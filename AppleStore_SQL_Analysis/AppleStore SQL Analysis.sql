USE ProjectP;

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'appledesc';

SELECT *
FROM appledesc;

SELECT *
FROM apple;

ALTER TABLE apple
DROP COLUMN F1;

--EXPLORATORY DATA ANALYSIS

--Check for missing values 
SELECT COUNT(*)
FROM apple
WHERE track_name IS NULL or prime_genre IS NULL or user_rating IS NULL;

SELECT COUNT(*)
FROM appledesc
WHERE id IS NULL or track_name IS NULL;

--Check the number of unique apps in both tables

SELECT COUNT(DISTINCT id) AS Unique_Apps
FROM apple;

SELECT COUNT(DISTINCT id) AS Unique_Apps
FROM appledesc;

--Find out the number of apps per genre

SELECT prime_genre, COUNT(*) AS Num_App
FROM apple
GROUP BY prime_genre;

--Overview of the apps rating

SELECT MIN(user_rating) AS MinRating,
       MAX(user_rating) AS MaxRating,
	   AVG(user_rating) AS AvgRating
FROM apple;

--How many free apps and paid apps are there?

SELECT 
CASE WHEN price = 0 THEN 'Free Apps'
     WHEN price > 0 THEN 'Paid Apps'
ELSE 'Invalid'
END AS Price,
COUNT(*) AS AppCount
FROM apple
GROUP BY 
      CASE WHEN price = 0 THEN 'Free Apps'
           WHEN price > 0 THEN 'Paid Apps'
      ELSE 'Invalid'
      END ;

--What is the distribution of app rating?

SELECT user_rating,
       COUNT(*) AS Rating_Count
FROM apple
GROUP BY user_rating
ORDER BY user_rating;
 
--What is the distribution of app rating percentage?
SELECT user_rating,
       COUNT(*) AS Rating_Count,
	   CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM apple) AS DECIMAL(5,2)) AS Percentage
FROM apple
GROUP BY user_rating
ORDER BY user_rating;


--Data Analysis

--1.Which apps have the highest number of downloads?

SELECT track_name, rating_count_tot
FROM apple
ORDER BY rating_count_tot DESC;

--2.Is there a correlation between app ratings and the number of downloads?

SELECT AVG(rating_count_tot) AS Avg_downloads,
       user_rating
FROM apple
GROUP BY user_rating
ORDER BY user_rating;

--3.How does the size of the app affect its popularity?

SELECT AVG(rating_count_tot) AS Avg_downloads,
       CASE WHEN size_bytes < 104857600 THEN 'Small'
	        WHEN size_bytes >= 104857600 AND size_bytes < 524288000 THEN 'Medium'
			ELSE 'Large'
	   END AS size_category
FROM apple
GROUP BY 
       CASE WHEN size_bytes < 104857600 THEN 'Small'
	        WHEN size_bytes >= 104857600 AND size_bytes < 524288000 THEN 'Medium'
			ELSE 'Large'
	   END
ORDER BY size_category;

--4.Do paid apps perform better in terms of ratings compared to free apps?

SELECT 
      CASE WHEN price = 0 THEN 'Free Apps'
	       ELSE 'Paid App'
      END AS App_type,
	  AVG(user_rating) AS Avg_Rating
FROM apple
GROUP BY 
       CASE WHEN price = 0 THEN 'Free Apps'
	       ELSE 'Paid App'
      END;

--5.What is the average price of paid apps in different categories?

SELECT prime_genre,
      CASE WHEN price = 0 THEN 'Free Apps'
	       ELSE 'Paid App'
      END AS App_type,
	  AVG(user_rating) AS Avg_Rating
FROM apple
GROUP BY prime_genre,
       CASE WHEN price = 0 THEN 'Free Apps'
	       ELSE 'Paid App'
      END
HAVING(CASE WHEN price = 0 THEN 'Free Apps'
	       ELSE 'Paid App'
      END)= 'Paid App';

--6.How many apps are designed for iPhones, iPads, or both?

SELECT
    CASE
        WHEN sup_devices_num = 1 THEN 'iPhone'
        WHEN sup_devices_num > 1 THEN 'iPad'
        ELSE 'Both (iPhone and iPad)'
    END AS DeviceCompatibility,
    COUNT(*) AS AppCount
FROM
    apple
GROUP BY
    CASE
        WHEN sup_devices_num = 1 THEN 'iPhone'
        WHEN sup_devices_num > 1 THEN 'iPad'
        ELSE 'Both (iPhone and iPad)'
    END;

--7.What is the distribution of app sizes for different devices?

SELECT
    CASE
        WHEN sup_devices_num = 1 THEN 'iPhone'
        WHEN sup_devices_num > 1 THEN 'iPad'
        ELSE 'Both (iPhone and iPad)'
    END AS DeviceCompatibility,
    AVG(size_bytes) AS Avg_Size,
    MIN(size_bytes) AS Min_Size,
    MAX(size_bytes) AS Max_Size
FROM
    apple
GROUP BY
    CASE
        WHEN sup_devices_num = 1 THEN 'iPhone'
        WHEN sup_devices_num > 1 THEN 'iPad'
        ELSE 'Both (iPhone and iPad)'
    END;

--Check if apps with more supported languages have higher ratings?

SELECT CASE WHEN lang_num < 10 THEN '< 10 languages'
			WHEN lang_num BETWEEN 10 AND 30 THEN '< 10-30 languages'
            ELSE '> 30 languages'
       END AS language_bucket,
	   AVG(user_rating) AS Avg_Rating
FROM apple
GROUP BY 
       CASE WHEN lang_num < 10 THEN '< 10 languages'
			WHEN lang_num BETWEEN 10 AND 30 THEN '< 10-30 languages'
            ELSE '> 30 languages'
       END
ORDER BY Avg_Rating;

--8.Genre with low rating

SELECT prime_genre,
       AVG(user_rating) AS Avg_Rating
FROM apple
GROUP BY prime_genre
ORDER BY Avg_Rating ASC;
  

--9.Is there a relationship between app price and category?
SELECT prime_genre,
       AVG(CASE WHEN price > 0 THEN price ELSE NULL END) AS Avg_Price
FROM apple
GROUP BY prime_genre
ORDER BY Avg_Price;


--10.Is there a correlation between the length of the description and the app's popularity or rating?

SELECT 
      CASE WHEN LEN(d.app_desc) < 500 THEN 'Short'
	       WHEN LEN(d.app_desc) > 500 THEN 'Medium'
		   ELSE 'Long'
      END AS description_lenght,
	  AVG(user_rating) AS Avg_Rating
FROM 
	apple a
JOIN
	appledesc d
ON a.id = d.id
GROUP BY 
        CASE WHEN LEN(d.app_desc) < 500 THEN 'Short'
	       WHEN LEN(d.app_desc) > 500 THEN 'Medium'
		   ELSE 'Long'
      END
ORDER BY  Avg_Rating DESC;
