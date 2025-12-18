Class {
	#name : 'MpTestHandlerWithInstead',
	#superclass : 'MpHandler',
	#instVars : [
		'insteadCalls',
		'afterCalls',
		'beforeCalls',
		'insteadBlock'
	],
	#category : 'MethodProxies-Tests',
	#package : 'MethodProxies-Tests'
}

{ #category : 'accessing' }
MpTestHandlerWithInstead >> afterCalls [

	^ afterCalls
]

{ #category : 'accessing' }
MpTestHandlerWithInstead >> afterCalls: anObject [

	afterCalls := anObject
]

{ #category : 'evaluating' }
MpTestHandlerWithInstead >> afterExecutionWithReceiver: receiver returnValue: val [

	afterCalls := afterCalls + 1.
	^ val
]

{ #category : 'accessing' }
MpTestHandlerWithInstead >> beforeCalls [

	^ beforeCalls
]

{ #category : 'accessing' }
MpTestHandlerWithInstead >> beforeCalls: anObject [

	beforeCalls := anObject
]

{ #category : 'evaluating' }
MpTestHandlerWithInstead >> beforeExecutionWithReceiver: receiver [

	beforeCalls := beforeCalls + 1
]

{ #category : 'initialization' }
MpTestHandlerWithInstead >> initialize [

	super initialize.
	beforeCalls := afterCalls := insteadCalls := 0
]

{ #category : 'accessing' }
MpTestHandlerWithInstead >> insteadBlock [

	^ insteadBlock
]

{ #category : 'accessing' }
MpTestHandlerWithInstead >> insteadBlock: anObject [

	insteadBlock := anObject
]

{ #category : 'accessing' }
MpTestHandlerWithInstead >> insteadCalls [

	^ insteadCalls
]

{ #category : 'accessing' }
MpTestHandlerWithInstead >> insteadCalls: anObject [

	insteadCalls := anObject
]

{ #category : 'evaluating' }
MpTestHandlerWithInstead >> insteadExecutionWithReceiver: receiver [

	insteadCalls := insteadCalls + 1.
	
	^ insteadBlock ifNotNil: [ insteadBlock value: receiver ]
]
