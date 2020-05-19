Class {
	#name : #PMApplicationController,
	#superclass : #PMASingleton,
	#instVars : [
		'lastLaunch',
		'current'
	],
	#category : #'ProjectManagementApplication-Control'
}

{ #category : #accessing }
PMApplicationController class >> globalName [
	^ #PMApp
]

{ #category : #'class initialization' }
PMApplicationController class >> initialize [
	super initialize
]

{ #category : #api }
PMApplicationController >> appName [
	^ 'Приложение для управления проектом'
]

{ #category : #'initialize-release' }
PMApplicationController >> close [
	current ifNil: [ ^ self ].
	current close.
	current := nil
]

{ #category : #initialization }
PMApplicationController >> initialize [
	lastLaunch := nil.
	current := nil
]

{ #category : #api }
PMApplicationController >> launch [
	(current isNil or: [ current isClosed ]) ifFalse: [ ^ current window flash ].
	lastLaunch ifNil: [ 
		(lastLaunch := PMAStartupDialog open) ifNil: [ ^ self ].
		lastLaunch at: #firstlaunch put: true.
	].
	current := self launchAs: lastLaunch.
	lastLaunch at: #firstlaunch put: false
]

{ #category : #private }
PMApplicationController >> launchAs: launchParameters [
	| role |
	role := launchParameters at: #role.
	
	role = 'Сотрудник' ifTrue: [ 
		PMAClientController initialize.
		^ PMAEmployeeSidePresenter open: launchParameters
	].
	
	role = 'Руководитель' ifTrue: [ 
		PMAServerController initialize.
		PMAProjectDBController initialize.
		^ PMAManagerSidePresenter open: launchParameters
	]
]

{ #category : #private }
PMApplicationController >> resetLaunchParameters [
	lastLaunch := nil
]

{ #category : #initialization }
PMApplicationController >> restart [
	self
		close;
		launch
]

{ #category : #private }
PMApplicationController >> restartWithReset [
	self
		close;
		resetLaunchParameters;
		launch
]

{ #category : #waiting }
PMApplicationController >> shortWait [
	0.01 seconds wait
]

{ #category : #versions }
PMApplicationController >> version [
	^ '1.0'
]
