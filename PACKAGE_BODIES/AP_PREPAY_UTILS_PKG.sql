--------------------------------------------------------
--  DDL for Package Body AP_PREPAY_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_PREPAY_UTILS_PKG" AS
/*$Header: apprutlb.pls 120.10.12010000.7 2009/12/31 12:16:51 pgayen ship $*/

FUNCTION Get_Line_Prepay_AMT_Remaining (
          P_invoice_id    IN NUMBER,
          P_line_number   IN NUMBER) RETURN NUMBER
IS
  l_prepay_amount_remaining NUMBER := 0;

BEGIN
  SELECT   SUM(NVL(prepay_amount_remaining, total_dist_amount))
    INTO   l_prepay_amount_remaining
    FROM   ap_invoice_distributions_all
   WHERE   invoice_id              = p_invoice_id
     AND   invoice_line_number     = p_line_number
     AND   line_type_lookup_code IN
           ('ITEM', 'ACCRUAL',
            'REC_TAX', 'NONREC_TAX' )
     AND   NVL(reversal_flag,'N')  <> 'Y';

RETURN (l_prepay_amount_remaining);

EXCEPTION
  WHEN OTHERS THEN
    RETURN (l_prepay_amount_remaining);

END Get_Line_Prepay_AMT_Remaining;


--This Function will return the amount_remaining for the Item Line
--on a Prepayment invoice, including the associated tax of that Item line.
--The tax could be exclusive or inclusive. For the exclusive case the
--tax distributions associated would be a separate line.

FUNCTION Get_Ln_Prep_AMT_Remain_Recoup (
          P_invoice_id    IN NUMBER,
	  P_line_number   IN NUMBER) RETURN NUMBER IS
l_prepay_amount_remaining_item  NUMBER;
l_prepay_amount_remaining_tax   NUMBER;

BEGIN

    l_prepay_amount_remaining_item := 0;
    l_prepay_amount_remaining_tax  := 0;

    SELECT   NVL(SUM(NVL(prepay_amount_remaining, total_dist_amount)),0)
    INTO   l_prepay_amount_remaining_item
    FROM   ap_invoice_distributions_all
    WHERE   invoice_id              = p_invoice_id
    AND   invoice_line_number     = p_line_number
    AND   line_type_lookup_code IN
             ('ITEM', 'ACCRUAL')
              --'REC_TAX', 'NONREC_TAX' )  --bugfix:5609186
    AND   NVL(reversal_flag,'N')  <> 'Y';

    --To get the exclusive tax amount tied to the Item line of Prepayment invoice.
    /*
    SELECT   NVL(SUM(NVL(aid.prepay_amount_remaining, aid.total_dist_amount)),0)
    INTO   l_prepay_amount_remaining_tax
    FROM   ap_invoice_distributions_all aid, --Tax line
           ap_invoice_distributions_all aid1 --Item line
    WHERE   aid1.invoice_id         = p_invoice_id
    AND   aid1.invoice_line_number  = p_line_number
    AND   aid.invoice_id = aid1.invoice_id
    AND   aid.charge_applicable_to_dist_id = aid1.invoice_distribution_id
    AND   aid.line_type_lookup_code IN ('REC_TAX','NONREC_TAX')
    AND   aid1.line_type_lookup_code IN ('ITEM', 'ACCRUAL')
    AND   NVL(aid1.reversal_flag,'N')  <> 'Y'
    AND   NVL(aid.reversal_flag,'N') <> 'Y'; */

 RETURN (l_prepay_amount_remaining_item+l_prepay_amount_remaining_tax);

EXCEPTION
   WHEN OTHERS THEN
     RETURN (l_prepay_amount_remaining_item+l_prepay_amount_remaining_tax);

END Get_Ln_Prep_AMT_Remain_Recoup;


FUNCTION Lock_Line (
          P_invoice_id   IN NUMBER,
          P_line_number  IN NUMBER,
          P_request_id   IN NUMBER) RETURN BOOLEAN
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  -- This would lock the selected lines for both the
  -- online and the batch cases.

  UPDATE  ap_invoice_lines
     SET  line_selected_for_appl_flag = 'Y',
          prepay_appl_request_id = p_request_id
   WHERE  invoice_id             = p_invoice_id
     AND  line_number            = p_line_number;

  COMMIT;

  RETURN (TRUE);

  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);

END Lock_Line;

FUNCTION Unlock_Line (
          P_invoice_id  IN NUMBER,
          P_line_number IN NUMBER) RETURN BOOLEAN
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  UPDATE  ap_invoice_lines
     SET  line_selected_for_appl_flag = 'N',
          prepay_appl_request_id      = NULL
   WHERE  invoice_id  = p_invoice_id
     AND  line_number = p_line_number;

  COMMIT;

  RETURN (TRUE);

  EXCEPTION
    WHEN OTHERS THEN

  RETURN (FALSE);
END Unlock_Line;

FUNCTION Unlock_Locked_Lines (
          P_request_id  IN NUMBER) RETURN BOOLEAN
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  -- This would lock the selected lines for both the
  -- online and the batch cases.

  UPDATE  ap_invoice_lines
     SET  line_selected_for_appl_flag = 'N',
          prepay_appl_request_id = NULL
   WHERE  (   prepay_appl_request_id = p_request_id
           OR prepay_appl_request_id IS NULL)
     AND  line_selected_for_appl_flag = 'Y';

  COMMIT;

  RETURN (TRUE);

  EXCEPTION
    WHEN OTHERS THEN

  RETURN (FALSE);
END Unlock_Locked_Lines;

FUNCTION IS_Line_Locked (
          P_invoice_id  IN NUMBER,
          P_line_number IN NUMBER,
          P_request_id  IN NUMBER) RETURN VARCHAR2
IS
  l_already_selected_flag VARCHAR2(1);
  l_request_id            NUMBER;
