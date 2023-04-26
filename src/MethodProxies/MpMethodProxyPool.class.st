Class {
	#name : #MpMethodProxyPool,
	#superclass : #SharedPool,
	#classVars : [
		'IsActiveInExecutionStack'
	],
	#category : #MethodProxies
}

{ #category : #'class initialization' }
MpMethodProxyPool class >> initialize [ 
	IsActiveInExecutionStack := MpInstrumentationLock new
]

{ #category : #activation }
MpMethodProxyPool class >> isProtected [

	^ IsActiveInExecutionStack value == true
]

{ #category : #activation }
MpMethodProxyPool class >> protect [
	<methodProxyCannotWrap>
	IsActiveInExecutionStack value: true
]

{ #category : #activation }
MpMethodProxyPool class >> unprotect [

	IsActiveInExecutionStack value: false
]
