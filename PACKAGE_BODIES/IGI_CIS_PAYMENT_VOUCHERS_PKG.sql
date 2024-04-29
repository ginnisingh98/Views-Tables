--------------------------------------------------------
--  DDL for Package Body IGI_CIS_PAYMENT_VOUCHERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_CIS_PAYMENT_VOUCHERS_PKG" AS
/* $Header: igiciscb.pls 115.9 2003/12/17 13:35:06 hkaniven ship $ */


    l_debug_level NUMBER	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
    l_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
    l_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
    l_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
    l_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
    l_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
    l_path        VARCHAR2(50)  :=      'IGI.PLSQL.igiciscb.IGI_CIS_PAYMENT_VOUCHERS_PKG.';

    PROCEDURE Lock_Row(p_row_id                VARCHAR2
                      ,p_invoice_payment_id    NUMBER
                      ,p_vendor_id             NUMBER
                      ,p_vendor_site_id        NUMBER
                      ,p_pmt_vch_number        VARCHAR2
                      ,p_pmt_vch_amount        NUMBER
                      ,p_pmt_vch_received_date DATE
                      ,p_pmt_vch_description   VARCHAR2) IS

        CURSOR c_lock IS
            SELECT *
            FROM   igi_cis_payment_vouchers_all
            WHERE  rowid = p_row_id
            FOR UPDATE OF invoice_payment_id NOWAIT;

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

        IF l_lock_rec.invoice_payment_id    = p_invoice_payment_id AND
           l_lock_rec.vendor_id             = p_vendor_id AND
           l_lock_rec.vendor_site_id        = p_vendor_site_id AND
           l_lock_rec.pmt_vch_number        = p_pmt_vch_number AND
           l_lock_rec.pmt_vch_amount        = p_pmt_vch_amount AND
           l_lock_rec.pmt_vch_received_date = p_pmt_vch_received_date AND
           l_lock_rec.pmt_vch_description   = p_pmt_vch_description
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


    PROCEDURE Insert_Row(p_org_id                NUMBER
                        ,p_row_id                IN OUT NOCOPY VARCHAR2
                        ,p_invoice_payment_id    NUMBER
                        ,p_vendor_id             NUMBER
                        ,p_vendor_site_id        NUMBER
                        ,p_pmt_vch_number        VARCHAR2
                        ,p_pmt_vch_amount        NUMBER
                        ,p_pmt_vch_received_date DATE
                        ,p_pmt_vch_description   VARCHAR2
                        ,p_creation_date         DATE
                        ,p_created_by            NUMBER
                        ,p_last_update_date      DATE
                        ,p_last_updated_by       NUMBER
                        ,p_last_update_login     NUMBER
                        ,p_calling_sequence      IN OUT NOCOPY VARCHAR2) IS

        l_debug_info VARCHAR2(100);

        CURSOR c_ins IS SELECT rowid
                        FROM   igi_cis_payment_vouchers
                        WHERE  invoice_payment_id = p_invoice_payment_id
                        AND    vendor_id = p_vendor_id
                        AND    vendor_site_id = p_vendor_site_id;
    BEGIN
        p_calling_sequence := 'IGI_CIS_PAYMENT_VOUCHERS_PKG.Insert_Row<=' ||
                              p_calling_sequence;

        l_debug_info := 'Insert Into igi_cis_payment_vouchers_all';

        INSERT INTO igi_cis_payment_vouchers_all
           (org_id
           ,invoice_payment_id
           ,vendor_id
           ,vendor_site_id
           ,pmt_vch_number
           ,pmt_vch_amount
           ,pmt_vch_received_date
           ,pmt_vch_description
           ,creation_date
           ,created_by
           ,last_update_date
           ,last_updated_by
           ,last_update_login)
        VALUES
           (p_org_id
           ,p_invoice_payment_id
           ,p_vendor_id
           ,p_vendor_site_id
           ,p_pmt_vch_number
           ,p_pmt_vch_amount
           ,p_pmt_vch_received_date
           ,p_pmt_vch_description
           ,p_creation_date
           ,p_created_by
           ,p_last_update_date
           ,p_last_updated_by
           ,p_last_update_login);

        l_debug_info := 'Open c_ins';
        OPEN c_ins;
        l_debug_info := 'Fetch c_ins';
        FETCH c_ins INTO p_row_id;
        IF c_ins%NOTFOUND THEN
            l_debug_info := 'Close c_ins NOTFOUND';
            CLOSE c_ins;
            RAISE No_Data_Found;
        END IF;
        l_debug_info := 'Close c_ins';
        CLOSE c_ins;

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
               		FND_LOG.MESSAGE ( l_unexp_level,l_path || 'Insert_Row', TRUE);
          	END IF;

                APP_EXCEPTION.Raise_Exception;
    END Insert_Row;


    PROCEDURE Update_Row(p_row_id                VARCHAR2
                        ,p_vendor_id             NUMBER
                        ,p_vendor_site_id        NUMBER
                        ,p_pmt_vch_number        VARCHAR2
                        ,p_pmt_vch_amount        NUMBER
                        ,p_pmt_vch_received_date DATE
                        ,p_pmt_vch_description   VARCHAR2
                        ,p_last_update_date      DATE
                        ,p_last_updated_by       NUMBER
                        ,p_last_update_login     NUMBER) IS
    BEGIN
        UPDATE igi_cis_payment_vouchers_all
        SET    vendor_id             = p_vendor_id
              ,vendor_site_id        = p_vendor_site_id
              ,pmt_vch_number        = p_pmt_vch_number
              ,pmt_vch_amount        = p_pmt_vch_amount
              ,pmt_vch_received_date = p_pmt_vch_received_date
              ,pmt_vch_description   = p_pmt_vch_description
              ,last_update_date      = p_last_update_date
              ,last_updated_by       = p_last_updated_by
              ,last_update_login     = p_last_update_login
        WHERE rowid = p_row_id;

        IF SQL%NOTFOUND THEN
            RAISE No_Data_Found;
        END IF;
    END Update_Row;

END IGI_CIS_PAYMENT_VOUCHERS_PKG;

/
