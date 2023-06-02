Class {
	#name : #MpInstrumentationUnwinder,
	#superclass : #InstrumentationEnsurer,
	#instVars : [
		'receiver',
		'arguments',
		'handler'
	],
	#category : #MethodProxies
}

{ #category : #'instance creation' }
MpInstrumentationUnwinder class >> newWithHandler: aHandler receiver: receiver arguments: arguments [

	^ self new
		  handler: aHandler;
		  receiver: receiver;
		  arguments: arguments;
		  yourself
]

{ #category : #accessing }
MpInstrumentationUnwinder >> arguments [

	^ arguments
]

{ #category : #accessing }
MpInstrumentationUnwinder >> arguments: anObject [

	arguments := anObject
]

{ #category : #accessing }
MpInstrumentationUnwinder >> handler [

	^ handler
]

{ #category : #accessing }
MpInstrumentationUnwinder >> handler: anObject [

	handler := anObject
]

{ #category : #accessing }
MpInstrumentationUnwinder >> receiver [

	^ receiver
]

{ #category : #accessing }
MpInstrumentationUnwinder >> receiver: anObject [

	receiver := anObject
]

{ #category : #evaluating }
MpInstrumentationUnwinder >> value [

	<methodProxyCannotWrap>
	thisProcess runInMetaLevel: [
		^ handler aboutToReturnWithReceiver: receiver arguments: arguments ]
]
