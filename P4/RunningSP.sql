-- Running Calculate total cost for each trip 
DECLARE @trip_id BIGINT;

SELECT @trip_id = MIN(trip_id) FROM Trip;

WHILE @trip_id IS NOT NULL
BEGIN
   EXEC TotalCostForTrip @trip_id = @trip_id;
   SELECT @trip_id = MIN(trip_id) FROM Trip WHERE trip_id > @trip_id;
END;