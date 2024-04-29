--------------------------------------------------------
--  DDL for Package Body AR_BUS_EVENT_SUB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BUS_EVENT_SUB_PVT" AS
/* $Header: ARBESUBB.pls 120.29.12010000.3 2010/04/16 13:19:39 mraymond ship $*/

TYPE ps_tab_type IS TABLE OF ar_payment_schedules%rowtype
 INDEX BY BINARY_INTEGER;
pg_cer_dso_days  NUMBER;

CURSOR get_trx_info (p_cust_acct_id NUMBER,
                     p_site_use_id  NUMBER,
                     p_currency     VARCHAR2,
                     p_date         DATE) IS
SELECT largest_inv_amount
FROM   ar_trx_summary
WHERE  cust_account_id = p_cust_acct_id
  AND  site_use_id = nvl(p_site_use_id,-99)
  AND  currency = p_currency
  AND  as_of_date = p_date
 FOR UPDATE;

CURSOR get_last_payment_info(p_cust_acct_id NUMBER,
                             p_site_use_id  NUMBER,
                             p_currency     VARCHAR2) IS
 SELECT last_payment_date,last_payment_number
   FROM   ar_trx_bal_summary
   WHERE  cust_account_id = p_cust_acct_id
     AND  site_use_id = nvl(p_site_use_id,-9999)
     AND  currency = p_currency
FOR UPDATE;
pg_debug VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

PROCEDURE debug (
        p_message_name          IN      VARCHAR2 ) IS
BEGIN
    ar_cmgt_util.debug (p_message_name, 'ar.cmgt.plsql.AR_BUS_EVENT_SUB_PVT');
END;

PROCEDURE Update_recapp_info(l_trx_class IN VARCHAR2,
                           l_trx_customer_id IN NUMBER,
                           l_trx_site_use_id IN NUMBER,
                           l_trx_currency_code IN VARCHAR2,
                           l_trx_amt      IN NUMBER,
                           l_op_trx_count IN NUMBER,
                           l_rcpt_customer_id IN NUMBER,
                           l_rcpt_site_use_id IN NUMBER,
                           l_rcpt_currency_code IN VARCHAR2,
                           l_rcpt_amt       IN NUMBER,
                           l_apply_date  IN DATE,
                           l_edisc_value IN NUMBER,
                           l_edisc_count IN NUMBER,
                           l_uedisc_value IN NUMBER,
                           l_uedisc_count IN NUMBER,
                           l_inv_paid_amt IN NUMBER,
                           l_inv_inst_pmt_days_sum IN NUMBER,
                           l_sum_app_amt_days_late IN NUMBER,
                           l_sum_app_amt IN NUMBER,
                           l_count_of_tot_inv_inst_paid IN NUMBER,
                           l_count_of_inv_inst_paid_late IN NUMBER,
                           l_count_of_disc_inv_inst IN NUMBER,
                           l_unresolved_cash_value  IN NUMBER,
                           l_unresolved_cash_count  IN NUMBER,
                           l_op_cm_count IN NUMBER , --this is relevant to credit memo applications
                           l_app_type IN VARCHAR2,
                           l_past_due_inv_value   IN NUMBER,
                           l_past_due_inv_inst_count IN NUMBER,
                           l_org_id  IN NUMBER
                           ) IS

BEGIN
    IF pg_debug = 'Y'
    THEN
    	debug ('AR_BUS_EVENT_SUB_PVT.Update_recapp_info(+)');
    	debug ('cust_account_id ='||l_trx_customer_id);
    	debug ('site_use_id ='||l_trx_site_use_id);
    	debug ('currency ='||l_trx_currency_code);
    	debug ('org_id ='||l_org_id);
   END IF;


        UPDATE ar_trx_bal_summary
          set OP_CREDIT_MEMOS_VALUE
                       = nvl(OP_CREDIT_MEMOS_VALUE,0)
                                     + DECODE(l_trx_class,'CM',
                                              nvl(l_trx_amt,0),0)
                                     + DECODE(l_app_type,'CM',l_trx_amt,0),
              OP_CREDIT_MEMOS_COUNT = nvl(OP_CREDIT_MEMOS_COUNT,0)
                                         - DECODE(l_trx_class,'CM',
                                               nvl(l_op_trx_count,0),0)
                                         - DECODE(l_app_type,'CM',l_op_cm_count,0),
              OP_INVOICES_VALUE = nvl(OP_INVOICES_VALUE,0)
                                        - DECODE(l_trx_class,'INV',
                                        nvl(l_trx_amt,0),0),
              OP_INVOICES_COUNT = nvl(OP_INVOICES_COUNT,0)
                                          - DECODE(l_trx_class, 'INV',
                                               nvl(l_op_trx_count,0),0),
              OP_DEBIT_MEMOS_VALUE = nvl(OP_DEBIT_MEMOS_VALUE,0)
                                        - DECODE(l_trx_class,'DM',
                                        nvl(l_trx_amt,0),0),
              OP_DEBIT_MEMOS_COUNT =  nvl(OP_DEBIT_MEMOS_COUNT,0)
                                          - DECODE(l_trx_class, 'DM',
                                               nvl(l_op_trx_count,0),0),
              OP_DEPOSITS_VALUE = nvl(OP_DEPOSITS_VALUE,0)
                                        - DECODE(l_trx_class,'DEP',
                                        nvl(l_trx_amt,0),0),
              OP_DEPOSITS_COUNT =  nvl(OP_DEPOSITS_COUNT,0)
                                          - DECODE(l_trx_class, 'DEP',
                                                 nvl(l_op_trx_count,0),0),
              OP_CHARGEBACK_VALUE = nvl(OP_CHARGEBACK_VALUE,0)
                                        - DECODE(l_trx_class,'CB',
                                               nvl(l_trx_amt,0),0),
              OP_CHARGEBACK_COUNT =  nvl(OP_CHARGEBACK_COUNT,0)
                                          - DECODE(l_trx_class, 'CB',
                                                 nvl(l_op_trx_count,0),0),
              PAST_DUE_INV_VALUE = nvl(PAST_DUE_INV_VALUE,0) -
                                      DECODE(l_trx_class,'INV',
                                             nvl(l_past_due_inv_value,0),0),
              PAST_DUE_INV_INST_COUNT = nvl(PAST_DUE_INV_INST_COUNT,0)
                                         - DECODE(l_trx_class,'INV',
                                             nvl(l_past_due_inv_inst_count,0),0),
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE cust_account_id = l_trx_customer_id
           and site_use_id = l_trx_site_use_id
           and currency = l_trx_currency_code
           and NVL(org_id,'-99') = NVL(l_org_id,-99);

      IF l_app_type = 'CASH'  THEN
        UPDATE ar_trx_bal_summary
          set UNRESOLVED_CASH_VALUE = nvl(UNRESOLVED_CASH_VALUE,0)
                                          + nvl(l_unresolved_cash_value,0),
              UNRESOLVED_CASH_COUNT = nvl(UNRESOLVED_CASH_COUNT,0) -
                                          nvl(l_unresolved_cash_count,0),
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE cust_account_id = l_rcpt_customer_id
           and site_use_id = l_rcpt_site_use_id
           and currency = l_rcpt_currency_code
           and NVL(org_id,'-99') = NVL(l_org_id,-99);
      END IF;

      IF l_app_type = 'CASH'  THEN
        UPDATE ar_trx_summary
          set INV_PAID_AMOUNT = nvl(INV_PAID_AMOUNT,0)
                                              + nvl(l_inv_paid_amt,0),
              INV_INST_PMT_DAYS_SUM = nvl(INV_INST_PMT_DAYS_SUM,0)
                                             + nvl(l_inv_inst_pmt_days_sum,0),
              TOTAL_EARNED_DISC_VALUE = nvl(TOTAL_EARNED_DISC_VALUE,0)
                                             + nvl(l_edisc_value,0),
              TOTAL_EARNED_DISC_COUNT = nvl(TOTAL_EARNED_DISC_COUNT,0)
                                             + nvl(l_edisc_count,0),
              TOTAL_UNEARNED_DISC_VALUE = nvl(TOTAL_UNEARNED_DISC_VALUE,0)
                                             + nvl(l_uedisc_value,0),
              TOTAL_UNEARNED_DISC_COUNT = nvl(TOTAL_UNEARNED_DISC_COUNT,0)
                                             + nvl(l_uedisc_count,0),
              SUM_APP_AMT_DAYS_LATE  = nvl(SUM_APP_AMT_DAYS_LATE,0)
                                             + nvl(l_SUM_APP_AMT_DAYS_LATE,0),
              SUM_APP_AMT = nvl(SUM_APP_AMT,0) + nvl(l_sum_app_amt,0),
              COUNT_OF_TOT_INV_INST_PAID = nvl(COUNT_OF_TOT_INV_INST_PAID,0)
                                            + nvl(l_count_of_tot_inv_inst_paid,0),
              COUNT_OF_INV_INST_PAID_LATE = nvl(COUNT_OF_INV_INST_PAID_LATE,0)
                                            + nvl(l_count_of_inv_inst_paid_late,0),
              COUNT_OF_DISC_INV_INST = nvl(COUNT_OF_DISC_INV_INST,0) +
                                             nvl(l_count_of_disc_inv_inst,0),
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
           -- DAYS_CREDIT_GRANTED_SUM = nvl(DAYS_CREDIT_GRANTED_SUM)
         WHERE cust_account_id = l_rcpt_customer_id
           and site_use_id = l_rcpt_site_use_id
           and currency = l_rcpt_currency_code
           and as_of_date = l_apply_date
           and NVL(org_id,'-99') = NVL(l_org_id,-99);
      END IF;
    IF pg_debug = 'Y'
    THEN
    	debug ('AR_BUS_EVENT_SUB_PVT.Update_recapp_info(-)');
    END IF;
END Update_recapp_info;

PROCEDURE Update_summary_for_request_id (p_request_id IN NUMBER)
IS
CURSOR get_req_run_data(p_req_id IN NUMBER) IS
  Select ps.class,
         ps.customer_id,
         ps.customer_site_use_id,
         ps.trx_date,
         ps.invoice_currency_code,
         ps.org_id,
         ps.due_date,
         ps.customer_trx_id ,
         trx.previous_customer_trx_id,
         ctt.type prev_trx_type,
         ps.terms_sequence_number,
         ps.amount_due_original,
         trx_sum.largest_inv_amount largest_inv_amount,
         trx_sum.largest_inv_date largest_inv_date,
         trx_sum.largest_inv_cust_trx_id largest_inv_cust_trx_id,
         count(nvl(rtl.term_id,1)) installment_count,
         sum(decode(sign(ra_cm.amount_applied),0,null,
                decode(ctt.type,'INV',
                    decode(cm_app_ps.status,'CL',1,null))))
                                   cm_closed_inv_count,
         sum(decode(sign(ra_cm.amount_applied),0,null,
              decode(ctt.type,'DM',
                    decode(cm_app_ps.status,'CL',1,null))))
                                   cm_closed_dm_count,
         sum(decode(sign(ra_cm.amount_applied),0,null,
              decode(ctt.type,'CM',
                    decode(cm_app_ps.status,'CL',1,null))))
                                   cm_closed_cm_count,
         sum(decode(sign(ra_cm.amount_applied),0,null,
              decode(ctt.type,'INV',
                decode(cm_app_ps.status,'CL',
                    decode(sign( cm_app_ps.due_date - trunc(sysdate)),-1,1,null)
                       )
                     )
                   ))              cm_cl_past_due_inv_ct,
         sum(decode(sign(ra_cm.amount_applied),0,null,
              decode(ctt.type,'INV',
                decode(cm_app_ps.status,'CL',
                    decode(sign( cm_app_ps.due_date - trunc(sysdate)),-1,
                        ra_cm.amount_applied,null)
                       )
                     )
                   ))              cm_cl_past_due_inv_amt
  from ra_customer_trx trx,
       ar_payment_schedules ps,
       ra_customer_trx prev_trx,
       ra_cust_trx_types ctt,
       ra_terms rt,
       ra_terms_lines rtl,
       ar_receivable_applications_all ra_cm,
       ar_payment_schedules_all cm_app_ps,
       ar_trx_summary trx_sum
  where trx.customer_trx_id = ps.customer_trx_id
    and trx.request_id = p_req_id
    and trx.previous_customer_trx_id = prev_trx.customer_trx_id(+)
    and prev_trx.cust_trx_type_id = ctt.cust_trx_type_id(+)
    and rt.term_id(+) = ps.term_id
    and rt.term_id = rtl.term_id(+)
    and trx.customer_trx_id = ra_cm.customer_trx_id(+)
    and ra_cm.applied_payment_schedule_id = cm_app_ps.payment_schedule_id(+)
    and trx_sum.cust_account_id(+) = trx.bill_to_customer_id
    and trx_sum.site_use_id(+) = trx.bill_to_site_use_id
    and trx_sum.currency(+) = trx.invoice_currency_code
    and trx_sum.as_of_date(+) = trx.trx_date
    and trx_sum.org_id (+) = trx.org_id
  group by ps.class,
         ps.customer_id,
         ps.customer_site_use_id,
         ps.trx_date,
         ps.invoice_currency_code,
         ps.org_id,
         ps.due_date,
         ps.customer_trx_id ,
         trx.previous_customer_trx_id,
         ctt.type,
         ps.terms_sequence_number,
         ps.amount_due_original,
         trx_sum.largest_inv_amount,
         trx_sum.largest_inv_date ,
         trx_sum.largest_inv_cust_trx_id
  order by ps.customer_trx_id,ps.terms_sequence_number;

  l_prev_customer_trx_id   NUMBER;
  l_inst_counter           NUMBER;
  l_trx_amount             NUMBER;

BEGIN
    IF pg_debug = 'Y'
    THEN
    	debug ('AR_BUS_EVENT_SUB_PVT.Update_summary_for_request_id(+)');
    	debug ('p_request_id ='||p_request_id);
   END IF;
 IF p_request_id IS NOT NULL  THEN
  For rec in get_req_run_data(p_request_id) LOOP
   IF  rec.installment_count > 1 and
       l_prev_customer_trx_id = rec.customer_trx_id
    THEN
     l_inst_counter := nvl(l_inst_counter,0) + 1;
     l_trx_amount := nvl(l_trx_amount,0) + rec.amount_due_original;

   ELSE
     --reset the installment counter for a new transaction
     l_inst_counter := 1;
     l_trx_amount :=  rec.amount_due_original;
   END IF;

   --
   -- l_tot_inv_amt := 0;


         UPDATE ar_trx_bal_summary
          set BEST_CURRENT_RECEIVABLES
                       = nvl(BEST_CURRENT_RECEIVABLES,0)
                              +DECODE(sign(rec.due_date - trunc(sysdate)),-1,0,
                               rec.amount_due_original),
              OP_INVOICES_VALUE
                       = nvl(OP_INVOICES_VALUE,0)
                             + DECODE(rec.class , 'INV' , rec.amount_due_original,
                                 'CM', decode(rec.previous_customer_trx_id, null,0,
                                      decode(rec.prev_trx_type,'INV',
                                                 rec.amount_due_original,0)),0),
              OP_INVOICES_COUNT
                       = nvl(OP_INVOICES_COUNT,0) +
                             DECODE(rec.class,'INV',1,'CM',
                                   decode(rec.previous_customer_trx_id, null,0,
                                     decode(rec.prev_trx_type,'INV',
                                                 -rec.cm_closed_inv_count)),0),
              PAST_DUE_INV_VALUE
                       = nvl(PAST_DUE_INV_VALUE,0) +  decode(rec.class , 'INV',
                                decode(sign(rec.due_date - trunc(sysdate)),-1,
                                   rec.amount_due_original,0),'CM',
                                    decode(rec.previous_customer_trx_id, null,0,
                                       decode(rec.prev_trx_type,'INV',
                                               rec.cm_cl_past_due_inv_amt,0)),0),
              PAST_DUE_INV_INST_COUNT
                      = nvl(PAST_DUE_INV_INST_COUNT,0) + decode(rec.class,'INV',
                             decode(sign(rec.due_date - trunc(sysdate)),-1,1,0),
                              'CM', decode(rec.previous_customer_trx_id, null,0,
                                  decode(rec.prev_trx_type,'INV',
                                            -rec.cm_cl_past_due_inv_ct,0)),0),
              OP_CREDIT_MEMOS_VALUE
                     = nvl(OP_CREDIT_MEMOS_VALUE,0) + DECODE(rec.class,'CM',
                               decode(rec.previous_customer_trx_id,  null,
                                        rec.amount_due_original),0),
              OP_CREDIT_MEMOS_COUNT
                     = nvl(OP_CREDIT_MEMOS_COUNT,0) +
                              DECODE(rec.class,'CM',
                                     DECODE(rec.previous_customer_trx_id, null,1,
                                        DECODE(rec.prev_trx_type,'CM',
                                                     -rec.cm_closed_cm_count,0)),0),
              OP_DEBIT_MEMOS_VALUE
                     = nvl(OP_DEBIT_MEMOS_VALUE,0) + DECODE(rec.class , 'DM',
                            rec.amount_due_original,'CM',
                                DECODE(rec.previous_customer_trx_id, null,0,
                                    DECODE(rec.prev_trx_type,'DM',
                                                 rec.amount_due_original,0)),0),
              OP_DEBIT_MEMOS_COUNT
                     =  nvl(OP_DEBIT_MEMOS_COUNT,0)+ DECODE(rec.class,'DM',1,'CM',
                                 DECODE(rec.previous_customer_trx_id, null,0,
                                     DECODE(rec.prev_trx_type,'DM',
                                                 -rec.cm_closed_dm_count,0)),0),
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE cust_account_id = rec.customer_id
           and site_use_id = nvl(rec.customer_site_use_id,-99)
           and currency = rec.invoice_currency_code
           and NVL(org_id,'-99') = NVL(rec.org_id,-99);


         IF SQL%NOTFOUND THEN
/* bug4403146 : Modified the decode for getting OP_DEBIT_MEMOS_COUNT */
           INSERT INTO ar_trx_bal_summary
            (CUST_ACCOUNT_ID,
             SITE_USE_ID,
             ORG_ID,
             CURRENCY,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             BEST_CURRENT_RECEIVABLES,
             OP_INVOICES_VALUE,
             OP_INVOICES_COUNT,
             PAST_DUE_INV_VALUE,
             PAST_DUE_INV_INST_COUNT,
             OP_CREDIT_MEMOS_VALUE,
             OP_CREDIT_MEMOS_COUNT,
             OP_DEBIT_MEMOS_VALUE,
             OP_DEBIT_MEMOS_COUNT)
             VALUES
            ( rec.customer_id,
              nvl(rec.customer_site_use_id,-99),
              rec.org_id,
              rec.invoice_currency_code,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              fnd_global.login_id,
              DECODE(sign(rec.due_date - trunc(sysdate)),-1,0,
                         rec.amount_due_original),
              DECODE(rec.class , 'INV' , rec.amount_due_original,
                                 'CM', decode(rec.previous_customer_trx_id, null,0,
                                      decode(rec.prev_trx_type,'INV',
                                                 rec.amount_due_original,0)),0),
              DECODE(rec.class,'INV',1,'CM',
                                   decode(rec.previous_customer_trx_id, null,0,
                                     decode(rec.prev_trx_type,'INV',
                                                 -rec.cm_closed_inv_count)),0),
              -decode(rec.class , 'INV',
                                decode(sign(rec.due_date - trunc(sysdate)),-1,
                                   rec.amount_due_original,0),'CM',
                                    decode(rec.previous_customer_trx_id, null,0,
                                       decode(rec.prev_trx_type,'INV',
                                               rec.cm_cl_past_due_inv_amt,0)),0),
               decode(rec.class,'INV',
                             decode(sign(rec.due_date - trunc(sysdate)),-1,1,0),
                              'CM', decode(rec.previous_customer_trx_id, null,0,
                                  decode(rec.prev_trx_type,'INV',
                                            -rec.cm_cl_past_due_inv_ct,0)),0),
               DECODE(rec.class,'CM',
                               decode(rec.previous_customer_trx_id,  null,
                                        rec.amount_due_original),0),
               DECODE(rec.previous_customer_trx_id, null,1,
                                        DECODE(rec.prev_trx_type,'CM',
                                                     -rec.cm_closed_cm_count,0)),
               DECODE(rec.class , 'DM',
                            rec.amount_due_original,'CM',
                                DECODE(rec.previous_customer_trx_id, null,0,
                                    DECODE(rec.prev_trx_type,'DM',
                                                 rec.amount_due_original,0)),0),
               DECODE(rec.class,'DM',1,'CM'
                                , DECODE(rec.previous_customer_trx_id, null,0,
                                     DECODE(rec.prev_trx_type,'DM',
                                                 -rec.cm_closed_dm_count,0)),0)
                );

            END IF;

        UPDATE ar_trx_summary
          SET OP_BAL_HIGH_WATERMARK = nvl(OP_BAL_HIGH_WATERMARK,0) +
                                             nvl(rec.amount_due_original,0),
              TOTAL_INVOICES_VALUE
                       = DECODE(rec.class , 'INV',
                           (nvl(TOTAL_INVOICES_VALUE,0)
                                 + nvl(rec.amount_due_original,0)),
                                       TOTAL_INVOICES_VALUE),
              TOTAL_INVOICES_COUNT
                       = DECODE(rec.class,'INV',nvl(TOTAL_INVOICES_COUNT,0)+1,
                              TOTAL_INVOICES_COUNT),
              LARGEST_INV_AMOUNT
                       = DECODE(rec.class , 'INV',
                          DECODE(sign(rec.installment_count - l_inst_counter),0,
                            DECODE(sign(l_trx_amount-nvl(LARGEST_INV_AMOUNT,0)),
                               1,l_trx_amount,LARGEST_INV_AMOUNT),
                                    LARGEST_INV_AMOUNT), LARGEST_INV_AMOUNT),
              LARGEST_INV_DATE = rec.trx_date,
              LARGEST_INV_CUST_TRX_ID
                       = DECODE(rec.class , 'INV',
                          DECODE(sign(rec.installment_count - l_inst_counter),0,
                           DECODE(sign(l_trx_amount-nvl(LARGEST_INV_AMOUNT,0)),1,
                             rec.customer_trx_id,LARGEST_INV_CUST_TRX_ID),
                               LARGEST_INV_CUST_TRX_ID),LARGEST_INV_CUST_TRX_ID),
              TOTAL_CREDIT_MEMOS_VALUE
                       = DECODE(rec.class,'CM',
                           nvl(TOTAL_CREDIT_MEMOS_VALUE,0)+rec.amount_due_original,
                             TOTAL_CREDIT_MEMOS_VALUE),
              TOTAL_CREDIT_MEMOS_COUNT
                       = DECODE(rec.class,'CM',nvl(TOTAL_CREDIT_MEMOS_COUNT,0)+1,
                           TOTAL_CREDIT_MEMOS_COUNT),
              TOTAL_DEBIT_MEMOS_VALUE
                        = DECODE(rec.class,'DM',
                           nvl(TOTAL_DEBIT_MEMOS_VALUE,0)+rec.amount_due_original,
                              TOTAL_DEBIT_MEMOS_VALUE),
              TOTAL_DEBIT_MEMOS_COUNT
                         = DECODE(rec.class,'DM',nvl(TOTAL_DEBIT_MEMOS_COUNT,0)+1,
                              TOTAL_DEBIT_MEMOS_COUNT),
              DAYS_CREDIT_GRANTED_SUM
                         = DECODE(rec.class,'INV',
                              nvl(DAYS_CREDIT_GRANTED_SUM,0) +
                                  (rec.amount_due_original *
                                       (rec.due_date - rec.trx_date)),
                                               DAYS_CREDIT_GRANTED_SUM),
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE cust_account_id = rec.customer_id
           AND site_use_id = nvl(rec.customer_site_use_id,-99)
           AND currency = rec.invoice_currency_code
           AND NVL(org_id,'-99') = NVL(rec.org_id,-99)
           AND as_of_date = rec.trx_date;

         IF SQL%NOTFOUND THEN
          INSERT INTO ar_trx_summary
            ( CUST_ACCOUNT_ID,
              SITE_USE_ID,
              ORG_ID,
              CURRENCY,
              AS_OF_DATE,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              OP_BAL_HIGH_WATERMARK,
              TOTAL_INVOICES_VALUE,
              TOTAL_INVOICES_COUNT,
              LARGEST_INV_AMOUNT,
              LARGEST_INV_DATE,
              LARGEST_INV_CUST_TRX_ID ,
              TOTAL_CREDIT_MEMOS_VALUE ,
              TOTAL_CREDIT_MEMOS_COUNT ,
              TOTAL_DEBIT_MEMOS_VALUE,
              TOTAL_DEBIT_MEMOS_COUNT ,
              DAYS_CREDIT_GRANTED_SUM)
          VALUES
            ( rec.customer_id,
              nvl(rec.customer_site_use_id,-99),
              rec.org_id,
              rec.invoice_currency_code,
              rec.trx_date,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              fnd_global.login_id,
              rec.amount_due_original,
              rec.amount_due_original,
              DECODE(rec.class , 'INV',1,null),
              DECODE(rec.class , 'INV',
                DECODE(sign(rec.installment_count - l_inst_counter),0,
                       l_trx_amount,null),null),
              rec.trx_date,
              DECODE(rec.class , 'INV',
                DECODE(sign(rec.installment_count - l_inst_counter),0,
                             rec.customer_trx_id,null),null),
              DECODE(rec.class,'CM', rec.amount_due_original,null),
              DECODE(rec.class,'CM',1,null),
              DECODE(rec.class,'DM',rec.amount_due_original,null),
              DECODE(rec.class,'DM',1, null),
              DECODE(rec.class,'INV',
                 (rec.amount_due_original * (rec.due_date - rec.trx_date)),
                                               null));
         END IF;

      l_prev_customer_trx_id := rec.customer_trx_id;
   END LOOP;
  END IF;
    IF pg_debug = 'Y'
    THEN
    	debug ('AR_BUS_EVENT_SUB_PVT.Update_summary_for_request_id(-)');
   END IF;
END Update_summary_for_request_id;

PROCEDURE Update_Adj_info (
              l_customer_id  IN NUMBER,
              l_site_use_id  IN NUMBER,
              l_org_id       IN NUMBER,
              l_currency_code IN VARCHAR2,
              l_adj_amount    IN NUMBER,
              l_op_trx_count  IN NUMBER,
              l_apply_date    IN DATE,
              l_pending_adj_amount  IN NUMBER,
              l_class         IN VARCHAR2,
              l_special_adj   IN VARCHAR2 DEFAULT null,
              l_past_due_inv_inst_count  IN NUMBER,
              l_past_due_inv_value IN NUMBER
                           ) IS
BEGIN
    IF pg_debug = 'Y'
    THEN
    	debug ('AR_BUS_EVENT_SUB_PVT.Update_Adj_info(+)');
        debug ('cust_account_id ='||l_customer_id);
        debug ('site_use_id ='||l_site_use_id);
        debug ('currency ='||l_currency_code);
        debug ('org_id ='||l_org_id);
   END IF;
        UPDATE ar_trx_bal_summary
          set BEST_CURRENT_RECEIVABLES
                       = nvl(BEST_CURRENT_RECEIVABLES,0)
                              + nvl(l_adj_amount,0),
              OP_CREDIT_MEMOS_VALUE
                       = nvl(OP_CREDIT_MEMOS_VALUE,0)
                                        + DECODE(l_class,'CM',
                                        nvl(l_adj_amount,0),0),
              OP_CREDIT_MEMOS_COUNT = nvl(OP_CREDIT_MEMOS_COUNT,0)
                                         + DECODE(l_class, 'CM',
                                               nvl(l_op_trx_count,0),0),
              OP_INVOICES_VALUE = nvl(OP_INVOICES_VALUE,0)
                                        + DECODE(l_class,'INV',
                                        nvl(l_adj_amount,0),0),
              OP_INVOICES_COUNT = nvl(OP_INVOICES_COUNT,0)
                                          + DECODE(l_class, 'INV',
                                               nvl(l_op_trx_count,0),0),
              OP_DEBIT_MEMOS_VALUE = nvl(OP_DEBIT_MEMOS_VALUE,0)
                                        + DECODE(l_class,'DM',
                                        nvl(l_adj_amount,0),0),
              OP_DEBIT_MEMOS_COUNT =  nvl(OP_DEBIT_MEMOS_COUNT,0)
                                          + DECODE(l_class, 'DM',
                                               nvl(l_op_trx_count,0),0),
              OP_DEPOSITS_VALUE = nvl(OP_DEPOSITS_VALUE,0)
                                        + DECODE(l_class,'DEP',
                                        nvl(l_adj_amount,0),0),
              OP_DEPOSITS_COUNT =  nvl(OP_DEPOSITS_COUNT,0)
                                          + DECODE(l_class, 'DEP',
                                               nvl(l_op_trx_count,0),0),
              PAST_DUE_INV_VALUE = nvl(PAST_DUE_INV_VALUE,0) +
                                      DECODE(l_class,'INV',
                                             nvl(l_past_due_inv_value,0),0),
              PAST_DUE_INV_INST_COUNT = nvl(PAST_DUE_INV_INST_COUNT,0)
                                         + DECODE(l_class,'INV',
                                             nvl(l_past_due_inv_inst_count,0),0),
              PENDING_ADJ_VALUE  = nvl(PENDING_ADJ_VALUE,0)
                                          + DECODE(l_special_adj, 'Y', 0, nvl(l_pending_adj_amount,0)),
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE cust_account_id = l_customer_id
           and site_use_id = l_site_use_id
           and currency = l_currency_code
           and NVL(org_id,'-99') = NVL(l_org_id,-99);

           IF sql%NOTFOUND  THEN

            INSERT INTO ar_trx_bal_summary
            (CUST_ACCOUNT_ID,
             SITE_USE_ID,
             ORG_ID,
             CURRENCY,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             BEST_CURRENT_RECEIVABLES,
             OP_CREDIT_MEMOS_VALUE,
             OP_CREDIT_MEMOS_COUNT,
             OP_INVOICES_VALUE,
             OP_INVOICES_COUNT,
             OP_DEBIT_MEMOS_VALUE,
             OP_DEBIT_MEMOS_COUNT,
             OP_DEPOSITS_VALUE,
             OP_DEPOSITS_COUNT,
             PENDING_ADJ_VALUE)
             VALUES
            ( l_customer_id,
              l_site_use_id,
              l_org_id,
              l_currency_code,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              fnd_global.login_id,
              +nvl(l_adj_amount,0),
              + DECODE(l_class,'CM',nvl(l_adj_amount,0),0),
                DECODE(l_class, 'CM', nvl(l_op_trx_count,0),0),
              + DECODE(l_class,'INV',nvl(l_adj_amount,0),0),
              + DECODE(l_class, 'INV', nvl(l_op_trx_count,0),0),
              + DECODE(l_class,'DM', nvl(l_adj_amount,0),0),
              + DECODE(l_class, 'DM',  nvl(l_op_trx_count,0),0),
              + DECODE(l_class,'DEP', nvl(l_adj_amount,0),0),
              + DECODE(l_class, 'DEP',  nvl(l_op_trx_count,0),0),
              + DECODE(l_special_adj, 'Y',null,nvl(l_pending_adj_amount,0))
                );

           END IF;

        UPDATE ar_trx_summary
        set  OP_BAL_HIGH_WATERMARK = nvl(OP_BAL_HIGH_WATERMARK,0)
                                        + nvl(l_adj_amount,0),
          TOTAL_ADJUSTMENTS_VALUE = nvl(TOTAL_ADJUSTMENTS_VALUE,0)
                                       + DECODE(l_special_adj, 'Y',0, nvl(l_adj_amount,0)),
          TOTAL_ADJUSTMENTS_COUNT = nvl(TOTAL_ADJUSTMENTS_COUNT,0)
                                       + DECODE(l_special_adj, 'Y',0,nvl(l_op_trx_count,0)),
          LAST_UPDATE_DATE  = sysdate,
          LAST_UPDATED_BY   = FND_GLOBAL.user_id,
          LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
        where cust_account_id = l_customer_id
           and site_use_id = l_site_use_id
           and currency = l_currency_code
           and as_of_date = l_apply_date
           and NVL(org_id,'-99') = NVL(l_org_id,-99);

           IF sql%NOTFOUND  THEN

            INSERT INTO ar_trx_summary
            (CUST_ACCOUNT_ID,
             SITE_USE_ID,
             ORG_ID,
             CURRENCY,
             AS_OF_DATE,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             TOTAL_ADJUSTMENTS_VALUE,
             TOTAL_ADJUSTMENTS_COUNT,
             OP_BAL_HIGH_WATERMARK
             )
             VALUES
            ( l_customer_id,
              l_site_use_id,
              l_org_id,
              l_currency_code,
              l_apply_date,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              fnd_global.login_id,
              nvl(l_adj_amount,0),
              nvl(l_op_trx_count,0),
              nvl(l_adj_amount,0)  );
           END IF;
    IF pg_debug = 'Y'
    THEN
    	debug ('AR_BUS_EVENT_SUB_PVT.Update_Adj_info(-)');
   END IF;
