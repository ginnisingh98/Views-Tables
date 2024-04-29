--------------------------------------------------------
--  DDL for Package Body IGI_SLS_SECURE_TABLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_SLS_SECURE_TABLES_PKG" AS
/* $Header: igislscb.pls 120.3.12000000.1 2007/09/03 17:22:10 vspuli ship $ */


    -- This procedure is called from the ON-DELETE trigger of form IGISLSST.
    -- It updates the date disabled and the date_removed in the table
    PROCEDURE Update_Row_On_Delete(p_owner              IN  igi_sls_secure_tables.owner%TYPE
                                  ,p_table_name         IN  igi_sls_secure_tables.table_name%TYPE
                                  ,p_date_removed       IN  igi_sls_secure_tables.date_removed%TYPE
                                  ,p_date_disabled      IN  igi_sls_secure_tables.date_disabled%TYPE
                                  ,p_last_update_date   IN  igi_sls_secure_tables.last_update_date%TYPE
                                  ,p_last_updated_by    IN  igi_sls_secure_tables.last_updated_by%TYPE
                                  ,p_last_update_login  IN  igi_sls_secure_tables.last_update_login%TYPE)
    IS
    BEGIN
        UPDATE igi_sls_secure_tables
        SET    date_disabled     = p_date_disabled
              ,date_removed      = p_date_removed
              ,last_update_date  = p_last_update_date
              ,last_updated_by   = p_last_updated_by
              ,last_update_login = p_last_update_login
        WHERE owner      = p_owner
        AND   table_name = p_table_name;

        IF SQL%NOTFOUND
        THEN
            RAISE No_Data_Found;
        END IF;
    END Update_Row_On_Delete;

END IGI_SLS_SECURE_TABLES_PKG;

/
