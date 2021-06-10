Class {
	#name : #MpCountingMethodProxyTest,
	#superclass : #MpMethodProxyTest,
	#category : #'MethodProxiesExamples-Tests'
}

{ #category : #tests }
MpCountingMethodProxyTest >> handlerClass [

	^ MpCountingHandler
]

{ #category : #tests }
MpCountingMethodProxyTest >> testCounts [

	| proxy instance handler |
	[ proxy := MpMethodProxy
		on: #methodOne
		inClass: MpClassA
		handler: (handler := self handlerClass new).
	proxy install.
	instance := MpClassA new.
	self assert: handler count equals: 0.
	instance methodOne.
	self assert: handler count equals: 1.
	instance methodOne.
	self assert: handler count equals: 2 ] ensure: [ proxy uninstall ]
]
