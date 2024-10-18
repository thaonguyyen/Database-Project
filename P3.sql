--must run twice to drop all tables with foreign keys
DROP TABLE IF EXISTS Itinerary_Picked_Activity;
DROP TABLE IF EXISTS Destination_Activity;
DROP TABLE IF EXISTS Itinerary_Picked_Hotel;
DROP TABLE IF EXISTS Review;
DROP TABLE IF EXISTS Flight;
DROP TABLE IF EXISTS Hotel;
DROP TABLE IF EXISTS Itinerary;
DROP TABLE IF EXISTS Trip;
DROP TABLE IF EXISTS Destination;
DROP TABLE IF EXISTS Activity;
DROP TABLE IF EXISTS Airport;
DROP TABLE IF EXISTS [User];

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


--TABLE MANUAL INSERTIONS
INSERT INTO [User] (user_id, first_name, last_name, email, [password], city, [state], date_of_birth) VALUES
   (1, 'Jeff', 'Cooper', 'jeff.cooper@gmail.com', '2jR^h8W$zQv', 'New York', 'NY', '1990-05-12'),
   (2, 'Allison', 'Jones', 'allison.jones.com', 'P@5sW0rd$8H!v', 'Los Angeles', 'CA', '1988-09-30'),
   (3, 'Michael', 'Johnson', 'michael.johnson@hotmail.com', 'W3!zKj9@pF7$', 'Chicago', 'IL', '1992-02-17'),
   (4, 'Emily', 'Davis', 'emily.davis@outlook.com', '7!eR#c8Zq@H2', 'Houston', 'TX', '1995-07-21'),
   (5, 'David', 'Brown', 'david.brown@live.com', 'bY5*#fG9$z3V', 'Phoenix', 'AZ', '1989-04-11'),
   (6, 'Sarah', 'Jones', 'sarah.jones@icloud.com', '6^V@qR3&zL1*', 'Philadelphia', 'PA', '1993-03-14'),
   (7, 'Matthew', 'Garcia', 'matthew.garcia@gmail.com', 'T#8kQ1!fH$7P', 'San Antonio', 'TX', '1994-12-25'),
   (8, 'Ashley', 'Martinez', 'ashley.martinez@aol.com', '2q%Y7*R@wK6$!', 'San Diego', 'CA', '1991-06-07'),
   (9, 'Joshua', 'Rodriguez', 'joshua.rodriguez@protonmail.com', 'xZ8#1!vP9@W5', 'Dallas', 'TX', '1990-11-19'),
   (10, 'Amanda', 'Wilson', 'amanda.wilson@yahoo.com', 'P@3wR#5K8%tQ', 'San Jose', 'CA', '1995-08-03'),
   (11, 'Christopher', 'Nguyen', 'christopher.nguyen@hotmail.com', 'G2&vP5!nW#8x', 'Austin', 'TX', '1987-10-12'),
   (12, 'Jessica', 'Taylor', 'jessica.taylor@outlook.com', 'z@8Q1*vF3!hR', 'Jacksonville', 'FL', '1994-05-22'),
   (13, 'Daniel', 'Thomas', 'daniel.thomas@gmail.com', 'T9!kR2#fL8^z', 'Columbus', 'OH', '1992-09-08'),
   (14, 'Laura', 'Moore', 'laura.moore@icloud.com', 'D5&xF9!jT7$1', 'Charlotte', 'NC', '1990-07-18'),
   (15, 'James', 'Hernandez', 'james.hernandez@live.com', 'J8@kQ2#nV5%t', 'Fort Worth', 'TX', '1993-12-05'),
   (16, 'Olivia', 'Lopez', 'olivia.lopez@yahoo.com', '6!mN4#V9$yT8', 'Indianapolis', 'IN', '1989-03-29'),
   (17, 'William', 'Gonzalez', 'william.gonzalez@gmail.com', '8&zF7*R6@vQ5', 'Seattle', 'WA', '1991-10-15'),
   (18, 'Sophia', 'Perez', 'sophia.perez@hotmfail.com', '2Q^6f!T9$kM4', 'Denver', 'CO', '1995-01-23'),
   (19, 'Benjamin', 'Young', 'benjamin.young@aol.com', 'T1!cN8$wY5&z', 'El Paso', 'TX', '1992-02-05'),
   (20, 'Mia', 'Hall', 'mia.hall@live.com', 'W3^tY9#vQ7*F', 'Washington', 'DC', '1990-04-13'),
   (21, 'Alexander', 'King', 'alexander.king@gmail.com', 'M5@dY2%qR8^n', 'Boston', 'MA', '1988-06-27'),
   (22, 'Ava', 'Scott', 'ava.scott@yahoo.com', 'H3!kW9^xT6&z', 'Detroit', 'MI', '1993-08-09'),
   (23, 'Ethan', 'Green', 'ethan.green@hotmail.com', 'L4@dY2#zM8^k', 'Memphis', 'TN', '1989-09-25'),
   (24, 'Isabella', 'Baker', 'isabella.baker@outlook.com', 'G7^nT6&fQ9@3', 'Nashville', 'TN', '1994-10-19'),
   (25, 'Lucas', 'Adams', 'lucas.adams@icloud.com', 'T2@xF8^vM5#n', 'Portland', 'OR', '1991-12-30'),
   (26, 'Mia', 'Kim', 'mia.kim@gmail.com', 'B8^tG6&zR4#k', 'Oklahoma City', 'OK', '1987-08-17'),
   (27, 'Mason', 'Carter', 'mason.carter@yahoo.com', 'H5!vL2$kQ9@x', 'Las Vegas', 'NV', '1990-01-11'),
   (28, 'Lily', 'Mitchell', 'lily.mitchell@hotmail.com', 'D9^nT5&vF2#z', 'Louisville', 'KY', '1995-03-06'),
   (29, 'Jacob', 'Perez', 'jacob.perez@live.com', 'R4@wM8#kN1%f', 'Baltimore', 'MD', '1988-11-02'),
   (30, 'Grace', 'Martinez', 'grace.martinez@aol.com', 'V3^tF1&zK8@5', 'Milwaukee', 'WI', '1992-05-25'),
   (31, 'Henry', 'White', 'henry.white@gmail.com', 'L6^jT7&yK9@1', 'Albuquerque', 'NM', '1993-04-14'),
   (32, 'Ella', 'Clark', 'ella.clark@yahoo.com', 'D8!fN2$zR5^k', 'Fresno', 'CA', '1990-09-10'),
   (33, 'Noah', 'Lewis', 'noah.lewis@hotmail.com', 'T1&kG4%vN6^z', 'Sacramento', 'CA', '1994-07-01'),
   (34, 'Zoe', 'Robinson', 'zoe.robinson@outlook.com', 'R9^fJ8@kQ7*3', 'Kansas City', 'MO', '1991-06-11'),
   (35, 'Logan', 'Walker', 'logan.walker@icloud.com', 'H4%wY3^tM2#k', 'Mesa', 'AZ', '1989-02-16'),
   (36, 'Chloe', 'Hall', 'chloe.hall@gmail.com', 'F3$kG1@zY6^v', 'Tucson', 'AZ', '1992-08-22'),
   (37, 'Aiden', 'Martinez', 'aiden.martinez@yahoo.com', 'L5^jW9@hK4*z', 'Virginia Beach', 'VA', '1988-05-04'),
   (38, 'Sofia', 'Thompson', 'sofia.thompson@hotmail.com', 'D9%rP6*eF2#k', 'Atlanta', 'GA', '1991-07-15'),
   (39, 'Liam', 'Anderson', 'liam.anderson@outlook.com', 'Q1^kY4$zM8&t', 'Colorado Springs', 'CO', '1990-11-09'),
   (40, 'Mia', 'Garcia', 'mia.garcia@live.com', 'H2*kF7^wD6#r', 'Omaha', 'NE', '1989-12-01'),
   (41, 'Oliver', 'Roberts', 'oliver.roberts@gmail.com', 'G4%pN8^tY7@x', 'Kansas City', 'KS', '1993-04-08'),
   (42, 'Isabella', 'Harris', 'isabella.harris@yahoo.com', 'V3&jX2%tK5^d', 'Miami', 'FL', '1995-01-18'),
   (43, 'Elijah', 'Scott', 'elijah.scott@hotmail.com', 'R8^mD3$wF1@z', 'Cleveland', 'OH', '1987-09-23'),
   (44, 'Amelia', 'Young', 'amelia.young@outlook.com', 'S2#nF6*eK3%v', 'Tulsa', 'OK', '1994-03-12'),
   (45, 'James', 'Adams', 'james.adams@live.com', 'F9!hK2@xT7&v', 'Raleigh', 'NC', '1988-10-04'),
   (46, 'Ava', 'King', 'ava.king@gmail.com', 'H7^xQ9$dL1@t', 'New Orleans', 'LA', '1990-06-15'),
   (47, 'Charlotte', 'Nelson', 'charlotte.nelson@yahoo.com', 'P5#kB8%zR4^w', 'Atlanta', 'GA', '1992-02-20'),
   (48, 'Jack', 'Baker', 'jack.baker@hotmail.com', 'Z6^yK3*qM5@d', 'Phoenix', 'AZ', '1993-12-11'),
   (49, 'Lucas', 'Green', 'lucas.green@outlook.com', 'J3$gN2#yR8&k', 'Tampa', 'FL', '1991-11-29'),
   (50, 'Emily', 'Carter', 'emily.carter@gmail.com', 'Y5^rL6$dW9*t', 'Minneapolis', 'MN', '1988-08-25'),
   (51, 'Madison', 'Morris', 'madison.morris@yahoo.com', 'T7$kF1!jH8^n', 'Virginia Beach', 'VA', '1994-03-31'),
   (52, 'Benjamin', 'Evans', 'benjamin.evans@hotmail.com', 'D9!zN4*pR5&k', 'Bakersfield', 'CA', '1987-04-16'),
   (53, 'Ella', 'Torres', 'ella.torres@live.com', 'K2%vT8*jN6^w', 'Wichita', 'KS', '1992-07-20'),
   (54, 'David', 'Parker', 'david.parker@gmail.com', 'S5&jF3#vM1@z', 'Santa Ana', 'CA', '1990-05-03'),
   (55, 'Grace', 'Wood', 'grace.wood@yahoo.com', 'C1^nD8@rF7*t', 'Anaheim', 'CA', '1995-06-14'),
   (56, 'Matthew', 'Hughes', 'matthew.hughes@hotmail.com', 'N3#rP2!dK6^j', 'Tucson', 'AZ', '1989-12-28'),
   (57, 'Samantha', 'Flores', 'samantha.flores@outlook.com', 'E4!kQ1*vN7&y', 'Fresno', 'CA', '1991-02-12'),
   (58, 'Jackson', 'Gonzalez', 'jackson.gonzalez@gmail.com', 'R3#pT5!nK8^w', 'Henderson', 'NV', '1988-10-09'),
   (59, 'Avery', 'Clark', 'avery.clark@yahoo.com', 'D9^hJ7&fY2@x', 'Chula Vista', 'CA', '1994-11-27'),
   (60, 'Henry', 'Rodriguez', 'henry.rodriguez@hotmail.com', 'B8*nT3$gQ5^k', 'Baton Rouge', 'LA', '1993-03-18'),
   (61, 'Layla', 'Richardson', 'layla.richardson@live.com', 'S1^jM8$dF6&v', 'Phoenix', 'AZ', '1987-06-15'),
   (62, 'Elena', 'Morgan', 'elena.morgan@gmail.com', 'H4&kG5*eP7^n', 'Atlanta', 'GA', '1990-08-30'),
   (63, 'Gabriel', 'Perez', 'gabriel.perez@yahoo.com', 'M8@dL1^qJ3$k', 'San Francisco', 'CA', '1995-01-02'),
   (64, 'Scarlett', 'Bennett', 'scarlett.bennett@hotmail.com', 'C3#rT6!nW9^f', 'Orlando', 'FL', '1989-05-05'),
   (65, 'Zoe', 'Diaz', 'zoe.diaz@outlook.com', 'K7$hM2!fQ8&r', 'Stockton', 'CA', '1993-07-22'),
   (66, 'Daniel', 'Price', 'daniel.price@gmail.com', 'F9@rW4&hN6!t', 'Irvine', 'CA', '1988-11-18'),
   (67, 'Natalie', 'Howard', 'natalie.howard@yahoo.com', 'Q1^kD8%gW2&r', 'San Bernardino', 'CA', '1992-09-06'),
   (68, 'Sebastian', 'Gonzalez', 'sebastian.gonzalez@hotmail.com', 'R5#jN3*dH8&y', 'Chandler', 'AZ', '1989-10-27'),
   (69, 'Savannah', 'Wright', 'savannah.wright@live.com', 'D6!kT1^hP9&r', 'Fort Worth', 'TX', '1994-06-09'),
   (70, 'David', 'Lopez', 'david.lopez@gmail.com', 'P8@zK6*wQ4^h', 'Boston', 'MA', '1988-03-14');

