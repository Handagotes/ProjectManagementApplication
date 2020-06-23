Class {
	#name : #PMAEditableEmployeeTableViewDialog,
	#superclass : #PMAEmployeeTableViewDialog,
	#instVars : [
		'excludeButton',
		'changePostButton',
		'managerPresenter'
	],
	#category : #'ProjectManagementApplication-Boundary'
}

{ #category : #specs }
PMAEditableEmployeeTableViewDialog class >> defaultSpec [
	^ SpecLayout composed newColumn: [ :column |
		column
			add: #employeeDataTable;
			newRow: [ :row |
				row
					add: #excludeButton;
					add: #changePostButton;
					add: #closeButton
			] height: self buttonHeight
	]
]

{ #category : #'instance creation' }
PMAEditableEmployeeTableViewDialog class >> openEmployees: employees posts: posts managerPresenter: aPMAManagerSidePresenter [
	^ self openDialogConfiguredAs: [ :dialog |
		dialog
			setupEmployees: employees
			posts: posts
			managerPresenter: aPMAManagerSidePresenter
	]
]

{ #category : #accessing }
PMAEditableEmployeeTableViewDialog >> changePostButton [
	^ changePostButton
]

{ #category : #accessing }
PMAEditableEmployeeTableViewDialog >> excludeButton [
	^ excludeButton
]

{ #category : #private }
PMAEditableEmployeeTableViewDialog >> excludeEmployee: employee [
	| items |
	items := employeeDataTable widget dataSource elements.
	items removeAt: (items findFirst: [ :i | (i at: #employee) = employee ]).
	self updateEmployeeDataTable.
	managerPresenter excludeEmployee: employee
]

{ #category : #initialization }
PMAEditableEmployeeTableViewDialog >> initializePresenter [
	super initializePresenter.
	excludeButton action: [ self onExcludeButtonClick ].
	changePostButton action: [ self onChangePostButtonClick ]
]

{ #category : #initialization }
PMAEditableEmployeeTableViewDialog >> initializeWidgets [
	super initializeWidgets.
	
	excludeButton := self newButton.
	changePostButton := self newButton.
	
	excludeButton label: 'Исключить из проекта'.
	changePostButton label: 'Изменить должность'.
	
	self focusOrder
		add: employeeDataTable;
		remove: closeButton;
		add: excludeButton;
		add: changePostButton;
		add: closeButton
]

{ #category : #private }
PMAEditableEmployeeTableViewDialog >> onChangePostButtonClick [
	| item employee newPost |
	(item := self selectedItem) ifNil: [ ^ self ].
	employee := item at: #employee.
	employee id = managerPresenter manager id ifTrue: [ ^ self ].
	newPost := PMASetEmployeePostDialog
		open: employee fullName
		posts: PMAProjectDB editablePosts
		current: (item at: #post) postName.
	newPost ifNil: [ ^ self ].
	item at: #post put: newPost.
	self updateEmployeeDataTable.
	managerPresenter changePostFor: employee newPost: newPost
]

{ #category : #private }
PMAEditableEmployeeTableViewDialog >> onExcludeButtonClick [
	| item employee |
	(item := self selectedItem) ifNil: [ ^ self ].
	employee := item at: #employee.
	employee id = managerPresenter manager id ifTrue: [ ^ self ].
	(PMAYesNoDialog open: (
		'Вы действительно хотите исключить сотрудника {1} из проекта?' format: { employee fullName }))
			ifFalse: [ ^ self ].
	self excludeEmployee: employee
]

{ #category : #private }
PMAEditableEmployeeTableViewDialog >> setupEmployees: employees posts: posts managerPresenter: aPMAManagerSidePresenter [
	self setupEmployees: employees posts: posts.
	managerPresenter := aPMAManagerSidePresenter
]
