/* Solving Tricky SQL Queries */

drop table if exists students
CREATE TABLE students(
 studentid int NULL,
 studentname varchar(255) NULL,
 subject varchar(255) NULL,
 marks int NULL,
 testid int NULL,
 testdate date NULL
) ;

insert into students values (2,'Max Ruin','Subject1',63,1,'2022-01-02');
insert into students values (3,'Arnold','Subject1',95,1,'2022-01-02');
insert into students values (4,'Krish Star','Subject1',61,1,'2022-01-02');
insert into students values (5,'John Mike','Subject1',91,1,'2022-01-02');
insert into students values (4,'Krish Star','Subject2',71,1,'2022-01-02');
insert into students values (3,'Arnold','Subject2',32,1,'2022-01-02');
insert into students values (5,'John Mike','Subject2',61,2,'2022-11-02');
insert into students values (1,'John Deo','Subject2',60,1,'2022-01-02');
insert into students values (2,'Max Ruin','Subject2',84,1,'2022-01-02');
insert into students values (2,'Max Ruin','Subject3',29,3,'2022-01-03');
insert into students values (5,'John Mike','Subject3',98,2,'2022-11-02');

select * from students;

/* Solution */

-- write an query to find the students who have achieved above the average marks in each subject

with t1 as
(select subject,round(avg(marks),2) as subject_avg_marks
from students 
group by subject),
t2 as
(select studentname,a.subject,marks, subject_avg_marks 
from students a
join t1 on a.subject = t1.subject)

select studentname,marks from t2 where marks > subject_avg_marks ;

-- write an query to find the percentag of students who have achieved more than 90 in any subject

with t1 as
	(select count(distinct studentid) as total_students from students),
	above_ninety as
	(select count(distinct studentid) as above_ninety_total_students from students
	where marks > 90)

select round(1.0*above_ninety_total_students/total_students*100,2)
as percentage_students_got_above_ninety from above_ninety, t1 ;

-- write an query to get the second highest and second lowest marks for each subject.

with t1 as
	(select subject,marks as second_highest_mark,
	dense_rank() over (partition by subject order by marks desc) as highest_marks_rank
	from students order by subject,marks),
	t2 as
	(select subject,marks as second_lowest_mark,
	dense_rank() over (partition by subject order by marks asc) as lowest_marks_rank
	from students order by subject,marks)

select t1.subject,second_highest_mark,second_lowest_mark from t1
join t2
on t1.subject = t2.subject where highest_marks_rank = 2 and lowest_marks_rank = 2 ;

/* alternate way to do */

select distinct subject,
	nth_value(marks,2) over(partition by subject order by marks desc range between unbounded preceding and unbounded following) as second_highest,
	nth_value(marks,2) over(partition by subject order by marks asc range between unbounded preceding and unbounded following) as second_lowest
from students
order by subject


--for each student and test, identify if their marks increased or decreased

select *,
	case when marks > prev_marks then 'inc' else 'dec' end as status
from
(select *,
lag(marks) over(partition by studentid order by subject) as prev_marks
from students
order by studentid,subject
) x
