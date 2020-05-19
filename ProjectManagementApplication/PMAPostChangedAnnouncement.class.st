Class {
	#name : #PMAPostChangedAnnouncement,
	#superclass : #Announcement,
	#instVars : [
		'newPost'
	],
	#category : #'ProjectManagementApplication-Util'
}

{ #category : #'instance creation' }
PMAPostChangedAnnouncement class >> newPost: newPost [
	^ self new
		newPost: newPost;
		yourself
]

{ #category : #accessing }
PMAPostChangedAnnouncement >> newPost [
	^ newPost
]

{ #category : #accessing }
PMAPostChangedAnnouncement >> newPost: anObject [
	newPost := anObject
]
