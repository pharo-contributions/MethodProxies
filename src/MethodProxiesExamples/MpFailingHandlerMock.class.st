"
I'm an example handler for testing purposes that fails on before.
I'm used to check that the infrastructure does not collapse when a handler fails
"
Class {
	#name : #MpFailingHandlerMock,
	#superclass : #MpHandler,
	#category : #MethodProxiesExamples
}

{ #category : #evaluating }
MpFailingHandlerMock >> beforeMethod [

	self error: 'error during instrumentation'
]
