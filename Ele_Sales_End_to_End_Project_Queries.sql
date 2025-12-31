CREATE DATABASE electronics_sales_db;
USE electronics_sales_db;

CREATE TABLE sales (
    user_id INT,
    product_id VARCHAR(50),
    category VARCHAR(50),
    rating INT,
    sale_timestamp BIGINT
);

CREATE VIEW sales_with_date AS
SELECT *,
       FROM_UNIXTIME(sale_timestamp) AS sale_date
FROM sales;

-- Q1. Top 5 most sold products (SUBQUERY)
SELECT product_id, total_sales
FROM (
    SELECT product_id, COUNT(*) AS total_sales
    FROM sales
    GROUP BY product_id
) t
ORDER BY total_sales DESC
LIMIT 5;

-- Q2. Most sold category (GROUP BY)
SELECT category, COUNT(*) AS total_sales
FROM sales
GROUP BY category
ORDER BY total_sales DESC
LIMIT 1;

-- Q3. Average rating per category (CTE)
WITH category_avg AS (
    SELECT category, AVG(rating) AS avg_rating
    FROM sales
    GROUP BY category
)
SELECT * FROM category_avg
ORDER BY avg_rating DESC;

-- Q4. Users who purchased more than average purchases (SUBQUERY)
SELECT user_id, COUNT(*) AS total_orders
FROM sales
GROUP BY user_id
HAVING COUNT(*) > (
    SELECT AVG(order_count)
    FROM (
        SELECT COUNT(*) AS order_count
        FROM sales
        GROUP BY user_id
    ) t
);


-- Q5. Most sold product in each category (WINDOW FUNCTION)
SELECT category, product_id, total_sales
FROM (
    SELECT category,
           product_id,
           COUNT(*) AS total_sales,
           RANK() OVER (PARTITION BY category ORDER BY COUNT(*) DESC) AS rnk
    FROM sales
    GROUP BY category, product_id
) t
WHERE rnk = 1;


-- Q6. Year-wise total sales (CTE + Date)
WITH yearly_sales AS (
    SELECT YEAR(FROM_UNIXTIME(sale_timestamp)) AS year,
           COUNT(*) AS total_sales
    FROM sales
    GROUP BY year
)
SELECT * FROM yearly_sales
ORDER BY year;


-- Q7. Products with rating higher than category average (SUBQUERY)
SELECT s.product_id, s.category, s.rating
FROM sales s
WHERE s.rating > (
    SELECT AVG(rating)
    FROM sales
    WHERE category = s.category
);


-- Q8. Top 3 products by sales in each year (WINDOW FUNCTION)
SELECT year, product_id, total_sales
FROM (
    SELECT YEAR(FROM_UNIXTIME(sale_timestamp)) AS year,
           product_id,
           COUNT(*) AS total_sales,
           DENSE_RANK() OVER (
               PARTITION BY YEAR(FROM_UNIXTIME(sale_timestamp))
               ORDER BY COUNT(*) DESC
           ) AS rnk
    FROM sales
    GROUP BY year, product_id
) t
WHERE rnk <= 3;


-- Q9. Users who purchased from more than one category (HAVING)
SELECT user_id, COUNT(DISTINCT category) AS category_count
FROM sales
GROUP BY user_id
HAVING COUNT(DISTINCT category) > 1;


-- Q10. Category contribution percentage to total sales (CTE)
WITH total_sales AS (
    SELECT COUNT(*) AS total FROM sales
),
category_sales AS (
    SELECT category, COUNT(*) AS cat_sales
    FROM sales
    GROUP BY category
)
SELECT c.category,
       ROUND((c.cat_sales * 100.0 / t.total), 2) AS sales_percentage
FROM category_sales c
CROSS JOIN total_sales t
ORDER BY sales_percentage DESC;


