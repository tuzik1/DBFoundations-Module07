--*************************************************************************--
-- Title: Assignment07
-- Author: Nicholas Smith
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2024-02-26, Nicholas Smith, Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_NicholasSmith')
	 Begin 
	  Alter Database [Assignment07DB_NicholasSmith] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_NicholasSmith;
	 End
	Create Database Assignment07DB_NicholasSmith;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_NicholasSmith;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

-- Select * From vProducts;

/*
-- Downselecting to display only the appropriate columns.

	SELECT ProductName, UnitPrice
	FROM vProducts;

-- Including a system function to format the UnitPrice column as US Dollars.

	SELECT ProductName, FORMAT(UnitPrice, 'C', 'en-US') AS 'UnitPrice'
	FROM vProducts;

-- Ordering by ProductName.

*/

	SELECT ProductName, FORMAT(UnitPrice, 'C', 'en-US') AS 'UnitPrice'
	FROM vProducts
	ORDER BY ProductName;
	GO

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.

-- Select * From vCategories;
-- Select * From vProducts;
-- CategoryID is the common column.

/*
-- Creating a join, and downselecting to the correct columns.

	SELECT CategoryName, ProductName, UnitPrice
	FROM vCategories AS C
	JOIN vProducts AS P ON C.CategoryID = P.CategoryID

-- Formatting the price as US Dollars.

	SELECT CategoryName, ProductName, FORMAT(UnitPrice, 'C', 'en-US') AS 'UnitPrice'
	FROM vCategories AS C
	JOIN vProducts as P ON C.CategoryID = P.CategoryID

-- Ordering the results by CategoryName and ProductName.

*/

	SELECT CategoryName, ProductName, FORMAT(UnitPrice, 'C', 'en-US') AS 'UnitPrice'
	FROM vCategories AS C
	JOIN vProducts AS P ON C.CategoryID = P.CategoryID
	ORDER BY CategoryName, ProductName;
	GO

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- Select * From vProducts;
-- Select * From vInventories;
-- ProductId is the common column.

/*
--Creating a join, and downselecting to the correct columns.

	SELECT ProductName, InventoryDate, Count
	FROM vProducts AS P
	JOIN vInventories AS I ON P.ProductID = I.ProductID;

-- Ordering the results by ProductName and Date.

	SELECT ProductName, InventoryDate, Count
	FROM vProducts AS P
	JOIN vInventories AS I ON P.ProductID = I.ProductID
	ORDER BY ProductName, InventoryDate;

-- Formatting InventoryDate column.


	SELECT ProductName
	, CONCAT(DATENAME(MONTH, InventoryDate),', ',DATENAME(YEAR, InventoryDate)) AS InventoryDate
	, Count
	FROM vProducts AS P
	JOIN vInventories AS I ON P.ProductID = I.ProductID
	ORDER BY ProductName, InventoryDate;
	GO

-- Issue with the ordering of the InventoryDate column. After some research, I am ordering the resulting string instead of the original date field.
*/

	SELECT ProductName
	, CONCAT(DATENAME(MONTH, InventoryDate),', ',DATENAME(YEAR, InventoryDate)) AS InventoryDate
	, Count
	FROM vProducts AS P
	JOIN vInventories AS I ON P.ProductID = I.ProductID
	ORDER BY ProductName, I.InventoryDate;
	GO

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- Using the code above as the SELECT Statement in my CREATE VIEW Statement.

	CREATE VIEW vProductInventories
	AS
		SELECT TOP 1000000 ProductName
		, CONCAT(DATENAME(MONTH, InventoryDate),', ',DATENAME(YEAR, InventoryDate)) AS InventoryDate
		, Count AS InventoryCount
		FROM vProducts AS P
		JOIN vInventories AS I ON P.ProductID = I.ProductID
		ORDER BY ProductName, I.InventoryDate;
	GO

-- Check that it works: Select * From vProductInventories;

	SELECT * FROM vProductInventories;
	GO

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- SELECT * FROM vCategories;
-- SELECT * FROM vProducts;
-- SELECT * FROM vInventories;

/*
-- Creating a two part join to tie the three tables together.

	SELECT CategoryName, InventoryDate, Count
	FROM vCategories AS C
	JOIN vProducts AS P ON C.CategoryID = P.CategoryID
	JOIN vInventories AS I ON P.ProductID = I.ProductID;

-- Summing the Inventory Count and adding an Alias. Ordering by CategoryName and Date.

	SELECT CategoryName, InventoryDate, SUM(Count) AS InventoryCountByCategory
	FROM vCategories AS C
	JOIN vProducts AS P ON C.CategoryID = P.CategoryID
	JOIN vInventories AS I ON P.ProductID = I.ProductID
	GROUP BY CategoryName, InventoryDate
	ORDER BY CategoryName, I.InventoryDate;

-- Formatting the Date column.

	SELECT CategoryName
	, CONCAT(DATENAME(MONTH, InventoryDate),', ',DATENAME(YEAR, InventoryDate)) AS InventoryDate
	, SUM(Count) AS InventoryCountByCategory
	FROM vCategories AS C
	JOIN vProducts AS P ON C.CategoryID = P.CategoryID
	JOIN vInventories AS I ON P.ProductID = I.ProductID
	GROUP BY CategoryName, InventoryDate
	ORDER BY CategoryName, I.InventoryDate;

-- Creating view

*/
	CREATE VIEW vCategoryInventories
	AS
		SELECT TOP 1000000 CategoryName
		, CONCAT(DATENAME(MONTH, InventoryDate),', ',DATENAME(YEAR, InventoryDate)) AS InventoryDate
		, SUM(Count) AS InventoryCountByCategory
		FROM vCategories AS C
		JOIN vProducts AS P ON C.CategoryID = P.CategoryID
		JOIN vInventories AS I ON P.ProductID = I.ProductID
		GROUP BY CategoryName, InventoryDate
		ORDER BY CategoryName, I.InventoryDate;
	GO