BEGIN
  SELECT  NVL(line_selected_for_appl_flag,'N'),
          prepay_appl_request_id
    INTO  l_already_selected_flag,
          l_request_id
    FROM  ap_invoice_lines
   WHERE  invoice_id  = p_invoice_id
     AND  line_number = p_line_number;

   IF l_already_selected_flag = 'Y' AND
      l_request_id            IS NULL THEN
      RETURN ('LOCKED');
   END IF;

   IF l_already_selected_flag = 'Y' AND
      l_request_id            IS NOT NULL THEN

      IF l_request_id = P_request_id THEN
        RETURN ('UNLOCKED');
      ELSE
        RETURN ('LOCKED');
      END IF;

   END IF;

   IF l_already_selected_flag = 'N' THEN
     RETURN ('UNLOCKED');
   END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN ('UNLOCKED');
    -- Check the RETURN in the case of exception

END IS_Line_Locked;


FUNCTION get_prepay_number (l_prepay_dist_id IN NUMBER)
RETURN VARCHAR2
IS
  l_prepay_number VARCHAR2(50);

  CURSOR c_prepay_number IS
  SELECT invoice_num
    FROM ap_invoices_all ai,
         ap_invoice_distributions_all aid
   WHERE ai.invoice_id               = aid.invoice_id
     AND aid.invoice_distribution_id = l_prepay_dist_id;

BEGIN

  -- This Function returns the prepayment number that the prepayment
  -- distribution  is associated with.

  OPEN  c_prepay_number;
  FETCH c_prepay_number
  INTO  l_prepay_number;
  CLOSE c_prepay_number;

  RETURN(l_prepay_number);

END get_prepay_number;


FUNCTION get_prepay_dist_number (l_prepay_dist_id IN NUMBER)
RETURN VARCHAR2
IS
  l_prepay_dist_number VARCHAR2(50);

  CURSOR c_prepay_dist_number IS
  SELECT distribution_line_number
    FROM ap_invoice_distributions_all
   WHERE invoice_distribution_id = l_prepay_dist_id;

BEGIN

  -- This Function returns the distribution_line_number that the
  -- prepayment associated with.

  OPEN c_prepay_dist_number;
  FETCH c_prepay_dist_number
  INTO l_prepay_dist_number;
  CLOSE c_prepay_dist_number;

  RETURN(l_prepay_dist_number);

END get_prepay_dist_number;


FUNCTION get_prepaid_amount(l_invoice_id IN NUMBER)
RETURN NUMBER
IS
  l_prepaid_amount           NUMBER := 0;
BEGIN

  -- This Function returns the prepaid amount on an STANDARD
  -- invoice
  -- eTax Uptake.  This function was modified to use the lines
  -- table instead of the distributions and include TAX lines in
  -- the prepaid amount if tax is exclusive.  In the inclusive
  -- case the PREPAY line will include the tax amount
 --bug4944102. As part of Performance fic for invoice workbench
 --fixed the following query
 /* SELECT (0 - SUM(NVL(amount,0)))
    INTO l_prepaid_amount
    FROM ap_invoice_lines_all
   WHERE invoice_id = l_invoice_id
     AND line_type_lookup_code IN ('PREPAY', 'TAX')
     AND NVL(invoice_includes_prepay_flag, 'N') = 'N'  -- Bug 5675960. Added the NVL
     AND nvl(prepay_invoice_id,-999)<>-999
     AND nvl(prepay_line_number,-999)<>-999 ; */

    SELECT  (0 - SUM(NVL(aid.amount,0)))
    INTO l_prepaid_amount
    FROM ap_invoice_distributions_all aid,
         ap_invoice_lines_all         ail
     WHERE ail.invoice_id = l_invoice_id
     AND   ail.invoice_id = aid.invoice_id
     AND   ail.line_number = aid.invoice_line_number
     AND   aid.line_type_lookup_code = 'PREPAY'
     AND   aid.prepay_distribution_id IS NOT NULL
     AND   NVL(ail.invoice_includes_prepay_flag, 'N') = 'N';



  RETURN(l_prepaid_amount);

END get_prepaid_amount;

-- This Function returns the total number of prepayments that exist for
-- a vendor (not fully applied, not permanent). We've declared a server-side
-- function that can be accessed from our invoices view so as to improve
-- performance when retrieving invoices in the Invoice Gateway.

FUNCTION get_total_prepays(
          l_vendor_id    IN NUMBER,
          l_org_id       IN NUMBER)
RETURN NUMBER
IS
  prepay_count           NUMBER := 0;
  l_prepay_amount_remaining NUMBER:=0;
  /*Bug 6841613
    Replaced the existing logic with a cursor defined for the same
    which just selects the prepayment invoices for the vendor.This
    is done for performance overheads.The comparison of earliest
    settlement date would be done with the cursor variable,also the
    earlier select statement which would call the get_total_prepays
    as a filter is removed and logic is implemented here as this
    would reduce the wait time*/

    /* Bug 9128633 Start -- Split the cursor prepayment_invoices into two
       parts to handle the l_org_id not null and null conditions to improve
       performance */

   CURSOR prepayment_invoices IS
    SELECT earliest_settlement_date,invoice_id
      from ap_invoices
     where vendor_id=l_vendor_id
       and invoice_type_lookup_code='PREPAYMENT'
       and earliest_settlement_date is not null; --bug7015402

   CURSOR prepayment_invoices_org IS
    SELECT earliest_settlement_date,invoice_id
      from ap_invoices
     where vendor_id=l_vendor_id
       and invoice_type_lookup_code='PREPAYMENT'
       and earliest_settlement_date is not null --bug7015402
       AND org_id = l_org_id;

     BEGIN

     if l_org_id is null then
        for i in prepayment_invoices
        loop
            l_prepay_amount_remaining:=0;
            l_prepay_amount_remaining:=
            AP_INVOICES_UTILITY_PKG.get_prepay_amount_remaining(i.invoice_id);
            if(l_prepay_amount_remaining>0 ) then
                prepay_count:=prepay_count+1;
            end if;
        end loop;
    elsif l_org_id is not null then
        for i in prepayment_invoices_org
        loop
            l_prepay_amount_remaining:=0;
            l_prepay_amount_remaining:=
            AP_INVOICES_UTILITY_PKG.get_prepay_amount_remaining(i.invoice_id);
            if(l_prepay_amount_remaining>0 ) then
                prepay_count:=prepay_count+1;
            end if;
        end loop;
	end if;

    /* Bug 9128633 End */

    return(prepay_count);

