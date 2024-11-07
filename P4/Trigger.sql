--trigger to update total trip cost if an itinerary changes
GO
CREATE TRIGGER UpdateTripTotalCost
ON Itinerary
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
   SET NOCOUNT ON;

   --handle new itineraries
   IF EXISTS (SELECT * FROM inserted)
   BEGIN
      --update total trip cost by summing all itineraries
      UPDATE Trip
      SET total_cost = (
         SELECT SUM(total_cost)
         FROM Itinerary
         WHERE Itinerary.trip_id = Trip.trip_id
      )
      FROM Trip
      INNER JOIN inserted ON Trip.trip_id = inserted.trip_id;
   END

   --handle deleted itineraries
   IF EXISTS (SELECT * FROM deleted)
   BEGIN
      --update trip by summing remaining itineraries
      UPDATE Trip
      SET total_cost = (
         SELECT SUM(total_cost)
         FROM Itinerary
         WHERE Itinerary.trip_id = Trip.trip_id
      )
      FROM Trip
      INNER JOIN deleted ON Trip.trip_id = deleted.trip_id;
   END
END;

