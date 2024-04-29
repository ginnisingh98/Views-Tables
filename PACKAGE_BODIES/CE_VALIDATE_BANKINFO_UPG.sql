--------------------------------------------------------
--  DDL for Package Body CE_VALIDATE_BANKINFO_UPG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_VALIDATE_BANKINFO_UPG" as
/* $Header: cevlbkub.pls 120.4 2005/08/23 21:52:35 lkwan noship $ */


l_DEBUG varchar2(1) := NVL(FND_PROFILE.value('CE_DEBUG'), 'N');
--l_DEBUG varchar2(1) := 'Y';


    -- 8/27/03 use CE_UPG_BANK_REC table

cursor get_bank_num ( Xi_BANK_ID              NUMBER) IS
   select PartyBank.BANK_OR_BRANCH_NUMBER
    From  CE_UPG_BANK_REC   PartyBank
   Where
 	  PartyBank.CE_UPGRADE_ID = Xi_BANK_ID
 	  --PartyBank.source_pk_id = Xi_BANK_ID
     And  PartyBank.BANK_ENTITY_TYPE = 'BANK';

function ce_check_numeric(check_value VARCHAR2,
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

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      COMPARE_BANK_AND_BRANCH_NUM                                      |
|                                                                       |
|  CALLED BY                                                            |
|      CE_VALIDATE_BRANCH_*                                             |
|          - DE, IS, SE, GB                                             |
|                                                                       |
|  DESCRIPTION                                                          |
|      Verify that the value entered for Bank number and Branch number  |
|        fields are the same when both fields are entered for some      |
|        countries                                                      |
 --------------------------------------------------------------------- */


PROCEDURE COMPARE_BANK_AND_BRANCH_NUM(Xi_branch_num IN VARCHAR2,
					Xi_BANK_ID IN NUMBER) AS


 /* 10/19/04 move to top of package
   -- 8/27/03 use CE_UPG_BANK_REC table
cursor get_bank_num is
   select PartyBank.BANK_OR_BRANCH_NUMBER
    From  CE_UPG_BANK_REC   PartyBank
   Where
 	  PartyBank.CE_UPGRADE_ID = Xi_BANK_ID
 	  --PartyBank.source_pk_id = Xi_BANK_ID
     And  PartyBank.BANK_ENTITY_TYPE = 'BANK';
*/

BANK_NUM varchar2(60);
bank_count number;
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.compare_bank_and_branch_num');
	END IF;

   select count(*) into bank_count
    From  CE_UPG_BANK_REC   PartyBank
   Where
 	  PartyBank.CE_UPGRADE_ID = Xi_BANK_ID
 	  --PartyBank.source_pk_id = Xi_BANK_ID
     And  PartyBank.BANK_ENTITY_TYPE = 'BANK';


IF (bank_count = 1) then

       OPEN  get_bank_num(Xi_BANK_ID);
       FETCH get_bank_num INTO bank_num;

    	IF l_DEBUG in ('Y', 'C') THEN
    		cep_standard.debug('fetch BANK_NUM : ' ||BANK_NUM);
    	END IF;

   IF  (BANK_NUM is  null) then
	null;
   ELSIF  (BANK_NUM is not null) then
    BANK_NUM := upper(replace(BANK_NUM,' ',''));

    BANK_NUM := upper(replace(BANK_NUM,'-',''));

	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('new BANK_NUM : ' ||BANK_NUM);
	END IF;


     IF ((nvl(BANK_NUM,Xi_branch_num)  <> Xi_branch_num)) then
 	IF l_DEBUG in ('Y', 'C') THEN
 	  cep_standard.debug('Bank number and branch number does not match' ||
 		 ' CE_BANK_BRANCH_NUM_NOT_MATCHED');
 	END IF;
      	fnd_message.set_name('CE', 'CE_BANK_BRANCH_NUM_NOT_MATCHED');
	fnd_msg_pub.add;

     END IF;

  END IF;

   close get_bank_num;
ELSIF (bank_count > 1) then
      IF l_DEBUG in ('Y', 'C') THEN
      	cep_standard.debug('EXCEPTION: More than one bank match ');
      END IF;
   FND_MESSAGE.set_name('CE', 'CE_MANY_BANKS');
       fnd_msg_pub.add;

ELSIF (bank_count = 0) then
	  IF l_DEBUG in ('Y', 'C') THEN
	  	cep_standard.debug(' CE_BANK_DOES_NOT_EXISTS');
	  END IF;
   fnd_message.set_name ('CE', 'CE_BANK_DOES_NOT_EXISTS');
   fnd_msg_pub.add;


END IF;

/*IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.compare_bank_and_branch_num');
END IF;
*/
EXCEPTION
  WHEN OTHERS THEN
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANKINFO_UPG.COMPARE_BANK_AND_BRANCH_NUM ' );
   END IF;

   FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
   fnd_message.set_token('PROCEDURE', 'CE_VALIDATE_BANKINFO_UPG.compare_bank_and_branch_num');
       fnd_msg_pub.add;
       RAISE;

END COMPARE_BANK_AND_BRANCH_NUM;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      COMPARE_ACCOUNT_NUM_AND_CD                                       |
|                                                                       |
|  CALLED BY                                                            |
|      CE_VALIDATE_CD_*                                                 |
|                                                                       |
|  DESCRIPTION                                                          |
|      Verify that the check digit entered on the account number        |
|        and check digit fields are the same                            |
 --------------------------------------------------------------------- */

FUNCTION COMPARE_ACCOUNT_NUM_AND_CD(Xi_account_num IN VARCHAR2,
					Xi_CD IN NUMBER,
					Xi_CD_length in number,
					Xi_CD_pos_from_right IN Number default 0) RETURN BOOLEAN AS

cd_position number;
acct_cd number;

/**************************/

procedure pass_check is
begin
 IF l_DEBUG in ('Y', 'C') THEN
	null;
 	--cep_standard.debug('COMPARE_ACCOUNT_NUM_AND_CD: ' || 'CD match');
 END IF;
end pass_check;

/**************************/


BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.COMPARE_ACCOUNT_NUM_AND_CD');
END IF;

cd_position := (length(Xi_account_num) - Xi_CD_pos_from_right);
acct_cd := substr(Xi_account_num, cd_position, Xi_CD_length);

 	IF l_DEBUG in ('Y', 'C') THEN
 		cep_standard.debug('cd_position : '||cd_position || ' acct_cd : '||acct_cd ||' Xi_CD : '||Xi_CD );
 	END IF;


 IF ( acct_cd  <> Xi_CD) then
 	IF l_DEBUG in ('Y', 'C') THEN
 		cep_standard.debug('CD does not match '|| 'CE_ACCT_NUM_AND_CD_NOT_MATCHED');
	END IF;
      	fnd_message.set_name('CE', 'CE_ACCT_NUM_AND_CD_NOT_MATCHED');
	fnd_msg_pub.add;
   return false;
 ELSE
   pass_check;
   return true;
 END IF;

/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.COMPARE_ACCOUNT_NUM_AND_CD');
END IF;
*/
END COMPARE_ACCOUNT_NUM_AND_CD;

/* --------------------------------------------------------------------
|  PRIVATE FUNCTION                                                     |
|      CE_VAL_UNIQUE_TAX_PAYER_ID                                       |
|                                                                       |
|  CALLED BY                                                            |
|      CE_VALIDATE_BANK_CO                                              |
|                                                                       |
|  DESCRIPTION                                                          |
|      Unique Tax Payer ID  VALIDATIONS                                 |
|                                                                       |
 --------------------------------------------------------------------- */

  FUNCTION CE_VAL_UNIQUE_TAX_PAYER_ID (p_country_code    IN  VARCHAR2,
                 		       p_taxpayer_id     IN  VARCHAR2
  			   		 ) RETURN VARCHAR2 IS


  CURSOR CHECK_UNIQUE_TAXID_BK IS       -- Banks
    SELECT JGZZ_FISCAL_CODE
    FROM   CE_UPG_BANK_REC	--HZ_PARTIES
    WHERE  JGZZ_FISCAL_CODE = p_taxpayer_id
      AND country     = p_country_code;

  l_taxid        VARCHAR2(30);

  BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.CE_VAL_UNIQUE_TAX_PAYER_ID');
END IF;

       OPEN CHECK_UNIQUE_TAXID_BK;
       FETCH CHECK_UNIQUE_TAXID_BK INTO l_taxid;

       IF (CHECK_UNIQUE_TAXID_BK%NOTFOUND) THEN
          RETURN('TRUE');
       ELSE
          RETURN('FALSE');
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('CE_VAL_UNIQUE_TAX_PAYER_ID false');
  END IF;
       END IF;
       CLOSE CHECK_UNIQUE_TAXID_BK;
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.CE_VAL_UNIQUE_TAX_PAYER_ID');
END IF;
*/
  END CE_VAL_UNIQUE_TAX_PAYER_ID;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_CHECK_CROSS_MODULE_TAX_ID                                     |
|                                                                       |
|  CALLED BY                                                            |
|      CE_VALIDATE_BANK_CO                                              |
|                                                                       |
|  DESCRIPTION                                                          |
|      Unique Tax Payer ID  VALIDATIONS                                 |
|                                                                       |
 --------------------------------------------------------------------- */
  -- Check the cross validation
  -- This procedure  checks in AR, AP and HR to see if the TAX ID entered
  --   for the Bank is used  by a Customer, Supplier or a Company.
  -- If it is used then the Customer name, Supplier name or the Company
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

  PROCEDURE ce_check_cross_module_tax_id(p_country_code     IN  VARCHAR2,
                               p_entity_name      IN  VARCHAR2, --l_bank_name
                               p_taxpayer_id      IN  VARCHAR2,
                               p_return_ar        OUT NOCOPY VARCHAR2,
                               p_return_ap        OUT NOCOPY VARCHAR2,
                               p_return_hr        OUT NOCOPY VARCHAR2,
                               p_return_bk        OUT NOCOPY VARCHAR2) IS

  CURSOR CHECK_CROSS_AP IS    --Suppliers
    SELECT AP.VENDOR_NAME, AP.NUM_1099
    FROM PO_VENDORS AP
    WHERE  (AP.VENDOR_NAME=p_entity_name
    OR  AP.NUM_1099= p_taxpayer_id)
    AND substrb(nvl(AP.GLOBAL_ATTRIBUTE_CATEGORY,'XX.XX'),4,2) = p_country_code;

  CURSOR CHECK_CROSS_AR IS    --Customers
    SELECT AR.PARTY_NAME, AR.JGZZ_FISCAL_CODE
    FROM HZ_PARTIES AR
    WHERE  (AR.PARTY_NAME=p_entity_name
    OR  AR.JGZZ_FISCAL_CODE= p_taxpayer_id)
    AND substrb(nvl(AR.GLOBAL_ATTRIBUTE_CATEGORY,'XX.XX'),4,2) = p_country_code;

  CURSOR CHECK_CROSS_HR IS    --Companies
    SELECT HR.GLOBAL_ATTRIBUTE8, HR.GLOBAL_ATTRIBUTE11
    FROM HR_LOCATIONS HR
    WHERE  (HR.GLOBAL_ATTRIBUTE8= p_entity_name
    OR  HR.GLOBAL_ATTRIBUTE11= p_taxpayer_id)
    AND substrb(nvl(HR.GLOBAL_ATTRIBUTE_CATEGORY,'XX.XX'),4,2) = p_country_code
    AND HR.LOCATION_USE = 'HR';

  l_taxid       VARCHAR2(30);
  l_taxid_type VARCHAR2(150);
  l_entity_name VARCHAR2(80);

  BEGIN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_check_cross_module_tax_id'||
     	' p_taxpayer_id: ' || p_taxpayer_id );
     END IF;

       -- Checking cross module Banks/Customers

       OPEN CHECK_CROSS_AR;
       FETCH CHECK_CROSS_AR INTO l_entity_name, l_taxid;

    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('l_entity_name: ' ||l_entity_name || ' l_taxid: ' ||l_taxid );
    END IF;

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

    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('p_return_ar: ' || p_return_ar );
    END IF;

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

       CLOSE CHECK_CROSS_AP;
       p_return_bk:='NA';

/*
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_check_cross_module_tax_id');
    END IF;
*/
  END ce_check_cross_module_tax_id;
/* --------------------------------------------------------------------
|  PRIVATE FUNCTION                                                     |
|      CE_TAX_ID_CHECK_ALGORITHM                                        |
|                                                                       |
|  CALLED BY                                                            |
|      CE_VALIDATE_BANK_CO                                              |
|                                                                       |
|  DESCRIPTION                                                          |
|      Unique Tax Payer ID  VALIDATIONS                                 |
|                                                                       |
 --------------------------------------------------------------------- */
  -- Taxpayer ID Validation

  FUNCTION ce_tax_id_check_algorithm(p_taxpayer_id  IN VARCHAR2,
                           		p_country   IN VARCHAR2,
                          		p_tax_id_cd IN VARCHAR2
  ) RETURN VARCHAR2 IS
  l_var1      VARCHAR2(20);
  l_val_digit VARCHAR2(2);
  l_mod_value NUMBER(2);
  BEGIN

   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.CE_TAX_ID_CHECK_ALGORITHM '||p_COUNTRY );
   END IF;

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

        IF l_DEBUG in ('Y', 'C') THEN
        	cep_standard.debug('l_mod_value: '|| l_mod_value);
        END IF;

       IF (l_mod_value IN (1,0)) THEN
          l_val_digit:=l_mod_value;
       ELSE
          l_val_digit:=11-l_mod_value;
       END IF;

        IF l_DEBUG in ('Y', 'C') THEN
        	cep_standard.debug('l_val_digit: '|| l_val_digit|| ' p_tax_id_cd: '|| p_tax_id_cd );
        END IF;

       IF l_val_digit<> p_tax_id_cd THEN
        IF l_DEBUG in ('Y', 'C') THEN
        	cep_standard.debug('failed ce_tax_id_check_algorithm' );
        END IF;
          RETURN('FALSE');

       ELSE
          RETURN('TRUE');
       END IF;

    END IF;
/*
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.CE_TAX_ID_CHECK_ALGORITHM');
   END IF;
*/
  END ce_tax_id_check_algorithm;


/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_CD                                                   |
|                                                                       |
|  CALLED BY                                                            |
|      CE_VALIDATE_ACCOUNT				                |
|                                                                       |
|  CALLS                                                                |
|      CE_VALIDATE_CD_*           for each country                      |
 --------------------------------------------------------------------- */


PROCEDURE CE_VALIDATE_CD(X_COUNTRY_NAME    IN varchar2,
			  X_CD	     	   IN  varchar2,
                          X_BANK_NUMBER    IN varchar2,
                          X_BRANCH_NUMBER  IN varchar2,
                          X_ACCOUNT_NUMBER IN varchar2) AS
			  --p_init_msg_list  IN  VARCHAR2 := FND_API.G_FALSE,
    			  --x_msg_count      OUT NOCOPY NUMBER,
			  --x_msg_data       OUT NOCOPY VARCHAR2) AS
                          --X_VALUE_OUT      OUT NOCOPY varchar2) AS

COUNTRY_NAME   VARCHAR2(2);

X_PASS_MAND_CHECK  VARCHAR2(1);

BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_cd X_COUNTRY_NAME: ' ||X_COUNTRY_NAME);
END IF;

COUNTRY_NAME  := X_COUNTRY_NAME;

--X_VALUE_OUT := X_CD;


/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('COUNTRY_NAME: '|| COUNTRY_NAME);
	--'CE_VALIDATE_BANKINFO_UPG.ce_validate_cd - X_VALUE_OUT: '|| X_VALUE_OUT|| '----------' ||
	--'CE_VALIDATE_BANKINFO_UPG.ce_validate_cd - P_INIT_MSG_LIST: '|| P_INIT_MSG_LIST);
END IF;
*/
/* removed 9/2/03
-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
END IF;
*/
/* We must validate the Check Digit*/

IF X_CD is null
         AND (X_BANK_NUMBER is not null
         OR   X_BRANCH_NUMBER is not null
         OR   X_ACCOUNT_NUMBER is not null)
      then

         X_PASS_MAND_CHECK := 'F';

ELSIF X_CD is not null then
    X_PASS_MAND_CHECK := 'P';
ELSE
   X_PASS_MAND_CHECK := ' ';

END IF;

IF (COUNTRY_NAME = 'FR') then

          CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_CD_FR(X_CD,
                      X_PASS_MAND_CHECK,
                      X_BANK_NUMBER,
                      X_BRANCH_NUMBER,
                      translate(X_ACCOUNT_NUMBER,
                        'ABCDEFGHIJKLMNOPQRSTUVWXYZ ',
                        '123456789123456789234567890') );

ELSIF (COUNTRY_NAME = 'ES') then

           CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_CD_ES(X_CD,
                      X_PASS_MAND_CHECK,
                      X_BANK_NUMBER,
                      X_BRANCH_NUMBER,
                      translate(X_ACCOUNT_NUMBER,
                        'ABCDEFGHIJKLMNOPQRSTUVWXYZ ',
                        '123456789123456789234567890') );

 ELSIF (COUNTRY_NAME = 'PT') then

           CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_CD_PT(X_CD,
                      X_PASS_MAND_CHECK,
                      X_BANK_NUMBER,
                      X_BRANCH_NUMBER,
                      translate(X_ACCOUNT_NUMBER,
                        'ABCDEFGHIJKLMNOPQRSTUVWXYZ ',
                        '123456789123456789234567890') );

-- added 5/14/02

 ELSIF (COUNTRY_NAME = 'DE') then

           CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_CD_DE(X_CD,
                      X_ACCOUNT_NUMBER);

 ELSIF (COUNTRY_NAME = 'GR') then

           CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_CD_GR(X_CD,
                      X_PASS_MAND_CHECK,
                      X_BANK_NUMBER,
                      X_BRANCH_NUMBER,
                      translate(X_ACCOUNT_NUMBER,
                        'ABCDEFGHIJKLMNOPQRSTUVWXYZ ',
                        '123456789123456789234567890') );

 ELSIF (COUNTRY_NAME = 'IS') then

           CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_CD_IS(X_CD,
                      translate(X_ACCOUNT_NUMBER,
                        'ABCDEFGHIJKLMNOPQRSTUVWXYZ ',
                        '123456789123456789234567890') );

 ELSIF (COUNTRY_NAME = 'IT') then

           CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_CD_IT(X_CD,
                      X_PASS_MAND_CHECK,
                      X_BANK_NUMBER,
                      X_BRANCH_NUMBER,
                      translate(X_ACCOUNT_NUMBER,
                        'ABCDEFGHIJKLMNOPQRSTUVWXYZ ',
                        '123456789123456789234567890') );

 ELSIF (COUNTRY_NAME = 'LU') then

           CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_CD_LU(X_CD,
                      X_BANK_NUMBER,
                      X_BRANCH_NUMBER,
                      X_ACCOUNT_NUMBER);
                    --  X_VALUE_OUT);

 ELSIF (COUNTRY_NAME = 'SE') then

           CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_CD_SE(X_CD,
                      X_ACCOUNT_NUMBER);


END IF;

