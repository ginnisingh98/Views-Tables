--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_RETURNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_RETURNS" AS
/* $Header: ARPRRTNB.pls 120.11.12010000.4 2009/07/22 09:31:38 aghoraka ship $ */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
G_PKG_NAME      CONSTANT VARCHAR2(30)   := 'ARP_PROCESS_RETURNS';

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
g_ccr_receivables_trx_id     NUMBER(15);
g_batch_source_id            ra_batch_sources.batch_source_id%type;
g_receipt_handling_option    ra_batch_sources.receipt_handling_option%type;
g_nccr_receivables_trx_id    NUMBER(15);

/*========================================================================
 | Prototype Declarations Procedures
 *=======================================================================*/
--
PROCEDURE check_rec_in_doubt(p_cash_receipt_id IN NUMBER,
                             x_rec_in_doubt OUT NOCOPY VARCHAR2,
                             x_rid_reason OUT NOCOPY VARCHAR2,
                             x_rec_proc_option IN VARCHAR2);
--
--
PROCEDURE get_receipt_amounts (p_cash_receipt_id IN NUMBER,
                            x_receipt_amount OUT NOCOPY NUMBER,
                            x_refund_amount  OUT NOCOPY NUMBER,
			    x_rec_proc_option IN VARCHAR2);
--
PROCEDURE add_ra_to_list(p_ra_info  IN app_info_type,
                         p_ra_rec   IN ar_receivable_applications%rowtype);
--
PROCEDURE populate_dff_and_gdf(p_ra_rec  IN ar_receivable_applications%rowtype,
                               x_dff_rec OUT NOCOPY
                                  ar_receipt_api_pub.attribute_rec_type,
                               x_gdf_rec OUT NOCOPY
                                  ar_receipt_api_pub.global_attribute_rec_type);
--
PROCEDURE fetch_gl_date( p_ra_rec IN ar_receivable_applications%rowtype,
                         p_gl_date OUT NOCOPY DATE);
--
PROCEDURE initialize_globals IS
BEGIN
   BEGIN
      SELECT receivables_trx_id
      INTO   g_ccr_receivables_trx_id
      FROM   ar_receivables_trx
      WHERE  type = 'CCREFUND'
      AND    status = 'A';
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
      WHEN OTHERS THEN
         RAISE;
   END;
   BEGIN
      SELECT receivables_trx_id
      INTO   g_nccr_receivables_trx_id
      FROM   ar_receivables_trx
      WHERE  type = 'CM_REFUND'
      AND    status = 'A';
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
      WHEN OTHERS THEN
         RAISE;
   END;

EXCEPTION
   WHEN OTHERS THEN
     RAISE;
END initialize_globals;

/*========================================================================
 | Procedure process_invoice_list()
 |
 | DESCRIPTION
 |      Process Invoices from the list prepared by the AutoInvoice
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 |
 | RETURNS
 |      nothing
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author           Description of Changes
 | 02-Jul-2003           Ramakant Alat    Created
 |
 *=======================================================================*/
PROCEDURE process_invoice_list AS

-- Get info for given Invoice
CURSOR c01 (p_customer_trx_id NUMBER) IS
SELECT
      inv.customer_trx_id inv_customer_trx_id,
      inv.invoice_currency_code,
      inv.exchange_rate,
      cmbs.receipt_handling_option,
      COUNT(DISTINCT invps.payment_schedule_id) ps_count,
      get_total_cm_amount(inv.customer_trx_id, cm.request_id) cm_amount,
      get_total_payment_types(inv.customer_trx_id) total_pmt_types,
      SUM(invps.amount_due_remaining)/
      COUNT(DISTINCT NVL(adj.adjustment_id, -9.9)) inv_balance,
      (SUM(NVL(invps.amount_applied, 0))+
      SUM(NVL(invps.discount_taken_earned, 0)))/
      COUNT(DISTINCT NVL(adj.adjustment_id, -9.9)) inv_app_amount,
      NVL(SUM(DECODE(adj.adjustment_type, 'C', adj.amount, 0)), 0) /
      COUNT(DISTINCT invps.payment_schedule_id) cmt_adj_amount,
      NVL(SUM(DECODE(adj.adjustment_type, 'C', 0, adj.amount)), 0) /
      COUNT(DISTINCT invps.payment_schedule_id) adj_amount
FROM
      ra_customer_trx inv,
      ar_payment_schedules invps,
      ra_cust_trx_types itt,
      ra_batch_sources cmbs,
      ra_customer_trx cm,
      ar_adjustments adj
WHERE
      inv.customer_trx_id            = cm.previous_customer_trx_id
  AND inv.customer_trx_id            = p_customer_trx_id
  AND inv.customer_trx_id            = invps.customer_trx_id
  AND cm.batch_source_id             = cmbs.batch_source_id
  AND cm.request_id                  = arp_global.request_id
  AND inv.cust_trx_type_id           = itt.cust_trx_type_id
  AND cmbs.receipt_handling_option IS NOT NULL
  AND itt.allow_overapplication_flag = 'N'
  AND inv.customer_trx_id            = adj.customer_trx_id (+)
GROUP BY
      cmbs.receipt_handling_option,
      cm.request_id,
      inv.invoice_currency_code,
      inv.exchange_rate,
      inv.customer_trx_id;
/***
   HAVING
      (SUM(invps.amount_due_original)/
       COUNT(DISTINCT NVL(adj.adjustment_id, -9.9))) > 0 ;
***/

adj_exception              EXCEPTION;
overapp_exception          EXCEPTION;
l_total_unapp_amount       NUMBER;
l_total_unapp_acctd_amount NUMBER;
l_rec_in_doubt             VARCHAR2(1):='N';
l_rid_reason               VARCHAR2(2000):= null;
l_mult_pmt_types_msg       VARCHAR2(2000):=
               arp_standard.fnd_message('AR_RID_MULTIPLE_PMT_TYPES');
l_min_ref_amt_msg          VARCHAR2(2000):=
                        arp_standard.fnd_message('AR_RID_OAPP_LT_MIN_REF_AMT');
l_split_term_with_bal_msg  VARCHAR2(2000):=
               arp_standard.fnd_message('AR_RID_SPLIT_TERM_WITH_BAL');
l_amt_lt_min_ref_amt_msg   VARCHAR2(2000):=
               arp_standard.fnd_message('AR_RID_OAPP_LT_MIN_REF_AMT');
i                          NUMBER(15):= 0;

BEGIN
   --
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_returns.process_invoice_list()+ ');
   END IF;
   --
   -- Check if there are any Invoices to process in the list
   --
   IF inv_info.COUNT = 0 THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('No Invoice in the list to process..');
      END IF;
      GOTO after_loop;
   END IF;
   --
   -- Process all Invoices added to the PL/SQL table by AutoInvoice
   --
   i := inv_info.FIRST;  -- get subscript of first element
   --
   WHILE i IS NOT NULL
   LOOP
      --
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('INV Customer Trx ID [' || i || ']');
      END IF;
      --
      FOR c01_rec IN c01 (i) LOOP
         --
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('CM count [' || inv_info(i).num_of_cms || ']');
            arp_standard.debug('Inv Balance [' || c01_rec.inv_balance || ']');
            arp_standard.debug('PS count [' || c01_rec.ps_count || ']');
            arp_standard.debug('Inv App Amount [' ||
               c01_rec.inv_app_amount || ']');
            arp_standard.debug('Commitment Adj amt [' ||
               c01_rec.cmt_adj_amount || ']');
            arp_standard.debug('Adj amt [' || c01_rec.adj_amount || ']');
            arp_standard.debug('CM amt [' || c01_rec.cm_amount || ']');
         END IF;
         --
         -- If adjustment exists then raise exception ***/
         --
         IF c01_rec.adj_amount <> 0 THEN
            arp_standard.debug('arp_process_returns.process_invoice_list : ' ||
            'adj_EXCEPTION customer_trx_id <' || c01_rec.inv_customer_trx_id ||
            '>');
            RAISE adj_exception;
         END IF;
         --
         -- Calculate Total amount which needs to be unapplied from receipts
         --
         l_total_unapp_amount := -1 * (c01_rec.inv_balance
                               - c01_rec.cmt_adj_amount
                               + c01_rec.cm_amount);
         --
         -- No overapplication, so no unapplication required
         --
         IF  c01_rec.cm_amount = 0 THEN
            GOTO end_loop;
         END IF;
         --
         -- If Total Unapp amount > Applied amount then raise exception
         --
         IF l_total_unapp_amount > (c01_rec.inv_app_amount)   THEN
            arp_standard.debug('arp_process_returns.process_invoice_list : ' ||
            'overapp_EXCEPTION customer_trx_id <'
            || c01_rec.inv_customer_trx_id || '>');
            arp_standard.debug('Inv Balance : <' || c01_rec.inv_balance);
            arp_standard.debug('Inv App Amount : <' || c01_rec.inv_app_amount);
            arp_standard.debug('Cmt Adj Amount : <' || c01_rec.cmt_adj_amount);
            arp_standard.debug('CM Amount : <' || c01_rec.cm_amount);
            RAISE overapp_exception;
         END IF;

         --
         -- Check if invoice has CC payment then check for receipt
         -- in doubt scenarios
         --
         IF c01_rec.total_pmt_types = 0 THEN
            --
            inv_info(i).cc_apps           := FALSE; -- No CC Applications
            inv_info(i).all_recs_in_doubt := FALSE; -- No receipts in doubt
            inv_info(i).rid_reason        := null;
            --
         ELSIF c01_rec.total_pmt_types = 1 THEN
            --
            inv_info(i).cc_apps          := TRUE;  -- CC Applications
            inv_info(i).all_recs_in_doubt := FALSE; -- No receipts in doubt
            inv_info(i).rid_reason       := null;
            --
