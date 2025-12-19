"
I'm an example handler that counts all the times a method has been invoked
"
Class {
	#name : 'MpCountingHandler',
	#superclass : 'MpHandler',
	#instVars : [
		'count'
	],
	#category : 'MethodProxiesExamples',
	#package : 'MethodProxiesExamples'
}

{ #category : 'evaluating' }
MpCountingHandler >> beforeExecutionWithReceiver: anObject [

	self count: self count + 1
]

{ #category : 'evaluating' }
MpCountingHandler >> beforeExecutionWithReceiver: anObject arguments: anArrayOfObjects [

	self count: self count + 1
]

{ #category : 'evaluating' }
MpCountingHandler >> beforeExecutionWithReceiver: anObject with: argument [

	self count: self count + 1
]

{ #category : 'accessing' }
MpCountingHandler >> count [

	^ count
]

{ #category : 'accessing' }
MpCountingHandler >> count: anInteger [

	count := anInteger
]

{ #category : 'initialization' }
MpCountingHandler >> initialize [

	super initialize.
	self count: 0.

]
