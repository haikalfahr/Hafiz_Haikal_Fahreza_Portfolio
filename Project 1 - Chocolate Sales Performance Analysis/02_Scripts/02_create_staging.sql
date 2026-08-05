-- zz. create staging_table

-- 2.1. create staging_customers

CREATE TABLE staging_customers
LIKE raw_customers;

INSERT staging_customers
SELECT * FROM raw_customers;

-- 2.2. create staging_products

CREATE TABLE staging_products
LIKE raw_products;


INSERT staging_products
SELECT * FROM raw_products;

-- 2.3. create staging_stores

CREATE TABLE staging_stores
LIKE raw_stores;

INSERT staging_stores
SELECT * FROM raw_stores;

-- 2.4. create staging_calendar

CREATE TABLE staging_calendar
LIKE raw_calendar;

INSERT staging_calendar
SELECT * FROM raw_calendar;

DESC staging_calendar;

-- 2.5. create staging_sales

CREATE TABLE staging_sales
LIKE raw_sales;

INSERT staging_sales
SELECT * FROM raw_sales;