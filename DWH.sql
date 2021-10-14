## Prepare the data bases and table
show databases;
create database DWH;
use DWH;
show tables;  
  select * from fct_order;
  select * from fct_rating;
  select * from dim_platform;
  select * from dim_payment;
  SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

## Create view to join the tables and relevant variables
 create view test as select A.order_date, A.order_id, A.customer_id,COUNT(A.customer_id) OVER(PARTITION BY A.customer_id) AS order_count,
  dim_payment.payment_id, dim_payment.payment_method
  FROM (select * from fct_order where is_canceled='FALSE') as A
	left join dim_payment 
	on A.payment_id = dim_payment.payment_id
    group by A.order_id
    order by A.order_date ;
  select * from test ;  
  
  ## Create view to add filter the customers and check if the payment methods are same
   create view test2 as
select *, 
CASE 
WHEN
(select payment_id from (select *, RANK() OVER (PARTITION BY customer_id ORDER BY order_date) as payment_order from test 
 where order_count >1 ) as x
where payment_order =1)
=
(select payment_id from (select *, RANK() OVER (PARTITION BY customer_id ORDER BY order_date) as payment_order from test 
 where order_count >1 ) as x
where payment_order =2)
then 1
else 0
END as payment_same
from (select *, RANK() OVER (PARTITION BY customer_id ORDER BY order_date) as payment_order from test 
 where order_count >1 ) as x ;
 
 select * from test2;

  
## Create View to see the the percentage of customers who used the same payment method for second order, split by the first payment method
create view result as select payment_method, COUNT(case payment_same when 1 then 1 else null end) over 
 (partition by payment_method) /COUNT(customer_id) OVER(PARTITION BY payment_method) * 100 AS pct_2order
 from test2
  group by payment_method
;
 
 select * from result;
 
 
 ## Create view to join the tables and relevant variables
 create view test3 as select A.order_date, A.order_id, A.customer_id, MAX(A.order_date) over (partition by A.customer_id) as order_recent,
 IFNULL(fct_rating.feedback,'NO FEEDBACK') AS feedback
 from (select * from fct_order where is_canceled='FALSE' and order_date >= '2019-01-01') as A
	left join fct_rating 
	on A.order_id = fct_rating.order_id
    group by A.customer_id
    order by A.order_date;
 
 ## Create view to see the customers, gave positive feedback and purchase within 45 days
create view test4 as select *, DATEDIFF(order_recent,order_date) as Days from test3;
 select * from test4;
 
 ## Check the ratio
select count(case WHEN Days<=45 and Days>0 and feedback='positive' then 1 else null end)/count(DISTINCT customer_id) * 100
as positive_feedback_45d_return
from test4;



###Create view to join the tables and relevant variables
 create view test5 as select A.order_date, A.order_id, A.customer_id,A.platform_id, dim_platform.platform
 from (select * from fct_order where is_canceled='FALSE' and order_date >= '2017-01-01' and order_date <= '2017-12-31') as A
	left join dim_platform 
	on A.platform_id = dim_platform.platform_id
    group by A.customer_id
    order by A.order_date;
    
select  * from test5;

## Check the customers number who only used Android for 2017
select count(DISTINCT customer_id) as customers from test5
having 'platform_id' <>2 and 'platform_id' <>3 ;



