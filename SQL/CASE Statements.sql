-- "CASE" statement handles "IF" "THEN" LOGIC
-- CASE Syntax
-- CASE
--     WHEN condition1 THEN result1
--     WHEN condition2 THEN result2
--     WHEN conditionN THEN resultN
--     ELSE result
-- END;
-- CASE - Expert Tip
-- 1.The CASE statement always goes in the SELECT clause.
-- 2.CASE must include the following components: WHEN, THEN, and END. ELSE is an optional component to catch cases that didn’t meet any of the other previous CASE conditions.
-- 3.You can make any conditional statement using any conditional operator (like WHERE) between WHEN and THEN. This includes stringing together multiple conditional statements using AND and OR.
-- 4.You can include multiple WHEN statements, as well as an ELSE statement again, to deal with any unaddressed conditions.

-- We wnat to compare Facebook as a marketing channel againts all other channels:
SELECT id,
       account_id,
       occurred_at,
       channel,
       CASE WHEN channel = 'facebook' THEN 'yes' END AS is_facebook
FROM web_events
ORDER BY occurred_at;

SELECT id,
       account_id,
       occurred_at,
       channel,
       CASE WHEN channel = 'facebook' THEN 'yes' ELSE 'no' END AS is_facebook
FROM web_events
ORDER BY occurred_at;

SELECT id,
       account_id,
       occurred_at,
       channel,
       CASE WHEN channel = 'facebook' OR channel = 'direct' THEN 'yes' 
       ELSE 'no' END AS is_facebook
FROM web_events
ORDER BY occurred_at;

SELECT account_id,
       occurred_at,
       total,
       CASE WHEN total > 500 THEN 'Over 500'
            WHEN total > 300 THEN '301 - 500'
            WHEN total > 100 THEN '101 - 300'
            ELSE '100 or under' END AS total_group
FROM orders;

SELECT account_id,
       occurred_at,
       total,
       CASE WHEN total > 500 THEN 'Over 500'
            WHEN total > 300 AND total <= 500 THEN '301 - 500'
            WHEN total > 100 AND total <=300 THEN '101 - 300'
            ELSE '100 or under' END AS total_group
FROM orders;

-- a qUESTİON
-- Create a column that divides the standard_amt_usd by the standard_qty to find the unit price for standard paper for each order.
-- Limit the results to the first 10 orders, and include the id and account_id fields. NOTE - you will be thrown an error with the correct solution to this question. This is for a division by zero. 
-- You will learn how to get a solution without an error to this query when you learn about CASE statements in a later section.
SELECT account_id, 
	   CASE WHEN standard_qty = 0 OR standard_qty IS NULL THEN 0
       ELSE standard_amt_usd/standard_qty 
	   END AS unit_price
FROM orders
LIMIT 10;

-- CASE & Aggregations
SELECT CASE WHEN total > 500 THEN 'OVer 500'
            ELSE '500 or under' END AS total_group,
            COUNT(*) AS order_count
FROM orders
GROUP BY 1;

SELECT COUNT(1) AS orders_over_500_units
FROM orders
WHERE total > 500;

-- Questions: CASE
-- 1.Write a query to display for each order, the account ID, the total amount of the order, 
-- and the level of the order - ‘Large’ or ’Small’ - depending on if the order is $3000 or more, or smaller than $3000.
SELECT account_id, total_amt_usd, 
		CASE WHEN total_amt_usd >=3000 THEN 'Large'
			 WHEN total_amt_usd < 3000 THEN 'Small' 
		END AS order_level
FROM orders;

-- 2. Write a query to display the number of orders in each of three categories, based on the total number of items in each order. 
-- The three categories are: 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.
SELECT CASE WHEN total >= 2000 THEN 'At Least 2000'
            WHEN total BETWEEN 1000 AND 2000 THEN 'Between 1000 and 2000'
			WHEN total < 1000 THEN 'Less than 1000'
			END AS three_category,
            COUNT(*) AS order_count
FROM orders
GROUP BY 1;

-- 3. We would like to understand 3 different levels of customers based on the amount associated with their purchases. 
-- The top-level includes anyone with a Lifetime Value (total sales of all orders) greater than 200,000 usd. 
-- The second level is between 200,000 and 100,000 usd. The lowest level is anyone under 100,000 usd.
-- Provide a table that includes the level associated with each account. 
-- You should provide the account name, the total sales of all orders for the customer, and the level. 
-- Order with the top spending customers listed first.

SELECT a.name, SUM(o.total_amt_usd) total_spent,
		CASE WHEN SUM(o.total_amt_usd) > 200000 THEN 'Level 1'
		WHEN SUM(o.total_amt_usd) BETWEEN 100000 AND 200000 THEN 'Level 2'
		WHEN SUM(o.total_amt_usd) < 100000 THEN 'Level 3'
		END AS level
