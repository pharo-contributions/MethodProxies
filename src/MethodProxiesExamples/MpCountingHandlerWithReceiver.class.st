Class {
	#name : 'MpCountingHandlerWithReceiver',
	#superclass : 'MpCountingHandler',
	#instVars : [
		'rs'
	],
	#category : 'MethodProxiesExamples',
	#package : 'MethodProxiesExamples'
}

{ #category : 'evaluating' }
MpCountingHandlerWithReceiver >> beforeExecutionWithReceiver: anObject arguments: args [

	rs add: anObject
]

{ #category : 'initialization' }
MpCountingHandlerWithReceiver >> initialize [

	super initialize.
	rs := OrderedCollection new
]
