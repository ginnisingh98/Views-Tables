--------------------------------------------------------
--  DDL for Package IGI_SLS_SECURE_TABLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_SLS_SECURE_TABLES_PKG" AUTHID CURRENT_USER AS
/* $Header: igislscs.pls 120.3.12000000.1 2007/09/03 17:22:14 vspuli ship $ */

    PROCEDURE Update_Row_On_Delete(p_owner              IN igi_sls_secure_tables.owner%TYPE
                                  ,p_table_name         IN igi_sls_secure_tables.table_name%TYPE
                                  ,p_date_removed       IN igi_sls_secure_tables.date_removed%TYPE
                                  ,p_date_disabled      IN igi_sls_secure_tables.date_disabled%TYPE
                                  ,p_last_update_date   IN igi_sls_secure_tables.last_update_date%TYPE
                                  ,p_last_updated_by    IN igi_sls_secure_tables.last_updated_by%TYPE
                                  ,p_last_update_login  IN igi_sls_secure_tables.last_update_login%TYPE);


END IGI_SLS_SECURE_TABLES_PKG;

 

/
