Class {
	#name : #PMAServerController,
	#superclass : #PMAConnectionController,
	#instVars : [
		'socketDict',
		'connectionSubprocesses',
		'uidDict'
	],
	#category : #'ProjectManagementApplication-Control'
}

{ #category : #accessing }
PMAServerController class >> globalName [
	^ #PMAServer
]

{ #category : #accessing }
PMAServerController >> clientCount [
	^ socketDict ifNil: [ 0 ] ifNotNil: [ socketDict size ]
]

{ #category : #api }
PMAServerController >> fireClient: id [
	(self isClientOnline: id) ifTrue: [ 
		(socketDict at: id)
			sendMessage: (PMAMessage commandCode: CMD_FIRED);
			close.
		socketDict removeKey: id.
	].
	uidDict removeKey: (uidDict keyAtValue: id)
]

{ #category : #private }
PMAServerController >> handleMessage: message fromId: id [
	| socket cmd arg |
	message ifNil: [ ^ self ].
	(self isClientOnline: id) ifFalse: [ ^ self ].
	socket := socketDict at: id.
	cmd := message commandCode.
	arg := message argument.
	
	cmd = CMD_CLIENT_CLOSED ifTrue: [ 
		socket close.
		socketDict removeKey: id.
		announcer announce: (PMAClientConnectionClosedAnnouncement withId: id).
		^ self
	].
	cmd = CMD_SEND_CHAT_MESSAGE  ifTrue: [ 
		announcer announce: (PMANewMessageAnnouncement withMessage: arg senderId: id).
		^ self
	].
	cmd = CMD_REQUEST_EMPLOYEE_LIST ifTrue: [ 
		socket sendMessage: (PMAMessage argument: PMAProjectDB employees asArray).
		^ self
	].
	cmd = CMD_REQUEST_POST_LIST ifTrue: [ 
		socket sendMessage: (PMAMessage argument: PMAProjectDB posts asArray).
		^ self
	].
	cmd = CMD_REQUEST_TASK_LIST ifTrue: [ | tasks |
		tasks := (PMAProjectDB tasksOfEmployeeWithId: id) asArray.
		socket sendMessage: (PMAMessage argument: tasks).
		^ self
	].
	cmd = CMD_REQUEST_PROJECT_NAME ifTrue: [ 
		socket sendMessage: (PMAMessage argument: (parameters at: #projectname)).
		^ self
	].
	cmd = CMD_TASK_COMPLETED ifTrue: [ 
		announcer announce: (PMATaskCompletedAnnouncement task: arg).
		^ self
	].
	cmd = CMD_LEFT_FROM_PROJECT ifTrue: [ 
		socket close.
		socketDict removeKey: id.
		uidDict removeKey: (uidDict keyAtValue: id).
		announcer announce: (PMAClientLeftAnnouncement withId: id).
		^ self
	].
	cmd = 'template_for_other_commands' ifTrue: [ 
		.
		^ self
	].
	
	('PMAServer catched an unknown message from id: {1} (commandCode: {2} argument: {3})' format: {id. cmd. arg}) traceCr.
]

{ #category : #initialization }
PMAServerController >> initializeConnectionProcess [
	socketDict := Dictionary new.
	connectionSubprocesses := Dictionary new.
	
	connectionProcess := [ 
		uidDict := parameters at: #uids ifAbsentPut: [ Dictionary new ].
		messageProcess resume.
		
		[  ] whileNil: [ | socket subprocess |
			socket := PMASocket waitForIncomingConnectionOnPort: (parameters at: #port).
			subprocess := [ | uid employee auth |
				employee := nil.
				uid := UUID fromString: socket waitForMessageAndConfirm argument.
				uid isNilUUID ifTrue: [ | name postId posts | "<- пустой uid - флаг первого подключения"
					auth := true.
					name := socket waitForMessageAndConfirm argument.
					socket sendMessageAndWaitForConfirm: (PMAMessage argument: (parameters at: #projectname)).
					posts := PMAProjectDB posts reject: [ :p | p postName = 'Руководитель' ].
					socket sendMessageAndWaitForConfirm: (PMAMessage argument: posts).
					postId := socket waitForMessageAndConfirm argument.
					(employee := PMAEmployee new)
						fullName: name;
						postId: postId.
					PMAProjectDB insertEmployee: employee.
					uid := UUID new.
					uidDict add: uid -> employee id.
					socket
						sendMessageAndWaitForConfirm: (PMAMessage argument: uid asString);
						sendMessageAndWaitForConfirm: (PMAMessage argument: PMAProjectDB tasks asArray)
				]
				ifFalse: [ 
					auth := uidDict includesKey: uid.
					socket sendMessageAndWaitForConfirm: (PMAMessage argument: auth).
					auth ifTrue: [ 
						employee := PMAProjectDB employeeWithId: (uidDict at: uid).
						socket
							sendMessageAndWaitForConfirm: (PMAMessage argument: (parameters at: #projectname));
							sendMessageAndWaitForConfirm: (PMAMessage argument: (PMAProjectDB postOfEmployee: employee));
							sendMessageAndWaitForConfirm: (PMAMessage argument: PMAProjectDB tasks asArray)
					]
				].
				auth ifTrue: [ 
					connectionSubprocesses removeKey: socket.
					socketDict add: employee id -> socket.
					announcer announce: (PMANewConnectionAnnouncement withEmployee: employee).
				]
			] newProcess.
			connectionSubprocesses add: socket -> subprocess.
			subprocess
				name: ('PMA connection subprocess #{1} (server)' format: {connectionSubprocesses size});
				resume.
			PMApp shortWait
		]
	] newProcess.
	connectionProcess name: 'PMA connection process (server)'
]

{ #category : #initialization }
PMAServerController >> initializeMessageProcess [
	messageProcess := [ 
		[  ] whileNil: [ 
			socketDict keysAndValuesDo: [ :id :socket |
				[ socket isMessageAvailable ] whileTrue: [ | message |
					message := socket waitForMessage.
					self handleMessage: message fromId: id
				].
				PMApp shortWait
			].
			PMApp shortWait
		]
	] newProcess.
	messageProcess name: 'PMA message process (server)'
]

{ #category : #testing }
PMAServerController >> isClientOnline: id [
	^ socketDict includesKey: id
]

{ #category : #private }
PMAServerController >> notify: notificationCommand clientId: id [
	self notify: notificationCommand clientId: id withArgument: nil
]

{ #category : #private }
PMAServerController >> notify: notificationCommand clientId: id withArgument: argument [
	(self isClientOnline: id) ifFalse: [ ^ self ].
	(socketDict at: id) sendMessage: (PMAMessage commandCode: notificationCommand argument: argument)
]

{ #category : #api }
PMAServerController >> notifyPostChanged: newPost clientId: id [
	self notify: CMD_POST_CHANGED clientId: id
]

{ #category : #api }
PMAServerController >> notifyProjectClosed [
	| message |
	message := PMAMessage commandCode: CMD_PROJECT_CLOSED.
	socketDict valuesDo: [ :socket | socket sendMessage: message ].
	uidDict removeAll
]

{ #category : #api }
PMAServerController >> notifyProjectNameChanged: newName [
	| message |
	message := PMAMessage commandCode: CMD_PROJECT_NAME_CHANGED argument: newName.
	socketDict valuesDo: [ :socket | socket sendMessage: message ]
]

{ #category : #api }
PMAServerController >> notifyTaskAdded: aPMATask clientId: id [
	self notify: CMD_TASK_ADDED clientId: id withArgument: aPMATask
]

{ #category : #api }
PMAServerController >> notifyTaskChanged: aPMATask clientId: id [
	self notify: CMD_TASK_CHANGED clientId: id withArgument: aPMATask
]

{ #category : #api }
PMAServerController >> notifyTaskRemoved: aPMATask clientId: id [
	self notify: CMD_TASK_REMOVED clientId: id withArgument: aPMATask
]

{ #category : #api }
PMAServerController >> sendChatMessage: messageString toId: id [
	| message |
	(self isClientOnline: id) ifFalse: [ ^ self ].
	message := PMAMessage commandCode: CMD_SEND_CHAT_MESSAGE argument: messageString.
	(socketDict at: id) sendMessage: message
]

{ #category : #api }
PMAServerController >> sendChatMessageToAll: messageString [
	| message |
	message := PMAMessage commandCode: CMD_SEND_CHAT_MESSAGE argument: messageString.
	socketDict valuesDo: [ :socket | socket sendMessage: message	]
]

{ #category : #api }
PMAServerController >> sendChatMessageToAll: messageString fromId: clientId [
	| message |
	message := PMAMessage commandCode: CMD_SEND_CHAT_MESSAGE argument: messageString.
	socketDict keysAndValuesDo: [ :id :socket | 
		clientId = id ifFalse: [ 
			socket sendMessage: message
		]
	]
]

{ #category : #api }
PMAServerController >> stop [
	super stop.
	connectionSubprocesses ifNotNil: [
		connectionSubprocesses
		keysAndValuesDo: [ :socket :process |
			process terminate.
			socket close
		];
		removeAll.
	].
	socketDict ifNil: [ ^ self ].
	socketDict
		valuesDo: [ :socket |
			[ socket sendMessage: (PMAMessage commandCode: CMD_SERVER_CLOSED) ]
				on: PrimitiveFailed do: [ 'client is already closed - ignore' ].
			socket close
		];
		removeAll
]
