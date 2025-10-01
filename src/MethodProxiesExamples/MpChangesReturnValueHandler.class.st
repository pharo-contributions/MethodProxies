"
I am an example hanlder that changes the return value of my instrumented method.

"
Class {
	#name : 'MpChangesReturnValueHandler',
	#superclass : 'MpHandler',
	#category : 'MethodProxiesExamples',
	#package : 'MethodProxiesExamples'
}

{ #category : 'evaluating' }
MpChangesReturnValueHandler >> afterExecutionWithReceiver: receiver arguments: arguments returnValue: returnValue [

    ^ 'trapped [' , returnValue asString , ']'
]
