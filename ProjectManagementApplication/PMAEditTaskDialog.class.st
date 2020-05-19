Class {
	#name : #PMAEditTaskDialog,
	#superclass : #PMADialog,
	#instVars : [
		'employeeLabel',
		'taskLabel',
		'taskTextInput',
		'startDateLabel',
		'startDate',
		'deadlineLabel',
		'deadlineDate',
		'okButton',
		'cancelButton',
		'task',
		'employee'
	],
	#category : #'ProjectManagementApplication-Boundary'
}

{ #category : #specs }
PMAEditTaskDialog class >> defaultSpec [
	^ SpecLayout composed newColumn: [ :column |
		column
			add: #employeeLabel height: self inputTextHeight;
			newRow: [ :row |
				row
					add: #taskLabel;
					add: #taskTextInput
			] height: self inputTextHeight;
			newRow: [ :row |
				row
					add: #startDateLabel;
					add: #startDate
			] height: self inputTextHeight;
			newRow: [ :row |
				row
					add: #deadlineLabel;
					add: #deadlineDate
			] height: self inputTextHeight;
			newRow: [ :row |
				row
					add: #okButton;
					add: #cancelButton
			] height: self buttonHeight
	]
]

{ #category : #api }
PMAEditTaskDialog class >> open: task forEmployee: employee [
	^ self openDialogConfiguredAs: [ :dialog |
		dialog
			task: task;
			employee: employee
	]
]

{ #category : #accessing }
PMAEditTaskDialog >> cancelButton [
	^ cancelButton
]

{ #category : #accessing }
PMAEditTaskDialog >> deadlineDate [
	^ deadlineDate
]

{ #category : #accessing }
PMAEditTaskDialog >> deadlineLabel [
	^ deadlineLabel
]

{ #category : #'private-accessing' }
PMAEditTaskDialog >> employee: aPMAEmployee [
	employee := aPMAEmployee.
	employeeLabel label: 'Задача для сотрудника ' , employee fullName
]

{ #category : #accessing }
PMAEditTaskDialog >> employeeLabel [
	^ employeeLabel
]

{ #category : #api }
PMAEditTaskDialog >> extent [
	^ 400 @ 185
]

{ #category : #initialization }
PMAEditTaskDialog >> initializePresenter [
	taskTextInput whenTextChanged: [ 
		okButton enabled: taskTextInput text isNotEmpty
	].
	
	startDate whenDateChanged: [ :date |
		okButton enabled: date <= deadlineDate date
	].
	
	deadlineDate whenDateChanged: [ :date |
		okButton enabled: date >= startDate date
	].
	
	okButton action: [ 
		task
			taskName: taskTextInput text;
			startDate: startDate date;
			deadline: deadlineDate date;
			isDone: (task isDone ifNil: [ false ]);
			employeeId: employee id.
		self closeDialog: true
	].
	
	cancelButton action: [ 
		self closeDialog: false
	]
]

{ #category : #initialization }
PMAEditTaskDialog >> initializeWidgets [
	employeeLabel := self newLabel.
	taskLabel := self newLabel.
	taskTextInput := self newTextInput.
	startDateLabel := self newLabel.
	startDate := self instantiate: DatePresenter.
	deadlineLabel := self newLabel.
	deadlineDate := self instantiate: DatePresenter.
	okButton := self newButton.
	cancelButton := self newButton.
	
	taskLabel label: 'Задача:'.
	taskTextInput autoAccept: true.
	startDateLabel label: 'Дата начала:'.
	deadlineLabel label: 'Дата окончания:'.
	okButton
		disable;
		label: 'Ок'.
	cancelButton label: 'Отмена'.
	
	self focusOrder
		add: taskTextInput;
		add: okButton;
		add: cancelButton
]

{ #category : #accessing }
PMAEditTaskDialog >> okButton [
	^ okButton
]

{ #category : #accessing }
PMAEditTaskDialog >> startDate [
	^ startDate
]

{ #category : #accessing }
PMAEditTaskDialog >> startDateLabel [
	^ startDateLabel
]

{ #category : #'private-accessing' }
PMAEditTaskDialog >> task: aPMATask [
	task := aPMATask.
	task taskName ifNotNil: [ taskTextInput text: task taskName ].
	task startDate ifNotNil: [ 	startDate date: task startDate	].
	task deadline ifNotNil: [ deadlineDate date: task deadline ].
]

{ #category : #accessing }
PMAEditTaskDialog >> taskLabel [
	^ taskLabel
]

{ #category : #accessing }
PMAEditTaskDialog >> taskTextInput [
	^ taskTextInput
]
