-- 4.1 Error Logging Infrastructure

-- 4.1.1 Create staging_error_catalog
CREATE TABLE staging_error_catalog (
	error_code VARCHAR(50) PRIMARY KEY,
	error_name VARCHAR(50) NOT NULL UNIQUE,
	error_description VARCHAR(100) NOT NULL
);

-- 4.1.2 Create staging_error_log
CREATE TABLE staging_error_log (
	error_log_id INT PRIMARY KEY AUTO_INCREMENT,
	table_name VARCHAR(50) NOT NULL,
	record_id VARCHAR(50) NOT NULL,
	error_code VARCHAR(50) NOT NULL,
	error_status VARCHAR(15) NOT NULL DEFAULT "UNSOLVED",
	detected_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	resolved_at DATETIME NULL,
	resolution_note VARCHAR(100) NULL,
	
	UNIQUE KEY uq_error_log (table_name, record_id, error_code),
	CONSTRAINT fk_log_error_code FOREIGN KEY (error_code) REFERENCES staging_error_catalog(error_code)
);

-- 4.2. Log Incorrect Category Values in staging_products 

-- 4.2.1. Add ERR_CAT_MISMATCH to staging_error_catalog

INSERT INTO staging_error_catalog (error_code, error_name, error_description)
VALUES ("ERR_CAT_MISMATCH", "Category Mismatch", "Category value does not match the first word of product_name in staging_products");

SELECT * FROM staging_error_catalog;

-- 4.2.2.  Insert invalid records into staging_error_log

INSERT INTO staging_error_log (table_name, record_id, error_code)
SELECT "staging_products", product_id, "ERR_CAT_MISMATCH"
FROM staging_products 
WHERE  SUBSTRING_INDEX(product_name, " ", 1) != category;

SELECT * FROM staging_error_log;

-- 4.3 Log Incorrect Country Values in staging_stores

-- 4.3.1. Add ERR_COUNTRY_CITY_MISMATCH to staging_error_catalog

INSERT INTO staging_error_catalog (error_code, error_name, error_description)
VALUES ("ERR_COUNTRY_CITY_MISMATCH", "Country-City Mismatch", "Country value does not correspond to the mapped city in staging_stores");

SELECT * FROM staging_error_catalog;

-- 4.3.2.  Insert invalid records into staging_error_log
INSERT INTO staging_error_log (table_name, record_id, error_code)
SELECT "staging_stores", store_id, "ERR_COUNTRY_CITY_MISMATCH"
FROM staging_stores
WHERE country !=
	CASE
		WHEN city = "New York" THEN "USA"
		WHEN city IN ("Melbourne", "Sydney") THEN "Australia"
		WHEN city = "London" THEN "UK"
		WHEN city = "Berlin" THEN "Germany"
		WHEN city = "Paris" THEN "France"
		WHEN city = "Toronto" THEN "Canada"
	END;

SELECT * FROM staging_error_log WHERE error_code = "ERR_COUNTRY_CITY_MISMATCH";

-- 4.4 Log Week Values Not Following Monday-Start Convention in staging_calendar

-- 4.4.1. Add ERR_WEEK_CONVENTION to staging_error_catalog

INSERT INTO staging_error_catalog (error_code, error_name, error_description)
VALUES ("ERR_WEEK_CONVENTION", "Week Convention Violation", "Week values do not follow Monday-start convention in staging_calendar");

SELECT * FROM staging_error_catalog;

-- 4.4.2. Insert invalid records into staging_error_log

INSERT INTO staging_error_log (table_name, record_id, error_code)
SELECT "staging_calendar", date, "ERR_WEEK_CONVENTION"
FROM staging_calendar
WHERE WEEK(date, 1) != week;

SELECT * FROM staging_error_log WHERE error_code = "ERR_WEEK_CONVENTION";

-- 4.5. Log day_of_week Values Not Following Monday-First 1–7 Convention in staging_calendar

-- 4.5.1. Add ERR_DOW_INDEX_INVALID to staging_error_catalog

INSERT INTO staging_error_catalog (error_code, error_name, error_description)
VALUES ("ERR_DOW_INDEX_INVALID", "Day of Week Index Invalid", "day_of_week values do not follow Monday-first 1–7 convention in staging_calendar");

SELECT * FROM staging_error_catalog;

-- 4.5.2. Insert invalid records into staging_error_log

INSERT INTO staging_error_log (table_name, record_id, error_code)
SELECT "staging_calendar", date, "ERR_DOW_INDEX_INVALID"
FROM staging_calendar
WHERE day_of_week != (WEEKDAY(date) + 1);

SELECT * FROM staging_error_log WHERE error_code = "ERR_DOW_INDEX_INVALID";


-- 4.6. Log transactions in staging_sales where order_date occurs before join_date

-- 4.6.1. Add ERR_ORD_DATE to staging_error_catalog

INSERT INTO staging_error_catalog (error_code, error_name, error_description)
VALUES ("ERR_ORD_DATE", "Order Date Before Join Date", "order_date occurs before the customer's join_date.");

SELECT * FROM staging_error_catalog;

-- 4.6.2.  Insert invalid records into staging_error_log

INSERT INTO staging_error_log (table_name, record_id, error_code)
SELECT "staging_sales", order_id, "ERR_ORD_DATE"
	FROM staging_customers sc 
	JOIN staging_sales ss
	ON sc.customer_id = ss.customer_id
	WHERE sc.join_date > ss.order_date
	ORDER BY order_id;

SELECT * FROM staging_error_log WHERE error_code = "ERR_ORD_DATE";

-- 4.7. Log transactions in staging_sales where product_id do not exist in staging_products

-- 4.7.1. Add ERR_ORP_PRODUCT to staging_error_catalog

INSERT INTO staging_error_catalog (error_code, error_name, error_description)
VALUES ("ERR_ORP_PRODUCT", "Orphan Product ID", "product_id in staging_sales does not exist in staging_products.");

SELECT * FROM staging_error_catalog;

-- 4.7.2. Insert invalid records into staging_error_log

INSERT INTO staging_error_log (table_name, record_id, error_code)
SELECT "staging_sales", order_id, "ERR_ORP_PRODUCT"
FROM staging_sales ss 
LEFT JOIN staging_products sp
ON ss.product_id = sp.product_id
WHERE sp.product_id IS NULL
ORDER BY ss.order_id;

SELECT * FROM staging_error_log WHERE error_code = "ERR_ORP_PRODUCT";

SELECT * FROM staging_error_catalog;







