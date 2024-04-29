--------------------------------------------------------
--  DDL for Package Body JG_TAXID_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_TAXID_VAL_PKG" AS
/* $Header: jgzzgtib.pls 120.15.12010000.1 2008/07/28 07:57:02 appldev ship $ */
  -- Check Tax ID is numeric

  FUNCTION check_numeric(p_taxpayer_id IN VARCHAR2
  ) RETURN VARCHAR2 IS
  l_length   number(3);
  BEGIN

    l_length:=lengthb(p_taxpayer_id);
    FOR i IN 1..l_length LOOP
        IF substrb(p_taxpayer_id,i,1)=' ' THEN
           RETURN('FALSE');
        END IF;
    END LOOP;

    IF (NVL(RTRIM(TRANSLATE(p_taxpayer_id,'1234567890','        ')),'0') <> '0') THEN
       RETURN('FALSE');
    ELSE
       RETURN('TRUE');
    END IF;
  END check_numeric;

  -- Check the length for Tax ID

  FUNCTION check_length(p_country_code  IN VARCHAR2,
                        p_num_digits    IN NUMBER,
                        p_taxpayer_id   IN VARCHAR2
  ) RETURN VARCHAR2 IS
  l_max_digits  NUMBER(3);
  BEGIN
    l_max_digits:=lengthb(p_taxpayer_id);
    IF (p_country_code = 'AR' AND (l_max_digits = p_num_digits)) THEN
          RETURN('TRUE');
    ELSIF (p_country_code='CL' AND (l_max_digits <= p_num_digits)) THEN
          RETURN('TRUE');
    ELSIF (p_country_code='CO' AND (l_max_digits <= p_num_digits)) THEN
          RETURN('TRUE');
    ELSIF (p_country_code='TW' AND (l_max_digits = p_num_digits)) THEN
          RETURN('TRUE');
    ELSE
          RETURN ('FALSE');
    END IF;
  END check_length;

  -- Check Duplicate Primary Bank Branch in AP_BANK_BRANCHES

  FUNCTION check_primary_bank_branch(p_bank_branch_id     IN NUMBER,
                                     p_bank_name          IN VARCHAR2,
                                     p_bank_branch_name   IN VARCHAR2
  )RETURN VARCHAR2 IS

 l_bank_branch_id   number(15);
 l_bank_name        varchar2(60);
 l_bank_branch_name varchar2(60);

 BEGIN
  -- Stubbed out this function since ap_bank_branches is obsolete
          RETURN('TRUE');

 END check_primary_bank_branch;


  -- Check Details Bank Branch

  FUNCTION check_detail_bank_branch(p_bank_branch_id IN NUMBER
  )RETURN VARCHAR2 IS

    l_bank_branch_id   number(15);

 BEGIN

  -- Stubbed out this function since ap_bank_branches is obsolete
          RETURN('TRUE');

 END check_detail_bank_branch;

  -- Check uniqueness for Tax ID

  FUNCTION check_uniqueness (p_country_code    IN  VARCHAR2,
                             p_taxpayer_id     IN  VARCHAR2,
                             p_record_id       IN  NUMBER,
                             p_calling_program IN  VARCHAR2,
                             p_orig_system_ref IN  VARCHAR2,
                             p_entity_name     IN  VARCHAR2,
                             p_request_id      IN  NUMBER
  			    ) RETURN VARCHAR2 IS

  CURSOR CHECK_UNIQUE_TAXID_AR IS       -- Customers for Argentina, Chile, and Colombia
    SELECT hzp.JGZZ_FISCAL_CODE
    FROM   hz_parties hzp, hz_cust_accounts hzc
    WHERE hzp.JGZZ_FISCAL_CODE = p_taxpayer_id
    AND   hzc.party_id = hzp.party_id
    AND   hzc.CUST_ACCOUNT_ID <> nvl(p_record_id,0)
    AND   substrb(nvl(HZC.GLOBAL_ATTRIBUTE_CATEGORY,'XX.XX'),4,2) = p_country_code;

  CURSOR CHECK_UNIQUE_TAXID_AR_TW IS    -- Customers for Taiwan
    SELECT hzp.JGZZ_FISCAL_CODE
    FROM   hz_parties hzp, hz_cust_accounts hzc
    WHERE hzp.JGZZ_FISCAL_CODE = p_taxpayer_id
    AND   hzc.party_id = hzp.party_id
    AND   hzc.CUST_ACCOUNT_ID <> nvl(p_record_id,0);

  CURSOR CHECK_UNIQUE_TAXID_AP IS       -- Suppliers

    -- TIN Project bug6063219
    /*
    SELECT AP.NUM_1099 FROM ap_suppliers AP
    WHERE  AP.NUM_1099 = p_taxpayer_id
    AND AP.VENDOR_ID<>nvl(p_record_id,0)
    AND substrb(nvl(AP.GLOBAL_ATTRIBUTE_CATEGORY,'XX.XX'),4,2) = p_country_code;
    */
    SELECT decode(ap.vendor_type_lookup_code,'Contractor',
                    decode(ap.organization_type_lookup_code,'INDIVIDUAL',AP.INDIVIDUAL_1099,
                                 'FOREIGN INDIVIDUAL',AP.INDIVIDUAL_1099,
                                 'PARTNERSHIP',AP.INDIVIDUAL_1099,
                                 'FOREIGN PARTNERSHIP',AP.INDIVIDUAL_1099,
                           AP.NUM_1099),
                 AP.NUM_1099) NUM_1099
     FROM PO_VENDORS AP
    WHERE  decode(ap.vendor_type_lookup_code,'Contractor',
                    decode(ap.organization_type_lookup_code,'INDIVIDUAL',AP.INDIVIDUAL_1099,
                                 'FOREIGN INDIVIDUAL',AP.INDIVIDUAL_1099,
                                 'PARTNERSHIP',AP.INDIVIDUAL_1099,
                                 'FOREIGN PARTNERSHIP',AP.INDIVIDUAL_1099,
                           AP.NUM_1099),
                 AP.NUM_1099) = p_taxpayer_id
    AND AP.VENDOR_ID <> nvl(p_record_id,0)
    AND substrb(nvl(AP.GLOBAL_ATTRIBUTE_CATEGORY,'XX.XX'),4,2) = p_country_code;

  -- Company Uniqueness of tax payer id is done by XLE.
  -- Removed cursor for Company on HR Locations
  -- Removed cursor to check on ap_bank_branches

  CURSOR CHECK_UNIQUE_TAXID_AR1 IS       -- CUSTOMERS
      SELECT hzp.JGZZ_FISCAL_CODE
      FROM   hz_parties hzp, hz_cust_accounts hzc
      WHERE  hzp.JGZZ_FISCAL_CODE = p_taxpayer_id
      AND    hzc.CUST_ACCOUNT_ID <> nvl(p_record_id,0)
      AND    jg_zz_shared_pkg.get_country(fnd_profile.value('ORG_ID'), NULL) = p_country_code
      -- Modified for Countries w/o GDF
   UNION
      SELECT I.JGZZ_FISCAL_CODE		-- RA_CUSTOMERS_INTERFACE
      FROM   RA_CUSTOMERS_INTERFACE I
      WHERE ( I.CUSTOMER_NAME <> p_entity_name
       OR     I.ORIG_SYSTEM_CUSTOMER_REF <> p_orig_system_ref)
      AND I.JGZZ_FISCAL_CODE = p_taxpayer_id
      AND jg_zz_shared_pkg.get_country(fnd_profile.value('ORG_ID'), NULL) = p_country_code
      -- Modified for Countries w/o GDF
      AND I.REQUEST_ID = p_request_id
      AND NVL(I.VALIDATED_FLAG,'N') <> 'Y'
      AND ROWNUM = 1;

  l_taxid        VARCHAR2(30);

  BEGIN

    -- Checking for Tax ID used by a different Customer

    IF p_calling_program = 'ARXCUDCI' THEN
      IF p_country_code = 'TW' THEN
         OPEN CHECK_UNIQUE_TAXID_AR_TW;
         FETCH CHECK_UNIQUE_TAXID_AR_TW INTO l_taxid;
         IF (CHECK_UNIQUE_TAXID_AR_TW%NOTFOUND) THEN
            RETURN('TRUE');
         ELSE
            RETURN('FALSE');
         END IF;
         CLOSE CHECK_UNIQUE_TAXID_AR_TW;
      ELSE
         OPEN CHECK_UNIQUE_TAXID_AR;
         FETCH CHECK_UNIQUE_TAXID_AR INTO l_taxid;
         IF (CHECK_UNIQUE_TAXID_AR%NOTFOUND) THEN
            RETURN('TRUE');
         ELSE
            RETURN('FALSE');
         END IF;
         CLOSE CHECK_UNIQUE_TAXID_AR;
      END IF;

    -- Checking for Tax ID used by a different Supplier

    ELSIF p_calling_program ='APXVDMVD' THEN
       OPEN CHECK_UNIQUE_TAXID_AP;
       FETCH CHECK_UNIQUE_TAXID_AP INTO l_taxid;

       IF (CHECK_UNIQUE_TAXID_AP%NOTFOUND) THEN
          RETURN('TRUE');
       ELSE
          RETURN('FALSE');
       END IF;
       CLOSE CHECK_UNIQUE_TAXID_AP;

    -- Checking for Tax ID used by a different Company
    -- Tax payer id for Company is done by XLE
    -- stubbed out because of ap_bank_branches

    -- Checking for Duplicate Tax ID in RA_CUSTOMERS and RA_CUSTOMERS_INTERFACE Tables

    ELSIF p_calling_program = 'RACUST' THEN
       OPEN CHECK_UNIQUE_TAXID_AR1;
       FETCH CHECK_UNIQUE_TAXID_AR1 INTO l_taxid;
       IF (CHECK_UNIQUE_TAXID_AR1%NOTFOUND) THEN
          RETURN('TRUE');
       ELSE
          RETURN('FALSE');
       END IF;
       CLOSE CHECK_UNIQUE_TAXID_AR1;
    END IF;

  END check_uniqueness;

  FUNCTION check_unique_tax_reg_num (p_country_code    IN  VARCHAR2,
                                     p_tax_reg_num     IN  VARCHAR2,
                                     p_record_id       IN  NUMBER,
                                     p_calling_program IN  VARCHAR2,
                                     p_orig_system_ref IN  VARCHAR2,
                                     p_entity_name     IN  VARCHAR2,
                                     p_request_id      IN  NUMBER
                                    ) RETURN VARCHAR2 IS
