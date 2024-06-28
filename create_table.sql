-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2024-05-19 19:20:00.847

-- tables
-- Table: AttractionReservations
CREATE TABLE AttractionReservations (
    RA_id int  NOT NULL IDENTITY(1, 1),
    Price_per_person money  NOT NULL,
    Count_of_trippers int  NOT NULL,
    Attraction_id int  NOT NULL,
    Reservation_id int  NOT NULL,
    CONSTRAINT AttractionReservations_check_count_of_trippers CHECK (Count_of_trippers > 0),
    CONSTRAINT AttractionReservations_check_price_per_person CHECK (Price_per_person > 0),
    CONSTRAINT AttractionReservations_pk PRIMARY KEY  (RA_id)
);

-- Table: Attractions
CREATE TABLE Attractions (
    Attraction_id int  NOT NULL IDENTITY(1, 1),
    Trip_id int  NOT NULL,
    Name varchar(50)  NOT NULL,
    Price_per_person money  NOT NULL,
    Limit int  NOT NULL,
    CONSTRAINT Attractions_check_limit CHECK (Limit > 0),
    CONSTRAINT Attractions_check_price_per_person CHECK (Price_per_person > 0),
    CONSTRAINT Attractions_pk PRIMARY KEY  (Attraction_id)
);

-- Table: Attractions_Trippers
CREATE TABLE Attractions_Trippers (
    AT_id int  NOT NULL IDENTITY(1, 1),
    Tripper_id int  NOT NULL,
    RA_id int  NOT NULL,
    CONSTRAINT Attractions_Trippers_pk PRIMARY KEY  (AT_id)
);

-- Table: Cities
CREATE TABLE Cities (
    City_id int  NOT NULL IDENTITY(1, 1),
    City varchar(50)  NOT NULL,
    Country_id int  NOT NULL,
    CONSTRAINT Cities_pk PRIMARY KEY  (City_id)
);

-- Table: Clients
CREATE TABLE Clients (
    Client_id int  NOT NULL IDENTITY(1, 1),
    Balance money  NOT NULL,
    Email varchar(100)  NOT NULL,
    Phone varchar(9)  NOT NULL,
    CONSTRAINT Clients_check_balance CHECK (Balance > 0),
    CONSTRAINT Clients_pk PRIMARY KEY  (Client_id)
);

-- Table: Companies
CREATE TABLE Companies (
    Company_id int  NOT NULL IDENTITY(1, 1),
    Client_id int  NOT NULL,
    Company_name varchar(50)  NOT NULL,
    NIP int  NOT NULL,
    CONSTRAINT Companies_pk PRIMARY KEY  (Company_id)
);

-- Table: Country
CREATE TABLE Country (
    Country_id int  NOT NULL IDENTITY(1, 1),
    Country varchar(50)  NOT NULL,
    CONSTRAINT Country_pk PRIMARY KEY  (Country_id)
);

-- Table: Customers
CREATE TABLE Customers (
    Customer_id int  NOT NULL IDENTITY(1, 1),
    Client_id int  NOT NULL,
    Firstname varchar(40)  NOT NULL,
    Lastname varchar(40)  NOT NULL,
    CONSTRAINT Customers_pk PRIMARY KEY  (Customer_id)
);

-- Table: Payments
CREATE TABLE Payments (
    Payment_id int  NOT NULL IDENTITY(1, 1),
    Paid money  NOT NULL,
    Timestamp datetime  NOT NULL,
    Reservation_id int  NOT NULL,
    CONSTRAINT Payments_check_paid CHECK (Paid > 0),
    CONSTRAINT Payments_pk PRIMARY KEY  (Payment_id)
);

-- Table: People
CREATE TABLE People (
    Person_id int  NOT NULL IDENTITY(1, 1),
    Client_id int  NOT NULL,
    Firstname varchar(40)  NOT NULL,
    Lastname varchar(40)  NOT NULL,
    Email varchar(100)  NOT NULL,
    Phone varchar(9)  NOT NULL,
    CONSTRAINT People_pk PRIMARY KEY  (Person_id)
);

-- Table: Reservations
CREATE TABLE Reservations (
    Reservation_id int  NOT NULL IDENTITY(1, 1),
    Trip_id int  NOT NULL,
    Client_id int  NOT NULL,
    Price_per_person money  NOT NULL,
    Count_of_trippers int  NOT NULL,
    Cancelled bit  NOT NULL,
    CONSTRAINT Reservations_check_price_per_person CHECK (Price_per_person > 0),
    CONSTRAINT Reservations_pk PRIMARY KEY  (Reservation_id)
);

