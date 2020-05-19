Class {
	#name : #PMAProjectNameChangedAnnouncement,
	#superclass : #Announcement,
	#instVars : [
		'newName'
	],
	#category : #'ProjectManagementApplication-Util'
}

{ #category : #'instance creation' }
PMAProjectNameChangedAnnouncement class >> newName: newName [
	^ self new
		newName: newName;
		yourself
]

{ #category : #accessing }
PMAProjectNameChangedAnnouncement >> newName [
	^ newName
]

{ #category : #accessing }
PMAProjectNameChangedAnnouncement >> newName: anObject [
	newName := anObject
]
