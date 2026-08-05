-- 1. Create staging_table 

CREATE TABLE staging_data LIKE raw_data;

ALTER TABLE staging_data
    RENAME COLUMN `Price Per Unit` TO price_per_unit;

INSERT staging_data
SELECT * FROM raw_data;
 
-- 2. Standardize Column Names

	-- 2.1. Inspect Current Column Names
	
	DESC staging_data;
	
		-- Finding: 5 columns were identified using spaces and title case 
		-- instead of the project's standard snake_case format.
	
	-- 2.2. Change the troubled column names to snake_case
	
	ALTER TABLE staging_data
		RENAME COLUMN `Transaction ID` TO transaction_id,
		RENAME COLUMN `Price Per Unit` TO price_per_unit,
		RENAME COLUMN `Total Spent` TO total_spent,
		RENAME COLUMN `Payment Method` TO payment_method,
		RENAME COLUMN `Transaction Date` TO transaction_date;

-- 3. Check for Duplicates

SELECT transaction_id, COUNT(*) AS duplicate
FROM staging_data
GROUP BY transaction_id
HAVING duplicate > 1 ;

-- Finding: No duplicates were found in this table

-- 4. Standardize Data

	-- 4.1. Check formatting inconsistencies
	
		-- 4.1.1. Check formating in transaction id column
		SELECT DISTINCT transaction_id
		FROM staging_data;
		
		SELECT transaction_id
		FROM staging_data
		WHERE transaction_id NOT REGEXP '^TXN_[0-9]+$';
	
		-- 4.1.2. Check formatting in Item column
		SELECT DISTINCT item FROM staging_data;
		
		-- 4.1.3. Check formatting in Quantity column
		SELECT DISTINCT quantity FROM staging_data;
		
		-- 4.1.4. Check formatting in PricePerUnit column
		SELECT DISTINCT price_per_unit FROM staging_data;
		
		-- 4.1.5. Check formatting in TotalSpent column
		SELECT DISTINCT total_spent FROM staging_data;
		
		-- 4.1.6. Check formatting in PaymentMethod column
		SELECT DISTINCT payment_method FROM staging_data;
		
		-- 4.1.7. Check formatting in Location column
		SELECT DISTINCT location FROM staging_data;
		
		-- 4.1.8. Check formatting in TransactionDate column
		SELECT DISTINCT transaction_date FROM staging_data;

-- Finding: No formatting inconsistencies were found.
-- However, several records contain blank, UNKNOWN, or ERROR values, except in the transaction_id column.
	
-- 4.2. Replace blank, UNKNOWN, and ERROR as NULL

UPDATE staging_data 
SET
	transaction_id = CASE WHEN transaction_id IN ('', 'UNKNOWN', 'ERROR') THEN NULL ELSE transaction_id END,
	item = CASE WHEN item IN ('', 'UNKNOWN', 'ERROR') THEN NULL ELSE item END,
	quantity = CASE WHEN quantity IN ('', 'UNKNOWN', 'ERROR') THEN NULL ELSE quantity END,
	price_per_unit = CASE WHEN price_per_unit IN ('', 'UNKNOWN', 'ERROR') THEN NULL ELSE price_per_unit END,
	total_spent = CASE WHEN total_spent IN ('', 'UNKNOWN', 'ERROR') THEN NULL ELSE total_spent END,
	payment_method = CASE WHEN payment_method IN ('', 'UNKNOWN', 'ERROR') THEN NULL ELSE payment_method END,
	location = CASE WHEN location IN ('', 'UNKNOWN', 'ERROR') THEN NULL ELSE location END,
	transaction_date = CASE WHEN transaction_date IN ('', 'UNKNOWN', 'ERROR') THEN NULL ELSE transaction_date END;

-- 5. Change Data Type

ALTER TABLE staging_data 
	MODIFY transaction_id VARCHAR(20),
	MODIFY item VARCHAR(50),
	MODIFY quantity SMALLINT UNSIGNED,
	MODIFY price_per_unit DECIMAL(10,2),
	MODIFY total_spent DECIMAL(10,2),
	MODIFY payment_method VARCHAR(20),
	MODIFY location VARCHAR(20),
	MODIFY transaction_date DATE;

DESC staging_data;

-- 6. Create invalid_data Table
-- This table will store records that cannot be repopulated

CREATE TABLE invalid_data
LIKE staging_data;

DESC invalid_data;

-- 7. Repopulate several records

-- 7.1. transaction_id column

SELECT 
	transaction_id,
	COUNT(*) AS how_many
FROM staging_data	
WHERE transaction_id IS NULL
GROUP BY transaction_id;

