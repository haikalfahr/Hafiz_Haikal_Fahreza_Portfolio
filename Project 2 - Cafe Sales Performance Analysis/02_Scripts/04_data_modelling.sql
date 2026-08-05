-- 1. Create Dimension Table

-- 1.1. create dim_product

SELECT * FROM clean_data;

CREATE TABLE dim_product(
	product_id INT PRIMARY KEY AUTO_INCREMENT,
	item VARCHAR(50) UNIQUE NOT NULL,
	price DECIMAL(10,2)
);

INSERT INTO dim_product (item, price)
SELECT DISTINCT item, price_per_unit
FROM clean_data
ORDER BY item;

SELECT * FROM dim_product;

-- 1.2. create dim_payment

CREATE TABLE dim_payment (
	payment_id INT PRIMARY KEY AUTO_INCREMENT,
	payment_method VARCHAR(20) UNIQUE NOT NULL
);

INSERT INTO dim_payment (payment_method)
SELECT DISTINCT payment_method 
FROM clean_data
ORDER BY payment_method;

SELECT * FROM dim_payment;


-- 1.3. Create dim_channel
CREATE TABLE dim_channel (
	channel_id INT PRIMARY KEY AUTO_INCREMENT,
	channel VARCHAR(20) UNIQUE NOT NULL
);

INSERT INTO dim_channel (channel)
SELECT DISTINCT location 
FROM clean_data
ORDER BY location;

SELECT * FROM dim_channel;

-- 1.4. Create dim_calendar

CREATE TABLE dim_calendar AS
WITH RECURSIVE calendar_cte AS (
    SELECT
        MIN(transaction_date) AS calendar_date,
        MAX(transaction_date) AS max_date
    FROM clean_data

    UNION ALL

    SELECT
        DATE_ADD(calendar_date, INTERVAL 1 DAY),
        max_date
    FROM calendar_cte
    WHERE calendar_date < max_date
)
SELECT
    calendar_date,
    YEAR(calendar_date) AS calendar_year,
    QUARTER(calendar_date) AS calendar_quarter,
    MONTH(calendar_date) AS calendar_month,
    MONTHNAME(calendar_date) AS month_name,
    DAYNAME(calendar_date) day_name,
	(WEEKDAY(calendar_date) + 1) AS day_of_week,
	CASE
		WHEN (WEEKDAY(calendar_date) + 1) IN (6,7) THEN "Weekend"
		ELSE "Weekday"
	END AS is_weekend
FROM calendar_cte;

ALTER TABLE dim_calendar
ADD CONSTRAINT prkey_calendar
PRIMARY KEY(calendar_date);

SELECT * FROM dim_calendar;

-- 1.5. create dim_category

CREATE TABLE dim_category (
	category_id INT PRIMARY KEY AUTO_INCREMENT,
	category VARCHAR(20) UNIQUE NOT NULL
);

INSERT INTO dim_category (category)
VALUES ('Bakery'), ('Beverage'), ('Food');

SELECT * FROM dim_category;

-- Add category_id column to dim_product and assign category_id based on each item's category

ALTER TABLE dim_product 
ADD COLUMN category_id INT AFTER product_id;

UPDATE dim_product dp
SET dp.category_id = (
	SELECT category_id FROM dim_category
	WHERE category =
		CASE
			WHEN dp.item IN ('Cake', 'Cookie') THEN 'Bakery'
			WHEN dp.item IN ('Coffee', 'Smoothie', 'Juice', 'Tea') THEN 'Beverage'
			WHEN dp.item IN ('Sandwich', 'Salad') THEN 'Food'
		END
);

ALTER TABLE dim_product
 ADD FOREIGN KEY (category_id) REFERENCES dim_category (category_id);

SELECT * FROM dim_product;

-- 2. Create Fact Table: fact_sales
CREATE TABLE fact_sales (
	transaction_id VARCHAR(20) PRIMARY KEY,
	product_id INT NOT NULL,
	payment_id INT NOT NULL,
	channel_id INT NOT NULL,
	transaction_date DATE,
	quantity SMALLINT UNSIGNED NOT NULL,
	FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
	FOREIGN KEY (payment_id) REFERENCES dim_payment(payment_id),
	FOREIGN KEY (channel_id) REFERENCES dim_channel(channel_id),
	FOREIGN KEY (transaction_date) REFERENCES dim_calendar(calendar_date)
);


INSERT INTO fact_sales (transaction_id, product_id, payment_id, channel_id, transaction_date, quantity)
SELECT
	cd.transaction_id,
	dp.product_id,
	dp2.payment_id,
	dc.channel_id,
	cd.transaction_date,
	cd.quantity
FROM
	clean_data cd
LEFT JOIN dim_product dp ON
	cd.item = dp.item
LEFT JOIN dim_payment dp2 ON
	cd.payment_method = dp2.payment_method
LEFT JOIN dim_channel dc ON
	cd.location = dc.channel;

SELECT * FROM fact_sales;

