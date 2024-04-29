--------------------------------------------------------
--  DDL for Package Body JAI_CMN_RGM_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_RGM_PROCESSING_PKG" AS
/* $Header: jai_cmn_rgm_prc.plb 120.27.12010000.18 2010/06/03 09:26:08 haoyang ship $ */

  /*  */
  /*----------------------------------------------------------------------------------------------------------------------------
  CHANGE HISTORY for FILENAME: jai_rgm_trx_processing_pkg_b.sql
  S.No  dd/mm/yyyy   Author and Details
  ------------------------------------------------------------------------------------------------------------------------------
  1     26/07/2004   Vijay Shankar for Bug# 4068823, Version:115.0

                Basic Package that Starts Service Tax Processing of both AP and AR transactions based on the inputs
                provided through request of "India - Service Tax Processing" concurrent

                - PROCESS_BATCH - this procedure is invoked from the request submitted by users through JAISRVTP concurrent
                This picksup all the Operating Units that are linked to the given Service Tax registration number and
                invokes AP Processor and AR Processor for their respective processing

                - INSERT_REQUEST_DETAILS : inserts a record into batch header with input details
                - GET_ITEM_LINE_ID       : fetches ITEM Invoice Distribution of TAX invoice distribution incase of AP transactions

                - PROCESS_PAYMENT        : records the recovered service tax into repository to the tune of payment amount
                w.r.t invoice amount and service tax distribution amount. this has all the required functional logic related
                to Payment reversals and apportioning of Service Tax if multiple payments exists for same invoice etc.

                - PROCESS_PAYMENTS       : This is the AP Processor that picks up all the eligible Payments(includes prepayments
                also) and invokes process_payment for each payment

2    19/03/2005   Vijay Shankar for Bug#4250236(4245089). FileVersion: 115.1
                    removed the usage of regime effective_date_from and replace it with regime creation_date as part of VAT Impl.
                    This is required as effective dates are removed Regime setup

3     12/04/2005  Brathod, for Bug# 4286646, Version 115.2
                  Issue :-
                    Because of change in Valueset from JA_IN_DATE to FND_STANDARD_DATE Concurrent was resulting
                    in error because JA_IN_DATE uses normal date format while FND_STANDARD_DATE uses NLS_DATE format
                    and it is passed as character value.
                  Fix :-
                    Procedure signature modified to convert p_trx_from_date, p_trx_from_date from date to
                    pv_trx_from_date, pv_trx_from_date varchar2.  And the varchar2 values are converted back
                    to date fromat using fnd_date.canonical_to_date function.

4.   14/04/2005   ssumaith - bug# 4284505 - File version 115.3

                  Added code to pick the third party taxes from the jai_Rcv_tp_inv_details table in case of
                  third party invoices.

                  This is done by adding code for checking - source in the ap_invoices_all table , if it
                  equals to 'RECEIPT' , getting the third party taxes from the jai_Rcv_tp_inv_Details table.

5.   24/05/2005   Ramananda for bug# 4388958 File Version: 116.1
                  Changed AP Lookup code from 'RECEIPT' to 'INDIA TAX INVOICE'


6. 08-Jun-2005  Version 116.3 jai_cmn_rgm_prc -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
    as required for CASE COMPLAINCE.

7. 14-Jun-2005      rchandan for bug#4428980, Version 116.4
                        Modified the object to remove literals from DML statements and CURSORS.

8. 24-Jan-2006  Bug 4991017. Added by Lakshmi Gopalsami version 120.4
                Merged the cursors c_ap_accounted_invoices and
    c_event_distributions  because of SLA uptake by base
    and removed the same.
    (1) Changed the reference to xla_ae_headers instead
        of ap_ae_headers_all
          (2) Also added xla_transaction_entities to get the entity_id
        and source_int_id_1 so that it can be joined with
        transaction tables.
    (3) Discussed with shekhar and found that we should derive by
        accounting_date and not on the creation_date.
    (4) Added accounting_event_id in cursor
    (5) Added local variable lv_entity_code

  DEPENDANCY:
  -----------
  IN60106  + 4068823 + 4245089

8. 29/07/2005   Aiyer - bug# 4523205 - File version 120.2 - (R12 Forward Porting FROM 11.5 bugs 4348774, 4357984)
                Procedure process has been changed for the bug. Please refer the details in the change history section
                of the procedure.

9. 08-Mar-2006 , Bug 4947102, By Aiyer , File Version 120.5
    Issue:-
      Cursor c_period_payments has high cost of execution.

    Fix:-
      Merged the cursors c_period_payments with c_invoice_distributions into c_period_payments so that the IL table in cursor
      can reduce the overall rows searched by the query.
      SQL-ID as reported in the repository is 14828450.

    Dependency Due to this bug :-
        None

10. 09-JUNE-2007 ,Kunkumar for Bug 6012489 version 12.6
             Added an if condtion for assignment to local variable
             If action is accounting, then generated vat invoice number is picked
11. 05-SEP-2007  CSahoo for bug#5680459, File Version 120.23
     R.TST1203:FORWARD PORTING FROM 115 BUG 5645003
    commented the part where lv_inv_gen_process_flag and lv_inv_gen_process_message
    were getting assigned as NULL.
    replaced the party_id by party_site_id as the second parameter in the call to check_reg_dealer procedure.

12. 04-OCT-2007  CSahoo for bug#6436576, File Version 120.24
     R.TST1203.XB2.QA:SERVICE TAX REVIEW REPOSITORY SHOW MULTIPLE ACCOUNTING LINES
     added the following AND condition in the cursor c_period_payments in process_payments procedure.
     AND      apinvp.invoice_id       = ainvd.invoice_id

13. 13-01-2009 vumaasha for bug 7684820
    INDIA LOCALIZATION: SERVICE TAX RECOVERABLE PORTION IS INCORRECT CALCULATED

14. 17-May-2009 Bug 7522584
                Issue : Service Tax entered in foreign currency for AR Invoice is not converted to Functional Currency
                Fix: Modified the code in the procedure process_payment. Added a cursor c_get_curr_dtls
                to get the currency details. Then multiplied the conversion rate to the tax_amount
                to get the tax amount in functional currency i.e., INR

15. 25-May-2009 Bug 8294236
              Issue: Svc tax transactions created fx balances on tax accounts after settlement
              Fix: Modified the code in the procedure process_payment. Added the call to the procedure
              JAI_RGM_TRX_RECORDING_PKG.exc_gain_loss_accounting.

16.  01-OCT-2009 JMEENA for bug#8943349
        Issue: India Service Tax Processing Concurrent not processing Standalone Invoices
        Fix:   Modified cursor c_tax_dist_dtl and c_period_payments of Procedure Process_payments
            Added code to check if the taxes exists with the standalone invoice. If taxes exists the
            invoices should be picked for the processing.

17.  08-Oct-2009 CSahoo for bug#8965721,
     Issue: TST1212.XB2.QA:SERVICE TAX CREDIT NOT ACCOUNTED FOR GOODS TRANSPORT OPERATORS
     Fix: Modified the cursors c_ap_accounted_inv_dist and c_period_payments. Added a AND condition.

18.  21-Dec-2009 Xiao Lv for Bug#7191302 .
       Issue: Service tax is recovered in excess when prepayment is applied
              with the checkbox "PREPAYMENT ON INVOICE" checked.
       Fix: included a cursor c_total_inv_amount, which fetches the sum of
            total invoice amount eligible for tax recovery.
      For more details please refer to bug.

19.  02-Apr-2010  Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement)
       Issue: currently, procedure 'process' only handles shippable items
       Fix: logic in procedure 'process' should be modified to process both shippable and
            non-shippable lines.
20   18-Apr-2010  Eric Ma remove the non-ASCII Codes in line 2185
21.  28-Apr-2010  Allen Yang for bug 9666476
                  In procedure 'process':
                  1) added 'NULLS FIRST' into Order By clause of sql_stmt_all
                  to ensure shippable items are always processed before non-shippable items.
                  2) removed order_number from Order By clause of sql_stmt_shippable
22.  13-May-2010  Allen Yang for bug 9709477
                  In procedure 'process':
                  1). added warning message when flags Same as Excise and Generate Single Invoice are both Y.
23.  03-Jun-2010  Allen Yang for bug 9737119
                  Issue: TST1213.XB1.QA.EXECPT DIAGNOSTICS,WARNING MESSAGE SHOULD ALSO BE SEEN IN LOG
                  Fix: In procedure 'process', added logic to put message lv_same_as_excise_conf_warning to Log.
---------------------------------------------------------------------------------------------------------------------------*/

  CURSOR c_rgm_repository_id(cp_source IN VARCHAR2, cp_source_table_name IN VARCHAR2,
          cp_source_document_id IN NUMBER, cp_reference_id IN NUMBER) IS
    SELECT  repository_id
    FROM jai_rgm_trx_records
    WHERE source = cp_source
    AND source_table_name = cp_source_table_name
    AND source_document_id = cp_source_document_id
    AND reference_id = cp_reference_id;

  CURSOR c_repo_recovered_amt(cp_source IN VARCHAR2, cp_source_table_name IN VARCHAR2,
          cp_source_document_id IN NUMBER, cp_reference_id IN NUMBER) IS
    SELECT  nvl(credit_amount, debit_amount) amount
    FROM jai_rgm_trx_records
    WHERE source = cp_source
    AND source_table_name = cp_source_table_name
    AND source_document_id = cp_source_document_id
    AND reference_id = cp_reference_id;

  CURSOR c_reference(cp_source IN VARCHAR2, cp_invoice_id IN NUMBER, cp_invoice_distribution_id IN NUMBER) IS
    SELECT  reference_id, parent_reference_id, item_line_id, reversal_flag, nvl(recovered_amount, 0) recovered_amount,
            tax_type, recoverable_amount, nvl(discounted_amount,0) discounted_amount
    FROM jai_rgm_trx_refs
    WHERE source = cp_source
    AND invoice_id = cp_invoice_id
    AND line_id = cp_invoice_distribution_id;

  CURSOR c_reference_using_id(cp_reference_id IN NUMBER) IS
    SELECT  reference_id, parent_reference_id, item_line_id, reversal_flag, recovered_amount, tax_type,
            recoverable_amount
    FROM jai_rgm_trx_refs
    WHERE reference_id = cp_reference_id;

  CURSOR c_invoice_distribution(cp_invoice_distribution_id IN NUMBER) IS
    SELECT  a.invoice_id, a.invoice_distribution_id,
            a.invoice_line_number, /* INVOICE LINES UPTAKE */
            a.distribution_line_number, a.prepay_distribution_id,
            a.amount, a.reversal_flag, a.parent_reversal_id, a.accounting_event_id, a.posted_flag, a.org_id,
            a.accounting_date, b.invoice_amount, b.amount_paid, b.cancelled_date, b.invoice_type_lookup_code invoice_type,
            a.creation_date, a.po_distribution_id
    FROM ap_invoice_distributions_all a, ap_invoices_all b
    WHERE a.invoice_id = b.invoice_id
    AND invoice_distribution_id = cp_invoice_distribution_id;

  CURSOR c_invoice_payment(cp_invoice_payment_id IN NUMBER) IS
    SELECT  a.invoice_payment_id, a.check_id, a.amount, a.payment_base_amount, -- a.reversal_flag, reversal_inv_pmt_id,
            a.org_id, b.status_lookup_code, b.check_date, b.void_date, b.future_pay_due_date,
            a.accounting_date, a.reversal_inv_pmt_id, discount_taken,
      -- Added the following for Bug 8294236
            b.currency_code, b.exchange_rate, b.exchange_date, b.exchange_rate_type
    FROM  ap_invoice_payments_all a, ap_checks_all b
    WHERE a.check_id = b.check_id
    AND   a.invoice_payment_id = cp_invoice_payment_id;

  ---------------------------- GET_ITEM_LINE_ID ---------------------------
  FUNCTION get_item_line_id(
    p_invoice_id              IN  NUMBER,
    p_po_distribution_id      IN  NUMBER,
    p_rcv_transaction_id      IN  NUMBER
  ) RETURN NUMBER IS

    CURSOR c_parent_distribution_id( p_line_type_lookup_code ap_invoice_distributions_all.line_type_lookup_code%TYPE ) IS
      SELECT invoice_distribution_id
      FROM ap_invoice_distributions_all
      WHERE invoice_id = p_invoice_id
      AND (p_rcv_transaction_id IS NULL OR rcv_transaction_id = p_rcv_transaction_id)
      AND po_distribution_id = p_po_distribution_id
      AND line_type_lookup_code = p_line_type_lookup_code--rchandan for bug#4428980
      AND parent_reversal_id IS NULL;   -- CHK

    ln_item_distribution_id   AP_INVOICE_DISTRIBUTIONS_ALL.invoice_distribution_id%TYPE;

  BEGIN

    OPEN c_parent_distribution_id('ITEM');
    FETCH c_parent_distribution_id INTO ln_item_distribution_id;
    CLOSE c_parent_distribution_id;

    RETURN ln_item_distribution_id;

  END get_item_line_id;

---------------------------- INSERT_REQUEST_DETAILS ---------------------------
  PROCEDURE insert_request_details(
    p_batch_id                OUT NOCOPY NUMBER,
    p_regime_id               IN         NUMBER,
    p_rgm_registration_num    IN         VARCHAR2,
    p_trx_from_date           IN         DATE,
    p_trx_till_date           IN         DATE
  ) IS

    ln_conc_request_id    FND_CONCURRENT_REQUESTS.request_id%TYPE;
    ln_conc_request_date  FND_CONCURRENT_REQUESTS.request_date%TYPE;

    CURSOR c_request_date(cp_request_id IN NUMBER) IS
      SELECT request_date
      FROM fnd_concurrent_requests
      WHERE request_id = cp_request_id;

/* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rgm_processing_pkg.insert_request_details';

  BEGIN

    ln_conc_request_id  := FND_PROFILE.value('CONC_REQUEST_ID');

    OPEN c_request_date(ln_conc_request_id);
    FETCH c_request_date INTO ln_conc_request_date;
    CLOSE c_request_date;

    INSERT INTO jai_rgm_conc_requests(
      batch_id,
      request_id,
      request_date,
      regime_id,
      rgm_registration_num,
      trx_from_date,
      trx_till_date,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      program_application_id,
      program_id,
      program_login_id
    ) VALUES (
      jai_rgm_conc_requests_s.nextval,
      ln_conc_request_id,
      ln_conc_request_date,
      p_regime_id,
      p_rgm_registration_num,
      p_trx_from_date,
      p_trx_till_date,
      sysdate,
      FND_GLOBAL.user_id,
      sysdate,
      fnd_global.user_id,
      fnd_global.login_id,
     fnd_profile.value('PROG_APPL_ID'),
     fnd_profile.value('CONC_PROGRAM_ID'),
     fnd_profile.value('CONC_LOGIN_ID')
    ) RETURNING batch_id INTO p_batch_id;


   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

  END insert_request_details;

  ---------------------------- PROCESS_PAYMENT ---------------------------
  PROCEDURE process_payment(
    p_batch_id                IN         NUMBER,
    p_regime_id               IN         NUMBER,
    p_org_id                  IN         NUMBER,
    p_source                  IN         VARCHAR2,
    p_payment_table_name      IN         VARCHAR2,
    p_payment_document_id     IN         NUMBER,
    p_invoice_id              IN         NUMBER,
    p_inv_dist_id             IN         NUMBER,
    p_inv_accounting_chk_done IN         VARCHAR2,
    p_process_flag            OUT NOCOPY VARCHAR2,
    p_process_message         OUT NOCOPY VARCHAR2
  ) IS
/*Bug 5879769 bduvarag start*/
/*    CURSOR c_inv_organization_id(cp_po_distribution_id IN NUMBER) IS
      SELECT b.ship_to_organization_id
      FROM po_distributions_all a, po_line_locations_all b
      WHERE a.line_location_id = b.line_location_id
      AND a.po_distribution_id = cp_po_distribution_id;*/

       -- Added for bug#7191302 by Xiao, begin.
/*     The cursor c_total_inv_amount is to fetch the total invoice amount without considering
       any prepayment applications. Refer to bug for more details*/
      CURSOR c_total_inv_amount(cp_invoice_id NUMBER) IS
      select sum(amount) from ap_invoice_distributions_all a where invoice_id=cp_invoice_id
      and prepay_distribution_id is null;

       -- Added for bug#7191302 by Xiao, end.
    -- Added the following cursor for Bug 7522584
  cursor c_get_curr_dtls (cp_invoice_id NUMBER)
  IS
  SELECT payment_currency_code,
         exchange_rate,
         exchange_date,
         exchange_rate_type
  FROM   ap_invoices_all
  WHERE  invoice_id = cp_invoice_id ;

          lv_service_type_code jai_po_line_locations.service_type_code%TYPE;
    ln_organization_id   NUMBER;
    ln_location_id       NUMBER;
    lv_process_flag      VARCHAR2(15);
    lv_process_message   VARCHAR2(4000);