/* 9/2/03
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
*/
IF l_DEBUG in ('Y', 'C') THEN
	--cep_standard.debug('CE_VALIDATE_BANKINFO_UPG.ce_validate_cd - P_COUNT: '|| x_msg_count|| '----------' ||
	--'CE_VALIDATE_BANKINFO_UPG.ce_validate_cd - P_DATA: '|| x_msg_data|| '----------' ||
	--'CE_VALIDATE_BANKINFO_UPG.ce_validate_cd - X_VALUE_OUT: '|| X_VALUE_OUT|| '----------' ||
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_cd X_PASS_MAND_CHECK: '|| X_PASS_MAND_CHECK);
END IF;
EXCEPTION
  WHEN OTHERS THEN
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANKINFO_UPG.ce_validate_cd ' ||X_COUNTRY_NAME );
   END IF;

   FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
   fnd_message.set_token('PROCEDURE', 'CE_VALIDATE_BANKINFO_UPG.cd_validate_cd');
       fnd_msg_pub.add;
       RAISE;


END CE_VALIDATE_CD;


/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_BRANCH                                               |
|                                                                       |
|  CALLED BY                                                            |
|      ceupgcpy.sql - Bank pre-upgrade script                           |
|                                                                       |
|  CALLS                                                                |
|      CE_VALIDATE_BRANCH_*           for each country                  |
|      removed CE_VALIDATE_UNIQUE_BRANCH_*    for each country          |
 --------------------------------------------------------------------- */


PROCEDURE CE_VALIDATE_BRANCH(X_COUNTRY_NAME 	IN  varchar2,
                             --X_BANK_NUMBER 	IN  varchar2,
                             X_BRANCH_NUMBER 	IN  varchar2,
                             --X_BANK_NAME 	IN  varchar2,
                             --X_BRANCH_NAME 	IN  varchar2,
                             X_BRANCH_NAME_ALT IN  varchar2,
                             X_BANK_ID 		IN  NUMBER,
                             --X_BRANCH_ID 	IN  NUMBER,
                             X_VALIDATION_TYPE	IN  varchar2 := 'ALL',
			     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
    			     x_msg_count      OUT NOCOPY NUMBER,
			     x_msg_data       OUT NOCOPY VARCHAR2,
                             X_VALUE_OUT      OUT NOCOPY varchar2,
			    x_message_name_all OUT NOCOPY varchar2)
                                      AS

COUNTRY_NAME   VARCHAR2(2);

X_PASS_MAND_CHECK  VARCHAR2(1);

l_msg_data varchar2(2000);
l_msg_index_out number;
l_error varchar2(2000);
l_error_description varchar2(4000);
l_message_name   varchar2(2000);
--x_message_name_all   varchar2(2000);
l_message_name_all_tmp   varchar2(2000);
v_error_description  varchar2(2000);
l_app_short_name varchar2(20);


BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_branch');
END IF;


COUNTRY_NAME  := X_COUNTRY_NAME;

X_VALUE_OUT := X_BRANCH_NUMBER;

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
END IF;

IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('COUNTRY_NAME: '|| COUNTRY_NAME
		|| ' X_VALUE_OUT: '|| X_VALUE_OUT || ' P_INIT_MSG_LIST: '|| P_INIT_MSG_LIST );
END IF;


/* X_COUNTRY_NAME cannot be null, not able to make this required on form, so must do validation here */

IF X_COUNTRY_NAME is null   then
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH: ' || 'CE_COUNTRY_NAME_REQUIRED');
   END IF;
   fnd_message.set_name ('CE', 'CE_COUNTRY_NAME_REQUIRED');
   fnd_msg_pub.add;
END IF;


/* We must validate the Bank Branch Number */

IF X_BRANCH_NUMBER is null   then
        X_PASS_MAND_CHECK := 'F';
ELSE
        X_PASS_MAND_CHECK := 'P';
END IF;

 IF l_DEBUG in ('Y', 'C') THEN
  IF (X_PASS_MAND_CHECK <> 'P') THEN
	cep_standard.debug('X_PASS_MAND_CHECK: '|| X_PASS_MAND_CHECK);
  END IF;
END IF;

-- VALIDATION TYPE: KEY, ALL

IF (COUNTRY_NAME = 'AT')
   THEN
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BRANCH_AT(X_BRANCH_NUMBER,
                      X_PASS_MAND_CHECK,
                      X_VALUE_OUT);

ELSIF (COUNTRY_NAME = 'ES')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BRANCH_ES(X_BRANCH_NUMBER,
                      X_PASS_MAND_CHECK,
                      X_VALUE_OUT);

ELSIF (COUNTRY_NAME = 'FR')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BRANCH_FR(X_BRANCH_NUMBER,
                      X_PASS_MAND_CHECK,
                      X_VALUE_OUT);

ELSIF (COUNTRY_NAME = 'PT')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BRANCH_PT(X_BRANCH_NUMBER,
                      X_PASS_MAND_CHECK);

ELSIF (COUNTRY_NAME = 'BR')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BRANCH_BR(X_BRANCH_NUMBER,
                      X_PASS_MAND_CHECK,
                      X_VALUE_OUT);

-- added 5/14/02

ELSIF (COUNTRY_NAME = 'DE')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BRANCH_DE(X_BRANCH_NUMBER,
                      X_BANK_ID);

ELSIF (COUNTRY_NAME = 'GR')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BRANCH_GR(X_BRANCH_NUMBER);

ELSIF (COUNTRY_NAME = 'IS')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BRANCH_IS(X_BRANCH_NUMBER,
                      X_BANK_ID,
                      X_VALUE_OUT);

ELSIF (COUNTRY_NAME = 'IE')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BRANCH_IE(X_BRANCH_NUMBER,
                      X_BANK_ID);

ELSIF (COUNTRY_NAME = 'IT')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BRANCH_IT(X_BRANCH_NUMBER,
                      X_PASS_MAND_CHECK);

ELSIF (COUNTRY_NAME = 'LU')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BRANCH_LU(X_BRANCH_NUMBER,
                      X_BANK_ID);

ELSIF (COUNTRY_NAME = 'PL')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BRANCH_PL(X_BRANCH_NUMBER,
                      X_BANK_ID);

ELSIF (COUNTRY_NAME = 'SE')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BRANCH_SE(X_BRANCH_NUMBER,
                      X_BANK_ID);

ELSIF (COUNTRY_NAME = 'CH')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BRANCH_CH(X_BRANCH_NUMBER,
                      X_BANK_ID);

ELSIF (COUNTRY_NAME = 'GB')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BRANCH_GB(X_BRANCH_NUMBER,
                      X_BANK_ID);

ELSIF (COUNTRY_NAME = 'US')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BRANCH_US(X_BRANCH_NUMBER,
                      X_PASS_MAND_CHECK,
                      X_VALUE_OUT);
-- added 10/19/04

ELSIF (COUNTRY_NAME = 'AU')
       then
                CE_VALIDATE_BRANCH_AU(X_BRANCH_NUMBER,
                      X_BANK_ID,
                      X_PASS_MAND_CHECK);
ELSIF (COUNTRY_NAME = 'IL')
       then
                CE_VALIDATE_BRANCH_IL(X_BRANCH_NUMBER,
                      X_PASS_MAND_CHECK);
ELSIF (COUNTRY_NAME = 'NZ')
       then
                CE_VALIDATE_BRANCH_NZ(X_BRANCH_NUMBER,
                      X_PASS_MAND_CHECK);

ELSIF (COUNTRY_NAME = 'JP')
       then
                CE_VALIDATE_BRANCH_JP(X_BRANCH_NUMBER,
			X_BRANCH_NAME_ALT,
                      X_PASS_MAND_CHECK,
			X_VALIDATION_TYPE );

END IF;


/**   UNIQUE VALIDATION CHECK for branch   **/
-- NO UNIQUE VALIDATION CHECK
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('UNIQUE VALIDATION CHECK for branch' );
END IF;

IF (COUNTRY_NAME = 'DE')   THEN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('call CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_UNIQUE_BRANCH_DE' );
END IF;

   CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_UNIQUE_BRANCH_DE(X_BRANCH_NUMBER,
                                       X_BRANCH_NAME,
                                       X_BANK_ID,
				       X_BRANCH_ID);

ELSIF (COUNTRY_NAME = 'US') THEN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('CE_VALIDATE_BRANCH: ' || 'call CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_UNIQUE_BRANCH_US' );
END IF;

   CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_UNIQUE_BRANCH_US(X_BRANCH_NUMBER,
                                       X_BRANCH_NAME,
                                       X_BANK_ID,
				       X_BRANCH_ID);

ELSIF (COUNTRY_NAME = 'JP') THEN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('call CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_UNIQUE_BRANCH_JP' );
END IF;

   CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_UNIQUE_BRANCH_JP(X_COUNTRY_NAME,
				       X_BRANCH_NUMBER,
                                       X_BRANCH_NAME,
                                       X_BRANCH_NAME_ALT,
                                       X_BANK_ID,
				       X_BRANCH_ID);
ELSE
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('call CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_UNIQUE_BRANCH' );
END IF;
   CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_UNIQUE_BRANCH(X_COUNTRY_NAME,
                                       X_BRANCH_NUMBER,
                                       X_BRANCH_NAME,
                                       X_BANK_ID,
				       X_BRANCH_ID);


END IF;

*/
 /**  end country unique check for branch   **/

	  --cep_standard.debug('call FND_MSG_PUB.Count_And_Get');
	  --cep_standard.debug('x_msg_count= '|| x_msg_count);
	  --cep_standard.debug('x_msg_data= '|| x_msg_data);

    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

	  --cep_standard.debug('call FND_MSG_PUB.Count_Msg');

        FOR j in  1..FND_MSG_PUB.Count_Msg LOOP
          FND_MSG_PUB.Get(
               p_msg_index=>j,
               p_encoded=>'T',
               p_data=>x_msg_data,
               p_msg_index_out=>l_msg_index_out);
          v_error_description := l_error_description || ':' || x_msg_data;

	  FND_MESSAGE.PARSE_ENCODED(x_msg_data,l_app_short_name,l_message_name);

 	  --cep_standard.debug('l_message_name: '|| l_message_name );
	  l_message_name_all_tmp:=(l_message_name_all_tmp ||','|| l_message_name);

        END LOOP;
 	  x_message_name_all:=substr(l_message_name_all_tmp,2);
	  cep_standard.debug('x_message_name_all: '|| x_message_name_all );


IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<BRANCH: X_PASS_MAND_CHECK: '|| X_PASS_MAND_CHECK ||' P_COUNT: '
				|| x_msg_count ||' X_VALUE_OUT: '|| X_VALUE_OUT );
	--cep_standard.debug('P_DATA: '|| x_msg_data );
	--cep_standard.debug('CE_VALIDATE_BRANCH: ' || 'CE_VALIDATE_BANKINFO_UPG.ce_validate_branch - X_VALUE_OUT: '|| X_VALUE_OUT);
	--cep_standard.debug('CE_VALIDATE_BRANCH: ' || '<<CE_VALIDATE_BANKINFO_UPG.ce_validate_branch');
END IF;
EXCEPTION
  WHEN OTHERS THEN
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH: ' || 'CE_VALIDATE_BANKINFO_UPG.ce_validate_branch ' ||X_COUNTRY_NAME );
   END IF;

   FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
   fnd_message.set_token('PROCEDURE', 'CE_VALIDATE_BANKINFO_UPG.cd_validate_branch');
       fnd_msg_pub.add;
       RAISE;

END CE_VALIDATE_BRANCH;


/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_ACCOUNT                                              |
|                                                                       |
|  CALLED BY                                                            |
|      ceupgcpy.sql - Bank pre-upgrade script                           |
|                                                                       |
|  CALLS                                                                |
|      CE_VALIDATE_ACCOUNT_*           for each country                 |
|      removed CE_VALIDATE_UNIQUE_ACCOUNT_*    for each country         |
 --------------------------------------------------------------------- */


PROCEDURE CE_VALIDATE_ACCOUNT(X_COUNTRY_NAME 	IN varchar2,
                              X_BANK_NUMBER 	IN varchar2,
                              X_BRANCH_NUMBER 	IN varchar2,
                              X_ACCOUNT_NUMBER 	IN varchar2,
                              --X_BANK_ID 	IN number,
                              --X_BRANCH_ID 	IN number,
                              --X_ACCOUNT_ID 	IN number,
                              --X_CURRENCY_CODE IN varchar2,
                              X_ACCOUNT_TYPE 	IN varchar2,
                              X_ACCOUNT_SUFFIX  IN varchar2,
                              X_SECONDARY_ACCOUNT_REFERENCE  IN varchar2,
                              X_ACCOUNT_NAME 	IN varchar2,
                              X_CD	 	IN varchar2,
                              X_VALIDATION_TYPE	IN  varchar2 := 'ALL',
			      p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE,
    			      x_msg_count      OUT NOCOPY NUMBER,
			      x_msg_data       OUT NOCOPY VARCHAR2,
		              X_VALUE_OUT      OUT NOCOPY varchar2,
			      x_message_name_all OUT NOCOPY varchar2)
                                      AS

COUNTRY_NAME   VARCHAR2(2);

X_PASS_MAND_CHECK  VARCHAR2(1);
l_msg_data varchar2(2000);
l_msg_index_out number;
l_error varchar2(2000);
l_error_description varchar2(4000);
l_message_name   varchar2(2000);
--x_message_name_all   varchar2(2000);
l_message_name_all_tmp   varchar2(2000);
v_error_description  varchar2(2000);
l_app_short_name varchar2(20);


BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_account');
END IF;

COUNTRY_NAME  := X_COUNTRY_NAME;
X_VALUE_OUT := X_ACCOUNT_NUMBER;

-- Initialize message list if p_init_msg_list is set to TRUE.

IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
END IF;

IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('COUNTRY_NAME: '|| COUNTRY_NAME
		||' X_VALUE_OUT: '|| X_VALUE_OUT || ' P_INIT_MSG_LIST: '|| P_INIT_MSG_LIST);
END IF;


/* X_COUNTRY_NAME cannot be null, not able to make this required on form, so must do validation here */

IF X_COUNTRY_NAME is null   then
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_ACCOUNT: ' || 'CE_COUNTRY_NAME_REQUIRED');
   END IF;
   fnd_message.set_name ('CE', 'CE_COUNTRY_NAME_REQUIRED');
   fnd_msg_pub.add;
END IF;


/* We must validate the Bank Account Number */

IF X_ACCOUNT_NUMBER is null   then
        X_PASS_MAND_CHECK := 'F';
ELSE
        X_PASS_MAND_CHECK := 'P';
END IF;

-- VALIDATION TYPE: KEY, ALL

IF (COUNTRY_NAME = 'AT')
	then
 		CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_ACCOUNT_AT(X_ACCOUNT_NUMBER,
                      X_PASS_MAND_CHECK,
                      X_VALUE_OUT);

ELSIF (COUNTRY_NAME = 'DK')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_ACCOUNT_DK(X_ACCOUNT_NUMBER,
                      X_PASS_MAND_CHECK,
                      X_VALUE_OUT);

ELSIF (COUNTRY_NAME = 'NO')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_ACCOUNT_NO(X_ACCOUNT_NUMBER,
                      X_PASS_MAND_CHECK);

ELSIF (COUNTRY_NAME = 'ES')
       then

                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_ACCOUNT_ES(X_ACCOUNT_NUMBER,
                      X_PASS_MAND_CHECK,
                      X_VALUE_OUT);


ELSIF (COUNTRY_NAME = 'NL')
       then

                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_ACCOUNT_NL(X_ACCOUNT_NUMBER,
                      X_PASS_MAND_CHECK);

ELSIF (COUNTRY_NAME = 'FR')
       then

          CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_ACCOUNT_FR(X_ACCOUNT_NUMBER,
                      X_PASS_MAND_CHECK,
                      X_VALUE_OUT);


ELSIF (COUNTRY_NAME = 'BE')
       then

          CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_ACCOUNT_BE(X_ACCOUNT_NUMBER,
                      X_PASS_MAND_CHECK);


ELSIF (COUNTRY_NAME = 'PT')
       then

          CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_ACCOUNT_PT(X_ACCOUNT_NUMBER,
                      X_PASS_MAND_CHECK,
                      X_VALUE_OUT);

ELSIF (COUNTRY_NAME = 'FI')
	  AND (X_BRANCH_NUMBER='LMP')
       then

          CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_ACCOUNT_FI(X_ACCOUNT_NUMBER,
                      X_PASS_MAND_CHECK);

-- added 5/14/02

ELSIF (COUNTRY_NAME = 'DE')
       then

          CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_ACCOUNT_DE(X_ACCOUNT_NUMBER,
                                      X_VALUE_OUT );

ELSIF (COUNTRY_NAME = 'GR')
       then

          CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_ACCOUNT_GR(X_ACCOUNT_NUMBER,
                      X_VALUE_OUT);

ELSIF (COUNTRY_NAME = 'IS')
       then

          CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_ACCOUNT_IS(X_ACCOUNT_NUMBER,
                                      X_VALUE_OUT );


ELSIF (COUNTRY_NAME = 'IE')
       then

          CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_ACCOUNT_IE(X_ACCOUNT_NUMBER);

ELSIF (COUNTRY_NAME = 'IT')
       then
 IF l_DEBUG in ('Y', 'C') THEN
 	cep_standard.debug('X_ACCOUNT_NUMBER : '|| X_ACCOUNT_NUMBER||
 		' X_VALUE_OUT : '||  X_VALUE_OUT);
 END IF;

          CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_ACCOUNT_IT(X_ACCOUNT_NUMBER,
                      X_VALUE_OUT);

ELSIF (COUNTRY_NAME = 'LU')
       then

          CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_ACCOUNT_LU(X_ACCOUNT_NUMBER);


ELSIF (COUNTRY_NAME = 'PL')
       then

          CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_ACCOUNT_PL(X_ACCOUNT_NUMBER);


ELSIF (COUNTRY_NAME = 'SE')
       then

          CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_ACCOUNT_SE(X_ACCOUNT_NUMBER);


ELSIF (COUNTRY_NAME = 'CH')
       then

          CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_ACCOUNT_CH(X_ACCOUNT_NUMBER,
      					X_ACCOUNT_TYPE,
					X_VALIDATION_TYPE );

ELSIF (COUNTRY_NAME = 'GB')
       then

          CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_ACCOUNT_GB(X_ACCOUNT_NUMBER,
                      X_VALUE_OUT);

-- added 10/19/04
ELSIF (COUNTRY_NAME = 'AU')
       then

   		CE_VALIDATE_ACCOUNT_AU(X_ACCOUNT_NUMBER);


ELSIF (COUNTRY_NAME = 'IL')
       then
	 	CE_VALIDATE_ACCOUNT_IL(X_ACCOUNT_NUMBER);

ELSIF (COUNTRY_NAME = 'NZ')
       then

                CE_VALIDATE_ACCOUNT_NZ(X_ACCOUNT_NUMBER,
                                      X_ACCOUNT_SUFFIX,
				   	X_VALIDATION_TYPE);
ELSIF (COUNTRY_NAME = 'JP')
       then
                CE_VALIDATE_ACCOUNT_JP(X_ACCOUNT_NUMBER,
					X_ACCOUNT_TYPE,
					X_VALIDATION_TYPE );

END IF;  /** country account check       **/


IF (X_VALIDATION_TYPE = 'ALL') THEN

  IF (COUNTRY_NAME = 'BR')
       then

          CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_ACCOUNT_BR(X_ACCOUNT_NUMBER,
                       X_SECONDARY_ACCOUNT_REFERENCE);
  END IF;

END IF;

IF (X_VALIDATION_TYPE in ('KEY', 'ALL')) THEN

  CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_CD(X_COUNTRY_NAME,
			  X_CD	     	  ,
                          X_BANK_NUMBER   ,
                          X_BRANCH_NUMBER ,
                          X_ACCOUNT_NUMBER);
END IF;


/**   UNIQUE VALIDATION CHECK for account   **/

-- NO UNIQUE VALIDATION CHECK

/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('UNIQUE_VALIDATION CHECK for account');
END IF;

IF (COUNTRY_NAME = 'JP')   THEN
   CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_UNIQUE_ACCOUNT_JP(X_ACCOUNT_NUMBER,
                                      X_CURRENCY_CODE,
                                      X_ACCOUNT_TYPE,
                                      X_ACCOUNT_NAME,
                                      X_BRANCH_ID,
                                      X_ACCOUNT_ID);

ELSIF (COUNTRY_NAME = 'NZ')   THEN
   CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_UNIQUE_ACCOUNT_NZ(X_ACCOUNT_NUMBER,
                                      X_CURRENCY_CODE,
                                      X_ACCOUNT_SUFFIX,
                                      X_ACCOUNT_NAME,
                                      X_BRANCH_ID,
                                      X_ACCOUNT_ID);
ELSE
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('call CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_UNIQUE_ACCOUNT' );
END IF;
   CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_UNIQUE_ACCOUNT(
				      X_ACCOUNT_NUMBER,
                                      X_CURRENCY_CODE,
                                      X_ACCOUNT_NAME,
                                      X_BRANCH_ID,
                                      X_ACCOUNT_ID);

END IF;
*/

    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

        FOR j in  1..FND_MSG_PUB.Count_Msg LOOP
          FND_MSG_PUB.Get(
               p_msg_index=>j,
               p_encoded=>'T',
               p_data=>x_msg_data,
               p_msg_index_out=>l_msg_index_out);
          v_error_description := l_error_description || ':' || x_msg_data;

	  FND_MESSAGE.PARSE_ENCODED(x_msg_data,l_app_short_name,l_message_name);

 	  --cep_standard.debug('l_message_name: '|| l_message_name );
	  l_message_name_all_tmp:=(l_message_name_all_tmp ||','|| l_message_name);

        END LOOP;
 	  x_message_name_all:=substr(l_message_name_all_tmp,2);
	  cep_standard.debug('x_message_name_all: '|| x_message_name_all );


IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<ACCOUNT: X_PASS_MAND_CHECK: '|| X_PASS_MAND_CHECK ||
				' P_COUNT: '|| x_msg_count || ' X_VALUE_OUT: '|| X_VALUE_OUT);
	--cep_standard.debug('P_DATA: '|| x_msg_data );
	--cep_standard.debug('CE_VALIDATE_ACCOUNT: ' || 'CE_VALIDATE_BANKINFO_UPG.ce_validate_account - X_VALUE_OUT: '|| X_VALUE_OUT);
	--cep_standard.debug('CE_VALIDATE_ACCOUNT: ' || '<<CE_VALIDATE_BANKINFO_UPG.ce_validate_account');
END IF;
EXCEPTION
  WHEN OTHERS THEN

   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_ACCOUNT: ' || 'CE_VALIDATE_BANKINFO_UPG.ce_validate_account ' ||X_COUNTRY_NAME );
   END IF;
   FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
   fnd_message.set_token('PROCEDURE', 'CE_VALIDATE_BANKINFO_UPG.cd_validate_account');
       fnd_msg_pub.add;
       RAISE;

END CE_VALIDATE_ACCOUNT;

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_BANK                                                 |
|                                                                       |
|  CALLED BY                                                            |
|      ceupgcpy.sql - Bank pre-upgrade script                           |
|                                                                       |
|  CALLS                                                                |
|      CE_VALIDATE_BANK_*           for each country                    |
|      removed CE_VALIDATE_UNIQUE_BANK_*    for each country            |
 --------------------------------------------------------------------- */


PROCEDURE CE_VALIDATE_BANK( X_COUNTRY_NAME    IN varchar2,
                            X_BANK_NUMBER     IN varchar2,
                            X_BANK_NAME       IN varchar2,
                            X_BANK_NAME_ALT   IN varchar2,
                            X_TAX_PAYER_ID    IN varchar2,
                            --X_BANK_ID 	      IN NUMBER,
                            X_VALIDATION_TYPE	IN  varchar2 := 'ALL',
			    p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE,
    			    x_msg_count      OUT NOCOPY NUMBER,
			    x_msg_data       OUT NOCOPY VARCHAR2,
	                    X_VALUE_OUT      OUT NOCOPY varchar2,
			    x_message_name_all OUT NOCOPY varchar2 )  AS

COUNTRY_NAME   VARCHAR2(2);

X_PASS_MAND_CHECK  VARCHAR2(1);

l_msg_data varchar2(2000);
l_msg_index_out number;
l_error varchar2(2000);
l_error_description varchar2(4000);
l_message_name   varchar2(2000);
--x_message_name_all   varchar2(2000);
l_message_name_all_tmp   varchar2(2000);
v_error_description  varchar2(2000);
l_app_short_name varchar2(20);

BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_bank');
END IF;

COUNTRY_NAME  := X_COUNTRY_NAME;
X_VALUE_OUT := X_BANK_NUMBER;

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
END IF;

IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('COUNTRY_NAME: '|| COUNTRY_NAME||
	' X_VALUE_OUT: '|| X_VALUE_OUT || ' P_INIT_MSG_LIST: '|| P_INIT_MSG_LIST);
END IF;

/* X_COUNTRY_NAME cannot be null, not able to make this required on form, so must do validation here */

IF X_COUNTRY_NAME is null   then
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK: ' || 'CE_COUNTRY_NAME_REQUIRED');
   END IF;
   fnd_message.set_name ('CE', 'CE_COUNTRY_NAME_REQUIRED');
   fnd_msg_pub.add;
END IF;

/* We must validate the Bank Number */

IF X_BANK_NUMBER is null   then
        X_PASS_MAND_CHECK := 'F';
ELSE
        X_PASS_MAND_CHECK := 'P';
END IF;

-- VALIDATION TYPE: KEY, ALL

IF (COUNTRY_NAME = 'ES')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BANK_ES(X_BANK_NUMBER,
                      X_PASS_MAND_CHECK,
                      X_VALUE_OUT);

ELSIF (COUNTRY_NAME = 'FR')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BANK_FR(X_BANK_NUMBER,
                      X_PASS_MAND_CHECK,
                      X_VALUE_OUT);

ELSIF (COUNTRY_NAME = 'PT')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BANK_PT(X_BANK_NUMBER,
                      X_PASS_MAND_CHECK);

ELSIF (COUNTRY_NAME = 'BR')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BANK_BR(X_BANK_NUMBER,
                      X_PASS_MAND_CHECK,
                      X_VALUE_OUT);

-- Added 5/14/02


ELSIF (COUNTRY_NAME = 'DE')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BANK_DE(X_BANK_NUMBER);

ELSIF (COUNTRY_NAME = 'GR')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BANK_GR(X_BANK_NUMBER);

ELSIF (COUNTRY_NAME = 'IS')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BANK_IS(X_BANK_NUMBER,
                      X_VALUE_OUT);

ELSIF (COUNTRY_NAME = 'IE')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BANK_IE(X_BANK_NUMBER);

ELSIF (COUNTRY_NAME = 'IT')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BANK_IT(X_BANK_NUMBER,
                      X_PASS_MAND_CHECK);

ELSIF (COUNTRY_NAME = 'LU')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BANK_LU(X_BANK_NUMBER);


ELSIF (COUNTRY_NAME = 'PL')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BANK_PL(X_BANK_NUMBER);

ELSIF (COUNTRY_NAME = 'SE')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BANK_SE(X_BANK_NUMBER);

ELSIF (COUNTRY_NAME = 'CH')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BANK_CH(X_BANK_NUMBER);

ELSIF (COUNTRY_NAME = 'GB')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BANK_GB(X_BANK_NUMBER);

-- Added 10/19/04

ELSIF (COUNTRY_NAME = 'AU')
       then
		CE_VALIDATE_BANK_AU(X_BANK_NUMBER);
		--CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_AU(X_BANK_NUMBER);
ELSIF (COUNTRY_NAME = 'IL')
       then
		CE_VALIDATE_BANK_IL(X_BANK_NUMBER,
                      X_PASS_MAND_CHECK);
ELSIF (COUNTRY_NAME = 'NZ')
       then
		CE_VALIDATE_BANK_NZ(X_BANK_NUMBER,
                      X_PASS_MAND_CHECK);

ELSIF (COUNTRY_NAME = 'JP')
       then
		CE_VALIDATE_BANK_JP(X_BANK_NUMBER,
                      X_BANK_NAME_ALT,
                      X_PASS_MAND_CHECK,
			X_VALIDATION_TYPE);


END IF;  /** country check for bank   **/


IF (X_VALIDATION_TYPE = 'ALL') THEN
  IF (COUNTRY_NAME = 'CO')
       then
                CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BANK_CO(X_COUNTRY_NAME,
			X_BANK_NAME ,
                        X_TAX_PAYER_ID);
  END IF;
END IF;





/**   UNIQUE VALIDATION CHECK for bank   **/
-- NO UNIQUE VALIDATION CHECK
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('UNIQUE VALIDATION CHECK for bank' );
END IF;

IF (COUNTRY_NAME = 'JP') THEN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('call CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_UNIQUE_BANK_JP' );
  END IF;

  CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_UNIQUE_BANK_JP(X_COUNTRY_NAME,
				       X_BANK_NUMBER ,
                                       X_BANK_NAME ,
                                       X_BANK_NAME_ALT,
                                       X_BANK_ID);

