--non-clustered indexes
--filter activities by category
CREATE NONCLUSTERED INDEX idx_ActivityCategory ON Activity(category);

--filter flight airlines
CREATE NONCLUSTERED INDEX idx_FlightAirline ON Flight(airline);

--filter reviews based on numerical star rating
CREATE NONCLUSTERED INDEX idx_StarRating ON Review(star_rating);
