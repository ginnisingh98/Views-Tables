--------------------------------------------------------
--  DDL for Package Body JE_INTERFACE_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_INTERFACE_VAL" AS
/* $Header: jgjegdfb.pls 120.11 2006/08/23 07:50:31 vgadde ship $ */

PROCEDURE ap_business_rules(
      p_calling_program_name            IN    VARCHAR2,
      p_set_of_books_id                 IN    NUMBER,
      p_invoice_date                    IN    DATE,
      p_parent_table                    IN    VARCHAR2,
      p_parent_id                       IN    NUMBER,
      p_default_last_updated_by         IN    NUMBER,
      p_default_last_update_login       IN    NUMBER,
      p_inv_vendor_site_id              IN    NUMBER,
      p_inv_payment_currency_code       IN    VARCHAR2,
      p_global_attribute_category       IN    VARCHAR2,
      p_global_attribute1               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute2               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute3               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute4               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute5               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute6               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute7               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute8               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute9               IN OUT NOCOPY    VARCHAR2,
      p_global_attribute10              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute11              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute12              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute13              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute14              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute15              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute16              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute17              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute18              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute19              IN OUT NOCOPY    VARCHAR2,
      p_global_attribute20              IN OUT NOCOPY    VARCHAR2,
      p_current_invoice_status          OUT NOCOPY   VARCHAR2,
      p_calling_sequence                IN    VARCHAR2) IS

    l_current_invoice_status    VARCHAR2(1)  := 'Y';
    l_debug_loc                 VARCHAR2(30) := 'ap_business_rules';
    l_curr_calling_sequence         VARCHAR2(2000);
    l_debug_info                    VARCHAR2(100);

