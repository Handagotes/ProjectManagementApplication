Class {
	#name : #PMAClientController,
	#superclass : #PMAConnectionController,
	#instVars : [
		'socket'
	],
	#category : #'ProjectManagementApplication-Control'
}

{ #category : #accessing }
PMAClientController class >> globalName [
	^ #PMAClient
]

{ #category : #private }
PMAClientController >> handleMessageFromServer: message [
	| cmd arg |
	message ifNil: [ ^ self ].
	cmd := message commandCode.
	arg := message argument.
	
	cmd = CMD_SERVER_CLOSED ifTrue: [ 
		announcer announce: PMAServerClosedAnnouncement new.
		^ self
	].
	cmd = CMD_PROJECT_CLOSED ifTrue: [ 
		announcer announce: PMAProjectClosedAnnouncement new.
		^ self
	].
	cmd = CMD_SEND_CHAT_MESSAGE  ifTrue: [ 
		announcer announce: (PMANewMessageAnnouncement withMesssage: arg).
		^ self
	].
	cmd = CMD_PROJECT_NAME_CHANGED ifTrue: [ 
		announcer announce: (PMAProjectNameChangedAnnouncement newName: arg).
		^ self
	].
	cmd = CMD_POST_CHANGED ifTrue: [ 
		announcer announce: (PMAPostChangedAnnouncement newPost: arg).
		^ self
	].
	cmd = CMD_TASK_ADDED ifTrue: [ 
		announcer announce: (PMATaskAddedAnnouncement task: arg).
		^ self
	].
	cmd = CMD_TASK_REMOVED ifTrue: [ 
		announcer announce: (PMATaskRemovedAnnouncement task: arg).
		^ self
	].
	cmd = CMD_TASK_CHANGED ifTrue: [ 
		announcer announce: (PMATaskChangedAnnouncement task: arg).
		^ self
	].
	cmd = CMD_FIRED ifTrue: [ 
		announcer announce: PMAClientFiredAnnouncement new.
		^ self
	].
	cmd = 'template_for_other_commands' ifTrue: [ 
		.
		^ self
	].
	
	('PMAClient catched an unknown message from server (commandCode: {1} argument: {2})' format: {cmd. arg}) traceCr.
]

{ #category : #initialization }
PMAClientController >> initializeConnectionProcess [
	connectionProcess := [ | address port uid projectName post |
		address := parameters at: #address.
		port := parameters at: #port.
		uid := parameters at: #uid ifAbsent: [ nil ].
		
		socket := PMASocket waitForConnectionToAddress: address port: port.
		
		uid ifNil: [ | posts name | "uid отсутствует - первое подключение"
			name := parameters at: #name.
			socket
				sendMessageAndWaitForConfirm: (PMAMessage argument: UUID nilUUID asString); "<- пустой uid - флаг первого подключения"
				sendMessageAndWaitForConfirm: (PMAMessage argument: name).
			projectName := socket waitForMessageAndConfirm argument.
			posts := socket waitForMessageAndConfirm argument.
			post := PMASetEmployeePostDialog openNoCancel: name posts: posts.
			socket sendMessageAndWaitForConfirm: (PMAMessage argument: post id).
			uid := UUID fromString: socket waitForMessageAndConfirm argument.
			announcer announce: (PMAConnectedToServerAnnouncement
				withPost: post
				uid: uid
				projectName: projectName
				tasks: Array empty).
			messageProcess resume.
		]
		ifNotNil: [ | auth tasks | "есть uid - передаём серверу"
			socket sendMessageAndWaitForConfirm: (PMAMessage argument: uid asString).
			auth := socket waitForMessageAndConfirm argument.
			
			auth ifTrue: [ "Аутентификация удалась"
				projectName := socket waitForMessageAndConfirm argument.
				post := socket waitForMessageAndConfirm argument.
				tasks := socket waitForMessageAndConfirm argument.
				announcer announce: (PMAConnectedToServerAnnouncement
					withPost: post
					projectName: projectName
					tasks: tasks).
				messageProcess resume.
			]
			ifFalse: [ "Аутентификация не удалась"
				announcer announce: PMAAuthFailedAnnouncement new.
				socket close
			]
		]
	] newProcess.
	connectionProcess name: 'PMA connection process (client)'
]

{ #category : #initialization }
PMAClientController >> initializeMessageProcess [
	messageProcess := [ 
		[ socket ] whileNil: [ PMApp shortWait ].
		[  ] whileNil: [ 
			self handleMessageFromServer: socket waitForMessage.
		]
	] newProcess.
	messageProcess name: 'PMA message process (client)'
]

{ #category : #testing }
PMAClientController >> isConnected [
	^ socket isNotNil and: [ socket isConnected ]
]

{ #category : #private }
PMAClientController >> makeRequest: requestCode [
	^ self messageSafeDo: [ 
		socket sendMessage: (PMAMessage commandCode: requestCode).
		socket waitForMessage argument
	]
]

{ #category : #api }
PMAClientController >> notifyLeftFromProject [
	socket sendMessage: (PMAMessage commandCode: CMD_LEFT_FROM_PROJECT)
]

{ #category : #api }
PMAClientController >> notifyTaskCompleted: aPMATask [
	socket sendMessage: (PMAMessage commandCode: CMD_TASK_COMPLETED argument: aPMATask)
]

{ #category : #api }
PMAClientController >> requestEmployeeList [
	^ self makeRequest: CMD_REQUEST_EMPLOYEE_LIST
]

{ #category : #api }
PMAClientController >> requestPostList [
	^ self makeRequest: CMD_REQUEST_POST_LIST
]

{ #category : #api }
PMAClientController >> requestProjectName [
	^ self makeRequest: CMD_REQUEST_PROJECT_NAME
]

{ #category : #api }
PMAClientController >> requestTaskList [
	^ self makeRequest: CMD_REQUEST_TASK_LIST
]

{ #category : #sending }
PMAClientController >> sendChatMessage: messageString [
	socket sendMessage: (PMAMessage commandCode: CMD_SEND_CHAT_MESSAGE argument: messageString)
]

{ #category : #api }
PMAClientController >> stop [
	super stop.
	socket ifNil: [ ^ self ].
	[ socket sendMessage: (PMAMessage commandCode: CMD_CLIENT_CLOSED) ]
		on: PrimitiveFailed do: [ 'server is already closed - ignore' ].
	socket close
]
