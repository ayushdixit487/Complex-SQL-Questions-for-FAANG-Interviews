/* If a person do a task on a regular basis and the output of the task is either success or fail.

suppose:
2022-01-01 - success
2022-01-02 - success
2022-01-03 - fail
2022-01-04 - success
2022-01-05 - fail
2022-01-06 - fail
2022-01-07 - fail
2022-01-08 - success

now my task is to write a query so that the output is like:

start_date    end_date      result
2022-01-01   2022-01-02    success
2022-01-03   2022-01-03    fail
2022-01-04 	 2022-01-04    success
2022-01-05   2022-01-07    fail
2022-01-08   2022-01-08    success
*/

create table tasks (
date_value date,
state varchar(10)
);

truncate tasks;
insert into tasks  values 
('2019-01-01','success'),
('2019-01-02','success'),
('2019-01-03','success'),
('2019-01-04','fail'),
('2019-01-05','fail'),
('2019-01-06','success'),
('2022-01-01','success'),
('2022-01-02','success'),
('2022-01-03','fail'),
('2022-01-04','success'),
('2022-01-05','fail'),
('2022-01-06','fail'),
('2022-01-07','fail'),
('2022-01-08','success');

/* Solution 1*/

with t1 as
	(select *,
 	date_value - interval '1 days' * row_number() over(partition by state order by date_value asc) as group_date
 	from tasks)
select min(date_value) as start_date,max(date_value) as end_date,state 
from t1 group by group_date,state order by 1;

/* Solution 2*/

with t1 as
	(select *,
 	date_value - interval '1 days' * row_number() over(order by date_value asc) as diff
 	from tasks where state = 'success'),
	t2 as 
	(select min(date_value),max(date_value) as end_date,max(state) as state 
	from t1 group by diff order by 1),
	t3 as
	(select *,
 	date_value - interval '1 days' * row_number() over(order by date_value asc) as diff
 	from tasks where state = 'fail'),
	t4 as 
	(select min(date_value),max(date_value) as end_date,max(state) as state 
	from t3 group by diff order by 1)
select * from t2 union all select * from t4
