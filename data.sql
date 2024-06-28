-- COUNTRY

SET IDENTITY_INSERT Countries ON;

INSERT INTO Countries (Country_id, Country)
VALUES
(1, 'Italy'),
(2, 'France'),
(3, 'Spain'),
(4, 'United States'),
(5, 'Japan'),
(6, 'Australia'),
(7, 'Greece'),
(8, 'Mexico'),
(9, 'Thailand'),
(10, 'Peru');

SET IDENTITY_INSERT Countries OFF;

--CITIES

SET IDENTITY_INSERT Cities ON;

INSERT INTO Cities (City_id, City, Country_id)
VALUES
(1, 'Rome', 1),
(2, 'Venice', 1),
(3, 'Florence', 1),
(4, 'Paris', 2),
(5, 'Nice', 2),
(6, 'Lyon', 2),
(7, 'Barcelona', 3),
(8, 'Madrid', 3),
(9, 'Seville', 3),
(10, 'New York', 4),
(11, 'Los Angeles', 4),
(12, 'Chicago', 4),
(13, 'Tokyo', 5),
(14, 'Kyoto', 5),
(15, 'Osaka', 5),
(16, 'Sydney', 6),
(17, 'Melbourne', 6),
(18, 'Brisbane', 6),
(19, 'Athens', 7),
(20, 'Santorini', 7),
(21, 'Mykonos', 7),
(22, 'Cancun', 8),
(23, 'Mexico City', 8),
(24, 'Guadalajara', 8),
(25, 'Bangkok', 9),
(26, 'Chiang Mai', 9),
(27, 'Phuket', 9),
(28, 'Cuzco', 10),
(29, 'Lima', 10),
(30, 'Jaen', 10);

SET IDENTITY_INSERT Cities OFF;

--CLIENT

SET IDENTITY_INSERT Clients ON;

INSERT INTO Clients (Client_id, Email, Phone)
VALUES
(1, 'techinnovators@example.com', '123456789'),
(2, 'greensolutions@greentech.net', '987654321'),
(3, 'info@healthfirst.net', '456789123'),
(4, 'support@creativeminds.tech', '789123456'),
(5, 'builders@thefuturebuildersgroup.com', '321654987'),
(6, 'contact@futurebuilders.net', '654987321'),
(7, 'contact@digitaldynamics.org', '147258369'),
(8, 'support@ecoenergy.org', '258369147'),
(9, 'support@financehub.org', '369147258'),
(10, 'sales@fashionforward.tech', '963852741'),
(11, 'kowalski@example.com', '741852963'),
(12, 'nowak@example.com', '852963147'),
(13, 'wisniewski@example.com', '369852147'),
(14, 'wojcik@example.com', '258741369'),
(15, 'kowalczyk@example.com', '123789456'),
(16, 'kaminska@example.com', '987654123'),
(17, 'lewandowski@example.com', '654123789'),
(18, 'zielinska@example.com', '456321987'),
(19, 'szymanski@example.com', '789456123'),
(20, 'wozniak@example.com', '321987654');

SET IDENTITY_INSERT Clients OFF;

--COMPANIES

SET IDENTITY_INSERT Companies ON;

INSERT INTO Companies (Company_id, Client_id, Company_name, NIP)
VALUES
(1, 1, 'Tech Innovators', 1234567890),
(2, 2, 'Green Solutions', 1234567891),
(3, 3, 'Health First', 1234567892),
(4, 4, 'Creative Minds', 1234567893),
(5, 5, 'Future Builders', 1234567894),
(6, 6, 'Smart Home Inc.', 1234567895),
(7, 7, 'Digital Dynamics', 1234567896),
(8, 8, 'Eco Energy', 1234567897),
(9, 9, 'Finance Hub', 1234567898),
(10, 10, 'Fashion Forward', 1234567899);

SET IDENTITY_INSERT Companies OFF;

--CUSTOMERS

SET IDENTITY_INSERT Customers ON;

