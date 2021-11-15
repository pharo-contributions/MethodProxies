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
		'proxy',
		'handlerModel'
	],
	#category : #MethodProxies
}

{ #category : #'instance creation' }
MpHandler class >> on: aModel [

	^ self new model: aModel
]

{ #category : #evaluating }
MpHandler >> afterExecutionWithReceiver: anObject arguments: anArrayOfObjects returnValue: aReturnValue [

	self afterMethod.
	^ aReturnValue
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
MpHandler >> beforeMethod [
]

{ #category : #accessing }
MpHandler >> handlerModel [

	^ handlerModel ifNil: [ handlerModel := MpHandlerModel new ]
]

{ #category : #accessing }
MpHandler >> model [

	^ self handlerModel model
]

{ #category : #accessing }
MpHandler >> model: anObject [

	self handlerModel model: anObject
]

{ #category : #accessing }
MpHandler >> proxy [
	^self handlerModel proxy

]

{ #category : #accessing }
MpHandler >> proxy: aMethodProxy [
	self handlerModel proxy: aMethodProxy

]