/*
  CURSOR CHECK_UNIQUE_TAX_REG_NUM_AR IS       -- Customers
    SELECT AR.TAX_REFERENCE
    FROM RA_CUSTOMERS AR
    WHERE  AR.TAX_REFERENCE = p_tax_reg_num
    AND AR.CUSTOMER_ID <>nvl(p_record_id,0)
    AND substrb(nvl(AR.GLOBAL_ATTRIBUTE_CATEGORY,'XX.XX'),4,2) = p_country_code;

  CURSOR CHECK_UNIQUE_TAX_REG_NUM_AP IS       -- Suppliers
    SELECT AP.VAT_REGISTRATION_NUM FROM PO_VENDORS AP
    WHERE  AP.VAT_REGISTRATION_NUM = p_tax_reg_num
    AND AP.VENDOR_ID<>nvl(p_record_id,0)
    AND substrb(nvl(AP.GLOBAL_ATTRIBUTE_CATEGORY,'XX.XX'),4,2) = p_country_code;

  CURSOR CHECK_UNIQUE_TAX_REG_NUM_AR1 IS       -- RA_CUSTOMERS
    SELECT AR.TAX_REFERENCE
    FROM   RA_CUSTOMERS AR
    WHERE  AR.TAX_REFERENCE = p_tax_reg_num
    AND AR.CUSTOMER_ID <> nvl(p_record_id,0)
    AND jg_zz_shared_pkg.get_country(fnd_profile.value('ORG_ID'), NULL) = p_country_code  -- Modified for Countries w/o GDF
   UNION

    SELECT I.CUST_TAX_REFERENCE           -- RA_CUSTOMERS_INTERFACE
    FROM   RA_CUSTOMERS_INTERFACE I
    WHERE ( I.CUSTOMER_NAME <> p_entity_name
     OR     I.ORIG_SYSTEM_CUSTOMER_REF <> p_orig_system_ref)
    AND I.CUST_TAX_REFERENCE = p_tax_reg_num
    AND jg_zz_shared_pkg.get_country(fnd_profile.value('ORG_ID'), NULL) = p_country_code  -- Modified for Countries w/o GDF
    AND I.REQUEST_ID = p_request_id
    AND NVL(I.VALIDATED_FLAG,'N') <> 'Y'
    AND ROWNUM = 1;

  l_tax_reg_num        VARCHAR2(50);
*/

  BEGIN

  RETURN('TRUE'); -- Bug 4474699: Stub out

