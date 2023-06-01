Class {
	#name : #BaselineOfMethodProxies,
	#superclass : #BaselineOf,
	#category : #BaselineOfMethodProxies
}

{ #category : #baselines }
BaselineOfMethodProxies >> baseline: spec [

	<baseline>
	spec for: #common do: [
		spec
			baseline: #Instrumentation
			with: [ spec
                repository: 'github://pharo-project/pharo' ];
			package: #MethodProxies
			with: [ spec requires: #( #Instrumentation ) ];
			package: #'MethodProxies-Tests'
			with: [ spec requires: #( #MethodProxies ) ];
			package: #MethodProxiesExamples
			with: [ spec requires: #( #MethodProxies ) ];
			package: #'MethodProxiesExamples-Tests'
			with: [ spec requires: #( #MethodProxiesExamples ) ].

		spec
			group: 'Core' with: #( #MethodProxies );
			group: 'All'
			with:
				#( #MethodProxies #'MethodProxies-Tests' #MethodProxiesExamples
				   #'MethodProxiesExamples-Tests' ) ]
]