END Update_Adj_info;

PROCEDURE Update_rcpt_app_info_for_req(p_req_id in number,
                                       p_org_id in number)
IS
cursor create_recept_info(p_req_id IN NUMBER) IS
select rps.customer_id                    customer_id,
       nvl(rps.customer_site_use_id, -99) site_use_id,
       rps.invoice_currency_code          rcpt_currency,
       cr.receipt_date                    as_of_date,
       sum(nvl(ra.amount_applied_from,ra.amount_applied)) receipt_amount
from ar_receivable_applications ra,
     ar_payment_schedules rps,
     ar_cash_receipts cr
where ra.request_id = p_req_id
  and ra.status = 'UNAPP'
  and sign(ra.amount_applied) = 1
  and rps.payment_schedule_id = ra.payment_schedule_id
  and cr.cash_receipt_id = ra.cash_receipt_id
  group by rps.customer_id,
       nvl(rps.customer_site_use_id, -99),
       rps.invoice_currency_code,
       cr.receipt_date,
       ra.cash_receipt_id
  order by rps.customer_id,
       site_use_id,
       rps.invoice_currency_code,
       cr.receipt_date;
/* bug4335997 : Modified the where clause of cursor get_last_payment_info
                to get the correct last payment info */
cursor get_last_payment_info(p_req_id IN NUMBER) IS
select c.customer_id          customer_id,
       c.customer_site_use_id site_use_id,
       c.currency             rcpt_currency,
       cr1.amount             last_payment_amount,
       cr1.receipt_date       last_payment_date,
       cr1.receipt_number     last_payment_number
from (
select a.customer_id,
       a.customer_site_use_id,
       a.currency,
       max(b.cash_receipt_id) cash_receipt_id
from (
select cr.pay_from_customer customer_id,
       nvl(cr.customer_site_use_id,-99) customer_site_use_id,
       cr.currency_code currency,
       cr.org_id,
       max(cr.receipt_date) last_cash_receipt_date
 from ar_cash_receipts cr,
      ar_receivable_applications ra
 where ra.request_id  = p_req_id
   and ra.status = 'UNAPP'
   and sign(ra.amount_applied) = 1
   and cr.cash_receipt_id = ra.cash_receipt_id
 group by cr.pay_from_customer,
          nvl(cr.customer_site_use_id,-99),
          cr.currency_code,
          cr.org_id) a,
      ar_cash_receipts b
where a.last_cash_receipt_date  = b.receipt_date
 and   a.customer_id = b.pay_from_customer
 and   a.customer_site_use_id = nvl(b.customer_site_use_id,-99)
 and   a.org_id = b.org_id
 and   a.currency  = b.currency_code
group by a.customer_id,
       a.customer_site_use_id,
       a.currency) c,
      ar_cash_receipts cr1
WHERE cr1.cash_receipt_id = c.cash_receipt_id;

cursor application_info(p_req_id IN NUMBER) IS
select ps.customer_id                            trx_customer_id,
       nvl(ps.customer_site_use_id, -99)         trx_site_use_id,
       ps.invoice_currency_code                  trx_currency,
       ps.class                                  trx_class,
       ra.apply_date                             apply_date,
       sum(decode(sign(ps.due_date - ra.apply_date),-1,
                    (ra.apply_date -
                       nvl(ps.due_date ,ra.apply_date))
                               * ra.amount_applied,null)) sum_app_amt_days_late,
       sum(ra.earned_discount_taken)                      edisc_value,
 	   sum(ra.unearned_discount_taken)                    uedisc_value,
       sum(decode(sign(nvl(ra.earned_discount_taken,0)),
		                                    -1,-1,0,0,1)) edisc_count,
	   sum(decode(sign(nvl(ra.unearned_discount_taken,
		                               0)),-1,-1,0,0,1))  uedisc_count,
       sum(ra.amount_applied)                             amt_applied,
       sum((ra.apply_date -
		        (ps.due_date + nvl(rt.printing_lead_days,0)))
                            *ra.amount_applied)           inv_inst_pmt_days_sum,
       sum(DECODE(ps.class,'INV',
                 DECODE((nvl(ps.discount_taken_earned,0)
              + nvl(ps.discount_taken_unearned,0)),0,0,1),0))
                                                         count_of_disc_inv_inst,
       count(DECODE(ps.class,'INV',
	            ps.payment_schedule_id, null))   count_of_tot_inv_inst_paid,
       count(decode(sign(ps.due_date-ra.apply_date),-1,
                     ps.payment_schedule_id, null))  count_of_inv_inst_paid_late
  from  ar_receivable_applications ra,
        ar_payment_schedules ps,
        ra_terms_b rt
  where ra.request_id = p_req_id
    and ra.status = 'APP'
    and ps.payment_schedule_id = ra.applied_payment_schedule_id
    and rt.term_id(+) = ps.term_id
  group by ps.customer_id,
           nvl(ps.customer_site_use_id, -99),
           ps.invoice_currency_code,
           ra.apply_date,
           ps.class;

 /*
   These variables are used  to maintain the cumulative totals for the
   data in application_info cursor, which will be used for updating the
   ar_trx_bal_summary column.
  */
l_prev_trx_customer_id    number;
l_prev_trx_site_use_id    number;
l_prev_trx_currency       varchar2(30);

  /* 5690748 - keep lists of customers, sites, orgs, currencies
     for later use in refresh_counts call */
  l_customer_id_tab generic_id_type;
  l_site_use_id_tab generic_id_type;
  l_org_id_tab      generic_id_type;
  l_currency_tab    currency_type;
  l_row_counter     NUMBER := 0;
  l_max_rows_per_update NUMBER := 1000;
BEGIN

   IF pg_debug = 'Y'
   THEN
    	debug ('AR_BUS_EVENT_SUB_PVT.Update_rcpt_app_info_for_req(+)');
        debug ('p_req_id ='||p_req_id);
   END IF;
     FOR i in create_recept_info(p_req_id)
      LOOP
       -- AR_TRX_SUMMARY
         UPDATE ar_trx_summary
           set total_cash_receipts_value = nvl(total_cash_receipts_value,0) +
                                                           i.receipt_amount,
               total_cash_receipts_count = nvl(total_cash_receipts_count,0) + 1,
               LAST_UPDATE_DATE  = sysdate,
               LAST_UPDATED_BY   = FND_GLOBAL.user_id,
               LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         where cust_account_id = i.customer_id
           and site_use_id = nvl(i.site_use_id,-99)
           and NVL(org_id,'-99') = NVL(p_org_id,-99)
           and currency =   i.rcpt_currency
           and as_of_date = i.as_of_date;

           IF sql%notfound then
             INSERT INTO ar_trx_summary
       	       (CUST_ACCOUNT_ID,
                SITE_USE_ID,
                ORG_ID,
                CURRENCY,
                AS_OF_DATE,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                total_cash_receipts_value,
                total_cash_receipts_count
                ) VALUES
               (i.customer_id,
                nvl(i.site_use_id,-99),
                p_org_id,
                i.rcpt_currency,
                i.as_of_date,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                fnd_global.login_id,
                i.receipt_amount,
                1);
            END IF;

      END LOOP;


  FOR i in get_last_payment_info(p_req_id)
       LOOP
  UPDATE ar_trx_bal_summary
          set last_payment_amount = decode(sign(i.last_payment_date-last_payment_date),
                                         -1,last_payment_amount,i.last_payment_amount),
              last_payment_date =decode(sign(i.last_payment_date-last_payment_date),
                                            -1,last_payment_date,i.last_payment_date),
              last_payment_number = decode(sign(i.last_payment_date-last_payment_date),
                                            -1,last_payment_number,i.last_payment_number),
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
           where cust_account_id = i.customer_id
             and site_use_id =  nvl(i.site_use_id,-99)
             and NVL(org_id,'-99') = NVL(p_org_id,-99)
             and currency = i.rcpt_currency;

             IF sql%notfound then
               INSERT into  ar_trx_bal_summary
                 (cust_account_id,
                  site_use_id,
                  org_id,
                  currency,
                  last_update_date,
                  last_updated_by,
                  creation_date,
                  created_by,
                  last_update_login,
                  last_payment_amount,
                  last_payment_date,
                  last_payment_number
                 )VALUES
                 (i.customer_id,
                  nvl(i.site_use_id,-99),
                  p_org_id,
                  i.rcpt_currency,
                  sysdate,
                  fnd_global.user_id,
                  sysdate,
                  fnd_global.user_id,
                  fnd_global.login_id,
                  i.last_payment_amount,
                  i.last_payment_date,
                  i.last_payment_number
                  );
             END IF;


       END LOOP;

    FOR i IN application_info(p_req_id) LOOP

          UPDATE ar_trx_summary
	  SET           inv_paid_amount         = nvl(inv_paid_amount,0)
	                                                + nvl(i.amt_applied,0),
	                inv_inst_pmt_days_sum   = nvl(inv_inst_pmt_days_sum,0)
	                                               + nvl(i.inv_inst_pmt_days_sum,0),
	                total_earned_disc_value = nvl(total_earned_disc_value,0)
	                                               + nvl(i.edisc_value,0),
	                total_earned_disc_count = nvl(total_earned_disc_count,0)
	                                               + nvl(i.edisc_count,0),
	                total_unearned_disc_value = nvl(total_unearned_disc_value,0)
	                                               + nvl(i.uedisc_value,0),
	                total_unearned_disc_count = nvl(total_unearned_disc_count,0)
	                                               + nvl(i.uedisc_count,0),
	                sum_app_amt_days_late     = nvl(sum_app_amt_days_late,0)
	                                               + nvl(i.sum_app_amt_days_late,0),
	                sum_app_amt               = nvl(sum_app_amt,0) +
	                                                       nvl(i.amt_applied,0),
	                count_of_tot_inv_inst_paid = nvl(count_of_tot_inv_inst_paid,0)
	                                              + nvl(i.count_of_tot_inv_inst_paid,0),
	                count_of_inv_inst_paid_late = nvl(count_of_inv_inst_paid_late,0)
	                                              + nvl(i.count_of_inv_inst_paid_late,0),
	                count_of_disc_inv_inst = nvl(count_of_disc_inv_inst,0) +
	                                               nvl(i.count_of_disc_inv_inst,0),
                        LAST_UPDATE_DATE  = sysdate,
                        LAST_UPDATED_BY   = FND_GLOBAL.user_id,
                        LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
	           WHERE cust_account_id = i.trx_customer_id
	             and site_use_id = i.trx_site_use_id
	             and currency = i.trx_currency
	             and as_of_date = i.apply_date
                     and NVL(org_id,'-99') = NVL(p_org_id,-99);

        /* 5690748 - storing customer, site, currency, and org
           for use in refresh_counts */

      IF   ((nvl(l_prev_trx_customer_id,-99) <> i.trx_customer_id)
         OR (nvl(l_prev_trx_site_use_id,-999) <> i.trx_site_use_id)
         OR (nvl(l_prev_trx_currency,'XYZ~') <> i.trx_currency))
      THEN
        l_customer_id_tab(l_row_counter) := i.trx_customer_id;
        l_site_use_id_tab(l_row_counter) := i.trx_site_use_id;
        l_currency_tab(l_row_counter)    := i.trx_currency;
        l_org_id_tab(l_row_counter)      := p_org_id;
        l_row_counter := l_row_counter + 1;

        IF pg_debug = 'Y'
        THEN
           debug('new row: ' || i.trx_customer_id || ':' ||
               i.trx_site_use_id || ':' || i.trx_currency);
        END IF;

        /* 5690748 check if l_row_counter exceeds max (from profile) */
        IF l_row_counter >= l_max_rows_per_update
        THEN
           IF pg_debug = 'Y'
           THEN
              debug('total rows exceeds threshold.. executing update for block');
           END IF;

           refresh_counts(l_customer_id_tab,
                          l_site_use_id_tab,
                          l_currency_tab,
                          l_org_id_tab);


           l_row_counter := 0;
           l_customer_id_tab.delete;
           l_site_use_id_tab.delete;
           l_currency_tab.delete;
           l_org_id_tab.delete;

        END IF;
      END IF;

        l_prev_trx_customer_id   := i.trx_customer_id;
        l_prev_trx_site_use_id   := i.trx_site_use_id;
        l_prev_trx_currency      := i.trx_currency;

    END LOOP;

    /* 5690748 correct open and past_due columns */
    IF l_row_counter > 0
    THEN
       refresh_counts(l_customer_id_tab,
                      l_site_use_id_tab,
                      l_currency_tab,
                      l_org_id_tab);

       l_row_counter := 0;
       l_customer_id_tab.delete;
       l_site_use_id_tab.delete;
       l_currency_tab.delete;
       l_org_id_tab.delete;
    END IF;

    IF pg_debug = 'Y'
    THEN
    	debug ('AR_BUS_EVENT_SUB_PVT.Update_rcpt_app_info_for_req(-)');
   END IF;
END Update_rcpt_app_info_for_req;

FUNCTION Inv_Complete
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS

  l_ps_tab ps_tab_type;
  l_trx_summary_hist AR_TRX_SUMMARY_HIST%rowtype;
  CURSOR get_trx_history(p_cust_trx_id  IN NUMBER) IS
  SELECT *
  FROM AR_TRX_SUMMARY_HIST
  WHERE customer_trx_id = p_cust_trx_id
    and nvl(complete_flag,'N') = 'N'
    and amount_due_original is not null
    for update;

  CURSOR lock_ps (cust_trx_id IN NUMBER) IS
  SELECT * from ar_payment_schedules
  WHERE customer_trx_id = cust_trx_id
  FOR UPDATE;

  i                  INTEGER;
  l_key         VARCHAR2(240) := p_event.GetEventKey();
  l_payment_schedule_id   NUMBER(15);
  l_customer_trx_id  NUMBER;
  l_org_id           NUMBER;
  l_user_id          NUMBER;
  l_resp_id          NUMBER;
  l_application_id   NUMBER;
  l_security_gr_id   NUMBER;
  l_counter          NUMBER;
  l_history_exists_flag  BOOLEAN;
  l_ps_exists         BOOLEAN;
  l_history_rec      ar_trx_summary_hist%rowtype;
  l_tot_inv_amt      NUMBER;
  l_inv_inst_count   NUMBER;
 BEGIN

    IF pg_debug = 'Y'
    THEN
    	debug ('AR_BUS_EVENT_SUB_PVT.Inv_Complete(+)');
   END IF;
  l_customer_trx_id := p_event.GetValueForParameter('CUSTOMER_TRX_ID');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');
   IF pg_debug = 'Y'
   THEN
        debug ('l_customer_trx_id ='||l_customer_trx_id);
        debug ('l_org_id ='||l_org_id);
        debug ('l_user_id ='||l_user_id);
        debug ('l_resp_id ='||l_resp_id);
        debug ('l_application_id ='||l_application_id);
        debug ('l_security_gr_id ='||l_security_gr_id);
   END IF;
   SAVEPOINT  Inv_Complete_Event;
   --
   --set the application context.
   --
  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
  mo_global.init('AR');
  mo_global.set_policy_context('S',l_org_id);
   --
   -- Acquire locks on the payment schedule record so that
   -- the record is not changed while this subscription is
   -- executed.
   --
  OPEN lock_ps (l_customer_trx_id);
    i := 1;
    l_counter := 0;
   LOOP
   FETCH lock_ps INTO  l_ps_tab(i);

   IF lock_ps%NOTFOUND  THEN
     IF l_counter = 0 THEN
       l_ps_exists := FALSE;
     ELSE
       l_ps_exists := TRUE;
     END IF;

     EXIT;
   END IF;
       i := i + 1;
       l_counter := l_counter + 1;
   END LOOP;
  CLOSE lock_ps;

   --
   --Update the transaction history table
   --set the complete_flag = 'Y'
   --if history records exist.
   --
   UPDATE ar_trx_summary_hist
      set complete_flag = 'Y',
          LAST_UPDATE_DATE  = sysdate,
          LAST_UPDATED_BY   = FND_GLOBAL.user_id,
          LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
   WHERE customer_trx_id = l_customer_trx_id
     and nvl(complete_flag,'N') = 'N';


   IF SQL%NOTFOUND THEN
      l_history_exists_flag := FALSE;
   ELSE
      l_history_exists_flag := TRUE;
   END IF;


   IF l_ps_exists  THEN
    --Sweep thru the l_ps_tab table to update the summary table
    --and ignore the history.
    l_tot_inv_amt := 0;
    l_inv_inst_count :=  l_ps_tab.COUNT;

     FOR j in 1..l_ps_tab.COUNT
       LOOP
       --
       -- Update the AR_TRX_BAL_SUMMARY table
       --
        UPDATE ar_trx_bal_summary
          set BEST_CURRENT_RECEIVABLES
                       = nvl(BEST_CURRENT_RECEIVABLES,0)
                              +DECODE(sign(l_ps_tab(j).due_date - sysdate),-1,0,
                              (l_ps_tab(j).amount_due_original
                                   +nvl(l_ps_tab(j).amount_adjusted,0))),
              OP_INVOICES_VALUE
                       = nvl(OP_INVOICES_VALUE,0)
                             +l_ps_tab(j).amount_due_original
                                   +nvl(l_ps_tab(j).amount_adjusted,0),
              OP_INVOICES_COUNT = nvl(OP_INVOICES_COUNT,0) + 1,
              PAST_DUE_INV_VALUE = nvl(PAST_DUE_INV_VALUE,0) +
                                   decode(sign(l_ps_tab(j).due_date - trunc(sysdate)),-1,
                                         (l_ps_tab(j).amount_due_original
                                       +nvl(l_ps_tab(j).amount_adjusted,0)),0),
              PAST_DUE_INV_INST_COUNT = nvl(PAST_DUE_INV_INST_COUNT,0) +
                                   decode(sign(l_ps_tab(j).due_date - trunc(sysdate)),-1,1,0),
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE cust_account_id = l_ps_tab(j).customer_id
           and site_use_id = nvl(l_ps_tab(j).customer_site_use_id,-99)
           and currency = l_ps_tab(j).invoice_currency_code
           and NVL(org_id,'-99') = NVL(l_org_id,-99);

         IF SQL%NOTFOUND THEN

           INSERT INTO ar_trx_bal_summary
            (CUST_ACCOUNT_ID,
             SITE_USE_ID,
             ORG_ID,
             CURRENCY,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             BEST_CURRENT_RECEIVABLES,
             OP_INVOICES_VALUE,
             OP_INVOICES_COUNT,
             PAST_DUE_INV_VALUE,
             PAST_DUE_INV_INST_COUNT)
             VALUES
            ( l_ps_tab(j).customer_id,
              nvl(l_ps_tab(j).customer_site_use_id,-99),
              l_org_id,
              l_ps_tab(j).invoice_currency_code,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              fnd_global.login_id,
              DECODE(sign(l_ps_tab(j).due_date - sysdate),-1,0,
                (l_ps_tab(j).amount_due_original
                  +nvl(l_ps_tab(j).amount_adjusted,0))),
              l_ps_tab(j).amount_due_original+nvl(l_ps_tab(j).amount_adjusted,0),
              1,
              decode(sign(l_ps_tab(j).due_date - trunc(sysdate)),-1,
                                         (l_ps_tab(j).amount_due_original
                                       +nvl(l_ps_tab(j).amount_adjusted,0)),0),
              decode(sign(l_ps_tab(j).due_date - trunc(sysdate)),-1,1,null));

           END IF;
       --
       -- Update the AR_TRX_SUMMARY table
       --
        l_tot_inv_amt := l_tot_inv_amt +  l_ps_tab(j).amount_due_original;

        UPDATE ar_trx_summary
          set OP_BAL_HIGH_WATERMARK = nvl(OP_BAL_HIGH_WATERMARK,0) +
                                    l_ps_tab(j).amount_due_original+
                                    nvl(l_ps_tab(j).amount_adjusted,0),
              TOTAL_INVOICES_VALUE = nvl(TOTAL_INVOICES_VALUE,0) +
                                     l_ps_tab(j).amount_due_original,
              TOTAL_INVOICES_COUNT = nvl(TOTAL_INVOICES_COUNT,0) + 1,
              LARGEST_INV_AMOUNT = DECODE(sign(l_inv_inst_count -j),0,
                                     DECODE(sign(l_tot_inv_amt- nvl(LARGEST_INV_AMOUNT,0)),
                                             1,l_tot_inv_amt,LARGEST_INV_AMOUNT),LARGEST_INV_AMOUNT),
              LARGEST_INV_DATE = l_ps_tab(j).trx_date,
              LARGEST_INV_CUST_TRX_ID = DECODE(sign(l_inv_inst_count -j),0,
                                     DECODE(sign(l_tot_inv_amt- nvl(LARGEST_INV_AMOUNT,0)),
                                             1,l_ps_tab(j).customer_trx_id,LARGEST_INV_CUST_TRX_ID),
                                                LARGEST_INV_CUST_TRX_ID),
              DAYS_CREDIT_GRANTED_SUM = nvl(DAYS_CREDIT_GRANTED_SUM,0) +
                                            ((l_ps_tab(j).amount_due_original
                                             + nvl(l_ps_tab(j).amount_adjusted,0))
                                                * (l_ps_tab(j).due_date
                                                    - l_ps_tab(j).trx_date)),
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE cust_account_id = l_ps_tab(j).customer_id
           and site_use_id = nvl(l_ps_tab(j).customer_site_use_id,-99)
           and currency = l_ps_tab(j).invoice_currency_code
           and NVL(org_id,'-99') = NVL(l_org_id,-99)
           and as_of_date = l_ps_tab(j).trx_date;

        IF SQL%NOTFOUND THEN

          INSERT INTO ar_trx_summary
            (CUST_ACCOUNT_ID,
             SITE_USE_ID,
             ORG_ID,
             CURRENCY,
             AS_OF_DATE,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             OP_BAL_HIGH_WATERMARK,
             TOTAL_INVOICES_VALUE,
             TOTAL_INVOICES_COUNT,
             LARGEST_INV_AMOUNT,
             LARGEST_INV_DATE,
             LARGEST_INV_CUST_TRX_ID,
             DAYS_CREDIT_GRANTED_SUM)
             VALUES
             (l_ps_tab(j).customer_id,
              nvl(l_ps_tab(j).customer_site_use_id,-99),
              l_org_id,
              l_ps_tab(j).invoice_currency_code,
              l_ps_tab(j).trx_date,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              fnd_global.login_id,
              l_ps_tab(j).amount_due_original+
                                    nvl(l_ps_tab(j).amount_adjusted,0),
              l_ps_tab(j).amount_due_original,
              1,
              DECODE(sign(l_inv_inst_count -j),0,l_tot_inv_amt,null),
              l_ps_tab(j).trx_date,
              DECODE(sign(l_inv_inst_count -j),0,l_ps_tab(j).customer_trx_id,null),
              ((l_ps_tab(j).amount_due_original+ nvl(l_ps_tab(j).amount_adjusted,0))
                                * (l_ps_tab(j).due_date - l_ps_tab(j).trx_date))
              );
           END IF;
      END LOOP;

   ELSE --l_ps_exists
     --if no payment schedule exits for the given customer_trx_id
     --then we do not update the summary table.
     null;
   END IF; --l_ps_exists

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.Inv_Complete(-)');
    END IF;
 RETURN 'SUCCESS';

 EXCEPTION
    WHEN OTHERS  THEN
     ROLLBACK TO Inv_Complete_Event;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AR_BUS_EVENT_SUB_PVT', 'INV_COMPLETE', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

 END Inv_Complete;


FUNCTION Inv_InComplete
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS
  l_ps_tab ps_tab_type;
  l_trx_summary_hist AR_TRX_SUMMARY_HIST%rowtype;

  CURSOR get_trx_history(p_hist_id  IN NUMBER) IS
  SELECT *
  FROM AR_TRX_SUMMARY_HIST
  WHERE history_id = p_hist_id;
   -- and nvl(complete_flag,'N') = 'N';

  CURSOR get_curr_larg_inv_info(p_cust_account_id IN NUMBER,
                                p_site_use_id IN NUMBER,
                                p_currency IN VARCHAR2,
                                p_as_of_date IN DATE) IS
  SELECT LARGEST_INV_CUST_TRX_ID
  FROM ar_trx_summary
  WHERE cust_account_id = p_cust_account_id
    and site_use_id = p_site_use_id
    and currency = p_currency
    and as_of_date = p_as_of_date
   FOR UPDATE;

  i                  INTEGER;
  l_key         VARCHAR2(240) := p_event.GetEventKey();
  l_payment_schedule_id   NUMBER(15);
  l_customer_trx_id  NUMBER;
  l_org_id           NUMBER;
  l_user_id          NUMBER;
  l_resp_id          NUMBER;
  l_application_id   NUMBER;
  l_security_gr_id   NUMBER;
  l_counter          NUMBER;
  l_history_exists_flag  BOOLEAN;
  l_ps_exists        BOOLEAN;
  l_history_rec      ar_trx_summary_hist%rowtype;
  l_tot_inv_amt      NUMBER;
  l_inv_inst_count   NUMBER;
  l_larg_inv_cust_trx_id  NUMBER;
  l_text         VARCHAR2(2000);
  l_history_id     NUMBER(15);
  v_cursor1  NUMBER;
  l_larg_inv_amt    NUMBER;
  v_return_code   NUMBER;
  v_NumRows       NUMBER;
BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.Inv_InComplete(+)');
    END IF;
  l_customer_trx_id := p_event.GetValueForParameter('CUSTOMER_TRX_ID');
  l_payment_schedule_id := p_event.GetValueForParameter('PAYMENT_SCHEDULE_ID');
  l_history_id      := p_event.GetValueForParameter('HISTORY_ID');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');
   SAVEPOINT  Inv_InComplete_Event;
    IF pg_debug = 'Y'
    THEN
       debug ('l_customer_trx_id= '||l_customer_trx_id);
       debug ('l_payment_schedule_id= '||l_payment_schedule_id);
       debug ('l_history_id= '||l_history_id);
       debug ('l_org_id= '||l_org_id);
       debug ('l_user_id= '||l_user_id);
       debug ('l_resp_id= '||l_resp_id);
       debug ('l_application_id= '||l_application_id);
       debug ('l_security_gr_id= '||l_security_gr_id);
    END IF;
   --
   --set the application context.
   --
  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
  mo_global.init('AR');
  mo_global.set_policy_context('S',l_org_id);
   --
   -- No need to acquire locks on the payment schedule record
   -- because it would not exist in the database as the Incomplete
   -- event deletes the payment schedules.
   --

   -- In case of the Incomplete event on a PS of an inv, there will be
   -- no future events(or in other words history) on this payment schedule
   -- as this payment schedule would have been deleted. And subscriptions
   -- for all the earlier events on this PS would have been executed by now.
   --
   -- Update the transaction history table set the complete_flag = 'Y'
   -- if history records exist.
   --
    UPDATE ar_trx_summary_hist
      set complete_flag = 'Y',
          LAST_UPDATE_DATE  = sysdate,
          LAST_UPDATED_BY   = FND_GLOBAL.user_id,
          LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
    WHERE payment_schedule_id = l_payment_schedule_id
      and history_id = l_history_id
      and nvl(complete_flag,'N') = 'N';


    IF SQL%NOTFOUND THEN
       l_history_exists_flag := FALSE;
    ELSE
       l_history_exists_flag := TRUE;
    END IF;

   IF l_history_exists_flag  THEN

    OPEN get_trx_history(l_history_id) ;
    FETCH get_trx_history INTO l_history_rec;
    CLOSE get_trx_history ;

    l_tot_inv_amt := 0;

       --
       -- Update the AR_TRX_BAL_SUMMARY table
       --
        UPDATE ar_trx_bal_summary
          set BEST_CURRENT_RECEIVABLES
                       = nvl(BEST_CURRENT_RECEIVABLES,0)
                              -DECODE(sign(l_history_rec.due_date - sysdate),-1,0,
                              (l_history_rec.amount_due_original
                                   +nvl(l_history_rec.amount_adjusted,0))),
              OP_INVOICES_VALUE
                       = nvl(OP_INVOICES_VALUE,0)
                             -l_history_rec.amount_due_original
                                   -nvl(l_history_rec.amount_adjusted,0),
              OP_INVOICES_COUNT = nvl(OP_INVOICES_COUNT,0) - 1,
              PAST_DUE_INV_VALUE = nvl(PAST_DUE_INV_VALUE,0) -
                                   (decode(sign(l_history_rec.due_date - trunc(sysdate)),-1,
                                         (l_history_rec.amount_due_original
                                       +nvl(l_history_rec.amount_adjusted,0)),0)),
              PAST_DUE_INV_INST_COUNT = nvl(PAST_DUE_INV_INST_COUNT,0) -
                                   decode(sign(l_history_rec.due_date - trunc(sysdate)),-1,1,0),
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE cust_account_id = l_history_rec.customer_id
           and site_use_id = nvl(l_history_rec.site_use_id,-99)
           and currency = l_history_rec.currency_code
           and NVL(org_id,'-99') = NVL(l_org_id,-99);

       -- No need to check the SQL%NOTFOUND case because Incomplete
       -- event would fire only after a  complete event has fired.


       --
       -- Update the AR_TRX_SUMMARY table
       --

       --
       --Get the info about the largest invoice
       --
       --We need to do this calc only for one installment of
       --invoice. Since the l_history_rec.installments will always have a non-zero
       --value only for the first installment so we are using it to identify the
       --the first installment and do the largest inv calc.
       --
      IF nvl(l_history_rec.installments,0) > 0  THEN

       OPEN get_curr_larg_inv_info(l_history_rec.customer_id,
                                nvl(l_history_rec.site_use_id,-99),
                                l_history_rec.currency_code,
                                l_history_rec.trx_date);
         FETCH get_curr_larg_inv_info INTO l_larg_inv_cust_trx_id;
         IF   nvl(l_larg_inv_cust_trx_id,0) = l_history_rec.customer_trx_id
           THEN
           --get the new largest invoice by hitting the
           --payment schedule table
           l_text :=   'SELECT CUSTOMER_TRX_ID, inv_amount
                        FROM (
                        Select trx_date,customer_trx_id,
                               sum(amount_due_original) inv_amount,
                        RANK() OVER (ORDER BY sum(amount_due_original) desc,
                               customer_trx_id desc) rank_amt
                        FROM ar_payment_schedules
                        WHERE customer_id = :customer_id_bind
                           and customer_site_use_id = :customer_site_use_id_bind
                           and invoice_currency_code = :invoice_currency_code_bind
                           and trx_date = :trx_date_bind
                          group by trx_date,customer_trx_id)
                         where rank_amt = 1 ';
            v_cursor1 := dbms_sql.open_cursor;
            dbms_sql.parse(v_cursor1,l_text,DBMS_SQL.V7);

            -- 5217077 (One-off:5096808). Bind the bind-variables here.
            dbms_sql.bind_variable(v_cursor1, ':customer_id_bind', l_history_rec.customer_id);
            dbms_sql.bind_variable(v_cursor1, ':customer_site_use_id_bind', l_history_rec.site_use_id);
            dbms_sql.bind_variable(v_cursor1, ':invoice_currency_code_bind', l_history_rec.currency_code);
            dbms_sql.bind_variable(v_cursor1, ':trx_date_bind', l_history_rec.trx_date);

            dbms_sql.define_column(v_cursor1,1,l_larg_inv_cust_trx_id);
            dbms_sql.define_column(v_cursor1,2,l_larg_inv_amt);
            v_return_code := dbms_sql.execute(v_cursor1);

            v_NumRows := DBMS_SQL.FETCH_ROWS(v_cursor1);
            DBMS_SQL.COLUMN_VALUE(v_cursor1,1,l_larg_inv_cust_trx_id);
            DBMS_SQL.COLUMN_VALUE(v_cursor1,2,l_larg_inv_amt);
            dbms_sql.close_cursor(v_cursor1);

         END IF;
        CLOSE get_curr_larg_inv_info;
      END IF;

     UPDATE ar_trx_summary
        set OP_BAL_HIGH_WATERMARK = nvl(OP_BAL_HIGH_WATERMARK,0) -
                                        (l_history_rec.amount_due_original+
                                           nvl(l_history_rec.amount_adjusted,0)),
           TOTAL_INVOICES_VALUE = nvl(TOTAL_INVOICES_VALUE,0) -
                                       l_history_rec.amount_due_original,
           TOTAL_INVOICES_COUNT = nvl(TOTAL_INVOICES_COUNT,0) - 1,
           LARGEST_INV_AMOUNT = DECODE(sign(nvl(l_history_rec.installments,0)),
                                 1, DECODE(sign(nvl(LARGEST_INV_CUST_TRX_ID,0)-
                                                l_history_rec.customer_trx_id),
                                       0,l_larg_inv_amt,LARGEST_INV_AMOUNT),LARGEST_INV_AMOUNT),
           LARGEST_INV_DATE = LARGEST_INV_DATE,
           LARGEST_INV_CUST_TRX_ID = DECODE(sign(nvl(l_history_rec.installments,0)),
                                    1, DECODE(sign(nvl(LARGEST_INV_CUST_TRX_ID,0)-
                                                   l_history_rec.customer_trx_id),
                                       0,l_larg_inv_cust_trx_id,
                                            LARGEST_INV_CUST_TRX_ID),LARGEST_INV_AMOUNT),
           DAYS_CREDIT_GRANTED_SUM = nvl(DAYS_CREDIT_GRANTED_SUM,0) -
                                            ((l_history_rec.amount_due_original
                                             + l_history_rec.amount_adjusted)
                                                * (l_history_rec.due_date
                                                    - l_history_rec.trx_date)),
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE cust_account_id = l_history_rec.customer_id
           and site_use_id = nvl(l_history_rec.site_use_id,-99)
           and currency = l_history_rec.currency_code
           and NVL(org_id,'-99') = NVL(l_org_id,-99)
           and as_of_date = l_history_rec.trx_date;

   ELSE  --l_history_exists_flag is false
     null;
   END IF;

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.Inv_InComplete(-)');
    END IF;
  Return 'SUCCESS';
EXCEPTION
    WHEN OTHERS  THEN
     ROLLBACK TO Inv_InComplete_Event;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AR_BUS_EVENT_SUB_PVT', 'INV_INCOMPLETE', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

END Inv_InComplete;

FUNCTION Inv_Modify
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS

CURSOR get_trx_history(p_hist_id  IN NUMBER) IS
 SELECT *
 FROM AR_TRX_SUMMARY_HIST
 WHERE history_id = p_hist_id;
--  and nvl(complete_flag,'N') = 'N';

CURSOR get_trx_history2 (p_history_id IN NUMBER) IS
select *
from ar_trx_summary_hist
where previous_history_id = p_history_id;

CURSOR get_ps_info (p_ps_id IN NUMBER) IS
select due_date, amount_in_dispute
from ar_payment_schedules
where payment_schedule_id = p_ps_id;

  l_key         VARCHAR2(240) := p_event.GetEventKey();
  l_payment_schedule_id   NUMBER(15);
  l_org_id           NUMBER;
  l_user_id          NUMBER;
  l_resp_id          NUMBER;
  l_application_id   NUMBER;
  l_security_gr_id   NUMBER;
  l_history_exists_flag  BOOLEAN;
  l_ps_exists        BOOLEAN;
  l_history_rec      ar_trx_summary_hist%rowtype;
  l_history_rec2     ar_trx_summary_hist%rowtype;
  l_tot_inv_amt      NUMBER;
  l_history_id       NUMBER(15);

  l_due_date_change  VARCHAR2(1);
  l_inv_dispute_count  NUMBER;
BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.Inv_Modify(+)');
    END IF;
  l_payment_schedule_id := p_event.GetValueForParameter('PAYMENT_SCHEDULE_ID');
  l_history_id      := p_event.GetValueForParameter('HISTORY_ID');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');

    IF pg_debug = 'Y'
    THEN
       debug ('l_payment_schedule_id= '||l_payment_schedule_id);
       debug ('l_history_id= '||l_history_id);
       debug ('l_org_id= '||l_org_id);
       debug ('l_user_id= '||l_user_id);
       debug ('l_resp_id= '||l_resp_id);
       debug ('l_application_id= '||l_application_id);
       debug ('l_security_gr_id= '||l_security_gr_id);
    END IF;
  Savepoint Inv_Modify_Event;
   --
   --set the application context.
   --
  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
  mo_global.init('AR');
  mo_global.set_policy_context('S',l_org_id);
   --Stamp the history record for the modification.
    /*bug#5484606-------------------------------------------------------------------+
|cuddagir Added Exception Handling for update statement and moved the logic for   |
|setting the flag inside the exception handling.                                |
|Have modified the earlier logic to make sure that the exceptions raised prior  |
|to calling the update statement are not trapped in "IF SQL%NOTFOUND" condition |
|Changes Start                                                                  |
+------------------------------------------------------------------------------*/

  BEGIN

   --Stamp the history record for the modification.
    UPDATE ar_trx_summary_hist
      set complete_flag = 'Y',
          LAST_UPDATE_DATE  = sysdate,
          LAST_UPDATED_BY   = FND_GLOBAL.user_id,
          LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
    WHERE payment_schedule_id = l_payment_schedule_id
      and history_id = l_history_id
      and nvl(complete_flag,'N') = 'N';

       l_history_exists_flag := TRUE;

  EXCEPTION

   WHEN NO_DATA_FOUND THEN
    l_history_exists_flag := FALSE;

  END;

   IF l_history_exists_flag  THEN

      OPEN get_trx_history(l_history_id) ;
      FETCH get_trx_history INTO l_history_rec;
      CLOSE get_trx_history ;

/*bug#5484606-------------------------------------------------------------------+
|cuddagir changed the condition for opening the cursor "get_trx_history2" with    |
|to get the data always from payment schedule                                   |
|Changes Start                                                                  |
+------------------------------------------------------------------------------*/

           OPEN get_ps_info(l_payment_schedule_id);
           FETCH get_ps_info INTO
                   l_history_rec2.due_date,
                   l_history_rec2.amount_in_dispute;
               l_ps_exists := true;
             IF get_ps_info%NOTFOUND THEN
               l_ps_exists := false;
             END IF;

           CLOSE get_ps_info;


      IF l_history_rec.due_date >= sysdate and
          l_history_rec2.due_date < sysdate THEN
         l_due_date_change :=  '-';
      ELSIF l_history_rec.due_date < sysdate and
          l_history_rec2.due_date >= sysdate THEN
          l_due_date_change :=  '+';
      END IF;

      IF nvl(l_history_rec2.amount_in_dispute,0) > 0
       AND nvl(l_history_rec.amount_in_dispute,0) = 0 THEN
           l_inv_dispute_count := 1;
      ELSIF nvl(l_history_rec2.amount_in_dispute,0) = 0
       AND nvl(l_history_rec.amount_in_dispute,0) > 0  THEN
         l_inv_dispute_count := -1;
      END IF;

        UPDATE ar_trx_bal_summary
          set BEST_CURRENT_RECEIVABLES
                      = nvl(BEST_CURRENT_RECEIVABLES,0)
                              -DECODE(l_due_date_change,'+',
                                  (l_history_rec.amount_due_original
                                   +nvl(l_history_rec.amount_adjusted,0)),
                                    '-',
                                    -(l_history_rec.amount_due_original
                                   +nvl(l_history_rec.amount_adjusted,0)),0),
              PAST_DUE_INV_VALUE = nvl(PAST_DUE_INV_VALUE,0)
                                   - DECODE(l_due_date_change,'+',
                                      -(l_history_rec.amount_due_remaining),
                                       '-',
                                      (l_history_rec.amount_due_remaining),0),
              PAST_DUE_INV_INST_COUNT = nvl(PAST_DUE_INV_INST_COUNT,0) -
                                        - DECODE(l_due_date_change,'+',
                                                     -1, '-',1,0),
              INV_AMT_IN_DISPUTE = nvl(INV_AMT_IN_DISPUTE,0)
                                        +(nvl(l_history_rec2.amount_in_dispute,0)
                                            - nvl(l_history_rec.amount_in_dispute,0)),
              DISPUTED_INV_COUNT = nvl(DISPUTED_INV_COUNT,0)
                                     + nvl(l_inv_dispute_count,0),
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE cust_account_id = l_history_rec.customer_id
           and site_use_id = nvl(l_history_rec.site_use_id,-99)
           and currency = l_history_rec.currency_code
           and NVL(org_id,'-99') = NVL(l_org_id,-99);

     UPDATE ar_trx_summary
       set  DAYS_CREDIT_GRANTED_SUM = nvl(DAYS_CREDIT_GRANTED_SUM,0) +
                                            ((l_history_rec.amount_due_original
                                             + l_history_rec.amount_adjusted)
                                                * (l_history_rec2.due_date -l_history_rec.due_date)),
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE cust_account_id = l_history_rec.customer_id
           and site_use_id = nvl(l_history_rec.site_use_id,-99)
           and currency = l_history_rec.currency_code
           and NVL(org_id,'-99') = NVL(l_org_id,-99)
           and as_of_date = l_history_rec.trx_date;

   END IF; --if history record has already been processed then we dont need
           --to do anything.

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.Inv_Modify(-)');
    END IF;
  Return 'SUCCESS';
EXCEPTION
    WHEN OTHERS  THEN
     ROLLBACK TO Inv_Modify_Event;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AR_BUS_EVENT_SUB_PVT', 'INV_MODIFY', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

END Inv_Modify;

FUNCTION Inv_DepositApply
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS

BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.Inv_DepositApply(+)');
    END IF;
  Return 'SUCCESS';
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.Inv_DepositApply(-)');
    END IF;
END Inv_DepositApply;

FUNCTION CM_Complete
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS
  l_ps_rec AR_PAYMENT_SCHEDULES%rowtype;
  l_trx_summary_hist AR_TRX_SUMMARY_HIST%rowtype;
  CURSOR get_trx_history(p_cust_trx_id  IN NUMBER) IS
  SELECT *
  FROM AR_TRX_SUMMARY_HIST
  WHERE customer_trx_id = p_cust_trx_id
    and nvl(complete_flag,'N') = 'N'
    and amount_due_original is not null
    for update;

  CURSOR lock_ps (cust_trx_id IN NUMBER) IS
  SELECT * from ar_payment_schedules
  WHERE customer_trx_id = cust_trx_id
  FOR UPDATE;

  CURSOR get_prev_ctx_id (ctx_id IN NUMBER) IS
  select ct.previous_customer_trx_id , ctt.type
  from ra_customer_trx ct,
       ra_customer_trx prev_ct,
       ra_cust_trx_types ctt
  where ct.customer_trx_id = ctx_id
    and prev_ct.customer_trx_id = ct.previous_customer_trx_id
    and prev_ct.cust_trx_type_id = ctt.cust_trx_type_id;

  i                  INTEGER;
  l_key         VARCHAR2(240) := p_event.GetEventKey();
  l_payment_schedule_id   NUMBER(15);
  l_customer_trx_id  NUMBER;
  l_org_id           NUMBER;
  l_user_id          NUMBER;
  l_resp_id          NUMBER;
  l_application_id   NUMBER;
  l_security_gr_id   NUMBER;
  l_counter          NUMBER;
  l_history_exists_flag  BOOLEAN;
  l_ps_exists         BOOLEAN;
  l_history_rec      ar_trx_summary_hist%rowtype;
  l_tot_inv_amt      NUMBER;
  l_inv_inst_count   NUMBER;
  l_prev_trx_op_count  NUMBER;
  l_prev_trx_app_amt   NUMBER;
  l_prev_ctx_id      NUMBER;
  l_prev_trx_class   VARCHAR2(10);
  l_past_due_inv_amt    NUMBER;
  l_past_due_inv_count  NUMBER;
BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CM_Complete(+)');
    END IF;
  l_customer_trx_id := p_event.GetValueForParameter('CUSTOMER_TRX_ID');
  l_prev_trx_op_count := p_event.GetValueForParameter('PREV_TRX_OP_COUNT');
  l_prev_trx_app_amt  := fnd_number.canonical_to_number(p_event.GetValueForParameter('PREV_TRX_APP_AMT'));
  l_past_due_inv_amt  := fnd_number.canonical_to_number(p_event.GetValueForParameter('PAST_DUE_INV_AMT'));
  l_past_due_inv_count  := p_event.GetValueForParameter('PAST_DUE_INV_COUNT');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');
  SAVEPOINT CM_Complete_Event;
    IF pg_debug = 'Y'
    THEN
       debug ('l_customer_trx_id= '||l_customer_trx_id);
       debug ('l_prev_trx_op_count= '||l_prev_trx_op_count);
       debug ('l_prev_trx_app_amt= '||l_prev_trx_app_amt);
       debug ('l_past_due_inv_amt= '||l_past_due_inv_amt);
       debug ('l_past_due_inv_count= '||l_past_due_inv_count);
       debug ('l_org_id= '||l_org_id);
       debug ('l_user_id= '||l_user_id);
       debug ('l_resp_id= '||l_resp_id);
       debug ('l_application_id= '||l_application_id);
       debug ('l_security_gr_id= '||l_security_gr_id);
    END IF;
   --
   --set the application context.
   --
  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
  mo_global.init('AR');
  mo_global.set_policy_context('S',l_org_id);
   --
   -- Acquire locks on the payment schedule record so that
   -- the record is not changed while this subscription is
   -- executed.
   --
  OPEN lock_ps (l_customer_trx_id);
/* bug4537412 	: Initialized the value of i as i:= 0 to prevent ORA-01400 error*/
    i := 0;

   LOOP
   FETCH lock_ps INTO  l_ps_rec;

   IF lock_ps%NOTFOUND  THEN
     IF i = 0 THEN
       l_ps_exists := FALSE;
     ELSE
       l_ps_exists := TRUE;
     END IF;

     EXIT;
   END IF;
       i := i + 1;
   END LOOP;
  CLOSE lock_ps;

   --
   --Update the transaction history table
   --set the complete_flag = 'Y'
   --if history records exist.
   --
   UPDATE ar_trx_summary_hist
      set complete_flag = 'Y',
          LAST_UPDATE_DATE  = sysdate,
          LAST_UPDATED_BY   = FND_GLOBAL.user_id,
          LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
   WHERE customer_trx_id = l_customer_trx_id
     and nvl(complete_flag,'N') = 'N';


   IF SQL%NOTFOUND THEN
      l_history_exists_flag := FALSE;
   ELSE
      l_history_exists_flag := TRUE;
   END IF;


   IF l_ps_exists  THEN

       OPEN get_prev_ctx_id(l_customer_trx_id);
        FETCH get_prev_ctx_id INTO l_prev_ctx_id, l_prev_trx_class;
       CLOSE get_prev_ctx_id;

       --l_prev_ctx_id is NOT NULL for a regular credit memo
       --and NULL for an On-Account Credit memo.

       --this is a credit memo so only one ps exists

       --
       -- Update the AR_TRX_BAL_SUMMARY table
       --
        UPDATE ar_trx_bal_summary
          set BEST_CURRENT_RECEIVABLES
                       = nvl(BEST_CURRENT_RECEIVABLES,0)
                              + DECODE(sign(l_ps_rec.due_date - sysdate),-1,0,
                              (l_ps_rec.amount_due_original
                                   +nvl(l_ps_rec.amount_adjusted,0))),
              OP_CREDIT_MEMOS_VALUE
                       = nvl(OP_CREDIT_MEMOS_VALUE,0)
                             + DECODE(l_prev_ctx_id, null,
                                     l_ps_rec.amount_due_original,
                                    DECODE(l_prev_trx_class,'CM',
                                                 l_ps_rec.amount_due_original,0)),
              OP_CREDIT_MEMOS_COUNT = nvl(OP_CREDIT_MEMOS_COUNT,0)
                                    + DECODE(l_prev_ctx_id, null,1,
                                        DECODE(l_prev_trx_class,'CM',
                                                     l_prev_trx_op_count,0)),
              OP_INVOICES_VALUE = nvl(OP_INVOICES_VALUE,0)
                                     + DECODE(l_prev_ctx_id, null,0,
                                         DECODE(l_prev_trx_class,'INV',
                                                 l_ps_rec.amount_due_original,0)),
              OP_INVOICES_COUNT =  nvl(OP_INVOICES_COUNT,0)
                                     + DECODE(l_prev_ctx_id, null,0,
                                          DECODE(l_prev_trx_class,'INV',
                                                          l_prev_trx_op_count,0)),
              OP_DEBIT_MEMOS_VALUE = nvl(OP_DEBIT_MEMOS_VALUE,0)
                                     + DECODE(l_prev_ctx_id, null,0,
                                         DECODE(l_prev_trx_class,'DM',
                                                 l_ps_rec.amount_due_original,0)),
              OP_DEBIT_MEMOS_COUNT =  nvl(OP_DEBIT_MEMOS_COUNT,0)
                                     + DECODE(l_prev_ctx_id, null,0,
                                          DECODE(l_prev_trx_class,'DM',
                                                          l_prev_trx_op_count,0)),
              OP_DEPOSITS_VALUE = nvl(OP_DEPOSITS_VALUE,0)
                                     + DECODE(l_prev_ctx_id, null,0,
                                         DECODE(l_prev_trx_class,'DEP',
                                                 l_ps_rec.amount_due_original,0)),
              OP_DEPOSITS_COUNT =  nvl(OP_DEPOSITS_COUNT,0)
                                     + DECODE(l_prev_ctx_id, null,0,
                                          DECODE(l_prev_trx_class,'DEP',
                                                          l_prev_trx_op_count,0)),
              OP_CHARGEBACK_VALUE = nvl(OP_CHARGEBACK_VALUE,0)
                                     + DECODE(l_prev_ctx_id, null,0,
                                         DECODE(l_prev_trx_class,'CB',
                                                 l_ps_rec.amount_due_original,0)),
              OP_CHARGEBACK_COUNT =  nvl(OP_CHARGEBACK_COUNT,0)
                                     + DECODE(l_prev_ctx_id, null,0,
                                          DECODE(l_prev_trx_class,'CB',
                                                          l_prev_trx_op_count,0)),
              PAST_DUE_INV_VALUE  = nvl(PAST_DUE_INV_VALUE,0)
                                      + nvl(l_past_due_inv_amt,0),
              PAST_DUE_INV_INST_COUNT = nvl(PAST_DUE_INV_INST_COUNT,0)
                                           + nvl(l_past_due_inv_count,0),
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE cust_account_id = l_ps_rec.customer_id
           and site_use_id = nvl(l_ps_rec.customer_site_use_id,-99)
           and currency = l_ps_rec.invoice_currency_code
           and NVL(org_id,'-99') = NVL(l_org_id,-99);

         IF SQL%NOTFOUND THEN

           INSERT INTO ar_trx_bal_summary
            (CUST_ACCOUNT_ID,
             SITE_USE_ID,
             ORG_ID,
             CURRENCY,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             BEST_CURRENT_RECEIVABLES,
             OP_CREDIT_MEMOS_VALUE,
             OP_CREDIT_MEMOS_COUNT,
             OP_INVOICES_VALUE,
             OP_INVOICES_COUNT,
             OP_DEBIT_MEMOS_VALUE,
             OP_DEBIT_MEMOS_COUNT,
             OP_CHARGEBACK_VALUE,
             OP_CHARGEBACK_COUNT,
             PAST_DUE_INV_VALUE,
             PAST_DUE_INV_INST_COUNT,
             OP_DEPOSITS_VALUE,
             OP_DEPOSITS_COUNT
             )
             VALUES
            ( l_ps_rec.customer_id,
              nvl(l_ps_rec.customer_site_use_id,-99),
              l_org_id,
              l_ps_rec.invoice_currency_code,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              fnd_global.login_id,
              DECODE(sign(l_ps_rec.due_date - sysdate),-1,0,
                               l_ps_rec.amount_due_original),
              DECODE(l_prev_ctx_id, null, l_ps_rec.amount_due_original,
                 DECODE(l_prev_trx_class,'CM',l_ps_rec.amount_due_original,0)),
              DECODE(l_prev_ctx_id, null,1,
                   DECODE(l_prev_trx_class,'CM', l_prev_trx_op_count,0)),
              DECODE(l_prev_ctx_id, null,0,
                 DECODE(l_prev_trx_class,'INV',l_ps_rec.amount_due_original,0)),
              DECODE(l_prev_ctx_id, null,0,
                 DECODE(l_prev_trx_class,'INV', l_prev_trx_op_count,0)),
              DECODE(l_prev_ctx_id, null,0,
                 DECODE(l_prev_trx_class,'DM',l_ps_rec.amount_due_original,0)),
              DECODE(l_prev_ctx_id, null,0,
                 DECODE(l_prev_trx_class,'DM', l_prev_trx_op_count,0)),
              DECODE(l_prev_ctx_id, null,0,
                 DECODE(l_prev_trx_class,'CB',l_ps_rec.amount_due_original,0)),
              DECODE(l_prev_ctx_id, null,0,
                 DECODE(l_prev_trx_class,'CB', l_prev_trx_op_count,0)),
              l_past_due_inv_amt,
              l_past_due_inv_count,
              DECODE(l_prev_ctx_id, null,0,
                 DECODE(l_prev_trx_class,'DEP',l_ps_rec.amount_due_original,0)),
              DECODE(l_prev_ctx_id, null,0,
                 DECODE(l_prev_trx_class,'DEP', l_prev_trx_op_count,0))
              );

           END IF;
       --
       -- Update the AR_TRX_SUMMARY table
       --

        UPDATE ar_trx_summary
          set OP_BAL_HIGH_WATERMARK = nvl(OP_BAL_HIGH_WATERMARK,0) +
                                               l_ps_rec.amount_due_original,
              TOTAL_CREDIT_MEMOS_VALUE = nvl(TOTAL_CREDIT_MEMOS_VALUE,0) +
                                               l_ps_rec.amount_due_original,
              TOTAL_CREDIT_MEMOS_COUNT = nvl(TOTAL_CREDIT_MEMOS_COUNT,0) + 1,
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE cust_account_id = l_ps_rec.customer_id
           and site_use_id = nvl(l_ps_rec.customer_site_use_id,-99)
           and currency = l_ps_rec.invoice_currency_code
           and NVL(org_id,'-99') = NVL(l_org_id,-99)
           and as_of_date = l_ps_rec.trx_date;

        IF SQL%NOTFOUND THEN

          INSERT INTO ar_trx_summary
            (CUST_ACCOUNT_ID,
             SITE_USE_ID,
             ORG_ID,
             CURRENCY,
             AS_OF_DATE,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             OP_BAL_HIGH_WATERMARK,
             TOTAL_CREDIT_MEMOS_VALUE,
             TOTAL_CREDIT_MEMOS_COUNT
             )
             VALUES
             (l_ps_rec.customer_id,
              nvl(l_ps_rec.customer_site_use_id,-99),
              l_org_id,
              l_ps_rec.invoice_currency_code,
              l_ps_rec.trx_date,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              fnd_global.login_id,
              l_ps_rec.amount_due_original+
                                    nvl(l_ps_rec.amount_adjusted,0),
              l_ps_rec.amount_due_original,
              1
              );
           END IF;

   ELSE --l_ps_exists
     --if no payment schedule exits for the given customer_trx_id
     --then we do not update the summary table.
     null;
   END IF; --l_ps_exists

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CM_Complete(-)');
    END IF;
  Return 'SUCCESS';
EXCEPTION
    WHEN OTHERS  THEN
     ROLLBACK TO CM_Complete_Event;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AR_BUS_EVENT_SUB_PVT', 'CM_COMPLETE', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';


END CM_Complete;

FUNCTION CM_InComplete
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS

  l_ps_tab ps_tab_type;
  l_trx_summary_hist AR_TRX_SUMMARY_HIST%rowtype;

  CURSOR get_trx_history(p_hist_id  IN NUMBER) IS
  SELECT *
  FROM AR_TRX_SUMMARY_HIST
  WHERE history_id = p_hist_id;

  CURSOR get_prev_ctx_id (ctx_id IN NUMBER) IS
  select previous_customer_trx_id
  from ra_customer_trx
  where customer_trx_id = ctx_id;

  i                  INTEGER;
  l_key         VARCHAR2(240) := p_event.GetEventKey();
  l_payment_schedule_id   NUMBER(15);
  l_customer_trx_id  NUMBER;
  l_org_id           NUMBER;
  l_user_id          NUMBER;
  l_resp_id          NUMBER;
  l_application_id   NUMBER;
  l_security_gr_id   NUMBER;
  l_counter          NUMBER;
  l_history_exists_flag  BOOLEAN;
  l_ps_exists        BOOLEAN;
  l_history_rec      ar_trx_summary_hist%rowtype;
  l_tot_inv_amt      NUMBER;
  l_inv_inst_count   NUMBER;
  l_larg_inv_cust_trx_id  NUMBER;
  l_text         VARCHAR2(2000);
  l_history_id     NUMBER(15);
  v_cursor1  NUMBER;
  l_larg_inv_amt    NUMBER;
  v_return_code   NUMBER;
  v_NumRows       NUMBER;
  l_prev_trx_op_count  NUMBER;
  l_prev_trx_app_amt   NUMBER;
  l_prev_ctx_id      NUMBER;
  l_prev_trx_class   VARCHAR2(10);
  l_past_due_inv_amt    NUMBER;
  l_past_due_inv_count  NUMBER;
BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CM_InComplete(+)');
    END IF;
  l_customer_trx_id := p_event.GetValueForParameter('CUSTOMER_TRX_ID');
  l_prev_trx_op_count := p_event.GetValueForParameter('PREV_TRX_OP_COUNT');
  l_prev_trx_app_amt  := fnd_number.canonical_to_number(p_event.GetValueForParameter('PREV_TRX_APP_AMT'));
  l_past_due_inv_amt  := fnd_number.canonical_to_number(p_event.GetValueForParameter('PAST_DUE_INV_AMT'));
  l_past_due_inv_count  := p_event.GetValueForParameter('PAST_DUE_INV_COUNT');
  l_prev_trx_class  := p_event.GetValueForParameter('PREV_TRX_TYPE');
  l_prev_ctx_id    := p_event.GetValueForParameter('PREV_TRX_ID');
  l_payment_schedule_id := p_event.GetValueForParameter('PAYMENT_SCHEDULE_ID');
  l_history_id      := p_event.GetValueForParameter('HISTORY_ID');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');
    IF pg_debug = 'Y'
    THEN
       debug ('l_customer_trx_id= '||l_customer_trx_id);
       debug ('l_prev_trx_op_count= '||l_prev_trx_op_count);
       debug ('l_prev_trx_app_amt= '||l_prev_trx_app_amt);
       debug ('l_past_due_inv_amt= '||l_past_due_inv_amt);
       debug ('l_past_due_inv_count= '||l_past_due_inv_count);
       debug ('l_prev_trx_class= '||l_prev_trx_class);
       debug ('l_prev_ctx_id= '||l_prev_ctx_id);
       debug ('l_payment_schedule_id= '||l_payment_schedule_id);
       debug ('l_history_id= '||l_history_id);
       debug ('l_org_id= '||l_org_id);
       debug ('l_user_id= '||l_user_id);
       debug ('l_resp_id= '||l_resp_id);
       debug ('l_application_id= '||l_application_id);
       debug ('l_security_gr_id= '||l_security_gr_id);
    END IF;
   SAVEPOINT  CM_InComplete_Event;
   --
   --set the application context.
   --
  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
  mo_global.init('AR');
  mo_global.set_policy_context('S',l_org_id);

   --
   -- No need to acquire locks on the payment schedule record
   -- because it would not exist in the database as the Incomplete
   -- event deletes the payment schedules.
   --

   -- In case of the Incomplete event on a PS of an inv, there will be
   -- no future events(or in other words history) on this payment schedule
   -- as this payment schedule would have been deleted. And subscriptions
   -- for all the earlier events on this PS would have been executed by now.
   --
   -- Update the transaction history table set the complete_flag = 'Y'
   -- if history records exist.
   --
    UPDATE ar_trx_summary_hist
      set complete_flag = 'Y',
          LAST_UPDATE_DATE  = sysdate,
          LAST_UPDATED_BY   = FND_GLOBAL.user_id,
          LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
    WHERE payment_schedule_id = l_payment_schedule_id
      and history_id = l_history_id
      and nvl(complete_flag,'N') = 'N';

    IF SQL%NOTFOUND THEN
       l_history_exists_flag := FALSE;
    ELSE
       l_history_exists_flag := TRUE;
    END IF;

   IF l_history_exists_flag  THEN

    OPEN get_trx_history(l_history_id) ;
    FETCH get_trx_history INTO l_history_rec;
    CLOSE get_trx_history ;

       --
       -- Update the AR_TRX_BAL_SUMMARY table
       --
        UPDATE ar_trx_bal_summary
          set BEST_CURRENT_RECEIVABLES
                       = nvl(BEST_CURRENT_RECEIVABLES,0)
                              - DECODE(sign(l_history_rec.due_date - sysdate),-1,0,
                              (l_history_rec.amount_due_original
                                   +nvl(l_history_rec.amount_adjusted,0))),
              OP_CREDIT_MEMOS_VALUE
                       = nvl(OP_CREDIT_MEMOS_VALUE,0)
                             - DECODE(l_prev_ctx_id, null,
                                     l_history_rec.amount_due_original,
                                    DECODE(l_prev_trx_class,'CM',
                                                 l_history_rec.amount_due_original,0)),
              OP_CREDIT_MEMOS_COUNT = nvl(OP_CREDIT_MEMOS_COUNT,0)
                                    + DECODE(l_prev_ctx_id, null,1,
                                        DECODE(l_prev_trx_class,'CM',
                                                     l_prev_trx_op_count,0)),
              OP_INVOICES_VALUE = nvl(OP_INVOICES_VALUE,0)
                                     - DECODE(l_prev_ctx_id, null,0,
                                         DECODE(l_prev_trx_class,'INV',
                                                 l_history_rec.amount_due_original,0)),
              OP_INVOICES_COUNT =  nvl(OP_INVOICES_COUNT,0)
                                     + DECODE(l_prev_ctx_id, null,0,
                                          DECODE(l_prev_trx_class,'INV',
                                                          l_prev_trx_op_count,0)),
              OP_DEBIT_MEMOS_VALUE = nvl(OP_DEBIT_MEMOS_VALUE,0)
                                     - DECODE(l_prev_ctx_id, null,0,
                                         DECODE(l_prev_trx_class,'DM',
                                                 l_history_rec.amount_due_original,0)),
              OP_DEBIT_MEMOS_COUNT =  nvl(OP_DEBIT_MEMOS_COUNT,0)
                                     + DECODE(l_prev_ctx_id, null,0,
                                          DECODE(l_prev_trx_class,'DM',
                                                          l_prev_trx_op_count,0)),
              OP_DEPOSITS_VALUE = nvl(OP_DEPOSITS_VALUE,0)
                                     - DECODE(l_prev_ctx_id, null,0,
                                         DECODE(l_prev_trx_class,'DEP',
                                                 l_history_rec.amount_due_original,0)),
              OP_DEPOSITS_COUNT =  nvl(OP_DEPOSITS_COUNT,0)
                                     + DECODE(l_prev_ctx_id, null,0,
                                          DECODE(l_prev_trx_class,'DEP',
                                                          l_prev_trx_op_count,0)),
              OP_CHARGEBACK_VALUE = nvl(OP_CHARGEBACK_VALUE,0)
                                     - DECODE(l_prev_ctx_id, null,0,
                                         DECODE(l_prev_trx_class,'CB',
                                                 l_history_rec.amount_due_original,0)),
              OP_CHARGEBACK_COUNT =  nvl(OP_CHARGEBACK_COUNT,0)
                                     + DECODE(l_prev_ctx_id, null,0,
                                          DECODE(l_prev_trx_class,'CB',
                                                          l_prev_trx_op_count,0)),
              PAST_DUE_INV_VALUE  = nvl(PAST_DUE_INV_VALUE,0)
                                      - nvl(l_past_due_inv_amt,0),
              PAST_DUE_INV_INST_COUNT = nvl(PAST_DUE_INV_INST_COUNT,0)
                                           - nvl(l_past_due_inv_count,0),
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE cust_account_id = l_history_rec.customer_id
           and site_use_id = nvl(l_history_rec.site_use_id,-99)
           and currency = l_history_rec.currency_code
           and NVL(org_id,'-99') = NVL(l_org_id,-99);

       --
       -- Update the AR_TRX_SUMMARY table
       --
     UPDATE ar_trx_summary
       set OP_BAL_HIGH_WATERMARK = nvl(OP_BAL_HIGH_WATERMARK,0) -
                                 l_history_rec.amount_due_original,
           TOTAL_CREDIT_MEMOS_VALUE = nvl(TOTAL_CREDIT_MEMOS_VALUE,0) -
                                  l_history_rec.amount_due_original,
           TOTAL_CREDIT_MEMOS_COUNT = nvl(TOTAL_CREDIT_MEMOS_COUNT,0) - 1,
           LAST_UPDATE_DATE  = sysdate,
           LAST_UPDATED_BY   = FND_GLOBAL.user_id,
           LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE cust_account_id = l_history_rec.customer_id
           and site_use_id = nvl(l_history_rec.site_use_id,-99)
           and currency = l_history_rec.currency_code
           and NVL(org_id,'-99') = NVL(l_org_id,-99)
           and as_of_date = l_history_rec.trx_date;

   ELSE  --l_history_exists_flag is false
     null;
   END IF;

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CM_InComplete(-)');
    END IF;
  Return 'SUCCESS';

END CM_InComplete;

FUNCTION CM_Modify
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS

BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CM_Modify(+)');
    END IF;
  Return 'SUCCESS';
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CM_Modify(-)');
    END IF;
END CM_Modify;

FUNCTION DM_Complete
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
) RETURN VARCHAR2 IS
  l_ps_tab ps_tab_type;
  l_trx_summary_hist AR_TRX_SUMMARY_HIST%rowtype;

  CURSOR get_trx_history(p_cust_trx_id  IN NUMBER) IS
  SELECT *
  FROM AR_TRX_SUMMARY_HIST
  WHERE customer_trx_id = p_cust_trx_id
    and nvl(complete_flag,'N') = 'N'
    and amount_due_original is not null
    for update;

  CURSOR lock_ps (cust_trx_id IN NUMBER) IS
  SELECT * from ar_payment_schedules
  WHERE customer_trx_id = cust_trx_id
  FOR UPDATE;

  i                  INTEGER;
  l_key         VARCHAR2(240) := p_event.GetEventKey();
  l_payment_schedule_id   NUMBER(15);
  l_customer_trx_id  NUMBER;
  l_org_id           NUMBER;
  l_user_id          NUMBER;
  l_resp_id          NUMBER;
  l_application_id   NUMBER;
  l_security_gr_id   NUMBER;
  l_counter          NUMBER;
  l_history_exists_flag  BOOLEAN;
  l_ps_exists         BOOLEAN;
  l_history_rec      ar_trx_summary_hist%rowtype;
 BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.DM_Complete(+)');
    END IF;
  l_customer_trx_id := p_event.GetValueForParameter('CUSTOMER_TRX_ID');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');
    IF pg_debug = 'Y'
    THEN
       debug ('l_customer_trx_id= '||l_customer_trx_id);
       debug ('l_org_id= '||l_org_id);
       debug ('l_user_id= '||l_user_id);
       debug ('l_resp_id= '||l_resp_id);
       debug ('l_application_id= '||l_application_id);
       debug ('l_security_gr_id= '||l_security_gr_id);
    END IF;
   SAVEPOINT  DM_Complete_Event;
   --
   --set the application context.
   --
  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
  mo_global.init('AR');
  mo_global.set_policy_context('S',l_org_id);

   --
   -- Acquire locks on the payment schedule record so that
   -- the record is not changed while this subscription is
   -- executed.
   --
  OPEN lock_ps (l_customer_trx_id);
    i := 1;
    l_counter := 0;
   LOOP
   FETCH lock_ps INTO  l_ps_tab(i);

   IF lock_ps%NOTFOUND  THEN
     IF l_counter = 0 THEN
       l_ps_exists := FALSE;
     ELSE
       l_ps_exists := TRUE;
     END IF;

     EXIT;
   END IF;
       i := i + 1;
       l_counter := l_counter + 1;
   END LOOP;
  CLOSE lock_ps;

   --
   --Update the transaction history table
   --set the complete_flag = 'Y'
   --if history records exist.
   --
   UPDATE ar_trx_summary_hist
     set complete_flag = 'Y',
         LAST_UPDATE_DATE  = sysdate,
         LAST_UPDATED_BY   = FND_GLOBAL.user_id,
         LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
   WHERE customer_trx_id = l_customer_trx_id
     and nvl(complete_flag,'N') = 'N';


   IF SQL%NOTFOUND THEN
      l_history_exists_flag := FALSE;
   ELSE
      l_history_exists_flag := TRUE;
   END IF;


   IF l_ps_exists  THEN
    --Sweep thru the l_ps_tab table to update the summary table
    --and ignore the history.

     FOR j in 1..l_ps_tab.COUNT
       LOOP
       --
       -- Update the AR_TRX_BAL_SUMMARY table
       --
        UPDATE ar_trx_bal_summary
          set BEST_CURRENT_RECEIVABLES
                       = nvl(BEST_CURRENT_RECEIVABLES,0)
                              +DECODE(sign(l_ps_tab(j).due_date - sysdate),-1,0,
                                        l_ps_tab(j).amount_due_original),
              OP_DEBIT_MEMOS_VALUE
                       = nvl(OP_DEBIT_MEMOS_VALUE,0)
                             +l_ps_tab(j).amount_due_original,
              OP_DEBIT_MEMOS_COUNT = nvl(OP_DEBIT_MEMOS_COUNT,0) + 1,
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE cust_account_id = l_ps_tab(j).customer_id
           and site_use_id = nvl(l_ps_tab(j).customer_site_use_id,-99)
           and currency = l_ps_tab(j).invoice_currency_code
           and NVL(org_id,'-99') = NVL(l_org_id,-99);

         IF SQL%NOTFOUND THEN

           INSERT INTO ar_trx_bal_summary
            (CUST_ACCOUNT_ID,
             SITE_USE_ID,
             ORG_ID,
             CURRENCY,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             BEST_CURRENT_RECEIVABLES,
             OP_DEBIT_MEMOS_VALUE,
             OP_DEBIT_MEMOS_COUNT
             )
             VALUES
            ( l_ps_tab(j).customer_id,
              nvl(l_ps_tab(j).customer_site_use_id,-99),
              l_org_id,
              l_ps_tab(j).invoice_currency_code,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              fnd_global.login_id,
              DECODE(sign(l_ps_tab(j).due_date - sysdate),-1,0,
                      l_ps_tab(j).amount_due_original),
              l_ps_tab(j).amount_due_original,
              1
              );

           END IF;
       --
       -- Update the AR_TRX_SUMMARY table
       --

        UPDATE ar_trx_summary
          set OP_BAL_HIGH_WATERMARK = nvl(OP_BAL_HIGH_WATERMARK,0) +
                                       l_ps_tab(j).amount_due_original,
              TOTAL_DEBIT_MEMOS_VALUE = nvl(TOTAL_DEBIT_MEMOS_VALUE,0) +
                                          l_ps_tab(j).amount_due_original,
               TOTAL_DEBIT_MEMOS_COUNT = nvl(TOTAL_DEBIT_MEMOS_COUNT,0) + 1,
               LAST_UPDATE_DATE  = sysdate,
               LAST_UPDATED_BY   = FND_GLOBAL.user_id,
               LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE cust_account_id = l_ps_tab(j).customer_id
           and site_use_id = nvl(l_ps_tab(j).customer_site_use_id,-99)
           and currency = l_ps_tab(j).invoice_currency_code
           and NVL(org_id,'-99') = NVL(l_org_id,-99)
           and as_of_date = l_ps_tab(j).trx_date;

        IF SQL%NOTFOUND THEN

          INSERT INTO ar_trx_summary
            (CUST_ACCOUNT_ID,
             SITE_USE_ID,
             ORG_ID,
             CURRENCY,
             AS_OF_DATE,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             OP_BAL_HIGH_WATERMARK,
             TOTAL_DEBIT_MEMOS_VALUE,
             TOTAL_DEBIT_MEMOS_COUNT
             )
             VALUES
             (l_ps_tab(j).customer_id,
              nvl(l_ps_tab(j).customer_site_use_id,-99),
              l_org_id,
              l_ps_tab(j).invoice_currency_code,
              l_ps_tab(j).trx_date,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              fnd_global.login_id,
              l_ps_tab(j).amount_due_original,
              l_ps_tab(j).amount_due_original,
              1
              );
           END IF;
      END LOOP;

   ELSE --l_ps_exists
     --if no payment schedule exits for the given customer_trx_id
     --then we do not update the summary table.
     null;
   END IF; --l_ps_exists

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.DM_Complete(-)');
    END IF;
  Return 'SUCCESS';
EXCEPTION
    WHEN OTHERS  THEN
     ROLLBACK TO DM_Complete_Event;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AR_BUS_EVENT_SUB_PVT', 'DM_COMPLETE', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';



END DM_Complete;

FUNCTION DM_InComplete
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS
  l_ps_tab ps_tab_type;
  l_trx_summary_hist AR_TRX_SUMMARY_HIST%rowtype;

  CURSOR get_trx_history(p_hist_id  IN NUMBER) IS
  SELECT *
  FROM AR_TRX_SUMMARY_HIST
  WHERE history_id = p_hist_id;
   -- and nvl(complete_flag,'N') = 'N';


  i                  INTEGER;
  l_key         VARCHAR2(240) := p_event.GetEventKey();
  l_payment_schedule_id   NUMBER(15);
  l_customer_trx_id  NUMBER;
  l_org_id           NUMBER;
  l_user_id          NUMBER;
  l_resp_id          NUMBER;
  l_application_id   NUMBER;
  l_security_gr_id   NUMBER;
  l_counter          NUMBER;
  l_history_exists_flag  BOOLEAN;
  l_ps_exists        BOOLEAN;
  l_history_rec      ar_trx_summary_hist%rowtype;
  l_tot_inv_amt      NUMBER;
  l_inv_inst_count   NUMBER;
  l_larg_inv_cust_trx_id  NUMBER;
  l_text         VARCHAR2(2000);
  l_history_id     NUMBER(15);
BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.DM_InComplete(+)');
    END IF;
  l_customer_trx_id := p_event.GetValueForParameter('CUSTOMER_TRX_ID');
  l_payment_schedule_id := p_event.GetValueForParameter('PAYMENT_SCHEDULE_ID');
  l_history_id      := p_event.GetValueForParameter('HISTORY_ID');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');
   SAVEPOINT  DM_InComplete_Event;
    IF pg_debug = 'Y'
    THEN
       debug ('l_customer_trx_id= '||l_customer_trx_id);
       debug ('l_payment_schedule_id= '||l_payment_schedule_id);
       debug ('l_history_id= '||l_history_id);
       debug ('l_org_id= '||l_org_id);
       debug ('l_user_id= '||l_user_id);
       debug ('l_resp_id= '||l_resp_id);
       debug ('l_application_id= '||l_application_id);
       debug ('l_security_gr_id= '||l_security_gr_id);
    END IF;
   --
   --set the application context.
   --
  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
  mo_global.init('AR');
  mo_global.set_policy_context('S',l_org_id);
   --
   -- No need to acquire locks on the payment schedule record
   -- because it would not exist in the database as the Incomplete
   -- event deletes the payment schedules.
   --

   -- In case of the Incomplete event on a PS of a trx, there will be
   -- no future events(or in other words history) on this payment schedule
   -- as this payment schedule would have been deleted. And subscriptions
   -- for all the earlier events on this PS would have been executed by now.
   --
   -- Update the transaction history table set the complete_flag = 'Y'
   -- if history records exist.
   --
    UPDATE ar_trx_summary_hist
      set complete_flag = 'Y',
          LAST_UPDATE_DATE  = sysdate,
          LAST_UPDATED_BY   = FND_GLOBAL.user_id,
          LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
    WHERE payment_schedule_id = l_payment_schedule_id
      and history_id = l_history_id
      and nvl(complete_flag,'N') = 'N';


    IF SQL%NOTFOUND THEN
       l_history_exists_flag := FALSE;
    ELSE
       l_history_exists_flag := TRUE;
    END IF;

   IF l_history_exists_flag  THEN

    OPEN get_trx_history(l_history_id) ;
    FETCH get_trx_history INTO l_history_rec;
    CLOSE get_trx_history ;

    l_tot_inv_amt := 0;

       --
       -- Update the AR_TRX_BAL_SUMMARY table
       --
        UPDATE ar_trx_bal_summary
          set BEST_CURRENT_RECEIVABLES
                       = nvl(BEST_CURRENT_RECEIVABLES,0)
                              -DECODE(sign(l_history_rec.due_date - sysdate),-1,0,
                                                 l_history_rec.amount_due_original),
              OP_DEBIT_MEMOS_VALUE
                       = nvl(OP_DEBIT_MEMOS_VALUE,0)
                             -l_history_rec.amount_due_original,
              OP_DEBIT_MEMOS_COUNT = nvl(OP_DEBIT_MEMOS_COUNT,0) - 1,
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE cust_account_id = l_history_rec.customer_id
           and site_use_id = nvl(l_history_rec.site_use_id,-99)
           and currency = l_history_rec.currency_code
           and NVL(org_id,'-99') = NVL(l_org_id,-99);

       -- No need to check the SQL%NOTFOUND case because Incomplete
       -- event would fire only after a  complete event has fired.


       --
       -- Update the AR_TRX_SUMMARY table
       --

     UPDATE ar_trx_summary
       set OP_BAL_HIGH_WATERMARK = nvl(OP_BAL_HIGH_WATERMARK,0) -
                                 l_history_rec.amount_due_original+
                                    nvl(l_history_rec.amount_adjusted,0),
           TOTAL_DEBIT_MEMOS_VALUE = nvl(TOTAL_DEBIT_MEMOS_VALUE,0) -
                                  l_history_rec.amount_due_original,
           TOTAL_DEBIT_MEMOS_COUNT = nvl(TOTAL_DEBIT_MEMOS_COUNT,0) - 1,
           LAST_UPDATE_DATE  = sysdate,
           LAST_UPDATED_BY   = FND_GLOBAL.user_id,
           LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE cust_account_id = l_history_rec.customer_id
           and site_use_id = nvl(l_history_rec.site_use_id,-99)
           and currency = l_history_rec.currency_code
           and NVL(org_id,'-99') = NVL(l_org_id,-99)
           and as_of_date = l_history_rec.trx_date;

   ELSE  --l_history_exists_flag is false
     null;
   END IF;

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.DM_InComplete(-)');
    END IF;
  Return 'SUCCESS';
EXCEPTION
    WHEN OTHERS  THEN
     ROLLBACK TO DM_InComplete_Event;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AR_BUS_EVENT_SUB_PVT', 'DEP_INCOMPLETE', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

END DM_InComplete;

FUNCTION DM_Modify
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS

BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.DM_Modify(+)');
    END IF;
  Return 'SUCCESS';
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.DM_Modify(-)');
    END IF;
END DM_Modify;

FUNCTION Dep_Complete
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS

  l_ps_tab ps_tab_type;
  l_trx_summary_hist AR_TRX_SUMMARY_HIST%rowtype;

  CURSOR get_trx_history(p_cust_trx_id  IN NUMBER) IS
  SELECT *
  FROM AR_TRX_SUMMARY_HIST
  WHERE customer_trx_id = p_cust_trx_id
    and nvl(complete_flag,'N') = 'N'
    and amount_due_original is not null
    for update;

  CURSOR lock_ps (cust_trx_id IN NUMBER) IS
  SELECT * from ar_payment_schedules
  WHERE customer_trx_id = cust_trx_id
  FOR UPDATE;

  i                  INTEGER;
  l_key         VARCHAR2(240) := p_event.GetEventKey();
  l_payment_schedule_id   NUMBER(15);
  l_customer_trx_id  NUMBER;
  l_org_id           NUMBER;
  l_user_id          NUMBER;
  l_resp_id          NUMBER;
  l_application_id   NUMBER;
  l_security_gr_id   NUMBER;
  l_counter          NUMBER;
  l_history_exists_flag  BOOLEAN;
  l_ps_exists         BOOLEAN;
  l_history_rec      ar_trx_summary_hist%rowtype;
 BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.Dep_Complete(+)');
    END IF;
  l_customer_trx_id := p_event.GetValueForParameter('CUSTOMER_TRX_ID');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');
   SAVEPOINT  Dep_Complete_Event;
    IF pg_debug = 'Y'
    THEN
       debug ('l_customer_trx_id= '||l_customer_trx_id);
       debug ('l_org_id= '||l_org_id);
       debug ('l_user_id= '||l_user_id);
       debug ('l_resp_id= '||l_resp_id);
       debug ('l_application_id= '||l_application_id);
       debug ('l_security_gr_id= '||l_security_gr_id);
    END IF;
   --
   --set the application context.
   --
  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
  mo_global.init('AR');
  mo_global.set_policy_context('S',l_org_id);

   --
   -- Acquire locks on the payment schedule record so that
   -- the record is not changed while this subscription is
   -- executed.
   --
  OPEN lock_ps (l_customer_trx_id);
    i := 1;
    l_counter := 0;
   LOOP
   FETCH lock_ps INTO  l_ps_tab(i);

   IF lock_ps%NOTFOUND  THEN
     IF l_counter = 0 THEN
       l_ps_exists := FALSE;
     ELSE
       l_ps_exists := TRUE;
     END IF;

     EXIT;
   END IF;
       i := i + 1;
       l_counter := l_counter + 1;
   END LOOP;
  CLOSE lock_ps;

   --
   --Update the transaction history table
   --set the complete_flag = 'Y'
   --if history records exist.
   --
   UPDATE ar_trx_summary_hist
      set complete_flag = 'Y',
          LAST_UPDATE_DATE  = sysdate,
          LAST_UPDATED_BY   = FND_GLOBAL.user_id,
          LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
   WHERE customer_trx_id = l_customer_trx_id
     and nvl(complete_flag,'N') = 'N';


   IF SQL%NOTFOUND THEN
      l_history_exists_flag := FALSE;
   ELSE
      l_history_exists_flag := TRUE;
   END IF;


   IF l_ps_exists  THEN
    --Sweep thru the l_ps_tab table to update the summary table
    --and ignore the history.

     FOR j in 1..l_ps_tab.COUNT
       LOOP
       --
       -- Update the AR_TRX_BAL_SUMMARY table
       --
        UPDATE ar_trx_bal_summary
          set BEST_CURRENT_RECEIVABLES
                       = nvl(BEST_CURRENT_RECEIVABLES,0)
                              +DECODE(sign(l_ps_tab(j).due_date - sysdate),-1,0,
                                        l_ps_tab(j).amount_due_original),
              OP_DEPOSITS_VALUE
                       = nvl(OP_DEPOSITS_VALUE,0)
                             +l_ps_tab(j).amount_due_original
                                   +nvl(l_ps_tab(j).amount_adjusted,0),
              OP_DEPOSITS_COUNT = nvl(OP_DEPOSITS_COUNT,0) + 1,
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE cust_account_id = l_ps_tab(j).customer_id
           and site_use_id = nvl(l_ps_tab(j).customer_site_use_id,-99)
           and currency = l_ps_tab(j).invoice_currency_code
           and NVL(org_id,'-99') = NVL(l_org_id,-99);

         IF SQL%NOTFOUND THEN

           INSERT INTO ar_trx_bal_summary
            (CUST_ACCOUNT_ID,
             SITE_USE_ID,
             ORG_ID,
             CURRENCY,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             BEST_CURRENT_RECEIVABLES,
             OP_INVOICES_VALUE,
             OP_INVOICES_COUNT
             )
             VALUES
            ( l_ps_tab(j).customer_id,
              nvl(l_ps_tab(j).customer_site_use_id,-99),
              l_org_id,
              l_ps_tab(j).invoice_currency_code,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              fnd_global.login_id,
              DECODE(sign(l_ps_tab(j).due_date - sysdate),-1,0,
                      l_ps_tab(j).amount_due_original),
              l_ps_tab(j).amount_due_original,
              1
              );

           END IF;
       --
       -- Update the AR_TRX_SUMMARY table
       --

        UPDATE ar_trx_summary
          set OP_BAL_HIGH_WATERMARK = nvl(OP_BAL_HIGH_WATERMARK,0) +
                                    l_ps_tab(j).amount_due_original+
                                    nvl(l_ps_tab(j).amount_adjusted,0),
              TOTAL_DEPOSITS_VALUE = nvl(TOTAL_DEPOSITS_VALUE,0) +
                                     l_ps_tab(j).amount_due_original,
              TOTAL_DEPOSITS_COUNT = nvl(TOTAL_DEPOSITS_COUNT,0) + 1,
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE cust_account_id = l_ps_tab(j).customer_id
           and site_use_id = nvl(l_ps_tab(j).customer_site_use_id,-99)
           and currency = l_ps_tab(j).invoice_currency_code
           and NVL(org_id,'-99') = NVL(l_org_id,-99)
           and as_of_date = l_ps_tab(j).trx_date;

        IF SQL%NOTFOUND THEN

          INSERT INTO ar_trx_summary
            (CUST_ACCOUNT_ID,
             SITE_USE_ID,
             ORG_ID,
             CURRENCY,
             AS_OF_DATE,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             OP_BAL_HIGH_WATERMARK,
             TOTAL_DEPOSITS_VALUE,
             TOTAL_DEPOSITS_COUNT
             )
             VALUES
             (l_ps_tab(j).customer_id,
              nvl(l_ps_tab(j).customer_site_use_id,-99),
              l_org_id,
              l_ps_tab(j).invoice_currency_code,
              l_ps_tab(j).trx_date,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              fnd_global.login_id,
              l_ps_tab(j).amount_due_original+
                                    nvl(l_ps_tab(j).amount_adjusted,0),
              l_ps_tab(j).amount_due_original,
              1
              );
           END IF;
      END LOOP;

   ELSE --l_ps_exists
     --if no payment schedule exits for the given customer_trx_id
     --then we do not update the summary table.
     null;
   END IF; --l_ps_exists

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.Dep_Complete(-)');
    END IF;

  Return 'SUCCESS';
EXCEPTION
    WHEN OTHERS  THEN
     ROLLBACK TO Dep_Complete_Event;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AR_BUS_EVENT_SUB_PVT', 'DEP_COMPLETE', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';
END Dep_Complete;

FUNCTION Dep_InComplete
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS
  l_ps_tab ps_tab_type;
  l_trx_summary_hist AR_TRX_SUMMARY_HIST%rowtype;

  CURSOR get_trx_history(p_hist_id  IN NUMBER) IS
  SELECT *
  FROM AR_TRX_SUMMARY_HIST
  WHERE history_id = p_hist_id;
   -- and nvl(complete_flag,'N') = 'N';


  i                  INTEGER;
  l_key         VARCHAR2(240) := p_event.GetEventKey();
  l_payment_schedule_id   NUMBER(15);
  l_customer_trx_id  NUMBER;
  l_org_id           NUMBER;
  l_user_id          NUMBER;
  l_resp_id          NUMBER;
  l_application_id   NUMBER;
  l_security_gr_id   NUMBER;
  l_counter          NUMBER;
  l_history_exists_flag  BOOLEAN;
  l_ps_exists        BOOLEAN;
  l_history_rec      ar_trx_summary_hist%rowtype;
  l_tot_inv_amt      NUMBER;
  l_inv_inst_count   NUMBER;
  l_larg_inv_cust_trx_id  NUMBER;
  l_text         VARCHAR2(2000);
  l_history_id     NUMBER(15);
BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.Dep_InComplete(+)');
    END IF;
  l_customer_trx_id := p_event.GetValueForParameter('CUSTOMER_TRX_ID');
  l_payment_schedule_id := p_event.GetValueForParameter('PAYMENT_SCHEDULE_ID');
  l_history_id      := p_event.GetValueForParameter('HISTORY_ID');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');
    IF pg_debug = 'Y'
    THEN
       debug ('l_customer_trx_id= '||l_customer_trx_id);
       debug ('l_payment_schedule_id= '||l_payment_schedule_id);
       debug ('l_history_id= '||l_history_id);
       debug ('l_org_id= '||l_org_id);
       debug ('l_user_id= '||l_user_id);
       debug ('l_resp_id= '||l_resp_id);
       debug ('l_application_id= '||l_application_id);
       debug ('l_security_gr_id= '||l_security_gr_id);
    END IF;
   --
   SAVEPOINT  Dep_InComplete_Event;
   --
   --set the application context.
   --
  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
  mo_global.init('AR');
  mo_global.set_policy_context('S',l_org_id);

   --
   -- No need to acquire locks on the payment schedule record
   -- because it would not exist in the database as the Incomplete
   -- event deletes the payment schedules.
   --

   -- In case of the Incomplete event on a PS of a trx, there will be
   -- no future events(or in other words history) on this payment schedule
   -- as this payment schedule would have been deleted. And subscriptions
   -- for all the earlier events on this PS would have been executed by now.
   --
   -- Update the transaction history table set the complete_flag = 'Y'
   -- if history records exist.
   --
    UPDATE ar_trx_summary_hist
      set complete_flag = 'Y',
          LAST_UPDATE_DATE  = sysdate,
          LAST_UPDATED_BY   = FND_GLOBAL.user_id,
          LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
    WHERE payment_schedule_id = l_payment_schedule_id
      and history_id = l_history_id
      and nvl(complete_flag,'N') = 'N';


    IF SQL%NOTFOUND THEN
       l_history_exists_flag := FALSE;
    ELSE
       l_history_exists_flag := TRUE;
    END IF;

   IF l_history_exists_flag  THEN

    OPEN get_trx_history(l_history_id) ;
    FETCH get_trx_history INTO l_history_rec;
    CLOSE get_trx_history ;

    l_tot_inv_amt := 0;

       --
       -- Update the AR_TRX_BAL_SUMMARY table
       --
        UPDATE ar_trx_bal_summary
          set BEST_CURRENT_RECEIVABLES
                       = nvl(BEST_CURRENT_RECEIVABLES,0)
                              -DECODE(sign(l_history_rec.due_date - sysdate),-1,0,
                                                 l_history_rec.amount_due_original),
              OP_DEPOSITS_VALUE
                       = nvl(OP_DEPOSITS_VALUE,0)
                             -l_history_rec.amount_due_original,
              OP_DEPOSITS_COUNT = nvl(OP_DEPOSITS_COUNT,0) - 1,
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE cust_account_id = l_history_rec.customer_id
           and site_use_id = nvl(l_history_rec.site_use_id,-99)
           and currency = l_history_rec.currency_code
           and NVL(org_id,'-99') = NVL(l_org_id,-99);

       -- No need to check the SQL%NOTFOUND case because Incomplete
       -- event would fire only after a  complete event has fired.


       --
       -- Update the AR_TRX_SUMMARY table
       --

     UPDATE ar_trx_summary
       set OP_BAL_HIGH_WATERMARK = nvl(OP_BAL_HIGH_WATERMARK,0) -
                                 l_history_rec.amount_due_original+
                                    nvl(l_history_rec.amount_adjusted,0),
           TOTAL_DEPOSITS_VALUE = nvl(TOTAL_DEPOSITS_VALUE,0) -
                                  l_history_rec.amount_due_original,
           TOTAL_DEPOSITS_COUNT = nvl(TOTAL_DEPOSITS_COUNT,0) - 1,
           LAST_UPDATE_DATE  = sysdate,
           LAST_UPDATED_BY   = FND_GLOBAL.user_id,
           LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE cust_account_id = l_history_rec.customer_id
           and site_use_id = nvl(l_history_rec.site_use_id,-99)
           and currency = l_history_rec.currency_code
           and NVL(org_id,'-99') = NVL(l_org_id,-99)
           and as_of_date = l_history_rec.trx_date;

   ELSE  --l_history_exists_flag is false
     null;
   END IF;

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.Dep_InComplete(-)');
    END IF;
  Return 'SUCCESS';
