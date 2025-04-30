"
I implement a method proxy that can wrap a method and do something before/after it.
I'm implemented as a stratified proxy: the specific instrumentation and the implementation of the instrumentation are separate concerns.
I am responsible of the instrumentation implementation, and I delegate to a handler object the corresponding instrumentation.
This allows users to define their own concerns without caring about specifics of the implementation.

## Basic Usage

A proxy is created by giving the method to wrap and a handler.
The proxy is not installed by default in the system.
Send it the message `install` to make it available.

```smalltalk
	mp := MpMethodProxy onMethod: Context >> #aboutToReturn:through: handler: (handler := MpCountingHandler new).
	mp install.
```

After installation the proxy will trap calls to the wrapped method and transfer them to the handler.
To uninstall a proxy, send it the message `#uninstall`

```smalltalk
	mp uninstall.
```

Check the implementation of `MpHandler` to understand how to define new handlers.

## Implementation notes

To instrument method executions, I use normal methods and literal patching which plays very well with the JIT and inline caches.
The general strategy is the following.

The original method is installed in the method dictionary with another selector (an object instance of `MpHiddenSelector`).
A trap method accepting the same number of arguments than the original method is copied, then it is patched so it forwards the message to the previously crafted selector.
Since the instrumented method is installed with a selector that has only one sender, this will become a monomorphic linked callsite after the first call.

Moreover, trap methods have been optimized to avoid allocating ensure blocks, stack reifications and other subtleties required for stack unwind (correct management of exceptions and non-local returns) which makes it very slow. Trap methods are thus written as:

```smalltalk
MpMethodProxy class >> trapWith: arg1 with: arg2
  | handler |
  handler := ""some object that understands value"".
  ...
```

This allows

- unwind without extra blocks and less contexts
- having a very fast execution path without unwind in the middle.

On top of this, the handler of traps is set as a literal that is patched.

That literal is a normal object (`MpProxyInstrumentationDeactivator`) that on value inspects the stack (we are in the slow case anyways, who cares! :D) and performs what is required to do.
"
Class {
	#name : 'MpMethodProxy',
	#superclass : 'Object',
	#instVars : [
		'handler',
		'hiddenSelector',
		'trapMethod',
		'wrappedMethod',
		'proxifiedMethod'
	],
	#classVars : [
		'ENABLED'
	],
	#category : 'MethodProxies',
	#package : 'MethodProxies'
}

