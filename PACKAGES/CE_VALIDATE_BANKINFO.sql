--------------------------------------------------------
--  DDL for Package CE_VALIDATE_BANKINFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_VALIDATE_BANKINFO" AUTHID CURRENT_USER AS
/* $Header: cevlbnks.pls 120.18.12010000.7 2010/02/17 10:45:12 vnetan ship $ */

l_DEBUG varchar2(1);

FUNCTION CE_CHECK_NUMERIC(
    CHECK_VALUE VARCHAR2,
    POS_FROM    NUMBER,
    POS_FOR     NUMBER
)RETURN VARCHAR2;

FUNCTION CE_REMOVE_FORMATS(CHECK_VALUE VARCHAR2) RETURN VARCHAR2;

PROCEDURE COMPARE_BANK_AND_BRANCH_NUM(
    XI_BRANCH_NUM IN VARCHAR2,
    XI_BANK_ID    IN NUMBER);

FUNCTION COMPARE_ACCOUNT_NUM_AND_CD(
    XI_ACCOUNT_NUM IN VARCHAR2,
    XI_CD          IN NUMBER,
    XI_CD_LENGTH   IN NUMBER,
    XI_CD_POS_FROM_RIGHT IN NUMBER DEFAULT 0
) RETURN BOOLEAN;


FUNCTION CE_VAL_UNIQUE_TAX_PAYER_ID (
    P_COUNTRY_CODE    IN  VARCHAR2,
    P_TAXPAYER_ID     IN  VARCHAR2
) RETURN VARCHAR2;

PROCEDURE CE_CHECK_CROSS_MODULE_TAX_ID(
    P_COUNTRY_CODE     IN  VARCHAR2,
    P_ENTITY_NAME      IN  VARCHAR2,
    P_TAXPAYER_ID      IN  VARCHAR2,
    P_RETURN_AR        OUT NOCOPY VARCHAR2,
    P_RETURN_AP        OUT NOCOPY VARCHAR2,
    P_RETURN_HR        OUT NOCOPY VARCHAR2,
    P_RETURN_BK        OUT NOCOPY VARCHAR2);

PROCEDURE CE_VALIDATE_BIC(
    X_BIC_CODE       IN VARCHAR2,
    P_INIT_MSG_LIST  IN VARCHAR2,
    X_MSG_COUNT      OUT NOCOPY NUMBER,
    X_MSG_DATA       OUT NOCOPY VARCHAR2,
    X_RETURN_STATUS  IN OUT NOCOPY VARCHAR2);

FUNCTION CE_TAX_ID_CHECK_ALGORITHM(
    P_TAXPAYER_ID  IN VARCHAR2,
    P_COUNTRY      IN VARCHAR2,
    P_TAX_ID_CD    IN VARCHAR2
) RETURN VARCHAR2;

PROCEDURE CE_UNIQUE_BRANCH_NAME(
    XI_COUNTRY_NAME IN VARCHAR2,
    XI_BRANCH_NAME  IN VARCHAR2,
    XI_BANK_ID      IN VARCHAR2,
    XI_BRANCH_ID    IN VARCHAR2);

PROCEDURE CE_UNIQUE_BRANCH_NUMBER(
    XI_COUNTRY_NAME  IN VARCHAR2,
    XI_BRANCH_NUMBER IN VARCHAR2,
    XI_BANK_ID       IN VARCHAR2,
    XI_BRANCH_ID     IN VARCHAR2);

PROCEDURE CE_UNIQUE_BRANCH_NAME_ALT(
    XI_COUNTRY_NAME     IN VARCHAR2,
    XI_BRANCH_NAME_ALT  IN VARCHAR2,
    XI_BANK_ID          IN VARCHAR2,
    XI_BRANCH_ID        IN VARCHAR2);

PROCEDURE CE_UNIQUE_ACCOUNT_NAME(
    XI_ACCOUNT_NAME  IN VARCHAR2,
    XI_BRANCH_ID     IN VARCHAR2,
    XI_ACCOUNT_ID    IN VARCHAR2);

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_*                                                    |
 --------------------------------------------------------------------- */
PROCEDURE CE_VALIDATE_CD(
    X_COUNTRY_NAME           IN VARCHAR2,
    X_CD                     IN VARCHAR2,
    X_BANK_NUMBER            IN VARCHAR2,
    X_BRANCH_NUMBER          IN VARCHAR2,
    X_ACCOUNT_NUMBER         IN VARCHAR2,
    P_INIT_MSG_LIST          IN VARCHAR2,
    X_MSG_COUNT              OUT NOCOPY NUMBER,
    X_MSG_DATA               OUT NOCOPY VARCHAR2,
    X_RETURN_STATUS          IN OUT NOCOPY VARCHAR2,
    X_ACCOUNT_CLASSIFICATion IN VARCHAR2 DEFAULT NULL);

