/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - Explore the unique values inside dimension tables.

SQL Used:
    - DISTINCT, ORDER BY
===============================================================================
*/

-- Unique countries customers come from
SELECT DISTINCT 
    country 
FROM gold.dim_customers
ORDER BY country;

-- Unique categories, subcategories, and products
SELECT DISTINCT 
    category, 
    subcategory, 
    product_name 
FROM gold.dim_products
ORDER BY category, subcategory, product_name;
