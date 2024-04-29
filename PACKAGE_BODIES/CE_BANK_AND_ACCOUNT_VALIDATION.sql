--------------------------------------------------------
--  DDL for Package Body CE_BANK_AND_ACCOUNT_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_BANK_AND_ACCOUNT_VALIDATION" AS
/*$Header: cebavalb.pls 120.18.12010000.4 2009/10/01 09:09:21 ckansara ship $ */

  l_DEBUG varchar2(1) := NVL(FND_PROFILE.value('CE_DEBUG'), 'N');
  --l_DEBUG varchar2(1) := 'Y';

  /*=======================================================================+
   | PUBLIC FUNCTION ce_check_numeric                                      |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Check if a value is numeric                                         |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     check_value                                                       |
   |     pos_from                                                          |
   |     pos_to                                                            |
   | RETURN VALUE                                                          |
   |     0         value return is numeric                                 |
   |     1         value return is alphanumeric                            |
   +=======================================================================*/
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


  /*=======================================================================+
   | PUBLIC PROCEDURE  validate_bank                                       |
   |   This procedure should be registered as the value of the profile     |
   |   option 'HZ_BANK_VALIDATION_PROCEDURE' in fnd_profile_option_values  |
   | DESCRIPTION                                                           |
   |   Dynamic bound validation routine. This procedure is called by TCA   |
   |   create_bank/update_bank API.                                        |
   |                                                                       |
   |   Validate:                                                           |
   |    1. Combination of Country and Bank Name is unique                  |
   |    2. Combination of Country and Short Bank Name is unique            |
   |       -- remove this 2nd validation due to upgrade changes            |
   |    3. Combination of Country and Bank Number is unique                |
   |                                                                       |
   |   Bug 6642215/6742860: Validation changed to check combination of     |
   |   bank name, number and country is unique.                            |
   |                                                                       |
   |   Bug 8572093 validation changes for 6642215 should only apply for    |
   |   upgraded banks. For banks created in R12, original validations will |
   |   apply.                                                              |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_temp_id in HZ_ORG_PROFILE_VAL_GT table                          |
   +=======================================================================*/
   PROCEDURE validate_bank (p_temp_id       IN  NUMBER,
                            x_return_status IN OUT NOCOPY VARCHAR2) IS
     l_bank_name_rowid     VARCHAR2(1000);
     l_short_name_rowid    VARCHAR2(1000);
     l_bank_number_rowid   VARCHAR2(1000);
     l_bank_name_exist     VARCHAR2(1);
     l_short_name_exist    VARCHAR2(1);
     l_bank_number_exist   VARCHAR2(1);
     l_bank_exist          VARCHAR2(1);
     l_country             VARCHAR2(60);
     l_bank_name           VARCHAR2(360);
     l_short_name          VARCHAR2(240) := NULL;
     l_short_name_null     VARCHAR2(1) := 'N';
     l_bank_number         VARCHAR2(60) := NULL;
     l_created_by          HZ_PARTIES.created_by_module%TYPE;

     /* records in HZ_BANK_VAL_GT and hz_org_profile_val_gt share the same temp_id */

     CURSOR c_country IS
       SELECT  country
       FROM    HZ_BANK_VAL_GT
       WHERE   temp_id = p_temp_id;

     CURSOR c_bank_number IS
       SELECT  bank_or_branch_number
       FROM    HZ_BANK_VAL_GT
       WHERE   temp_id = p_temp_id;

     CURSOR c_bank_name IS
       SELECT  organization_name
       FROM    hz_org_profile_val_gt
       WHERE   temp_id = p_temp_id;

     -- Bug 6742860/6642215: Added cursor to check for duplicate
     -- of combination of name-number-country.
     -- 8572093: This is used for validating banks upgraded from 11i.
       CURSOR c_bank_name_number_uk IS
       SELECT  'Y'
       FROM    hz_parties  BankParty,
               hz_organization_profiles  BankOrgProfile,
               hz_code_assignments   BankCA
       WHERE   BankParty.PARTY_TYPE = 'ORGANIZATION'
       AND     BankParty.status = 'A'
       AND     BankParty.PARTY_ID = BankOrgProfile.PARTY_ID
       AND     SYSDATE between TRUNC(BankOrgProfile.effective_start_date)
               and NVL(TRUNC(BankOrgProfile.effective_end_date), SYSDATE+1)
       AND     BankCA.CLASS_CATEGORY = 'BANK_INSTITUTION_TYPE'
       AND     BankCA.CLASS_CODE = 'BANK'
       AND     BankCA.OWNER_TABLE_NAME = 'HZ_PARTIES'
       AND     NVL(BankCA.STATUS, 'A') = 'A'
       AND     BankCA.OWNER_TABLE_ID = BankParty.PARTY_ID
       AND     BankOrgProfile.home_country = l_country
       AND     nvl(BankOrgProfile.bank_or_branch_number,'--NULL--') = nvl(l_bank_number,'--NULL--')
       AND     upper(BankParty.party_name) = upper(l_bank_name)
       AND     BankParty.party_id <> p_temp_id;

     -- 8572093: Cursors for checking uniqueness of banks created in R12
     CURSOR c_short_name IS
       SELECT  known_as
       FROM    hz_org_profile_val_gt
       WHERE   temp_id = p_temp_id;

     CURSOR c_bank_name_uk IS
       SELECT  'Y'
       FROM    hz_parties  BankParty,
               hz_code_assignments   BankCA,
           hz_organization_profiles  BankOrgProfile
       WHERE   BankParty.PARTY_TYPE = 'ORGANIZATION'
       AND     BankParty.status = 'A'
       AND     BankParty.PARTY_ID = BankOrgProfile.PARTY_ID
       AND     SYSDATE between TRUNC(BankOrgProfile.effective_start_date)
               and NVL(TRUNC(BankOrgProfile.effective_end_date), SYSDATE+1)
       AND     BankCA.CLASS_CATEGORY = 'BANK_INSTITUTION_TYPE'
       AND     BankCA.CLASS_CODE = 'BANK'
       AND     BankCA.OWNER_TABLE_NAME = 'HZ_PARTIES'
       AND     NVL(BankCA.STATUS, 'A') = 'A'
       AND     BankCA.OWNER_TABLE_ID = BankParty.PARTY_ID
       AND     BankOrgProfile.home_country = l_country
       AND     upper(BankParty.party_name) = upper(l_bank_name)
       AND     BankParty.party_id <> p_temp_id;

     CURSOR c_short_name_uk IS
       SELECT  'Y'
       FROM    hz_parties  BankParty,
               hz_code_assignments   BankCA,
               hz_organization_profiles  BankOrgProfile
       WHERE   BankParty.PARTY_TYPE = 'ORGANIZATION'
       AND     BankParty.status = 'A'
       AND     BankParty.PARTY_ID = BankOrgProfile.PARTY_ID
       AND     SYSDATE between TRUNC(BankOrgProfile.effective_start_date)
               and NVL(TRUNC(BankOrgProfile.effective_end_date), SYSDATE+1)
       AND     BankCA.CLASS_CATEGORY = 'BANK_INSTITUTION_TYPE'
       AND     BankCA.CLASS_CODE = 'BANK'
       AND     BankCA.OWNER_TABLE_NAME = 'HZ_PARTIES'
       AND     NVL(BankCA.STATUS, 'A') = 'A'
       AND     BankCA.OWNER_TABLE_ID = BankParty.PARTY_ID
       AND     BankOrgProfile.home_country = l_country
       AND     BankParty.known_as = l_short_name
       AND     BankParty.party_id <> p_temp_id;

     CURSOR c_bank_number_uk IS
       SELECT  'Y'
       FROM    hz_parties  BankParty,
               hz_organization_profiles  BankOrgProfile,
               hz_code_assignments   BankCA
       WHERE   BankParty.PARTY_TYPE = 'ORGANIZATION'
       AND     BankParty.status = 'A'
       AND     BankParty.PARTY_ID = BankOrgProfile.PARTY_ID
       AND     SYSDATE between TRUNC(BankOrgProfile.effective_start_date)
               and NVL(TRUNC(BankOrgProfile.effective_end_date), SYSDATE+1)
       AND     BankCA.CLASS_CATEGORY = 'BANK_INSTITUTION_TYPE'
       AND     BankCA.CLASS_CODE = 'BANK'
       AND     BankCA.OWNER_TABLE_NAME = 'HZ_PARTIES'
       AND     NVL(BankCA.STATUS, 'A') = 'A'
       AND     BankCA.OWNER_TABLE_ID = BankParty.PARTY_ID
       AND     BankOrgProfile.home_country = l_country
       AND     BankOrgProfile.bank_or_branch_number = l_bank_number
       AND     BankParty.party_id <> p_temp_id;

   BEGIN
     cep_standard.debug('CE_BANK_AND_ACCOUNT_VALIDATION.validate_bank (+)');

     /***** Fetching the bank country *****/
     OPEN  c_country;
     FETCH c_country INTO l_country;

     IF c_country%NOTFOUND THEN
        -- Close the cursor and raise an error if the country could not be
        -- found in the temp table HZ_BANK_VAL_GT.
        CLOSE c_country;

        fnd_message.set_name('CE', 'CE_TEMP_NOT_FOUND');
        fnd_message.set_token('COLUMN', 'Country');
        fnd_message.set_token('TABLE', 'HZ_BANK_VAL_GT');
        fnd_msg_pub.add;
        RAISE NO_DATA_FOUND;
      END IF;
     CLOSE c_country;

     -- 8572093: Check if bank was created by upgrade
     BEGIN
         SELECT created_by_module
         INTO l_created_by
         FROM hz_parties
         WHERE party_id = p_temp_id;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_created_by := 'CE';
     END;

     -- 8572093: For upgraded banks, check for name-number-country combination
     IF l_created_by = 'CE_BANK_UPGRADE'
     THEN
         cep_standard.debug('>> upgraded bank. checking name-number-country');
         OPEN  c_bank_name;
         FETCH c_bank_name INTO l_bank_name;
         IF c_bank_name%NOTFOUND THEN
            -- Close the cursor and raise an error if the org_name could not be
            -- found in the temp table hz_org_profile_val_gt.
            CLOSE c_bank_name;

            fnd_message.set_name('CE', 'CE_TEMP_NOT_FOUND');
            fnd_message.set_token('COLUMN', 'Organization_name');
            fnd_message.set_token('TABLE', 'HZ_ORG_PROFILE_VAL_GT');
            fnd_msg_pub.add;
            RAISE NO_DATA_FOUND;
          END IF;
         CLOSE c_bank_name;

         -- Fetching the bank Number
         OPEN  c_bank_number;
         FETCH c_bank_number INTO l_bank_number;
         IF c_bank_number%NOTFOUND THEN
            l_bank_number := null;
         END IF;
         CLOSE c_bank_number;

         -- if bank number is not entered in the UI it is being
         -- stored in the temp table as character with ascii value of
         -- zero. to check for this correcting value to null
         if ascii(l_bank_number) = 0 then
            l_bank_number := null;
         end if;

         -- Check for Bank Name-Number-Country Uniqueness
         OPEN  c_bank_name_number_uk;
         FETCH c_bank_name_number_uk INTO l_bank_exist;
         CLOSE c_bank_name_number_uk;

         -- If bank exists add message to error queue
         if l_bank_exist = 'Y' then
            fnd_message.set_name('CE', 'CE_DUP_BANK_NAME');
            fnd_msg_pub.add;
            x_return_status := fnd_api.G_RET_STS_ERROR;
         else
            x_return_status := fnd_api.G_RET_STS_SUCCESS;
         end if;

     ELSE
         -- 8572093: banks not created by upgrade
         -- do check for name-country, number-country, short_name-country
         cep_standard.debug('>> upgraded bank. checking name-number-country');
         -- Check uniquess of the combination of bank_name and country
         OPEN  c_bank_name;
         FETCH c_bank_name INTO l_bank_name;

         IF c_bank_name%NOTFOUND THEN
            -- Close the cursor and raise an error if the org_name could not be
            -- found in the temp table hz_org_profile_val_gt.
            CLOSE c_bank_name;

            fnd_message.set_name('CE', 'CE_TEMP_NOT_FOUND');
            fnd_message.set_token('COLUMN', 'Organization_name');
            fnd_message.set_token('TABLE', 'HZ_ORG_PROFILE_VAL_GT');
            fnd_msg_pub.add;
            RAISE NO_DATA_FOUND;
          END IF;
         CLOSE c_bank_name;

         OPEN  c_bank_name_uk;
         FETCH c_bank_name_uk INTO l_bank_name_exist;
         CLOSE c_bank_name_uk;


         -- Check uniquess of the combination of short bank_name and country --
         OPEN  c_short_name;
         FETCH c_short_name INTO l_short_name;

         if c_short_name%NOTFOUND then
          l_short_name_null := 'Y';
         end if;
         CLOSE c_short_name;

         if l_short_name_null <> 'Y' then

          OPEN  c_short_name_uk;
          FETCH c_short_name_uk INTO l_short_name_exist;
          CLOSE c_short_name_uk;
         end if;

         -- check uniquess of the combination of bank_number and country
         -- when bank_number is not null
         OPEN  c_bank_number;
         FETCH c_bank_number INTO l_bank_number;

         IF c_bank_number%NOTFOUND THEN
          -- Close the cursor. No other checks.
          CLOSE c_bank_number;
         ELSE
          CLOSE c_bank_number;

          OPEN  c_bank_number_uk;
          FETCH c_bank_number_uk INTO l_bank_number_exist;

          CLOSE c_bank_number_uk;
         END IF;

         IF l_bank_name_exist = 'Y' THEN
          fnd_message.set_name('CE', 'CE_DUP_BANK_NAME');
          fnd_msg_pub.add;
         END IF;

         if l_short_name_exist = 'Y' then
          fnd_message.set_name('CE', 'CE_DUP_SHORT_BANK_NAME');
          fnd_msg_pub.add;
         end if;

         if l_bank_number_exist = 'Y' then
          fnd_message.set_name('CE', 'CE_DUP_BANK_NUM');
          fnd_msg_pub.add;
         end if;

         if l_bank_name_exist = 'Y' OR l_short_name_exist = 'Y' OR l_bank_number_exist='Y' then
          --RAISE fnd_api.g_exc_error;
          x_return_status := fnd_api.G_RET_STS_ERROR;
         else
          x_return_status := fnd_api.G_RET_STS_SUCCESS;
         end if;
     END IF; -- IF (l_created_by = 'CE_BANK_UPGRADE')

   EXCEPTION
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
       FND_MESSAGE.Set_Token('PROCEDURE', 'CE_BANK_AND_ACCOUNT_VALIDATION.validate_bank');
       fnd_msg_pub.add;
       RAISE;
   END validate_bank;



  /*=======================================================================+
   | PUBLIC PROCEDURE validate_branch                                      |
   |   This procedure should be registered as the value of the profile     |
   |   option of 'HZ_BANK_BRANCH_VALIDATION_PROCEDURE' in                  |
   |   fnd_profile_option_values                                           |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Dynamic bound validation routine.                                   |
   |   The validation 'the combination of country, bank name, and branch   |
   |   name should be unique' is done in TCA's create_bank_branch API.     |
   |   This API will call the country specific validation APIs             |
   |   This procedure is called by TCA create_bank_branch/                 |
   |   update_bank_branch API                                              |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_temp_org_profile_id   temp_id in HZ_ORG_PROFILE_VAL_GT table    |
   +=======================================================================*/
   PROCEDURE validate_branch (p_temp_org_profile_id   IN  NUMBER,
                              x_return_status         IN OUT NOCOPY VARCHAR2) IS
   BEGIN
     NULL;
   END validate_branch;



  /*=======================================================================+
   | PUBLIC PROCEDURE validate_org                                         |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validate the org is a valid org in TCA/HR and satisfies             |
   |   MO security profile                                                 |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_org_name             name of org to be validated                |
   |     p_org_classification   HR_BG (Business Group)                     |
   |                            OPERATING_UNIT                             |
   |                            HR_LEGAL                                   |
   |     p_security_profile_id                                             |
   +=======================================================================*/
