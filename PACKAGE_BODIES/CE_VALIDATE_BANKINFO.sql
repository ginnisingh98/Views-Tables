--------------------------------------------------------
--  DDL for Package Body CE_VALIDATE_BANKINFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_VALIDATE_BANKINFO" as
/* $Header: cevlbnkb.pls 120.34.12010000.35 2010/04/28 09:01:46 talapati ship $ */

-- bug 6856840
-- package variable to track whether bank ID needs to be mapped to Bank Num
BANK_ID_IS_NUM  BOOLEAN := FALSE;

CURSOR get_bank_num (Xi_BANK_ID NUMBER) IS
   SELECT OrgProfileBank.BANK_OR_BRANCH_NUMBER
    FROM  HZ_PARTIES   PartyBank,
          HZ_ORGANIZATION_PROFILES   OrgProfileBank,
          HZ_CODE_ASSIGNMENTS   CABank
   WHERE
          PartyBank.party_id = Xi_BANK_ID
     AND  PartyBank.PARTY_TYPE = 'ORGANIZATION'
     AND  PartyBank.status = 'A'
     AND  PartyBank.PARTY_ID = OrgProfileBank.PARTY_ID
     AND  SYSDATE BETWEEN TRUNC(OrgProfileBank.EFFECTIVE_START_DATE)
          AND NVL(TRUNC(OrgProfileBank.EFFECTIVE_END_DATE),SYSDATE)
     AND  CABank.CLASS_CATEGORY = 'BANK_INSTITUTION_TYPE'
     AND  CABank.CLASS_CODE = 'BANK'
     AND  CABank.OWNER_TABLE_NAME = 'HZ_PARTIES'
     AND  CABank.OWNER_TABLE_ID = PartyBank.PARTY_ID
     AND  NVL(CABank.status, 'A') = 'A';

-- bug 7582842 : Added private function
FUNCTION CE_DISABLE_VALIDATION RETURN BOOLEAN
AS
    l_disable VARCHAR2(1) := 'N';
BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_disable_validation');
    l_disable := nvl(FND_PROFILE.value('CE_DISABLE_BANK_VAL'),'N');
    cep_standard.debug('disable = '||l_disable);

    IF (l_disable = 'Y') THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

END CE_DISABLE_VALIDATION;

FUNCTION ce_check_numeric(check_value VARCHAR2,
                             pos_from NUMBER,
                              pos_for NUMBER)
RETURN VARCHAR2
IS
   num_check VARCHAR2(40);
BEGIN
     num_check := '1';
     num_check := nvl(
                     rtrim(
                   translate(substr(check_value,pos_from,pos_for),
                             '1234567890',
                             '          ')
                                            ), '0'
                                                        );
RETURN(num_check);
END ce_check_numeric;

-- SEPA 6700007
PROCEDURE CE_VALIDATE_BIC(  X_BIC_CODE IN varchar2,
                            p_init_msg_list  IN  VARCHAR2,
                          x_msg_count      OUT NOCOPY NUMBER,
                          x_msg_data       OUT NOCOPY VARCHAR2,
                          x_return_status   IN OUT NOCOPY VARCHAR2
                         ) AS
 l_bic varchar2(30) ;
 l_string varchar2(30) ;

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bic');
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    l_bic := upper(X_BIC_CODE) ;

    IF LENGTH(l_bic)  IN ( 8,11 ) THEN
        l_string := nvl(translate(l_bic,'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890','0'),'0');
        l_string := nvl(length(ltrim(rtrim(replace(l_string, '0', ' ')))),'0') ;

        IF TO_NUMBER(l_string) > 0 THEN
            fnd_message.set_name('CE', 'CE_INVALID_BIC_CODE');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_error;
        END IF ;
    ELSE
        fnd_message.set_name('CE', 'CE_INVALID_BIC_LENGTH');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
    END IF ;

    FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

END CE_VALIDATE_BIC;

FUNCTION ce_remove_formats(check_value VARCHAR2) RETURN VARCHAR2
IS
   num_check VARCHAR2(40);
BEGIN

    num_check := upper(replace(check_value,' ',''));
    num_check := replace(num_check,'-','');
    num_check := replace(num_check,'.','');

    RETURN(num_check);

END ce_remove_formats;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      COMPARE_BANK_AND_BRANCH_NUM                                      |
|                                                                       |
|  CALLED BY                                                            |
|      CE_VALIDATE_BRANCH_*                                             |
|                                                                       |
|  DESCRIPTION                                                          |
|      Verify that the value entered for Bank number and Branch number  |
|        fields are the same when both fields are entered for some      |
|        countries                                                      |
 --------------------------------------------------------------------- */
PROCEDURE COMPARE_BANK_AND_BRANCH_NUM(
        Xi_branch_num   IN VARCHAR2,
        Xi_BANK_ID      IN NUMBER
) AS
    BANK_NUM    varchar2(60);
    bank_count  number;
BEGIN

    cep_standard.debug('>>CE_VALIDATE_BANKINFO.compare_bank_and_branch_num');


    -- Bug 6856840: Added IF clause to handle cases where Bank ID is the Bank Number --
    IF BANK_ID_IS_NUM = TRUE
    THEN
        -- Bank ID is the bank number. No need to fetch from the table --
        IF ((nvl(Xi_BANK_ID,Xi_BRANCH_NUM) = Xi_BRANCH_NUM))
        THEN
            cep_standard.debug('COMPARE_BANK_AND_BRANCH_NUM: ' || ' passed_check');
        ELSE
            cep_standard.debug('COMPARE_BANK_AND_BRANCH_NUM: ' ||
                'Bank number and branch number does not match'||
                'CE_BANK_BRANCH_NUM_NOT_MATCHED');
            fnd_message.set_name('CE', 'CE_BANK_BRANCH_NUM_NOT_MATCHED');
            fnd_msg_pub.add;
        END IF;

	ELSE
		-- Bank ID is being used. Check if Bank exists and fetch Bank Number --
        SELECT count(*) INTO bank_count
        FROM   HZ_PARTIES   PartyBank,
               HZ_ORGANIZATION_PROFILES   OrgProfileBank,
               HZ_CODE_ASSIGNMENTS   CABank
        WHERE
               PartyBank.party_id = Xi_BANK_ID
          AND  PartyBank.PARTY_TYPE = 'ORGANIZATION'
          AND  PartyBank.status = 'A'
          AND  PartyBank.PARTY_ID = OrgProfileBank.PARTY_ID
          AND  sysdate BETWEEN trunc(OrgProfileBank.EFFECTIVE_START_DATE)
               AND nvl(trunc(OrgProfileBank.EFFECTIVE_END_DATE),sysdate)
          AND  CABank.CLASS_CATEGORY = 'BANK_INSTITUTION_TYPE'
          AND  CABank.CLASS_CODE = 'BANK'
          AND  CABank.OWNER_TABLE_NAME = 'HZ_PARTIES'
          AND  CABank.OWNER_TABLE_ID = PartyBank.PARTY_ID
          AND  nvl(CABank.status, 'A') = 'A';


        IF (bank_count = 1)
        THEN
            OPEN  get_bank_num(Xi_BANK_ID);
            FETCH get_bank_num INTO bank_num;
            CLOSE get_bank_num;

            IF  (BANK_NUM IS  NULL)
            THEN
                null;
            ELSIF  (BANK_NUM IS NOT NULL)
            THEN
                BANK_NUM := upper(replace(BANK_NUM,' ',''));
                BANK_NUM := upper(replace(BANK_NUM,'-',''));

                cep_standard.debug('COMPARE_BANK_AND_BRANCH_NUM: ' || 'BANK_NUM : ' ||BANK_NUM);

                IF ((nvl(BANK_NUM,Xi_branch_num) <> Xi_branch_num))
                THEN
                    cep_standard.debug('COMPARE_BANK_AND_BRANCH_NUM: ' ||
                        'Bank number and branch number does not match'||
                        'CE_BANK_BRANCH_NUM_NOT_MATCHED');
                    fnd_message.set_name('CE', 'CE_BANK_BRANCH_NUM_NOT_MATCHED');
                    fnd_msg_pub.add;
                END IF;
            END IF;
        ELSIF (bank_count > 1)
        THEN
            cep_standard.debug('COMPARE_BANK_AND_BRANCH_NUM: ' ||'EXCEPTION: More than one bank match ');
            fnd_message.set_name('CE', 'CE_MANY_BANKS');
            fnd_msg_pub.add;

        ELSIF (bank_count = 0)
        THEN
            cep_standard.debug('COMPARE_BANK_AND_BRANCH_NUM: ' || ' CE_BANK_DOES_NOT_EXISTS');
            fnd_message.set_name ('CE', 'CE_BANK_DOES_NOT_EXISTS');
            fnd_msg_pub.add;

        ELSE
            cep_standard.debug('COMPARE_BANK_AND_BRANCH_NUM: ' || ' passed_check');
        END IF;

        cep_standard.debug('<<CE_VALIDATE_BANKINFO.compare_bank_and_branch_num');
    END IF; /* end of check for BANK_ID_IS_NUM*/

EXCEPTION
    WHEN OTHERS THEN
        cep_standard.debug('CE_VALIDATE_BANKINFO.COMPARE_BANK_AND_BRANCH_NUM: Exception ' );
        FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
        fnd_message.set_token('PROCEDURE', 'CE_VALIDATE_BANKINFO.compare_bank_and_branch_num');
        fnd_msg_pub.add;
        RAISE;
END COMPARE_BANK_AND_BRANCH_NUM;

/* --------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|      COMPARE_ACCOUNT_NUM_AND_CD                                       |
|                                                                       |
|  CALLED BY                                                            |
|      CE_VALIDATE_CD_*                                                 |
|                                                                       |
|  DESCRIPTION                                                          |
|      Verify that the check digit entered on the account number        |
|      and check digit fields are the same                              |
 --------------------------------------------------------------------- */
FUNCTION COMPARE_ACCOUNT_NUM_AND_CD(
                    Xi_account_num IN VARCHAR2,
                    Xi_CD IN NUMBER,
                    Xi_CD_length in number,
                    Xi_CD_pos_from_right IN Number default 0) RETURN BOOLEAN AS

cd_position number;
acct_cd number;

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.COMPARE_ACCOUNT_NUM_AND_CD');

    cd_position := (length(Xi_account_num) - Xi_CD_pos_from_right);
    acct_cd := substr(Xi_account_num, cd_position, Xi_CD_length);

    cep_standard.debug('COMPARE_ACCOUNT_NUM_AND_CD: ' || 'cd_position : '||cd_position ||
                       'acct_cd : '||acct_cd || 'Xi_CD : '||Xi_CD );

    IF (acct_cd  <> Xi_CD) THEN
        cep_standard.debug('COMPARE_ACCOUNT_NUM_AND_CD: ' || 'CD does not match'||
                           'CE_ACCT_NUM_AND_CD_NOT_MATCHED');

        fnd_message.set_name('CE', 'CE_ACCT_NUM_AND_CD_NOT_MATCHED');
        fnd_msg_pub.add;
        RETURN FALSE;
    ELSE
        cep_standard.debug('COMPARE_ACCOUNT_NUM_AND_CD: ' || 'CD match');
        RETURN TRUE;
    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.COMPARE_ACCOUNT_NUM_AND_CD');

END COMPARE_ACCOUNT_NUM_AND_CD;

/* --------------------------------------------------------------------
|  PUBLIC FUNCTION                                                      |
|      CE_VAL_UNIQUE_TAX_PAYER_ID                                       |
|                                                                       |
|  CALLED BY                                                            |
|      CE_VALIDATE_BANK                                                 |
|                                                                       |
|  DESCRIPTION                                                          |
|      Unique Tax Payer ID  VALIDATIONS                                 |
|                                                                       |
 --------------------------------------------------------------------- */

FUNCTION CE_VAL_UNIQUE_TAX_PAYER_ID (
            p_country_code    IN  VARCHAR2,
            p_taxpayer_id     IN  VARCHAR2
) RETURN VARCHAR2 IS

    CURSOR CHECK_UNIQUE_TAXID_BK IS       -- Banks 8614674 changed the select
        SELECT TAX_PAYER_ID
        FROM   CE_BANKS_V
        WHERE  tax_payer_id = p_taxpayer_id
        AND home_country     = p_country_code;

    l_taxid        VARCHAR2(30);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_VAL_UNIQUE_TAX_PAYER_ID');

    OPEN CHECK_UNIQUE_TAXID_BK;
    FETCH CHECK_UNIQUE_TAXID_BK INTO l_taxid;

    IF (CHECK_UNIQUE_TAXID_BK%NOTFOUND)
    THEN
        CLOSE CHECK_UNIQUE_TAXID_BK;
        RETURN('TRUE');
        cep_standard.debug('CE_VAL_UNIQUE_TAX_PAYER_ID true');
    ELSE
        CLOSE CHECK_UNIQUE_TAXID_BK;
        RETURN('FALSE');
        cep_standard.debug('CE_VAL_UNIQUE_TAX_PAYER_ID false');
    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_VAL_UNIQUE_TAX_PAYER_ID');

END CE_VAL_UNIQUE_TAX_PAYER_ID;

/* --------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|      CE_CHECK_CROSS_MODULE_TAX_ID                                     |
|                                                                       |
|  CALLED BY                                                            |
|      CE_VALIDATE_BANK                                                 |
|                                                                       |
|  DESCRIPTION                                                          |
|      Unique Tax Payer ID  VALIDATIONS                                 |
|                                                                       |
 --------------------------------------------------------------------- */
  -- Check the cross validation
  -- This procedure  checks in AR, AP and HR to see if the TAX ID entered
  --   for the Bank is used  by a Customer, Supplier or a Company.
  -- If it is used THEN the Customer name, Supplier name or the Company
  --   name should match with the Bank name.
  -- Depending upon the different combinations different error codes are
  -- returned
  -- The messages codes returned are:
  --   bk1  Tax ID is used by a different Company
  --   bk2  Tax ID is used by a different Customer
  --   bk3  Tax ID is used by a different Supplier
  --   bk4  Bank exists as a Customer with different Tax ID or Tax ID Type
  --   bk5  Bank exists as a Supplier with different Tax ID or Tax ID Type
  --   bk6  Bank exists as a Company with different Tax ID or Tax ID Type

PROCEDURE ce_check_cross_module_tax_id(
                               p_country_code     IN  VARCHAR2,
                               p_entity_name      IN  VARCHAR2, --l_bank_name
                               p_taxpayer_id      IN  VARCHAR2,
                               p_return_ar        OUT NOCOPY VARCHAR2,
                               p_return_ap        OUT NOCOPY VARCHAR2,
                               p_return_hr        OUT NOCOPY VARCHAR2,
                               p_return_bk        OUT NOCOPY VARCHAR2) IS

  -- Suppliers
  CURSOR CHECK_CROSS_AP IS
    SELECT AP.VENDOR_NAME, AP.NUM_1099
    FROM   PO_VENDORS AP
    WHERE  (AP.VENDOR_NAME=p_entity_name OR  AP.NUM_1099= p_taxpayer_id)
      AND  substrb(nvl(AP.GLOBAL_ATTRIBUTE_CATEGORY,'XX.XX'),4,2) = p_country_code;

  -- Customers
  -- replaced ra_customers with hz_parties
  CURSOR CHECK_CROSS_AR IS
    SELECT AR.PARTY_NAME, AR.JGZZ_FISCAL_CODE
    FROM   HZ_PARTIES  AR
    WHERE  (AR.PARTY_NAME=p_entity_name OR  AR.JGZZ_FISCAL_CODE= p_taxpayer_id)
      AND  substrb(nvl(AR.GLOBAL_ATTRIBUTE_CATEGORY,'XX.XX'),4,2) = p_country_code;

  -- Companies
  CURSOR CHECK_CROSS_HR IS
    SELECT HR.GLOBAL_ATTRIBUTE8, HR.GLOBAL_ATTRIBUTE11
    FROM   HR_LOCATIONS HR
    WHERE  (HR.GLOBAL_ATTRIBUTE8= p_entity_name
       OR  HR.GLOBAL_ATTRIBUTE11= p_taxpayer_id)
      AND  substrb(nvl(HR.GLOBAL_ATTRIBUTE_CATEGORY,'XX.XX'),4,2) = p_country_code
      AND  HR.LOCATION_USE = 'HR';

  l_taxid       VARCHAR2(30);
  l_taxid_type  VARCHAR2(150);
  l_entity_name VARCHAR2(80);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_check_cross_module_tax_id'||
            'ce_check_cross_module_tax_id - p_taxpayer_id ' || p_taxpayer_id);

    -- Checking cross module Banks/Customers
    OPEN CHECK_CROSS_AR;
    FETCH CHECK_CROSS_AR INTO l_entity_name, l_taxid;

    cep_standard.debug('ce_check_cross_module_tax_id - l_entity_name ' ||l_entity_name ||
            'l_taxid ' ||l_taxid );

    IF CHECK_CROSS_AR%NOTFOUND THEN
        p_return_ar:='SUCCESS';
    ELSIF (l_taxid IS NULL  AND l_entity_name=p_entity_name) THEN
        p_return_ar:='SUCCESS';
    ELSIF (l_taxid IS NOT NULL) THEN
        IF (l_entity_name=p_entity_name AND l_taxid=p_taxpayer_id  ) THEN
            p_return_ar:='SUCCESS';
        -- Check if Tax ID is used by a different Customer
        ELSIF (l_entity_name<>p_entity_name AND l_taxid=p_taxpayer_id) THEN
            p_return_ar:='bk2';
        -- Check if Bank exists as Customer with different TAX ID or Tax ID
        -- Type
        ELSIF (l_entity_name=p_entity_name AND (l_taxid<>p_taxpayer_id )) THEN
            p_return_ar:='bk4';
        END IF;
    END IF;

    cep_standard.debug('ce_check_cross_module_tax_id - p_return_ar ' || p_return_ar );

    CLOSE CHECK_CROSS_AR;

    -- Checking cross module Banks/Companies
    IF p_country_code='CO' THEN
        l_taxid_type:='LEGAL_ENTITY';
    END IF;

    OPEN CHECK_CROSS_HR;
    FETCH CHECK_CROSS_HR INTO l_entity_name, l_taxid;

    IF CHECK_CROSS_HR%NOTFOUND THEN
        p_return_hr:='SUCCESS';
    ELSIF (l_taxid IS NULL  AND l_entity_name=p_entity_name) THEN
        p_return_hr:='SUCCESS';
    ELSIF (l_taxid IS NOT NULL) THEN
        IF (l_entity_name=p_entity_name AND l_taxid=p_taxpayer_id ) THEN
            p_return_hr:='SUCCESS';
        -- Check if Tax ID is used by a different Company
        ELSIF (l_entity_name<>p_entity_name AND l_taxid=p_taxpayer_id) THEN
            p_return_hr:='bk1';
        -- Check if Bank exists as Company with different Tax ID
        ELSIF (l_entity_name=p_entity_name AND (l_taxid<>p_taxpayer_id)) THEN
            p_return_hr:='bk6';
        END IF;
    END IF;
    cep_standard.debug('ce_check_cross_module_tax_id - p_return_hr ' || p_return_hr );
    CLOSE CHECK_CROSS_HR;

    -- Checking cross module Banks/Suppliers
    OPEN CHECK_CROSS_AP;
    FETCH CHECK_CROSS_AP INTO l_entity_name, l_taxid;

    IF CHECK_CROSS_AP%NOTFOUND THEN
        p_return_ap:='SUCCESS';
    ELSIF (l_taxid IS NULL  AND l_entity_name=p_entity_name) THEN
        p_return_ap:='SUCCESS';
    ELSIF (l_taxid IS NOT NULL) THEN
        IF (l_entity_name=p_entity_name AND l_taxid=p_taxpayer_id) THEN
            p_return_ap:='SUCCESS';
        -- Check if Tax ID is used by a different Supplier
        ELSIF (l_entity_name<>p_entity_name AND l_taxid=p_taxpayer_id) THEN
            p_return_ap:='bk3';
        -- Check if Bank exists as Supplier with different Tax ID
        ELSIF (l_entity_name=p_entity_name AND (l_taxid<>p_taxpayer_id )) THEN
            p_return_ap:='bk5';
        END IF;
    END IF;
    cep_standard.debug('ce_check_cross_module_tax_id - p_return_ap ' || p_return_ap );
    CLOSE CHECK_CROSS_AP;

    p_return_bk:='NA';

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_check_cross_module_tax_id');

END ce_check_cross_module_tax_id;

/* --------------------------------------------------------------------
|  PUBLIC FUNCTION                                                     |
|      CE_TAX_ID_CHECK_ALGORITHM                                        |
|                                                                       |
|  CALLED BY                                                            |
|      CE_VALIDATE_BANK                                                 |
|                                                                       |
|  DESCRIPTION                                                          |
|      Unique Tax Payer ID  VALIDATIONS                                 |
|                                                                       |
 --------------------------------------------------------------------- */
  -- Taxpayer ID Validation
FUNCTION ce_tax_id_check_algorithm(
    p_taxpayer_id  IN VARCHAR2,
    p_country   IN VARCHAR2,
    p_tax_id_cd IN VARCHAR2
) RETURN VARCHAR2 IS

    l_var1      VARCHAR2(20);
    l_val_digit VARCHAR2(2);
    l_mod_value NUMBER(2);
BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_TAX_ID_CHECK_ALGORITHM'|| '----------' ||
        'CE_VALIDATE_BANKINFO.CE_TAX_ID_CHECK_ALGORITHM ' ||p_COUNTRY );

    -- Check the Taxpayer ID Valdiation digit for Colombia
    IF p_country='CO' THEN
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

        cep_standard.debug('CE_VALIDATE_BANKINFO.ce_tax_id_check_algorithm - l_mod_value: '|| l_mod_value);

        IF (l_mod_value IN (1,0)) THEN
            l_val_digit:=l_mod_value;
        ELSE
            l_val_digit:=11-l_mod_value;
        END IF;

        cep_standard.debug('CE_VALIDATE_BANKINFO.ce_tax_id_check_algorithm - l_val_digit: '|| l_val_digit|| '----------' ||
            'CE_VALIDATE_BANKINFO.ce_tax_id_check_algorithm - p_tax_id_cd : '|| p_tax_id_cd );

        IF l_val_digit<> p_tax_id_cd THEN
            cep_standard.debug('failed ce_tax_id_check_algorithm' );
            RETURN('FALSE');
        ELSE
            cep_standard.debug('passed ce_tax_id_check_algorithm' );
            RETURN('TRUE');
        END IF;
    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_TAX_ID_CHECK_ALGORITHM');
END ce_tax_id_check_algorithm;


/* --------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|      CE_UNIQUE_BRANCH_NAME                                            |
|                                                                       |
|  DESCRIPTION                                                          |
|      Unique bank_id, branch_name  VALIDATIONS                         |
|                                                                       |
|  CALLED BY                                                            |
|
 --------------------------------------------------------------------- */
PROCEDURE CE_UNIQUE_BRANCH_NAME(
    Xi_COUNTRY_NAME    IN varchar2,
    Xi_BRANCH_NAME  IN varchar2,
    Xi_BANK_ID IN varchar2,
    Xi_BRANCH_ID IN varchar2) AS

    temp_name number;

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_UNIQUE_BRANCH_NAME');

    -- unique combination -> bank_id, branch_name, country --confirmed sql 6/25/02
    SELECT COUNT(*) INTO temp_name
    FROM   HZ_PARTIES              BankParty,
           HZ_PARTIES              BranchParty,
           HZ_ORGANIZATION_PROFILES        BankOrgProfile,
           HZ_ORGANIZATION_PROFILES        BranchOrgProfile,
           HZ_RELATIONSHIPS            BRRel,
           HZ_CODE_ASSIGNMENTS         BankCA,
           HZ_CODE_ASSIGNMENTS         BranchCA
    WHERE  BankParty.PARTY_TYPE = 'ORGANIZATION'
    AND    BankParty.status = 'A'
    AND    BankParty.PARTY_ID = BankOrgProfile.PARTY_ID
    AND    SYSDATE between TRUNC(BankOrgProfile.effective_start_date)
           and NVL(TRUNC(BankOrgProfile.effective_end_date), SYSDATE+1)
    AND    BankCA.CLASS_CATEGORY = 'BANK_INSTITUTION_TYPE'
    AND    BankCA.CLASS_CODE = 'BANK'
    AND    BankCA.OWNER_TABLE_NAME = 'HZ_PARTIES'
    AND    BankCA.OWNER_TABLE_ID = BankParty.PARTY_ID
    AND    NVL(BankCA.STATUS, 'A') = 'A'
    AND    BranchParty.PARTY_TYPE(+) = 'ORGANIZATION'
    AND    BranchParty.status(+) = 'A'
    AND    BranchOrgProfile.PARTY_ID(+) = BranchParty.PARTY_ID
    AND    SYSDATE BETWEEN TRUNC(BranchOrgProfile.effective_start_date(+))
           AND NVL(TRUNC(BranchOrgProfile.effective_end_date(+)), SYSDATE+1)
    AND    BranchCA.CLASS_CATEGORY(+) = 'BANK_INSTITUTION_TYPE'
    AND    BranchCA.CLASS_CODE(+) = 'BANK_BRANCH'
    AND    BranchCA.OWNER_TABLE_NAME(+) = 'HZ_PARTIES'
    AND    BranchCA.OWNER_TABLE_ID(+) = BranchParty.PARTY_ID
    AND    NVL(BranchCA.STATUS(+), 'A') = 'A'
    AND    BRRel.OBJECT_ID(+) = BankParty.PARTY_ID
    AND    BranchParty.PARTY_ID(+) = BRRel.SUBJECT_ID
    AND    BRRel.RELATIONSHIP_TYPE(+) = 'BANK_AND_BRANCH'
    AND    BRRel.RELATIONSHIP_CODE(+) = 'BRANCH_OF'
    AND    BRRel.STATUS(+) = 'A'
    AND    BRRel.SUBJECT_TABLE_NAME(+) = 'HZ_PARTIES'
    AND    BRRel.SUBJECT_TYPE(+) =  'ORGANIZATION'
    AND    BRRel.OBJECT_TABLE_NAME(+) = 'HZ_PARTIES'
    AND    BRRel.OBJECT_TYPE(+) = 'ORGANIZATION'
    AND    BankParty.PARTY_ID     =  Xi_BANK_ID
    AND    BranchParty.party_name =  Xi_BRANCH_NAME
    AND    BranchParty.country    =  Xi_COUNTRY_NAME
    AND    BranchParty.PARTY_ID  <>  nvl(Xi_BRANCH_ID, -1);

    cep_standard.debug('CE_UNIQUE_BRANCH_NAME - temp_name: ' ||temp_name);

    IF (nvl(temp_name,0) > 0) THEN
        cep_standard.debug('CE_UNIQUE_BRANCH_NAME: ' || 'CE_BANK_BRANCH_NAME_EXISTS');
        fnd_message.set_name('CE', 'CE_BANK_BRANCH_NAME_EXISTS');
        fnd_msg_pub.add;
    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_UNIQUE_BRANCH_NAME');

END CE_UNIQUE_BRANCH_NAME;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_UNIQUE_BRANCH_NUMBER                                          |
|                                                                       |
|  DESCRIPTION                                                          |
|      Unique bank_id, branch_number  VALIDATIONS                       |
|
|  CALLED BY                                                            |
|
 --------------------------------------------------------------------- */
PROCEDURE CE_UNIQUE_BRANCH_NUMBER(
    Xi_COUNTRY_NAME    IN varchar2,
    Xi_BRANCH_NUMBER  IN varchar2,
    Xi_BANK_ID IN varchar2,
    Xi_BRANCH_ID IN varchar2) AS

    temp_number number;
BEGIN
    cep_standard.debug('CE_UNIQUE_BRANCH_NAME: ' || '>>CE_VALIDATE_BANKINFO.CE_UNIQUE_BRANCH_NUMBER');

    -- unique combination -> bank_id, branch_number, country --confirmed sql 6/25/02

    SELECT  COUNT(*) INTO temp_number
    FROM    HZ_PARTIES              BankParty,
            HZ_PARTIES              BranchParty,
            HZ_ORGANIZATION_PROFILES        BankOrgProfile,
            HZ_ORGANIZATION_PROFILES        BranchOrgProfile,
            HZ_RELATIONSHIPS            BRRel,
            HZ_CODE_ASSIGNMENTS         BankCA,
            HZ_CODE_ASSIGNMENTS         BranchCA
    WHERE   BankParty.PARTY_TYPE = 'ORGANIZATION'
    AND     BankParty.status = 'A'
    AND     BankParty.PARTY_ID = BankOrgProfile.PARTY_ID
    AND     SYSDATE between TRUNC(BankOrgProfile.effective_start_date)
            and NVL(TRUNC(BankOrgProfile.effective_end_date), SYSDATE+1)
    AND     BankCA.CLASS_CATEGORY = 'BANK_INSTITUTION_TYPE'
    AND     BankCA.CLASS_CODE = 'BANK'
    AND     BankCA.OWNER_TABLE_NAME = 'HZ_PARTIES'
    AND     BankCA.OWNER_TABLE_ID = BankParty.PARTY_ID
    AND     NVL(BankCA.STATUS, 'A') = 'A'
    AND     BranchParty.PARTY_TYPE(+) = 'ORGANIZATION'
    AND     BranchParty.status(+) = 'A'
    AND     BranchOrgProfile.PARTY_ID(+) = BranchParty.PARTY_ID
    AND     SYSDATE between TRUNC(BranchOrgProfile.effective_start_date(+))
            and NVL(TRUNC(BranchOrgProfile.effective_end_date(+)), SYSDATE+1)
    AND     BranchCA.CLASS_CATEGORY(+) = 'BANK_INSTITUTION_TYPE'
    AND     BranchCA.CLASS_CODE(+) = 'BANK_BRANCH'
    AND     BranchCA.OWNER_TABLE_NAME(+) = 'HZ_PARTIES'
    AND     BranchCA.OWNER_TABLE_ID(+) = BranchParty.PARTY_ID
    AND     NVL(BranchCA.STATUS(+), 'A') = 'A'
    AND     BRRel.OBJECT_ID(+) = BankParty.PARTY_ID
    AND     BranchParty.PARTY_ID(+) = BRRel.SUBJECT_ID
    AND     BRRel.RELATIONSHIP_TYPE(+) = 'BANK_AND_BRANCH'
    AND     BRRel.RELATIONSHIP_CODE(+) = 'BRANCH_OF'
    AND     BRRel.STATUS(+) = 'A'
    AND     BRRel.SUBJECT_TABLE_NAME(+) = 'HZ_PARTIES'
    AND     BRRel.SUBJECT_TYPE(+) =  'ORGANIZATION'
    AND     BRRel.OBJECT_TABLE_NAME(+) = 'HZ_PARTIES'
    AND     BRRel.OBJECT_TYPE(+) = 'ORGANIZATION'
    AND     BankParty.PARTY_ID     =  Xi_BANK_ID
    AND     BranchOrgProfile.BANK_OR_BRANCH_NUMBER  = Xi_BRANCH_NUMBER
    AND     BranchParty.country    =  Xi_COUNTRY_NAME
    AND     BranchParty.PARTY_ID  <>  nvl(Xi_BRANCH_ID, -1);

    cep_standard.debug('CE_UNIQUE_BRANCH_NAME: ' || 'CE_UNIQUE_BRANCH_NUMBER - temp_number: ' ||temp_number);

    IF (nvl(temp_number,0) > 0) THEN
        cep_standard.debug('CE_UNIQUE_BRANCH_NAME: ' || 'CE_BANK_BRANCH_NUMBER_EXISTS');
        fnd_message.set_name('CE', 'CE_BANK_BRANCH_NUMBER_EXISTS');
        fnd_msg_pub.add;
    END IF;

    cep_standard.debug('CE_UNIQUE_BRANCH_NAME: ' || '<<CE_VALIDATE_BANKINFO.CE_UNIQUE_BRANCH_NUMBER');
END CE_UNIQUE_BRANCH_NUMBER;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_UNIQUE_BRANCH_NAME_ALT                                        |
|                                                                       |
|  DESCRIPTION                                                          |
|      Unique bank_id, branch_number_alt  VALIDATIONS                   |
|                                                                       |
|  CALLED BY                                                            |
|     Japan                                                             |
 --------------------------------------------------------------------- */
PROCEDURE CE_UNIQUE_BRANCH_NAME_ALT(
        Xi_COUNTRY_NAME    IN varchar2,
        Xi_BRANCH_NAME_ALT  IN varchar2,
        Xi_BANK_ID IN varchar2,
        Xi_BRANCH_ID IN varchar2) AS
    temp_name_alt number;
BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_UNIQUE_BRANCH_NAME_ALT');
    -- unique combination -> bank_id,  branch_name_alt, country  bug 2363959 --confirmed sql 6/25/02

    SELECT  COUNT(*) INTO temp_name_alt
    FROM    HZ_PARTIES              BankParty,
            HZ_PARTIES              BranchParty,
            HZ_ORGANIZATION_PROFILES        BankOrgProfile,
            HZ_ORGANIZATION_PROFILES        BranchOrgProfile,
            HZ_RELATIONSHIPS            BRRel,
            HZ_CODE_ASSIGNMENTS         BankCA,
            HZ_CODE_ASSIGNMENTS         BranchCA
    WHERE   BankParty.PARTY_TYPE = 'ORGANIZATION'
    AND     BankParty.status = 'A'
    AND     BankParty.PARTY_ID = BankOrgProfile.PARTY_ID
    AND     SYSDATE between TRUNC(BankOrgProfile.effective_start_date)
            and NVL(TRUNC(BankOrgProfile.effective_end_date), SYSDATE+1)
    AND     BankCA.CLASS_CATEGORY = 'BANK_INSTITUTION_TYPE'
    AND     BankCA.CLASS_CODE = 'BANK'
    AND     BankCA.OWNER_TABLE_NAME = 'HZ_PARTIES'
    AND     BankCA.OWNER_TABLE_ID = BankParty.PARTY_ID
    AND     NVL(BankCA.STATUS, 'A') = 'A'
    AND     BranchParty.PARTY_TYPE(+) = 'ORGANIZATION'
    AND     BranchParty.status(+) = 'A'
    AND     BranchOrgProfile.PARTY_ID(+) = BranchParty.PARTY_ID
    AND     SYSDATE between TRUNC(BranchOrgProfile.effective_start_date(+))
            and NVL(TRUNC(BranchOrgProfile.effective_end_date(+)), SYSDATE+1)
    AND     BranchCA.CLASS_CATEGORY(+) = 'BANK_INSTITUTION_TYPE'
    AND     BranchCA.CLASS_CODE(+) = 'BANK_BRANCH'
    AND     BranchCA.OWNER_TABLE_NAME(+) = 'HZ_PARTIES'
    AND     BranchCA.OWNER_TABLE_ID(+) = BranchParty.PARTY_ID
    AND     NVL(BranchCA.STATUS(+), 'A') = 'A'
    AND     BRRel.OBJECT_ID(+) = BankParty.PARTY_ID
    AND     BranchParty.PARTY_ID(+) = BRRel.SUBJECT_ID
    AND     BRRel.RELATIONSHIP_TYPE(+) = 'BANK_AND_BRANCH'
    AND     BRRel.RELATIONSHIP_CODE(+) = 'BRANCH_OF'
    AND     BRRel.STATUS(+) = 'A'
    AND     BRRel.SUBJECT_TABLE_NAME(+) = 'HZ_PARTIES'
    AND     BRRel.SUBJECT_TYPE(+) =  'ORGANIZATION'
    AND     BRRel.OBJECT_TABLE_NAME(+) = 'HZ_PARTIES'
    AND     BRRel.OBJECT_TYPE(+) = 'ORGANIZATION'
    AND     BankParty.PARTY_ID     =  Xi_BANK_ID
    AND     BranchParty.ORGANIZATION_NAME_PHONETIC =  Xi_BRANCH_NAME_ALT
    AND     BranchOrgProfile.home_country    =  Xi_COUNTRY_NAME -- bug 8552410 Changed BranchParty to BranchOrgProfile
    AND     BranchParty.PARTY_ID  <>  nvl(Xi_BRANCH_ID, -1);

    cep_standard.debug('CE_UNIQUE_BRANCH_NAME_ALT - temp_name_alt: ' ||temp_name_alt);

    IF (nvl(temp_name_alt,0) > 0) THEN
        cep_standard.debug('CE_UNIQUE_BRANCH_NAME: ' || 'CE_BANK_BRANCH_NAME_ALT_EXISTS');
        fnd_message.set_name('CE', 'CE_BANK_BRANCH_NAME_ALT_EXISTS');
        fnd_msg_pub.add;
    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_UNIQUE_BRANCH_NAME_ALT');
