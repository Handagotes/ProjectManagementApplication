Class {
	#name : #PMANetAddressValidator,
	#superclass : #Object,
	#category : #'ProjectManagementApplication-Util'
}

{ #category : #validation }
PMANetAddressValidator class >> validateAddress: addressString onError: errorBlock [
	[ ^ NetNameResolver addressForName: addressString ] on: NameLookupFailure do: errorBlock
]

{ #category : #validation }
PMANetAddressValidator class >> validatePort: portString onError: errorBlock [
	| port |
	(portString isNotEmpty
		and: [ (portString allSatisfy: [ :c | c isDigit ])
			and: [ (port := portString asInteger) <= 65535 ] ]) ifTrue: [ 
		^ port
	]
	ifFalse: errorBlock
]
