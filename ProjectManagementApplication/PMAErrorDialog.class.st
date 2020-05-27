Class {
	#name : #PMAErrorDialog,
	#superclass : #PMADialog,
	#instVars : [
		'errorImage',
		'errorLabel',
		'okButton'
	],
	#category : #'ProjectManagementApplication-Boundary'
}

{ #category : #specs }
PMAErrorDialog class >> defaultSpec [
	^ SpecLayout composed newColumn: [ :column |
		column
			newRow: [ :row |
				row
					add: #errorImage width: self errorIcon width;
					add: #errorLabel
			];
			add: #okButton
	]
]

{ #category : #private }
PMAErrorDialog class >> errorIcon [
	^ self iconNamed: #error
]

{ #category : #api }
PMAErrorDialog class >> open: errorString [
	^ self openDialogConfiguredAs: [ :dialog :window |
		dialog errorLabel label: 'Ошибка: ' , errorString.
		window extent: dialog extent
	]
]

{ #category : #accessing }
PMAErrorDialog >> errorImage [
	^ errorImage
]

{ #category : #accessing }
PMAErrorDialog >> errorLabel [
	^ errorLabel
]

{ #category : #api }
PMAErrorDialog >> extent [
	^ super extent max: 30 + (self widthOfString: errorLabel label) @ 100
]

{ #category : #initialization }
PMAErrorDialog >> initializePresenter [
	okButton action: [ self closeDialog ]
]

{ #category : #initialization }
PMAErrorDialog >> initializeWidgets [
	errorImage := self newImage.
	errorLabel := self newLabel.
	okButton := self newButton.
	
	errorImage image: self class errorIcon.
	okButton label: 'Ок'.
	
	self focusOrder
		add: okButton
]

{ #category : #accessing }
PMAErrorDialog >> okButton [
	^ okButton
]
