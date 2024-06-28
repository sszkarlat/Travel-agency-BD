-- Panel Sekretarki
-- 17. Sekretarka dostaje wpłatę dla rezerwacji 7, dodaje do bazy informacje o wpłacie
exec add_new_payment
    @Paid = 2550,
    @Reservation_id = 7,
    @Method = 'C'

-- 18. sekretarka dostaje wpłatę dla rezerwacji 8 (połowiczną), ponownie dodaje informacje
exec add_new_payment
    @Paid = 500,
    @Reservation_id = 8,
    @Method = 'C'

-- 19. Sekretarka może sprawdzić, jakie klient ma rezerwacje i czy je opłacił, żeby móc wysłać wiadomość z przypomnieniem w razie potrzeby:
select * from GetReservationsForClient(1);
-- 20. Sprawdzamy, czy poprawnie zarejestrowano wplatę
select dbo.CheckIfReservationIsPaid(7);
-- 21. Rezerwacja 8 wciąż nie jest w pełni opłacona
select dbo.CheckIfReservationIsPaid(8);

select * from Trips_value_for_clients