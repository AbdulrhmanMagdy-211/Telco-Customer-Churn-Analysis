USE TelecomDB
-- ===============================================================================
-- Script Name: 02_Business_Analysis.sql 
-- Objective  : Extract Executive KPIs, Churn Drivers, Risk Segments, and Revenue Loss
-- Table Name : telco
-- ===============================================================================

-- 1. EXECUTIVE KPI OVERVIEW
SELECT 
    COUNT(*) AS TotalCustomers,
    SUM(CASE WHEN CustomerStatus = 'Churned' THEN 1 ELSE 0 END) AS ChurnedCustomers,
    ROUND(
        CAST(SUM(CASE WHEN CustomerStatus = 'Churned' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) * 100, 
        2
    ) AS ChurnRatePercent,
    ROUND(SUM(Total_Revenue), 2) AS TotalRevenue,
    ROUND(SUM(CASE WHEN CustomerStatus = 'Churned' THEN Total_Revenue ELSE 0 END), 2) AS LostRevenue,
    ROUND(
        SUM(CASE WHEN CustomerStatus = 'Churned' THEN Total_Revenue ELSE 0 END) / SUM(Total_Revenue) * 100, 
        2
    ) AS LostRevenuePercent
FROM telco;

-- 2. CHURN DRIVERS & REASONS
-- A. Churn Distribution by Category
SELECT 
    ChurnCategory,
    COUNT(*) AS ChurnedCount,
    ROUND(
        CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM telco WHERE CustomerStatus = 'Churned') * 100, 
        2
    ) AS PercentOfTotalChurn
FROM telco
WHERE CustomerStatus = 'Churned'
GROUP BY ChurnCategory
ORDER BY ChurnedCount DESC;

-- B. Top 5 Specific Churn Reasons
SELECT TOP 5
    ChurnReason,
    ChurnCategory,
    COUNT(*) AS ChurnedCount
FROM telco
WHERE CustomerStatus = 'Churned'
GROUP BY ChurnReason, ChurnCategory
ORDER BY ChurnedCount DESC;

-- 3. RISK BY CONTRACT TYPE
SELECT 
    Contract,
    COUNT(*) AS TotalCustomers,
    SUM(CASE WHEN CustomerStatus = 'Churned' THEN 1 ELSE 0 END) AS ChurnedCount,
    ROUND(
        CAST(SUM(CASE WHEN CustomerStatus = 'Churned' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) * 100, 
        2
    ) AS ChurnRatePercent
FROM telco
GROUP BY Contract
ORDER BY ChurnRatePercent DESC;

-- 4. SERVICE ANALYSIS: INTERNET TYPE & PREMIUM TECH SUPPORT
-- A. Churn Rate by Internet Type
SELECT 
    Internet_Type AS InternetType,
    COUNT(*) AS TotalCustomers,
    SUM(CASE WHEN CustomerStatus = 'Churned' THEN 1 ELSE 0 END) AS ChurnedCount,
    ROUND(
        CAST(SUM(CASE WHEN CustomerStatus = 'Churned' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) * 100, 
        2
    ) AS ChurnRatePercent
FROM telco
WHERE Internet_Type IS NOT NULL
GROUP BY Internet_Type
ORDER BY ChurnRatePercent DESC;

-- B. Impact of Premium Tech Support
SELECT 
    PremiumTechSupport,
    COUNT(*) AS TotalCustomers,
    SUM(CASE WHEN CustomerStatus = 'Churned' THEN 1 ELSE 0 END) AS ChurnedCount,
    ROUND(
        CAST(SUM(CASE WHEN CustomerStatus = 'Churned' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) * 100, 
        2
    ) AS ChurnRatePercent
FROM telco
GROUP BY PremiumTechSupport
ORDER BY ChurnRatePercent DESC;

-- 5. TENURE & HIGH-VALUE AT-RISK ANALYSIS
-- A. Average Tenure and Charges by Customer Status
SELECT 
    CustomerStatus,
    ROUND(AVG(TenureInMonths), 1) AS AvgTenureMonths,
    ROUND(AVG(MonthlyCharges), 2) AS AvgMonthlyCharge,
    ROUND(AVG(TotalCharges), 2) AS AvgTotalCharges
FROM telco
GROUP BY CustomerStatus;

-- B. Top 5 High-Value Lost Customers (Using CTE)
WITH RankedLostCustomers AS (
    SELECT 
        CustomerID,
        Contract,
        TenureInMonths,
        Total_Revenue AS TotalRevenue,
        ChurnReason,
        DENSE_RANK() OVER (ORDER BY Total_Revenue DESC) AS RevenueRank
    FROM telco
    WHERE CustomerStatus = 'Churned'
)
SELECT 
    RevenueRank,
    CustomerID,
    Contract,
    TenureInMonths,
    TotalRevenue,
    ChurnReason
FROM RankedLostCustomers
WHERE RevenueRank <= 5;