EXCEPTION
    WHEN OTHERS  THEN
     ROLLBACK TO Dep_InComplete_Event;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AR_BUS_EVENT_SUB_PVT', 'DEP_INCOMPLETE', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

END Dep_InComplete;

FUNCTION Dep_Modify
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS

BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.Dep_Modify(+)');
    END IF;
  Return 'SUCCESS';
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.Dep_Modify(-)');
    END IF;
END Dep_Modify;

FUNCTION CB_Create
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS

  l_ps_rec AR_PAYMENT_SCHEDULES%rowtype;
  l_trx_summary_hist AR_TRX_SUMMARY_HIST%rowtype;

  CURSOR get_trx_history(p_cust_trx_id  IN NUMBER) IS
  SELECT *
  FROM AR_TRX_SUMMARY_HIST
  WHERE customer_trx_id = p_cust_trx_id
    and nvl(complete_flag,'N') = 'N'
    and amount_due_original is not null
    for update;

  CURSOR lock_ps (cust_trx_id IN NUMBER) IS
  SELECT *
  FROM ar_payment_schedules
  WHERE customer_trx_id = cust_trx_id
  FOR UPDATE;

  i                     INTEGER;
  l_key                 VARCHAR2(240) := p_event.GetEventKey();
  l_payment_schedule_id NUMBER(15);
  l_customer_trx_id     NUMBER;
  l_org_id              NUMBER;
  l_user_id             NUMBER;
  l_resp_id             NUMBER;
  l_application_id      NUMBER;
  l_security_gr_id      NUMBER;
  l_counter             NUMBER;
  l_history_exists_flag BOOLEAN;
  l_ps_exists           BOOLEAN;
  l_history_rec         ar_trx_summary_hist%rowtype;
  l_tot_inv_amt         NUMBER;
  l_inv_inst_count      NUMBER;
BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CB_Create(+)');
    END IF;
  l_customer_trx_id := p_event.GetValueForParameter('CUSTOMER_TRX_ID');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');
    IF pg_debug = 'Y'
    THEN
       debug ('l_customer_trx_id= '||l_customer_trx_id);
       debug ('l_org_id= '||l_org_id);
       debug ('l_user_id= '||l_user_id);
       debug ('l_resp_id= '||l_resp_id);
       debug ('l_application_id= '||l_application_id);
       debug ('l_security_gr_id= '||l_security_gr_id);
    END IF;
  SAVEPOINT CB_Create;
   --
   --set the application context.
   --
  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
  mo_global.init('AR');
  mo_global.set_policy_context('S',l_org_id);
   --
   -- Acquire locks on the payment schedule record so that
   -- the record is not changed while this subscription is
   -- executed.
   --
  OPEN lock_ps (l_customer_trx_id);
    i := 1;
    l_counter := 0;
   LOOP
   FETCH lock_ps INTO  l_ps_rec;

   IF lock_ps%NOTFOUND  THEN
     IF l_counter = 0 THEN
       l_ps_exists := FALSE;
     ELSE
       l_ps_exists := TRUE;
     END IF;

     EXIT;
   END IF;
       i := i + 1;
       l_counter := l_counter + 1;
   END LOOP;
  CLOSE lock_ps;

   --
   --Update the transaction history table
   --set the complete_flag = 'Y'
   --if history records exist.
   --
   UPDATE ar_trx_summary_hist
      set complete_flag = 'Y',
          LAST_UPDATE_DATE  = sysdate,
          LAST_UPDATED_BY   = FND_GLOBAL.user_id,
          LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
   WHERE customer_trx_id = l_customer_trx_id
     and nvl(complete_flag,'N') = 'N';


   IF SQL%NOTFOUND THEN
      l_history_exists_flag := FALSE;
   ELSE
      l_history_exists_flag := TRUE;
   END IF;


   IF l_ps_exists  THEN
    --this is a chargeback so only one ps exists

       --
       -- Update the AR_TRX_BAL_SUMMARY table
       --

        UPDATE ar_trx_bal_summary
          set BEST_CURRENT_RECEIVABLES
                       = nvl(BEST_CURRENT_RECEIVABLES,0)
                              +DECODE(sign(l_ps_rec.due_date - sysdate),-1,0,
                                                 l_ps_rec.amount_due_original),
              OP_CHARGEBACK_VALUE
                       = nvl(OP_CHARGEBACK_VALUE,0)
                             +l_ps_rec.amount_due_original,
              OP_CHARGEBACK_COUNT = nvl(OP_CHARGEBACK_COUNT,0) + 1,
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE cust_account_id = l_ps_rec.customer_id
           and site_use_id = nvl(l_ps_rec.customer_site_use_id,-99)
           and currency = l_ps_rec.invoice_currency_code
           and NVL(org_id,'-99') = NVL(l_org_id,-99);

         IF SQL%NOTFOUND THEN

           INSERT INTO ar_trx_bal_summary
            (CUST_ACCOUNT_ID,
             SITE_USE_ID,
             ORG_ID,
             CURRENCY,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             BEST_CURRENT_RECEIVABLES,
             OP_CHARGEBACK_VALUE,
             OP_CHARGEBACK_COUNT
             )
             VALUES
            ( l_ps_rec.customer_id,
              nvl(l_ps_rec.customer_site_use_id,-99),
              l_org_id,
              l_ps_rec.invoice_currency_code,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              fnd_global.login_id,
              DECODE(sign(l_ps_rec.due_date - sysdate),-1,0,
                                  l_ps_rec.amount_due_original),
              l_ps_rec.amount_due_original,
              1
              );

           END IF;
       --
       -- Update the AR_TRX_SUMMARY table
       --

        UPDATE ar_trx_summary
          set OP_BAL_HIGH_WATERMARK = nvl(OP_BAL_HIGH_WATERMARK,0) +
                                                  l_ps_rec.amount_due_original,
              TOTAL_CHARGEBACK_VALUE = nvl(TOTAL_CHARGEBACK_VALUE,0) +
                                                   l_ps_rec.amount_due_original,
              TOTAL_CHARGEBACK_COUNT = nvl(TOTAL_CHARGEBACK_COUNT,0) + 1,
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE cust_account_id = l_ps_rec.customer_id
           and site_use_id = nvl(l_ps_rec.customer_site_use_id,-99)
           and currency = l_ps_rec.invoice_currency_code
           and NVL(org_id,'-99') = NVL(l_org_id,-99)
           and as_of_date = l_ps_rec.trx_date;

        IF SQL%NOTFOUND THEN

          INSERT INTO ar_trx_summary
            (CUST_ACCOUNT_ID,
             SITE_USE_ID,
             ORG_ID,
             CURRENCY,
             AS_OF_DATE,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             OP_BAL_HIGH_WATERMARK,
             TOTAL_CHARGEBACK_VALUE,
             TOTAL_CHARGEBACK_COUNT
             )
             VALUES
             (l_ps_rec.customer_id,
              nvl(l_ps_rec.customer_site_use_id,-99),
              l_org_id,
              l_ps_rec.invoice_currency_code,
              l_ps_rec.trx_date,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              fnd_global.login_id,
              l_ps_rec.amount_due_original,
              l_ps_rec.amount_due_original,
              1
              );
           END IF;

   ELSE --l_ps_exists
     --if no payment schedule exits for the given customer_trx_id
     --then we do not update the summary table.
     null;
   END IF; --l_ps_exists

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CB_Create(-)');
    END IF;
  Return 'SUCCESS';
EXCEPTION
    WHEN OTHERS  THEN
     ROLLBACK TO CB_Create;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AR_BUS_EVENT_SUB_PVT', 'CB_CREATE', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

END CB_Create;

FUNCTION CB_Modify
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS

BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CB_Modify(+)');
    END IF;
  Return 'SUCCESS';
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CB_Modify(-)');
    END IF;
END CB_Modify;

FUNCTION Guar_Complete
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS

BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.Guar_Complete(+)');
    END IF;
  Return 'SUCCESS';
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.Guar_Complete(-)');
    END IF;
END Guar_Complete;

FUNCTION Guar_InComplete
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS

BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.Guar_InComplete(+)');
    END IF;
  Return 'SUCCESS';
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.Guar_InComplete(-)');
    END IF;
END Guar_InComplete;

FUNCTION Guar_Modify
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS

BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.Guar_Modify(+)');
    END IF;
  Return 'SUCCESS';
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.Guar_Modify(-)');
    END IF;
END Guar_Modify;

FUNCTION CashReceipt_Create
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS

l_cash_receipt_id  NUMBER;
l_receipt_date   DATE ;
l_receipt_amount  NUMBER;
l_receipt_number  VARCHAR2(30);
l_customer_id  NUMBER;
l_customer_site_use_id NUMBER;
l_currency_code VARCHAR2(30);

  l_payment_schedule_id NUMBER;
  l_org_id          NUMBER;
  l_user_id         NUMBER;
  l_resp_id         NUMBER;
  l_application_id  NUMBER;
  l_security_gr_id  NUMBER;
  -- bug 3979914
  -- don't raise the BE in case of unidentified receipts
  l_cust_account_id	ar_payment_schedules.customer_id%type;

  /* 9363502 - define tables used by refresh_at_risk_value */
  l_customer_id_tab generic_id_type;
  l_site_use_id_tab generic_id_type;
  l_org_id_tab      generic_id_type;
  l_currency_tab    currency_type;
  /* end 9363502 */

CURSOR get_receipt_details (p_ps_id  IN NUMBER ) IS
SELECT cash_receipt_id, trx_date, amount_due_original,
       trx_number, customer_id, customer_site_use_id,
       invoice_currency_code
FROM ar_payment_schedules ps
WHERE payment_schedule_id = p_ps_id;

l_receipt_exists   BOOLEAN := FALSE;
BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CashReceipt_Create(+)');
    END IF;
  l_payment_schedule_id := p_event.GetValueForParameter('PAYMENT_SCHEDULE_ID');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');
  l_cust_account_id := p_event.GetValueForParameter('CUST_ACCOUNT_ID');

    IF pg_debug = 'Y'
    THEN
       debug ('l_payment_schedule_id= '||l_payment_schedule_id);
       debug ('l_org_id= '||l_org_id);
       debug ('l_user_id= '||l_user_id);
       debug ('l_resp_id= '||l_resp_id);
       debug ('l_application_id= '||l_application_id);
       debug ('l_security_gr_id= '||l_security_gr_id);
       debug ('l_cust_account_id= '||l_cust_account_id);
    END IF;
  -- bug -- bug 3979914
  -- don't raise the BE in case of unidentified receipts
  IF l_cust_account_id <> -99 -- means cust_account_id is null
  THEN
   SAVEPOINT  CR_Create_Event;
   --
   --set the application context.
   --
  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
  mo_global.init('AR');
  mo_global.set_policy_context('S',l_org_id);

   --we would stamp the complete_flag on the ar_trx_summary_hist
   --for any records for this cash receipt. They could be due to
   -- receipt deletion or modification.
     UPDATE ar_trx_summary_hist
      set complete_flag = 'Y',
          LAST_UPDATE_DATE  = sysdate,
          LAST_UPDATED_BY   = FND_GLOBAL.user_id,
          LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
      WHERE payment_schedule_id = l_payment_schedule_id;

  OPEN get_receipt_details (l_payment_schedule_id);

  FETCH get_receipt_details
    INTO l_cash_receipt_id,
         l_receipt_date   ,
         l_receipt_amount ,
         l_receipt_number ,
         l_customer_id,
         l_customer_site_use_id,
         l_currency_code ;

    IF get_receipt_details%NOTFOUND THEN
      --this would happen if the receipt got deleted before the subscription
      --for the create fires.
      --We have already stamped the history record for the deletion with
      --complete = Y so that the delete subscription does not fire
       null;
    ELSE
      l_receipt_exists := TRUE;
    END IF;

  CLOSE get_receipt_details;

  IF (l_receipt_exists)
  THEN

         UPDATE ar_trx_bal_summary
           set unresolved_cash_value = nvl(unresolved_cash_value,0) +
                                                               l_receipt_amount,
               unresolved_cash_count = nvl(unresolved_cash_count,0) + 1,
               last_payment_amount = DECODE(sign(l_receipt_date-last_payment_date),
                                          -1,last_payment_amount,l_receipt_amount),
               last_payment_date =DECODE(sign(l_receipt_date-last_payment_date),
                                          -1,last_payment_date,l_receipt_date),
               last_payment_number = DECODE(sign(l_receipt_date-last_payment_date),
                                          -1,last_payment_number,l_receipt_number),
               LAST_UPDATE_DATE  = sysdate,
               LAST_UPDATED_BY   = FND_GLOBAL.user_id,
               LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         where cust_account_id = l_customer_id
           and site_use_id =  nvl(l_customer_site_use_id,-99)
           and NVL(org_id,'-99') = NVL(l_org_id,-99)
           and currency = l_currency_code;

           IF sql%notfound then
             INSERT INTO  ar_trx_bal_summary
               (CUST_ACCOUNT_ID,
                SITE_USE_ID,
                ORG_ID,
                CURRENCY,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                unresolved_cash_value,
                unresolved_cash_count,
                last_payment_amount,
                last_payment_date,
                last_payment_number
               )VALUES
               (l_customer_id,
                nvl(l_customer_site_use_id,-99),
                l_org_id,
                l_currency_code,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                fnd_global.login_id,
                l_receipt_amount,
                1,
                l_receipt_amount,
                l_receipt_date,
                l_receipt_number
                );
           END IF;

    --Update ar_trx_summary
         UPDATE ar_trx_summary
           set total_cash_receipts_value = nvl(total_cash_receipts_value,0) +
                                                           l_receipt_amount,
               total_cash_receipts_count = nvl(total_cash_receipts_count,0) + 1,
               LAST_UPDATE_DATE  = sysdate,
               LAST_UPDATED_BY   = FND_GLOBAL.user_id,
               LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         where cust_account_id = l_customer_id
           and site_use_id = nvl(l_customer_site_use_id,-99)
           and NVL(org_id,'-99') = NVL(l_org_id,-99)
           and currency =   l_currency_code
           and as_of_date = l_receipt_date;

           IF sql%notfound then
             INSERT INTO ar_trx_summary
               (CUST_ACCOUNT_ID,
                SITE_USE_ID,
                ORG_ID,
                CURRENCY,
                AS_OF_DATE,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                total_cash_receipts_value,
                total_cash_receipts_count
                ) VALUES
               (l_customer_id,
                nvl(l_customer_site_use_id,-99),
                l_org_id,
                l_currency_code,
                l_receipt_date,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                fnd_global.login_id,
                l_receipt_amount,
                1);

           END IF;

    END IF;

  /* 9363502 - call refresh_at_risk_value() */
  l_customer_id_tab(0) := l_customer_id;
  l_site_use_id_tab(0) := l_customer_site_use_id;
  l_currency_tab(0) := l_currency_code;
  l_org_id_tab(0) := l_org_id;

  refresh_at_risk_value(l_customer_id_tab,
                        l_site_use_id_tab,
                        l_currency_tab,
                        l_org_id_tab);

  END IF;  -- end of l_cust-account_id <> -99
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CashReceipt_Create(-)');
    END IF;
  Return 'SUCCESS';
EXCEPTION
    WHEN OTHERS  THEN
     ROLLBACK TO CR_Create_Event;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AR_BUS_EVENT_SUB_PVT', 'CashReceipt_Create', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';
END CashReceipt_Create;

FUNCTION CashReceipt_Reverse
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
) RETURN VARCHAR2 IS
l_cash_receipt_id      NUMBER;
l_reversal_date         DATE ;
l_receipt_amount       NUMBER;
l_receipt_number       VARCHAR2(30);
l_customer_id          NUMBER;
l_customer_site_use_id NUMBER;
l_currency_code        VARCHAR2(30);
l_history_id           NUMBER;
l_payment_schedule_id  NUMBER;
l_org_id               NUMBER;
l_user_id              NUMBER;
l_resp_id              NUMBER;
l_application_id       NUMBER;
l_security_gr_id       NUMBER;
l_reversal_category    VARCHAR2(20);
l_last_receipt_number  VARCHAR2(30);
l_last_receipt_amount  NUMBER;
l_last_receipt_date    DATE;
is_last_payment        VARCHAR2(1);
l_unresolved_cash      NUMBER;
l_receipt_date         DATE;

CURSOR get_receipt_details (p_ps_id  IN NUMBER ) IS
SELECT ps.amount_due_original,
       ps.trx_number, ps.customer_id, ps.customer_site_use_id,
       ps.invoice_currency_code,
       cr.reversal_category,
       cr.reversal_date,
       cr.receipt_date,
       sum(DECODE(ra.status,
           'UNAPP', nvl(ra.amount_applied_from,ra.amount_applied),
           'ACC', nvl(ra.amount_applied_from,ra.amount_applied),
           'OTHER ACC',nvl(ra.amount_applied_from,ra.amount_applied),
                             null)) unresolved_cash
FROM ar_payment_schedules ps,
     ar_cash_receipts cr,
     ar_cash_receipt_history crh,
     ar_receivable_applications ra
WHERE ps.payment_schedule_id = p_ps_id
  and ps.cash_receipt_id = cr.cash_receipt_id
  and crh.cash_receipt_id = cr.cash_receipt_id
  and crh.cash_receipt_history_id = ra.cash_receipt_history_id -- apandit
  and crh.status = 'REVERSED'
  and ra.cash_receipt_id = cr.cash_receipt_id
group by ps.amount_due_original,
       ps.trx_number, ps.customer_id, ps.customer_site_use_id,
       ps.invoice_currency_code,
       cr.reversal_category,
       cr.reversal_date,
       cr.receipt_date;

CURSOR is_this_last_payment (p_customer_id IN NUMBER,
                             p_site_use_id IN NUMBER,
                             p_currency    IN VARCHAR2,
                             p_pmt_number  IN VARCHAR2,
                             p_pmt_date    IN DATE,
                             p_org_id      IN NUMBER)IS
select 'Y'
from   ar_trx_bal_summary
where  cust_account_id = p_customer_id
  and  site_use_id = p_site_use_id
  and  currency = p_currency
  and  last_payment_number = p_pmt_number
  and  last_payment_date = p_pmt_date
  and  NVL(org_id,'-99') = NVL(p_org_id,-99);

CURSOR get_last_pmt (p_customer_id IN NUMBER,
                     p_site_use_id IN NUMBER,
                     p_currency    IN VARCHAR2) IS
select receipt_number, amount, receipt_date
from ar_cash_receipts
where cash_receipt_id =
     (select max(cr.cash_receipt_id)
      from ar_cash_receipts cr,
           ar_cash_receipt_history crh --apandit
      where cr.pay_from_customer = p_customer_id
        and cr.cash_receipt_id = crh.cash_receipt_id --apandit
        and crh.current_record_flag = 'Y'
        and crh.status <> 'REVERSED'
        and nvl(cr.customer_site_use_id,-99) = nvl(p_site_use_id, -99)
        and cr.currency_code = p_currency);

BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CashReceipt_Reverse(+)');
    END IF;
  l_payment_schedule_id := p_event.GetValueForParameter('PAYMENT_SCHEDULE_ID');
  l_cash_receipt_id     := p_event.GetValueForParameter('CASH_RECEIPT_ID');
  l_history_id          := p_event.GetValueForParameter('HISTORY_ID');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');
    IF pg_debug = 'Y'
    THEN
       debug ('l_payment_schedule_id= '||l_payment_schedule_id);
       debug ('l_cash_receipt_id= '||l_cash_receipt_id);
       debug ('l_history_id= '||l_history_id);
       debug ('l_org_id= '||l_org_id);
       debug ('l_user_id= '||l_user_id);
       debug ('l_resp_id= '||l_resp_id);
       debug ('l_application_id= '||l_application_id);
       debug ('l_security_gr_id= '||l_security_gr_id);
    END IF;
   SAVEPOINT  CR_Reverse;
   --
   --set the application context.
   --
  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
  mo_global.init('AR');
  mo_global.set_policy_context('S',l_org_id);

     UPDATE ar_trx_summary_hist
      set complete_flag = 'Y',
          LAST_UPDATE_DATE  = sysdate,
          LAST_UPDATED_BY   = FND_GLOBAL.user_id,
          LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
      WHERE payment_schedule_id = l_payment_schedule_id;

  OPEN get_receipt_details (l_payment_schedule_id);

  FETCH get_receipt_details
    INTO l_receipt_amount ,
         l_receipt_number ,
         l_customer_id,
         l_customer_site_use_id,
         l_currency_code,
         l_reversal_category,
         l_reversal_date,
         l_receipt_date,
         l_unresolved_cash;

  -- both l_receipt_amount and l_unresolved_cash have the -ve sign.

  CLOSE get_receipt_details;

 IF l_customer_id IS NOT NULL THEN

  OPEN is_this_last_payment (l_customer_id,
                             l_customer_site_use_id,
                             l_currency_code,
                             l_receipt_number,
                             l_receipt_date,
                             l_org_id);

   FETCH is_this_last_payment INTO is_last_payment;
     IF nvl(is_last_payment,'N') = 'Y' THEN
       OPEN get_last_pmt (l_customer_id,
                          l_customer_site_use_id,
                          l_currency_code);
        FETCH get_last_pmt INTO
                   l_last_receipt_number,
                   l_last_receipt_amount,
                   l_last_receipt_date;

       CLOSE get_last_pmt;
     END IF;

  CLOSE is_this_last_payment;

    --Update ar_trx_bal_summary
         UPDATE ar_trx_bal_summary
           set unresolved_cash_value = nvl(unresolved_cash_value,0) -
                                                               l_unresolved_cash,
               unresolved_cash_count = nvl(unresolved_cash_count,0) - 1,
               last_payment_amount = nvl(l_last_receipt_amount,last_payment_amount),
               last_payment_date = nvl(l_last_receipt_date,last_payment_date),
               last_payment_number = nvl(l_last_receipt_number,last_payment_number),
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         where cust_account_id = l_customer_id
           and site_use_id =  nvl(l_customer_site_use_id,-99)
           and NVL(org_id,'-99') = NVL(l_org_id,-99)
           and currency = l_currency_code;


    --Update ar_trx_summary
         UPDATE ar_trx_summary
           set total_cash_receipts_value = nvl(total_cash_receipts_value,0) -
                                                           nvl(l_receipt_amount,0),
               total_cash_receipts_count = nvl(total_cash_receipts_count,0) - 1,
               nsf_stop_payment_amount = nvl(nsf_stop_payment_amount,0)
                                                         - nvl(l_receipt_amount,0),
               nsf_stop_payment_count  = nvl(nsf_stop_payment_count,0) + 1,
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         where cust_account_id = l_customer_id
           and site_use_id = nvl(l_customer_site_use_id,-99)
           and NVL(org_id,'-99') = NVL(l_org_id,-99)
           and currency =   l_currency_code
           and as_of_date = l_reversal_date;

   END IF;

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CashReceipt_Reverse(-)');
    END IF;
  Return 'SUCCESS';
EXCEPTION
    WHEN OTHERS  THEN
     ROLLBACK TO CR_Reverse;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AR_BUS_EVENT_SUB_PVT', 'CashReceipt_Reverse', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';
END CashReceipt_Reverse;

FUNCTION CashReceipt_Modify
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS

l_cash_receipt_id  NUMBER;
l_receipt_date   DATE ;
l_receipt_amount  NUMBER;
l_receipt_number  VARCHAR2(30);
l_customer_id  NUMBER;
l_customer_site_use_id NUMBER;
l_currency_code VARCHAR2(30);

  l_payment_schedule_id NUMBER;
  l_org_id          NUMBER;
  l_user_id         NUMBER;
  l_resp_id         NUMBER;
  l_application_id  NUMBER;
  l_security_gr_id  NUMBER;

CURSOR get_receipt_details (p_ps_id  IN NUMBER ) IS
SELECT cash_receipt_id, trx_date, amount_due_original,
       trx_number, customer_id, customer_site_use_id,
       invoice_currency_code
FROM ar_payment_schedules ps
WHERE payment_schedule_id = p_ps_id;

CURSOR get_receipt_hist (p_hist_id  IN NUMBER) IS
 select *
 from ar_trx_summary_hist
 where history_id = p_hist_id
   and nvl(complete_flag ,'N') = 'N'
 for update;

CURSOR get_receipt_hist2 (p_hist_id  IN NUMBER) IS
 select ps.cash_receipt_id, ps.trx_date, hist.amount_due_original,
       ps.trx_number, hist.customer_id, hist.site_use_id,
       ps.invoice_currency_code
 from ar_trx_summary_hist hist,
      ar_payment_schedules ps
 where previous_history_id = p_hist_id
   and ps.payment_schedule_id = hist.payment_schedule_id;

