Class {
	#name : #PMADBController,
	#superclass : #PMASingleton,
	#instVars : [
		'connection',
		'traceQueries'
	],
	#category : #'ProjectManagementApplication-Control'
}

{ #category : #private }
PMADBController >> attributesForEntity: aPMAEntity [
	| columns |
	columns := connection columnNamesFor: aPMAEntity class tableName.
	columns remove: #id.
	^ (columns collect: [ :c | c -> c snakeToCamel uncapitalized asSymbol ]) asDictionary
]

{ #category : #api }
PMADBController >> closeConnection [
	connection ifNil: [ ^ self ].
	connection close.
	connection := nil
]

{ #category : #accessing }
PMADBController >> connection [
	^ connection
]

{ #category : #private }
PMADBController >> createTableIfNotExistsQueries [
	^ self subclassResponsibility
]

{ #category : #api }
PMADBController >> dbFilename [
	^ self subclassResponsibility
	
]

{ #category : #api }
PMADBController >> deleteEntity: aPMAEntity [
	| table query |
	self assert: connection isNotNil.
	table := aPMAEntity class tableName storeString.
	query := String streamContents: [ :stream |
		stream
			nextPutAll: 'DELETE FROM ';
			nextPutAll: table;
			nextPutAll: ' WHERE id = ?;'
	].
	traceQueries ifTrue: [ query traceCr ].
	connection execute: query value: aPMAEntity id
	
]

{ #category : #private }
PMADBController >> dropTableQueries [
	^ self subclassResponsibility
]

{ #category : #api }
PMADBController >> dropTables [
	connection ifNil: [ ^ self ].
	self dropTableQueries do: [ :q | connection execute: q ]
]

{ #category : #initialization }
PMADBController >> initialize [
	connection := nil.
	traceQueries := false
]

{ #category : #api }
PMADBController >> insertEntity: aPMAEntity [
	| table attributes query args |
	self assert: connection isNotNil.
	table := aPMAEntity class tableName storeString.
	attributes := self attributesForEntity: aPMAEntity.
	query := String streamContents: [ :stream |
		stream
			nextPutAll: 'INSERT INTO ';
			nextPutAll: table;
			nextPut: $(;
			nextPutAll: (', ' join: attributes keys);
			nextPutAll: ') VALUES (';
			nextPutAll: (', ' join: ('?' repeat: attributes size));
			nextPutAll: ');'
	].
	traceQueries ifTrue: [ query traceCr ].
	args := attributes values collect: [ :a | aPMAEntity perform: a ].
	connection
		beginTransaction;
		execute: query with: args.
	aPMAEntity id: self lastId.
	connection commitTransaction.
	^ aPMAEntity id
]

{ #category : #testing }
PMADBController >> isConnected [
	^ self connection isNotNil
]

{ #category : #private }
PMADBController >> lastId [
	^ (connection execute: 'SELECT last_insert_rowid()') next at: 1
]

{ #category : #api }
PMADBController >> openConnection [
	| path |
	connection ifNotNil: [ ^ self ].
	path := (Smalltalk imageDirectory / self dbFilename) fullName.
	connection := SQLite3Connection openOn: path.
	self createTableIfNotExistsQueries do: [ :q | connection execute: q ]
]

{ #category : #private }
PMADBController >> selectAllFrom: table entityClass: entityClass [
	| cursor |
	cursor := connection execute: 'SELECT * FROM ' , table asString storeString.
	^ cursor rowsOfClassFixed: entityClass
]

{ #category : #accessing }
PMADBController >> traceQueries [
	^ traceQueries
]

{ #category : #accessing }
PMADBController >> traceQueries: aBoolean [
	traceQueries := aBoolean
]

{ #category : #api }
PMADBController >> updateEntity: aPMAEntity [
	| table attributes query args |
	self assert: connection isNotNil.
	table := aPMAEntity class tableName storeString.
	attributes := self attributesForEntity: aPMAEntity.
	query := String streamContents: [ :stream | | columns |
		stream
			nextPutAll: 'UPDATE ';
			nextPutAll: table;
			nextPutAll: ' SET '.
		(columns := attributes keys)
			doWithIndex: [ :column :i |
				stream
					nextPutAll: column;
					nextPutAll: ' = ?'.
				i = columns size ifFalse: [ 
					stream nextPutAll: ', '
				]
			].
		stream
			nextPutAll: ' WHERE id = ?;'
	].
	traceQueries ifTrue: [ query traceCr ].
	args := attributes values collect: [ :a | aPMAEntity perform: a ].
	connection execute: query with: args , { aPMAEntity id }
]
