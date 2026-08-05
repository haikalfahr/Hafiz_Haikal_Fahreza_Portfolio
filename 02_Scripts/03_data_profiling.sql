z-- 3.1. Check for duplicates

-- 3.1.1. Check duplicates in staging_customer table

SELECT * FROM staging_customers;

	-- Check for id duplicates
	
	SELECT customer_id, COUNT(*)  AS dp
	FROM staging_customers 
	GROUP BY customer_id
	HAVING dp > 1;
	
	-- Check for potential attribute duplicates
	
	SELECT age, gender, loyalty_member, join_date, COUNT(*) AS dp
	FROM staging_customers
	GROUP BY age, gender, loyalty_member, join_date
	HAVING dp > 1;
	
	-- Finding: While customer IDs are unique, multiple records share identical profiles (age, gender, loyalty status, and join date), 
	-- indicating potential duplicate registrations for the same individual
	-- however, due to the lack of verification data, no cleaning action is taken and this is currently accepted as-is.
 
-- 3.1.2 Check duplicates in staging_products table

SELECT * FROM staging_products;

	-- Check for id duplicates
	
	SELECT product_id, COUNT(*) AS dp 
	FROM staging_products
	GROUP BY product_id
	HAVING dp > 1;
	
	-- Check for attribute duplicates
	
	SELECT product_name, brand, cocoa_percent, weight_g, COUNT(*) AS dp
	FROM staging_products
	GROUP BY product_name, brand, cocoa_percent, weight_g
	HAVING dp > 1;
	
	
	-- Finding: While product IDs are unique, multiple records share identical profiles (product_name, brand, cocoa_percent, and weight_g), 
	-- indicating potential duplicate registrations for the same item (17 redundant groups found).
	-- All records are retained to avoid orphan data, as different stores may have actively 
	-- used these distinct product IDs during operational data entry
	
	SELECT * FROM staging_sales;

-- 3.1.3. Check duplicates in stores table

SELECT * FROM staging_stores;

	-- Check for id duplicates
	
	SELECT store_id, COUNT(*) AS dp
	FROM staging_stores
	GROUP BY store_id
	HAVING dp > 1;
	
	-- Check for attribute duplicates
	
	SELECT store_name, city, country, store_type, COUNT(*) AS dp
	FROM staging_stores
	GROUP BY store_name, city, country, store_type
	HAVING dp > 1;
	
	-- Finding: No duplicates were found in this table
	
	
-- 3.1.4. Check duplicates in staging_calendar table

SELECT * FROM staging_calendar;

	-- Check for id duplicates
	
	SELECT date, COUNT(*) AS dp
	FROM staging_calendar
	GROUP BY date 
	HAVING dp > 1;
	
	-- Check for attribute duplicates
	
	SELECT year, month, day, week, day_of_week, COUNT(*) AS dp
	FROM staging_calendar
	GROUP BY year, month, day, week, day_of_week
	HAVING dp > 1;
	
	-- Finding: No duplicates were found in this table
	
-- 3.1.5. Check duplicates in staging_sales table
	
SELECT * FROM staging_sales;

	-- Check for id duplicates
	
	SELECT order_id, COUNT(*) AS dp
	FROM staging_sales
	GROUP BY order_id
	HAVING dp > 1;
	
	-- Check for potential attribute duplicates
	
	SELECT order_date, product_id, store_id, customer_id, quantity, unit_price, discount, revenue, cost, profit, COUNT(*) AS dp
	FROM staging_sales
	GROUP BY order_date, product_id, store_id, customer_id, quantity, unit_price, discount, revenue, cost, profit
	HAVING dp > 1;
	
	-- Finding: No duplicates were found in this table
	
-- 3.2 Check for inconsistent data

SELECT * FROM staging_customers;
	
