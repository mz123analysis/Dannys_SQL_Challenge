--Q1
Select pizza_name, string_agg(topping_name, ' ,') as toppings
FROM pizza_runner.pizza_recipe as PR
JOIN pizza_runner.pizza_toppings as PT
ON PR.topping = PT.topping_id
JOIN pizza_runner.pizza_names as PN
ON PR.pizza_id = PN.pizza_id
GROUP BY pizza_name;

--Q2
select count(topping_name), topping_name
FROM pizza_runner.Co
JOIN pizza_runner.pizza_toppings as PT
ON PT.topping_id = Co.extras
GROUP BY topping_name;

--Q3
With exclusions as (
  Select order_id, customer_id, pizza_number, pizza_id, extras, 			CAST(unnest(string_to_array(exclusions, ', ')) as INT) as exclusions, order_time
	FROM pizza_runner.customer_order
)

select count(topping_name), topping_name
FROM exclusions as Coss
JOIN pizza_runner.pizza_toppings as PT
ON PT.topping_id = Coss.exclusions
GROUP BY topping_name;

--Q4
With exclusions as
(
  Select order_id, customer_id, pizza_number, pizza_id, extras, 			CAST(unnest(string_to_array(exclusions, ', ')) as INT) as exclusions
	FROM pizza_runner.customer_order
)
  
Select co1.order_id, co1.pizza_number, (CASE 
WHEN CO1.extras = '0' AND CO1.exclusions = '0'
THEN pizza_name
WHEN co1.extras != '0' AND co1.exclusions = '0'
Then CONCAT(pizza_name, ' Extras - ', string_agg(DISTINCT extra.topping_name , ', ')) 
WHEN co1.extras = '0' AND co1.exclusions != '0'
THEN CONCAT(pizza_name, ' Exclusions - ', string_agg(DISTINCT exclusion.topping_name, ', ') )
WHEN co1.extras != '0' AND co1.exclusions != '0'
THEN CONCAT(pizza_name, ' Extras - ',  string_agg(DISTINCT extra.topping_name, ', '), ', Exclusions - ', string_agg(DISTINCT exclusion.topping_name, ','))
END) as "Pizza Type"

FROM pizza_runner.customer_order as CO1
JOIN pizza_runner.pizza_names as PN
ON CO1.pizza_id = PN.pizza_id
LEFT JOIN (Select order_id, STRING_agg(distinct topping_name, ', ') as topping_name, pizza_number
      FROM pizza_runner.co
	  JOIN pizza_runner.pizza_toppings as PT
	  ON PT.topping_id = Co.extras
          GROUP BY co.order_id, co.pizza_number) as extra
ON extra.order_id = CO1.order_id
LEFT JOIN (Select order_id, STRING_agg(distinct topping_name, ', ') as topping_name, pizza_number
           FROM exclusions
           JOIN pizza_runner.pizza_toppings as PT
           ON PT.topping_id = exclusions.exclusions
          GROUP BY exclusions.order_id, exclusions.pizza_number) as exclusion
ON CO1.order_id = exclusion.order_id
GROUP BY co1.order_id, co1.pizza_number, PN.pizza_name, extra.topping_name, co1.extras, co1.exclusions

--Q5
--Is not alphabetical

WITH excluded as (
  Select order_id, customer_id, pizza_number, pizza_id,CAST(unnest(string_to_array(exclusions, ', ')) as INT) as exclusions, order_time
FROM pizza_runner.customer_order
)
Select order_id, customer_id, pizza_number, pizza_id, string_to_array(string_agg(topping_name, ', '), ', ') as topping_name
INTO pizza_runner.excludedtoppings
FROM excluded
LEFT JOIN pizza_runner.pizza_toppings
ON pizza_toppings.topping_id = excluded.exclusions
GROUP BY order_id, customer_id, pizza_number, pizza_id
ORDER BY order_id,pizza_number
;

