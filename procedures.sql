
-- Dean adding a course --
create or replace procedure add_course(course_id varchar,name varchar,department varchar,l numeric, t numeric, p numeric, s numeric, c numeric)
language plpgsql
as $$
declare
-- variable declaration
begin
-- stored procedure body
	Insert into courses(course_id,name,department,l,t,p,s,c) values (course_id,name,department,l,t,p,s,c);
	
end; $$

-- Faculty offering a course --
create or replace procedure offer_course(offer_course_id varchar, offer_section_id int, offer_semester int, offer_year int,offer_time_slot_id int,offer_prerequisites_list varchar[],offer_allowed_batches varchar[],offer_min_cg int)
language plpgsql
as $$
declare
-- variable declaration
	find_course courses%rowtype;
	find_time_slot time_slot%rowtype;
	find_section section%rowtype;
begin
-- stored procedure body
-- faculty id ko dynamically lene ka try krna hai
	Select * from courses into find_course where courses.course_id = offer_course_id;
	if not found then
		raise notice 'The given course id % is not present in the course catalogue',offer_course_id;
	else 
		Select * from time_slot into find_time_slot where time_slot.time_slot_id = offer_time_slot_id;
		if not found then
			raise notice 'The given time_slot_id % is not present in the time slots provided by dean academic office',offer_time_slot_id;
		else
			Select * from section into find_section where section.course_id = offer_course_id AND section.section_id = offer_section_id AND section.semester = offer_semester AND section.year = offer_year;
			if found then
				raise notice 'This course is being offered already,if you want to offer it with a different section_id';
			else
				Insert into section(course_id,section_id,semester,year,time_slot_id,room_no,building,min_cg) Values(offer_course_id,offer_section_id,offer_semester,offer_year,offer_time_slot_id,NULL,NULL,offer_min_cg);
				Insert into teaches(faculty_id,course_id,section_id,semester,year) Values(current_user,offer_course_id,offer_section_id,offer_semester,offer_year);	
				Insert into allowed_batches(course_id,section_id,semester,year,batch_list) Values(offer_course_id,offer_section_id,offer_semester,offer_year,offer_allowed_batches);
				Insert into prerequisites(course_id,section_id,semester,year,prerequisites_list) Values(offer_course_id,offer_section_id,offer_semester,offer_year,offer_prerequisites_list);
			end if;
		end if;
	end if;
end; $$

-- Show which rooms and buildings are free --
create or replace procedure show_unallocated_sections()
language plpgsql
as $$
declare
-- variable declaration
	unallocated_cursor cursor for select * from section where room_no is null and building is null;
	row_unallocated_section record;
begin
-- stored procedure body
	open unallocated_cursor;
	loop
		fetch unallocated_cursor into row_unallocated_section;
		exit when not found;
		
		raise notice 'Course_Id : %, Section_Id : %, Semester : %, Year : %, Time_Slot_Id : %',row_unallocated_section.course_id,row_unallocated_section.section_id,row_unallocated_section.semester,row_unallocated_section.year,row_unallocated_section.time_slot_id;
	end loop;
	close unallocated_cursor;
end; $$


-- Student registering a course --
create or replace procedure register_course(register_course_id varchar, register_section_id int,register_semester int,register_year int)
language plpgsql
as $$
declare
-- variable declaration
	credit_limit numeric := 0;
	current_credits int:= 0;
	credits_after_taking_course int := 0;
	credit_sum numeric :=0;
	credit_sum_temp numeric :=0;
	register_batch_year int;
	credit_limit_flag int := 0;
	min_cg_requirement int :=0;
	time_slot_for_course int;
	allowed_branches_flag int := 0;
	min_cg_flag int := 0;
	time_slot_flag int :=1;
	course_exists int := 0;
	allowed_batch_list varchar[];
	my_department varchar;
	
	time_slot_cursor cursor for select * from takes,section where takes.student_id = current_user and takes.semester = register_semester and takes.year = register_year and takes.course_id = section.course_id and takes.section_id = section.section_id and takes.semester = section.semester and takes.year = section.year;
	time_slot_row record;
	
	-- cgpa calculation
	sum_prod_grade_credits numeric :=0;
	sum_credits numeric :=0;
	cgpa_value numeric :=0;
	cgpa_cursor cursor for select * from takes,courses where takes.course_id = courses.course_id and takes.student_id = current_user;
	row_cgpa record;
	
	-- course pre-requisite list
	course_prerequisite_list varchar[];
	prerequisite_flag int := 1;
	is_completed_prerequisite int;
