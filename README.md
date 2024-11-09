---

# Apple Retail Sales SQL Project - Analyzing Millions of Sales Rows

![apple](https://www.apple.com/newsroom/images/product/apple-news/Apple-BKC-Mumbai-India-media-preview-hero_Full-Bleed-Image.jpg.slideshow-medium_2x.jpg)

## Project Overview

This project is designed to showcase advanced SQL querying techniques through the analysis of over 1 million rows of Apple retail sales data. The dataset includes information about products, stores, sales transactions, and warranty claims across various Apple retail locations globally. By tackling a variety of questions, from basic to complex, I'll demonstrate the ability to write sophisticated SQL queries that extract valuable insights from large datasets.

## Entity Relationship Diagram (ERD)

![ERD](https://github.com/najirh/Apple-Retail-Sales-SQL-Project---Analyzing-Millions-of-Sales-Rows/blob/main/erd.png)

---

## Database Schema

The project uses five main tables:

1. **`stores`**: Contains information about Apple retail stores.
   - `store_id`: Unique identifier for each store.
   - `store_name`: Name of the store.
   - `city`: City where the store is located.
   - `country`: Country of the store.

2. **`category`**: Holds product category information.
   - `category_id`: Unique identifier for each product category.
   - `category_name`: Name of the category.

3. **`products`**: Details about Apple products.
   - `product_id`: Unique identifier for each product.
   - `product_name`: Name of the product.
   - `category_id`: References the category table.
   - `launch_date`: Date when the product was launched.
   - `price`: Price of the product.

4. **`sales`**: Stores sales transactions.
   - `sale_id`: Unique identifier for each sale.
   - `sale_date`: Date of the sale.
   - `store_id`: References the store table.
   - `product_id`: References the product table.
   - `quantity`: Number of units sold.

5. **`warranty`**: Contains information about warranty claims.
   - `claim_id`: Unique identifier for each warranty claim.
   - `claim_date`: Date the claim was made.
   - `sale_id`: References the sales table.
   - `repair_status`: Status of the warranty claim (e.g., Paid Repaired, Warranty Void).

## Objectives

The project is split into three tiers of Insights with increasing complexity:

### Easy

- **1.** Find the number of stores in each country.
  ```sql
  SELECT 
	  country,
	  COUNT(store_id) AS total_stores
  FROM stores
  GROUP BY 1
  ORDER BY 2 DESC;
  ```
- **2.** Calculate the total number of units sold by each store.
  ```sql
  SELECT
    st.store_name,
    COUNT(s.quantity) AS sold_units
  FROM stores AS st
  JOIN sales AS s ON st.store_id=s.store_id
  GROUP BY 1
  ORDER BY 2 DESC;
  ```
- **3.** Identify how many sales occurred in December 2023.
  ```sql
  SELECT sale_date, COUNT(*) AS total_sales
  FROM sales
  WHERE sale_date BETWEEN '2023-12-01' AND '2023-12-31'
  GROUP BY sale_date;
  ```
- **4.** Determine how many stores have never had a warranty claim filed.
  ```sql
  SELECT store_name
  FROM stores st
  WHERE store_id NOT IN (
      SELECT DISTINCT(s.store_id)
      FROM sales s
      RIGHT JOIN warrenty w 
      ON s.sale_id=w.sale_id
      );
  ```
- **5.** Calculate the percentage of warranty claims marked as "Warranty Void".
  ```sql
  SELECT 
	ROUND(
		COUNT(claim_id)/(SELECT COUNT(*) FROM warrenty)::numeric * 100, 2)
	as warranty_void_percentage
  FROM warrenty
  WHERE repair_status = 'Warranty Void';
  ```
- **6.** Identify which store had the highest total units sold in the last year.
  ```sql
  SELECT 
	  s.store_id,
	  st.store_name,
	  SUM(s.quantity) 
  FROM sales as s
  JOIN stores as st on s.store_id=st.store_id
  WHERE s.sale_date >= (CURRENT_DATE - INTERVAL '1 year')
  GROUP BY 1, 2
  ORDER BY 3 DESC
  LIMIT 1;
  ```
- **7.** Count the number of unique products sold in the last year.
  ```sql
  SELECT 
	  DISTINCT(p.product_name)
  FROM sales as s
  JOIN products as p on s.product_id = p.product_id
  WHERE sale_date >= (CURRENT_DATE - INTERVAL '1 year');
  ```
- **8.** Find the average price of products in each category.
  ```sql
  SELECT 
	  c.category_name,
	  ROUND(AVG(p.price)) as avg_price
  FROM products as p
  JOIN category as c on p.category_id=c.category_id
  GROUP BY c.category_id
  ORDER BY 2 DESC;
  ```
- **9.** How many warranty claims were filed in 2020?
  ```sql
  SELECT COUNT(claim_id)
  FROM warrenty
  WHERE claim_date BETWEEN '2020-01-01' AND '2020-12-31';
  ```
- **10.** For each store, identify the best-selling day based on highest quantity sold.
  ```sql
  SELECT * 
  FROM
  (
  	SELECT 
  		st.store_id,
  		st.store_name,
  		TO_CHAR(s.sale_date, 'Day'),
  		SUM(s.quantity) as total_quantity,
  		RANK() OVER(PARTITION BY st.store_id ORDER BY SUM(s.quantity) DESC) as rank
  	FROM sales as s
  	JOIN stores as st on s.store_id=st.store_id
  	GROUP BY 1,3
  ) as t
  WHERE rank = 1;
  ```

### Medium

- **11.** Identify the least selling product in each country for each year based on total units sold.
  ```sql
	WITH product_rank
	AS
	(
	    SELECT 
	        st.country,
	        p.product_name,
	        SUM(s.quantity) AS total_quantity,
	        RANK() OVER(PARTITION BY st.country ORDER BY SUM(s.quantity) ASC) AS rank
	    FROM sales AS s
	    JOIN stores AS st ON s.store_id = st.store_id
	    JOIN products AS p ON s.product_id = p.product_id
	    GROUP BY 1,2
	)
	SELECT *
	FROM product_rank
	WHERE rank = 1;
  ```
- **12.** Calculate how many warranty claims were filed within 180 days of a product sale.
  ```sql
	SELECT COUNT(s.sale_date)
	FROM sales as s
	JOIN warrenty as w on s.sale_id=w.sale_id
	WHERE w.claim_date - sale_date <= 180;
  ```
- **13.** Determine how many warranty claims were filed for products launched in the last two years.
  ```sql
	SELECT COUNT(w.claim_id)
	FROM sales as s
	JOIN warrenty as w on s.sale_id=w.sale_id
	JOIN products as p on s.product_id=p.product_id
	WHERE p.launch_date >= (CURRENT_DATE - INTERVAL '2 year');
  ```
- **14.** List the months in the last three years where sales exceeded 5,000 units in the USA.
  ```sql
	SELECT 
		SUM(quantity) as month_sale, 
		TO_CHAR(sale_date, 'MonthYY') as month
	FROM sales as s
	JOIN stores as st on s.store_id=st.store_id
	WHERE sale_date >= (CURRENT_DATE - INTERVAL '3 year')
	AND st.country = 'USA'
	GROUP BY month
	HAVING SUM(quantity) > 5000;
  ```
- **15.** Identify the product category with the most warranty claims filed in the last two years.
  ```sql
	SELECT COUNT(w.claim_id), c.category_name
	FROM products as p
	JOIN category as c on p.category_id=c.category_id
	JOIN sales as s on p.product_id=s.product_id
	JOIN warrenty as w on s.sale_id=w.sale_id
	WHERE sale_date >= (CURRENT_DATE - INTERVAL '2 year')
	GROUP BY 2
	ORDER BY 1 DESC
	LIMIT 1;

  ```

### Complex

- **16.** Determine the percentage chance of receiving warranty claims after each purchase for each country.
  ```sql
    SELECT 
		country,
		total_unit_sold,
		total_claim,
		COALESCE(ROUND(total_claim::numeric/total_unit_sold::numeric * 100), 0) as risk_percent
	FROM
	(SELECT 
		st.country, 
		SUM(s.quantity) as total_unit_sold,
		COUNT(w.claim_id) as total_claim
	FROM sales as s
	JOIN stores as st on s.store_id=st.store_id
	LEFT JOIN warrenty as w on s.sale_id=w.sale_id
	GROUP BY 1
	HAVING COUNT(w.claim_id) > 0) as t1
	ORDER BY 3 DESC;

  ```
- **17.** Analyze the year-by-year growth ratio for each store.
  ```sql
	WITH yearly_sales
	AS
	(
	SELECT
		s.store_id,
		st.store_name,
		EXTRACT(YEAR FROM sale_date) as year,
		SUM(s.quantity * p.price) as total_sale
	FROM sales as s
	JOIN products as p on s.product_id=p.product_id
	JOIN stores as st on s.store_id=st.store_id
	GROUP BY 1, 2, 3
	ORDER BY 2, 3
	),
	growth_ratio
	AS
	(
	SELECT
		store_name,
		year,
		LAG(total_sale, 1) OVER(PARTITION BY store_name ORDER BY year) as last_year_sale,
		total_sale as current_year_sale
	FROM yearly_sales
	)
	SELECT
		store_name,
		year,
		last_year_sale,
		current_year_sale,
		ROUND((current_year_sale - last_year_sale)::numeric / last_year_sale::numeric * 100, 3) as year_on_year
	FROM growth_ratio
	WHERE last_year_sale IS NOT NULL
	AND YEAR <> EXTRACT(YEAR FROM CURRENT_DATE);
  ```
- **18.** Calculate the correlation between product price and warranty claims for products sold in the last five years, segmented by price range.
  ```sql
	SELECT 
		CASE
			WHEN p.price < 500 THEN 'Low End Product'
			WHEN p.price BETWEEN 500 AND 1000 THEN 'Mid Range Product'
			ELSE 'High End Product'
		END as price_segment,
		COUNT(w.claim_id) as total_claim
	FROM warrenty as w
	LEFT JOIN sales as s on w.sale_id=s.sale_id
	JOIN products as p on s.product_id=p.product_id
	WHERE claim_date >= CURRENT_DATE - INTERVAL '5 year'
	GROUP BY 1
	ORDER BY 2 DESC;

  ```
- **19.** Identify the store with the highest percentage of "Paid Repaired" claims relative to total claims filed.
  ```sql
	WITH total AS (
	    SELECT 
	        s.store_id,
	        COUNT(w.repair_status) AS total_repair
	    FROM sales AS s
	    RIGHT JOIN warrenty AS w ON s.sale_id = w.sale_id
	    GROUP BY 1
	), 
	paid AS (
	    SELECT 
	        s.store_id,
	        COUNT(w.repair_status) AS paid_repair
	    FROM sales AS s
	    RIGHT JOIN warrenty AS w ON s.sale_id = w.sale_id
	    WHERE w.repair_status = 'Paid Repaired'
	    GROUP BY 1
	)
	SELECT
	    tr.store_id,
		st.store_name,
	    tr.total_repair,
	    pr.paid_repair,
		ROUND((pr.paid_repair::numeric/tr.total_repair::numeric) * 100, 2) as percent_paid_repair
	FROM total AS tr
	JOIN paid AS pr ON tr.store_id = pr.store_id
	JOIN stores as st on tr.store_id=st.store_id
	ORDER BY 5 DESC;

  ```
- **20.** Write a query to calculate the monthly running total of sales for each store over the past four years and compare trends during this period.
  ```sql
	WITH monthly_sales
	AS (SELECT 
		store_id,
		EXTRACT(YEAR FROM sale_date) as year,
		EXTRACT(MONTH FROM sale_date) as month,
		SUM(p.price * s.quantity) as total_revenue
	FROM sales as s
	JOIN products as p on s.product_id=p.product_id
	GROUP BY 1,2,3
	ORDER BY 1,2,3)
	SELECT 
		store_id,
		month,
		year,
		total_revenue,
		SUM(total_revenue) OVER(PARTITION BY store_id ORDER BY year, month) as running_total
	FROM monthly_sales;
  ```

### Bonus 

- **Analyze product sales trends over time**, segmented into key periods: from launch to 6 months, 6-12 months, 12-18 months, and beyond 18 months.
  ```sql
	WITH launch_to_six AS (
	    SELECT 
	        p.launch_date,
	        p.product_name,
	        COUNT(s.sale_id) AS launch_to_six,
	        SUM(s.quantity * p.price) AS lts_revenue
	    FROM products AS p
	    LEFT JOIN sales AS s ON s.product_id = p.product_id
	    AND s.sale_date BETWEEN p.launch_date AND p.launch_date + INTERVAL '6 month'
	    GROUP BY p.launch_date, p.product_name
	),
	six_to_twelve AS (
	    SELECT 
	        p.launch_date,
	        p.product_name,
	        COUNT(s.sale_id) AS six_to_twelve,
	        SUM(s.quantity * p.price) AS stt_revenue
	    FROM products AS p
	    LEFT JOIN sales AS s ON s.product_id = p.product_id
	    AND s.sale_date BETWEEN p.launch_date + INTERVAL '6 month' AND p.launch_date + INTERVAL '12 month'
	    GROUP BY p.launch_date, p.product_name
	),
	twelve_to_eighteen AS (
	    SELECT 
	        p.launch_date,
	        p.product_name,
	        COUNT(s.sale_id) AS twelve_to_eighteen,
	        SUM(s.quantity * p.price) AS tte_revenue
	    FROM products AS p
	    LEFT JOIN sales AS s ON s.product_id = p.product_id
	    AND s.sale_date BETWEEN p.launch_date + INTERVAL '12 month' AND p.launch_date + INTERVAL '18 month'
	    GROUP BY p.launch_date, p.product_name
	),
	beyond_eighteen AS (
	    SELECT 
	        p.launch_date,
	        p.product_name,
	        COUNT(s.sale_id) AS beyond_eighteen,
	        SUM(s.quantity * p.price) AS be_revenue
	    FROM products AS p
	    LEFT JOIN sales AS s ON s.product_id = p.product_id
	    AND s.sale_date >= p.launch_date + INTERVAL '18 month'
	    GROUP BY p.launch_date, p.product_name
	)
	SELECT
	    lts.launch_date,
	    lts.product_name,
	    COALESCE(lts.launch_to_six, 0) AS launch_to_six,
	    COALESCE(lts.lts_revenue, 0) AS lts_revenue,
	    COALESCE(stt.six_to_twelve, 0) AS six_to_twelve,
	    COALESCE(stt.stt_revenue, 0) AS stt_revenue,
	    COALESCE(tte.twelve_to_eighteen, 0) AS twelve_to_eighteen,
	    COALESCE(tte.tte_revenue, 0) AS tte_revenue,
	    COALESCE(be.beyond_eighteen, 0) AS beyond_eighteen,
	    COALESCE(be.be_revenue, 0) AS be_revenue
	FROM launch_to_six AS lts
	LEFT JOIN six_to_twelve AS stt ON lts.launch_date = stt.launch_date AND lts.product_name = stt.product_name
	LEFT JOIN twelve_to_eighteen AS tte ON lts.launch_date = tte.launch_date AND lts.product_name = tte.product_name
	LEFT JOIN beyond_eighteen AS be ON lts.launch_date = be.launch_date AND lts.product_name = be.product_name;
  ```

***Another Approach**
```sql
WITH sales_intervals AS (
    SELECT 
        p.product_name,
        p.launch_date,
        COUNT(CASE WHEN s.sale_date BETWEEN p.launch_date AND p.launch_date + INTERVAL '6 month' THEN s.sale_id END) AS launch_to_six,
        SUM(CASE WHEN s.sale_date BETWEEN p.launch_date AND p.launch_date + INTERVAL '6 month' THEN s.quantity * p.price END) AS lts_revenue,
        COUNT(CASE WHEN s.sale_date BETWEEN p.launch_date + INTERVAL '6 month' AND p.launch_date + INTERVAL '12 month' THEN s.sale_id END) AS six_to_twelve,
        SUM(CASE WHEN s.sale_date BETWEEN p.launch_date + INTERVAL '6 month' AND p.launch_date + INTERVAL '12 month' THEN s.quantity * p.price END) AS stt_revenue,
        COUNT(CASE WHEN s.sale_date BETWEEN p.launch_date + INTERVAL '12 month' AND p.launch_date + INTERVAL '18 month' THEN s.sale_id END) AS twelve_to_eighteen,
        SUM(CASE WHEN s.sale_date BETWEEN p.launch_date + INTERVAL '12 month' AND p.launch_date + INTERVAL '18 month' THEN s.quantity * p.price END) AS tte_revenue,
        COUNT(CASE WHEN s.sale_date >= p.launch_date + INTERVAL '18 month' THEN s.sale_id END) AS beyond_eighteen,
        SUM(CASE WHEN s.sale_date >= p.launch_date + INTERVAL '18 month' THEN s.quantity * p.price END) AS be_revenue
    FROM sales AS s
    JOIN products AS p ON s.product_id = p.product_id
    GROUP BY p.product_name, p.launch_date
)
SELECT 
    product_name,
    launch_date,
    launch_to_six,
    lts_revenue,
    six_to_twelve,
    stt_revenue,
    twelve_to_eighteen,
    tte_revenue,
    beyond_eighteen,
    be_revenue
FROM sales_intervals
ORDER BY launch_date;

```
## Project Focus

This project primarily focuses on developing and showcasing the following SQL skills:

- **Complex Joins and Aggregations**: Demonstrating the ability to perform complex SQL joins and aggregate data meaningfully.
- **Window Functions**: Using advanced window functions for running totals, growth analysis, and time-based queries.
- **Data Segmentation**: Analyzing data across different time frames to gain insights into product performance.
- **Correlation Analysis**: Applying SQL functions to determine relationships between variables, such as product price and warranty claims.
- **Real-World Problem Solving**: Answering business-related questions that reflect real-world scenarios faced by data analysts.

## Dataset

| **Attribute**           | **Description**                          |
|-------------------------|------------------------------------------|
| **Size**                | 1 million+ rows of sales data           |
| **Period Covered**      | Multiple years, enabling trend analysis |
| **Geographical Coverage** | Sales data from Apple stores globally |

## Conclusion

This Apple Retail Sales SQL project offers a comprehensive look at SQL’s power to unlock actionable insights from vast datasets, such as Apple’s global sales data. By systematically addressing complex business questions, from basic aggregations to intricate window functions and correlation analysis, this project illustrates the real-world application of advanced SQL techniques. The progression through increasingly challenging questions demonstrates versatility in querying, ranging from data segmentation and warranty claim analysis to sales trend evaluation across product lifecycles.

This project is more than just an exercise in querying—it showcases how SQL can transform raw data into valuable insights that drive business strategy. Whether identifying sales leaders, evaluating warranty claim risks, or analyzing product demand over time, these insights are essential for data-driven decision-making in today’s business landscape. Ultimately, this project underscores SQL’s role as a crucial tool for anyone aspiring to turn data into a strategic asset in the tech and retail industries.

---
