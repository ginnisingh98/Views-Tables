--------------------------------------------------------
--  DDL for Package Body AP_R11_PREPAY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_R11_PREPAY_PKG" AS
/*$Header: apr11ppb.pls 120.10 2006/03/27 20:49:50 hchacko noship $*/
--
-- Declare Local procedures
--
PROCEDURE ap_prepay_get_info(
		    X_prepay_id		 	IN	NUMBER,
                    X_invoice_id     	 	IN	NUMBER,
                    X_amount_apply    	 	IN	NUMBER,
		    X_user_id      	 	IN	NUMBER,
		    X_last_update_login  	IN	NUMBER,
		    X_gl_date    	 	IN OUT NOCOPY	DATE,
		    X_period_name	 	IN OUT NOCOPY  VARCHAR2,
                    X_prepay_curr_amount_apply  IN OUT NOCOPY	NUMBER,
                    X_payment_cross_rate	OUT NOCOPY	NUMBER,
		    X_amount_positive 	 	OUT NOCOPY	VARCHAR2,
		    X_orig_amount 	 	OUT NOCOPY	NUMBER,
		    X_dist_item_amount 	 	OUT NOCOPY	NUMBER,
		    X_dist_tax_amount	 	OUT NOCOPY	NUMBER,
		    X_currency_code      	OUT NOCOPY     VARCHAR2,
		    X_base_currency      	OUT NOCOPY     VARCHAR2,
		    X_min_unit		 	OUT NOCOPY     NUMBER,
		    X_precision 	 	OUT NOCOPY	NUMBER,
		    X_base_min_unit	 	OUT NOCOPY     NUMBER,
		    X_base_precision 	 	OUT NOCOPY	NUMBER,
		    X_pay_curr_min_unit		OUT NOCOPY	NUMBER,
		    X_pay_curr_precision	OUT NOCOPY	NUMBER,
  		    X_max_dist		 	OUT NOCOPY	NUMBER,
  		    X_orig_max_dist	 	OUT NOCOPY	NUMBER,
		    X_max_pay_num	 	OUT NOCOPY	NUMBER,
		    X_max_inv_pay	 	OUT NOCOPY	NUMBER,
           	    X_copy_inv_pay_id	 	OUT NOCOPY 	NUMBER,
		    /* Bug 3700128. MOAC Project */
		    X_org_id                    OUT NOCOPY      NUMBER,
		    X_calling_from	 	IN	VARCHAR2,
		    X_calling_sequence   	IN      VARCHAR2);

PROCEDURE appp_update_ap_invoices(
		    X_invoice_id	 	IN	NUMBER,
		    X_prepay_id		 	IN	NUMBER,
                    X_amount_apply    	 	IN	NUMBER,
                    X_prepay_curr_amount_apply	IN	NUMBER,
		    X_user_id      	 	IN	NUMBER,
		    X_base_currency     	IN      VARCHAR2,
		    X_min_unit		 	IN      NUMBER,
		    X_precision 	 	IN	NUMBER,
		    X_last_update_login  	IN 	NUMBER,
		    X_calling_sequence   	IN      VARCHAR2);

PROCEDURE appp_insert_invoice_dist(
		    X_invoice_id	 IN	NUMBER,
		    X_prepay_id		 IN	NUMBER,
		    X_dist_line_amount 	 IN	NUMBER,
		    X_payment_cross_rate IN	NUMBER,
  		    X_max_dist		 IN OUT NOCOPY	NUMBER,
		    X_copy_dist_num	 IN	NUMBER,
		    X_user_id      	 IN	NUMBER,
		    X_min_unit		 IN     NUMBER,
		    X_precision 	 IN	NUMBER,
		    X_base_min_unit	 IN     NUMBER,
		    X_base_precision 	 IN	NUMBER,
		    X_gl_date    	 IN 	DATE,
		    X_period_name	 IN     VARCHAR2,
		    X_last_update_login  IN	NUMBER,
		    X_calling_sequence   IN     VARCHAR2);

PROCEDURE appp_insert_invoice_payment(
		    X_prepay_id		 	IN	NUMBER,
		    X_new_invoice_id	 	IN	NUMBER,
		    X_amount_apply 	 	IN	NUMBER,
		    X_prepay_curr_amount_apply	IN	NUMBER,
		    X_payment_cross_rate 	IN	NUMBER,
		    X_copy_inv_pay_id	 	IN	NUMBER,
  		    X_max_inv_pay	 	IN OUT NOCOPY	NUMBER,
		    X_orig_max_dist	 	IN	NUMBER,
		    X_user_id      	 	IN	NUMBER,
		    X_currency_code 	 	IN 	VARCHAR2,
		    X_base_currency 	 	IN 	VARCHAR2,
		    X_min_unit		 	IN      NUMBER,
		    X_precision 	 	IN	NUMBER,
		    X_pay_curr_min_unit		IN	NUMBER,
		    X_pay_curr_precision	IN	NUMBER,
		    X_base_min_unit	 	IN      NUMBER,
		    X_base_precision 	 	IN	NUMBER,
		    X_gl_date    	 	IN 	DATE,
		    X_period_name	 	IN      VARCHAR2,
		    X_last_update_login  	IN	NUMBER,
		    X_calling_sequence   	IN      VARCHAR2);


PROCEDURE appp_insert_payment_schedule(
		    X_prepay_id		 	IN	NUMBER,
		    X_amount_apply	 	IN      NUMBER,
		    X_prepay_curr_amount_apply	IN	NUMBER,
  		    X_max_pay_num	 	IN OUT NOCOPY	NUMBER,
		    X_copy_payment_num	 	IN	NUMBER,
		    X_user_id      	 	IN	NUMBER,
		    X_min_unit		 	IN      NUMBER,
		    X_precision 	 	IN	NUMBER,
		    X_pay_curr_min_unit		IN	NUMBER,
		    X_pay_curr_precision	IN	NUMBER,
		    X_last_update_login  	IN	NUMBER,
		    X_calling_sequence   	IN      VARCHAR2);

PROCEDURE appp_update_payment_schedule(
		    X_invoice_id	 	IN	NUMBER,
		    X_prepay_id		 	IN	NUMBER,
		    X_amount_apply	 	IN      NUMBER,
		    X_prepay_curr_amount_apply	IN	NUMBER,
		    X_payment_cross_rate 	IN	NUMBER,
		    X_amount_positive	 	IN	VARCHAR2,
		    X_copy_inv_pay_id	 	IN	NUMBER,
		    X_orig_max_dist	 	IN	NUMBER,
		    X_user_id      	 	IN	NUMBER,
		    X_currency_code 	 	IN 	VARCHAR2,
		    X_base_currency 	 	IN 	VARCHAR2,
		    X_min_unit		 	IN      NUMBER,
		    X_precision 	 	IN	NUMBER,
                    X_pay_curr_min_unit		IN	NUMBER,
		    X_pay_curr_precision	IN	NUMBER,
		    X_base_min_unit	 	IN      NUMBER,
		    X_base_precision 	 	IN	NUMBER,
		    X_gl_date    	 	IN 	DATE,
		    X_period_name	 	IN      VARCHAR2,
		    X_last_update_login  	IN	NUMBER,
		    X_calling_sequence   	IN      VARCHAR2);


PROCEDURE appp_insert_invoice_prepay(
		    X_invoice_id	 	IN	NUMBER,
		    X_prepay_id		 	IN	NUMBER,
		    X_amount_apply		IN      NUMBER,
		    X_user_id      	 	IN	NUMBER,
		    X_min_unit		 	IN      NUMBER,
		    X_precision 	 	IN	NUMBER,
		    X_last_update_login  	IN	NUMBER,
		    /* Bug 3700128. MOAC Project */
		    X_org_id                    IN      NUMBER,
		    X_calling_sequence   	IN      VARCHAR2);

PROCEDURE app_update_inv_distributions(
			X_prepay_id			IN  NUMBER,
			X_amount_apply      IN  NUMBER,
            X_calling_sequence      IN      VARCHAR2);

/*========================================================================
 * Main Procedure:
 *
 * This main procedure includes 9 steps and describe below.
 * (P stands for prepayment, I for Invoice)
 *========================================================================*/
PROCEDURE ap_r11_prepay(X_prepay_id		IN	NUMBER,
                        X_invoice_id     	IN	NUMBER,
                        X_amount_apply   	IN	NUMBER,
		        X_user_id      	 	IN	NUMBER,
		        X_last_update_login  	IN	NUMBER,
		        X_gl_date    	 	IN  	DATE,
		        X_period_name	 	IN	VARCHAR2,
		        X_calling_from	 	IN	VARCHAR2,
		        X_calling_sequence   	IN	VARCHAR2) IS

current_calling_sequence  	VARCHAR2(2000);
P_amount_positive 	 	VARCHAR2(2);
P_orig_amount			NUMBER;
P_dist_item_amount	 	NUMBER;
P_dist_tax_amount	 	NUMBER;
P_currency_code 	     	VARCHAR2(15);
P_base_currency      		VARCHAR2(15);
P_min_unit		     	NUMBER;
P_precision 		 	NUMBER;
P_base_min_unit		  	NUMBER;
P_base_precision 	 	NUMBER;
P_max_dist		 	NUMBER;
P_orig_max_dist		 	NUMBER;
P_max_pay_num		 	NUMBER;
P_max_inv_pay		 	NUMBER;
P_copy_inv_pay_id	  	NUMBER;
P_gl_date			DATE;
P_period_name			VARCHAR(15);
P_prepay_curr_amount_apply	NUMBER;
P_payment_cross_rate		NUMBER;
P_pay_curr_min_unit		NUMBER;
P_pay_curr_precision		NUMBER;
/* Bug 3700128. MOAC Project */
p_org_id                        NUMBER;

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence := 'AP_R11_PREPAY_PKG.ap_prepay<-'||X_calling_sequence;