/*         ELSE             --- Greater than 1
            --
            inv_info(i).cc_apps           := TRUE; -- No CC Applications
            --
            IF c01_rec.receipt_handling_option = 'REFUND' THEN
               inv_info(i).all_recs_in_doubt := TRUE; -- receipts in doubt
               inv_info(i).rid_reason        := l_mult_pmt_types_msg;

            ELSE
               inv_info(i).all_recs_in_doubt := FALSE; -- No receipts in doubt
               inv_info(i).rid_reason        := null;
            END IF; -- receipt handling option
*/ -- GGADHAMS  Commented as Refund can be now done for CC and Non CC Receipt

         ELSIF  c01_rec.receipt_handling_option = 'REFUND' THEN
            inv_info(i).cc_apps           := TRUE;
	    inv_info(i).all_recs_in_doubt := FALSE; -- No receipts in doubt
            inv_info(i).rid_reason        := null;
         ELSE
            inv_info(i).cc_apps           := TRUE;
            --
            --
         END IF; -- total_pmt_types
         --
         -- Check for RID due to min refund amount check
         --
         IF c01_rec.receipt_handling_option = 'REFUND' AND
            inv_info(i).cc_apps AND
            NOT inv_info(i).all_recs_in_doubt THEN
            --
            -- Get functional unapply amount
            --
            IF arp_global.functional_currency <> c01_rec.invoice_currency_code
            THEN
               l_total_unapp_acctd_amount:= ARPCURR.functional_amount(
                                          amount=>l_total_unapp_amount,
                                          currency_code=>
                                          c01_rec.invoice_currency_code,
                                          exchange_rate=>c01_rec.exchange_rate,
                                          precision=>null,
                                          min_acc_unit=>null);
            ELSE
               l_total_unapp_acctd_amount:= l_total_unapp_amount;
            END IF; -- functional_currency
            --
            -- Check for open split term  invoices
            --
            IF c01_rec.ps_count > 1  AND c01_rec.inv_balance > 0 THEN
               --
               inv_info(i).all_recs_in_doubt := TRUE; -- receipts in doubt
               inv_info(i).rid_reason        := l_split_term_with_bal_msg;
               --
            ELSIF NVL(arp_global.sysparam.min_refund_amount, 0) >
                  l_total_unapp_acctd_amount THEN
               --
               inv_info(i).all_recs_in_doubt := TRUE; -- receipts in doubt
               inv_info(i).rid_reason        := l_amt_lt_min_ref_amt_msg;
               --
            END IF;

         END IF; -- receipt_handling option
         --
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('Calling unapply_receipts...');
            arp_standard.debug('Inv Customer Trx ID [' ||
               c01_rec.inv_customer_trx_id || ']');
            arp_standard.debug('RecHandOption [' ||
               c01_rec.receipt_handling_option || ']');
            arp_standard.debug('Unapp amount [' || l_total_unapp_amount || ']');
            arp_standard.debug('RID Reason [' || inv_info(i).rid_reason  || ']');
            IF inv_info(i).all_recs_in_doubt THEN
               arp_standard.debug('Rec In doubt ');
            ELSE
               arp_standard.debug('Rec NOT In doubt ');
            END IF;
         END IF;

         --
         -- Call unapply_receipts
         --
         unapply_receipts (p_inv_customer_trx_id=>c01_rec.inv_customer_trx_id,
                           p_receipt_handling_option=>
                           c01_rec.receipt_handling_option);

         <<end_loop>>
         NULL;
      END LOOP;
      --
      i := inv_info.NEXT(i);
      --
   END LOOP;
   --
   <<after_loop>>
   --
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_RETURNS.process_invoice_list()- ');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      arp_standard.debug('EXCEPTION : arp_process_returns.process_invoice_list : ' || SQLERRM(SQLCODE));
      RAISE;
END process_invoice_list;

/*========================================================================
 | Procedure process_application_list()
 |
 | DESCRIPTION
 |      Process Applications from the list prepared by the unapply_receipts
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 |
 | RETURNS
 |      nothing
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author           Description of Changes
 | 18-Jul-2003           Ramakant Alat    Created
 |
 *=======================================================================*/
PROCEDURE process_application_list AS


-- Get open balance for the given Invoice
CURSOR c01 (p_payment_schedule_id NUMBER) IS
SELECT
      inv.customer_trx_id inv_customer_trx_id,
      inv.invoice_currency_code,
      inv.exchange_rate,
      invps.amount_due_remaining inv_balance
FROM
      ra_customer_trx inv,
      ar_payment_schedules invps
WHERE
      invps.payment_schedule_id = p_payment_schedule_id
  AND inv.customer_trx_id       = invps.customer_trx_id;

adj_exception               EXCEPTION;
overapp_exception           EXCEPTION;
l_apply_failed              EXCEPTION;
l_activity_app_failed       EXCEPTION;
l_on_account_app_failed     EXCEPTION;
l_total_unapp_amount        NUMBER;
l_refund_amount             ar_cash_receipts.amount%type;
l_pay_refund_amount         ar_cash_receipts.amount%type;
l_on_account_amount         ar_cash_receipts.amount%type;
l_old_refund_amount         ar_cash_receipts.amount%type;
l_receipt_amount            ar_cash_receipts.amount%type;
l_reapply_amount            ar_cash_receipts.amount%type;
l_new_apply_amount          ar_cash_receipts.amount%type;
l_new_apply_amount_fr       ar_cash_receipts.amount%type;
l_ch_apply_amount_fr        ar_cash_receipts.amount%type;
l_total_unapp_amount        NUMBER;
l_rec_in_doubt              VARCHAR2(1):='N';
l_rid_reason                VARCHAR2(2000):= null;
l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);
l_app_comments              ar_receivable_applications.comments%type :=
    arp_standard.fnd_message('AR_RID_PROCESSED_AS_PER_REQ');
