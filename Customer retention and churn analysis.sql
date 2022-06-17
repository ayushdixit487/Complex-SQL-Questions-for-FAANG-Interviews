/* Customer retention and churn analysis */
/* Part 1 */

create table transactions(
order_id int,
cust_id int,
order_date date,
amount int
);

delete from transactions;
insert into transactions values 
(1,1,'2020-01-15',150)
,(2,1,'2020-02-10',150)
,(3,2,'2020-01-16',150)
,(4,2,'2020-02-25',150)
,(5,3,'2020-01-10',150)
,(6,3,'2020-02-20',150)
,(7,4,'2020-01-20',150)
,(8,5,'2020-02-20',150);

/* hints 
> first, I have extract the month from current order date for order id and then take the month of previous order if available otherwise it will give 'null' 
> then took difference of the current order month and previous order month. If the difference is 1, that means the customer is retained (means he shopped last month and also current month)
> then I have used case statement if month_diff = 1 then 1 and If null (means no previous month shopping) then 0 and then take summation over month_diff to take out the no_customer_retention
*/

/*Solution */

select * from transactions ;

with t1 as
	(select order_id,cust_id, date_part('month',order_date) as current_order_month,
		lag(date_part('month',order_date)) over (partition by cust_id order by order_date asc) as prev_order_month,
	 	date_part('month',order_date) - lag(date_part('month',order_date)) over (partition by cust_id order by order_date asc) as month_diff
	 from transactions)

select current_order_month,
	sum(case when month_diff = 1 then 1  
		when month_diff is null then 0 end) as no_retention 
from t1 
group by current_order_month
order by current_order_month asc ;


/* Part 2 */

--customer churn by month (churn is something,suppose cust A bought something in Jan but not in Feb that means in Jan, there is a churn cause cust A didn't buy anything in feb. 
here my result is 
month no_churn
  1       1
  2       4
 -- that's because cust 4 has bought in jan but no in february (next month after jan) so it's a churn
  and as well as, we have no data for march that means there no_churn is 4. there might be a question that we have 5 customers. but think concisely, cust 4 didn't buy anything in feb, so that means in march for cust 4 that won't be counted as churn.
    retention related to purchase in next month after purchase something in previous month
    churn related to purchase in current month but not in next month.
    
with t1 as
	(select order_id,cust_id, date_part('month',order_date) as current_order_month,
		lead(date_part('month',order_date)) over (partition by cust_id order by order_date asc) as next_order_month,
	 	lead(date_part('month',order_date)) over (partition by cust_id order by order_date asc) - date_part('month',order_date) as month_diff
	 from transactions)

select current_order_month,
	sum(case when month_diff > 1 then 1  
		when month_diff is null then 1 end) as no_churn	
from t1 
group by current_order_month
order by current_order_month asc ;




/* tricky but amazing solution from a genious one  */

with retention_map as 
	(select *, count(1) over(partition by cust_id order by order_date rows between unbounded preceding and current row)  as retention_map 
	from transactions ) 
select   date_part( 'month', order_date) as month , sum( case when  retention_map > 1 then 1 else 0 end)  as retetion_count
from retention_map
group by  date_part( 'month', order_date) ;


with churn_map as 
	(select *, count(1) over(partition by cust_id order by order_date rows between current row and unbounded following)  as churn_map 
	from transactions ) 
select  date_part( 'month', order_date) as month , sum( case when  churn_map > 1 then 0 else 1 end)  as churn_count
from churn_map
group by  date_part( 'month', order_date) ;
