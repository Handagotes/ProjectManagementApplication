Class {
	#name : #PMANewMessageAnnouncement,
	#superclass : #Announcement,
	#instVars : [
		'message',
		'senderId'
	],
	#category : #'ProjectManagementApplication-Util'
}

{ #category : #'instance creation' }
PMANewMessageAnnouncement class >> withMessage: message senderId: senderId [
	^ self new
		message: message;
		senderId: senderId;
		yourself
]

{ #category : #'instance creation' }
PMANewMessageAnnouncement class >> withMesssage: message [
	^ self withMessage: message senderId: nil
]

{ #category : #accessing }
PMANewMessageAnnouncement >> message [
	^ message
]

{ #category : #accessing }
PMANewMessageAnnouncement >> message: anObject [
	message := anObject
]

{ #category : #accessing }
PMANewMessageAnnouncement >> senderId [
	^ senderId
]

{ #category : #accessing }
PMANewMessageAnnouncement >> senderId: anObject [
	senderId := anObject
]
