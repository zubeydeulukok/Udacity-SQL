-- What exactly is a subquery?

-- A subquery is a query within a query.

-- - As a reminder, a query has both SELECT and FROM clauses to signify what you want to extract from a table and what table you’d like to pull data from. 
-- A query that includes subquery, as a result, has multiple SELECT and FROM clauses.
-- - The subquery that sits nested inside a larger query is called an INNER QUERY. 
-- This inner query can be fully executed on its own and often is run independently before when trying to troubleshoot bugs in your code.
-- ********************************************* 
-- When do you need to use a subquery?
-- You need to use a subquery when you have the need to manipulate 
-- an existing table to “pseudo-create” a table that is then used as a part of a larger query. 
-- Some existing tables cannot be joined together to solve the problem at hand. 
-- Instead, an existing table needs to be manipulated, massaged, or aggregated in some way to then join to another table 
-- in the dataset to answer the posed question.

-- select *
-- from orders
-- where standard_qty > AVG(standard_qty);

select *
from orders
where standard_qty > (select AVG(standard_qty) from orders);

-- Subqueries:
-- Output: Either a scalar (a single value) or rows that have met a condition. 
-- Use Case: Calculate a scalar value to use in a later part of the query (e.g., average price as a filter). 
-- Dependencies: Stand independently and be run as complete queries themselves.

-- Joins:
-- Output: A joint view of multiple tables stitched together using a common “key”. 
-- Use Case: Fully stitch tables together and have full flexibility on what to “select” and “filter from”. 
-- Dependencies: Cannot stand independently.
-- ********************************************* 
-- Fundamentals to Know about Subqueries:
-- Subqueries must be fully placed inside parentheses.
-- Subqueries must be fully independent and can be executed on their own
-- Subqueries have two components to consider:
-- Where it’s placed
-- Dependencies with the outer/larger query
-- ********************************************* 
-- Subquery Placement:
-- With: This subquery is used when you’d like to “pseudo-create” a table from an existing table and visually scope the temporary table at the top of the larger query.

-- Nested: This subquery is used when you’d like the temporary table to act as a filter within the larger query, which implies that it often sits within the where clause.

-- Inline: This subquery is used in the same fashion as the WITH use case above. However, instead of the temporary table sitting on top of the larger query, it’s embedded within the from clause.

-- Scalar: This subquery is used when you’d like to generate a scalar value to be used as a benchmark of some sort.
-- 1. WITH
-- WITH subquery_name (column_name1, ...) AS
--  (SELECT ...)
-- SELECT ...

-- 2. INLINE
-- SELECT student_name
-- FROM
--   (SELECT student_id, student_name, grade
--    FROM student
--    WHERE teacher =10)
-- WHERE grade >80;
-- 3. NESTED
-- SELECT s.s_id, s.s_name, g.final_grade
-- FROM student s, grades g
-- WHERE s.s_id = g.s_id
-- IN (SELECT final_grade
--     FROM grades g
--     WHERE final_grade >3.7
--    );
-- 4.SCALAR
-- SELECT s.student_name
--   (SELECT AVG(final_score)
--    FROM grades g
--    WHERE g.student_id = s.student_id) AS
--      avg_score
-- FROM student s;
-- **************************************************
-- You’ll notice the following order of operations.

-- Build the Subquery: The aggregation of an existing table that you’d like to leverage as a part of the larger query.
-- Run the Subquery: Because a subquery can stand independently, it’s important to run its content first to get a sense of whether this aggregation is the interim output you are expecting.
-- Encapsulate and Name: Close this subquery off with parentheses and call it something. In this case, we called the subquery table ‘sub.’
-- Test Again: Run a SELECT * within the larger query to determine if all syntax of the subquery is good to go.
-- Build Outer Query: Develop the SELECT * clause as you see fit to solve the problem at hand, leveraging the subquery appropriately.

-- Time for more Hands-on Practice
-- which channels send the most traffic per day on average to Parch and Posey.

SELECT channel,
       AVG(event_count) AS avg_event_count
FROM
(SELECT DATE_TRUNC('day',occurred_at) AS day,
        channel,
        count(*) as event_count
   FROM web_events
   GROUP BY 1,2
   ) sub
GROUP BY 1
ORDER BY 2 DESC;

-- Quiz 1
-- On which day-channel pair did the most events occur.
SELECT DATE_TRUNC('day',occurred_at) AS day,
        channel,
        count(*) as event_count
FROM web_events
GROUP BY 1,2
ORDER BY 3 DESC;

