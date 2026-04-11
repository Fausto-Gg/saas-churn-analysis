CREATE TABLE churn_data (
    "CustomerID" TEXT,
    "Count" INT,
    "Country" TEXT,
    "State" TEXT,
    "City" TEXT,
    "Zip Code" TEXT,
    "Lat Long" TEXT,
    "Latitude" FLOAT,
    "Longitude" FLOAT,
    "Gender" TEXT,
    "Senior Citizen" TEXT,
    "Partner" TEXT,
    "Dependents" TEXT,
    "Tenure Months" INT,
    "Phone Service" TEXT,
    "Multiple Lines" TEXT,
    "Internet Service" TEXT,
    "Online Security" TEXT,
    "Online Backup" TEXT,
    "Device Protection" TEXT,
    "Tech Support" TEXT,
    "Streaming TV" TEXT,
    "Streaming Movies" TEXT,
    "Contract" TEXT,
    "Paperless Billing" TEXT,
    "Payment Method" TEXT,
    "Monthly Charges" FLOAT,
    "Total Charges" TEXT,
    "Churn Label" TEXT,
    "Churn Value" INT,
    "Churn Score" INT,
    "CLTV" INT,
    "Churn Reason" TEXT
);

SELECT * FROM churn_data LIMIT 5;

CREATE TABLE churn_clean AS
SELECT
    "CustomerID" AS customer_id,
    CASE 
        WHEN "Senior Citizen" = 'Yes' THEN 1
        ELSE 0
    END AS senior_citizen,
    "Gender" AS gender,
    "Tenure Months" AS tenure,
    "Contract" AS contract,
    "Payment Method" AS payment_method,
    "Monthly Charges" AS monthly_charges,
    NULLIF(TRIM("Total Charges"), '')::FLOAT AS total_charges,
    "Churn Label" AS churn,
    "Churn Value" AS churn_value
FROM churn_data;

-- Overall churn rate
SELECT 
    AVG(churn_value) AS churn_rate
FROM churn_clean;

-- Churn rate by subscription type
SELECT 
    contract,
    COUNT(*) AS total_customers,
    AVG(churn_value) AS churn_rate
FROM churn_clean
GROUP BY contract
ORDER BY churn_rate DESC;

-- Churn behavior by tenure
SELECT 
    CASE 
        WHEN tenure <= 6 THEN '0-6 months'
        WHEN tenure <= 12 THEN '6-12 months'
        WHEN tenure <= 24 THEN '12-24 months'
        ELSE '24+ months'
    END AS tenure_group,
    COUNT(*) AS total_customers,
    AVG(churn_value) AS churn_rate
FROM churn_clean
GROUP BY tenure_group
ORDER BY churn_rate DESC;

-- Churn by monthly charges
SELECT 
    CASE 
        WHEN monthly_charges < 40 THEN 'Low'
        WHEN monthly_charges < 80 THEN 'Medium'
        ELSE 'High'
    END AS spending_group,
    COUNT(*) AS total_customers,
    AVG(churn_value) AS churn_rate
FROM churn_clean
GROUP BY spending_group
ORDER BY churn_rate DESC;

-- Churn by payment method
SELECT 
    payment_method,
    COUNT(*) AS total_customers,
    AVG(churn_value) AS churn_rate
FROM churn_clean
GROUP BY payment_method
ORDER BY churn_rate DESC;

-- Create tenure cohorts
SELECT
    customer_id,
    tenure,
    churn_value,
    CASE 
        WHEN tenure <= 6 THEN '0-6 months'
        WHEN tenure <= 12 THEN '6-12 months'
        WHEN tenure <= 24 THEN '12-24 months'
        ELSE '24+ months'
    END AS cohort_group
FROM churn_clean;

-- Retention / churn by cohort
SELECT 
    cohort_group,
    COUNT(*) AS total_customers,
    SUM(churn_value) AS churned_customers,
    1 - AVG(churn_value) AS retention_rate
FROM (
    SELECT
        tenure,
        churn_value,
        CASE 
            WHEN tenure <= 6 THEN '0-6 months'
            WHEN tenure <= 12 THEN '6-12 months'
            WHEN tenure <= 24 THEN '12-24 months'
            ELSE '24+ months'
        END AS cohort_group
    FROM churn_clean
) t
GROUP BY cohort_group
ORDER BY cohort_group;

-- Cohort + contract segmentation
SELECT 
    cohort_group,
    contract,
    COUNT(*) AS total_customers,
    AVG(churn_value) AS churn_rate
FROM (
    SELECT
        contract,
        churn_value,
        CASE 
            WHEN tenure <= 6 THEN '0-6 months'
            WHEN tenure <= 12 THEN '6-12 months'
            WHEN tenure <= 24 THEN '12-24 months'
            ELSE '24+ months'
        END AS cohort_group
    FROM churn_clean
) t
GROUP BY cohort_group, contract
ORDER BY cohort_group, churn_rate DESC;

