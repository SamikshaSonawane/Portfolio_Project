USE Cyclistic;

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'bike';

--Changed Sunday = 0 & Saturday = 6 from Sunday = 1 & Saturday = 7
UPDATE bike
SET day_of_week = DATEPART(WEEKDAY, started_at);

--Descriptive Statistics

--Average ride_duration
SELECT AVG(CAST(DATEDIFF(SECOND, started_at, ended_at) AS DECIMAL(18, 3))) AS avg_duration
FROM bike;

--Max ride_duration
SELECT MAX(CAST(DATEDIFF(MINUTE, started_at, ended_at) AS DECIMAL(18, 3))) AS maximum_duration
FROM bike;

--Min ride_duration
SELECT MIN(CAST(DATEDIFF(MINUTE, started_at, ended_at) AS DECIMAL(18, 3))) AS Min_duration
FROM bike;

--Total rides
SELECT COUNT(ride_id) AS Total_Rides
FROM bike;

--TOP start station names by Total Ride
SELECT start_station_name, 
	   COUNT(ride_id) AS Total_Ride
FROM bike
GROUP BY start_station_name
ORDER BY Total_Ride DESC;
/*TOP stations are University Ave & 57th St, Ellis Ave & 60th St, Clinton St & Washington Blvd,Kingsbury St & Kinzie St, Clark St & Elm St */


--TOP end_station_name by Total Ride 
SELECT end_station_name, 
	   COUNT(ride_id) OVER (PARTITION BY end_station_name )AS Total_Ride
FROM bike
GROUP BY end_station_name
ORDER BY Total_Ride DESC;
/*University Ave & 57th St, Ellis Ave & 60th St, Clinton St & Washington Blvd, Kingsbury St & Kinzie St, Clinton St & Madison St*/



--Temp table
DROP TABLE IF EXISTS #CyleD
CREATE TABLE #CyleD (
	ride_id nvarchar(255),
	rideable_type nvarchar(255),
	started_at datetime,
	ended_at datetime,
	ride_length varchar(255),
	member_casual nvarchar(255),
	day_of_week float
)

INSERT INTO #CyleD
SELECT ride_id,
	  rideable_type, 
	  started_at, 
	  ended_at,
	  ride_length_formatted,
	  member_casual,
	  day_of_week 
FROM bike;

SELECT *
FROM #CyleD;

--Adding new column ride_duration in seconds
ALTER TABLE #CyleD
ADD ride_durationn INT;

UPDATE #CyleD
SET ride_durationn = DATEDIFF(SECOND, started_at, ended_at);

--Adding new column month 
ALTER TABLE #CyleD
ADD month INT;

UPDATE #CyleD
SET month = MONTH(started_at);


UPDATE #CyleD
SET
   month =
       CASE WHEN month = '1' THEN 'January'
			WHEN month = '2' THEN 'February'
			WHEN month = '3' THEN 'March'
       END
WHERE month IN ('1', '2', '3');

--Convert the month column to string 
ALTER TABLE #CyleD
ALTER COLUMN month VARCHAR(255);

UPDATE #CyleD
SET
   day_of_week =
      CASE WHEN day_of_week = 1 THEN 'Sunday'
			WHEN day_of_week = 2 THEN 'Monday'
			WHEN day_of_week = 3 THEN 'Tuesday'
			WHEN day_of_week = 4 THEN 'Wednesday'
			WHEN day_of_week = 5 THEN 'Thursday'
			WHEN day_of_week = 6 THEN 'Friday'
			WHEN day_of_week = 7 THEN 'Saturday'
	   END
WHERE day_of_week IN ('1', '2', '3', '4', '5', '6', '7');

--Convert the month column to string 
ALTER TABLE #CyleD
ALTER COLUMN day_of_week VARCHAR(255);


SELECT * 
FROM #CyleD



--2. Total Ride per ride type
SELECT rideable_type, 
	   COUNT(ride_id) AS Tota_Ride
FROM bike
GROUP BY rideable_type;


--3.Compare the number of trips between annual members and casual riders.(Total Ride by member status)
SELECT member_casual,
	   COUNT(ride_id) AS Total_Ride
FROM bike
GROUP BY member_casual;


--4.Ride type by total duration spend
SELECT rideable_type, 
	   AVG(CAST(DATEDIFF(MINUTE, started_at, ended_at) AS DECIMAL(18, 3))) AS Total_duration
FROM bike
WHERE ride_length_formatted > '00:03:00'
GROUP BY rideable_type;


--5.How does the distribution of ride durations differ between annual members and casual riders?
SELECT
    member_casual,
    CASE
        WHEN DATEDIFF(MINUTE, started_at, ended_at)> 3 and  DATEDIFF(MINUTE, started_at, ended_at) < 10 THEN '0-10 mins'
        WHEN DATEDIFF(MINUTE, started_at, ended_at) > 10 and DATEDIFF(MINUTE, started_at, ended_at) <= 20 THEN '10-20 mins'
        WHEN DATEDIFF(MINUTE, started_at, ended_at) > 20 and DATEDIFF(MINUTE, started_at, ended_at) <= 30 THEN '20-30 mins'
        ELSE '30+ mins'
    END AS ride_duration_range,
    COUNT(*) AS ride_count
FROM
    bike
