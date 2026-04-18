/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - Consolidate key product metrics and behaviors into a single view.

Highlights:
    1. Core fields: product name, category, subcategory, cost.
    2. Segments products by revenue: High-Performer, Mid-Range, Low-Performer.
    3. Aggregated metrics per product:
       - total orders, total sales, total quantity, total customers, lifespan
    4. KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue

NOTE: This creates a VIEW — run once, then query it like a table:
      SELECT * FROM gold.report_products;
===============================================================================
*/

IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS

WITH base_query AS (
    -- Core columns from fact and dimension tables
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
),

product_aggregations AS (
    -- Summarize metrics at the product level
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date))               AS lifespan,
        MAX(order_date)                                                  AS last_sale_date,
        COUNT(DISTINCT order_number)                                     AS total_orders,
        COUNT(DISTINCT customer_key)                                     AS total_customers,
        SUM(sales_amount)                                                AS total_sales,
        SUM(quantity)                                                    AS total_quantity,
        ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
    FROM base_query
    GROUP BY product_key, product_name, category, subcategory, cost
)

SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    DATEDIFF(MONTH, last_sale_date, GETDATE())  AS recency_in_months,

    -- Revenue-based product segmentation
    CASE
        WHEN total_sales > 50000  THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,

    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,

    -- Average Order Revenue (AOR)
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,

    -- Average Monthly Revenue
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue

FROM product_aggregations;
GO
