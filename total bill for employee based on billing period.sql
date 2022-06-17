/* find total bill for employee based on billing period */

create table billings 
(
emp_name varchar(10),
bill_date date,
bill_rate int
);
delete from billings;
insert into billings values
('Sachin','01-JAN-1990',25)
,('Sehwag' ,'01-JAN-1989', 15)
,('Dhoni' ,'01-JAN-1989', 20)
,('Sachin' ,'05-Feb-1991', 30)
;

create table HoursWorked 
(
emp_name varchar(20),
work_date date,
bill_hrs int
);
insert into HoursWorked values
('Sachin', '01-JUL-1990' ,3)
,('Sachin', '01-AUG-1990', 5)
,('Sehwag','01-JUL-1990', 2)
,('Sachin','01-JUL-1991', 4) ;

select * from billings ; 
select * from HoursWorked ;

/* hints
1. first let's take the (second bill date - 1) as bill date ending period.
	and if there is no second bill date then put an arbitary unique value '9999-12-31' as bill date ending period
2. then just joined the table with HoursWorked table based on emp_name and filter it if work_date between bill_start_date and bill_end_date
*/
 
/* Solution */

with t1 as
	(select emp_name,bill_date as bill_start_date,
		coalesce((lead(bill_date) over (partition by emp_name order by bill_date asc) - 1),cast('9999-12-31' as date)) as bill_end_date,
	 	bill_rate
	from billings),
	t2 as
	(select hw.emp_name, hw.work_date, t1.bill_start_date, t1.bill_end_date, hw.bill_hrs, t1.bill_rate 
	 from t1 join HoursWorked hw on t1.emp_name = hw.emp_name 
	 where hw.work_date between t1.bill_start_date and t1.bill_end_date)
select emp_name, sum(bill_rate * bill_hrs) as total_bill from t2 group by emp_name ;