l_application_ref_type      ar_receivable_applications.application_ref_type%type;
l_application_ref_id        ar_receivable_applications.application_ref_id%type;
l_application_ref_num       ar_receivable_applications.application_ref_num%type;
l_receivable_application_id ar_receivable_applications.receivable_application_id%type;
l_new_ra_rec                ar_receivable_applications%rowtype;
l_refunding                 BOOLEAN:=FALSE;
l_gdf_rec                   ar_receipt_api_pub.global_attribute_rec_type;
l_dff_rec                   ar_receipt_api_pub.attribute_rec_type;
l_party_id                  hz_parties.party_id%type;
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_returns.process_application_list()+ ');
   END IF;
   --
   -- Check if there are any applications to process in the list
   --
   IF app_info.COUNT = 0 THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('No Application in the list to process..');
      END IF;
      GOTO after_loop;
   END IF;
   --
   -- Process all applications added to the PL/SQL table by unapply_receipts
   --
   FOR i IN 1..app_info.COUNT
   LOOP
      --
      --
      --
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('INV Customer Trx ID [' ||
         app_tab(i).applied_customer_trx_id || ']');
         arp_standard.debug('rec_proc_option [' ||
         app_info(i).rec_proc_option || ']');
         arp_standard.debug('rec_in_doubt [' ||
         app_info(i).rec_in_doubt || ']');
         arp_standard.debug('rec_currency_code [' ||
         app_info(i).rec_currency_code || ']');
         arp_standard.debug('inv_currency_code [' ||
         app_info(i).inv_currency_code || ']');
         arp_standard.debug('rid_reason [' ||
         app_info(i).rid_reason || ']');
         arp_standard.debug('trx_number [' ||
         app_info(i).trx_number || ']');
      END IF;
      --
      FOR c01_rec IN c01 (app_tab(i).applied_payment_schedule_id)
      LOOP
         --
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('Inv Balance [' || c01_rec.inv_balance || ']');
            arp_standard.debug('Inv Customer Trx Id [' || c01_rec.inv_customer_trx_id || ']');
         END IF;
         --
         -- Compute reapply amount ** 1 **
         --
         l_reapply_amount := LEAST(app_tab(i).amount_applied,
                                   c01_rec.inv_balance );



	 IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('  l_reapply_amount  [' ||  l_reapply_amount  || ']');
         END IF;

	 IF l_reapply_amount > 0 THEN
            --
            -- Get Amount Applied to be passed to Receipt API
            --
            IF app_tab(i).amount_applied +
               NVL(app_tab(i).earned_discount_taken, 0) >= c01_rec.inv_balance
            THEN
            --
               l_new_apply_amount := null;
            --
            ELSE
            --
               l_new_apply_amount := app_tab(i).amount_applied;
            --
            END IF;

	    IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('  l_new_apply_amount  [' ||  l_new_apply_amount  || ']');
            END IF;


            --
            -- Populate DFF and GDF for re-app from the Old app
            --
            populate_dff_and_gdf(p_ra_rec=>app_tab(i),
                                 x_dff_rec=>l_dff_rec,
                                 x_gdf_rec=>l_gdf_rec
                                 );
            --
            -- Apply to original payment schedule
            --
            -- Re-apply to the application to the same invoice
            --
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('Re-apply back to invoice ps[' ||
                  app_tab(i).applied_payment_schedule_id ||'] : <'  ||
                  l_reapply_amount|| '>');
            END IF;
            --
            --
            ar_receipt_api_pub.Apply(p_api_version => 1.0,
                     x_return_status     => l_return_status,
                     x_msg_count         => l_msg_count,
                     x_msg_data          => l_msg_data,
                     p_cash_receipt_id   => app_tab(i).cash_receipt_id,
                     p_applied_payment_schedule_id  =>
                         app_tab(i).applied_payment_schedule_id,
                     p_amount_applied    => l_new_apply_amount,
                     p_trans_to_receipt_rate =>
                         app_tab(i).trans_to_receipt_rate,
                     p_apply_date      => app_tab(i).apply_date,
                     p_apply_gl_date   => app_tab(i).reversal_gl_date,
                     p_comments          => app_tab(i).comments,
                     p_ussgl_transaction_code  =>
                         app_tab(i).ussgl_transaction_code,
                     p_customer_trx_line_id  =>
                         app_tab(i).applied_customer_trx_line_id,
                     p_attribute_rec  => l_dff_rec,
                     p_global_attribute_rec  => l_gdf_rec,
                     p_customer_reference  =>
                         app_tab(i).customer_reference,
                     p_customer_reason  => app_tab(i).customer_reason
                    );

            IF l_return_status  <> FND_API.G_RET_STS_SUCCESS THEN

               IF (l_msg_count = 1) THEN
                  arp_standard.debug('Apply: ' || l_MSG_DATA);
               ELSIF(l_MSG_COUNT>1)THEN
                  LOOP
                     l_MSG_DATA:=FND_MSG_PUB.GET(p_encoded=>FND_API.G_FALSE);
                     IF (l_MSG_DATA IS NULL)THEN
                        EXIT;
                     END IF;
                     arp_standard.debug('Apply : ' || l_MSG_DATA);
                  END LOOP;
               END IF;

               arp_standard.debug('Apply failed');

               RAISE l_apply_failed;

            END IF;
            --
            -- Fetch Rec App record for the application
            --
            arp_app_pkg.fetch_p(p_ra_id=>
                   ar_receipt_api_pub.apply_out_rec.receivable_application_id,
                   p_ra_rec=>l_new_ra_rec);
            --
            -- Get Amount Applied from for the new application
            --
            l_new_apply_amount_fr := NVL(l_new_ra_rec.amount_applied_from, 0);
            l_new_apply_amount    := NVL(l_new_ra_rec.amount_applied, 0);
            --
         ELSE
            l_new_apply_amount    := 0;
            l_new_apply_amount_fr := 0;
         END IF;
         --
         -- Compute change in Application amount applied "from"
         --
         IF app_info(i).cross_currency THEN
            --
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('Cross Currency');
               arp_standard.debug('Re-apply Amount :' || l_reapply_amount);
               arp_standard.debug('New-apply Amount :' || l_new_apply_amount);
               arp_standard.debug('T->R Rate       :' ||
                  app_tab(i).trans_to_receipt_rate);
               arp_standard.debug('Currency REC    :' ||
                             app_info(i).rec_currency_code);
            END IF;
            --
            /***
            l_new_apply_amount_fr :=
            arp_util.CurrRound(
                            l_reapply_amount *
                               app_tab(i).trans_to_receipt_rate,
                             app_info(i).rec_currency_code
                            );
            ***/
            --
            l_ch_apply_amount_fr := app_tab(i).amount_applied_from -
                                       l_new_apply_amount_fr;
            --
         ELSE
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('Not Cross Currency');
               arp_standard.debug('Old Amount Applied :' ||
                  app_tab(i).amount_applied );
               arp_standard.debug('New Amount Applied :' ||
                  l_new_apply_amount);
            END IF;
            l_ch_apply_amount_fr := app_tab(i).amount_applied -
                                       l_new_apply_amount;
         END IF;
         --
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('Change in App amount [' ||
               app_tab(i).applied_payment_schedule_id ||'] : <'  ||
               l_ch_apply_amount_fr || '>');
         END IF;
         --
         --
         --  Initialize amounts
         --
         l_refund_amount := 0;
         l_old_refund_amount := 0;
         l_on_account_amount := 0;
         l_receipt_amount := 0;
         l_refunding := FALSE;
         l_pay_refund_amount :=0;

         IF app_info(i).rec_in_doubt = 'N' AND
         app_info(i).rec_proc_option = 'REFUND' THEN
            --
            l_refunding := TRUE;
            --
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('Refunding...');
            END IF;
            --
            -- Get receipt amount and old refund amounts from the receipt
            --
            get_receipt_amounts(
               p_cash_receipt_id=>app_tab(i).cash_receipt_id,
               x_receipt_amount=>l_receipt_amount,
               x_refund_amount=>l_old_refund_amount,
               x_rec_proc_option=> app_info(i).rec_proc_option);
            --
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('Cash Receipt Id ' ||
                  app_tab(i).cash_receipt_id ||'] :  RecAmt<'  ||
                  l_receipt_amount|| '>' );
               arp_standard.debug('Old Refund Amount :[' ||
                  l_old_refund_amount  ||']');
            END IF;
            --
            --
            -- Compute refund amount = LEAST(receipt amount - old refunds,
            --                               change in application amount)
            --
            l_refund_amount := LEAST(l_receipt_amount - l_old_refund_amount,
                                     l_ch_apply_amount_fr);
            --
         ELSE
            l_refund_amount := 0;
         END IF;
         --
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('New Refund Amount [' || l_refund_amount || ']');
         END IF;

--GGADHAMS Added for Payment Refund
    IF app_info(i).rec_in_doubt = 'N' AND
         app_info(i).rec_proc_option = 'PAY_REFUND' THEN
            --
            l_refunding := TRUE;
            --
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('Payment Refunding...');
            END IF;
            --
            -- Get receipt amount and old refund amounts from the receipt
            --
            get_receipt_amounts(
               p_cash_receipt_id=>app_tab(i).cash_receipt_id,
               x_receipt_amount=>l_receipt_amount,
               x_refund_amount=>l_old_refund_amount,
       	       x_rec_proc_option=> app_info(i).rec_proc_option);
            --
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('Cash Receipt Id ' ||
                  app_tab(i).cash_receipt_id ||'] :  RecAmt<'  ||
                  l_receipt_amount|| '>' );
               arp_standard.debug('Old Refund Amount :[' ||
                  l_old_refund_amount  ||']');
            END IF;
            --
            --
            -- Compute refund amount = LEAST(receipt amount - old refunds,
            --                               change in application amount)
            --
            l_pay_refund_amount := LEAST(l_receipt_amount - l_old_refund_amount,
                                     l_ch_apply_amount_fr);
            --
         ELSE
            l_pay_refund_amount := 0;
         END IF;
         --
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('New Payment  Refund Amount [' || l_pay_refund_amount || ']');
         END IF;