END get_total_prepays;


FUNCTION get_available_prepays(
          l_vendor_id    IN NUMBER,
          l_org_id       IN NUMBER)
RETURN NUMBER
IS
  prepay_count           NUMBER := 0;
  l_prepay_amount_remaining NUMBER:=0;

  /*Bug 6841613
    Replaced the existing logic with a cursor defined for the same
    which just selects the prepayment invoices for the vendor.This
    is done for performance overheads.The comparison of earliest
    settlement date would be done with the cursor variable,also the
    earlier select statement which would call the get_total_prepays
    as a filter is removed and logic is implemented here as this
    would reduce the wait time*/
   CURSOR prepayment_invoices IS
    SELECT earliest_settlement_date,invoice_id
      from ap_invoices
     where vendor_id=l_vendor_id
       and invoice_type_lookup_code='PREPAYMENT'
       /*bug 7015402*/
       and payment_status_flag = 'Y'
       and earliest_settlement_date is not null
       AND ((l_org_id is not null and  org_id = l_org_id) or l_org_id is null);
BEGIN

  -- This Function returns the number of available prepayments to a vendor
  -- which can be applied. We've declared a server-side function that can be
  -- accessed from our invoices view so as to improve performance when
  -- retrieving invoices in the Invoice Gateway.
   for i in prepayment_invoices
         loop
          if(i.earliest_settlement_date<=(sysdate)) then
             l_prepay_amount_remaining:=0;
             l_prepay_amount_remaining:=
             AP_INVOICES_UTILITY_PKG.get_prepay_amount_remaining(i.invoice_id);
             if(l_prepay_amount_remaining>0 ) then
                    prepay_count:=prepay_count+1;
             end if;
          end if;
         end loop;

  RETURN(prepay_count);

END get_available_prepays;


FUNCTION get_prepay_amount_applied (P_invoice_id IN number)
RETURN number
IS
  l_prepay_amount         number := 0;
  l_inv_type_lookup_code  varchar2(30);

  CURSOR prepay_cursor is
  SELECT SUM(total_dist_amount -
         NVL(prepay_amount_remaining, total_dist_amount))
    FROM ap_invoice_distributions_all aid,
         ap_invoice_lines_all ail
   WHERE aid.invoice_id = P_invoice_id
     AND aid.invoice_id = ail.invoice_id
     AND aid.invoice_line_number = ail.line_number
     AND ail.line_type_lookup_code <> 'TAX'
     AND aid.line_type_lookup_code IN
         ('ITEM', 'ACCRUAL', 'REC_TAX', 'NONREC_TAX')
     -- No need to include variances since the total_dist_amount
     -- includes the variances total and it is store in the
     -- nonrec tax distribution.
     AND NVL(reversal_flag,'N') <> 'Y';

  CURSOR inv_prepay_cursor is
  SELECT ABS(SUM(amount))
    FROM ap_invoice_lines_all ail
   WHERE ail.invoice_id = P_invoice_id
     AND ail.line_type_lookup_code = 'PREPAY';

BEGIN

  --  Returns the sum of the applied prepayment amounts for a given
  --  prepayment or standard invoice.
  --  Inclusive tax amount are included, exclusive are not.

  SELECT ai.invoice_type_lookup_code
    INTO  l_inv_type_lookup_code
    FROM ap_invoices ai
   WHERE ai.invoice_id = P_invoice_id;

  IF (l_inv_type_lookup_code = 'PREPAYMENT') THEN
    OPEN prepay_cursor;
    FETCH prepay_cursor INTO l_prepay_amount;
    CLOSE prepay_cursor;
  ELSE
    OPEN inv_prepay_cursor;
    FETCH inv_prepay_cursor INTO l_prepay_amount;
    CLOSE inv_prepay_cursor;
  END IF;

RETURN (l_prepay_amount);

END get_prepay_amount_applied;


FUNCTION get_prepay_amount_remaining (P_invoice_id IN number)
RETURN number
IS
  l_prepay_amount_remaining NUMBER := 0;

  -- Inclusive tax will be included in the prepay_amount_remaining
  -- exclusive tax will not.
  CURSOR c_prepay_amount_remaining IS
  SELECT SUM(nvl(prepay_amount_remaining, total_dist_amount))
    FROM ap_invoice_distributions_all aid,
         ap_invoice_lines_all ail
   WHERE aid.invoice_id = P_invoice_id
     AND aid.invoice_id = ail.invoice_id
     AND aid.invoice_line_number = ail.line_number
     AND ail.line_type_lookup_code <> 'TAX'
     -- We will only get REC_TAX and NONREC_TAX dist for the
     -- inclusive case (parent line is not TAX)
     AND NVL(ail.line_selected_for_appl_flag, 'N') <> 'Y'
     AND aid.line_type_lookup_code IN
         ('ITEM', 'ACCRUAL', 'REC_TAX', 'NONREC_TAX')
     -- there is no need to include the tax variance distr
     -- here since the prepay_amount_remaining and the
     -- total_dist_amount will be including them and it will
     -- be stored at the primary nonrec tax dist.
     AND nvl(aid.reversal_flag,'N') <> 'Y';

BEGIN

  -- Returns the sum of the unapplied prepayment amounts for a given
  -- prepayment

  OPEN c_prepay_amount_remaining;
  FETCH c_prepay_amount_remaining INTO l_prepay_amount_remaining;
  CLOSE c_prepay_amount_remaining;

  RETURN(l_prepay_amount_remaining);

END get_prepay_amount_remaining;


FUNCTION get_prepayments_applied_flag (P_invoice_id IN number)
RETURN varchar2
IS
  l_flag varchar2(1) := 'N';
BEGIN

  -- Returns 'Y' if an invoice has prepayments applied to it

  IF ( sign (AP_PREPAY_UTILS_PKG.get_prepay_amount_applied(
             P_invoice_id)) = 1 ) THEN
    l_flag := 'Y';
  ELSE
    l_flag := null;
  END IF;

  RETURN (l_flag);

