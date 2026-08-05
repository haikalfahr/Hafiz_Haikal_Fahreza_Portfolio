-- 1. Add new data into dim_product, dim_category, dim_payment, and dim_channel to contain unidentified records

	-- 1.1. Add new data into dim_product table
	
		INSERT INTO dim_product (product_id, category_id, item, price)
		VALUES (-1, -1, "Unidentified 3$", 3), (-2, -1, "Unidentified 4$", 4);
		
		SELECT * FROM dim_product;
		
	-- 1.2. Add new data into dim_category
		
		INSERT INTO dim_category (category_id, category)
		VALUES (-1, "Unidentified");
		
		SELECT * FROM dim_category dc;
		
	-- 1.3 add new daya into dim_payment
	
		INSERT INTO dim_payment (payment_id, payment_method)
		VALUES (-1, "Unidentified");
		
		SELECT * FROM dim_payment;
	
	-- 1.4 Add new data into dim_channel
	
		INSERT INTO dim_channel (channel_id, channel)
		VALUES (-1, "Unidentified");
		
		SELECT * FROM dim_channel;

-- 2. Add essential flag columns to fact_sales
		
ALTER TABLE fact_sales 
ADD COLUMN invalid_product BOOLEAN NOT NULL DEFAULT FALSE,
ADD COLUMN invalid_payment_method BOOLEAN NOT NULL DEFAULT FALSE,
ADD COLUMN invalid_channel BOOLEAN NOT NULL DEFAULT FALSE,
ADD COLUMN invalid_transaction_date BOOLEAN NOT NULL DEFAULT FALSE;

SELECT * FROM fact_sales;

-- 3. Create quantifiable_invalid_data table 

CREATE TABLE quantifiable_invalid_data
LIKE invalid_data;

INSERT INTO quantifiable_invalid_data
SELECT * FROM invalid_data
WHERE quantity IS NOT NULL
AND price_per_unit IS NOT NULL;

SELECT * FROM quantifiable_invalid_data

UPDATE quantifiable_invalid_data
SET item = CASE 
	WHEN price_per_unit = 3 THEN "Unidentified 3$"
	WHEN price_per_unit = 4 THEN "Unidentified 4$"
	END
WHERE item IS NULL;

UPDATE quantifiable_invalid_data
SET payment_method = "Unidentified"
WHERE payment_method IS NULL;

UPDATE quantifiable_invalid_data
SET location = "Unidentified"
WHERE location IS NULL;

-- 4. Add the invalid records with complete quantitative fields to fact_sales 

INSERT INTO fact_sales (
	transaction_id, 
	product_id,
	payment_id,
	channel_id,
	transaction_date,
	quantity,
	invalid_product,
	invalid_payment_method,
	invalid_channel,
	invalid_transaction_date
	)
SELECT 
	qid.transaction_id, 
	CASE
		WHEN qid.item = "Unidentified 3$" THEN  -1
		WHEN qid.item = "Unidentified 4$" THEN  -2
		ELSE dp.product_id
	END AS product_id, 
	COALESCE(dp2.payment_id, -1), 
	COALESCE(dc.channel_id, -1), 
	qid.transaction_date, 
	qid.quantity,
	qid.invalid_item,
	qid.invalid_payment_method,
	qid.invalid_location,
	qid.invalid_transaction_date
FROM quantifiable_invalid_data qid
LEFT JOIN dim_product dp ON
	qid.item = dp.item
LEFT JOIN dim_payment dp2 ON
	qid.payment_method = dp2.payment_method
LEFT  JOIN dim_channel dc ON
	qid.location = dc.channel;

SELECT * FROM fact_sales
WHERE invalid_channel = 0;

SELECT count(*) FROM quantifiable_invalid_data qid WHERE qid.transaction_date IS NULL;































