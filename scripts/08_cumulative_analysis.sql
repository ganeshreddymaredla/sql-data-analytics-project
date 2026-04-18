/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - Calculate running totals and moving averages to track growth over time.

SQL Used:
    - SUM() OVER(), AVG() OVER() (window functions)
===============================================================================
*/

-- Yearly running total of sales and moving average price
SELECT
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date)  AS running_total_sales,
    AVG(avg_price)   OVER (ORDER BY order_date)  AS moving_average_price
FROM (
    SELECT
        DATETRUNC(year, order_date)  AS order_date,
        SUM(sales_amount)            AS total_sales,
        AVG(price)                   AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(year, order_date)
) AS yearly_sales;
