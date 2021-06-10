Class {
	#name : #MpMethodProxyTest,
	#superclass : #TestCase,
	#instVars : [
		'trackedWrappers'
	],
	#category : #'MethodProxies-Tests'
}

{ #category : #asserting }
MpMethodProxyTest class >> shouldInheritSelectors [
	^ true
]

{ #category : #hook }
MpMethodProxyTest >> handlerClass [ 
	^ MpHandler
]

{ #category : #'tests - dead representation' }
MpMethodProxyTest >> installMethodProxy: aMethodWrapper [

	trackedWrappers add: aMethodWrapper.
	aMethodWrapper install.

]

{ #category : #initialization }
MpMethodProxyTest >> setUp [ 

	super setUp.
	trackedWrappers := OrderedCollection new.
	MpClassA methods do: [ :each | each uninstall ]
	
]

{ #category : #initialization }
MpMethodProxyTest >> tearDown [

	trackedWrappers do: [ :e | e uninstall ].
	super tearDown
]

{ #category : #'tests - dead representation' }
MpMethodProxyTest >> testCreatingAnInstanceDoesNotInstallIt [

	| mp method |
	method := MpClassA >> #methodOne.
	mp := MpMethodProxy on: #methodOne inClass: MpClassA handler: self handlerClass new.
	self assert: mp selector equals: #methodOne.
	self assert: mp methodClass equals: MpClassA.

	self assert: mp wrappedMethod equals: nil
]

{ #category : #'tests - safety' }
MpMethodProxyTest >> testExceptionsAfterInstrumentationDoNotBreakInstrumentation [

	| mp handler |
	mp := MpMethodProxy onMethod: Object >> #error: handler: (handler := MpCountingHandler new).
	
	self installMethodProxy: mp.

	"An error after instrumentation should not break the instrumentation.
	Subsequent calls should still be instrumented, and the counting code should still execute regardless the exception"
	2 timesRepeat: [
		[MpClassB new error: 'error after instrumentation'.
		self fail] on: Error do: [ :error | ] ].

	self assert: handler count equals: 2
]

{ #category : #'tests - safety' }
MpMethodProxyTest >> testExceptionsAfterInstrumentationFlow [
"Managing exceptions in the wrapper"
	| w |
	w := MpMethodProxy onMethod: Object >> #error: handler: MpCountingHandler new.
	
	self installMethodProxy: w.

	"An error after instrumentation should not break the instrumentation.
	Subsequent calls should still be instrumented"
	2 timesRepeat: [
		[MpClassB new error: 'error after instrumentation'.
		self fail]
			on: Error do: [ :error |
				self assert: error messageText equals: 'error after instrumentation' ].]
]

{ #category : #'tests - safety' }
MpMethodProxyTest >> testExceptionsDuringInstrumentationDoNotBreakInstrumentation [
"Managing exceptions in the wrapper"
	| w |
	w := MpMethodProxy onMethod: MpClassB >> #methodTwo  handler: MpFailingHandlerMock new.
	
	self installMethodProxy: w.

	"An error during instrumentation should not break the instrumentation.
	Subsequent calls should still be instrumented"
	2 timesRepeat: [
		[MpClassB new methodTwo.
		self fail]
			on: Error do: [ :error |
				self assert: error messageText equals: 'error during instrumentation' ].]
]

{ #category : #'tests - dead representation' }
MpMethodProxyTest >> testInstallOnWrongClass [

	| mw |
	mw := MpMethodProxy on: #methodOne inClass: Object handler: self handlerClass new.
	self assert: mw isNil
]

{ #category : #'tests - installation' }
MpMethodProxyTest >> testInstallSetCompiledMethod [

	| mw method |
	[ 
	method := MpClassA >> #methodOne.
	mw := MpMethodProxy on: #methodOne inClass: MpClassA handler: self handlerClass new.
	mw install.
	self assert: mw selector equals: #methodOne.
	self assert: mw methodClass equals: MpClassA.
	self assert: mw wrappedMethod equals: method ] ensure: [ 
		mw uninstall ]
]

{ #category : #'tests - installation' }
MpMethodProxyTest >> testIsInstalled [

	| mw method |
	[ 
	method := MpClassA >> #methodOne.
	mw := MpMethodProxy on: #methodOne inClass: MpClassA handler: self handlerClass new.
	self deny: mw isInstalled.
	mw install.
	self assert: mw isInstalled ] ensure: [ mw uninstall ]
]

{ #category : #'tests - installation' }
MpMethodProxyTest >> testIsInstalledNestedMWAreNotInstalled [

	| mw method mw2 |
	method := MpClassA >> #methodOne.
	mw := MpMethodProxy on: #methodOne inClass: MpClassA handler: self handlerClass new.
	mw2 := MpMethodProxy on: #methodOne inClass: MpClassA handler: MpMockMethodProxyHandler new.
	mw install.
	mw2 install.
	self deny: mw isInstalled.
	self assert: mw2 isInstalled.
	mw2 uninstall.
	self deny: mw2 isInstalled.
	self assert: mw isInstalled.
	mw uninstall.
	self deny: mw isInstalled
]

{ #category : #'tests - safety' }
MpMethodProxyTest >> testRecursiveMethodWrapperDoesNotRecurse [

	| mw method |
	method := MpMockObject >> #recursiveMethod.
	mw := MpMethodProxy onMethod: method  handler: MpMockMethodProxyHandler new.
	self installMethodProxy: mw.

	self assert: MpMockObject new recursiveMethod equals: 'trapped [original]'.
]

{ #category : #'tests - installation' }
MpMethodProxyTest >> testUninstall [

	| mw method |
	method := MpClassA >> #methodOne.
	mw := MpMethodProxy on: #methodOne inClass: MpClassA handler: self handlerClass new.
	mw install.
	self assert: (MpClassA compiledMethodAt: #methodOne) isMethodProxy.
	self assert: (MpClassA compiledMethodAt: #methodOne) == mw.
	mw uninstall.
	self assert: (MpClassA compiledMethodAt: #methodOne) == method.
	self assert: mw wrappedMethod isNil
]

{ #category : #'tests - installation' }
MpMethodProxyTest >> testUninstallNestedInRightOrderIsOk [

	| mw mw2 method |
	method := MpClassA >> #methodOne.
	mw := MpMethodProxy on: #methodOne inClass: MpClassA handler: self handlerClass new.
	mw2 := MpMethodProxy on: #methodOne inClass: MpClassA handler: MpMockMethodProxyHandler new.
	mw install.
	mw2 install.
	self assert: (MpClassA compiledMethodAt: #methodOne) isMethodProxy.
	self assert: (MpClassA compiledMethodAt: #methodOne) identicalTo: mw2.
	mw2 uninstall.
	self assert: (MpClassA compiledMethodAt: #methodOne) identicalTo: mw.
	mw uninstall.
	self
		assert: (MpClassA compiledMethodAt: #methodOne)
		identicalTo: method
]

{ #category : #tests }
MpMethodProxyTest >> testUnwrappedMethodAtOneLevelIsTheWrappedMethod [

	| mw method |
	[ 
	method := MpClassA >> #methodOne.
	mw := MpMethodProxy on: #methodOne inClass: MpClassA handler: self handlerClass new.
	mw install.
	self assert: mw unproxifiedMethod equals: method ] ensure: [ 
		mw uninstall ]
]

{ #category : #tests }
MpMethodProxyTest >> testUnwrappedMethodOfNestedMethodWrapperInTheCompiledMethod [

	| mw method mw2 |
	[ 
	method := MpClassA >> #methodOne.
	mw := MpMethodProxy on: #methodOne inClass: MpClassA handler: self handlerClass new.
	mw install.
	mw2 := MpMethodProxy on: #methodOne inClass: MpClassA handler: MpMockMethodProxyHandler new.
	mw2 install.

	self assert: mw2 wrappedMethod equals: mw.
	self assert: mw2 unproxifiedMethod equals: method ] ensure: [ 
		mw2 uninstall.
		mw uninstall ]
]

{ #category : #'tests - safety' }
MpMethodProxyTest >> testWrapEssentialPrimitiveShouldBeCalledDuringInstallation [

	| mw method handler |
	method := SmallInteger >> #+.
	mw := MpMethodProxy onMethod: method handler: (handler := MpCalledHandler new).
	self installMethodProxy: mw.

	self deny: handler called
]

{ #category : #'tests - safety' }
MpMethodProxyTest >> testWrapEssentialPrimitiveShouldNotRecurse [

	| mw method handler |
	method := SmallInteger >> #+.
	mw := MpMethodProxy onMethod: method handler: (handler := MpCalledHandler new).
	self installMethodProxy: mw.

	"Do a perform, otherwise the addition is optimized out and tried as non-send addition.
	A message send is issued only if the normal addition fails"
	1 perform: #+ with: 2.

	self assert: handler called
]

{ #category : #'tests - safety' }
MpMethodProxyTest >> testWrapMethodCalledDuringInstallationIsNotIntercepted [

	| mw method handler |
	method := SmallInteger lookupSelector: #max:.
	mw := MpMethodProxy onMethod: method handler: (handler := MpCalledHandler new).
	self installMethodProxy: mw.

	self deny: handler called
]

{ #category : #tests }
MpMethodProxyTest >> testWrappingTwiceIsPossible [

	| mw method mw2 |
	[ 
	method := MpClassA >> #methodOne.
	mw := MpMethodProxy on: #methodOne inClass: MpClassA handler: self handlerClass new.
	mw install.

	mw2 := MpMethodProxy on: #methodOne inClass: MpClassA handler: MpMockMethodProxyHandler new.
	mw2 install.

	self assert: mw selector equals: #methodOne.
	self assert: mw methodClass equals: MpClassA.
	self assert: mw wrappedMethod equals: method.

	self assert: mw2 selector equals: #methodOne.
	self assert: mw2 methodClass equals: MpClassA.
	self assert: mw2 wrappedMethod equals: mw ] ensure: [ 
		mw2 uninstall.
		self assert: (MpClassA methodDict at: #methodOne) equals: mw.
		mw uninstall.
		self assert: (MpClassA methodDict at: #methodOne) equals: method ]
]
