-- ============================================================
-- FULL PROJECT RUN — DataWarehouseAnalytics
-- Run this file in MySQL Workbench:
--   1. Open this file (File > Open SQL Script)
--   2. Click the lightning bolt ⚡ to run all
-- ============================================================


-- ===========================================================
-- 00: CREATE DATABASE, TABLES & LOAD DATA
-- ===========================================================

DROP DATABASE IF EXISTS DataWarehouseAnalytics;
CREATE DATABASE DataWarehouseAnalytics;
USE DataWarehouseAnalytics;

CREATE TABLE dim_customers (
    customer_key     INT,
    customer_id      INT,
    customer_number  VARCHAR(50),
    first_name       VARCHAR(50),
    last_name        VARCHAR(50),
    country          VARCHAR(50),
    marital_status   VARCHAR(50),
    gender           VARCHAR(50),
    birthdate        DATE,
    create_date      DATE
);

CREATE TABLE dim_products (
    product_key     INT,
    product_id      INT,
    product_number  VARCHAR(50),
    product_name    VARCHAR(100),
    category_id     VARCHAR(50),
    category        VARCHAR(50),
    subcategory     VARCHAR(50),
    maintenance     VARCHAR(50),
    cost            INT,
    product_line    VARCHAR(50),
    start_date      DATE
);

CREATE TABLE fact_sales (
    order_number   VARCHAR(50),
    product_key    INT,
    customer_key   INT,
    order_date     DATE,
    shipping_date  DATE,
    due_date       DATE,
    sales_amount   INT,
    quantity       TINYINT,
    price          INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_customers.csv'
INTO TABLE dim_customers
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(customer_key, customer_id, customer_number, first_name, last_name,
 country, marital_status, gender, @birthdate, @create_date)
SET birthdate = NULLIF(@birthdate,''), create_date = NULLIF(@create_date,'');

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_products.csv'
INTO TABLE dim_products
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_key, product_id, product_number, product_name, category_id,
 category, subcategory, maintenance, cost, product_line, @start_date)
SET start_date = NULLIF(@start_date,'');

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fact_sales.csv'
INTO TABLE fact_sales
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_number, product_key, customer_key, @order_date, @shipping_date,
 @due_date, sales_amount, quantity, price)
SET order_date = NULLIF(@order_date,''),
    shipping_date = NULLIF(@shipping_date,''),
    due_date = NULLIF(@due_date,'');

-- Verify row counts
SELECT 'dim_customers' AS tbl, COUNT(*) AS total_rows FROM dim_customers
UNION ALL SELECT 'dim_products', COUNT(*) FROM dim_products
UNION ALL SELECT 'fact_sales',   COUNT(*) FROM fact_sales;


-- ===========================================================
-- 01: DATABASE EXPLORATION
-- ===========================================================

SELECT TABLE_NAME, TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'DataWarehouseAnalytics';

SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'DataWarehouseAnalytics' AND TABLE_NAME = 'dim_customers';


-- ===========================================================
-- 02: DIMENSIONS EXPLORATION
-- ===========================================================

SELECT DISTINCT country FROM dim_customers ORDER BY country;

SELECT DISTINCT category, subcategory, product_name
FROM dim_products ORDER BY category, subcategory, product_name;


-- ===========================================================
-- 03: DATE RANGE EXPLORATION
-- ===========================================================

SELECT
    MIN(order_date)                                           AS first_order_date,
    MAX(order_date)                                           AS last_order_date,
    TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date))    AS order_range_months
FROM fact_sales;

SELECT
    MIN(birthdate)                                            AS oldest_birthdate,
    TIMESTAMPDIFF(YEAR, MIN(birthdate), CURDATE())            AS oldest_age,
    MAX(birthdate)                                            AS youngest_birthdate,
    TIMESTAMPDIFF(YEAR, MAX(birthdate), CURDATE())            AS youngest_age
FROM dim_customers;


-- ===========================================================
-- 04: KEY METRICS
-- ===========================================================

SELECT 'Total Sales'       AS measure_name, SUM(sales_amount)            AS measure_value FROM fact_sales
UNION ALL SELECT 'Total Quantity',           SUM(quantity)                                 FROM fact_sales
UNION ALL SELECT 'Average Price',            AVG(price)                                    FROM fact_sales
UNION ALL SELECT 'Total Orders',             COUNT(DISTINCT order_number)                  FROM fact_sales
UNION ALL SELECT 'Total Products',           COUNT(DISTINCT product_name)                  FROM dim_products
UNION ALL SELECT 'Total Customers',          COUNT(customer_key)                           FROM dim_customers
UNION ALL SELECT 'Active Customers',         COUNT(DISTINCT customer_key)                  FROM fact_sales;


-- ===========================================================
-- 05: MAGNITUDE ANALYSIS
-- ===========================================================

SELECT country, COUNT(customer_key) AS total_customers
FROM dim_customers GROUP BY country ORDER BY total_customers DESC;

