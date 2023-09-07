"
I'm an example handler for profiling purposes that stores all the objects returned by the spyied method

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

{ #category : #accessing }
MpAllocationProfilerHandler >> allocations [
	^ allocations
]

{ #category : #evaluating }
MpAllocationProfilerHandler >> captureCallingContext [

	| runWithInContext |
	"Find the context of #run:with:in:"
	runWithInContext := thisContext sender.
	[
	runWithInContext isNil or: [ runWithInContext method primitive = 198 ] ]
		whileFalse: [ runWithInContext := runWithInContext sender ].

	"Find the real sender"
	^ runWithInContext ifNotNil: [ runWithInContext sender ]
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
