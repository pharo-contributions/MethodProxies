"
I am a deactivator handler. When an exception or a non local return occurs, I will be executed just like an ensure:
I am executed in the same way that an ensure does
"
Class {
	#name : 'MpDeactivator',
	#superclass : 'Object',
	#instVars : [
		'handler'
	],
	#classVars : [
		'CompleteTempVariableIndex',
		'WasMetaTempVariableIndex'
	],
	#category : 'MethodProxies',
	#package : 'MethodProxies'
}

{ #category : 'class initialization' }
MpDeactivator class >> initialize [

    WasMetaTempVariableIndex := (MpMethodProxy class >> #prototypeTrap) numTemps. "last temp"
    CompleteTempVariableIndex := 2 "always the second temp"
]

{ #category : 'as yet unclassified' }
MpDeactivator class >> withHandler: aMpHandler [

	^ self new
		  handler: aMpHandler;
		  yourself
]

{ #category : 'accessing' }
MpDeactivator >> asContextWithSender: aContext [
	"Inner private support method for evaluation.  Do not use unless you know what you're doing."

	^(Context newForMethod: (MpDeactivator >> #value))
		setSender: aContext
		receiver: self
		method: (MpDeactivator >> #value)
		closure: nil
		startpc: (MpDeactivator >> #value) initialPC;
		privRefresh
]

{ #category : 'accessing' }
MpDeactivator >> handler: aMpHandler [

	handler := aMpHandler
]

{ #category : 'evaluating' }
MpDeactivator >> value [
	
	"Execution handler for the slow path. An exception or a non local return happened during proxy execution"
	| wasMeta trapContext |
	"Jump to the meta level (to avoid meta-recursions) to observe if the handler was in a meta level, marked by the wasMeta flag.
			During the meta-jump call the handler to tell there was an unwind."
	thisProcess shiftLevelUp.
	trapContext := thisContext.
	[ trapContext := trapContext findNextUnwindContextUpTo: nil.
	  trapContext method hasPragmaNamed: #trap ] whileFalse.

	wasMeta := trapContext tempAt: trapContext method numArgs + WasMetaTempVariableIndex.
	handler aboutToReturnWithReceiver: trapContext receiver arguments: trapContext arguments.

	thisProcess shiftLevelDown.
	
	"If the handler was in a meta-state (i.e., the exception or non-local return happened in the handler),
	shift it back to the base level before returning.
	Otherwise, we were already in the base level and we need to do nothing!"
	wasMeta ifTrue: [ thisProcess shiftLevelDown ].

	"Mark execution as complete to avoid double execution of the handler."
	trapContext tempAt: trapContext method numArgs + CompleteTempVariableIndex put: true
]
