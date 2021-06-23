Class {
	#name : #MpCannotInstall,
	#superclass : #Error,
	#instVars : [
		'methodProxy'
	],
	#category : #MethodProxies
}

{ #category : #signalling }
MpCannotInstall class >> signalWith: aMethodProxy [

	self new
		methodProxy: aMethodProxy;
		signal
]

{ #category : #accessing }
MpCannotInstall >> methodProxy [

	^ methodProxy
]

{ #category : #accessing }
MpCannotInstall >> methodProxy: anObject [

	methodProxy := anObject
]
