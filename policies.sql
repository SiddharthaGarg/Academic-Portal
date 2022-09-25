-- Ticket Table
alter table tickets enable row level security;


-- Policy for faculty to see only his tickets
create policy faculty_ticket_policy on tickets to faculty using (faculty_id = current_user);

-- Policy for faculty_advisor to see only his tickets
create policy faculty_advisor_ticket_policy on tickets to faculty_advisor using (faculty_advisor_id = current_user);

-- Takes Table
alter table takes enable row level security;
create policy takes_policy on takes to student using (student_id = current_user);

-- Students Table
alter table students enable row level security;
create policy students_policy on students to student using (student_id = current_user);
