# E-commerce-YTD-Sales-Data-Visualization
This project involves building an E-Commerce Sales Dashboard using SQL Server and Power BI. Power BI connects directly to SQL Server to load data. SQL was used for cleaning and validation. The analysis highlights KPIs such as Sales, Profit, Quantity, and Profit Margin, focusing on YTD, PYTD, and YoY growth.
## Objectives
- **Data Integration** - Load e-commerce data from CSV files into Microsoft SQL Server and connect Power BI to SQL Server to retrieve and analyze the consolidated dataset.
- **Data Cleaning and Preparation** – Perform data quality checks and transformations using SQL and Power Query, including duplicate detection, null value validation, and data type corrections.
- **Date Intelligence Setup** – Create a dedicated Date table and supporting date columns to enable time intelligence calculations such as YTD, PYTD, Running Total, and YoY analysis.
- **Data Modeling** – Build an optimized data model by defining table relationships and implementing a star schema structure for efficient analytics.
- **KPI Development Using DAX** – Develop DAX measures to calculate key business metrics, including Sales, Profit, Order Quantity, Profit Margin, YTD, PYTD, and YoY Growth.
- **Data Visualization** – Develop interactive Power BI dashboards to visualize sales performance, profitability, product trends, regional distribution, and shipping effectiveness, enabling data-driven decision-making.

## Data Integration
The e-commerce dataset was initially stored in CSV format and imported into Microsoft SQL Server to establish a centralized data repository. SQL Server was utilized to manage the transactional data and perform preliminary data validation. Power BI was then connected directly to SQL Server to retrieve the processed dataset, ensuring a streamlined and scalable data pipeline for analysis and reporting. This integration enabled efficient data access, consistency across analyses, and a single source of truth for the dashboard.
<img width="500" height="250" alt="image" src="https://github.com/user-attachments/assets/719b98a9-5b76-4769-ad0b-b6005e8db967" />

## Data Cleaning and Preparation
This stage ensures the dataset is clean, accurate, and ready for analysis by addressing duplicates, missing values, and incorrect data types using SQL Server and Power Query.
### 1. Checked for Duplicate Records
Used SQL to identify potential duplicate records based on the order_id field.
```sql
WITH check_duplicates AS (
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY order_date DESC) AS record_count
	FROM ecommerce_data
)
SELECT *
FROM check_duplicates
WHERE record_count > 2;
```
### 2. Validated Missing Values
Performed SQL queries to check for null or missing values across all columns in the dataset.
```sql
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
```
### 3. Verified Data Types
Used Power Query to review and confirm that each column was assigned the appropriate data type.
<img width="1360" height="200" alt="image" src="https://github.com/user-attachments/assets/15b3a46c-b8bb-46a3-880f-fe412738c813" />

## Date Intelligence Setup
This stage focuses on creating a dedicated Date table to support time-based analysis and DAX time intelligence calculations.
### 1. Created a Calendar Table
Generated a Date table using DAX with the CALENDAR() function, covering the full range of transaction dates from the dataset.
```DAX
Calendar = 
CALENDAR(
    MIN(ecommerce_data[order_date]),
    MAX(ecommerce_data[order_date])
)
```

## Data Modeling
This stage focuses on building a structured data model to support accurate analysis and reporting in Power BI.
### 1. Defined Fact and Dimension Tables
Identified ecommerce_data as the fact table containing all transactional records, while Calendar and us_state_long_lat_codes were used as dimension tables.
### 2. Established Table Relationships
Created relationships to connect the fact and dimension tables:
 - ecommerce_data[customer_state] → us_state_long_lat_codes[name] for geographic analysis
 - ecommerce_data[order_date] → Calendar[Date] as an active relationship for time-based reporting
 - ecommerce_data[ship_date] → Calendar[Date] as an inactive relationship for shipment-based analysis
<img width="1022" height="322" alt="image" src="https://github.com/user-attachments/assets/b88b473b-28c9-4444-b907-4e275a44d667" />

### 3. Configured Role of Date Table
Utilized the Calendar table to support time intelligence calculations such as YTD, PYTD, and YoY analysis.

