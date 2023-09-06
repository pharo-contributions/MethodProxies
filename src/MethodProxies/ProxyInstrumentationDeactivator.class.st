Class {
	#name : #ProxyInstrumentationDeactivator,
	#superclass : #InstrumentationEnsurer,
	#instVars : [
		'handler'
	],
	#category : #MethodProxies
}

{ #category : #accessing }
ProxyInstrumentationDeactivator >> handler [

	^ handler
]

{ #category : #accessing }
ProxyInstrumentationDeactivator >> handler: anObject [

	handler := anObject
]

{ #category : #evaluating }
ProxyInstrumentationDeactivator >> value [

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
