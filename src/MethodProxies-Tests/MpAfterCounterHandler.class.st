"
I am a method proxy handler for testing that increments a counter after the method has been executed.
I therefore test method exit
"
Class {
	#name : 'MpAfterCounterHandler',
	#superclass : 'MpHandler',
	#instVars : [
		'count'
	],
	#category : 'MethodProxies-Tests',
	#package : 'MethodProxies-Tests'
}

{ #category : 'evaluating' }
MpAfterCounterHandler >> afterExecutionWithReceiver: anObject arguments: anArrayOfObjects returnValue: aReturnValue [

	count := count + 1
]

{ #category : 'accessing' }
MpAfterCounterHandler >> count [
	^ count
]

{ #category : 'evaluating' }
MpAfterCounterHandler >> initialize [

	super initialize.
	count := 0
]
