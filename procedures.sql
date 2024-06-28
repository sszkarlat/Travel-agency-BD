-- procedura 1 - zmień cenę za wycieczkę
create procedure update_trip_price
    @trip_id int,
    @new_price money
as
begin
    update Trips
    set Price_per_person = @new_price
    where Trip_id = @trip_id;
end;

-- procedura 2 - zmień limit miejsc na wycieczkę
create procedure update_trip_limit
    @trip_id int,
    @new_limit int 
as
begin
    update Trips
    set Limit = @new_limit
    where Trip_id = @trip_id;
end;

-- procedura 3 - zmień cenę za atrakcję
create procedure update_attraction_price
    @attraction_id int,
    @new_price money
as
begin
    update Attractions
    set Price_per_person = @new_price
    where Attraction_id = @attraction_id;
end;

-- procedura 4 - zmień limit miejsc na atrakcję
create procedure update_attraction_limit
    @attraction_id int,
    @new_limit int
as
begin
    update Attractions
    set Limit = @new_limit
    where Attraction_id = @attraction_id;
end;

-- procedura 5 - dodawanie nowego klienta (firmy albo osoby fizycznej)
create or alter procedure add_new_client
    @Email = 0),
    @Phone = ,
    @Client_type CHAR(1), -- 'C' dla osoby fizycznej, 'P' dla firmy
    @Firstname = ) = null,
    @Lastname = ) = null,
    @Company_name = ) = null,
    @NIP int = null
as
begin
    begin transaction;
    begin try

        set nocount on;

        -- Sprawdzanie warunków przed rozpoczęciem transakcji
        if @Client_type = 'C' and (@Firstname is null or @Lastname is null)
        begin
            raiserror('Firstname and Lastname are required for Customers.', 16, 1);
            rollback transaction;
            return;
        end

        if @Client_type = 'P' and (@Company_name is null or @NIP is null)
        begin
            raiserror('CompanyName and NIP are required for Companies.', 16, 1);
            rollback transaction;
            return;
        end

        if @Client_type not in ('C', 'P')
        begin
            raiserror('Invalid Client_type. Use ''C'' for Customers or ''P'' for Companies.', 16, 1);
            rollback transaction;
            return;
        end

        declare @Client_id int;

        -- Dodawanie nowego klienta do tabeli Clients
        insert into Clients (Email, Phone)
        values (@Email, @Phone);

        -- Pobieranie ID nowo dodanego klienta
        set @Client_id = SCOPE_IDENTITY();

        -- Dodawanie klienta do tabeli Customers lub Companies na podstawie typu klienta
        if @Client_type = 'C'
        begin
            insert into Customers (Client_id, Firstname, Lastname)
            values (@Client_id, @Firstname, @Lastname);
        end
        else if @Client_type = 'P'
        begin
            insert into Companies (Client_id, Company_name, NIP)
            values (@Client_id, @Company_name, @NIP);
        end

        -- Jeśli wszystko się powiodło, zatwierdź transakcję
        commit transaction;
    end try
    begin catch
        -- Jeśli wystąpił błąd, wycofaj transakcję
        if @@TRANCOUNT > 0
            rollback transaction;

        -- Rzuć błąd ponownie, aby informować o problemie
        throw;
    end catch
end;


-- Testy dla procedura 5
-- Dodanie nowego klienta jako osoby fizycznej
exec add_new_client
    @Email = 'jan.kowal@example.com',
    @Phone = '123456789',
    @Client_type = 'c',
    @Firstname = 'Jan',
    @Lastname = 'Kowal'

select * from Clients;

-- Dodanie nowego klienta jako firmy
exec add_new_client
    @Email = 'contact@microsoft.com',
    @Phone = '987654321',
    @Client_type = 'x',
    @Company_name = 'Microsoft',
    @NIP = 1234567890;


-- procedura 6 - dodanie nowej wycieczki
create or alter procedure add_new_trip
(
    @Name = ),
    @City = ),
    @Country = ),
    @Date date,
    @Price_per_person money,
    @Limit int,
    @Start_reservation datetime
)
as
begin
    declare @City_id int;
    declare @Country_id int;

    -- Sprawdzenie czy kraj  i miasto już istnieje
    if EXISTS (select * from Countries where Country = @Country)
           and EXISTS (select * from Cities where City = @City)
    begin
        select @Country_id = Country_id
        from Countries
        where Country = @Country;

        select @City_id = City_id
        from Cities
        where City = @City;
    end

    -- Dodanie nowej wycieczki
    insert into Trips (Name, City_id, Date, Price_per_person, Limit, Start_reservation)
    values (@Name, @City_id, @Date, @Price_per_person, @Limit, @Start_reservation);
end;

-- Test działania
exec add_new_trip
    @Name = 'Sightseeing in paris',
    @City = 'Paris',
    @Country = 'France',
    @Date = '2024-07-22',
    @Price_per_person = '700.0000',
    @Limit = 15,
    @Start_reservation = '2024-06-22 2:00:00.000'

