-- How many people are traveling to New York (Aggregate & Subquery & Join)
SELECT COUNT(*) AS number_traveling_to_new_york
FROM (
    SELECT I.trip_id
    FROM Itinerary I
    INNER JOIN Destination D ON I.destination_id = D.destination_id
    WHERE D.[state] = 'New York'
    GROUP BY I.trip_id
) AS NY_traveled;

-- Who are all staying hotels with the highest price range (Subquery & Join)
SELECT DISTINCT u.first_name, u.last_name
FROM [User] u
WHERE u.user_id IN (
    SELECT user_id
    FROM Trip T
    WHERE T.trip_id IN (
        SELECT trip_id 
        FROM Itinerary I
        WHERE I.itinerary_id IN (
            SELECT itinerary_id
            FROM Itinerary_Picked_Hotel IH
            INNER JOIN Hotel H ON H.hotel_id = IH.hotel_id
            WHERE H.price_range = '$$$'
        )
    )
);

-- Get all itineraries for Michael Johnson (Join)
SELECT * 
FROM Itinerary I
INNER JOIN Trip T ON I.trip_id = T.trip_id
INNER JOIN [User] U ON T.user_id = U.user_id
WHERE U.first_name = 'Michael' AND U.last_name = 'Johnson';

-- Find the three most expensive chosen hotel (Join)
SELECT TOP 3 H.hotel_id, H.name, H.price_range, IPH.cost
FROM Hotel H
JOIN Itinerary_Picked_Hotel IPH ON IPH.hotel_id = H.hotel_id
ORDER BY IPH.cost DESC

-- Find the average cost of each hotel chosen (Aggregate & Join)
SELECT H.hotel_id, H.name, H.price_range, AVG(cost) AS average_cost
FROM Hotel H
JOIN Itinerary_Picked_Hotel IPH ON IPH.hotel_id = H.hotel_id
GROUP BY H.hotel_id, H.name, H.price_range;

-- Find all flights from Texas (Subquery)
SELECT DISTINCT F.airport_id, F.flight_id, F.departure_time, F.arrival_time, F.airline
FROM Flight F
WHERE EXISTS (
    SELECT 1
    FROM Airport A
    WHERE A.[state] = 'Texas'
    AND F.airport_id = A.airport_id
);

-- Find all activites in New York City with cost less than $100 (Join)
SELECT A.name, A.category, DA.cost
FROM Activity A
INNER JOIN Destination_Activity DA ON DA.activity_id = A.activity_id
INNER JOIN Destination D ON DA.destination_id = D.destination_id
WHERE D.city = 'New York City' AND DA.cost < 100;

-- Find the average rating for each destination (Subquery & Join & Aggregate)
SELECT RD.city, RD.[state], AVG(RD.star_rating) AS avg_rating
FROM (
    SELECT R.destination_id, D.city, D.[state], R.star_rating
    FROM Review R
    JOIN Destination D ON D.destination_id = R.destination_id
) AS RD
GROUP BY RD.destination_id, RD.city, RD.[state]

-- Get the money spent on trips from each user that has a trip planned (Aggregate & Join)
SELECT U.user_id, SUM(total_cost) AS total_money_spent
FROM [User] U
JOIN Trip T ON T.user_id = U.user_id
GROUP BY U.user_id;

-- Who spends the most time on activites (Aggregate & Join)
SELECT TOP 1 U.user_id, U.first_name, U.last_name, SUM(duration) AS total_time_spent
FROM [User] U
JOIN Trip T ON T.user_id = U.user_id
JOIN Itinerary I ON T.trip_id = I.trip_id
JOIN Itinerary_Picked_Activity IPA ON IPA.itinerary_id = I.itinerary_id
GROUP BY U.user_id, U.first_name, U.last_name
ORDER BY SUM(IPA.duration) DESC;