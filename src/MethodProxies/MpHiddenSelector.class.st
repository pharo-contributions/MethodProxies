"
I represent a selector that is hidden for the user, used to install hidden methods in method dictionaries.
I'm not a string, so I cannot be typed, avoiding potential conflicts.

I'm used as key of the original method wrapped by proxies, to ensure this wrapped method can be called using myself as selector.
Check my usages during proxy installation.

As a put myself instead of the selector of the roxy method, I now the selector of the proxified method. I need this as someone mmay ask for the selector of the method, for example the code completion engine.
"
Class {
	#name : 'MpHiddenSelector',
	#superclass : 'Object',
	#instVars : [
		'proxifiedSelector'
	],
	#category : 'MethodProxies',
	#package : 'MethodProxies'
}

{ #category : 'faking selector' }
MpHiddenSelector >> asSymbol [

	^ self proxifiedSelector
]

{ #category : 'faking selector' }
MpHiddenSelector >> beginsWith: aString [

	^ proxifiedSelector beginsWith: aString
]

{ #category : 'private' }
MpHiddenSelector >> flushCache [
	"Tell the virtual machine to remove all entries with this symbol as a selector from its method lookup caches, if it has any.  This 	must be done whenever a method is added, redefined or removed, so that message lookups reflect the revised organization.  c.f. 	Behavior>>flushCache & CompiledMethod>>flushCache.  Essential. See MethodDictionary class comment."

	<primitive: 119>
]

{ #category : 'faking selector' }
MpHiddenSelector >> proxifiedSelector [

	^ proxifiedSelector
]

{ #category : 'faking selector' }
MpHiddenSelector >> proxifiedSelector: anObject [

	proxifiedSelector := anObject
]
