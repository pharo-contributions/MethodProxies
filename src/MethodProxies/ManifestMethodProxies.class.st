"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestMethodProxies',
	#superclass : 'PackageManifest',
	#category : 'MethodProxies-Manifest',
	#package : 'MethodProxies',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestMethodProxies class >> ruleStringConcatenationRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGPackageDefinition #(#MethodProxies)) #'2024-10-25T11:11:43.630624+02:00') )
]