BEGIN
  -------------------------- DEBUG INFORMATION ------------------------------------------
  l_curr_calling_sequence := 'je_interface_val.'||l_debug_loc||'<-'||p_calling_sequence;
  l_debug_info := 'Check Europe business rules';
  ---------------------------------------------------------------------------------------

 --
  --     1-7.  JE.IT.APXIISIM.DEF
  --
  IF (p_global_attribute_category = 'JE.IT.APXIISIM.DISTRIBUTIONS') THEN
    je_it_apxiisim_def(
          p_parent_id,
          p_default_last_updated_by,
          p_default_last_update_login,
          p_global_attribute1,
          p_global_attribute2,
          p_global_attribute3,
          p_global_attribute4,
          p_global_attribute5,
          p_global_attribute6,
          p_global_attribute7,
          p_global_attribute8,
          p_global_attribute9,
          p_global_attribute10,
          p_global_attribute11,
          p_global_attribute12,
          p_global_attribute13,
          p_global_attribute14,
          p_global_attribute15,
          p_global_attribute16,
          p_global_attribute17,
          p_global_attribute18,
          p_global_attribute19,
          p_global_attribute20,
          l_current_invoice_status,
          p_calling_sequence);


   ELSIF (p_global_attribute_category = 'JE.ES.APXIISIM.MODELO349') THEN
      je_es_apxiisim_modelo349(
          p_parent_id,
          p_default_last_updated_by,
          p_default_last_update_login,
	  p_global_attribute1,
          p_global_attribute2,
          p_global_attribute3,
          p_global_attribute4,
          p_global_attribute5,
          p_global_attribute6,
          p_global_attribute7,
          p_global_attribute8,
          p_global_attribute9,
          p_global_attribute10,
          p_global_attribute11,
          p_global_attribute12,
          p_global_attribute13,
          p_global_attribute14,
          p_global_attribute15,
          p_global_attribute16,
          p_global_attribute17,
          p_global_attribute18,
          p_global_attribute19,
          p_global_attribute20,
          l_current_invoice_status,
          p_calling_sequence);


  --
  --    1-24. JE.CZ.APXIISIM.INVOICE_INFO
  --
  ELSIF (p_global_attribute_category = 'JE.CZ.APXIISIM.INVOICE_INFO') THEN
    je_cz_apxiisim_invoice_info(
          p_parent_id,
          p_default_last_updated_by,
          p_default_last_update_login,
          p_global_attribute1,
          p_global_attribute2,
          p_global_attribute3,
          p_global_attribute4,
          p_global_attribute5,
          p_global_attribute6,
          p_global_attribute7,
          p_global_attribute8,
          p_global_attribute9,
          p_global_attribute10,
          p_global_attribute11,
          p_global_attribute12,
          p_global_attribute13,
          p_global_attribute14,
          p_global_attribute15,
          p_global_attribute16,
          p_global_attribute17,
          p_global_attribute18,
          p_global_attribute19,
          p_global_attribute20,
          l_current_invoice_status,
          p_calling_sequence);

  --
  --    1-25. JE.HU.APXIISIM.TAX_DATE
  --
  ELSIF (p_global_attribute_category = 'JE.HU.APXIISIM.TAX_DATE') THEN
    je_hu_apxiisim_tax_date(
          p_parent_id,
          p_default_last_updated_by,
          p_default_last_update_login,
          p_global_attribute1,
          p_global_attribute2,
          p_global_attribute3,
          p_global_attribute4,
          p_global_attribute5,
          p_global_attribute6,
          p_global_attribute7,
          p_global_attribute8,
          p_global_attribute9,
          p_global_attribute10,
          p_global_attribute11,
          p_global_attribute12,
          p_global_attribute13,
          p_global_attribute14,
          p_global_attribute15,
          p_global_attribute16,
          p_global_attribute17,
          p_global_attribute18,
          p_global_attribute19,
          p_global_attribute20,
          l_current_invoice_status,
          p_calling_sequence);


  END IF;

    p_current_invoice_status := l_current_invoice_status;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', 'SQLERRM');
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
                        'Set Of Books Id = '||to_char(p_set_of_books_id)
                    ||', Parent Table = '||p_parent_table
                    ||', Parent Id = '||to_char(p_parent_id)
                    ||', Last Updated By = '||to_char(p_default_last_updated_by)
                    ||', Last Update Login = '||to_char(p_default_last_update_login)
                    ||', Global Attribute Category = '||p_global_attribute_category
                    ||', Global Attribute1 = '||p_global_attribute1
                    ||', Global Attribute2 = '||p_global_attribute2
                    ||', Global Attribute3 = '||p_global_attribute3
                    ||', Global Attribute4 = '||p_global_attribute4
                    ||', Global Attribute5 = '||p_global_attribute5
                    ||', Global Attribute6 = '||p_global_attribute6
                    ||', Global Attribute7 = '||p_global_attribute7
                    ||', Global Attribute8 = '||p_global_attribute8
                    ||', Global Attribute9 = '||p_global_attribute9
                    ||', Global Attribute10 = '||p_global_attribute10
                    ||', Global Attribute11 = '||p_global_attribute11
                    ||', Global Attribute12 = '||p_global_attribute12
                    ||', Global Attribute13 = '||p_global_attribute13
                    ||', Global Attribute14 = '||p_global_attribute14
                    ||', Global Attribute15 = '||p_global_attribute15
                    ||', Global Attribute16 = '||p_global_attribute16
                    ||', Global Attribute17 = '||p_global_attribute17
                    ||', Global Attribute18 = '||p_global_attribute18
                    ||', Global Attribute19 = '||p_global_attribute19
                    ||', Global Attribute20 = '||p_global_attribute20);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END ap_business_rules;





  --------------------------------------------------------------------------------------
  --    JE_IT_APXIISIM_DISTRIBUTIONS()
  --------------------------------------------------------------------------------------
  --    Following segemnts are defined for Italian Invoice Line Interface:
  --------------------------------------------------------------------------------------
  --    No. Name                       Column             Value Set            Required
  --    --- -------------------------- ------------------ -------------------- ---------
  --    1   TAXABLE_AMOUNT             GLOBAL_ATTRIBUTE1  JEIT_NUMBER           NO
  --------------------------------------------------------------------------------------
  PROCEDURE je_it_apxiisim_def
     (p_parent_id                       IN    NUMBER,
      p_default_last_updated_by         IN    NUMBER,
      p_default_last_update_login       IN    NUMBER,
      p_global_attribute1               IN    VARCHAR2,
      p_global_attribute2               IN    VARCHAR2,
      p_global_attribute3               IN    VARCHAR2,
      p_global_attribute4               IN    VARCHAR2,
      p_global_attribute5               IN    VARCHAR2,
      p_global_attribute6               IN    VARCHAR2,
      p_global_attribute7               IN    VARCHAR2,
      p_global_attribute8               IN    VARCHAR2,
      p_global_attribute9               IN    VARCHAR2,
      p_global_attribute10              IN    VARCHAR2,
      p_global_attribute11              IN    VARCHAR2,
      p_global_attribute12              IN    VARCHAR2,
      p_global_attribute13              IN    VARCHAR2,
      p_global_attribute14              IN    VARCHAR2,
      p_global_attribute15              IN    VARCHAR2,
      p_global_attribute16              IN    VARCHAR2,
      p_global_attribute17              IN    VARCHAR2,
      p_global_attribute18              IN    VARCHAR2,
      p_global_attribute19              IN    VARCHAR2,
      p_global_attribute20              IN    VARCHAR2,
      p_current_invoice_status          OUT NOCOPY   VARCHAR2,
      p_calling_sequence                IN    VARCHAR2) IS


	l_def_exp_acc_exists	VARCHAR2(1);
	l_def_exp_sob_id	NUMBER;

  BEGIN


