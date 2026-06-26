-- Creating a Table based upon columns from final CSV created by Pandas.
CREATE Table amazon 
(brand VARCHAR, 
product_id VARCHAR, 
product_name VARCHAR,
category VARCHAR, 
subcategory VARCHAR,    
domain VARCHAR, 
discounted_price NUMERIC, 
actual_price NUMERIC, 
discount_percentage NUMERIC,
rating NUMERIC, 
rating_count NUMERIC, 
sales_proxy NUMERIC, 
rating_type VARCHAR, 
price_band VARCHAR);

-- Crosschecking Table after creating table and importing data.
SELECT * FROM amazon;


-- Pareto Analysis

--- Sales Proxy Focused:
-- Q1. Which categories account for 80% of the marketplace's assumed sales?

WITH category_sales AS (
    SELECT
        category,
        SUM(sales_proxy) AS total_sales
    FROM amazon
    GROUP BY category
), pareto as (SELECT
    category,
    total_sales, (total_sales * 100.0 / SUM(total_sales) OVER ()) AS share_total
    ,ROUND(100.0 *SUM(total_sales) OVER (ORDER BY total_sales DESC)/
    SUM(total_sales) OVER (),2) AS cumulative_pct
FROM category_sales)

SELECT * FROM pareto
WHERE cumulative_pct <= 80
   OR cumulative_pct = (
        SELECT MIN(cumulative_pct) FROM pareto WHERE cumulative_pct > 80)
ORDER BY total_sales DESC;

-- Q2. Which brands account for 80% of the assumed sales within each category?

WITH brand_sales AS (
    SELECT
        brand, category, 
        SUM(sales_proxy) AS total_sales
    FROM amazon
    GROUP BY brand, category),

pareto AS (SELECT
    brand, category,
    total_sales,
    ROUND(100.0 * SUM(total_sales) OVER (ORDER BY total_sales DESC)
     / SUM(total_sales) OVER (), 2) AS cumulative_pct
FROM brand_sales)

SELECT * FROM pareto
WHERE cumulative_pct <= 80
   OR cumulative_pct = (
        SELECT MIN(cumulative_pct) FROM pareto WHERE cumulative_pct > 80
      )
ORDER BY total_sales DESC;

-- Q3. Which products account for 80% of the marketplace's assumed sales?

WITH product_sales AS (
    SELECT
        product_name, category, 
        SUM(sales_proxy) AS total_sales
    FROM amazon
    GROUP BY product_name, category
), 

pareto as (SELECT
    product_name, category,
    total_sales,
    ROUND(
        100.0 *
        SUM(total_sales) OVER (
            ORDER BY total_sales DESC)
        /SUM(total_sales) OVER (), 2) AS cumulative_pct
FROM product_sales)

SELECT * FROM pareto
WHERE cumulative_pct <= 80
   OR cumulative_pct = (
        SELECT MIN(cumulative_pct) FROM pareto WHERE cumulative_pct > 80)
ORDER BY total_sales DESC;


--- Customer Engagement Focused:
-- Q4. Which categories account for 80% of total customer engagement (Rating Count)?

WITH category_engagement AS (
    SELECT
        category,
        SUM(rating_count) AS total_ratingcount
    FROM amazon
    GROUP BY category),

pareto as (SELECT
    category,
    total_ratingcount
    ,ROUND(
        100.0 *
        SUM(total_ratingcount) OVER (
            ORDER BY total_ratingcount DESC)
        /SUM(total_ratingcount) OVER (), 2) AS cumulative_pct
FROM category_engagement)


SELECT * FROM pareto
WHERE cumulative_pct <= 80
   OR cumulative_pct = (
        SELECT MIN(cumulative_pct) FROM pareto WHERE cumulative_pct > 80)
ORDER BY total_ratingcount DESC;

-- Q5. Which brands account for 80% of total customer engagement (Rating Count)?

WITH brand_engagement AS (
    SELECT
        brand,
        SUM(rating_count) AS total_ratingcount
    FROM amazon
    GROUP BY brand
), 
pareto AS (SELECT
    brand,
    total_ratingcount
    ,round(
        100.0 *
        SUM(total_ratingcount) OVER 
		(ORDER BY total_ratingcount DESC)/ SUM(total_ratingcount) OVER (),
		2) AS cumulative_pct
FROM brand_engagement)

SELECT * FROM pareto
WHERE cumulative_pct <= 80
   OR cumulative_pct = (
        SELECT MIN(cumulative_pct) FROM pareto WHERE cumulative_pct > 80)
ORDER BY total_ratingcount DESC;

-- Q6. Which products account for 80% of total customer engagement (Rating Count)?

SELECT
    product_id,
    product_name,
    rating_count,
    ROUND(
        100.0 *
        SUM(rating_count) OVER (ORDER BY rating_count DESC)
        / SUM(rating_count) OVER (),
        2) AS cumulative_pct 
		FROM amazon ORDER BY rating_count DESC;


-- Other Analysis:
-- Q1. What are the best product estimated sales wise from each category;

WITH product_cte as (SELECT brand, category, sales_proxy,
ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales_proxy DESC)as rn FROM amazon)

SELECT * FROM product_cte WHERE rn = 1
ORDER BY sales_proxy;

-- Q2. What are the best product rating wise from each category;

WITH max_ratings AS (
    SELECT
        category,
        MAX(rating) AS max_rating
    FROM amazon
    GROUP BY category
)
SELECT
    a.category,
    COUNT(*) AS top_rated_product_count
FROM amazon a
JOIN max_ratings m
    ON a.category = m.category
   AND a.rating = m.max_rating
GROUP BY a.category;



-- Q3. Which price bands generate the most revenue and engagement and where should assortment focus be?


SELECT 
    price_band,
    COUNT(product_id) AS product_count,
    ROUND(AVG(rating),2) AS avg_rating,
    ROUND(SUM(sales_proxy),2)/10000000000 AS total_revenue_in_bn,
    ROUND(AVG(discount_percentage),1) AS avg_discount
FROM amazon
GROUP BY price_band
ORDER BY total_revenue_in_bn DESC;


-- Q4. Which categories are dominated by a few brands vs. fragmented across many?"
SELECT category,
    COUNT(DISTINCT brand) AS total_brands,
    COUNT(DISTINCT product_id) AS total_products,
    ROUND(COUNT(DISTINCT product_id)::NUMERIC / 
          COUNT(DISTINCT brand), 1) AS products_per_brand,
    CASE 
        WHEN COUNT(DISTINCT brand) <= 10 THEN 'Concentrated'
        WHEN COUNT(DISTINCT brand) <= 50 THEN 'Moderate'
        ELSE 'Fragmented'
    END AS market_structure
FROM amazon
GROUP BY category
ORDER BY total_brands DESC;