-- Check that it works: Select * From vCategoryInventories;

	SELECT * FROM vCategoryInventories;
	GO

-- Question 6 (15% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

-- This will require a join between the vProducts view and the vInventories view to get the right columns.
-- This will require a LAG function in order to get the previous month's count.

/*

-- Beginning with code from question 4.

		SELECT TOP 1000000 ProductName
		, CONCAT(DATENAME(MONTH, InventoryDate),', ',DATENAME(YEAR, InventoryDate)) AS InventoryDate
		, Count
		-- LAG FUNCTION HERE
		FROM vProducts AS P
		JOIN vInventories AS I ON P.ProductID = I.ProductID
		ORDER BY ProductName, I.InventoryDate;


-- Adding LAG FUNCTION code. Adding Alias to Count. 
-- Lag function treats the NULL values for January with the last argument "default" (scalar_expression [, offset] [, default]).
-- The default argument instructs the code on how to treat NULL values that are out of scope of the Partition.

		SELECT TOP 1000000 ProductName
		, CONCAT(DATENAME(MONTH, InventoryDate),', ',DATENAME(YEAR, InventoryDate)) AS InventoryDate
		, Count AS InventoryCount
		, LAG(Count, 1, 0) OVER (PARTITION BY P.ProductName ORDER BY (I.InventoryDate)) AS PreviousMonthCount
		FROM vProducts AS P
		JOIN vInventories AS I ON P.ProductID = I.ProductID
		ORDER BY ProductName, I.InventoryDate;

-- Creating View. Need to convert data type for InventoryDate in the ORDER BY clause because we lost our ALIAS from question 4.

*/

	CREATE VIEW vProductInventoriesWithPreviouMonthCounts
	AS
		SELECT TOP 1000000 ProductName
		, InventoryDate
		, InventoryCount
		, [PreviousMonthCount] = IIF(MONTH(InventoryDate) = 1, 0, LAG(InventoryCount) OVER (PARTITION BY ProductName ORDER BY MONTH(InventoryDate)))
		FROM vProductInventories
		ORDER BY ProductName, CONVERT(DATE, InventoryDate);
	GO

-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;

	SELECT * 
	FROM vProductInventoriesWithPreviouMonthCounts;
	GO

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

-- Starting with question 6 code as a baseline.

/*
		SELECT TOP 1000000 ProductName
		, InventoryDate
		, InventoryCount
		, [PreviousMonthCount] = IIF(MONTH(InventoryDate) = 1, 0, LAG(InventoryCount) OVER (PARTITION BY ProductName ORDER BY MONTH(InventoryDate)))
		FROM vProductInventories
		ORDER BY ProductName, CONVERT(DATE, InventoryDate);
		

-- Adjusting FROM clause. Adding a KPI Column. This will require a CASE clause in the SELECT statement.

		SELECT TOP 1000000 ProductName
		, InventoryDate
		, InventoryCount
		, PreviousMonthCount
		, [CountVsPreviousCountKPI] = CASE
			WHEN InventoryCount > PreviousMonthCount THEN 1
			WHEN InventoryCount = PreviousMonthCount THEN 0
			WHEN InventoryCount < PreviousMonthCount THEN -1
			END
		FROM vProductInventoriesWithPreviouMonthCounts
		ORDER BY ProductName, CONVERT(DATE, InventoryDate);

-- Adding CREATE view.

*/

	CREATE VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs
	AS
		SELECT TOP 1000000 ProductName
		, InventoryDate
		, InventoryCount
		, PreviousMonthCount
		, [CountVsPreviousCountKPI] = CASE
			WHEN InventoryCount > PreviousMonthCount THEN 1
			WHEN InventoryCount = PreviousMonthCount THEN 0
			WHEN InventoryCount < PreviousMonthCount THEN -1
			END
		FROM vProductInventoriesWithPreviouMonthCounts
		ORDER BY ProductName, CONVERT(DATE, InventoryDate);
	GO

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;

	SELECT *
	FROM vProductInventoriesWithPreviousMonthCountsWithKPIs;
	GO

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

-- Creating UDF, referring to Module 6 notes regarding functions with parameters.

/*
-- Teseting code to see if I can return one of the desired tables.

		SELECT ProductName, InventoryDate, InventoryCount, PreviousMonthCount, CountVsPreviousCountKPI
		FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
		WHERE CountVsPreviousCountKPI = 1
		ORDER BY ProductName, CONVERT(DATE, InventoryDate);
	
-- Rewriting code to accommodate UDF, including all elements of defining a function and parameters.
*/

	CREATE FUNCTION fProductInventoriesWithPreviousMonthCountsWithKPIs(@CountVsPreviousCountKPI int)
	RETURNS TABLE
	AS
		RETURN(
			SELECT TOP 1000000 ProductName, InventoryDate, InventoryCount, PreviousMonthCount, CountVsPreviousCountKPI
			FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
			WHERE CountVsPreviousCountKPI = @CountVsPreviousCountKPI
			ORDER BY ProductName, CONVERT(DATE, InventoryDate)
			);
	GO

-- Check that it works:

	SELECT * FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
	SELECT * FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
	SELECT * FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
	GO


/***************************************************************************************/