"
I'm the responsible of executing some instrumentation for a method proxy.
I implement the main hooks that are called when a method is executed or returns.
By default, I do nothing. Override my hooks to perform some action before/after.

The main API is composed of three methods: 
- `beforeExecutionWithReceiver: anObject arguments: anArrayOfObjects`: called before the wrapped method gets invoked. It receives as argument the actual receiver and arguments of the trapped message send.
- `aboutToReturnWithReceiver: anObject arguments: arguments`: called before the wrapped method exits because of a stack unwind that *passes through* this method. This happens in the case of non-local returns and exceptions.
- `afterExecutionWithReceiver: anObject arguments: anArrayOfObjects returnValue: aReturnValue`: called before the wraped method exists on a normal return with a return value. This hook allows doing something after normal execution happened, act on the return value, and change the return values of methods. The return value of the trapped call is sent as argument. The proxy will return the value returned by this method.

Moreover, for cases when this is not required, two higher-level hooks are proposed in and defined in terms of the ones above.
- `beforeMethod`: called before the method gets invoked. Just a simpler version of `beforeExecutionWithReceiver: anObject arguments: anArrayOfObjects`.
- `afterMethod`: called before the method returns, either by normal or abnormal execution. It does not allow any action on the return value.
"
Class {
	#name : 'MpHandler',
	#superclass : 'Object',
	#category : 'MethodProxies',
	#package : 'MethodProxies'
}

{ #category : 'evaluating - excepction or non local return' }
MpHandler >> aboutToReturnWithReceiver: receiver arguments: arguments [

    ^ self afterExecutionWithReceiver: receiver arguments: arguments returnValue: nil
]

{ #category : 'evaluating' }
MpHandler >> afterExecutionWithReceiver: anObject arguments: anArrayOfObjects returnValue: returnValue [
    "This is the method that you need to subclass if you want to execute the after method."

    "IMPORTANT This method needs to ALWAYS return the object that the proxied method should return."
    "This object is normally the argument `returnValue`; or something else if you want to change the returned object."

    self afterMethod.
    ^ returnValue
]

{ #category : 'evaluating' }
MpHandler >> afterMethod [

    
]

{ #category : 'evaluating' }
MpHandler >> beforeExecutionWithReceiver: anObject arguments: anArrayOfObjects [

    self beforeMethod
]

{ #category : 'evaluating' }
MpHandler >> beforeMethod [

    
]
