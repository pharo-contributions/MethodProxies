# MethodProxies

MethodProxies is a Pharo instrumentation library for **message-passing control**. It lets you execute custom code **before**, **after**, **instead of**, or **during the unwind of** any method execution — without changing the method's source.

It is designed for building profilers, tracers, call-graph analyzers, mocks, and other dynamic analysis tools. Its stratified architecture cleanly separates the instrumentation mechanism (handled by the framework) from the user-defined behavior, so all you need to do is **subclass a handler** and define a few hooks.

MethodProxies guarantees:

- **Meta-safety** — instrumented methods can safely call other instrumented methods without triggering infinite recursion.
- **Unwind-safety** — non-local returns and exceptions are handled correctly.
- **Meta-thread safety** — the meta-level state is tracked per process.
- **Dynamic (de)instrumentation** — instrumentation can be installed and removed at run time.
- **Practical overhead** — the trap-method approach integrates with the JIT and with polymorphic inline caches.

## Loading

```st
EpMonitor disableDuring: [
    Metacello new
        baseline: 'MethodProxies';
        repository: 'github://pharo-contributions/MethodProxies/src';
        load ]
```

To depend on it from your own baseline:

```st
spec
    baseline: 'MethodProxies'
    with: [ spec repository: 'github://pharo-contributions/MethodProxies/src' ]
```

## Basic Usage

A proxy associates a method with a handler. You install it, enable instrumentation, run your code, then uninstall.

```st
handler := MpCountingHandler new.
p := MpMethodProxy
    onMethod: Object >> #error:
    handler: handler.
p install.
p enableInstrumentation.
1 error: 'foo'.
p uninstall.
handler count.
>>> 1
```

A failure inside a handler will not corrupt the system. The framework safely unwinds the stack and restores normal execution:

```st
p := MpMethodProxy
    onMethod: MpClassB >> #methodTwo
    handler: MpFailingBeforeHandler new.
p install.
p enableInstrumentation.
MpClassB new methodTwo.
p uninstall.
```

## Defining a Handler

Subclass `MpHandler` and override one or more of the hooks below.

### `before` and `after`

```st
beforeExecutionWithReceiver: receiver arguments: args
    "Called before the controlled method runs."

afterExecutionWithReceiver: receiver arguments: args returnValue: value
    "Called after a normal return. MUST return the value the proxied method should yield.
     Return `value` to keep it as-is, or return something else to override the result."
```

For convenience, two simpler hooks are also provided. They are useful when the receiver, the arguments, or the return value are not needed:

```st
beforeMethod    "no arguments"
afterMethod     "no arguments, cannot modify the return value"
```

Example — a handler that rewrites the return value (defined on a subclass `MpChangesReturnValueHandler` of `MpHandler`):

```st
MpChangesReturnValueHandler >>
afterExecutionWithReceiver: receiver arguments: arguments returnValue: returnValue
    ^ 'trapped [' , returnValue asString , ']'
```

### `instead` — replace the original method

The `instead` hook completely replaces the original method body. When `instead` is defined, `before` and `after` are **not** invoked: the original method is never called.

For example, a handler `MpAlwaysReturn42Handler` (a subclass of `MpHandler`) can override the receiver's behavior like this:

```st
MpAlwaysReturn42Handler >> insteadExecutionWithReceiver: receiver
    ^ 42
```

Using it:

```st
p := MpMethodProxy
    onMethod: MpClassA >> #methodOne
    handler: MpAlwaysReturn42Handler new.
p install.
p enableInstrumentation.
MpClassA new methodOne.
>>> 42                "the original method is not executed"
p uninstall.
```

For methods that take arguments, use `insteadExecutionWithReceiver:arguments:` (or one of the keyword variants `insteadExecutionWithReceiver:with:`, `...with:with:`, etc.).

The `instead` hook is useful for mocking, stubbing in tests, fault injection, or quickly experimenting with alternative implementations.

