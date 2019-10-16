--- Connect to database
\c starschema_company;

--- Get the top 3 product types that have proven most profitable
SELECT sum(o.profit) as sum_profit, p.product_line
FROM order_line_fact_table AS o
LEFT JOIN products as p
ON o.product_code = p.product_code
group by p.product_line
order by sum_profit desc
limit 3;


--- Get the top 3 products by most items sold
SELECT sum(o.quantity_ordered) as sum_ordered, p.product_name
FROM order_line_fact_table AS o
LEFT JOIN products as p
ON o.product_code = p.product_code
group by p.product_code
order by sum_ordered desc
limit 3;

--- Get the top 3 products by items sold per country of customer for: USA, Spain, Belgium
SELECT sum(op.quantity_ordered) as sum_ordered, op.product_name
FROM (order_line_fact_table AS o
LEFT JOIN products as p
ON o.product_code = p.product_code) as op
left join customers as c
on op.customer_number=c.customer_number
where c.country='USA'
group by op.product_name
order by sum_ordered desc
limit 3;

SELECT sum(op.quantity_ordered) as sum_ordered, op.product_name
FROM (order_line_fact_table AS o
LEFT JOIN products as p
ON o.product_code = p.product_code) as op
left join customers as c
on op.customer_number=c.customer_number
where c.country='Spain'
group by op.product_name
order by sum_ordered desc
limit 3;

SELECT sum(op.quantity_ordered) as sum_ordered, op.product_name
FROM (order_line_fact_table AS o
LEFT JOIN products as p
ON o.product_code = p.product_code) as op
left join customers as c
on op.customer_number=c.customer_number
where c.country='Belgium'
group by op.product_name
order by sum_ordered desc
limit 3;

--- Get the most profitable day of the week
SELECT sum(o.profit) as sum_profit, d.day_of_the_week
FROM order_line_fact_table AS o
LEFT JOIN dates as d
ON o.date_key = d.date_key
group by d.day_of_the_week
order by sum_profit desc
limit 1;

--- Get the top 3 city-quarters with the highest average profit margin in their sales
SELECT sum(oi.profit)/sum(oi.sales_amount) as avg_profit_margin, oi.quarter,e.city
FROM (order_line_fact_table AS o
LEFT JOIN dates as d
ON o.date_key = d.date_key) as oi
left join employees as e
on oi.sales_rep_employee_number=e.employee_number
group by oi.quarter,e.city
order by avg_profit_margin desc
limit 3;

-- List the employees who have sold more goods (in $ amount) than the average employee.


/*select sum(o.sales_amount) as sum_sales, e.employee_number,e.first_name,e.last_name
from order_line_fact_table as o
left join employees as e
on o.sales_rep_employee_number=e.employee_number
group by e.employee_number
order by sum_sales desc
limit 3;

select avg(temp.sum_sales)
from (select sum(o.sales_amount) as sum_sales, e.employee_number,e.first_name,e.last_name
from order_line_fact_table as o
left join employees as e
on o.sales_rep_employee_number=e.employee_number
group by e.employee_number) as temp;
*/

select *
from (select sum(o.sales_amount) as sum_sales, e.employee_number,e.first_name,e.last_name
from order_line_fact_table as o
left join employees as e
on o.sales_rep_employee_number=e.employee_number
group by e.employee_number) as temp1
CROSS JOIN (select avg(temp.sum_sales) as average
from (select sum(o.sales_amount) as sum_sales, e.employee_number,e.first_name,e.last_name
from order_line_fact_table as o
left join employees as e
on o.sales_rep_employee_number=e.employee_number
group by e.employee_number) as temp) as temp2
where temp1.sum_sales > temp2.average;



-- List all the orders where the sales amount in the order is in the top 10% of all order sales amounts (BONUS: Add the employee number)
select top.order_number,top.sum_sales,top.sales_rep_employee_number
from (SELECT sum(o.sales_amount) as sum_sales,o.sales_rep_employee_number, o.order_number
from order_line_fact_table as o
group by o.order_number,o.sales_rep_employee_number) as top
order by top.sum_sales desc
LIMIT (SELECT (count(*) / 10) AS selnum FROM (SELECT sum(o.sales_amount) as sum_sales
from order_line_fact_table as o
group by o.order_number,o.sales_rep_employee_number) as top);
