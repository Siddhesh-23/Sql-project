-- Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS Total_orders
FROM
    orders;


-- Calculate the total revenue generated from pizza sales

SELECT 
    ROUND(SUM(pizzas.price * order_details.quantity),
            2) AS Total_revenue
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id;


-- Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;



-- Identify the most common pizza size ordered.

SELECT 
    pizzas.size, SUM(order_details.quantity) AS no_of_orders
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY no_of_orders DESC
LIMIT 1;



-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS total_quantities
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY total_quantities DESC
LIMIT 5;



-- Join the necessary tables to find the total quantity of each pizza category ordered

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantities
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantities DESC;



-- Determine the distribution of orders by hour of the day

SELECT 
    HOUR(order_time), COUNT(order_id)
FROM
    orders
GROUP BY HOUR(order_time);




-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;




-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(total_quantity), 0) AS avg_no_of_orders
FROM
    (SELECT 
        orders.order_date,
            SUM(order_details.quantity) AS total_quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS ordered_quantity;
    
    
    
    
-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;



-- Calculate the percentage contribution of each pizza type to total revenue.
-- x/t*100

select pizza_types.category, round((sum(pizzas.price * order_details.quantity) / (select sum(pizzas.price * order_details.quantity) as total_sales
from pizzas
join order_details 
on pizzas.pizza_id = order_details.pizza_id)*100),1) as contribution_to_revenue
from pizzas
join order_details 
on pizzas.pizza_id = order_details.pizza_id
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category;




-- Analyze the cumulative revenue generated over time.

select order_date, round(sum(revenue) over(order by order_date),2) as cum_revenue from
(select orders.order_date, sum(order_details.quantity * pizzas.price) as revenue
from order_details 
join pizzas 
on pizzas.pizza_id = order_details.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;



-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category, name , revenue from
(select category, name, revenue, rank() over(partition by category order by revenue) as rn from
(select pizza_types.category, pizza_types.name, sum(pizzas.price * order_details.quantity) as revenue
from pizzas
join order_details
on pizzas.pizza_id = order_details.pizza_id
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category,pizza_types.name)as a)as b
where rn <= 3;