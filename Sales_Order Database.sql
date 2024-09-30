drop table if exists products;
create table products
(
	id				    int generated always as identity primary key,
	name			    varchar(100),
	price			    float,
	release_date 	date
);
insert into products 
values(default,'iPhone 15', 800, to_date('22-08-2023','dd-mm-yyyy'));
insert into products 
values(default,'Macbook Pro', 2100, to_date('12-10-2022','dd-mm-yyyy'));
insert into products 
values(default,'Apple Watch 9', 550, to_date('04-09-2022','dd-mm-yyyy'));
insert into products 
values(default,'iPad', 400, to_date('25-08-2020','dd-mm-yyyy'));
insert into products 
values(default,'AirPods', 420, to_date('30-03-2024','dd-mm-yyyy'));

drop table if exists customers;
create table customers
(
    id         int generated always as identity primary key,
    name       varchar(100),
    email      varchar(30)
);
insert into customers values(default,'Meghan Harley', 'mharley@demo.com');
insert into customers values(default,'Rosa Chan', 'rchan@demo.com');
insert into customers values(default,'Logan Short', 'lshort@demo.com');
insert into customers values(default,'Zaria Duke', 'zduke@demo.com');

drop table if exists employees;
create table employees
(
    id         int generated always as identity primary key,
    name       varchar(100)
);
insert into employees values(default,'Nina Kumari');
insert into employees values(default,'Abrar Khan');
insert into employees values(default,'Irene Costa');

drop table if exists sales_order;
create table sales_order
(
	order_id		  int generated always as identity primary key,
	order_date	  date,
	quantity		  int,
	prod_id			  int references products(id),
	status			  varchar(20),
	customer_id		int references customers(id),
	emp_id			  int,
	constraint fk_so_emp foreign key (emp_id) references employees(id)
);
insert into sales_order 
values(default,to_date('01-01-2024','dd-mm-yyyy'),2,1,'Completed',1,1);
insert into sales_order 
values(default,to_date('01-01-2024','dd-mm-yyyy'),3,1,'Pending',2,2);
insert into sales_order 
values(default,to_date('02-01-2024','dd-mm-yyyy'),3,2,'Completed',3,2);
insert into sales_order 
values(default,to_date('03-01-2024','dd-mm-yyyy'),3,3,'Completed',3,2);
insert into sales_order 
values(default,to_date('04-01-2024','dd-mm-yyyy'),1,1,'Completed',3,2);
insert into sales_order 
values(default,to_date('04-01-2024','dd-mm-yyyy'),1,3,'completed',2,1);
insert into sales_order 
values(default,to_date('04-01-2024','dd-mm-yyyy'),1,2,'On Hold',2,1);
insert into sales_order 
values(default,to_date('05-01-2024','dd-mm-yyyy'),4,2,'Rejected',1,2);
insert into sales_order 
values(default,to_date('06-01-2024','dd-mm-yyyy'),5,5,'Completed',1,2);
insert into sales_order 
values(default,to_date('06-01-2024','dd-mm-yyyy'),1,1,'Cancelled',1,1);

SELECT * FROM products;
SELECT * FROM customers;
SELECT * FROM employees;
SELECT * FROM sales_order;

-- 1. Identify the total no of products sold
Select count(quantity), prod_id
from sales_order
group by prod_id
order by prod_id asc;


-- 2. Other than Completed, display the available delivery status's
select *, status
from sales_order
where status not in ('Completed', 'completed');

-- 3. Display the order id, order_date and product_name for all the completed orders.
select so.order_id, so.order_date, p.name
from sales_order so
join products p on p.id=so.prod_id
where lower(so.status) = 'completed';

-- 4. Sort the above query to show the earliest orders at the top. Also, display the customer who purchased these orders.
select o.order_id, o.order_date, p.name, o.status, c.name
from sales_order o
join products p on o.prod_id=p.id
join customers c on o.customer_id=c.id
where status in ('Completed', 'completed')
order by order_date desc;

-- 5. Display the total no of orders corresponding to each delivery status
select count(quantity), status
from sales_order
group by  status;

-- 6. How many orders are still not completed for orders purchasing more than 1 item?
select quantity, prod_id, status
from sales_order
where quantity> 1 
	and 
	status not in('Completed','completed');

-- 7. Find the total number of orders corresponding to each delivery status by ignoring the case in the delivery status
select status, count(*) as total_order
from sales_order
group by status
order by total_order desc;

