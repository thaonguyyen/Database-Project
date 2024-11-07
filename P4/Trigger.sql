--trigger to update total trip cost if an itinerary changes
CREATE OR ALTER TRIGGER UpdateTripTotalCost
ON Itinerary
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
   SET NOCOUNT ON;

   -- handle new itineraries (INSERT)
   IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
   BEGIN
      UPDATE Trip
      SET Trip.total_cost = Trip.total_cost + inserted.total_cost
      FROM Trip
      INNER JOIN inserted ON Trip.trip_id = inserted.trip_id;
   END

   -- handle updated itineraries (UPDATE)
   IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
   BEGIN
      UPDATE Trip
      SET Trip.total_cost = Trip.total_cost + (inserted.total_cost - deleted.total_cost)
      FROM Trip
      INNER JOIN inserted ON Trip.trip_id = inserted.trip_id
      INNER JOIN deleted ON Trip.trip_id = deleted.trip_id;
   END

   -- handle deleted itineraries (DELETE)
   IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
   BEGIN
      UPDATE Trip
      SET Trip.total_cost = Trip.total_cost - deleted.total_cost
      FROM Trip
      INNER JOIN deleted ON Trip.trip_id = deleted.trip_id;
   END
END;