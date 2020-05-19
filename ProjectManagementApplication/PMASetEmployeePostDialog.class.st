Class {
	#name : #PMASetEmployeePostDialog,
	#superclass : #PMADialog,
	#instVars : [
		'nameLabel',
		'postDropList',
		'okButton',
		'cancelButton'
	],
	#category : #'ProjectManagementApplication-Boundary'
}

{ #category : #specs }
PMASetEmployeePostDialog class >> defaultSpec [
	^ SpecLayout composed newColumn: [ :column |
		column
			add: #nameLabel;
			add: #postDropList;
			newRow: [ :row |
				row
					add: #okButton;
					add: #cancelButton
			]
	]
]

{ #category : #api }
PMASetEmployeePostDialog class >> open: employeeName posts: posts [
	^ self openDialogConfiguredAs: [ :dialog |
		dialog setupName: employeeName posts: posts
	]
]

{ #category : #api }
PMASetEmployeePostDialog class >> open: employeeName posts: posts current: currentPost [
	^ self openDialogConfiguredAs: [ :dialog |
		dialog
			setupName: employeeName posts: posts;
			setupCurrentPost: currentPost
	]
]

{ #category : #api }
PMASetEmployeePostDialog class >> openNoCancel: employeeName posts: posts [
	^ self openDialogConfiguredAs: [ :dialog |
		dialog setupName: employeeName posts: posts.
		dialog cancelButton disable
	]
]

{ #category : #api }
PMASetEmployeePostDialog class >> openNoCancel: employeeName posts: posts current: currentPost [
	^ self openDialogConfiguredAs: [ :dialog |
		dialog
			setupName: employeeName posts: posts;
			setupCurrentPost: currentPost.
		dialog cancelButton disable
	]
]

{ #category : #accessing }
PMASetEmployeePostDialog >> cancelButton [
	^ cancelButton
]

{ #category : #api }
PMASetEmployeePostDialog >> extent [
	| font w |
	font := self class defaultFont.
	w := 375 max: (15 + (font widthOfString: nameLabel label)).
	^ w @ 125
]

{ #category : #initialization }
PMASetEmployeePostDialog >> initializePresenter [
	postDropList whenSelectionChanged: [ 
		okButton enable
	].
	
	okButton action: [ 
		self closeDialog: postDropList selectedItem
	].
	
	cancelButton action: [ 
		self closeDialog: nil
	]
]

{ #category : #initialization }
PMASetEmployeePostDialog >> initializeWidgets [
	nameLabel := self newLabel.
	postDropList := self newDropList.
	okButton := self newButton.
	cancelButton := self newButton.
	
	postDropList displayBlock: [ :p | p postName ].
	okButton label: 'Ок'.
	cancelButton label: 'Отмена'.
	
	self focusOrder
		add: postDropList;
		add: okButton;
		add: cancelButton
]

{ #category : #accessing }
PMASetEmployeePostDialog >> nameLabel [
	^ nameLabel
]

{ #category : #accessing }
PMASetEmployeePostDialog >> okButton [
	^ okButton
]

{ #category : #accessing }
PMASetEmployeePostDialog >> postDropList [
	^ postDropList
]

{ #category : #private }
PMASetEmployeePostDialog >> setupCurrentPost: currentPost [
	postDropList setSelectedItem: currentPost
]

{ #category : #private }
PMASetEmployeePostDialog >> setupName: employeeName posts: postCollection [
	nameLabel label: 'Укажите должность сотрудника ' , employeeName , '.'.
	postDropList
		items: postCollection;
		resetSelection.
	okButton disable.
	self window extent: self extent
]
