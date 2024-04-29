--------------------------------------------------------
--  DDL for Package Body AP_PAYMENT_SCHEDULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_PAYMENT_SCHEDULES_PKG" AS
/* $Header: apipascb.pls 120.7.12010000.7 2009/10/06 05:41:54 rseeta ship $ */

  -----------------------------------------------------------------------
  -- PROCEDURE adjust_pay_schedule adjusts the payment schedule of
  -- a paid or partially paid invoice
  --
  -- PRECONDITION: Called from the invoice block in PRE-UPDATE via
  --               stored procedure call ap_invoices_pkg.invoice_pre_update()
  -----------------------------------------------------------------------
  PROCEDURE adjust_pay_schedule (X_invoice_id          IN number,
                                 X_invoice_amount      IN number,
                                 X_payment_status_flag IN OUT NOCOPY varchar2,
                                 X_invoice_type_lookup_code IN varchar2,
                                 X_last_updated_by     IN number,
                                 X_message1            IN OUT NOCOPY varchar2,
                                 X_message2            IN OUT NOCOPY varchar2,
                                 X_reset_match_status  IN OUT NOCOPY varchar2,
                                 X_liability_adjusted_flag IN OUT NOCOPY varchar2,
                                 X_calling_sequence    IN varchar2,
				 X_calling_mode        IN varchar2,
                                 X_revalidate_ps       IN OUT NOCOPY varchar2)
  IS
    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);
    l_current_payment_num  number;
    l_current_amount_to_adjust number;
    l_original_invoice_amount number;
    l_net_amount_to_adjust   number;
    l_payment_num_to_add     number;
    l_amount_remaining     number;
    l_payment_status_flag     ap_payment_schedules.payment_status_flag%TYPE;
    l_allow_paid_invoice_adjust
                        ap_system_parameters.allow_paid_invoice_adjust%TYPE;
    l_add_new_payment_schedule varchar2(1) := 'Y';
    l_sum_ps_amount_remaining	number;
    l_payment_currency_code   ap_invoices.payment_currency_code%TYPE;
    l_invoice_currency_code   ap_invoices.invoice_currency_code%TYPE;
    l_payment_cross_rate      ap_invoices.payment_cross_rate%TYPE;
    l_pay_curr_invoice_amount ap_invoices.pay_curr_invoice_amount%TYPE;
    l_pay_curr_orig_inv_amt   ap_invoices.pay_curr_invoice_amount%TYPE;
    l_pay_curr_net_amt_to_adj number;
    l_inv_curr_sched_total    number;

    --8891266
    l_recouped_amount        number;
    l_amount_paid            NUMBER;

    cursor message1_cursor is
        SELECT 'AP_PAY_WARN_DISC_UPDATE'
        FROM   ap_payment_schedules
        WHERE  invoice_id = X_invoice_id
        AND    payment_num = l_current_payment_num
        AND    (NVL(discount_amount_available, 0) <> 0
                OR NVL(second_disc_amt_available, 0) <> 0
                OR NVL(third_disc_amt_available, 0) <> 0);

    cursor invoice_cursor is
        select AI.invoice_amount,
               SP.allow_paid_invoice_adjust,
               AI.invoice_currency_code,
               AI.payment_currency_code,
               AI.payment_cross_rate,
	       nvl(AI.amount_paid,0),    --bug 8891266
               nvl(AI.pay_curr_invoice_amount, AI.invoice_amount)
        from   ap_invoices AI,
               ap_system_parameters SP
        where  invoice_id = X_invoice_id;

    -- If we're adding a new payment schedule and not adjusting
    -- an existing one, then the payment_status_flag of the
    -- payment schedule we're copying from is irrelevant.
    --
    -- NOTE: The reason l_add_new_payment_schedule is declared as a
    -- 	     varchar2 and not a boolean is that a boolean can not
    --       be evaluated in a cursor select statement.
    --
    cursor pay_sched_adjust_cursor is
        SELECT payment_num,
	       amount_remaining,
	       payment_status_flag
        FROM   ap_payment_schedules
        WHERE  invoice_id = X_invoice_id
        AND    (l_add_new_payment_schedule='Y' OR
		payment_status_flag <> 'Y')
	ORDER BY due_date desc, payment_num desc;

    cursor payment_num_to_add_cursor is
        SELECT nvl((MAX(payment_num)+1),1)
        FROM   ap_payment_schedules
        WHERE  invoice_id = X_invoice_id;

    cursor c_inv_curr_sched_total IS
        SELECT SUM(nvl(inv_curr_gross_amount, gross_amount))
        FROM   ap_payment_schedules
        WHERE  invoice_id = X_Invoice_Id;

  BEGIN
    current_calling_sequence :=
		'AP_PAYMENT_SCHEDULES_PKG.ADJUST_PAY_SCHEDULE<-' ||
				X_calling_sequence;

    -- Determine the original invoice_amount
    -- The precondition of this procedure is that it is being called
    -- in PRE-UPDATE mode; thus the new amount has not been saved
    -- to the database.

    debug_info := 'Determining proper payment schedule to adjust';

    open invoice_cursor;
    debug_info := 'Fetch cursor invoice_cursor';
    fetch invoice_cursor into l_original_invoice_amount,
                              l_allow_paid_invoice_adjust,
                              l_invoice_currency_code,
                              l_payment_currency_code,
                              l_payment_cross_rate,
			      l_amount_paid,  --bug 8891266
                              l_pay_curr_orig_inv_amt;
    debug_info := 'Close cursor invoice_cursor';
    close invoice_cursor;

    l_pay_curr_invoice_amount := ap_utilities_pkg.ap_round_currency(
                                 X_invoice_amount * l_payment_cross_rate,
                                 l_payment_currency_code);
    l_net_amount_to_adjust := X_invoice_amount - l_original_invoice_amount;
    l_pay_curr_net_amt_to_adj := l_pay_curr_invoice_amount -
                                    l_pay_curr_orig_inv_amt;

    if (l_net_amount_to_adjust = 0) then
      -- No need to alter payment schedules if we're not
      -- adjusting the liability
      --
      X_liability_adjusted_flag := 'N';
      return;
    else
      -- Make note of the fact that a liability adjustment will
      -- be made.  In the Invoice Workbench, we will requery the
      -- payment schedules block if the liability_adjusted_flag = 'Y'.
      --
      X_liability_adjusted_flag := 'Y';
    end if;

    -- Although the Invoice Workbench enforces rules which prevent
    -- updates to the invoice (liability) amount in certain cases,
    -- we want to ensure that these rules are enforced server-side
    -- as well.

     --bug 8891266 fetching recouped amount
     l_recouped_amount := AP_MATCHING_UTILS_PKG.Get_Inv_Line_Recouped_Amount
					(P_Invoice_Id          => X_invoice_id,
                                 	 P_Invoice_Line_Number => Null);

    if (ap_invoices_pkg.get_encumbered_flag(X_invoice_id) = 'Y') then
      -- Cannot change the invoice_amount as it is encumbered
      fnd_message.set_name('SQLAP','AP_INV_ALL_DISTS_ENCUMB');
      app_exception.raise_exception;
    elsif (ap_invoices_pkg.get_posting_status(X_invoice_id) = 'Y') then
      -- Cannot change the invoice_amount as it is posted
      fnd_message.set_name('SQLAP','AP_INV_ALL_DIST_POSTED');
      app_exception.raise_exception;
    elsif (ap_invoices_pkg.selected_for_payment_flag(
                        X_invoice_id) = 'Y') then
          -- Cannot change the amount as it is selected for payment
      fnd_message.set_name('SQLAP','AP_INV_SELECTED_INVOICE');
      app_exception.raise_exception;
    elsif (l_allow_paid_invoice_adjust  <> 'Y'
	   and nvl(x_calling_mode, 'X') <> 'APXIIMPT'
	   --bug 8891266 added the below condition
	   and l_amount_paid <> (-1 *  l_recouped_amount )) then
      fnd_message.set_name('SQLAP','AP_DIST_NO_UPDATE_PAID');
      app_exception.raise_exception;
    end if;

    -- Look at the sign of the adjustment and determine whether
    -- an existing payment should be adjusted or a payment schedule
    -- should be added.
    --
    if (X_payment_status_flag <> 'N' and
        ((X_invoice_type_lookup_code in ('CREDIT','DEBIT') and
           l_net_amount_to_adjust <= 0) or
         (X_invoice_type_lookup_code not in ('CREDIT','DEBIT') and
           l_net_amount_to_adjust >= 0))) then
      --
      -- Invoice is either paid or partially paid and the
      -- the amount of the adjustment is greater than the
      -- scheduled payment is absolute terms.  In this case,
      -- we can add a payment schedule
      --
      l_add_new_payment_schedule := 'Y';
    else
      --
      -- We will be adjusting a payment schedule in this case
      --
      l_add_new_payment_schedule := 'N';
    end if;

    --
    -- New for 10SC
    --
    -- Instead of restricting liability adjustment to a single
    -- payment schedule, we will iteratively apply adjustment to all unpaid
    -- and partially paid payment schedules in descending order
    -- of due date until the adjustment is fully applied.
    --
    -- We will delete any unpaid payment schedules where an adjustment
    -- will cause the gross amount to be reduced to zero.
    --
    -- If an adjustment to existing payment schedule is not planned,
    -- ie, we will be adding a new one, then the first fetch from
    -- pay_sched_adjust_cursor will yield the payment_num of the
    -- payment schedule that we wish to base our new record on.
    --
    debug_info := 'Open pay_sched_adjust_cursor';
    open pay_sched_adjust_cursor;

    loop

      debug_info := 'Fetch pay_sched_adjust_cursor';
      fetch pay_sched_adjust_cursor into l_current_payment_num,
					 l_amount_remaining,
					 l_payment_status_flag;

      -- Leave the cursor if we intend to create a new payment schedule
      -- or if we've run out NOCOPY of payment schedules to process.
      --
      exit when (l_add_new_payment_schedule='Y' or
                 pay_sched_adjust_cursor%NOTFOUND);

      -- For the current payment schedule, reduce the gross_amount
      -- by the adjustment amount or its amount_remaining,
      -- whichever is less.
      --
      if (ABS(l_amount_remaining) - ABS(l_pay_curr_net_amt_to_adj) >= 0) then
        l_current_amount_to_adjust := l_pay_curr_net_amt_to_adj;
      else
        l_current_amount_to_adjust := (0 - l_amount_remaining);
      end if;

      -- If the adjustment is being made for the entire gross amount
      -- of the payment schedule and the payment schedule is unpaid,
      -- then delete the record, otherwise update it.
      --
      if ((l_amount_remaining + l_current_amount_to_adjust = 0) and
	  l_payment_status_flag not in ('Y','P')) then

        debug_info := 'Delete AP_PAYMENT_SCHEDULES payment_num '||
                      l_current_payment_num;

        delete from ap_payment_schedules
        where  invoice_id = X_invoice_id
        and    payment_num = l_current_payment_num;

      else
        --
        -- Update the payment schedule.
        --
        -- NOTE: This is non-standard to have an update to another table
        -- called from the pre_update trigger.  We anticipate no problems
        -- in this case because the table ap_invoices was marked already
        -- when the commit was invoked.  (See the update_liability trigger.)
        -- Usual locking order is invoices then pay lines,
        -- so this is consistent.
        --
        debug_info := 'Update AP_PAYMENT_SCHEDULES payment_num '||
                      l_current_payment_num;

        UPDATE ap_payment_schedules
        SET    gross_amount = NVL(gross_amount, 0)+l_current_amount_to_adjust,
               inv_curr_gross_amount = (
                   SELECT   DECODE(F.minimum_accountable_unit,NULL,
    	                       ROUND( ((NVL(gross_amount, 0)+
                                       l_current_amount_to_adjust)/
                                       l_payment_cross_rate)
                                      , F.precision),
                               ROUND( ((NVL(gross_amount, 0)+
                                       l_current_amount_to_adjust)/
                                       l_payment_cross_rate)
                                      / F.minimum_accountable_unit)
	                              * F.minimum_accountable_unit)
                   FROM   fnd_currencies_vl F
                   WHERE  F.currency_code = l_invoice_currency_code),
               amount_remaining = NVL(amount_remaining, 0)
                                + l_current_amount_to_adjust,
               payment_status_flag =
                DECODE(NVL(amount_remaining, 0) +
                       l_current_amount_to_adjust,
                           NVL(gross_amount, 0) +
                           l_current_amount_to_adjust, 'N',
                       0, DECODE(X_invoice_amount,
                                0,'N',
                                  'Y'),
                          'P')
        WHERE  invoice_id = X_invoice_id
        AND    payment_num = l_current_payment_num;


        -- If message name is returned in to X_Message1 then
        -- we know that the payment schedule line has a non-zero
        -- discount which may need adjustment
        -- Message to display is AP_PAY_WARN_DISC_UPDATE
        --
        if (X_Message1 is null) then
          debug_info := 'Select from AP_PAYMENT_SCHEDULES';

          open message1_cursor;
          debug_info := 'Fetch message1_cursor';
          fetch message1_cursor into X_Message1;
          debug_info := 'Close message1_cursor';
          close message1_cursor;
        end if;
      end if;

      -- Reduce the Net Adjustment amount by the amount we're
      -- applying in this adjustment.
      --
      l_pay_curr_net_amt_to_adj := l_pay_curr_net_amt_to_adj -
				    l_current_amount_to_adjust;

      -- If the adjustment has been fully applied then exit the loop
      exit when (l_pay_curr_net_amt_to_adj = 0);

    end loop;

    debug_info := 'Close pay_sched_adjust_cursor';
    close pay_sched_adjust_cursor;

    -- If the previous cursor retrieved no payment schedules,
    -- fail the procedure and tell the user.
    --
    if (l_current_payment_num is null) then
      -- Cannot find a payment schedule to adjust
      FND_MESSAGE.Set_Name('SQLAP', 'AP_INV_NO_PAYMENT_SCHEDULE');
      FND_MESSAGE.Set_Name('SQLAP', 'AP_PAY_NO_PAYMENT_SCHEDULE');
      APP_EXCEPTION.Raise_Exception;
    end if;

    -- Adjust for any rounding errors that might have been introduced
    -- for inv_curr_gross_amount

    if (l_add_new_payment_schedule = 'N') then
      debug_info := 'Open cursor c_inv_curr_sched_total';
      OPEN  c_inv_curr_sched_total;
      debug_info := 'Fetch cursor c_inv_curr_sched_total';
      FETCH c_inv_curr_sched_total INTO l_inv_curr_sched_total;
      debug_info := 'Close cursor c_inv_curr_sched_total';
      CLOSE c_inv_curr_sched_total;

      -- Adjust inv_curr_gross_amount for rounding errors
                                                                         --
      IF (l_inv_curr_sched_total <> X_invoice_amount) THEN
                                                                         --
        debug_info:= 'Update ap_payment_schedules - set inv_curr_gross_amount';
        UPDATE AP_PAYMENT_SCHEDULES
        SET inv_curr_gross_amount = inv_curr_gross_amount
                                    + X_Invoice_Amount
                                    - l_inv_curr_sched_total
        WHERE invoice_id = X_Invoice_Id
        AND payment_num = (SELECT MAX(payment_num)
                           FROM   ap_payment_schedules
                           WHERE  invoice_id = X_Invoice_Id);
                                                                         --
      END IF;
    end if;
                                                                         --
    -- Add the new payment schedule
    --
    if (l_add_new_payment_schedule = 'Y') then

      -- Determine payment num of new payment schedule
      debug_info := 'Open payment_num_to_add_cursor';
      open payment_num_to_add_cursor;
      debug_info := 'Fetch payment_num_to_add_cursor';
      fetch payment_num_to_add_cursor into l_payment_num_to_add;
      debug_info := 'Close payment_num_to_add_cursor';
      close payment_num_to_add_cursor;

      debug_info := 'Insert into AP_PAYMENT_SCHEDULES';

      -- Insert the new payment schedule
      INSERT INTO ap_payment_schedules(
      invoice_id, payment_num, due_date,
      last_update_date, last_updated_by,
      last_update_login, creation_date, created_by,
      payment_cross_rate,
      gross_amount,inv_curr_gross_amount,amount_remaining,
      payment_priority, hold_flag,
      payment_status_flag, batch_id, payment_method_code,
      external_bank_account_id,
      org_id, --MOAC project
      remittance_message1,
      remittance_message2,
      remittance_message3,
      --third party payments
      remit_to_supplier_name,
      remit_to_supplier_id,
      remit_to_supplier_site,
      remit_to_supplier_site_id,
      relationship_id
      )
      SELECT X_invoice_id, l_payment_num_to_add, P.due_date,
             SYSDATE, X_last_updated_by,
             null, SYSDATE, X_last_updated_by,
             P.payment_cross_rate,
             l_pay_curr_net_amt_to_adj,
             l_net_amount_to_adjust,
             l_pay_curr_net_amt_to_adj,
             P.payment_priority, P.hold_flag, 'N', P.batch_id,
             P.payment_method_code,
             P.external_bank_account_id,
             P.org_id, --MOAC project
             p.remittance_message1,
             p.remittance_message2,
             p.remittance_message3,
	     --third party payments
	     p.remit_to_supplier_name,
	     p.remit_to_supplier_id,
	     p.remit_to_supplier_site,
	     p.remit_to_supplier_site_id,
	     p.relationship_id
      FROM   ap_payment_schedules P
      WHERE  P.invoice_id           = X_invoice_id
      AND    P.payment_num          = l_current_payment_num;

      x_revalidate_ps := 'Y';



      -- If encumbrance is on, then this invoice will already have dist
      -- lines that need reapproval, so we can skip this.  Plus, we don't
      -- want to flip any 'A' flags to 'N' if encumbrance is on.
      X_reset_match_status := 'Y';

    else
      --
      -- Existing payment schedules were adjusted.  Inform user.
      --
      X_Message2 := 'AP_PAY_WARN_SCHED_UPDATE';
    end if;

    --
    -- Check if we need to change the payment_status_flag
    --
     SELECT sum(amount_remaining)
       INTO l_sum_ps_amount_remaining
       FROM ap_payment_schedules
      WHERE invoice_id = X_invoice_id;

    if (l_sum_ps_amount_remaining <> 0) then
  	X_payment_status_flag := 'P';
    else
        X_payment_status_flag := 'Y';
    end if;


     EXCEPTION
       WHEN OTHERS THEN
         IF (SQLCODE <> -20001) THEN
           FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
           FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
           FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                     current_calling_sequence);
           FND_MESSAGE.SET_TOKEN('PARAMETERS',
               'X_invoice_id = '        ||X_invoice_id
           ||', X_invoice_amount = '    ||X_invoice_amount
           ||', X_payment_status_flag= '||X_payment_status_flag
           ||', X_invoice_type_lookup_code = '||X_invoice_type_lookup_code
           ||', X_last_updated_by = '   ||X_last_updated_by
           ||', X_message1 = '          ||X_message1
           ||', X_message2 = '          ||X_message2
           ||', X_reset_match_status = '||X_reset_match_status
           ||', X_liability_adjusted_flag = '||X_liability_adjusted_flag
                                    );
           FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
         END IF;
       APP_EXCEPTION.RAISE_EXCEPTION;

  END adjust_pay_schedule;

  -----------------------------------------------------------------------
  -- FUNCTION get_amt_withheld_per_sched, returns prorated withheld
  -- per payment schedule of an invoice.
  -- Function added for bug 3484292
  -----------------------------------------------------------------------

  FUNCTION get_amt_withheld_per_sched(X_invoice_id           IN NUMBER,
                                      X_gross_amount         IN NUMBER,
                                      X_currency_code        IN VARCHAR2)
  RETURN NUMBER
  IS
  l_wt_amt_to_subtract number :=0;
  BEGIN
        select  nvl(ap_utilities_pkg.ap_round_currency(
                ap_invoices_pkg.get_amount_withheld(ai.invoice_id)*
       		ai.payment_cross_rate,X_currency_code),0)*
                X_gross_amount/decode(ai.pay_curr_invoice_amount, 0, 1,
				      nvl(ai.pay_curr_invoice_amount, 1))
	into    l_wt_amt_to_subtract
        from    ap_invoices ai
        where   ai.invoice_id=X_invoice_id;
  return l_wt_amt_to_subtract;
  END get_amt_withheld_per_sched;

  -----------------------------------------------------------------------
  -- FUNCTION get_discount_available computes the discount available
  -- based on X_check_date
  -----------------------------------------------------------------------
  FUNCTION get_discount_available(X_invoice_id	       IN NUMBER,
				  X_payment_num	       IN NUMBER,
				  X_check_date	       IN DATE,
				  X_currency_code      IN VARCHAR2)
    RETURN NUMBER
  IS
    l_discount_available	NUMBER;
    l_wt_amt_to_subtract        NUMBER := 0; --Bug 3484292
    l_gross_amount              NUMBER;      -- BUG 3741934
  BEGIN

    -- bug 3484292 Added the select stmt below.
    select  nvl(ap_utilities_pkg.ap_round_currency(
     ap_invoices_pkg.get_amount_withheld(ai.invoice_id)*
       ai.payment_cross_rate,X_currency_code),0)*
                 aps.gross_amount/decode(ai.pay_curr_invoice_amount, 0, 1,
					 nvl(ai.pay_curr_invoice_amount, 1)),
         aps.gross_amount                                -- BUG 3741934
    into l_wt_amt_to_subtract, l_gross_amount
    from ap_invoices ai,ap_payment_schedules aps
    where ai.invoice_id=aps.invoice_id
    and   aps.payment_num=X_payment_num
    and    ai.invoice_id=X_invoice_id;

