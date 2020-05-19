Extension { #name : #ComposablePresenter }

{ #category : #'*ProjectManagementApplication' }
ComposablePresenter >> newDataTable [
	^ FTTableMorph new
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		beResizable;
		asSpecAdapter
]