-- Taxable Amount
  IF p_global_attribute1 is not null then
-- Bug 3510068. Changed the maximum size from 1 to 30.
     IF (NOT jg_globe_flex_val_shared.check_format(p_global_attribute1,'N',30,'','N','N','N','','')) then
     	jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
						p_parent_id,
						'INVALID_GLOBAL_ATTR1',
						p_default_last_updated_by,
						p_default_last_update_login,
						p_calling_sequence);
        p_current_invoice_status := 'N';
     END IF;
  END IF;

  IF (p_global_attribute6 is not null) or
     (p_global_attribute7 is not null) or
     (p_global_attribute8 is not null) or
     (p_global_attribute9 is not null) or
     (p_global_attribute10 is not null) or
     (p_global_attribute11 is not null) or
     (p_global_attribute12 is not null) or
     (p_global_attribute13 is not null) or
     (p_global_attribute14 is not null) or
     (p_global_attribute15 is not null) or
     (p_global_attribute16 is not null) or
     (p_global_attribute17 is not null) or
     (p_global_attribute18 is not null) or
     (p_global_attribute19 is not null) or
     (p_global_attribute20 is not null)  THEN

			jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                    p_parent_id,
                                    'GLOBAL_ATTR_VALUE_FOUND',
                                    p_default_last_updated_by,
                                    p_default_last_update_login,
                                    p_calling_sequence);
        		p_current_invoice_status := 'N';

  END IF;
  end je_it_apxiisim_def;



  --------------------------------------------------------------------------------------
  --    JE_CZ_APXIISIM_INVOICE_INFO()
  --------------------------------------------------------------------------------------
  --    Following segments are defined for Czech Republic Invoice Interface:
  --------------------------------------------------------------------------------------
  --    No. Name                       Column             Value Set            Required
  --    --- -------------------------- ------------------ -------------------- ---------
  --      4 IMPORT_DOC_DATE            GLOBAL_ATTRIBUTE4  FND_STANDARD_DATE    No
  --------------------------------------------------------------------------------------
  PROCEDURE je_cz_apxiisim_invoice_info
     (p_parent_id                       IN    NUMBER,
      p_default_last_updated_by         IN    NUMBER,
      p_default_last_update_login       IN    NUMBER,
      p_global_attribute1               IN    VARCHAR2,
      p_global_attribute2               IN    VARCHAR2,
      p_global_attribute3               IN    VARCHAR2,
      p_global_attribute4               IN    VARCHAR2,
      p_global_attribute5               IN    VARCHAR2,
      p_global_attribute6               IN    VARCHAR2,
      p_global_attribute7               IN    VARCHAR2,
      p_global_attribute8               IN    VARCHAR2,
      p_global_attribute9               IN    VARCHAR2,
      p_global_attribute10              IN    VARCHAR2,
      p_global_attribute11              IN    VARCHAR2,
      p_global_attribute12              IN    VARCHAR2,
      p_global_attribute13              IN    VARCHAR2,
      p_global_attribute14              IN    VARCHAR2,
      p_global_attribute15              IN    VARCHAR2,
      p_global_attribute16              IN    VARCHAR2,
      p_global_attribute17              IN    VARCHAR2,
      p_global_attribute18              IN    VARCHAR2,
      p_global_attribute19              IN    VARCHAR2,
      p_global_attribute20              IN    VARCHAR2,
      p_current_invoice_status          OUT NOCOPY   VARCHAR2,
      p_calling_sequence                IN    VARCHAR2) IS

  BEGIN

    IF   (
    -- bug 1579266 this country uses global attribute 5,6,7
       -- (p_global_attribute5  IS NOT NULL) OR
       -- (p_global_attribute6  IS NOT NULL) OR
       -- (p_global_attribute7  IS NOT NULL) OR
       --   (p_global_attribute2  IS NOT NULL) OR
          (p_global_attribute8  IS NOT NULL) OR
          (p_global_attribute9  IS NOT NULL) OR
          (p_global_attribute10 IS NOT NULL) OR
          (p_global_attribute11 IS NOT NULL) OR
          (p_global_attribute12 IS NOT NULL) OR
          (p_global_attribute13 IS NOT NULL) OR
          (p_global_attribute14 IS NOT NULL) OR
          (p_global_attribute15 IS NOT NULL) OR
          (p_global_attribute16 IS NOT NULL) OR
          (p_global_attribute17 IS NOT NULL) OR
          (p_global_attribute18 IS NOT NULL) OR
          (p_global_attribute19 IS NOT NULL) OR
          (p_global_attribute20 IS NOT NULL))
    THEN

                  jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                    p_parent_id,
                                    'GLOBAL_ATTR_VALUE_FOUND',
                                    p_default_last_updated_by,
                                    p_default_last_update_login,
                                    p_calling_sequence);
        p_current_invoice_status := 'N';
    END IF;
  END je_cz_apxiisim_invoice_info;

  --------------------------------------------------------------------------------------
  --    JE_HU_APXIISIM_TAX_DATE()
  --------------------------------------------------------------------------------------
  --    Following segments are defined for Hungary Invoice Interface:
  --------------------------------------------------------------------------------------
  --    No. Name                       Column             Value Set            Required
  --    --- -------------------------- ------------------ -------------------- ---------
  --      1 TAX_DATE                   GLOBAL_ATTRIBUTE1  FND_STANDARD_DATE    Yes
  --      2 Check VAT Amount Paid      GLOBAL_ATTRIBUTE2  YES_NO               Yes

  --------------------------------------------------------------------------------------
  PROCEDURE je_hu_apxiisim_tax_date
     (p_parent_id                       IN    NUMBER,
      p_default_last_updated_by         IN    NUMBER,
      p_default_last_update_login       IN    NUMBER,
      p_global_attribute1               IN    VARCHAR2,
      p_global_attribute2               IN    VARCHAR2,
      p_global_attribute3               IN    VARCHAR2,
      p_global_attribute4               IN    VARCHAR2,
      p_global_attribute5               IN    VARCHAR2,
      p_global_attribute6               IN    VARCHAR2,
      p_global_attribute7               IN    VARCHAR2,
      p_global_attribute8               IN    VARCHAR2,
      p_global_attribute9               IN    VARCHAR2,
      p_global_attribute10              IN    VARCHAR2,
      p_global_attribute11              IN    VARCHAR2,
      p_global_attribute12              IN    VARCHAR2,
      p_global_attribute13              IN    VARCHAR2,
      p_global_attribute14              IN    VARCHAR2,
      p_global_attribute15              IN    VARCHAR2,
      p_global_attribute16              IN    VARCHAR2,
      p_global_attribute17              IN    VARCHAR2,
      p_global_attribute18              IN    VARCHAR2,
      p_global_attribute19              IN    VARCHAR2,
      p_global_attribute20              IN    VARCHAR2,
      p_current_invoice_status          OUT NOCOPY   VARCHAR2,
      p_calling_sequence                IN    VARCHAR2) IS

  BEGIN

    IF (p_global_attribute2 IS NOT NULL AND
	    p_global_attribute2 NOT IN ('Y','N'))  OR
       (p_global_attribute2 IS NULL) THEN

       jg_globe_flex_val_shared.insert_rejections(
				    'AP_INVOICES_INTERFACE',
                                    p_parent_id,
                                    'INVALID_GLOBAL_ATTR2',
                                    p_default_last_updated_by,
                                    p_default_last_update_login,
                                    p_calling_sequence);

        p_current_invoice_status := 'N';


    END IF;

    IF
          ((p_global_attribute3  IS NOT NULL) OR
          (p_global_attribute4  IS NOT NULL) OR
          (p_global_attribute5  IS NOT NULL) OR
          (p_global_attribute6  IS NOT NULL) OR
          (p_global_attribute7  IS NOT NULL) OR
          (p_global_attribute8  IS NOT NULL) OR
          (p_global_attribute9  IS NOT NULL) OR
          (p_global_attribute10 IS NOT NULL) OR
          (p_global_attribute11 IS NOT NULL) OR
          (p_global_attribute12 IS NOT NULL) OR
          (p_global_attribute13 IS NOT NULL) OR
          (p_global_attribute14 IS NOT NULL) OR
          (p_global_attribute15 IS NOT NULL) OR
          (p_global_attribute16 IS NOT NULL) OR
          (p_global_attribute17 IS NOT NULL) OR
          (p_global_attribute18 IS NOT NULL) OR
          (p_global_attribute19 IS NOT NULL) OR
          (p_global_attribute20 IS NOT NULL))
    THEN
                  jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                    p_parent_id,
                                    'GLOBAL_ATTR_VALUE_FOUND',
                                    p_default_last_updated_by,
                                    p_default_last_update_login,
                                    p_calling_sequence);
        p_current_invoice_status := 'N';
    END IF;
  END je_hu_apxiisim_tax_date;


   PROCEDURE je_es_apxiisim_modelo349
     (p_parent_id                       IN    NUMBER,
      p_default_last_updated_by         IN    NUMBER,
      p_default_last_update_login       IN    NUMBER,
      p_global_attribute1               IN    VARCHAR2,
      p_global_attribute2               IN    VARCHAR2,
      p_global_attribute3               IN    VARCHAR2,
      p_global_attribute4               IN    VARCHAR2,
      p_global_attribute5               IN    VARCHAR2,
      p_global_attribute6               IN    VARCHAR2,
      p_global_attribute7               IN    VARCHAR2,
      p_global_attribute8               IN    VARCHAR2,
      p_global_attribute9               IN    VARCHAR2,
      p_global_attribute10              IN    VARCHAR2,
      p_global_attribute11              IN    VARCHAR2,
      p_global_attribute12              IN    VARCHAR2,
      p_global_attribute13              IN    VARCHAR2,
      p_global_attribute14              IN    VARCHAR2,
      p_global_attribute15              IN    VARCHAR2,
      p_global_attribute16              IN    VARCHAR2,
      p_global_attribute17              IN    VARCHAR2,
      p_global_attribute18              IN    VARCHAR2,
      p_global_attribute19              IN    VARCHAR2,
      p_global_attribute20              IN    VARCHAR2,
      p_current_invoice_status          OUT NOCOPY   VARCHAR2,
      p_calling_sequence                IN    VARCHAR2) IS

      l_stat_code_exists  VARCHAR2(1);

  BEGIN
    BEGIN
      IF p_global_attribute2 IS NOT NULL THEN
      if p_global_attribute3 is NULL THEN

       jg_globe_flex_val_shared.insert_rejections('AP_INVOICE_LINES_INTERFACE',
                                    p_parent_id,
                                    'INVALID_GLOBAL_ATTR3',
                                    p_default_last_updated_by,
                                    p_default_last_update_login,
                                    p_calling_sequence);
        p_current_invoice_status := 'N';

        end if;
        end if;

      EXCEPTION
        WHEN OTHERS THEN
                 jg_globe_flex_val_shared.insert_rejections('AP_INVOICE_LINES_INTERFACE',
                                    p_parent_id,
                                    'GLOBAL_ATTR_VALUE_FOUND',
                                    p_default_last_updated_by,
                                    p_default_last_update_login,
                                    p_calling_sequence);
        p_current_invoice_status := 'N';
   END;
  IF   (p_global_attribute4 IS NOT NULL) or
       (p_global_attribute6 IS NOT NULL) or
       (p_global_attribute7 IS NOT NULL) or
       (p_global_attribute8 IS NOT NULL) or
       (p_global_attribute9 IS NOT NULL) or
       (p_global_attribute10 IS NOT NULL) or
       (p_global_attribute11 IS NOT NULL) or
       (p_global_attribute12 IS NOT NULL) or
       (p_global_attribute13 IS NOT NULL) or
       (p_global_attribute14 IS NOT NULL) or
       (p_global_attribute15 IS NOT NULL) or
       (p_global_attribute16 IS NOT NULL) or
       (p_global_attribute17 IS NOT NULL) or
       (p_global_attribute18 IS NOT NULL) or
       (p_global_attribute19 IS NOT NULL) or
       (p_global_attribute20 IS NOT NULL)
    THEN
                    jg_globe_flex_val_shared.insert_rejections('AP_INVOICE_LINES_INTERFACE',
                                      p_parent_id,
                                      'GLOBAL_ATTR_VALUE_FOUND',
                                      p_default_last_updated_by,
                                      p_default_last_update_login,
                                      p_calling_sequence);
        p_current_invoice_status := 'N';
    END IF;


  END je_es_apxiisim_modelo349;

