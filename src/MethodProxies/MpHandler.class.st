"
I'm the root of hierarchy of objects that can perform computation in place of method such as counting execution...

The main API is composed of two methods: 
- `afterExecutionWithReceiver: anObject arguments: anArrayOfObjects returnValue: aReturnValue`
- `beforeExecutionWithReceiver: anObject arguments: anArrayOfObjects`
"
Class {
	#name : #MpHandler,
	#superclass : #Object,
	#instVars : [
		'proxy'
	],
	#category : #MethodProxies
}

{ #category : #evaluating }
MpHandler >> afterExecutionWithReceiver: anObject arguments: anArrayOfObjects returnValue: aReturnValue [

	self afterMethod.
	^ aReturnValue
]

{ #category : #evaluating }
MpHandler >> afterExecutionWithReceiver: anObject arguments: anArrayOfObjects returnValue: aReturnValue callerContext: aContext [

	^ self afterExecutionWithReceiver: anObject arguments: anArrayOfObjects returnValue: aReturnValue.
	
	
]

{ #category : #evaluating }
MpHandler >> afterMethod [
	"Perform action after execution."
]

{ #category : #evaluating }
MpHandler >> beforeExecutionWithReceiver: anObject arguments: anArrayOfObjects [

	self beforeMethod
]

{ #category : #evaluating }
MpHandler >> beforeExecutionWithReceiver: anObject arguments: anArrayOfObjects callerContext: aContext [

	self beforeExecutionWithReceiver: anObject arguments: anArrayOfObjects
]

{ #category : #evaluating }
MpHandler >> beforeMethod [
]

{ #category : #evaluating }
MpHandler >> proxy: aMethodProxy [
	proxy := aMethodProxy
]