-- closest airport to each destination
INSERT INTO Airport (airport_id, [name], city, [state]) VALUES
   ('JFK', 'John F. Kennedy International Airport', 'New York City', 'New York'),
   ('LAX', 'Los Angeles International Airport', 'Los Angeles', 'California'),
   ('ORD', 'OHare International Airport', 'Chicago', 'Illinois'),
   ('IAH', 'George Bush Intercontinental Airport', 'Houston', 'Texas'),
   ('PHX', 'Phoenix Sky Harbor International Airport', 'Phoenix', 'Arizona'),
   ('PHL', 'Philadelphia International Airport', 'Philadelphia', 'Pennsylvania'),
   ('SAT', 'San Antonio International Airport', 'San Antonio', 'Texas'),
   ('SAN', 'San Diego International Airport', 'San Diego', 'California'),
   ('MIA', 'Miami International Airport', 'Miami', 'Florida'),--
   ('SJC', 'Norman Y. Mineta San Jose International Airport', 'San Jose', 'California'),
   ('AUS', 'Austin-Bergstrom International Airport', 'Austin', 'Texas'),
   ('MCO', 'Orlando International Airport', 'Orlando', 'Florida'),
   ('DFW', 'Dallas/Fort Worth International Airport', 'Dallas', 'Texas'),
   ('CMH', 'John Glenn Columbus International Airport', 'Columbus', 'Ohio'),
   ('CLT', 'Charlotte Douglas International Airport', 'Charlotte', 'North Carolina'),
   ('SFO', 'San Francisco International Airport', 'San Francisco', 'California'),
   ('IND', 'Indianapolis International Airport', 'Indianapolis', 'Indiana'),
   ('SEA', 'Seattle-Tacoma International Airport', 'Seattle', 'Washington'),
   ('DEN', 'Denver International Airport', 'Denver', 'Colorado'),
   ('IAD', 'Washington Dulles International Airport', 'Washington', 'District of Columbia'),
   ('BOS', 'Logan International Airport', 'Boston', 'Massachusetts'),
   ('ELP', 'El Paso International Airport', 'El Paso', 'Texas'),
   ('BNA', 'Nashville International Airport', 'Nashville', 'Tennessee'),
   ('DTW', 'Detroit Metropolitan Wayne County Airport', 'Detroit', 'Michigan'),
   ('LAS', 'McCarran International Airport', 'Las Vegas', 'Nevada'),
   ('PDX', 'Portland International Airport', 'Portland', 'Oregon'),
   ('MEM', 'Memphis International Airport', 'Memphis', 'Tennessee'),
   ('OKC', 'Will Rogers World Airport', 'Oklahoma City', 'Oklahoma'),
   ('SDF', 'Louisville Muhammad Ali International Airport', 'Louisville', 'Kentucky'),
   ('BWI', 'Baltimore/Washington International Thurgood Marshall Airport', 'Baltimore', 'Maryland');

