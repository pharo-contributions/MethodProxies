"
I'm an example handler that counts all the times a method has been invoked
"
Class {
	#name : #MpCountingHandler,
	#superclass : #MpHandler,
	#instVars : [
		'count'
	],
	#category : #MethodProxiesExamples
}

{ #category : #evaluating }
MpCountingHandler >> beforeMethod [

	self count: self count + 1
]

{ #category : #accessing }
MpCountingHandler >> count [

	^ count
]

{ #category : #accessing }
MpCountingHandler >> count: anInteger [

	count := anInteger
]

{ #category : #initialization }
MpCountingHandler >> initialize [

	super initialize.
	self count: 0.

]
