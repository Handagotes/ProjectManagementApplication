Class {
	#name : #PMATaskAnnouncement,
	#superclass : #Announcement,
	#instVars : [
		'task'
	],
	#category : #'ProjectManagementApplication-Util'
}

{ #category : #accessing }
PMATaskAnnouncement class >> task: task [
	^ self new
		task: task;
		yourself
]

{ #category : #accessing }
PMATaskAnnouncement >> task [
	^ task
]

{ #category : #accessing }
PMATaskAnnouncement >> task: anObject [
	task := anObject
]