exec add_new_trip
    @Name = 'Travel to Naples',
    @City = 'Naples',
    @Country = 'Italy',
    @Date = '2024-08-20',
    @Price_per_person = '450.0000',
    @Limit = 7,
    @Start_reservation = '2024-06-11 12:00:00.000'

exec add_new_trip
    @Name = 'Walk around Krakow',
    @City = 'Krako',
    @Country = 'Poland',
    @Date = '2024-10-15',
    @Price_per_person = '200.0000',
    @Limit = 20,
    @Start_reservation = '2024-08-13 05:00:00.000'

select * from Trips

-- procedura 7 - dodanie nowej atrakcji
create or alter procedure add_new_attraction
(
    @Trip_id int,
    @Name = ),
    @Price_per_person money,
    @Limit int
)
as
begin
    insert into Attractions (Trip_id, Name, Price_per_person, Limit)
    values (@Trip_id, @Name, @Price_per_person, @Limit);
end;

-- testy działania
exec add_new_attraction
    @Trip_id = 45,
    @Name = 'Climbing Vesuvius',
    @Price_per_person = 60.0000,
    @Limit = 3

select * from Attractions


-- procedura 8 - zaaktualizuj dane klienta
create or alter procedure update_client
(
    @Client_id int,
    @New_value = 0),
    @Update_type char(1) -- 'E' dla Email, 'P' dla Phone
)
as
begin
    if @Update_type = 'E'
    begin
        update Clients
        set Email = @New_value
        where Client_id = @Client_id;
    end
    else if @Update_type = 'P'
    begin
        update Clients
        set Phone = @New_value
        where Client_id = @Client_id;
    end
    else
    begin
        raiserror('Invalid Update_type. Use ''E'' for Email or ''P'' for Phone.', 16, 1);
    end
end;


-- test działania
exec update_client
    @Client_id = 11,
    @New_value = 'kowalski@onet.pl',
    @Update_type = 'E'

exec update_client
    @Client_id = 1,
    @New_value = '794551123',
    @Update_type = 'P'

select * from Clients;

-- procedura 9 - anulowanie rezerwacji
create or alter procedure cancel_reservation
(
    @Reservation_id int
)
as
begin
    begin transaction ;

    begin try
        -- Oznacz rezerwację jako anulowaną
        update Reservations
        SET Cancelled = 1
        where Reservation_id = @Reservation_id;

        commit transaction ;
    end try
    begin catch
        if @@TRANCOUNT > 0
            rollback transaction ;
        throw;
    end catch;
end;

-- test działania
exec cancel_reservation
    @Reservation_id = 1

select * from Reservations

select * from Trippers

-- procedura 10 - dodanie nowej rezerwacji
create or alter procedure add_new_reservation
(
    @Trip_id int,
    @Client_id int,
    @Count_of_trippers int,
    @Cancelled bit = 0
)
as
begin
    declare @Price_per_person money;
    select @Price_per_person = Price_per_person from Trips where Trip_id = @Trip_id;

    insert into Reservations (Trip_id, Client_id, Price_per_person, Count_of_trippers, Cancelled)
    values (@Trip_id, @Client_id, @Price_per_person, @Count_of_trippers, @Cancelled);
end;

exec add_new_reservation
    @Trip_id = 8,
    @Client_id = 1,
    @Count_of_trippers = 1

select * from Reservations

-- procedura 11 - dodanie nowej płatności
create or alter procedure add_new_payment
(
    @Paid money,
    @Reservation_id int,
    @Method char(1)
)
as
begin
    declare @Timestamp datetime;

    select @Timestamp = CAST(SYSDATETIME() as datetime)

    insert into Payments (Paid, Timestamp, Reservation_id, Method)
    values (@Paid, @Timestamp, @Reservation_id, @Method);
end;

-- test działania
exec add_new_payment
    @Paid = 2000,
    @Reservation_id = 6,
    @Method = 'C'

select * from Reservations
where Reservation_id = 6

select * from Payments
where Reservation_id = 6


-- procedura 12 - zaaktualizowanie daty odbycia się wycieczki
create or alter procedure update_trip_date
(
    @Trip_id int,
    @Date date
)
as
begin
    update Trips
    set Date = @Date
    where Trip_id = @Trip_id;
end;

-- test dziłania
exec update_trip_date
    @Trip_id = 1,
    @Date = '2024-06-17'

select * from Trips
where Trip_id = 1


-- procedura 13 - zaaktualizowanie daty rozpoczęcia rezerwacji
create or alter procedure update_trip_start_reservation
(
    @Trip_id int,
    @Start_reservation datetime
)
as
begin
    update Trips
    set Start_reservation = @Start_reservation
    where Trip_id = @Trip_id;
end;

