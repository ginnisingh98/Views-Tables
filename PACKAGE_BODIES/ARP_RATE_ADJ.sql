--------------------------------------------------------
--  DDL for Package Body ARP_RATE_ADJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_RATE_ADJ" AS
/* $Header: ARPLRADB.pls 120.25.12010000.2 2008/11/10 13:30:28 spdixit ship $ */

/* =======================================================================
 | Global Data Types
 * ======================================================================*/
SUBTYPE ae_doc_rec_type   IS arp_acct_main.ae_doc_rec_type;

--
--gscc change
    PG_DEBUG varchar2(1);

PROCEDURE main(new_crid   IN  NUMBER,
                   new_ed     IN  DATE,
                   new_er     IN  NUMBER,
                   new_ert    IN  VARCHAR2,
                   new_gd     IN  DATE,
                   new_cb     IN NUMBER,
                   new_cd     IN DATE,
                   new_lub    IN NUMBER,
                   new_lud    IN DATE,
                   new_lul    IN NUMBER,
		           touch_hist_and_dist IN BOOLEAN DEFAULT TRUE,
                   crh_id_out OUT NOCOPY ar_cash_receipt_history.cash_receipt_history_id%TYPE)
IS
        CURSOR cr_info (cr_id AR_CASH_RECEIPTS.CASH_RECEIPT_ID%TYPE) IS
        SELECT cr.cash_receipt_id            cash_receipt_id,
               cr.set_of_books_id            set_of_books_id,
               cr.currency_code              currency_code,
	       cr.receipt_method_id	     receipt_method_id,
	       sob.currency_code             functional_currency,
               cr.type                       type,
               cr.amount                     amount,
               ps.payment_schedule_id        payment_schedule_id,
               rma.unapplied_ccid            unapplied_ccid,
               rma.unidentified_ccid         unidentified_ccid,
	       cr.tax_rate		     tax_rate,
	       cr.receivables_trx_id	     receivables_trx_id
        FROM   ar_cash_receipts              cr,
               ar_payment_schedules          ps,
               ar_receipt_method_accounts    rma,
	       gl_sets_of_books              sob
        WHERE  cr.cash_receipt_id            = cr_id
        AND    ps.cash_receipt_id(+)         = cr.cash_receipt_id
        AND    rma.receipt_method_id         = cr.receipt_method_id
        AND    rma.remit_bank_acct_use_id    = cr.remit_bank_acct_use_id
        AND    cr.set_of_books_id            = sob.set_of_books_id
        FOR UPDATE OF cr.exchange_date,
                      cr.exchange_rate,
                      cr.exchange_rate_type;

        CURSOR crh_info (cr_id NUMBER) IS
        SELECT *
        FROM   AR_CASH_RECEIPT_HISTORY
        WHERE  CASH_RECEIPT_ID = cr_id
        AND    CURRENT_RECORD_FLAG = 'Y';

        CURSOR crh_prv_stat_info (cr_id NUMBER) IS
        SELECT *
        FROM   AR_CASH_RECEIPT_HISTORY
        WHERE  CASH_RECEIPT_HISTORY_ID =
               (SELECT PRV_STAT_CASH_RECEIPT_HIST_ID
                FROM AR_CASH_RECEIPT_HISTORY
                WHERE CASH_RECEIPT_ID = cr_id
                AND CURRENT_RECORD_FLAG = 'Y');

 	CURSOR dis_info (cr_id NUMBER) IS
        SELECT SUM(nvl(d.acctd_amount_dr,0)
                                - nvl(d.acctd_amount_cr,0))  sum_amount,
                d.code_combination_id,
                crh2.acctd_amount,
                crh2.acctd_factor_discount_amount,
                crh2.cash_receipt_history_id,
                d.source_type,
                d.source_table
        FROM   AR_CASH_RECEIPT_HISTORY  crh,
               AR_CASH_RECEIPT_HISTORY  crh2,
               AR_DISTRIBUTIONS  d
        WHERE  crh.cash_receipt_id = cr_id
        AND    crh2.cash_receipt_id = cr_id
        AND    d.source_id = crh.cash_receipt_history_id
        AND    crh2.current_record_flag = 'Y'
        AND    d.source_table = 'CRH'
        GROUP BY crh.cash_receipt_id,
                 d.source_type,
                 d.source_table,
                 d.code_combination_id,
                 crh2.acctd_amount,
                 crh2.acctd_factor_discount_amount,
                 crh2.cash_receipt_history_id  /* Bug 4443931: Added OR Below */
        HAVING SUM(nvl(d.acctd_amount_dr,0) - nvl(d.acctd_amount_cr,0)) <> 0
	OR (SUM(nvl(d.acctd_amount_dr,0) - nvl(d.acctd_amount_cr,0)) = 0
	AND SUM(nvl(d.amount_dr,0) - nvl(d.amount_cr,0)) <> 0 ) ;

        CURSOR misc_info (cr_id AR_MISC_CASH_DISTRIBUTIONS.CASH_RECEIPT_ID%TYPE) IS
        SELECT *
        FROM   AR_MISC_CASH_DISTRIBUTIONS
        WHERE  CASH_RECEIPT_ID = cr_id
        AND    REVERSAL_GL_DATE IS NULL;

        CURSOR rec_app_info (cr_id AR_CASH_RECEIPTS.CASH_RECEIPT_ID%TYPE) IS
        SELECT *
        FROM   AR_RECEIVABLE_APPLICATIONS
        WHERE  CASH_RECEIPT_ID = cr_id
        AND    REVERSAL_GL_DATE IS NULL
        ORDER BY decode(status,
                       'APP'        ,1,
                       'ACTIVITY'   ,2,
                       'ACC'        ,3,
                       'OTHER ACC'  ,4,
                       'UNID'       ,5,
                       'UNAPP'      ,6);  --This ordering is required for pairing UNAPP with APP, ACC or UNID rec record

        CURSOR ps_remaining_info
              (pay_id AR_PAYMENT_SCHEDULES.PAYMENT_SCHEDULE_ID%TYPE) IS
        SELECT AMOUNT_DUE_REMAINING,
               ACCTD_AMOUNT_DUE_REMAINING
        FROM   AR_PAYMENT_SCHEDULES
        WHERE  PAYMENT_SCHEDULE_ID = pay_id;

        CURSOR get_acctd_amounts
              (cr_id AR_PAYMENT_SCHEDULES.CASH_RECEIPT_ID%TYPE) IS
        SELECT ARCH.ACCTD_AMOUNT,
               ARCH.ACCTD_FACTOR_DISCOUNT_AMOUNT,
               ARPS.ACCTD_AMOUNT_DUE_REMAINING
        FROM   AR_PAYMENT_SCHEDULES    ARPS,
               AR_CASH_RECEIPT_HISTORY ARCH
        WHERE  ARPS.CASH_RECEIPT_ID = cr_id
        AND    ARCH.CASH_RECEIPT_ID = cr_id
        AND    ARCH.CURRENT_RECORD_FLAG = 'Y';

        CURSOR apps_with_claims
              (cr_id AR_PAYMENT_SCHEDULES.CASH_RECEIPT_ID%TYPE) IS
        SELECT SECONDARY_APPLICATION_REF_ID
        FROM   AR_RECEIVABLE_APPLICATIONS
        WHERE  CASH_RECEIPT_ID = cr_id
        AND    STATUS = 'APP'
        AND    APPLICATION_REF_TYPE = 'CLAIM'
        AND    NVL(TRANS_TO_RECEIPT_RATE,1) <> 1
        AND    SECONDARY_APPLICATION_REF_ID IS NOT NULL
        AND    DISPLAY = 'Y';

 /*add cursors needed for CCR logic 1st- to get the payment type code to determine if this is a CCR and
     2nd to get the receivable application id associated with the Negative Credit Card Miscellaneous receipt */

    CURSOR ar_rm_c(p_receipt_method_id number) is
	SELECT payment_channel_code
	FROM	ar_receipt_methods
	WHERE receipt_method_id = p_receipt_method_id;

    CURSOR ar_rc_rec(p_cr_id number) is
	SELECT  *
	FROM	ar_receivable_applications
	WHERE application_ref_id = p_cr_id
    and   application_ref_type = 'MISC_RECEIPT'
	and   display = 'Y';

    /* Bug 4112494 CM refunds */
    CURSOR ar_rt_c(p_receivables_trx_id NUMBER) IS
	SELECT type
	FROM   ar_receivables_trx
	WHERE  receivables_trx_id = p_receivables_trx_id;

	l_rc_app	ar_rc_rec%ROWTYPE;
	l_rm_code	ar_receipt_methods.payment_type_code%TYPE;
	l_credit_card	boolean := FALSE;
	l_rt_type	ar_receivables_trx.type%TYPE;
	l_cm_refund	BOOLEAN := FALSE;
	ln_rec_application_id	ar_receivable_applications.receivable_application_id%TYPE;
	ln_acctd_amount_applied_from	ar_receivable_applications.acctd_amount_applied_from%TYPE;
	ln_acctd_amount_applied_to	ar_receivable_applications.acctd_amount_applied_to%TYPE;
	l_bal_due_remaining	number;

    l_app_ra_rec    ar_receivable_applications%ROWTYPE;  /* MRC */

/* end of modification in the declare section for CCR - pkt */

    new_adj        NewAdjTyp;
    cr             cr_info%ROWTYPE;
    old_crh        crh_info%ROWTYPE;
    old_old_crh    crh_info%ROWTYPE;
    new_crh        crh_info%ROWTYPE;
    old_misc       misc_info%ROWTYPE;
    old_rec_app    rec_app_info%ROWTYPE;
    ps_remaining   ps_remaining_info%ROWTYPE;
    acctd          get_acctd_amounts%ROWTYPE;

    new_crh_id   AR_CASH_RECEIPT_HISTORY.CASH_RECEIPT_HISTORY_ID%TYPE;
    old_crh_id   AR_CASH_RECEIPT_HISTORY.CASH_RECEIPT_HISTORY_ID%TYPE;
    unapp_id     AR_RECEIVABLE_APPLICATIONS.RECEIVABLE_APPLICATION_ID%TYPE;

    dis                     DIS_INFO%ROWTYPE;
    acctd_curr_amount       AR_CASH_RECEIPT_HISTORY.ACCTD_AMOUNT%TYPE;
    acctd_dis_amount        AR_DISTRIBUTIONS.ACCTD_AMOUNT_DR%TYPE;
	amount_cr		NUMBER;
	amount_dr		NUMBER;
	acctd_amount_cr		NUMBER;
	acctd_amount_dr		NUMBER;

    amt_due_remaining       AR_MISC_CASH_DISTRIBUTIONS.AMOUNT%TYPE;
    acctd_amt_due_remaining AR_MISC_CASH_DISTRIBUTIONS.ACCTD_AMOUNT%TYPE;
    dist_acctd_amount       AR_MISC_CASH_DISTRIBUTIONS.ACCTD_AMOUNT%TYPE;
    new_acctd_amount        AR_MISC_CASH_DISTRIBUTIONS.ACCTD_AMOUNT%TYPE;

    app_acctd_amount     AR_PAYMENT_SCHEDULES.ACCTD_AMOUNT_DUE_REMAINING%TYPE;
    new_ps_acctd_amount  AR_PAYMENT_SCHEDULES.ACCTD_AMOUNT_DUE_REMAINING%TYPE;

    acctd_diff AR_CASH_RECEIPT_HISTORY.ACCTD_AMOUNT%TYPE;

    temp_num    NUMBER;

    total_unid       NUMBER := 0;     -- running total of 'UNID' records
    cr_acctd_amount  NUMBER;

    ins_ra_rec            AR_RECEIVABLE_APPLICATIONS%ROWTYPE;
    upd_ra_rec            AR_RECEIVABLE_APPLICATIONS%ROWTYPE;
    net_ra_rec            AR_RECEIVABLE_APPLICATIONS%ROWTYPE;

    --  Added for 11.5 VAT changes
    l_cr_rec             ar_cash_receipts%ROWTYPE;
    l_dist_rec           ar_distributions%ROWTYPE;
    l_dummy              ar_distributions.line_id%TYPE;
    l_app_id             ar_receivable_applications.receivable_application_id%TYPE;
    l_ae_doc_rec         ae_doc_rec_type;

    --  Added for iClaim API calls
    l_bill_to_site_id    hz_cust_acct_sites.cust_acct_site_id%TYPE;
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_mesg               VARCHAR2(2000); --GSCC Change
    l_claim_id                   NUMBER := NULL;
    l_claim_amount               NUMBER := NULL;
    l_claim_number               VARCHAR2(30);
    l_claim_reason_code_id       NUMBER;
    l_claim_reason_name          VARCHAR2(80);

    --Added for write-off
    l_max_wrt_off_amount ar_system_parameters.max_wrtoff_amount%TYPE;
    -- Bug 2076743
    l_claim_status       VARCHAR2(30);
	l_new_rec_app_id     NUMBER;
	l_new_net_rec_app_id NUMBER;
	l_exchange_rate      NUMBER;

	--Added for Bug No.3682777
	l_inv_gl_date_closed ar_payment_schedules.gl_date_closed%TYPE;
    l_inv_ps_status      ar_payment_schedules.status%TYPE;

    --Added for Bug No.3713101
	l_rct_gl_date_closed ar_payment_schedules.gl_date_closed%TYPE;
    l_rct_ps_status      ar_payment_schedules.status%TYPE;
    claim_cancel_api_error    EXCEPTION;
    claim_create_api_error    EXCEPTION;

    --Bug#2750340
    l_xla_ev_rec   arp_xla_events.xla_events_type;

    --BUG#5022786
    CURSOR c_trx(p_trx_id IN NUMBER) IS
    SELECT upgrade_method
      FROM ra_customer_trx
     WHERE customer_trx_id = p_trx_id;

    l_gt_id             NUMBER;
    x_return_status     VARCHAR2(10);
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(2000);
    l_upgrade_methode   VARCHAR2(30);


    --BUG#5201086
    old_crh_reverse_rec    ar_cash_receipt_history_all%ROWTYPE;
    old_reverse_crh_id     NUMBER;
    CURSOR c_distrib(p_source_id    IN NUMBER,
                     p_source_table IN VARCHAR2,
                     p_status       IN VARCHAR2)
    IS
    SELECT *
     FROM ar_distributions
    WHERE source_table = 'CRH'
      AND source_id    = p_source_id
      AND ((DECODE(p_status,'CONFIRMED',DECODE(source_type,'CONFIRMATION','Y','N'),
                           'REMITTED' ,DECODE(source_type,'REMITTANCE','Y','N'),
                           'CLEARED'  ,DECODE(source_type,'CASH','Y','N'),
                           'RISK_ELIMINATED',DECODE(source_type,'FACTOR','Y',
                                                    'SHORT_TERM_DEBT','Y','N')) = 'Y')
            OR
            (source_type = 'BANK_CHARGES'));


   l_distrib_rec       c_distrib%ROWTYPE;
   l_old_acctd_amount  NUMBER;

   CURSOR c_rate_adj
   (p_cr_id               IN NUMBER,
    p_rate_adjustment_id  IN NUMBER)
   IS
   SELECT RATE_ADJUSTMENT_ID    ,
          CASH_RECEIPT_ID       ,
          OLD_EXCHANGE_RATE     ,
          NEW_EXCHANGE_RATE     ,
          OLD_EXCHANGE_RATE_TYPE,
          NEW_EXCHANGE_RATE_TYPE,
          OLD_EXCHANGE_DATE     ,
          NEW_EXCHANGE_DATE     ,
          GAIN_LOSS             ,
          GL_DATE               ,
          GL_POSTED_DATE
     FROM ar_rate_adjustments
    WHERE cash_receipt_id    = p_cr_id
      AND rate_adjustment_id = p_rate_adjustment_id;

  l_rate_adj_rec    c_rate_adj%ROWTYPE;
  l_rate_adjustment_id    NUMBER;
  l_old_new_indicator     VARCHAR2(30);

