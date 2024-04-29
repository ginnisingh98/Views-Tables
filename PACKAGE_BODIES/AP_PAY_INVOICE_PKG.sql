--------------------------------------------------------
--  DDL for Package Body AP_PAY_INVOICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_PAY_INVOICE_PKG" AS
/*$Header: apayinvb.pls 120.11.12010000.4 2009/05/05 06:53:02 njakkula ship $*/
--
-- Declare Local procedures
--
PROCEDURE ap_pay_get_info(
	P_invoice_id		IN	NUMBER,
        P_check_id     		IN	NUMBER,
        P_payment_num	    	IN	NUMBER,
	P_invoice_payment_id	IN	NUMBER,
	P_old_invoice_payment_id IN 	NUMBER,
	P_period_name		IN OUT NOCOPY  VARCHAR2,
	P_accounting_date	IN OUT NOCOPY	DATE,
	P_amount		IN	NUMBER,
	P_discount_taken	IN	NUMBER,
	P_discount_lost		IN OUT NOCOPY	NUMBER,
	P_invoice_base_amount	IN OUT NOCOPY	NUMBER,
	P_payment_base_amount	IN OUT NOCOPY	NUMBER,
	P_set_of_books_id	IN	NUMBER,
	P_currency_code		IN 	VARCHAR2,
	P_base_currency_code	IN	VARCHAR2,
	P_exchange_rate		IN	NUMBER,
	P_exchange_rate_type  	IN 	VARCHAR2,
	P_exchange_date		IN 	DATE,
	P_ce_bank_acct_use_id	IN	NUMBER,
	P_future_pay_posted_flag IN   	VARCHAR2,
	P_gain_ccid	 	IN OUT NOCOPY	NUMBER,
	P_loss_ccid   	 	IN OUT NOCOPY	NUMBER,
	P_payment_dists_flag	IN	VARCHAR2,
	P_payment_mode		IN	VARCHAR2,
	P_replace_flag		IN	VARCHAR2,
	P_calling_sequence   	IN    	VARCHAR2,
	P_last_update_date	OUT NOCOPY	DATE);


/*========================================================================
 * Main Procedure:
+=============================================================================+
| Step	   | Description					| Work for*   |
+==========+====================================================+=============+
| Step 1:  | Call ap_pay_get_info to get some needed 		| PAY/REV     |
|	   |    parameters  	      				|	      |
+----------+----------------------------------------------------+-------------+
| Step 2:  | Call ap_pay_update_payment_schedule:		| PAY         |
|	   | 							|	      |
+----------+----------------------------------------------------+-------------+
| Step 3:  | Call ap_pay_update_ap_invoices:			| PAY         |
|	   |  							|	      |
+----------+----------------------------------------------------+-------------+
| Step 4:  | Call ap_pay_insert_invoice_payments:		| PAY/REV     |
|	   | 							|	      |
+----------+----------------------------------------------------+-------------+
 *========================================================================*/
PROCEDURE ap_pay_invoice(
	P_invoice_id		IN	NUMBER,
        P_check_id     		IN	NUMBER,
        P_payment_num	    	IN	NUMBER,
	P_invoice_payment_id	IN	NUMBER,
	P_old_invoice_payment_id IN 	NUMBER	  	  Default NULL,
	P_period_name		IN   	VARCHAR2,
	P_invoice_type		IN  	VARCHAR2  	  Default NULL,
	P_accounting_date	IN	DATE,
	P_amount		IN	NUMBER,
	P_discount_taken	IN	NUMBER,
	P_discount_lost		IN	NUMBER		  Default NULL,
	P_invoice_base_amount	IN	NUMBER		  Default NULL,
	P_payment_base_amount	IN	NUMBER		  Default NULL,
	P_accrual_posted_flag	IN	VARCHAR2,
	P_cash_posted_flag	IN 	VARCHAR2,
	P_posted_flag		IN 	VARCHAR2,
	P_set_of_books_id	IN	NUMBER,
	P_last_updated_by     	IN 	NUMBER,
	P_last_update_login	IN	NUMBER 		  Default NULL,
	P_currency_code		IN 	VARCHAR2	  Default NULL,
	P_base_currency_code	IN	VARCHAR2  	  Default NULL,
	P_exchange_rate		IN	NUMBER	 	  Default NULL,
	P_exchange_rate_type  	IN 	VARCHAR2	  Default NULL,
	P_exchange_date		IN 	DATE		  Default NULL,
	P_ce_bank_acct_use_id	IN	NUMBER		  Default NULL,
	P_bank_account_num	IN	VARCHAR2  	  Default NULL,
	P_bank_account_type	IN	VARCHAR2  	  Default NULL,
	P_bank_num		IN	VARCHAR2  	  Default NULL,
	P_future_pay_posted_flag  IN   	VARCHAR2  	  Default NULL,
	P_exclusive_payment_flag  IN	VARCHAR2  	  Default NULL,
	P_accts_pay_ccid     	IN	NUMBER    	  Default NULL,
	P_gain_ccid	  	IN	NUMBER    	  Default NULL,
	P_loss_ccid   	  	IN	NUMBER    	  Default NULL,
	P_future_pay_ccid    	IN	NUMBER    	  Default NULL,
	P_asset_ccid	  	IN	NUMBER	  	  Default NULL,
	P_payment_dists_flag	IN	VARCHAR2	  Default NULL,
	P_payment_mode		IN	VARCHAR2	  Default NULL,
	P_replace_flag		IN	VARCHAR2	  Default NULL,
	P_attribute1		IN	VARCHAR2	  Default NULL,
	P_attribute2		IN	VARCHAR2	  Default NULL,
	P_attribute3		IN	VARCHAR2	  Default NULL,
	P_attribute4		IN	VARCHAR2	  Default NULL,
	P_attribute5		IN	VARCHAR2	  Default NULL,
	P_attribute6		IN	VARCHAR2	  Default NULL,
	P_attribute7		IN	VARCHAR2	  Default NULL,
	P_attribute8		IN	VARCHAR2	  Default NULL,
	P_attribute9		IN	VARCHAR2	  Default NULL,
	P_attribute10		IN	VARCHAR2	  Default NULL,
	P_attribute11		IN	VARCHAR2	  Default NULL,
	P_attribute12		IN	VARCHAR2	  Default NULL,
	P_attribute13		IN	VARCHAR2	  Default NULL,
	P_attribute14		IN	VARCHAR2	  Default NULL,
	P_attribute15		IN	VARCHAR2	  Default NULL,
	P_attribute_category	IN	VARCHAR2	  Default NULL,
	P_global_attribute1	IN	VARCHAR2	  Default NULL,
	P_global_attribute2	IN	VARCHAR2	  Default NULL,
	P_global_attribute3	IN	VARCHAR2	  Default NULL,
	P_global_attribute4	IN	VARCHAR2	  Default NULL,
	P_global_attribute5	IN	VARCHAR2	  Default NULL,
	P_global_attribute6	IN	VARCHAR2	  Default NULL,
	P_global_attribute7	IN	VARCHAR2	  Default NULL,
	P_global_attribute8	IN	VARCHAR2	  Default NULL,
	P_global_attribute9	IN	VARCHAR2	  Default NULL,
	P_global_attribute10	IN	VARCHAR2	  Default NULL,
	P_global_attribute11	IN	VARCHAR2	  Default NULL,
	P_global_attribute12	IN	VARCHAR2	  Default NULL,
	P_global_attribute13	IN	VARCHAR2	  Default NULL,
	P_global_attribute14	IN	VARCHAR2	  Default NULL,
	P_global_attribute15	IN	VARCHAR2	  Default NULL,
	P_global_attribute16	IN	VARCHAR2	  Default NULL,
	P_global_attribute17	IN	VARCHAR2	  Default NULL,
	P_global_attribute18	IN	VARCHAR2	  Default NULL,
	P_global_attribute19	IN	VARCHAR2	  Default NULL,
	P_global_attribute20	IN	VARCHAR2	  Default NULL,
	P_global_attribute_category	  IN	VARCHAR2  Default NULL,
        P_calling_sequence      IN      VARCHAR2          Default NULL,
        P_accounting_event_id   IN      NUMBER            Default NULL,
        P_org_id                IN      NUMBER            Default NULL)
