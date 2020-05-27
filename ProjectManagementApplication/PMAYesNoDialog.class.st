Class {
	#name : #PMAYesNoDialog,
	#superclass : #PMADialog,
	#instVars : [
		'questionImage',
		'questionLabel',
		'yesButton',
		'noButton'
	],
	#category : #'ProjectManagementApplication-Boundary'
}

{ #category : #specs }
PMAYesNoDialog class >> defaultSpec [
	^ SpecLayout composed newColumn: [ :column |
		column
			newRow: [ :row |
				row
					add: #questionImage width: self questionIcon width;
					add: #questionLabel
			];
			newRow: [ :row |
				row
					add: #yesButton;
					add: #noButton
			]
	]
]

{ #category : #api }
PMAYesNoDialog class >> open: questionString [
	^ self openDialogConfiguredAs: [ :dialog :window |
		dialog questionLabel label: questionString.
		window extent: dialog extent
	]
]

{ #category : #private }
PMAYesNoDialog class >> questionIcon [
	^ self iconNamed: #question
]

{ #category : #api }
PMAYesNoDialog >> extent [
	^ super extent max: 50 + (self widthOfString: questionLabel label) @ 100
]

{ #category : #initialization }
PMAYesNoDialog >> initializePresenter [
	yesButton action: [ self closeDialog: true ].
	noButton action: [ self closeDialog: false ]
]

{ #category : #initialization }
PMAYesNoDialog >> initializeWidgets [
	questionImage := self newImage.
	questionLabel := self newLabel.
	yesButton := self newButton.
	noButton := self newButton.
	
	questionImage image: self class questionIcon.
	yesButton label: 'Да'.
	noButton label: 'Нет'.
	
	self focusOrder
		add: yesButton;
		add: noButton
]

{ #category : #accessing }
PMAYesNoDialog >> noButton [
	^ noButton
]

{ #category : #accessing }
PMAYesNoDialog >> questionImage [
	^ questionImage
]

{ #category : #accessing }
PMAYesNoDialog >> questionLabel [
	^ questionLabel
]

{ #category : #accessing }
PMAYesNoDialog >> yesButton [
	^ yesButton
]
