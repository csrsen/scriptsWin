USE AdventureWorks
GO

IF OBJECT_ID('dbo.demoCustomer','U') IS NOT NULL BEGIN
    DROP TABLE dbo.demoCustomer;
END;
CREATE TABLE dbo.demoCustomer(CustomerID INT NOT NULL,
    FirstName NVARCHAR(50) NOT NULL, MiddleName NVARCHAR(50) NULL,
    LastName NVARCHAR(50) NOT NULL
    CONSTRAINT PK_demoCustomer PRIMARY KEY (CustomerID));

--1
INSERT INTO dbo.demoCustomer (CustomerID, FirstName, MiddleName, LastName)
VALUES (1, N'Orlando', N'N.', N'Gee');

--2
INSERT INTO dbo.demoCustomer (CustomerID, FirstName, MiddleName, LastName)
SELECT 3, N'Donna', N'F.', N'Cameras';

--3
INSERT INTO dbo.demoCustomer
VALUES (4,N'Janet', N'M.', N'Gates');

--4
INSERT INTO dbo.demoCustomer
SELECT 6,N'Rosmarie', N'J.', N'Carroll';

--5
INSERT INTO dbo.demoCustomer (CustomerID, FirstName, MiddleName, LastName)
VALUES (2, N'Keith', NULL, N'Harris');

--6
INSERT INTO dbo.demoCustomer (CustomerID, FirstName, LastName)
VALUES (5, N'Lucy', N'Harrington');

--7
SELECT CustomerID, FirstName, MiddleName, LastName
FROM dbo.demoCustomer;


--Inserting Multiple Rows with One INSERT

--1
INSERT INTO dbo.demoCustomer (CustomerID, FirstName, MiddleName, LastName)
SELECT 7, N'Dominic', N'P.', N'Gash'
UNION ALL
SELECT 10, N'Kathleen', N'M.', N'Garza'
UNION ALL
SELECT 11, N'Katherine', NULL, N'Harding';

--2
INSERT INTO dbo.demoCustomer (CustomerID, FirstName, MiddleName, LastName)
VALUES (12, N'Johnny', N'A.', N'Capino'),
       (16, N'Christopher', N'R.', N'Beck'),
       (18, N'David', N'J.', N'Liu');

--3
SELECT CustomerID, FirstName, MiddleName, LastName
FROM dbo.demoCustomer
WHERE CustomerID >=7;

--Inserting Rows from Another Table

--1
INSERT INTO dbo.demoCustomer (CustomerID, FirstName, MiddleName, LastName)
SELECT BusinessEntityID, FirstName, MiddleName, LastName
FROM Person.Person
WHERE BusinessEntityID BETWEEN 19 AND 35;

--2
INSERT INTO dbo.demoCustomer (CustomerID, FirstName, MiddleName, LastName)
SELECT DISTINCT s.SalesOrderID, c.FirstName, c.MiddleName, c.LastName
FROM Person.Person AS c
INNER JOIN Sales.SalesOrderHeader AS s ON c.BusinessEntityID = s.SalesPersonID;

--3
SELECT CustomerID, FirstName, MiddleName, LastName
FROM dbo.demoCustomer
WHERE CustomerID > 18;

 --Inserting Missing Rows

--1
SELECT COUNT(CustomerID) AS CustomerCount
FROM dbo.demoCustomer;

--2
INSERT INTO dbo.demoCustomer (CustomerID, FirstName, MiddleName, LastName)
SELECT c.BusinessEntityID, c.FirstName, c.MiddleName, c.LastName
FROM Person.Person AS c
WHERE NOT EXISTS (
    SELECT * FROM dbo.demoCustomer a
    WHERE a.CustomerID = c.BusinessEntityID);

--3
SELECT COUNT(CustomerID) AS CustomerCount
FROM dbo.demoCustomer;

--Using SELECT INTO to Create and Populate a Table

IF EXISTS (SELECT * FROM sys.objects
            WHERE object_id = OBJECT_ID(N'[dbo].[demoCustomer]')
                AND type in (N'U'))
DROP TABLE dbo.demoCustomer;