IS

current_calling_sequence  	VARCHAR2(2000);
C_last_update_date		DATE;
C_discount_lost			NUMBER;
C_invoice_base_amount		NUMBER;
C_payment_base_amount		NUMBER;
C_gain_ccid	NUMBER;
C_loss_ccid	NUMBER;
C_period_name   VARCHAR2(15);
C_accounting_date               DATE;  --Bug #825450

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence := 'AP_PAY_INVOICE_PKG.ap_pay_invoice<-'||P_calling_sequence;

  --
  -- Transfer some IN variables into local variables
  C_discount_lost		:= P_discount_lost;
  C_invoice_base_amount		:= P_invoice_base_amount;
  C_payment_base_amount		:= P_payment_base_amount;
  C_gain_ccid	:= P_gain_ccid;
  C_loss_ccid	:= P_loss_ccid;
  C_period_name := P_period_name;
  C_accounting_date := P_accounting_date;

/*---------------------------------------------------------------------------
 * -- Step 1 : case for all
 * Call ap_pay_get_info :
 *
 *--------------------------------------------------------------------------*/
 ap_pay_invoice_pkg.ap_pay_get_info(
	P_invoice_id,
        P_check_id,
        P_payment_num,
	P_invoice_payment_id,
	P_old_invoice_payment_id,
	C_period_name,
	C_accounting_date,
	P_amount,
	P_discount_taken,
	C_discount_lost,
	C_invoice_base_amount,
	C_payment_base_amount,
	P_set_of_books_id,
	P_currency_code,
	P_base_currency_code,
	P_exchange_rate,
	P_exchange_rate_type,
	P_exchange_date,
	P_ce_bank_acct_use_id,
	P_future_pay_posted_flag,
	C_gain_ccid,
	C_loss_ccid,
	P_payment_dists_flag,
	P_payment_mode,
	P_replace_flag,
	Current_calling_sequence,
	C_last_update_date);

  --
  -- Don't do Step 2 and 3, if REV
  --
  if (P_PAYMENT_MODE = 'PAY') then

    /*--------------------------------------------------------------------------
     * -- Step 2 : case for all : Update AP_PAYMENT_SCHEDULES
     * Call ap_pay_update_payment_schedules :
     *
     *--------------------------------------------------------------------------*/
     ap_pay_invoice_pkg.ap_pay_update_payment_schedule(
	P_invoice_id,
	P_payment_num,
        P_check_id,
	P_amount,
  	P_discount_taken,
	P_payment_dists_flag,
	P_payment_mode,
	P_replace_flag,
	P_last_updated_by,
	C_last_update_date,
	Current_calling_sequence);

     -- Fix for bug 893626:
     -- In revision 115.11 of this file, there was an 'end if' here which
     -- was causing the amount paid in ap_invoices to be updated twice
     -- which resulted in the bug 893626.
     -- As mentioned above in the comment, we should not do steps 2 and 3
     -- for REV.
     -- Moved the 'end if' after the ap_pay_update_ap_invoices procedure call.

    /*--------------------------------------------------------------------------
     * -- Step 3 : case for all: Update AP_INVOICES
     * Call ap_pay_update_ap_invoices :
     *
     *--------------------------------------------------------------------------*/
     ap_pay_invoice_pkg.ap_pay_update_ap_invoices(
	P_invoice_id,
        P_check_id,
        P_amount,
	P_discount_taken,
	P_payment_dists_flag,
	P_payment_mode,
	P_replace_flag,
	C_last_update_date,
	P_last_updated_by,
	Current_calling_sequence);

  end if;

/*--------------------------------------------------------------------------
 * -- Step 4 : case for all : Insert AP_INVOICE_PAYMENTS
 * Call ap_pay_insert_invoice_payments :
 *
 *--------------------------------------------------------------------------*/
 ap_pay_invoice_pkg.ap_pay_insert_invoice_payments(
	P_invoice_id,
        P_check_id,
        P_payment_num,
	P_invoice_payment_id,
	P_old_invoice_payment_id,
	C_period_name,
	C_accounting_date,
	P_amount,
	P_discount_taken,
	C_discount_lost,
	C_invoice_base_amount,
	C_payment_base_amount,
	P_accrual_posted_flag,
	P_cash_posted_flag,
	P_posted_flag,
	P_set_of_books_id,
	P_last_updated_by,
	P_last_update_login,
	C_last_update_date,
	P_currency_code,
	P_base_currency_code,
	P_exchange_rate,
	P_exchange_rate_type,
	P_exchange_date,
	P_ce_bank_acct_use_id,
	P_bank_account_num,
	P_bank_account_type,
	P_bank_num,
	P_future_pay_posted_flag,
	P_exclusive_payment_flag,
	P_accts_pay_ccid,
	C_gain_ccid,
	C_loss_ccid,
	P_future_pay_ccid,
	P_asset_ccid,
	P_payment_dists_flag,
	P_payment_mode,
	P_replace_flag,
	P_attribute1,
	P_attribute2,
	P_attribute3,
	P_attribute4,
	P_attribute5,
	P_attribute6,
	P_attribute7,
	P_attribute8,
	P_attribute9,
	P_attribute10,
	P_attribute11,
	P_attribute12,
	P_attribute13,
	P_attribute14,
	P_attribute15,
	P_attribute_category,
	P_global_attribute1,
	P_global_attribute2,
	P_global_attribute3,
	P_global_attribute4,
	P_global_attribute5,
	P_global_attribute6,
	P_global_attribute7,
	P_global_attribute8,
	P_global_attribute9,
	P_global_attribute10,
	P_global_attribute11,
	P_global_attribute12,
	P_global_attribute13,
	P_global_attribute14,
	P_global_attribute15,
	P_global_attribute16,
	P_global_attribute17,
	P_global_attribute18,
	P_global_attribute19,
	P_global_attribute20,
	P_global_attribute_category,
        Current_calling_sequence,
        P_accounting_event_id,
        P_org_id);