FROM accounts a
JOIN orders o ON a.id = o.account_id 
GROUP BY 1
ORDER BY 2 desc;
-- OR
SELECT a.name, SUM(total_amt_usd) total_spent, 
  CASE WHEN SUM(total_amt_usd) > 200000 THEN 'top'
  WHEN  SUM(total_amt_usd) > 100000 THEN 'middle'
  ELSE 'low' END AS customer_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id 
GROUP BY a.name
ORDER BY 2 DESC;

-- 4. We would now like to perform a similar calculation to the first, but we want to obtain the total amount spent by customers only in 2016 and 2017. 
-- Keep the same levels as in the previous question. Order with the top spending customers listed first.

SELECT a.name, SUM(total_amt_usd) total_spent, 
  CASE WHEN SUM(total_amt_usd) > 200000 THEN 'top'
  WHEN  SUM(total_amt_usd) > 100000 THEN 'middle'
  ELSE 'low' END AS customer_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id 
WHERE DATE_PART('year',o.occurred_at) IN (2016,2017)
GROUP BY a.name
ORDER BY 2 DESC;
-- OR
SELECT a.name, SUM(total_amt_usd) total_spent, 
  CASE WHEN SUM(total_amt_usd) > 200000 THEN 'top'
  WHEN  SUM(total_amt_usd) > 100000 THEN 'middle'
  ELSE 'low' END AS customer_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE occurred_at > '2015-12-31' 
GROUP BY 1
ORDER BY 2 DESC;

-- 5.We would like to identify top-performing sales reps, which are sales reps associated with more than 200 orders. 
-- Create a table with the sales rep name, the total number of orders, and a column with top or not depending on if they have more than 200 orders. 
-- Place the top salespeople first in your final table.
SELECT s.name, COUNT(o.total) total_orders, 
CASE WHEN COUNT(o.total) > 200 THEN 'top' ELSE 'not' END AS top_sales_rep
FROM accounts a 
JOIN sales_reps s ON s.id=a.sales_rep_id
JOIN orders o ON o.account_id = a.id 
GROUP BY 1
ORDER BY total_orders DESC
LIMIT 10;

-- 6. The previous didn't account for the middle, nor the dollar amount associated with the sales.
-- Management decides they want to see these characteristics represented as well. 
-- We would like to identify top-performing sales reps, which are sales reps associated with more than 200 orders or more than 750000 in total sales. 
-- The middle group has any rep with more than 150 orders or 500000 in sales. Create a table with the sales rep name, the total number of orders, 
-- total sales across all orders, and a column with top, middle, or low depending on these criteria. 
-- Place the top salespeople based on the dollar amount of sales first in your final table. 
-- You might see a few upset salespeople by this criteria!
SELECT s.name, COUNT(o.total) total_orders, SUM(total_amt_usd) total_sales,
CASE WHEN COUNT(o.total) > 200 OR SUM(total_amt_usd) > 750000 THEN 'top' 
	WHEN COUNT(o.total) > 150 OR SUM(total_amt_usd) > 500000 THEN 'middle'
	ELSE 'low' 
	END AS top_sales_rep
FROM accounts a 
JOIN sales_reps s ON s.id=a.sales_rep_id
JOIN orders o ON o.account_id = a.id 
GROUP BY 1
ORDER BY total_sales DESC
LIMIT 10;

-- RECAP

-- Each of the sections has been labeled to assist if you need to revisit a particular topic. 
-- Intentionally, the solutions for a particular section are actually not in the labeled section, 
-- because my hope is this will force you to practice if you have a question about a particular topic we covered.

-- You have now gained a ton of useful skills associated with SQL. 
-- The combination of JOINs and Aggregations is one of the reasons SQL is such a powerful tool.

-- If there was a particular topic you struggled with, I suggest coming back and revisiting the questions with a fresh mind. 
-- The more you practice the better, but you also don't want to get stuck on the same problem for an extended period of time!

-- In this lesson, we covered and you can now:
-- Deal with NULL values
-- Create aggregations in your SQL Queries including
-- COUNT
-- SUM
-- MIN & MAX
-- AVG
-- GROUP BY
-- DISTINCT
-- HAVING
-- Create DATE functions
-- Implement CASE statements
-- KeyTerm	Definition
-- DISTINCT	Always used in SELECT statements, and it provides the unique rows for all columns written in the SELECT statement.
-- GROUP BY	Used to aggregate data within subsets of the data. For example, grouping for different accounts, different regions, or different sales representatives.
-- HAVING	is the “clean” way to filter a query that has been aggregated
-- NULLs	A datatype that specifies where no data exists in SQL