/*
    -- Checking for Tax Registration Number used by a different Customer

    IF p_calling_program = 'ARXCUDCI' THEN
       OPEN CHECK_UNIQUE_TAX_REG_NUM_AR;
       FETCH CHECK_UNIQUE_TAX_REG_NUM_AR INTO l_tax_reg_num;
       IF (CHECK_UNIQUE_TAX_REG_NUM_AR%NOTFOUND) THEN
          RETURN('TRUE');
       ELSE
          RETURN('FALSE');
       END IF;
       CLOSE CHECK_UNIQUE_TAX_REG_NUM_AR;

    -- Checking for Tax Registration Number used by a different Supplier

    ELSIF p_calling_program ='APXVDMVD' THEN
       OPEN CHECK_UNIQUE_TAX_REG_NUM_AP;
       FETCH CHECK_UNIQUE_TAX_REG_NUM_AP INTO l_tax_reg_num;

       IF (CHECK_UNIQUE_TAX_REG_NUM_AP%NOTFOUND) THEN
          RETURN('TRUE');
       ELSE
          RETURN('FALSE');
       END IF;
       CLOSE CHECK_UNIQUE_TAX_REG_NUM_AP;

    -- Checking for Duplicate Tax Registration Number in RA_CUSTOMERS
    -- and RA_CUSTOMERS_INTERFACE Tables

    ELSIF p_calling_program = 'RACUST' THEN
       OPEN CHECK_UNIQUE_TAX_REG_NUM_AR1;
       FETCH CHECK_UNIQUE_TAX_REG_NUM_AR1 INTO l_tax_reg_num;
       IF (CHECK_UNIQUE_TAX_REG_NUM_AR1%NOTFOUND) THEN
          RETURN('TRUE');
       ELSE
          RETURN('FALSE');
       END IF;
       CLOSE CHECK_UNIQUE_TAX_REG_NUM_AR1;

    END IF;
*/

  END;

  -- Check the cross validation
  -- This procedure depending upon the current module (say for example if
  -- current module is AP) checks in AR and HR to see if the TAX ID entered
  -- for the Supplier is used  by a Customer or a Company.
  -- If it is used then the Customer name or the Company name should match
  -- with the Supplier name and also the Tax ID Type should match.
  -- Depending upon the different combinations different error codes are
  -- returned to the calling program.
  -- The messages codes that send the procedure are:
  --   ap1  Tax ID is used by a different Bank
  --   ap2  Tax ID is used by a different Customer
  --   ap3  Tax ID is used by a different Company
  --   ap4  Supplier exists as a Customer with different Tax ID or Tax ID Type
  --   ap5  Supplier exists as a Company with different Tax ID or Tax ID Type
  --   ap6  Supplier exists as a Bank with different Tax ID or Tax ID Type
  --   k6   Tax ID is used by a different Supplier
  --   k7   Tax ID is used by a different Company
  --   k8   Customer exists as a Supplier with different Tax ID or Tax ID Type
  --   k9   Customer exists as a Company with different Tax ID or Tax ID Type
  --   l1   Tax ID is used by a different Bank
  --   l2   Customer exists as a Bank with different Tax ID or Tax ID Type
  --   hr1  Tax ID is used by a different Bank
  --   hr2  Tax ID is used by a different Supplier
  --   hr3  Tax ID is used by a different Customer
  --   hr4  Company exists as a Supplier with different Tax ID or Tax ID Type
  --   hr5  Company exists as a Customer with different Tax ID or Tax ID Type
  --   hr6  Company exists as a Bank with different Tax ID or Tax ID Type
  --   bk1  Tax ID is used by a different Company
  --   bk2  Tax ID is used by a different Customer
  --   bk3  Tax ID is used by a different Supplier
  --   bk4  Bank exists as a Customer with different Tax ID or Tax ID Type
  --   bk5  Bank exists as a Supplier with different Tax ID or Tax ID Type
  --   bk6  Bank exists as a Company with different Tax ID or Tax ID Type

  PROCEDURE check_cross_module(p_country_code     IN  VARCHAR2,
                               p_entity_name      IN  VARCHAR2,
                               p_taxpayer_id      IN  VARCHAR2,
                               p_origin           IN  VARCHAR2,
                               p_taxid_type       IN  VARCHAR2,
                               p_calling_program  IN  VARCHAR2,
                               p_return_ar        OUT NOCOPY VARCHAR2,
                               p_return_ap        OUT NOCOPY VARCHAR2,
                               p_return_hr        OUT NOCOPY VARCHAR2,
                               p_return_bk        OUT NOCOPY VARCHAR2
  ) IS

  CURSOR CHECK_CROSS_AP IS    --Suppliers

    -- TIN Project bug6063219
    /*
    SELECT AP.VENDOR_NAME, AP.NUM_1099,AP.GLOBAL_ATTRIBUTE9,
           AP.GLOBAL_ATTRIBUTE10 FROM AP_SUPPLIERS AP
    WHERE  (AP.VENDOR_NAME=p_entity_name
            OR  AP.NUM_1099= p_taxpayer_id)
      AND substrb(nvl(AP.GLOBAL_ATTRIBUTE_CATEGORY,'XX.XX'),4,2) = p_country_code;
    */
    SELECT AP.VENDOR_NAME,
           decode(ap.vendor_type_lookup_code,'Contractor',
                    decode(ap.organization_type_lookup_code,'INDIVIDUAL',AP.INDIVIDUAL_1099,
                                 'FOREIGN INDIVIDUAL',AP.INDIVIDUAL_1099,
                                 'PARTNERSHIP',AP.INDIVIDUAL_1099,
                                 'FOREIGN PARTNERSHIP',AP.INDIVIDUAL_1099,
                           AP.NUM_1099),
                 AP.NUM_1099) NUM_1099,
           AP.GLOBAL_ATTRIBUTE9,
           AP.GLOBAL_ATTRIBUTE10 FROM PO_VENDORS AP
    WHERE  (AP.VENDOR_NAME=p_entity_name
    OR     decode(ap.vendor_type_lookup_code,'Contractor',
                    decode(ap.organization_type_lookup_code,'INDIVIDUAL',AP.INDIVIDUAL_1099,
                                 'FOREIGN INDIVIDUAL',AP.INDIVIDUAL_1099,
                                 'PARTNERSHIP',AP.INDIVIDUAL_1099,
                                 'FOREIGN PARTNERSHIP',AP.INDIVIDUAL_1099,
                           AP.NUM_1099),
                 AP.NUM_1099) = p_taxpayer_id)
    AND substrb(nvl(AP.GLOBAL_ATTRIBUTE_CATEGORY,'XX.XX'),4,2) = p_country_code;

 CURSOR CHECK_CROSS_AR IS    --Customers
    SELECT HZP.PARTY_NAME, HZP.JGZZ_FISCAL_CODE,
           HZC.GLOBAL_ATTRIBUTE9, HZC.GLOBAL_ATTRIBUTE10
    FROM HZ_PARTIES HZP, HZ_CUST_ACCOUNTS HZC
    WHERE  (HZP.PARTY_NAME=p_entity_name
            OR  HZP.JGZZ_FISCAL_CODE=p_taxpayer_id)
    AND substrb(nvl(HZC.GLOBAL_ATTRIBUTE_CATEGORY,'XX.XX'),4,2)=p_country_code
    AND HZP.PARTY_ID = HZC.PARTY_ID;

  CURSOR CHECK_CROSS_HR IS    --Companies
    SELECT LEGAL_ENTITY_NAME, REGISTRATION_NUMBER
    FROM   XLE_REGISTRATIONS_V -- Coud use this view XLE_LE_FROM_REGISTRATIONS_V
    WHERE  (LEGAL_ENTITY_NAME = p_entity_name
            OR REGISTRATION_NUMBER = p_taxpayer_id)
    AND    Legislative_Category = 'INCOME_TAX'
    AND    COUNTRY = p_country_code;

