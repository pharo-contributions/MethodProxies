"
I'm the responsible of executing some instrumentation for a method proxy.
I implement the main hooks that are called when a method is executed or returns.
By default, I do nothing. Override my hooks to perform some action before/after.

The main API is composed of three methods: 
- `beforeExecutionWithReceiver: anObject arguments: anArrayOfObjects`: called before the wrapped method gets invoked. It receives as argument the actual receiver and arguments of the trapped message send.
- `aboutToReturnWithReceiver: anObject arguments: arguments`: called before the wrapped method exits because of a stack unwind that *passes through* this method. This happens in the case of non-local returns and exceptions.
- `afterExecutionWithReceiver: anObject arguments: anArrayOfObjects returnValue: aReturnValue`: called before the wraped method exists on a normal return with a return value. This hook allows doing something after normal execution happened, act on the return value, and change the return values of methods. The return value of the trapped call is sent as argument. The proxy will return the value returned by this method.

Moreover, for cases when this is not required, two higher-level hooks are proposed in and defined in terms of the ones above.
- `beforeMethod`: called before the method gets invoked. Just a simpler version of `beforeExecutionWithReceiver: anObject arguments: anArrayOfObjects`.
- `afterMethod`: called before the method returns, either by normal or abnormal execution. It does not allow any action on the return value.
"
Class {
	#name : 'MpHandler',
	#superclass : 'Object',
	#category : 'MethodProxies',
	#package : 'MethodProxies'
}

