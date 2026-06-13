SELECT *
FROM ecommerce_data;

--------- DATA CLEANING ---------
-- Check for duplicates
WITH check_duplicates AS (
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY order_date DESC) AS record_count
	FROM ecommerce_data
)
SELECT *
FROM check_duplicates
WHERE record_count > 2;

-- Check for NULL values
SELECT *
FROM ecommerce_data
WHERE 
	customer_id IS NULL
	OR
	customer_first_name IS NULL
	OR
	customer_last_name IS NULL
	OR
	category_name IS NULL
	OR
	product_name IS NULL
	OR
	customer_segment IS NULL
	OR
	customer_city IS NULL
	OR
	customer_state IS NULL
	OR
	customer_country IS NULL
	OR
	customer_region IS NULL
	OR
	delivery_status IS NULL
	OR
	order_date IS NULL
	OR
	order_id IS NULL
	OR
	ship_date IS NULL
	OR
	shipping_type IS NULL
	OR
	days_for_shipment_scheduled IS NULL
	OR
	days_for_shipment_real IS NULL
	OR
	order_item_discount IS NULL
	OR
	sales_per_order IS NULL
	OR
	order_quantity IS NULL
	OR
	profit_per_order IS NULL;

--------- KPI ANALYSIS ---------

-- Total Sales Per Year
SELECT
	YEAR(order_date) AS Year,
	SUM(sales_per_order) AS total_sales
FROM ecommerce_data
GROUP BY YEAR(order_date)
ORDER BY Year;

-- YTD Sales 2022
SELECT
	SUM(sales_per_order) AS YTD_Sales
FROM ecommerce_data
WHERE YEAR(order_date) = '2022';

-- PYTD Sales 2021
SELECT
	SUM(sales_per_order) AS PYTD_Sales
FROM ecommerce_data
WHERE YEAR(order_date) = '2021'

