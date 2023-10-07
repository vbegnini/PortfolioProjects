CREATE TABLE appleStore_description_combined AS

SELECT * FROM appleStore_description1

UNION ALL

SELECT * FROM appleStore_description2

UNION ALL

SELECT * FROM appleStore_description3

UNION ALL

SELECT * FROM appleStore_description4

**EXPLORATORY DATA ANALYSIS (EDA)**
-- supposedly insights for a Mobile Dev who wants to establish which way to create better rated apps

-- check the number of unique apps in both tables AppleStore

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROm AppleStore
      
SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROm appleStore_description_combined

-- check for any missing values in key fields in both tables

SELECT COUNT(*) AS MissingValues
FROM AppleStore
WHERE track_name is null or user_rating is null or prime_genre is null

SELECT COUNT(*) AS MissingValues
FROM appleStore_description_combined
WHERE app_desc is null

-- find out the number of apps per genre

SELECT prime_genre, COUNT(*) as NumApps
FROM AppleStore
Group by prime_genre
order BY NumApps DESC

-- get an overview of apps ratings

SELECT min(user_rating) as MinRating, 
	   max(user_rating) as MaxRating, 
       avg(user_rating) as AvgRating
FROM AppleStore

**DATA ANALYSIS**

-- determine whether paid apps have higher ratings than free apps

SELECT CASE
            WHEN price > 0 THEN 'Paid'
            ELSE 'Free'
   	   end as App_Type, avg(user_rating) as Avg_Rating
FROM AppleStore
GROUP BY App_Type

-- check whether apps that support more languages have higher ratings

SELECT CASE
			WHEN lang_num < 10 then '<10 languages'
            when lang_num BETWEEN 10 and 30 then '10-30 languages'
            ELSE '>30 languages'
       END AS language_bucket, avg(user_rating) as Avg_Rating
FROM AppleStore
GROUP BY language_bucket
ORDER BY Avg_Rating

-- determine the genres with lower ratings

select prime_genre, avg(user_rating) as Avg_Rating
from AppleStore
group by prime_genre
order by Avg_Rating
LIMIT 10

-- check if there is a correlation between the app length description and the user rating
-- using JOIN and CASE 

SELECT CASE
		when length(b.app_desc) < 500 then 'Short'
        when length(b.app_desc) BETWEEN 500 and 1000 then 'Medium'
        ELSE 'Long'
       end as description_length_bucket, avg(user_rating) AS Avg_Rating
FROM 
	AppleStore as A
JOIN
	appleStore_description_combined as B
ON
 	A.id = B.id
GROUP BY description_length_bucket
ORDER BY Avg_Rating DESC

