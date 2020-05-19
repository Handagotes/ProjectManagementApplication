Class {
	#name : #PMAEmployeeSidePresenter,
	#superclass : #PMAPresenter,
	#instVars : [
		'employeeLabel',
		'projectName',
		'tasks'
	],
	#category : #'ProjectManagementApplication-Boundary'
}

{ #category : #specs }
PMAEmployeeSidePresenter class >> defaultSpec [
	| defHeight |
	defHeight := self toolbarHeight.
	^ SpecLayout composed newColumn: [ :column |
		column
			add: #menu height: defHeight;
			newRow: [ :row |
				row
					newColumn: [ :chatColumn |
						chatColumn
							add: #chatText;
							newRow: [ :chatRow |
								chatRow
									add: #messageTextInput;
									add: #sendButton width: 100
							] height: defHeight
					];
					addSplitter;
					newColumn: [ :taskColumn |
						taskColumn
							add: #employeeLabel height: defHeight;
							add: #tasksDataTable;
							newRow: [ :taskRow |
								taskRow
									add: #taskDoneButton width: 175
							] height: defHeight
					]
			];
			add: #statusLabel height: defHeight
	]
]

{ #category : #accessing }
PMAEmployeeSidePresenter >> employeeLabel [
	^ employeeLabel
]

{ #category : #initialization }
PMAEmployeeSidePresenter >> initializeAnnouncementListeners [
	PMAClient
		when: PMAConnectedToServerAnnouncement do: [ :a | self onConnectedToServerAnnouncement: a ];
		when: PMAAuthFailedAnnouncement do: [ :a | self onAuthFailedAnnouncement: a ];
		when: PMAServerClosedAnnouncement do: [ :a | self onServerClosedAnnouncement: a ];
		when: PMAProjectClosedAnnouncement do: [ :a | self onProjectClosedAnnouncement: a ];
		when: PMANewMessageAnnouncement do: [ :a | self onNewMessageAnnouncement: a ];
		when: PMAProjectNameChangedAnnouncement do: [ :a | self onProjectNameChangedAnnouncement: a ];
		when: PMAPostChangedAnnouncement do: [ :a | self onPostChangedAnnouncement: a ];
		when: PMATaskAddedAnnouncement do: [ :a | self onTaskAddedAnnouncement: a ];
		when: PMATaskRemovedAnnouncement do: [ :a | self onTaskRemovedAnnouncement: a ];
		when: PMATaskChangedAnnouncement do: [ :a | self onTaskChangedAnnouncement: a ];
		when: PMAClientFiredAnnouncement do: [ :a | self onClientFiredAnnouncement: a ].
]

{ #category : #initialization }
PMAEmployeeSidePresenter >> initializeWidgets [
	super initializeWidgets.
	employeeLabel := self newLabel.
	employeeLabel label: 'ФИО (Должность)'.
	taskDoneButton enable
]

{ #category : #private }
PMAEmployeeSidePresenter >> onAuthFailedAnnouncement: announcement [
	PMAErrorDialog open: 'Авторизация не удалась. Возможно, вас исключили из проекта или проект был закрыт.'.
	PMApp restartWithReset
]

{ #category : #private }
PMAEmployeeSidePresenter >> onClientFiredAnnouncement: announcement [
	PMAErrorDialog open: 'Вы были исключены из проекта.'.
	PMApp restartWithReset
]

{ #category : #private }
PMAEmployeeSidePresenter >> onClose [
	PMAClient stop
]

{ #category : #private }
PMAEmployeeSidePresenter >> onCloseMenuItemClick [
	PMApp close
]

{ #category : #private }
PMAEmployeeSidePresenter >> onConnectedToServerAnnouncement: announcement [
	launchParameters at: #post put: announcement post.
	announcement uid ifNotNil: [ "<- Первое подключение"
		launchParameters add: #uid -> announcement uid
	].
	self projectName: announcement projectName.
	tasks := SortedCollection sortBlock: [ :t1 :t2 | t1 startDate < t2 startDate ].
	tasks addAll: announcement tasks.
	sendButton enable.
	self
		updateStatusLabel;
		updateEmployeeLabel;
		updateTaskTable
]

{ #category : #private }
PMAEmployeeSidePresenter >> onLeaveProjectMenuItemClick [
	(PMAYesNoDialog open: 'Вы действительно хотите выйти из проекта?') ifFalse: [ ^ self ].
	PMAClient notifyLeftFromProject.
	PMApp restartWithReset
]

{ #category : #private }
PMAEmployeeSidePresenter >> onNewMessageAnnouncement: announcement [
	self addChatMessage: announcement message
]

{ #category : #private }
PMAEmployeeSidePresenter >> onOpen [
	self updateStatusLabel.
	PMAClient startWithParameters: launchParameters
]

{ #category : #private }
PMAEmployeeSidePresenter >> onPostChangedAnnouncement: announcement [
	launchParameters at: #post put: announcement newPost
]

{ #category : #private }
PMAEmployeeSidePresenter >> onProjectClosedAnnouncement: announcement [
	PMAErrorDialog open: 'Проект был закрыт.'.
	PMApp restartWithReset
]

{ #category : #private }
PMAEmployeeSidePresenter >> onProjectNameChangedAnnouncement: announcement [
	self projectName: announcement newName.
]

{ #category : #private }
PMAEmployeeSidePresenter >> onSendButtonClick: messageString [
	| message |
	message := '{1}: {2}' format: { 
		employeeLabel label.
		messageString
	}.
	self addChatMessage: message.
	PMAClient sendChatMessage: message.
]

{ #category : #private }
PMAEmployeeSidePresenter >> onServerClosedAnnouncement: announcement [
	PMAErrorDialog open: 'Сервер был закрыт.'.
	PMApp close
]

{ #category : #private }
PMAEmployeeSidePresenter >> onTaskAddedAnnouncement: announcement [
	| task |
	task := announcement task.
	tasks add: task.
	self
		updateTaskTable;
		addChatMessage: ('Руководитель добавил задачу "{1}" для вас.' format: { task taskName })
]

{ #category : #private }
PMAEmployeeSidePresenter >> onTaskChangedAnnouncement: announcement [
	| task |
	task := announcement task.
	tasks
		removeAt: (tasks findFirst: [ :t | t id = task id ]);
		add: task.
	self
		updateTaskTable;
		addChatMessage: ('Руководитель изменил данные вашей задачи "{1}".' format: { task taskName })
]

{ #category : #private }
PMAEmployeeSidePresenter >> onTaskDoneButtonClick [
	| task |
	(task := self selectedTask) ifNil: [ ^ self ].
	task isDone ifTrue: [ ^ self ].
	task isDone: true.
	PMAClient notifyTaskCompleted: task.
	self updateTaskTable
]

{ #category : #private }
PMAEmployeeSidePresenter >> onTaskRemovedAnnouncement: announcement [
	| task |
	task := announcement task.
	tasks removeAt: (tasks findFirst: [ :t | t id = task id ]).
	self
		updateTaskTable;
		addChatMessage: ('Руководитель удалил вашу задачу "{1}".' format: { task taskName })
]

{ #category : #private }
PMAEmployeeSidePresenter >> onViewEmployeeListMenuItemClick [
	PMAClient isConnected ifFalse: [ ^ self ].
	PMAEmployeeTableViewDialog
		openEmployees: PMAClient requestEmployeeList
		posts: PMAClient requestPostList
]

{ #category : #'private-accessing' }
PMAEmployeeSidePresenter >> projectName [
	^ projectName
]

{ #category : #'private-accessing' }
PMAEmployeeSidePresenter >> projectName: aString [
	projectName := aString.
	self updateTitle
]

{ #category : #private }
PMAEmployeeSidePresenter >> subMenu [
	^ MenuPresenter new addGroup: [ :group |
		group
			addItem: [ :item |
				item
					name: 'Просмотр списка сотрудников';
					action: [ self onViewEmployeeListMenuItemClick ]
			];
			addItem: [ :item |
				item
					name: 'Выйти из проекта';
					action: [ self onLeaveProjectMenuItemClick ]
			];
			addItem: [ :item |
				item
					name: 'Закрыть';
					action: [ self onCloseMenuItemClick ]
			]
	]
]

{ #category : #accessing }
PMAEmployeeSidePresenter >> tasks [
	^ tasks
]

{ #category : #private }
PMAEmployeeSidePresenter >> updateEmployeeLabel [
	| name postName |
	name := launchParameters at: #name.
	postName := (launchParameters at: #post) postName.
	employeeLabel label: (self titleForEmployeeName: name postName: postName)
]

{ #category : #private }
PMAEmployeeSidePresenter >> updateStatusLabel [
	| address fullAddress |
	address := String streamContents: [ :s | (launchParameters at: #address) printOn: s ].
	fullAddress := address , ':' , (launchParameters at: #port) asString.
	statusLabel label: (PMAClient isConnected
		ifFalse: [ 'Подключение к: {1} ...' format: { fullAddress } ]
		ifTrue: [ 'Подключен к: {1}' format: { fullAddress } ])
]