END ap_pay_invoice;



/*==========================================================================
  This procedure is responsible for getting values from several different
    database column.
 *=====================================================================*/
PROCEDURE ap_pay_get_info(
	P_invoice_id		IN	NUMBER,
        P_check_id     		IN	NUMBER,
        P_payment_num	    	IN	NUMBER,
	P_invoice_payment_id	IN	NUMBER,
	P_old_invoice_payment_id IN 	NUMBER,
	P_period_name		IN OUT NOCOPY  VARCHAR2,
	P_accounting_date	IN OUT NOCOPY	DATE,
	P_amount		IN	NUMBER,
	P_discount_taken	IN	NUMBER,
	P_discount_lost		IN OUT NOCOPY	NUMBER,
	P_invoice_base_amount	IN OUT NOCOPY	NUMBER,
	P_payment_base_amount	IN OUT NOCOPY	NUMBER,
	P_set_of_books_id	IN	NUMBER,
	P_currency_code		IN 	VARCHAR2,
	P_base_currency_code	IN	VARCHAR2,
	P_exchange_rate		IN	NUMBER,
	P_exchange_rate_type  	IN 	VARCHAR2,
	P_exchange_date		IN 	DATE,
	P_ce_bank_acct_use_id	IN	NUMBER,
	P_future_pay_posted_flag	 IN   	VARCHAR2,
	P_gain_ccid	 	IN OUT NOCOPY	NUMBER,
	P_loss_ccid   	 	IN OUT NOCOPY	NUMBER,
	P_payment_dists_flag	IN	VARCHAR2,
	P_payment_mode		IN	VARCHAR2,
	P_replace_flag		IN	VARCHAR2,
	P_calling_sequence   	IN    	VARCHAR2,
	P_last_update_date	OUT NOCOPY	DATE) IS

debug_info   		  VARCHAR2(100);
current_calling_sequence  VARCHAR2(2000);
PS_payment_cross_rate     NUMBER;
AI_exchange_rate	  NUMBER;
PS_disc_amt_available     NUMBER;
PS_gross_amount		  NUMBER;
C_inv_currency_code       VARCHAR2(15);
AI_payment_cross_rate_date  DATE;
AI_payment_cross_rate_type  VARCHAR2(30);
AI_exchange_date	    DATE;
AI_exchange_rate_type	    VARCHAR2(30);
l_gl_date		    DATE;