GO

--1
SELECT BusinessEntityID, FirstName, MiddleName, LastName,
    FirstName + ISNULL(' ' + MiddleName,'') + ' ' +  LastName AS FullName
INTO dbo.demoCustomer
FROM Person.Person;

--2
SELECT BusinessEntityID, FirstName, MiddleName, LastName, FullName
FROM dbo.demoCustomer;

--Inserting Data with a Column Default Constraint

IF  EXISTS (SELECT * FROM sys.objects
            WHERE object_id = OBJECT_ID(N'[dbo].[demoDefault]')
               AND type in (N'U'))
DROP TABLE dbo.demoDefault;
GO

CREATE TABLE dbo.demoDefault(
    KeyColumn int NOT NULL PRIMARY KEY,
    HasADefault1 DATETIME2 (1) NOT NULL,
    HasADefault2 NVARCHAR (50) NULL,
);
GO
ALTER TABLE dbo.demoDefault ADD  CONSTRAINT DF_demoDefault_HasADefault
    DEFAULT (GETDATE()) FOR HasADefault1;
GO
ALTER TABLE dbo.demoDefault ADD  CONSTRAINT DF_demoDefault_HasADefault2
    DEFAULT ('the default') FOR HasADefault2;
GO

--1
INSERT INTO dbo.demoDefault(HasADefault1, HasADefault2, KeyColumn)
VALUES ('2009-04-24', N'Test 1', 1),('2009-10-1', NULL, 2);

--2
INSERT INTO dbo.demoDefault (HasADefault1, HasADefault2, KeyColumn)
VALUES (DEFAULT, DEFAULT, 3), (DEFAULT, DEFAULT, 4);

--3
INSERT INTO dbo.demoDefault (KeyColumn)
VALUES (5),(6);

--4
SELECT HasADefault1,HasADefault2,KeyColumn
FROM dbo.demoDefault;

--Inserting Rows into Tables with Autopopulated Columns

IF  EXISTS (SELECT * FROM sys.objects
            WHERE object_id = OBJECT_ID(N'[dbo].[demoAutoPopulate]')
                AND type in (N'U'))
DROP TABLE [dbo].[demoAutoPopulate];

CREATE TABLE [dbo].[demoAutoPopulate](
     [RegularColumn] [NVARCHAR](50) NOT NULL PRIMARY KEY,
     [IdentityColumn] [INT] IDENTITY(1,1) NOT NULL,
     [RowversionColumn] [ROWVERSION] NOT NULL,
     [ComputedColumn] AS ([RegularColumn]+CONVERT([NVARCHAR],
     [IdentityColumn],(0))) PERSISTED);
GO

--1
INSERT INTO dbo.demoAutoPopulate (RegularColumn)
VALUES (N'a'), (N'b'), (N'c');

--2
SELECT RegularColumn, IdentityColumn, RowversionColumn, ComputedColumn
FROM demoAutoPopulate;


--Creating Demo Tables

IF  EXISTS (SELECT * FROM sys.objects
            WHERE object_id = OBJECT_ID(N'[dbo].[demoProduct]')
               AND type in (N'U'))
DROP TABLE [dbo].[demoProduct];
GO

SELECT * INTO dbo.demoProduct FROM Production.Product;

IF  EXISTS (SELECT * FROM sys.objects
            WHERE object_id = OBJECT_ID(N'[dbo].[demoCustomer]')
               AND type in (N'U'))
DROP TABLE [dbo].[demoCustomer];
GO

SELECT C.*, LastName, FirstName INTO dbo.demoCustomer
FROM Sales.Customer AS C
JOIN Person.Person AS P ON C.CustomerID = P.BusinessEntityID;

IF  EXISTS (SELECT * FROM sys.objects
            WHERE object_id = OBJECT_ID(N'[dbo].[demoAddress]')
               AND type in (N'U'))
DROP TABLE [dbo].[demoAddress];
GO

SELECT * INTO dbo.demoAddress FROM Person.Address;

