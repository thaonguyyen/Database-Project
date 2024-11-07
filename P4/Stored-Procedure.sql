-- Adds a selected hotel to a user's itinerary. Called when a user chooses a hotel for their trip and updates the Itinerary_Picked_Hotel table to reflect the chosen hotel, room type, and associated costs.
GO
CREATE PROCEDURE AddHotelToItinerary
   @itinerary_id BIGINT,
   @trip_id BIGINT,
   @destination_id BIGINT,
   @hotel_id BIGINT,
   @room_type VARCHAR(50),
   @cost BIGINT
AS
BEGIN
   INSERT INTO Itinerary_Picked_Hotel (itinerary_id, trip_id, destination_id, hotel_id, room_type, cost)
   VALUES (@itinerary_id, @trip_id, @destination_id, @hotel_id, @room_type, @cost);
END;
GO


-- Retrieves all details related to a specific trip, including destinations, hotels, activities, and total costs. Allows users to review their trip details before finalizing plans.
-- CREATE PROCEDURE GetTripDetails
--    @trip_id BIGINT
-- AS
-- BEGIN
--    SELECT *
--    FROM Itinerary i
--    JOIN Itinerary_Picked_Hotel iph ON i.itinerary_id = iph.itinerary_id AND i.trip_id = iph.trip_id
--    JOIN Destination d ON i.destination_id = d.destination_id
--    WHERE i.trip_id = @trip_id;
-- END;
-- GO

-- Delete a selected hotel from a user's itinerary. Called when a user decides to remove a hotel from their trip and updates the Itinerary_Picked_Hotel table to reflect the change
CREATE PROCEDURE DeleteHotelFromItinerary
   @itinerary_id BIGINT,
   @trip_id BIGINT
AS
BEGIN
   -- Check for existence of this hotel reservation
   IF NOT EXISTS (SELECT 1 FROM Itinerary_Picked_Hotel WHERE itinerary_id = @itinerary_id AND trip_id = @trip_id)
   BEGIN
      RAISERROR('Hotel does not exist in the itinerary', 16, 1);
      RETURN;
   END;

   -- Get the hotel cost
   DECLARE @hotel_cost BIGINT
   SELECT @hotel_cost = cost
   FROM Itinerary_Picked_Hotel
   WHERE itinerary_id = @itinerary_id AND trip_id = @trip_id;

   -- Check if the total_cost would be negative for the Itinerary or Trip
   IF (SELECT total_cost - @hotel_cost FROM Itinerary WHERE itinerary_id = @itinerary_id) < 0 OR
      (SELECT total_cost - @hotel_cost FROM Trip WHERE trip_id = @trip_id) < 0
   BEGIN
      RAISERROR('Subtracting this hotel cost would result in a negative total cost', 16, 1);
      RETURN;
   END;

   -- Subtracting total cost in itinerary
   Update Itinerary
   SET total_cost = total_cost - @hotel_cost
   WHERE itinerary_id = @itinerary_id AND trip_id = @trip_id;

   -- Subtracting total cost in trip
   Update Trip
   SET total_cost = total_cost - @hotel_cost
   WHERE trip_id = @trip_id;

   -- Delete from the picked table 
   DELETE FROM Itinerary_Picked_Hotel
   WHERE itinerary_id = @itinerary_id AND trip_id = @trip_id;
END;
GO

-- Calculates and updates the total costs for each itinerary for a specified trip and then aggregates these costs to update the overall cost of the trip itself in the Trip table
CREATE PROCEDURE TotalCostForTrip
   @trip_id BIGINT
AS
BEGIN
   DECLARE @tripTotalCost BIGINT = 0;

   UPDATE Itinerary
   SET total_cost = dbo.CalculateItineraryCost(itinerary_id, @trip_id)
   WHERE trip_id = @trip_id;

   SELECT @tripTotalCost = SUM(total_cost)
   FROM Itinerary
   WHERE trip_id = @trip_id;


   UPDATE Trip
   SET total_cost = @tripTotalCost
   WHERE trip_id = @trip_id;
END;
GO