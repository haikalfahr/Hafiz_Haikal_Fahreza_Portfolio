-- 5.1. Correct category values based on the first word of product_name in the staging_products table
-- Source: 3.3.2
-- Error Log: 4.2

-- 5.1.1. Update the category column using the first word of product_name

UPDATE staging_products
SET category = SUBSTRING_INDEX(product_name, " ", 1)
WHERE SUBSTRING_INDEX(product_name, " ", 1) != category;

-- 5.1.2. Update error status

UPDATE staging_error_log
SET 
	error_status = "FIXED",
	resolved_at = CURRENT_TIMESTAMP
WHERE 
	error_code = "ERR_CAT_MISMATCH" AND
	error_status = "UNSOLVED";

SELECT * FROM staging_error_log WHERE error_code = "ERR_CAT_MISMATCH";

-- 5.1.3.  Verify the results

SELECT 
	SUBSTRING_INDEX(product_name, " ", 1) AS correct_category,
	category AS false_category
FROM staging_products 
WHERE  SUBSTRING_INDEX(product_name, " ", 1) != category;

SELECT product_name, category 
FROM staging_products;


-- 5.2. Correct country values based on the city values in the staging_stores table
-- Source: 3.3.4
-- Error Log: 4.3

-- 5.2.1. Update the country column based on the city values

UPDATE staging_stores
SET country = 
	CASE
		WHEN city = "New York" THEN "USA"
		WHEN city IN ("Melbourne", "Sydney") THEN "Australia"
		WHEN city = "London" THEN "UK"
		WHEN city = "Berlin" THEN "Germany"
		WHEN city = "Paris" THEN "France"
		WHEN city = "Toronto" THEN "Canada"
	END
WHERE country !=
	CASE
		WHEN city = "New York" THEN "USA"
		WHEN city IN ("Melbourne", "Sydney") THEN "Australia"
		WHEN city = "London" THEN "UK"
		WHEN city = "Berlin" THEN "Germany"
		WHEN city = "Paris" THEN "France"
		WHEN city = "Toronto" THEN "Canada"
	END;

-- 5.2.2. Update error status

UPDATE staging_error_log
SET 
	error_status = "FIXED",
	resolved_at = CURRENT_TIMESTAMP
WHERE 
	error_code = "ERR_COUNTRY_CITY_MISMATCH" AND
	error_status = "UNSOLVED";

SELECT * FROM staging_error_log WHERE error_code = "ERR_COUNTRY_CITY_MISMATCH";

-- 5.2.3 Verify the results

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

SELECT city, country FROM staging_stores;


-- 5.3. Standardize week values using the Monday-start convention in the staging_calendar table
-- Source: 3.3.8
-- Error Log: 4.4

-- 5.3.1. Update the week column using the Monday-start convention

UPDATE staging_calendar
SET week = WEEK(date, 1)
WHERE WEEK(date, 1) != week;

-- 5.3.2. Update error status

SELECT DISTINCT error_code FROM staging_error_log;

UPDATE staging_error_log
SET 
	error_status = "FIXED",
	resolved_at = CURRENT_TIMESTAMP
WHERE 
	error_code = "ERR_WEEK_CONVENTION" AND
	error_status = "UNSOLVED";

SELECT * FROM staging_error_log WHERE error_code = "ERR_WEEK_CONVENTION";

-- 5.3.3. Verify the results

SELECT week, WEEK(date, 1) AS extracted_week
FROM staging_calendar
WHERE WEEK(date, 1) != week;

SELECT date, week FROM staging_calendar;

-- 5.4. Standardize day_of_week values using the Monday-first (1–7) convention in the staging_calendar table
-- Source: 3.3.9
-- Error Log: 4.5

-- 5.4.1. Update the day_of_week column using the Monday-first 1–7 convention

UPDATE staging_calendar
SET day_of_week = WEEKDAY(date) + 1
WHERE day_of_week != WEEKDAY(date) + 1;

-- 5.4.2. Update error status

SELECT DISTINCT error_code FROM staging_error_log;

UPDATE staging_error_log
SET 
	error_status = "FIXED",
	resolved_at = CURRENT_TIMESTAMP
WHERE 
	error_code = "ERR_DOW_INDEX_INVALID" AND
	error_status = "UNSOLVED";

SELECT * FROM staging_error_log WHERE error_code = "ERR_DOW_INDEX_INVALID";

-- 5.4.3 Verify the results

SELECT day_of_week, (WEEKDAY(date) + 1)  AS extracted_dow
FROM staging_calendar
WHERE day_of_week != (WEEKDAY(date) + 1);


-- 5.5. Verify the remaining issues

SELECT * FROM staging_error_catalog sec;

SELECT 
	DISTINCT el.error_code, 
	ec.error_description,
	el.table_name
FROM staging_error_log el
JOIN staging_error_catalog ec 
ON el.error_code = ec.error_code 
WHERE error_status =  'UNSOLVED';





























