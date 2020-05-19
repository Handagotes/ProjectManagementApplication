Class {
	#name : #PMAClientLeftAnnouncement,
	#superclass : #Announcement,
	#instVars : [
		'id'
	],
	#category : #'ProjectManagementApplication-Util'
}

{ #category : #'instance creation' }
PMAClientLeftAnnouncement class >> withId: id [
	^ self new
		id: id;
		yourself
]

{ #category : #accessing }
PMAClientLeftAnnouncement >> id [
	^ id
]

{ #category : #accessing }
PMAClientLeftAnnouncement >> id: anObject [
	id := anObject
]
