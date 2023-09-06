Class {
	#name : #MpMethodProxy,
	#superclass : #Object,
	#instVars : [
		'proxyMethod',
		'handler',
		'hiddenSelector',
		'trapMethod',
		'wrappedMethod'
	],
	#category : #MethodProxies
}

{ #category : #'instance creation' }
MpMethodProxy class >> onMethod: aMethod handler: aHandler [

	^ self new
		  proxyMethod: aMethod;
		  handler: aHandler;
		  yourself
]

{ #category : #accessing }
MpMethodProxy >> handler [

	^ handler
]

{ #category : #accessing }
MpMethodProxy >> handler: anObject [

	handler := anObject
]

{ #category : #installation }
MpMethodProxy >> install [

	| deactivator newTrap index trapSelector |
	thisProcess runInMetaLevel: [
		(proxyMethod hasPragmaNamed: #noInstrumentation) ifTrue: [
			^ MpCannotInstall signalWith: self ].

		deactivator := ProxyInstrumentationDeactivator new.
		deactivator handler: handler.

		newTrap := self trapMethodPrototype copy.
		trapSelector := newTrap selector.
		newTrap selector: proxyMethod selector.
		newTrap methodClass: proxyMethod methodClass.

		hiddenSelector := Object new.

		index := newTrap literals indexOf: trapSelector.
		newTrap literalAt: index put: hiddenSelector.

		index := newTrap literals indexOf: #handler.
		newTrap literalAt: index put: handler.

		index := newTrap literals indexOf: #deactivator.
		newTrap literalAt: index put: deactivator.

		"It could happen that a proxy wraps a proxy.
		Remember the object that was installed at this moment.
		This is the object to restore during uninstall"
		wrappedMethod := proxyMethod methodClass methodDict
			at: proxyMethod selector.

		proxyMethod methodClass methodDict
			at: hiddenSelector
			put: proxyMethod.
		proxyMethod methodClass methodDict
			at: proxyMethod selector
			put: newTrap.
			
		trapMethod := newTrap ]
]

{ #category : #testing }
MpMethodProxy >> isInstalled [

	trapMethod ifNil: [ ^ false ].

	^ proxyMethod methodClass >> proxyMethod selector == trapMethod
]

{ #category : #accessing }
MpMethodProxy >> methodClass [

	^ proxyMethod methodClass
]

{ #category : #accessing }
MpMethodProxy >> proxyMethod: anObject [

	proxyMethod := anObject
]

{ #category : #accessing }
MpMethodProxy >> selector [
	
	^ proxyMethod selector
]

{ #category : #'instruction decoding' }
MpMethodProxy >> trap [
	
	^ trapMethod
]

{ #category : #installation }
MpMethodProxy >> trapMethodPrototype [

	^ MpMethodProxyPrototypeFactory class methods detect: [ :m |
		  m numArgs = proxyMethod numArgs and: [ m selector beginsWith: 'trap' ] ]
]

{ #category : #installation }
MpMethodProxy >> uninstall [

	self isInstalled ifFalse: [ ^ self ].

	thisProcess runInMetaLevel: [
		proxyMethod methodClass methodDict
			at: proxyMethod selector
			put: wrappedMethod.
		proxyMethod methodClass methodDict removeKey: hiddenSelector ]
]

{ #category : #'when installed' }
MpMethodProxy >> wrappedMethod [

	^ proxyMethod
]
