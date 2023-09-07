Class {
	#name : #MpCountingMethodProxyTest,
	#superclass : #MpAbstractMethodProxyTest,
	#category : #'MethodProxiesExamples-Tests'
}

{ #category : #tests }
MpCountingMethodProxyTest >> handlerClass [

	^ MpCountingHandler
]

{ #category : #tests }
MpCountingMethodProxyTest >> testInstalledButNotCalledCounts0 [

	| proxy instance handler |
	proxy := MpMethodProxy
		         onMethod: MpClassA >> #methodOne
		         handler: (handler := self handlerClass new).
	self installMethodProxy: proxy.

	instance := MpClassA new.
	self assert: handler count equals: 0
]

{ #category : #tests }
MpCountingMethodProxyTest >> testInstalledCalledOnceCounts1 [

	| proxy instance handler |
	proxy := MpMethodProxy
		         onMethod: MpClassA >> #methodOne
		         handler: (handler := self handlerClass new).
	self installMethodProxy: proxy.

	instance := MpClassA new.
	instance methodOne.
	self assert: handler count equals: 1
]

{ #category : #tests }
MpCountingMethodProxyTest >> testInstalledCalledTwiceCounts2 [

	| proxy instance handler instance2 |
	proxy := MpMethodProxy
		         onMethod: MpClassA >> #methodOne
		         handler: (handler := self handlerClass new).
	self installMethodProxy: proxy.

	instance := MpClassA new.
	instance methodOne.

	instance2 := MpClassA new.
	instance2 methodOne.

	self assert: handler count equals: 2
]

{ #category : #tests }
MpCountingMethodProxyTest >> testNonInstalledCounts0 [

	| proxy handler |
	proxy := MpMethodProxy
		         onMethod: MpClassA >> #methodOne
		         handler: (handler := self handlerClass new).
	self assert: handler count equals: 0
]