/*Bug 5879769 bduvarag End*/

    r_ref                     c_reference%ROWTYPE;
    r_parent_ref              c_reference%ROWTYPE;
    r_dist                    c_invoice_distribution%ROWTYPE;

    r_prepayment              c_invoice_distribution%ROWTYPE;
    r_payment                 c_invoice_payment%ROWTYPE;

    ln_inv_organization_id    NUMBER(15);
    ln_rgm_reposotory_id      NUMBER;
    -- ln_payment_amount      NUMBER;

    lv_src_trx_type           VARCHAR2(30);
    ln_recovered_amount       NUMBER;
    ln_parent_recovered_amt   NUMBER;

    ln_payment_amount         NUMBER;
    ld_transaction_date       JAI_RGM_TRX_RECORDS.transaction_date%TYPE;
    ld_accounting_date        DATE;
    ln_validate_amount        NUMBER;
    ln_discounted_amount      NUMBER := 0;
    ln_payment_discount       NUMBER := 0;

    ln_diff_amount            NUMBER;

    lv_codepath               VARCHAR2(1996);  -- := '';  File.Sql.35 by Brathod
    lv_total_inv_amount       NUMBER;  -- added for bug#7191302 by Xiao
    lv_called_from            VARCHAR2(100);  --rchandan for bug#4428980
  rec_get_curr_dtls         c_get_curr_dtls%rowtype;  -- Added for Bug 7522584
  ln_func_tax_amount        NUMBER;
  ln_exc_gain_loss_amt      NUMBER; -- Added for Bug 8294236
  ln_tot_tax_amt            NUMBER; -- Added for Bug 8294236

  BEGIN
    g_debug := 'Y';
    lv_codepath := jai_general_pkg.plot_codepath(1,lv_codepath, 'PROCESS_PAYMENT', 'START');

    -- added for bug#7191302 by Xiao, begin
    open c_total_inv_amount(p_invoice_id);
    fetch c_total_inv_amount into lv_total_inv_amount;
    close c_total_inv_amount;
    -- added for bug#7191302 by Xiao, end.
    -- Bug 7522584 Start
  OPEN c_get_curr_dtls(p_invoice_id);
  FETCH c_get_curr_dtls INTO rec_get_curr_dtls;
  CLOSE c_get_curr_dtls;
  -- Bug 7522584 End

    -- Accounting check for the invoice_distribution, whether it is accounted or not
    IF p_inv_accounting_chk_done = jai_constants.no THEN
      OPEN c_invoice_distribution(p_inv_dist_id);
      FETCH c_invoice_distribution INTO r_dist;
      CLOSE c_invoice_distribution;

      r_dist.invoice_amount:=lv_total_inv_amount;  -- added for bug#7191302 by Xiao
      lv_codepath := jai_general_pkg.plot_codepath(2, lv_codepath);

      -- Following condition is true only if Invoice Distribution Accounting did not happen
      IF r_dist.posted_flag IS NULL OR r_dist.posted_flag <> 'Y' THEN
        lv_codepath := jai_general_pkg.plot_codepath(3, lv_codepath);
        IF g_debug='Y' THEN
          fnd_file.put_line(fnd_file.log,'AccntChkFail. InvId,LineNum,DisNum:'||r_dist.invoice_id||','
              ||r_dist.invoice_line_number||','||r_dist.distribution_line_number);
        END IF;
        p_process_flag := jai_constants.not_accounted;
        --p_process_message := 'Invoice is not accounted';
        RETURN;
      END IF;

    END IF;

    OPEN c_reference(p_source, p_invoice_id, p_inv_dist_id);
    FETCH c_reference INTO r_ref;
    CLOSE c_reference;

    -- If the following if condition is satisfied, then it means there is no REFERENCE entry and thus no RECEOVERY should happen
    IF r_ref.reference_id IS NULL THEN
      lv_codepath := jai_general_pkg.plot_codepath(4, lv_codepath);
      RETURN;
    -- if the following is satisfied then it means this is a reversal of a parent line which is processed and hence should return back
    ELSIF r_ref.reversal_flag = 'Y' THEN
      lv_codepath := jai_general_pkg.plot_codepath(5, lv_codepath);
      p_process_flag := jai_constants.already_processed;
      RETURN;
    END IF;

    IF g_debug='Y' THEN fnd_file.put_line(fnd_file.log,'ProPay.r_ref:'||r_ref.reference_id||',taxty:'||r_ref.tax_type); END IF;

    OPEN c_rgm_repository_id(p_source, p_payment_table_name, p_payment_document_id, r_ref.reference_id);
    FETCH c_rgm_repository_id INTO ln_rgm_reposotory_id;
    CLOSE c_rgm_repository_id;

    -- if the following is satisfied, then it means the payment against the invoice is already processed
    IF ln_rgm_reposotory_id IS NOT NULL THEN
      lv_codepath := jai_general_pkg.plot_codepath(6, lv_codepath);
      p_process_flag := jai_constants.already_processed;
      RETURN;
    END IF;

    lv_codepath := jai_general_pkg.plot_codepath(7, lv_codepath);
    -- following will be true only in case Accounting Check for Invoice distribution is not done in calling procedure
    IF r_dist.invoice_distribution_id IS NULL THEN
      OPEN c_invoice_distribution(p_inv_dist_id);
      FETCH c_invoice_distribution INTO r_dist;
      CLOSE c_invoice_distribution;
    END IF;

    IF p_payment_table_name = jai_constants.ap_payments THEN

      lv_codepath := jai_general_pkg.plot_codepath(8, lv_codepath);
      OPEN c_invoice_payment(p_payment_document_id);
      FETCH c_invoice_payment INTO r_payment;
      CLOSE c_invoice_payment;

      IF r_payment.future_pay_due_date IS NOT NULL AND r_payment.future_pay_due_date > trunc(sysdate) THEN
        lv_codepath := jai_general_pkg.plot_codepath(9, lv_codepath);
        p_process_flag  := 'FP';
        p_process_message := 'Future payment which is not yet matured';
        RETURN;
      END IF;

      ln_payment_amount   := r_payment.amount;
      ln_payment_discount := r_payment.discount_taken;

      ld_accounting_date  := r_payment.accounting_date;

      -- To Derive Src Trx Type and Transaction Date for Normal Payment
      IF r_payment.amount > 0 THEN
        IF r_payment.future_pay_due_date IS NOT NULL THEN
          lv_codepath := jai_general_pkg.plot_codepath(10, lv_codepath);
          lv_src_trx_type     := jai_constants.future_payment;
          ld_transaction_date := r_payment.future_pay_due_date;
        ELSE
          lv_codepath := jai_general_pkg.plot_codepath(11, lv_codepath);
          lv_src_trx_type     := jai_constants.payment;
          ld_transaction_date := r_payment.check_date;
        END IF;

      -- Void Case
      ELSE
        IF r_payment.void_date IS NOT NULL THEN
          lv_codepath := jai_general_pkg.plot_codepath(12, lv_codepath);
          lv_src_trx_type     := jai_constants.payment_voided;
          ld_transaction_date := r_payment.void_date;
        ELSE
          lv_codepath := jai_general_pkg.plot_codepath(13, lv_codepath);
          lv_src_trx_type     := jai_constants.payment_reversal;
          ld_transaction_date := r_payment.check_date;
        END IF;
      END IF;

    ELSIF p_payment_table_name = jai_constants.ap_prepayments THEN

      lv_codepath := jai_general_pkg.plot_codepath(14, lv_codepath);
      OPEN c_invoice_distribution(p_payment_document_id);
      FETCH c_invoice_distribution INTO r_prepayment;
      CLOSE c_invoice_distribution;

      -- Prepayment Application is always a -ve line in invoice distributions, so to make it as +ve we need to negate it
      ln_payment_amount   := -r_prepayment.amount;

      ld_accounting_date  := r_prepayment.accounting_date;
      ld_transaction_date := trunc(r_prepayment.creation_date);

      -- if the following condition is satisfied, then it means a prepayment unapplication onto invoice
      IF r_prepayment.parent_reversal_id IS NOT NULL THEN
        lv_codepath := jai_general_pkg.plot_codepath(15, lv_codepath);
        lv_src_trx_type     := jai_constants.prepay_unapplication;
      ELSE
        lv_codepath := jai_general_pkg.plot_codepath(16, lv_codepath);
        lv_src_trx_type     := jai_constants.prepay_application;
      END IF;

    END IF;

    -- following condition is satisfied if the invoice is cancelled and line has been already claimed that needs to be reversed
    --IF r_dist.cancelled_date IS NOT NULL THEN

    -- Following condition is satisfied if the distribution tax line is reversal of a parent distribution tax line
    IF r_dist.reversal_flag = 'Y' AND r_dist.parent_reversal_id IS NOT NULL THEN

      lv_codepath := jai_general_pkg.plot_codepath(17, lv_codepath);
      OPEN c_reference(p_source, p_invoice_id, r_dist.parent_reversal_id);
      FETCH c_reference INTO r_parent_ref;
      CLOSE c_reference;

      UPDATE jai_rgm_trx_refs
      SET reversal_flag = 'Y',
        last_update_date = sysdate
      WHERE source = p_source
      AND invoice_id = p_invoice_id
      AND line_id in (p_inv_dist_id, r_dist.parent_reversal_id);

      ln_recovered_amount := -r_parent_ref.recovered_amount;
      ln_discounted_amount := -r_parent_ref.discounted_amount;

    -- following elsif is added to take care of void scenarios, where in the recovered amt againt the main payment is reversed
    ELSIF lv_src_trx_type = jai_constants.payment_voided THEN

      lv_codepath := jai_general_pkg.plot_codepath(18, lv_codepath);
      OPEN c_repo_recovered_amt(p_source, p_payment_table_name, r_payment.reversal_inv_pmt_id, r_ref.reference_id);
      FETCH c_repo_recovered_amt INTO ln_parent_recovered_amt;
      CLOSE c_repo_recovered_amt;

      ln_recovered_amount := -ln_parent_recovered_amt;

      if r_payment.amount = 0 THEN
         r_payment.amount :=1;
      end if;

         ln_discounted_amount := -ln_parent_recovered_amt * ( nvl(r_payment.discount_taken,0)/nvl(r_payment.amount,1) );

    -- following elsif is added to take care of Prepay Unapply scenarios, where in the recovered amt againt the main payment is reversed
    ELSIF lv_src_trx_type = jai_constants.prepay_unapplication THEN
      lv_codepath := jai_general_pkg.plot_codepath(20, lv_codepath);
      OPEN c_repo_recovered_amt(p_source, p_payment_table_name, r_prepayment.parent_reversal_id, r_ref.reference_id);
      FETCH c_repo_recovered_amt INTO ln_parent_recovered_amt;
      CLOSE c_repo_recovered_amt;

      ln_recovered_amount := -ln_parent_recovered_amt;

    ELSE
      IF r_dist.invoice_amount = 0 THEN
         r_dist.invoice_amount := 1;
      end if;
      lv_codepath := jai_general_pkg.plot_codepath(22, lv_codepath);
         ln_recovered_amount := (r_ref.recoverable_amount * ln_payment_amount) / r_dist.invoice_amount;    -- CHK

      /* Discount is considered only for payments and not for prepayments */
      if r_payment.amount = 0 THEN
         r_payment.amount := 1;
      end if;
      ln_discounted_amount := ln_recovered_amount * ( r_payment.discount_taken / r_payment.amount );

    END IF;

    IF g_debug = 'Y' THEN
      FND_FILE.put_line(fnd_file.log, 'RecoAmt:'||ln_recovered_amount||', RefRecobleAmt:'||r_ref.recoverable_amount
        ||', PaymtAmt:'||ln_payment_amount||', InvAmt:'||r_dist.invoice_amount||', DiscTaken:'||r_payment.discount_taken
        ||', rPayAmt:'||r_payment.amount||', DiscRecoAmt:'||ln_discounted_amount);
    END IF;

    lv_codepath := jai_general_pkg.plot_codepath(23, lv_codepath);
    ln_recovered_amount   := nvl(ln_recovered_amount, 0);
    ln_discounted_amount  := nvl(ln_discounted_amount, 0);

    ln_validate_amount := r_ref.recovered_amount + r_ref.discounted_amount + ln_recovered_amount + ln_discounted_amount;

     if ln_validate_amount = 0 THEN
       ln_validate_amount := 1;
     end if;


    IF r_ref.recoverable_amount > 0 AND ln_validate_amount > r_ref.recoverable_amount THEN
      lv_codepath := jai_general_pkg.plot_codepath(24, lv_codepath);

      ln_diff_amount  := ln_validate_amount - r_ref.recoverable_amount;
      ln_discounted_amount  := ln_discounted_amount - (ln_discounted_amount * ln_diff_amount / ln_validate_amount);
      ln_recovered_amount   := ln_recovered_amount  - (ln_recovered_amount * ln_diff_amount / ln_validate_amount);
      --ln_recovered_amount := r_ref.recoverable_amount - r_ref.recovered_amount;

    ELSIF r_ref.recoverable_amount < 0 AND ln_validate_amount < r_ref.recoverable_amount THEN
      lv_codepath := jai_general_pkg.plot_codepath(25, lv_codepath);

      ln_diff_amount  := ln_validate_amount - r_ref.recoverable_amount;
      ln_discounted_amount  := ln_discounted_amount - (ln_discounted_amount * ln_diff_amount / ln_validate_amount);
      ln_recovered_amount   := ln_recovered_amount  - (ln_recovered_amount * ln_diff_amount / ln_validate_amount);
      -- ln_recovered_amount := r_ref.recoverable_amount - r_ref.recovered_amount;

    END IF;

    IF g_debug = 'Y' THEN
      FND_FILE.put_line(fnd_file.log, 'DiffAmt:'||ln_diff_amount||', ValidtAmt:'||ln_validate_amount
        ||', RecoAmt:'||ln_recovered_amount||', DiscRecoAmt:'||ln_discounted_amount);
    END IF;

    IF ln_recovered_amount = 0 THEN
      lv_codepath := jai_general_pkg.plot_codepath(26, lv_codepath);
      IF g_debug='Y' THEN
        fnd_file.put_line(fnd_file.log,'Allready amount is recovered');
    END IF;
      RETURN;
    END IF;
/*Bug 5879769 bduvarag start*/
/*    OPEN c_inv_organization_id(r_dist.po_distribution_id);
    FETCH c_inv_organization_id INTO ln_inv_organization_id;
    CLOSE c_inv_organization_id;*/
    jai_trx_repo_extract_pkg.get_doc_from_reference(p_reference_id      => r_ref.reference_id,
                                                    p_organization_id   => ln_organization_id,
                                                    p_location_id       => ln_location_id,
                                                    p_service_type_code => lv_service_type_code,
                                                    p_process_flag      => lv_process_flag,
                                                    p_process_message   => lv_process_message
                                                    );
     IF  lv_process_flag <> jai_constants.successful THEN
       lv_codepath := jai_general_pkg.plot_codepath(27.1, lv_codepath);
       FND_FILE.put_line(fnd_file.log, 'Error Flag:'||lv_process_flag||' Error Message:'||lv_process_message);
       return;
     END IF;
/*Bug 5879769 bduvarag End*/
    -- Replaced rec_get_curr_dtls by r_payment for Bug 8294236
    ln_func_tax_amount := ln_recovered_amount * nvl(r_payment.exchange_rate, 1); -- Added for Bug 7522584

  /*Bug 8294236 - Start*/
    ln_tot_tax_amt := ln_recovered_amount + nvl(ln_discounted_amount,0);
      IF (nvl(r_payment.exchange_rate,1) <> nvl(rec_get_curr_dtls.exchange_rate,1)
        AND r_payment.currency_code = rec_get_curr_dtls.payment_currency_code) THEN
        ln_exc_gain_loss_amt := (ln_tot_tax_amt * nvl(r_payment.exchange_rate,1))
                                - (ln_tot_tax_amt * nvl(rec_get_curr_dtls.exchange_rate,1));
      ELSE
        ln_exc_gain_loss_amt := 0;
      END IF;
  /*Bug 8294236 - End*/

    lv_codepath := jai_general_pkg.plot_codepath(27, lv_codepath);
    lv_called_from := 'AP_PROCESSING';--rchandan for bug#4428980
    jai_cmn_rgm_recording_pkg.insert_repository_entry(
        p_repository_id          => ln_rgm_reposotory_id,
        p_regime_id              => p_regime_id,
        p_tax_type               => r_ref.tax_type,
        p_organization_type      => jai_constants.orgn_type_io     ,/*5694855*/
        p_organization_id        => ln_organization_id         ,/*5694855*/
        p_location_id            => ln_location_id,/*5694855*/
        p_service_type_code      => lv_service_type_code,/*5694855*/
        p_source                 => p_source,
        p_source_trx_type        => lv_src_trx_type,
        p_source_table_name      => p_payment_table_name,
        p_source_document_id     => p_payment_document_id,
        p_transaction_date       => ld_transaction_date,
        p_account_name           => null,
        p_charge_account_id      => null,
        p_balancing_account_id   => null,
        p_amount                 => ln_func_tax_amount ,  -- Added for Bug 7522584
        p_discounted_amount      => ln_discounted_amount,
        p_inv_organization_id    => ln_organization_id,/*Bug 5879769 bduvarag*/
        p_trx_amount             => ln_recovered_amount,
        p_assessable_value       => null,
        p_tax_rate               => null,
        p_reference_id           => r_ref.reference_id,
        p_batch_id               => p_batch_id,
        p_called_from            => lv_called_from,   --rchandan for bug#4428980
        p_process_flag           => p_process_flag,
        p_process_message        => p_process_message,
        p_accntg_required_flag   => jai_constants.yes,
        p_accounting_date        => ld_accounting_date,
        p_balancing_orgn_type    => null,
        p_balancing_orgn_id      => null,
        p_balancing_location_id  => null,
        p_balancing_tax_type     => null,
        p_balancing_accnt_name   => null,
        /* added nvl part for bug 9187805 */
        p_currency_code          => nvl(r_payment.currency_code,rec_get_curr_dtls.payment_currency_code), -- Added for Bug 7522584
        p_curr_conv_date         => nvl(r_payment.exchange_date,rec_get_curr_dtls.exchange_date), -- Added for Bug 7522584
        p_curr_conv_type         => nvl(r_payment.exchange_rate_type,rec_get_curr_dtls.exchange_rate_type), -- Added for Bug 7522584
        p_curr_conv_rate         => nvl(r_payment.exchange_rate,rec_get_curr_dtls.exchange_rate) -- Added for Bug 7522584
    );

    IF p_process_flag <> jai_constants.successful THEN
      lv_codepath := jai_general_pkg.plot_codepath(28, lv_codepath);
      RETURN;
    END IF;

    /*Bug 8294236 - Start*/
  IF nvl(ln_exc_gain_loss_amt,0) <> 0 THEN

         jai_cmn_rgm_recording_pkg.exc_gain_loss_accounting(
                                 p_repository_id           =>  ln_rgm_reposotory_id                                ,
                                 p_regime_id               =>  p_regime_id                                         ,
                                 p_tax_type                =>  r_ref.tax_type                                      ,
                                 p_organization_type       =>  jai_constants.orgn_type_io                          ,
                                 p_organization_id         =>  ln_organization_id                                  ,
                                 p_location_id             =>  ln_location_id                                      ,
                                 p_source                  =>  p_source                                            ,
                                 p_source_trx_type         =>  lv_src_trx_type                                     ,
                                 p_source_table_name       =>  p_payment_table_name                                ,
                                 p_source_document_id      =>  p_payment_document_id                               ,
                                 p_transaction_date        =>  ld_transaction_date                                 ,
                                 p_account_name            =>  NULL                                                ,
                                 p_charge_account_id       =>  NULL                                                ,
                                 p_balancing_account_id    =>  NULL                                                ,
                                 p_exc_gain_loss_amt       =>  ln_exc_gain_loss_amt                                ,
                                 p_reference_id            =>  r_ref.reference_id                                  ,
                                 p_called_from             =>  'AP_PROCESSING'                                     ,
                                 p_process_flag            =>  lv_process_flag                                     ,
                                 p_process_message         =>  lv_process_message                                  ,
                                 p_accounting_date         =>  ld_accounting_date
                               );

         IF lv_process_flag = jai_constants.expected_error    OR
            lv_process_flag = jai_constants.unexpected_error
         THEN
           p_process_flag    := lv_process_flag    ;
           p_process_message := lv_process_message ;
           fnd_file.put_line( fnd_file.log, 'error in call to jai_rgm_trx_recording_pkg.exc_gain_loss_accounting - lv_process_flag '||lv_process_flag
                                             ||', lv_process_message'||lv_process_message);
           RETURN;
         END IF;
  END IF;
  /*Bug 8294236 - end*/

    jai_cmn_rgm_recording_pkg.update_reference(
      p_source            => p_source,
      p_reference_id      => r_ref.reference_id,
      p_recovered_amount  => ln_recovered_amount,
      p_discounted_amount => ln_discounted_amount,     -- CHK (Implementation)
      p_process_flag      => p_process_flag,
      p_process_message   => p_process_message
    );

    <<end_of_dist>>
    lv_codepath := jai_general_pkg.plot_codepath(49, lv_codepath, 'PROCESS_PAYMENT', 'END');

    IF g_debug = 'Y' THEN
      FND_FILE.put_line( fnd_file.log, 'Codepath:'||lv_codepath);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_process_flag := jai_constants.unexpected_error;
      p_process_message := 'Process Payment Error:'||SQLERRM;
      FND_FILE.put_line( fnd_file.log, p_process_message);
      FND_FILE.put_line( fnd_file.log, 'Error Codepath:'||lv_codepath);

  END process_payment;

---------------------------- PROCESS_BATCH ---------------------------
PROCEDURE process_batch(
    errbuf                    OUT NOCOPY VARCHAR2,
    retcode                   OUT NOCOPY VARCHAR2,
    p_regime_id               IN         NUMBER,
    p_rgm_registration_num    IN         VARCHAR2,
    pv_trx_from_date          IN         VARCHAR2,
    pv_trx_till_date          IN         VARCHAR2,
    p_called_from             IN         VARCHAR2,  -- DEFAULT 'Batch' File.Sql.35 by Brathod
    p_debug                   IN         VARCHAR2,  -- DEFAULT 'Y'     File.Sql.35 by Brathod
    p_trace_switch            IN         VARCHAR2,   -- DEFAULT 'N'     File.Sql.35 by Brathod
    p_organization_id       IN         NUMBER    DEFAULT NULL   /*5694855*/
  ) IS

    ln_batch_id                 JAI_RGM_CONC_REQUESTS.batch_id%TYPE;
    ln_request_id               JAI_RGM_CONC_REQUESTS.request_id%TYPE;
    ld_trx_start_date           DATE;

    lv_process_flag             VARCHAR2(2);
    lv_process_message          VARCHAR2(1000);

    /* Brathod, for Bug# 4286646*/
    p_trx_from_date DATE; -- DEFAULT fnd_date.canonical_to_date(pv_trx_from_date)  File.Sql.35 by Brathod
    p_trx_till_date DATE; -- DEFAULT fnd_date.canonical_to_date(pv_trx_till_date)  File.Sql.35 by Brathod
    /*End of Bug# 4286646 */

    CURSOR c_regime_orgs(cp_regime_id IN NUMBER, cp_orgn_type IN VARCHAR2, cp_registration_num IN VARCHAR2,p_att_type_code jai_rgm_registrations.attribute_type_code%TYPE,cp_organization_id  IN NUMBER ) IS/*Bug 5879769 bduvarag*/
      SELECT a.organization_id org_id,a.location_id /*Bug 5879769 bduvarag*/
      FROM JAI_RGM_ORG_REGNS_V a
      WHERE regime_id = cp_regime_id
      AND registration_type = jai_constants.regn_type_others
      AND attribute_type_code = p_att_type_code--rchandan for bug#4428980
      AND organization_type = cp_orgn_type
      AND attribute_value = cp_registration_num
      AND a.organization_id   = nvl(cp_organization_id,a.organization_id) /*5694855*/;


    ld_rgm_effective_from   JAI_RGM_DEFINITIONS.effective_date_from%TYPE;
    CURSOR c_rgm_effective_from_date(cp_regime_id IN NUMBER) IS
      SELECT trunc(creation_date) effective_date_from  /* effective_date_from. Commneted this as part of VAT Impl. Vijay Shankar for Bug#425023(4245089) */
      FROM JAI_RGM_DEFINITIONS
      WHERE regime_id = cp_regime_id;
