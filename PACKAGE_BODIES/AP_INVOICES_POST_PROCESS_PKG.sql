--------------------------------------------------------
--  DDL for Package Body AP_INVOICES_POST_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_INVOICES_POST_PROCESS_PKG" AS
/* $Header: apinvppb.pls 120.13.12010000.7 2010/02/10 08:58:37 asansari ship $ */

 -----------------------------------------------------------------------
  -- Procedure create_holds
  -- Creates invoice limit and vendor holds
  -- Called for an invoice at POST_UPDATE and POST_INSERT
  -----------------------------------------------------------------------
  procedure create_holds (X_invoice_id           IN number,
                          X_event                IN varchar2 default 'UPDATE',
                          X_update_base          IN varchar2 default 'N',
                          X_vendor_changed_flag  IN varchar2 default 'N',
                          X_calling_sequence     IN varchar2)
  IS
     current_calling_sequence           VARCHAR2(2000);
     debug_info                         VARCHAR2(100);
     l_invoice_amount                   AP_INVOICES.invoice_amount%TYPE;
     l_base_amount                      AP_INVOICES.base_amount%TYPE;
     l_invoice_currency_code
                        AP_INVOICES.invoice_currency_code%TYPE;
     l_invoice_amount_limit
                        PO_VENDOR_SITES.invoice_amount_limit%TYPE;
     l_base_currency_code
                        AP_SYSTEM_PARAMETERS.base_currency_code%TYPE;
     l_hold_future_payments_flag
                        PO_VENDOR_SITES.hold_future_payments_flag%TYPE;

 -- perf bug 5052699 - below sql tuned so as to go to base tables

     cursor invoice_cursor is
         select AI.invoice_amount,
                AI.base_amount,
                AI.invoice_currency_code,
                VS.invoice_amount_limit,
                SP.base_currency_code,
                nvl(VS.hold_future_payments_flag,'N')
         from   ap_invoices_all AI,
                ap_batches_all AB,
                ap_system_parameters_all SP,
                po_vendor_sites VS
         where  AI.invoice_id = X_invoice_id
         and    AI.batch_id = AB.batch_id (+)
         and    AI.vendor_site_id = VS.vendor_site_id
         and    sp.org_id = ai.org_id
         and    sp.set_of_books_id = ai.set_of_books_id;
  BEGIN

     -- Update the calling sequence
     --
     current_calling_sequence :=
               'AP_INVOICES_POST_PROCESS_PKG.create_holds<-'
               ||X_calling_sequence;

     open  invoice_cursor;
     fetch invoice_cursor
     into  l_invoice_amount,
           l_base_amount,
           l_invoice_currency_code,
           l_invoice_amount_limit,
           l_base_currency_code,
           l_hold_future_payments_flag;
     close invoice_cursor;

     -- Insert amount hold if needed
     if (l_invoice_amount_limit is not null) then

       -- Compare the limit with the base_amount if the invoice
       -- is foreign currency or the invoice_amount if the
       -- invoice is base currency.
       if ((l_invoice_currency_code = l_base_currency_code and
            l_invoice_amount > l_invoice_amount_limit) or
           (l_invoice_currency_code <> l_base_currency_code and
            l_base_amount > l_invoice_amount_limit)) then
         --
         -- Allow hold creation if this is
         --   (1) a newly created invoice or
         --   (2) an updated invoice and either the vendor
         --       has changed or the amount or base amount has changed
         --
         if (X_event = 'INSERT' or
             (X_update_base = 'Y' or
              X_vendor_changed_flag = 'Y')) then
           ap_holds_pkg.insert_single_hold(
                X_invoice_id,
                'AMOUNT',
                'INVOICE HOLD REASON',
                '',
                5,
                current_calling_sequence);
         end if;
       else
         -- Release the invoice amount hold if one exists
         ap_holds_pkg.release_single_hold(
                X_invoice_id,
                'AMOUNT',
                'AMOUNT LOWERED',
                5,
                current_calling_sequence);
       end if;
     end if;

     -- Insert vendor hold if needed
     if (l_hold_future_payments_flag = 'Y') then
       --
       -- Allow hold creation if this is
       --   (1) a newly created invoice or
       --   (2) an updated invoice and the vendor has changed
       --
       if (X_event = 'INSERT' or
           X_vendor_changed_flag = 'Y') then

         ap_holds_pkg.insert_single_hold(
              X_invoice_id,
              'VENDOR',
              'INVOICE HOLD REASON',
              '',
              5,
              current_calling_sequence);

       end if;

     else
       -- Release the vendor hold if one exists
       ap_holds_pkg.release_single_hold(
              X_invoice_id,
              'VENDOR',
              'VENDOR UPDATED',
              5,
              current_calling_sequence);
     end if;

     EXCEPTION
       WHEN OTHERS THEN
         IF (SQLCODE <> -20001) THEN
           FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
           FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
           FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                     current_calling_sequence);
           FND_MESSAGE.SET_TOKEN('PARAMETERS',
               'X_invoice_id = '||X_invoice_id
             ||'X_event = '||X_event
             ||'X_update_base = '||X_update_base
             ||'X_vendor_changed_flag = '||X_vendor_changed_flag
                                    );
           FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
         END IF;
       APP_EXCEPTION.RAISE_EXCEPTION;

  END create_holds;


  -----------------------------------------------------------------------
  -- Procedure insert_children
  -- Inserts child records into AP_HOLDS, AP_PAYMENT_SCHEDULES,
  -- and AP_INVOICE_DISTRIBUTIONS
  -- PRECONDITION: Called from PRE-UPDATE, POST-INSERT of INV_SUM_FOLDER
  -----------------------------------------------------------------------
  procedure insert_children (
            X_invoice_id              IN            NUMBER,
            X_Payment_Priority        IN            NUMBER,
            X_Hold_count              IN OUT NOCOPY NUMBER,
            X_Line_count              IN OUT NOCOPY NUMBER,
            X_Line_Total              IN OUT NOCOPY NUMBER,
            X_calling_sequence        IN            VARCHAR2,
            X_Sched_Hold_count        IN OUT NOCOPY NUMBER)  -- bug 5334577

  IS
     current_calling_sequence           VARCHAR2(2000);
     debug_info                         VARCHAR2(1000);
     l_terms_id                         AP_INVOICES.terms_id%TYPE;
     l_created_by                       AP_INVOICES.created_by%TYPE;
     l_Last_Updated_By                  AP_INVOICES.Last_Updated_By%TYPE;
     l_batch_id                         AP_INVOICES.batch_id%TYPE;
     l_terms_date                       AP_INVOICES.terms_date%TYPE;
     l_invoice_amount                   AP_INVOICES.invoice_amount%TYPE;
     l_pay_curr_invoice_amount          AP_INVOICES.invoice_amount%TYPE;
     l_payment_cross_rate               AP_INVOICES.payment_cross_rate%TYPE;
     l_amt_applicable_to_discount
            AP_INVOICES.amount_applicable_to_discount%TYPE;
     l_payment_method_code
            AP_INVOICES.payment_method_code%TYPE;
     l_invoice_currency_code
            AP_INVOICES.invoice_currency_code%TYPE;
     l_payment_currency_code
            AP_INVOICES.payment_currency_code%TYPE;
     l_invoice_type_lookup_code
            AP_INVOICES.invoice_type_lookup_code%TYPE;
     l_batch_hold_lookup_code         AP_BATCHES.hold_lookup_code%TYPE;
     l_batch_hold_reason              AP_BATCHES.hold_reason%TYPE;
     l_vendor_id                      NUMBER;
     l_vendor_site_id                 NUMBER;
     l_invoice_date                   AP_INVOICES.invoice_date%TYPE;
     l_error_code                     VARCHAR2(30);
     l_msg_data                       VARCHAR2(30);
     l_msg_application                VARCHAR2(25);
     l_msg_type                       VARCHAR2(25);
     l_debug_context                  VARCHAR2(2000);
     l_debug_info                     VARCHAR2(1000);

     cursor invoice_cursor is
     select AI.terms_id,
        AI.last_updated_by,
        AI.created_by,
        AI.batch_id,
        AI.terms_date,
        AI.invoice_amount,
        nvl(AI.pay_curr_invoice_amount, invoice_amount),
        AI.payment_cross_rate,
        AI.amount_applicable_to_discount,
        AI.payment_method_code,
        AI.invoice_currency_code,
        AI.payment_currency_code,
        AI.invoice_type_lookup_code,
        AI.vendor_id,
        AI.vendor_site_id,
        AB.hold_lookup_code,
        AB.hold_reason,
        AI.invoice_date
     from   ap_invoices AI,
            ap_batches_all AB  --Bug8409056
     where  AI.invoice_id = X_invoice_id
     and    AI.batch_id = AB.batch_id (+);

  BEGIN

     -- Update the calling sequence
     --
     current_calling_sequence :=
               'AP_INVOICES_POST_PROCESS_PKG.insert_children<-'
               ||X_calling_sequence;

     -- Retrieve the values we need from the newly inserted
     -- invoice so we can create the payment schedules
     OPEN  invoice_cursor;
     FETCH invoice_cursor
     INTO  l_terms_id,
           l_last_updated_by,
           l_created_by,
           l_batch_id,
           l_terms_date,
           l_invoice_amount,
           l_pay_curr_invoice_amount,
           l_payment_cross_rate,
           l_amt_applicable_to_discount,
           l_payment_method_code,
           l_invoice_currency_code,
           l_payment_currency_code,
           l_invoice_type_lookup_code,
           l_vendor_id,
           l_vendor_site_id,
           l_batch_hold_lookup_code,
           l_batch_hold_reason,
           l_invoice_date;
     CLOSE invoice_cursor;

     debug_info := 'Create Payment Schedules';

     -- Create the payment schedules
     AP_CREATE_PAY_SCHEDS_PKG.AP_Create_From_Terms(
                X_invoice_id,
                l_terms_id,
                l_last_updated_by,
                l_created_by,
                X_payment_priority,
                l_batch_id,
                l_terms_date,
                l_invoice_amount,
                l_pay_curr_invoice_amount,
                l_payment_cross_rate,
                l_amt_applicable_to_discount,
                l_payment_method_code,
                l_invoice_currency_code,
                l_payment_currency_code,
                current_calling_sequence);

     debug_info := 'Create batch hold';

     -- Insert the batch-level hold if one exists
     if (l_batch_hold_lookup_code is not null) then

       ap_holds_pkg.insert_single_hold(
        X_invoice_id,
        l_batch_hold_lookup_code,
        '',
        l_batch_hold_reason,
        '',
        current_calling_sequence);

     end if;

     -- Get the new Lines and hold counts

     debug_info := 'Select counts and sum of amounts from lines and holds';

     select count(*)
     into   X_Hold_count
     from   ap_holds
     where  invoice_id = X_invoice_id
     and    release_lookup_code is null;

     --bug 5334577
     Select count(*)
     into   X_Sched_Hold_count
     from   ap_payment_schedules_all
     where  invoice_id = X_invoice_id
     and    hold_flag = 'Y';

     select count(*)
     into   X_Line_count
     from   ap_invoice_lines
     where  invoice_id = X_invoice_id;

     select sum(amount)
       into X_Line_total
       from ap_invoice_lines
      where invoice_id = X_invoice_id;

     EXCEPTION
       WHEN OTHERS THEN
         IF (SQLCODE <> -20001) THEN
           FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
           FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
           FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                     current_calling_sequence);
           FND_MESSAGE.SET_TOKEN('PARAMETERS',
           ' X_Invoice_Id = '         ||TO_CHAR(X_invoice_id));
           FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
         END IF;
       APP_EXCEPTION.RAISE_EXCEPTION;

  END insert_children;


  -----------------------------------------------------------------------
  -- Procedure invoice_pre_update
  -- Checks to see if payment schedules should be recalculated.
  -- Performs a liability adjustment on paid or partially paid invoices.
  -- Determines whether match_status_flag's should be reset on all
  --   distributions after the commit has occurred.
  -- PRECONDITION: Called during PRE-UPDATE
  -----------------------------------------------------------------------