SELECT gender, COUNT(customer_key) AS total_customers
FROM dim_customers GROUP BY gender ORDER BY total_customers DESC;

SELECT category, COUNT(product_key) AS total_products
FROM dim_products GROUP BY category ORDER BY total_products DESC;

SELECT category, AVG(cost) AS avg_cost
FROM dim_products GROUP BY category ORDER BY avg_cost DESC;

SELECT p.category, SUM(f.sales_amount) AS total_revenue
FROM fact_sales f LEFT JOIN dim_products p ON p.product_key = f.product_key
GROUP BY p.category ORDER BY total_revenue DESC;

SELECT c.country, SUM(f.quantity) AS total_sold_items
FROM fact_sales f LEFT JOIN dim_customers c ON c.customer_key = f.customer_key
GROUP BY c.country ORDER BY total_sold_items DESC;


-- ===========================================================
-- 06: RANKING ANALYSIS
-- ===========================================================

-- Top 5 products by revenue
SELECT p.product_name, SUM(f.sales_amount) AS total_revenue
FROM fact_sales f LEFT JOIN dim_products p ON p.product_key = f.product_key
GROUP BY p.product_name ORDER BY total_revenue DESC LIMIT 5;

-- Bottom 5 products by revenue
SELECT p.product_name, SUM(f.sales_amount) AS total_revenue
FROM fact_sales f LEFT JOIN dim_products p ON p.product_key = f.product_key
GROUP BY p.product_name ORDER BY total_revenue ASC LIMIT 5;

-- Top 10 customers by revenue
SELECT c.customer_key, c.first_name, c.last_name, SUM(f.sales_amount) AS total_revenue
FROM fact_sales f LEFT JOIN dim_customers c ON c.customer_key = f.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_revenue DESC LIMIT 10;

-- Top 5 using RANK() window function
SELECT * FROM (
    SELECT p.product_name, SUM(f.sales_amount) AS total_revenue,
           RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
    FROM fact_sales f LEFT JOIN dim_products p ON p.product_key = f.product_key
    GROUP BY p.product_name
) ranked WHERE rank_products <= 5;


-- ===========================================================
-- 07: CHANGE OVER TIME
-- ===========================================================

SELECT
    YEAR(order_date) AS order_year, MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM fact_sales WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY order_year, order_month;

SELECT
    DATE_FORMAT(order_date, '%Y-%b') AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers
FROM fact_sales WHERE order_date IS NOT NULL
GROUP BY DATE_FORMAT(order_date, '%Y-%b'), DATE_FORMAT(order_date, '%Y%m')
ORDER BY DATE_FORMAT(order_date, '%Y%m');


-- ===========================================================
-- 08: CUMULATIVE ANALYSIS
-- ===========================================================

SELECT order_year, total_sales,
    SUM(total_sales) OVER (ORDER BY order_year) AS running_total_sales,
    AVG(avg_price)   OVER (ORDER BY order_year) AS moving_avg_price
FROM (
    SELECT YEAR(order_date) AS order_year,
           SUM(sales_amount) AS total_sales,
           AVG(price) AS avg_price
    FROM fact_sales WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date)
) yearly;


-- ===========================================================
-- 09: YEAR-OVER-YEAR PERFORMANCE
-- ===========================================================

WITH yearly_product_sales AS (
    SELECT YEAR(f.order_date) AS order_year, p.product_name,
           SUM(f.sales_amount) AS current_sales
    FROM fact_sales f LEFT JOIN dim_products p ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY YEAR(f.order_date), p.product_name
)
SELECT order_year, product_name, current_sales,
    AVG(current_sales) OVER (PARTITION BY product_name)                                        AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name)                        AS diff_avg,
    CASE WHEN current_sales > AVG(current_sales) OVER (PARTITION BY product_name) THEN 'Above Avg'
         WHEN current_sales < AVG(current_sales) OVER (PARTITION BY product_name) THEN 'Below Avg'
         ELSE 'Avg' END AS avg_change,
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year)                    AS py_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year)    AS diff_py,
    CASE WHEN current_sales > LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) THEN 'Increase'
         WHEN current_sales < LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) THEN 'Decrease'
         ELSE 'No Change' END AS py_change
FROM yearly_product_sales ORDER BY product_name, order_year;


-- ===========================================================
-- 10: DATA SEGMENTATION
-- ===========================================================

-- Product cost segments
WITH product_segments AS (
    SELECT product_key, product_name, cost,
        CASE WHEN cost < 100 THEN 'Below 100'
             WHEN cost BETWEEN 100 AND 500 THEN '100-500'
             WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
             ELSE 'Above 1000' END AS cost_range
    FROM dim_products
)
SELECT cost_range, COUNT(product_key) AS total_products
FROM product_segments GROUP BY cost_range ORDER BY total_products DESC;

