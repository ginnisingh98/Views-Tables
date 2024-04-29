--------------------------------------------------------
--  DDL for Package Body AP_PAY_IN_FULL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_PAY_IN_FULL_PKG" AS
/* $Header: apayfulb.pls 120.19.12010000.16 2010/04/02 06:54:51 serabell ship $ */

  ---------------------------------------------------------------------
  -- Procedure AP_Lock_Invoices parses the P_invoice_id_list and locks all
  -- the invoices in the list.  This procedure also returns information
  -- needed by the Single Payment workbench to pay these invoices in full.
  --

G_CURRENT_RUNTIME_LEVEL     NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR      CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION  CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT      CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE  CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT  CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME      CONSTANT VARCHAR2(50) :='AP.PLSQL.AP_ACCOUNTING_EVENT_PKG.';

   --Modified below procedure parameter types for bug #7721348/7758448
  PROCEDURE AP_Lock_Invoices(
	   P_invoice_id_list     IN  VARCHAR2,
           P_payment_num_list    IN  VARCHAR2,
           P_currency_code       OUT NOCOPY VARCHAR2,
           P_payment_method      OUT NOCOPY AP_PAYMENT_SCHEDULES.PAYMENT_METHOD_CODE%TYPE,  --VARCHAR2,
           P_vendor_id           OUT NOCOPY AP_SUPPLIERS.VENDOR_ID%TYPE,             --NUMBER,
           P_vendor_site_id      OUT NOCOPY AP_SUPPLIER_SITES.VENDOR_SITE_ID%TYPE,   --NUMBER,
           P_party_id            OUT NOCOPY AP_SUPPLIERS.PARTY_ID%TYPE,              --NUMBER,
           P_party_site_id       OUT NOCOPY AP_SUPPLIER_SITES.PARTY_SITE_ID%TYPE,    --NUMBER,
           P_org_id              OUT NOCOPY NUMBER,
           P_payment_function    OUT NOCOPY AP_INVOICES.PAYMENT_FUNCTION%TYPE,          --VARCHAR2, -- 4965233
           P_proc_trxn_type      OUT NOCOPY AP_INVOICES.PAY_PROC_TRXN_TYPE_CODE%TYPE,   --VARCHAR2, -- 4965233
           P_num_payments        OUT NOCOPY NUMBER,
           P_le_id               OUT NOCOPY NUMBER,   -- 5617689
	    --Added below variables for the bug 7662240
	   P_remit_vendor_id        OUT NOCOPY AP_SUPPLIERS.VENDOR_ID%TYPE,            --NUMBER,
           P_remit_vendor_site_id   OUT NOCOPY AP_SUPPLIER_SITES.VENDOR_SITE_ID%TYPE,   --NUMBER,
           P_remit_party_id         OUT NOCOPY AP_SUPPLIERS.PARTY_ID%TYPE,              --NUMBER,
           P_remit_party_site_id    OUT NOCOPY AP_SUPPLIER_SITES.PARTY_SITE_ID%TYPE,    --NUMBER,
           P_remit_vendor_name      OUT NOCOPY AP_SUPPLIERS.VENDOR_NAME%TYPE,           --VARCHAR2,
           P_remit_vendor_site_name OUT NOCOPY AP_SUPPLIER_SITES.VENDOR_SITE_CODE%TYPE, --VARCHAR2,
           P_calling_sequence       IN  VARCHAR2,
	   --Added below parameter for 7688200
	   p_relationship_id	OUT NOCOPY NUMBER)
