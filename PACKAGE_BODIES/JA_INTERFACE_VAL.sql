--------------------------------------------------------
--  DDL for Package Body JA_INTERFACE_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_INTERFACE_VAL" AS
/* $Header: jgjagdfb.pls 120.5 2005/07/17 18:25:08 ykonishi ship $ */
-----------------------------------------------------------------
--                    Payables Business Rules                  --
-----------------------------------------------------------------
PROCEDURE ap_business_rules
     (p_calling_program_name            IN    VARCHAR2,
      p_set_of_books_id                 IN    NUMBER,
      p_invoice_date                    IN    DATE,
      p_parent_table                    IN    VARCHAR2,
      p_parent_id                       IN    NUMBER,
      p_default_last_updated_by         IN    NUMBER,
      p_default_last_update_login       IN    NUMBER,
      p_global_attribute_category       IN    VARCHAR2,
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

    l_credit_exists		VARCHAR2(1);
    l_current_invoice_status 	VARCHAR2(1);
    l_debug_loc			VARCHAR2(100);
    l_curr_calling_sequence         VARCHAR2(2000);
    l_debug_info                    VARCHAR2(100);
  BEGIN
    l_current_invoice_status 	:= 'Y';
    l_debug_loc			:= 'ap_business_rules';
  -------------------------- DEBUG INFORMATION ------------------------------------------
  l_curr_calling_sequence := 'ja_interface_val.'||l_debug_loc||'<-'||p_calling_sequence;
  l_debug_info := 'Check Asia Pacific business rules';
  ---------------------------------------------------------------------------------------

  --------------------------------------------------------------------------------------
  --                         Global Flexfield Validation
  --------------------------------------------------------------------------------------
  --  You can add your own validation code for your global flexfields.
  --  You should not include arguments(GLOBAL_ATTRIBUTE(n)) you do not validate
  --  in your procedure.

  --  Form Name: APXIISIM
  --------------------------------------------------------------------------------------
  --   Header Level Validation - Block Name: INVOICES_FOLDER
  --------------------------------------------------------------------------------------
  --    1-1. JA.KR.APXIISIM.INVOICES_FOLDER
  --    1-2. JA.CN.APXIISIM.INVOICES_FOLDER
  --    1-3. JA.TH.APXIISIM.INVOICES_INTF
  --    1-4. JA.TW.APXIISIM.INVOICES_FOLDER
  --    1-5. JA.SG.APXIISIM.INVOICES_FOLDER
  --------------------------------------------------------------------------------------
  --   Line Level Validation   - Block Name: INVOICE_LINES_FOLDER
  --------------------------------------------------------------------------------------
  --    2-1. JA.KR.APXIISIM.LINES_FOLDER
  --    2-2. JA.CA.APXIISIM.LINES_FOLDER
  --------------------------------------------------------------------------------------

  --
  --    1-1. JA.KR.APXIISIM.INVOICES_FOLDER
  --
  IF (p_global_attribute_category = 'JA.KR.APXIISIM.INVOICES_FOLDER') THEN
    ja_kr_apxiisim_invoices_folder(
          p_parent_id,
          p_default_last_updated_by,
          p_default_last_update_login,
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
  --    1-2. JA.CN.APXIISIM.INVOICES_FOLDER
  --
  ELSIF (p_global_attribute_category = 'JA.CN.APXIISIM.INVOICES_FOLDER') THEN
    ja_cn_apxiisim_invoices_folder(
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
  --    1-3. JA.TH.APXIISIM.INVOICES_FOLDER
  --
  ELSIF (p_global_attribute_category = 'JA.TH.APXIISIM.INVOICES_INTF') THEN
    ja_th_apxiisim_invoices_folder(
          p_set_of_books_id,
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
  --    1-4. JA.TW.APXIISIM.INVOICES_FOLDER
  --
  ELSIF (p_global_attribute_category = 'JA.TW.APXIISIM.INVOICES_FOLDER') THEN
    ja_tw_apxiisim_invoices_folder(
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
  --    1-5. JA.SG.APXIISIM.INVOICES_FOLDER
  --
  ELSIF (p_global_attribute_category = 'JA.SG.APXIISIM.INVOICES_FOLDER') THEN
    ja_sg_apxiisim_invoices_folder(
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
  --    2-1. JA.KR.APXIISIM.LINES_FOLDER
  --
  ELSIF (p_global_attribute_category = 'JA.KR.APXIISIM.LINES_FOLDER') THEN
    ja_kr_apxiisim_lines_folder(
          p_parent_id,
          p_default_last_updated_by,
          p_default_last_update_login,
          p_global_attribute1,
          p_global_attribute2,
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
  --    2-2. JA.CA.APXIISIM.LINES_FOLDER
  --
  ELSIF (p_global_attribute_category = 'JA.CA.APXIISIM.LINES_FOLDER') THEN
    ja_ca_apxiisim_lines_folder (
         p_set_of_books_id,
         p_invoice_date,
         p_parent_id,
         p_default_last_updated_by,
         p_default_last_update_login,
         p_global_attribute1,
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

END ap_business_rules;

  --------------------------------------------------------------------------------------
  --    JA_KR_APXIISIM_INVOICES_FOLDER()
  --------------------------------------------------------------------------------------
  --    There is no global flexfield in R11i, so we don't provide any validation for
  --    Invoice Gateway.
  --------------------------------------------------------------------------------------
  PROCEDURE  ja_kr_apxiisim_invoices_folder(
          p_parent_id                         IN     NUMBER,
          p_default_last_updated_by           IN     NUMBER,
          p_default_last_update_login         IN     NUMBER,
          p_global_attribute13                IN     VARCHAR2,
          p_global_attribute14                IN     VARCHAR2,
          p_global_attribute15                IN     VARCHAR2,
          p_global_attribute16                IN     VARCHAR2,
          p_global_attribute17                IN     VARCHAR2,
          p_global_attribute18                IN     VARCHAR2,
          p_global_attribute19                IN     VARCHAR2,
          p_global_attribute20                IN     VARCHAR2,
          p_current_invoice_status            OUT NOCOPY    VARCHAR2,
          p_calling_sequence                  IN     VARCHAR2) IS

  BEGIN
      null;
  END ja_kr_apxiisim_invoices_folder;

  --------------------------------------------------------------------------------------
  --    JA_CN_APXIISIM_INVOICES_FOLDER()
  --------------------------------------------------------------------------------------
  --    There is no global flexfield in R11i, so we don't provide any validation for
  --    Invoice Gateway.
  --------------------------------------------------------------------------------------
  PROCEDURE ja_cn_apxiisim_invoices_folder
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
    null;
  END ja_cn_apxiisim_invoices_folder;

  --------------------------------------------------------------------------------------
  --    JA_TH_APXIISIM_INVOICES_FOLDER()
  --------------------------------------------------------------------------------------
  --    Following segments are defined for Thai Invoice Interface:
  --------------------------------------------------------------------------------------
  --    No. Name                       Column             Value Set         Required
  --    --- -------------------------- ------------------ ----------------- ------------
  --     1 Tax Invoice Number          GLOBAL_ATTRIBUTE1                    No
  --     2 Tax Invoice Date            GLOBAL_ATTRIBUTE2  FND_STANDARD_DATE No
  --     3 Supplier Tax Invoice Number GLOBAL_ATTRIBUTE3                    No
  --     4 Tax Accounting Period       GLOBAL_ATTRIBUTE4  JATH_AP_TAX_ACCT_PERIOD No
  --------------------------------------------------------------------------------------
  PROCEDURE ja_th_apxiisim_invoices_folder
     (p_set_of_books_id                 IN    NUMBER,
      p_parent_id                       IN    NUMBER,
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

      l_tax_acct_per_exists    VARCHAR2(1);
      l_tax_inv_date           DATE;


  BEGIN

     IF (p_global_attribute2 IS NOT NULL) THEN

       -- Check if Tax Invoice Date is of Standard Date Format

       BEGIN
         SELECT fnd_date.canonical_to_date(p_global_attribute2)
           INTO l_tax_inv_date
         FROM dual;
       EXCEPTION
         WHEN OTHERS THEN
                   jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                     p_parent_id,
                                     'INVALID_GLOBAL_ATTR2',
                                     p_default_last_updated_by,
                                     p_default_last_update_login,
                                     p_calling_sequence);
         p_current_invoice_status := 'N';
       END;

       -- Supplier Tax Invoice Number and Tax Accounting Period fields are required
       -- if Tax Invoice Date is entered

       IF (p_global_attribute3 IS NULL) THEN
                   jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                     p_parent_id,
                                     'INVALID_GLOBAL_ATTR3',
                                     p_default_last_updated_by,
                                     p_default_last_update_login,
                                     p_calling_sequence);
         p_current_invoice_status := 'N';
       END IF;

       IF (p_global_attribute4 IS NULL) THEN
                   jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                     p_parent_id,
                                     'INVALID_GLOBAL_ATTR4',
                                     p_default_last_updated_by,
                                     p_default_last_update_login,
                                     p_calling_sequence);
          p_current_invoice_status := 'N';

       END IF;

  END IF;

       IF (p_global_attribute2 is not null and p_global_attribute4 is not null) then

         -- Check is Tax Accounting Period is an Open or Future Period

         BEGIN
           SELECT NULL
             INTO l_tax_acct_per_exists
           FROM dual
           WHERE p_global_attribute4 in
               (select period_name
                from gl_period_statuses
                where application_id=200
                and set_of_books_id = p_set_of_books_id
                and closing_status in ('O','F')
                and adjustment_period_flag = 'N'
                and end_date >= fnd_date.canonical_to_date(p_global_attribute2));
         EXCEPTION
           WHEN OTHERS THEN
                   jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                     p_parent_id,
                                     'INVALID_GLOBAL_ATTR4',
                                     p_default_last_updated_by,
                                     p_default_last_update_login,
                                     p_calling_sequence);
            p_current_invoice_status := 'N';
         END ;

       END IF;



 -- Global attributes 5 through 20 checked for rejection
       IF  ((p_global_attribute5  IS NOT NULL) OR
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
  END ja_th_apxiisim_invoices_folder;

  --------------------------------------------------------------------------------------
  --    JA_TW_APXIISIM_INVOICES_FOLDER()
  --------------------------------------------------------------------------------------
  --    Following segments are defined for Taiwanese Invoice Interface:
  --------------------------------------------------------------------------------------
  --    No. Name                       Column             Value Set            Required
  --    --- -------------------------- ------------------ -------------------- ---------
  --      1 Invoice Format             GLOBAL_ATTRIBUTE1  JA_TW_AP_GUI_FORMAT  No
  --      2 Wine/Cigarette             GLOBAL_ATTRIBUTE2  AP_SRS_YES_NO_OPT    No
  --      3 Deductible Flag            GLOBAL_ATTRIBUTE3  JATW_AP_DEDUCTIBLE   No
  --------------------------------------------------------------------------------------
  PROCEDURE ja_tw_apxiisim_invoices_folder
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
      IF (p_global_attribute1 NOT IN ('21','22','23','24','25','26','27','28')) THEN
                  jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                    p_parent_id,
                                    'INVALID_GLOBAL_ATTR1',
                                    p_default_last_updated_by,
                                    p_default_last_update_login,
                                    p_calling_sequence);
        p_current_invoice_status := 'N';
      END IF;

      IF (p_global_attribute2 NOT IN ('Y','N')) THEN
                  jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                    p_parent_id,
                                    'INVALID_GLOBAL_ATTR2',
                                    p_default_last_updated_by,
                                    p_default_last_update_login,
                                    p_calling_sequence);
        p_current_invoice_status := 'N';
      END IF;

      IF (p_global_attribute3 NOT IN ('1','2')) THEN
                  jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                    p_parent_id,
                                    'INVALID_GLOBAL_ATTR3',
                                    p_default_last_updated_by,
                                    p_default_last_update_login,
                                    p_calling_sequence);
        p_current_invoice_status := 'N';
      END IF;

/*
      DECLARE
        X_temp varchar2(30);
      BEGIN
        X_temp := fnd_date.canonical_to_date(p_global_attribute4);
      EXCEPTION
        WHEN OTHERS THEN
          jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                    p_parent_id,
                                    'INVALID_GLOBAL_ATTR4',
                                    p_default_last_updated_by,
                                    p_default_last_update_login,
                                    p_calling_sequence);
         p_current_invoice_status := 'N';
      END;
*/
      IF ((p_global_attribute5  IS NOT NULL) OR
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
  END ja_tw_apxiisim_invoices_folder;

  --------------------------------------------------------------------------------------
  --    JA_SG_APXIISIM_INVOICES_FOLDER()
  --------------------------------------------------------------------------------------
  --    Following segments are defined for Singapore Invoice Interface:
  --------------------------------------------------------------------------------------
  --    No. Name                       Column             Value Set            Required
  --    --- -------------------------- ------------------ -------------------- ---------
  --      1 Supplier Exchange Rate     GLOBAL_ATTRIBUTE1  FND_NUMBER15         No
  --------------------------------------------------------------------------------------
  PROCEDURE ja_sg_apxiisim_invoices_folder
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
    /* NONE - NUMBER(15),Numbers Only(0-9) */
    IF (NOT jg_globe_flex_val_shared.check_format(p_global_attribute1,'N',15,'','N','N','N','','')) THEN
                  jg_globe_flex_val_shared.insert_rejections('AP_INVOICES_INTERFACE',
                                    p_parent_id,
                                    'INVALID_GLOBAL_ATTR1',
                                    p_default_last_updated_by,
                                    p_default_last_update_login,
                                    p_calling_sequence);
        p_current_invoice_status := 'N';
    END IF;

    IF   ((p_global_attribute2  IS NOT NULL) OR
          (p_global_attribute3  IS NOT NULL) OR
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
  END ja_sg_apxiisim_invoices_folder;

  --------------------------------------------------------------------------------------
  --    JA_CA_APXIISIM_LINES_FOLDER()
  --------------------------------------------------------------------------------------
  --    There is no global flexfield in R11i, so we don't provide any validation for
  --    Invoice Gateway.
  --------------------------------------------------------------------------------------
  PROCEDURE ja_ca_apxiisim_lines_folder
     (p_set_of_books_id                 IN    NUMBER,
      p_invoice_date                    IN    DATE,
      p_parent_id                       IN    NUMBER,
      p_default_last_updated_by         IN    NUMBER,
      p_default_last_update_login       IN    NUMBER,
      p_global_attribute1               IN    VARCHAR2,
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
    null;
  END ja_ca_apxiisim_lines_folder;

  --------------------------------------------------------------------------------------
  --    JA_KR_APXIISIM_LINES_FOLDER()
  --------------------------------------------------------------------------------------
  --    There is no global flexfield in R11i, so we don't provide any validation for
  --    Invoice Gateway.
  --------------------------------------------------------------------------------------
  PROCEDURE ja_kr_apxiisim_lines_folder
     (p_parent_id                       IN    NUMBER,
      p_default_last_updated_by         IN    NUMBER,
      p_default_last_update_login       IN    NUMBER,
      p_global_attribute1               IN    VARCHAR2,
      p_global_attribute2               IN    VARCHAR2,
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
      null;
  END ja_kr_apxiisim_lines_folder;

-----------------------------------------------------------------
--                 Receivables Business Rules                  --
-----------------------------------------------------------------
PROCEDURE ar_business_rules
     (p_calling_program_name            IN    VARCHAR2,
      p_sob_id                          IN    NUMBER,
      p_row_id                          IN    VARCHAR2,
      p_customer_name                   IN    VARCHAR2,
      p_customer_number                 IN    NUMBER,
      p_jgzz_fiscal_code                IN    VARCHAR2,
      p_generate_customer_number        IN    VARCHAR2,
      p_orig_system_customer_ref        IN    VARCHAR2,
      p_insert_update_flag              IN    VARCHAR2,
      p_request_id                      IN    NUMBER,
      p_global_attribute_category       IN    VARCHAR2,
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
      p_current_record_status           OUT NOCOPY   VARCHAR2) IS

BEGIN

      p_current_record_status := 'S';

END ar_business_rules;

PROCEDURE ar_business_rules(
      p_int_table_name                  IN    VARCHAR2,
      p_glob_attr_set1                  IN    JG_GLOBE_FLEX_VAL_SHARED.GdfRec,
      p_glob_attr_set2                  IN    JG_GLOBE_FLEX_VAL_SHARED.GdfRec,
      p_glob_attr_set3                  IN    JG_GLOBE_FLEX_VAL_SHARED.GdfRec,
      p_misc_prod_arg                   IN    JG_GLOBE_FLEX_VAL_SHARED.GenRec,
      p_current_record_status           OUT NOCOPY   VARCHAR2) IS

  l_current_record_status  VARCHAR2(1);

  l_ou_id    NUMBER;

BEGIN
  l_current_record_status  := 'S';
  fnd_profile.get('ORG_ID',l_ou_id);
  IF jg_zz_shared_pkg.get_country(l_ou_id, NULL) = 'TW' THEN
    IF p_int_table_name = 'CUSTOMER' THEN
      ja_tw_arxcudci_customers(
              p_glob_attr_set1
            , p_glob_attr_set2
            , p_glob_attr_set3
            , p_misc_prod_arg
            , l_current_record_status);
    END IF;
  END IF;

  p_current_record_status := l_current_record_status;

END ar_business_rules;

PROCEDURE ja_tw_arxcudci_customers(
      p_glob_attr_set1          IN   JG_GLOBE_FLEX_VAL_SHARED.GdfRec,
      p_glob_attr_set2          IN   JG_GLOBE_FLEX_VAL_SHARED.GdfRec,
      p_glob_attr_set3          IN   JG_GLOBE_FLEX_VAL_SHARED.GdfRec,
      p_misc_prod_arg           IN   JG_GLOBE_FLEX_VAL_SHARED.GenRec,
      p_current_record_status   OUT NOCOPY  VARCHAR2) IS

  l_record_status               VARCHAR2(1);
  l_rowid                       ROWID;
  l_customer_name               VARCHAR2(50);
  l_taxpayer_id                 VARCHAR2(20);
  l_orig_system_customer_ref    VARCHAR2(240);
  l_insert_update_flag          VARCHAR(1);
  l_request_id                  NUMBER(15);
  l_tax_reg_num                 VARCHAR2(50);
  l_customer_id                 NUMBER(15);

  l_mesg_code                   VARCHAR2(50);
  l_table_name                  VARCHAR2(30);

BEGIN
/* Bug 4497198 : Stub out package body due to build error in referencing to
                 ra_customers table

  l_record_status               := 'S';
  l_rowid                       := p_misc_prod_arg.core_prod_arg2;
  l_customer_name               := p_misc_prod_arg.core_prod_arg3;
  l_taxpayer_id                 := p_misc_prod_arg.core_prod_arg5;
  l_orig_system_customer_ref    := p_misc_prod_arg.core_prod_arg7;
  l_insert_update_flag          := p_misc_prod_arg.core_prod_arg8;
  l_request_id                  := p_misc_prod_arg.core_prod_arg9;
  l_tax_reg_num                 := p_misc_prod_arg.core_prod_arg10;

  l_table_name                  := 'RA_CUSTOMERS_INTERFACE';

  --
  -- ** Index **
  -- 0. Get Customer ID for Uniqueness Check
  -- 1. Validate Taxpayer ID
  --   1-1. Numeric
  --   1-2. Length
  --   1-3. Uniqueness
  -- 2. Validate Tax Registration Number
  --   2-1. Numeric`
  --   2-2. Length
  --   2-3. Uniqueness
  --

  --
  -- Get Customer ID for Uniqueness Check
  --
  IF (l_insert_update_flag = 'U') THEN
    BEGIN
      SELECT
             rc.customer_id
        INTO
             l_customer_id
        FROM
             ra_customers rc
       WHERE
             rc.orig_system_reference = l_orig_system_customer_ref;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      arp_standard.debug('No data found in RA_CUSTOMERS table for Update');
    WHEN OTHERS THEN
      arp_standard.debug('Exception in ja_interface_val.ja_tw_arxcudci_customers');
      arp_standard.debug(SQLERRM);
    END;
  ELSE
    l_customer_id := 0;
  END IF;

  --
  --  ** Taxpayer ID Validation **
  --  +---------------+------+---------------------------------------------+
  --  | Validation    | Code | Message Text(Summary)                       |
  --  +---------------+------+---------------------------------------------+
  --  |1. Numeric     | k3   | Taxpayer ID should be numeric.              |
  --  |2. 8 digits    | k4   | Taxpayer ID exceeds maximum length allowed. |
  --  |3. Unique      | k5   | Duplicate Taxpayer ID.                      |
  --  +---------------+------+---------------------------------------------+

  --
  -- 1. Taxpayer ID - Numeric
  --
  IF jg_taxid_val_pkg.check_numeric(
                      l_taxpayer_id               -- Taxpayer ID
                                    ) <> 'TRUE'
  THEN
    l_mesg_code := 'k3,';
    l_record_status := 'E';
  END IF;

  --
  -- 2. Taxpayer ID - 8 digits
  --
  IF l_taxpayer_id IS NOT NULL THEN
    IF jg_taxid_val_pkg.check_length(
                       'TW'             -- Country Code
                      , 8               -- Maximum Length
                      , l_taxpayer_id   -- Taxpayer ID
                                     ) <> 'TRUE'
    THEN
      l_mesg_code := l_mesg_code || 'k4,';
      l_record_status := 'E';
    END IF;
  END IF;

  --
  -- 3. Taxpayer ID - Unique
  --
  IF jg_taxid_val_pkg.check_uniqueness(
                     'TW'                         -- Country Code
                    , l_taxpayer_id               -- Taxpayer ID
                    , l_customer_id               -- Customer ID
                    ,'RACUST'                     -- Calling Program Name
                    , l_orig_system_customer_ref  -- Unique Customer Identifier
                    , l_customer_name             -- Customer Name
                    , l_request_id                -- Request ID
                                      ) <> 'TRUE'
  THEN
    l_mesg_code := l_mesg_code || 'k5,';
    l_record_status := 'E';
  END IF;

  --
  --  ** Tax Registration Num Validation **
  --  +----------------------+---------------------------------------------+
  --  | Validation    | Code | Message Text(Summary)                       |
  --  +---------------+------+---------------------------------------------+
  --  |1. Numeric     | t5   | Tax Reg. No. should be numeric.             |
  --  |2. 9 digits    | t6   | Tax Reg. No. exceeds maximum length allowed.|
  --  |3. Unique      | t7   | Duplicate Tax Reg. No.                      |
  --  +---------------+----------------------------------------------------+

  --
  -- 1. Tax Registration Number - Numeric
  --
  IF jg_taxid_val_pkg.check_numeric(
                      l_tax_reg_num               -- Tax Registration Number
                                    ) <> 'TRUE'
  THEN
    l_mesg_code := l_mesg_code || 't5';
    l_record_status := 'E';
  END IF;

  --
  -- 2. Tax Registration Number - 9 digits
  --
  IF l_tax_reg_num IS NOT NULL THEN
    IF jg_taxid_val_pkg.check_length(
                     'TW'                         -- Country Code
                    , 9                           -- Maximum Length
                    , l_tax_reg_num               -- Tax Registration Number
                                   ) <> 'TRUE'
    THEN
      l_mesg_code := l_mesg_code || 't6';
      l_record_status := 'E';
    END IF;
  END IF;

  --
  -- 3. Tax Registration Number - Unique
  --
  IF jg_taxid_val_pkg.check_unique_tax_reg_Num(
                     'TW'                         -- Country Code
                    , l_tax_reg_num               -- Tax Registrtion Number
                    , l_customer_id               -- Customer ID
                    ,'RACUST'                     -- Calling Program Name
                    , l_orig_system_customer_ref  -- Unique Customer Identifier
                    , l_customer_name             -- Customer Name
                    , l_request_id                -- Request ID
                                      ) <> 'TRUE'
  THEN
    l_mesg_code := l_mesg_code || 't7';
    l_record_status := 'E';
  END IF;

  --
  --  Update Interface_Status of ra_customers_interface.
  --

  IF l_record_status = 'E' THEN
    jg_globe_flex_val_shared.update_interface_status(
                             l_rowid,
                             l_table_name,
                             l_mesg_code,
                             'E');
  END IF;

  --
  -- Return current status to ar_business_rules
  --
  p_current_record_status := l_record_status;
*/
NULL;
END ja_tw_arxcudci_customers;

END ja_interface_val;

/