/*Bug 5879769 bduvarag start*/
  CURSOR cur_fetch_ou(cp_organization_id NUMBER)
  IS
  SELECT org_information3
  FROM   hr_organization_information
  WHERE  upper(ORG_INFORMATION_CONTEXT) = 'ACCOUNTING INFORMATION'
  AND    organization_id                = cp_organization_id;

  ln_org_id   NUMBER;  /*5694855*/
/*Bug 5879769 bduvarag End*/
  BEGIN

    p_trx_from_date := fnd_date.canonical_to_date(pv_trx_from_date);  --File.Sql.35 by Brathod
    p_trx_till_date := fnd_date.canonical_to_date(pv_trx_till_date); --File.Sql.35 by Brathod

    FND_FILE.put_line(fnd_file.log,'Value of from date is '||p_trx_from_date);
     FND_FILE.put_line(fnd_file.log,'Value of from date is '||p_trx_till_date);


    g_debug := p_debug;
    g_debug := 'Y';

    IF p_debug = 'Y' THEN
      fnd_file.put_line(fnd_file.log, 'Enter1');
    END IF;

    /*
    OPEN c_previous_batch_dtls(p_regime_id, p_rgm_registration_num);
    FETCH c_previous_batch_dtls INTO ld_trx_start_date;
    CLOSE c_previous_batch_dtls;

    IF ld_trx_start_date IS NULL THEN
      ld_trx_start_date := to_date('22-DEC-2004', 'DD-MON-YYYY');     -- TEST CODE
    END IF;
    */

    insert_request_details(
      p_batch_id             => ln_batch_id,    -- OUT parameter
      p_regime_id            => p_regime_id,
      p_rgm_registration_num => p_rgm_registration_num,
      p_trx_from_date        => p_trx_from_date,
      p_trx_till_date        => p_trx_till_date
    );

    OPEN c_rgm_effective_from_date(p_regime_id);
    FETCH c_rgm_effective_from_date INTO ld_rgm_effective_from;
    CLOSE c_rgm_effective_from_date;

    IF p_trx_from_date < ld_rgm_effective_from THEN

      FND_FILE.put_line(fnd_file.log, 'Start Date('||to_char(p_trx_from_Date,'DD-MON-YYYY')
        ||') of Transaction Processing cannot be less than Regime Effective Date('||to_char(ld_rgm_effective_from,'DD-MON-YYYY')||')'
      );
      retcode := jai_constants.request_error;

      RETURN;

    END IF;

    ld_trx_start_date := p_trx_from_date;

    FOR loop_io IN c_regime_orgs(p_regime_id, jai_constants.orgn_type_io, p_rgm_registration_num,'PRIMARY',p_organization_id) LOOP/*Bug 5879769 bduvarag*/

     /* start changes by ssumaith - code review comments - bug# 6109941*/
     OPEN  cur_fetch_ou(loop_io.org_id);
     FETCH cur_fetch_ou INTO ln_org_id;
     CLOSE cur_fetch_ou;
    /* ends additions by ssumaith - bug#6109941*/

     /*Added by nprashar for bug # 6636517*/
     fnd_file.put_line(fnd_file.log,'P_organization_type :' || jai_constants.orgn_type_io);
     fnd_file.put_line(fnd_file.log,'P_organization_id :' ||ln_org_id);
     fnd_file.put_line(fnd_file.log,'P_Location_id :' ||loop_io.location_id); /*Ends here for bug #6636517*/
      /***************** Processing of AP Start Here *********************/
      process_payments(
          p_regime_id         => p_regime_id,
          p_organization_type => jai_constants.orgn_type_io, /* ssumaith - bug# 6109941 */
            p_organization_id   => loop_io.org_id,/*5694855*/ /* ssumaith 6109941 */
          p_trx_from_date     => ld_trx_start_date,
          p_trx_to_date       => p_trx_till_date,
          p_org_id            => ln_org_id,
          p_batch_id          => ln_batch_id,
          p_debug             => p_debug,
          p_process_flag      => lv_process_flag,
          p_process_message   => lv_process_message
      );

      IF lv_process_flag IN (jai_constants.expected_error, jai_constants.unexpected_error) THEN
        GOTO end_of_batch;
      END IF;

      /***************** Processing of AR Start Here *********************/
      jai_ar_rgm_processing_pkg.process_records(
          p_regime_id         => p_regime_id,
          p_organization_type => jai_constants.orgn_type_io,
          p_organization_id   => loop_io.org_id   ,/*5694855*/
          p_from_date         => ld_trx_start_date,
          p_to_date           => p_trx_till_date,
          p_org_id            => ln_org_id,
          p_batch_id          => ln_batch_id,
          p_process_flag      => lv_process_flag,
          p_process_message   => lv_process_message
      );

      IF lv_process_flag IN (jai_constants.expected_error, jai_constants.unexpected_error) THEN
        GOTO end_of_batch;
      END IF;

    END LOOP;     -- Operating Units loop of Registration Number

    <<end_of_batch>>

    IF lv_process_flag IN (jai_constants.expected_error, jai_constants.unexpected_error) THEN
      FND_FILE.put_line( FND_FILE.log, 'Problem Message:'||lv_process_message);
      fnd_file.put_line(fnd_file.log,'Problem Message:'||lv_process_message);
      retcode := jai_constants.request_warning;
      errbuf  := lv_process_message;
    END IF;

    -- FINAL Commit to permanently save the transactions
    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      retcode := jai_constants.request_error;
      errbuf := 'Unexpected Error Occured:'||SQLERRM;
      FND_FILE.put_line( fnd_file.log, 'Unexpected Error Occured:'||SQLERRM);

  END process_batch;

  PROCEDURE process_payments(
    p_regime_id           IN         NUMBER,
    p_organization_type   IN         VARCHAR2,
    p_trx_from_date       IN         DATE,
    p_trx_to_date         IN         DATE,
    p_org_id              IN         NUMBER,
    p_batch_id            IN         NUMBER,
    p_debug               IN         VARCHAR2,
    p_process_flag        OUT NOCOPY VARCHAR2,
    p_process_message     OUT NOCOPY VARCHAR2,
    p_organization_id      IN         NUMBER    DEFAULT NULL   /*5694855*/
  ) IS

    v_today     DATE ; -- := trunc(sysdate)  -- File.Sql.35 by Brathod
    lv_standard_lookup  CONSTANT varchar2(30) := 'STANDARD';   --rchandan for bug#4428980
    lv_debit_lookup     CONSTANT varchar2(30) := 'DEBIT';      --rchandan for bug#4428980
    --Bug 4991017. Added by Lakshmi Gopalsami
    lv_entity_code      CONSTANT varchar2(30) := 'AP_INVOICES';

    CURSOR c_previous_batch_dtls(cp_regime_id IN NUMBER, cp_registration_num IN VARCHAR2) IS
      SELECT trx_till_date+1
      FROM jai_rgm_conc_requests
      WHERE regime_id = cp_regime_id
      AND rgm_registration_num = cp_registration_num;

    /* Bug 4991017. Added by Lakshmi Gopalsami
       Merged the cursors c_ap_accounted_invoices and c_event_distributions
       because of SLA uptake by base and removed the same.
      (1) Changed the reference to xla_ae_headers instead of ap_ae_headers_all
      (2) Also added xla_transaction_entities to get the entity_id and
          source_int_id_1 so that it can be joined with transaction tables.
      (3) Discussed with shekhar and found that we should derive by
          accounting_date and not on the creation_date.
      (4) Added accounting_event_id in cursor
    */
    -- Considers only Localization Tax Distributions created from Receipt, PO, Invoice Matching
    CURSOR c_ap_accounted_inv_dist(cp_ae_category IN VARCHAR2,
                                   cp_start_date  IN DATE    ,
                                   cp_till_date   IN DATE    ,
                                   cp_sob_id      IN NUMBER) IS/*Bug 5879769 bduvarag*/
      SELECT aid.invoice_id, aid.invoice_distribution_id,
             aid.distribution_line_number, aid.invoice_line_number,
       aid.reversal_flag, aid.parent_reversal_id,
       aid.accrual_posted_flag, aid.cash_posted_flag,
       aid.amount, aid.base_amount,
       aid.po_distribution_id, aid.rcv_transaction_id,
       -- Bug 4991017 Added by Lakshmi Gopalsami.
       -- Added accounting_event_id in cursor.
       aid.org_id, aid.accounting_event_id,
       ai.vendor_id, ai.vendor_site_id, ai.invoice_currency_code,
       aid.exchange_rate, aid.exchange_rate_type, aid.exchange_date,
       ai.source
      FROM xla_ae_headers xah ,
           xla_transaction_entities xte,
     ap_invoices_all ai,
     ap_invoice_distributions_all aid
      WHERE  xah.je_category_name = cp_ae_category
      AND xah.ledger_id = cp_sob_id
      AND xah.application_id =200
      and xah.entity_id = xte.entity_id
      AND xte.application_id = 200
      and xte.entity_code =lv_entity_code --'AP_INVOICES'
      and xte.source_id_int_1 = ai.invoice_id
      AND aid.invoice_id = ai.invoice_id
      and aid.accounting_event_id = xah.event_id
      AND ai.invoice_type_lookup_code IN (lv_standard_lookup, lv_debit_lookup)
      AND ai.cancelled_date IS NULL
      AND ( aid.line_type_lookup_code = jai_constants.misc_line
            or exists (select 1 from jai_rcv_tp_invoices jtp where AID.invoice_id = jtp.invoice_id)) /* modified by vumaasha for bug 8965721 */
      AND aid.posted_flag = 'Y'
      /*bug 7347127 - moved the trunc in following 2 expressions to the RHS, so that
       * the indec on accounting_date would be used in the two tables. In some cases,
       * this would prevent performance issue in the Service Tax Processor*/
      AND xah.accounting_date between trunc(cp_start_date) AND (trunc(cp_till_date+1)-1/(24*60*60))
      AND aid.accounting_date between trunc(cp_start_date) AND (trunc(cp_till_date+1)-1/(24*60*60))
      and ai.org_id = p_org_id
      and aid.org_id = p_org_id;
      /*bug 7347127 - commented the order by clause to improve performance*/
      --ORDER BY aid.accounting_date, aid.invoice_distribution_id;
/*Bug 5879769 bduvarag start*/
    CURSOR c_prepayment_applications(cp_start_date IN DATE, cp_till_date IN DATE)
        IS
    SELECT invoice_id,
           invoice_distribution_id,
           prepay_distribution_id ,
           amount                 ,
           reversal_flag          ,
           parent_reversal_id     ,
           org_id
      FROM ap_invoice_distributions_all
     WHERE org_id                 = p_org_id
       AND line_type_lookup_code  = jai_constants.prepay_line
       AND invoice_id IN ( SELECT invoice_id
                             FROM ap_invoice_distributions_all
                            WHERE po_distribution_id IN ( SELECT pda.po_distribution_id
        FROM po_line_locations_all   pll,
        po_distributions_all    pda,
        jai_po_line_locations jpll
       WHERE pll.line_location_id        = jpll.line_location_id
       AND pll.line_location_id        = pda.line_location_id
       AND pll.ship_to_organization_id = p_organization_id
      )
       AND (   (cp_start_date IS NULL AND creation_date < cp_till_date)
              OR (cp_start_date IS NOT NULL AND trunc(creation_date) between cp_start_date AND cp_till_date)
                    )

        -- union added by Xiao Lv for Bug#7191302
        UNION
                select invoice_id
                  from jai_rcv_tp_invoices
                 where vendor_id
                    in (select vendor_id
                          from po_vendors
                         where trim(vendor_type_lookup_code)
                          like 'Service Tax Authorities')
                           AND (  (cp_start_date IS NULL AND creation_date < cp_till_date)
                               OR (cp_start_date IS NOT NULL AND trunc(creation_date) between cp_start_date AND cp_till_date)
                                )--Xiao Lv for Bug#7191302
              )/*5694855*/
       AND prepay_distribution_id IS NOT NULL
       AND (   ( cp_start_date IS NULL AND  creation_date < cp_till_date)
            OR ( cp_start_date IS NOT  NULL AND trunc(creation_date) between cp_start_date AND cp_till_date)
           )

     ORDER BY invoice_distribution_id;
