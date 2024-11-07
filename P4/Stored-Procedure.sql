-- FUNCTIONS


-- Calculates the total cost for the given itinerary_id and can be used whenever users make changes to items within that specific itinerary. Keeps the cost updated dynamically.
CREATE FUNCTION dbo.CalculateItineraryCost
   (@itinerary_id BIGINT, @trip_id BIGINT)
RETURNS BIGINT
AS
BEGIN
   DECLARE @itineraryCost BIGINT;


   SELECT @itineraryCost =
       ISNULL(SUM(iph.cost), 0) + ISNULL(SUM(ia.duration * da.cost), 0)
   FROM Itinerary_Picked_Hotel iph
   LEFT JOIN Itinerary_Picked_Activity ia ON iph.itinerary_id = ia.itinerary_id AND iph.trip_id = ia.trip_id
   LEFT JOIN Destination_Activity da ON ia.destination_id = da.destination_id AND ia.activity_id = da.activity_id
   WHERE iph.itinerary_id = @itinerary_id AND iph.trip_id = @trip_id;


   RETURN @itineraryCost;
END;
GO


-- Calculates the average rating for a given desination
CREATE FUNCTION dbo.GetAverageRating
   (@destinationId BIGINT)
RETURNS FLOAT
AS
BEGIN
   DECLARE @averageRating FLOAT;
   SELECT @averageRating = AVG(star_rating)
   FROM Review
   WHERE destination_id = @destinationId;
   RETURN @averageRating;
END;
GO


-- Calculates the total cost of activities for a given itinerary. Users can see how much they will be spending on activities in their itinerary, allowing them to manage their travel budget more effectively.
CREATE FUNCTION dbo.CalculateTotalActivityCost (@itinerary_id BIGINT)
RETURNS BIGINT
AS
BEGIN
   DECLARE @totalActivityCost BIGINT;


   SELECT @totalActivityCost = ISNULL(SUM(ia.duration * da.cost), 0)
   FROM Itinerary_Picked_Activity ia
   JOIN Destination_Activity da ON ia.activity_id = da.activity_id AND ia.destination_id = da.destination_id
   WHERE ia.itinerary_id = @itinerary_id;


   RETURN @totalActivityCost;
END;
GO




-- PROCEDURES


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