/*
   PROCEDURE validate_org (p_org_id                     IN  NUMBER,
                           p_org_classification         IN  VARCHAR2,
                           p_security_profile_id        IN  NUMBER,
			   x_out OUT NUMBER) IS    -- this param is only for testing needs to be taken out
    l_org_list  	VARCHAR2(4000);
    l_sub		VARCHAR2(4000);
    l_len       	NUMBER;
    l_pos       	NUMBER;
    l_org_id_str	VARCHAR2(30);
    l_found		VARCHAR2(1);
   BEGIN
      cep_standard.debug('CE_BANK_AND_ACCOUNT_VALIDATION.validate_org (+)');
      x_out := 1;
      l_found := 'N';

      l_org_list := MO_UTILS.get_org_list(p_security_profile_id, p_org_classification);
      IF l_org_list = '' THEN
        fnd_message.set_name('CE', 'CE_NO_ORG_FOR_MO_SP');
        fnd_msg_pub.add;
        return;
      END IF;

      l_sub := l_org_list;

      WHILE ( l_sub <> '@') LOOP
        l_len := LENGTH(l_sub);
        l_sub := substr(l_sub, 2, l_len-1);
        l_pos := instr(l_sub, '@');
        l_org_id_str := substr(l_sub, 1, l_pos-1);
        if  (TO_NUMBER(l_org_id_str) = p_org_id) then
          l_found := 'Y';
          l_sub := '@';
          x_out := 0;
        else
          l_sub := substr(l_sub, l_pos, l_len - l_pos);
        END IF;
        --l_sub := substr(l_sub, l_pos, l_len - l_pos);
      END LOOP;

      IF l_found = 'N' THEN
        fnd_message.set_name('CE', 'CE_INVALID_ORG_NAME');
        fnd_msg_pub.add;
      END IF;

   EXCEPTION
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
       FND_MESSAGE.Set_Token('PROCEDURE', 'CE_BANK_AND_ACCOUNT_VALIDATION.validate_org');
       fnd_msg_pub.add;
       RAISE;
   END validate_org;
*/


  /*=======================================================================+
   | PUBLIC PROCEDURE validate_currency                                    |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validate the currency_code is valid in FND_CURRENCIES               |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_currency_code                                                   |
   +=======================================================================*/
  PROCEDURE validate_currency (p_currency_code 	IN VARCHAR2,
			       x_return_status  IN OUT NOCOPY VARCHAR2) IS
    CURSOR c_currency IS
      SELECT  1
      FROM    fnd_currencies fc
      WHERE   fc.currency_code = p_currency_code;
    l_dummy   NUMBER := 0;
  BEGIN
    cep_standard.debug('CE_BANK_AND_ACCOUNT_VALIDATION.validate_currency (+)');

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    OPEN c_currency;
    FETCH c_currency INTO l_dummy;
    IF c_currency%NOTFOUND THEN
      fnd_message.set_name('CE', 'CE_BA_INVALID_CURRENCY');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;
    CLOSE c_currency;
  END validate_currency;


  /*=======================================================================+
   | PUBLIC PROCEDURE validate_account_name                                |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validate the account_name is unique within a branch                 |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_branch_id                                                       |
   |     p_account_name
   +=======================================================================*/
   PROCEDURE validate_account_name (p_branch_id         IN  NUMBER,
                                    p_account_name      IN  VARCHAR2,
				    p_account_id	IN  NUMBER,
				    x_return_status     IN OUT NOCOPY VARCHAR2) IS
     --l_rowid    VARCHAR2(1000);
     l_dummy    VARCHAR2(1);