/*Bug 5879769 bduvarag end*/
    CURSOR c_invoice_distributions(cp_invoice_id IN NUMBER) IS
      SELECT a.invoice_id, a.invoice_distribution_id, a.distribution_line_number, a.dist_match_type,
        a.invoicE_line_number,  /* INVOICE LINES UPTAKE */
        a.parent_reversal_id, a.reversal_flag, a.rcv_transaction_id, a.po_distribution_id
      FROM ap_invoice_distributions_all a, jai_rgm_trx_refs b /* second table is used for join just to take IL records */
      WHERE a.invoice_id = cp_invoice_id
      AND a.line_type_lookup_code = jai_constants.misc_line   -- <> 'PREPAY'
      AND b.source = jai_constants.source_ap
      and b.invoice_id = a.invoice_id
      and b.line_id = a.invoice_distribution_id
      ORDER BY a.invoice_distribution_id;

    CURSOR c_tax_dist_dtl(cp_regime_id IN NUMBER, cp_invoice_id IN NUMBER, cp_inv_distribution_id IN NUMBER) IS -- cp_dist_line_no IN NUMBER) IS
      SELECT 1 chk, a.tax_id, b.tax_rate, a.tax_amount, a.parent_invoice_distribution_id, b.tax_type,
            a.invoice_line_number,  /* INVOICE LINES UPTAKE */
            nvl(b.mod_cr_percentage,0) recoverable_ptg, a.base_amount
      FROM JAI_AP_MATCH_INV_TAXES a, JAI_CMN_TAXES_ALL b, JAI_RGM_REGISTRATIONS c
      WHERE a.invoice_id = cp_invoice_id
      -- AND a.distribution_line_number = cp_dist_line_no Modified as part of AP INVOICE Lines Uptake project
      AND a.invoice_distribution_id = cp_inv_distribution_id
      AND a.tax_id = b.tax_id
      AND b.tax_type = c.attribute_code
      and c.regime_id = cp_regime_id
      and c.registration_type = jai_constants.regn_type_tax_types
      -- 5763527, modified and condition as below
      AND ( mod_cr_percentage > 0 and  mod_cr_percentage <= 100 and nvl(recoverable_flag,'Y') <> 'N')
        UNION --Added this union for bug#8943349 by JMEENA
     SELECT 2 chk, a.tax_id, b.tax_rate, a.tax_amt,null, b.tax_type,
              d.invoice_line_number,  /* INVOICE LINES UPTAKE */
              nvl(b.mod_cr_percentage,0) recoverable_ptg, d.base_amount
        FROM JAI_CMN_DOCUMENT_TAXES a, JAI_CMN_TAXES_ALL b, JAI_RGM_REGISTRATIONS c,
             AP_INVOICE_DISTRIBUTIONS_ALL d
        WHERE a.source_doc_id = cp_invoice_id
        AND d.invoice_distribution_id = cp_inv_distribution_id
        AND d.invoice_id = a.source_doc_id
        AND d.invoice_line_number = a.source_doc_line_id
        AND a.tax_id = b.tax_id
        AND b.tax_type = c.attribute_code
        and c.regime_id = cp_regime_id
        and c.registration_type = jai_constants.regn_type_tax_types
        AND ( mod_cr_percentage > 0 and  mod_cr_percentage <= 100 and nvl(modvat_flag,'Y') <> 'N');

     -- AND b.mod_cr_percentage > 0;

     /* Cursor added by ssumaith - bug# 4284505*/
     CURSOR c_tp_inv_details (cp_regime_id IN NUMBER , cp_invoice_id IN NUMBER , cp_line_number IN NUMBER) IS
       SELECT 1 chk , a.tax_id , a.tax_rate , a.tax_amount , NULL ,a.tax_type ,
              a.line_number invoice_line_number,  /* INVOICE LINES UPTAKE */
              NVL(b.mod_cr_percentage,0) recoverable_ptg, NULL
       FROM   jai_rcv_tp_inv_details a , JAI_CMN_TAXES_ALL b  , jai_rcv_tp_invoices c, JAI_RGM_REGISTRATIONS d
       WHERE  c.invoice_id = cp_invoice_id
       AND    a.batch_invoice_id = c.batch_invoice_id
       AND    a.tax_id = b.tax_id
       AND    a.line_number = cp_line_number  /*INVOICE LINES UPTAKE cp_dist_line_number */
       AND    b.tax_type = attribute_code
       and d.regime_id = cp_regime_id
       AND d.registration_type = jai_constants.regn_type_tax_types
       AND    b.mod_cr_percentage > 0;


    CURSOR c_item_id(cp_po_distribution_id IN NUMBER) IS
      SELECT b.item_id
      FROM po_distributions_all a, po_lines_all b
      WHERE po_distribution_id = cp_po_distribution_id
      AND a.po_line_id = b.po_line_id;

    CURSOR c_batch_references(cp_batch_id IN NUMBER, cp_source IN VARCHAR2) IS
      SELECT distinct invoice_id
      FROM jai_rgm_trx_refs
      WHERE batch_id = cp_batch_id
      AND source = cp_source;

    CURSOR c_previous_payments_of_inv(cp_invoice_id IN NUMBER, cp_start_date IN DATE) IS
      SELECT a.invoice_payment_id, a.check_id, a.amount, a.payment_base_amount, a.reversal_flag,
            a.reversal_inv_pmt_id, a.org_id
      FROM ap_invoice_payments_all a, ap_checks_all b
      WHERE a.invoice_id = cp_invoice_id
      AND a.check_id = b.check_id
      AND a.creation_date < cp_start_date
      AND nvl(b.future_pay_due_date, v_today) <= v_today
      AND a.amount <> 0 /* ssumaith bug# 6104491 */
      AND a.invoice_payment_id NOT IN (select source_document_id from jai_rgm_trx_records   -- CHK is this required
                                    where source = jai_constants.source_ap
                                    and source_table_name = jai_constants.ap_payments
                                    and source_document_id = a.invoice_payment_id
                                    )
      ORDER BY invoice_payment_id;

    CURSOR c_previous_prepayments(cp_invoice_id IN NUMBER, cp_start_date IN DATE) IS
      SELECT invoice_distribution_id, reversal_flag, parent_reversal_id, amount, org_id
      FROM ap_invoice_distributions_all
      WHERE invoice_id = cp_invoice_id
      AND creation_date < cp_start_date
      ORDER BY invoice_distribution_id;

    /*
    ||Cursor modified by aiyer for the bug 4947102 .
    ||Merged the cursors c_period_payments with c_invoice_distributions into c_period_payments
    */
    CURSOR  c_period_payments( /*Bug 5879769 bduvarag*/
                               cp_start_date IN DATE   ,
                               cp_till_date  IN DATE
                             )
    IS
    SELECT
            ainvd.invoice_id,
            ainvd.invoice_distribution_id,
            ainvd.distribution_line_number,
            ainvd.dist_match_type,
            ainvd.invoice_line_number,  /* INVOICE LINES UPTAKE */
            ainvd.parent_reversal_id,
            ainvd.reversal_flag,
            ainvd.rcv_transaction_id,
            ainvd.po_distribution_id,
            apinvp.invoice_payment_id,
            apinvp.check_id,
            apinvp.amount,
            apinvp.org_id
    FROM
            ap_invoice_payments_all      apinvp,
            ap_checks_all                apc   ,
            ap_invoice_distributions_all ainvd ,
            jai_rgm_trx_refs             jrtr /* second table is used for join just to take IL records */
    WHERE
            apinvp.org_id                         = p_org_id
    AND     apinvp.check_id                       = apc.check_id
    AND     nvl(apc.future_pay_due_date, v_today) <= v_today
    AND     apinvp.accounting_date/*Commented by  nprashar for bug #6636517
    v_today*/     BETWEEN cp_start_date AND cp_till_date
    AND     ainvd.invoice_id     IN
          ( SELECT invoice_id
              FROM ap_invoice_distributions_all
       WHERE org_id = p_org_id
         AND po_distribution_id in
             (SELECT pda.po_distribution_id
          FROM po_line_locations_all   pll,
               po_distributions_all    pda,
         jai_po_line_locations jpll
           WHERE pll.line_location_id        = jpll.line_location_id
           AND pll.line_location_id        = pda.line_location_id
           AND pll.ship_to_organization_id = p_organization_id
               )
              /* Bug 7172723. Added by Lakshmi Gopalsami
         * Added union clause.
         */
              UNION
        SELECT jrti.invoice_id
          FROM jai_rcv_tp_invoices jrti
         WHERE jrti.vendor_id = apc.vendor_id
           AND jrti.vendor_site_id = apc.vendor_site_id
     AND apc.org_id = p_org_id
     UNION --Added this union for bug#8943349 by JMEENA
     select aia.invoice_id
     from ap_invoices_all aia , jai_ap_invoice_lines jail
     where aia.invoice_id = jail.invoice_id
     and aia.source='Manual Invoice Entry'
     and jail.organization_id = p_organization_id
             )/*5694855*/

    AND     ( ainvd.line_type_lookup_code           = jai_constants.misc_line
              /* modified by vumaasha for bug 8965721 */
              OR  exists (select 1 from jai_rcv_tp_invoices jtp where jtp.invoice_id=ainvd.invoice_id ) )
    AND     jrtr.source                           = jai_constants.source_ap
    AND     jrtr.invoice_id                       = ainvd.invoice_id
    AND     apinvp.invoice_id       = ainvd.invoice_id  --added by csahoo for bug#6436576
    AND     jrtr.line_id                          = ainvd.invoice_distribution_id
    ORDER BY
            apinvp.invoice_payment_id     ,
            ainvd.invoice_distribution_id;

    CURSOR c_invoice_batch_refs(cp_source IN VARCHAR2, cp_batch_id IN NUMBER, cp_invoice_id IN NUMBER) IS
      SELECT *
      FROM jai_rgm_trx_refs
      WHERE source = cp_source
      AND batch_id = cp_batch_id
      AND invoice_id = cp_invoice_id
      AND reversal_flag IS NULL
      ORDER by invoice_id, line_id;

    /* Bug 5243532. Added by Lakshmi Gopalsami
       removed the cursor c_sob_of_ou and implemented using caching
       logic.
     */
     CURSOR c_payment_chk(cp_source IN VARCHAR2, cp_source_table_name IN VARCHAR2, cp_source_document_id IN NUMBER) IS
      SELECT 1
      FROM jai_rgm_trx_records
      WHERE source = jai_constants.source_ap
      AND source_table_name = jai_constants.ap_payments
      AND source_document_id = cp_source_document_id;

    /*OPEN c_payment_chk(jai_constants.source_ap, jai_constants.ap_payments, inv_payment.invoice_payment_id);
    FETCH c_payment_chk INTO ln_chk;
    CLOSE c_payment_chk;    */

    r_ref                       c_reference%ROWTYPE;
    r_parent_ref                c_reference%ROWTYPE;
    r_parent_dist               c_invoice_distribution%ROWTYPE;

    r_tax_dist_dtl              c_tax_dist_dtl%ROWTYPE;

    ln_item_line_id             NUMBER(15);   -- Incase of AP -> AP_INVOICE_DISTRIBUTIONS_ALL.invoice_distribution_id%TYPE;
    ln_item_id                  MTL_SYSTEM_ITEMS.inventory_item_id%TYPE;
    ln_reference_id             JAI_RGM_TRX_REFS.reference_id%TYPE;
    ln_parent_reference_id      JAI_RGM_TRX_REFS.parent_reference_id%TYPE;
    ln_taxable_basis            NUMBER;

    ln_rgm_reposotory_id        JAI_RGM_TRX_RECORDS.repository_id%TYPE;
    ln_recovered_amount         JAI_RGM_TRX_REFS.recovered_amount%TYPE;
    ln_recoverable_amount       JAI_RGM_TRX_REFS.recoverable_amount%TYPE;

    ln_sob_id                   GL_SETS_OF_BOOKS.set_of_books_id%TYPE;
    lv_src_trx_type             JAI_RGM_TRX_RECORDS.source_trx_type%TYPE;
    lv_process_flag             VARCHAR2(2);
    lv_process_message          VARCHAR2(1000);

    ln_commit_interval          NUMBER(5) := 500;
    ln_uncommited_trxs          NUMBER(6) := 0;

    /* Bug 5243532. Added by Lakshmi Gopalsami
       Defined variahle for caching logic.
     */
    l_func_curr_det jai_plsql_cache_pkg.func_curr_details;
  BEGIN

    v_today     := trunc(sysdate);  -- File.Sql.35 by Brathod

    /* Bug 5243532. Added by Lakshmi Gopalsami
       removed the cursor c_sob_of_ou and implemented using caching
       logic.
     */
    l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => p_org_id );
    ln_sob_id := l_func_curr_det.ledger_id;


    IF p_debug = 'Y' THEN fnd_file.put_line(fnd_file.log, 'AAA Enter2 - Organization id:'||p_organization_id||'OU ID:'||p_org_id||',sob:'||ln_sob_id); END IF;/*Bug 5879769 bduvarag*/

    -- this is required for to rollback the changes made in this procedure incase any unexpected error
    -- SAVEPOINT start_payments;

    -- ~~~~~~~~~~ Payables Processing ~~~~~~~~~~
    -- Logic to Insert data into REFERENCEs Table
    -- if the invoice is cancelled, then no references are populated so that the lines are not processed against any
    -- Payements/Voids that are present for this invoice
    FOR ap_acc_dist IN c_ap_accounted_inv_dist( 'Purchase Invoices', p_trx_from_date, p_trx_to_date, ln_sob_id) LOOP/*Bug 5879769 bduvarag*/

    IF p_debug = 'Y' THEN fnd_file.put_line(fnd_file.log, 'Enter3 - ap_event_id:'||ap_acc_dist.accounting_event_id); END IF;

    --Bug 4991017. Added by Lakshmi gopalsami
    -- Removed the FOR.. LOOP dist.

      IF p_debug = 'Y' THEN fnd_file.put_line(fnd_file.log, 'Enter4 - invid:'||ap_acc_dist.invoice_id
        ||', LineNum:'||ap_acc_dist.invoice_line_number ||',distid:'||ap_acc_dist.distribution_line_number); END IF;

      -- Initialization Point
      ln_reference_id   := null;
      ln_item_line_id   := null;
      ln_item_id        := null;

      r_ref             := null;
      r_tax_dist_dtl    := null;
      r_parent_dist     := null;
      r_parent_ref      := null;

      OPEN c_reference(jai_constants.source_ap, ap_acc_dist.invoice_id, ap_acc_dist.invoice_distribution_id);    -- , r_tax_dist_dtl.tax_id);
      FETCH c_reference INTO r_ref;
      CLOSE c_reference;

      -- following condition is satisfied if the invoice line is already inserted into REFERENCEs table
      IF r_ref.reference_id IS NOT NULL THEN
        IF p_debug = 'Y' THEN
          fnd_file.put_line(fnd_file.log, 'Enter5 - Return Ref NotNull');
        END IF;
        GOTO end_of_reference_insertion;
      END IF;

      -- ~~~~~~~~~~~~~~~~~~~~~~~~~ POPULATION Logic for Data Entry into JAI_RGM_TRX_REFS ~~~~~~~~~~~~~~~~~~~~~~~~
      -- following condition is satisfied for REVERSAL lines
      IF ap_acc_dist.reversal_flag = 'Y' AND ap_acc_dist.parent_reversal_id IS NOT NULL THEN
        OPEN c_invoice_distribution(ap_acc_dist.parent_reversal_id);
        FETCH c_invoice_distribution INTO r_parent_dist;
        CLOSE c_invoice_distribution;

        OPEN c_tax_dist_dtl(p_regime_id, r_parent_dist.invoice_id, r_parent_dist.invoice_distribution_id );  -- distribution_line_number );
        FETCH c_tax_dist_dtl INTO r_tax_dist_dtl;
        CLOSE c_tax_dist_dtl;

      ELSIF NVL(ap_acc_dist.source,'$$$') = 'INDIA TAX INVOICE' THEN --'RECEIPT' THEN --Ramanand for bug#4388958
        /*
        || above elsif added by ssumaith - bug# 4284505
        || NVL(ap_acc_dist.source,'$$$') = 'INDIA TAX INVOICE' --'RECEIPT' - It means a third party invoice.is being processed. ----Ramanand for bug#4388958

        || nvl(r_tax_dist_dtl.chk, 0) = 0  means that no records were found in the JAI_AP_MATCH_INV_TAXES table.
        || For third party invoices , there will be no records in the JAI_AP_MATCH_INV_TAXES table
        || For third party invoices , the tax details need to be picked up from the jai_rcv_tp_inv_details table.
        || It should be joined to the jai_rcv_tp_.invoices table based on the batch_invoice_id column and
        || we arrive at the correct batch_invoice_id based on the invoice_id link between the third party
        || invoice and jai_rcv_tp_invoices table.
        || Using this link, if the r_tax_dist_dtl is populated, it will take its normal course.
        */

        OPEN  c_tp_inv_details(p_regime_id , ap_acc_dist.invoice_id , ap_acc_dist.invoice_line_number); /* INVOICE LINES UPTAKE distribution_line_number); */
        FETCH c_tp_inv_Details INTO  r_tax_dist_dtl;
        CLOSE c_tp_inv_Details;

      -- Normal Distribution and not a Reversal and not a third party distribution
      ELSE
        OPEN c_tax_dist_dtl(p_regime_id, ap_acc_dist.invoice_id, ap_acc_dist.invoice_distribution_id); -- AP INVOICE LINES UPTAKE ap_acc_dist.distribution_line_number);   --
        FETCH c_tax_dist_dtl INTO r_tax_dist_dtl;
        CLOSE c_tax_dist_dtl;

      END IF;

      IF nvl(r_tax_dist_dtl.chk, 0) = 0 THEN
        IF p_debug = 'Y' THEN
          fnd_file.put_line(fnd_file.log, 'Enter6 - DistChk is 0');
        END IF;

        GOTO end_of_reference_insertion;
      END IF;

      IF r_tax_dist_dtl.recoverable_ptg = 0 THEN
        IF p_debug = 'Y' THEN
          fnd_file.put_line(fnd_file.log, 'Enter7 - recov_ptg is 0');
        END IF;
        FND_FILE.put_line( FND_FILE.log, 'Invoice_id, LineNum, DistNum->'||ap_acc_dist.invoice_id
            ||','||ap_acc_dist.invoice_line_number||','||ap_acc_dist.distribution_line_number||' is not Recoverable');
        GOTO end_of_reference_insertion;
      END IF;

      IF r_tax_dist_dtl.parent_invoice_distribution_id IS NOT NULL THEN
        ln_item_line_id := r_tax_dist_dtl.parent_invoice_distribution_id;
      /* Bug 7172723. Added by Lakshmi Gopalsami
       * If it is third party invoice there is no reference item line.
       * and so the dist line itself is the parent.
       * assigning the invoice_distribution_id of ST tax itself
       */
      ELSIF NVL(ap_acc_dist.source,'$$$') = 'INDIA TAX INVOICE' THEN
       ln_item_line_id := ap_acc_dist.invoice_distribution_id;

    ELSIF r_tax_dist_dtl.chk = 2 then --Added this elsif condition for bug#8943349 by JMEENA

       ln_item_line_id  := r_tax_dist_dtl.invoice_line_number;

      ELSE
        ln_item_line_id := get_item_line_id(
                    p_invoice_id          => ap_acc_dist.invoice_id,
                    p_po_distribution_id  => ap_acc_dist.po_distribution_id,
                    p_rcv_transaction_id  => ap_acc_dist.rcv_transaction_id
                   );
      END IF;

      OPEN c_item_id(ap_acc_dist.po_distribution_id);
      FETCH c_item_id INTO ln_item_id;
      CLOSE c_item_id;

      IF ap_acc_dist.parent_reversal_id is not null then  /* condition introduced for AP LINES Uptake Project */
        OPEN c_reference(jai_constants.source_ap, ap_acc_dist.invoice_id, ap_acc_dist.parent_reversal_id);    -- , r_tax_dist_dtl.tax_id);
        FETCH c_reference INTO r_parent_ref;
        CLOSE c_reference;
      END IF;

      ln_recoverable_amount := ap_acc_dist.amount ; /*  r_tax_dist_dtl.recoverable_ptg/100 commented for bug 7684820 */
      lv_process_flag       := null;

      savepoint start_of_ref;

      jai_cmn_rgm_recording_pkg.insert_reference(
        p_reference_id          => ln_reference_id,    -- OUT Variable
        p_organization_id       => p_organization_id,/*5694855*/
        p_source                => jai_constants.source_ap,
        p_invoice_id            => ap_acc_dist.invoice_id,
        p_line_id               => ap_acc_dist.invoice_distribution_id,
        p_tax_type              => r_tax_dist_dtl.tax_type,
        p_tax_id                => r_tax_dist_dtl.tax_id,
        p_tax_rate              => r_tax_dist_dtl.tax_rate,
        p_recoverable_ptg       => r_tax_dist_dtl.recoverable_ptg,
        p_recoverable_amount    => ln_recoverable_amount,
        p_party_type            => jai_constants.party_type_vendor,
        p_party_id              => ap_acc_dist.vendor_id,
        p_party_site_id         => ap_acc_dist.vendor_site_id,
        p_tax_amount            => ap_acc_dist.amount,
        p_recovered_amount      => 0,
        p_taxable_basis         => r_tax_dist_dtl.base_amount,       -- CHK << what amount i should populate >>
        p_item_line_id          => ln_item_line_id,
        p_item_id               => ln_item_id,
        p_trx_tax_amount        => ap_acc_dist.amount,
        p_trx_currency          => ap_acc_dist.invoice_currency_code,
        p_curr_conv_date        => ap_acc_dist.exchange_date,
        p_curr_conv_rate        => ap_acc_dist.exchange_rate,
        p_parent_reference_id   => r_parent_ref.reference_id,
        p_reversal_flag         => ap_acc_dist.reversal_flag,
        p_batch_id              => p_batch_id,
        p_process_flag          => lv_process_flag,
        p_process_message       => lv_process_message
      );

      IF lv_process_flag IN (jai_constants.expected_error, jai_constants.unexpected_error) THEN
        -- RAISE_APPLICATION_ERROR( -20201, p_process_flag||':'||p_process_message);
        -- ERROR RECORDING should be there for all errored records, so that we can code the processing in future. CHK
        ROLLBACK TO start_of_ref;
        p_process_flag    := lv_process_flag;
        p_process_message := lv_process_message;
      END IF;

      ln_uncommited_trxs := ln_uncommited_trxs + 1;
      IF ln_uncommited_trxs >= ln_commit_interval THEN
        COMMIT;
        ln_uncommited_trxs := 0;
      END IF;

      IF p_debug = 'Y' THEN fnd_file.put_line(fnd_file.log, 'Enter8 - Inserted Reference:'||ln_reference_id); END IF;

      <<end_of_reference_insertion>>
      NULL;

    -- Bug 4991017. Added by Lakshmi Gopalsami.
    -- Removed the END LOOP as the two cursors has been merged.

    END LOOP;     -- ap_acc_dist for Operating Unit

    -- Logic to Make Register Entry for the Invoice Distributions that are populated into REFERENCES table and which are PAID
    -- Prior to the start date of this concurrent program. This is because localization only considers invoices that are accounted
    FOR invo IN c_batch_references(p_batch_id, jai_constants.source_ap) LOOP

      -- Logic to Process the PAST DATED PAYMENTS that are not processed due to Invoice Accounting did not happen
      FOR inv_payment IN c_previous_payments_of_inv(invo.invoice_id, p_trx_from_date) LOOP

        FOR dist IN c_invoice_batch_refs(jai_constants.source_ap, p_batch_id, invo.invoice_id) LOOP

        lv_process_flag := null;

        SAVEPOINT process_payment;

        process_payment(
          p_batch_id                => p_batch_id,
          p_regime_id               => p_regime_id,
          p_org_id                  => inv_payment.org_id,
          p_source                  => jai_constants.source_ap,
          p_payment_table_name      => jai_constants.ap_payments,
          p_payment_document_id     => inv_payment.invoice_payment_id,
          p_invoice_id              => dist.invoice_id,
          p_inv_dist_id             => dist.line_id,
          p_inv_accounting_chk_done => jai_constants.yes,
          p_process_flag            => lv_process_flag,
          p_process_message         => lv_process_message
        );


        -- "FP" Means means future payment and it is not yet matured, so
        --IF p_process_flag = 'FP' THEN
        --ELS
        IF lv_process_flag IN (jai_constants.expected_error, jai_constants.unexpected_error) THEN
          ROLLBACK TO process_payment;
          --retcode := jai_constants.request_warning;
          p_process_flag    := lv_process_flag;
          p_process_message := lv_process_message;
        END IF;

        ln_uncommited_trxs := ln_uncommited_trxs + 1;
        IF ln_uncommited_trxs >= ln_commit_interval THEN
          COMMIT;
          ln_uncommited_trxs := 0;
        END IF;

        END LOOP;       -- invoice distributions

      END LOOP;       -- invoice payments

      -- Logic to Process the PAST DATED PREPAYMENTS that are not processed due to Invoice Accounting did not happen
    FOR pp IN c_period_payments( p_trx_from_date, p_trx_to_date) LOOP

        FOR dist IN c_invoice_batch_refs(jai_constants.source_ap, p_batch_id, invo.invoice_id) LOOP

          lv_process_flag := null;

          SAVEPOINT process_prepayment;
          process_payment(
            p_batch_id                => p_batch_id,
            p_regime_id               => p_regime_id,
            p_org_id                  => pp.org_id,
            p_source                  => jai_constants.source_ap,
            p_payment_table_name      => jai_constants.ap_prepayments,
            p_payment_document_id     => pp.invoice_distribution_id,
            p_invoice_id              => dist.invoice_id,
            p_inv_dist_id             => dist.line_id,
            p_inv_accounting_chk_done => jai_constants.yes,
            p_process_flag            => lv_process_flag,
            p_process_message         => lv_process_message
          );

          IF lv_process_flag IN (jai_constants.expected_error, jai_constants.unexpected_error) THEN
            ROLLBACK TO process_prepayment;
            -- retcode := jai_constants.request_warning;
            p_process_flag    := lv_process_flag;
            p_process_message := lv_process_message;
          END IF;

          ln_uncommited_trxs := ln_uncommited_trxs + 1;
          IF ln_uncommited_trxs >= ln_commit_interval THEN
            COMMIT;
            ln_uncommited_trxs := 0;
          END IF;

        END LOOP;       -- invoice distributions

      END LOOP;       -- invoice prepayments

    END LOOP;       -- batch_references

    -- Logic to Process Payments that fall for the specified period
    /*
    ||Cursor for Loops c_period_payments and c_invoice_distributions merged into c_period_payments by aiyer for the bug 4947102
    || This has been done to derive performance improvement
    || SQL ID 14828450
    */
    FOR inv_payment IN c_period_payments( p_trx_from_date, p_trx_to_date) LOOP
        lv_process_flag := null;

        IF g_debug='Y' THEN fnd_file.put_line(fnd_file.log,'PeriodPay. Inv,DistId:'||inv_payment.invoice_id||','||inv_payment.invoice_distribution_id); END IF;

        SAVEPOINT process_payment;

        process_payment(
          p_batch_id                => p_batch_id,
          p_regime_id               => p_regime_id,
          p_org_id                  => inv_payment.org_id,
          p_source                  => jai_constants.source_ap,
          p_payment_table_name      => jai_constants.ap_payments,
          p_payment_document_id     => inv_payment.invoice_payment_id,
          p_invoice_id              => inv_payment.invoice_id,
          p_inv_dist_id             => inv_payment.invoice_distribution_id,
          p_inv_accounting_chk_done => jai_constants.no,
          p_process_flag            => lv_process_flag,
          p_process_message         => lv_process_message
        );

        IF lv_process_flag IN (jai_constants.expected_error, jai_constants.unexpected_error) THEN
          ROLLBACK TO process_payment;
          -- retcode := jai_constants.request_warning;
          p_process_flag    := lv_process_flag;
          p_process_message := lv_process_message;
        END IF;

        ln_uncommited_trxs := ln_uncommited_trxs + 1;
        IF ln_uncommited_trxs >= ln_commit_interval THEN
          COMMIT;
          ln_uncommited_trxs := 0;
        END IF;

    END LOOP;

    -- Logic to Process Prepayment Applications onto standard invoices that fall in the processing period
    FOR pp IN c_prepayment_applications(p_trx_from_date, p_trx_to_date) LOOP

      FOR dist IN c_invoice_distributions(pp.invoice_id) LOOP

        lv_process_flag := null;

        SAVEPOINT process_prepayment;

        process_payment(
          p_batch_id                => p_batch_id,
          p_regime_id               => p_regime_id,
          p_org_id                  => pp.org_id,
          p_source                  => jai_constants.source_ap,
          p_payment_table_name      => jai_constants.ap_prepayments,
          p_payment_document_id     => pp.invoice_distribution_id,
          p_invoice_id              => dist.invoice_id,
          p_inv_dist_id             => dist.invoice_distribution_id,
          p_inv_accounting_chk_done => jai_constants.no,
          p_process_flag            => lv_process_flag,
          p_process_message         => lv_process_message
        );

        IF lv_process_flag IN (jai_constants.expected_error, jai_constants.unexpected_error) THEN
          ROLLBACK TO process_prepayment;
          -- retcode := jai_constants.request_warning;
          p_process_flag    := lv_process_flag;
          p_process_message := lv_process_message;
        END IF;

        ln_uncommited_trxs := ln_uncommited_trxs + 1;
        IF ln_uncommited_trxs >= ln_commit_interval THEN
          COMMIT;
          ln_uncommited_trxs := 0;
        END IF;

      END LOOP;

    END LOOP;   -- Prepayments

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      -- retcode := jai_constants.request_error;
      -- errbuf := 'Unexpected Error Occured:'||SQLERRM;
      p_process_flag    := jai_constants.unexpected_error;
      p_process_message := 'Unexpected Error Occured in Process_Payments:'||SQLERRM;
      FND_FILE.put_line( fnd_file.log, 'Unexpected Error Occured:'||p_process_message);

  END process_payments;

