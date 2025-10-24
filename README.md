# MethodProxies

MethodProxies is a Pharo instrumentation library that implements message-passing control (it controls method execution). It features a stratified architecture that cleanly separates the instrumentation mechanism from the user-defined controlling methods.
Users simply need to **subclass a handler class** and define the desired controlling methods.
The library ensures that these methods execute safely, as concerns such as meta-safety and stack unwinding are managed by the framework. Its robust design allows MethodProxies to instrument any method safely.

Message-passing control is an instrumentation paradigm where programs are instrumented to perform actions before, instead, and after a message is sent. This replaces the original method entirely, or performs no additional action at all.

## How to load

```st
EpMonitor disableDuring: [
	Metacello new
		baseline: 'MethodProxies';
		repository: 'github://pharo-contributions/MethodProxies/src';
		load. ]
```

#### How to depend on this project

```st
spec 
    baseline: 'MethodProxies' 
    with: [ spec repository: 'github://pharo-contributions/MethodProxies/src' ].
```

## Examples

A simple counting handler.

```st
handler :=  MpCountingHandler new.
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

A simple example showing that an handler may failed still the system does not destroy Pharo.

```st
"Managing exceptions in the spyied method"

p := MpMethodProxy 
        onMethod: MpClassB >> #methodTwo 
	handler: MpFailingBeforeHandler new.
p install.
p enableInstrumentation.
MpClassB new methodTwo.
p uninstall.
```

### Sharing Handlers

The design of method proxies supports the sharing of handlers between multiple proxied methods. 
For example the following example shows how we can monitor and gather information about `new` and `new:` in the same place

```st
h := MpAllocationProfilerHandler new.
p1 := MpMethodProxy 
	onMethod: Behavior >> #basicNew 
	handler: h.
p2 := MpMethodProxy 
	onMethod: Object >> #clone 
	handler: h.

p1 install.
p2 install.
p1 enableInstrumentation.
p2 enableInstrumentation.

Object new clone.

p1 uninstall.
p2 uninstall.

h allocations size
>>> 2
```

### Automatically proxies propagation (virus) 

A more advanced and challenging for the architecture of method proxies is a propagating handler. 
The idea is simple, before a method executes, all the implementor methods of its messages are proxified with propagating handlers.
So instead of proxifying the complete system only we subpart is spyied. This is this challenging because the infrastructure should make sure that we are not proxifying the code that is proxifying the system else we would end up in a severe and endless loop. 
The handler design protects you from that by avoiding that you extend and break the clear separation between base and meta-level.

```st
testCase := StringTest selector: #testAsCamelCase.
method :=  StringTest >> #testAsCamelCase.
(MpMethodProxy 
   onMethod: method 
   handler: MpProfilingHandler new) install; enableInstrumentation.
testCase run.

proxies := MpMethodProxy allInstances.
proxies do: #uninstall.
```

## Design 

MethodProxies design rests on two pillars: **handlers** and the **trap method** as presented in the Figure below.

- Each controlled method is associated with a dedicated handler that defines the controlling methods. This specialization allows different instrumented methods to execute different handlers: **each controlled method can have its own handler**. Handlers can also be shared.
- The second pillar, the trap method, is a **pre-compiled template method**. Instrumentation is achieved by copying the trap method and applying literal patching to replace the literal references to the actual handler and the original method. Finally, the trap method leverages Pharo’s *stack unwinding* mechanism to guarantee execution of the handlers without allocating block closures, gaining significantly in performance. The trap method is a precompiled template in which the before and after method handlers, and the original method are represented as literals, later updated through literal patching. It ensures safety by including a meta-safe mechanism to prevent infinite recursion and safe stack unwinds.

MethodProxies has a stratified architecture structured around two core classes: `MpMethodProxy` and `MpHandler`:

- `MpMethodProxy` manages the lifecycle of an instrumented method. Users are not exposed to the internal logic and the implementation details.
- `MpHandler` is the root of handlers. Users can subclass it and define the controlling methods.

Its API is composed of three methods:

- `beforeExecutionWithReceiver:arguments:` is called before the controlled method is invoked. It receives as arguments the actual receiver and the arguments of the controlled message send.
- `aboutToReturnWithReceiver:arguments:` is called before the controlled method exits due to a stack unwind. This situation occurs in the presence of non-local returns or exceptions.
- `afterExecutionWithReceiver:arguments:returnValue:` is called after the controlled method returns. This hook allows executing actions after the method has run, inspecting or modifying the return value. The return value of the controlled call is passed as an argument, and the method must return the final value to be used as the result of the instrumented method.

Moreover, two higher-level hooks are provided, defined in terms of the ones described above.
- `beforeMethod` is invoked before the method execution begins.
- It is a simpler version of `beforeExecutionWithReceiver:arguments:` that does not receives any arguments.
- `afterMethod` is invoked before the method returns, either by normal completion or due to a stack unwind. This method does not receives any arguments and it does not allow modification of the return value.

## Some Archeology and History

Method Wrappers were originally developed by John Brant for proprietary software. You can read "Evaluating Message Passing Control" article from S. Ducasse to understand the original implementation and a comparison with other approaches. What you see is that back in 1998/9 there were already multiple ways to control message passing. Method Wrappers is one of them. 

MethodWrappers were basically using CompiledMethod prototypes that were patched (cloned + adding selector/class) during their application because the VM of the system where Method Wrappers were implemented did not support to have anything but CompiledMethod as value of method dictionaries. 
This is not the case for Pharo. And the design and implementation of MethodProxies allows us to wrap any part of the system and in addition to design propagating proxies without blowing up the system. This is a key properties for us.

**Note for grumpies.** For the people that could think that we would like to steal this idea, we encourage them to lower their paranoia by having a look at our CV and publication record list. We redeveloped from scratch this library while taking into account the original intention and we wrote many tests to validate them.

## Bibliography

- Jordan Montaño S., Sandoval Alcócer J., Polito G., Ducasse S., Tesone P., MethodProxies: A Safe and Fast Message-Passing Control Library, IWST '24 June 2024, France. [PDF](https://hal.science/hal-04708729v1/document)
- Stéphane Ducasse, Evaluating Message Passing Control Techniques in Smalltalk, Journal of Object-Oriented Programming (JOOP), 12, 39–44, SIGS Press, 1999, Impact factor 0.306. [PDF](http://rmod-files.lille.inria.fr/Team/Texts/Papers/Duca99aMsgPassingControl.pdf)
- John Brant, Brian Foote, Ralph E. Johnson, and Donald Roberts. Wrappers to the Rescue. In Proceedings of European Conference on Object-Oriented Programming (ECOOP). Springer, Berlin, Heidelberg, 1998. http://www.laputan.org/brant/brant.html (https://link.springer.com/chapter/10.1007/BFb0054101)


