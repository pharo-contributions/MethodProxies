Class {
	#name : #MpMethodProxyActivator,
	#superclass : #Object,
	#pools : [
		'MpMethodProxyPool'
	],
	#category : #MethodProxies
}

{ #category : #accessing }
MpMethodProxyActivator >> value [

	<methodProxyCannotWrap>
	IsActiveInExecutionStack := true
]