PROCEDURE CE_VALIDATE_BRANCH(
        X_COUNTRY_NAME            IN  VARCHAR2,
        X_BANK_NUMBER             IN  VARCHAR2,
        X_BRANCH_NUMBER           IN  VARCHAR2,
        X_BANK_NAME               IN  VARCHAR2,
        X_BRANCH_NAME             IN  VARCHAR2,
        X_BRANCH_NAME_ALT         IN  VARCHAR2,
        X_BANK_ID                 IN  NUMBER,
        X_BRANCH_ID               IN  NUMBER,
        P_INIT_MSG_LIST           IN  VARCHAR2,
        X_MSG_COUNT               OUT NOCOPY NUMBER,
        X_MSG_DATA                OUT NOCOPY VARCHAR2,
        X_VALUE_OUT               OUT NOCOPY varchar2,
        X_RETURN_STATUS           IN  OUT NOCOPY VARCHAR2,
        X_ACCOUNT_CLASSIFICATION  IN  VARCHAR2 DEFAULT NULL,
        X_BRANCH_TYPE             IN  VARCHAR2 DEFAULT NULL); -- 9218190 added

PROCEDURE CE_VALIDATE_ACCOUNT(
        X_COUNTRY_NAME             IN VARCHAR2,
        X_BANK_NUMBER              IN VARCHAR2,
        X_BRANCH_NUMBER            IN VARCHAR2,
        X_ACCOUNT_NUMBER           IN VARCHAR2,
        X_BANK_ID                  IN NUMBER,
        X_BRANCH_ID                IN NUMBER,
        X_ACCOUNT_ID               IN NUMBER,
        X_CURRENCY_CODE            IN VARCHAR2,
        X_ACCOUNT_TYPE             IN VARCHAR2,
        X_ACCOUNT_SUFFIX           IN VARCHAR2,
        X_SECONDARY_ACCOUNT_REFERENCE    IN VARCHAR2,
        X_ACCOUNT_NAME             IN VARCHAR2,
        P_INIT_MSG_LIST            IN  VARCHAR2,
        X_MSG_COUNT                OUT NOCOPY NUMBER,
        X_MSG_DATA                 OUT NOCOPY VARCHAR2,
        X_VALUE_OUT                OUT NOCOPY VARCHAR2,
        X_RETURN_STATUS            IN OUT NOCOPY VARCHAR2,
        X_ACCOUNT_CLASSIFICATION   IN VARCHAR2 DEFAULT NULL,
        X_CD                       IN  VARCHAR2  DEFAULT NULL,
        X_ELECTRONIC_ACCT_NUM      OUT NOCOPY VARCHAR2);

PROCEDURE CE_VALIDATE_BANK(
        X_COUNTRY_NAME           IN VARCHAR2,
        X_BANK_NUMBER            IN VARCHAR2,
        X_BANK_NAME              IN VARCHAR2,
        X_BANK_NAME_ALT          IN VARCHAR2,
        X_TAX_PAYER_ID           IN VARCHAR2,
        X_BANK_ID                IN NUMBER,
        p_init_msg_list          IN VARCHAR2,
        x_msg_count              OUT NOCOPY NUMBER,
        x_msg_data               OUT NOCOPY VARCHAR2,
        X_VALUE_OUT              OUT NOCOPY Varchar2,
        x_return_status          IN OUT NOCOPY VARCHAR2,
        X_ACCOUNT_CLASSIFICATION IN VARCHAR2 DEFAULT NULL);

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_CD_*                                                 |
 --------------------------------------------------------------------- */
PROCEDURE CE_VALIDATE_CD_PT(
    Xi_CD               VARCHAR2,
    Xi_PASS_MAND_CHECK  VARCHAR2,
    Xi_X_BANK_NUMBER    VARCHAR2,
    Xi_X_BRANCH_NUMBER  VARCHAR2,
    Xi_X_ACCOUNT_NUMBER VARCHAR2);

PROCEDURE CE_VALIDATE_CD_ES(
    Xi_CD               VARCHAR2,
    Xi_PASS_MAND_CHECK  VARCHAR2,
    Xi_X_BANK_NUMBER    VARCHAR2,
    Xi_X_BRANCH_NUMBER  VARCHAR2,
    Xi_X_ACCOUNT_NUMBER VARCHAR2);


PROCEDURE CE_VALIDATE_CD_FR(
    Xi_CD               VARCHAR2,
    Xi_PASS_MAND_CHECK  VARCHAR2,
    Xi_X_BANK_NUMBER    VARCHAR2,
    Xi_X_BRANCH_NUMBER  VARCHAR2,
    Xi_X_ACCOUNT_NUMBER VARCHAR2);

