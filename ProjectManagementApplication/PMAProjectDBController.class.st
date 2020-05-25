Class {
	#name : #PMAProjectDBController,
	#superclass : #PMADBController,
	#category : #'ProjectManagementApplication-Control'
}

{ #category : #accessing }
PMAProjectDBController class >> globalName [
	^ #PMAProjectDB
]

{ #category : #removing }
PMAProjectDBController class >> remove [
	instance ifNotNil: [ instance closeConnection ].
	super remove
]

{ #category : #private }
PMAProjectDBController >> createTableIfNotExistsQueries [
	^ {
		'CREATE TABLE IF NOT EXISTS employees (
			id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
			full_name varchar(255) NOT NULL,
			post_id integer(10) NOT NULL,
			FOREIGN KEY(post_id) REFERENCES posts(id)
		);'.
		'CREATE TABLE IF NOT EXISTS posts (
			id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
			post_name varchar(255) NOT NULL
		);'.
		'CREATE TABLE IF NOT EXISTS tasks (
			id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
			task_name integer(10) NOT NULL,
			start_date date NOT NULL,
			deadline date NOT NULL,
			is_done integer(10) NOT NULL,
			employee_id integer(10) NOT NULL,
			FOREIGN KEY(employee_id) REFERENCES employees(id)
		);'.
	}
]