--Added till here for Payment Refund
         --

         --
         -- Get On-account application amount = (change in application amount
         --                                      - refund amount)
         --
         l_on_account_amount := l_ch_apply_amount_fr - l_refund_amount - l_pay_refund_amount;
         --
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('On Account Amount [' ||
               l_on_account_amount|| ']');
         END IF;
         --
         --
         -- Create Credit Card application
         --
         IF l_refund_amount > 0 THEN
             -- Apply to CCR
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('Creating CCR application..');
               arp_standard.debug('l_app_comments :[' || l_app_comments ||']');
            END IF;
            --
            -- Initialize IN-OUT variables
            --
            l_application_ref_type := null;
            l_application_ref_id   := null;
            l_application_ref_num  := null;
            --

             select party_id
             into l_party_id
	     from
	     hz_cust_accounts acc,
	     ra_customer_trx  trx
	     where trx.bill_to_customer_id = acc.cust_account_id
             and trx.trx_number = app_info(i).trx_number;

            ar_receipt_api_pub.activity_application(
               p_api_version                  => 1.0,
               x_return_status                => l_return_status,
               x_msg_count                    => l_msg_count,
               x_msg_data                     => l_msg_data,
               p_cash_receipt_id              =>
                  app_tab(i).cash_receipt_id,
               p_amount_applied               => l_refund_amount,
               p_applied_payment_schedule_id  => -6,
               p_receivables_trx_id           => g_ccr_receivables_trx_id,
               p_apply_gl_date                => app_tab(i).reversal_gl_date,
               p_comments                     => l_app_comments,
               p_application_ref_type         => l_application_ref_type,
               p_application_ref_id           => l_application_ref_id,
               p_application_ref_num          => l_application_ref_num,
               p_secondary_application_ref_id =>
                  app_tab(i).applied_customer_trx_id,
               p_secondary_app_ref_type       => 'TRANSACTION',
               p_secondary_app_ref_num        => app_info(i).trx_number,
               p_receivable_application_id    => l_receivable_application_id,
               p_party_id                     => l_party_id
              );

            IF l_return_status  <> FND_API.G_RET_STS_SUCCESS THEN

               IF (l_msg_count = 1) THEN
                  arp_standard.debug('ActivityApp: ' || l_MSG_DATA);
               ELSIF(l_MSG_COUNT>1)THEN
                  LOOP
                     l_MSG_DATA:=FND_MSG_PUB.GET(p_encoded=>FND_API.G_FALSE);
                     IF (l_MSG_DATA IS NULL)THEN
                        EXIT;
                     END IF;
                     arp_standard.debug('ActivityApp: ' || l_MSG_DATA);
                  END LOOP;
               END IF;

               arp_standard.debug('ActivityApp failed');

               RAISE l_activity_app_failed;
            END IF; -- Handle API errors
            --
         END IF; -- Process CCR
         --
         -- Create On-account application
         --
         IF l_on_account_amount > 0 THEN
         --
            -- Apply to ON-ACCOUNT
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('Creating ON-ACCOUNT application..');
               arp_standard.debug('l_app_comments :[' || l_app_comments ||']');
               arp_standard.debug('l_app_comments NVL:[' ||
                  NVL(app_info(i).rid_reason, l_app_comments) ||']');
            END IF;
            --
            --
            IF l_refunding  THEN
               l_app_comments := arp_standard.fnd_message('AR_RID_TOTAL_REFUND_LIMIT');
            END IF;
            ar_receipt_api_pub.Apply_on_account(
               p_api_version                  => 1.0,
               x_return_status                => l_return_status,
               x_msg_count                    => l_msg_count,
               x_msg_data                     => l_msg_data,
               p_cash_receipt_id              =>
                  app_tab(i).cash_receipt_id,
               p_apply_gl_date                => app_tab(i).reversal_gl_date,
               p_amount_applied               => l_on_account_amount,
               p_comments                     => NVL(app_info(i).rid_reason,
                                                     l_app_comments),
               p_secondary_application_ref_id =>
                  app_tab(i).applied_customer_trx_id,
               p_secondary_app_ref_type       => 'TRANSACTION',
               p_secondary_app_ref_num        => app_info(i).trx_number
              );
            IF l_return_status  <> FND_API.G_RET_STS_SUCCESS THEN

               IF (l_msg_count = 1) THEN
                  arp_standard.debug('OnaccountApp: ' || l_MSG_DATA);
               ELSIF(l_MSG_COUNT>1)THEN
                  LOOP
                     l_MSG_DATA:=FND_MSG_PUB.GET(p_encoded=>FND_API.G_FALSE);
                     IF (l_MSG_DATA IS NULL)THEN
                        EXIT;
                     END IF;
                     arp_standard.debug('OnaccountApp : ' || l_MSG_DATA);
                  END LOOP;
               END IF;

               arp_standard.debug('OnaccountApp failed');

               RAISE l_on_account_app_failed;

            END IF;
            --
         END IF; -- Process On-Account


         -- GGADHAMS
         -- Create Payment Refund application
         --
         IF l_pay_refund_amount > 0 THEN
         --

            -- Initialize IN-OUT variables Bug8402274
            --
            l_application_ref_type := null;
            l_application_ref_id   := null;
            l_application_ref_num  := null;

            -- Apply to PAYMENT REFUND
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('Creating Payment Refund application..');
               arp_standard.debug('l_app_comments :[' || l_app_comments ||']');
               arp_standard.debug('l_app_comments NVL:[' ||
                  NVL(app_info(i).rid_reason, l_app_comments) ||']');
            END IF;
            --
		 ar_receipt_api_pub.activity_application(
               p_api_version                  => 1.0,
                p_init_msg_list =>FND_API.G_FALSE,
                p_commit =>FND_API.G_FALSE,
                p_validation_level  =>FND_API.G_VALID_LEVEL_FULL,
               x_return_status                => l_return_status,
               x_msg_count                    => l_msg_count,
               x_msg_data                     => l_msg_data,
               p_cash_receipt_id              => app_tab(i).cash_receipt_id,
               p_amount_applied               => l_pay_refund_amount,
               p_applied_payment_schedule_id  => -8,
               p_receivables_trx_id           =>  g_nccr_receivables_trx_id,
               p_apply_gl_date                => app_tab(i).reversal_gl_date,
               p_comments                     => l_app_comments,
               p_application_ref_type         => l_application_ref_type,
               p_application_ref_id           => l_application_ref_id,
               p_application_ref_num          => l_application_ref_num,
               p_secondary_application_ref_id =>  app_tab(i).applied_customer_trx_id,
               p_secondary_app_ref_type       => 'TRANSACTION',
               p_secondary_app_ref_num        =>  app_info(i).trx_number,
               p_receivable_application_id    => l_receivable_application_id
--              p_party_id => 1004
              );
           IF l_return_status  <> FND_API.G_RET_STS_SUCCESS THEN

               IF (l_msg_count = 1) THEN
                  arp_standard.debug('ActivityApp: ' || l_MSG_DATA);
               ELSIF(l_MSG_COUNT>1)THEN
                  LOOP
                     l_MSG_DATA:=FND_MSG_PUB.GET(p_encoded=>FND_API.G_FALSE);
                     IF (l_MSG_DATA IS NULL)THEN
                        EXIT;
                     END IF;
                     arp_standard.debug('ActivityApp: ' || l_MSG_DATA);
                  END LOOP;
               END IF;

               arp_standard.debug('ActivityApp failed');

               RAISE l_activity_app_failed;
            END IF; -- Handle API errors
            --
    END IF; -- Process PAyment Refund




         <<end_loop>>
         NULL;
      END LOOP;
   END LOOP;
   --
   <<after_loop>>
   --
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_RETURNS.process_application_list()- ');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      arp_standard.debug('EXCEPTION : arp_process_returns.process_application_list : ' || SQLERRM(SQLCODE));
      RAISE;
END process_application_list;

/*========================================================================
 | Procedure unapply_receipts()
 |
 | DESCRIPTION
 |      Unapply all receipt applications for the given invoice
 |      and create the application list. This list will be used to create
 |      special applications and apply remaining amount back to original
 |      invoice
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 |   p_inv_customer_trx_id  - Invoice customer Trx ID
 |   p_receipt_handling_option IN VARCHAR2
 |
 | RETURNS
 |      nothing
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author           Description of Changes
 | 17-Jul-2003           Ramakant Alat    Created
 |
 *=======================================================================*/

PROCEDURE unapply_receipts (p_inv_customer_trx_id IN NUMBER,
                            p_receipt_handling_option IN VARCHAR2
                           ) AS

--
-- Cursor to get information about all receipt applications for the
-- given invoice.
--
/*GGADHAMS Modified the cursor for automated Receipt Handling using
Payment Refund*/
CURSOR c02 (p_customer_trx_id NUMBER,
            p_receipt_handling_option IN VARCHAR2) IS
SELECT
      ra.receivable_application_id,
      ra.cash_receipt_id,
      cr.amount,
      cr.currency_code rec_currency_code,
      inv.invoice_currency_code,
      ra.applied_customer_trx_id,
      ra.applied_payment_schedule_id,
      inv.trx_number,
      rm.payment_channel_code payment_type,
--      DECODE(p_receipt_handling_option, 'REFUND',
--                                     DECODE(rm.payment_channel_code,
--                                            'CREDIT_CARD', 'REFUND',
--                                            'ON-ACCOUNT'),
--                                     'ON-ACCOUNT') rec_proc_option,
     DECODE(p_receipt_handling_option, 'REFUND',
                                     DECODE(rm.payment_channel_code,
                                            'CREDIT_CARD', 'REFUND',
                                            ' BANK_ACCT_XFER','PAY_REFUND',
                                              null,'PAY_REFUND',
                                             'ON-ACCOUNT'),
                                     'ON-ACCOUNT') rec_proc_option,
      ra.amount_applied,
      ra.amount_applied_from
FROM
      ar_receivable_applications ra
     ,ar_cash_receipts cr
     ,ar_receipt_methods rm
     ,ra_customer_trx inv
WHERE
      ra.applied_customer_trx_id = p_customer_trx_id
  AND ra.cash_receipt_id         = cr.cash_receipt_id
  AND rm.receipt_method_id       = cr.receipt_method_id
  AND ra.display                 = 'Y'
  AND ra.applied_customer_trx_id = inv.customer_trx_id
