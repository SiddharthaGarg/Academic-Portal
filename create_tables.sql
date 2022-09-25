create table tickets(
	student_id varchar(50) not null,
	course_id varchar(50) not null,
	section_id int not null,
	semester int not null,
	year int not null,
	status int not null,
	constraint tickets_id primary key (student_id, course_id, section_id, semester, year),
	foreign key(course_id,section_id,semester,year) references section(course_id,section_id,semester,year),
	foreign key(course_id) references courses(course_id),
	foreign key(student_id) references students(student_id)
);


create table prerequisites (
	course_id varchar(50) not null primary key,
	course_list varchar[] not null,
	foreign key (course_id) references courses(course_id)
);

create table allowed_batches (
	course_id varchar(50) not null,
	section_id int not null,
	semester int not null,
	year int not null,
batch_list varchar[] not null,
	constraint allowed_batches_id primary key ( course_id, section_id, semester, year),
	foreign key(course_id) references courses(course_id),
	foreign key(course_id,section_id,semester,year) references section(course_id,section_id,semester,year)
);




create table time_slot(
	time_slot_id int not null primary key,
	start_time time not null,
	end_time time not null,
	day varchar(10) not null
);

create table section (
	course_id varchar(50) not null,
	section_id int not null,
	semester int not null,
	year int not null,
	time_slot_id int not null,
	room_no intl,
	building varchar(50),
min_cg numeric not null,
	constraint section_id primary key (course_id, section_id, semester, year),
	foreign key(course_id) references courses(course_id),
	foreign key(time_slot_id) references time_slot(time_slot_id)
);



create table faculty_advisor (
	faculty_id varchar not null primary key,
	name varchar(50) not null,
	department varchar(50) not null,
	batch_year int not null,
	foreign key(faculty_id) references teachers(faculty_id)
);


create table teaches (
	faculty_id varchar not null,
	course_id varchar(50) not null,
	section_id int not null,
	semester int not null,
	year int not null,
	constraint teaches_id primary key (faculty_id, course_id, section_id, semester, year),
	foreign key(faculty_id) references teachers(faculty_id),
	foreign key(course_id) references courses(course_id),
	foreign key(course_id,section_id,semester,year) references section(course_id,section_id,semester,year)
);


create table takes (
	student_id varchar(50) not null,
	course_id varchar(50) not null,
	section_id int not null,
	semester int not null,
	year int not null,
	grade int,
	constraint takes_id primary key (student_id, course_id, section_id, semester, year),
	foreign key(student_id) references students(student_id),
	foreign key(course_id) references courses(course_id),
	foreign key(course_id,section_id,semester,year) references section(course_id,section_id,semester,year)

);


create table teachers (
	faculty_id varchar not null primary key,
	name varchar(50) not null,
	department varchar(50) not null
);

create table students (
	student_id varchar(50) not null primary key,
	name varchar(50) not null,
	department varchar(50) not null,
	batch_year int not null
);

create table courses (
	course_id varchar(50) not null primary key,
	name varchar(50) not null,
	department varchar(50) not null,
	l numeric not null,
	t numeric not null,
	p numeric not null,
	s numeric not null,
	c numeric not null
);