-- top 30 largest and popular cities in the US
INSERT INTO Destination (destination_id, city, [state], airport_id) VALUES
   (1, 'New York City', 'New York', 'JFK'),
   (2, 'Los Angeles', 'California', 'LAX'),
   (3, 'Chicago', 'Illinois', 'ORD'),
   (4, 'Houston', 'Texas', 'IAH'),
   (5, 'Phoenix', 'Arizona', 'PHX'),
   (6, 'Philadelphia', 'Pennsylvania', 'PHL'),
   (7, 'San Antonio', 'Texas', 'SAT'),
   (8, 'San Diego', 'California', 'SAN'),
   (9, 'Miami', 'Florida', 'MIA'),
   (10, 'San Jose', 'California', 'SJC'),
   (11, 'Austin', 'Texas', 'AUS'),
   (12, 'Orlando', 'Florida', 'MCO'),
   (13, 'Dallas', 'Texas', 'DFW'),
   (14, 'Columbus', 'Ohio', 'CMH'),
   (15, 'Charlotte', 'North Carolina', 'CLT'),
   (16, 'San Francisco', 'California', 'SFO'),
   (17, 'Indianapolis', 'Indiana', 'IND'),
   (18, 'Seattle', 'Washington', 'SEA'),
   (19, 'Denver', 'Colorado', 'DEN'),
   (20, 'Washington', 'District of Columbia', 'IAD'),
   (21, 'Boston', 'Massachusetts', 'BOS'),
   (22, 'El Paso', 'Texas', 'ELP'),
   (23, 'Nashville', 'Tennessee', 'BNA'),
   (24, 'Detroit', 'Michigan', 'DTW'),
   (25, 'Las Vegas', 'Nevada', 'LAS'),
   (26, 'Portland', 'Oregon', 'PDX'),
   (27, 'Memphis', 'Tennessee', 'MEM'),
   (28, 'Oklahoma City', 'Oklahoma', 'OKC'),
   (29, 'Louisville', 'Kentucky', 'SDF'),
   (30, 'Baltimore', 'Maryland', 'BWI');

