Class {
	#name : #PMAConnectedToServerAnnouncement,
	#superclass : #Announcement,
	#instVars : [
		'uid',
		'post',
		'projectName',
		'tasks'
	],
	#category : #'ProjectManagementApplication-Util'
}

{ #category : #'instance creation' }
PMAConnectedToServerAnnouncement class >> withPost: post projectName: projectName tasks: tasks [
	^ self new
		post: post;
		projectName: projectName;
		tasks: tasks;
		yourself
]

{ #category : #'instance creation' }
PMAConnectedToServerAnnouncement class >> withPost: post uid: uid projectName: projectName tasks: tasks [
	^ self new
		post: post;
		uid: uid;
		projectName: projectName;
		tasks: tasks;
		yourself
]

{ #category : #accessing }
PMAConnectedToServerAnnouncement >> post [
	^ post
]

{ #category : #accessing }
PMAConnectedToServerAnnouncement >> post: anObject [
	post := anObject
]

{ #category : #accessing }
PMAConnectedToServerAnnouncement >> projectName [
	^ projectName
]

{ #category : #accessing }
PMAConnectedToServerAnnouncement >> projectName: anObject [
	projectName := anObject
]

{ #category : #accessing }
PMAConnectedToServerAnnouncement >> tasks [
	^ tasks
]

{ #category : #accessing }
PMAConnectedToServerAnnouncement >> tasks: anObject [
	tasks := anObject
]

{ #category : #accessing }
PMAConnectedToServerAnnouncement >> uid [
	^ uid
]

{ #category : #accessing }
PMAConnectedToServerAnnouncement >> uid: anObject [
	uid := anObject
]
