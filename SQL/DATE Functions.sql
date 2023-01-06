SELECT occurred_at,
       SUM(standard_qty) AS standard_qty_sum
FROM orders
GROUP BY occurred_at
ORDER BY occurred_at;

SELECT DATE_PART('dow',occurred_at) AS day_of_week,
       account_id,
       occurred_at,
       total
FROM orders;

SELECT DATE_PART('dow',occurred_at) AS day_of_week,
       SUM(total) AS total_qty
FROM orders
GROUP BY 1
ORDER BY 2;

SELECT DATE_TRUNC('day',occurred_at) AS day,
       SUM(standard_qty) AS standard_qty_sum
FROM orders
GROUP BY occurred_at
ORDER BY occurred_at;

SELECT DATE_TRUNC('year',occurred_at) AS year,
       SUM(standard_qty) AS standard_qty_sum
FROM orders
GROUP BY occurred_at
ORDER BY occurred_at;

SELECT DATE_PART('year',occurred_at) AS day,
       SUM(standard_qty) AS standard_qty_sum
FROM orders
GROUP BY occurred_at
ORDER BY occurred_at;

-- https://www.postgresql.org/docs/9.1/functions-datetime.html
-- Questions: Working With DATEs
-- 1. Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least.
-- Do you notice any trends in the yearly sales totals?
SELECT DATE_PART('year',occurred_at) AS YEAR,
       SUM(total_amt_usd) AS sales
FROM orders
GROUP BY occurred_at
ORDER BY sales DESC;

SELECT DATE_PART('year', occurred_at), DATE_PART('month', occurred_at)
FROM orders
GROUP BY 1,2
ORDER BY 1;
-- When we look at the yearly totals, you might notice that 2013 and 2017 have much smaller totals than all other years. 
-- If we look further at the monthly data, we see that for 2013 and 2017 there is only one month of sales 
-- for each of these years (12 for 2013 and 1 for 2017). Therefore, neither of these is evenly represented. 
-- Sales have been increasing year over year, with 2016 being the largest sales to date. 
-- At this rate, we might expect 2017 to have the largest sales.

-- 2. Which month did Parch & Posey have the greatest sales in terms of total dollars? 
-- Are all months evenly represented by the dataset?

SELECT DATE_PART('month', occurred_at) ord_month, SUM(total_amt_usd) total_spent
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC; 

-- 3. Which year did Parch & Posey have the greatest sales in terms of the total number of orders? 
-- Are all years evenly represented by the dataset?
SELECT DATE_PART('year', occurred_at) ord_month, SUM(total_amt_usd) total_spent
FROM orders
GROUP BY 1
ORDER BY 2 DESC;
-- Again, 2016 by far has the most amount of orders,
-- but again 2013 and 2017 are not evenly represented to the other years in the dataset.

-- 4. In which month of which year did Walmart spend the most on gloss paper in terms of dollars?

SELECT DATE_PART('year', occurred_at), DATE_PART('month', occurred_at), SUM(o.gloss_amt_usd) gloss_paper
FROM orders o
JOIN accounts a ON a.id =o.account_id
WHERE a.name = 'Walmart'
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 1;

-- OR
SELECT DATE_TRUNC('month', o.occurred_at) ord_date, SUM(o.gloss_amt_usd) tot_spent
FROM orders o 
JOIN accounts a
ON a.id = o.account_id
WHERE a.name = 'Walmart'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;












