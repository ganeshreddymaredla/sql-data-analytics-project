/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - Calculate top-level aggregated metrics for a quick business overview.

SQL Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/

-- Total sales revenue
SELECT SUM(sales_amount) AS total_sales FROM gold.fact_sales;

-- Total items sold
SELECT SUM(quantity) AS total_quantity FROM gold.fact_sales;

-- Average selling price
SELECT AVG(price) AS avg_price FROM gold.fact_sales;

-- Total number of orders (with and without duplicates check)
SELECT COUNT(order_number)          AS total_orders_raw    FROM gold.fact_sales;
SELECT COUNT(DISTINCT order_number) AS total_orders_unique FROM gold.fact_sales;

-- Total number of products in catalog
SELECT COUNT(product_name) AS total_products FROM gold.dim_products;

-- Total customers in the system
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers;

-- Customers who have actually placed an order
SELECT COUNT(DISTINCT customer_key) AS active_customers FROM gold.fact_sales;

-- Combined key metrics report
SELECT 'Total Sales'      AS measure_name, SUM(sales_amount)            AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity',                   SUM(quantity)                                 FROM gold.fact_sales
UNION ALL
SELECT 'Average Price',                    AVG(price)                                    FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders',                     COUNT(DISTINCT order_number)                  FROM gold.fact_sales
UNION ALL
SELECT 'Total Products',                   COUNT(DISTINCT product_name)                  FROM gold.dim_products
UNION ALL
SELECT 'Total Customers',                  COUNT(customer_key)                           FROM gold.dim_customers;