BEGIN
  -- Update the calling sequence
  --
    current_calling_sequence := 'ap_pay_get_info<-'||P_calling_sequence;

  ------------------------------------------------
  -- Case for all
  -- Get period_name and gl_date if they are null
  ---------------------------------------------------------------------

    if (P_period_name IS NULL) then
    BEGIN
      debug_info := 'Get period_name';
      SELECT G.period_name
        INTO P_period_name
        FROM gl_period_statuses G, ap_system_parameters P
       WHERE G.application_id = 200
         AND G.set_of_books_id = P.set_of_books_id
         AND DECODE(P_accounting_date, '',
		    sysdate, P_accounting_date) between G.start_date and G.end_date
         AND G.closing_status in ('O', 'F')
         AND NVL(G.adjustment_period_flag, 'N') = 'N';
	 -- Bug 825450. Added select statement so that if the current period is
           -- not 'open' or 'future-entry' then select the next such available period.
           EXCEPTION WHEN NO_DATA_FOUND THEN
             BEGIN
               SELECT G.start_date, G.period_name
               INTO l_gl_date, P_period_name
               FROM gl_period_statuses G, ap_system_parameters P
               WHERE G.application_id = 200
               AND G.set_of_books_id = P.set_of_books_id
               AND G.start_date = (SELECT min(G1.start_date)
                                   FROM   gl_period_statuses G1
                                   WHERE G1.application_id = 200
                                   AND G1.set_of_books_id = P.set_of_books_id
                                   AND G1.start_date > DECODE(P_accounting_date, '',
                                                           sysdate, P_accounting_date)
                                   AND G1.closing_status in ('O', 'F')
                                   AND NVL(G1.adjustment_period_flag, 'N') = 'N'
                                   )
               AND G.closing_status in ('O', 'F')
               AND NVL(G.adjustment_period_flag, 'N') = 'N';

               P_accounting_date := l_gl_date;
             END ;
      END;

 end if;

 ------------------------------------------------
 -- Case for all
 -- Populate some required fields
 ------------------------------------------------

  P_last_update_date := sysdate;

  ------------------------------------------------
  -- Case for PAY
  -- Get base_amount and gain loss CCID
  ------------------------------------------------

  -- Bug 590200: Need to populate the base amount cols if
  -- either the inv or pay currency is not the same as the
  -- base currency

  debug_info := 'Get payment base amount';
  SELECT PS.payment_cross_rate,
         AI.payment_cross_rate_date,
         AI.payment_cross_rate_type,
         AI.exchange_rate,
         AI.exchange_date,
         AI.exchange_rate_type,
         AI.invoice_currency_code
  INTO PS_payment_cross_rate,
       AI_payment_cross_rate_date,
       AI_payment_cross_rate_type,
       AI_exchange_rate,
       AI_exchange_date,
       AI_exchange_rate_type,
       c_inv_currency_code
  FROM ap_payment_schedules PS, ap_invoices AI
  WHERE PS.invoice_id = P_invoice_id
  AND PS.payment_num = P_payment_num
  AND AI.invoice_id = P_invoice_id;

  if ((P_currency_code = P_base_currency_code) AND
      (c_inv_currency_code = P_base_currency_code) AND
      (P_PAYMENT_MODE = 'PAY')) then
   P_GAIN_CCID := '';
   P_LOSS_CCID := '';
   P_INVOICE_BASE_AMOUNT := '';
   P_PAYMENT_BASE_AMOUNT := '';

  elsif ((P_PAYMENT_MODE = 'PAY') AND
	 ((P_currency_code <> P_base_currency_code) OR
          (c_inv_currency_code <> P_base_currency_code))) then

    if (P_currency_code = P_base_currency_code) then
       P_payment_base_amount := ap_utilities_pkg.ap_round_currency(
                                P_amount, P_base_currency_code);
    else
       if (p_exchange_rate_type = 'User') then
          P_payment_base_amount := ap_utilities_pkg.ap_round_currency(
              (P_amount
               *P_exchange_rate),P_base_currency_code);
       else
          If (p_exchange_rate is not  null) then
              P_payment_base_amount :=
                  gl_currency_api.convert_amount (
                      p_currency_code,
                      p_base_currency_code,
                      p_exchange_date,
                      p_exchange_rate_type,
                      p_amount);
          End if;
        end if;
    end if;

    if (c_inv_currency_code = P_base_currency_code) then
        P_invoice_base_amount :=
              gl_currency_api.convert_amount (
                          p_currency_code,
                          p_base_currency_code,
                          AI_payment_cross_rate_date,
                          AI_payment_cross_rate_type,
                          P_amount);

    else
       if (AI_exchange_rate_type = 'User') then
           P_invoice_base_amount := ap_utilities_pkg.ap_round_currency(
              ((P_amount / PS_payment_cross_rate)
               *AI_exchange_rate),P_base_currency_code);
       else
         -- techinically an invoice cannot reach this point without an
         -- exchange rate...Adding the If stmt for any corner case missed.
         If (AI_exchange_rate is not null) then

         -- Bug fix: 969285
         -- Commented the call to 'gl_currency_api' and added the
         -- call to 'ap_utilities_pkg'

            P_invoice_base_amount:= ap_utilities_pkg.ap_round_currency
              (((P_amount/PS_payment_cross_rate)* AI_exchange_rate),
                                       P_base_currency_code);

             /*  P_invoice_base_amount :=
                   gl_currency_api.convert_amount (
                       p_currency_code,
                       p_base_currency_code,
                       AI_exchange_date,
                       AI_exchange_rate_type,
                       P_amount); */
         End if;
       end if;
    end if;

    debug_info := 'Get CCID';
    SELECT gain_code_combination_id, loss_code_combination_id
    INTO P_gain_ccid,
         P_loss_ccid
    FROM ce_gl_accounts_ccid CGAC
    WHERE CGAC.bank_acct_use_id = P_ce_bank_acct_use_id;

  elsif (P_PAYMENT_MODE = 'REV') then

    -- Fix for bug 905158
    -- For reversals, we want negated base_amounts from the old invoice payment
    --
    SELECT DECODE(invoice_base_amount ,'','',
                  0-NVL(invoice_base_amount,0)),
           DECODE(payment_base_amount ,'','',
                  0-NVL(payment_base_amount,0))
    INTO   P_invoice_base_amount, P_payment_base_amount
    FROM   ap_invoice_payments
    WHERE  invoice_payment_id = P_old_invoice_payment_id;

  end if;


 ------------------------------------------------
 -- Case for PAY
 -- Get discount_lost
 ------------------------------------------------
 if (P_PAYMENT_MODE = 'PAY') then
  debug_info := 'Get discount lost';
  SELECT greatest (nvl(PS.discount_amount_available,0),
                   nvl(PS.second_disc_amt_available,0),
                   nvl(PS.third_disc_amt_available,0)),
         ps.gross_amount
  INTO   PS_disc_amt_available,
         PS_gross_amount
  FROM   ap_payment_schedules ps
  WHERE  invoice_id = P_invoice_id
  AND    payment_num = P_payment_num;

  --
  -- Calculate the discount_loss
  --
  if (PS_gross_amount <> 0) then
   P_discount_lost :=
       ap_utilities_pkg.ap_round_currency(
        (((P_amount + P_discount_taken)/PS_gross_amount *
          PS_disc_amt_available) -
         P_discount_taken), P_currency_code);
  else
   P_discount_lost := 0;
  end if;
 end if;


EXCEPTION

 WHEN NO_DATA_FOUND then
   if (debug_info = 'check void') then
      FND_MESSAGE.SET_NAME('SQLAP', 'AP_INP_MUST_POST_VOID');
      APP_EXCEPTION.RAISE_EXCEPTION;
   elsif(debug_info ='Get period_name') then
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO','the GL_date(sysdate) is not in an open period');
     APP_EXCEPTION.RAISE_EXCEPTION;
   end if;

 WHEN OTHERS then
   if (SQLCODE <> -20001 ) then
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice_id = '||TO_CHAR(P_invoice_id)
		||', Payment_num = '||TO_CHAR(P_payment_num)
		||', Check_id = '||TO_CHAR(P_check_id)
		||', Invoice_payment_id = '||TO_CHAR(P_invoice_payment_id)
		||', Old Invoice_payment_id = '||TO_CHAR(P_old_invoice_payment_id)
		||', Accounting_date = '||TO_CHAR(P_accounting_date)
		||', Period_name = '||P_period_name
		||', Amount = '||TO_CHAR(P_amount)
		||', discount_taken = '||TO_CHAR(P_discount_taken)
		||', discount_lost = '||TO_CHAR(P_discount_lost)
		||', invoice_base_amount = '||TO_CHAR(P_invoice_base_amount)
		||', payment_base_amount = '||TO_CHAR(P_payment_base_amount)
		||', set_of_books_id = '||TO_CHAR(P_set_of_books_id)
		||', currency_code = '||P_currency_code
		||', base_currency_code = '||P_base_currency_code
		||', exchange_rate = '||TO_CHAR(P_exchange_rate)
		||', exchange_rate_type = '||P_exchange_rate_type
		||', exchange_date = '||TO_CHAR(P_exchange_date)
		||', bank_account_id = '||TO_CHAR(P_ce_bank_acct_use_id)
		||', future_pay_posted_flag = '||P_future_pay_posted_flag
		||', payment_dists_flag = '||P_payment_dists_flag
		||', payment_mode = '||P_payment_mode
		||', replace_flag = '||P_replace_flag);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
    end if;

     APP_EXCEPTION.RAISE_EXCEPTION;

END ap_pay_get_info;



