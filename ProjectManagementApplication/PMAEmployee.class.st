Class {
	#name : #PMAEmployee,
	#superclass : #PMAEntity,
	#instVars : [
		'fullName',
		'postId'
	],
	#category : #'ProjectManagementApplication-Entity'
}

{ #category : #api }
PMAEmployee class >> tableName [
	^ 'employees'
]

{ #category : #accessing }
PMAEmployee >> fullName [
	^ fullName
]

{ #category : #accessing }
PMAEmployee >> fullName: anObject [
	fullName := anObject
]

{ #category : #accessing }
PMAEmployee >> postId [
	^ postId
]

{ #category : #accessing }
PMAEmployee >> postId: anObject [
	postId := anObject
]
