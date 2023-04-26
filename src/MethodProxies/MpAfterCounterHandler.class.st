Class {
	#name : #MpAfterCounterHandler,
	#superclass : #MpHandler,
	#instVars : [
		'count'
	],
	#category : #'MethodProxies-Tests'
}

{ #category : #evaluating }
MpAfterCounterHandler >> afterMethod [

	count := count + 1
]

{ #category : #accessing }
MpAfterCounterHandler >> count [
	^ count
]

{ #category : #evaluating }
MpAfterCounterHandler >> initialize [

	super initialize.
	count := 0
]
