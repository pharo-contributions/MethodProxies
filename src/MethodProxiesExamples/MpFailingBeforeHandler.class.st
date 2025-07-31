"
I'm an example handler for testing purposes that fails on before.
I'm used to check that the infrastructure does not collapse when a handler fails
"
Class {
	#name : 'MpFailingBeforeHandler',
	#superclass : 'MpHandler',
	#category : 'MethodProxiesExamples',
	#package : 'MethodProxiesExamples'
}

{ #category : 'evaluating' }
MpFailingBeforeHandler >> beforeExecutionWithReceiver: anObject arguments: anArrayOfObjects [

	self error: 'error during instrumentation'
]
