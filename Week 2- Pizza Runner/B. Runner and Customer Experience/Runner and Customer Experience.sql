--Runner and Customer Experience
--Q1
ALTER TABLE pizza_runner.runners
ADD rd DATE;

UPDATE pizza_runner.runners
SET rd = '2021-01-01';

SELECT COUNT(runner_id) as join_on_this_week, 
CASE WHEN registration_date < rd + 7 THEN 1
WHEN registration_date < rd + 14 THEN 2
ELSE 3
END AS Week_Number
FROM pizza_runner.runners 
GROUP BY Week_Number
Order BY Week_Number;

--Q2
Select runner_id, CAST(AVG(DISTINCT CAST(pickup_time as TIMESTAMP) - order_time) as time) as Average_Time 
FROM pizza_runner.runner_orders as RO
JOIN pizza_runner.CoS
ON RO.order_id = CoS.order_id
WHERE cancellation = 'No Cancellations'
GROUP BY runner_id;

--Q3
Select CoS.order_id,CAST(CAST(pickup_time as TIMESTAMP) - order_time as time) as Time, pizza_number
FROM pizza_runner.runner_orders as RO
JOIN pizza_runner.CoS
ON RO.order_id = CoS.order_id
WHERE cancellation = 'No Cancellations'
GROUP BY CoS.order_id, pickup_time, order_time, pizza_number;

--Q4
Select customer_id, AVG(CAST(distance as Float)) as avg_Distance_in_km
FROM pizza_runner.runner_orders as Ro
JOIN pizza_runner.customer_orders as Co
ON Co.order_id = Ro.order_id
Where cancellation = 'No Cancellations'
GROUP BY customer_id;

--Q5
Select (Max(Cast(duration as float)) - Min(Cast(duration as Float))) as Difference_in_time
FROM pizza_runner.runner_orders
Where cancellation = 'No Cancellations';

--Q6
Select order_id, runner_id, Round(Cast(distance as numeric)/Cast(duration as numeric)::numeric, 2) as "speed(km/min)"
From pizza_runner.runner_orders
where cancellation = 'No Cancellations'
Order BY runner_id;

--Q7
Select runner_id, Round(Sum(CASE WHEN cancellation = 'No Cancellations' then 1.0 else 0.0 END)/ Count(cancellation)::numeric, 2) * 100 as successful_percentage
FROM pizza_runner.runner_orders
GROUP BY runner_id