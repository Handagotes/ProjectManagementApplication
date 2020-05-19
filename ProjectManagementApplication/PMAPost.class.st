Class {
	#name : #PMAPost,
	#superclass : #Object,
	#instVars : [
		'id',
		'postName'
	],
	#category : #'ProjectManagementApplication-Entity'
}

{ #category : #accessing }
PMAPost >> id [
	^ id
]

{ #category : #accessing }
PMAPost >> id: anObject [
	id := anObject
]

{ #category : #accessing }
PMAPost >> postName [
	^ postName
]

{ #category : #accessing }
PMAPost >> postName: anObject [
	postName := anObject
]
