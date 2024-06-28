-- Trigger 1 - sprawdzanie  czy liczba osób ze wszystkich rezerwacji atrakcji
-- jest mniejsza niż limit danej atrakcji
create or alter trigger CheckAttractionTrippersLimit
    on Attraction_Reservations
    after insert, update
    as
begin

    -- Sprawdź, czy operacja dotyczy tylko jednego wiersza
    if (select count(*) from inserted) > 1 or (select count(*) from deleted) > 1
    begin
        rollback transaction;
        raiserror('The trigger supports only single-row operations.', 16, 1);
        return;
    end

    if exists (
        select 1
        from inserted i
                 join (
            select Attraction_id, SUM(Count_of_trippers) as TotalTrippers
            from Attraction_Reservations
            where Attraction_id in (select Attraction_id from inserted)
            group by Attraction_id
        ) R on i.Attraction_id = R.Attraction_id
                 join Attractions A on i.Attraction_id = A.Attraction_id
        where R.TotalTrippers+i.Count_of_Trippers > A.limit
    )
        begin
            raiserror ('There are not that many vacancies for this attraction.', 16, 1);
            rollback transaction;
            return;
        end;
end;

-- Testy dla triggera 1
-- Atrakcja o id 2 ma tylko 14 wolnych miejsc, więc spróbujemy umieścić tam 15 uczestników:
-- exec add_new_attraction_reservation
--     @Reservation_id = 1,
--     @Attraction_id = 2,
--     @Count_of_trippers = 15


-- Triger 2 - sprawdzenie czy można dodać nowego uczestnika wycieczki,
-- poprzez sprawdzenie czy rezerwacja jest aktualna (Cancelled = 0) oraz czy limit się zgadza.
create or alter trigger CheckTripperCount
on Trippers
after insert, update
as
begin
    set nocount on;

    -- Sprawdź, czy operacja dotyczy tylko jednego wiersza
    if (select count(*) from inserted) > 1 or (select count(*) from deleted) > 1
    begin
        rollback transaction;
        raiserror('The trigger supports only single-row operations.', 16, 1);
        return;
    end

    declare @Reservation_id int;
    declare @CurrentTrippersCount int;
    declare @MaxTrippersCount int;
    declare @Cancelled bit;

    -- Pobierz Reservation_id z wstawionego lub zaktualizowanego rekordu
    select @Reservation_id = inserted.Reservation_id
    from inserted;

    -- Pobierz bieżącą liczbę osób zarezerwowanych dla tej rezerwacji
    select @CurrentTrippersCount = count(*)
    from Trippers
    where Reservation_id = @Reservation_id;

    -- Pobierz maksymalną liczbę osób dozwoloną dla tej rezerwacji oraz status anulowania
    select @MaxTrippersCount = Count_of_trippers, @Cancelled = Cancelled
    from Reservations
    where Reservation_id = @Reservation_id;

    -- Sprawdź, czy liczba osób nie przekracza dozwolonego limitu lub rezerwacja jest anulowana
    if @CurrentTrippersCount > @MaxTrippersCount or @Cancelled = 1
    begin
        -- Wycofaj transakcję, jeśli limit został przekroczony lub rezerwacja jest anulowana
        rollback transaction;

        -- Rzuć błąd
        if @Cancelled = 1
        begin
            raiserror('Cannot add trippers to a cancelled reservation.', 16, 1);
        end
        else
        begin
            raiserror('The number of trippers exceeds the allowed limit for this reservation.', 16, 1);
        end
    end
end;


-- Trigger 3 - sprawdza czy nowo dodawana atrakcja ma limit nie większy niż dana wycieczka
create or alter trigger CheckAttractionLimit
on Attractions
after insert, update
as
begin
    set nocount on;

    -- Sprawdź, czy operacja dotyczy tylko jednego wiersza
    if (select count(*) from inserted) > 1 or (select count(*) from deleted) > 1
    begin
        rollback transaction;
        raiserror('The trigger supports only single-row operations.', 16, 1);
        return;
    end

    declare @Trip_id int;
    declare @AttractionLimit int;
    declare @TripLimit int;

    -- Pobierz Trip_id oraz Limit z wstawionego lub zaktualizowanego rekordu
    select @Trip_id = inserted.Trip_id, @AttractionLimit = inserted.Limit
    from inserted;

    -- Pobierz limit wycieczki z tabeli Trips
    select @TripLimit = Limit
    from Trips
    where Trip_id = @Trip_id;

    -- Sprawdź, czy limit atrakcji jest mniejszy lub równy limitowi wycieczki
    if @AttractionLimit > @TripLimit
    begin
        -- Wycofaj transakcję, jeśli limit atrakcji jest większy niż limit wycieczki
        rollback transaction;

        -- Rzuć błąd
        raiserror('The limit for the attraction exceeds the limit for the trip.', 16, 1);
    end