-- Modification to the passing of parameters to ar_business_rules for TCA model

PROCEDURE ar_business_rules
   (p_int_table_name                  IN VARCHAR2,
    p_glob_attr_set1                  IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set2                  IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set3                  IN jg_globe_flex_val_shared.GdfRec,
    p_misc_prod_arg                   IN jg_globe_flex_val_shared.GenRec,
    p_current_record_status           OUT NOCOPY VARCHAR2) IS

     l_current_record_status       VARCHAR2(1) := 'S';
     l_ou_id  NUMBER;
BEGIN

  ----------------------------- DEBUG INFORMATION ------------------------------
  arp_standard.debug('Check ar business rules');
  ------------------------------------------------------------------------------
  -- Call to validate the address gdfs
IF p_int_table_name = 'CUSTOMER' THEN


    SELECT org_id into l_ou_id FROM fnd_concurrent_requests
    WHERE request_id = fnd_global.conc_request_id ;

    fnd_request.set_org_id(l_ou_id);

     IF jg_zz_shared_pkg.get_country(l_ou_id, NULL,null) IN ('GR','PT','ES') THEN
--     IF sys_context('JG','JGZZ_COUNTRY_CODE') IN ('GR','PT','ES' ) THEN
        IF p_glob_attr_set1.global_attribute_category =
                                  ('JE.GR.ARXCUDCI.CUSTOMERS') then
           je_gr_arxcudci_cust_txid (p_glob_attr_set1,
                                     p_glob_attr_set2,
                                     p_glob_attr_set3,
                                     p_misc_prod_arg,
                                     l_current_record_status);
        END IF;

       IF p_glob_attr_set3.global_attribute_category  IN
                                  ('JE.GR.ARXCUDCI.RA',
                                   'JE.PT.ARXCUDCI.RA') then
           je_zz_arxcudci_site_uses (p_glob_attr_set1,
                                     p_glob_attr_set2,
                                     p_glob_attr_set3,
                                     p_misc_prod_arg,
                                     l_current_record_status);
        END IF;

     END IF;

 END IF;

  p_current_record_status := l_current_record_status;

