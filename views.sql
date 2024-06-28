-- Widok 1 - oferty wycieczek w biurze turystycznym
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


-- Widok 2 - wartość wycieczek i atrakcji dla klientów
create or alter view Trips_value_for_clients as
select * from
(select
    c.Client_id,
    r.Reservation_id,
    r.Trip_id,
    r.Count_of_trippers*
    r.Price_per_person -p.Paid Trip_value
from Reservations r
join Clients c on c.Client_id=r.Client_id
left join Payments p on p.Reservation_id=r.Reservation_id
where Cancelled = 'false' and c.Client_id=15

select * from Trips_value_for_clients
where Client_id = 15

select * from Payments p
join Reservations r on r.Reservation_id=p.Reservation_id
where r.Client_id = 15;

exec add_new_payment
    @Paid = 2000,
    @Reservation_id = 6,
    @Method = 'B'

select r.Client_id, r.Trip_id, r.Reservation_id, r.Count_of_trippers * r.Price_per_person - SUM(p.Paid) from Reservations r
join Payments p on p.Reservation_id=r.Reservation_id
where r.Client_id = 15 and r.Cancelled = 'false'
group by r.Client_id, r.Trip_id, r.Reservation_id, r.Count_of_trippers, r.Price_per_person, p.Paid

select * from Reservations
where Client_id = 15 and Reservation_id = 6


-- Widok 3 - lista osób na poszczególne wycieczki
create or alter view Trippers_lists as
select Name as TripName, Firstname, Lastname
from People p
right join Trippers on p.Person_id=Trippers.Person_id
right join Reservations r on r.Reservation_id=Trippers.Reservation_id
left join Trips on Trips.Trip_id=r.Trip_id
'''
-- Widok 6 - stany kont klientów
select
    c.Client_id,
    COALESCE(pa.paid - COALESCE((r.Count_of_trippers * r.Price_per_person) +
    (at.Count_of_trippers * at.Price_per_person),0), 0)
    balance
from Reservations r
right join Clients c on c.Client_id=r.Client_id
left join AttractionReservations at on at.Reservation_id=r.Reservation_id
left join Payments pa on pa.Reservation_id=r.Reservation_id
'''
-- Widok 7 - wycieczki z wolnymi miejscami, które się nie odbyły
create or alter view Available_Trips as
select
    t.Trip_id,
    t.Name as TripName,
    ci.City as CityName,
    co.Country as CountryName,
    t.Date as TripDate,
    t.Price_per_person,
    t.Limit,
    t.Limit - ISNULL(SUM(r.Count_of_trippers), 0) as AvailableSpots
from Trips t
left join Cities ci on ci.City_id = t.City_id
left join Countries co on co.Country_id = ci.Country_id
left join Reservations r on r.Trip_id = t.Trip_id and r.Cancelled = 0
where t.Date > getdate()
group by t.Trip_id, t.Name, ci.City, co.Country, t.Date, t.Price_per_person, t.Limit
having t.Limit - ISNULL(SUM(r.Count_of_trippers), 0) != 0;

-- Widok 8 - szczegóły wszystkich płatności
create view Payment_Details_History as
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

-- Widok 9 - Lista klientów wraz z liczbą złożonych rezerwacji (łącznie z anulowanymi)

create or alter view Client_List as
select C.Client_id, 'FIRMA' as Client_Type,  Cm.Company_name as Nazwa, C.Phone, C.Email, Cm.NIP,
       count(R2.Reservation_id) as Liczba_rezerwacji
from Companies Cm
join dbo.Clients C on Cm.Client_id = C.Client_id
left join dbo.Reservations R2 on C.Client_id = R2.Client_id
group by C.Client_id, Cm.Company_name, C.Phone, C.Email, Cm.NIP
union
select C.Client_id, 'OSOBA FIZYCZNA' as Client_Type, P.Firstname + ' ' + P.Lastname, C.Phone, C.Email, null,
       count(R3.Reservation_id) as Liczba_rezerwacji
from Customers P
join dbo.Clients C on P.Client_id = C.Client_id
left join dbo.Reservations R3 on C.Client_id = R3.Client_id
group by C.Client_id, P.Firstname, P.Lastname, C.Phone, C.Email


select * from Client_List

-- Widok 10 - lista miast

create or alter view City_List as
select Cities.City_id , Cities.City, C.Country
from Cities
join dbo.Countries C on C.Country_id = Cities.Country_id

select * from City_List

-- Widok 11 - lista krajów
create or alter view Country_List as
select Country_id, Country
from dbo.Countries
order by Country

select * from Country_List
