--------------------------------------------------------
--  DDL for Package IGI_SLS_SECURE_TABLES_AU_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_SLS_SECURE_TABLES_AU_PKG" AUTHID CURRENT_USER AS
/* $Header: igislsbs.pls 120.4.12000000.1 2007/09/03 17:22:07 vspuli ship $ */

    PROCEDURE Insert_Row(p_owner              IN      igi_sls_secure_tables.owner%TYPE
                        ,p_table_name         IN      igi_sls_secure_tables.table_name%TYPE
                        ,p_description        IN      igi_sls_secure_tables.description%TYPE
                        ,p_sls_table_name     IN      igi_sls_secure_tables.sls_table_name%TYPE
                        ,p_update_allowed     IN      igi_sls_secure_tables.update_allowed%TYPE
                        ,p_date_enabled       IN      igi_sls_secure_tables.date_enabled%TYPE
                        ,p_date_disabled      IN      igi_sls_secure_tables.date_disabled%TYPE
                        ,p_date_removed       IN      igi_sls_secure_tables.date_removed%TYPE
                        ,p_date_object_created     IN igi_sls_secure_tables.date_object_created%TYPE
                        ,p_date_security_applied   IN igi_sls_secure_tables.date_security_applied%TYPE
                        ,p_creation_date      IN      igi_sls_secure_tables.creation_date%TYPE
                        ,p_created_by         IN      igi_sls_secure_tables.created_by%TYPE
                        ,p_last_update_date   IN      igi_sls_secure_tables.last_update_date%TYPE
                        ,p_last_updated_by    IN      igi_sls_secure_tables.last_updated_by%TYPE
                        ,p_last_update_login  IN      igi_sls_secure_tables.last_update_login%TYPE
                        ,p_rowid              IN OUT NOCOPY VARCHAR2
                        ,p_calling_sequence   IN OUT NOCOPY VARCHAR2);


END IGI_SLS_SECURE_TABLES_AU_PKG;

 

/