-- new validations for check digits 5/14/02
PROCEDURE CE_VALIDATE_CD_DE(
    Xi_CD               IN VARCHAR2,
    Xi_X_ACCOUNT_NUMBER IN VARCHAR2);

PROCEDURE CE_VALIDATE_CD_GR(
    Xi_CD               IN VARCHAR2,
    Xi_PASS_MAND_CHECK  IN VARCHAR2,
    Xi_X_BANK_NUMBER    IN VARCHAR2,
    Xi_X_BRANCH_NUMBER  IN VARCHAR2,
    Xi_X_ACCOUNT_NUMBER IN VARCHAR2);

PROCEDURE CE_VALIDATE_CD_IS(
    Xi_CD               IN VARCHAR2,
    Xi_X_ACCOUNT_NUMBER IN VARCHAR2);

PROCEDURE CE_VALIDATE_CD_IT(
    Xi_CD               IN VARCHAR2,
    Xi_PASS_MAND_CHECK  IN VARCHAR2,
    Xi_X_BANK_NUMBER    IN VARCHAR2,
    Xi_X_BRANCH_NUMBER  IN VARCHAR2,
    Xi_X_ACCOUNT_NUMBER IN VARCHAR2);

PROCEDURE CE_VALIDATE_CD_LU(
    Xi_CD               IN VARCHAR2,
    Xi_X_BANK_NUMBER    IN VARCHAR2,
    Xi_X_BRANCH_NUMBER  IN VARCHAR2,
    Xi_X_ACCOUNT_NUMBER IN VARCHAR2);

PROCEDURE CE_VALIDATE_CD_SE(
    Xi_CD               IN VARCHAR2,
    Xi_X_ACCOUNT_NUMBER IN VARCHAR2);

-- 9249372: Added ce_validate_cd_fi
PROCEDURE CE_VALIDATE_CD_FI(
    Xi_CD               IN VARCHAR2,
    Xi_X_BRANCH_NUMBER  IN VARCHAR2,
    Xi_X_ACCOUNT_NUMBER IN VARCHAR2);

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_BRANCH_*                                             |
 --------------------------------------------------------------------- */
PROCEDURE CE_VALIDATE_BRANCH_AT(
    Xi_BRANCH_NUMBER    VARCHAR2,
    Xi_PASS_MAND_CHECK  VARCHAR2,
    Xo_VALUE_OUT        OUT NOCOPY VARCHAR2);

PROCEDURE CE_VALIDATE_BRANCH_PT(
    Xi_BRANCH_NUMBER    VARCHAR2,
    Xi_PASS_MAND_CHECK  VARCHAR2);

PROCEDURE CE_VALIDATE_BRANCH_FR(
    Xi_BRANCH_NUMBER    VARCHAR2,
    Xi_PASS_MAND_CHECK  VARCHAR2,
    Xo_VALUE_OUT        OUT NOCOPY VARCHAR2);

PROCEDURE CE_VALIDATE_BRANCH_ES(
    Xi_BRANCH_NUMBER    VARCHAR2,
    Xi_PASS_MAND_CHECK  VARCHAR2,
    Xo_VALUE_OUT        OUT NOCOPY varchar2);

PROCEDURE CE_VALIDATE_BRANCH_BR(
    Xi_BRANCH_NUMBER    VARCHAR2,
    Xi_PASS_MAND_CHECK  VARCHAR2,
    Xo_VALUE_OUT        OUT NOCOPY varchar2);

-- new branch validations 5/14/02
PROCEDURE CE_VALIDATE_BRANCH_DE(
    Xi_BRANCH_NUMBER  IN VARCHAR2,
    Xi_BANK_ID        IN NUMBER);

PROCEDURE CE_VALIDATE_BRANCH_GR(Xi_BRANCH_NUMBER IN VARCHAR2);

PROCEDURE CE_VALIDATE_BRANCH_IS(
    Xi_BRANCH_NUMBER  IN VARCHAR2,
    Xi_BANK_ID        IN NUMBER,
    Xo_VALUE_OUT      OUT NOCOPY VARCHAR2);

PROCEDURE CE_VALIDATE_BRANCH_IE(
    Xi_BRANCH_NUMBER  IN VARCHAR2,
    Xi_BANK_ID        IN NUMBER);

PROCEDURE CE_VALIDATE_BRANCH_IT(
    Xi_BRANCH_NUMBER   IN VARCHAR2,
    Xi_PASS_MAND_CHECK IN VARCHAR2);

PROCEDURE CE_VALIDATE_BRANCH_LU(
    Xi_BRANCH_NUMBER  IN VARCHAR2,
    Xi_BANK_ID        IN NUMBER);

PROCEDURE CE_VALIDATE_BRANCH_PL(
    Xi_BRANCH_NUMBER  IN VARCHAR2,
    Xi_BANK_ID        IN NUMBER);

