-- LEFT & RIGHT Quizzes
-- 1.In the accounts table, there is a column holding the website for each company.
-- The last three digits specify what type of web address they are using. A list of extensions (and pricing) is provided here. 
-- Pull these extensions and provide how many of each website type exist in the accounts table.
SELECT DISTINCT RIGHT(website, 3)
FROM accounts;

SELECT RIGHT(website, 3) AS domain, COUNT(*) num_companies
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;

-- 2. There is much debate about how much the name (or even the first letter of a company name) matters. 
-- Use the accounts table to pull the first letter of each company name to see the distribution of company names that begin with each letter (or number).
SELECT LEFT(name,1) first_letter, COUNT(*) num_cpmpanies
FROM accounts
GROUP BY 1
ORDER BY 1;

-- 3.Use the accounts table and a CASE statement to create two groups: one group of company names that start with a number and the second group of those company names that start with a letter. 
-- What proportion of company names start with a letter?

SELECT first_char, COUNT(*)
FROM (SELECT
		CASE WHEN LEFT(name,1) IN ('0','1','2','3','4','5','6','7','8','9') THEN 'numeric name' 
			WHEN LEFT(name,1) NOT IN ('0','1','2','3','4','5','6','7','8','9') THEN 'letter name' 
		END AS first_char 
		FROM accounts) t1
GROUP BY 1;
-- OR
SELECT SUM(num) nums, SUM(letter) letters
FROM (SELECT name, 
		  CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') THEN 1 ELSE 0 
		  END AS num, 
		  CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') THEN 0 ELSE 1 
		  END AS letter
      FROM accounts) t1;
	  
SELECT 100*SUM(vovels)/COUNT(DISTINCT name) result
FROM (SELECT name,
			CASE WHEN LEFT(UPPER(name),1) IN ('A','E','I','O','U') THEN 1 ELSE 0
			END AS vovels
	 FROM accounts) t1;
-- OR
SELECT SUM(vowels) vowels, SUM(other) other
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U') 
                           THEN 1 ELSE 0 END AS vowels, 
             CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U') 
                          THEN 0 ELSE 1 END AS other
            FROM accounts) t1;
-- Quiz: CONCAT, LEFT, RIGHT, and SUBSTR
-- Suppose the company wants to assess the performance of all the sales representatives. 
-- Each sales representative is assigned to work in a particular region. 
-- To make it easier to understand for the HR team, display the concatenated sales_reps.id, ‘_’ (underscore),
-- and region.name as EMP_ID_REGION for each sales representative.
SELECT CONCAT(s.name,'_',r.name) emp_id_region
FROM sales_reps s
JOIN region r
ON r.id = s.region_id;

-- 2.
SELECT name, CONCAT(LAT, ',', LONG) COORDINATE, CONCAT(LEFT(PRIMARY_POC, 1), RIGHT(PRIMARY_POC, 1), '@', SUBSTR(WEBSITE, 5)) EMAIL
FROM ACCOUNTS;

-- 3. From the web_events table, display the concatenated value of account_id, '_' , channel, '_', count of web events of the particular channel.
WITH T1 AS (
	 SELECT ACCOUNT_ID, CHANNEL, COUNT(*) 
	 FROM WEB_EVENTS
	 GROUP BY ACCOUNT_ID, CHANNEL
	 ORDER BY ACCOUNT_ID
)

SELECT CONCAT(t1.account_id,'_',t1.channel,'_', count)
FROM t1;

-- CAST: Converts a value of any type into a specific, different data type
-- CAST(expression AS datatype)
-- CAST(salary AS int)

SELECT *
FROM accounts;

-- -- Notes:
-- select date, CAST(concat(substr(date,7,4),'-',substr(date,1,2),'-',substr(date,4,2)) AS date) new_date
-- from sf_crime_data
-- -- gives the same output as
-- SELECT date orig_date, (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2))::DATE new_date
-- FROM sf_crime_data;

-- POSITION: Returns the position of the first occurrence of a substring in a string
select position('com' IN website)
from accounts;

-- STRPOS: Converts a value of any type into a specific, different data type
-- STRPOS(string, substring)
select STRPOS(website,'com')
from accounts;

