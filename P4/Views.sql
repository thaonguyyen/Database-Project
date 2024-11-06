-- View all airports and associated flights to destinations
CREATE VIEW GetAllAirportAndFlights AS
SELECT A1.airport_id AS Departure_Airport, A1.name AS Departure_Airport_Name, F.flight_id, A2.city AS Arrival_City, A2.[state] AS Arrival_State
FROM Airport A1
LEFT JOIN Flight F ON A1.airport_id = F.airport_id
LEFT JOIN Airport A2 ON F.arrival_airport_id = A2.airport_id
GO

-- View all users that have a planned travel with at least one itinerary and the total amount for all their trips
CREATE VIEW GetALLUsersWithPlannedTravel AS
SELECT U.user_id, U.first_name, U.last_name, COUNT(T.trip_id) AS total_trips, SUM(T.total_cost) AS total_cost
FROM [User] U
INNER JOIN Trip T ON U.user_id = T.user_id
INNER JOIN Itinerary I ON T.trip_id = I.trip_id
GROUP BY U.user_id, U.first_name, U.last_name
GO


