--Pizza Metrics
--Q1
Select COUNT(order_id) as Orders
FROM pizza_runner.customer_order;
--Q2
Select Count(Distinct customer_id)
From pizza_runner.customer_order;
--Q3
Select runner_id, cancellation, count(cancellation)
FROM pizza_runner.runner_orders
GROUP BY runner_id, cancellation
Order BY runner_id;
--Q4
Select pizza_name, count(pizza_name), cancellation
FROM pizza_runner.runner_orders as RO
JOIN pizza_runner.customer_orders as CO
ON RO.order_id = CO.order_id
JOIN pizza_runner.pizza_names as pn
ON pn.pizza_id = CO.pizza_id
GROUP By pizza_name, cancellation
Order BY cancellation;
--Q5
Select customer_id, pizza_name, count(pizza_name)
FROM pizza_runner.runner_orders as RO
JOIN pizza_runner.customer_orders as CO
ON RO.order_id = CO.order_id
JOIN pizza_runner.pizza_names as pn
ON pn.pizza_id = CO.pizza_id
GROUP BY customer_id, pizza_name
Order BY customer_id, pizza_name;
--Q6
Select order_id, MAX(pizza_number)
FROM pizza_runner.CoS
GROUP BY order_id
ORDER BY MAX(pizza_number) DESC;
--Q7
SELECT customer_id, count(pizza_number) as "Amount of changes"
FROM pizza_runner.customer_order as CoS
JOIN pizza_runner.runner_orders as RO
ON CoS.order_id = RO.order_id
WHERE (exclusions != '0'  or extras != '0') AND cancellation = 'No Cancellations'
GROUP BY customer_id;

SELECT customer_id, count(pizza_number) as "Amount of no changes"
FROM pizza_runner.customer_order as CoS
JOIN pizza_runner.runner_orders as RO
ON CoS.order_id = RO.order_id
WHERE (exclusions = '0'  AND extras = '0') AND cancellation = 'No Cancellations'
GROUP BY customer_id;
--Q8
SELECT count(pizza_number) as "Both Exclusions and Extras"
FROM pizza_runner.customer_order as CoS
JOIN pizza_runner.runner_orders as RO
ON CoS.order_id = RO.order_id
WHERE (exclusions != '0'  AND extras != '0') AND cancellation = 'No Cancellations';
--Q9
Select EXTRACT(HOUR FROM order_time) as HOUR, COUNT(EXTRACT(hour FROM order_time))
FROM pizza_runner.customer_orders
GROUP BY EXTRACT(HOUR FROM order_time)
ORDER BY hour;
--Q10
Select EXTRACT(dow FROM order_time) as dow, COUNT(EXTRACT(dow FROM order_time))
FROM pizza_runner.customer_orders
GROUP BY EXTRACT(dow FROM order_time)
ORDER BY dow;