--3 most popular activities for each destination
INSERT INTO Activity (activity_id, name, category) VALUES
    -- New York City
    (1, 'Visit the Statue of Liberty', 'Sightseeing'),
    (2, 'Explore Central Park', 'Outdoor'),
    (3, 'See a Broadway Show', 'Entertainment'),

    -- Los Angeles
    (4, 'Tour Hollywood Studios', 'Sightseeing'),
    (5, 'Relax at Santa Monica Beach', 'Outdoor'),
    (6, 'Visit Griffith Observatory', 'Education'),

    -- Chicago
    (7, 'Visit the Art Institute of Chicago', 'Cultural'),
    (8, 'Explore Millennium Park', 'Outdoor'),
    (9, 'Take an Architecture River Cruise', 'Sightseeing'),

    -- Houston
    (10, 'Visit Space Center Houston', 'Education'),
    (11, 'Explore the Houston Museum District', 'Cultural'),
    (12, 'Relax in Hermann Park', 'Outdoor'),

    -- Phoenix
    (13, 'Hike Camelback Mountain', 'Outdoor'),
    (14, 'Visit the Desert Botanical Garden', 'Cultural'),
    (15, 'Explore the Heard Museum', 'Cultural'),

    -- Philadelphia
    (16, 'Visit the Liberty Bell', 'Historical'),
    (17, 'Explore the Philadelphia Museum of Art', 'Cultural'),
    (18, 'Walk the Schuylkill River Trail', 'Outdoor'),

    -- San Antonio
    (19, 'Visit the Alamo', 'Historical'),
    (20, 'Explore the River Walk', 'Sightseeing'),
    (21, 'Visit the San Antonio Missions', 'Cultural'),

    -- San Diego
    (22, 'Relax at Balboa Park', 'Outdoor'),
    (23, 'Visit the San Diego Zoo', 'Cultural'),
    (24, 'Explore La Jolla Cove', 'Outdoor'),

    -- Miami
    (25, 'Relax at South Beach', 'Outdoor'),
    (26, 'Explore Art Deco Historic District', 'Cultural'),
    (27, 'Visit Vizcaya Museum and Gardens', 'Cultural'),

    -- San Jose
    (28, 'Visit the Tech Museum of Innovation', 'Education'),
    (29, 'Explore the Winchester Mystery House', 'Cultural'),
    (30, 'Relax at Almaden Quicksilver County Park', 'Outdoor'),

    -- Austin
    (31, 'Visit the Texas State Capitol', 'Historical'),
    (32, 'Explore Lady Bird Lake', 'Outdoor'),
    (33, 'Experience live music on Sixth Street', 'Entertainment'),

    -- Orlando
    (34, 'Visit Walt Disney World', 'Entertainment'),
    (35, 'Explore Universal Studios', 'Entertainment'),
    (36, 'Relax at Lake Eola Park', 'Outdoor'),

    -- Dallas
    (37, 'Visit the Sixth Floor Museum', 'Historical'),
    (38, 'Explore the Dallas Arboretum', 'Outdoor'),
    (39, 'Visit the Perot Museum of Nature and Science', 'Cultural'),

    -- Columbus
    (40, 'Explore the Columbus Zoo and Aquarium', 'Cultural'),
    (41, 'Visit COSI Columbus', 'Education'),
    (42, 'Relax at Franklin Park Conservatory', 'Outdoor'),

    -- Charlotte
    (43, 'Visit the NASCAR Hall of Fame', 'Cultural'),
    (44, 'Explore Freedom Park', 'Outdoor'),
    (45, 'Visit the U.S. National Whitewater Center', 'Outdoor'),

    -- San Francisco
    (46, 'Visit Alcatraz Island', 'Sightseeing'),
    (47, 'Explore Golden Gate Park', 'Outdoor'),
    (48, 'Walk across the Golden Gate Bridge', 'Sightseeing'),

    -- Indianapolis
    (49, 'Visit the Indianapolis Motor Speedway', 'Cultural'),
    (50, 'Explore White River State Park', 'Outdoor'),
    (51, 'Visit the Indianapolis Museum of Art', 'Cultural'),

    -- Seattle
    (52, 'Visit the Space Needle', 'Sightseeing'),
    (53, 'Explore Pike Place Market', 'Cultural'),
    (54, 'Take a ferry to Bainbridge Island', 'Sightseeing'),

    -- Denver
    (55, 'Visit the Denver Art Museum', 'Cultural'),
    (56, 'Explore Red Rocks Park and Amphitheatre', 'Outdoor'),
    (57, 'Ski in the Rocky Mountains', 'Outdoor'),

    -- Washington D.C.
    (58, 'Visit the National Mall', 'Historical'),
    (59, 'Explore the Smithsonian Museums', 'Cultural'),
    (60, 'Tour the U.S. Capitol', 'Historical'),

    -- Boston
    (61, 'Walk the Freedom Trail', 'Historical'),
    (62, 'Visit the Boston Museum of Fine Arts', 'Cultural'),
    (63, 'Explore Boston Common', 'Outdoor'),

    -- El Paso
    (64, 'Visit the El Paso Museum of Art', 'Cultural'),
    (65, 'Explore the Franklin Mountains State Park', 'Outdoor'),
    (66, 'Visit the El Paso Zoo', 'Cultural'),

    -- Nashville
    (67, 'Visit the Country Music Hall of Fame', 'Cultural'),
    (68, 'Experience live music on Broadway', 'Entertainment'),
    (69, 'Explore the Parthenon in Centennial Park', 'Historical'),

    -- Detroit
    (70, 'Visit the Henry Ford Museum', 'Cultural'),
    (71, 'Explore Belle Isle Park', 'Outdoor'),
    (72, 'Visit the Detroit Institute of Arts', 'Cultural'),

    -- Las Vegas
    (73, 'Visit the Las Vegas Strip', 'Entertainment'),
    (74, 'See a Cirque du Soleil Show', 'Entertainment'),
    (75, 'Explore Red Rock Canyon', 'Outdoor'),

    -- Portland
    (76, 'Visit the Portland Art Museum', 'Cultural'),
    (77, 'Explore Washington Park', 'Outdoor'),
    (78, 'Visit the Oregon Zoo', 'Cultural'),

    -- Memphis
    (79, 'Visit Graceland', 'Cultural'),
    (80, 'Explore Beale Street', 'Entertainment'),
    (81, 'Visit the National Civil Rights Museum', 'Cultural'),

    -- Oklahoma City
    (82, 'Visit the National Cowboy & Western Heritage Museum', 'Cultural'),
    (83, 'Explore Myriad Botanical Gardens', 'Outdoor'),
    (84, 'Visit the Oklahoma City National Memorial', 'Historical'),

    -- Louisville
    (85, 'Visit the Muhammad Ali Center', 'Cultural'),
    (86, 'Explore the Louisville Mega Cavern', 'Entertainment'),
    (87, 'Experience the Kentucky Derby', 'Cultural'),

    -- Baltimore
    (88, 'Visit the National Aquarium', 'Cultural'),
    (89, 'Explore Fort McHenry', 'Historical'),
    (90, 'Visit the Baltimore Museum of Art', 'Cultural');

