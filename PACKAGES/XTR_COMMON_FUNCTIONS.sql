--------------------------------------------------------
--  DDL for Package XTR_COMMON_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_COMMON_FUNCTIONS" AUTHID CURRENT_USER as
/* $Header: xtrfuncs.pls 120.0 2005/07/19 12:55:51 rjose noship $ */

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * FUNCTION DEAL_STATUS_CHECK
 *
 * DESCRIPTION
 * This function returns True if the statis of the Deal is Current.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *	p_deal_number			Deal Number of the Deal for which
 *					Status is to be determined.
 *   IN/OUT:
 *
 *   OUT:
 *	True if Deal Status is Current. False for all other statuses.
 *
 * NOTES
 *	Originally from DEAL_STATUS_CHECK in XTRUTIL.pld
 *
 * MODIFICATION HISTORY
 *
 *   14-JUN-2005    Rajesh Jose        	o Created.
 *
 */

FUNCTION DEAL_STATUS_CHECK(
		p_deal_number IN XTR_DEALS.DEAL_NO%TYPE) RETURN BOOLEAN;

/**
 * FUNCTION INTEREST_OVERRIDE_CHECK
 *
 * DESCRIPTION
 * Determines whether the user has the authority to override interest.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *   IN/OUT:
 *   OUT:
 *	TRUE if the user has the authority to override interest. Else False.
 *
 * NOTES
 *	Originally from INTEREST_OVERRIDE_CHECK in XTRUTIL.pld
 *
 * MODIFICATION HISTORY
 *
 *   14-JUL-2005    Rajesh Jose        	o Created.
 */

FUNCTION INTEREST_OVERRIDE_CHECK return BOOLEAN;

/**
 * FUNCTION    INTEREST_CHECK_COVER
 *
 * DESCRIPTION
 *     Cover Function which calls the following functions
 *		Settled_Interest_Check
 *		Interest_Reval_Check
 *		Interest_Accrual_Check
 *		Interest_Jrnls_Check
 *		Interest_Recon_Check
 *		Settled_Int_Tax_Check
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *	p_deal_type		Deal Type of the Deal
 *	p_deal_number		Deal Number
 *	p_transaction_number	Transaction Number
 *	p_date			Date
 *	p_maturity_date		Maturity Date of the Deal
 *	p_check_intset_record	Flag to indicate whether the check should be
 *				done for INTSET records only.
 *   IN/OUT:
 *   OUT:
 *	Returns False if any of the functions return False. Else returns True.
 *
 * NOTES
 *	Originally from INTEREST_CHECK_COVER in XTRUTIL.pld
 *
 * MODIFICATION HISTORY
 *
 *   14-JUL-2005    Rajesh Jose        	o Created.
 */

FUNCTION INTEREST_CHECK_COVER(
	p_deal_type		IN	XTR_DEALS.DEAL_TYPE%TYPE,
	p_deal_number		IN	XTR_DEALS.DEAL_NO%TYPE,
	p_transaction_number	IN	XTR_DEALS.TRANSACTION_NO%TYPE
						DEFAULT NULL,
	p_date			IN	DATE	DEFAULT NULL,
	p_maturity_date		IN	DATE	DEFAULT NULL,
	p_check_intset_record	IN	VARCHAR2 DEFAULT 'N') RETURN BOOLEAN;

/**
 * FUNCTION SETTLED_INTEREST_CHECK
 *
 * DESCRIPTION
 *	This function checks whether the input transaction has been settled.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *	p_deal_type		Deal Type of the Deal
 *	p_deal_number		Deal Number
 *	p_transaction_number	Transaction Number
 *	p_date			Date
 *	p_maturity_date		Maturity Date of the Deal
 *	p_check_intset_record	Flag to indicate whether the check should be
 *				done for INTSET records only.
 *   IN/OUT:
 *   OUT:
 *	Returns False if the transactions has been settled. Else returns True.
 *
 * NOTES
 *	Originally from SETTLED_INTEREST_CHECK in XTRUTIL.pld
 *
 * MODIFICATION HISTORY
 *
 *   14-JUL-2005    Rajesh Jose        	o Created.
 */

FUNCTION SETTLED_INTEREST_CHECK(
	p_deal_type		IN	XTR_DEALS.DEAL_TYPE%TYPE,
	p_deal_number		IN	XTR_DEALS.DEAL_NO%TYPE,
	p_transaction_number	IN	XTR_DEALS.TRANSACTION_NO%TYPE
						DEFAULT NULL,
	p_date			IN	DATE	DEFAULT NULL,
	p_maturity_date		IN	DATE	DEFAULT NULL,
	p_check_intset_record	IN	VARCHAR2 DEFAULT 'N') RETURN BOOLEAN;

/**
 * FUNCTION INTEREST_REVALUED_CHECK
 *
 * DESCRIPTION
 *	This function checks whether the input transaction has been revalued.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *	p_deal_type		Deal Type of the Deal
 *	p_deal_number		Deal Number
 *	p_transaction_number	Transaction Number
 *	p_date			Date
 *   IN/OUT:
 *   OUT:
 *	Returns False if the transaction has been revalued. Else returns True.
 *
 * NOTES
 *	Originally from INTEREST_REVAL_CHECK in XTRUTIL.pld
 *
 * MODIFICATION HISTORY
 *
 *   14-JUL-2005    Rajesh Jose        	o Created.
 */

