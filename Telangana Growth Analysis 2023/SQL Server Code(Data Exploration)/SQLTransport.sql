SELECT TOP (1000) [dist_code]
      ,[month]
      ,[fuel_type_petrol]
      ,[fuel_type_diesel]
      ,[fuel_type_electric]
      ,[fuel_type_others]
      ,[vehicleClass_MotorCycle]
      ,[vehicleClass_MotorCar]
      ,[vehicleClass_AutoRickshaw]
      ,[vehicleClass_Agriculture]
      ,[vehicleClass_others]
      ,[seatCapacity_1_to_3]
      ,[seatCapacity_4_to_6]
      ,[seatCapacity_above_6]
      ,[Brand_new_vehicles]
      ,[Pre-owned_vehicles]
      ,[category_Non-Transport]
      ,[category_Transport]
  FROM [ResumeProject].[dbo].[fact_transport$]

USE ResumeProject;

--Changed the datetime type to date

ALTER TABLE dbo.fact_transport$
ALTER COLUMN month DATE;

SELECT *
FROM dbo.fact_transport$;


-- 

SELECT d.district,
       SUM([vehicleClass_MotorCycle]) AS Cycles
      ,SUM([vehicleClass_MotorCar]) AS Cars
      ,SUM([vehicleClass_AutoRickshaw]) AS Rickshaws
      ,SUM([vehicleClass_Agriculture]) AS Agriculture
       ,SUM([vehicleClass_others]) 
From 
      dbo.fact_transport$ f
	 JOIN dbo.dim_districts$ d
	 ON f.dist_code = d.dist_code
	 LEFT JOIN dim_date$ dd ON f.month = dd.month
WHERE fiscal_year = '2022'
Group By d.district
--Having SUM([vehicleClass_Agriculture]) > 1000

Order By Agriculture DESC;


SELECT MONTH(month),
       fuel_type_petrol,
	   CASE 
	       WHEN fuel_type_petrol >= 26000 THEN 'Higher Sales'
		   WHEN fuel_type_petrol >= 15000 AND fuel_type_petrol < 26000 THEN 'Medium Sales'
		   WHEN fuel_type_petrol < 15000 THEN 'Low Sales'
		   ELSE 'Others'
       END AS SalesCategory

FROM dbo.fact_transport$
GROUP BY month ,  fuel_type_petrol
ORDER BY month;

/*How does the distribution of vehicles vary by vehicle class (MotorCycle, MotorCar, AutoRickshaw, Agriculture) across different 
districts? Are there any districts with a predominant preference for a
specific vehicle class? Consider FY 2022 for analysis.*/

SELECT
    d.district,

    SUM( vehicleClass_MotorCycle) AS MotorCycleCount,
    SUM(vehicleClass_MotorCar) AS MotorCarCount,
    SUM(vehicleClass_AutoRickshaw ) AS AutoRickshawCount,
    SUM(vehicleClass_Agriculture) AS AgricultureCount
FROM
    dbo.fact_transport$ f-- Replace with the actual name of your table
	JOIN dim_districts$ d on f.dist_code = d.dist_code 
	JOIN dim_date$ dd ON f.month = dd.month
WHERE
    fiscal_year = 2022
GROUP BY
    d.district


/*List down the top 3 and bottom 3 districts that have shown the highest and lowest vehicle sales growth during FY 2022 compared to FY
2021? (Consider and compare categories: Petrol, Diesel and Electric)*/

--2021
SELECT TOP 3
       f.month,
       SUM(fuel_type_petrol) AS PetrolType
	   --SUM(fuel_type_diesel) AS DieselType,
	   --SUM(fuel_type_electric) AS ElectricType
FROM dbo.fact_transport$ f
     JOIN dim_date$ d ON f.month = d.month
WHERE 
     fiscal_year = 2021
GROUP BY f.month
ORDER BY PetrolType;

--2022
SELECT TOP 3
       f.month,
       SUM(fuel_type_petrol) AS PetrolType
	   --SUM(fuel_type_diesel) AS DieselType,
	   --SUM(fuel_type_electric) AS ElectricType
FROM dbo.fact_transport$ f
     JOIN dim_date$ d ON f.month = d.month
WHERE 
     fiscal_year = 2022
GROUP BY f.month
ORDER BY PetrolType;

-- Bottom 2021
SELECT TOP 3
       f.month,
       SUM(f.fuel_type_petrol) AS PetrolType,
	   SUM(f.fuel_type_diesel) AS DieselType,
	   SUM(f.fuel_type_electric) AS ElectricType
FROM dbo.fact_transport$ f
     JOIN dim_date$ d ON f.month = d.month
WHERE 
     fiscal_year = 2021
GROUP BY f.month
ORDER BY PetrolType DESC;

--2022
SELECT TOP 3
       f.month,
       SUM(fuel_type_petrol) AS PetrolType
	   --SUM(fuel_type_diesel) AS DieselType,
	   --SUM(fuel_type_electric) AS ElectricType
FROM dbo.fact_transport$ f
     JOIN dim_date$ d ON f.month = d.month
WHERE 
     fiscal_year = 2021
GROUP BY f.month
ORDER BY PetrolType ;


SELECT d.district,
       SUM(vehicleClass_MotorCycle) As MotorCycle,
	   SUM(vehicleClass_MotorCar) As MotorCar,
	  SUM(vehicleClass_Agriculture) As Agriculture,
	   SUM(vehicleClass_AutoRickshaw) As AutoRikshaw
	   
FROM dbo.fact_transport$ f
     JOIN dbo.dim_districts$ d  
	 ON f.dist_code = d.dist_code
GROUP BY d.district