END IF;
*/
  /**   country unique check for bank   **/


    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

        FOR j in  1..FND_MSG_PUB.Count_Msg LOOP
          FND_MSG_PUB.Get(
               p_msg_index=>j,
               p_encoded=>'T',
               p_data=>x_msg_data,
               p_msg_index_out=>l_msg_index_out);
          v_error_description := l_error_description || ':' || x_msg_data;

	  FND_MESSAGE.PARSE_ENCODED(x_msg_data,l_app_short_name,l_message_name);

 	  --cep_standard.debug('l_message_name: '|| l_message_name );
	  l_message_name_all_tmp:=(l_message_name_all_tmp ||','|| l_message_name);

        END LOOP;
 	  x_message_name_all:=substr(l_message_name_all_tmp,2);
	  cep_standard.debug('x_message_name_all: '|| x_message_name_all );

IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<BANK: X_PASS_MAND_CHECK: '|| X_PASS_MAND_CHECK
				||' P_COUNT: '|| x_msg_count || ' X_VALUE_OUT: '|| X_VALUE_OUT  );
	--cep_standard.debug('P_DATA: '|| x_msg_data );
	--cep_standard.debug('CE_VALIDATE_BANK: ' || 'CE_VALIDATE_BANKINFO_UPG.ce_validate_bank - X_VALUE_OUT: '|| X_VALUE_OUT );
	--cep_standard.debug('CE_VALIDATE_BANK: ' || '<<CE_VALIDATE_BANKINFO_UPG.ce_validate_bank');
END IF;
EXCEPTION
  WHEN OTHERS THEN
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK: ' || 'CE_VALIDATE_BANKINFO_UPG.ce_validate_bank ' ||X_COUNTRY_NAME );
   END IF;

   FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
   fnd_message.set_token('PROCEDURE', 'CE_VALIDATE_BANKINFO_UPG.cd_validate_bank');
       fnd_msg_pub.add;
       RAISE;


END CE_VALIDATE_BANK;


/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_CD_*                                                 |
|                                                                       |
|  CALLED BY                                                            |
|      CE_VALIDATE_CD                                                   |
|                                                                       |
|  DESCRIPTION                                                          |
|      Check Digit PROCEDURES, Validations 1 or more of the following:  |
|      1. Check Digit length                                            |
|      2. Check Digit Algorithm                                         |
|                                               |
 --------------------------------------------------------------------- */


procedure CE_VALIDATE_CD_PT(Xi_CD in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2,
                                      Xi_X_BANK_NUMBER in varchar2,
                                      Xi_X_BRANCH_NUMBER in varchar2,
                                      Xi_X_ACCOUNT_NUMBER in varchar2)
                                      AS
numeric_result_bk varchar2(40);
numeric_result_br varchar2(40);
numeric_result_cd varchar2(40);
numeric_result_ac varchar2(40);
cal_cd     number(10);
CONCED_NUMBER varchar2(30);
cd_value varchar2(20);
bk_value varchar2(30);
ac_value varchar2(30);
br_value varchar2(30);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_mandatory is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_CHECK_DIGIT');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_CD: ' || 'CE_ENTER_CHECK_DIGIT');
   END IF;
end fail_mandatory;

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_CHECK_DIGIT');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_CD: ' || 'CE_INVALID_CHECK_DIGIT');
   END IF;
end fail_check;

procedure pass_check is
begin
 IF l_DEBUG in ('Y', 'C') THEN
 	null;
 	--cep_standard.debug('CE_VALIDATE_CD: ' || 'pass_check');
 END IF;
end pass_check;
                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_cd_pt');
END IF;

CD_VALUE := upper(replace(Xi_CD,' ',''));
bk_value := upper(replace(Xi_X_BANK_NUMBER,' ',''));
br_value := upper(replace(Xi_X_BRANCH_NUMBER,' ',''));
ac_value := upper(replace(Xi_X_ACCOUNT_NUMBER,' ',''));

IF Xi_PASS_MAND_CHECK = 'F'
  then
    fail_mandatory;

ELSIF Xi_PASS_MAND_CHECK = 'P'
  then

      numeric_result_bk := ce_check_numeric(bk_value,1,length(bk_value));
      numeric_result_br := ce_check_numeric(br_value,1,length(br_value));
      numeric_result_ac := ce_check_numeric(ac_value,1,length(ac_value));
      numeric_result_cd := ce_check_numeric(CD_VALUE,1,length(CD_VALUE));

  IF length(bk_value) = 4 and length(br_value) = 4 and length(ac_value) = 11
     and length(CD_VALUE) = 2
    then

    IF numeric_result_bk = '0' and numeric_result_br = '0'
       and numeric_result_ac = '0' and numeric_result_cd = '0'
       then
             /* its numeric so continue  */

       CONCED_NUMBER := bk_value||br_value||ac_value||CD_VALUE;

       cal_cd := 98 - mod(( (to_number(substr(CONCED_NUMBER,19,1)) * 3)
                 +(to_number(substr(CONCED_NUMBER,18,1)) * 30)
                 +(to_number(substr(CONCED_NUMBER,17,1)) * 9)
                 +(to_number(substr(CONCED_NUMBER,16,1)) * 90)
                 +(to_number(substr(CONCED_NUMBER,15,1)) * 27)
                 +(to_number(substr(CONCED_NUMBER,14,1)) * 76)
                 +(to_number(substr(CONCED_NUMBER,13,1)) * 81)
                 +(to_number(substr(CONCED_NUMBER,12,1)) * 34)
                 +(to_number(substr(CONCED_NUMBER,11,1)) * 49)
                 +(to_number(substr(CONCED_NUMBER,10,1)) * 5)
                 +(to_number(substr(CONCED_NUMBER,9,1)) * 50)
                 +(to_number(substr(CONCED_NUMBER,8,1)) * 15)
                 +(to_number(substr(CONCED_NUMBER,7,1)) * 53)
                 +(to_number(substr(CONCED_NUMBER,6,1)) * 45)
                 +(to_number(substr(CONCED_NUMBER,5,1)) * 62)
                 +(to_number(substr(CONCED_NUMBER,4,1)) * 38)
                 +(to_number(substr(CONCED_NUMBER,3,1)) * 89)
                 +(to_number(substr(CONCED_NUMBER,2,1)) * 17)
                 +(to_number(substr(CONCED_NUMBER,1,1)) * 73)),97);


   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('cal_cd: ' || cal_cd);
   END IF;

       IF CD_VALUE = cal_cd
          then
                pass_check;
       ELSE
              fail_check;
       END IF;

    ELSE
       fail_check;

    END IF;  /* end of numeric check */

  ELSE
     fail_check;

  END IF;  /* end of length check  */
END IF; /* end of mandatory check  */

/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_cd_pt');
END IF;
*/
END CE_VALIDATE_CD_PT;

/****************     End of Procedure CE_VALIDATE_CD_PT   ***********/

procedure CE_VALIDATE_CD_ES(Xi_CD in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2,
                                      Xi_X_BANK_NUMBER in varchar2,
                                      Xi_X_BRANCH_NUMBER in varchar2,
                                      Xi_X_ACCOUNT_NUMBER in varchar2)
                                      AS
numeric_result_bk varchar2(40);
numeric_result_br varchar2(40);
numeric_result_cd varchar2(40);
numeric_result_ac varchar2(40);
cd_1       number(10);
cd_2       number(10);
cd_value varchar2(20);
bk_value varchar2(30);
ac_value varchar2(30);
br_value varchar2(30);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/
/*Bug Fix:880887*/
/*Changed the Xo_RET_VAR='F' to 'W' ,in 'fail_mandatory' and 'fail_check'*/
/*so that a warning message is displayed*/
/*for spain instead of Error message*/

procedure fail_mandatory is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_CHECK_DIGIT');
   fnd_msg_pub.add;
   fnd_msg_pub.add_detail(fnd_msg_pub.g_warning_msg);
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_CD: ' || 'CE_ENTER_CHECK_DIGIT');
   END IF;

end fail_mandatory;

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_CHECK_DIGIT');
   fnd_msg_pub.add;
   fnd_msg_pub.add_detail(fnd_msg_pub.g_warning_msg);
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_CD: ' || 'CE_INVALID_CHECK_DIGIT');
   END IF;

end fail_check;

procedure pass_check is
begin
 IF l_DEBUG in ('Y', 'C') THEN
 	null;
 	--cep_standard.debug('CE_VALIDATE_CD: ' || 'pass_check');
 END IF;

end pass_check;
                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_cd_es');
END IF;

CD_VALUE := upper(Xi_CD);
bk_value := upper(Xi_X_BANK_NUMBER);
br_value := upper(Xi_X_BRANCH_NUMBER);
ac_value := upper(Xi_X_ACCOUNT_NUMBER);

IF Xi_PASS_MAND_CHECK = 'F'
  then
    fail_mandatory;

ELSIF Xi_PASS_MAND_CHECK = 'P'
  then

      numeric_result_bk := ce_check_numeric(bk_value,1,length(bk_value));
      numeric_result_br := ce_check_numeric(br_value,1,length(br_value));
      numeric_result_ac := ce_check_numeric(ac_value,1,length(ac_value));
      numeric_result_cd := ce_check_numeric(CD_VALUE,1,length(CD_VALUE));

    IF numeric_result_bk = '0' and numeric_result_br = '0'
       and numeric_result_ac = '0' and numeric_result_cd = '0'
       then
             /* its numeric so continue  */
       cd_1  := 11-mod(((to_number(substr(Xi_X_BANK_NUMBER,1,1)) * 4)
          + (to_number(substr(Xi_X_BANK_NUMBER,2,1)) * 8)
          + (to_number(substr(Xi_X_BANK_NUMBER,3,1)) * 5)
          + (to_number(substr(Xi_X_BANK_NUMBER,4,1)) * 10)
          + (to_number(substr(Xi_X_BRANCH_NUMBER,1,1)) * 9)
          + (to_number(substr(Xi_X_BRANCH_NUMBER,2,1)) * 7)
          + (to_number(substr(Xi_X_BRANCH_NUMBER,3,1)) * 3)
          + (to_number(substr(Xi_X_BRANCH_NUMBER,4,1)) * 6)),11);


       cd_2  := 11-mod(((to_number(substr(Xi_X_ACCOUNT_NUMBER,1,1)) * 1)
               + (to_number(substr(Xi_X_ACCOUNT_NUMBER,2,1)) * 2)
               + (to_number(substr(Xi_X_ACCOUNT_NUMBER,3,1)) * 4)
               + (to_number(substr(Xi_X_ACCOUNT_NUMBER,4,1)) * 8)
               + (to_number(substr(Xi_X_ACCOUNT_NUMBER,5,1)) * 5)
               + (to_number(substr(Xi_X_ACCOUNT_NUMBER,6,1)) * 10)
               + (to_number(substr(Xi_X_ACCOUNT_NUMBER,7,1)) * 9)
               + (to_number(substr(Xi_X_ACCOUNT_NUMBER,8,1)) * 7)
               + (to_number(substr(Xi_X_ACCOUNT_NUMBER,9,1)) * 3)
               + (to_number(substr(Xi_X_ACCOUNT_NUMBER,10,1)) * 6)),11);


       IF (cd_1 = 10)
          then
             cd_1 :=1;
       ELSIF (cd_1 = 11)
          then
             cd_1 := 0;
       END IF;

       IF (cd_2 = 10)
          then
             cd_2 :=1;
       ELSIF (cd_2 = 11)
          then
             cd_2 := 0;
       END IF;

       IF (cd_1 = substr(CD_VALUE,1,1)  and cd_2 = substr(CD_VALUE,2,1))
          OR  (CD_VALUE = '00')
          then
          /* check digit checks out  */
          pass_check;
       ELSE
          fail_check;
       END IF;

    ELSE
       fail_check;

    END IF;  /* end of numeric check */

END IF; /* end of mandatory check  */
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_cd_es');
END IF;
*/
END CE_VALIDATE_CD_ES;


/****************     End of Procedure CE_VALIDATE_CD_ES   ***********/


procedure CE_VALIDATE_CD_FR(Xi_CD in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2,
                                      Xi_X_BANK_NUMBER in varchar2,
                                      Xi_X_BRANCH_NUMBER in varchar2,
                                      Xi_X_ACCOUNT_NUMBER in varchar2)
                                      AS
numeric_result_bk varchar2(40);
numeric_result_br varchar2(40);
numeric_result_cd varchar2(40);
numeric_result_ac varchar2(40);
calc_value number(30);
cd_value varchar2(20);
bk_value varchar2(30);
ac_value varchar2(30);
br_value varchar2(30);


                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_mandatory is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_CHECK_DIGIT');
   fnd_msg_pub.add;
end fail_mandatory;

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_CHECK_DIGIT');
   fnd_msg_pub.add;
end fail_check;

procedure pass_check is
begin
 IF l_DEBUG in ('Y', 'C') THEN
 	null;
 	-- 	cep_standard.debug('CE_VALIDATE_CD: ' || 'pass_check');
 END IF;

end pass_check;


                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_cd_fr');
END IF;

CD_VALUE := upper(Xi_CD);
bk_value := upper(Xi_X_BANK_NUMBER);
br_value := upper(Xi_X_BRANCH_NUMBER);
ac_value := upper(Xi_X_ACCOUNT_NUMBER);

IF Xi_PASS_MAND_CHECK = 'F'
  then
    fail_mandatory;

ELSIF Xi_PASS_MAND_CHECK = 'P'
  then

  IF length(CD_VALUE) < 3
   then
      numeric_result_bk := ce_check_numeric(bk_value,1,length(bk_value));
      numeric_result_br := ce_check_numeric(br_value,1,length(br_value));
      numeric_result_ac := ce_check_numeric(ac_value,1,length(ac_value));
      numeric_result_cd := ce_check_numeric(CD_VALUE,1,length(CD_VALUE));

    IF numeric_result_bk = '0' and numeric_result_br = '0'
        and numeric_result_cd = '0'
       then
             /* its numeric so continue  */
       calc_value := 97-mod(to_number(Xi_X_BANK_NUMBER||Xi_X_BRANCH_NUMBER||
                     translate(Xi_X_ACCOUNT_NUMBER,
                        'ABCDEFGHIJKLMNOPQRSTUVWXYZ ',
                         '123456789123456789234567890')||'00'),97);
       IF calc_value = CD_VALUE
          then
          /* check digit checks out  */
          pass_check;
       ELSE
          fail_check;
       END IF;

    ELSE
       fail_check;

    END IF;  /* end of numeric check */

  ELSE
   fail_check;

  END IF;  /* end of length check */
END IF; /* end of mandatory check  */

/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_cd_fr');
END IF;
*/
END CE_VALIDATE_CD_FR;


/****************     End of Procedure CE_VALIDATE_CD_FR   ***********/

-- new validations for check digits 5/14/02

procedure CE_VALIDATE_CD_DE(Xi_CD in varchar2,
                            Xi_X_ACCOUNT_NUMBER in varchar2)
                                      AS
numeric_result_cd varchar2(40);

calc_value number;
cd_value varchar2(50);



                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_CHECK_DIGIT');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_CD: ' || 'CE_INVALID_CHECK_DIGIT');
   END IF;
end fail_check;

procedure pass_check is
begin
 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_CD: ' || 'pass_check');
 END IF;
end pass_check;


                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_CD_DE');
END IF;

CD_VALUE := upper(Xi_CD);

IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('cd_value: '|| cd_value);
END IF;

IF (CD_VALUE is not null) THEN
  IF length(CD_VALUE) = 1   then
      numeric_result_cd := ce_check_numeric(CD_VALUE,1,length(CD_VALUE));

    IF numeric_result_cd = '0' then
      if (CE_VALIDATE_BANKINFO_UPG.COMPARE_ACCOUNT_NUM_AND_CD(Xi_X_ACCOUNT_NUMBER, CD_VALUE, 1, 0)) then
	 pass_check;
      end if;
    ELSE
          fail_check;
    END IF;

  ELSE
   fail_check;

  END IF;  /* end of length check */
END IF;

/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_CD_DE');
END IF;
*/
END CE_VALIDATE_CD_DE;

/* -------------------------------------------------------------------- */


procedure CE_VALIDATE_CD_GR(Xi_CD in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2,
                                      Xi_X_BANK_NUMBER in varchar2,
                                      Xi_X_BRANCH_NUMBER in varchar2,
                                      Xi_X_ACCOUNT_NUMBER in varchar2)
                                      AS
numeric_result_cd varchar2(40);

calc_value number(30);
cd_value varchar2(20);



                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_CHECK_DIGIT');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_CD: ' || 'CE_INVALID_CHECK_DIGIT');
   END IF;
end fail_check;

procedure pass_check is
begin
 IF l_DEBUG in ('Y', 'C') THEN
 	null;
 	-- 	cep_standard.debug('CE_VALIDATE_CD: ' || 'pass_check');
 END IF;
end pass_check;


                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN

CD_VALUE := upper(Xi_CD);

  IF length(CD_VALUE) < 2   then
      numeric_result_cd := ce_check_numeric(CD_VALUE,1,length(CD_VALUE));

    IF numeric_result_cd = '0' then
          pass_check;
    ELSE
          fail_check;
    END IF;

  ELSE
   fail_check;

  END IF;  /* end of length check */

END CE_VALIDATE_CD_GR;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_CD_IS(Xi_CD in varchar2,
                            Xi_X_ACCOUNT_NUMBER in varchar2)
                                      AS
numeric_result_cd varchar2(50);
numeric_result_ac varchar2(50);
cal_cd     number;
cal_cd1     number;

cd_value varchar2(50);
ac_value varchar2(50);
ac_cd_value varchar2(50);


                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_CHECK_DIGIT');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_CD: ' || 'CE_INVALID_CHECK_DIGIT');
   END IF;
end fail_check;


procedure pass_check is
begin
 IF l_DEBUG in ('Y', 'C') THEN
 	null;
 	-- 	cep_standard.debug('CE_VALIDATE_CD: ' || 'pass_check');
 END IF;
end pass_check;
                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_cd_is');
END IF;

CD_VALUE := upper(replace(Xi_CD,' ',''));
ac_value := upper(replace(Xi_X_ACCOUNT_NUMBER,' ',''));
ac_value := upper(replace(ac_value,'-',''));


ac_cd_value := substr(ac_value,17,1);

   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('ac_cd_value : ' || ac_cd_value|| ' cal_cd : ' || cal_cd);
   END IF;

IF (CD_VALUE is not null) THEN
  IF length(CD_VALUE) = 1   then
      numeric_result_cd := ce_check_numeric(CD_VALUE,1,length(CD_VALUE));

    IF numeric_result_cd = '0' then
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_CD: ' || 'cd is numeric');
   END IF;
      if (CE_VALIDATE_BANKINFO_UPG.COMPARE_ACCOUNT_NUM_AND_CD(ac_value, CD_VALUE, 1,1)) then
     		pass_check;
   		IF l_DEBUG in ('Y', 'C') THEN
   			cep_standard.debug('cd_value = cal_cd');
   		END IF;
      else
       	fail_check;

      end if;
    ELSE
	   IF l_DEBUG in ('Y', 'C') THEN
	   	cep_standard.debug('failed numeric');
	   END IF;
       fail_check;
    END IF; --numeric check

  ELSE
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('failed length');
   END IF;
          fail_check;
  END IF;  /* end of length check */

ELSE
       pass_check;
END IF;

/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_cd_is');
END IF;
*/
END CE_VALIDATE_CD_IS;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_CD_IT(Xi_CD in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2,
                                      Xi_X_BANK_NUMBER in varchar2,
                                      Xi_X_BRANCH_NUMBER in varchar2,
                                      Xi_X_ACCOUNT_NUMBER in varchar2)
                                      AS
numeric_result_bk varchar2(40);
numeric_result_br varchar2(40);
numeric_result_cd varchar2(40);
numeric_result_ac varchar2(40);
CONCED_NUMBER varchar2(30);
calc_value varchar2(30);
calc_value1 number;
calc_value2 number;
calc_value3 number;
cd_value varchar2(20);
bk_value varchar2(30);
ac_value varchar2(30);
br_value varchar2(30);



                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_mandatory is
begin
		IF l_DEBUG in ('Y', 'C') THEN
			cep_standard.debug('CD: procedure fail_mandatory CE_ENTER_CHECK_DIGIT ');
		END IF;
   fnd_message.set_name ('CE', 'CE_ENTER_CHECK_DIGIT');
   fnd_msg_pub.add;

end fail_mandatory;

procedure fail_check is
begin
		IF l_DEBUG in ('Y', 'C') THEN
			cep_standard.debug('CD: procedure fail_check CE_INVALID_CHECK_DIGIT');
		END IF;
   fnd_message.set_name ('CE', 'CE_INVALID_CHECK_DIGIT');
   fnd_msg_pub.add;
end fail_check;


procedure pass_check is
begin
  IF l_DEBUG in ('Y', 'C') THEN
	null;
 	--	cep_standard.debug('CE_VALIDATE_CD: ' || 'procedure pass_check ');
  END IF;
end pass_check;

function get_odd_value(odd_value_in varchar2) RETURN NUMBER
IS
  odd_value_out number;
BEGIN
  IF (odd_value_in in ('A', '0')) then
     odd_value_out := 1;
  ELSIF (odd_value_in in ('B', '1')) then
     odd_value_out := 0;
  ELSIF (odd_value_in in ('C', '2')) then
     odd_value_out := 5;
  ELSIF (odd_value_in in ('D', '3')) then
     odd_value_out := 7;
  ELSIF (odd_value_in in ('E', '4')) then
     odd_value_out := 9;
  ELSIF (odd_value_in in ('F', '5')) then
     odd_value_out := 13;
  ELSIF (odd_value_in in ('G', '6')) then
     odd_value_out := 15;
  ELSIF (odd_value_in in ('H', '7')) then
     odd_value_out := 17;
  ELSIF (odd_value_in in ('I', '8')) then
     odd_value_out := 19;
  ELSIF (odd_value_in in ('J', '9')) then
     odd_value_out := 21;
  ELSIF (odd_value_in = 'K') then
     odd_value_out := 2;
  ELSIF (odd_value_in = 'L') then
     odd_value_out := 4;
  ELSIF (odd_value_in = 'M') then
     odd_value_out := 18;
  ELSIF (odd_value_in = 'N') then
     odd_value_out := 20;
  ELSIF (odd_value_in = 'O') then
     odd_value_out := 11;
  ELSIF (odd_value_in = 'P') then
     odd_value_out := 3;
  ELSIF (odd_value_in = 'Q') then
     odd_value_out := 6;
  ELSIF (odd_value_in = 'R') then
     odd_value_out := 8;
  ELSIF (odd_value_in = 'S') then
     odd_value_out := 12;
  ELSIF (odd_value_in = 'T') then
     odd_value_out := 14;
  ELSIF (odd_value_in = 'U') then
     odd_value_out := 16;
  ELSIF (odd_value_in = 'V') then
     odd_value_out := 10;
  ELSIF (odd_value_in = 'W') then
     odd_value_out := 22;
  ELSIF (odd_value_in = 'X') then
     odd_value_out := 25;
  ELSIF (odd_value_in = 'Y') then
     odd_value_out := 24;
  ELSIF (odd_value_in = 'Z') then
     odd_value_out := 23;
  END IF;

  RETURN(odd_value_out);
END get_odd_value;

function get_even_value(even_value_in varchar2) RETURN NUMBER
IS
  even_value_out number;
