-- funkcja 1 - wypisz szczegóły płatności w podanym zakresie dat
create function Payment_Details
(
    @start_date date,
    @end_date date
)
returns table
as
return
(
    select 
        pa.payment_id,
        pa.paid,
        pa.timestamp,
        pa.method,
        r.reservation_id,
        c.client_id,
        case 
            when cust.customer_id is not null then cust.firstname + ' ' + cust.lastname
            when comp.company_id is not null then comp.company_name
        end as clientname,
        t.trip_id,
        t.name as tripname
    from payments pa
    join reservations r on r.reservation_id = pa.reservation_id
    join clients c on c.client_id = r.client_id
    left join customers cust on cust.client_id = c.client_id
    left join companies comp on comp.client_id = c.client_id
    left join trips t on t.trip_id = r.trip_id
    where pa.timestamp between @start_date and @end_date
);

-- test działania
select * from Payment_Details('2024-05-01', '2024-05-20');
select * from Payments


-- Funkcja 2 - wypisz wycieczki w podanym zakresie dat
create function TripsWithRange
(
    @start_date date,
    @end_date date
)
returns table
as
return
(
    select 
        trip_id, 
        name, 
        city_id, 
        date, 
        price_per_person, 
        limit, 
        start_reservation
    from 
        trips
    where 
        date between @start_date and @end_date
);

-- test działania
select * from TripsWithRange('2024-06-01', '2024-06-30');



-- funkcja 3 - wypisz klientów, którzy zarezerwowali wybraną wycieczkę
create or alter function GetClientsForTrip
(
    @trip_id int
)
returns table
as
return
(
    select 
    c.client_id,
    case 
        when cust.customer_id is not null then cust.firstname + ' ' + cust.lastname
        when comp.company_id is not null then comp.company_name
    end as clientname,
    t.trip_id,
    t.name as tripname
from clients c
join reservations r on c.Client_id = r.Client_id
left join customers cust on cust.client_id = c.client_id
left join companies comp on comp.client_id = c.client_id
left join trips t on t.trip_id = r.trip_id
where r.trip_id = @trip_id
);

-- test działania
select * from GetClientsForTrip(1)


-- funkcja 4 - wypisz uczestników wybranej wycieczki
create or alter function GetParticipantsForTrip
(
    @trip_id int
)
returns table
as
return 
(
    select t.Tripper_id, p.Firstname, p.Lastname
    from Trippers t
    join People p on t.Person_id = p.Person_id
    where t.Reservation_id in (select Reservation_id from Reservations where Trip_id = @trip_id)
);

-- test działania
select * from GetParticipantsForTrip(3)

-- funkcja 5 - wypisz informacje o kliencie
create or alter function GetClientDetails(@Client_id int)
returns table
as
return
(select
    c.Client_id,
    case
        when cu.customer_id is not null then cu.firstname + ' ' + cu.lastname
        when co.company_id is not null then co.company_name
    end as Client_name,
    c.Email,
    c.Phone
from Clients c
left join Customers cu ON c.Client_id = cu.Client_id
left join Companies co ON c.Client_id = co.Client_id
where c.Client_id = @Client_id);

-- test działania
select * from GetClientDetails(1)

-- funkcja 6 - Wyszukiwanie atrakcji w danym mieście
create or alter function SearchAttractionsInCity (@CityID int)
returns table
as
return
(select
    a.Attraction_id,
    a.Name,
    c.City,
    a.Price_per_person,
    COALESCE(a.Limit - SUM(at.Count_of_trippers), a.Limit) Limit
from Attractions a
join Trips t on a.Trip_id = t.Trip_id
join Cities c on c.City_id=t.City_id
left join Attraction_Reservations at on at.Attraction_id=a.Attraction_id
where t.City_id = @CityID
group by a.Attraction_id, a.Name, c.City, a.Price_per_person, a.Limit);

-- test działania
select * from SearchAttractionsInCity(29)


-- funkcja 7 - wypisuje rezerwacje dla wybranego klienta
create or alter function GetReservationsForClient(@Client_id int)
returns table
as
return
(select
    r.Client_id,
    r.Reservation_id,
    r.Trip_id,
    t.Name AS Trip_name,
    r.Price_per_person,
    r.Count_of_trippers,
    r.Cancelled
from Reservations r
join Trips t ON r.Trip_id = t.Trip_id
where r.Client_id = @Client_id);

-- test działania
select * from GetReservationsForClient(5)

select * from Reservations
where Client_id = 1

-- funkcja 8 - wyszukanie dostępnych atrakcji dla podanej wycieczki
create or alter function GetAvailableAttractionsForTrip(@Trip_id int)
returns table
as
return
(select
    a.Attraction_id,
    a.Name,
    a.Price_per_person,
    a.Limit - COALESCE(SUM(ar.Count_of_trippers), 0) AvailableSpots
from Attractions a
left join Attraction_Reservations ar on a.Attraction_id = ar.Attraction_id
where a.Trip_id = @Trip_id
group by a.Attraction_id, a.Name, a.Price_per_person, a.Limit
);

select * from GetAvailableAttractionsForTrip(1)

select Attraction_id, Limit from Attractions
where Attraction_id = 2

-- funkcja 9 - wypisuje wszystkie wycieczki klienta, które zostały anulowane.
create or alter function GetCancelledTripsForClient(@Client_id int)
returns table
as
return
(select
    r.Reservation_id,
    r.Trip_id,
    t.Name TripName,
    r.Price_per_person,
    r.Count_of_trippers,
    r.Cancelled
from Reservations r
join Trips t on r.Trip_id = t.Trip_id
where r.Client_id = @Client_id and r.Cancelled = 1);

select * from GetCancelledTripsForClient(1)

-- funkcja 10 - lista uczestników danej atrakcji

CREATE FUNCTION GetParticipantsForAttraction(@attraction_id INT)
    RETURNS TABLE
        AS
        RETURN
        (
            SELECT P.Person_id ,P.Firstname, P.Lastname
            FROM People P
            JOIN Trippers T ON P.Person_id = T.Person_id
            JOIN dbo.Attractions_Trippers A on T.Tripper_id = A.Tripper_id
            JOIN dbo.Attraction_Reservations AR on A.AR_id = AR.AR_id
            JOIN dbo.Attractions AT on AR.Attraction_id = AT.Attraction_id
            WHERE AT.Attraction_id = @attraction_id
        );

        select * from GetParticipantsForAttraction(7);

