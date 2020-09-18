USE                       db_University_basic;
show tables;
select * from instructor;
select * from course;
select * from department;
select * from teaches;
select * from classroom;
select * from section;
select * from student;
#1. Fetch the name of all the instructors using as column alias professor_name. 
select name as professor_name from instructor;

#2. Fetch the name of all the instructors using the alias PROFESSOR_NAME. Names of the faculty 
# should be all CAPITAL LETTERS. 
select UPPER(name) as PROFESSOR_NAME from instructor;

#3. Fetch the name of all the different departments that appear in the table course. 
select distinct(dept_name) from course;

#4. Write a query to recover the first 4 characters (including white spaces) from the name of each 
#instructor. Do not worry if the outcome is meaningless.  Just make sure the 4 characters appear.  
select substring(name,1,4) from instructor;

#5. Write a query to recover all the instructors whose names start with the letter E. 
select name from instructor where name regexp '^E';

#6. Write a query to print the title of all the courses removing all the any extra white spaces from the 
#left (in case those actually existed). 
select trim(leading '' from title) from course;
select trim(trailing from title) from course;

#7. Print the length of all the names of the instructors. For example, the length of Einstein is 8. Do not 
#worry for white spacing. For example ‘El Said’ should have length 7. 
select length(name),name from instructor;

#8. Write a query to write, on a single column named IS_LOCATED the following string 
#a. ‘The  department: ’, +    name_of_the_department  + ,   ‘  is  located  at: ’    +  name  of  the building. 
select concat('The  department: ', dept_name, ' is located at: ', building)as IS_LOCATED from department;

#9. Write a query to recover all the information of the table instructor ordered by department and salary. 
select * from instructor order by dept_name,salary; 

#10.Write a query that recovers the information of all the instructors in the departments of History and Finance. 
select * from instructor where dept_name = 'History' or dept_name = 'Finance';

#11. Write a query that recovers all the instructors in departments other than of history and Finance. 
select * from instructor where dept_name != 'History' and dept_name != 'Finance';

#12. List all the departments whose name has 7 letters. 
select dept_name from department where length(dept_name) = 7;

#13. List all the instructors that have taught at least once in the Packard building. 
select distinct(name), building,a.course_id from
(select name,course_id from instructor inner join
teaches on instructor.id = teaches.id) as a
inner join section as b on a.course_id = b.course_id
where building = 'Packard';

select name from instructor where id in
(select id from teaches where course_id in
(select course_id from section where building =  'Packard'));

#14.List all the instructors with a wage between $70 and $90K. 
select name,salary from instructor where salary between 70e3 and 90e3;

#15. Write a query that reports the names of all the  faculty of the courses in the computer science 
#department. Make sure there are no duplicities in the final table. 
select distinct(name),c.dept_name from
(select a.course_id,dept_name,b.id as ins_id from
(select * from course where dept_name like 'Comp%') as a
inner join
teaches as b
on a.course_id = b.course_id) as c
inner join
instructor as d
on c.ins_id = d.id;

select name 
from instructor where id in
(select id
from teaches where course_id in
(select course_id from course where dept_name like 'Comp%'));

#16. Write a query to show only the even rows from the student table. 
select * from
(select a.*, (@rowNumber := @rowNumber +1)as row_id from student as a
join (select @rowNumber := 0) as b) as t
where row_id % 2=0;

#17. Write a query to show only odd rows from the student table. 
select * from
(select a.*, (@rowNumber := @rowNumber +1)as row_id from student as a
join (select @rowNumber := 0) as b) as t
where row_id % 2=1;

#18.Write a query to recover the current date. 
select current_date();

#19. Write a query to recover the 3rd highest salary. 
select * from instructor order by salary desc limit 2,1;

#20. Write a query to recover the top 3 salaries of the instructors.
select * from instructor order by salary desc limit 3;

#21. Write a query to recover the bottom 3 salaries of the instructors. 
select * from instructor order by salary limit 3;

#22. Write  a  query  to  recover  the  name  of  all  the  faculty  with  a  salary  above  the  mean  of  their 
#department. 
select name,a.dept_name,salary,avg_salary from
(select avg(salary) as avg_salary,dept_name from instructor group by dept_name) as a
inner join instructor as b on a.dept_name = b.dept_name
where salary > avg_salary;
