Class {
	#name : #MpAbstractMethodProxyTest,
	#superclass : #TestCase,
	#instVars : [
		'trackedWrappers'
	],
	#category : #'MethodProxies-Tests'
}

{ #category : #testing }
MpAbstractMethodProxyTest class >> isAbstract [

	^ self == MpAbstractMethodProxyTest
]

{ #category : #'tests - dead representation' }
MpAbstractMethodProxyTest >> installMethodProxy: aMethodProxy [

	trackedWrappers add: aMethodProxy.
	aMethodProxy install.

]

{ #category : #initialization }
MpAbstractMethodProxyTest >> setUp [

	super setUp.
	trackedWrappers := OrderedCollection new
]

{ #category : #initialization }
MpAbstractMethodProxyTest >> tearDown [

	| stillInstalled |
	
	"Uninstall proxies using a fixed point approach.
	This is to cover a problem of proxies wrapping proxies for now"
	[
	stillInstalled := trackedWrappers select: [ :e | e isInstalled ].
	stillInstalled isEmpty ] whileFalse: [
		stillInstalled do: [ :each |
			[
			each uninstall.
			trackedWrappers remove: each ]
				on: Error
				do: [ :e | "continue" ] ] ].

	"Give me the guarantee that we did not leave proxies installed in the system"
	(MpMethodProxy allInstances anySatisfy: [ :e | e isInstalled ])
		ifTrue: [
			self error:
				'Proxies still installed after test: ' , testSelector asString ].

	super tearDown
]
