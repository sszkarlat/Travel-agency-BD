-- Procedura 1 - zamiana ceny za wycieczkę
create or alter procedure update_trip_price
    @trip_id int,
    @new_price money
as
begin
    update Trips
    set Price_per_person = @new_price
    where Trip_id = @trip_id;
end;

-- Procedura 2 - zamiana limitu miejsc na wycieczkę
create or alter procedure update_trip_limit
    @trip_id int,
    @new_limit int
as
begin
    update Trips
    set Limit = @new_limit
    where Trip_id = @trip_id;
end;

-- Procedura 3 - zamiana ceny za atrakcję
create or alter procedure update_attraction_price
    @attraction_id int,
    @new_price money
as
begin
    update Attractions
    set Price_per_person = @new_price
    where Attraction_id = @attraction_id;
end;

-- Procedura 4 - zamiana limitu miejsc na atrakcję
create or alter procedure update_attraction_limit
    @attraction_id int,
    @new_limit int
as
begin
    update Attractions
    set Limit = @new_limit
    where Attraction_id = @attraction_id;
end;

-- Procedura 5 - dodawanie nowego klienta (firmę albo osobe fizyczną)
create or alter procedure add_new_client
    @Email varchar(100),
    @Phone varchar(9),
    @Client_type char(1), -- 'C' dla osoby fizycznej, 'P' dla firmy
    @Firstname varchar(40) = null,
    @Lastname varchar(40) = null,
    @Company_name varchar(50) = null,
    @NIP int = null
as
begin
    begin transaction;

    begin try
        set nocount on;

        -- Sprawdzanie warunków przed wykonaniem operacji
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

-- Procedura 6 - dodawanie nowej wycieczki
create or alter procedure add_new_trip
(
    @Name varchar(40),
    @City varchar(50),
    @Country varchar(50),
    @Date date,
    @Price_per_person money,
    @Limit int,
    @Start_reservation datetime
)
as
begin
    declare @City_id int;
    declare @Country_id int;

    -- Sprawdzenie, czy daty są poprawne
    if @Date < getdate()
    begin
        raiserror('The trip start date cannot be in the past.', 16, 1);
        return;
    end

    if @Start_reservation < cast(getdate() as date)
    begin
        raiserror('The reservation start date cannot be in the past.', 16, 1);
        return;
    end

    if @Date < DATEADD(Day, 7, @Start_reservation)
    begin
        raiserror('The trip start date must be at least 7 days later than the reservation start date.', 16, 1);
        return;
    end

    -- Sprawdzenie czy kraj i miasto już istnieją
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
    else
    begin
        raiserror('The specified country or city does not exist.', 16, 1);
        return;
    end

    -- Dodanie nowej wycieczki
    insert into Trips (Name, City_id, Date, Price_per_person, Limit, Start_reservation)
    values (@Name, @City_id, @Date, @Price_per_person, @Limit, @Start_reservation);
end;


-- Procedura 7 - dodawanie nowej atrakcji
create or alter procedure add_new_attraction
(
    @Trip_id int,
    @Name varchar(50),
    @Price_per_person money,
    @Limit int
)
as
begin
    insert into Attractions (Trip_id, Name, Price_per_person, Limit)
    values (@Trip_id, @Name, @Price_per_person, @Limit);
end;

-- Procedura 8 - dodawanie nowej rezerwacji wycieczki
create or alter procedure add_new_reservation
(
    @Trip_id int,
    @Client_id int,
    @Count_of_trippers int,
    @Cancelled bit = 0
)
as
begin
    -- Uniemożliw dodanie rezerwacji z Cancelled = 1
    if @Cancelled = 1
    begin
        raiserror('Cannot add a reservation with Cancelled set to 1.', 16, 1);
        return;
    end

    declare @Price_per_person money;
    select @Price_per_person = Price_per_person from Trips where Trip_id = @Trip_id;

    insert into Reservations (Trip_id, Client_id, Price_per_person, Count_of_trippers, Cancelled)
    values (@Trip_id, @Client_id, @Price_per_person, @Count_of_trippers, @Cancelled);
end;

-- Procedura 9 - anulowanie wycieczki
create or alter procedure cancel_reservation
(
    @Reservation_id int
)
as
begin
    -- Oznacz rezerwację jako anulowaną
    update Reservations
    set Cancelled = 1
    where Reservation_id = @Reservation_id;
