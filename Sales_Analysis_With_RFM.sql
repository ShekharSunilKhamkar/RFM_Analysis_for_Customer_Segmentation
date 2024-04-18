CREATE DATABASE Project;
USE Project;

-- get a review of the dataset
select * from sales_data;

-- show the unique values of some parameters of the dataset
SELECT DISTINCT ORDERNUMBER FROM sales_data; -- Total Order numbers = 307
SELECT DISTINCT STATUS FROM sales_data; -- Total Statuses = 6
SELECT DISTINCT YEAR_ID FROM sales_data; -- Total Year IDs = 3
SELECT DISTINCT PRODUCTLINE FROM sales_data; -- Total Productlines = 7
SELECT DISTINCT CUSTOMERNAME FROM sales_data; -- Total Customer names = 92
SELECT DISTINCT COUNTRY FROM sales_data; -- Total Countries = 19
SELECT DISTINCT TERRITORY FROM sales_data; -- Total Territories = 4 
SELECT DISTINCT DEALSIZE FROM sales_data; -- Total Dealsizes = 3

-- ANALYSIS OF THE DATASET
-- Grouping sales by productline
SELECT PRODUCTLINE, sum(sales) AS REVENUE
FROM sales_data
GROUP BY PRODUCTLINE
ORDER BY 2 DESC;

-- sales of the productline by year 
SELECT YEAR_ID, sum(sales) AS REVENUE
FROM sales_data
GROUP BY YEAR_ID
ORDER BY 2 DESC; -- in the year of 2004 the sales of the products were maximum

-- sales of the productline by dealsize
SELECT  DEALSIZE,  sum(sales)  AS REVENUE
FROM sales_data
GROUP BY  DEALSIZE
ORDER BY 2 DESC; -- the medium type of dealsizes have generated the maximum sales


-- THE MONTH IN EVERY YEAR WITH THE MAXIMUM SALES
-- year 2003
SELECT MONTH_ID, sum(sales) AS REVENUE, count(ORDERNUMBER) AS ORDER_FREQUENCY
FROM sales_data
WHERE YEAR_ID = 2003
GROUP BY MONTH_ID
ORDER BY 2 DESC;

-- year 2004
SELECT MONTH_ID, sum(sales) AS REVENUE, count(ORDERNUMBER) AS ORDER_FREQUENCY
FROM sales_data
WHERE YEAR_ID = 2004
GROUP BY MONTH_ID
ORDER BY 2 DESC;

-- year 2005
SELECT MONTH_ID, sum(sales) AS REVENUE, count(ORDERNUMBER) AS ORDER_FREQUENCY
FROM sales_data
WHERE YEAR_ID = 2005
GROUP BY MONTH_ID
ORDER BY 2 DESC;

-- in both 2003 and 2004, the month of November has come on top as the month of maximum sales and it was May in 2005.
-- the product which has got maximum sales in the month of november
-- year 2003
SELECT MONTH_ID, PRODUCTLINE, sum(sales) AS REVENUE, count(ORDERNUMBER) AS ORDER_FREQUENCY
FROM sales_data
WHERE YEAR_ID = 2003 AND MONTH_ID = 11   
GROUP BY MONTH_ID, PRODUCTLINE
ORDER BY 3 DESC;

-- year 2004
SELECT MONTH_ID, PRODUCTLINE, sum(sales) AS REVENUE, count(ORDERNUMBER) AS ORDER_FREQUENCY
FROM sales_data
WHERE YEAR_ID = 2004 AND MONTH_ID = 11   
GROUP BY MONTH_ID, PRODUCTLINE
ORDER BY 3 DESC;
-- in both 2003 and 2004, Classic cars has been the highest selling product in the month of November.

-- The best customers who have purchased recently, frequently and who spent the most.
WITH RFM_ANALYSIS AS 
(
	SELECT 
		CUSTOMERNAME, 
		sum(sales) AS MonetaryValue,
		AVG(sales) AS AvgMonetaryValue,
		count(ORDERNUMBER) AS Frequency,
		max(ORDERDATE) AS LastOrderDate,
		(SELECT max(ORDERDATE) FROM sales_data AS MaxOrderDate,
		DATEDIFF(DD, max(ORDERDATE), (SELECT max(ORDERDATE) FROM sales_data)) AS Recency
	    FROM sales_data
	GROUP BY CUSTOMERNAME
),

RFM_CALC AS 
(
	SELECT *,
		NTILE(4) OVER(ORDER BY Recency DESC) AS RFM_Recency, -- The more recency value indicates slipping Customers.
		NTILE(4) OVER(ORDER BY Frequency) AS RFM_Frequency,
		NTILE(4) OVER(ORDER BY MonetaryValue) AS RFM_Monetary
		FROM RFM_ANALYSIS
)

SELECT *, 
	RFM_Recency + RFM_Frequency + RFM_Monetary AS RFM_Cell, -- summation of values
FROM RFM_CALC;

SELECT * FROM RFM_ANALYSIS;

SELECT CUSTOMERNAME, RFM_Recency, RFM_Frequency, RFM_Monetary,
	CASE
		WHEN RFM_total BETWEEN 3 AND 5 THEN 'Lost Customers' -- Customers who havent bought anything
		WHEN RFM_total BETWEEN 6 AND 7 THEN 'Slipping customers' -- Big customers/buyers havent bought lately
		WHEN RFM_total = 8 THEN 'New Customers' -- Customers who purchased for the first time recently
		WHEN RFM_total = 9 OR RFM_total > 9 THEN 'Active' -- Customers who buy often & have bought recently
	END RFM_SEGMENT
FROM RFM_ANALYSIS;