-- Running Total of  YTD Sales
SELECT
	order_date,
	sales_per_order,
	SUM(sales_per_order) OVER(PARTITION BY YEAR(order_date) ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS YTD 
FROM ecommerce_data;

-- YoY Sales Growth Percentage
WITH sales_summary AS (
	SELECT
		SUM(CASE
			WHEN order_date >= '2022-01-01'
				AND order_date < '2023-01-01'
			THEN sales_per_order
		END) AS YTD_Sales,

		SUM(CASE
			WHEN order_date >= '2021-01-01'
				AND order_date < '2022-01-01'
			THEN sales_per_order
		END) AS PYTD_Sales
	FROM ecommerce_data
)
SELECT
	YTD_Sales AS current_year_sales,
	PYTD_Sales AS previous_year_sales,
	ROUND((YTD_Sales - PYTD_Sales) / NULLIF(PYTD_Sales, 0) * 100, 2) AS YoY_Growth_Percentage
FROM sales_summary;





-- Total Profit per Year
SELECT
	YEAR(order_date) AS Year,
	SUM(profit_per_order) AS total_sales
FROM ecommerce_data
GROUP BY YEAR(order_date)
ORDER BY Year;

-- YTD Profit 2022
SELECT
	SUM(profit_per_order) AS YTD_Profit
FROM ecommerce_data
WHERE YEAR(order_date) = '2022';

-- PYTD Profit 2022
SELECT
	SUM(profit_per_order) AS YTD_Profit
FROM ecommerce_data
WHERE YEAR(order_date) = '2021';

-- Running Total of  YTD Profit
SELECT
	order_date,
	profit_per_order,
	SUM(profit_per_order) OVER(PARTITION BY YEAR(order_date) ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS YTD
FROM ecommerce_data;

-- YoY Profit Growth Percentage
WITH profit_summary AS (
	SELECT
		SUM(CASE
			WHEN order_date >= '2022-01-01'
				AND order_date < '2023-01-01'
			THEN profit_per_order
		END) AS YTD_Profit,

		SUM(CASE
			WHEN order_date >= '2021-01-01'
				AND order_date < '2022-01-01'
			THEN profit_per_order
		END) AS PYTD_Profit
	FROM ecommerce_data
)
SELECT
	YTD_Profit AS current_year_sales,
	PYTD_Profit AS previous_year_sales,
	ROUND((YTD_Profit - PYTD_Profit) / NULLIF(PYTD_Profit, 0) * 100, 2) AS YoY_Growth_Percentage
FROM profit_summary;





-- Total Quantity per Year
SELECT
	YEAR(order_date) AS Year,
	SUM(order_quantity) AS total_quantity
FROM ecommerce_data
GROUP BY YEAR(order_date);


-- YTD Total Quantity 2022
SELECT
	SUM(order_quantity) AS YTD_total_quantity
FROM ecommerce_data
WHERE YEAR(order_date) = '2022';

-- PYTD Total Quantity 2021
SELECT
	SUM(order_quantity) AS PYTD_total_quantity
FROM ecommerce_data
WHERE YEAR(order_date) = '2021';

-- Running Total of YTD Total Quantity
SELECT
	order_date,
	order_quantity,
	SUM(order_quantity) OVER(PARTITION BY YEAR(order_date) ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS YTD
FROM ecommerce_data;

-- YoY Quantity Growth Percentage
WITH quantity_summary AS (
	SELECT
		SUM(CASE
			WHEN order_date >= '2022-01-01'
				AND order_date < '2023-01-01'
			THEN order_quantity
		END) AS YTD_Quantity,

		SUM(CASE
			WHEN order_date >= '2021-01-01'
				AND order_date < '2022-01-01'
			THEN order_quantity
		END) AS PYTD_Quantity
	FROM ecommerce_data
)
SELECT
	YTD_Quantity,
	PYTD_Quantity,
	(YTD_Quantity - PYTD_Quantity) * 1.0 / NULLIF(PYTD_Quantity, 0) * 100.0 AS YoY_Growth_Percentage
FROM quantity_summary;





-- Total Profit Margin per Year
SELECT
	YEAR(order_date),
	SUM(profit_per_order) AS total_profit,
	SUM(sales_per_order) AS total_sales,
	ROUND(SUM(profit_per_order) / SUM(sales_per_order) * 100, 2) AS profit_margin_percentage
FROM ecommerce_data
GROUP BY YEAR(order_date);

-- YTD Profit Margin 2022
SELECT
	ROUND(SUM(profit_per_order) / SUM(sales_per_order) * 100, 2) AS YTD_profit_margin_percentage
FROM ecommerce_data
WHERE YEAR(order_date) = '2022';

-- PYTD Profit Margin 2021
SELECT
	ROUND(SUM(profit_per_order) / SUM(sales_per_order) * 100, 2) AS YTD_profit_margin_percentage
FROM ecommerce_data
WHERE YEAR(order_date) = '2021';

-- YoY Profit Margin Growth Percentage
WITH yearly_summary AS (
    SELECT
        YEAR(order_date) AS order_year,
        SUM(profit_per_order) AS total_profit,
        SUM(sales_per_order) AS total_sales
    FROM ecommerce_data
    WHERE order_date >= '2021-01-01'
      AND order_date < '2023-01-01'
    GROUP BY YEAR(order_date)
),

profit_margin_summary AS (
    SELECT
        order_year,

        total_profit * 100.0
        / NULLIF(total_sales, 0) AS profit_margin

    FROM yearly_summary
)

SELECT
    curr.profit_margin AS current_margin,
    prev.profit_margin AS previous_margin,

    ROUND(
        (curr.profit_margin - prev.profit_margin)
        * 100.0
        / NULLIF(prev.profit_margin, 0),
        2
    ) AS yoy_profit_margin_growth

FROM profit_margin_summary curr
JOIN profit_margin_summary prev
    ON curr.order_year = prev.order_year + 1;


--------- ANALYSIS ---------
-- Sales by Category
SELECT
	category_name,
	SUM(sales_per_order) AS total_sales
FROM ecommerce_data
WHERE YEAR(order_date) = '2022'
GROUP BY category_name;

SELECT * FROM ecommerce_data;
SELECT * FROM us_state_long_lat_codes;

-- Sales by State
SELECT
	u.name,
	SUM(e.sales_per_order) AS total_sales
FROM us_state_long_lat_codes AS u
LEFT JOIN ecommerce_data AS e
	ON u.name = e.customer_state
WHERE YEAR(e.order_date) = '2022'
GROUP BY u.name
ORDER BY total_sales DESC;

-- TOP 5
SELECT
	TOP 5
	product_name,
	SUM(sales_per_order) AS total_sales
FROM ecommerce_data
WHERE YEAR(order_date) = '2022'
GROUP BY product_name
ORDER BY total_sales DESC;

-- BOTTOM 5
SELECT
	TOP 5
	product_name,
	SUM(sales_per_order) AS total_sales
FROM ecommerce_data
WHERE YEAR(order_date) = '2022'
GROUP BY product_name
ORDER BY total_sales;

-- Sales by Region
SELECT
	customer_region,
	SUM(sales_per_order) AS total_sales
FROM ecommerce_data
WHERE YEAR(order_date) = '2022'
GROUP BY customer_region;

-- Sales by Shipping Type
SELECT
	shipping_type,
	SUM(sales_per_order) AS total_sales
FROM ecommerce_data
WHERE YEAR(order_date) = '2022'
GROUP BY shipping_type;