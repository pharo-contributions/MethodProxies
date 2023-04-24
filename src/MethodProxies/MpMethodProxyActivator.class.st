Class {
	#name : #MpMethodProxyActivator,
	#superclass : #MpMethodProxyEnsurer,
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
