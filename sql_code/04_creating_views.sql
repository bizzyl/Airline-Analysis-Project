SELECT * FROM dbo.flights

/* 

Creating Views for PowerBI
	-Overall flight trends
		-Month
			-Month number
			-Number of flights
			-Number of delayed flights
			-Delay percentage
			-Number of cancelled flights
			-Cancellation percentage
		-Day of Week
			-Day of week number
			-Number of flights
			-Number of delayed flights
			-Delay percentage
			-Number of cancelled flights
			-Cancellation percentage
	-Airline performance
		-Average departure delay
		-Average arrival delay
		-Number of flights
		-Cancellation rate
		-Early arrival %
		-Late arrival %
		-Departure delay standard deviation
	-Airport performance
		-Origin Airport
			-Airport name
			-Airport code
			-Number of departures
			-Average departure delay
			-Cancellation rate
		-Destination Airport
			-Airport name
			-Airport code
			-Number of arrivals
			-Average arrival delay
	-Cancellation reasons percentage
*/

SELECT * FROM dbo.flights
SELECT * FROM dbo.airports

--Cancellations by category
CREATE VIEW cancellation_reasons_view AS
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

SELECT * FROM dbo.cancellation_reasons_view

--Monthly flight analysis view
CREATE VIEW monthly_analysis_view AS
SELECT 
DATENAME(month, flight_date) as flight_month,
MONTH(flight_date) as month_num,
COUNT(flight_number) as total_flights,
SUM(CASE WHEN DEPARTURE_DELAY > 0 THEN 1 ELSE 0 END) as delayed_flights,
ROUND(CAST(SUM(CASE WHEN DEPARTURE_DELAY > 0 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(flight_number) * 100, 2) as percent_flights_delayed,
SUM(CANCELLED) as total_cancelled,
ROUND(CAST(SUM(CANCELLED) AS FLOAT) * 100 / COUNT(flight_number), 2) as percent_flights_cancelled
FROM dbo.flights
GROUP BY DATENAME(month, flight_date), MONTH(flight_date) 

--Day of week flight analysis view
CREATE VIEW dow_analysis_view AS
SELECT 
DATENAME(weekday, DATEFROMPARTS(2000, 1, day_of_week + 8)) AS flight_day,
DAY_OF_WEEK as day_num,
COUNT(flight_number) as total_flights,
SUM(CASE WHEN DEPARTURE_DELAY > 0 THEN 1 ELSE 0 END) as delayed_flights,
ROUND(CAST(SUM(CASE WHEN DEPARTURE_DELAY > 0 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(flight_number) * 100, 2) as percent_flights_delayed,
SUM(CANCELLED) as total_cancelled,
ROUND(CAST(SUM(CANCELLED) AS FLOAT) * 100 / COUNT(flight_number), 2) as percent_flights_cancelled
FROM dbo.flights
GROUP BY DATENAME(weekday, DATEFROMPARTS(2000, 1, day_of_week + 8)), DAY_OF_WEEK


--Destination airport view
CREATE VIEW destination_airport_view AS
WITH airport_destination_query AS (
SELECT 
DESTINATION_AIRPORT as destination_airport, 
AIRPORT_NAME as airport, 
COUNT(FLIGHT_NUMBER) as total_flights,
COUNT(ARRIVAL_TIME) as num_arrivals,
AVG(ARRIVAL_DELAY) as avg_arrival_delay_min
FROM dbo.flights as f
LEFT JOIN dbo.airports as ap
ON f.DESTINATION_AIRPORT = ap.AIRPORT_CODE
GROUP BY DESTINATION_AIRPORT, AIRPORT_NAME
HAVING AIRPORT_NAME IS NOT NULL
)

SELECT 
destination_airport,
airport,
num_arrivals,
avg_arrival_delay_min
FROM airport_destination_query

SELECT * FROM destination_airport_view

--Origin airport view
CREATE VIEW origin_airport AS
WITH airport_query AS (
SELECT 
ORIGIN_AIRPORT as origin_airport, 
AIRPORT_NAME as airport, 
SUM(CANCELLED) as num_cancelled,
COUNT(FLIGHT_NUMBER) as total_flights,
COUNT(DEPARTURE_TIME) as num_departures,
AVG(DEPARTURE_DELAY) as avg_departure_delay_min
FROM dbo.flights as f
LEFT JOIN dbo.airports as ap
ON f.ORIGIN_AIRPORT = ap.AIRPORT_CODE
GROUP BY ORIGIN_AIRPORT, AIRPORT_NAME
HAVING AIRPORT_NAME IS NOT NULL
)

SELECT 
origin_airport,
airport,
num_cancelled,
CONCAT(ROUND(CAST(num_cancelled AS FLOAT) * 100 / total_flights, 2), '%') as cancellation_rate,
num_departures,
avg_departure_delay_min
FROM airport_query

SELECT * FROM origin_airport

--Airline view 
CREATE VIEW airline_performance AS
WITH base_query AS (
SELECT
AIRLINE_NAME as airline, 
AVG(DEPARTURE_DELAY) as avg_departure_delay_min,
AVG(ARRIVAL_DELAY) as avg_arrival_delay_min,
COUNT(FLIGHT_NUMBER) as num_flights,
SUM(CANCELLED) as num_cancelled,
SUM(CASE WHEN ARRIVAL_DELAY < 0 THEN 1 ELSE 0 END) as num_early_arrivals, 
SUM(CASE WHEN ARRIVAL_DELAY > 0 THEN 1 ELSE 0 END) as num_late_arrivals, 
ROUND(STDEV(DEPARTURE_DELAY),2) as departure_std_delay
FROM dbo.flights f
LEFT JOIN dbo.airlines a
ON f.AIRLINE_CODE = a.AIRLINE_CODE
GROUP BY AIRLINE_NAME
)

SELECT 
airline, 
num_flights,
num_cancelled,
ROUND(CAST(num_cancelled AS FLOAT) * 100 / num_flights, 2) as percent_cancellation_rate,
avg_departure_delay_min,
departure_std_delay,
avg_arrival_delay_min,
ROUND(CAST(num_late_arrivals AS FLOAT) * 100 / num_flights, 2) as percent_late_arrivals,
ROUND(CAST(num_early_arrivals AS FLOAT) * 100 / num_flights, 2) as percent_early_arrivals
FROM base_query

SELECT * FROM airline_performance;