ORDER BY
   ra.APPLY_DATE,  --- This is for aging
   TO_NUMBER(DECODE(p_receipt_handling_option, 'REFUND',
                                     DECODE(rm.payment_channel_code, 'CREDIT_CARD',
                                                              2, 1) ,
                                     ra.amount_applied)) desc,
   ra.amount_applied desc;

-- Local Variables
l_application_ref_type      ar_receivable_applications.application_ref_type%type;
l_application_ref_id        ar_receivable_applications.application_ref_id%type;
l_secondary_application_ref_id  ar_receivable_applications.secondary_application_ref_id%type;
l_application_ref_num       ar_receivable_applications.application_ref_num%type;
l_receivable_application_id ar_receivable_applications.receivable_application_id%type;
l_receivables_trx_id        ar_receivable_applications.receivables_trx_id%type;
l_app_comments              ar_receivable_applications.comments%type;

l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);
l_rid_reason                VARCHAR2(2000);
l_unapp_amt_remaining       ar_receivable_applications.amount_applied%type;
l_unapp_amount              ar_receivable_applications.amount_applied%type;
l_ra_rec                    ar_receivable_applications%rowtype;
l_unapply_failed            EXCEPTION;
l_apply_failed              EXCEPTION;
l_activity_app_failed       EXCEPTION;
l_on_account_app_failed     EXCEPTION;
l_ra_info                   app_info_type;
l_rec_in_doubt              VARCHAR2(1):='N';
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_RETURNS.unapply_receipts()+ ');
      arp_standard.debug('p_inv_customer_trx_id :<' || p_inv_customer_trx_id ||'>');
      arp_standard.debug('rec_hand_option :<' || p_receipt_handling_option ||'>');
   END IF;
   --
   --
   --
   FOR c02_rec IN c02(p_inv_customer_trx_id,
       p_receipt_handling_option) LOOP
      --
      --
      l_rec_in_doubt := 'N';
      l_rid_reason   := null;
      --
      -- If receipt is not already in doubt then check for doubt
      --

-- Need to add check receipt in doubt for PAY_REFUND
      IF c02_rec.rec_proc_option = 'REFUND' THEN
         --
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('CC receipt with refund request ');
         END IF;
         --
         IF inv_info(p_inv_customer_trx_id).all_recs_in_doubt THEN
            --
            l_rec_in_doubt := 'Y';
            l_rid_reason   := inv_info(p_inv_customer_trx_id).rid_reason;
            --
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('All recs in doubt :<' || l_rid_reason ||'>');
            END IF;
            --
         ELSE
            --
            check_rec_in_doubt(p_cash_receipt_id=>c02_rec.cash_receipt_id,
                                x_rec_in_doubt =>l_rec_in_doubt,
                                x_rid_reason=>l_rid_reason,
                                x_rec_proc_option => c02_rec.rec_proc_option);
            --
            --
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('After RID chk :<' || l_rid_reason ||'>');
            END IF;
            --
         END IF;
         --

      END IF;


      IF c02_rec.rec_proc_option = 'PAY_REFUND' THEN
         --
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('Non CC receipt with refund request ');
         END IF;
         --
         IF inv_info(p_inv_customer_trx_id).all_recs_in_doubt THEN
            --
            l_rec_in_doubt := 'Y';
            l_rid_reason   := inv_info(p_inv_customer_trx_id).rid_reason;
            --
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('All recs in doubt :<' || l_rid_reason ||'>');
            END IF;
            --
         ELSE
            --
            check_rec_in_doubt(p_cash_receipt_id=>c02_rec.cash_receipt_id,
                                x_rec_in_doubt =>l_rec_in_doubt,
                                x_rid_reason=>l_rid_reason,
                                x_rec_proc_option=> c02_rec.rec_proc_option);
            --
            --
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('After Non CC  RID chk :<' || l_rid_reason ||'>');
            END IF;
            --
         END IF;
         --

      END IF;


      --
      -- Before we unapply receipt, get current application info.
      -- This application info will be used to create special apps and
      -- remaining amount re-app to old transaction.
      --
      -- Fetch Rec App record for the application
      --
      arp_app_pkg.fetch_p(p_ra_id=>c02_rec.receivable_application_id,
                          p_ra_rec=>l_ra_rec);
      --
      -- Add Receivable Application record to the list
      --
      -- This list will be used to create special apps e.g. REFUND, ON-ACCOUNT
      -- and re-app to old transaction
      --
      /* Bug 8686218 */
     IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('Call to fetch_gl_date :  '||to_char(l_ra_rec.reversal_gl_date));
     END IF;

      fetch_gl_date(p_ra_rec => l_ra_rec,
                    p_gl_date => l_ra_rec.reversal_gl_date);

     IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('Defaulted gl date via fetch_gl_date :  '||to_char(l_ra_rec.reversal_gl_date));
     END IF;

      l_ra_info.rec_proc_option   := c02_rec.rec_proc_option;
      l_ra_info.rec_in_doubt      := l_rec_in_doubt;
      l_ra_info.rid_reason        := l_rid_reason;
      l_ra_info.trx_number        := c02_rec.trx_number;
      l_ra_info.rec_currency_code := c02_rec.rec_currency_code;
      l_ra_info.inv_currency_code := c02_rec.invoice_currency_code;
      --
      IF c02_rec.rec_currency_code <> c02_rec.invoice_currency_code THEN
         l_ra_info.cross_currency := TRUE;
      ELSE
         l_ra_info.cross_currency := FALSE;
      END IF;
      --
      l_ra_info.inv_currency_code := c02_rec.invoice_currency_code;
      --
      add_ra_to_list(p_ra_info=>l_ra_info, p_ra_rec=>l_ra_rec);
      --
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('rec_app_id :<' ||
            c02_rec.receivable_application_id ||'>');
         arp_standard.debug('rec_in_doubt :<' || l_rec_in_doubt ||'>');
         arp_standard.debug('rec_in_doubt_reason :<' ||
            l_rid_reason ||'>');
         arp_standard.debug('rec_proc_option :<' ||
            c02_rec.rec_proc_option ||'>');
      END IF;
      --
      -- Unapply the application
      --
      ar_receipt_api_pub.Unapply(
               p_api_version               => 1.0,
               x_return_status             => l_return_status,
               x_msg_count                 => l_msg_count,
               x_msg_data                  => l_msg_data,
               p_receivable_application_id => c02_rec.receivable_application_id,
               p_reversal_gl_date          => l_ra_rec.reversal_gl_date
              );

      IF l_return_status  <> FND_API.G_RET_STS_SUCCESS THEN

         IF (l_msg_count = 1) THEN
            arp_standard.debug('Unapply: ' || l_MSG_DATA);
         ELSIF(l_MSG_COUNT>1)THEN
            LOOP
               l_MSG_DATA:=FND_MSG_PUB.GET(p_encoded=>FND_API.G_FALSE);
               IF (l_MSG_DATA IS NULL)THEN
                  EXIT;
               END IF;
               arp_standard.debug('UNapply: ' || l_MSG_DATA);
            END LOOP;
         END IF;

         arp_standard.debug('Unapplication failed');
         RAISE l_unapply_failed;
      END IF;

   END LOOP;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_RETURNS.unapply_receipts()- ');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      arp_standard.debug('arp_process_returns.unapply_receipts : '
         || SQLERRM(SQLCODE));
      RAISE;

END unapply_receipts;

--
-- Add invoice to the list, which will be used for further processing
--

PROCEDURE add_invoice (p_customer_trx_id IN NUMBER) IS
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_RETURNS.add_invoice()+ ');
      arp_standard.debug('p_customer_trx_id :<' || p_customer_trx_id ||'>');
   END IF;

   IF inv_info.EXISTS(p_customer_trx_id) THEN
      inv_info(p_customer_trx_id).num_of_cms :=
         inv_info(p_customer_trx_id).num_of_cms + 1;
   ELSE
      inv_info(p_customer_trx_id).num_of_cms := 1;
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_RETURNS.add_invoice()- ');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      arp_standard.debug('arp_process_returns.add_invoice : ' ||
      SQLERRM(SQLCODE));
      RAISE;
END;

--
-- Add Receipt Application to the list,
-- which will be used for further processing
--

PROCEDURE add_ra_to_list(p_ra_info  IN app_info_type,
                         p_ra_rec   IN ar_receivable_applications%rowtype) AS
l_cnt  NUMBER := app_info.COUNT;
BEGIN
   --
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_RETURNS.add_ra_to_list()+ ');
      arp_standard.debug('count :<' || l_cnt ||'>');
   END IF;
   --
   l_cnt := l_cnt + 1;
   app_info(l_cnt) := p_ra_info;
   app_tab(l_cnt)  := p_ra_rec;
   --
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_RETURNS.add_ra_to_list()- ');
   END IF;
   --
EXCEPTION
   WHEN OTHERS THEN
      arp_standard.debug('arp_process_returns.add_ra_to_list : ' ||
      SQLERRM(SQLCODE));
      RAISE;
END;
--
-- Get Total CM amount for a given invoice
--
FUNCTION get_total_cm_amount (p_inv_customer_trx_id IN NUMBER,
                              p_request_id IN NUMBER) RETURN NUMBER AS