## KPI Development
This stage focuses on building DAX measures to calculate and analyze key business KPIs, with emphasis on performance trends and year-over-year comparisons. SQL was also used to validate and cross-check DAX results to ensure accuracy and consistency between the Power BI measures and the source data.
### 1. Sales
#### DAX (Power BI)
This stage focuses on building DAX measures to analyze Sales performance through time intelligence, trend visualization, and dynamic indicators.
##### 1.1 YTD Sales
Used the TOTALYTD function to compute Year-to-Date Sales:
```DAX
YTD Sales = 
TOTALYTD(
	SUM(ecommerce_data[sales_per_order]),
	'Calendar'[Date]
)
```
##### 1.2 PYTD Sales
Used CALCULATE, DATESYTD, and SAMEPERIODLASTYEAR to compute Previous Year-to-Date Sales:
```DAX
PYTD Sales = 
CALCULATE(
	SUM(ecommerce_data[sales_per_order]),
	DATESYTD(
		SAMEPERIODLASTYEAR('Calendar'[Date])
	)
)
```
##### 1.3 YoY Sales Growth
Calculated Year-over-Year Sales growth using a simple ratio comparison:
```DAX
YoY Sales = 
([YTD Sales] - [PYTD Sales]) / [PYTD Sales]
```
##### 1.4 Sales Trend Icon Indicator
Used IF logic and UNICHAR to display dynamic up/down arrows based on performance:
```DAX
Sales Trend Icon = 
VAR positive = UNICHAR(9650)
VAR negative = UNICHAR(9660)
VAR result = 
    IF([YoY Sales] > 0, positive, negative)
RETURN result
```
##### 1.5 Sales Background Color (Conditional Formatting)
Created a DAX measure to drive conditional formatting in Power BI:
```DAX
Sales BG Color = 
IF([YoY Sales] > 0, "Green", "Red")
```
##### 1.6 Sales Trend Visualization
Built an area chart using the sum of sales_per_order per month to visualize monthly sales trends and support performance analysis over time.
<img width="257" height="110" alt="image" src="https://github.com/user-attachments/assets/3ea865f9-336b-4eca-ab78-15e6acd6f922" />

#### SQL (Validation Layer)
SQL queries were used to independently compute and validate KPI results from DAX.
##### 1.1 Total Sales Per Year
Aggregates total sales per year to analyze yearly performance trends.
```sql
SELECT
    YEAR(order_date) AS Year,
    SUM(sales_per_order) AS total_sales
FROM ecommerce_data
GROUP BY YEAR(order_date)
ORDER BY Year;
```
##### 1.2 YTD Sales
Calculates total sales for the current year to date (2022).
```sql
SELECT
    SUM(sales_per_order) AS YTD_Sales
FROM ecommerce_data
WHERE YEAR(order_date) = '2022';
```
##### 1.3 PYTD Sales
Calculates total sales for the same period in the previous year (2021).
```sql
SELECT
    SUM(sales_per_order) AS PYTD_Sales
FROM ecommerce_data
WHERE YEAR(order_date) = '2021';
```
##### 1.4 Running Total (YTD Trend)
Computes cumulative sales over time to show sales progression.
```sql
SELECT
    order_date,
    sales_per_order,
    SUM(sales_per_order) OVER (
        PARTITION BY YEAR(order_date)
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS YTD
FROM ecommerce_data;
```
##### 1.5 YoY Sales Growth
Compares current year sales vs previous year sales to compute growth percentage.
```sql
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
    ROUND((YTD_Sales - PYTD_Sales) / NULLIF(PYTD_Sales, 0) * 100, 2) AS YoY_Growth_Percentage;
```
> **Note:** The same KPI development and validation approach used for Sales was also applied to **Profit**, **Total Quantity**, and **Profit Margin**. For each KPI, DAX measures were created for YTD, PYTD, YoY Growth, dynamic trend indicators, and conditional formatting, while SQL queries were used to validate the calculated results and ensure consistency with the source data.

## Data Visualization
This stage focuses on transforming KPI calculations into interactive visualizations that provide insights into sales performance, product trends, regional distribution, and shipping behavior.
<img width="1298" height="726" alt="image" src="https://github.com/user-attachments/assets/274f58d8-ab7e-49d3-9f28-7353d3d1427d" />

### 1. Sales by Category (Matrix)
A Matrix visual was created to compare sales performance across product categories.
 - Rows: Category
 - Values:
 	- YTD Sales
 	- PYTD Sales
 	- YoY Sales Growth
 	- Sales Trend Icon
This visualization enables quick comparison of category performance while highlighting year-over-year changes through dynamic trend indicators.
### 2. Sales by State (Map)
A Map visual was developed to display the geographical distribution of sales across states.
 - Location: Customer State
 - Values: YTD Sales
 - Supporting Data: Latitude and Longitude from the us_state_long_lat_codes table
### 3. Top 5 Products by YTD Sales (Stacked Bar Chart)
A Stacked Bar Chart was created to highlight the top-performing products based on YTD Sales.
 - Axis: Product Name
 - Values: YTD Sales
 - Filter: Top 5 Products
This visualization helps identify the products that contribute the most to overall sales performance.
### 4. Bottom 5 Products by YTD Sales (Stacked Bar Chart)
A second Stacked Bar Chart was created to identify the lowest-performing products.
 - Axis: Product Name
 - Values: YTD Sales
 - Filter: Bottom 5 Products
This visualization helps uncover products that may require additional attention or improvement strategies.
### 5. YTD Sales by Region (Donut Chart)
A Donut Chart was used to visualize the distribution of YTD Sales across regions.
 - Legend: Region
 - Values: YTD Sales
This visualization provides a quick view of each region's contribution to total sales.
### 6. YTD Sales by Shipping Type (Pie Chart)
A Pie Chart was created to analyze sales distribution by shipping method.
 - Legend: Shipping Type
 - Values: YTD Sales
This visualization highlights the proportion of sales generated through each shipping option and helps identify the most utilized shipping methods.
