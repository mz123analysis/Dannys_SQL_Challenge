--Q1
Select SUM(price)
FROM(Select pizza_id, SUM(CASE WHEN pizza_id = '1'
                     THEN 12
                     Else 10
                     END) as price
FROM pizza_runner.customer_orders as Co
Left JOIN pizza_runner.runner_orders as Ro
on Co.order_id = Ro.order_id
Where cancellation = 'No Cancellations'
group by pizza_id) as total;

--Q2
Select SUM(base_price + topping_price)
FROM(Select order_id,pizza_number,base_price, SUM(CASE WHEN topping_name = 'Cheese'
THEN 2
WHEN topping_name is NULL
THEN 0
ELSE 1
END) as topping_price
FROM (Select order_id, pizza_id, pizza_number, CASE WHEN pizza_id = '1'
      THEN 12
      ELSE 10
      End as base_price,
      extras, topping_name
FROM pizza_runner.co
LEFT JOIN pizza_runner.pizza_toppings as pt
ON co.extras = pt.topping_id) as cost_of_everything
GROUP BY order_id, pizza_number,base_price) as cost_with_extras
LEFT JOIN pizza_runner.runner_orders
ON cost_with_extras.order_id = runner_orders.order_id
WHERE cancellation = 'No Cancellations'
;

--Q3
--THIS IS THE SCHEMA CODE FOR THE NEW TABLE
DROP TABLE IF EXISTS ratings;
CREATE TABLE ratings (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "ratings" INTEGER,
  "review" TEXT
);
INSERT INTO ratings
  ("order_id", "customer_id", "ratings", "review")
VALUES
  ('1', '101', '4', 'Good pizza'),
  ('2', '101', '4', 'Meatlovers is pretty good!'),
  ('3', '102', '5', 'Quick Delivery'),
  ('4', '103', '3', 'Ordered 3 pizzas, Took over 40 minutes!'),
  ('5', '104', '5', 'Fast Delivery. Good Pizza too!'),
  ('6', '101', NULL, NULL),
  ('7', '105', '4', 'Delivery Driver is pretty nice'),
  ('8', '102', '4', 'Quick Delivery once again!'),
  ('9', '103', NULL, NULL),
  ('10', '104', '3', 'Did not give me extra cheese!');
 
 
--Q4
WITH amount as (
  Select order_time, order_id, count(pizza_id) as amount_of_pizzas
FROM pizza_runner.customer_orders
group by order_time, order_id
  )
  
Select customer_id, ro.order_id, runner_id, ratings, order_time, pickup_time, 
CASE WHEN pickup_time != 'null'
THEN CAST(CAST(pickup_time as TIMESTAMP) - order_time as time)
ELSE NULL
END as Time_between_order_and_pickup,
duration,
CASE WHEN distance != 'null'
THEN ROUND(CAST(CAST(distance as float)/CAST(duration as float) as numeric), 2)
ELSE NULL
END AS average_speed, 
amount_of_pizzas
FROM pizza_runner.runner_orders as ro
LEFT JOIN pizza_runner.ratings
on ro.order_id =  pizza_runner.ratings.order_id
LEFT JOIN amount
ON ro.order_id = amount.order_id;

--Q5
With cost_of_order as (
Select order_id, sum(cost_of_pizza) as cost_of_orders
FROM(Select order_id, pizza_id, pizza_number, CASE WHEN pizza_id = '1'
THEN 12
ELSE 10
END as cost_of_pizza
FROM pizza_runner.customer_order
group by order_id, pizza_id, pizza_number) as cost_of_order
group by order_id
  )

Select SUM(CASE WHEN distance != 'null'
THEN Round(CAST (cost_of_orders - CAST(distance as float) * .3 as numeric), 2)
ELSE 0
END) as profit
FROM pizza_runner.runner_orders as RO
LEFT JOIN cost_of_order
ON cost_of_order.order_id = RO.order_id