-- Customer VIP / Regular / New segments
WITH customer_spending AS (
    SELECT c.customer_key, SUM(f.sales_amount) AS total_spending,
           TIMESTAMPDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan
    FROM fact_sales f LEFT JOIN dim_customers c ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT customer_segment, COUNT(customer_key) AS total_customers FROM (
    SELECT customer_key,
        CASE WHEN lifespan >= 12 AND total_spending > 5000  THEN 'VIP'
             WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
             ELSE 'New' END AS customer_segment
    FROM customer_spending
) seg GROUP BY customer_segment ORDER BY total_customers DESC;


-- ===========================================================
-- 11: PART-TO-WHOLE ANALYSIS
-- ===========================================================

WITH category_sales AS (
    SELECT p.category, SUM(f.sales_amount) AS total_sales
    FROM fact_sales f LEFT JOIN dim_products p ON p.product_key = f.product_key
    GROUP BY p.category
)
SELECT category, total_sales,
    SUM(total_sales) OVER ()                                          AS overall_sales,
    ROUND((total_sales / SUM(total_sales) OVER ()) * 100, 2)          AS pct_of_total
FROM category_sales ORDER BY total_sales DESC;


-- ===========================================================
-- 12: CUSTOMER REPORT VIEW
-- ===========================================================

DROP VIEW IF EXISTS report_customers;

CREATE VIEW report_customers AS
WITH base_query AS (
    SELECT f.order_number, f.product_key, f.order_date, f.sales_amount, f.quantity,
           c.customer_key, c.customer_number,
           CONCAT(c.first_name, ' ', c.last_name)         AS customer_name,
           TIMESTAMPDIFF(YEAR, c.birthdate, CURDATE())     AS age
    FROM fact_sales f LEFT JOIN dim_customers c ON c.customer_key = f.customer_key
    WHERE f.order_date IS NOT NULL
),
customer_aggregation AS (
    SELECT customer_key, customer_number, customer_name, age,
           COUNT(DISTINCT order_number)                                     AS total_orders,
           SUM(sales_amount)                                                AS total_sales,
           SUM(quantity)                                                    AS total_quantity,
           COUNT(DISTINCT product_key)                                      AS total_products,
           MAX(order_date)                                                  AS last_order_date,
           TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date))           AS lifespan
    FROM base_query
    GROUP BY customer_key, customer_number, customer_name, age
)
SELECT customer_key, customer_number, customer_name, age,
    CASE WHEN age < 20 THEN 'Under 20' WHEN age BETWEEN 20 AND 29 THEN '20-29'
         WHEN age BETWEEN 30 AND 39 THEN '30-39' WHEN age BETWEEN 40 AND 49 THEN '40-49'
         ELSE '50 and above' END AS age_group,
    CASE WHEN lifespan >= 12 AND total_sales > 5000  THEN 'VIP'
         WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
         ELSE 'New' END AS customer_segment,
    last_order_date,
    TIMESTAMPDIFF(MONTH, last_order_date, CURDATE())  AS recency,
    total_orders, total_sales, total_quantity, total_products, lifespan,
    CASE WHEN total_orders = 0 THEN 0 ELSE total_sales / total_orders END  AS avg_order_value,
    CASE WHEN lifespan = 0 THEN total_sales ELSE total_sales / lifespan END AS avg_monthly_spend
FROM customer_aggregation;

SELECT * FROM report_customers LIMIT 20;


-- ===========================================================
-- 13: PRODUCT REPORT VIEW
-- ===========================================================

DROP VIEW IF EXISTS report_products;

CREATE VIEW report_products AS
WITH base_query AS (
    SELECT f.order_number, f.order_date, f.customer_key, f.sales_amount, f.quantity,
           p.product_key, p.product_name, p.category, p.subcategory, p.cost
    FROM fact_sales f LEFT JOIN dim_products p ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
),
product_aggregations AS (
    SELECT product_key, product_name, category, subcategory, cost,
           TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date))                AS lifespan,
           MAX(order_date)                                                        AS last_sale_date,
           COUNT(DISTINCT order_number)                                           AS total_orders,
           COUNT(DISTINCT customer_key)                                           AS total_customers,
           SUM(sales_amount)                                                      AS total_sales,
           SUM(quantity)                                                          AS total_quantity,
           ROUND(AVG(sales_amount / NULLIF(quantity,0)), 1)                       AS avg_selling_price
    FROM base_query
    GROUP BY product_key, product_name, category, subcategory, cost
)
SELECT product_key, product_name, category, subcategory, cost, last_sale_date,
    TIMESTAMPDIFF(MONTH, last_sale_date, CURDATE())  AS recency_in_months,
    CASE WHEN total_sales > 50000  THEN 'High-Performer'
         WHEN total_sales >= 10000 THEN 'Mid-Range'
         ELSE 'Low-Performer' END AS product_segment,
    lifespan, total_orders, total_sales, total_quantity, total_customers,
    avg_selling_price,
    CASE WHEN total_orders = 0 THEN 0 ELSE total_sales / total_orders END   AS avg_order_revenue,
    CASE WHEN lifespan = 0 THEN total_sales ELSE total_sales / lifespan END AS avg_monthly_revenue
FROM product_aggregations;

SELECT * FROM report_products LIMIT 20;