INSERT INTO Customers (Customer_id, Client_id, Firstname, Lastname)
VALUES
(1, 11, 'Jan', 'Kowalski'),
(2, 12, 'Anna', 'Nowak'),
(3, 13, 'Piotr', 'Wiśniewski'),
(4, 14, 'Katarzyna', 'Wójcik'),
(5, 15, 'Andrzej', 'Kowalczyk'),
(6, 16, 'Małgorzata', 'Kamińska'),
(7, 17, 'Stanisław', 'Lewandowski'),
(8, 18, 'Joanna', 'Zielińska'),
(9, 19, 'Tomasz', 'Szymański'),
(10, 20, 'Magdalena', 'Woźniak');

SET IDENTITY_INSERT Customers OFF;

--PEOPLE

SET IDENTITY_INSERT People ON;

INSERT INTO People (Person_id, Firstname, Lastname, Email, Phone)
VALUES
(1, 'Adam', 'Kowalski', 'adam.kowalski@example.com', '123456789'),
(2, 'Anna', 'Nowak', 'anna.nowak@example.com', '987654321'),
(3, 'Piotr', 'Wiśniewski', 'piotr.wisniewski@example.com', '456789123'),
(4, 'Katarzyna', 'Wójcik', 'katarzyna.wojcik@example.com', '789123456'),
(5, 'Andrzej', 'Kowalczyk', 'andrzej.kowalczyk@example.com', '321654987'),
(6, 'Małgorzata', 'Kamińska', 'malgorzata.kaminska@example.com', '654987321'),
(7, 'Stanisław', 'Lewandowski', 'stanislaw.lewandowski@example.com', '147258369'),
(8, 'Joanna', 'Zielińska', 'joanna.zielinska@example.com', '258369147'),
(9, 'Tomasz', 'Szymański', 'tomasz.szymanski@example.com', '369147258'),
(10, 'Magdalena', 'Woźniak', 'magdalena.wozniak@example.com', '963852741'),
(11, 'Marcin', 'Dąbrowski', 'marcin.dabrowski@example.com', '741852963'),
(12, 'Agnieszka', 'Kozłowska', 'agnieszka.kozlowska@example.com', '852963147'),
(13, 'Michał', 'Jankowski', 'michal.jankowski@example.com', '369852147'),
(14, 'Justyna', 'Wojciechowska', 'justyna.wojciechowska@example.com', '258741369'),
(15, 'Krzysztof', 'Kwiatkowska', 'krzysztof.kwiatkowska@example.com', '123789456'),
(16, 'Natalia', 'Wojcik', 'natalia.wojcik@example.com', '987654123'),
(17, 'Marek', 'Kaczmarek', 'marek.kaczmarek@example.com', '654123789'),
(18, 'Monika', 'Mazur', 'monika.mazur@example.com', '456321987'),
(19, 'Adam', 'Krawczyk', 'adam.krawczyk@example.com', '789456123'),
(20, 'Karolina', 'Piotrowska', 'karolina.piotrowska@example.com', '321987654'),
(21, 'Jan', 'Nowak', 'jan.nowak@example.com', '987654321'),
(22, 'Marta', 'Kowalska', 'marta.kowalska@example.com', '456789123'),
(23, 'Tadeusz', 'Wiśniewski', 'tadeusz.wisniewski@example.com', '789123456'),
(24, 'Katarzyna', 'Wójcik', 'katarzyna.wojcik@example.com', '321654987'),
(25, 'Piotr', 'Kowalczyk', 'piotr.kowalczyk@example.com', '654987321'),
(26, 'Beata', 'Kamińska', 'beata.kaminska@example.com', '147258369'),
(27, 'Tomasz', 'Lewandowski', 'tomasz.lewandowski@example.com', '258369147'),
(28, 'Anna', 'Zielińska', 'anna.zielinska@example.com', '369147258'),
(29, 'Michał', 'Szymański', 'michal.szymanski@example.com', '963852741'),
(30, 'Joanna', 'Woźniak', 'joanna.wozniak@example.com', '741852963'),
(31, 'Jan', 'Dąbrowski', 'jan.dabrowski@example.com', '852963147'),
(32, 'Aleksandra', 'Kozłowska', 'aleksandra.kozlowska@example.com', '369852147'),
(33, 'Paweł', 'Jankowski', 'pawel.jankowski@example.com', '258741369'),
(34, 'Weronika', 'Wojciechowska', 'weronika.wojciechowska@example.com', '123789456'),
(35, 'Mateusz', 'Kwiatkowska', 'mateusz.kwiatkowska@example.com', '987654123');

