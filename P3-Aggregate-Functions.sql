-- How many people are traveling to New York
SELECT city, COUNT(trip_id) AS number_traveling_to_new_york
FROM (
    SELECT D.city, I.trip_id
    FROM Itinerary I
    INNER JOIN Destination D ON I.destination_id = D.destination_id
    WHERE D.city = 'New York'
    GROUP BY I.trip_id
) AS NY_traveled
GROUP BY city; 

