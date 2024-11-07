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
CREATE PROCEDURE GetTripDetails
   @trip_id BIGINT
AS
BEGIN
   SELECT *
   FROM Itinerary i
   JOIN Itinerary_Picked_Hotel iph ON i.itinerary_id = iph.itinerary_id AND i.trip_id = iph.trip_id
   JOIN Destination d ON i.destination_id = d.destination_id
   WHERE i.trip_id = @trip_id;
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

