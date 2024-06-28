-- Z roli klienta do pracownia
ALTER ROLE travel_agency_employee ADD MEMBER u_pczernec;
ALTER ROLE travel_agency_client DROP MEMBER u_pczernec;

-- Z roli pracownika do managera wycieczek
ALTER ROLE travel_agency_tour_manager ADD MEMBER u_pczernec;
ALTER ROLE travel_agency_employee DROP MEMBER u_pczernec;

-- Z roli managera wycieczek do właściciela biura
ALTER ROLE travel_agency_owner ADD MEMBER u_pczernec;
ALTER ROLE travel_agency_tour_manager DROP MEMBER u_pczernec;

-- Z roli właściciela biura do managera
ALTER ROLE travel_agency_client ADD MEMBER u_pczernec;
ALTER ROLE travel_agency_tour_manager DROP MEMBER u_pczernec;

-- Sprawdzenie ról
SELECT
    dp.name AS RoleName
FROM
    sys.database_role_members drm
        JOIN
    sys.database_principals dp ON drm.role_principal_id = dp.principal_id
        JOIN
    sys.database_principals du ON drm.member_principal_id = du.principal_id
WHERE
    du.name = 'u_pczernec';
