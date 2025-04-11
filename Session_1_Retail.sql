CREATE DATABASE Retail;
USE Retail;

SELECT * FROM sales_transaction;

-- Problem Statement 1:
/*
Write a query to identify the number of duplicates in "sales_transaction" table. Also, 
create a separate table containing the unique values and remove the the original table 
from the databases and replace the name of the new table with the original name.
Hint:
Use the “Sales_transaction” table.
There will be two resulting tables in the output. First, the table where the count of 
duplicates will be identified and in the second table we can check if the duplicates 
were removed or not by selecting the whole table.
*/
-- Step 1: Count duplicates
SELECT TransactionID, COUNT(*)
FROM Sales_transaction
GROUP BY TransactionID
HAVING COUNT(*) > 1;

-- Step 2: Create a table with unique records
CREATE TABLE sales_unique AS
SELECT DISTINCT *
FROM Sales_transaction;

-- Step 3: Drop the original table
DROP TABLE Sales_transaction;

-- Step 4: Rename the unique table to the original table name
RENAME TABLE sales_unique TO Sales_transaction;

-- Step 5: Verify the updated table
SELECT * FROM Sales_transaction;


-- Problem 2
/* 
Discrepancy - a lack of compatibility or similarity between two or more facts:
Write a query to identify the discrepancies in the price of the same product 
in "sales_transaction" and "product_inventory" tables. 
Also, update those discrepancies to match the price in both the tables.
*/
SELECT * FROM product_inventory;
SELECT * FROM sales_transaction;

-- STEP 1: Checking for the discrepancies
SELECT s.TransactionID, s.Price as TransactionPrice, p.Price as InventoryPrice
FROM sales_transaction s
join product_inventory p on p.ProductID = s.ProductID
where s.Price <> p.Price;

-- STEP 2: Updating the unmatched value with the correct entry
UPDATE sales_transaction s
JOIN product_inventory p ON p.ProductID = s.ProductID
SET s.Price = p.Price
WHERE s.Price <> p.Price;
/* Alternate approach.
-- Update the entry of the ProductID TransactionPrice where there is a discrepancy
UPDATE sales_transaction s
SET Price = (SELECT p.price FROM product_inventory p WHERE s.ProductID = p.ProductID)
WHERE s.ProductID IN (SELECT p.productID FROM product_inventory p WHERE s.Price <> p.Price);
*/
-- STEP 3: Displaying the Table
SELECT * FROM sales_transaction;

-- Problem 3
/*
Write a SQL query to identify the null values in the dataset and replace those by “Unknown”.
Hint:
Use the customer_profiles table.
Identify the columns which contains null values and count the number of cells containing null values. 
Update those values with “unknown” and showcase the changes that the query has created.
*/
SELECT * FROM customer_profiles;

-- STEP 1: Identifying the columns which are having null values
select * from customer_profiles
WHERE CustomerID = "" 
	OR Age =""
    OR Gender = ""
    OR Location = "" -- Only Location is having NULL values
    OR JoinDate = "";

-- STEP 2: count the number of cells containing null values
SELECT COUNT(*) FROM customer_profiles
WHERE Location = "";

-- STEP 3: Update those values with “unknown”
UPDATE customer_profiles
SET Location = "Unknown"
WHERE Location = "";

-- STEP 4: Show case the changes
SELECT * FROM customer_profiles;

-- Problem 4: 
/*
Write a SQL query to clean the DATE column in the dataset.
Steps:
Create a separate table and change the data type of the date column as it is in TEXT 
format and name it as you wish to.
Remove the original table from the database.
Change the name of the new table and replace it with the original name of the table.
Hint:
Use the “Sales_transaction” tables.
The resulting table will display a separate column named TransactionDate_updated.
*/
SELECT * FROM sales_transaction;
/*
Since the date format of transaction date is dd-mm-yyyy so we should first update that and then we will proceed
*/
-- STEP 0:
UPDATE sales_transaction
SET TransactionDate = date_format(str_to_date(TransactionDate,'%d-%m-%Y'),'%Y-%m-%d');

-- STEP 1: Create a new table
CREATE TABLE sales_new
SELECT * FROM sales_transaction;

DESC sales_new;

