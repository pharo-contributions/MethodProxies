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

{ #category : #'tests - safety' }
MpMethodProxyTest >> assertCannotInstall: mp [

	[mp install.
	self fail.]
		on: MpCannotInstall do: [ :ex |
			self assert: ex methodProxy equals: mp ]
]

{ #category : #'tests - safety' }
MpMethodProxyTest >> callEnsureWithNonLocalReturn [
	
	[ ^ 7 ] ensure: [ 2 ]
]

{ #category : #hook }
MpMethodProxyTest >> handlerClass [ 
	^ MpHandler
]

{ #category : #'tests - dead representation' }
MpMethodProxyTest >> installMethodProxy: aMethodProxy [

	trackedWrappers add: aMethodProxy.
	aMethodProxy install.

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

{ #category : #'tests - safety' }
MpMethodProxyTest >> testCanRunConcurrently [
	"This tests the ability of method proxies to not influence each other between threads."
	| mp1 mp2 mpTrigger1 mpTrigger2 handlerTrigger1 handlerTrigger2 sharedObject testSemaphore |
	
	sharedObject := MpTestConcurrentSharedObject new.
	testSemaphore := Semaphore new.
	
	mp1 := MpMethodProxy onMethod: (MpTestConcurrentSharedObject lookupSelector: #methodProcess1) handler: (MpWaitBeforeHandler new).
	mp2 := MpMethodProxy onMethod: (MpTestConcurrentSharedObject lookupSelector: #methodProcess2) handler: (MpWaitAndTriggerBeforeHandler new).
	mpTrigger1 := MpMethodProxy onMethod: (MpTestConcurrentSharedObject lookupSelector: #trigger1) handler: (handlerTrigger1 := MpAfterCounterHandler new).
	mpTrigger2 := MpMethodProxy onMethod: (MpTestConcurrentSharedObject lookupSelector: #trigger2) handler: (handlerTrigger2 := MpAfterCounterHandler new).
	
	self installMethodProxy: mp1.
	self installMethodProxy: mp2.
	self installMethodProxy: mpTrigger1.
	self installMethodProxy: mpTrigger2.
	
	"Here the first process will run an instrumented trigger (trigger1) while the second process is not instrumenting, then the second process will run a non-instrumented trigger while the first process is still instrumenting."
	[ sharedObject methodProcess1. testSemaphore signal ] fork.
	[ sharedObject methodProcess2. testSemaphore signal ] fork.
	testSemaphore wait.
	
	"Here the first trigger should have been captured, but not the second. If not concurrency is not correctly managed."
	self assert: handlerTrigger1 count equals: 1.
	self assert: handlerTrigger2 count equals: 0
]

{ #category : #'tests - safety' }
MpMethodProxyTest >> testCanWrapAboutToReturnThroughWithNonLocalReturn [

	| mp handler |
	mp := MpMethodProxy onMethod: Context >> #aboutToReturn:through: handler: (handler := MpCountingHandler new).
	
	self installMethodProxy: mp.

	self callEnsureWithNonLocalReturn.

	self assert: handler count equals: 1
]

{ #category : #'tests - safety' }
MpMethodProxyTest >> testCanWrapEnsure [

	| mp handler |
	mp := MpMethodProxy onMethod: BlockClosure >> #ensure: handler: (handler := MpCountingHandler new).
	
	self installMethodProxy: mp.

	[ 1 ] ensure: [ 2 ].

	self assert: handler count equals: 1
]

{ #category : #'tests - safety' }
MpMethodProxyTest >> testCanWrapEnsureNonLocalReturn [

	| mp handler |
	mp := MpMethodProxy onMethod: BlockClosure >> #ensure: handler: (handler := MpCountingHandler new).
	
	self installMethodProxy: mp.

	self callEnsureWithNonLocalReturn.

	self assert: handler count equals: 1
]

{ #category : #'tests - safety' }
MpMethodProxyTest >> testCanWrapEnsureWithException [

	| mp handler |
	mp := MpMethodProxy onMethod: BlockClosure >> #ensure: handler: (handler := MpCountingHandler new).
	
	self installMethodProxy: mp.

	[[ 1 error ] ensure: [ 2 ]] on: Error do: [ "nothing" ].

	self assert: handler count equals: 1
]

{ #category : #'tests - safety' }
MpMethodProxyTest >> testCanWrapValue [
	<compilerOptions: #(- optionConstantBlockClosure)>
	| mp handler |
	mp := MpMethodProxy onMethod: (FullBlockClosure lookupSelector: #value) handler: (handler := MpCountingHandler new).
	
	self installMethodProxy: mp.

	[[ 1 ] value] value.

	self assert: handler count equals: 2
]

{ #category : #'tests - safety' }
MpMethodProxyTest >> testCanWrapValueWithException [

	| mp handler |
	mp := MpMethodProxy onMethod: (FullBlockClosure lookupSelector: #value) handler: (handler := MpCountingHandler new).
	
	self installMethodProxy: mp.

	[[[ 1 error ] value] value] on: Error do: #yourself "to avoid an extra block".

	self assert: handler count equals: 2 "value" + 1 "on:do:"
]

{ #category : #'tests - installation' }
MpMethodProxyTest >> testCannotProxyUnexistentMethod [

	| mp |
	mp := MpMethodProxy on: #methodOne inClass: Object handler: self handlerClass new.
	
	self assertCannotInstall: mp
]

{ #category : #'tests - safety' }
MpMethodProxyTest >> testCannotWrapCriticalProxyMethods [

	| mp handler |
	mp := MpMethodProxy onMethod: MpMethodProxy >> #valueWithReceiver:arguments: handler: (handler := MpCountingHandler new).
	
	self assertCannotInstall: mp
]

{ #category : #'tests - safety' }
MpMethodProxyTest >> testCannotWrapCriticalProxyMethods2 [

	| mp handler |
	mp := MpMethodProxy onMethod: MpMethodProxy >> #receiver:withArgs:executeMethod: handler: (handler := MpCountingHandler new).
	
	self assertCannotInstall: mp
]

{ #category : #'tests - safety' }
MpMethodProxyTest >> testCannotWrapCriticalProxyMethods3 [

	| mp handler |
	mp := MpMethodProxy onMethod: MpMethodProxy >> #run:with:in: handler: (handler := MpCountingHandler new).
	
	self assertCannotInstall: mp
]

{ #category : #'tests - safety' }
MpMethodProxyTest >> testCannotWrapCriticalProxyMethods4 [

	| mp handler |
	mp := MpMethodProxy onMethod: BlockClosure >> #methodProxyEnsure: handler: (handler := MpCountingHandler new).
	
	self assertCannotInstall: mp
]

{ #category : #'tests - safety' }
MpMethodProxyTest >> testCannotWrapCriticalProxyMethods5 [

	| mp handler |
	mp := MpMethodProxy onMethod: MpMethodProxyActivator >> #value handler: (handler := MpCountingHandler new).
	
	self assertCannotInstall: mp
]

{ #category : #'tests - safety' }
MpMethodProxyTest >> testCannotWrapCriticalProxyMethods6 [

	| mp handler |
	mp := MpMethodProxy onMethod: MpMethodProxyDeactivator >> #value handler: (handler := MpCountingHandler new).
	
	self assertCannotInstall: mp
]

{ #category : #'tests - safety' }
MpMethodProxyTest >> testCannotWrapCriticalProxyMethods7 [

	| mp handler |
	mp := MpMethodProxy onMethod: MpMethodProxyPool class >> #protect handler: (handler := MpCountingHandler new).
	
	self assertCannotInstall: mp
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
	| p |
	p := MpMethodProxy onMethod: Object >> #error: handler: MpCountingHandler new.
	
	self installMethodProxy: p.

	"An error after instrumentation should not break the instrumentation.
	Subsequent calls should still be instrumented"
	2 timesRepeat: [
		[ MpClassB new error: 'error after instrumentation'.
		self fail ]
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

	| mp method mp2 |
	method := MpClassA >> #methodOne.
	mp := MpMethodProxy on: #methodOne inClass: MpClassA handler: self handlerClass new.
	mp2 := MpMethodProxy on: #methodOne inClass: MpClassA handler: MpMockMethodProxyHandler new.
	mp install.
	mp2 install.
	self deny: mp isInstalled.
	self assert: mp2 isInstalled.
	mp2 uninstall.
	self deny: mp2 isInstalled.
	self assert: mp isInstalled.
	mp uninstall.
	self deny: mp isInstalled
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

	| mp method |
	method := MpClassA >> #methodOne.
	mp := MpMethodProxy on: #methodOne inClass: MpClassA handler: self handlerClass new.
	mp install.
	self assert: (MpClassA compiledMethodAt: #methodOne) isMethodProxy.
	self assert: (MpClassA compiledMethodAt: #methodOne) == mp.
	mp uninstall.
	self assert: (MpClassA compiledMethodAt: #methodOne) == method.
	self assert: mp wrappedMethod isNil
]

{ #category : #'tests - installation' }
MpMethodProxyTest >> testUninstallNestedInRightOrderIsOk [

	| mp mp2 method |
	method := MpClassA >> #methodOne.
	mp := MpMethodProxy on: #methodOne inClass: MpClassA handler: self handlerClass new.
	mp2 := MpMethodProxy on: #methodOne inClass: MpClassA handler: MpMockMethodProxyHandler new.
	mp install.
	mp2 install.
	self assert: (MpClassA compiledMethodAt: #methodOne) isMethodProxy.
	self assert: (MpClassA compiledMethodAt: #methodOne) identicalTo: mp2.
	mp2 uninstall.
	self assert: (MpClassA compiledMethodAt: #methodOne) identicalTo: mp.
	mp uninstall.
	self
		assert: (MpClassA compiledMethodAt: #methodOne)
		identicalTo: method
]

{ #category : #tests }
MpMethodProxyTest >> testUnwrappedMethodAtOneLevelIsTheWrappedMethod [

	| mp method |
	[ 
	method := MpClassA >> #methodOne.
	mp := MpMethodProxy on: #methodOne inClass: MpClassA handler: self handlerClass new.
	mp install.
	self assert: mp unproxifiedMethod equals: method ] ensure: [ 
		mp uninstall ]
]

{ #category : #tests }
MpMethodProxyTest >> testUnwrappedMethodOfNestedMethodWrapperInTheCompiledMethod [

	| mp method mp2 |
	[ 
	method := MpClassA >> #methodOne.
	mp := MpMethodProxy on: #methodOne inClass: MpClassA handler: self handlerClass new.
	mp install.
	mp2 := MpMethodProxy on: #methodOne inClass: MpClassA handler: MpMockMethodProxyHandler new.
	mp2 install.

	self assert: mp2 wrappedMethod equals: mp.
	self assert: mp2 unproxifiedMethod equals: method ] ensure: [ 
		mp2 uninstall.
		mp uninstall ]
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

{ #category : #'tests - safety' }
MpMethodProxyTest >> testWrapNonLocalReturns [

	| mp handler |
	mp := MpMethodProxy
		      onMethod: MpClassA >> #methodAcceptingABlock:
		      handler: (handler := MpAfterCounterHandler new).

	self installMethodProxy: mp.

	MpClassA new methodWithNonLocalReturn.

	self assert: handler count equals: 1
]

{ #category : #tests }
MpMethodProxyTest >> testWrappingTwiceIsPossible [

	| mp1 method mp2 |
	[ 
	method := MpClassA >> #methodOne.
	mp1 := MpMethodProxy on: #methodOne inClass: MpClassA handler: self handlerClass new.
	mp1 install.

	mp2 := MpMethodProxy on: #methodOne inClass: MpClassA handler: MpMockMethodProxyHandler new.
	mp2 install.

	self assert: mp1 selector equals: #methodOne.
	self assert: mp1 methodClass equals: MpClassA.
	self assert: mp1 wrappedMethod equals: method.

	self assert: mp2 selector equals: #methodOne.
	self assert: mp2 methodClass equals: MpClassA.
	self assert: mp2 wrappedMethod equals: mp1 ] ensure: [ 
		mp2 uninstall.
		self assert: (MpClassA methodDict at: #methodOne) equals: mp1.
		mp1 uninstall.
		self assert: (MpClassA methodDict at: #methodOne) equals: method ]
]
