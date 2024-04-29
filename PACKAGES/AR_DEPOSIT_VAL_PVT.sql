--------------------------------------------------------
--  DDL for Package AR_DEPOSIT_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_DEPOSIT_VAL_PVT" AUTHID CURRENT_USER AS
/* $Header: ARXDEPVS.pls 115.2 2003/07/10 01:00:43 anukumar noship $*/

/*========================================================================
 | PUBLIC PROCEDURE Validate_Deposit
 |
 | DESCRIPTION
 |      Enter a brief description of what the package procedure does.
 |      ----------------------------------------
 |    This procedure does the following ......      |
 |    Perform some of basic validation
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Enter a list of all local procedures and functions which
 |      are call this package.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      Enter a list of all local procedures and funtions which
 |      this package calls.
 |      Validate_deposit_Date
 |      Validate_batch_source'
 |      Validate_Gl_Date
 |      Validate_amount
 |      Validate_Exchange_Rate
 |      Is_currency_valid
 |      Validate_Currency
 |      arp_util.debug(
 |      FND_MESSAGE.SET_NAME
 |      FND_MSG_PUB.Add;
 |
 | PARAMETERS
 | Parameter			Type	Description
 | p_batch_source_id    	IN      Batch source
 | p_deposit_date   		IN 	Deposit date
 | p_gl_date        		IN 	Gl Date
 | p_doc_sequence_value 	IN      Doc seq no value
 | p_amount         		IN      Deposit amount
 | p_currency_code  		IN      Currenct code
 | p_exchange_rate_type		IN      Exchange type
 | p_exchange_rate  		IN      Exchange rate
 | p_exchange_rate_date		IN      Exchange rate date
 | p_printing_option		IN      Printing option
 | p_status_trx     		IN      Transaction status
 | p_default_tax_exempt_flag	IN      Tax exempt flag
 | p_financial_charges		IN      Financial Charges
 | p_return_status 		OUT NOCOPY     Return Status
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-MAY-2001           Anuj              Created
 | DD-MON-YYYY           Name              Bug #####, modified amount ..
 |
 *=======================================================================*/


Procedure Validate_Deposit(
                 p_batch_source_id
                                  IN ra_batch_sources.batch_source_id%type,
                 p_deposit_date   IN date,
                 p_gl_date        IN date,
                 p_doc_sequence_value
                                  IN ra_customer_trx.doc_sequence_value%type,
                 p_amount         IN ra_customer_trx_lines.extended_amount%type,
                 p_currency_code  IN ra_customer_trx.invoice_currency_code%TYPE,
                 p_exchange_rate_type
                                  IN ra_customer_trx.exchange_rate_type%TYPE,
                 p_exchange_rate  IN ra_customer_trx.exchange_rate%TYPE,
                 p_exchange_rate_date
                                  IN ra_customer_trx.exchange_date%TYPE,
                 p_printing_option
                                  IN VARCHAR2,
                 p_status_trx     IN  VARCHAR2,
                 p_default_tax_exempt_flag
                                  IN  VARCHAR2,
                 p_financial_charges
                                  IN  VARCHAR2 default null ,
                 p_return_status  OUT NOCOPY VARCHAR2);


END AR_DEPOSIT_VAL_PVT ; -- Package spec

 

/
