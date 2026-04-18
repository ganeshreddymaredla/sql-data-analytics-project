/*
===============================================================================
Date Range Exploration
===============================================================================
Purpose:
    - Understand the temporal boundaries of the data.

SQL Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/

-- First and last order date, and total duration in months
SELECT 
    MIN(order_date)                                    AS first_order_date,
    MAX(order_date)                                    AS last_order_date,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date))  AS order_range_months
FROM gold.fact_sales;

-- Youngest and oldest customer based on birthdate
SELECT
    MIN(birthdate)                                  AS oldest_birthdate,
    DATEDIFF(YEAR, MIN(birthdate), GETDATE())       AS oldest_age,
    MAX(birthdate)                                  AS youngest_birthdate,
    DATEDIFF(YEAR, MAX(birthdate), GETDATE())       AS youngest_age
FROM gold.dim_customers;