/*
     BUG 3741934: Branch around the SQL that calculates the discount if the
                  Gross Amount of the payment schedule is equal to the withheld
                  amount.
*/

   IF l_wt_amt_to_subtract <> l_gross_amount
   THEN
    SELECT NVL(ap_utilities_pkg.ap_round_currency(
	     DECODE(gross_amount, 0, 0,
	       DECODE(air.always_take_disc_flag, 'Y', discount_amount_available,  --Bug7717053, added the table alias
		 GREATEST(
                  DECODE(SIGN(X_check_date -
	                 NVL(discount_date, sysdate-9000)),
			    1, 0, NVL(ABS(discount_amount_available), 0)),
	          DECODE(SIGN(X_check_date -
		         NVL(second_discount_date, sysdate-9000)),
		            1, 0, NVL(ABS(second_disc_amt_available), 0)),
	          DECODE(SIGN(X_check_date -
		         NVL(third_discount_date, sysdate-9000)),
		            1, 0, NVL(ABS(third_disc_amt_available),0))) * DECODE(SIGN(gross_amount),-1,-1,1) )
	       * (amount_remaining/DECODE(gross_amount, 0, 1, gross_amount-decode(asp.create_awt_dists_type,
                                     'APPROVAL',
                                     l_wt_amt_to_subtract,
                                     0)))),
                 X_currency_code),0)                              --Bug7717053, added the decode
    INTO   l_discount_available
    FROM   ap_invoices_ready_to_pay_v air, ap_system_parameters_all asp
    WHERE  invoice_id = X_invoice_id
    AND    payment_num = X_payment_num
    AND    air.org_id = asp.org_id;  --Added for bug #8506044;
   ELSE l_discount_available := 0;
   END IF;

    RETURN l_discount_available;

  END get_discount_available;

  -----------------------------------------------------------------------
  -- FUNCTION get_discount_date computes the discount date based on
  -- X_check_date
  -----------------------------------------------------------------------
  FUNCTION get_discount_date(X_invoice_id	IN NUMBER,
			     X_payment_num	IN NUMBER,
			     X_check_date	IN DATE)
    RETURN DATE
  IS
    l_discount_date		DATE;
  BEGIN

    SELECT DECODE(always_take_disc_flag, 'Y', due_date,
	     DECODE(SIGN(X_check_date - NVL(discount_date,sysdate-9000)-1),
	            -1, discount_date,
	       DECODE(SIGN(X_check_date - NVL(second_discount_date,sysdate-9000)-1),
	              -1, second_discount_date,
	         DECODE(SIGN(X_check_date - NVL(third_discount_date,sysdate-9000)-1),
			-1, third_discount_date, due_date))))
    INTO   l_discount_date
    FROM   ap_invoices_ready_to_pay_v
    WHERE  invoice_id = X_invoice_id
    AND    payment_num = X_payment_num;

    RETURN l_discount_date;

  END get_discount_date;
