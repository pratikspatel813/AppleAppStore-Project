CREATE TABLE appleStore_description_combined AS

SELECT * FrOM appleStore_description1

UNION ALL

SELECT * FrOM appleStore_description1

UNION ALL

SELECT * FrOM appleStore_description2

UNION ALL

SELECT * FrOM appleStore_description3

UNION ALL

SELECT * FrOM appleStore_description4


**EXPLORATORY DATA ANALYSIS** 

-- Check the number of unique apps in both tablesAppleStore

SELECT COUNT(DISTINCT id) as UniqueAppIDs
FROM AppleStore

SELECT COUNT(DISTINCT id) as UniqueAppIDs
FROM appleStore_description_combined

-- Check for any missing values in key fields

SELECT COUNT(*) AS MissingValues
FROM AppleStore
WHERE track_name IS null OR user_rating is null or prime_genre is null

SELECT COUNT(*) AS MissingValues
FROM appleStore_description_combined
WHERE app_desc IS null 

-- Find out the number of apps per genre
SELECT prime_genre, COUNT(*) AS NumApps
FROM AppleStore
GROUP BY prime_genre
ORDER by NumApps DESC

-- Get an overview of the apps' ratings
SELECT min(user_rating) AS MinRating,
       max(user_rating) AS MaxRating,
       avg(user_rating) AS AvgRating
FROM AppleStore


-- Determine whether paid apps have higher ratings than free appsAppleStore

SELECT CASE
			WHEN price > 0 then 'Paid'
            ELSE 'Free'
		End AS App_Type,
        avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY App_Type

-- Check if apps with more support languages have higher ratings

SELECT CASE
			WHEN lang_num < 10 then '<10 languages'
            WHEN lang_num between 10 and 30 then '10-30 languages'
            else '>30 languages'
		END AS language_bucket,
        avg(user_rating) AS Avg_Rating
from AppleStore
GROUP BY language_bucket
order by Avg_Rating DESC

-- Check genres with low ratings

SELECT prime_genre,
		avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP by prime_genre
ORDER BY Avg_Rating asc
limit 10

--Check if there is a correlation between the length of the app description and the user raitng

SELECT CASE
			WHEN length(b.app_desc) < 500 then 'Short'
			WHEN length(b.app_desc) between 500 and 1000 then 'Medium'
            ELSE 'Long'
		end as description_length_bucket,
        avg(a.user_rating) AS average_rating
            
FROM
		AppleStore as A 
JOIN
		appleStore_description_combined AS b
ON 
		a.id = b.id

GROUP BY description_length_bucket
order by average_rating desc

-- Check the top-rated apps for each genre

 SELECT
 	prime_genre,
    track_name,
    user_rating
FROM (
  		SELECT
  		prime_genre,
  		track_name,
  		user_rating,
  		RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating desc, rating_count_tot desc) as rank
  		FROM
  		AppleStore
  	) as a
WHERE
a.rank = 1