PROCEDURE CE_VALIDATE_BRANCH_SE(
    Xi_BRANCH_NUMBER  IN VARCHAR2,
    Xi_BANK_ID        IN NUMBER);

PROCEDURE CE_VALIDATE_BRANCH_CH(
    Xi_BRANCH_NUMBER  IN varchar2,
    Xi_BANK_ID        IN NUMBER);

PROCEDURE CE_VALIDATE_BRANCH_GB(
    Xi_BRANCH_NUMBER  IN VARCHAR2,
    Xi_BANK_ID        IN NUMBER);

PROCEDURE CE_VALIDATE_BRANCH_US(
    Xi_BRANCH_NUMBER    IN VARCHAR2,
    Xi_PASS_MAND_CHECK  IN VARCHAR2,
    Xo_VALUE_OUT        OUT NOCOPY VARCHAR2);

-- new branch validations 10/19/04
PROCEDURE CE_VALIDATE_BRANCH_AU(
    Xi_BRANCH_NUMBER    IN VARCHAR2,
    Xi_BANK_ID          IN NUMBER,
    Xi_PASS_MAND_CHECK  VARCHAR2);

PROCEDURE CE_VALIDATE_BRANCH_IL(
    Xi_BRANCH_NUMBER    IN VARCHAR2,
    Xi_PASS_MAND_CHECK  VARCHAR2);

PROCEDURE CE_VALIDATE_BRANCH_NZ(
    Xi_BRANCH_NUMBER    IN VARCHAR2,
    Xi_PASS_MAND_CHECK  VARCHAR2);

PROCEDURE CE_VALIDATE_BRANCH_JP(
    Xi_BRANCH_NUMBER    IN VARCHAR2,
    Xi_BRANCH_NAME_ALT  IN VARCHAR2,
    Xi_PASS_MAND_CHECK  VARCHAR2);

-- 9249372: Added ce_validate_branch_fi
PROCEDURE CE_VALIDATE_BRANCH_FI(Xi_BRANCH_NUMBER IN VARCHAR2);

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_ACCOUNT_*                                            |
 --------------------------------------------------------------------- */
PROCEDURE CE_VALIDATE_ACCOUNT_AT(
    Xi_ACCOUNT_NUMBER   VARCHAR2,
    Xi_PASS_MAND_CHECK  VARCHAR2,
    Xo_VALUE_OUT        OUT NOCOPY varchar2);

PROCEDURE CE_VALIDATE_ACCOUNT_PT(
    Xi_ACCOUNT_NUMBER   VARCHAR2,
    Xi_PASS_MAND_CHECK  VARCHAR2,
    Xo_VALUE_OUT        OUT NOCOPY varchar2);

PROCEDURE CE_VALIDATE_ACCOUNT_BE(
    Xi_ACCOUNT_NUMBER   VARCHAR2,
    Xi_PASS_MAND_CHECK  VARCHAR2);

PROCEDURE CE_VALIDATE_ACCOUNT_DK(
    Xi_ACCOUNT_NUMBER   VARCHAR2,
    Xi_PASS_MAND_CHECK  VARCHAR2,
    Xo_VALUE_OUT        OUT NOCOPY varchar2);

PROCEDURE CE_VALIDATE_ACCOUNT_FR(
    Xi_ACCOUNT_NUMBER   VARCHAR2,
    Xi_PASS_MAND_CHECK  VARCHAR2,
    Xo_VALUE_OUT        OUT NOCOPY VARCHAR2);

PROCEDURE CE_VALIDATE_ACCOUNT_NL(
    Xi_ACCOUNT_NUMBER   VARCHAR2,
    Xi_PASS_MAND_CHECK  VARCHAR2);

PROCEDURE CE_VALIDATE_ACCOUNT_ES(
    Xi_ACCOUNT_NUMBER   VARCHAR2,
    Xi_PASS_MAND_CHECK  VARCHAR2,
    Xo_VALUE_OUT        OUT NOCOPY VARCHAR2);

PROCEDURE CE_VALIDATE_ACCOUNT_NO(
    Xi_ACCOUNT_NUMBER   VARCHAR2,
    Xi_PASS_MAND_CHECK  VARCHAR2);

PROCEDURE CE_VALIDATE_ACCOUNT_FI(
    Xi_ACCOUNT_NUMBER   VARCHAR2,
    Xi_PASS_MAND_CHECK  VARCHAR2);

-- new account validations 5/14/02
PROCEDURE CE_VALIDATE_ACCOUNT_DE(
    Xi_ACCOUNT_NUMBER   IN VARCHAR2,
    Xo_VALUE_OUT        OUT NOCOPY VARCHAR2);

PROCEDURE CE_VALIDATE_ACCOUNT_GR(
    Xi_ACCOUNT_NUMBER   IN VARCHAR2,
    Xo_VALUE_OUT        OUT NOCOPY VARCHAR2);

