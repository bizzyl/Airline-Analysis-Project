--Creating a real date column
ALTER TABLE dbo.flights
ADD flight_date DATE;

UPDATE dbo.flights
SET flight_date = DATEFROMPARTS(year, month, day);

--Inspecting values
SELECT COUNT(*) AS total_flights
FROM dbo.flights;

--Checking for invalid values
SELECT DISTINCT MONTH
FROM dbo.flights
ORDER BY MONTH;

--Checking for invalid weekdays
SELECT DISTINCT DAY_OF_WEEK
FROM dbo.flights
ORDER BY DAY_OF_WEEK;

--Checking for any other value than 0 or 1
SELECT DISTINCT CANCELLED
FROM dbo.flights;

--Seeing if there are outliers or invalid values for departures
SELECT MIN(DEPARTURE_DELAY) AS min_departure_delay,
       MAX(DEPARTURE_DELAY) AS max_departure_delay
FROM dbo.flights;

SELECT *
FROM dbo.flights
WHERE DEPARTURE_DELAY = 1988;

-- Seeing outliers for arrivals
SELECT 
    MIN(ARRIVAL_DELAY) AS min_arrival_delay,
    MAX(ARRIVAL_DELAY) AS max_arrival_delay
FROM dbo.flights;

SELECT *
FROM dbo.flights
WHERE ARRIVAL_DELAY = 1971;

-- Checking flight date range (All within 2015)
SELECT 
    MIN(flight_date) AS earliest_flight,
    MAX(flight_date) AS latest_flight
FROM dbo.flights;

-- Checking cancellation reasons
SELECT 
    CANCELLATION_REASON,
    COUNT(*) AS num_flights
FROM dbo.flights
WHERE CANCELLED = 1
GROUP BY CANCELLATION_REASON
ORDER BY CANCELLATION_REASON;

-- Checking for invalid air time
SELECT 
    MIN(AIR_TIME) AS min_air_time,
    MAX(AIR_TIME) AS max_air_time
FROM dbo.flights;

-- Checking for negative air time
SELECT COUNT(*) AS negative_air_time
FROM dbo.flights
WHERE AIR_TIME < 0;