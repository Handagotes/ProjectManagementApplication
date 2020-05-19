Class {
	#name : #PMAConnectionController,
	#superclass : #PMASingleton,
	#instVars : [
		'connectionProcess',
		'messageProcess',
		'announcer',
		'parameters',
		'CMD_CLIENT_CLOSED',
		'CMD_SERVER_CLOSED',
		'CMD_SEND_CHAT_MESSAGE',
		'CMD_PROJECT_NAME_CHANGED',
		'CMD_FIRED',
		'CMD_TASK_ADDED',
		'CMD_TASK_REMOVED',
		'CMD_TASK_COMPLETED',
		'CMD_TASK_CHANGED',
		'CMD_POST_CHANGED',
		'CMD_REQUEST_EMPLOYEE_LIST',
		'CMD_REQUEST_POST_LIST',
		'CMD_REQUEST_TASK_LIST',
		'CMD_REQUEST_PROJECT_NAME',
		'CMD_PROJECT_CLOSED',
		'CMD_LEFT_FROM_PROJECT'
	],
	#category : #'ProjectManagementApplication-Control'
}

{ #category : #removing }
PMAConnectionController class >> remove [
	self instance ifNotNil: [ self instance stop ].
	super remove
]

{ #category : #initialization }
PMAConnectionController >> initialize [
	CMD_CLIENT_CLOSED := 1.
	CMD_SERVER_CLOSED := 2.
	CMD_SEND_CHAT_MESSAGE := 3.
	CMD_PROJECT_NAME_CHANGED := 4.
	CMD_FIRED := 5.
	CMD_TASK_ADDED := 6.
	CMD_TASK_REMOVED := 7.
	CMD_TASK_COMPLETED := 8.
	CMD_TASK_CHANGED := 9.
	CMD_POST_CHANGED := 10.
	CMD_REQUEST_EMPLOYEE_LIST := 11.
	CMD_REQUEST_POST_LIST := 12.
	CMD_REQUEST_TASK_LIST := 13.
	CMD_REQUEST_PROJECT_NAME := 14.
	CMD_PROJECT_CLOSED := 15.
	CMD_LEFT_FROM_PROJECT := 16.
	announcer := Announcer new
]

{ #category : #initialization }
PMAConnectionController >> initializeConnectionProcess [
	self subclassResponsibility
]

{ #category : #initialization }
PMAConnectionController >> initializeMessageProcess [
	self subclassResponsibility
]

{ #category : #enumerating }
PMAConnectionController >> messageSafeDo: aBlock [
	| result |
	messageProcess isSuspended ifTrue: [ ^ aBlock value ].
	messageProcess suspend.
	result := aBlock value.
	messageProcess resume.
	^ result
]

{ #category : #api }
PMAConnectionController >> startWithParameters: params [
	connectionProcess ifNotNil: [ ^ self ].
	messageProcess ifNotNil: [ ^ self ].
	self
		initializeConnectionProcess;
		initializeMessageProcess.
	parameters := params.
	connectionProcess resume
]

{ #category : #api }
PMAConnectionController >> stop [
	announcer subscriptions reset.
	messageProcess ifNotNil: [ 
		messageProcess terminate.
		messageProcess := nil.
	].
	connectionProcess ifNotNil: [ 
		connectionProcess terminate.
		connectionProcess := nil.
	]
]

{ #category : #announcing }
PMAConnectionController >> when: announcement do: block [
	announcer when: announcement do: block
]
