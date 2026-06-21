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

## KPI Development Using DAX
This stage focuses on building DAX measures to calculate and analyze key business KPIs, with emphasis on performance trends and year-over-year comparisons.



