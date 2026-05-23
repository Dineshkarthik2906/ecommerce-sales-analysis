

USE olist_db;


SELECT 'olist_orders_dataset'               AS table_name, COUNT(*) AS row_count FROM olist_orders_dataset
UNION ALL
SELECT 'olist_order_items_dataset',          COUNT(*) FROM olist_order_items_dataset
UNION ALL
SELECT 'olist_order_payments_dataset',       COUNT(*) FROM olist_order_payments_dataset
UNION ALL
SELECT 'olist_order_reviews_dataset',        COUNT(*) FROM olist_order_reviews_dataset
UNION ALL
SELECT 'olist_customers_dataset',            COUNT(*) FROM olist_customers_dataset
UNION ALL
SELECT 'olist_products_dataset',             COUNT(*) FROM olist_products_dataset
UNION ALL
SELECT 'olist_sellers_dataset',              COUNT(*) FROM olist_sellers_dataset
UNION ALL
SELECT 'olist_geolocation_dataset',          COUNT(*) FROM olist_geolocation_dataset
UNION ALL
SELECT 'product_category_name_translation',  COUNT(*) FROM product_category_name_translation;


-- Total Revenue & Orders by Product Category
-- Business Question: Which product categories generate the most revenue?
-- Tables Used: order_items, products, category_translation
SELECT
    COALESCE(t.product_category_name_english, p.product_category_name, 'Unknown') AS category,
    COUNT(DISTINCT oi.order_id)                         AS total_orders,
    SUM(oi.order_item_id)                               AS total_units_sold,
    ROUND(SUM(oi.price), 2)                             AS total_revenue,
    ROUND(SUM(oi.freight_value), 2)                     AS total_freight,
    ROUND(SUM(oi.price) + SUM(oi.freight_value), 2)     AS total_order_value,
    ROUND(AVG(oi.price), 2)                             AS avg_item_price
FROM olist_order_items_dataset oi
LEFT JOIN olist_products_dataset p      ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name
GROUP BY COALESCE(t.product_category_name_english, p.product_category_name, 'Unknown')
ORDER BY total_revenue DESC;


--  Monthly Revenue Trend (2017–2018)
-- Business Question: How has revenue grown month over month?
-- Tables Used: orders, order_items
SELECT
    FORMAT(o.order_purchase_timestamp, 'yyyy-MM')       AS order_month,
    COUNT(DISTINCT o.order_id)                          AS total_orders,
    COUNT(DISTINCT o.customer_id)                       AS unique_customers,
    ROUND(SUM(oi.price), 2)                             AS monthly_revenue,
    ROUND(AVG(oi.price), 2)                             AS avg_order_value
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp IS NOT NULL
GROUP BY FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
ORDER BY order_month;


--  Top 10 Customers by Lifetime Spending
-- Business Question: Who are our highest value customers?
-- Tables Used: customers, orders, order_items
SELECT TOP 10
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    COUNT(DISTINCT o.order_id)                          AS total_orders,
    ROUND(SUM(oi.price), 2)                             AS lifetime_spend,
    ROUND(AVG(oi.price), 2)                             AS avg_order_value,
    MIN(FORMAT(o.order_purchase_timestamp, 'yyyy-MM-dd')) AS first_order,
    MAX(FORMAT(o.order_purchase_timestamp, 'yyyy-MM-dd')) AS last_order
FROM olist_customers_dataset c
JOIN olist_orders_dataset o         ON c.customer_id = o.customer_id
JOIN olist_order_items_dataset oi   ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id, c.customer_city, c.customer_state
ORDER BY lifetime_spend DESC;


--  Payment Method Analysis & Revenue by Payment Type
-- Business Question: How do customers prefer to pay?
-- Tables Used: order_payments, orders
SELECT
    op.payment_type,
    COUNT(DISTINCT op.order_id)                         AS total_orders,
    ROUND(SUM(op.payment_value), 2)                     AS total_payment_value,
    ROUND(AVG(op.payment_value), 2)                     AS avg_payment_value,
    ROUND(AVG(op.payment_installments), 1)              AS avg_installments,
    ROUND(SUM(op.payment_value) * 100.0 /
        SUM(SUM(op.payment_value)) OVER (), 2)          AS revenue_share_pct
FROM olist_order_payments_dataset op
JOIN olist_orders_dataset o ON op.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY op.payment_type
ORDER BY total_payment_value DESC;


-- Customer Review Score Distribution
-- Business Question: How satisfied are our customers overall?
-- Tables Used: order_reviews, orders

SELECT
    r.review_score,
    COUNT(*)                                            AS num_reviews,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total,
    CASE
        WHEN r.review_score >= 4 THEN 'Positive'
        WHEN r.review_score = 3  THEN 'Neutral'
        ELSE                          'Negative'
    END                                                 AS sentiment
FROM olist_order_reviews_dataset r
JOIN olist_orders_dataset o ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY r.review_score
ORDER BY r.review_score DESC;


--  Repeat vs One-Time Customers
-- Business Question: What percentage of customers return?
-- Tables Used: customers, orders
WITH customer_order_count AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),
customer_segments AS (
    SELECT
        customer_unique_id,
        total_orders,
        CASE
            WHEN total_orders = 1 THEN 'One-Time Customer'
            WHEN total_orders BETWEEN 2 AND 3 THEN 'Occasional Customer'
            ELSE 'Loyal Customer'
        END AS customer_type
    FROM customer_order_count
)
SELECT
    customer_type,
    COUNT(*)                                            AS num_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total,
    ROUND(AVG(CAST(total_orders AS FLOAT)), 2)          AS avg_orders
