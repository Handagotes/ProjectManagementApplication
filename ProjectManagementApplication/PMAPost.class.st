Class {
	#name : #PMAPost,
	#superclass : #PMAEntity,
	#instVars : [
		'postName'
	],
	#category : #'ProjectManagementApplication-Entity'
}

{ #category : #api }
PMAPost class >> tableName [
	^ 'posts'
]

{ #category : #accessing }
PMAPost >> postName [
	^ postName
]

{ #category : #accessing }
PMAPost >> postName: anObject [
	postName := anObject
]
