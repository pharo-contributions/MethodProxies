Class {
	#name : #MpFailingHandlerMock,
	#superclass : #MpHandler,
	#category : #MethodProxiesExamples
}

{ #category : #evaluating }
MpFailingHandlerMock >> beforeMethod [

	self error: 'error during instrumentation'
]
