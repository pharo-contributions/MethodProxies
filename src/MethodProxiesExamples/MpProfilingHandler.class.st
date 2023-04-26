Class {
	#name : #MpProfilingHandler,
	#superclass : #MpHandler,
	#instVars : [
		'count',
		'wrappedMethod'
	],
	#category : #MethodProxiesExamples
}

{ #category : #evaluating }
MpProfilingHandler >> beforeMethod [

	self count: self count + 1.

	count > 1 ifTrue: [ ^ self ].
	wrappedMethod literalsEvenTheOnesInTheInnerBlocks
		select: [ :literal | literal isSymbol ]
		thenDo: [ :potentialSelector | self instrumentImplementorsOf: potentialSelector ]
]

{ #category : #accessing }
MpProfilingHandler >> count [

	^ count
]

{ #category : #accessing }
MpProfilingHandler >> count: anInteger [

	count := anInteger
]

{ #category : #initialization }
MpProfilingHandler >> initialize [

	super initialize.
	count := 0.
]

{ #category : #evaluating }
MpProfilingHandler >> instrumentImplementorsOf: potentialSelector [

	| newProxy |
	potentialSelector implementors do: [ :method |
		newProxy := MpMethodProxy
			onMethod: method
			handler: (MpProfilingHandler new
				wrappedMethod: method;
				yourself).
		(newProxy notNil and: [ (newProxy shouldWrap: method) ])
			ifTrue: [ newProxy install ].
	]
]

{ #category : #accessing }
MpProfilingHandler >> wrappedMethod [
	^ wrappedMethod
]

{ #category : #evaluating }
MpProfilingHandler >> wrappedMethod: aMethod [
	wrappedMethod := aMethod
]
