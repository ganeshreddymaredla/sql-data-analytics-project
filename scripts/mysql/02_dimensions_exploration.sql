USE DataWarehouseAnalytics;

-- Unique countries
SELECT DISTINCT country FROM dim_customers ORDER BY country;

-- Unique categories, subcategories, products
SELECT DISTINCT category, subcategory, product_name
FROM dim_products
ORDER BY category, subcategory, product_name;
