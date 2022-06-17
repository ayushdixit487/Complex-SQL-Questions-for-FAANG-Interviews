/* Data Analyst Take Home Assignment by A Startup */

CREATE table activity
(
user_id varchar(20),
event_name varchar(20),
event_date date,
country varchar(20)
);

delete from activity;
insert into activity values (1,'app-installed','2022-01-01','India')
,(1,'app-purchase','2022-01-02','India')
,(2,'app-installed','2022-01-01','USA')
,(3,'app-installed','2022-01-01','USA')
,(3,'app-purchase','2022-01-03','USA')
,(4,'app-installed','2022-01-03','India')
,(4,'app-purchase','2022-01-03','India')
,(5,'app-installed','2022-01-03','SL')
,(5,'app-purchase','2022-01-03','SL')
,(6,'app-installed','2022-01-04','Pakistan')
,(6,'app-purchase','2022-01-04','Pakistan');

select * from activity ;
 
/* Solution */
/* find total users each day */

select event_date,count(distinct user_id) as active_users from activity group by event_date order by event_date asc ;

/* 
--- weekly active users 
here, notice something! 2022-01-01 is saturday and week is count from monday as 1 and sunday as 7. 
as 2022-01-01 and 2022-01-02 is a part of last week of 2021 so, the week will be here 52
and 1st week of 2022 will start from 2022-01-03
*/

select date_part('week',event_date) as week ,count(distinct user_id) as active_users from activity group by 1 order by 1 ;

/* count the users who installed and purchased in same day */ 

with t1 as
	(select a.user_id, a.event_date as installation_date, b.event_date as purchase_date 
	from activity a 
	join activity b
	on a.user_id = b.user_id
	where a.event_name ilike '%installed%' and b.event_name ilike '%purchase%' and a.event_date = b.event_date),
	t2 as
	(select distinct event_date from activity),
	t3 as
	(select * from t2 left join t1 on t2.event_date = installation_date or t2.event_date = purchase_date)	

select event_date,
	sum(case when user_id is not null then 1 else 0 end) as no_of_users
from t3 group by event_date order by event_date asc;

/* Percentage of paid users coutry wise -- India,USA and Others(remaining countries) */

with t1 as
 	(select case when country not in ('India','USA') then 'Others' else country end as country , count(distinct user_id) as no_of_users		 
	from activity where event_name = 'app-purchase' group by 1),
	t2 as
	(select count(distinct user_id) as total_users from activity where event_name = 'app-purchase')
select country, round(1.0*no_of_users/total_users*100,2) as percentage_users from t1,t2 ;

/* count them among all the users who have installed the app in a given day and purchases in the very next day */

with t1 as
	(select a.user_id, a.event_date as installation_date, b.event_date as purchase_date 
	from activity a 
	left join activity b
	on a.user_id = b.user_id
	where a.event_name ilike '%installed%' and b.event_name ilike '%purchase%')

select purchase_date,count(distinct user_id) as no_users 
from t1
where purchase_date - installation_date = 1
group by purchase_date
