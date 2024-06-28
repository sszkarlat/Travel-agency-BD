--Panel Admina

-- 1.Dodanie nowej wycieczki # tworzy się o id 10
EXEC add_new_trip 
    @Name = 'Nowa Wycieczka Testowa2',
    @City = 'Sydney',
    @Country = 'Australia',
    @Date = '2024-12-20',
    @Price_per_person = 150.00,
    @Limit = 20,
    @Start_reservation = '2024-06-18';

-- 2.Dodanie nowej atrakcji = nie zadziała, bo limitAtrakcji > limitWycieczki
EXEC add_new_attraction 
    @Trip_id = 10, 
    @Name = 'Nowa Atrakcja Testowa',
    @Price_per_person = 50.00,
    @Limit = 25;

-- 3.Dodanie nowej atrakcji = zadziala #tworzy się o id 26
EXEC add_new_attraction 
    @Trip_id = 10, 
    @Name = 'Nowa Atrakcja Testowa',
    @Price_per_person = 50.00,
    @Limit = 15;


-- 10.Zmiana kosztu wycieczki
exec update_trip_price
    @trip_id = 10,
    @new_price = 200.00

-- 14. Sprawdzenie, czy dodano nowe dane: [Osoba/rezerwacja/rezerwacja atrakcji]
select TOP 5 * from People
Order by Person_id DESC;

select TOP 5 * from reservations
Order by Reservation_id DESC;

Select TOP 5 * from Trippers_lists
Order by Trip_id DESC;

select TOP 5 * from Attractions_lists
Order by Attraction_id DESC

select TOP 5 * from attraction_reservations
Order by AR_id DESC;


-- 15.Zmiana limitu wycieczki = nie zadziała, limit jest mniejszy niż liczba uczestników
UPDATE Trips
SET Limit = 5
WHERE Trip_id = 10;

-- 16.Zmiana limitu wycieczki = zadziała, limit jest OK
UPDATE Trips
SET Limit = 17
WHERE Trip_id = 10;
