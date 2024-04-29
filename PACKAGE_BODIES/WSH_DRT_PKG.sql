--------------------------------------------------------
--  DDL for Package Body WSH_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DRT_PKG" AS
  /* $Header: WSHDRTPB.pls 120.0.12010000.10 2018/05/08 12:52:21 sunilku noship $ */
  l_package VARCHAR2(33) DEFAULT 'WSH_DRT_PKG. ';
  --
  --- Implement log writer
  --
PROCEDURE write_log(
    message IN VARCHAR2 ,
    stage   IN VARCHAR2)
IS
BEGIN
  IF fnd_log.g_current_runtime_level<=fnd_log.level_procedure THEN
    fnd_log.string(fnd_log.level_procedure,message,stage);
  END IF;
END write_log;

------------------------------------------------------------------------------
-- Description:
-- Procedure: WSH_TCA_POST
-- Post processing function for person type : TCA
-- This function masks ui_location_code of the party in wsh_locations table
------------------------------------------------------------------------------
PROCEDURE wsh_tca_post
  (p_person_id IN	NUMBER)
 IS
  --
  -- Declare cursors and local variables
  --
   l_proc							varchar2(72) :='WSH_TCA_POST';
BEGIN

  write_log('Entering: '||l_proc,' 10');
  write_log('p_person_id: '||p_person_id,' 20');

  UPDATE  wsh_locations wl
  SET     ui_location_code = substrb ((wl.location_code
                                            || ' : '
                                            || wl.address1
                                            || '-'
                                            || wl.address2
                                            || '-'
                                            || wl.city
                                            || '-'
                                            || nvl (wl.state
                                                   ,wl.province)
                                            || '-'
                                            || wl.postal_code
                                            || '-'
                                            || wl.country)
                                           ,1
                                           ,500)
  WHERE   wl.source_location_id IN
        (
        SELECT  location_id
        FROM    hz_party_sites
        WHERE   party_id = p_person_id
        UNION
        SELECT  location_id
        FROM    hz_party_sites hps2
        WHERE   EXISTS  (
                        SELECT  1
                        FROM    hz_relationships hr
                        WHERE   hr.subject_id = p_person_id
                        AND     hps2.party_id = hr.party_id
                        AND     hr.subject_table_name = 'HZ_PARTIES'
                        AND     hr.subject_type = 'PERSON'
                        )

        )
  AND wl.location_source_code = 'HZ';

  write_log('Leaving: '||l_proc,' 30');

 EXCEPTION

  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occured
    --
    write_log('OTHERS : '||SQLCODE||'-'||SQLERRM,' 40');
    write_log('Leaving: OTHERS : '||l_proc,' 50');
    RAISE;

END wsh_tca_post;

--
--- Procedure: WSH_TCA_DRC
--- For a given TCA Party, procedure subject it to pass the validation representing applicable constraint.
--- If the Party comes out of validation process successfully, then it can be MASKed otherwise error will be raised.
---
PROCEDURE wsh_tca_drc(
    person_id IN NUMBER ,
    result_tbl OUT NOCOPY  per_drt_pkg.result_tbl_type)
IS
  l_proc      VARCHAR2(72) := l_package|| 'WSH_TCA_DRC';
  p_person_id NUMBER(20);
  l_count     NUMBER;
  l_temp      VARCHAR2(20);