END CE_UNIQUE_BRANCH_NAME_ALT;


/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_UNIQUE_ACCOUNT_NAME                                           |
|                                                                       |
|  DESCRIPTION                                                          |
|      Unique bank_branch_id, bank account name VALIDATIONS             |
|                                                                       |
|  CALLED BY                                                            |
|      CE_VALIDATE_UNIQUE_ACCOUNT_*                                     |
|                                                                       |
|  CALLS                                                                |
|
 --------------------------------------------------------------------- */
PROCEDURE CE_UNIQUE_ACCOUNT_NAME(
    Xi_ACCOUNT_NAME  IN varchar2,
    Xi_BRANCH_ID IN varchar2,
    Xi_ACCOUNT_ID IN varchar2) AS

    temp_name  number;
BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_UNIQUE_ACCOUNT_NAME'||
        'Xi_ACCOUNT_NAME ' ||Xi_ACCOUNT_NAME ||
        ', Xi_BRANCH_ID ' ||Xi_BRANCH_ID );

    -- unique combination -> bank_branch_id, bank account name --confirmed sql
    SELECT  COUNT(*) INTO temp_name
    FROM    ce_bank_accounts ba
    WHERE   ba.bank_account_name  = Xi_ACCOUNT_NAME
    AND     ba.bank_branch_id      = Xi_BRANCH_ID
    AND     ba.bank_account_id    <> nvl(Xi_ACCOUNT_ID,-1);

    cep_standard.debug('CE_UNIQUE_ACCOUNT_NAME: ' || 'temp_name: '||temp_name);

    IF (nvl(temp_name,0) > 0) THEN
        fnd_message.set_name('CE', 'CE_BANK_ACCOUNT_NAME_EXISTS');
        fnd_msg_pub.add;
        cep_standard.debug('CE_UNIQUE_ACCOUNT_NAME: ' || 'CE_BANK_ACCOUNT_NAME_EXISTS');
    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_UNIQUE_ACCOUNT_NAME');

END CE_UNIQUE_ACCOUNT_NAME;


/* --------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|      CE_VALIDATE_CD                                                   |
|                                                                       |
|  CALLED BY                                                            |
|      OA - BANK ACCOUNT INFORMATION PAGE                               |
|                                                                       |
|  CALLS                                                                |
|      CE_VALIDATE_CD_*           for each country                      |
 --------------------------------------------------------------------- */
PROCEDURE CE_VALIDATE_CD(
    X_COUNTRY_NAME   IN varchar2,
    X_CD             IN varchar2,
    X_BANK_NUMBER    IN varchar2,
    X_BRANCH_NUMBER  IN varchar2,
    X_ACCOUNT_NUMBER IN varchar2,
    p_init_msg_list  IN VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2,
    x_return_status  IN OUT NOCOPY VARCHAR2,
    X_ACCOUNT_CLASSIFICATION IN VARCHAR2 DEFAULT NULL
) AS
    COUNTRY_NAME       VARCHAR2(2);
    X_PASS_MAND_CHECK  VARCHAR2(1);
    x_init_count       NUMBER;  --bug 7460921: added
BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_cd');

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;
    COUNTRY_NAME  := X_COUNTRY_NAME;

    cep_standard.debug('CE_VALIDATE_BANKINFO.ce_validate_cd - COUNTRY_NAME: '|| COUNTRY_NAME||
        'CE_VALIDATE_BANKINFO.ce_validate_cd - P_INIT_MSG_LIST: '|| P_INIT_MSG_LIST);

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        x_init_count := 0;
        FND_MSG_PUB.initialize;
    ELSE
        -- bug 7460921 Capturing the message stack count into the variable x_init_count
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_init_count,
                p_data  => x_msg_data);
    END IF;

    /* We must validate the Check Digit
       Bug 6632733 Making check digit validation optional so assigning P instead of earlier F */
    IF X_CD is null AND
      (X_BANK_NUMBER is not null OR X_BRANCH_NUMBER is not null OR X_ACCOUNT_NUMBER is not null)
    THEN
        X_PASS_MAND_CHECK := 'P';
    ELSIF X_CD is not null THEN
        X_PASS_MAND_CHECK := 'P';
    ELSE
        X_PASS_MAND_CHECK := ' ';
    END IF;

    cep_standard.debug('CE_VALIDATE_BANKINFO.ce_validate_cd - X_PASS_MAND_CHECK: '|| X_PASS_MAND_CHECK);

    IF X_CD IS NOT NULL THEN -- Bug 6632733 Perform all the validations only if check digit is entered

        IF (COUNTRY_NAME = 'FR') THEN
            CE_VALIDATE_BANKINFO.CE_VALIDATE_CD_FR(
                X_CD,
                X_PASS_MAND_CHECK,
                X_BANK_NUMBER,
                X_BRANCH_NUMBER,
                translate(X_ACCOUNT_NUMBER,'ABCDEFGHIJKLMNOPQRSTUVWXYZ ','123456789123456789234567890'));

        ELSIF (COUNTRY_NAME = 'ES') THEN
            CE_VALIDATE_BANKINFO.CE_VALIDATE_CD_ES(X_CD,
                X_PASS_MAND_CHECK,
                X_BANK_NUMBER,
                X_BRANCH_NUMBER,
                translate(X_ACCOUNT_NUMBER,'ABCDEFGHIJKLMNOPQRSTUVWXYZ ','123456789123456789234567890'));

        ELSIF (COUNTRY_NAME = 'PT') THEN
            CE_VALIDATE_BANKINFO.CE_VALIDATE_CD_PT(X_CD,
                X_PASS_MAND_CHECK,
                X_BANK_NUMBER,
                X_BRANCH_NUMBER,
                translate(X_ACCOUNT_NUMBER,'ABCDEFGHIJKLMNOPQRSTUVWXYZ ','123456789123456789234567890'));
            -- added 5/14/02

        ELSIF (COUNTRY_NAME = 'DE') THEN
            CE_VALIDATE_BANKINFO.CE_VALIDATE_CD_DE(X_CD,
                X_ACCOUNT_NUMBER);

        ELSIF (COUNTRY_NAME = 'GR') THEN
            CE_VALIDATE_BANKINFO.CE_VALIDATE_CD_GR(X_CD,
                X_PASS_MAND_CHECK,
                X_BANK_NUMBER,
                X_BRANCH_NUMBER,
                translate(X_ACCOUNT_NUMBER,'ABCDEFGHIJKLMNOPQRSTUVWXYZ ','123456789123456789234567890'));

        ELSIF (COUNTRY_NAME = 'IS') THEN
            CE_VALIDATE_BANKINFO.CE_VALIDATE_CD_IS(X_CD,
                translate(X_ACCOUNT_NUMBER,'ABCDEFGHIJKLMNOPQRSTUVWXYZ ','123456789123456789234567890'));

        ELSIF (COUNTRY_NAME = 'IT') THEN
            CE_VALIDATE_BANKINFO.CE_VALIDATE_CD_IT(X_CD,
                X_PASS_MAND_CHECK,
                X_BANK_NUMBER,
                X_BRANCH_NUMBER,
                -- Bug 6836343: Removed translate command as the substitution is done in
                -- the procedure itself. Passing X_ACCOUNT_NUMBER directly
                X_ACCOUNT_NUMBER);

        ELSIF (COUNTRY_NAME = 'LU') THEN
            CE_VALIDATE_BANKINFO.CE_VALIDATE_CD_LU(X_CD,
                X_BANK_NUMBER,
                X_BRANCH_NUMBER,
                X_ACCOUNT_NUMBER);

        ELSIF (COUNTRY_NAME = 'SE') THEN
            CE_VALIDATE_BANKINFO.CE_VALIDATE_CD_SE(X_CD,X_ACCOUNT_NUMBER);

        --9249372: Added
        ELSIF (COUNTRY_NAME = 'FI') THEN
            CE_VALIDATE_BANKINFO.ce_validate_cd_fi(X_CD, X_BRANCH_NUMBER, X_ACCOUNT_NUMBER);

        END IF;
    END IF; -- End Bug 6632733

    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    IF x_msg_count > x_init_count THEN -- bug 7460921
        x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    cep_standard.debug('CE_VALIDATE_BANKINFO.ce_validate_cd - P_COUNT: '|| x_msg_count);

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_cd');

EXCEPTION
    WHEN OTHERS THEN
        cep_standard.debug('Exception: CE_VALIDATE_BANKINFO.ce_validate_cd ' ||X_COUNTRY_NAME );

        FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
        fnd_message.set_token('PROCEDURE', 'CE_VALIDATE_BANKINFO.cd_validate_cd');
        fnd_msg_pub.add;
        RAISE;
END CE_VALIDATE_CD;


/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_BRANCH                                               |
|                                                                       |
|  CALLED BY                                                            |
|      OA - BANK BRANCH INFORMATION PAGE                                |
|                                                                       |
|  CALLS                                                                |
|      CE_VALIDATE_BRANCH_*           for each country                  |
|      CE_VALIDATE_UNIQUE_BRANCH_*    for each country                  |
 --------------------------------------------------------------------- */
PROCEDURE CE_VALIDATE_BRANCH(
    X_COUNTRY_NAME              IN  VARCHAR2,
    X_BANK_NUMBER               IN  VARCHAR2,
    X_BRANCH_NUMBER             IN  VARCHAR2,
    X_BANK_NAME                 IN  VARCHAR2,
    X_BRANCH_NAME               IN  VARCHAR2,
    X_BRANCH_NAME_ALT           IN  VARCHAR2,
    X_BANK_ID                   IN  NUMBER,
    X_BRANCH_ID                 IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    X_VALUE_OUT                 OUT NOCOPY varchar2,
    x_return_status             IN OUT NOCOPY VARCHAR2,
    X_ACCOUNT_CLASSIFICATION    IN VARCHAR2 DEFAULT NULL,
    X_BRANCH_TYPE               IN VARCHAR2 DEFAULT NULL) -- 9250566 added