/*
     CURSOR c_rowid IS
       SELECT  rowid
       FROM    ce_bank_accounts
       WHERE   bank_account_name = p_account_name
       AND     bank_branch_id = p_branch_id;
*/
     CURSOR c_acct_name IS
       SELECT  'X'
       FROM    ce_bank_accounts
       WHERE   bank_branch_id = p_branch_id
       AND     bank_account_name = p_account_name
       AND     bank_account_id <> NVL(p_account_id, -1);
       --AND     (rowid <> l_rowid  OR l_rowid IS NULL);

   BEGIN
     cep_standard.debug('CE_BANK_AND_ACCOUNT_VALIDATION.validate_account_name (+)');

     -- initialize API return status to success.
     x_return_status := fnd_api.g_ret_sts_success;
/*
     OPEN  c_rowid;
     FETCH c_rowid INTO l_rowid;
     CLOSE c_rowid;
*/
     OPEN  c_acct_name;
     FETCH c_acct_name INTO l_dummy;
     IF l_dummy = 'X' THEN
      fnd_message.set_name('CE', 'CE_DUP_ACCT_NAME');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
     END IF;
     CLOSE c_acct_name;

   EXCEPTION
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
       FND_MESSAGE.Set_Token('PROCEDURE', 'CE_BANK_AND_ACCOUNT_VALIDATION.validate_account_name');
       fnd_msg_pub.add;

   END validate_account_name;



  /*=======================================================================+
   | PUBLIC PROCEDURE validate_IBAN                                        |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validate IBAN according to IBAN validation rules                    |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_IBAN                                                            |
   |   OUT:                                                                |
   |     p_IBAN_OUT                                                        |
   +=======================================================================*/
   PROCEDURE validate_IBAN (p_IBAN         	IN  VARCHAR2,
			    p_IBAN_OUT     	OUT NOCOPY VARCHAR2,
			    x_return_status     IN OUT NOCOPY VARCHAR2 ) IS
     l_var     VARCHAR2(40);
     l_temp1   VARCHAR2(4);
     l_temp2   VARCHAR2(40);
     l_temp3   VARCHAR2(40);
     l_temp4   VARCHAR2(100);
     l_len     NUMBER;
     l_num     NUMBER;
     l_mod     NUMBER;
     l_str1_2   VARCHAR2(4);
     l_str3_4   VARCHAR2(40);
     new_IBAN  VARCHAR2(100);
   BEGIN
     cep_standard.debug('CE_BANK_AND_ACCOUNT_VALIDATION.validate_IBAN (+)');

     -- initialize API return status to success.
     x_return_status := fnd_api.g_ret_sts_success;

     -- step 1: remove spaces from the left and right only for p_IBAN
     --         spaces in the middle are not removed

     new_IBAN :=rtrim(ltrim(p_IBAN,' '),' ');
     p_IBAN_OUT := null;

     cep_standard.debug('p_IBAN='||p_IBAN);
     cep_standard.debug('new_IBAN='||new_IBAN);
     cep_standard.debug('p_IBAN_OUT='||p_IBAN_OUT);

     l_var := '9';
     l_len := LENGTH(new_IBAN);

     -- step 2: length <= 34
     --
     IF l_len > 34 THEN
       fnd_message.set_name('CE', 'CE_INVALID_IBAN_LEN'); -- Bug 8946879
       fnd_msg_pub.add;
       x_return_status := fnd_api.g_ret_sts_error;
     cep_standard.debug('validate_IBAN: CE_INVALID_IBAN_LEN'); -- Bug 8946879
     END IF;

     -- step 3
     -- bug 4350134
     -- 1) The first 2 characters are letters
     -- 2) The third and fourth characters are numbers
     l_str1_2 := SUBSTR(new_IBAN, 1, 2);
     l_str3_4 := upper(SUBSTR(new_IBAN, 3, 2));

     cep_standard.debug('l_str1_2='||l_str1_2);
     cep_standard.debug('l_str3_4='||l_str3_4);

     IF (TRANSLATE(l_str1_2, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', '99999999999999999999999999') <> '99') THEN
       fnd_message.set_name('CE', 'CE_IBAN_FIRST_2_CHAR');  -- Bug 8946879
       fnd_msg_pub.add;
       x_return_status := fnd_api.g_ret_sts_error;
       cep_standard.debug('validate_IBAN: CE_IBAN_FIRST_2_CHAR l_str1_2= '||l_str1_2);  -- Bug 8946879
     END IF;

     IF (TRANSLATE(l_str3_4, '0123456789', '9999999999') <> '99') THEN
       fnd_message.set_name('CE', 'CE_IBAN_FIRST_34_CHAR');  -- Bug 8946879
       fnd_msg_pub.add;
       x_return_status := fnd_api.g_ret_sts_error;
       cep_standard.debug('validate_IBAN: CE_IBAN_FIRST_34_CHAR l_str3_4= '||l_str3_4);  -- Bug 8946879
     END IF;

     --
     IF TRANSLATE(new_IBAN,  'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
                        '999999999999999999999999999999999999')
                <>       RPAD(l_var, l_len, '9') THEN
       fnd_message.set_name('CE', 'CE_INVALID_IBAN_FORMAT');
       fnd_msg_pub.add;
       x_return_status := fnd_api.g_ret_sts_error;
     cep_standard.debug('validate_IBAN: CE_INVALID_IBAN_FORMAT');
     ELSE
       --
       l_temp1 := SUBSTR(new_IBAN, 1, 4);
       l_temp2 := SUBSTR(new_IBAN, 5, l_len);
       l_temp3 := l_temp2||l_temp1;
       --
       l_temp4:= REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
             REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
             REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
             REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(l_temp3,
             'A', '10'), 'B', '11'), 'C', '12'), 'D', '13'), 'E', '14'),
             'F', '15'), 'G', '16'), 'H', '17'),'I', '18'), 'J', '19'),
             'K', '20'), 'L', '21'), 'M', '22'), 'N', '23'), 'O', '24'),
             'P', '25'), 'Q', '26'), 'R', '27'), 'S', '28'), 'T', '29'),
             'U', '30'), 'V', '31'), 'W', '32'), 'X', '33'), 'Y', '34'),
             'Z', '35');
       --
       l_num  :=  TO_NUMBER(l_temp4);
       --
       l_mod  :=   MOD(l_num, 97);
       --
       IF l_mod <> 1 THEN
         fnd_message.set_name('CE', 'CE_INVALID_IBAN_CHKSUM');  -- Bug 8946879
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_error;
     	cep_standard.debug('validate_IBAN: CE_INVALID_IBAN_CHKSUM');  -- Bug 8946879
       ELSE
	-- IF (new_IBAN <> p_IBAN) then  Bug 6658562
     		cep_standard.debug('new_IBAN <> p_IBAN');
	    p_IBAN_OUT := new_IBAN;
     		cep_standard.debug('p_IBAN='||p_IBAN);
	        cep_standard.debug('new_IBAN='||new_IBAN);
	        cep_standard.debug('p_IBAN_OUT='||p_IBAN_OUT);
	-- END IF;
       END IF;
     END IF;

	cep_standard.debug('end');

     cep_standard.debug('p_IBAN='||p_IBAN);
     cep_standard.debug('new_IBAN='||new_IBAN);
     cep_standard.debug('p_IBAN_OUT='||p_IBAN_OUT);

   END validate_IBAN;

  /*=======================================================================+
   | PUBLIC PROCEDURE validate_account_use                                 |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validate that at least one account use is selected for the          |
   |     bank account                                                      |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_ap, p_ar, p_pay, p_xtr                                          |
   +=======================================================================*/
   PROCEDURE validate_account_use(p_ap      IN  VARCHAR2,
                                  p_ar      IN  VARCHAR2,
                                  p_pay     IN  VARCHAR2,
                                  p_xtr     IN  VARCHAR2,
			    x_return_status     IN OUT NOCOPY VARCHAR2 ) IS


   BEGIN
     cep_standard.debug('CE_BANK_AND_ACCOUNT_VALIDATION.validate_account_use (+)');
     -- initialize API return status to success.
     x_return_status := fnd_api.g_ret_sts_success;

     cep_standard.debug('p_ap='||p_ap);
     cep_standard.debug('p_ar='||p_ar);
     cep_standard.debug('p_pay='||p_pay);
     cep_standard.debug('p_xtr='||p_xtr);


     IF (p_ap IS NULL OR p_ap = 'N') AND
	(p_ar IS NULL OR p_ar = 'N')  AND
        (p_pay IS NULL OR p_pay = 'N') AND
	(p_xtr IS NULL OR p_xtr = 'N')    THEN
      fnd_message.set_name('CE', 'CE_NO_ACCOUNT_USE');
      fnd_msg_pub.add;
       x_return_status := fnd_api.g_ret_sts_error;
     END IF;


   EXCEPTION
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
       FND_MESSAGE.Set_Token('PROCEDURE', 'CE_BANK_AND_ACCOUNT_VALIDATION.validate_account_use');
       fnd_msg_pub.add;

   END validate_account_use;

  /*=======================================================================+
   | PUBLIC PROCEDURE validate_short_account_name                          |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Short Account Name is required when Xtr use is selected for the     |
   |     bank account                                                      |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_short_account_name, p_xtr                                       |
   +=======================================================================*/
   PROCEDURE validate_short_account_name(p_short_account_name  IN  VARCHAR2,
                                  	 p_xtr   	       IN  VARCHAR2,
			    		 x_return_status     IN OUT NOCOPY VARCHAR2 ) IS

   BEGIN
     cep_standard.debug('CE_BANK_AND_ACCOUNT_VALIDATION.validate_account_use (+)');
     -- initialize API return status to success.
     x_return_status := fnd_api.g_ret_sts_success;
     cep_standard.debug('p_short_account_name='||p_short_account_name);
     cep_standard.debug('p_xtr='||p_xtr);


     IF (p_short_account_name IS NULL) AND (p_xtr IS NOT NULL) AND (p_xtr <> 'N')   THEN
      fnd_message.set_name('CE', 'CE_SHORT_ACCOUNT_NAME_REQUIRED');
      fnd_msg_pub.add;
       x_return_status := fnd_api.g_ret_sts_error;
     END IF;


   EXCEPTION
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
       FND_MESSAGE.Set_Token('PROCEDURE', 'CE_BANK_AND_ACCOUNT_VALIDATION.validate_short_account_name');
       fnd_msg_pub.add;

   END validate_short_account_name;

  /*=======================================================================+
   | PUBLIC PROCEDURE validate_end_date                                    |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validate that the end date is not earlier than the start date       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_start_date, p_end_date                                          |
   +=======================================================================*/
   PROCEDURE validate_end_date(p_start_date    IN  DATE,
                               p_end_date      IN  DATE,
			       x_return_status     IN OUT NOCOPY VARCHAR2) IS

   BEGIN
     cep_standard.debug('CE_BANK_AND_ACCOUNT_VALIDATION.validate_end_date (+)');
     -- initialize API return status to success.
     x_return_status := fnd_api.g_ret_sts_success;


     IF (p_start_date is not NULL) AND (p_end_date is not NULL)  THEN
       IF  p_start_date > p_end_date	THEN
        fnd_message.set_name('CE', 'CE_EARLY_END_DATE');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
       END IF;
     END IF;


   EXCEPTION
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
       FND_MESSAGE.Set_Token('PROCEDURE', 'CE_BANK_AND_ACCOUNT_VALIDATION.validate_end_date');
       fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;

   END validate_end_date;

  /*=======================================================================+
   | PUBLIC FUNCTION Get_Emp_Name                                         |
   |                                                                       |
   | DESCRIPTION                                                           |
   |    Get Employee Name                                                  |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_emp_id                                                          |
   +=======================================================================*/
   FUNCTION Get_Emp_Name( p_emp_id NUMBER ) RETURN VARCHAR2 IS
  	l_return per_employees_x.full_name%TYPE;
   BEGIN

      BEGIN

        SELECT full_name
        INTO   l_return
        FROM   per_employees_x
        WHERE  employee_id = p_emp_id;


      EXCEPTION
        WHEN no_data_found THEN
           l_return := NULL;
      END;

      RETURN l_return;

   END Get_Emp_Name;


  /*=======================================================================+
   | PUBLIC FUNCTION Get_Org_Type                                          |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Get Organization Type                                               |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_org_id                                                          |
   +=======================================================================*/
   FUNCTION Get_Org_Type( p_org_id NUMBER ) RETURN VARCHAR2 IS
     bg_org hr_lookups.meaning%TYPE;
     le_org hr_lookups.meaning%TYPE;
     ou_org hr_lookups.meaning%TYPE;
     org_type1 VARCHAR2(240);
     org_type VARCHAR2(240);

   CURSOR bg IS
	SELECT  hl.meaning || ', '
	FROM 	hr_organization_information 	oi,
     		hr_lookups			hl
	WHERE 	oi.org_information_context = 'CLASS'
	AND   	oi.org_information1 = 'HR_BG'
	and  	hl.lookup_type = 'ORG_CLASS'
	AND  	hl.lookup_code =  oi.org_information1
	and 	oi.organization_id =  p_org_id;

   CURSOR le IS
	SELECT  hl.meaning || ', '
	FROM 	hr_organization_information 	oi,
     		hr_lookups			hl
	WHERE 	oi.org_information_context = 'CLASS'
	AND   	oi.org_information1 = 'HR_LEGAL'
	and  	hl.lookup_type = 'ORG_CLASS'
	AND  	hl.lookup_code =  oi.org_information1
	and 	oi.organization_id =  p_org_id;

   CURSOR ou IS
	SELECT  hl.meaning || ', '
	FROM 	hr_organization_information 	oi,
     		hr_lookups			hl
	WHERE 	oi.org_information_context = 'CLASS'
	AND   	oi.org_information1 = 'OPERATING_UNIT'
	and  	hl.lookup_type = 'ORG_CLASS'
	AND  	hl.lookup_code =  oi.org_information1
	and 	oi.organization_id =  p_org_id;
 	--and 	MO_GLOBAL.CHECK_ACCESS(oi.ORGANIZATION_ID) = 'Y';

   BEGIN

     BEGIN
     cep_standard.debug('CE_BANK_AND_ACCOUNT_VALIDATION.get_org_type (+)');

   --/*  1/13/05 no bg
     OPEN  bg;

     FETCH bg INTO bg_org;
     cep_standard.debug('bg_org='||bg_org);
       IF bg%NOTFOUND THEN
	 bg_org := null;
       END IF;
     CLOSE bg;
  -- */

   /* 3/24/05 no le
     OPEN  le;
     FETCH le INTO le_org;
     cep_standard.debug('le_org='||le_org);
       IF le%NOTFOUND THEN
	 le_org := null;
       END IF;
     CLOSE le;
   */
     OPEN  ou;
     FETCH ou INTO ou_org;
     cep_standard.debug('ou_org='||ou_org);
       IF ou%NOTFOUND THEN
	 ou_org := null;
       END IF;
     CLOSE ou;

     --org_type1 := bg_org || le_org || ou_org;
     --org_type1 := le_org || ou_org;
     org_type1 := bg_org || ou_org;

     org_type := substr(org_type1,1,(length(org_type1)-2));

     cep_standard.debug('org_type='||org_type);

    EXCEPTION
      WHEN no_data_found THEN
       org_type := NULL;
    END;


     RETURN org_type;

   EXCEPTION
	WHEN OTHERS THEN
  	cep_standard.debug('EXCEPTION: Get_Org_Type');
  	RAISE;
   END Get_Org_Type;


  /*=======================================================================+
   | PUBLIC FUNCTION Get_Org_Type_Code                                     |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Get Organization Type Code. Used in System Parameters.              |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_org_id                                                          |
   +=======================================================================*/
   FUNCTION Get_Org_Type_Code( p_org_id NUMBER ) RETURN VARCHAR2 IS
     org_type1 VARCHAR2(240);
     org_type VARCHAR2(240);
     bg_org	VARCHAR2(50);
     ou_org	VARCHAR2(50);

   CURSOR bg IS
	SELECT  'BG'
	FROM    ce_security_profiles_v
 	WHERE   organization_type = 'BUSINESS_GROUP'
	AND     organization_id = p_org_id;

   CURSOR ou IS
        SELECT  'OU'
        FROM    ce_security_profiles_v
        WHERE   organization_type = 'OPERATING_UNIT'
        AND     organization_id = p_org_id;

   BEGIN
     BEGIN
     cep_standard.debug('CE_BANK_AND_ACCOUNT_VALIDATION.get_org_type_code (+)');

     OPEN  bg;

     FETCH bg INTO bg_org;
     cep_standard.debug('bg_org='||bg_org);
       IF bg%NOTFOUND THEN
         bg_org := null;
       END IF;
     CLOSE bg;

     OPEN  ou;
     FETCH ou INTO ou_org;
     cep_standard.debug('ou_org='||ou_org);
       IF ou%NOTFOUND THEN
         ou_org := null;
       END IF;
     CLOSE ou;

     org_type := bg_org || ou_org;

     --org_type := substr(org_type1,1,(length(org_type1)-2));

     cep_standard.debug('org_type='||org_type);

    EXCEPTION
      WHEN no_data_found THEN
       org_type := NULL;
    END;


     RETURN org_type;

   EXCEPTION
        WHEN OTHERS THEN
        cep_standard.debug('EXCEPTION: Get_Org_Type_Code');
        RAISE;
   END Get_Org_Type_Code;


  /*=======================================================================+
   | PUBLIC PROCEDURE validate_account_access_org                          |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validate that the account use is valid for the org                  |
   |
   |    Validate organization use
   |    Access Org        | Org can be          | Org cannot be
   |    Classification    | use in              | use In
   |    --------------------------------------------------------------
   |    LE                | XTR                 | AP, AR, PAY
   |    BG                | PAY                 | AR, AP, XTR
   |    OU                | AP, AR              | PAY, XTR
   |    BG and OU         | AP, AR, PAY         | XTR
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_ap, p_ar, p_pay, p_xtr, p_org_id                                |
   +=======================================================================*/
   PROCEDURE validate_account_access_org(p_ap      IN  VARCHAR2,
                                  p_ar      IN  VARCHAR2,
                                  p_pay     IN  VARCHAR2,
                                  p_xtr     IN  VARCHAR2,
				  p_org_type IN VARCHAR2,
				  p_org_id  IN	NUMBER,
			          x_return_status     IN OUT NOCOPY VARCHAR2 ) IS

      org_type VARCHAR2(240);

   BEGIN
     cep_standard.debug('CE_BANK_AND_ACCOUNT_VALIDATION.validate_account_use (+)');
     -- initialize API return status to success.
     x_return_status := fnd_api.g_ret_sts_success;

     cep_standard.debug('p_ap='||p_ap);
     cep_standard.debug('p_ar='||p_ar);
     cep_standard.debug('p_pay='||p_pay);
     cep_standard.debug('p_xtr='||p_xtr);
     cep_standard.debug('p_org_id='||p_org_id);

    /*// orgType: LE - Legal Entity
      //          BG - Business Group
      //          OU - Operating Unit
      //          BGOU - Business Group and Operating Unit*/

     IF (p_org_type = 'LE')  AND
 	(((p_ap IS not NULL) and (p_ap <>'N')) or
	 ((p_ar IS not NULL) and (p_ar <>'N'))  or
         ((p_pay IS not NULL) and (p_pay <>'N')))   THEN
      fnd_message.set_name('CE', 'CE_LE_ACCESS_ORG');
      fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
     ELSIF (p_org_type = 'BG')  AND
 	(((p_ap IS not NULL) and (p_ap <>'N')) or
	 ((p_ar IS not NULL) and (p_ar <>'N'))  or
	 ((p_xtr IS not NULL) and (p_xtr <>'N'))) THEN
      fnd_message.set_name('CE', 'CE_BG_ACCESS_ORG');
      fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
     ELSIF (p_org_type = 'OU')  AND
 	(((p_xtr IS not NULL) and (p_xtr <>'N')) or
 	 ((p_pay IS not NULL) and (p_pay <>'N')))  THEN
      fnd_message.set_name('CE', 'CE_OU_ACCESS_ORG');
      fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
     ELSIF (p_org_type = 'BGOU')  AND
 	((p_xtr IS not NULL) and (p_xtr <>'N'))  THEN
      fnd_message.set_name('CE', 'CE_BGOU_ACCESS_ORG');
      fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
     END IF;

   EXCEPTION
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
       FND_MESSAGE.Set_Token('PROCEDURE', 'CE_BANK_AND_ACCOUNT_VALIDATION.validate_account_access_org');
       fnd_msg_pub.add;

   END validate_account_access_org;

  /*=======================================================================+
   | PUBLIC PROCEDURE VALIDATE_ALC                                         |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validate Agency Location Code		                           |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |    ALC_VALUE                                                          |
   |   OUT                                                                 |
   |    x_msg_count                                                        |
   |    x_msg_data                                                         |
   |    X_VALUE_OUT                                                        |
   +=======================================================================*/
   PROCEDURE VALIDATE_ALC(ALC_VALUE in varchar2,
 			  p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE,
    			      x_msg_count      OUT NOCOPY NUMBER,
			      x_msg_data       OUT NOCOPY VARCHAR2,
		              X_VALUE_OUT      OUT NOCOPY VARCHAR2,
			      x_return_status     IN OUT NOCOPY VARCHAR2 )
                                      AS
   numeric_alc  varchar2(40);
   alc_value_len number;
   new_alc_value varchar2(40);

   BEGIN

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
   END IF;
     -- initialize API return status to success.
     x_return_status := fnd_api.g_ret_sts_success;


   IF (ALC_VALUE is not null) THEN

     numeric_alc := ce_check_numeric(ALC_VALUE,1,length(ALC_VALUE));
     new_alc_value := replace(ALC_VALUE,' ');  --remove spaces
     alc_value_len := length(new_alc_value);

     IF numeric_alc = '0' then
       IF (alc_value_len < 9) then
	 If (alc_value_len <> 8)  then
	   x_value_out := lpad(new_alc_value,8,0);
	 end if;
       else
         FND_MESSAGE.set_name('CE','CE_ALC_VALUE_TOO_LONG');
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_error;
       END if;
     ELSE
       FND_MESSAGE.set_name('CE','CE_ALC_NUMERIC_VALUE_ONLY');
       fnd_msg_pub.add;
       x_return_status := fnd_api.g_ret_sts_error;
     END IF;

   END IF;

   FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

   EXCEPTION
      WHEN OTHERS THEN

      FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'CE_BANK_AND_ACCOUNT_VALIDATION.validate_alc');
        fnd_msg_pub.add;
        RAISE;

   END VALIDATE_ALC;

  /*=======================================================================+
   | PUBLIC PROCEDURE validate_country                                     |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Check to see that the country specified is defined in               |
   |   territories.                                                        |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |    p_country_code                                                     |
   |   OUT                                                                 |
   |    x_return_status                                                    |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    Xin Wang      Created.                               |
   +=======================================================================*/
  PROCEDURE validate_country (
    p_country_code  IN     VARCHAR2,
    x_return_status IN OUT NOCOPY VARCHAR2
  ) IS
    CURSOR c_country IS
      SELECT 1
      FROM   fnd_territories ft
      WHERE  ft.territory_code = p_country_code;
    l_dummy   NUMBER(1) := 0;
  BEGIN
    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('>>CE_BANK_AND_ACCOUNT_VALIDATION.validate_country.');
    END IF;

    OPEN c_country;
    FETCH c_country INTO l_dummy;
    IF c_country%NOTFOUND THEN
      fnd_message.set_name('CE', 'CE_API_INVALID_COUNTRY');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;
    CLOSE c_country;

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('<<CE_BANK_AND_ACCOUNT_VALIDATION.validate_country.');
    END IF;
  END validate_country;

  /*=======================================================================+
   | PUBLIC PROCEDURE validate_def_settlement                              |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Allow only one account per currency and account use (AP or XTR)     |
   |   to be flagged as the default settlement account for each  LE or OU  |
   |                                                                       |
   |   Possible combination:                                               |
   |   LE1, USD, AP USE,  BANK ACCOUNT 1                                   |
   |   LE1, USD, XTR USE, BANK ACCOUNT 2                                   |
   |   OU1, USD, AP USE,  BANK ACCOUNT 1                                   |
   |   OU1, USD, XTR USE, BANK ACCOUNT 1                                   |
   |                                                                       |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |    p_bank_account_id - required 					   |
   |    p_bank_acct_use_id - required 					   |
   |    p_org_id - required	                                           |
   |    p_ap_def_settlement, p_xtr_def_settlement, p_init_msg_list	   |
   |   OUT                                                                 |
   |    x_return_status                                                    |
   |    x_msg_count                                                        |
   |	x_msg_data   	                                                   |
   |		                                                           |
   | MODIFICATION HISTORY                                                  |
   |   21-DEC-2004    lkwan         Created.                               |
   +=======================================================================*/
  PROCEDURE validate_def_settlement(
		p_bank_account_id 	IN  number,
		p_bank_acct_use_id 	IN  number,
		p_org_id 		IN  number,
		p_ap_def_settlement 	in  VARCHAR2,
		p_xtr_def_settlement 	in  VARCHAR2,
		p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE,
    		x_msg_count      OUT NOCOPY NUMBER,
		x_msg_data       OUT NOCOPY VARCHAR2,
                x_return_status IN OUT NOCOPY VARCHAR2) IS
   p_cur  varchar2(5);
   p_ap_def number;
   p_xtr_def number;
  BEGIN
      cep_standard.debug('>>CE_BANK_AND_ACCOUNT_VALIDATION.validate_def_settlement');
   -- initialize API return status to success.
   x_return_status := fnd_api.g_ret_sts_success;

   -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
  END IF;
IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug(' P_INIT_MSG_LIST: '|| P_INIT_MSG_LIST);
END IF;

  IF (p_bank_account_id is not null) then
     select currency_code into p_cur
     from ce_bank_accounts
     where bank_account_id = p_bank_account_id;
    IF (P_CUR IS not NULL) THEN
      --IF (p_bank_acct_use_id is null) then
      --   FND_MESSAGE.set_name('CE','CE_BANK_ACCT_USE_ID_REQUIRED');
      --   fnd_msg_pub.add;
      --ELSE

        IF (p_ap_def_settlement = 'Y')  THEN
	   select count(*) into p_ap_def
	   from ce_bank_accounts ba, ce_bank_acct_uses_all bau
	   where ba.bank_account_id = bau.bank_account_id
	   and ba.currency_code = p_cur
	   and nvl(bau.org_id, bau.LEGAL_ENTITY_ID) = p_org_id
	   and nvl(bau.AP_DEFAULT_SETTLEMENT_FLAG,'N') = 'Y'
	   and bau.bank_acct_use_id <> nvl(p_bank_acct_use_id, bau.bank_acct_use_id);
        END IF;
        IF (p_xtr_def_settlement = 'Y')  THEN
	   select count(*) into p_xtr_def
	   from ce_bank_accounts ba, ce_bank_acct_uses_all bau
	   where ba.bank_account_id = bau.bank_account_id
	   and ba.currency_code = p_cur
	   and nvl(bau.org_id, bau.LEGAL_ENTITY_ID) = p_org_id
	   and nvl(bau.XTR_DEFAULT_SETTLEMENT_FLAG,'N') = 'Y'
	   and bau.bank_acct_use_id <> nvl(p_bank_acct_use_id, bau.bank_acct_use_id) ;
        END IF;

        IF (p_ap_def > 0) THEN
           FND_MESSAGE.set_name('CE','CE_AP_SETTLEMENT_EXIST_ORG');
           fnd_msg_pub.add;
        END IF;

        IF (p_xtr_def > 0) THEN
           FND_MESSAGE.set_name('CE','CE_XTR_SETTLEMENT_EXIST_ORG');
           fnd_msg_pub.add;
        END IF;
      --END IF; --p_bank_acct_use_id
    ELSE
       FND_MESSAGE.set_name('CE','CE_BANK_ACCOUNT_ID_INVALID');
       fnd_msg_pub.add;
     END IF;

   ELSE
     FND_MESSAGE.set_name('CE','CE_BANK_ACCOUNT_ID_REQUIRED');
     fnd_msg_pub.add;
   END IF;

   FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

   IF x_msg_count > 0 THEN
     x_return_status := fnd_api.g_ret_sts_error;
   END IF;