l_total_cm_amount  RA_CUSTOMER_TRX_LINES.EXTENDED_AMOUNT%TYPE;

BEGIN
   --
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_RETURNS.get_total_cm_amount()+ ');
      arp_standard.debug('p_inv_customer_trx_id :<'
         || p_inv_customer_trx_id ||'>');
   END IF;
   --
   SELECT NVL(SUM(extended_amount) , 0)
   INTO   l_total_cm_amount
   FROM   RA_CUSTOMER_TRX_LINES
   WHERE  previous_customer_trx_id = p_inv_customer_trx_id
   AND    request_id               = p_request_id;
   --
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('l_total_cm_amount :<'
         || l_total_cm_amount ||'>');
      arp_standard.debug('arp_process_RETURNS.get_total_cm_amount()- ');
   END IF;
   --

   RETURN l_total_cm_amount;
EXCEPTION
   WHEN OTHERS THEN
      arp_standard.debug('EXCEPTION:arp_process_returns.get_total_cm_amount : '
      || SQLERRM(SQLCODE));
      RAISE;

END get_total_cm_amount;

--
-- Get total payment types for all receipts applied to this invoice
--
--Modified the select using Payment Channel code to identify the payment type
--Need confirmation on count and NVL
FUNCTION get_total_payment_types (p_inv_customer_trx_id IN NUMBER)
RETURN NUMBER AS

l_total_payment_types     NUMBER:=0;
l_total_cc_pmts           NUMBER:=0;

BEGIN
   --
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_RETURNS.get_total_payment_types()+ ');
      arp_standard.debug('p_inv_customer_trx_id :<'
         || p_inv_customer_trx_id ||'>');
   END IF;
   --
   SELECT
--          count(distinct NVL(rm.payment_channel_code, 'CHECK')) ,
            count(distinct NVL(rm.payment_channel_code, 'CHECK')) ,
--          sum(DECODE(rm.payment_channel_code, 'CREDIT_CARD', 1, 0))
            sum(DECODE(rm.payment_channel_code, 'CREDIT_CARD', 1, 0))
   INTO
          l_total_payment_types,
          l_total_cc_pmts
   FROM   AR_RECEIVABLE_APPLICATIONS ra,
          ar_cash_receipts cr,
          ar_receipt_methods rm
   WHERE  ra.applied_customer_trx_id = p_inv_customer_trx_id
     AND  ra.cash_receipt_id         = cr.cash_receipt_id
     AND  cr.receipt_method_id       = rm.receipt_method_id;

   IF l_total_cc_pmts = 0 THEN
      l_total_payment_types := 0;
   END IF;
   --
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('l_total_payment_types :<'
         || l_total_payment_types ||'>');
      arp_standard.debug('arp_process_RETURNS.get_total_payment_types()- ');
   END IF;
   --
   RETURN l_total_payment_types;
   --
EXCEPTION
   WHEN OTHERS THEN
      arp_standard.debug('EXCEPTION:arp_process_returns.get_total_payment_types : '
      || SQLERRM(SQLCODE));
      RAISE;

END get_total_payment_types;


--
-- Get receipt and refund amounts
--
PROCEDURE get_receipt_amounts (p_cash_receipt_id IN NUMBER,
                            x_receipt_amount OUT NOCOPY NUMBER,
                            x_refund_amount  OUT NOCOPY NUMBER,
		            x_rec_proc_option IN VARCHAR2) AS

BEGIN
   --
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_RETURNS.get_receipt_amounts()+ ');
      arp_standard.debug('p_cash_receipt_id :<'
         || p_cash_receipt_id ||'>');
   END IF;
   --
   x_receipt_amount := 0;
   x_refund_amount := 0;

IF  x_rec_proc_option = 'REFUND' THEN

   SELECT NVL(amount, 0), NVL(SUM(amount_applied) , 0)
   INTO   x_receipt_amount, x_refund_amount
   FROM   ar_cash_receipts cr,  ar_receivable_applications ra
   WHERE  cr.cash_receipt_id = p_cash_receipt_id
   AND    cr.cash_receipt_id = ra.cash_receipt_id(+)
   AND    ra.applied_payment_schedule_id(+)  = -6
   AND    ra.display(+)  = 'Y'
   GROUP BY  amount;

ELSIF  x_rec_proc_option = 'PAY_REFUND' THEN
   SELECT NVL(amount, 0), NVL(SUM(amount_applied) , 0)
   INTO   x_receipt_amount, x_refund_amount
   FROM   ar_cash_receipts cr,  ar_receivable_applications ra
   WHERE  cr.cash_receipt_id = p_cash_receipt_id
   AND    cr.cash_receipt_id = ra.cash_receipt_id(+)
   AND    ra.applied_payment_schedule_id(+)  = -8
   AND    ra.display(+)  = 'Y'
   GROUP BY  amount;

END IF;

   --
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('x_receipt_amount :<'
         || x_receipt_amount ||'>');
      arp_standard.debug('x_refund_amount :<'
         || x_refund_amount ||'>');
      arp_standard.debug('arp_process_RETURNS.get_receipt_amounts()- ');
   END IF;
   --

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      NULL;
   WHEN OTHERS THEN
      arp_standard.debug('EXCEPTION:arp_process_returns.get_receipt_amounts : '
      || SQLERRM(SQLCODE));
      RAISE;
END;

/*===========================================================================+
 | PORCEDURE                                                                 |
 |    check_rec_in_doubt                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function checks if given receipt is doubt                         |
 |    Given receipt can be in doubt for any of the following reasons         |
 |    . If receipt is a CC receipt and is not remitted                       |
 |    . If receipt has Special application of Claims Investigation           |
 |    . If the receipt is Debit Memo reversed                                |
 |    . If the Receipt is a Non CC receipt and is not cleared
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | ARGUMENTS  : IN  : p_cash_receipt_id                                      |
 |                                                                           |
 |            : OUT : x_rec_in_doubt (Y/N)                                   |
 |              OUT : x_rid_reason                                           |
 |                                                                           |
 | NOTES      :                                                              |
 |                                                                           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-Jun-03    Ramakant Alat   Created                                  |
 |     27-Dec-05    Gyanajyothi G   Added the check for Non CC receipt       |
 +===========================================================================*/
PROCEDURE check_rec_in_doubt(p_cash_receipt_id IN NUMBER,
                             x_rec_in_doubt OUT NOCOPY VARCHAR2,
                             x_rid_reason OUT NOCOPY VARCHAR2,
		   	     x_rec_proc_option IN VARCHAR2) IS
BEGIN
   ---
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_RETURNS.check_rec_in_doubt()+ ');
   END IF;
   ---
   x_rec_in_doubt := 'N';
   x_rid_reason   := null;
   ---
   --- For CC receipts, receipt should be remitted
   ---
  IF  x_rec_proc_option = 'REFUND' THEN
   BEGIN
      SELECT 'Y', arp_standard.fnd_message('AR_RID_NOT_REMITTED_OR_CLEARED')
      INTO   x_rec_in_doubt, x_rid_reason
      FROM   dual
      WHERE
         (
           NOT EXISTS
           (
             SELECT 1
             FROM  AR_CASH_RECEIPT_HISTORY crh
             WHERE crh.cash_receipt_id = p_cash_receipt_id
             AND   crh.status IN ('REMITTED', 'CLEARED')
           )
         );
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
      WHEN OTHERS THEN
         arp_standard.debug('Unexpected error '||sqlerrm||
            ' occurred in arp_process_returns.check_rec_in_doubt');
         RAISE;
   END;

   ---
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('After REFUND x_rec_in_doubt[x_rid_reason]: ' || x_rec_in_doubt ||
      '[' || x_rid_reason || ']');
   END IF;

  ELSIF  x_rec_proc_option = 'PAY_REFUND' THEN
   ---
   --- For Non CC Receipts , receipt should be cleared
   ---
    BEGIN
      SELECT 'Y', arp_standard.fnd_message('AR_RID_NOT_CLEARED')
      INTO   x_rec_in_doubt, x_rid_reason
      FROM   dual
      WHERE
         (
           NOT EXISTS
           (
             SELECT 1
             FROM  AR_CASH_RECEIPT_HISTORY crh
             WHERE crh.cash_receipt_id = p_cash_receipt_id
             AND   crh.status IN ('CLEARED')
           )
         );
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
      WHEN OTHERS THEN
         arp_standard.debug('Unexpected error '||sqlerrm||
            ' occurred in arp_process_returns.check_rec_in_doubt');
         RAISE;
   END;

   ---
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('After Non CC REFUND x_rec_in_doubt[x_rid_reason]: ' || x_rec_in_doubt ||
      '[' || x_rid_reason || ']');
   END IF;
  END IF;


   ---
   ---
   --- There should not be any Claims Investigation or CB special application
   ---
   BEGIN
      SELECT 'Y', arp_standard.fnd_message('AR_RID_CLAIM_OR_CB_APP_EXISTS')
      INTO   x_rec_in_doubt, x_rid_reason
      FROM   dual
      WHERE
           EXISTS
           (
             SELECT 1
             FROM   ar_receivable_applications ra
             WHERE  ra.cash_receipt_id = p_cash_receipt_id
             AND    applied_payment_schedule_id IN (-4,  -5)
             AND    display = 'Y'
           );
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
      WHEN OTHERS THEN
         arp_standard.debug('Unexpected error '||sqlerrm||
            ' occurred in arp_process_returns.check_rec_in_doubt');
         RAISE;
   END;

   ---
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('After CLAIMS x_rec_in_doubt[x_rid_reason]: ' ||
         x_rec_in_doubt || '[' || x_rid_reason || ']');
   END IF;
   ---
   ---
   --- Receipt should not be reversed
   ---
   BEGIN
      SELECT 'Y', arp_standard.fnd_message('AR_RID_RECEIPT_REVERSED')
      INTO   x_rec_in_doubt, x_rid_reason
      FROM   dual
      WHERE
           EXISTS
           (
             SELECT 1
             FROM   ar_cash_receipts cr1
             WHERE  cr1.cash_receipt_id = p_cash_receipt_id
             AND    cr1.reversal_date is not null
           );
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
      WHEN OTHERS THEN
         arp_standard.debug('Unexpected error '||sqlerrm||
            ' occurred in arp_process_returns.check_rec_in_doubt');
         RAISE;
   END;

   ---
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('After DM reverse x_rec_in_doubt[x_rid_reason]: ' ||
      x_rec_in_doubt || '[' || x_rid_reason || ']');
   END IF;
   ---
