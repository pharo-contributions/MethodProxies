Class {
	#name : 'MpMethodProxyTest',
	#superclass : 'MpAbstractMethodProxyTest',
	#category : 'MethodProxies-Tests',
	#package : 'MethodProxies-Tests'
}

{ #category : 'asserting' }
MpMethodProxyTest class >> shouldInheritSelectors [
	^ true
]

{ #category : 'tests - safety' }
MpMethodProxyTest >> assertCannotInstall: mp [

	[mp install.
	self fail.]
		on: MpCannotInstall do: [ :ex |
			self assert: ex methodProxy equals: mp ]
]

{ #category : 'tests - safety' }
MpMethodProxyTest >> callEnsureWithNonLocalReturn [
	
	[ ^ 7 ] ensure: [ 2 ]
]

{ #category : 'hook' }
MpMethodProxyTest >> handlerClass [ 
	^ MpHandler
]

{ #category : 'tests - safety' }
MpMethodProxyTest >> testArgumentListIsSent [

	| mp handler |
	mp := MpMethodProxy onMethod: MpClassA >> #methodWithArgument: handler: (handler := MpArgumentListTestHandler new).
	
	self installMethodProxy: mp.

	MpClassA new x: 1; methodWithArgument: 111.

	mp uninstall.
	"Test before"
	self assert: handler beforeArgs size equals: 1.
	self assert: handler beforeArgs first equals: 111.
	
	"Test after"
	self assert: handler afterArgs size equals: 1.
	self assert: handler afterArgs first equals: 111.
]

{ #category : 'tests - safety' }
MpMethodProxyTest >> testArgumentListIsSentSizeTwo [

	| mp handler |
	mp := MpMethodProxy
		onMethod: MpClassA >> #methodWithArgumentOne:argumentTwo: handler: (handler := MpArgumentListTestHandler new).
	
	self installMethodProxy: mp.

	MpClassA new x:1; methodWithArgumentOne: 22 argumentTwo: 33.

	mp uninstall.
	"Test before"
	self assert: handler beforeArgs size equals: 2.
	self assert: handler beforeArgs first equals: 22.
	self assert: handler beforeArgs second equals: 33.
	
	"Test after"
	self assert: handler afterArgs size equals: 2.
	self assert: handler afterArgs first equals: 22.
	self assert: handler afterArgs second equals: 33
]

{ #category : 'tests - safety' }
MpMethodProxyTest >> testArgumentListIsSentSizeZero [

	| mp handler |
	mp := MpMethodProxy onMethod: MpClassA >> #methodTwo handler: (handler := MpArgumentListTestHandler new).
	
	self installMethodProxy: mp.

	MpClassA new methodTwo.

	mp uninstall.
	"Test before"
	self assert: handler beforeArgs isEmpty.
	
	"Test after"
	self assert: handler afterArgs isEmpty.
]

{ #category : 'tests - safety' }
MpMethodProxyTest >> testCanRunConcurrently [
	"This tests the ability of method proxies to not influence each other between threads."

	| mp1 mp2 mpTrigger1 mpTrigger2 handlerTrigger1 handlerTrigger2 sharedObject testSemaphore p1 p2 |
	sharedObject := MpTestConcurrentSharedObject new.
	testSemaphore := Semaphore new.

	mp1 := MpMethodProxy
		       onMethod:
		       (MpTestConcurrentSharedObject lookupSelector: #methodProcess1)
		       handler: MpWaitBeforeHandler new.
	mp2 := MpMethodProxy
		       onMethod:
		       (MpTestConcurrentSharedObject lookupSelector: #methodProcess2)
		       handler: MpWaitAndTriggerBeforeHandler new.
	mpTrigger1 := MpMethodProxy
		              onMethod:
		              (MpTestConcurrentSharedObject lookupSelector:
			               #trigger1)
		              handler:
		              (handlerTrigger1 := MpAfterCounterHandler new).
	mpTrigger2 := MpMethodProxy
		              onMethod:
		              (MpTestConcurrentSharedObject lookupSelector:
			               #trigger2)
		              handler:
		              (handlerTrigger2 := MpAfterCounterHandler new).

	self installMethodProxy: mp1.
	self installMethodProxy: mp2.
	self installMethodProxy: mpTrigger1.
	self installMethodProxy: mpTrigger2.

	"Here the first process will run an instrumented trigger (trigger1) while the second process is not instrumenting, then the second process will run a non-instrumented trigger while the first process is still instrumenting."
	p1 := [
	sharedObject methodProcess1.
	testSemaphore signal ] fork.
	p2 := [
	sharedObject methodProcess2.
	testSemaphore signal ] fork.
	testSemaphore wait.

	"Here the first trigger should have been captured, but not the second. If not concurrency is not correctly managed."
	self assert: handlerTrigger1 count equals: 1.
	self assert: handlerTrigger2 count equals: 0
]

{ #category : 'tests - safety' }
MpMethodProxyTest >> testCanWrapAboutToReturnThroughWithNonLocalReturn [

	| mp handler |
	mp := MpMethodProxy onMethod: Context >> #aboutToReturn:through: handler: (handler := MpCountingHandler new).
	
	self installMethodProxy: mp.

	self callEnsureWithNonLocalReturn.

	self assert: handler count equals: 1
]

{ #category : 'tests - safety' }
MpMethodProxyTest >> testCanWrapBasicNew [

	| mp handler |
	mp := MpMethodProxy onMethod: Behavior >> #basicNew handler: (handler := MpCountingHandler new).
	
	self installMethodProxy: mp.

	MpClassA new.

	mp uninstall.
	self assert: handler count equals: 1
]

{ #category : 'tests - safety' }
MpMethodProxyTest >> testCanWrapEnsure [

	| mp handler |
	mp := MpMethodProxy onMethod: BlockClosure >> #ensure: handler: (handler := MpCountingHandler new).
	
	self installMethodProxy: mp.

	[ 1 ] ensure: [ 2 ].

	self assert: handler count equals: 1
]

{ #category : 'tests - safety' }
MpMethodProxyTest >> testCanWrapEnsureNonLocalReturn [

	| mp handler |
	mp := MpMethodProxy onMethod: BlockClosure >> #ensure: handler: (handler := MpCountingHandler new).
	
	self installMethodProxy: mp.

	self callEnsureWithNonLocalReturn.

	self assert: handler count equals: 1
]

{ #category : 'tests - safety' }
MpMethodProxyTest >> testCanWrapEnsureWithException [

	| mp handler |
	mp := MpMethodProxy onMethod: BlockClosure >> #ensure: handler: (handler := MpCountingHandler new).
	
	self installMethodProxy: mp.

	[[ 1 error ] ensure: [ 2 ]] on: Error do: [ "nothing" ].

	self assert: handler count equals: 1
]

{ #category : 'tests - safety' }
MpMethodProxyTest >> testCanWrapValue [
	<compilerOptions: #(- optionConstantBlockClosure)>
	<compilerOptions: #(- optionOptimiseSpecialSends)>
	| mp handler |
	mp := MpMethodProxy onMethod: (FullBlockClosure lookupSelector: #value) handler: (handler := MpCountingHandler new).
	
	self installMethodProxy: mp.

	[[ 1 ] value] value.

	self assert: handler count equals: 2
]

{ #category : 'tests - safety' }
MpMethodProxyTest >> testCanWrapValueWithException [

	<compilerOptions: #( #- optionOptimiseSpecialSends )>
	| mp handler |
	mp := MpMethodProxy
		      onMethod: (FullBlockClosure lookupSelector: #value)
		      handler: (handler := MpCountingHandler new).

	self installMethodProxy: mp.
	[ [ [ 1 error ] value ] value ]
		on: Error
		do: #yourself. "to avoid an extra block"

	"#on:do: does send value too but it's optimised by default and there is no message send"
	self assert: handler count equals: 2
]

{ #category : 'tests - safety' }
MpMethodProxyTest >> testCannotWrapCriticalProxyMethods6 [

	| mp handler |
	mp := MpMethodProxy onMethod: InstrumentationDeactivator >> #value handler: (handler := MpCountingHandler new).
	
	self assertCannotInstall: mp
]

{ #category : 'tests - dead representation' }
MpMethodProxyTest >> testCreatingAnInstanceDoesNotInstallIt [

	| mp |
	mp := MpMethodProxy
		      onMethod: MpClassA >> #methodOne
		      handler: self handlerClass new.
	self assert: mp selector equals: #methodOne.
	self assert: mp methodClass equals: MpClassA.

	self deny: mp isInstalled
]

{ #category : 'tests - safety' }
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

{ #category : 'tests - safety' }
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

{ #category : 'tests - safety' }
MpMethodProxyTest >> testExceptionsDuringInstrumentationDoNotBreakInstrumentation [
"Managing exceptions in the wrapper"
	| w |
	w := MpMethodProxy onMethod: MpClassB >> #methodTwo  handler: MpFailingBeforeHandler new.
	
	self installMethodProxy: w.

	"An error during instrumentation should not break the instrumentation.
	Subsequent calls should still be instrumented"
	2 timesRepeat: [
		[MpClassB new methodTwo.
		self fail]
			on: Error do: [ :error |
				self assert: error messageText equals: 'error during instrumentation' ].]
]

{ #category : 'tests - installation' }
MpMethodProxyTest >> testInstallSetCompiledMethod [

	| mw method |
	[ 
	method := MpClassA >> #methodOne.
	mw := MpMethodProxy  onMethod: method handler: self handlerClass new.
	mw install.
	self assert: mw selector equals: #methodOne.
	self assert: mw methodClass equals: MpClassA.
	self assert: mw proxifiedMethod equals: method ] ensure: [ 
		mw uninstall ]
]

{ #category : 'tests - installation' }
MpMethodProxyTest >> testIsInstalled [

	| mw method |
	[ 
	method := MpClassA >> #methodOne.
	mw := MpMethodProxy onMethod: method handler: self handlerClass new.
	self deny: mw isInstalled.
	mw install.
	self assert: mw isInstalled ] ensure: [ mw uninstall ]
]

{ #category : 'tests - installation' }
MpMethodProxyTest >> testIsInstalledNestedMWAreNotInstalled [

	| mp mp2 |
	mp := MpMethodProxy
		      onMethod: MpClassA >> #methodOne
		      handler: self handlerClass new.
	mp2 := MpMethodProxy
		       onMethod: MpClassA >> #methodOne
		       handler: self handlerClass new.

	[
	[
	mp install.
	mp2 install.
	self deny: mp isInstalled.
	self assert: mp2 isInstalled ] ensure: [
		mp2 uninstall.
		self deny: mp2 isInstalled.
		self assert: mp isInstalled ] ] ensure: [
		mp uninstall.
		self deny: mp isInstalled ]
]

{ #category : 'tests - safety' }
MpMethodProxyTest >> testRecursiveMethodWrapperDoesNotRecurse [

	| mw method |
	method := MpMockObject >> #recursiveMethod.
	mw := MpMethodProxy onMethod: method handler: MpAfterResultHandler new.
	self installMethodProxy: mw.

	self assert: MpMockObject new recursiveMethod equals: 'trapped [original]'.
]

{ #category : 'tests - installation' }
MpMethodProxyTest >> testUninstall [

	| mp method |
	[
	method := MpClassA >> #methodOne.
	mp := MpMethodProxy onMethod: method handler: self handlerClass new.
	mp install.
	self assert:
		(MpClassA compiledMethodAt: #methodOne) selector = #methodOne.
	self assert: (MpClassA compiledMethodAt: #methodOne) == mp trapMethod ]
		ensure: [
			mp uninstall.
			self assert: (MpClassA compiledMethodAt: #methodOne) == method ]
]

{ #category : 'tests - installation' }
MpMethodProxyTest >> testUninstallNestedInRightOrderIsOk [

	| mp mp2 method |
	method := MpClassA >> #methodOne.
	mp := MpMethodProxy
		      onMethod: MpClassA >> #methodOne
		      handler: self handlerClass new.
	mp2 := MpMethodProxy
		       onMethod: MpClassA >> #methodOne
		       handler: self handlerClass new.
	self installMethodProxy: mp.
	self installMethodProxy: mp2.

	[
	[
	self
		assert: (MpClassA compiledMethodAt: #methodOne)
		identicalTo: mp2 trapMethod ] ensure: [
		mp2 uninstall.
		self
			assert: (MpClassA compiledMethodAt: #methodOne)
			identicalTo: mp trapMethod ] ] ensure: [ mp uninstall ].
	self
		assert: (MpClassA compiledMethodAt: #methodOne)
		identicalTo: method
]

{ #category : 'tests' }
MpMethodProxyTest >> testUnwrappedMethodAtOneLevelIsTheWrappedMethod [

	| mp method |
	method := MpClassA >> #methodOne.
	mp := MpMethodProxy onMethod: method handler: self handlerClass new.
	self installMethodProxy: mp.

	self assert: mp proxifiedMethod equals: method
]

{ #category : 'tests' }
MpMethodProxyTest >> testUnwrappedMethodOfNestedMethodWrapperInTheCompiledMethod [

	| mp method mp2 |
	method := MpClassA >> #methodOne.
	mp := MpMethodProxy
		      onMethod: MpClassA >> #methodOne
		      handler: self handlerClass new.
	self installMethodProxy: mp.

	mp2 := MpMethodProxy
		       onMethod: MpClassA >> #methodOne
		       handler: self handlerClass new.
	self installMethodProxy: mp2.

	self assert: mp2 proxifiedMethod equals: mp trapMethod.
]

{ #category : 'tests - safety' }
MpMethodProxyTest >> testWrapEssentialPrimitiveShouldBeCalledDuringInstallation [

	| mw method handler |
	method := SmallInteger >> #+.
	mw := MpMethodProxy onMethod: method handler: (handler := MpCalledHandler new).
	self installMethodProxy: mw.

	self deny: handler called
]

{ #category : 'tests - safety' }
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

{ #category : 'tests - safety' }
MpMethodProxyTest >> testWrapMethodCalledDuringInstallationIsNotIntercepted [

	| mw method handler |
	method := SmallInteger lookupSelector: #max:.
	mw := MpMethodProxy onMethod: method handler: (handler := MpCalledHandler new).
	self installMethodProxy: mw.

	self deny: handler called
]

{ #category : 'tests - safety' }
MpMethodProxyTest >> testWrapNonLocalReturns [

	| mp handler |
	mp := MpMethodProxy
		      onMethod: MpClassA >> #methodAcceptingABlock:
		      handler: (handler := MpAfterCounterHandler new).

	self installMethodProxy: mp.

	MpClassA new methodWithNonLocalReturn.

	self assert: handler count equals: 1
]

{ #category : 'tests' }
MpMethodProxyTest >> testWrappingTwiceIsPossible [

	| mp1 method mp2 |
	[
	method := MpClassA >> #methodOne.
	mp1 := MpMethodProxy
		       onMethod: MpClassA >> #methodOne
		       handler: self handlerClass new.
	self installMethodProxy: mp1.

	mp2 := MpMethodProxy
		       onMethod: MpClassA >> #methodOne
		       handler: self handlerClass new.
	self installMethodProxy: mp2.

	self assert: mp1 selector equals: #methodOne.
	self assert: mp1 methodClass equals: MpClassA.
	self assert: mp1 proxifiedMethod equals: method.

	self assert: mp2 selector equals: #methodOne.
	self assert: mp2 methodClass equals: MpClassA.
	self assert: mp2 proxifiedMethod equals: mp1 trapMethod ] ensure: [
		[
		mp2 uninstall.
		self assert: (MpClassA methodDict at: #methodOne) equals: mp1 trapMethod ]
			ensure: [
				mp1 uninstall.
				self assert: (MpClassA methodDict at: #methodOne) equals: method ] ]
]
