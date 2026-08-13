
--Inspecting the data
SELECT * 
FROM dbo.airports
SELECT * 
FROM dbo.cancellation_codes;
SELECT * 
FROM dbo.flights;
SELECT * 
FROM dbo.airlines;
SELECT COUNT(*) as total_num_flights
FROM dbo.flights;

--Creating a real date column
ALTER TABLE dbo.flights
ADD flight_date DATE;

UPDATE dbo.flights
SET flight_date = DATEFROMPARTS(year, month, day);

/* Overall Analysis of Flights 
	-Flight volume by month
	-Flight volume by day of week
	-Percent of flights that had a departure delay
	-Average delay time of all flights
	-Percent delayed flights every month
	-Percent delayed flights by week day
	-Total flights cancelled
	-Flight cancellations by month
	-Percent cancellations due to weather
	-Percent cancellations due to airline / carrier
	-Number of flights that arrive early / late
	-Top 10 Longest Departure Delays
	-Top 10 Earliest Departures
*/


--Overall flight volume by month, day of week
-- By month
WITH flight_by_month AS(
SELECT 
DATENAME(month, flight_date) AS flight_month,
MONTH(flight_date) as month_num,
COUNT(FLIGHT_NUMBER) as num_flights
FROM dbo.flights
GROUP BY  DATENAME(month, flight_date), MONTH(flight_date)
)

SELECT 
flight_month,
num_flights,
CONCAT(ROUND((CAST(num_flights AS FLOAT) / SUM(num_flights) OVER ()) * 100, 2), '%') AS percent_flights
FROM flight_by_month
ORDER BY month_num;

--Overall flight volume by day of week
WITH flight_by_dow AS(
SELECT 
DATENAME(weekday, DATEFROMPARTS(2000, 1, day_of_week + 8)) AS weekday_name,
-- Assuming that DATE_OF_WEEK has 1 = Sunday, 2 = Monday, ..
DAY_OF_WEEK as dow_num,
COUNT(FLIGHT_NUMBER) as num_flights
FROM dbo.flights
GROUP BY DATENAME(weekday, DATEFROMPARTS(2000, 1, day_of_week + 8)), DAY_OF_WEEK
)

SELECT 
weekday_name,
dow_num,
num_flights,
CONCAT(ROUND((CAST(num_flights AS FLOAT) / SUM(num_flights) OVER ()) * 100, 2), '%') AS percent_flights
FROM flight_by_dow
ORDER BY dow_num;


--What percentage of flights experienced a departure delay?

SELECT CONCAT(ROUND(CAST(SUM(CASE WHEN DEPARTURE_DELAY > 0 THEN 1
	ELSE 0
	END) AS FLOAT) / COUNT(DEPARTURE_DELAY) * 100, 2),'%') as total_perc_flights_delayed
FROM dbo.flights
;

--What was the average delay time in minutes?

SELECT AVG(DEPARTURE_DELAY) as avg_delayed_min
FROM dbo.flights
WHERE DEPARTURE_DELAY > 0;


--How does the % of delayed flights vary throughout the year? 

WITH percent_delay_flights_month AS (SELECT 
DATENAME(month, flight_date) AS flight_month,
MONTH(flight_date) as month_num,
SUM(CASE 
	WHEN DEPARTURE_DELAY > 0 THEN 1
	ELSE 0
	END) as delayed_flights,
COUNT(DEPARTURE_DELAY) as total_flights
FROM dbo.flights
GROUP BY DATENAME(month, flight_date), MONTH(flight_date))

SELECT 
flight_month,
month_num,
delayed_flights,
total_flights,
CONCAT(ROUND(CAST(delayed_flights as FLOAT) / total_flights * 100, 2),'%') as percent_flights_delayed_by_month
FROM percent_delay_flights_month
ORDER BY month_num;

--How does % of delayed flights vary throughout the week days?

