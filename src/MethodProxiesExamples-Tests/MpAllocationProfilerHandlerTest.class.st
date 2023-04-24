Class {
	#name : #MpAllocationProfilerHandlerTest,
	#superclass : #MpMethodProxyTest,
	#category : #'MethodProxiesExamples-Tests'
}

{ #category : #tests }
MpAllocationProfilerHandlerTest >> handlerClass [

	^ MpAllocationProfilerHandler 
]

{ #category : #tests }
MpAllocationProfilerHandlerTest >> testMethodGetsTheCorrectContext [

	| mp handler |
	
	handler := MpAllocationProfilerHandler new
					contextTransformationBlock: [ :aCtx | aCtx sender method printString ].
	
	mp := MpMethodProxy 
				onMethod: (Behavior >> #basicNew) 
				handler: handler.
	
	self installMethodProxy: mp.
	
	Delay forMilliseconds: 1.
	
	self assert: (handler allocations at: Delay) first second equals: 'Delay class>>#forMilliseconds:'.	

]