INSERT INTO Destination_Activity (destination_id, activity_id, cost) VALUES
	(1, 1, 250), -- Visit the Statue of Liberty
	(1, 2, 0),   -- Explore Central Park
	(1, 3, 150), -- See a Broadway Show

   -- Los Angeles
	(2, 4, 200), -- Tour Hollywood Studios
	(2, 5, 0),   -- Relax at Santa Monica Beach
	(2, 6, 50),  -- Visit Griffith Observatory

   -- Chicago
	(3, 7, 25),  -- Visit the Art Institute of Chicago
	(3, 8, 0),   -- Explore Millennium Park
	(3, 9, 40),  -- Take an Architecture River Cruise

   -- Houston
	(4, 10, 100), -- Visit Space Center Houston
	(4, 11, 20),  -- Explore the Houston Museum District
	(4, 12, 0),   -- Relax in Hermann Park

   -- Phoenix
	(5, 13, 0),   -- Hike Camelback Mountain
	(5, 14, 30),  -- Visit the Desert Botanical Garden
	(5, 15, 20),  -- Explore the Heard Museum

   -- Philadelphia
	(6, 16, 0),   -- Visit the Liberty Bell
	(6, 17, 25),  -- Explore the Philadelphia Museum of Art
	(6, 18, 0),   -- Walk the Schuylkill River Trail

   -- San Antonio
	(7, 19, 0),   -- Visit the Alamo
	(7, 20, 0),   -- Explore the River Walk
	(7, 21, 30),  -- Visit the San Antonio Missions

   -- San Diego
	(8, 22, 0),   -- Relax at Balboa Park
	(8, 23, 60),  -- Visit the San Diego Zoo
	(8, 24, 0),   -- Explore La Jolla Cove

   -- Miami
	(9, 25, 0),   -- Relax at South Beach
	(9, 26, 20),  -- Explore Art Deco Historic District
	(9, 27, 18),  -- Visit Vizcaya Museum and Gardens

   -- San Jose
	(10, 28, 25), -- Visit the Tech Museum of Innovation
	(10, 29, 35), -- Explore the Winchester Mystery House
	(10, 30, 0),  -- Relax at Almaden Quicksilver County Park

   -- Austin
	(11, 31, 0),  -- Visit the Texas State Capitol
	(11, 32, 0),  -- Explore Lady Bird Lake
	(11, 33, 50), -- Experience live music on Sixth Street

   -- Orlando
	(12, 34, 150), -- Visit Walt Disney World
	(12, 35, 120), -- Explore Universal Studios
	(12, 36, 0),   -- Relax at Lake Eola Park

   -- Dallas
	(13, 37, 15),  -- Visit the Sixth Floor Museum
	(13, 38, 30),  -- Explore the Dallas Arboretum
	(13, 39, 20),  -- Visit the Perot Museum of Nature and Science

   -- Columbus
	(14, 40, 50),  -- Explore the Columbus Zoo and Aquarium
	(14, 41, 20),  -- Visit COSI Columbus
	(14, 42, 0),   -- Relax at Franklin Park Conservatory

   -- Charlotte
	(15, 43, 25),  -- Visit the NASCAR Hall of Fame
	(15, 44, 0),   -- Explore Freedom Park
	(15, 45, 40),  -- Visit the U.S. National Whitewater Center

   -- San Francisco
	(16, 46, 35),  -- Visit Alcatraz Island
	(16, 47, 0),   -- Explore Golden Gate Park
	(16, 48, 0),   -- Walk across the Golden Gate Bridge

   -- Indianapolis
	(17, 49, 25),  -- Visit the Indianapolis Motor Speedway
	(17, 50, 0),   -- Explore White River State Park
	(17, 51, 20),  -- Visit the Indianapolis Museum of Art

   -- Seattle
	(18, 52, 40),  -- Visit the Space Needle
	(18, 53, 0),   -- Explore Pike Place Market
	(18, 54, 0),   -- Take a ferry to Bainbridge Island

   -- Denver
	(19, 55, 20),  -- Visit the Denver Art Museum
	(19, 56, 0),   -- Explore Red Rocks Park and Amphitheatre
	(19, 57, 200), -- Ski in the Rocky Mountains

   -- Washington D.C.
	(20, 58, 0),   -- Visit the National Mall
	(20, 59, 0),   -- Explore the Smithsonian Museums
	(20, 60, 0),   -- Tour the U.S. Capitol

   -- Boston
	(21, 61, 0),   -- Walk the Freedom Trail
	(21, 62, 25),  -- Visit the Boston Museum of Fine Arts
	(21, 63, 0),   -- Explore Boston Common

   -- El Paso
	(22, 64, 15),  -- Visit the El Paso Museum of Art
	(22, 65, 0),   -- Explore the Franklin Mountains State Park
	(22, 66, 10),  -- Visit the El Paso Zoo

   -- Nashville
	(23, 67, 30),  -- Visit the Country Music Hall of Fame
	(23, 68, 0),   -- Experience live music on Broadway
	(23, 69, 0),   -- Explore the Parthenon in Centennial Park

   -- Detroit
	(24, 70, 20),  -- Visit the Henry Ford Museum
	(24, 71, 0),   -- Explore Belle Isle Park
	(24, 72, 15),  -- Visit the Detroit Institute of Arts

   -- Las Vegas
	(25, 73, 0),   -- Visit the Las Vegas Strip
	(25, 74, 100), -- See a Cirque du Soleil Show
	(25, 75, 0),   -- Explore Red Rock Canyon

   -- Portland
	(26, 76, 25),  -- Visit the Portland Art Museum
	(26, 77, 0),   -- Explore Washington Park
	(26, 78, 18),  -- Visit the Oregon Zoo

   -- Memphis
	(27, 79, 40),  -- Visit Graceland
	(27, 80, 0),   -- Explore Beale Street
	(27, 81, 25),  -- Visit the National Civil Rights Museum

   -- Oklahoma City
	(28, 82, 20),  -- Visit the National Cowboy & Western Heritage Museum
	(28, 83, 0),   -- Explore Myriad Botanical Gardens
	(28, 84, 0),   -- Visit the Oklahoma City National Memorial

   -- Louisville
	(29, 85, 15),  -- Visit the Muhammad Ali Center
	(29, 86, 30),  -- Explore the Louisville Mega Cavern
	(29, 87, 120), -- Experience the Kentucky Derby

   -- Baltimore
	(30, 88, 25),  -- Visit the National Aquarium
	(30, 89, 0),   -- Explore Fort McHenry
	(30, 90, 20);  -- Visit the Baltimore Museum of Art

