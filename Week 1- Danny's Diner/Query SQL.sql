--Q1

SELECT customer_id, SUM(price) as Spent
FROM dannys_diner.sales
LEFT JOIN dannys_diner.menu
ON dannys_diner.sales.product_id = dannys_diner.menu.product_id
GROUP BY customer_id;
--Q2

SELECT COUNT(DISTINCT order_date), customer_id
From dannys_diner.sales
GROUP BY customer_id;

-- Q3- ONLY WORKS IF EACH DATE IS THE SAME, IF DATES ARE SOME MUCH EASIER TO BREAK IT INTO TWO DIFFERENT QUERY STATEMENTS
Select customer_id, product_name
FROM dannys_diner.sales
LEFT JOIN dannys_diner.menu
ON dannys_diner.sales.product_id = dannys_diner.menu.product_id
WHERE order_date = (Select MIN(order_date) FROM dannys_diner.sales);
--Q4
Select product_name, COUNT(product_name)
FROM dannys_diner.sales
LEFT JOIN dannys_diner.menu
ON dannys_diner.sales.product_id = dannys_diner.menu.product_id 
GROUP BY product_name;
--
Select customer_id, Count(customer_id)
FROM dannys_diner.sales
LEFT JOIN dannys_diner.menu
ON dannys_diner.sales.product_id = dannys_diner.menu.product_id 
WHERE product_name = 'ramen'
GROUP BY customer_id;
--Q5
Select customer_id, product_name, Count(product_name)
FROM dannys_diner.sales
LEFT JOIN dannys_diner.menu
ON dannys_diner.sales.product_id = dannys_diner.menu.product_id
Group BY customer_id, product_name
Order BY customer_id;
--Q6
Select customer_id, order_date, product_name
From (Select sales.customer_id, order_date, product_id, join_date
      FROM dannys_diner.sales as sales
      LEFT Join dannys_diner.members as members
      ON sales.customer_id = members.customer_id) as C
Left JOIN dannys_diner.menu as menu
ON menu.product_id = C.product_id
WHERE order_date >= join_date 
ORDER BY order_date;
--Q7
Select customer_id, order_date, product_name
From (Select sales.customer_id, order_date, product_id, join_date
      FROM dannys_diner.sales as sales
      LEFT Join dannys_diner.members as members
      ON sales.customer_id = members.customer_id) as C
Left JOIN dannys_diner.menu as menu
ON menu.product_id = C.product_id
WHERE order_date <= join_date
ORDER BY order_date;
--Q8
Select customer_id, count(product_name), sum(price)
From (Select sales.customer_id, order_date, product_id, join_date
      FROM dannys_diner.sales as sales
      LEFT Join dannys_diner.members as members
      ON sales.customer_id = members.customer_id) as C
Left JOIN dannys_diner.menu as menu
ON menu.product_id = C.product_id
WHERE order_date < join_date
GROUP BY customer_id;
--Q9
With points AS
(
  Select *, Case When product_name = 'sushi' Then price * 20 ELSE price*10 END AS Points
  FROM dannys_diner.menu
)
Select customer_id, sum(Points) as Points
FROM dannys_diner.sales
LEFT JOIN points
ON dannys_diner.sales.product_id = points.product_id
GROUP BY customer_id;
--Q10

WITH dates as
(
  Select *,
  	join_date + Interval'6 day' as valid_date,
	date_trunc('month', date '2021-01-31') + interval '1 month - 1 day' as last_date
  FROM dannys_diner.members
)

Select s.customer_id,
SUM(
  CASE WHEN product_name = 'sushi' THEN m.price * 20
  WHEN order_date between d.join_date AND d.valid_date THEN m.price * 20
  ELSE m.price * 10
  END
  ) as points
FROM dannys_diner.sales as s
JOIN dates as d
ON s.customer_id = d.customer_id
JOIN dannys_diner.menu as m
ON m.product_id = s.product_id
WHERE order_date < d.last_date
Group BY s.customer_id