-- Table: Trippers
CREATE TABLE Trippers (
    Tripper_id int  NOT NULL IDENTITY(1, 1),
    Reservation_id int  NOT NULL,
    Person_id int  NOT NULL,
    CONSTRAINT Trippers_pk PRIMARY KEY  (Tripper_id)
);

-- Table: Trips
CREATE TABLE Trips (
    Trip_id int  NOT NULL IDENTITY(1, 1),
    Name varchar(40)  NOT NULL,
    City_id int  NOT NULL,
    Date date  NOT NULL,
    Price_per_person money  NOT NULL,
    Limit int  NOT NULL,
    Start_reservation datetime  NOT NULL,
    CONSTRAINT check_limit CHECK (Limit > 0),
    CONSTRAINT check_price_per_person CHECK (Price_per_person > 0),
    CONSTRAINT Trips_pk PRIMARY KEY  (Trip_id)
);

-- foreign keys
-- Reference: Attractions_Trippers_Reservations_Attractions (table: Attractions_Trippers)
ALTER TABLE Attractions_Trippers ADD CONSTRAINT Attractions_Trippers_Reservations_Attractions
    FOREIGN KEY (RA_id)
    REFERENCES AttractionReservations (RA_id);

-- Reference: Attractions_Trippers_Trippers (table: Attractions_Trippers)
ALTER TABLE Attractions_Trippers ADD CONSTRAINT Attractions_Trippers_Trippers
    FOREIGN KEY (Tripper_id)
    REFERENCES Trippers (Tripper_id);

-- Reference: Cities_Country (table: Cities)
ALTER TABLE Cities ADD CONSTRAINT Cities_Country
    FOREIGN KEY (Country_id)
    REFERENCES Country (Country_id);

-- Reference: Companies_Clients (table: Companies)
ALTER TABLE Companies ADD CONSTRAINT Companies_Clients
    FOREIGN KEY (Client_id)
    REFERENCES Clients (Client_id);

-- Reference: Customers_Clients (table: Customers)
ALTER TABLE Customers ADD CONSTRAINT Customers_Clients
    FOREIGN KEY (Client_id)
    REFERENCES Clients (Client_id);

-- Reference: Payments_Reservations (table: Payments)
ALTER TABLE Payments ADD CONSTRAINT Payments_Reservations
    FOREIGN KEY (Reservation_id)
    REFERENCES Reservations (Reservation_id);

-- Reference: People_Clients (table: People)
ALTER TABLE People ADD CONSTRAINT People_Clients
    FOREIGN KEY (Client_id)
    REFERENCES Clients (Client_id);

-- Reference: Reservations_Attractions_Attractions (table: AttractionReservations)
ALTER TABLE AttractionReservations ADD CONSTRAINT Reservations_Attractions_Attractions
    FOREIGN KEY (Attraction_id)
    REFERENCES Attractions (Attraction_id);

-- Reference: Reservations_Attractions_Reservations (table: AttractionReservations)
ALTER TABLE AttractionReservations ADD CONSTRAINT Reservations_Attractions_Reservations
    FOREIGN KEY (Reservation_id)
    REFERENCES Reservations (Reservation_id);

-- Reference: Reservations_Clients (table: Reservations)
ALTER TABLE Reservations ADD CONSTRAINT Reservations_Clients
    FOREIGN KEY (Client_id)
    REFERENCES Clients (Client_id);

-- Reference: Reservations_Trips (table: Reservations)
ALTER TABLE Reservations ADD CONSTRAINT Reservations_Trips
    FOREIGN KEY (Trip_id)
    REFERENCES Trips (Trip_id);

-- Reference: Trippers_People (table: Trippers)
ALTER TABLE Trippers ADD CONSTRAINT Trippers_People
    FOREIGN KEY (Person_id)
    REFERENCES People (Person_id);

-- Reference: Trippers_Reservations (table: Trippers)
ALTER TABLE Trippers ADD CONSTRAINT Trippers_Reservations
    FOREIGN KEY (Reservation_id)
    REFERENCES Reservations (Reservation_id);

-- Reference: Trips_Attractions (table: Attractions)
ALTER TABLE Attractions ADD CONSTRAINT Trips_Attractions
    FOREIGN KEY (Trip_id)
    REFERENCES Trips (Trip_id);

-- Reference: Trips_Cities (table: Trips)
ALTER TABLE Trips ADD CONSTRAINT Trips_Cities
    FOREIGN KEY (City_id)
    REFERENCES Cities (City_id);

-- End of file.

