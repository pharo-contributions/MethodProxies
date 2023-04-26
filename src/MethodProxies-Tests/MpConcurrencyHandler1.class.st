Class {
	#name : #MpConcurrencyHandler1,
	#superclass : #MpHandler,
	#category : #'MethodProxies-Tests'
}

{ #category : #evaluating }
MpConcurrencyHandler1 >> beforeExecutionWithReceiver: anObject arguments: anArrayOfObjects [
	anObject concurrencySemaphore wait
]