begin
-- stored procedure body
	-- If he is in the first year of college he can take max 18 credits
	select batch_year into register_batch_year from students where students.student_id = current_user;
	
	select Count(*) into course_exists from section where section.course_id = register_course_id and section.section_id = register_section_id and section.semester = register_semester and section.year = register_year;
	
	if register_batch_year = register_year then
		credit_limit = 18;
	else 
		if register_semester = 1 then
			select sum(courses.c) into credit_sum from takes,courses where takes.student_id = current_user and takes.course_id = courses.course_id and takes.year = (register_year-1);
			credit_limit = 1.25*credit_sum;
		elsif register_semester = 2 then
			select sum(courses.c) into credit_sum_temp from takes,courses where takes.student_id = current_user and takes.course_id = courses.course_id and takes.year = register_year and takes.semester = 1;
			select sum(courses.c) into credit_sum from takes,courses where takes.student_id = current_user and takes.course_id = courses.course_id and takes.year = (register_year-1) and takes.semester = 2;
			credit_sum = credit_sum + credit_sum_temp;
			credit_limit = 1.25*credit_sum;
		else
			raise notice 'Invalid semester number, allowed values 1 and 2';
		end if;
	end if;
	
	select sum(courses.c) into current_credits from takes,courses where takes.student_id = current_user and takes.course_id = courses.course_id and takes.year = register_year and takes.semester = register_semester;
	select sum(courses.c) into credits_after_taking_course from courses where courses.course_id = register_course_id;
	if current_credits is null then
		current_credits = 0;
	end if;
	credits_after_taking_course = credits_after_taking_course + current_credits;
	if(credits_after_taking_course <= credit_limit) then
		credit_limit_flag = 1;
	end if;
	
	select allowed_batches.batch_list into allowed_batch_list from allowed_batches where allowed_batches.course_id = register_course_id and allowed_batches.section_id = register_section_id and allowed_batches.semester = register_semester and allowed_batches.year = register_year;
	select students.department into my_department from students where students.student_id = current_user;
	
	if(array_length(allowed_batch_list, 1) is not null) then
		for counter in 1..array_length(allowed_batch_list, 1) loop
			if(allowed_batch_list[counter] = my_department) then
				allowed_branches_flag = 1;
			end if;
		end loop;
	end if;
	
	select section.min_cg into min_cg_requirement from section where section.course_id = register_course_id and section.section_id = register_section_id and section.semester = register_semester and section.year = register_year;
	-- compare cgpa set flag
	open cgpa_cursor;
	loop
		fetch cgpa_cursor into row_cgpa;
		exit when not found;
		if(row_cgpa.grade is not null) then
			sum_prod_grade_credits = sum_prod_grade_credits + row_cgpa.grade*row_cgpa.c;
			sum_credits = sum_credits + row_cgpa.c;
		end if;
	end loop;
	close cgpa_cursor;
	if(sum_prod_grade_credits != 0) then
		cgpa_value = sum_prod_grade_credits/sum_credits;
	end if;
	if(cgpa_value >= min_cg_requirement) then
		min_cg_flag = 1;
	end if;
	
	
	select section.time_slot_id into time_slot_for_course from section where section.course_id = register_course_id and section.section_id = register_section_id and section.semester = register_semester and section.year = register_year;
	
	open time_slot_cursor;
	loop
		fetch time_slot_cursor into time_slot_row; 
		exit when not found;
		if(time_slot_row.time_slot_id = time_slot_for_course) then
			time_slot_flag = 0;
		end if;
	end loop;
	close time_slot_cursor;
	
	select prerequisites.prerequisites_list into course_prerequisite_list from prerequisites where prerequisites.course_id = register_course_id and prerequisites.section_id = register_section_id and prerequisites.semester = register_semester and prerequisites.year = register_year;
	if(array_length(course_prerequisite_list, 1) is not null) then
		for counter in 1..array_length(course_prerequisite_list, 1) loop
			select count(*) into is_completed_prerequisite from takes where takes.student_id = current_user and takes.course_id = course_prerequisite_list[counter];
			if(is_completed_prerequisite = 0) then
				prerequisite_flag = 0;
			end if;
		end loop;
	end if;
	
	
	if(course_exists=1 and credit_limit_flag =1 and allowed_branches_flag=1 and min_cg_flag=1 and prerequisite_flag=1 and time_slot_flag=1) then
		raise notice 'Course Succesfully registered';
	else
		raise notice 'prerequisite_flag %',prerequisite_flag;
		if(course_exists = 0) then
			raise notice 'The course you are trying to take is not offered or does not exist';
		elsif (credit_limit_flag = 0) then
			raise notice 'You cannot exceed the credit limit of %',credit_limit;
		elsif (allowed_branches_flag = 0) then
			raise notice 'Your branch is not allowed for this course';
		elsif (min_cg_flag = 1) then
			raise notice 'Your cgpa does not pass the minimum cgpa critera';
		elsif (prerequisite_flag = 1) then
			raise notice 'You have not done the pre-requisites for this course';
		else
			raise notice 'You already have taken another course in the same time slot';
		end if;
	end if;
