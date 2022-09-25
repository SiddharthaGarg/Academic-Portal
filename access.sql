-- TABLES
grant select on courses,teaches,teachers,section,allowed_batches,time_slot,prerequisites to student;
grant select on courses,students,takes,section,allowed_batches,time_slot,prerequisites,tickets to faculty;
grant insert on allowed_batches,prerequisites,section,teaches to faculty;
grant update on allowed_batches,prerequisites,tickets to faculty;
grant delete on allowed_batches,prerequisites to faculty;
grant select on tickets to faculty_advisor;
grant update on tickets to faculty_advisor;
GRANT EXECUTE ON procedure public.register_course(varchar, integer, integer,integer) TO student;
Grant select on students to student;
Grant select on section to student;
Grant select on takes to student;
Grant select on allowed_batches to student;
Grant select on prerequisites to student;
Grant insert on takes to student;
grant update on takes to faculty;
grant select on teaches to student;
grant select on faculty_advisor to student;
grant select on tickets to student;
grant delete on tickets to faculty;
grant delete on tickets to faculty_advisor;
grant select on teaches to student;
grant select on faculty_advisor to student;
grant insert on tickets to student;
grant select on tickets to student;
grant delete on tickets to faculty;
grant delete on tickets to faculty_advisor;

-- PROCEDURES
-- add_course
REVOKE EXECUTE ON procedure public.add_course(varchar,varchar,varchar,numeric,numeric,numeric,numeric,numeric) FROM public; 

GRANT EXECUTE ON procedure public.add_course(varchar,varchar,varchar,numeric,numeric,numeric,numeric,numeric) TO dean;

-- add_course_time_slot
REVOKE EXECUTE ON procedure public.add_course_time_slot(int,time,time,varchar) FROM public; 

GRANT EXECUTE ON procedure public.add_course_time_slot(int,time,time,varchar) TO dean;


-- add_faculty
REVOKE EXECUTE ON procedure public.add_faculty(varchar,varchar,varchar) FROM public; 

GRANT EXECUTE ON procedure public.add_faculty(varchar,varchar,varchar) TO dean;


-- add_faculty_advisor
REVOKE EXECUTE ON procedure public.add_faculty_advisor(varchar,varchar,varchar,int) FROM public; 

GRANT EXECUTE ON procedure public.add_faculty_advisor(varchar,varchar,varchar,int) TO dean;


-- add_student
REVOKE EXECUTE ON procedure public.add_student(varchar,varchar,varchar,int) FROM public; 

GRANT EXECUTE ON procedure public.add_student(varchar,varchar,varchar,int) TO dean;


-- assign_room
REVOKE EXECUTE ON procedure public.assign_room(varchar,int,int,int,int,varchar) FROM public; 

GRANT EXECUTE ON procedure public.assign_room(varchar,int,int,int,int,varchar) TO dean;


-- calculate_cgpa
REVOKE EXECUTE ON procedure public.calculate_cgpa() FROM public;
 
GRANT EXECUTE ON procedure public.calculate_cgpa() TO student;


-- create_ticket
REVOKE EXECUTE ON procedure public.create_ticket(varchar,int,int,int) FROM public;
 
GRANT EXECUTE ON procedure public.create_ticket(varchar,int,int,int) TO student;


-- generate_transcript
REVOKE EXECUTE ON procedure public.generate_transcript(varchar) FROM public; 

GRANT EXECUTE ON procedure public.generate_transcript(varchar) TO dean;


-- grade_entry
REVOKE EXECUTE ON procedure public.grade_entry(varchar,int,int,int,text) FROM public;
 
GRANT EXECUTE ON procedure public.grade_entry(varchar,int,int,int,text) TO faculty;


-- offer_course
REVOKE EXECUTE ON procedure public.offer_course(varchar,int,int,int,int,varchar[],varchar[],int) FROM public; 
GRANT EXECUTE ON procedure public.offer_course(varchar,int,int,int,int,varchar[],varchar[],int) TO faculty;


-- register_course
REVOKE EXECUTE ON procedure public.register_course(varchar,int,int,int) FROM public; 

GRANT EXECUTE ON procedure public.register_course(varchar,int,int,int) TO student;


-- show_unallocated_sections
REVOKE EXECUTE ON procedure public.show_unallocated_sections() FROM public; 

GRANT EXECUTE ON procedure public.show_unallocated_sections() TO dean;



-- update_dean_tickets
REVOKE EXECUTE ON procedure public.update_dean_tickets(varchar,varchar,int,int,int,int) FROM public; 

GRANT EXECUTE ON procedure public.update_dean_tickets(varchar,varchar,int,int,int,int) TO dean;



-- update_faculty_tickets
REVOKE EXECUTE ON procedure public.update_faculty_tickets(varchar,varchar,int,int,int,int) FROM public; 

GRANT EXECUTE ON procedure public.update_faculty_tickets(varchar,varchar,int,int,int,int) TO faculty;



-- update_faculty_advisor_tickets
REVOKE EXECUTE ON procedure public.update_faculty_advisor_tickets(varchar,varchar,int,int,int,int) FROM public; 

GRANT EXECUTE ON procedure public.update_faculty_advisor_tickets(varchar,varchar,int,int,int,int) TO faculty_advisor;