{ #category : #api }
PMAProjectDBController >> dbFilename [
	^ 'project.db'
]

{ #category : #api }
PMAProjectDBController >> deleteEmployee: employee [
	self deleteEntity: employee.
	connection execute: 'DELETE FROM tasks WHERE employee_id = ?' value: employee id
]

{ #category : #api }
PMAProjectDBController >> deletePost: post [
	self deleteEntity: post.
	connection execute: 'DELETE FROM employees WHERE post_id = ?' value: post id
]

{ #category : #api }
PMAProjectDBController >> deleteTask: task [
	self deleteEntity: task
]

{ #category : #private }
PMAProjectDBController >> dropTableQueries [
	^ {
		'DROP TABLE employees;'.
		'DROP TABLE posts;'.
		'DROP TABLE tasks;'.
	}
]

{ #category : #api }
PMAProjectDBController >> dropTables [
	connection
		execute: 'DROP TABLE employees;';
		execute: 'DROP TABLE posts;';
		execute: 'DROP TABLE tasks;'
]

{ #category : #api }
PMAProjectDBController >> employeeWithId: id [
	| cursor |
	cursor := connection execute: 'SELECT * FROM employees WHERE id = ?' value: id.
	^ cursor nextOfClassFixed: PMAEmployee
]

{ #category : #api }
PMAProjectDBController >> employees [
	^ self selectAllFrom: #employees entityClass: PMAEmployee
]

{ #category : #api }
PMAProjectDBController >> employeesWithPost: post [
	| cursor |
	cursor := connection execute: 'SELECT * FROM employees WHERE post_id = ?' value: post id.
	^ cursor rowsOfClassFixed: PMAEmployee
]

{ #category : #example }
PMAProjectDBController >> example [
	| posts employees tasks ids |
	
	self
		closeConnection;
		openConnection;
		dropTables;
		closeConnection;
		openConnection.
	
	posts := { 
		'Руководитель'.
		'Аналитик'.
		'Дизайнер'.
		'Верстальщик'.
		'Программист'
	} collect: [ :p |
		PMAPost new
			postName: p;
			yourself
	].
	
	posts do: [ :p | self insertPost: p ].
	ids := (posts collect: [ :p | p postName -> p id ]) asDictionary.
	
	employees := { 
		PMAEmployee new
			fullName: 'Петрова Татьяна Григорьевна';
			postId: (ids at: 'Руководитель'); yourself.
		PMAEmployee new
			fullName: 'Воробей Станислав Михайлович';
			postId: (ids at: 'Аналитик'); yourself.
		PMAEmployee new
			fullName: 'Блинов Лавр Львович';
			postId: (ids at: 'Дизайнер'); yourself.
		PMAEmployee new
			fullName: 'Соболев Елисей Денисович';
			postId: (ids at: 'Верстальщик'); yourself.
		PMAEmployee new
			fullName: 'Молчанова Рая Михаиловна';
			postId: (ids at: 'Программист'); yourself.
		PMAEmployee new
			fullName: 'Сафонов Владимир Робертович';
			postId: (ids at: 'Программист'); yourself.
	}.
	
	employees do: [ :e | self insertEmployee: e ].
	ids := (employees collect: [ :e | e fullName -> e id ]) asDictionary.
	
	tasks := { 
		PMATask new
			taskName: 'Анализ конкуренции';
			employeeId: (ids at: 'Воробей Станислав Михайлович');
			isDone: true;
			startDate: '02/11/2002' asDate;
			deadline: '02/13/2002' asDate;
			yourself.
		PMATask new
			taskName: 'Анализ целевой аудитории';
			employeeId: (ids at: 'Воробей Станислав Михайлович');
			isDone: true;
			startDate: '02/14/2002' asDate;
			deadline: '02/17/2002' asDate;
			yourself.
		PMATask new
			taskName: 'Разработка и утверждение концепта сайта';
			employeeId: (ids at: 'Петрова Татьяна Григорьевна');
			isDone: true;
			startDate: '02/18/2002' asDate;
			deadline: '02/18/2002' asDate;
			yourself.
		PMATask new
			taskName: 'Составление  ТЗ';
			employeeId: (ids at: 'Петрова Татьяна Григорьевна');
			isDone: true;
			startDate: '02/19/2002' asDate;
			deadline: '02/19/2002' asDate;
			yourself.
		PMATask new
			taskName: 'Разработка коллажей для разделов сайта';
			employeeId: (ids at: 'Блинов Лавр Львович');
			isDone: true;
			startDate: '02/20/2002' asDate;
			deadline: '02/24/2002' asDate;
			yourself.
		PMATask new
			taskName: 'Верстка шаблонов страниц';
			employeeId: (ids at: 'Соболев Елисей Денисович');
			isDone: false;
			startDate: '02/24/2002' asDate;
			deadline: '02/27/2002' asDate;
			yourself.
		PMATask new
			taskName: 'Программирование взаимодействия с БД';
			employeeId: (ids at: 'Молчанова Рая Михаиловна');
			isDone: false;
			startDate: '02/24/2002' asDate;
			deadline: '03/02/2002' asDate;
			yourself.
		PMATask new
			taskName: 'Программирование разделов сайта';
			employeeId: (ids at: 'Сафонов Владимир Робертович');
			isDone: false;
			startDate: '03/03/2002' asDate;
			deadline: '03/27/2002' asDate;
			yourself.
		PMATask new
			taskName: 'Заполнение страниц и тестирование на реальных данных';
			employeeId: (ids at: 'Сафонов Владимир Робертович');
			isDone: false;
			startDate: '03/28/2002' asDate;
			deadline: '03/29/2002' asDate;
			yourself.
		PMATask new
			taskName: 'Доработка кода, исправление ошибок';
			employeeId: (ids at: 'Сафонов Владимир Робертович');
			isDone: false;
			startDate: '03/30/2002' asDate;
			deadline: '04/04/2002' asDate;
			yourself.
		PMATask new
			taskName: 'Сдача сайта заказчику';
			employeeId: (ids at: 'Петрова Татьяна Григорьевна');
			isDone: false;
			startDate: '04/05/2002' asDate;
			deadline: '04/05/2002' asDate;
			yourself.
	}.
	
	tasks do: [ :t | self insertTask: t ]
]

{ #category : #api }
PMAProjectDBController >> insertEmployee: employee [
	^ self insertEntity: employee
]

{ #category : #api }
PMAProjectDBController >> insertPost: post [
	^ self insertEntity: post
]

{ #category : #api }
PMAProjectDBController >> insertTask: task [
	^ self insertEntity: task
]

{ #category : #api }
PMAProjectDBController >> postOfEmployee: employee [
	| cursor |
	cursor := connection execute: 'SELECT * FROM posts WHERE id = ?' value: employee postId.
	^ cursor nextOfClassFixed: PMAPost
]

{ #category : #'private - accessing' }
PMAProjectDBController >> posts [
	^ self selectAllFrom: #posts entityClass: PMAPost
]

{ #category : #accessing }
PMAProjectDBController >> tasks [
	^ self selectAllFrom: #tasks entityClass: PMATask
]

{ #category : #api }
PMAProjectDBController >> tasksOfEmployee: employee [
	^ self tasksOfEmployeeWithId: employee id
]

{ #category : #api }
PMAProjectDBController >> tasksOfEmployeeWithId: id [
	| cursor |
	cursor := connection execute: 'SELECT * FROM tasks WHERE employee_id = ?' value: id.
	^ cursor rowsOfClassFixed: PMATask
]

{ #category : #api }
PMAProjectDBController >> updateEmployee: employee [
	self updateEntity: employee
]

{ #category : #api }
PMAProjectDBController >> updatePost: post [
	self updateEntity: post
]

{ #category : #api }
PMAProjectDBController >> updateTask: task [
	self updateEntity: task
]
