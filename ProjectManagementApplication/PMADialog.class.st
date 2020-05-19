Class {
	#name : #PMADialog,
	#superclass : #ComposablePresenter,
	#instVars : [
		'result'
	],
	#category : #'ProjectManagementApplication-Boundary'
}

{ #category : #private }
PMADialog class >> openDialog [
	^ self openDialogConfiguredAs: [  ]
]

{ #category : #private }
PMADialog class >> openDialogConfiguredAs: aBlock [
	| topMorph dialog window |
	topMorph := SystemWindow topWindow ifNil: [ World ].
	(dialog := self new)
		openWithSpec;
		result: nil.
	(window := dialog window)
		containingWindow removeBoxes.
	aBlock cull: dialog cull: window.
	window modalRelativeTo: topMorph.
	"Поток останавливается до закрытия модального окна"
	^ dialog result
]

{ #category : #private }
PMADialog >> closeDialog [
	self closeDialog: nil
]

{ #category : #private }
PMADialog >> closeDialog: aResultObject [
	self result: aResultObject.
	self window close
]

{ #category : #'private - accessing' }
PMADialog >> result [
	^ result
]

{ #category : #'private - accessing' }
PMADialog >> result: anObject [
	result := anObject
]

{ #category : #api }
PMADialog >> title [
	^ PMApp appName
]