BEGIN
  IF (even_value_in in ('A', '0')) then
     even_value_out := 0;
  ELSIF (even_value_in in ('B', '1')) then
     even_value_out := 1;
  ELSIF (even_value_in in ('C', '2')) then
     even_value_out := 2;
  ELSIF (even_value_in in ('D', '3')) then
     even_value_out := 3;
  ELSIF (even_value_in in ('E', '4')) then
     even_value_out := 4;
  ELSIF (even_value_in in ('F', '5')) then
     even_value_out := 5;
  ELSIF (even_value_in in ('G', '6')) then
     even_value_out := 6;
  ELSIF (even_value_in in ('H', '7')) then
     even_value_out := 7;
  ELSIF (even_value_in in ('I', '8')) then
     even_value_out := 8;
  ELSIF (even_value_in in ('J', '9')) then
     even_value_out := 9;
  ELSIF (even_value_in = 'K') then
     even_value_out := 10;
  ELSIF (even_value_in = 'L') then
     even_value_out := 11;
  ELSIF (even_value_in = 'M') then
     even_value_out := 12;
  ELSIF (even_value_in = 'N') then
     even_value_out := 13;
  ELSIF (even_value_in = 'O') then
     even_value_out := 14;
  ELSIF (even_value_in = 'P') then
     even_value_out := 15;
  ELSIF (even_value_in = 'Q') then
     even_value_out := 16;
  ELSIF (even_value_in = 'R') then
     even_value_out := 17;
  ELSIF (even_value_in = 'S') then
     even_value_out := 18;
  ELSIF (even_value_in = 'T') then
     even_value_out := 19;
  ELSIF (even_value_in = 'U') then
     even_value_out := 20;
  ELSIF (even_value_in = 'V') then
     even_value_out := 21;
  ELSIF (even_value_in = 'W') then
     even_value_out := 22;
  ELSIF (even_value_in = 'X') then
     even_value_out := 23;
  ELSIF (even_value_in = 'Y') then
     even_value_out := 24;
  ELSIF (even_value_in = 'Z') then
     even_value_out := 25;
  END IF;

  RETURN(even_value_out);
END get_even_value;

function get_result_cd(remainder_value_in number) RETURN varchar2
IS
  remainder_value_out VARCHAR2(1);
BEGIN
  IF (remainder_value_in =  '0') then
     remainder_value_out := 'A';
  ELSIF (remainder_value_in =  '1') then
     remainder_value_out := 'B';
  ELSIF (remainder_value_in =  '2') then
     remainder_value_out := 'C';
  ELSIF (remainder_value_in =  '3') then
     remainder_value_out := 'D';
  ELSIF (remainder_value_in =  '4') then
     remainder_value_out := 'E';
  ELSIF (remainder_value_in =  '5') then
     remainder_value_out := 'F';
  ELSIF (remainder_value_in =  '6') then
     remainder_value_out := 'G';
  ELSIF (remainder_value_in =  '7') then
     remainder_value_out := 'H';
  ELSIF (remainder_value_in =  '8') then
     remainder_value_out := 'I';
  ELSIF (remainder_value_in =  '9') then
     remainder_value_out := 'J';
  ELSIF (remainder_value_in =  '10') then
     remainder_value_out := 'K';
  ELSIF (remainder_value_in =  '11') then
     remainder_value_out := 'L';
  ELSIF (remainder_value_in =  '12') then
     remainder_value_out := 'M';
  ELSIF (remainder_value_in =  '13') then
     remainder_value_out := 'N';
  ELSIF (remainder_value_in =  '14') then
     remainder_value_out := 'O';
  ELSIF (remainder_value_in =  '15') then
     remainder_value_out := 'P';
  ELSIF (remainder_value_in =  '16') then
     remainder_value_out := 'Q';
  ELSIF (remainder_value_in =  '17') then
     remainder_value_out := 'R';
  ELSIF (remainder_value_in =  '18') then
     remainder_value_out := 'S';
  ELSIF (remainder_value_in =  '19') then
     remainder_value_out := 'T';
  ELSIF (remainder_value_in =  '20') then
     remainder_value_out := 'U';
  ELSIF (remainder_value_in =  '21') then
     remainder_value_out := 'V';
  ELSIF (remainder_value_in =  '22') then
     remainder_value_out := 'W';
  ELSIF (remainder_value_in =  '23') then
     remainder_value_out := 'X';
  ELSIF (remainder_value_in =  '24') then
     remainder_value_out := 'Y';
  ELSIF (remainder_value_in =  '25') then
     remainder_value_out := 'Z';

  END IF;

  RETURN(remainder_value_out);
END get_result_cd;




                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN

IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_cd_it'||
	' Xi_X_ACCOUNT_NUMBER: '||Xi_X_ACCOUNT_NUMBER);
END IF;

CD_VALUE := upper(replace(Xi_CD,' ',''));
bk_value := upper(replace(Xi_X_BANK_NUMBER,' ',''));
br_value := upper(replace(Xi_X_BRANCH_NUMBER,' ',''));
ac_value := upper(replace(Xi_X_ACCOUNT_NUMBER,' ',''));

ac_value := upper(ac_value);

IF l_DEBUG in ('Y', 'C') THEN
  cep_standard.debug('cd_value: '||cd_value|| ' ac_value: '||ac_value);
END IF;

IF Xi_PASS_MAND_CHECK = 'F'
  then
    fail_mandatory;

ELSIF Xi_PASS_MAND_CHECK = 'P'
  then

  IF length(CD_VALUE) = 1
   then
      numeric_result_bk := ce_check_numeric(bk_value,1,length(bk_value));
      numeric_result_br := ce_check_numeric(br_value,1,length(br_value));


    IF numeric_result_bk = '0' and numeric_result_br = '0'
       then
             /* its numeric so continue  */


       CONCED_NUMBER := bk_value||br_value||ac_value;

		IF l_DEBUG in ('Y', 'C') THEN
			cep_standard.debug('CONCED_NUMBER: '||CONCED_NUMBER);
		END IF;

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


			IF l_DEBUG in ('Y', 'C') THEN
				cep_standard.debug('Bank Digit 1: '||get_odd_value(substr(conced_number,1,1))||
					 get_even_value(substr(conced_number,2,1))||
					 get_odd_value(substr(conced_number,3,1))||
					 get_even_value(substr(conced_number,4,1))||
					 get_odd_value(substr(conced_number,5,1))||
					' Branch Digit 6: ' ||get_even_value(substr(conced_number,6,1))||
					 get_odd_value(substr(conced_number,7,1))||
					 get_even_value(substr(conced_number,8,1)) ||
					 get_odd_value(substr(conced_number,9,1)) ||
					 get_even_value(substr(conced_number,10,1))||
					 ' Account Digit 11: '||get_odd_value(substr(conced_number,11,1))||
					 get_even_value(substr(conced_number,12,1))||
					 get_odd_value(substr(conced_number,13,1))||
					 get_even_value(substr(conced_number,14,1))||
					 get_odd_value(substr(conced_number,15,1)) ||
					 get_even_value(substr(conced_number,16,1))||
					 get_odd_value(substr(conced_number,17,1))||
					 get_even_value(substr(conced_number,18,1))||
					 get_odd_value(substr(conced_number,19,1))||
					 get_even_value(substr(conced_number,20,1))||
					 get_odd_value(substr(conced_number,21,1))||
					 get_even_value(substr(conced_number,22,1))||
					 'calc_value1: '||calc_value1);
		END IF;

        calc_value2 := nvl(mod(calc_value1,26),0);

		IF l_DEBUG in ('Y', 'C') THEN
			cep_standard.debug('calc_value2: '||calc_value2);
		END IF;


	calc_value := get_result_cd(calc_value2);

		IF l_DEBUG in ('Y', 'C') THEN
			cep_standard.debug('calc_value: '||calc_value);
		END IF;


       IF calc_value = CD_VALUE
          then
          /* check digit checks out  */
          pass_check;
       ELSE
          fail_check;
		IF l_DEBUG in ('Y', 'C') THEN
			cep_standard.debug('fail_check cd_value');
		END IF;
       END IF;

    ELSE
       fail_check;
		IF l_DEBUG in ('Y', 'C') THEN
			cep_standard.debug('fail_check numeric ');
		END IF;

    END IF;  /* end of numeric check */

  ELSE
   fail_check;
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('fail_check cd length ');
	END IF;

  END IF;  /* end of length check */
END IF;

/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_cd_it');
END IF;
*/
END CE_VALIDATE_CD_IT;

/* -------------------------------------------------------------------- */


procedure CE_VALIDATE_CD_LU(Xi_CD in varchar2,
                                      Xi_X_BANK_NUMBER in varchar2,
                                      Xi_X_BRANCH_NUMBER in varchar2,
                                      Xi_X_ACCOUNT_NUMBER in varchar2)
                                      --Xo_VALUE_OUT OUT NOCOPY varchar2)
                                      AS
numeric_result_cd varchar2(40);

ACCOUNT_VALUE varchar2(30);

CHECK_DIGIT varchar2(2);

                          /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_CHECK_DIGIT');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_CD_LU: ' || 'CE_INVALID_CHECK_DIGIT');
   END IF;
end fail_check;

procedure pass_check is
begin
 IF l_DEBUG in ('Y', 'C') THEN
 	null;
 	-- 	cep_standard.debug('CE_VALIDATE_CD: ' || 'pass_check');
 END IF;
end pass_check;


                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_cd_lu');
END IF;

   ACCOUNT_VALUE := lpad(Xi_X_ACCOUNT_NUMBER,12,0);

   CHECK_DIGIT := Xi_CD;


IF CHECK_DIGIT is not null then
  IF length(CHECK_DIGIT) = 2   then
      numeric_result_cd := ce_check_numeric(CHECK_DIGIT,1,length(CHECK_DIGIT));


    IF numeric_result_cd = '0' then
          pass_check;

    /*IF MOD(account_value,97) = CHECK_DIGIT
               THEN pass_check;

      ELSIF MOD(account_value,97) = 0
               THEN Xo_VALUE_OUT := 97;
      ELSE fail_check;

      END IF;*/

    ELSE
	fail_check;

    END IF;  /* end of numeric check */

  ELSE fail_check;

  END IF;  /* end of length check */

ELSE
   pass_check;

END IF;

/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_cd_lu');
END IF;
*/
END CE_VALIDATE_CD_LU;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_CD_SE(Xi_CD in varchar2,
                            Xi_X_ACCOUNT_NUMBER in varchar2)
                                      AS
numeric_result_cd varchar2(40);

calc_value number(30);
cd_value varchar2(20);
account_value varchar2(30);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_CHECK_DIGIT');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_CD: ' || 'CE_INVALID_CHECK_DIGIT');
   END IF;
end fail_check;

procedure pass_check is
begin
 IF l_DEBUG in ('Y', 'C') THEN
 	null;
 	-- 	cep_standard.debug('CE_VALIDATE_CD: ' || 'pass_check');
 END IF;
end pass_check;


                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_cd_se');
END IF;

CD_VALUE := upper(Xi_CD);
account_value := upper(replace(Xi_X_ACCOUNT_NUMBER ,' ',''));
account_value := replace(account_value,'-','');

IF (CD_VALUE is not null) THEN
  IF length(CD_VALUE) = 1   then
      numeric_result_cd := ce_check_numeric(CD_VALUE,1,length(CD_VALUE));

    IF numeric_result_cd = '0' then
	pass_check;
    ELSE
          fail_check;
    END IF;

  ELSE
   fail_check;

  END IF;  /* end of length check */
ELSE
   pass_check;
END IF;
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_cd_se');
END IF;
*/
END CE_VALIDATE_CD_SE;

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


procedure CE_VALIDATE_BRANCH_AT(Xi_BRANCH_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2)
                                      AS
BRANCH_VALUE varchar2(30);

numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_mandatory is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_BRANCH_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH_AT: ' || 'CE_ENTER_BRANCH_NUM');
   END IF;
end fail_mandatory;

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BRANCH_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH_AT: ' || 'CE_INVALID_BRANCH_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin
 IF l_DEBUG in ('Y', 'C') THEN
 	null;
 	-- 	cep_standard.debug('CE_VALIDATE_BRANCH_AT: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_at');
END IF;

BRANCH_VALUE := upper(Xi_BRANCH_NUMBER );
Xo_VALUE_OUT := BRANCH_VALUE;

IF Xi_PASS_MAND_CHECK = 'F'
THEN
    fail_mandatory;

ELSIF Xi_PASS_MAND_CHECK = 'P'
THEN

    BRANCH_VALUE := replace(BRANCH_VALUE,' ','');

    IF ( length(BRANCH_VALUE) < 6 ) THEN

        numeric_result := ce_check_numeric(BRANCH_VALUE,1,length(BRANCH_VALUE));

        IF (numeric_result = '0' and length(BRANCH_VALUE) = 5 ) THEN
             /* its numeric so continue  */
           Xo_VALUE_OUT := BRANCH_VALUE;
           pass_check;
        ELSE
           fail_check;

        END IF;  /* end of numeric check */

     ELSE
          fail_check;

     END IF;  /* end of length check */

END IF; /* end of mandatory check  */
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_at');
END IF;
*/
END CE_VALIDATE_BRANCH_AT;

/****************     End of Procedure CE_VALIDATE_BRANCH_AT   ***********/

procedure CE_VALIDATE_BRANCH_PT(Xi_BRANCH_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2)
                                      AS
BRANCH_VALUE varchar2(30);
numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_mandatory is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_BRANCH_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH_PT: ' || 'CE_INVALID_BRANCH_NUM');
   END IF;
end fail_mandatory;

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BRANCH_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH_PT: ' || 'CE_INVALID_BRANCH_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin
 IF l_DEBUG in ('Y', 'C') THEN
 	null;
 	-- 	cep_standard.debug('CE_VALIDATE_BRANCH_PT: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_pt');
END IF;

BRANCH_VALUE := upper(Xi_BRANCH_NUMBER );

IF Xi_PASS_MAND_CHECK = 'F'
  then
    fail_mandatory;

ELSIF Xi_PASS_MAND_CHECK = 'P'
  then

  BRANCH_VALUE := replace(BRANCH_VALUE,' ','');

  IF length(BRANCH_VALUE) = 4
   then
      numeric_result := ce_check_numeric(BRANCH_VALUE,1,length(BRANCH_VALUE));

    IF numeric_result = '0'
       then /* its numeric so continue  */
       pass_check;
    ELSE
       fail_check;

    END IF;  /* end of numeric check */

  ELSE
   fail_check;

  END IF;  /* end of length check */
END IF; /* end of mandatory check  */
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_pt');
END IF;
*/
END CE_VALIDATE_BRANCH_PT;

/****************     End of Procedure CE_VALIDATE_BRANCH_PT   ***********/


procedure CE_VALIDATE_BRANCH_FR(Xi_BRANCH_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2)
                                      AS
BRANCH_VALUE varchar2(30);

numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_mandatory is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_BRANCH_NUM');
   fnd_msg_pub.add;
end fail_mandatory;

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BRANCH_NUM');
   fnd_msg_pub.add;
end fail_check;

procedure pass_check is
begin
 IF l_DEBUG in ('Y', 'C') THEN
 	null;
 	-- 	cep_standard.debug('CE_VALIDATE_BRANCH_FR: ' || 'pass_check');
 END IF;

end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_fr');
END IF;

BRANCH_VALUE := upper(Xi_BRANCH_NUMBER );
Xo_VALUE_OUT := BRANCH_VALUE;

IF Xi_PASS_MAND_CHECK = 'F'
  then
    fail_mandatory;

ELSIF Xi_PASS_MAND_CHECK = 'P'
  then

BRANCH_VALUE := replace(BRANCH_VALUE,' ','');

  IF length(BRANCH_VALUE) < 6
   then
   BRANCH_VALUE := lpad(BRANCH_VALUE,5,0);
      numeric_result := ce_check_numeric(BRANCH_VALUE,1,length(BRANCH_VALUE));

    IF numeric_result = '0'
       then
             /* its numeric so continue  */
       Xo_VALUE_OUT := BRANCH_VALUE;
       pass_check;
    ELSE
       fail_check;

    END IF;  /* end of numeric check */

  ELSE
   fail_check;

  END IF;  /* end of length check */
END IF; /* end of mandatory check  */
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_fr');
END IF;
*/
END CE_VALIDATE_BRANCH_FR;


/****************     End of Procedure CE_VALIDATE_BRANCH_FR   ***********/

procedure CE_VALIDATE_BRANCH_ES (Xi_BRANCH_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2)
                                      AS
BRANCH_VALUE varchar2(30);

numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

/*Bug Fix:880887*/
/*Changed the Xo_RET_VAR='F' to 'W' ,in 'fail_mandatory' and 'fail_check'*/
/*so that a warning message is displayed*/
/*for spain instead of Error message*/
procedure fail_mandatory is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_BRANCH_NUM');
   fnd_msg_pub.add;
   fnd_msg_pub.add_detail(fnd_msg_pub.g_warning_msg);

end fail_mandatory;

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BRANCH_NUM');
   fnd_msg_pub.add;
   fnd_msg_pub.add_detail(fnd_msg_pub.g_warning_msg);

end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_BRANCH_ES: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_es');
END IF;

BRANCH_VALUE := upper(Xi_BRANCH_NUMBER );
Xo_VALUE_OUT := BRANCH_VALUE;

IF Xi_PASS_MAND_CHECK = 'F'
  then
    fail_mandatory;

ELSIF Xi_PASS_MAND_CHECK = 'P'
  then

BRANCH_VALUE := replace(BRANCH_VALUE,' ','');

  IF length(BRANCH_VALUE) < 5
   then
   BRANCH_VALUE := lpad(BRANCH_VALUE,4,0);
      numeric_result := ce_check_numeric(BRANCH_VALUE,1,length(BRANCH_VALUE));

    IF numeric_result = '0'
       then
             /* its numeric so continue  */
       Xo_VALUE_OUT := BRANCH_VALUE;
       pass_check;
    ELSE
       fail_check;

    END IF;  /* end of numeric check */

  ELSE
   fail_check;

  END IF;  /* end of length check */
END IF; /* end of mandatory check  */
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_es');
END IF;
*/
END CE_VALIDATE_BRANCH_ES;


/****************     End of Procedure CE_VALIDATE_BRANCH_ES   ***********/



procedure CE_VALIDATE_BRANCH_BR(Xi_BRANCH_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2)
                                      AS
BRANCH_VALUE varchar2(30);

numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_mandatory is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_BRANCH_NUM');
   fnd_msg_pub.add;
end fail_mandatory;

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BRANCH_NUM');
   fnd_msg_pub.add;
end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
 	null;
 	-- 	cep_standard.debug('CE_VALIDATE_BRANCH_BR: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_br');
END IF;

BRANCH_VALUE := upper(Xi_BRANCH_NUMBER );
Xo_VALUE_OUT := BRANCH_VALUE;

IF Xi_PASS_MAND_CHECK = 'F'
  then
    fail_mandatory;

ELSIF Xi_PASS_MAND_CHECK = 'P'
  then

   BRANCH_VALUE := replace(BRANCH_VALUE,' ','');

     IF length(BRANCH_VALUE) < 6
       then
         BRANCH_VALUE := lpad(BRANCH_VALUE,5,0);
         numeric_result := ce_check_numeric(BRANCH_VALUE,1,length(BRANCH_VALUE));

       IF numeric_result = '0'
        then
                /* its numeric so continue  */
          Xo_VALUE_OUT := BRANCH_VALUE;
          pass_check;
       ELSE
          fail_check;

       END IF;  /* end of numeric check for branch */

     ELSE
      fail_check;

     END IF;  /* end of length check for branch */

END IF; /* end of mandatory check  */
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_br');
END IF;
*/
END CE_VALIDATE_BRANCH_BR;

/****************     End of Procedure CE_VALIDATE_BRANCH_BR   ***********/

-- new branch validations 5/14/02

procedure CE_VALIDATE_BRANCH_DE(Xi_BRANCH_NUMBER  in varchar2,
				Xi_BANK_ID        in NUMBER)
                                      AS
BRANCH_NUM varchar2(30);
numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BRANCH_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH_DE: ' || 'CE_INVALID_BRANCH_NUM');
   END IF;

end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
 	null;
 	-- 	cep_standard.debug('CE_VALIDATE_BRANCH_DE: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_de');
	END IF;

BRANCH_NUM := upper(replace(Xi_BRANCH_NUMBER,' ',''));

BRANCH_NUM := replace(BRANCH_NUM,'-','');

  IF (BRANCH_NUM) is not null then
    IF length(BRANCH_NUM) = 8  then
       numeric_result := ce_check_numeric(BRANCH_NUM,1,length(BRANCH_NUM));

      IF numeric_result = '0'     then /* its numeric so continue  */
       -- Bank number and branch number should be the same

        CE_VALIDATE_BANKINFO_UPG.COMPARE_BANK_AND_BRANCH_NUM(branch_num, Xi_BANK_ID);

      ELSE
        fail_check;
      END IF;  /* end of numeric check */
    ELSE
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('ce_validate_branch_de - length <>8');
	END IF;
      fail_check;

    END IF;  /* end of length check */

  ELSE
    pass_check;

  END IF;

	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_de');
	END IF;

END CE_VALIDATE_BRANCH_DE;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BRANCH_GR(Xi_BRANCH_NUMBER  in varchar2)
                                      AS
BRANCH_VALUE varchar2(30);

numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BRANCH_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH_GR: ' || 'CE_INVALID_BRANCH_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_BRANCH_GR: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_gr');
	END IF;

BRANCH_VALUE := upper(replace(Xi_BRANCH_NUMBER,' ',''));

BRANCH_VALUE := replace(BRANCH_VALUE,'-','');

IF (BRANCH_VALUE) is not null then

  IF length(BRANCH_VALUE) < 5    then
      numeric_result := ce_check_numeric(BRANCH_VALUE,1,length(BRANCH_VALUE));

    IF numeric_result = '0' then         /* its numeric so continue  */
       pass_check;
    ELSE
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('branch_gr failed numeric check');
	END IF;
       fail_check;

    END IF;  /* end of numeric check */

  ELSE
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('branch_gr failed length of branch_value < 5');
	END IF;
   fail_check;

  END IF;  /* end of length check */

ELSE

   pass_check;

END IF;
/*
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_gr');
	END IF;
*/
END CE_VALIDATE_BRANCH_GR;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BRANCH_IS(Xi_BRANCH_NUMBER  in varchar2,
				Xi_BANK_ID        in NUMBER,
                                Xo_VALUE_OUT OUT NOCOPY varchar2)
                                      AS
BRANCH_NUM varchar2(60);
numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BRANCH_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH_IS: ' || 'CE_INVALID_BRANCH_NUM');
   END IF;

end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_BRANCH_IS: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_is');
	END IF;

BRANCH_NUM := upper(replace(Xi_BRANCH_NUMBER,' ',''));

BRANCH_NUM := replace(BRANCH_NUM,'-','');

  IF (BRANCH_NUM) is not null then
    IF length(BRANCH_NUM) < 5  then
       numeric_result := ce_check_numeric(BRANCH_NUM,1,length(BRANCH_NUM));

      IF numeric_result = '0'   then /* its numeric so continue  */
        -- Bank number and branch number should be the same

  	Xo_value_out := lpad(BRANCH_NUM,4,0);
	BRANCH_NUM := lpad(BRANCH_NUM,4,0);

        CE_VALIDATE_BANKINFO_UPG.COMPARE_BANK_AND_BRANCH_NUM(branch_num, Xi_BANK_ID);

      ELSE
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('branch_is fail numeric check');
	END IF;
        fail_check;
      END IF;  /* end of numeric check */
    ELSE
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('branch_is fail check for length < 5');
	END IF;
      fail_check;

    END IF;  /* end of numeric check */

  ELSE
    pass_check;

  END IF;  /* end of length check */

/*
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_is');
	END IF;
*/
END CE_VALIDATE_BRANCH_IS;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BRANCH_IE(Xi_BRANCH_NUMBER  in varchar2,
				Xi_BANK_ID        in NUMBER)
                                      AS
BRANCH_NUM varchar2(60);
numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BRANCH_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH_IE: ' || 'CE_INVALID_BRANCH_NUM');
   END IF;

end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_BRANCH_IE: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_ie');
	END IF;

BRANCH_NUM := upper(replace(Xi_BRANCH_NUMBER,' ',''));

BRANCH_NUM := replace(BRANCH_NUM,'-','');

  IF (BRANCH_NUM) is not null then
    IF length(BRANCH_NUM) = 8  then
       numeric_result := ce_check_numeric(BRANCH_NUM,1,length(BRANCH_NUM));

      IF numeric_result = '0'   then /* its numeric so continue  */
        -- Bank number and branch number should be the same

        CE_VALIDATE_BANKINFO_UPG.COMPARE_BANK_AND_BRANCH_NUM(branch_num, Xi_BANK_ID);

      ELSE
        fail_check;
      END IF;  /* end of numeric check */
    ELSE
      fail_check;

    END IF;  /* end of length check */

  ELSE
    pass_check;

  END IF;

