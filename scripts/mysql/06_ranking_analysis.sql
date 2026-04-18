USE DataWarehouseAnalytics;

-- Top 5 products by revenue
SELECT p.product_name, SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
LEFT JOIN dim_products p ON p.product_key = f.product_key
GROUP BY p.product_name ORDER BY total_revenue DESC LIMIT 5;

-- Top 5 using window function RANK()
SELECT * FROM (
    SELECT
        p.product_name,
        SUM(f.sales_amount) AS total_revenue,
        RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
    FROM fact_sales f
    LEFT JOIN dim_products p ON p.product_key = f.product_key
    GROUP BY p.product_name
) AS ranked_products
WHERE rank_products <= 5;

-- Bottom 5 worst-performing products
SELECT p.product_name, SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
LEFT JOIN dim_products p ON p.product_key = f.product_key
GROUP BY p.product_name ORDER BY total_revenue ASC LIMIT 5;

-- Top 10 customers by revenue
SELECT c.customer_key, c.first_name, c.last_name, SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
LEFT JOIN dim_customers c ON c.customer_key = f.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_revenue DESC LIMIT 10;

-- Bottom 3 customers by order count
SELECT c.customer_key, c.first_name, c.last_name, COUNT(DISTINCT f.order_number) AS total_orders
FROM fact_sales f
LEFT JOIN dim_customers c ON c.customer_key = f.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_orders ASC LIMIT 3;
