Class {
	#name : #PMATasksDataSource,
	#superclass : #FTSimpleDataSource,
	#category : #'ProjectManagementApplication-Boundary'
}

{ #category : #'instance creation' }
PMATasksDataSource class >> withTasks: tasks [
	^ self elements: tasks
]

{ #category : #adding }
PMATasksDataSource >> addColumnsTo: aTable [
	aTable
		addColumn: (FTColumn new
			id: 'Задание';
			width: 220;
			yourself);
		addColumn: (FTColumn new
			id: 'Дата начала';
			width: 90;
			yourself);
		addColumn: (FTColumn new
			id: 'Дата окончания';
			width: 100;
			yourself);
		addColumn: (FTColumn new
			id: 'Выполнено';
			yourself)
]

{ #category : #accessing }
PMATasksDataSource >> cellColumn: column row: rowIndex [ 
	| task  |
	task := self elementAt: rowIndex.
	column id = 'Задание' ifTrue: [ ^ task taskName asStringMorph ].
	column id = 'Дата начала' ifTrue: [ ^ task startDate ddmmyyyy asStringMorph ].
	column id = 'Дата окончания' ifTrue: [ ^ task deadline ddmmyyyy asStringMorph ].
	column id = 'Выполнено' ifTrue: [ ^ (task isDone ifTrue: [ 'Да' ] ifFalse: [ 'Нет' ]) asStringMorph ]
]