/*
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_ie');
	END IF;
*/
END CE_VALIDATE_BRANCH_IE;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BRANCH_IT(Xi_BRANCH_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2)
                                      AS
BRANCH_VALUE varchar2(30);

numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_mandatory is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_BRANCH_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH_IT: ' || 'CE_ENTER_BRANCH_NUM');
   END IF;
end fail_mandatory;

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BRANCH_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH_IT: ' || 'CE_INVALID_BRANCH_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
 	null;
 	-- 	cep_standard.debug('CE_VALIDATE_BRANCH_IT: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_it');
	END IF;

BRANCH_VALUE := upper(replace(Xi_BRANCH_NUMBER,' ',''));

BRANCH_VALUE := replace(BRANCH_VALUE,'-','');


IF Xi_PASS_MAND_CHECK = 'F'
  then
    fail_mandatory;

ELSIF Xi_PASS_MAND_CHECK = 'P'
  then

  IF length(BRANCH_VALUE) = 5
   then

      numeric_result := ce_check_numeric(BRANCH_VALUE,1,length(BRANCH_VALUE));

    IF numeric_result = '0'
       then
             /* its numeric so continue  */

       pass_check;
    ELSE
       fail_check;

    END IF;  /* end of numeric check */

  ELSE
   fail_check;

  END IF;  /* end of length check */
END IF; /* end of mandatory check  */
/*
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_it');
	END IF;
*/
END CE_VALIDATE_BRANCH_IT;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BRANCH_LU(Xi_BRANCH_NUMBER  in varchar2,
				Xi_BANK_ID        in NUMBER)
                                      AS
BRANCH_NUM varchar2(60);
numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BRANCH_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH_LU: ' || 'CE_INVALID_BRANCH_NUM');
   END IF;

end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_BRANCH_LU: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_lu');
	END IF;

BRANCH_NUM := upper(replace(Xi_BRANCH_NUMBER,' ',''));

BRANCH_NUM := replace(BRANCH_NUM,'-','');

  IF (BRANCH_NUM) is not null then
    IF length(BRANCH_NUM) = 2  then
       numeric_result := ce_check_numeric(BRANCH_NUM,1,length(BRANCH_NUM));

      IF numeric_result = '0'   then /* its numeric so continue  */
        -- Bank number and branch number should be the same

        CE_VALIDATE_BANKINFO_UPG.COMPARE_BANK_AND_BRANCH_NUM(branch_num, Xi_BANK_ID);

      ELSE
        fail_check;
      END IF;  /* end of numeric check */
    ELSE
      fail_check;

    END IF;  /* end of length check */

  ELSE
    pass_check;

  END IF;

/*
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_lu');
	END IF;
*/

END CE_VALIDATE_BRANCH_LU;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BRANCH_PL(Xi_BRANCH_NUMBER  in varchar2,
				Xi_BANK_ID        in NUMBER)
                                      AS
BRANCH_NUM varchar2(60);
numeric_result varchar2(40);
cal_cd1 number;

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BRANCH_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH_PL: ' || 'CE_INVALID_BRANCH_NUM');
   END IF;

end fail_check;


procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_BRANCH_PL: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_pl');
	END IF;

BRANCH_NUM := upper(replace(Xi_BRANCH_NUMBER,' ',''));

BRANCH_NUM := replace(BRANCH_NUM,'-','');


  IF (BRANCH_NUM) is not null then
    IF length(BRANCH_NUM) = 8  then
       numeric_result := ce_check_numeric(BRANCH_NUM,1,length(BRANCH_NUM));

      IF numeric_result = '0'   then /* its numeric so continue  */
        -- Bank number and branch number should be the same

        CE_VALIDATE_BANKINFO_UPG.COMPARE_BANK_AND_BRANCH_NUM(branch_num, Xi_BANK_ID);

	-- Modulus 10

	cal_cd1 := 10 - mod(((to_number(substr(BRANCH_NUM,1,1)) * 1)
        	         +(to_number(substr(BRANCH_NUM,2,1)) * 7)
                	 +(to_number(substr(BRANCH_NUM,3,1)) * 9)
                 	 +(to_number(substr(BRANCH_NUM,4,1)) * 3)
                 	 +(to_number(substr(BRANCH_NUM,5,1)) * 1)
                 	 +(to_number(substr(BRANCH_NUM,6,1)) * 7)
                 	 +(to_number(substr(BRANCH_NUM,7,1)) * 9)),10);

	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('cal_cd1: ' || cal_cd1);
	END IF;

        IF cal_cd1 = substr(BRANCH_NUM,8,1) then
		pass_check;
	else
       		fail_check;
        end if;
      ELSE
        fail_check;
      END IF;  /* end of numeric check */
    ELSE
      fail_check;

    END IF; /* end of length check */

  ELSE
    pass_check;

  END IF;

/*
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_pl');
	END IF;
*/
END CE_VALIDATE_BRANCH_PL;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BRANCH_SE(Xi_BRANCH_NUMBER  in varchar2,
				Xi_BANK_ID        in NUMBER)
                                      AS
BRANCH_NUM varchar2(60);
numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BRANCH_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH_SE: ' || 'CE_INVALID_BRANCH_NUM');
   END IF;

end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
 	null;
 	-- 	cep_standard.debug('CE_VALIDATE_BRANCH_SE: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_se');
	END IF;

BRANCH_NUM := upper(replace(Xi_BRANCH_NUMBER,' ',''));

BRANCH_NUM := replace(BRANCH_NUM,'-','');

  IF (BRANCH_NUM) is not null then
    IF ((length(BRANCH_NUM) = 4) or  (length(BRANCH_NUM) = 5)) then
       numeric_result := ce_check_numeric(BRANCH_NUM,1,length(BRANCH_NUM));

      IF numeric_result = '0'   then /* its numeric so continue  */
        -- Bank number and branch number should be the same

        CE_VALIDATE_BANKINFO_UPG.COMPARE_BANK_AND_BRANCH_NUM(branch_num, Xi_BANK_ID);

      ELSE
        fail_check;
      END IF;  /* end of numeric check */
    ELSE
      fail_check;

    END IF;  /* end of length check */

  ELSE
    pass_check;

  END IF;
/*
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_se');
	END IF;
*/

END CE_VALIDATE_BRANCH_SE;


/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BRANCH_CH(Xi_BRANCH_NUMBER  in varchar2,
				Xi_BANK_ID        in NUMBER)
                                      AS
BRANCH_NUM varchar2(60);
numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BRANCH_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH_CH: ' || 'CE_INVALID_BRANCH_NUM');
   END IF;

end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_BRANCH_CH: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_ch');
	END IF;

BRANCH_NUM := upper(replace(Xi_BRANCH_NUMBER,' ',''));

BRANCH_NUM := replace(BRANCH_NUM,'-','');

  IF (BRANCH_NUM) is not null then
    IF ((length(BRANCH_NUM) > 2) and  (length(BRANCH_NUM) < 6)) then
       numeric_result := ce_check_numeric(BRANCH_NUM,1,length(BRANCH_NUM));

      IF numeric_result = '0'   then /* its numeric so continue  */
        -- Bank number and branch number should be the same

        CE_VALIDATE_BANKINFO_UPG.COMPARE_BANK_AND_BRANCH_NUM(branch_num, Xi_BANK_ID);

      ELSE
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('ce_validate_branch_ch fail numeric check');
	END IF;
        fail_check;
      END IF;  /* end of numeric check */
    ELSE
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('ce_validate_branch_ch fail length');
	END IF;
      fail_check;

    END IF; /* end of length check */

  ELSE
    pass_check;

  END IF;
/*
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_ch');
	END IF;
*/

END CE_VALIDATE_BRANCH_CH;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BRANCH_GB(Xi_BRANCH_NUMBER  in varchar2,
				Xi_BANK_ID        in NUMBER)
                                      AS
BRANCH_NUM varchar2(60);
numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BRANCH_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH_GB: ' || 'CE_INVALID_BRANCH_NUM');
   END IF;

end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
 	null;
 	-- 	cep_standard.debug('CE_VALIDATE_BRANCH_GB: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_gb');
	END IF;
BRANCH_NUM := upper(replace(Xi_BRANCH_NUMBER,' ',''));

BRANCH_NUM := replace(BRANCH_NUM,'-','');

  IF (BRANCH_NUM) is not null then
    IF length(BRANCH_NUM) = 6  then
       numeric_result := ce_check_numeric(BRANCH_NUM,1,length(BRANCH_NUM));

      IF numeric_result = '0'   then /* its numeric so continue  */
        -- Bank number and branch number should be the same

        CE_VALIDATE_BANKINFO_UPG.COMPARE_BANK_AND_BRANCH_NUM(branch_num, Xi_BANK_ID);

      ELSE
        fail_check;
      END IF;  /* end of numeric check */
    ELSE
      fail_check;

    END IF;  /* end of length check */

  ELSE
    pass_check;

  END IF;
/*
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_gb');
	END IF;
*/

END CE_VALIDATE_BRANCH_GB;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BRANCH_US(Xi_BRANCH_NUMBER    in varchar2,
                                Xi_PASS_MAND_CHECK  in varchar2,
                                Xo_VALUE_OUT 	   OUT NOCOPY varchar2)
                                      AS
BRANCH_VALUE varchar2(30);
BRANCH_VALUE_OUT varchar2(30);
cal_cd1 number;
cd_value number;

numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_mandatory is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_BRANCH_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH_US: ' || 'CE_ENTER_BRANCH_NUM');
   END IF;
end fail_mandatory;

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BRANCH_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH_US: ' || 'CE_INVALID_BRANCH_NUM');
   END IF;
end fail_check;


procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_BRANCH_US: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_us');
END IF;

BRANCH_VALUE := upper(replace(Xi_BRANCH_NUMBER,' ',''));

BRANCH_VALUE := replace(BRANCH_VALUE,'-','');


IF Xi_PASS_MAND_CHECK = 'F'
  then

  -- Branch number should be made optional for all US banks.
  null;
  --   fail_mandatory;

ELSIF Xi_PASS_MAND_CHECK = 'P'
  then

   BRANCH_VALUE := replace(BRANCH_VALUE,' ','');

      	IF l_DEBUG in ('Y', 'C') THEN
      		cep_standard.debug('BRANCH_VALUE: ' || BRANCH_VALUE);
      	END IF;

   numeric_result := ce_check_numeric(BRANCH_VALUE,1,length(BRANCH_VALUE));

   IF numeric_result = '0' then

     IF length(BRANCH_VALUE) < 10 then
        IF length(BRANCH_VALUE) <> 9 then
   	   BRANCH_VALUE_OUT := lpad(BRANCH_VALUE,9,0);
        END IF;

      	IF l_DEBUG in ('Y', 'C') THEN
      		cep_standard.debug('BRANCH_VALUE_OUT: ' || BRANCH_VALUE_OUT);
      	END IF;

        IF (to_number(SUBSTR(BRANCH_VALUE_OUT,1,8)) = '00000000') then
	          	fail_check;
         	IF l_DEBUG in ('Y', 'C') THEN
         		cep_standard.debug('fail branch_value = 00000000');
         	END IF;
        ELSE
	  -- Modulus 10

 	   cal_cd1 := 10 - mod(((to_number(substr(BRANCH_VALUE_OUT,1,1)) * 3)
        		         +(to_number(substr(BRANCH_VALUE_OUT,2,1)) * 7)
                		 +(to_number(substr(BRANCH_VALUE_OUT,3,1)) * 1)
                 		 +(to_number(substr(BRANCH_VALUE_OUT,4,1)) * 3)
                 		 +(to_number(substr(BRANCH_VALUE_OUT,5,1)) * 7)
                 		 +(to_number(substr(BRANCH_VALUE_OUT,6,1)) * 1)
                 		 +(to_number(substr(BRANCH_VALUE_OUT,7,1)) * 3)
                 		 +(to_number(substr(BRANCH_VALUE_OUT,8,1)) * 7)),10);

	   cd_value := substr(BRANCH_VALUE_OUT,9,1);

      	IF l_DEBUG in ('Y', 'C') THEN
      		cep_standard.debug('cd_value: ' || cd_value ||' cal_cd1: ' || cal_cd1);
      	END IF;

           IF cal_cd1 = cd_value then
		pass_check;
	        Xo_VALUE_OUT := BRANCH_VALUE_OUT;

	   else
         	IF l_DEBUG in ('Y', 'C') THEN
         		cep_standard.debug('failed cd check');
         	END IF;
       		fail_check;

           end if;

	  IF l_DEBUG in ('Y', 'C') THEN
	  	cep_standard.debug('Xo_VALUE_OUT: '|| Xo_VALUE_OUT);
	  END IF;

        END IF;
     ELSE
         	IF l_DEBUG in ('Y', 'C') THEN
         		cep_standard.debug('fail length < 10');
         	END IF;
	fail_check;
     END IF;  /* end of length check for branch */
   ELSE
         	IF l_DEBUG in ('Y', 'C') THEN
         		cep_standard.debug('fail numeric check');
         	END IF;
          fail_check;

   END IF;  /* end of numeric check for branch */

END IF;  /* end of mandatory check  */

/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_branch_us');
END IF;
*/
END CE_VALIDATE_BRANCH_US;

/* -------------------------------------------------------------------- */
-- added 10/19/04

procedure CE_VALIDATE_BRANCH_AU(Xi_BRANCH_NUMBER  in varchar2,
				Xi_BANK_ID        in NUMBER,
                                Xi_PASS_MAND_CHECK in varchar2)
                                      AS
BRANCH_VALUE varchar2(30);
BANK_VALUE varchar2(30);
BANK_num varchar2(30);

length_bank_and_branch number;
numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_mandatory is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_BRANCH_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH_AU: ' || 'CE_ENTER_BRANCH_NUM');
   END IF;
end fail_mandatory;

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BRANCH_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH_AU: ' || 'CE_INVALID_BRANCH_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
 	cep_standard.debug('CE_VALIDATE_BRANCH_AU: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_branch_au');
	END IF;

BRANCH_VALUE := upper(replace(Xi_BRANCH_NUMBER,' ',''));

BRANCH_VALUE := replace(BRANCH_VALUE,'-','');


IF Xi_PASS_MAND_CHECK = 'F'
  then
    fail_mandatory;

ELSIF Xi_PASS_MAND_CHECK = 'P'
  then

  IF (length(BRANCH_VALUE) = 3 or length(BRANCH_VALUE) = 4 or length(BRANCH_VALUE) = 6)
   then

      numeric_result := ce_check_numeric(BRANCH_VALUE,1,length(BRANCH_VALUE));

    IF numeric_result = '0'
       then
             /* its numeric so continue  */
        -- Bank number and branch number should have total of 6 digits

       OPEN  get_bank_num(Xi_BANK_ID);
       FETCH get_bank_num INTO bank_num;

	BANK_VALUE := upper(replace(bank_num,' ',''));
	BANK_VALUE := replace(BANK_VALUE,'-','');
	length_bank_and_branch := length(BRANCH_VALUE) + nvl(length(BANK_VALUE), 0);

   close get_bank_num;

 	IF length_bank_and_branch = 6  THEN
      	  pass_check;
    	ELSE
       	  fail_check;
 	END IF;
    ELSE
       fail_check;

    END IF;  /* end of numeric check */

  ELSE
   fail_check;

  END IF;  /* end of length check */
END IF; /* end of mandatory check  */
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_branch_au');
	END IF;

END CE_VALIDATE_BRANCH_AU;
/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BRANCH_IL(Xi_BRANCH_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2)
                                      AS
BRANCH_VALUE varchar2(30);

numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_mandatory is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_BRANCH_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH_IL: ' || 'CE_ENTER_BRANCH_NUM');
   END IF;
end fail_mandatory;

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BRANCH_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH_IL: ' || 'CE_INVALID_BRANCH_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
 	cep_standard.debug('CE_VALIDATE_BRANCH_IL: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_branch_il');
	END IF;

BRANCH_VALUE := upper(replace(Xi_BRANCH_NUMBER,' ',''));

BRANCH_VALUE := replace(BRANCH_VALUE,'-','');


IF Xi_PASS_MAND_CHECK = 'F'
  then
    fail_mandatory;

ELSIF Xi_PASS_MAND_CHECK = 'P'
  then

  IF length(BRANCH_VALUE) = 3
   then

      numeric_result := ce_check_numeric(BRANCH_VALUE,1,length(BRANCH_VALUE));

    IF numeric_result = '0'
       then
             /* its numeric so continue  */

       pass_check;
    ELSE
       fail_check;

    END IF;  /* end of numeric check */

  ELSE
   fail_check;

  END IF;  /* end of length check */
END IF; /* end of mandatory check  */
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_branch_il');
	END IF;

END CE_VALIDATE_BRANCH_IL;
/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BRANCH_NZ(Xi_BRANCH_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2)
                                      AS
BRANCH_VALUE varchar2(30);

numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_mandatory is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_BRANCH_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH_NZ: ' || 'CE_ENTER_BRANCH_NUM');
   END IF;
end fail_mandatory;

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BRANCH_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH_NZ: ' || 'CE_INVALID_BRANCH_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
 	cep_standard.debug('CE_VALIDATE_BRANCH_NZ: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_branch_nz');
	END IF;

BRANCH_VALUE := upper(replace(Xi_BRANCH_NUMBER,' ',''));

BRANCH_VALUE := replace(BRANCH_VALUE,'-','');


IF Xi_PASS_MAND_CHECK = 'F'
  then
    fail_mandatory;

ELSIF Xi_PASS_MAND_CHECK = 'P'
  then

  IF length(BRANCH_VALUE) = 4
   then

      numeric_result := ce_check_numeric(BRANCH_VALUE,1,length(BRANCH_VALUE));

    IF numeric_result = '0'
       then
             /* its numeric so continue  */

       pass_check;
    ELSE
       fail_check;

    END IF;  /* end of numeric check */

  ELSE
   fail_check;

  END IF;  /* end of length check */
END IF; /* end of mandatory check  */
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_branch_nz');
	END IF;

END CE_VALIDATE_BRANCH_NZ;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BRANCH_JP(Xi_BRANCH_NUMBER  in varchar2,
				Xi_BRANCH_NAME_ALT  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2,
					Xi_VALIDATION_TYPE in varchar2)
                                      AS
BRANCH_VALUE varchar2(30);

numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_mandatory is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_BRANCH_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH_JP: ' || 'CE_ENTER_BRANCH_NUM');
   END IF;
end fail_mandatory;

procedure fail_branch_name_alt is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_BRANCH_NAME_ALT');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH_JP: ' || 'CE_ENTER_BRANCH_NAME_ALT');
   END IF;
end fail_branch_name_alt;

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BRANCH_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BRANCH_JP: ' || 'CE_INVALID_BRANCH_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
 	cep_standard.debug('CE_VALIDATE_BRANCH_JP: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_branch_jp');
	END IF;

BRANCH_VALUE := upper(replace(Xi_BRANCH_NUMBER,' ',''));

BRANCH_VALUE := replace(BRANCH_VALUE,'-','');


IF Xi_PASS_MAND_CHECK = 'F'
  then
    fail_mandatory;

ELSIF Xi_PASS_MAND_CHECK = 'P'
  then

  IF length(BRANCH_VALUE) = 4
   then

      numeric_result := ce_check_numeric(BRANCH_VALUE,1,length(BRANCH_VALUE));

    IF numeric_result = '0'
       then
             /* its numeric so continue  */

       pass_check;
    ELSE
       fail_check;

    END IF;  /* end of numeric check */

  ELSE
   fail_check;

  END IF;  /* end of length check */
END IF; /* end of mandatory check  */

IF (Xi_VALIDATION_TYPE = 'ALL') THEN
  IF (	Xi_BRANCH_NAME_ALT  is null) THEN

	fail_branch_name_alt ;
  END IF;
END IF;


	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_branch_jp');
	END IF;

END CE_VALIDATE_BRANCH_JP;

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


procedure CE_VALIDATE_ACCOUNT_AT (Xi_ACCOUNT_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2)
                                      AS
account_value varchar2(30);
chk_chars     varchar2(30);

		/*******************************/
	   	/* SUB FUNCTIONS and PROCEDURES*/
	 	/*******************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_ACCOUNT_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_ACCOUNT_AT: ' || 'CE_INVALID_ACCOUNT_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
 	null;
 	-- 	cep_standard.debug('CE_VALIDATE_ACCOUNT_AT: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_account_at');
END IF;

	account_value := upper(Xi_ACCOUNT_NUMBER );
	Xo_VALUE_OUT := account_value;

	account_value := replace(account_value,' ','');

	chk_chars := translate(account_value,'123456789'
                                    ,'00000000000000000000000000000000000');

  	IF length(account_value) < 12
     	then
         	chk_chars := lpad(chk_chars,11,0);
         	IF CHK_CHARS = '00000000000'
            	then
            		Xo_VALUE_OUT := lpad(account_value,11,0);
			pass_check;
         	ELSE
           		fail_check;
         	END IF;  /* end number check */
  	ELSE
     		fail_check;

  	END IF;  /* end of length check */
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_account_at');
END IF;
*/
END CE_VALIDATE_ACCOUNT_AT;

/****************     End of Procedure CE_VALIDATE_ACCOUNT_AT  ***********/


procedure CE_VALIDATE_ACCOUNT_PT (Xi_ACCOUNT_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2)
                                      AS
ACCOUNT_VALUE varchar2(30);
numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/


procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_ACCOUNT_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_ACCOUNT_PT: ' || 'CE_INVALID_ACCOUNT_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_ACCOUNT_PT: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_account_pt');
END IF;

ACCOUNT_VALUE := upper(Xi_ACCOUNT_NUMBER );
ACCOUNT_VALUE := replace(ACCOUNT_VALUE,' ','');

  IF length(ACCOUNT_VALUE) <= 11
   then
      ACCOUNT_VALUE := lpad(ACCOUNT_VALUE,11,0);
      numeric_result := ce_check_numeric(ACCOUNT_VALUE,1,length(ACCOUNT_VALUE));

    IF numeric_result = '0'
       then /* its numeric so continue  */
       Xo_VALUE_OUT := ACCOUNT_VALUE;
       pass_check;
    ELSE
       fail_check;

    END IF;  /* end of numeric check */

  ELSE
   fail_check;

  END IF;  /* end of length check */
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_account_pt');
END IF;
*/
END CE_VALIDATE_ACCOUNT_PT;

/****************     End of Procedure CE_VALIDATE_ACCOUNT_PT  ***********/

procedure CE_VALIDATE_ACCOUNT_BE (Xi_ACCOUNT_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2)
                                      AS
ACCOUNT_VALUE varchar2(30);
numeric_result varchar2(40);
BANK_CODE varchar2(3);
MIDDLE varchar2(7);
CHECK_DIGIT varchar2(2);
CONCED varchar2(30);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/


procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_ACCOUNT_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_ACCOUNT_BE: ' || 'CE_INVALID_ACCOUNT_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_ACCOUNT_BE: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_account_be');
END IF;

   ACCOUNT_VALUE := upper(substr(Xi_ACCOUNT_NUMBER ,1,14));
   BANK_CODE := substr(ACCOUNT_VALUE,1,3);
   MIDDLE := substr(ACCOUNT_VALUE,5,7);
   CHECK_DIGIT := substr(ACCOUNT_VALUE,13,2);
   CONCED := BANK_CODE||MIDDLE||CHECK_DIGIT;

   numeric_result := ce_check_numeric(CONCED,1,length(CONCED));

   CONCED := replace(CONCED,' ','');

   IF length(CONCED) = 12
      THEN IF numeric_result = '0'
              THEN /* its numeric so continue  */

                   IF MOD(BANK_CODE||MIDDLE,97) = 0
                               AND CHECK_DIGIT  = 97
                      THEN pass_check;
/*
2261587 fbreslin: 00 is never a valid check digit, even if
                  the MOD of the account number is 0
*/

                   ELSIF MOD(bank_code||middle, 97) = 0
                                    AND check_digit = 00
                      THEN fail_check;

                   ELSIF MOD(BANK_CODE||MIDDLE,97) = CHECK_DIGIT
                      THEN pass_check;
                      ELSE fail_check;

                   END IF;

              ELSE fail_check;

           END IF;  /* end of numeric check */

      ELSE fail_check;

   END IF;  /* end of length check */
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_account_be');
END IF;
*/