-- 3.2.1. Check inconsistent data in staging_customers table

	-- Check inconsistent data in customer_id column

	SELECT customer_id, COUNT(*) AS inc
	FROM staging_customers
	GROUP BY customer_id;
	
	-- Check inconsistent data in age column
	
	SELECT age, COUNT(*) AS inc
	FROM staging_customers
	GROUP BY age
	ORDER BY age ASC;
	
	-- Check inconsistent data in gender
	
	SELECT gender, COUNT(*) AS inc
	FROM staging_customers
	GROUP BY gender;
	
	-- Check inconsistent data in loyalty_member
	
	SELECT loyalty_member, COUNT(*) AS inc
	FROM staging_customers
	GROUP BY loyalty_member;
	
	-- Finding: No data inconsistencies is found in this table
	
-- 3.2.2. Check inconsistent data in staging_products table
	
SELECT * FROM staging_products;
	
	-- Check inconsistent data in product_name column

	SELECT product_id, COUNT(*) AS inc
	FROM staging_products
	GROUP BY product_id;
	
	-- Check inconsistent data in product_name column

	SELECT product_name, COUNT(*) AS inc
	FROM staging_products
	GROUP BY product_name;

	-- Check inconsistent data in brand column

	SELECT brand, COUNT(*) AS inc
	FROM staging_products
	GROUP BY brand;

	-- Check inconsistent data in category column

	SELECT category, COUNT(*) AS inc
	FROM staging_products
	GROUP BY category;

	-- Check inconsistent data in cocoa_percent column

	SELECT cocoa_percent, COUNT(*) AS inc
	FROM staging_products
	GROUP BY cocoa_percent
	ORDER BY cocoa_percent ASC;

	-- Check inconsistent data in weight_g column

	SELECT weight_g, COUNT(*) AS inc
	FROM staging_products
	GROUP BY weight_g
	ORDER BY weight_g ASC;
	
	-- Finding: No data inconsistencies is found in this table
	
	
-- 3.2.3. Check inconsistent data in staging_stores table
	
SELECT * FROM staging_stores;

	-- Check inconsistent data in store_id column

	SELECT store_id, COUNT(*) AS inc
	FROM staging_stores
	GROUP BY store_id;
	
	-- Check inconsistent data in store_name column

	SELECT store_name, COUNT(*) AS inc
	FROM staging_stores
	GROUP BY store_name;

	-- Check inconsistent data in city column

	SELECT city, COUNT(*) AS inc
	FROM staging_stores
	GROUP BY city;

	-- Check inconsistent data in country column

	SELECT country, COUNT(*) AS inc
	FROM staging_stores
	GROUP BY country;

	-- Check inconsistent data in store_type column

	SELECT store_type, COUNT(*) AS inc
	FROM staging_stores
	GROUP BY store_type;
	
	-- Finding: No data inconsistencies is found in this table
	
-- 3.2.4. Check inconsistent data in staging_calendar table

SELECT * FROM staging_calendar;

	-- Check inconsistent data in date column

	SELECT date, COUNT(*) AS inc
	FROM staging_calendar
	GROUP BY date;

	-- Check inconsistent data in year column

	SELECT year, COUNT(*) AS inc
	FROM staging_calendar
	GROUP BY year
	ORDER BY year ASC;

	-- Check inconsistent data in month column

	SELECT month, COUNT(*) AS inc
	FROM staging_calendar
	GROUP BY month
	ORDER BY month ASC;

	-- Check inconsistent data in day column

	SELECT day, COUNT(*) AS inc
	FROM staging_calendar
	GROUP BY day
	ORDER BY day ASC;

	-- Check inconsistent data in week column

	SELECT week, COUNT(*) AS inc
	FROM staging_calendar
	GROUP BY week
	ORDER BY week ASC;

	-- Check inconsistent data in day_of_week column

	SELECT day_of_week, COUNT(*) AS inc
	FROM staging_calendar
	GROUP BY day_of_week
	ORDER BY day_of_week ASC;
	
	-- Finding: No data inconsistencies were found in this table. 	

-- 3.2.5. Check inconsistent data in staging_sales table	

