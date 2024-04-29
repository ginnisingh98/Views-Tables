--------------------------------------------------------
--  DDL for Package Body CE_CUSTOM_BANK_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_CUSTOM_BANK_VALIDATIONS" AS
/* $Header: cecbnkvb.pls 120.1.12010000.3 2009/12/24 07:18:41 vnetan noship $ */

/*----------------------------------------------------------------------+
| PRIVATE PROCEDURE                                                     |
|   debug_log                                                           |
|                                                                       |
| DESCRIPTION                                                           |
|   For debugging purposes. Displays message in the debug log.          |
+----------------------------------------------------------------------*/
PROCEDURE debug_log(msg_text VARCHAR2) AS
BEGIN
    cep_standard.debug(msg_text);
END debug_log;

/*----------------------------------------------------------------------+
| PRIVATE PROCEDURE                                                     |
|   set_error_text                                                      |
|                                                                       |
| DESCRIPTION                                                           |
|   Populates the error message stack with message to be displayed in   |
|   the UI.                                                             |
|                                                                       |
| PARAMETERS                                                            |
|   IN msg_name  Message name created under application Cash Management |
+----------------------------------------------------------------------*/
PROCEDURE set_error_text(msg_name VARCHAR2) AS
BEGIN
    fnd_message.set_name('CE',msg_name);
    fnd_msg_pub.add;
END set_error_text;

/*----------------------------------------------------------------------+
| PUBLIC PROCEDURE                                                      |
|   ce_usr_validate_bank                                                |
|                                                                       |
| DESCRIPTION                                                           |
|   This will be called when validating a bank from the Bank Setup UI   |
|                                                                       |
| PARAMETERS                                                            |
|  IN                                                                   |
|   Xi_COUNTRY_NAME    Country Name (Two-digit ISO Code)                |
|   Xi_BANK_NUMBER     Bank Number                                      |
|   Xi_BANK_NAME       Bank Name                                        |
|   Xi_BANK_NAME_ALT   Alt. Bank Name                                   |
|   Xi_TAX_PAYER_ID    Tax Payer ID                                     |
|   Xi_BANK_ID         Bank ID -> CE_BANKS_V.bank_party_id (available   |
|                      when updating a bank)                            |
|                                                                       |
|  OUT                                                                  |
|   Xo_RETURN_STATUS  fnd_api.g_ret_sts_success - Validation Successful |
|                     fnd_api.g_ret_sts_error   - Validation Failure    |
|                                                                       |
|   Xo_BANK_NUM_OUT   Formatted value of bank number to be stored.      |
+----------------------------------------------------------------------*/
PROCEDURE CE_USR_VALIDATE_BANK(
    Xi_COUNTRY_NAME    IN VARCHAR2,
    Xi_BANK_NUMBER     IN VARCHAR2,
    Xi_BANK_NAME       IN VARCHAR2,
    Xi_BANK_NAME_ALT   IN VARCHAR2,
    Xi_TAX_PAYER_ID    IN VARCHAR2,
    Xi_BANK_ID         IN NUMBER,
    Xo_BANK_NUM_OUT    OUT NOCOPY VARCHAR2,
    Xo_RETURN_STATUS   OUT NOCOPY VARCHAR2
) AS

    l_bank_num HZ_ORGANIZATION_PROFILES.bank_or_branch_number%TYPE;

BEGIN
    debug_log('>>CE_CUSTOM_BANK_VALIDATIONS.ce_usr_valdiate_bank');
    -- Initialize Return values
    Xo_RETURN_STATUS := fnd_api.g_ret_sts_success;
    Xo_BANK_NUM_OUT := Xi_BANK_NUMBER;

    /*------------------------------------------------------------------------------
    -- TODO: Add validation logic at bank level
    --

    debug_log('Xi_COUNTRY_NAME =' ||Xi_COUNTRY_NAME);
    debug_log('Xi_BANK_NUMBER  =' ||Xi_BANK_NUMBER);
    debug_log('Xi_BANK_NAME    =' ||Xi_BANK_NAME);
    debug_log('Xi_BANK_NAME_ALT=' ||Xi_BANK_NAME_ALT);
    debug_log('Xi_TAX_PAYER_ID =' ||Xi_TAX_PAYER_ID);
    debug_log('Xi_BANK_ID      =' ||Xi_BANK_ID);

    l_bank_num := CE_VALIDATE_BANKINFO.ce_remove_formats(Xi_BANK_NUMBER);

    -- SAMPLE VALIDATION
    -- For country AU, where Bank Number is populated, the Bank Number must be 3
    -- characters in length; bank number must contain only digits

    IF (Xi_COUNTRY_NAME = 'AU') AND (l_bank_num IS NOT NULL)
      AND ((length(l_bank_num) <> 3)
        OR (CE_VALIDATE_BANKINFO.ce_check_numeric(l_bank_num,1,length(l_bank_num)) <> '0'))
    THEN
        -- set error message name from Message Dictionary
        -- AND set return flag to indicate failure
        set_error_text('CE_CUSTOM_BANK');
        Xo_RETURN_STATUS := fnd_api.g_ret_sts_error;
    END IF;
    ------------------------------------------------------------------------------*/

    debug_log('<<CE_CUSTOM_BANK_VALIDATIONS.ce_usr_valdiate_bank');
