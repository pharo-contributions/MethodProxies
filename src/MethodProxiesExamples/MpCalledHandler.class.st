"
I'm a little example that reports if the spyied method has been executed. 


"
Class {
	#name : #MpCalledHandler,
	#superclass : #MpHandler,
	#instVars : [
		'called'
	],
	#category : #MethodProxiesExamples
}

{ #category : #evaluating }
MpCalledHandler >> beforeMethod [

	called := true
]

{ #category : #accessing }
MpCalledHandler >> called [

	^ called
]

{ #category : #accessing }
MpCalledHandler >> called: aBoolean [

	called := aBoolean
]

{ #category : #initialization }
MpCalledHandler >> initialize [

	super initialize.
	self called: false
]