end; 
$$

-- Calculates CGPA based of a student --
create or replace procedure calculate_cgpa(cgpa_student_id varchar)
language plpgsql
as $$
declare
-- variable declaration
	sum_prod_grade_credits numeric :=0;
	sum_credits numeric :=0;
	cgpa_value numeric :=0;
	cgpa_cursor cursor for select * from takes,courses where takes.course_id = courses.course_id and takes.student_id = cgpa_student_id;
	row_cgpa record;
begin
-- stored procedure body
	open cgpa_cursor;
	loop
		fetch cgpa_cursor into row_cgpa;
		exit when not found;
		if(row_cgpa.grade is not null) then
			sum_prod_grade_credits = sum_prod_grade_credits + row_cgpa.grade*row_cgpa.c;
			sum_credits = sum_credits + row_cgpa.c;
		end if;
	end loop;
	close cgpa_cursor;
	cgpa_value = sum_prod_grade_credits/sum_credits;
	raise notice 'Your cgpa is %',cgpa_value;
end; $$

-- Take grades from a CSV file and update it in the database --
create or replace procedure take_csv(
	courseId varchar(50),
	sectionId int,
	sem int,
	yr int,
	csv_file_path text
)
language plpgsql
as $$
declare
-- variable declaration
begin
	truncate table grades;

	EXECUTE format ('
   COPY grades(student_id, grade)
   FROM %L (FORMAT CSV, HEADER)'  -- current syntax
           -- WITH CSV HEADER'    -- tolerated legacy syntax
   , $1);
	
	UPDATE takes
	SET grade = grades.grade
	FROM grades
	WHERE takes.course_id = courseId and takes.section_id = sectionId and takes.semester = sem and takes.year = yr and takes.student_id = grades.student_id;
end; $$

-- Generate transcript for the student --
create or replace procedure generate_transcript(report_student_id varchar)
language plpgsql
as $$
declare
-- variable declaration
	sum_prod_grade_credits numeric :=0;
	sum_credits numeric :=0;
	cgpa_value numeric :=0;
	cgpa_cursor cursor for select * from takes,courses where takes.course_id = courses.course_id and takes.student_id = report_student_id;
	row_cgpa record;