-- STEP 2: Changine the type of the Transaction Date and creating a new column
ALTER TABLE sales_new
ADD COLUMN TransactionDate_updated DATE;

UPDATE sales_new
SET TransactionDate_updated = TransactionDate;

-- STEP 3: Remove the previous table
DROP TABLE sales_transaction;

-- STEP 4: Rename the table
RENAME TABLE sales_new TO sales_transaction;

-- STEP 5: Showcase the changes.
SELECT * FROM sales_transaction;

DESC sales_transaction;

/* Exploratory Data Analysis */

-- Problem 5:
/*
Write a SQL query to summarize the total sales and quantities sold per product by the company.

(Here, the data has been already cleaned in the previous steps and from here we will be understanding 
the different types of data analysis from the given dataset.)
Hint:
Use the “Sales_transaction” table.
The resulting table will display the total quantity purchased by the customers and the 
total sales done by the company to evaluate the product performance.
Return the result table in descending order corresponding to Total Sales Column.
*/
SELECT * FROM sales_transaction;
-- PPV - Product  Performance Variability
-- Sum of all the quantity and sales based on the products
SELECT ProductID, SUM(QuantityPurchased) as TotalUnitsSold, SUM(Price * QuantityPurchased) as TotalSales
FROM sales_transaction
GROUP BY ProductID
ORDER BY SUM(Price * QuantityPurchased) DESC;


-- Problem 6:
/*
Write a SQL query to count the number of transactions per customer to understand purchase frequency.
Hint:
Use the “Sales_transaction” table.
The resulting table will be counting the number of transactions corresponding to each customerID.
Return the result table ordered by NumberOfTransactions in descending order.
*/
SELECT CustomerID, COUNT(TransactionID) as NumberofTransactions
FROM Sales_transaction
GROUP BY CustomerID
ORDER BY NumberofTransactions DESC;


-- Problem 7:
/*
Write a SQL query to evaluate the performance of the product categories based on the
 total sales which help us understand the product categories which needs to be promoted 
 in the marketing campaigns.
Hint:
Use the “Sales_transaction” and "product_inventory" table.
The resulting table must display product categories, the aggregated count of 
units sold for each category, and the total sales value per category.
Return the result table ordering by TotalSales in descending order.
*/
SELECT * FROM sales_transaction;
SELECT * FROM product_inventory;

SELECT 
    p.Category,
    SUM(s.QuantityPurchased) AS TotalUnitsSold,
    SUM(s.QuantityPurchased * s.Price) AS TotalSales
FROM sales_transaction s JOIN product_inventory p 
ON p.ProductID = s.ProductID
GROUP BY p.Category
ORDER BY TotalSales DESC;


-- Problem 8:
/*
Write a SQL query to find the top 10 products with the highest total sales revenue 
from the sales transactions. This will help the company to identify the High sales 
products which needs to be focused to increase the revenue of the company
Hint:
Use the “Sales_transaction” table.
The resulting table should be limited to 10 productIDs whose TotalRevenue 
(Product of Price and QuantityPurchased) is the highest.
Return the result table ordering by TotalRevenue in descending order.
*/

SELECT * FROM sales_transaction;

SELECT ProductID, SUM(QuantityPurchased*Price) as TotalRevenue
FROM sales_transaction
GROUP BY ProductID
ORDER BY TotalRevenue DESC
LIMIT 10;


-- Problem 9:
/*
Write a SQL query to find the ten products with the least amount of units 
sold from the sales transactions, provided that at least one unit was sold for those products.
Hint:
Use the “Sales_transaction” table.
The resulting table should be limited to 10 productIDs whose TotalUnitsSold 
(sum of QuantityPurchased) is the least. (The limit value can be adjusted accordingly)
Return the result table ordering by TotalUnitsSold in ascending order.
*/
SELECT * FROM sales_transaction;

SELECT ProductID, SUM(QuantityPurchased) as TotalUnitsSold
FROM sales_transaction
GROUP BY ProductID
HAVING TotalUnitsSold >= 1
ORDER BY TotalUnitsSold 
LIMIT 10;


