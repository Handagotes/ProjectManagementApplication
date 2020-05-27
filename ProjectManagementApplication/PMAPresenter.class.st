Class {
	#name : #PMAPresenter,
	#superclass : #ComposablePresenter,
	#instVars : [
		'menu',
		'chatText',
		'messageTextInput',
		'sendButton',
		'tasksDataTable',
		'taskDoneButton',
		'statusLabel',
		'launchParameters'
	],
	#category : #'ProjectManagementApplication-Boundary'
}

{ #category : #api }
PMAPresenter class >> open: launchParameters [
	^ self new
		launchParameters: launchParameters;
		openWithSpec
]

{ #category : #adding }
PMAPresenter >> addChatMessage: messageString [
	chatText
		text: (chatText text append: messageString; append: String crlf; yourself);
		scrollValue: (chatText scrollValue + (0 @ chatText text lineCount))
]

{ #category : #accessing }
PMAPresenter >> chatText [
	^ chatText
]

{ #category : #api }
PMAPresenter >> extent [
	^ 1000 @ 500
]

{ #category : #initialization }
PMAPresenter >> initializeAnnouncementListeners [
	self subclassResponsibility
]

{ #category : #initialization }
PMAPresenter >> initializeChat [
	| inputHistory current last |
	inputHistory := OrderedCollection new.
	current := nil.
	last := nil.
	
	sendButton action: [ | text |
		text := messageTextInput text.
		(text isNotNil and: [ text isNotEmpty ]) ifTrue: [ 
			inputHistory remove: text ifAbsent: [  ].
			inputHistory add: text.
			current := nil.
			self onSendButtonClick: text.
			messageTextInput text: String empty
		]
	].
	
	messageTextInput
		bindKeyCombination: Character cr toAction: [ 
			sendButton enabled ifTrue: [ 
				sendButton performAction
			]
		];
		bindKeyCombination: Character arrowUp toAction: [ 
			inputHistory size isZero ifFalse: [ 
				current ifNil: [ | text |
					current := inputHistory size.
					text := messageTextInput text.
					(text isNotNil and: [ text isNotEmpty ]) ifTrue: [ 
						last := text
					]
				]
				ifNotNil: [
					current ~= 1 ifTrue: [ 
						current := current - 1
					]
				].
				messageTextInput
					text: (inputHistory at: current);
					selectAll
			]
		];
		bindKeyCombination: Character arrowDown toAction: [ 
			current ifNotNil: [ 
				current < inputHistory size ifTrue: [ 
					current := current + 1.
					messageTextInput text: (inputHistory at: current)
				]
				ifFalse: [ 
					current := nil.
					messageTextInput
						text: last;
						selectAll
				]
			]
		].
]

{ #category : #initialization }
PMAPresenter >> initializePresenter [
	taskDoneButton action: [ self onTaskDoneButtonClick ].
	self
		initializeChat;
		whenBuiltDo: [ 
			self initializeAnnouncementListeners.
			self window whenClosedDo: [ self onClose ].
			self onOpen
		]
]

{ #category : #initialization }
PMAPresenter >> initializeWidgets [
	menu := self mainMenu.
	menu applyTo: self.
	
	chatText := self newText.
	messageTextInput := self newTextInput.
	sendButton := self newButton.
	tasksDataTable := self newDataTable.
	taskDoneButton := self newButton.
	statusLabel := self newLabel.
	
	chatText
		disable;
		autoAccept: true;
		text: Text new.
	messageTextInput
		text: String empty;
		autoAccept: true.
	sendButton
		label: 'Отправить';
		disable.
	taskDoneButton
		label: 'Выполнено';
		disable.
	statusLabel label: 'Статус'.
	
	self focusOrder
		add: chatText;
		add: messageTextInput;
		add: sendButton;
		add: tasksDataTable;
		add: taskDoneButton.
	
	self aboutText: ('{1}
Автор -  Данил Захаров, г. Нижневартовск, НВГУ
Версия -  {2}
Контакт: danilzakharovm@yandex.ru
2019 -  2020' format: {PMApp appName. PMApp version}).
]

{ #category : #accessing }
PMAPresenter >> launchParameters [
	^ launchParameters
]

{ #category : #private }
PMAPresenter >> launchParameters: anObject [
	launchParameters := anObject
]

{ #category : #private }
PMAPresenter >> mainMenu [
	^ MenuPresenter new addGroup: [ :group |
		group addItem: [ :item |
			item
				name: 'Проект';
				subMenu: self subMenu
		]
	]
]

{ #category : #accessing }
PMAPresenter >> menu [
	^ menu
]

{ #category : #accessing }
PMAPresenter >> messageTextInput [
	^ messageTextInput
]

{ #category : #private }
PMAPresenter >> onClose [
	self subclassResponsibility
]

{ #category : #private }
PMAPresenter >> onOpen [
	self subclassResponsibility
]

{ #category : #private }
PMAPresenter >> onSendButtonClick: messageString [
	self subclassResponsibility
]

{ #category : #private }
PMAPresenter >> onTaskDoneButtonClick [
	self subclassResponsibility
]

{ #category : #accessing }
PMAPresenter >> projectName [
	self subclassResponsibility
]

{ #category : #api }
PMAPresenter >> selectedTask [
	| table i |
	table := tasksDataTable widget.
	i := table selectedRowIndex.
	^ table dataSource elements at: i ifAbsent: [ nil ]
]

{ #category : #accessing }
PMAPresenter >> sendButton [
	^ sendButton
]

{ #category : #accessing }
PMAPresenter >> statusLabel [
	^ statusLabel
]

{ #category : #private }
PMAPresenter >> subMenu [
	self subclassResponsibility
]

{ #category : #accessing }
PMAPresenter >> taskDoneButton [
	^ taskDoneButton
]

{ #category : #accessing }
PMAPresenter >> tasks [
	self subclassResponsibility
]

{ #category : #accessing }
PMAPresenter >> tasksDataTable [
	^ tasksDataTable
]

{ #category : #api }
PMAPresenter >> title [
	| projectName |
	(projectName := self projectName) ifNil: [ ^ PMApp appName ].
	^ '{1} - {2}' format: { PMApp appName. projectName }
	
]

{ #category : #private }
PMAPresenter >> titleForEmployeeName: name postName: postName [
	^ '{1} ({2})' format: { name. postName }
]

{ #category : #private }
PMAPresenter >> updateStatusLabel [
	self subclassResponsibility
]

{ #category : #private }
PMAPresenter >> updateTaskTable [
	| dataSource tasks |
	tasks := self tasks.
	(dataSource := tasksDataTable widget dataSource) ifNil: [ 
		(dataSource := PMATasksDataSource withTasks: tasks)
			addColumnsTo: tasksDataTable widget
	]
	ifNotNil: [
		dataSource elements: tasks
	].
	tasksDataTable widget dataSource: dataSource
]
