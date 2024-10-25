Class {
	#name : 'MpArgumentListTestHandler',
	#superclass : 'MpHandler',
	#instVars : [
		'beforeArgs',
		'afterArgs'
	],
	#category : 'MethodProxies-Tests',
	#package : 'MethodProxies-Tests'
}

{ #category : 'accessing' }
MpArgumentListTestHandler >> afterArgs [

	^ afterArgs
]

{ #category : 'evaluating' }
MpArgumentListTestHandler >> afterExecutionWithReceiver: anObject arguments: anArrayOfObjects returnValue: aReturnValue [

	afterArgs := anArrayOfObjects.
	^ aReturnValue
]

{ #category : 'accessing' }
MpArgumentListTestHandler >> beforeArgs [

	^ beforeArgs
]

{ #category : 'evaluating' }
MpArgumentListTestHandler >> beforeExecutionWithReceiver: anObject arguments: anArrayOfObjects [

	beforeArgs := anArrayOfObjects
]
