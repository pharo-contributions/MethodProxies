Class {
	#name : #MpMethodProxyActivator,
	#superclass : #MpMethodProxyEnsurer,
	#instVars : [
		'receiver',
		'arguments',
		'handler'
	],
	#pools : [
		'MpMethodProxyPool'
	],
	#category : #MethodProxies
}

{ #category : #'instance creation' }
MpMethodProxyActivator class >> newWithHandler: aHandler receiver: receiver arguments: arguments [

	^ self new
		  handler: aHandler;
		  receiver: receiver;
		  arguments: arguments;
		  yourself
]

{ #category : #accessing }
MpMethodProxyActivator >> arguments [

	^ arguments
]

{ #category : #accessing }
MpMethodProxyActivator >> arguments: anObject [

	arguments := anObject
]

{ #category : #accessing }
MpMethodProxyActivator >> handler [

	^ handler
]

{ #category : #accessing }
MpMethodProxyActivator >> handler: anObject [

	handler := anObject
]

{ #category : #accessing }
MpMethodProxyActivator >> receiver [

	^ receiver
]

{ #category : #accessing }
MpMethodProxyActivator >> receiver: anObject [

	receiver := anObject
]

{ #category : #evaluating }
MpMethodProxyActivator >> value [

	<methodProxyCannotWrap>
	IsActiveInExecutionStack value: true.
	^ handler
		  aboutToReturnWithReceiver: receiver
		  arguments: arguments
]
