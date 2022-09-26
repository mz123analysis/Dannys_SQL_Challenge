UPDATE pizza_runner.customer_orders
SET exclusions = '0'
WHERE exclusions = '' or exclusions = 'null' or exclusions IS null;

UPDATE pizza_runner.customer_orders
SET extras = '0'
WHERE extras = '' or extras = 'null' or extras IS NULL;

Select *, ROW_NUMBER() OVER(PARTITION BY order_id, customer_id) as pizza_number
INTO pizza_runner.customer_order
FROM pizza_runner.customer_orders;

Select order_id, customer_id, pizza_number, pizza_id, exclusions, CAST(unnest(string_to_array(extras, ', ')) as INT) as extras, order_time
INTO pizza_runner.Co
FROM pizza_runner.customer_order;

Select order_id, customer_id, pizza_number, pizza_id, CAST(unnest(string_to_array(exclusions, ', ')) as INT) as exclusions, extras, order_time
INTO pizza_runner.CoS
FROM pizza_runner.Co;

Select *
FROM pizza_runner.CoS;

-- customer_orders cleaned

UPDATE pizza_runner.runner_orders
SET cancellation = 'No Cancellations'
WHERE cancellation = '' or cancellation = 'null' or cancellation IS Null;

Update pizza_runner.runner_orders
SET distance = TRIM(REPLACE(distance,'km', ''))
where distance != 'null';

Update pizza_runner.runner_orders
SET duration = TRIM(REGEXP_REPLACE(duration, '[[:alpha:]]', '','g'))
Where distance != 'null';

SELECT * 
FROM pizza_runner.runner_orders;

-- pizza recipes CLEANED
WITH Pa AS (
Select pizza_id, CAST(unnest(string_to_array(toppings, ', ')) as INT) as topping
FROM pizza_runner.pizza_recipes
)

Select *
INTO pizza_runner.pizza_recipe
FROM PA;

Select *
FROM pizza_runner.pizza_recipe;