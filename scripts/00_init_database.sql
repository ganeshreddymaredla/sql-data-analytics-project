/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    Creates the 'DataWarehouseAnalytics' database, the 'gold' schema,
    all three tables, and bulk loads data from CSV files.

WARNING:
    This script drops and recreates the database if it already exists.
    All existing data will be lost. Make sure you have backups.

HOW TO USE:
    1. Update the three file paths in the BULK INSERT statements below
       to match the location of your cloned repo on your machine.
    2. Run this script first before any other script.
=============================================================
*/

USE master;
GO

-- Drop and recreate the database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseAnalytics')
BEGIN
    ALTER DATABASE DataWarehouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouseAnalytics;
END;
GO

CREATE DATABASE DataWarehouseAnalytics;
GO

USE DataWarehouseAnalytics;
GO

-- Create schema
CREATE SCHEMA gold;
GO

-- ============================================================
-- Create Tables
-- ============================================================

CREATE TABLE gold.dim_customers (
    customer_key     INT,
    customer_id      INT,
    customer_number  NVARCHAR(50),
    first_name       NVARCHAR(50),
    last_name        NVARCHAR(50),
    country          NVARCHAR(50),
    marital_status   NVARCHAR(50),
    gender           NVARCHAR(50),
    birthdate        DATE,
    create_date      DATE
);
GO

CREATE TABLE gold.dim_products (
    product_key     INT,
    product_id      INT,
    product_number  NVARCHAR(50),
    product_name    NVARCHAR(50),
    category_id     NVARCHAR(50),
    category        NVARCHAR(50),
    subcategory     NVARCHAR(50),
    maintenance     NVARCHAR(50),
    cost            INT,
    product_line    NVARCHAR(50),
    start_date      DATE
);
GO

CREATE TABLE gold.fact_sales (
    order_number   NVARCHAR(50),
    product_key    INT,
    customer_key   INT,
    order_date     DATE,
    shipping_date  DATE,
    due_date       DATE,
    sales_amount   INT,
    quantity       TINYINT,
    price          INT
);
GO

-- ============================================================
-- Load Data
-- UPDATE THESE PATHS to match your local machine
-- ============================================================

TRUNCATE TABLE gold.dim_customers;
GO

BULK INSERT gold.dim_customers
FROM 'C:\Projects\sql-analytics-guide\datasets\flat-files\dim_customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
GO

TRUNCATE TABLE gold.dim_products;
GO

BULK INSERT gold.dim_products
FROM 'C:\Projects\sql-analytics-guide\datasets\flat-files\dim_products.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
GO

TRUNCATE TABLE gold.fact_sales;
GO

BULK INSERT gold.fact_sales
FROM 'C:\Projects\sql-analytics-guide\datasets\flat-files\fact_sales.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
GO
