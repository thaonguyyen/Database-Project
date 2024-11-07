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