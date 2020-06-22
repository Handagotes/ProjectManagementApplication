Class {
	#name : #PMAManagerSidePresenter,
	#superclass : #PMAPresenter,
	#instVars : [
		'employeeDropList',
		'addTaskButton',
		'editTaskButton',
		'removeTaskButton',
		'manager',
		'managerPost',
		'tasks'
	],
	#category : #'ProjectManagementApplication-Boundary'
}

{ #category : #specs }
PMAManagerSidePresenter class >> defaultSpec [
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
							add: #employeeDropList height: defHeight;
							add: #tasksDataTable;
							newRow: [ :taskRow |
								taskRow
									add: #addTaskButton;
									add: #editTaskButton;
									add: #removeTaskButton;
									add: #taskDoneButton
							] height: defHeight
					]
			];
			add: #statusLabel height: defHeight
	]
]

{ #category : #accessing }
PMAManagerSidePresenter >> addTaskButton [
	^ addTaskButton
]

{ #category : #private }
PMAManagerSidePresenter >> changePostFor: employee newPost: newPost [
	employee postId: newPost id.
	PMAProjectDB updateEmployee: employee.
	PMAServer notifyPostChanged: newPost clientId: employee id
]

{ #category : #accessing }
PMAManagerSidePresenter >> editTaskButton [
	^ editTaskButton
]

{ #category : #accessing }
PMAManagerSidePresenter >> employeeDropList [
	^ employeeDropList
]

{ #category : #private }
PMAManagerSidePresenter >> excludeEmployee: employee [
	PMAProjectDB deleteEmployee: employee.
	PMAServer
		fireClient: employee id;
		sendChatMessageToAll: ('Сотрудник {1} исключен из проекта.' format: employee fullName).
]

{ #category : #initialization }
PMAManagerSidePresenter >> initializeAnnouncementListeners [
	PMAServer
		when: PMANewConnectionAnnouncement do: [ :a | self onNewConnectionAnnouncement: a ];
		when: PMAClientConnectionClosedAnnouncement do: [ :a | self onClientConnectionClosedAnnouncement: a ];
		when: PMANewMessageAnnouncement do: [ :a | self onNewMessageAnnouncement: a ];
		when: PMATaskCompletedAnnouncement do: [ :a | self onTaskCompletedAnnouncement: a ];
		when: PMAClientLeftAnnouncement do: [ :a | self onClientLeftAnnouncement: a ].
]

{ #category : #initialization }
PMAManagerSidePresenter >> initializePresenter [
	super initializePresenter.
	addTaskButton action: [ self onAddTaskButtonClick ].
	editTaskButton action: [ self onEditTaskButtonClick ].
	removeTaskButton action: [ self onRemoveTaskButtonClick ].
	employeeDropList whenSelectedItemChanged: [ self onEmployeeDropListSelectedItemChanged ].
]

{ #category : #initialization }
PMAManagerSidePresenter >> initializeWidgets [
	super initializeWidgets.
	
	employeeDropList := self newDropList.
	addTaskButton := self newButton.
	editTaskButton := self newButton.
	removeTaskButton := self newButton.
	
	employeeDropList displayBlock: [ :e | self titleForEmployee: e ].
	addTaskButton label: 'Добавить задание'.
	editTaskButton label: 'Редактировать'.
	removeTaskButton label: 'Удалить'.
	
	sendButton enable.
	
	self focusOrder: (self focusOrder first: 3).
	self focusOrder
		add: employeeDropList;
		add: tasksDataTable;
		add: addTaskButton;
		add: editTaskButton;
		add: removeTaskButton;
		add: taskDoneButton.
]

{ #category : #accessing }
PMAManagerSidePresenter >> manager [
	^ manager
]

{ #category : #accessing }
PMAManagerSidePresenter >> managerPost [
	^ managerPost
]

{ #category : #private }
PMAManagerSidePresenter >> managerTitle [
	^ self titleForEmployeeName: (launchParameters at: #name) postName: 'Руководитель'
]

{ #category : #private }
PMAManagerSidePresenter >> onAddTaskButtonClick [
	| employee task |
	employee := employeeDropList selectedItem.
	task := PMATask new.
	(PMAEditTaskDialog open: task forEmployee: employee) ifFalse: [ ^ self ].
	PMAProjectDB insertTask: task.
	tasks add: task.
	self updateTaskTable.
	employee id = manager id ifTrue: [ ^ self ].
	PMAServer notifyTaskAdded: task clientId: employee id
]

{ #category : #private }
PMAManagerSidePresenter >> onChangeProjectNameMenuItemClick [
	| oldName newName message |
	oldName := launchParameters at: #projectname.
	(newName := PMATextInputDialog open: 'Название проекта:' default: oldName)
		ifNil: [ ^ self ].
	launchParameters at: #projectname put: newName.
	self updateTitle.
	message := '{1} сменил название проекта с: {2} на: {3}.' format: { 
		self managerTitle.
		oldName.
		newName.
	}.
	self addChatMessage: message.
	PMAServer
		notifyProjectNameChanged: newName;
		sendChatMessageToAll: message
]

{ #category : #private }
PMAManagerSidePresenter >> onClientConnectionClosedAnnouncement: announcement [
	| employee message |
	self updateStatusLabel.
	employee := PMAProjectDB employeeWithId: announcement clientId.
	message := 'Сотрудник {1} вышел из чата.' format: { self titleForEmployee: employee. }.
	self addChatMessage: message.
	PMAServer sendChatMessageToAll: message.
]

{ #category : #private }
PMAManagerSidePresenter >> onClientLeftAnnouncement: announcement [
	| employee message |
	self updateStatusLabel.
	employee := PMAProjectDB employeeWithId: announcement id.
	message := 'Сотрудник {1} покинул проект.' format: { self titleForEmployee: employee. }.
	self addChatMessage: message.
	PMAServer sendChatMessageToAll: message.
	PMAProjectDB deleteEmployee: employee.
	self updateEmployeeDropList
]

{ #category : #private }
PMAManagerSidePresenter >> onClose [
	PMAServer stop.
	PMAProjectDB closeConnection
]

{ #category : #private }
PMAManagerSidePresenter >> onCloseMenuItemClick [
	PMApp close
]

{ #category : #private }
PMAManagerSidePresenter >> onCloseProjectMenuItemClick [
	(PMAYesNoDialog open: 'Вы действительно хотите удалить проект?') ifFalse: [ ^ self ].
	PMAServer notifyProjectClosed.
	PMAProjectDB
		dropTables;
		closeConnection.
	PMApp restartWithReset
]

{ #category : #private }
PMAManagerSidePresenter >> onEditPostsMenuItemClick [
	| changes |
	(changes := PMAEditPostsDialog open: PMAProjectDB posts)
		ifNil: [ ^ self ].
	
	(changes at: #added) do: [ :p |
		PMAProjectDB insertPost: p
	].
	
	(changes at: #removed) do: [ :p |
		(PMAProjectDB employeesWithPost: p) size isZero ifTrue: [ 
			PMAProjectDB deletePost: p
		]
		ifFalse: [ 
			PMAErrorDialog open: ('Должность {1} не удалена, т.к. в проекте есть сотрудники с этой должностью.' format: { p postName })
		]
	].

	(changes at: #changed) do: [ :p |
		p id = managerPost id ifFalse: [ 
			PMAProjectDB updatePost: p.
			(PMAProjectDB employeesWithPost: p) do: [ :e |
				PMAServer notifyPostChanged: p clientId: e id
			]
		]
	].
]

{ #category : #private }
PMAManagerSidePresenter >> onEditTaskButtonClick [
	| employee task |
	employee := employeeDropList selectedItem.
	(task := self selectedTask) ifNil: [ ^ self ].
	(PMAEditTaskDialog open: task forEmployee: employee) ifFalse: [ ^ self ].
	PMAProjectDB updateTask: task.
	tasks reSort.
	self updateTaskTable.
	employee id = manager id ifTrue: [ ^ self ].
	PMAServer notifyTaskChanged: task clientId: employee id
]

{ #category : #private }
PMAManagerSidePresenter >> onEmployeeDropListSelectedItemChanged [
	employeeDropList selectedIndex isZero ifFalse: [ | selectedEmployee |
		tasks := SortedCollection sortBlock: [ :t1 :t2 | t1 startDate < t2 startDate ].
		tasks addAll: (PMAProjectDB tasksOfEmployee: (employeeDropList selectedItem)).
		selectedEmployee := employeeDropList selectedItem.
		taskDoneButton enabled: selectedEmployee id = manager id.
	]
	ifTrue: [ 
		tasks := nil.
		taskDoneButton disable
	].
	self updateTaskTable.
]

{ #category : #private }
PMAManagerSidePresenter >> onNewConnectionAnnouncement: announcement [
	| employee message |
	self
		updateStatusLabel;
		updateEmployeeDropList.
	employee := announcement employee.
	message := 'Сотрудник {1} присоединился к чату.' format: { self titleForEmployee: employee. }.
	self addChatMessage: message.
	PMAServer sendChatMessageToAll: message.
]

{ #category : #private }
PMAManagerSidePresenter >> onNewMessageAnnouncement: announcement [
	| message |
	message := announcement message.
	message traceCr. ('-' repeat: 30) traceCr.
	self addChatMessage: message.
	PMAServer sendChatMessageToAll: message fromId: announcement senderId.
]

{ #category : #private }
PMAManagerSidePresenter >> onOpen [
	| firstLaunch changes |
	self updateStatusLabel.
	firstLaunch := launchParameters at: #firstlaunch.
	firstLaunch ifTrue: [ 
		launchParameters at: #projectname put: (PMATextInputDialog openNoCancel: 'Введите название проекта.')
	].
	
	PMAProjectDB openConnection.
	
	firstLaunch ifFalse: [ 
		manager := launchParameters at: #manager.
		managerPost := launchParameters at: #managerpost.
		^ self
			updateEmployeeDropList;
			updateTaskTable.
	].
	
	(managerPost := PMAPost new)
		postName: 'Руководитель'.
	PMAProjectDB insertPost: managerPost.
	(manager := PMAEmployee new)
		fullName: (launchParameters at: #name);
		postId: managerPost id.
	PMAProjectDB insertEmployee: manager.
	
	launchParameters
		add: #manager -> manager;
		add: #managerpost -> managerPost.
	
	changes := PMAEditPostsDialog openNoCancel.
	(changes at: #added) do: [ :p | PMAProjectDB insertPost: p ].
	
	self
		updateEmployeeDropList;
		updateTaskTable.
	
	PMAServer startWithParameters: launchParameters.
]

{ #category : #private }
PMAManagerSidePresenter >> onRemoveTaskButtonClick [
	| task |
	(task := self selectedTask) ifNil: [ ^ self ].
	PMAProjectDB deleteTask: task.
	tasks remove: task.
	self updateTaskTable.
	task employeeId = manager id ifTrue: [ ^ self ].
	PMAServer notifyTaskRemoved: task clientId: task employeeId
]

{ #category : #private }
PMAManagerSidePresenter >> onSendButtonClick: messageString [
	| message |
	message := '{1}: {2}' format: { self managerTitle. messageString }.
	self addChatMessage: message.
	PMAServer sendChatMessageToAll: message.
]

{ #category : #private }
PMAManagerSidePresenter >> onTaskCompletedAnnouncement: announcement [
	| task employee |
	task := announcement task.
	employee := PMAProjectDB employeeWithId: task employeeId.
	PMAProjectDB updateTask: task.
	employeeDropList selectedItem id = employee id ifFalse: [ ^ self ].
	tasks removeAt: (tasks findFirst: [ :t | t id = task id ]).
	tasks add: task.
	self updateTaskTable
]

{ #category : #private }
PMAManagerSidePresenter >> onTaskDoneButtonClick [
	| task |
	(task := self selectedTask) ifNil: [ ^ self ].
	task isDone ifTrue: [ ^ self ].
	task isDone: true.
	PMAProjectDB updateTask: task.
	self updateTaskTable
]

{ #category : #private }
PMAManagerSidePresenter >> onViewEmployeeListMenuItemClick [
	PMAEditableEmployeeTableViewDialog
		openEmployees: PMAProjectDB employees
		posts: (PMAProjectDB posts reject: [ :p | p postName = 'Руководитель' ])
		managerPresenter: self
]

{ #category : #accessing }
PMAManagerSidePresenter >> projectName [
	^ launchParameters at: #projectname ifAbsent: [ nil ]
]

{ #category : #accessing }
PMAManagerSidePresenter >> removeTaskButton [
	^ removeTaskButton
]

{ #category : #private }
PMAManagerSidePresenter >> subMenu [
	^ MenuPresenter new addGroup: [ :group |
		group
			addItem: [ :item |
				item
					name: 'Изменить название';
					action: [ self onChangeProjectNameMenuItemClick ]
			];
			addItem: [ :item |
				item
					name: 'Изменить список должностей';
					action: [ self onEditPostsMenuItemClick ]
			];
			addItem: [ :item |
				item
					name: 'Просмотр списка сотрудников';
					action: [ self onViewEmployeeListMenuItemClick ]
			];
			addItem: [ :item |
				item
					name: 'Закрыть проект';
					action: [ self onCloseProjectMenuItemClick ]
			];
			addItem: [ :item |
				item
					name: 'Закрыть сервер';
					action: [ self onCloseMenuItemClick ]
			]
	]
]

{ #category : #accessing }
PMAManagerSidePresenter >> tasks [
	^ tasks
]

{ #category : #private }
PMAManagerSidePresenter >> titleForEmployee: employee [
	| postName |
	postName := (PMAProjectDB postOfEmployee: employee) postName.
	^ self titleForEmployeeName: employee fullName postName: postName
]

{ #category : #private }
PMAManagerSidePresenter >> updateEmployeeDropList [
	employeeDropList items: PMAProjectDB employees
]

{ #category : #private }
PMAManagerSidePresenter >> updateStatusLabel [
	statusLabel label: ('Порт: {1}. Количество подключенных пользователей: {2}' format: { 
		launchParameters at: #port.
		PMAServer clientCount
	}).
]