INSERT INTO Review (review_id, destination_id, user_id, star_rating, comment) VALUES
    -- New York City, New York
    (1, 1, 1, '5', 'Amazing experience in New York! The hotel was fantastic, and the food options were endless.'),
    (2, 1, 2, '2', 'Flight delays were frustrating, and the hotel did not meet my expectations.'),
    (3, 1, 3, '4', 'Loved the Broadway shows! Wish my hotel was closer to Times Square.'),
    
    -- Los Angeles, California
    (4, 2, 4, '5', 'Hollywood was a blast! Our hotel had a stunning view, but the flight was tiring.'),
    (5, 2, 5, '3', 'Great weather, but the hotel staff were unhelpful. Traffic was a nightmare!'),
    (6, 2, 6, '4', 'The Griffith Observatory is a must-see, but my return flight was exhausting.'),
    
    -- Chicago, Illinois
    (7, 3, 7, '5', 'The Art Institute is a must-visit! The hotel was cozy and well-located.'),
    (8, 3, 8, '3', 'Millennium Park is nice, but the hotel was undergoing renovations.'),
    (9, 3, 9, '5', 'The architecture cruise was the highlight! Great hotel staff made the stay enjoyable.'),
    
    -- Houston, Texas
    (10, 4, 10, '4', 'Space Center was fascinating, but my flight was delayed. Hotel was decent.'),
    (11, 4, 11, '3', 'Museum District was great, but my hotel room was cramped.'),
    (12, 4, 12, '2', 'Hermann Park was lovely, but the hotel had booking issues.'),
    
    -- Phoenix, Arizona
    (13, 5, 13, '5', 'Camelback Mountain hike was beautiful! Hotel staff were super friendly.'),
    (14, 5, 14, '4', 'Desert Botanical Garden is stunning, but my flight was late.'),
    (15, 5, 15, '3', 'Heard Museum had great exhibits, but the hotel cleanliness was lacking.'),
    
    -- Philadelphia, Pennsylvania
    (16, 6, 16, '5', 'Liberty Bell is a must-see! Loved the hotel location and service.'),
    (17, 6, 17, '3', 'Art museum is great, but my flight was bumpy and the hotel was overpriced.'),
    (18, 6, 18, '4', 'Schuylkill River Trail is perfect for jogging, but my hotel was far from attractions.'),
    
    -- San Antonio, Texas
    (19, 7, 19, '4', 'Alamo is breathtaking! Enjoyed my hotel stay, but the flight was delayed.'),
    (20, 7, 20, '3', 'River Walk was beautiful, but my hotel was noisy at night.'),
    (21, 7, 21, '5', 'The missions were fascinating! Had a pleasant stay at the hotel.'),
    
    -- San Diego, California
    (22, 8, 22, '5', 'Balboa Park was stunning! Great hotel experience and service.'),
    (23, 8, 23, '4', 'San Diego Zoo is impressive, but my flight was too long.'),
    (24, 8, 24, '3', 'La Jolla Cove is beautiful, but my hotel had cleanliness issues.'),
    
    -- Miami, Florida
    (25, 9, 25, '5', 'South Beach was lively! My hotel was amazing, but the flight was delayed.'),
    (26, 9, 26, '4', 'Art Deco architecture is a must-see, but my hotel was a bit far from the beach.'),
    (27, 9, 27, '2', 'Vizcaya Museum was beautiful, but my hotel was terrible and the staff were rude.'),
    
    -- San Jose, California
    (28, 10, 28, '4', 'Tech Museum was fun! Flight was good, and hotel was convenient.'),
    (29, 10, 29, '5', 'Winchester Mystery House was fascinating! Enjoyed the hotel amenities.'),
    (30, 10, 30, '3', 'Almaden Quicksilver County Park was nice, but my hotel had noise issues.'),
    
    -- Austin, Texas
    (31, 11, 31, '5', 'Capitol building is stunning! Great hotel and friendly staff.'),
    (32, 11, 32, '4', 'Lady Bird Lake was perfect for kayaking, but the flight was long and tiring.'),
    (33, 11, 33, '3', 'Sixth Street live music was fun, but the hotel had a strange odor.'),
    
    -- Orlando, Florida
    (34, 12, 34, '5', 'Disney World was magical! The hotel was close to all attractions.'),
    (35, 12, 35, '4', 'Universal Studios was thrilling! Flight was fine, but my hotel was busy.'),
    (36, 12, 36, '2', 'Lake Eola Park is lovely, but my hotel had bugs! Never going back.'),
    
    -- Dallas, Texas
    (37, 13, 37, '5', 'Sixth Floor Museum is well done! Enjoyed my hotel stay.'),
    (38, 13, 38, '4', 'Dallas Arboretum is beautiful, but my flight was delayed.'),
    (39, 13, 39, '3', 'Perot Museum was fun, but the hotel was subpar.'),
    
    -- Columbus, Ohio
    (40, 14, 40, '5', 'Columbus Zoo was a highlight! Hotel was great too.'),
    (41, 14, 41, '3', 'COSI is educational, but my hotel was too far from everything.'),
    (42, 14, 42, '2', 'Franklin Park Conservatory was nice, but the hotel had awful service.'),
    
    -- Charlotte, North Carolina
    (43, 15, 43, '5', 'NASCAR Hall of Fame is fun! Loved my hotel experience!'),
    (44, 15, 44, '4', 'Freedom Park is great for a walk, but my flight was long.'),
    (45, 15, 45, '3', 'U.S. National Whitewater Center is thrilling, but my hotel was crowded.'),
    
    -- San Francisco, California
    (46, 16, 46, '5', 'Alcatraz was fascinating! Hotel was excellent and well-located.'),
    (47, 16, 47, '4', 'Golden Gate Park is beautiful, but the flight was long.'),
    (48, 16, 48, '3', 'Walking the Golden Gate Bridge was cool, but hotel staff were rude.'),
    
    -- Indianapolis, Indiana
    (49, 17, 49, '4', 'Motor Speedway is a must for racing fans! Hotel was okay.'),
    (50, 17, 50, '5', 'White River State Park is beautiful! Had a great time.'),
    (51, 17, 51, '2', 'Indianapolis Museum of Art had great exhibits, but the hotel was dirty.'),
    
    -- Seattle, Washington
    (52, 18, 52, '5', 'Space Needle has stunning views! My hotel was fantastic.'),
    (53, 18, 53, '4', 'Pike Place Market is lively, but my flight was delayed.'),
    (54, 18, 54, '3', 'Taking the ferry to Bainbridge Island was nice, but hotel service was lacking.'),
    
    -- Denver, Colorado
    (55, 19, 55, '5', 'Denver Art Museum was amazing! Hotel had a great location.'),
    (56, 19, 56, '4', 'Red Rocks Park is perfect for hiking. My flight was smooth.'),
    (57, 19, 57, '3', 'Skiing in the Rockies was fun, but my hotel was overpriced.'),
    
    -- Washington D.C.
    (58, 20, 58, '5', 'National Mall is breathtaking! The hotel was close to all attractions.'),
    (59, 20, 59, '4', 'Smithsonian Museums are educational, but my flight was late.'),
    (60, 20, 60, '3', 'Touring the U.S. Capitol was interesting, but hotel staff were rude.'),
    
    -- Boston, Massachusetts
    (61, 21, 61, '5', 'Walking the Freedom Trail was informative! Great hotel and amenities.'),
    (62, 21, 62, '4', 'Museum of Fine Arts is beautiful. Flight was tiring.'),
    (63, 21, 63, '3', 'Boston Common is nice, but my hotel room was small.'),
    
    -- El Paso, Texas
    (64, 22, 64, '5', 'Scenic views at Franklin Mountains State Park! My hotel was great.'),
    (65, 22, 65, '3', 'El Paso Museum of Art is interesting, but the hotel could be cleaner.'),
    (66, 22, 66, '2', 'Flight was delayed and the hotel had poor service.'),
    
    -- Nashville, Tennessee
    (67, 23, 67, '5', 'Live music on Broadway was a highlight! Great hotel experience.'),
    (68, 23, 68, '4', 'Country Music Hall of Fame is fantastic. My flight was fine.'),
    (69, 23, 69, '3', 'The Parthenon is interesting, but the hotel was noisy.'),
    
    -- Detroit, Michigan
    (70, 24, 70, '5', 'Motown Museum was fantastic! Hotel was convenient.'),
    (71, 24, 1, '4', 'Henry Ford Museum is interesting, but my flight was late.'),
    (72, 24, 2, '3', 'Belle Isle Park is nice, but the hotel had rude staff.'),
    
    -- Las Vegas, Nevada
    (73, 25, 3, '5', 'The Strip is incredible! Enjoyed my hotel stay!'),
    (74, 25, 4, '4', 'Casino experience was thrilling. My flight was smooth.'),
    (75, 25, 5, '2', 'Shows were fun, but the hotel had issues with service.'),
    
    -- Portland, Oregon
    (76, 26, 6, '5', 'The food scene is amazing! Loved my hotel!'),
    (77, 26, 7, '4', 'Washington Park is beautiful, but my flight was delayed.'),
    (78, 26, 8, '3', 'Powell’s City of Books was cool, but the hotel was noisy.'),
    
    -- Memphis, Tennessee
    (79, 27, 9, '5', 'Graceland was incredible! Enjoyed the hotel amenities.'),
    (80, 27, 10, '4', 'Beale Street is lively, but my flight was long.'),
    (81, 27, 11, '3', 'National Civil Rights Museum is educational, but my hotel was small.'),
    
    -- Oklahoma City, Oklahoma
    (82, 28, 12, '5', 'Bricktown is fun! Great hotel experience.'),
    (83, 28, 13, '4', 'My flight was smooth, but the hotel was a bit far from the action.'),
    (84, 28, 14, '3', 'Oklahoma City National Memorial is touching, but my hotel was outdated.'),
    
    -- Louisville, Kentucky
    (85, 29, 15, '5', 'Kentucky Derby is thrilling! Great hotel and food.'),
    (86, 29, 16, '4', 'Louisville Slugger Museum is fun, but my flight was tiring.'),
    (87, 29, 17, '3', 'The Big Four Bridge is great, but my hotel was noisy.'),
    
    -- Baltimore, Maryland
    (88, 30, 18, '5', 'Inner Harbor is beautiful! Had a great stay at the hotel!'),
    (89, 30, 19, '4', 'National Aquarium is worth visiting. My flight was long but enjoyable.'),
    (90, 30, 20, '3', 'Fort McHenry is historic, but my hotel needed updating.');


