-- Testy dla procedury 1
-- Zmiana ceny wycieczki
exec update_trip_price
    @trip_id = 1,
    @new_price = 600.00

select * from Trips


-- Testy dla procedury 2
-- Zmiana limitu miejsc na wycieczkę
exec update_trip_limit
    @trip_id = 1,
    @new_limit = 13

select * from Trips


-- Testy dla procedury 3
-- Zmiana ceny atrakcji
exec update_attraction_price
    @attraction_id = 1,
    @new_price = 100.00

select * from Attractions


-- Testy dla procedury 4
-- Zmiana limitu dla atrakcji
exec update_attraction_limit
    @attraction_id = 1,
    @new_limit = 11

select * from Attractions


-- Testy dla procedury 5
-- Dodanie nowego klienta jako osoby fizycznej
exec add_new_client
    @Email = 'jan.kowal@example.com',
    @Phone = '123456789',
    @Client_type = 'c',
    @Firstname = 'Jan',
    @Lastname = 'Kowal'

select * from Clients;
select * from Customers;

-- Dodanie nowego klienta jako firmy
exec add_new_client
    @Email = 'contact@microsoft.com',
    @Phone = '987654321',
    @Client_type = 'p',
    @Company_name = 'Microsoft',
    @NIP = 1234567890;

select * from Clients;
select * from Companies;


-- Testy dla procedury 6
-- Dodanie wycieczki do istniejącego państwa
-- Powinno się udać!
exec add_new_trip
    @Name = 'Sightseeing in paris',
    @City = 'Paris',
    @Country = 'France',
    @Date = '2024-07-22',
    @Price_per_person = '700.0000',
    @Limit = 15,
    @Start_reservation = '2024-06-22 2:00:00.000'

-- Wynik dodania nowej wycieczki, można podejrzeć w tabeli Trips
select * from Trips

-- Dodanie wycieczki do nieistniejącego miasta
-- Powinno się nie udać!
exec add_new_trip
    @Name = 'Travel to Naples',
    @City = 'Naples',
    @Country = 'Italy',
    @Date = '2024-08-20',
    @Price_per_person = '450.0000',
    @Limit = 7,
    @Start_reservation = '2024-06-11 12:00:00.000'

-- Dodanie wycieczki do nieistniejącego państwa oraz miasta
-- Powinno się nie udać!
exec add_new_trip
    @Name = 'Walk around Krakow',
    @City = 'Krako',
    @Country = 'Poland',
    @Date = '2024-10-15',
    @Price_per_person = '200.0000',
    @Limit = 20,
    @Start_reservation = '2024-08-13 05:00:00.000'


-- Testy dla procedury 7
-- Dodanie nowej atrakcji dla wycieczki o istniejącym Trip_id
exec add_new_attraction
    @Trip_id = 2,
    @Name = 'Forum Romanum Visit',
    @Price_per_person = 60.0000,
    @Limit = 5

select * from Attractions

-- Dodanie nowej atrakcji dla wycieczki o nieistniejącym Trip_id
-- Powinno się nie udać!
exec add_new_attraction
    @Trip_id = 100,
    @Name = 'Forum Romanum Visit',
    @Price_per_person = 60.0000,
    @Limit = 5


-- Testy dla procedury 8
-- Dodawanie nowej rezerwacji
exec add_new_reservation
    @Trip_id = 8,
    @Client_id = 1,
    @Count_of_trippers = 1

select * from Reservations

-- Dodanie nowej rezerwacji nie powinno się udać
-- z powodu braku miejsc na wycieczkę (Trip_id=8)
exec add_new_reservation
    @Trip_id = 8,
    @Client_id = 1,
    @Count_of_trippers = 100

select * from Reservations


-- Testy dla procedury 9
-- Anulowanie rezerwacji
exec cancel_reservation
    @Reservation_id = 1

select * from Reservations

-- Testy dla procedury 10
-- Cofnięcie anulowania rezerwacji
exec return_reservation
    @Reservation_id = 1

-- TODO
-- Tutaj cofnięcie anulowanie rezerwacji nie powinno się udać!
exec return_reservation
    @Reservation_id = 1


-- Testy dla procedury 11
-- Dodanie istniejącego gościa jako uczestnika wycieczki
exec add_new_tripper
    @Reservation_id = 4,
    @Firstname = 'Jan',
    @Lastname = 'Kowalski',
    @Email = 'adam.kowalski@example.com',
    @Phone = '234567890'

-- Sprawdzamy czy dodano nowego uczestnika wycieczki
select * from Trippers
where Reservation_id = 4;

-- Podejrzeć można, że Jan Kowalski jest już w People
select * from People
where Email = 'adam.kowalski@example.com' and Phone = '234567890';

-- Dodanie nowej osoby jako uczestnika wycieczki
exec add_new_tripper
    @Reservation_id = 4,
    @Firstname = 'Jasio',
    @Lastname = 'Motyl',
    @Email = 'jan.motyl@example.com',
    @Phone = '794776667'

-- Sprawdzany czy dodano nowego uczestnika wycieczki
select * from Trippers
where Reservation_id = 4

-- Podejrzeć można, że Jan Motyl jest nowy w tabeli People, ma najwięjsze Person_id
select * from People
where Email = 'jan.motyl@example.com' and Phone = '794776667'


-- Testy dla procedury 12
-- Dodanie nowej rezerwacji atrakcji
exec add_new_attraction_reservation
    @Reservation_id = 3,
    @Attraction_id = 7,
    @Count_of_trippers = 1

-- Sprawdzamy czy dodano nową rezerwację atrakcji
select * from Attraction_Reservations


-- Testy dla procedury 13
-- Doanie nowej platności
exec add_new_payment
    @Paid = 2000,
    @Reservation_id = 6,
    @Method = 'C'

-- Sprawdzenie rekordów w tabeli Payments
select * from Payments
where Reservation_id = 6