/*---------------------------------------------------------------------------
 * Step 1pi: Case p and i : for both Prepayment and Invoice:
 * Call ap_prepay_get_info to get some parameters
 *--------------------------------------------------------------------------*/
 P_gl_date := X_gl_date;
 P_period_name := X_period_name;

 ap_r11_prepay_pkg.ap_prepay_get_info(
		    X_prepay_id,
                    X_invoice_id,
                    X_amount_apply,
		    X_user_id,
		    X_last_update_login,
		    P_gl_date,
		    P_period_name,
                    P_prepay_curr_amount_apply,
		    P_payment_cross_rate,
		    P_amount_positive,
		    P_orig_amount,
		    P_dist_item_amount,
		    P_dist_tax_amount,
		    P_currency_code,
		    P_base_currency,
		    P_min_unit,
		    P_precision,
		    P_base_min_unit,
		    P_base_precision,
		    P_pay_curr_min_unit,
		    P_pay_curr_precision,
  		    P_max_dist,
  		    P_orig_max_dist,
		    P_max_pay_num,
		    P_max_inv_pay,
           	    P_copy_inv_pay_id,
		    P_org_id, /* Bug 3700128. MOAC Project */
		    X_calling_from,
		    Current_calling_sequence);

/*--------------------------------------------------------------------------
 * -- Step 2p : case p: Prepayment: Update AP_INVOICES
 * Call appp_update_ap_invoices:
 *   1. Reduce the prepayment amount (invoice_amount) become
 *       (invoice_amount - amount_apply)
 *   2. Reduce amount_paid, invoice_distribution_total, and base_amount
 *       as well
 * (converse for Unapplication)
 *
 *--------------------------------------------------------------------------*/
	ap_r11_prepay_pkg.appp_update_ap_invoices(
		    '',
		    X_prepay_id,
                    X_amount_apply,
		    P_prepay_curr_amount_apply,
		    X_user_id,
		    P_base_currency,
		    P_base_min_unit,
		    P_base_precision,
		    X_last_update_login,
		    Current_calling_sequence);

/*--------------------------------------------------------------------------
 * -- Step 3p : case p : Prepayment: Insert AP_INVOICE_DISTRIBUTIONS (ITEM)
 * Call appp_insert_invoice_dist:
 * Create reversing ITEM distribution on the Prepayment, We presume dist line 1
 *   is item line. (converse for unapplication (amount_apply < 0) )
 *--------------------------------------------------------------------------*/
	ap_r11_prepay_pkg.appp_insert_invoice_dist(
		    X_invoice_id,
		    X_prepay_id,
		    P_dist_item_amount,
		    P_payment_cross_rate,
  		    P_max_dist,		/* IN/OUT parameter*/
		    1,	 		/* Line 1 is item line */
		    X_user_id,
		    P_min_unit,
		    P_precision,
		    P_base_min_unit,
		    P_base_precision,
		    P_gl_date,
		    P_period_name,
		    X_last_update_login,
		    Current_calling_sequence);


/*--------------------------------------------------------------------------
 * -- Step 4p : case p : Prepayment: Insert AP_INVOICE_DISTRIBUTIONS (TAX)
 * Call appp_insert_invoice_dist:
 * Create reversing TAX distribution on the Prepayment if applicable,
 *   we presume dist line 2 is tax line. (converse for unapplication)
 *--------------------------------------------------------------------------*/
 if (NVL(P_dist_tax_amount,0) <> 0) then
	ap_r11_prepay_pkg.appp_insert_invoice_dist(
		    X_invoice_id,
		    X_prepay_id,
		    P_dist_tax_amount,
		    P_payment_cross_rate,
  		    P_max_dist,	  /* Add 1 from above */ /* IN/OUT parameter*/
		    2,	          /* Line 2 in Tax line */
		    X_user_id,
		    P_min_unit,
		    P_precision,
		    P_base_min_unit,
		    P_base_precision,
		    P_gl_date,
		    P_period_name,
		    X_last_update_login,
		    Current_calling_sequence);
 end if;

/*--------------------------------------------------------------------------
 * -- Step 5p : case p : Prepayment: Insert AP_PAYMENT_SCHEDULES
 * Call appp_insert_payment_schedule :
 * Create additional paid Payment Schedule for the Prepayment.
 *         (converse for Unapplication)
 *--------------------------------------------------------------------------*/
  ap_r11_prepay_pkg.appp_insert_payment_schedule(
		    X_prepay_id,
		    X_amount_apply,
		    P_prepay_curr_amount_apply,
  		    P_max_pay_num,   /* IN/OUT parameter */
		    1,	 	     /* Line 1 will be copied into new line*/
		    X_user_id,
		    P_min_unit,
		    P_precision,
		    P_pay_curr_min_unit,
		    P_pay_curr_precision,
		    X_last_update_login,
		    Current_calling_sequence);


/*--------------------------------------------------------------------------
 * -- Step 6p : case p : Prepayment : Insert AP_INVOICE_PAYMENTS
 * Call appp_insert_invoice_payment :
 * Create new positive Invoice Payments for the Prepayment (converse
 *        for Unapplication)
 *--------------------------------------------------------------------------*/
 ap_r11_prepay_pkg.appp_insert_invoice_payment(
		    X_invoice_id,
		    X_prepay_id,
		    X_amount_apply,
		    P_prepay_curr_amount_apply,
		    P_payment_cross_rate,
		    P_copy_inv_pay_id,
  		    P_max_inv_pay,	/* IN/OUT parameter*/
		    P_orig_max_dist,
		    X_user_id,
		    P_currency_code,
		    P_base_currency,
		    P_min_unit,
		    P_precision,
		    P_pay_curr_min_unit,
		    P_pay_curr_precision,
		    P_base_min_unit,
		    P_base_precision,
		    P_gl_date,
		    P_period_name,
		    X_last_update_login,
		    Current_calling_sequence);


/*--------------------------------------------------------------------------
 * -- Step 7i : case i: Invoice : Update AP_INVOICES
 * Call appp_update_ap_invoices:
 *   1. Add the amount_apply to amount_paid for refelecting the payment
 *       amount change.
 *   2. Update discount_amount_taken, payment_status_flag as well
 *  (converse for Unapplication)
 *  Reversed order of this and next step for Rel11 'cos calc of ROUNDING
 *  type payment distributions depends upon the payment_status_flag of the
 *  invoice. Since the next step also creates payment dists, we should
 *  first update the payment_status_flag on the invoice.
 *--------------------------------------------------------------------------*/
	ap_r11_prepay_pkg.appp_update_ap_invoices(
		    X_invoice_id,
		    '',
                    X_amount_apply,
		    P_prepay_curr_amount_apply,
		    X_user_id,
		    P_base_currency,
		    P_pay_curr_min_unit,
		    P_pay_curr_precision,
		    X_last_update_login,
		    Current_calling_sequence);


/*--------------------------------------------------------------------------
 * -- Step 8i : case i : Invoice : Update AP_PAYMENT_SCHEDULES
 * Call appp_update_payment_schedule :
 *
 * 1. Update the Payment Schedules and create new Invoice Payments on the
 *      Invoice to reflect the effective payment (converse for Unapplication)
 * 2. Insert a new line for ap_invoice_payment to reflect the effective
 *      payment amount.
 *--------------------------------------------------------------------------*/
 ap_r11_prepay_pkg.appp_update_payment_schedule(
		    X_invoice_id,
		    X_prepay_id,
		    X_amount_apply,
		    P_prepay_curr_amount_apply,
		    P_payment_cross_rate,
		    P_amount_positive,
		    P_copy_inv_pay_id,
		    P_orig_max_dist,
		    X_user_id,
		    P_currency_code,
		    P_base_currency,
		    P_min_unit,
		    P_precision,
		    P_pay_curr_min_unit,
		    P_pay_curr_precision,
		    P_base_min_unit,
		    P_base_precision,
		    P_gl_date,
		    P_period_name,
		    X_last_update_login,
		    Current_calling_sequence);



/*--------------------------------------------------------------------------
 * -- Step 9ip : case i and p: Invoice: prepayment : Update AP_INVOICE_PREPAYS
 * Call appp_insert_invoice_prepay:
 * 1. Update ap_invoice_prepays if there's a invoice_prepay line exit.
 * 2. Delete record if unapply the prepayment.
 * 3. Insert new line if there's no such record exist
 ---------------------------------------------------------------------------*/
 ap_r11_prepay_pkg.appp_insert_invoice_prepay(
		    X_invoice_id,
		    X_prepay_id,
		    X_amount_apply,
		    X_user_id,
		    P_pay_curr_min_unit,
		    P_pay_curr_precision,
		    X_last_update_login,
		    /* Bug 3700128. MOAC Project */
		    P_org_id,
		    Current_calling_sequence);


 app_update_inv_distributions(
			X_prepay_id,
			X_amount_apply,
            Current_calling_sequence);

END  ap_r11_prepay;


