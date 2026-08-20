**Airline Analysis Project**

This project analyses a dataset with 5,000,000+ commercial airline flight records in 2015, compiled for the U.S. DOT Air Travel Consumer Report.
The goal of this project is to evaluate airline reliability, delay patterns, cancellation reasons, airport performance, and operational trends using SQL and PowerBI.

**SQL Workflow**
1.Created tables and inserted the data
2. Checking the data for any outliers and invalid, missing, or null values.
3. Running Analysis on Flights, Airlines, and Airports

  Overall Analysis of Flights 
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
    
  Overall Analysis of Airlines
	-Average departure delay by airline (most and least reliable)
	-Average arrival delay by airline (most and least reliable)
	-Which airline has the most flights
	-Which airline has the highest cancellation rates
	-Which airline has the highest percentage of flights that arrive early?
	-Which airline has the highest percentage of flights that arrive late?
	-Which airline has the most consistent departure times? - standard deviation

  Overall Analysis of Airlines
	-Highest / loest average arrival delay by airport
	-Highest / lowest average departure delay by airport
	-Average delay by route - are certain origin to destination combinations particularly problematic?
	-Which airports have the highest cancellation rate?

4. Creating views for easier analysis and importing them into PowerBI


**PowerBi Workflow**
Created 5 dashboards:
1. Overall flight analysis
   - Total flights
   - Delayed flights
   - Cancellation rate
   - Flights by day, month
2. Flight delay analysis
   - Delay reasons
   - Number/Percentage of flights delayed by day
   - Number/Percentage of flights delayed by month
3. Flight cancellation analysis
   - Cancellation reasons
   - Number/Percentage of flights cancelled by day
   -  Number/Percentage of flights cancelled by month
4. Airline Analysis
   - Slicer to choose any airline
   - Top cancellation rates of airlines
   - Most consistent airlines by departure times
   - Average departure and arrival delay
   - Percent Early and Late Arrivals
5. Airport Analysis
   - Number of arrivals by airport
   - Cancellation Rate of airports
   - Average departure delay by airport
   - average arrival delay by airport

  Key insights:
  Friday had a much lower amount of flight volume compared to the other days.
  About 37% of all flights were delayed, and about 1.5% of all flights were cancelled.
  February had a cancellation rate of 5% among all flights, which was significantly higher than every other month
  Weather was the biggest reason why flights were cancelled.
  The majority of airlines had more early flights compared to late flights.

Tech Stack:
SQL (Data inspection, data cleaning, transformation, aggregating, creating CTE's and views)
PowerBI (Dashboarding, modeling, KPI cards)
  
