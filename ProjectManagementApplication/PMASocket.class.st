Class {
	#name : #PMASocket,
	#superclass : #Object,
	#instVars : [
		'socketStream'
	],
	#category : #'ProjectManagementApplication-Util'
}

{ #category : #accesing }
PMASocket class >> messageSeparator [
	^ WideString crlf asByteArray
]

{ #category : #'instance creation' }
PMASocket class >> on: socketStream [
	socketStream
		shouldSignal: false;
		noTimeout;
		binary.
	^ self new
		socketStream: socketStream;
		yourself
]

{ #category : #'instance creation' }
PMASocket class >> waitForConnectionToAddress: address port: port [
	| socketStream |
	socketStream := nil.
	[ socketStream ] whileNil: [ 
		[ 
			socketStream := SocketStream openConnectionToHost: address port: port
		] on: ConnectionTimedOut do: [ PMApp shortWait ]
	].
	^ self on: socketStream
]

{ #category : #'instance creation' }
PMASocket class >> waitForIncomingConnectionOnPort: port [
	| socket |
	socket := Socket newTCP.
	socket listenOn: port.
	[ socket isConnected ] whileFalse: [ PMApp shortWait ].
	^ self on: (SocketStream on: socket)
]

{ #category : #'initialize-release' }
PMASocket >> close [
	socketStream close
]

{ #category : #testing }
PMASocket >> isConnected [
	^ socketStream isNotNil and: [ socketStream isConnected ]
]

{ #category : #testing }
PMASocket >> isMessageAvailable [
	^ socketStream isDataAvailable
]

{ #category : #sending }
PMASocket >> sendMessage: aPMAMessage [
	socketStream nextPutAllFlush: aPMAMessage toBytes , self class messageSeparator
]

{ #category : #'data exchanging' }
PMASocket >> sendMessageAndWaitForConfirm: aPMAMessage [
	self sendMessage: aPMAMessage.
	socketStream next
]

{ #category : #accessing }
PMASocket >> socketStream [
	^ socketStream
]

{ #category : #'private - accessing' }
PMASocket >> socketStream: aSocketStream [
	socketStream := aSocketStream
]

{ #category : #waiting }
PMASocket >> waitForMessage [
	| messageBytes |
	[ self isMessageAvailable ] whileFalse: [ PMApp shortWait ].
	messageBytes := socketStream upToAllFixed: self class messageSeparator limit: nil.
	^ PMAMessage fromBytes: messageBytes
]

{ #category : #'data exchanging' }
PMASocket >> waitForMessageAndConfirm [
	| message |
	message := self waitForMessage.
	socketStream
		nextPut: 0;
		flush.
	^ message
]
