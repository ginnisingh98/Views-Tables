--------------------------------------------------------
--  DDL for Package Body INV_MGD_MVT_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MGD_MVT_DRT_PKG" AS
/* $Header: INVMVTDRTB.pls 120.0.12010000.5 2018/05/09 15:18:02 abhissri noship $ */

    g_package   VARCHAR2(50) := 'INV_MGD_MVT_DRT_PKG';
    -- g_debug     BOOLEAN := hr_utility.debug_enabled;

    PROCEDURE gbl_tca_drc(person_id     IN NUMBER,
                          result_tbl    OUT NOCOPY PER_DRT_PKG.result_tbl_type)
    AS
        l_exists        NUMBER := 0;
        -- l_counter       NUMBER;

    BEGIN
        PER_DRT_PKG.write_log('Entering:: ' || g_package || '.gbl_tca_drc', '10');
        PER_DRT_PKG.write_log('Parameters:: person_id: '|| person_id, '20');

        -- Check if there are any movement records for this person with status as Frozen or Exported.
        -- SELECT 1
        -- INTO l_exists
        -- FROM dual
        -- WHERE EXISTS (
        --     SELECT 'exists'
        --     FROM mtl_movement_statistics
        --     WHERE (movement_status in ('F','X')
        --         OR edi_sent_flag = 'Y')
        --     AND (vendor_id = person_id
        --       OR bill_to_customer_id = person_id)
        --     AND ROWNUM = 1 );

        SELECT movement_id
        INTO l_exists
        FROM mtl_movement_statistics
        WHERE ( movement_status IN ('F','X')
             OR edi_sent_flag = 'Y')
          AND ( vendor_id = (SELECT vendor_id
                             FROM ap_suppliers
                             WHERE party_id = person_id)
             OR bill_to_customer_id = (SELECT cust_account_id
                                       FROM hz_cust_accounts
                                       WHERE party_id = person_id)
              )
          AND ROWNUM = 1;

        IF (l_exists > 0) THEN
            PER_DRT_PKG.write_log('Constraint hit', '30');

            PER_DRT_PKG.add_to_results
                (person_id   => person_id
               , entity_type => 'TCA'
               , status      => 'W'
               , msgcode     => 'INV_DRT_FROZEN_MVT_RECORDS'
               , msgaplid    => 401
               , result_tbl  => result_tbl);
        END IF;

        PER_DRT_PKG.write_log('Leaving ' || g_package || '.gbl_tca_drc', '40');

    EXCEPTION
        WHEN no_data_found THEN
            PER_DRT_PKG.write_log('No frozen or exported movement records exist for person_id: ' || person_id || '. ' ||
                                  'Records for this person can be updated.', '50');
            PER_DRT_PKG.write_log('Leaving ' || g_package || '.gbl_tca_drc', '60');

        WHEN others THEN
            PER_DRT_PKG.write_log('Exception ' || SQLERRM || ' in ' || g_package || '.gbl_tca_drc', '60');
            PER_DRT_PKG.write_log('Leaving ' || g_package || '.gbl_tca_drc', '70');

    END gbl_tca_drc;

END INV_MGD_MVT_DRT_PKG;

/
