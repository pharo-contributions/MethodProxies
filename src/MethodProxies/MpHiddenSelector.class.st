"
I represent a selector that is hidden for the user, used to install hidden methods in method dictionaries.
I'm not a string, so I cannot be typed, avoiding potential conflicts.

I'm used as key of the original method wrapped by proxies, to ensure this wrapped method can be called using myself as selector.
Check my usages during proxy installation.
"
Class {
	#name : #MpHiddenSelector,
	#superclass : #Object,
	#category : #MethodProxies
}

{ #category : #private }
MpHiddenSelector >> flushCache [
	"Tell the virtual machine to remove all entries with this symbol as a selector from its method lookup caches, if it has any.  This 	must be done whenever a method is added, redefined or removed, so that message lookups reflect the revised organization.  c.f. 	Behavior>>flushCache & CompiledMethod>>flushCache.  Essential. See MethodDictionary class comment."

	<primitive: 119>
]
