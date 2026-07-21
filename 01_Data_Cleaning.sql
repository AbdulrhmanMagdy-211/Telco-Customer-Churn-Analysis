USE TelecomDB
-- ===============================================================================
-- Script Name: 01_Data_Cleaning.sql 
-- Objective  : Clean, convert data types, replace NULLs, and standardize column names
-- Table Name : telco
-- ===============================================================================

-- 1. Handle blank spaces and convert them to NULL in Total_Charges
UPDATE telco
SET [Total_Charges] = NULL
WHERE LTRIM(RTRIM(CAST([Total_Charges] AS VARCHAR(MAX)))) = '' 
   OR [Total_Charges] = ' ';

-- 2. Convert Total_Charges data type to FLOAT
ALTER TABLE telco
ALTER COLUMN [Total_Charges] FLOAT;

-- 3. Handle NULL values in Churn categories and reasons
UPDATE telco
SET [Churn_Category] = 'Not Applicable'
WHERE [Churn_Category] IS NULL;

UPDATE telco
SET [Churn_Reason] = 'Not Applicable'
WHERE [Churn_Reason] IS NULL;

-- 4. Standardize column names (Remove underscores)
EXEC sp_rename 'telco.Customer_ID', 'CustomerID', 'COLUMN';
EXEC sp_rename 'telco.Customer_Status', 'CustomerStatus', 'COLUMN';
EXEC sp_rename 'telco.Churn_Label', 'ChurnLabel', 'COLUMN';
EXEC sp_rename 'telco.Tenure_in_Months', 'TenureInMonths', 'COLUMN';
EXEC sp_rename 'telco.Monthly_Charge', 'MonthlyCharges', 'COLUMN';
EXEC sp_rename 'telco.Total_Charges', 'TotalCharges', 'COLUMN';
EXEC sp_rename 'telco.Premium_Tech_Support', 'PremiumTechSupport', 'COLUMN';
EXEC sp_rename 'telco.Internet_Service', 'InternetService', 'COLUMN';
EXEC sp_rename 'telco.Contract', 'Contract', 'COLUMN';
EXEC sp_rename 'telco.Churn_Category', 'ChurnCategory', 'COLUMN';
EXEC sp_rename 'telco.Churn_Reason', 'ChurnReason', 'COLUMN';

-- 5. Set CustomerID as the Primary Key
ALTER TABLE telco
ALTER COLUMN CustomerID VARCHAR(50) NOT NULL;

ALTER TABLE telco
ADD CONSTRAINT PK_Telco PRIMARY KEY (CustomerID);