end;



-- Trigger 4 - sprawdza czy można dodać nową rezerwację, sprawdza czy jest wolne miejsce
create or alter trigger CheckReservationLimit
on Reservations
after insert, update
as
begin
    set nocount on;

    -- Sprawdź, czy operacja dotyczy tylko jednego wiersza
    if (select count(*) from inserted) > 1 or (select count(*) from deleted) > 1
    begin
        rollback transaction;
        raiserror('The trigger supports only single-row operations.', 16, 1);
        return;
    end

    declare @Trip_id int;
    declare @NewTrippersCount int;
    declare @MaxTrippersCount int;

    -- Pobierz Trip_id z wstawionego lub zaktualizowanego rekordu
    select @Trip_id = inserted.Trip_id
    from inserted;

    -- Oblicz sumę Count_of_trippers dla tej wycieczki z tabeli Reservations
    select @NewTrippersCount = sum(Count_of_trippers)
    from Reservations
    where Trip_id = @Trip_id

    -- Pobierz maksymalną liczbę uczestników dozwoloną dla tej wycieczki
    select @MaxTrippersCount = Limit
    from Trips
    where Trip_id = @Trip_id;

    -- Sprawdź, czy nowa liczba trippers nie przekracza maksymalnej liczby dozwolonej dla tej wycieczki
    if @NewTrippersCount > @MaxTrippersCount
    begin
        -- Wycofaj transakcję, jeśli limit został przekroczony
        rollback transaction;

        -- Rzuć błąd
        raiserror('The number of trippers exceeds the allowed limit for this trip.', 16, 1);
    end
end;


-- Trigger 5 - sprawdzenie czy dzień, w którym dokonujemy rezerwacji wycieczki
-- jest niemniejszy niż 7 dni od startu wycieczki
create or alter trigger CheckDateBeforeTrip
on Reservations
after insert, update
as
begin
    set nocount on;

    -- Sprawdź, czy operacja dotyczy tylko jednego wiersza
    if (select count(*) from inserted) > 1 or (select count(*) from deleted) > 1
    begin
        rollback transaction;
        raiserror('The trigger supports only single-row operations.', 16, 1);
        return;
    end

    declare @Trip_id int;
    declare @Trip_date date;
    declare @Current_date date = getdate();

    -- Pobierz Trip_id z wstawionego lub zaktualizowanego rekordu
    select @Trip_id = inserted.Trip_id
    from inserted;

    -- Pobierz datę wycieczki
    select @Trip_date = Date
    from Trips
    where Trip_id = @Trip_id

    -- Sprawdź, czy aktualna data jest nie mniejsza niż 7 dni przed datą wycieczki
    if datediff(day, @Current_date, @Trip_date) < 7
    begin
        -- Wycofaj transakcję, jeśli data jest nieodpowiednia
        rollback transaction;

        -- Rzuć błąd informacyjny
        raiserror('Cannot create reservation because it is less than 7 days before the trip.', 16, 1);
    end
end;


-- Trigger 6 - sprawdzenie czy data rozpoczęcia wycieczka dla podanej atrakcji,
-- jest niemniejsza niź 7 dni od startu wycieczki
create or alter trigger CheckAttractionDateBeforeTrip
on Attraction_Reservations
after insert, update
as
begin
    set nocount on;

    -- Sprawdź, czy operacja dotyczy tylko jednego wiersza
    if (select count(*) from inserted) > 1 or (select count(*) from deleted) > 1
    begin
        rollback transaction;
        raiserror('The trigger supports only single-row operations.', 16, 1);
        return;
    end

    declare @Trip_id int;
    declare @Trip_date date;
    declare @Current_date date = getdate();

    -- Pobierz Trip_id z wstawionego lub zaktualizowanego rekordu
    select @Trip_id = a.Trip_id
    from inserted i
    join Attractions a on i.Attraction_id = a.Attraction_id;

    -- Pobierz datę wycieczki
    select @Trip_date = Date
    from Trips
    where Trip_id = @Trip_id

    -- Sprawdź, czy aktualna data jest nie mniejsza niż 7 dni przed datą wycieczki
    if datediff(day, @Current_date, @Trip_date) < 7
    begin
        -- Wycofaj transakcję, jeśli data jest nieodpowiednia
        rollback transaction;

        -- Rzuć błąd informacyjny
        raiserror('Cannot create attraction reservation because it is less than 7 days before the trip.', 16, 1);
    end
