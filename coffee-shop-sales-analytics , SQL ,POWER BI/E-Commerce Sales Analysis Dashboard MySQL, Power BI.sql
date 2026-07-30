create database Coffee_shop_sales_db;
use Coffee_shop_sales_db;

UPDATE coffee_shop_sales
SET transaction_date = STR_TO_DATE(transaction_date, '%m/%d/%Y');

alter table coffee_shop_sales
modify column transaction_date  DATE;


UPDATE coffee_shop_sales
SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');

alter table coffee_shop_sales
modify column transaction_time  TIME;


alter table coffee_shop_sales
change column transcation_id transaction_id INT;

select * from coffee_shop_sales;




select * from (
select months , concat((round(sum(sales))/1000),"K") as totalsales from (
select month(transaction_date) as months , (transaction_qty * unit_price) as sales  from coffee_shop_sales
) as h
group by months 
) as h
where months = 3;


-- calculate the diff in sales between selected month and previous months 

select * ,
(totalsales - previousmonthsales) as mom_change,
(totalsales - previousmonthsales)/previousmonthsales *100 as mom_increase_percentage
from (
select month(transaction_date) as months , round(sum((transaction_qty * unit_price))) as totalsales,
lag(round(sum((transaction_qty * unit_price)))) over(order by month(transaction_date)) as previousmonthsales 
from coffee_shop_sales
group by month(transaction_date)
) t
where months in (4,5) ;

-- calculate the diff in orders between selected month and previous months 


select months  , totalorders , 
(totalorders - previousmonthorders) as mom_diference_for_month , 
(totalorders - previousmonthorders)/previousmonthorders *100 as mom_increase_percentage 
from (
select month(transaction_date) as months , count(transaction_id) as totalorders ,
lag(count(transaction_id)) over(order by month(transaction_date)) as previousmonthorders
from coffee_shop_sales
group by month(transaction_date)
) as j
where months in (4,5);

-- calculate the diff in total quantity sold between selected month and previous months 
 select months  , totalquantity , 
(totalquantity - previousmonthquantity) as mom_diference_for_month , 
(totalquantity - previousmonthquantity)/previousmonthquantity *100 as mom_increase_percentage 
from (
select month(transaction_date) as months , sum(transaction_qty) as totalquantity ,
lag(sum(transaction_qty)) over(order by month(transaction_date)) as previousmonthquantity
from coffee_shop_sales
group by month(transaction_date)
) as j
where months in (4,5);

select * from coffee_shop_sales;

-- Sales Report

select 
concat(round(sum(unit_price*transaction_qty)/1000,1),'K') as totalsales,
concat(round(count(transaction_id)/1000,1),'K') as totalorders,
concat(round(sum(transaction_qty)/1000,1),'K') as totalquantity
from coffee_shop_sales
where transaction_date = '2023-05-18';
 
-- Sales by weekend /weekdays


select 
case when dayofweek(transaction_date) in (1,7) then 'Weekend'
else 'Weekdays'
end day_type,
concat(round(sum(unit_price*transaction_qty)/1000,1), 'K') as totalsales
from coffee_shop_sales
where month(transaction_date) = 5
group by  case when dayofweek(transaction_date) in (1,7) then 'Weekend'
else 'Weekdays'
end ;

-- Sales by store location 

select store_location , concat(round(sum(unit_price*transaction_qty)/1000,1), 'K') as totalsales
from coffee_shop_sales
where month(transaction_date) = 6
group by store_location
order by concat(round(sum(unit_price*transaction_qty)/1000,1), 'K') desc;

-- Sales trend over the period

select concat(round(avg(totalsales)/1000,1),'K') as avgsales from (
select sum(unit_price * transaction_qty) as totalsales   from coffee_shop_sales
where month(transaction_date) = 5
group by transaction_date
) as h;

-- Sales trend over the period 


select day(transaction_date) as dayofmonth, concat(round(sum(unit_price*transaction_qty)/1000,1), 'K') as totalsales  from coffee_shop_sales
where month(transaction_date) = 5
group by transaction_date
order by day(transaction_date);

-- COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”


SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        coffee_shop_sales
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;
    
-- Sales with respect to product category    


select * from coffee_shop_sales;



select product_type ,sum(unit_price*transaction_qty) as totalsales from coffee_shop_sales
where month(transaction_date) = 5
group by product_type
order by sum(unit_price*transaction_qty) desc
limit 10;


-- Sales analysis by days and hours

select  
sum(unit_price*transaction_qty) as totalsales ,
sum(transaction_qty) as totalquantity,
count(transaction_id) as total_orders from coffee_shop_sales
where month(transaction_date) = 5 and dayofweek(transaction_date) = 1
and hour(transaction_time) = 8;


-- Find the peak hours where the coffee are sold 

select hour(transaction_time) as peakhours , sum(unit_price*transaction_qty) as totalsales from coffee_shop_sales
where month(transaction_date) = 5
group  by hour(transaction_time)
order by sum(unit_price*transaction_qty) desc;


-- To get sales from monday to sunday for month of may 


select dayname(transaction_date) as daynames , month(transaction_date) as months,
round(sum(unit_price*transaction_qty))  as totalsales from coffee_shop_sales
where month(transaction_date) = 5
group by dayname(transaction_date) , month(transaction_date)
order by totalsales desc




