Class {
	#name : #PMATask,
	#superclass : #Object,
	#instVars : [
		'id',
		'taskName',
		'startDate',
		'deadline',
		'isDone',
		'employeeId'
	],
	#category : #'ProjectManagementApplication-Entity'
}

{ #category : #accessing }
PMATask >> deadline [
	^ deadline
]

{ #category : #accessing }
PMATask >> deadline: anObject [
	deadline := anObject asDate
]

{ #category : #accessing }
PMATask >> employeeId [
	^ employeeId
]

{ #category : #accessing }
PMATask >> employeeId: anObject [
	employeeId := anObject
]

{ #category : #accessing }
PMATask >> id [
	^ id
]

{ #category : #accessing }
PMATask >> id: anObject [
	id := anObject
]

{ #category : #accessing }
PMATask >> isDone [
	^ isDone
]

{ #category : #accessing }
PMATask >> isDone: intOrBool [
	isDone := intOrBool isInteger
		ifTrue: [ intOrBool > 0 ]
		ifFalse: [ intOrBool ]
]

{ #category : #accessing }
PMATask >> startDate [
	^ startDate
]

{ #category : #accessing }
PMATask >> startDate: anObject [
	startDate := anObject asDate
]

{ #category : #accessing }
PMATask >> taskName [
	^ taskName
]

{ #category : #accessing }
PMATask >> taskName: anObject [
	taskName := anObject
]
