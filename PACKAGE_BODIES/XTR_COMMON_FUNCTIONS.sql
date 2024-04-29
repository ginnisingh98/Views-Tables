--------------------------------------------------------
--  DDL for Package Body XTR_COMMON_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_COMMON_FUNCTIONS" as
/* $Header: xtrfuncb.pls 120.3 2006/08/23 05:32:47 kbabu noship $ */

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
		p_deal_number IN XTR_DEALS.DEAL_NO%TYPE) RETURN BOOLEAN IS

 CURSOR	chk_status is
 SELECT	1
 FROM	xtr_deals_v
 WHERE	deal_no     = p_deal_number
 AND	status_code = 'CURRENT';

 l_dummy        number(1);

BEGIN
  OPEN	chk_status;
  FETCH	chk_status
  INTO	l_dummy;

  IF 	chk_status%FOUND THEN
	CLOSE chk_status;
        RETURN (TRUE);
  ELSE
	CLOSE chk_status;
        RETURN (false);
  END IF;

END;

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

FUNCTION INTEREST_OVERRIDE_CHECK return BOOLEAN IS

 l_allow_override VARCHAR2(1);
BEGIN
 SELECT	allow_override
 INTO	l_allow_override
 FROM	Xtr_Dealer_Codes
 WHERE	user_id = fnd_global.user_id;

 IF l_allow_override = 'Y' THEN
	RETURN(TRUE);
 ELSE
	RETURN(FALSE);
 END IF;
EXCEPTION
 WHEN OTHERS THEN
	RETURN (FALSE);
END INTEREST_OVERRIDE_CHECK;

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
 *      p_check_intset_record   Flag to indicate whether the check should be
 *                              done for INTSET records only.
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
	p_check_intset_record	IN	VARCHAR2 DEFAULT 'N') RETURN BOOLEAN IS

BEGIN

	IF NOT XTR_COMMON_FUNCTIONS.SETTLED_INTEREST_CHECK(
			p_deal_type, p_deal_number,
			p_transaction_number, p_date, p_maturity_date,
			p_check_intset_record) THEN
                RETURN FALSE;
        END IF;

        IF (NOT XTR_COMMON_FUNCTIONS.INTEREST_REVALUED_CHECK(
			p_deal_type, p_deal_number,
			p_transaction_number, p_date)) THEN
                RETURN FALSE;
        END IF;

        IF (NOT XTR_COMMON_FUNCTIONS.INTEREST_ACCRUAL_CHECK(
			p_deal_type, p_deal_number,
			p_transaction_number, p_date)) THEN
                RETURN FALSE;
        END IF;
        IF (NOT XTR_COMMON_FUNCTIONS.INTEREST_JOURNAL_CHECK(
			p_deal_type, p_deal_number,
			p_transaction_number, p_date,
			p_check_intset_record)) THEN
                RETURN FALSE;
        END IF;

        IF (NOT XTR_COMMON_FUNCTIONS.INTEREST_RECONCILED_CHECK(
			p_deal_type, p_deal_number,
			p_transaction_number, p_date)) THEN
                RETURN FALSE;
        END IF;

        IF NOT XTR_COMMON_FUNCTIONS.SETTLED_INTEREST_TAX_CHECK(
			p_deal_type, p_deal_number,
			p_transaction_number, p_date, p_maturity_date) THEN
                RETURN FALSE;
        END IF;

        RETURN TRUE;

EXCEPTION
 WHEN OTHERS THEN
    RETURN( FALSE );

END INTEREST_CHECK_COVER;

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
 *      p_check_intset_record   Flag to indicate whether the check should be
 *                              done for INTSET records only.
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
	p_check_intset_record	IN	VARCHAR2 DEFAULT 'N') RETURN BOOLEAN IS

 CURSOR	chk_settle_onc IS
 SELECT 1
 FROM  	xtr_deal_date_amounts dda
 WHERE 	dda.deal_number = nvl(p_deal_number,dda.deal_number)
 AND   	dda.transaction_number =
		nvl(p_transaction_number, dda.transaction_number)
 AND   	settle='Y';

CURSOR	chk_settle_onc_interest IS
 SELECT 1
 FROM  	xtr_deal_date_amounts dda
 WHERE 	dda.deal_number = nvl(p_deal_number,dda.deal_number)
 AND   	dda.transaction_number =
		nvl(p_transaction_number, dda.transaction_number)
 AND   	settle='Y'
 AND    actual_settlement_date > p_date --bug 5444438
 AND	dda.amount_type = 'INTSET';

 CURSOR chk_settle_others(l_date date) IS
 SELECT 1
 FROM  xtr_deal_date_amounts dda
 WHERE dda.deal_number = nvl(p_deal_number,dda.deal_number)
 AND   settle='Y'
 AND   amount_date > nvl(l_date,amount_date -1);

 l_dummy       number;
 l_date        date;

