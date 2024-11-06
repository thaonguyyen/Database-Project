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
END
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
END


GO


-- FUNCTIONS
-- Calculates the total cost of a trip based on selected hotels and activites. Called whenever a user adds or removes items from their itinerary to dynamically update the total trip cost.
CREATE FUNCTION CalculateTotalCost
   (@trip_id BIGINT)
RETURNS BIGINT
AS
BEGIN
   DECLARE @totalCost BIGINT;


   SELECT @totalCost = ISNULL(SUM(iph.cost), 0) + ISNULL(SUM(ia.duration * da.cost), 0)
   FROM Itinerary_Picked_Hotel iph
   LEFT JOIN Itinerary_Picked_Activity ia ON iph.trip_id = ia.trip_id
   LEFT JOIN Destination_Activity da ON ia.destination_id = da.destination_id AND ia.activity_id = da.activity_id
   WHERE iph.trip_id = @trip_id;


   RETURN @totalCost;
END


GO
-- Calculates the average rating for a given desination
CREATE FUNCTION GetAverageRating
   (@destinationId BIGINT)
RETURNS FLOAT
AS
BEGIN
   DECLARE @averageRating FLOAT;
   SELECT @averageRating = AVG(star_rating)
   FROM Review
   WHERE destination_id = @destinationId;
   RETURN @averageRating;
END
GO