end;


-- Trigger 7 - sprawdzenie czy dzień, w którym dokonujemy rezerwacji
-- jest dniem późniejszym niż data Start_reservation dla danej wycieczki
create or alter trigger CheckReservationStart
on Reservations
after insert, update
as
begin
    set nocount on;

    -- Sprawdź, czy operacja dotyczy tylko jednego wiersza
    if (select count(*) from inserted) > 1 or (select count(*) from deleted) > 1
    begin
        rollback transaction;
        raiserror('The trigger supports only single-row operations.', 16, 1);
        return;
    end

    declare @Trip_id int;
    declare @Start_reservation datetime;
    declare @Current_date datetime = getdate();

    -- Pobierz Trip_id z wstawionego lub zaktualizowanego rekordu
    select @Trip_id = inserted.Trip_id
    from inserted;

    -- Pobierz datę rozpoczęcia rezerwacji
    select @Start_reservation = Start_reservation
    from Trips
    where Trip_id = @Trip_id

    -- Sprawdź, czy można już rezerwować wycieczkę
    if @Current_date < @Start_reservation
    begin
        -- Wycofaj transakcję, jeśli rezerwacja jest niedozwolona
        rollback transaction;

        -- Rzuć błąd informacyjny
        raiserror('Cannot create reservation because the reservation period has not started yet.', 16, 1);
    end
end;


-- Trigger 8 - sprawdzenie czy można już dokonywać rezerwacji na podaną atrakcję dla danej wycieczki
create or alter trigger CheckAttractionReservationStart
on Attraction_Reservations
after insert, update
as
begin
    set nocount on;

    -- Sprawdź, czy operacja dotyczy tylko jednego wiersza
    if (select count(*) from inserted) > 1 or (select count(*) from deleted) > 1
    begin
        rollback transaction;
        raiserror('The trigger supports only single-row operations.', 16, 1);
        return;
    end

    declare @Trip_id int;
    declare @Start_reservation datetime;
    declare @Current_date datetime = getdate();

    -- Pobierz Trip_id z wstawionego lub zaktualizowanego rekordu
    select @Trip_id = a.Trip_id
    from inserted i
    join Attractions a on i.Attraction_id = a.Attraction_id;

    -- Pobierz datę rozpoczęcia rezerwacji
    select @Start_reservation = Start_reservation
    from Trips
    where Trip_id = @Trip_id

    -- Sprawdź, czy można już rezerwować wycieczkę
    if @Current_date < @Start_reservation
    begin
        -- Wycofaj transakcję, jeśli rezerwacja jest niedozwolona
        rollback transaction;

        -- Rzuć błąd informacyjny
        raiserror('Cannot create attraction reservation because the reservation period has not started yet.', 16, 1);
    end
end;


-- Trigger 9 - sprawdzenie czy można zmienić limit dla danej wycieczki
create or alter trigger CheckTripLimitUpdate
on Trips
after update
as
begin
    set nocount on;

    -- Sprawdź, czy operacja dotyczy tylko jednego wiersza
    if (select count(*) from inserted) > 1 or (select count(*) from deleted) > 1
    begin
        rollback transaction;
        raiserror('The trigger supports only single-row operations.', 16, 1);
        return;
    end

    declare @Trip_id int;
    declare @New_limit int;
    declare @Current_trippers int;

    -- pobierz wartości z aktualizowanego rekordu
    select @Trip_id = Trip_id, @New_limit = Limit
    from inserted;

    -- oblicz aktualną liczbę uczestników dla tej wycieczki
    select @Current_trippers = sum(count_of_trippers)
    from Reservations
    where Trip_id = @Trip_id

    -- sprawdź, czy nowy limit jest większy lub równy aktualnej liczbie uczestników
    if @New_Limit < @Current_trippers
    begin
        -- jeśli nowy limit jest mniejszy niż aktualna liczba uczestników, wycofaj operację
        raiserror('The new limit cannot be less than the current number of trippers.', 16, 1);
        rollback transaction;
        return;
    end