EXCEPTION
  WHEN OTHERS THEN
    debug_log('EXCEPTION: CE_CUSTOM_BANK_VALIDATIONS.ce_usr_valdiate_bank');
    FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
    FND_MESSAGE.set_token('PROCEDURE', 'CE_CUSTOM_BANK_VALIDATIONS.ce_usr_valdiate_bank');
    FND_MSG_PUB.add;
    RAISE;
END ce_usr_validate_bank;
/*----------------------------------------------------------------------+
| PUBLIC PROCEDURE                                                      |
|   ce_usr_validate_branch                                              |
|                                                                       |
| DESCRIPTION                                                           |
|   This will be called when validating a bank branch from the Bank     |
|   Branch Setup UI.                                                    |
|                                                                       |
| PARAMETERS                                                            |
|  IN                                                                   |
|   Xi_COUNTRY_NAME    Country Name (Two-digit ISO Code)                |
|   Xi_BANK_NUMBER     Bank Number                                      |
|   Xi_BRANCH_NUMBER   Bank Branch Number                               |
|   Xi_BANK_NAME       Bank Name                                        |
|   Xi_BRANCH_NAME     Bank Branch Name                                 |
|   Xi_BRANCH_NAME_ALT Alt. Bank Branch Name                            |
|   Xi_BRANCH_TYPE     Bank Branch Type                                 |
|   Xi_BANK_ID         Bank ID -> CE_BANKS_V.bank_party_id              |
|   Xi_BRANCH_ID       Bank ID -> CE_BANK_BRANCHES_V.branch_party_id    |
|                                (available when updating a bank branch)|
|                                                                       |
|  OUT                                                                  |
|   Xo_RETURN_STATUS  fnd_api.g_ret_sts_success - Validation Successful |
|                     fnd_api.g_ret_sts_error   - Validation Failure    |
|                                                                       |
|   Xo_BRANCH_NUM_OUT Formatted value of branch number to be stored     |
+----------------------------------------------------------------------*/
PROCEDURE CE_USR_VALIDATE_BRANCH(
    Xi_COUNTRY_NAME     IN  VARCHAR2,
    Xi_BANK_NUMBER      IN  VARCHAR2,
    Xi_BRANCH_NUMBER    IN  VARCHAR2,
    Xi_BANK_NAME        IN  VARCHAR2,
    Xi_BRANCH_NAME      IN  VARCHAR2,
    Xi_BRANCH_NAME_ALT  IN  VARCHAR2,
    Xi_BRANCH_TYPE      IN  VARCHAR2,
    Xi_BANK_ID          IN  NUMBER,
    Xi_BRANCH_ID        IN  NUMBER,
    Xo_BRANCH_NUM_OUT  OUT NOCOPY VARCHAR2,
    Xo_RETURN_STATUS   OUT NOCOPY VARCHAR2
) AS

    l_branch_num    HZ_ORGANIZATION_PROFILES.bank_or_branch_number%TYPE;

