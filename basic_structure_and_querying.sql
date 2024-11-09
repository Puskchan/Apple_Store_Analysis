-- Apple Sales Project
SELECT * FROM category;
SELECT * FROM products;
SELECT * FROM stores;
SELECT * FROM sales;
SELECT * FROM warrenty;


-- EDA
SELECT DISTINCT repair_status FROM warrenty;

SELECT COUNT(*) FROM sales;

SELECT DISTINCT country FROM stores;

-- Improving Query Performance

-- ET - 264ms to 8.7ms
-- PT - 0.103ms to 2.7ms
EXPLAIN ANALYZE
SELECT * FROM sales
WHERE product_id ='P-44';

CREATE INDEX sales_product_id ON sales(product_id);

-- ET - 204ms to 3.4ms
-- PT - 0.183ms to 2.7ms
EXPLAIN ANALYZE
SELECT * FROM sales
WHERE store_id ='ST-33';

CREATE INDEX sales_store_id ON sales(store_id);

CREATE INDEX sales_sale_date ON sales(sale_date);

-- Business Problems