SELECT * FROM staging_sales;

	-- Check inconsistent data in order_id

	SELECT order_id, COUNT(*) AS inc
	FROM staging_sales
	GROUP BY order_id
	ORDER BY order_id;

	-- Check inconsistent data in order_date

	SELECT order_date, COUNT(*) AS inc
	FROM staging_sales
	GROUP BY order_date
	ORDER BY order_date ASC;

	-- Check inconsistent data in product_id

	SELECT product_id, COUNT(*) AS inc
	FROM staging_sales
	GROUP BY product_id
	ORDER BY product_id ASC;

	-- Check inconsistent data in store_id

	SELECT store_id, COUNT(*) AS inc
	FROM staging_sales
	GROUP BY store_id
	ORDER BY store_id;

	-- Check inconsistent data in customer_id

	SELECT customer_id, COUNT(*) AS inc
	FROM staging_sales
	GROUP BY customer_id
	ORDER BY customer_id;

	-- Check inconsistent data in quantity

	SELECT quantity, COUNT(*) AS inc
	FROM staging_sales
	GROUP BY quantity
	ORDER BY quantity ASC;

	-- Check inconsistent data in unit_price

	SELECT unit_price, COUNT(*) AS inc
	FROM staging_sales
	GROUP BY unit_price
	ORDER BY unit_price ASC;

	-- Check inconsistent data in discount

	SELECT discount, COUNT(*) AS inc
	FROM staging_sales
	GROUP BY discount
	ORDER BY discount ASC;

	-- Check inconsistent data in revenue

	SELECT revenue, COUNT(*) AS inc
	FROM staging_sales
	GROUP BY revenue
	ORDER BY revenue ASC;

	-- Check inconsistent data in cost

	SELECT cost, COUNT(*) AS inc
	FROM staging_sales
	GROUP BY cost
	ORDER BY cost ASC;

	-- Check inconsistent data in profit

	SELECT profit, COUNT(*) AS inc
	FROM staging_sales
	GROUP BY profit
	ORDER BY profit ASC;
	
-- 3.3. Check for logical issues
	
-- 3.3.1. Check join_date in staging_customer vs product_date in staging_sales
-- Note: join_date cannot come after order_date
		
SELECT * FROM staging_customers;

SELECT * FROM staging_sales LIMIT 100;

SELECT order_id, join_date, order_date
FROM staging_customers sc 
JOIN staging_sales ss
ON sc.customer_id = ss.customer_id
WHERE sc.join_date > ss.order_date;
	
-- Finding: Found potential logical inconsistencies where order_date occurs before join_date.
-- Customers cannot make transactions before their registration date


-- Initial investigation indicates that join_date does not represent:
--   1. The customer's first transaction date.
--   2. The date the customer joined the loyalty program.


-- This scenario is flagged as a potential data quality issue because,
-- under the common business assumption, a customer should not make a
-- transaction before their registration date.
-- The business definition of join_date remains ambiguous.
-- Error Logging: See 4.6


-- 3.3.2. Check the relationship between product_name column and category column in staging_products table
-- Note: The category is supposed to represent the 1st word of the product_name

SELECT * FROM staging_products;

SELECT 
	SUBSTRING_INDEX(product_name, " ", 1) AS correct_category,
	category AS false_category
FROM staging_products 
WHERE  SUBSTRING_INDEX(product_name, " ", 1) != category;

-- Finding: Found logical inconsistencies where category column doesn't match with the 1st word of the product_name column
-- Error Logging: See 4.2
-- Data Cleaning: See 5.1

-- 3.3.3. Check the relationship between product_name column and cocoa_percent column in staging_products table
-- Note: The cocoa_percent is supposed to represent the 3rd word of the product_name

SELECT * FROM staging_products;

SELECT 
	REPLACE(SUBSTRING_INDEX(product_name, " ", -1), "%", " ") AS correct_cocoa_percent,
	cocoa_percent AS false_cocoa_percent
FROM staging_products
WHERE REPLACE(SUBSTRING_INDEX(product_name, " ", -1), "%", " ") != cocoa_percent;

-- Finding: No logical inconsistencies where found in this relationship

-- 3.3.4. Check the relationship between city and country in staging_stores
-- Note: The city is supposed to match with its country

SELECT DISTINCT city FROM staging_stores;

SELECT DISTINCT country FROM staging_stores;

SELECT * FROM staging_stores;