BEGIN
    debug_log('>>CE_CUSTOM_BANK_VALIDATIONS.ce_usr_validate_branch');
    -- Initialize return values
    Xo_RETURN_STATUS := fnd_api.g_ret_sts_success;
    Xo_BRANCH_NUM_OUT := Xi_BRANCH_NUMBER;

    /*------------------------------------------------------------------------------
    -- TODO: Add validation logic at branch level
    --

    debug_log('Xi_COUNTRY_NAME     ='||Xi_COUNTRY_NAME     );
    debug_log('Xi_BANK_NUMBER      ='||Xi_BANK_NUMBER      );
    debug_log('Xi_BRANCH_NUMBER    ='||Xi_BRANCH_NUMBER    );
    debug_log('Xi_BANK_NAME        ='||Xi_BANK_NAME        );
    debug_log('Xi_BRANCH_NAME      ='||Xi_BRANCH_NAME      );
    debug_log('Xi_BRANCH_NAME_ALT  ='||Xi_BRANCH_NAME_ALT  );
    debug_log('Xi_BRANCH_TYPE      ='||Xi_BRANCH_TYPE      );
    debug_log('Xi_BANK_ID          ='||Xi_BANK_ID          );
    debug_log('Xi_BRANCH_ID        ='||Xi_BRANCH_ID        );

    -- SAMPLE VALIDATION
    -- For country ES, where Branch Number is populated, the Branch Number must be 4
    -- (or less) characters in length; where the length of the Bank Branch Number is
    -- less than 4, the Bank Branch Number is left padded with zeroes

    l_branch_num := CE_VALIDATE_BANKINFO.ce_remove_formats(Xi_BRANCH_NUMBER);
    IF(Xi_COUNTRY_NAME = 'ES') THEN
        IF(length(l_branch_num) > 4) THEN
            -- set error message name from Message Dictionary
            -- AND set return flag to indicate failure
            set_error_text('CE_CUSTOM_BRANCH');
            Xo_RETURN_STATUS := fnd_api.g_ret_sts_error;
        ELSE
           -- pad and set OUT value
           Xo_BRANCH_NUM_OUT := LPAD(l_branch_num,4,'0');
        END IF;
    END IF;
    ------------------------------------------------------------------------------*/

    debug_log('<<CE_CUSTOM_BANK_VALIDATIONS.ce_usr_validate_branch');

EXCEPTION
  WHEN OTHERS THEN
    debug_log('EXCEPTION: CE_CUSTOM_BANK_VALIDATIONS.ce_usr_valdiate_branch');
    FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
    FND_MESSAGE.set_token('PROCEDURE', 'CE_CUSTOM_BANK_VALIDATIONS.ce_usr_valdiate_branch');
    FND_MSG_PUB.add;
    RAISE;
END ce_usr_validate_branch;

/*----------------------------------------------------------------------+
| PUBLIC PROCEDURE                                                      |
|   ce_usr_validate_account                                             |
|                                                                       |
| DESCRIPTION                                                           |
|   This will be called when validating a bank account from the Bank    |
|   Account Setup UI. Any error messages to be displayed in the UI      |
|   should be set by calling the procedure set_error_text().            |
|                                                                       |
| PARAMETERS                                                            |
|  IN                                                                   |
|   Xi_COUNTRY_NAME        Country Name (Two-digit ISO Code)            |
|   Xi_BANK_NUMBER         Bank Number                                  |
|   Xi_BRANCH_NUMBER       Bank Branch Number                           |
|   Xi_ACCOUNT_NUMBER      Bank Account Number                          |
|   Xi_CD                  Check Digit                                  |
|   Xi_ACCOUNT_NAME        Bank Account Name                            |
|   Xi_CURRENCY_CODE       Bank Account Currency                        |
|   Xi_ACCOUNT_TYPE        Bank Account Type                            |
|   Xi_ACCOUNT_SUFFIX      Account Suffix                               |
|   Xi_SECONDARY_ACCT_REF  Secondary Account Reference                  |
|   Xi_ACCT_CLASSIFICATION Account Classification ('Internal')          |
|   Xi_BANK_ID             CE_BANKS_V.bank_party_id                     |
|   Xi_BRANCH_ID           CE_BANKS_BRANCHES_V.branch_party_id          |
|   Xi_ACCOUNT_ID          CE_BANK_ACCOUNTS.bank_account_id             |
|                                                                       |
|  OUT                                                                  |
|   Xo_RETURN_STATUS  fnd_api.g_ret_sts_success - Validation Successful |
|                     fnd_api.g_ret_sts_error   - Validation Failure    |
|                                                                       |
|   Xo_ACCOUNT_NUM_OUT Formatted value of account number to be stored   |
+----------------------------------------------------------------------*/
PROCEDURE CE_USR_VALIDATE_ACCOUNT(
    Xi_COUNTRY_NAME            IN VARCHAR2,
    Xi_BANK_NUMBER             IN VARCHAR2,
    Xi_BRANCH_NUMBER           IN VARCHAR2,
    Xi_ACCOUNT_NUMBER          IN VARCHAR2,
    Xi_CD                      IN VARCHAR2,
    Xi_ACCOUNT_NAME            IN VARCHAR2,
    Xi_CURRENCY_CODE           IN VARCHAR2,
    Xi_ACCOUNT_TYPE            IN VARCHAR2,
    Xi_ACCOUNT_SUFFIX          IN VARCHAR2,
    Xi_SECONDARY_ACCT_REF      IN VARCHAR2,
    Xi_ACCT_CLASSIFICATION     IN VARCHAR2,
    Xi_BANK_ID                 IN NUMBER,
    Xi_BRANCH_ID               IN NUMBER,
    Xi_ACCOUNT_ID              IN NUMBER,
    Xo_ACCOUNT_NUM_OUT OUT NOCOPY VARCHAR2,
    Xo_RETURN_STATUS   OUT NOCOPY VARCHAR2
) AS

