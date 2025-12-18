"
I'm an example handler that counts all the times a method has been invoked
"
Class {
	#name : 'MpEmptyHandlerAfter',
	#superclass : 'MpHandler',
	#instVars : [
		'count'
	],
	#category : 'MethodProxiesExamples',
	#package : 'MethodProxiesExamples'
}

{ #category : 'evaluating' }
MpEmptyHandlerAfter >> afterExecutionWithReceiver: anObject arguments: anArrayOfObjects returnValue: retVal [

	^ retVal
]

{ #category : 'evaluating' }
MpEmptyHandlerAfter >> afterExecutionWithReceiver: anObject returnValue: retVal [

	^ retVal
]

{ #category : 'evaluating' }
MpEmptyHandlerAfter >> afterExecutionWithReceiver: anObject with: arg returnValue: retVal [

	^ retVal
]

{ #category : 'evaluating' }
MpEmptyHandlerAfter >> beforeExecutionWithReceiver: anObject [
]

{ #category : 'evaluating' }
MpEmptyHandlerAfter >> beforeExecutionWithReceiver: anObject with: arg [
]
