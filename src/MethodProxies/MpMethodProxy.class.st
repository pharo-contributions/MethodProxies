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

	handler := aHandler
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
		(IsActiveInExecutionStack value) == true ]) ifTrue: [
			^ self receiver: aReceiver withArgs: anArrayOfObjects executeMethod: proxifiedMethod ].
	
	"We are now in the instrumentation world.
	Do not instrument the instrumentation."
	IsActiveInExecutionStack value: true.
	
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
	IsActiveInExecutionStack value: true.
	installedMethod := methodClass compiledMethodAt: selector ifAbsent: [ 
		IsActiveInExecutionStack value: false.
		^ self ].
	installedMethod == self
		ifTrue: [ methodClass methodDict at: selector put: installedMethod wrappedMethod ].

	self unproxifiedMethod: nil.
	IsActiveInExecutionStack value: false
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
	IsActiveInExecutionStack value: false.
	result := self
		          receiver: receiver
		          withArgs: arguments
		          executeMethod: proxifiedMethod.

	"Eagerly set it to true to avoid instrumenting all messages done during the ensure"
	IsActiveInExecutionStack value: true ] methodProxyEnsure:
		(MpMethodProxyActivator
			 newWithHandler: handler
			 receiver: receiver
			 arguments: arguments).

	"Hooking into user methods to define after actions.
	After actions are not instrumented."
	^ handler
		  afterExecutionWithReceiver: receiver
		  arguments: arguments
		  returnValue: result
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