-- Steps:
-- 1. First, we needed to group by the day and channel. 
-- Then ordering by the number of events (the third column) gave us a quick way to answer the first question.
SELECT DATE_TRUNC('day',occurred_at) AS day,
       channel, COUNT(*) as events
FROM web_events
GROUP BY 1,2
ORDER BY 3 DESC;
-- 2. we are able to get a table that shows the average number of events a day for each channel.
SELECT channel, AVG(events) AS average_events
FROM (SELECT DATE_TRUNC('day',occurred_at) AS day,
                channel, COUNT(*) as events
         FROM web_events 
         GROUP BY 1,2) sub
GROUP BY channel
ORDER BY 2 DESC;

-- Well Formatted Query
SELECT *
FROM (SELECT DATE_TRUNC('day',occurred_at) AS day,
                channel, COUNT(*) as events
      FROM web_events 
      GROUP BY 1,2
      ORDER BY 3 DESC) sub;
-- Additionally, if we have a GROUP BY, ORDER BY, WHERE, HAVING, or any other statement following our subquery,
-- we would then indent it at the same level as our outer query.
SELECT *
FROM (SELECT DATE_TRUNC('day',occurred_at) AS day,
                channel, COUNT(*) as events
      FROM web_events 
      GROUP BY 1,2
      ORDER BY 3 DESC) sub
GROUP BY day, channel, events
ORDER BY 2 DESC;

-- An example for nested query used inside where clause
-- We want to return only orders that occurred in the same month as Parch and Posies first order ever.
SELECT *
FROM orders
WHERE DATE_TRUNC('month',occurred_at) =
 (SELECT DATE_TRUNC('month',MIN(occurred_at)) AS min_month
  FROM orders)
ORDER BY occurred_at;
-- The average amount of standard paper, gloss paper, poster paper sold on the first month that any order was placed in the orders table (in terms of quantity).
SELECT AVG(standard_qty) std, AVG(gloss_qty) gloss, AVG(poster_qty) poster, SUM(TOTAL_AMT_USD) total_spent
FROM orders
WHERE DATE_TRUNC('month',occurred_at) =
 (SELECT DATE_TRUNC('month',MIN(occurred_at)) AS min_month
  FROM orders);
-- ***********************************************
-- Subqueries : Simple vs. Correlated
-- Simple: The inner subquery is completely independent from the outer query
-- Correlated: The inner subquery is dependent on a clause in the outer query
-- Simple Subquery
-- ************************************************
-- Views in SQL
--  views are the virtual tables that are derived from one or more base tables.
-- The syntax for creating a view is
-- CREATE VIEW <VIEW_NAME>
-- AS
-- SELECT …
-- FROM …
-- WHERE …

-- sales representatives who are looking after the accounts in the Northeast region only.
-- create view v1
-- as
-- select S.id, S.name as Rep_Name, R.name as Region_Name
-- from sales_reps S
-- join region R
-- on S.region_id = R.id
-- and R.name = 'Northeast';

select *
from v1;
-- The Question
-- 1. What is the top channel used by each account to market products?
-- 2. How often was that same channel used?
-- Let's find the number of times each channel is used by each account.
SELECT a.id, a.name, we.channel, COUNT(*) ct
FROM accounts a
JOIN web_events we
ON a.id = we.account_id
GROUP BY a.id, a.name, we.channel
ORDER BY a.id;
-- We need to see which usage of the channel in our first query is equal to the maximum usage channel for that account.
SELECT t1.id, t1.name, MAX(ct)
FROM (SELECT a.id, a.name, we.channel, COUNT(*) ct
     FROM accounts a
     JOIN web_events we
     On a.id = we.account_id
     GROUP BY a.id, a.name, we.channel) T1
GROUP BY t1.id, t1.name;

SELECT *
FROM (SELECT a.id, a.name, we.channel, COUNT(*) ct
	FROM accounts a
	JOIN web_events we
	ON a.id = we.account_id
	GROUP BY a.id, a.name, we.channel) t3
JOIN (SELECT t1.id, t1.name, MAX(ct) max_chan
	  FROM (SELECT a.id, a.name, we.channel, COUNT(*) ct
		 	FROM accounts a
		 	JOIN web_events we
		 	On a.id = we.account_id
		 	GROUP BY a.id, a.name, we.channel) t1
		GROUP BY t1.id, t1.name) t2
ON t2.id = t3.id AND t2.max_chan = t3.ct
ORDER BY t3.id;
-- ******************************************
-- More Subqueries Quizzes
-- 1. Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
FROM accounts a
JOIN orders o ON a.id = o.account_id
JOIN sales_reps s ON a.sales_rep_id = s.id
JOIN region r ON r.id = s.region_id
GROUP BY 1,2
ORDER BY 3 DESC;

