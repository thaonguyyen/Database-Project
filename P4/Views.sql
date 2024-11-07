-- View all airports and associated flights to destinations
CREATE VIEW GetAllAirportAndFlights AS
SELECT 
    A1.airport_id AS Departure_Airport, 
    A1.name AS Departure_Airport_Name, 
    COALESCE(CAST(F.flight_id AS VARCHAR), 'No Flights') AS Flight_ID, 
    COALESCE(A2.city, 'None') AS Arrival_City, 
    COALESCE(A2.[state], 'None') AS Arrival_State
FROM Airport A1
LEFT JOIN Flight F ON A1.airport_id = F.airport_id
LEFT JOIN Airport A2 ON F.arrival_airport_id = A2.airport_id
GO

-- View all users that have a planned travel with at least one itinerary and the total amount for all their trips
CREATE VIEW GetALLUsersWithPlannedTravel AS
SELECT U.user_id, U.first_name, U.last_name, COUNT(T.trip_id) AS total_trips, SUM(T.total_cost) AS total_cost
FROM [User] U
INNER JOIN Trip T ON U.user_id = T.user_id
GROUP BY U.user_id, U.first_name, U.last_name
GO

-- List all the destinations and the number of people that are visiting each one
CREATE VIEW GetDestinationAndNumberOfVisitors AS
SELECT D.destination_id, D.city, D.[state], COUNT(DISTINCT T.user_id) AS number_of_visitors
FROM Destination D
LEFT JOIN Itinerary I ON D.airport_id = I.arrival_airport_id
LEFT JOIN Trip T ON I.trip_id = T.trip_id
GROUP BY D.destination_id, D.city, D.[state]
GO

SELECT * FROM GetAllAirportAndFlights;
SELECT * FROM GetALLUsersWithPlannedTravel;
SELECT * FROM GetDestinationAndNumberOfVisitors;
