-- Student
create or replace procedure add_student(
	studentId varchar,
	name varchar,
	dep varchar,
	byr int
)
language plpgsql
as $$
declare
	v_password varchar;
begin
	v_password = '''iitropar''';
	insert into students (student_id, name, department, batch_year) values (studentId,name,dep,byr);
		
	EXECUTE 'CREATE USER "' || studentId || '" WITH PASSWORD ' || v_password;
	EXECUTE 'GRANT student TO "' || studentId || '"';
	EXECUTE 'GRANT CONNECT ON DATABASE postgres TO "' || studentId || '"';
end; $$


-- Faculty
create or replace procedure add_faculty(
	facultyId varchar,
	name varchar,
	dep varchar
)
language plpgsql
as $$
declare
	v_password varchar;
begin
	v_password = '''faculty''';
	insert into teachers (faculty_id, name, department) values (facultyId ,name,dep);
		
	EXECUTE 'CREATE USER "' || facultyId || '" WITH PASSWORD ' || v_password;
	EXECUTE 'GRANT faculty TO "' || FacultyId || '"';
	EXECUTE 'GRANT CONNECT ON DATABASE postgres TO "' || facultyId || '"';
end; $$


-- Faculty Advisor
create or replace procedure add_faculty_advisor(
	facultyId int,
	name varchar,
	dep varchar,
	byr int
)
language plpgsql
as $$
declare
	v_password varchar;
begin
	v_password = '''facultyadvisor''';
	insert into teachers (faculty_id, name, department) values (facultyId ,name,dep);
	insert into faculty_advisor (faculty_id, name, department, batch_year) values (facultyId ,name,dep,byr);
		
	EXECUTE 'CREATE USER "' || facultyId || '" WITH PASSWORD ' || v_password;
	EXECUTE 'GRANT faculty TO "' || FacultyId || '"';
	EXECUTE 'GRANT faculty_advisor TO "' || FacultyId || '"';
	EXECUTE 'GRANT CONNECT ON DATABASE postgres TO "' || facultyId || '"';
end; $$

-- Dean
Super Admin
