Class {
	#name : 'MpArgumentsArrayHandler',
	#superclass : 'MpHandler',
	#instVars : [
		'argsArray'
	],
	#category : 'MethodProxies-Tests',
	#package : 'MethodProxies-Tests'
}

{ #category : 'evaluating' }
MpArgumentsArrayHandler >> argsArray [

	^ argsArray
]

{ #category : 'evaluating' }
MpArgumentsArrayHandler >> beforeExecutionWithReceiver: anObject arguments: anArrayOfObjects [

	argsArray := anArrayOfObjects
]
