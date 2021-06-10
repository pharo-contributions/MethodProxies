Extension { #name : #CompiledMethod }

{ #category : #'*MethodProxies' }
CompiledMethod >> install [
	"does not nothing. Act as a NullObject for MethodProxy."
	^ self
]

{ #category : #'*MethodProxies' }
CompiledMethod >> isMethodProxy [

	^ false
]

{ #category : #'*MethodProxies' }
CompiledMethod >> uninstall [
	"does not nothing. Act as a NullObject for MethodProxy."
	^ self
]

{ #category : #'*MethodProxies' }
CompiledMethod >> unproxifiedMethod [
	^ self 
]
