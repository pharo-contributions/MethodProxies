Class {
	#name : 'MpHandlerTest',
	#superclass : 'TestCase',
	#category : 'MethodProxies-Tests',
	#package : 'MethodProxies-Tests'
}

{ #category : 'tests' }
MpHandlerTest >> testCanHandleMethodWithArity [
	
	self assert: (MpHandler new canHandle: 5).
	self deny: (MpHandler new canHandle: 6)
]