/*==========================================================================
  This procedure is responsible for getting values from several different
    database column.

  It includes: (same discription as above)
  +---------------------------------------------------------------------+
  | Variable        	| NULL? | Description				|
  +=====================================================================+
  | X_gl_date  		| No	| If the main function didn't pass any 	|
  |			|	| value, the set it to SYSDATE		|
  +---------------------------------------------------------------------+
  | X_period_name	| No	| If the main function didn't pass any 	|
  |			|	| value, get it from gl_period_statuses |
  +---------------------------------------------------------------------+
  | X_amount_positive	| No    | Examine the sign for AMOUNT_APPLY	|
  |			|	| If amount_apply >0, then 'Y' -  APPLY	|
  |			|	|    <0, then 'N', means this's UNAPPLY	|
  +---------------------------------------------------------------------+
  | X_orig_amount	| No	| original_prepayment_amount from 	|
  |			|	| ap_invoice.(0 if NULL)		|
  +---------------------------------------------------------------------+
  | X_dist_item_amount	| No	| (ap_invoice_distributions.amount /	|
  |			|	|  ap_invoices.original_prepayment_amount)
  |			|	|  * X_amount_apply			|
  +---------------------------------------------------------------------+
  | X_dist_tax_amount   | No	| X_amount_apply - X_dist_item_amount	|
  +---------------------------------------------------------------------+
  | X_currency_code	| Maybe | currency_code from ap_invoice		|
  +---------------------------------------------------------------------+
  | X_base_currency	| Maybe | currency_code from ap_system_parameter|
  +---------------------------------------------------------------------+
  | X_min_unit		| Maybe | minimum_accountable_unit from		|
  |			|	|  fnd_currency.			|
  +---------------------------------------------------------------------+
  | X_precision		| No	| precision from fnd_currency.		|
  |			|	| 	(0 if NULL)			|
  +---------------------------------------------------------------------+
  | X_base_min_unit	| Maybe | minimum_accountable_unit from		|
  |			|	|  fnd_currency for base_currency	|
  +---------------------------------------------------------------------+
  | X_precision		| No	| precision from fnd_currency.		|
  |			|	| 	(0 if NULL)for base_currency 	|
  +---------------------------------------------------------------------+
  | X_max_dist		| No(*) | max(distribution_line_number) 	|
  |			|	| from ap_invoice_distribution		|
  |			|	| Use for insert a new dist line	|
  +---------------------------------------------------------------------+
  | X_orig_max_dist	| No(*) | Because X_max_dist is updatable,	|
  |			|	| keep a very original max_dist 	|
  |			|	| Use only for updating ap_payment_sche.|
  +---------------------------------------------------------------------+
  | X_max_pay_num  	| No(*) | max(payment_num) from ap_payment_sche.|
  +---------------------------------------------------------------------+
  | X_max_inv_pay	| No(*) | max(payment_num) from ap_invoice_paym.|
  +---------------------------------------------------------------------+
  | X_copy_inv_pay_id	| No(*) | max(invoice_payment_id), it means we  |
  |			|  	| copy the last line of invoice_payment |
  |			|	| when we create a new line		|
  +---------------------------------------------------------------------+

  * Currupted data if NULL.
 *=====================================================================*/

PROCEDURE ap_prepay_get_info(
		    X_prepay_id		        IN	NUMBER,
                    X_invoice_id     	        IN	NUMBER,
                    X_amount_apply    	        IN	NUMBER,
		    X_user_id      	 	IN	NUMBER,
		    X_last_update_login  	IN	NUMBER,
		    X_gl_date    	 	IN OUT NOCOPY	DATE,
		    X_period_name	 	IN OUT NOCOPY  VARCHAR2,
                    X_prepay_curr_amount_apply  IN OUT NOCOPY	NUMBER,
		    X_payment_cross_rate	OUT NOCOPY	NUMBER,
		    X_amount_positive 	 	OUT NOCOPY	VARCHAR2,
		    X_orig_amount 	 	OUT NOCOPY	NUMBER,
		    X_dist_item_amount 	 	OUT NOCOPY	NUMBER,
		    X_dist_tax_amount	 	OUT NOCOPY	NUMBER,
		    X_currency_code      	OUT NOCOPY     VARCHAR2,
		    X_base_currency      	OUT NOCOPY     VARCHAR2,
		    X_min_unit		 	OUT NOCOPY     NUMBER,
		    X_precision 	 	OUT NOCOPY	NUMBER,
		    X_base_min_unit	 	OUT NOCOPY     NUMBER,
		    X_base_precision 	 	OUT NOCOPY	NUMBER,
		    X_pay_curr_min_unit		OUT NOCOPY	NUMBER,
		    X_pay_curr_precision	OUT NOCOPY	NUMBER,
  		    X_max_dist		 	OUT NOCOPY	NUMBER,
  		    X_orig_max_dist	 	OUT NOCOPY	NUMBER,
		    X_max_pay_num	 	OUT NOCOPY	NUMBER,
		    X_max_inv_pay	 	OUT NOCOPY	NUMBER,
           	    X_copy_inv_pay_id	 	OUT NOCOPY 	NUMBER,
		    /* Bug 3700128. MOAC Project */
		    X_org_id                    OUT NOCOPY      NUMBER,
		    X_calling_from	 	IN	VARCHAR2,
		    X_calling_sequence   	IN      VARCHAR2) IS

debug_info   		    VARCHAR2(100);
current_calling_sequence    VARCHAR2(2000);
C_min_unit		    NUMBER;
C_precision		    NUMBER;
DUMMY			    VARCHAR2(100);
invoice_number              VARCHAR2(50);
C_pay_curr_invoice_amount   NUMBER;
C_invoice_amount	    NUMBER;
C_payment_cross_rate	    NUMBER;
C_currency_code             VARCHAR2(15);
C_gross_amount		    NUMBER;
C_orig_prepay_amount	    NUMBER;
C_pay_curr_min_unit	    NUMBER;
C_pay_curr_precision	    NUMBER;

BEGIN
    -- Update the calling sequence
    --
    current_calling_sequence := 'ap_prepay_get_info<-'||X_calling_sequence;


    ---------------------------------------------------------------------
    -- Get the amount_positive to distinguish apply or unapply prepayment
    ---------------------------------------------------------------------
    debug_info := 'Get the amount_positive';
    SELECT DECODE((SIGN(X_amount_apply)), 1, 'Y', 'N')
    INTO   X_amount_positive
    FROM   sys.dual;


    ---------------------------------------------------------------------
    -- We need to check if the invoice has been overapplyed when
    -- concurrent program (Invoice Import) call this procedure. Otherwise,
    -- forms filter out NOCOPY the possibility.
    ---------------------------------------------------------------------
    if (X_calling_from <> 'FORM') then
      debug_info := 'The apply amount is more than amount remaining';
      SELECT 'Not overapplying'
      INTO DUMMY
      FROM   ap_payment_schedules
      WHERE  invoice_id = X_invoice_id
      GROUP BY invoice_id
      HAVING sum(nvl(amount_remaining, 0)) >= X_amount_apply;
    end if;


    ---------------------------------------------------------------------
    -- We need to check if the amount apply is greater than prepayment amount
    -- when concurrent program (Invoice Import) call this procedure.
    -- Otherwise, forms filter out NOCOPY the possibility.
    ---------------------------------------------------------------------
    if (X_calling_from <> 'FORM') then
      debug_info := 'The apply amount is more than available amount';
      SELECT 'Not applying more than available'
      INTO DUMMY
      FROM   ap_invoices
      WHERE  invoice_id = X_prepay_id
      AND invoice_amount >= X_amount_apply;
    end if;

    ---------------------------------------------------------------------
    -- We need to check if the amount to be applied is greater than
    -- the amount not on hold for this invoice.
    ---------------------------------------------------------------------

      debug_info := 'Get the invoice number';
      SELECT invoice_num
      INTO invoice_number
      FROM   ap_invoices
      WHERE  invoice_id = X_invoice_id;

      debug_info := 'The apply amount is more than amount not on hold';
      SELECT 'Not applying more than not on hold'
      INTO DUMMY
      FROM   ap_payment_schedules
      WHERE  invoice_id = X_invoice_id
      AND    hold_flag <> 'Y'
      GROUP BY invoice_id
      HAVING sum(nvl(amount_remaining, 0)) >= X_amount_apply;

    ---------------------------------------------------------------------
    -- Get the invoice currency code, payment cross rate and amounts
    ---------------------------------------------------------------------
      debug_info := 'Get invoice currency code, payment cross rate, amounts';
      SELECT invoice_currency_code, payment_cross_rate,
             nvl(pay_curr_invoice_amount, invoice_amount),
             invoice_amount, invoice_currency_code,
             payment_cross_rate,
             original_prepayment_amount
      INTO   X_currency_code, X_payment_cross_rate,
             C_pay_curr_invoice_amount,
             C_invoice_amount, C_currency_code,
             C_payment_cross_rate,
             C_orig_prepay_amount
      FROM   ap_invoices
      WHERE  invoice_id = X_prepay_id;


    ---------------------------------------------------------------------
    -- Get the base currency
    ---------------------------------------------------------------------
    debug_info := 'Get base currency code';
    /* Bug 3700128. MOAC Project
       Selected org_id also so that the same can be used for
       insertion at later point of time */
    SELECT base_currency_code,org_id
    INTO   X_base_currency,X_org_id
    FROM   ap_system_parameters;


    ---------------------------------------------------------------------
    -- Get the Min_unit and precision from ap_invoice
    ---------------------------------------------------------------------
    debug_info := 'Get min_unit and precision for the prepayment';
    SELECT minimum_accountable_unit, nvl(precision,0)
    INTO X_min_unit, X_precision
    FROM fnd_currencies
    WHERE currency_code = C_currency_code;


    ---------------------------------------------------------------------
    -- Copy into local variable - READ AGAIN !!
    ---------------------------------------------------------------------
    debug_info := 'Get C_min_unit and C_precision for the prepayment';
    SELECT minimum_accountable_unit, nvl(precision,0)
    INTO C_min_unit, C_precision
    FROM fnd_currencies
    WHERE currency_code = C_currency_code;


    ---------------------------------------------------------------------
    -- Get the Min_unit and precision from base corrency
    ---------------------------------------------------------------------
    debug_info :='Get min_unit and precision from base_currency';
    SELECT MINIMUM_ACCOUNTABLE_UNIT, nvl(PRECISION,0)
    INTO   X_base_min_unit , X_base_precision
    FROM FND_CURRENCIES
    WHERE CURRENCY_CODE = ( SELECT BASE_CURRENCY_CODE
                              FROM AP_SYSTEM_PARAMETERS);


    ---------------------------------------------------------------------
    -- Get the Payment Currency Min_unit and precision from ap_invoice
    ---------------------------------------------------------------------
    debug_info := 'Get payment currency min_unit and precision for prepayment';
    SELECT minimum_accountable_unit, nvl(precision,0),
	   minimum_accountable_unit, nvl(precision,0)
    INTO   X_pay_curr_min_unit, X_pay_curr_precision,
	   C_pay_curr_min_unit, C_pay_curr_precision
    FROM   fnd_currencies
    WHERE  currency_code = ( SELECT payment_currency_code
                            FROM   ap_invoices
     			    WHERE  invoice_id = X_prepay_id);


    ---------------------------------------------------------------------
    -- Calculate the amount to apply in the Prepayment currency, i.e.
    -- the invoice currency of the Prepayment
    ---------------------------------------------------------------------
    If (X_amount_apply > 0)
    then
      -- Apply case
      If (X_amount_apply = C_pay_curr_invoice_amount)
      then
        -- Full application
        X_prepay_curr_amount_apply := C_invoice_amount;
      else
        -- Partial application
        X_prepay_curr_amount_apply := ap_utilities_pkg.ap_round_currency(
                                     X_amount_apply / C_payment_cross_rate,
                                     C_currency_code);
      end if;
    else
      -- Unapply case. Get the gross_amount for first payment schedule
      -- of the prepayment invoice.
      debug_info := 'Get gross amount from 1st payment schedule';
      SELECT  gross_amount
      INTO    C_gross_amount
      FROM    ap_payment_schedules
      WHERE   invoice_id = X_prepay_id
      AND     payment_num = 1;
      If (X_amount_apply = (C_pay_curr_invoice_amount - C_gross_amount))
      then
        -- Full unapplication
        X_prepay_curr_amount_apply := C_invoice_amount - C_orig_prepay_amount;
      else
        -- Partial unapplication
        X_prepay_curr_amount_apply := ap_utilities_pkg.ap_round_currency(
                                      X_amount_apply / C_payment_cross_rate,
                                      C_currency_code);
      end if;
    end if;


    ---------------------------------------------------------------------
    -- Get orig_amount, dist_item_amount, and dist_tax_amount
    --
    --   dist_item_amount =
    --   D1.amount / I.original_prepayment_amount * amount_apply
    --
    --   dist_tax_amount =
    --   amount_apply - (D1.amount / I.original_prepayment_amount
    --                   * amount_apply)
    ---------------------------------------------------------------------

    debug_info := 'Get orig_amount, dist_item_amount, and dist_tax_amount';

    -- Perf bug 5058989
    -- Go to base tables AP_INVIOCES_ALL and AP_INVOICE_DISTRIBUTIONS_ALL ( only for D2 )
    -- to eliminate MJC and reduce shared memory usage

    SELECT nvl(I.original_prepayment_amount,0),
	   ap_utilities_pkg.ap_round_precision(
		     D1.amount/I.original_prepayment_amount *
		     X_amount_apply,
		     C_pay_curr_min_unit, C_pay_curr_precision),
           DECODE(D2.line_type_lookup_code,
	          'ITEM', 0, null, 0,
                  (X_amount_apply -
                     ap_utilities_pkg.ap_round_precision(
		     D1.amount/I.original_prepayment_amount *
                     X_amount_apply,
		     C_pay_curr_min_unit, C_pay_curr_precision)))
    INTO   X_orig_amount,
	   X_dist_item_amount,
	   X_dist_tax_amount
    FROM   ap_invoices_all I, ap_invoice_distributions D1,
           ap_invoice_distributions_all D2
    WHERE  I.invoice_id = X_prepay_id
    AND    D1.invoice_id = I.invoice_id
    AND    D1.distribution_line_number = 1
    AND    D2.invoice_id(+) = D1.invoice_id -- Perf bug 5058989 -- replace I. with D1.
    AND    D2.distribution_line_number(+) = 2;


    ---------------------------------------------------------------------
    -- Get max_dist from ap_invoice_distributions
    ---------------------------------------------------------------------
    debug_info := 'Get max_dist';
    SELECT max(distribution_line_number),max(distribution_line_number)
    INTO   X_max_dist, X_orig_max_dist
    FROM   ap_invoice_distributions
    WHERE  invoice_id = X_prepay_id;


    ---------------------------------------------------------------------
    -- Get max_pay_num from ap_payment_schedules
    ---------------------------------------------------------------------
    debug_info := 'Get max_pay_num';
    SELECT max(payment_num)
    INTO   X_max_pay_num
    FROM   ap_payment_schedules
    WHERE  invoice_id = X_prepay_id;


    ---------------------------------------------------------------------
    -- Get max_inv_pay and copy_inv_pay_id from ap_invoice_payments
    ---------------------------------------------------------------------
    debug_info := 'Get max_inv_pay and copy_inv_pay_id';
    SELECT max(payment_num),
           max(decode(payment_num,1,invoice_payment_id,0))
    INTO   X_max_inv_pay,
           X_copy_inv_pay_id
    FROM   ap_invoice_payments
    WHERE  invoice_id = X_prepay_id;


    ---------------------------------------------------------------------
    -- Get period_name and gl_date if they are null
    ---------------------------------------------------------------------
    debug_info := 'Get gl_date';
    if (X_gl_date IS NULL) then
      X_gl_date := sysdate;
    end if;

    if (X_period_name IS NULL) then
      debug_info := 'Get period_name';
      SELECT G.period_name
        INTO X_period_name
        FROM gl_period_statuses G, ap_system_parameters P
       WHERE G.application_id = 200
         AND G.set_of_books_id = P.set_of_books_id
         AND DECODE(X_gl_date, '',
		    sysdate, X_gl_date) between G.start_date and G.end_date
         AND G.closing_status in ('O', 'F')
         AND NVL(G.adjustment_period_flag, 'N') = 'N';
    end if;