/*
 CREATED BY       : ssumaith
 CREATED DATE     : 15-MAR-2005
 ENHANCEMENT BUG  : 4245053
 PURPOSE          : wrapper program to interpret the input parameters and suitably call program to
                    generate vat imvoice number and pass accounting during shipment
 CALLED FROM      : Concurrent program JAIVATP

 */


-- foll function created by kunkumar - for seperate vat invoice num for unreg dealers - bug# 5233925


FUNCTION  check_reg_dealer ( pn_customer_id  NUMBER ,
                               pn_site_use_id  NUMBER ) return boolean

  IS
   ln_address_id   NUMBER;
   lv_regno        JAI_CMN_CUS_ADDRESSES.vat_Reg_no%type;


   CURSOR c_get_address is
   SELECT hzcas.cust_acct_site_id
   FROM   hz_cust_site_uses_all         hzcsu ,
          hz_cust_acct_sites_all        hzcas
   WHERE  hzcas.cust_acct_site_id   =   hzcsu.cust_acct_site_id
   AND    hzcsu.site_use_id         =   pn_site_use_id
   AND    hzcas.cust_account_id     =   pn_customer_id ;

   CURSOR c_regno (pn_address_id NUMBER) IS
   SELECT vat_Reg_no
   FROM   JAI_CMN_CUS_ADDRESSES
   WHERE  customer_id = pn_customer_id
   AND    address_id  = pn_address_id;

  BEGIN

     open   c_get_address;
     fetch  c_get_address into ln_address_id;
     close  c_get_address;
 IF  ln_address_id IS NOT NULL THEN

       open   c_regno (ln_address_id);
       fetch  c_regno into lv_regno;
       close  c_regno;
     END IF;

     IF   lv_regno IS NULL THEN
        return (false);
     ELSE
         return (true);
     END IF;


  END  check_reg_dealer;

  /*
  || kunkumar - for seperate vat invoice num for unreg dealers  - bug# 5233925
  */




  PROCEDURE process (
                     retcode OUT NOCOPY VARCHAR2,
                     errbuf OUT NOCOPY VARCHAR2,
                     p_regime_id                     JAI_RGM_DEFINITIONS.REGIME_ID%TYPE,
                     p_registration_num              JAI_RGM_TRX_RECORDS.REGIME_PRIMARY_REGNO%TYPE,
                     p_organization_id               JAI_OM_WSH_LINES_ALL.ORGANIZATION_ID%TYPE,
                     p_location_id                   JAI_OM_WSH_LINES_ALL.LOCATION_ID%TYPE,
                     -- added by Allen Yang  for bug 9485355 (12.1.3 non-shippable Enhancement), begin
                     p_order_number_from            OE_ORDER_HEADERS_ALL.ORDER_NUMBER%TYPE,
                     p_order_number_to              OE_ORDER_HEADERS_ALL.ORDER_NUMBER%TYPE,
                     -- added by Allen Yang  for bug 9485355 (12.1.3 non-shippable Enhancement), end
                     p_delivery_id_from              JAI_OM_WSH_LINES_ALL.DELIVERY_ID%TYPE,
                     p_delivery_id_to                JAI_OM_WSH_LINES_ALL.DELIVERY_ID%TYPE,
                     pv_delivery_date_from            VARCHAR2, --DATE, Harshita for Bug 4918870
                     pv_delivery_date_to              VARCHAR2, --DATE, Harshita for Bug 4918870
                     p_process_action                VARCHAR2,
                     p_single_invoice_num            VARCHAR2,
                     p_override_invoice_date         VARCHAR2, /* aiyer for the bug 5369250 */
                     p_debug                         VARCHAR2
                    )
    IS