BEGIN

 IF p_deal_type in ('ONC') THEN
	IF p_check_intset_record = 'Y' THEN
   		OPEN 	chk_settle_onc_interest;
   		FETCH 	chk_settle_onc_interest
		INTO	l_dummy;

   		IF chk_settle_onc_interest%NOTFOUND THEN
        		CLOSE chk_settle_onc_interest;
			RETURN TRUE;
   		ELSE
        		CLOSE chk_settle_onc_interest;
        		RETURN FALSE;
   		END IF;
	ELSE
   		OPEN 	chk_settle_onc;
   		FETCH 	chk_settle_onc
		INTO	l_dummy;

   		IF chk_settle_onc%NOTFOUND THEN
        		CLOSE chk_settle_onc;
			RETURN TRUE;
   		ELSE
        		CLOSE chk_settle_onc;
        		RETURN FALSE;
   		END IF;
	END IF;
 ELSE	/* Other deal type */
	IF p_deal_type='IRS' THEN
        	l_date := p_maturity_date -1;
   	ELSIF p_deal_type='BOND' THEN
        	l_date := p_date -1;
   	ELSE
        	l_date := p_date;
	END IF;

	OPEN 	chk_settle_others(l_date);
	FETCH	chk_settle_others
	INTO	l_dummy;

   	IF chk_settle_others%NOTFOUND THEN
        	CLOSE chk_settle_others;
		RETURN TRUE;
   	ELSE
        	CLOSE chk_settle_others;
        	RETURN FALSE;
   	END IF;
END IF;

EXCEPTION
WHEN OTHERS THEN
	RETURN FALSE;
END SETTLED_INTEREST_CHECK;

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
	p_date			IN	DATE	DEFAULT NULL) RETURN BOOLEAN IS

 CURSOR chk_reval_tmm_irs(l_date date) IS
 SELECT	max(period_end)
 FROM	xtr_batches b,xtr_batch_events e,xtr_revaluation_details r
 WHERE 	r.deal_no    = p_deal_number
 AND 	r.batch_id   = b.batch_id
 AND	b.batch_id   = e.batch_id
 AND	e.event_code = 'REVAL'
 AND 	period_to > nvl(l_date, period_to -1);

 CURSOR chk_reval_others IS
 SELECT ('Y')
 FROM	xtr_batches b,xtr_batch_events e,xtr_revaluation_details r
 WHERE 	r.deal_no    = nvl(p_deal_number, r.deal_no)
 AND 	r.batch_id   = b.batch_id
 AND	b.batch_id   = e.batch_id
 AND	e.event_code = 'REVAL'
 AND	r.transaction_no =nvl(p_transaction_number,r.transaction_no);

 l_dummy       	VARCHAR2(1);
 l_max  	DATE;
 l_date		DATE;

BEGIN

 IF p_deal_type in ('TMM','IRS') THEN
   	IF (p_deal_type='IRS' AND p_date is not null) THEN
		l_date := p_date -1;
   	ELSE
		l_date := p_date;
   	END IF;

 	OPEN 	chk_reval_tmm_irs(l_date);
	FETCH	chk_reval_tmm_irs
	INTO	l_max;

	IF l_max is null THEN
		CLOSE chk_reval_tmm_irs;
        	RETURN TRUE;
	ELSE
        	CLOSE chk_reval_tmm_irs;
		RETURN (FALSE);
	END IF;
 ELSIF 	p_deal_type='BOND' THEN
        	RETURN(TRUE);
 ELSE
  	OPEN 	chk_reval_others;
  	FETCH	chk_reval_others
	INTO	l_dummy;

  	IF chk_reval_others%NOTFOUND THEN
        	CLOSE chk_reval_others;
        	RETURN (TRUE);
  	ELSE
        	CLOSE chk_reval_others;
        	RETURN (FALSE);
  	END IF;
 END IF;

EXCEPTION
  	WHEN OTHERS THEN
    		RETURN (FALSE);
END INTEREST_REVALUED_CHECK;

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
	p_date			IN	DATE	DEFAULT NULL) RETURN BOOLEAN IS

 l_accrual_check NUMBER;
 l_period_end 	 DATE;
BEGIN
 IF p_deal_type in ('TMM','IRS') AND p_date is not null THEN
	SELECT	max(period_to)
   	INTO	l_period_end
	FROM	xtr_accrls_amort
	WHERE	deal_no=p_deal_number
	AND	period_to > p_date;

	IF l_period_end IS NOT NULL THEN
		RETURN(FALSE);
	ELSE
		RETURN(TRUE);
	END IF;

 ELSE
	SELECT	count(deal_no)
	INTO	l_accrual_check
	FROM	Xtr_Accrls_Amort
	WHERE	deal_no = nvl(p_deal_number,deal_no)
	AND	Trans_no = nvl(p_transaction_number,Trans_no);

	IF l_accrual_check = 0 THEN
		RETURN(TRUE);
	ELSE
		RETURN(FALSE);
	END IF;
 END IF;

EXCEPTION
	WHEN OTHERS THEN
		RETURN (FALSE);