IS
    l_invoice_id    NUMBER;
    l_inv_pos     NUMBER;
    l_inv_next      NUMBER;
    l_pay_pos     NUMBER;
    l_pay_next      NUMBER;
    l_num_payments    NUMBER := 0;
    l_payment_num   NUMBER;
    l_log_msg    VARCHAR2(240);
    l_curr_calling_sequence VARCHAR2(2000);

    -- Bug 8209483
    l_result varchar2(1) := FND_API.G_TRUE;
    -- Bug 8209483

  BEGIN
    l_curr_calling_sequence := 'AP_PAY_IN_FULL_PKG.AP_LOCK_INVOICES<-' ||
             P_calling_sequence;

    -- Parse P_invoice_id_list and lock invoices
    --
    l_inv_pos := 1;

    LOOP
      l_inv_next := INSTR(P_invoice_id_list, ' ', l_inv_pos);
      IF (l_inv_next = 0) THEN
        l_inv_next := LENGTH(P_invoice_id_list) + 1;
      END IF;

      l_invoice_id := TO_NUMBER(SUBSTR(P_invoice_id_list,
                                       l_inv_pos,
               l_inv_next - l_inv_pos));

      l_log_msg := 'Locking invoice_id:' || to_char(l_invoice_id);
      AP_INVOICES_PKG.LOCK_ROW(l_invoice_id,
             l_curr_calling_sequence);

      -- Determine the number of payments for this invoice
      --
      IF (P_payment_num_list IS NULL) THEN

  l_log_msg := 'Get number of payments for invoice_id:' ||
      to_char(l_invoice_id);

        SELECT count(*) + l_num_payments
        INTO   l_num_payments
        FROM   ap_invoices_ready_to_pay_v
        WHERE  invoice_id = l_invoice_id;

      ELSE
        -- Parse and count P_payment_num_list
        --
  l_pay_pos := 1;

        LOOP
    l_pay_next := INSTR(P_payment_num_list, ' ', l_pay_pos);
    IF (l_pay_next = 0) THEN
      l_pay_next := LENGTH(P_payment_num_list) + 1;
    END IF;

    l_num_payments := l_num_payments + 1;

    EXIT WHEN (l_pay_next = LENGTH(P_payment_num_list) + 1);
    l_pay_pos := l_pay_next + 1;

        END LOOP;

      END IF;

      EXIT WHEN (l_inv_next > LENGTH(P_invoice_id_list));
      l_inv_pos := l_inv_next + 1;

    END LOOP;

    l_log_msg := 'Get vendor and currency info for invoice_id:' ||
        to_char(l_invoice_id);



    -- Perf bugfix 5052493
    -- Go to base table AP_INVOICES_ALL to reduce shared memory usage
    SELECT a.payment_currency_code,
     b.payment_method_code, --4552701
     a.vendor_id,
     a.vendor_site_id,
     a.party_id,
     a.party_site_id,
     a.org_id,
     l_num_payments,
     a.payment_function,
     a.pay_proc_trxn_type_code,
     a.legal_entity_id,
     /* commented as part of bug 7688200
     ,         -- Bug 5617689 */--Bug 7860631 Uncommented the commeted code.
     b.remit_to_supplier_id,    --Bug 7662240
     b.remit_to_supplier_site_id,
     b.remit_to_supplier_name,
     b.remit_to_supplier_site,
     b.relationship_id
    INTO   P_currency_code,
     P_payment_method,
     P_vendor_id,
     P_vendor_site_id,
     P_party_id,
     P_party_site_id,
     P_org_id,
     P_num_payments,
     P_payment_function,
     P_proc_trxn_type,
     p_le_id,
     /* commented as part of bug 7688200
     ,                -- Bug 5617689 */--Bug 7860631 Uncommented the commented code.
     P_remit_vendor_id,      -- Bug 7662240
     P_remit_vendor_site_id,
     p_remit_vendor_name,
     p_remit_vendor_site_name,
     p_relationship_id
     FROM    ap_invoices_all a, ap_payment_schedules_all b  --Bug 7662240
     WHERE  a.invoice_id = l_invoice_id
      and    a.invoice_id = b.invoice_id
      and    rownum<2;

    /* Need to get payment method if paying from the payment schedule level */
    If  (P_Payment_num_list IS NOT NULL) then
      -- get the first payment num.
      l_pay_next := INSTR(P_payment_num_list,' ',1);
      If l_pay_next = 0 then
       l_pay_next := length(p_payment_num_list) +1;
      End if;
      l_payment_num := to_number(substr(p_payment_num_list,1,l_pay_next));

      --7662240 Added all remit related variables in below select statement
      SELECT payment_method_code,
      /* commented as part of bug 7688200
	     ,      --4552701  */--Bug 7860631 Uncommented the commeted code.
             remit_to_supplier_id,     --7662240
             remit_to_supplier_site_id,
             remit_to_supplier_name,
             remit_to_supplier_site,
             relationship_id
      INTO   p_payment_method,
      /*  commented as part of bug 7688200
	     ,*/--Bug 7860631 Uncommented the commented code.
             P_remit_vendor_id,      -- Bug 7662240
             P_remit_vendor_site_id,
             p_remit_vendor_name,
             p_remit_vendor_site_name,
             p_relationship_id
      FROM   ap_payment_schedules
      WHERE  invoice_id = l_invoice_id
      and    payment_num = l_payment_num;
     End if;

     /* Bug 7860631 Added If condition to avoid the call to IBY and the query Payment request type invoices */
     If (p_remit_vendor_id > 0 and p_remit_vendor_site_id > 0) then
      --Begin 7662240
      -- modified as part of bug 7688200. start

      -- modified as part of bug 8209483. start
      SELECT APS.party_id
      INTO p_remit_party_id
      FROM AP_SUPPLIERS APS
      WHERE APS.vendor_id = p_remit_vendor_id;

      IBY_EXT_PAYEE_RELSHIPS_PKG.import_Ext_Payee_Relationship(
	   p_party_id => p_party_id,
	   p_supplier_site_id => p_vendor_site_id,
	   p_date => sysdate,
	   x_result  => l_result,
	   x_remit_party_id => p_remit_party_id,
	   x_remit_supplier_site_id => p_remit_vendor_site_id,
	   x_relationship_id	=> p_relationship_id
      );

       IF (l_result = FND_API.G_FALSE) THEN

        IBY_EXT_PAYEE_RELSHIPS_PKG.default_Ext_Payee_Relationship(
	   p_party_id => p_party_id,
	   p_supplier_site_id => P_vendor_site_id,
	   p_date => sysdate,
	   x_remit_party_id => p_remit_party_id,
	   x_remit_supplier_site_id => P_remit_vendor_site_id,
	   x_relationship_id => p_relationship_id
        );

       End if;
       -- modified as part of bug 8209483. end

       --bug 8345877 if no relationship exists as on current date
       --then need to null out all remit-to columns

       IF p_relationship_id = -1 then --bug 8345877

          P_remit_vendor_id        := NULL;
	  P_remit_vendor_site_id   := NULL;
	  P_remit_party_id         := NULL;
	  P_remit_party_site_id    := NULL;
	  P_remit_vendor_name      := NULL;
	  P_remit_vendor_site_name := NULL;
	  p_relationship_id        := NULL;

       ELSE --bug 8345877
          SELECT APS.vendor_id,
	         APS.vendor_name,
		 APSS.party_site_id,
		 APSS.vendor_site_code
          INTO p_remit_vendor_id,
	       p_remit_vendor_name,
	       p_remit_party_site_id,
	       p_remit_vendor_site_name
       FROM AP_SUPPLIERS APS,  AP_SUPPLIER_SITES APSS
       WHERE APS.party_id = p_remit_party_id
             AND APS.vendor_id =APSS.vendor_id
             AND APSS.vendor_site_id = p_remit_vendor_site_id;

       END IF; --bug 8345877
       -- modified as part of bug 7688200. end
       --End 7662240
     -- 7860631. To handle payment request type invoices
     ELSIF (p_remit_party_id is null AND
		p_remit_party_site_id is null AND
		(p_remit_vendor_id = p_vendor_id) AND
		(p_remit_vendor_site_id = p_vendor_site_id) ) THEN

	   SELECT party_id, party_site_id
	   INTO p_remit_party_id, p_remit_party_site_id
	   FROM ap_invoices_all
	   WHERE invoice_id = l_invoice_id;

     end if; --7860631

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
            ' P_invoice_id_list = ' || P_invoice_id_list);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_log_msg);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END AP_Lock_Invoices;


  ---------------------------------------------------------------------
  -- Function AP_Discount_Available determines whether or not discounts
  -- are available for the invoices in P_invoice_id_list
  --
  FUNCTION AP_Discount_Available(P_invoice_id_list   IN  VARCHAR2,
               P_payment_num_list  IN  VARCHAR2,
               P_check_date        IN  DATE,
               P_currency_code     IN  VARCHAR2,
               P_calling_sequence  IN  VARCHAR2)
    RETURN BOOLEAN
  IS
    l_invoice_id    NUMBER;
    l_payment_num   NUMBER;
    l_pos     NUMBER;
    l_next      NUMBER;
    l_discount_available  NUMBER := 0;
    l_log_msg    VARCHAR2(240);
    l_curr_calling_sequence VARCHAR2(2000);
  BEGIN
    l_curr_calling_sequence := 'AP_PAY_IN_FULL_PKG.AP_DISCOUNT_AVAILABLE<-' ||
             P_calling_sequence;
    l_pos := 1;

    IF (P_payment_num_list IS NOT NULL) THEN

      l_invoice_id := TO_NUMBER(P_invoice_id_list);
      --
      -- Parse P_payment_num_list
      --
      LOOP
        l_next := INSTR(P_payment_num_list, ' ', l_pos);
        IF (l_next = 0) THEN
          l_next := LENGTH(P_payment_num_list) + 1;
        END IF;

        l_payment_num := TO_NUMBER(SUBSTR(P_payment_num_list,
                                          l_pos,
                  l_next - l_pos));

  l_log_msg := 'Get discount available for invoice_id:' ||
      to_char(l_invoice_id) || ' payment_num:' ||
      to_char(l_payment_num);

  SELECT ap_payment_schedules_pkg.get_discount_available(
       invoice_id,
       payment_num,
       P_check_date,
       P_currency_code)
  INTO   l_discount_available
  FROM   ap_invoices_ready_to_pay_v
        WHERE  invoice_id = l_invoice_id
  AND    payment_num = l_payment_num;

        EXIT WHEN (l_discount_available > 0 OR
       l_next > LENGTH(P_payment_num_list));
        l_pos := l_next + 1;

      END LOOP;

    ELSIF (P_invoice_id_list IS NOT NULL) THEN
      --
      -- Parse P_invoice_id_list
      --
      LOOP
        l_next := INSTR(P_invoice_id_list, ' ', l_pos);
        IF (l_next = 0) THEN
          l_next := LENGTH(P_invoice_id_list) + 1;
        END IF;

        l_invoice_id := TO_NUMBER(SUBSTR(P_invoice_id_list,
                                       l_pos,
               l_next - l_pos));

  l_log_msg := 'Get discount available for invoice_id:' ||
      to_char(l_invoice_id);

  SELECT SUM(ap_payment_schedules_pkg.get_discount_available(
      invoice_id,
      payment_num,
      P_check_date,
      P_currency_code))
  INTO   l_discount_available
  FROM   ap_invoices_ready_to_pay_v
        WHERE  invoice_id = l_invoice_id;

        EXIT WHEN (l_discount_available > 0 OR
       l_next > LENGTH(P_invoice_id_list));
        l_pos := l_next + 1;

      END LOOP;

    END IF;

    -- Fix for 962271. For refunds the l_discount_available would be negative,
    -- so the following if condition should be: IF(l_discount_available <> 0) (instead of > 0)
    -- since it can be positive or negative depending upon the payment.
    --
    IF (l_discount_available <> 0) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
            ' P_invoice_id_list = '  ||P_invoice_id_list ||
            ' P_payment_num_list = ' ||P_payment_num_list ||
            ' P_check_date = '       ||P_check_date ||
            ' P_currency_code = '    ||P_currency_code);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_log_msg);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END AP_Discount_Available;

  ---------------------------------------------------------------------
  -- Function Get_Single_Payment_Amount is called by Get_Check_Amount
  -- to compute the amount of a single payment
  --
  FUNCTION Get_Single_Payment_Amount(P_invoice_id             IN  NUMBER,
             P_payment_num        IN  NUMBER,
                 P_payment_type_flag      IN  VARCHAR2,
                 P_check_date             IN  DATE,
                 P_currency_code          IN  VARCHAR2,
                 P_take_discount          IN  VARCHAR2,
                 P_sys_auto_calc_int_flag IN  VARCHAR2,
                 P_auto_calc_int_flag     IN  VARCHAR2,
                 P_calling_sequence       IN  VARCHAR2)
    RETURN NUMBER
  IS
    l_payment_num   NUMBER;
    l_total_amount    NUMBER := 0;
    l_amount_remaining    NUMBER;
    l_discount_available  NUMBER;
    l_discount_taken    NUMBER;
    l_interest_amount   NUMBER;
    l_payment_amount            NUMBER;
    l_due_date      DATE;
    l_interest_invoice_num  VARCHAR2(50);
    l_log_msg    VARCHAR2(240);
    l_curr_calling_sequence VARCHAR2(2000);

    -------------------------------------------------------------------
    -- Declare cursor to compute single payment amount
    --
    CURSOR payments_cursor IS
    SELECT payment_num,
     amount_remaining,
     ap_payment_schedules_pkg.get_discount_available(
       invoice_id,
       payment_num,
       P_check_date,
       P_currency_code)
    FROM   ap_invoices_ready_to_pay_v
    WHERE  invoice_id = P_invoice_id
    AND    payment_num = nvl(P_payment_num, payment_num);

  BEGIN
    l_curr_calling_sequence := 'AP_PAY_IN_FULL_PKG.GET_SINGLE_PAYMENT_AMOUNT<-' ||
             P_calling_sequence;

    l_log_msg := 'Open payments_cursor';
    OPEN payments_cursor;

    LOOP
      l_log_msg := 'Fetch payments_cursor';
      FETCH payments_cursor
      INTO  l_payment_num,
      l_amount_remaining,
      l_discount_available;

      EXIT WHEN payments_cursor%NOTFOUND;

      -- For pay-in-full payment amount = amount remaining

      l_payment_amount := l_amount_remaining;
      --
      -- Calculate discount taken
      --
      IF (P_take_discount = 'Y') THEN
        l_discount_taken := l_discount_available;
      ELSE
        l_discount_taken := 0;
      END IF;

      --
      -- Calculate interest invoice amount
      --
      IF ((P_payment_type_flag = 'Q')
         AND (P_auto_calc_int_flag = 'Y')) THEN --Bug 2119368: AND condition added
  l_log_msg := 'Calulate interest invoice amount for invoice_id:' ||
      to_char(P_invoice_id) || ' payment_num:' ||
      to_char(l_payment_num);
        AP_INTEREST_INVOICE_PKG.AP_CALCULATE_INTEREST(
                  P_invoice_id,
                  P_sys_auto_calc_int_flag,
                  P_auto_calc_int_flag,
                  P_check_date,
                  l_payment_num,
                  l_amount_remaining,
                  l_discount_taken,
                  l_discount_available,
                  P_currency_code,
                  l_interest_amount,
                  l_due_date,
                  l_interest_invoice_num,
                  l_payment_amount,
                  l_curr_calling_sequence);
      ELSE
        l_interest_amount := 0;
      END IF;

      --
      -- Calculate total amount
      --
      l_total_amount := l_total_amount + l_amount_remaining
               + l_interest_amount
               - l_discount_taken;
    END LOOP;

    l_log_msg := 'Close payments_cursor';
    CLOSE payments_cursor;

    RETURN l_total_amount;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
    ' P_invoice_id = '            || P_invoice_id ||
    ' P_payment_num = '           || P_payment_num ||
    ' P_payment_type_flag = '     || P_payment_type_flag ||
    ' P_check_date = '            || P_check_date ||
    ' P_currency_code = '         || P_currency_code ||
    ' P_take_discount = '         || P_take_discount ||
    ' P_sys_auto_calc_int_flag = '|| P_sys_auto_calc_int_flag ||
    ' P_auto_calc_int_flag = '    || P_auto_calc_int_flag);
         FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_log_msg);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Get_Single_Payment_Amount;


  ---------------------------------------------------------------------
  -- Function AP_Get_Check_Amount computes the total check amount including
  -- discount and interest amounts (if applicable) for the invoices in
  -- P_invoice_id_list
  --
  FUNCTION AP_Get_Check_Amount(P_invoice_id_list  IN  VARCHAR2,
             P_payment_num_list       IN  VARCHAR2,
             P_payment_type_flag      IN  VARCHAR2,
             P_check_date             IN  DATE,
             P_currency_code          IN  VARCHAR2,
             P_take_discount          IN  VARCHAR2,
             P_sys_auto_calc_int_flag IN  VARCHAR2,
             P_auto_calc_int_flag     IN  VARCHAR2,
             P_calling_sequence       IN  VARCHAR2)
    RETURN NUMBER
  IS
    l_invoice_id    NUMBER;
    l_payment_num   NUMBER;
    l_pos     NUMBER;
    l_next      NUMBER;
    l_total_check_amount  NUMBER := 0;
    l_log_msg    VARCHAR2(240);
    l_curr_calling_sequence VARCHAR2(2000);

  BEGIN
    l_curr_calling_sequence := 'AP_PAY_IN_FULL_PKG.AP_GET_CHECK_AMOUNT<-' ||
             P_calling_sequence;
    l_pos := 1;

    IF (P_payment_num_list IS NOT NULL) THEN

      l_invoice_id := TO_NUMBER(P_invoice_id_list);
      --
      -- Parse P_payment_num_list
      --
      LOOP
        l_next := INSTR(P_payment_num_list, ' ', l_pos);
        IF (l_next = 0) THEN
          l_next := LENGTH(P_payment_num_list) + 1;
        END IF;

        l_payment_num := TO_NUMBER(SUBSTR(P_payment_num_list,
                                          l_pos,
                  l_next - l_pos));

        l_total_check_amount := l_total_check_amount +
          Get_Single_Payment_Amount(
          l_invoice_id,
          l_payment_num,
          P_payment_type_flag,
          P_check_date,
          P_currency_code,
          P_take_discount,
          P_sys_auto_calc_int_flag,
          P_auto_calc_int_flag,
          l_curr_calling_sequence);

        EXIT WHEN (l_next > LENGTH(P_payment_num_list));
        l_pos := l_next + 1;

      END LOOP;

    ELSIF (P_invoice_id_list IS NOT NULL) THEN
      --
      -- Parse P_invoice_id_list
      --
      LOOP
        l_next := INSTR(P_invoice_id_list, ' ', l_pos);
        IF (l_next = 0) THEN
          l_next := LENGTH(P_invoice_id_list) + 1;
        END IF;

        l_invoice_id := TO_NUMBER(SUBSTR(P_invoice_id_list,
                                       l_pos,
               l_next - l_pos));

  l_log_msg := 'Get discount available for invoice_id:' ||
      to_char(l_invoice_id);

        l_total_check_amount := l_total_check_amount +
          Get_Single_Payment_Amount(
          l_invoice_id,
          NULL,
          P_payment_type_flag,
          P_check_date,
          P_currency_code,
          P_take_discount,
          P_sys_auto_calc_int_flag,
          P_auto_calc_int_flag,
          l_curr_calling_sequence);

        EXIT WHEN (l_next > LENGTH(P_invoice_id_list));
        l_pos := l_next + 1;

      END LOOP;

    END IF;

    RETURN l_total_check_amount;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
    ' P_invoice_id_list = '       || P_invoice_id_list ||
    ' P_payment_num_list = '      || P_payment_num_list ||
    ' P_payment_type_flag = '     || P_payment_type_flag ||
    ' P_check_date = '            || P_check_date ||
    ' P_currency_code = '         || P_currency_code ||
    ' P_take_discount = '         || P_take_discount ||
    ' P_sys_auto_calc_int_flag = '|| P_sys_auto_calc_int_flag ||
    ' P_auto_calc_int_flag = '    || P_auto_calc_int_flag);
         FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_log_msg);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END AP_Get_Check_Amount;


  ---------------------------------------------------------------------
  -- Procedure Create_Single_Payment is called by Create_Payments to
  -- create the payment(s) for a single invoice
  --
  PROCEDURE Create_Single_Payment(P_invoice_id        IN  NUMBER,
                P_payment_num       IN  NUMBER,
                P_check_id        IN  NUMBER,
                P_payment_type_flag     IN  VARCHAR2,
                P_payment_method      IN  VARCHAR2,
                P_ce_bank_acct_use_id     IN  NUMBER,
                P_bank_account_num      IN  VARCHAR2,
                P_bank_account_type     IN  VARCHAR2,
                P_bank_num        IN  VARCHAR2,
                P_check_date              IN  DATE,
                P_period_name       IN  VARCHAR2,
                P_currency_code           IN  VARCHAR2,
                P_base_currency_code      IN  VARCHAR2,
                P_checkrun_name     IN  VARCHAR2,
                P_doc_sequence_value      IN  NUMBER,
                P_doc_sequence_id     IN  NUMBER,
                P_exchange_rate     IN  NUMBER,
                P_exchange_rate_type      IN  VARCHAR2,
                P_exchange_date     IN  DATE,
                P_take_discount           IN  VARCHAR2,
                P_sys_auto_calc_int_flag  IN  VARCHAR2,
                P_auto_calc_int_flag      IN  VARCHAR2,
                P_set_of_books_id     IN  NUMBER,
                P_future_pay_ccid         IN  NUMBER,
                P_last_updated_by     IN  NUMBER,
                P_last_update_login     IN  NUMBER,
                P_calling_sequence      IN  VARCHAR2,
                P_sequential_numbering    IN  VARCHAR2,
                P_accounting_event_id     IN  NUMBER, --Events
                P_org_id                IN  NUMBER)
  IS
    l_invoice_payment_id  NUMBER;
    l_payment_num   NUMBER;
    l_invoice_type    VARCHAR2(25);
    l_invoice_num   VARCHAR2(50);
    l_vendor_id     NUMBER;
    l_vendor_site_id    NUMBER;
    l_exclusive_payment_flag  VARCHAR2(1);
    l_future_pay_posted_flag  VARCHAR2(1);
    l_accts_pay_ccid    NUMBER;
    l_amount      NUMBER;
    l_amount_remaining    NUMBER;
    l_discount_available  NUMBER;
    l_discount_taken    NUMBER;
    l_interest_invoice_id NUMBER;
    l_interest_invoice_pay_id   NUMBER;
    l_interest_amount   NUMBER;
    l_payment_amount            NUMBER;
    l_due_date      DATE;
    l_interest_invoice_num  VARCHAR2(50);
    l_invoice_description       VARCHAR2(240);
    l_attribute1    VARCHAR2(150);
    l_attribute2    VARCHAR2(150);
    l_attribute3    VARCHAR2(150);
    l_attribute4    VARCHAR2(150);
    l_attribute5    VARCHAR2(150);
    l_attribute6    VARCHAR2(150);
    l_attribute7    VARCHAR2(150);
    l_attribute8    VARCHAR2(150);
    l_attribute9    VARCHAR2(150);
    l_attribute10   VARCHAR2(150);
    l_attribute11   VARCHAR2(150);
    l_attribute12   VARCHAR2(150);
    l_attribute13   VARCHAR2(150);
    l_attribute14   VARCHAR2(150);
    l_attribute15   VARCHAR2(150);
    l_attribute_category  VARCHAR2(150);
    l_log_msg    VARCHAR2(240);
    l_curr_calling_sequence VARCHAR2(2000);
    l_int_inv_doc_seq_v   NUMBER;                   --1724353
    l_int_inv_doc_seq_id  NUMBER;
    l_int_inv_doc_seq_nm  FND_DOCUMENT_SEQUENCES.NAME%TYPE;
    l_pay_amt             NUMBER;  --Bug9539935
    l_prepay_amt          NUMBER;
    l_count               NUMBER;

    -------------------------------------------------------------------
    -- Declare cursor to pay single invoice
    --
    CURSOR payments_cursor IS
    SELECT AIRP.payment_num,
     AIRP.invoice_type,
     AIRP.invoice_num,
     AIRP.vendor_id,
     AIRP.vendor_site_id,
     AIRP.exclusive_payment_flag,
     AIRP.accts_pay_code_combi_id,
     AIRP.amount_remaining,
     ap_payment_schedules_pkg.get_discount_available(
       AIRP.invoice_id,
       AIRP.payment_num,
       P_check_date,
       P_currency_code),
     APS.attribute1,
     APS.attribute2,
     APS.attribute3,
     APS.attribute4,
     APS.attribute5,
     APS.attribute6,
     APS.attribute7,
     APS.attribute8,
     APS.attribute9,
     APS.attribute10,
     APS.attribute11,
     APS.attribute12,
     APS.attribute13,
     APS.attribute14,
     APS.attribute15,
     APS.attribute_category
    FROM   ap_invoices_ready_to_pay_v AIRP,
     ap_payment_schedules       APS
    WHERE  AIRP.invoice_id = P_invoice_id
    AND    AIRP.payment_num = nvl(P_payment_num, AIRP.payment_num)
    AND    APS.invoice_id = AIRP.invoice_id
    AND    APS.payment_num = AIRP.payment_num;

  BEGIN
    l_curr_calling_sequence := 'AP_PAY_IN_FULL_PKG.CREATE_SINGLE_PAYMENT<-' ||
             P_calling_sequence;


    l_log_msg := 'Open payments_cursor';
    OPEN payments_cursor;

    LOOP
      l_log_msg := 'Fetch payments_cursor';
      FETCH payments_cursor
      INTO  l_payment_num,
      l_invoice_type,
      l_invoice_num,
      l_vendor_id,
      l_vendor_site_id,
      l_exclusive_payment_flag,
      l_accts_pay_ccid,
      l_amount_remaining,
      l_discount_available,
      l_attribute1,
      l_attribute2,
      l_attribute3,
      l_attribute4,
      l_attribute5,
      l_attribute6,
      l_attribute7,
      l_attribute8,
      l_attribute9,
      l_attribute10,
      l_attribute11,
      l_attribute12,
      l_attribute13,
      l_attribute14,
      l_attribute15,
      l_attribute_category;

      EXIT WHEN payments_cursor%NOTFOUND;

      --
      -- Calculate discount taken and amount
      --
      IF (P_take_discount = 'Y') THEN
        l_discount_taken := l_discount_available;
      ELSE
        l_discount_taken := 0;
      END IF;

      l_amount := l_amount_remaining - l_discount_taken;

      -- For pay-in-full payment_amount = amount_remaining

      l_payment_amount := l_amount_remaining;

      --
      -- Get next invoice_payment_id
      --
      l_log_msg := 'Get next invoice_payment_id';
      SELECT ap_invoice_payments_s.nextval
      INTO   l_invoice_payment_id
      FROM   sys.dual;

      --
      -- Bug: 661558
      -- DO AUTOMATIC WITHHOLDING
      --
      declare
         l_subject_amount          NUMBER;
         l_withholding_amount      NUMBER;
         l_awt_success             VARCHAR2(2000);
         l_include_discount        VARCHAR2(1);
         l_awt_flag                VARCHAR2(1);
         l_awt_invoices_exists     VARCHAR2(1);
         l_before_invoice_amount   NUMBER;
         l_inv_exchange_rate       NUMBER;
         l_pay_cross_rate          NUMBER;
	 --5145239
         l_awt_applied              VARCHAR2(1);
         l_create_awt_dists_type    VARCHAR2(25);
         l_create_awt_invoices_type VARCHAR2(25);
         --Bug6660355 AWT PROJ
         l_amount_payable            NUMBER;
         l_total_inv_amount          NUMBER;
         l_total_awt_amount          NUMBER;
      begin
      -- Bug 8406393
      -- Added Condition for Invoice type PAYMENT REQUEST
      -- Withholding should not be calculated for Invoice type PAYMENT REQUEST originated from AR
      -- having vendor_site_id as negative value (-222)

      IF (P_payment_type_flag = 'Q' AND l_vendor_site_id <> '-222') THEN

          l_log_msg := 'Get system parameter for tax withholding';

	  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
	    FND_LOG.STRING(G_LEVEL_PROCEDURE,
                   G_MODULE_NAME||'AP_PAY_IN_FULL_PKG.DO_AUTOMATIC_WITHHOLDING.begin',
                   l_log_msg);
	  END IF;

          SELECT   nvl(awt_include_discount_amt, 'N'),
                   nvl(allow_awt_flag, 'N'),
		   create_awt_dists_type,
                   create_awt_invoices_type

          INTO     l_include_discount,
                   l_awt_flag,
		   l_create_awt_dists_type, --5745239
                   l_create_awt_invoices_type
          FROM     ap_system_parameters;

          begin
             l_log_msg := 'Check if tax should be withheld from invoice:'||
                      to_char(P_invoice_id);
            IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
	      FND_LOG.STRING(G_LEVEL_PROCEDURE,
                   G_MODULE_NAME||'AP_PAY_IN_FULL_PKG.DO_AUTOMATIC_WITHHOLDING.begin',
                   l_log_msg);
	    END IF;
             SELECT 'Y',awt_flag
             INTO   l_awt_invoices_exists,l_awt_applied --5745239
             FROM   ap_invoices AI
             WHERE  AI.invoice_id = p_invoice_id
             AND EXISTS (SELECT 'At least 1 dist has an AWT Group'
                         FROM   ap_invoice_distributions AID1
                         WHERE  AID1.invoice_id = AI.invoice_id
                         AND   ( AID1.pay_awt_group_id is not null --Bug6660355
			 OR     AID1.awt_group_id is not null))    --Bug7685907
             AND   NOT EXISTS (SELECT 'Manual AWT lines exist'
                               FROM   ap_invoice_distributions AID
                               WHERE  AID.invoice_id = AI.invoice_id
                               AND    AID.line_type_lookup_code = 'AWT'
                               AND    AID.awt_flag in ('M', 'O'));

                l_log_msg := 'Distributions Exists -- l_awt_invoices_exists -- '||l_awt_invoices_exists
				||' l_awt_applied -- '||l_awt_applied;
		 IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
		   FND_LOG.STRING(G_LEVEL_PROCEDURE,
			   G_MODULE_NAME||'AP_PAY_IN_FULL_PKG.DO_AUTOMATIC_WITHHOLDING.begin',
	                   l_log_msg);
		  END IF;
          exception
            when no_data_found then
              l_awt_invoices_exists := 'N';
          end;
          --Bug6660355
          SELECT sum(nvl(base_amount,amount))
          INTO   l_total_inv_amount
          FROM   ap_invoice_distributions
          WHERE  invoice_id =p_invoice_id
          AND    line_type_lookup_code not in('PREPAYMENT','AWT');

	  --Bug7707630: Added NVL condition since the awt_group_id
	  --can be null at invoice header level
          SELECT  sum(nvl(aid.base_amount,aid.amount))
          INTO   l_total_awt_amount
          FROM   ap_invoice_distributions aid,ap_invoices ai
          WHERE  aid.invoice_id =p_invoice_id
          AND    aid.invoice_id    = ai.invoice_id
          AND    aid.line_type_lookup_code in ('AWT')
          AND    aid.awt_origin_group_id = NVL(ai.awt_group_id, aid.awt_origin_group_id)  --Bug7707630
          AND    aid.awt_invoice_payment_id IS NULL;
          --bug 8898537, should consider only invoice time AWT for calculating l_amount_payable

	  l_amount_payable := l_total_inv_amount + nvl(l_total_awt_amount,0); --7022001

          if l_awt_flag = 'Y' and
             l_awt_invoices_exists = 'Y' then

             --get invoice amount before withholding
             l_log_msg := 'Get the invoice amount for awt, invoice_id:'||
                      to_char(P_invoice_id);

             -- Bug 906732
             -- Multiply the witholding subject amount by the exchange rate as the
             -- witholding procedure expects the amount in base currency.

             SELECT invoice_amount,exchange_rate,nvl(payment_cross_rate,1)
             INTO   l_before_invoice_amount,l_inv_exchange_rate,l_pay_cross_rate
             FROM   ap_invoices
             WHERE  invoice_id = p_invoice_id;