SET IDENTITY_INSERT People OFF;

-- TRIPS

SET IDENTITY_INSERT Trips ON;

INSERT INTO Trips (Trip_id, Name, City_id, Date, Price_per_person, Limit, Start_reservation)
VALUES
(1, 'Discover Paris', 4, '2024-06-15', 500.00, 20, '2024-05-15 08:00:00'),
(2, 'Explore Rome', 1, '2024-07-10', 600.00, 15, '2024-06-10 09:00:00'),
(3, 'Adventures in Tokyo', 13, '2024-08-20', 700.00, 25, '2024-05-20 09:00:00'),
(4, 'Safari in Guadalajara', 24, '2024-09-05', 650.00, 18, '2024-05-21 10:00:00'),
(5, 'Cruise in Sydney', 16, '2024-10-15', 900.00, 30, '2024-09-15 12:00:00'),
(6, 'Hike in Machu Picchu', 29, '2024-11-10', 1080.00, 22, '2024-05-22 11:00:00'),
(7, 'Holidays in USA', 10, '2024-12-01', 5100.00, 17, '2024-01-01 14:00:00'),
(8, 'Relaxing in Athens', 19, '2025-01-20', 1200.00, 28, '2025-01-01 15:00:00'),
(9, 'Snorkelling in Australia', 16,'2024-06-21', 4500.00, 10, '2024-06-07 00:00:00.000');

SET IDENTITY_INSERT Trips OFF;

-- ATTRACTIONS

SET IDENTITY_INSERT Attractions ON;

INSERT INTO Attractions (Attraction_id, Trip_id, Name, Price_per_person, Limit)
VALUES
-- Atrakcje dla Discover Paris
(1, 1, 'Eiffel Tower Tour', 50.00, 15),
(2, 1, 'Louvre Museum Visit', 40.00, 10),
(3, 1, 'Seine River Cruise', 60.00, 5),

-- Atrakcje dla Explore Rome
(4, 2, 'Colosseum Guided Tour', 60.00, 10),
(5, 2, 'Vatican City Tour', 70.00, 15),
(6, 2, 'Trevi Fountain Visit', 30.00, 5),

-- Atrakcje dla Adventures in Tokyo
(7, 3, 'Tokyo Disneyland Tickets', 80.00, 20),
(8, 3, 'Mount Fuji Hike', 100.00, 15),
(9, 3, 'Robot Restaurant Show', 70.00, 10),

-- Atrakcje dla Safari in Guadalajara
(10, 4, 'Tequila Tasting Tour', 70.00, 15),
(11, 4, 'Zoologico Guadalajara', 40.00, 10),
(12, 4, 'Los Arcos Waterfall Hike', 50.00, 5),

-- Atrakcje dla Cruise in Sydney
(13, 5, 'Sydney Opera House Tour', 90.00, 20),
(14, 5, 'Great Barrier Reef Diving', 150.00, 25),
(15, 5, 'Bondi Beach Surfing Lesson', 70.00, 20),

-- Atrakcje dla Hike in Machu Picchu
(16, 6, 'Machu Picchu Guided Tour', 80.00, 20),
(17, 6, 'Inca Trail Trek', 120.00, 15),
(18, 6, 'Huayna Picchu Summit', 100.00, 10),

-- Atrakcje dla Holidays in USA
(19, 7, 'Grand Canyon Helicopter Tour', 300.00, 10),
(20, 7, 'Disneyland Resort Tickets', 200.00, 15),
(21, 7, 'Universal Studios Hollywood Pass', 150.00, 10),

-- Atrakcje dla Relaxing in Athens
(22, 8, 'Acropolis Guided Tour', 70.00, 20),
(23, 8, 'Plaka Neighborhood Stroll', 50.00, 15),
(24, 8, 'Greek Cooking Class', 80.00, 10);

SET IDENTITY_INSERT Attractions OFF;