/*=========================================================================
 * update amount_paid, discount_amount_taken and payment_status_flag for
 * ap_invoices 					Update AP_INVOICES
 ==========================================================================*/
 PROCEDURE ap_pay_update_ap_invoices(
		    P_invoice_id	 IN	NUMBER,
        	    P_check_id     	 IN	NUMBER,
                    P_amount    	 IN	NUMBER,
		    P_discount_taken     IN	NUMBER,
		    P_payment_dists_flag IN	VARCHAR2,
		    P_payment_mode	 IN	VARCHAR2,
		    P_replace_flag	 IN	VARCHAR2,
		    P_last_update_date   IN	DATE,
		    P_last_updated_by 	 IN	NUMBER,
		    P_calling_sequence   IN     VARCHAR2) IS

debug_info   		  VARCHAR2(100);
current_calling_sequence  VARCHAR2(2000);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence := 'ap_pay_update_ap_invoices<-'||P_calling_sequence;

  if (P_PAYMENT_MODE = 'PAY') then

    if (P_REPLACE_FLAG = 'N') then

      debug_info := 'Update ap_invoices (pay)';

      UPDATE ap_invoices
      SET    amount_paid = NVL(amount_paid, 0) + NVL(P_amount, 0),
             discount_amount_taken = NVL(discount_amount_taken, 0) +
                                     NVL(P_discount_taken, 0),
			 payment_status_flag = AP_INVOICES_UTILITY_PKG.get_payment_status( P_invoice_id ),
             last_update_date = P_last_update_date,
             last_updated_by = P_last_updated_by
      WHERE  invoice_id = P_invoice_id;

      --Bug 4539462 DBI logging
      AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_INVOICES',
               p_operation => 'U',
               p_key_value1 => P_invoice_id,
                p_calling_sequence => current_calling_sequence);

    elsif (P_REPLACE_FLAG = 'Y') then

      debug_info := 'Update ap_invoices (reissue)';

      UPDATE ap_invoices
      SET    last_update_date = P_last_update_date,
             last_updated_by = P_last_updated_by
      WHERE  invoice_id = P_invoice_id;

    end if;

  elsif (P_PAYMENT_MODE = 'REV') then

    if (P_REPLACE_FLAG = 'N') then

      debug_info := 'Update ap_invoices (reverse)';

      UPDATE ap_invoices AI
      SET   (amount_paid
      ,      discount_amount_taken
      ,      payment_status_flag
      ,      last_update_date
      ,      last_updated_by)
      =     (SELECT AI.amount_paid - SUM(AIP.amount)
             ,      NVL(AI.discount_amount_taken,0) -
	  		SUM(NVL(AIP.discount_taken,0))
             ,		AP_INVOICES_UTILITY_PKG.get_payment_status( P_invoice_id )
             ,      P_last_update_date
             ,      P_last_updated_by
             FROM   ap_invoice_payments AIP
             WHERE  AIP.invoice_id = P_invoice_id
	     AND    AIP.check_id = P_check_id
             GROUP BY AI.invoice_id
             ,        AI.amount_paid
             ,        AI.discount_amount_taken
             ,        AI.invoice_amount )
      WHERE AI.invoice_id = P_invoice_id;

      --Bug 4539462 DBI logging
      AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_INVOICES',
               p_operation => 'U',
               p_key_value1 => P_invoice_id,
                p_calling_sequence => current_calling_sequence);

    elsif (P_REPLACE_FLAG = 'Y') then

      debug_info := 'Update ap_invoices (replace)';

      UPDATE ap_invoices
      SET    last_update_date = P_last_update_date,
             last_updated_by = P_last_updated_by
      WHERE  invoice_id = P_invoice_id;

    end if;
  end if;

EXCEPTION

 WHEN OTHERS then

   if (SQLCODE <> -20001 ) then
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice_id = '||TO_CHAR(P_invoice_id)
		||', Check_id = '||TO_CHAR(P_check_id)
		||', Amount = '||TO_CHAR(P_amount)
		||', discount_taken = '||TO_CHAR(P_discount_taken)
		||', Last_updated_by = '||TO_CHAR(P_last_updated_by)
		||', Last_update_date = '||TO_CHAR(P_last_update_date)
		||', payment_dists_flag = '||P_payment_dists_flag
		||', payment_mode = '||P_payment_mode
		||', replace_flag = '||P_replace_flag);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
   end if;

     APP_EXCEPTION.RAISE_EXCEPTION;

END ap_pay_update_ap_invoices;



/*========================================================================
 *** Pubilic Function ***
 ************************
 * This function: 				Update AP_INVOICE_PAYMENTS
 * Inserts a new invoice payment line
 *========================================================================*/
