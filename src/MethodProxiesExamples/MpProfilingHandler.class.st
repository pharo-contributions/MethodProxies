"
I'm a more advanced proxy that propagates itself during execution.
When a proxy is executed, before letting the execution runs, it installs itself on all the implementators of the methods used in the method.
```
proxy := nil.
proxies := nil.
Smalltalk garbageCollect.
testCase := StringTest selector: #testAsCamelCase.
testMethod := StringTest lookupSelector: testCase selector.
proxy := MpMethodProxy
				onMethod: testMethod
				handler: (MpProfilingHandler new
					wrappedMethod: testMethod;
					yourself).
proxy install.
testCase run.
proxies := MpMethodProxy allInstances.
proxies do: #uninstall.
proxies collect: #handler
```
"
Class {
	#name : #MpProfilingHandler,
	#superclass : #MpHandler,
	#instVars : [
		'count',
		'wrappedMethod'
	],
	#category : #MethodProxiesExamples
}

{ #category : #evaluating }
MpProfilingHandler >> beforeMethod [

	self count: self count + 1.

	count > 1 ifTrue: [ ^ self ].
	wrappedMethod literalsEvenTheOnesInTheInnerBlocks
		select: [ :literal | literal isSymbol ]
		thenDo: [ :potentialSelector | self instrumentImplementorsOf: potentialSelector ]
]

{ #category : #accessing }
MpProfilingHandler >> count [

	^ count
]

{ #category : #accessing }
MpProfilingHandler >> count: anInteger [

	count := anInteger
]

{ #category : #initialization }
MpProfilingHandler >> initialize [

	super initialize.
	count := 0.
]

{ #category : #evaluating }
MpProfilingHandler >> instrumentImplementorsOf: potentialSelector [

	| newProxy |
	potentialSelector implementors do: [ :method |
		newProxy := MpMethodProxy
			onMethod: method
			handler: (MpProfilingHandler new
				wrappedMethod: method;
				yourself).
		(newProxy notNil and: [ (newProxy shouldWrap: method) ])
			ifTrue: [ newProxy install ].
	]
]

{ #category : #accessing }
MpProfilingHandler >> proxifiedMethod [
	^ wrappedMethod
]

{ #category : #evaluating }
MpProfilingHandler >> wrappedMethod: aMethod [
	wrappedMethod := aMethod
]