--TABLE CSV INSERTIONS
--must download locally then change file path
BULK INSERT Hotel
FROM 'C:\Users\thaon\Downloads\hotels.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);

--hub and spoke structure with JFK, LAX, ORD, and IAH as central hubs
BULK INSERT Flight
FROM 'C:\Users\thaon\Downloads\flights.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);

BULK INSERT Itinerary
FROM 'C:\Users\thaon\Downloads\itinerary.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);

BULK INSERT Itinerary_Picked_Hotel
FROM 'C:\Users\thaon\Downloads\itinerary_picked_hotel.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);

BULK INSERT Itinerary_Picked_Activity
FROM 'C:\Users\thaon\Downloads\itinerary_picked_activity.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);

BULK INSERT Trip
FROM 'C:\Users\thaon\Downloads\trip.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);

--SQL QUERIES
-- How many people are traveling to New York (Aggregate & Subquery & Join)
SELECT COUNT(*) AS number_traveling_to_new_york
FROM (
    SELECT I.trip_id
    FROM Itinerary I
    INNER JOIN Destination D ON I.destination_id = D.destination_id
    WHERE D.[state] = 'New York'
    GROUP BY I.trip_id
) AS NY_traveled;

-- Who are all staying hotels with the highest price range (Subquery & Join)
SELECT DISTINCT u.first_name, u.last_name
FROM [User] u
WHERE u.user_id IN (
    SELECT user_id
    FROM Trip T
    WHERE T.trip_id IN (
        SELECT trip_id 
        FROM Itinerary I
        WHERE I.itinerary_id IN (
            SELECT itinerary_id
            FROM Itinerary_Picked_Hotel IH
            INNER JOIN Hotel H ON H.hotel_id = IH.hotel_id
            WHERE H.price_range = '$$$'
        )
    )
);