WITH percent_delay_flights_weekdays AS (SELECT 
DATENAME(weekday, DATEFROMPARTS(2000, 1, DAY_OF_WEEK + 8)) AS weekdays,
DAY_OF_WEEK as week_num,
SUM(CASE 
	WHEN DEPARTURE_DELAY > 0 THEN 1
	ELSE 0
	END) as delayed_flights,
COUNT(DEPARTURE_DELAY) as total_flights
FROM dbo.flights
GROUP BY DATENAME(weekday, DATEFROMPARTS(2000, 1, DAY_OF_WEEK + 8)), DAY_OF_WEEK)

SELECT 
weekdays,
week_num,
delayed_flights,
total_flights,
CONCAT(ROUND(CAST(delayed_flights as FLOAT) / total_flights * 100, 2),'%') as percent_flights_delayed_by_day
FROM percent_delay_flights_weekdays
ORDER BY week_num;

--How many flights were cancelled in 2015? 
SELECT COUNT(CANCELLED) as cancelled_flights
FROM dbo.flights
WHERE CANCELLED != 0;

--Cancellations by month
SELECT 
DATENAME(month, flight_date) as month, 
MONTH(flight_date) as month_num,
SUM(CANCELLED) as cancelled_flights
FROM dbo.flights
GROUP BY DATENAME(month, flight_date), MONTH(flight_date)
ORDER BY MONTH(flight_date) 

-- % of cancellations by category
WITH cancellation_dist AS (SELECT CANCELLATION_DESCRIPTION as cancellation_reason, 
SUM(CASE WHEN f.CANCELLATION_REASON IS NOT NULL THEN 1 ELSE 0 END) as cancelled_flights
FROM dbo.flights as f
LEFT JOIN dbo.cancellation_codes as cc
ON f.CANCELLATION_REASON = cc.CANCELLATION_REASON
GROUP BY CANCELLATION_DESCRIPTION
HAVING SUM(CASE WHEN f.CANCELLATION_REASON IS NOT NULL THEN 1 ELSE 0 END) != 0)

SELECT 
cancellation_reason, 
cancelled_flights, 
CONCAT(ROUND(CAST(cancelled_flights as FLOAT) / SUM(cancelled_flights) OVER() * 100, 2),'%') as percent_cancelled_flights
FROM cancellation_dist
ORDER BY cancelled_flights DESC


-- What % of cancellations were due to weather? 
SELECT SUM(CASE WHEN CANCELLATION_REASON = 'B' THEN 1 ELSE 0 END) as weather_cancel,
	   SUM(CANCELLED) as total_cancelled,
	   CONCAT(ROUND(CAST(SUM(CASE WHEN CANCELLATION_REASON = 'B' THEN 1 ELSE 0 END) AS FLOAT) * 100, 2) / SUM(CANCELLED), '%') as percent_cancelled_weather
FROM dbo.flights

-- What % were due to the Airline/Carrier?
SELECT SUM(CASE WHEN CANCELLATION_REASON = 'A' THEN 1 ELSE 0 END) as ac_cancel,
	   SUM(CANCELLED) as total_cancelled,
	   CONCAT(ROUND(CAST(SUM(CASE WHEN CANCELLATION_REASON = 'A' THEN 1 ELSE 0 END) AS FLOAT) * 100, 2) / SUM(CANCELLED), '%') as percent_cancelled_ac
FROM dbo.flights

--Number of flights that arrive early / late
SELECT SUM(CASE WHEN ARRIVAL_DELAY < 0 THEN 1 ELSE 0 END) as num_early_arrivals,
	   SUM(CASE WHEN ARRIVAL_DELAY > 0 THEN 1 ELSE 0 END) as num_late_arrivals
FROM dbo.flights

--Top 10 Longest Departure Delays
WITH delay_rank_cte AS 
(SELECT ORIGIN_AIRPORT, AIRPORT_NAME, AIRLINE_NAME, DEPARTURE_DELAY, RANK() OVER(ORDER BY DEPARTURE_DELAY DESC) as delay_rank
FROM dbo.flights as f
LEFT JOIN dbo.airports as ap
ON f.ORIGIN_AIRPORT = ap.AIRPORT_CODE
LEFT JOIN dbo.airlines as al
ON f.AIRLINE_CODE = al.AIRLINE_CODE
WHERE DEPARTURE_DELAY IS NOT NULL)

