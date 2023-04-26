Class {
	#name : #MpTestConcurrentSharedObject,
	#superclass : #Object,
	#instVars : [
		'concurrencySemaphore'
	],
	#category : #'MethodProxies-Tests'
}

{ #category : #accessing }
MpTestConcurrentSharedObject >> concurrencySemaphore [

	^ concurrencySemaphore
]

{ #category : #accessing }
MpTestConcurrentSharedObject >> concurrencySemaphore: anObject [

	concurrencySemaphore := anObject
]

{ #category : #initialization }
MpTestConcurrentSharedObject >> initialize [ 
	self concurrencySemaphore: (Semaphore new).
]

{ #category : #debugging }
MpTestConcurrentSharedObject >> methodProcess1 [
	"We are in instrumented territory this trigger should be registered."
	self trigger1.
	"Let the second thread end its before execution and wait for its signal."
	concurrencySemaphore signal.
	concurrencySemaphore wait.
]

{ #category : #debugging }
MpTestConcurrentSharedObject >> methodProcess2 [
	"Do nothing"
]

{ #category : #debugging }
MpTestConcurrentSharedObject >> trigger1 [
	"Proxified method being counted"
]

{ #category : #debugging }
MpTestConcurrentSharedObject >> trigger2 [
	"Proxified method being counted"
]
