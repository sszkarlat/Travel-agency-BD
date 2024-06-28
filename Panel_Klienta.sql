-- 4.Przeglądanie dostępnych wycieczek
SELECT * FROM Available_Trips;

-- 5. Przejrzyj dostępne atrakcje dla danej wycieczki
select * from GetAvailableAttractionsForTrip(10)

-- 6. Klient decyduje się na rezerwację wycieczki
exec add_new_reservation
    @Trip_id = 10,
    @Client_id = 1,
    @Count_of_trippers = 10

-- 7. Klient decyduje się na rezerwację atrakcji, ale zrobił pomyłkę i wybrał podał więcej uczestników niż ma
exec add_new_attraction_reservation
    @Reservation_id = 7,
    @Attraction_id = 26,
    @Count_of_trippers = 20

-- 8. Klient decyduje się na rezerwację atrakcji = działa
exec add_new_attraction_reservation
    @Reservation_id = 7,
    @Attraction_id = 26,
    @Count_of_trippers = 5

-- 9. Klient dodaje swojego pierwszego uczestnika nowokupionej wycieczki
exec add_new_tripper
    @Reservation_id = 7,
    @Firstname = 'Adaś',
    @Lastname = 'Niezgódka',
    @Email = 'adasniezgodka@akademia.kleksa',
    @Phone = '244466666'

-- 10. Klient dodaje swojego drugiego uczestnika, który przy okazji pójdzie na atrakcję
exec add_new_tripper
    @Reservation_id = 7,
    @Firstname = 'Piotruś',
    @Lastname = 'Podróżnik',
    @Email = 'piotrek@pan.pl',
    @Phone = '123123123'


exec add_new_attraction_tripper
    @Tripper_id = 12,
    @Attraction_id = 26

-- Gdyby klient podał atrakcję niezgodną z wycieczką na którą idzie uczestnik, procedura nie powiedzie się
exec add_new_attraction_tripper
    @Tripper_id = 12,
    @Attraction_id = 20

-- 12. Klient rezerwuje jeszcze 5 miejsc na wycieczkę (po wyższej cenie)

exec add_new_reservation
    @Trip_id = 10,
    @Client_id = 1,
    @Count_of_trippers = 5

-- 13. Klient sprawdza, ile wynosi cena jego wycieczek:
select dbo.CalculateTotalPrice(7);
-- 10*150+50*5 = 1750
select dbo.CalculateTotalPrice(8);
-- select 5*200 = 1000