-- RESERVATIONS

SET IDENTITY_INSERT Reservations ON;

INSERT INTO Reservations (Reservation_id, Trip_id, Client_id, Price_per_person, Count_of_trippers, Cancelled)
VALUES
(1, 1, 15, 500.00, 1, 0),  -- Rezerwacja 1
(2, 3, 5, 700.00, 4, 0),  -- Rezerwacja 2
(3, 3, 13, 700.00, 4, 1),  -- Rezerwacja 3 (anulowana)
(4, 4, 18, 650.00, 4, 0),  -- Rezerwacja 4
(5, 6, 20, 1080.00, 6, 0),  -- Rezerwacja 5
(6, 9, 8, 4500.00, 10, 0); -- Rezerwacja 6 (zajmuje wszystkie miejsca)
SET IDENTITY_INSERT Reservations OFF;

--ATTRACTION RESERVATIONS

SET IDENTITY_INSERT Attraction_Reservations ON;

INSERT INTO Attraction_Reservations (AR_id, Price_per_person, Count_of_trippers, Attraction_id, Reservation_id)
VALUES
(1, 40.00, 1, 2, 1),  -- Rezerwacja atrakcji 1:
(2, 80.00, 4, 7, 3),  -- Rezerwacja atrakcji 2:
(3, 120.00, 4, 17, 5) -- Rezerwacja atrakcji 3:
;

SET IDENTITY_INSERT Attraction_Reservations OFF;

-- TRIPPERS

SET IDENTITY_INSERT Trippers ON;

-- rezerwacja 1

INSERT INTO Trippers (Tripper_id, Reservation_id, Person_id) VALUES
(1, 1, 35);

-- rezerwacja 2

INSERT INTO Trippers (Tripper_id, Reservation_id, Person_id) VALUES
(2, 2, 21),
(3, 2, 22),
(4, 2, 23),
(5, 2, 24);

-- rezerwacja 5

INSERT INTO Trippers (Tripper_id, Reservation_id, Person_id) VALUES
(6, 5, 31),
(7, 5, 32),
(8, 5, 33),
(9, 5, 34),
(10, 5, 35);

SET IDENTITY_INSERT Trippers OFF;

-- ATTRACTIONS_TRIPPERS

SET IDENTITY_INSERT Attractions_Trippers ON;

-- Dla Reservation_id 1
INSERT INTO Attractions_Trippers (AT_id, Tripper_id, AR_id) VALUES
(1, 1, 1);  -- AT_id 1, Tripper_id 1, RA_id 1 (Rezerwacja 1)

-- Dla Reservation_id 2
INSERT INTO Attractions_Trippers (AT_id, Tripper_id, AR_id) VALUES
(2, 2, 2),  -- AT_id 2, Tripper_id 2, RA_id 2
(3, 3, 2),  -- AT_id 3, Tripper_id 3, RA_id 2
(4, 4, 2),  -- AT_id 4, Tripper_id 4, RA_id 2
(5, 5, 2);  -- AT_id 5, Tripper_id 5, RA_id 2

-- Dla Reservation_id 5
INSERT INTO Attractions_Trippers (AT_id, Tripper_id, AR_id) VALUES
(6, 6, 3),  -- AT_id 6, Tripper_id 6, RA_id 5
(7, 7, 3),  -- AT_id 7, Tripper_id 7, RA_id 5
(8, 8, 3),  -- AT_id 8, Tripper_id 8, RA_id 5
(9, 9, 3)   -- AT_id 9, Tripper_id 9, RA_id 5

SET IDENTITY_INSERT Attractions_Trippers OFF;

-- PAYMENTS

INSERT INTO Payments (Paid, Method, Timestamp, Reservation_id)
VALUES
(540.00, 'M', '2024-05-19 18:31:34', 1),  -- Rezerwacja 1
(3120.00, 'M', '2024-05-19 18:31:34', 2), -- Rezerwacja 2
(2600.00, 'C', '2024-05-19 18:31:34', 4), -- Rezerwacja 4
(7200.00, 'P', '2024-05-19 18:31:34', 5); -- Rezerwacja 5