PROCEDURE Lock_Row(	X_Invoice_Id                               NUMBER,
			X_Last_Updated_By                          NUMBER,
			X_Last_Update_Date                         DATE,
			X_Payment_Cross_Rate                       NUMBER,
			X_Payment_Num                              NUMBER,
			X_Amount_Remaining                         NUMBER,
			X_Created_By                               NUMBER,
			X_Creation_Date                            DATE,
			X_Discount_Date                            DATE,
			X_Due_Date                                 DATE,
			X_Future_Pay_Due_Date                      DATE,
			X_Gross_Amount                             NUMBER,
			X_Hold_Flag                                VARCHAR2,
			X_iby_hold_reason                          VARCHAR2, /*bug 8893354 */
			X_Last_Update_Login                        NUMBER,
			X_Payment_Method_Lookup_Code               VARCHAR2 default null,
                        X_payment_method_code                      varchar2,
			X_Payment_Priority                         NUMBER,
			X_Payment_Status_Flag                      VARCHAR2,
			X_Second_Discount_Date                     DATE,
			X_Third_Discount_Date                      DATE,
			X_Batch_Id                                 NUMBER,
			X_Discount_Amount_Available                NUMBER,
			X_Second_Disc_Amt_Available                NUMBER,
			X_Third_Disc_Amt_Available                 NUMBER,
			X_Attribute1                               VARCHAR2,
			X_Attribute10                              VARCHAR2,
			X_Attribute11                              VARCHAR2,
			X_Attribute12                              VARCHAR2,
			X_Attribute13                              VARCHAR2,
			X_Attribute14                              VARCHAR2,
			X_Attribute15                              VARCHAR2,
			X_Attribute2                               VARCHAR2,
			X_Attribute3                               VARCHAR2,
			X_Attribute4                               VARCHAR2,
			X_Attribute5                               VARCHAR2,
			X_Attribute6                               VARCHAR2,
			X_Attribute7                               VARCHAR2,
			X_Attribute8                               VARCHAR2,
			X_Attribute9                               VARCHAR2,
			X_Attribute_Category                       VARCHAR2,
			X_Discount_Amount_Remaining                NUMBER,
			X_Global_Attribute_Category                VARCHAR2,
			X_Global_Attribute1                        VARCHAR2,
			X_Global_Attribute2                        VARCHAR2,
			X_Global_Attribute3                        VARCHAR2,
			X_Global_Attribute4                        VARCHAR2,
			X_Global_Attribute5                        VARCHAR2,
			X_Global_Attribute6                        VARCHAR2,
			X_Global_Attribute7                        VARCHAR2,
			X_Global_Attribute8                        VARCHAR2,
			X_Global_Attribute9                        VARCHAR2,
			X_Global_Attribute10                       VARCHAR2,
			X_Global_Attribute11                       VARCHAR2,
			X_Global_Attribute12                       VARCHAR2,
			X_Global_Attribute13                       VARCHAR2,
			X_Global_Attribute14                       VARCHAR2,
			X_Global_Attribute15                       VARCHAR2,
			X_Global_Attribute16                       VARCHAR2,
			X_Global_Attribute17                       VARCHAR2,
			X_Global_Attribute18                       VARCHAR2,
			X_Global_Attribute19                       VARCHAR2,
			X_Global_Attribute20                       VARCHAR2,
			X_External_Bank_Account_Id                 NUMBER,
			X_Inv_Curr_Gross_Amount                    NUMBER,
                        X_Org_Id                                   NUMBER,
			X_Calling_Sequence                     IN  VARCHAR2,
			--Third Party Payments
			X_Remit_To_Supplier_Name		VARCHAR2,
			X_Remit_To_Supplier_Id		NUMBER,
			X_Remit_To_Supplier_Site		VARCHAR2,
			X_Remit_To_Supplier_Site_Id		NUMBER,
			X_Relationship_Id				NUMBER
) IS
  CURSOR C IS
      SELECT *
      FROM   ap_payment_schedules
      WHERE  invoice_id = X_Invoice_Id
      AND    payment_num = X_Payment_Num
      FOR UPDATE of invoice_id NOWAIT;
  Recinfo C%ROWTYPE;

  first_conditions BOOLEAN := TRUE;
  current_calling_sequence      VARCHAR2(2000);
  debug_info                    VARCHAR2(100);

  BEGIN
  -- Update the calling sequence
  --
    current_calling_sequence :=
               'AP_PAYMENT_SCHEDULES_PKG.LOCK_ROW<-'||X_calling_sequence;

    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      debug_info := 'Close cursor C - ROW NOTFOUND';
      CLOSE C;
      RAISE NO_DATA_FOUND;
    end if;
    debug_info := 'Close cursor C';
    CLOSE C;

    first_conditions :=
	    ((Recinfo.Invoice_Id = X_Invoice_Id) OR
	     ((Recinfo.Invoice_Id IS NULL)
	      AND (X_Invoice_Id IS NULL)))
	AND ((Recinfo.Last_Updated_By = X_Last_Updated_By) OR
	     ((Recinfo.Last_Updated_By IS NULL)
	      AND (X_Last_Updated_By IS NULL)))
      -- Bug 2909797 AND ((Recinfo.Last_Update_Date = X_Last_Update_Date) OR
      --     ((Recinfo.Last_Update_Date IS NULL)
      --      AND (X_Last_Update_Date IS NULL)))
	AND ((Recinfo.Payment_Cross_Rate = X_Payment_Cross_Rate) OR
	     ((Recinfo.Payment_Cross_Rate IS NULL)
	      AND (X_Payment_Cross_Rate IS NULL)))
	AND ((Recinfo.Payment_Num = X_Payment_Num) OR
	     ((Recinfo.Payment_Num IS NULL)
	      AND (X_Payment_Num IS NULL)))
	AND ((Recinfo.Amount_Remaining = X_Amount_Remaining) OR
	     ((Recinfo.Amount_Remaining IS NULL)
	      AND (X_Amount_Remaining IS NULL)))
	AND ((Recinfo.Created_By = X_Created_By) OR
	     ((Recinfo.Created_By IS NULL)
	      AND (X_Created_By IS NULL)))
      -- Bug 2909797 AND ((Recinfo.Creation_Date = X_Creation_Date) OR
      --     ((Recinfo.Creation_Date IS NULL)
      --      AND (X_Creation_Date IS NULL)))
	AND ((Recinfo.Discount_Date = X_Discount_Date) OR
	     ((Recinfo.Discount_Date IS NULL)
	      AND (X_Discount_Date IS NULL)))
	/* AND ((Recinfo.Due_Date = X_Due_Date) OR Commented for bug#8487514 */
	AND ((trunc(Recinfo.Due_Date) = trunc(X_Due_Date)) OR /* Added for bug#8487514 */
	     ((Recinfo.Due_Date IS NULL)
	      AND (X_Due_Date IS NULL)))
	AND ((Recinfo.Future_Pay_Due_Date = X_Future_Pay_Due_Date) OR
	     ((Recinfo.Future_Pay_Due_Date IS NULL)
	      AND (X_Future_Pay_Due_Date IS NULL)))
	AND ((Recinfo.Gross_Amount = X_Gross_Amount) OR
	     ((Recinfo.Gross_Amount IS NULL)
	      AND (X_Gross_Amount IS NULL)))
	AND ((Recinfo.Hold_Flag = X_Hold_Flag) OR
	     ((Recinfo.Hold_Flag IS NULL)
	      AND (X_Hold_Flag IS NULL)))
	AND ((Recinfo.iby_hold_reason = X_iby_hold_reason) OR
	     ((Recinfo.iby_hold_reason IS NULL)
	      AND (X_iby_hold_reason IS NULL))) /*bug 8893354*/
	AND ((Recinfo.Last_Update_Login = X_Last_Update_Login) OR
	     ((Recinfo.Last_Update_Login IS NULL)
	      AND (X_Last_Update_Login IS NULL)))
	AND ((Recinfo.Payment_Method_Code = X_Payment_Method_Code) OR
	     ((Recinfo.Payment_Method_Code IS NULL)
	      AND (X_Payment_Method_Code IS NULL)))
	AND ((Recinfo.Payment_Priority = X_Payment_Priority) OR
	     ((Recinfo.Payment_Priority IS NULL)
	      AND (X_Payment_Priority IS NULL)))
	AND ((Recinfo.Payment_Status_Flag = X_Payment_Status_Flag) OR
	     ((Recinfo.Payment_Status_Flag IS NULL)
	      AND (X_Payment_Status_Flag IS NULL)))
	AND ((Recinfo.Second_Discount_Date = X_Second_Discount_Date) OR
	     ((Recinfo.Second_Discount_Date IS NULL)
	      AND (X_Second_Discount_Date IS NULL)))
	AND ((Recinfo.Third_Discount_Date = X_Third_Discount_Date) OR
	     ((Recinfo.Third_Discount_Date IS NULL)
	      AND (X_Third_Discount_Date IS NULL)))
	AND ((Recinfo.Batch_Id = X_Batch_Id) OR
	     ((Recinfo.Batch_Id IS NULL)
	      AND (X_Batch_Id IS NULL)))
	AND ((Recinfo.Discount_Amount_Available = X_Discount_Amount_Available) OR
	     ((Recinfo.Discount_Amount_Available IS NULL)
	      AND (X_Discount_Amount_Available IS NULL)))
	AND ((Recinfo.Second_Disc_Amt_Available = X_Second_Disc_Amt_Available) OR
	     ((Recinfo.Second_Disc_Amt_Available IS NULL)
	      AND (X_Second_Disc_Amt_Available IS NULL)))
	AND ((Recinfo.Third_Disc_Amt_Available = X_Third_Disc_Amt_Available) OR
	     ((Recinfo.Third_Disc_Amt_Available IS NULL)
	      AND (X_Third_Disc_Amt_Available IS NULL)))
	AND ((Recinfo.Attribute1 = X_Attribute1) OR
	     ((Recinfo.Attribute1 IS NULL)
	      AND (X_Attribute1 IS NULL)))
	AND ((Recinfo.Attribute10 = X_Attribute10) OR
	     ((Recinfo.Attribute10 IS NULL)
	      AND (X_Attribute10 IS NULL)))
	AND ((Recinfo.Attribute11 = X_Attribute11) OR
	     ((Recinfo.Attribute11 IS NULL)
	      AND (X_Attribute11 IS NULL)))
	AND ((Recinfo.Attribute12 = X_Attribute12) OR
	     ((Recinfo.Attribute12 IS NULL)
	      AND (X_Attribute12 IS NULL)))
	AND ((Recinfo.Attribute13 = X_Attribute13) OR
	     ((Recinfo.Attribute13 IS NULL)
	      AND (X_Attribute13 IS NULL)))
	AND ((Recinfo.Attribute14 = X_Attribute14) OR
	     ((Recinfo.Attribute14 IS NULL)
	      AND (X_Attribute14 IS NULL)))
	AND ((Recinfo.Attribute15 = X_Attribute15) OR
	     ((Recinfo.Attribute15 IS NULL)
	      AND (X_Attribute15 IS NULL)))
	AND ((Recinfo.Attribute2 = X_Attribute2) OR
	     ((Recinfo.Attribute2 IS NULL)
	      AND (X_Attribute2 IS NULL)))
	AND ((Recinfo.Attribute3 = X_Attribute3) OR
	     ((Recinfo.Attribute3 IS NULL)
	      AND (X_Attribute3 IS NULL)))
	AND ((Recinfo.Attribute4 = X_Attribute4) OR
	     ((Recinfo.Attribute4 IS NULL)
	      AND (X_Attribute4 IS NULL)))
	AND ((Recinfo.Attribute5 = X_Attribute5) OR
	     ((Recinfo.Attribute5 IS NULL)
	      AND (X_Attribute5 IS NULL)))
	AND ((Recinfo.Attribute6 = X_Attribute6) OR
	     ((Recinfo.Attribute6 IS NULL)
	      AND (X_Attribute6 IS NULL)))
	AND ((Recinfo.Attribute7 = X_Attribute7) OR
	     ((Recinfo.Attribute7 IS NULL)
	      AND (X_Attribute7 IS NULL)))
	AND ((Recinfo.Attribute8 = X_Attribute8) OR
	     ((Recinfo.Attribute8 IS NULL)
	      AND (X_Attribute8 IS NULL)))
	AND ((Recinfo.Attribute9 = X_Attribute9) OR
	     ((Recinfo.Attribute9 IS NULL)
	      AND (X_Attribute9 IS NULL)))
	AND ((Recinfo.Attribute_Category = X_Attribute_Category) OR
	     ((Recinfo.Attribute_Category IS NULL)
	      AND (X_Attribute_Category IS NULL)))
	AND ((Recinfo.Discount_Amount_Remaining = X_Discount_Amount_Remaining) OR
	     ((Recinfo.Discount_Amount_Remaining IS NULL)
	      AND (X_Discount_Amount_Remaining IS NULL)))
	-- Third party payments
	AND ((Recinfo.Remit_To_Supplier_Name = X_Remit_To_Supplier_Name) OR
             ((Recinfo.Remit_To_Supplier_Name IS NULL)
              AND (X_Remit_To_Supplier_Name IS NULL)))
        AND ((Recinfo.Remit_To_Supplier_Id = X_Remit_To_Supplier_Id) OR
             ((Recinfo.Remit_To_Supplier_Id IS NULL)
              AND (X_Remit_To_Supplier_Id IS NULL)))
        AND ((Recinfo.Remit_To_Supplier_Site = X_Remit_To_Supplier_Site) OR
             ((Recinfo.Remit_To_Supplier_Site IS NULL)
              AND (X_Remit_To_Supplier_Site IS NULL)))
        AND ((Recinfo.Remit_To_Supplier_Site_Id = X_Remit_To_Supplier_Site_Id) OR
             ((Recinfo.Remit_To_Supplier_Site_Id IS NULL)
              AND (X_Remit_To_Supplier_Site_Id IS NULL)))
        AND ((Recinfo.Relationship_Id = X_Relationship_Id) OR
             ((Recinfo.Relationship_Id IS NULL)
              AND (X_Relationship_Id IS NULL)));

    if (first_conditions
	AND ((Recinfo.Global_Attribute_Category = X_Global_Attribute_Category) OR
	     ((Recinfo.Global_Attribute_Category IS NULL)
	      AND (X_Global_Attribute_Category IS NULL)))
	AND ((Recinfo.Global_Attribute1 = X_Global_Attribute1) OR
	     ((Recinfo.Global_Attribute1 IS NULL)
	      AND (X_Global_Attribute1 IS NULL)))
	AND ((Recinfo.Global_Attribute2 = X_Global_Attribute2) OR
	     ((Recinfo.Global_Attribute2 IS NULL)
	      AND (X_Global_Attribute2 IS NULL)))
	AND ((Recinfo.Global_Attribute3 = X_Global_Attribute3) OR
	     ((Recinfo.Global_Attribute3 IS NULL)
	      AND (X_Global_Attribute3 IS NULL)))
	AND ((Recinfo.Global_Attribute4 = X_Global_Attribute4) OR
	     ((Recinfo.Global_Attribute4 IS NULL)
	      AND (X_Global_Attribute4 IS NULL)))
	AND ((Recinfo.Global_Attribute5 = X_Global_Attribute5) OR
	     ((Recinfo.Global_Attribute5 IS NULL)
	      AND (X_Global_Attribute5 IS NULL)))
	AND ((Recinfo.Global_Attribute6 = X_Global_Attribute6) OR
	     ((Recinfo.Global_Attribute6 IS NULL)
	      AND (X_Global_Attribute6 IS NULL)))
	AND ((Recinfo.Global_Attribute7 = X_Global_Attribute7) OR
	     ((Recinfo.Global_Attribute7 IS NULL)
	      AND (X_Global_Attribute7 IS NULL)))
	AND ((Recinfo.Global_Attribute8 = X_Global_Attribute8) OR
	     ((Recinfo.Global_Attribute8 IS NULL)
	      AND (X_Global_Attribute8 IS NULL)))
	AND ((Recinfo.Global_Attribute9 = X_Global_Attribute9) OR
	     ((Recinfo.Global_Attribute9 IS NULL)
	      AND (X_Global_Attribute9 IS NULL)))
	AND ((Recinfo.Global_Attribute10 = X_Global_Attribute10) OR
	     ((Recinfo.Global_Attribute10 IS NULL)
	      AND (X_Global_Attribute10 IS NULL)))
	AND ((Recinfo.Global_Attribute11 = X_Global_Attribute11) OR
	     ((Recinfo.Global_Attribute11 IS NULL)
	      AND (X_Global_Attribute11 IS NULL)))
	AND ((Recinfo.Global_Attribute12 = X_Global_Attribute12) OR
	     ((Recinfo.Global_Attribute12 IS NULL)
	      AND (X_Global_Attribute12 IS NULL)))
	AND ((Recinfo.Global_Attribute13 = X_Global_Attribute13) OR
	     ((Recinfo.Global_Attribute13 IS NULL)
	      AND (X_Global_Attribute13 IS NULL)))
	AND ((Recinfo.Global_Attribute14 = X_Global_Attribute14) OR
	     ((Recinfo.Global_Attribute14 IS NULL)
	      AND (X_Global_Attribute14 IS NULL)))
	AND ((Recinfo.Global_Attribute15 = X_Global_Attribute15) OR
	     ((Recinfo.Global_Attribute15 IS NULL)
	      AND (X_Global_Attribute15 IS NULL)))
	AND ((Recinfo.Global_Attribute16 = X_Global_Attribute16) OR
	     ((Recinfo.Global_Attribute16 IS NULL)
	      AND (X_Global_Attribute16 IS NULL)))
	AND ((Recinfo.Global_Attribute17 = X_Global_Attribute17) OR
	     ((Recinfo.Global_Attribute17 IS NULL)
	      AND (X_Global_Attribute17 IS NULL)))
	AND ((Recinfo.Global_Attribute18 = X_Global_Attribute18) OR
	     ((Recinfo.Global_Attribute18 IS NULL)
	      AND (X_Global_Attribute18 IS NULL)))
	AND ((Recinfo.Global_Attribute19 = X_Global_Attribute19) OR
	     ((Recinfo.Global_Attribute19 IS NULL)
	      AND (X_Global_Attribute19 IS NULL)))
	AND ((Recinfo.Global_Attribute20 = X_Global_Attribute20) OR
	     ((Recinfo.Global_Attribute20 IS NULL)
	      AND (X_Global_Attribute20 IS NULL)))
	AND ((Recinfo.External_Bank_Account_Id = X_External_Bank_Account_Id) OR
	     ((Recinfo.External_Bank_Account_Id IS NULL)
	      AND (X_External_Bank_Account_Id IS NULL)))
	AND ((Recinfo.Inv_Curr_Gross_Amount = X_Inv_Curr_Gross_Amount) OR
	     ((Recinfo.Inv_Curr_Gross_Amount IS NULL)
	      AND (X_Inv_Curr_Gross_Amount IS NULL)))
        AND ((Recinfo.Org_Id = X_Org_Id) OR
             ((Recinfo.Org_Id IS NULL)
              AND (X_Org_Id IS NULL)))
) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;

  EXCEPTION
     WHEN OTHERS THEN
         IF (SQLCODE <> -20001) THEN
           IF (SQLCODE = -54) THEN
             FND_MESSAGE.SET_NAME('SQLAP','AP_RESOURCE_BUSY');
           ELSE
             FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
             FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
             FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                       current_calling_sequence);
             FND_MESSAGE.SET_TOKEN('PARAMETERS',
                 'X_Invoice_Id = '||X_Invoice_Id
             ||', X_Payment_Num = '||X_Payment_Num
                                  );
             FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
         END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

  END Lock_Row;

END AP_PAYMENT_SCHEDULES_PKG;

/
