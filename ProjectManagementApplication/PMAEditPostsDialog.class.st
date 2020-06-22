Class {
	#name : #PMAEditPostsDialog,
	#superclass : #PMADialog,
	#instVars : [
		'postList',
		'editPostTextInput',
		'addButton',
		'removeButton',
		'okButton',
		'cancelButton',
		'posts',
		'changes'
	],
	#category : #'ProjectManagementApplication-Boundary'
}

{ #category : #specs }
PMAEditPostsDialog class >> defaultSpec [
	^ SpecLayout composed newColumn: [ :column |
		column
			add: #postList;
			newRow: [ :row |
				row
					add: #editPostTextInput;
					add: #addButton width: 50;
					add: #removeButton width: 50
			] height: self buttonHeight;
			newRow: [ :row |
				row
					add: #okButton;
					add: #cancelButton
			] height: self buttonHeight
	]
]

{ #category : #api }
PMAEditPostsDialog class >> open [
	^ self open: OrderedCollection empty
]

{ #category : #api }
PMAEditPostsDialog class >> open: posts [
	^ self openDialogConfiguredAs: [ :dialog |
		dialog posts: posts
	]
]

{ #category : #api }
PMAEditPostsDialog class >> openNoCancel [
	^ self openNoCancel: OrderedCollection empty
]

{ #category : #api }
PMAEditPostsDialog class >> openNoCancel: posts [
	^ self openDialogConfiguredAs: [ :dialog |
		dialog posts: posts.
		dialog cancelButton disable
	]
]

{ #category : #accessing }
PMAEditPostsDialog >> addButton [
	^ addButton
]

{ #category : #private }
PMAEditPostsDialog >> addedPosts [
	^ changes at: #added
]

{ #category : #accessing }
PMAEditPostsDialog >> cancelButton [
	^ cancelButton
]

{ #category : #private }
PMAEditPostsDialog >> changedPosts [
	^ changes at: #changed
]

{ #category : #accessing }
PMAEditPostsDialog >> editPostTextInput [
	^ editPostTextInput
]

{ #category : #api }
PMAEditPostsDialog >> extent [
	^ 400 @ 400
]

{ #category : #initialization }
PMAEditPostsDialog >> initializeChanges [
	changes := {
		#added -> OrderedCollection new.
		#removed -> OrderedCollection new.
		#changed -> OrderedCollection new.
	} asDictionary
]

{ #category : #initialization }
PMAEditPostsDialog >> initializePresenter [
	postList whenSelectionIndexChanged: [ 
		self onPostListSelectionIndexChanged
	].
	
	editPostTextInput whenTextChanged: [ 
		self onEditPostTextInputTextChanged
	].
	
	editPostTextInput bindKeyCombination: Character cr toAction: [ 
		postList selectedIndex isZero ifTrue: [ 
			self onAddButtonClick
		]
	].
	
	addButton action: [ 
		self onAddButtonClick
	].
	
	removeButton action: [ 
		self onRemoveButtonClick
	].
	
	okButton action: [ 
		self onOkButtonClick
	].
	
	cancelButton action: [ 
		self onCancelButtonClick
	].
	
	self initializeChanges
]

{ #category : #initialization }
PMAEditPostsDialog >> initializeWidgets [
	postList := self newList.
	editPostTextInput := self newTextInput.
	addButton := self newButton.
	removeButton := self newButton.
	okButton := self newButton.
	cancelButton := self newButton.
	
	postList
		beSingleSelection;
		displayBlock: [ :postItem | postItem postName ].
	editPostTextInput autoAccept: true.
	addButton label: '+'.
	removeButton label: '-'.
	okButton label: 'Ок'.
	cancelButton label: 'Отмена'.
	
	self focusOrder
		add: postList;
		add: editPostTextInput;
		add: addButton;
		add: removeButton;
		add: okButton;
		add: cancelButton
]

{ #category : #accessing }
PMAEditPostsDialog >> okButton [
	^ okButton
]

{ #category : #private }
PMAEditPostsDialog >> onAddButtonClick [
	| postName i newPost |
	postName := editPostTextInput text.
	postName ifEmpty: [ ^ self ].
	i := posts findFirst: [ :p | p postName = postName ].
	i isZero ifFalse: [ 
		postList setSelectedIndex: i.
		^ self
	].
	(newPost := PMAPost new)
		postName: postName.
	posts add: newPost.
	self updatePostList.
	i := self removedPosts findFirst: [ :p | p postName = postName ].
	i isZero ifTrue: [ 
		self addedPosts add: newPost
	]
	ifFalse: [ 
		self removedPosts removeAt: i
	]
]

{ #category : #private }
PMAEditPostsDialog >> onCancelButtonClick [
	self closeDialog: nil
]

{ #category : #private }
PMAEditPostsDialog >> onEditPostTextInputTextChanged [
	| i text |
	i := postList selectedIndex.
	(i isZero or: [ posts isNil or: [ posts isEmpty ] ]) ifTrue: [ ^ self ].
	text := editPostTextInput text.
	text ifNotEmpty: [ | changedPost |
		changedPost := posts at: i.
		changedPost postName = text ifTrue: [ ^ self ].
		changedPost postName: text.
		self updatePostList.
		postList setSelectedIndex: i.
		(self changedPosts includes: changedPost) ifTrue: [ ^ self ].
		(self addedPosts includes: changedPost) ifTrue: [ ^ self ].
		self changedPosts add: changedPost
	]
	ifEmpty: [ 
		self onRemoveButtonClick
	].
	
]

{ #category : #private }
PMAEditPostsDialog >> onOkButtonClick [
	posts ifEmpty: [ 
		^ PMAErrorDialog open: 'Добавьте как минимум одну должность.'
	].
	self closeDialog: changes
]

{ #category : #private }
PMAEditPostsDialog >> onPostListSelectionIndexChanged [
	| index |
	index := postList selectedIndex.
	(index isZero or: [ posts isNil or: [ posts isEmpty ] ]) ifTrue: [ 
		editPostTextInput text: String empty.
		addButton enable.
		^ self
	].
	addButton disable.
	editPostTextInput text: (posts at: index) postName
]

{ #category : #private }
PMAEditPostsDialog >> onRemoveButtonClick [
	| i removedPost |
	i := postList selectedIndex.
	i isZero ifTrue: [ ^ self ].
	removedPost := posts removeAt: i.
	self updatePostList.
	i := self addedPosts findFirst: [ :p | p postName = removedPost postName ].
	i isZero ifTrue: [ 
		self removedPosts add: removedPost
	]
	ifFalse: [ 
		self addedPosts removeAt: i
	].
	self changedPosts remove: removedPost ifAbsent: [  ]
]

{ #category : #accessing }
PMAEditPostsDialog >> postList [
	^ postList
]

{ #category : #'private - accessing' }
PMAEditPostsDialog >> posts [
	^ posts
]

{ #category : #'private - accessing' }
PMAEditPostsDialog >> posts: aCollection [
	posts := aCollection.
	postList
		items: posts;
		setSelectedIndex: 0
]

{ #category : #accessing }
PMAEditPostsDialog >> removeButton [
	^ removeButton
]

{ #category : #private }
PMAEditPostsDialog >> removedPosts [
	^ changes at: #removed
]

{ #category : #api }
PMAEditPostsDialog >> title [
	^ 'Редактирование списка должностей'
]

{ #category : #private }
PMAEditPostsDialog >> updatePostList [
	self posts: posts
]