EXCEPTION
  WHEN OTHERS THEN
        arp_standard.debug('Exception in JE_INTERFACE_VAL.AR_BUSINESS_RULES()');
        arp_standard.debug(SQLERRM);
END ar_business_rules;



PROCEDURE je_gr_arxcudci_cust_txid
(   p_glob_attr_set1                  IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set2                  IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set3                  IN jg_globe_flex_val_shared.GdfRec,
    p_misc_prod_arg                   IN jg_globe_flex_val_shared.GenRec,
    p_record_status                   OUT NOCOPY VARCHAR2)
IS

dummy_code NUMBER;
l_error_code  varchar2(50) :='';
l_row_id  ROWID := p_misc_prod_arg.core_prod_arg2;

BEGIN
IF p_glob_attr_set1.global_attribute1 IS NOT NULL THEN
  BEGIN
    SELECT 1
    INTO dummy_code
    FROM fnd_lookups
    WHERE lookup_code=p_glob_attr_set1.global_attribute1
    AND  lookup_type = 'YES_NO'
    AND NVL(START_DATE_ACTIVE,SYSDATE) <= SYSDATE
    AND NVL(END_DATE_ACTIVE,SYSDATE) >= SYSDATE
    AND ENABLED_FLAG = 'Y';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_error_code := l_error_code||'i2,';
  END;