/*
 Remove cursor for AP_BANK_BRANCHES because it is obsolete
*/


  l_taxid       VARCHAR2(30);
  l_origin      VARCHAR2(150);
  l_taxid_type  VARCHAR2(150);
  l_entity_name VARCHAR2(240); -- utf8 changes bug # 2598519

  BEGIN

    -- Initialize p_return_bk

         p_return_bk:='NA';

    -- Checking the cross module for Suppliers
    IF p_calling_program='APXVDMVD' THEN

       -- Checking cross module Suppliers/Customers

       OPEN CHECK_CROSS_AR;
       FETCH CHECK_CROSS_AR INTO l_entity_name, l_taxid, l_origin, l_taxid_type;

       IF CHECK_CROSS_AR%NOTFOUND THEN
          p_return_ar:='SUCCESS';

       ELSIF (l_taxid IS NULL AND l_entity_name = p_entity_name) THEN
             p_return_ar:='SUCCESS';

       ELSIF (l_taxid IS NOT NULL) THEN

         IF (p_country_code = 'AR' AND l_entity_name = p_entity_name
            AND l_taxid = p_taxpayer_id  AND l_taxid_type=p_taxid_type AND l_origin = p_origin )
            OR (p_country_code in ('CL','CO') AND l_entity_name = p_entity_name
            AND l_taxid=p_taxpayer_id  AND l_taxid_type = p_taxid_type) THEN

            p_return_ar:='SUCCESS';

         -- Check if Tax ID is used by a different Customer

         ELSIF (l_entity_name<>p_entity_name AND l_taxid=p_taxpayer_id) THEN

               p_return_ar:='ap2';

         -- Check if Supplier exists as Customer with different TAX ID or Tax ID
         -- Type

         ELSIF (p_country_code = 'AR' AND l_entity_name=p_entity_name
               AND (l_taxid<>p_taxpayer_id or l_taxid_type <>p_taxid_type or l_origin <> p_origin))
           OR  (p_country_code in ('CL','CO') AND l_entity_name=p_entity_name
                AND (l_taxid<>p_taxpayer_id or l_taxid_type <>p_taxid_type ))THEN

                p_return_ar:='ap4';

         END IF;

      END IF;

       CLOSE CHECK_CROSS_AR;

       -- Checking cross module Suppliers/Companies

       IF p_country_code='AR' THEN
          l_taxid_type:='80';
          l_origin:='DOMESTIC_ORIGIN';
       ELSIF p_country_code ='CL' THEN
          l_taxid_type:='DOMESTIC_ORIGIN';
       ELSIF p_country_code='CO' THEN
          l_taxid_type:='LEGAL_ENTITY';
       END IF;

       OPEN CHECK_CROSS_HR;
       FETCH CHECK_CROSS_HR INTO l_entity_name, l_taxid;

       IF CHECK_CROSS_HR%NOTFOUND  THEN
          p_return_hr:='SUCCESS';

       ELSIF (l_taxid IS NULL  AND l_entity_name=p_entity_name) THEN
             p_return_ar:='SUCCESS';

       ELSIF (l_taxid IS NOT NULL) THEN

         IF (p_country_code = 'AR' AND l_entity_name=p_entity_name
             AND l_taxid=p_taxpayer_id  AND l_taxid_type=p_taxid_type AND l_origin = p_origin )
         OR (p_country_code in ('CL','CO') AND l_entity_name=p_entity_name
             AND l_taxid=p_taxpayer_id  AND l_taxid_type=p_taxid_type) THEN

            p_return_hr:='SUCCESS';

         -- Check if Tax ID is used by a different Company
         ELSIF (l_entity_name<>p_entity_name AND l_taxid=p_taxpayer_id) THEN

               p_return_hr:='ap3';

         -- Check if Supplier exists as Company with different Tax ID or Tax ID
         -- Type

         ELSIF (p_country_code = 'AR' AND l_entity_name=p_entity_name
                AND (l_taxid<>p_taxpayer_id or l_taxid_type <>p_taxid_type or l_origin <> p_origin))
            OR (p_country_code in ('CL','CO') AND l_entity_name=p_entity_name
                AND (l_taxid<>p_taxpayer_id or l_taxid_type <>p_taxid_type ))THEN

             p_return_hr:='ap5';

         END IF;

       END IF;

       CLOSE CHECK_CROSS_HR;

       -- Commented out because of AP_BANK_BRANCHES

