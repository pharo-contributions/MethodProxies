"
I'm a mock for tests that checks that the infrastructure does not collapse when a handler is failing.
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
