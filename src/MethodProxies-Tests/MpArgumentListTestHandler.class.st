Class {
	#name : 'MpArgumentListTestHandler',
	#superclass : 'MpHandler',
	#instVars : [
		'beforeArgs',
		'afterArgs',
		'unwound'
	],
	#category : 'MethodProxies-Tests',
	#package : 'MethodProxies-Tests'
}

{ #category : 'evaluating' }
MpArgumentListTestHandler >> aboutToReturnWithReceiver: receiver arguments: arguments [

	unwound := true
]

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

{ #category : 'accessing' }
MpArgumentListTestHandler >> unwound [

	^ unwound
]

{ #category : 'accessing' }
MpArgumentListTestHandler >> unwound: anObject [

	unwound := anObject
]
