--TABLE CREATION
CREATE TABLE [User] (
	user_id BIGINT NOT NULL,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	email VARCHAR(50) NOT NULL,
	[password] VARCHAR(50) NOT NULL,
	city VARCHAR(50),
	[state] VARCHAR(50),
	date_of_birth DATE
	CONSTRAINT User_PK PRIMARY KEY (user_id)
);

CREATE TABLE Trip (
	trip_id BIGINT NOT NULL,
	user_id BIGINT NOT NULL,
	number_of_people INT,
	total_cost BIGINT,
	CONSTRAINT Trip_PK PRIMARY KEY (trip_id),
	CONSTRAINT Trip_User_FK FOREIGN KEY (user_id) REFERENCES [User](user_id)
);

CREATE TABLE Airport (
	airport_id VARCHAR(3),
	[name] VARCHAR(100),
	city VARCHAR(50),
	[state] VARCHAR(50),
	CONSTRAINT Airport_PK PRIMARY KEY (airport_id)
);

CREATE TABLE Destination (
	destination_id BIGINT NOT NULL,
	city VARCHAR(50) NOT NULL,
	[state] VARCHAR(50) NOT NULL,
	airport_id VARCHAR(3) NOT NULL,
	CONSTRAINT Destination_PK PRIMARY KEY (destination_id),
	CONSTRAINT Destination_Airport_FK FOREIGN KEY (airport_id) REFERENCES Airport(airport_id)
);

CREATE TABLE Flight (
	airport_id VARCHAR(3) NOT NULL,
	flight_id BIGINT NOT NULL,
	departure_time TIME,
	arrival_time TIME,
	airline VARCHAR(50),
   arrival_airport_id VARCHAR(3),
	CONSTRAINT Flight_PK PRIMARY KEY (airport_id, flight_id),
	CONSTRAINT Flight_Airport_FK FOREIGN KEY (airport_id) REFERENCES Airport(airport_id),
   CONSTRAINT Arrival_Airport_FK FOREIGN KEY (arrival_airport_id) REFERENCES Airport(airport_id)
);

CREATE TABLE Itinerary (
	itinerary_id BIGINT NOT NULL,
	trip_id BIGINT NOT NULL,
	destination_id BIGINT NOT NULL,
	total_cost BIGINT,
   departure_airport_id VARCHAR(3) NOT NULL,
   arrival_airport_id VARCHAR(3) NOT NULL,
   flight_id BIGINT NOT NULL,
	CONSTRAINT Itinerary_PK PRIMARY KEY (itinerary_id, trip_id),
	CONSTRAINT Itinerary_Trip_FK FOREIGN KEY (trip_id) REFERENCES Trip(trip_id),
	CONSTRAINT Itinerary_Destination_FK FOREIGN KEY (destination_id) REFERENCES Destination(destination_id),
	CONSTRAINT Airport_Flight_FK FOREIGN KEY (departure_airport_id, flight_id) REFERENCES Flight(airport_id, flight_id)
);

CREATE TABLE Hotel (
	hotel_id BIGINT NOT NULL,
	destination_id BIGINT NOT NULL,
	[name] VARCHAR(100),
	price_range VARCHAR(3),
	CONSTRAINT Hotel_PK PRIMARY KEY (hotel_id),
	CONSTRAINT Hotel_Destination_FK FOREIGN KEY (destination_id) REFERENCES Destination(destination_id),
	CONSTRAINT Price_Range CHECK (price_range = '$' OR price_range = '$$' OR price_range = '$$$')
);

CREATE TABLE Itinerary_Picked_Hotel (
	itinerary_id BIGINT NOT NULL,
	trip_id BIGINT NOT NULL,
	destination_id BIGINT NOT NULL,
	hotel_id BIGINT NOT NULL,
	room_type VARCHAR(50),
	cost BIGINT,
	CONSTRAINT Itinerary_Picked_PK PRIMARY KEY (itinerary_id, trip_id, destination_id, hotel_id),
	CONSTRAINT Itinerary_Picked_FK FOREIGN KEY (itinerary_id, trip_id) REFERENCES Itinerary(itinerary_id, trip_id),
	CONSTRAINT Itinerary_Picked_Destination_FK FOREIGN KEY (destination_id) REFERENCES Destination(destination_id),
	CONSTRAINT Itinerary_Picked_Hotel_FK FOREIGN KEY (hotel_id) REFERENCES Hotel(hotel_id),
	CONSTRAINT Room_Type CHECK (room_type = 'single' OR room_type = 'double' OR room_type = 'twin' OR room_type = 'suite' OR room_type = 'deluxe')
);

CREATE TABLE Activity (
	activity_id BIGINT NOT NULL,
	[name] VARCHAR(100),
	category VARCHAR(50),
	CONSTRAINT Activity_PK PRIMARY KEY (activity_id)
);

CREATE TABLE Destination_Activity (
	destination_id BIGINT NOT NULL,
	activity_id BIGINT NOT NULL,
	cost BIGINT,
	CONSTRAINT Destination_Activity_PK PRIMARY KEY (destination_id, activity_id),
	CONSTRAINT Destination_FK FOREIGN KEY (destination_id) REFERENCES Destination(destination_id),
	CONSTRAINT Activity_FK FOREIGN KEY (activity_id) REFERENCES Activity(activity_id)
);

CREATE TABLE Itinerary_Picked_Activity (
	itinerary_id BIGINT NOT NULL,
	trip_id BIGINT NOT NULL,
	destination_id BIGINT NOT NULL,
	activity_id BIGINT NOT NULL,
	duration INT,
	CONSTRAINT Itinerary_Picked_Activity_PK PRIMARY KEY (itinerary_id, destination_id, activity_id),
	CONSTRAINT Itinerary_Picked_Acitivity_FK FOREIGN KEY (itinerary_id, trip_id) REFERENCES Itinerary(itinerary_id, trip_id),
	CONSTRAINT Picked_Destination_FK FOREIGN KEY (destination_id) REFERENCES Destination(destination_id),
	CONSTRAINT Picked_Activity_FK FOREIGN KEY (activity_id) REFERENCES Activity(activity_id)
);

CREATE TABLE Review (
	review_id BIGINT NOT NULL,
	destination_id BIGINT NOT NULL,
	user_id BIGINT NOT NULL,
	star_rating INT,
	comment VARCHAR(200),
	CONSTRAINT Review_PK PRIMARY KEY (review_id, destination_id),
	CONSTRAINT Review_Destination_FK FOREIGN KEY (destination_id) REFERENCES Destination(destination_id),
	CONSTRAINT Review_User_FK FOREIGN KEY (user_id) REFERENCES [User](user_id),
	CONSTRAINT Star_Rating CHECK (star_rating >= 1 AND star_rating <= 5)
);
