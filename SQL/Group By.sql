-- GROUP BY Syntax

-- SELECT column_name(s)
-- FROM table_name
-- WHERE condition
-- GROUP BY column_name(s)
-- ORDER BY column_name(s);

-- The key takeaways here:

-- GROUP BY can be used to aggregate data within subsets of the data. For example, grouping for different accounts, different regions, or different sales representatives.
-- Any column in the SELECT statement that is not within an aggregator must be in the GROUP BY clause.
-- The GROUP BY always goes between WHERE and ORDER BY.
-- ORDER BY works like SORT in spreadsheet software.
-- SQL evaluates the aggregations before the LIMIT clause.

-- SELECT account_id,
--        SUM(standard_qty) AS standard,
--        SUM(gloss_qty) AS gloss,
--        SUM(poster_qty) AS poster
-- FROM orders;

SELECT account_id,
       SUM(standard_qty) AS standard,
       SUM(gloss_qty) AS gloss,
       SUM(poster_qty) AS poster
FROM orders
GROUP BY account_id
ORDER BY account_id;

-- QUESTIONS: GROUP BY
-- 1. Which account (by name) placed the earliest order? Your solution should have the account name and the date of the order.
SELECT a.name, o.occurred_at
FROM accounts a
JOIN orders o
ON a.id = o.account_id
ORDER BY occurred_at
LIMIT 1;

-- 2. Find the total sales in usd for each account. 
-- You should include two columns - the total sales for each company's orders in usd and the company name.
SELECT a.name, SUM(o.total_amt_usd) AS total_sales
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name;

-- 3. Via what channel did the most recent (latest) web_event occur, which account was associated with this web_event? 
-- Your query should return only three values - the date, channel, and account name.

SELECT w.occurred_at, w.channel, a.name
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
ORDER BY w.occurred_at DESC
LIMIT 1;

-- 4. Find the total number of times each type of channel from the web_events was used. 
-- Your final table should have two columns - the channel and the number of times the channel was used.

SELECT channel, COUNT(channel) AS number_of_tmes
FROM web_events
GROUP BY channel;

-- 5. Who was the primary contact associated with the earliest web_event?

SELECT a.primary_poc 
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
ORDER BY w.occurred_at ASC
LIMIT 1;

-- 6. What was the smallest order placed by each account in terms of total usd. Provide only two columns - the account name and the total usd.
-- Order from smallest dollar amounts to largest.

SELECT a.name, MIN(o.total_amt_usd) smallest_usd
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY smallest_usd;

-- 7. Find the number of sales reps in each region. 
-- Your final table should have two columns - the region and the number of sales_reps. Order from the fewest reps to most reps.

SELECT r.name, COUNT(sr.id) number_sales_reps
FROM region r
JOIN sales_reps sr ON r.id = sr.region_id
GROUP BY r.name
ORDER BY number_sales_reps;

-- Note that Group By and Order By can be used with multiple columns in the same query
-- GROUP BY - Expert Tips
-- 1. The order of column names in your GROUP BY clause doesn’t matter—the results will be the same regardless. 
-- If we run the same query and reverse the order in the GROUP BY clause, you can see we get the same results.
-- 2. As with ORDER BY, you can substitute numbers for column names in the GROUP BY clause.
-- It’s generally recommended to do this only when you’re grouping many columns, or if something else is causing the text in the GROUP BY clause to be excessively long.
-- 3. A reminder here that any column that is not within an aggregation must show up in your GROUP BY statement.
-- If you forget, you will likely get an error. However, in the off chance that your query does work, you might not like the results!

SELECT account_id,
       channel,
       COUNT(id) as events
FROM web_events
GROUP BY account_id, channel
ORDER BY account_id, channel;

SELECT account_id,
       channel,
       COUNT(id) as events
FROM web_events
GROUP BY account_id, channel
ORDER BY account_id, channel DESC;

-- Questions: GROUP BY Part II
-- 1. For each account, determine the average amount of each type of paper they purchased across their orders. 
-- Your result should have four columns - one for the account name and one for the average quantity purchased 
-- for each of the paper types for each account.
SELECT a.name, AVG(standard_qty) AS standard, AVG(gloss_qty) AS gloss, AVG(poster_qty) AS poster
FROM accounts a 
JOIN orders o ON a.id = o.account_id
GROUP BY a.name;

-- 2. For each account, determine the average amount spent per order on each paper type. 
-- Your result should have four columns - one for the account name and one for the average amount spent on each paper type.

SELECT a.name, AVG(standard_amt_usd) AS standard, AVG(gloss_amt_usd) AS gloss, AVG(poster_amt_usd) AS poster
FROM accounts a 
JOIN orders o ON a.id = o.account_id
GROUP BY a.name;

-- 3. Determine the number of times a particular channel was used in the web_events table for each sales rep.
-- Your final table should have three columns - the name of the sales rep, the channel, and the number of occurrences. 
-- Order your table with the highest number of occurrences first.

SELECT s.name, w.channel, COUNT(*) num_events
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name, w.channel
ORDER BY num_events DESC;

-- 4. Determine the number of times a particular channel was used in the web_events table for each region. 
-- Your final table should have three columns - the region name, the channel, and the number of occurrences. 
-- Order your table with the highest number of occurrences first.

SELECT r.name, w.channel, COUNT(*) num_events
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r ON r.id = s.region_id
GROUP BY r.name, w.channel
ORDER BY num_events DESC;


