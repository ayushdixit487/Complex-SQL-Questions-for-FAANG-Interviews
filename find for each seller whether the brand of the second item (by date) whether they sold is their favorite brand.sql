/* write a query to find for each seller whether the brand of the second item (by date) whether they sold is their favorite brand or not 
if a seller had sold less than 2 items then report the result as no */


create table Users (
user_id         int     ,
join_date       date    ,
favorite_brand  varchar(50));

create table orders (
order_id       int     ,
order_date     date    ,
item_id        int     ,
buyer_id       int     ,
seller_id      int 
);

create table items
(
item_id        int     ,
item_brand     varchar(50)
);


insert into Users values (1,'2019-01-01','Lenovo'),(2,'2019-02-09','Samsung'),(3,'2019-01-19','LG'),(4,'2019-05-21','HP');

insert into items values (1,'Samsung'),(2,'Lenovo'),(3,'LG'),(4,'HP');

insert into orders values (1,'2019-08-01',4,1,2),(2,'2019-08-02',2,1,3),(3,'2019-08-03',3,2,3),(4,'2019-08-04',1,4,2)
,(5,'2019-08-04',1,3,4),(6,'2019-08-05',2,2,4);
 
select * from Users;
select * from items;
select * from orders;

/* hints 
1. first joined the items and users table to get the favourite brand item_id.(t1)
2. then, took out the second order date and second order item by each seller (t2) and also filtered the table where second_order_item is not null (t3)
3. then, joined the t1 table with t3 by left join to get all the user id and then compared whether favourite brand item_id is similar to second ordered item or not.
*/

/* Solution */

select * from Users;
select * from items;
select * from orders ;

with t1 as
	(select u.user_id,u.favorite_brand,i.item_id as fav_item from users u
	join items i
	on u.favorite_brand = i.item_brand),
	t2 as
	(select seller_id,item_id as ordered_item_id,order_date,
	coalesce(lead(order_date) over(partition by seller_id order by order_date),order_date) as second_order_date,
	lead(item_id) over(partition by seller_id order by order_date) as second_order_item
	from orders order by seller_id,order_date asc),
	t3 as
	(select seller_id,ordered_item_id,order_date,second_order_item,second_order_date 
	 from t2 where second_order_item is not null),
	 t4 as
	 (select * from t1 left join t3 on t1.user_id = t3.seller_id)
select user_id,case when fav_item = second_order_item then 'Yes' else 'No' end as second_item_sold_fav from t4