-- Finding: No invalid records were found in this column

-- 7.2. price_per_unit column

SELECT
	price_per_unit,
	COUNT(*) AS how_many
FROM staging_data
WHERE price_per_unit IS NULL
GROUP BY price_per_unit;

-- Finding: 533 invalid records were found in this column

	-- 7.2.1. Repopulate price_per_unit based on its item

		-- Investigate the relationship between price_per_unit and item.

		SELECT
			item,
			price_per_unit
		FROM staging_data
		WHERE
			item IS NOT NULL
			AND price_per_unit IS NOT null	
		GROUP BY item, price_per_unit	
		ORDER BY price_per_unit;
		
			-- Finding: The relationship was identified. Each item has a unique price_per_unit,
			-- except for Smoothie and Sandwich, which share the same price_per_unit of 4
			-- and Cake and Juice, which share the same price_per_unit of 3

		-- Repopulate

		UPDATE staging_data
		SET price_per_unit = CASE item
			WHEN 'Cookie' THEN 1
			WHEN 'Tea' THEN 1.5
			WHEN 'Coffee' THEN 2
			WHEN 'Cake' THEN 3
			WHEN 'Juice' THEN 3
			WHEN 'Smoothie' THEN 4
			WHEN 'Sandwich' THEN 4
			WHEN 'Salad' THEN 5
			END
		WHERE price_per_unit IS NULL;

	-- 7.2.2. Repopulate price_per_unit based on its quantity and total_spent
		-- price_per_unit = total_spent / quantity.
	
		UPDATE staging_data
		SET price_per_unit = (total_spent/quantity)
		WHERE price_per_unit IS NULL;


	-- 7.2.3. Check the remaining invalid records

		SELECT * FROM staging_data
		WHERE price_per_unit IS NULL;

		-- Finding: 6 invalid records remain and could not be repopulated.

	-- 7.2.4. Migrate the remaining invalid price_per_unit records to invalid_data table

		INSERT invalid_data
		SELECT * FROM staging_data
		WHERE price_per_unit IS NULL;
	
		DELETE FROM staging_data
		WHERE price_per_unit IS NULL;


	-- 7.2.5 Final verification on price_per_unit

		SELECT * FROM staging_data
		WHERE price_per_unit IS NULL;

-- 7.3. Clean the item column
	
SELECT
	item,
	COUNT(*) AS how_many
FROM staging_data
WHERE item IS NULL
GROUP BY item;

-- Finding: 936 invalid records were still found in this column

	-- 7.3.1. Repopulate item based on its price_per_unit

		-- Investigate the relationship between price_per_unit and item (same as the investigation on 7.2.1.)
	
		SELECT
			item,
			price_per_unit
		FROM staging_data
		WHERE
			item IS NOT NULL
			AND price_per_unit IS NOT null
		GROUP BY item, price_per_unit
		ORDER BY price_per_unit;

		-- Finding: Each item has a unique price_per_unit,
		-- except for Smoothie and Sandwich, which share the same price_per_unit of 4,
		-- and Cake and Juice, which share the same price_per_unit of 3.
		-- In conclusion, invalid item records with price_per_unit values of 3 and 4 cannot be repopulated
		-- due to ambiguity in determining the correct item for those prices.

		-- Items that can be repopulated vs cannot be repopulated

		SELECT
			item,
			price_per_unit,
			CASE
				WHEN COUNT(*) OVER (PARTITION BY price_per_unit) > 1 THEN "Cannot be Repopulated"
				ELSE "Can be Repopulated"
			END AS status
			FROM staging_data
			WHERE item IS NOT NULL
			AND price_per_unit IS NOT NULL
			GROUP BY item, price_per_unit
			ORDER BY price_per_unit;

		-- Repopulate

			UPDATE staging_data
			SET item = CASE price_per_unit
				WHEN 1 THEN 'Cookie'
				WHEN 1.5 THEN 'Tea'
				WHEN 2 THEN 'Coffee'
				WHEN 5 THEN 'Salad'
			END
			WHERE item IS NULL
			AND price_per_unit IN (1, 1.5, 2, 5);

	-- 7.3.2. Check the remaining invalid records
	
		SELECT * FROM staging_data
		WHERE item IS NULL;
	
		SELECT count(*) FROM staging_data
		WHERE item IS NULL;

		-- Finding: 474 invalid records remain and could not be repopulated.
	
	-- 7.3.3. Migrate the remaining invalid price_per_unit records to invalid_data table

		INSERT invalid_data
		SELECT * FROM staging_data
		WHERE item IS NULL;
	
		DELETE FROM staging_data
		WHERE item IS NULL;
	
	-- 7.3.4. Final verification on item column
	
		SELECT * FROM staging_data
		WHERE item IS NULL;