END get_prepayments_applied_flag;


FUNCTION get_prepayment_type (P_invoice_id IN number)
RETURN varchar2
IS
  l_prepayment_type VARCHAR2(9);

  CURSOR c_prepayment_type IS
  SELECT decode(AI.EARLIEST_SETTLEMENT_DATE,null,'PERMANENT','TEMPORARY')
    FROM ap_invoices_all ai
   WHERE ai.invoice_id = P_invoice_id;
BEGIN

  --  Returns whether prepayment is of type "PERMANENT' which cannot be
  --  applied or 'TEMPORARY' which can be applied.

  OPEN c_prepayment_type;
  FETCH c_prepayment_type INTO l_prepayment_type;
  CLOSE c_prepayment_type;

  RETURN(l_prepayment_type);

END get_prepayment_type;


FUNCTION get_pp_amt_applied_on_date (
          P_invoice_id       IN NUMBER,
          P_prepay_id        IN NUMBER,
          P_application_date IN DATE)
RETURN number
IS
  l_prepay_amt_applied NUMBER := 0;

BEGIN

  -- This Function returns the sum of the applied prepayment amounts to
  -- an invoice by a prepayment for a given date.
  -- Tax inclusive amounts included, exclusive amounts are not.
  -- This query is called from the Prepayment Remittance Notice
  -- and it is required to show the applied amount at the rate of the
  -- prepayment in the case there is a difference in the tax rate or
  -- tax recovery rate

  SELECT SUM((NVL(aid1.amount, 0) - NVL(aid1.prepay_tax_diff_amount, 0))* -1)
    INTO l_prepay_amt_applied
    FROM ap_invoice_distributions_all aid1,
         ap_invoice_distributions_all aid2,
         ap_invoice_lines_all ail
   WHERE aid1.invoice_id = P_invoice_id
     AND aid1.line_type_lookup_code IN ('PREPAY', 'REC_TAX', 'NONREC_TAX')
     AND aid1.invoice_id = ail.invoice_id
     AND aid1.invoice_line_number = ail.line_number
     AND ail.line_type_lookup_code = 'PREPAY'
     AND aid1.prepay_distribution_id = aid2.invoice_distribution_id
     AND aid2.invoice_id = P_prepay_id
     AND aid2.last_update_date = P_application_date ;

  RETURN (l_prepay_amt_applied);

END get_pp_amt_applied_on_date;


FUNCTION get_amt_applied_per_prepay (
          P_invoice_id          IN NUMBER,
          P_prepay_id           IN NUMBER)
RETURN number
IS
  l_prepay_amt_applied NUMBER := 0;

BEGIN

  -- This Function returns the sum of the applied prepayment amounts to
  -- an invoice by a prepayment. This has been added to do not use a
  -- new select statement in the expense report import program.
  -- eTax Uptake.  Change this select to get the pp applied amt from the
  -- lines table, not the distributions
  -- Tax: inclusive included, exclusive is not.

  SELECT SUM(ail.amount * -1)
    INTO l_prepay_amt_applied
    FROM ap_invoice_lines_all ail
   WHERE ail.invoice_id = P_invoice_id
     AND ail.line_type_lookup_code = 'PREPAY'
     AND ail.prepay_invoice_id = P_prepay_id;

  RETURN (l_prepay_amt_applied);

END get_amt_applied_per_prepay;

-- Check this should be obsoleted , because we have obsoleted the
-- stop_prepay_across_bal_seg option as a part of this project.

PROCEDURE Get_Prepay_Amount_Available(
          X_Invoice_ID                   IN      NUMBER,
          X_Prepay_ID                    IN      NUMBER,
          X_Sob_Id                       IN      NUMBER,
          X_Balancing_Segment            OUT NOCOPY     VARCHAR2,
          X_Prepay_Amount                OUT NOCOPY     NUMBER,
          X_Invoice_Amount               OUT NOCOPY     NUMBER) IS

  l_prepay_amount         NUMBER;
  l_invoice_amount        NUMBER;
  l_bal_segment           VARCHAR2(30);

  CURSOR c_prepay_dist IS
  SELECT sum(nvl(prepay_amount_remaining,total_dist_amount)),
         AP_INVOICE_DISTRIBUTIONS_PKG.get_balancing_segment_value(
         aip.dist_code_combination_id, X_Sob_Id)
    FROM ap_invoice_distributions aip
   WHERE aip.invoice_id = X_Prepay_Id
     AND aip.line_type_lookup_code IN ('ITEM', 'ACCRUAL')
     AND nvl(aip.reversal_flag,'N') <> 'Y'
     AND nvl(aip.prepay_amount_remaining,amount) > 0
     AND AP_INVOICE_DISTRIBUTIONS_PKG.get_balancing_segment_value(
         aip.dist_code_combination_id, X_Sob_Id) IN
             (SELECT AP_INVOICE_DISTRIBUTIONS_PKG.get_balancing_segment_value(
                     aid.dist_code_combination_id, X_Sob_Id)
                FROM ap_invoice_distributions aid
               WHERE aid.invoice_id = X_Invoice_ID)
   GROUP BY AP_INVOICE_DISTRIBUTIONS_PKG.get_balancing_segment_value(
            aip.dist_code_combination_id, X_Sob_Id)
   ORDER BY AP_INVOICE_DISTRIBUTIONS_PKG.get_balancing_segment_value(
            aip.dist_code_combination_id, X_Sob_Id);

BEGIN

  -- Procedure to get the sum of distribution amount for a given invoice
  -- and the sum of the distribution amount for a given prepayment

  OPEN c_prepay_dist;
  LOOP
    FETCH c_prepay_dist into l_prepay_amount, l_bal_segment;
    EXIT WHEN c_prepay_dist%NOTFOUND;

    SELECT sum(amount)
      INTO l_invoice_amount
      FROM ap_invoice_distributions
     WHERE invoice_id = X_Invoice_ID
       AND line_type_lookup_code IN ('ITEM','PREPAY')
       AND nvl(reversal_flag,'N') <> 'Y'
       AND AP_INVOICE_DISTRIBUTIONS_PKG.get_balancing_segment_value(
           dist_code_combination_id, X_Sob_Id)
                   = l_bal_segment;

  IF l_invoice_amount <> 0 THEN
     EXIT;
  END IF;

  END LOOP;
  CLOSE c_prepay_dist;

  X_Balancing_Segment := l_bal_segment;
  X_Prepay_Amount     := l_prepay_amount;
  X_Invoice_Amount    := l_invoice_amount;