IF  EXISTS (SELECT * FROM sys.objects
            WHERE object_id = OBJECT_ID(N'[dbo].[demoSalesOrderHeader]')
               AND type in (N'U'))
DROP TABLE [dbo].[demoSalesOrderHeader];
GO

SELECT * INTO dbo.demoSalesOrderHeader FROM Sales.SalesOrderHeader;

IF  EXISTS (SELECT * FROM sys.objects
            WHERE object_id = OBJECT_ID(N'[dbo].[demoSalesOrderDetail]')
               AND type in (N'U'))
DROP TABLE [dbo].[demoSalesOrderDetail];
GO

SELECT * INTO dbo.demoSalesOrderDetail FROM Sales.SalesOrderDetail;

--Deleting Rows from Tables

--1
SELECT CustomerID
FROM dbo.demoCustomer;

--2
DELETE dbo.demoCustomer;

--3
SELECT CustomerID
FROM dbo.demoCustomer;

--4
SELECT ProductID
FROM dbo.demoProduct
WHERE ProductID > 900;

--5
DELETE dbo.demoProduct
WHERE ProductID > 900;

--6
SELECT ProductID
FROM dbo.demoProduct
WHERE ProductID > 900;

--Deleting When Using EXISTS

--1
SELECT d.SalesOrderID, SalesOrderNumber
FROM dbo.demoSalesOrderDetail AS d
INNER JOIN dbo.demoSalesOrderHeader AS h ON d.SalesOrderID = h.SalesOrderID
WHERE h.SalesOrderNumber = 'SO71797'

--2
DELETE d
FROM dbo.demoSalesOrderDetail AS d
WHERE EXISTS(
    SELECT *
        FROM dbo.demoSalesOrderHeader AS h
        WHERE h.SalesOrderNumber = 'SO71797'
            AND d.SalesOrderID = h.SalesOrderID);

--3
SELECT d.SalesOrderID, SalesOrderNumber
FROM dbo.demoSalesOrderDetail AS d
INNER JOIN dbo.demoSalesOrderHeader AS h ON d.SalesOrderID = h.SalesOrderID
WHERE h.SalesOrderNumber = 'SO71797'

--4
SELECT SalesOrderID, ProductID
FROM dbo.demoSalesOrderDetail AS SOD
WHERE NOT EXISTS
    (SELECT *
         FROM dbo.demoProduct AS P
         WHERE P.ProductID = SOD.ProductID);
--5
DELETE SOD
FROM dbo.demoSalesOrderDetail AS SOD
WHERE NOT EXISTS
    (SELECT *
         FROM dbo.demoProduct AS P
         WHERE P.ProductID = SOD.ProductID);

--6
SELECT SalesOrderID, ProductID
FROM dbo.demoSalesOrderDetail
WHERE ProductID NOT IN
    (SELECT ProductID FROM dbo.demoProduct AS P
        WHERE P.ProductID  IS NOT NULL);


--Truncating Tables

--1
SELECT SalesOrderID, OrderDate
FROM dbo.demoSalesOrderHeader;

--2
TRUNCATE TABLE dbo.demoSalesOrderHeader;

--3
SELECT SalesOrderID, OrderDate
FROM dbo.demoSalesOrderHeader;


--Updating Data in a Table

IF  EXISTS (SELECT * FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[dbo].[demoPerson]')
    AND type in (N'U'))
DROP TABLE [dbo].[demoPerson];
GO

SELECT *, ' ' Gender INTO dbo.demoPerson
FROM Person.Person
WHERE Title in ('Mr.', 'Mrs.', 'Ms.');

--1
SELECT BusinessEntityID, Title, Gender
FROM dbo.demoPerson
ORDER BY BusinessEntityID;

--2
UPDATE dbo.demoPerson
SET Gender = CASE WHEN Title = 'Mr.' THEN 'M' ELSE 'F' END;

--3
SELECT BusinessEntityID, Title, Gender
FROM dbo.demoPerson
ORDER BY BusinessEntityID;

--Update with Expressions, Columns, or Data from Another Table

IF  EXISTS (SELECT * FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[dbo].[demoPersonStore]')
    AND type in (N'U'))
