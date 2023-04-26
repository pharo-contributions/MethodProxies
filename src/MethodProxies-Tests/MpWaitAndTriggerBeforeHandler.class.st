Class {
	#name : #MpWaitAndTriggerBeforeHandler,
	#superclass : #MpHandler,
	#category : #'MethodProxies-Tests'
}

{ #category : #evaluating }
MpWaitAndTriggerBeforeHandler >> beforeExecutionWithReceiver: anObject arguments: anArrayOfObjects [
	"Begin execution, stop instrumentation and let first thread enter its method."
	anObject concurrencySemaphore signal.
	anObject concurrencySemaphore wait.
	
	"Trigger count, shouldn't be registered as we are in the before."
	anObject trigger2.
	anObject concurrencySemaphore signal.
]
