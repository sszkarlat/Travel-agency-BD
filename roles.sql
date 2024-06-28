
-- ROLE: OWNER

CREATE ROLE travel_agency_owner;

ALTER ROLE db_datareader ADD MEMBER travel_agency_owner;

GRANT SELECT ON dbo.Trip_Offers TO travel_agency_owner;
GRANT SELECT ON dbo.Available_Trips TO travel_agency_owner;
GRANT SELECT ON dbo.Trips_value_for_clients TO travel_agency_owner;
GRANT SELECT ON dbo.Trippers_lists TO travel_agency_owner;
GRANT SELECT ON dbo.Payment_Details_History TO travel_agency_owner;
GRANT SELECT ON dbo.Client_List TO travel_agency_owner;
GRANT SELECT ON dbo.City_List TO travel_agency_owner;

GRANT SELECT ON dbo.Payment_Details TO travel_agency_owner;
GRANT SELECT ON dbo.SearchAttractionsInCity TO travel_agency_owner;
GRANT SELECT ON dbo.TripsWithRange TO travel_agency_owner;
GRANT SELECT ON dbo.GetClientsForTrip TO travel_agency_owner;
GRANT SELECT ON dbo.GetParticipantsForTrip TO travel_agency_owner;
GRANT SELECT ON dbo.GetParticipantsForAttraction TO travel_agency_owner;
GRANT SELECT ON dbo.GetClientDetails TO travel_agency_owner;
GRANT SELECT ON dbo.GetReservationsForClient TO travel_agency_owner;
GRANT SELECT ON dbo.GetAvailableAttractionsForTrip TO travel_agency_owner;
GRANT SELECT ON dbo.GetCancelledTripsForClient TO travel_agency_owner;

-- ROLE: ADMIN

CREATE ROLE travel_agency_admin;

ALTER ROLE db_datawriter ADD MEMBER travel_agency_admin;
ALTER ROLE db_datareader ADD MEMBER travel_agency_admin;

-- ROLE: TOUR_MANAGER

CREATE ROLE travel_agency_tour_manager;

-- Tabele

GRANT SELECT ON dbo.Clients TO travel_agency_tour_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Trips TO travel_agency_tour_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Cities TO travel_agency_tour_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Countries TO travel_agency_tour_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Attractions TO travel_agency_tour_manager;
GRANT SELECT ON dbo.Attraction_Reservations TO travel_agency_tour_manager;
GRANT SELECT ON dbo.Attractions_Trippers TO travel_agency_tour_manager;
GRANT SELECT ON dbo.Reservations TO travel_agency_tour_manager;
GRANT SELECT ON dbo.Trippers TO travel_agency_tour_manager;

-- Widoki

GRANT SELECT ON dbo.Trip_Offers TO travel_agency_tour_manager;
GRANT SELECT ON dbo.Available_Trips TO travel_agency_tour_manager;
GRANT SELECT ON dbo.City_List TO travel_agency_tour_manager;

-- Procedury

GRANT EXECUTE ON dbo.update_trip_price TO travel_agency_tour_manager;
GRANT EXECUTE ON dbo.update_trip_limit TO travel_agency_tour_manager;
GRANT EXECUTE ON dbo.update_attraction_price TO travel_agency_tour_manager;
GRANT EXECUTE ON dbo.update_attraction_limit TO travel_agency_tour_manager;
GRANT EXECUTE ON dbo.add_new_attraction TO travel_agency_tour_manager;
GRANT EXECUTE ON dbo.add_new_reservation TO travel_agency_tour_manager;

-- Funkcje

GRANT SELECT ON dbo.SearchAttractionsInCity TO travel_agency_employee;
GRANT SELECT ON dbo.TripsWithRange TO travel_agency_employee;
GRANT SELECT ON dbo.GetReservationsForClient TO travel_agency_employee;
GRANT SELECT ON dbo.GetAvailableAttractionsForTrip TO travel_agency_employee;


-- ROLE: EMPLOYEE

CREATE ROLE travel_agency_employee;

-- Tabele

GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Clients TO travel_agency_employee;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Companies TO travel_agency_employee;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Customers TO travel_agency_employee;
GRANT SELECT ON dbo.Trips TO travel_agency_employee;
GRANT SELECT ON dbo.Cities TO travel_agency_employee;
GRANT SELECT ON dbo.Countries TO travel_agency_employee;
GRANT SELECT ON dbo.Attractions TO travel_agency_employee;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Attraction_Reservations TO travel_agency_employee;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Attractions_Trippers TO travel_agency_employee;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Reservations TO travel_agency_employee;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.People TO travel_agency_employee;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Payments TO travel_agency_employee;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Trippers TO travel_agency_employee;

-- Widoki

GRANT SELECT ON dbo.Trip_Offers TO travel_agency_employee;
GRANT SELECT ON dbo.Available_Trips TO travel_agency_employee;
GRANT SELECT ON dbo.Trips_value_for_clients TO travel_agency_employee;
GRANT SELECT ON dbo.Trippers_lists TO travel_agency_employee;
GRANT SELECT ON dbo.Payment_Details_History TO travel_agency_employee;
GRANT SELECT ON dbo.Client_List TO travel_agency_employee;
GRANT SELECT ON dbo.City_List TO travel_agency_employee;

-- Procedury

GRANT EXECUTE ON dbo.add_new_client TO travel_agency_employee;
GRANT EXECUTE ON dbo.add_new_reservation TO travel_agency_employee;
GRANT EXECUTE ON dbo.add_new_attraction_reservation TO travel_agency_employee;
GRANT EXECUTE ON dbo.add_new_payment TO travel_agency_employee;
GRANT EXECUTE ON dbo.add_new_tripper TO travel_agency_employee;
GRANT EXECUTE ON dbo.cancel_reservation TO travel_agency_employee;
GRANT EXECUTE ON dbo.return_reservation TO travel_agency_employee;

-- Funkcje

GRANT SELECT ON dbo.Payment_Details TO travel_agency_employee;
GRANT SELECT ON dbo.SearchAttractionsInCity TO travel_agency_employee;
GRANT SELECT ON dbo.TripsWithRange TO travel_agency_employee;
GRANT SELECT ON dbo.GetClientsForTrip TO travel_agency_employee;
GRANT SELECT ON dbo.GetParticipantsForTrip TO travel_agency_employee;
GRANT SELECT ON dbo.GetParticipantsForAttraction TO travel_agency_employee;
GRANT SELECT ON dbo.GetClientDetails TO travel_agency_employee;
GRANT SELECT ON dbo.GetReservationsForClient TO travel_agency_employee;
GRANT SELECT ON dbo.GetAvailableAttractionsForTrip TO travel_agency_employee;
GRANT SELECT ON dbo.GetCancelledTripsForClient TO travel_agency_employee;

-- ROLE: CLIENT

CREATE ROLE travel_agency_client;

GRANT SELECT ON dbo.Available_Trips TO travel_agency_client;