END Get_Prepay_Amount_Available;

-- This function returns the remaining amount for an
-- ITEM line of the prepayment invoice not including tax
FUNCTION Get_Ln_Pp_AMT_Remaining_No_Tax(
          P_invoice_id    IN NUMBER,
          P_line_number   IN NUMBER) RETURN NUMBER
IS
  l_prepay_amount_remaining NUMBER := 0;

BEGIN
  SELECT   SUM(nvl(prepay_amount_remaining,total_dist_amount))
    INTO   l_prepay_amount_remaining
    FROM   ap_invoice_distributions_all
   WHERE   invoice_id              = p_invoice_id
     AND   invoice_line_number     = p_line_number
     AND   line_type_lookup_code IN ('ITEM', 'ACCRUAL')
     AND   NVL(reversal_flag,'N')  <> 'Y';

RETURN (l_prepay_amount_remaining);

EXCEPTION
  WHEN OTHERS THEN
    RETURN (l_prepay_amount_remaining);

END Get_Ln_Pp_AMT_Remaining_No_Tax;

-- This function will return the remaining amount
-- of inclusive tax for an ITEM line of a prepayment
-- invoice
FUNCTION Get_Inc_Tax_Pp_Amt_Remaining (
          P_invoice_id    IN NUMBER,
          P_line_number   IN NUMBER) RETURN NUMBER
IS
  l_prepay_amount_remaining NUMBER := 0;

BEGIN
  SELECT   SUM(nvl(prepay_amount_remaining, total_dist_amount))
    INTO   l_prepay_amount_remaining
    FROM   ap_invoice_distributions_all
   WHERE   invoice_id              = p_invoice_id
     AND   invoice_line_number     = p_line_number
     AND   line_type_lookup_code IN ('REC_TAX', 'NONREC_TAX',
                                     'TIPV', 'TRV')
     AND   NVL(reversal_flag,'N')  <> 'Y';

RETURN (l_prepay_amount_remaining);

EXCEPTION
  WHEN OTHERS THEN
    RETURN (l_prepay_amount_remaining);

END Get_Inc_Tax_Pp_Amt_Remaining;

-- This function will return the exclusive tax
-- amount resulting from a prepayment application
FUNCTION Get_Exc_Tax_Amt_Applied (
          X_Invoice_Id          IN NUMBER,
          X_prepay_invoice_id   IN NUMBER,
          X_prepay_Line_Number  IN NUMBER) RETURN NUMBER
IS
  l_exclusive_tax_amt_applied NUMBER := 0;

BEGIN
  SELECT SUM(NVL(ail.amount, 0))
    INTO l_exclusive_tax_amt_applied
    FROM ap_invoice_lines_all ail
   WHERE ail.invoice_id = X_invoice_id
     AND ail.line_type_lookup_code = 'TAX'
     AND NVL(ail.discarded_flag, 'N')  <> 'Y'
     AND NVL(ail.cancelled_flag, 'N') <> 'Y'
     AND ail.prepay_invoice_id = X_prepay_invoice_id
     AND ail.prepay_line_number = X_prepay_Line_Number;

RETURN (l_exclusive_tax_amt_applied);

EXCEPTION
  WHEN OTHERS THEN
    RETURN (l_exclusive_tax_amt_applied);

END Get_Exc_Tax_Amt_Applied;

-- This function will return the total of the invoice
-- unpaid amount not including exclusive taxes

FUNCTION Get_Invoice_Unpaid_Amount(
		  X_Invoice_Id            IN NUMBER) RETURN NUMBER
IS
  l_invoice_unpaid_amount         NUMBER := 0;
  l_inv_payment_status            AP_INVOICES_ALL.payment_status_flag%TYPE;
  l_invoice_currency_code         AP_INVOICES_ALL.invoice_currency_code%TYPE;
  l_payment_currency_code         AP_INVOICES_ALL.payment_currency_code%TYPE;
  l_payment_cross_rate_date       AP_INVOICES_ALL.payment_cross_rate_date%TYPE;
  l_payment_cross_rate_type       AP_INVOICES_ALL.payment_cross_rate_type%TYPE;
  l_invoice_total                 AP_INVOICES_ALL.invoice_amount%TYPE;
  l_lines_total_no_exc_tax        NUMBER := 0;
  l_unpaid_amount NUMBER := 0;

CURSOR c_invoice_info IS
SELECT ai.payment_status_flag,
  ai.invoice_currency_code,
  ai.payment_currency_code,
  ai.payment_cross_rate_date,
  ai.payment_cross_rate_type,
  NVL(ai.invoice_amount,   0)
FROM ap_invoices_all ai
WHERE ai.invoice_id =  X_Invoice_Id;

/* Commented for bug 7506584
  CURSOR c_invoice_lines_info IS
  SELECT NVL(SUM(NVL(ail.amount,0)), 0)
    FROM ap_invoice_lines_all ail
   WHERE ail.invoice_id = X_Invoice_Id
     AND ail.line_type_lookup_code <> 'TAX'
     AND (ail.line_type_lookup_code <> 'PREPAY'
          OR NVL(ail.invoice_includes_prepay_flag,'N') = 'Y'); */
 --7506584
l_non_tax_lines NUMBER := 0;
l_tax_lines NUMBER := 0;
l_tax_prorated NUMBER := 0;
l_prep_applied NUMBER := 0;
l_item_lines_proration NUMBER := 0;
l_tax_lines_proration NUMBER := 0;
l_sum_checks_payment NUMBER := 0;
l_awt_lines NUMBER := 0;

