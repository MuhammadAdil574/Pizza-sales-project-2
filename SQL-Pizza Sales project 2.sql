create database pizza_sales_2;
use pizza_sales_2;

CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);

CREATE TABLE orders_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    quantity INT NOT NULL,
    pizza_id TEXT NOT NULL,
    PRIMARY KEY (order_details_id)
);

show tables;
select * from orders;
select * from orders_details;
select * from pizza_types;
select * from pizzas;

-- Q.1) Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id)
FROM
    orders AS Total_orders;

-- Q.2) Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS Total_revenue
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id;
    
-- Q.3) Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1; 

-- Q.4) dentify the most common pizza size ordered.
-- 4.1  Total_orders_per_quantity
SELECT 
    quantity,
    COUNT(order_details_id) AS Total_orders_per_quantity
FROM
    orders_details
GROUP BY quantity;

-- 4.2 most common pizza order with respect to size

SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS Orders_Per_Each_Size
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY Orders_Per_Each_Size DESC
Limit 1;

-- Q.5 List the top 5 most ordered pizza types along with their 
-- quantities.

SELECT 
    pizza_types.name,
    SUM(orders_details.quantity) AS No_of_pizzas_by_name
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.name
ORDER BY No_of_pizzas_by_name DESC
LIMIT 5;

-- Intermediate
-- Q.6 Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS ordered_pizza_by_catagorey
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category
ORDER BY ordered_pizza_by_catagorey DESC
LIMIT 5;

-- Q.7  Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS Hours, COUNT(order_id)
FROM
    orders
GROUP BY Hours;

-- Q.8 Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name) AS Total_pizza_orders
FROM
    pizza_types
GROUP BY category;

-- Q.9 Group the orders by date and calculate the average number of pizzas ordered per day.
-- Used a subquerry to get the final resut, initiating with
-- grouping total orders by date and later on making it a sub-querry to get
-- average pizza ordered per day 
SELECT 
    ROUND(AVG(Quantity), 0) AS avg_pizza_ordered_per_day
FROM
    (SELECT                       
        orders.order_date, SUM(orders_details.quantity) AS Quantity
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS ordered_quantity;


-- Q.10 Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    ROUND(SUM((orders_details.quantity * pizzas.price)),
            0) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.name
ORDER BY Revenue DESC
LIMIT 3;

-- Q.11 Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    ROUND(SUM(orders_details.quantity * pizzas.price),
            0) AS category_sales,
    ROUND((SUM(orders_details.quantity * pizzas.price) / (SELECT 
                    SUM(orders_details.quantity * pizzas.price)
                FROM
                    pizzas
                        JOIN
                    orders_details ON pizzas.pizza_id = orders_details.pizza_id)) * 100,
            0) AS percentage_of_total_sales
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.category
ORDER BY percentage_of_total_sales DESC;

-- Q.12 Analyze the cumulative revenue generated over time.
select order_date, sum(Revenue) over (order by order_date) as Commulative_Revenue
from
(select orders.order_date, 
round(sum(orders_details.quantity * pizzas.price),2) as Revenue
from orders_details join pizzas on orders_details.pizza_id = pizzas.pizza_id
join orders on orders.order_id = orders_details.order_id
group by orders.order_date) as sales;

-- Q.13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name,category, Revenue 
from

(select category,name,Revenue,
 rank() over (partition by category order by Revenue desc) as RN 
from 
(select pizza_types.category,
pizza_types.name, round(sum(orders_details.quantity * pizzas.price),2) as Revenue
from pizza_types join pizzas on 
pizza_types.pizza_type_id = pizzas.pizza_type_id join orders_details on
orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) As A) as B
where RN <= 3;


