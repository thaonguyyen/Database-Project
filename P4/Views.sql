-- View all airports and associated flights to destinations
-- CREATE VIEW GetAllAirportAndFlights AS
-- SELECT A1.airport_id AS Departure_Airport, A1.name AS Departure_Airport_Name, F.flight_id, A2.city AS Arrival_City, A2.[state] AS Arrival_State
-- FROM Airport A1
-- LEFT JOIN Flight F ON A1.airport_id = F.airport_id
-- LEFT JOIN Airport A2 ON F.arrival_airport_id = A2.airport_id

SELECT * FROM GetAllAirportAndFlights;