EXCEPTION
 WHEN NO_DATA_FOUND then
  if (debug_info = 'The apply amount is more than amount not on hold') then
     FND_MESSAGE.SET_NAME('SQLAP','AP_INV_PREPAY_GT_NOT_ON_HOLD');
     FND_MESSAGE.SET_TOKEN('INVOICE_NUM',invoice_number);
     APP_EXCEPTION.RAISE_EXCEPTION;
  else
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice_id = '||TO_CHAR(X_invoice_id)
		||' Prepay_id = '||TO_CHAR(X_prepay_id)
		||' Amount_apply = '||TO_CHAR(X_amount_apply)
		||' User_id = '||TO_CHAR(X_user_id)
		||' Last_update_login = '||TO_CHAR(X_last_update_login)
		||' gl_date = '||TO_CHAR(X_gl_date)
 		||' Period_name = '||X_period_name);

   if (debug_info = 'Get min_unit and precision for the prepayment') then
    FND_MESSAGE.SET_TOKEN('DEBUG_INFO','No currency code for this prepayment');
     APP_EXCEPTION.RAISE_EXCEPTION;
   elsif(debug_info ='Get min_unit and precision from base_currency') then
    FND_MESSAGE.SET_TOKEN('DEBUG_INFO','No Base currency code');
     APP_EXCEPTION.RAISE_EXCEPTION;
   elsif(debug_info ='Get period_name') then
    FND_MESSAGE.SET_TOKEN('DEBUG_INFO','the GL_date(sysdate) is not in an open period');
     APP_EXCEPTION.RAISE_EXCEPTION;
   else
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
     APP_EXCEPTION.RAISE_EXCEPTION;
   end if;
  end if;

 WHEN OTHERS then
   if (SQLCODE <> -20001 ) then
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice_id = '||TO_CHAR(X_invoice_id)
		||' Prepay_id = '||TO_CHAR(X_prepay_id)
		||' Amount_apply = '||TO_CHAR(X_amount_apply)
		||' User_id = '||TO_CHAR(X_user_id)
		||' Last_update_login = '||TO_CHAR(X_last_update_login)
		||' gl_date = '||TO_CHAR(X_gl_date)
 		||' Period_name = '||X_period_name);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
    end if;

     APP_EXCEPTION.RAISE_EXCEPTION;

END ap_prepay_get_info;




/*=========================================================================
 * This procedure is used for two case (Maintain AP_INVOICES)
 *
 * Case 1. Prepayment:
 *   1.1 Reduce the prepayment amount (invoice_amount) become
 *       (invoice_amount - amount_apply)
 *   1.2 Reduce amount_paid, invoice_distribution_total, and base_amount
 *       as well
 *
 * Case 2. Invoice:
 *   1.1 Add the amount_apply to amount_paid for refelecting the payment
 *       amount change.
 *   1.2 Update discount_amount_taken, payment_status_flag as well
 *
 * Distingrish case for invoice or prepayment depend on Null value passing.
 * (Invoice: prepay_id is NULL; Prepayment: invoice_id is NULL)
 *
 ==========================================================================*/

PROCEDURE appp_update_ap_invoices(
		    X_invoice_id	 	IN	NUMBER,
		    X_prepay_id		 	IN	NUMBER,
                    X_amount_apply    	 	IN	NUMBER,
		    X_prepay_curr_amount_apply	IN	NUMBER,
		    X_user_id      	 	IN	NUMBER,
		    X_base_currency      	IN      VARCHAR2,
		    X_min_unit		 	IN      NUMBER,
		    X_precision 	 	IN	NUMBER,
		    X_last_update_login  	IN	NUMBER,
		    X_calling_sequence   	IN      VARCHAR2) IS

debug_info   		  VARCHAR2(100);
current_calling_sequence  VARCHAR2(2000);

BEGIN
    -- Update the calling sequence
    --
   current_calling_sequence := 'appp_update_ap_invoices<-'||X_calling_sequence;

  if (X_invoice_id is NULL) then /* Update prepayment info */

    debug_info := 'Update ap_invoice for reducing the amount';

    UPDATE ap_invoices
    SET    invoice_amount = invoice_amount - X_prepay_curr_amount_apply,
           pay_curr_invoice_amount = nvl(pay_curr_invoice_amount, invoice_amount)
					- X_amount_apply,
           amount_paid = amount_paid - X_amount_apply,
           invoice_distribution_total = invoice_distribution_total -
                                          X_amount_apply,
           base_amount = DECODE(invoice_currency_code,
                                X_base_currency, base_amount,
                                base_amount -
				ap_utilities_pkg.ap_round_precision(
		    		exchange_rate * X_prepay_curr_amount_apply,
				X_min_unit, X_precision)),
           last_update_date = SYSDATE,
           last_updated_by = X_user_id,
           last_update_login = X_last_update_login
    WHERE invoice_id = X_prepay_id;

  else /* Update invoice info*/

    UPDATE ap_invoices
    SET    amount_paid = nvl(amount_paid, 0) +
				ap_utilities_pkg.ap_round_precision(
				X_amount_apply, X_min_unit, X_precision),
           discount_amount_taken = nvl(discount_amount_taken, 0),
           payment_status_flag =
		DECODE(NVL(amount_paid, 0) + NVL(discount_amount_taken, 0) +
		       ap_utilities_pkg.ap_round_precision(
		    	X_amount_apply, X_min_unit, X_precision),
                       nvl(pay_curr_invoice_amount, invoice_amount), 'Y',
                       0,'N',
                       'P'),
           last_update_date = SYSDATE,
           last_updated_by = X_user_id,
           last_update_login = X_last_update_login
    WHERE  invoice_id = X_invoice_id;

  end if;