/*
   Removed the logic for AP_BANK_BRANCHES since table is obsolete
*/

      -- Since the current module is AP, there is no validation for AP.
      -- So returning the OUT variable as 'NA'(Not Applicable).
      p_return_ap:='NA';

    --Checking the cross module for Customers

    ELSIF  (p_calling_program IN ('RACUST','ARXCUDCI')) THEN

       -- Checking cross module Customers/Suppliers
       OPEN CHECK_CROSS_AP;
       FETCH CHECK_CROSS_AP INTO l_entity_name, l_taxid, l_origin, l_taxid_type;

       IF CHECK_CROSS_AP%NOTFOUND THEN
          p_return_ap:='SUCCESS';

       ELSIF (l_taxid IS NULL  AND l_entity_name = p_entity_name) THEN
          p_return_ap:='SUCCESS';

       ELSIF (l_taxid IS NOT NULL)  THEN

         IF (p_country_code = 'AR' AND l_entity_name=p_entity_name
             AND l_taxid=p_taxpayer_id  AND l_taxid_type=p_taxid_type AND l_origin = p_origin )
         OR (p_country_code in ('CL','CO') AND l_entity_name=p_entity_name
             AND l_taxid=p_taxpayer_id  AND l_taxid_type=p_taxid_type) THEN

             p_return_ap:='SUCCESS';

         -- Check if Tax ID is used by a different Supplier

         ELSIF (l_entity_name<>p_entity_name AND l_taxid=p_taxpayer_id) THEN

               p_return_ap:='k6';

         -- Check if Customer exists as Supplier with different Tax ID or Tax ID
         -- Type

         ELSIF (p_country_code = 'AR' AND l_entity_name=p_entity_name
                AND (l_taxid<>p_taxpayer_id or l_taxid_type <>p_taxid_type or l_origin <> p_origin))
           OR  (p_country_code in ('CL','CO') AND l_entity_name=p_entity_name
                AND (l_taxid<>p_taxpayer_id or l_taxid_type <>p_taxid_type ))THEN

               p_return_ap:='k8';

         END IF;

       END IF;

       CLOSE CHECK_CROSS_AP;

     -- Checking cross module Customers/Companies

     IF p_country_code='AR' THEN
        l_taxid_type:='80';
        l_origin :='DOMESTIC_ORIGIN';
     ELSIF p_country_code ='CL' THEN
        l_taxid_type:='DOMESTIC_ORIGIN';
     ELSIF p_country_code='CO' THEN
        l_taxid_type:='LEGAL_ENTITY';
     END IF;

     OPEN CHECK_CROSS_HR;
     FETCH CHECK_CROSS_HR INTO l_entity_name, l_taxid;

     IF CHECK_CROSS_HR%NOTFOUND  THEN
        p_return_hr:='SUCCESS';

     ELSIF (l_taxid IS NULL  AND l_entity_name=p_entity_name) THEN

        p_return_hr:='SUCCESS';

     ELSIF (l_taxid IS NOT NULL) THEN

       IF (p_country_code = 'AR' AND l_entity_name=p_entity_name
           AND l_taxid=p_taxpayer_id  AND l_taxid_type=p_taxid_type AND l_origin = p_origin )
       OR (p_country_code in ('CL','CO') AND l_entity_name=p_entity_name
           AND l_taxid=p_taxpayer_id  AND l_taxid_type=p_taxid_type) THEN

           p_return_hr:='SUCCESS';

       -- Check if Tax ID is used by a different Company

       ELSIF (l_entity_name<>p_entity_name AND l_taxid=p_taxpayer_id) THEN

             p_return_hr:='k7';

       -- Check if Customer exists as Company with different Tax ID or Tax ID
       -- Type

       ELSIF (p_country_code = 'AR' AND l_entity_name=p_entity_name
              AND (l_taxid<>p_taxpayer_id or l_taxid_type <>p_taxid_type or l_origin <> p_origin))
          OR (p_country_code in ('CL','CO') AND l_entity_name=p_entity_name
              AND (l_taxid<>p_taxpayer_id or l_taxid_type <>p_taxid_type ))THEN

              p_return_hr:='k9';

       END IF;

     END IF;

     CLOSE CHECK_CROSS_HR;

      -- Remove code on ap_bank_branches
      -- Since the current module is AR, there is no validation for AR.
      -- So returning the OUT variable as 'NA'(Not Applicable).
      p_return_ar:='NA';

    --Checking the cross module for Companies

    ELSIF  (p_calling_program ='PERWSLOC') THEN

          p_return_hr:='NA';

     -- Checking the cross module for Banks
     -- This is applicable for Colombia only

    ELSIF p_calling_program='APXSUMBA' THEN

         p_return_bk:='NA';

    ELSE

     -- Since the current module is not in Colombia, there is no validation for BK.
     -- So returning the OUT variable as 'NA'(Not Applicable).
        p_return_bk:='NA';
    END IF;

  END check_cross_module;


  -- Taxpayer ID Validation

  FUNCTION check_algorithm(p_taxpayer_id        IN VARCHAR2,
                           p_country            IN VARCHAR2,
                           p_global_attribute12 IN VARCHAR2
  ) RETURN VARCHAR2 IS
  l_var1      VARCHAR2(20);
  l_val_digit VARCHAR2(2);
  l_mod_value NUMBER(2);
  BEGIN

    -- Check the Taxpayer ID Validation digit for Chile

    IF p_country='CL' THEN


       l_var1:=LPAD(p_taxpayer_id,12,'0');
       l_val_digit:=(11-MOD(((TO_NUMBER(SUBSTR(l_var1,12,1))) *2 +
                             (TO_NUMBER(SUBSTR(l_var1,11,1))) *3 +
                             (TO_NUMBER(SUBSTR(l_var1,10,1))) *4 +
                             (TO_NUMBER(SUBSTR(l_var1,9,1)))  *5 +
                             (TO_NUMBER(SUBSTR(l_var1,8,1)))  *6 +
                             (TO_NUMBER(SUBSTR(l_var1,7,1)))  *7 +
                             (TO_NUMBER(SUBSTR(l_var1,6,1)))  *2 +
                             (TO_NUMBER(SUBSTR(l_var1,5,1)))  *3 +
                             (TO_NUMBER(SUBSTR(l_var1,4,1)))  *4 +
                             (TO_NUMBER(SUBSTR(l_var1,3,1)))  *5 +
                             (TO_NUMBER(SUBSTR(l_var1,2,1)))  *6 +
                             (TO_NUMBER(SUBSTR(l_var1,1,1)))  *7),11));
      IF l_val_digit='10'THEN
         l_val_digit:='K';
      ELSIF l_val_digit = '11' THEN
         l_val_digit:='0';
      END IF;

      IF l_val_digit<> p_global_attribute12 THEN
         RETURN('FALSE');
      ELSE
         RETURN('TRUE');
      END IF;

    -- Check the Taxpayer ID Valdiation digit for Colombia

    ELSIF p_country='CO' THEN

       l_var1:=LPAD(p_taxpayer_id,15,'0');
       l_mod_value:=(MOD(((TO_NUMBER(SUBSTR(l_var1,15,1))) *3  +
                          (TO_NUMBER(SUBSTR(l_var1,14,1))) *7  +
                          (TO_NUMBER(SUBSTR(l_var1,13,1))) *13 +
                          (TO_NUMBER(SUBSTR(l_var1,12,1))) *17 +
                          (TO_NUMBER(SUBSTR(l_var1,11,1))) *19 +
                          (TO_NUMBER(SUBSTR(l_var1,10,1))) *23 +
                          (TO_NUMBER(SUBSTR(l_var1,9,1)))  *29 +
                          (TO_NUMBER(SUBSTR(l_var1,8,1)))  *37 +
                          (TO_NUMBER(SUBSTR(l_var1,7,1)))  *41 +
                          (TO_NUMBER(SUBSTR(l_var1,6,1)))  *43 +
                          (TO_NUMBER(SUBSTR(l_var1,5,1)))  *47 +
                          (TO_NUMBER(SUBSTR(l_var1,4,1)))  *53 +
                          (TO_NUMBER(SUBSTR(l_var1,3,1)))  *59 +
                          (TO_NUMBER(SUBSTR(l_var1,2,1)))  *67 +
                          (TO_NUMBER(SUBSTR(l_var1,1,1)))  *71),11));

       IF (l_mod_value IN (1,0)) THEN
          l_val_digit:=l_mod_value;
       ELSE
          l_val_digit:=11-l_mod_value;
       END IF;

       IF l_val_digit<> p_global_attribute12 THEN
          RETURN('FALSE');
       ELSE
          RETURN('TRUE');
       END IF;

   -- Check the Taxpayer ID Validation digit for Argentina

    ELSIF p_country='AR' THEN

       l_val_digit:=(11-MOD(((TO_NUMBER(SUBSTR(p_taxpayer_id,10,1))) *2 +
                             (TO_NUMBER(SUBSTR(p_taxpayer_id,9,1)))  *3 +
                             (TO_NUMBER(SUBSTR(p_taxpayer_id,8,1)))  *4 +
                             (TO_NUMBER(SUBSTR(p_taxpayer_id,7,1)))  *5 +
                             (TO_NUMBER(SUBSTR(p_taxpayer_id,6,1)))  *6 +
                             (TO_NUMBER(SUBSTR(p_taxpayer_id,5,1)))  *7 +
                             (TO_NUMBER(SUBSTR(p_taxpayer_id,4,1)))  *2 +
                             (TO_NUMBER(SUBSTR(p_taxpayer_id,3,1)))  *3 +
                             (TO_NUMBER(SUBSTR(p_taxpayer_id,2,1)))  *4 +
                             (TO_NUMBER(SUBSTR(p_taxpayer_id,1,1)))  *5),11));

      IF l_val_digit ='10' THEN
         l_val_digit:='9';
      ELSIF l_val_digit='11' THEN
         l_val_digit:='0';
      END IF;

      IF l_val_digit<> p_global_attribute12 THEN
         RETURN('FALSE');
      ELSE
         RETURN('TRUE');
      END IF;

    END IF;

  END check_algorithm;

END JG_TAXID_VAL_PKG;

/
