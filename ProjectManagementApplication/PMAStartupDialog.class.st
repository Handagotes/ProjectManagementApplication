Class {
	#name : #PMAStartupDialog,
	#superclass : #PMADialog,
	#instVars : [
		'nameLabel',
		'nameTextInput',
		'roleLabel',
		'roleEmployeeRadioButton',
		'roleManagerRadioButton',
		'addressLabel',
		'addressTextInput',
		'startButton',
		'closeButton',
		'roleRadioButtonGroup'
	],
	#category : #'ProjectManagementApplication-Boundary'
}

{ #category : #specs }
PMAStartupDialog class >> defaultSpec [
	^ SpecLayout composed newColumn: [ :column |
			column
				newRow: [ :row | 
					row
						add: #nameLabel width: 125;
						add: #nameTextInput
				];
				newRow: [ :row |
					row
						add: #roleLabel width: 125;
						add: #roleEmployeeRadioButton;
						add: #roleManagerRadioButton
				];
				newRow: [ :row |
					row
						add: #addressLabel width: 125;
						add: #addressTextInput
				];
				newRow: [ :row |
					row
						add: #startButton;
						add: #closeButton
				]
	];
	yourself
]

{ #category : #api }
PMAStartupDialog class >> open [
	^ self openDialog
]

{ #category : #accessing }
PMAStartupDialog >> addressLabel [
	^ addressLabel
]

{ #category : #accessing }
PMAStartupDialog >> addressTextInput [
	^ addressTextInput
]

{ #category : #accessing }
PMAStartupDialog >> closeButton [
	^ closeButton
]

{ #category : #api }
PMAStartupDialog >> extent [
	^ 425 @ 150
]

{ #category : #initialization }
PMAStartupDialog >> initializePresenter [
	roleEmployeeRadioButton activationAction: [ 
		addressLabel label: 'Адрес и порт сервера:'
	].
	
	roleManagerRadioButton activationAction: [ 
		addressLabel label: 'Порт сервера:'
	].
	
	startButton action: [ 
		self onStartButtonClick
	].
	
	closeButton action: [ 
		self closeDialog
	]
]

{ #category : #initialization }
PMAStartupDialog >> initializeWidgets [
	nameLabel := self newLabel.
	nameTextInput := self newTextInput.
	roleLabel := self newLabel.
	roleEmployeeRadioButton := self newRadioButton.
	roleManagerRadioButton := self newRadioButton.
	addressLabel := self newLabel.
	addressTextInput := self newTextInput.
	startButton := self newButton.
	closeButton := self newButton.
	
	nameLabel label: 'ФИО:'.
	nameTextInput autoAccept: true.
	roleLabel label: 'Роль:'.
	roleEmployeeRadioButton label: 'Сотрудник'.
	roleManagerRadioButton label: 'Руководитель'.
	roleRadioButtonGroup := RadioButtonGroup new
		addRadioButton: roleEmployeeRadioButton;
		addRadioButton: roleManagerRadioButton;
		default: roleEmployeeRadioButton;
		yourself.
	addressLabel label: 'Адрес и порт сервера:'.
	addressTextInput autoAccept: true.
	startButton label: 'Начать'.
	closeButton label: 'Закрыть'.
	
	self focusOrder
		add: nameTextInput;
		add: roleEmployeeRadioButton;
		add: roleManagerRadioButton;
		add: addressTextInput;
		add: startButton;
		add: closeButton
]

{ #category : #accessing }
PMAStartupDialog >> nameLabel [
	^ nameLabel
]

{ #category : #accessing }
PMAStartupDialog >> nameTextInput [
	^ nameTextInput
]

{ #category : #private }
PMAStartupDialog >> onStartButtonClick [
	| role name fullAddress address port |
	
	role := roleRadioButtonGroup currentlyActivated label.
	name := nameTextInput text.
	fullAddress := addressTextInput text.
	
	name ifEmpty: [ 
		^ PMAErrorDialog open: 'Поле ФИО должно быть заполнено.'
	].
	
	fullAddress ifEmpty: [ 
		^ PMAErrorDialog open: 'Поле адреса/порта должно быть заполнено.'
	].
	
	fullAddress := fullAddress splitOn: $:.
	
	role = 'Сотрудник' ifTrue: [ 
		address := fullAddress at: 1.
		port := fullAddress at: 2 ifAbsent: [ 
			^ PMAErrorDialog
				open: 'Адрес и порт должны быть указаны в формате "адрес:порт". Пример: "127.0.0.1:1234"'
		].
		address := PMANetAddressValidator validateAddress: address onError: [ 
			^ PMAErrorDialog open: ('Некорректный адрес "{1}".' format: { address })
		]
	]
	ifFalse: [ 
		address := nil.
		port := fullAddress at: 1
	].
	
	port := PMANetAddressValidator validatePort: port onError: [ 
		^ PMAErrorDialog open: ('Некорректный порт "{1}".' format: { port })
	].
	
	self closeDialog: { 
		#role -> role.
		#name -> name.
		#address -> address.
		#port -> port
	} asDictionary
]

{ #category : #accessing }
PMAStartupDialog >> roleEmployeeRadioButton [
	^ roleEmployeeRadioButton
]

{ #category : #accessing }
PMAStartupDialog >> roleLabel [
	^ roleLabel
]

{ #category : #accessing }
PMAStartupDialog >> roleManagerRadioButton [
	^ roleManagerRadioButton
]

{ #category : #accessing }
PMAStartupDialog >> startButton [
	^ startButton
]
