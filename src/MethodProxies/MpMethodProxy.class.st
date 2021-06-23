"
I'm a modern implementation of Python's method decorators or MethodWrappers for Pharo based on `valueWithReceiver:arguments:` VM hook.

Method proxies are objects that wrap methods stored in the method dictionary of the class. 
Some support before and after action the execution of the original method. 
Method proxies control their installation and propagation. 
In particular, they can be applied to any Pharo method. The implementation ensures that the method proxy installation cannot touch any part of the system that could be used to installation.

Method proxies delegate to method handler. This delegation ensures that end user cannot blow up their environment by overridding undesired methods.


## Usage
Here is a typical usage. Check the tests to know more. 

```
testCounts

	| proxy instance handler |
	[ proxy := MpMethodProxy
		on: #methodOne
		inClass: MpClassA
		handler: (handler := MwCountingHandler new).
	proxy install.
	instance := MpClassA new.
	self assert: handler count equals: 0.
	instance methodOne.
	self assert: handler count equals: 1.
	instance methodOne.
	self assert: handler count equals: 2 ] ensure: [ proxy uninstall ]
```


This package is developed and maintained by S. Ducasse, G. Polito and P. Tesone, but feel free to give a hand. 


"
Class {
	#name : #MpMethodProxy,
	#superclass : #Object,
	#instVars : [
		'selector',
		'methodClass',
		'isDisabled',
		'handler',
		'proxifiedMethod'
	],
	#pools : [
		'MpMethodProxyPool'
	],
	#category : #MethodProxies
}

