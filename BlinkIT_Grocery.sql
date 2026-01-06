-->Loading BlinkIT Data:
SELECT *
FROM BlinkIT


-->CLEANING [BlinkIT] DATA:
---Updating the Item_Fat_Content Column (e.g. LF, low fat Vs Low Fat)---
UPDATE BlinkIT
SET Item_Fat_Content =
	CASE
			WHEN Item_Fat_Content IN ('LF', 'low fat') THEN 'Low Fat'
			WHEN Item_Fat_Content = 'reg' THEN 'Regular'
			ELSE Item_Fat_Content
	END;
SELECT DISTINCT(Item_Fat_Content) FROM BlinkIT;

SELECT * FROM BlinkIT;


-->KPI Requirements:
--Total Revenue generated from all items sold:
SELECT 
	CAST(SUM(Total_Sales)/1000000 AS decimal(10,2)) AS Total_Sales(million)
FROM BlinkIT;


--The Average Revenue per Sale:
SELECT
	CAST(AVG(Total_Sales) AS INT) AS Average_Sales
FROM BlinkIT;


--Number of Items:
SELECT 
	COUNT(*) AS Number_of_Items
FROM BlinkIT;


--Average Rating for all items sold:
SELECT
	CAST(AVG(Rating) AS decimal(10,1)) AS Average_Rating
FROM BlinkIT;


--> Grandular Requirements
--Total Sales by Fat Content
SELECT 
	Item_Fat_Content as "Item Fat Content",
	CAST(SUM(Total_Sales) AS decimal(10,2)) AS "Total Sales"
FROM BlinkIT
GROUP BY Item_Fat_Content;


--Total Sales by Item Type;
SELECT 
	Item_Type as "Item Type",
	CAST(SUM(Total_Sales) AS decimal(10,2)) AS "Total Sales"
FROM BlinkIT
GROUP BY Item_Type;


SELECT * FROM BlinkIT;


--Fat Content by Outlet for Total Sales
SELECT 
	Outlet_Location_Type as "Outlet Location", 
    ISNULL([Low Fat], 0) AS "Low Fat", 
    ISNULL([Regular], 0) AS Regular
FROM (
   SELECT 
	Outlet_Location_Type, Item_Fat_Content, 
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
   FROM BlinkIT
   GROUP BY Outlet_Location_Type, Item_Fat_Content) AS SourceTable
PIVOT (
    SUM(Total_Sales) 
    FOR Item_Fat_Content IN ([Low Fat], [Regular])) AS PivotTable
ORDER BY Outlet_Location_Type;


--Creating View for [Fat Content by Outlet for Total Sales];
CREATE VIEW Fat_Content_by_Outlet_for_Total_Sales AS
	SELECT 
	Outlet_Location_Type, 
    ISNULL([Low Fat], 0) AS "Low Fat", 
    ISNULL([Regular], 0) AS Regular
FROM (
   SELECT 
	Outlet_Location_Type, Item_Fat_Content, 
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
   FROM BlinkIT
   GROUP BY Outlet_Location_Type, Item_Fat_Content) AS SourceTable
PIVOT (
    SUM(Total_Sales) 
    FOR Item_Fat_Content IN ([Low Fat], [Regular])) AS PivotTable


--Total Sales by Outlet Type:
SELECT 
	Outlet_Establishment_Year as "Outlet Establishment Year",
	CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS "Total Sales"
FROM BlinkIT
GROUP BY Outlet_Establishment_Year
ORDER BY Outlet_Establishment_Year;


-- Sale Percentages by Outlet Size:
SELECT
	Outlet_Size as "Outlet Size",
	CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS "Total Sales",
	CAST((SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER()) AS DECIMAL(10,2)) AS "Sales Percentage"
FROM BlinkIT
GROUP BY Outlet_Size
ORDER BY [Total Sales] DESC;


--Total Number of Outlets by Size:
SELECT
	Outlet_Size "Outlet Size",
	COUNT(Outlet_Size) AS "Total Number"
FROM BlinkIT
GROUP BY Outlet_Size
ORDER BY [Total Number] DESC;


--Sales by Outlet Location Type:
SELECT
	Outlet_Location_Type "Outlet Location Type",
	CAST(SUM(Total_Sales) AS decimal(10,2)) AS "Total Sales"
FROM BlinkIT
GROUP BY Outlet_Location_Type
ORDER BY [Total Sales] DESC;


--All Metrics by Outlet Type:
SELECT
	Outlet_Type AS "Outlet Type",
	CAST(SUM(Total_Sales) AS decimal(10,2)) AS "Total Sales",
	CAST(AVG(Rating) AS DECIMAL(10,2)) AS "Average Sales",
	COUNT(*) AS "Number of Items",
	ROUND(AVG(Rating), 2) AS "Average Rating",
	CAST(AVG(Item_Visibility) AS DECIMAL(10,2)) AS " Average Item Visibility"
FROM BlinkIT
GROUP BY Outlet_Type
ORDER BY [Total Sales] DESC;


