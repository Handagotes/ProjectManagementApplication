Class {
	#name : #PMASingleton,
	#superclass : #Object,
	#classInstVars : [
		'instance'
	],
	#category : #'ProjectManagementApplication-Control'
}

{ #category : #accessing }
PMASingleton class >> globalName [
	"
		^ #MySingletonInstance
		or if global is not needed:
		^ nil
	"
	self subclassResponsibility
]

{ #category : #'class initialization' }
PMASingleton class >> initialize [
	| globalName |
	self = PMASingleton ifTrue: [ ^ self	].
	instance ifNotNil: [ ^ self ].
	(globalName := self globalName) ifNil: [ 
		instance := self basicNew initialize.
		^ self
	].
	(Smalltalk globals includesKey: globalName) ifTrue: [ 
		instance := Smalltalk at: globalName
	]
	ifFalse: [ 
		instance := self basicNew initialize.
		Smalltalk at: globalName put: instance
	]
]

{ #category : #accessing }
PMASingleton class >> instance [
	^ instance
]

{ #category : #'instance creation' }
PMASingleton class >> new [
	instance ifNil: [ 
		self initialize.
		^ instance
	].
	
	self error: (String streamContents: [ :s | | globalName |
		s nextPutAll: ('Attempt to instantiate singleton class {1}. Use "{1} instance" ' format: { self name }).
		(globalName := self globalName) ifNotNil: [ 
			s nextPutAll: ('or global "{1}" ' format: { globalName })
		].
		s nextPutAll: 'instead.'
	])
]

{ #category : #removing }
PMASingleton class >> remove [
	| globalName |
	globalName := self globalName.
	globalName ifNotNil: [ Smalltalk globals removeKey: globalName ifAbsent: [  ] ].
	instance := nil
]

{ #category : #removing }
PMASingleton class >> removeAll [
	PMASingleton allSubclassesDo: [ :c |
		c hasAbstractMethods ifFalse: [ 
			c remove
		]
	]
]
