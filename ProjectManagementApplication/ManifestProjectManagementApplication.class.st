"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestProjectManagementApplication,
	#superclass : #PackageManifest,
	#category : #'ProjectManagementApplication-Manifest'
}

{ #category : #'code-critics' }
ManifestProjectManagementApplication class >> ruleRBLongMethodsRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#PMAClientController #initializeConnectionProcess #false)) #'2020-05-27T18:39:46.428908+05:00') #(#(#RGMethodDefinition #(#PMAServerController #initializeConnectionProcess #false)) #'2020-05-27T18:39:52.157908+05:00') #(#(#RGMethodDefinition #(#PMAClientController #handleMessageFromServer: #false)) #'2020-05-27T18:46:36.487908+05:00') #(#(#RGMethodDefinition #(#PMAServerController #handleMessage:fromId: #false)) #'2020-05-27T18:46:45.505908+05:00') )
]