end;

-- Procedura 10 - cofnięcie anulowania wycieczki
create or alter procedure return_reservation
(
    @Reservation_id int
)
as
begin
    -- Cofnij anulowanie rezerwacji
    update Reservations
    set Cancelled = 0
    where Reservation_id = @Reservation_id;
end;

-- Procedura 11 - dodawanie nowego uczestnika wycieczki
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
        declare @Cancelled bit;
        declare @Trip_id int;
        declare @Client_id int;

        -- Sprawdź, czy rezerwacja jest anulowana
        select @Cancelled = Cancelled, @Trip_id = Trip_id
        from Reservations
        where Reservation_id = @Reservation_id;

        if @Cancelled = 1
        begin
            raiserror('Cannot add a tripper to a cancelled reservation.', 16, 1);
            rollback transaction;
            return;
        end

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

        -- Pobranie Client_id, który dokonał rezerwacji
        select @Client_id = Client_id
        from Reservations
        where Reservation_id = @Reservation_id

        -- Sprawdź, czy osoba już jest przypisana do jakiejkolwiek rezerwacji w ramach tej samej wycieczki (Trip_id)
        if exists (
            select 1
            from Trippers t
            join Reservations r on t.Reservation_id = r.Reservation_id
            where r.Trip_id = @Trip_id and r.Client_id = @Client_id
              and t.Person_id = @Person_id
        )
        begin
            raiserror('This person is already a tripper for a reservation within the same trip.', 16, 1);
            rollback transaction;
            return;
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



-- Procedura 12 - dodawanie nowej rezerwacji atrakcji
create or alter procedure add_new_attraction_reservation
(
    @Reservation_id int,
    @Attraction_id int,
    @Count_of_trippers int
)
as
begin
    begin transaction;

    begin try
        set nocount on;

        declare @Price_per_person money;
        declare @Cancelled bit;
        declare @Trip_id int;
        declare @MaxTrippersCount int;
        declare @TotalTrippersCount int;

        -- Sprawdź, czy rezerwacja jest anulowana
        select @Cancelled = Cancelled, @Trip_id = Trip_id, @MaxTrippersCount = Count_of_trippers
        from Reservations
        where Reservation_id = @Reservation_id;

        if @Cancelled = 1
        begin
            raiserror('Cannot add a reservation for an attraction to a cancelled reservation.', 16, 1);
            rollback transaction;
            return;
        end

        -- Sprawdź, czy atrakcja jest przypisana do wycieczki
        if not exists (
            select 1
            from Attractions
            where Trip_id = @Trip_id and Attraction_id = @Attraction_id
        )
        begin
            raiserror('The selected attraction is not available for the trip associated with this reservation.', 16, 1);
            rollback transaction;
            return;
        end

        -- Pobierz cenę za osobę z tabeli Attractions
        select @Price_per_person = Price_per_person
        from Attractions
        where Attraction_id = @Attraction_id;

        -- Oblicz sumę Count_of_trippers dla wszystkich rezerwacji atrakcji w ramach danej rezerwacji wycieczki
        select @TotalTrippersCount = ISNULL(sum(ar.Count_of_trippers), 0)
        from Attraction_Reservations ar
        where ar.Reservation_id = @Reservation_id and ar.Attraction_id = @Attraction_id;

        -- Sprawdź, czy nowa liczba trippers nie przekracza maksymalnej liczby dozwolonej dla tej rezerwacji
        if @TotalTrippersCount + @Count_of_trippers > @MaxTrippersCount
        begin
            -- Wycofaj transakcję, jeśli limit został przekroczony
            raiserror('The number of trippers exceeds the allowed limit for this reservation.', 16, 1);
            rollback transaction;
            return;
        end

        -- Dodaj nową rezerwację atrakcji
        insert into Attraction_Reservations (Price_per_person, Count_of_trippers, Attraction_id, Reservation_id)
        values (@Price_per_person, @Count_of_trippers, @Attraction_id, @Reservation_id);

        commit transaction;
    end try
    begin catch
        if @@TRANCOUNT > 0
            rollback transaction;

        throw;
    end catch
end;


