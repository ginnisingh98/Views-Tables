--------------------------------------------------------
--  DDL for Package Body IGI_SLS_SECURE_TABLES_AU_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_SLS_SECURE_TABLES_AU_PKG" AS
/* $Header: igislsbb.pls 120.6.12000000.1 2007/09/03 17:22:03 vspuli ship $ */

   l_debug_level NUMBER	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
   l_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
   l_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
   l_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
   l_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
   l_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
   l_path        VARCHAR2(50)  :=  'IGI.PLSQL.igislsbb.IGI_SLS_SECURE_TABLES_AU_PKG.';

    PROCEDURE Insert_Row(p_owner                   IN igi_sls_secure_tables.owner%TYPE
                        ,p_table_name              IN igi_sls_secure_tables.table_name%TYPE
                        ,p_description             IN igi_sls_secure_tables.description%TYPE
                        ,p_sls_table_name          IN igi_sls_secure_tables.sls_table_name%TYPE
                        ,p_update_allowed          IN igi_sls_secure_tables.update_allowed%TYPE
                        ,p_date_enabled            IN igi_sls_secure_tables.date_enabled%TYPE
                        ,p_date_disabled           IN igi_sls_secure_tables.date_disabled%TYPE
                        ,p_date_removed            IN igi_sls_secure_tables.date_removed%TYPE
                        ,p_date_object_created   IN igi_sls_secure_tables.date_object_created%TYPE
                        ,p_date_security_applied   IN igi_sls_secure_tables.date_security_applied%TYPE
                        ,p_creation_date           IN igi_sls_secure_tables.creation_date%TYPE
                        ,p_created_by              IN igi_sls_secure_tables.created_by%TYPE
                        ,p_last_update_date        IN igi_sls_secure_tables.last_update_date%TYPE
                        ,p_last_updated_by         IN igi_sls_secure_tables.last_updated_by%TYPE
                        ,p_last_update_login       IN igi_sls_secure_tables.last_update_login%TYPE
                        ,p_rowid                   IN OUT NOCOPY VARCHAR2
                        ,p_calling_sequence        IN OUT NOCOPY VARCHAR2)
    IS

        l_debug_info VARCHAR2(100);

        CURSOR c_insert IS
               SELECT rowid
               FROM   igi_sls_secure_tables_audit
               WHERE  owner      = p_owner
               AND    table_name = p_table_name;

    BEGIN
        -- Update the calling sequence
        p_calling_sequence := 'IGI_SLS_SECURE_TABLES_AU_PKG.Insert_Row<-' ||
                              p_calling_sequence;

        l_debug_info := 'Inserting into IGI_SLS_SECURE_TABLES_AUDIT';

        INSERT INTO igi_sls_secure_tables_audit
               (owner
               ,table_name
               ,description
               ,sls_table_name
               ,update_allowed
               ,date_enabled
               ,date_disabled
               ,date_removed
               ,date_object_created
               ,date_security_applied
               ,creation_date
               ,created_by
               ,last_update_date
               ,last_updated_by
               ,last_update_login)
        VALUES
               (p_owner
               ,p_table_name
               ,p_description
               ,p_sls_table_name
               ,p_update_allowed
               ,p_date_enabled
               ,p_date_disabled
               ,p_date_removed
               ,p_date_object_created
               ,p_date_security_applied
               ,p_creation_date
               ,p_created_by
               ,p_last_update_date
               ,p_last_updated_by
               ,p_last_update_login);

        l_debug_info := 'Open cursor c_insert';
        OPEN c_insert;

        l_debug_info := 'Fetch cursor c_insert';
        FETCH c_insert INTO p_rowid;

        IF c_insert%NOTFOUND THEN
            l_debug_info := 'Close cursor c_insert NOTFOUND';
            CLOSE c_insert;
            RAISE No_Data_Found;
        END IF;

        l_debug_info := 'Close cursor c_insert';
        CLOSE c_insert;

    EXCEPTION
        WHEN OTHERS THEN
            FND_MESSAGE.Set_Name('SQLAP','AP_DEBUG');
            FND_MESSAGE.Set_Token('ERROR',SQLERRM);
            FND_MESSAGE.Set_Token('CALLING_SEQUENCE',p_calling_sequence);
            FND_MESSAGE.Set_Token('DEBUG_INFO',l_debug_info);
	    IF ( l_unexp_level >= l_debug_level ) THEN
                FND_LOG.MESSAGE ( l_unexp_level,l_path || 'Insert_Row', FALSE);
            END IF;
            APP_EXCEPTION.Raise_Exception;

    END Insert_Row;

END IGI_SLS_SECURE_TABLES_AU_PKG;

/
