-- 1.1. Create chocolate_company database
CREATE DATABASE chocolate_company;

-- 1.2. Use chocolate_company database
USE chocolate_company;

-- 1.3. mport the csv tables using GUI

-- 1.4. Rename all the imported tables as raw table
RENAME TABLE
    customers TO raw_customers,
    products TO raw_products,
    calendar TO raw_calendar,
    stores TO raw_stores,
    sales TO raw_sales;