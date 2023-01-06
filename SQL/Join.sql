SELECT orders.*
FROM orders
JOIN accounts
ON orders.account_id = accounts.id;

SELECT accounts.name, orders.occurred_at
FROM orders
JOIN accounts
ON orders.account_id = accounts.id;

SELECT *
FROM orders
JOIN accounts
ON orders.account_id = accounts.id;

--  all the information from only the orders table:
SELECT orders.*
FROM orders
JOIN accounts
ON orders.account_id = accounts.id;

-- Try pulling all the data from the accounts table, and all the data from the orders table.
SELECT orders.*, accounts.*
FROM accounts
JOIN orders
ON accounts.id = orders.account_id;
-- Try pulling standard_qty, gloss_qty, and poster_qty from the orders table, 
-- ... and the website and the primary_poc from the accounts table.
SELECT orders.standard_qty,orders.gloss_qty, orders.poster_qty,
	 accounts.website, accounts.primary_poc
FROM orders
JOIN accounts
ON orders.account_id = accounts.id;
-- Notice that we need to specify every table a column comes from in the SELECT statement.
-- Entity Relationship Diagrams
-- JOIN More than Two Tables
SELECT *
FROM web_events
JOIN accounts
ON web_events.account_id = accounts.id
JOIN orders
ON accounts.id = orders.account_id;
-- To pull specific columns
SELECT web_events.channel, accounts.name, orders.total
FROM web_events
JOIN accounts
ON web_events.account_id = accounts.id
JOIN orders
ON accounts.id = orders.account_id;
-- Aliases
SELECT o.*, a.*
FROM orders o
JOIN accounts a
ON o.account_id = a.id;
-- Question-1
-- Provide a table for all web_events associated with the account name of Walmart.
-- There should be three columns. Be sure to include the primary_poc, time of the event,
-- and the channel for each event. 
-- Additionally, you might choose to add a fourth column to assure only Walmart events were chosen.
SELECT ac.primary_poc, w.occurred_at, w.channel, ac.name
FROM web_events w
JOIN accounts ac
ON ac.id = w.account_id
where ac.name= 'Walmart';
-- Question-2 :
-- Provide a table that provides the region for each sales_rep along with their associated accounts. 
-- Your final table should include three columns: the region name, the sales rep name, and the account name. 
-- Sort the accounts alphabetically (A-Z) according to the account name.
SELECT r.name region_name, s.name sales_name, ac.name account_name
FROM region r
JOIN sales_reps s
ON r.id=s.region_id
JOIN accounts ac
ON s.id = ac.sales_rep_id
ORDER BY account_name;
-- ORDER BY ac.name
-- Question-3
-- Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order.
-- Your final table should have 3 columns: region name, account name, and unit price. 
-- A few accounts have 0 for total, so I divided by (total + 0.01) to assure not dividing by zero.
SELECT r.name region_name, ac.name account_name, (o.total_amt_usd/(o.total+0.01)) unit_price
FROM orders o
JOIN accounts ac
ON ac.id = o.account_id
JOIN sales_reps sr
ON sr.id = ac.sales_rep_id
JOIN region r 
ON r.id = sr.region_id;
-- OR
SELECT r.name region, a.name account, 
    o.total_amt_usd/(o.total + 0.01) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id;

-- That's right! We can simply write our alias directly after the column name (in the SELECT) or table name (in the FROM or JOIN) by writing the alias directly following the column or table we would like to alias.
-- This will allow you to create clear column names even if calculations are used to create the column, and you can be more efficient with your code by aliasing table names.
-- Left-Right Joins
SELECT a.id, a.name, o.total
FROM orders o
JOIN accounts a
ON o.account_id = a.id;

SELECT a.id, a.name, o.total
FROM orders o
LEFT JOIN accounts a
ON o.account_id = a.id;

SELECT a.id, a.name, o.total
FROM orders o
RIGHT JOIN accounts a
ON o.account_id = a.id;

-- A LEFT JOIN and RIGHT JOIN do the same thing if we change the tables that are in the FROM and JOIN statements.
-- A LEFT JOIN will at least return all the rows that are in an INNER JOIN.
-- JOIN and INNER JOIN are the same.
-- A LEFT OUTER JOIN is the same as LEFT JOIN.
SELECT orders.*, accounts.*
FROM orders
LEFT JOIN accounts
ON orders.account_id = accounts.id 
WHERE accounts.sales_rep_id = 321500;