{ #category : 'evaluating' }
MpMethodProxy class >> buildPrototypesUpToArguments: maxNumberOfArguments [
	"This method builds/compiles the prototype traps for arguments up to the argument.
	The trap prototypes are installed in this class' class side.
	They can later be copied and patched by MpMethodProxy"

	"self buildPrototypesUpToArguments: 15"

	| forwarders argumentListNodes |
	0 to: maxNumberOfArguments do: [ :numberOfArguments |
		| originalAst trapSelector trapArguments |
		originalAst := (self class >> #prototypeTrap) parseTree.

		trapSelector := #trapMethod.
		1 to: numberOfArguments do: [ :i | trapSelector := trapSelector , #with: ].
		trapArguments := (1 to: numberOfArguments) collect: [ :i |
			                 RBVariableNode named: 'arg' , i asString ].

		originalAst selector: trapSelector.
		originalAst arguments: trapArguments.
		
		argumentListNodes := originalAst allChildren select: [ :e | e value = #argumentList ].
		argumentListNodes do: [ :e | e replaceWith: (RBArrayNode statements: trapArguments) ].

		forwarders := originalAst sendNodes select: [ :e | e selector = #originalMessage ].
		forwarders do: [ :e |
			e replaceWith: (RBMessageNode
					 receiver: RBVariableNode selfNode
					 selector: trapSelector
					 arguments: trapArguments) ].
		self class compile: originalAst formattedCode ]
]

{ #category : 'as yet unclassified' }
MpMethodProxy class >> disableInstrumentation [

	ENABLED := false
]

{ #category : 'as yet unclassified' }
MpMethodProxy class >> enableInstrumentation [

	ENABLED := true
]

{ #category : 'class initialization' }
MpMethodProxy class >> initialize [

	self disableInstrumentation
]

{ #category : 'instance creation' }
MpMethodProxy class >> onMethod: aMethod handler: aHandler [

	^ self new
		  proxyMethod: aMethod;
		  handler: aHandler;
		  yourself
]

{ #category : 'evaluating' }
MpMethodProxy class >> prototypeTrap [
	"The unwind handler should be the first temp, the complete flag should be the second temp.
	Then this method is free to use as many extra temporaries and arguments as is wants"

	<trap>
	<primitive: 198>
	| deactivator complete result process wasMeta |
	ENABLED ifFalse: [ ^ self originalMessage ].
	process := Processor activeProcess.
	process isMeta ifTrue: [ ^ self originalMessage ].	

	"Set the deactivator literal for the slow path.
	It will be patched to an exception handler"
	deactivator := #slowdeactivator.

	"Move to the meta level and call the before hook"
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: #argumentList.
	process shiftLevelDown.
	wasMeta := false.

	"Back in the base-level forward the original message.
	This is a message to self that will be monomorphically linked by the VM.
	The core idea is that
	 - the original method is installed in the same method dictionary using a unique symbol
	 - this call is patched to use that symbol for the send"
	result := self originalMessage.

	"Move to the meta level and call the after hooks.
	Two after hooks are required.
	One indicates the method is returning either because a normal return, or a stack unwind due to exceptions or non-local returns
	The other indicates we are returning normally with a value."
	process shiftLevelUp.
	wasMeta := true.
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: #argumentList
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false.

	"Mark the execution as complete to avoid double execution of the unwind handler"
	complete := true.
	^ result
]

{ #category : 'as yet unclassified' }
MpMethodProxy class >> proxyMethod: method handler: aHandler [

	^ MpMethodProxy new
		  proxyMethod: method;
		  handler: aHandler;
		  yourself
]

{ #category : 'as yet unclassified' }
MpMethodProxy class >> trapMethod [
	"The unwind handler should be the first temp, the complete flag should be the second temp.
	Then this method is free to use as many extra temporaries and arguments as is wants"
	<trap>
	<primitive: 198>
	| deactivator complete result process wasMeta |
	ENABLED ifFalse: [ ^ self trapMethod ].
	process := Processor activeProcess.
	process isMeta ifTrue: [ ^ self trapMethod ] "Set the deactivator literal for the slow path.
	It will be patched to an exception handler".
	deactivator := #slowdeactivator "Move to the meta level and call the before hook".
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: {  }.
	process shiftLevelDown.
	wasMeta := false "Back in the base-level forward the original message.
	This is a message to self that will be monomorphically linked by the VM.
	The core idea is that
	 - the original method is installed in the same method dictionary using a unique symbol
	 - this call is patched to use that symbol for the send".
	result := self trapMethod "Move to the meta level and call the after hooks.
	Two after hooks are required.
	One indicates the method is returning either because a normal return, or a stack unwind due to exceptions or non-local returns
	The other indicates we are returning normally with a value.".
	process shiftLevelUp.
	wasMeta := true.
	result := #handler afterExecutionWithReceiver: self arguments: {  } returnValue: result.
	process shiftLevelDown.
	wasMeta := false "Mark the execution as complete to avoid double execution of the unwind handler".
	complete := true.
	^ result
]

{ #category : 'as yet unclassified' }
MpMethodProxy class >> trapMethodwith: arg1 [
	"The unwind handler should be the first temp, the complete flag should be the second temp.
	Then this method is free to use as many extra temporaries and arguments as is wants"
	<trap>
	<primitive: 198>
	| deactivator complete result process wasMeta |
	ENABLED ifFalse: [ ^ self trapMethodwith: arg1 ].
	process := Processor activeProcess.
	process isMeta ifTrue: [ ^ self trapMethodwith: arg1 ] "Set the deactivator literal for the slow path.
	It will be patched to an exception handler".
	deactivator := #slowdeactivator "Move to the meta level and call the before hook".
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: { arg1 }.
	process shiftLevelDown.
	wasMeta := false "Back in the base-level forward the original message.
	This is a message to self that will be monomorphically linked by the VM.
	The core idea is that
	 - the original method is installed in the same method dictionary using a unique symbol
	 - this call is patched to use that symbol for the send".
	result := self trapMethodwith: arg1 "Move to the meta level and call the after hooks.
	Two after hooks are required.
	One indicates the method is returning either because a normal return, or a stack unwind due to exceptions or non-local returns
	The other indicates we are returning normally with a value.".
	process shiftLevelUp.
	wasMeta := true.
	result := #handler afterExecutionWithReceiver: self arguments: { arg1 } returnValue: result.
	process shiftLevelDown.
	wasMeta := false "Mark the execution as complete to avoid double execution of the unwind handler".
	complete := true.
	^ result
]

{ #category : 'as yet unclassified' }
MpMethodProxy class >> trapMethodwith: arg1 with: arg2 [
	"The unwind handler should be the first temp, the complete flag should be the second temp.
	Then this method is free to use as many extra temporaries and arguments as is wants"
	<trap>
	<primitive: 198>
	| deactivator complete result process wasMeta |
	ENABLED ifFalse: [ ^ self trapMethodwith: arg1 with: arg2 ].
	process := Processor activeProcess.
	process isMeta ifTrue: [ ^ self trapMethodwith: arg1 with: arg2 ] "Set the deactivator literal for the slow path.
	It will be patched to an exception handler".
	deactivator := #slowdeactivator "Move to the meta level and call the before hook".
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: {
			arg1.
			arg2 }.
	process shiftLevelDown.
	wasMeta := false "Back in the base-level forward the original message.
	This is a message to self that will be monomorphically linked by the VM.
	The core idea is that
	 - the original method is installed in the same method dictionary using a unique symbol
	 - this call is patched to use that symbol for the send".
	result := self trapMethodwith: arg1 with: arg2 "Move to the meta level and call the after hooks.
	Two after hooks are required.
	One indicates the method is returning either because a normal return, or a stack unwind due to exceptions or non-local returns
	The other indicates we are returning normally with a value.".
	process shiftLevelUp.
	wasMeta := true.
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: {
				          arg1.
				          arg2 }
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false "Mark the execution as complete to avoid double execution of the unwind handler".
	complete := true.
	^ result
]

{ #category : 'as yet unclassified' }
MpMethodProxy class >> trapMethodwith: arg1 with: arg2 with: arg3 [
	"The unwind handler should be the first temp, the complete flag should be the second temp.
	Then this method is free to use as many extra temporaries and arguments as is wants"
	<trap>
	<primitive: 198>
	| deactivator complete result process wasMeta |
	ENABLED ifFalse: [ ^ self trapMethodwith: arg1 with: arg2 with: arg3 ].
	process := Processor activeProcess.
	process isMeta ifTrue: [ ^ self trapMethodwith: arg1 with: arg2 with: arg3 ] "Set the deactivator literal for the slow path.
	It will be patched to an exception handler".
	deactivator := #slowdeactivator "Move to the meta level and call the before hook".
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: {
			arg1.
			arg2.
			arg3 }.
	process shiftLevelDown.
	wasMeta := false "Back in the base-level forward the original message.
	This is a message to self that will be monomorphically linked by the VM.
	The core idea is that
	 - the original method is installed in the same method dictionary using a unique symbol
	 - this call is patched to use that symbol for the send".
	result := self trapMethodwith: arg1 with: arg2 with: arg3 "Move to the meta level and call the after hooks.
	Two after hooks are required.
	One indicates the method is returning either because a normal return, or a stack unwind due to exceptions or non-local returns
	The other indicates we are returning normally with a value.".
	process shiftLevelUp.
	wasMeta := true.
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: {
				          arg1.
				          arg2.
				          arg3 }
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false "Mark the execution as complete to avoid double execution of the unwind handler".
	complete := true.
	^ result
]

{ #category : 'as yet unclassified' }
MpMethodProxy class >> trapMethodwith: arg1 with: arg2 with: arg3 with: arg4 [
	"The unwind handler should be the first temp, the complete flag should be the second temp.
	Then this method is free to use as many extra temporaries and arguments as is wants"
	<trap>
	<primitive: 198>
	| deactivator complete result process wasMeta |
	ENABLED ifFalse: [
			^ self
				  trapMethodwith: arg1
				  with: arg2
				  with: arg3
				  with: arg4 ].
	process := Processor activeProcess.
	process isMeta ifTrue: [
			^ self
				  trapMethodwith: arg1
				  with: arg2
				  with: arg3
				  with: arg4 ] "Set the deactivator literal for the slow path.
	It will be patched to an exception handler".
	deactivator := #slowdeactivator "Move to the meta level and call the before hook".
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: {
			arg1.
			arg2.
			arg3.
			arg4 }.
	process shiftLevelDown.
	wasMeta := false "Back in the base-level forward the original message.
	This is a message to self that will be monomorphically linked by the VM.
	The core idea is that
	 - the original method is installed in the same method dictionary using a unique symbol
	 - this call is patched to use that symbol for the send".
	result := self
		          trapMethodwith: arg1
		          with: arg2
		          with: arg3
		          with: arg4 "Move to the meta level and call the after hooks.
	Two after hooks are required.
	One indicates the method is returning either because a normal return, or a stack unwind due to exceptions or non-local returns
	The other indicates we are returning normally with a value.".
	process shiftLevelUp.
	wasMeta := true.
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: {
				          arg1.
				          arg2.
				          arg3.
				          arg4 }
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false "Mark the execution as complete to avoid double execution of the unwind handler".
	complete := true.
	^ result
]

{ #category : 'as yet unclassified' }
MpMethodProxy class >> trapMethodwith: arg1 with: arg2 with: arg3 with: arg4 with: arg5 [
	"The unwind handler should be the first temp, the complete flag should be the second temp.
	Then this method is free to use as many extra temporaries and arguments as is wants"
	<trap>
	<primitive: 198>
	| deactivator complete result process wasMeta |
	ENABLED ifFalse: [
			^ self
				  trapMethodwith: arg1
				  with: arg2
				  with: arg3
				  with: arg4
				  with: arg5 ].
	process := Processor activeProcess.
	process isMeta ifTrue: [
			^ self
				  trapMethodwith: arg1
				  with: arg2
				  with: arg3
				  with: arg4
				  with: arg5 ] "Set the deactivator literal for the slow path.
	It will be patched to an exception handler".
	deactivator := #slowdeactivator "Move to the meta level and call the before hook".
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: {
			arg1.
			arg2.
			arg3.
			arg4.
			arg5 }.
	process shiftLevelDown.
	wasMeta := false "Back in the base-level forward the original message.
	This is a message to self that will be monomorphically linked by the VM.
	The core idea is that
	 - the original method is installed in the same method dictionary using a unique symbol
	 - this call is patched to use that symbol for the send".
	result := self
		          trapMethodwith: arg1
		          with: arg2
		          with: arg3
		          with: arg4
		          with: arg5 "Move to the meta level and call the after hooks.
	Two after hooks are required.
	One indicates the method is returning either because a normal return, or a stack unwind due to exceptions or non-local returns
	The other indicates we are returning normally with a value.".
	process shiftLevelUp.
	wasMeta := true.
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: {
				          arg1.
				          arg2.
				          arg3.
				          arg4.
				          arg5 }
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false "Mark the execution as complete to avoid double execution of the unwind handler".
	complete := true.
	^ result
]

{ #category : 'as yet unclassified' }
MpMethodProxy class >> trapMethodwith: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 [
	"The unwind handler should be the first temp, the complete flag should be the second temp.
	Then this method is free to use as many extra temporaries and arguments as is wants"
	<trap>
	<primitive: 198>
	| deactivator complete result process wasMeta |
	ENABLED ifFalse: [
			^ self
				  trapMethodwith: arg1
				  with: arg2
				  with: arg3
				  with: arg4
				  with: arg5
				  with: arg6 ].
	process := Processor activeProcess.
	process isMeta ifTrue: [
			^ self
				  trapMethodwith: arg1
				  with: arg2
				  with: arg3
				  with: arg4
				  with: arg5
				  with: arg6 ] "Set the deactivator literal for the slow path.
	It will be patched to an exception handler".
	deactivator := #slowdeactivator "Move to the meta level and call the before hook".
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: {
			arg1.
			arg2.
			arg3.
			arg4.
			arg5.
			arg6 }.
	process shiftLevelDown.
	wasMeta := false "Back in the base-level forward the original message.
	This is a message to self that will be monomorphically linked by the VM.
	The core idea is that
	 - the original method is installed in the same method dictionary using a unique symbol
	 - this call is patched to use that symbol for the send".
	result := self
		          trapMethodwith: arg1
		          with: arg2
		          with: arg3
		          with: arg4
		          with: arg5
		          with: arg6 "Move to the meta level and call the after hooks.
	Two after hooks are required.
	One indicates the method is returning either because a normal return, or a stack unwind due to exceptions or non-local returns
	The other indicates we are returning normally with a value.".
	process shiftLevelUp.
	wasMeta := true.
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: {
				          arg1.
				          arg2.
				          arg3.
				          arg4.
				          arg5.
				          arg6 }
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false "Mark the execution as complete to avoid double execution of the unwind handler".
	complete := true.
	^ result
]

{ #category : 'as yet unclassified' }
MpMethodProxy class >> trapMethodwith: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 with: arg7 [
	"The unwind handler should be the first temp, the complete flag should be the second temp.
	Then this method is free to use as many extra temporaries and arguments as is wants"
	<trap>
	<primitive: 198>
	| deactivator complete result process wasMeta |
	ENABLED ifFalse: [
			^ self
				  trapMethodwith: arg1
				  with: arg2
				  with: arg3
				  with: arg4
				  with: arg5
				  with: arg6
				  with: arg7 ].
	process := Processor activeProcess.
	process isMeta ifTrue: [
			^ self
				  trapMethodwith: arg1
				  with: arg2
				  with: arg3
				  with: arg4
				  with: arg5
				  with: arg6
				  with: arg7 ] "Set the deactivator literal for the slow path.
	It will be patched to an exception handler".
	deactivator := #slowdeactivator "Move to the meta level and call the before hook".
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: {
			arg1.
			arg2.
			arg3.
			arg4.
			arg5.
			arg6.
			arg7 }.
	process shiftLevelDown.
	wasMeta := false "Back in the base-level forward the original message.
	This is a message to self that will be monomorphically linked by the VM.
	The core idea is that
	 - the original method is installed in the same method dictionary using a unique symbol
	 - this call is patched to use that symbol for the send".
	result := self
		          trapMethodwith: arg1
		          with: arg2
		          with: arg3
		          with: arg4
		          with: arg5
		          with: arg6
		          with: arg7 "Move to the meta level and call the after hooks.
	Two after hooks are required.
	One indicates the method is returning either because a normal return, or a stack unwind due to exceptions or non-local returns
	The other indicates we are returning normally with a value.".
	process shiftLevelUp.
	wasMeta := true.
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: {
				          arg1.
				          arg2.
				          arg3.
				          arg4.
				          arg5.
				          arg6.
				          arg7 }
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false "Mark the execution as complete to avoid double execution of the unwind handler".
	complete := true.
	^ result
]

{ #category : 'as yet unclassified' }
MpMethodProxy class >> trapMethodwith: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 with: arg7 with: arg8 [
	"The unwind handler should be the first temp, the complete flag should be the second temp.
	Then this method is free to use as many extra temporaries and arguments as is wants"
	<trap>
	<primitive: 198>
	| deactivator complete result process wasMeta |
	ENABLED ifFalse: [
			^ self
				  trapMethodwith: arg1
				  with: arg2
				  with: arg3
				  with: arg4
				  with: arg5
				  with: arg6
				  with: arg7
				  with: arg8 ].
	process := Processor activeProcess.
	process isMeta ifTrue: [
			^ self
				  trapMethodwith: arg1
				  with: arg2
				  with: arg3
				  with: arg4
				  with: arg5
				  with: arg6
				  with: arg7
				  with: arg8 ] "Set the deactivator literal for the slow path.
	It will be patched to an exception handler".
	deactivator := #slowdeactivator "Move to the meta level and call the before hook".
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: {
			arg1.
			arg2.
			arg3.
			arg4.
			arg5.
			arg6.
			arg7.
			arg8 }.
	process shiftLevelDown.
	wasMeta := false "Back in the base-level forward the original message.
	This is a message to self that will be monomorphically linked by the VM.
	The core idea is that
	 - the original method is installed in the same method dictionary using a unique symbol
	 - this call is patched to use that symbol for the send".
	result := self
		          trapMethodwith: arg1
		          with: arg2
		          with: arg3
		          with: arg4
		          with: arg5
		          with: arg6
		          with: arg7
		          with: arg8 "Move to the meta level and call the after hooks.
	Two after hooks are required.
	One indicates the method is returning either because a normal return, or a stack unwind due to exceptions or non-local returns
	The other indicates we are returning normally with a value.".
	process shiftLevelUp.
	wasMeta := true.
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: {
				          arg1.
				          arg2.
				          arg3.
				          arg4.
				          arg5.
				          arg6.
				          arg7.
				          arg8 }
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false "Mark the execution as complete to avoid double execution of the unwind handler".
	complete := true.
	^ result
]

{ #category : 'as yet unclassified' }
MpMethodProxy class >> trapMethodwith: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 with: arg7 with: arg8 with: arg9 [
	"The unwind handler should be the first temp, the complete flag should be the second temp.
	Then this method is free to use as many extra temporaries and arguments as is wants"
	<trap>
	<primitive: 198>
	| deactivator complete result process wasMeta |
	ENABLED ifFalse: [
			^ self
				  trapMethodwith: arg1
				  with: arg2
				  with: arg3
				  with: arg4
				  with: arg5
				  with: arg6
				  with: arg7
				  with: arg8
				  with: arg9 ].
	process := Processor activeProcess.
	process isMeta ifTrue: [
			^ self
				  trapMethodwith: arg1
				  with: arg2
				  with: arg3
				  with: arg4
				  with: arg5
				  with: arg6
				  with: arg7
				  with: arg8
				  with: arg9 ] "Set the deactivator literal for the slow path.
	It will be patched to an exception handler".
	deactivator := #slowdeactivator "Move to the meta level and call the before hook".
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: {
			arg1.
			arg2.
			arg3.
			arg4.
			arg5.
			arg6.
			arg7.
			arg8.
			arg9 }.
	process shiftLevelDown.
	wasMeta := false "Back in the base-level forward the original message.
	This is a message to self that will be monomorphically linked by the VM.
	The core idea is that
	 - the original method is installed in the same method dictionary using a unique symbol
	 - this call is patched to use that symbol for the send".
	result := self
		          trapMethodwith: arg1
		          with: arg2
		          with: arg3
		          with: arg4
		          with: arg5
		          with: arg6
		          with: arg7
		          with: arg8
		          with: arg9 "Move to the meta level and call the after hooks.
	Two after hooks are required.
	One indicates the method is returning either because a normal return, or a stack unwind due to exceptions or non-local returns
	The other indicates we are returning normally with a value.".
	process shiftLevelUp.
	wasMeta := true.
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: {
				          arg1.
				          arg2.
				          arg3.
				          arg4.
				          arg5.
				          arg6.
				          arg7.
				          arg8.
				          arg9 }
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false "Mark the execution as complete to avoid double execution of the unwind handler".
	complete := true.
	^ result
]

{ #category : 'as yet unclassified' }
MpMethodProxy class >> trapMethodwith: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 with: arg7 with: arg8 with: arg9 with: arg10 [
	"The unwind handler should be the first temp, the complete flag should be the second temp.
	Then this method is free to use as many extra temporaries and arguments as is wants"
	<trap>
	<primitive: 198>
	| deactivator complete result process wasMeta |
	ENABLED ifFalse: [
			^ self
				  trapMethodwith: arg1
				  with: arg2
				  with: arg3
				  with: arg4
				  with: arg5
				  with: arg6
				  with: arg7
				  with: arg8
				  with: arg9
				  with: arg10 ].
	process := Processor activeProcess.
	process isMeta ifTrue: [
			^ self
				  trapMethodwith: arg1
				  with: arg2
				  with: arg3
				  with: arg4
				  with: arg5
				  with: arg6
				  with: arg7
				  with: arg8
				  with: arg9
				  with: arg10 ] "Set the deactivator literal for the slow path.
	It will be patched to an exception handler".
	deactivator := #slowdeactivator "Move to the meta level and call the before hook".
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: {
			arg1.
			arg2.
			arg3.
			arg4.
			arg5.
			arg6.
			arg7.
			arg8.
			arg9.
			arg10 }.
	process shiftLevelDown.
	wasMeta := false "Back in the base-level forward the original message.
	This is a message to self that will be monomorphically linked by the VM.
	The core idea is that
	 - the original method is installed in the same method dictionary using a unique symbol
	 - this call is patched to use that symbol for the send".
	result := self
		          trapMethodwith: arg1
		          with: arg2
		          with: arg3
		          with: arg4
		          with: arg5
		          with: arg6
		          with: arg7
		          with: arg8
		          with: arg9
		          with: arg10 "Move to the meta level and call the after hooks.
	Two after hooks are required.
	One indicates the method is returning either because a normal return, or a stack unwind due to exceptions or non-local returns
	The other indicates we are returning normally with a value.".
	process shiftLevelUp.
	wasMeta := true.
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: {
				          arg1.
				          arg2.
				          arg3.
				          arg4.
				          arg5.
				          arg6.
				          arg7.
				          arg8.
				          arg9.
				          arg10 }
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false "Mark the execution as complete to avoid double execution of the unwind handler".
	complete := true.
	^ result
]

{ #category : 'as yet unclassified' }
MpMethodProxy class >> trapMethodwith: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 with: arg7 with: arg8 with: arg9 with: arg10 with: arg11 [
	"The unwind handler should be the first temp, the complete flag should be the second temp.
	Then this method is free to use as many extra temporaries and arguments as is wants"
	<trap>
	<primitive: 198>
	| deactivator complete result process wasMeta |
	ENABLED ifFalse: [
			^ self
				  trapMethodwith: arg1
				  with: arg2
				  with: arg3
				  with: arg4
				  with: arg5
				  with: arg6
				  with: arg7
				  with: arg8
				  with: arg9
				  with: arg10
				  with: arg11 ].
	process := Processor activeProcess.
	process isMeta ifTrue: [
			^ self
				  trapMethodwith: arg1
				  with: arg2
				  with: arg3
				  with: arg4
				  with: arg5
				  with: arg6
				  with: arg7
				  with: arg8
				  with: arg9
				  with: arg10
				  with: arg11 ] "Set the deactivator literal for the slow path.
	It will be patched to an exception handler".
	deactivator := #slowdeactivator "Move to the meta level and call the before hook".
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: {
			arg1.
			arg2.
			arg3.
			arg4.
			arg5.
			arg6.
			arg7.
			arg8.
			arg9.
			arg10.
			arg11 }.
	process shiftLevelDown.
	wasMeta := false "Back in the base-level forward the original message.
	This is a message to self that will be monomorphically linked by the VM.
	The core idea is that
	 - the original method is installed in the same method dictionary using a unique symbol
	 - this call is patched to use that symbol for the send".
	result := self
		          trapMethodwith: arg1
		          with: arg2
		          with: arg3
		          with: arg4
		          with: arg5
		          with: arg6
		          with: arg7
		          with: arg8
		          with: arg9
		          with: arg10
		          with: arg11 "Move to the meta level and call the after hooks.
	Two after hooks are required.
	One indicates the method is returning either because a normal return, or a stack unwind due to exceptions or non-local returns
	The other indicates we are returning normally with a value.".
	process shiftLevelUp.
	wasMeta := true.
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: {
				          arg1.
				          arg2.
				          arg3.
				          arg4.
				          arg5.
				          arg6.
				          arg7.
				          arg8.
				          arg9.
				          arg10.
				          arg11 }
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false "Mark the execution as complete to avoid double execution of the unwind handler".
	complete := true.
	^ result
]

{ #category : 'as yet unclassified' }
MpMethodProxy class >> trapMethodwith: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 with: arg7 with: arg8 with: arg9 with: arg10 with: arg11 with: arg12 [
	"The unwind handler should be the first temp, the complete flag should be the second temp.
	Then this method is free to use as many extra temporaries and arguments as is wants"
	<trap>
	<primitive: 198>
	| deactivator complete result process wasMeta |
	ENABLED ifFalse: [
			^ self
				  trapMethodwith: arg1
				  with: arg2
				  with: arg3
				  with: arg4
				  with: arg5
				  with: arg6
				  with: arg7
				  with: arg8
				  with: arg9
				  with: arg10
				  with: arg11
				  with: arg12 ].
	process := Processor activeProcess.
	process isMeta ifTrue: [
			^ self
				  trapMethodwith: arg1
				  with: arg2
				  with: arg3
				  with: arg4
				  with: arg5
				  with: arg6
				  with: arg7
				  with: arg8
				  with: arg9
				  with: arg10
				  with: arg11
				  with: arg12 ] "Set the deactivator literal for the slow path.
	It will be patched to an exception handler".
	deactivator := #slowdeactivator "Move to the meta level and call the before hook".
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: {
			arg1.
			arg2.
			arg3.
			arg4.
			arg5.
			arg6.
			arg7.
			arg8.
			arg9.
			arg10.
			arg11.
			arg12 }.
	process shiftLevelDown.
	wasMeta := false "Back in the base-level forward the original message.
	This is a message to self that will be monomorphically linked by the VM.
	The core idea is that
	 - the original method is installed in the same method dictionary using a unique symbol
	 - this call is patched to use that symbol for the send".
	result := self
		          trapMethodwith: arg1
		          with: arg2
		          with: arg3
		          with: arg4
		          with: arg5
		          with: arg6
		          with: arg7
		          with: arg8
		          with: arg9
		          with: arg10
		          with: arg11
		          with: arg12 "Move to the meta level and call the after hooks.
	Two after hooks are required.
	One indicates the method is returning either because a normal return, or a stack unwind due to exceptions or non-local returns
	The other indicates we are returning normally with a value.".
	process shiftLevelUp.
	wasMeta := true.
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: {
				          arg1.
				          arg2.
				          arg3.
				          arg4.
				          arg5.
				          arg6.
				          arg7.
				          arg8.
				          arg9.
				          arg10.
				          arg11.
				          arg12 }
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false "Mark the execution as complete to avoid double execution of the unwind handler".
	complete := true.
	^ result
]

{ #category : 'as yet unclassified' }
MpMethodProxy class >> trapMethodwith: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 with: arg7 with: arg8 with: arg9 with: arg10 with: arg11 with: arg12 with: arg13 [
	"The unwind handler should be the first temp, the complete flag should be the second temp.
	Then this method is free to use as many extra temporaries and arguments as is wants"
	<trap>
	<primitive: 198>
	| deactivator complete result process wasMeta |
	ENABLED ifFalse: [
			^ self
				  trapMethodwith: arg1
				  with: arg2
				  with: arg3
				  with: arg4
				  with: arg5
				  with: arg6
				  with: arg7
				  with: arg8
				  with: arg9
				  with: arg10
				  with: arg11
				  with: arg12
				  with: arg13 ].
	process := Processor activeProcess.
	process isMeta ifTrue: [
			^ self
				  trapMethodwith: arg1
				  with: arg2
				  with: arg3
				  with: arg4
				  with: arg5
				  with: arg6
				  with: arg7
				  with: arg8
				  with: arg9
				  with: arg10
				  with: arg11
				  with: arg12
				  with: arg13 ] "Set the deactivator literal for the slow path.
	It will be patched to an exception handler".
	deactivator := #slowdeactivator "Move to the meta level and call the before hook".
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: {
			arg1.
			arg2.
			arg3.
			arg4.
			arg5.
			arg6.
			arg7.
			arg8.
			arg9.
			arg10.
			arg11.
			arg12.
			arg13 }.
	process shiftLevelDown.
	wasMeta := false "Back in the base-level forward the original message.
	This is a message to self that will be monomorphically linked by the VM.
	The core idea is that
	 - the original method is installed in the same method dictionary using a unique symbol
	 - this call is patched to use that symbol for the send".
	result := self
		          trapMethodwith: arg1
		          with: arg2
		          with: arg3
		          with: arg4
		          with: arg5
		          with: arg6
		          with: arg7
		          with: arg8
		          with: arg9
		          with: arg10
		          with: arg11
		          with: arg12
		          with: arg13 "Move to the meta level and call the after hooks.
	Two after hooks are required.
	One indicates the method is returning either because a normal return, or a stack unwind due to exceptions or non-local returns
	The other indicates we are returning normally with a value.".
	process shiftLevelUp.
	wasMeta := true.
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: {
				          arg1.
				          arg2.
				          arg3.
				          arg4.
				          arg5.
				          arg6.
				          arg7.
				          arg8.
				          arg9.
				          arg10.
				          arg11.
				          arg12.
				          arg13 }
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false "Mark the execution as complete to avoid double execution of the unwind handler".
	complete := true.
	^ result
]

{ #category : 'as yet unclassified' }
MpMethodProxy class >> trapMethodwith: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 with: arg7 with: arg8 with: arg9 with: arg10 with: arg11 with: arg12 with: arg13 with: arg14 [
	"The unwind handler should be the first temp, the complete flag should be the second temp.
	Then this method is free to use as many extra temporaries and arguments as is wants"
	<trap>
	<primitive: 198>
	| deactivator complete result process wasMeta |
	ENABLED ifFalse: [
			^ self
				  trapMethodwith: arg1
				  with: arg2
				  with: arg3
				  with: arg4
				  with: arg5
				  with: arg6
				  with: arg7
				  with: arg8
				  with: arg9
				  with: arg10
				  with: arg11
				  with: arg12
				  with: arg13
				  with: arg14 ].
	process := Processor activeProcess.
	process isMeta ifTrue: [
			^ self
				  trapMethodwith: arg1
				  with: arg2
				  with: arg3
				  with: arg4
				  with: arg5
				  with: arg6
				  with: arg7
				  with: arg8
				  with: arg9
				  with: arg10
				  with: arg11
				  with: arg12
				  with: arg13
				  with: arg14 ] "Set the deactivator literal for the slow path.
	It will be patched to an exception handler".
	deactivator := #slowdeactivator "Move to the meta level and call the before hook".
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: {
			arg1.
			arg2.
			arg3.
			arg4.
			arg5.
			arg6.
			arg7.
			arg8.
			arg9.
			arg10.
			arg11.
			arg12.
			arg13.
			arg14 }.
	process shiftLevelDown.
	wasMeta := false "Back in the base-level forward the original message.
	This is a message to self that will be monomorphically linked by the VM.
	The core idea is that
	 - the original method is installed in the same method dictionary using a unique symbol
	 - this call is patched to use that symbol for the send".
	result := self
		          trapMethodwith: arg1
		          with: arg2
		          with: arg3
		          with: arg4
		          with: arg5
		          with: arg6
		          with: arg7
		          with: arg8
		          with: arg9
		          with: arg10
		          with: arg11
		          with: arg12
		          with: arg13
		          with: arg14 "Move to the meta level and call the after hooks.
	Two after hooks are required.
	One indicates the method is returning either because a normal return, or a stack unwind due to exceptions or non-local returns
	The other indicates we are returning normally with a value.".
	process shiftLevelUp.
	wasMeta := true.
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: {
				          arg1.
				          arg2.
				          arg3.
				          arg4.
				          arg5.
				          arg6.
				          arg7.
				          arg8.
				          arg9.
				          arg10.
				          arg11.
				          arg12.
				          arg13.
				          arg14 }
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false "Mark the execution as complete to avoid double execution of the unwind handler".
	complete := true.
	^ result
]

{ #category : 'as yet unclassified' }
MpMethodProxy class >> trapMethodwith: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 with: arg7 with: arg8 with: arg9 with: arg10 with: arg11 with: arg12 with: arg13 with: arg14 with: arg15 [
	"The unwind handler should be the first temp, the complete flag should be the second temp.
	Then this method is free to use as many extra temporaries and arguments as is wants"
	<trap>
	<primitive: 198>
	| deactivator complete result process wasMeta |
	ENABLED ifFalse: [
			^ self
				  trapMethodwith: arg1
				  with: arg2
				  with: arg3
				  with: arg4
				  with: arg5
				  with: arg6
				  with: arg7
				  with: arg8
				  with: arg9
				  with: arg10
				  with: arg11
				  with: arg12
				  with: arg13
				  with: arg14
				  with: arg15 ].
	process := Processor activeProcess.
	process isMeta ifTrue: [
			^ self
				  trapMethodwith: arg1
				  with: arg2
				  with: arg3
				  with: arg4
				  with: arg5
				  with: arg6
				  with: arg7
				  with: arg8
				  with: arg9
				  with: arg10
				  with: arg11
				  with: arg12
				  with: arg13
				  with: arg14
				  with: arg15 ] "Set the deactivator literal for the slow path.
	It will be patched to an exception handler".
	deactivator := #slowdeactivator "Move to the meta level and call the before hook".
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: {
			arg1.
			arg2.
			arg3.
			arg4.
			arg5.
			arg6.
			arg7.
			arg8.
			arg9.
			arg10.
			arg11.
			arg12.
			arg13.
			arg14.
			arg15 }.
	process shiftLevelDown.
	wasMeta := false "Back in the base-level forward the original message.
	This is a message to self that will be monomorphically linked by the VM.
	The core idea is that
	 - the original method is installed in the same method dictionary using a unique symbol
	 - this call is patched to use that symbol for the send".
	result := self
		          trapMethodwith: arg1
		          with: arg2
		          with: arg3
		          with: arg4
		          with: arg5
		          with: arg6
		          with: arg7
		          with: arg8
		          with: arg9
		          with: arg10
		          with: arg11
		          with: arg12
		          with: arg13
		          with: arg14
		          with: arg15 "Move to the meta level and call the after hooks.
	Two after hooks are required.
	One indicates the method is returning either because a normal return, or a stack unwind due to exceptions or non-local returns
	The other indicates we are returning normally with a value.".
	process shiftLevelUp.
	wasMeta := true.
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: {
				          arg1.
				          arg2.
				          arg3.
				          arg4.
				          arg5.
				          arg6.
				          arg7.
				          arg8.
				          arg9.
				          arg10.
				          arg11.
				          arg12.
				          arg13.
				          arg14.
				          arg15 }
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false "Mark the execution as complete to avoid double execution of the unwind handler".
	complete := true.
	^ result
]

{ #category : 'installation' }
MpMethodProxy >> disableInstrumentation [

	self class disableInstrumentation
]

{ #category : 'installation' }
MpMethodProxy >> enableInstrumentation [

	self class enableInstrumentation
]

{ #category : 'accessing' }
MpMethodProxy >> handler [

	^ handler
]

{ #category : 'accessing' }
MpMethodProxy >> handler: anObject [

	handler := anObject
]

{ #category : 'installation' }
MpMethodProxy >> install [

	| slowdeactivator newTrap index trapSelector |
	
	"Disable instrumentation during installation to make it safe.
	We don't want to call instrumented methods when installing the instrumentation"
	self disableInstrumentation.
	
	thisProcess runInMetaLevel: [
		(proxifiedMethod hasPragmaNamed: #noInstrumentation) ifTrue: [
			^ MpCannotInstall signalWith: self ].

		slowdeactivator := MpDeactivator withHandler: handler.

		newTrap := self prototypeTrapMethod copy.
		trapSelector := newTrap selector.
		newTrap selector: proxifiedMethod selector.
		newTrap methodClass: proxifiedMethod methodClass.

		hiddenSelector := MpHiddenSelector new
			proxifiedSelector: proxifiedMethod selector;
			yourself.

		index := newTrap literals indexOf: trapSelector.
		newTrap literalAt: index put: hiddenSelector.

		index := newTrap literals indexOf: #handler.
		newTrap literalAt: index put: handler.

		index := newTrap literals indexOf: #slowdeactivator.
		newTrap literalAt: index put: slowdeactivator.

		"It could happen that a proxy wraps a proxy. Remember the object that was installed at this moment.
		This is the object to restore during uninstall"
		wrappedMethod := proxifiedMethod methodClass
			methodDict at: proxifiedMethod selector.

		proxifiedMethod methodClass methodDict
			at: hiddenSelector
			put: proxifiedMethod.
		proxifiedMethod methodClass methodDict
			at: proxifiedMethod selector
			put: newTrap.

		trapMethod := newTrap ]
]

{ #category : 'testing' }
MpMethodProxy >> isInstalled [

	trapMethod ifNil: [ ^ false ].

	^ proxifiedMethod methodClass >> proxifiedMethod selector == trapMethod
]

{ #category : 'accessing' }
MpMethodProxy >> methodClass [

	^ proxifiedMethod methodClass
]

{ #category : 'installation' }
MpMethodProxy >> prototypeTrapMethod [

	^ self class class methods detect: [ :m |
		  m numArgs = proxifiedMethod numArgs and: [
			  m selector beginsWith: 'trap' ] ]
]

{ #category : 'accessing' }
MpMethodProxy >> proxifiedMethod [

	^ proxifiedMethod
]

{ #category : 'accessing' }
MpMethodProxy >> proxyMethod: anObject [

	proxifiedMethod := anObject
]

{ #category : 'accessing' }
MpMethodProxy >> selector [
	
	^ proxifiedMethod selector
]

{ #category : 'accessing' }
MpMethodProxy >> trapMethod [
	
	^ trapMethod
]

{ #category : 'installation' }
MpMethodProxy >> uninstall [

	"Disable instrumentation during installation to make it safe."
	self disableInstrumentation.

	self isInstalled ifFalse: [ ^ self ].

	thisProcess runInMetaLevel: [
		proxifiedMethod methodClass methodDict
			at: proxifiedMethod selector
			put: wrappedMethod.
		proxifiedMethod methodClass methodDict removeKey: hiddenSelector ]
]
