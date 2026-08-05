-- 6.1. Create dim_customer

	-- 6.1.1. Create dim_customers like staging_customer
	
	SELECT * FROM staging_customers;
	
	CREATE TABLE dim_customers (
		customer_id VARCHAR(20) PRIMARY KEY, 
		age TINYINT UNSIGNED NOT NULL, 
		gender VARCHAR(20) NOT NULL,
		loyalty_member BOOLEAN NOT NULL,
		join_date DATE NOT NULL
	);
	
	DESC dim_customers;
	
	INSERT INTO dim_customers
	SELECT * FROM staging_customers;
	
	SELECT * FROM dim_customers;
	
	-- 6.1.2. Add age_group column into dim_customers
	
	ALTER TABLE dim_customers
	ADD COLUMN age_group VARCHAR(20) DEFAULT 'unidentified' NOT NULL AFTER age;
	
	UPDATE dim_customers
	SET age_group = 
	    CASE 
	        WHEN age < 18 THEN '<18'
	        WHEN age BETWEEN 18 AND 24 THEN '18-24'
	        WHEN age BETWEEN 25 AND 34 THEN '25-34'
	        WHEN age BETWEEN 35 AND 44 THEN '35-44'
	        WHEN age BETWEEN 45 AND 54 THEN '45-54'
	        WHEN age BETWEEN 55 AND 64 THEN '55-64'
	        WHEN age >= 65 THEN '65+'
	    END;
	
	SELECT *, CASE 
		WHEN loyalty_member = TRUE THEN "Loyalty Member"
		ELSE "Non-loyalty Member"
	END AS loyaty_type
	FROM dim_customers;
	SELECT * FROM dim_customers;
	
	SELECT * FROM dim_customers;

-- 6.2. Create dim_products

	-- 6.2.1. Create dim_products like staging_products
	
	SELECT * FROM staging_products;
	
	CREATE TABLE dim_products (
		product_id VARCHAR(20) PRIMARY KEY,
		product_name VARCHAR(50) NOT NULL,
		brand VARCHAR (20) NOT NULL,
		category VARCHAR (20) NOT NULL,
		cocoa_percent TINYINT NOT NULL,
		weight_g SMALLINT NOT NULL
	);
	
	DESC dim_products;
	
	INSERT INTO dim_products
	SELECT * FROM staging_products;
	
	-- 6.2.2. Insert Orphan Product into dim_product
	
	INSERT INTO dim_products (product_id, product_name, brand, category, cocoa_percent, weight_g)
	VALUES ("Orphan Product", "Unknown", "Unknown", "Unknown", -1, -1);
	
	SELECT * FROM dim_products;

-- 6.3. Create dim_stores

SELECT * FROM staging_stores;

CREATE TABLE dim_stores (
	store_id VARCHAR(20) PRIMARY KEY,
	store_name VARCHAR(20) NOT NULL UNIQUE,
	city VARCHAR(50) NOT NULL,
	country VARCHAR(50) NOT NULL,
	store_type VARCHAR(20) NOT NULL
);

DESC dim_stores;

INSERT INTO dim_stores
SELECT * FROM staging_stores;

SELECT * FROM staging_stores;

-- 6.4. Create dim_calendar

	-- 6.4.1. Create dim_calendar like staging_calendar
	
	SELECT * FROM staging_calendar;
	
	CREATE TABLE dim_calendar (
		date DATE PRIMARY KEY,
		year YEAR NOT NULL,
		month TINYINT UNSIGNED NOT NULL,
		day TINYINT UNSIGNED NOT NULL,
		week TINYINT UNSIGNED NOT NULL, 
		day_of_week TINYINT UNSIGNED NOT NULL
	);
	
	DESC dim_calendar;
	
	INSERT INTO dim_calendar
	SELECT * FROM staging_calendar;
	
	SELECT * FROM dim_calendar;
	
	-- 6.4.2. Add month_name to dim_calendar
	
	ALTER TABLE dim_calendar
	ADD COLUMN month_name VARCHAR(10) NOT NULL;
	
	UPDATE dim_calendar
	SET month_name = MONTHNAME(date);

-- 6.5. Create fact_sales

	-- 6.5.1. Import staging_sales to fact_sales
	
	SELECT * FROM staging_sales;
	
	CREATE TABLE fact_sales (
		order_id VARCHAR(20) PRIMARY KEY,
		order_date DATE NOT NULL,  
		product_id VARCHAR(20) NOT NULL, 
		store_id VARCHAR(20) NOT NULL, 
		customer_id VARCHAR(20) NOT NULL, 
		quantity SMALLINT NOT NULL, 
		unit_price DECIMAL(10,2) NOT NULL, 
		discount DECIMAL(10,2) NOT NULL, 
		revenue DECIMAL(10,2) NOT NULL, 
		cost DECIMAL(10,2) NOT NULL, 
		profit DECIMAL(10,2) NOT NULL, 
		CONSTRAINT fk_fact_sales_calendar FOREIGN KEY (order_date) REFERENCES dim_calendar (date),
	    CONSTRAINT fk_fact_sales_product  FOREIGN KEY (product_id) REFERENCES dim_products (product_id),
	    CONSTRAINT fk_fact_sales_store    FOREIGN KEY (store_id) REFERENCES dim_stores (store_id),
	    CONSTRAINT fk_fact_sales_customer FOREIGN KEY (customer_id) REFERENCES dim_customers (customer_id)
	);
	
	INSERT INTO fact_sales (
	    order_id, 
	    order_date, 
	    product_id,
	    store_id, 
	    customer_id, 
	    quantity, 
	    unit_price, 
	    discount, 
	    revenue, 
	    cost, 
	    profit
	)
	SELECT 
	    s.order_id, 
	    s.order_date, 
	    COALESCE(p.product_id, "Orphan Product") AS product_id, 
	    s.store_id, 
	    s.customer_id, 
	    s.quantity, 
	    s.unit_price, 
	    s.discount, 
	    s.revenue, 
	    s.cost, 
	    s.profit
	FROM staging_sales s
	LEFT JOIN dim_products p ON s.product_id = p.product_id;
	
	SELECT 
		DISTINCT el.error_code, 
		ec.error_description  
	FROM staging_error_log el
	JOIN staging_error_catalog ec 
	ON el.error_code = ec.error_code 
	WHERE error_status =  "UNSOLVED";
	
	-- 6.5.2. Add is_orphan_product
	
	ALTER TABLE fact_sales
	ADD COLUMN is_orphan_product BOOLEAN NOT NULL DEFAULT FALSE;
	
	SELECT * FROM fact_sales;
	
	UPDATE fact_sales fs 
	JOIN staging_error_log el
	ON fs.order_id = el.record_id 
	SET is_orphan_product = TRUE
	WHERE el.error_code = 'ERR_ORP_PRODUCT';
	
	SELECT * FROM fact_sales WHERE is_orphan_product = TRUE;
	
	-- 6.6.3. Add is_invalid_order_date
	
	ALTER TABLE fact_sales
	ADD COLUMN is_invalid_order_date BOOLEAN NOT NULL DEFAULT FALSE;
	
	SELECT * FROM fact_sales;
	
	UPDATE fact_sales fs 
	JOIN staging_error_log el
	ON fs.order_id = el.record_id 
	SET is_invalid_order_date = TRUE
	WHERE el.error_code = 'ERR_ORD_DATE';
	
	SELECT * FROM fact_sales
	WHERE is_invalid_order_date = TRUE;