/*  CURSOR c_acct_details IS
  SELECT * FROM CE_BANK_ACCOUNTS WHERE bank_account_id = Xi_Account_id;*/

BEGIN
    debug_log('>>CE_CUSTOM_BANK_VALIDATIONS.ce_usr_validate_account');
    -- Initialize Return values
    Xo_RETURN_STATUS := fnd_api.g_ret_sts_success;
    Xo_ACCOUNT_NUM_OUT := Xi_ACCOUNT_NUMBER;

    /*------------------------------------------------------------------------------
    -- TODO: Add validation at account level
    --
    debug_log('Xi_COUNTRY_NAME            ='||Xi_COUNTRY_NAME            );
    debug_log('Xi_BANK_NUMBER             ='||Xi_BANK_NUMBER             );
    debug_log('Xi_BRANCH_NUMBER           ='||Xi_BRANCH_NUMBER           );
    debug_log('Xi_ACCOUNT_NUMBER          ='||Xi_ACCOUNT_NUMBER          );
    debug_log('Xi_CD                      ='||Xi_CD                      );
    debug_log('Xi_ACCOUNT_NAME            ='||Xi_ACCOUNT_NAME            );
    debug_log('Xi_CURRENCY_CODE           ='||Xi_CURRENCY_CODE           );
    debug_log('Xi_ACCOUNT_TYPE            ='||Xi_ACCOUNT_TYPE            );
    debug_log('Xi_ACCOUNT_SUFFIX          ='||Xi_ACCOUNT_SUFFIX          );
    debug_log('Xi_SECONDARY_ACCT_REF      ='||Xi_SECONDARY_ACCT_REF      );
    debug_log('Xi_ACCT_CLASSIFICATION     ='||Xi_ACCT_CLASSIFICATION     );
    debug_log('Xi_BANK_ID                 ='||Xi_BANK_ID                 );
    debug_log('Xi_BRANCH_ID               ='||Xi_BRANCH_ID               );
    debug_log('Xi_ACCOUNT_ID              ='||Xi_ACCOUNT_ID              );

    -- Accessing bank account details using bank account id
    FOR i IN c_acct_details
    LOOP
      debug_log('acct_name='||i.bank_account_name);
      debug_log('bank_acct_num='||i.bank_account_num);
      debug_log('attr_categ='||i.attribute_category);
      debug_log('account_type='||i.bank_account_type);
    END LOOP;

    -- SAMPLE VALIDATION
    -- For country JP, where the Bank Account Number is populated, the value for
    -- the bank account type cannot be NULL nor can the length of the value for
    -- the bank account type cannot be equal to 1

    IF   (Xi_COUNTRY_NAME = 'JP')
     AND (Xi_ACCOUNT_NUMBER IS NOT NULL)
     AND ((Xi_ACCOUNT_TYPE IS NULL) OR (length(Xi_ACCOUNT_TYPE) = 1))
    THEN
            -- set error message name from Message Dictionary
            -- AND set return flag to indicate failure
            set_error_text('CE_CUSTOM_ACCOUNT');
            Xo_RETURN_STATUS := fnd_api.g_ret_sts_error;
    END IF;
    ------------------------------------------------------------------------------*/
    debug_log('<<CE_CUSTOM_BANK_VALIDATIONS.ce_usr_validate_account');

EXCEPTION
  WHEN OTHERS THEN
    debug_log('EXCEPTION: CE_CUSTOM_BANK_VALIDATIONS.ce_usr_valdiate_account');
    FND_MESSAGE.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
    FND_MESSAGE.set_token('PROCEDURE', 'CE_CUSTOM_BANK_VALIDATIONS.ce_usr_valdiate_account');
    FND_MSG_PUB.add;
    RAISE;
END ce_usr_validate_account;

END CE_CUSTOM_BANK_VALIDATIONS;

/