END CE_VALIDATE_ACCOUNT_BE;


/****************     End of Procedure CE_VALIDATE_ACCOUNT_BE  ***********/

procedure CE_VALIDATE_ACCOUNT_DK (Xi_ACCOUNT_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2,
                                      Xo_VALUE_OUT OUT  NOCOPY varchar2)
                                      AS
check_digit_ok_flag   boolean;
account_value varchar2(30);
chk_chars     varchar2(30);

		/*******************************/
	   	/* SUB FUNCTIONS and PROCEDURES*/
	 	/*******************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_ACCOUNT_NUM');
   fnd_msg_pub.add;
   fnd_msg_pub.add_detail(fnd_msg_pub.g_warning_msg);
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_ACCOUNT_DK: ' || 'CE_INVALID_ACCOUNT_NUM');
   END IF;

end fail_check;

procedure pass_check is
begin
  IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	-- 	cep_standard.debug('CE_VALIDATE_ACCOUNT_DK: ' || 'pass_check');
  END IF;

end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_account_dk');
END IF;

	account_value := upper(Xi_ACCOUNT_NUMBER );
	Xo_VALUE_OUT := account_value;

	account_value := replace(account_value,' ','');

	chk_chars := translate(account_value,'123456789'
                                    ,'00000000000000000000000000000000000');

  	IF length(account_value) < 11
     	then
         	IF CHK_CHARS = '0000000000'
            	then
            		Xo_VALUE_OUT := account_value;
			pass_check;
         	ELSE
           		fail_check;
         	END IF;  /* end number check */


  	ELSE
     		fail_check;

  	END IF;  /* end of length check */
 /*
IF l_DEBUG in ('Y', 'C') THEN
 	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_account_dk');
 END IF;
*/
END CE_VALIDATE_ACCOUNT_DK;

/****************     End of Procedure CE_VALIDATE_ACCOUNT_DK  ***********/

procedure CE_VALIDATE_ACCOUNT_FR (Xi_ACCOUNT_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2)
                                      AS
ACCOUNT_VALUE varchar2(30);
CHK_CHARS     varchar2(30);


                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/


procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_ACCOUNT_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_ACCOUNT_FR: ' || 'CE_INVALID_ACCOUNT_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_ACCOUNT_FR: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_account_fr');
END IF;

ACCOUNT_VALUE := upper(Xi_ACCOUNT_NUMBER );
Xo_VALUE_OUT := ACCOUNT_VALUE;

ACCOUNT_VALUE := replace(ACCOUNT_VALUE,' ','');

chk_chars := translate(ACCOUNT_VALUE,'ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789'
                                    ,'00000000000000000000000000000000000');


  IF length(ACCOUNT_VALUE) < 12
     then
         chk_chars := lpad(chk_chars,11,0);
         IF CHK_CHARS = '00000000000'
            then
            Xo_VALUE_OUT := lpad(ACCOUNT_VALUE,11,0);
         ELSE
           fail_check;
         END IF;  /* end of char and number check */


  ELSE
     fail_check;

  END IF;  /* end of length check */

/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_account_fr');
END IF;
*/
END CE_VALIDATE_ACCOUNT_FR;


/*******************  End of Procedure ce_validate_account_fr ***********/


procedure CE_VALIDATE_ACCOUNT_NL(Xi_ACCOUNT_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2)
                                      AS
ACCOUNT_VALUE varchar2(30);
numeric_result varchar2(40);
position_i number(2);
integer_value number(1);
multiplied_number number(2);
multiplied_sum number(3);
loop_sum number(3);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure check_11(input_value IN VARCHAR2,
                   mult_sum_result OUT NOCOPY NUMBER)
IS
BEGIN
      FOR position_i in 1..10  LOOP
          integer_value := substr(input_value,position_i,1);

          multiplied_number := integer_value * (11-position_i);
          loop_sum := loop_sum + multiplied_number;

      END LOOP;
      mult_sum_result := loop_sum;
END check_11;


procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_ACCOUNT_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_ACCOUNT_NL: ' || 'CE_INVALID_ACCOUNT_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
 	null;
 	-- 	cep_standard.debug('CE_VALIDATE_ACCOUNT_NL: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_account_nl');
END IF;

multiplied_number := 0;
multiplied_sum := 0;
loop_sum := 0;


ACCOUNT_VALUE := upper(Xi_ACCOUNT_NUMBER );
IF substr(ACCOUNT_VALUE,1,1) = 'P' OR substr(ACCOUNT_VALUE,1,1) = 'G'
   then

   IF length(ACCOUNT_VALUE) < 9 and instr(ACCOUNT_VALUE,' ') = 0
      then
      numeric_result := ce_check_numeric(ACCOUNT_VALUE,2,length(ACCOUNT_VALUE));
    IF numeric_result = '0'
       then
             /* its numeric so continue  */

      IF substr(ACCOUNT_VALUE,2,7) > 0 and substr(ACCOUNT_VALUE,2,7) <= 9999999
         then

           pass_check;
      ELSE

           fail_check;
      END IF;
    ELSE  /* failed numeric check */

        fail_check;
    END IF;

   ELSE  /* failed length check  */

      fail_check;
   END IF;

ELSE /* not a P or G account */
   numeric_result := ce_check_numeric(ACCOUNT_VALUE,1,length(ACCOUNT_VALUE));
    IF numeric_result = '0'
       then
             /* its numeric so continue  */
       IF length(ACCOUNT_VALUE) = 9 and instr(ACCOUNT_VALUE,' ') = 0
          then
             ACCOUNT_VALUE := '0'||ACCOUNT_VALUE;
             check_11(ACCOUNT_VALUE,multiplied_sum);
             IF mod(multiplied_sum,11) <> 0
                then
                fail_check;
             ELSE
                pass_check;
             END IF;

       ELSIF length(ACCOUNT_VALUE) = 10 and instr(ACCOUNT_VALUE,' ') = 0
           then
             check_11(ACCOUNT_VALUE,multiplied_sum);
             IF mod(multiplied_sum,11) <> 0
                then
                fail_check;
             ELSE
                pass_check;
             END IF;

       ELSE
            fail_check;

       END IF;

    ELSE  /* failed numeric check */
       fail_check;

    END IF;

END IF;

/*
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_account_nl');
  END IF;
 */
END CE_VALIDATE_ACCOUNT_NL;

/****************  End of Procedure CE_validate_account_nl ******/


procedure CE_VALIDATE_ACCOUNT_ES(Xi_ACCOUNT_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2)
                                      AS
ACCOUNT_VALUE varchar2(30);

numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

/*Bug Fix:880887*/
/*Changed the Xo_RET_VAR='F' to 'W' ,so that a warning message is displayed*/
/*for spain instead of Error message*/
procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_ACCOUNT_NUM');
   fnd_msg_pub.add;
   fnd_msg_pub.add_detail(fnd_msg_pub.g_warning_msg);
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('CE_VALIDATE_ACCOUNT_ES: ' || 'CE_INVALID_ACCOUNT_NUM');
    END IF;

end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_ACCOUNT_ES: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_account_es');
END IF;

ACCOUNT_VALUE := upper(Xi_ACCOUNT_NUMBER );
Xo_VALUE_OUT := ACCOUNT_VALUE;


ACCOUNT_VALUE := replace(ACCOUNT_VALUE,' ','');

IF length(ACCOUNT_VALUE) < 11
   then
   ACCOUNT_VALUE := lpad(ACCOUNT_VALUE,10,0);
      numeric_result := ce_check_numeric(ACCOUNT_VALUE,1,length(ACCOUNT_VALUE));

    IF numeric_result = '0'
       then
             /* its numeric so continue  */
       Xo_VALUE_OUT := ACCOUNT_VALUE;
       pass_check;
    ELSE
       fail_check;

    END IF;  /* end of numeric check */

ELSE
   fail_check;

END IF;  /* end of length check */
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_account_es');
END IF;
*/
END CE_VALIDATE_ACCOUNT_ES;


/**************  End of Procedure CE_VALIDATE_ACCOUNT_ES   **************/


procedure CE_VALIDATE_ACCOUNT_NO (Xi_ACCOUNT_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2)
                                      AS
ACCOUNT_VALUE varchar2(30);
numeric_result varchar2(40);
computed_sum number(30);
check_digit varchar2(20);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_ACCOUNT_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_ACCOUNT_NO: ' || 'CE_INVALID_ACCOUNT_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin
 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_ACCOUNT_NO: ' || 'pass_check');
 END IF;

end pass_check;


                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_account_no');
END IF;

ACCOUNT_VALUE := upper(Xi_ACCOUNT_NUMBER );

IF  length(ACCOUNT_VALUE) = 11 and ACCOUNT_VALUE <> '08271000279'and
	(substr(ACCOUNT_VALUE,5,2) <> '00')
    then
      check_digit := substr(ACCOUNT_VALUE,11,1);

      numeric_result := ce_check_numeric(ACCOUNT_VALUE,1,length(ACCOUNT_VALUE));

    IF numeric_result = '0'
       then
           computed_sum :=
             5 * substr(ACCOUNT_VALUE,1,1) +
             4 * substr(ACCOUNT_VALUE,2,1) +
             3 * substr(ACCOUNT_VALUE,3,1) +
             2 * substr(ACCOUNT_VALUE,4,1) +
             7 * substr(ACCOUNT_VALUE,5,1) +
             6 * substr(ACCOUNT_VALUE,6,1) +
             5 * substr(ACCOUNT_VALUE,7,1) +
             4 * substr(ACCOUNT_VALUE,8,1) +
             3 * substr(ACCOUNT_VALUE,9,1) +
             2 * substr(ACCOUNT_VALUE,10,1);

        IF mod((computed_sum + check_digit),11)=0
               then
           pass_check;
       ELSE
           fail_check;   /* failed numeric check  */
       END IF;
     ELSE
        fail_check;
     END IF;

/* 10/19/04  7-digit account numbers are no longer valid in Norway
ELSIF length(ACCOUNT_VALUE) = 7 and ACCOUNT_VALUE <> '1520006'
      and substr(ACCOUNT_VALUE,1,2) <> 12
      and substr(ACCOUNT_VALUE,1,2) <> 19
    then
    numeric_result := ce_check_numeric(ACCOUNT_VALUE,1,length(ACCOUNT_VALUE));

    IF numeric_result = '0'
       then
       account_value := lpad(ACCOUNT_VALUE,11,0);
           computed_sum :=
             (1 * substr(ACCOUNT_VALUE,1,1)) +
             substr(2 * substr(ACCOUNT_VALUE,2,1),1,1) +
                   nvl(substr(2 * substr(ACCOUNT_VALUE,2,1),2,1),0) +
             (1 * substr(ACCOUNT_VALUE,3,1)) +
             substr(2 * substr(ACCOUNT_VALUE,4,1),1,1) +
                   nvl(substr(2 * substr(ACCOUNT_VALUE,4,1),2,1),0) +
             (1 * substr(ACCOUNT_VALUE,5,1)) +
             substr(2 * substr(ACCOUNT_VALUE,6,1),1,1) +
                   nvl(substr(2 * substr(ACCOUNT_VALUE,6,1),2,1),0) +
             (1 * substr(ACCOUNT_VALUE,7,1)) +
             substr(2 * substr(ACCOUNT_VALUE,8,1),1,1) +
                   nvl(substr(2 * substr(ACCOUNT_VALUE,8,1),2,1),0) +
             (1 * substr(ACCOUNT_VALUE,9,1)) +
             substr(2 * substr(ACCOUNT_VALUE,10,1),1,1) +
                   nvl(substr(2 * substr(ACCOUNT_VALUE,10,1),2,1),0) +
             (1 * substr(ACCOUNT_VALUE,11,1));

        IF mod(computed_sum,10) = 0
           then
              pass_check;
        ELSE
              fail_check;
        END IF;

    ELSE
        fail_check;  -- failed numeric check

    END IF;
*/
ELSE
     fail_check;

END IF;
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_account_no');
END IF;
*/
END CE_VALIDATE_ACCOUNT_NO;


/*********   END CE_VALIDATE_ACCOUNT_NO         *************************/

/* 960103 VVAHAMAA Bank Account Validation for Finland */

procedure CE_VALIDATE_ACCOUNT_FI (Xi_ACCOUNT_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2)
                                      AS
ACCOUNT_VALUE varchar2(30);
COMPUTED_SUM varchar2(20);
BRANCH_NUMBER varchar2(3);
numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_ACCOUNT_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_ACCOUNT_FI: ' || 'CE_INVALID_ACCOUNT_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin
 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_ACCOUNT_FI: ' || 'pass_check');
 END IF;

end pass_check;


                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_account_fi');
END IF;

ACCOUNT_VALUE := upper(Xi_ACCOUNT_NUMBER );

select
      decode(substr(Xi_ACCOUNT_NUMBER ,1,1), '1','Y','2','Y','3','Y','4','N',
      '5','N','6','Y','7','N','8','Y','9','Y','ERR')
into BRANCH_NUMBER
from dual;

    if BRANCH_NUMBER='Y' then
       ACCOUNT_VALUE:= substr(Xi_ACCOUNT_NUMBER ,1,6)||
              lpad(substr(Xi_ACCOUNT_NUMBER ,8),8,'0');
    elsif  BRANCH_NUMBER='N' then
       ACCOUNT_VALUE:= substr(Xi_ACCOUNT_NUMBER ,1,6)||
              substr(Xi_ACCOUNT_NUMBER ,8,1)||
              lpad(substr(Xi_ACCOUNT_NUMBER ,9),7,'0');
    else
          fail_check;
	  return;
    end if;
    ACCOUNT_VALUE:=replace(ACCOUNT_VALUE,'-','0');
    numeric_result := ce_check_numeric(ACCOUNT_VALUE,1,length(ACCOUNT_VALUE));
    IF numeric_result = '0'
    THEN
	null;
    ELSE
	fail_check;
	return;
    END IF;
    IF substr(ACCOUNT_VALUE,1,2)='88' then
       COMPUTED_SUM:=to_char(
       1* to_number(substr(ACCOUNT_VALUE,8,1))+
       3* to_number(substr(ACCOUNT_VALUE,9,1))+
       7* to_number(substr(ACCOUNT_VALUE,10,1)) +
       1* to_number(substr(ACCOUNT_VALUE,11,1)) +
       3* to_number(substr(ACCOUNT_VALUE,12,1)) +
       7* to_number(substr(ACCOUNT_VALUE,13,1)));

       	if substr(ACCOUNT_VALUE,14,1)=
          to_char(10-to_number(substr(COMPUTED_SUM,length(COMPUTED_SUM),1))) or
          (substr(ACCOUNT_VALUE,14,1)= '0' and
	   substr(COMPUTED_SUM,length(COMPUTED_SUM),1)='0')
 	then
          null;
	else
          fail_check;
	  return;
        end if;
    ELSE
      COMPUTED_SUM:= mod(2*substr(ACCOUNT_VALUE,1,1),10) +
	trunc(2*substr(ACCOUNT_VALUE,1,1)/10) +
	mod(1*substr(ACCOUNT_VALUE,2,1),10) +
	mod(2*substr(ACCOUNT_VALUE,3,1),10) +
	trunc(2*substr(ACCOUNT_VALUE,3,1)/10) +
	mod(1*substr(ACCOUNT_VALUE,4,1),10) +
	mod(2*substr(ACCOUNT_VALUE,5,1),10) +
	trunc(2*substr(ACCOUNT_VALUE,5,1)/10) +
        mod(1*substr(ACCOUNT_VALUE,6,1),10) +
        mod(2*substr(ACCOUNT_VALUE,7,1),10) +
	trunc(2*substr(ACCOUNT_VALUE,7,1)/10) +
        mod(1*substr(ACCOUNT_VALUE,8,1),10) +
        mod(2*substr(ACCOUNT_VALUE,9,1),10) +
	trunc(2*substr(ACCOUNT_VALUE,9,1)/10) +
        mod(1*substr(ACCOUNT_VALUE,10,1),10) +
        mod(2*substr(ACCOUNT_VALUE,11,1),10) +
	trunc(2*substr(ACCOUNT_VALUE,11,1)/10) +
        mod(1*substr(ACCOUNT_VALUE,12,1),10) +
        mod(2*substr(ACCOUNT_VALUE,13,1),10) +
	trunc(2*substr(ACCOUNT_VALUE,13,1)/10);

      IF trunc((COMPUTED_SUM+9)/10)*10 -COMPUTED_SUM<>
	   to_number(substr(ACCOUNT_VALUE,14,1)) THEN
          fail_check;
	  return;
      END IF;
    END IF;
    pass_check;
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_account_fi');
END IF;
*/
END CE_VALIDATE_ACCOUNT_FI;

/*********   END CE_VALIDATE_ACCOUNT_FI         *************************/

-- new account validations 5/14/02

procedure CE_VALIDATE_ACCOUNT_DE(Xi_ACCOUNT_NUMBER  in varchar2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2)
                                      AS
account_value varchar2(60);
numeric_result varchar2(40);


		/*******************************/
	   	/* SUB FUNCTIONS and PROCEDURES*/
	 	/*******************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_ACCOUNT_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_ACCOUNT_DE: ' || 'CE_INVALID_ACCOUNT_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_ACCOUNT_DE: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_ACCOUNT_DE');
END IF;

account_value := upper(Xi_ACCOUNT_NUMBER );
Xo_VALUE_OUT := account_value;

account_value := replace(account_value,' ','');

IF ((length(account_value) > 10) or (length(account_value) < 1)) THEN
           fail_check;

ELSE
   numeric_result := ce_check_numeric(account_value,1,length(account_value));

   IF numeric_result <> '0' then
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug( 'failed numeric');
	END IF;
      fail_check;
   ELSE
      Xo_VALUE_OUT := lpad(account_value,10,0);
   END IF;  /* end of numeric check */
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('Xo_VALUE_OUT: ' || Xo_VALUE_OUT);
	END IF;
END IF;  /* end of length check */

/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_ACCOUNT_DE');
END IF;
*/
END CE_VALIDATE_ACCOUNT_DE;

/* -------------------------------------------------------------------- */


procedure CE_VALIDATE_ACCOUNT_GR(Xi_ACCOUNT_NUMBER  in varchar2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2)
                                      AS
account_value varchar2(30);
numeric_result varchar2(40);

		/*******************************/
	   	/* SUB FUNCTIONS and PROCEDURES*/
	 	/*******************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_ACCOUNT_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_ACCOUNT_GR: ' || 'CE_INVALID_ACCOUNT_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_ACCOUNT_GR: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_ACCOUNT_GR');
END IF;

	account_value := upper(replace(Xi_ACCOUNT_NUMBER,' ',''));
	account_value := replace(account_value,'-','');

IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug(' account_value: ' ||account_value);
END IF;

  	IF length(account_value) < 8 THEN
           fail_check;

  	ELSIF length(account_value) < 13  THEN

     	      numeric_result := ce_check_numeric(ACCOUNT_VALUE,1,length(ACCOUNT_VALUE));

  	   IF numeric_result = '0'   then
              IF length(account_value) <> 12 then
	   	Xo_VALUE_OUT := lpad(account_value,12,0);
	      END IF;

           ELSE
           	fail_check;
           END IF;  /* end number check */
  	ELSE
     	   fail_check;

  	END IF;  /* end of length check */
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_ACCOUNT_GR');
END IF;
*/
END CE_VALIDATE_ACCOUNT_GR;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_ACCOUNT_IS(Xi_ACCOUNT_NUMBER  in varchar2,
                                      Xo_VALUE_OUT OUT  NOCOPY varchar2)
                                      AS

ac_value varchar2(50);
cal_cd     number;
cal_cd1     number;

cd_value varchar2(50);
ac_cd_value varchar2(50);


numeric_result varchar2(40);

		/*******************************/
	   	/* SUB FUNCTIONS and PROCEDURES*/
	 	/*******************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_ACCOUNT_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_ACCOUNT_IS: ' || 'CE_INVALID_ACCOUNT_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_ACCOUNT_IS: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_account_is');
END IF;

ac_value := upper(Xi_ACCOUNT_NUMBER );

ac_value := replace(ac_value,' ','');
ac_value := replace(ac_value,'-','');


IF length(ac_value) < 19 THEN
     numeric_result := ce_check_numeric(AC_VALUE,1,length(AC_VALUE));
  IF numeric_result = '0'   then

     IF length(ac_value) <> 18  THEN
            	Xo_VALUE_OUT := lpad(ac_value,18,0);
            	ac_value := lpad(ac_value,18,0);
     END IF;

      IF l_DEBUG in ('Y', 'C') THEN
      	cep_standard.debug( 'ac_value : ' || ac_value);
      END IF;

     cal_cd1 := mod(( (to_number(substr(ac_value,9,1)) * 3)
                 +(to_number(substr(ac_value,10,1)) * 2)
                 +(to_number(substr(ac_value,11,1)) * 7)
                 +(to_number(substr(ac_value,12,1)) * 6)
                 +(to_number(substr(ac_value,13,1)) * 5)
                 +(to_number(substr(ac_value,14,1)) * 4)
                 +(to_number(substr(ac_value,15,1)) * 3)
                 +(to_number(substr(ac_value,16,1)) * 2)),11);

     IF l_DEBUG in ('Y', 'C') THEN
     	cep_standard.debug('cal_cd1 : ' || cal_cd1);
     END IF;

     IF cal_cd1 = 0 then
        cal_cd := 0;
     else
        cal_cd := (11 - cal_cd1);
     END if;

	-- the check digit is the penultimate digit of (a3).
     ac_cd_value := substr(ac_value,17,1);

      IF l_DEBUG in ('Y', 'C') THEN
      	cep_standard.debug('ac_cd_value: ' || ac_cd_value||  ' cal_cd: ' || cal_cd);
      END IF;

      IF ac_cd_value = cal_cd  then
         pass_check;
      ELSE
         IF l_DEBUG in ('Y', 'C') THEN
         	cep_standard.debug('failed check - cd ');
         END IF;
         fail_check;
      END IF;

  ELSE
      IF l_DEBUG in ('Y', 'C') THEN
      	cep_standard.debug('failed check numeric ');
      END IF;
    fail_check;
  END IF;
ELSE
      IF l_DEBUG in ('Y', 'C') THEN
      	cep_standard.debug('failed check length ');
      END IF;
   fail_check;
END IF;  /* end of length check */
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_account_is');
END IF;
*/
END CE_VALIDATE_ACCOUNT_IS;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_ACCOUNT_IE(Xi_ACCOUNT_NUMBER  in varchar2)
                                      AS
account_value varchar2(30);
numeric_result varchar2(40);

		/*******************************/
	   	/* SUB FUNCTIONS and PROCEDURES*/
	 	/*******************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_ACCOUNT_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_ACCOUNT_IE: ' || 'CE_INVALID_ACCOUNT_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin
 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_ACCOUNT_IE: ' || 'pass_check');
 END IF;

end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_account_ie');
END IF;

	account_value := upper(Xi_ACCOUNT_NUMBER );

	account_value := replace(account_value,' ','');
	account_value := replace(account_value,'-','');


  	IF length(account_value) = 8  THEN
	    numeric_result := ce_check_numeric(ACCOUNT_VALUE,1,length(ACCOUNT_VALUE));

	      IF numeric_result = '0'   then
		pass_check;

  	       ELSE
     		  fail_check;
               END IF;
	ELSE
	   fail_check;
  	END IF;  /* end of length check */
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_account_ie');
END IF;
*/
END CE_VALIDATE_ACCOUNT_IE;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_ACCOUNT_IT(Xi_ACCOUNT_NUMBER  in varchar2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2)
                                      AS
