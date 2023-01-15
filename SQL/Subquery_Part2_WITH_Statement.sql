-- Before diving headfirst into building a subquery, consider the workflow below. 
-- Strong SQL users walk through the following before ever writing a line of code:

-- 1.Determine if a subquery is needed (or a join/aggregation function will suffice).
-- 2.If a subquery is needed, determine where you’ll need to place it.
-- 3.Run the subquery as an independent query first: is the output what you expect?
-- 4.Call it something! If you are working with With or Inline subquery, you’ll most certainly need to name it.
-- 5.Run the entire query -- both the inner query and outer query.

-- Placement: WITH
-- Use Case for With subquery:
-- When a user wants to create a version of an existing table to be used in a larger query (e.g., aggregate daily prices to an average price table).
-- It is advantageous for readability purposes.

-- QUESTION: You need to find the average number of events for each channel per day.
SELECT DATE_TRUNC('day',occurred_at) AS day,
             channel, COUNT(*) as events
FROM web_events 
GROUP BY 1,2;

-- Using subquery
SELECT channel, AVG(events) AS average_events
FROM (SELECT DATE_TRUNC('day',occurred_at) AS day,
             channel, COUNT(*) as events
      FROM web_events 
      GROUP BY 1,2) sub
GROUP BY channel
ORDER BY 2 DESC;

-- Using WITH statement
WITH events AS (
          SELECT DATE_TRUNC('day',occurred_at) AS day, 
                        channel, COUNT(*) as events
          FROM web_events 
          GROUP BY 1,2)
		  
SELECT channel, AVG(events) AS average_events
FROM events
GROUP BY channel
ORDER BY 2 DESC;

-- We can create an additional table to pull from in the following way:

-- WITH table1 AS (
--           SELECT *
--           FROM web_events),

--      table2 AS (
--           SELECT *
--           FROM accounts)


-- SELECT *
-- FROM table1
-- JOIN table2
-- ON table1.account_id = table2.id;

-- WITH QUIZZES
-- 1. Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
WITH t1 AS (select s.name sales_rep_name,r.name region_name, SUM(o.total_amt_usd) total_amt
			from accounts a
			join orders o on a.id = o.account_id
			join sales_reps s on s.id = a.sales_rep_id
			join region r on r.id = s.region_id
			group by 1,2
			order by 3 desc
			),
	t2 AS (select region_name, MAX(total_amt) total_amt
		   from t1
		   group by 1)
SELECT t1.sales_rep_name, t1.region_name, t1.total_amt
FROM t1
JOIN t2
ON t1.region_name = t2.region_name AND t1.total_amt = t2.total_amt;

-- 2.For the region with the largest sales total_amt_usd, how many total orders were placed?
WITH T1 AS (
			select r.name region_name, SUM(o.total_amt_usd) total_amt
			from accounts a
			join orders o on a.id = o.account_id
			join sales_reps s on s.id = a.sales_rep_id
			join region r on r.id = s.region_id
			group by 1),
	T2 AS (
			SELECT MAX(total_amt)
		   	FROM T1)

SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (SELECT * FROM t2);

-- 3. How many accounts had more total purchases than the account name which has bought the most standard_qty paper
-- throughout their lifetime as a customer?
WITH t1 AS (
  SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
  FROM accounts a
  JOIN orders o
  ON o.account_id = a.id
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 1), 
t2 AS (
  SELECT a.name
  FROM orders o
  JOIN accounts a
  ON a.id = o.account_id
  GROUP BY 1
  HAVING SUM(o.total) > (SELECT total FROM t1))
SELECT COUNT(*)
FROM t2;
-- How many accounts in total have ordered more than the standard_qty of the customer with the most standard_qty?
with t1 as (
			select a.id,a.name,SUM(standard_qty) total_std_qty
			from accounts a
			join orders o 
			on a.id = o.account_id
			group by 1,2),
	t2 as (
			select max(total_std_qty) total_std_qty
			from t1),
	t3 as (
			select a.id,a.name
			from accounts a
			join orders o 
			on a.id = o.account_id
			group by 1,2
			having SUM(o.total) > (SELECT * FROM t2))
select count(*)
from t3;

-- 4. For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, 
-- how many web_events did they have for each channel?
WITH T1 AS (
	SELECT a.id t1_id,a.name account_name, SUM(o.total_amt_usd) total_usd
	FROM accounts a
	JOIN orders o
	ON o.account_id = a.id
	GROUP BY 1,2
	ORDER BY 3 DESC
	LIMIT 1)

SELECT account_name,w.channel,COUNT(*)
FROM web_events w
JOIN T1 
ON T1.t1_id = w.account_id
GROUP BY 1,2
ORDER BY 3 DESC;

-- OR
WITH t1 AS (
   SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id
   GROUP BY a.id, a.name
   ORDER BY 3 DESC
   LIMIT 1)
SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id FROM t1)
GROUP BY 1, 2
ORDER BY 3 DESC;

-- 5. What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?

WITH T1 AS (
	SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
	FROM orders o
	JOIN accounts a
	ON a.id = o.account_id
	GROUP BY a.id, a.name
	ORDER BY 3 DESC
	LIMIT 10)
SELECT AVG(tot_spent)
FROM T1;

-- 6. What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, 
-- on average, than the average of all orders.

WITH t1 AS (
   SELECT AVG(o.total_amt_usd) avg_all
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id),
t2 AS (
   SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
   FROM orders o
   GROUP BY 1
   HAVING AVG(o.total_amt_usd) > (SELECT * FROM t1))
SELECT AVG(avg_amt)
FROM t2;