{ #category : 'evaluating - excepction or non local return' }
MpHandler >> aboutToReturnWithReceiver: receiver arguments: arguments [

    ^ self afterExecutionWithReceiver: receiver arguments: arguments returnValue: nil
]

{ #category : 'evaluating' }
MpHandler >> afterExecutionWithReceiver: anObject arguments: anArrayOfObjects returnValue: returnValue [
    "This is the method that you need to subclass if you want to execute the after method."

    "IMPORTANT This method needs to ALWAYS return the object that the proxied method should return."
    "This object is normally the argument `returnValue`; or something else if you want to change the returned object."

    self afterMethod.
    ^ returnValue
]

{ #category : 'evaluating' }
MpHandler >> afterExecutionWithReceiver: anObject returnValue: aValue [
	^ self afterExecutionWithReceiver: anObject arguments: {} returnValue: aValue
]

{ #category : 'evaluating' }
MpHandler >> afterExecutionWithReceiver: anObject with: arg1 returnValue: aValue [
	^ self afterExecutionWithReceiver: anObject arguments: {arg1} returnValue: aValue
]

{ #category : 'evaluating' }
MpHandler >> afterExecutionWithReceiver: anObject with: arg1 with: arg2 returnValue: aValue [
	^ self afterExecutionWithReceiver: anObject arguments: {arg1 . arg2} returnValue: aValue
]

{ #category : 'evaluating' }
MpHandler >> afterExecutionWithReceiver: anObject with: arg1 with: arg2 with: arg3 returnValue: aValue [
	^ self afterExecutionWithReceiver: anObject arguments: {arg1 . arg2 . arg3} returnValue: aValue
]

{ #category : 'evaluating' }
MpHandler >> afterExecutionWithReceiver: anObject with: arg1 with: arg2 with: arg3 with: arg4 returnValue: aValue [
	^ self afterExecutionWithReceiver: anObject arguments: {arg1 . arg2 . arg3 . arg4} returnValue: aValue
]

{ #category : 'evaluating' }
MpHandler >> afterExecutionWithReceiver: anObject with: arg1 with: arg2 with: arg3 with: arg4 with: arg5 returnValue: aValue [
	^ self afterExecutionWithReceiver: anObject arguments: {arg1 . arg2 . arg3 . arg4 . arg5} returnValue: aValue
]

{ #category : 'evaluating' }
MpHandler >> afterMethod [

    
]

{ #category : 'evaluating' }
MpHandler >> beforeExecutionWithReceiver: anObject [
	^ self beforeExecutionWithReceiver: anObject arguments: {}
]

{ #category : 'evaluating' }
MpHandler >> beforeExecutionWithReceiver: anObject arguments: anArrayOfObjects [

    self beforeMethod
]

{ #category : 'evaluating' }
MpHandler >> beforeExecutionWithReceiver: anObject with: arg1 [
	^ self beforeExecutionWithReceiver: anObject arguments: {arg1}
]

{ #category : 'evaluating' }
MpHandler >> beforeExecutionWithReceiver: anObject with: arg1 with: arg2 [
	^ self beforeExecutionWithReceiver: anObject arguments: {arg1 . arg2}
]

{ #category : 'evaluating' }
MpHandler >> beforeExecutionWithReceiver: anObject with: arg1 with: arg2 with: arg3 [
	^ self beforeExecutionWithReceiver: anObject arguments: {arg1 . arg2 . arg3}
]

{ #category : 'evaluating' }
MpHandler >> beforeExecutionWithReceiver: anObject with: arg1 with: arg2 with: arg3 with: arg4 [
	^ self beforeExecutionWithReceiver: anObject arguments: {arg1 . arg2 . arg3 . arg4}
]

{ #category : 'evaluating' }
MpHandler >> beforeExecutionWithReceiver: anObject with: arg1 with: arg2 with: arg3 with: arg4 with: arg5 [
	^ self beforeExecutionWithReceiver: anObject arguments: {arg1 . arg2 . arg3 . arg4 . arg5}
]

{ #category : 'evaluating' }
MpHandler >> beforeMethod [

    
]

{ #category : 'evaluating' }
MpHandler >> insteadExecutionWithReceiver: anObject [
	^ self insteadExecutionWithReceiver: anObject arguments: {}
]

{ #category : 'evaluating' }
MpHandler >> insteadExecutionWithReceiver: anObject arguments: arguments [
]

{ #category : 'evaluating' }
MpHandler >> insteadExecutionWithReceiver: anObject with: arg1 [
	^ self insteadExecutionWithReceiver: anObject arguments: {arg1}
]

{ #category : 'evaluating' }
MpHandler >> insteadExecutionWithReceiver: anObject with: arg1 with: arg2 [
	^ self insteadExecutionWithReceiver: anObject arguments: {arg1 . arg2}
]

{ #category : 'evaluating' }
MpHandler >> insteadExecutionWithReceiver: anObject with: arg1 with: arg2 with: arg3 [
	^ self insteadExecutionWithReceiver: anObject arguments: {arg1 . arg2 . arg3}
]

{ #category : 'evaluating' }
MpHandler >> insteadExecutionWithReceiver: anObject with: arg1 with: arg2 with: arg3 with: arg4 [
	^ self insteadExecutionWithReceiver: anObject arguments: {arg1 . arg2 . arg3 . arg4}
]

{ #category : 'evaluating' }
MpHandler >> insteadExecutionWithReceiver: anObject with: arg1 with: arg2 with: arg3 with: arg4 with: arg5 [
	^ self insteadExecutionWithReceiver: anObject arguments: {arg1 . arg2 . arg3 . arg4 . arg5}
]

{ #category : 'as yet unclassified' }
MpHandler >> overridesAfterMethodFor: anInteger [

	| argKeywords |
	
	anInteger > 5 ifTrue: [ ^ false ].
	argKeywords := '' join: ((1 to: anInteger) collect: [ :i | 'with:' ]).

	^ (self class lookupSelector:
		   (#afterExecutionWithReceiver: , argKeywords, 'returnValue:') asSymbol)
		  methodClass ~= MpHandler
]

{ #category : 'configuring' }
MpHandler >> overridesBeforeMethod [
	
	^(self class lookupSelector: #beforeExecutionWithReceiver:arguments:)
		methodClass ~= MpHandler
]

{ #category : 'as yet unclassified' }
MpHandler >> overridesBeforeMethodFor: anInteger [

	| argKeywords |
	
	anInteger > 5 ifTrue: [ ^ false ].
	argKeywords := '' join: ((1 to: anInteger) collect: [ :i | 'with:' ]).

	^ (self class lookupSelector:
		   (#beforeExecutionWithReceiver: , argKeywords) asSymbol)
		  methodClass ~= MpHandler
]

{ #category : 'as yet unclassified' }
MpHandler >> overridesInsteadMethodFor: anInteger [

	| argKeywords |
	
	anInteger > 5 ifTrue: [ ^ false ].
	argKeywords := '' join: ((1 to: anInteger) collect: [ :i | 'with:' ]).

	^ (self class lookupSelector:
		   (#insteadExecutionWithReceiver: , argKeywords) asSymbol)
		  methodClass ~= MpHandler
]