DROP TABLE [dbo].[demoPersonStore];
GO

CREATE TABLE [dbo].[demoPersonStore] (
[FirstName] [NVARCHAR] (60),
[LastName] [NVARCHAR] (60),
[CompanyName] [NVARCHAR] (60)
);

INSERT INTO dbo.demoPersonStore (FirstName, LastName, CompanyName)
SELECT a.FirstName, a.LastName, c.Name
FROM Person.Person a
JOIN Sales.SalesPerson b
ON a.BusinessEntityID = b.BusinessEntityID
JOIN Sales.Store c
ON b.BusinessEntityID = c.SalesPersonID;

--1
SELECT FirstName,LastName, CompanyName,
   LEFT(FirstName,3) + '-' + LEFT(LastName,3) AS NewCompany
FROM dbo.demoPersonStore;

--2
UPDATE dbo.demoPersonStore
SET CompanyName = LEFT(FirstName,3) + '-' + LEFT(LastName,3);

--3
SELECT FirstName,LastName, CompanyName,
    LEFT(FirstName,3) + '-' + LEFT(LastName,3) AS NewCompany
FROM dbo.demoPersonStore;

--Updating with a Join

--1
SELECT AddressLine1, AddressLine2
FROM dbo.demoAddress;

--2
UPDATE dA
SET AddressLine1 = P.FirstName + ' ' + P.LastName,
    AddressLine2 = AddressLine1 + ISNULL(' ' + AddressLine2,'')
FROM dbo.demoAddress AS dA
INNER JOIN Person.BusinessEntityAddress BEA ON dA.AddressID = BEA.AddressID
INNER JOIN Person.Person P ON P.BusinessEntityID = BEA.BusinessEntityID;

--3
SELECT AddressLine1, AddressLine2
FROM dbo.demoAddress;

--Deleting Demo Tables

IF  EXISTS (SELECT * FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[dbo].[demoPersonStore]')
    AND type in (N'U'))
DROP TABLE [dbo].[demoPersonStore]
GO


IF  EXISTS (SELECT * FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[dbo].[demoPerson]')
    AND type in (N'U'))
DROP TABLE [dbo].[demoPerson];


IF  EXISTS (SELECT * FROM sys.objects
            WHERE object_id = OBJECT_ID(N'[dbo].[demoProduct]')
               AND type in (N'U'))
DROP TABLE [dbo].[demoProduct];
GO

IF  EXISTS (SELECT * FROM sys.objects
            WHERE object_id = OBJECT_ID(N'[dbo].[demoCustomer]')
               AND type in (N'U'))
DROP TABLE [dbo].[demoCustomer];
GO

IF  EXISTS (SELECT * FROM sys.objects
            WHERE object_id = OBJECT_ID(N'[dbo].[demoAddress]')
               AND type in (N'U'))
DROP TABLE [dbo].[demoAddress];
GO

IF  EXISTS (SELECT * FROM sys.objects
            WHERE object_id = OBJECT_ID(N'[dbo].[demoSalesOrderHeader]')
               AND type in (N'U'))
DROP TABLE [dbo].[demoSalesOrderHeader];
GO

IF  EXISTS (SELECT * FROM sys.objects
            WHERE object_id = OBJECT_ID(N'[dbo].[demoSalesOrderDetail]')
               AND type in (N'U'))
DROP TABLE [dbo].[demoSalesOrderDetail];
GO

IF  EXISTS (SELECT * FROM sys.objects
            WHERE object_id = OBJECT_ID(N'[dbo].[demoDefault]')
               AND type in (N'U'))
DROP TABLE [dbo].[demoDefault];
GO

IF  EXISTS (SELECT * FROM sys.objects
            WHERE object_id = OBJECT_ID(N'[dbo].[demoAutoPopulate]')
               AND type in (N'U'))
DROP TABLE [dbo].[demoAutoPopulate];


IF  EXISTS (SELECT * FROM sys.objects
            WHERE object_id = OBJECT_ID(N'[dbo].[demoPerformance]')
               AND type in (N'U'))
DROP TABLE [dbo].[demoPerformance];

