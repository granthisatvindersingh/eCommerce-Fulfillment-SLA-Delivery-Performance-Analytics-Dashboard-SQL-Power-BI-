use olist_ecommerce;
LOAD DATA LOCAL INFILE 'C:/Users/ssgra/OneDrive/Desktop/powerbi/olist_customers_dataset.csv'
INTO TABLE olist_customers_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 
 

LOAD DATA LOCAL INFILE 'C:/Users/ssgra/OneDrive/Desktop/powerbi/olist_orders_dataset.csv'
INTO TABLE olist_orders_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/ssgra/OneDrive/Desktop/powerbi/olist_order_items_dataset.csv'
INTO TABLE olist_order_items_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/ssgra/OneDrive/Desktop/powerbi/olist_order_reviews_dataset.csv'
INTO TABLE olist_order_reviews_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/ssgra/OneDrive/Desktop/powerbi/olist_products_dataset.csv'
INTO TABLE olist_products_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT 'orders' as table_name, COUNT(*) as row_count 
FROM olist_orders_dataset
UNION ALL
SELECT 'order_items', COUNT(*) 
FROM olist_order_items_dataset
UNION ALL
SELECT 'reviews', COUNT(*) 
FROM olist_order_reviews_dataset
UNION ALL
SELECT 'products', COUNT(*) 
FROM olist_products_dataset
UNION ALL
SELECT 'customers', COUNT(*) 
FROM olist_customers_dataset; 

-- Step 1: clear the duplicate
TRUNCATE TABLE olist_orders_dataset;

-- Step 2: reload it once
LOAD DATA LOCAL INFILE 'C:/Users/ssgra/OneDrive/Desktop/powerbi/olist_orders_dataset.csv'
INTO TABLE olist_orders_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Step 3: verify
SELECT COUNT(*) FROM olist_orders_dataset; 

SELECT 'orders' as table_name, COUNT(*) as row_count 
FROM olist_orders_dataset
UNION ALL
SELECT 'order_items', COUNT(*) 
FROM olist_order_items_dataset
UNION ALL
SELECT 'reviews', COUNT(*) 
FROM olist_order_reviews_dataset
UNION ALL
SELECT 'products', COUNT(*) 
FROM olist_products_dataset
UNION ALL
SELECT 'customers', COUNT(*) 
FROM olist_customers_dataset; 

-- Step 1: Delete all rows
DELETE FROM olist_orders_dataset;

-- Step 2: Check it's empty
SELECT COUNT(*) FROM olist_orders_dataset;

-- Step 1: Drop the table entirely
DROP TABLE olist_orders_dataset;

-- Step 2: Recreate it fresh
CREATE TABLE olist_orders_dataset (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);

-- Step 3: Verify it's empty
SELECT COUNT(*) FROM olist_orders_dataset;

LOAD DATA LOCAL INFILE 'C:/Users/ssgra/OneDrive/Desktop/powerbi/olist_orders_dataset.csv'
INTO TABLE olist_orders_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM olist_orders_dataset; 

-- Step 1: Drop the table entirely
DROP TABLE olist_orders_dataset;

-- Step 2: Recreate it fresh
CREATE TABLE olist_orders_dataset (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);

-- Step 3: Verify it's empty
SELECT COUNT(*) FROM olist_orders_dataset; 

LOAD DATA LOCAL INFILE 'C:/Users/ssgra/OneDrive/Desktop/powerbi/olist_orders_dataset.csv'
INTO TABLE olist_orders_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM olist_orders_dataset;

SELECT 'orders' as table_name, COUNT(*) as row_count 
FROM olist_orders_dataset ; 

USE olist_ecommerce;

CREATE TABLE sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);

LOAD DATA INFILE 'C:\Users\ssgra\OneDrive\Desktop\powerbi\olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 


RENAME TABLE olist_orders_dataset TO orders;
RENAME TABLE olist_customers_dataset TO customers;
RENAME TABLE olist_products_dataset TO products;
RENAME TABLE olist_order_reviews_dataset TO order_reviews;
RENAME TABLE olist_order_items_dataset TO order_items; 



USE olist_ecommerce;

CREATE VIEW delivery_sla_view AS
SELECT
    order_id,

    DATEDIFF(order_approved_at, order_purchase_timestamp) 
        AS approval_delay_days,

    DATEDIFF(order_delivered_carrier_date, order_approved_at) 
        AS carrier_delay_days,

    DATEDIFF(order_delivered_customer_date, order_delivered_carrier_date) 
        AS delivery_delay_days,

    DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) 
        AS total_delivery_days,

    CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date
        THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status

FROM orders
WHERE order_status = 'delivered';


SELECT * 
FROM delivery_sla_view
LIMIT 10; 

 -- KPI 1: Approval Delay Analysis (Order Processing Bottleneck)
 SELECT
ROUND(AVG(approval_delay_days),2) AS avg_approval_delay_days
FROM delivery_sla_view;

-- KPI 2: Carrier Pickup Delay (Logistics Bottleneck Detection)
SELECT
ROUND(AVG(carrier_delay_days),2) AS avg_carrier_delay_days
FROM delivery_sla_view;

-- KPI 3: Last-Mile Delivery Delay
SELECT
ROUND(AVG(delivery_delay_days),2) AS avg_last_mile_delay_days
FROM delivery_sla_view;

-- KPI 4: Region-Wise SLA Performance 
SELECT
c.customer_state,
ROUND(AVG(d.total_delivery_days),2) AS avg_delivery_days
FROM delivery_sla_view d
JOIN orders o
ON d.order_id = o.order_id
JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY avg_delivery_days DESC;

-- KPI 5: Late Delivery Rate by State 
SELECT
c.customer_state,
ROUND(
SUM(CASE WHEN d.delivery_status='Late' THEN 1 ELSE 0 END)*100.0
/ COUNT(*),2
) AS late_delivery_percent
FROM delivery_sla_view d
JOIN orders o
ON d.order_id=o.order_id
JOIN customers c
ON o.customer_id=c.customer_id
GROUP BY c.customer_state
ORDER BY late_delivery_percent DESC; 

-- KPI 6: Seller Performance Impact on Delivery Speed
SELECT
oi.seller_id,
ROUND(AVG(d.total_delivery_days),2) AS avg_delivery_days
FROM delivery_sla_view d
JOIN order_items oi
ON d.order_id = oi.order_id
GROUP BY oi.seller_id
ORDER BY avg_delivery_days DESC
LIMIT 15; 

-- KPI 7: Delivery Speed vs Customer Satisfaction
SELECT
r.review_score,
ROUND(AVG(d.total_delivery_days),2) AS avg_delivery_days
FROM delivery_sla_view d
JOIN order_reviews r
ON d.order_id=r.order_id
GROUP BY r.review_score
ORDER BY review_score;