end;


-- Trigger 10 - sprawdzenie czy można zmienić limit dla danej atrakcji
create or alter trigger CheckAttractionLimitUpdate
on Attractions
after update
as
begin
    set nocount on;

    -- Sprawdź, czy operacja dotyczy tylko jednego wiersza
    if (select count(*) from inserted) > 1 or (select count(*) from deleted) > 1
    begin
        rollback transaction;
        raiserror('The trigger supports only single-row operations.', 16, 1);
        return;
    end

    declare @Attraction_id int;
    declare @New_limit int;
    declare @Current_trippers int;

    -- Pobierz wartości z aktualizowanego rekordu
    select @Attraction_id = Attraction_id, @New_limit = Limit
    from inserted;

    -- Oblicz aktualną liczbę uczestników dla tej atrakcji
    select @Current_trippers = SUM(Count_of_trippers)
    from Attraction_Reservations
    where Attraction_id = @Attraction_id;

    -- Sprawdź, czy nowy limit jest większy lub równy aktualnej liczbie uczestników
    if @New_limit < @Current_trippers
    begin
        -- Jeśli nowy limit jest mniejszy niż aktualna liczba uczestników, wycofaj operację
        raiserror('The new limit cannot be less than the current number of trippers.', 16, 1);
        rollback transaction;
        return;
    end
end;


-- Trigger 11 - sprawdzenie czy do wycieczki pozostało mniej niż 7 dni i czy dokonano wpłaty, w przeciwnym wypadku anulacja
CREATE OR ALTER TRIGGER CheckReservationDateAndPayment
ON Reservations
AFTER INSERT, UPDATE
AS
BEGIN

    -- Sprawdź, czy operacja dotyczy tylko jednego wiersza
    if (select count(*) from inserted) > 1 or (select count(*) from deleted) > 1
    begin
        rollback transaction;
        raiserror('The trigger supports only single-row operations.', 16, 1);
        return;
    end

    DECLARE @Reservation_id INT;
    DECLARE @Trip_id INT;
    DECLARE @TripDate DATE;

    DECLARE C CURSOR FOR
    SELECT Reservation_id, Trip_id FROM inserted;

    OPEN C;
    FETCH NEXT FROM C INTO @Reservation_id, @Trip_id;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @TripDate = Date FROM Trips WHERE Trip_id = @Trip_id;

        -- Sprawdzenie, czy data wycieczki jest mniej niż 7 dni od teraz
        IF DATEDIFF(DAY, GETDATE(), @TripDate) < 7
        BEGIN
            -- Sprawdzenie, czy istnieje wpłata za rezerwację
            IF dbo.CheckIfReservationIsPaid(@Reservation_id) = 0
            BEGIN
                -- Zaktualizowanie statusu rezerwacji na 'anulowana'
                UPDATE Reservations
                SET Cancelled = 1
                WHERE Reservation_id = @Reservation_id;
            END
        END

        FETCH NEXT FROM C INTO @Reservation_id, @Trip_id;
    END

    CLOSE C;
    DEALLOCATE C;
END;


-- Trigger 12 - sprawdzenie czy można dodać nowego uczestnika do wycieczki
create or alter trigger CheckNewTripper
on Trippers
after insert
as
begin
    set nocount on;

    -- Sprawdź, czy operacja dotyczy tylko jednego wiersza
    if (select count(*) from inserted) > 1
    begin
        rollback transaction;
        raiserror('The trigger supports only single-row operations.', 16, 1);
        return;
    end

    declare @Reservation_id int;
    declare @Trip_id int;
    declare @TripDate date;

    -- Pobierz Reservation_id z wstawionego rekordu
    select @Reservation_id = i.Reservation_id
    from inserted i;

    -- Pobierz Trip_id na podstawie Reservation_id z tabeli Reservations
    select @Trip_id = r.Trip_id
    from Reservations r
    where r.Reservation_id = @Reservation_id;

    -- Pobierz datę wycieczki na podstawie Trip_id
    select @TripDate = t.Date
    from Trips t
    where t.Trip_id = @Trip_id;

    -- Sprawdź, czy data wycieczki jest mniejsza niż 7 dni od daty systemowej
    if @TripDate < DATEADD(day, 7, CAST(GETDATE() as date))
    begin
        rollback transaction;
        raiserror('Cannot add a tripper for a trip that starts in less than 7 days.', 16, 1);
        return;
    end