END INTEREST_ACCRUAL_CHECK;

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
	p_check_intset_record	IN	VARCHAR2 DEFAULT 'N') RETURN BOOLEAN IS

 CURSOR chk_jrnls IS
 SELECT ('Y')
 FROM	xtr_journals
 WHERE	deal_number =nvl(p_deal_number, deal_number)
 AND	transaction_number =nvl(p_transaction_number,transaction_number);

 CURSOR chk_jrnls_for_intset IS
 SELECT ('Y')
 FROM	xtr_journals
 WHERE	deal_number =nvl(p_deal_number, deal_number)
 AND	transaction_number =nvl(p_transaction_number,transaction_number)
 AND	amount_type = 'INTSET'
 AND    journal_date > p_date; -- for bug 5444438

 l_dummy       	varchar2(1);
 l_intset_date  date;
BEGIN

 IF p_deal_type in ('TMM','IRS') AND p_date is not null THEN
	SELECT	max(journal_date)
	INTO	l_intset_date
	FROM	xtr_journals
	WHERE	deal_number = p_deal_number
	AND	amount_type = 'INTSET';

	IF p_date < l_intset_date THEN
		RETURN FALSE;
	ELSE
		RETURN TRUE;
	END IF;
 ELSE
	IF (p_deal_type = 'ONC' and p_check_intset_record = 'Y') THEN
		OPEN 	chk_jrnls_for_intset;
		FETCH	chk_jrnls_for_intset
		INTO	l_dummy;

		IF chk_jrnls_for_intset%NOTFOUND THEN
			CLOSE chk_jrnls_for_intset;
			RETURN TRUE;
		ELSE
			CLOSE chk_jrnls_for_intset;
			RETURN FALSE;
		END IF;
	ELSE
		OPEN 	chk_jrnls;
		FETCH	chk_jrnls
		INTO	l_dummy;

		IF chk_jrnls%NOTFOUND THEN
			CLOSE chk_jrnls;
			RETURN TRUE;
		ELSE
			CLOSE chk_jrnls;
			RETURN FALSE;
		END IF;
	END IF;
 END IF;

EXCEPTION
	WHEN OTHERS THEN
		RETURN(FALSE);

END INTEREST_JOURNAL_CHECK;

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
	p_date			IN	DATE	DEFAULT NULL) RETURN BOOLEAN IS

CURSOR chk_recon IS
	SELECT	1
	FROM	XTR_DEAL_DATE_AMOUNTS_V
	WHERE	deal_number = nvl(p_deal_number, deal_number)
	AND	transaction_number=nvl(p_transaction_number, transaction_number)
	AND	reconciled_pass_code is not null
	AND	reconciled_reference is not null;

l_dummy       number;

BEGIN

 OPEN 	chk_recon;
 FETCH 	chk_recon
 INTO	l_dummy;

 IF chk_recon%NOTFOUND THEN
	CLOSE chk_recon;
	RETURN(TRUE);
 ELSE
	CLOSE chk_recon;
	RETURN(FALSE);
 END IF;

EXCEPTION
	WHEN OTHERS THEN
		RETURN(FALSE);
END INTEREST_RECONCILED_CHECK;


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
	p_maturity_date		IN	DATE	DEFAULT NULL) RETURN BOOLEAN IS

 v_trans_no 	NUMBER;
 l_dummy       	NUMBER;
 l_date        	DATE;

CURSOR	get_later_trans IS
 SELECT	transaction_number
 FROM	xtr_rollover_transactions
 WHERE	deal_number = p_deal_number
 AND	maturity_date > l_date
 AND	tax_amount IS NOT NULL;

CURSOR 	chk_tax_settle is
 SELECT 1
 FROM	xtr_deal_date_amounts dda, xtr_rollover_transactions rt
 WHERE	rt.deal_number=p_deal_number
 AND	rt.transaction_number=v_trans_no
 AND	dda.settle='Y'
 AND	dda.deal_number=0
 AND	dda.deal_type='EXP'
 AND	((rt.tax_settled_reference IS NOT NULL
 AND	dda.transaction_number=rt.tax_settled_reference)
 OR	(rt.principal_tax_settled_ref is not null
 AND	dda.transaction_number=rt.principal_tax_settled_ref));

BEGIN
 IF p_deal_type in ('BOND') THEN
	l_date := p_date-1;
	OPEN get_later_trans;
	LOOP
		FETCH	get_later_trans
		INTO	v_trans_no;
		EXIT WHEN get_later_trans%NOTFOUND;
		OPEN	chk_tax_settle;
		FETCH	chk_tax_settle
		INTO	l_dummy;
		IF chk_tax_settle%FOUND then
			CLOSE chk_tax_settle;
			RETURN FALSE;
		END IF;
		CLOSE chk_tax_settle;
	END LOOP;
	CLOSE get_later_trans;
	RETURN TRUE;

 ELSE /* Other deal type */

	RETURN TRUE;

 END IF;
EXCEPTION
	WHEN OTHERS THEN
		RETURN (FALSE);
END SETTLED_INTEREST_TAX_CHECK;

END XTR_COMMON_FUNCTIONS;


/
