Class {
	#name : #MpConcurrencyClass,
	#superclass : #Object,
	#instVars : [
		'concurrencySemaphore'
	],
	#category : #'MethodProxies-Tests'
}

{ #category : #accessing }
MpConcurrencyClass >> concurrencySemaphore [

	^ concurrencySemaphore
]

{ #category : #accessing }
MpConcurrencyClass >> concurrencySemaphore: anObject [

	concurrencySemaphore := anObject
]

{ #category : #debugging }
MpConcurrencyClass >> methodProcess1 [
	self trigger1.
	concurrencySemaphore signal.
	concurrencySemaphore wait.
]

{ #category : #debugging }
MpConcurrencyClass >> methodProcess2 [
]

{ #category : #debugging }
MpConcurrencyClass >> trigger1 [
]

{ #category : #debugging }
MpConcurrencyClass >> trigger2 [
]
