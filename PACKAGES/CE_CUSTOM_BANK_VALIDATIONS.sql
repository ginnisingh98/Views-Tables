--------------------------------------------------------
--  DDL for Package CE_CUSTOM_BANK_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_CUSTOM_BANK_VALIDATIONS" AUTHID CURRENT_USER AS
/* $Header: cecbnkvs.pls 120.1.12010000.2 2009/12/24 06:56:44 vnetan noship $ */
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
    );

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
    );

    /*----------------------------------------------------------------------+
    | PUBLIC PROCEDURE                                                      |
    |   ce_usr_validate_account                                             |
    |                                                                       |
    | DESCRIPTION                                                           |
    |   This will be called when validating a bank account from the Bank    |
    |   Account Setup UI.                                                   |
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
    );

END CE_CUSTOM_BANK_VALIDATIONS;

/
