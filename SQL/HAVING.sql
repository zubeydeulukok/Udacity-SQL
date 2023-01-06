-- HAVING - Expert Tip
-- HAVING is the “clean” way to filter a query that has been aggregated, but this is also commonly done using a subquery. 
-- Essentially, any time you want to perform a WHERE on an element of your query that was created by an aggregate, you need to use HAVING instead.

SELECT account_id,
       SUM(total_amt_usd) AS sum_total_amt_usd
FROM orders
GROUP BY 1
ORDER BY 2 DESC;
-- -- Results in an Error
-- SELECT account_id,
--        SUM(total_amt_usd) AS sum_total_amt_usd
-- FROM orders
-- WHERE SUM(total_amt_usd) >= 250000
-- GROUP BY 1
-- ORDER BY 2 DESC;

SELECT account_id,
       SUM(total_amt_usd) AS sum_total_amt_usd
FROM orders
GROUP BY 1
HAVING SUM(total_amt_usd) >= 250000;

-- Questions: HAVING
-- 1. How many of the sales reps have more than 5 accounts that they manage?
SELECT s.id,s.name, COUNT(*) num_accounts
FROM sales_reps s
JOIN accounts a ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
HAVING COUNT(a.id) > 5
ORDER BY num_accounts;
-- Using a subquery
SELECT COUNT(*) num_reps_above5
FROM(SELECT s.id, s.name, COUNT(*) num_accounts
     FROM accounts a
     JOIN sales_reps s
     ON s.id = a.sales_rep_id
     GROUP BY s.id, s.name
     HAVING COUNT(*) > 5
     ORDER BY num_accounts) AS Table1;

-- 2. How many accounts have more than 20 orders?
SELECT a.id, a.name, COUNT(*) AS order_numbers
FROM accounts a
JOIN orders o On a.id = o.account_id
GROUP BY a.id,a.name
HAVING COUNT(*) > 20
ORDER BY order_numbers;

-- Using subquery
SELECT COUNT(*) ORDER_NUMBERS
FROM (SELECT a.id, a.name, COUNT(*) AS order_numbers
FROM accounts a
JOIN orders o On a.id = o.account_id
GROUP BY a.id,a.name
HAVING COUNT(*) > 20
ORDER BY order_numbers) as table_2;

-- 3. Which account has the most orders?

SELECT a.id, a.name, COUNT(*) AS order_numbers
FROM accounts a
JOIN orders o On a.id = o.account_id
GROUP BY a.id,a.name
ORDER BY order_numbers DESC
LIMIT 1;

-- 4.Which accounts spent more than 30,000 usd total across all orders?
SELECT a.id, a.name, SUM(o.total_amt_usd) AS total_spent
FROM accounts a
JOIN orders o On a.id = o.account_id
GROUP BY a.id,a.name
HAVING SUM(o.total_amt_usd) > 30000
ORDER BY total_spent;

-- 5. Which accounts spent less than 1,000 usd total across all orders?
SELECT a.id, a.name, SUM(o.total_amt_usd) AS total_spent
FROM accounts a
JOIN orders o On a.id = o.account_id
GROUP BY a.id,a.name
HAVING SUM(o.total_amt_usd) < 1000
ORDER BY total_spent;

-- 6. Which account has spent the most with us?
SELECT a.id, a.name, SUM(o.total_amt_usd) AS total_spent
FROM accounts a
JOIN orders o On a.id = o.account_id
GROUP BY a.id,a.name
ORDER BY total_spent DESC
LIMIT 1;

-- 7. Which account has spent the least with us?
SELECT a.id, a.name, SUM(o.total_amt_usd) AS total_spent
FROM accounts a
JOIN orders o On a.id = o.account_id
GROUP BY a.id,a.name
ORDER BY total_spent ASC
LIMIT 1;

-- 8. Which accounts used facebook as a channel to contact customers more than 6 times?
SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
HAVING COUNT(*) > 6 AND w.channel = 'facebook'
ORDER BY use_of_channel;

-- 9. Which account used facebook most as a channel?
SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE w.channel = 'facebook'
GROUP BY a.id, a.name, w.channel
ORDER BY use_of_channel DESC
LIMIT 1;
-- 10. Which channel was most frequently used by most accounts?
SELECT a.id, a.name, w.channel,COUNT(*) account_numbers
FROM accounts a
JOIN web_events w On a.id = w.account_id
GROUP BY 1,2,3
ORDER BY account_numbers DESC
LIMIT 10;

SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
ORDER BY use_of_channel DESC
LIMIT 10;
