-- Trigger 1 - sprawdzanie czy liczba uczestników nie przekracza zadeklarowanej liczby z rezerwacji

CREATE TRIGGER CheckTrippersCount
    ON Trippers
    AFTER INSERT, UPDATE
    AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
                 JOIN (
            SELECT Reservation_id, COUNT(*) as TrippersCount
            FROM Trippers
            WHERE Reservation_id IN (SELECT Reservation_id FROM inserted)
            GROUP BY Reservation_id
        ) T ON i.Reservation_id = T.Reservation_id
                 JOIN Reservations R ON i.Reservation_id = R.Reservation_id
        WHERE T.TrippersCount > R.Count_of_trippers
    )
        BEGIN
            RAISERROR ('Liczba rekordów w tabeli Trippers nie może przekraczać wartości Count_of_trippers w tabeli Reservations.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;
END;

-- Trigger 2 - sprawdzanie czy liczba uczestników rezerwacji nie przekracza zadeklarowanej liczby z rezerwacji

    CREATE OR ALTER TRIGGER CheckAttractionTrippersCount
        ON Attractions_Trippers
        AFTER INSERT, UPDATE
        AS
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM inserted i
                     JOIN (
                SELECT AR_id, COUNT(*) as AttractionTrippersCount
                FROM Attractions_Trippers
                WHERE AR_id IN (SELECT AR_id FROM inserted)
                GROUP BY AR_id
            ) T ON i.AR_id = T.AR_id
                     JOIN Attraction_Reservations AR ON i.AR_id = AR.AR_id
            WHERE T.AttractionTrippersCount > AR.Count_of_trippers
        )
            BEGIN
                RAISERROR ('Liczba rekordów w tabeli Attraction_Trippers nie może przekraczać wartości Count_of_trippers w tabeli Attraction_Reservations.', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END;
    END;

-- Trigger 3 - sprwadzanie czy zadeklarowana ilość osób ze wszystkich rezerwacji jest mniejsza niż limit danej wycieczki

CREATE OR ALTER TRIGGER CheckTrippersLimit
    ON Reservations
    AFTER INSERT, UPDATE
    AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
                 JOIN (
            SELECT Trip_id, SUM(Count_of_trippers) as TotalTrippers
            FROM Reservations
            WHERE Trip_id IN (SELECT Trip_id FROM inserted)
            GROUP BY Trip_id
        ) R ON i.Trip_id = R.Trip_id
                 JOIN Trips T ON i.Trip_id = T.Trip_id
        WHERE R.TotalTrippers > T.limit
    )
        BEGIN
            RAISERROR ('Suma Count_of_trippers w tabeli Reservations nie może przekraczać wartości limit w powiązanym rekordzie z tabeli Trips.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;
END;

-- Trigger 4 - sprawdzanie  czy zadeklarowana ilość osób ze wszystkich rezerwacji atrakcji jest mniejsza niż limit danej atrakcji

CREATE OR ALTER TRIGGER CheckAttractionTrippersLimit
    ON Attraction_Reservations
    AFTER INSERT, UPDATE
    AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
                 JOIN (
            SELECT Attraction_id, SUM(Count_of_trippers) as TotalTrippers
            FROM Attraction_Reservations
            WHERE Attraction_id IN (SELECT Attraction_id FROM inserted)
            GROUP BY Attraction_id
        ) R ON i.Attraction_id = R.Attraction_id
                 JOIN Attractions A ON i.Attraction_id = A.Attraction_id
        WHERE R.TotalTrippers > A.limit
    )
        BEGIN
            RAISERROR ('Suma Count_of_trippers w tabeli Attraction_Reservations nie może przekraczać wartości limit w powiązanym rekordzie z tabeli Attractions.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;
END;


-- triger 5 - sprawdzenie czy można dodać nowego uczestnika wycieczki,
-- poprzez sprawdzenie czy rezerwacja jest aktualna (Cancelled = 0) oraz czy limit się zgadza.
create or alter trigger CheckTripperCount
on Trippers
after insert, update
as
begin
    set nocount on;

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

-- trigger 6 - sprawdza czy nowo dodawana atrakcja ma limit nie większy niż dana wycieczka
create or alter trigger CheckAttractionLimit
on Attractions
after insert, update
as
begin
    set nocount on;

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

-- trigger 7 - sprawdza czy można dodać nową rezerwację
create or alter trigger CheckReservationLimit
on Reservations
after insert, update
as
begin
    set nocount on;

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
      and Cancelled = 0;  -- Uwzględnij tylko aktywne rezerwacje

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

-- trigger 7 - sprawdza czy można zmienić limit dla danej wycieczki
create or alter trigger CheckTripLimitUpdate
on Trips
instead of update
as
begin
    set nocount on;

    declare @trip_id int;
    declare @new_limit int;
    declare @current_trippers int;

    -- Pobierz wartości z aktualizowanego rekordu
    select @trip_id = Trip_id, @new_limit = Limit
    from inserted;

    -- Oblicz aktualną liczbę uczestników dla tej wycieczki
    select @current_trippers = sum(Count_of_trippers)
    from Reservations
    where Trip_id = @trip_id
      and Cancelled = 0;  -- Uwzględnij tylko aktywne rezerwacje

    -- Sprawdź, czy nowy limit jest większy lub równy aktualnej liczbie uczestników
    if @new_limit < @current_trippers
    begin
        -- Jeśli nowy limit jest mniejszy niż aktualna liczba uczestników, wycofaj operację
        raiserror('The new limit cannot be less than the current number of trippers.', 16, 1);
        rollback transaction;
        return;
    end

    -- Jeśli nowy limit jest poprawny, wykonaj aktualizację
    update Trips
    set Limit = @new_limit
    where Trip_id = @trip_id;
end;


-- Trigger 8 - sprawdzenie czy do wycieczki pozostało mniej niż 7 dni i czy dokonano wpłaty, w przeciwnym wypadku anulacja
CREATE TRIGGER CheckReservationDateAndPayment
ON Reservations
AFTER INSERT, UPDATE
AS
BEGIN
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
            IF dbo.check_if_reservation_is_paid(@Reservation_id) = 0
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