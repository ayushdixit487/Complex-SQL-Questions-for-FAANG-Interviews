/* Count no of first visited customer and repeated customer over order date */

create table customer_orders (
order_id integer,
customer_id integer,
order_date date,
order_amount integer
);

insert into customer_orders values
(1,100,cast('2022-01-01' as date),2000),
(2,200,cast('2022-01-01' as date),2500),
(3,300,cast('2022-01-01' as date),2100),
(4,100,cast('2022-01-02' as date),2000),
(5,400,cast('2022-01-02' as date),2200),
(6,500,cast('2022-01-02' as date),2700),
(7,100,cast('2022-01-03' as date),3000),
(8,400,cast('2022-01-03' as date),1000),
(9,600,cast('2022-01-03' as date),3000) ;


select * from customer_orders ;

/* 
my logic here -
1. ordered the table by customer id and order date in ascending order and then took previous order date. as there is no previous date
	before 2022-01-01 so, I have put it as first visit date. 
2. If order_date = first_visit_date considered it as 1 else 0 and them sum those to get no of first_visit customer group by order_date.
3. If order_date > first_visit_date considered it as 1 else 0 and them sum those to get no of repeated_visit customer group by order_date.
*/

/* Solution */

with t1 as
	(select *,coalesce(lag(order_date) over (partition by customer_id order by order_date),order_date) as first_vist_date
	from customer_orders order by customer_id asc, order_date asc)
	
select order_date,
	sum(case when order_date = first_vist_date then 1 else 0 end) as first_vist,
	sum(case when order_date > first_vist_date then 1 else 0 end) as repeated_vist
from t1
group by order_date
order by order_date asc;