--{HYU_Rate_Adj
   CURSOR c_trx_gt(p_customer_trx_id IN NUMBER)
   IS
   SELECT COUNT(CUSTOMER_TRX_LINE_ID),
          CUSTOMER_TRX_LINE_ID
     FROM ra_customer_trx_lines_gt
    WHERE CUSTOMER_TRX_ID = p_customer_trx_id
    GROUP BY CUSTOMER_TRX_LINE_ID;

   l_cnt_line      DBMS_SQL.NUMBER_TABLE;
   l_line_tab      DBMS_SQL.NUMBER_TABLE;
   l_reset_rem     VARCHAR2(1) := 'N';

   CURSOR c_trx_rem_gt(p_customer_trx_id IN NUMBER)
   IS
   SELECT ACCTD_AMOUNT_DUE_REMAINING ,
          AMOUNT_DUE_REMAINING       ,
          CHRG_ACCTD_AMOUNT_REMAINING,
          CHRG_AMOUNT_REMAINING      ,
          FRT_ADJ_ACCTD_REMAINING    ,
          FRT_ADJ_REMAINING          ,
          FRT_ED_ACCTD_AMOUNT        ,
          FRT_ED_AMOUNT              ,
          FRT_UNED_ACCTD_AMOUNT      ,
          FRT_UNED_AMOUNT            ,
          customer_trx_line_id
     FROM ra_customer_trx_lines
   WHERE customer_trx_id      = p_customer_trx_id;

  l_ACCTD_AMOUNT_DUE_REMAINING       DBMS_SQL.NUMBER_TABLE;
  l_AMOUNT_DUE_REMAINING             DBMS_SQL.NUMBER_TABLE;
  l_CHRG_ACCTD_AMOUNT_REMAINING      DBMS_SQL.NUMBER_TABLE;
  l_CHRG_AMOUNT_REMAINING            DBMS_SQL.NUMBER_TABLE;
  l_FRT_ADJ_ACCTD_REMAINING          DBMS_SQL.NUMBER_TABLE;
  l_FRT_ADJ_REMAINING                DBMS_SQL.NUMBER_TABLE;
  l_FRT_ED_ACCTD_AMOUNT              DBMS_SQL.NUMBER_TABLE;
  l_FRT_ED_AMOUNT                    DBMS_SQL.NUMBER_TABLE;
  l_FRT_UNED_ACCTD_AMOUNT            DBMS_SQL.NUMBER_TABLE;
  l_FRT_UNED_AMOUNT                  DBMS_SQL.NUMBER_TABLE;
  l_customer_trx_line_id             DBMS_SQL.NUMBER_TABLE;
  g_ae_sys_rec                       arp_acct_main.ae_sys_rec_type;
BEGIN
--
  IF PG_DEBUG in ('Y', 'C') THEN
  arp_standard.debug( '>> ARBRAD MAIN' );
  arp_standard.debug( 'new_crid   :'||new_crid);
  arp_standard.debug( 'new_ed     :'||new_ed);
  arp_standard.debug( 'new_er     :'||new_er);
  arp_standard.debug( 'new_ert    :'||new_ert);
  arp_standard.debug( 'new_gd     :'||new_gd);
  arp_standard.debug( 'new_cb     :'||new_cb);
  arp_standard.debug( 'new_cd     :'||new_cd);
  arp_standard.debug( 'new_lub    :'||new_lub);
  arp_standard.debug( 'new_lud    :'||new_lud);
  arp_standard.debug( 'new_lul    :'||new_lul);
--  arp_standard.debug( 'p_rate_adjustment_id :'||p_rate_adjustment_id);
  IF touch_hist_and_dist THEN
    arp_standard.debug( 'touch_hist_and_dist : TRUE');
  ELSE
    arp_standard.debug( 'touch_hist_and_dist : FALSE');
  END IF;
  END IF;

  l_mesg    := '';

  new_adj.cash_receipt_id := new_crid;
  new_adj.new_exchange_rate := new_er;
  new_adj.new_exchange_date := new_ed;
  new_adj.new_exchange_rate_type := new_ert;
  new_adj.gl_date := new_gd;
  new_adj.created_by := new_cb;
  new_adj.creation_date := new_cd;
  new_adj.last_updated_by := new_lub;
  new_adj.last_update_date := new_lud;
  new_adj.last_update_login := new_lul;

 /*-----------------------*
  | Get Cash Receipt Info |
  *-----------------------*/
  OPEN cr_info(new_adj.cash_receipt_id);
  FETCH cr_info INTO cr;
  CLOSE cr_info;


  --BUG#5201086 get_rate_adjustment info
--  IF p_rate_adjustment_id IS NOT NULL THEN
--    OPEN c_rate_adj(new_crid,p_rate_adjustment_id);
--    FETCH c_rate_adj INTO l_rate_adj_rec;
--    CLOSE c_rate_adj;
--  END IF;

 /*----------------------------------------------------------*
  | Check if receipt has claims and if they can be cancelled |
  *----------------------------------------------------------*/
  FOR clrec in apps_with_claims(new_adj.cash_receipt_id) LOOP
    -- Bug 2076743 - cater for cancelled claims
    -- Bug 2353144 - use check_cancel_deduction instead of status OPEN
    -- to determine if claim is cancellable
    IF NOT OZF_Claim_GRP.Check_Cancell_Deduction(
          p_claim_id => clrec.secondary_application_ref_id)
    THEN
       FND_MESSAGE.SET_NAME('AR', 'AR_RW_APP_NO_NEW_RATE_IF_CLAIM');
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('Receipt has uncancellable claims - ARP_RATE_ADJ.MAIN' );
       END IF;
       app_exception.raise_exception;
    END IF;
  END LOOP;

 /*-------------------------------------------*
  | Fetch current Cash receipt History Record |
  *-------------------------------------------*/

  IF ( touch_hist_and_dist ) THEN
    OPEN crh_info(new_adj.cash_receipt_id);
    FETCH crh_info INTO old_crh;
    CLOSE crh_info;
  ELSE
    OPEN crh_info(new_adj.cash_receipt_id);
    FETCH crh_info INTO new_crh;
    CLOSE crh_info;

    new_crh_id := new_crh.cash_receipt_history_id;
    crh_id_out := new_crh_id;

    OPEN crh_prv_stat_info(new_adj.cash_receipt_id);
    FETCH crh_prv_stat_info INTO old_crh;
    CLOSE crh_prv_stat_info;
  END IF;

  old_old_crh  := old_crh;
  old_crh_id   := old_crh.cash_receipt_history_id;




  /*-----------------------------------------*
   | Create New Cash Receipts History Record |
   *-----------------------------------------*/
  IF (touch_hist_and_dist ) THEN

     -- Accounted amount for the CRH record except BANK_CHARGES
     new_crh.amount      := old_crh.amount;
     l_old_acctd_amount  := old_crh.acctd_amount;


     -- Accounted amount for the CRH record for BANK_CHARGES
     new_crh.factor_discount_amount := old_crh.factor_discount_amount;
     old_crh.acctd_amount := arp_standard.functional_amount(old_crh.amount,
                                                     cr.functional_currency,
                                                     new_adj.new_exchange_rate,
                                                     NULL,
                                                     NULL);

     new_crh.acctd_amount := old_crh.acctd_amount;
     old_crh.gl_date := new_adj.gl_date;
     new_crh.gl_date := old_crh.gl_date;

    /* This is a design change:
       The new cash receipt history trx_date should remain the
       same as what it was before */
     old_crh.trx_date := old_crh.trx_date;
     new_crh.trx_date := old_crh.trx_date;

     IF (old_crh.factor_discount_amount IS NULL) THEN
         old_crh.acctd_factor_discount_amount := NULL;
         new_crh.acctd_factor_discount_amount := old_crh.acctd_factor_discount_amount;
     ELSE
         old_crh.acctd_factor_discount_amount :=
                         arp_standard.functional_amount(old_crh.amount +
                                               old_crh.factor_discount_amount,
                                               cr.functional_currency,
                                               new_adj.new_exchange_rate,
                                               NULL,
                                               NULL) - old_crh.acctd_amount;
         new_crh.acctd_factor_discount_amount := old_crh.acctd_factor_discount_amount;
     END IF;

     old_crh.first_posted_record_flag := 'N';
     old_crh.current_record_flag := 'Y';
     old_crh.exchange_date := new_adj.new_exchange_date;
     old_crh.exchange_rate := new_adj.new_exchange_rate;
     old_crh.exchange_rate_type := new_adj.new_exchange_rate_type;
     old_crh.gl_posted_date := NULL;
     old_crh.posting_control_id := -3;
     old_crh.reversal_cash_receipt_hist_id := NULL;
     old_crh.reversal_gl_date := NULL;
     old_crh.reversal_gl_posted_date := NULL;
     old_crh.reversal_posting_control_id := NULL;
     old_crh.request_id := NULL;
     old_crh.program_application_id := NULL;
     old_crh.program_id := NULL;
     old_crh.program_update_date := NULL;
     old_crh.created_by := new_adj.created_by;
     old_crh.creation_date := new_adj.creation_date;
     old_crh.last_updated_by := new_adj.last_updated_by;
     old_crh.last_update_date := new_adj.last_update_date;
     old_crh.last_update_login := new_adj.last_update_login;
     old_crh.created_from := 'RATE ADJUSTMENT TRIGGER';

     arp_standard.debug('Insert the new cash_receipt_history record');
     --HYU use the new for rate_adj
     new_crh_id := arp_cash_receipt_history.InsertRecord
                        (amount                       => old_crh.amount,
                         acctd_amount                 => old_crh.acctd_amount,
                         cash_receipt_id              => old_crh.cash_receipt_id,
                         factor_flag                  => old_crh.factor_flag,
                         first_posted_record_flag     => old_crh.first_posted_record_flag,
                         gl_date                      => old_crh.gl_date,
                         postable_flag                => old_crh.postable_flag,
                         status                       => old_crh.status,
                         trx_date                     => old_crh.trx_date,
                         acctd_factor_discount_amount => old_crh.acctd_factor_discount_amount,
                         account_code_combination_id  => old_crh.account_code_combination_id,
                         bank_charge_account_ccid     => old_crh.bank_charge_account_ccid,
                         batch_id                     => old_crh.batch_id,
                         current_record_flag          => old_crh.current_record_flag,
                         exchange_date                => old_crh.exchange_date,
                         exchange_rate                => old_crh.exchange_rate,
                         exchange_rate_type           => old_crh.exchange_rate_type,
                         factor_discount_amount       => old_crh.factor_discount_amount,
                         gl_posted_date               => old_crh.gl_posted_date,
                         posting_control_id           => old_crh.posting_control_id,
                         reversal_cash_rec_hist_id    => old_crh.reversal_cash_receipt_hist_id,
                         reversal_gl_date             => old_crh.reversal_gl_date,
                         reversal_gl_posted_date      => old_crh.reversal_gl_posted_date,
                         reversal_posting_control_id  => old_crh.reversal_posting_control_id,
                         request_id                   => old_crh.request_id,
                         program_application_id       => old_crh.program_application_id,
                         program_id                   => old_crh.program_id,
                         program_update_date          => old_crh.program_update_date,
                         created_by                   => old_crh.created_by,
                         creation_date                => old_crh.creation_date,
                         last_updated_by              => old_crh.last_updated_by,
                         last_update_date             => old_crh.last_update_date,
                         last_update_login            => old_crh.last_update_login,
                         prv_stat_cash_rec_hist_id    => old_crh.prv_stat_cash_receipt_hist_id,
                         created_from                 => old_crh.created_from,
                         reversal_created_from        => old_crh.reversal_created_from);

        crh_id_out := new_crh_id;
        arp_standard.debug('crh_id_out:'||crh_id_out);

    /*------------------------------------------------*
     | Close out NOCOPY current Cash Receipts History Record |
     *------------------------------------------------*/
     arp_standard.debug('Update the rate_adjustments info on the old cash_receipt_history record');
     --HYU rate adjustment OLD
     arp_cash_receipt_history.Reverse(new_crh_id,
                                      old_crh.gl_date,
                                      old_crh_id,
	                                  new_adj.last_updated_by,
                                      new_adj.last_update_date,
                                      new_adj.last_update_login);

     --BUG#2750340
     l_xla_ev_rec.xla_from_doc_id := old_crh.cash_receipt_id;
     l_xla_ev_rec.xla_to_doc_id   := old_crh.cash_receipt_id;
     l_xla_ev_rec.xla_doc_table   := 'CRH';
     l_xla_ev_rec.xla_mode        := 'O';
     l_xla_ev_rec.xla_call        := 'B';
     ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
  END IF;


  /*----------------------------------------------------------------*
   | Update Cash Receipts record with New exchange rate Information |
   *----------------------------------------------------------------*/
  arp_standard.debug('Update Cash Receipts record with New exchange rate Information');
  arp_cash_rec.upd_cash_receipts(new_adj.new_exchange_date,
                               new_adj.new_exchange_rate,
                               new_adj.new_exchange_rate_type,
                               new_adj.cash_receipt_id,
			       new_adj.last_updated_by,
			       new_adj.last_update_date,
			       new_adj.last_update_login);


  /*----------------------------------------------------------------*
   | Create New Distributions Records                               |
   *----------------------------------------------------------------*/
   IF (touch_hist_and_dist )  THEN

      -- Since we have the cash_receipt_id, we can get the
      -- cash receipt information.
      l_cr_rec.cash_receipt_id := new_adj.cash_receipt_id;
      arp_cash_receipts_pkg.fetch_p( l_cr_rec );


---{Start Obsolete after testing
    -- HYU in R12 we need to reverse backout the last CRH record at last stage
    -- Cases:
    -- Cash Receipt created as Confirmed
    --    CONF(CRH)     UNAPP(RA)
    --    REM(CRH1)     CONF(CRH1)
    --    CASH(CRH2)    REM(CRH2)
    -- If applications
    --    UNAPP(RA1)    APP(RA2)
    -- Here we need to backout the last CRH record at last stage
/*
      --  11.5 VAT changes:
      --  using the new_adj exchange info because this is what is
      --  is used to create new crh row.
        l_dist_rec.currency_code            := l_cr_rec.currency_code;
        l_dist_rec.currency_conversion_rate := new_adj.new_exchange_rate;
        l_dist_rec.currency_conversion_type := new_adj.new_exchange_rate_type;
        l_dist_rec.currency_conversion_date := new_adj.new_exchange_date;
        l_dist_rec.third_party_id           := l_cr_rec.pay_from_customer;
        l_dist_rec.third_party_sub_id       := l_cr_rec.customer_site_use_id;

  	OPEN dis_info(new_adj.cash_receipt_id);
	LOOP
  	FETCH dis_info INTO dis;
	EXIT WHEN dis_info%NOTFOUND OR dis_info%NOTFOUND IS NULL;


	IF dis.source_type IN ('CONFIRMATION', 'REMITTANCE', 'FACTOR',
                                     'SHORT_TERM_DEBT')   THEN
           acctd_curr_amount := nvl(dis.acctd_amount,0) +
                                nvl(dis.acctd_factor_discount_amount,0);
        END IF;
--
        IF dis.source_type = 'CASH' THEN
           acctd_curr_amount := nvl(dis.acctd_amount,0);
        END IF;
--
        IF dis.source_type = 'BANK_CHARGES' THEN
           acctd_curr_amount := nvl(dis.acctd_factor_discount_amount,0);
        END IF;
--

--	Find the absolute amount of difference between what the amount
--	should be and what is already in the database.

	acctd_dis_amount := abs(nvl(acctd_curr_amount,0)) -
                                        abs(nvl(dis.sum_amount,0));
--
--	If acctd_dis_amount is less than 0, then the amount should
--	be a debit if the original sum_amount is a credit and vice
--	versa.  If acctd_dis_amount is greater than or equal to 0,
--	then it should be on the same debit or credit side as the
--	original sum_amount.

        IF acctd_dis_amount < 0 THEN
		IF nvl(dis.sum_amount,0) < 0 THEN
     	           acctd_amount_dr := -acctd_dis_amount;
	           acctd_amount_cr := NULL;
	           amount_dr := 0;
                   amount_cr := NULL;
		ELSE
	           acctd_amount_dr := NULL;
     	           acctd_amount_cr := -acctd_dis_amount;
                   amount_dr := NULL;
	           amount_cr := 0;
		END IF;

        ELSE
		IF nvl(dis.sum_amount,0) < 0 THEN
	           acctd_amount_dr := NULL;
     	           acctd_amount_cr := acctd_dis_amount;
                   amount_dr := NULL;
	           amount_cr := 0;
		ELSE
     	           acctd_amount_dr := acctd_dis_amount;
	           acctd_amount_cr := NULL;
	           amount_dr := 0;
                   amount_cr := NULL;
		END IF;
        END IF;

--      Populate the l_dis_rec with the correct values:
        l_dist_rec.amount_dr := amount_dr;
        l_dist_rec.amount_cr := amount_cr;
        l_dist_rec.acctd_amount_dr := acctd_amount_dr;
        l_dist_rec.acctd_amount_cr := acctd_amount_cr;
        l_dist_rec.code_combination_id := dis.code_combination_id;
        l_dist_rec.source_table := dis.source_table;
        l_dist_rec.source_type := dis.source_type;
        l_dist_rec.source_id := new_crh_id;
        l_dist_rec.last_update_date := new_lud;
        l_dist_rec.last_updated_by := new_lub;
        l_dist_rec.last_update_login := new_lul;
        l_dist_rec.creation_date := new_cd;
        l_dist_rec.created_by := new_cb;
        arp_distributions_pkg.insert_p(l_dist_rec, l_dummy);
        -- store line_id in the dist record for use in mrc call
        l_dist_rec.line_id := l_dummy;
  	END LOOP;
--
	CLOSE dis_info;
*/
--} Obsoleted after testing end


--HYU distribution for the new cash receipt history record with the new exchange rate info

    arp_standard.debug('Create distributions for the new CRH reord');
    OPEN c_distrib(old_crh.cash_receipt_history_id,'CRH',old_crh.status);
    LOOP
      FETCH c_distrib INTO  l_distrib_rec;
      EXIT WHEN c_distrib%NOTFOUND;

      l_dist_rec.LINE_ID                  := l_distrib_rec.line_id;
      l_dist_rec.SOURCE_ID                := l_distrib_rec.source_id;
      l_dist_rec.SOURCE_TABLE             := l_distrib_rec.source_table;
      l_dist_rec.SOURCE_TYPE              := l_distrib_rec.source_type;
      l_dist_rec.CODE_COMBINATION_ID      := l_distrib_rec.code_combination_id;
      l_dist_rec.ORG_ID                   := l_distrib_rec.org_id;
      l_dist_rec.SOURCE_TABLE_SECONDARY   := l_distrib_rec.source_table_secondary;
      l_dist_rec.SOURCE_ID_SECONDARY      := l_distrib_rec.source_id_secondary;
      l_dist_rec.CURRENCY_CODE            := l_distrib_rec.currency_code;
      l_dist_rec.THIRD_PARTY_ID           := l_distrib_rec.third_party_id;
      l_dist_rec.THIRD_PARTY_SUB_ID       := l_distrib_rec.third_party_sub_id;
      l_dist_rec.REVERSED_SOURCE_ID       := l_distrib_rec.reversed_source_id;
      l_dist_rec.TAX_CODE_ID              := l_distrib_rec.tax_code_id;
      l_dist_rec.LOCATION_SEGMENT_ID      := l_distrib_rec.location_segment_id;
      l_dist_rec.SOURCE_TYPE_SECONDARY    := l_distrib_rec.source_type_secondary;
      l_dist_rec.TAX_GROUP_CODE_ID        := l_distrib_rec.tax_group_code_id;
      l_dist_rec.REF_CUSTOMER_TRX_LINE_ID := l_distrib_rec.ref_customer_trx_line_id;
      l_dist_rec.REF_CUST_TRX_LINE_GL_DIST_ID:= l_distrib_rec.ref_cust_trx_line_gl_dist_id;
      l_dist_rec.REF_ACCOUNT_CLASS        := l_distrib_rec.ref_account_class;
      l_dist_rec.ACTIVITY_BUCKET          := l_distrib_rec.activity_bucket;
      l_dist_rec.REF_LINE_ID              := l_distrib_rec.ref_line_id;

    IF  l_dist_rec.SOURCE_TYPE = 'BANK_CHARGES' THEN
      IF  old_crh.factor_discount_amount > 0 THEN
        l_dist_rec.amount_cr           := NULL;
        l_dist_rec.amount_dr           := old_crh.factor_discount_amount;
      ELSE
        l_dist_rec.amount_cr           := ABS(old_crh.factor_discount_amount);
        l_dist_rec.amount_dr           := NULL;
      END IF;
    ELSE
    -- Case l_dist_rec.SOURCE_TYPE IN 'CONFIRMATION',
    --                                'REMITTANCE',
    --                                'FACTOR',
    --                                'SHORT_TERM_DEBT',
    --                                'CASH'
      IF  old_crh.amount > 0 THEN
        l_dist_rec.amount_cr                := NULL;
        l_dist_rec.amount_dr                := old_crh.amount;
      ELSE
        l_dist_rec.amount_cr                := ABS(old_crh.amount);
        l_dist_rec.amount_dr                := NULL;
      END IF;
    END IF;

    IF  l_dist_rec.SOURCE_TYPE = 'BANK_CHARGES' THEN
      IF  old_crh.acctd_factor_discount_amount > 0 THEN
        l_dist_rec.acctd_amount_cr           := NULL;
        l_dist_rec.acctd_amount_dr           := old_crh.acctd_factor_discount_amount;
      ELSE
        l_dist_rec.acctd_amount_cr           := ABS(old_crh.acctd_factor_discount_amount);
        l_dist_rec.acctd_amount_dr           := NULL;
      END IF;
    ELSE
    -- Case l_dist_rec.SOURCE_TYPE IN 'CONFIRMATION',
    --                                'REMITTANCE',
    --                                'FACTOR',
    --                                'SHORT_TERM_DEBT',
    --                                'CASH'
      IF  old_crh.acctd_amount > 0 THEN
        l_dist_rec.acctd_amount_cr           := NULL;
        l_dist_rec.acctd_amount_dr           := old_crh.acctd_amount;
      ELSE
        l_dist_rec.acctd_amount_cr           := ABS(old_crh.acctd_amount);
        l_dist_rec.acctd_amount_dr           := NULL;
      END IF;
    END IF;

    l_dist_rec.currency_code            := l_cr_rec.currency_code;
    l_dist_rec.currency_conversion_rate := new_adj.new_exchange_rate;
    l_dist_rec.currency_conversion_type := new_adj.new_exchange_rate_type;
    l_dist_rec.currency_conversion_date := new_adj.new_exchange_date;
    l_dist_rec.third_party_id           := l_cr_rec.pay_from_customer;
    l_dist_rec.third_party_sub_id       := l_cr_rec.customer_site_use_id;
    l_dist_rec.source_id                := new_crh_id;
    l_dist_rec.last_update_date         := new_lud;
    l_dist_rec.last_updated_by          := new_lub;
    l_dist_rec.last_update_login        := new_lul;
    l_dist_rec.creation_date            := new_cd;
    l_dist_rec.created_by               := new_cb;

    arp_distributions_pkg.insert_p(l_dist_rec, l_dummy);

      -- store line_id in the dist record for use in mrc call
      l_dist_rec.line_id := l_dummy;
   END  LOOP;
   CLOSE c_distrib;



        /* Bug fix 3193590 */
        /* If the net receipt amount is  zero, we need to insert the
           distribution amount separately */
/*
        IF old_crh.amount = 0 AND old_crh.status <> 'APPROVED' THEN
          IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug(' Receipt Amount is zero.');
              arp_standard.debug('old_crh_id = '||to_char(old_crh_id));
              arp_standard.debug('new_crh_id = '||to_char(new_crh_id));
          END IF;
          SELECT decode( old_crh.status,
                  'CONFIRMED','CONFIRMATION',
                  'REMITTED', 'REMITTANCE',
                  'CLEARED', 'CASH' )
          INTO l_dist_rec.source_type
          FROM dual;
          l_dist_rec.amount_dr := 0;
          l_dist_rec.amount_cr := NULL;
          l_dist_rec.acctd_amount_dr := 0;
          l_dist_rec.acctd_amount_cr := NULL;
          l_dist_rec.source_table := 'CRH';
          l_dist_rec.code_combination_id := old_crh.account_code_combination_id;
          l_dist_rec.source_id := new_crh_id;
          l_dist_rec.last_update_date := new_lud;
          l_dist_rec.last_updated_by := new_lub;
          l_dist_rec.last_update_login := new_lul;
          l_dist_rec.creation_date := new_cd;
          l_dist_rec.created_by := new_cb;

          arp_distributions_pkg.insert_p(l_dist_rec, l_dummy);
          IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug('line_id = ' ||to_char(l_dummy));
          END IF;

          l_dist_rec.line_id := l_dummy;
       END IF;
*/



      arp_standard.debug('Create the CRH record for reversing the CRH before rate adjustment');

      old_crh_reverse_rec                              := old_old_crh;

      old_crh_reverse_rec.amount                       := -old_crh_reverse_rec.amount;
      old_crh_reverse_rec.factor_discount_amount       := -old_crh_reverse_rec.factor_discount_amount;
      old_crh_reverse_rec.acctd_amount                 := -old_crh_reverse_rec.acctd_amount;
      old_crh_reverse_rec.gl_date                      := new_adj.gl_date;
      old_crh_reverse_rec.acctd_factor_discount_amount := -old_crh_reverse_rec.acctd_factor_discount_amount;
      old_crh_reverse_rec.first_posted_record_flag     := 'N';
      old_crh_reverse_rec.current_record_flag          := 'N';
      old_crh_reverse_rec.gl_posted_date               := NULL;
      old_crh_reverse_rec.posting_control_id           := -3;
      old_crh_reverse_rec.reversal_cash_receipt_hist_id := NULL;
      old_crh_reverse_rec.reversal_gl_date             := NULL;
      old_crh_reverse_rec.reversal_gl_posted_date      := NULL;
      old_crh_reverse_rec.reversal_posting_control_id  := NULL;
      old_crh_reverse_rec.request_id                   := NULL;
      old_crh_reverse_rec.program_application_id       := NULL;
      old_crh_reverse_rec.program_id                   := NULL;
      old_crh_reverse_rec.program_update_date          := NULL;
      old_crh_reverse_rec.created_by                   := new_adj.created_by;
      old_crh_reverse_rec.creation_date                := new_adj.creation_date;
      old_crh_reverse_rec.last_updated_by              := new_adj.last_updated_by;
      old_crh_reverse_rec.last_update_date             := new_adj.last_update_date;
      old_crh_reverse_rec.last_update_login            := new_adj.last_update_login;
      old_crh_reverse_rec.created_from                 := 'RATE ADJUSTMENT TRIGGER';


     old_reverse_crh_id := arp_cash_receipt_history.InsertRecord
                        (amount                       => old_crh_reverse_rec.amount,
                         acctd_amount                 => old_crh_reverse_rec.acctd_amount,
                         cash_receipt_id              => old_crh_reverse_rec.cash_receipt_id,
                         factor_flag                  => old_crh_reverse_rec.factor_flag,
                         first_posted_record_flag     => old_crh_reverse_rec.first_posted_record_flag,
                         gl_date                      => old_crh_reverse_rec.gl_date,
                         postable_flag                => old_crh_reverse_rec.postable_flag,
                         status                       => old_crh_reverse_rec.status,
                         trx_date                     => old_crh_reverse_rec.trx_date,
                         acctd_factor_discount_amount => old_crh_reverse_rec.acctd_factor_discount_amount,
                         account_code_combination_id  => old_crh_reverse_rec.account_code_combination_id,
                         bank_charge_account_ccid     => old_crh_reverse_rec.bank_charge_account_ccid,
                         batch_id                     => old_crh_reverse_rec.batch_id,
                         current_record_flag          => old_crh_reverse_rec.current_record_flag,
                         exchange_date                => old_crh_reverse_rec.exchange_date,
                         exchange_rate                => old_crh_reverse_rec.exchange_rate,
                         exchange_rate_type           => old_crh_reverse_rec.exchange_rate_type,
                         factor_discount_amount       => old_crh_reverse_rec.factor_discount_amount,
                         gl_posted_date               => old_crh_reverse_rec.gl_posted_date,
                         posting_control_id           => old_crh_reverse_rec.posting_control_id,
                         reversal_cash_rec_hist_id    => old_crh_reverse_rec.reversal_cash_receipt_hist_id,
                         reversal_gl_date             => old_crh_reverse_rec.reversal_gl_date,
                         reversal_gl_posted_date      => old_crh_reverse_rec.reversal_gl_posted_date,
                         reversal_posting_control_id  => old_crh_reverse_rec.reversal_posting_control_id,
                         request_id                   => old_crh_reverse_rec.request_id,
                         program_application_id       => old_crh_reverse_rec.program_application_id,
                         program_id                   => old_crh_reverse_rec.program_id,
                         program_update_date          => old_crh_reverse_rec.program_update_date,
                         created_by                   => old_crh_reverse_rec.created_by,
                         creation_date                => old_crh_reverse_rec.creation_date,
                         last_updated_by              => old_crh_reverse_rec.last_updated_by,
                         last_update_date             => old_crh_reverse_rec.last_update_date,
                         last_update_login            => old_crh_reverse_rec.last_update_login,
                         prv_stat_cash_rec_hist_id    => old_crh_reverse_rec.prv_stat_cash_receipt_hist_id,
                         created_from                 => old_crh_reverse_rec.created_from,
                         reversal_created_from        => old_crh_reverse_rec.reversal_created_from);


    arp_standard.debug('Creating the offset distributions');
    OPEN c_distrib(old_old_crh.cash_receipt_history_id,'CRH',old_old_crh.status);
    LOOP
      FETCH c_distrib INTO  l_distrib_rec;
      EXIT WHEN c_distrib%NOTFOUND;
      l_dist_rec                          := l_distrib_rec;
      l_dist_rec.SOURCE_ID                := old_reverse_crh_id;

      l_dist_rec.amount_cr                := l_distrib_rec.amount_dr;
      l_dist_rec.amount_dr                := l_distrib_rec.amount_cr;
      l_dist_rec.acctd_amount_cr          := l_distrib_rec.acctd_amount_dr;
      l_dist_rec.acctd_amount_dr          := l_distrib_rec.acctd_amount_cr;
      l_dist_rec.last_update_date         := new_lud;
      l_dist_rec.last_updated_by          := new_lub;
      l_dist_rec.last_update_login        := new_lul;
      l_dist_rec.creation_date            := new_cd;
      l_dist_rec.created_by               := new_cb;
      arp_distributions_pkg.insert_p(l_dist_rec, l_dummy);

      l_dist_rec.line_id := l_dummy;
    END  LOOP;
    CLOSE c_distrib;


    --Bug#2750340
    l_xla_ev_rec.xla_from_doc_id := new_adj.cash_receipt_id;
    l_xla_ev_rec.xla_to_doc_id   := new_adj.cash_receipt_id;
    l_xla_ev_rec.xla_doc_table   := 'CRH';
    l_xla_ev_rec.xla_mode        := 'O';
    l_xla_ev_rec.xla_call        := 'B';
    ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
  END IF;



  IF (cr.type = 'MISC') THEN
    /*---------------------------------------------------------*
     | Create New Distributions for Miscellaneous Cash Receipt |
     *---------------------------------------------------------*/
     amt_due_remaining := new_crh.amount +
                                 NVL(new_crh.factor_discount_amount, 0);

     acctd_amt_due_remaining := new_crh.acctd_amount +
                                   NVL(new_crh.acctd_factor_discount_amount, 0);
    /*----------------------------*
     | Retrieve each distribution |
     *----------------------------*/
     FOR old_misc IN misc_info(new_adj.cash_receipt_id) LOOP
        /*-------------------------------*
         | Create reversing Distribution |
         *-------------------------------*/
       --BUG#5201086
       IF old_misc.cash_receipt_history_id IS NULL THEN
         --Use the old Cash_receipt_history_id HYUHYU
         old_misc.cash_receipt_history_id := old_reverse_crh_id;
       END IF;

       temp_num := arp_misc_cd.ins_misc_cash_distributions
                            (new_adj.last_updated_by,
                             new_adj.last_update_date,
                             new_adj.last_update_login,
                             new_adj.created_by,
                             new_adj.creation_date,
                             new_adj.cash_receipt_id,
                             old_misc.code_combination_id,
                             old_misc.set_of_books_id,
                             GREATEST(new_adj.gl_date, old_misc.gl_date),
                             old_misc.percent,
                             -1 * old_misc.amount,
                             old_misc.comments,
                             NULL,
                             old_misc.apply_date,
                             -3,
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             -1 * old_misc.acctd_amount,
                             old_misc.ussgl_transaction_code,
                             old_misc.ussgl_transaction_code_context,
                             'RATE ADJUSTMENT TRIGGER',
                             GREATEST(new_adj.gl_date, old_misc.gl_date),
                             --BUG#5201086
                             old_misc.cash_receipt_history_id);

         /* Bugfix 2753644 */
         BEGIN
		   IF l_ae_doc_rec.gl_tax_acct IS NULL AND
		      cr.tax_rate IS NOT NULL
           THEN
              SELECT code_combination_id
                INTO l_ae_doc_rec.gl_tax_acct
                FROM ar_distributions
               WHERE source_id = old_misc.misc_cash_distribution_id
                 AND source_table ='MCD'
                 AND source_type = 'TAX';
		   END IF;
         EXCEPTION
            WHEN no_data_found THEN
		         null;
            WHEN others THEN
                 raise;
         END;

         --
         --Release 11.5 VAT changes, reverse the application accounting for
         --misc cash accounting records in ar_distributions.
         --
         l_ae_doc_rec.document_type             := 'RECEIPT';
         l_ae_doc_rec.document_id               := old_misc.cash_receipt_id;
         l_ae_doc_rec.accounting_entity_level   := 'ONE';
         l_ae_doc_rec.source_table              := 'MCD';
         l_ae_doc_rec.source_id                 := temp_num;     --new record
         l_ae_doc_rec.source_id_old             := old_misc.misc_cash_distribution_id; --old record for reversal
         l_ae_doc_rec.other_flag                := 'REVERSE';
         arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

         /*----------------------------------*
          | Update the Reversed Distribution |
         *----------------------------------*/
         arp_misc_cd.upd_reversal_gl_date
                       (old_misc.misc_cash_distribution_id,
                        GREATEST(new_adj.gl_Date,old_misc.gl_date),
			       		new_adj.last_updated_by,
			       		new_adj.last_update_date,
			       		new_adj.last_update_login,
                        --BUG#5201086
                        old_misc.cash_receipt_history_id);

         /*-----------------------------*
          |  Calculate New ACCTD_AMOUNT |
          *-----------------------------*/
         amt_due_remaining := amt_due_remaining - old_misc.amount;

         new_acctd_amount := arp_standard.functional_amount(amt_due_remaining,
                                                       cr.functional_currency,
                                                       new_adj.new_exchange_rate,
                                                       NULL,
                                                       NULL);

         dist_acctd_amount := acctd_amt_due_remaining -
                                      new_acctd_amount;
         acctd_amt_due_remaining := new_acctd_amount;

         /*-----------------------------*
          | Insert the new Distribution |
          *-----------------------------*/
        temp_num := arp_misc_cd.ins_misc_cash_distributions
                        (new_adj.last_updated_by,
                         new_adj.last_update_date,
                         new_adj.last_update_login,
                         new_adj.created_by,
                         new_adj.creation_date,
                         new_adj.cash_receipt_id,
                         old_misc.code_combination_id,
                         old_misc.set_of_books_id,
                         GREATEST(new_adj.gl_date, old_misc.gl_date),
                         old_misc.percent,
                         old_misc.amount,
                         old_misc.comments,
                         NULL,
                         old_misc.apply_date,
                         -3,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         dist_acctd_amount,
                         old_misc.ussgl_transaction_code,
                         old_misc.ussgl_transaction_code_context,
                         'RATE ADJUSTMENT TRIGGER',
                         NULL,
                        --BUG#5201086
                         new_crh_id);

     END LOOP;

     --
     --Release 11.5 VAT changes, create accounting for the new MCD records
     --in the ar_distributions table.
     --
     l_ae_doc_rec.document_type             := 'RECEIPT';
     l_ae_doc_rec.document_id               := new_adj.cash_receipt_id;
     l_ae_doc_rec.accounting_entity_level   := 'ONE';
     l_ae_doc_rec.source_table              := 'MCD';
     l_ae_doc_rec.source_id                 := '';
     l_ae_doc_rec.source_id_old             := '';
     l_ae_doc_rec.other_flag                := '';
     arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

	/*CCR- Check to see if this MISC receipt is a negative credit card receipt
           -- Paula for CC Refund Rate adjustment. */

	OPEN ar_rm_c(cr.receipt_method_id);
    FETCH ar_rm_c INTO l_rm_code;
    IF l_rm_code = 'CREDIT_CARD' THEN
      l_credit_card := TRUE;
    END IF;
    CLOSE ar_rm_c;

	IF (cr.amount < 0 and l_credit_card ) THEN

      OPEN ar_rc_rec(new_adj.cash_receipt_id);
      FETCH ar_rc_rec into l_rc_app;
       /* call the receipt api to unapply the cCR on the cash receipt - pkt */
       BEGIN
	     IF PG_DEBUG in ('Y', 'C') THEN
	      arp_standard.debug('main: ' || 'new_adj gl_date ' || new_adj.gl_date);
	      arp_standard.debug('main: ' || 'old_misc gl_date ' ||old_misc.gl_date);
	      arp_standard.debug('bal due remain ' ||l_bal_due_remaining);
	     END IF;

         arp_process_application.reverse(
            l_rc_app.receivable_application_id,
            greatest(new_adj.gl_date, l_rc_app.gl_date),
            trunc(sysdate),
            'RATE ADJUSTMENT TRIGGER',
            null,
            l_bal_due_remaining,
            'RATE_ADJUST_MISC');

       EXCEPTION
         WHEN others THEN
           IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('main: ' || 'EXCEPTION in unapplying the
 CCR for the MISC recipt in ARP_RATE_ADJ.MAIN');
             arp_standard.debug('main: ' || SQLERRM(SQLCODE));
           END IF;
           raise;
           close ar_rc_rec;
       END;


       /* now that the old CCR has been unapplied; apply the new CCR with the new rate- pkt */
       BEGIN
         arp_process_application.activity_application (
             p_receipt_ps_id   => l_rc_app.payment_schedule_id,
             p_application_ps_id =>l_rc_app.applied_payment_schedule_id ,
             p_link_to_customer_trx_id => NULL,
             p_amount_applied  => l_rc_app.amount_applied,
             p_apply_date      => l_rc_app.apply_date,
             p_gl_date         =>  greatest(new_adj.gl_date, l_rc_app.gl_date),
             p_receivables_trx_id => l_rc_app.receivables_trx_id,
             p_ussgl_transaction_code => l_rc_app.ussgl_transaction_code,
             p_attribute_category => l_rc_app.attribute_category,
             p_attribute1        => l_rc_app.attribute1,
             p_attribute2        => l_rc_app.attribute2,
             p_attribute3        => l_rc_app.attribute3,
             p_attribute4        => l_rc_app.attribute4,
             p_attribute5        => l_rc_app.attribute5,
             p_attribute6        => l_rc_app.attribute6,
             p_attribute7        => l_rc_app.attribute7,
             p_attribute8        => l_rc_app.attribute8,
             p_attribute9        => l_rc_app.attribute9,
             p_attribute10       => l_rc_app.attribute10,
             p_attribute11       => l_rc_app.attribute11,
             p_attribute12       =>l_rc_app.attribute12,
             p_attribute13       => l_rc_app.attribute13,
             p_attribute14       => l_rc_app.attribute14,
             p_attribute15       => l_rc_app.attribute15,
             p_global_attribute_category  => l_rc_app.global_attribute_category,
             p_global_attribute1 => l_rc_app.global_attribute1,
             p_global_attribute2 => l_rc_app.global_attribute2,
             p_global_attribute3 => l_rc_app.global_attribute3,
             p_global_attribute4 => l_rc_app.global_attribute4,
             p_global_attribute5 => l_rc_app.global_attribute5,
             p_global_attribute6 => l_rc_app.global_attribute6,
             p_global_attribute7 => l_rc_app.global_attribute7,
             p_global_attribute8 => l_rc_app.global_attribute8,
             p_global_attribute9 => l_rc_app.global_attribute9,
             p_global_attribute10 => l_rc_app.global_attribute10,
             p_global_attribute11 => l_rc_app.global_attribute11,
             p_global_attribute12 => l_rc_app.global_attribute12,
             p_global_attribute13 => l_rc_app.global_attribute13,
             p_global_attribute14 => l_rc_app.global_attribute14,
             p_global_attribute15 => l_rc_app.global_attribute15,
             p_global_attribute16 => l_rc_app.global_attribute16,
             p_global_attribute17 => l_rc_app.global_attribute17,
             p_global_attribute18 => l_rc_app.global_attribute18,
             p_global_attribute19 => l_rc_app.global_attribute19,
             p_global_attribute20 => l_rc_app.global_attribute20,
             p_comments               => l_rc_app.comments,
             p_module_name         => 'RATE_ADJUSTMENT_MAIN',
             p_module_version      => '1.0',
             p_secondary_application_ref_id => l_rc_app.secondary_application_ref_id,
             p_application_ref_type  => l_rc_app.application_ref_type,
             p_application_ref_id  => l_rc_app.application_ref_id,
             p_application_ref_num  => l_rc_app.application_ref_num,
                                  -- *** OUT NOCOPY
             p_out_rec_application_id => ln_rec_application_id);


       EXCEPTION
          WHEN others THEN
            IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug('main: ' || 'EXCEPTION in applying the
 CCR for the MISC recipt in ARP_RATE_ADJ.MAIN');
              arp_standard.debug('main: ' || SQLERRM(SQLCODE));
            END IF;
            raise;
            close ar_rc_rec;
       END;

      CLOSE ar_rc_rec;

    END IF; -- negative credit card miscellaneous receipt pkt
        -- End of Paula's changes for CC Refund rate change.

  ELSE
     /*-----------------------------------------------------------------*
      | Update Payment Schedules Record, resetting amount_due_remaining |
      | and change exchange rate information                            |
      *-----------------------------------------------------------------*/
      cr_acctd_amount := arp_standard.functional_amount(cr.amount,
                                          cr.functional_currency,
                                          new_adj.new_exchange_rate,
                                          NULL,
                                          NULL);

      arp_pay_sched.upd_payment_schedules
                   (-cr.amount,
                    -cr_acctd_amount,
                    new_adj.new_exchange_rate,
                    new_adj.new_exchange_date,
                    new_adj.new_exchange_rate_type,
                    cr.payment_schedule_id,
		    new_adj.last_updated_by,
		    new_adj.last_update_date,
		    new_adj.last_update_login);

      /*------------------------------------------------------------*
       |                                                            |
       | Now get the amount due remaining from the payment schedule |
       |                                                            |
       *------------------------------------------------------------*/
       OPEN ps_remaining_info(cr.payment_schedule_id);
       FETCH ps_remaining_info INTO ps_remaining;
       CLOSE ps_remaining_info;

       /*------------------------------------------------------------*
        |Get the maximum write-off amount set at the system level    |
        *------------------------------------------------------------*/
        SELECT NVL(MAX_WRTOFF_AMOUNT,0)
          INTO   l_max_wrt_off_amount
          FROM   AR_SYSTEM_PARAMETERS;

        /*----------------------------------*
         |                                  |
         | For each un-reversed application |
         |                                  |
         *----------------------------------*/
         FOR old_rec_app IN rec_app_info(cr.cash_receipt_id) LOOP
            /*------------------------------*
             | Create reversing Application |
             *------------------------------*/
                -- Release 11
                -- Modified call to create new receivable application record to use the
                -- latest and greatest receivable applications table handler.
                --
                -- Firstly need to setup the record structure that is passed to the insert procedure.
                --
                ins_ra_rec.acctd_amount_applied_from := -1 * old_rec_app.acctd_amount_applied_from;
                ins_ra_rec.amount_applied :=  -1 * old_rec_app.amount_applied;
                ins_ra_rec.amount_applied_from :=  -1 * old_rec_app.amount_applied_from;
                ins_ra_rec.trans_to_receipt_rate := old_rec_app.trans_to_receipt_rate;
                ins_ra_rec.application_rule := 'RATE ADJUSTMENT TRIGGER';
                ins_ra_rec.application_type := old_rec_app.application_type;
                ins_ra_rec.apply_date := old_rec_app.apply_date;
                ins_ra_rec.code_combination_id := old_rec_app.code_combination_id;
                ins_ra_rec.created_by := new_adj.created_by;
                ins_ra_rec.creation_date := new_adj.creation_date;
                ins_ra_rec.display :=  'N';
                ins_ra_rec.gl_date := GREATEST(new_adj.gl_date, old_rec_app.gl_date);
                ins_ra_rec.last_updated_by := new_adj.last_updated_by;
                ins_ra_rec.last_update_date := new_adj.last_update_date;
                ins_ra_rec.payment_schedule_id := old_rec_app.payment_schedule_id;
                ins_ra_rec.set_of_books_id := old_rec_app.set_of_books_id;
                ins_ra_rec.status := old_rec_app.status;
                ins_ra_rec.acctd_amount_applied_to := -1 * old_rec_app.acctd_amount_applied_to;
                ins_ra_rec.acctd_earned_discount_taken := -1 * old_rec_app.acctd_earned_discount_taken;
                ins_ra_rec.acctd_unearned_discount_taken :=  -1 * old_rec_app.acctd_unearned_discount_taken;
                ins_ra_rec.applied_customer_trx_id := old_rec_app.applied_customer_trx_id;
                ins_ra_rec.applied_customer_trx_line_id := old_rec_app.applied_customer_trx_line_id;
                ins_ra_rec.applied_payment_schedule_id := old_rec_app.applied_payment_schedule_id;
                ins_ra_rec.cash_receipt_id := old_rec_app.cash_receipt_id;
                ins_ra_rec.comments := old_rec_app.comments;
                ins_ra_rec.confirmed_flag := old_rec_app.confirmed_flag;
                ins_ra_rec.customer_trx_id := old_rec_app.customer_trx_id;
                ins_ra_rec.days_late := old_rec_app.days_late;
                ins_ra_rec.earned_discount_taken := -1 * old_rec_app.earned_discount_taken;
                ins_ra_rec.freight_applied := -1 * old_rec_app.freight_applied;
                ins_ra_rec.gl_posted_date := NULL;
                ins_ra_rec.last_update_login := new_adj.last_update_login;
                ins_ra_rec.line_applied := -1 * old_rec_app.line_applied;
                ins_ra_rec.on_account_customer := old_rec_app.on_account_customer;
                ins_ra_rec.postable := old_rec_app.postable;
                ins_ra_rec.posting_control_id := -3;
                ins_ra_rec.program_application_id := NULL;
                ins_ra_rec.program_id := NULL;
                ins_ra_rec.program_update_date := NULL;
                ins_ra_rec.receivables_charges_applied := -1 * old_rec_app.receivables_charges_applied;
                ins_ra_rec.receivables_trx_id := old_rec_app.receivables_trx_id;
                ins_ra_rec.request_id := NULL;
                ins_ra_rec.tax_applied := -1 * old_rec_app.tax_applied;
                ins_ra_rec.unearned_discount_taken := -1 * old_rec_app.unearned_discount_taken;
                ins_ra_rec.unearned_discount_ccid := old_rec_app.unearned_discount_ccid;
                ins_ra_rec.earned_discount_ccid := old_rec_app.earned_discount_ccid;
                ins_ra_rec.ussgl_transaction_code := old_rec_app.ussgl_transaction_code;
                ins_ra_rec.ussgl_transaction_code_context := old_rec_app.ussgl_transaction_code_context;
                ins_ra_rec.reversal_gl_date := GREATEST(old_rec_app.gl_date, new_adj.gl_date);
                ins_ra_rec.cash_receipt_history_id := new_crh_id; /* bug 3730165 */

                -- Additional Columns for Application Rule Sets

                ins_ra_rec.LINE_EDISCOUNTED := old_rec_app.LINE_EDISCOUNTED;
                ins_ra_rec.LINE_UEDISCOUNTED := old_rec_app.LINE_UEDISCOUNTED;
                ins_ra_rec.TAX_EDISCOUNTED := old_rec_app.TAX_EDISCOUNTED;
                ins_ra_rec.TAX_UEDISCOUNTED := old_rec_app.TAX_UEDISCOUNTED;
                ins_ra_rec.FREIGHT_EDISCOUNTED := old_rec_app.FREIGHT_EDISCOUNTED;
                ins_ra_rec.FREIGHT_UEDISCOUNTED := old_rec_app.FREIGHT_UEDISCOUNTED;
                ins_ra_rec.CHARGES_EDISCOUNTED := old_rec_app.CHARGES_EDISCOUNTED;
                ins_ra_rec.CHARGES_UEDISCOUNTED := old_rec_app.CHARGES_UEDISCOUNTED;

                --Bug 2071717
                ins_ra_rec.APPLICATION_REF_TYPE := old_rec_app.APPLICATION_REF_TYPE;
                ins_ra_rec.application_ref_id   := old_rec_app.application_ref_id;
                ins_ra_rec.application_ref_num  := old_rec_app.application_ref_num;
                /* Bug 2254777 - new columns for Trade Management */
                ins_ra_rec.application_ref_reason  := old_rec_app.application_ref_reason;
                ins_ra_rec.customer_reference  := old_rec_app.customer_reference;

                 /*Bug3505753 */
                ins_ra_rec.link_to_customer_trx_id  := old_rec_app.link_to_customer_trx_id;

                /* Bug 2821139 - more new columns for Trade Mgt and netting */
                ins_ra_rec.customer_reason  := old_rec_app.customer_reason;
                ins_ra_rec.applied_rec_app_id := old_rec_app.applied_rec_app_id;
                --BUG#5201086
                ins_ra_rec.cash_receipt_history_id := old_reverse_crh_id;  --BUG#5201086

                arp_app_pkg.insert_p( ins_ra_rec, temp_num );

               --Bug#2750340
                l_xla_ev_rec.xla_from_doc_id := temp_num;
                l_xla_ev_rec.xla_to_doc_id   := temp_num;
                l_xla_ev_rec.xla_doc_table   := 'APP';
                l_xla_ev_rec.xla_mode        := 'O';
                l_xla_ev_rec.xla_call        := 'B';
                ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);

              --BUG#5022786
              IF old_rec_app.applied_customer_trx_id IS NOT NULL AND old_rec_app.status = 'APP' THEN
                OPEN c_trx(old_rec_app.applied_customer_trx_id);
                FETCH c_trx INTO l_upgrade_methode;
                IF c_trx%NOTFOUND THEN
                  l_upgrade_methode  := NULL;
                END IF;
                CLOSE c_trx;
              END IF;

              --
              -- iClaim/Deductions - update invoice related claim if exists
              --
                IF (old_rec_app.APPLICATION_REF_TYPE = 'CLAIM' AND
                    old_rec_app.STATUS = 'APP' AND
                    NVL(old_rec_app.trans_to_receipt_rate,1) <> 1 AND
                    old_rec_app.SECONDARY_APPLICATION_REF_ID IS NOT NULL)
                THEN
                  -- Bug 2076743 - cater for cancelled claims
                  -- Bug 2353144 - use check_cancel_deduction instead of status
                  -- OPEN to determine if claim is cancellable
                    IF OZF_Claim_GRP.Check_Cancell_Deduction(
                         p_claim_id => old_rec_app.secondary_application_ref_id)
                    THEN
                      l_claim_id := NULL;
                      l_claim_amount := ps_remaining.amount_due_remaining +
                           nvl(old_rec_app.amount_applied_from, old_rec_app.amount_applied);
                      arp_process_application.update_claim(
                      p_claim_id        =>  l_claim_id
                    , p_invoice_ps_id   =>  old_rec_app.applied_payment_schedule_id
                    , p_customer_trx_id =>  old_rec_app.customer_trx_id
                    , p_amount               =>  l_claim_amount
                    , p_amount_applied       =>  old_rec_app.amount_applied
                    , p_apply_date           =>  old_rec_app.apply_date
                    , p_cash_receipt_id      =>  cr.cash_receipt_id
                    , p_receipt_number       =>  NULL
                    , p_action_type          =>  'A'
                    , x_claim_reason_code_id =>  l_claim_reason_code_id
                    , x_claim_reason_name    =>  l_claim_reason_name
                    , x_claim_number    =>  l_claim_number
                    , x_return_status   =>  l_return_status
                    , x_msg_count       =>  l_msg_count
                    , x_msg_data        =>  l_msg_data);
                      IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                      THEN
                        IF l_msg_count > 1 THEN
                          fnd_msg_pub.reset;
                          -- get first message only from the stack for forms users
                          l_mesg := fnd_msg_pub.get(p_encoded=>FND_API.G_FALSE);
                        ELSE
                          l_mesg := l_msg_data;
                        END IF;

                        --Now set the message token
                        FND_MESSAGE.SET_NAME('AR', 'GENERIC_MESSAGE');
                        FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', l_mesg);

                        RAISE claim_cancel_api_error;

                      END IF;
                    END IF;
                END IF;

              --
              --Release 11.5 VAT changes, reverse the application accounting for
              --confirmed records in ar_distributions.
              --
                l_ae_doc_rec.document_type             := 'RECEIPT';
                l_ae_doc_rec.document_id               := cr.cash_receipt_id;
                l_ae_doc_rec.accounting_entity_level   := 'ONE';
                l_ae_doc_rec.source_table              := 'RA';
                l_ae_doc_rec.source_id                 := temp_num;                              --new record
                l_ae_doc_rec.source_id_old             := old_rec_app.receivable_application_id; --old record for reversal
                l_ae_doc_rec.other_flag                := 'REVERSE';

              --Commented out NOCOPY for fixing the accounting
              --Bug 1329091 - PS is updated before Accounting Engine Call
              --l_ae_doc_rec.pay_sched_upd_yn := 'Y';

              --{HYU line level Reversal
              IF old_rec_app.status = 'APP' AND  l_upgrade_methode IN ('R12','R12_11IMFAR') THEN



--Rate Adj
   OPEN c_trx_rem_gt(p_customer_trx_id => old_rec_app.applied_customer_trx_id);
   FETCH c_trx_rem_gt BULK COLLECT INTO
   l_ACCTD_AMOUNT_DUE_REMAINING ,
   l_AMOUNT_DUE_REMAINING       ,
   l_CHRG_ACCTD_AMOUNT_REMAINING,
   l_CHRG_AMOUNT_REMAINING      ,
   l_FRT_ADJ_ACCTD_REMAINING    ,
   l_FRT_ADJ_REMAINING          ,
   l_FRT_ED_ACCTD_AMOUNT        ,
   l_FRT_ED_AMOUNT              ,
   l_FRT_UNED_ACCTD_AMOUNT      ,
   l_FRT_UNED_AMOUNT            ,
   l_customer_trx_line_id;
   IF l_customer_trx_line_id.COUNT > 0 THEN
       l_reset_rem := 'Y';
   ELSE
       l_reset_rem := 'N';
   END IF;
   CLOSE c_trx_rem_gt;
   --}

                      arp_det_dist_pkg.get_gt_sequence
                      (x_gt_id         => l_gt_id,
                       x_return_status => x_return_status,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data);

                       INSERT INTO ar_line_app_detail_gt
                       ( ACCTD_AMOUNT
                        ,REF_ACCOUNT_CLASS
                        ,AMOUNT
                        ,APP_LEVEL
                        ,BASE_CURRENCY
                        ,ACTIVITY_BUCKET
                        ,CCID
                        ,GT_ID
                        ,LEDGER_ID
                        ,ORG_ID
                        ,REF_CUSTOMER_TRX_ID
                        ,REF_CUSTOMER_TRX_LINE_ID
                        ,REF_CUST_TRX_LINE_GL_DIST_ID
                        ,REF_LINE_ID
                        ,SOURCE_ID
                        ,SOURCE_TABLE
                        ,SOURCE_TYPE
                        ,TAXABLE_ACCTD_AMOUNT
                        ,TAXABLE_AMOUNT
                        ,TAX_INC_FLAG
                        ,TAX_LINK_ID
                        ,TO_CURRENCY
                        ,REF_MF_DIST_FLAG)
                       SELECT
                              DECODE(ard.activity_bucket,
                              'APP_LINE' , -(NVL(ard.acctd_amount_dr,0)-NVL(ard.acctd_amount_cr,0)),
                              'APP_TAX'  , -(NVL(ard.acctd_amount_dr,0)-NVL(ard.acctd_amount_cr,0)),
                              'APP_FRT'  , -(NVL(ard.acctd_amount_dr,0)-NVL(ard.acctd_amount_cr,0)),
                              'APP_CHRG' , -(NVL(ard.acctd_amount_dr,0)-NVL(ard.acctd_amount_cr,0)),
                              -(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)))         -- ACCTD_AMOUNT
                             ,ard.ref_account_class                                            -- REF_ACCOUNT_CLASS
                             ,DECODE(ard.activity_bucket,
                              'APP_LINE' , -(NVL(ard.amount_dr,0)-NVL(ard.amount_cr,0)),
                              'APP_TAX'  , -(NVL(ard.amount_dr,0)-NVL(ard.amount_cr,0)),
                              'APP_FRT'  , -(NVL(ard.amount_dr,0)-NVL(ard.amount_cr,0)),
                              'APP_CHRG' , -(NVL(ard.amount_dr,0)-NVL(ard.amount_cr,0)),
                              -(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)))                     -- AMOUNT
                             ,'LINE'                                                           -- APP_LEVEL
                             ,arp_global.functional_currency                                   -- BASE_CURRENCY
                             ,ard.ACTIVITY_BUCKET                                              -- ACTIVITY_BUCKET
                             ,ard.code_combination_id                                          -- CCID
                             ,l_gt_id                                                          -- GT_ID
                             ,ora.set_of_books_id                                     -- LEDGER_ID
                             ,ard.org_id                                                       -- ORG_ID
                             ,ora.applied_customer_trx_id                             -- REF_CUSTOMER_TRX_ID
                             ,ard.ref_customer_trx_line_id                                     -- REF_CUSTOMER_TRX_LINE_ID
                             ,ard.ref_cust_trx_line_gl_dist_id                                 -- REF_CUST_TRX_LINE_GL_DIST_ID
                             ,ard.ref_line_id                                                  -- REF_LINE_ID
                             ,ard.source_id                                                    -- SOURCE_ID
                             ,ard.source_table                                                 -- SOURCE_TABLE
                             ,ora.application_type                                    -- SOURCE_TYPE
                             ,''                                                               -- TAXABLE_ACCTD_AMOUNT
                             ,''                                                               -- TAXABLE_AMOUNT
                             ,''                                                               -- TAX_INC_FLAG
                             ,''                                                               -- TAX_LINK_ID
                             ,trx.invoice_currency_code                                        -- TO_CURRENCY
                             ,''                                                               -- REF_MF_DIST_FLAG
                        FROM ar_distributions            ard,
						     ar_receivable_applications  ora,
                             ra_customer_trx             trx
                       WHERE ora.receivable_application_id = old_rec_app.receivable_application_id
                         AND ard.source_table              = 'RA'
                         AND ard.source_id                 = ora.receivable_application_id
                         AND ard.activity_bucket           IS NOT NULL
                         AND ora.applied_customer_trx_id   = trx.customer_trx_id;

                      arp_acct_main.Create_Acct_Entry(
                       p_ae_doc_rec    => l_ae_doc_rec,
                       p_client_server => NULL,
                       p_from_llca_call=> 'Y',
                       p_gt_id         => l_gt_id);

                 ELSE
                     arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);
                 END IF;


             /*---------------------------------------------*
              | Update reversed record, setting DISPLAY and |
              | REVERSAL_GL_DATE                            |
              *---------------------------------------------*/
                arp_app_pkg.fetch_p( old_rec_app.receivable_application_id, upd_ra_rec );

                upd_ra_rec.display := 'N';
                upd_ra_rec.reversal_gl_date := GREATEST(old_rec_app.gl_date, new_adj.gl_date);
                upd_ra_rec.last_updated_by := new_adj.last_updated_by;
                upd_ra_rec.last_update_date := new_adj.last_update_date;
                upd_ra_rec.last_update_login := new_adj.last_update_login;

                arp_app_pkg.update_p(upd_ra_rec);

             -- keep a running total of the amount of UNID
                IF old_rec_app.status = 'UNID'  THEN
                    total_unid := total_unid + old_rec_app.amount_applied;
                ELSE
             /*---------------------------------------------------------*
              |                                                         |
              | Calculate new acctd_amount and update Payment Schedules |
              | (for Applied applications)                              |
              |                                                         |
              *---------------------------------------------------------*/
                    IF (old_rec_app.status in ('APP','ACTIVITY')) THEN
                  /*-------------------------------------------*
                   |                                           |
                   | Calculate ACCTD_AMOUNT of new application |
                   |                                           |
                   *-------------------------------------------*/
                        ps_remaining.amount_due_remaining :=
                           ps_remaining.amount_due_remaining +
                           nvl(old_rec_app.amount_applied_from, old_rec_app.amount_applied);

                        new_ps_acctd_amount := arp_standard.functional_amount
                                             (ps_remaining.amount_due_remaining,
                                              cr.functional_currency,
                                              new_adj.new_exchange_rate,
                                              NULL,
                                              NULL);

                        app_acctd_amount := new_ps_acctd_amount -
                                           ps_remaining.acctd_amount_due_remaining;

                        ps_remaining.acctd_amount_due_remaining :=
                                           new_ps_acctd_amount;


                      IF  ((old_rec_app.status = 'ACTIVITY')
                           AND (old_rec_app.applied_payment_schedule_id = -3)
                           AND (NVL(app_acctd_amount,0) > l_max_wrt_off_amount))
                      THEN
                       /*-------------------------------------------------------------*
                        |Bug 1832122 - If the new write-off accounted amount exceeds  |
                        |maximum write-off amount at system level,then we leave the   |
                        |write-off record as unapplied. In that case, we have to open the|
                        |receipt PS and ar_cash_receipts record                       |
                        *-------------------------------------------------------------*/
                        --Since in this case we are not re-creating the write-off record
                        --we should not update the amounts in PS only status needs to be
                        --opened.

                        UPDATE ar_payment_schedules
                        SET    status = 'OP',
                               gl_date_closed = ARP_GLOBAL.G_MAX_DATE,
                               actual_date_closed = ARP_GLOBAL.G_MAX_DATE
                        WHERE  payment_schedule_id = cr.payment_schedule_id;

                        l_cr_rec.cash_receipt_id    := cr.cash_receipt_id;
                        l_cr_rec.status             := 'UNAPP';

                        -- Update cash receipt status
                        arp_cash_receipts_pkg.update_p(l_cr_rec, cr.cash_receipt_id);

                       ELSE
                         /*-----------------------------------*
                          | Update Payment Schedules with new |
                          | amount due remaining              |
                          *-----------------------------------*/

                          arp_pay_sched.upd_amt_due_remaining(cr.payment_schedule_id,
                                     ps_remaining.amount_due_remaining,
                                     ps_remaining.acctd_amount_due_remaining,
 			       		             new_adj.last_updated_by,
			       		             new_adj.last_update_date,
			       		             new_adj.last_update_login);

                       END IF;
                    ELSE

                        app_acctd_amount := arp_standard.functional_amount
                                           (old_rec_app.amount_applied,
                                            cr.functional_currency,
                                            new_adj.new_exchange_rate,
                                            NULL,
                                        NULL);
                    END IF;

             /*------------------------*
              |                        |
              | Create new application |
              |                        |
              *------------------------*/
                -- Release 11
                -- Modified call to create new receivable application record to use the
                -- latest and greatest receivable applications table handler.
                --
                -- Firstly need to setup the record structure that is passed to the insert procedure.
                --
                IF old_rec_app.status IN ( 'APP', 'ACC' ,'OTHER ACC','ACTIVITY')  THEN

                     /*-----------------------------------------------------------------*
                      | Bug 1815650 - When rate adjusting write-off application,the new |
                      | accounted amount should not exceed maximum write off limit set  |
                      | at the system level.If it exceeds, do not create write-off      |
                      | ACTIVITY record or associated UNAPP record                      |
                      *-----------------------------------------------------------------*/
                      IF  ((old_rec_app.status = 'ACTIVITY')
                           AND (old_rec_app.applied_payment_schedule_id = -3)
                           AND (NVL(app_acctd_amount,0) > l_max_wrt_off_amount))
                      THEN
                         --Do not re-create the write-off record is it exceeds
                         --maximum write-off amount set.
                         NULL;
                      ELSE

                        /*Bug3505753 */
                        ins_ra_rec.link_to_customer_trx_id  := old_rec_app.link_to_customer_trx_id;
                        ins_ra_rec.acctd_amount_applied_from := app_acctd_amount;
                        ins_ra_rec.amount_applied := old_rec_app.amount_applied;
                        ins_ra_rec.amount_applied_from := old_rec_app.amount_applied_from;
                        ins_ra_rec.trans_to_receipt_rate := old_rec_app.trans_to_receipt_rate;
                        ins_ra_rec.application_rule := 'RATE ADJUSTMENT TRIGGER';
                        ins_ra_rec.application_type := old_rec_app.application_type;
                        ins_ra_rec.apply_date := old_rec_app.apply_date;
                        ins_ra_rec.code_combination_id := old_rec_app.code_combination_id;
                        ins_ra_rec.created_by := new_adj.created_by;
                        ins_ra_rec.creation_date := new_adj.creation_date;
                        ins_ra_rec.display := old_rec_app.display;
                        ins_ra_rec.gl_date := GREATEST(new_adj.gl_date, old_rec_app.gl_date);
                        ins_ra_rec.last_updated_by := new_adj.last_updated_by;
                        ins_ra_rec.last_update_date := new_adj.last_update_date;
                        ins_ra_rec.payment_schedule_id := old_rec_app.payment_schedule_id;
                        ins_ra_rec.set_of_books_id := old_rec_app.set_of_books_id;
                        ins_ra_rec.status := old_rec_app.status;

                     /* Bug 2821139 - if a payment netting then the acctd_amount_applied_to is
                        recalculated as this receipt becomes the 'main' receipt. */
                        IF old_rec_app.receivables_trx_id = -16 THEN
                           SELECT exchange_rate
                           INTO   l_exchange_rate
                           FROM   ar_payment_schedules
                           WHERE  payment_schedule_id = old_rec_app.applied_payment_schedule_id;
                           ins_ra_rec.acctd_amount_applied_to :=
                                  ARPCURR.functional_amount(
                                           amount           => old_rec_app.amount_applied
                                         , currency_code    => cr.functional_currency
                                         , exchange_rate    => l_exchange_rate
                                         , precision        => NULL
                                         , min_acc_unit     => NULL );
                        ELSE
                           ins_ra_rec.acctd_amount_applied_to := old_rec_app.acctd_amount_applied_to;
                        END IF;

                        ins_ra_rec.acctd_earned_discount_taken := old_rec_app.acctd_earned_discount_taken;
                        ins_ra_rec.acctd_unearned_discount_taken := old_rec_app.acctd_unearned_discount_taken;
                        ins_ra_rec.applied_customer_trx_id := old_rec_app.applied_customer_trx_id;
                        ins_ra_rec.applied_customer_trx_line_id := old_rec_app.applied_customer_trx_line_id;
                        ins_ra_rec.applied_payment_schedule_id := old_rec_app.applied_payment_schedule_id;
                        ins_ra_rec.cash_receipt_id := old_rec_app.cash_receipt_id;
                        ins_ra_rec.comments := old_rec_app.comments;
                        ins_ra_rec.confirmed_flag := old_rec_app.confirmed_flag;
                        ins_ra_rec.customer_trx_id := old_rec_app.customer_trx_id;
                        ins_ra_rec.days_late := old_rec_app.days_late;
                        ins_ra_rec.earned_discount_taken := old_rec_app.earned_discount_taken;
                        ins_ra_rec.freight_applied := old_rec_app.freight_applied;
                        ins_ra_rec.gl_posted_date := NULL;
                        ins_ra_rec.last_update_login := new_adj.last_update_login;
                        ins_ra_rec.line_applied := old_rec_app.line_applied;
                        ins_ra_rec.on_account_customer := old_rec_app.on_account_customer;
                        ins_ra_rec.postable := old_rec_app.postable;
                        ins_ra_rec.posting_control_id := -3;
                        ins_ra_rec.program_application_id := NULL;
                        ins_ra_rec.program_id := NULL;
                        ins_ra_rec.program_update_date := NULL;
                        ins_ra_rec.receivables_charges_applied := old_rec_app.receivables_charges_applied;
                        ins_ra_rec.receivables_trx_id := old_rec_app.receivables_trx_id;
                        ins_ra_rec.request_id := NULL;
                        ins_ra_rec.tax_applied := old_rec_app.tax_applied;
                        ins_ra_rec.unearned_discount_taken := old_rec_app.unearned_discount_taken;
                        ins_ra_rec.unearned_discount_ccid := old_rec_app.unearned_discount_ccid;
                        ins_ra_rec.earned_discount_ccid := old_rec_app.earned_discount_ccid;
                        ins_ra_rec.ussgl_transaction_code := old_rec_app.ussgl_transaction_code;
                        ins_ra_rec.ussgl_transaction_code_context := old_rec_app.ussgl_transaction_code_context;
                        ins_ra_rec.reversal_gl_date := NULL;
                        ins_ra_rec.cash_receipt_history_id := new_crh_id;

                        -- Additional Columns for Application Rule Sets
                        ins_ra_rec.LINE_EDISCOUNTED := old_rec_app.LINE_EDISCOUNTED;
                        ins_ra_rec.LINE_UEDISCOUNTED := old_rec_app.LINE_UEDISCOUNTED;
                        ins_ra_rec.TAX_EDISCOUNTED := old_rec_app.TAX_EDISCOUNTED;
                        ins_ra_rec.TAX_UEDISCOUNTED := old_rec_app.TAX_UEDISCOUNTED;
                        ins_ra_rec.FREIGHT_EDISCOUNTED := old_rec_app.FREIGHT_EDISCOUNTED;
                        ins_ra_rec.FREIGHT_UEDISCOUNTED := old_rec_app.FREIGHT_UEDISCOUNTED;
                        ins_ra_rec.CHARGES_EDISCOUNTED := old_rec_app.CHARGES_EDISCOUNTED;
                        ins_ra_rec.CHARGES_UEDISCOUNTED := old_rec_app.CHARGES_UEDISCOUNTED;

                       --
                       -- Additional application reference columns
                       --
                        ins_ra_rec.APPLICATION_REF_TYPE := old_rec_app.APPLICATION_REF_TYPE;

                      --S.Nambiar added payment_set_id for prepayment application.
                        ins_ra_rec.payment_set_id       := old_rec_app.payment_set_id;
                       --
                       -- If non invoice related claim  call API to create
                       -- a new claim
                       --
                       ins_ra_rec.application_ref_id := old_rec_app.application_ref_id;
                       ins_ra_rec.application_ref_num := old_rec_app.application_ref_num;
                       ins_ra_rec.secondary_application_ref_id := old_rec_app.secondary_application_ref_id;
                       /* Bug 2821139 - more new columns for Trade Mgt and netting */
                       ins_ra_rec.application_ref_reason  := old_rec_app.application_ref_reason;
                       ins_ra_rec.customer_reference  := old_rec_app.customer_reference;
                       ins_ra_rec.customer_reason  := old_rec_app.customer_reason;
                       ins_ra_rec.applied_rec_app_id := old_rec_app.applied_rec_app_id;

		       temp_num := NULL;  --bug6271951
                       arp_app_pkg.insert_p( ins_ra_rec, temp_num );

                       --Bug2750340
                       l_xla_ev_rec.xla_from_doc_id := temp_num;
                       l_xla_ev_rec.xla_to_doc_id   := temp_num;
                       l_xla_ev_rec.xla_doc_table   := 'APP';
                       l_xla_ev_rec.xla_mode        := 'O';
                       l_xla_ev_rec.xla_call        := 'B';
                       ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);

