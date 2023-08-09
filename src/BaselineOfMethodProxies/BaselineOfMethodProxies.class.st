Class {
	#name : #BaselineOfMethodProxies,
	#superclass : #BaselineOf,
	#category : #BaselineOfMethodProxies
}

{ #category : #baselines }
BaselineOfMethodProxies >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec package: #MethodProxies;
			package: #'MethodProxies-Tests'
			with: [ spec requires: #( #MethodProxies ) ];
			package: #MethodProxiesExamples
			with: [ spec requires: #( #MethodProxies ) ];
			package: #'MethodProxiesExamples-Tests'
			with: [ spec requires: #( #MethodProxiesExamples #'MethodProxies-Tests' ) ].

		spec
			group: 'Core' with: #( #MethodProxies );
			group: 'All'
			with:
				#( #MethodProxies #'MethodProxies-Tests' #MethodProxiesExamples
				   #'MethodProxiesExamples-Tests' ) ].
	spec for: #'pharo11.x' do: [ 
		spec package: #Instrumentation.
		spec
			package: #MethodProxies
			with: [ spec requires: #( Instrumentation ) ] ]
]
