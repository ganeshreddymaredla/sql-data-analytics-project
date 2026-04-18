/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - Measure each category's percentage contribution to total revenue.

SQL Used:
    - SUM() OVER() for grand total
    - ROUND(), CAST() for percentage calculation
===============================================================================
*/

-- Category share of total revenue
WITH category_sales AS (
    SELECT
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
    GROUP BY p.category
)
SELECT
    category,
    total_sales,
    SUM(total_sales) OVER ()                                                  AS overall_sales,
    ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2)  AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;