FUNCTION INTEREST_REVALUED_CHECK(
	p_deal_type		IN	XTR_DEALS.DEAL_TYPE%TYPE,
	p_deal_number		IN	XTR_DEALS.DEAL_NO%TYPE,
	p_transaction_number	IN	XTR_DEALS.TRANSACTION_NO%TYPE
						DEFAULT NULL,
	p_date			IN	DATE	DEFAULT NULL) RETURN BOOLEAN;

/**
 * FUNCTION INTEREST_ACCRUAL_CHECK
 *
 * DESCRIPTION
 *	This function checks whether accruals have been passed for
 *	the input transaction.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *	p_deal_type		Deal Type of the Deal
 *	p_deal_number		Deal Number
 *	p_transaction_number	Transaction Number
 *	p_date			Date
 *   IN/OUT:
 *   OUT:
 *	Returns False if the transaction has been accrued. Else returns True.
 *
 * NOTES
 *	Originally from INTEREST_ACCRUAL_CHECK in XTRUTIL.pld
 *
 * MODIFICATION HISTORY
 *
 *   14-JUL-2005    Rajesh Jose        	o Created.
 */

FUNCTION INTEREST_ACCRUAL_CHECK(
	p_deal_type		IN	XTR_DEALS.DEAL_TYPE%TYPE,
	p_deal_number		IN	XTR_DEALS.DEAL_NO%TYPE,
	p_transaction_number	IN	XTR_DEALS.TRANSACTION_NO%TYPE
						DEFAULT NULL,
	p_date			IN	DATE	DEFAULT NULL) RETURN BOOLEAN;

/**
 * FUNCTION INTEREST_JOURNAL_CHECK
 *
 * DESCRIPTION
 *	This function checks whether journals have been passed for
 *	the input transaction.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *	p_deal_type		Deal Type of the Deal
 *	p_deal_number		Deal Number
 *	p_transaction_number	Transaction Number
 *	p_date			Date
 *	p_check_intset_record	Flag to indicate whether the check should be
 *				done for INTSET records only.
 *   IN/OUT:
 *   OUT:
 *	Returns False if the transaction has been accrued. Else returns True.
 *
 * NOTES
 *	Originally from INTEREST_JRNLS_CHECK in XTRUTIL.pld
 *
 * MODIFICATION HISTORY
 *
 *   14-JUL-2005    Rajesh Jose        	o Created.
 */

FUNCTION INTEREST_JOURNAL_CHECK(
	p_deal_type		IN	XTR_DEALS.DEAL_TYPE%TYPE,
	p_deal_number		IN	XTR_DEALS.DEAL_NO%TYPE,
	p_transaction_number	IN	XTR_DEALS.TRANSACTION_NO%TYPE
						DEFAULT NULL,
	p_date			IN	DATE	DEFAULT NULL,
	p_check_intset_record	IN	VARCHAR2 DEFAULT 'N') RETURN BOOLEAN;

/**
 * FUNCTION INTEREST_RECONCILED_CHECK
 *
 * DESCRIPTION
 *	This function checks whether the transaction has been reconciled.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *	p_deal_type		Deal Type of the Deal
 *	p_deal_number		Deal Number
 *	p_transaction_number	Transaction Number
 *	p_date			Date
 *   IN/OUT:
 *   OUT:
 *	Returns False if the transaction has been reconciled. Else returns True.
 *
 * NOTES
 *	Originally from INTEREST_RECON_CHECK in XTRUTIL.pld
 *
 * MODIFICATION HISTORY
 *
 *   14-JUL-2005    Rajesh Jose        	o Created.
 */

FUNCTION INTEREST_RECONCILED_CHECK(
	p_deal_type		IN	XTR_DEALS.DEAL_TYPE%TYPE,
	p_deal_number		IN	XTR_DEALS.DEAL_NO%TYPE,
	p_transaction_number	IN	XTR_DEALS.TRANSACTION_NO%TYPE
						DEFAULT NULL,
	p_date			IN	DATE	DEFAULT NULL) RETURN BOOLEAN;


/**
 * FUNCTION SETTLED_INTEREST_TAX_CHECK
 *
 * DESCRIPTION
 *	This function checks whether the tax exposure transaction for Bond
 *	Deals has been settled.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *	p_deal_type		Deal Type of the Deal
 *	p_deal_number		Deal Number
 *	p_transaction_number	Transaction Number
 *	p_date			Date
 *	p_maturity_date		Maturity Date of the Deal
 *   IN/OUT:
 *   OUT:
 *	Returns False if the tax exposure transaction has been settled.
 *	Else returns True.
 *
 * NOTES
 *	Originally from SETTLED_INT_TAX_CHECK in XTRUTIL.pld
 *
 * MODIFICATION HISTORY
 *
 *   14-JUL-2005    Rajesh Jose        	o Created.
 */

FUNCTION SETTLED_INTEREST_TAX_CHECK(
	p_deal_type		IN	XTR_DEALS.DEAL_TYPE%TYPE,
	p_deal_number		IN	XTR_DEALS.DEAL_NO%TYPE,
	p_transaction_number	IN	XTR_DEALS.TRANSACTION_NO%TYPE
						DEFAULT NULL,
	p_date			IN	DATE	DEFAULT NULL,
	p_maturity_date		IN	DATE	DEFAULT NULL) RETURN BOOLEAN;


END XTR_COMMON_FUNCTIONS;


 

/
