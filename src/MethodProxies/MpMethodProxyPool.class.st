Class {
	#name : #MpMethodProxyPool,
	#superclass : #SharedPool,
	#classVars : [
		'IsActiveInExecutionStack'
	],
	#category : #MethodProxies
}

{ #category : #activation }
MpMethodProxyPool class >> isProtected [

	^ IsActiveInExecutionStack == true
]

{ #category : #activation }
MpMethodProxyPool class >> protect [
	<methodProxyCannotWrap>
	IsActiveInExecutionStack := true
]

{ #category : #activation }
MpMethodProxyPool class >> unprotect [

	IsActiveInExecutionStack := false
]