SELECT orders.*, accounts.*
FROM orders
JOIN accounts
ON orders.account_id = accounts.id 
WHERE accounts.sales_rep_id = 321500;
-- JOINS QUIZ
-- Question-1: Provide a table that provides the region for each sales_rep along with their associated accounts. 
-- This time only for the Midwest region. Your final table should include three columns: the region name, the sales rep name, and the account name. 
-- Sort the accounts alphabetically (A-Z) according to the account name.
SELECT r.name region, s.name sales_rep, a.name account
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
WHERE r.name = 'Midwest';
-- Question-2:Provide a table that provides the region for each sales_rep along with their associated accounts. 
-- This time only for accounts where the sales rep has a first name starting with S and in the Midwest region. 
-- Your final table should include three columns: the region name, the sales rep name, and the account name.
-- Sort the accounts alphabetically (A-Z) according to the account name.
SELECT r.name region, s.name sales_rep, a.name account
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
WHERE r.name = 'Midwest' AND s.name LIKE 'S%'
ORDER BY a.name;
-- Question-3: Provide a table that provides the region for each sales_rep along with their associated accounts. 
-- This time only for accounts where the sales rep has a last name starting with K and in the Midwest region. Your final table should include three columns: the region name, the sales rep name, and the account name.
-- Sort the accounts alphabetically (A-Z) according to the account name.
SELECT r.name region, s.name sales_rep, a.name account
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
WHERE r.name = 'Midwest' AND s.name LIKE '%K%' AND s.name NOT LIKE 'K%' 
ORDER BY a.name;

-- Question-4: Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order. 
-- However, you should only provide the results if the standard order quantity exceeds 100. 
-- Your final table should have 3 columns: region name, account name, and unit price. In order to avoid a division by zero error, adding .01 to the denominator here is helpful total_amt_usd/(total+0.01).
SELECT r.name region, a.name account, (o.total_amt_usd/(o.total+0.01)) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
WHERE o.standard_qty > 100;
-- Question-5: Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order. 
-- However, you should only provide the results if the standard order quantity exceeds 100 and the poster order quantity exceeds 50. Your final table should have 3 columns: region name, account name, and unit price. 
-- Sort for the smallest unit price first. 
-- In order to avoid a division by zero error, adding .01 to the denominator here is helpful (total_amt_usd/(total+0.01).

SELECT r.name region, a.name account, (o.total_amt_usd/(o.total+0.01)) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
WHERE o.standard_qty > 100 AND o.poster_qty > 50
ORDER BY unit_price;

-- Question-6
-- Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order. 
-- However, you should only provide the results if the standard order quantity exceeds 100 and the poster order quantity exceeds 50. 
-- Your final table should have 3 columns: region name, account name, and unit price. Sort for the largest unit price first. In order to avoid a division by zero error, adding .01 to the denominator here is helpful (total_amt_usd/(total+0.01).
 
SELECT r.name region, a.name account, (o.total_amt_usd/(o.total+0.01)) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
WHERE o.standard_qty > 100 AND o.poster_qty > 50
ORDER BY unit_price DESC;

-- Question-7: What are the different channels used by account id 1001?
-- Your final table should have only 2 columns: account name and the different channels. 
-- You can try SELECT DISTINCT to narrow down the results to only the unique values.

SELECT DISTINCT a.name, w.channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE w.account_id = 1001;
-- OR 
-- WHERE a.id = 1001

-- Question-8: Find all the orders that occurred in 2015. 
-- Your final table should have 4 columns: occurred_at, account name, order total, and order total_amt_usd.

SELECT o.occurred_at, a.name, o.total, o.total_amt_usd
FROM accounts a
JOIN orders o
ON o.account_id=a.id
WHERE o.occurred_at BETWEEN '01.01.2015' and '01.01.2016'
order by o.occurred_at DESC;

SELECT o.occurred_at, a.name, o.total, o.total_amt_usd
FROM accounts a
JOIN orders o
ON o.account_id = a.id
WHERE o.occurred_at BETWEEN '01-01-2015' AND '01-01-2016'
ORDER BY o.occurred_at DESC;

-- Recap
-- 1. Foreign Key (FK)	is a column in one table that is a primary key in a different table
-- 2. JOIN	is an INNER JOIN that only pulls data that exists in both tables.
-- 3. LEFT JOIN	is a JOIN that pulls all the data that exists in both tables, as well as all of the rows from the table in the FROM even if they do not exist in the JOIN statement.
-- 4. Partition by	A subclause of the OVER clause. Similar to GROUP BY.
-- 5. Primary Key (PK)	is a unique column in a particular table
-- 6. RIGHT JOIN	is a JOIN pulls all the data that exists in both tables, as well as all of the rows from the table in the JOIN even if they do not exist in the FROM statement.






