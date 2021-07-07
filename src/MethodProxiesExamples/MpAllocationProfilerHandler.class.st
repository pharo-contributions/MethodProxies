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
		'allocations'
	],
	#category : #MethodProxiesExamples
}

{ #category : #initialization }
MpAllocationProfilerHandler >> afterExecutionWithReceiver: receiver arguments: arguments returnValue: returnValue callerContext: callerContext [

	| allocationsPerClass |
	
	allocationsPerClass := allocations at: receiver ifAbsentPut: [ OrderedCollection new ].
	allocationsPerClass add: {returnValue. callerContext method}.
	^ returnValue
]

{ #category : #initialization }
MpAllocationProfilerHandler >> initialize [

	super initialize.
	allocations := Dictionary new.
]
