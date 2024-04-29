--------------------------------------------------------
--  DDL for Package CE_BANK_AND_ACCOUNT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_BANK_AND_ACCOUNT_UTIL" AUTHID CURRENT_USER AS
/*$Header: cebautls.pls 120.2.12010000.4 2009/07/28 08:30:10 ckansara ship $ */

  /*=======================================================================+
   | Array of bank_account_id                                              |
   +=======================================================================*/
  TYPE BankAcctIdTable IS TABLE OF ce_bank_accounts.bank_account_id%TYPE;

  /*=======================================================================+
   | PUBLIC FUNCTION get_masked_bank_acct_num                              |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   This function takes a bank_account_id and returns the bank account  |
   |   number with the appropriate mask based on the value of the profile  |
   |   option 'CE: Mask Internal Bank Account Numbers'                     |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_bank_acct_id                                                    |
   +=======================================================================*/
   FUNCTION get_masked_bank_acct_num(p_bank_acct_id	IN NUMBER) RETURN VARCHAR2;

   /*=======================================================================+
   | PUBLIC FUNCTION get_masked_IBAN                                       |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   This function takes a bank_account_id and returns the IBAN          |
   |   number with the appropriate mask based on the value of the profile  |
   |   option 'CE: Mask Internal Bank Account Numbers'                     |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_bank_acct_id                                                    |
   +=======================================================================*/
   FUNCTION get_masked_IBAN(p_bank_acct_id	IN NUMBER) RETURN VARCHAR2;

  /*=======================================================================+
   | PUBLIC FUNCTION get_org_bank_acct_list                                |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   This function takes a org_id and returns the list of bank accounts  |
   |   that this org has access                                            |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_org_id                                                          |
   | RETURN                                                                |
   |   '@' deliminated bank_account_id's                                   |
   +=======================================================================*/
   FUNCTION get_org_bank_acct_list(p_org_id     IN NUMBER) RETURN VARCHAR2;



  /*=======================================================================+
   | PUBLIC PRECEDURE sql_error                                            |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   This procedure sets the error message and raise an exception        |
   |   for unhandled sql errors.                                           |
   |   Called by other routines.                                           |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_routine                                                         |
   |     p_errcode                                                         |
   |     p_errmsg                                                          |
   +=======================================================================*/
   PROCEDURE sql_error(p_routine    IN VARCHAR2,
                       p_errcode    IN NUMBER,
                       p_errmsg     IN VARCHAR2);


  /*=======================================================================+
   | PUBLIC PRECEDURE get_internal_bank_accts                              |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   This procedure returns the list of internal bank accounts given the |
   |   conditions of date, currency, and organization that uses this BA.   |
   |									   |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_currency                                                        |
   |     p_org_id                                                          |
   |     p_date                                                            |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_bank_acct_ids  '@' deliminated bank_account_id's                |
   +=======================================================================*/
   PROCEDURE get_internal_bank_accts (p_currency      IN  VARCHAR2,
                                      p_org_type      IN  VARCHAR2,
                       		      p_org_id        IN  NUMBER,
                       		      p_date          IN  DATE,
				      x_bank_acct_ids OUT NOCOPY BankAcctIdTable);

 /*=======================================================================+
   | PUBLIC PRECEDURE get_internal_bank_accts            For bug 8277703              |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   This procedure returns the list of internal bank accounts given the |
   |   conditions of date, currency, and organization that uses this BA.   |
   |									   |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_currency                                                        |
   |     p_org_id                                                          |
   |     p_date                                                            |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     p_internal_bank_account_id                                        |
   |     p_valid_flag                                                      |
   +=======================================================================*/
   PROCEDURE get_internal_bank_accts (p_currency      IN  VARCHAR2,
                                      p_org_type      IN  VARCHAR2,
                       		          p_org_id        IN  NUMBER,
                       		          p_date          IN  DATE,
				                      p_internal_bank_account_id IN OUT NOCOPY NUMBER,
                                      p_valid_flag OUT NOCOPY BOOLEAN);

END CE_BANK_AND_ACCOUNT_UTIL;

/