### Unwind — non-local returns and exceptions

`aboutToReturnWithReceiver:arguments:` is invoked when the controlled method exits via a stack unwind — an exception or a non-local return. By default it delegates to `afterExecutionWithReceiver:arguments:returnValue:` with a `nil` return value, but you can override it to react specifically to abnormal exits:

```st
MyHandler >> aboutToReturnWithReceiver: receiver arguments: args
    "Called only when the method is being unwound."
    ...
```

### Sharing handlers

The same handler can be installed on multiple methods, which is convenient for aggregating information from several places. For example, monitoring `basicNew` and `clone` together:

```st
h := MpAllocationProfilerHandler new.
p1 := MpMethodProxy onMethod: Behavior >> #basicNew handler: h.
p2 := MpMethodProxy onMethod: Object   >> #clone    handler: h.

p1 install. p2 install.
p1 enableInstrumentation. p2 enableInstrumentation.

Object new clone.

p1 uninstall. p2 uninstall.
h allocations size
>>> 2
```

## Design

MethodProxies rests on two pillars: **handlers** and the **trap method**.

- Each instrumented method is associated with a handler. Users subclass `MpHandler` and override the hooks; they never touch the low-level machinery. Different methods can have different handlers, and handlers can be shared.
- The **trap method** is a precompiled template installed in place of the instrumented method. At installation time it is patched via *literal patching* to reference the actual handler and the original method. The original method is kept in the same method dictionary under a hidden selector, so the forwarding call becomes a monomorphic, JIT-friendly message send.

The trap also tracks a meta-level state on the active process. Whenever a hook executes, the process is marked as *meta*. While in this state, any instrumented method called from within the handler short-circuits to the original behavior, which avoids the infinite-recursion problem that affects simpler approaches. Stack unwinds are handled directly through the VM's unwind mechanism, **without allocating block closures**, giving significantly better performance than approaches based on `ensure:`.

The architecture has two strata: `MpMethodProxy` manages the lifecycle of an instrumented method and hides the implementation details, while `MpHandler` is the root class users subclass to define their controlling methods.

A full description of the design, the implementation, and the empirical evaluation is available in the IWST '24 paper listed in the bibliography. On a suite of 48 benchmarks across four real-world applications, the average overhead is about 1.54× and the meta-safety mechanism itself adds roughly 9% on top. Compared to instrumentation based on the `run:with:in:` hook — which cannot be JIT-compiled — MethodProxies is on average 6.5× faster, with peaks up to 40×.

## Advanced: Propagating Handlers

A more advanced use case is a *propagating* handler: before a method runs, all the implementors of the messages it sends are themselves wrapped with the same kind of handler. Instead of instrumenting the entire system upfront, only the subset of code that actually executes is instrumented. The challenge is to avoid instrumenting the instrumentation code itself, which would lead to an infinite loop. The handler design and the meta-safety mechanism take care of this by preserving the separation between base and meta levels.

```st
testCase := StringTest selector: #testAsCamelCase.
method   := StringTest >> #testAsCamelCase.
(MpMethodProxy
    onMethod: method
    handler: MpProfilingHandler new) install; enableInstrumentation.
testCase run.

proxies := MpMethodProxy allInstances.
proxies do: #uninstall.
```

## Bibliography

- Jordan Montaño S., Sandoval Alcócer J., Polito G., Ducasse S., Tesone P. *MethodProxies: A Safe and Fast Message-Passing Control Library.* IWST '24, June 2024, France. [PDF](https://hal.science/hal-04708729v1/document)
- Stéphane Ducasse. *Evaluating Message Passing Control Techniques in Smalltalk.* Journal of Object-Oriented Programming (JOOP), 12, 39–44, SIGS Press, 1999. [PDF](http://rmod-files.lille.inria.fr/Team/Texts/Papers/Duca99aMsgPassingControl.pdf)