end;


-- Trigger 13 - sprawdzenie czy można dodać nowego uczestnika do atrakcji
create or alter trigger CheckNewAttractionTripper
on Attractions_Trippers
after insert
as
begin
    set nocount on;

    -- Sprawdź, czy operacja dotyczy tylko jednego wiersza
    if (select count(*) from inserted) > 1
    begin
        rollback transaction;
        raiserror('The trigger supports only single-row operations.', 16, 1);
        return;
    end

    declare @AR_id int;
    declare @Reservation_id int;
    declare @Attraction_id int;
    declare @Trip_id int;
    declare @TripDate date;

    -- Pobierz AR_id z wstawionego rekordu
    select @AR_id = i.AR_id
    from inserted i;

    -- Pobierz Reservation_id i Attraction_id na podstawie AR_id z tabeli Attraction_Reservations
    select @Reservation_id = ar.Reservation_id, @Attraction_id = ar.Attraction_id
    from Attraction_Reservations ar
    where ar.AR_id = @AR_id;

    -- Pobierz Trip_id na podstawie Reservation_id z tabeli Reservations
    select @Trip_id = r.Trip_id
    from Reservations r
    where r.Reservation_id = @Reservation_id;

    -- Pobierz datę wycieczki na podstawie Trip_id
    select @TripDate = t.Date
    from Trips t
    where t.Trip_id = @Trip_id;

    -- Sprawdź, czy data wycieczki jest mniejsza niż 7 dni od daty systemowej
    if @TripDate < DATEADD(day, 7, CAST(GETDATE() as date))
    begin
        rollback transaction;
        raiserror('Cannot add a tripper to an attraction for a trip that starts in less than 7 days.', 16, 1);
        return;
    end
end;

-- Trigger 14 - sprawdzenie czy nieprzekroczono limitu uczestników atrakcji w rezerwacji
create or alter trigger CheckAttractionTripperCount
on Attractions_Trippers
after insert, update
as
begin
    set nocount on;

    -- Sprawdź, czy operacja dotyczy tylko jednego wiersza
    if (select count(*) from inserted) > 1 or (select count(*) from deleted) > 1
    begin
        rollback transaction;
        raiserror('The trigger supports only single-row operations.', 16, 1);
        return;
    end

    declare @AR_id int;
    declare @Reservation_id int;
    declare @CurrentAttractionTrippersCount int;
    declare @MaxAttractionTrippersCount int;
    declare @Cancelled bit;

    -- Pobierz AR_id z wstawionego lub zaktualizowanego rekordu
    select @AR_id = inserted.AR_id
    from inserted;

    -- Pobierz Reservation_id z tabeli Attraction_Reservations na podstawie AR_id
    select @Reservation_id = ar.Reservation_id
    from Attraction_Reservations ar
    where ar.AR_id = @AR_id;

    -- Pobierz bieżącą liczbę osób zarezerwowanych dla tej atrakcji
    select @CurrentAttractionTrippersCount = count(*)
    from Attractions_Trippers
    where AR_id = @AR_id;

    -- Pobierz maksymalną liczbę osób dozwoloną dla tej rezerwacji oraz status anulowania
    select @MaxAttractionTrippersCount = ar.Count_of_trippers, @Cancelled = r.Cancelled
    from Attraction_Reservations ar
    join Reservations r on ar.Reservation_id = r.Reservation_id
    where ar.AR_id = @AR_id;

    -- Sprawdź, czy liczba osób nie przekracza dozwolonego limitu lub rezerwacja jest anulowana
    if @CurrentAttractionTrippersCount > @MaxAttractionTrippersCount or @Cancelled = 1
    begin
        -- Wycofaj transakcję, jeśli limit został przekroczony lub rezerwacja jest anulowana
        rollback transaction;

        -- Rzuć błąd
        if @Cancelled = 1
        begin
            raiserror('Cannot add trippers to a cancelled reservation.', 16, 1);
        end
        else
        begin
            raiserror('The number of trippers exceeds the allowed limit for this attraction reservation.', 16, 1);
        end
    end
end;