PROCEDURE CE_VALIDATE_ACCOUNT_IS(
    Xi_ACCOUNT_NUMBER   IN VARCHAR2,
    Xo_VALUE_OUT        OUT NOCOPY VARCHAR2);

PROCEDURE CE_VALIDATE_ACCOUNT_IE(
    Xi_ACCOUNT_NUMBER  IN VARCHAR2);

PROCEDURE CE_VALIDATE_ACCOUNT_IT(
    Xi_ACCOUNT_NUMBER   IN VARCHAR2,
    Xo_VALUE_OUT        OUT NOCOPY VARCHAR2);

PROCEDURE CE_VALIDATE_ACCOUNT_LU(Xi_ACCOUNT_NUMBER IN VARCHAR2);

PROCEDURE CE_VALIDATE_ACCOUNT_PL(Xi_ACCOUNT_NUMBER IN VARCHAR2);

PROCEDURE CE_VALIDATE_ACCOUNT_SE(Xi_ACCOUNT_NUMBER IN VARCHAR2);

PROCEDURE CE_VALIDATE_ACCOUNT_CH(
    Xi_ACCOUNT_NUMBER  IN VARCHAR2,
    Xi_ACCOUNT_TYPE    IN VARCHAR2);

PROCEDURE CE_VALIDATE_ACCOUNT_GB(
    Xi_ACCOUNT_NUMBER   IN VARCHAR2,
    Xo_VALUE_OUT        OUT NOCOPY VARCHAR2);

PROCEDURE CE_VALIDATE_ACCOUNT_BR(
    Xi_ACCOUNT_NUMBER               IN VARCHAR2,
    Xi_SECONDARY_ACCOUNT_REFERENCE  IN VARCHAR2);

-- new account validations 10/19/04 Bug 6760446 added currency code
PROCEDURE CE_VALIDATE_ACCOUNT_AU(
    Xi_ACCOUNT_NUMBER   IN VARCHAR2,
    Xi_CURRENCY_CODE    IN VARCHAR2);

PROCEDURE CE_VALIDATE_ACCOUNT_IL(Xi_ACCOUNT_NUMBER IN VARCHAR2);

PROCEDURE CE_VALIDATE_ACCOUNT_NZ(
    Xi_ACCOUNT_NUMBER  IN VARCHAR2,
    Xi_ACCOUNT_SUFFIX  IN VARCHAR2);

PROCEDURE CE_VALIDATE_ACCOUNT_JP(
    Xi_ACCOUNT_NUMBER  IN VARCHAR2,
    Xi_ACCOUNT_TYPE    IN VARCHAR2);

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_BANK_*                                               |
 --------------------------------------------------------------------- */
PROCEDURE CE_VALIDATE_BANK_ES(
    Xi_BANK_NUMBER      VARCHAR2,
    Xi_PASS_MAND_CHECK  VARCHAR2,
    Xo_VALUE_OUT        OUT NOCOPY VARCHAR2);

PROCEDURE CE_VALIDATE_BANK_FR(
    Xi_BANK_NUMBER      VARCHAR2,
    Xi_PASS_MAND_CHECK  VARCHAR2,
    Xo_VALUE_OUT        OUT NOCOPY VARCHAR2);

PROCEDURE CE_VALIDATE_BANK_PT(
    Xi_BANK_NUMBER      VARCHAR2,
    Xi_PASS_MAND_CHECK  VARCHAR2);


PROCEDURE CE_VALIDATE_BANK_BR(
    Xi_BANK_NUMBER      VARCHAR2,
    Xi_PASS_MAND_CHECK  VARCHAR2,
    Xo_VALUE_OUT        OUT NOCOPY VARCHAR2);

-- new bank validations 5/14/02
PROCEDURE CE_VALIDATE_BANK_DE(Xi_BANK_NUMBER IN VARCHAR2);

PROCEDURE CE_VALIDATE_BANK_GR(Xi_BANK_NUMBER IN VARCHAR2);

PROCEDURE CE_VALIDATE_BANK_IS(
    Xi_BANK_NUMBER  IN VARCHAR2,
    Xo_VALUE_OUT    OUT NOCOPY VARCHAR2);

PROCEDURE CE_VALIDATE_BANK_IE(Xi_BANK_NUMBER IN VARCHAR2);

PROCEDURE CE_VALIDATE_BANK_IT(
    Xi_BANK_NUMBER      IN VARCHAR2,
    Xi_PASS_MAND_CHECK  IN VARCHAR2);

PROCEDURE CE_VALIDATE_BANK_LU(Xi_BANK_NUMBER IN VARCHAR2);

PROCEDURE CE_VALIDATE_BANK_PL(Xi_BANK_NUMBER IN VARCHAR2);