EXCEPTION

 WHEN OTHERS then

   if (SQLCODE <> -20001 ) then
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Prepay_id = '||TO_CHAR(X_prepay_id)
		||' Invoice_id = '||TO_CHAR(X_invoice_id)
		||' Amount_apply = '||TO_CHAR(X_amount_apply)
		||' User_id = '||TO_CHAR(X_user_id)
		||' Last_update_login = '||TO_CHAR(X_last_update_login)
		||' Base_currency = '||X_base_currency
 		||' Min_unit = '||TO_CHAR(X_min_unit)
		||' Precision = '||TO_CHAR(X_precision));
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
   end if;

     APP_EXCEPTION.RAISE_EXCEPTION;

END appp_update_ap_invoices;




/*=========================================================================
 * This procedure is used for maintain AP_INVOICES_DISTRIBUTIONS
 *
 * -- Only prepayment need to add new distribution line.
 * -- the parameter X_invoice is only used for insert other_invoice_id
 *
 ==========================================================================*/
PROCEDURE appp_insert_invoice_dist(
		    X_invoice_id	 IN	NUMBER,
		    X_prepay_id		 IN	NUMBER,
		    X_dist_line_amount 	 IN	NUMBER,
		    X_payment_cross_rate IN	NUMBER,
  		    X_max_dist		 IN OUT NOCOPY	NUMBER,
		    X_copy_dist_num	 IN	NUMBER,
		    X_user_id      	 IN	NUMBER,
		    X_min_unit		 IN     NUMBER,
		    X_precision 	 IN	NUMBER,
		    X_base_min_unit	 IN     NUMBER,
		    X_base_precision 	 IN	NUMBER,
		    X_gl_date    	 IN 	DATE,
		    X_period_name	 IN     VARCHAR2,
		    X_last_update_login  IN	NUMBER,
		    X_calling_sequence   IN     VARCHAR2) IS

debug_info   		  VARCHAR2(100);
current_calling_sequence  VARCHAR2(2000);
new_line_num		  NUMBER;
l_invoice_distribution_id   NUMBER;


BEGIN
    -- Update the calling sequence
    --
    current_calling_sequence := 'appp_insert_invoice_dist<-'||X_calling_sequence;
    --
    -- This procedure is used for creating the distribution reversals on the
    -- prepayment invoice
    --

    X_max_dist := X_max_dist + 1;
    new_line_num := X_max_dist;

     /* First get the Invoice_Distribution_Id from the sequence */
    SELECT ap_invoice_distributions_s.NEXTVAL
      INTO l_invoice_distribution_id
      FROM sys.dual;                  -- added for Invoice_Distribution_Id


    debug_info := 'Update ap_invoice_distributions for creating the distribution reversals';

   INSERT INTO AP_INVOICE_DISTRIBUTIONS
               (invoice_id,
		dist_code_combination_id,
		last_update_date,
		last_updated_by,
 		accounting_date,
		period_name,
		set_of_books_id,
 		amount,
		description,
		type_1099,
		vat_code,
		posted_flag,
		batch_id,
 		req_distribution_id,
		quantity_invoiced,
		unit_price,
		price_adjustment_flag,
 		earliest_settlement_date,
		assets_addition_flag,
 		distribution_line_number,
		line_type_lookup_code,
		base_amount,
 		exchange_rate,
		exchange_rate_type,
		exchange_date,
	        accrual_posted_flag,
		cash_posted_flag,
		assets_tracking_flag,
 		pa_addition_flag,
		other_invoice_id,
		last_update_login,
		creation_date,
		created_by,
		invoice_distribution_id,
		tax_code_id,
		tax_code_override_flag,
		tax_recovery_override_flag,
		tax_recoverable_flag,
		org_id ) /* Bug 3700128. MOAC Project */
         SELECT invoice_id,
		dist_code_combination_id,
		SYSDATE,
		X_user_id,
       		X_gl_date,
		X_period_name,
		set_of_books_id,
		ap_utilities_pkg.ap_round_precision(
			 (-1) * X_dist_line_amount / X_payment_cross_rate,
                             X_min_unit, X_precision),
		'Prepayment Application',
       		type_1099,
		vat_code,
		'N',
		batch_id,
       		req_distribution_id,
		quantity_invoiced,
		unit_price,
       		price_adjustment_flag,
		earliest_settlement_date,
		'U',
       		new_line_num,
		line_type_lookup_code,
       		DECODE(base_amount, null, null,
			ap_utilities_pkg.ap_round_precision(
			(-1) * exchange_rate * X_dist_line_amount
			  / X_payment_cross_rate,
			X_base_min_unit, X_base_precision)),
       		exchange_rate,
		exchange_rate_type,
		exchange_date,
                'N',
		'N',
       		assets_tracking_flag,
		'E',
		X_invoice_id,
       		DECODE(X_last_update_login, -999, null, X_last_update_login),
       		SYSDATE,
		X_user_id,
		l_invoice_distribution_id,
		tax_code_id,
		tax_code_override_flag,
		tax_recovery_override_flag,
		tax_recoverable_flag,
		org_id                    /* Bug 3700128. MOAC Project */
	FROM    ap_invoice_distributions
	WHERE   invoice_id = X_prepay_id
	AND     distribution_line_number = X_copy_dist_num;

	--Bug 4539462 DBI logging
        AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_INVOICE_DISTRIBUTIONS',
               p_operation => 'I',
               p_key_value1 => X_prepay_id,
               p_key_value2 => l_invoice_distribution_Id,
                p_calling_sequence => current_calling_sequence);


EXCEPTION
 WHEN OTHERS then

   if (SQLCODE <> -20001 ) then
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Prepay_id = '||TO_CHAR(X_prepay_id)
		||' Dist_line_amount = '||TO_CHAR(X_dist_line_amount)
		||' Copy_dist_num = '||TO_CHAR(X_copy_dist_num)
		||' User_id = '||TO_CHAR(X_user_id)
		||' Last_update_login = '||TO_CHAR(X_last_update_login)
 		||' Base_min_unit = '||TO_CHAR(X_base_min_unit)
		||' Base_precision = '||TO_CHAR(X_base_precision)
 		||' Min_unit = '||TO_CHAR(X_min_unit)
		||' Precision = '||TO_CHAR(X_precision)
		||' gl_date = '||TO_CHAR(X_gl_date)
 		||' Period_name = '||X_period_name);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
   end if;

  APP_EXCEPTION.RAISE_EXCEPTION;

END appp_insert_invoice_dist;



/*========================================================================
  This procedure is used for creating an addition paid payment schedule
    on the prepayment invoice              (Insert AP_PAYMENT_SCHEDULE)
 *========================================================================*/
PROCEDURE appp_insert_payment_schedule(
		    X_prepay_id		 	IN	NUMBER,
		    X_amount_apply	 	IN      NUMBER,
                    X_prepay_curr_amount_apply	IN	NUMBER,
  		    X_max_pay_num	 	IN OUT NOCOPY	NUMBER,
		    X_copy_payment_num	 	IN	NUMBER,
		    X_user_id      	 	IN	NUMBER,
		    X_min_unit		 	IN      NUMBER,
		    X_precision 	 	IN	NUMBER,
 		    X_pay_curr_min_unit	 	IN	NUMBER,
		    X_pay_curr_precision 	IN	NUMBER,
		    X_last_update_login  	IN	NUMBER,
		    X_calling_sequence   	IN      VARCHAR2) IS

debug_info   		  VARCHAR2(100);
current_calling_sequence  VARCHAR2(2000);
new_line_num		  NUMBER;

BEGIN
    -- Update the calling sequence
    --
    current_calling_sequence := 'appp_insert_payment_schedule<-'||X_calling_sequence;

    X_max_pay_num := X_max_pay_num + 1;
    new_line_num := X_max_pay_num;

    debug_info := 'Create an addition paid payment schedule';

INSERT INTO AP_PAYMENT_SCHEDULES(
		invoice_id,
		payment_num,
		last_update_date,
		last_updated_by,
		due_date,
 		discount_date,
		gross_amount,
		inv_curr_gross_amount,
		amount_remaining,
		discount_amount_remaining,
 		payment_priority,
		payment_method_code,  --4552701
		hold_flag,
		payment_status_flag,
 		batch_id,
		payment_cross_rate,
		future_pay_due_date,
 		last_update_login,
		creation_date,
		created_by,
		org_id )  /* Bug 3700128. MOAC Project */
	SELECT 	invoice_id,
		new_line_num,
		SYSDATE,
		X_user_id,
		SYSDATE,
       		SYSDATE,
		ap_utilities_pkg.ap_round_precision(
			 (-1) * X_amount_apply, X_pay_curr_min_unit,
                         X_pay_curr_precision),
		ap_utilities_pkg.ap_round_precision(
			 (-1) * X_prepay_curr_amount_apply,
			     X_min_unit, X_precision),
		0,
		0,
       		payment_priority,
		payment_method_code,  --4552701
		'N',
		'Y',
       		batch_id,
		payment_cross_rate,
		future_pay_due_date,
       		DECODE(X_last_update_login, -999, null, X_last_update_login),
       		SYSDATE,
		X_user_id,
		org_id   /* Bug 3700128. MOAC Project */
	FROM   ap_payment_schedules
	WHERE  invoice_id = X_prepay_id
	AND    payment_num = X_copy_payment_num;