SELECT store_id, city, country FROM staging_stores
WHERE country !=
	CASE
		WHEN city = "New York" THEN "USA"
		WHEN city IN ("Melbourne", "Sydney") THEN "Australia"
		WHEN city = "London" THEN "UK"
		WHEN city = "Berlin" THEN "Germany"
		WHEN city = "Paris" THEN "France"
		WHEN city = "Toronto" THEN "Canada"
	END;

-- Finding: Found logical inconsistencies where city column doesn't match with country column
-- Error Logging: See 4.3
-- Data Cleaning: See 5.2

-- 3.3.5. Check the relationship between date and year in staging_calendar

SELECT * FROM staging_calendar;

SELECT YEAR(date) AS extracted_year, year 
FROM staging_calendar 
WHERE YEAR(date) != year;

-- Finding: No logical inconsistencies where found in this relationship

-- 3.3.6. Check the relationship between date and month in staging_calendar

SELECT * FROM staging_calendar;

SELECT MONTH(date) AS extracted_month, month 
FROM staging_calendar 
WHERE MONTH(date) != month;

-- Finding: No logical inconsistencies where found in this relationship

-- 3.3.7. Check the relationship between date and day in staging_calendar

SELECT * FROM staging_calendar;

SELECT DAY(date) AS extracted_month, day 
FROM staging_calendar
WHERE DAY(date) = day;

-- Finding: No logical inconsistencies where found in this relationship

-- 3.3.8. Check the relationship between date and week in staging_calendar

SELECT * FROM staging_calendar;

SELECT week, WEEK(date, 1) AS extracted_week
FROM staging_calendar
WHERE WEEK(date, 1) != week;


-- Finding: source data does not start the week on Monday. A Monday-start format is preferred for standard business logic.
-- Error Logging: See 4.3
-- Data Cleaning: See 5.3

-- 3.3.9. Check the relationship between date and day_of_week in staging_calendar

SELECT * FROM staging_calendar;

SELECT day_of_week, (WEEKDAY(date) + 1)  AS extracted_dow
FROM staging_calendar
WHERE day_of_week != (WEEKDAY(date) + 1);

-- Finding: Source data does not start the week on Monday. day_of_week column uses a 0–6 index (Sunday/Monday as 0). For better readability and alignment with standard business logic, 
-- a 1–7 indexing format is preferred
-- Error Logging: See 4.5
-- Data Cleaning: See 5.4
	
-- 3.3.10. Check the relationship between quantity, unit_price, discount and revenue
-- Note: revenue = (unit_price * quantity) * (1 - discount)

SELECT * FROM staging_sales;

SELECT 
	revenue, 
	ROUND((unit_price * quantity) * (1 - discount), 2) AS revcalc_check 
FROM staging_sales
WHERE 
	ROUND(revenue, 2) != ROUND((unit_price * quantity) * (1 - discount), 2);

-- Finding: Some records showed a minor discrepancy of only 0.01 across the rounding functions (ROUND, CEIL, FLOOR) compared to the source revenue
-- I decided not to adjust the calculations because the discrepancies are negligible and were likely caused by the cashier system's rounding process 
	
-- 3.3.11. Check the relationship between revenue, cost, and profit
-- Note: profit = revenue - cost

SELECT * FROM staging_sales;

SELECT profit, revenue - cost 
FROM staging_sales ss 
WHERE ROUND(profit, 2) != ROUND(revenue - cost, 2);

-- Finding: Some records showed a minor discrepancy of only 0.01 across the rounding functions (ROUND, CEIL, FLOOR) compared to the source profit
-- I decided not to adjust the calculations because the discrepancies are negligible and were likely caused by the cashier system's rounding process 

-- 3.4. Check for orphan data in staging_sales against dimension tables
-- Note: Ensure all foreign keys in staging_sales have matching records in their respective dimension tables.

SELECT * FROM staging_sales;

-- 3.4.1. Check for orphan data between customer_id in staging_sales and customer_id in staging_customers table

SELECT ss.customer_id  ,sc.customer_id 
FROM staging_sales ss 
LEFT JOIN staging_customers sc 
ON ss.customer_id = sc.customer_id 
WHERE sc.customer_id IS NULL
ORDER BY sc.customer_id;