FROM customer_segments
GROUP BY customer_type
ORDER BY num_customers DESC;


--  Running Cumulative Revenue by Month (Window Function)
-- Business Question: What is our cumulative revenue growth?
-- Tables Used: orders, order_items

WITH monthly_revenue AS (
    SELECT
        FORMAT(o.order_purchase_timestamp, 'yyyy-MM')   AS order_month,
        ROUND(SUM(oi.price), 2)                         AS monthly_revenue
    FROM olist_orders_dataset o
    JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp IS NOT NULL
    GROUP BY FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
)
SELECT
    order_month,
    monthly_revenue,
    ROUND(SUM(monthly_revenue) OVER (
        ORDER BY order_month
        ROWS UNBOUNDED PRECEDING
    ), 2)                                               AS cumulative_revenue,
    ROUND(monthly_revenue - LAG(monthly_revenue) OVER (
        ORDER BY order_month
    ), 2)                                               AS mom_change,
    ROUND((monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY order_month))
        / NULLIF(LAG(monthly_revenue) OVER (ORDER BY order_month), 0) * 100
    , 2)                                                AS mom_growth_pct
FROM monthly_revenue
ORDER BY order_month;


-- Top 10 Sellers by Revenue & Avg Review Score
-- Business Question: Who are our best performing sellers?
-- Tables Used: sellers, order_items, orders, order_reviews
SELECT TOP 10
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id)                         AS total_orders,
    ROUND(SUM(oi.price), 2)                             AS total_revenue,
    ROUND(AVG(oi.price), 2)                             AS avg_item_price,
    ROUND(AVG(CAST(r.review_score AS FLOAT)), 2)        AS avg_review_score
FROM olist_sellers_dataset s
JOIN olist_order_items_dataset oi   ON s.seller_id = oi.seller_id
JOIN olist_orders_dataset o         ON oi.order_id = o.order_id
LEFT JOIN olist_order_reviews_dataset r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_id, s.seller_city, s.seller_state
ORDER BY total_revenue DESC;


-- Customer Spend Tier Segmentation (NTILE)
-- Business Question: Can we group customers into spend tiers?
-- Tables Used: customers, orders, order_items

WITH customer_spend AS (
    SELECT
        c.customer_unique_id,
        c.customer_state,
        COUNT(DISTINCT o.order_id)                      AS total_orders,
        ROUND(SUM(oi.price), 2)                         AS total_spend
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o         ON c.customer_id = o.customer_id
    JOIN olist_order_items_dataset oi   ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id, c.customer_state
)
SELECT
    customer_unique_id,
    customer_state,
    total_orders,
    total_spend,
    NTILE(4) OVER (ORDER BY total_spend DESC)           AS spend_quartile,
    CASE NTILE(4) OVER (ORDER BY total_spend DESC)
        WHEN 1 THEN 'Platinum'
        WHEN 2 THEN 'Gold'
        WHEN 3 THEN 'Silver'
        ELSE        'Bronze'
    END                                                 AS customer_tier
FROM customer_spend
ORDER BY total_spend DESC;


--Shipping Delay Analysis & Impact on Reviews
-- Business Question: Do late deliveries lead to lower ratings?
-- Tables Used: orders, order_reviews
WITH delivery_analysis AS (
    SELECT
        o.order_id,
        DATEDIFF(day, o.order_purchase_timestamp, o.order_delivered_customer_date) AS actual_days,
        DATEDIFF(day, o.order_purchase_timestamp, o.order_estimated_delivery_date)  AS estimated_days,
        DATEDIFF(day, o.order_estimated_delivery_date, o.order_delivered_customer_date) AS delay_days,
        CASE
            WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
                THEN 'On Time'
            WHEN DATEDIFF(day, o.order_estimated_delivery_date, o.order_delivered_customer_date) <= 7
                THEN 'Slightly Late (1-7 days)'
            ELSE 'Very Late (7+ days)'
        END AS delivery_status
    FROM olist_orders_dataset o
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
)
SELECT
    da.delivery_status,
    COUNT(*)                                            AS total_orders,
    ROUND(AVG(CAST(r.review_score AS FLOAT)), 2)        AS avg_review_score,
    ROUND(AVG(da.actual_days), 1)                       AS avg_delivery_days,
    ROUND(AVG(da.delay_days), 1)                        AS avg_delay_days,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)  AS pct_of_orders
FROM delivery_analysis da
LEFT JOIN olist_order_reviews_dataset r ON da.order_id = r.order_id
GROUP BY da.delivery_status
ORDER BY avg_review_score DESC;


--: State-wise Revenue & Order Heatmap
-- Business Question: Which states drive the most business?
-- Tables Used: customers, orders, order_items
SELECT
    c.customer_state,
    COUNT(DISTINCT c.customer_unique_id)                AS unique_customers,
    COUNT(DISTINCT o.order_id)                          AS total_orders,
    ROUND(SUM(oi.price), 2)                             AS total_revenue,
    ROUND(AVG(oi.price), 2)                             AS avg_order_value,
    ROUND(AVG(CAST(r.review_score AS FLOAT)), 2)        AS avg_review_score
FROM olist_customers_dataset c
JOIN olist_orders_dataset o         ON c.customer_id = o.customer_id
JOIN olist_order_items_dataset oi   ON o.order_id = oi.order_id
LEFT JOIN olist_order_reviews_dataset r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;