begin
-- stored procedure body
	open cgpa_cursor;
	loop
		fetch cgpa_cursor into row_cgpa;
		exit when not found;
		if(row_cgpa.grade is not null) then
			raise notice 'Course : %, Year : %, Semester : %, Grade : %',row_cgpa.course_id,row_cgpa.year,row_cgpa.semester,row_cgpa.grade;
			sum_prod_grade_credits = sum_prod_grade_credits + row_cgpa.grade*row_cgpa.c;
			sum_credits = sum_credits + row_cgpa.c;
		end if;
	end loop;
	close cgpa_cursor;
	cgpa_value = sum_prod_grade_credits/sum_credits;
	raise notice 'Your cgpa is %',cgpa_value;
end; $$

-- Students can view their tickets --
create or replace procedure view_my_tickets(tickets_student_id varchar)
language plpgsql
as $$
declare
-- variable declaration
	ticket_cursor cursor for select * from tickets where tickets.student_id = tickets_student_id;
	row_ticket record;
begin
-- stored procedure body
	open ticket_cursor;
	loop
		fetch ticket_cursor into row_ticket;
		exit when not found;
		
		raise notice 'Course_Id : %, Section_Id : %, Semester : %, Year : %, Status : %',row_ticket.course_id,row_ticket.section_id,row_ticket.semester,row_ticket.year,row_ticket.status;
	end loop;
	close ticket_cursor;
end; $$

-- Generating ticket by student --
create or replace procedure create_ticket(ticket_course_id varchar,ticket_section_id int,ticket_semester int,ticket_year int)
language plpgsql
as $$
declare
-- variable declaration
ticket_faculty_id varchar;
ticket_faculty_advisor_id varchar;
student_department varchar;
student_batch_year int;
begin
-- 
	select faculty_id into ticket_faculty_id from teaches where teaches.course_id = ticket_course_id and teaches.section_id = ticket_section_id and teaches.semester = ticket_semester and teaches.year = ticket_year;
	select department,batch_year into student_department,student_batch_year from students where students.student_id = current_user;
	
	select faculty_id into ticket_faculty_advisor_id from faculty_advisor where faculty_advisor.department = student_department and faculty_advisor.batch_year = student_batch_year;
	Insert into tickets(student_id,course_id,section_id,semester,year,status,faculty_id,faculty_advisor_id) Values(current_user,ticket_course_id,ticket_section_id,ticket_semester,ticket_year,0,ticket_faculty_id,ticket_advisor);
	
end; $$

	
end; $$

-- View tickets by faculty --
create or replace procedure view_faculty_tickets(tickets_faculty_id int)
language plpgsql
as $$
declare
-- variable declaration
	ticket_cursor cursor for select * from tickets,teaches where teaches.course_id = tickets.course_id and teaches.faculty_id = tickets_faculty_id and tickets.status = 0;
	row_ticket record;
begin
-- stored procedure body
	open ticket_cursor;
	loop
		fetch ticket_cursor into row_ticket;
		exit when not found;
		
		raise notice 'Student_Id : %,Course_Id : %, Section_Id : %, Semester : %, Year : %, Status : %',row_ticket.student_id,row_ticket.course_id,row_ticket.section_id,row_ticket.semester,row_ticket.year,row_ticket.status;
	end loop;
	close ticket_cursor;
end; $$


-- View tickets by faculty advisor --
create or replace procedure view_faculty_advisor_tickets(tickets_faculty_id int)
language plpgsql
as $$
declare
-- variable declaration
	ticket_cursor cursor for select * from tickets,faculty_advisor,students where tickets.student_id = students.student_id and faculty_advisor.faculty_id =tickets_faculty_id and students.department = faculty_advisor.department and students.batch_year = faculty.batch_year and tickets.status = 2; 
	row_ticket record;
