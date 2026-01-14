/*
  Bike Shop - Business Scenario
  T-SQL script: table, sample data, and report queries.
*/

IF OBJECT_ID('dbo.BikeSales', 'U') IS NOT NULL
BEGIN
  DROP TABLE dbo.BikeSales;
END;
GO

CREATE TABLE dbo.BikeSales (
  BikeSaleId INT IDENTITY(1,1) PRIMARY KEY,
  CustomerName NVARCHAR(100) NOT NULL,
  CustomerAddress NVARCHAR(200) NOT NULL,
  PhoneNumber NVARCHAR(20) NOT NULL,
  BikeCompany NVARCHAR(50) NOT NULL,
  BikeSize NVARCHAR(10) NOT NULL,
  BikeColor NVARCHAR(30) NOT NULL,
  DatePurchased DATE NOT NULL,
  PurchasePrice DECIMAL(10, 2) NOT NULL,
  IsNew BIT NOT NULL,
  ConditionWhenReceived NVARCHAR(20) NULL,
  DateSold DATE NOT NULL,
  Season NVARCHAR(10) NOT NULL,
  SoldPrice DECIMAL(10, 2) NOT NULL,
  CONSTRAINT CHK_BikeSales_Season
    CHECK (Season IN ('Winter', 'Spring', 'Summer', 'Fall')),
  CONSTRAINT CHK_BikeSales_Dates
    CHECK (DateSold >= DatePurchased),
  CONSTRAINT CHK_BikeSales_SoldPrice
    CHECK (SoldPrice <= 3000.00),
  CONSTRAINT CHK_BikeSales_PurchaseStart
    CHECK (DatePurchased >= '2022-03-01'),
  CONSTRAINT CHK_BikeSales_Condition
    CHECK (
      (IsNew = 1 AND ConditionWhenReceived IS NULL)
      OR
      (IsNew = 0 AND ConditionWhenReceived IN ('Perfect', 'Minor Fixup', 'Major Fixup', 'Restoration'))
    )
);
GO

INSERT INTO dbo.BikeSales (
  CustomerName,
  CustomerAddress,
  PhoneNumber,
  BikeCompany,
  BikeSize,
  BikeColor,
  DatePurchased,
  PurchasePrice,
  IsNew,
  ConditionWhenReceived,
  DateSold,
  Season,
  SoldPrice
)
VALUES
  ('Shmuel Bitton', '4 Sparrow Drive Spring Valley NY 10977', '845-425-9501', 'Schwinn', '24"', 'Black', '2022-07-20', 110.00, 1, NULL, '2022-09-15', 'Summer', 220.00),
  ('Jack Sullivan', '1889 Fifty Second Street Brooklyn NY 11218', '718-350-4401', 'Trek', '24"', 'Gray', '2023-01-26', 150.00, 1, NULL, '2023-05-11', 'Spring', 250.00),
  ('Rochel Cohen', '95 Francis Place Spring Valley NY 10977', '845-371-2052', 'Huffy', '16"', 'Pink', '2023-03-13', 30.00, 1, NULL, '2023-06-18', 'Spring', 85.00),
  ('Meir Stern', '7 Bluejay Street Spring Valley NY 10977', '845-426-9806', 'Razor', '20"', 'Slate', '2023-08-06', 17.00, 0, 'Restoration', '2023-10-26', 'Fall', 61.00),
  ('Yehuda Gluck', '11 Parness Rd. #3 South Fallsburg NY 12733', '845-434-4011', 'Kent', '26"', 'Black', '2024-01-08', 120.00, 1, NULL, '2024-02-19', 'Winter', 250.00),
  ('Gedallia Gold', '2036 Park Avenue Lakewood NJ 08701', '732-930-6402', 'Trek', '20"', 'Blue', '2022-05-12', 105.00, 0, 'Minor Fixup', '2024-02-07', 'Winter', 200.00),
  ('Binyomin Shapiro', '66 Carlton Road Monsey NY 10952', '845-356-9027', 'Schwinn', '26"', 'Gray', '2022-04-22', 150.00, 0, 'Perfect', '2024-01-09', 'Winter', 135.00),
  ('Malka Fischer', '80 Twin Avenue Spring Valley NY 10977', '845-425-9002', 'Malibu', '18"', 'Pink', '2022-12-04', 90.00, 1, NULL, '2023-06-23', 'Summer', 120.00),
  ('Yonason Katz', '1470 E 26th Street Brooklyn NY 11223', '718-376-2658', 'Huffy', '20"', 'Blue', '2023-06-14', 76.00, 1, NULL, '2023-08-03', 'Summer', 130.00),
  ('Bracha Smith', '25 North Rigaud Road Spring Valley NY 10977', '845-352-1099', 'Razor', '24"', 'Slate', '2023-05-18', 167.00, 1, NULL, '2023-07-22', 'Summer', 220.00),
  ('Moshe Weiss', '25 Old Nyack Turnpike Monsey NY 10952', '845-356-9423', 'Kent', '24"', 'Black', '2022-12-13', 103.00, 0, 'Minor Fixup', '2023-08-16', 'Summer', 195.00),
  ('Yehuda Jacobs', '1650 Lexington Avenue Lakewood NJ 08701', '732-930-8054', 'Schwinn', '20"', 'Blue', '2022-04-09', 42.00, 0, 'Major Fixup', '2022-07-20', 'Summer', 98.00);
GO

-- Report 1: Local vs out-of-town customers (local = Spring Valley, NY 10977)
SELECT
  CASE
    WHEN CustomerAddress LIKE '%Spring Valley NY 10977%'
      THEN 'Local'
    ELSE 'Out-of-Town'
  END AS CustomerType,
  COUNT(*) AS CustomerCount
FROM dbo.BikeSales
GROUP BY
  CASE
    WHEN CustomerAddress LIKE '%Spring Valley NY 10977%'
      THEN 'Local'
    ELSE 'Out-of-Town'
  END;
GO

-- Report 2: Bikes sold per season
SELECT
  Season,
  COUNT(*) AS BikesSold
FROM dbo.BikeSales
GROUP BY Season
ORDER BY BikesSold DESC;
GO

-- Report 3: Average/min/max time in store and total profit
SELECT
  AVG(DATEDIFF(DAY, DatePurchased, DateSold) * 1.0) AS AvgDaysInStore,
  MIN(DATEDIFF(DAY, DatePurchased, DateSold)) AS MinDaysInStore,
  MAX(DATEDIFF(DAY, DatePurchased, DateSold)) AS MaxDaysInStore,
  SUM(SoldPrice - PurchasePrice) AS TotalProfit
FROM dbo.BikeSales;
GO

-- Report 4: Profit per sale with details
SELECT
  CustomerName,
  BikeCompany,
  PurchasePrice,
  SoldPrice,
  CASE WHEN IsNew = 1 THEN 'New' ELSE 'Used' END AS BikeCondition,
  (SoldPrice - PurchasePrice) AS Profit
FROM dbo.BikeSales
ORDER BY DateSold;
GO

-- Report 5: Most popular bike company
SELECT TOP 1 WITH TIES
  BikeCompany,
  COUNT(*) AS BikesSold
FROM dbo.BikeSales
GROUP BY BikeCompany
ORDER BY COUNT(*) DESC;
GO
