Extension { #name : #String }

{ #category : #'*ProjectManagementApplication' }
String >> snakeToCamel [
	^ self class streamContents: [ :stream |
		self splitOn: $_ do: [ :sub |
			stream nextPutAll: sub capitalized
		]
	]
]
