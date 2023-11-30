CREATE DATABASE Customer;

USE Customer;

SELECT *
FROM customer;

--Exploratory Data Analysis

-- Count of rows
SELECT COUNT(*) Row_count
FROM customer;

-- Count of columns
SELECT COUNT(*) AS ColumnCount
FROM information_schema.columns
WHERE table_name = 'customer';

--data types of column
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'customer';

--Missing values 
SELECT * 
FROM customer 
WHERE CustomerId IS NULL OR Surname IS NULL OR Age IS NULL;

SELECT * 
FROM customer
WHERE CustomerId IS NOT NULL ;

-- Creating new column for an already existing complain column
ALTER TABLE customer
ADD Complain_Rec NVARCHAR(10)

UPDATE customer
SET Complain_Rec = 
	CASE 
		WHEN Complain = 1 THEN 'Yes'
		WHEN Complain = 0 THEN 'No'
	END;

-- Creating new column for an already existing complain column
ALTER TABLE customer
ADD CustomerStatus NVARCHAR(10)

UPDATE customer
SET CustomerStatus = 
	CASE 
		WHEN IsActiveMember = 1 THEN 'Yes'
		WHEN IsActiveMember = 0 THEN 'No'
	END;

--How many customers have churned, and how many have not?

SELECT 'Cust_Churned' AS ChurnStatus, COUNT(Exited) AS Churn_Count
FROM customer
WHERE Exited = 1
UNION ALL
SELECT 'NoCust_Churned' AS ChurnStatus, COUNT(Exited) AS NoChurn_Count
FROM customer
WHERE Exited = 0;

--Number of Churn customers
SELECT 'Cust_Churned' AS ChurnStatus, SUM(Exited) AS Churn_Count
FROM customer
WHERE Exited = 1

--What is the percentage of churned customers in the dataset?
SELECT COUNT(DISTINCT CustomerId) AS Unique_Customer, SUM(Exited) AS Churn, SUM(Exited)/COUNT(DISTINCT CustomerId) * 100 AS Churn_Rate
FROM customer;

--What is the distribution of customers based on demographics (age, gender, location)?
SELECT CASE
    WHEN Age <= 20 THEN '0-20'
    WHEN Age > 20 AND Age <= 40 THEN '21-40'
    WHEN Age > 40 AND Age <= 60 THEN '41-60'
    ELSE '>60'
  END AS AgeCategory,
	   Gender,
	   Geography,
	   COUNT(*) AS Customer_Count
FROM customer
GROUP BY CASE
    WHEN Age <= 20 THEN '0-20'
    WHEN Age > 20 AND Age <= 40 THEN '21-40'
    WHEN Age > 40 AND Age <= 60 THEN '41-60'
    ELSE '>60'
	END, 
  Gender, 
  Geography
ORDER BY  Customer_Count;

--Number of Complaints
SELECT Geography,
	   SUM(Complain) AS NumofComplains
FROM customer
GROUP BY Geography;


--Is there any significant difference in churn rates across demographics?
SELECT 
	   Geography,
	   COUNT(*) AS Customer_Count,
	   SUM(Exited) / COUNT(DISTINCT CustomerId) * 100 AS Churn_Rate
FROM customer
GROUP BY  Geography;

--ChurnRate by Tenure
SELECT Tenure,
	   ROUND(SUM(Exited) / COUNT(DISTINCT CustomerId) * 100,2) AS ChurnRate
FROM customer
GROUP BY Tenure
ORDER BY Tenure;

--ChurnRate by Age
SELECT 
	CASE
		WHEN Age <= 20 THEN '0-20'
		WHEN Age > 20 AND Age <= 40 THEN '21-40'
		WHEN Age > 40 AND Age <= 60 THEN '41-60'
		ELSE 'greater than 60'
	END AS AgeCategory,
	ROUND(SUM(Exited) / COUNT(DISTINCT CustomerId) * 100,2) AS ChurnRate
FROM customer
GROUP BY  
	CASE
		WHEN Age <= 20 THEN '0-20'
		WHEN Age > 20 AND Age <= 40 THEN '21-40'
		WHEN Age > 40 AND Age <= 60 THEN '41-60'
		ELSE 'greater than 60'
	END 
ORDER BY 
	CASE
		WHEN Age <= 20 THEN '0-20'
		WHEN Age > 20 AND Age <= 40 THEN '21-40'
		WHEN Age > 40 AND Age <= 60 THEN '41-60'
		ELSE 'greater than 60'
	END;


-- Number of active and non-active member
SELECT 'Active Member' AS IsActiveMember_Status,
		COUNT(IsActiveMember) AS ActiveMember_Count
FROM customer
WHERE IsActiveMember = 1
UNION ALL
SELECT 'Non-Active Member' AS IsActiveMember_Status,
		COUNT(IsActiveMember) AS ActiveMember_Count
FROM customer
WHERE IsActiveMember = 0;

--ChurnRate by IsActiveMember_Status
SELECT 'Active Member' AS IsActiveMember_Status,
		COUNT(IsActiveMember) AS ActiveMember_Count,
	    ROUND(SUM(Exited) / COUNT(DISTINCT CustomerId) * 100,2) AS ChurnRate
FROM customer
WHERE IsActiveMember = 1
UNION ALL
SELECT 'Non-Active Member' AS IsActiveMember_Status,
		COUNT(IsActiveMember) AS ActiveMember_Count,
		ROUND(SUM(Exited) / COUNT(DISTINCT CustomerId) * 100,2) AS ChurnRate
FROM customer
WHERE IsActiveMember = 0;



--ChurnRate by Number of products
SELECT NumOfProducts,
	   ROUND(SUM(Exited) / COUNT(DISTINCT CustomerId) * 100,2) AS ChurnRate 
FROM customer
GROUP BY NumOfProducts
ORDER BY NumOfProducts;

--ChurnRate by creditcard 
SELECT [Card Type],
	   ROUND(SUM(Exited) / COUNT(DISTINCT CustomerId) * 100,2) AS ChurnRate 
FROM customer
GROUP BY [Card Type]
ORDER BY ChurnRate;

--ChurnRate by satisfaction score 
SELECT [Satisfaction Score],
	   ROUND(SUM(Exited) / COUNT(DISTINCT CustomerId) * 100,2) AS ChurnRate 
FROM customer
GROUP BY [Satisfaction Score]
ORDER BY [Satisfaction Score];

SELECT [Card Type],
	   ROUND(SUM(Exited) / COUNT(DISTINCT CustomerId) * 100,2) AS ChurnRate 
FROM customer
GROUP BY [Card Type]
ORDER BY [Card Type];

SELECT *
FROM customer
