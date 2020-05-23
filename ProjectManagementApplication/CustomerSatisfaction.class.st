Class {
	#name : #CustomerSatisfaction,
	#superclass : #ComposablePresenter,
	#instVars : [
		'buttonHappy',
		'buttonNeutral',
		'buttonBad',
		'screen'
	],
	#category : #ProjectManagementApplication
}

{ #category : #specs }
CustomerSatisfaction class >> defaultSpec [
	^ SpecLayout composed newRow: [ :row |
		row add: #buttonHappy; add: #buttonNeutral; add: #buttonBad
	]
	origin: 0 @ 0 corner: 1 @ 0.7;
	newRow: [ :row |
		row add: #screen
	]
	origin: 0 @ 0.7 corner: 1 @ 1;
	yourself
]

{ #category : #accessing }
CustomerSatisfaction >> buttonBad [
	^ buttonBad
]

{ #category : #accessing }
CustomerSatisfaction >> buttonHappy [
	^ buttonHappy
]

{ #category : #accessing }
CustomerSatisfaction >> buttonNeutral [
	^ buttonNeutral
]

{ #category : #api }
CustomerSatisfaction >> extent [
	^ 400@100
]

{ #category : #initialization }
CustomerSatisfaction >> initializePresenter [
	buttonHappy action: [ screen label: buttonHappy label ].
	buttonNeutral action: [ screen label: buttonNeutral label ].
	buttonBad action: [ screen label: buttonBad label ].
]

{ #category : #initialization }
CustomerSatisfaction >> initializeWidgets [
	"widget instantiation"
	screen := self newLabel.
	buttonHappy := self newButton.
	buttonNeutral := self newButton.
	buttonBad := self newButton.
	"widget configuration"
	screen label: 'Please give us your feedback.'.
	buttonHappy
		label: 'Happy';
		icon: (self iconNamed: #thumbsUp).
	buttonNeutral
		label: 'Neutral';
		icon: (self iconNamed: #user).
	buttonBad
		label: 'Bad';
		icon: (self iconNamed: #thumbsDown).
	"specification of order of focus"
	self focusOrder
		add: buttonHappy;
		add: buttonNeutral;
		add: buttonBad
]

{ #category : #accessing }
CustomerSatisfaction >> screen [
	^ screen
]

{ #category : #api }
CustomerSatisfaction >> title [
	^ 'Customer Satisfaction Survey'.
]