l_hist_rec ar_trx_summary_hist%rowtype;
l_hist_rec2 ar_trx_summary_hist%rowtype;
l_receipt_exists   VARCHAR2(10);
l_history_id   NUMBER;
l_history2_exists_flag  VARCHAR2(1);
l_history_exists_flag   VARCHAR2(1);
BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CashReceipt_Modify(+)');
    END IF;
  l_payment_schedule_id := p_event.GetValueForParameter('PAYMENT_SCHEDULE_ID');
  l_history_id      := p_event.GetValueForParameter('HISTORY_ID');
  l_cash_receipt_id := p_event.GetValueForParameter('CASH_RECEIPT_ID');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');
    IF pg_debug = 'Y'
    THEN
       debug ('l_payment_schedule_id= '||l_payment_schedule_id);
       debug ('l_history_id= '||l_history_id);
       debug ('l_cash_receipt_id= '||l_cash_receipt_id);
       debug ('l_org_id= '||l_org_id);
       debug ('l_user_id= '||l_user_id);
       debug ('l_resp_id= '||l_resp_id);
       debug ('l_application_id= '||l_application_id);
       debug ('l_security_gr_id= '||l_security_gr_id);
    END IF;
   SAVEPOINT  CR_Modify;
   --
   --set the application context.
   --
  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
  mo_global.init('AR');
  mo_global.set_policy_context('S',l_org_id);

   OPEN get_receipt_hist(l_history_id);
    FETCH get_receipt_hist INTO l_hist_rec;

   IF get_receipt_hist%NOTFOUND THEN
    l_history_exists_flag  := 'N';
   ELSE
    l_history_exists_flag  := 'Y';
    OPEN get_receipt_hist2(l_history_id);

     FETCH get_receipt_hist2 INTO
                  l_cash_receipt_id ,
                  l_receipt_date ,
                  l_receipt_amount ,
                  l_receipt_number ,
                  l_customer_id ,
                  l_customer_site_use_id ,
                  l_currency_code ;

     IF get_receipt_hist2%notfound THEN
       --get the data from the
        l_history2_exists_flag := 'N';
         OPEN get_receipt_details (l_payment_schedule_id);

          FETCH get_receipt_details
             INTO l_cash_receipt_id ,
         	  l_receipt_date ,
       		  l_receipt_amount ,
              l_receipt_number ,
         	  l_customer_id ,
        	  l_customer_site_use_id ,
       		  l_currency_code ;

            IF get_receipt_details%NOTFOUND THEN
               null;
              l_receipt_exists := 'N';
            ELSE
              l_receipt_exists := 'Y';
            END IF;

         CLOSE get_receipt_details;
     ELSE
        l_history2_exists_flag := 'Y';
     END IF;

    CLOSE get_receipt_hist2;

   END IF;
  CLOSE get_receipt_hist;

     UPDATE ar_trx_summary_hist
      set complete_flag = 'Y',
          LAST_UPDATE_DATE  = sysdate,
          LAST_UPDATED_BY   = FND_GLOBAL.user_id,
          LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
      WHERE history_id  = l_history_id
       and  nvl(complete_flag ,'N') = 'N';


  IF (l_history_exists_flag = 'Y') AND
      ((l_history2_exists_flag = 'Y') OR (l_receipt_exists = 'Y'))
    THEN

    IF l_customer_id =  l_hist_rec.customer_id THEN
    --Update ar_trx_bal_summary
         UPDATE ar_trx_bal_summary
           set unresolved_cash_value = nvl(unresolved_cash_value,0) +
                                                 (l_receipt_amount - nvl(l_hist_rec.amount_due_original,0)),
               unresolved_cash_count = nvl(unresolved_cash_count,0),
			   last_payment_amount =  l_receipt_amount,
			   last_payment_date = l_receipt_date,
			   last_payment_number = l_receipt_number,
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         where cust_account_id = l_customer_id
           and site_use_id =  nvl(l_customer_site_use_id,-99)
           and NVL(org_id,'-99') = NVL(l_org_id,-99)
           and currency = l_currency_code;

         IF sql%notfound then
             INSERT INTO  ar_trx_bal_summary
               (CUST_ACCOUNT_ID,
                SITE_USE_ID,
                ORG_ID,
                CURRENCY,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                unresolved_cash_value,
                unresolved_cash_count,
                last_payment_amount,
                last_payment_date,
                last_payment_number
               )VALUES
               (l_customer_id,
                nvl(l_customer_site_use_id,-99),
                l_org_id,
                l_currency_code,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                fnd_global.login_id,
                (l_receipt_amount - nvl(l_hist_rec.amount_due_original,0)),
                1,
                (l_receipt_amount - nvl(l_hist_rec.amount_due_original,0)),
                l_receipt_date,
                l_receipt_number
                );
           END IF;



    --Update ar_trx_summary
         UPDATE ar_trx_summary
           set total_cash_receipts_value = nvl(total_cash_receipts_value,0) +
                                             (l_receipt_amount - nvl(l_hist_rec.amount_due_original,0)),
               total_cash_receipts_count = nvl(total_cash_receipts_count,0),
              LAST_UPDATE_DATE  = sysdate,
              LAST_UPDATED_BY   = FND_GLOBAL.user_id,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         where cust_account_id = l_customer_id
           and site_use_id = nvl(l_customer_site_use_id,-99)
           and NVL(org_id,'-99') = NVL(l_org_id,-99)
           and currency =   l_currency_code
           and as_of_date = l_receipt_date;


         IF sql%notfound then
             INSERT INTO ar_trx_summary
               (CUST_ACCOUNT_ID,
                SITE_USE_ID,
                ORG_ID,
                CURRENCY,
                AS_OF_DATE,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                total_cash_receipts_value,
                total_cash_receipts_count
                ) VALUES
               (l_customer_id,
                nvl(l_customer_site_use_id,-99),
                l_org_id,
                l_currency_code,
                l_receipt_date,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                fnd_global.login_id,
                (l_receipt_amount - nvl(l_hist_rec.amount_due_original,0)),
                1);

           END IF;
     ELSIF l_customer_id IS NULL AND  l_hist_rec.customer_id IS NOT NULL THEN
             --Update ar_trx_bal_summary
         UPDATE ar_trx_bal_summary
           set unresolved_cash_value = nvl(unresolved_cash_value,0)
                                               - nvl(l_hist_rec.amount_due_original,0),
               unresolved_cash_count = nvl(unresolved_cash_count,0) -1,
               last_payment_amount =  nvl(l_hist_rec.amount_due_original,0),
	       last_payment_date = l_receipt_date,
	       last_payment_number = l_receipt_number,
               LAST_UPDATE_DATE  = sysdate,
               LAST_UPDATED_BY   = FND_GLOBAL.user_id,
               LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         where cust_account_id = l_hist_rec.customer_id
           and site_use_id =  nvl(l_hist_rec.site_use_id,-99)
           and NVL(org_id,'-99') = NVL(l_org_id,-99)
           and currency = l_currency_code;

         IF sql%notfound then
             INSERT INTO  ar_trx_bal_summary
               (CUST_ACCOUNT_ID,
                SITE_USE_ID,
                ORG_ID,
                CURRENCY,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                unresolved_cash_value,
                unresolved_cash_count,
                last_payment_amount,
                last_payment_date,
                last_payment_number
               )VALUES
               (l_hist_rec.customer_id,
                nvl(l_hist_rec.site_use_id,-99),
                l_org_id,
                l_currency_code,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                fnd_global.login_id,
                l_hist_rec.amount_due_original,
                1,
                l_hist_rec.amount_due_original,
                l_receipt_date,
                l_receipt_number
                );
           END IF;

    --Update ar_trx_summary
         UPDATE ar_trx_summary
           set total_cash_receipts_value = nvl(total_cash_receipts_value,0)
                                                 - nvl(l_hist_rec.amount_due_original,0) ,
               total_cash_receipts_count = nvl(total_cash_receipts_count,0) -1,
               LAST_UPDATE_DATE  = sysdate,
               LAST_UPDATED_BY   = FND_GLOBAL.user_id,
               LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         where cust_account_id = l_hist_rec.customer_id
           and site_use_id = nvl(l_hist_rec.site_use_id,-99)
           and NVL(org_id,'-99') = NVL(l_org_id,-99)
           and currency =   l_currency_code
           and as_of_date = l_receipt_date;

          IF sql%notfound then
             INSERT INTO ar_trx_summary
               (CUST_ACCOUNT_ID,
                SITE_USE_ID,
                ORG_ID,
                CURRENCY,
                AS_OF_DATE,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                total_cash_receipts_value,
                total_cash_receipts_count
                ) VALUES
               (l_hist_rec.customer_id,
                nvl(l_hist_rec.site_use_id,-99),
                l_org_id,
                l_currency_code,
                l_receipt_date,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                fnd_global.login_id,
                l_hist_rec.amount_due_original,
                1);
 		END IF;
     ELSIF l_customer_id IS NOT NULL AND  l_hist_rec.customer_id IS  NULL THEN
             --Update ar_trx_bal_summary
         UPDATE ar_trx_bal_summary
           set unresolved_cash_value = nvl(unresolved_cash_value,0)
                                               +l_receipt_amount ,
               unresolved_cash_count = nvl(unresolved_cash_count,0) +1,
               last_payment_amount =  l_receipt_amount,
	       last_payment_date = l_receipt_date,
	       last_payment_number = l_receipt_number,
               LAST_UPDATE_DATE  = sysdate,
               LAST_UPDATED_BY   = FND_GLOBAL.user_id,
               LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         where cust_account_id = l_customer_id
           and site_use_id =  nvl(l_customer_site_use_id,-99)
           and NVL(org_id,'-99') = NVL(l_org_id,-99)
           and currency = l_currency_code;

         IF sql%notfound then
             INSERT INTO  ar_trx_bal_summary
               (CUST_ACCOUNT_ID,
                SITE_USE_ID,
                ORG_ID,
                CURRENCY,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                unresolved_cash_value,
                unresolved_cash_count,
                last_payment_amount,
                last_payment_date,
                last_payment_number
               )VALUES
               (l_customer_id,
                nvl(l_customer_site_use_id,-99),
                l_org_id,
                l_currency_code,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                fnd_global.login_id,
                l_receipt_amount,
                1,
                l_receipt_amount,
                l_receipt_date,
                l_receipt_number
                );
           END IF;

    --Update ar_trx_summary
         UPDATE ar_trx_summary
           set total_cash_receipts_value = nvl(total_cash_receipts_value,0)
                                                 + l_receipt_amount ,
               total_cash_receipts_count = nvl(total_cash_receipts_count,0)+1,
               LAST_UPDATE_DATE  = sysdate,
               LAST_UPDATED_BY   = FND_GLOBAL.user_id,
               LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         where cust_account_id = l_customer_id
           and site_use_id = nvl(l_customer_site_use_id,-99)
           and NVL(org_id,'-99') = NVL(l_org_id,-99)
           and currency =   l_currency_code
           and as_of_date = l_receipt_date;

         IF sql%notfound then
             INSERT INTO ar_trx_summary
               (CUST_ACCOUNT_ID,
                SITE_USE_ID,
                ORG_ID,
                CURRENCY,
                AS_OF_DATE,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                total_cash_receipts_value,
                total_cash_receipts_count
                ) VALUES
               (l_customer_id,
                nvl(l_customer_site_use_id,-99),
                l_org_id,
                l_currency_code,
                l_receipt_date,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                fnd_global.login_id,
                l_receipt_amount,
                1);
 		END IF;
     ELSIF nvl(l_customer_id,0) <> nvl(l_hist_rec.customer_id,0)  THEN

      --Update ar_trx_bal_summary
         UPDATE ar_trx_bal_summary
           set unresolved_cash_value = nvl(unresolved_cash_value,0)
                                               - nvl(l_hist_rec.amount_due_original,0),
               unresolved_cash_count = nvl(unresolved_cash_count,0) -1,
               last_payment_amount =  nvl(l_hist_rec.amount_due_original,0),
			   last_payment_date = l_receipt_date,
			   last_payment_number = l_receipt_number,
               LAST_UPDATE_DATE  = sysdate,
               LAST_UPDATED_BY   = FND_GLOBAL.user_id,
               LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         where cust_account_id = l_hist_rec.customer_id
           and site_use_id =  nvl(l_hist_rec.site_use_id,-99)
           and NVL(org_id,'-99') = NVL(l_org_id,-99)
           and currency = l_currency_code;

          IF sql%notfound then
             INSERT INTO  ar_trx_bal_summary
               (CUST_ACCOUNT_ID,
                SITE_USE_ID,
                ORG_ID,
                CURRENCY,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                unresolved_cash_value,
                unresolved_cash_count,
                last_payment_amount,
                last_payment_date,
                last_payment_number
               )VALUES
               (l_hist_rec.customer_id,
                nvl(l_hist_rec.site_use_id,-99),
                l_org_id,
                l_currency_code,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                fnd_global.login_id,
                l_hist_rec.amount_due_original,
                1,
                l_hist_rec.amount_due_original,
                l_receipt_date,
                l_receipt_number
                );
           END IF;

     --Update ar_trx_summary
         UPDATE ar_trx_summary
           set total_cash_receipts_value = nvl(total_cash_receipts_value,0)
                                                 - nvl(l_hist_rec.amount_due_original,0) ,
               total_cash_receipts_count = nvl(total_cash_receipts_count,0),
               LAST_UPDATE_DATE  = sysdate,
               LAST_UPDATED_BY   = FND_GLOBAL.user_id,
               LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         where cust_account_id = l_hist_rec.customer_id
           and site_use_id = nvl(l_hist_rec.site_use_id,-99)
           and NVL(org_id,'-99') = NVL(l_org_id,-99)
           and currency =   l_currency_code
           and as_of_date = l_receipt_date;

          IF sql%notfound then
             INSERT INTO ar_trx_summary
               (CUST_ACCOUNT_ID,
                SITE_USE_ID,
                ORG_ID,
                CURRENCY,
                AS_OF_DATE,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                total_cash_receipts_value,
                total_cash_receipts_count
                ) VALUES
               (l_hist_rec.customer_id,
                nvl(l_hist_rec.site_use_id,-99),
                l_org_id,
                l_currency_code,
                l_receipt_date,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                fnd_global.login_id,
                l_hist_rec.amount_due_original,
                1);
 		END IF;

      --Update ar_trx_bal_summary
         UPDATE ar_trx_bal_summary
           set unresolved_cash_value = nvl(unresolved_cash_value,0)
                                               +l_receipt_amount ,
               unresolved_cash_count = nvl(unresolved_cash_count,0)+1,
               last_payment_amount =  l_receipt_amount,
			   last_payment_date = l_receipt_date,
			   last_payment_number = l_receipt_number,
               LAST_UPDATE_DATE  = sysdate,
               LAST_UPDATED_BY   = FND_GLOBAL.user_id,
               LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         where cust_account_id = l_customer_id
           and site_use_id =  nvl(l_customer_site_use_id,-99)
           and NVL(org_id,'-99') = NVL(l_org_id,-99)
           and currency = l_currency_code;

         IF sql%notfound then
             INSERT INTO  ar_trx_bal_summary
               (CUST_ACCOUNT_ID,
                SITE_USE_ID,
                ORG_ID,
                CURRENCY,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                unresolved_cash_value,
                unresolved_cash_count,
                last_payment_amount,
                last_payment_date,
                last_payment_number
               )VALUES
               (l_customer_id,
                nvl(l_customer_site_use_id,-99),
                l_org_id,
                l_currency_code,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                fnd_global.login_id,
                l_receipt_amount,
                1,
                l_receipt_amount,
                l_receipt_date,
                l_receipt_number
                );
           END IF;


    --Update ar_trx_summary
         UPDATE ar_trx_summary
           set total_cash_receipts_value = nvl(total_cash_receipts_value,0)
                                                 + l_receipt_amount ,
               total_cash_receipts_count = nvl(total_cash_receipts_count,0)+1,
               LAST_UPDATE_DATE  = sysdate,
               LAST_UPDATED_BY   = FND_GLOBAL.user_id,
               LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         where cust_account_id = l_customer_id
           and site_use_id = nvl(l_customer_site_use_id,-99)
           and NVL(org_id,'-99') = NVL(l_org_id,-99)
           and currency =   l_currency_code
           and as_of_date = l_receipt_date;

         IF sql%notfound then
             INSERT INTO ar_trx_summary
               (CUST_ACCOUNT_ID,
                SITE_USE_ID,
                ORG_ID,
                CURRENCY,
                AS_OF_DATE,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                total_cash_receipts_value,
                total_cash_receipts_count
                ) VALUES
               (l_customer_id,
                nvl(l_customer_site_use_id,-99),
                l_org_id,
                l_currency_code,
                l_receipt_date,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                fnd_global.login_id,
                l_receipt_amount ,
                1);
 		END IF;

     END IF;

  END IF;
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CashReceipt_Modify(-)');
    END IF;

  Return 'SUCCESS';
EXCEPTION
    WHEN OTHERS  THEN
     ROLLBACK TO CR_Modify;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AR_BUS_EVENT_SUB_PVT', 'CashReceipt_Modify', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

END CashReceipt_Modify;

FUNCTION CashReceipt_Approve
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS

BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CashReceipt_Approve(+)');
    END IF;
  Return 'SUCCESS';
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CashReceipt_Approve(-)');
    END IF;
END CashReceipt_Approve;

FUNCTION CashReceipt_Confirm
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS

BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CashReceipt_Confirm(+)');
    END IF;
  Return 'SUCCESS';
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CashReceipt_Confirm(-)');
    END IF;
END CashReceipt_Confirm;

FUNCTION CashReceipt_Unconfirm
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS

BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CashReceipt_Unconfirm(+)');
    END IF;
  Return 'SUCCESS';
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CashReceipt_Unconfirm(-)');
    END IF;
END CashReceipt_Unconfirm;

FUNCTION CashReceipt_DMReversal
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS

BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CashReceipt_DMReversal(+)');
    END IF;
  Return 'SUCCESS';
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CashReceipt_DMReversal(-)');
    END IF;
END CashReceipt_DMReversal;

/* Bug 4173339 */
FUNCTION CashReceipt_Delete
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2
IS
CURSOR hist(ps_id in number) IS
	SELECT *
	  FROM ar_trx_summary_hist
	 WHERE payment_schedule_id = ps_id;

CURSOR is_this_last_payment (p_customer_id IN NUMBER,
                             p_site_use_id IN NUMBER,
                             p_currency    IN VARCHAR2,
                             p_pmt_number  IN VARCHAR2,
                             p_pmt_date    IN DATE,
                             p_org_id      IN NUMBER) IS
        SELECT 'Y'
         FROM  ar_trx_bal_summary
        WHERE  cust_account_id = p_customer_id
          AND  site_use_id = p_site_use_id
          AND  currency = p_currency
          AND  last_payment_number = p_pmt_number
          AND  last_payment_date = p_pmt_date
          AND  NVL(org_id,'-99') = NVL(p_org_id,-99);

CURSOR get_last_pmt (p_customer_id IN NUMBER,
                     p_site_use_id IN NUMBER,
                     p_currency    IN VARCHAR2) IS
	SELECT receipt_number, amount, receipt_date
	  FROM ar_cash_receipts
	 WHERE cash_receipt_id =
	        (SELECT MAX(cr.cash_receipt_id)
	         FROM ar_cash_receipts cr,
       	              ar_cash_receipt_history crh
	         WHERE cr.pay_from_customer = p_customer_id
        	   AND cr.cash_receipt_id = crh.cash_receipt_id
        	   AND crh.current_record_flag = 'Y'
        	   AND crh.status <> 'REVERSED'
        	   AND NVL(cr.customer_site_use_id,-99) = NVL(p_site_use_id, -99)
        	   AND cr.currency_code = p_currency
		);

l_cash_receipt_id  	NUMBER;
l_receipt_date   	DATE ;
l_receipt_amount  	NUMBER;
l_receipt_number  	VARCHAR2(30);
l_customer_id  		NUMBER;
l_customer_site_use_id 	NUMBER;
l_currency_code 	VARCHAR2(30);
is_last_payment        	VARCHAR2(1);
l_last_receipt_number	VARCHAR2(30);
l_last_receipt_amount	NUMBER;
l_last_receipt_date     DATE;
l_payment_schedule_id 	NUMBER;
l_org_id          	NUMBER;
l_user_id         	NUMBER;
l_resp_id         	NUMBER;
l_application_id  	NUMBER;
l_security_gr_id  	NUMBER;
l_deletion_date   	DATE;

BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CashReceipt_Delete(+)');
    END IF;
   l_payment_schedule_id := p_event.GetValueForParameter('PAYMENT_SCHEDULE_ID');
   l_cash_receipt_id     := p_event.GetValueForParameter('CASH_RECEIPT_ID');
   l_receipt_number      := p_event.GetValueForParameter('RECEIPT_NUMBER');
   l_receipt_date        := p_event.GetValueForParameter('RECEIPT_DATE');
   l_deletion_date       := p_event.GetValueForParameter('DELETION_DATE');
   -- l_history_id          := p_event.GetValueForParameter('HISTORY_ID');
   l_org_id          := p_event.GetValueForParameter('ORG_ID');
   l_user_id         := p_event.GetValueForParameter('USER_ID');
   l_resp_id         := p_event.GetValueForParameter('RESP_ID');
   l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
   l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');

    IF pg_debug = 'Y'
    THEN
       debug ('l_payment_schedule_id= '||l_payment_schedule_id);
       debug ('l_cash_receipt_id= '||l_cash_receipt_id);
       debug ('l_receipt_number= '||l_receipt_number);
       debug ('l_receipt_date= '||l_receipt_date);
       debug ('l_deletion_date= '||l_deletion_date);
       debug ('l_org_id= '||l_org_id);
       debug ('l_user_id= '||l_user_id);
       debug ('l_resp_id= '||l_resp_id);
       debug ('l_application_id= '||l_application_id);
       debug ('l_security_gr_id= '||l_security_gr_id);
    END IF;
   SAVEPOINT  CR_Delete;
   --
   --set the application context.
   --
   fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
   mo_global.init('AR');
   mo_global.set_policy_context('S',l_org_id);

   UPDATE ar_trx_summary_hist
      SET complete_flag = 'Y',
          LAST_UPDATE_DATE  = sysdate,
          LAST_UPDATED_BY   = FND_GLOBAL.user_id,
          LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
    WHERE payment_schedule_id = l_payment_schedule_id;

   FOR k IN hist(l_payment_schedule_id) LOOP
      IF k.customer_id IS NOT NULL THEN

         OPEN is_this_last_payment (k.customer_id,
                                    k.site_use_id,
                                    k.currency_code,
                                    l_receipt_number,
                                    l_receipt_date,
                                    l_org_id);

         FETCH is_this_last_payment INTO is_last_payment;

         IF NVL(is_last_payment,'N') = 'Y' THEN

            OPEN get_last_pmt (k.customer_id,
                          k.site_use_id,
                          k.currency_code);
            FETCH get_last_pmt INTO
                   l_last_receipt_number,
                   l_last_receipt_amount,
                   l_last_receipt_date;

            CLOSE get_last_pmt;
         END IF;

         CLOSE is_this_last_payment;

         --Update ar_trx_bal_summary
         UPDATE ar_trx_bal_summary
            SET unresolved_cash_value = NVL(unresolved_cash_value,0) -
                                                               NVL(k.amount_due_original,0),
                unresolved_cash_count = NVL(unresolved_cash_count,0) - 1,
                last_payment_amount = NVL(l_last_receipt_amount,last_payment_amount),
                last_payment_date = NVL(l_last_receipt_date,last_payment_date),
                last_payment_number = NVL(l_last_receipt_number,last_payment_number),
                LAST_UPDATE_DATE  = sysdate,
                LAST_UPDATED_BY   = FND_GLOBAL.user_id,
                LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
          WHERE cust_account_id = k.customer_id
            AND site_use_id =  nvl(k.site_use_id,-99)
            AND NVL(org_id,'-99') = NVL(l_org_id,-99)
            AND currency = k.currency_code;


         --Update ar_trx_summary
         UPDATE ar_trx_summary
           SET  total_cash_receipts_value = nvl(total_cash_receipts_value,0) -
                                                           nvl(k.amount_due_original,0),
                total_cash_receipts_count = nvl(total_cash_receipts_count,0) - 1,
                LAST_UPDATE_DATE  = sysdate,
                LAST_UPDATED_BY   = FND_GLOBAL.user_id,
                LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE cust_account_id = k.customer_id
           AND site_use_id = nvl(k.site_use_id,-99)
           AND NVL(org_id,'-99') = NVL(l_org_id,-99)
           AND currency =   k.currency_code
           AND as_of_date = l_deletion_date;
      END IF;
   END LOOP;

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CashReceipt_Delete(-)');
    END IF;
   RETURN 'SUCCESS';
EXCEPTION
    WHEN OTHERS  THEN
     ROLLBACK TO CR_Delete;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AR_BUS_EVENT_SUB_PVT', 'CashReceipt_Delete', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';
END CashReceipt_Delete;

FUNCTION CreditMemoApp_Apply
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS
CURSOR get_recapp_details (p_ra_id  IN NUMBER ) IS
SELECT trx_ps.customer_id,
       trx_ps.customer_site_use_id,
       trx_ps.invoice_currency_code,
       trx_ps.class,
       ra.amount_applied,
       rcpt_ps.customer_id,
       rcpt_ps.customer_site_use_id,
       rcpt_ps.invoice_currency_code,
       nvl(ra.amount_applied_from,ra.amount_applied),
       ra.apply_date
FROM  ar_payment_schedules trx_ps,
      ar_receivable_applications ra,
      ar_payment_schedules rcpt_ps
WHERE ra.receivable_application_id = p_ra_id
and   ra.status in ('APP')
and   ra.payment_schedule_id = rcpt_ps.payment_schedule_id
and   ra.applied_payment_schedule_id = trx_ps.payment_schedule_id
;
  l_org_id          NUMBER;
  l_user_id         NUMBER;
  l_resp_id         NUMBER;
  l_application_id  NUMBER;
  l_security_gr_id  NUMBER;
  l_receivable_application_id  NUMBER;
  l_trx_customer_id     NUMBER;
  l_trx_site_use_id     NUMBER;
  l_trx_currency_code   VARCHAR2(30);
  l_trx_amt             NUMBER;
  l_trx_due_date        DATE;
  l_cm_customer_id      NUMBER;
  l_cm_site_use_id      NUMBER;
  l_cm_currency_code    VARCHAR2(30);
  l_cm_amt              NUMBER;
  l_apply_date          DATE;
  l_op_trx_count        NUMBER;
  l_trx_ado             NUMBER;
  l_trx_app_amt         NUMBER;
  l_trx_class           VARCHAR2(10);
  l_trx_ps_status       VARCHAR2(10);
  l_cm_ps_status        VARCHAR2(10);
  l_due_date_str        VARCHAR2(30);
  l_op_cm_count         NUMBER;
  l_past_due_inv_value       NUMBER;
  l_past_due_inv_inst_count  NUMBER;

BEGIN
  SAVEPOINT  CM_Apply_Event;

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CreditMemoApp_Apply(+)');
    END IF;
  l_receivable_application_id :=
                  p_event.GetValueForParameter('RECEIVABLE_APPLICATION_ID');
  l_trx_ps_status      := p_event.GetValueForParameter('TRX_PS_STATUS');
  l_cm_ps_status  := p_event.GetValueForParameter('CM_PS_STATUS');
  l_due_date_str    := p_event.GetValueForParameter('TRX_DUE_DATE');
  l_trx_app_amt     := fnd_number.canonical_to_number(p_event.GetValueForParameter('TRX_APP_AMT'));
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');

    IF pg_debug = 'Y'
    THEN
       debug ('l_receivable_application_id= '||l_receivable_application_id);
       debug ('l_trx_ps_status= '||l_trx_ps_status);
       debug ('l_cm_ps_status= '||l_cm_ps_status);
       debug ('l_due_date_str= '||l_due_date_str);
       debug ('l_trx_app_amt= '||l_trx_app_amt);
       debug ('l_org_id= '||l_org_id);
       debug ('l_user_id= '||l_user_id);
       debug ('l_resp_id= '||l_resp_id);
       debug ('l_application_id= '||l_application_id);
       debug ('l_security_gr_id= '||l_security_gr_id);
    END IF;
   --
   --set the application context.
   --
   fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
   mo_global.init('AR');
   mo_global.set_policy_context('S',l_org_id);

   select to_date(l_due_date_str, 'J')
   into  l_trx_due_date
   from dual;

   OPEN get_recapp_details(l_receivable_application_id);

     FETCH get_recapp_details INTO  l_trx_customer_id,
                                    l_trx_site_use_id,
                                    l_trx_currency_code,
                                    l_trx_class,
                                    l_trx_amt ,
                                    l_cm_customer_id ,
                                    l_cm_site_use_id ,
                                    l_cm_currency_code,
                                    l_cm_amt,
                                    l_apply_date
                                    ;
	IF get_recapp_details%NOTFOUND THEN
	 CLOSE get_recapp_details;
         Return 'SUCCESS';
        END IF;

      IF  l_cm_ps_status = 'CL' THEN
        l_op_cm_count := 1;
      END IF;

      IF l_trx_ps_status = 'CL' THEN
       l_op_trx_count := 1;
      END IF;

      IF l_trx_class = 'INV' THEN

        IF  l_trx_due_date < sysdate THEN

             l_past_due_inv_value := l_trx_app_amt;
             IF l_trx_ps_status = 'CL' THEN
               l_past_due_inv_inst_count := 1;
             END IF;
        END IF;

      END IF;

      /*****************************************************************
        Columns that need to be updated in the summary tables due to a
        credit memo application
        AR_TRX_SUMMARY
        ==================

        AR_TRX_BAL_SUMMARY
        ==================
        1) OP_INVOICES_VALUE
        2) OP_INVOICES_COUNT
        3) OP_DEBIT_MEMOS_VALUE
        4) OP_DEBIT_MEMOS_COUNT
        5) OP_DEPOSITS_VALUE
        6) OP_DEPOSITS_COUNT
        7) OP_CHARGEBACK_VALUE
        8) OP_CHARGEBACK_COUNT
        9) OP_CREDIT_MEMOS_VALUE
        10)OP_CREDIT_MEMOS_COUNT
        11)PAST_DUE_INV_VALUE
        12)PAST_DUE_INV_INST_COUNT

        *****************************************************************/

        Update_recapp_info(l_trx_class,
                           l_trx_customer_id,
                           l_trx_site_use_id,
                           l_trx_currency_code,
                           l_trx_amt,
                           l_op_trx_count,
                           l_cm_customer_id ,
                           l_cm_site_use_id ,
                           l_cm_currency_code,
                           l_cm_amt,
                           l_apply_date ,
                           null, --l_edisc_value,
                           null, --l_edisc_count,
                           null, --l_uedisc_value,
                           null, --l_uedisc_count,
                           null, --l_inv_paid_amt,
                           null, --l_inv_inst_pmt_days_sum,
                           null, --l_sum_app_amt_days_late,
                           null, --l_sum_app_amt,
                           null, --l_count_of_tot_inv_inst_paid,
                           null, --l_count_of_inv_inst_paid_late,
                           null, --l_count_of_disc_inv_inst,
                           null, --l_unresolved_cash_value,
                           null, --l_unresolved_cash_count,
                           l_op_cm_count,
                           'CM',
                           l_past_due_inv_value,
                           l_past_due_inv_inst_count,
                           l_org_id
                           );

     --
   CLOSE get_recapp_details;
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CreditMemoApp_Apply(-)');
    END IF;
  Return 'SUCCESS';
EXCEPTION
    WHEN OTHERS  THEN
     ROLLBACK TO CM_Apply_Event;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AR_BUS_EVENT_SUB_PVT', 'CREDITMEMOAPP_APPLY', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

END CreditMemoApp_Apply;


FUNCTION CreditMemoApp_UnApply
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS

CURSOR get_recapp_details (p_ra_id  IN NUMBER ) IS
SELECT trx_ps.customer_id,
       trx_ps.customer_site_use_id,
       trx_ps.invoice_currency_code,
       trx_ps.class,
       ra.amount_applied,
       rcpt_ps.customer_id,
       rcpt_ps.customer_site_use_id,
       rcpt_ps.invoice_currency_code,
       nvl(ra.amount_applied_from,ra.amount_applied),
       ra.apply_date
FROM  ar_payment_schedules trx_ps,
      ar_receivable_applications ra,
      ar_payment_schedules rcpt_ps
WHERE ra.receivable_application_id = p_ra_id
and   ra.status in ('APP')
and   ra.payment_schedule_id = rcpt_ps.payment_schedule_id
and   ra.applied_payment_schedule_id = trx_ps.payment_schedule_id
;
  l_org_id          NUMBER;
  l_user_id         NUMBER;
  l_resp_id         NUMBER;
  l_application_id  NUMBER;
  l_security_gr_id  NUMBER;
  l_receivable_application_id  NUMBER;
  l_trx_customer_id     NUMBER;
  l_trx_site_use_id     NUMBER;
  l_trx_currency_code   VARCHAR2(30);
  l_trx_amt             NUMBER;
  l_trx_due_date        DATE;
  l_cm_customer_id      NUMBER;
  l_cm_site_use_id      NUMBER;
  l_cm_currency_code    VARCHAR2(30);
  l_cm_amt              NUMBER;
  l_apply_date          DATE;
  l_op_trx_count        NUMBER;
  l_trx_ado             NUMBER;
  l_trx_app_amt         NUMBER;
  l_trx_class           VARCHAR2(10);
  l_trx_ps_status       VARCHAR2(10);
  l_cm_ps_status        VARCHAR2(10);
  l_due_date_str        VARCHAR2(30);
  l_op_cm_count         NUMBER;
  l_past_due_inv_value       NUMBER;
  l_past_due_inv_inst_count  NUMBER;

BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CreditMemoApp_UnApply(+)');
    END IF;
  l_receivable_application_id :=
                  p_event.GetValueForParameter('RECEIVABLE_APPLICATION_ID');
  l_trx_ps_status      := p_event.GetValueForParameter('TRX_PS_STATUS');
  l_cm_ps_status  := p_event.GetValueForParameter('CM_PS_STATUS');
  l_due_date_str    := p_event.GetValueForParameter('TRX_DUE_DATE');
  l_trx_app_amt     := fnd_number.canonical_to_number(p_event.GetValueForParameter('TRX_APP_AMT'));
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');
    IF pg_debug = 'Y'
    THEN
       debug ('l_receivable_application_id= '||l_receivable_application_id);
       debug ('l_trx_ps_status= '||l_trx_ps_status);
       debug ('l_cm_ps_status= '||l_cm_ps_status);
       debug ('l_due_date_str= '||l_due_date_str);
       debug ('l_trx_app_amt= '||l_trx_app_amt);
       debug ('l_org_id= '||l_org_id);
       debug ('l_user_id= '||l_user_id);
       debug ('l_resp_id= '||l_resp_id);
       debug ('l_application_id= '||l_application_id);
       debug ('l_security_gr_id= '||l_security_gr_id);
    END IF;

   SAVEPOINT  CM_UnApply_Event;
   --
   --set the application context.
   --
   fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
   mo_global.init('AR');
   mo_global.set_policy_context('S',l_org_id);

   select to_date(l_due_date_str, 'J')
   into  l_trx_due_date
   from dual;

   OPEN get_recapp_details(l_receivable_application_id);

     FETCH get_recapp_details INTO  l_trx_customer_id,
                                    l_trx_site_use_id,
                                    l_trx_currency_code,
                                    l_trx_class,
                                    l_trx_amt ,
                                    l_cm_customer_id ,
                                    l_cm_site_use_id ,
                                    l_cm_currency_code,
                                    l_cm_amt,
                                    l_apply_date
                                    ;
	IF get_recapp_details%NOTFOUND THEN
         CLOSE get_recapp_details;
         Return 'SUCCESS';
        END IF;
      IF  l_cm_ps_status = 'CL' THEN
        l_op_cm_count := -1;
      END IF;

      IF l_trx_ps_status = 'CL' THEN
       l_op_trx_count := -1;
      END IF;

      IF l_trx_class = 'INV' THEN

        IF  l_trx_due_date < sysdate THEN

             l_past_due_inv_value := l_trx_app_amt;
             IF l_trx_ps_status = 'CL' THEN
               l_past_due_inv_inst_count := -1;
             END IF;
        END IF;

      END IF;

      /*****************************************************************
        Columns that need to be updated in the summary tables due to a
        credit memo application
        AR_TRX_SUMMARY
        ==================

        AR_TRX_BAL_SUMMARY
        ==================
        1) OP_INVOICES_VALUE
        2) OP_INVOICES_COUNT
        3) OP_DEBIT_MEMOS_VALUE
        4) OP_DEBIT_MEMOS_COUNT
        5) OP_DEPOSITS_VALUE
        6) OP_DEPOSITS_COUNT
        7) OP_CHARGEBACK_VALUE
        8) OP_CHARGEBACK_COUNT
        9) OP_CREDIT_MEMOS_VALUE
        10)OP_CREDIT_MEMOS_COUNT
        11)PAST_DUE_INV_VALUE
        12)PAST_DUE_INV_INST_COUNT

        *****************************************************************/

        Update_recapp_info(l_trx_class,
                           l_trx_customer_id,
                           l_trx_site_use_id,
                           l_trx_currency_code,
                           l_trx_amt,
                           l_op_trx_count,
                           l_cm_customer_id ,
                           l_cm_site_use_id ,
                           l_cm_currency_code,
                           l_cm_amt,
                           l_apply_date ,
                           null, --l_edisc_value,
                           null, --l_edisc_count,
                           null, --l_uedisc_value,
                           null, --l_uedisc_count,
                           null, --l_inv_paid_amt,
                           null, --l_inv_inst_pmt_days_sum,
                           null, --l_sum_app_amt_days_late,
                           null, --l_sum_app_amt,
                           null, --l_count_of_tot_inv_inst_paid,
                           null, --l_count_of_inv_inst_paid_late,
                           null, --l_count_of_disc_inv_inst,
                           null, --l_unresolved_cash_value,
                           null, --l_unresolved_cash_count,
                           l_op_cm_count,
                           'CM',
                           l_past_due_inv_value,
                           l_past_due_inv_inst_count,
                           l_org_id
                           );

     --
   CLOSE get_recapp_details;
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CreditMemoApp_UnApply(-)');
    END IF;
  Return 'SUCCESS';