account_value varchar2(50);


		/*******************************/
	   	/* SUB FUNCTIONS and PROCEDURES*/
	 	/*******************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_ACCOUNT_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_ACCOUNT_IT: ' || 'CE_INVALID_ACCOUNT_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_ACCOUNT_IT: ' || 'pass_check');
 END IF;
end pass_check;



                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_account_it');
END IF;

	account_value := upper(replace(Xi_ACCOUNT_NUMBER,' ',''));
	account_value := replace(account_value,'-','');
   		IF l_DEBUG in ('Y', 'C') THEN
   			cep_standard.debug('length(account_value): '||length(account_value) );
   		END IF;

  	IF length(account_value) < 13  THEN
       		Xo_VALUE_OUT := lpad(account_value,12,0);
		pass_check;
   		IF l_DEBUG in ('Y', 'C') THEN
   			cep_standard.debug('Xo_VALUE_OUT: '||Xo_VALUE_OUT );
   		END IF;
  	ELSE
     		fail_check;

  	END IF;  /* end of length check */
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_account_it');
END IF;
*/
END CE_VALIDATE_ACCOUNT_IT;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_ACCOUNT_LU(Xi_ACCOUNT_NUMBER  in varchar2)
                                      AS
account_value varchar2(30);
numeric_result varchar2(40);

		/*******************************/
	   	/* SUB FUNCTIONS and PROCEDURES*/
	 	/*******************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_ACCOUNT_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_ACCOUNT_LU: ' || 'CE_INVALID_ACCOUNT_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin
 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_ACCOUNT_LU: ' || 'pass_check');
 END IF;

end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_account_lu');
END IF;

	account_value := upper(Xi_ACCOUNT_NUMBER );

	account_value := replace(account_value,' ','');
	account_value := replace(account_value,'-','');


  	IF length(account_value) < 13  THEN
	    numeric_result := ce_check_numeric(ACCOUNT_VALUE,1,length(ACCOUNT_VALUE));

	      IF numeric_result = '0'   then
		pass_check;

  	       ELSE
     		  fail_check;
               END IF;
	ELSE
	   fail_check;
  	END IF;  /* end of length check */
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_account_lu');
END IF;
*/
END CE_VALIDATE_ACCOUNT_LU;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_ACCOUNT_PL(Xi_ACCOUNT_NUMBER  in varchar2)
                                      AS
account_value varchar2(30);
numeric_result varchar2(40);

		/*******************************/
	   	/* SUB FUNCTIONS and PROCEDURES*/
	 	/*******************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_ACCOUNT_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_ACCOUNT_PL: ' || 'CE_INVALID_ACCOUNT_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin
 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_ACCOUNT_PL: ' || 'pass_check');
 END IF;

end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_account_pl');
END IF;

	account_value := upper(Xi_ACCOUNT_NUMBER );

	account_value := replace(account_value,' ','');
	account_value := replace(account_value,'-','');


  	IF length(account_value) < 25  THEN

		pass_check;
	ELSE
	   fail_check;
  	END IF;  /* end of length check */
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_account_pl');
END IF;
*/
END CE_VALIDATE_ACCOUNT_PL;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_ACCOUNT_SE(Xi_ACCOUNT_NUMBER  in varchar2)
                                      AS
account_value varchar2(30);
numeric_result varchar2(40);

		/*******************************/
	   	/* SUB FUNCTIONS and PROCEDURES*/
	 	/*******************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_ACCOUNT_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_ACCOUNT_SE: ' || 'CE_INVALID_ACCOUNT_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin
 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_ACCOUNT_SE: ' || 'pass_check');
 END IF;

end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_account_se');
END IF;

	account_value := upper(replace(Xi_ACCOUNT_NUMBER ,' ',''));
	account_value := replace(account_value,'-','');

  	IF length(account_value) < 12  THEN
	    numeric_result := ce_check_numeric(ACCOUNT_VALUE,1,length(ACCOUNT_VALUE));

	      IF numeric_result = '0'   then
		pass_check;

  	       ELSE
     		  fail_check;
               END IF;
	ELSE
	   fail_check;
  	END IF;  /* end of length check */
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_account_se');
END IF;
*/
END CE_VALIDATE_ACCOUNT_SE;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_ACCOUNT_CH(Xi_ACCOUNT_NUMBER  in varchar2,
					Xi_ACCOUNT_TYPE in varchar2,
					Xi_VALIDATION_TYPE in varchar2 )
                                      AS
account_value varchar2(30);


		/*******************************/
	   	/* SUB FUNCTIONS and PROCEDURES*/
	 	/*******************************/

procedure fail_account_type is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_ACCOUNT_TYPE');
   fnd_msg_pub.add;
   fnd_msg_pub.add_detail(fnd_msg_pub.g_warning_msg);

end fail_account_type;

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_ACCOUNT_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_ACCOUNT_CH: ' || 'CE_INVALID_ACCOUNT_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin
 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_ACCOUNT_CH: ' || 'pass_check');
 END IF;

end pass_check;



                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_account_ch');
END IF;

	account_value := upper(replace(Xi_ACCOUNT_NUMBER,' ',''));

	account_value := replace(account_value,'-','');

  	IF length(account_value) < 17  THEN
		pass_check;
  	ELSE
     		fail_check;

  	END IF;  /* end of length check */

IF (Xi_VALIDATION_TYPE = 'ALL') THEN
  IF (Xi_ACCOUNT_TYPE  is null)  THEN
    fail_account_type;
  END if;
END if;

/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_account_ch');
END IF;
*/
END CE_VALIDATE_ACCOUNT_CH;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_ACCOUNT_GB(Xi_ACCOUNT_NUMBER  in varchar2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2)
                                      AS
account_value varchar2(30);
numeric_result varchar2(40);

		/*******************************/
	   	/* SUB FUNCTIONS and PROCEDURES*/
	 	/*******************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_ACCOUNT_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_ACCOUNT_GB: ' || 'CE_INVALID_ACCOUNT_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_ACCOUNT_GB: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_account_gb');
END IF;

	Xo_VALUE_OUT := account_value;

	account_value := upper(replace(Xi_ACCOUNT_NUMBER,' ',''));
	account_value := replace(account_value,'-','');

  	IF length(account_value) < 9  THEN
	    numeric_result := ce_check_numeric(ACCOUNT_VALUE,1,length(ACCOUNT_VALUE));

	   IF numeric_result = '0'   then
	      IF (length(account_value) <> 8)  then
	     	Xo_VALUE_OUT := lpad(account_value,8,0);
	      END IF;
	   ELSE
     		  fail_check;
           END IF;

  	ELSE
     		fail_check;

  	END IF;  /* end of length check */
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_account_gb');
END IF;
*/
END CE_VALIDATE_ACCOUNT_GB;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_ACCOUNT_BR(Xi_ACCOUNT_NUMBER  in varchar2,
                                     Xi_SECONDARY_ACCOUNT_REFERENCE in varchar2)
                                      AS
account_ref varchar2(30);
numeric_result varchar2(40);

		/*******************************/
	   	/* SUB FUNCTIONS and PROCEDURES*/
	 	/*******************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_COMPANY_CODE');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_ACCOUNT_BR: ' || 'CE_INVALID_COMPANY_CODE');
   END IF;
end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_ACCOUNT_BR: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN

IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_account_br');
END IF;

	account_ref := upper(replace(Xi_SECONDARY_ACCOUNT_REFERENCE,' ',''));

IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('account_ref: '|| account_ref);
END IF;

  IF (account_ref) is not null then

  	IF length(account_ref) < 16  THEN
	    numeric_result := ce_check_numeric(ACCOUNT_REF,1,length(ACCOUNT_REF));

	   IF numeric_result = '0'   then
		pass_check;
	   ELSE
     		  fail_check;
           END IF;

  	ELSE
     		fail_check;

  	END IF;  /* end of length check */
  ELSE
   pass_check;

  END IF;  /* end of not null check */

IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_account_br');
END IF;

END CE_VALIDATE_ACCOUNT_BR;

--added 10/19/04

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_ACCOUNT_AU(Xi_ACCOUNT_NUMBER  in varchar2)
                                      AS
account_value varchar2(30);
numeric_result varchar2(40);

		/*******************************/
	   	/* SUB FUNCTIONS and PROCEDURES*/
	 	/*******************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_ACCOUNT_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_ACCOUNT_AU: ' || 'CE_INVALID_ACCOUNT_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin
 IF l_DEBUG in ('Y', 'C') THEN
 	cep_standard.debug('CE_VALIDATE_ACCOUNT_AU: ' || 'pass_check');
 END IF;

end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_au');
END IF;

	account_value := upper(Xi_ACCOUNT_NUMBER );

	account_value := replace(account_value,' ','');
	account_value := replace(account_value,'-','');


  	IF length(account_value) <= 10 and  length(account_value) >= 7 THEN
	    numeric_result := ce_check_numeric(ACCOUNT_VALUE,1,length(ACCOUNT_VALUE));

	      IF numeric_result = '0'   then
		pass_check;

  	       ELSE
     		  fail_check;
               END IF;

	ELSE
	   fail_check;
  	END IF;  /* end of length check */
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_account_au');
END IF;

END CE_VALIDATE_ACCOUNT_AU;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_ACCOUNT_IL(Xi_ACCOUNT_NUMBER  in varchar2)
                                      AS
account_value varchar2(30);
numeric_result varchar2(40);

		/*******************************/
	   	/* SUB FUNCTIONS and PROCEDURES*/
	 	/*******************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_ACCOUNT_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_ACCOUNT_IL: ' || 'CE_INVALID_ACCOUNT_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin
 IF l_DEBUG in ('Y', 'C') THEN
 	cep_standard.debug('CE_VALIDATE_ACCOUNT_IL: ' || 'pass_check');
 END IF;

end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_il');
END IF;

	account_value := upper(Xi_ACCOUNT_NUMBER );

	account_value := replace(account_value,' ','');
	account_value := replace(account_value,'-','');


  	IF length(account_value) = 9 THEN
	    numeric_result := ce_check_numeric(ACCOUNT_VALUE,1,length(ACCOUNT_VALUE));

	      IF numeric_result = '0'   then
		pass_check;

  	       ELSE
     		  fail_check;
               END IF;

	ELSE
	   fail_check;
  	END IF;  /* end of length check */
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_account_il');
END IF;

END CE_VALIDATE_ACCOUNT_IL;
/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_ACCOUNT_NZ(Xi_ACCOUNT_NUMBER  in varchar2,
                                      Xi_ACCOUNT_SUFFIX	in varchar2,
					Xi_VALIDATION_TYPE in varchar2)
                                      AS
account_value varchar2(30);
account_suffix varchar2(30);
numeric_result varchar2(40);

		/*******************************/
	   	/* SUB FUNCTIONS and PROCEDURES*/
	 	/*******************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_ACCOUNT_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_ACCOUNT_NZ: ' || 'CE_INVALID_ACCOUNT_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin
 IF l_DEBUG in ('Y', 'C') THEN
 	cep_standard.debug('CE_VALIDATE_ACCOUNT_NZ: ' || 'pass_check');
 END IF;

end pass_check;

procedure fail_account_suffix_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_ACCOUNT_SUFFIX');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_ACCOUNT_NZ: ' || 'CE_INVALID_ACCOUNT_SUFFIX');
   END IF;
end fail_account_suffix_check;

procedure pass_account_suffix_check is
begin
 IF l_DEBUG in ('Y', 'C') THEN
 	cep_standard.debug('CE_VALIDATE_ACCOUNT_NZ: ' || 'pass_check');
 END IF;

end pass_account_suffix_check;
                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_nz');
END IF;
  -- check account number
	account_value := upper(Xi_ACCOUNT_NUMBER );

	account_value := replace(account_value,' ','');
	account_value := replace(account_value,'-','');


  	IF length(account_value) <= 8 and  length(account_value) >= 6 THEN
	    numeric_result := ce_check_numeric(ACCOUNT_VALUE,1,length(ACCOUNT_VALUE));

	      IF numeric_result = '0'   then
		pass_check;

  	       ELSE
     		  fail_check;
               END IF;

	ELSE
	   fail_check;
  	END IF;  /* end of length check */

 -- check account_suffix
IF (Xi_VALIDATION_TYPE = 'ALL') THEN
	account_suffix := upper(Xi_ACCOUNT_SUFFIX );

	account_suffix := replace(account_suffix,' ','');
	account_suffix := replace(account_suffix,'-','');


  	IF length(account_suffix) = 3 THEN
	    numeric_result := ce_check_numeric(ACCOUNT_SUFFIX,1,length(ACCOUNT_SUFFIX));

	      IF numeric_result = '0'   then
		pass_account_suffix_check;

  	       ELSE
     		  fail_account_suffix_check;
               END IF;

	ELSE
	   fail_account_suffix_check;
  	END IF;  /* end of length check */
END IF;


IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_account_nz');
END IF;

END CE_VALIDATE_ACCOUNT_NZ;
/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_ACCOUNT_JP(Xi_ACCOUNT_NUMBER  in varchar2,
					Xi_ACCOUNT_TYPE  in varchar2 ,
					Xi_VALIDATION_TYPE in varchar2)
                                      AS
account_value varchar2(30);
numeric_result varchar2(40);

		/*******************************/
	   	/* SUB FUNCTIONS and PROCEDURES*/
	 	/*******************************/

procedure fail_mandatory is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_ACCOUNT_NUM');
   fnd_msg_pub.add;
   fnd_msg_pub.add_detail(fnd_msg_pub.g_warning_msg);

end fail_mandatory;

procedure fail_account_type is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_ACCOUNT_TYPE');
   fnd_msg_pub.add;
   fnd_msg_pub.add_detail(fnd_msg_pub.g_warning_msg);

end fail_account_type;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_account_jp');
END IF;

IF (Xi_ACCOUNT_NUMBER is null)  THEN
  fail_mandatory;
END if;

IF (Xi_VALIDATION_TYPE = 'ALL') THEN
  IF (Xi_ACCOUNT_TYPE  is null)  THEN
    fail_account_type;
  END if;
END IF;

IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_account_il');
END IF;

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

procedure CE_VALIDATE_BANK_ES (Xi_BANK_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2)
                                      AS
BANK_VALUE varchar2(30);

numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

/*Bug Fix:880887*/
/*Changed the Xo_RET_VAR='F' to 'W' ,in 'fail_mandatory' and 'fail_check'*/
/*so that a warning message is displayed*/
/*for spain instead of Error message*/
procedure fail_mandatory is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_BANK_NUM');
   fnd_msg_pub.add;
   fnd_msg_pub.add_detail(fnd_msg_pub.g_warning_msg);

end fail_mandatory;

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BANK_NUM');
   fnd_msg_pub.add;
   fnd_msg_pub.add_detail(fnd_msg_pub.g_warning_msg);
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_ES: ' || 'CE_INVALID_BANK_NUM');
   END IF;

end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_BANK_ES: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_es');
END IF;

BANK_VALUE := upper(Xi_BANK_NUMBER );
Xo_VALUE_OUT := BANK_VALUE;

IF Xi_PASS_MAND_CHECK = 'F'
  then
    fail_mandatory;

ELSIF Xi_PASS_MAND_CHECK = 'P'
  then

BANK_VALUE := replace(BANK_VALUE,' ','');

  IF length(BANK_VALUE) < 5
   then
   BANK_VALUE := lpad(BANK_VALUE,4,0);
      numeric_result := ce_check_numeric(BANK_VALUE,1,length(BANK_VALUE));

    IF numeric_result = '0'
       then
             /* its numeric so continue  */
       Xo_VALUE_OUT := BANK_VALUE;
       pass_check;
    ELSE
       fail_check;

    END IF;  /* end of numeric check */

  ELSE
   fail_check;

  END IF;  /* end of length check */
END IF; /* end of mandatory check  */
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_es');
END IF;
*/
END CE_VALIDATE_BANK_ES;


/****************     End of Procedure CE_VALIDATE_BANK_ES   ***********/


procedure CE_VALIDATE_BANK_FR(Xi_BANK_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2)
                                      AS
BANK_VALUE varchar2(30);

numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_mandatory is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_BANK_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_FR: ' || 'CE_ENTER_BANK_NUM');
   END IF;
end fail_mandatory;

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BANK_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_FR: ' || 'CE_INVALID_BANK_NUM');
   END IF;

end fail_check;

procedure pass_check is
begin
 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_BANK_FR: ' || 'pass_check');
 END IF;

end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_fr');
END IF;

BANK_VALUE := upper(Xi_BANK_NUMBER );
Xo_VALUE_OUT := BANK_VALUE;

IF Xi_PASS_MAND_CHECK = 'F'
  then
    fail_mandatory;

ELSIF Xi_PASS_MAND_CHECK = 'P'
  then

BANK_VALUE := replace(BANK_VALUE,' ','');

  IF length(BANK_VALUE) < 6
   then
   BANK_VALUE := lpad(BANK_VALUE,5,0);
      numeric_result := ce_check_numeric(BANK_VALUE,1,length(BANK_VALUE));

    IF numeric_result = '0'
       then
             /* its numeric so continue  */
       Xo_VALUE_OUT := BANK_VALUE;
       pass_check;
    ELSE
       fail_check;

    END IF;  /* end of numeric check */

  ELSE
   fail_check;

  END IF;  /* end of length check */
END IF; /* end of mandatory check  */
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_fr');
END IF;
*/
END CE_VALIDATE_BANK_FR;


/****************     End of Procedure CE_VALIDATE_BANK_FR   ***********/

procedure CE_VALIDATE_BANK_PT(Xi_BANK_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2)
                                      AS
BANK_VALUE varchar2(30);
numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_mandatory is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_BANK_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_PT: ' || 'CE_ENTER_BANK_NUM');
   END IF;
end fail_mandatory;

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BANK_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_PT: ' || 'CE_INVALID_BANK_NUM');
   END IF;

end fail_check;

procedure pass_check is
begin
 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_BANK_PT: ' || 'pass_check');
 END IF;

end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_pt');
END IF;


BANK_VALUE := upper(Xi_BANK_NUMBER );

IF Xi_PASS_MAND_CHECK = 'F'
  then
    fail_mandatory;

ELSIF Xi_PASS_MAND_CHECK = 'P'
  then

  BANK_VALUE := replace(BANK_VALUE,' ','');

  IF length(BANK_VALUE) = 4
   then
      numeric_result := ce_check_numeric(BANK_VALUE,1,length(BANK_VALUE));

    IF numeric_result = '0'
       then /* its numeric so continue  */
       pass_check;
    ELSE
       fail_check;

    END IF;  /* end of numeric check */

  ELSE
   fail_check;

  END IF;  /* end of length check */
END IF; /* end of mandatory check  */
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_pt');
END IF;

END CE_VALIDATE_BANK_PT;

/****************     End of Procedure CE_VALIDATE_BANK_PT   ***********/

procedure CE_VALIDATE_BANK_BR(Xi_BANK_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2)
                                      AS
BANK_VALUE varchar2(30);

numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_mandatory is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_BANK_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_BR: ' || 'CE_ENTER_BANK_NUM');
   END IF;
end fail_mandatory;

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BANK_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_BR: ' || 'CE_INVALID_BANK_NUM');
   END IF;
end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_BANK_BR: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_br');
END IF;

BANK_VALUE := upper(Xi_BANK_NUMBER );
Xo_VALUE_OUT := BANK_VALUE;

IF Xi_PASS_MAND_CHECK = 'F'
  then
    fail_mandatory;

ELSIF Xi_PASS_MAND_CHECK = 'P'
  then

   BANK_VALUE := replace(BANK_VALUE,' ','');

     IF length(BANK_VALUE) < 4
       then
         BANK_VALUE := lpad(BANK_VALUE,3,0);
         numeric_result := ce_check_numeric(BANK_VALUE,1,length(BANK_VALUE));

       IF numeric_result = '0'
        then
                /* its numeric so continue  */
          Xo_VALUE_OUT := BANK_VALUE;
          pass_check;
       ELSE
          fail_check;

       END IF;  /* end of numeric check for bank */

     ELSE
      fail_check;

     END IF;  /* end of length check for bank */

END IF; /* end of mandatory check  */
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_br');
END IF;
*/
END CE_VALIDATE_BANK_BR;

/* -------------------------------------------------------------------- */

-- new bank validations 5/14/02

procedure CE_VALIDATE_BANK_DE(Xi_BANK_NUMBER  in varchar2)
                                      AS
BANK_NUM varchar2(30);
numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BANK_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_DE: ' || 'CE_INVALID_BANK_NUM');
   END IF;

end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_BANK_DE: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_de');
END IF;

BANK_NUM := upper(replace(Xi_BANK_NUMBER,' ',''));

BANK_NUM := replace(BANK_NUM,'-','');

  IF (BANK_NUM) is not null then
    IF length(BANK_NUM) = 8  then
       numeric_result := ce_check_numeric(BANK_NUM,1,length(BANK_NUM));

      IF numeric_result = '0'
        then /* its numeric so continue  */
        pass_check;
      ELSE
 	IF l_DEBUG in ('Y', 'C') THEN
 		cep_standard.debug('bank num is not numeric');
 	END IF;
        fail_check;
      END IF;  /* end of numeric check */
    ELSE
 	IF l_DEBUG in ('Y', 'C') THEN
 		cep_standard.debug('bank num length is not 8');
 	END IF;
      fail_check;

    END IF;  /* end of numeric check */

  ELSE
    pass_check;

  END IF;  /* end of length check */
/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_de');
END IF;
*/
END CE_VALIDATE_BANK_DE;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BANK_GR(Xi_BANK_NUMBER  in varchar2)
                                      AS
BANK_VALUE varchar2(30);
numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BANK_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_GR: ' || 'CE_INVALID_BANK_NUM');
   END IF;

end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_BANK_GR: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_gr');
	END IF;

BANK_VALUE := upper(replace(Xi_BANK_NUMBER,' ',''));

BANK_VALUE := replace(BANK_VALUE,'-','');

IF (BANK_VALUE) is not null then

  IF length(BANK_VALUE) < 4
   then
      numeric_result := ce_check_numeric(BANK_VALUE,1,length(BANK_VALUE));

    IF numeric_result = '0'
       then /* its numeric so continue  */
       pass_check;
    ELSE
       fail_check;

    END IF;  /* end of numeric check */

  ELSE
   fail_check;

  END IF;  /* end of length check */

ELSE
  pass_check;

END IF;
/*
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_gr');
	END IF;
*/
END CE_VALIDATE_BANK_GR;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BANK_IS(Xi_BANK_NUMBER  in varchar2,
                              Xo_VALUE_OUT OUT NOCOPY varchar2)
                                      AS
BANK_NUM varchar2(60);
numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BANK_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_IS: ' || 'CE_INVALID_BANK_NUM');
   END IF;

end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_BANK_IS: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_is');
	END IF;

BANK_NUM := upper(replace(Xi_BANK_NUMBER,' ',''));

BANK_NUM := replace(BANK_NUM,'-','');

  IF (BANK_NUM) is not null then
    IF length(BANK_NUM) < 5  then
       numeric_result := ce_check_numeric(BANK_NUM,1,length(BANK_NUM));

      IF numeric_result = '0'
        then /* its numeric so continue  */

        Xo_VALUE_OUT := lpad(bank_num,4,0);
        pass_check;
      ELSE
        fail_check;
      END IF;  /* end of numeric check */
    ELSE
      fail_check;

    END IF;  /* end of length check */

  ELSE
    pass_check;

  END IF;
/*
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_is');
	END IF;
*/
END CE_VALIDATE_BANK_IS;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BANK_IE(Xi_BANK_NUMBER  in varchar2)
                                      AS
BANK_NUM varchar2(60);
numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BANK_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_IE: ' || 'CE_INVALID_BANK_NUM');
   END IF;

end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_BANK_IE: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_ie');
	END IF;

BANK_NUM := upper(replace(Xi_BANK_NUMBER,' ',''));

BANK_NUM := replace(BANK_NUM,'-','');

  IF (BANK_NUM) is not null then
    IF length(BANK_NUM) = 8  then
       numeric_result := ce_check_numeric(BANK_NUM,1,length(BANK_NUM));

      IF numeric_result = '0'
        then /* its numeric so continue  */
        pass_check;
      ELSE
        fail_check;
      END IF;  /* end of numeric check */
    ELSE
      fail_check;

    END IF;  /* end of length check */

  ELSE
    pass_check;

  END IF;
/*
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_ie');
	END IF;
*/
END CE_VALIDATE_BANK_IE;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BANK_IT(Xi_BANK_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2)
                                      AS
BANK_VALUE varchar2(30);

numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_mandatory is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_BANK_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_IT: ' || 'CE_ENTER_BANK_NUM');
   END IF;
