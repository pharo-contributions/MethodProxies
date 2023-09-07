"
I'm an exception raised when a proxy cannot be installed.
This usually happens when the wrapped method is a very special method whose instrumentation could break the system.
"
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