procedure invoice_pre_update  (
               X_invoice_id               IN            number,
               X_invoice_amount           IN            number,
               X_payment_status_flag      IN OUT NOCOPY varchar2,
               X_invoice_type_lookup_code IN            varchar2,
               X_last_updated_by          IN            number,
               X_accts_pay_ccid           IN            number,
               X_terms_id                 IN            number,
               X_terms_date               IN            date,
               X_discount_amount          IN            number,
               X_exchange_rate_type       IN            varchar2,
               X_exchange_date            IN            date,
               X_exchange_rate            IN            number,
               X_vendor_id                IN            number,
               X_payment_method_code      IN          varchar2,
               X_message1                 IN OUT NOCOPY varchar2,
               X_message2                 IN OUT NOCOPY varchar2,
               X_reset_match_status       IN OUT NOCOPY varchar2,
               X_vendor_changed_flag      IN OUT NOCOPY varchar2,
               X_recalc_pay_sched         IN OUT NOCOPY varchar2,
               X_liability_adjusted_flag  IN OUT NOCOPY varchar2,
	       X_external_bank_account_id IN		NUMBER,	  --bug 7714053
               X_payment_currency_code	  IN	        VARCHAR2, --Bug9294551
               X_calling_sequence         IN            varchar2,
               X_revalidate_ps            IN OUT NOCOPY varchar2)
  IS
     current_calling_sequence           VARCHAR2(2000);
     debug_info                         VARCHAR2(100);

     l_recouped_amount					NUMBER; --bug8891266

     cursor liability_changed_cursor is
    SELECT 'Y'
    FROM   ap_invoices AI,
           financials_system_parameters FSP
    WHERE  invoice_id = X_invoice_id
    AND    (AI.accts_pay_code_combination_id <> X_accts_pay_ccid OR
                --
                -- The following have been added in order to
        -- completely externalize the tests for match status
        -- reset on the server.  We want to reset the match
        -- status flag if
        -- Encumbrance is not on *AND*
        -- One of the following columns' values has changed
        --
        --   (1) invoice_amount
        --   (2) exchange_rate_type
        --   (3) exchange_date
        --   (4) exchange_rate
        --
        invoice_amount <> X_invoice_amount OR
        nvl(AI.exchange_rate_type,'dummy') <>
            nvl(X_exchange_rate_type,'dummy') OR
        nvl(AI.exchange_date,sysdate-9000) <>
            nvl(X_exchange_date,sysdate-9000) OR
        nvl(AI.exchange_rate,-1) <> nvl(X_exchange_rate,-1))
    AND    FSP.purch_encumbrance_flag <> 'Y';

     cursor vendor_changed_cursor is
    SELECT    'Y'
    FROM     ap_invoices
    WHERE    vendor_id <> X_vendor_id
    AND     invoice_id = X_invoice_id;

    --bug 8891266 added cursor parameter here
    --Bug9294551 : Recalculate payment schedules when payment currency code
    -- changes. Added X_payment_currency_code check to cursor.
     cursor recalc_pay_sched_cursor (l_recoup_amt number) is
        --
        -- Determine whether payment schedules should
        -- be "recalculated"; that is, should we delete the
        -- existing payment schedules and insert new
        -- ones based on certain new invoice values.
        -- Recalculate payment schedules if there are no
    -- recorded payments or discounts (payment_status_flag = 'N')
    -- and at least one of the following invoice values has changed
    --
    --  (1) invoice amount,
    --  (2) terms,
    --  (3) terms date,
    --  (4) payment method (new for 10SC),
    --  (5) amount applicable to discount
    --  (6) payment currency code (Bug9294551)
    SELECT     'Y'
      FROM     ap_invoices AI
     WHERE     invoice_id = X_invoice_id
       AND     (AI.invoice_amount <> X_invoice_amount OR
            AI.terms_id <> X_terms_id OR
            AI.terms_date <> X_terms_date OR
            AI.payment_method_code <> X_payment_method_code OR
            AI.payment_currency_code <> X_payment_currency_code OR -- Bug9294551
            AI.amount_applicable_to_discount <> X_discount_amount /*OR	--bug 7714053
	    AI.external_bank_account_id <> X_external_bank_account_id*/) --bug 7714053
	    -- commented above code as part of bug 8208495
    AND     (( X_payment_status_flag = 'N') OR
              (X_payment_status_flag <> 'N' AND (-1*l_recoup_amt) = ai.amount_paid ));

   --bug 8891266 also changed the last condition of Payment status flag

  BEGIN

    -- Update the calling sequence
    --
    current_calling_sequence :=
              'AP_INVOICES_POST_PROCESS_PKG.invoice_pre_update<-'||X_calling_sequence;

    -- Determine whether the vendor has changed
    open vendor_changed_cursor;
    fetch vendor_changed_cursor into X_vendor_changed_flag;
    close vendor_changed_cursor;

    -- If the user has changed the liability account and encumbrance
    -- is off then we must reset the match status flag of unposted
    -- distributions to N
    open liability_changed_cursor;
    fetch liability_changed_cursor into X_reset_match_status;
    close liability_changed_cursor;

    --Bug8891266 obtained the recouped added the check of recouped amount
    -- so that payment schedules are not adjusted , they needs to be recalculated

    l_recouped_amount := AP_MATCHING_UTILS_PKG.Get_Inv_Line_Recouped_Amount
							(P_Invoice_Id     => X_invoice_id,
                             P_Invoice_Line_Number => Null);

    debug_info := 'l_recouped_amount obtained ';

    -- If the invoice is paid or partially paid then we made need
    -- to alter the payment schedules if a liability adjustment
    -- has been made.

    if (X_payment_status_flag <> 'N' AND nvl(l_recouped_amount,0) = 0) then

      AP_PAYMENT_SCHEDULES_PKG.adjust_pay_schedule(
		                 X_invoice_id,
                                 X_invoice_amount,
                                 X_payment_status_flag,
                                 X_invoice_type_lookup_code,
                                 X_last_updated_by,
                                 X_message1,
                                 X_message2,
                                 X_reset_match_status,
                                 X_liability_adjusted_flag,
                                 current_calling_sequence,
				 'APXINWKB',
                                 X_revalidate_ps);
      X_recalc_pay_sched := 'N';
    end if;

    -- Do not need to recalc if all important fields are unchanged

    --Bug8891266 added the l_recouped_amount paramter to cursor
    open recalc_pay_sched_cursor(l_recouped_amount);
    fetch recalc_pay_sched_cursor into X_recalc_pay_sched;
    close recalc_pay_sched_cursor;

     EXCEPTION
       WHEN OTHERS THEN
         IF (SQLCODE <> -20001) THEN
           FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
           FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
           FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                     current_calling_sequence);
           FND_MESSAGE.SET_TOKEN('PARAMETERS',
               'X_invoice_id = '||X_invoice_id
           ||', X_invoice_amount = '||X_invoice_amount
           ||', X_payment_status_flag = '||X_payment_status_flag
           ||', X_invoice_type_lookup_code  = '||X_invoice_type_lookup_code
           ||', X_last_updated_by = '   ||X_last_updated_by
           ||', X_accts_pay_ccid = '    ||X_accts_pay_ccid
           ||', X_terms_id = '          ||X_terms_id
           ||', X_terms_date = '        ||X_terms_date
           ||', X_discount_amount = '   ||X_discount_amount
           ||', X_message1 = '          ||X_message1
           ||', X_message2 = '          ||X_message2
           ||', X_reset_match_status = '||X_reset_match_status
           ||', X_recalc_pay_sched = '  ||X_recalc_pay_sched
           ||', X_liability_adjusted_flag = '  ||X_liability_adjusted_flag
                                    );
           FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
         END IF;
       APP_EXCEPTION.RAISE_EXCEPTION;

  END invoice_pre_update;

  -----------------------------------------------------------------------
  -- Procedure invoice_post_update
  --   o Applies/releases invoice limit and vendor holds
  --   o Recalculates payment schedules if necessary
  -- PRECONDITION: Called during POST-UPDATE
  -----------------------------------------------------------------------
  procedure invoice_post_update (
               X_invoice_id          IN number,
               X_payment_priority    IN number,
               X_recalc_pay_sched    IN OUT NOCOPY varchar2,
               X_Hold_count          IN OUT NOCOPY number,
               X_update_base         IN varchar2,
               X_vendor_changed_flag IN varchar2,
               X_calling_sequence    IN varchar2,
               X_Sched_Hold_count    IN OUT NOCOPY number) -- bug 5334577
  IS
     current_calling_sequence           VARCHAR2(2000);
     debug_info                         VARCHAR2(100);
     l_terms_id                         AP_INVOICES.terms_id%TYPE;
     l_created_by                       AP_INVOICES.created_by%TYPE;
     l_Last_Updated_By                  AP_INVOICES.Last_Updated_By%TYPE;
     l_batch_id                         AP_INVOICES.batch_id%TYPE;
     l_terms_date                       AP_INVOICES.terms_date%TYPE;
     l_invoice_amount                   AP_INVOICES.invoice_amount%TYPE;
     l_pay_curr_invoice_amount          AP_INVOICES.invoice_amount%TYPE;
     l_payment_cross_rate               AP_INVOICES.payment_cross_rate%TYPE;
     l_amt_applicable_to_discount
                        AP_INVOICES.amount_applicable_to_discount%TYPE;
     l_payment_method_code
                        AP_INVOICES.payment_method_code%TYPE;
     l_invoice_currency_code
                        AP_INVOICES.invoice_currency_code%TYPE;
     l_payment_currency_code
                        AP_INVOICES.payment_currency_code%TYPE;

     -- bug 2663549 variables declared
    l_awt_amount                        NUMBER;
    l_inv_amt_remaining                 NUMBER;
    l_gross_amount                      NUMBER;
    -- end bug 2663549

    --Bug8891266

    l_recouped_amount				NUMBER;
    l_po_number					VARCHAR2(1000);

     cursor invoice_cursor is
         select AI.terms_id,
                AI.last_updated_by,
                AI.created_by,
                AI.batch_id,
                AI.terms_date,
                AI.invoice_amount,
                nvl(AI.pay_curr_invoice_amount, AI.invoice_amount),
                AI.payment_cross_rate,
                AI.amount_applicable_to_discount,
                AI.payment_method_code,
                AI.invoice_currency_code,
                AI.payment_currency_code
         from   ap_invoices AI
         where  AI.invoice_id = X_invoice_id;

  BEGIN

    -- Update the calling sequence
    --
    current_calling_sequence :=
              'AP_INVOICES_POST_PROCESS_PKG.invoice_post_update<-'
              ||X_calling_sequence;

    -- Retrieve the values we need from the recently updated
    -- invoice so we can create the payment schedules
    open invoice_cursor;
    fetch invoice_cursor into
               l_terms_id,
               l_last_updated_by,
               l_created_by,
               l_batch_id,
               l_terms_date,
               l_invoice_amount,
               l_pay_curr_invoice_amount,
               l_payment_cross_rate,
               l_amt_applicable_to_discount,
               l_payment_method_code,
               l_invoice_currency_code,
               l_payment_currency_code;
    close invoice_cursor;

    -- Get the new Distribution and hold counts

    debug_info := 'Select count from AP_HOLDS';

    select count(*)
    into   X_Hold_count
    from   ap_holds
    where  invoice_id = X_invoice_id
    and    release_lookup_code is null;

    debug_info := 'Recalculate Payment Schedules: '||X_recalc_pay_sched;

    if (X_recalc_pay_sched = 'Y') then
      -- Create the payment schedules
      AP_CREATE_PAY_SCHEDS_PKG.AP_Create_From_Terms(
                X_invoice_id,
                l_terms_id,
                l_last_updated_by,
                l_created_by,
                X_payment_priority,
                l_batch_id,
                l_terms_date,
                l_invoice_amount,
                l_pay_curr_invoice_amount,
                l_payment_cross_rate,
                l_amt_applicable_to_discount,
                l_payment_method_code,
                l_invoice_currency_code,
                l_payment_currency_code,
        current_calling_sequence);

      -- bug 2663549 amount_remaining should be adjusted for AWT amount
      -- after payment_schedule has been recreated.
      SELECT  sum( nvl(amount, 0) )
      INTO   l_awt_amount
      FROM   ap_invoice_lines -- bug 9255550
      WHERE  invoice_id = X_invoice_id
      AND    line_type_lookup_code = 'AWT';

      SELECT sum(nvl(amount_remaining,0)), sum(nvl(gross_amount,0))
      INTO l_inv_amt_remaining, l_gross_amount
      FROM ap_payment_schedules
      WHERE invoice_id = X_invoice_id;

       --bug 5334577
      Select count(*)
      into   X_Sched_Hold_count
      from   ap_payment_schedules_all
      where  invoice_id = X_invoice_id
      and    hold_flag = 'Y';

      debug_info := ' Total Awt Amount: '||l_awt_amount||', '||'Invoice Amount Remaining: '||
                      l_inv_amt_remaining||', '||'Gross Amount: '||l_gross_amount;

      --===================================================================
      --Prorate the manual AWT against the invoice amount remaining
      --===================================================================
      if ((l_inv_amt_remaining <> 0) and (l_awt_amount is not null)) then

         UPDATE ap_payment_schedules
         SET amount_remaining = (amount_remaining +
               ap_utilities_pkg.ap_round_currency(
                 (amount_remaining * (l_awt_amount/l_inv_amt_remaining)
                    * l_payment_cross_rate), l_payment_currency_code ) )
         WHERE invoice_id = X_invoice_id;
      elsif ((l_inv_amt_remaining = 0) and (l_awt_amount is not null)
              and (l_gross_amount <> 0)) then  /* Bug 5382525 */

         UPDATE ap_payment_schedules
         SET amount_remaining = (amount_remaining +
               ap_utilities_pkg.ap_round_currency(
                 (gross_amount * (l_awt_amount/l_gross_amount)
                    * l_payment_cross_rate), l_payment_currency_code) ),
             payment_status_flag = DECODE(payment_status_flag,
                                   'Y','P',payment_status_flag)
         WHERE invoice_id = X_invoice_id;

         UPDATE ap_invoices
         SET payment_status_flag = DECODE(payment_status_flag,
                                    'Y','P',payment_status_flag)
         WHERE invoice_id = X_invoice_id;
      end if;
      -- end bug 2663549

      --Bug8891266
	l_recouped_amount := AP_MATCHING_UTILS_PKG.Get_Inv_Line_Recouped_Amount
						(P_Invoice_Id     => X_invoice_id,
                     P_Invoice_Line_Number => Null);
	l_po_number := AP_INVOICES_UTILITY_PKG.get_po_number(X_invoice_id);


	debug_info := ' l_recouped_amount : '|| l_recouped_amount ||', '||'l_po_number: '||
              l_po_number ;

	if( l_po_number <> 'UNMATCHED' ) then
		if( nvl(l_recouped_amount,0) <> 0) THEN
			UPDATE ap_payment_schedules
			SET amount_remaining = (amount_remaining +
						ap_utilities_pkg.ap_round_currency(l_recouped_amount,
						                           l_payment_currency_code) ),
			payment_status_flag = DECODE(amount_remaining +
                                                     ap_utilities_pkg.ap_round_currency( l_recouped_amount,
                                                                                   l_payment_currency_code),
                                                     0,'Y',
                                                     gross_amount, 'N',
                                                     'P')
			WHERE invoice_id = X_invoice_id;


		end if;

	end if;
    --End of Bug8891266
    end if;

     EXCEPTION
       WHEN OTHERS THEN
         IF (SQLCODE <> -20001) THEN
           FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
           FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
           FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                     current_calling_sequence);
           FND_MESSAGE.SET_TOKEN('PARAMETERS',
               'X_invoice_id = '      ||X_invoice_id
           ||', X_payment_priority = '||X_payment_priority
           ||', X_recalc_pay_sched = '||X_recalc_pay_sched
           ||', X_Hold_count = '      ||X_Hold_count
                                    );
           FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
         END IF;
       APP_EXCEPTION.RAISE_EXCEPTION;

  END invoice_post_update;

  --Invoice Lines: Distributions, modified the procedure
  -----------------------------------------------------------------------
  -- Procedure post_forms_commit
  --   o Calls distribution procedure which resets match status,
  --     recalculates base, 1099 info, etc.
  --   o Determines new invoice-level statuses
  -- PRECONDITION: Called during POST-FORMS-COMMIT
  -----------------------------------------------------------------------
  procedure post_forms_commit
                (X_invoice_id                   IN            number,
		 X_Line_Number		        IN	      number,
                 X_type_1099                    IN            varchar2,
                 X_income_tax_region            IN            varchar2,
                 X_vendor_changed_flag          IN OUT NOCOPY varchar2,
                 X_update_base                  IN OUT NOCOPY varchar2,
                 X_reset_match_status           IN OUT NOCOPY varchar2,
                 X_update_occurred              IN OUT NOCOPY varchar2,
                 X_approval_status_lookup_code  IN OUT NOCOPY varchar2,
                 X_holds_count                  IN OUT NOCOPY number,
                 X_posting_flag                 IN OUT NOCOPY varchar2,
                 X_amount_paid                  IN OUT NOCOPY number,
		 X_highest_line_num		IN OUT NOCOPY number,
                 X_line_total	                IN OUT NOCOPY number,
                 X_actual_invoice_count         IN OUT NOCOPY number,
                 X_actual_invoice_total         IN OUT NOCOPY number,
                 X_calling_sequence             IN varchar2,
                 X_sched_holds_count            IN OUT NOCOPY number)   -- bug 5334577


  IS

     current_calling_sequence           VARCHAR2(2000);
     debug_info                         VARCHAR2(100);

     CURSOR invoice_status_cursor is
       select
        AP_INVOICES_PKG.GET_APPROVAL_STATUS(
                     AI.INVOICE_ID,
                     AI.INVOICE_AMOUNT,
                     AI.PAYMENT_STATUS_FLAG,
                     AI.INVOICE_TYPE_LOOKUP_CODE),
        AP_INVOICES_PKG.GET_HOLDS_COUNT(
                     AI.INVOICE_ID),
        AP_INVOICES_PKG.GET_SCHED_HOLDS_COUNT(     --bug 5334577
                     AI.INVOICE_ID),
        AP_INVOICES_PKG.GET_POSTING_STATUS(
                     AI.INVOICE_ID),
        AI.AMOUNT_PAID,
        AP_INVOICES_PKG.GET_MAX_LINE_NUMBER(
			  AI.INVOICE_ID) + 1,
        AP_INVOICES_UTILITY_PKG.GET_LINE_TOTAL(
                          AI.INVOICE_ID),
        decode(AB.BATCH_ID,
            '',null,
               AP_BATCHES_PKG.GET_ACTUAL_INV_COUNT(
                               AB.BATCH_ID)),
        decode(AB.BATCH_ID,
                        '',null,
                      AP_BATCHES_PKG.GET_ACTUAL_INV_AMOUNT(
                                AB.BATCH_ID))
        from   ap_invoices AI,
               ap_batches_all AB    --Bug: 6668692 : Added _all to table name
        where  AI.invoice_id = X_invoice_id
        and    AI.batch_id = AB.batch_id (+);
  BEGIN

    -- Update the calling sequence
    --
    current_calling_sequence :=
              'AP_INVOICES_POST_PROCESS_PKG.post_forms_commit<-'||X_calling_sequence;

    -- Update the invoice distributions if necessary
    --
    if (nvl(X_update_base,'N') = 'Y' or
        nvl(X_reset_match_status,'N') = 'Y') then

      ap_invoice_distributions_pkg.update_distributions
                (X_invoice_id,
                 X_line_number,
                 X_type_1099,
                 X_income_tax_region,
                 X_vendor_changed_flag,
                 X_update_base,
                 X_reset_match_status,
                 X_update_occurred,
                 current_calling_sequence);

    end if;

    -- Determine the current invoice statuses
    --

    debug_info := 'Select invoice statuses from AP_INVOICES';

    open invoice_status_cursor;
    fetch invoice_status_cursor into X_approval_status_lookup_code,
                        X_holds_count,
                        X_sched_holds_count,  --bug 5334577
                        X_posting_flag,
                        X_amount_paid,
                        X_highest_line_num,
                        X_line_total,
                        X_actual_invoice_count,
                        X_actual_invoice_total;
    close invoice_status_cursor;

     EXCEPTION
       WHEN OTHERS THEN
         IF (SQLCODE <> -20001) THEN
           FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
           FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
           FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                     current_calling_sequence);
           FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'X_invoice_id = '                 ||X_invoice_id
              ||', X_type_1099 = '                  ||X_type_1099
              ||', X_income_tax_region = '          ||X_income_tax_region
              ||', X_vendor_changed_flag = '        ||X_vendor_changed_flag
              ||', X_update_base = '                ||X_update_base
              ||', X_reset_match_status = '         ||X_reset_match_status
              ||', X_update_occurred = '            ||X_update_occurred
              ||', X_approval_status_lookup_code = '||
                X_approval_status_lookup_code
              ||', X_holds_count = '           ||X_holds_count
              ||', X_posting_flag = '          ||X_posting_flag
              ||', X_amount_paid = '           ||X_amount_paid
              ||', X_highest_line_num  = '     ||X_highest_line_num
              ||', X_actual_invoice_count = '  ||X_actual_invoice_count
              ||', X_actual_invoice_total = '  ||X_actual_invoice_total
              ||', X_line_total         = '    ||X_Line_total );
           FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
         END IF;
       APP_EXCEPTION.RAISE_EXCEPTION;

  END post_forms_commit;

     -----------------------------------------------------------------------
     -- Procedure Select_Summary calculates the initial value for the
     -- batch (actual) total
     --
     -----------------------------------------------------------------------
     PROCEDURE Select_Summary(X_Batch_ID         IN            NUMBER,
                              X_Total            IN OUT NOCOPY NUMBER,
                              X_Total_Rtot_DB    IN OUT NOCOPY NUMBER,
                              X_Calling_Sequence IN            VARCHAR2)
     IS
       current_calling_sequence  VARCHAR2(2000);
       debug_info                VARCHAR2(100);
     BEGIN

        -- Update the calling sequence
        --
        current_calling_sequence :=
           'AP_INVOICES_POST_PROCESS_PKG.Select_Summary<-'||X_Calling_Sequence;

        debug_info := 'Select from AP_INVOICES';

        select sum(nvl(invoice_amount,0))
        into   X_Total
        from   ap_invoices
        where  Batch_ID = X_Batch_ID;

        X_Total_Rtot_DB := X_Total;

     EXCEPTION
       WHEN OTHERS THEN
         if (SQLCODE <> -20001) then
           FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
           FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
           FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
           FND_MESSAGE.SET_TOKEN('PARAMETERS','Batch Id = '||X_Batch_ID
                                          ||',Total = '||X_Total
                                          ||',Total RTOT DB = '||
                                              X_Total_Rtot_DB);
           FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
         end if;
         APP_EXCEPTION.RAISE_EXCEPTION;
     END Select_Summary;

END AP_INVOICES_POST_PROCESS_PKG;

/