-- Finding: No orphan data was found in this relationship

-- 3.4.2. Check for orphan data between product_id in staging_sales and product_id in staging_products table

SELECT ss.product_id ,sp.product_id 
FROM staging_sales ss 
LEFT JOIN staging_products sp
ON ss.product_id = sp.product_id
WHERE sp.product_id IS NULL
ORDER BY sp.product_id;

SELECT DISTINCT ss.product_id
FROM staging_sales ss 
LEFT JOIN staging_products sp
ON ss.product_id = sp.product_id
WHERE sp.product_id IS NULL;

-- Finding: There are 2 orphan product_id values in staging_sales that do not exist in staging_products.
-- Error Logging: See 4.7


-- 3.4.3. Check for orphan data between store_id in staging_sales and store_id in staging_stores table

SELECT ss.store_id, ss2.store_id 
FROM staging_sales ss 
LEFT JOIN staging_stores ss2
ON ss.store_id = ss2.store_id 
WHERE ss2.store_id IS NULL
ORDER BY ss2.store_id;

-- Finding: No orphan data was found in this relationship

-- 3.4.4. Check for orphan data between order_date in staging_sales and date in staging_calendar table

SELECT ss.order_date, sc.date
FROM staging_sales ss 
LEFT JOIN staging_calendar sc 
ON ss.order_date = sc.date
WHERE sc.date IS NULL
ORDER BY sc.date;

-- Finding: No orphan data was found in this relationship




-- FINDING SUMMARY --

-- A. Resolvable Records via Data Cleaning

	-- 1. Incorrect category values that do not match the first word of product_name in staging_products 
	-- (Source: 3.3.2 → Error Logging: 4.2 → Data Cleaning: 5.1)
	
	-- 2. Incorrect country values that do not match the corresponding city in staging_stores 
	-- (Source: 3.3.4 → Error Logging: 4.3 → Data Cleaning: 5.2)
	
	-- 3. Week values in staging_calendar that do not follow the Monday-start convention. 
	-- (Source: 3.3.8 → Error Logging: 4.4 → Data Cleaning: 5.3)
	
	-- 4. day_of_week values in staging_calendar that do not follow the Monday-first 1–7 convention.
	-- (Source: 3.3.9 → Error Logging: 4.5 → Data Cleaning: 5.4)

-- B. Irresolvable Records via Data Cleaning

	-- 1. Transactions where order_date occurs before join_date.
	-- (Source: 3.3.1 → Error Logging: 4.6)
	
	-- 2. Orphan product_id values in staging_sales that do not exist in staging_products.
	-- (Source: 3.4.2 → Error Logging: 4.7)

-- C. Findings Accepted Without Cleaning

	-- 1. Multiple customer records share identical demographic profiles
	-- (age, gender, loyalty_member, and join_date), but cannot be confirmed
	-- as duplicate individuals due to the absence of identifying attributes.
	-- (Source: 3.1.1)

	-- 2. Multiple products share identical attributes
	-- (product_name, brand, cocoa_percent, and weight_g) but use different
	-- product_id values. These records are retained to avoid orphan data,
	-- since different stores may legitimately reference different product IDs.
	-- (Source: 3.1.2)

	-- 3. Minor rounding differences (±0.01) between calculated and source
	-- revenue values are accepted, as they are likely caused by the source
	-- system's rounding mechanism.
	-- (Source: 3.3.10)

	-- 4. Minor rounding differences (±0.01) between calculated and source
	-- profit values are accepted, as they are likely caused by the source
	-- system's rounding mechanism.
	-- (Source: 3.3.11)


-- D. No Issues Found

	-- No duplicates were found in:
	-- - staging_stores
	-- - staging_calendar
	-- - staging_sales

	-- No inconsistent values were found in:
	-- - staging_customers
	-- - staging_products
	-- - staging_stores
	-- - staging_calendar

	-- No logical issues were found in:
	-- - product_name ↔ cocoa_percent
	-- - date ↔ year
	-- - date ↔ month
	-- - date ↔ day

	-- No orphan data were found between staging_sales and:
	-- - staging_customers
	-- - staging_stores
	-- - staging_calendar


	