--IF l_DEBUG in ('Y', 'C') THEN
	cep_standard.debug(' P_COUNT: '|| x_msg_count);


      cep_standard.debug('<<CE_BANK_AND_ACCOUNT_VALIDATION.validate_def_settlement');
--END IF;

   EXCEPTION
      WHEN OTHERS THEN

      FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'CE_BANK_AND_ACCOUNT_VALIDATION.validate_def_settlement');
        fnd_msg_pub.add;
        RAISE;

  END validate_def_settlement;

  /*=======================================================================+
   | PUBLIC FUNCTION get_masked_account_num                                |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Passing the bank_account_num and return the                         |
   |   masked bank_account_num based on the profile option:                |
   |     CE: MASK INTERNAL BANK ACCOUNT NUMBERS                            |
   |     (CE_MASK_INTERNAL_BANK_ACCT_NUM)                                  |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |   p_bank_account_num                                                  |
   |                                                                       |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   23-NOV-2004    lkwan         Created.                               |
   +=======================================================================*/
/*
  FUNCTION get_masked_account_num (
    p_bank_account_num  IN     VARCHAR2,
    p_acct_class  IN     VARCHAR2
  ) RETURN VARCHAR2
   IS
     masked_account_num VARCHAR2(100);
     ba_num_length number;
     ba_num_masked_start number;
     mask_ba_num_option varchar2(1);

   BEGIN
   IF  p_acct_class is not null THEN
     IF p_acct_class in ( 'INTERNAL', 'BOTH')  THEN
	mask_ba_num_option := NVL(FND_PROFILE.value('CE_MASK_INTERNAL_BANK_ACCT_NUM'), 'LAST FOUR VISIBLE');
     ELSIF p_acct_class = 'EXTERNAL'  THEN
	mask_ba_num_option := NVL(FND_PROFILE.value('CE_MASK_EXTERNAL_BANK_ACCT_NUM'), 'LAST FOUR VISIBLE');
     END IF;
   END IF;
   IF  p_bank_account_num is not null THEN
     ba_num_length := length(p_bank_account_num);
     ba_num_masked_start :=  (ba_num_length - 3);

     IF mask_ba_num_option = 'LAST FOUR VISIBLE' THEN
	masked_account_num  :=  substr(p_bank_account_num, ba_num_masked_start,ba_num_length  );
	masked_account_num  :=  lpad(masked_account_num, ba_num_length, 'X'  );
     END IF;

   END IF;

   RETURN(masked_account_num);
   EXCEPTION
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
       FND_MESSAGE.Set_Token('PROCEDURE', 'CE_BANK_AND_ACCOUNT_VALIDATION.get_masked_account_num');
       fnd_msg_pub.add;
       RAISE;
   END get_masked_account_num;
*/

  /*=======================================================================+
   | PUBLIC PROCEDURE validate_unique_org_access                           |
   |                                                                       |
   | DESCRIPTION                                                           |
   |    The combination or bank_account_id and org_id/legal_entity_id in   |
   |    in CE_BANK_ACCT_USES_ALL should be unique.                         |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |    p_org_le_id                                                        |
   |    p_bank_account_id                                                  |
   |   OUT                                                                 |
   |    x_return_status                                                    |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   22-JUN-2005    Xin Wang      Created.                               |
   +=======================================================================*/
  PROCEDURE validate_unique_org_access (
    p_org_le_id        IN     NUMBER,
    p_bank_account_id  IN     NUMBER,
    p_acct_use_id      IN     NUMBER,
    x_return_status    IN OUT NOCOPY VARCHAR2
  ) IS
   l_dummy    VARCHAR2(1);
   CURSOR c_acct_access IS
       SELECT  'X'
       FROM    ce_bank_acct_uses_all
       WHERE   bank_account_id = p_bank_account_id
       AND     NVL(org_id, legal_entity_id) = p_org_le_id
       AND     bank_acct_use_id <> NVL(p_acct_use_id, -1);

   BEGIN
     cep_standard.debug('CE_BANK_AND_ACCOUNT_VALIDATION.validate_unique_org_access(+)');

     -- initialize API return status to success.
     x_return_status := fnd_api.g_ret_sts_success;

     OPEN  c_acct_access;
     FETCH c_acct_access INTO l_dummy;
     IF l_dummy = 'X' THEN
      fnd_message.set_name('CE', 'CE_DUP_ACCT_ORG_ACCESS');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
     END IF;
     CLOSE c_acct_access;

   EXCEPTION
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
       FND_MESSAGE.Set_Token('PROCEDURE', 'CE_BANK_AND_ACCOUNT_VALIDATION.validate_unique_org_access');
       fnd_msg_pub.add;

   END validate_unique_org_access;


  /*=======================================================================+
   | PUBLIC PROCEDURE get_pay_doc_cat                              |
   |                                                                       |
   | DESCRIPTION                                                           |
   |    Obtaining the correct document category will be a hierarchical
   |     approach:
   |     1) payment document,
   |     2) bank account use/payment method,
   |     3) bank account use                                               |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |    P_PAYMENT_DOCUMENT_ID
   |    P_PAYMENT_METHOD_CODE
   |    P_BANK_ACCT_USE_ID
   |   OUT                                                                 |
   |    P_PAYMENT_DOC_CATEGORY_CODE ("-1" if no category code is defined)
   |		                                                           |
   | MODIFICATION HISTORY                                                  |
   |   21-FEB-2006    lkwan         Created.                               |
   +=======================================================================*/
  PROCEDURE get_pay_doc_cat(
		P_PAYMENT_DOCUMENT_ID 	IN  number,
		P_PAYMENT_METHOD_CODE 	IN  VARCHAR2,
		P_BANK_ACCT_USE_ID	IN  number,
		P_PAYMENT_DOC_CATEGORY_CODE  OUT NOCOPY VARCHAR2) IS
   p_pay_doc_count	number;
   p_ap_doc_cat_count	number;

   BEGIN
     cep_standard.debug('>>CE_BANK_AND_ACCOUNT_VALIDATION.get_pay_doc_cat');
     cep_standard.debug('P_PAYMENT_DOCUMENT_ID=' ||P_PAYMENT_DOCUMENT_ID
			||', P_PAYMENT_METHOD_CODE='||P_PAYMENT_METHOD_CODE
			||', P_BANK_ACCT_USE_ID='||P_BANK_ACCT_USE_ID 	);

     P_PAYMENT_DOC_CATEGORY_CODE := '-1';

     IF (P_PAYMENT_DOCUMENT_ID is not null)  THEN
	select count(*) into p_pay_doc_count
	from ce_payment_documents
	where PAYMENT_DOCUMENT_ID = P_PAYMENT_DOCUMENT_ID;

     cep_standard.debug('p_pay_doc_count='||p_pay_doc_count );

	if (p_pay_doc_count = 1) then
	  select nvl(PAYMENT_DOC_CATEGORY, '-1')
	  into P_PAYMENT_DOC_CATEGORY_CODE
	  from ce_payment_documents
	  where PAYMENT_DOCUMENT_ID = P_PAYMENT_DOCUMENT_ID;
	else
	  P_PAYMENT_DOC_CATEGORY_CODE := '-1';
	end if;
     END IF;

     cep_standard.debug('ce_payment_documents P_PAYMENT_DOC_CATEGORY_CODE='||P_PAYMENT_DOC_CATEGORY_CODE );

     IF (P_PAYMENT_DOC_CATEGORY_CODE = '-1') THEN
       IF (P_PAYMENT_METHOD_CODE is not null and P_BANK_ACCT_USE_ID is not null) THEN
	 select count(*) into p_ap_doc_cat_count
	 from ce_ap_pm_doc_categories
	 where BANK_ACCT_USE_ID = P_BANK_ACCT_USE_ID
	 and PAYMENT_METHOD_CODE = P_PAYMENT_METHOD_CODE;

	 if (p_ap_doc_cat_count = 1) then
 	   select nvl(PAYMENT_DOC_CATEGORY, '-1')
	   into P_PAYMENT_DOC_CATEGORY_CODE
	   from ce_ap_pm_doc_categories
	   where BANK_ACCT_USE_ID = P_BANK_ACCT_USE_ID
	   and PAYMENT_METHOD_CODE = P_PAYMENT_METHOD_CODE;
	 else
	   P_PAYMENT_DOC_CATEGORY_CODE := '-1';
	 end if;

         cep_standard.debug('ce_ap_pm_doc_categories P_PAYMENT_DOC_CATEGORY_CODE='||P_PAYMENT_DOC_CATEGORY_CODE );

       END IF;
     END IF;


     IF (P_PAYMENT_DOC_CATEGORY_CODE = '-1') THEN
       IF ( P_BANK_ACCT_USE_ID is not null) THEN
	 select nvl(PAYMENT_DOC_CATEGORY, '-1')
 	 into P_PAYMENT_DOC_CATEGORY_CODE
	 from ce_bank_acct_uses_all
	 where  BANK_ACCT_USE_ID = P_BANK_ACCT_USE_ID;
         cep_standard.debug('ce_bank_acct_uses_all P_PAYMENT_DOC_CATEGORY_CODE='||P_PAYMENT_DOC_CATEGORY_CODE );
       END IF;
     END IF;

     cep_standard.debug('P_PAYMENT_DOC_CATEGORY_CODE='||P_PAYMENT_DOC_CATEGORY_CODE );

     cep_standard.debug('<<CE_BANK_AND_ACCOUNT_VALIDATION.get_pay_doc_cat');

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
     cep_standard.debug('no data found');
           P_PAYMENT_DOC_CATEGORY_CODE := '-1';
     WHEN TOO_MANY_ROWS THEN
     cep_standard.debug('too_many_rows');
           P_PAYMENT_DOC_CATEGORY_CODE := '-1';
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
       FND_MESSAGE.Set_Token('PROCEDURE', 'CE_BANK_AND_ACCOUNT_VALIDATION.get_pay_doc_cat');
       fnd_msg_pub.add;

   END get_pay_doc_cat;

  /*=======================================================================+
   | PUBLIC FUNCTION Get_Org_Type_Code_Isetup                              |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Get Organization Type Code. Used in System Parameters.              |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_org_id							   |
   | Function added for the bug 7713625					   |
   +=======================================================================*/

 FUNCTION Get_Org_Type_Code_Isetup( p_org_id NUMBER ) RETURN VARCHAR2 IS
     org_type VARCHAR2(240);
     bg_org	VARCHAR2(50);
     ou_org	VARCHAR2(50);

   CURSOR bg IS
	SELECT 'BG'
	FROM 	hr_organization_information 	oi,
     		hr_lookups			hl
	WHERE 	oi.org_information_context = 'CLASS'
	AND   	oi.org_information1 = 'HR_BG'
	and  	hl.lookup_type = 'ORG_CLASS'
	AND  	hl.lookup_code =  oi.org_information1
	and 	oi.organization_id =  p_org_id;

   CURSOR ou IS
        SELECT 'OU'
	FROM 	hr_organization_information 	oi,
     		hr_lookups			hl
	WHERE 	oi.org_information_context = 'CLASS'
	AND   	oi.org_information1 = 'OPERATING_UNIT'
	and  	hl.lookup_type = 'ORG_CLASS'
	AND  	hl.lookup_code =  oi.org_information1
	and 	oi.organization_id =  p_org_id;

   BEGIN
     BEGIN
     cep_standard.debug('CE_BANK_AND_ACCOUNT_VALIDATION.get_org_type_code_isetup (+)');

     OPEN  bg;

     FETCH bg INTO bg_org;
     cep_standard.debug('bg_org='||bg_org);
       IF bg%NOTFOUND THEN
         bg_org := null;
       END IF;
     CLOSE bg;

     OPEN  ou;
     FETCH ou INTO ou_org;
     cep_standard.debug('ou_org='||ou_org);
       IF ou%NOTFOUND THEN
         ou_org := null;
       END IF;
     CLOSE ou;

     org_type := bg_org || ou_org;

    cep_standard.debug('org_type='||org_type);

    EXCEPTION
      WHEN no_data_found THEN
       org_type := NULL;
    END;


     RETURN org_type;

   EXCEPTION
        WHEN OTHERS THEN
        cep_standard.debug('EXCEPTION: Get_Org_Type_Code_Isetup');
        RAISE;
   END Get_Org_Type_Code_Isetup;

END CE_BANK_AND_ACCOUNT_VALIDATION;

/