BEGIN
  -- .....
  write_log ('Entering:'|| l_proc,' 10');
  p_person_id := person_id;
  write_log ('p_person_id: '|| p_person_id,' 20');
  --
  ---- Check DRC rule# 1
  --
  BEGIN
    --
    --- Check whether delivery detail existis in the interface table for this customer
    --
    BEGIN
    l_count := 0;
    SELECT 1
    INTO l_count
    FROM wsh_del_details_interface wddi
    WHERE EXISTS
      (SELECT 'X'
      FROM hz_parties hp,
        hz_cust_accounts acc
      WHERE hp.party_id      = p_person_id
      AND acc.party_id       = hp.party_id
      AND hp.party_type      = 'PERSON'
      AND wddi.customer_id   = acc.cust_account_id
      )
    AND rownum = 1;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
     l_count := 0;
    END;

    --
    --- If record exists in interface table, then Customer person is referenced. Should not delete. Raise error.
    --
    IF l_count > 0 THEN
         per_drt_pkg.add_to_results
                (person_id   => p_person_id
                ,entity_type => 'TCA'
                ,status      => 'E'
                ,msgcode     => 'WSH_DRC_CST_INTERFACE_EXISTS'
                ,msgaplid    => 665
                ,result_tbl  => result_tbl );
    END IF;

    write_log ('p_person_id: '|| p_person_id,' 30');

   IF l_count = 0 THEN
    BEGIN
     SELECT 1
     INTO l_count
     FROM wsh_del_details_interface wddi
     WHERE EXISTS
       (SELECT 'X'
       FROM hz_parties hp,
         hz_cust_accounts acc
       WHERE hp.party_id      = p_person_id
       AND acc.party_id       = hp.party_id
       AND hp.party_type      = 'PERSON'
       AND wddi.customer_name = hp.party_name
       )
     AND rownum = 1;
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
      l_count := 0;
     END;
   END IF;

    --
    --- If record exists in interface table, then Customer person is referenced. Should not delete. Raise error.
    --
    IF l_count > 0 THEN
         per_drt_pkg.add_to_results
                (person_id   => p_person_id
                ,entity_type => 'TCA'
                ,status      => 'E'
                ,msgcode     => 'WSH_DRC_CST_INTERFACE_EXISTS'
                ,msgaplid    => 665
                ,result_tbl  => result_tbl );
    END IF;

    write_log ('p_person_id: '|| p_person_id,' 30A');

    --- Check whether delivery existis in the interface table for this customer

	IF l_count = 0 THEN
    BEGIN
    SELECT 1
    INTO l_count
    FROM wsh_new_del_interface wndi
    WHERE EXISTS
      (SELECT 'X'
      FROM hz_parties hp,
        hz_cust_accounts acc
      WHERE hp.party_id      = p_person_id
      AND acc.party_id       = hp.party_id
      AND hp.party_type      = 'PERSON'
      AND wndi.customer_id   = acc.cust_account_id
      )
    AND rownum = 1;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
     l_count := 0;
    END;
	--
    --- If record exists in interface table, then Customer person is referenced. Should not delete. Raise error.
    --
    IF l_count > 0 THEN
         per_drt_pkg.add_to_results
                (person_id   => p_person_id
                ,entity_type => 'TCA'
                ,status      => 'E'
                ,msgcode     => 'WSH_DRC_CST_INTERFACE_EXISTS'
                ,msgaplid    => 665
                ,result_tbl  => result_tbl );
    END IF;
    write_log ('p_person_id: '|| p_person_id,' 40');
	END IF;
    --
	IF l_count = 0 THEN
    BEGIN
    SELECT 1
    INTO l_count
    FROM wsh_new_del_interface wndi
    WHERE EXISTS
      (SELECT 'X'
      FROM hz_parties hp,
        hz_cust_accounts acc
      WHERE hp.party_id      = p_person_id
      AND acc.party_id       = hp.party_id
      AND hp.party_type      = 'PERSON'
      AND wndi.customer_name = hp.party_name
      )
    AND rownum = 1;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
     l_count := 0;
    END;
	--
    --- If record exists in interface table, then Customer person is referenced. Should not delete. Raise error.
    --
    IF l_count > 0 THEN
         per_drt_pkg.add_to_results
                (person_id   => p_person_id
                ,entity_type => 'TCA'
                ,status      => 'E'
                ,msgcode     => 'WSH_DRC_CST_INTERFACE_EXISTS'
                ,msgaplid    => 665
                ,result_tbl  => result_tbl );
    END IF;
    write_log ('p_person_id: '|| p_person_id,' 40A');
	END IF;
    --- Check whether delivery existis in the interface table for this Invoice To Customer
   IF l_count = 0 THEN
    BEGIN
    SELECT 1
    INTO l_count
    FROM wsh_new_del_interface wndi
    WHERE EXISTS
      (SELECT 'X'
      FROM hz_parties hp,
        hz_cust_accounts acc
      WHERE hp.party_id                 = p_person_id
      AND acc.party_id                  = hp.party_id
      AND hp.party_type                 = 'PERSON'
      AND wndi.invoice_to_customer_id   = acc.cust_account_id
      )
    AND rownum = 1;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
     l_count := 0;
    END;
    --
    --- If record exists in interface table, then Customer person is referenced. Should not delete. Raise error.
    --
    IF l_count > 0 THEN
         per_drt_pkg.add_to_results
                (person_id   => p_person_id
                ,entity_type => 'TCA'
                ,status      => 'E'
                ,msgcode     => 'WSH_DRC_CST_INTERFACE_EXISTS'
                ,msgaplid    => 665
                ,result_tbl  => result_tbl );
    END IF;
    write_log ('p_person_id: '|| p_person_id,' 50');
	END IF;
    --
    IF l_count = 0 THEN
    BEGIN
    SELECT 1
    INTO l_count
    FROM wsh_new_del_interface wndi
    WHERE EXISTS
      (SELECT 'X'
      FROM hz_parties hp,
        hz_cust_accounts acc
      WHERE hp.party_id                 = p_person_id
      AND acc.party_id                  = hp.party_id
      AND hp.party_type                 = 'PERSON'
      AND wndi.invoice_to_customer_name = hp.party_name
      )
    AND rownum = 1;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
     l_count := 0;
    END;
    --
    --- If record exists in interface table, then Customer person is referenced. Should not delete. Raise error.
    --
    IF l_count > 0 THEN
         per_drt_pkg.add_to_results
                (person_id   => p_person_id
                ,entity_type => 'TCA'
                ,status      => 'E'
                ,msgcode     => 'WSH_DRC_CST_INTERFACE_EXISTS'
                ,msgaplid    => 665
                ,result_tbl  => result_tbl );
    END IF;
    write_log ('p_person_id: '|| p_person_id,' 50A');
	END IF;
    --- Check whether delivery existis in the interface table for this Deliver To Customer
   IF l_count = 0 THEN
    BEGIN
    SELECT 1
    INTO l_count
    FROM wsh_new_del_interface wndi
    WHERE EXISTS
      (SELECT 'X'
      FROM hz_parties hp,
        hz_cust_accounts acc
      WHERE hp.party_id                 = p_person_id
      AND acc.party_id                  = hp.party_id
      AND hp.party_type                 = 'PERSON'
      AND wndi.deliver_to_customer_id   = acc.cust_account_id
      )
    AND rownum = 1;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
     l_count := 0;
    END;
    --
    --- If record exists in interface table, then Customer person is referenced. Should not delete. Raise error.
    --
    IF l_count > 0 THEN
         per_drt_pkg.add_to_results
                (person_id   => p_person_id
                ,entity_type => 'TCA'
                ,status      => 'E'
                ,msgcode     => 'WSH_DRC_CST_INTERFACE_EXISTS'
                ,msgaplid    => 665
                ,result_tbl  => result_tbl );
    END IF;
    write_log ('p_person_id: '|| p_person_id,' 60');
	END IF;
    --
    IF l_count = 0 THEN
    BEGIN
    SELECT 1
    INTO l_count
    FROM wsh_new_del_interface wndi
    WHERE EXISTS
      (SELECT 'X'
      FROM hz_parties hp,
        hz_cust_accounts acc
      WHERE hp.party_id                 = p_person_id
      AND acc.party_id                  = hp.party_id
      AND hp.party_type                 = 'PERSON'
      AND wndi.deliver_to_customer_name = hp.party_name
      )
    AND rownum = 1;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
     l_count := 0;
    END;
    --
    --- If record exists in interface table, then Customer person is referenced. Should not delete. Raise error.
    --
    IF l_count > 0 THEN
         per_drt_pkg.add_to_results
                (person_id   => p_person_id
                ,entity_type => 'TCA'
                ,status      => 'E'
                ,msgcode     => 'WSH_DRC_CST_INTERFACE_EXISTS'
                ,msgaplid    => 665
                ,result_tbl  => result_tbl );
    END IF;
    write_log ('p_person_id: '|| p_person_id,' 60A');
	END IF;
    --- Check whether delivery existis in the interface table for this Ship To Customer
  IF l_count = 0 THEN
    BEGIN
    SELECT 1
    INTO l_count
    FROM wsh_new_del_interface wndi
    WHERE EXISTS
      (SELECT 'X'
      FROM hz_parties hp,
        hz_cust_accounts acc
      WHERE hp.party_id              = p_person_id
      AND acc.party_id               = hp.party_id
      AND hp.party_type              = 'PERSON'
      AND wndi.ship_to_customer_id = acc.cust_account_id
      )
    AND rownum = 1;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
     l_count := 0;
    END;
    --
    --- If record exists in interface table, then Customer person is referenced. Should not delete. Raise error.
    --
    IF l_count > 0 THEN
         per_drt_pkg.add_to_results
                (person_id   => p_person_id
                ,entity_type => 'TCA'
                ,status      => 'E'
                ,msgcode     => 'WSH_DRC_CST_INTERFACE_EXISTS'
                ,msgaplid    => 665
                ,result_tbl  => result_tbl );
    END IF;
    write_log ('p_person_id: '|| p_person_id,' 70');
	END IF;
   --
    IF l_count = 0 THEN
    BEGIN
    SELECT 1
    INTO l_count
    FROM wsh_new_del_interface wndi
    WHERE EXISTS
      (SELECT 'X'
      FROM hz_parties hp,
        hz_cust_accounts acc
      WHERE hp.party_id              = p_person_id
      AND acc.party_id               = hp.party_id
      AND hp.party_type              = 'PERSON'
      AND wndi.ship_to_customer_name = hp.party_name
      )
    AND rownum = 1;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
     l_count := 0;
    END;
    --
    --- If record exists in interface table, then Customer person is referenced. Should not delete. Raise error.
    --
    IF l_count > 0 THEN
         per_drt_pkg.add_to_results
                (person_id   => p_person_id
                ,entity_type => 'TCA'
                ,status      => 'E'
                ,msgcode     => 'WSH_DRC_CST_INTERFACE_EXISTS'
                ,msgaplid    => 665
                ,result_tbl  => result_tbl );
    END IF;
    write_log ('p_person_id: '|| p_person_id,' 70A');
	END IF;
    --- Check whether delivery existis in the interface table for this SHIP_TO_CONTACT_NAME
    --
    BEGIN
    l_count := 0;
    SELECT 1
    INTO l_count
    FROM wsh_new_del_interface wndi
    WHERE EXISTS
      (SELECT 'X'
      FROM hz_cust_account_roles acct_role ,
        hz_parties party ,
        hz_cust_accounts acct ,
        hz_relationships rel ,
        hz_org_contacts org_cont ,
        hz_parties rel_party
      WHERE acct_role.party_id           = rel.party_id
      AND acct_role.role_type            = 'CONTACT'
      AND org_cont.party_relationship_id = rel.relationship_id
      AND rel.subject_table_name         = 'HZ_PARTIES'
      AND rel.object_table_name          = 'HZ_PARTIES'
      AND rel.subject_id                 = party.party_id
      AND rel.party_id                   = rel_party.party_id
      AND rel.object_id                  = acct.party_id
      AND acct.cust_account_id           = acct_role.cust_account_id
      AND rel.directional_flag           = 'F'
      AND wndi.ship_to_contact_id        = acct_role.cust_account_role_id
      AND party.party_id = p_person_id
      )
    AND rownum = 1;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
     l_count := 0;
    END;
    --
    --- If record exists in interface table, then Customer person is referenced. Should not delete. Raise error.
    --
    IF l_count > 0 THEN
         per_drt_pkg.add_to_results
                (person_id   => p_person_id
                ,entity_type => 'TCA'
                ,status      => 'E'
                ,msgcode     => 'WSH_DRC_CONTACT_IFACE_EXISTS'
                ,msgaplid    => 665
                ,result_tbl  => result_tbl );
    END IF;
    write_log ('p_person_id: '|| p_person_id,' 80');

	IF l_count = 0 THEN
    BEGIN
    SELECT 1
    INTO l_count
    FROM wsh_new_del_interface wndi
    WHERE EXISTS
      (SELECT 'X'
      FROM hz_cust_account_roles acct_role ,
        hz_parties party ,
        hz_cust_accounts acct ,
        hz_relationships rel ,
        hz_org_contacts org_cont ,
        hz_parties rel_party
      WHERE acct_role.party_id           = rel.party_id
      AND acct_role.role_type            = 'CONTACT'
      AND org_cont.party_relationship_id = rel.relationship_id
      AND rel.subject_table_name         = 'HZ_PARTIES'
      AND rel.object_table_name          = 'HZ_PARTIES'
      AND rel.subject_id                 = party.party_id
      AND rel.party_id                   = rel_party.party_id
      AND rel.object_id                  = acct.party_id
      AND acct.cust_account_id           = acct_role.cust_account_id
      AND rel.directional_flag           = 'F'
      AND wndi.ship_to_contact_name      = party.person_last_name
        || ', '
        || party.person_first_name
      AND party.party_id = p_person_id
      )
    AND rownum = 1;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
     l_count := 0;
    END;
    --
    --- If record exists in interface table, then Customer person is referenced. Should not delete. Raise error.
    --
    IF l_count > 0 THEN
         per_drt_pkg.add_to_results
                (person_id   => p_person_id
                ,entity_type => 'TCA'
                ,status      => 'E'
                ,msgcode     => 'WSH_DRC_CONTACT_IFACE_EXISTS'
                ,msgaplid    => 665
                ,result_tbl  => result_tbl );
    END IF;
    write_log ('p_person_id: '|| p_person_id,' 80A');
	END IF;

    --- Check whether delivery existis in the interface table for this INVOICE_TO_CONTACT_NAME
    --
	IF l_count = 0 THEN

    BEGIN
    SELECT 1
    INTO l_count
    FROM wsh_new_del_interface wndi
    WHERE EXISTS
      (SELECT 'X'
      FROM hz_cust_account_roles acct_role ,
        hz_parties party ,
        hz_cust_accounts acct ,
        hz_relationships rel ,
        hz_org_contacts org_cont ,
        hz_parties rel_party
      WHERE acct_role.party_id           = rel.party_id
      AND acct_role.role_type            = 'CONTACT'
      AND org_cont.party_relationship_id = rel.relationship_id
      AND rel.subject_table_name         = 'HZ_PARTIES'
      AND rel.object_table_name          = 'HZ_PARTIES'
      AND rel.subject_id                 = party.party_id
      AND rel.party_id                   = rel_party.party_id
      AND rel.object_id                  = acct.party_id
      AND acct.cust_account_id           = acct_role.cust_account_id
      AND rel.directional_flag           = 'F'
      AND wndi.invoice_to_contact_id     = acct_role.cust_account_role_id
      AND party.party_id = p_person_id
      )
    AND rownum = 1;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
     l_count := 0;
    END;
    --
    --- If record exists in interface table, then Customer person is referenced. Should not delete. Raise error.
    --
    IF l_count > 0 THEN
         per_drt_pkg.add_to_results
                (person_id   => p_person_id
                ,entity_type => 'TCA'
                ,status      => 'E'
                ,msgcode     => 'WSH_DRC_CONTACT_IFACE_EXISTS'
                ,msgaplid    => 665
                ,result_tbl  => result_tbl );
    END IF;
    write_log ('p_person_id: '|| p_person_id,' 90');
	END IF;

	IF l_count = 0 THEN

    BEGIN
    SELECT 1
    INTO l_count
    FROM wsh_new_del_interface wndi
    WHERE EXISTS
      (SELECT 'X'
      FROM hz_cust_account_roles acct_role ,
        hz_parties party ,
        hz_cust_accounts acct ,
        hz_relationships rel ,
        hz_org_contacts org_cont ,
        hz_parties rel_party
      WHERE acct_role.party_id           = rel.party_id
      AND acct_role.role_type            = 'CONTACT'
      AND org_cont.party_relationship_id = rel.relationship_id
      AND rel.subject_table_name         = 'HZ_PARTIES'
      AND rel.object_table_name          = 'HZ_PARTIES'
      AND rel.subject_id                 = party.party_id
      AND rel.party_id                   = rel_party.party_id
      AND rel.object_id                  = acct.party_id
      AND acct.cust_account_id           = acct_role.cust_account_id
      AND rel.directional_flag           = 'F'
      AND wndi.invoice_to_contact_name   = party.person_last_name
        || ', '
        || party.person_first_name
      AND party.party_id = p_person_id
      )
    AND rownum = 1;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
     l_count := 0;
    END;
    --
    --- If record exists in interface table, then Customer person is referenced. Should not delete. Raise error.
    --
    IF l_count > 0 THEN
         per_drt_pkg.add_to_results
                (person_id   => p_person_id
                ,entity_type => 'TCA'
                ,status      => 'E'
                ,msgcode     => 'WSH_DRC_CONTACT_IFACE_EXISTS'
                ,msgaplid    => 665
                ,result_tbl  => result_tbl );
    END IF;
    write_log ('p_person_id: '|| p_person_id,' 90A');
	END IF;

    --- Check whether delivery existis in the interface table for this DELIVER_TO_CONTACT_NAME

  IF l_count = 0 THEN

    BEGIN
    SELECT 1
    INTO l_count
    FROM wsh_new_del_interface wndi
    WHERE EXISTS
      (SELECT 'X'
      FROM hz_cust_account_roles acct_role ,
        hz_parties party ,
        hz_cust_accounts acct ,
        hz_relationships rel ,
        hz_org_contacts org_cont ,
        hz_parties rel_party
      WHERE acct_role.party_id           = rel.party_id
      AND acct_role.role_type            = 'CONTACT'
      AND org_cont.party_relationship_id = rel.relationship_id
      AND rel.subject_table_name         = 'HZ_PARTIES'
      AND rel.object_table_name          = 'HZ_PARTIES'
      AND rel.subject_id                 = party.party_id
      AND rel.party_id                   = rel_party.party_id
      AND rel.object_id                  = acct.party_id
      AND acct.cust_account_id           = acct_role.cust_account_id
      AND rel.directional_flag           = 'F'
      AND wndi.deliver_to_contact_id     = acct_role.cust_account_role_id
      AND party.party_id = p_person_id
      )
    AND rownum = 1;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
     l_count := 0;
    END;
    --
    --- If record exists in interface table, then Customer person is referenced. Should not delete. Raise error.
    --
    IF l_count > 0 THEN
         per_drt_pkg.add_to_results
                (person_id   => p_person_id
                ,entity_type => 'TCA'
                ,status      => 'E'
                ,msgcode     => 'WSH_DRC_CONTACT_IFACE_EXISTS'
                ,msgaplid    => 665
                ,result_tbl  => result_tbl );
    END IF;
    write_log ('p_person_id: '|| p_person_id,' 100');
	END IF;
    --
	IF l_count = 0 THEN

    BEGIN
    SELECT 1
    INTO l_count
    FROM wsh_new_del_interface wndi
    WHERE EXISTS
      (SELECT 'X'
      FROM hz_cust_account_roles acct_role ,
        hz_parties party ,
        hz_cust_accounts acct ,
        hz_relationships rel ,
        hz_org_contacts org_cont ,
        hz_parties rel_party
      WHERE acct_role.party_id           = rel.party_id
      AND acct_role.role_type            = 'CONTACT'
      AND org_cont.party_relationship_id = rel.relationship_id
      AND rel.subject_table_name         = 'HZ_PARTIES'
      AND rel.object_table_name          = 'HZ_PARTIES'
      AND rel.subject_id                 = party.party_id
      AND rel.party_id                   = rel_party.party_id
      AND rel.object_id                  = acct.party_id
      AND acct.cust_account_id           = acct_role.cust_account_id
      AND rel.directional_flag           = 'F'
      AND wndi.deliver_to_contact_name   = party.person_last_name
        || ', '
        || party.person_first_name
      AND party.party_id = p_person_id
      )
    AND rownum = 1;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
     l_count := 0;
    END;
    --
    --- If record exists in interface table, then Customer person is referenced. Should not delete. Raise error.
    --
    IF l_count > 0 THEN
         per_drt_pkg.add_to_results
                (person_id   => p_person_id
                ,entity_type => 'TCA'
                ,status      => 'E'
                ,msgcode     => 'WSH_DRC_CONTACT_IFACE_EXISTS'
                ,msgaplid    => 665
                ,result_tbl  => result_tbl );
    END IF;
    write_log ('p_person_id: '|| p_person_id,' 100A');
	END IF;
    --- Check whether trips are not closed for this customer
    --
	BEGIN
    l_count := 0;
    SELECT X
    INTO l_count
	FROM
	(SELECT 1 "X"
    FROM wsh_delivery_details wdd ,
      wsh_delivery_assignments wda ,
      wsh_new_deliveries wnd ,
      wsh_delivery_legs wdl ,
      wsh_trip_stops wts ,
      wsh_trips wt
    WHERE wt.trip_id    = wts.trip_id
    AND wts.stop_id     = wdl.pick_up_stop_id
    AND wdl.delivery_id = wnd.delivery_id
    AND wda.delivery_id = wnd.delivery_id
    AND wda.delivery_detail_id = wdd.delivery_detail_id
    AND wt.status_code <> 'CL'
    AND EXISTS (SELECT 'X'
      FROM hz_parties hp,
        hz_cust_accounts acc
      WHERE hp.party_id   = p_person_id
      AND acc.party_id    = hp.party_id
      AND hp.party_type   = 'PERSON'
      AND wnd.customer_id = acc.cust_account_id
      )
    AND rownum = 1
    UNION ALL
    SELECT 1 "X"
    FROM wsh_delivery_details wdd ,
      wsh_delivery_assignments wda ,
      wsh_new_deliveries wnd
    WHERE wda.delivery_id = wnd.delivery_id
    AND wda.delivery_detail_id = wdd.delivery_detail_id
    AND wnd.status_code <> 'CL'
    AND EXISTS (SELECT 'X'
      FROM hz_parties hp,
        hz_cust_accounts acc
      WHERE hp.party_id   = p_person_id
      AND acc.party_id    = hp.party_id
      AND hp.party_type   = 'PERSON'
      AND wnd.customer_id = acc.cust_account_id
      )
    AND NOT EXISTS
	       (SELECT 1
		       FROM wsh_delivery_legs wdl
		   	WHERE wnd.delivery_id = wdl.delivery_id)
    AND rownum = 1          )
    WHERE rownum = 1;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
     l_count := 0;
    END;
    --
    --- BOL: If record exists, then Customer person is referenced. Should not delete. Raise error.
    --
    IF l_count > 0 THEN
         per_drt_pkg.add_to_results
                (person_id   => p_person_id
                ,entity_type => 'TCA'
                ,status      => 'W'
                ,msgcode     => 'WSH_DRC_CST_WND_NOT_CL_TRIP'
                ,msgaplid    => 665
                ,result_tbl  => result_tbl );
    END IF;
    write_log ('p_person_id: '|| p_person_id,' 110');
    --- Check whether trips are not closed for this customer
    --
    BEGIN
    l_count := 0;
    SELECT X
    INTO l_count
	FROM
	(SELECT /*+ use_nl(wda) use_nl(wdl) use_nl(wt) */ 1 "X"
    FROM wsh_delivery_details wdd
      , wsh_new_deliveries wnd
      , wsh_delivery_assignments wda
      , wsh_delivery_legs wdl
      , wsh_trip_stops wts
      , wsh_trips wt
    WHERE wt.trip_id = wts.trip_id
    AND wts.stop_id = wdl.pick_up_stop_id
    AND wdl.delivery_id = wnd.delivery_id
    AND wda.delivery_id = wnd.delivery_id
    AND wda.delivery_detail_id = wdd.delivery_detail_id
    AND wt.status_code <> 'CL'
    AND EXISTS (SELECT /*+ unnest */ 'X'
      FROM hz_parties hp,
        hz_cust_accounts acc
      WHERE hp.party_id   = p_person_id
      AND acc.party_id    = hp.party_id
      AND hp.party_type   = 'PERSON'
      AND wdd.customer_id = acc.cust_account_id
      )
    AND rownum = 1
    UNION ALL
    SELECT 1 "X"
    FROM wsh_delivery_details wdd
      , wsh_new_deliveries wnd
      , wsh_delivery_assignments wda
    WHERE wda.delivery_id = wnd.delivery_id
    AND wda.delivery_detail_id = wdd.delivery_detail_id
    AND wnd.status_code <> 'CL'
    AND EXISTS (SELECT /*+ unnest */ 'X'
      FROM hz_parties hp,
        hz_cust_accounts acc
      WHERE hp.party_id   = p_person_id
      AND acc.party_id    = hp.party_id
      AND hp.party_type   = 'PERSON'
      AND wdd.customer_id = acc.cust_account_id
      )
    AND NOT EXISTS
	       (SELECT 1
		       FROM wsh_delivery_legs wdl
		   	WHERE wnd.delivery_id = wdl.delivery_id)
    AND rownum = 1
    UNION ALL
    SELECT 1 "X"
    FROM wsh_delivery_details wdd
      , wsh_delivery_assignments wda
    WHERE wda.delivery_detail_id = wdd.delivery_detail_id
    AND wdd.released_status NOT IN ('C','D')
    AND wda.delivery_id IS NULL
    AND EXISTS (SELECT /*+ unnest */ 'X'
      FROM hz_parties hp,
        hz_cust_accounts acc
      WHERE hp.party_id   = p_person_id
      AND acc.party_id    = hp.party_id
      AND hp.party_type   = 'PERSON'
      AND wdd.customer_id = acc.cust_account_id
      )
    AND rownum = 1   )
    WHERE rownum = 1;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
     l_count := 0;
    END;
    --
    --- If record exists, then Customer person is referenced. Should not delete. Raise error.
    --
    IF l_count > 0 THEN
         per_drt_pkg.add_to_results
                (person_id   => p_person_id
                ,entity_type => 'TCA'
                ,status      => 'W'
                ,msgcode     => 'WSH_DRC_CST_WDD_NOT_CL_TRIP'
                ,msgaplid    => 665
                ,result_tbl  => result_tbl );
    END IF;
    write_log ('p_person_id: '|| p_person_id,' 120');
    --- BOL DSNO: Check whether trips having ultimate drop off location of a person are open for this customer
    --
    BEGIN
    l_count := 0;
    SELECT X
    INTO l_count
	FROM
	(SELECT /*+ use_nl(wt wts wdl) */ 1 "X"
    FROM wsh_delivery_details wdd ,
      wsh_delivery_assignments wda ,
      wsh_new_deliveries wnd ,
      wsh_delivery_legs wdl ,
      wsh_trip_stops wts ,
      wsh_trips wt
    WHERE wt.trip_id    = wts.trip_id
    AND wts.stop_id     = wdl.pick_up_stop_id
    AND wdl.delivery_id = wnd.delivery_id
    AND wda.delivery_id = wnd.delivery_id
    AND wda.delivery_detail_id = wdd.delivery_detail_id
    AND wt.status_code <> 'CL'
    AND EXISTS
      (SELECT 'X'
      FROM hz_party_sites hps
      WHERE (hps.party_id                  = p_person_id)
      AND wnd.ultimate_dropoff_location_id = hps.location_id
      UNION
      SELECT 'x'
      FROM hz_party_sites hps
      WHERE (hps.party_id IN
        (SELECT hr.party_id
        FROM hz_relationships hr
        WHERE hr.subject_id       = p_person_id
        AND hr.subject_table_name = 'HZ_PARTIES'
        AND hr.subject_type       = 'PERSON'
        ) )
      AND wnd.ultimate_dropoff_location_id = hps.location_id
      )
    AND rownum = 1
	UNION ALL
    SELECT 1 "X"
	FROM wsh_delivery_details wdd,
       wsh_delivery_assignments wda,
       wsh_new_deliveries wnd
    WHERE wda.delivery_id = wnd.delivery_id
    AND wda.delivery_detail_id = wdd.delivery_detail_id
    AND wnd.status_code <> 'CL'
    AND EXISTS
      (SELECT 'X'
      FROM hz_party_sites hps
      WHERE (hps.party_id                  = p_person_id)
      AND wnd.ultimate_dropoff_location_id = hps.location_id
      UNION
      SELECT 'x'
      FROM hz_party_sites hps
      WHERE (hps.party_id IN
        (SELECT hr.party_id
        FROM hz_relationships hr
        WHERE hr.subject_id       = p_person_id
        AND hr.subject_table_name = 'HZ_PARTIES'
        AND hr.subject_type       = 'PERSON'
        ) )
      AND wnd.ultimate_dropoff_location_id = hps.location_id
      )
	AND NOT EXISTS
	       (SELECT 1
		    FROM wsh_delivery_legs wdl
			WHERE wnd.delivery_id = wdl.delivery_id)
    AND rownum = 1)
   WHERE rownum = 1;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
     l_count := 0;
    END;
    --
    --- If record exists, then Customer person is referenced. Should not delete. Raise error.
    --
    IF l_count > 0 THEN
         per_drt_pkg.add_to_results
                (person_id   => p_person_id
                ,entity_type => 'TCA'
                ,status      => 'W'
                ,msgcode     => 'WSH_DRC_DROP_OFF_NOT_CL_TRIP'
                ,msgaplid    => 665
                ,result_tbl  => result_tbl );
    END IF;
    write_log ('p_person_id: '|| p_person_id,' 130');
    --- DSNO Invoice Contact: find if any open trip exists of a person
    --
    BEGIN
    l_count := 0;
    WITH    check_all AS
            (
            SELECT  rel_party.party_id
                   ,oeh.header_id source_header_id
            FROM    oe_order_headers_all oeh
                   ,hz_cust_account_roles acct_role
                   ,hz_relationships rel
                   ,hz_org_contacts org_cont
                   ,hz_parties rel_party
                   ,hz_party_sites party_site
                   ,hz_locations loc
                   ,hz_cust_acct_sites_all acct_site
                   ,hz_cust_site_uses_all hcsu1
            WHERE   oeh.invoice_to_org_id = hcsu1.site_use_id
            AND     hcsu1.contact_id = acct_role.cust_account_role_id
            AND     rel.party_id = acct_role.party_id
            AND     acct_role.role_type = 'CONTACT'
            AND     rel.relationship_id = org_cont.party_relationship_id
            AND     rel.subject_table_name = 'HZ_PARTIES'
            AND     rel.object_table_name = 'HZ_PARTIES'
            AND     rel.subject_id = rel_party.party_id
			   AND     rel_party.party_id  = p_person_id
            AND     hcsu1.cust_acct_site_id = acct_site.cust_acct_site_id
            AND     acct_site.party_site_id = party_site.party_site_id
            AND     loc.location_id = party_site.location_id
            UNION ALL
            SELECT  rel_party.party_id
                   ,wdd.source_header_id
            FROM    hz_cust_account_roles acct_role
                   ,hz_relationships rel
                   ,hz_org_contacts org_cont
                   ,hz_parties rel_party
                   ,hz_party_sites party_site
                   ,hz_locations loc
                   ,hz_cust_acct_sites_all acct_site
                   ,hz_cust_site_uses_all hcsu1
                   ,wsh_delivery_details wdd
            WHERE   wdd.source_code = 'OKE'
            AND     wsh_dsno_oke.get_oke_party (wdd.delivery_detail_id
                                               ,wdd.source_header_id) = hcsu1.site_use_id
            AND     hcsu1.contact_id = acct_role.cust_account_role_id
            AND     rel.party_id  = acct_role.party_id
            AND     acct_role.role_type  = 'CONTACT'
            AND     rel.relationship_id = org_cont.party_relationship_id
            AND     rel.subject_table_name  = 'HZ_PARTIES'
            AND     rel.object_table_name  = 'HZ_PARTIES'
            AND     rel.subject_id = rel_party.party_id
			   AND     rel_party.party_id  = p_person_id
            AND     hcsu1.cust_acct_site_id = acct_site.cust_acct_site_id
            AND     acct_site.party_site_id = party_site.party_site_id
            AND     loc.location_id  = party_site.location_id
            )
    SELECT  X INTO l_count
	FROM (SELECT 1 "X"
    FROM    wsh_delivery_details wdd
           ,wsh_new_deliveries wnd
           ,wsh_delivery_assignments wda
           ,wsh_delivery_legs wdl
           ,wsh_trip_stops wts
           ,wsh_trips wt
           ,check_all
    WHERE   wt.trip_id = wts.trip_id
    AND     wts.stop_id = wdl.pick_up_stop_id
    AND     wdl.delivery_id = wnd.delivery_id
    AND     wda.delivery_id = wnd.delivery_id
    AND     wda.delivery_detail_id = wdd.delivery_detail_id
    AND     wt.status_code <> 'CL'
    AND     check_all.source_header_id = wdd.source_header_id
    AND     rownum = 1
	UNION ALL
	SELECT 1 "X"
	FROM    wsh_delivery_details wdd
           ,wsh_new_deliveries wnd
           ,wsh_delivery_assignments wda
           ,check_all
    WHERE   wda.delivery_id = wnd.delivery_id
    AND     wda.delivery_detail_id = wdd.delivery_detail_id
    AND     check_all.source_header_id = wdd.source_header_id
	 AND     wnd.status_code <> 'CL'
	 AND     NOT EXISTS
	       (SELECT 1
		    FROM wsh_delivery_legs wdl
			WHERE wnd.delivery_id = wdl.delivery_id)
    AND     rownum = 1
	UNION ALL
	SELECT 1 "X"
	FROM    wsh_delivery_details wdd
           ,check_all
    WHERE   check_all.source_header_id = wdd.source_header_id
	AND     wdd.released_status NOT IN ('C','D')
    AND     rownum = 1);
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
     l_count := 0;
    END;
    --
    --- If record exists, then Customer person is referenced. Should not delete. Raise error.
    --
    IF l_count > 0 THEN
         per_drt_pkg.add_to_results
                (person_id   => p_person_id
                ,entity_type => 'TCA'
                ,status      => 'W'
                ,msgcode     => 'WSH_INV_CONTACT_NOT_CL_TRIP'
                ,msgaplid    => 665
                ,result_tbl  => result_tbl );
    END IF;
    write_log ('p_person_id: '|| p_person_id,' 140');

  END;
  --
  write_log ('Leaving:'|| l_proc,'150');
  -- .....
END wsh_tca_drc;
-- .....
END WSH_DRT_PKG;


/