EXCEPTION
 WHEN OTHERS then

   if (SQLCODE <> -20001 ) then
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS',' Prepay_id = '||TO_CHAR(X_prepay_id)
		||' Amount_apply = '||TO_CHAR(X_amount_apply)
		||' Max_payment_num = '||TO_CHAR(X_max_pay_num)
		||' Copy_payment_num = '||TO_CHAR(X_copy_payment_num)
		||' User_id = '||TO_CHAR(X_user_id)
		||' Last_update_login = '||TO_CHAR(X_last_update_login)
 		||' Min_unit = '||TO_CHAR(X_min_unit)
		||' Precision = '||TO_CHAR(X_precision));
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
   end if;

     APP_EXCEPTION.RAISE_EXCEPTION;

END appp_insert_payment_schedule;



/*===========================================================================*
 * This procedure is used for maintaining AP_PAYMENT_SCHEDULE
 *  1. Update the paid payment schedules for this invoice.		     *
 *  2. Insert a new line for ap_invoice_payment to reflect the effective     *
 *     payment amount. (call appp_insert_invoice_payment)		     *
 *===========================================================================*/
PROCEDURE appp_update_payment_schedule(
		    X_invoice_id	 	IN	NUMBER,
		    X_prepay_id		 	IN	NUMBER,
		    X_amount_apply	 	IN      NUMBER,
		    X_prepay_curr_amount_apply	IN	NUMBER,
		    X_payment_cross_rate 	IN	NUMBER,
		    X_amount_positive	 	IN	VARCHAR2,
		    X_copy_inv_pay_id	 	IN	NUMBER,
		    X_orig_max_dist	 	IN	NUMBER,
		    X_user_id      	 	IN	NUMBER,
		    X_currency_code 	 	IN 	VARCHAR2,
		    X_base_currency 	 	IN 	VARCHAR2,
		    X_min_unit		 	IN      NUMBER,
		    X_precision 	 	IN	NUMBER,
		    X_pay_curr_min_unit		IN	NUMBER,
		    X_pay_curr_precision	IN	NUMBER,
		    X_base_min_unit	 	IN      NUMBER,
		    X_base_precision 	 	IN	NUMBER,
		    X_gl_date    	 	IN 	DATE,
		    X_period_name	 	IN      VARCHAR2,
		    X_last_update_login  	IN	NUMBER,
		    X_calling_sequence   	IN      VARCHAR2) IS

debug_info   		  VARCHAR2(100);
current_calling_sequence  VARCHAR2(2000);
C_amount_apply_remaining  NUMBER;
C_local_pay_num		  NUMBER;
C_local_amount		  NUMBER;
Temp_local_pay_num	  NUMBER;

-- debug_info := 'Declare Schedule Cursor';
CURSOR Schedules IS
    SELECT  payment_num,
            DECODE(X_amount_positive,
                 'N', gross_amount - amount_remaining,
                      amount_remaining)
    --
    -- gross_amount - amount_remaining = amount_paid.<- No database column
    --
    FROM    ap_payment_schedules
    WHERE   invoice_id = X_invoice_id
    AND     (payment_status_flag||'' = 'P'
    OR      payment_status_flag||'' = DECODE(X_amount_positive, 'N', 'Y', 'N'))
    ORDER BY DECODE(X_amount_positive,
                 'N', DECODE(payment_status_flag,'P',1,'Y',2,3),
                      DECODE(NVL(hold_flag,'N'),'N',1,2)),
             DECODE(X_amount_positive,
                     'N', due_date,
                          NULL) DESC,
             DECODE(X_amount_positive,
                     'N', NULL,
                          due_date),
             DECODE(X_amount_positive,
                 'N', DECODE(hold_flag,'N',1,'Y',2,3),
                      DECODE(NVL(payment_status_flag,'N'),'P',1,'N',2,3));

BEGIN
    -- Update the calling sequence
    --
    current_calling_sequence := 'appp_update_payment_schedule<-'||X_calling_sequence;
    --
    -- C_amount_apply_remaining is used for recording the actually amount_apply
    -- left.
    --
    C_amount_apply_remaining := X_amount_apply;

--
-- Open schedule ,fetch payment_num and amount into local variable array
--
debug_info := 'Open Schedule Cursor';
OPEN SCHEDULES;

LOOP

    debug_info := 'Fetch Schedules into local variables';
    FETCH SCHEDULES INTO C_local_pay_num, C_local_amount;

 if ((((C_amount_apply_remaining - C_local_amount) <= 0) AND
	(X_amount_positive = 'Y')) OR
	(((C_amount_apply_remaining + C_local_amount) >= 0) AND
	(X_amount_positive = 'N'))) then
    /*-----------------------------------------------------------------------+
     * Case 1 for 							     *
     *   1. In apply prepayment(amount_positive = 'Y'), the amount remaining *
     *	   is greater than amount_apply_remaining.			     *
     *   2. In unapply prepayment, the amount_apply (actually amount_unapply *
     *	   here) is greater than amount_paid (gross_amount-amount_remaining).*
     *
     *  It means that this schedule line have enough amount to apply(unapply)*
     *  the whole apply_amount.						     *
     *  								     *
     *  Update the amount_remaining for this payment schedule line become    *
     *  (amount_remaining - amount_apply_remaining).			     *
     +-----------------------------------------------------------------------*/

    debug_info := 'Update ap_payment_schedule for the invoice, case 1';

     UPDATE ap_payment_schedules
        SET amount_remaining = (amount_remaining -
				ap_utilities_pkg.ap_round_precision(
				C_amount_apply_remaining,
				X_pay_curr_min_unit, X_pay_curr_precision)),
            payment_status_flag =
                        DECODE(amount_remaining -
				ap_utilities_pkg.ap_round_precision(
				C_amount_apply_remaining,
				X_pay_curr_min_unit, X_pay_curr_precision),
                        	0,'Y',
                        	gross_amount, 'N',
                                'P'),
            last_update_date = SYSDATE,
            last_updated_by = X_user_id,
            last_update_login = X_last_update_login
      WHERE invoice_id = X_invoice_id
        AND payment_num = C_local_pay_num;

    -- ****NOTICE**********************************
    -- Kludge way to prevent this function automatically add 1 for pay_num
    --
       Temp_local_pay_num := C_local_pay_num - 1;

    debug_info := 'Call appp_insert_invoice_payment , case 1';
    ----------------------------------------------------------------------
    -- Add a new ap_invoice_payment line to adjust the amount
    ----------------------------------------------------------------------
    AP_R11_PREPAY_PKG.appp_insert_invoice_payment(
			X_prepay_id,
			X_invoice_id,
			C_amount_apply_remaining,
			X_prepay_curr_amount_apply,
			X_payment_cross_rate,
			X_copy_inv_pay_id,
			Temp_local_pay_num,
			X_orig_max_dist,
			X_user_id,
			X_currency_code,
			X_base_currency,
			X_min_unit,
			X_precision,
			X_pay_curr_min_unit,
			X_pay_curr_precision,
			X_base_min_unit,
			X_base_precision,
			X_gl_date,
			X_period_name,
			X_last_update_login,
			Current_calling_sequence);

     EXIT; /* No more amount left */

  else
    /*----------------------------------------------------------------------*
     *Case 2 for this line don't have enough amount to apply(unapply).      *
     *									    *
     *   Update the amount_remaining to 0 and amount_apply_remaining become *
     *   (amount_apply - amount_remaining(this line)), then go to next      *
     *   schedule line.							    *
     *----------------------------------------------------------------------*/

      debug_info := 'Update ap_payment_schedule for the invoice, case 2';
      UPDATE ap_payment_schedules
         SET amount_remaining = DECODE(X_amount_positive,
                                       'Y', 0,
                                       gross_amount),
             payment_status_flag = DECODE(X_amount_positive,
                                          'Y', 'Y',
                                          'N'),
             last_update_date = SYSDATE,
             last_updated_by = X_user_id,
             last_update_login = X_last_update_login
       WHERE  invoice_id = X_invoice_id
         AND  payment_num = C_local_pay_num;

      -- ****NOTICE**********************************
      -- Kludge way to prevent this function automatically add 1 for pay_num
      --
        Temp_local_pay_num := C_local_pay_num - 1;

      if (X_amount_positive = 'Y') then
       -- Apply:
       -- Add a new ap_invoice_payment line to adjust the amount
       --
         AP_R11_PREPAY_PKG.appp_insert_invoice_payment(
			X_prepay_id,
			X_invoice_id,
			C_local_amount,        /* Difference from above */
			X_prepay_curr_amount_apply,
			X_payment_cross_rate,
			X_copy_inv_pay_id,
			Temp_local_pay_num,    /* See notice above */
			X_orig_max_dist,
		        X_user_id,
		    	X_currency_code,
		    	X_base_currency,
		    	X_min_unit,
		    	X_precision,
			X_pay_curr_min_unit,
			X_pay_curr_precision,
		    	X_base_min_unit,
		    	X_base_precision,
		    	X_gl_date,
		    	X_period_name,
		    	X_last_update_login,
		    	Current_calling_sequence);
     else
       -- Unapply:
       -- Add a new ap_invoice_payment line to adjust the amount
       --
         AP_R11_PREPAY_PKG.appp_insert_invoice_payment(
			X_prepay_id,
			X_invoice_id,
			(-1)*C_local_amount,   /* Difference from above */
			X_prepay_curr_amount_apply,
			X_payment_cross_rate,
			X_copy_inv_pay_id,
			Temp_local_pay_num,    /* See notice above */
			X_orig_max_dist,
		        X_user_id,
		    	X_currency_code,
		    	X_base_currency,
		    	X_min_unit,
		    	X_precision,
			X_pay_curr_min_unit,
			X_pay_curr_precision,
		    	X_base_min_unit,
		    	X_base_precision,
		    	X_gl_date,
		    	X_period_name,
		    	X_last_update_login,
		    	Current_calling_sequence);
     end if;

     if (X_amount_positive = 'Y') then
        C_amount_apply_remaining := C_amount_apply_remaining - C_local_amount;
     else
        C_amount_apply_remaining := C_amount_apply_remaining + C_local_amount;
     end if;

   end if;

END LOOP;

debug_info := 'Close Schedule Cursor';
CLOSE SCHEDULES;