PROCEDURE CE_VALIDATE_BANK_SE(Xi_BANK_NUMBER IN VARCHAR2);

PROCEDURE CE_VALIDATE_BANK_CH(Xi_BANK_NUMBER IN VARCHAR2);

PROCEDURE CE_VALIDATE_BANK_GB(Xi_BANK_NUMBER IN VARCHAR2);

PROCEDURE CE_VALIDATE_BANK_CO(
    Xi_COUNTRY_NAME IN VARCHAR2,
    Xi_BANK_NAME    IN VARCHAR2,
    Xi_TAX_PAYER_ID IN VARCHAR2);

-- new bank validations 10/19/04
PROCEDURE CE_VALIDATE_BANK_AU(
    Xi_BANK_NUMBER  in varchar2);

PROCEDURE CE_VALIDATE_BANK_IL(
    Xi_BANK_NUMBER      IN VARCHAR2,
    Xi_PASS_MAND_CHECK  IN VARCHAR2);

PROCEDURE CE_VALIDATE_BANK_NZ(
    Xi_BANK_NUMBER      IN VARCHAR2,
    Xi_PASS_MAND_CHECK  IN VARCHAR2);

PROCEDURE CE_VALIDATE_BANK_JP(
    Xi_BANK_NUMBER      IN VARCHAR2,
    Xi_BANK_NAME_ALT    IN VARCHAR2,
    Xi_PASS_MAND_CHECK  IN VARCHAR2);

-- 8266356: Added
PROCEDURE CE_VALIDATE_BANK_AT(
    Xi_BANK_NUMBER      VARCHAR2,
    Xi_PASS_MAND_CHECK  VARCHAR2,
    Xo_VALUE_OUT        OUT NOCOPY varchar2);

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_UNIQUE_ACCOUNT_*                                     |
 --------------------------------------------------------------------- */
PROCEDURE CE_VALIDATE_UNIQUE_ACCOUNT(
    Xi_ACCOUNT_NUMBER   IN VARCHAR2,
    Xi_CURRENCY_CODE    IN VARCHAR2,
    Xi_ACCOUNT_NAME     IN VARCHAR2,
    Xi_BRANCH_ID        IN NUMBER,
    Xi_ACCOUNT_ID       IN NUMBER);

PROCEDURE CE_VALIDATE_UNIQUE_ACCOUNT_JP(
    Xi_ACCOUNT_NUMBER   IN VARCHAR2,
    Xi_CURRENCY_CODE    IN VARCHAR2,
    Xi_ACCOUNT_TYPE     IN VARCHAR2,
    Xi_ACCOUNT_NAME     IN VARCHAR2,
    Xi_BRANCH_ID        IN NUMBER,
    Xi_ACCOUNT_ID       IN NUMBER);

PROCEDURE CE_VALIDATE_UNIQUE_ACCOUNT_NZ(
    Xi_ACCOUNT_NUMBER   IN VARCHAR2,
    Xi_CURRENCY_CODE    IN VARCHAR2,
    Xi_ACCOUNT_SUFFIX   IN VARCHAR2,
    Xi_ACCOUNT_NAME     IN VARCHAR2,
    Xi_BRANCH_ID        IN NUMBER,
    Xi_ACCOUNT_ID       IN NUMBER);

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|   CE_FORMAT_ELECTRONIC_NUM                                            |
|    Description:  Format CE_BANK_ACCOUNTS.BANK_ACCOUNT_NUM_ELECTRONIC  |
|    CALLED BY:    CE_VALIDATE_ACCOUNT                                  |
|    Calls:        CE_FORMAT_ELECTRONIC_NUM_*                           |
 --------------------------------------------------------------------- */
PROCEDURE CE_FORMAT_ELECTRONIC_NUM(
    X_COUNTRY_NAME              IN VARCHAR2,
    X_BANK_NUMBER               IN VARCHAR2,
    X_BRANCH_NUMBER             IN VARCHAR2,
    X_ACCOUNT_NUMBER            IN VARCHAR2,
    X_CD                        IN  VARCHAR2  DEFAULT NULL,
    X_ACCOUNT_SUFFIX            IN VARCHAR2,
    X_SECONDARY_ACCOUNT_REFERENCE  IN varchar2,
    X_ACCOUNT_CLASSIFICATION    IN VARCHAR2 DEFAULT NULL,
    X_ELECTRONIC_ACCT_NUM       OUT NOCOPY varchar2,
    p_init_msg_list             IN VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_return_status             IN OUT NOCOPY VARCHAR2);

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_UNIQUE_BRANCH_*                                      |
 --------------------------------------------------------------------- */
PROCEDURE CE_VALIDATE_UNIQUE_BRANCH(
    Xi_COUNTRY_NAME   IN VARCHAR2,
    Xi_BRANCH_NUMBER  IN VARCHAR2,
    Xi_BRANCH_NAME    IN VARCHAR2,
    Xi_BANK_ID        IN NUMBER,
    Xi_BRANCH_ID      IN NUMBER);