SELECT ORIGIN_AIRPORT, AIRPORT_NAME, AIRLINE_NAME, DEPARTURE_DELAY, delay_rank
FROM delay_rank_cte
WHERE delay_rank <= 10;

--Top 10 Earliest Departures
WITH early_rank_cte AS 
(SELECT ORIGIN_AIRPORT, AIRPORT_NAME, AIRLINE_NAME, DEPARTURE_DELAY, RANK() OVER(ORDER BY DEPARTURE_DELAY ASC) as early_rank
FROM dbo.flights as f
LEFT JOIN dbo.airports as ap
ON f.ORIGIN_AIRPORT = ap.AIRPORT_CODE
LEFT JOIN dbo.airlines as al
ON f.AIRLINE_CODE = al.AIRLINE_CODE
WHERE DEPARTURE_DELAY IS NOT NULL)

SELECT ORIGIN_AIRPORT, AIRPORT_NAME, AIRLINE_NAME, DEPARTURE_DELAY, early_rank
FROM early_rank_cte
WHERE early_rank <= 10;

/* Overall Analysis of Airlines
	-Average departure delay by airline (most and least reliable)
	-Average arrival delay by airline (most and least reliable)
	-Which airline has the most flights
	-Which airline has the highest cancellation rates
	-Which airline has the highest percentage of flights that arrive early?
	-Which airline has the highest percentage of flights that arrive late?
	-Which airline has the most consistent departure times? - standard deviation
*/

-- Average departure delay by airline
SELECT AIRLINE_NAME, AVG(DEPARTURE_DELAY) as avg_dep_delay
FROM dbo.flights f
LEFT JOIN dbo.airlines a
ON f.AIRLINE_CODE = a.AIRLINE_CODE
GROUP BY AIRLINE_NAME
ORDER BY AVG(DEPARTURE_DELAY);

-- Average arrival delay by airline  

SELECT AIRLINE_NAME, AVG(ARRIVAL_DELAY) as avg_arrival_delay
FROM dbo.flights as f
LEFT JOIN dbo.airlines as al
ON f.AIRLINE_CODE = al.AIRLINE_CODE
GROUP BY AIRLINE_NAME
ORDER BY AVG(ARRIVAL_DELAY);

--Which airline had the most flights?

SELECT AIRLINE_NAME, COUNT(FLIGHT_NUMBER) as num_flights
FROM dbo.flights as f
LEFT JOIN dbo.airlines as al
ON f.AIRLINE_CODE = al.AIRLINE_CODE
GROUP BY AIRLINE_NAME
ORDER BY COUNT(FLIGHT_NUMBER) DESC;

--Which airline has the highest cancellation rates
WITH cancellation_rates as (
SELECT AIRLINE_NAME, SUM(CANCELLED) as num_cancelled
FROM dbo.flights as f
LEFT JOIN dbo.airlines as al
ON f.AIRLINE_CODE = al.AIRLINE_CODE
GROUP BY AIRLINE_NAME
)
SELECT AIRLINE_NAME, 
num_cancelled,
CONCAT(ROUND(CAST(num_cancelled AS FLOAT) * 100 / (SUM(num_cancelled) OVER()), 2), '%') as cancellation_rate
FROM cancellation_rates
ORDER BY num_cancelled DESC;

--Which airline has the highest percentage of flights that arrive early?
WITH early_flights AS (
SELECT AIRLINE_NAME, 
SUM(CASE WHEN ARRIVAL_DELAY < 0 THEN 1 ELSE 0 END) as num_early_arrivals, 
COUNT(ARRIVAL_DELAY) as total_flights
FROM dbo.flights as f
LEFT JOIN dbo.airlines as al
ON f.AIRLINE_CODE = al.AIRLINE_CODE
GROUP BY AIRLINE_NAME)