EXCEPTION
  WHEN OTHERS then

   if (SQLCODE <> -20001 ) then
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice_id = '||TO_CHAR(X_invoice_id)
		||' Prepay_id = '||TO_CHAR(X_prepay_id)
		||' Amount_apply = '||TO_CHAR(X_amount_apply)
		||' Amount_positive = '||X_amount_positive
		||' Amount_apply_remaining = '||TO_CHAR(C_amount_apply_remaining)
		||' C_local_amount = '||TO_CHAR(C_local_amount)
		||' C_local_pay_num = '||TO_CHAR(C_local_pay_num)
		||' Copy_inv_pay_id = '||TO_CHAR(X_copy_inv_pay_id)
		||' Orig_max_dist = '||TO_CHAR(X_orig_max_dist)
		||' User_id = '||TO_CHAR(X_user_id)
		||' Last_update_login = '||TO_CHAR(X_last_update_login)
 		||' Currency_code = '||X_currency_code
 		||' Base_currency = '||X_base_currency
 		||' Base_min_unit = '||TO_CHAR(X_base_min_unit)
		||' Base_precision = '||TO_CHAR(X_base_precision)
 		||' Min_unit = '||TO_CHAR(X_min_unit)
		||' Precision = '||TO_CHAR(X_precision)
		||' gl_date = '||TO_CHAR(X_gl_date)
 		||' Period_name = '||X_period_name);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
   end if;

     APP_EXCEPTION.RAISE_EXCEPTION;

END appp_update_payment_schedule;




/*===========================================================================
  This procedure is used for creating the new payment records on the check.
  (Maintain Table AP_INVOICE_PAYMENTS, and AP_PAYMENT_SCHEDULES)

  It include 3 steps. In step 3, there are 2 cases:

  1. Invoice type is prepayment: insert ap_payment_distribution. It separate
     into 3 steps, see below for detail.
  2. Invoice type is invoice: use AP_CREATE_PAY_DISTS_PKG.distribution_payment
     to create payment distribution line
 *==========================================================================*/
PROCEDURE appp_insert_invoice_payment(
		    X_prepay_id		 	IN	NUMBER,
		    X_new_invoice_id	 	IN	NUMBER,
		    X_amount_apply 	 	IN	NUMBER,
		    X_prepay_curr_amount_apply	IN	NUMBER,
		    X_payment_cross_rate 	IN	NUMBER,
		    X_copy_inv_pay_id	 	IN	NUMBER,
  		    X_max_inv_pay	 	IN OUT NOCOPY	NUMBER,
		    X_orig_max_dist	 	IN	NUMBER,
		    X_user_id      	 	IN	NUMBER,
		    X_currency_code 	 	IN 	VARCHAR2,
		    X_base_currency 	 	IN 	VARCHAR2,
		    X_min_unit		 	IN      NUMBER,
		    X_precision 	 	IN	NUMBER,
		    X_pay_curr_min_unit		IN	NUMBER,
		    X_pay_curr_precision	IN	NUMBER,
		    X_base_min_unit	 	IN      NUMBER,
		    X_base_precision 	 	IN	NUMBER,
		    X_gl_date    	 	IN 	DATE,
		    X_period_name	 	IN      VARCHAR2,
		    X_last_update_login  	IN	NUMBER,
		    X_calling_sequence   	IN      VARCHAR2) IS

debug_info   		  VARCHAR2(100);
current_calling_sequence  VARCHAR2(2000);
new_line_num		  NUMBER;
C_invoice_type 		  VARCHAR2(25);
C_round_amount		  NUMBER;
C_base_round_amount	  NUMBER;
C_new_invoice_payment_id  NUMBER;
C_check_id		  NUMBER;
DUMMY			  VARCHAR2(10);
C_inv_curr_round_amount   NUMBER;
C_inv_curr_base_round_amt NUMBER;
-- Bug 3907029
C_payment_type            VARCHAR2(25);
l_accounting_event_id     NUMBER;

BEGIN
    -- Update the calling sequence
    --
    current_calling_sequence := 'appp_insert_invoice_payment<-'||X_calling_sequence;
    --
    -- Add 1 to the X_max_inv_pay
    --
    X_max_inv_pay := X_max_inv_pay + 1;
    new_line_num := X_max_inv_pay;

    --------------------------------------------------------------
    -- Step 1: Get information
    --------------------------------------------------------------
    --
    -- Get check_id for the copy(reference) invoice( or prepayment).
    --
	debug_info := 'Get check_id';
	SELECT check_id
	INTO   C_check_id
	FROM   ap_invoice_payments
	WHERE  invoice_payment_id = X_copy_inv_pay_id;
    --
    -- Get the invoice_type for X_new_invoice_id (prepayment or invoice)
    --
    debug_info := 'Get invoice_type';
    SELECT   invoice_type_lookup_code
      INTO   C_invoice_type
      FROM   ap_invoices
     WHERE   invoice_id = X_new_invoice_id;

    -- Bug 3907029. Added this sql statement to get the payment type for the
    -- check to pass in to the create events API
    --
    -- Get the payment_type for c_check_id
    --
    debug_info := 'Get payment_type';
    SELECT   payment_type_flag
      INTO   C_payment_type
      FROM   ap_checks
     WHERE   check_id = c_check_id;


    -- Bug 3907029. Calling the create events API to create the
    -- payment adjustment event.
    AP_ACCOUNTING_EVENTS_PKG.Create_Events
              ( P_event_type          =>  'PAYMENT ADJUSTMENT'
               ,P_doc_type            =>  c_payment_type
               ,P_doc_id              =>  c_check_id
               ,P_accounting_date     =>  x_gl_date
               ,P_accounting_event_id =>  l_accounting_event_id
               ,P_checkrun_name       =>  NULL
               ,P_calling_sequence    =>  current_calling_sequence);

    ----------------------------------------------------------------
    -- Step 2: Insert into ap_invoice_payments
    ----------------------------------------------------------------
    debug_info := 'Create the new payment records for ap_invoice_payments';

    INSERT INTO AP_INVOICE_PAYMENTS(
		invoice_payment_id,
		invoice_id,
		payment_num,
		check_id,
		amount,
 		last_update_date,
		last_updated_by,
		set_of_books_id,
		posted_flag,
                accrual_posted_flag,
		cash_posted_flag,
		electronic_transfer_id,
 		accts_pay_code_combination_id,
		accounting_date,
		period_name,
 		exchange_rate_type,
		exchange_rate,
		exchange_date,
 		discount_lost,
		invoice_base_amount,
		payment_base_amount,
 		asset_code_combination_id,
		gain_code_combination_id,
 		loss_code_combination_id,
		bank_account_num,
		bank_num,
		bank_account_type,
 		future_pay_code_combination_id,
		future_pay_posted_flag,
		last_update_login,
 		creation_date,
		created_by,
		invoice_payment_type,
		other_invoice_id,
		org_id ) /* Bug 3700128. MOAC Project */
	SELECT 	ap_invoice_payments_s.nextval,
		X_new_invoice_id,
		new_line_num,
       		P.check_id,
		DECODE(P.invoice_id, X_new_invoice_id,
		       ap_utilities_pkg.ap_round_precision(
			(-1) * X_amount_apply, X_pay_curr_min_unit,
			X_pay_curr_precision),
		       ap_utilities_pkg.ap_round_precision(
			X_amount_apply, X_pay_curr_min_unit,
			X_pay_curr_precision)),
       		SYSDATE,
		X_user_id,
		P.set_of_books_id,
		'N',
                'N',
		'N',
       		P.electronic_transfer_id,
       		decode(X_new_invoice_id, P.invoice_id,
			P.accts_pay_code_combination_id,
              		I.accts_pay_code_combination_id),
       		X_gl_date,
		X_period_name,
       		P.exchange_rate_type,
		P.exchange_rate,
		P.exchange_date,
		0,
		DECODE(P.invoice_id, X_new_invoice_id,
    			ap_utilities_pkg.ap_round_precision(
				(-1) *
                                decode(I.invoice_currency_code,
                                   ASP.base_currency_code,
                                   decode(I.payment_currency_code,
                                      ASP.base_currency_code,
                                      I.exchange_rate, 1),
                                   I.exchange_rate)
                                  * X_amount_apply
				  / X_payment_cross_rate,
				X_base_min_unit, X_base_precision),
    			ap_utilities_pkg.ap_round_precision(
				decode(I.invoice_currency_code,
                                   ASP.base_currency_code,
                                   decode(I.payment_currency_code,
                                      ASP.base_currency_code,
                                      I.exchange_rate, 1),
                                   I.exchange_rate) * X_amount_apply
				  / X_payment_cross_rate,
				X_base_min_unit, X_base_precision)),
		DECODE(P.invoice_id, X_new_invoice_id,
    			ap_utilities_pkg.ap_round_precision(
				(-1) *
                                decode(I.payment_currency_code,
                                   ASP.base_currency_code,
                                   decode(I.invoice_currency_code,
                                      ASP.base_currency_code,
                                      P.exchange_rate, 1),
                                   P.exchange_rate)
                                  * X_amount_apply,
				X_base_min_unit, X_base_precision),
   			ap_utilities_pkg.ap_round_precision(
				decode(I.payment_currency_code,
                                   ASP.base_currency_code,
                                   decode(I.invoice_currency_code,
                                      ASP.base_currency_code,
                                      P.exchange_rate, 1),
                                   P.exchange_rate) * X_amount_apply,
				X_base_min_unit, X_base_precision)),
		P.asset_code_combination_id,
		P.gain_code_combination_id,
       		P.loss_code_combination_id,
		P.bank_account_num,
		P.bank_num,
       		P.bank_account_type,
		P.future_pay_code_combination_id,
       		'N',
       		DECODE(X_last_update_login, -999, null, X_last_update_login),
       		sysdate,
		X_user_id,
       		'PREPAY',
       		X_prepay_id,
		I.org_id     /* Bug 3700128. MOAC Project */
	FROM   ap_invoice_payments P, ap_invoices I, ap_system_parameters ASP
	WHERE  I.invoice_id = X_new_invoice_id
	AND    P.invoice_payment_id = X_copy_inv_pay_id
        AND    ASP.set_of_books_id = I.set_of_books_id;


