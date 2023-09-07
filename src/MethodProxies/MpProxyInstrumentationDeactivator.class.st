Class {
	#name : #MpProxyInstrumentationDeactivator,
	#superclass : #InstrumentationEnsurer,
	#instVars : [
		'handler'
	],
	#category : #MethodProxies
}

{ #category : #accessing }
MpProxyInstrumentationDeactivator >> handler [

	^ handler
]

{ #category : #accessing }
MpProxyInstrumentationDeactivator >> handler: anObject [

	handler := anObject
]

{ #category : #evaluating }
MpProxyInstrumentationDeactivator >> value [

	<noInstrumentation>
	"Slow path, an exception or a non local return happened"
	| wasMeta me |
	thisProcess shiftLevelUp.

	me := thisContext findContextSuchThat: [ :ctx | ctx isUnwindContext ].
	wasMeta := me tempNamed: 'wasMeta'.
	handler aboutToReturnWithReceiver: me receiver arguments: me arguments.
	thisProcess shiftLevelDown.
	wasMeta ifTrue: [ thisProcess shiftLevelDown ].
	
]