-- test działania
exec update_trip_start_reservation
    @Trip_id = 1,
    @Start_reservation = '2024-05-15 10:00:00.000'

select * from Trips
where Trip_id = 1

-- procedura 14 - zmiana danych w tabeli People
create or alter procedure update_person_data
(
    @Person_id int,
    @Update_type char(1), -- 'E' dla Email, 'P' dla Phone
    @Email = 0) = null,
    @Phone =  = null
)
as
begin
    if @Update_type = 'E'
    begin
        update People
        set Email = @Email
        where Person_id = @Person_id;
    end
    else if @Update_type = 'P'
    begin
        update People
        set Phone = @Phone
        where Person_id = @Person_id;
    end
end;

-- test działania
select * from People
where Person_id = 1

exec update_person_data
    @Person_id = 1,
    @Update_type = 'P', -- 'E' dla Email, 'P' dla Phone
    @Phone = '234567890'

select * from People
where Person_id = 1


-- procedura 15 - dodanie nowej rezerwacji atrakcji
create or alter procedure add_new_attraction_reservation
(
    @Reservation_id int,
    @Attraction_id int,
    @Count_of_trippers int
)
as
begin
    declare @Price_per_person money;
    select @Price_per_person = Price_per_person from Attractions where Attraction_id = @Attraction_id;

    insert into Attraction_Reservations (Price_per_person, Count_of_trippers, Attraction_id, Reservation_id)
    values (@Price_per_person, @Count_of_trippers, @Attraction_id, @Reservation_id);
end;

select * from Attractions
select * from Attraction_Reservations

exec add_new_attraction_reservation
    @Reservation_id = 3,
    @Attraction_id = 7,
    @Count_of_trippers = 1

select * from Attraction_Reservations

-- procedura 16 - dodawanie nowego uczestnika wycieczki
create or alter procedure add_new_tripper
    @Reservation_id int,
    @Firstname varchar(40),
    @Lastname varchar(40),
    @Email varchar(100),
    @Phone varchar(9)
as
begin
    begin transaction;

    begin try
        set nocount on;

        declare @Person_id int;

        -- Sprawdź, czy osoba już istnieje w tabeli People
        select @Person_id = Person_id
        from People
        where Firstname = @Firstname
          and Lastname = @Lastname
          and Email = @Email
          and Phone = @Phone;

        -- Jeśli osoba nie istnieje, dodaj ją do tabeli People
        if @Person_id is null
        begin
            insert into People (Firstname, Lastname, Email, Phone)
            values (@Firstname, @Lastname, @Email, @Phone);

            set @Person_id = SCOPE_IDENTITY();
        end

        -- Dodaj nowego członka wycieczki do tabeli Trippers
        insert into Trippers (Reservation_id, Person_id)
        values (@Reservation_id, @Person_id);

        commit transaction;
    end try
    begin catch
        if @@TRANCOUNT > 0
            rollback transaction;

        throw;
    end catch
end;

-- Testy
-- Dodanie istniejącego gościa
exec add_new_tripper
    @Reservation_id = 4,
    @Firstname = 'Jan',
    @Lastname = 'Kowalski',
    @Email = 'adam.kowalski@example.com',
    @Phone = '234567890'

-- Testy działania
select * from Reservations
where Trip_id = 6

select * from People
where Person_id = 1

select t.Tripper_id, t.Reservation_id, t.Person_id, p.Firstname, p.Lastname from Trippers t
join People p on p.Person_id=t.Person_id
where Reservation_id = 4

select * from People
where Firstname = 'Jan' and Lastname = 'Motyl'

select * from Reservations
where Reservation_id = 4

-- Dodanie nowej osoby
exec add_new_tripper
    @Reservation_id = 4,
    @Firstname = 'Jasio',
    @Lastname = 'Motyl',
    @Email = 'jan.motyl@example.com',
    @Phone = '794776667'


select * from Reservations
where Reservation_id = 4
select * from People;

select * from Trippers
where Reservation_id = 4

select * from Reservations
where Trip_id = 3 and Cancelled = 0

select * from Trips
where Trip_id = 3

select * from Reservations
where Reservation_id = 3

exec add_new_reservation
    @Trip_id = 6,
    @Client_id = 1,
    @Count_of_trippers = 1

exec return_reservation
    @Reservation_id = 3

select * from Reservations

exec cancel_reservation
    @Reservation_id = 24

exec update_trip_limit
    @trip_id = 2,
    @new_limit = 1

select * from Trips


-- procedura przywraca wycieczkę do "żywych"
create or alter procedure return_reservation
(
    @Reservation_id int
)
as
begin
    begin transaction ;

    begin try
        -- Oznacz rezerwację jako anulowaną
        update Reservations
        SET Cancelled = 0
        where Reservation_id = @Reservation_id;

        commit transaction ;
    end try
    begin catch
        if @@TRANCOUNT > 0
            rollback transaction ;
        throw;
    end catch;
end;