-------------------------------------------------------------------------
-- Step 3a and 3b:
-- Check if invoice type is prepayment, insert ap_payment_distribution here.
-- Otherwise, use AP_CREATE_PAY_DISTS_PKG.distribution_payment to create
-- payment distribution line.
-------------------------------------------------------------------------
-- Step 3a/3b deleted because payment distributions are obsolete
--

EXCEPTION
 WHEN NO_DATA_FOUND then

   if (debug_info = 'Check flexbuilt') then
     FND_MESSAGE.SET_NAME('SQLAP','AP_PAY_DIST_NOT_FLEXBUILT');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Prepay_id = '||TO_CHAR(X_prepay_id)
		||' New_invoice_id = '||TO_CHAR(X_new_invoice_id)
		||' Invoice_type = '||C_invoice_type
		||' Amount_apply = '||TO_CHAR(X_amount_apply)
		||' Copy_inv_pay_id = '||TO_CHAR(X_copy_inv_pay_id)
		||' Max_inv_pay = '||TO_CHAR(X_max_inv_pay)
		||' Orig_max_dist = '||TO_CHAR(X_orig_max_dist)
		||' User_id = '||TO_CHAR(X_user_id)
		||' Last_update_login = '||TO_CHAR(X_last_update_login)
 		||' Currency_code = '||X_currency_code
 		||' Base_currency = '||X_base_currency
 		||' Base_min_unit = '||TO_CHAR(X_base_min_unit)
		||' Base_precision = '||TO_CHAR(X_base_precision)
 		||' Min_unit = '||TO_CHAR(X_min_unit)
		||' Precision = '||TO_CHAR(X_precision)
		||' gl_date = '||TO_CHAR(X_gl_date)
 		||' Period_name = '||X_period_name);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
     APP_EXCEPTION.RAISE_EXCEPTION;

   end if;

 WHEN OTHERS then

  if (SQLCODE <> -20001) then
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Prepay_id = '||TO_CHAR(X_prepay_id)
		||' New_invoice_id = '||TO_CHAR(X_new_invoice_id)
		||' Invoice_type = '||C_invoice_type
		||' Amount_apply = '||TO_CHAR(X_amount_apply)
		||' Copy_inv_pay_id = '||TO_CHAR(X_copy_inv_pay_id)
		||' Max_inv_pay = '||TO_CHAR(X_max_inv_pay)
		||' Orig_max_dist = '||TO_CHAR(X_orig_max_dist)
		||' User_id = '||TO_CHAR(X_user_id)
		||' Last_update_login = '||TO_CHAR(X_last_update_login)
 		||' Currency_code = '||X_currency_code
 		||' Base_currency = '||X_base_currency
 		||' Base_min_unit = '||TO_CHAR(X_base_min_unit)
		||' Base_precision = '||TO_CHAR(X_base_precision)
 		||' Min_unit = '||TO_CHAR(X_min_unit)
		||' Precision = '||TO_CHAR(X_precision)
		||' gl_date = '||TO_CHAR(X_gl_date)
 		||' Period_name = '||X_period_name);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
   end if;

     APP_EXCEPTION.RAISE_EXCEPTION;

END appp_insert_invoice_payment;




/*===========================================================================
  This precedure use for maintaining AP_INVOICE_PREPAYS
  1. Update ap_invoice_prepays if there's a invoice_prepay line exit.
  2. Delete record if unapply the prepayment.
  3. Insert new line if there's no such record exist
===========================================================================*/
PROCEDURE appp_insert_invoice_prepay(
		    X_invoice_id	 	IN	NUMBER,
		    X_prepay_id		 	IN	NUMBER,
		    X_amount_apply		IN      NUMBER,
		    X_user_id      	 	IN	NUMBER,
		    X_min_unit		 	IN      NUMBER,
		    X_precision 	 	IN	NUMBER,
		    X_last_update_login  	IN	NUMBER,
		    /* Bug 3700128. MOAC Project */
		    X_org_id                    IN      NUMBER,
		    X_calling_sequence   	IN      VARCHAR2) IS

debug_info   		  VARCHAR2(100);
current_calling_sequence  VARCHAR2(2000);

BEGIN
    -- Update the calling sequence
    --
    current_calling_sequence := 'appp_insert_invoice_prepay<-'||X_calling_sequence;

    ------------------------------------------------------------------
    -- Update ap_invoice_prepays if there's a invoice_prepay line exit
    ------------------------------------------------------------------
    debug_info := 'Update ap_invoice_prepays';
    UPDATE ap_invoice_prepays
    SET    prepayment_amount_applied = prepayment_amount_applied +
			ap_utilities_pkg.ap_round_precision(
			X_amount_apply, X_min_unit, X_precision),
           last_update_date = SYSDATE,
           last_updated_by = X_user_id,
           last_update_login = X_last_update_login
    WHERE  prepay_id = X_prepay_id
    AND    invoice_id = X_invoice_id;


    ------------------------------------------------------------------
    -- Delete record if unapply the prepayment
    ------------------------------------------------------------------
    debug_info := 'Delete record from ap_invoice_prepays';
    if (X_amount_apply < 0)
    then  /* Same as X_amount_positive = 'N' */
      DELETE FROM ap_invoice_prepays
      WHERE  prepay_id = X_prepay_id
      AND    invoice_id = X_invoice_id
      AND    prepayment_amount_applied = 0;

    else
    ------------------------------------------------------------------
    -- Insert new line if there's no record exist
    ------------------------------------------------------------------
    debug_info := 'Insert record from ap_invoice_prepays';

    INSERT INTO ap_invoice_prepays(
		prepay_id,
		invoice_id,
		prepayment_amount_applied,
		last_update_date,
 		last_updated_by,
		last_update_login,
		creation_date,
		created_by,
		org_id )  /* Bug 3700128. MOAC Project */
	SELECT  X_prepay_id,
		X_invoice_id,
		ap_utilities_pkg.ap_round_precision(
			X_amount_apply, X_min_unit, X_precision),
	        SYSDATE,
		X_user_id,
       		DECODE(X_last_update_login, -999, null, X_last_update_login),
       		SYSDATE,
		X_user_id,
		X_org_id  /* Bug 3700128. MOAC Project */
	FROM  SYS.DUAL
	WHERE NOT EXISTS (
                  SELECT 'Already updated existing record'
                  FROM   ap_invoice_prepays
                  WHERE  prepay_id = X_prepay_id
                  AND    invoice_id = X_invoice_id);
   end if;

EXCEPTION
 WHEN OTHERS then

  if (SQLCODE <> -20001) then
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice_id = '||TO_CHAR(X_invoice_id)
		||' Prepay_id = '||TO_CHAR(X_prepay_id)
		||' Amount_apply = '||TO_CHAR(X_amount_apply)
		||' User_id = '||TO_CHAR(X_user_id)
		||' Last_update_login = '||TO_CHAR(X_last_update_login)
 		||' Min_unit = '||TO_CHAR(X_min_unit)
		||' Precision = '||TO_CHAR(X_precision));
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
  end if;

     APP_EXCEPTION.RAISE_EXCEPTION;

END appp_insert_invoice_prepay;

PROCEDURE app_update_inv_distributions(
			X_prepay_id			IN  NUMBER,
			X_amount_apply 		IN  NUMBER,
			X_calling_sequence	IN  VARCHAR2) IS

debug_info            		VARCHAR2(100);
current_calling_sequence  	VARCHAR2(2000);
l_prepay_amt_remaining		NUMBER;

BEGIN
    -- Update the calling sequence
    --
    current_calling_sequence := 'appp_insert_invoice_prepay<-'||X_calling_sequence;

    -------------------------------------------------------------------------------
    -- Update the reversal flag
    -------------------------------------------------------------------------------

    UPDATE ap_invoice_distributions AID
    SET    reversal_flag = 'Y'
    WHERE  AID.line_type_lookup_code = 'ITEM'
    AND    AID.distribution_line_number > 1
    AND    AID.invoice_id = X_prepay_id;

    -------------------------------------------------------------------------------
    -- Update the prepay_amount_remaining
    -- If the prepay_amount_remaining of the first distribution line is null
    -- we need to set it as the sum of amount of all the item type distribution
    -- lines. If the prepay_amount_remaining is not null, it means the data has
    -- upgraded, if by any chance user did application by using 11i style and did
    -- unapplication by using pre-11i style, we need to add the amount we are
    -- trying to unapply to the prepay_amount_remaining. Here X_amount_remaining
    -- is always negative because of unapplication
    -------------------------------------------------------------------------------

	SELECT prepay_amount_remaining
	INTO   l_prepay_amt_remaining
	FROM   ap_invoice_distributions
	WHERE  invoice_id = X_prepay_id
	AND	   distribution_line_number = 1
	AND    line_type_lookup_code = 'ITEM';

	IF ( l_prepay_amt_remaining IS null ) THEN
    	UPDATE ap_invoice_distributions AID
    	SET    prepay_amount_remaining = (
                                       SELECT sum(AID2.amount)
                                       FROM   ap_invoice_distributions AID2
                                       WHERE  AID.invoice_id = AID2.invoice_id
                                       AND    AID2.line_type_lookup_code = 'ITEM')
    	WHERE  invoice_id = X_prepay_id
    	AND    AID.distribution_line_number = 1;
	ELSE
    	UPDATE ap_invoice_distributions
		SET	   prepay_amount_remaining = l_prepay_amt_remaining - X_amount_apply
    	WHERE  invoice_id = X_prepay_id
    	AND    distribution_line_number = 1;
	END IF;
EXCEPTION
WHEN OTHERS then

  if (SQLCODE <> -20001) then
 	FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
    FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
    FND_MESSAGE.SET_TOKEN('PARAMETERS','prepay_id = '||TO_CHAR(X_prepay_id));
    FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
  end if;
    APP_EXCEPTION.RAISE_EXCEPTION;

END app_update_inv_distributions;


END AP_R11_PREPAY_PKG;

/
