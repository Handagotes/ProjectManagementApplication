Class {
	#name : #PMATextInputDialog,
	#superclass : #PMADialog,
	#instVars : [
		'label',
		'textInput',
		'okButton',
		'cancelButton'
	],
	#category : #'ProjectManagementApplication-Boundary'
}

{ #category : #specs }
PMATextInputDialog class >> defaultSpec [
	^ SpecLayout composed newColumn: [ :column |
		column
			add: #label height: 25;
			add: #textInput;
			newRow: [ :row |
				row
					add: #okButton;
					add: #cancelButton
			] height: self buttonHeight
	]
]

{ #category : #api }
PMATextInputDialog class >> open: labelText [
	^ self open: labelText default: String empty
]

{ #category : #api }
PMATextInputDialog class >> open: labelText default: defaultText [
	^ self openDialogConfiguredAs: [ :dialog |
		dialog setupLabelText: labelText defaultText: defaultText
	]
]

{ #category : #api }
PMATextInputDialog class >> openNoCancel: labelText [
	^ self openNoCancel: labelText default: String empty
]

{ #category : #api }
PMATextInputDialog class >> openNoCancel: labelText default: defaultText [
	^ self openDialogConfiguredAs: [ :dialog |
		dialog setupLabelText: labelText defaultText: defaultText.
		dialog cancelButton disable
	]
]

{ #category : #accessing }
PMATextInputDialog >> cancelButton [
	^ cancelButton
]

{ #category : #api }
PMATextInputDialog >> extent [
	| font w |
	font := self class defaultFont.
	w := 400 max: (50 + (font widthOfString: label label)).
	^ w @ 120
]

{ #category : #initialization }
PMATextInputDialog >> initializePresenter [
	textInput whenTextChanged: [ 
		okButton enabled: textInput text isNotEmpty
	].
	
	okButton action: [ 
		self closeDialog: textInput text
	].
	
	cancelButton action: [ 
		self closeDialog: nil
	]
]

{ #category : #initialization }
PMATextInputDialog >> initializeWidgets [
	label := self newLabel.
	textInput := self newTextInput.
	okButton := self newButton.
	cancelButton := self newButton.
	
	textInput autoAccept: true.
	okButton label: 'Ок'.
	cancelButton label: 'Отмена'.
	
	self focusOrder
		add: textInput;
		add: okButton;
		add: cancelButton
]

{ #category : #accessing }
PMATextInputDialog >> label [
	^ label
]

{ #category : #accessing }
PMATextInputDialog >> okButton [
	^ okButton
]

{ #category : #private }
PMATextInputDialog >> setupLabelText: labelText defaultText: defaultText [
	label label: labelText.
	textInput text: defaultText
]

{ #category : #accessing }
PMATextInputDialog >> textInput [
	^ textInput
]
