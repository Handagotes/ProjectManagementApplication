Class {
	#name : #PMAEmployeeTableViewDialog,
	#superclass : #PMADialog,
	#instVars : [
		'employeeDataTable',
		'closeButton'
	],
	#category : #'ProjectManagementApplication-Boundary'
}

{ #category : #specs }
PMAEmployeeTableViewDialog class >> defaultSpec [
	^ SpecLayout composed newColumn: [ :column |
		column
			add: #employeeDataTable;
			newRow: [ :row |
				row add: #closeButton
			] height: self buttonHeight
	]
]

{ #category : #'instance creation' }
PMAEmployeeTableViewDialog class >> openEmployees: employees posts: posts [
	^ self openDialogConfiguredAs: [ :dialog |
		dialog setupEmployees: employees posts: posts
	]
]

{ #category : #accessing }
PMAEmployeeTableViewDialog >> closeButton [
	^ closeButton
]

{ #category : #accessing }
PMAEmployeeTableViewDialog >> employeeDataTable [
	^ employeeDataTable
]

{ #category : #api }
PMAEmployeeTableViewDialog >> extent [
	^ 640 @ 480
]

{ #category : #initialization }
PMAEmployeeTableViewDialog >> initializePresenter [
	closeButton action: [ self closeDialog ]
]

{ #category : #initialization }
PMAEmployeeTableViewDialog >> initializeWidgets [
	employeeDataTable := self newDataTable.
	closeButton := self newButton.
	
	closeButton label: 'Закрыть'.
	
	self focusOrder
		add: employeeDataTable;
		add: closeButton
]

{ #category : #accessing }
PMAEmployeeTableViewDialog >> selectedIndex [
	^ employeeDataTable widget selectedRowIndex
]

{ #category : #private }
PMAEmployeeTableViewDialog >> selectedItem [
	| i |
	(i := self selectedIndex) isZero ifTrue: [ ^ nil ].
	^ employeeDataTable widget dataSource elementAt: i
]

{ #category : #private }
PMAEmployeeTableViewDialog >> setupEmployees: employees posts: posts [
	| dataSource |
	dataSource := PMAEmployeesDataSource withEmployees: employees posts: posts.
	dataSource addColumnsTo: employeeDataTable widget.
	employeeDataTable widget dataSource: dataSource
]

{ #category : #api }
PMAEmployeeTableViewDialog >> title [
	^ 'Просмотр списка сотрудников'
]

{ #category : #private }
PMAEmployeeTableViewDialog >> updateEmployeeDataTable [
	employeeDataTable widget dataSource: employeeDataTable widget dataSource
]
