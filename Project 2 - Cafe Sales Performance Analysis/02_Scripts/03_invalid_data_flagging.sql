-- 1. add invalid flag column for each column in invalid_data table

ALTER TABLE invalid_data 
ADD COLUMN invalid_item BOOLEAN NOT NULL DEFAULT FALSE ,
ADD COLUMN invalid_quantity BOOLEAN NOT NULL DEFAULT FALSE ,
ADD COLUMN invalid_price_per_unit BOOLEAN NOT NULL DEFAULT FALSE,
ADD COLUMN invalid_total_spent BOOLEAN NOT NULL DEFAULT FALSE,
ADD COLUMN invalid_payment_method BOOLEAN NOT NULL DEFAULT FALSE,
ADD COLUMN invalid_location BOOLEAN NOT NULL DEFAULT FALSE,
ADD COLUMN invalid_transaction_date BOOLEAN NOT NULL DEFAULT FALSE;


-- 2. Populate invalid flags

UPDATE invalid_data
SET
    invalid_item = item IS NULL,
    invalid_quantity = quantity IS NULL,
    invalid_price_per_unit = price_per_unit IS NULL,
    invalid_total_spent = total_spent IS NULL,
    invalid_payment_method = payment_method IS NULL,
    invalid_location = location IS NULL,
    invalid_transaction_date = transaction_date IS NULL;

SELECT * FROM invalid_data;

-- 3. Complete the quantiative fields

	-- 3.1. Fill quantity

		UPDATE invalid_data
		SET quantity = total_spent / price_per_unit
		WHERE quantity IS NULL
		  AND total_spent IS NOT NULL
		  AND price_per_unit IS NOT NULL;

	-- 3.2. Fill price_per_unit
		
		UPDATE invalid_data
		SET price_per_unit = total_spent / quantity
		WHERE price_per_unit IS NULL
		  AND total_spent IS NOT NULL
		  AND quantity IS NOT NULL;

	-- 3.3. Fill total_spent
		
		UPDATE invalid_data
		SET total_spent = quantity * price_per_unit
		WHERE total_spent IS NULL
		  AND quantity IS NOT NULL
		  AND price_per_unit IS NOT NULL;
		