-- Problem 10:
/*
Write a SQL query to identify the sales trend to understand the revenue pattern of the company.
Hint:
Use the “sales_transaction” table.
The resulting table must have DATETRANS in date format, count the number of transaction 
on that particular date, total units sold and the total sales took place.
Return the result table ordered by datetrans in descending order.
*/
SELECT 
    TransactionDate_updated AS DATETRANS,
    COUNT(*) Transaction_count,
    SUM(QuantityPurchased) AS TotalUnitsSold,
    SUM(QuantityPurchased * Price) AS TotalSales
FROM
    sales_transaction
GROUP BY TransactionDate_updated
ORDER BY TransactionDate_updated DESC;


-- Problem 11: Month on Month Percentage
/*
Write a SQL query to understand the month on month growth rate of sales of the 
company which will help understand the growth trend of the company.
Hint:
Use the “sales_transaction” table.
The resulting table must extract the month from the transactiondate and then the 
Month on month growth percentange should be calculated. 
(Total sales present month - total sales previous month/ total sales previous month * 100)
Return the result table ordering by month.
*/
SELECT * FROM sales_transaction;

WITH monthly_sales AS (
    SELECT 
        MONTH(TransactionDate_updated) AS month,
        SUM(QuantityPurchased * Price) AS total_sales
    FROM 
        sales_transaction
    GROUP BY 
        month
)
SELECT 
    month,
    total_sales, 
    LAG(total_sales) OVER (ORDER BY month) AS previous_month_sales,
   ((total_sales - LAG(total_sales) OVER(ORDER BY month)) / LAG(total_sales) OVER(ORDER BY month)) * 100
   AS mom_growth_percentage
FROM 
    monthly_sales;


-- Problem 12
/*
Write a SQL query that describes the number of transaction along with the total 
amount spent by each customer which are on the higher side and will help us understand 
the customers who are the high frequency purchase customers in the company.
Hint:
Use the “sales_transaction” table.
The resulting table must have number of transactions more than 10 and TotalSpent more 
than 1000 on those transactions by the corresponding customers.
Return the result table on the “TotalSpent” in descending order.
*/
SELECT CustomerID, COUNT(TransactionID) as NumberOfTransactions, 
SUM(QuantityPurchased * Price) as TotalSpent
FROM sales_transaction
GROUP BY CustomerID
HAVING NumberOfTransactions > 10 AND TotalSpent > 1000
ORDER BY TotalSpent DESC;


-- Problem 13:
/*
Write a SQL query that describes the number of transaction along with the total 
amount spent by each customer, which will help us understand the customers who 
are occasional customers or have low purchase frequency in the company.
Hint:
Use the “Sales_transaction” table.
The resulting table must have number of transactions less than or equal to 2 and corresponding total 
amount spent on those transactions by related customers.
Return the result table of “NumberOfTransactions” in ascending order and “TotalSpent” in descending order.
*/
SELECT 
    CustomerID,
    COUNT(*) AS NumberOfTransactions,
    SUM(QuantityPurchased * Price) AS TotalSpent
FROM sales_transaction
GROUP BY CustomerID
HAVING NumberOfTransactions <= 2
ORDER BY NumberOfTransactions , TotalSpent DESC;


-- Problem 14:
/*
Write a SQL query that describes the total number of purchases made by each customer 
against each productID to understand the repeat customers in the company.
Hint:
Use the “Sales_transaction” table.
The resulting table must have "CustomerID", "ProductID" and the number of times that 
particular customer have purchases the product.
The number of times the customer has purchased should be more than once.
Return the result table in descending order corresponding to the TimesPurchased column.
*/
SELECT * FROM customer_profiles;
SELECT * FROM sales_transaction;

SELECT CustomerID, ProductID, COUNT(*) as TimesPurchased
FROM  sales_transaction 
GROUP BY CustomerID, ProductID
HAVING COUNT(*) > 1
ORDER BY TimesPurchased DESC;


-- Problem 15:
/*
Write a SQL query that describes the duration between the first and the 
last purchase of the customer in that particular company to understand 
the loyalty of the customer.
Hints:
Use the "Sales_transaction" table.
The DATE column will be majorly in use in the question and the TransactionDate column in 
Sales_transaction is in text format. Thus, the format of the TransactionDate column should be changed.
The resulting table must have the first date of purchase, the last date of purchase and the 
difference between the first and the last date of purchase.
The difference between the first and the last date of purchase should be more than 0.
Return the table in descending order corresponding to DaysBetweenPurchases.
*/
SELECT * FROM sales_transaction;