/* Bug No. 3682777 JVARKEY
Update the gl_date_closed of concerned invoice in the payment schedules if the status is closed and
the current gl_date closed is less than gl_date of the reate adjustment */

                      SELECT gl_date_closed,status
                      INTO   l_inv_gl_date_closed,l_inv_ps_status
                      FROM   ar_payment_schedules
                      WHERE  payment_schedule_id=ins_ra_rec.applied_payment_schedule_id;

                      IF     ((l_inv_gl_date_closed<ins_ra_rec.gl_date)
                           AND l_inv_ps_status='CL')
                      THEN
                          UPDATE ar_payment_schedules
                          SET    gl_date_closed=ins_ra_rec.gl_date
                          WHERE payment_schedule_id=ins_ra_rec.applied_payment_schedule_id;
                      END IF;


                        -- save the app_rec info for mrc use
                         l_app_ra_rec := ins_ra_rec;
                         l_app_ra_rec.receivable_application_id := temp_num;
                        -- Store the rec app id for Netting
                         l_new_rec_app_id := temp_num;
                       --
                       --Release 11.5 VAT changes, create the APP record for the new rate
                       --adjustment
                       --
                       l_ae_doc_rec.document_type             := 'RECEIPT';
                       l_ae_doc_rec.document_id               := cr.cash_receipt_id;
                       l_ae_doc_rec.accounting_entity_level   := 'ONE';
                       l_ae_doc_rec.source_table              := 'RA';
                       l_ae_doc_rec.source_id                 := temp_num;         --new APP record
                       l_ae_doc_rec.source_id_old             := '';
                       l_ae_doc_rec.other_flag                := '';

                     --Bug 1329091 - PS is updated before Accounting Engine Call
                       l_ae_doc_rec.pay_sched_upd_yn := 'Y';


                       l_app_id := temp_num;
                 --
                 -- Create the complementary UNAPP record
                 --
                        ins_ra_rec.acctd_amount_applied_from := -app_acctd_amount;
                        ins_ra_rec.amount_applied := nvl(-old_rec_app.amount_applied_from, -old_rec_app.amount_applied);
                        ins_ra_rec.amount_applied_from := -old_rec_app.amount_applied_from;
                        ins_ra_rec.trans_to_receipt_rate := NULL;
                        ins_ra_rec.application_rule := 'RATE ADJUSTMENT TRIGGER';
                        ins_ra_rec.application_type := old_rec_app.application_type;
                        ins_ra_rec.apply_date := old_rec_app.apply_date;
                        ins_ra_rec.code_combination_id := cr.unapplied_ccid;
                        ins_ra_rec.created_by := new_adj.created_by;
                        ins_ra_rec.creation_date := new_adj.creation_date;
                        ins_ra_rec.display := 'N';
                        ins_ra_rec.gl_date := GREATEST(new_adj.gl_date, old_rec_app.gl_date);
                        ins_ra_rec.last_updated_by := new_adj.last_updated_by;
                        ins_ra_rec.last_update_date := new_adj.last_update_date;
                        ins_ra_rec.payment_schedule_id := old_rec_app.payment_schedule_id;
                        ins_ra_rec.set_of_books_id := old_rec_app.set_of_books_id;
                        ins_ra_rec.status := 'UNAPP';
                        ins_ra_rec.acctd_amount_applied_to := NULL;
                        ins_ra_rec.acctd_earned_discount_taken := NULL;
                        ins_ra_rec.acctd_unearned_discount_taken := NULL;
                        ins_ra_rec.applied_customer_trx_id := NULL;
                        ins_ra_rec.applied_customer_trx_line_id := NULL;
                        ins_ra_rec.applied_payment_schedule_id := NULL;
                        ins_ra_rec.cash_receipt_id := old_rec_app.cash_receipt_id;
                        ins_ra_rec.comments := old_rec_app.comments;
                        ins_ra_rec.confirmed_flag := old_rec_app.confirmed_flag;
                        ins_ra_rec.customer_trx_id := NULL;
                        ins_ra_rec.days_late := NULL;
                        ins_ra_rec.earned_discount_taken := NULL;
                        ins_ra_rec.freight_applied := NULL;
                        ins_ra_rec.gl_posted_date := NULL;
                        ins_ra_rec.last_update_login := new_adj.last_update_login;
                        ins_ra_rec.line_applied := NULL;
                        ins_ra_rec.on_account_customer := old_rec_app.on_account_customer;
                        ins_ra_rec.postable := old_rec_app.postable;
                        ins_ra_rec.posting_control_id :=  -3;
                        ins_ra_rec.program_application_id := NULL;
                        ins_ra_rec.receivables_charges_applied := NULL;
                        ins_ra_rec.program_id := NULL;
                        ins_ra_rec.program_update_date := NULL;
                        ins_ra_rec.receivables_trx_id := old_rec_app.receivables_trx_id;
                        ins_ra_rec.request_id := NULL;
                        ins_ra_rec.tax_applied := NULL;
                        ins_ra_rec.unearned_discount_taken := NULL;
                        ins_ra_rec.unearned_discount_ccid := NULL;
                        ins_ra_rec.earned_discount_ccid := NULL;
                        ins_ra_rec.ussgl_transaction_code := old_rec_app.ussgl_transaction_code;
                        ins_ra_rec.ussgl_transaction_code_context := old_rec_app.ussgl_transaction_code_context;
                        ins_ra_rec.reversal_gl_date := NULL;
                        ins_ra_rec.cash_receipt_history_id := new_crh_id;
                        ins_ra_rec.application_ref_type := NULL;
                        ins_ra_rec.application_ref_id := NULL;
                        ins_ra_rec.application_ref_num := NULL;
                        ins_ra_rec.secondary_application_ref_id := NULL;
                        /* Bug 2254777  reason and cust reference */
                        ins_ra_rec.application_ref_reason := NULL;
                        ins_ra_rec.customer_reference := NULL;
                        ins_ra_rec.payment_set_id := NULL;
                        /*Bug3505753 */
                        ins_ra_rec.link_to_customer_trx_id:=NULL;

		       temp_num := NULL;  --bug6271951
                       arp_app_pkg.insert_p( ins_ra_rec, temp_num );

                      --Bug#2750340
                      l_xla_ev_rec.xla_from_doc_id := temp_num;
                      l_xla_ev_rec.xla_to_doc_id   := temp_num;
                      l_xla_ev_rec.xla_doc_table   := 'APP';
                      l_xla_ev_rec.xla_mode        := 'O';
                      l_xla_ev_rec.xla_call        := 'B';
                      ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);


                  --{BUG#5022786 Call  the creation of APP distribution in LLCA mode if required
                  IF old_rec_app.status = 'APP' AND     l_upgrade_methode IN ('R12','R12_11IMFAR') THEN

                      arp_det_dist_pkg.get_gt_sequence
                      (x_gt_id         => l_gt_id,
                       x_return_status => x_return_status,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data);

                       INSERT INTO ar_line_app_detail_gt
                       ( ACCTD_AMOUNT
                        ,REF_ACCOUNT_CLASS
                        ,AMOUNT
                        ,APP_LEVEL
                        ,BASE_CURRENCY
                        ,ACTIVITY_BUCKET
                        ,CCID
                        ,GT_ID
                        ,LEDGER_ID
                        ,ORG_ID
                        ,REF_CUSTOMER_TRX_ID
                        ,REF_CUSTOMER_TRX_LINE_ID
                        ,REF_CUST_TRX_LINE_GL_DIST_ID
                        ,REF_LINE_ID
                        ,SOURCE_ID
                        ,SOURCE_TABLE
                        ,SOURCE_TYPE
                        ,TAXABLE_ACCTD_AMOUNT
                        ,TAXABLE_AMOUNT
                        ,TAX_INC_FLAG
                        ,TAX_LINK_ID
                        ,TO_CURRENCY
                        ,REF_MF_DIST_FLAG)
                       SELECT
                              DECODE(ard.activity_bucket,
                              'APP_LINE' , (NVL(ard.acctd_amount_dr,0)-NVL(ard.acctd_amount_cr,0)),
                              'APP_TAX'  , (NVL(ard.acctd_amount_dr,0)-NVL(ard.acctd_amount_cr,0)),
                              'APP_FRT'  , (NVL(ard.acctd_amount_dr,0)-NVL(ard.acctd_amount_cr,0)),
                              'APP_CHRG' , (NVL(ard.acctd_amount_dr,0)-NVL(ard.acctd_amount_cr,0)),
                              (NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)))         -- ACCTD_AMOUNT
                             ,ard.ref_account_class                                            -- REF_ACCOUNT_CLASS
                             ,DECODE(ard.activity_bucket,
                              'APP_LINE' , (NVL(ard.amount_dr,0)-NVL(ard.amount_cr,0)),
                              'APP_TAX'  , (NVL(ard.amount_dr,0)-NVL(ard.amount_cr,0)),
                              'APP_FRT'  , (NVL(ard.amount_dr,0)-NVL(ard.amount_cr,0)),
                              'APP_CHRG' , (NVL(ard.amount_dr,0)-NVL(ard.amount_cr,0)),
                              (NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)))                     -- AMOUNT
                             ,'LINE'                                                           -- APP_LEVEL
                             ,arp_global.functional_currency                                   -- BASE_CURRENCY
                             ,ard.ACTIVITY_BUCKET                                              -- ACTIVITY_BUCKET
                             ,ard.code_combination_id                                          -- CCID
                             ,l_gt_id                                                          -- GT_ID
                             ,ora.set_of_books_id                                     -- LEDGER_ID
                             ,ard.org_id                                                       -- ORG_ID
                             ,ora.applied_customer_trx_id                             -- REF_CUSTOMER_TRX_ID
                             ,ard.ref_customer_trx_line_id                                     -- REF_CUSTOMER_TRX_LINE_ID
                             ,ard.ref_cust_trx_line_gl_dist_id                                 -- REF_CUST_TRX_LINE_GL_DIST_ID
                             ,ard.ref_line_id                                                  -- REF_LINE_ID
                             ,ard.source_id                                                    -- SOURCE_ID
                             ,ard.source_table                                                 -- SOURCE_TABLE
                             ,ora.application_type                                    -- SOURCE_TYPE
                             ,''                                                               -- TAXABLE_ACCTD_AMOUNT
                             ,''                                                               -- TAXABLE_AMOUNT
                             ,''                                                               -- TAX_INC_FLAG
                             ,''                                                               -- TAX_LINK_ID
                             ,trx.invoice_currency_code                                        -- TO_CURRENCY
                             ,''                                                               -- REF_MF_DIST_FLAG
                        FROM ar_distributions            ard,
						     ar_receivable_applications  ora,
                             ra_customer_trx             trx
                       WHERE ora.receivable_application_id = old_rec_app.receivable_application_id
                         AND ard.source_table              = 'RA'
                         AND ard.source_id                 = ora.receivable_application_id
                         AND ard.activity_bucket           IS NOT NULL
                         AND ora.applied_customer_trx_id   = trx.customer_trx_id;

                      arp_acct_main.Create_Acct_Entry(
                       p_ae_doc_rec    => l_ae_doc_rec,
                       p_client_server => NULL,
                       p_from_llca_call=> 'Y',
                       p_gt_id         => l_gt_id);


                    IF l_reset_rem = 'Y' THEN
                      FORALL i IN l_customer_trx_line_id.FIRST ..l_customer_trx_line_id.LAST
                      UPDATE ra_customer_trx_lines  SET
                      ACCTD_AMOUNT_DUE_REMAINING = l_ACCTD_AMOUNT_DUE_REMAINING(i),
                      AMOUNT_DUE_REMAINING       = l_AMOUNT_DUE_REMAINING(i),
                      CHRG_ACCTD_AMOUNT_REMAINING= l_CHRG_ACCTD_AMOUNT_REMAINING(i),
                      CHRG_AMOUNT_REMAINING      = l_CHRG_AMOUNT_REMAINING(i),
                      FRT_ADJ_ACCTD_REMAINING    = l_FRT_ADJ_ACCTD_REMAINING(i),
                      FRT_ADJ_REMAINING          = l_FRT_ADJ_REMAINING(i),
                      FRT_ED_ACCTD_AMOUNT        = l_FRT_ED_ACCTD_AMOUNT(i),
                      FRT_ED_AMOUNT              = l_FRT_ED_AMOUNT(i),
                      FRT_UNED_ACCTD_AMOUNT      = l_FRT_UNED_ACCTD_AMOUNT(i),
                      FRT_UNED_AMOUNT            = l_FRT_UNED_AMOUNT(i)
                      WHERE customer_trx_line_id      = l_customer_trx_line_id(i);

                      l_reset_rem := 'N';


                    END IF;
                    --}

                  ELSE
                   --Call the creation of distributions in normal case
                         arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);
                  END IF;
                  --}

                  --
                  --Release 11.5 VAT changes, create the
                  --complementary UNAPP record
                  --accounting.
                  --
                  l_ae_doc_rec.document_type             := 'RECEIPT';
                  l_ae_doc_rec.document_id               := cr.cash_receipt_id;
                  l_ae_doc_rec.accounting_entity_level   := 'ONE';
                  l_ae_doc_rec.source_table              := 'RA';
                  l_ae_doc_rec.source_id                 := temp_num;         --new UNAPP record
                  l_ae_doc_rec.source_id_old             := l_app_id;         --paired APP record
                  l_ae_doc_rec.other_flag                := 'PAIR';
                  arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

                END IF; --end if for maximum write-off amount check

               /* Bug 2821139 - if a netting application the opposing
                 application on the netted receipt is reversed/reapplied */
                IF old_rec_app.receivables_trx_id = -16 THEN

                        arp_app_pkg.fetch_p (old_rec_app.applied_rec_app_id
                                            , net_ra_rec);



                        arp_process_application.reverse(
                                 p_ra_id             => old_rec_app.applied_rec_app_id
                               , p_reversal_gl_date  => GREATEST(old_rec_app.gl_date, new_adj.gl_date)
                               , p_reversal_date     => TRUNC(SYSDATE)
                               , p_module_name       => 'ARPLRADB'
                               , p_module_version    => '1.0'
                               , p_bal_due_remaining => l_bal_due_remaining
                               , p_called_from       => 'ARPLRADB');

                        arp_process_application.activity_application (
                             p_receipt_ps_id => net_ra_rec.payment_schedule_id,
                             p_application_ps_id => net_ra_rec.applied_payment_schedule_id,
                             p_link_to_customer_trx_id => net_ra_rec.link_to_customer_trx_id,
                             p_amount_applied  => net_ra_rec.amount_applied,
                             p_apply_date      => net_ra_rec.apply_date,
                             p_gl_date  => GREATEST(old_rec_app.gl_date, new_adj.gl_date),
                             p_receivables_trx_id => net_ra_rec.receivables_trx_id,
                             p_ussgl_transaction_code => net_ra_rec.ussgl_transaction_code,
                             p_attribute_category=> net_ra_rec.attribute_category,
                             p_attribute1        => net_ra_rec.attribute1,
                             p_attribute2        => net_ra_rec.attribute2,
                             p_attribute3        => net_ra_rec.attribute3,
                             p_attribute4        => net_ra_rec.attribute4,
                             p_attribute5        => net_ra_rec.attribute5,
                             p_attribute6        => net_ra_rec.attribute6,
                             p_attribute7        => net_ra_rec.attribute7,
                             p_attribute8        => net_ra_rec.attribute8,
                             p_attribute9        => net_ra_rec.attribute9,
                             p_attribute10       => net_ra_rec.attribute10,
                             p_attribute11       => net_ra_rec.attribute11,
                             p_attribute12       => net_ra_rec.attribute12,
                             p_attribute13       => net_ra_rec.attribute13,
                             p_attribute14       => net_ra_rec.attribute14,
                             p_attribute15       => net_ra_rec.attribute15,
                             p_global_attribute1 => net_ra_rec.global_attribute1,
                             p_global_attribute2 => net_ra_rec.global_attribute2,
                             p_global_attribute3 => net_ra_rec.global_attribute3,
                             p_global_attribute4 => net_ra_rec.global_attribute4,
                             p_global_attribute5 => net_ra_rec.global_attribute5,
                             p_global_attribute6 => net_ra_rec.global_attribute6,
                             p_global_attribute7 => net_ra_rec.global_attribute7,
                             p_global_attribute8 => net_ra_rec.global_attribute8,
                             p_global_attribute9 => net_ra_rec.global_attribute9,
                             p_global_attribute10 => net_ra_rec.global_attribute10,
                             p_global_attribute11 => net_ra_rec.global_attribute11,
                             p_global_attribute12 => net_ra_rec.global_attribute12,
                             p_global_attribute13 => net_ra_rec.global_attribute13,
                             p_global_attribute14 => net_ra_rec.global_attribute14,
                             p_global_attribute15 => net_ra_rec.global_attribute15,
                             p_global_attribute16 => net_ra_rec.global_attribute16,
                             p_global_attribute17 => net_ra_rec.global_attribute17,
                             p_global_attribute18 => net_ra_rec.global_attribute18,
                             p_global_attribute19 => net_ra_rec.global_attribute19,
                             p_global_attribute20 => net_ra_rec.global_attribute20,
                             p_global_attribute_category => net_ra_rec.global_attribute_category,
                             p_module_name         => 'ARPLRADB',
                             p_comments         => net_ra_rec.comments,
                             p_application_ref_type => net_ra_rec.application_ref_type,
                             p_application_ref_id   => net_ra_rec.application_ref_id,
                             p_application_ref_num  => net_ra_rec.application_ref_num,
                             p_secondary_application_ref_id   => net_ra_rec.secondary_application_ref_id,
                             p_payment_set_id   => net_ra_rec.payment_set_id,
                             p_module_version      => '1.0',
                             p_out_rec_application_id => l_new_net_rec_app_id,
                             p_customer_reference => net_ra_rec.customer_reference,
			     p_netted_receipt_flag => 'Y',
			     p_netted_cash_receipt_id => net_ra_rec.cash_receipt_id
                             );

			-- Updating both new activity records with each others
			-- new rec app id
                        arp_app_pkg.fetch_p(l_new_rec_app_id, net_ra_rec );
                        net_ra_rec.applied_rec_app_id := l_new_net_rec_app_id;
                        arp_app_pkg.update_p( net_ra_rec );

                        arp_app_pkg.fetch_p (l_new_net_rec_app_id, net_ra_rec);
                        net_ra_rec.applied_rec_app_id := l_new_rec_app_id;
                        arp_app_pkg.update_p( net_ra_rec );

                      END IF;

                  END IF; -- end if status
                END IF; --end if for unid

		temp_num := NULL;  --bug6271951
            END LOOP;


            IF total_unid = 0  THEN

                     -- create an 'UNAPP' record for the value of the cr
                     ins_ra_rec.acctd_amount_applied_from := cr_acctd_amount;
                     ins_ra_rec.amount_applied := cr.amount;
                     ins_ra_rec.amount_applied_from := NULL;
                     ins_ra_rec.trans_to_receipt_rate := NULL;
                     ins_ra_rec.application_rule := 'RATE ADJUSTMENT TRIGGER';
                     ins_ra_rec.application_type := 'CASH';
                     ins_ra_rec.apply_date := new_crh.trx_date;
                     ins_ra_rec.code_combination_id := cr.unapplied_ccid;
                     ins_ra_rec.created_by := new_adj.created_by;
                     ins_ra_rec.creation_date := new_adj.creation_date;
                     ins_ra_rec.display := 'N';
                     ins_ra_rec.gl_date := new_crh.gl_date;
                     ins_ra_rec.last_updated_by := new_adj.last_updated_by;
                     ins_ra_rec.last_update_date := new_adj.last_update_date;
                     ins_ra_rec.payment_schedule_id := cr.payment_schedule_id;
                     ins_ra_rec.set_of_books_id := cr.set_of_books_id;
                     ins_ra_rec.status := 'UNAPP';
                     ins_ra_rec.acctd_amount_applied_to := NULL;
                     ins_ra_rec.acctd_earned_discount_taken := NULL;
                     ins_ra_rec.acctd_unearned_discount_taken := NULL;
                     ins_ra_rec.applied_customer_trx_id := NULL;
                     ins_ra_rec.applied_customer_trx_line_id := NULL;
                     ins_ra_rec.applied_payment_schedule_id := NULL;
                     ins_ra_rec.cash_receipt_id := cr.cash_receipt_id;
                     ins_ra_rec.comments := NULL;
                     ins_ra_rec.confirmed_flag := 'Y';
                     ins_ra_rec.customer_trx_id := NULL;
                     ins_ra_rec.days_late := NULL;
                     ins_ra_rec.earned_discount_taken := NULL;
                     ins_ra_rec.freight_applied := NULL;
                     ins_ra_rec.gl_posted_date := NULL;
                     ins_ra_rec.last_update_login := new_adj.last_update_login;
                     ins_ra_rec.line_applied := NULL;
                     ins_ra_rec.on_account_customer := NULL;
                     ins_ra_rec.postable := NULL;
                     ins_ra_rec.posting_control_id := -3;
                     ins_ra_rec.program_application_id := NULL;
                     ins_ra_rec.program_id := NULL;
                     ins_ra_rec.program_update_date := NULL;
                     ins_ra_rec.receivables_charges_applied := NULL;
                     ins_ra_rec.receivables_trx_id := NULL;
                     ins_ra_rec.request_id := NULL;
                     ins_ra_rec.tax_applied := NULL;
                     ins_ra_rec.unearned_discount_taken := NULL;
                     ins_ra_rec.unearned_discount_ccid := NULL;
                     ins_ra_rec.earned_discount_ccid := NULL;
                     ins_ra_rec.ussgl_transaction_code := NULL;
                     ins_ra_rec.ussgl_transaction_code_context := NULL;
                     ins_ra_rec.reversal_gl_date := NULL;
                     ins_ra_rec.cash_receipt_history_id := new_crh_id;
                     ins_ra_rec.application_ref_type := NULL;
                     ins_ra_rec.application_ref_id := NULL;
                     ins_ra_rec.application_ref_num := NULL;
                     ins_ra_rec.secondary_application_ref_id := NULL;
                     ins_ra_rec.application_ref_reason := NULL;
                     ins_ra_rec.customer_reference := NULL;
                     /*Bug3505753  */
                     ins_ra_rec.link_to_customer_trx_id:=NULL;

                     arp_app_pkg.insert_p( ins_ra_rec, temp_num );


                    --Bug#2750340
                    l_xla_ev_rec.xla_from_doc_id := temp_num;
                    l_xla_ev_rec.xla_to_doc_id   := temp_num;
                    l_xla_ev_rec.xla_doc_table   := 'APP';
                    l_xla_ev_rec.xla_mode        := 'O';
                    l_xla_ev_rec.xla_call        := 'B';
                    ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);

                    --
                    --Release 11.5 VAT changes, create the UNAPP record accounting.
                    --
                     l_ae_doc_rec.document_type             := 'RECEIPT';
                     l_ae_doc_rec.document_id               := cr.cash_receipt_id;
                     l_ae_doc_rec.accounting_entity_level   := 'ONE';
                     l_ae_doc_rec.source_table              := 'RA';
                     l_ae_doc_rec.source_id                 := temp_num;         --new UNAPP record
                     l_ae_doc_rec.source_id_old             := '';
                     l_ae_doc_rec.other_flag                := '';
                     arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

            ELSE
                     ins_ra_rec.acctd_amount_applied_from := cr_acctd_amount;
                     ins_ra_rec.amount_applied := cr.amount;
                     ins_ra_rec.amount_applied_from := NULL;
                     ins_ra_rec.trans_to_receipt_rate := NULL;
                     ins_ra_rec.application_rule := 'RATE ADJUSTMENT TRIGGER';
                     ins_ra_rec.application_type := 'CASH';
                     ins_ra_rec.apply_date := new_crh.trx_date;
                     ins_ra_rec.code_combination_id := cr.unidentified_ccid;
                     ins_ra_rec.created_by := new_adj.created_by;
                     ins_ra_rec.creation_date := new_adj.creation_date;
                     ins_ra_rec.display := 'N';
                     ins_ra_rec.gl_date := new_crh.gl_date;
                     ins_ra_rec.last_updated_by := new_adj.last_updated_by;
                     ins_ra_rec.last_update_date := new_adj.last_update_date;
                     ins_ra_rec.payment_schedule_id := cr.payment_schedule_id;
                     ins_ra_rec.set_of_books_id := cr.set_of_books_id;
                     ins_ra_rec.status := 'UNID';
                     ins_ra_rec.acctd_amount_applied_to := NULL;
                     ins_ra_rec.acctd_earned_discount_taken := NULL;
                     ins_ra_rec.acctd_unearned_discount_taken := NULL;
                     ins_ra_rec.applied_customer_trx_id := NULL;
                     ins_ra_rec.applied_customer_trx_line_id := NULL;
                     ins_ra_rec.applied_payment_schedule_id := NULL;
                     ins_ra_rec.cash_receipt_id := cr.cash_receipt_id;
                     ins_ra_rec.comments := NULL;
                     ins_ra_rec.confirmed_flag := 'Y';
                     ins_ra_rec.customer_trx_id := NULL;
                     ins_ra_rec.days_late := NULL;
                     ins_ra_rec.earned_discount_taken := NULL;
                     ins_ra_rec.freight_applied := NULL;
                     ins_ra_rec.gl_posted_date := NULL;
                     ins_ra_rec.last_update_login := new_adj.last_update_login;
                     ins_ra_rec.line_applied := NULL;
                     ins_ra_rec.on_account_customer := NULL;
                     ins_ra_rec.postable := NULL;
                     ins_ra_rec.posting_control_id := -3;
                     ins_ra_rec.program_application_id := NULL;
                     ins_ra_rec.program_id := NULL;
                     ins_ra_rec.program_update_date := NULL;
                     ins_ra_rec.receivables_charges_applied := NULL;
                     ins_ra_rec.receivables_trx_id := NULL;
                     ins_ra_rec.request_id := NULL;
                     ins_ra_rec.tax_applied := NULL;
                     ins_ra_rec.unearned_discount_taken := NULL;
                     ins_ra_rec.unearned_discount_ccid := NULL;
                     ins_ra_rec.earned_discount_ccid := NULL;
                     ins_ra_rec.ussgl_transaction_code := NULL;
                     ins_ra_rec.ussgl_transaction_code_context := NULL;
                     ins_ra_rec.reversal_gl_date := NULL;
                     ins_ra_rec.cash_receipt_history_id := new_crh_id;
                     ins_ra_rec.application_ref_type := NULL;
                     ins_ra_rec.application_ref_id := NULL;
                     ins_ra_rec.application_ref_num := NULL;
                     ins_ra_rec.secondary_application_ref_id := NULL;
                     ins_ra_rec.application_ref_reason := NULL;
                     ins_ra_rec.customer_reference := NULL;
                      /*Bug3505753  */
                     ins_ra_rec.link_to_customer_trx_id:=NULL;


                     arp_app_pkg.insert_p( ins_ra_rec, temp_num );


                    --Bug#2750340
                    l_xla_ev_rec.xla_from_doc_id := temp_num;
                    l_xla_ev_rec.xla_to_doc_id   := temp_num;
                    l_xla_ev_rec.xla_doc_table   := 'APP';
                    l_xla_ev_rec.xla_mode        := 'O';
                    l_xla_ev_rec.xla_call        := 'B';
                    ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);

                    --
                    --Release 11.5 VAT changes, create the UNID record accounting.
                    --
                     l_ae_doc_rec.document_type             := 'RECEIPT';
                     l_ae_doc_rec.document_id               := cr.cash_receipt_id;
                     l_ae_doc_rec.accounting_entity_level   := 'ONE';
                     l_ae_doc_rec.source_table              := 'RA';
                     l_ae_doc_rec.source_id                 := temp_num;         --new UNID record
                     l_ae_doc_rec.source_id_old             := '';
                     l_ae_doc_rec.other_flag                := '';
                     arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

            END IF;
