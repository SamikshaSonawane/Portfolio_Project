

USE ResumeProject;

--Changed the datetime type to date

ALTER TABLE dbo.fact_stamps$
ALTER COLUMN month DATE;


--Checking for duplicates for districts

SELECT * 
FROM dbo.fact_stamps$ 
WHERE dist_code IS NOT NULL 
AND month =  '2019-07-01 00:00:00.000'
ORDER BY  documents_registered_cnt ASC , estamps_challans_cnt ASC ;

SELECT COUNT(district)
FROM dbo.dim_districts$ 
 
SELECT *
FROM dbo.dim_districts$ ;


SELECT * 
FROM dbo.fact_stamps$;

ALTER TABLE dbo.fact_stamps$
DROP COLUMN F7;

ALTER TABLE dbo.fact_stamps$
DROP COLUMN F8;

SELECT dist_code,
       month, 
       SUM(documents_registered_cnt) OVER (PARTITION BY dist_code) AS  Documents_Registered_C_Dist , 
       SUM(estamps_challans_cnt) OVER (PARTITION BY dist_code) AS EstampCh_C_Dist
FROM dbo.fact_stamps$
WHERE dist_code IS NOT NULL 
--GROUP BY month;

-- Sum of document_registration revenue and sum of estamp challan revenue

SELECT  SUM(documents_registered_rev) AS  Documents_Registered_C_Dist , SUM(estamps_challans_rev) AS EstampCh_C_Dist
FROM dbo.fact_stamps$
WHERE dist_code IS NOT NULL;

-- Sum of document_registration count and sum of estamp_challan count

SELECT  SUM(documents_registered_rev) AS  Documents_Registered_C_Dist , SUM(estamps_challans_rev) AS EstampCh_C_Dist
FROM dbo.fact_stamps$
WHERE dist_code IS NOT NULL;

-- 

SELECT * 
FROM dbo.fact_stamps$
WHERE dist_code IS NOT NULL
AND estamps_challans_cnt <> 0 ;

--1. Document rgistration revenue and estamp challan revenue by district

SELECT 
       d.district,
       SUM(documents_registered_rev) AS  Documents_Registered_C_Dist
       --SUM(estamps_challans_rev) AS EstampCh_C_Dist
FROM dbo.fact_stamps$ s 
JOIN dbo.dim_districts$ d on s.dist_code = d.dist_code
WHERE s.dist_code IS NOT NULL 
      AND s.month BETWEEN '2019-04-01 00:00:00.000' AND '2022-04-01 00:00:00.000'
GROUP BY d.district , s.month-- d.district,s.month
ORDER BY Documents_Registered_C_Dist DESC ;



--2. Highest document registration revenue by district 

SELECT TOP 5
       d.district , 
       SUM(documents_registered_rev)  AS  Documents_Registered_C_Dist
FROM dbo.fact_stamps$ s 
     JOIN dbo.dim_districts$ d on s.dist_code = d.dist_code
WHERE s.dist_code IS NOT NULL 
      AND s.month BETWEEN '2019-04-01 00:00:00.000' AND '2022-04-01 00:00:00.000'
GROUP BY d.district
ORDER BY  Documents_Registered_C_Dist DESC;


/*3. Is there any alteration of e-Stamp challan count and document registration count pattern since the implementation of e-Stamp 
challan? If so, what suggestions would you propose to the government? */

SELECT s.month,
        
       SUM(documents_registered_cnt) OVER (PARTITION BY s.month) AS  Documents_Registered_C_Dist,
	   SUM(estamps_challans_cnt)  OVER (PARTITION BY s.month) AS EstampChallanCnt,
CASE WHEN documents_registered_cnt < estamps_challans_cnt THEN 'High'
     WHEN documents_registered_cnt > estamps_challans_cnt THEN 'Low'
	 ELSE 'Others'
END AS category 
FROM dbo.fact_stamps$ s 
WHERE s.dist_code IS NOT NULL 
      
--GROUP BY  documents_registered_cnt ,estamps_challans_cnt
ORDER BY  s.month  ;





-- 4.e-stamps revenue contributes significantly more to the revenue than the documents in FY 2022?

SELECT TOP 5
       d.district , 
       SUM(estamps_challans_rev) AS EstampCh_C_Dist,
       SUM(documents_registered_rev)  AS  Documents_Registered_C_Dist
FROM dbo.fact_stamps$ s 
     JOIN dbo.dim_districts$ d on s.dist_code = d.dist_code
WHERE s.dist_code IS NOT NULL 
      AND s.month BETWEEN '2022-04-01 00:00:00.000' AND '2023-04-01 00:00:00.000'
	  AND (estamps_challans_rev > documents_registered_rev)
GROUP BY d.district
ORDER BY  EstampCh_C_Dist DESC, Documents_Registered_C_Dist DESC;

-- Categorize districts into three segments based on their stamp registration revenue generation during the fiscal year 2021 to 2022.

SELECT s.dist_code , 
       s.month,
       SUM(documents_registered_rev) AS  Documents_Registered_C_Dist, 
       SUM(estamps_challans_rev) AS EstampCh_C_Dist
FROM dbo.fact_stamps$ s 
       JOIN dbo.dim_districts$ d on s.dist_code = d.dist_code
WHERE s.dist_code IS NOT NULL 
      AND s.month BETWEEN '2021-01-01 00:00:00.000' AND '2022-12-01 00:00:00.000'
GROUP BY s.dist_code , s.month-- d.district,s.month
ORDER BY  Documents_Registered_C_Dist DESC, EstampCh_C_Dist DESC ;


-- Temp table to perform calculations on Sum of document_registration revenue and sum of estamp challan revenue for FY 2021 & 2022
DROP TABLE IF EXISTS #Revenue2122

CREATE TABLE #Revenue2122 (
  Dist_code nvarchar(255),
  month date,
  SUMDocumentsRegis float,
  SUMestampChallan float
  )

INSERT INTO #Revenue2122
SELECT s.dist_code , 
       s.month,
       SUM(documents_registered_rev) AS  Documents_Registered_C_Dist, 
       SUM(estamps_challans_rev) AS EstampCh_C_Dist
FROM dbo.fact_stamps$ s 
       JOIN dbo.dim_districts$ d on s.dist_code = d.dist_code
WHERE s.dist_code IS NOT NULL 
      AND s.month BETWEEN '2021-01-01 00:00:00.000' AND '2022-12-01 00:00:00.000'
GROUP BY s.dist_code , s.month-- d.district,s.month
ORDER BY  Documents_Registered_C_Dist DESC, EstampCh_C_Dist DESC ;


SELECT * 
FROM #Revenue2122
ORDER BY SUMDocumentsRegis DESC;

-- Max

SELECT
       MAX(SUMDocumentsRegis) AS Maximum_SumDocReg,
       MAX(SUMestampChallan) AS Maximum_SumestampChallan
FROM #Revenue2122
--ORDER BY SUMDocumentsRegis DESC;

--Min

SELECT
       MIN(SUMDocumentsRegis) AS Minimum_SumDocReg,
       Min(SUMestampChallan) AS Minimum_SumestampChallan
FROM #Revenue2122

