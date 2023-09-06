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
