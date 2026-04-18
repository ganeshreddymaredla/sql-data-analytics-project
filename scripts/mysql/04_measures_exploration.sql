USE DataWarehouseAnalytics;

-- Key metrics combined report
SELECT 'Total Sales'      AS measure_name, SUM(sales_amount)            AS measure_value FROM fact_sales
UNION ALL
SELECT 'Total Quantity',                   SUM(quantity)                                 FROM fact_sales
UNION ALL
SELECT 'Average Price',                    AVG(price)                                    FROM fact_sales
UNION ALL
SELECT 'Total Orders',                     COUNT(DISTINCT order_number)                  FROM fact_sales
UNION ALL
SELECT 'Total Products',                   COUNT(DISTINCT product_name)                  FROM dim_products
UNION ALL
SELECT 'Total Customers',                  COUNT(customer_key)                           FROM dim_customers
UNION ALL
SELECT 'Active Customers',                 COUNT(DISTINCT customer_key)                  FROM fact_sales;
