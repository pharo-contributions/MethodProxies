"
I am a container object to share models between proxies' handlers.
MpHandlers objects can share the same model, who each know their proxy. 

I therefore hold:
- An optionnal model provided by a client. This model is intented to be called from the handler to perform operations upon method call interception.
- The proxy who owns my handler.

See MpMethodProxyTest>>testSharedHandlerModel
"
Class {
	#name : #MpHandlerModel,
	#superclass : #Object,
	#instVars : [
		'proxy',
		'model'
	],
	#category : #MethodProxies
}

{ #category : #'instance creation' }
MpHandlerModel class >> on: aModel [

	^ self new model: aModel
]

{ #category : #accessing }
MpHandlerModel >> model [

	^ model
]

{ #category : #accessing }
MpHandlerModel >> model: anObject [

	model := anObject
]

{ #category : #accessing }
MpHandlerModel >> proxy [

	^ proxy
]

{ #category : #accessing }
MpHandlerModel >> proxy: anObject [

	proxy := anObject
]
