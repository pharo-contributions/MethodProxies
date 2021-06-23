Class {
	#name : #MpMethodProxyDeactivator,
	#superclass : #Object,
	#pools : [
		'MpMethodProxyPool'
	],
	#category : #MethodProxies
}

{ #category : #accessing }
MpMethodProxyDeactivator >> value [

	<methodProxyCannotWrap>
	IsActiveInExecutionStack := false
]