PROCEDURE CE_VALIDATE_UNIQUE_BRANCH_JP(
    Xi_COUNTRY_NAME    IN VARCHAR2,
    Xi_BRANCH_NUMBER   IN VARCHAR2,
    Xi_BRANCH_NAME     IN VARCHAR2,
    Xi_BRANCH_NAME_ALT IN VARCHAR2,
    Xi_BANK_ID         IN NUMBER,
    Xi_BRANCH_ID       IN NUMBER);

PROCEDURE CE_VALIDATE_UNIQUE_BRANCH_DE(
    Xi_BRANCH_NUMBER    IN VARCHAR2,
    Xi_BRANCH_NAME      IN VARCHAR2,
    Xi_BANK_ID          IN NUMBER,
    Xi_BRANCH_ID        IN NUMBER);

PROCEDURE CE_VALIDATE_UNIQUE_BRANCH_US(
    Xi_BRANCH_NUMBER    IN VARCHAR2,
    Xi_BRANCH_NAME      IN VARCHAR2,
    Xi_BANK_ID          IN NUMBER,
    Xi_BRANCH_ID        IN NUMBER);

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_UNIQUE_BANK_*                                        |
 --------------------------------------------------------------------- */
PROCEDURE CE_VALIDATE_UNIQUE_BANK_JP(
    Xi_COUNTRY_NAME     IN VARCHAR2,
    Xi_BANK_NUMBER      IN VARCHAR2,
    Xi_BANK_NAME        IN VARCHAR2,
    Xi_BANK_NAME_ALT    IN VARCHAR2,
    Xi_BANK_ID          IN VARCHAR2);

-- added 10/25/04
/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_MISC_*   other misc validations
 --------------------------------------------------------------------- */
PROCEDURE CE_VALIDATE_MISC_EFT_NUM(
    X_COUNTRY_NAME  IN VARCHAR2,
    X_EFT_NUMBER    IN VARCHAR2,
    P_INIT_MSG_LIST IN VARCHAR2,
    X_MSG_COUNT     OUT NOCOPY NUMBER,
    X_MSG_DATA      OUT NOCOPY VARCHAR2,
    X_RETURN_STATUS IN OUT NOCOPY VARCHAR2);

PROCEDURE CE_VALIDATE_MISC_ACCT_HLDR_ALT(
    X_COUNTRY_NAME          IN VARCHAR2,
    X_ACCOUNT_HOLDER_ALT    IN VARCHAR2,
    X_ACCOUNT_CLASSIFICATION    IN VARCHAR2,
    P_INIT_MSG_LIST         IN VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,
    X_RETURN_STATUS         IN OUT NOCOPY VARCHAR2);

-- added 12/18/06
PROCEDURE CE_VALIDATE_BRANCH_IS_FORMAT(
    Xi_BRANCH_NUMBER    IN VARCHAR2,
    Xo_VALUE_OUT        OUT NOCOPY VARCHAR2);

PROCEDURE GET_BRANCH_NUM_FORMAT(
    X_COUNTRY_NAME   IN VARCHAR2,
    X_BRANCH_NUMBER  IN VARCHAR2,
    X_VALUE_OUT      OUT NOCOPY VARCHAR2,
    P_INIT_MSG_LIST  IN VARCHAR2,
    X_MSG_COUNT      OUT NOCOPY NUMBER,
    X_MSG_DATA       OUT NOCOPY VARCHAR2,
    X_RETURN_STATUS  IN OUT NOCOPY VARCHAR2);

-- Bug 6856840: Added wrapper procedure for Branch Validations
PROCEDURE CE_VALIDATE_BRANCH_BANK (
    Xi_COUNTRY     IN varchar2,
    Xi_BRANCH_NUM  IN varchar2,
    Xi_BANK_NUM    IN varchar2,
    Xo_VALUE_OUT   OUT NOCOPY varchar2);

/* 7582842: The following procedures are no longer used by CE:
    1) UPD_BANK_UNIQUE
    2) UPD_BANK_VALIDATE
    3) UPD_BRANCH_UNIQUE
    4) UPD_BRANCH_VALIDATE
    5) UPD_ACCOUNT_UNIQUE
    6) UPD_ACCOUNT_VALIDATE
   But, these have been retained due to possible dependencies in IBY */

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
        p_init_msg_list   IN VARCHAR2,
        x_msg_count       OUT NOCOPY NUMBER,
        x_msg_data        OUT NOCOPY VARCHAR2,
        X_VALUE_OUT       OUT NOCOPY varchar2,
        x_return_status   IN OUT NOCOPY VARCHAR2,
        X_ACCOUNT_CLASSIFICATION IN VARCHAR2 DEFAULT NULL);