begin
-- stored procedure body
	open ticket_cursor;
	loop
		fetch ticket_cursor into row_ticket;
		exit when not found;
		
		raise notice 'Student_Id : %,Course_Id : %, Section_Id : %, Semester : %, Year : %, Status : %',row_ticket.student_id,row_ticket.course_id,row_ticket.section_id,row_ticket.semester,row_ticket.year,row_ticket.status;
	end loop;
	close ticket_cursor;
end; $$


-- View tickets by dean -- 
create or replace procedure view_dean_tickets(tickets_faculty_id int)
language plpgsql
as $$
declare
-- variable declaration
	ticket_cursor cursor for select * from tickets where tickets.status = 4;
	row_ticket record;
begin
-- stored procedure body
	open ticket_cursor;
	loop
		fetch ticket_cursor into row_ticket;
		exit when not found;
		
		raise notice 'Student_Id : %,Course_Id : %, Section_Id : %, Semester : %, Year : %, Status : %',row_ticket.student_id,row_ticket.course_id,row_ticket.section_id,row_ticket.semester,row_ticket.year,row_ticket.status;
	end loop;
	close ticket_cursor;
end; $$


-- UPDATE TICKETS STATUS BY FACULTY --
create or replace procedure update_faculty_tickets(tickets_student_id varchar,tickets_course_id varchar, tickets_section_id int, tickets_semester int, tickets_year int, tickets_status int)
language plpgsql
as $$
declare
-- variable declaration
	
begin
-- stored procedure body
	update tickets set status = tickets_status where tickets.student_id = tickets_student_id and tickets.section_id = tickets_section_id and tickets.semester = tickets_semester and tickets.year = tickets_year;
end; $$


-- UPDATE TICKETS STATUS BY FACULTY_ADVISOR --
create or replace procedure update_faculty_advisor_tickets(tickets_student_id varchar,tickets_course_id varchar, tickets_section_id int, tickets_semester int, tickets_year int, tickets_status int)
language plpgsql
as $$
declare
-- variable declaration
	
begin
-- stored procedure body
	update tickets set status = tickets_status where tickets.student_id = tickets_student_id and tickets.section_id = tickets_section_id and tickets.semester = tickets_semester and tickets.year = tickets_year;
end; $$


--UPDATE TICKETS STATUS BY DEAN --
create or replace procedure update_dean_tickets(tickets_student_id varchar,tickets_course_id varchar, tickets_section_id int, tickets_semester int, tickets_year int, tickets_status int)
language plpgsql
as $$
declare
-- variable declaration
	
begin
-- stored procedure body
	if tickets_status = 6 then
		insert into takes(student_id, course_id, section_id, semester, year, grade) values(tickets_student_id, tickets_course_id, tickets_section_id, tickets_semester, tickets_year,null);
	end if;
	delete from tickets where tickets.student_id = tickets_student_id and tickets.section_id = tickets_section_id and tickets.semester = tickets_semester and tickets.year = tickets_year;
	
end; $$

-- add_room by dean --
create or replace procedure assign_room(assign_course_id varchar, assign_section_id int, assign_semester int, assign_year int,room int, build varchar)
language plpgsql
as $$
declare
	section_cursor cursor for select * from section;
	section_row record;
	current_time_slot int;
	flag_assign int := 0;
begin
	select time_slot_id into current_time_slot from section where course_id = assign_course_id and section_id = assign_section_id and semester = assign_semester and year = assign_year;
	open section_cursor;
	loop
		
		fetch section_cursor into section_row;
		exit when not found;
		
		if (section_row.time_slot_id = current_time_slot and section_row.room_no = room and section_row.building = build and section_row.year = assign_year and section_row.semester = assign_semester) then
		flag_assign = 1;
		end if;
	end loop;
	
	if flag_assign = 1 then
	raise notice 'This Room % in Building % is already allocated to another course in same time-slot',room,build;
	else
	update section set room_no = room, building = build where course_id = assign_course_id and section_id = assign_section_id and semester = assign_semester and year = assign_year;
	end if;
end; $$
