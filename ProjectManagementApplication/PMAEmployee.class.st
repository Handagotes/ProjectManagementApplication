Class {
	#name : #PMAEmployee,
	#superclass : #Object,
	#instVars : [
		'id',
		'fullName',
		'postId'
	],
	#category : #'ProjectManagementApplication-Entity'
}

{ #category : #accessing }
PMAEmployee >> fullName [
	^ fullName
]

{ #category : #accessing }
PMAEmployee >> fullName: anObject [
	fullName := anObject
]

{ #category : #accessing }
PMAEmployee >> id [
	^ id
]

{ #category : #accessing }
PMAEmployee >> id: anObject [
	id := anObject
]

{ #category : #accessing }
PMAEmployee >> postId [
	^ postId
]

{ #category : #accessing }
PMAEmployee >> postId: anObject [
	postId := anObject
]