-- Approach 1
WITH temp as(
SELECT CustomerID, MIN(TransactionDate_updated)  as FirstPurchase,
MAX(TransactionDate_updated) as LastPurchase
FROM sales_transaction
GROUP BY CustomerID
)
SELECT CustomerID, FirstPurchase, LastPurchase, DATEDIFF(LastPurchase,FirstPurchase) as DaysBetweenPurchases
FROM temp
GROUP BY CustomerID, FirstPurchase, LastPurchase
HAVING DaysBetweenPurchases > 0
ORDER BY DaysBetweenPurchases DESC;

-- Approach 2
WITH temp AS (
    SELECT
        CustomerID,
        FIRST_VALUE(TransactionDate_updated) OVER (PARTITION BY CustomerID ORDER BY TransactionDate_updated ) AS FirstPurchase,
        LAST_VALUE(TransactionDate_updated) OVER (PARTITION BY CustomerID ORDER BY TransactionDate_updated 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS LastPurchase
    FROM sales_transaction
)
SELECT
    CustomerID, FirstPurchase, LastPurchase,
    DATEDIFF(LastPurchase, FirstPurchase) AS DaysBetweenPurchases
FROM temp
GROUP BY CustomerID, FirstPurchase, LastPurchase
HAVING DaysBetweenPurchases > 0
ORDER BY DaysBetweenPurchases DESC;


-- Problem 16:
/*
Write an SQL query that segments customers based on the total quantity of products they have purchased.
Also, count the number of customers in each segment which will help us target a particular 
segment for marketing.
Hint:
Use the customer_profiles and sales_transaction tables.
Create a separate table named customer_segment and create the segments on the total quantity 
of the purchased products.
To segment customers based on their purchasing behavior for targeted marketing campaigns. 
Create Customer segments on the following criteria-

Total Quantity of Products Purchased             Segment
		1-10									  Low
        10-30						 			  Mid
        >30										  High

The resulting table should count the number of customers in different customer segments.
Return the result table in any order.
*/
SELECT * FROM customer_profiles;
SELECT * FROM sales_transaction;

-- APPROACH 1
-- Creating Table
CREATE TABLE customer_segment(
	CustomerID INT,
	CustomerSegment VARCHAR(50)
);

/*
Humme join isiliye use kra h kyu ki hume whi customers chahiye jinki profiles humare pass h 
hum chahte toh bs Sales table use kr skte the but join ka reason tha ki hume only and only
woh customers mile jinki profiles customer_profiles table main mentioned h
*/
-- Insertion in the table
INSERT INTO customer_segment
SELECT c.CustomerID,
CASE
		WHEN SUM(s.QuantityPurchased) >= 1 and SUM(s.QuantityPurchased) < 10 then 'Low'
        WHEN SUM(s.QuantityPurchased) >= 10 and SUM(s.QuantityPurchased) <= 30 then 'Med'
        WHEN SUM(s.QuantityPurchased) > 30  then 'High'
END AS customer_segment
FROM customer_profiles c
JOIN sales_transaction s 
on s.CustomerID = c.CustomerID
GROUP BY c.CustomerID;

-- Final result
SELECT CustomerSegment, COUNT(*)
FROM customer_segment
GROUP BY CustomerSegment;


-- APPROACH 2:
-- Customer Segmentation
CREATE TABLE customer_segment AS 
SELECT CustomerID, 
CASE WHEN TotalQuantity > 30 THEN 'High'
WHEN TotalQuantity BETWEEN 10 AND 30 THEN 'Mid'
WHEN TotalQuantity BETWEEN 1 AND 10 THEN 'Low'
ELSE 'None'
END AS customerSegment
FROM (
SELECT 
    a.CustomerID, 
    SUM(b.QuantityPurchased) AS TotalQuantity
FROM customer_profiles a JOIN sales_transaction b 
ON a.CustomerID = b.CustomerID
GROUP BY a.CustomerID
) AS derived_table;

SELECT * FROM  customer_segment;