SELECT 
AIRLINE_NAME, 
num_early_arrivals, 
CONCAT(ROUND(CAST(num_early_arrivals AS FLOAT) * 100 / total_flights, 2), '%') as early_arrivals
FROM early_flights 
ORDER BY early_arrivals DESC

--Which airline has the highest percentage of flights that arrive late?

WITH late_flights AS (
SELECT AIRLINE_NAME, 
SUM(CASE WHEN ARRIVAL_DELAY > 0 THEN 1 ELSE 0 END) as num_late_arrivals, 
COUNT(ARRIVAL_DELAY) as total_flights
FROM dbo.flights as f
LEFT JOIN dbo.airlines as al
ON f.AIRLINE_CODE = al.AIRLINE_CODE
GROUP BY AIRLINE_NAME)

SELECT 
AIRLINE_NAME, 
num_late_arrivals, 
CONCAT(ROUND(CAST(num_late_arrivals AS FLOAT) * 100 / total_flights, 2), '%') as late_arrivals
FROM late_flights 
ORDER BY late_arrivals DESC

--Which airline has the most consistent departure times? - standard deviation

SELECT AIRLINE_NAME, AVG(DEPARTURE_DELAY) as avg_delay, ROUND(STDEV(DEPARTURE_DELAY),2) as std_delay
FROM dbo.flights as f
LEFT JOIN dbo.airlines as al
ON f.AIRLINE_CODE = al.AIRLINE_CODE
GROUP BY AIRLINE_NAME
ORDER BY STDEV(DEPARTURE_DELAY)

/* Overall Analysis of Airlines
	-Highest / loest average arrival delay by airport
	-Highest / lowest average departure delay by airport
	-Average delay by route - are certain origin to destination combinations particularly problematic?
	-Which airports have the highest cancellation rate?
*/


--Average arrival delay by airport (excluding 5-digit-number airports)
SELECT DESTINATION_AIRPORT, AIRPORT_NAME, AVG(ARRIVAL_DELAY) as avg_delay
FROM dbo.flights as f
LEFT JOIN dbo.airports as ap
ON f.DESTINATION_AIRPORT = ap.AIRPORT_CODE
GROUP BY DESTINATION_AIRPORT, AIRPORT_NAME
HAVING AIRPORT_NAME IS NOT NULL
ORDER BY avg_delay DESC;


--Average departure delay by airport (excluding the 5-digit number airports)
SELECT ORIGIN_AIRPORT, AIRPORT_NAME, AVG(DEPARTURE_DELAY) as avg_delay
FROM dbo.flights as f
LEFT JOIN dbo.airports as ap
ON f.ORIGIN_AIRPORT = ap.AIRPORT_CODE
GROUP BY ORIGIN_AIRPORT, AIRPORT_NAME
HAVING AIRPORT_NAME IS NOT NULL
ORDER BY avg_delay;

--Average delay by route - are certain origin to destination combinations particularly problematic?
WITH delay_route AS (SELECT ORIGIN_AIRPORT, DESTINATION_AIRPORT, AVG(DEPARTURE_DELAY) as avg_delay
FROM dbo.flights
GROUP BY ORIGIN_AIRPORT, DESTINATION_AIRPORT)

SELECT ORIGIN_AIRPORT, DESTINATION_AIRPORT, avg_delay
FROM delay_route
WHERE avg_delay IS NOT NULL
ORDER BY avg_delay;

--Which airports have the highest cancellation rates

WITH cancellation_rates as (
SELECT AIRPORT_NAME, SUM(CANCELLED) as num_cancelled
FROM dbo.flights as f
LEFT JOIN dbo.airports as ap
ON f.ORIGIN_AIRPORT = ap.AIRPORT_CODE
GROUP BY AIRPORT_NAME
HAVING AIRPORT_NAME IS NOT NULL
)
SELECT AIRPORT_NAME, 
num_cancelled,
CONCAT(ROUND(CAST(num_cancelled AS FLOAT) * 100 / (SUM(num_cancelled) OVER()), 2), '%') as cancellation_rate
FROM cancellation_rates
ORDER BY num_cancelled DESC;