-- Quizzes POSITION & STRPOS
-- 1.Use the accounts table to create first and last name columns that hold the first and last names for the primary_poc.
select position(' ' IN primary_poc)
from accounts;

SELECT LEFT(primary_poc,position(' ' IN primary_poc)-1) first_name,
	RIGHT(primary_poc, LENGTH(primary_poc)-position(' ' IN primary_poc)) last_name
FROM accounts;
-- 2. Now see if you can do the same thing for every rep name in the sales_reps table. Again provide first and last name columns.
SELECT LEFT(name,position(' ' IN name)-1) first_name,
	RIGHT(name, LENGTH(name)-position(' ' IN name)) last_name
FROM sales_reps;

-- Quizzes CONCAT
-- 1. Each company in the accounts table wants to create an email address for each primary_poc. 
-- The email address should be the first name of the primary_poc . last name primary_poc @ company name .com.
select CONCAT(LEFT(primary_poc,position(' ' IN primary_poc)-1),'.',
			  RIGHT(primary_poc, LENGTH(primary_poc)-position(' ' IN primary_poc)),'@',name,'.com') email
from accounts;

-- or
WITH t1 AS (
 SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', name, '.com')
FROM t1;

-- 2. You may have noticed that in the previous solution some of the company names include spaces, which will certainly not work in an email address. 
-- See if you can create an email address that will work by removing all of the spaces in the account name, but otherwise, your solution should be just as in question 1. 
select CONCAT(LEFT(primary_poc,position(' ' IN primary_poc)-1),'.',
			  RIGHT(primary_poc, LENGTH(primary_poc)-position(' ' IN primary_poc)),'@',LEFT(name,position(' ' IN name)-1) ,
	RIGHT(name, LENGTH(name)-position(' ' IN name)),'.com') email
from accounts;

-- or
WITH t1 AS (
 SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', REPLACE(name, ' ', ''), '.com')
FROM  t1;
-- CREATING PASSWORDS
WITH t1 AS (
 SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', name, '.com'), LEFT(LOWER(first_name), 1) || RIGHT(LOWER(first_name), 1) || LEFT(LOWER(last_name), 1) || RIGHT(LOWER(last_name), 1) || LENGTH(first_name) || LENGTH(last_name) || REPLACE(UPPER(name), ' ', '')
FROM t1;

-- concat or ||
SELECT LEFT(primary_poc,STRPOS(primary_poc,' ')-1) || RIGHT(primary_poc,LENGTH(primary_poc)-STRPOS(primary_poc,' '))
FROM accounts;

-- COALESCE
-- COALESCE: Returns the first non-null value in a list.

SELECT *
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, o.*
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, COALESCE(o.account_id, a.id) account_id, o.occurred_at, o.standard_qty, o.gloss_qty, o.poster_qty, o.total, o.standard_amt_usd, o.gloss_amt_usd, o.poster_amt_usd, o.total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, COALESCE(o.account_id, a.id) account_id, o.occurred_at, COALESCE(o.standard_qty, 0) standard_qty, COALESCE(o.gloss_qty,0) gloss_qty, COALESCE(o.poster_qty,0) poster_qty, COALESCE(o.total,0) total, COALESCE(o.standard_amt_usd,0) standard_amt_usd, COALESCE(o.gloss_amt_usd,0) gloss_amt_usd, COALESCE(o.poster_amt_usd,0) poster_amt_usd, COALESCE(o.total_amt_usd,0) total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

SELECT COUNT(*)
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id;

SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, COALESCE(o.account_id, a.id) account_id, o.occurred_at, COALESCE(o.standard_qty, 0) standard_qty, COALESCE(o.gloss_qty,0) gloss_qty, COALESCE(o.poster_qty,0) poster_qty, COALESCE(o.total,0) total, COALESCE(o.standard_amt_usd,0) standard_amt_usd, COALESCE(o.gloss_amt_usd,0) gloss_amt_usd, COALESCE(o.poster_amt_usd,0) poster_amt_usd, COALESCE(o.total_amt_usd,0) total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id;