BEGIN
  -- Get invoice info

  OPEN c_invoice_info;
  FETCH c_invoice_info INTO
    l_inv_payment_status,
    l_invoice_currency_code,
    l_payment_currency_code,
    l_payment_cross_rate_date,
    l_payment_cross_rate_type,
    l_invoice_total;

  IF(c_invoice_info % NOTFOUND) THEN
    CLOSE c_invoice_info;
    RAISE NO_DATA_FOUND;
  END IF;

  CLOSE c_invoice_info;

  --bug 7506584 starts
  SELECT SUM(nvl(aps.amount_remaining,   0))
  INTO l_unpaid_amount
  FROM ap_payment_schedules_all aps
  WHERE aps.invoice_id = x_invoice_id;

  SELECT SUM(decode(line_type_lookup_code,   'TAX',   nvl(ail.amount,   0),   0)) l_tax_lines,
    SUM(decode(line_type_lookup_code,   'TAX',   0,   nvl(ail.amount,   0))) l_non_tax_lines,
    SUM(decode(line_type_lookup_code,   'PREPAY',   nvl(ail.amount,   0),   0)) l_prep_applied,
    SUM(decode(line_type_lookup_code,   'AWT',   nvl(ail.amount,   0),   0)) l_awt_lines
  INTO l_tax_lines,
       l_non_tax_lines,
       l_prep_applied,
       l_awt_lines
  FROM ap_invoice_lines_all ail
  WHERE ail.invoice_id = x_invoice_id;

  SELECT nvl(SUM(nvl(amount,   0)),   0)
  INTO l_item_lines_proration
  FROM ap_invoice_lines_all ail
  WHERE ail.invoice_id = x_invoice_id
   AND ail.line_type_lookup_code <> 'TAX'
   AND(ail.line_type_lookup_code <> 'PREPAY' OR nvl(ail.invoice_includes_prepay_flag,   'N') = 'Y');

  SELECT nvl(SUM(nvl(amount,   0)),   0)
  INTO l_tax_lines_proration
  FROM ap_invoice_lines_all ail
  WHERE ail.invoice_id = x_invoice_id
   AND ail.line_type_lookup_code = 'TAX'
   AND ail.amount > 0;

   l_tax_lines_proration := ap_utilities_pkg.ap_round_currency(l_tax_lines_proration,   l_invoice_currency_code);

  --payments made by check
  SELECT nvl(SUM(amount),   0)
  INTO l_sum_checks_payment
  FROM ap_invoice_payments_all
  WHERE invoice_id = x_invoice_id;

  --Commented for bug8921145
  /*IF(l_inv_payment_status = 'N') THEN*/

    IF(l_tax_lines = 0) THEN
      l_invoice_unpaid_amount := l_unpaid_amount;

    ELSE

      IF(l_unpaid_amount -l_tax_lines = l_non_tax_lines) THEN
        l_invoice_unpaid_amount := l_non_tax_lines;

      ELSE
        --prorate tax
        l_tax_prorated :=(l_invoice_total *l_tax_lines_proration) /(l_item_lines_proration + l_tax_lines_proration);
        l_tax_prorated := ap_utilities_pkg.ap_round_currency(l_tax_prorated,   l_invoice_currency_code);
        l_invoice_unpaid_amount := l_invoice_total -l_tax_prorated + l_prep_applied -l_sum_checks_payment + l_awt_lines;

      END IF;

    END IF;
  --Commented ELSE block for bug8921145
  /*ELSE
    -- Invoice has any partial payment

    l_tax_prorated :=(l_invoice_total *l_tax_lines_proration) /(l_item_lines_proration + l_tax_lines_proration);
    l_tax_prorated := ap_utilities_pkg.ap_round_currency(l_tax_prorated,   l_invoice_currency_code);
    l_invoice_unpaid_amount := l_invoice_total -l_tax_prorated + l_prep_applied -l_sum_checks_payment + l_awt_lines;

  END IF; */
  --End of bug8921145
  --bug 7506584 ends

  /* Commented for bug 7506584

  --Bugfix:4554256, moved the cursor code from within the IF
  --condition, to here, since l_lines_total_no_exc_tax
  --is used both by IF and ELSE condition.
  OPEN c_invoice_lines_info;
  FETCH c_invoice_lines_info INTO l_lines_total_no_exc_tax;
  CLOSE c_invoice_lines_info;

  IF (l_inv_payment_status = 'N' ) THEN
    -- This invoice has not been paid.
    -- The unpaid amount is the total of lines
    -- not including TAX lines
    -- If no tax lines exist, the unpaid amount will be the
    -- invoice total.  The select will return 0 in the case
    -- there are no lines

    IF (l_lines_total_no_exc_tax = 0) THEN
      l_invoice_unpaid_amount := l_invoice_total;

    ELSE
      l_invoice_unpaid_amount := l_lines_total_no_exc_tax;
    END IF;

  ELSE
    -- Invoice has any partial payment

    SELECT SUM(NVL(aps.amount_remaining, 0))
      INTO l_unpaid_amount
      FROM ap_payment_schedules_all aps
     WHERE aps.invoice_id = X_Invoice_Id;

    -- If the invoice and payment currencies are different
    -- we need to convert to the invoice currency the amount
    -- from payment schedules
    IF (l_invoice_currency_code <> l_payment_currency_code) THEN
      l_unpaid_amount := gl_currency_api.convert_amount(
                           l_payment_currency_code,
                           l_invoice_currency_code,
                           l_payment_cross_rate_date,
                           l_payment_cross_rate_type,
                           l_unpaid_amount);

    END IF;

    -- get the rounded proportion of the unpaid amount exclusive
    -- of tax from the total unpaid amount
    l_invoice_unpaid_amount := AP_Utilities_PKG.AP_Round_Currency (
                                 l_lines_total_no_exc_tax*l_unpaid_amount/l_invoice_total,
                                 l_invoice_currency_code);

  END IF;
Commented for bug 7506584 */
RETURN(l_invoice_unpaid_amount);

EXCEPTION
WHEN OTHERS THEN
  RETURN(l_invoice_unpaid_amount);

END Get_Invoice_Unpaid_Amount;


-- This function will return the total of the invoice
-- unpaid amount including exclusive taxes, added for
-- bug 6149363

