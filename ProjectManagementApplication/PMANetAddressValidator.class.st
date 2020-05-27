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
	portString ifEmpty: [ ^ errorBlock value ].
	(portString allSatisfy: [ :c | c isDigit ]) ifFalse: [ ^ errorBlock value ].
	(port := portString asInteger) <= 65535 ifFalse: [ ^ errorBlock value ].
	^ port
]
