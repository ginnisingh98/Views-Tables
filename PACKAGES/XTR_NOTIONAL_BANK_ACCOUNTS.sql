--------------------------------------------------------
--  DDL for Package XTR_NOTIONAL_BANK_ACCOUNTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_NOTIONAL_BANK_ACCOUNTS" AUTHID CURRENT_USER as
/* $Header: xtrnbnks.pls 120.1 2005/07/29 09:32:34 badiredd noship $ */

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * PROCEDURE modify_xtr_bank_accounts
 *
 * DESCRIPTION
 *     This procedure creates a dummy bank account in xtr_bank_accounts
 *     if the cash pool is being created.
 *     If an existing cash pool is being updated, then the corresponding
 *     dummy bank account in xtr_bank_accounts will be updated.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_cashpool_id                  	Cashpool ID of the Notional Cash Pool
 *					that is being created or updated.
 *     p_bank_account_id		Bank Account ID from CE_BANK_ACCOUNTS
 *					of the Concentration Account of the
 *					Cashpool.
 *   IN/OUT:
 *     x_return_status                	Return status after the call. The
 *                                    	status can be Y for success or N for
 *					error.
 *   OUT:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   01-26-2005    Rajesh Jose        	o Created.
 *
 */

PROCEDURE modify_xtr_bank_accounts(
	p_cashpool_id		IN	CE_CASHPOOLS.CASHPOOL_ID%TYPE,
	p_bank_account_id	IN	CE_BANK_ACCOUNTS.BANK_ACCOUNT_ID%TYPE,
	x_return_status		IN OUT NOCOPY VARCHAR2);

/**
 * PROCEDURE create_xtr_bank_account
 *
 * DESCRIPTION
 *     Creates dummy account in XTR_BANK_ACCOUNTS
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_cashpool_id                  	Cashpool ID of the Notional Cash Pool
 *					that is being created or updated.
 *     p_bank_account_id		Bank Account ID from CE_BANK_ACCOUNTS
 *					of the Concentration Account of the
 *					Cashpool.
 *   IN/OUT:
 *     x_return_status                	Return status after the call. The
 *                                    	status can be Y for success or N for
 *					error.
 *   OUT:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   01-26-2005    Rajesh Jose        	o Created.
 */

PROCEDURE create_xtr_bank_account(
	p_cashpool_id		IN	CE_CASHPOOLS.CASHPOOL_ID%TYPE,
	p_bank_account_id	IN	CE_BANK_ACCOUNTS.BANK_ACCOUNT_ID%TYPE,
	x_return_status		IN OUT NOCOPY VARCHAR2);

/**
 * PROCEDURE update_xtr_bank_account
 *
 * DESCRIPTION
 *     Updates the dummy account in XTR_BANK_ACCOUNTS
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_cashpool_id                  	Cashpool ID of the Notional Cash Pool
 *					that is being created or updated.
 *     p_bank_account_id		Bank Account ID from CE_BANK_ACCOUNTS
 *					of the Concentration Account of the
 *					Cashpool.
 *   IN/OUT:
 *     x_return_status                	Return status after the call. The
 *                                    	status can be Y for success or N for
 *					error.
 *   OUT:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   01-26-2005    Rajesh Jose        	o Created.
 */

PROCEDURE update_xtr_bank_account(
	p_cashpool_id		IN	CE_CASHPOOLS.CASHPOOL_ID%TYPE,
	p_bank_account_id	IN	CE_BANK_ACCOUNTS.BANK_ACCOUNT_ID%TYPE,
	x_return_status		IN OUT NOCOPY VARCHAR2);

END XTR_NOTIONAL_BANK_ACCOUNTS;


 

/
