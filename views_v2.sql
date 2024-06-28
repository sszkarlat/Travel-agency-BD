-- Widok 1 - wszystkie wycieczki w biurze podróźy
create or alter view Trip_Offers as
select
    t.Trip_id,
    t.Name,
    ci.City,
    co.Country,
    t.Price_per_person,
    t.Limit,
    t.Date
from Trips t
join Cities ci on ci.City_id=t.City_id
join Countries co on co.Country_id=ci.Country_id;

-- select * from Trip_Offers


-- Widok 2 - koszty zarezerwowanych ofert dla każdego klienta
create or alter view Trips_value_for_clients as
select
    c.Client_id,
    r.Reservation_id,
    COALESCE((r.Count_of_trippers * r.Price_per_person) +
    (at.Count_of_trippers * at.Price_per_person),0)
    Trips_and_attractions_value
from Reservations r
left join Clients c on c.Client_id=r.Client_id
left join Attraction_Reservations at on at.Reservation_id=r.Reservation_id
where Cancelled = 'false';

-- select * from Trips_value_for_clients


-- Widok 3 - uczestnicy na poszczególne wycieczki
create or alter view Trippers_lists as
select
    Trips.Trip_id TripId,
    Trips.Name TripName,
    p.Firstname,
    p.Lastname
from Reservations r
join Trippers on Trippers.Reservation_id=r.Reservation_id
join People p on p.Person_id=Trippers.Person_id
join Trips on Trips.Trip_id=r.Trip_id;

-- select * from Trippers_lists


-- Widok 4 - Informacje o wycieczkach w biurze
-- kiedy rozpoczyna się rezerwacja, ile jest wolnych miejsc
create or alter view Available_Trips as
select
    t.Trip_id,
    t.Name as TripName,
    ci.City as CityName,
    co.Country as CountryName,
    t.Date as TripDate,
    t.Start_reservation,
    t.Price_per_person,
    t.Limit,
    t.Limit - ISNULL(SUM(r.Count_of_trippers), 0) as AvailableSpots
from Trips t
left join Cities ci on ci.City_id = t.City_id
left join Countries co on co.Country_id = ci.Country_id
left join Reservations r on r.Trip_id = t.Trip_id and r.Cancelled = 0
where t.Date > getdate() and t.Start_reservation < getdate()
group by t.Trip_id, t.Name, ci.City, co.Country, t.Date, t.Start_reservation, t.Price_per_person, t.Limit
having t.Limit - ISNULL(SUM(r.Count_of_trippers), 0) != 0;

-- select * from Available_Trips


-- Widok 5 - wszystkie dotychczasowe płatności
create or alter view Payment_Details_History as
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
left join trips t on t.trip_id = r.trip_id;

-- select * from Payment_Details_History


-- Widok 6 - dla każdego klienta ile dokonali rezerwacji
CREATE OR ALTER VIEW Client_List AS
SELECT
    C.Client_id,
    'COMPANY' AS Client_Type,
    Cm.Company_name AS Name,
    C.Phone,
    C.Email,
    Cm.NIP,
    COUNT(R2.Reservation_id) AS Count_of_active_reservations,
    COALESCE(
            (SELECT COUNT(*) FROM Reservations R WHERE R.Client_id = C.Client_id AND R.Cancelled = 1),
            0) AS Count_of_cancelled_reservations
FROM Companies Cm
JOIN Clients C ON Cm.Client_id = C.Client_id
LEFT JOIN Reservations R2 ON C.Client_id = R2.Client_id AND R2.Cancelled = 0
GROUP BY C.Client_id, Cm.Company_name, C.Phone, C.Email, Cm.NIP
UNION ALL
SELECT
    C.Client_id,
    'PERSON' AS Client_Type,
    P.Firstname + ' ' + P.Lastname AS Name,
    C.Phone,
    C.Email,
    NULL AS NIP,
    COUNT(R3.Reservation_id) AS Count_of_active_reservations,
    COALESCE(
            (SELECT COUNT(*) FROM Reservations R WHERE R.Client_id = C.Client_id AND R.Cancelled = 1),
            0) AS Count_of_cancelled_reservations
FROM Customers P
JOIN Clients C ON P.Client_id = C.Client_id
LEFT JOIN Reservations R3 ON C.Client_id = R3.Client_id AND R3.Cancelled = 0
GROUP BY C.Client_id, P.Firstname, P.Lastname, C.Phone, C.Email;

-- select * from Client_List


-- Widok 7 - miasta + państwa
create or alter view City_List as
select Cities.City_id , Cities.City, C.Country
from Cities
join dbo.Countries C on C.Country_id = Cities.Country_id

-- select * from City_List

-- Widok 8 - uczestnicy na poszczególne atrakcje
create or alter view Attractions_Lists as
Select A.Attraction_id, P.Firstname, P.Lastname, A.Name
From People P
inner join Trippers T on P.Person_id=T.Person_id
inner join Attractions_Trippers AT on AT.Tripper_id=T.Tripper_id
inner join Attraction_Reservations AR on AR.AR_id = AT.AR_id
inner join Attractions A on A.Attraction_id = AR.Attraction_id
