-- Data Cleaning Project: SampleSuperStore Dataset--
-- 1: View original data --
SELECT * 
FROM samplesuperstore;
-- 2: create a backup table for safe cleaning--
CREATE TABLE samplesuperstore1
LIKE samplesuperstore;
SELECT * 
FROM samplesuperstore1;
-- 3: create table into backup table --
INSERT INTO samplesuperstore1
SELECT * 
FROM samplesuperstore;
SELECT *
FROM samplesuperstore1;
-- Remove Duplicates --
-- 1: create a new table to store cleaned data --
CREATE TABLE `samplesuperstore2` (
  `Ship_Mode` text,
  `Segment` text,
  `Country` text,
  `City` text,
  `State` text,
  `Postal_Code` int DEFAULT NULL,
  `Region` text,
  `Category` text,
  `Sub-Category` text,
  `Sales` double DEFAULT NULL,
  `Quantity` int DEFAULT NULL,
  `Discount` double DEFAULT NULL,
  `Profit` double DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * 
FROM samplesuperstore2;
-- 2: insert data with row numbers to identify duplicates --
INSERT INTO samplesuperstore2
SELECT *,
ROW_NUMBER() 
OVER(PARTITION  BY Ship_Mode,Segment,Country,City,State,Postal_Code,Region,Category,`Sub-Category`,Sales,Quantity,Discount,Profit) AS row_num
FROM samplesuperstore1;
-- 3: check duplicate records --
SELECT * 
FROM samplesuperstore2
WHERE row_num >1;
-- 4: delete duplicate records --
DELETE
FROM samplesuperstore2
WHERE row_num >1;
SELECT * 
FROM samplesuperstore2
WHERE row_num >1;

-- Standardizing Data --
-- 1: convert data tyoes for better performance and accuracy --
SELECT * 
FROM samplesuperstore2;
ALTER TABLE samplesuperstore2
CHANGE Ship_Mode Ship_Mode VARCHAR(50) NOT NULL;
ALTER TABLE samplesuperstore2
CHANGE Postal_Code Postal_Code INT;
-- 2: convert text columns to VARCHAR for optimization --
ALTER TABLE samplesuperstore2
MODIFY Sales DECIMAL(10,2),
MODIFY Profit DECIMAL(10,2),
MODIFY Discount DECIMAL(4,2);
ALTER TABLE samplesuperstore2
MODIFY Segment VARCHAR(100),
MODIFY Country VARCHAR(50),
MODIFY City VARCHAR(100),
MODIFY State VARCHAR(100),
MODIFY Region VARCHAR(100),
MODIFY Category VARCHAR(100),
MODIFY `Sub-Category` VARCHAR(100);
-- 3: remove extra spaces
UPDATE samplesuperstore2
SET Ship_Mode = TRIM(Ship_Mode);
UPDATE samplesuperstore2
SET City = TRIM(City);
UPDATE samplesuperstore2
SET Segment = TRIM(Segment);
UPDATE samplesuperstore2
SET Country = TRIM(Country);
UPDATE samplesuperstore2
SET State = TRIM(State);
UPDATE samplesuperstore2
SET Region = TRIM(Region);
UPDATE samplesuperstore2
SET Category = TRIM(Category);
UPDATE samplesuperstore2
SET `Sub-Category` = TRIM(`Sub-Category`);
SELECT * 
FROM samplesuperstore2;
-- Remove NULL OR BLANk--
SELECT * 
FROM samplesuperstore2;
-- 1: handling missing values --
SELECT Sales
FROM samplesuperstore2
WHERE Sales IS NULL ;
SELECT Discount
FROM samplesuperstore2
WHERE Discount IS NULL ;
SELECT Profit
FROM samplesuperstore2
WHERE Profit IS NULL ;
-- Final Cleanup --
SELECT * 
FROM samplesuperstore2;
-- 1: remove helper column used for duplicate detection --
ALTER TABLE samplesuperstore2
DROP COLUMN row_num;
-- 2: Add Primary Key for better table structure --

ALTER TABLE samplesuperstore2
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY FIRST;
-- Check Data Quality --
-- 1: cjeck for invalid negative sales --
SELECT * 
FROM samplesuperstore2
WHERE Sales <0;
-- 2: check for invalid discount values --
SELECT * 
FROM samplesuperstore2
WHERE Discount >1;

-- Exploratory Data Analysis --
-- 1: View the raw data
SELECT *
FROM samplesuperstore2;

-- 2: (Total Sales, Orders, Average Order Value
SELECT
SUM(Sales) AS total_sale,
COUNT(DISTINCT id) AS total_orders,
SUM(Sales)/COUNT(DISTINCT id) AS avg_order_value
FROM samplesuperstore2;

-- 3: Top 5 Sub-Categories by Sales
SELECT 
`Sub-Category`,
SUM(Sales) AS total_sale
FROM samplesuperstore2
GROUP BY `Sub-Category`
ORDER BY total_sale DESC
LIMIT 5;

-- 4: Top 5 Sub-Categories by Sales
SELECT 
`Sub-Category`,
SUM(Sales) AS total_sale
FROM samplesuperstore2
GROUP BY `Sub-Category`
ORDER BY total_sale ASC
LIMIT 5;

-- 5: Total sales by Region
SELECT 
Region,
SUM(Sales) AS total_sale
FROM samplesuperstore2
GROUP BY Region
ORDER BY total_sale DESC
;

-- 6: Top 10 Cities by Sales and Profit
SELECT 
City,
SUM(Sales) AS total_sale,
SUM(Profit) AS total_profit
FROM samplesuperstore2
GROUP BY City
ORDER BY total_sale DESC
LIMIT 10;

-- 7: Total Profit by Category
SELECT 
Category,
SUM(Profit) AS total_profit
FROM samplesuperstore2
GROUP BY Category
ORDER BY total_profit DESC;

-- 8: Sales and Profit Analysis by Category
SELECT 
Category,
SUM(Sales) AS total_sale,
SUM(Profit) AS total_profit
FROM samplesuperstore2
GROUP BY Category 
ORDER BY total_profit DESC;

-- 9: Impact of Discount Levels on Profit and Orders
SELECT
ROUND(Discount,1) AS discount_level ,
AVG(Profit) AS avg_profit,
COUNT(id) AS orders
FROM samplesuperstore2
GROUP BY ROUND(Discount,1) 
ORDER BY discount_level ;

-- 10: Customer Segment performance Analysis
select 
Segment,
COUNT(id) AS total_orders,
SUM(Sales) AS total_sales,
SUM(Profit) AS total_profit
FROM samplesuperstore2
GROUP BY Segment
ORDER BY total_sales DESC;
