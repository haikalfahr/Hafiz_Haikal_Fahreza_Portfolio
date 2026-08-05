-- 1. Create cafe_reports Database
CREATE DATABASE cafe_reports;

-- 2. Use messy_cafe Database
USE cafe_reports;

-- 3. Import the File: dirty_cafe_sales.csv and rename it into raw_data
-- Note: I imported my file through GUI

ALTER TABLE dirty_cafe_sales
RENAME TO raw_data;

-- 4. Brief exploration on raw data
DESC raw_data;

SELECT * FROM raw_data;

SELECT COUNT(*) AS total_records
FROM raw_data;