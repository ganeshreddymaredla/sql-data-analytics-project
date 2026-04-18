USE DataWarehouseAnalytics;

-- Monthly sales trend
SELECT
    YEAR(order_date)             AS order_year,
    MONTH(order_date)            AS order_month,
    SUM(sales_amount)            AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity)                AS total_quantity
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY order_year, order_month;

-- Monthly trend with formatted label
SELECT
    DATE_FORMAT(order_date, '%Y-%b')  AS order_month,
    SUM(sales_amount)                 AS total_sales,
    COUNT(DISTINCT customer_key)      AS total_customers,
    SUM(quantity)                     AS total_quantity
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_FORMAT(order_date, '%Y-%b'), DATE_FORMAT(order_date, '%Y%m')
ORDER BY DATE_FORMAT(order_date, '%Y%m');