<<end_of_proc>>
   ---
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_RETURNS.check_rec_in_doubt()- ');
   END IF;
   ---
EXCEPTION
   WHEN OTHERS THEN
      arp_standard.debug('Unexpected error '||sqlerrm||
         ' occurred in arp_process_returns.check_rec_in_doubt');
      RAISE;
END check_rec_in_doubt;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_on_acct_cm_apps                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function returns the total number of on-acct cm applications      |
 |    to the given transaction                                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | ARGUMENTS  : IN:   p_customer_trx_id                                      |
 |                                                                           |
 | RETURNS    : Total number of on-account credit memo applications          |
 |                                                                           |
 | NOTES      :                                                              |
 |                                                                           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-Jun-03    Ramakant Alat   Created                                  |
 +===========================================================================*/

FUNCTION get_on_acct_cm_apps(p_customer_trx_id   IN NUMBER)
RETURN NUMBER  IS
l_count NUMBER;
BEGIN
   ---
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_RETURNS.get_on_acct_cm_apps()+ ');
      arp_standard.debug('p_customer_trx_id :<'
         || p_customer_trx_id ||'>');
   END IF;
   ---
   select count(*)
     into l_count
   from   ar_receivable_applications app,
          ra_customer_trx oncm
   where app.applied_customer_trx_id = p_customer_trx_id
     and app.status = 'APP'
     and app.application_type = 'CM'
     and app.display = 'Y'
     and app.customer_trx_id = oncm.customer_trx_id
     and oncm.previous_customer_trx_id IS NULL;
   ---
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_RETURNS.get_on_acct_cm_apps()- ');
   END IF;
   ---
   RETURN l_count;

EXCEPTION
   WHEN OTHERS THEN
   arp_standard.debug('Unexpected error '||sqlerrm||
                      ' occurred in arp_process_returns.get_on_acct_cm_apps');
   RAISE;
END get_on_acct_cm_apps;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_neg_inv_apps                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function returns the total number of negative inv applications    |
 |    across different receipts                                              |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | ARGUMENTS  : IN:   p_customer_trx_id                                      |
 |                                                                           |
 | RETURNS    : Total number of negative inv applications                    |
 |                                                                           |
 | NOTES      :                                                              |
 |                                                                           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-Oct-03    Ramakant Alat   Created                                  |
 +===========================================================================*/

FUNCTION get_neg_inv_apps(p_customer_trx_id   IN NUMBER)
RETURN NUMBER  IS
l_count NUMBER;
BEGIN
   ---
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_RETURNS.get_neg_inv_apps()+ ');
      arp_standard.debug('p_customer_trx_id :<'
         || p_customer_trx_id ||'>');
   END IF;
   ---
   select count(*)
     into l_count
   from   ar_receivable_applications app
   where app.applied_customer_trx_id = p_customer_trx_id
     and app.status = 'APP'
     and app.application_type = 'CASH'
     and app.display = 'Y'
     and app.amount_applied < 0;
   ---
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_RETURNS.get_neg_inv_apps()- ');
   END IF;
   ---
   RETURN l_count;

EXCEPTION
   WHEN OTHERS THEN
   arp_standard.debug('Unexpected error '||sqlerrm||
                      ' occurred in arp_process_returns.get_neg_inv_apps');
   RAISE;
END get_neg_inv_apps;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_llca_apps                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function checks if there exists a Line Level Cash Applications    |
 |    to the given transaction                                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | ARGUMENTS  : IN:   p_customer_trx_id                                      |
 |                                                                           |
 | RETURNS    : Total of  LLCA                                               |
 |                                                                           |
 | NOTES      :                                                              |
 |                                                                           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-Dec-05   Gyanajyothi G    Created                                  |
 +===========================================================================*/
FUNCTION get_llca_apps(p_customer_trx_id   IN NUMBER)
RETURN NUMBER  IS
l_count NUMBER;
BEGIN
   ---
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_RETURNS.get_llca_apps()+ ');
      arp_standard.debug('p_customer_trx_id :<'
         || p_customer_trx_id ||'>');
   END IF;
   ---
   select count(*)
     into l_count
   from   ar_activity_details  aad,
          ra_customer_trx_lines lines
   where
     lines.customer_trx_id =  p_customer_trx_id
     and   nvl(aad.CURRENT_ACTIVITY_FLAG,'Y') = 'Y'
     and aad.customer_trx_line_id = lines.customer_trx_line_id;

   ---
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_RETURNS.get_llca_apps()- ');
   END IF;
   ---
   RETURN l_count;

EXCEPTION
   WHEN OTHERS THEN
   arp_standard.debug('Unexpected error '||sqlerrm||
                      ' occurred in arp_process_returns.get_llca_apps');
   RAISE;
END get_llca_apps;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    populate_dff_and_gdf                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure populates the Global DFF and DFF from the old           |
 |    record                                                                 |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | ARGUMENTS  : IN  :   p_ra_rec                                             |
 |              OUT :   x_dff_rec                                            |
 |                      x_gdf_rec                                            |
 |                                                                           |
 |                                                                           |
 | NOTES      :                                                              |
 |                                                                           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-Jul-03    Ramakant Alat   Created                                  |
 +===========================================================================*/

PROCEDURE populate_dff_and_gdf(p_ra_rec  IN ar_receivable_applications%rowtype,
                               x_dff_rec OUT NOCOPY
                                  ar_receipt_api_pub.attribute_rec_type,
                               x_gdf_rec OUT NOCOPY
                                  ar_receipt_api_pub.global_attribute_rec_type)
AS
BEGIN
   ---
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_RETURNS.populate_dff_and_gdf()+ ');
   END IF;
   ---
   x_dff_rec.attribute_category:=p_ra_rec.attribute_category;
   x_dff_rec.attribute1        :=p_ra_rec.attribute1;
   x_dff_rec.attribute2        :=p_ra_rec.attribute2;
   x_dff_rec.attribute3        :=p_ra_rec.attribute3;
   x_dff_rec.attribute4        :=p_ra_rec.attribute4;
   x_dff_rec.attribute5        :=p_ra_rec.attribute5;
   x_dff_rec.attribute6        :=p_ra_rec.attribute6;
   x_dff_rec.attribute7        :=p_ra_rec.attribute7;
   x_dff_rec.attribute8        :=p_ra_rec.attribute8;
   x_dff_rec.attribute9        :=p_ra_rec.attribute9;
   x_dff_rec.attribute10       :=p_ra_rec.attribute10;
   x_dff_rec.attribute11       :=p_ra_rec.attribute11;
   x_dff_rec.attribute12       :=p_ra_rec.attribute12;
   x_dff_rec.attribute13       :=p_ra_rec.attribute13;
   x_dff_rec.attribute14       :=p_ra_rec.attribute14;
   x_dff_rec.attribute15       :=p_ra_rec.attribute15;
   ---
   ---
   x_gdf_rec.global_attribute_category :=p_ra_rec.global_attribute_category ;
   x_gdf_rec.global_attribute1         :=p_ra_rec.global_attribute1;
   x_gdf_rec.global_attribute2         :=p_ra_rec.global_attribute2;
   x_gdf_rec.global_attribute3         :=p_ra_rec.global_attribute3;
   x_gdf_rec.global_attribute4         :=p_ra_rec.global_attribute4;
   x_gdf_rec.global_attribute5         :=p_ra_rec.global_attribute5;
   x_gdf_rec.global_attribute6         :=p_ra_rec.global_attribute6;
   x_gdf_rec.global_attribute7         :=p_ra_rec.global_attribute7;
   x_gdf_rec.global_attribute8         :=p_ra_rec.global_attribute8;
   x_gdf_rec.global_attribute9         :=p_ra_rec.global_attribute9;
   x_gdf_rec.global_attribute10        :=p_ra_rec.global_attribute10;
   x_gdf_rec.global_attribute11        :=p_ra_rec.global_attribute11;
   x_gdf_rec.global_attribute12        :=p_ra_rec.global_attribute12;
   x_gdf_rec.global_attribute13        :=p_ra_rec.global_attribute13;
   x_gdf_rec.global_attribute14        :=p_ra_rec.global_attribute14;
   x_gdf_rec.global_attribute15        :=p_ra_rec.global_attribute15;
   x_gdf_rec.global_attribute16        :=p_ra_rec.global_attribute16;
   x_gdf_rec.global_attribute17        :=p_ra_rec.global_attribute17;
   x_gdf_rec.global_attribute18        :=p_ra_rec.global_attribute18;
   x_gdf_rec.global_attribute19        :=p_ra_rec.global_attribute19;
   x_gdf_rec.global_attribute20        :=p_ra_rec.global_attribute20;
   ---
   ---
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_RETURNS.populate_dff_and_gdf()- ');
   END IF;
   ---
