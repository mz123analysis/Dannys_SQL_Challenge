--Q1
Select Count(Distinct customer_id) as amount_of_customers
FROM foodie_fi.subscriptions as s
LEFT JOIN foodie_fi.plans  as plan
ON plan.plan_id = s.plan_id;

--Q2
Select extract(month from start_date) as months, count(extract(month from start_date))
FROM foodie_fi.subscriptions as s
LEFT JOIN foodie_fi.plans  as plan
ON plan.plan_id = s.plan_id
Where plan_name = 'trial'
group by extract(month from start_date)
order by extract(month from start_date);

--Q3
Select plan_name, count(plan_name)
FROM foodie_fi.subscriptions as s
LEFT JOIN foodie_fi.plans  as plan
ON plan.plan_id = s.plan_id
Where start_date >= '2021-01-01'
Group by plan_name
order by plan_name;

--Q4
Select count(customer_id), ROUND(count(customer_id)/1000.0,2)
FROM foodie_fi.subscriptions as s
LEFT JOIN foodie_fi.plans  as plan
ON plan.plan_id = s.plan_id
Where plan_name = 'churn';
 
--Q5
Select  plan_id, previous_plan, count(plan_id), ROUND(count(plan_id)/1000.0 , 2) * 100 as precentage
FROM(Select customer_id, plan_id, LAG(plan_id) OVER (Order BY customer_id, start_date) as previous_plan, start_date
FROM foodie_fi.subscriptions
GROUP BY customer_id, plan_id, start_date) as previous
WHERE plan_id = 4 AND previous_plan = 0
GROUP BY plan_id, previous_plan

--Q6
Select  plan_id, previous_plan, count(plan_id), ROUND(count(plan_id)/1000.0 , 2) * 100 as precentage
FROM(Select customer_id, plan_id, LAG(plan_id) OVER (Order BY customer_id, start_date) as previous_plan, start_date
FROM foodie_fi.subscriptions
GROUP BY customer_id, plan_id, start_date) as previous
WHERE plan_id != 4 AND previous_plan = 0
GROUP BY plan_id, previous_plan;

--Q7
Select plan_name, count(plan_name), ROUND( count(plan_name) /10.0 , 1) as precentage
FROM(select DISTINCT ON (customer_id) customer_id, plan_name, start_date
FROM foodie_fi.subscriptions as sb
LEFT JOIN foodie_fi.plans as plans1
ON sb.plan_id = plans1.plan_id
WHERE start_date <= '2020-12-31'
ORDER BY customer_id, start_date DESC NULLS LAST, plan_name) as t1
group by plan_name;

--Q8
Select sb.plan_id, count(sb.plan_id) as unique_customers
FROM foodie_fi.subscriptions as sb
LEFT JOIN foodie_fi.plans as plans1
ON sb.plan_id = plans1.plan_id
WHERE  (sb.plan_id = 3) AND (date_part('year', start_date) = 2020)
GROUP BY sb.plan_id;

--Q9
With t1 as (
	select DISTINCT ON (customer_id) customer_id, plan_name, start_date
	FROM foodie_fi.subscriptions as sb
	LEFT JOIN foodie_fi.plans as plans1
	ON sb.plan_id = plans1.plan_id
	ORDER BY customer_id, start_date ASC NULLS FIRST, plan_name
)
Select ROUND(AVG(annual_dates.start_date - t1.start_date), 2)
FROM(select customer_id, plan_name, start_date
FROM foodie_fi.subscriptions as sb
LEFT JOIN foodie_fi.plans as plans1
ON sb.plan_id = plans1.plan_id
where plan_name = 'pro annual') as annual_dates
LEFT JOIN t1
on annual_dates.customer_id = t1.customer_id;

--Q10
With t1 as (
	select DISTINCT ON (customer_id) customer_id, plan_name, start_date
	FROM foodie_fi.subscriptions as sb
	LEFT JOIN foodie_fi.plans as plans1
	ON sb.plan_id = plans1.plan_id
	ORDER BY customer_id, start_date ASC NULLS FIRST, plan_name
)

SELECT ((breaking_into_buckets - 1) * 30 || ' - ' || (breaking_into_buckets) * 30) || ' days' AS Breaking_down_into_30Days , count(breaking_into_buckets)
FROM (Select Width_bucket(days, 0, 360, 12) as breaking_into_buckets
FROM(Select (annual_dates.start_date - t1.start_date) as days
FROM(select customer_id, plan_name, start_date
FROM foodie_fi.subscriptions as sb
LEFT JOIN foodie_fi.plans as plans1
ON sb.plan_id = plans1.plan_id
where plan_name = 'pro annual') as annual_dates
LEFT JOIN t1
on annual_dates.customer_id = t1.customer_id) as incrementations ) as final_table
group by breaking_into_buckets;

--Q11
Select count(customer_id) as downgrade
FROM (Select customer_id, plan_id, LAG(plan_id) OVER (Order BY customer_id, start_date) as previous_plan, start_date
FROM foodie_fi.subscriptions
GROUP BY customer_id, plan_id, start_date) as basic
WHERE (previous_plan = 2 AND plan_id = 1) and start_date <= '2020-12-31';