/* -------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                   |
|   UPD_ACCOUNT_VALIDATE                                              |
|    Description:  Country specific Bank Account validation           |
|                  that does not include the uniqueness validations   |
|    Usage: Bug 7582842 - No longer called by CE                      |
|    Calls: CE_VALIDATE_ACCOUNT_*                                     |
 --------------------------------------------------------------------*/
PROCEDURE UPD_ACCOUNT_VALIDATE(
        X_COUNTRY_NAME              IN varchar2,
        X_BANK_NUMBER               IN varchar2,
        X_BRANCH_NUMBER             IN varchar2,
        X_ACCOUNT_NUMBER            IN varchar2,
        X_BANK_ID                   IN number,
        X_BRANCH_ID                 IN number,
        X_ACCOUNT_ID                IN number,
        X_CURRENCY_CODE             IN varchar2,
        X_ACCOUNT_TYPE              IN varchar2,
        X_ACCOUNT_SUFFIX            IN varchar2,
        X_SECONDARY_ACCOUNT_REFERENCE  IN varchar2,
        X_ACCOUNT_NAME              IN VARCHAR2,
        p_init_msg_list             IN  VARCHAR2,
        x_msg_count                 OUT NOCOPY NUMBER,
        x_msg_data                  OUT NOCOPY VARCHAR2,
        X_VALUE_OUT                 OUT NOCOPY varchar2,
        x_return_status             IN OUT NOCOPY VARCHAR2,
        X_ACCOUNT_CLASSIFICATION    IN VARCHAR2 DEFAULT NULL,
        X_CD                        IN  varchar2  DEFAULT NULL,
        X_ELECTRONIC_ACCT_NUM       OUT NOCOPY varchar2);

/* -------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                   |
|   UPD_BRANCH_UNIQUE                                                 |
|    Description:  Branch uniqueness validation                       |
|    Usage:        Bug 7582842 - No longer called by CE               |
|    Calls:        CE_VALIDATE_UNIQUE_BRANCH_*                        |
 ------------------------------------------------------------------- */
PROCEDURE UPD_BRANCH_UNIQUE(
        X_COUNTRY_NAME     IN  varchar2,
        X_BANK_NUMBER      IN  varchar2,
        X_BRANCH_NUMBER    IN  varchar2,
        X_BANK_NAME        IN  varchar2,
        X_BRANCH_NAME      IN  varchar2,
        X_BRANCH_NAME_ALT  IN  varchar2,
        X_BANK_ID          IN  NUMBER,
        X_BRANCH_ID        IN  NUMBER,
        p_init_msg_list    IN  VARCHAR2,
        x_msg_count        OUT NOCOPY NUMBER,
        x_msg_data         OUT NOCOPY VARCHAR2,
        X_VALUE_OUT        OUT NOCOPY varchar2,
        x_return_status    IN OUT NOCOPY VARCHAR2,
        X_ACCOUNT_CLASSIFICATION IN VARCHAR2 DEFAULT NULL);

/* -------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                   |
|   UPD_BRANCH_VALIDATE                                               |
|    Description:  Country specific Branch validation                 |
|                  that does not include the uniqueness validation    |
|    Usage:        Bug 7582842 - No longer called by CE               |
|    Calls:        CE_VALIDATE_BRANCH_*                               |
 --------------------------------------------------------------------*/
PROCEDURE UPD_BRANCH_VALIDATE(
        X_COUNTRY_NAME     IN  VARCHAR2,
        X_BANK_NUMBER      IN  VARCHAR2,
        X_BRANCH_NUMBER    IN  VARCHAR2,
        X_BANK_NAME        IN  VARCHAR2,
        X_BRANCH_NAME      IN  VARCHAR2,
        X_BRANCH_NAME_ALT  IN  VARCHAR2,
        X_BANK_ID          IN  NUMBER,
        X_BRANCH_ID        IN  NUMBER,
        p_init_msg_list    IN  VARCHAR2,
        x_msg_count       OUT NOCOPY NUMBER,
        x_msg_data        OUT NOCOPY VARCHAR2,
        X_VALUE_OUT       OUT NOCOPY VARCHAR2,
        x_return_status   IN OUT NOCOPY VARCHAR2,
        X_ACCOUNT_CLASSIFICATION IN VARCHAR2 DEFAULT NULL,
        X_BRANCH_TYPE IN VARCHAR2 DEFAULT NULL); -- 9218190 added

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
        X_ACCOUNT_CLASSIFICATION IN VARCHAR2 DEFAULT NULL);


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
    x_return_status   IN OUT NOCOPY VARCHAR2,
    X_ACCOUNT_CLASSIFICATION IN VARCHAR2 DEFAULT NULL);


END CE_VALIDATE_BANKINFO;

/