EXCEPTION
    WHEN OTHERS  THEN
     ROLLBACK TO CM_UnApply_Event;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AR_BUS_EVENT_SUB_PVT', 'CREDITMEMOAPP_UNAPPLY', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

END CreditMemoApp_UnApply;

FUNCTION CashApp_Apply
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS

  l_org_id          NUMBER;
  l_user_id         NUMBER;
  l_resp_id         NUMBER;
  l_application_id  NUMBER;
  l_security_gr_id  NUMBER;

CURSOR get_recapp_details (ra_id  IN NUMBER ) IS
SELECT trx_ps.customer_id,
       trx_ps.customer_site_use_id,
       trx_ps.invoice_currency_code,
       trx_ps.class,
       DECODE(trx_ps.class,'INV',
          DECODE((nvl(trx_ps.discount_taken_earned,0)
              + nvl(trx_ps.discount_taken_unearned,0)),0,0,1),0) disc_inv_inst_count,
       rt.printing_lead_days,
       ra.amount_applied,
       rcpt_ps.customer_id,
       rcpt_ps.customer_site_use_id,
       rcpt_ps.invoice_currency_code,
       nvl(ra.amount_applied_from,ra.amount_applied),
       ra.apply_date,
       ra.earned_discount_taken,
       ra.unearned_discount_taken,
       decode(sign(nvl(ra.earned_discount_taken,0)),-1,-1,0,0,1) count_of_edisc,
       decode(sign(nvl(ra.unearned_discount_taken,0)),-1,-1,0,0,1) count_of_uedisc
FROM  ar_payment_schedules trx_ps,
      ar_receivable_applications ra,
      ar_payment_schedules rcpt_ps,
      ra_terms_b rt
WHERE ra.receivable_application_id = ra_id
and   ra.status in ('APP','ACTIVITY')
and   ra.payment_schedule_id = rcpt_ps.payment_schedule_id
and   ra.applied_payment_schedule_id = trx_ps.payment_schedule_id
and   trx_ps.term_id =  rt.term_id(+);

l_receivable_application_id  NUMBER;
l_disc_inv_inst_count NUMBER;
l_trx_customer_id     NUMBER;
l_trx_site_use_id     NUMBER;
l_trx_currency_code   VARCHAR2(30);
l_trx_amt             NUMBER;
l_trx_due_date        DATE;
l_rcpt_customer_id    NUMBER;
l_rcpt_site_use_id    NUMBER;
l_rcpt_currency_code  VARCHAR2(30);
l_rcpt_amt            NUMBER;
l_apply_date          DATE;
l_edisc_count         NUMBER;
l_edisc_value         NUMBER;
l_uedisc_count       NUMBER;
l_uedisc_value       NUMBER;
l_op_trx_count        NUMBER;
l_inv_paid_amt         NUMBER;
l_inv_inst_pmt_days_sum NUMBER;
l_sum_app_amt_days_late NUMBER;
l_sum_app_amt           NUMBER;
l_count_of_tot_inv_inst_paid NUMBER;
l_count_of_inv_inst_paid_late NUMBER;
l_count_of_disc_inv_inst  NUMBER;
l_trx_ado                 NUMBER;
l_trx_app_amt             NUMBER;
l_printing_lead_days      NUMBER;
l_trx_class               VARCHAR2(10);
l_trx_ps_status           VARCHAR2(10);
l_rcpt_ps_status          VARCHAR2(10);
l_due_date_str            VARCHAR2(30);
l_unresolved_cash_value   NUMBER;
l_unresolved_cash_count   NUMBER;

l_past_due_inv_value    NUMBER;
l_past_due_inv_inst_count NUMBER;
BEGIN
  SAVEPOINT  CashApp_Apply_pvt;

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CashApp_Apply(+)');
    END IF;
  l_receivable_application_id :=
                  p_event.GetValueForParameter('RECEIVABLE_APPLICATION_ID');
  l_trx_ps_status      := p_event.GetValueForParameter('TRX_PS_STATUS');
  l_rcpt_ps_status  := p_event.GetValueForParameter('RCPT_PS_STATUS');
  l_due_date_str    := p_event.GetValueForParameter('TRX_DUE_DATE');
  l_trx_app_amt     := fnd_number.canonical_to_number(p_event.GetValueForParameter('TRX_APP_AMT'));
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');

    IF pg_debug = 'Y'
    THEN
       debug ('l_receivable_application_id= '||l_receivable_application_id);
       debug ('l_trx_ps_status= '||l_trx_ps_status);
       debug ('l_rcpt_ps_status= '||l_rcpt_ps_status);
       debug ('l_due_date_str= '||l_due_date_str);
       debug ('l_trx_app_amt= '||l_trx_app_amt);
       debug ('l_org_id= '||l_org_id);
       debug ('l_user_id= '||l_user_id);
       debug ('l_resp_id= '||l_resp_id);
       debug ('l_application_id= '||l_application_id);
       debug ('l_security_gr_id= '||l_security_gr_id);
    END IF;
   --
   --set the application context.
   --
  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
  mo_global.init('AR');
  mo_global.set_policy_context('S',l_org_id);

   select to_date(l_due_date_str, 'J')
   into  l_trx_due_date
   from dual;

   OPEN get_recapp_details(l_receivable_application_id);

     FETCH get_recapp_details INTO  l_trx_customer_id,
                                    l_trx_site_use_id,
                                    l_trx_currency_code,
                                    l_trx_class,
                                    l_disc_inv_inst_count,
                                    l_printing_lead_days,
                                    l_trx_amt          ,
                                    l_rcpt_customer_id ,
                                    l_rcpt_site_use_id ,
                                    l_rcpt_currency_code,
                                    l_rcpt_amt          ,
                                    l_apply_date     ,
                                    l_edisc_value,
                                    l_uedisc_value,
                                    l_edisc_count,
                                    l_uedisc_count;

	IF get_recapp_details%NOTFOUND THEN
          CLOSE get_recapp_details;
          Return 'SUCCESS';
        END IF;

        l_trx_amt := l_trx_amt + nvl(l_edisc_value,0) +  nvl(l_uedisc_value,0);
      --populating the remaining variables
        l_unresolved_cash_value := l_rcpt_amt;

      IF  l_rcpt_ps_status = 'CL' THEN
        l_unresolved_cash_count := 1;
      END IF;

      IF l_trx_ps_status = 'CL' THEN
       l_op_trx_count := 1;
      END IF;

      IF l_trx_class = 'INV' THEN

         l_sum_app_amt := l_trx_amt;

         l_inv_inst_pmt_days_sum :=
              (l_apply_date - (l_trx_due_date + nvl(l_printing_lead_days,0)))
                     * l_trx_amt;

        IF l_trx_ps_status = 'CL' THEN
            l_inv_paid_amt := l_trx_app_amt;
            l_count_of_tot_inv_inst_paid := 1;
            l_count_of_disc_inv_inst := l_disc_inv_inst_count;
        END IF;

        IF  l_trx_ps_status = 'CL' and
            l_apply_date > nvl(l_trx_due_date,l_apply_date) THEN
            l_count_of_inv_inst_paid_late := 1;
        END IF;

        IF  l_trx_due_date < sysdate THEN

             l_past_due_inv_value := l_trx_app_amt;
             IF l_trx_ps_status = 'CL' THEN
               l_past_due_inv_inst_count := 1;
             END IF;
        END IF;

        IF l_apply_date > nvl(l_trx_due_date,l_apply_date) THEN
           l_sum_app_amt_days_late :=
                        (l_apply_date - nvl(l_trx_due_date ,l_apply_date))
                               * l_trx_amt;
        END IF;

      END IF;

      /*****************************************************************
        Columns that need to be updated in the summary tables due to a
        receipt application
        AR_TRX_SUMMARY
        ==================
        1) INV_PAID_AMOUNT
        2) INV_INST_PMT_DAYS_SUM
        3) TOTAL_EARNED_DISC_VALUE
        4) TOTAL_EARNED_DISC_COUNT
        5) TOTAL_UNEARNED_DISC_VALUE
        6) TOTAL_UNEARNED_DISC_COUNT
        7) SUM_APP_AMT_DAYS_LATE
        8) SUM_APP_AMT
        9) COUNT_OF_TOT_INV_INST_PAID
        10)COUNT_OF_INV_INST_PAID_LATE
        11)COUNT_OF_DISC_INV_INST
        12)DAYS_CREDIT_GRANTED_SUM

        AR_TRX_BAL_SUMMARY
        ==================
        1) OP_INVOICES_VALUE
        2) OP_INVOICES_COUNT
        3) OP_DEBIT_MEMOS_VALUE
        4) OP_DEBIT_MEMOS_COUNT
        5) OP_DEPOSITS_VALUE
        6) OP_DEPOSITS_COUNT
        7) OP_CHARGEBACK_VALUE
        8) OP_CHARGEBACK_COUNT
        9) OP_CREDIT_MEMOS_VALUE
        10)OP_CREDIT_MEMOS_COUNT
        11)UNRESOLVED_CASH_VALUE  l_rcp_cash_amt
        12)UNRESOLVED_CASH_COUNT
        13)PAST_DUE_INV_VALUE
        14)PAST_DUE_INV_INST_COUNT

        *****************************************************************/

        Update_recapp_info(l_trx_class,
                           l_trx_customer_id,
                           l_trx_site_use_id,
                           l_trx_currency_code,
                           l_trx_amt          ,
                           l_op_trx_count,
                           l_rcpt_customer_id ,
                           l_rcpt_site_use_id ,
                           l_rcpt_currency_code,
                           l_rcpt_amt          ,
                           l_apply_date ,
                           l_edisc_value,
                           l_edisc_count,
                           l_uedisc_value,
                           l_uedisc_count,
                           l_inv_paid_amt,
                           l_inv_inst_pmt_days_sum,
                           l_sum_app_amt_days_late,
                           l_sum_app_amt,
                           l_count_of_tot_inv_inst_paid,
                           l_count_of_inv_inst_paid_late,
                           l_count_of_disc_inv_inst,
                           l_unresolved_cash_value,
                           l_unresolved_cash_count,
                           null,
                           'CASH',
                           l_past_due_inv_value,
                           l_past_due_inv_inst_count,
                           l_org_id
                           );

     --
   CLOSE get_recapp_details;

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CashApp_Apply(-)');
    END IF;
  Return 'SUCCESS';
EXCEPTION
    WHEN OTHERS  THEN
     ROLLBACK TO CashApp_Apply_pvt;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AR_BUS_EVENT_SUB_PVT', 'CashApp_Apply', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

END CashApp_Apply;

FUNCTION CashApp_UnApply
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS

  l_org_id          NUMBER;
  l_user_id         NUMBER;
  l_resp_id         NUMBER;
  l_application_id  NUMBER;
  l_security_gr_id  NUMBER;

CURSOR get_recapp_details (ra_id  IN NUMBER ) IS
SELECT trx_ps.customer_id,
       trx_ps.customer_site_use_id,
       trx_ps.invoice_currency_code,
       trx_ps.class,
       DECODE(trx_ps.class,'INV',
        DECODE((nvl(trx_ps.discount_taken_earned,0)
          + nvl(trx_ps.discount_taken_unearned,0)),0,0,1),0) disc_inv_inst_count,
       rt.printing_lead_days,
       ra.amount_applied,
       rcpt_ps.customer_id,
       rcpt_ps.customer_site_use_id,
       rcpt_ps.invoice_currency_code,
       nvl(ra.amount_applied_from,ra.amount_applied),
       ra.apply_date,
       ra.earned_discount_taken,
       ra.unearned_discount_taken,
       decode(sign(nvl(ra.earned_discount_taken,0)),-1,-1,0,0,1) count_of_edisc,
       decode(sign(nvl(ra.unearned_discount_taken,0)),-1,-1,0,0,1) count_of_uedisc
FROM  ar_payment_schedules trx_ps,
      ar_receivable_applications ra,
      ar_payment_schedules rcpt_ps,
      ra_terms_b rt
WHERE ra.receivable_application_id = ra_id
and   ra.status in ('APP','ACTIVITY')
and   ra.payment_schedule_id = rcpt_ps.payment_schedule_id
and   ra.applied_payment_schedule_id = trx_ps.payment_schedule_id
and   trx_ps.term_id =  rt.term_id(+);

/* bug number :4387571
   Modified cursor get_inv_disc_info for receivable_application_id condition */
Cursor get_inv_disc_info(p_rec_app_id IN NUMBER) IS
select sum(  nvl(ra.earned_discount_taken,0)
           + nvl(ra.unearned_discount_taken,0)
          ) total_disc
from ar_receivable_applications ra
where receivable_application_id = p_rec_app_id
and  status = 'APP'
and  display = 'Y';

l_receivable_application_id  NUMBER;
l_disc_inv_inst_count NUMBER;
l_trx_customer_id     NUMBER;
l_trx_site_use_id     NUMBER;
l_trx_currency_code   VARCHAR2(30);
l_trx_amt             NUMBER;
l_trx_due_date        DATE;
l_rcpt_customer_id    NUMBER;
l_rcpt_site_use_id    NUMBER;
l_rcpt_currency_code  VARCHAR2(30);
l_rcpt_amt            NUMBER;
l_apply_date          DATE;
l_edisc_count         NUMBER;
l_edisc_value         NUMBER;
l_unedisc_count       NUMBER;
l_unedisc_value       NUMBER;
l_op_trx_count        NUMBER;
l_inv_paid_amt         NUMBER;
l_inv_inst_pmt_days_sum NUMBER;
l_sum_app_amt_days_late NUMBER;
l_sum_app_amt           NUMBER;
l_count_of_tot_inv_inst_paid NUMBER;
l_count_of_inv_inst_paid_late NUMBER;
l_count_of_disc_inv_inst  NUMBER;
l_trx_ado                 NUMBER;
l_trx_app_amt             NUMBER;
l_printing_lead_days      NUMBER;
l_trx_class               VARCHAR2(10);
l_old_trx_ps_status       VARCHAR2(10);
l_old_rcpt_ps_status      VARCHAR2(10);
l_new_trx_ps_status       VARCHAR2(10);
l_new_rcpt_ps_status      VARCHAR2(10);
l_due_date_str            VARCHAR2(30);
l_unresolved_cash_value   NUMBER;
l_unresolved_cash_count   NUMBER;
l_past_due_inv_value      NUMBER;
l_past_due_inv_inst_count NUMBER;
l_prior_disc_amt          NUMBER;
BEGIN
     SAVEPOINT  CashApp_UnApply_pvt;
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CashApp_UnApply(+)');
    END IF;
  l_receivable_application_id :=
                  p_event.GetValueForParameter('RECEIVABLE_APPLICATION_ID');
  l_old_trx_ps_status      := p_event.GetValueForParameter('OLD_TRX_PS_STATUS');
  l_new_trx_ps_status      := p_event.GetValueForParameter('NEW_TRX_PS_STATUS');
  l_old_rcpt_ps_status  := p_event.GetValueForParameter('OLD_RCPT_PS_STATUS');
  l_new_rcpt_ps_status  := p_event.GetValueForParameter('NEW_RCPT_PS_STATUS');
  l_due_date_str        := p_event.GetValueForParameter('TRX_DUE_DATE');
  l_trx_app_amt         := fnd_number.canonical_to_number(p_event.GetValueForParameter('TRX_APP_AMT'));
 -- l_trx_ps_adr          := p_event.GetValueForParameter('AMT_DUE_REMAINING');
 -- l_trx_ps_old_adr      := p_event.GetValueForParameter('OLD_AMT_DUE_REMAINING');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');
    IF pg_debug = 'Y'
    THEN
       debug ('l_receivable_application_id= '||l_receivable_application_id);
       debug ('l_new_trx_ps_status= '||l_new_trx_ps_status);
       debug ('l_old_rcpt_ps_status= '||l_old_rcpt_ps_status);
       debug ('l_old_rcpt_ps_status= '||l_old_rcpt_ps_status);
       debug ('l_new_rcpt_ps_status= '||l_new_rcpt_ps_status);
       debug ('l_due_date_str= '||l_due_date_str);
       debug ('l_trx_app_amt= '||l_trx_app_amt);
       debug ('l_org_id= '||l_org_id);
       debug ('l_user_id= '||l_user_id);
       debug ('l_resp_id= '||l_resp_id);
       debug ('l_application_id= '||l_application_id);
       debug ('l_security_gr_id= '||l_security_gr_id);
    END IF;
   --
   --set the application context.
   --
  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
  mo_global.init('AR');
  mo_global.set_policy_context('S',l_org_id);

   select to_date(l_due_date_str, 'J')
   into  l_trx_due_date
   from dual;

   OPEN get_recapp_details(l_receivable_application_id);

     FETCH get_recapp_details INTO  l_trx_customer_id,
                                    l_trx_site_use_id,
                                    l_trx_currency_code,
                                    l_trx_class,
                                    l_disc_inv_inst_count,
                                    l_printing_lead_days,
                                    l_trx_amt          ,
                                    l_rcpt_customer_id ,
                                    l_rcpt_site_use_id ,
                                    l_rcpt_currency_code,
                                    l_rcpt_amt          ,
                                    l_apply_date     ,
                                    l_edisc_value,
                                    l_unedisc_value,
                                    l_edisc_count,
                                    l_unedisc_count;

	IF get_recapp_details%NOTFOUND THEN
         CLOSE get_recapp_details;
         Return 'SUCCESS';
        END IF;

        l_trx_amt := l_trx_amt + nvl(l_edisc_value,0) +  nvl(l_unedisc_value,0);
      --populating the remaining variables
        l_unresolved_cash_value := l_rcpt_amt;

      IF  l_old_rcpt_ps_status = 'CL'  AND
          l_new_rcpt_ps_status = 'OP' THEN
        l_unresolved_cash_count := -1;
      END IF;


      IF l_new_trx_ps_status = 'CL' AND
         l_old_trx_ps_status = 'OP' THEN
       l_op_trx_count := 1;
      ELSIF l_new_trx_ps_status = 'OP' AND
         l_old_trx_ps_status = 'CL' THEN
       l_op_trx_count := -1;
      END IF;




      IF l_trx_class = 'INV' THEN

         l_sum_app_amt := l_trx_amt;

         l_inv_inst_pmt_days_sum :=
              (l_apply_date - (l_trx_due_date + nvl(l_printing_lead_days,0)))
                     * l_trx_amt;

       --
       --Impact on following columns
       --  INV_PAID_AMT
       --  COUNT_OF_TOT_INV_INST_PAID
       --  COUNT_OF_DISC_INV_INST
       --  COUNT_OF_INV_INST_PAID_LATE
       --
       -- To get the impact of the application reversal on the
       -- count_of_inv_inst_paid_late, we need to find if there were
       -- any discounted applications against this specific payment schedule
       -- prior to this current APP reversal RA record.
       -- We can check that by looking at all RA records with receivable_application_id
       -- less than that of current record.

       --If the current application that is being reversed has discount on it then only
       --we need the info to update the COUNT_OF_DISC_INV_INST.
        IF (nvl(l_edisc_value,0) <> 0 OR
            nvl(l_unedisc_value,0) <> 0)
         THEN
            OPEN get_inv_disc_info(l_receivable_application_id);
              FETCH get_inv_disc_info INTO l_prior_disc_amt;
            CLOSE get_inv_disc_info;
        END IF;


        IF l_new_trx_ps_status = 'OP'  AND
           l_old_trx_ps_status = 'CL'
         THEN
            l_inv_paid_amt := -nvl(l_trx_app_amt,0) + l_trx_amt;
            l_count_of_tot_inv_inst_paid := -1;

          --If the only discount on the trx is due to current application
          --which is being reversed then count_of_disc_inv_inst needs
          --to be bumped up by 1.
          IF l_prior_disc_amt <> 0 AND
             (l_prior_disc_amt =
                   (nvl(l_edisc_value,0) + nvl(l_unedisc_value,0)))
           THEN
            l_count_of_disc_inv_inst := -1;
          END IF;

          IF l_apply_date > nvl(l_trx_due_date,l_apply_date) THEN
             l_count_of_inv_inst_paid_late := -1;
          END IF;

        ELSIF l_new_trx_ps_status = 'CL'  AND
           l_old_trx_ps_status = 'OP' THEN
             --
             --This is an overapplication case
             --
            l_inv_paid_amt :=  l_trx_amt;
            l_count_of_tot_inv_inst_paid := 1;

          --If the only discount on the trx is due to current application
          --which is being reversed then count_of_disc_inv_inst needs
          --to be bumped up by 1.
          IF l_prior_disc_amt <> 0 AND
             (l_prior_disc_amt =
                   (nvl(l_edisc_value,0) + nvl(l_unedisc_value,0)))
           THEN
            l_count_of_disc_inv_inst := 1;
          END IF;


           IF l_apply_date > nvl(l_trx_due_date,l_apply_date) THEN
             l_count_of_inv_inst_paid_late := 1;
          END IF;
        END IF;


       --
       --Impact on following columns
       --  PAST_DUE_INV_INST_COUNT
       --
       -- If due_date on the inv for which the application is being reversed
       -- is past sysdate then bump up the past_due_inv_value. Based on if the
       -- status of the inv is being changed from CL to OP bump up the
       -- past_due_inv_inst_count.

        IF  l_trx_due_date < sysdate THEN
          IF l_old_trx_ps_status = 'CL' AND
            l_new_trx_ps_status = 'OP'
           THEN
             l_past_due_inv_inst_count := -1;
          END IF;
             l_past_due_inv_value := -l_trx_app_amt;
        END IF;

       --
       --Impact on following columns
       --  SUM_APP_AMT_DAYS_LATE
       --
       -- If the apply_date on the application that is being reversed is
       -- greater than the due_date on the invoice installment then we
       -- need to reduce the sum_app_amt_days_late by the sum of the
       -- amount applied.

        IF l_apply_date > nvl(l_trx_due_date,l_apply_date) THEN
           l_sum_app_amt_days_late :=
                        (l_apply_date - nvl(l_trx_due_date ,l_apply_date))
                               * l_trx_amt;
        END IF;

      END IF;

      /*****************************************************************
        Columns that need to be updated in the summary tables due to a
        receipt application
        AR_TRX_SUMMARY
        ==================
        1) INV_PAID_AMOUNT
        2) INV_INST_PMT_DAYS_SUM
        3) TOTAL_EARNED_DISC_VALUE
        4) TOTAL_EARNED_DISC_COUNT
        5) TOTAL_UNEARNED_DISC_VALUE
        6) TOTAL_UNEARNED_DISC_COUNT
        7) SUM_APP_AMT_DAYS_LATE
        8) SUM_APP_AMT
        9) COUNT_OF_TOT_INV_INST_PAID
        10)COUNT_OF_INV_INST_PAID_LATE
        11)COUNT_OF_DISC_INV_INST
        12)DAYS_CREDIT_GRANTED_SUM

        AR_TRX_BAL_SUMMARY
        ==================
        1) OP_INVOICES_VALUE
        2) OP_INVOICES_COUNT
        3) OP_DEBIT_MEMOS_VALUE
        4) OP_DEBIT_MEMOS_COUNT
        5) OP_DEPOSITS_VALUE
        6) OP_DEPOSITS_COUNT
        7) OP_CHARGEBACK_VALUE
        8) OP_CHARGEBACK_COUNT
        9) OP_CREDIT_MEMOS_VALUE
        10)OP_CREDIT_MEMOS_COUNT
        11)UNRESOLVED_CASH_VALUE  l_rcp_cash_amt
        12)UNRESOLVED_CASH_COUNT
        13)PAST_DUE_INV_VALUE
        14)PAST_DUE_INV_INST_COUNT

        *****************************************************************/

        Update_recapp_info(l_trx_class,
                           l_trx_customer_id,
                           l_trx_site_use_id,
                           l_trx_currency_code,
                           l_trx_amt          ,
                           l_op_trx_count,
                           l_rcpt_customer_id ,
                           l_rcpt_site_use_id ,
                           l_rcpt_currency_code,
                           l_rcpt_amt          ,
                           l_apply_date ,
                           l_edisc_value,
                           l_edisc_count,
                           l_unedisc_value,
                           l_unedisc_count,
                           l_inv_paid_amt,
                           l_inv_inst_pmt_days_sum,
                           l_sum_app_amt_days_late,
                           l_sum_app_amt,
                           l_count_of_tot_inv_inst_paid,
                           l_count_of_inv_inst_paid_late,
                           l_count_of_disc_inv_inst,
                           l_unresolved_cash_value,
                           l_unresolved_cash_count,
                           null,
                           'CASH',
                           l_past_due_inv_value,
                           l_past_due_inv_inst_count,
                           l_org_id
                           );

     --
   CLOSE get_recapp_details;

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CashApp_UnApply(-)');
    END IF;
  Return 'SUCCESS';
EXCEPTION
    WHEN OTHERS  THEN
     ROLLBACK TO CashApp_UnApply_pvt;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AR_BUS_EVENT_SUB_PVT', 'CashApp_UnApply', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

END CashApp_UnApply;

--This function is not being used by ant BE currently.
FUNCTION Adjustment
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS

BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.Adjustment(+)');
    END IF;
  Return 'SUCCESS';
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.Adjustment(-)');
    END IF;
END Adjustment;

FUNCTION AutoInv_Run
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS

CURSOR get_AI_run_data(p_req_id IN NUMBER) IS
  Select ps.class,
         ps.customer_id,
         ps.customer_site_use_id,
         ps.trx_date,
         ps.invoice_currency_code,
         ps.org_id,
         ps.due_date,
         ps.customer_trx_id ,
         trx.previous_customer_trx_id,
         ctt.type prev_trx_type,
         ps.terms_sequence_number,
         ps.amount_due_original,
         trx_sum.largest_inv_amount largest_inv_amount,
         trx_sum.largest_inv_date largest_inv_date,
         trx_sum.largest_inv_cust_trx_id largest_inv_cust_trx_id,
         count(nvl(rtl.term_id,1)) installment_count,
         sum(decode(sign(ra_cm.amount_applied),0,null,
                decode(ctt.type,'INV',
                    decode(cm_app_ps.status,'CL',1,null))))
                                   cm_closed_inv_count,
         sum(decode(sign(ra_cm.amount_applied),0,null,
              decode(ctt.type,'DM',
                    decode(cm_app_ps.status,'CL',1,null))))
                                   cm_closed_dm_count,
         sum(decode(sign(ra_cm.amount_applied),0,null,
              decode(ctt.type,'CM',
                    decode(cm_app_ps.status,'CL',1,null))))
                                   cm_closed_cm_count,
         sum(decode(sign(ra_cm.amount_applied),0,null,
              decode(ctt.type,'INV',
                decode(cm_app_ps.status,'CL',
                    decode(sign( cm_app_ps.due_date - trunc(sysdate)),-1,1,null)
                       )
                     )
                   ))              cm_cl_past_due_inv_ct,
         sum(decode(sign(ra_cm.amount_applied),0,null,
              decode(ctt.type,'INV',
                decode(cm_app_ps.status,'CL',
                    decode(sign( cm_app_ps.due_date - trunc(sysdate)),-1,
                        ra_cm.amount_applied,null)
                       )
                     )
                   ))              cm_cl_past_due_inv_amt
  from ra_customer_trx trx,
       ar_payment_schedules ps,
       ra_customer_trx prev_trx,
       ra_cust_trx_types ctt,
       ra_terms rt,
       ra_terms_lines rtl,
       ar_receivable_applications_all ra_cm,
       ar_payment_schedules_all cm_app_ps,
       ar_trx_summary trx_sum
  where trx.customer_trx_id = ps.customer_trx_id
    and trx.request_id = p_req_id
    and trx.previous_customer_trx_id = prev_trx.customer_trx_id(+)
    and prev_trx.cust_trx_type_id = ctt.cust_trx_type_id(+)
    and rt.term_id(+) = ps.term_id
    and rt.term_id = rtl.term_id(+)
    and trx.customer_trx_id = ra_cm.customer_trx_id(+)
    and ra_cm.applied_payment_schedule_id = cm_app_ps.payment_schedule_id(+)
    and trx_sum.cust_account_id(+) = trx.bill_to_customer_id
    and trx_sum.site_use_id(+) = trx.bill_to_site_use_id
    and trx_sum.currency(+) = trx.invoice_currency_code
    and trx_sum.as_of_date(+) = trx.trx_date
    and trx_sum.org_id (+) = trx.org_id
  group by ps.class,
         ps.customer_id,
         ps.customer_site_use_id,
         ps.trx_date,
         ps.invoice_currency_code,
         ps.org_id,
         ps.due_date,
         ps.customer_trx_id ,
         trx.previous_customer_trx_id,
         ctt.type,
         ps.terms_sequence_number,
         ps.amount_due_original,
         trx_sum.largest_inv_amount,
         trx_sum.largest_inv_date ,
         trx_sum.largest_inv_cust_trx_id
  order by ps.customer_trx_id,ps.terms_sequence_number;

  l_key         VARCHAR2(240) := p_event.GetEventKey();
  l_payment_schedule_id   NUMBER(15);
  l_request_id       NUMBER;
  l_org_id           NUMBER;
  l_user_id          NUMBER;
  l_resp_id          NUMBER;
  l_application_id   NUMBER;
  l_security_gr_id   NUMBER;

BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.AutoInv_Run(+)');
    END IF;
  l_request_id := p_event.GetValueForParameter('REQUEST_ID');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');
    IF pg_debug = 'Y'
    THEN
       debug ('l_request_id= '||l_request_id);
       debug ('l_org_id= '||l_org_id);
       debug ('l_user_id= '||l_user_id);
       debug ('l_resp_id= '||l_resp_id);
       debug ('l_application_id= '||l_application_id);
       debug ('l_security_gr_id= '||l_security_gr_id);
    END IF;
   SAVEPOINT  AutoInv_Run_Event;
   --
   --set the application context.
   --
  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
  mo_global.init('AR');
  mo_global.set_policy_context('S',l_org_id);

  Update_summary_for_request_id(l_request_id);
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.AutoInv_Run(-)');
    END IF;

  Return 'SUCCESS';
 EXCEPTION
    WHEN OTHERS  THEN
     ROLLBACK TO AutoInv_Run_Event;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AR_BUS_EVENT_SUB_PVT', 'AUTOINV_RUN', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

END AutoInv_Run;

FUNCTION AutoRcpt_Run
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS
  l_key         VARCHAR2(240) := p_event.GetEventKey();
  l_request_id       NUMBER;
  l_org_id           NUMBER;
  l_user_id          NUMBER;
  l_resp_id          NUMBER;
  l_application_id   NUMBER;
  l_security_gr_id   NUMBER;

BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.AutoRcpt_Run(+)');
    END IF;
  l_request_id      := p_event.GetValueForParameter('REQUEST_ID');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');
    IF pg_debug = 'Y'
    THEN
       debug ('l_request_id= '||l_request_id);
       debug ('l_org_id= '||l_org_id);
       debug ('l_user_id= '||l_user_id);
       debug ('l_resp_id= '||l_resp_id);
       debug ('l_application_id= '||l_application_id);
       debug ('l_security_gr_id= '||l_security_gr_id);
    END IF;
   SAVEPOINT  AutoRcpt_Run_Event;
   --
   --set the application context.
   --
   fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
   mo_global.init('AR');
   mo_global.set_policy_context('S',l_org_id);

   Update_rcpt_app_info_for_req(l_request_id, l_org_id);
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.AutoRcpt_Run(-)');
    END IF;
  Return 'SUCCESS';
 EXCEPTION
    WHEN OTHERS  THEN
     ROLLBACK TO AutoRcpt_Run_Event;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AR_BUS_EVENT_SUB_PVT', 'AUTORCPT_RUN', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';
END AutoRcpt_Run;

FUNCTION AutoAdj_Run
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS
  l_org_id          NUMBER;
  l_user_id         NUMBER;
  l_resp_id         NUMBER;
  l_application_id  NUMBER;
  l_security_gr_id  NUMBER;
  l_request_id          NUMBER;

  l_customer_id         NUMBER;
  l_site_use_id         NUMBER;
  l_currency_code       VARCHAR2(30);
  l_apply_date          DATE;
  l_class               VARCHAR2(10);
  l_due_date            DATE;
  l_adj_status      VARCHAR2(20);

  l_adj_amount          NUMBER;
  l_pending_adj_amount  NUMBER;
  l_adj_count           NUMBER;
  l_past_due_inv_inst_count  NUMBER;
  l_past_due_inv_value  NUMBER;

  CURSOR get_adj (p_req_id  IN NUMBER) IS
   SELECT sum(amount),count(adj.adjustment_id) adj_count,
          ps.customer_id, ps.customer_site_use_id,
          ps.invoice_currency_code, adj.apply_date,
          ps.class, ps.due_date, adj.status
   FROM ar_adjustments adj,
        ar_payment_schedules ps
   WHERE adj.request_id = p_req_id
     and adj.payment_schedule_id = ps.payment_schedule_id
   group by ps.customer_id,
            ps.customer_site_use_id,
            ps.invoice_currency_code,
            adj.apply_date,
            ps.class,
            ps.due_date,
	    adj.status;

BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.AutoAdj_Run(+)');
    END IF;
  l_request_id      := p_event.GetValueForParameter('REQUEST_ID');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');

    IF pg_debug = 'Y'
    THEN
       debug ('l_request_id= '||l_request_id);
       debug ('l_org_id= '||l_org_id);
       debug ('l_user_id= '||l_user_id);
       debug ('l_resp_id= '||l_resp_id);
       debug ('l_application_id= '||l_application_id);
       debug ('l_security_gr_id= '||l_security_gr_id);
    END IF;
  SAVEPOINT AutoADJ_Run_Event;
   --
   --set the application context.
   --
  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
  mo_global.init('AR');
  mo_global.set_policy_context('S',l_org_id);

  OPEN get_adj(l_request_id);

  LOOP
     FETCH get_adj  INTO l_adj_amount,
                         l_adj_count,
                         l_customer_id,
                         l_site_use_id,
                         l_currency_code,
                         l_apply_date,
                         l_class,
                         l_due_date,
		         l_adj_status;

     IF get_adj%NOTFOUND THEN
        EXIT;
     END IF;

     IF  l_adj_status = 'A'
     THEN
	l_pending_adj_amount := 0;
	IF l_due_date < sysdate
        THEN
           l_past_due_inv_inst_count  := -1;
           l_past_due_inv_value  := l_adj_amount;
        END IF;
     ELSE
        l_pending_adj_amount := l_adj_amount;
	l_adj_amount := 0;
	l_adj_count := 0;
     END IF;

     Update_Adj_info (
              l_customer_id,
              l_site_use_id,
              l_org_id    ,
              l_currency_code,
              l_adj_amount   ,
              l_adj_count ,
              l_apply_date   ,
              l_pending_adj_amount,
              l_class,
              null,
              l_past_due_inv_inst_count,
              l_past_due_inv_value );
  END LOOP;

  CLOSE get_adj;

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.AutoAdj_Run(-)');
    END IF;
  Return 'SUCCESS';
EXCEPTION
WHEN OTHERS  THEN
     ROLLBACK TO AutoADJ_Run_Event;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AR_BUS_EVENT_SUB_PVT', 'AUTO_ADJ_RUN', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

END AutoAdj_Run;

FUNCTION QuickCash_PostBatch
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS
  l_key         VARCHAR2(240) := p_event.GetEventKey();
  l_request_id       NUMBER;
  l_org_id           NUMBER;
  l_user_id          NUMBER;
  l_resp_id          NUMBER;
  l_application_id   NUMBER;
  l_security_gr_id   NUMBER;

BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.QuickCash_PostBatch(+)');
    END IF;
  l_request_id      := p_event.GetValueForParameter('REQUEST_ID');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');
    IF pg_debug = 'Y'
    THEN
       debug ('l_request_id= '||l_request_id);
       debug ('l_org_id= '||l_org_id);
       debug ('l_user_id= '||l_user_id);
       debug ('l_resp_id= '||l_resp_id);
       debug ('l_application_id= '||l_application_id);
       debug ('l_security_gr_id= '||l_security_gr_id);
    END IF;
   SAVEPOINT  QuickCash_PostBatch_pvt;
   --
   --set the application context.
   --
   fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
   mo_global.init('AR');
   mo_global.set_policy_context('S',l_org_id);

   Update_rcpt_app_info_for_req(l_request_id, l_org_id);
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.QuickCash_PostBatch(-)');
    END IF;

  Return 'SUCCESS';

EXCEPTION
    WHEN OTHERS  THEN
     ROLLBACK TO QuickCash_PostBatch_pvt;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AR_BUS_EVENT_SUB_PVT', 'QuickCash_PostBatch', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

END QuickCash_PostBatch;

FUNCTION Aging_PastDue
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2
IS

BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.Aging_PastDue(+)');
    END IF;
  Return 'SUCCESS';
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.Aging_PastDue(-)');
    END IF;
END Aging_PastDue;

FUNCTION AdjCreate
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2
IS
  l_adjustment_id   NUMBER;
  l_app_ps_status   VARCHAR2(10);
  l_org_id          NUMBER;
  l_user_id         NUMBER;
  l_resp_id         NUMBER;
  l_application_id  NUMBER;
  l_security_gr_id  NUMBER;
  l_adj_status      VARCHAR2(20);

  l_amount              NUMBER;
  l_apply_date          DATE;
  l_receivables_trx_id  NUMBER;
  l_customer_id         NUMBER;
  l_site_use_id         NUMBER;
  l_currency_code       VARCHAR2(30);
  l_class               VARCHAR2(10);
  l_pending_adj_amount  NUMBER;
  l_adj_amount          NUMBER;
  l_op_trx_count        NUMBER;
  l_special_adj         VARCHAR2(10);
  l_due_date            DATE;
  CURSOR get_adj_details (p_adj_id IN NUMBER) IS
  SELECT adj.amount, adj.apply_date, adj.receivables_trx_id,
         ps.customer_id, ps.customer_site_use_id, ps.invoice_currency_code,
         ps.class, ps.due_date
  FROM ar_adjustments adj,
       ar_payment_schedules ps
  WHERE adj.payment_schedule_id = ps.payment_schedule_id
   and  adj.adjustment_id = p_adj_id ;
l_past_due_inv_inst_count  NUMBER;
l_past_due_inv_value       NUMBER;
BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.AdjCreate(+)');
    END IF;
  l_adjustment_id   := p_event.GetValueForParameter('ADJUSTMENT_ID');
  l_adj_status      := p_event.GetValueForParameter('ADJ_STATUS');
  l_app_ps_status   := p_event.GetValueForParameter('APPLIED_PS_STATUS');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');

    IF pg_debug = 'Y'
    THEN
       debug ('l_adjustment_id= '||l_adjustment_id);
       debug ('l_adj_status= '||l_adj_status);
       debug ('l_app_ps_status= '||l_app_ps_status);
       debug ('l_org_id= '||l_org_id);
       debug ('l_user_id= '||l_user_id);
       debug ('l_resp_id= '||l_resp_id);
       debug ('l_application_id= '||l_application_id);
       debug ('l_security_gr_id= '||l_security_gr_id);
    END IF;
  SAVEPOINT ADJCreate_Event;
   --
   --set the application context.
   --
  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
  mo_global.init('AR');
  mo_global.set_policy_context('S',l_org_id);

  OPEN  get_adj_details (l_adjustment_id);

  FETCH get_adj_details
              INTO l_amount,
                   l_apply_date,
                   l_receivables_trx_id,
                   l_customer_id,
                   l_site_use_id,
                   l_currency_code,
                   l_class,
                   l_due_date;

	IF get_adj_details%NOTFOUND THEN
	   CLOSE get_adj_details;
           Return 'SUCCESS';
        END IF;
  CLOSE get_adj_details;

  IF l_receivables_trx_id > 0 and
     l_adj_status = 'A' THEN
     l_adj_amount := l_amount;
  ELSIF l_receivables_trx_id > 0 and
     l_adj_status <> 'A' THEN
     l_pending_adj_amount := l_amount;
  ELSIF l_receivables_trx_id in ( -12,-11)  THEN
     --chargeback adjustment and its reversal
     l_adj_amount := l_amount;
     l_special_adj := 'Y';
  ELSIF l_receivables_trx_id = -1 THEN
     --commitment
     l_adj_amount := l_amount;
     l_special_adj := 'Y';
  ELSIF l_receivables_trx_id = -15 THEN
     --br creation closing inv
     l_adj_amount := l_amount;
     l_special_adj := 'Y';
  END IF;


  IF l_app_ps_status = 'CL'  THEN
       l_op_trx_count := -1;

    IF l_due_date < sysdate THEN
       l_past_due_inv_inst_count  := -1;
       l_past_due_inv_value  := l_adj_amount;
    END IF;

  ELSIF l_app_ps_status = 'OP'  THEN
      l_op_trx_count := 1;
    IF l_due_date < sysdate THEN
       l_past_due_inv_inst_count  := 1;
       l_past_due_inv_value  := l_adj_amount;
    END IF;

  END IF;

        Update_Adj_info (
              l_customer_id,
              l_site_use_id,
              l_org_id    ,
              l_currency_code,
              l_adj_amount   ,
              l_op_trx_count ,
              l_apply_date   ,
              l_pending_adj_amount,
              l_class ,
              l_special_adj,
              l_past_due_inv_inst_count,
              l_past_due_inv_value);

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.AdjCreate(-)');
    END IF;
  Return 'SUCCESS';
EXCEPTION
    WHEN OTHERS  THEN
     ROLLBACK TO ADJCreate_Event;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AR_BUS_EVENT_SUB_PVT', 'ADJ_CREATE', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';


END AdjCreate;

FUNCTION AdjApprove
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2
IS
  l_adjustment_id   NUMBER;
  l_app_ps_status   VARCHAR2(10);
  l_org_id          NUMBER;
  l_user_id         NUMBER;
  l_resp_id         NUMBER;
  l_application_id  NUMBER;
  l_security_gr_id  NUMBER;
  l_adj_status      VARCHAR2(20);

  l_amount              NUMBER;
  l_apply_date          DATE;
  l_receivables_trx_id  NUMBER;
  l_customer_id         NUMBER;
  l_site_use_id         NUMBER;
  l_currency_code       VARCHAR2(30);
  l_class               VARCHAR2(10);
  l_pending_adj_amount  NUMBER;
  l_adj_amount          NUMBER;
  l_op_trx_count        NUMBER;
  l_past_due_inv_inst_count NUMBER;
  l_past_due_inv_value  NUMBER;
  l_due_date   DATE;
  CURSOR get_adj_details (p_adj_id IN NUMBER) IS
  SELECT adj.amount, adj.apply_date, adj.receivables_trx_id,
         ps.customer_id, ps.customer_site_use_id, ps.invoice_currency_code,
         ps.class, ps.due_date
  FROM ar_adjustments adj,
       ar_payment_schedules ps
  WHERE adj.payment_schedule_id = ps.payment_schedule_id
   and  adj.adjustment_id = p_adj_id ;

BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.AdjApprove(+)');
    END IF;
  l_adjustment_id   := p_event.GetValueForParameter('ADJUSTMENT_ID');
  l_adj_status      := p_event.GetValueForParameter('APPROVAL_ACTN_HIST_ID');
  l_app_ps_status   := p_event.GetValueForParameter('APPLIED_PS_STATUS');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');
    IF pg_debug = 'Y'
    THEN
       debug ('l_adjustment_id= '||l_adjustment_id);
       debug ('l_adj_status= '||l_adj_status);
       debug ('l_app_ps_status= '||l_app_ps_status);
       debug ('l_org_id= '||l_org_id);
       debug ('l_user_id= '||l_user_id);
       debug ('l_resp_id= '||l_resp_id);
       debug ('l_application_id= '||l_application_id);
       debug ('l_security_gr_id= '||l_security_gr_id);
     END IF;
  SAVEPOINT ADJApprove_Event;
   --
   --set the application context.
   --
  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
  mo_global.init('AR');
  mo_global.set_policy_context('S',l_org_id);

  OPEN  get_adj_details (l_adjustment_id);
  FETCH get_adj_details
              INTO l_amount,
                   l_apply_date,
                   l_receivables_trx_id,
                   l_customer_id,
                   l_site_use_id,
                   l_currency_code,
                   l_class,
                   l_due_date;

	IF get_adj_details%NOTFOUND THEN
	 CLOSE get_adj_details;
	 RETURN 'SUCCESS';
       END IF;
  CLOSE get_adj_details;

  IF l_receivables_trx_id > 0 THEN
     l_adj_amount := l_amount;
     l_pending_adj_amount := l_amount;
  END IF;


  IF l_app_ps_status = 'CL'  THEN
      l_op_trx_count := -1;
    IF l_due_date < sysdate THEN
       l_past_due_inv_inst_count  := -1;
       l_past_due_inv_value  := l_adj_amount;
    END IF;

  ELSIF l_app_ps_status = 'OP'  THEN
      l_op_trx_count := 1;
    IF l_due_date < sysdate THEN
       l_past_due_inv_inst_count  := 1;
       l_past_due_inv_value  := l_adj_amount;
    END IF;

  END IF;


        Update_Adj_info (
              l_customer_id,
              l_site_use_id,
              l_org_id    ,
              l_currency_code,
              l_adj_amount   ,
              l_op_trx_count ,
              l_apply_date   ,
              -l_pending_adj_amount,
              l_class,
              null,
              l_past_due_inv_inst_count,
              l_past_due_inv_value);

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.AdjApprove(-)');
    END IF;
  Return 'SUCCESS';
EXCEPTION
    WHEN OTHERS  THEN
     ROLLBACK TO ADJApprove_Event;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AR_BUS_EVENT_SUB_PVT', 'ADJ_APPROVE', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

END AdjApprove;

FUNCTION Recurr_Invoice
(p_subscription_guid In RAW
,p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2
IS

BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.Recurr_Invoice(+)');
    END IF;
  Return 'SUCCESS';

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.Recurr_Invoice(-)');
    END IF;
END Recurr_Invoice;

FUNCTION CopyInv_Run
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2 IS
  i                  INTEGER;
  l_key         VARCHAR2(240) := p_event.GetEventKey();
  l_request_id       NUMBER;
  l_org_id           NUMBER;
  l_user_id          NUMBER;
  l_resp_id          NUMBER;
  l_application_id   NUMBER;
  l_security_gr_id   NUMBER;
BEGIN
    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CopyInv_Run(+)');
    END IF;
  l_request_id := p_event.GetValueForParameter('REQUEST_ID');
  l_org_id          := p_event.GetValueForParameter('ORG_ID');
  l_user_id         := p_event.GetValueForParameter('USER_ID');
  l_resp_id         := p_event.GetValueForParameter('RESP_ID');
  l_application_id  := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_gr_id  := p_event.GetValueForParameter('SECURITY_GROUP_ID');
    IF pg_debug = 'Y'
    THEN
       debug ('l_request_id= '||l_request_id);
       debug ('l_org_id= '||l_org_id);
       debug ('l_user_id= '||l_user_id);
       debug ('l_resp_id= '||l_resp_id);
       debug ('l_application_id= '||l_application_id);
       debug ('l_security_gr_id= '||l_security_gr_id);
     END IF;
   SAVEPOINT  CopyInv_Run_Event;
   --
   --set the application context.
   --
  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);
  mo_global.init('AR');
  mo_global.set_policy_context('S',l_org_id);

  Update_summary_for_request_id(l_request_id);

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.CopyInv_Run(-)');
    END IF;
  Return 'SUCCESS';
EXCEPTION
    WHEN OTHERS  THEN
     ROLLBACK TO CopyInv_Run_Event;

     FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AR_BUS_EVENT_SUB_PVT', 'COPYINV_RUN', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

END CopyInv_Run;

-- The following subroutines have been added for RAMC
-- Please refer to Bug # 3085672 for details.

FUNCTION raise_revenue_event (
  p_customer_trx_id NUMBER,
  p_customer_trx_line_id NUMBER,
  p_amount NUMBER,
  p_acctd_amount NUMBER)
  RETURN VARCHAR2 IS


/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

  l_item_key         wf_items.ITEM_KEY%TYPE;
  l_parameter_list  wf_parameter_list_t := wf_parameter_list_t();


BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.raise_revenue_event(+)');
    END IF;
  -- This function simply raises revenue related business events.


  l_item_key := ar_revenue_management_pvt.c_revenue_deferral_event ||
                '_'||
                to_char(p_customer_trx_line_id) || '_'||
                to_char(sysdate,'DD-MON-YYYY HH24:MI:SS');

  wf_event.addParameterToList(p_name => 'customer_trx_id',
    p_value => p_customer_trx_id,
    p_parameterlist => l_parameter_list);

  wf_event.addParameterToList(p_name => 'customer_trx_line_id',
    p_value => p_customer_trx_line_id,
    p_parameterlist => l_parameter_list);

  wf_event.addParameterToList(p_name => 'amount',
    p_value => p_amount,
    p_parameterlist => l_parameter_list);

  wf_event.addParameterToList(p_name => 'accounted_amount',
    p_value => p_acctd_amount,
    p_parameterlist => l_parameter_list);

  wf_event.raise(
    p_event_name     => ar_revenue_management_pvt.c_revenue_deferral_event,
    p_event_key      => l_item_key,
    p_parameters     => l_parameter_list);


    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.raise_revenue_event(-)');
    END IF;
  RETURN l_item_key;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    RAISE;

  WHEN OTHERS THEN
    RAISE;

END raise_revenue_event;


/*========================================================================
 | PUBLIC FUNCTION events_manager
 |
 | DESCRIPTION
 |   This is a subscription program to the business event
 |   oracle.apps.ar.batch.AutoInvoice.run.  For the lines that were considered
 |   uncollectible during this autoinvoice run, we must raise business event.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |   As a subscription to the the buisness event:
 |     oracle.apps.ar.batch.AutoInvoice.run.:
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   request_id
 |
 | NOTES
 |   None.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 30-JUL-2003           ORASHID           Subroutine Created
 |
 *=======================================================================*/

FUNCTION events_manager (
  p_subscription_guid in raw,
  p_event IN OUT NOCOPY WF_EVENT_T)
  RETURN VARCHAR2 IS

  -- This cursor fetches all rows given a request id
  -- from the audit trail table, so that business events
  -- can be raised.

  CURSOR lines (p_request_id NUMBER) IS
    SELECT rowid,
           customer_trx_id,
           customer_trx_line_id,
           amount_due_original,
           acctd_amount_due_original
    FROM   ar_ramc_audit_trail
    WHERE  request_id = p_request_id
    AND    original_collectibility_flag = 'N';

  l_request_id 			NUMBER;
  l_last_fetch                  BOOLEAN;
  l_item_key                    wf_items.ITEM_KEY%TYPE;
  l_rowid_table                 ar_revenue_management_pvt.varchar_table;
  l_customer_trx_id_table 	ar_revenue_management_pvt.number_table;
  l_customer_trx_line_id_table	ar_revenue_management_pvt.number_table;
  l_line_collectible_table 	ar_revenue_management_pvt.varchar_table;
  l_amount_due_original_table 	ar_revenue_management_pvt.number_table;
  l_acctd_amount_due_orig_table	ar_revenue_management_pvt.number_table;
  l_acctd_amount_pending_table 	ar_revenue_management_pvt.number_table;

BEGIN

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.events_manager(+)');
    END IF;
  l_request_id := p_event.GetValueForParameter('REQUEST_ID');

    IF pg_debug = 'Y'
    THEN
       debug ('l_request_id= '||l_request_id);
    END IF;
  OPEN lines(l_request_id);
  LOOP

    -- this table must be deleted for re-entry
    -- otherwise the row count may not be zero
    -- and we will be stuck in an infinite loop.

    l_rowid_table.delete;

    FETCH lines BULK COLLECT INTO
      l_rowid_table,
      l_customer_trx_id_table,
      l_customer_trx_line_id_table,
      l_amount_due_original_table,
      l_acctd_amount_due_orig_table
    LIMIT ar_revenue_management_pvt.c_max_bulk_fetch_size;

    IF lines%NOTFOUND THEN
      fnd_file.put_line(fnd_file.log, 'last fetch');
      l_last_fetch := TRUE;
    END IF;

    fnd_file.put_line(fnd_file.log, 'Count: ' || to_char(l_rowid_table.COUNT));

    IF l_rowid_table.COUNT = 0 AND l_last_fetch THEN
      fnd_file.put_line(fnd_file.log, 'last fetch and COUNT is zero');
      EXIT;
    END IF;

    FOR i IN l_rowid_table.FIRST .. l_rowid_table.LAST LOOP

        l_item_key := raise_revenue_event (
          p_customer_trx_id      => l_customer_trx_id_table(i),
          p_customer_trx_line_id => l_customer_trx_line_id_table(i),
          p_amount               => l_amount_due_original_table(i),
          p_acctd_amount         => l_acctd_amount_due_orig_table(i));

        fnd_file.put_line(fnd_file.log, 'Raising Buisness Event For ' ||
          l_customer_trx_line_id_table(i));

    END LOOP;

  END LOOP;
  CLOSE Lines;

    IF pg_debug = 'Y'
    THEN
        debug ('AR_BUS_EVENT_SUB_PVT.events_manager(-)');
    END IF;

  RETURN 'SUCCESS';


EXCEPTION

  WHEN OTHERS THEN
     WF_CORE.CONTEXT(
       'ar_revenue_management_pvt',
       'events_manager',
       p_event.getEventName( ),
       p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';

END events_manager;

/* 5690748 - procedure for setting the following fields after
    mass updates (receipt applications):
      op_invoices_count
      op_invoices_value
      past_due_inv_inst_count
      past_due_inv_value

    In the original bug, lockbox receipts were corrupting these columns in
    ar_trx_bal_summary for partial receipts, multiple applications to one
    trx from different receipts, and receipts with apply_dates that
    occurr before the trx.due_date. */
PROCEDURE refresh_counts(
   p_customer_id_tab IN ar_bus_event_sub_pvt.generic_id_type,
   p_site_use_id_tab IN ar_bus_event_sub_pvt.generic_id_type,
   p_currency_tab    IN ar_bus_event_sub_pvt.currency_type,
   p_org_id_tab      IN ar_bus_event_sub_pvt.generic_id_type ) IS

   l_rows NUMBER;

BEGIN
   IF pg_debug = 'Y'
   THEN
      debug ('ar_bus_event_sub_pvt.refresh_counts()+');
   END IF;

   FORALL i IN p_customer_id_tab.FIRST .. p_customer_id_tab.LAST
      update ar_trx_bal_summary main_sum
      set (op_invoices_count,
           op_invoices_value,
           past_due_inv_inst_count,
           past_due_inv_value,
           op_credit_memos_count,
           op_credit_memos_value,
           op_debit_memos_count,
           op_debit_memos_value,
           op_deposits_count,
           op_deposits_value,
           op_chargeback_count,
           op_chargeback_value ) =
      (select
              /* OP invoices */
              count(decode(trx_ps.class,'INV',trx_ps.payment_schedule_id, null)),
              sum(decode(trx_ps.class,'INV',trx_ps.amount_due_remaining,0)),
              /* past due invoices */
              count(decode(trx_ps.class,'INV',
                  decode(sign(trx_ps.due_date - trunc(sysdate)),
                     -1, trx_ps.payment_schedule_id,null),null)),
              sum(decode(trx_ps.class,'INV',
                  decode(sign(trx_ps.due_date - trunc(sysdate)),
                     -1, decode(trx_ps.class,'INV',trx_ps.amount_due_remaining,0),0),0)),
              /* OP credit memos */
              count(decode(trx_ps.class,'CM',trx_ps.payment_schedule_id, null)),
              sum(decode(trx_ps.class,'CM',trx_ps.amount_due_remaining,0)),
              /* OP debit memos */
              count(decode(trx_ps.class,'DM',trx_ps.payment_schedule_id, null)),
              sum(decode(trx_ps.class,'DM',trx_ps.amount_due_remaining,0)),
              /* OP deposits */
              count(decode(trx_ps.class,'DEP',trx_ps.payment_schedule_id, null)),
              sum(decode(trx_ps.class,'DEP',trx_ps.amount_due_remaining,0)),
              /* OP chargebacks */
              count(decode(trx_ps.class,'CB',trx_ps.payment_schedule_id, null)),
              sum(decode(trx_ps.class,'CB',trx_ps.amount_due_remaining,0))
       from ar_payment_schedules_all trx_ps
       where trx_ps.status = 'OP'
       and trx_ps.customer_id = main_sum.cust_account_id
       and trx_ps.customer_site_use_id = decode(main_sum.site_use_id,-99,
             trx_ps.customer_site_use_id,
                main_sum.site_use_id)
       and trx_ps.org_id = main_sum.org_id
       and trx_ps.invoice_currency_code = main_sum.currency
       group by trx_ps.customer_id, trx_ps.customer_site_use_id,
               trx_ps.invoice_currency_code, trx_ps.org_id),
           /* WHO columns */
           last_update_date = sysdate,
           last_updated_by  = fnd_global.user_id,
           last_update_login= fnd_global.login_id
      where cust_account_id = p_customer_id_tab(i)
      and   site_use_id     = p_site_use_id_tab(i)
      and   currency        = p_currency_tab(i)
      and   NVL(org_id,'-99') = NVL(p_org_id_tab(i),-99);

    l_rows := SQL%ROWCOUNT;

   IF pg_debug = 'Y'
   THEN
      debug ('  updated row(s) = ' || l_rows);
   END IF;

   /* 9363502 - Set receipts_at_risk_value */
   refresh_at_risk_value(p_customer_id_tab,
                         p_site_use_id_tab,
                         p_currency_tab,
                         p_org_id_tab);

   IF pg_debug = 'Y'
   THEN
      debug ('ar_bus_event_sub_pvt.refresh_counts()-');
   END IF;
END refresh_counts;

/* 5690748 - procedure for setting the receipt_at_risk_value column
   after mass updates (receipt applications)
*/
PROCEDURE refresh_at_risk_value(
   p_customer_id_tab IN ar_bus_event_sub_pvt.generic_id_type,
   p_site_use_id_tab IN ar_bus_event_sub_pvt.generic_id_type,
   p_currency_tab    IN ar_bus_event_sub_pvt.currency_type,
   p_org_id_tab      IN ar_bus_event_sub_pvt.generic_id_type ) IS

   l_rows NUMBER;

BEGIN
   IF pg_debug = 'Y'
   THEN
      debug ('ar_bus_event_sub_pvt.refresh_at_risk_value()+');
   END IF;

   FORALL i IN p_customer_id_tab.FIRST .. p_customer_id_tab.LAST
      UPDATE ar_trx_bal_summary main_sum
      SET receipts_at_risk_value =
        (SELECT SUM(DECODE(rap.applied_payment_schedule_id, -2, 0,
                       crh.amount))
         FROM   ar_cash_receipts_all cr,
                ar_cash_receipt_history_all crh,
                ar_receivable_applications_all rap
         WHERE  nvl(cr.confirmed_flag, 'Y') = 'Y'
         AND    cr.reversal_date IS NULL
         AND    cr.cash_receipt_id = crh.cash_receipt_id
         AND    crh.current_record_flag = 'Y'
         AND    crh.status NOT IN ('REVERSED',
                  DECODE(crh.factor_flag, 'Y', 'RISK_ELIMINATED',
                                          'N', 'CLEARED'))
         AND    cr.cash_receipt_id = rap.cash_receipt_id (+)
         AND    rap.applied_payment_schedule_id (+) = -2
         AND    cr.pay_from_customer = main_sum.cust_account_id
         AND    cr.customer_site_use_id = decode(main_sum.site_use_id,-99,
                                                  cr.customer_site_use_id,
                                                       main_sum.site_use_id)
         AND    cr.org_id = main_sum.org_id
         AND    cr.currency_code = main_sum.currency
         GROUP BY cr.pay_from_customer, cr.customer_site_use_id,
                  cr.currency_code, cr.org_id),
           /* WHO columns */
           last_update_date = sysdate,
           last_updated_by  = fnd_global.user_id,
           last_update_login= fnd_global.login_id
      WHERE cust_account_id = p_customer_id_tab(i)
      AND   site_use_id     = p_site_use_id_tab(i)
      AND   currency        = p_currency_tab(i)
      AND   NVL(org_id,'-99') = NVL(p_org_id_tab(i),-99);

    l_rows := SQL%ROWCOUNT;

   IF pg_debug = 'Y'
   THEN
      debug ('  updated row(s) = ' || l_rows);
      debug ('ar_bus_event_sub_pvt.refresh_at_risk_value()-');
   END IF;
END refresh_at_risk_value;

END AR_BUS_EVENT_SUB_PVT; -- Package spec

/