-- 7.4. Clean the quantity column
		
SELECT
	quantity,
	COUNT(*) AS how_many
FROM staging_data
WHERE quantity IS NULL
GROUP BY quantity;

-- Finding: 452 invalid records were still found in this column

	-- 7.4.1. Repopulate quantity based on its total_spent and price_per_unit
		-- quantity = total_spent / quantity.

		UPDATE staging_data
		SET quantity = (total_spent/price_per_unit)
		WHERE quantity IS NULL;

	-- 7.4.2. Check the remaining invalid records
	
		SELECT * FROM staging_data
		WHERE quantity IS NULL;
	
		SELECT count(*) FROM staging_data
		WHERE quantity IS NULL;

		-- Finding: 20 invalid records remain and could not be repopulated.
		
	-- 7.4.3. Migrate the remaining invalid records to invalid_data table

		INSERT invalid_data
		SELECT * FROM staging_data
		WHERE quantity IS NULL;
	
		DELETE FROM staging_data
		WHERE quantity IS NULL;
	
	-- 7.4.4. Final verification on price_per_unit
	
		SELECT * FROM staging_data
		WHERE quantity IS NULL;
		
-- 7.5. Clean the total_spent column

SELECT
	total_spent,
	COUNT(*) AS how_many
FROM staging_data
WHERE total_spent IS NULL
GROUP BY total_spent;

-- Finding: 457 invalid records were still found in this column

	-- 7.5.1. Repopulate total_spent based on its quantity and price_per_unit
		-- total_spent = quantity * price_per_unit

		UPDATE staging_data
		SET total_spent = quantity * price_per_unit 
		WHERE total_spent IS NULL;

	-- 7.5.2. Check the remaining invalid records
	
		SELECT * FROM staging_data
		WHERE total_spent IS NULL;
	
		SELECT count(*) FROM staging_data
		WHERE total_spent IS NULL;

		-- Finding: No invalid records remain
	
-- 7.6. Clean the payment_method column

SELECT
	payment_method,
	COUNT(*) AS how_many
FROM staging_data
WHERE payment_method IS NULL
GROUP BY payment_method;

	-- Finding: 3024 invalid records were still found in this column	
	-- Since no reliable reference data is available to determine the correct payment_method,
	-- these records could not be repopulated and were migrated to the invalid_data table.

	-- 7.6.1. Migrate invalid records to invalid_data table
	
		INSERT invalid_data
		SELECT * FROM staging_data
		WHERE payment_method IS NULL;
		
		DELETE FROM staging_data
		WHERE payment_method IS NULL;
	
	-- 7.6.2. Final verification on payment_method
	
		SELECT * FROM staging_data
		WHERE payment_method IS NULL;

-- 7.7 Clean the location column

SELECT
	location,
	COUNT(*) AS how_many
FROM staging_data
WHERE location IS NULL
GROUP BY location;

-- Finding: 2533 invalid records were still found in this column.
-- Since no reliable reference data is available to determine the correct location,
-- these records could not be repopulated and were migrated to the invalid_data table.

	-- 7.7.1. Migrate invalid location records to invalid_data table
	
	INSERT INTO invalid_data
	SELECT * FROM staging_data
	WHERE location IS NULL;
	
	DELETE FROM staging_data
	WHERE location IS NULL;
	
	-- 7.7.2. Final verification on location
	
	SELECT *
	FROM staging_data
	WHERE location IS NULL;
	
-- 7.8. Clean the transaction_date column

SELECT
	transaction_date,
	COUNT(*) AS how_many
FROM staging_data
WHERE transaction_date IS NULL
GROUP BY transaction_date;

-- Finding: 172 invalid records were still found in this column.
-- Since no reliable reference data is available to determine the correct transaction_date,
-- these records could not be repopulated and were migrated to the invalid_data table.

	-- 7.8.1. Migrate invalid transaction_date records to invalid_data table
	
	INSERT INTO invalid_data
	SELECT * FROM staging_data
	WHERE transaction_date IS NULL;
	
	DELETE FROM staging_data
	WHERE transaction_date IS NULL;
	
	-- 7.8.2. Final verification on transaction_date
	
	SELECT *
	FROM staging_data
	WHERE transaction_date IS NULL;
	
-- 8. Create Clean Table
	
CREATE TABLE clean_data
LIKE staging_data;

INSERT INTO clean_data
SELECT * FROM staging_data;

SELECT * FROM clean_data;