-- Get all itineraries for Michael Johnson (Join)
SELECT * 
FROM Itinerary I
INNER JOIN Trip T ON I.trip_id = T.trip_id
INNER JOIN [User] U ON T.user_id = U.user_id
WHERE U.first_name = 'Michael' AND U.last_name = 'Johnson';

-- Find the three most expensive chosen hotel (Join)
SELECT TOP 3 H.hotel_id, H.name, H.price_range, IPH.cost
FROM Hotel H
JOIN Itinerary_Picked_Hotel IPH ON IPH.hotel_id = H.hotel_id
ORDER BY IPH.cost DESC

-- Find the average cost of each hotel chosen (Aggregate & Join)
SELECT H.hotel_id, H.name, H.price_range, AVG(cost) AS average_cost
FROM Hotel H
JOIN Itinerary_Picked_Hotel IPH ON IPH.hotel_id = H.hotel_id
GROUP BY H.hotel_id, H.name, H.price_range;

-- Find all flights from Texas (Subquery)
SELECT DISTINCT F.airport_id, F.flight_id, F.departure_time, F.arrival_time, F.airline
FROM Flight F
WHERE EXISTS (
    SELECT 1
    FROM Airport A
    WHERE A.[state] = 'Texas'
    AND F.airport_id = A.airport_id
);

-- Find all activites in New York City with cost less than $100 (Join)
SELECT A.name, A.category, DA.cost
FROM Activity A
INNER JOIN Destination_Activity DA ON DA.activity_id = A.activity_id
INNER JOIN Destination D ON DA.destination_id = D.destination_id
WHERE D.city = 'New York City' AND DA.cost < 100;

-- Find the average rating for each destination (Subquery & Join & Aggregate)
SELECT RD.city, RD.[state], AVG(RD.star_rating) AS avg_rating
FROM (
    SELECT R.destination_id, D.city, D.[state], R.star_rating
    FROM Review R
    JOIN Destination D ON D.destination_id = R.destination_id
) AS RD
GROUP BY RD.destination_id, RD.city, RD.[state]

-- Get the money spent on trips from each user that has a trip planned (Aggregate & Join)
SELECT U.user_id, SUM(total_cost) AS total_money_spent
FROM [User] U
JOIN Trip T ON T.user_id = U.user_id
GROUP BY U.user_id;

-- Who spends the most time on activites (Aggregate & Join)
SELECT TOP 1 U.user_id, U.first_name, U.last_name, SUM(duration) AS total_time_spent
FROM [User] U
JOIN Trip T ON T.user_id = U.user_id
JOIN Itinerary I ON T.trip_id = I.trip_id
JOIN Itinerary_Picked_Activity IPA ON IPA.itinerary_id = I.itinerary_id
GROUP BY U.user_id, U.first_name, U.last_name
ORDER BY SUM(IPA.duration) DESC;