Select fin3.order_id, fin3.customer_id, fin3.pizza_number,
CASE WHEN topping_name is NOT Null
THEN (array_to_string(array(select unnest(String_to_array(additions, ', ')) except Select unnest(topping_name)),', ' ) )
ELSE additions
END as list
FROM(Select order_id,customer_id,pizza_number, string_agg(addition, ', ') as additions
FROM(Select order_id,customer_id,pizza_number, 
CASE WHEN number_of != 1
THEN concat(number_of,'x ', amount_of_extras)
ELSE amount_of_extras
END as addition
FROM(Select order_id, customer_id, pizza_number, amount_of_extras, count(amount_of_extras) as number_of
FROM(  Select order_id, customer_id, pizza_number,unnest(string_to_array(combine, ', ')) as amount_of_extras
FROM (
  Select order_id, customer_id,pizza_number,
CASE WHEN extrass is NOT NULL
THEN CONCAT(toppings, ', ', extrass)
Else toppings
END as combine
FROM(
  
  Select Co.order_id, CO.customer_id, pizza_number, CO.pizza_id, CO.exclusions, toppings, String_agg(topping_name, ', ' ORDER BY topping_name) as extrass
FROM pizza_runner.Co
LEFT JOIN pizza_runner.pizza_toppings as pt
ON CO.extras = pt.topping_id
LEFT JOIN pizza_runner.pizza_names
ON pizza_names.pizza_id = Co.pizza_id
LEFT JOIN (
  
  Select pizza_name, string_agg(topping_name, ', ' ORDER BY topping_name) as toppings
FROM pizza_runner.pizza_recipe as PR
JOIN pizza_runner.pizza_toppings as PT
ON PR.topping = PT.topping_id
JOIN pizza_runner.pizza_names as PN
ON PR.pizza_id = PN.pizza_id
GROUP BY pizza_name) as recipe
     
ON pizza_names.pizza_name = recipe.pizza_name 
GROUP BY Co.order_id, pizza_number, recipe.pizza_name, CO.customer_id, CO.pizza_id, CO.exclusions, toppings) as combining
      
GROUP BY order_id, customer_id,pizza_number, extrass, toppings
ORDER BY order_id, pizza_number) as finalone
     
GROUP BY order_id, customer_id, pizza_number, combine
Order BY order_id, customer_id, pizza_number) as fin

Group BY order_id, customer_id, pizza_number, amount_of_extras
order By order_id,pizza_number) as fin1 
) as fin2
GROUP BY order_id, customer_id, pizza_number) as fin3
LEFT JOIN pizza_runner.excludedtoppings as et
ON fin3.order_id = et.order_id AND fin3.pizza_number = et.pizza_number

--Q6
With excluded as (
  Select topping_name, count(topping_name) as numb
FROM(Select unnest(topping_name) as topping_name
from pizza_runner.excludedtoppings) as unnested
GROUP by topping_name
  )
  
Select amount_of_extras, amounts
FROM(Select amount_of_extras, 
CASE WHEN amount_of_extras = ex.topping_name
THEN Count(amount_of_extras) - numb
ELSE COUNT(amount_of_extras)
END as Amounts
FROM(  Select order_id, customer_id, pizza_number,unnest(string_to_array(combine, ', ')) as amount_of_extras
FROM (
  Select order_id, customer_id,pizza_number,
CASE WHEN extrass is NOT NULL
THEN CONCAT(toppings, ', ', extrass)
Else toppings
END as combine
FROM(
  
  Select Co.order_id, CO.customer_id, pizza_number, CO.pizza_id, CO.exclusions, toppings, String_agg(topping_name, ', ' ORDER BY topping_name) as extrass
FROM pizza_runner.Co
LEFT JOIN pizza_runner.pizza_toppings as pt
ON CO.extras = pt.topping_id
LEFT JOIN pizza_runner.pizza_names
ON pizza_names.pizza_id = Co.pizza_id
LEFT JOIN (
  
  Select pizza_name, string_agg(topping_name, ', ' ORDER BY topping_name) as toppings
FROM pizza_runner.pizza_recipe as PR
JOIN pizza_runner.pizza_toppings as PT
ON PR.topping = PT.topping_id
JOIN pizza_runner.pizza_names as PN
ON PR.pizza_id = PN.pizza_id
GROUP BY pizza_name) as recipe
     
ON pizza_names.pizza_name = recipe.pizza_name 
GROUP BY Co.order_id, pizza_number, recipe.pizza_name, CO.customer_id, CO.pizza_id, CO.exclusions, toppings) as combining
      
GROUP BY order_id, customer_id,pizza_number, extrass, toppings
ORDER BY order_id, pizza_number) as finalone
     
GROUP BY order_id, customer_id, pizza_number, combine
Order BY order_id, customer_id, pizza_number) as fin
Left JOIN excluded as ex
ON ex.topping_name = fin.amount_of_extras 
group by amount_of_extras, ex.numb, topping_name
order by Count(amount_of_extras) desc) as FinalCOUNT
ORDER BY amounts desc