Class {
	#name : #PMAEmployeesDataSource,
	#superclass : #FTSimpleDataSource,
	#category : #'ProjectManagementApplication-Boundary'
}

{ #category : #'instance creation' }
PMAEmployeesDataSource class >> withEmployees: employees posts: posts [
	^ self elements: (employees collect: [ :e |
		{
			#employee -> e.
			#post -> (posts detect: [ :p | p id = e postId ])
		} asDictionary
	]) asOrderedCollection
]

{ #category : #adding }
PMAEmployeesDataSource >> addColumnsTo: aTable [
	aTable
		addColumn: (FTColumn new
			id: 'Фамилия, имя, отчество';
			width: 400;
			yourself);
		addColumn: (FTColumn new
			id: 'Должность';
			yourself)
]

{ #category : #accessing }
PMAEmployeesDataSource >> cellColumn: column row: rowIndex [ 
	| item employee post  |
	item := self elementAt: rowIndex.
	employee := item at: #employee.
	post := item at: #post.
	column id = 'Фамилия, имя, отчество' ifTrue: [ ^ employee fullName asStringMorph ].
	column id = 'Должность' ifTrue: [ ^ post postName asStringMorph ]
]
