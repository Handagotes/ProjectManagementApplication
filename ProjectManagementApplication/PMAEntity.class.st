Class {
	#name : #PMAEntity,
	#superclass : #Object,
	#instVars : [
		'id'
	],
	#category : #'ProjectManagementApplication-Entity'
}

{ #category : #api }
PMAEntity class >> tableName [
	^ self subclassResponsibility
]

{ #category : #accessing }
PMAEntity >> id [
	^ id
]

{ #category : #accessing }
PMAEntity >> id: anObject [
	id := anObject
]
