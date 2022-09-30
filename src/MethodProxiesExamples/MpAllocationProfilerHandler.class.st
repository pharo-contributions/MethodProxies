"
I'm a simple little profiler that can store all the objects returned by the spyied method.

```
h := MpAllocationProfilerHandler new.
p1 := MpMethodProxy 
	onMethod: Behavior >> #basicNew 
	handler: h.
p1 install.
p2 := MpMethodProxy 
	onMethod: Behavior >> #basicNew: 
	handler: h.
p2 install.
p3 := MpMethodProxy 
	onMethod: Array class >> #new: 
	handler: h.
p3 install.
```
"
Class {
	#name : #MpAllocationProfilerHandler,
	#superclass : #MpHandler,
	#instVars : [
		'allocations',
		'transformationBlock'
	],
	#category : #MethodProxiesExamples
}

{ #category : #initialization }
MpAllocationProfilerHandler >> afterExecutionWithReceiver: receiver arguments: arguments returnValue: returnValue [ 

	| allocationsPerClass transformedContext |
	transformedContext := self transformContext: self captureCallingContext. 
	allocationsPerClass := allocations at: receiver ifAbsentPut: [ OrderedCollection new ].
	allocationsPerClass add: {returnValue. transformedContext}.
	^ returnValue
]

{ #category : #initialization }
MpAllocationProfilerHandler >> afterExecutionWithReceiver: receiver arguments: arguments returnValue: returnValue callerContext: callerContext [

	| allocationsPerClass transformedContext |
	transformedContext := self transformContext: callerContext. 
	allocationsPerClass := allocations at: receiver ifAbsentPut: [ OrderedCollection new ].
	allocationsPerClass add: {returnValue. transformedContext}.
	^ returnValue
]

{ #category : #accessing }
MpAllocationProfilerHandler >> allocations [
	^ allocations
]

{ #category : #accessing }
MpAllocationProfilerHandler >> contextTransformationBlock: aBlock [

	transformationBlock := aBlock
]

{ #category : #initialization }
MpAllocationProfilerHandler >> initialize [

	super initialize.
	allocations := Dictionary new.
]

{ #category : #'as yet unclassified' }
MpAllocationProfilerHandler >> transformContext: aContext [

	^ transformationBlock 
		ifNil: [ aContext ]
		ifNotNil: [ transformationBlock value: aContext ]
]
