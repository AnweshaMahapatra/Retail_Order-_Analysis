CREATE TABLE retail_orders (
    order_id VARCHAR(50) PRIMARY KEY,        -- Assuming 'Order Id' is unique
    order_date DATE,                         -- Date format for 'Order Date'
    ship_mode VARCHAR(50),
    segment VARCHAR(50),
    country VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_id VARCHAR(50),
    quantity INTEGER,                        -- Integer for quantity
    discount NUMERIC(5, 2),                  -- Percentage, e.g., 10.50%
    sale_price NUMERIC(10, 2),               -- Monetary value, e.g., 99999999.99
    profit NUMERIC(10, 2)                    -- Monetary value, e.g., 99999999.99
);


select * from retail_orders;
--find top 10 highest reveue generating products 
SELECT product_id, SUM(sale_price) AS sales
FROM retail_orders
GROUP BY product_id
ORDER BY sales DESC
LIMIT 10;

--find top 5 highest selling products in each region
WITH cte AS (
    SELECT region, product_id, SUM(sale_price) AS sales
    FROM retail_orders
    GROUP BY region, product_id
)
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY region ORDER BY sales DESC) AS rn
    FROM cte
) AS A
WHERE rn <= 5;






--find month over month growth comparison for 2022 and 2023 sales 
--eg : jan 2022 vs jan 2023
WITH cte AS (
    SELECT 
        EXTRACT(YEAR FROM order_date) AS order_year,
        EXTRACT(MONTH FROM order_date) AS order_month,
        SUM(sale_price) AS sales
    FROM 
        retail_orders
    GROUP BY 
        EXTRACT(YEAR FROM order_date),
        EXTRACT(MONTH FROM order_date)
)
SELECT 
    order_month,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM 
    cte 
GROUP BY 
    order_month
ORDER BY 
    order_month;

--for each category which month had highest sales 
WITH cte AS (
    SELECT 
        category,
        TO_CHAR(order_date, 'YYYYMM') AS order_year_month,
        SUM(sale_price) AS sales 
    FROM 
        retail_orders
    GROUP BY 
        category, TO_CHAR(order_date, 'YYYYMM')
)
SELECT * 
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) AS rn
    FROM cte
) AS a
WHERE rn = 1;


--which sub category had highest growth by profit in 2023 compare to 2022
WITH cte AS (
    SELECT 
        category,
        TO_CHAR(order_date, 'YYYYMM') AS order_year_month,
        SUM(sale_price) AS sales 
    FROM 
        retail_orders
    GROUP BY 
        category, TO_CHAR(order_date, 'YYYYMM')
)
SELECT * 
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) AS rn
    FROM cte
) AS a
WHERE a.rn = 1;  -- Ensure to reference the alias correctly
