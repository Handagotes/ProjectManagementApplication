Class {
	#name : #PMAClientConnectionClosedAnnouncement,
	#superclass : #Announcement,
	#instVars : [
		'clientId'
	],
	#category : #'ProjectManagementApplication-Util'
}

{ #category : #'instance creation' }
PMAClientConnectionClosedAnnouncement class >> withId: id [
	^ self new
		clientId: id;
		yourself
]

{ #category : #accessing }
PMAClientConnectionClosedAnnouncement >> clientId [
	^ clientId
]

{ #category : #accessing }
PMAClientConnectionClosedAnnouncement >> clientId: anObject [
	clientId := anObject
]
