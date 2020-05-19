Class {
	#name : #PMAMessage,
	#superclass : #Object,
	#instVars : [
		'commandCode',
		'argument'
	],
	#category : #'ProjectManagementApplication-Util'
}

{ #category : #accessing }
PMAMessage class >> argument: argument [
	^ self
		commandCode: 0
		argument: argument
]

{ #category : #accessing }
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
	^ self new
		commandCode: aByteArray first;
		argument: (Smalltalk compiler evaluate: aByteArray allButFirst asWideString);
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
