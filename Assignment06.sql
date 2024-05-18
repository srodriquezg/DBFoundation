--*************************************************************************--
-- Title: Assignment06
-- Author: SRodriguez
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,SRodriguez,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_SRodriguez')
	 Begin 
	  Alter Database [Assignment06DB_SRodriguez] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_SRodriguez;
	 End
	Create Database Assignment06DB_SRodriguez;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_SRodriguez;

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
,[UnitPrice] [mOney] NOT NULL
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
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
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
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BASIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
Go
Create View vCategories
As
Select C.CategoryName
From Categories as C
Go
Select * From [dbo].[vCategories] 
Go

Go
Create View vProducts
As
Select P.ProductName
From Products as P
Go 
Select * From [dbo].[vProducts]

Go
Create View vInventories
As
Select I.InventoryDate
From Inventories as I
Go 
Select * From [dbo].[vInventories]

Go
Create View vEmployees
As
Select E.EmployeeFirstName
From Employees as E
Go
Select * From [dbo].[vEmployees]



-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
--By using Vertical partitioning, choosing certain columns, to show some of the columns to the public vs private role in a database.
-- This would be only one table but will have two Select statements Deny vs Grant.
-- I can define the private role as a specific group, such as HR group to be able to view the private information.


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

/*Select 
C.CategoryName
,P.ProductName
,P.UnitPrice
From Categories as C
Inner Join Products as P
 On C.CategoryID = P.CategoryID
Order By 1,2,3;
*/
Go
Create View vProductsByCategories
As
	Select 
	 C.CategoryName
	 ,P.ProductName
	 ,P.UnitPrice
	From Categories as C
	Inner Join Products as P
	 On C.CategoryID = P.CategoryID
Go
Select * From [dbo].[vProductsByCategories] Order By 1,2,3;

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
/*
Select
P.ProductName
,I.[Count]
,I.InventoryDate
From Products as P
Inner Join Inventories as I
On P.ProductID = I.ProductID
Go
*/
Go
Create View vInventoriesByProductsByDates
As
	Select
	P.ProductName
	,I.[Count]
	,I.InventoryDate
	From Products as P
	Inner Join Inventories as I
	On P.ProductID = I.ProductID
Go
Select * From [dbo].[vInventoriesByProductsByDates] Order By 1,3,2; 

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

/*
Select Distinct
I.InventoryDate
,E.EmployeeFirstName + ' ' + E.EmployeeLastname as Employee
From Inventories as I
Inner Join Employees as E
On I.EmployeeID = E.EmployeeID
*/
Go
Create View vInventoriesByEmployeesByDates
As
	Select Distinct
	I.InventoryDate
	,E.EmployeeFirstName + ' ' + E.EmployeeLastname as Employee
	From Inventories as I
	Inner Join Employees as E
	On I.EmployeeID = E.EmployeeID
Go
Select * From [dbo].[vInventoriesByEmployeesByDates] Order By 1,2;

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
/*
Select
C.CategoryName
,P.ProductName
,I.InventoryDate
,I.[Count]
From
Inventories as I
Inner Join Products as P
On I.ProductID = P.ProductID
Inner Join Categories as C
On P.CategoryID = C.CategoryID
*/
Go
Create View [vInventoriesByProductsByCategories]
As
	Select
	C.CategoryName
	,P.ProductName
	,I.InventoryDate
	,I.[Count]
	From
	Inventories as I
	Inner Join Products as P
	On I.ProductID = P.ProductID
	Inner Join Categories as C
	On P.CategoryID = C.CategoryID
Go
Select * From [dbo].[vInventoriesByProductsByCategories] Order By 1,2,3,4;


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

/*
Select
C.Categoryname
,P.ProductName
,I.InventoryDate
,I.[Count]
,E.EmployeeFirstName +' '+ E.EmployeeLastName as EmployeeName
From
Inventories as I
Inner Join Employees as E
On I.EmployeeID = E.EmployeeID
Inner Join Products as P
On I.ProductID = P.ProductID
Inner Join Categories as C
On P.CategoryID = C.CategoryID
Order By 3,1,2,4;
*/
Go
Create View vInventoriesByProductsByEmployees
As
	Select
	C.Categoryname
	,P.ProductName
	,I.InventoryDate
	,I.[Count]
	,E.EmployeeFirstName +' '+ E.EmployeeLastName as EmployeeName
	From
	Inventories as I
	Inner Join Employees as E
	On I.EmployeeID = E.EmployeeID
	Inner Join Products as P
	On I.ProductID = P.ProductID
	Inner Join Categories as C
	On P.CategoryID = C.CategoryID
Go
Select * From [dbo].[vInventoriesByProductsByEmployees] Order By 3,1,2,4;


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
/*
Select
C.CategoryName
,P.ProductName
,I.InventoryDate
,I.[Count]
,E.EmployeeFirstName +' ' + E.EmployeeLastName as EmployeeName
From
Inventories as I
Inner Join Employees as E
On I.EmployeeID = E.EmployeeID
Inner Join Products as P
On I.ProductID = P.ProductID
Inner Join Categories as C
On P.CategoryID = C.CategoryID
Where I.ProductID in (Select ProductID From Products Where ProductName In ('Chai', 'Chang'))
*/
Go
Create View vInventoriesForChaiAndChangByEmployees
As
	Select
	C.CategoryName
	,P.ProductName
	,I.InventoryDate
	,I.[Count]
	,E.EmployeeFirstName +' ' + E.EmployeeLastName as EmployeeName
	From
	Inventories as I
	Inner Join Employees as E
	On I.EmployeeID = E.EmployeeID
	Inner Join Products as P
	On I.ProductID = P.ProductID
	Inner Join Categories as C
	On P.CategoryID = C.CategoryID
	Where I.ProductID in (Select ProductID From Products Where ProductName In ('Chai', 'Chang'))
Go
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
/*
Select
E.EmployeeFirstName +' '+ E.EmployeeLastName as EmployeeName
,M.EmployeeFirstName +' '+ M.EmployeeLastName as Manager
From Employees as E
Inner Join Employees as M
On E.ManagerID = M.EmployeeID
Order By 2,1;
*/
Go
Create View vEmployeesByManager
As
Select
E.EmployeeFirstName +' '+ E.EmployeeLastName as EmployeeName
,M.EmployeeFirstName +' '+ M.EmployeeLastName as Manager
From Employees as E
Inner Join Employees as M
On E.ManagerID = M.EmployeeID
Go
Select * From [dbo].[vEmployeesByManager] Order By 2,1;

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
Go
Create View vInventoriesByProductsByCategoriesByEmployees
As
	Select 
	C.CategoryID
	,C.CategoryName
	,P.ProductID
	,P.ProductName
	,P.UnitPrice
	,I.InventoryID
	,I.InventoryDate
	,I.[Count]
	,E.EmployeeID
	,E.EmployeeFirstName +' '+ E.EmployeeLastName as EmployeeName
	,M.EmployeeFirstName +' '+ M.EmployeeLastName as Manager
	From
	Inventories as I
		Inner Join Employees as E
		On I.EmployeeID = E.EmployeeID
		Inner Join Products as P
		On I.ProductID = P.ProductID
		Inner Join Categories as C
		On P.CategoryID = C.CategoryID
		Inner Join Employees as M
		On E.ManagerID = M.EmployeeID
		Go

Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]


-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/