{ #category : #'instance creation' }
MpMethodProxy class >> on: selector inClass: aClass handler: aHandler [

	| proxy |
	proxy := self new.
	proxy class: aClass selector: selector.
	proxy handler: aHandler.
	^ proxy
]

{ #category : #'instance creation' }
MpMethodProxy class >> onMethod: aMethod handler: aHandler [

	^ self on: aMethod selector inClass: aMethod methodClass handler: aHandler
]

{ #category : #private }
MpMethodProxy class >> uninstallAllWrappers [
	"self uninstallAllWrappers"

	self allSubInstancesDo: [ :inst | inst uninstall ]
]

{ #category : #initialization }
MpMethodProxy >> class: aClass selector: aSymbol [

	self
		methodClass: aClass;
		selector: aSymbol
]

{ #category : #accessing }
MpMethodProxy >> disable [

	isDisabled := true
]

{ #category : #accessing }
MpMethodProxy >> doesNotUnderstand: aMessage [
	^ proxifiedMethod 
			ifNotNil: [ proxifiedMethod 
								perform: aMessage selector 
								withArguments: aMessage arguments ]
			ifNil: [ super doesNotUnderstand: aMessage ]
			
]

{ #category : #accessing }
MpMethodProxy >> fetchMethod [
	
	"Fetches the method to be instrumented"
	^ methodClass >> selector
]

{ #category : #installation }
MpMethodProxy >> handler [

	^ handler
]

{ #category : #accessing }
MpMethodProxy >> handler: aHandler [ 
	handler := aHandler.
	aHandler proxy: self
]

{ #category : #installation }
MpMethodProxy >> initialize [

	super initialize.
	isDisabled := true
]

{ #category : #installation }
MpMethodProxy >> install [
	"We have a method proxy with a method = class * selector of the method it will proxy."
	
	|  method |
	method := methodClass compiledMethodAt: selector ifAbsent: [ 
		MpCannotInstall signalWith: self ].
	
	(self shouldWrap: method) ifFalse: [ 
		MpCannotInstall signalWith: self ].
	
	self unproxifiedMethod: method.
	methodClass methodDict at: selector put: self.
	
	"Activate it now"
	isDisabled := false.
	^ self
]

{ #category : #accessing }
MpMethodProxy >> isEnabled [

	^ isDisabled not
]

{ #category : #accessing }
MpMethodProxy >> isEnabled: anObject [

	isDisabled := anObject not
]

{ #category : #testing }
MpMethodProxy >> isInstalled [
	"Return whether the receiver is effectively installed in a method dictionary.
	Note that in the case of nesting of method proxies the inner ones are not considered as installed."
	
	methodClass ifNotNil: [
		selector ifNotNil: [ 
			^ self == (methodClass methodDict at: selector ifAbsent: [])]].
	^ false
]

{ #category : #testing }
MpMethodProxy >> isMethodProxy [

	^ true
]

{ #category : #accessing }
MpMethodProxy >> methodClass [
	^ methodClass
]

{ #category : #accessing }
MpMethodProxy >> methodClass: aClass [

	methodClass := aClass
]

{ #category : #evaluating }
MpMethodProxy >> name [

	^ self printString
]

{ #category : #printing }
MpMethodProxy >> printOn: aStream [

	aStream
		nextPutAll: self class name;
		nextPutAll: '[';
		nextPutAll: methodClass name;
		nextPutAll: '>>#';
		nextPutAll: selector;
		nextPutAll: ']'
]

{ #category : #evaluating }
MpMethodProxy >> receiver: aReceiver withArgs: argArray executeMethod: compiledMethod [
	"Execute compiledMethod against the receiver and args in argArray"

	<primitive: 188>
	<methodProxyCannotWrap>
	self primitiveFailed
]

{ #category : #evaluating }
MpMethodProxy >> run: aSelector with: anArrayOfObjects in: aReceiver [

	"Do not intercept"
	<methodProxyCannotWrap>
	
	| returnValue |
	(isDisabled or: [
		"Check explicitly that the flag has been set.
		This allows proxies to work independently of initialization side effects."
		IsActiveInExecutionStack == true ]) ifTrue: [
			^ self receiver: aReceiver withArgs: anArrayOfObjects executeMethod: proxifiedMethod ].
	
	"We are now in the instrumentation world.
	Do not instrument the instrumentation."
	IsActiveInExecutionStack := true.
	
	"Purposely do not use a non-local return.
	Otherwise the non-local return logic would be instrumented once the ensure block is executed.
	However, since a lot of code executes between the ensure block and the real method return, this could end in infinite loops"
	[returnValue := self valueWithReceiver: aReceiver arguments: anArrayOfObjects ]
		ensure: MpMethodProxyDeactivator new.
	^ returnValue
]

{ #category : #accessing }
MpMethodProxy >> selector [

	^ selector
]

{ #category : #accessing }
MpMethodProxy >> selector: aSymbol [

	selector := aSymbol
]

{ #category : #installation }
MpMethodProxy >> shouldWrap: aMethod [
	
	(aMethod isCompiledMethod not and: [
		aMethod handler class ~~ self handler class ])
			ifTrue: [ ^ true ].
	
	aMethod isCompiledMethod ifFalse: [ ^ false ].
	
	^ aMethod pragmas noneSatisfy: [ :pragma | pragma selector = #methodProxyCannotWrap ]
]

{ #category : #installation }
MpMethodProxy >> uninstall [
	
	| installedMethod |
	IsActiveInExecutionStack := true.
	installedMethod := methodClass compiledMethodAt: selector ifAbsent: [ 
		IsActiveInExecutionStack := false.
		^ self ].
	installedMethod == self
		ifTrue: [ methodClass methodDict at: selector put: installedMethod wrappedMethod ].

	self unproxifiedMethod: nil.
	IsActiveInExecutionStack := false
]

{ #category : #accessing }
MpMethodProxy >> unproxifiedMethod [
	"The unproxifedMethod returns the proxified method even in case we have multiple proxified nesting."
	
	^ proxifiedMethod ifNotNil: [ proxifiedMethod unproxifiedMethod ]
]

{ #category : #'when installed' }
MpMethodProxy >> unproxifiedMethod: aCompiledMethod [

	proxifiedMethod := aCompiledMethod
]

{ #category : #evaluating }
MpMethodProxy >> valueWithReceiver: receiver arguments: arguments [

	<methodProxyCannotWrap>
	| result |
	
	"Hooking into user methods to define before actions.
	Before actions are not instrumented."
	handler beforeExecutionWithReceiver: receiver arguments: arguments.
	
	"Purposely do not use a non-local return.
	Otherwise the non-local return logic would be instrumented and this could end in infinite loops"
	[
		IsActiveInExecutionStack := false.
		result := self receiver: receiver withArgs: arguments executeMethod: proxifiedMethod.
		
		"Eagerly set it to true to avoid instrumenting all messages done during the ensure"
		IsActiveInExecutionStack := true.
	] methodProxyEnsure: MpMethodProxyActivator new.

	"Hooking into user methods to define after actions.
	After actions are not instrumented."
	^ handler afterExecutionWithReceiver: receiver arguments: arguments returnValue: result
]

{ #category : #accessing }
MpMethodProxy >> wrappedClass [

	^ methodClass
]

{ #category : #accessing }
MpMethodProxy >> wrappedClass: aClass [

	methodClass := aClass
]

{ #category : #'when installed' }
MpMethodProxy >> wrappedMethod [

	^ proxifiedMethod
]
