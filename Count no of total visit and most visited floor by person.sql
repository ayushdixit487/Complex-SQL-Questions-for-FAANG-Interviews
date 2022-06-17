/* Count no of total visit and most visited floor by person */

create table entries ( 
name varchar(20),
address varchar(20),
email varchar(20),
floor int,
resources varchar(10));

insert into entries 
values 
('A','Bangalore','A@gmail.com',1,'CPU'),
('A','Bangalore','A1@gmail.com',1,'CPU'),
('A','Bangalore','A2@gmail.com',2,'DESKTOP'),
('B','Bangalore','B@gmail.com',2,'DESKTOP'),
('B','Bangalore','B1@gmail.com',2,'DESKTOP'),
('B','Bangalore','B2@gmail.com',1,'MONITOR');

select * from entries;

/* 
my logic here -
1. at first, find out the most visited floor by name --table 1
2. then find out the total_visit and aggregate the distinct resources by name --table 2
3. join the tables on name
*/

/* Solution */

with visited_floor as
	(select name,floor as most_visited_floor,count(*),rank() over(partition by name order by count(*) desc) as rn
	from entries
	group by name,floor),
	t1 as
	(select vf.name,vf.most_visited_floor from visited_floor as vf where rn = 1),
	t2 as
	(select name,count(floor) as total_visit,STRING_AGG(distinct(resources), ',') as resources from entries as tv group by name)
	
select t1.name,t2.total_visit,t1.most_visited_floor,t2.resources from t1
join t2
on t1.name = t2.name;
