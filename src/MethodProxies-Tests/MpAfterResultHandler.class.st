Class {
	#name : #MpAfterResultHandler,
	#superclass : #MpHandler,
	#instVars : [
		'count'
	],
	#category : #'MethodProxies-Tests'
}

{ #category : #evaluating }
MpAfterResultHandler >> afterExecutionWithReceiver: anObject arguments: anArrayOfObjects returnValue: aReturnValue [

	^ 'trapped [', aReturnValue asString, ']'
]

{ #category : #accessing }
MpAfterResultHandler >> count [
	^ count
]

{ #category : #evaluating }
MpAfterResultHandler >> initialize [

	super initialize.
	count := 0
]