SELECT region_name, MAX(total_amt) total_amt
FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
     FROM sales_reps s
     JOIN accounts a
     ON a.sales_rep_id = s.id
     JOIN orders o
     ON o.account_id = a.id
     JOIN region r
     ON r.id = s.region_id
     GROUP BY 1, 2) t1
GROUP BY 1;
-- Finally;
SELECT t3.rep_name, t3.region_name, t3.total_amt
FROM(SELECT region_name, MAX(total_amt) total_amt
     FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY 1, 2) t1
     GROUP BY 1) t2
JOIN (SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
     FROM sales_reps s
     JOIN accounts a
     ON a.sales_rep_id = s.id
     JOIN orders o
     ON o.account_id = a.id
     JOIN region r
     ON r.id = s.region_id
     GROUP BY 1,2
     ORDER BY 3 DESC) t3
ON t3.region_name = t2.region_name AND t3.total_amt = t2.total_amt;
--  2. For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed?
SELECT r.name, COUNT(o.total) total_order
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
WHERE r.name = (SELECT t1.region_name
FROM (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY 1
ORDER BY 2 desc
LIMIT 1) t1)
GROUP BY 1;
-- OR
SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (
      SELECT MAX(total_amt)
      FROM (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
              FROM sales_reps s
              JOIN accounts a
              ON a.sales_rep_id = s.id
              JOIN orders o
              ON o.account_id = a.id
              JOIN region r
              ON r.id = s.region_id
              GROUP BY r.name) sub);

-- 3. How many accounts had more total purchases than the account name 
-- which has bought the most standard_qty paper throughout their lifetime as a customer?
SELECT COUNT(*)
FROM(SELECT a.name
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
HAVING SUM(o.total) > (SELECT most_qty
						FROM (SELECT a.name, SUM(o.standard_qty) most_qty
						FROM accounts a
						JOIN orders o
						ON a.id = o.account_id
						GROUP BY 1
						ORDER BY 2 DESC
						LIMIT 1) t1)) t2;

-- OR
SELECT COUNT(*)
FROM (SELECT a.name
       FROM orders o
       JOIN accounts a
       ON a.id = o.account_id
       GROUP BY 1
       HAVING SUM(o.total) > (SELECT total 
                   FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                         FROM accounts a
                         JOIN orders o
                         ON o.account_id = a.id
                         GROUP BY 1
                         ORDER BY 2 DESC
                         LIMIT 1) inner_tab)
             ) counter_tab;
						
-- 4. For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd,
-- how many web_events did they have for each channel?
-- Solution : The customer that spent the most

SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE a.name = (SELECT t1.name
FROM (SELECT a.name, SUM(o.total_amt_usd) most_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1) t1)
GROUP BY a.name, w.channel
ORDER BY 3 DESC;

-- OR
SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id
                     FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
                           FROM orders o
                           JOIN accounts a
                           ON a.id = o.account_id
                           GROUP BY a.id, a.name
                           ORDER BY 3 DESC
                           LIMIT 1) inner_table)
GROUP BY 1, 2
ORDER BY 3 DESC;

-- 5. What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
SELECT a.id, a.name, AVG(total_amt_usd)
FROM orders o
JOIN accounts a
ON a.id = o.account_id AND a.id IN (SELECT id
								    FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
										FROM orders o
										JOIN accounts a
										ON a.id = o.account_id
										GROUP BY a.id, a.name
										ORDER BY 3 DESC
										LIMIT 10) t1 )
GROUP BY 1, 2
ORDER BY 3 DESC;

-- we just want the average of these 10 amounts.
SELECT AVG(tot_spent)
FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
      FROM orders o
      JOIN accounts a
      ON a.id = o.account_id
      GROUP BY a.id, a.name
      ORDER BY 3 DESC
      LIMIT 10) temp;

-- 6. What is the lifetime average amount spent in terms of total_amt_usd, 
-- including only the companies that spent more per order, on average, than the average of all orders?
SELECT AVG(total_amt_usd)
FROM (SELECT a.name, AVG(o.total_amt_usd) total_amt_usd
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY 1
HAVING AVG(o.total_amt_usd/ (o.total+0.01)) > (SELECT AVG(o.total_amt_usd / (o.total+0.01))
											   FROM orders o)) t1 ;


-- The solution by Udacity
SELECT AVG(avg_amt)
FROM (SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
    FROM orders o
    GROUP BY 1
    HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) avg_all
                                   FROM orders o)) temp_table;
