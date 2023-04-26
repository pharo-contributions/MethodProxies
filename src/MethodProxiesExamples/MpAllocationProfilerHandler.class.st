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
