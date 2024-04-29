--------------------------------------------------------
--  DDL for Package Body IGI_CIS_CERT_NI_NUMBERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_CIS_CERT_NI_NUMBERS_PKG" AS
/* $Header: igicisbb.pls 115.9 2003/12/17 13:34:07 hkaniven ship $ */


    l_debug_level NUMBER	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
    l_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
    l_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
    l_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
    l_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
    l_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
    l_path        VARCHAR2(50)  :=  'IGI.PLSQL.igicisbb.IGI_CIS_CERT_NI_NUMBERS_PKG.';


    PROCEDURE Lock_Row(p_row_id            VARCHAR2
                      ,p_tax_rate_id       NUMBER
                      ,p_ni_number         VARCHAR2) IS

        CURSOR c_lock IS
            SELECT *
            FROM   igi_cis_cert_ni_numbers_all
            WHERE  rowid = p_row_id
            FOR UPDATE OF tax_rate_id NOWAIT;

        l_lock_rec         c_lock%ROWTYPE;
    BEGIN
        OPEN c_lock;
        FETCH c_lock INTO l_lock_rec;
        IF (c_lock%NOTFOUND) THEN
            CLOSE c_lock;

	    FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
            IF ( l_excep_level >=  l_debug_level ) THEN
                FND_LOG.MESSAGE (l_excep_level, l_path || 'Lock_Row',FALSE);
	    END IF;
	    APP_EXCEPTION.Raise_Exception;
        END IF;
        CLOSE c_lock;

        IF l_lock_rec.tax_rate_id = p_tax_rate_id AND
           l_lock_rec.ni_number   = p_ni_number
        THEN
            RETURN;
        ELSE
            FND_MESSAGE.Set_Name('FND','FORM_RECORD_CHANGED');
            IF ( l_excep_level >=  l_debug_level ) THEN
                FND_LOG.MESSAGE (l_excep_level, l_path || 'Lock_Row',FALSE);
	    END IF;
            APP_EXCEPTION.Raise_Exception;
        END IF;
    END Lock_Row;


    PROCEDURE Insert_Row(p_row_id            IN OUT NOCOPY VARCHAR2
                        ,p_org_id            NUMBER
                        ,p_tax_rate_id       NUMBER
                        ,p_ni_number         VARCHAR2
                        ,p_creation_date     DATE
                        ,p_created_by        NUMBER
                        ,p_last_update_date  DATE
                        ,p_last_updated_by   NUMBER
                        ,p_last_update_login NUMBER
                        ,p_calling_sequence  IN OUT NOCOPY VARCHAR2) IS

        l_debug_info VARCHAR2(100);

                           --changed row_id to rowid
                           --by sdixit 4/7/03 for MOAC
                           CURSOR c_insert IS SELECT rowid
                           FROM   igi_cis_cert_ni_numbers
                           WHERE  tax_rate_id = p_tax_rate_id;

    BEGIN
        -- Update the calling sequence
        p_calling_sequence := 'IGI_CIS_CERT_NI_NUMBERS_PKG.Insert_Row<-' ||
                              p_calling_sequence;

        l_debug_info := 'Inserting into IGI_CIS_CERT_NI_NUMBERS_ALL';

        INSERT INTO igi_cis_cert_ni_numbers_all
           (tax_rate_id
           ,ni_number
           ,creation_date
           ,created_by
           ,last_update_date
           ,last_updated_by
           ,last_update_login
           ,org_id)
        VALUES
           (p_tax_rate_id
           ,p_ni_number
           ,p_creation_date
           ,p_created_by
           ,p_last_update_date
           ,p_last_updated_by
           ,p_last_update_login
           ,p_org_id);

        l_debug_info := 'Open cursor c_insert';
        OPEN c_insert;
        l_debug_info := 'Fetch cursor c_insert';
        FETCH c_insert INTO p_row_id;
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
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,l_path || 'Insert Row', FALSE);
            END IF;

            APP_EXCEPTION.Raise_Exception;
    END Insert_Row;


    PROCEDURE Update_Row(p_row_id            VARCHAR2
                        ,p_ni_number         VARCHAR2
                        ,p_last_update_date  DATE
                        ,p_last_updated_by   NUMBER
                        ,p_last_update_login NUMBER) IS
    BEGIN
        UPDATE igi_cis_cert_ni_numbers_all
        SET    ni_number         = p_ni_number
              ,last_update_date  = p_last_update_date
              ,last_updated_by   = p_last_updated_by
              ,last_update_login = p_last_update_login
        WHERE rowid = p_row_id;

        IF SQL%NOTFOUND THEN
            RAISE No_Data_Found;
        END IF;
    END Update_Row;

END IGI_CIS_CERT_NI_NUMBERS_PKG;

/