ELSE
  l_error_code := l_error_code||'i2,';
END IF;

IF l_error_code IS NULL THEN
   p_record_status := 'S';
ELSE
   p_record_status := 'E';
   jg_globe_flex_val_shared.update_interface_status
   (l_row_id,
    'RA_CUSTOMERS_INTERFACE',
    l_error_code,
    p_record_status);
END IF;
END je_gr_arxcudci_cust_txid;




PROCEDURE je_zz_arxcudci_site_uses
(   p_glob_attr_set1                  IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set2                  IN jg_globe_flex_val_shared.GdfRec,
    p_glob_attr_set3                  IN jg_globe_flex_val_shared.GdfRec,
    p_misc_prod_arg                   IN jg_globe_flex_val_shared.GenRec,
    p_record_status                   OUT NOCOPY VARCHAR2)
IS

dummy_code NUMBER;
l_error_code  varchar2(50) :='';
l_row_id  ROWID := p_misc_prod_arg.core_prod_arg2;

BEGIN
IF p_glob_attr_set3.global_attribute1 IS NOT NULL THEN
  BEGIN
    SELECT 1
    INTO dummy_code
    FROM fnd_lookups
    WHERE lookup_code=p_glob_attr_set3.global_attribute1
    AND  lookup_type = 'YES_NO'
    AND NVL(START_DATE_ACTIVE,SYSDATE) <= SYSDATE
    AND NVL(END_DATE_ACTIVE,SYSDATE) >= SYSDATE
    AND ENABLED_FLAG = 'Y';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_error_code := l_error_code||'p3,';
  END;
ELSE
  l_error_code := l_error_code||'p3,';
END IF;

IF l_error_code IS NULL THEN
   p_record_status := 'S';
ELSE
   p_record_status := 'E';
   jg_globe_flex_val_shared.update_interface_status
   (l_row_id,
    'RA_CUSTOMERS_INTERFACE',
    l_error_code,
    p_record_status);
END IF;
END je_zz_arxcudci_site_uses;


END JE_INTERFACE_VAL;

/