FUNCTION Get_Inv_Tot_Unpaid_Amt(
	 X_Invoice_Id IN NUMBER) 	RETURN NUMBER
 IS
  l_invoice_unpaid_amount         NUMBER := 0;
  l_inv_payment_status            AP_INVOICES_ALL.payment_status_flag%TYPE;
  l_invoice_currency_code         AP_INVOICES_ALL.invoice_currency_code%TYPE;
  l_payment_currency_code         AP_INVOICES_ALL.payment_currency_code%TYPE;
  l_payment_cross_rate_date       AP_INVOICES_ALL.payment_cross_rate_date%TYPE;
  l_payment_cross_rate_type       AP_INVOICES_ALL.payment_cross_rate_type%TYPE;
  l_invoice_total                 AP_INVOICES_ALL.invoice_amount%TYPE;
  l_lines_total_with_exc_tax      NUMBER := 0;
  l_unpaid_amount                 NUMBER := 0;

CURSOR c_invoice_info IS
SELECT ai.payment_status_flag,
  ai.invoice_currency_code,
  ai.payment_currency_code,
  ai.payment_cross_rate_date,
  ai.payment_cross_rate_type,
  NVL(ai.invoice_amount,   0)
FROM ap_invoices_all ai
WHERE ai.invoice_id = X_Invoice_Id;

/* Commented for bug 7506584
  CURSOR c_invoice_lines_info IS
  SELECT NVL(SUM(NVL(ail.amount,0)), 0)
    FROM ap_invoice_lines_all ail
   WHERE ail.invoice_id = X_Invoice_Id
     AND (ail.line_type_lookup_code <> 'PREPAY'
          OR NVL(ail.invoice_includes_prepay_flag,'N') = 'Y');

	  */

BEGIN
  -- Get invoice info

  OPEN c_invoice_info;
  FETCH c_invoice_info INTO
    l_inv_payment_status,
    l_invoice_currency_code,
    l_payment_currency_code,
    l_payment_cross_rate_date,
    l_payment_cross_rate_type,
    l_invoice_total;

  IF(c_invoice_info % NOTFOUND) THEN
    CLOSE c_invoice_info;
    RAISE NO_DATA_FOUND;
  END IF;

  CLOSE c_invoice_info;

  /* Commented for bug 7506584
  --Bugfix:4554256, moved the cursor code from within the IF
  --condition, to here, since l_lines_total_with_exc_tax
  --is used both by IF and ELSE condition.
  OPEN c_invoice_lines_info;
  FETCH c_invoice_lines_info INTO l_lines_total_with_exc_tax;
  CLOSE c_invoice_lines_info;

  IF (l_inv_payment_status = 'N' ) THEN
    -- This invoice has not been paid.
    -- The unpaid amount is the total of lines
    -- not including TAX lines
    -- If no tax lines exist, the unpaid amount will be the
    -- invoice total.  The select will return 0 in the case
    -- there are no lines

    IF (l_lines_total_with_exc_tax = 0) THEN
      l_invoice_unpaid_amount := l_invoice_total;

    ELSE
      l_invoice_unpaid_amount := l_lines_total_with_exc_tax;
    END IF;

  ELSE
    -- Invoice has any partial payment
*/

  SELECT SUM(nvl(aps.amount_remaining,   0))
  INTO l_unpaid_amount
  FROM ap_payment_schedules_all aps
  WHERE aps.invoice_id = x_invoice_id;

  -- If the invoice and payment currencies are different
  -- we need to convert to the invoice currency the amount
  -- from payment schedules

  IF(l_invoice_currency_code <> l_payment_currency_code) THEN
    l_unpaid_amount := gl_currency_api.convert_amount(
					l_payment_currency_code,
					l_invoice_currency_code,
					l_payment_cross_rate_date,
				      l_payment_cross_rate_type,
					l_unpaid_amount);

  END IF;

  -- get the rounded proportion of the unpaid amount exclusive
  -- of tax from the total unpaid amount

  /*Commented for bug 7506584
l_invoice_unpaid_amount := AP_Utilities_PKG.AP_Round_Currency (
                                 l_lines_total_with_exc_tax*l_unpaid_amount/l_invoice_total,
                                 l_invoice_currency_code);
*/
  l_invoice_unpaid_amount := ap_utilities_pkg.ap_round_currency(l_unpaid_amount,   l_invoice_currency_code);

--END IF;

RETURN(l_invoice_unpaid_amount);

EXCEPTION
WHEN OTHERS THEN
RETURN(l_invoice_unpaid_amount);

END Get_Inv_Tot_Unpaid_Amt;


-- This function will return the total of the inclusive invoice
-- unpaid amount

FUNCTION Get_Inclusive_Tax_Unpaid_Amt (
          X_Invoice_Id          IN NUMBER) RETURN NUMBER
IS
  l_inclusive_unpaid_amount       NUMBER := 0;
  l_inv_payment_status            AP_INVOICES_ALL.payment_status_flag%TYPE;
  l_invoice_currency_code         AP_INVOICES_ALL.invoice_currency_code%TYPE;
  l_payment_currency_code         AP_INVOICES_ALL.payment_currency_code%TYPE;
  l_payment_cross_rate_date       AP_INVOICES_ALL.payment_cross_rate_date%TYPE;
  l_payment_cross_rate_type       AP_INVOICES_ALL.payment_cross_rate_type%TYPE;
  l_invoice_total                 AP_INVOICES_ALL.invoice_amount%TYPE;
  l_inclusive_tax_total_lines     NUMBER := 0;

  l_unpaid_amount                 NUMBER := 0;

  CURSOR c_invoice_info IS
  SELECT ai.payment_status_flag ,
         ai.invoice_currency_code,
         ai.payment_currency_code,
         ai.payment_cross_rate_date,
         ai.payment_cross_rate_type,
         NVL(ai.invoice_amount, 0)
    FROM ap_invoices_all ai
   WHERE ai.invoice_id = X_Invoice_Id;

  CURSOR c_invoice_lines_info IS
  SELECT NVL(SUM(NVL(ail.included_tax_amount,0)), 0)
    FROM ap_invoice_lines_all ail
   WHERE ail.invoice_id = X_Invoice_Id
     AND (ail.line_type_lookup_code <> 'PREPAY'
          OR NVL(ail.invoice_includes_prepay_flag,'N') = 'Y');