PROCEDURE ap_pay_insert_invoice_payments(
	P_invoice_id		IN	NUMBER,
        P_check_id     		IN	NUMBER,
        P_payment_num	    	IN	NUMBER,
	P_invoice_payment_id	IN	NUMBER,
	P_old_invoice_payment_id IN 	NUMBER,
	P_period_name		IN   	VARCHAR2,
	P_accounting_date	IN	DATE,
	P_amount		IN	NUMBER,
	P_discount_taken	IN	NUMBER,
	P_discount_lost		IN	NUMBER,
	P_invoice_base_amount	IN	NUMBER,
	P_payment_base_amount	IN	NUMBER,
	P_accrual_posted_flag	IN	VARCHAR2,
	P_cash_posted_flag	IN 	VARCHAR2,
	P_posted_flag		IN 	VARCHAR2,
	P_set_of_books_id	IN	NUMBER,
	P_last_updated_by     	IN 	NUMBER,
	P_last_update_login	IN	NUMBER,
	P_last_update_date	IN	DATE,
	P_currency_code		IN 	VARCHAR2,
	P_base_currency_code	IN	VARCHAR2,
	P_exchange_rate		IN	NUMBER,
	P_exchange_rate_type  	IN 	VARCHAR2,
	P_exchange_date		IN 	DATE,
	P_ce_bank_acct_use_id	IN	NUMBER,
	P_bank_account_num	IN	VARCHAR2,
	P_bank_account_type	IN	VARCHAR2,
	P_bank_num		IN	VARCHAR2,
	P_future_pay_posted_flag	  IN   	VARCHAR2,
	P_exclusive_payment_flag 	  IN	VARCHAR2,
	P_accts_pay_ccid     	IN	NUMBER,
	P_gain_ccid	  	IN	NUMBER,
	P_loss_ccid   	  	IN	NUMBER,
	P_future_pay_ccid    	IN	NUMBER,
	P_asset_ccid	  	IN	NUMBER,
	P_payment_dists_flag	IN	VARCHAR2,
	P_payment_mode		IN	VARCHAR2,
	P_replace_flag		IN	VARCHAR2,
	P_attribute1		IN	VARCHAR2,
	P_attribute2		IN	VARCHAR2,
	P_attribute3		IN	VARCHAR2,
	P_attribute4		IN	VARCHAR2,
	P_attribute5		IN	VARCHAR2,
	P_attribute6		IN	VARCHAR2,
	P_attribute7		IN	VARCHAR2,
	P_attribute8		IN	VARCHAR2,
	P_attribute9		IN	VARCHAR2,
	P_attribute10		IN	VARCHAR2,
	P_attribute11		IN	VARCHAR2,
	P_attribute12		IN	VARCHAR2,
	P_attribute13		IN	VARCHAR2,
	P_attribute14		IN	VARCHAR2,
	P_attribute15		IN	VARCHAR2,
	P_attribute_category	IN	VARCHAR2,
	P_global_attribute1	IN	VARCHAR2	  Default NULL,
	P_global_attribute2	IN	VARCHAR2	  Default NULL,
	P_global_attribute3	IN	VARCHAR2	  Default NULL,
	P_global_attribute4	IN	VARCHAR2	  Default NULL,
	P_global_attribute5	IN	VARCHAR2	  Default NULL,
	P_global_attribute6	IN	VARCHAR2	  Default NULL,
	P_global_attribute7	IN	VARCHAR2	  Default NULL,
	P_global_attribute8	IN	VARCHAR2	  Default NULL,
	P_global_attribute9	IN	VARCHAR2	  Default NULL,
	P_global_attribute10	IN	VARCHAR2	  Default NULL,
	P_global_attribute11	IN	VARCHAR2	  Default NULL,
	P_global_attribute12	IN	VARCHAR2	  Default NULL,
	P_global_attribute13	IN	VARCHAR2	  Default NULL,
	P_global_attribute14	IN	VARCHAR2	  Default NULL,
	P_global_attribute15	IN	VARCHAR2	  Default NULL,
	P_global_attribute16	IN	VARCHAR2	  Default NULL,
	P_global_attribute17	IN	VARCHAR2	  Default NULL,
	P_global_attribute18	IN	VARCHAR2	  Default NULL,
	P_global_attribute19	IN	VARCHAR2	  Default NULL,
	P_global_attribute20	IN	VARCHAR2	  Default NULL,
	P_global_attribute_category	  IN	VARCHAR2  Default NULL,
        P_calling_sequence      IN      VARCHAR2,
        P_accounting_event_id   IN      NUMBER            Default NULL,
        P_org_id                IN      NUMBER            Default NULL) IS

current_calling_sequence  	VARCHAR2(2000);
debug_info   		  	VARCHAR2(100);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence := 'AP_PAY_INVOICE_PKG.ap_pay_insert_invoice_payments<-'||P_calling_sequence;

     debug_info := 'Insert ap_invoice_payments';
      AP_AIP_TABLE_HANDLER_PKG.Insert_Row(
        P_invoice_id,
        P_check_id,
        P_payment_num,
        P_invoice_payment_id,
        P_old_invoice_payment_id,
        P_period_name,
        P_accounting_date,
        P_amount,
        P_discount_taken,
        P_discount_lost,
        P_invoice_base_amount,
        P_payment_base_amount,
        P_accrual_posted_flag,
        P_cash_posted_flag,
        P_posted_flag,
        P_set_of_books_id,
        P_last_updated_by,
        P_last_update_login,
        P_last_update_date,
        P_currency_code,
        P_base_currency_code,
        P_exchange_rate,
        P_exchange_rate_type,
        P_exchange_date,
        P_ce_bank_acct_use_id,
        P_bank_account_num,
        P_bank_account_type,
        P_bank_num,
        P_future_pay_posted_flag,
        P_exclusive_payment_flag,
        P_accts_pay_ccid,
        P_gain_ccid,
        P_loss_ccid,
        P_future_pay_ccid,
        P_asset_ccid,
        P_payment_dists_flag,
        P_payment_mode,
        P_replace_flag,
        P_attribute1,
        P_attribute2,
        P_attribute3,
        P_attribute4,
        P_attribute5,
        P_attribute6,
        P_attribute7,
        P_attribute8,
        P_attribute9,
        P_attribute10,
        P_attribute11,
        P_attribute12,
        P_attribute13,
        P_attribute14,
        P_attribute15,
        P_attribute_category,
        P_global_attribute1,
        P_global_attribute2,
        P_global_attribute3,
        P_global_attribute4,
        P_global_attribute5,
        P_global_attribute6,
        P_global_attribute7,
        P_global_attribute8,
        P_global_attribute9,
        P_global_attribute10,
        P_global_attribute11,
        P_global_attribute12,
        P_global_attribute13,
        P_global_attribute14,
        P_global_attribute15,
        P_global_attribute16,
        P_global_attribute17,
        P_global_attribute18,
        P_global_attribute19,
        P_global_attribute20,
        P_global_attribute_category,
        Current_calling_sequence,
        P_accounting_event_id,
        P_org_id);