--arp_standard.debug('HYU-5');

            /* Bug No. 3825830
            Update the gl_date_closed of reciept in the payment schedules if the status is closed and
            the current gl_date closed is less than gl_date of the rate adjustment */

               SELECT gl_date_closed,status
               INTO   l_rct_gl_date_closed,l_rct_ps_status
               FROM   ar_payment_schedules
               WHERE  payment_schedule_id= cr.payment_schedule_id;
               IF     ((l_rct_gl_date_closed < nvl(new_crh.gl_date,l_rct_gl_date_closed))
                        AND l_rct_ps_status='CL') THEN
                      UPDATE ar_payment_schedules
                      SET    gl_date_closed = new_crh.gl_date
                      WHERE payment_schedule_id = cr.payment_schedule_id;
               END IF;
        END IF;
--
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug( '<< ARBRAD MAIN' );
        END IF;
    EXCEPTION
       WHEN claim_create_api_error THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('claim_create_api_error - ARP_RATE_ADJ.MAIN' );
         END IF;
         RAISE;

       WHEN claim_cancel_api_error THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('claim_cancel_api_error - ARP_RATE_ADJ.MAIN' );
         END IF;
         RAISE;

       WHEN OTHERS THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('EXCEPTION: ARP_RATE_ADJ.MAIN');
            arp_standard.debug('EXCEPTION OTHERS: '||SQLERRM);

         END IF;
         RAISE;
--
    END main;
--
 --gscc warning fix : moved initialization of package variable to the
 --new initialization section.
 begin
  PG_DEBUG := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

--
END arp_rate_adj;

/