-- Procedura 13 - dodawanie nowej płatności
create or alter procedure add_new_payment
(
    @Paid money,
    @Reservation_id int,
    @Method char(1)
)
as
begin
    declare @Timestamp datetime;
    declare @Cancelled bit;
    declare @TripDate date;

    select @Cancelled = r.Cancelled, @TripDate = t.Date
    from Reservations r
    join Trips t on r.Trip_id = t.Trip_id
    where r.Reservation_id = @Reservation_id;

    -- Uniemożliwienie dodania płatności na rezerwację anulowaną
    if @Cancelled = 1
    begin
        raiserror('Cannot add a payment to a cancelled reservation.', 16, 1);
        return;
    end

    -- Uniemożliwienie dodania płatności, jeśli data rozpoczęcia wycieczki jest mniejsza niż 7 dni od daty systemowej
    if @TripDate < DATEADD(day, 7, CAST(SYSDATETIME() as date))
    begin
        raiserror('Cannot add a payment for a trip that starts in less than 7 days.', 16, 1);
        return;
    end

    select @Timestamp = CAST(SYSDATETIME() as datetime);

    insert into Payments (Paid, Timestamp, Reservation_id, Method)
    values (@Paid, @Timestamp, @Reservation_id, @Method);
end;

-- Procedura 14 - dodawanie nowego uczestnika atrakcji
create or alter procedure add_new_attraction_tripper
(
    @Tripper_id int,
    @AR_id int
)
as
begin
    set nocount on;

    begin transaction;

    begin try
        declare @Reservation_id int;
        declare @Trip_id int;
        declare @TripDate date;
        declare @Cancelled bit;
        declare @Attraction_id int;
        declare @Client_id int;

        -- Sprawdź, czy tripper istnieje w tabeli Trippers i jest powiązany z odpowiednią Reservation_id
        select @Reservation_id = t.Reservation_id
        from Trippers t
        where t.Tripper_id = @Tripper_id;

        if @Reservation_id is null
        begin
            raiserror('The tripper does not exist in the Trippers table or is not associated with any reservation.', 16, 1);
            rollback transaction;
            return;
        end

        -- Pobierz dane rezerwacji i wycieczki
        select
            @Trip_id = r.Trip_id,
            @Cancelled = r.Cancelled
        from Reservations r
        where r.Reservation_id = @Reservation_id;

        -- Pobierz datę wycieczki
        select @TripDate = t.Date
        from Trips t
        where t.Trip_id = @Trip_id;

        -- Pobierz Client_id, który dokonywał rezerwacji
        select @Client_id = Client_id
        from Reservations
        where Reservation_id = @Reservation_id;

        -- Sprawdź, czy rezerwacja jest anulowana
        if @Cancelled = 1
        begin
            raiserror('Cannot add a tripper to an attraction for a cancelled reservation.', 16, 1);
            rollback transaction;
            return;
        end

        -- Sprawdź, czy data wycieczki jest mniejsza niż 7 dni od daty systemowej
        if @TripDate < DATEADD(day, 7, CAST(GETDATE() as date))
        begin
            raiserror('Cannot add a tripper to an attraction for a trip that starts in less than 7 days.', 16, 1);
            rollback transaction;
            return;
        end

        -- Pobierz Attraction_id na podstawie AR_id
        select @Attraction_id = ar.Attraction_id
        from Attraction_Reservations ar
        where ar.AR_id = @AR_id;

        if @Attraction_id is null
        begin
            raiserror('Invalid AR_id provided.', 16, 1);
            rollback transaction;
            return;
        end

        -- Sprawdź, czy ten tripper już istnieje w tabeli Attractions_Trippers dla tej samej atrakcji w ramach tej samej wycieczki
        if exists (
            select 1
            from Attractions_Trippers at
            join Attraction_Reservations ar on at.AR_id = ar.AR_id
            join Reservations r on ar.Reservation_id = r.Reservation_id
            join Trips t on r.Trip_id = t.Trip_id
            where at.Tripper_id = @Tripper_id
              and ar.Attraction_id = @Attraction_id
              and t.Trip_id = @Trip_id and r.Client_id = @Client_id
        )
        begin
            raiserror('This tripper is already registered for the selected attraction within the same trip.', 16, 1);
            rollback transaction;
            return;
        end

        -- Dodaj nowego uczestnika do atrakcji
        insert into Attractions_Trippers (Tripper_id, AR_id)
        values (@Tripper_id, @AR_id);

        commit transaction;
    end try
    begin catch
        if @@TRANCOUNT > 0
            rollback transaction;

        throw;
    end catch
end;