/*************************************************************************************************************************************
    Purpose:-
    || It processes single / multiple deliveries based on the parameters entered.
    || In a loop , each delivery is processed and two tasks are done based upon the p_process_action parameter
    || If the p_process_action = 'Generate Invoice Number' or p_process_action = 'All' then the subsection a) happens.
    || If the p_process_action = 'Process Accounting' or p_process_action = 'All' then the subsection b) happens.
    ||
    || a) make a call to an api to generate vat invoice number depending on various settings
    ||    a.1) If the Parameter p_single_invoice_num is set to 'Y' , then for all the deliveries of a cust / cust site  a single
    ||         invoice number is generated. The call happen to the procedure to generate the vat invoice number just once
    ||         and the same value retained for this record set of same cust / cust site
    ||    a.2) If the parameter p_single_invoice_num is set to 'N' , then for each delivery a seperate vat invoice number
    ||         will be generated.
    || If the generate vat invoice number api returns error , then the subsection b will not be processed and the delivery
    || will be flagged as errored in the table JAI_RGM_INVOICE_GEN_T for the delivery_id
    ||
    || b) make a call to the api to process accounting
    ||
    ||    b.1 If it returns success then if the p_process_action = 'All' then flag both the fields VAT_INV_GEN_STATUS
    ||        and VAT_ACCT_STATUS are to be set to completed  - 'C'
    ||        commit the delivery and continue with the next delivery
    ||
    ||        If it returns error (either expected error or unexpected error) and if the p_process_action = 'All' then
    ||        flag the fields VAT_INV_GEN_STATUS and VAT_ACCT_STATUS as - Errored 'E'
    ||        Rollback the delivery and continue with the next delivery.
    ||
    Change History -
1.   29/07/2005   Aiyer - bug# 4523205 - File version 120.2 - (R12 Forward Porting FROM 11.5 bugs 4348774, 4357984)

                  Issues :
                  -------
                  1. The concurrent program is picking up all records irrespective of the registration number passed
                     in the parameter.
                  2. (Logged in bug 4534166) Returning clause is not required, hence needs to be removed 4357984.

                  Fix :
                  -----
                  1.The issue has been fixed by adding the p_registration_num and p_Regime_id in the where clause.
                  2.As the returning clause was not required and hence was removed. Also added the fnd_file log in
                    the exception section of the procedure.

                 Dependency due to this bug:-
                 None
2.      05-Jul-2006  Aiyer for the bug 5369250, Version  120.7
                 Issue:-
                 --------
                   The concurrent failes with the following error :-
                   "FDPSTP failed due to ORA-01861: literal does not match format string ORA-06512: at line 1 "

                 Reason:-
                ---------
                   The procedure PROCESS had a parameters p_override_invoice_date of type date , however the concurrent program
                   passes it in the canonical format and hence the failure.

                 Fix:-
                -----------
                  Modified the procedure update_excise_invoice_no.
                  Changed the datatype of p_override_invoice_date from date to varchar2 as this parameter.
                  Also added the new parameter ld_override_invoice_date . The value in p_override_invoice_date would be converted to date format and
                  stored in the local variable ld_override_invoice_date.

                 Dependency due to this fix:-
                  None

3.    3-Feb-2007 srjayara for bug 4702156, file version 120.8
                 Forward porting for 11i bug#4542996

     Issue:-
                 --------
                 VAT invoice number and accounting was not happening for all the delivery lines in a delivery.

                 Fix:-
                 ------
                 Possible reason identified is that the all lines are not inventory interfaced at the same time and
                 hence only those lines which are inventory interfaced are considered at the time vat processing concurrent
                 runs.
                 Added a check that only if all the delivery details are inventory interfaced , the delivery needs to be considered.

4.    4-jun-2007 ssumaith - bug#6109941 -
                 The Service tax by IO code was incorrectly forward ported to R12. There were some code missing and operating unit was being passed instead of inventory org. Such code has been corrected.


5    07-jun-2007  ssumaith - bug# 6109941 - divisor by zero error was coming . this has been resolved by checking
                  for zero divides before the divide is done.

6   25-jun-2007  ssumaith - bug#6147385 - when all delivery details in a delivery are not interfaced trip stopped
                 then, the program was returning instead of processing the next delivery.
                 It was because of a return statement, instead added the code to process the next delivery and increment the failure counter.

                Adde the nvl condition in the where clauseto use the table's registration number its passed as null
11. 12-Jul-2007   CSahoo for bug#6176277, File Version 120.20
                  assigned the variable ln_excise_invoice_not_done to NULL before opening the cursor.

12. 13-jul-2007  ssumaith - bug# 6176277 - The variable - lv_inv_gen_process_flag was not re-initialised
                 re-initialised the variables - lv_inv_gen_process_flag , lv_inv_gen_process_message to NULL

13.   04-JUN-2009 JMEENA for bug#8574533
    Reset the variable ln_interface_status to zero before fetching the value from cursor c_check_interface_status

14.   07-Jul-2009  Bug 7347127 File version 120.7.12000000.14/120.27.12010000.8/120.35
                   Modified the cursor c_ap_accounted_inv_dis so that it may use the index on accounting_date
       column if required. This is the forward port of 11i bug 7280631.

15. 02-Apr-2010  Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement)
       Issue: currently, procedure 'process' only handles shippable items
       Fix: logic in procedure 'process' should be modified to process both shippable and
            non-shippable lines.
16.  28-Apr-2010  Allen Yang for bug 9666476
                  In procedure 'process':
                  1) added 'NULLS FIRST' into Order By clause of sql_stmt_all
                  to ensure shippable items are always processed before non-shippable items.
                  2) removed order_number from Order By clause of sql_stmt_shippable
17.  13-May-2010  Allen Yang for bug 9709477
                  1). added warning message when flags Same as Excise and Generate Single Invoice are both Y.
18.  03-Jun-2010  Allen Yang for bug 9737119
                  Issue: TST1213.XB1.QA.EXECPT DIAGNOSTICS,WARNING MESSAGE SHOULD ALSO BE SEEN IN LOG
                  Fix: In procedure 'process', added logic to put message lv_same_as_excise_conf_warning to Log.
**************************************************************************************************************************************/

    lv_acct_process_flag            VARCHAR2(10);
    lv_inv_gen_process_flag         VARCHAR2(10);
    lv_inv_gen_process_message      VARCHAR2(1996);
    lv_acct_process_message         VARCHAR2(1996);
    lv_invoice_generated            VARCHAR2(100);
    lv_vat_invoice_number           VARCHAR2(100);
    ln_failure_delivery_ctr         NUMBER;
    ln_success_delivery_Ctr         NUMBER;
    ln_regime_id                    NUMBER;
    lv_debug                        VARCHAR2(5); --  := jai_constants.no  /*  This should be either 'Y' or 'N' */ File.Sql.35 by Brathod
    ln_order_type_id                JAI_OM_WSH_LINES_ALL.ORDER_TYPE_ID%TYPE;
    lv_inv_num_already_generated    VARCHAR2(10); --:= jai_constants.value_false File.Sql.35 by Brathod
    ln_batch_id                     NUMBER;
    lv_regime_code                  JAI_RGM_DEFINITIONS.REGIME_CODE%TYPE;
    ln_current_party_id             NUMBER;
    ln_current_party_site_id        NUMBER;
    lv_party_has_changed            VARCHAR2(10);
    ln_conc_progam_id               NUMBER;
    ln_conc_request_id              NUMBER;
    ln_conc_prog_appl_id            NUMBER;
    lv_Same_invoice_no              VARCHAR2(100);
    lv_excise_invoice_no            JAI_OM_WSH_LINES_ALL.EXCISE_INVOICE_NO%TYPE;
    ld_excise_invoice_date          JAI_OM_WSH_LINES_ALL.EXCISE_INVOICE_DATE%TYPE;
    lb_completion_status            BOOLEAN;
    ld_override_invoice_date        DATE; /* aiyer for the bug 5369250 */
    lv_doc_type_class               varchar2(2); /*kunkumar for bug #5233925*/

    -- added by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
    lv_SQLStmt                      VARCHAR2(2000);
    v_main_rec_cur                  MainRec_Cur;
    mainrec                         MainRecord;
    ln_current_order_number         NUMBER;
    lv_order_has_changed            VARCHAR2(10);
    lv_p_source                     VARCHAR2(30);

    lv_p_registration_num_str           VARCHAR2(200);

    sql_stmt_shippable     VARCHAR2(2000);
    sql_stmt_all           VARCHAR2(2000);
    -- added by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), end

    -- added by Allen Yang for bug 9709477 13-May-2010, begin
    lv_same_as_excise_conf_warning VARCHAR2(2000);
    -- added by Allen Yang for bug 9709477 13-May-2010, end

    CURSOR c_regime_cur(cp_trx_Date DATE) IS
    SELECT regime_id
    FROM   JAI_RGM_DEFINITIONS
    WHERE  regime_code = jai_constants.vat_regime;

    -- modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
    CURSOR c_shipment_info(cp_Delivery_id   JAI_OM_WSH_LINES_ALL.DELIVERY_ID%TYPE
                         , cp_order_line_id JAI_OM_WSH_LINES_ALL.ORDER_LINE_ID%TYPE)
    IS
    SELECT order_type_id , excise_invoice_no
    FROM   JAI_OM_WSH_LINES_ALL
    --WHERE  delivery_id = cp_delivery_id;
    WHERE  delivery_id = cp_delivery_id
       OR  (delivery_id IS NULL AND order_line_id = cp_order_line_id);
    -- modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), end

    CURSOR c_same_inv_no(cp_organization_id JAI_OM_WSH_LINES_ALL.ORGANIZATION_ID%TYPE , cp_location_id JAI_OM_WSH_LINES_ALL.location_id%TYPE ) IS
    SELECT attribute_Value
    FROM   JAI_RGM_ORG_REGNS_V
    WHERE  regime_id = p_regime_id
    AND    attribute_type_code = jai_constants.regn_type_others
    AND    attribute_code = jai_constants.attr_code_same_inv_no
    AND    organization_id = cp_organization_id
    AND    location_id = cp_location_id;

    CURSOR c_excise_invoice_not_done ( cp_Delivery_id JAI_OM_WSH_LINES_ALL.DELIVERY_ID%TYPE)IS
    SELECT 1
    FROM   JAI_OM_OE_GEN_TAXINV_T
    WHERE  delivery_id = cp_delivery_id;

    ln_excise_invoice_not_done NUMBER;

    /*srjayara for bug 4702156*/

    /*
    || The following cursor is added to check that all the delivery lines in the delivery are inventory interfaced
    */
    CURSOR c_check_interface_status (cp_delivery_id NUMBER) IS
    SELECT 1
    FROM
           wsh_delivery_details            wdd     ,
           wsh_new_deliveries              wnd     ,
           wsh_delivery_assignments        wda
    WHERE
           wdd.delivery_detail_id = wda.delivery_detail_id             AND
           wda.Delivery_Id        = wnd.Delivery_Id                    AND
           wnd.Delivery_Id        = cp_delivery_id                 AND
           wdd.source_code        = 'OE'                               AND
           NVL(wdd.inv_interfaced_flag,'N') <> 'Y';

    /*Bug 6031031 - Start*/
    -- modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
    CURSOR c_vat_inv_gen_status (cp_delivery_id jai_rgm_invoice_gen_t.delivery_id%type
                                ,cp_order_line_id jai_rgm_invoice_gen_t.order_line_id%type)
    IS
    SELECT vat_inv_gen_status
    FROM JAI_RGM_INVOICE_GEN_T
    --WHERE delivery_id = cp_delivery_id ;
    WHERE delivery_id = NVL(cp_delivery_id, -1)
       OR order_line_id = NVL(cp_order_line_id, -1);
    -- modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), end
    lv_vat_inv_gen_status VARCHAR2(1);
    /*Bug 6031031 - End*/

    -- added by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
    CURSOR c_get_excise_from_shippable (cp_order_number jai_rgm_invoice_gen_t.order_number%TYPE)
    IS
    SELECT jowla.excise_invoice_no
          ,jowla.excise_invoice_date
    FROM   JAI_RGM_INVOICE_GEN_T jrigt
         , JAI_OM_WSH_LINES_ALL  jowla
    WHERE  jrigt.program_id = ln_conc_progam_id
    AND    jrigt.delivery_id = jowla.delivery_id
    AND    jowla.excise_invoice_no IS NOT NULL
    AND    EXISTS (SELECT 1
                   FROM WSH_DELIVERY_DETAILS     wdd
                       ,WSH_DELIVERY_ASSIGNMENTS wda
                       ,OE_ORDER_HEADERS_ALL     ooha
                   WHERE ooha.order_number = cp_order_number
                   AND   ooha.header_id = wdd.source_header_id
                   AND   wda.delivery_detail_id = wdd.delivery_detail_id
                   AND   wda.delivery_id = jrigt.delivery_id)
    AND    rownum = 1;
    -- added by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), end

    ln_interface_status  NUMBER;

    /*end bug 4702156*/

    -- Harshita for Bug 4918870
    p_delivery_date_from DATE DEFAULT fnd_date.canonical_to_date(pv_delivery_date_from);
    p_delivery_date_to   DATE DEFAULT fnd_date.canonical_to_date(pv_delivery_date_to);

   BEGIN
     /*
     ||aiyer for the bug 5369250
     ||convert from canonical to date format
     */
      ld_override_invoice_date := fnd_date.canonical_to_date(p_override_invoice_date);
        lv_inv_num_already_generated := jai_constants.value_false;  -- File.Sql.35 by Brathod
        lv_debug := NVL(P_DEBUG,jai_constants.no);
        ln_current_party_id := -9999;
        ln_current_party_site_id := -9999;
        -- added by Allen Yang for for bug 9485355 (12.1.3 non-shippable Enhancement), begin
        ln_current_order_number  := -9999;
        ln_regime_id := p_regime_id ;
        -- added by Allen Yang for for bug 9485355 (12.1.3 non-shippable Enhancement), end
        IF lv_debug = 'Y' THEN
           Fnd_File.PUT_LINE(Fnd_File.LOG, ' 1. Entered in the proc with parameters :');
           Fnd_File.PUT_LINE(Fnd_File.LOG, ' P_REGIME_ID  :' || P_REGIME_ID);
           Fnd_File.PUT_LINE(Fnd_File.LOG, ' P_REGISTRATION_NUM  :' || P_REGISTRATION_NUM);
           Fnd_File.PUT_LINE(Fnd_File.LOG, ' P_ORGANIZATION_ID :'  || P_ORGANIZATION_ID);
           Fnd_File.PUT_LINE(Fnd_File.LOG, ' P_LOCATION_ID  :' || P_LOCATION_ID);
           -- added by Allen Yang for for bug 9485355 (12.1.3 non-shippable Enhancement), begin
           Fnd_File.PUT_LINE(Fnd_File.LOG, ' P_ORDER_NUMBER_FROM  :' || P_ORDER_NUMBER_FROM);
           Fnd_File.PUT_LINE(Fnd_File.LOG, ' P_ORDER_NUMBER_TO  :' || P_ORDER_NUMBER_TO);
           -- added by Allen Yang for for bug 9485355 (12.1.3 non-shippable Enhancement), end
           Fnd_File.PUT_LINE(Fnd_File.LOG, ' P_DELIVERY_ID_FROM :' || P_DELIVERY_ID_FROM);
           Fnd_File.PUT_LINE(Fnd_File.LOG, ' P_DELIVERY_ID_TO :'   || P_DELIVERY_ID_TO);
           Fnd_File.PUT_LINE(Fnd_File.LOG, ' P_DELIVERY_DATE_FROM :' ||   P_DELIVERY_DATE_FROM);
           Fnd_File.PUT_LINE(Fnd_File.LOG, ' P_DELIVERY_DATE_TO : ' ||     P_DELIVERY_DATE_TO);
           Fnd_File.PUT_LINE(Fnd_File.LOG, ' P_PROCESS_ACTION :'   ||   P_PROCESS_ACTION);
           Fnd_File.PUT_LINE(Fnd_File.LOG, ' P_SINGLE_INVOICE_NUM :' ||  P_SINGLE_INVOICE_NUM);
           Fnd_File.PUT_LINE(Fnd_File.LOG, ' P_OVERRIDE_INVOICE_DATE :' ||P_OVERRIDE_INVOICE_DATE);
        END IF;
        ln_conc_progam_id     := FND_GLOBAL.conc_program_id;
        ln_conc_request_id    := FND_GLOBAL.conc_request_id;
        ln_conc_prog_appl_id  := FND_GLOBAL.prog_appl_id;
        lv_inv_gen_process_flag     := jai_constants.successful;
        lv_acct_process_flag        := jai_constants.successful;
        lv_inv_gen_process_message  := NULL;
        lv_acct_process_message     := NULL;
        ln_batch_id := ln_conc_request_id;

        ln_failure_delivery_ctr     :=0;
        ln_success_delivery_Ctr     :=0;
  ln_interface_status         :=0; /*added by srjayara for bug 4702156*/

       IF P_PROCESS_ACTION IS NULL  THEN
          Fnd_File.PUT_LINE(Fnd_File.LOG, ' +++ P_PROCESS_ACTION parameter IS NULL Hence returning +++ ' );
          RETURN;
       END IF;

       -- modified by Allen Yang for for bug 9485355 (12.1.3 non-shippable Enhancement), begin

       /* only for the below two cases, non-shippable items will be ignored and don't be
          processed. So different SQL queries are used here.
          1. p_delivery_id_from and p_delivery_id_to are both NOT NULL
          2. p_delivery_id_from IS NOT NULL OR p_delivery_id_to IS NOT NULL and
             p_order_number_from/p_order_number_to are both NULL.
       */
       IF p_registration_num IS NULL
       THEN
         lv_p_registration_num_str := 'NULL';
       ELSE
         lv_p_registration_num_str := '''' || p_registration_num || '''';
       END IF; -- IF p_registration_num IS NULL

       sql_stmt_shippable
    := 'SELECT delivery_id , delivery_date , organization_id , location_id , vat_invoice_no, '||
            'party_id , party_site_id , party_type , vat_inv_gen_status , vat_acct_status, '||
            'order_line_id, order_number ' ||
     'FROM   JAI_RGM_INVOICE_GEN_T jrigt ' ||
     'WHERE  regime_id        = '||p_regime_id ||' '||
       'AND    registration_num = NVL('||lv_p_registration_num_str||',registration_num) '||
       'AND    (delivery_id BETWEEN NVL('||NVL(TO_CHAR(p_delivery_id_from), 'NULL')||',delivery_id) AND '||
                                     'NVL('||NVL(TO_CHAR(p_delivery_id_to), 'NULL')||',delivery_id)) '||
       'AND EXISTS (SELECT 1 FROM WSH_DELIVERY_DETAILS wdd '||
                                ',WSH_DELIVERY_ASSIGNMENTS wda '||
                                ',OE_ORDER_HEADERS_ALL ooha '||
                    'WHERE ooha.order_number BETWEEN '||
                             'NVL('||NVL(TO_CHAR(p_order_number_from), 'NULL')||',order_number) AND '||
                             'NVL('||NVL(TO_CHAR(p_order_number_to), 'NULL')||',order_number) '||
                     'AND ooha.header_id = wdd.source_header_id '||
                     'AND wda.delivery_detail_id = wdd.delivery_detail_id '||
                     'AND wda.delivery_id = jrigt.delivery_id) ' ||
       'AND  (TRUNC(delivery_date) BETWEEN '||
             'NVL(TRUNC(TO_DATE('''||pv_delivery_date_from||''' ,''yyyy-MM-dd HH24:MI:SS'')'||'),delivery_date) AND '||
             --'NVL(TRUNC('||pv_delivery_date_to||'),delivery_date)) '||
             'NVL(TRUNC(TO_DATE('''||pv_delivery_date_to||''' ,''yyyy-MM-dd HH24:MI:SS'')'||'),delivery_date)) '||
       'AND    organization_id  = NVL('||NVL(TO_CHAR(p_organization_id), 'NULL')||',organization_id) '||
       'AND    location_id = NVL('||NVL(TO_CHAR(p_location_id), 'NULL')||',location_id) ' ||
       'AND    (vat_inv_gen_status <> ''C'' OR vat_acct_status  <> ''C'') '||
       -- modified by Allen Yang for bug 9666476 28-apr-2010, begin
       --'ORDER  BY party_id , party_type, party_site_id, order_number';
       'ORDER  BY party_id , party_type, party_site_id';
       -- modified by Allen Yang for bug 9666476 28-apr-2010, end

  sql_stmt_all
  := 'SELECT delivery_id , delivery_date , organization_id , location_id , vat_invoice_no, '||
            'party_id , party_site_id , party_type , vat_inv_gen_status , vat_acct_status, '||
            'order_line_id, order_number ' ||
     'FROM   JAI_RGM_INVOICE_GEN_T jrigt ' ||
     'WHERE  regime_id        = '||p_regime_id ||' '||
       'AND    registration_num = NVL('||lv_p_registration_num_str||',registration_num) '||
       'AND    (delivery_id IS NULL OR (delivery_id BETWEEN '||
                                        'NVL('||NVL(TO_CHAR(p_delivery_id_from), 'NULL')||',delivery_id) AND '||
                                        'NVL('||NVL(TO_CHAR(p_delivery_id_to), 'NULL')||',delivery_id) '||
                                        'AND EXISTS (SELECT 1 FROM WSH_DELIVERY_DETAILS wdd '||
                                                                 ',WSH_DELIVERY_ASSIGNMENTS wda '||
                                                                 ',OE_ORDER_HEADERS_ALL ooha '||
                                                    'WHERE ooha.order_number BETWEEN '||
                                                            'NVL('||NVL(TO_CHAR(p_order_number_from), 'NULL')||',order_number) AND '||
                                                            'NVL('||NVL(TO_CHAR(p_order_number_to), 'NULL')||',order_number) '||
                                                    'AND ooha.header_id = wdd.source_header_id '||
                                                    'AND wda.delivery_detail_id = wdd.delivery_detail_id '||
                                                    'AND wda.delivery_id = jrigt.delivery_id))) ' ||
       'AND  (order_number IS NULL '||
              'OR order_number BETWEEN NVL('||NVL(TO_CHAR(p_order_number_from), 'NULL')||',order_number) ' ||
                                     ' AND NVL('||NVL(TO_CHAR(p_order_number_to), 'NULL')||',order_number)) ' ||
       'AND  (TRUNC(delivery_date) BETWEEN '||
             --'NVL(TRUNC('||pv_delivery_date_from||'),delivery_date) AND '||
             --'NVL(TRUNC('||pv_delivery_date_to||'),delivery_date)) '||
             'NVL(TRUNC(TO_DATE('''||pv_delivery_date_from||''' ,''yyyy-MM-dd HH24:MI:SS'')'||'),delivery_date) AND '||
             'NVL(TRUNC(TO_DATE('''||pv_delivery_date_to||''' ,''yyyy-MM-dd HH24:MI:SS'')'||'),delivery_date)) '||
       'AND    organization_id  = NVL('||NVL(TO_CHAR(p_organization_id), 'NULL')||',organization_id) '||
       'AND    location_id = NVL('||NVL(TO_CHAR(p_location_id), 'NULL')||',location_id) '||
       'AND    (vat_inv_gen_status <> ''C'' OR vat_acct_status  <> ''C'') '||
       -- modified by Allen Yang for bug 9666476 28-apr-2010, begin
       'ORDER  BY party_id , party_type, party_site_id, order_number NULLS FIRST';
       -- modified by Allen Yang for bug 9666476 28-apr-2010, end

       IF (p_delivery_id_from IS NOT NULL AND p_delivery_id_to IS NOT NULL) OR
          ((p_delivery_id_from IS NOT NULL OR p_delivery_id_to IS NOT NULL) AND
           (p_order_number_from IS NULL AND p_order_number_to IS NULL))
       THEN
         lv_SQLStmt := sql_stmt_shippable;
         IF lv_debug = 'Y'
         THEN
           Fnd_File.PUT_LINE(Fnd_File.LOG, 'Query SQL for shippable items only: '||lv_SQLStmt);
         END IF;  -- lv_debug = 'Y'
       ELSE
         lv_SQLStmt := sql_stmt_all;
         IF lv_debug = 'Y'
         THEN
           Fnd_File.PUT_LINE(Fnd_File.LOG, 'Query SQL for shippable and non-shippable items: '||lv_SQLStmt);
         END IF; -- lv_debug = 'Y'
       END IF; -- p_delivery_id_from IS NOT NULL AND p_delivery_id_to IS NOT NULL

       OPEN v_main_rec_cur FOR lv_SQLStmt;
       LOOP
         FETCH v_main_rec_cur INTO mainrec;
         EXIT WHEN v_main_rec_cur%NOTFOUND;

         --Fnd_File.PUT_LINE(Fnd_File.LOG, 'delivery_id: '||mainrec.delivery_id||' order_line_id: '||mainrec.order_line_id);

         -- start processing records
         IF mainrec.delivery_id IS NOT NULL   -- for shippable line
         THEN
           lv_p_source := jai_constants.source_wsh;
           ln_interface_status:= 0;
           OPEN   c_check_interface_status(mainrec.delivery_id);
           FETCH  c_check_interface_status into ln_interface_status;
           CLOSE  c_check_interface_status;

           IF ln_interface_status = 1
           THEN
             Fnd_File.PUT_LINE(Fnd_File.LOG,
                               'Delivery - ' || mainrec.delivery_id ||
                              ' Cannot be processed because all delivery details'||
                              ' are not inventory interfaced');
             ln_failure_delivery_ctr := NVL(ln_failure_Delivery_ctr,0) + 1;
             goto NEXTDELIVERY;
           END IF; -- ln_interface_status = 1
           IF lv_debug = 'Y' THEN
             Fnd_File.PUT_LINE(Fnd_File.LOG, ' Processing Delivery - ' || mainrec.delivery_id);
           END IF; -- lv_debug = 'Y'
         ELSE    -- else for non-shippable line
           lv_p_source := jai_constants.source_nsh;
           IF lv_debug = 'Y' THEN
             Fnd_File.PUT_LINE(Fnd_File.LOG, ' Processing Non-shippable Order Line - ' ||
                                             mainrec.order_line_id);
           END IF; -- lv_debug = 'Y'
         END IF; -- mainrec.delivery_id IS NOT NULL

         IF check_reg_dealer(mainrec.party_id,mainrec.party_site_id)
         THEN
           lv_doc_type_class :='O';
         ELSE
           lv_doc_type_class :='UO';  /*made it to UO from VO */
         END IF; -- check_reg_dealer(mainrec.party_id,mainrec.party_site_id)

         IF lv_Debug = 'Y'
         THEN
           Fnd_File.PUT_LINE(Fnd_File.LOG, ' ln_current_party_id : ' || ln_current_party_id);
           Fnd_File.PUT_LINE(Fnd_File.LOG, ' mainrec.party_id : ' || mainrec.party_id);
           Fnd_File.PUT_LINE(Fnd_File.LOG, ' ln_current_party_site_id : ' || ln_current_party_site_id);
           Fnd_File.PUT_LINE(Fnd_File.LOG, ' mainrec.party_site_id :' || mainrec.party_site_id);
           Fnd_File.PUT_LINE(Fnd_File.LOG, ' ln_current_order_number : ' || ln_current_order_number);
           Fnd_File.PUT_LINE(Fnd_File.LOG, ' mainrec.order_number :' || mainrec.order_number);
           Fnd_File.PUT_LINE(Fnd_File.LOG, 'lv_doc_type_class:' || lv_doc_type_class);
         END IF; -- lv_Debug = 'Y'

         IF ln_current_party_id <> mainrec.party_id OR
            ln_current_party_site_id <> mainrec.party_site_id
         THEN
           /*
           || There has been a change either in the party id or the party site id .
           || Hence a new loop needs to start
           */
           ln_current_party_id := mainrec.party_id;
           ln_current_party_site_id := mainrec.party_site_id;
           lv_party_has_changed := jai_constants.value_true;
         ELSE
           lv_party_has_changed := jai_constants.value_false;
         END IF;  -- ln_current_party_id <> mainrec.party_id OR ... ...

         -- modified by Allen Yang for bug bug 9485355 (12.1.3 non-shippable Enhancement), begin
         --OPEN   c_shipment_info(mainrec.delivery_id);
         lv_excise_invoice_no := NULL;
         OPEN   c_shipment_info(mainrec.delivery_id
                              , mainrec.order_line_id);
         FETCH  c_shipment_info INTO ln_order_type_id ,lv_excise_invoice_no ;
         -- modified by Allen Yang for bug bug 9485355 (12.1.3 non-shippable Enhancement), end
         CLOSE  c_shipment_info;

         OPEN  c_vat_inv_gen_status(mainrec.delivery_id, mainrec.order_line_id);
         FETCH c_vat_inv_gen_status INTO lv_vat_inv_gen_status ;
         CLOSE c_vat_inv_gen_status;

         -- Check if the excise invoice number can be used as VAT invoice number.
         OPEN  c_same_inv_no(mainrec.organization_id , mainrec.location_id );
         FETCH c_same_inv_no INTO lv_Same_invoice_no;
         CLOSE c_same_inv_no;

         IF mainrec.vat_inv_gen_status = 'C' OR lv_vat_inv_gen_status = 'C'
         THEN
           GOTO Processaccounting;
         END IF; -- mainrec.vat_inv_gen_status = 'C' OR lv_vat_inv_gen_status = 'C'

         -- here comes the detail logic of VAT generation for shippable and non-shippable lines
         IF mainrec.delivery_id IS NOT NULL -- current is shippable line
         THEN
           IF NVL(lv_Same_invoice_no,jai_constants.no) = jai_constants.yes --same as excise
           THEN
             /* detailed logic of using excise invoice number as VAT invoice number
                1. if excise is not generated, then raise error msg and go NEXTDELIVERY;
                2. else, use excise as VAT invoice number, and update JAI_RGM_INVOICE_GEN_T
                   (vat_invoice_no => excise_inv_number, vat_inv_gen_status => 'C');
             */
             IF lv_debug = 'Y' THEN
                Fnd_File.PUT_LINE(Fnd_File.LOG, ' lv_Same_invoice_no = Y , Hence we need not call inv num generation routine - using excise inv num instead');
             END IF; -- lv_debug = 'Y'

             ln_excise_invoice_not_done := NULL;
             OPEN  c_excise_invoice_not_done (mainrec.delivery_id);
             FETCH c_excise_invoice_not_done INTO ln_excise_invoice_not_done;
             CLOSE c_excise_invoice_not_done ;

             IF lv_debug = 'Y' THEN
                Fnd_File.PUT_LINE(Fnd_File.LOG, ' ln_excise_invoice_not_done = ' || NVL(ln_excise_invoice_not_done,-1));
             END IF; -- lv_debug = 'Y'

             IF ln_excise_invoice_not_done IS NULL THEN
               -- Excise invoice number in not found , populate it as -1
               ln_excise_invoice_not_done := -1;
             END IF;  -- ln_excise_invoice_not_done IS NULL

             IF ln_excise_invoice_not_done = 1 THEN
               /*
               || It means the delivery is still existing in the JAI_OM_OE_GEN_TAXINV_T table
               || It means that the excise invoice generation was either not processed or errored out.
               || We need to raise an error saying that excise invoice number needs to be run before VAT processing can happen.
               */
               lv_inv_gen_process_flag    :=  jai_constants.expected_error;
               lv_inv_gen_process_message :=  'Excise Invoice Generation is not generated yet for this Delivery. Please run the excise invoice number generation number for delivery : '
                                              || mainrec.delivery_id;
               -- Not using the debug flag for the following message because it needs to be shown to the user irrespective of debug flag.
               Fnd_File.PUT_LINE(Fnd_File.LOG, 'Excise Invoice Generation is not generated yet for this Delivery. Please run the excise invoice number generation number for delivery : '
                                               || mainrec.delivery_id);
               ln_failure_delivery_ctr := NVL(ln_failure_Delivery_ctr,0) + 1;
               goto NEXTDELIVERY;
             ELSE
               /*
               || Control comes here - It means record for the delivery does not exist in the JAI_OM_OE_GEN_TAXINV_T table
                  because of reasons such as :
               || a. Delivery does not have excise taxes
               || b. Explicit setting such as bond register is set to DOMESTIC_WITHOUT_EXCISE or EXPORT_WITHOUT_EXCISE
               || c. The item itself is not excisable , hence no excise invoice num is generated.
               || d. Excise invoice is already generated

               For cases a to c , need to generate VAT invoice number explicitly.
               For case d , need to copy the excise invoice number and make it the vat invoice number.
               */
               IF lv_excise_invoice_no IS NOT NULL THEN
                 -- Excise invoice number is not null - so the same excise invoice number needs to be used as VAT invoice number
                 lv_vat_invoice_number := lv_excise_invoice_no;
                 IF lv_debug = 'Y' THEN
                    Fnd_File.PUT_LINE(Fnd_File.LOG, ' Excise Invoice number - ' || lv_vat_invoice_number || ' Will be used as VAT Invoice number for delivery : ' || mainrec.delivery_id);
                    Fnd_File.PUT_LINE(Fnd_File.LOG, ' before updating jai_om_wsh_lines_all for ex inv num');
                 END IF; -- lv_debug = 'Y'

                 UPDATE JAI_OM_WSH_LINES_ALL
                 SET    vat_invoice_no = excise_invoice_no
                      , vat_invoice_date = excise_invoice_date
                 WHERE  delivery_id = mainrec.delivery_id;

                 IF lv_debug = 'Y' THEN
                   Fnd_File.PUT_LINE(Fnd_File.LOG, ' before updating jai_rgm_invoice_gen_t for ex inv num');
                 END IF;

                 UPDATE JAI_RGM_INVOICE_GEN_T
                 SET    vat_invoice_no          = lv_vat_invoice_number
                      , vat_inv_gen_status      = 'C'
                      , vat_inv_gen_err_message = NULL
                      , request_id              = ln_conc_request_id
                      , program_id              = ln_conc_progam_id
                      , program_application_id  = ln_conc_prog_appl_id
                      , last_update_login       = fnd_global.conc_login_id
                      , last_update_Date        = sysdate
                 WHERE  Delivery_id             = mainrec.delivery_id;

                 IF lv_debug = 'Y' THEN
                   Fnd_File.PUT_LINE(Fnd_File.LOG, ' after updating jai_rgm_invoice_gen_t for ex inv num');
                 END IF;

                 ln_success_delivery_Ctr := NVL(ln_success_Delivery_Ctr,0) + 1;

                 IF lv_debug = 'Y' THEN
                   Fnd_File.PUT_LINE(Fnd_File.LOG, ' Before going to process accounting for generating accounting');
                 END IF;

                 lv_inv_gen_process_flag    :=  jai_constants.successful;
                 GOTO Processaccounting;
               END IF; -- lv_excise_invoice_no IS NOT NULL
             END IF; -- ln_excise_invoice_not_done = 1
           ELSE -- same as excise option is 'NO'
             /*
             || Check if we need to generate vat invoice number and within that check if an invoice number is already generated.
             || if an invoice is already generated and if the parameter p_single_invoice_num is set to 'Y' then do not make an
             || API call again and again to the generation api . Just update the JAI_OM_WSH_LINES_ALL table to set the
             || vat invoice number for the delivery and continue.
             */
             IF NVL(p_single_invoice_num,jai_constants.No) = jai_constants.yes -- single invoice number is true
             THEN
               IF NVL(lv_party_has_changed,jai_constants.value_false) = jai_constants.value_true     -- party has changed
               THEN
                 /* generate new VAT invoice number by document sequence;
                    1. jai_cmn_rgm_setup_pkg.Gen_Invoice_number();
                    2. if successful, update VAT invoice number to JAI_OM_WSH_LINES_ALL, and update
                       table JAI_RGM_INVOICE_GEN_T (vat_invoice_no => lv_vat_invoice_number
                                                  , vat_inv_gen_status => 'C');
                 */
                 IF lv_Debug = 'Y'
                 THEN
                   Fnd_File.PUT_LINE(Fnd_File.LOG, ' lv_party_has_changed :' || lv_party_has_changed);
                   Fnd_File.PUT_LINE(Fnd_File.LOG, ' lv_inv_num_already_generated :' || lv_inv_num_already_generated);
                 END IF;  -- lv_Debug = 'Y'
                 IF p_process_action in (jai_constants.om_action_gen_inv_n_accnt ,jai_constants.om_action_gen_invoice)
                 THEN
                   IF lv_inv_num_already_generated = jai_constants.value_false
                   THEN
                     IF lv_Debug = 'Y' THEN
                       Fnd_File.PUT_LINE(Fnd_File.LOG, ' before call to jai_cmn_rgm_setup_pkg.Gen_Invoice_number with ln_order_type_id' || ln_order_type_id || 'date ' || mainrec.delivery_date );
                     END IF; -- lv_Debug = 'Y'
                     jai_cmn_rgm_setup_pkg.Gen_Invoice_number(p_regime_id        => ln_regime_id
                                                            , p_organization_id  => mainrec.organization_id
                                                            , p_location_id      => mainrec.location_id
                                                            , p_date             => mainrec.delivery_date
                                                            , p_doc_class        => lv_doc_type_class
                                                            , p_doc_type_id      => ln_order_type_id
                                                            , P_invoice_number   => lv_vat_invoice_number
                                                            , p_process_flag     => lv_inv_gen_process_flag
                                                            , p_process_msg      => lv_inv_gen_process_message
                                                             );
                     IF lv_Debug = 'Y' THEN
                       Fnd_File.PUT_LINE(Fnd_File.LOG, ' after call with lv_vat_invoice_number:' || lv_vat_invoice_number || lv_inv_gen_process_flag ||lv_inv_gen_process_message);
                     END IF; -- lv_Debug = 'Y'

                     -- check the return status and update the JAI_OM_WSH_LINES_ALL table to set the vat invoice number
                     IF lv_inv_gen_process_flag = jai_constants.successful
                     THEN
                       IF lv_vat_invoice_number IS NOT NULL
                       THEN
                         ln_success_delivery_Ctr := NVL(ln_success_Delivery_Ctr,0) + 1;
                         lv_inv_num_already_generated := jai_constants.value_true;
                         UPDATE JAI_OM_WSH_LINES_ALL
                         SET    VAT_INVOICE_NO = lv_vat_invoice_number
                              , VAT_INVOICE_DATE = nvl(ld_override_invoice_date ,sysdate)
                              , LAST_UPDATE_DATE = sysdate
                              , LAST_UPDATE_LOGIN = fnd_global.login_id
                              , LAST_UPDATED_BY   = fnd_global.user_id
                         WHERE  DELIVERY_ID = mainrec.delivery_id;

                         UPDATE JAI_RGM_INVOICE_GEN_T
                         SET    vat_invoice_no    = lv_vat_invoice_number
                              , vat_inv_gen_status = 'C'
                              , request_id = ln_conc_request_id
                              , program_id = ln_conc_progam_id
                              , program_application_id = ln_conc_prog_appl_id
                              , last_update_login = fnd_global.conc_login_id
                              , last_update_date = sysdate
                         WHERE  delivery_id = mainrec.delivery_id;
                       ELSE
                         lv_inv_gen_process_flag := jai_constants.unexpected_error;
                         lv_acct_process_flag := jai_constants.expected_error;
                         ln_failure_delivery_ctr := NVL(ln_failure_Delivery_ctr,0) + 1;
                       END IF; -- lv_vat_invoice_number IS NOT NULL
                     ELSE
                       ln_failure_delivery_ctr := NVL(ln_failure_Delivery_ctr,0) + 1;
                     END IF; -- lv_inv_gen_process_flag = jai_constants.successful
                   END IF;  -- lv_inv_num_already_generated = jai_constants.value_false
                 END IF; -- p_process_action in (jai_constants.om_action_gen_inv_n_accnt ,jai_constants.om_action_gen_invoice)

               ELSE                     -- party not change
                 /* 1. use existing VAT invoice number for this record;
                    2. update JAI_OM_WSH_LINES_ALL and JAI_RGM_INVOICE_GEN_T;
                 */
                 IF lv_vat_invoice_number IS NOT NULL
                 THEN
                   -- Update the vat_invoice_num field in JAI_OM_WSH_LINES_ALL table for the current delivery.
                   UPDATE  JAI_OM_WSH_LINES_ALL
                   SET     vat_invoice_no = lv_vat_invoice_number,
                           VAT_INVOICE_DATE = nvl(ld_override_invoice_date ,sysdate),
                           last_update_date = sysdate,
                           last_update_login = fnd_global.login_id,
                           last_updated_by   = fnd_global.user_id
                   WHERE   delivery_id IN (SELECT delivery_id
                                           FROM   JAI_RGM_INVOICE_GEN_T         jrigt
                                           WHERE  party_id = ln_current_party_id
                                           AND    party_site_id = ln_current_party_site_id
                                           AND    party_type    = mainrec.party_type
                                           AND    vat_inv_gen_status <> 'C'
                                           AND    delivery_id BETWEEN NVL(P_DELIVERY_ID_FROM,delivery_id)
                                                              AND NVL(P_DELIVERY_ID_TO,delivery_id)
                                           AND EXISTS (SELECT 1
                                                       FROM    WSH_DELIVERY_ASSIGNMENTS         wda
                                                             , WSH_DELIVERY_DETAILS             wdd
                                                             , OE_ORDER_HEADERS_ALL             ooha
                                                       WHERE wda.delivery_id = jrigt.delivery_id
                                                       AND   wda.delivery_detail_id = wdd.delivery_detail_id
                                                       AND   wdd.source_header_id = ooha.header_id
                                                       AND   ooha.order_number BETWEEN
                                                             NVL(p_order_number_from, ooha.order_number) AND
                                                             NVL(p_order_number_to, ooha.order_number))
                                           AND    trunc(delivery_Date) BETWEEN NVL(P_DELIVERY_DATE_FROM,Delivery_date)
                                                                       AND NVL(P_DELIVERY_DATE_TO,delivery_date));

                   UPDATE  JAI_RGM_INVOICE_GEN_T
                   SET     vat_invoice_no             = lv_vat_invoice_number,
                           vat_inv_gen_status         = 'C',
                           request_id = ln_conc_request_id,
                           program_id = ln_conc_progam_id,
                           program_application_id = ln_conc_prog_appl_id,
                           last_update_login = fnd_global.conc_login_id
                   WHERE   delivery_id IN (SELECT delivery_id
                                           FROM   JAI_RGM_INVOICE_GEN_T         jrigt
                                           WHERE  party_id = ln_current_party_id
                                           AND    party_site_id = ln_current_party_site_id
                                           AND    party_type    = mainrec.party_type
                                           AND    vat_inv_gen_status <> 'C'
                                           AND    delivery_id BETWEEN NVL(P_DELIVERY_ID_FROM,delivery_id)
                                                              AND NVL(P_DELIVERY_ID_TO,delivery_id)
                                           AND EXISTS (SELECT 1
                                                       FROM    WSH_DELIVERY_ASSIGNMENTS         wda
                                                             , WSH_DELIVERY_DETAILS             wdd
                                                             , OE_ORDER_HEADERS_ALL             ooha
                                                       WHERE wda.delivery_id = jrigt.delivery_id
                                                       AND   wda.delivery_detail_id = wdd.delivery_detail_id
                                                       AND   wdd.source_header_id = ooha.header_id
                                                       AND   ooha.order_number BETWEEN
                                                             NVL(p_order_number_from, ooha.order_number) AND
                                                             NVL(p_order_number_to, ooha.order_number))
                                           AND    trunc(delivery_Date) BETWEEN NVL(P_DELIVERY_DATE_FROM,Delivery_date)
                                                                       AND NVL(P_DELIVERY_DATE_TO,delivery_date));

                   ln_success_delivery_Ctr := NVL(ln_success_Delivery_Ctr,0) + sql%rowcount ;

                   IF lv_Debug = 'Y' THEN
                     Fnd_File.PUT_LINE(Fnd_File.LOG, 'No. of Deliveries updated in jai_vat_processing_t: ' || SQL%ROWCOUNT);
                   END IF; -- lv_Debug = 'Y'
                 END IF; -- lv_vat_invoice_number IS NOT NULL
               END IF; -- lv_party_has_changed
             ELSE  -- single invoice number is false
               /* generate new VAT invoice number by document sequence;
                  1. jai_cmn_rgm_setup_pkg.Gen_Invoice_number();
                  2. if successful, update VAT invoice number to JAI_OM_WSH_LINES_ALL, and update
                     table JAI_RGM_INVOICE_GEN_T (vat_invoice_no => lv_vat_invoice_number,
                                                  vat_inv_gen_status => 'C');
               */
               IF lv_Debug = 'Y' THEN
                 Fnd_File.PUT_LINE(Fnd_File.LOG, 'In the Else when p_single_invoice is not Y ');
               END IF;
               /*
               || This is the Else Part of the IF p_single_invoice_num = 'Y' THEN
               || In this comes the code that is needed for different generating vat invoice number for every delivery
               */
               IF lv_Debug = 'Y' THEN
                 Fnd_File.PUT_LINE(Fnd_File.LOG, '+++ before call to jai_cmn_rgm_setup_pkg.Gen_Invoice_number In the Else when p_single_invoice is not Y with order type = '
                                                 || ln_order_type_id || ' +++ ' );

                 Fnd_File.PUT_LINE(Fnd_File.LOG, '0 ' ||   ln_regime_id || ' ' ||
                                                 mainrec.organization_id || ' ' || mainrec.location_id || ' ' ||
                                                 mainrec.delivery_date || '' ||   ln_order_type_id || ' ' ||
                                                 lv_vat_invoice_number || ' '  || lv_inv_gen_process_flag || ' ' ||
                                                 lv_inv_gen_process_message ) ;

               END IF; -- lv_Debug = 'Y'
               jai_cmn_rgm_setup_pkg.Gen_Invoice_number( p_regime_id        => ln_regime_id
                                                       , p_organization_id  => mainrec.organization_id
                                                       , p_location_id      => mainrec.location_id
                                                       , p_date             => mainrec.delivery_date
                                                       , p_doc_class        => lv_doc_type_class
                                                       , p_doc_type_id      => ln_order_type_id
                                                       , P_invoice_number   => lv_vat_invoice_number
                                                       , p_process_flag     => lv_inv_gen_process_flag
                                                       , p_process_msg      => lv_inv_gen_process_message
                                                        );
               IF lv_Debug = 'Y' THEN
                 Fnd_File.PUT_LINE(Fnd_File.LOG, ' +++ after call to jai_cmn_rgm_setup_pkg.Gen_Invoice_number In the Else when p_single_invoice is not Y with lv_vat_invoice_number = '
                                                || lv_vat_invoice_number || '+++');
                 Fnd_File.PUT_LINE(Fnd_File.LOG, ' +++ after call to jai_cmn_rgm_setup_pkg.Gen_Invoice_number with lv_inv_gen_process_flag = '
                                                || lv_inv_gen_process_flag || 'lv_inv_gen_process_message '|| lv_inv_gen_process_message || '+++');
               END IF;  -- lv_Debug = 'Y'
               IF  lv_inv_gen_process_flag = jai_constants.successful
               THEN
                 IF lv_vat_invoice_number IS NOT NULL
                 THEN
                   ln_success_delivery_Ctr := NVL(ln_success_Delivery_Ctr,0) + 1;
                   UPDATE JAI_OM_WSH_LINES_ALL
                   SET    vat_invoice_no = lv_vat_invoice_number,
                          vat_invoice_date = nvl(ld_override_invoice_date ,sysdate),
                          last_update_date = sysdate,
                          last_update_login = fnd_global.login_id,
                          last_updated_by   = fnd_global.user_id
                   WHERE  delivery_id = mainrec.delivery_id;

                   UPDATE JAI_RGM_INVOICE_GEN_T
                   SET    vat_invoice_no    = lv_vat_invoice_number,
                          vat_inv_gen_status = 'C',
                          vat_inv_gen_err_message = NULL ,
                          request_id = ln_conc_request_id,
                          program_id = ln_conc_progam_id,
                          program_application_id = ln_conc_prog_appl_id,
                          last_update_login = fnd_global.conc_login_id,
                          last_update_date  = sysdate
                    WHERE  delivery_id = mainrec.delivery_id;

                  ELSE
                    lv_inv_gen_process_flag := jai_constants.unexpected_error;
                    lv_inv_gen_process_message := 'No VAT Invoice Number Generated';
                    ln_failure_delivery_ctr := NVL(ln_failure_Delivery_ctr,0) + 1;
                  END IF;  -- lv_vat_invoice_number IS NOT NULL
                ELSE
                  UPDATE JAI_RGM_INVOICE_GEN_T
                  SET    vat_inv_gen_err_message   = substr(lv_inv_gen_process_message,1,1000),
                         vat_inv_gen_status = 'E',
                         request_id = ln_conc_request_id,
                         program_id = ln_conc_progam_id,
                         program_application_id = ln_conc_prog_appl_id,
                         last_update_login = fnd_global.conc_login_id,
                         last_update_date = sysdate
                  WHERE  delivery_id = mainrec.delivery_id;
                  ln_failure_delivery_ctr := NVL(ln_failure_Delivery_ctr,0) + 1;
                END IF; -- lv_inv_gen_process_flag = jai_constants.successful
              END IF; -- NVL(lv_Same_invoice_no,jai_constants.no) = jai_constants.yes
           END IF; -- NVL(lv_Same_invoice_no,jai_constants.no) = jai_constants.yes

         -- below logic is for non-shippable lines
         ELSE  -- current line is non-shippable line
           IF ln_current_order_number <> mainrec.order_number
             THEN
               /*
               || There has been a change in order number .
               || Hence a new loop needs to start
               */
               ln_current_order_number := mainrec.order_number;
               lv_order_has_changed := jai_constants.value_true;
           ELSE
               lv_order_has_changed := jai_constants.value_false;
           END IF;  -- ln_current_order_number <> mainrec.order_number

           /* commented following logic as for non-shippable lines, same_as_excise flag will not take effect
           -- if same_as_excise flag is 'Y', use excise invoice number of first fetched delivery line as vat invoice number
           IF NVL(lv_Same_invoice_no,jai_constants.no) = jai_constants.yes --same as excise
           THEN
             IF lv_debug = 'Y' THEN
                Fnd_File.PUT_LINE(Fnd_File.LOG, ' lv_Same_invoice_no = Y , Hence we need not call inv num generation routine - using excise inv num instead');
             END IF; -- lv_debug = 'Y'

             lv_excise_invoice_no := NULL;
             OPEN  c_get_excise_from_shippable (mainrec.order_number);
             FETCH c_get_excise_from_shippable
             INTO lv_excise_invoice_no
                 ,ld_excise_invoice_date;
             CLOSE c_get_excise_from_shippable ;

             IF lv_debug = 'Y' THEN
                Fnd_File.PUT_LINE(Fnd_File.LOG, ' lv_excise_invoice_no is ' || NVL(lv_excise_invoice_no,'NULL'));
             END IF; -- lv_debug = 'Y'

             IF lv_excise_invoice_no IS NOT NULL
             THEN
               -- Excise invoice number is not null - so the same excise invoice number needs to be used as VAT invoice number
               IF lv_debug = 'Y' THEN
                 Fnd_File.PUT_LINE(Fnd_File.LOG, ' Excise Invoice number - ' || lv_excise_invoice_no || ' Will be used as VAT Invoice number for non-shippable order line : ' || mainrec.order_line_id);
                 Fnd_File.PUT_LINE(Fnd_File.LOG, ' before updating jai_om_wsh_lines_all for ex inv num');
               END IF; -- lv_debug = 'Y'

               UPDATE JAI_OM_WSH_LINES_ALL
               SET    vat_invoice_no = lv_excise_invoice_no
                    , vat_invoice_date = ld_excise_invoice_date
               WHERE  order_line_id = mainrec.order_line_id
               AND    delivery_id IS NULL;

               IF lv_debug = 'Y' THEN
                 Fnd_File.PUT_LINE(Fnd_File.LOG, ' before updating jai_rgm_invoice_gen_t for ex inv num');
               END IF; -- lv_debug = 'Y'

               UPDATE JAI_RGM_INVOICE_GEN_T
               SET    vat_invoice_no          = lv_excise_invoice_no
                    , vat_inv_gen_status      = 'C'
                    , vat_inv_gen_err_message = NULL
                    , request_id              = ln_conc_request_id
                    , program_id              = ln_conc_progam_id
                    , program_application_id  = ln_conc_prog_appl_id
                    , last_update_login       = fnd_global.conc_login_id
                    , last_update_Date        = sysdate
               WHERE  order_line_id           = mainrec.order_line_id;

               IF lv_debug = 'Y' THEN
                 Fnd_File.PUT_LINE(Fnd_File.LOG, ' after updating jai_rgm_invoice_gen_t for ex inv num');
               END IF;

               ln_success_delivery_Ctr := NVL(ln_success_Delivery_Ctr,0) + 1;

               IF lv_debug = 'Y' THEN
                 Fnd_File.PUT_LINE(Fnd_File.LOG, ' Before going to process accounting for generating accounting');
               END IF;

               lv_inv_gen_process_flag      :=  jai_constants.successful;
               lv_inv_num_already_generated :=  jai_constants.value_true;
               lv_vat_invoice_number        :=  lv_excise_invoice_no;
               GOTO Processaccounting;
             END IF; -- lv_excise_invoice_no IS NOT NULL

           END IF; -- NVL(lv_Same_invoice_no,jai_constants.no) = jai_constants.yes
           */

           Fnd_File.PUT_LINE(Fnd_File.LOG, ' lv_party_has_changed :' || lv_party_has_changed);
           Fnd_File.PUT_LINE(Fnd_File.LOG, ' p_single_invoice_num :' || p_single_invoice_num);

           IF NVL(p_single_invoice_num,jai_constants.No) = jai_constants.yes    -- single invoice number is true
           THEN
             IF NVL(lv_party_has_changed,jai_constants.value_false) = jai_constants.value_true   -- party has changed
             THEN
               /* generate new VAT invoice number by document sequence;
                  1. jai_cmn_rgm_setup_pkg.Gen_Invoice_number();
                  2. if successful, update VAT invoice number to JAI_OM_WSH_LINES_ALL, and update
                     table JAI_RGM_INVOICE_GEN_T (vat_invoice_no => lv_vat_invoice_number,
                                                  vat_inv_gen_status => 'C');
               */
               IF lv_Debug = 'Y'
               THEN
                 Fnd_File.PUT_LINE(Fnd_File.LOG, ' lv_party_has_changed :' || lv_party_has_changed);
                 Fnd_File.PUT_LINE(Fnd_File.LOG, ' lv_inv_num_already_generated :' || lv_inv_num_already_generated);
               END IF;  -- lv_Debug = 'Y'
               IF p_process_action in (jai_constants.om_action_gen_inv_n_accnt ,jai_constants.om_action_gen_invoice)
               THEN
                 --IF lv_inv_num_already_generated = jai_constants.value_false
                 --THEN
                   IF lv_Debug = 'Y' THEN
                     Fnd_File.PUT_LINE(Fnd_File.LOG, ' before call to jai_cmn_rgm_setup_pkg.Gen_Invoice_number with ln_order_type_id' || ln_order_type_id || 'date ' || mainrec.delivery_date );
                   END IF; -- lv_Debug = 'Y'
                   jai_cmn_rgm_setup_pkg.Gen_Invoice_number(  p_regime_id        => ln_regime_id
                                                            , p_organization_id  => mainrec.organization_id
                                                            , p_location_id      => mainrec.location_id
                                                            , p_date             => mainrec.delivery_date
                                                            , p_doc_class        => lv_doc_type_class
                                                            , p_doc_type_id      => ln_order_type_id
                                                            , P_invoice_number   => lv_vat_invoice_number
                                                            , p_process_flag     => lv_inv_gen_process_flag
                                                            , p_process_msg      => lv_inv_gen_process_message
                                                            );
                   IF lv_Debug = 'Y' THEN
                     Fnd_File.PUT_LINE(Fnd_File.LOG, ' after call with lv_vat_invoice_number:' || lv_vat_invoice_number || lv_inv_gen_process_flag ||lv_inv_gen_process_message);
                   END IF; -- lv_Debug = 'Y'

                   -- check the return status and update the JAI_OM_WSH_LINES_ALL table to set the vat invoice number
                   IF lv_inv_gen_process_flag = jai_constants.successful
                   THEN
                     IF lv_vat_invoice_number IS NOT NULL
                     THEN
                       ln_success_delivery_Ctr := NVL(ln_success_Delivery_Ctr,0) + 1;
                       lv_inv_num_already_generated := jai_constants.value_true;
                       UPDATE JAI_OM_WSH_LINES_ALL
                       SET    VAT_INVOICE_NO = lv_vat_invoice_number
                            , VAT_INVOICE_DATE = nvl(ld_override_invoice_date ,sysdate)
                            , LAST_UPDATE_DATE = sysdate
                            , LAST_UPDATE_LOGIN = fnd_global.login_id
                            , LAST_UPDATED_BY   = fnd_global.user_id
                       WHERE  order_line_id = mainrec.order_line_id
                       AND    delivery_id   IS NULL;

                       UPDATE JAI_RGM_INVOICE_GEN_T
                       SET    vat_invoice_no    = lv_vat_invoice_number
                            , vat_inv_gen_status = 'C'
                            , request_id = ln_conc_request_id
                            , program_id = ln_conc_progam_id
                            , program_application_id = ln_conc_prog_appl_id
                            , last_update_login = fnd_global.conc_login_id
                            , last_update_date = sysdate
                       WHERE  order_line_id = mainrec.order_line_id;
                     ELSE
                       lv_inv_gen_process_flag := jai_constants.unexpected_error;
                       lv_acct_process_flag := jai_constants.expected_error;
                       ln_failure_delivery_ctr := NVL(ln_failure_Delivery_ctr,0) + 1;
                     END IF; -- lv_vat_invoice_number IS NOT NULL
                   ELSE
                     ln_failure_delivery_ctr := NVL(ln_failure_Delivery_ctr,0) + 1;
                   END IF; -- lv_inv_gen_process_flag = jai_constants.successful
                 --END IF;  -- lv_inv_num_already_generated = jai_constants.value_false
               END IF; -- p_process_action in (jai_constants.om_action_gen_inv_n_accnt ,jai_constants.om_action_gen_invoice)
             ELSE                    -- party not change
               /* 1. use existing VAT invoice number for this record;
                  2. update JAI_OM_WSH_LINES_ALL and JAI_RGM_INVOICE_GEN_T;
               */
               IF lv_vat_invoice_number IS NOT NULL THEN
                 -- Update the vat_invoice_num field in JAI_OM_WSH_LINES_ALL table for the current non-shippable line.
                 UPDATE  JAI_OM_WSH_LINES_ALL
                 SET     vat_invoice_no = lv_vat_invoice_number
                       , VAT_INVOICE_DATE = nvl(ld_override_invoice_date ,sysdate)
                       , last_update_date = sysdate
                       , last_update_login = fnd_global.login_id
                       , last_updated_by   = fnd_global.user_id
                 WHERE   order_line_id = mainrec.order_line_id
                 AND     delivery_id IS NULL;

                 UPDATE  JAI_RGM_INVOICE_GEN_T
                 SET     vat_invoice_no             = lv_vat_invoice_number
                       , vat_inv_gen_status         = 'C'
                       , request_id = ln_conc_request_id
                       , program_id = ln_conc_progam_id
                       , program_application_id = ln_conc_prog_appl_id
                       , last_update_login = fnd_global.conc_login_id
                 WHERE   order_line_id = mainrec.order_line_id;

                 ln_success_delivery_Ctr := NVL(ln_success_Delivery_Ctr,0) + 1 ;
               END IF;  -- lv_vat_invoice_number IS NOT NULL
             END IF; -- lv_party_has_changed
           ELSE    -- single invoice number is false
             -- if single invoice number option is 'NO', then generate VAT invoice by Order Numbers

             IF NVL(lv_order_has_changed,jai_constants.value_false) = jai_constants.value_true    -- order number has changed
             THEN
               /* generate new VAT invoice number by document sequence;
               1. jai_cmn_rgm_setup_pkg.Gen_Invoice_number();
               2. if successful, update VAT invoice number to JAI_OM_WSH_LINES_ALL, and update
                  table JAI_RGM_INVOICE_GEN_T (vat_invoice_no => lv_vat_invoice_number,
                                               vat_inv_gen_status => 'C');
               */
               IF lv_Debug = 'Y'
               THEN
                 Fnd_File.PUT_LINE(Fnd_File.LOG, ' lv_order_has_changed :' || lv_order_has_changed);
                 Fnd_File.PUT_LINE(Fnd_File.LOG, ' lv_inv_num_already_generated :' || lv_inv_num_already_generated);
               END IF;  -- lv_Debug = 'Y'
               IF p_process_action in (jai_constants.om_action_gen_inv_n_accnt ,jai_constants.om_action_gen_invoice)
               THEN
                 --IF lv_inv_num_already_generated = jai_constants.value_false
                 --THEN
                   IF lv_Debug = 'Y' THEN
                     Fnd_File.PUT_LINE(Fnd_File.LOG, ' before call to jai_cmn_rgm_setup_pkg.Gen_Invoice_number with ln_order_type_id' || ln_order_type_id || 'date ' || mainrec.delivery_date );
                   END IF; -- lv_Debug = 'Y'
                   jai_cmn_rgm_setup_pkg.Gen_Invoice_number(  p_regime_id        => ln_regime_id
                                                            , p_organization_id  => mainrec.organization_id
                                                            , p_location_id      => mainrec.location_id
                                                            , p_date             => mainrec.delivery_date
                                                            , p_doc_class        => lv_doc_type_class
                                                            , p_doc_type_id      => ln_order_type_id
                                                            , P_invoice_number   => lv_vat_invoice_number
                                                            , p_process_flag     => lv_inv_gen_process_flag
                                                            , p_process_msg      => lv_inv_gen_process_message
                                                            );
                   IF lv_Debug = 'Y' THEN
                     Fnd_File.PUT_LINE(Fnd_File.LOG, ' after call with lv_vat_invoice_number:' || lv_vat_invoice_number || lv_inv_gen_process_flag ||lv_inv_gen_process_message);
                   END IF; -- lv_Debug = 'Y'

                   -- check the return status and update the JAI_OM_WSH_LINES_ALL table to set the vat invoice number
                   IF lv_inv_gen_process_flag = jai_constants.successful
                   THEN
                     IF lv_vat_invoice_number IS NOT NULL
                     THEN
                       ln_success_delivery_Ctr := NVL(ln_success_Delivery_Ctr,0) + 1;
                       lv_inv_num_already_generated := jai_constants.value_true;
                       UPDATE JAI_OM_WSH_LINES_ALL
                       SET    VAT_INVOICE_NO = lv_vat_invoice_number
                            , VAT_INVOICE_DATE = nvl(ld_override_invoice_date ,sysdate)
                            , LAST_UPDATE_DATE = sysdate
                            , LAST_UPDATE_LOGIN = fnd_global.login_id
                            , LAST_UPDATED_BY   = fnd_global.user_id
                       WHERE  order_line_id = mainrec.order_line_id
                       AND    delivery_id   IS NULL;

                       UPDATE JAI_RGM_INVOICE_GEN_T
                       SET    vat_invoice_no    = lv_vat_invoice_number
                            , vat_inv_gen_status = 'C'
                            , request_id = ln_conc_request_id
                            , program_id = ln_conc_progam_id
                            , program_application_id = ln_conc_prog_appl_id
                            , last_update_login = fnd_global.conc_login_id
                            , last_update_date = sysdate
                       WHERE  order_line_id = mainrec.order_line_id;
                     ELSE
                       lv_inv_gen_process_flag := jai_constants.unexpected_error;
                       lv_acct_process_flag := jai_constants.expected_error;
                       ln_failure_delivery_ctr := NVL(ln_failure_Delivery_ctr,0) + 1;
                     END IF; -- lv_vat_invoice_number IS NOT NULL
                   ELSE
                     ln_failure_delivery_ctr := NVL(ln_failure_Delivery_ctr,0) + 1;
                   END IF; -- lv_inv_gen_process_flag = jai_constants.successful
                 --END IF;  -- lv_inv_num_already_generated = jai_constants.value_false
               END IF; -- p_process_action in (jai_constants.om_action_gen_inv_n_accnt ,jai_constants.om_action_gen_invoice)
             ELSE  -- order number not change
               /* 1. use existing VAT invoice number for this record;
                  2. update JAI_OM_WSH_LINES_ALL and JAI_RGM_INVOICE_GEN_T;
               */
               IF lv_vat_invoice_number IS NOT NULL THEN
                 -- Update the vat_invoice_num field in JAI_OM_WSH_LINES_ALL table for the current delivery.
                 UPDATE  JAI_OM_WSH_LINES_ALL
                 SET     vat_invoice_no = lv_vat_invoice_number
                       , VAT_INVOICE_DATE = nvl(ld_override_invoice_date ,sysdate)
                       , last_update_date = sysdate
                       , last_update_login = fnd_global.login_id
                       , last_updated_by   = fnd_global.user_id
                 WHERE   order_line_id = mainrec.order_line_id
                 AND     delivery_id IS NULL;

                 UPDATE  JAI_RGM_INVOICE_GEN_T
                 SET     vat_invoice_no             = lv_vat_invoice_number
                       , vat_inv_gen_status         = 'C'
                       , request_id = ln_conc_request_id
                       , program_id = ln_conc_progam_id
                       , program_application_id = ln_conc_prog_appl_id
                       , last_update_login = fnd_global.conc_login_id
                 WHERE   order_line_id = mainrec.order_line_id;

                 ln_success_delivery_Ctr := NVL(ln_success_Delivery_Ctr,0) + 1;
               END IF;  -- lv_vat_invoice_number IS NOT NULL
             END IF;  -- lv_order_has_changed
           END IF;  -- p_single_invoice_num
         END IF; -- IF mainrec.delivery_id IS NOT NULL

         -- modified by Allen Yang for for bug 9485355 (12.1.3 non-shippable Enhancement), end

         -- Now process the om-ar accounting if it is needed

          <<Processaccounting>>

          IF lv_debug = 'Y' THEN
             Fnd_File.PUT_LINE(Fnd_File.LOG, ' In process accounting section with p_process_action = ' || p_process_action);
          END IF;

          IF p_process_action in (jai_constants.om_action_gen_inv_n_accnt,jai_constants.om_action_gen_accounting) THEN
             /*
             ||  Only In case the parameter p_process_action in ('PROCESS ALL','PROCESS ACCOUNTING')  AND
             ||
             */
             IF lv_Debug = 'Y' THEN
                Fnd_File.PUT_LINE(Fnd_File.LOG, ' mainrec.vat_acct_status : ' || mainrec.vat_acct_status || ' lv_inv_gen_process_flag : ' || lv_inv_gen_process_flag );
             END IF;
             IF mainrec.vat_acct_status = 'C' THEN
                GOTO NEXTDELIVERY;
             END IF;
             IF lv_Debug = 'Y' THEN
                Fnd_File.PUT_LINE(Fnd_File.LOG, ' lv_inv_gen_process_flag = ' || lv_inv_gen_process_flag );
             END IF;
             IF lv_inv_gen_process_flag = jai_constants.successful THEN

                IF lv_vat_invoice_number IS NULL THEN
                   lv_vat_invoice_number:= mainrec.vat_invoice_no;
                END IF;

                IF p_process_action = jai_constants.om_action_gen_accounting
                THEN
                  lv_vat_invoice_number := mainrec.vat_invoice_no;
                END IF;

                IF lv_Debug = 'Y' THEN
                   Fnd_File.PUT_LINE(Fnd_File.LOG, 'Before Call to jai_cmn_rgm_vat_accnt_pkg.process_order_invoice ');
                END IF;
                jai_cmn_rgm_vat_accnt_pkg.process_order_invoice(
                                                                    P_REGIME_ID             => ln_regime_id ,
                                                                    -- modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
                                                                    P_SOURCE                => lv_p_source,
                                                                    -- P_SOURCE                => jai_constants.source_wsh ,
                                                                    -- modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), end
                                                                    P_ORGANIZATION_ID       => mainrec.organization_id,
                                                                    P_LOCATION_ID           => mainrec.location_id    ,
                                                                    P_DELIVERY_ID           => mainrec.delivery_id    ,
                                                                    -- added by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
                                                                    P_ORDER_LINE_ID         => mainrec.order_line_id  ,
                                                                    -- added by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), end
                                                                    P_CUSTOMER_TRX_ID       => NULL                   ,
                                                                    P_VAT_INVOICE_NO        => lv_vat_invoice_number  ,
                                                                    P_TRANSACTION_TYPE      => jai_cmn_rgm_vat_accnt_pkg.gv_transaction_type_dflt,
                                                                    P_DEFAULT_INVOICE_DATE  => NVL(ld_override_invoice_date,SYSDATE),
                                                                    P_BATCH_ID              => ln_batch_id            ,
                                                                    P_CALLED_FROM           => 'jai_cmn_rgm_processing_pkg.PROCESS',
                                                                    P_DEBUG                 => lv_debug               ,
                                                                    P_PROCESS_FLAG          => lv_acct_process_flag   ,
                                                                    P_PROCESS_MESSAGE       => lv_acct_process_message
                                                                   );
                IF lv_Debug = 'Y' THEN
                   Fnd_File.PUT_LINE(Fnd_File.LOG, 'after  Call to jai_cmn_rgm_vat_accnt_pkg.process_order_invoice  with status = ' || lv_acct_process_flag);
                END IF;
                IF lv_acct_process_flag = jai_constants.successful THEN
                   /*
                   || If the control comes here it means that Accounting got processed successfully.
                   || Check here if Delivery for successfully processed and invoice got successfully processed
                   || and only then do a commit
                   */
                   IF  lv_inv_gen_process_flag = jai_constants.successful  AND lv_acct_process_flag = jai_constants.successful  THEN
                       /*
                       || Both the activities have been succesfully completed
                       || Can commit the changes made to the delivery.
                       */
                       UPDATE JAI_RGM_INVOICE_GEN_T
                       SET    vat_acct_status         = 'C',
                       vat_inv_gen_err_message = NULL, /*following columns added by srjayara for bug 4702156*/
                       request_id = ln_conc_request_id,
                       program_id = ln_conc_progam_id,
                       program_application_id = ln_conc_prog_appl_id,
                       last_update_login = fnd_global.conc_login_id,
                       last_update_date  = sysdate
                       -- modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
                       -- WHERE  delivery_id = mainrec.delivery_id;
                       WHERE  delivery_id = NVL(mainrec.delivery_id, -1)
                          OR  order_line_id = NVL(mainrec.order_line_id, -1);
                       -- modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
                       COMMIT;
                   END IF;
                ELSE
                   ln_failure_delivery_ctr := NVL(ln_failure_Delivery_ctr,0) + 1;
                   Fnd_File.PUT_LINE(Fnd_File.LOG, 'Error Encountered after call to process_order_invoice is ' || lv_acct_process_message);
                END IF;

                IF  lv_inv_gen_process_flag <> jai_constants.successful  OR lv_acct_process_flag <> jai_constants.successful  THEN

                   /*
                   || There have been some errors which have happened during accounting
                   */
                    ROLLBACK;

                    IF lv_inv_gen_process_flag <> jai_constants.successful  THEN
                       UPDATE JAI_RGM_INVOICE_GEN_T
                       SET    vat_inv_gen_err_message    = substr(lv_inv_gen_process_message,1,1000),
                              vat_inv_gen_status         = 'E',
                              request_id = ln_conc_request_id, /*following columns added by srjayara for bug 4702156*/
                              program_id = ln_conc_progam_id,
                              program_application_id = ln_conc_prog_appl_id,
                              last_update_login = fnd_global.conc_login_id,
                              last_update_date  = sysdate
                        -- modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
                        -- WHERE  delivery_id = mainrec.delivery_id;
                        WHERE  delivery_id = NVL(mainrec.delivery_id, -1)
                           OR  order_line_id = NVL(mainrec.order_line_id, -1);
                        -- modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), end
                    END IF;

                    IF lv_acct_process_flag <> jai_constants.successful  THEN
                       UPDATE JAI_RGM_INVOICE_GEN_T
                       SET    vat_acct_err_message    = substr(lv_acct_process_message,1,1000),
                              vat_acct_status         = 'E',
                              request_id = ln_conc_request_id, /*following columns added by srjayara for bug 4702156*/
                              program_id = ln_conc_progam_id,
                              program_application_id = ln_conc_prog_appl_id,
                              last_update_login = fnd_global.conc_login_id,
                              last_update_date  = sysdate
                      -- modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
                      -- WHERE  delivery_id = mainrec.delivery_id;
                        WHERE  delivery_id = NVL(mainrec.delivery_id, -1)
                           OR  order_line_id = NVL(mainrec.order_line_id, -1);
                      -- modified by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), end
                    END IF;
                    COMMIT;
                END IF;

             END IF;  /* END IF For IF lv_inv_gen_process_flag = jai_constants.successful THEN  */
          END IF; /* END IF For IF p_process_action in ('ALL','PROCESS ACCOUNTING') THEN */
          <<NEXTDELIVERY>>
           NULL;
       END LOOP;

       -- added by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), begin
       -- need to purse JAI_RGM_INVOICE_GEN_T at the end of this concurrent
       DELETE FROM JAI_RGM_INVOICE_GEN_T
       WHERE vat_inv_gen_status = 'C'
       AND   vat_acct_status = 'C';
       -- added by Allen Yang for bug 9485355 (12.1.3 non-shippable Enhancement), end


   /*
   || Coding here to mark the status of the concurrent and generating statictics.
   ||
   */
   Fnd_File.PUT_LINE(Fnd_File.LOG, ' +++ Number of Successful deliveries  : ' || ln_success_delivery_Ctr || '+++');
   Fnd_File.PUT_LINE(Fnd_File.LOG, ' +++ Number of Failed deliveries  : ' || ln_failure_delivery_ctr || '+++');

   IF ln_failure_delivery_ctr > 0 AND ln_success_delivery_Ctr > 0 then
     /*
     || Atleast one delivery failed Atleast one delivery Succeeded
     || Signal completion with warning
     */
     lb_completion_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', NVL(lv_acct_process_message,lv_inv_gen_process_message));
     retcode := '1';
   END IF;
   IF ln_failure_delivery_ctr = 0 AND ln_success_delivery_Ctr > 0 then
     /*
     || Atleast one delivery Succeeded and none failed
     || Signal completion with success
     */
     lb_completion_status := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL', NULL);
     retcode := '0';
   END IF;
   IF ln_failure_delivery_ctr > 0 AND ln_success_delivery_Ctr = 0 then
     /*
     || Atleast one delivery failed and No delivery Succeeded
     || Signal completion with error
     */
     retcode := '2';
     lb_completion_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',NVL(lv_acct_process_message,lv_inv_gen_process_message));
   END IF;
   IF ln_failure_delivery_ctr = 0 AND ln_success_delivery_Ctr = 0 then
     /*
     || No delivery failed and No delivery Succeeded
     || Signal completion with Success
     */
     lb_completion_status := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL', NULL);
     retcode := '0';
   END IF;

   -- added by Allen Yang for bug 9709477 13-May-2010, begin
   IF (
     (lv_Same_invoice_no = jai_constants.yes) AND
     (NVL(p_single_invoice_num,jai_constants.No) = jai_constants.yes)
      )
   THEN
     lv_same_as_excise_conf_warning := '"Generate Single Invoice" is applicable only when "VAT invoice number same as Excise invoice number" is set as No.';
     -- added by Allen Yang for bug 9737119, begin
     -------------------------------------------------
     Fnd_File.PUT_LINE(Fnd_File.LOG, lv_same_as_excise_conf_warning);
     -------------------------------------------------
     -- added by Allen Yang for bug 9737119, end
     lb_completion_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', lv_same_as_excise_conf_warning);
     retcode := '1';
   END IF; -- (lv_Same_invoice_no = jai_constants.yes) AND ......
   -- added by Allen Yang for bug 9709477 13-May-2010, end

   EXCEPTION
   WHEN OTHERS THEN
     RETCODE := '2';
     Fnd_File.PUT_LINE(Fnd_File.LOG,'Unexpected Error occured in procedure jai_cmn_rgm_processing_pkg.process '||substr(sqlerrm,1,300));
     lb_completion_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',substr(sqlerrm,1,1000));
     ERRBUF := substr(sqlerrm,1,1000);
     lv_inv_gen_process_flag     := jai_constants.unexpected_error;
     lv_acct_process_flag        := jai_constants.unexpected_error;
     lv_inv_gen_process_message  := sqlerrm;
     lv_acct_process_message     := sqlerrm;

 END PROCESS;

END jai_cmn_rgm_processing_pkg;

/