BEGIN

  -- Get invoice info
  OPEN c_invoice_info;
  FETCH c_invoice_info INTO
         l_inv_payment_status,
         l_invoice_currency_code,
         l_payment_currency_code,
         l_payment_cross_rate_date,
         l_payment_cross_rate_type,
         l_invoice_total;

  IF (c_invoice_info%NOTFOUND) THEN
    CLOSE c_invoice_info;
    RAISE NO_DATA_FOUND;

  END IF;
  CLOSE c_invoice_info;

  IF (l_inv_payment_status = 'N' ) THEN
    -- This invoice has not been paid.
    -- The inclusive tax unpaid amount is the sum of included_tax_amount from
    -- the invoice lines.  If tax has not been calculated yet, the included amt
    -- should be 0

    OPEN c_invoice_lines_info;
    FETCH c_invoice_lines_info INTO l_inclusive_tax_total_lines;
    CLOSE c_invoice_lines_info;

    l_inclusive_unpaid_amount := l_inclusive_tax_total_lines;

  ELSE
    -- Invoice has any partial payment

    SELECT SUM(NVL(aps.amount_remaining, 0))
      INTO l_unpaid_amount
      FROM ap_payment_schedules aps
     WHERE aps.invoice_id = X_Invoice_Id;

    -- If the invoice and payment currencies are different
    -- we need to convert to the invoice currency the amount
    -- from payment schedules
    IF (l_invoice_currency_code <> l_payment_currency_code) THEN
      l_unpaid_amount := gl_currency_api.convert_amount(
                           l_payment_currency_code,
                           l_invoice_currency_code,
                           l_payment_cross_rate_date,
                           l_payment_cross_rate_type,
                           l_unpaid_amount);

    END IF;

    -- get the proportion of the unpaid amount exclusive of tax from the
    -- total unpaid amount
    l_inclusive_unpaid_amount := AP_Utilities_PKG.AP_Round_Currency (
                                   l_inclusive_tax_total_lines*l_unpaid_amount/l_invoice_total,
                                   l_invoice_currency_code);


  END IF;

RETURN (l_inclusive_unpaid_amount);

EXCEPTION
  WHEN OTHERS THEN
    RETURN (l_inclusive_unpaid_amount);

END Get_Inclusive_Tax_Unpaid_Amt;

-- This function will return the total of the remaining
-- inclusive tax amount for a distribution
FUNCTION Get_Dist_Inclusive_Tax_Amt (
          X_Invoice_Id               IN NUMBER,
          X_Line_Number              IN NUMBER,
          X_Invoice_Dist_Id          IN NUMBER) RETURN NUMBER

IS
  l_remaining_inc_tax_dist  NUMBER := 0;

BEGIN
  SELECT NVL(SUM(NVL(prepay_amount_remaining, total_dist_amount)), 0)
    INTO l_remaining_inc_tax_dist
    FROM ap_invoice_distributions_all
   WHERE invoice_id = X_Invoice_Id
     AND invoice_line_number = X_Line_Number
     AND charge_applicable_to_dist_id = X_Invoice_Dist_Id
     AND line_type_lookup_code IN ('REC_TAX', 'NONREC_TAX')
     AND NVL(reversal_flag,'N')  <> 'Y';
     -- the total_dist_amount is store only in the primary distribution
     -- for prepayment invoices that means ITEM and NONREC TAX dist

RETURN (l_remaining_inc_tax_dist);

EXCEPTION
  WHEN OTHERS THEN
    RETURN (l_remaining_inc_tax_dist);

END Get_Dist_Inclusive_Tax_Amt;

--Bug 8638881 begin
--This function will return the invoice_includes_prepay_flag of
--the applied prepayment line on standard invoice
FUNCTION Get_pp_appl_inv_incl_pp_flag(
           X_Invoice_Id   IN NUMBER,
	   X_prepay_invoice_id   IN NUMBER,
           X_prepay_Line_Number  IN NUMBER DEFAULT NULL) RETURN VARCHAR2
IS
 l_inv_incl_pp_flag ap_invoice_lines_all.invoice_includes_prepay_flag%type;

BEGIN

 Select case
         when exists
          (select 1
                 From ap_invoice_lines_all ail
                where ail.invoice_id = X_Invoice_Id
                  and ail.line_type_lookup_code = 'PREPAY'
                  and ail.prepay_invoice_id = X_prepay_invoice_id
                  and ail.prepay_line_number = nvl(X_prepay_Line_Number,ail.prepay_line_number)
                  and (ail.discarded_flag is null or ail.discarded_flag = 'N')
                  and nvl(ail.invoice_includes_prepay_flag, 'N') = 'Y'
		  and exists (select 'Prepay line dists amt remg exists'
		               from ap_invoice_distributions_all aid
			       where aid.invoice_id = ail.prepay_invoice_id
			        and aid.invoice_line_number = ail.prepay_line_number
				and aid.prepay_amount_remaining > 0)) Then
          'Y'
         when exists
          (select 1
                 From ap_invoice_lines_all ail
                where ail.invoice_id = X_Invoice_Id
                  and ail.line_type_lookup_code = 'PREPAY'
                  and ail.prepay_invoice_id = X_prepay_invoice_id
                  and ail.prepay_line_number = nvl(X_prepay_Line_Number,ail.prepay_line_number)
                  and (ail.discarded_flag is null or ail.discarded_flag = 'N')
                  and nvl(ail.invoice_includes_prepay_flag, 'N') = 'N') then
          'N'
         else
          'X'
       end "INVOICE_INCLUDES_PREPAY_FLAG"
     INTO l_inv_incl_pp_flag
  from dual;

  Return l_inv_incl_pp_flag;

EXCEPTION
  WHEN OTHERS THEN
    RETURN (NULL);

END Get_pp_appl_inv_incl_pp_flag; --Bug 8638881 end

END AP_PREPAY_UTILS_PKG;

/