EXCEPTION
 WHEN OTHERS then

   if (SQLCODE <> -20001 ) then
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice_id = '||TO_CHAR(P_invoice_id)
		||', Payment_num = '||TO_CHAR(P_payment_num)
		||', Check_id = '||TO_CHAR(P_check_id)
		||', Invoice_payment_id = '||TO_CHAR(P_invoice_payment_id)
		||', Old Invoice_payment_id = '||TO_CHAR(P_old_invoice_payment_id)
		||', Accounting_date = '||TO_CHAR(P_accounting_date)
		||', Period_name = '||P_period_name
		||', Amount = '||TO_CHAR(P_amount)
		||', accrual_posted_flag = '||P_accrual_posted_flag
		||', cash_posted_flag = '||P_cash_posted_flag
		||', posted_flag = '||P_posted_flag
		||', discount_taken = '||TO_CHAR(P_discount_taken)
		||', discount_lost = '||TO_CHAR(P_discount_lost)
		||', invoice_base_amount = '||TO_CHAR(P_invoice_base_amount)
		||', payment_base_amount = '||TO_CHAR(P_payment_base_amount)
		||', set_of_books_id = '||TO_CHAR(P_set_of_books_id)
		||', currency_code = '||P_currency_code
		||', base_currency_code = '||P_base_currency_code
		||', exchange_rate = '||TO_CHAR(P_exchange_rate)
		||', exchange_rate_type = '||P_exchange_rate_type
		||', exchange_date = '||TO_CHAR(P_exchange_date)
		||', bank_account_id = '||TO_CHAR(P_ce_bank_acct_use_id)
		||', bank_account_num = '||P_bank_account_num
		||', bank_account_type = '||P_bank_account_type
		||', bank_num = '||P_bank_num
		||', future_pay_posted_flag = '||P_future_pay_posted_flag
		||', exclusive_payment_flag = '||P_exclusive_payment_flag
		||', accts_pay_ccid = '||TO_CHAR(P_accts_pay_ccid)
		||', gain_ccid = '||TO_CHAR(P_gain_ccid)
		||', loss_ccid = '||TO_CHAR(P_loss_ccid)
		||', future_pay_ccid= '||TO_CHAR(P_future_pay_ccid)
		||', asset_ccid = '||TO_CHAR(P_asset_ccid)
		||', attribute1 = '||P_attribute1
		||', attribute2 = '||P_attribute2
		||', attribute3 = '||P_attribute3
		||', attribute4 = '||P_attribute4
		||', attribute5 = '||P_attribute5
		||', attribute6 = '||P_attribute6
		||', attribute7 = '||P_attribute7
		||', attribute8 = '||P_attribute8
		||', attribute9 = '||P_attribute9
		||', attribute10 = '||P_attribute10
		||', attribute11 = '||P_attribute11
		||', attribute12 = '||P_attribute12
		||', attribute13 = '||P_attribute13
		||', attribute14 = '||P_attribute14
		||', attribute15 = '||P_attribute15
		||', attribute_category = '||P_attribute_category
		||', Last_update_by = '||TO_CHAR(P_last_updated_by)
		||', Last_update_date = '||TO_CHAR(P_last_update_date)
		||', Last_update_login = '||TO_CHAR(P_last_update_login)
		||', payment_dists_flag = '||P_payment_dists_flag
		||', payment_mode = '||P_payment_mode
		||', replace_flag = '||P_replace_flag);

     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
   end if;

     APP_EXCEPTION.RAISE_EXCEPTION;

end ap_pay_insert_invoice_payments;



/*========================================================================
  Update AP_PAYMENT_SCHEDULE
 *========================================================================*/
PROCEDURE ap_pay_update_payment_schedule(
		    P_invoice_id	 IN	NUMBER,
		    P_payment_num	 IN	NUMBER,
        	    P_check_id     	 IN	NUMBER,
		    P_amount		 IN     NUMBER,
  		    P_discount_taken	 IN 	NUMBER,
		    P_payment_dists_flag IN	VARCHAR2,
		    P_payment_mode	 IN	VARCHAR2,
		    P_replace_flag	 IN	VARCHAR2,
		    P_last_updated_by	 IN	NUMBER,
		    P_last_update_date	 IN	DATE,
		    P_calling_sequence   IN     VARCHAR2) IS

debug_info   		  VARCHAR2(100);
current_calling_sequence  VARCHAR2(2000);
l_pmt_status_flag	  AP_PAYMENT_SCHEDULES_ALL.payment_status_flag%TYPE ; -- Bug 8300099
BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence := 'ap_pay_update_payment_schedule<-'||P_calling_sequence;

  if (P_PAYMENT_MODE = 'PAY') then

    if (P_REPLACE_FLAG = 'N') then

      debug_info := 'Update ap_payment_schedules (pay)';

      UPDATE ap_payment_schedules
      SET  amount_remaining = amount_remaining - P_amount -
                                      NVL(P_discount_taken, 0),
           discount_amount_remaining = 0,
           payment_status_flag = DECODE(amount_remaining -
                                      P_amount -
                                      NVL(P_discount_taken, 0),
                                      0, 'Y',
                                      amount_remaining, payment_status_flag,
                                      'P'),
           last_update_date = P_last_update_date,
           last_updated_by = P_last_updated_by
      WHERE  invoice_id = P_invoice_id
      AND    payment_num = P_payment_num;

    elsif (P_REPLACE_FLAG = 'Y') then

      debug_info := 'Update ap_payment_schedules (reissue)';

      UPDATE ap_payment_schedules
      SET    last_update_date = P_last_update_date,
             last_updated_by = P_last_updated_by
      WHERE  invoice_id = P_invoice_id
      AND    payment_num = P_payment_num;

    end if;

  elsif (P_PAYMENT_MODE = 'REV') then

    if (P_REPLACE_FLAG = 'N') then

      debug_info := 'Update ap_payment_schedules (reverse, non-prepayment)';

      -- SELECT statement added by Bug 8300099
      SELECT DECODE( NVL( SUM(AIP.amount), 0 ), 0, 'N', 'P' )
      INTO   l_pmt_status_flag
      FROM   ap_invoice_payments AIP
      WHERE  AIP.invoice_id = p_invoice_id
      AND    AIP.payment_num = p_payment_num
      AND    AIP.check_id <> p_check_id ;

      -- bug7353248 nvl added for aps.amount_remaining

      UPDATE ap_payment_schedules APS
      SET   (amount_remaining
      ,      discount_amount_remaining
      ,      payment_status_flag
      ,      last_update_date
      ,      last_updated_by)
      =     (SELECT nvl(APS.amount_remaining,0) + SUM(AIP.amount)
                                    + SUM(NVL(AIP.discount_taken,0))
             ,      0
             ,      l_pmt_status_flag
	            /* Bug 8300099 : Commented the DECODE being used earlier
		    DECODE(APS.gross_amount, APS.amount_remaining -- Bug 8300099 Commented the fix for 2182168
                    + SUM(AIP.amount)
                    + SUM(NVL(AIP.discount_taken,0)), 'N', 'P')/*DECODE(AI.amount_paid,SUM(AIP.amount),'N','P')*/
              --	2182168 modified the decode statement to compare amount_paid to amount cancelled
             ,      P_last_update_date
             ,      P_last_updated_by
             FROM   ap_invoice_payments AIP,ap_invoices AI --bug2182168 added ap_invoices AI
             WHERE  AIP.invoice_id = P_invoice_id
             AND    AIP.payment_num = P_payment_num
	     AND    AIP.check_id = P_check_id
	     AND    AI.invoice_id=P_invoice_id --bug2182168 added  condition
             GROUP BY AIP.invoice_id
             ,        AIP.payment_num
             ,        APS.gross_amount
             ,        APS.amount_remaining
             ,        APS.discount_amount_remaining
             ,        AI.amount_paid  --bug2182168 added amount_paid in group by clause
  )
      WHERE (invoice_id, payment_num) IN
            (SELECT P_invoice_id
             ,      P_payment_num
             FROM   ap_invoices AI
             WHERE  AI.invoice_id = P_invoice_id
             AND AI.invoice_type_lookup_code <> 'PREPAYMENT');

     --
     --Bug 992128
     --Split the UPDATE into two. First for non-prepayment as above
     --and next for PREPAYMENT as below
     --

      debug_info := 'Update ap_payment_schedules (reverse, prepayment)';

     UPDATE ap_payment_schedules APS
     SET    (amount_remaining
     ,       payment_status_flag
     ,       last_update_date
     ,       last_updated_by)
     =      (SELECT SUM(AIP.amount) + SUM(NVL(AIP.discount_taken, 0))
             ,      'N'
             ,      P_last_update_date
             ,      P_last_updated_by
             FROM   ap_invoice_payments AIP
             WHERE  AIP.invoice_id = P_invoice_id
             AND    AIP.check_id = P_check_id
             AND    AIP.payment_num = APS.payment_num -- Bug 7184181
             GROUP BY AIP.invoice_id)
     WHERE   payment_num = P_payment_num   -- Bug 4701565
     AND     (invoice_id) IN
             (SELECT P_invoice_id
              FROM   ap_invoices AI
              WHERE  AI.invoice_id = P_invoice_id
              AND    AI.invoice_type_lookup_code = 'PREPAYMENT');

    elsif (P_REPLACE_FLAG = 'Y') then

      debug_info := 'Update ap_payment_schedules (replace)';

      UPDATE ap_payment_schedules
      SET    last_update_date = P_last_update_date,
             last_updated_by = P_last_updated_by
      WHERE  invoice_id = P_invoice_id
      AND    payment_num = P_payment_num;

    end if;
  end if;

