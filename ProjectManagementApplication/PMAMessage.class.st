Class {
	#name : #PMAMessage,
	#superclass : #Object,
	#instVars : [
		'commandCode',
		'argument'
	],
	#category : #'ProjectManagementApplication-Util'
}

{ #category : #'instance creation' }
PMAMessage class >> argument: argument [
	^ self
		commandCode: 0
		argument: argument
]

{ #category : #'instance creation' }
PMAMessage class >> commandCode: commandCode [
	^ self
		commandCode: commandCode
		argument: nil
]

{ #category : #'instance creation' }
PMAMessage class >> commandCode: commandCode argument: argument [
	^ self new
		commandCode: commandCode;
		argument: argument;
		yourself
]

{ #category : #'instance creation' }
PMAMessage class >> fromBytes: aByteArray [
	| argString arg |
	argString := aByteArray allButFirst asWideString.
	[ arg := Smalltalk compiler evaluate: argString ] on: Error do: [ :e |
		('Invalid argument for PMAMessage "{1}". Error: "{2}".' format: { argString. e messageText }) traceCr.
		^ nil
	].
	^ self new
		commandCode: aByteArray first;
		argument: arg;
		yourself
]

{ #category : #accessing }
PMAMessage >> argument [
	^ argument
]

{ #category : #accessing }
PMAMessage >> argument: anObject [
	argument := anObject
]

{ #category : #accessing }
PMAMessage >> commandCode [
	^ commandCode
]

{ #category : #accessing }
PMAMessage >> commandCode: aByte [
	commandCode := aByte
]

{ #category : #converting }
PMAMessage >> toBytes [
	^ (ByteArray with: commandCode) ,
		argument storeString asWideString asByteArray
]