EXCEPTION
   WHEN OTHERS THEN
   arp_standard.debug('Unexpected error '||sqlerrm||
                      ' occurred in arp_process_returns.populate_dff_and_gdf');
   RAISE;
END populate_dff_and_gdf;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_amount_applied                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function returns the amount applied by receipts for a given       |
 |    invoice for requested bucket                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | ARGUMENTS  : IN:   p_customer_trx_id                                      |
 |              IN:   p_line_type                                            |
 |                                                                           |
 | RETURNS    : amount applied for the given bucket by receipts              |
 |                                                                           |
 | NOTES      :                                                              |
 |                                                                           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     26-Jul-03    Ramakant Alat   Created                                  |
 +===========================================================================*/

FUNCTION get_amount_applied(p_customer_trx_id   IN NUMBER,
                            p_line_type IN VARCHAR2)
RETURN NUMBER  IS

l_total_amount   ar_receivable_applications.amount_applied%type:=0;
l_amt_app_rec    amt_app_type;

l_line_amount    ar_receivable_applications.amount_applied%type:=0;
l_tax_amount     ar_receivable_applications.amount_applied%type:=0;
l_frt_amount     ar_receivable_applications.amount_applied%type:=0;
l_charges_amount ar_receivable_applications.amount_applied%type:=0;
l_applied_amount ar_receivable_applications.amount_applied%type:=0;

BEGIN
   ---
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_RETURNS.get_amount_applied()+ ');
      arp_standard.debug('Customer Trx Id : ' || p_customer_trx_id);
      arp_standard.debug('p_line_type : ' || p_line_type);
   END IF;
   --
   -- Adjust amount applied iff invoice is in the list created during validation
   --
   IF inv_info.EXISTS(p_customer_trx_id) THEN
      --
      IF amt_app_tab.EXISTS(p_customer_trx_id) THEN
         --
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('Cache Hit...');
         END IF;
         --
         null;
         --
      ELSE
         --
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('Database Hit...');
         END IF;
         --
         --
         --
         SELECT
            SUM(NVL(line_applied, 0) + NVL(line_ediscounted, 0)),
            SUM(NVL(tax_applied, 0) + NVL(tax_ediscounted, 0)),
            SUM(NVL(freight_applied, 0) + NVL(freight_ediscounted, 0)),
            SUM(NVL(receivables_charges_applied, 0)
             + NVL(charges_ediscounted, 0)),
            SUM(NVL(amount_applied, 0) + NVL(earned_discount_taken, 0))
         INTO
            l_line_amount,
            l_tax_amount,
            l_frt_amount,
            l_charges_amount,
            l_applied_amount
         FROM
            ar_receivable_applications
         WHERE
            applied_customer_trx_id = p_customer_trx_id
         AND application_type = 'CASH'   -- Consider only receipt applications
         AND display = 'Y';
         --
         --
         amt_app_tab(p_customer_trx_id).line_applied := NVL(l_line_amount, 0);
         amt_app_tab(p_customer_trx_id).tax_applied := NVL(l_tax_amount, 0);
         amt_app_tab(p_customer_trx_id).freight_applied := NVL(l_frt_amount, 0);
         amt_app_tab(p_customer_trx_id).charges_applied := NVL(l_charges_amount, 0);
         amt_app_tab(p_customer_trx_id).amount_applied := NVL(l_applied_amount, 0);
         --
         --
      END IF;
      --
      IF p_line_type = 'LINE' THEN
         l_total_amount := amt_app_tab(p_customer_trx_id).line_applied;
      ELSIF p_line_type = 'TAX' THEN
         l_total_amount := amt_app_tab(p_customer_trx_id).tax_applied;
      ELSIF p_line_type = 'FREIGHT' THEN
         l_total_amount := amt_app_tab(p_customer_trx_id).freight_applied;
      ELSIF p_line_type = 'CHARGES' THEN
         l_total_amount := amt_app_tab(p_customer_trx_id).charges_applied;
      ELSE
         l_total_amount := amt_app_tab(p_customer_trx_id).amount_applied;
      END IF;
      --
   ELSE
      l_total_amount := 0;
   END IF;
   ---
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Total Amount : ' || l_total_amount);
      arp_standard.debug('arp_process_RETURNS.get_amount_applied()- ');
   END IF;
   --

   RETURN l_total_amount;

EXCEPTION
   WHEN OTHERS THEN
   arp_standard.debug('Unexpected error '||sqlerrm||
                      ' occurred in arp_process_returns.get_amount_applied');
   RAISE;
END get_amount_applied;

PROCEDURE fetch_gl_date( p_ra_rec IN ar_receivable_applications%rowtype,
                         p_gl_date OUT NOCOPY DATE) IS
  l_trx_gl_date DATE;
  l_rec_gl_date DATE;
  l_profile_appln_gl_date_def VARCHAR2(20);
  l_error_message VARCHAR2(128);
  l_defaulting_rule_used  VARCHAR2(100);
  l_default_gl_date DATE;
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_process_returns.fetch_gl_date()+ ');
   END IF;

  l_profile_appln_gl_date_def := NVL(fnd_profile.value('AR_APPLICATION_GL_DATE_DEFAULT')
                                    , 'INV_REC_DT');

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Profile Value :  '||l_profile_appln_gl_date_def);
   END IF;

  BEGIN
    SELECT  gl_date
    INTO    l_trx_gl_date
    FROM    ra_cust_trx_line_gl_dist
    WHERE   customer_trx_id = p_ra_rec.applied_customer_trx_id
    AND     account_class = 'REC'
    AND     latest_rec_flag = 'Y';
  EXCEPTION
    WHEN OTHERS THEN
    l_trx_gl_date := NULL;
  END;

  BEGIN
    SELECT  gl_date
    INTO    l_rec_gl_date
    FROM    ar_cash_receipt_history
    WHERE   cash_receipt_id = p_ra_rec.cash_receipt_id
    AND     first_posted_record_flag = 'Y';
  EXCEPTION
    WHEN OTHERS THEN
    l_rec_gl_date := NULL;
  END;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('TRX DATE Value :  '||to_char(l_trx_gl_date));
      arp_standard.debug('REC DATE Value :  '||to_char(l_rec_gl_date));
   END IF;

  IF l_profile_appln_gl_date_def = 'INV_REC_SYS_DT' THEN
    p_gl_date := GREATEST(NVL(l_trx_gl_date, trunc(SYSDATE))
                          , NVL(l_rec_gl_date, trunc(SYSDATE))
                          , trunc(sysdate));
  Else
    /* l_profile_appln_gl_date_def = 'INV_REC_DT' */
    p_gl_date := GREATEST(l_trx_gl_date, l_rec_gl_date);
  END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('GL DATE Before Defaulting Value :  '||to_char(p_gl_date));
   END IF;

  IF p_gl_date IS NOT NULL THEN
    IF ( arp_util.validate_and_default_gl_date(
          gl_date                => p_gl_date,
          trx_date               => null,
          validation_date1       => null,
          validation_date2       => null,
          validation_date3       => null,
          default_date1          => p_gl_date,
          default_date2          => null,
          default_date3          => null,
          p_allow_not_open_flag  => 'N',
          p_invoicing_rule_id    => null,
          p_set_of_books_id      => arp_global.set_of_books_id,
          p_application_id       => 222,
          default_gl_date        => l_default_gl_date ,
          defaulting_rule_used   => l_defaulting_rule_used,
          error_message          => l_error_message)= TRUE) THEN
          p_gl_date := l_default_gl_date;
    END IF;
  END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('GL DATE OUT :  '||to_char(p_gl_date));
      arp_standard.debug('arp_process_returns.fetch_gl_date()-');
   END IF;

EXCEPTION
WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Exception -- arp_process_returns');
   END IF;
    p_gl_date := NULL;

END fetch_gl_date;


BEGIN
  initialize_globals;

END arp_process_RETURNS;

/