end fail_mandatory;

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BANK_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_IT: ' || 'CE_INVALID_BANK_NUM');
   END IF;

end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_BANK_IT: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_it');
	END IF;

BANK_VALUE := upper(replace(Xi_BANK_NUMBER,' ',''));

BANK_VALUE := replace(BANK_VALUE,'-','');


IF Xi_PASS_MAND_CHECK = 'F'
  then
    fail_mandatory;

ELSIF Xi_PASS_MAND_CHECK = 'P'
  then

BANK_VALUE := replace(BANK_VALUE,' ','');

  IF length(BANK_VALUE) = 5
   then

      numeric_result := ce_check_numeric(BANK_VALUE,1,length(BANK_VALUE));

    IF numeric_result = '0'
       then
             /* its numeric so continue  */

       pass_check;
    ELSE
       fail_check;

    END IF;  /* end of numeric check */

  ELSE
   fail_check;

  END IF;  /* end of length check */
END IF; /* end of mandatory check  */

/*
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_it');
	END IF;
*/
END CE_VALIDATE_BANK_IT;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BANK_LU(Xi_BANK_NUMBER  in varchar2)
                                      AS
BANK_NUM varchar2(60);
numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BANK_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_LU: ' || 'CE_INVALID_BANK_NUM');
   END IF;

end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_BANK_LU: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_lu');
	END IF;

BANK_NUM := upper(replace(Xi_BANK_NUMBER,' ',''));

BANK_NUM := replace(BANK_NUM,'-','');

  IF (BANK_NUM) is not null then
    IF length(BANK_NUM) = 2  then
       numeric_result := ce_check_numeric(BANK_NUM,1,length(BANK_NUM));

      IF numeric_result = '0'
        then /* its numeric so continue  */
        pass_check;
      ELSE
        fail_check;
      END IF;  /* end of numeric check */
    ELSE
      fail_check;

    END IF;  /* end of length check */

  ELSE
    pass_check;

  END IF;
/*
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_lu');
	END IF;
*/
END CE_VALIDATE_BANK_LU;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BANK_PL(Xi_BANK_NUMBER  in varchar2)
                                      AS
BANK_NUM varchar2(60);
numeric_result varchar2(40);
cal_cd1  number;
                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BANK_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_PL: ' || 'CE_INVALID_BANK_NUM');
   END IF;

end fail_check;


procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_BANK_PL: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_pl');
	END IF;

BANK_NUM := upper(replace(Xi_BANK_NUMBER,' ',''));

BANK_NUM := replace(BANK_NUM,'-','');

  IF (BANK_NUM) is not null then
    IF length(BANK_NUM) = 8  then
       numeric_result := ce_check_numeric(BANK_NUM,1,length(BANK_NUM));

      IF numeric_result = '0'
        then /* its numeric so continue  */

	-- Modulus 10

	cal_cd1 := 10 - mod(((to_number(substr(BANK_NUM,1,1)) * 1)
        	         +(to_number(substr(BANK_NUM,2,1)) * 7)
                	 +(to_number(substr(BANK_NUM,3,1)) * 9)
                 	 +(to_number(substr(BANK_NUM,4,1)) * 3)
                 	 +(to_number(substr(BANK_NUM,5,1)) * 1)
                 	 +(to_number(substr(BANK_NUM,6,1)) * 7)
                 	 +(to_number(substr(BANK_NUM,7,1)) * 9)),10);

	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('cal_cd1: '|| cal_cd1);
	END IF;

        IF cal_cd1 = substr(BANK_NUM,8,1) then
		pass_check;
	else
       		fail_check;
        end if;

      ELSE
        fail_check;
      END IF;  /* end of numeric check */
    ELSE
      fail_check;

    END IF;  /* end of length check */

  ELSE
    pass_check;

  END IF;
/*
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_pl');
	END IF;
*/
END CE_VALIDATE_BANK_PL;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BANK_SE(Xi_BANK_NUMBER  in varchar2)
                                      AS
BANK_NUM varchar2(60);
numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BANK_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_SE: ' || 'CE_INVALID_BANK_NUM');
   END IF;

end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_BANK_SE: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_se');
	END IF;

BANK_NUM := upper(replace(Xi_BANK_NUMBER,' ',''));

BANK_NUM := replace(BANK_NUM,'-','');

  IF (BANK_NUM) is not null then
    IF ((length(BANK_NUM) = 4) or (length(BANK_NUM) = 5))  then
       numeric_result := ce_check_numeric(BANK_NUM,1,length(BANK_NUM));

      IF numeric_result = '0'
        then /* its numeric so continue  */
        pass_check;
      ELSE
        fail_check;
      END IF;  /* end of numeric check */
    ELSE
      fail_check;

    END IF;  /* end of length check */

  ELSE
    pass_check;

  END IF;
/*
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_se');
	END IF;
*/
END CE_VALIDATE_BANK_SE;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BANK_CH(Xi_BANK_NUMBER  in varchar2)
                                      AS
BANK_NUM varchar2(60);
numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BANK_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_CH: ' || 'CE_INVALID_BANK_NUM');
   END IF;

end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_BANK_CH: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_ch');
	END IF;

BANK_NUM := upper(replace(Xi_BANK_NUMBER,' ',''));

BANK_NUM := replace(BANK_NUM,'-','');

  IF (BANK_NUM) is not null then
    IF ((length(BANK_NUM) > 2) and (length(BANK_NUM) < 6))  then
       numeric_result := ce_check_numeric(BANK_NUM,1,length(BANK_NUM));

      IF numeric_result = '0'
        then /* its numeric so continue  */
        pass_check;
      ELSE
        fail_check;
      END IF;  /* end of numeric check */
    ELSE
      fail_check;

    END IF;  /* end of length check */

  ELSE
    pass_check;

  END IF;
/*
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_ch');
	END IF;
*/
END CE_VALIDATE_BANK_CH;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BANK_GB(Xi_BANK_NUMBER  in varchar2)
                                      AS
BANK_NUM varchar2(60);
numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BANK_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_GB: ' || 'CE_INVALID_BANK_NUM');
   END IF;

end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_BANK_GB: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_gb');
	END IF;

BANK_NUM := upper(replace(Xi_BANK_NUMBER,' ',''));

BANK_NUM := replace(BANK_NUM,'-','');

  IF (BANK_NUM) is not null then
    IF length(BANK_NUM) = 6  then
       numeric_result := ce_check_numeric(BANK_NUM,1,length(BANK_NUM));

      IF numeric_result = '0'
        then /* its numeric so continue  */
        pass_check;
      ELSE
        fail_check;
      END IF;  /* end of numeric check */
    ELSE
      fail_check;

    END IF;  /* end of length check */

  ELSE
    pass_check;

  END IF;
/*
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.ce_validate_bank_gb');
	END IF;
*/
END CE_VALIDATE_BANK_GB;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BANK_CO(Xi_COUNTRY_NAME in varchar2,
				Xi_BANK_NAME  in varchar2,
				Xi_TAX_PAYER_ID  in varchar2)
                                      AS
tax_id varchar2(60);
tax_id1 varchar2(60);
tax_id_end number;

tax_id_cd_start number;
tax_id_cd varchar2(60);

numeric_result varchar2(40);

l_supp	varchar(10);
l_comp	varchar(10);
l_cust	varchar(10);
l_bank	varchar(10);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_TAX_PAYER_ID');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_CO: ' || 'CE_INVALID_TAX_PAYER_ID');
   END IF;

end fail_check;

procedure fail_check_unique is
begin
   fnd_message.set_name ('CE', 'CE_TAX_PAYER_ID_NOT_UNIQUE');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_CO: ' || 'CE_TAX_PAYER_ID_NOT_UNIQUE');
   END IF;

end fail_check_unique;

procedure fail_check_required is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_TAX_PAYER_ID');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_CO: ' || 'CE_ENTER_TAX_PAYER_ID');
   END IF;

end fail_check_required;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
  	null;
 	--	cep_standard.debug('CE_VALIDATE_BANK_CO: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN

IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BANK_CO');
END IF;

-- the last digit of tax payer id is the check digits

TAX_ID1 := upper(replace(Xi_TAX_PAYER_ID,' ',''));
TAX_ID1 := replace(TAX_ID1,'-','');
tax_id_end := (length(tax_id1) - 1);
tax_id := substr(tax_id1,1, tax_id_end);

tax_id_cd_start := (length(tax_id1));
tax_id_cd := substr(tax_id1, tax_id_cd_start, length(tax_id1));

IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('tax_id_cd:  ' || tax_id_cd || ' tax_id: ' || tax_id   );
END IF;

  IF (tax_id) is not null then
    IF length(tax_id) <= 14  then
       numeric_result := ce_check_numeric(tax_id,1,length(tax_id));

      IF numeric_result = '0'
        then /* its numeric so continue  */
         if CE_VALIDATE_BANKINFO_UPG.CE_VAL_UNIQUE_TAX_PAYER_ID(Xi_COUNTRY_NAME,TAX_ID) = 'FALSE' then
        	IF l_DEBUG in ('Y', 'C') THEN
        		cep_standard.debug('failed CE_VAL_UNIQUE_TAX_PAYER_ID' );
        	END IF;
		fail_check_unique;
	 else
	    CE_VALIDATE_BANKINFO_UPG.CE_CHECK_CROSS_MODULE_TAX_ID(Xi_COUNTRY_NAME,
				Xi_BANK_NAME,
				TAX_ID,
				l_cust,
				l_supp,
				l_comp,
				l_bank);

        IF l_DEBUG in ('Y', 'C') THEN
        	cep_standard.debug('l_cust: '|| l_cust ||' l_supp: '|| l_supp ||
  			' l_comp: '|| l_comp ||' l_bank: '|| l_bank );
        END IF;


     	    IF (l_supp  = 'bk3' OR l_cust='bk2' OR l_comp = 'bk1')THEN
               --FND_MESSAGE.SET_NAME('JG','JG_ZZ_PRIMARYID_NUM_EXIST');
               FND_MESSAGE.SET_NAME('CE','CE_TAXID_EXIST');
	       fnd_msg_pub.add;
            END IF;
            IF (l_supp = 'bk5') THEN
	       --FND_MESSAGE.SET_NAME('JG','JG_ZZ_TAXID_BANK_EXIST_AS_SUPP');
	       FND_MESSAGE.SET_NAME('CE','CE_TAXID_BANK_EXIST_AS_SUPP');
	       fnd_msg_pub.add;
            END IF;
            IF (l_cust = 'bk4') THEN
	       --FND_MESSAGE.SET_NAME('JG','JG_ZZ_TAXID_BANK_EXIST_AS_CUST');
	       FND_MESSAGE.SET_NAME('CE','CE_TAXID_BANK_EXIST_AS_CUST');
	       fnd_msg_pub.add;
            END IF;
            IF (l_comp = 'bk6') THEN
	      --FND_MESSAGE.SET_NAME('JG','JG_ZZ_TAXID_BANK_EXIST_AS_COMP');
	       FND_MESSAGE.SET_NAME('CE','CE_TAXID_BANK_EXIST_AS_COMP');
	       fnd_msg_pub.add;
            END IF;
            IF CE_VALIDATE_BANKINFO_UPG.CE_TAX_ID_CHECK_ALGORITHM(TAX_ID,Xi_COUNTRY_NAME,TAX_ID_CD) = 'FALSE' then
        	IF l_DEBUG in ('Y', 'C') THEN
        		cep_standard.debug('failed CE_TAX_ID_CHECK_ALGORITHM' );
        	END IF;
		fail_check;
	    END IF;

	 end if;
      ELSE
        fail_check;
      END IF;  /* end of numeric check */
    ELSE
      fail_check;

    END IF;  /* end of length check */

  ELSE  --tax payer id is required
    fail_check_required;

  END IF;

/*
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('<<CE_VALIDATE_BANKINFO_UPG.CE_VALIDATE_BANK_CO');
END IF;
*/
END CE_VALIDATE_BANK_CO;

--Added 10/19/04

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BANK_AU(Xi_BANK_NUMBER  in varchar2)
                                      AS
BANK_NUM varchar2(60);
numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BANK_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_AU: ' || 'CE_INVALID_BANK_NUM');
   END IF;

end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
 	cep_standard.debug('CE_VALIDATE_BANK_AU: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bank_au');
	END IF;

BANK_NUM := upper(replace(Xi_BANK_NUMBER,' ',''));

BANK_NUM := replace(BANK_NUM,'-','');

  IF (BANK_NUM) is not null then
    IF length(BANK_NUM) = 2 or length(BANK_NUM) = 3  then
       numeric_result := ce_check_numeric(BANK_NUM,1,length(BANK_NUM));

      IF numeric_result = '0'
        then /* its numeric so continue  */
        pass_check;
      ELSE
        fail_check;
      END IF;  /* end of numeric check */
    ELSE
      fail_check;

    END IF;  /* end of length check */

  ELSE
    pass_check;

  END IF;
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_bank_au');
	END IF;

END CE_VALIDATE_BANK_AU;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BANK_IL(Xi_BANK_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2)
                                      AS
BANK_VALUE varchar2(30);

numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_mandatory is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_BANK_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_IL: ' || 'CE_ENTER_BANK_NUM');
   END IF;
end fail_mandatory;

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BANK_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_IL: ' || 'CE_INVALID_BANK_NUM');
   END IF;

end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
 	cep_standard.debug('CE_VALIDATE_BANK_IL: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bank_il');
	END IF;

BANK_VALUE := upper(replace(Xi_BANK_NUMBER,' ',''));

BANK_VALUE := replace(BANK_VALUE,'-','');


IF Xi_PASS_MAND_CHECK = 'F'
  then
    fail_mandatory;

ELSIF Xi_PASS_MAND_CHECK = 'P'
  then

BANK_VALUE := replace(BANK_VALUE,' ','');

  IF length(BANK_VALUE) <= 2
   then

      numeric_result := ce_check_numeric(BANK_VALUE,1,length(BANK_VALUE));

    IF numeric_result = '0'
       then
             /* its numeric so continue  */

       pass_check;
    ELSE
       fail_check;

    END IF;  /* end of numeric check */

  ELSE
   fail_check;

  END IF;  /* end of length check */
END IF; /* end of mandatory check  */

	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_bank_il');
	END IF;

END CE_VALIDATE_BANK_IL;


/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BANK_NZ(Xi_BANK_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2)
                                      AS
BANK_VALUE varchar2(30);

numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_mandatory is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_BANK_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_NZ: ' || 'CE_ENTER_BANK_NUM');
   END IF;
end fail_mandatory;

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BANK_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_NZ: ' || 'CE_INVALID_BANK_NUM');
   END IF;

end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
 	cep_standard.debug('CE_VALIDATE_BANK_NZ: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bank_nz');
	END IF;

BANK_VALUE := upper(replace(Xi_BANK_NUMBER,' ',''));

BANK_VALUE := replace(BANK_VALUE,'-','');


IF Xi_PASS_MAND_CHECK = 'F'
  then
    fail_mandatory;

ELSIF Xi_PASS_MAND_CHECK = 'P'
  then

BANK_VALUE := replace(BANK_VALUE,' ','');

  IF length(BANK_VALUE) = 2
   then

      numeric_result := ce_check_numeric(BANK_VALUE,1,length(BANK_VALUE));

    IF numeric_result = '0'
       then
             /* its numeric so continue  */

       pass_check;
    ELSE
       fail_check;

    END IF;  /* end of numeric check */

  ELSE
   fail_check;

  END IF;  /* end of length check */
END IF; /* end of mandatory check  */

	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_bank_nz');
	END IF;


END CE_VALIDATE_BANK_NZ;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_BANK_JP(Xi_BANK_NUMBER  in varchar2,
				Xi_BANK_NAME_ALT  in varchar2,
                                Xi_PASS_MAND_CHECK in varchar2,
					Xi_VALIDATION_TYPE in varchar2)
                                      AS
BANK_VALUE varchar2(30);

numeric_result varchar2(40);

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_mandatory is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_BANK_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_JP: ' || 'CE_ENTER_BANK_NUM');
   END IF;
end fail_mandatory;

procedure fail_bank_name_alt is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_BANK_NAME_ALT');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_JP: ' || 'CE_ENTER_BANK_NAME_ALT');
   END IF;
end fail_bank_name_alt;


procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_BANK_NUM');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANK_JP: ' || 'CE_INVALID_BANK_NUM');
   END IF;

end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
 	cep_standard.debug('CE_VALIDATE_BANK_JP: ' || 'pass_check');
 END IF;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/
BEGIN
	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('>>CE_VALIDATE_BANKINFO.ce_validate_bank_jp');
	END IF;

BANK_VALUE := upper(replace(Xi_BANK_NUMBER,' ',''));

BANK_VALUE := replace(BANK_VALUE,'-','');


IF Xi_PASS_MAND_CHECK = 'F'
  then
    fail_mandatory;

ELSIF Xi_PASS_MAND_CHECK = 'P'
  then

BANK_VALUE := replace(BANK_VALUE,' ','');

  IF length(BANK_VALUE) = 3
   then

      numeric_result := ce_check_numeric(BANK_VALUE,1,length(BANK_VALUE));

    IF numeric_result = '0'
       then
             /* its numeric so continue  */

       pass_check;
    ELSE
       fail_check;

    END IF;  /* end of numeric check */

  ELSE
   fail_check;

  END IF;  /* end of length check */
END IF; /* end of mandatory check  */

IF (Xi_VALIDATION_TYPE = 'ALL') THEN
  IF (Xi_BANK_NAME_ALT is null) THEN
	fail_bank_name_alt;
  END IF;
END IF;

	IF l_DEBUG in ('Y', 'C') THEN
		cep_standard.debug('<<CE_VALIDATE_BANKINFO.ce_validate_bank_jp');
	END IF;


END CE_VALIDATE_BANK_JP;


-- added 10/25/04
/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_MISC_*   other misc validations
 --------------------------------------------------------------------- */

procedure CE_VALIDATE_MISC_EFT_NUM(X_COUNTRY_NAME    	in varchar2,
				X_EFT_NUMBER   	in varchar2,
			     	p_init_msg_list    	IN  VARCHAR2 := FND_API.G_FALSE,
    			     	x_msg_count      	OUT NOCOPY NUMBER,
			     	x_msg_data       	OUT NOCOPY VARCHAR2,
			     	x_return_status		IN OUT NOCOPY VARCHAR2)
                                            AS
COUNTRY_NAME   VARCHAR2(2);
EFT_NUM_VALUE  varchar2(60);
numeric_result varchar2(40);

procedure fail_mandatory is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_EFT_NUMBER');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_MISC_EFT_NUM: ' || 'CE_ENTER_EFT_NUMBER');
   END IF;
end fail_mandatory;

procedure fail_check is
begin
   fnd_message.set_name ('CE', 'CE_INVALID_EFT_NUMBER');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_MISC_EFT_NUM: ' || 'CE_INVALID_EFT_NUMBER');
   END IF;
end fail_check;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
 	cep_standard.debug('CE_VALIDATE_MISC_EFT_NUM: ' || 'pass_check');
 END IF;
end pass_check;


BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_VALIDATE_MISC_EFT_NUM');
END IF;

-- initialize API return status to success.
x_return_status := fnd_api.g_ret_sts_success;

COUNTRY_NAME  := X_COUNTRY_NAME;

IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('CE_VALIDATE_MISC_EFT_NUM - COUNTRY_NAME: '|| COUNTRY_NAME);
END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
END IF;

IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('CE_VALIDATE_MISC_EFT_NUM:  P_INIT_MSG_LIST: '|| P_INIT_MSG_LIST);
END IF;


EFT_NUM_VALUE := upper(replace(X_EFT_NUMBER,' ',''));

EFT_NUM_VALUE := replace(EFT_NUM_VALUE,'-','');

IF (COUNTRY_NAME = 'IL')
   THEN

  IF (EFT_NUM_VALUE is null) then
    fail_mandatory;
  ELSE
    IF length(EFT_NUM_VALUE) = 8   then

      numeric_result := ce_check_numeric(EFT_NUM_VALUE,1,length(EFT_NUM_VALUE));

      IF numeric_result = '0'      then
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

IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('CE_VALIDATE_BANKINFO.ce_validate_misc_eft_num - P_COUNT: '|| x_msg_count||
	--'P_DATA: '|| x_msg_data||
	--' X_VALUE_OUT: '|| X_VALUE_OUT||
	'<<CE_VALIDATE_BANKINFO.CE_VALIDATE_MISC_EFT_NUM');
END IF;

EXCEPTION
  WHEN OTHERS THEN
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANKINFO.CE_VALIDATE_MISC_EFT_NUM ' ||X_COUNTRY_NAME );
   END IF;

   FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
   fnd_message.set_token('PROCEDURE', 'CE_VALIDATE_BANKINFO.cd_validate_misc_eft_num');
       fnd_msg_pub.add;
       RAISE;
END CE_VALIDATE_MISC_EFT_NUM;

/* -------------------------------------------------------------------- */

procedure CE_VALIDATE_MISC_ACCT_HLDR_ALT(X_COUNTRY_NAME    in varchar2,
                                X_ACCOUNT_HOLDER_ALT 	in varchar2,
                             	X_ACCOUNT_CLASSIFICATION 	in varchar2,
			    	p_init_msg_list   	IN VARCHAR2 := FND_API.G_FALSE,
    			        x_msg_count      	OUT NOCOPY NUMBER,
			    	x_msg_data       	OUT NOCOPY VARCHAR2,
			    	x_return_status		IN OUT NOCOPY VARCHAR2)
                                            AS
COUNTRY_NAME   VARCHAR2(2);
ACCOUNT_HOLDER_ALT  varchar2(60);
numeric_result varchar2(40);


procedure fail_mandatory is
begin
   fnd_message.set_name ('CE', 'CE_ENTER_ACCOUNT_HOLDER_ALT');
   fnd_msg_pub.add;
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_MISC_ACCT_HLDR_ALT: ' || 'CE_ENTER_ACCOUNT_HOLDER_ALT');
   END IF;
end fail_mandatory;

procedure pass_check is
begin

 IF l_DEBUG in ('Y', 'C') THEN
 	cep_standard.debug('pass_check');
 END IF;
end pass_check;

BEGIN
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('>>CE_VALIDATE_BANKINFO.CE_VALIDATE_MISC_ACCT_HLDR_ALT');
END IF;

-- initialize API return status to success.
x_return_status := fnd_api.g_ret_sts_success;

COUNTRY_NAME  := X_COUNTRY_NAME;

IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('CE_VALIDATE_MISC_ACCT_HLDR_ALT - COUNTRY_NAME: '|| COUNTRY_NAME);
END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
END IF;

IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('CE_VALIDATE_MISC_ACCT_HLDR_ALT:  P_INIT_MSG_LIST: '|| P_INIT_MSG_LIST);
END IF;


ACCOUNT_HOLDER_ALT := X_ACCOUNT_HOLDER_ALT;


IF (COUNTRY_NAME = 'JP')
   THEN

  IF (ACCOUNT_HOLDER_ALT is null and X_ACCOUNT_CLASSIFICATION = 'INTERNAL') then
    fail_mandatory;

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

IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug('CE_VALIDATE_BANKINFO.ce_validate_misc_acct_hldr_alt - P_COUNT: '|| x_msg_count||
	--'P_DATA: '|| x_msg_data||
	--' X_VALUE_OUT: '|| X_VALUE_OUT||
	'<<CE_VALIDATE_BANKINFO.CE_VALIDATE_MISC_ACCT_HLDR_ALT');
END IF;

EXCEPTION
  WHEN OTHERS THEN
   IF l_DEBUG in ('Y', 'C') THEN
   	cep_standard.debug('CE_VALIDATE_BANKINFO.CE_VALIDATE_MISC_ACCT_HLDR_ALT ' ||X_COUNTRY_NAME );
   END IF;

   FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
   fnd_message.set_token('PROCEDURE', 'CE_VALIDATE_BANKINFO.cd_validate_misc_acct_hldr_alt');
       fnd_msg_pub.add;
       RAISE;

END CE_VALIDATE_MISC_ACCT_HLDR_ALT;

END CE_VALIDATE_BANKINFO_UPG;

/
