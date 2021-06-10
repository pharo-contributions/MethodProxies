Class {
	#name : #MpMockMethodProxyHandler,
	#superclass : #MpHandler,
	#category : #'MethodProxies-Tests'
}

{ #category : #evaluating }
MpMockMethodProxyHandler >> afterExecutionWithReceiver: receiver arguments: arguments returnValue: returnValue [

	^ 'trapped [', returnValue asString, ']'
]