/*
             if (l_include_discount = 'Y') then
                l_subject_amount := (((l_amount + l_discount_taken))
                            / l_pay_cross_rate) * nvl(l_inv_exchange_rate,1);
             else
                l_subject_amount := l_amount / l_pay_cross_rate
                            * nvl(l_inv_exchange_rate,1);
             end if;
*/
--changes for bug 8590059

             if (l_include_discount = 'Y') then
                l_subject_amount := (l_amount + l_discount_taken)
		  		    * nvl(P_exchange_rate,1);
             else
                l_subject_amount := l_amount * nvl(P_exchange_rate,1);
             end if;

             l_subject_amount := l_subject_amount * l_total_inv_amount/l_amount_payable; --Bug6660355
             l_log_msg := 'Call the AP_DO_WITHHOLD procedure, invoice_id:'||
                      to_char(P_invoice_id);
         --Bug5745239

	 l_log_msg := 'l_awt_applied -- '||nvl(l_awt_applied,'NULL')||' l_create_awt_dists_type -- '
			 ||l_create_awt_dists_type||' l_create_awt_invoices_type -- '||l_create_awt_invoices_type;
	  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
	    FND_LOG.STRING(G_LEVEL_PROCEDURE,
                   G_MODULE_NAME||'AP_PAY_IN_FULL_PKG.DO_AUTOMATIC_WITHHOLDING.begin',
                   l_log_msg);
	  END IF;

         IF (nvl(l_awt_applied,'N') <> 'Y')
             OR (l_create_awt_dists_type='APPROVAL' and l_create_awt_invoices_type ='PAYMENT')
             OR (l_create_awt_dists_type ='BOTH')  Then --Bug6660355

	 l_log_msg := 'call to AP_DO_WITHHOLDING with parameters -- p_invoice_id -- '||p_invoice_id
			 ||' p_calling_module -- QUICKCHECK '||'p_amount -- '||l_subject_amount;
	  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
	    FND_LOG.STRING(G_LEVEL_PROCEDURE,
                   G_MODULE_NAME||'AP_PAY_IN_FULL_PKG.DO_AUTOMATIC_WITHHOLDING.begin',
                   l_log_msg);
	  END IF;

             AP_WITHHOLDING_PKG.AP_Do_Withholding
                (P_Invoice_Id             => p_invoice_id
                ,P_Awt_Date               => P_check_date
                ,P_Calling_Module         => 'QUICKCHECK'
                ,P_Amount                 => l_subject_amount
                ,P_Payment_Num            => l_payment_num
                ,P_Checkrun_Name          => null
                ,P_Last_Updated_By        => p_last_updated_by
                ,P_Last_Update_Login      => p_last_update_login
                ,P_Program_Application_Id => null
                ,P_Program_Id             => null
                ,P_Request_Id             => null
                ,P_Awt_Success            => l_awt_success
	        ,P_Invoice_Payment_ID     => l_invoice_payment_id
 	        ,P_Check_Id		  => P_check_id		--bug 8590059
                );
         End if;
                if ((l_awt_success = 'SUCCESS') OR
                    (l_awt_success IS NULL)) then

                   -- get amount withheld for this particular invoice payment.
                   -- (this will be a negative number for STD inv and
       -- positive for CM
                   SELECT nvl(sum(ap_utilities_pkg.ap_round_currency(
             AID.amount * AI.payment_cross_rate,
          AI.payment_currency_code)),0)
                   INTO  l_withholding_amount
                   FROM ap_invoice_distributions AID,
                  ap_invoices AI
                   WHERE AID.awt_invoice_payment_id = l_invoice_payment_id
               AND AID.invoice_id = AI.invoice_id;

                   l_amount := l_amount + l_withholding_amount;
                   l_amount_remaining := l_amount_remaining +
                                         l_withholding_amount;
                else
                   FND_MESSAGE.SET_NAME('SQLAP', 'AP_AWT_PROB_PLSQL');
                   FND_MESSAGE.SET_TOKEN('INVOICE', to_char(P_invoice_id));
                   FND_MESSAGE.SET_TOKEN('PROBLEM', l_awt_success );
                   APP_EXCEPTION.RAISE_EXCEPTION;
                end if;

          end if;

      --END WITHHOLDING HANDLING
      end if; -- quick check


--Bug 9539935
--Overpayment code

SELECT nvl(SUM(aip.amount),0)
  INTO l_pay_amt
  FROM ap_invoice_payments_all aip
 WHERE aip.invoice_id = p_invoice_id;

 SELECT nvl(SUM(aid.amount),0)
   INTO l_prepay_amt
   FROM ap_invoice_distributions_all aid,ap_invoice_lines_all ail,ap_invoices_all ai
  WHERE ail.invoice_id=aid.invoice_id
        AND ail.invoice_id=ai.invoice_id
        AND ail.line_number=aid.invoice_line_number
        AND ai.invoice_id=p_invoice_id
    AND aid.prepay_distribution_id is not null
    AND nvl(ail.invoice_includes_prepay_flag,'N')<>'Y';


 BEGIN
   l_count:=0;

   SELECT count(ai.invoice_id)
     INTO l_count
     FROM ap_invoices_all ai
    WHERE ai.invoice_id=p_invoice_id
    GROUP BY ai.invoice_id,ai.invoice_amount
            ,ai.discount_amount_taken,  decode(ai.net_of_retainage_flag,'Y',0,
                nvl(AP_INVOICES_UTILITY_PKG.GET_RETAINED_TOTAL(ai.invoice_id,ai.org_id),0))
     HAVING (abs(nvl(ai.invoice_amount,0) -nvl(ai.discount_amount_taken,0)
                  - nvl(AP_INVOICES_UTILITY_PKG.get_amount_withheld(ai.invoice_id),0)
                  + decode(ai.net_of_retainage_flag, 'Y', 0,
                   nvl(AP_INVOICES_UTILITY_PKG.GET_RETAINED_TOTAL(ai.invoice_id, ai.org_id),0))
               )
            < abs((nvl(l_pay_amt,0)-nvl(l_prepay_amt,0))
                                +((l_amount) + (l_discount_taken))));

 EXCEPTION
     WHEN NO_DATA_FOUND THEN
     l_count:=0;
 END;

IF(l_count>0) THEN
   DECLARE
      undo_output VARCHAR2(2000);
   BEGIN
      AP_WITHHOLDING_PKG.Ap_Undo_Temp_Withholding
                            (P_Invoice_Id             => p_invoice_id
                            ,P_vendor_Id              => l_vendor_id
                            ,P_Payment_Num            => l_payment_num
                            ,P_Checkrun_Name          => null
                            ,P_Undo_Awt_Date          => SYSDATE
                            ,P_Calling_Module         => 'QUICKCHECK'
                            ,P_Last_Updated_By        => p_last_updated_by
                                ,P_Last_Update_Login      => p_last_update_login
                            ,P_Program_Application_Id => null
                            ,P_Program_Id             => null
                            ,P_Request_Id             => null
                            ,P_Awt_Success            => undo_output
                            ,P_checkrun_id            => null);

   END;

   FND_MESSAGE.SET_NAME('SQLAP', 'AP_OVERPAID_INVOICE');
   FND_MESSAGE.SET_TOKEN('INVOICE', to_char(P_invoice_id));
   APP_EXCEPTION.RAISE_EXCEPTION;

END IF;

--End of Overpayment code
--End of bug 9539935
      end;

      --
      -- Calculate interest invoice amount
      -- added below 'and' condition for 7612309/7668747
      IF ((P_payment_type_flag = 'Q') AND (P_auto_calc_int_flag = 'Y')) THEN
    l_log_msg := 'Calulate interest invoice amount for invoice_id:' ||
      to_char(P_invoice_id) || ' payment_num:' ||
      to_char(l_payment_num);
        AP_INTEREST_INVOICE_PKG.AP_CALCULATE_INTEREST(
                  P_invoice_id,
                  P_sys_auto_calc_int_flag,
                  P_auto_calc_int_flag,
                  P_check_date,
                  l_payment_num,
                  --bug1905384 Interest should be calculated for payment amount
                  --including withholding amount.
                  l_payment_amount,
                  --l_amount_remaining,
                  l_discount_taken,
                  l_discount_available,
                  P_currency_code,
                  l_interest_amount,
                  l_due_date,
                  l_interest_invoice_num,
                  l_payment_amount,
                  l_curr_calling_sequence);
      ELSE
        l_interest_amount := 0;
      END IF;


      l_log_msg := 'Create invoice payment for invoice_id:' ||
          to_char(P_invoice_id) || ' payment_num:' ||
          to_char(l_payment_num);

      AP_PAY_INVOICE_PKG.AP_PAY_INVOICE(
          P_invoice_id              =>    P_invoice_id,
          P_check_id                =>    P_check_id,
          P_payment_num             =>    l_payment_num,
          P_invoice_payment_id      =>    l_invoice_payment_id,
          P_old_invoice_payment_id  =>    NULL,
          P_period_name             =>    P_period_name,
          P_invoice_type            =>    l_invoice_type,
          P_accounting_date         =>    P_check_date,
          P_amount                  =>    l_amount,
          P_discount_taken          =>    l_discount_taken,
          P_discount_lost           =>    '',
          P_invoice_base_amount     =>    '',
          P_payment_base_amount     =>    '',
          P_accrual_posted_flag     =>    'N',
          P_cash_posted_flag        =>    'N',
          P_posted_flag             =>    'N',
          P_set_of_books_id         =>    P_set_of_books_id,
          P_last_updated_by         =>    P_last_updated_by,
          P_last_update_login       =>    P_last_update_login,
          P_currency_code           =>    P_currency_code,
          P_base_currency_code      =>    P_base_currency_code,
          P_exchange_rate           =>    P_exchange_rate,
          P_exchange_rate_type      =>    P_exchange_rate_type,
          P_exchange_date           =>    P_exchange_date,
          P_ce_bank_acct_use_id     =>    P_ce_bank_acct_use_id,
          P_bank_account_num        =>    P_bank_account_num,
          P_bank_account_type       =>    P_bank_account_type,
          P_bank_num                =>    P_bank_num,
          P_future_pay_posted_flag  =>    l_future_pay_posted_flag,
          P_exclusive_payment_flag  =>    l_exclusive_payment_flag,
          P_accts_pay_ccid          =>    l_accts_pay_ccid,
          P_gain_ccid               =>    '',
          P_loss_ccid               =>    '',
          P_future_pay_ccid         =>    P_future_pay_ccid,
          P_asset_ccid              =>    NULL,
          P_payment_dists_flag      =>    'N',
          P_payment_mode            =>    'PAY',
          P_replace_flag            =>    'N',
          P_attribute1              =>    l_attribute1,
          P_attribute2              =>    l_attribute2,
          P_attribute3              =>    l_attribute3,
          P_attribute4              =>    l_attribute4,
          P_attribute5              =>    l_attribute5,
          P_attribute6              =>    l_attribute6,
          P_attribute7              =>    l_attribute7,
          P_attribute8              =>    l_attribute8,
          P_attribute9              =>    l_attribute9,
          P_attribute10             =>    l_attribute10,
          P_attribute11             =>    l_attribute11,
          P_attribute12             =>    l_attribute12,
          P_attribute13             =>    l_attribute13,
          P_attribute14             =>    l_attribute14,
          P_attribute15             =>    l_attribute15,
          P_attribute_category      =>    l_attribute_category,
          P_calling_sequence        =>    l_curr_calling_sequence,
          -- Events Project - 4 - Added following parameter
          P_accounting_event_id     =>    P_accounting_event_id,
          P_org_id                  =>    P_org_id);

      --Bug2993905 We will call events package to update the accounting
      --event id on awt distributions created during Payment time with
      --the payment time account event id after invoice payments have been
      --created.
      IF (p_payment_type_flag = 'Q') THEN

        -- Events Project
        -- Bug 2751466
        -- This call is happening for the Pay-In-Full case,
        -- (also a type of Quick Payment)
        --
        -- This code will work ONLY when the the wiholding options
        -- are set to:-
        --
        -- o Apply Witholding Tax      ==> At Payment Time
        -- o Create Witholding Invoice ==> At Payment Time
        --
        -- We want to stamp the Accounting_Event_ID for the Payment
        -- Event on all the AWT distributions that have been created
        -- as a result of this check.

        AP_ACCOUNTING_EVENTS_PKG.UPDATE_AWT_INT_DISTS
        (
          p_event_type => 'PAYMENT CREATED',
          p_check_id => p_check_id,
          p_event_id => p_accounting_event_id,
          p_calling_sequence => l_curr_calling_sequence
        );

      END IF;
      --Bug2993905 End.

      --
      -- Create interest invoice if QuickCheck
      -- Added below 'AND' condition for 7612309/7668747
      IF ((P_payment_type_flag = 'Q') AND (P_auto_calc_int_flag = 'Y'))THEN

        --
        -- Get next interest invoice_id
        --
        l_log_msg := 'Get next interest invoice_id';
        SELECT ap_invoices_s.nextval
        INTO   l_interest_invoice_id
        FROM   sys.dual;

        --
        -- Get next interest invoice_payment_id
        --
        l_log_msg := 'Get next interest invoice_payment_id';
        SELECT ap_invoice_payments_s.nextval
        INTO   l_interest_invoice_pay_id
        FROM   sys.dual;

        --
        -- Create interest invoice
  --
        l_log_msg := 'Create interest invoice for invoice_id:' ||
            to_char(P_invoice_id) || ' payment_num:' ||
            to_char(l_payment_num);

        --
        -- Bug: 622377
        -- This block will compose the Invoice Description field by retrieving the
        -- Due Date and Annual interest rate and the filling words...
        --
        DECLARE
           l_rate              NUMBER;
           l_due_date          DATE;
           l_int_invoice_days  NUMBER;
           /* Datatype for following variables changed for MLS */
           l_nls_interest      ap_lookup_codes.displayed_field%TYPE;  -- **1**
           l_nls_days          ap_lookup_codes.displayed_field%TYPE;  -- **1**
           l_nls_percent       ap_lookup_codes.displayed_field%TYPE;  -- **1**

        BEGIN
          -- Get the Translatable Words for filling the description
          SELECT l1.displayed_field,
                 l2.displayed_field,
                 l3.displayed_field
            INTO l_nls_interest,
                 l_nls_days,
                 l_nls_percent
            FROM ap_lookup_codes l1,
                 ap_lookup_codes l2,
                 ap_lookup_codes l3
           WHERE l1.lookup_type = 'NLS TRANSLATION'
             AND l1.lookup_code = 'INTEREST'
             AND l2.lookup_type = 'NLS TRANSLATION'
             AND l2.lookup_code = 'DAYS'
             AND l3.lookup_type = 'NLS TRANSLATION'
             AND l3.lookup_code = 'PERCENT';

           IF l_interest_amount = 0 THEN
              l_invoice_description := '0 ' || l_nls_interest;
           ELSE
              BEGIN
              SELECT  annual_interest_rate , due_date
                 INTO    l_rate, l_due_date
                 FROM    ap_payment_schedules, ap_interest_periods
                 WHERE   payment_num = l_payment_num
                 AND     invoice_id = P_invoice_id
                 AND     trunc(due_date+1) BETWEEN trunc(start_date) AND trunc(end_date);

              l_int_invoice_days:=
                 LEAST(TRUNC(P_check_date),ADD_MONTHS(TRUNC(l_due_date),12))
                       - TRUNC(l_due_date);

              l_invoice_description :=
                 l_nls_interest|| ' ' || to_char(l_int_invoice_days) || ' ' || l_nls_days ||
                 to_char(l_rate) || l_nls_percent;

              EXCEPTION
              WHEN NO_DATA_FOUND then
                  -- If no interest found, treat as ZERO interest
                  l_invoice_description := '0 ' || l_nls_interest;
              END;
           END IF;
        END;


             --1724353, START OF CODE

        BEGIN

            IF P_sequential_numbering = 'A' and l_interest_amount > 0 THEN


                l_int_inv_doc_seq_v :=   FND_SEQNUM.GET_NEXT_SEQUENCE(
                                         APPID    =>'200',
                                         CAT_CODE => 'INT INV',
                                         SOBID    => P_set_of_books_id,
                                         MET_CODE => 'A',
                                         TRX_DATE => SYSDATE,
                                         DBSEQNM  => l_int_inv_doc_seq_nm,
                                         DBSEQID  => l_int_inv_doc_seq_id );
            END IF;

        EXCEPTION

              WHEN OTHERS THEN

                IF (SQLCODE <> -20001) THEN
                    FND_MESSAGE.SET_NAME('FND','UNIQUE-ALWAYS USED');
                END IF;

                APP_EXCEPTION.RAISE_EXCEPTION;
       END;


        BEGIN

            IF P_sequential_numbering = 'P' and l_interest_amount > 0 THEN

                l_int_inv_doc_seq_v :=   FND_SEQNUM.GET_NEXT_SEQUENCE(
                                         APPID    =>'200',
                                         CAT_CODE => 'INT INV',
                                         SOBID    => P_set_of_books_id,
                                         MET_CODE => 'A',
                                         TRX_DATE => SYSDATE,
                                         DBSEQNM  => l_int_inv_doc_seq_nm,
                                         DBSEQID  => l_int_inv_doc_seq_id );
            END IF;

        EXCEPTION
          when others then
          NULL;

        END;

       --1724353, END OF CODE




  AP_INTEREST_INVOICE_PKG.AP_CREATE_INTEREST_INVOICE(
            P_invoice_id                  =>    P_invoice_id,
            P_int_invoice_id              =>    l_interest_invoice_id,
            P_check_id                    =>    P_check_id,
            P_payment_num                 =>    l_payment_num,
            P_int_invoice_payment_id      =>    l_interest_invoice_pay_id,
            P_old_invoice_payment_id      =>    NULL,
            P_period_name                 =>    P_period_name,
            P_invoice_type                =>    l_invoice_type,
            P_accounting_date             =>    P_check_date,
            P_amount                      =>    l_amount,
            P_discount_taken              =>    l_discount_taken,
            P_discount_lost               =>    '',
            P_invoice_base_amount         =>    '',
            P_payment_base_amount         =>    '',
            P_vendor_id                   =>    l_vendor_id,
            P_vendor_site_id              =>    l_vendor_site_id,
            P_int_invoice_num             =>    l_interest_invoice_num,
            P_old_invoice_num             =>    l_invoice_num,
            P_interest_amount             =>    l_interest_amount,
            P_payment_method_code         =>    P_payment_method, --4552701
            P_doc_sequence_value          =>    l_int_inv_doc_seq_v, --1724353
            P_doc_sequence_id             =>    l_int_inv_doc_seq_id,--1724353
            P_checkrun_name               =>    P_checkrun_name,
            P_payment_priority            =>    '',
            P_accrual_posted_flag         =>    'N',
            P_cash_posted_flag            =>    'N',
            P_posted_flag                 =>    'N',
            P_set_of_books_id             =>    P_set_of_books_id,
            P_last_updated_by             =>    P_last_updated_by,
            P_last_update_login           =>    P_last_update_login,
            P_currency_code               =>    P_currency_code,
            P_base_currency_code          =>    P_base_currency_code,
            P_exchange_rate               =>    P_exchange_rate,
            P_exchange_rate_type          =>    P_exchange_rate_type,
            P_exchange_date               =>    P_exchange_date,
            P_bank_account_id             =>    P_ce_bank_acct_use_id,
            P_bank_account_num            =>    P_bank_account_num,
            P_bank_account_type           =>    P_bank_account_type,
            P_bank_num                    =>    P_bank_num,
            P_exclusive_payment_flag      =>    l_exclusive_payment_flag,
            P_accts_pay_ccid              =>    l_accts_pay_ccid,
            P_gain_ccid                   =>    '',
            P_loss_ccid                   =>    '',
            P_future_pay_ccid             =>    P_future_pay_ccid,
            P_asset_ccid                  =>    NULL,
            P_payment_dists_flag          =>    'N',
            P_payment_mode                =>    'PAY',
            P_replace_flag                =>    'N',
            P_invoice_description         =>    l_invoice_description,
            P_attribute1                  =>    l_attribute1,
            P_attribute2                  =>    l_attribute2,
            P_attribute3                  =>    l_attribute3,
            P_attribute4                  =>    l_attribute4,
            P_attribute5                  =>    l_attribute5,
            P_attribute6                  =>    l_attribute6,
            P_attribute7                  =>    l_attribute7,
            P_attribute8                  =>    l_attribute8,
            P_attribute9                  =>    l_attribute9,
            P_attribute10                 =>    l_attribute10,
            P_attribute11                 =>    l_attribute11,
            P_attribute12                 =>    l_attribute12,
            P_attribute13                 =>    l_attribute13,
            P_attribute14                 =>    l_attribute14,
            P_attribute15                 =>    l_attribute15,
            P_attribute_category          =>    l_attribute_category,
            P_calling_sequence            =>    l_curr_calling_sequence,
            P_org_id                      =>    P_org_id,  /* Bug 4742671 */
            P_accounting_event_id         =>    P_accounting_event_id); --Events

      END IF;

    END LOOP;

    l_log_msg := 'Close payments_cursor';
    CLOSE payments_cursor;


  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
    ' P_invoice_id = '        || P_invoice_id      ||
    ' P_payment_num = '       || P_payment_num     ||
    ' P_check_id = '                || P_check_id        ||
    ' P_payment_type_flag = '   || P_payment_type_flag     ||
    ' P_payment_method = '    || P_payment_method    ||
    ' P_bank_account_id = '   || P_ce_bank_acct_use_id   ||
    ' P_bank_account_num = '  || P_bank_account_num      ||
    ' P_bank_account_type = '   || P_bank_account_type     ||
    ' P_bank_num = '    || P_bank_num      ||
    ' P_check_date = '    || P_check_date      ||
    ' P_period_name = '     || P_period_name     ||
    ' P_currency_code = '     || P_currency_code       ||
    ' P_base_currency_code = '  || P_base_currency_code    ||
    ' P_checkrun_name = '     || P_checkrun_name     ||
    ' P_doc_sequence_value = '  || P_doc_sequence_value    ||
    ' P_doc_sequence_id = '   || P_doc_sequence_id     ||
    ' P_exchange_rate = '     || P_exchange_rate     ||
    ' P_exchange_rate_type = '  || P_exchange_rate_type    ||
    ' P_exchange_date = '     || P_exchange_date     ||
    ' P_take_discount = '     || P_take_discount         ||
    ' P_sys_auto_calc_int_flag = '  || P_sys_auto_calc_int_flag||
    ' P_auto_calc_int_flag = '  || P_auto_calc_int_flag    ||
    ' P_set_of_books_id = '   || P_set_of_books_id     ||
    ' P_future_pay_ccid = '   || P_future_pay_ccid     ||
    ' P_last_updated_by = '   || P_last_updated_by     ||
    ' P_last_update_login = '   || P_last_update_login
    );
  FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_log_msg);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Create_Single_Payment;


  ---------------------------------------------------------------------
  -- Procedure AP_Create_Payments create an invoice payment for all payable
  -- payment schedules belonging to invoices in P_invoice_id_list and
  -- related interest invoices if Quickcheck.
  --
  PROCEDURE AP_Create_Payments(P_invoice_id_list  IN  VARCHAR2,
             P_payment_num_list IN  VARCHAR2,
             P_check_id   IN  NUMBER,
             P_payment_type_flag  IN  VARCHAR2,
             P_payment_method   IN  VARCHAR2,
             P_ce_bank_acct_use_id  IN  NUMBER,
             P_bank_account_num IN  VARCHAR2,
             P_bank_account_type  IN  VARCHAR2,
             P_bank_num   IN  VARCHAR2,
             P_check_date             IN  DATE,
             P_period_name    IN  VARCHAR2,
             P_currency_code          IN  VARCHAR2,
             P_base_currency_code IN  VARCHAR2,
             P_checkrun_name    IN  VARCHAR2,
             P_doc_sequence_value IN  NUMBER,
             P_doc_sequence_id  IN  NUMBER,
             P_exchange_rate    IN  NUMBER,
             P_exchange_rate_type IN  VARCHAR2,
             P_exchange_date    IN  DATE,
             P_take_discount          IN  VARCHAR2,
             P_sys_auto_calc_int_flag IN  VARCHAR2,
             P_auto_calc_int_flag     IN  VARCHAR2,
             P_set_of_books_id  IN  NUMBER,
             P_future_pay_ccid  IN  NUMBER,
             P_last_updated_by  IN  NUMBER,
             P_last_update_login  IN  NUMBER,
             P_calling_sequence IN  VARCHAR2,
             P_sequential_numbering   IN  VARCHAR2 DEFAULT 'N', -- 1724353
             P_accounting_event_id  IN  NUMBER, -- Events
             P_org_id           IN  NUMBER)
  IS
    l_invoice_id    NUMBER;
    l_payment_num   NUMBER;
    l_pos     NUMBER;
    l_next      NUMBER;
    l_log_msg    VARCHAR2(240);
    l_curr_calling_sequence VARCHAR2(2000);

  BEGIN
    l_curr_calling_sequence := 'AP_PAY_IN_FULL_PKG.AP_CREATE_PAYMENTS<-' ||
             P_calling_sequence;
    l_pos := 1;

    IF (P_payment_num_list IS NOT NULL) THEN

      l_invoice_id := TO_NUMBER(P_invoice_id_list);
      --
      -- Parse P_payment_num_list
      --
      LOOP
        l_next := INSTR(P_payment_num_list, ' ', l_pos);
        IF (l_next = 0) THEN
          l_next := LENGTH(P_payment_num_list) + 1;
        END IF;

        l_payment_num := TO_NUMBER(SUBSTR(P_payment_num_list,
                                          l_pos,
                  l_next - l_pos));

  Create_Single_Payment(l_invoice_id,
            l_payment_num,
            P_check_id,
            P_payment_type_flag,
            P_payment_method,
            P_ce_bank_acct_use_id,
            P_bank_account_num,
            P_bank_account_type,
            P_bank_num,
            P_check_date,
            P_period_name,
            P_currency_code,
            P_base_currency_code,
            P_checkrun_name,
            P_doc_sequence_value,
            P_doc_sequence_id,
            P_exchange_rate,
            P_exchange_rate_type,
            P_exchange_date,
            P_take_discount,
            P_sys_auto_calc_int_flag,
            P_auto_calc_int_flag,
            P_set_of_books_id,
            P_future_pay_ccid,
            P_last_updated_by,
            P_last_update_login,
            l_curr_calling_sequence,
            P_sequential_numbering, -- 1724353
            P_accounting_event_id,  -- Events Project
            P_org_id);

        EXIT WHEN (l_next > LENGTH(P_payment_num_list));
        l_pos := l_next + 1;

      END LOOP;

    ELSIF (P_invoice_id_list IS NOT NULL) THEN
      --
      -- Parse P_invoice_id_list
      --
      LOOP
        l_next := INSTR(P_invoice_id_list, ' ', l_pos);
        IF (l_next = 0) THEN
          l_next := LENGTH(P_invoice_id_list) + 1;
        END IF;

        l_invoice_id := TO_NUMBER(SUBSTR(P_invoice_id_list,
                                       l_pos,
               l_next - l_pos));

  l_log_msg := 'Get discount available for invoice_id:' ||
      to_char(l_invoice_id);

  Create_Single_Payment(l_invoice_id,
            NULL,
            P_check_id,
            P_payment_type_flag,
            P_payment_method,
            P_ce_bank_acct_use_id,
            P_bank_account_num,
            P_bank_account_type,
            P_bank_num,
            P_check_date,
            P_period_name,
            P_currency_code,
            P_base_currency_code,
            P_checkrun_name,
            P_doc_sequence_value,
            P_doc_sequence_id,
            P_exchange_rate,
            P_exchange_rate_type,
            P_exchange_date,
            P_take_discount,
            P_sys_auto_calc_int_flag,
            P_auto_calc_int_flag,
            P_set_of_books_id,
            P_future_pay_ccid,
            P_last_updated_by,
            P_last_update_login,
            l_curr_calling_sequence,
            P_sequential_numbering,
            P_accounting_event_id,   -- Events Project
            P_org_id);

        EXIT WHEN (l_next > LENGTH(P_invoice_id_list));
        l_pos := l_next + 1;

      END LOOP;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
    ' P_invoice_id_list = '         || P_invoice_id_list     ||
    ' P_payment_num_list = '        || P_payment_num_list      ||
    ' P_check_id = '                || P_check_id        ||
    ' P_payment_type_flag = '   || P_payment_type_flag     ||
    ' P_payment_method = '    || P_payment_method    ||
    ' P_bank_account_id = '   || P_ce_bank_acct_use_id   ||
    ' P_bank_account_num = '  || P_bank_account_num      ||
    ' P_bank_account_type = '   || P_bank_account_type     ||
    ' P_bank_num = '    || P_bank_num      ||
    ' P_check_date = '    || P_check_date      ||
    ' P_period_name = '     || P_period_name     ||
    ' P_currency_code = '     || P_currency_code       ||
    ' P_base_currency_code = '  || P_base_currency_code    ||
    ' P_checkrun_name = '     || P_checkrun_name     ||
    ' P_doc_sequence_value = '  || P_doc_sequence_value    ||
    ' P_doc_sequence_id = '   || P_doc_sequence_id     ||
    ' P_exchange_rate = '     || P_exchange_rate     ||
    ' P_exchange_rate_type = '  || P_exchange_rate_type    ||
    ' P_exchange_date = '     || P_exchange_date     ||
    ' P_take_discount = '     || P_take_discount         ||
    ' P_sys_auto_calc_int_flag = '  || P_sys_auto_calc_int_flag||
    ' P_auto_calc_int_flag = '  || P_auto_calc_int_flag    ||
    ' P_set_of_books_id = '   || P_set_of_books_id     ||
    ' P_future_pay_ccid = '   || P_future_pay_ccid     ||
    ' P_last_updated_by = '   || P_last_updated_by     ||
    ' P_last_update_login = '   || P_last_update_login
    );
  FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_log_msg);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END AP_Create_Payments;

END AP_PAY_IN_FULL_PKG;

/
