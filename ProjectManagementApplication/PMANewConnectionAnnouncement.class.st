Class {
	#name : #PMANewConnectionAnnouncement,
	#superclass : #Announcement,
	#instVars : [
		'employee'
	],
	#category : #'ProjectManagementApplication-Util'
}

{ #category : #'instance creation' }
PMANewConnectionAnnouncement class >> withEmployee: employee [
	^ self new
		withEmployee: employee;
		yourself
]

{ #category : #accessing }
PMANewConnectionAnnouncement >> employee [
	^ employee
]

{ #category : #accessing }
PMANewConnectionAnnouncement >> withEmployee: anObject [
	employee := anObject
]