-- 8. Write a query to identify the total products purchased by each customer 
select  c.name, sum(o.quantity) as total_order
from customers c
right join sales_order o
on c.id=o.customer_id
group by c.name;

-- 9. Display the total sales and average sales done for each day. 
select order_date, sum(price*quantity), avg(price*quantity)
from sales_order o
join products p
on p.id=o.prod_id
group by order_date;

-- 10. Display the customer name, employee name, and total sale amount of all orders which are either on hold or pending.
select c.name as customer, e.name as employee, sum(quantity*p.price) as total_sales
from sales_order so
join employees e on e.id = so.emp_id
join customers c on c.id = so.customer_id
join products p on p.id = so.prod_id
where status in ('On Hold', 'Pending')
group by c.name, e.name;

-- 11. Fetch all the orders which were neither completed/pending or were handled by the employee Abrar. 
      --Display the employee name and all details of the order.
select e.name as employee, so.*
from sales_order so
join employees e on e.id = so.emp_id
where e.name like 'Abrar'
or lower(status) not in ('Completed', 'pending', 'completed');

-- 12. Fetch the orders which cost more than 2000 but did not include the MacBook Pro. Print the total sale amount as well.
select (so.quantity * p.price) as total_sale, so.*, p.name
from sales_order so
join products p on p.id = so.prod_id
where prod_id not in (select id from products 
					  where name = 'Macbook Pro')
and (so.quantity * p.price)	> 2000;

-- 13. Identify the customers who have not purchased any product yet.
select * from customers
where id not in (select distinct customer_id 
				 from sales_order);

select  c.*
from sales_order so
right join customers c 
on so.customer_id = c.id
where so.order_id is null;

-- 14. Write a query to identify the total products purchased by each customer. 
--Return all customers irrespective of whether they have made a purchase or not. 
--Sort the result with the highest no of orders at the top

select c.name , coalesce(sum(quantity), 0) as tot_prod_purchased
from sales_order so
right join customers c on c.id = so.customer_id
group by c.name
order by tot_prod_purchased desc;

-- 15. Corresponding to each employee, display the total sales they made of all the completed orders. Display total sales as 0 if an employee made no sales yet.
select e.name as employee, coalesce(sum(p.price * so.quantity),0) as total_sale
from sales_order so
join products p on p.id = so.prod_id
right join employees e on e.id = so.emp_id 
and lower(so.status) = 'completed'
group by e.name
order by total_sale desc;

-- 16. Re-write the above query to display the total sales made by each employee corresponding to each customer. If an employee has not served a customer yet then display "-" under the customer.
select e.name as employee, coalesce(c.name, '-') as customer
, coalesce(sum(p.price * so.quantity),0) as total_sale
from sales_order so 
join products p on p.id = so.prod_id
join customers c on c.id = so.customer_id
right join employees e on e.id = so.emp_id
and lower(so.status) = 'completed'
group by e.name, c.name
order by total_sale desc;

-- 17. Re-write the above query to display only those records where the total sales are above 1000
select e.name as employee, coalesce(c.name, '-') as customer
, coalesce(sum(p.price * so.quantity),0) as total_sale
from sales_order so
join products p on p.id = so.prod_id
join customers c on c.id = so.customer_id
right join employees e on e.id = so.emp_id
and lower(so.status) = 'completed'
group by e.name, c.name
having sum(p.price * so.quantity) > 1000
order by total_sale desc;

-- 18. Identify employees who have served more than 2 customers.
select e.name, count(distinct c.name) as total_customers
from sales_order so
join employees e on e.id = so.emp_id
join customers c on c.id = so.customer_id
group by e.name
having count(distinct c.name) > 2;

-- 19. Identify the customers who have purchased more than 5 products
select c.name as customer, sum(quantity) as total_products_purchased
from sales_order so
join customers c on c.id = so.customer_id
group by c.name
having sum(quantity) > 5;

-- 20. Identify customers whose average purchase cost exceeds the average sale of all the orders.
select c.name as customer, avg(quantity * p.price)
from sales_order so
join customers c on c.id = so.customer_id
join products p on p.id = so.prod_id
group by c.name
having avg(quantity * p.price) > (select avg(quantity * p.price)
								  from sales_order so
								  join products p on p.id = so.prod_id);
 