Extension { #name : #SQLite3Cursor }

{ #category : #'*ProjectManagementApplication' }
SQLite3Cursor >> nextOfClassFixed: aRowClass [
	| rr |
	moreRows ifFalse: [ ^nil ].
	
	statement
		ifNil: [ SQLite3Misuse
				signal: 'This result set does not contain a prepared statement.' ].
	moreRows
		ifTrue: [
			rr := aRowClass new.
			(rr respondsTo: #columnNames:)
				ifTrue: [ "generic row class"
					rr columnNames: self columnNames.
					1 to: statement dataValuesAvailable do: [ :c | rr at: c put: (statement valueOfColumn: c - 1) ].
					 ]
				ifFalse: [ | msgs |
					"custom object"
					msgs := self mutators.
					1 to: msgs size do: [ :c | 
						(rr respondsTo: (msgs at: c))
							ifTrue: [ rr perform: (msgs at: c) with: (statement valueOfColumn: c - 1) ] ] 
						].
			moreRows := statement step = SQLITE_ROW.
			moreRows ifFalse: [ self close ].
			^ rr ].
	^ nil
]

{ #category : #'*ProjectManagementApplication' }
SQLite3Cursor >> rowsOfClassFixed: aRowClass [
	
	rows ifNil: [ rows := OrderedCollection new ].
	[ moreRows ] whileTrue: [
			rows add: (self nextOfClassFixed: aRowClass) ].
	^ rows

]
