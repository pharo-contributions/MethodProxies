Class {
	#name : #MpConcurrencyHandler2,
	#superclass : #MpHandler,
	#category : #'MethodProxies-Tests'
}

{ #category : #evaluating }
MpConcurrencyHandler2 >> beforeExecutionWithReceiver: anObject arguments: anArrayOfObjects [
	anObject concurrencySemaphore signal.
	anObject concurrencySemaphore wait.
	anObject trigger2.
	anObject concurrencySemaphore signal.
]
