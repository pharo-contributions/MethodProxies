Class {
	#name : 'MpWaitBeforeHandler',
	#superclass : 'MpHandler',
	#category : 'MethodProxies-Tests',
	#package : 'MethodProxies-Tests'
}

{ #category : 'evaluating' }
MpWaitBeforeHandler >> beforeExecutionWithReceiver: anObject arguments: anArrayOfObjects [
	"We are inside the before, not being instrumented, wait for second thread to enter inside before."
	anObject concurrencySemaphore wait
]