EXCEPTION
 WHEN OTHERS then

   if (SQLCODE <> -20001 ) then
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice_id = '||TO_CHAR(P_invoice_id)
		||', Payment_num = '||TO_CHAR(P_payment_num)
		||', Check_id = '||TO_CHAR(P_check_id)
		||', Amount = '||TO_CHAR(P_amount)
		||', discount_taken = '||TO_CHAR(P_discount_taken)
		||', Last_update_by = '||TO_CHAR(P_last_updated_by)
		||', Last_update_date = '||TO_CHAR(P_last_update_date)
		||', payment_dists_flag = '||P_payment_dists_flag
		||', payment_mode = '||P_payment_mode
		||', replace_flag = '||P_replace_flag);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
   end if;

     APP_EXCEPTION.RAISE_EXCEPTION;

END ap_pay_update_payment_schedule;

 --------------------------------------------------------------------------
 -- This Function is used by quick checks to determine and update the check
 -- amount.
 -------------------------------------------------------------------------
FUNCTION ap_pay_update_check_amount(x_check_id IN NUMBER)
         RETURN NUMBER
     IS
         check_amount NUMBER;
         l_debug_info VARCHAR2(100);

     BEGIN

         SELECT sum(amount)
         INTO   check_amount
	 FROM   ap_invoice_payments aip
         WHERE  aip.check_id = x_check_id;

         RETURN(check_amount);

     EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN(0);

         UPDATE ap_checks ac
            set amount = check_amount
            where ac.check_id = x_check_id;

END ap_pay_update_check_amount;


/****************************************************************
The procedure was created due to bugs 467167, 661795 .
It is used to update the ap_invoices table and ap_payment_schedules
table when reversing an invoice payment. It is called from the
payment workbench.
******************************************************************/

PROCEDURE ap_inv_pay_update_invoices (
           P_org_invoice_pay_id   NUMBER,
           P_invoice_id           NUMBER,
           P_payment_line_number  NUMBER,
           P_last_update_date     DATE,
           P_last_updated_by      NUMBER,
           P_calling_sequence     VARCHAR2) IS
current_calling_sequence  VARCHAR2(2000);
debug_info   		  VARCHAR2(100);
p_amount                  NUMBER;
p_discount                NUMBER;


Begin

  -- Update the calling sequence
  --
  current_calling_sequence := 'ap_inv_pay_update_invoices<-'||P_calling_sequence;

 -- Get amount_from org_invoice_pay_id
 --
    SELECT amount, discount_taken
    INTO p_amount, p_discount
    FROM ap_invoice_payments
    WHERE invoice_payment_id = p_org_invoice_pay_id;


  -- Bug 1544895 - The update statement for AP_INVOICES that appears below the update
  -- statment for ap_pyment_schedules has been moved from here to after the update
  -- statment for ap_pyment_schedules in this procedure.


  -- Update ap_payment_schedules
  --
      UPDATE ap_payment_schedules
      SET  amount_remaining = amount_remaining + P_amount +
                                      nvl(P_discount,0),
           discount_amount_remaining = 0,
           payment_status_flag = DECODE(amount_remaining +
                                      P_amount +
                                      NVL(P_discount, 0),
                                      0, 'Y',
                                      gross_amount, 'N',
                                      'P'),
           last_update_date = P_last_update_date,
           last_updated_by = P_last_updated_by
      WHERE  invoice_id = P_invoice_id
      AND    payment_num = P_payment_line_number;

  -- Bug 1544895 - Moved the following update statement so that it inserts values
  -- in AP_INVOICES after ap_payment_schedules is updates. This will cause
  -- the payment_status_flag in AP_INVOICES to have the correct value.

  -- Update ap_invoices

      UPDATE ap_invoices
      SET  amount_paid = nvl(amount_paid,0) - P_amount ,
           discount_amount_taken =
                 nvl(discount_amount_taken,0) - nvl(P_discount,0) ,
           payment_status_flag = AP_INVOICES_UTILITY_PKG.get_payment_status( P_invoice_id ),
           last_update_date = P_last_update_date,
           last_updated_by = P_last_updated_by
      WHERE invoice_id = P_invoice_id;

      --Bug 4539462 DBI logging
      AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_INVOICES',
               p_operation => 'U',
               p_key_value1 => P_invoice_id,
                p_calling_sequence => current_calling_sequence);


Exception
 WHEN OTHERS then

   if (SQLCODE <> -20001 ) then
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice_id = '||TO_CHAR(P_invoice_id)
		||', Payment_line_number = '||TO_CHAR(P_payment_line_number)
		||', Amount = '||TO_CHAR(P_amount)
		||', discount_taken = '||TO_CHAR(P_discount)
		||', Last_update_by = '||TO_CHAR(P_last_updated_by)
		||', Last_update_date = '||TO_CHAR(P_last_update_date));

     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
   end if;

   APP_EXCEPTION.RAISE_EXCEPTION;

END ap_inv_pay_update_invoices;

END AP_PAY_INVOICE_PKG;

/