GROUP BY
    member_casual,
    CASE
        WHEN DATEDIFF(MINUTE, started_at, ended_at)> 3 and  DATEDIFF(MINUTE, started_at, ended_at) < 10 THEN '0-10 mins'
        WHEN DATEDIFF(MINUTE, started_at, ended_at) > 10 and DATEDIFF(MINUTE, started_at, ended_at) <= 20 THEN '10-20 mins'
        WHEN DATEDIFF(MINUTE, started_at, ended_at) > 20 and DATEDIFF(MINUTE, started_at, ended_at) <= 30 THEN '20-30 mins'
        ELSE '30+ mins'
    END
ORDER BY
    member_casual, ride_duration_range;
/*Ride duration for casual members for 0-10 mins is highest, followed by 10-20 mins larger trips have around 18700 ride count*/


--6.What is the average ride_length per month for annual members and casual riders?
SELECT  member_casual, 
		MONTH(started_at) AS Month_,
	    AVG(CAST(DATEDIFF(MINUTE, started_at, ended_at) AS DECIMAL(18, 3))) AS AVG_Ride_duration
FROM bike
GROUP BY member_casual, MONTH(started_at)
ORDER BY  Month_, member_casual;

/*Casual members have average ride durations greater than annual members.*/ 

--7.Are there specific days or times when annual members or casual riders are more active?
SELECT day_of_week,
	   DATEPART(HOUR, started_at) AS hour_of_day,
       member_casual,
	   COUNT(*) AS RideCount
FROM #CyleD
GROUP BY day_of_week,
         DATEPART(HOUR, started_at),
		 member_casual
ORDER BY RideCount DESC;




	SELECT member_casual,
		   FORMAT(started_at, 'HH:mm:ss') AS TimeOnly,
		   COUNT(ride_id) AS Total_Ride
	FROM bike
	GROUP BY FORMAT(started_at, 'HH:mm:ss'), member_casual
	HAVING COUNT(ride_id)  > 10 and
			member_casual = 'casual'
	ORDER BY Total_Ride DESC;

--Mode of day_of_week
WITH DayofWeekCounts AS(
	SELECT 
		day_of_week AS mode_dayofweek,
		COUNT(*) AS mode_frequency
	FROM
		#CyleD
	GROUP BY
		day_of_week
)
SELECT TOP 1
	mode_dayofweek,
	mode_frequency
FROM 
	DayofWeekCounts
ORDER BY
		ROW_NUMBER() OVER (ORDER BY mode_frequency);
/*Saturday is the mode */

--8.What is the average number of rides per month for annual members and casual riders?
SELECT 
	member_casual,
	month,
	COUNT(ride_id) AS RideCount,
	ROUND(CAST(COUNT(ride_id) AS FLOAT) / SUM(COUNT(ride_id)) OVER (PARTITION BY member_casual) * 100,2) AS category_proportion
FROM 
	#CyleD
GROUP BY 
	member_casual,
	month
ORDER BY
	RideCount;

SELECT 
	member_casual,
	month,
	COUNT(ride_id) AS RideCount,
	ROUND(COUNT(ride_id) / SUM(COUNT(ride_id)) OVER (PARTITION BY member_casual) * 100, 2) AS category_proportion
FROM 
	#CyleD
GROUP BY 
	member_casual,
	month
ORDER BY
	RideCount;

--9.Do annual members or casual riders tend to use the bikes more frequently? (Total Rides by day of week) 
SELECT 
	member_casual,
	COUNT(ride_id) AS Ride_Count
FROM 
	#CyleD
GROUP BY
	member_casual
ORDER BY
	Ride_Count;

--10.Do annual members and casual riders prefer different types of rideables (e.g., standard bikes, electric bikes)?
SELECT member_casual,
	   rideable_type,
	   COUNT(ride_id) AS Total_Ride
FROM #CyleD
GROUP BY member_casual, rideable_type
ORDER BY member_casual, rideable_type;
/*annual members are only using classics and electric bike and casual riders are using all rideable types, though annual members has more total rides.
In both groups electric type is more popular.*/

--11.Which start and end stations are most popular among annual members and casual riders?
--(casual) 
SELECT  TOP 10
		member_casual,
		start_station_name, 
		end_station_name,
	    COUNT(ride_id) AS Total_Ride
FROM bike
GROUP BY member_casual, start_station_name, end_station_name
HAVING member_casual = 'casual'
ORDER BY Total_Ride DESC;

--(annual member) Determine if there are specific stations that attract more annual members
SELECT  TOP 10
		member_casual,
		start_station_name, 
		end_station_name,
	    COUNT(ride_id) AS Total_Ride
FROM bike
GROUP BY member_casual, start_station_name, end_station_name
HAVING member_casual = 'member'
ORDER BY Total_Ride DESC;

--4.Ride type by total duration spend
SELECT 
	member_casual, 
	ride_length
	   --AVG(CAST(DATEDIFF(MINUTE, started_at, ended_at) AS DECIMAL(18, 3))) AS Total_duration
FROM 
	#CyleD
GROUP BY 
	member_casual,
    ride_length
HAVING ride_length >'00:03:00'
ORDER BY
	ride_length DESC;

--12.Is there a difference in the average duration  by annual members and casual riders?
SELECT
    member_casual,
    AVG(DATEDIFF(MINUTE, started_at, ended_at)) AS avg_ride_duration_minutes
FROM
    #CyleD
GROUP BY
    member_casual;
/*casual members has highest number of avg ride duration */

--13.Are there specific routes or paths that are more popular among annual members or casual riders?
SELECT
    member_casual,
    start_station_name,
    end_station_name,
    COUNT(ride_id) AS route_popularity
FROM
    bike
GROUP BY
    member_casual,
    start_station_name,
    end_station_name
ORDER BY
    route_popularity DESC;



