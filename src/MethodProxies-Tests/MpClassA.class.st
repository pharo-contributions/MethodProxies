"
Instance Variables:

	x	<Integer>
"
Class {
	#name : #MpClassA,
	#superclass : #Object,
	#instVars : [
		'x'
	],
	#category : #'MethodProxies-Tests'
}

{ #category : #debugging }
MpClassA >> methodDelay [

	(Delay forMilliseconds: 1) wait.
]

{ #category : #debugging }
MpClassA >> methodLastingOneSecond [

	(Delay forMilliseconds: 0.5) wait.
	^ 999
]

{ #category : #debugging }
MpClassA >> methodOne [
	^ 101
	
]

{ #category : #debugging }
MpClassA >> methodTwo [
	^ 42
]

{ #category : #debugging }
MpClassA >> methodWithArgument: anInteger [

	self x: self x + anInteger.
	^ self x
]

{ #category : #debugging }
MpClassA >> methodWithException [

	1/0
]

{ #category : #debugging }
MpClassA >> methodWithWarning [

	Warning new signal: 'I warned you'.
]

{ #category : #accessing }
MpClassA >> x [

	^ x
]

{ #category : #accessing }
MpClassA >> x: anInteger [

	x := anInteger
]