AS
    COUNTRY_NAME        VARCHAR2(2);
    X_PASS_MAND_CHECK   VARCHAR2(1);

    l_value_out           VARCHAR2(40);-- 9250566: Added
    l_value_out_custom    VARCHAR2(40);-- 9250566: Added
    l_usr_valid           VARCHAR2(1); -- 9250566: Added
    l_count_before_custom NUMBER;      -- 9250566: Added
    l_count_after_custom  NUMBER;      -- 9250566: Added

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_branch');

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    COUNTRY_NAME  := X_COUNTRY_NAME;
    l_value_out := X_BRANCH_NUMBER;

    cep_standard.debug('COUNTRY_NAME: '|| COUNTRY_NAME);
    cep_standard.debug('l_value_out: '|| l_value_out);

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    /* We must validate the Bank Branch Number */
    IF X_BRANCH_NUMBER IS NULL THEN
        X_PASS_MAND_CHECK := 'F';
    ELSE
        X_PASS_MAND_CHECK := 'P';
    END IF;

    cep_standard.debug('X_PASS_MAND_CHECK: '|| X_PASS_MAND_CHECK);
    cep_standard.debug('Calling CE_VALIDATE_BRANCH_'||COUNTRY_NAME);

    IF (COUNTRY_NAME = 'AT') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_AT(
            X_BRANCH_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'ES') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_ES(
            X_BRANCH_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'FR') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_FR(
            X_BRANCH_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'PT') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_PT(
            X_BRANCH_NUMBER,
            X_PASS_MAND_CHECK);

    ELSIF (COUNTRY_NAME = 'BR') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_BR(
            X_BRANCH_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    -- added 5/14/02
    ELSIF (COUNTRY_NAME = 'DE') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_DE(
            X_BRANCH_NUMBER,
            X_BANK_ID);

    ELSIF (COUNTRY_NAME = 'GR') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_GR(X_BRANCH_NUMBER);

    ELSIF (COUNTRY_NAME = 'IS') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_IS(
            X_BRANCH_NUMBER,
            X_BANK_ID,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'IE') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_IE(
            X_BRANCH_NUMBER,
            X_BANK_ID);

    ELSIF (COUNTRY_NAME = 'IT') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_IT(
            X_BRANCH_NUMBER,
            X_PASS_MAND_CHECK);

    ELSIF (COUNTRY_NAME = 'LU') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_LU(
            X_BRANCH_NUMBER,
            X_BANK_ID);

    ELSIF (COUNTRY_NAME = 'PL') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_PL(
            X_BRANCH_NUMBER,
            X_BANK_ID);

    ELSIF (COUNTRY_NAME = 'SE') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_SE(
            X_BRANCH_NUMBER,
            X_BANK_ID);

    ELSIF (COUNTRY_NAME = 'CH') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_CH(
            X_BRANCH_NUMBER,
            X_BANK_ID);

    ELSIF (COUNTRY_NAME = 'GB') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_GB(
            X_BRANCH_NUMBER,
            X_BANK_ID);

    ELSIF (COUNTRY_NAME = 'US') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_US(
            X_BRANCH_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    -- added 10/19/04
    ELSIF (COUNTRY_NAME = 'AU') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_AU(
            X_BRANCH_NUMBER,
            X_BANK_ID,
            X_PASS_MAND_CHECK);

    ELSIF (COUNTRY_NAME = 'IL') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_IL(
            X_BRANCH_NUMBER,
            X_PASS_MAND_CHECK);

    ELSIF (COUNTRY_NAME = 'NZ') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_NZ(
            X_BRANCH_NUMBER,
            X_PASS_MAND_CHECK);

    ELSIF (COUNTRY_NAME = 'JP') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_JP(
            X_BRANCH_NUMBER,
            X_BRANCH_NAME_ALT,
            X_PASS_MAND_CHECK);

    -- 9249372: Added
    ELSIF (COUNTRY_NAME = 'FI') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_FI(X_BRANCH_NUMBER);

    END IF;

    --   UNIQUE VALIDATION CHECK for branch --
    cep_standard.debug('UNIQUE VALIDATION CHECK for branch' );

    -- bug 4730717,
    -- 11/30/05 unique validation for US and Germany bank branches should not
    -- be removed
    IF (COUNTRY_NAME = 'JP') THEN
        cep_standard.debug('call CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_BRANCH_JP' );

        CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_BRANCH_JP(
            X_COUNTRY_NAME,
            X_BRANCH_NUMBER,
            X_BRANCH_NAME,
            X_BRANCH_NAME_ALT,
            X_BANK_ID,
            X_BRANCH_ID);
    ELSE
        cep_standard.debug('call CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_BRANCH' );

        CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_BRANCH(
            X_COUNTRY_NAME,
            X_BRANCH_NUMBER,
            X_BRANCH_NAME,
            X_BANK_ID,
            X_BRANCH_ID);
    END IF;
    cep_standard.debug('UNIQUE VALIDATION CHECK for branch end' );
    --  end country unique check for branch   --

    -- 9250566 ADDED 1/6 START -------------------------
    l_count_before_custom := Nvl(FND_MSG_PUB.count_msg,0);
    l_usr_valid := fnd_api.g_ret_sts_success;

    -- Call to custom validation routines
    cep_standard.debug('Calling custom validation hooks');
    cep_standard.debug('l_count_before=' ||l_count_before_custom);
    cep_standard.debug('l_value_out='    ||l_value_out);
    CE_CUSTOM_BANK_VALIDATIONS.ce_usr_validate_branch(
        Xi_COUNTRY_NAME    => X_COUNTRY_NAME,
        Xi_BANK_NUMBER     => X_BANK_NUMBER,
        Xi_BRANCH_NUMBER   => l_value_out,
        Xi_BANK_NAME       => X_BANK_NAME,
        Xi_BRANCH_NAME     => X_BRANCH_NAME,
        Xi_BRANCH_NAME_ALT => X_BRANCH_NAME_ALT,
        Xi_BRANCH_TYPE     => X_BRANCH_TYPE,
        Xi_BANK_ID         => X_BANK_ID,
        Xi_BRANCH_ID       => X_BRANCH_ID,
        Xo_BRANCH_NUM_OUT  => l_value_out_custom,
        Xo_RETURN_STATUS   => l_usr_valid
    );

    l_count_after_custom := FND_MSG_PUB.count_msg;
    cep_standard.debug('l_count_before='    ||l_count_before_custom);

    cep_standard.debug('l_value_out_custom='||l_value_out_custom);
    X_VALUE_OUT := NVL(l_value_out_custom,l_value_out);

    -- Check return status
    IF l_usr_valid = fnd_api.g_ret_sts_error
    THEN
       cep_standard.debug('Custom validations done - failure');
       IF l_count_after_custom = 0 THEN
          cep_standard.debug('No custom error message set');
       END IF;
    ELSE
       cep_standard.debug('Custom validations done - success');
       -- remove any unnecessary messages
       WHILE l_count_after_custom > l_count_before_custom
       LOOP
            FND_MSG_PUB.delete_msg(l_count_after_custom);
            l_count_after_custom := l_count_after_custom - 1;
            cep_standard.debug(l_count_after_custom);
        END LOOP;
        cep_standard.debug('After cleanup, count='||FND_MSG_PUB.count_msg);

    END IF;
    -- 9250566 ADDED 1/6 END --------------------------

    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    cep_standard.debug('P_COUNT: '|| x_msg_count);

    IF x_msg_count > 0 THEN
        x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    cep_standard.debug('X_VALUE_OUT: '|| X_VALUE_OUT);
    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_branch');

EXCEPTION
    WHEN OTHERS THEN
        cep_standard.debug('EXCEPTION: ce_validate_branch ' ||X_COUNTRY_NAME );
        FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
        fnd_message.set_token('PROCEDURE', 'CE_VALIDATE_BANKINFO.cd_validate_branch');
        fnd_msg_pub.add;
        RAISE;
END CE_VALIDATE_BRANCH;

/* ----------------------------------------------------------------------- */
PROCEDURE CE_FORMAT_ELECTRONIC_NUM_BE(
    X_ACCOUNT_NUMBER          IN VARCHAR2,
    X_ACCOUNT_CLASSIFICATION  IN VARCHAR2 DEFAULT NULL,
    X_ELECTRONIC_ACCT_NUM     OUT NOCOPY VARCHAR2
) AS
    account_value       VARCHAR2(30);
    l_bank_account_num  VARCHAR2(30);
BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_FORMAT_ELECTRONIC_NUM_BE');

    account_value:= ce_remove_formats(X_ACCOUNT_NUMBER);

    IF X_ACCOUNT_CLASSIFICATION = 'EXTERNAL' THEN
        -- Bug 6175680 changed the character for l_bank_account_num from 12 to 14.
        l_bank_account_num := lpad(ltrim(rtrim(to_char(X_ACCOUNT_NUMBER))),14,'0');
        l_bank_account_num := rpad(nvl(l_bank_account_num, ' '), 14, ' ');

        -- Bug 8884977: replaced to_number() with rtrim(ltrim(,'0'))
        account_value := rtrim(ltrim((substr(l_bank_account_num,1,3)
                                 ||substr(l_bank_account_num,5,7)
                                 ||substr(l_bank_account_num,13,2)),'0'));

    END IF;

    cep_standard.debug('account_value ' ||account_value);
    X_ELECTRONIC_ACCT_NUM := account_value;

    cep_standard.debug('X_ELECTRONIC_ACCT_NUM ' ||X_ELECTRONIC_ACCT_NUM);
    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_FORMAT_ELECTRONIC_NUM_BE');
END CE_FORMAT_ELECTRONIC_NUM_BE;

/* ----------------------------------------------------------------------- */
PROCEDURE CE_FORMAT_ELECTRONIC_NUM_FI(
    X_BRANCH_NUMBER           IN  VARCHAR2, /* 9249372: Added */
    X_ACCOUNT_NUMBER          IN  VARCHAR2,
    X_ACCOUNT_CLASSIFICATION  IN  VARCHAR2 DEFAULT NULL,
    X_ELECTRONIC_ACCT_NUM     OUT NOCOPY VARCHAR2
) AS

    account_value     VARCHAR2(30);
    account_pad_value VARCHAR2(30);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_FORMAT_ELECTRONIC_NUM_FI');

    -- 9249372: Combination of account number and branch number to be used
    IF X_Branch_Number IS NOT NULL
    THEN
        -- remove formatting characters
        account_value := ce_remove_formats(X_Branch_Number || X_Account_Number);
        cep_standard.debug('account_value='||account_value);

        -- pad as per first digit
        IF (SubStr(account_value,1,1) IN ('4','5'))
        THEN
            account_pad_value := SubStr(account_value,1,7) ||
                            LPad(SubStr(account_value,8,Length(account_value)),7,'0');
        ELSE
            account_pad_value := SubStr(account_value,1,6) ||
                            LPad(SubStr(account_value,7,Length(account_value)),8,'0');
        END IF;
        cep_standard.debug('account_pad_value='||account_pad_value);

        X_ELECTRONIC_ACCT_NUM := account_pad_value;

    -- 9249372: If branch number not entered, return account number
    ELSE
        X_ELECTRONIC_ACCT_NUM := ce_remove_formats(X_Account_Number);
    END IF;

    cep_standard.debug('X_ELECTRONIC_ACCT_NUM ' ||X_ELECTRONIC_ACCT_NUM);
    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_FORMAT_ELECTRONIC_NUM_FI');
END CE_FORMAT_ELECTRONIC_NUM_FI;

/* ----------------------------------------------------------------------- */
PROCEDURE CE_FORMAT_ELECTRONIC_NUM_NL(
    X_ACCOUNT_NUMBER            IN VARCHAR2,
    X_ACCOUNT_CLASSIFICATION    IN VARCHAR2 DEFAULT NULL,
    X_ELECTRONIC_ACCT_NUM       OUT NOCOPY VARCHAR2
) AS
    account_value VARCHAR2(100);
BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_FORMAT_ELECTRONIC_NUM_NL');
    SELECT rpad(
              decode(
                   upper(substr(X_ACCOUNT_NUMBER, 1, 1)),
                   'P', rpad(upper(X_ACCOUNT_NUMBER), 10, ' '),
                   'G', rpad('P' || substr(X_ACCOUNT_NUMBER, 2), 10, ' '),
               'I', rpad('P' || substr(X_ACCOUNT_NUMBER, 2), 10, ' '),
                   NULL, lpad(' ', 10, ' '),
                   lpad(X_ACCOUNT_NUMBER, 10, '0')
                   )
                   ,35,' ')
    INTO account_value
    FROM dual;

    X_ELECTRONIC_ACCT_NUM := account_value;

    cep_standard.debug('X_ELECTRONIC_ACCT_NUM ' ||X_ELECTRONIC_ACCT_NUM);
    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_FORMAT_ELECTRONIC_NUM_NL');
END CE_FORMAT_ELECTRONIC_NUM_NL;

/* ----------------------------------------------------------------------- */
PROCEDURE CE_FORMAT_ELECTRONIC_NUM_NO(
    X_ACCOUNT_NUMBER      IN varchar2,
    X_ACCOUNT_CLASSIFICATION  IN VARCHAR2 DEFAULT NULL,
    X_ELECTRONIC_ACCT_NUM     OUT NOCOPY varchar2
) AS
    account_value varchar2(30);
BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_FORMAT_ELECTRONIC_NUM_NO');

    account_value:= lpad(replace(replace(NVL(X_ACCOUNT_NUMBER,''),'.',''),' ',''),11,0);
    X_ELECTRONIC_ACCT_NUM := account_value;

    cep_standard.debug('X_ELECTRONIC_ACCT_NUM ' ||X_ELECTRONIC_ACCT_NUM);
    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_FORMAT_ELECTRONIC_NUM_NO');
END CE_FORMAT_ELECTRONIC_NUM_NO;

/* ----------------------------------------------------------------------- */
PROCEDURE CE_FORMAT_ELECTRONIC_NUM_SE(
    X_ACCOUNT_NUMBER            IN VARCHAR2,
    X_ACCOUNT_CLASSIFICATION    IN VARCHAR2 DEFAULT NULL,
    X_ELECTRONIC_ACCT_NUM       OUT NOCOPY VARCHAR2
) AS
    account_value VARCHAR2(30);
BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_FORMAT_ELECTRONIC_NUM_SE');

    account_value:= ce_remove_formats(X_ACCOUNT_NUMBER);
    X_ELECTRONIC_ACCT_NUM := account_value;

    cep_standard.debug('X_ELECTRONIC_ACCT_NUM ' ||X_ELECTRONIC_ACCT_NUM);
    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_FORMAT_ELECTRONIC_NUM_SE');
END CE_FORMAT_ELECTRONIC_NUM_SE;

/* --------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                    |
|      CE_FORMAT_ELECTRONIC_NUM                                        |
|                                                                      |
|  CALLED BY                                                           |
|      CE_VALIDATE_ACCOUNT                                             |
|                                                                      |
|  CALLS                                                               |
|      CE_FORMAT_ELECTRONIC_NUM_*           for each country           |
 ---------------------------------------------------------------------*/
PROCEDURE CE_FORMAT_ELECTRONIC_NUM(
    X_COUNTRY_NAME                  IN VARCHAR2,
    X_BANK_NUMBER                   IN VARCHAR2,
    X_BRANCH_NUMBER                 IN VARCHAR2,
    X_ACCOUNT_NUMBER                IN VARCHAR2,
    X_CD                            IN VARCHAR2 DEFAULT NULL,
    X_ACCOUNT_SUFFIX                IN VARCHAR2,
    X_SECONDARY_ACCOUNT_REFERENCE   IN VARCHAR2,
    X_ACCOUNT_CLASSIFICATION        IN VARCHAR2 DEFAULT NULL,
    X_ELECTRONIC_ACCT_NUM           OUT NOCOPY Varchar2,
    p_init_msg_list                 IN VARCHAR2,
    x_msg_count                     OUT NOCOPY NUMBER,
    x_msg_data                      OUT NOCOPY VARCHAR2,
    x_return_status                 IN OUT NOCOPY VARCHAR2
) AS
    country_name   VARCHAR2(2);
BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_FORMAT_ELECTRONIC_NUM');
    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    COUNTRY_NAME  := X_COUNTRY_NAME;
    X_ELECTRONIC_ACCT_NUM := X_ACCOUNT_NUMBER;

    cep_standard.debug('COUNTRY_NAME: '|| COUNTRY_NAME);
    cep_standard.debug('X_ELECTRONIC_ACCT_NUM: '|| X_ELECTRONIC_ACCT_NUM);

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
            FND_MSG_PUB.initialize;
    END IF;

    IF (COUNTRY_NAME = 'BE') THEN
        CE_VALIDATE_BANKINFO.CE_FORMAT_ELECTRONIC_NUM_BE(
            X_ACCOUNT_NUMBER  ,
            X_ACCOUNT_CLASSIFICATION,
            X_ELECTRONIC_ACCT_NUM);

    ELSIF (COUNTRY_NAME = 'FI') THEN
        CE_VALIDATE_BANKINFO.CE_FORMAT_ELECTRONIC_NUM_FI(
            X_BRANCH_NUMBER,   /* 9249372: Added */
            X_ACCOUNT_NUMBER  ,
            X_ACCOUNT_CLASSIFICATION,
            X_ELECTRONIC_ACCT_NUM);

    ELSIF (COUNTRY_NAME = 'NL') THEN
        CE_VALIDATE_BANKINFO.CE_FORMAT_ELECTRONIC_NUM_NL(
            X_ACCOUNT_NUMBER  ,
            X_ACCOUNT_CLASSIFICATION,
            X_ELECTRONIC_ACCT_NUM);

    ELSIF (COUNTRY_NAME = 'NO') THEN
        CE_VALIDATE_BANKINFO.CE_FORMAT_ELECTRONIC_NUM_NO(
            X_ACCOUNT_NUMBER  ,
            X_ACCOUNT_CLASSIFICATION,
            X_ELECTRONIC_ACCT_NUM);

    ELSIF (COUNTRY_NAME = 'SE') THEN
        CE_VALIDATE_BANKINFO.CE_FORMAT_ELECTRONIC_NUM_SE(
            X_ACCOUNT_NUMBER  ,
            X_ACCOUNT_CLASSIFICATION,
            X_ELECTRONIC_ACCT_NUM);

    END IF;

    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

    IF x_msg_count > 0 THEN
       x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    cep_standard.debug('P_COUNT: '|| x_msg_count);
    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_FORMAT_ELECTRONIC_NUM');
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: CE_FORMAT_ELECTRONIC_NUM ' ||X_COUNTRY_NAME );
    FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
    fnd_message.set_token('PROCEDURE', 'CE_VALIDATE_BANKINFO.CE_FORMAT_ELECTRONIC_NUM');
    fnd_msg_pub.add;
    RAISE;
END CE_FORMAT_ELECTRONIC_NUM;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_ACCOUNT                                              |
|                                                                       |
|  CALLED BY                                                            |
|      OA - BANK ACCOUNT INFORMATION PAGE                               |
|                                                                       |
|  CALLS                                                                |
|      CE_VALIDATE_ACCOUNT_*           for each country                 |
|      CE_VALIDATE_UNIQUE_ACCOUNT_*    for each country                 |
 --------------------------------------------------------------------- */
PROCEDURE CE_VALIDATE_ACCOUNT(
    x_country_name                  IN VARCHAR2,
    x_bank_number                   IN VARCHAR2,
    x_branch_number                 IN VARCHAR2,
    x_account_number                IN VARCHAR2,
    x_bank_id                       IN NUMBER,
    x_branch_id                     IN NUMBER,
    x_account_id                    IN NUMBER,
    x_currency_code                 IN VARCHAR2,
    x_account_type                  IN VARCHAR2,
    x_account_suffix                IN VARCHAR2,
    x_secondary_account_reference   IN VARCHAR2,
    x_account_name                  IN VARCHAR2,
    p_init_msg_list                 IN  VARCHAR2,
    x_msg_count                     OUT NOCOPY NUMBER,
    x_msg_data                      OUT NOCOPY VARCHAR2,
    x_value_out                     OUT NOCOPY Varchar2,
    x_return_status                 IN OUT NOCOPY VARCHAR2,
    x_account_classification        IN VARCHAR2 DEFAULT NULL,
    x_cd                            IN  VARCHAR2  DEFAULT NULL,
    x_electronic_acct_num           OUT NOCOPY VARCHAR2
) AS
    COUNTRY_NAME        VARCHAR2(2);
    NEW_ACCOUNT_NUM     VARCHAR2(100);
    X_PASS_MAND_CHECK   VARCHAR2(1);

    l_value_out           VARCHAR2(40);-- 9250566: Added
    l_value_out_custom    VARCHAR2(40);-- 9250566: Added
    l_usr_valid           VARCHAR2(1); -- 9250566: Added
    l_count_before_custom NUMBER;      -- 9250566: Added
    l_count_after_custom  NUMBER;      -- 9250566: Added

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account');
    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    COUNTRY_NAME  := X_COUNTRY_NAME;
    l_value_out := X_ACCOUNT_NUMBER;
    X_ELECTRONIC_ACCT_NUM := X_ACCOUNT_NUMBER;

    cep_standard.debug('COUNTRY_NAME: '|| COUNTRY_NAME||', l_value_out: '|| l_value_out);

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
            FND_MSG_PUB.initialize;
    END IF;

    /* We must validate the Bank Account Number */
    IF X_ACCOUNT_NUMBER is null   THEN
        X_PASS_MAND_CHECK := 'F';
    ELSE
        X_PASS_MAND_CHECK := 'P';
    END IF;

    cep_standard.debug('X_PASS_MAND_CHECK: '|| X_PASS_MAND_CHECK);

    IF (COUNTRY_NAME = 'AT') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_AT(
            X_ACCOUNT_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'DK') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_DK(
            X_ACCOUNT_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'NO') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_NO(
            X_ACCOUNT_NUMBER,
            X_PASS_MAND_CHECK);

    ELSIF (COUNTRY_NAME = 'ES') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_ES(
            X_ACCOUNT_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'NL') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_NL(
            X_ACCOUNT_NUMBER,
            X_PASS_MAND_CHECK);

    ELSIF (COUNTRY_NAME = 'FR') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_FR(
            X_ACCOUNT_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'BE') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_BE(
            X_ACCOUNT_NUMBER,
            X_PASS_MAND_CHECK);

    ELSIF (COUNTRY_NAME = 'PT') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_PT(
            X_ACCOUNT_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'FI') THEN -- 8897744 Removed AND (X_BRANCH_NUMBER='LMP')
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_FI(
            X_ACCOUNT_NUMBER,
            X_PASS_MAND_CHECK);

    -- added 5/14/02
    ELSIF (COUNTRY_NAME = 'DE') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_DE(
            X_ACCOUNT_NUMBER,
            l_value_out );

    ELSIF (COUNTRY_NAME = 'GR') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_GR(
            X_ACCOUNT_NUMBER,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'IS') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_IS(
            X_ACCOUNT_NUMBER,
            l_value_out );

    ELSIF (COUNTRY_NAME = 'IE') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_IE(X_ACCOUNT_NUMBER);

    ELSIF (COUNTRY_NAME = 'IT') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_IT(X_ACCOUNT_NUMBER,l_value_out);

    ELSIF (COUNTRY_NAME = 'LU') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_LU(X_ACCOUNT_NUMBER);

    ELSIF (COUNTRY_NAME = 'PL') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_PL(X_ACCOUNT_NUMBER);

    ELSIF (COUNTRY_NAME = 'SE') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_SE(X_ACCOUNT_NUMBER);

    ELSIF (COUNTRY_NAME = 'CH') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_CH(
            X_ACCOUNT_NUMBER,
            X_ACCOUNT_TYPE );

    ELSIF (COUNTRY_NAME = 'GB') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_GB(
            X_ACCOUNT_NUMBER,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'BR') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_BR(
            X_ACCOUNT_NUMBER,
            X_SECONDARY_ACCOUNT_REFERENCE);

    ELSIF (COUNTRY_NAME = 'AU') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_AU(
            X_ACCOUNT_NUMBER,
            X_CURRENCY_CODE);

    ELSIF (COUNTRY_NAME = 'IL') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_IL(X_ACCOUNT_NUMBER);

    ELSIF (COUNTRY_NAME = 'NZ') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_NZ(
            X_ACCOUNT_NUMBER,
            X_ACCOUNT_SUFFIX);

    ELSIF (COUNTRY_NAME = 'JP') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_JP(X_ACCOUNT_NUMBER,
                    X_ACCOUNT_TYPE );
    END IF;  /* country account check */

    /*   UNIQUE VALIDATION CHECK for account   */
    cep_standard.debug('UNIQUE_VALIDATION CHECK for account');

    IF (COUNTRY_NAME = 'JP')   THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_ACCOUNT_JP(
            X_ACCOUNT_NUMBER,
            X_CURRENCY_CODE,
            X_ACCOUNT_TYPE,
            X_ACCOUNT_NAME,
            X_BRANCH_ID,
            X_ACCOUNT_ID);

    ELSIF (COUNTRY_NAME = 'NZ')   THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_ACCOUNT_NZ(
            X_ACCOUNT_NUMBER,
            X_CURRENCY_CODE,
            X_ACCOUNT_SUFFIX,
            X_ACCOUNT_NAME,
            X_BRANCH_ID,
            X_ACCOUNT_ID);

    ELSE
        cep_standard.debug('call CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_ACCOUNT' );
        CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_ACCOUNT(
            X_ACCOUNT_NUMBER,
            X_CURRENCY_CODE,
            X_ACCOUNT_NAME,
            X_BRANCH_ID,
            X_ACCOUNT_ID);

    END IF;

    cep_standard.debug(' UNIQUE_VALIDATION CHECK for account end ');

    -- ER 3973203
    -- Format Electronic Bank Account Num
    -- (CE_BANK_ACCOUNTS.BANK_ACCOUNT_NUM_ELECTRONIC)
    IF l_value_out IS NOT NULL THEN
        NEW_ACCOUNT_NUM :=  l_value_out;
    ELSE
        NEW_ACCOUNT_NUM :=  X_ACCOUNT_NUMBER;
    END IF;
    cep_standard.debug('CE_VALIDATE_ACCOUNT: NEW_ACCOUNT_NUM: '|| NEW_ACCOUNT_NUM);

    CE_FORMAT_ELECTRONIC_NUM(
        X_COUNTRY_NAME ,
        X_BANK_NUMBER ,
        X_BRANCH_NUMBER ,
        NEW_ACCOUNT_NUM ,
        X_CD,
        X_ACCOUNT_SUFFIX,
        X_SECONDARY_ACCOUNT_REFERENCE,
        X_ACCOUNT_CLASSIFICATION,
        X_ELECTRONIC_ACCT_NUM ,
        p_init_msg_list  ,
        x_msg_count ,
        x_msg_data ,
        x_return_status   );

    cep_standard.debug('CE_VALIDATE_ACCOUNT: X_ELECTRONIC_ACCT_NUM: '|| X_ELECTRONIC_ACCT_NUM);

    -- 9250566 ADDED 2/6 START -------------------------
    l_count_before_custom := Nvl(FND_MSG_PUB.count_msg,0);
    l_usr_valid := fnd_api.g_ret_sts_success;

    -- Call to custom validation routines
    cep_standard.debug('Calling custom validation hooks');
    cep_standard.debug('l_count_before=' ||l_count_before_custom);
    cep_standard.debug('l_value_out='    ||l_value_out);
    CE_CUSTOM_BANK_VALIDATIONS.ce_usr_validate_account(
        Xi_COUNTRY_NAME            => X_COUNTRY_NAME,
        Xi_BANK_NUMBER             => X_BANK_NUMBER,
        Xi_BRANCH_NUMBER           => X_BRANCH_NUMBER,
        Xi_ACCOUNT_NUMBER          => l_value_out,
        Xi_CD                      => X_CD,
        Xi_ACCOUNT_NAME            => X_ACCOUNT_NAME,
        Xi_CURRENCY_CODE           => X_CURRENCY_CODE,
        Xi_ACCOUNT_TYPE            => X_ACCOUNT_TYPE,
        Xi_ACCOUNT_SUFFIX          => X_ACCOUNT_SUFFIX,
        Xi_SECONDARY_ACCT_REF      => X_SECONDARY_ACCOUNT_REFERENCE,
        Xi_ACCT_CLASSIFICATION     => X_ACCOUNT_CLASSIFICATION,
        Xi_BANK_ID                 => X_BANK_ID,
        Xi_BRANCH_ID               => X_BRANCH_ID,
        Xi_ACCOUNT_ID              => X_ACCOUNT_ID,
        Xo_ACCOUNT_NUM_OUT         => l_value_out_custom,
        Xo_RETURN_STATUS           => l_usr_valid
    );

    l_count_after_custom := FND_MSG_PUB.count_msg;
    cep_standard.debug('l_count_before='||l_count_before_custom);

    cep_standard.debug('l_value_out_custom='||l_value_out_custom);
    X_VALUE_OUT := NVL(l_value_out_custom,l_value_out);

    -- Check return status
    IF l_usr_valid = fnd_api.g_ret_sts_error
    THEN
       cep_standard.debug('Custom validations done - failure');
       IF l_count_after_custom = 0 THEN
          cep_standard.debug('No custom error message set');
       END IF;
    ELSE
       cep_standard.debug('Custom validations done - success');
       -- remove any unnecessary messages
       WHILE l_count_after_custom > l_count_before_custom
       LOOP
            FND_MSG_PUB.delete_msg(l_count_after_custom);
            l_count_after_custom := l_count_after_custom - 1;
            cep_standard.debug(l_count_after_custom);
        END LOOP;
        cep_standard.debug('After cleanup, count='||FND_MSG_PUB.count_msg);

    END IF;
    -- 9250566 2/6 ADDED END --------------------------

    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    IF x_msg_count > 0 THEN
       x_return_status := fnd_api.g_ret_sts_error;
    END IF;
    cep_standard.debug('CE_VALIDATE_ACCOUNT: P_COUNT: '|| x_msg_count);
    cep_standard.debug('X_VALUE_OUT: '|| X_VALUE_OUT);

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_account');
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: ce_validate_account ' ||X_COUNTRY_NAME );
    FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
    fnd_message.set_token('PROCEDURE', 'CE_VALIDATE_BANKINFO.ce_validate_account');
    fnd_msg_pub.add;
    RAISE;
END CE_VALIDATE_ACCOUNT;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_BANK                                                 |
|                                                                       |
|  CALLED BY                                                            |
|      OA - BANK INFORMATION PAGE                                       |
|                                                                       |
|  CALLS                                                                |
|      CE_VALIDATE_BANK_*           for each country                    |
|      CE_VALIDATE_UNIQUE_BANK_*    for each country                    |
 --------------------------------------------------------------------- */
PROCEDURE CE_VALIDATE_BANK(
    X_COUNTRY_NAME    IN varchar2,
    X_BANK_NUMBER     IN varchar2,
    X_BANK_NAME       IN varchar2,
    X_BANK_NAME_ALT   IN varchar2,
    X_TAX_PAYER_ID    IN varchar2,
    X_BANK_ID         IN NUMBER,
    p_init_msg_list   IN VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2,
    X_VALUE_OUT      OUT NOCOPY varchar2,
    x_return_status IN OUT NOCOPY VARCHAR2,
    X_ACCOUNT_CLASSIFICATION IN VARCHAR2 DEFAULT NULL
) AS
    COUNTRY_NAME   VARCHAR2(2);
    X_PASS_MAND_CHECK  VARCHAR2(1);

    l_value_out           VARCHAR2(40);-- 9250566: Added
    l_value_out_custom    VARCHAR2(40);-- 9250566: Added
    l_usr_valid           VARCHAR2(1); -- 9250566: Added
    l_count_before_custom NUMBER;      -- 9250566: Added
    l_count_after_custom  NUMBER;      -- 9250566: Added

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bank');
    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    COUNTRY_NAME  := X_COUNTRY_NAME;
    l_value_out := X_BANK_NUMBER;

    cep_standard.debug('COUNTRY_NAME: '|| COUNTRY_NAME||
                       ', l_value_out: '|| l_value_out);

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
            FND_MSG_PUB.initialize;
    END IF;

    /* We must validate the Bank Number */
    IF X_BANK_NUMBER is null   THEN
        X_PASS_MAND_CHECK := 'F';
    ELSE
        X_PASS_MAND_CHECK := 'P';
    END IF;

    cep_standard.debug('X_PASS_MAND_CHECK: '|| X_PASS_MAND_CHECK);

    IF (COUNTRY_NAME = 'ES') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_ES(
            X_BANK_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'FR') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_FR(
            X_BANK_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'PT') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_PT(
            X_BANK_NUMBER,
            X_PASS_MAND_CHECK);

    ELSIF (COUNTRY_NAME = 'BR') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_BR(
            X_BANK_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    -- Added 5/14/02
    ELSIF (COUNTRY_NAME = 'DE') THEN
    CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_DE(X_BANK_NUMBER);

    ELSIF (COUNTRY_NAME = 'GR') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_GR(X_BANK_NUMBER);

    ELSIF (COUNTRY_NAME = 'IS') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_IS(
            X_BANK_NUMBER,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'IE') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_IE(X_BANK_NUMBER);

    ELSIF (COUNTRY_NAME = 'IT') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_IT(
            X_BANK_NUMBER,
            X_PASS_MAND_CHECK);

    ELSIF (COUNTRY_NAME = 'LU') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_LU(X_BANK_NUMBER);

    ELSIF (COUNTRY_NAME = 'PL') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_PL(X_BANK_NUMBER);

    ELSIF (COUNTRY_NAME = 'SE') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_SE(X_BANK_NUMBER);

    ELSIF (COUNTRY_NAME = 'CH') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_CH(X_BANK_NUMBER);

    ELSIF (COUNTRY_NAME = 'GB') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_GB(X_BANK_NUMBER);

    ELSIF (COUNTRY_NAME = 'CO') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_CO(
            X_COUNTRY_NAME,
            X_BANK_NAME ,
            X_TAX_PAYER_ID);

    -- Added 10/19/04
    ELSIF (COUNTRY_NAME = 'AU') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_AU(X_BANK_NUMBER);

    ELSIF (COUNTRY_NAME = 'IL') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_IL(
            X_BANK_NUMBER,
            X_PASS_MAND_CHECK);

    ELSIF (COUNTRY_NAME = 'NZ') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_NZ(
            X_BANK_NUMBER,
            X_PASS_MAND_CHECK);

    ELSIF (COUNTRY_NAME = 'JP') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_JP(
            X_BANK_NUMBER,
            X_BANK_NAME_ALT,
            X_PASS_MAND_CHECK);
    -- 8266356: Added
    ELSIF (COUNTRY_NAME = 'AT') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_AT(
            X_BANK_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);
    END IF;  /* country check for bank   */

    /*   UNIQUE VALIDATION CHECK for bank   */
    cep_standard.debug('UNIQUE VALIDATION CHECK for bank' );

    IF (COUNTRY_NAME = 'JP') THEN
        cep_standard.debug('call CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_BANK_JP');
        CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_BANK_JP(
            X_COUNTRY_NAME,
            X_BANK_NUMBER ,
            X_BANK_NAME ,
            X_BANK_NAME_ALT,
            X_BANK_ID);

    END IF;  /*   country unique check for bank   */

    -- 9250566 ADDED 3/6 START -------------------------
    l_count_before_custom := Nvl(FND_MSG_PUB.count_msg,0);
    l_usr_valid := fnd_api.g_ret_sts_success;

    -- Call to custom validation routines
    cep_standard.debug('Calling custom validation hooks');
    cep_standard.debug('l_count_before=' ||l_count_before_custom);
    cep_standard.debug('l_value_out='    ||l_value_out);
    CE_CUSTOM_BANK_VALIDATIONS.ce_usr_validate_bank (
        Xi_COUNTRY_NAME    => X_COUNTRY_NAME,
        Xi_BANK_NUMBER     => l_value_out,
        Xi_BANK_NAME       => X_BANK_NAME,
        Xi_BANK_NAME_ALT   => X_BANK_NAME_ALT,
        Xi_TAX_PAYER_ID    => X_TAX_PAYER_ID,
        Xi_BANK_ID         => X_BANK_ID,
        Xo_BANK_NUM_OUT    => l_value_out_custom,
        Xo_RETURN_STATUS   => l_usr_valid);

    l_count_after_custom := FND_MSG_PUB.count_msg;
    cep_standard.debug('l_count_before='||l_count_before_custom);

    cep_standard.debug('l_value_out_custom='||l_value_out_custom);
    X_VALUE_OUT := NVL(l_value_out_custom,l_value_out);
    -- Check return status
    IF l_usr_valid = fnd_api.g_ret_sts_error
    THEN
       cep_standard.debug('Custom validations done - failure');
       IF l_count_after_custom = 0 THEN
          cep_standard.debug('No custom error message set');
       END IF;
    ELSE
       cep_standard.debug('Custom validations done - success');
       -- remove any unnecessary messages
       WHILE l_count_after_custom > l_count_before_custom
       LOOP
            FND_MSG_PUB.delete_msg(l_count_after_custom);
            l_count_after_custom := l_count_after_custom - 1;
            cep_standard.debug(l_count_after_custom);
        END LOOP;
        cep_standard.debug('After cleanup, count='||FND_MSG_PUB.count_msg);

    END IF;
    -- 9250566 ADDED 3/6 END --------------------------

    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    IF X_MSG_COUNT > 0 THEN
        x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    cep_standard.debug('CE_VALIDATE_BANKINFO.ce_validate_bank - P_COUNT: '||X_MSG_COUNT);
    cep_standard.debug('X_VALUE_OUT: '|| X_VALUE_OUT);
    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_bank');

EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('CE_VALIDATE_BANKINFO.ce_validate_bank ' ||X_COUNTRY_NAME );
    FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
    fnd_message.set_token('PROCEDURE', 'CE_VALIDATE_BANKINFO.cd_validate_bank');
    fnd_msg_pub.add;
    RAISE;
END CE_VALIDATE_BANK;


/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|     CE_PASSED_CHECK                                                   |
|                                                                       |
|  DESCRIPTION                                                          |
|   This procedure is called when the validations are successful        |
|                                                                       |
|  CALLED BY                                                            |
|      CE_VALIDATE_BANK_*       for each country                        |
|      CE_VALIDATE_BRANCH_*     for each country                        |
|      CE_VALIDATE_ACCOUNT_*    for each country                        |
|      CE_VALIDATE_CD_*         for each country                        |
 --------------------------------------------------------------------- */
PROCEDURE CE_PASSED_CHECK (
        Xi_Field    IN VARCHAR2,
        Xi_Country  IN VARCHAR2
) AS
BEGIN
    cep_standard.debug('CE_VALIDATE_'||xi_field
                        ||'_'||xi_country||' : passed_check');
END CE_PASSED_CHECK;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|     CE_FAILED_CHECK                                                   |
|                                                                       |
|  DESCRIPTION                                                          |
|  This procedure populates the FND message queue with the appropriate  |
|  error message for any country-specific validation failure            |
|                                                                       |
|  CALLED BY                                                            |
|      CE_VALIDATE_BANK_*       for each country                        |
|      CE_VALIDATE_BRANCH_*     for each country                        |
|      CE_VALIDATE_ACCOUNT_*    for each country                        |
|      CE_VALIDATE_CD_*         for each country                        |
 --------------------------------------------------------------------- */
PROCEDURE CE_FAILED_CHECK (
        p_Field IN VARCHAR2,
        p_Error IN VARCHAR2,
        p_Token IN VARCHAR2 default NULL
) AS

    field_token   VARCHAR2(100) DEFAULT NULL;
    field_name    VARCHAR2(100) DEFAULT NULL;
    mesg_name     VARCHAR2(100) DEFAULT NULL;
    length_val    VARCHAR2(100) DEFAULT NULL;
BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_FAILED_CHECK');

    -- Setting the field name as per call --
    IF    p_Field = 'ACCOUNT_NUM'    THEN field_token := 'CE_TOKEN_ACCOUNT_NUM';
    ELSIF p_Field = 'ACCOUNT_SUFFIX' THEN field_token := 'CE_TOKEN_ACCOUNT_SUFFIX';
    ELSIF p_Field = 'BANK_NUM'       THEN field_token := 'CE_TOKEN_BANK_NUM';
    ELSIF p_Field = 'BRANCH_NUM'     THEN field_token := 'CE_TOKEN_BRANCH_NUM';
    ELSIF p_Field = 'CHECK_DIGIT'    THEN field_token := 'CE_TOKEN_CHECK_DIGIT';
    ELSIF p_Field = 'COMPANY_CODE'   THEN field_token := 'CE_TOKEN_COMPANY_CODE';
    ELSIF p_Field = 'TAX_PAYER_ID'   THEN field_token := 'CE_TOKEN_TAX_PAYER_ID';
    ELSIF p_Field = 'ROUTE_NUM'      THEN field_token := 'CE_TOKEN_BRANCH_NUM_US';
    END IF;

    cep_standard.debug('field_token = '||field_token);
    -- Get field name from values stored in FND_NEW_MESSAGES --
    field_name := fnd_message.get_string('CE',field_token);
    cep_standard.debug('field_name = '||field_name);

    -- Setting the error message name as per call --
    IF    p_Error = 'LENGTH'              THEN mesg_name := 'CE_FIELD_INVALID_LEN';
    ELSIF p_Error = 'LENGTH_MAX'          THEN mesg_name := 'CE_FIELD_INVALID_MAX_LEN';
    ELSIF p_Error = 'LENGTH_MIN'          THEN mesg_name := 'CE_FIELD_INVALID_MIN_LEN';
    ELSIF p_Error = 'NUMERIC'             THEN mesg_name := 'CE_FIELD_INVALID_NUMERIC';
    ELSIF p_Error = 'ALPHANUM'            THEN mesg_name := 'CE_FIELD_INVALID_ALPHANUM'; -- 9537127: Added
    ELSIF p_Error = 'CD_FAILED'           THEN mesg_name := 'CE_FIELD_FAILED_VAL';
    ELSIF p_Error = 'POST_GIRO'           THEN mesg_name := 'CE_FIELD_INVALID_PG';
    ELSIF p_Error = 'INVALID_FORMAT'      THEN mesg_name := 'CE_FIELD_INVALID_FORMAT';
    ELSIF p_Error = 'INVALID_RTN'         THEN mesg_name := 'CE_FIELD_INVALID_RTN';
    END IF;

    cep_standard.debug('mesg_name = '||mesg_name);
    -- set the value for the tokens and add message to FND_MSG_PUB --
	FND_MESSAGE.set_name('CE', mesg_name);
    FND_MESSAGE.set_token('FIELD', field_name, true);

    -- For length related errors, need to populate the VALUE token --
    IF p_Token IS NOT NULL
    THEN
        -- get the number for VALUE token from lookups
        BEGIN
            SELECT meaning
            INTO length_val
            FROM fnd_lookup_values_vl
            WHERE lookup_type = 'NUMBERS'
            AND lookup_code = p_Token;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                length_val := NULL;
        END;
        -- set the token --
        FND_MESSAGE.set_token('VALUE', length_val, true);
    END IF;

    -- populate the message queue
    FND_MSG_PUB.add;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_FAILED_CHECK');
END CE_FAILED_CHECK;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|     CE_FAILED_MANDATORY                                               |
|                                                                       |
|  DESCRIPTION                                                          |
|  This procedure populates the FND message queue with the appropriate  |
|  error message for any country-specific validation field value not    |
|  entered.                                                             |
|                                                                       |
|  CALLED BY                                                            |
|      CE_VALIDATE_BANK_*       for each country                        |
|      CE_VALIDATE_BRANCH_*     for each country                        |
|      CE_VALIDATE_ACCOUNT_*    for each country                        |
|      CE_VALIDATE_CD_*         for each country                        |
 --------------------------------------------------------------------- */
PROCEDURE CE_FAILED_MANDATORY (
        p_Field IN VARCHAR2
) AS

    mesg_name VARCHAR2(30);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_FAILED_MANDATORY');

    IF    p_Field = 'BANK_NUM'        THEN mesg_name := 'CE_ENTER_BANK_NUM';
    ELSIF p_Field = 'BRANCH_NUM'      THEN mesg_name := 'CE_ENTER_BRANCH_NUM';
    ELSIF p_Field = 'TAX_PAYER_ID'    THEN mesg_name := 'CE_ENTER_TAX_PAYER_ID';
    ELSIF p_Field = 'BRANCH_NAME_ALT' THEN mesg_name := 'CE_ENTER_BRANCH_NAME_ALT';
    ELSIF p_Field = 'BANK_NAME_ALT'   THEN mesg_name := 'CE_ENTER_BANK_NAME_ALT';
    ELSIF p_Field = 'ACCOUNT_TYPE'    THEN mesg_name := 'CE_ENTER_ACCOUNT_TYPE';
    ELSIF p_Field = 'ACCOUNT_SUFFIX'  THEN mesg_name := 'CE_ENTER_ACCOUNT_SUFFIX';
    END IF;

    cep_standard.debug('mesg_name = '||mesg_name);

    FND_MESSAGE.set_name('CE', mesg_name);
    FND_MSG_PUB.add;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_FAILED_MANDATORY');
END CE_FAILED_MANDATORY;

/*  --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_CD_*                                                 |
|                                                                       |
|  CALLED BY                                                            |
|      CE_VALIDATE_CD                                                   |
|                                                                       |
|  DESCRIPTION                                                          |
|      Check Digit PROCEDURES, Validations 1 or more of the following:  |
|      1. Check Digit length                                            |
|      2. Check Digit Composition                                       |
|      2. Check Digit Algorithm                                         |
|                                                                       |
 --------------------------------------------------------------------- */

/* ---------------------------------------------------------------------
| CD Validation: PORTUGAL                                               |
 ----------------------------------------------------------------------*/
PROCEDURE CE_VALIDATE_CD_PT(
        Xi_CD in varchar2,
        Xi_PASS_MAND_CHECK in varchar2,
        Xi_X_BANK_NUMBER in varchar2,
        Xi_X_BRANCH_NUMBER in varchar2,
        Xi_X_ACCOUNT_NUMBER in varchar2
) AS

    numeric_result_cd   VARCHAR2(40);
    cal_cd              NUMBER(10);
    CONCED_NUMBER       VARCHAR2(30);
    cd_value            VARCHAR2(20);
    bk_value            VARCHAR2(30);
    ac_value            VARCHAR2(30);
    br_value            VARCHAR2(30);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_cd_pt');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    CD_VALUE := upper(replace(Xi_CD,' ',''));
    bk_value := upper(replace(replace(Xi_X_BANK_NUMBER,' ',''),'-',''));
    br_value := upper(replace(replace(Xi_X_BRANCH_NUMBER,' ',''),'-',''));
    ac_value := upper(replace(replace(Xi_X_ACCOUNT_NUMBER,' ',''),'-',''));

    IF length(CD_VALUE) = 2
    THEN /* length is ok */
        numeric_result_cd := ce_check_numeric(CD_VALUE,1,length(CD_VALUE));
        IF  numeric_result_cd = '0'
        THEN /* its numeric so continue  */
            CONCED_NUMBER := bk_value||br_value||ac_value||CD_VALUE;
            cal_cd := 98 - mod(( (to_number(substr(CONCED_NUMBER,19,1)) * 3)
                        + (to_number(substr(CONCED_NUMBER,18,1)) * 30)
                        + (to_number(substr(CONCED_NUMBER,17,1)) * 9)
                        + (to_number(substr(CONCED_NUMBER,16,1)) * 90)
                        + (to_number(substr(CONCED_NUMBER,15,1)) * 27)
                        + (to_number(substr(CONCED_NUMBER,14,1)) * 76)
                        + (to_number(substr(CONCED_NUMBER,13,1)) * 81)
                        + (to_number(substr(CONCED_NUMBER,12,1)) * 34)
                        + (to_number(substr(CONCED_NUMBER,11,1)) * 49)
                        + (to_number(substr(CONCED_NUMBER,10,1)) * 5)
                        + (to_number(substr(CONCED_NUMBER,9,1)) * 50)
                        + (to_number(substr(CONCED_NUMBER,8,1)) * 15)
                        + (to_number(substr(CONCED_NUMBER,7,1)) * 53)
                        + (to_number(substr(CONCED_NUMBER,6,1)) * 45)
                        + (to_number(substr(CONCED_NUMBER,5,1)) * 62)
                        + (to_number(substr(CONCED_NUMBER,4,1)) * 38)
                        + (to_number(substr(CONCED_NUMBER,3,1)) * 89)
                        + (to_number(substr(CONCED_NUMBER,2,1)) * 17)
                        + (to_number(substr(CONCED_NUMBER,1,1)) * 73)),97);

            IF CD_VALUE = cal_cd
            THEN
                ce_passed_check('CD','PT');
            ElSE
                ce_failed_check('CHECK_DIGIT','CD_FAILED');
            END IF; /* end of validation check */

        ELSE
            ce_failed_check('CHECK_DIGIT','NUMERIC');
        END IF; /* end of numeric check */
    ELSE
        ce_failed_check('CHECK_DIGIT','LENGTH','2');
    END IF; /* end of length check  */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_cd_pt');
END CE_VALIDATE_CD_PT;


/* ---------------------------------------------------------------------
| CD Validation: SPAIN                                                  |
 ----------------------------------------------------------------------*/
PROCEDURE CE_VALIDATE_CD_ES(
    Xi_CD in varchar2,
    Xi_PASS_MAND_CHECK in varchar2,
    Xi_X_BANK_NUMBER in varchar2,
    Xi_X_BRANCH_NUMBER in varchar2,
    Xi_X_ACCOUNT_NUMBER in varchar2
) AS

    numeric_result_cd   VARCHAR2(40);
    cd_1                NUMBER(10);
    cd_2                NUMBER(10);
    cd_value            VARCHAR2(20);
    bk_value            VARCHAR2(30);
    ac_value            VARCHAR2(30);
    br_value            VARCHAR2(30);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_cd_es');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    CD_VALUE := upper(Xi_CD);
    bk_value := upper(replace(replace(Xi_X_BANK_NUMBER,' ',''),'-',''));
    br_value := upper(replace(replace(Xi_X_BRANCH_NUMBER,' ',''),'-',''));
    ac_value := upper(replace(replace(Xi_X_ACCOUNT_NUMBER,' ',''),'-',''));

	--Bug 7184848: Fixed value numeric_result_cd not being set.
	numeric_result_cd := ce_check_numeric(CD_VALUE,1,length(CD_VALUE));
    IF numeric_result_cd = '0'
    THEN /* its numeric so continue  */
        cd_1  := 11 - mod(((to_number(substr(Xi_X_BANK_NUMBER,1,1)) * 4)
                    + (to_number(substr(Xi_X_BANK_NUMBER,2,1)) * 8)
                    + (to_number(substr(Xi_X_BANK_NUMBER,3,1)) * 5)
                    + (to_number(substr(Xi_X_BANK_NUMBER,4,1)) * 10)
                    + (to_number(substr(Xi_X_BRANCH_NUMBER,1,1)) * 9)
                    + (to_number(substr(Xi_X_BRANCH_NUMBER,2,1)) * 7)
                    + (to_number(substr(Xi_X_BRANCH_NUMBER,3,1)) * 3)
                    + (to_number(substr(Xi_X_BRANCH_NUMBER,4,1)) * 6)),11);

        IF (cd_1 = 10) THEN
            cd_1 := 1;
        ELSIF (cd_1 = 11) THEN
            cd_1 := 0;
        END IF;

        cd_2  := 11 - mod(((to_number(substr(Xi_X_ACCOUNT_NUMBER,1,1)) * 1)
                    + (to_number(substr(Xi_X_ACCOUNT_NUMBER,2,1)) * 2)
                    + (to_number(substr(Xi_X_ACCOUNT_NUMBER,3,1)) * 4)
                    + (to_number(substr(Xi_X_ACCOUNT_NUMBER,4,1)) * 8)
                    + (to_number(substr(Xi_X_ACCOUNT_NUMBER,5,1)) * 5)
                    + (to_number(substr(Xi_X_ACCOUNT_NUMBER,6,1)) * 10)
                    + (to_number(substr(Xi_X_ACCOUNT_NUMBER,7,1)) * 9)
                    + (to_number(substr(Xi_X_ACCOUNT_NUMBER,8,1)) * 7)
                    + (to_number(substr(Xi_X_ACCOUNT_NUMBER,9,1)) * 3)
                    + (to_number(substr(Xi_X_ACCOUNT_NUMBER,10,1)) * 6)),11);

        IF (cd_2 = 10) THEN
            cd_2 := 1;
        ELSIF (cd_2 = 11) THEN
            cd_2 := 0;
        END IF;

        IF (cd_1 = substr(CD_VALUE,1,1) AND cd_2 = substr(CD_VALUE,2,1))
        OR (CD_VALUE = '00')
        THEN    /* check digit checks out */
            ce_passed_check('CD','ES');
        ELSE
            ce_failed_check('CHECK_DIGIT','CD_FAILED');
        END IF; /* end of check digit validation */

    ELSE
        ce_failed_check('CHECK_DIGIT','NUMERIC');
    END IF;  /* end of numeric check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_cd_es');
END CE_VALIDATE_CD_ES;

/* ---------------------------------------------------------------------
| CD Validation: FRANCE                                                 |
 ----------------------------------------------------------------------*/
PROCEDURE CE_VALIDATE_CD_FR(
        Xi_CD               in varchar2,
        Xi_PASS_MAND_CHECK  in varchar2,
        Xi_X_BANK_NUMBER    in varchar2,
        Xi_X_BRANCH_NUMBER  in varchar2,
        Xi_X_ACCOUNT_NUMBER in varchar2
) AS
    numeric_result_bk   varchar2(40);
    numeric_result_br   varchar2(40);
    numeric_result_cd   varchar2(40);
    numeric_result_ac   varchar2(40);
    calc_value          number(30);
    cd_value            varchar2(20);
    bk_value            varchar2(30);
    ac_value            varchar2(30);
    br_value            varchar2(30);


BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_cd_fr');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    CD_VALUE := upper(Xi_CD);
    bk_value := replace(replace(upper(Xi_X_BANK_NUMBER),' ',''),'-','');
    br_value := replace(replace(upper(Xi_X_BRANCH_NUMBER),' ',''),'-','');
    ac_value := translate(upper(Xi_X_ACCOUNT_NUMBER) ,
                        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
                        '12345678912345678923456789');
	ac_value := replace(replace(ac_value,' ',''),'-','');

    IF length(CD_VALUE) = 2
    THEN    /* length is ok */
        numeric_result_cd := ce_check_numeric(CD_VALUE,1,length(CD_VALUE));
        IF numeric_result_cd = '0'
        THEN
            /* its numeric so continue  */
            calc_value := mod(to_number(bk_value||br_value||ac_value||cd_value),97);
            IF calc_value = 0
            THEN
                ce_passed_check('CD','FR');
            ELSE
                ce_failed_check('CHECK_DIGIT','CD_FAILED');
            END IF; /* end of check digit validation */
        ELSE
            ce_failed_check('CHECK_DIGIT','NUMERIC');
        END IF;  /* end of numeric check */
    ELSE
        ce_failed_check('CHECK_DIGIT','LENGTH','2');
    END IF;  /* end of length check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_cd_fr');

END CE_VALIDATE_CD_FR;

/* ---------------------------------------------------------------------
| CD Validation: GERMANY                                                |
 ----------------------------------------------------------------------*/
PROCEDURE CE_VALIDATE_CD_DE(
    Xi_CD in varchar2,
    Xi_X_ACCOUNT_NUMBER in varchar2
) AS
    numeric_result_cd   VARCHAR2(40);
    ret_value           BOOLEAN;
    cd_value            VARCHAR2(50);
	ac_value            VARCHAR2(50);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_VALIDATE_CD_DE');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    cd_value := upper(Xi_CD);

    IF (cd_value IS NOT NULL)
    THEN    /* only validate if a value has been entered */
        IF length(cd_value) = 1
        THEN    /* length is ok */
            numeric_result_cd := ce_check_numeric(CD_VALUE,1,length(CD_VALUE));
            IF numeric_result_cd = '0'
            THEN
                /*it is numeric so continue*/
                -- compare CD with account number --
			    ac_value := upper(replace(Xi_X_ACCOUNT_NUMBER,' ',''));
			    ac_value := upper(replace(ac_value,'-',''));
                ret_value := compare_account_num_and_cd(ac_value,cd_value,1,0);
            ELSE
                ce_failed_check('CHECK_DIGIT','NUMERIC');
            END IF; /* end of numeric check */
        ELSE
            ce_failed_check('CHECK_DIGIT','LENGTH','1');
        END IF;  /* end of length check */
    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_VALIDATE_CD_DE');
END CE_VALIDATE_CD_DE;


/* ---------------------------------------------------------------------
| CD Validation: GREECE                                                 |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_CD_GR(
        Xi_CD               in varchar2,
        Xi_PASS_MAND_CHECK  in varchar2,
        Xi_X_BANK_NUMBER    in varchar2,
        Xi_X_BRANCH_NUMBER  in varchar2,
        Xi_X_ACCOUNT_NUMBER in varchar2
) AS

    numeric_result_cd   VARCHAR2(40);
    calc_value          NUMBER(30);
    cd_value            VARCHAR2(20);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_cd_gr');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    CD_VALUE := upper(Xi_CD);
    IF length(CD_VALUE) = 1
    THEN    /* length is ok */
        numeric_result_cd := ce_check_numeric(CD_VALUE,1,length(CD_VALUE));
        IF numeric_result_cd = '0'
        THEN
            ce_passed_check('CD','GR');
        ELSE
            ce_failed_check('CHECK_DIGIT','NUMERIC');
        END IF; /* end of numeric check */
    ELSE
        ce_failed_check('CHECK_DIGIT','LENGTH','1');
    END IF;  /* end of length check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_cd_gr');
END CE_VALIDATE_CD_GR;

/* ---------------------------------------------------------------------
| CD Validation: ICELAND                                                |
 ----------------------------------------------------------------------*/
PROCEDURE CE_VALIDATE_CD_IS(
        Xi_CD in varchar2,
        Xi_X_ACCOUNT_NUMBER in varchar2
) AS

    numeric_result_cd   VARCHAR2(50);
    ret_val             BOOLEAN;
    cd_value            VARCHAR2(50);
    ac_value            VARCHAR2(50);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_cd_is');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    CD_VALUE := upper(replace(Xi_CD,' ',''));
    ac_value := upper(replace(Xi_X_ACCOUNT_NUMBER,' ',''));
    ac_value := upper(replace(ac_value,'-',''));

    IF length(CD_VALUE) = 1
    THEN    /* length is ok */
        numeric_result_cd := ce_check_numeric(CD_VALUE,1,length(CD_VALUE));
        IF numeric_result_cd = '0'
        THEN    /* it is numeric so continue */
            ret_val := compare_account_num_and_cd(ac_value, CD_VALUE, 1,1);
        ELSE
            ce_failed_check('CHECK_DIGIT','NUMERIC');
        END IF; /* end of numeric check */
    ELSE
        ce_failed_check('CHECK_DIGIT','LENGTH','1');
    END IF;  /* end of length check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_cd_is');
END CE_VALIDATE_CD_IS;

/* ---------------------------------------------------------------------
| CD Validation: ITALY                                                  |
 ----------------------------------------------------------------------*/
PROCEDURE CE_VALIDATE_CD_IT(
        Xi_CD in varchar2,
        Xi_PASS_MAND_CHECK in varchar2,
        Xi_X_BANK_NUMBER in varchar2,
        Xi_X_BRANCH_NUMBER in varchar2,
        Xi_X_ACCOUNT_NUMBER in varchar2
) AS
    numeric_result_bk   varchar2(40);
    numeric_result_br   varchar2(40);
    numeric_result_cd   varchar2(40);
    numeric_result_ac   varchar2(40);
    CONCED_NUMBER       varchar2(30);
    calc_value          varchar2(30);
    calc_value1         number;
    calc_value2         number;
    calc_value3         number;
    cd_value            varchar2(20);
    bk_value            varchar2(30);
    ac_value            varchar2(30);
    br_value            varchar2(30);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/
FUNCTION get_odd_value(odd_value_in varchar2)
RETURN NUMBER IS
  odd_value_out number;
BEGIN
    IF    odd_value_in in ('A', '0') THEN     odd_value_out := 1;
    ELSIF odd_value_in in ('B', '1') THEN     odd_value_out := 0;
    ELSIF odd_value_in in ('C', '2') THEN     odd_value_out := 5;
    ELSIF odd_value_in in ('D', '3') THEN     odd_value_out := 7;
    ELSIF odd_value_in in ('E', '4') THEN     odd_value_out := 9;
    ELSIF odd_value_in in ('F', '5') THEN     odd_value_out := 13;
    ELSIF odd_value_in in ('G', '6') THEN     odd_value_out := 15;
    ELSIF odd_value_in in ('H', '7') THEN     odd_value_out := 17;
    ELSIF odd_value_in in ('I', '8') THEN     odd_value_out := 19;
    ELSIF odd_value_in in ('J', '9') THEN     odd_value_out := 21;
    ELSIF odd_value_in = 'K' THEN     odd_value_out := 2;
    ELSIF odd_value_in = 'L' THEN     odd_value_out := 4;
    ELSIF odd_value_in = 'M' THEN     odd_value_out := 18;
    ELSIF odd_value_in = 'N' THEN     odd_value_out := 20;
    ELSIF odd_value_in = 'O' THEN     odd_value_out := 11;
    ELSIF odd_value_in = 'P' THEN     odd_value_out := 3;
    ELSIF odd_value_in = 'Q' THEN     odd_value_out := 6;
    ELSIF odd_value_in = 'R' THEN     odd_value_out := 8;
    ELSIF odd_value_in = 'S' THEN     odd_value_out := 12;
    ELSIF odd_value_in = 'T' THEN     odd_value_out := 14;
    ELSIF odd_value_in = 'U' THEN     odd_value_out := 16;
    ELSIF odd_value_in = 'V' THEN     odd_value_out := 10;
    ELSIF odd_value_in = 'W' THEN     odd_value_out := 22;
    ELSIF odd_value_in = 'X' THEN     odd_value_out := 25;
    ELSIF odd_value_in = 'Y' THEN     odd_value_out := 24;
    ELSIF odd_value_in = 'Z' THEN     odd_value_out := 23;
  END IF;
  RETURN(odd_value_out);
END get_odd_value;

FUNCTION get_even_value(even_value_in varchar2)
RETURN NUMBER IS
  even_value_out number;
BEGIN
    IF    even_value_in IN ('A','0') THEN     even_value_out := 0;
    ELSIF even_value_in IN ('B','1') THEN     even_value_out := 1;
    ELSIF even_value_in IN ('C','2') THEN     even_value_out := 2;
    ELSIF even_value_in IN ('D','3') THEN     even_value_out := 3;
    ELSIF even_value_in IN ('E','4') THEN     even_value_out := 4;
    ELSIF even_value_in IN ('F','5') THEN     even_value_out := 5;
    ELSIF even_value_in IN ('G','6') THEN     even_value_out := 6;
    ELSIF even_value_in IN ('H','7') THEN     even_value_out := 7;
    ELSIF even_value_in IN ('I','8') THEN     even_value_out := 8;
    ELSIF even_value_in IN ('J','9') THEN     even_value_out := 9;
    ELSIF even_value_in = 'K' THEN     even_value_out := 10;
    ELSIF even_value_in = 'L' THEN     even_value_out := 11;
    ELSIF even_value_in = 'M' THEN     even_value_out := 12;
    ELSIF even_value_in = 'N' THEN     even_value_out := 13;
    ELSIF even_value_in = 'O' THEN     even_value_out := 14;
    ELSIF even_value_in = 'P' THEN     even_value_out := 15;
    ELSIF even_value_in = 'Q' THEN     even_value_out := 16;
    ELSIF even_value_in = 'R' THEN     even_value_out := 17;
    ELSIF even_value_in = 'S' THEN     even_value_out := 18;
    ELSIF even_value_in = 'T' THEN     even_value_out := 19;
    ELSIF even_value_in = 'U' THEN     even_value_out := 20;
    ELSIF even_value_in = 'V' THEN     even_value_out := 21;
    ELSIF even_value_in = 'W' THEN     even_value_out := 22;
    ELSIF even_value_in = 'X' THEN     even_value_out := 23;
    ELSIF even_value_in = 'Y' THEN     even_value_out := 24;
    ELSIF even_value_in = 'Z' THEN     even_value_out := 25;
    END IF;
    RETURN(even_value_out);
END get_even_value;

FUNCTION get_result_cd(remainder_value_in number)
RETURN varchar2 IS
  remainder_value_out VARCHAR2(1);
BEGIN
    IF    remainder_value_in =  '0' THEN     remainder_value_out := 'A';
    ELSIF remainder_value_in =  '1' THEN     remainder_value_out := 'B';
    ELSIF remainder_value_in =  '2' THEN     remainder_value_out := 'C';
    ELSIF remainder_value_in =  '3' THEN     remainder_value_out := 'D';
    ELSIF remainder_value_in =  '4' THEN     remainder_value_out := 'E';
    ELSIF remainder_value_in =  '5' THEN     remainder_value_out := 'F';
    ELSIF remainder_value_in =  '6' THEN     remainder_value_out := 'G';
    ELSIF remainder_value_in =  '7' THEN     remainder_value_out := 'H';
    ELSIF remainder_value_in =  '8' THEN     remainder_value_out := 'I';
    ELSIF remainder_value_in =  '9' THEN     remainder_value_out := 'J';
    ELSIF remainder_value_in =  '10' THEN     remainder_value_out := 'K';
    ELSIF remainder_value_in =  '11' THEN     remainder_value_out := 'L';
    ELSIF remainder_value_in =  '12' THEN     remainder_value_out := 'M';
    ELSIF remainder_value_in =  '13' THEN     remainder_value_out := 'N';
    ELSIF remainder_value_in =  '14' THEN     remainder_value_out := 'O';
    ELSIF remainder_value_in =  '15' THEN     remainder_value_out := 'P';
    ELSIF remainder_value_in =  '16' THEN     remainder_value_out := 'Q';
    ELSIF remainder_value_in =  '17' THEN     remainder_value_out := 'R';
    ELSIF remainder_value_in =  '18' THEN     remainder_value_out := 'S';
    ELSIF remainder_value_in =  '19' THEN     remainder_value_out := 'T';
    ELSIF remainder_value_in =  '20' THEN     remainder_value_out := 'U';
    ELSIF remainder_value_in =  '21' THEN     remainder_value_out := 'V';
    ELSIF remainder_value_in =  '22' THEN     remainder_value_out := 'W';
    ELSIF remainder_value_in =  '23' THEN     remainder_value_out := 'X';
    ELSIF remainder_value_in =  '24' THEN     remainder_value_out := 'Y';
    ELSIF remainder_value_in =  '25' THEN     remainder_value_out := 'Z';
    END IF;
    RETURN(remainder_value_out);
END get_result_cd;
                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN

    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_cd_it');
    cep_standard.debug('Xi_X_ACCOUNT_NUMBER: '||Xi_X_ACCOUNT_NUMBER);

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    CD_VALUE := upper(replace(Xi_CD,' ',''));
    bk_value := upper(replace(replace(Xi_X_BANK_NUMBER,' ',''),'-',''));
    br_value := upper(replace(replace(Xi_X_BRANCH_NUMBER,' ',''),'-',''));
    ac_value := upper(replace(replace(Xi_X_ACCOUNT_NUMBER,' ',''),'-',''));

    IF length(CD_VALUE) = 1
    THEN    /* length is ok */
        CONCED_NUMBER := bk_value||br_value||ac_value;

        calc_value1 := (get_odd_value(substr(conced_number,1,1)) +
                        get_even_value(substr(conced_number,2,1)) +
                        get_odd_value(substr(conced_number,3,1)) +
                        get_even_value(substr(conced_number,4,1)) +
                        get_odd_value(substr(conced_number,5,1)) +
                        get_even_value(substr(conced_number,6,1)) +
                        get_odd_value(substr(conced_number,7,1)) +
                        get_even_value(substr(conced_number,8,1)) +
                        get_odd_value(substr(conced_number,9,1)) +
                        get_even_value(substr(conced_number,10,1)) +
                        get_odd_value(substr(conced_number,11,1)) +
                        get_even_value(substr(conced_number,12,1)) +
                        get_odd_value(substr(conced_number,13,1)) +
                        get_even_value(substr(conced_number,14,1)) +
                        get_odd_value(substr(conced_number,15,1)) +
                        get_even_value(substr(conced_number,16,1)) +
                        get_odd_value(substr(conced_number,17,1)) +
                        get_even_value(substr(conced_number,18,1)) +
                        get_odd_value(substr(conced_number,19,1)) +
                        get_even_value(substr(conced_number,20,1)) +
                        get_odd_value(substr(conced_number,21,1)) +
                        get_even_value(substr(conced_number,22,1))) ;
        calc_value2 := nvl(mod(calc_value1,26),0);
        calc_value := get_result_cd(calc_value2);

        IF calc_value = CD_VALUE
        THEN
            ce_passed_check('CD','IT');
        ELSE
            ce_failed_check('CHECK_DIGIT','CD_FAILED');
        END IF; /* end of check digit validation */
    ELSE
        ce_failed_check('CHECK_DIGIT','LENGTH','1');
    END IF;  /* end of length check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_cd_it');
END CE_VALIDATE_CD_IT;

/* ---------------------------------------------------------------------
| CD Validation: LUXEMBOURG                                             |
 ----------------------------------------------------------------------*/
PROCEDURE CE_VALIDATE_CD_LU(
        Xi_CD               in varchar2,
        Xi_X_BANK_NUMBER    in varchar2,
        Xi_X_BRANCH_NUMBER  in varchar2,
        Xi_X_ACCOUNT_NUMBER in varchar2
) AS
    numeric_result_cd   VARCHAR2(40);
    account_value       VARCHAR2(30);
    check_digit         VARCHAR2(2);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_cd_lu');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    ACCOUNT_VALUE := lpad(Xi_X_ACCOUNT_NUMBER,12,0);
    CHECK_DIGIT := Xi_CD;

    IF length(CHECK_DIGIT) = 2
    THEN /*length is ok*/
        numeric_result_cd := ce_check_numeric(CHECK_DIGIT,1,length(CHECK_DIGIT));
        IF numeric_result_cd = '0'
        THEN
            ce_passed_check('CD','LU');
        ELSE
            ce_failed_check('CHECK_DIGIT','NUMERIC');
        END IF;  /* end of numeric check */
    ELSE
        ce_failed_check('CHECK_DIGIT','LENGTH','2');
    END IF;  /* end of length check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_cd_lu');
END CE_VALIDATE_CD_LU;

/* ---------------------------------------------------------------------
| CD Validation: SWEDEN                                                 |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_CD_SE(
        Xi_CD               in varchar2,
        Xi_X_ACCOUNT_NUMBER in varchar2
) AS
    numeric_result_cd   varchar2(40);
    calc_value          number(30);
    cd_value            varchar2(20);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_cd_se');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    CD_VALUE := upper(Xi_CD);

    IF length(CD_VALUE) = 1
    THEN    /* length is ok */

        numeric_result_cd := ce_check_numeric(CD_VALUE,1,length(CD_VALUE));
        IF numeric_result_cd = '0'
        THEN
            ce_passed_check('CD','SE');
        ELSE
            ce_failed_check('CHECK_DIGIT','NUMERIC');
        END IF; /* end of numeric check */
    ELSE
        ce_failed_check('CHECK_DIGIT','LENGTH','1');
    END IF;  /* end of length check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_cd_se');
END CE_VALIDATE_CD_SE;

-- 9249372: Added ce_validate_cd_fi
/* ---------------------------------------------------------------------
| CD Validation: FINLAND                                                |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_CD_FI(
        Xi_CD               in varchar2,
        Xi_X_BRANCH_NUMBER  in varchar2,
        Xi_X_ACCOUNT_NUMBER in varchar2
) AS

    branch_value      VARCHAR2(30);
    account_value     VARCHAR2(30);
    check_value       VARCHAR2(30);
    check_pad_value   VARCHAR2(30);
    int_val           NUMBER;
    weighted_sum      NUMBER;
    digit             NUMBER;
BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_cd_fi');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    branch_value := ce_remove_formats(Xi_X_Branch_Number);
    account_value := ce_remove_formats(Xi_X_Account_Number);

    IF length(Xi_CD) = 1
    THEN
        -- entered check digit should match the last digit of the account number.
        IF Xi_CD = substr(account_value,length(account_value))
        THEN
            -- check digit validation to be applied only if branch number available.
            IF(Xi_X_BRANCH_NUMBER IS NOT NULL)
            THEN
                check_value := branch_value || account_value;
                IF (SubStr(account_value,1,1) IN ('4','5'))
                THEN
                    check_pad_value := SubStr(check_value,1,7) ||
                    LPad(SubStr(check_value,8,Length(check_value)),7,'0');
                ELSE
                    check_pad_value := SubStr(check_value,1,6) ||
                    LPad(SubStr(check_value,7,Length(check_value)),8,'0');
                END IF;

                cep_standard.debug('check_pad_value='||check_pad_value);

                -- Luhn Mod 10 Alogrithm
                int_val := To_Number(
                            To_Char(SubStr(check_pad_value,1,1) *2)||
                            To_Char(SubStr(check_pad_value,2,1) *1)||
                            To_Char(SubStr(check_pad_value,3,1) *2)||
                            To_Char(SubStr(check_pad_value,4,1) *1)||
                            To_Char(SubStr(check_pad_value,5,1) *2)||
                            To_Char(SubStr(check_pad_value,6,1) *1)||
                            To_Char(SubStr(check_pad_value,7,1) *2)||
                            To_Char(SubStr(check_pad_value,8,1) *1)||
                            To_Char(SubStr(check_pad_value,9,1) *2)||
                            To_Char(SubStr(check_pad_value,10,1)*1)||
                            To_Char(SubStr(check_pad_value,11,1)*2)||
                            To_Char(SubStr(check_pad_value,12,1)*1)||
                            To_Char(SubStr(check_pad_value,13,1)*2)||
                            To_Char(SubStr(check_pad_value,14,1)*1)
                            );
                cep_standard.debug('int_val='||int_val);

                weighted_sum := 0;
                WHILE int_val <> 0 LOOP
                    digit := Mod(int_val,10);
                    weighted_sum := weighted_sum + digit;
                    int_val := floor(int_val/10);
                END LOOP;

                cep_standard.debug ('weighted_sum='||weighted_sum);

                IF (Mod(weighted_sum,10)=0)
                THEN
                    ce_passed_check('CHECK_DIGIT','FI');
                ELSE
                    ce_failed_check('CHECK_DIGIT','CD_FAILED');
                END IF;

            ELSE
                /* No branch number. CD Algo skipped */
                ce_passed_check('CD','FI');
            END IF; /* end of branch number check */

        ELSE
            -- Account number and CD do not match
            FND_MESSAGE.set_name('CE','CE_ACCT_NUM_CD_MISMATCH');
            FND_MSG_PUB.add;
        END IF; /* last digit check */
    ELSE
        ce_failed_check('CHECK_DIGIT','LENGTH','1');
    END IF; /* length check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_cd_fi');
END CE_VALIDATE_CD_FI;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_BRANCH_*                                             |
|                                                                       |
|  CALLED BY                                                            |
|      CE_VALIDATE_BRANCH                                               |
|                                                                       |
|  DESCRIPTION                                                          |
|      Branch PROCEDURES, Validate 1 or more of the following:          |
|      1. Branch number length                                          |
|      2. Branch number datatype (numeric, alphanumeric, or alphabet    |
|      3. Branch number Algorithm                                       |
|                                                                       |
|  RETURN                                                               |
|      Xo_VALUE_OUT - Branch Number is return with leading 0            |
|                     (Not for all countries)                           |
 --------------------------------------------------------------------- */

/* ---------------------------------------------------------------------
| Branch Number Validation: AUSTRIA                                     |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BRANCH_AT(
        Xi_BRANCH_NUMBER  in varchar2,
        Xi_PASS_MAND_CHECK in varchar2,
        Xo_VALUE_OUT OUT NOCOPY varchar2
) AS

    branch_value VARCHAR2(30);
    numeric_result VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_branch_at');

    Xo_VALUE_OUT := Xi_BRANCH_NUMBER;

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    BRANCH_VALUE := upper(Xi_BRANCH_NUMBER);
    -- 8266356: Branch Number is not mandatory.
    IF BRANCH_VALUE IS NOT NULL
    THEN
        BRANCH_VALUE := replace(replace(BRANCH_VALUE,' ',''),'-','');
        IF ( length(BRANCH_VALUE) = 5 )
        THEN
            /* length is ok */
            numeric_result := ce_check_numeric(BRANCH_VALUE,1,length(BRANCH_VALUE));
            IF (numeric_result = '0')
            THEN
                /* its numeric validations successful */
                Xo_VALUE_OUT := BRANCH_VALUE;
                ce_passed_check('BRANCH','AT');
            ELSE
                ce_failed_check('BRANCH_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        ELSE
            ce_failed_check('BRANCH_NUM','LENGTH','5');
        END IF;  /* end of length check */
    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_branch_at');
END CE_VALIDATE_BRANCH_AT;

/* ---------------------------------------------------------------------
| Branch Number Validation: PORTUGAL                                    |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BRANCH_PT(
        Xi_BRANCH_NUMBER    in varchar2,
        Xi_PASS_MAND_CHECK  in varchar2
) AS
        branch_value    VARCHAR2(30);
        numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_branch_pt');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    BRANCH_VALUE := upper(Xi_BRANCH_NUMBER);

    IF Xi_PASS_MAND_CHECK = 'F'
    THEN
        ce_failed_mandatory('BRANCH_NUM');

    ELSIF Xi_PASS_MAND_CHECK = 'P'
    THEN
        BRANCH_VALUE := replace(replace(BRANCH_VALUE,' ',''),'-','');
        IF length(BRANCH_VALUE) = 4
        THEN    /* length is ok */
            numeric_result := ce_check_numeric(BRANCH_VALUE,1,length(BRANCH_VALUE));
            IF numeric_result = '0'
            THEN /* it's numeric - validations successful */
                ce_passed_check('BRANCH','PT');
            ELSE
                ce_failed_check('BRANCH_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        ELSE
            ce_failed_check('BRANCH_NUM','LENGTH','4');
        END IF;  /* end of length check */
    END IF; /* end of mandatory check  */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_branch_pt');
END CE_VALIDATE_BRANCH_PT;

/* ---------------------------------------------------------------------
| Branch Number Validation: FRANCE                                      |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BRANCH_FR(
        Xi_BRANCH_NUMBER    in varchar2,
        Xi_PASS_MAND_CHECK  in varchar2,
        Xo_VALUE_OUT        OUT NOCOPY varchar2
) AS

branch_value VARCHAR2(30);
numeric_result VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_branch_fr');


    Xo_VALUE_OUT := Xi_BRANCH_NUMBER;
    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    BRANCH_VALUE := upper(Xi_BRANCH_NUMBER );
    IF Xi_PASS_MAND_CHECK = 'F'
    THEN
        ce_failed_mandatory('BRANCH_NUM');
    ELSIF Xi_PASS_MAND_CHECK = 'P'
    THEN

        BRANCH_VALUE := replace(replace(BRANCH_VALUE,' ',''),'-','');
        IF length(BRANCH_VALUE) > 5
        THEN
            ce_failed_check('BRANCH_NUM','LENGTH_MAX','5');
        ELSE    /* length is ok */
            numeric_result := ce_check_numeric(BRANCH_VALUE,1,length(BRANCH_VALUE));
            IF numeric_result = '0'
            THEN    /* its numeric - validations successful */
                BRANCH_VALUE := lpad(BRANCH_VALUE,5,0);
                Xo_VALUE_OUT := BRANCH_VALUE;
                ce_passed_check('BRANCH','FR');
            ELSE
                ce_failed_check('BRANCH_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        END IF;  /* end of length check */
    END IF; /* end of mandatory check  */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_branch_fr');
END CE_VALIDATE_BRANCH_FR;

/* ---------------------------------------------------------------------
| Branch Number Validation: SPAIN                                       |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BRANCH_ES (
        Xi_BRANCH_NUMBER    in varchar2,
        Xi_PASS_MAND_CHECK  in varchar2,
        Xo_VALUE_OUT        out nocopy varchar2
) AS

    BRANCH_VALUE    varchar2(30);
    NUMERIC_RESULT  varchar2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_branch_es');

    Xo_VALUE_OUT := Xi_BRANCH_NUMBER;
    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    BRANCH_VALUE := upper(Xi_BRANCH_NUMBER );
    BRANCH_VALUE := replace(replace(BRANCH_VALUE,' ',''),'-','');

    IF Xi_PASS_MAND_CHECK = 'F'
    THEN
        ce_failed_mandatory('BRANCH_NUM');

    ELSIF Xi_PASS_MAND_CHECK = 'P'
    THEN
        IF length(BRANCH_VALUE) > 4
        THEN
            ce_failed_check('BRANCH_NUM','LENGTH_MAX','4');
        ELSE    /* length is ok */
            numeric_result := ce_check_numeric(BRANCH_VALUE,1,length(BRANCH_VALUE));
            IF numeric_result = '0'
            THEN    /* it's numeric - validations successful */
                BRANCH_VALUE := lpad(BRANCH_VALUE,4,0);
                Xo_VALUE_OUT := BRANCH_VALUE;
                ce_passed_check('BRANCH','ES');
            ELSE
                ce_failed_check('BRANCH_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        END IF;  /* end of length check */
    END IF; /* end of mandatory check  */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_branch_es');
END CE_VALIDATE_BRANCH_ES;

/* ---------------------------------------------------------------------
| Branch Number Validation: BRAZIL                                      |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BRANCH_BR(
        Xi_BRANCH_NUMBER    in varchar2,
        Xi_PASS_MAND_CHECK  in varchar2,
        Xo_VALUE_OUT        OUT NOCOPY varchar2
) AS

    branch_value    VARCHAR2(30);
    numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_branch_br');

    -- 6083246: Brazil Branch number is not standardized and there should be
    -- no validation for this field.
    Xo_VALUE_OUT := Xi_BRANCH_NUMBER ;
    ce_passed_check('BRANCH','BR');

    /*----
    BRANCH_VALUE := upper(Xi_BRANCH_NUMBER );
    Xo_VALUE_OUT := BRANCH_VALUE;

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    IF Xi_PASS_MAND_CHECK = 'F'
    THEN
        ce_failed_mandatory('BRANCH_NUM');
    ELSIF Xi_PASS_MAND_CHECK = 'P'
    THEN
        BRANCH_VALUE := replace(replace(BRANCH_VALUE,' ',''),'-','');
        IF length(BRANCH_VALUE) > 5
        THEN
            ce_failed_check('BRANCH_NUM','LENGTH_MAX','5');
        ELSE
            -- length is ok
            numeric_result := ce_check_numeric(BRANCH_VALUE,1,length(BRANCH_VALUE));
            IF numeric_result = '0'
            THEN
                -- its numeric - validations successful
                BRANCH_VALUE := lpad(BRANCH_VALUE,5,0);
                Xo_VALUE_OUT := BRANCH_VALUE;
                ce_passed_check('BRANCH','BR');
            ELSE
                ce_failed_check('BRANCH_NUM','NUMERIC');
            END IF;  -- end of numeric check
        END IF;  -- end of length check
    END IF; -- end of mandatory check
    ----*/

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_branch_br');
END CE_VALIDATE_BRANCH_BR;

/* ---------------------------------------------------------------------
| Branch Number Validation: GERMANY                                     |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BRANCH_DE(
    Xi_BRANCH_NUMBER  in varchar2,
    Xi_BANK_ID        in number
) AS

    branch_num      VARCHAR2(30);
    numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_branch_de');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    BRANCH_NUM := upper(replace(Xi_BRANCH_NUMBER,' ',''));
    BRANCH_NUM := replace(BRANCH_NUM,'-','');

    IF (BRANCH_NUM) IS NOT NULL
    THEN    /* only validate if a value has been entered */
        IF length(BRANCH_NUM) = 8
        THEN    /* length is ok */
            numeric_result := ce_check_numeric(BRANCH_NUM,1,length(BRANCH_NUM));
            IF numeric_result = '0'
            THEN  /* its numeric so continue  */
                -- Bank number and branch number should be the same
                compare_bank_and_branch_num(BRANCH_NUM, Xi_BANK_ID);
            ELSE
                ce_failed_check('BRANCH_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        ELSE
            ce_failed_check('BRANCH_NUM','LENGTH','8');
        END IF;  /* end of length check */
    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_branch_de');
END CE_VALIDATE_BRANCH_DE;

/* ---------------------------------------------------------------------
| Branch Number Validation: GREECE                                       |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BRANCH_GR(
        Xi_BRANCH_NUMBER  in varchar2
) AS

    branch_value    VARCHAR2(30);
    numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_branch_gr');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    BRANCH_VALUE := upper(replace(Xi_BRANCH_NUMBER,' ',''));
    BRANCH_VALUE := replace(BRANCH_VALUE,'-','');

    IF (BRANCH_VALUE) IS NOT NULL
    THEN    /* only validate if a value has been entered */
        IF length(BRANCH_VALUE) > 4
        THEN
            ce_failed_check('BRANCH_NUM','LENGTH_MAX','4');
        ELSE    /* length is ok */
            numeric_result := ce_check_numeric(BRANCH_VALUE,1,length(BRANCH_VALUE));
            IF numeric_result = '0'
            THEN    /* it's numeric - validations successful*/
                ce_passed_check('BRANCH','GR');
            ELSE
                ce_failed_check('BRANCH_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        END IF;  /* end of length check */
    END IF; /* end of null check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_branch_gr');
END CE_VALIDATE_BRANCH_GR;

/* ---------------------------------------------------------------------
| Branch Number Validation: ICELAND                                     |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BRANCH_IS(
        Xi_BRANCH_NUMBER IN VARCHAR2,
        Xi_BANK_ID       IN NUMBER,
        Xo_VALUE_OUT     OUT NOCOPY VARCHAR2
) AS

    branch_num      VARCHAR2(60);
    numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_branch_is');

    Xo_VALUE_OUT := Xi_BRANCH_NUMBER;
    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    BRANCH_NUM := upper(replace(Xi_BRANCH_NUMBER,' ',''));
    BRANCH_NUM := replace(BRANCH_NUM,'-','');

    IF (BRANCH_NUM) IS NOT NULL
    THEN    /* only validate if a branch number has been entered */
        IF length(BRANCH_NUM) > 4
        THEN
            ce_failed_check('BRANCH_NUM','LENGTH_MAX','4');
        ELSE    /* length is ok */
            numeric_result := ce_check_numeric(BRANCH_NUM,1,length(BRANCH_NUM));
            IF numeric_result = '0'
            THEN /* its numeric so continue  */
                -- Bank number and branch number should be the same
                BRANCH_NUM := lpad(BRANCH_NUM,4,0);
                Xo_VALUE_OUT := BRANCH_NUM;
                compare_bank_and_branch_num(branch_num, Xi_BANK_ID);
            ELSE
                ce_failed_check('BRANCH_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        END IF;  /* end of length check */
    ELSE
        ce_passed_check('BRANCH','IS');
    END IF;  /* end of null check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_branch_is');
END CE_VALIDATE_BRANCH_IS;


/* ---------------------------------------------------------------------
| Branch Number Validation: IRELAND                                     |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BRANCH_IE(
        Xi_BRANCH_NUMBER  in varchar2,
        Xi_BANK_ID        in number
) AS

    branch_num      VARCHAR2(60);
    numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_branch_ie');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    BRANCH_NUM := upper(replace(Xi_BRANCH_NUMBER,' ',''));
    BRANCH_NUM := replace(BRANCH_NUM,'-','');

    IF (BRANCH_NUM) IS NOT NULL
    THEN    /* only validate if a value has been entered */
        -- Bug 6846899 : Valid length is 6 not 8
        IF length(BRANCH_NUM) = 6
        THEN    /* length is ok */
            numeric_result := ce_check_numeric(BRANCH_NUM,1,length(BRANCH_NUM));
            IF numeric_result = '0'
            THEN /* its numeric so continue  */
                -- Bank number and branch number should be the same
                compare_bank_and_branch_num(branch_num, Xi_BANK_ID);
            ELSE
                ce_failed_check('BRANCH_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        ELSE
            ce_failed_check('BRANCH_NUM','LENGTH','6');
        END IF;  /* end of length check */
    ELSE
        ce_passed_check('BRANCH','IE');
    END IF; /* end of null check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_branch_ie');
END CE_VALIDATE_BRANCH_IE;

/* ---------------------------------------------------------------------
| Branch Number Validation: ITALY                                       |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BRANCH_IT(
        Xi_BRANCH_NUMBER    in varchar2,
        Xi_PASS_MAND_CHECK  in varchar2
) AS

    branch_value    VARCHAR2(30);
    numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_branch_it');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    BRANCH_VALUE := upper(replace(Xi_BRANCH_NUMBER,' ',''));
    BRANCH_VALUE := replace(BRANCH_VALUE,'-','');

    IF Xi_PASS_MAND_CHECK = 'F'
    THEN
        ce_failed_mandatory('BRANCH_NUM');
    ELSIF Xi_PASS_MAND_CHECK = 'P'
    THEN
        IF length(BRANCH_VALUE) = 5
        THEN    /* length is ok */
            numeric_result := ce_check_numeric(BRANCH_VALUE,1,length(BRANCH_VALUE));
            IF numeric_result = '0'
            THEN    /* it's numeric - validations successful */
                ce_passed_check('BRANCH','IT');
            ELSE
                ce_failed_check('BRANCH_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        ELSE
            ce_failed_check('BRANCH_NUM','LENGTH','5');
        END IF;  /* end of length check */
    END IF; /* end of mandatory check  */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_branch_it');
END CE_VALIDATE_BRANCH_IT;

/* ---------------------------------------------------------------------
| Branch Number Validation: LUXEMBOURG                                  |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BRANCH_LU(
        Xi_BRANCH_NUMBER  in varchar2,
        Xi_BANK_ID        in number
) AS
    branch_num      VARCHAR2(60);
    numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_branch_lu');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove hyphens and spaces --
    BRANCH_NUM := upper(replace(Xi_BRANCH_NUMBER,' ',''));
    BRANCH_NUM := replace(BRANCH_NUM,'-','');

    IF (BRANCH_NUM) IS NOT NULL
    THEN    /* only validate if a value has been entered */
        -- 6005620: Bank/Branch Num length is 3
        IF length(BRANCH_NUM) = 3
        THEN /* length is ok */
            numeric_result := ce_check_numeric(BRANCH_NUM,1,length(BRANCH_NUM));
            IF numeric_result = '0'
            THEN /* its numeric so continue  */
                -- Bank number and branch number should be the same
                compare_bank_and_branch_num(BRANCH_NUM, Xi_BANK_ID);
            ELSE
                ce_failed_check('BRANCH_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        ELSE
            ce_failed_check('BRANCH_NUM','LENGTH','3');
        END IF;  /* end of length check */
    ELSE
        ce_passed_check('BRANCH','LU');
    END IF; /* end of null check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_branch_lu');
END CE_VALIDATE_BRANCH_LU;

/* ---------------------------------------------------------------------
| Branch Number Validation: POLAND                                      |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BRANCH_PL(
        Xi_BRANCH_NUMBER  in varchar2,
        Xi_BANK_ID        in NUMBER
) AS

    branch_num      VARCHAR2(60);
    numeric_result  VARCHAR2(40);
    cal_cd1         NUMBER;

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_branch_pl');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    BRANCH_NUM := upper(replace(Xi_BRANCH_NUMBER,' ',''));
    BRANCH_NUM := replace(BRANCH_NUM,'-','');

    IF (BRANCH_NUM) IS NOT NULL
    THEN    /* only validate if a value has been entered */
        IF length(BRANCH_NUM) = 8
        THEN    /* length is ok */
            numeric_result := ce_check_numeric(BRANCH_NUM,1,length(BRANCH_NUM));
            IF numeric_result = '0'
            THEN /* its numeric so continue  */
                -- Bank number and branch number should be the same
                compare_bank_and_branch_num(BRANCH_NUM, Xi_BANK_ID);
                -- Bug 7454786: No check digit validation for Poland
                ce_passed_check('BRANCH','PL');
            ELSE
                ce_failed_check('BRANCH_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        ELSE
            ce_failed_check('BRANCH_NUM','LENGTH','8');
        END IF; /* end of length check */
    ELSE
        ce_passed_check('BRANCH','PL');
    END IF; /* end of null check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_branch_pl');
END CE_VALIDATE_BRANCH_PL;

/* ---------------------------------------------------------------------
| Branch Number Validation: SWEDEN                                      |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BRANCH_SE(
        Xi_BRANCH_NUMBER  in varchar2,
        Xi_BANK_ID        in number
) AS

    branch_num      VARCHAR2(60);
    numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_branch_se');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove hyphens and spaces --
    BRANCH_NUM := upper(replace(Xi_BRANCH_NUMBER,' ',''));
    BRANCH_NUM := replace(BRANCH_NUM,'-','');

    IF (BRANCH_NUM) IS NOT NULL
    THEN    /* only validate if a value has been entered */
        IF (length(BRANCH_NUM) < 4)
        THEN
            ce_failed_check('BRANCH_NUM','LENGTH_MIN','4');

        ELSIF (length(BRANCH_NUM) > 5)
        THEN
            ce_failed_check('BRANCH_NUM','LENGTH_MAX','5');

        ELSE    /* length is ok */
            numeric_result := ce_check_numeric(BRANCH_NUM,1,length(BRANCH_NUM));
            IF numeric_result = '0'
            THEN    /* its numeric so continue  */
                -- Bank number and branch number should be the same
                compare_bank_and_branch_num(BRANCH_NUM, Xi_BANK_ID);
            ELSE
                ce_failed_check('BRANCH_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        END IF;  /* end of length check */
    ELSE
        ce_passed_check('BRANCH','SE');
    END IF; /* end of null check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_branch_se');
END CE_VALIDATE_BRANCH_SE;


/* ---------------------------------------------------------------------
| Branch Number Validation: SWITZERLAND                                 |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BRANCH_CH(
        Xi_BRANCH_NUMBER  in varchar2,
        Xi_BANK_ID        in number
) AS

    branch_num      VARCHAR2(60);
    numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_branch_ch');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    BRANCH_NUM := upper(replace(Xi_BRANCH_NUMBER,' ',''));
    BRANCH_NUM := replace(BRANCH_NUM,'-','');

    IF (BRANCH_NUM) IS NOT NULL
    THEN /* only validate if a value has been entered */
        -- Bug 6208182 - Length of the branch number should be between 7 to 9
        -- numeric digits. (Changed from 3 -> 6)
		-- Bug 6885135 - Length restriction changed to (3->9)
        IF (length(BRANCH_NUM) < 3)
        THEN
            ce_failed_check('BRANCH_NUM','LENGTH_MIN','3');
        ELSIF (length(BRANCH_NUM) > 9)
        THEN
            ce_failed_check('BRANCH_NUM','LENGTH_MAX','9');
        ELSE    /* length is ok */
            numeric_result := ce_check_numeric(BRANCH_NUM,1,length(BRANCH_NUM));
            IF numeric_result = '0'
            THEN /* its numeric so continue  */
                -- Bank number and branch number should be the same
                -- Bug 6208182 - validation to check if bank and branch number are same
                -- is not required for swiss banks.
                -- compare_bank_and_branch_num(branch_num, Xi_BANK_ID);
                ce_passed_check('BRANCH','CH');
            ELSE
                ce_failed_check('BRANCH_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        END IF; /* end of length check */
    ELSE
        ce_passed_check('BRANCH','CH');
    END IF; /* end of null check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_branch_ch');
END CE_VALIDATE_BRANCH_CH;

/* ---------------------------------------------------------------------
| Branch Number Validation: UNITED KINGDOM                              |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BRANCH_GB(
        Xi_BRANCH_NUMBER  in varchar2,
        Xi_BANK_ID        in number
) AS

        branch_num      VARCHAR2(60);
        numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_branch_gb');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    BRANCH_NUM := upper(replace(Xi_BRANCH_NUMBER,' ',''));
    BRANCH_NUM := replace(BRANCH_NUM,'-','');

    IF (BRANCH_NUM) IS NOT NULL
    THEN    /* only validate if a value has been entered */
        IF length(BRANCH_NUM) = 6
        THEN    /* length is ok */
            numeric_result := ce_check_numeric(BRANCH_NUM,1,length(BRANCH_NUM));
            IF numeric_result = '0'
            THEN /* its numeric so continue  */
                -- Bank number and branch number should be the same
                compare_bank_and_branch_num(BRANCH_NUM, Xi_BANK_ID);
            ELSE
                ce_failed_check('BRANCH_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        ELSE
            ce_failed_check('BRANCH_NUM','LENGTH','6');
        END IF;  /* end of length check */
    ELSE
        ce_passed_check('BRANCH','GB');
    END IF; /* end of null check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_branch_gb');
END CE_VALIDATE_BRANCH_GB;

/* ---------------------------------------------------------------------
| Branch Number Validation: UNITED STATES                               |
| For the US, Branch Number is Routing Transit Number                   |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BRANCH_US(
        Xi_BRANCH_NUMBER    in varchar2,
        Xi_PASS_MAND_CHECK  in varchar2,
        Xo_VALUE_OUT        OUT NOCOPY varchar2
) AS

    branch_value        VARCHAR2(30);
    branch_value_out    VARCHAR2(30);
    cal_cd1             NUMBER;
    cd_value            NUMBER;
    l_mod_value         NUMBER;
    numeric_result      VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_branch_us');

    Xo_VALUE_OUT := Xi_BRANCH_NUMBER;
    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    BRANCH_VALUE := upper(replace(Xi_BRANCH_NUMBER,' ',''));
    BRANCH_VALUE := replace(BRANCH_VALUE,'-','');

    -- Branch Number is optional for all US banks --
    IF Xi_PASS_MAND_CHECK = 'P'
    THEN    /* only validate if value has been entered */
        IF length(BRANCH_VALUE) > 9
        THEN
            ce_failed_check('ROUTE_NUM','LENGTH_MAX','9');
        ELSE    /* length is ok */

            numeric_result := ce_check_numeric(BRANCH_VALUE,1,length(BRANCH_VALUE));
            IF numeric_result = '0'
            THEN    /* it is numeric */

                BRANCH_VALUE_OUT := lpad(BRANCH_VALUE,9,0);
                IF (substr(BRANCH_VALUE_OUT,1,8) = '00000000')
                THEN    /* After padding to 9 digits, the leading 8 cannot be all 0 */
                    ce_failed_check('ROUTE_NUM','INVALID_RTN');
                ELSE
                    -- Modulus 10
                    l_mod_value :=  mod(((to_number(substr(BRANCH_VALUE_OUT,1,1)) * 3)
                                    + (to_number(substr(BRANCH_VALUE_OUT,2,1)) * 7)
                                    + (to_number(substr(BRANCH_VALUE_OUT,3,1)) * 1)
                                    + (to_number(substr(BRANCH_VALUE_OUT,4,1)) * 3)
                                    + (to_number(substr(BRANCH_VALUE_OUT,5,1)) * 7)
                                    + (to_number(substr(BRANCH_VALUE_OUT,6,1)) * 1)
                                    + (to_number(substr(BRANCH_VALUE_OUT,7,1)) * 3)
                                    + (to_number(substr(BRANCH_VALUE_OUT,8,1)) * 7)),10);

                    -- Bug 6052424  changed the IN clause
                    IF (l_mod_value IN (0)) THEN
                        cal_cd1:=l_mod_value;
                    ELSE
                        cal_cd1 :=10-l_mod_value;
                    END IF;
                    cd_value := substr(BRANCH_VALUE_OUT,9,1);

                    IF cal_cd1 = cd_value
                    THEN    /* check digit checks out validations successful */
                        Xo_VALUE_OUT := BRANCH_VALUE_OUT;
                        ce_passed_check('BRANCH','US');
                    ELSE
                        ce_failed_check('ROUTE_NUM','CD_FAILED');
                    END IF;
                END IF; /* end of padding check */
            ELSE
                ce_failed_check('ROUTE_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        END IF;  /* end length check */
    ELSE
        ce_passed_check('BRANCH','US');
    END IF;  /* end of null check  */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_branch_us');
END CE_VALIDATE_BRANCH_US;

/* ---------------------------------------------------------------------
| Branch Number Validation: AUSTRALIA                                   |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BRANCH_AU(
        Xi_BRANCH_NUMBER    in varchar2,
        Xi_BANK_ID          in NUMBER,
        Xi_PASS_MAND_CHECK  in varchar2
) AS

    BRANCH_VALUE            varchar2(30);
    BANK_VALUE              varchar2(30);
    BANK_num                varchar2(30);
    valid_branch_length     number;
    numeric_result          varchar2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_branch_au');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    BRANCH_VALUE := upper(replace(Xi_BRANCH_NUMBER,' ',''));
    BRANCH_VALUE := replace(BRANCH_VALUE,'-','');


    IF Xi_PASS_MAND_CHECK = 'F'
    THEN
        ce_failed_mandatory('BRANCH_NUM');

    ELSIF Xi_PASS_MAND_CHECK = 'P'
    THEN
        -- Bug 6856840: Added IF clause to handle cases where Bank ID is the Bank Number
        IF BANK_ID_IS_NUM = TRUE
        THEN
            bank_num := Xi_BANK_ID;
        ELSE
            -- fetch the bank number
            OPEN  get_bank_num(Xi_BANK_ID);
            FETCH get_bank_num INTO bank_num;
            CLOSE get_bank_num;
        END IF;
		BANK_VALUE := upper(replace(bank_num,' ',''));
		BANK_VALUE := replace(BANK_VALUE,'-','');

		-- Bank number and branch number should have total of 6 digits --
        valid_branch_length := 6 - nvl(length(BANK_VALUE), 0);
        IF (length(BRANCH_VALUE) = valid_branch_length)
        THEN
            /* length is ok */
            numeric_result := ce_check_numeric(BRANCH_VALUE,1,length(BRANCH_VALUE));
            IF numeric_result = '0'
            THEN
                /* its numeric - validations successful */
                ce_passed_check('BRANCH','AU');
            ELSE
                ce_failed_check('BRANCH_NUM','NUMERIC');
            END IF; /* end of numeric check */
        ELSE
            ce_failed_check('BRANCH_NUM','LENGTH',to_char(valid_branch_length));
        END IF; /* end of length check */

    END IF; /* end of mandatory check  */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_branch_au');
END CE_VALIDATE_BRANCH_AU;

/* ---------------------------------------------------------------------
| Branch Number Validation: ISRAEL                                      |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BRANCH_IL(
        Xi_BRANCH_NUMBER    in varchar2,
        Xi_PASS_MAND_CHECK  in varchar2
) AS

    branch_value    VARCHAR2(30);
    numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_branch_il');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    BRANCH_VALUE := upper(replace(Xi_BRANCH_NUMBER,' ',''));
    BRANCH_VALUE := replace(BRANCH_VALUE,'-','');

    IF Xi_PASS_MAND_CHECK = 'F'
    THEN
        ce_failed_mandatory('BRANCH_NUM');

    ELSIF Xi_PASS_MAND_CHECK = 'P'
    THEN
        IF length(BRANCH_VALUE) = 3
        THEN    /* length is ok */
            numeric_result := ce_check_numeric(BRANCH_VALUE,1,length(BRANCH_VALUE));
            IF numeric_result = '0'
            THEN    /* it's numeric - validations successful */
                ce_passed_check('BRANCH','IL');
            ELSE
                ce_failed_check('BRANCH_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        ELSE
            ce_failed_check('BRANCH_NUM','LENGTH','3');
        END IF;  /* end of length check */
    END IF; /* end of mandatory check  */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_branch_il');
END CE_VALIDATE_BRANCH_IL;

/* ---------------------------------------------------------------------
| Branch Number Validation: NEW ZEALAND                                 |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BRANCH_NZ(
        Xi_BRANCH_NUMBER    in varchar2,
        Xi_PASS_MAND_CHECK  in varchar2
) AS

    branch_value    VARCHAR2(30);
    numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_branch_nz');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove hyphens and spaces --
    BRANCH_VALUE := upper(replace(Xi_BRANCH_NUMBER,' ',''));
    BRANCH_VALUE := replace(BRANCH_VALUE,'-','');

    IF Xi_PASS_MAND_CHECK = 'F'
    THEN
        ce_failed_mandatory('BRANCH_NUM');

    ELSIF Xi_PASS_MAND_CHECK = 'P'
    THEN
        IF length(BRANCH_VALUE) = 4
        THEN    /* length is ok */
            numeric_result := ce_check_numeric(BRANCH_VALUE,1,length(BRANCH_VALUE));
            IF numeric_result = '0'
            THEN    /* it's numeric - validations successful */
                ce_passed_check('BRANCH','NZ');
            ELSE
                ce_failed_check('BRANCH_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        ELSE
            ce_failed_check('BRANCH_NUM','LENGTH','4');
        END IF;  /* end of length check */
    END IF; /* end of mandatory check  */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_branch_nz');
END CE_VALIDATE_BRANCH_NZ;

/* ---------------------------------------------------------------------
| Branch Number Validation: JAPAN                                       |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BRANCH_JP(
        Xi_BRANCH_NUMBER    in varchar2,
        Xi_BRANCH_NAME_ALT  in varchar2,
        Xi_PASS_MAND_CHECK  in varchar2
) AS

    branch_value    VARCHAR2(30);
    numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_branch_jp');

    -- 7582842: This validation fires irrespective of disable profile
    -- Check that Branch Name Alt has been entered --
    IF (Xi_BRANCH_NAME_ALT  IS NULL)
    THEN
       ce_failed_mandatory('BRANCH_NAME_ALT');
    END IF;

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('branch number validations disabled.');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    BRANCH_VALUE := upper(replace(Xi_BRANCH_NUMBER,' ',''));
    BRANCH_VALUE := replace(BRANCH_VALUE,'-','');

    IF Xi_PASS_MAND_CHECK = 'F'
    THEN
        ce_failed_mandatory('BRANCH_NUM');
    ELSIF Xi_PASS_MAND_CHECK = 'P'
    THEN
        -- bug 5746679 change from 4 numeric digits to 3 numeric digits
        IF length(BRANCH_VALUE) = 3
        THEN    /* length is ok */
            numeric_result := ce_check_numeric(BRANCH_VALUE,1,length(BRANCH_VALUE));
            IF numeric_result = '0'
            THEN    /* it's numeric - validations successful*/
                ce_passed_check('BRANCH','JP');
            ELSE
                ce_failed_check('BRANCH_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        ELSE
            ce_failed_check('BRANCH_NUM','LENGTH','3');
        END IF;  /* end of length check */
    END IF; /* end of mandatory check  */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_branch_jp');
END CE_VALIDATE_BRANCH_JP;

-- Bug 9249372: Added
/* ---------------------------------------------------------------------
| Branch Number Validation: FINLAND                                     |
 ----------------------------------------------------------------------*/
PROCEDURE CE_VALIDATE_BRANCH_FI(
        Xi_BRANCH_NUMBER    IN VARCHAR2
) AS

    branch_value    VARCHAR2(30);
    numeric_result  VARCHAR2(40);
BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_branch_fi');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('branch number validations disabled.');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    BRANCH_VALUE := upper(replace(Xi_BRANCH_NUMBER,' ',''));
    BRANCH_VALUE := replace(BRANCH_VALUE,'-','');

    IF Xi_BRANCH_NUMBER IS NOT NULL
    THEN
        IF length(BRANCH_VALUE) = 6
        THEN    /* length is ok */
            numeric_result := ce_check_numeric(BRANCH_VALUE,1,length(BRANCH_VALUE));
            IF numeric_result = '0'
            THEN    /* it's numeric - validations successful*/
                ce_passed_check('BRANCH','FI');
            ELSE
                ce_failed_check('BRANCH_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        ELSE
            ce_failed_check('BRANCH_NUM','LENGTH','6');
        END IF;  /* end of length check */
    END IF; /* end of mandatory check  */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_branch_fi');
END CE_VALIDATE_BRANCH_FI;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_ACCOUNT_*                                            |
|                                                                       |
|  CALLED BY                                                            |
|      CE_VALIDATE_ACCOUNT                                              |
|                                                                       |
|  DESCRIPTION                                                          |
|      ACCOUNT PROCEDURES, Validate 1 or more of the following:         |
|      1. Account number length                                         |
|      2. Account number datatype (numeric, alphanumeric, or alphabet   |
|      3. Account number Algorithm                                      |
|                                                                       |
|  RETURN                                                               |
|      Xo_VALUE_OUT - Account Number is return with leading 0           |
|                     (Not for all countries)                           |
 --------------------------------------------------------------------- */

/* ---------------------------------------------------------------------
| Account Number Validation: AUSTRIA                                    |
| 9537127: Minimum length of 4 enforced. No Zero Padding                |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_ACCOUNT_AT (
        Xi_ACCOUNT_NUMBER   in varchar2,
        Xi_PASS_MAND_CHECK  in varchar2,
        Xo_VALUE_OUT        out nocopy varchar2
) AS
    account_value   VARCHAR2(30);
    numeric_result  VARCHAR2(30);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_at');

    Xo_VALUE_OUT := Xi_ACCOUNT_NUMBER ;
    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    account_value := UPPER(Xi_ACCOUNT_NUMBER);

    -- check for length constraints
    IF length(account_value) > 11
    THEN
        ce_failed_check('ACCOUNT_NUM','LENGTH_MAX','11');
    ELSIF length(account_value) < 4
    THEN
        ce_failed_check('ACCOUNT_NUM','LENGTH_MIN','4');
    END IF;

    -- check for alphanumeric characters
    IF NOT regexp_like(account_value,'^[0-9]*$')
    THEN
        ce_failed_check('ACCOUNT_NUM','NUMERIC');
    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_account_at');
END CE_VALIDATE_ACCOUNT_AT;

/* ---------------------------------------------------------------------
| Account Number Validation: PORTUGAL                                   |
| 9537127: No Zero Padding. Account number should be 11N                |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_ACCOUNT_PT (
        Xi_ACCOUNT_NUMBER   in varchar2,
        Xi_PASS_MAND_CHECK  in varchar2,
        Xo_VALUE_OUT        out nocopy varchar2
) AS
    account_value   VARCHAR2(30);
BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_pt');

    Xo_VALUE_OUT := Xi_ACCOUNT_NUMBER;
    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    account_value := UPPER(Xi_ACCOUNT_NUMBER);

    -- check for length
    IF length(ACCOUNT_VALUE) <> 11
    THEN
        ce_failed_check('ACCOUNT_NUM','LENGTH','11');
    END IF;

    -- check for numeric digits
    IF NOT regexp_like(account_value,'^[0-9]*$')
    THEN
        ce_failed_check('ACCOUNT_NUM','NUMERIC');
    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_account_pt');
END CE_VALIDATE_ACCOUNT_PT;

/* ---------------------------------------------------------------------
| Account Number Validation: BELGIUM                                    |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_ACCOUNT_BE (
        Xi_ACCOUNT_NUMBER   in varchar2,
        Xi_PASS_MAND_CHECK  in varchar2
) AS

    account_value   VARCHAR2(30);
    entered_format  VARCHAR2(30);
    numeric_result  VARCHAR2(40);
    bank_code       VARCHAR2(3);
    middle          VARCHAR2(7);
    check_digit     VARCHAR2(2);
    conced          VARCHAR2(30);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_be');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces --
    account_value := upper(replace(Xi_ACCOUNT_NUMBER,' ',''));
    conced := replace(account_value,'-','');

    IF (length(CONCED) = 12)
    THEN    /* length is ok */
        numeric_result := ce_check_numeric(CONCED,1,length(CONCED));
        IF numeric_result = '0'
        THEN    /* its numeric, continue */
            /* Account number should be of the format 999-9999999-99 */
            entered_format := translate(account_value,'0123456789',
                                                      '9999999999');
            IF (entered_format = '999-9999999-99')
            THEN    /* account format is correct */

                BANK_CODE       := substr(ACCOUNT_VALUE,1,3);
                MIDDLE          := substr(ACCOUNT_VALUE,5,7);
                CHECK_DIGIT     := substr(ACCOUNT_VALUE,13,2);

                -- The check digits are calculated by dividing the first 10
                -- digits by 97. If the remainder is 00, THEN the check
                -- digits are 97. Otherwise the check digits are the
                -- remainders.
                IF check_digit = 00
                THEN
                    -- 2261587 fbreslin: 00 is never a valid check digit,
                    -- even if  the MOD of the account number is 0
                    ce_failed_check('ACCOUNT_NUM','CD_FAILED');
                ELSIF  MOD(BANK_CODE||MIDDLE,97) = MOD(CHECK_DIGIT,97)
                THEN /* check digit checks out - validations successful */
                    ce_passed_check('ACCOUNT','BE');
                ELSE
                    ce_failed_check('ACCOUNT_NUM','CD_FAILED');
                END IF; /* end of CD validation */

            ELSE
                ce_failed_check('ACCOUNT_NUM','INVALID_FORMAT');
            END IF; /* end of format check */

        ELSE
            ce_failed_check('ACCOUNT_NUM','NUMERIC');
        END IF;  /* end of numeric check */

    ELSE
        ce_failed_check('ACCOUNT_NUM','LENGTH','12');
    END IF;  /* end of length check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_account_be');
END CE_VALIDATE_ACCOUNT_BE;


/* ---------------------------------------------------------------------
| Account Number Validation: DENMARK                                    |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_ACCOUNT_DK (
        Xi_ACCOUNT_NUMBER   in varchar2,
        Xi_PASS_MAND_CHECK  in varchar2,
        Xo_VALUE_OUT        out nocopy varchar2
) AS
    account_value       varchar2(30);
    numeric_result      varchar2(30);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_dk');

    Xo_VALUE_OUT := Xi_ACCOUNT_NUMBER;
    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    account_value := upper(Xi_ACCOUNT_NUMBER );
    account_value := replace(replace(account_value,' ',''),'-','');

    IF length(account_value) <= 10
    THEN    /* length is ok */
        numeric_result := ce_check_numeric(ACCOUNT_VALUE,1,length(ACCOUNT_VALUE));
        IF numeric_result = '0'
        THEN    /* it's numeric so validations successful */
            ce_passed_check('ACCOUNT','DK');
        ELSE
            ce_failed_check('ACCOUNT_NUM','NUMERIC');
        END IF; /* end of numeric check */
    ELSE
        ce_failed_check('ACCOUNT_NUM','LENGTH_MAX','10');
    END IF;  /* end of length check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_account_dk');
END CE_VALIDATE_ACCOUNT_DK;

/* ---------------------------------------------------------------------
| Account Number Validation: FRANCE                                     |
| 9537127: No Zero Padding. Account number should be 11AN                |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_ACCOUNT_FR (
        Xi_ACCOUNT_NUMBER   in varchar2,
        Xi_PASS_MAND_CHECK  in varchar2,
        Xo_VALUE_OUT        out nocopy varchar2
) AS

    ACCOUNT_VALUE varchar2(30);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_fr');

    Xo_VALUE_OUT  := Xi_ACCOUNT_NUMBER;
    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    account_value := UPPER(Xi_ACCOUNT_NUMBER);

    -- check for length
    IF length(ACCOUNT_VALUE) <> 11
    THEN
        ce_failed_check('ACCOUNT_NUM','LENGTH','11');
    END IF;  /* end of length check */

    -- check for alpha-numeric characters
    IF NOT regexp_like(account_value,'^[a-zA-Z0-9]*$')
    THEN
        ce_failed_check('ACCOUNT_NUM','ALPHANUM');
    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_account_fr');
END CE_VALIDATE_ACCOUNT_FR;


/* ---------------------------------------------------------------------
| Account Number Validation: NETHERLANDS                                |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_ACCOUNT_NL(
        Xi_ACCOUNT_NUMBER  in varchar2,
        Xi_PASS_MAND_CHECK in varchar2
) AS

    account_value       VARCHAR2(30);
    numeric_result      VARCHAR2(40);
    position_i          NUMBER(2);
    integer_value       NUMBER(1);
    multiplied_number   NUMBER(2);
    multiplied_sum      NUMBER(3);
    loop_sum            NUMBER(3);
                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/
    procedure check_11(
            input_value     IN  VARCHAR2,
            mult_sum_result OUT NOCOPY NUMBER
    )
    IS
    BEGIN
          FOR position_i in 1..10  LOOP
              integer_value := substr(input_value,position_i,1);
              multiplied_number := integer_value * (11-position_i);
              loop_sum := loop_sum + multiplied_number;
          END LOOP;
          mult_sum_result := loop_sum;
    END check_11;
                           /**************************/
                           /*      MAIN SECTION      */
                           /**************************/
BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_nl');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    multiplied_number := 0;
    multiplied_sum := 0;
    loop_sum := 0;

	ACCOUNT_VALUE := upper(Xi_ACCOUNT_NUMBER );
	ACCOUNT_VALUE := replace(replace(account_value,' ',''),'-','');

    --
    -- Bug 8478951: Change of validation for NL Post/Giro Accounts
    -- A. If the bank account number is numeric and consists of
    --    - 7 digits or less, or
    --    - prefixed with 000, or
    --    - prefixed with P/G
    --    then bank account will be considered as Post/Giro Account
    -- B. If the bank account number is of 9/10 digits then the existing
    --    validations will be applied.
    --
    IF (substr(ACCOUNT_VALUE,1,1) = 'P' OR substr(ACCOUNT_VALUE,1,1) = 'G')
     OR substr(ACCOUNT_VALUE,1,3) = '000'
     OR length(ACCOUNT_VALUE) <= 7

    THEN -- 'Giro' and 'Postbank' accounts

        cep_standard.debug('Validating account as Post/Giro...');
        -- Remove preceeding format strings
        IF (substr(ACCOUNT_VALUE,1,1) = 'P' OR substr(ACCOUNT_VALUE,1,1) = 'G')
        THEN
            ACCOUNT_VALUE := substr(ACCOUNT_VALUE,2,length(ACCOUNT_VALUE));
        ELSIF substr(ACCOUNT_VALUE,1,3) = '000'
        THEN
            ACCOUNT_VALUE := substr(ACCOUNT_VALUE,4,length(ACCOUNT_VALUE));
        END IF;

        -- Check for length of the account number
        IF length(ACCOUNT_VALUE) <= 7
        THEN
            numeric_result := ce_check_numeric(ACCOUNT_VALUE,1,length(ACCOUNT_VALUE));
            IF numeric_result = '0'
            THEN /* all validations successful */
                ce_passed_check('ACCOUNT','NL');
            ELSE  /* failed numeric check */
                ce_failed_check('ACCOUNT_NUM','POST_GIRO');
            END IF;
        ELSE  /* failed length check  */
            ce_failed_check('ACCOUNT_NUM','POST_GIRO');
        END IF;

    ELSE /* not a PostGiro account */
        cep_standard.debug('Validating account as regular...');
        -- check length
        IF length(ACCOUNT_VALUE) < 9
        THEN
            ce_failed_check('ACCOUNT_NUM','LENGTH_MIN','9');
        ELSIF length(ACCOUNT_VALUE) > 10
        THEN
            ce_failed_check('ACCOUNT_NUM','LENGTH_MAX','9');
        ELSE /* length is ok */

            numeric_result := ce_check_numeric(ACCOUNT_VALUE,1,length(ACCOUNT_VALUE));
            IF numeric_result = '0' AND instr(ACCOUNT_VALUE,' ') = 0
            THEN    /* it's numeric so continue */

                ACCOUNT_VALUE := lpad(ACCOUNT_VALUE,10,0);
                check_11(ACCOUNT_VALUE,multiplied_sum);
                IF mod(multiplied_sum,11) = 0
                THEN
                    ce_passed_check('ACCOUNT','NL');
                ELSE
                    ce_failed_check('ACCOUNT_NUM','CD_FAILED');
                END IF; /* end of CD validation */

            ELSE
                ce_failed_check('ACCOUNT_NUM','NUMERIC');
            END IF; /* end of numeric check */

        END IF; /* end of length check */

    END IF; /* end of 'Postgiro' check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_account_nl');
END CE_VALIDATE_ACCOUNT_NL;

/* ---------------------------------------------------------------------
| Account Number Validation: SPAIN                                      |
| Bug 9539000: Account number should be 10N. No automatic zero padding  |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_ACCOUNT_ES(
        Xi_ACCOUNT_NUMBER   in varchar2,
        Xi_PASS_MAND_CHECK  in varchar2,
        Xo_VALUE_OUT        out nocopy varchar2
) AS

    account_value   VARCHAR2(30);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_es');

    ACCOUNT_VALUE := upper(Xi_ACCOUNT_NUMBER);
    Xo_VALUE_OUT := ACCOUNT_VALUE;
    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- check for length
    IF length(ACCOUNT_VALUE) <> 10 -- Bug 9058549: length must be 10 digits
    THEN
        ce_failed_check('ACCOUNT_NUM','LENGTH','10');
    END IF;

    -- check for numeric digits
    IF NOT regexp_like(account_value,'^[0-9]*$')
    THEN
        ce_failed_check('ACCOUNT_NUM','NUMERIC');
    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_account_es');
END CE_VALIDATE_ACCOUNT_ES;

/* ---------------------------------------------------------------------+
| Account Number Validation: NORWAY                                     |
+----------------------------------------------------------------------*/
procedure CE_VALIDATE_ACCOUNT_NO (
        Xi_ACCOUNT_NUMBER  in varchar2,
        Xi_PASS_MAND_CHECK in varchar2
) AS

    account_value   VARCHAR2(30);
    numeric_result  VARCHAR2(40);
    computed_sum    NUMBER;
    calc_cd         NUMBER;
    check_digit     VARCHAR2(20);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_no');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    ACCOUNT_VALUE := upper(Xi_ACCOUNT_NUMBER );
	ACCOUNT_VALUE := replace(replace(account_value,' ',''),'-','');

    IF  length(ACCOUNT_VALUE) = 11
    THEN    /* length is ok */
        check_digit := substr(ACCOUNT_VALUE,11,1);

        numeric_result := ce_check_numeric(ACCOUNT_VALUE,1,length(ACCOUNT_VALUE));
        IF numeric_result = '0'
        THEN    /* its numeric so continue */
			/* perform check digit validation only if 5,6 digits are not 0 */
            IF (substr(ACCOUNT_VALUE,5,2) <> '00')
            THEN
                computed_sum := 5 * substr(ACCOUNT_VALUE,1,1) +
                                4 * substr(ACCOUNT_VALUE,2,1) +
                                3 * substr(ACCOUNT_VALUE,3,1) +
                                2 * substr(ACCOUNT_VALUE,4,1) +
                                7 * substr(ACCOUNT_VALUE,5,1) +
                                6 * substr(ACCOUNT_VALUE,6,1) +
                                5 * substr(ACCOUNT_VALUE,7,1) +
                                4 * substr(ACCOUNT_VALUE,8,1) +
                                3 * substr(ACCOUNT_VALUE,9,1) +
                                2 * substr(ACCOUNT_VALUE,10,1);

                calc_cd := 11 - mod(computed_sum,11);

                /* if remainder is 0 THEN check digit is 0 */
                IF calc_cd = 11 THEN
                    calc_cd := 0;
                ELSIF calc_cd = 10 THEN
                    /* check digit 10 cannot be used */
                    ce_failed_check('ACCOUNT_NUM','CD_FAILED');
                END IF;

                IF to_char(calc_cd) <> check_digit
                THEN    /* check digit is not ok */
                    ce_failed_check('ACCOUNT_NUM','CD_FAILED');
                ELSE
                    ce_passed_check('ACCOUNT','NO');
                END IF;
			END IF; /* end of check digit validation */

        ELSE
            ce_failed_check('ACCOUNT_NUM','NUMERIC');
        END IF; /* end of numeric check */

    ELSE
        ce_failed_check('ACCOUNT_NUM','LENGTH','11');
    END IF; /* end of length check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_account_no');
END CE_VALIDATE_ACCOUNT_NO;

/* ---------------------------------------------------------------------
| Account Number Validation: FINLAND                                    |
 ----------------------------------------------------------------------*/
PROCEDURE CE_VALIDATE_ACCOUNT_FI (
        Xi_ACCOUNT_NUMBER  in varchar2,
        Xi_PASS_MAND_CHECK in varchar2
) AS

    account_value     VARCHAR2(30);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_fi');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove formatting characters
    account_value := ce_remove_formats(Xi_Account_Number);
    cep_standard.debug('account_value='||account_value);

    -- 9249372: Validations reworked.
    IF (length(account_value) <= 8)
    THEN /* length is ok */
        IF ce_check_numeric(account_value,1,length(account_value)) = '0'
        THEN /* numeric is ok */
            ce_passed_check('ACCOUNT','FI');
        ELSE
            ce_failed_check('ACCOUNT_NUM','NUMERIC');
        END IF; /* end numeric check */
    ELSE
        ce_failed_check('ACCOUNT_NUM','LENGTH_MAX','8');
    END IF; /* End length check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_account_fi');
END CE_VALIDATE_ACCOUNT_FI;

/* ---------------------------------------------------------------------
| Account Number Validation: GERMANY                                    |
| Bug 9539000: Account Number should be 1-10N. No auto zero-padding     |
 ----------------------------------------------------------------------*/
 procedure CE_VALIDATE_ACCOUNT_DE(
        Xi_ACCOUNT_NUMBER   in varchar2,
        Xo_VALUE_OUT        out nocopy varchar2
) AS

    account_value   VARCHAR2(60);
    numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_DE');

    account_value := upper(Xi_ACCOUNT_NUMBER );
    Xo_VALUE_OUT := account_value;

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- length check
    IF length(account_value) > 10
    THEN
        ce_failed_check('ACCOUNT_NUM','LENGTH_MAX','10');
    END IF;

    -- numeric check
    IF NOT regexp_like(account_value,'^[0-9]*$')
    THEN
        ce_failed_check('ACCOUNT_NUM','NUMERIC');
    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_DE');
END CE_VALIDATE_ACCOUNT_DE;

/* ---------------------------------------------------------------------
| Account Number Validation: GREECE                                     |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_ACCOUNT_GR(
        Xi_ACCOUNT_NUMBER   in varchar2,
        Xo_VALUE_OUT        out nocopy varchar2
) AS

    account_value   VARCHAR2(30);
    numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_GR');

    Xo_VALUE_OUT := Xi_ACCOUNT_NUMBER;
    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    account_value := upper(replace(Xi_ACCOUNT_NUMBER,' ',''));
    account_value := replace(account_value,'-','');

    IF length(account_value) < 8
    THEN
        ce_failed_check('ACCOUNT_NUM','LENGTH_MIN','8');
    ELSIF length(account_value) > 16 -- 8207572
    THEN
        ce_failed_check('ACCOUNT_NUM','LENGTH_MAX','16'); -- Bug 8207572
    ELSE    /* length is ok */
        -- 8207572: removed numeric check and changed padding length
        Xo_VALUE_OUT := lpad(account_value,16,0);
        ce_passed_check('ACCOUNT','GR');
    END IF;  /* end of length check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_GR');
END CE_VALIDATE_ACCOUNT_GR;

/* ---------------------------------------------------------------------
| Account Number Validation: ICELAND                                    |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_ACCOUNT_IS(
        Xi_ACCOUNT_NUMBER  in varchar2,
        Xo_VALUE_OUT       out  nocopy varchar2
)   AS

    ac_value       VARCHAR2(50);
    cal_cd         NUMBER;
    cal_cd1        NUMBER;
    cd_value       VARCHAR2(50);
    ac_cd_value    VARCHAR2(50);
    numeric_result VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_is');

    Xo_VALUE_OUT := Xi_ACCOUNT_NUMBER;
    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    ac_value := upper(Xi_ACCOUNT_NUMBER );
    ac_value := replace(ac_value,' ','');
    ac_value := replace(ac_value,'-','');

    IF length(ac_value) <= 18
    THEN    /* length is ok */
        numeric_result := ce_check_numeric(AC_VALUE,1,length(AC_VALUE));
        IF numeric_result = '0'
        THEN    /* its numeric so continue */
            ac_value     := lpad(ac_value,18,0);
            Xo_VALUE_OUT := ac_value;

            cal_cd1 := mod(( (to_number(substr(ac_value,9,1))  * 3)
                            +(to_number(substr(ac_value,10,1)) * 2)
                            +(to_number(substr(ac_value,11,1)) * 7)
                            +(to_number(substr(ac_value,12,1)) * 6)
                            +(to_number(substr(ac_value,13,1)) * 5)
                            +(to_number(substr(ac_value,14,1)) * 4)
                            +(to_number(substr(ac_value,15,1)) * 3)
                            +(to_number(substr(ac_value,16,1)) * 2)),11);

            IF cal_cd1 = 0 THEN
                cal_cd := 0;
            ELSE
                cal_cd := (11 - cal_cd1);
            END IF;

            -- the check digit is the penultimate digit of (a3).
            ac_cd_value := substr(ac_value,17,1);

            IF ac_cd_value = cal_cd
            THEN    /* check digit checks out */
                ce_passed_check('ACCOUNT','IS');
            ELSE
                ce_failed_check('ACCOUNT_NUM','CD_FAILED');
            END IF; /* end of CD validation */

        ELSE
            ce_failed_check('ACCOUNT_NUM','NUMERIC');
        END IF; /* end of numeric check */

    ELSE
        ce_failed_check('ACCOUNT_NUM','LENGTH_MAX','18');
    END IF;  /* end of length check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_account_is');
END CE_VALIDATE_ACCOUNT_IS;

/* ---------------------------------------------------------------------
| Account Number Validation: IRELAND                                    |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_ACCOUNT_IE(
        Xi_ACCOUNT_NUMBER  in varchar2
)   AS

        account_value   VARCHAR2(30);
        numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_ie');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    account_value := upper(Xi_ACCOUNT_NUMBER );
    account_value := replace(account_value,' ','');
    account_value := replace(account_value,'-','');

    IF length(account_value) = 8
    THEN    /* length is ok */
        numeric_result := ce_check_numeric(ACCOUNT_VALUE,1,length(ACCOUNT_VALUE));
        IF numeric_result = '0'
        THEN    /* it's numeric so validations successful */
            ce_passed_check('ACCOUNT','IE');
        ELSE
            ce_failed_check('ACCOUNT_NUM','NUMERIC');
        END IF; /* end of numeric check */
    ELSE
       ce_failed_check('ACCOUNT_NUM','LENGTH','8');
    END IF;  /* end of length check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_account_ie');
END CE_VALIDATE_ACCOUNT_IE;

/* ---------------------------------------------------------------------
| Account Number Validation: ITALY                                      |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_ACCOUNT_IT(
        Xi_ACCOUNT_NUMBER  in varchar2,
        Xo_VALUE_OUT OUT NOCOPY varchar2
) AS

    account_value VARCHAR2(50);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_it');

    Xo_VALUE_OUT := Xi_ACCOUNT_NUMBER;
    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove hyphens and spaces --
    account_value := upper(replace(Xi_ACCOUNT_NUMBER,' ',''));
    account_value := replace(account_value,'-','');

    IF length(account_value) <= 12
    THEN    /* length is ok */
        Xo_VALUE_OUT := lpad(account_value,12,0);
        ce_passed_check('ACCOUNT','IT');
    ELSE
        ce_failed_check('ACCOUNT_NUM','LENGTH_MAX','12');
    END IF;  /* end of length check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_account_it');
END CE_VALIDATE_ACCOUNT_IT;

/* ---------------------------------------------------------------------
| Account Number Validation: LUXEMBOURG                                 |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_ACCOUNT_LU(
    Xi_ACCOUNT_NUMBER  in varchar2
) AS
    account_value   varchar2(30);
    numeric_result  varchar2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_lu');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    account_value := upper(Xi_ACCOUNT_NUMBER );
    account_value := replace(account_value,' ','');
    account_value := replace(account_value,'-','');

    -- 6005620: Standardized IBAN structure. Account number: 13an
    IF length(account_value) = 13
    THEN    /* length is ok */
        ce_passed_check('ACCOUNT','LU');
    ELSE
       -- Bug 7570051 : Correct length token
       ce_failed_check('ACCOUNT_NUM','LENGTH','13');
    END IF;  /* end of length check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_account_lu');
END CE_VALIDATE_ACCOUNT_LU;

/* ---------------------------------------------------------------------
| Account Number Validation: POLAND                                     |
| 9537127: Account Number should be 16N                                 |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_ACCOUNT_PL(
        Xi_ACCOUNT_NUMBER  in varchar2
) AS
    account_value   VARCHAR2(30);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_pl');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    account_value := UPPER(Xi_ACCOUNT_NUMBER);

    -- check for length
    IF length(account_value) <> 16
    THEN
        ce_failed_check('ACCOUNT_NUM','LENGTH','16');
    END IF;

    -- check for numeric digits
    IF NOT regexp_like(account_value,'^[0-9]*$')
    THEN
        ce_failed_check('ACCOUNT_NUM','NUMERIC');
    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_account_pl');
END CE_VALIDATE_ACCOUNT_PL;

/* ---------------------------------------------------------------------
| Account Number Validation: SWEDEN                                     |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_ACCOUNT_SE(
        Xi_ACCOUNT_NUMBER  in varchar2
) AS
    account_value   VARCHAR2(30);
    numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_se');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    account_value := upper(replace(Xi_ACCOUNT_NUMBER ,' ',''));
    account_value := replace(account_value,'-','');

    IF length(account_value) <= 16 -- 8246542: validation changed to 16 from 11
    THEN    /* length is ok */
        numeric_result := ce_check_numeric(ACCOUNT_VALUE,1,length(ACCOUNT_VALUE));
        IF numeric_result = '0'
        THEN
            ce_passed_check('ACCOUNT','SE');
        ELSE
            ce_failed_check('ACCOUNT_NUM','NUMERIC');
        END IF;
    ELSE
        ce_failed_check('ACCOUNT_NUM','LENGTH_MAX','16'); -- 8246542
    END IF;  /* end of length check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_account_se');
END CE_VALIDATE_ACCOUNT_SE;

/* ---------------------------------------------------------------------
| Account Number Validation: SWITZERLAND                                |
| 9537127: Account number should be  1/16AN                             |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_ACCOUNT_CH(
        Xi_ACCOUNT_NUMBER   in varchar2,
        Xi_ACCOUNT_TYPE     in varchar2
) AS

    account_value   VARCHAR2(30);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_ch');

    --8707415  Removed mandatory check for the account type, removed the code
    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled');
        RETURN;
    END IF;

    account_value := UPPER(Xi_ACCOUNT_NUMBER);

    -- check for max length
    IF length(account_value) > 16  THEN
        ce_failed_check('ACCOUNT_NUM','LENGTH_MAX','16');
    END IF;  /* end of length check */

    -- check for alphanumeric values
    IF NOT regexp_like(account_value,'^[a-zA-Z0-9]*$') THEN
        ce_failed_check('ACCOUNT_NUM','ALPHANUM');
    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_account_ch');
END CE_VALIDATE_ACCOUNT_CH;

/* ---------------------------------------------------------------------
| Account Number Validation: UNITED KINGDOM                             |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_ACCOUNT_GB(
        Xi_ACCOUNT_NUMBER   in varchar2,
        Xo_VALUE_OUT        out nocopy varchar2
) AS

    account_value   VARCHAR2(30);
    numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_gb');

    Xo_VALUE_OUT := Xi_ACCOUNT_NUMBER;
    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    account_value := upper(replace(Xi_ACCOUNT_NUMBER,' ',''));
    account_value := replace(account_value,'-','');
    IF length(account_value) <= 8
    THEN    /* length is ok */
        numeric_result := ce_check_numeric(ACCOUNT_VALUE,1,length(ACCOUNT_VALUE));
        IF numeric_result = '0'
        THEN    /* it's numeric */
            --7022651: Remove zero padding for UK Account Numbers.
            --Xo_VALUE_OUT := lpad(account_value,8,0);
            ce_passed_check('ACCOUNT','GB');
        ELSE
            ce_failed_check('ACCOUNT_NUM','NUMERIC');
        END IF; /* end of numeric check */
    ELSE
        ce_failed_check('ACCOUNT_NUM','LENGTH_MAX','8');
    END IF;  /* end of length check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_account_gb');
END CE_VALIDATE_ACCOUNT_GB;

/* ---------------------------------------------------------------------
| Account Number Validation: BRAZIL                                     |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_ACCOUNT_BR(
        Xi_ACCOUNT_NUMBER               in varchar2,
        Xi_SECONDARY_ACCOUNT_REFERENCE  in varchar2
)   AS

    account_ref     VARCHAR2(30);
    numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_br');

    -- 7582842: No validations on account number. Disable profile will not
    -- apply here

    -- remove spaces and hyphens from company code --
    account_ref := upper(replace(Xi_SECONDARY_ACCOUNT_REFERENCE,' ',''));
	account_ref := replace(account_ref,'-','');

    IF (account_ref) IS NOT NULL
    THEN    /* only validate if a value has been entered */
        IF length(account_ref) <= 15
        THEN    /* length is ok */
            numeric_result := ce_check_numeric(ACCOUNT_REF,1,length(ACCOUNT_REF));
            IF numeric_result = '0'
            THEN    /* its numeric so validations successful */
                ce_passed_check('ACCOUNT','BR');
            ELSE
                ce_failed_check('COMPANY_CODE','NUMERIC');
            END IF; /* end of numeric check */
        ELSE
            ce_failed_check('COMPANY_CODE','LENGTH_MAX','15');
        END IF;  /* end of length check */
    END IF;  /* end of not null check */

    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_br');
END CE_VALIDATE_ACCOUNT_BR;

/* ---------------------------------------------------------------------
| Account Number Validation: AUSTRALIA                                  |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_ACCOUNT_AU(
        Xi_ACCOUNT_NUMBER  in varchar2,
        Xi_CURRENCY_CODE   in varchar2
) AS

    account_value   VARCHAR2(30);
    numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_au');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens
    account_value := upper(Xi_ACCOUNT_NUMBER );
    account_value := replace(account_value,' ','');
    account_value := replace(account_value,'-','');

    --   Bug 6079454 changed minimum length to 6
    --   Bug 8228625 changed minimum length to 5
    IF length(account_value) > 10
    THEN
        ce_failed_check('ACCOUNT_NUM','LENGTH_MAX','10');
    ELSIF length(account_value) < 5
    THEN
        ce_failed_check('ACCOUNT_NUM','LENGTH_MIN','5');
    ELSE    /* length is ok */
        -- 6760446: Numeric check only for AUD denominated accounts.
        IF Xi_CURRENCY_CODE = 'AUD'
        THEN
            numeric_result := ce_check_numeric(ACCOUNT_VALUE,1,length(ACCOUNT_VALUE));
            IF numeric_result = '0'
            THEN    /* its is numeric - validation succesful */
                ce_passed_check('ACCOUNT','AU');
            ELSE
                ce_failed_check('ACCOUNT_NUM','NUMERIC');
            END IF; /* end of numeric check */
        ELSE
            ce_passed_check('ACCOUNT','AU');
        END IF; /* end of currency check */
    END IF;  /* end of length check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_account_au');
END CE_VALIDATE_ACCOUNT_AU;

/* ---------------------------------------------------------------------
| Account Number Validation: ISRAEL                                     |
 ----------------------------------------------------------------------*/
 procedure CE_VALIDATE_ACCOUNT_IL(
        Xi_ACCOUNT_NUMBER  in varchar2
) AS

    account_value  VARCHAR2(30);
    numeric_result VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_il');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    account_value := upper(Xi_ACCOUNT_NUMBER );
    account_value := replace(account_value,' ','');
    account_value := replace(account_value,'-','');
    -- Bug 9645400
    IF length(account_value) <= 9
    THEN    /* length is ok */
        numeric_result := ce_check_numeric(ACCOUNT_VALUE,1,length(ACCOUNT_VALUE));
        IF numeric_result = '0'
        THEN    /* its numeric validations successful */
            ce_passed_check('ACCOUNT','IL');
        ELSE
            ce_failed_check('ACCOUNT_NUM','NUMERIC');
        END IF; /* end of numeric check */
    ELSE
        ce_failed_check('ACCOUNT_NUM','LENGTH','9');
    END IF;  /* end of length check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_account_il');
END CE_VALIDATE_ACCOUNT_IL;

/* ---------------------------------------------------------------------
| Account Number Validation: NEW ZEALAND                                |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_ACCOUNT_NZ(
        Xi_ACCOUNT_NUMBER  in varchar2,
        Xi_ACCOUNT_SUFFIX in varchar2
) AS

    account_value   VARCHAR2(30);
    account_suffix  VARCHAR2(30);
    numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_nz');

--  bug 8416679, relaxed account validations for New Zealand
--    -- check account number
--    account_value := upper(Xi_ACCOUNT_NUMBER );
--    account_value := replace(account_value,' ','');
--    account_value := replace(account_value,'-','');
--
--
--    IF length(account_value) > 8
--    THEN
--        ce_failed_check('ACCOUNT_NUM','LENGTH_MAX','8');
--    ELSIF length(account_value) < 6
--    THEN
--        ce_failed_check('ACCOUNT_NUM','LENGTH_MIN','6');
--    ELSE
--        numeric_result := ce_check_numeric(ACCOUNT_VALUE,1,length(ACCOUNT_VALUE));
--        IF numeric_result = '0'
--        THEN    /* it's numeric so validations successful */
--            ce_passed_check('ACCOUNT','NZ');
--        ELSE
--            ce_failed_check('ACCOUNT_NUM','NUMERIC');
--        END IF; /* end of numeric check */
--    END IF;  /* end of length check */
--
--    -- check account_suffix
--    account_suffix := upper(Xi_ACCOUNT_SUFFIX );
--    account_suffix := replace(account_suffix,' ','');
--    account_suffix := replace(account_suffix,'-','');
--
--    IF account_suffix IS NOT NULL
--    THEN
--        IF length(account_suffix) = 3
--        THEN    /* length is ok */
--            numeric_result := ce_check_numeric(ACCOUNT_SUFFIX,1,length(ACCOUNT_SUFFIX));
--            IF numeric_result = '0'
--            THEN    /* it's numeric all validations successful */
--                ce_passed_check('ACCOUNT','NZ');
--            ELSE
--                ce_failed_check('ACCOUNT_SUFFIX','NUMERIC');
--            END IF; /* end of numeric check */
--        ELSE
--            ce_failed_check('ACCOUNT_SUFFIX','LENGTH','3');
--        END IF;  /* end of length check */
--    ELSE
--        ce_failed_mandatory('ACCOUNT_SUFFIX');
--    END IF; /* end of mandatory check */
--
    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_account_nz');
END CE_VALIDATE_ACCOUNT_NZ;

/* ---------------------------------------------------------------------
| Account Number Validation: JAPAN                                      |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_ACCOUNT_JP(
        Xi_ACCOUNT_NUMBER  in varchar2,
        Xi_ACCOUNT_TYPE  in varchar2
) AS

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_jp');

    -- 7582842: No Checks on Account number. Disable profile option does not
    -- apply here.

    /* Account number is required */
    IF (Xi_ACCOUNT_NUMBER is null)  THEN
      ce_failed_mandatory('ACCOUNT_NUMBER');
    END if;
    /* Account type is required */
    IF (Xi_ACCOUNT_TYPE  is null)  THEN
      ce_failed_mandatory('ACCOUNT_TYPE');
    END if;


    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_account_jp');
END CE_VALIDATE_ACCOUNT_JP;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_BANK_*                                               |
|                                                                       |
|  CALLED BY                                                            |
|      CE_VALIDATE_BANK                                                 |
|                                                                       |
|  DESCRIPTION                                                          |
|      BANK PROCEDURES, Validate 1 or more of the following:            |
|      1. Bank number length                                            |
|      2. Bank number datatype (numeric, alphanumeric, or alphabet      |
|      3. Bank number Algorithm                                         |
|                                                                       |
|  RETURN                                                               |
|      Xo_VALUE_OUT - Bank Number is return with leading 0              |
|                     (Not for all countries)                           |
 --------------------------------------------------------------------- */

/* ---------------------------------------------------------------------
| Bank Number Validation: SPAIN                                         |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BANK_ES (
        Xi_BANK_NUMBER      in varchar2,
        Xi_PASS_MAND_CHECK  in varchar2,
        Xo_VALUE_OUT        OUT NOCOPY varchar2
) AS

    bank_value VARCHAR2(30);
    numeric_result VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bank_es');

    Xo_VALUE_OUT :=  Xi_BANK_NUMBER;
    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
	BANK_VALUE   :=  upper(Xi_BANK_NUMBER);
    BANK_VALUE   :=  replace(replace(BANK_VALUE,' ',''),'-','');

    IF Xi_PASS_MAND_CHECK = 'F'
    THEN
        ce_failed_mandatory('BANK_NUM');

    ELSIF Xi_PASS_MAND_CHECK = 'P'
    THEN
        IF length(BANK_VALUE) > 4
        THEN
            ce_failed_check('BANK_NUM','LENGTH_MAX','4');
        ELSE
            /* length is ok */
            BANK_VALUE := lpad(BANK_VALUE,4,0);
            numeric_result := ce_check_numeric(BANK_VALUE,1,length(BANK_VALUE));
            IF numeric_result = '0'
            THEN
                /* its numeric validations successful*/
                Xo_VALUE_OUT := BANK_VALUE;
                ce_passed_check('BANK','ES');
            ELSE
                ce_failed_check('BANK_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        END IF;  /* end of length check */
    END IF; /* end of mandatory check  */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_bank_es');
END CE_VALIDATE_BANK_ES;

/* ---------------------------------------------------------------------
| Bank Number Validation: FRANCE                                        |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BANK_FR(
        Xi_BANK_NUMBER  in varchar2,
        Xi_PASS_MAND_CHECK in varchar2,
        Xo_VALUE_OUT OUT NOCOPY varchar2
) AS
BANK_VALUE varchar2(30);
numeric_result varchar2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bank_fr');

    Xo_VALUE_OUT := Xi_BANK_NUMBER;
    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    BANK_VALUE   := upper(Xi_BANK_NUMBER );
    BANK_VALUE   := replace(replace(BANK_VALUE,' ',''),'-','');

    IF Xi_PASS_MAND_CHECK = 'F'
    THEN
        ce_failed_mandatory('BANK_NUM');

    ELSIF Xi_PASS_MAND_CHECK = 'P'
    THEN
        /* mandatory check passed */

        IF length(BANK_VALUE) > 5
        THEN
            ce_failed_check('BANK_NUM','LENGTH_MAX','5');
        ELSE
            /* length check passed */
            BANK_VALUE := lpad(BANK_VALUE,5,0);
            numeric_result := ce_check_numeric(BANK_VALUE,1,length(BANK_VALUE));

            IF numeric_result = '0'
            THEN
                /* numeric check passed - validations successful*/
                Xo_VALUE_OUT := BANK_VALUE;
                ce_passed_check('BANK','FR');
            ELSE
                ce_failed_check('BANK_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        END IF;  /* end of length check */
    END IF; /* end of mandatory check  */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_bank_fr');

END CE_VALIDATE_BANK_FR;

/* ---------------------------------------------------------------------
| Bank Number Validation: PORTUGAL                                      |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BANK_PT(
        Xi_BANK_NUMBER      in varchar2,
        Xi_PASS_MAND_CHECK  in varchar2
) AS

    bank_value      VARCHAR2(30);
    numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bank_pt');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces --
    BANK_VALUE := replace(replace(Xi_BANK_NUMBER,' ',''),'-','');

    IF Xi_PASS_MAND_CHECK = 'F'
    THEN
        ce_failed_mandatory('BANK_NUM');

    ELSIF Xi_PASS_MAND_CHECK = 'P'
    THEN
        IF length(BANK_VALUE) = 4
        THEN
            /* length is ok */
            numeric_result := ce_check_numeric(BANK_VALUE,1,length(BANK_VALUE));
            IF numeric_result = '0'
            THEN    /* its numeric - validations successful */
                ce_passed_check('BANK','PT');
            ELSE
                ce_failed_check('BANK_NUM','NUMERIC');
            END IF;  /* end of numeric check */

        ELSE
            ce_failed_check('BANK_NUM','LENGTH','4');
        END IF;  /* end of length check */

    END IF; /* end of mandatory check  */

    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bank_pt');
END CE_VALIDATE_BANK_PT;

/* ---------------------------------------------------------------------
| Bank Number Validation: BRAZIL                                        |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BANK_BR(
        Xi_BANK_NUMBER      in varchar2,
        Xi_PASS_MAND_CHECK  in varchar2,
        Xo_VALUE_OUT        OUT NOCOPY varchar2
) AS

    bank_value      VARCHAR2(30);
    numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bank_br');

    Xo_VALUE_OUT := Xi_BANK_NUMBER;
    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    BANK_VALUE := upper(Xi_BANK_NUMBER );
    BANK_VALUE := replace(replace(BANK_VALUE,' ',''),'-','');

    IF Xi_PASS_MAND_CHECK = 'F'
    THEN /* mandatory check failed */
        ce_failed_mandatory('BANK_NUM');

    ELSIF Xi_PASS_MAND_CHECK = 'P'
    THEN
        /* mandatory check passed */
        IF length(BANK_VALUE) > 3
        THEN
            ce_failed_check('BANK_NUM','LENGTH_MAX','3');

        ELSE
            /* length is ok */
            BANK_VALUE := lpad(BANK_VALUE,3,0);
            numeric_result := ce_check_numeric(BANK_VALUE,1,length(BANK_VALUE));
            IF numeric_result = '0' THEN
                /* numeric check passed validations successful */
                Xo_VALUE_OUT := BANK_VALUE;
                ce_passed_check('BANK','BR');
            ELSE
                ce_failed_check('BANK_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        END IF;  /* end of length check */
    END IF; /* end of mandatory check  */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_bank_br');
END CE_VALIDATE_BANK_BR;

/* ---------------------------------------------------------------------
| Bank Number Validation: GERMANY                                       |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BANK_DE(
        Xi_BANK_NUMBER  in varchar2
) AS
    BANK_NUM        varchar2(30);
    numeric_result  varchar2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bank_de');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    BANK_NUM := upper(replace(Xi_BANK_NUMBER,' ',''));
    BANK_NUM := replace(BANK_NUM,'-','');

    IF (BANK_NUM) IS NOT NULL
    THEN /* only validate if bank num is entered */
        IF length(BANK_NUM) = 8
        THEN /* length is ok */
            numeric_result := ce_check_numeric(BANK_NUM,1,length(BANK_NUM));

            IF numeric_result = '0'
            THEN /* its numeric validation successful */
                ce_passed_check('BANK','DE');
            ELSE
                ce_failed_check('BANK_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        ELSE
            ce_failed_check('BANK_NUM','LENGTH','8');
        END IF;  /* end of length check */
    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_bank_de');
END CE_VALIDATE_BANK_DE;

/* ---------------------------------------------------------------------
| Bank Number Validation: GREECE                                        |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BANK_GR(
        Xi_BANK_NUMBER  in varchar2
) AS

    BANK_VALUE      varchar2(30);
    numeric_result  varchar2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bank_gr');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens before validating --
    BANK_VALUE := upper(replace(Xi_BANK_NUMBER,' ',''));
    BANK_VALUE := replace(BANK_VALUE,'-','');

    IF (BANK_VALUE) IS NOT NULL
    THEN    /* only validate if value entered */
        IF length(BANK_VALUE) <= 3
        THEN    /* length is ok */
            numeric_result := ce_check_numeric(BANK_VALUE,1,length(BANK_VALUE));
            IF numeric_result = '0'
            THEN /* its numeric - validations successful  */
                ce_passed_check('BANK','GR');
            ELSE
                ce_failed_check('BANK_NUM','NUMERIC');
            END IF;  /* end of numeric check */

        ELSE
                ce_failed_check('BANK_NUM','LENGTH_MAX', '3');
        END IF;  /* end of length check */
    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_bank_gr');
END CE_VALIDATE_BANK_GR;

/* ---------------------------------------------------------------------
| Bank Number Validation: ICELAND                                       |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BANK_IS(
        Xi_BANK_NUMBER  in varchar2,
        Xo_VALUE_OUT    OUT NOCOPY varchar2
) AS

    BANK_NUM        varchar2(60);
    numeric_result  varchar2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bank_is');

    Xo_VALUE_OUT := Xi_BANK_NUMBER;
    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    BANK_NUM := upper(replace(Xi_BANK_NUMBER,' ',''));
    BANK_NUM := replace(BANK_NUM,'-','');

    IF (BANK_NUM) IS NOT NULL
    THEN
        IF length(BANK_NUM) <= 4
        THEN    /* length is ok */
            numeric_result := ce_check_numeric(BANK_NUM,1,length(BANK_NUM));
            IF numeric_result = '0'
            THEN /* its numeric - validations successful */
                Xo_VALUE_OUT := lpad(bank_num,4,0);
                ce_passed_check('BANK','IS');
            ELSE
                ce_failed_check('BANK_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        ELSE
            ce_failed_check('BANK_NUM','LENGTH_MAX','4');
        END IF;  /* end of length check */
    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_bank_is');
END CE_VALIDATE_BANK_IS;

/* ---------------------------------------------------------------------
| Bank Number Validation: IRELAND                                       |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BANK_IE(
        Xi_BANK_NUMBER  in varchar2
) AS

    bank_num        VARCHAR2(60);
    numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bank_ie');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens
    BANK_NUM := upper(replace(Xi_BANK_NUMBER,' ',''));
    BANK_NUM := replace(BANK_NUM,'-','');

    IF (BANK_NUM) IS NOT NULL
    THEN
        /* only validate if a value has been entered */
        -- Bug 6846899 : Valid length is 6 not 8
        IF length(BANK_NUM) = 6
        THEN    /* length is ok */
            numeric_result := ce_check_numeric(BANK_NUM,1,length(BANK_NUM));
            IF numeric_result = '0'
            THEN /* its numeric so validations sucessful  */
                ce_passed_check('BANK','IE');
            ELSE
                ce_failed_check('BANK_NUM','NUMERIC');
            END IF;  /* end of numeric check */

        ELSE
            ce_failed_check('BANK_NUM','LENGTH','6');
        END IF;  /* end of length check */

    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_bank_ie');
END CE_VALIDATE_BANK_IE;

/* ---------------------------------------------------------------------
| Bank Number Validation: ITALY                                         |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BANK_IT(
        Xi_BANK_NUMBER  in varchar2,
        Xi_PASS_MAND_CHECK in varchar2
) AS

    bank_value      VARCHAR2(30);
    numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bank_it');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    BANK_VALUE := upper(replace(Xi_BANK_NUMBER,' ',''));
    BANK_VALUE := replace(BANK_VALUE,'-','');

    IF Xi_PASS_MAND_CHECK = 'F'
    THEN
        ce_failed_mandatory('BANK_NUM');

    ELSIF Xi_PASS_MAND_CHECK = 'P'
    THEN
        IF length(BANK_VALUE) = 5
        THEN
            /* length is ok */
            numeric_result := ce_check_numeric(BANK_VALUE,1,length(BANK_VALUE));
            IF numeric_result = '0'
            THEN
                /* its numeric - validations successful  */
                ce_passed_check('BANK','IT');
            ELSE
                ce_failed_check('BANK_NUM','NUMERIC');
            END IF;  /* end of numeric check */

        ELSE
            ce_failed_check('BANK_NUM','LENGTH','5');
        END IF;  /* end of length check */

    END IF; /* end of mandatory check  */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_bank_it');
END CE_VALIDATE_BANK_IT;

/* ---------------------------------------------------------------------
| Bank Number Validation: LUXEMBOURG                                    |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BANK_LU(
        Xi_BANK_NUMBER  in varchar2
) AS

    bank_num        VARCHAR2(60);
    numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bank_lu');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    BANK_NUM := upper(replace(Xi_BANK_NUMBER,' ',''));
    BANK_NUM := replace(BANK_NUM,'-','');

    IF (BANK_NUM) IS NOT NULL
    THEN
        /* only validate if a value has been entered */
        -- 6005620: IBAN standardized structure. Bank Num: 3n
        IF length(BANK_NUM) = 3
        THEN
            /* length is ok */
            numeric_result := ce_check_numeric(BANK_NUM,1,length(BANK_NUM));
            IF numeric_result = '0'
            THEN /* its numeric - validations successful */
                ce_passed_check('BANK','LU');
            ELSE
                ce_failed_check('BANK_NUM','NUMERIC');
            END IF;  /* end of numeric check */

        ELSE
            ce_failed_check('BANK_NUM','LENGTH','3');
        END IF;  /* end of length check */

    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_bank_lu');
END CE_VALIDATE_BANK_LU;

/* ---------------------------------------------------------------------
| Bank Number Validation: POLAND                                        |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BANK_PL(
        Xi_BANK_NUMBER  in varchar2
) AS

    bank_num        VARCHAR2(60);
    numeric_result  VARCHAR2(40);
    cal_cd1         NUMBER;

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bank_pl');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    BANK_NUM := upper(replace(Xi_BANK_NUMBER,' ',''));
    BANK_NUM := replace(BANK_NUM,'-','');

    IF (BANK_NUM) IS NOT NULL
    THEN
        /* only validate if a value has been entered */
        IF length(BANK_NUM) = 8
        THEN
            /* length is ok */
            numeric_result := ce_check_numeric(BANK_NUM,1,length(BANK_NUM));
            IF numeric_result = '0'
            THEN
                -- Bug 7454786: No check digit validation for Poland
                ce_passed_check('BANK','PL');
            ELSE
                ce_failed_check('BANK_NUM','NUMERIC');
            END IF;  /* end of numeric check */

        ELSE
            ce_failed_check('BANK_NUM','LENGTH','8');
        END IF;  /* end of length check */

    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_bank_pl');
END CE_VALIDATE_BANK_PL;

/* ---------------------------------------------------------------------
| Bank Number Validation: SWEDEN                                        |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BANK_SE(
        Xi_BANK_NUMBER  in varchar2
) AS

    bank_num VARCHAR2(60);
    numeric_result VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bank_se');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    BANK_NUM := upper(replace(Xi_BANK_NUMBER,' ',''));
    BANK_NUM := replace(BANK_NUM,'-','');

    IF (BANK_NUM) IS NOT NULL
    THEN
        /* only validate if a value has been entered */
        IF length(BANK_NUM) > 5
        THEN
            ce_failed_check('BANK_NUM','LENGTH_MAX','5');
        ELSIF length(BANK_NUM) < 4
        THEN
            ce_failed_check('BANK_NUM','LENGTH_MIN','4');
        ELSE
            /* length is ok */
            numeric_result := ce_check_numeric(BANK_NUM,1,length(BANK_NUM));
            IF numeric_result = '0'
            THEN /* its numeric - validation successful */
                ce_passed_check('BANK','SE');
            ELSE
                ce_failed_check('BANK_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        END IF;  /* end of length check */
    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_bank_se');
END CE_VALIDATE_BANK_SE;

/* ---------------------------------------------------------------------
| Bank Number Validation: SWITZERLAND                                   |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BANK_CH(
        Xi_BANK_NUMBER  in varchar2
) AS

    bank_num VARCHAR2(60);
    numeric_result VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bank_ch');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    BANK_NUM := upper(replace(Xi_BANK_NUMBER,' ',''));
    BANK_NUM := replace(BANK_NUM,'-','');

    IF (BANK_NUM) IS NOT NULL
    THEN
        /* only validate if a value has been entered */
        IF length(BANK_NUM) > 5
        THEN
            ce_failed_check('BANK_NUM','LENGTH_MAX','5');
        ELSIF length(BANK_NUM) < 3
        THEN
            ce_failed_check('BANK_NUM','LENGTH_MIN','3');
        ELSE
            /* length is ok */
            numeric_result := ce_check_numeric(BANK_NUM,1,length(BANK_NUM));
            IF numeric_result = '0'
            THEN /* its numeric - validations successful */
                ce_passed_check('BANK','CH');
            ELSE
                ce_failed_check('BANK_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        END IF;  /* end of length check */
    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_bank_ch');
END CE_VALIDATE_BANK_CH;

/* ---------------------------------------------------------------------
| Bank Number Validation: UNITED KINGDOM                                |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BANK_GB(
        Xi_BANK_NUMBER  in varchar2
) AS

    bank_num VARCHAR2(60);
    numeric_result VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bank_gb');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    BANK_NUM := upper(replace(Xi_BANK_NUMBER,' ',''));
    BANK_NUM := replace(BANK_NUM,'-','');

    IF (BANK_NUM) IS NOT NULL
    THEN
        /* only validate if a value has been entered */
        IF length(BANK_NUM) = 6
        THEN
            /* length is ok */
            numeric_result := ce_check_numeric(BANK_NUM,1,length(BANK_NUM));
            IF numeric_result = '0'
            THEN /* its numeric - validations successful */
                ce_passed_check('BANK','GB');
            ELSE
                ce_failed_check('BANK_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        ELSE
            ce_failed_check('BANK_NUM','LENGTH','6');
        END IF;  /* end of length check */
    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_bank_gb');
END CE_VALIDATE_BANK_GB;

/* ---------------------------------------------------------------------
| Bank Number Validation: COLUMBIA                                      |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BANK_CO(
        Xi_COUNTRY_NAME     in varchar2,
        Xi_BANK_NAME        in varchar2,
        Xi_TAX_PAYER_ID     in varchar2
) AS

    tax_id          VARCHAR2(60);
    tax_id1         VARCHAR2(60);
    tax_id_end      NUMBER;
    tax_id_cd_start NUMBER;
    tax_id_cd       VARCHAR2(60);
    numeric_result  VARCHAR2(40);
    l_supp          VARCHAR(10);
    l_comp          VARCHAR(10);
    l_cust          VARCHAR(10);
    l_bank          VARCHAR(10);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_CO');

    -- 7582842: No validations on bank number. Disable profile will not apply
    -- here.

    -- the last digit of tax payer id is the check digits
    TAX_ID1 := upper(replace(Xi_TAX_PAYER_ID,' ',''));
    TAX_ID1 := replace(TAX_ID1,'-','');
    tax_id_end := (length(tax_id1) - 1);
    tax_id := substr(tax_id1,1, tax_id_end);
    tax_id_cd_start := (length(tax_id1));
    tax_id_cd := substr(tax_id1, tax_id_cd_start, length(tax_id1));

    IF (tax_id) IS NOT NULL
    THEN
        IF length(tax_id) <= 14
        THEN
            numeric_result := ce_check_numeric(tax_id,1,length(tax_id));
            IF numeric_result = '0'
            THEN
	    /* its numeric so continue.. Bug 8614674 replaced tax_id with tax_id1 as it is
	        stored with check digit */
                IF CE_VALIDATE_BANKINFO.CE_VAL_UNIQUE_TAX_PAYER_ID(
                    Xi_COUNTRY_NAME,TAX_ID1) = 'TRUE'
                THEN
                    CE_VALIDATE_BANKINFO.CE_CHECK_CROSS_MODULE_TAX_ID(
                        Xi_COUNTRY_NAME,
                        Xi_BANK_NAME,
                        TAX_ID,
                        l_cust,
                        l_supp,
                        l_comp,
                        l_bank
                    );

                    cep_standard.debug('l_cust : '|| l_cust );
                    cep_standard.debug('l_supp : '|| l_supp );
                    cep_standard.debug('l_comp : '|| l_comp );
                    cep_standard.debug('l_bank : '|| l_bank );

                    IF (l_supp  = 'bk3' OR l_cust= 'bk2' OR l_comp = 'bk1')
                    THEN
                        FND_MESSAGE.SET_NAME('CE','CE_TAXID_EXIST');
                        fnd_msg_pub.add;
                    END IF;
                    IF (l_supp = 'bk5')
                    THEN
                        FND_MESSAGE.SET_NAME('CE','CE_TAXID_BANK_EXIST_AS_SUPP');
                        fnd_msg_pub.add;
                    END IF;
                    IF (l_cust = 'bk4')
                    THEN
                        FND_MESSAGE.SET_NAME('CE','CE_TAXID_BANK_EXIST_AS_CUST');
                        fnd_msg_pub.add;
                    END IF;
                    IF (l_comp = 'bk6') THEN
                        FND_MESSAGE.SET_NAME('CE','CE_TAXID_BANK_EXIST_AS_COMP');
                        fnd_msg_pub.add;
                    END IF;
                    IF ce_tax_id_check_algorithm(TAX_ID,Xi_COUNTRY_NAME,TAX_ID_CD) = 'FALSE'
                    THEN
                        ce_failed_check('TAX_PAYER_ID','CD_FAILED');
                    END IF; /* end of check digit validation */
                ELSE
                    fnd_message.set_name ('CE', 'CE_TAX_PAYER_ID_NOT_UNIQUE');
                    fnd_msg_pub.add;
                END IF; /* end of unique check */
            ELSE
                ce_failed_check('TAX_PAYER_ID','NUMERIC');
            END IF;  /* end of numeric check */
        ELSE
            ce_failed_check('TAX_PAYER_ID','LENGTH_MAX','14');
        END IF;  /* end of length check */
    ELSE
        ce_failed_mandatory('TAX_PAYER_ID');
    END IF; /* end of mandatory check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_CO');
END CE_VALIDATE_BANK_CO;

/* ---------------------------------------------------------------------
| Bank Number Validation: AUSTRALIA                                     |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BANK_AU(
        Xi_BANK_NUMBER  in varchar2
) AS
    BANK_NUM        varchar2(60);
    numeric_result  varchar2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bank_au');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- Remove blanks and hyphens before validation --
    BANK_NUM := upper(replace(Xi_BANK_NUMBER,' ',''));
    BANK_NUM := replace(BANK_NUM,'-','');

    IF (BANK_NUM) IS NOT NULL
    THEN /* only validate if a value has been entered */
        IF length(BANK_NUM) < 2
        THEN /* length less than min */
            ce_failed_check('BANK_NUM','LENGTH_MIN','2');

        ELSIF length(BANK_NUM) > 3
        THEN /* length more than max */
            ce_failed_check('BANK_NUM','LENGTH_MAX','3');

        ELSE /* length is ok */
            numeric_result := ce_check_numeric(BANK_NUM,1,length(BANK_NUM));
            IF numeric_result = '0'
            THEN  /* its numeric, validations successfull */
                ce_passed_check('BANK','AU');
            ELSE
                ce_failed_check('BANK_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        END IF;  /* end of length check */
    ELSE
        ce_passed_check('BANK','AU');
    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_bank_au');
END CE_VALIDATE_BANK_AU;

/* ---------------------------------------------------------------------
| Bank Number Validation: ISRAEL                                        |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BANK_IL(
        Xi_BANK_NUMBER      in varchar2,
        Xi_PASS_MAND_CHECK  in varchar2
) AS

    bank_value      VARCHAR2(30);
    numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bank_il');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    BANK_VALUE := upper(replace(Xi_BANK_NUMBER,' ',''));
    BANK_VALUE := replace(BANK_VALUE,'-','');

    IF Xi_PASS_MAND_CHECK = 'F'
    THEN
        ce_failed_mandatory('BANK_NUM');

    ELSIF Xi_PASS_MAND_CHECK = 'P'
    THEN

        IF length(BANK_VALUE) > 2
        THEN
            ce_failed_check('BANK_NUM','LENGTH_MAX','2');
        ELSE
            /* length is ok */
            numeric_result := ce_check_numeric(BANK_VALUE,1,length(BANK_VALUE));
            IF numeric_result = '0'
            THEN
                /* it's numeric - validations successful  */
                ce_passed_check('BANK','IL');
            ELSE
                ce_failed_check('BANK_NUM','NUMERIC');
            END IF;  /* end of numeric check */

        END IF;  /* end of length check */

    END IF; /* end of mandatory check  */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_bank_il');
END CE_VALIDATE_BANK_IL;

/* ---------------------------------------------------------------------
| Bank Number Validation: NEW ZEALAND                                   |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BANK_NZ(
        Xi_BANK_NUMBER      in varchar2,
        Xi_PASS_MAND_CHECK  in varchar2
) AS

    bank_value VARCHAR2(30);
    numeric_result VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bank_nz');

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    BANK_VALUE := upper(replace(Xi_BANK_NUMBER,' ',''));
    BANK_VALUE := replace(BANK_VALUE,'-','');

    IF Xi_PASS_MAND_CHECK = 'F'
    THEN
        ce_failed_mandatory('BANK_NUM');

    ELSIF Xi_PASS_MAND_CHECK = 'P'
    THEN
        IF length(BANK_VALUE) = 2
        THEN
            /* length is ok */
            numeric_result := ce_check_numeric(BANK_VALUE,1,length(BANK_VALUE));
            IF numeric_result = '0'
            THEN
                /* its numeric - validations passed */
                ce_passed_check('BANK','NZ');
            ELSE
                ce_failed_check('BANK_NUM','NUMERIC');
            END IF;  /* end of numeric check */

        ELSE
            ce_failed_check('BANK_NUM','LENGTH','2');
        END IF;  /* end of length check */

    END IF; /* end of mandatory check  */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_bank_nz');
END CE_VALIDATE_BANK_NZ;

/* ---------------------------------------------------------------------
| Bank Number Validation: JAPAN                                         |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BANK_JP(
        Xi_BANK_NUMBER      in varchar2,
        Xi_BANK_NAME_ALT    in varchar2,
        Xi_PASS_MAND_CHECK  in varchar2
) AS

    bank_value      VARCHAR2(30);
    numeric_result  VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bank_jp');

    -- check that BANK_NAME_ALT is also entered
    -- 7582842: This check is done irrespective of the disable profile option
    IF (Xi_BANK_NAME_ALT is null) THEN
        ce_failed_mandatory('BANK_NAME_ALT');
    END IF;

    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- remove spaces and hyphens --
    BANK_VALUE := upper(replace(Xi_BANK_NUMBER,' ',''));
    BANK_VALUE := replace(BANK_VALUE,'-','');

    IF Xi_PASS_MAND_CHECK = 'F'
    THEN
        ce_failed_mandatory('BANK_NUM');

    ELSIF Xi_PASS_MAND_CHECK = 'P'
    THEN
        --bug 5746679 change from 3 numeric digits to 4 numberic digits
        IF length(BANK_VALUE) = 4
        THEN
            /* length is ok */
            numeric_result := ce_check_numeric(BANK_VALUE,1,length(BANK_VALUE));
            IF numeric_result = '0'
            THEN
                /* its numeric - validations successful  */
                ce_passed_check('BANK','JP');
            ELSE
                ce_failed_check('BANK_NUM','NUMERIC');
            END IF;  /* end of numeric check */

        ELSE
            ce_failed_check('BANK_NUM','LENGTH','4');
        END IF;  /* end of length check */

    END IF; /* end of mandatory check for bank num */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_bank_jp');
END CE_VALIDATE_BANK_JP;

-- 8266356: Added procedure
/* ---------------------------------------------------------------------
| Bank Number Validation: AUSTRIA                                     |
 ----------------------------------------------------------------------*/
procedure CE_VALIDATE_BANK_AT(
        Xi_BANK_NUMBER  in varchar2,
        Xi_PASS_MAND_CHECK in varchar2,
        Xo_VALUE_OUT OUT NOCOPY varchar2
) AS

    bank_value VARCHAR2(30);
    numeric_result VARCHAR2(40);

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bank_at');

    Xo_VALUE_OUT := Xi_BANK_NUMBER;
    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    -- 8266356: Bank Number is not mandatory.
    IF Xi_BANK_NUMBER IS NOT NULL
    THEN
        BANK_VALUE := upper(Xi_BANK_NUMBER);
        BANK_VALUE := replace(replace(BANK_VALUE,' ',''),'-','');
        IF ( length(BANK_VALUE) = 5 )
        THEN
            /* length is ok */
            numeric_result := ce_check_numeric(BANK_VALUE,1,length(BANK_VALUE));
            IF (numeric_result = '0')
            THEN
                /* its numeric validations successful */
                Xo_VALUE_OUT := BANK_VALUE;
                ce_passed_check('BANK','AT');
            ELSE
                ce_failed_check('BANK_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        ELSE
            ce_failed_check('BANK_NUM','LENGTH','5');
        END IF;  /* end of length check */
    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_bank_at');
END CE_VALIDATE_BANK_AT;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_UNIQUE_ACCOUNT_*                                     |
|                                                                       |
|  CALLED BY                                                            |
|      CE_VALIDATE_ACCOUNT                                              |
|                                                                       |
|  DESCRIPTION                                                          |
|      Unique Account VALIDATIONS                                       |
|                                                                       |
|                                                                       |
 --------------------------------------------------------------------- */
PROCEDURE CE_VALIDATE_UNIQUE_ACCOUNT(
    Xi_ACCOUNT_NUMBER  in VARCHAR2,
    Xi_CURRENCY_CODE   in VARCHAR2,
    Xi_ACCOUNT_NAME    in VARCHAR2,
    Xi_BRANCH_ID       in NUMBER,
    Xi_ACCOUNT_ID      in NUMBER
) AS
    temp_number     number;
BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_ACCOUNT');

    -- unique combination -> bank_branch_id, bank account number, currency code
    -- due to upgrade changes, the unique combination was changed to:
    -- bank_branch_id, bank account number, currency code, and account name
    SELECT COUNT(*) INTO temp_number
    FROM   ce_bank_accounts ba
    WHERE  ba.bank_account_num  =  Xi_ACCOUNT_NUMBER
    AND    ba.bank_account_name =  Xi_ACCOUNT_NAME
    AND    ba.bank_branch_id    =  Xi_BRANCH_ID
    AND    ba.currency_code     =  Xi_CURRENCY_CODE
    AND    ba.bank_account_id   <> nvl(Xi_ACCOUNT_ID,-1);

    cep_standard.debug('CE_VALIDATE_UNIQUE_ACCOUNT: ' || 'temp_number: '||temp_number);

    IF (nvl(temp_number,0) > 0) THEN
        cep_standard.debug('CE_VALIDATE_UNIQUE_ACCOUNT: ' || 'CE_BANK_ACCOUNT_NUM_EXISTS');
        fnd_message.set_name('CE', 'CE_BANK_ACCOUNT_NUM_EXISTS');
        fnd_msg_pub.add;
    END IF;

    -- unique combination -> bank_branch_id, bank account name
    -- Bug 7836516 removed this check
    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_ACCOUNT');

END CE_VALIDATE_UNIQUE_ACCOUNT;

/* -------------------------------------------------------------------- */

PROCEDURE CE_VALIDATE_UNIQUE_ACCOUNT_JP(
        Xi_ACCOUNT_NUMBER in VARCHAR2,
        Xi_CURRENCY_CODE  in VARCHAR2,
        Xi_ACCOUNT_TYPE   in VARCHAR2,
        Xi_ACCOUNT_NAME   in VARCHAR2,
        Xi_BRANCH_ID      in NUMBER,
        Xi_ACCOUNT_ID     in NUMBER
)AS
    temp_number     NUMBER;
BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_ACCOUNT_JP');

    -- unique combination -> bank_branch_id, bank account number, currency code, account type
    -- due to upgrade changes account name was added to the unique combination
    SELECT count(*) INTO temp_number
    FROM   ce_bank_accounts ba
    WHERE  ba.bank_account_num = Xi_ACCOUNT_NUMBER
    AND    ba.bank_account_name = Xi_ACCOUNT_NAME
    AND    ba.bank_account_type = Xi_ACCOUNT_TYPE
    AND    ba.currency_code     = Xi_CURRENCY_CODE
    AND    ba.bank_branch_id    = Xi_BRANCH_ID
    AND    ba.bank_account_id  <> nvl(Xi_ACCOUNT_ID,-1);

    cep_standard.debug('CE_VALIDATE_UNIQUE_ACCOUNT: ' || 'temp_number: '||temp_number);

    IF (nvl(temp_number,0) > 0) THEN
        fnd_message.set_name('CE', 'CE_BANK_ACCOUNT_NUM_EXISTS');
        fnd_msg_pub.add;
        cep_standard.debug('CE_VALIDATE_UNIQUE_ACCOUNT: ' || 'CE_BANK_ACCOUNT_NUM_EXISTS');
    END IF;

    -- unique combination -> bank_branch_id, bank account name
    -- Bug 7836516 removed this check

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_ACCOUNT_JP');

END CE_VALIDATE_UNIQUE_ACCOUNT_JP;

/* -------------------------------------------------------------------- */
PROCEDURE CE_VALIDATE_UNIQUE_ACCOUNT_NZ(
        Xi_ACCOUNT_NUMBER in VARCHAR2,
        Xi_CURRENCY_CODE  in VARCHAR2,
        Xi_ACCOUNT_SUFFIX in VARCHAR2,
        Xi_ACCOUNT_NAME   in VARCHAR2,
        Xi_BRANCH_ID      in NUMBER,
        Xi_ACCOUNT_ID     in NUMBER)
AS

temp_number     NUMBER;

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_ACCOUNT_NZ');

    -- unique combination -> bank_branch_id, bank account number, currency code, account suffix
    -- due to upgrade changes account name was added to the unique combination
    SELECT COUNT(*) INTO temp_number
    FROM   ce_bank_accounts ba
    WHERE  ba.bank_account_num = Xi_ACCOUNT_NUMBER
    AND    ba.bank_account_name = Xi_ACCOUNT_NAME
    AND    ba.account_suffix    = Xi_ACCOUNT_SUFFIX
    AND    ba.currency_code     = Xi_CURRENCY_CODE
    AND    ba.bank_branch_id    = Xi_BRANCH_ID
    AND    ba.bank_account_id  <> nvl(Xi_ACCOUNT_ID,-1);

    cep_standard.debug('CE_VALIDATE_UNIQUE_ACCOUNT: ' || 'temp_number: ' || temp_number);

    IF (nvl(temp_number,0) > 0) THEN
        cep_standard.debug('CE_VALIDATE_UNIQUE_ACCOUNT: ' || 'CE_BANK_ACCOUNT_NUM_EXISTS');
        fnd_message.set_name('CE', 'CE_BANK_ACCOUNT_NUM_EXISTS');
        fnd_msg_pub.add;
    END IF;

    -- unique combination -> bank_branch_id, bank account name
    -- Bug 7836516 removed this check

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_ACCOUNT_NZ');
END CE_VALIDATE_UNIQUE_ACCOUNT_NZ;


/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_UNIQUE_BRANCH_*                                      |
|                                                                       |
|  CALLED BY                                                            |
|      CE_VALIDATE_BRANCH                                               |
|                                                                       |
|  DESCRIPTION                                                          |
|      Unique Branch VALIDATIONS                                        |
|                                                                       |
 --------------------------------------------------------------------- */
procedure CE_VALIDATE_UNIQUE_BRANCH(
    Xi_COUNTRY_NAME in varchar2,
    Xi_BRANCH_NUMBER in varchar2,
    Xi_BRANCH_NAME    in varchar2,
    Xi_BANK_ID    in number,
    Xi_BRANCH_ID  in number
) AS
BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_BRANCH');
    -- unique combination -> bank_id, branch_name, country
    CE_VALIDATE_BANKINFO.CE_UNIQUE_BRANCH_NAME(
        Xi_COUNTRY_NAME,
        Xi_BRANCH_NAME,
        Xi_BANK_ID,
        Xi_BRANCH_ID);

    -- unique combination -> bank_id,  branch_number, country
    CE_VALIDATE_BANKINFO.CE_UNIQUE_BRANCH_NUMBER(
        Xi_COUNTRY_NAME,
        Xi_BRANCH_NUMBER,
        Xi_BANK_ID,
        Xi_BRANCH_ID);

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_BRANCH');
END CE_VALIDATE_UNIQUE_BRANCH;

/* -------------------------------------------------------------------- */
PROCEDURE CE_VALIDATE_UNIQUE_BRANCH_JP(
    Xi_COUNTRY_NAME in varchar2,
    Xi_BRANCH_NUMBER in varchar2,
    Xi_BRANCH_NAME    in varchar2,
    Xi_BRANCH_NAME_ALT in varchar2,
    Xi_BANK_ID    in number,
    Xi_BRANCH_ID  in number
) AS
BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_BRANCH_JP');
    -- unique combination -> bank_id, branch_name, country
    CE_VALIDATE_BANKINFO.CE_UNIQUE_BRANCH_NAME(
        Xi_COUNTRY_NAME,
        Xi_BRANCH_NAME,
        Xi_BANK_ID,
        Xi_BRANCH_ID);

    -- unique combination -> bank_id,  branch_number, country
    CE_VALIDATE_BANKINFO.CE_UNIQUE_BRANCH_NUMBER(
        Xi_COUNTRY_NAME,
        Xi_BRANCH_NUMBER,
        Xi_BANK_ID,
        Xi_BRANCH_ID);

    -- unique combination -> bank_id,  branch_name_alt, country  bug 2363959
    CE_VALIDATE_BANKINFO.CE_UNIQUE_BRANCH_NAME_ALT(
        Xi_COUNTRY_NAME,
        Xi_BRANCH_NAME_ALT,
        Xi_BANK_ID,
        Xi_BRANCH_ID);

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_BRANCH_JP');
END CE_VALIDATE_UNIQUE_BRANCH_JP;

/* -------------------------------------------------------------------- */
PROCEDURE CE_VALIDATE_UNIQUE_BRANCH_DE(
    Xi_BRANCH_NUMBER in varchar2,
    Xi_BRANCH_NAME    in varchar2,
    Xi_BANK_ID    in number,
    Xi_BRANCH_ID  in number
) AS
BEGIN
    cep_standard.debug('CE_VALIDATE_UNIQUE_BRANCH_DE remove unique requirement');

END CE_VALIDATE_UNIQUE_BRANCH_DE;

/* -------------------------------------------------------------------- */

PROCEDURE CE_VALIDATE_UNIQUE_BRANCH_US(
    Xi_BRANCH_NUMBER in varchar2,
    Xi_BRANCH_NAME    in varchar2,
    Xi_BANK_ID    in number,
    Xi_BRANCH_ID  in number
) AS
BEGIN
    cep_standard.debug('CE_VALIDATE_UNIQUE_BRANCH_US remove unique requirement');
END CE_VALIDATE_UNIQUE_BRANCH_US;


/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_UNIQUE_BANK_*                                        |
|                                                                       |
|  CALLED BY                                                            |
|      CE_VALIDATE_BANK                                                 |
|                                                                       |
|  DESCRIPTION                                                          |
|      Unique Bank  VALIDATIONS                                         |
|                                                                       |
 --------------------------------------------------------------------- */
PROCEDURE CE_VALIDATE_UNIQUE_BANK_JP(
    Xi_COUNTRY_NAME in varchar2,
    Xi_BANK_NUMBER in varchar2,
    Xi_BANK_NAME     in varchar2,
    Xi_BANK_NAME_ALT in varchar2,
    Xi_BANK_ID   in varchar2
) AS
    temp_number number;
    temp_name number;
    temp_name_alt number;
BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_BANK_JP');
    -- unique combination -> bank_name_alt, country  bug 2363959 --confirmed sql 6/28/02
    SELECT COUNT(*)
    INTO   temp_name_alt
    FROM   HZ_PARTIES   HzPartyBankEO,
           HZ_ORGANIZATION_PROFILES   HzOrgProfileBankEO,
           HZ_CODE_ASSIGNMENTS   HzCodeAssignmentBankEO
    WHERE  HzPartyBankEO.ORGANIZATION_NAME_PHONETIC =  Xi_BANK_NAME_ALT
      AND  HzOrgProfileBankEO.home_country     = Xi_COUNTRY_NAME -- 8552410: Changed HzPartyBankEO to HzOrgProfileBankEO
      AND  HzPartyBankEO.PARTY_TYPE = 'ORGANIZATION'
      AND  HzPartyBankEO.status = 'A'
      AND  HzPartyBankEO.PARTY_ID = HzOrgProfileBankEO.PARTY_ID
      AND  SYSDATE BETWEEN TRUNC(HzOrgProfileBankEO.EFFECTIVE_START_DATE)
                   AND NVL(TRUNC(HzOrgProfileBankEO.EFFECTIVE_END_DATE),SYSDATE)
      AND  HzCodeAssignmentBankEO.CLASS_CATEGORY = 'BANK_INSTITUTION_TYPE'
      AND  HzCodeAssignmentBankEO.CLASS_CODE = 'BANK'
      AND  HzCodeAssignmentBankEO.OWNER_TABLE_NAME = 'HZ_PARTIES'
      AND  HzCodeAssignmentBankEO.OWNER_TABLE_ID = HzPartyBankEO.PARTY_ID
      AND  NVL(HzCodeAssignmentBankEO.status, 'A') = 'A'
      AND  HzPartyBankEO.PARTY_ID <> NVL(Xi_BANK_ID, -1);  -- Bug 8552410: Changed = to <>

    cep_standard.debug('CE_VALIDATE_UNIQUE_BANK_JP - temp_name_alt: ' ||temp_name_alt);

    IF (nvl(temp_name_alt,0) > 0) THEN
        cep_standard.debug('CE_VALIDATE_UNIQUE_BANK_JP: ' || 'CE_BANK_NAME_ALT_EXISTS');
        fnd_message.set_name('CE', 'CE_BANK_NAME_ALT_EXISTS');
        fnd_msg_pub.add;
    END IF;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_BANK_JP');
END CE_VALIDATE_UNIQUE_BANK_JP;

-- added 10/25/04
/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_MISC_*   other misc validations
 --------------------------------------------------------------------- */
PROCEDURE CE_VALIDATE_MISC_EFT_NUM(
    x_country_name      IN VARCHAR2,
    x_eft_number        IN VARCHAR2,
    p_init_msg_list     IN  VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    x_return_status     IN OUT NOCOPY VARCHAR2
) AS
    country_name   VARCHAR2(2);
    eft_num_value  VARCHAR2(60);
    numeric_result VARCHAR2(40);

    procedure fail_mandatory is
    begin
       fnd_message.set_name ('CE', 'CE_ENTER_EFT_NUMBER');
       fnd_msg_pub.add;
       cep_standard.debug('CE_VALIDATE_MISC_EFT_NUM: ' || 'CE_ENTER_EFT_NUMBER');
    end fail_mandatory;

    procedure fail_check is
    begin
       fnd_message.set_name ('CE', 'CE_INVALID_EFT_NUMBER');
       fnd_msg_pub.add;
       cep_standard.debug('CE_VALIDATE_MISC_EFT_NUM: ' || 'CE_INVALID_EFT_NUMBER');
    end fail_check;

    procedure pass_check is
    begin
       cep_standard.debug('CE_VALIDATE_MISC_EFT_NUM: ' || 'pass_check');
    end pass_check;
BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_VALIDATE_MISC_EFT_NUM');

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    COUNTRY_NAME  := X_COUNTRY_NAME;
    cep_standard.debug('CE_VALIDATE_MISC_EFT_NUM - COUNTRY_NAME: '|| COUNTRY_NAME);

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    EFT_NUM_VALUE := upper(replace(X_EFT_NUMBER,' ',''));
    EFT_NUM_VALUE := replace(EFT_NUM_VALUE,'-','');

    IF (COUNTRY_NAME = 'IL') THEN
        IF (EFT_NUM_VALUE is null) THEN
            fail_mandatory;
        ELSE
            IF length(EFT_NUM_VALUE) = 8 THEN
                numeric_result := ce_check_numeric(EFT_NUM_VALUE,1,length(EFT_NUM_VALUE));
                IF numeric_result = '0'      THEN
                    --  its numeric so continue
                    pass_check;
                ELSE
                    fail_check;
                END IF;  -- end of numeric check
            ELSE
                fail_check;
            END IF;  -- end of length check
        END IF; --  end of mandatory check
    ELSE -- other countries pass_check
        pass_check;
    END IF; -- end of country_name

    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    IF x_msg_count > 0 THEN
        x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    cep_standard.debug('CE_VALIDATE_BANKINFO.ce_validate_misc_eft_num - P_COUNT: '|| x_msg_count);
    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_VALIDATE_MISC_EFT_NUM');

EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('CE_VALIDATE_BANKINFO.CE_VALIDATE_MISC_EFT_NUM ' ||X_COUNTRY_NAME );
    FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
    fnd_message.set_token('PROCEDURE', 'CE_VALIDATE_BANKINFO.cd_validate_misc_eft_num');
    fnd_msg_pub.add;
    RAISE;
END CE_VALIDATE_MISC_EFT_NUM;

/* -------------------------------------------------------------------- */

PROCEDURE CE_VALIDATE_MISC_ACCT_HLDR_ALT(
    X_COUNTRY_NAME              IN VARCHAR2,
    X_ACCOUNT_HOLDER_ALT        IN VARCHAR2,
    X_ACCOUNT_CLASSIFICATION    IN VARCHAR2,
    p_init_msg_list             IN VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_return_status             IN OUT NOCOPY VARCHAR2
) AS
    COUNTRY_NAME        VARCHAR2(2);
    ACCOUNT_HOLDER_ALT  VARCHAR2(60);
    numeric_result      VARCHAR2(40);

    procedure fail_mandatory is
    begin
       fnd_message.set_name ('CE', 'CE_ENTER_ACCOUNT_HOLDER_ALT');
       fnd_msg_pub.add;
       cep_standard.debug('CE_VALIDATE_MISC_ACCT_HLDR_ALT: ' || 'CE_ENTER_ACCOUNT_HOLDER_ALT');
    end fail_mandatory;

    procedure pass_check is
    begin
       cep_standard.debug('pass_check');
    end pass_check;

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_VALIDATE_MISC_ACCT_HLDR_ALT');

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    COUNTRY_NAME  := X_COUNTRY_NAME;
    cep_standard.debug('CE_VALIDATE_MISC_ACCT_HLDR_ALT - COUNTRY_NAME: '|| COUNTRY_NAME);

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    ACCOUNT_HOLDER_ALT := X_ACCOUNT_HOLDER_ALT;
    IF (COUNTRY_NAME = 'JP') THEN
        IF (ACCOUNT_HOLDER_ALT is null and X_ACCOUNT_CLASSIFICATION = 'INTERNAL') THEN
            fail_mandatory;
        ELSE
            pass_check;
        END IF; -- end of mandatory check
    ELSE -- other countries pass_check
        pass_check;
    END IF; -- end of country_name

    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    IF x_msg_count > 0 THEN
       x_return_status := fnd_api.g_ret_sts_error;
    END IF;
    cep_standard.debug('CE_VALIDATE_BANKINFO.ce_validate_misc_acct_hldr_alt - P_COUNT: '|| x_msg_count);

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_VALIDATE_MISC_ACCT_HLDR_ALT');
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('CE_VALIDATE_BANKINFO.CE_VALIDATE_MISC_ACCT_HLDR_ALT ' ||X_COUNTRY_NAME );
    FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
    fnd_message.set_token('PROCEDURE', 'CE_VALIDATE_BANKINFO.cd_validate_misc_acct_hldr_alt');
    fnd_msg_pub.add;
    RAISE;
END CE_VALIDATE_MISC_ACCT_HLDR_ALT;

-- added 12/18/06
/* -------------------------------------------------------------------- */

PROCEDURE ce_validate_branch_is_format(
    Xi_BRANCH_NUMBER    in varchar2,
    Xo_VALUE_OUT        OUT NOCOPY varchar2
) AS
    branch_num      VARCHAR2(100);
    numeric_result  VARCHAR2(100);
BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_IS_FORMAT');

    Xo_VALUE_OUT := Xi_BRANCH_NUMBER;
    -- 7582842: Disable validations using profile option
    IF CE_DISABLE_VALIDATION THEN
        cep_standard.debug('validations disabled. no check done');
        RETURN;
    END IF;

    BRANCH_NUM := upper(replace(Xi_BRANCH_NUMBER,' ',''));
    BRANCH_NUM := replace(BRANCH_NUM,'-','');

    IF (BRANCH_NUM) IS NOT NULL
    THEN    /* length is ok */
        IF length(BRANCH_NUM) <= 4
        THEN
            numeric_result := ce_check_numeric(BRANCH_NUM,1,length(BRANCH_NUM));
            IF numeric_result = '0'
            THEN /* its numeric so continue  */
                Xo_value_out := lpad(BRANCH_NUM,4,0);
                BRANCH_NUM := lpad(BRANCH_NUM,4,0);
            ELSE
                ce_failed_check('BRANCH_NUM','NUMERIC');
            END IF;  /* end of numeric check */
        ELSE
            ce_failed_check('BRANCH_NUM','LENGTH_MAX','4');
        END IF;  /* end of length check */
    END IF;  /* end of null check */

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_IS_FORMAT');
END CE_VALIDATE_BRANCH_IS_FORMAT;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      GET_BRANCH_NUM_FORMAT                                               |
|                                                                       |
|  CALLED BY                                                            |
|      AR                                |
|                                                                       |
|  CALLS                                                                |
|      CE_VALIDATE_BRANCH_*           for each country                  |
|      CE_VALIDATE_BRANCH_IS_FORMAT                                     |
 --------------------------------------------------------------------- */
PROCEDURE GET_BRANCH_NUM_FORMAT(
    x_country_name  IN VARCHAR2,
    x_branch_number IN VARCHAR2,
    x_value_out     OUT NOCOPY Varchar2,
    p_init_msg_list IN VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2,
    x_return_status IN OUT NOCOPY VARCHAR2
) AS

    COUNTRY_NAME   VARCHAR2(2);
    X_PASS_MAND_CHECK  VARCHAR2(1);

    procedure fail_mandatory is
    begin
       fnd_message.set_name ('CE', 'CE_ENTER_BRANCH_NUM');
       fnd_msg_pub.add;
       cep_standard.debug('GET_BRANCH_NUM_FORMAT: ' || 'CE_ENTER_BRANCH_NUM');
    end fail_mandatory;

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.GET_BRANCH_NUM_FORMAT');

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    COUNTRY_NAME  := X_COUNTRY_NAME;
    X_VALUE_OUT := X_BRANCH_NUMBER;
    cep_standard.debug('COUNTRY_NAME: '|| COUNTRY_NAME);
    cep_standard.debug('X_VALUE_OUT: '|| X_VALUE_OUT);

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    /* We must validate the Bank Branch Number */
    IF X_BRANCH_NUMBER is null   THEN
        X_PASS_MAND_CHECK := 'F';
    ELSE
        X_PASS_MAND_CHECK := 'P';
    END IF;

    cep_standard.debug('GET_BRANCH_NUM_FORMAT - X_PASS_MAND_CHECK: '|| X_PASS_MAND_CHECK);
    IF (X_PASS_MAND_CHECK = 'P')  THEN
        IF (COUNTRY_NAME = 'AT') THEN
            CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_AT(
                X_BRANCH_NUMBER,
                X_PASS_MAND_CHECK,
                X_VALUE_OUT);

        ELSIF (COUNTRY_NAME = 'ES') THEN
            CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_ES(
                X_BRANCH_NUMBER,
                X_PASS_MAND_CHECK,
                X_VALUE_OUT);

        ELSIF (COUNTRY_NAME = 'FR') THEN
            CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_FR(
                X_BRANCH_NUMBER,
                X_PASS_MAND_CHECK,
                X_VALUE_OUT);

        ELSIF (COUNTRY_NAME = 'BR') THEN
            CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_BR(
                X_BRANCH_NUMBER,
                X_PASS_MAND_CHECK,
                X_VALUE_OUT);

        ELSIF (COUNTRY_NAME = 'IS') THEN
            CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_IS_FORMAT(
                X_BRANCH_NUMBER,
                X_VALUE_OUT);

        ELSIF (COUNTRY_NAME = 'US') THEN
            CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_US(
                X_BRANCH_NUMBER,
                X_PASS_MAND_CHECK,
                X_VALUE_OUT);

        END IF;
    ELSE
        fail_mandatory;
    END IF;

    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    IF x_msg_count > 0 THEN
        x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    cep_standard.debug('P_COUNT: '|| x_msg_count );
    cep_standard.debug('X_VALUE_OUT: '|| X_VALUE_OUT);
    cep_standard.debug('<<CE_VALIDATE_BANKINFO.GET_BRANCH_NUM_FORMAT');

EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('CE_VALIDATE_BANKINFO.GET_BRANCH_NUM_FORMAT ' ||X_COUNTRY_NAME );
    FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
    fnd_message.set_token('PROCEDURE', 'CE_VALIDATE_BANKINFO.GET_BRANCH_NUM_FORMAT');
    fnd_msg_pub.add;
    RAISE;
END GET_BRANCH_NUM_FORMAT;

-- bug 6856840 : Added procedure
/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|      CE_VALIDATE_BRANCH_BANK                                          |
|                                                                       |
|  DESCRIPTION                                                          |
|     This procedure sets the global variable BANK_ID_IS_NUM and calls  |
|     the country-specific branch validation procedure.                 |
|                                                                       |
|  CALLED BY                                                            |
|      IBY                                                              |
|                                                                       |
|  CALLS                                                                |
|      CE_VALIDATE_BRANCH_*           for some countries                |
 --------------------------------------------------------------------- */
procedure CE_VALIDATE_BRANCH_BANK (
    Xi_COUNTRY     IN varchar2,
    Xi_BRANCH_NUM  IN varchar2,
    Xi_BANK_NUM    IN varchar2,
	Xo_VALUE_OUT   OUT NOCOPY varchar2
) AS
BEGIN
    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_BANK');

    -- setting global variable to map Bank ID as Bank Number instead
    -- of party ID
    BANK_ID_IS_NUM := TRUE;

	Xo_VALUE_OUT := Xi_BRANCH_NUM;
	-- depending upon country code call the appropriate function
    IF    Xi_COUNTRY = 'AU'
    THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_AU(
                    Xi_BRANCH_NUMBER    => Xi_BRANCH_NUM,
                    Xi_BANK_ID          => Xi_BANK_NUM,
                    Xi_PASS_MAND_CHECK  => 'P');

    ELSIF Xi_COUNTRY = 'DE'
    THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_DE(
                    Xi_BRANCH_NUMBER    => Xi_BRANCH_NUM,
                    Xi_BANK_ID          => Xi_BANK_NUM);

    ELSIF Xi_COUNTRY = 'IS'
    THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_IS(
                    Xi_BRANCH_NUMBER    => Xi_BRANCH_NUM,
                    Xi_BANK_ID          => Xi_BANK_NUM,
					Xo_VALUE_OUT		=> Xo_VALUE_OUT);

    ELSIF Xi_COUNTRY = 'IE'
    THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_IE(
                    Xi_BRANCH_NUMBER    => Xi_BRANCH_NUM,
                    Xi_BANK_ID          => Xi_BANK_NUM);

    ELSIF Xi_COUNTRY = 'LU'
    THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_LU(
                    Xi_BRANCH_NUMBER    => Xi_BRANCH_NUM,
                    Xi_BANK_ID          => Xi_BANK_NUM);

    ELSIF Xi_COUNTRY = 'PL'
    THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_PL(
                    Xi_BRANCH_NUMBER    => Xi_BRANCH_NUM,
                    Xi_BANK_ID          => Xi_BANK_NUM);

    ELSIF Xi_COUNTRY = 'SE'
    THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_SE(
                    Xi_BRANCH_NUMBER    => Xi_BRANCH_NUM,
                    Xi_BANK_ID          => Xi_BANK_NUM);

    ELSIF Xi_COUNTRY = 'CH'
    THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_CH(
                    Xi_BRANCH_NUMBER    => Xi_BRANCH_NUM,
                    Xi_BANK_ID          => Xi_BANK_NUM);

    ELSIF Xi_COUNTRY = 'GB'
    THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_GB(
                    Xi_BRANCH_NUMBER    => Xi_BRANCH_NUM,
                    Xi_BANK_ID          => Xi_BANK_NUM);
    END IF;

    -- resetting the variable
    BANK_ID_IS_NUM := FALSE;

    cep_standard.debug('<<CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_BANK');
END CE_VALIDATE_BRANCH_BANK;

--  7582842: The following procedures are no longer used by CE:
--    1) UPD_BANK_UNIQUE
--    2) UPD_BANK_VALIDATE
--    3) UPD_BRANCH_UNIQUE
--    4) UPD_BRANCH_VALIDATE
--    5) UPD_ACCOUNT_UNIQUE
--    6) UPD_ACCOUNT_VALIDATE
--   But, these have been retained due to possible external dependencies
--   as these are public porcedures
/* -------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                   |
|   UPD_BANK_UNIQUE                                                   |
|    Description:  Bank uniqueness validation                         |
|    Usage:        Bug 7582842 - No longer called by CE               |
|    Calls:        CE_VALIDATE_UNIQUE_BANK_*                          |
 --------------------------------------------------------------------*/
PROCEDURE UPD_BANK_UNIQUE(
    X_COUNTRY_NAME    IN varchar2,
    X_BANK_NUMBER     IN varchar2,
    X_BANK_NAME       IN varchar2,
    X_BANK_NAME_ALT   IN varchar2,
    X_TAX_PAYER_ID    IN varchar2,
    X_BANK_ID         IN NUMBER,
    p_init_msg_list   IN VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2,
    X_VALUE_OUT      OUT NOCOPY varchar2,
    x_return_status     IN OUT NOCOPY VARCHAR2,
    X_ACCOUNT_CLASSIFICATION IN VARCHAR2 DEFAULT NULL
) AS
    COUNTRY_NAME   VARCHAR2(2);
    X_PASS_MAND_CHECK  VARCHAR2(1);
BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.upd_bank_unique');
    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    COUNTRY_NAME  := X_COUNTRY_NAME;
    X_VALUE_OUT := X_BANK_NUMBER;

    cep_standard.debug('COUNTRY_NAME: '|| COUNTRY_NAME ||
                       ', X_VALUE_OUT: '|| X_VALUE_OUT);

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    cep_standard.debug('P_INIT_MSG_LIST: '|| P_INIT_MSG_LIST);

    /* UNIQUE VALIDATION CHECK for bank */
    cep_standard.debug('UNIQUE VALIDATION CHECK for bank' );

    IF (COUNTRY_NAME = 'JP') THEN
        cep_standard.debug('call CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_BANK_JP' );

        CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_BANK_JP(
            X_COUNTRY_NAME,
            X_BANK_NUMBER ,
            X_BANK_NAME ,
            X_BANK_NAME_ALT,
            X_BANK_ID);

    END IF;  /* country unique check for bank  */
    cep_standard.debug('CE_VALIDATE_CD: ' || 'UNIQUE VALIDATION CHECK for bank end' );

    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    IF x_msg_count > 0 THEN
        x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    cep_standard.debug('CE_VALIDATE_BANKINFO.upd_bank_unique - P_COUNT: '|| x_msg_count);
    cep_standard.debug('X_VALUE_OUT: '|| X_VALUE_OUT);
    cep_standard.debug('<<CE_VALIDATE_BANKINFO.upd_bank_unique');
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('CE_VALIDATE_BANKINFO.upd_bank_unique ' ||X_COUNTRY_NAME );
    FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
    fnd_message.set_token('PROCEDURE', 'CE_VALIDATE_BANKINFO.upd_bank_unique');
    fnd_msg_pub.add;
    RAISE;
END UPD_BANK_UNIQUE;

/* -------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                   |
|   UPD_BANK_VALIDATE                                                 |
|    Description:  Country specific Bank validation that does not     |
|                  include the uniqueness validations                 |
|    Usage:        Bug 7582842 - No longer called by CE               |
|    Calls:        CE_VALIDATE_BANK_*                                 |
 --------------------------------------------------------------------*/
PROCEDURE UPD_BANK_VALIDATE(
    X_COUNTRY_NAME    IN varchar2,
    X_BANK_NUMBER     IN varchar2,
    X_BANK_NAME       IN varchar2,
    X_BANK_NAME_ALT   IN varchar2,
    X_TAX_PAYER_ID    IN varchar2,
    X_BANK_ID         IN NUMBER,
    p_init_msg_list   IN VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2,
    X_VALUE_OUT      OUT NOCOPY varchar2,
    x_return_status     IN OUT NOCOPY VARCHAR2,
    X_ACCOUNT_CLASSIFICATION IN VARCHAR2 DEFAULT NULL
) AS
    COUNTRY_NAME   VARCHAR2(2);
    X_PASS_MAND_CHECK  VARCHAR2(1);

    l_value_out           VARCHAR2(40);-- 9250566: Added
    l_value_out_custom    VARCHAR2(40);-- 9250566: Added
    l_usr_valid           VARCHAR2(1); -- 9250566: Added
    l_count_before_custom NUMBER;      -- 9250566: Added
    l_count_after_custom  NUMBER;      -- 9250566: Added

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bank');

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    COUNTRY_NAME  := X_COUNTRY_NAME;
    l_value_out := X_BANK_NUMBER;

    cep_standard.debug('COUNTRY_NAME: '|| COUNTRY_NAME||
                       ', l_value_out: '|| l_value_out);

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    cep_standard.debug('CE_VALIDATE_BANKINFO.upd_bank_validate - P_INIT_MSG_LIST: '|| P_INIT_MSG_LIST);

    /* We must validate the Bank Number */
    IF X_BANK_NUMBER is null   THEN
        X_PASS_MAND_CHECK := 'F';
    ELSE
        X_PASS_MAND_CHECK := 'P';
    END IF;

    IF (COUNTRY_NAME = 'ES') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_ES(
            X_BANK_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'FR') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_FR(
            X_BANK_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'PT') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_PT(
            X_BANK_NUMBER,
            X_PASS_MAND_CHECK);

    ELSIF (COUNTRY_NAME = 'BR') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_BR(
            X_BANK_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    -- Added 5/14/02
    ELSIF (COUNTRY_NAME = 'DE') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_DE(X_BANK_NUMBER);

    ELSIF (COUNTRY_NAME = 'GR') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_GR(X_BANK_NUMBER);

    ELSIF (COUNTRY_NAME = 'IS') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_IS(
            X_BANK_NUMBER,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'IE') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_IE(X_BANK_NUMBER);

    ELSIF (COUNTRY_NAME = 'IT') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_IT(
            X_BANK_NUMBER,
            X_PASS_MAND_CHECK);

    ELSIF (COUNTRY_NAME = 'LU') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_LU(X_BANK_NUMBER);


    ELSIF (COUNTRY_NAME = 'PL') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_PL(X_BANK_NUMBER);

    ELSIF (COUNTRY_NAME = 'SE') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_SE(X_BANK_NUMBER);

    ELSIF (COUNTRY_NAME = 'CH') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_CH(X_BANK_NUMBER);

    ELSIF (COUNTRY_NAME = 'GB') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_GB(X_BANK_NUMBER);

    ELSIF (COUNTRY_NAME = 'CO') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_CO(
            X_COUNTRY_NAME,
            X_BANK_NAME ,
            X_TAX_PAYER_ID);

    -- Added 10/19/04
    ELSIF (COUNTRY_NAME = 'AU') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_AU(X_BANK_NUMBER);

    ELSIF (COUNTRY_NAME = 'IL') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_IL(
            X_BANK_NUMBER,
            X_PASS_MAND_CHECK);

    ELSIF (COUNTRY_NAME = 'NZ') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_NZ(
            X_BANK_NUMBER,
            X_PASS_MAND_CHECK);

    ELSIF (COUNTRY_NAME = 'JP') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_JP(
            X_BANK_NUMBER,
            X_BANK_NAME_ALT,
            X_PASS_MAND_CHECK);

            -- 8266356: Added
    ELSIF (COUNTRY_NAME = 'AT') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_AT(
            X_BANK_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    END IF;  /* country check for bank   */

    -- 9250566 ADDED 4/6 START -------------------------
    l_count_before_custom := Nvl(FND_MSG_PUB.count_msg,0);
    l_usr_valid := fnd_api.g_ret_sts_success;

    -- Call to custom validation routines
    cep_standard.debug('Calling custom validation hooks');
    cep_standard.debug('l_count_before=' ||l_count_before_custom);
    cep_standard.debug('l_value_out='    ||l_value_out);
    CE_CUSTOM_BANK_VALIDATIONS.ce_usr_validate_bank (
        Xi_COUNTRY_NAME    => X_COUNTRY_NAME,
        Xi_BANK_NUMBER     => l_value_out,
        Xi_BANK_NAME       => X_BANK_NAME,
        Xi_BANK_NAME_ALT   => X_BANK_NAME_ALT,
        Xi_TAX_PAYER_ID    => X_TAX_PAYER_ID,
        Xi_BANK_ID         => X_BANK_ID,
        Xo_BANK_NUM_OUT    => l_value_out_custom,
        Xo_RETURN_STATUS   => l_usr_valid
    );
    l_count_after_custom := FND_MSG_PUB.count_msg;
    cep_standard.debug('l_count_before='||l_count_before_custom);

    cep_standard.debug('l_value_out_custom='||l_value_out_custom);
    X_VALUE_OUT := NVL(l_value_out_custom,l_value_out);

    -- Check return status
    IF l_usr_valid = fnd_api.g_ret_sts_error
    THEN
       cep_standard.debug('Custom validations done - failure');
       IF l_count_after_custom = 0 THEN
          cep_standard.debug('No custom error message set');
       END IF;
    ELSE
       cep_standard.debug('Custom validations done - success');
       -- remove any unnecessary messages
       WHILE l_count_after_custom > l_count_before_custom
       LOOP
            FND_MSG_PUB.delete_msg(l_count_after_custom);
            l_count_after_custom := l_count_after_custom - 1;
            cep_standard.debug(l_count_after_custom);
        END LOOP;
        cep_standard.debug('After cleanup, count='||FND_MSG_PUB.count_msg);

    END IF;
    -- 9250566 ADDED 4/6 END --------------------------


    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    IF x_msg_count > 0 THEN
        x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    cep_standard.debug('CE_VALIDATE_BANKINFO.upd_bank_validate - P_COUNT: '|| x_msg_count);
    cep_standard.debug('X_VALUE_OUT: '|| X_VALUE_OUT);
    cep_standard.debug('<<CE_VALIDATE_BANKINFO.upd_bank_validate');
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: upd_bank_validate' ||X_COUNTRY_NAME );
    FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
    fnd_message.set_token('PROCEDURE', 'CE_VALIDATE_BANKINFO.upd_bank_validate');
    fnd_msg_pub.add;
    RAISE;
END UPD_BANK_VALIDATE;

/* -------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                   |
|   UPD_BRANCH_UNIQUE                                                 |
|    Description:  Branch uniqueness validation                       |
|    Usage:        Bug 7582842 - No longer called by CE               |
|    Calls:        CE_VALIDATE_UNIQUE_BRANCH_*                        |
 ------------------------------------------------------------------  */
PROCEDURE UPD_BRANCH_UNIQUE(
    X_COUNTRY_NAME     IN  varchar2,
    X_BANK_NUMBER      IN  varchar2,
    X_BRANCH_NUMBER    IN  varchar2,
    X_BANK_NAME        IN  varchar2,
    X_BRANCH_NAME      IN  varchar2,
    X_BRANCH_NAME_ALT  IN  varchar2,
    X_BANK_ID          IN  NUMBER,
    X_BRANCH_ID        IN  NUMBER,
    P_INIT_MSG_LIST    IN  VARCHAR2,
    X_MSG_COUNT        OUT NOCOPY NUMBER,
    X_MSG_DATA         OUT NOCOPY VARCHAR2,
    X_VALUE_OUT        OUT NOCOPY varchar2,
    X_RETURN_STATUS    IN OUT NOCOPY VARCHAR2,
    X_ACCOUNT_CLASSIFICATION IN VARCHAR2 DEFAULT NULL
) AS

    COUNTRY_NAME   VARCHAR2(2);
    X_PASS_MAND_CHECK  VARCHAR2(1);

BEGIN

    cep_standard.debug('>>CE_VALIDATE_BANKINFO.upd_branch_unique');

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    COUNTRY_NAME  := X_COUNTRY_NAME;
    X_VALUE_OUT := X_BRANCH_NUMBER;

    cep_standard.debug('CE_VALIDATE_BANKINFO.upd_branch_unique - COUNTRY_NAME: '|| COUNTRY_NAME||
        ',  X_VALUE_OUT: '|| X_VALUE_OUT);

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    /*   UNIQUE VALIDATION CHECK for branch   */
    cep_standard.debug('UNIQUE VALIDATION CHECK for branch' );

    -- bug 4730717,
    -- 11/30/05 unique validation for US and Germany bank branches should not
    -- be removed
    IF (COUNTRY_NAME = 'JP') THEN
        cep_standard.debug('call CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_BRANCH_JP' );

        CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_BRANCH_JP(
            X_COUNTRY_NAME,
            X_BRANCH_NUMBER,
            X_BRANCH_NAME,
            X_BRANCH_NAME_ALT,
            X_BANK_ID,
            X_BRANCH_ID);

    ELSE
        cep_standard.debug('call CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_BRANCH' );

        CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_BRANCH(
            X_COUNTRY_NAME,
            X_BRANCH_NUMBER,
            X_BRANCH_NAME,
            X_BANK_ID,
            X_BRANCH_ID);
    END IF;
    /*  end country unique check for branch   */

    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    IF x_msg_count > 0 THEN
        x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    cep_standard.debug('CE_VALIDATE_BANKINFO.upd_branch_unique - P_COUNT: '|| x_msg_count||
        ' X_VALUE_OUT: '|| X_VALUE_OUT||
        '<<CE_VALIDATE_BANKINFO.upd_branch_unique');

EXCEPTION
    WHEN OTHERS THEN
        cep_standard.debug('EXCEPTION: upd_branch_unique ' ||X_COUNTRY_NAME );
        FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
        fnd_message.set_token('PROCEDURE', 'CE_VALIDATE_BANKINFO.upd_branch_unique');
        fnd_msg_pub.add;
        RAISE;
END UPD_BRANCH_UNIQUE;


/* -------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                   |
|   UPD_BRANCH_VALIDATE                                               |
|    Description:  Country specific Branch validation                 |
|                  that does not include the uniqueness validation    |
|    Usage:        Bug 7582842 - No longer called by CE               |
|    Calls:        CE_VALIDATE_BRANCH_*                               |
 --------------------------------------------------------------------*/
PROCEDURE UPD_BRANCH_VALIDATE(
    x_country_name      IN  varchar2,
    x_bank_number       IN  varchar2,
    x_branch_number     IN  varchar2,
    x_bank_name         IN  varchar2,
    x_branch_name       IN  varchar2,
    x_branch_name_alt   IN  varchar2,
    x_bank_id           IN  NUMBER,
    x_branch_id         IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    x_value_out         OUT NOCOPY varchar2,
    x_return_status     IN OUT NOCOPY VARCHAR2,
    x_account_classification IN VARCHAR2 DEFAULT NULL,
    x_branch_type       IN VARCHAR2 DEFAULT NULL -- 9250566 added
) AS

    COUNTRY_NAME   VARCHAR2(2);
    X_PASS_MAND_CHECK  VARCHAR2(1);

    l_value_out           VARCHAR2(40);-- 9250566: Added
    l_value_out_custom    VARCHAR2(40);-- 9250566: Added
    l_usr_valid           VARCHAR2(1); -- 9250566: Added
    l_count_before_custom NUMBER;      -- 9250566: Added
    l_count_after_custom  NUMBER;      -- 9250566: Added

BEGIN

    cep_standard.debug('>>CE_VALIDATE_BANKINFO.upd_branch_validate');

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    COUNTRY_NAME  := X_COUNTRY_NAME;
    l_value_out := X_BRANCH_NUMBER;

    cep_standard.debug('COUNTRY_NAME: '|| COUNTRY_NAME);
    cep_standard.debug('l_value_out: '|| l_value_out);

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    /* We must validate the Bank Branch Number */
    IF X_BRANCH_NUMBER IS NULL THEN
        X_PASS_MAND_CHECK := 'F';
    ELSE
        X_PASS_MAND_CHECK := 'P';
    END IF;
    cep_standard.debug('X_PASS_MAND_CHECK: '|| X_PASS_MAND_CHECK);

    cep_standard.debug('Calling CE_VALIDATE_BRANCH_'||COUNTRY_NAME);
    IF (COUNTRY_NAME = 'AT') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_AT(
            X_BRANCH_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'ES') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_ES(
            X_BRANCH_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'FR') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_FR(
            X_BRANCH_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'PT') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_PT(
            X_BRANCH_NUMBER,
            X_PASS_MAND_CHECK);

    ELSIF (COUNTRY_NAME = 'BR') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_BR(
            X_BRANCH_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    -- added 5/14/02
    ELSIF (COUNTRY_NAME = 'DE') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_DE(
            X_BRANCH_NUMBER,
            X_BANK_ID);

    ELSIF (COUNTRY_NAME = 'GR') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_GR(X_BRANCH_NUMBER);

    ELSIF (COUNTRY_NAME = 'IS') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_IS(
            X_BRANCH_NUMBER,
            X_BANK_ID,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'IE') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_IE(
            X_BRANCH_NUMBER,
            X_BANK_ID);

    ELSIF (COUNTRY_NAME = 'IT') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_IT(
            X_BRANCH_NUMBER,
            X_PASS_MAND_CHECK);

    ELSIF (COUNTRY_NAME = 'LU') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_LU(
            X_BRANCH_NUMBER,
            X_BANK_ID);

    ELSIF (COUNTRY_NAME = 'PL') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_PL(
            X_BRANCH_NUMBER,
            X_BANK_ID);

    ELSIF (COUNTRY_NAME = 'SE') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_SE(
            X_BRANCH_NUMBER,
            X_BANK_ID);

    ELSIF (COUNTRY_NAME = 'CH') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_CH(
            X_BRANCH_NUMBER,
            X_BANK_ID);

    ELSIF (COUNTRY_NAME = 'GB') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_GB(
            X_BRANCH_NUMBER,
            X_BANK_ID);

    ELSIF (COUNTRY_NAME = 'US') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_US(
            X_BRANCH_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    -- added 10/19/04
    ELSIF (COUNTRY_NAME = 'AU') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_AU(X_BRANCH_NUMBER,
            X_BANK_ID,
            X_PASS_MAND_CHECK);

    ELSIF (COUNTRY_NAME = 'IL') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_IL(X_BRANCH_NUMBER,
            X_PASS_MAND_CHECK);

    ELSIF (COUNTRY_NAME = 'NZ') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_NZ(X_BRANCH_NUMBER,
            X_PASS_MAND_CHECK);

    ELSIF (COUNTRY_NAME = 'JP') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_JP(X_BRANCH_NUMBER,
            X_BRANCH_NAME_ALT,
            X_PASS_MAND_CHECK);

    -- 9249372: Added
    ELSIF (COUNTRY_NAME = 'FI') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_FI(X_BRANCH_NUMBER);

    END IF;

    -- 9250566 ADDED 5/6 START -------------------------
    l_count_before_custom := Nvl(FND_MSG_PUB.count_msg,0);
    l_usr_valid := fnd_api.g_ret_sts_success;

    -- Call to custom validation routines
    cep_standard.debug('Calling custom validation hooks');
    cep_standard.debug('l_count_before=' ||l_count_before_custom);
    cep_standard.debug('l_value_out='    ||l_value_out);
    CE_CUSTOM_BANK_VALIDATIONS.ce_usr_validate_branch(
        Xi_COUNTRY_NAME    => X_COUNTRY_NAME,
        Xi_BANK_NUMBER     => X_BANK_NUMBER,
        Xi_BRANCH_NUMBER   => l_value_out,
        Xi_BANK_NAME       => X_BANK_NAME,
        Xi_BRANCH_NAME     => X_BRANCH_NAME,
        Xi_BRANCH_NAME_ALT => X_BRANCH_NAME_ALT,
        Xi_BRANCH_TYPE     => X_BRANCH_TYPE,
        Xi_BANK_ID         => X_BANK_ID,
        Xi_BRANCH_ID       => X_BRANCH_ID,
        Xo_BRANCH_NUM_OUT  => l_value_out_custom,
        Xo_RETURN_STATUS   => l_usr_valid
    );

    l_count_after_custom := FND_MSG_PUB.count_msg;
    cep_standard.debug('l_count_before='||l_count_before_custom);

    cep_standard.debug('l_value_out_custom='||l_value_out_custom);
    X_VALUE_OUT := l_value_out_custom;

    -- Check return status
    IF l_usr_valid = fnd_api.g_ret_sts_error
    THEN
       cep_standard.debug('Custom validations done - failure');
       IF l_count_after_custom = 0 THEN
          cep_standard.debug('No custom error message set');
       END IF;
    ELSE
       cep_standard.debug('Custom validations done - success');
       -- remove any unnecessary messages
       WHILE l_count_after_custom > l_count_before_custom
       LOOP
            FND_MSG_PUB.delete_msg(l_count_after_custom);
            l_count_after_custom := l_count_after_custom - 1;
            cep_standard.debug(l_count_after_custom);
        END LOOP;
        cep_standard.debug('After cleanup, count='||FND_MSG_PUB.count_msg);

    END IF;
    -- 9250566 5/6 ADDED END --------------------------

    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    IF x_msg_count > 0 THEN
        x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    cep_standard.debug('P_COUNT: '|| x_msg_count);
    cep_standard.debug(' X_VALUE_OUT: '|| X_VALUE_OUT);
    cep_standard.debug('<<CE_VALIDATE_BANKINFO.upd_branch_validate');

EXCEPTION
    WHEN OTHERS THEN
        cep_standard.debug('EXCEPTION: upd_branch_validate ' ||X_COUNTRY_NAME );
        FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
        fnd_message.set_token('PROCEDURE', 'CE_VALIDATE_BANKINFO.upd_branch_validate');
        fnd_msg_pub.add;
        RAISE;
END UPD_BRANCH_VALIDATE;

/* -------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                   |
|   UPD_ACCOUNT_UNIQUE                                                |
|    Description:  Bank Account uniqueness validation                 |
|    Usage: Bug 7582842 - No longer called by CE                      |
|    Calls:        CE_VALIDATE_UNIQUE_ACCOUNT_*                       |
 --------------------------------------------------------------------*/
PROCEDURE UPD_ACCOUNT_UNIQUE(
    X_COUNTRY_NAME    IN varchar2,
    X_BANK_NUMBER     IN varchar2,
    X_BRANCH_NUMBER   IN varchar2,
    X_ACCOUNT_NUMBER  IN varchar2,
    X_BANK_ID         IN number,
    X_BRANCH_ID       IN number,
    X_ACCOUNT_ID      IN number,
    X_CURRENCY_CODE   IN varchar2,
    X_ACCOUNT_TYPE    IN varchar2,
    X_ACCOUNT_SUFFIX  IN varchar2,
    X_SECONDARY_ACCOUNT_REFERENCE  IN varchar2,
    X_ACCOUNT_NAME    IN varchar2,
    p_init_msg_list   IN  VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2,
    X_VALUE_OUT      OUT NOCOPY varchar2,
    x_return_status     IN OUT NOCOPY VARCHAR2,
    X_ACCOUNT_CLASSIFICATION IN VARCHAR2 DEFAULT NULL
) AS
    COUNTRY_NAME   VARCHAR2(2);
    X_PASS_MAND_CHECK  VARCHAR2(1);
BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.upd_account_unique');

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    COUNTRY_NAME  := X_COUNTRY_NAME;
    X_VALUE_OUT := X_ACCOUNT_NUMBER;

    cep_standard.debug('COUNTRY_NAME: '|| COUNTRY_NAME||
                       ', X_VALUE_OUT: '|| X_VALUE_OUT);

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    /*   UNIQUE VALIDATION CHECK for account   */
    cep_standard.debug('UNIQUE_VALIDATION CHECK for account');

    IF (COUNTRY_NAME = 'JP')   THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_ACCOUNT_JP(
            X_ACCOUNT_NUMBER,
            X_CURRENCY_CODE,
            X_ACCOUNT_TYPE,
            X_ACCOUNT_NAME,
            X_BRANCH_ID,
            X_ACCOUNT_ID);

    ELSIF (COUNTRY_NAME = 'NZ')   THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_ACCOUNT_NZ(
            X_ACCOUNT_NUMBER,
            X_CURRENCY_CODE,
            X_ACCOUNT_SUFFIX,
            X_ACCOUNT_NAME,
            X_BRANCH_ID,
            X_ACCOUNT_ID);
    ELSE
        CE_VALIDATE_BANKINFO.CE_VALIDATE_UNIQUE_ACCOUNT(
            X_ACCOUNT_NUMBER,
            X_CURRENCY_CODE,
            X_ACCOUNT_NAME,
            X_BRANCH_ID,
            X_ACCOUNT_ID);
    END IF;
    cep_standard.debug(' UNIQUE_VALIDATION CHECK for account end ');

    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    IF x_msg_count > 0 THEN
        x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    cep_standard.debug('CE_VALIDATE_BANKINFO.upd_account_unique - P_COUNT: '|| x_msg_count);
    cep_standard.debug('X_VALUE_OUT: '|| X_VALUE_OUT);
    cep_standard.debug('<<CE_VALIDATE_BANKINFO.upd_account_unique');
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('CE_VALIDATE_BANKINFO.upd_account_unique ' ||X_COUNTRY_NAME );
    FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
    fnd_message.set_token('PROCEDURE', 'CE_VALIDATE_BANKINFO.upd_account_unique');
    fnd_msg_pub.add;
    RAISE;
END UPD_ACCOUNT_UNIQUE;

/* -------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                   |
|   UPD_ACCOUNT_VALIDATE                                              |
|    Description:  Country specific Bank Account validation           |
|                  that does not include the uniqueness validations   |
|    Usage: Bug 7582842 - No longer called by CE                      |
|    Calls: CE_VALIDATE_ACCOUNT_*                                     |
 --------------------------------------------------------------------*/
PROCEDURE UPD_ACCOUNT_VALIDATE(
    X_COUNTRY_NAME    IN varchar2,
    X_BANK_NUMBER     IN varchar2,
    X_BRANCH_NUMBER   IN varchar2,
    X_ACCOUNT_NUMBER  IN varchar2,
    X_BANK_ID         IN number,
    X_BRANCH_ID       IN number,
    X_ACCOUNT_ID      IN number,
    X_CURRENCY_CODE   IN varchar2,
    X_ACCOUNT_TYPE    IN varchar2,
    X_ACCOUNT_SUFFIX  IN varchar2,
    X_SECONDARY_ACCOUNT_REFERENCE  IN varchar2,
    X_ACCOUNT_NAME    IN varchar2,
    p_init_msg_list   IN  VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2,
    X_VALUE_OUT      OUT NOCOPY varchar2,
    x_return_status     IN OUT NOCOPY VARCHAR2,
    X_ACCOUNT_CLASSIFICATION IN VARCHAR2 DEFAULT NULL,
    X_CD                 IN  varchar2  DEFAULT NULL,
    X_ELECTRONIC_ACCT_NUM    OUT NOCOPY varchar2
) AS
    COUNTRY_NAME   VARCHAR2(2);
    X_PASS_MAND_CHECK  VARCHAR2(1);
    NEW_ACCOUNT_NUM  VARCHAR2(100);

    l_value_out           VARCHAR2(40);-- 9250566: Added
    l_value_out_custom    VARCHAR2(40);-- 9250566: Added
    l_usr_valid           VARCHAR2(1); -- 9250566: Added
    l_count_before_custom NUMBER;      -- 9250566: Added
    l_count_after_custom  NUMBER;      -- 9250566: Added

BEGIN
    cep_standard.debug('>>CE_VALIDATE_BANKINFO.upd_account_validate');
    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    COUNTRY_NAME  := X_COUNTRY_NAME;
    l_value_out := X_ACCOUNT_NUMBER;
    X_ELECTRONIC_ACCT_NUM := X_ACCOUNT_NUMBER;

    cep_standard.debug('COUNTRY_NAME: '|| COUNTRY_NAME||
                       ', l_value_out: '|| l_value_out);

    -- Initialize message list if p_init_msg_list is set to TRUE.
    --IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    --END IF;

    /* We must validate the Bank Account Number */
    IF X_ACCOUNT_NUMBER is null   THEN
        X_PASS_MAND_CHECK := 'F';
    ELSE
        X_PASS_MAND_CHECK := 'P';
    END IF;

    IF (COUNTRY_NAME = 'AT') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_AT(
            X_ACCOUNT_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'DK') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_DK(
            X_ACCOUNT_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'NO') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_NO(
            X_ACCOUNT_NUMBER,
            X_PASS_MAND_CHECK);

    ELSIF (COUNTRY_NAME = 'ES') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_ES(
            X_ACCOUNT_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'NL') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_NL(
            X_ACCOUNT_NUMBER,
            X_PASS_MAND_CHECK);

    ELSIF (COUNTRY_NAME = 'FR') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_FR(
            X_ACCOUNT_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'BE') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_BE(
            X_ACCOUNT_NUMBER,
            X_PASS_MAND_CHECK);

    ELSIF (COUNTRY_NAME = 'PT') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_PT(
            X_ACCOUNT_NUMBER,
            X_PASS_MAND_CHECK,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'FI') THEN -- 8897744 Removed AND (X_BRANCH_NUMBER='LMP')
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_FI(
            X_ACCOUNT_NUMBER,
            X_PASS_MAND_CHECK);

    -- added 5/14/02
    ELSIF (COUNTRY_NAME = 'DE') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_DE(
            X_ACCOUNT_NUMBER,
            l_value_out );

    ELSIF (COUNTRY_NAME = 'GR') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_GR(
            X_ACCOUNT_NUMBER,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'IS') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_IS(
            X_ACCOUNT_NUMBER,
            l_value_out );

    ELSIF (COUNTRY_NAME = 'IE') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_IE(X_ACCOUNT_NUMBER);

    ELSIF (COUNTRY_NAME = 'IT') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_IT(
            X_ACCOUNT_NUMBER,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'LU') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_LU(X_ACCOUNT_NUMBER);

    ELSIF (COUNTRY_NAME = 'PL') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_PL(X_ACCOUNT_NUMBER);

    ELSIF (COUNTRY_NAME = 'SE') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_SE(X_ACCOUNT_NUMBER);

    ELSIF (COUNTRY_NAME = 'CH') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_CH(
            X_ACCOUNT_NUMBER,
            X_ACCOUNT_TYPE );

    ELSIF (COUNTRY_NAME = 'GB') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_GB(
            X_ACCOUNT_NUMBER,
            l_value_out);

    ELSIF (COUNTRY_NAME = 'BR') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_BR(
            X_ACCOUNT_NUMBER,
            X_SECONDARY_ACCOUNT_REFERENCE);

    -- added 10/19/04
    ELSIF (COUNTRY_NAME = 'AU') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_AU(
            X_ACCOUNT_NUMBER,
            X_CURRENCY_CODE);

    ELSIF (COUNTRY_NAME = 'IL') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_IL(X_ACCOUNT_NUMBER);

    ELSIF (COUNTRY_NAME = 'NZ') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_NZ(
            X_ACCOUNT_NUMBER,
            X_ACCOUNT_SUFFIX);

    ELSIF (COUNTRY_NAME = 'JP') THEN
        CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_JP(
            X_ACCOUNT_NUMBER,
            X_ACCOUNT_TYPE );

    END IF;  /* country account check */

    -- ER 3973203
    -- Format Electronic Bank Account Num
    -- (CE_BANK_ACCOUNTS.BANK_ACCOUNT_NUM_ELECTRONIC)
    IF l_value_out IS NOT NULL THEN
        NEW_ACCOUNT_NUM :=  l_value_out;
    ELSE
        NEW_ACCOUNT_NUM :=  X_ACCOUNT_NUMBER;
    END IF;

    CE_FORMAT_ELECTRONIC_NUM(
        x_country_name ,
        x_bank_number ,
        x_branch_number ,
        new_account_num ,
        x_cd,
        x_account_suffix,
        x_secondary_account_reference,
        x_account_classification,
        x_electronic_acct_num ,
        p_init_msg_list  ,
        x_msg_count ,
        x_msg_data ,
        x_return_status   );

    -- 9250566 ADDED 6/6 START -------------------------
    l_count_before_custom := Nvl(FND_MSG_PUB.count_msg,0);
    l_usr_valid := fnd_api.g_ret_sts_success;

    -- Call to custom validation routines
    cep_standard.debug('Calling custom validation hooks');
    cep_standard.debug('l_count_before=' ||l_count_before_custom);
    cep_standard.debug('l_value_out='    ||l_value_out);
    CE_CUSTOM_BANK_VALIDATIONS.ce_usr_validate_account(
        Xi_COUNTRY_NAME            => X_COUNTRY_NAME,
        Xi_BANK_NUMBER             => X_BANK_NUMBER,
        Xi_BRANCH_NUMBER           => X_BRANCH_NUMBER,
        Xi_ACCOUNT_NUMBER          => l_value_out,
        Xi_CD                      => X_CD,
        Xi_ACCOUNT_NAME            => X_ACCOUNT_NAME,
        Xi_CURRENCY_CODE           => X_CURRENCY_CODE,
        Xi_ACCOUNT_TYPE            => X_ACCOUNT_TYPE,
        Xi_ACCOUNT_SUFFIX          => X_ACCOUNT_SUFFIX,
        Xi_SECONDARY_ACCT_REF      => X_SECONDARY_ACCOUNT_REFERENCE,
        Xi_ACCT_CLASSIFICATION     => X_ACCOUNT_CLASSIFICATION,
        Xi_BANK_ID                 => X_BANK_ID,
        Xi_BRANCH_ID               => X_BRANCH_ID,
        Xi_ACCOUNT_ID              => X_ACCOUNT_ID,
        Xo_ACCOUNT_NUM_OUT         => l_value_out_custom,
        Xo_RETURN_STATUS           => l_usr_valid
    );

    l_count_after_custom := FND_MSG_PUB.count_msg;
    cep_standard.debug('l_count_after='     ||l_count_after_custom);

    cep_standard.debug('l_value_out_custom='||l_value_out_custom);
    X_VALUE_OUT := NVL(l_value_out_custom,l_value_out);

    -- Check return status
    IF l_usr_valid = fnd_api.g_ret_sts_error
    THEN
       cep_standard.debug('Custom validations done - failure');
       IF l_count_after_custom = 0 THEN
          cep_standard.debug('No custom error message set');
       END IF;
    ELSE
       cep_standard.debug('Custom validations done - success');
       -- remove any unnecessary messages
       WHILE l_count_after_custom > l_count_before_custom
       LOOP
            FND_MSG_PUB.delete_msg(l_count_after_custom);
            l_count_after_custom := l_count_after_custom - 1;
            cep_standard.debug(l_count_after_custom);
        END LOOP;
        cep_standard.debug('After cleanup, count='||FND_MSG_PUB.count_msg);

    END IF;
    -- 9250566 6/6 ADDED END --------------------------

    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    IF x_msg_count > 0 THEN
        x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    cep_standard.debug('CE_VALIDATE_BANKINFO.upd_account_validate - P_COUNT: '|| x_msg_count);
    cep_standard.debug('X_VALUE_OUT: '|| X_VALUE_OUT);
    cep_standard.debug('<<CE_VALIDATE_BANKINFO.upd_account_validate');
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: upd_account_validate ' ||X_COUNTRY_NAME );
    FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
    fnd_message.set_token('PROCEDURE', 'CE_VALIDATE_BANKINFO.upd_account_validate');
    fnd_msg_pub.add;
    RAISE;
END UPD_ACCOUNT_VALIDATE;


END CE_VALIDATE_BANKINFO;

/
