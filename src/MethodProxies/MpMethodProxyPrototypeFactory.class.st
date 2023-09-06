Class {
	#name : #MpMethodProxyPrototypeFactory,
	#superclass : #Object,
	#category : #MethodProxies
}

{ #category : #evaluating }
MpMethodProxyPrototypeFactory class >> buildPrototypesUpToArguments: maxNumberOfArguments [

	"self buildPrototypesUpToArguments: 15"
	
	| forwarders |
	0 to: maxNumberOfArguments do: [ :numberOfArguments |
		| originalAst trapSelector trapArguments |
		originalAst := (MpMethodProxyPrototypeFactory class >> #protoPrototype)
			               parseTree.

		trapSelector := #trap.
		1 to: numberOfArguments do: [ :i |
		trapSelector := trapSelector , #with: ].
		trapArguments := ((1 to: numberOfArguments) collect: [ :i |
				 RBVariableNode named: 'arg' , i asString ]).

		originalAst selector: trapSelector.
		originalAst arguments: trapArguments.

		forwarders := originalAst sendNodes select: [ :e | e selector = #originalMessage ].
		forwarders do: [ :e | 
			e replaceWith: (RBMessageNode 
				receiver: RBVariableNode selfNode
				selector: trapSelector
				arguments: trapArguments) ].
		self class compile: originalAst formattedCode
	]
]

{ #category : #evaluating }
MpMethodProxyPrototypeFactory class >> protoPrototype [

	<primitive: 198>
	| deactivator result process complete wasMeta |
	process := Processor activeProcess.
	process isMeta ifTrue: [ ^ self originalMessage ].

	deactivator := #deactivator.
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: #(  ).
	process shiftLevelDown.
	wasMeta := false.

	result := self originalMessage.

	process shiftLevelUp.
	wasMeta := true.
	#handler aboutToReturnWithReceiver: self arguments: #(  ).
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: #(  )
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false.

	complete := true.

	^ result
]

{ #category : #'as yet unclassified' }
MpMethodProxyPrototypeFactory class >> proxyMethod: method handler: aHandler [

	^ MpMethodProxy new
		  proxyMethod: method;
		  handler: aHandler;
		  yourself
]

{ #category : #'as yet unclassified' }
MpMethodProxyPrototypeFactory class >> trap [

	<primitive: 198>
	| deactivator result process complete wasMeta |
	process := Processor activeProcess.
	process isMeta ifTrue: [ ^ self trap ].

	deactivator := #deactivator.
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: #(  ).
	process shiftLevelDown.
	wasMeta := false.

	result := self trap.

	process shiftLevelUp.
	wasMeta := true.
	#handler aboutToReturnWithReceiver: self arguments: #(  ).
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: #(  )
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false.

	complete := true.

	^ result
]

{ #category : #'as yet unclassified' }
MpMethodProxyPrototypeFactory class >> trapwith: arg1 [

	<primitive: 198>
	| deactivator result process complete wasMeta |
	process := Processor activeProcess.
	process isMeta ifTrue: [ ^ self trapwith: arg1 ].

	deactivator := #deactivator.
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: #(  ).
	process shiftLevelDown.
	wasMeta := false.

	result := self trapwith: arg1.

	process shiftLevelUp.
	wasMeta := true.
	#handler aboutToReturnWithReceiver: self arguments: #(  ).
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: #(  )
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false.

	complete := true.

	^ result
]

{ #category : #'as yet unclassified' }
MpMethodProxyPrototypeFactory class >> trapwith: arg1 with: arg2 [

	<primitive: 198>
	| deactivator result process complete wasMeta |
	process := Processor activeProcess.
	process isMeta ifTrue: [ ^ self trapwith: arg1 with: arg2 ].

	deactivator := #deactivator.
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: #(  ).
	process shiftLevelDown.
	wasMeta := false.

	result := self trapwith: arg1 with: arg2.

	process shiftLevelUp.
	wasMeta := true.
	#handler aboutToReturnWithReceiver: self arguments: #(  ).
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: #(  )
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false.

	complete := true.

	^ result
]

{ #category : #'as yet unclassified' }
MpMethodProxyPrototypeFactory class >> trapwith: arg1 with: arg2 with: arg3 [

	<primitive: 198>
	| deactivator result process complete wasMeta |
	process := Processor activeProcess.
	process isMeta ifTrue: [ ^ self trapwith: arg1 with: arg2 with: arg3 ].

	deactivator := #deactivator.
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: #(  ).
	process shiftLevelDown.
	wasMeta := false.

	result := self trapwith: arg1 with: arg2 with: arg3.

	process shiftLevelUp.
	wasMeta := true.
	#handler aboutToReturnWithReceiver: self arguments: #(  ).
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: #(  )
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false.

	complete := true.

	^ result
]

{ #category : #'as yet unclassified' }
MpMethodProxyPrototypeFactory class >> trapwith: arg1 with: arg2 with: arg3 with: arg4 [

	<primitive: 198>
	| deactivator result process complete wasMeta |
	process := Processor activeProcess.
	process isMeta ifTrue: [
		^ self
			  trapwith: arg1
			  with: arg2
			  with: arg3
			  with: arg4 ].

	deactivator := #deactivator.
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: #(  ).
	process shiftLevelDown.
	wasMeta := false.

	result := self
		          trapwith: arg1
		          with: arg2
		          with: arg3
		          with: arg4.

	process shiftLevelUp.
	wasMeta := true.
	#handler aboutToReturnWithReceiver: self arguments: #(  ).
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: #(  )
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false.

	complete := true.

	^ result
]

{ #category : #'as yet unclassified' }
MpMethodProxyPrototypeFactory class >> trapwith: arg1 with: arg2 with: arg3 with: arg4 with: arg5 [

	<primitive: 198>
	| deactivator result process complete wasMeta |
	process := Processor activeProcess.
	process isMeta ifTrue: [
		^ self
			  trapwith: arg1
			  with: arg2
			  with: arg3
			  with: arg4
			  with: arg5 ].

	deactivator := #deactivator.
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: #(  ).
	process shiftLevelDown.
	wasMeta := false.

	result := self
		          trapwith: arg1
		          with: arg2
		          with: arg3
		          with: arg4
		          with: arg5.

	process shiftLevelUp.
	wasMeta := true.
	#handler aboutToReturnWithReceiver: self arguments: #(  ).
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: #(  )
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false.

	complete := true.

	^ result
]

{ #category : #'as yet unclassified' }
MpMethodProxyPrototypeFactory class >> trapwith: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 [

	<primitive: 198>
	| deactivator result process complete wasMeta |
	process := Processor activeProcess.
	process isMeta ifTrue: [
		^ self
			  trapwith: arg1
			  with: arg2
			  with: arg3
			  with: arg4
			  with: arg5
			  with: arg6 ].

	deactivator := #deactivator.
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: #(  ).
	process shiftLevelDown.
	wasMeta := false.

	result := self
		          trapwith: arg1
		          with: arg2
		          with: arg3
		          with: arg4
		          with: arg5
		          with: arg6.

	process shiftLevelUp.
	wasMeta := true.
	#handler aboutToReturnWithReceiver: self arguments: #(  ).
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: #(  )
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false.

	complete := true.

	^ result
]

{ #category : #'as yet unclassified' }
MpMethodProxyPrototypeFactory class >> trapwith: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 with: arg7 [

	<primitive: 198>
	| deactivator result process complete wasMeta |
	process := Processor activeProcess.
	process isMeta ifTrue: [
		^ self
			  trapwith: arg1
			  with: arg2
			  with: arg3
			  with: arg4
			  with: arg5
			  with: arg6
			  with: arg7 ].

	deactivator := #deactivator.
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: #(  ).
	process shiftLevelDown.
	wasMeta := false.

	result := self
		          trapwith: arg1
		          with: arg2
		          with: arg3
		          with: arg4
		          with: arg5
		          with: arg6
		          with: arg7.

	process shiftLevelUp.
	wasMeta := true.
	#handler aboutToReturnWithReceiver: self arguments: #(  ).
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: #(  )
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false.

	complete := true.

	^ result
]

{ #category : #'as yet unclassified' }
MpMethodProxyPrototypeFactory class >> trapwith: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 with: arg7 with: arg8 [

	<primitive: 198>
	| deactivator result process complete wasMeta |
	process := Processor activeProcess.
	process isMeta ifTrue: [
		^ self
			  trapwith: arg1
			  with: arg2
			  with: arg3
			  with: arg4
			  with: arg5
			  with: arg6
			  with: arg7
			  with: arg8 ].

	deactivator := #deactivator.
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: #(  ).
	process shiftLevelDown.
	wasMeta := false.

	result := self
		          trapwith: arg1
		          with: arg2
		          with: arg3
		          with: arg4
		          with: arg5
		          with: arg6
		          with: arg7
		          with: arg8.

	process shiftLevelUp.
	wasMeta := true.
	#handler aboutToReturnWithReceiver: self arguments: #(  ).
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: #(  )
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false.

	complete := true.

	^ result
]

{ #category : #'as yet unclassified' }
MpMethodProxyPrototypeFactory class >> trapwith: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 with: arg7 with: arg8 with: arg9 [

	<primitive: 198>
	| deactivator result process complete wasMeta |
	process := Processor activeProcess.
	process isMeta ifTrue: [
		^ self
			  trapwith: arg1
			  with: arg2
			  with: arg3
			  with: arg4
			  with: arg5
			  with: arg6
			  with: arg7
			  with: arg8
			  with: arg9 ].

	deactivator := #deactivator.
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: #(  ).
	process shiftLevelDown.
	wasMeta := false.

	result := self
		          trapwith: arg1
		          with: arg2
		          with: arg3
		          with: arg4
		          with: arg5
		          with: arg6
		          with: arg7
		          with: arg8
		          with: arg9.

	process shiftLevelUp.
	wasMeta := true.
	#handler aboutToReturnWithReceiver: self arguments: #(  ).
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: #(  )
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false.

	complete := true.

	^ result
]

{ #category : #'as yet unclassified' }
MpMethodProxyPrototypeFactory class >> trapwith: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 with: arg7 with: arg8 with: arg9 with: arg10 [

	<primitive: 198>
	| deactivator result process complete wasMeta |
	process := Processor activeProcess.
	process isMeta ifTrue: [
		^ self
			  trapwith: arg1
			  with: arg2
			  with: arg3
			  with: arg4
			  with: arg5
			  with: arg6
			  with: arg7
			  with: arg8
			  with: arg9
			  with: arg10 ].

	deactivator := #deactivator.
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: #(  ).
	process shiftLevelDown.
	wasMeta := false.

	result := self
		          trapwith: arg1
		          with: arg2
		          with: arg3
		          with: arg4
		          with: arg5
		          with: arg6
		          with: arg7
		          with: arg8
		          with: arg9
		          with: arg10.

	process shiftLevelUp.
	wasMeta := true.
	#handler aboutToReturnWithReceiver: self arguments: #(  ).
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: #(  )
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false.

	complete := true.

	^ result
]

{ #category : #'as yet unclassified' }
MpMethodProxyPrototypeFactory class >> trapwith: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 with: arg7 with: arg8 with: arg9 with: arg10 with: arg11 [

	<primitive: 198>
	| deactivator result process complete wasMeta |
	process := Processor activeProcess.
	process isMeta ifTrue: [
		^ self
			  trapwith: arg1
			  with: arg2
			  with: arg3
			  with: arg4
			  with: arg5
			  with: arg6
			  with: arg7
			  with: arg8
			  with: arg9
			  with: arg10
			  with: arg11 ].

	deactivator := #deactivator.
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: #(  ).
	process shiftLevelDown.
	wasMeta := false.

	result := self
		          trapwith: arg1
		          with: arg2
		          with: arg3
		          with: arg4
		          with: arg5
		          with: arg6
		          with: arg7
		          with: arg8
		          with: arg9
		          with: arg10
		          with: arg11.

	process shiftLevelUp.
	wasMeta := true.
	#handler aboutToReturnWithReceiver: self arguments: #(  ).
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: #(  )
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false.

	complete := true.

	^ result
]

{ #category : #'as yet unclassified' }
MpMethodProxyPrototypeFactory class >> trapwith: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 with: arg7 with: arg8 with: arg9 with: arg10 with: arg11 with: arg12 [

	<primitive: 198>
	| deactivator result process complete wasMeta |
	process := Processor activeProcess.
	process isMeta ifTrue: [
		^ self
			  trapwith: arg1
			  with: arg2
			  with: arg3
			  with: arg4
			  with: arg5
			  with: arg6
			  with: arg7
			  with: arg8
			  with: arg9
			  with: arg10
			  with: arg11
			  with: arg12 ].

	deactivator := #deactivator.
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: #(  ).
	process shiftLevelDown.
	wasMeta := false.

	result := self
		          trapwith: arg1
		          with: arg2
		          with: arg3
		          with: arg4
		          with: arg5
		          with: arg6
		          with: arg7
		          with: arg8
		          with: arg9
		          with: arg10
		          with: arg11
		          with: arg12.

	process shiftLevelUp.
	wasMeta := true.
	#handler aboutToReturnWithReceiver: self arguments: #(  ).
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: #(  )
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false.

	complete := true.

	^ result
]

{ #category : #'as yet unclassified' }
MpMethodProxyPrototypeFactory class >> trapwith: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 with: arg7 with: arg8 with: arg9 with: arg10 with: arg11 with: arg12 with: arg13 [

	<primitive: 198>
	| deactivator result process complete wasMeta |
	process := Processor activeProcess.
	process isMeta ifTrue: [
		^ self
			  trapwith: arg1
			  with: arg2
			  with: arg3
			  with: arg4
			  with: arg5
			  with: arg6
			  with: arg7
			  with: arg8
			  with: arg9
			  with: arg10
			  with: arg11
			  with: arg12
			  with: arg13 ].

	deactivator := #deactivator.
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: #(  ).
	process shiftLevelDown.
	wasMeta := false.

	result := self
		          trapwith: arg1
		          with: arg2
		          with: arg3
		          with: arg4
		          with: arg5
		          with: arg6
		          with: arg7
		          with: arg8
		          with: arg9
		          with: arg10
		          with: arg11
		          with: arg12
		          with: arg13.

	process shiftLevelUp.
	wasMeta := true.
	#handler aboutToReturnWithReceiver: self arguments: #(  ).
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: #(  )
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false.

	complete := true.

	^ result
]

{ #category : #'as yet unclassified' }
MpMethodProxyPrototypeFactory class >> trapwith: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 with: arg7 with: arg8 with: arg9 with: arg10 with: arg11 with: arg12 with: arg13 with: arg14 [

	<primitive: 198>
	| deactivator result process complete wasMeta |
	process := Processor activeProcess.
	process isMeta ifTrue: [
		^ self
			  trapwith: arg1
			  with: arg2
			  with: arg3
			  with: arg4
			  with: arg5
			  with: arg6
			  with: arg7
			  with: arg8
			  with: arg9
			  with: arg10
			  with: arg11
			  with: arg12
			  with: arg13
			  with: arg14 ].

	deactivator := #deactivator.
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: #(  ).
	process shiftLevelDown.
	wasMeta := false.

	result := self
		          trapwith: arg1
		          with: arg2
		          with: arg3
		          with: arg4
		          with: arg5
		          with: arg6
		          with: arg7
		          with: arg8
		          with: arg9
		          with: arg10
		          with: arg11
		          with: arg12
		          with: arg13
		          with: arg14.

	process shiftLevelUp.
	wasMeta := true.
	#handler aboutToReturnWithReceiver: self arguments: #(  ).
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: #(  )
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false.

	complete := true.

	^ result
]

{ #category : #'as yet unclassified' }
MpMethodProxyPrototypeFactory class >> trapwith: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 with: arg7 with: arg8 with: arg9 with: arg10 with: arg11 with: arg12 with: arg13 with: arg14 with: arg15 [

	<primitive: 198>
	| deactivator result process complete wasMeta |
	process := Processor activeProcess.
	process isMeta ifTrue: [
		^ self
			  trapwith: arg1
			  with: arg2
			  with: arg3
			  with: arg4
			  with: arg5
			  with: arg6
			  with: arg7
			  with: arg8
			  with: arg9
			  with: arg10
			  with: arg11
			  with: arg12
			  with: arg13
			  with: arg14
			  with: arg15 ].

	deactivator := #deactivator.
	process shiftLevelUp.
	wasMeta := true.
	#handler beforeExecutionWithReceiver: self arguments: #(  ).
	process shiftLevelDown.
	wasMeta := false.

	result := self
		          trapwith: arg1
		          with: arg2
		          with: arg3
		          with: arg4
		          with: arg5
		          with: arg6
		          with: arg7
		          with: arg8
		          with: arg9
		          with: arg10
		          with: arg11
		          with: arg12
		          with: arg13
		          with: arg14
		          with: arg15.

	process shiftLevelUp.
	wasMeta := true.
	#handler aboutToReturnWithReceiver: self arguments: #(  ).
	result := #handler
		          afterExecutionWithReceiver: self
		          arguments: #(  )
		          returnValue: result.
	process shiftLevelDown.
	wasMeta := false.

	complete := true.

	^ result
]
