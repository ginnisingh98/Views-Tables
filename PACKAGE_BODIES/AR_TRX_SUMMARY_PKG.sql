--------------------------------------------------------
--  DDL for Package Body AR_TRX_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_TRX_SUMMARY_PKG" AS
/* $Header: ARCMUPGB.pls 120.21.12010000.5 2010/04/08 13:27:58 mraymond ship $ */

/* Globals */
   PG_DEBUG VARCHAR2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
   TYPE l_cust_id_type IS TABLE OF
        ar_payment_schedules_all.customer_id%type
        INDEX BY BINARY_INTEGER;

   t_cust_id  l_cust_id_type;

  SUCCESS          CONSTANT NUMBER:=0;
  WARNING          CONSTANT NUMBER:=1;
  FAILURE          CONSTANT NUMBER:=2;

/* 6149811 - declarations to allow early (re)use */
PROCEDURE block_events(p_action IN VARCHAR2,
                       p_request_id IN NUMBER);
PROCEDURE clear_summary_tables(p_table_to_clear IN VARCHAR2);
PROCEDURE submit_held_events;
/* 6149811 - end early declarations */

PROCEDURE refresh_all(
       errbuf      IN OUT NOCOPY VARCHAR2,
       retcode     IN OUT NOCOPY VARCHAR2
      ) IS
l_program_start_date  DATE;
l_return              BOOLEAN;
v_cursor              NUMBER;
v_return_code         INTEGER;
v_cursor1             NUMBER;
v_return_code1        INTEGER;
text                  VARCHAR2(4000);
l_string              VARCHAR2(4000);
l_po_value            VARCHAR2(10);
l_at_risk_exists      VARCHAR2(1);
BEGIN
 fnd_file.put_line(fnd_file.log,'AR_TRX_SUMMARY_PKG.refresh_all(+)');
 l_po_value := fnd_profile.value('AR_CMGT_ALLOW_SUMMARY_TABLE_REFRESH');

 IF nvl(l_po_value,'N') = 'Y' THEN

  /* 6149811 - clear summary table data */
  block_events('BLOCK',FND_GLOBAL.conc_request_id);

  clear_summary_tables('S');  -- only clear ar_trx_summary

  l_program_start_date := sysdate;

  /* 6149811 - start parallel query */
  EXECUTE IMMEDIATE 'alter session enable parallel dml';
  EXECUTE IMMEDIATE 'alter session force parallel query';

  /* 8713252 - Changed from INSERT to MERGE */
  MERGE INTO ar_trx_bal_summary t
  USING (SELECT D.CUSTOMER_ID,
       D.CUSTOMER_SITE_USE_ID,
       D.CURRENCY_CODE,
       D.ORG_ID,
       nvl(SUM(D.OP_INV_SUM),0)   OP_INV_SUM,
       nvl(SUM(D.OP_INV_COUNT),0) OP_INV_COUNT,
       nvl(SUM(D.OP_CM_SUM),0)    OP_CM_SUM,
       nvl(SUM(D.OP_CM_COUNT),0)  OP_CM_COUNT,
       nvl(SUM(D.OP_DEP_SUM),0)   OP_DEP_SUM,
       nvl(SUM(D.OP_DEP_COUNT),0) OP_DEP_COUNT,
       nvl(SUM(D.OP_CB_SUM),0)    OP_CB_SUM,
       nvl(SUM(D.OP_CB_COUNT),0)  OP_CB_COUNT,
       nvl(SUM(D.OP_DM_SUM),0)    OP_DM_SUM,
       nvl(SUM(D.OP_DM_COUNT),0)  OP_DM_COUNT,
       nvl(SUM(D.OP_BR_SUM),0)    OP_BR_SUM,
       nvl(SUM(D.OP_BR_COUNT),0)  OP_BR_COUNT,
       nvl(SUM(D.UNRESOLVED_CASH_VALUE),0)    UNRESOLVED_CASH_VALUE,
       nvl(SUM(D.UNRESOLVED_CASH_COUNT),0)    UNRESOLVED_CASH_COUNT,
       nvl(SUM(D.PAST_DUE_INV_VALUE),0)       PAST_DUE_INV_VALUE,
       nvl(SUM(D.PAST_DUE_INV_COUNT),0)       PAST_DUE_INV_COUNT,
       nvl(SUM(D.INV_AMT_IN_DISPUTE),0)       INV_AMT_IN_DISPUTE,
       nvl(SUM(D.INV_DISPUTE_COUNT),0)        INV_DISPUTE_COUNT,
       nvl(SUM(D.BEST_CURRENT_RECEIVABLES),0) BEST_CURRENT_RECEIVABLES,
       nvl(SUM(D.RECEIPT_AT_RISK_AMT),0)      RECEIPT_AT_RISK_AMT,
       nvl(SUM(D.LAST_RECEIPT_AMOUNT),0)      LAST_RECEIPT_AMOUNT,
       MAX(D.LAST_RECEIPT_DATE)               LAST_RECEIPT_DATE,
       nvl(MAX(D.LAST_RECEIPT_NUMBER),'0')      LAST_RECEIPT_NUMBER,
       nvl(SUM(D.PENDING_ADJ_AMT),0)          PENDING_ADJ_AMT
   FROM (
   SELECT C.CUSTOMER_ID,
       nvl(C.CUSTOMER_SITE_USE_ID,-99) CUSTOMER_SITE_USE_ID,
       C.INVOICE_CURRENCY_CODE CURRENCY_CODE,
       C.ORG_ID,
       SUM(DECODE(C.CLASS,'INV', C.AMOUNT_DUE_REMAINING,0))       OP_INV_SUM,
       COUNT(DECODE(C.CLASS,'INV', DECODE(C.STATUS,'OP',
                           C.PAYMENT_SCHEDULE_ID,NULL),NULL))   OP_INV_COUNT,
       SUM(DECODE(C.CLASS,'CM', C.AMOUNT_DUE_REMAINING,0) )       OP_CM_SUM,
       COUNT(DECODE(C.CLASS,'CM', DECODE(C.STATUS,'OP',
                           C.PAYMENT_SCHEDULE_ID,NULL),NULL))   OP_CM_COUNT,
       SUM(DECODE(C.CLASS,'CB', C.AMOUNT_DUE_REMAINING,0))        OP_CB_SUM,
       COUNT(DECODE(C.CLASS,'CB',DECODE(C.STATUS, 'OP',
                           C.PAYMENT_SCHEDULE_ID,NULL),NULL))   OP_CB_COUNT,
       SUM(DECODE(C.CLASS,'DEP', C.AMOUNT_DUE_REMAINING) )      OP_DEP_SUM,
       COUNT(DECODE(C.CLASS,'DEP', DECODE(C.STATUS ,'OP',
                           C.PAYMENT_SCHEDULE_ID,NULL),NULL))   OP_DEP_COUNT,
       SUM(DECODE(C.CLASS,'DM', C.AMOUNT_DUE_REMAINING ,0))     OP_DM_SUM,
       COUNT(DECODE(C.CLASS,'DM', DECODE(C.STATUS, 'OP',
                           C.PAYMENT_SCHEDULE_ID,NULL),NULL))   OP_DM_COUNT,
       SUM(DECODE(C.CLASS,'BR', C.AMOUNT_DUE_REMAINING, NULL))  OP_BR_SUM,
       COUNT(DECODE(C.CLASS,'BR', DECODE(C.STATUS, 'OP',
                           C.PAYMENT_SCHEDULE_ID,NULL),NULL))   OP_BR_COUNT,
       SUM(DECODE(C.CLASS,'PMT', C.AMOUNT_DUE_REMAINING * -1, NULL)) UNRESOLVED_CASH_VALUE,
       COUNT(DECODE(C.CLASS,'PMT', DECODE(C.STATUS, 'OP',
                           C.PAYMENT_SCHEDULE_ID,NULL),NULL))   UNRESOLVED_CASH_COUNT,
       SUM(DECODE(C.CLASS,'INV',DECODE(C.STATUS, 'OP',
                                DECODE(SIGN(TRUNC(SYSDATE) -
                                            TRUNC(NVL(C.DUE_DATE, SYSDATE))),1,
                                  (C.AMOUNT_DUE_ORIGINAL
                                    - NVL(C.AMOUNT_APPLIED,0)
                                    + NVL(C.AMOUNT_ADJUSTED,0)
                                    + NVL(C.AMOUNT_CREDITED,0)),
                                        0),0),0))               PAST_DUE_INV_VALUE,
       COUNT(DECODE(C.CLASS,'INV',DECODE(C.STATUS, 'OP',
                                DECODE(SIGN(TRUNC(SYSDATE) -
                                          TRUNC(NVL(C.DUE_DATE, SYSDATE))),1,
                                          C.PAYMENT_SCHEDULE_ID,
                                          NULL),NULL),NULL))    PAST_DUE_INV_COUNT,
       SUM(DECODE(CLASS,'INV',C.AMOUNT_IN_DISPUTE,0))           INV_AMT_IN_DISPUTE,
       COUNT(DECODE(C.CLASS,'INV',DECODE(C.AMOUNT_IN_DISPUTE,
                                   NULL,NULL,0,NULL,C.PAYMENT_SCHEDULE_ID),
                                   NULL))                       INV_DISPUTE_COUNT,
       SUM(DECODE(C.CLASS,
                   'INV', 1,
                   'DM',  1,
                   'CB',  1,
                   'DEP', 1,
                   'BR',  1,
                    0)
                   * DECODE(SIGN(C.DUE_DATE-SYSDATE),
                          -1,0,C.AMOUNT_DUE_REMAINING ))   BEST_CURRENT_RECEIVABLES,
       0 RECEIPT_AT_RISK_AMT ,
       0 LAST_RECEIPT_AMOUNT,
       TO_DATE(NULL) LAST_RECEIPT_DATE,
       NULL LAST_RECEIPT_NUMBER,
       SUM(C.AMOUNT_ADJUSTED_PENDING) PENDING_ADJ_AMT
   FROM AR_PAYMENT_SCHEDULES_ALL C
   WHERE C.payment_schedule_id > 0
   AND   C.customer_id is not null
   AND   C.org_id is not null
   GROUP BY C.CUSTOMER_ID,
            C.CUSTOMER_SITE_USE_ID,
            C.INVOICE_CURRENCY_CODE ,
            C.ORG_ID ) D
   GROUP BY D.CUSTOMER_ID,D.CUSTOMER_SITE_USE_ID,D.CURRENCY_CODE,D.ORG_ID) a
   ON     (	a.CUSTOMER_ID 		= t.CUST_ACCOUNT_ID
	AND   	a.CUSTOMER_SITE_USE_ID  = t.SITE_USE_ID
	AND   	a.CURRENCY_CODE		= t.CURRENCY
	AND   	a.ORG_ID		= t.ORG_ID
	)
   WHEN MATCHED THEN
   UPDATE
   SET
      LAST_UPDATE_DATE =      SYSDATE,
      LAST_UPDATED_BY =       -2003,
      LAST_UPDATE_LOGIN =     -2003,
      OP_INVOICES_VALUE =     a.op_inv_sum,
      OP_INVOICES_COUNT =     a.op_inv_count,
      OP_CREDIT_MEMOS_VALUE = a.op_cm_sum,
      OP_CREDIT_MEMOS_COUNT = a.op_cm_count,
      OP_DEPOSITS_VALUE     = a.op_dep_sum,
      OP_DEPOSITS_COUNT     = a.op_dep_count,
      OP_CHARGEBACK_VALUE   = a.op_cb_sum,
      OP_CHARGEBACK_COUNT   = a.op_cb_count,
      OP_DEBIT_MEMOS_VALUE  = a.op_dm_sum,
      OP_DEBIT_MEMOS_COUNT  = a.op_dm_count,
      OP_BILLS_RECEIVABLES_VALUE = a.op_br_sum,
      OP_BILLS_RECEIVABLES_COUNT = a.op_br_count,
      UNRESOLVED_CASH_VALUE = a.unresolved_cash_value,
      UNRESOLVED_CASH_COUNT = a.unresolved_cash_count,
      PAST_DUE_INV_VALUE     = a.past_due_inv_value,
      PAST_DUE_INV_INST_COUNT= a.past_due_inv_count,
      INV_AMT_IN_DISPUTE     = a.inv_amt_in_dispute,
      DISPUTED_INV_COUNT     = a.inv_dispute_count,
      BEST_CURRENT_RECEIVABLES = a.best_current_receivables,
      PENDING_ADJ_VALUE      = a.pending_adj_amt
   WHEN NOT MATCHED THEN
     INSERT
     (CUST_ACCOUNT_ID,
      SITE_USE_ID,
      CURRENCY,
      ORG_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      OP_INVOICES_VALUE,
      OP_INVOICES_COUNT,
      OP_CREDIT_MEMOS_VALUE,
      OP_CREDIT_MEMOS_COUNT,
      OP_DEPOSITS_VALUE,
      OP_DEPOSITS_COUNT,
      OP_CHARGEBACK_VALUE,
      OP_CHARGEBACK_COUNT,
      OP_DEBIT_MEMOS_VALUE,
      OP_DEBIT_MEMOS_COUNT,
      OP_BILLS_RECEIVABLES_VALUE,
      OP_BILLS_RECEIVABLES_COUNT,
      UNRESOLVED_CASH_VALUE,
      UNRESOLVED_CASH_COUNT,
      PAST_DUE_INV_VALUE,
      PAST_DUE_INV_INST_COUNT,
      INV_AMT_IN_DISPUTE,
      DISPUTED_INV_COUNT,
      BEST_CURRENT_RECEIVABLES,
      PENDING_ADJ_VALUE,
      LAST_PAYMENT_AMOUNT,
      LAST_PAYMENT_NUMBER)
    VALUES
     (a.customer_id,
      a.customer_site_use_id,
      a.currency_code,
      a.org_id,
      sysdate,
      -2003,
      sysdate,
      -2003,
      -2003,
      a.op_inv_sum,
      a.op_inv_count,
      a.op_cm_sum,
      a.op_cm_count,
      a.op_dep_sum,
      a.op_dep_count,
      a.op_cb_sum,
      a.op_cb_count,
      a.op_dm_sum,
      a.op_dm_count,
      a.op_br_sum,
      a.op_br_count,
      a.unresolved_cash_value,
      a.unresolved_cash_count,
      a.past_due_inv_value,
      a.past_due_inv_count,
      a.inv_amt_in_dispute,
      a.inv_dispute_count,
      a.best_current_receivables,
      a.pending_adj_amt,
      a.last_receipt_amount,
      a.last_receipt_number);

   /* We have to issue a commit or the next statement will
      raise an ORA-12838 */
   COMMIT;

   /* 8713252 - Now update last_payment_amounts */

   /* 8784962 - Added WHEN NOT MATCHED to meet 9i requirements,
       that code should never execute */
   merge into AR_TRX_BAL_SUMMARY t
   using (SELECT
           A1.CUSTOMER_ID,
	 	       A1.CUSTOMER_SITE_USE_ID,
	 	       A1.CURRENCY,
	 	       A1.ORG_ID,
	         nvl(sum(B.AMOUNT),0)          LAST_RECEIPT_AMOUNT,
	         max(B.RECEIPT_DATE)           LAST_RECEIPT_DATE,
	         nvl(max(B.RECEIPT_NUMBER),0)  LAST_RECEIPT_NUMBER
	     FROM
           (select
   		cr.pay_from_customer  			customer_id,
       		nvl(cr.customer_site_use_id, -99) 	customer_site_use_id,
       		cr.currency_code 			currency,
       		cr.org_id				org_id,
       		to_number(substr(max(to_char(cr.receipt_date, 'YYYYMMDD') ||
                       ltrim(to_char(cr.cash_receipt_id,
                           '0999999999999999999999'))),9)) last_cash_receipt_id
	    from   ar_cash_receipts_all cr
	    where  NVL(cr.confirmed_flag, 'Y') = 'Y'
	    and    cr.reversal_date is null
	    and    cr.type = 'CASH'
            and    cr.pay_from_customer IS NOT NULL
	    group by pay_from_customer, customer_site_use_id,
                     currency_code, org_id)  a1,
	        AR_CASH_RECEIPTS_ALL B
	     WHERE a1.LAST_CASH_RECEIPT_ID   = B.CASH_RECEIPT_ID
             GROUP BY A1.CUSTOMER_ID,
	              A1.CUSTOMER_SITE_USE_ID,
	 	      A1.CURRENCY,
	 	      A1.ORG_ID) a
         ON (   a.CUSTOMER_ID = t.CUST_ACCOUNT_ID
	    AND a.CUSTOMER_SITE_USE_ID  = t.SITE_USE_ID
	    AND a.CURRENCY = t.CURRENCY
	    AND a.ORG_ID = t.ORG_ID
	    )
         WHEN MATCHED THEN UPDATE
	 SET t.LAST_PAYMENT_AMOUNT = a.LAST_RECEIPT_AMOUNT,
             t.LAST_PAYMENT_DATE = a.LAST_RECEIPT_DATE,
	     t.LAST_PAYMENT_NUMBER = a.LAST_RECEIPT_NUMBER
         WHEN NOT MATCHED THEN INSERT
            (CUST_ACCOUNT_ID,
             SITE_USE_ID,
             CURRENCY,
             ORG_ID,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN,
             LAST_PAYMENT_AMOUNT,
             LAST_PAYMENT_DATE,
             LAST_PAYMENT_NUMBER)
            VALUES
            (-1 * ar_trx_summary_hist_s.nextval,
             -999,
             a.currency,
             -999,
             sysdate,
             -2003,
             sysdate,
             -2003,
             -2003,
             a.last_receipt_amount,
             a.last_receipt_date,
             a.last_receipt_number);

     /* 8713252 - Detect receipts at risk and set receipts_at_risk_value
        only if they exist */
     BEGIN

        SELECT 'Y'
        INTO   l_at_risk_exists
        FROM   DUAL
        WHERE  EXISTS  (
          SELECT 'at risk receipt'
          FROM   AR_CASH_RECEIPTS_ALL CR,
                 AR_CASH_RECEIPT_HISTORY_ALL CRH
          WHERE NVL(CR.CONFIRMED_FLAG, 'Y') = 'Y'
          AND CR.REVERSAL_DATE IS NULL
          AND CR.CASH_RECEIPT_ID = CRH.CASH_RECEIPT_ID
          AND CRH.CURRENT_RECORD_FLAG = 'Y'
          AND CRH.STATUS NOT IN (
              DECODE (CRH.FACTOR_FLAG, 'Y', 'RISK_ELIMINATED',
                                       'N', 'CLEARED'), 'REVERSED'));

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
           l_at_risk_exists := 'N';
     END;

   IF l_at_risk_exists = 'Y'
   THEN

      /* We have to issue a commit or the next statement will
         raise an ORA-12838 */
      COMMIT;

     merge into AR_TRX_BAL_SUMMARY t
     using (SELECT  CR.PAY_FROM_CUSTOMER   CUSTOMER_ID,
                    NVL(CR.CUSTOMER_SITE_USE_ID,-99) CUSTOMER_SITE_USE_ID,
                    CR.CURRENCY_CODE CURRENCY,
                    CR.ORG_ID ORG_ID,
        	    SUM(DECODE(RAP.APPLIED_PAYMENT_SCHEDULE_ID,-2,NULL,
                        CRH.AMOUNT)) RECEIPTS_AT_RISK_VALUE
 	    FROM    AR_CASH_RECEIPTS_ALL CR,
           	    AR_CASH_RECEIPT_HISTORY_ALL CRH,
      		    AR_RECEIVABLE_APPLICATIONS_ALL RAP
 	    WHERE NVL(CR.CONFIRMED_FLAG, 'Y') 	= 'Y'
   	    AND CR.REVERSAL_DATE 		IS NULL
   	    AND CR.CASH_RECEIPT_ID 		= CRH.CASH_RECEIPT_ID
   	    AND CRH.CURRENT_RECORD_FLAG 	= 'Y'
   	    AND CRH.STATUS NOT IN
               (DECODE (CRH.FACTOR_FLAG, 'Y', 'RISK_ELIMINATED',
                                         'N', 'CLEARED'), 'REVERSED')
   	    AND RAP.CASH_RECEIPT_ID(+) 	= CR.CASH_RECEIPT_ID
   	    AND RAP.APPLIED_PAYMENT_SCHEDULE_ID(+) = -2
            AND CR.PAY_FROM_CUSTOMER IS NOT NULL
 	    GROUP BY CR.PAY_FROM_CUSTOMER,
		     NVL(CR.CUSTOMER_SITE_USE_ID,-99),
		     CR.CURRENCY_CODE,
		     CR.ORG_ID) a
      ON (    a.CUSTOMER_ID = t.CUST_ACCOUNT_ID
	  AND a.CUSTOMER_SITE_USE_ID = t.SITE_USE_ID
	  AND a.CURRENCY             = t.CURRENCY
	  AND a.ORG_ID               = t.ORG_ID
	 )
      WHEN MATCHED THEN UPDATE
         SET t.RECEIPTS_AT_RISK_VALUE = a.RECEIPTS_AT_RISK_VALUE
      WHEN NOT MATCHED THEN INSERT
            (CUST_ACCOUNT_ID,
             SITE_USE_ID,
             CURRENCY,
             ORG_ID,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN,
             RECEIPTS_AT_RISK_VALUE)
            VALUES
            (-1 * ar_trx_summary_hist_s.nextval,
             -888,
             a.currency,
             -999,
             sysdate,
             -2003,
             sysdate,
             -2003,
             -2003,
             a.receipts_at_risk_value);

   END IF;

COMMIT;


IF AR_CMGT_CREDIT_REQUEST_API.is_Credit_Management_Installed()
THEN

  INSERT into ar_trx_summary
   (CUST_ACCOUNT_ID,
    SITE_USE_ID,
    CURRENCY,
    ORG_ID,
    AS_OF_DATE,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    TOTAL_INVOICES_VALUE,
    TOTAL_INVOICES_COUNT,
    TOTAL_CREDIT_MEMOS_VALUE ,
    TOTAL_CREDIT_MEMOS_COUNT,
    TOTAL_CHARGEBACK_VALUE,
    TOTAL_CHARGEBACK_COUNT,
    TOTAL_DEPOSITS_VALUE,
    TOTAL_DEPOSITS_COUNT,
    TOTAL_DEBIT_MEMOS_VALUE,
    TOTAL_DEBIT_MEMOS_COUNT,
    TOTAL_BILLS_RECEIVABLES_VALUE,
    TOTAL_BILLS_RECEIVABLES_COUNT,
    TOTAL_CASH_RECEIPTS_VALUE,
    TOTAL_CASH_RECEIPTS_COUNT,
    COUNT_OF_DISC_INV_INST,
    DAYS_CREDIT_GRANTED_SUM,
    COUNT_OF_INV_INST_PAID_LATE,
    COUNT_OF_TOT_INV_INST_PAID,
    INV_PAID_AMOUNT,
    INV_INST_PMT_DAYS_SUM,
    NSF_STOP_PAYMENT_COUNT,
    NSF_STOP_PAYMENT_AMOUNT,
    SUM_APP_AMT,
    TOTAL_EARNED_DISC_VALUE,
    TOTAL_EARNED_DISC_COUNT,
    TOTAL_UNEARNED_DISC_VALUE,
    TOTAL_UNEARNED_DISC_COUNT,
    SUM_APP_AMT_DAYS_LATE,
    TOTAL_ADJUSTMENTS_VALUE,
    TOTAL_ADJUSTMENTS_COUNT)
    ( select D.customer_id,
        D.customer_site_use_id,
        D.currency_code,
        D.org_id,
        D.as_of_date,
        sysdate,
        -2003,
        sysdate,
        -2003,
        -2003,
        sum(decode(D.TOT_INV_SUM,0,null,D.TOT_INV_SUM)) TOT_INV_SUM,
        sum(decode(D.TOT_INV_COUNT,0,null,D.TOT_INV_COUNT)) TOT_INV_COUNT,
        SUM(decode(D.TOT_CM_SUM,0,null,D.TOT_CM_SUM)) TOT_CM_SUM,
        SUM(decode(D.TOT_CM_COUNT,0,null,D.TOT_CM_COUNT)) TOT_CM_COUNT,
        sum(decode(D.TOT_CB_SUM,0,null,D.TOT_CB_SUM)) TOT_CB_SUM,
        SUM(decode(D.TOT_CB_COUNT,0,null,D.TOT_CB_COUNT)) TOT_CB_COUNT,
        SUM(decode(D.TOT_DEP_SUM,0,null,D.TOT_DEP_SUM)) TOT_DEP_SUM,
        SUM(decode(D.TOT_DEP_COUNT,0,null,D.TOT_DEP_COUNT)) TOT_DEP_COUNT,
        SUM(decode(D.TOT_DM_SUM,0,null,D.TOT_DM_SUM)) TOT_DM_SUM,
        SUM(decode(D.TOT_DM_COUNT,0,null,D.TOT_DM_COUNT)) TOT_DM_COUNT,
        SUM(decode(D.TOT_BR_SUM,0,null,D.TOT_BR_SUM)) TOT_BR_SUM,
        SUM(decode(D.TOT_BR_COUNT,0,null,D.TOT_BR_COUNT)) TOT_BR_COUNT,
        SUM(decode(D.TOT_PMT_SUM,0,null,D.TOT_PMT_SUM)) TOT_PMT_SUM,
        SUM(decode(D.TOT_PMT_COUNT,0,null,D.TOT_PMT_COUNT)) TOT_PMT_COUNT,
        SUM(decode(D.disc_inv_inst_count,0,null,D.disc_inv_inst_count)) disc_inv_inst_count,
        SUM(decode(D.days_credit_granted_sum,0,null,D.days_credit_granted_sum)) days_credit_granted_sum,
        SUM(decode(D.COUNT_OF_INV_INST_PAID_LATE,0,null,D.COUNT_OF_INV_INST_PAID_LATE)) COUNT_OF_INV_INST_PAID_LATE,
        SUM(decode(D.COUNT_OF_TOT_INV_INST_PAID,0,null,D.COUNT_OF_TOT_INV_INST_PAID)) COUNT_OF_TOT_INV_INST_PAID,
        SUM(decode(D.INV_PAID_AMOUNT,0,null,D.INV_PAID_AMOUNT)) INV_PAID_AMOUNT,
        SUM(decode(D.inv_inst_pmt_days_sum,0,null,D.inv_inst_pmt_days_sum)) inv_inst_pmt_days_sum,
        sum(decode(D.NSF_STOP_PAYMENT_COUNT,0,null,D.NSF_STOP_PAYMENT_COUNT)) NSF_STOP_PAYMENT_COUNT,
        sum(decode(D.NSF_STOP_PAYMENT_AMOUNT,0,null,D.NSF_STOP_PAYMENT_AMOUNT)) NSF_STOP_PAYMENT_AMOUNT,
        sum(decode(D.sum_amt_applied,0,null,D.sum_amt_applied)) sum_amt_applied,
        sum(decode(D.edisc_taken,0,null,D.edisc_taken)) edisc_taken,
        sum(decode(D.edisc_taken,0,null,D.edisc_count)) edisc_count,
        sum(decode(D.unedisc_taken,0,null,D.unedisc_taken)) unedisc_taken,
        sum(decode(D.unedisc_taken,0,null,D.unedisc_count)) unedisc_count,
        sum(decode(D.app_amt_days_late,0,null,D.app_amt_days_late)) app_amt_days_late,
        sum(decode(D.adj_amount,0,null,D.adj_amount)) adj_amount,
        sum(decode(D.adj_count,0,null,D.adj_count)) adj_count
from ( select  C.customer_id,
        C.customer_site_use_id,
        C.currency_code,
        C.org_id,
        C.trx_date as_of_date,
        sum(DECODE(C.class,'INV',C.amount_due_original,0 ))     TOT_INV_SUM,
        count(decode(C.class,'INV',C.payment_schedule_id,null)) TOT_INV_COUNT,
        sum(DECODE(C.class,'CM',C.amount_due_original,0 ))      TOT_CM_SUM,
        count(decode(C.class,'CM',C.payment_schedule_id,null))  TOT_CM_COUNT,
        sum(DECODE(C.class,'CB',C.amount_due_original,0 ))      TOT_CB_SUM,
        count(decode(C.class,'CB',C.payment_schedule_id,null))  TOT_CB_COUNT,
        sum(DECODE(C.class,'DEP',C.amount_due_original,0 ))     TOT_DEP_SUM,
        count(decode(C.class,'DEP',C.payment_schedule_id,null)) TOT_DEP_COUNT,
        sum(DECODE(C.class,'DM',C.amount_due_original,0 ))      TOT_DM_SUM,
        count(decode(C.class,'DM',C.payment_schedule_id,null))  TOT_DM_COUNT,
        sum(DECODE(C.class,'BR',C.amount_due_original,0))       TOT_BR_SUM,
        count(decode(C.class,'BR',C.payment_schedule_id,null))  TOT_BR_COUNT,
        sum(DECODE(C.class,'PMT',C.amount_due_original * -1 ,0 ))     TOT_PMT_SUM,
        count(decode(C.class,'PMT',C.payment_schedule_id,null)) TOT_PMT_COUNT,
        sum(DECODE(C.class, 'INV', DECODE((nvl(C.edisc_taken,0) +
               nvl(C.unedisc_taken,0)), 0, 0, 1),0))            DISC_INV_INST_COUNT,
        sum(decode(C.class,'INV',((C.due_date - C.trx_date)*(nvl(C.amount_due_original,0)+
                                   nvl(C.ADJ_AMOUNT,0))),null)) DAYS_CREDIT_GRANTED_SUM,
        sum(decode(C.class,'INV',
                      DECODE(sign(NVL(C.AMOUNT_APPLIED,0)),0,null,
                          DECODE(SIGN((C.AMOUNT_DUE_ORIGINAL
                           - NVL(C.AMOUNT_APPLIED,0)
                           - nvl(C.edisc_taken,0)
                           - nvl(C.unedisc_taken,0)
                           + NVL(C.ADJ_AMOUNT,0))),SIGN(C.AMOUNT_DUE_ORIGINAL),
                            null,
                            decode(sign(C.due_date - C.actual_date_closed),
                            -1, 1,null))),null))                COUNT_OF_INV_INST_PAID_LATE,
        sum(decode(C.class,'INV',
                       DECODE(sign(NVL(C.AMOUNT_APPLIED,0)),0,null,
                           DECODE(SIGN((C.AMOUNT_DUE_ORIGINAL
                           - NVL(C.AMOUNT_APPLIED,0)
                           - nvl(C.edisc_taken,0)
                           - nvl(C.unedisc_taken,0)
                           + NVL(C.ADJ_AMOUNT,0))),SIGN(C.AMOUNT_DUE_ORIGINAL)
                           ,null,
                            1)),null))                           COUNT_OF_TOT_INV_INST_PAID,
        sum(decode(C.class,'INV',DECODE(SIGN((C.AMOUNT_DUE_ORIGINAL
                   - NVL(C.AMOUNT_APPLIED,0)
                   - nvl(C.edisc_taken,0)
                   - nvl(C.unedisc_taken,0)
                   + NVL(C.ADJ_AMOUNT,0))),SIGN(C.AMOUNT_DUE_ORIGINAL),
                    null,nvl(C.amount_applied,0)),null))     INV_PAID_AMOUNT,
        sum(decode(C.class,'INV',1,null))           COUNT_OF_TOT_INV_INST,
        0 inv_inst_pmt_days_sum,
        0 NSF_STOP_PAYMENT_COUNT,
        0 NSF_STOP_PAYMENT_AMOUNT,
        0 sum_amt_applied,
        0 edisc_taken,
        0 edisc_count,
        0 unedisc_taken,
        0 unedisc_count,
        0 app_amt_days_late,
        0 ADJ_AMOUNT,
        0 ADJ_COUNT
 FROM  (
   SELECT A.CUSTOMER_ID,
        A.CUSTOMER_SITE_USE_ID,
        A.CURRENCY_CODE,
        A.ORG_ID ,
        A.CLASS,
        A.DUE_DATE,
        A.TRX_DATE,
        A.actual_date_closed,
        A.PAYMENT_SCHEDULE_ID,
        A.AMOUNT_DUE_ORIGINAL,
        A.AMOUNT_IN_DISPUTE,
        A.AMOUNT_APPLIED,
        A.edisc_taken,
        A.unedisc_taken,
        SUM(ADJ.AMOUNT) ADJ_AMOUNT
  FROM (
  SELECT PS.CUSTOMER_ID,
       NVL(PS.CUSTOMER_SITE_USE_ID,-99) CUSTOMER_SITE_USE_ID,
       PS.INVOICE_CURRENCY_CODE CURRENCY_CODE,
       PS.ORG_ID,
       PS.CLASS,
       ps.amount_in_dispute AMOUNT_IN_DISPUTE,
       ps.due_date DUE_DATE,
       PS.AMOUNT_DUE_ORIGINAL,
       PS.TRX_DATE,
       PS.actual_date_closed,
       PS.PAYMENT_SCHEDULE_ID,
       SUM(  RA.AMOUNT_APPLIED) AMOUNT_APPLIED,
       sum(decode(ps.class, 'INV',
                decode(ra.earned_discount_taken,0,
                         null,ra.earned_discount_taken), null)) edisc_taken,
       sum(decode(ps.class, 'INV',
                decode(ra.unearned_discount_taken,0,
                         null,ra.unearned_discount_taken), null)) unedisc_taken
   FROM  AR_PAYMENT_SCHEDULES_all ps,
         AR_RECEIVABLE_APPLICATIONS_ALL RA
  WHERE  RA.APPLIED_PAYMENT_SCHEDULE_ID(+) = PS.PAYMENT_SCHEDULE_ID
    AND  RA.CREATION_DATE(+) <= l_program_start_date
    AND  RA.DISPLAY(+) = 'Y'
    AND  RA.STATUS(+) = 'APP'
    AND  PS.CUSTOMER_ID > 0
    and  ra.apply_date(+) >= add_months(sysdate, -24)
    AND  ps.trx_date >= add_months(sysdate, -24)
    AND  PS.CREATION_DATE <= l_program_start_date
 GROUP BY PS.CUSTOMER_ID,  NVL(PS.CUSTOMER_SITE_USE_ID,-99),
          PS.INVOICE_CURRENCY_CODE, PS.ORG_ID,
          PS.CLASS, PS.TRX_DATE, ps.due_date,
          PS.AMOUNT_DUE_ORIGINAL,
          ps.amount_in_dispute,
          ps.actual_date_closed, PS.PAYMENT_SCHEDULE_ID
       ) A,
       AR_ADJUSTMENTS_ALL ADJ
 WHERE A.PAYMENT_SCHEDULE_ID = ADJ.PAYMENT_SCHEDULE_ID(+)
  AND  ADJ.CREATION_DATE (+) <= l_program_start_date
  AND  ADJ.STATUS(+) = 'A'
 GROUP BY A.CUSTOMER_ID,  A.CUSTOMER_SITE_USE_ID,
          A.CURRENCY_CODE, A.ORG_ID,
          A.CLASS, A.TRX_DATE,A.DUE_DATE,
          A.AMOUNT_DUE_ORIGINAL, A.AMOUNT_IN_DISPUTE,
          A.actual_date_closed,A.AMOUNT_APPLIED,
          A.edisc_taken,A.unedisc_taken,
          A.PAYMENT_SCHEDULE_ID
      ) C
 group by C.customer_id,
        C.customer_site_use_id,
        C.currency_code,
        C.org_id,
        C.trx_date
UNION
select  cr.pay_from_customer customer_id,
        nvl(cr.customer_site_use_id,-99) customer_site_use_id,
        cr.currency_code invoice_currency_code,
        cr.org_id,
        cr.reversal_date as_of_date,
        0 TOT_INV_SUM,
        0 TOT_INV_COUNT,
        0 TOT_CM_SUM,
        0 TOT_CM_COUNT,
        0 TOT_CB_SUM,
        0 TOT_CB_COUNT,
        0 TOT_DEP_SUM,
        0 TOT_DEP_COUNT,
        0 TOT_DM_SUM,
        0 TOT_DM_COUNT,
        0 TOT_BR_SUM,
        0 TOT_BR_COUNT,
        0 TOT_PMT_SUM,
        0 TOT_PMT_COUNT,
        0 disc_inv_inst_count,
        0 days_credit_granted_sum,
        0 COUNT_OF_INV_INST_PAID_LATE,
        0 COUNT_OF_TOT_INV_INST_PAID,
        0 INV_PAID_AMOUNT,
        0 COUNT_OF_TOT_INV_INST,
        0 inv_inst_pmt_days,
        count(cr.cash_receipt_id) NSF_STOP_PAYMENT_COUNT,
        sum(cr.amount) NSF_STOP_PAYMENT_AMOUNT,
        0 sum_amt_applied,
        0 edisc_taken,
        0 edisc_count,
        0 unedisc_taken,
        0 unedisc_count,
        0 app_amt_days_late,
        0 adj_amount,
        0 adj_count
 from   ar_cash_receipts_all cr,
        ar_cash_receipt_history_all crh
 where  cr.cash_receipt_id = crh.cash_receipt_id
    and crh.current_record_flag = 'Y'
    and crh.status = 'REVERSED'
    and crh.creation_date <= l_program_start_date
    and cr.status = 'REV'
    and cr.reversal_category = 'NSF'
    and cr.reversal_date > add_months(sysdate, -24)
    and nvl(cr.pay_from_customer,0) > 0
 group by cr.pay_from_customer,
        nvl(cr.customer_site_use_id,-99),
        cr.currency_code,
        cr.org_id,
        cr.reversal_date
UNION
select  customer_id,
        customer_site_use_id,
        invoice_currency_code,
        org_id,
        apply_date as_of_date,
        0 TOT_INV_SUM,
        0 TOT_INV_COUNT,
        0 TOT_CM_SUM,
        0 TOT_CM_COUNT,
        0 TOT_CB_SUM,
        0 TOT_CB_COUNT,
        0 TOT_DEP_SUM,
        0 TOT_DEP_COUNT,
        0 TOT_DM_SUM,
        0 TOT_DM_COUNT,
        0 TOT_BR_SUM,
        0 TOT_BR_COUNT,
        0 TOT_PMT_SUM,
        0 TOT_PMT_COUNT,
        0 disc_inv_inst_count,
        0 days_credit_granted_sum,
        0 COUNT_OF_INV_INST_PAID_LATE,
        0 COUNT_OF_TOT_INV_INST_PAID,
        0 INV_PAID_AMOUNT,
        0 COUNT_OF_TOT_INV_INST,
        sum(decode(inv_inst_pmt_days,0,null,inv_inst_pmt_days)) inv_inst_pmt_days,
        0 NSF_STOP_PAYMENT_COUNT,
        0 NSF_STOP_PAYMENT_AMOUNT,
        sum(decode(sum_amt_applied,0,null,sum_amt_applied)) sum_amt_applied,
        sum(decode(edisc_taken,0,null,edisc_taken)) edisc_taken,
        sum(decode(edisc_taken,0,null,edisc_count)) edisc_count,
        sum(decode(unedisc_taken,0,null,unedisc_taken)) unedisc_taken,
        sum(decode(unedisc_taken,0,null,unedisc_count)) unedisc_count,
        sum(decode(app_amt_days_late,0,null,app_amt_days_late)) app_amt_days_late,
        0 adj_amount,
        0 adj_count
from ( select ps.customer_id,
        ps.customer_site_use_id,
        ps.invoice_currency_code,
        ps.org_id,
        trunc(ra.apply_date) apply_date,
        ra.cash_receipt_id,
        ra.applied_payment_schedule_id,
        sum(decode(ps.class, 'INV',ra.amount_applied,0)) sum_amt_applied,
        sum(decode(ps.class, 'INV',((ra.apply_date - (ps.trx_date + nvl(rt.printing_lead_days,0)))
                                  * (nvl(ra.amount_applied,0))),null)) inv_inst_pmt_days,
        sum(decode(ps.class, 'INV', decode(ra.earned_discount_taken,0,null,ra.earned_discount_taken), null)) edisc_taken,
        sum(decode(ps.class, 'INV',decode(nvl(ra.earned_discount_taken,0),0,null,1),null)) edisc_count,
        sum(decode(ps.class, 'INV', decode(ra.unearned_discount_taken,0,null,ra.unearned_discount_taken), null)) unedisc_taken,
        sum(decode(ps.class, 'INV',decode(nvl(ra.unearned_discount_taken,0),0,null,1),null)) unedisc_count,
        sum(decode(ps.class, 'INV',
        (ra.apply_date - ps.due_date)* ra.amount_applied, null)) app_amt_days_late
 from   ar_payment_schedules_all ps,
        ra_terms_b rt,
        ar_receivable_applications_all ra
 where  ps.payment_schedule_id = ra.applied_payment_schedule_id
  and   ps.customer_id > 0
  and   ps.term_id = rt.term_id(+)
  and   ra.creation_date <= l_program_start_date
  and   ra.status =  'APP'
  and   ra.display = 'Y'
  and   ra.application_type = 'CASH'
  and   ra.apply_date >= add_months(sysdate, -24)
  group by ps.customer_id,
        ps.customer_site_use_id,
        ps.invoice_currency_code,
        ps.org_id,
        trunc(ra.apply_date),
        ra.cash_receipt_id,
        ra.applied_payment_schedule_id
        )
  group by customer_id,
        customer_site_use_id,
        invoice_currency_code,
        org_id,
        apply_date
UNION
select  ps.customer_id,
        ps.customer_site_use_id,
        ps.invoice_currency_code,
        ps.org_id,
        adj.apply_date as_of_date,
        0 TOT_INV_SUM,
        0 TOT_INV_COUNT,
        0 TOT_CM_SUM,
        0 TOT_CM_COUNT,
        0 TOT_CB_SUM,
        0 TOT_CB_COUNT,
        0 TOT_DEP_SUM,
        0 TOT_DEP_COUNT,
        0 TOT_DM_SUM,
        0 TOT_DM_COUNT,
        0 TOT_BR_SUM,
        0 TOT_BR_COUNT,
        0 TOT_PMT_SUM,
        0 TOT_PMT_COUNT,
        0 disc_inv_inst_count,
        0 days_credit_granted_sum,
        0 COUNT_OF_INV_INST_PAID_LATE,
        0 COUNT_OF_TOT_INV_INST_PAID,
        0 INV_PAID_AMOUNT,
        0 COUNT_OF_TOT_INV_INST,
        0 inv_inst_pmt_days,
        0 NSF_STOP_PAYMENT_COUNT,
        0 NSF_STOP_PAYMENT_AMOUNT,
        0 sum_amt_applied,
        0 edisc_taken,
        0 edisc_count,
        0 unedisc_taken,
        0 unedisc_count,
        0 app_amt_days_late,
        sum(adj.amount) adj_amount,
        count(adjustment_id) adj_count
 from   ar_payment_schedules_all ps,
        ar_adjustments_all adj
 where  ps.payment_schedule_id = adj.payment_schedule_id
   and  adj.receivables_trx_id(+) > 0
   and  ps.trx_date > add_months(sysdate, -24)
   and  ps.creation_date <= l_program_start_date
   and  adj.creation_date <= l_program_start_date
   and  adj.status = 'A'
   and  adj.apply_date > add_months(sysdate, -24)
group by ps.customer_id,
         ps.customer_site_use_id,
         ps.invoice_currency_code,
         ps.org_id,
         adj.apply_date
) D
group by D.customer_id,
        D.customer_site_use_id,
        D.currency_code,
        D.org_id,
        D.as_of_date);
COMMIT;

  /* 6149811 - stop parallel processing now */
  EXECUTE IMMEDIATE 'alter session disable parallel query';

   /*--------------------------------------------+
    |                                            |
    | LOGIC TO UPDATE THE LARGEST INV INFO IN    |
    | AR_TRX_SUMMARY  TABLE                      |
    |                                            |
    +--------------------------------------------*/

declare
v_cursor1       NUMBER;
v_cursor2       NUMBER;
v_BatchSize     INTEGER := 1000;
v_NumRows       INTEGER;
v_customer_id   DBMS_SQL.NUMBER_TABLE;
v_site_use_id   DBMS_SQL.NUMBER_TABLE;
v_currency_code DBMS_SQL.VARCHAR2_TABLE;
v_trx_date      DBMS_SQL.DATE_TABLE;
v_amount        DBMS_SQL.NUMBER_TABLE;
v_cust_trx_id   DBMS_SQL.NUMBER_TABLE;
v_return_code   INTEGER;
text_select     VARCHAR2(4000);
text_update     VARCHAR2(4000);
 begin
  text_select :=
     'SELECT customer_id, customer_site_use_id,
       invoice_currency_code, trunc(trx_date), amount,customer_trx_id
     FROM (
      select customer_id, customer_site_use_id,
             invoice_currency_code,
             trx_date, amount,customer_trx_id,
             RANK() OVER (PARTITION BY customer_id,
                                       customer_site_use_id,
                                       invoice_currency_code,
                                       trx_date
                          ORDER BY amount desc, trx_date desc,
                                      customer_trx_id desc) rank_amount
      from ( select customer_id,customer_site_use_id,
                    invoice_currency_code,customer_trx_id,
                    trx_date,SUM(amount_due_original) amount
             from   ar_payment_schedules_all
             where  class = '||''''||'INV'||''''||
              ' and  customer_id > 0
                and  trx_date >= add_months(sysdate, -24)
             group by customer_id,customer_site_use_id,
                      invoice_currency_code, trx_date, customer_trx_id
            )
     )
     WHERE rank_amount = 1';

  text_update := 'Update ar_trx_summary
                     set LARGEST_INV_AMOUNT = :amount,
                         LARGEST_INV_CUST_TRX_ID = :cust_trx_id,
                         LARGEST_INV_DATE = :trx_date,
		         LAST_UPDATE_DATE  = sysdate,
                         LAST_UPDATED_BY   = FND_GLOBAL.user_id,
                         LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
                  where cust_account_id = :customer_id
                    and SITE_USE_ID = :site_use_id
                    and CURRENCY = :currency_code
                    and AS_OF_DATE = :trx_date';

  v_cursor1 := dbms_sql.open_cursor;
  v_cursor2 := dbms_sql.open_cursor;

  dbms_sql.parse(v_cursor1,text_select,DBMS_SQL.V7);
  dbms_sql.parse(v_cursor2,text_update,DBMS_SQL.V7);

  dbms_sql.define_array(v_cursor1,1,v_customer_id,v_BatchSize,1);
  dbms_sql.define_array(v_cursor1,2,v_site_use_id,v_BatchSize,1);
  dbms_sql.define_array(v_cursor1,3,v_currency_code,v_BatchSize,1);
  dbms_sql.define_array(v_cursor1,4,v_trx_date,v_BatchSize,1);
  dbms_sql.define_array(v_cursor1,5,v_amount,v_BatchSize,1);
  dbms_sql.define_array(v_cursor1,6,v_cust_trx_id,v_BatchSize,1);

   v_return_code := dbms_sql.execute(v_cursor1);

  --This is the fetch loop. Each call to FETCH_ROWS will retrive v_BatchSize
  --rows of data. The loop is over when FETCH_ROWS returns a value< v_BatchSize.

  LOOP

    v_customer_id.delete;
    v_site_use_id.delete;
    v_currency_code.delete;
    v_trx_date.delete;
    v_cust_trx_id.delete;
    v_amount.delete;

    v_NumRows := DBMS_SQL.FETCH_ROWS(v_cursor1);
    DBMS_SQL.COLUMN_VALUE(v_cursor1,1,v_customer_id);
    DBMS_SQL.COLUMN_VALUE(v_cursor1,2,v_site_use_id);
    DBMS_SQL.COLUMN_VALUE(v_cursor1,3,v_currency_code);
    DBMS_SQL.COLUMN_VALUE(v_cursor1,4,v_trx_date);
    DBMS_SQL.COLUMN_VALUE(v_cursor1,5,v_amount);
    DBMS_SQL.COLUMN_VALUE(v_cursor1,6,v_cust_trx_id);

   --The special case of v_NumRows = 0 needs to be checked here. This
   --means that the previous fetch returned all the remaining rows and
   --therefore we are done with the loop.

    if (v_NumRows = 0)  then
     EXIT;
    end if;

  --Use BIND_ARRAYS to specify the input variables for the insert.
  --only elements 1..V_NumRows will be used.

    DBMS_SQL.BIND_ARRAY(v_cursor2,':amount',v_amount);
    DBMS_SQL.BIND_ARRAY(v_cursor2,':cust_trx_id',v_cust_trx_id);
    DBMS_SQL.BIND_ARRAY(v_cursor2,':customer_id',v_customer_id);
    DBMS_SQL.BIND_ARRAY(v_cursor2,':site_use_id',v_site_use_id);
    DBMS_SQL.BIND_ARRAY(v_cursor2,':currency_code',v_currency_code);
    DBMS_SQL.BIND_ARRAY(v_cursor2,':trx_date',v_trx_date);

    v_return_code := DBMS_SQL.EXECUTE(v_cursor2);

    EXIT WHEN v_NumRows < v_BatchSize;
    COMMIT;
  END LOOP;
  COMMIT;
    DBMS_SQL.CLOSE_CURSOR(v_cursor1);
    DBMS_SQL.CLOSE_CURSOR(v_cursor2);

 END;


   /*--------------------------------------------+
    |                                            |
    | LOGIC TO UPDATE THE HIGHWATER MARK BALANCE |
    | IN AR_TRX_SUMMARY                          |
    |                                            |
    +--------------------------------------------*/

declare
v_cursor1       NUMBER;
v_cursor2       NUMBER;
v_BatchSize     INTEGER := 1000;
v_NumRows       INTEGER;
v_customer_id   DBMS_SQL.NUMBER_TABLE;
v_site_use_id   DBMS_SQL.NUMBER_TABLE;
v_currency_code DBMS_SQL.VARCHAR2_TABLE;
v_trx_date      DBMS_SQL.DATE_TABLE;
v_cum_balance   DBMS_SQL.NUMBER_TABLE;
v_return_code   INTEGER;
text_select     VARCHAR2(4000);
text_update     VARCHAR2(4000);
 begin
  text_select :=
'select customer_id, customer_site_use_id, invoice_currency_code,
       as_of_date , cum_balance
from (
select customer_id, customer_site_use_id, invoice_currency_code,
       as_of_date , sum(net_amount) OVER (PARTITION BY customer_id,
        customer_site_use_id, invoice_currency_code
        ORDER BY customer_id, customer_site_use_id,
        invoice_currency_code ROWS UNBOUNDED PRECEDING) cum_balance
from (
select customer_id, customer_site_use_id, invoice_currency_code,
       as_of_date , sum(net_amount) net_amount
from
(select ps.customer_id, ps.customer_site_use_id, ps.invoice_currency_code,
        ps.trx_date as_of_date, sum(ps.amount_due_original) net_amount
 from  ar_payment_schedules_all ps
 where ps.class in ('||''''||'INV'||''''||','
                     ||''''||'CM'||''''||','
                     ||''''||'DM'||''''||','
                     ||''''||'DEP'||''''||','
                     ||''''||'BR'||''''||','
                     ||''''||'CB'||''''||')
 and ps.customer_id > 0
 group by ps.customer_id, ps.customer_site_use_id,
          ps.invoice_currency_code, ps.trx_date
 union all
 select ps.customer_id, ps.customer_site_use_id, ps.invoice_currency_code,
        ra.apply_date as_of_date,
        sum(-ra.amount_applied
            -nvl(ra.earned_discount_taken,0)
            -nvl(ra.unearned_discount_taken,0)) net_amount
 from ar_payment_schedules_all ps,
      ar_receivable_applications_all ra
 where ps.payment_schedule_id = ra.applied_payment_schedule_id
  and  ps.customer_id > 0
  and  ra.status = '||''''||'APP'||''''||'
  and  ra.application_type = '||''''||'CASH'||''''||'
  and  nvl(ra.confirmed_flag,'||''''||'Y'||''''||') = '||''''||'Y'||''''||'
  and  ps.class in ('||''''||'INV'||''''||','
                     ||''''||'CM'||''''||','
                     ||''''||'DM'||''''||','
                     ||''''||'DEP'||''''||','
                     ||''''||'BR'||''''||','
                     ||''''||'CB'||''''||')
 group by ps.customer_id, ps.customer_site_use_id,
          ps.invoice_currency_code, ra.apply_date
 union all
 select ps.customer_id, ps.customer_site_use_id, ps.invoice_currency_code,
        adj.apply_date as_of_date, sum(adj.amount)
 from  ar_payment_schedules_all ps,
       ar_adjustments_all adj
 where ps.payment_schedule_id = adj.payment_schedule_id
  and  ps.class in ('||''''||'INV'||''''||','
                     ||''''||'CM'||''''||','
                     ||''''||'DM'||''''||','
                     ||''''||'DEP'||''''||','
                     ||''''||'BR'||''''||','
                     ||''''||'CB'||''''||')
  and  adj.status = '||''''||'A'||''''||'
  and  ps.customer_id > 0
 group by ps.customer_id, ps.customer_site_use_id,
          ps.invoice_currency_code, adj.apply_date
)
group by customer_id, customer_site_use_id, invoice_currency_code,
       as_of_date
order by customer_id, customer_site_use_id,  invoice_currency_code,
       as_of_date )
       )
 where as_of_date > add_months(sysdate , -24)';

  text_update :=
             'Update ar_trx_summary
               set   OP_BAL_HIGH_WATERMARK      = :cum_balance,
                     OP_BAL_HIGH_WATERMARK_DATE = :as_of_date,
		     LAST_UPDATE_DATE  = sysdate,
                     LAST_UPDATED_BY   = FND_GLOBAL.user_id,
                     LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
                  where cust_account_id = :customer_id
                    and SITE_USE_ID = :site_use_id
                    and CURRENCY = :currency_code
                    and AS_OF_DATE = :as_of_date';

  v_cursor1 := dbms_sql.open_cursor;
  v_cursor2 := dbms_sql.open_cursor;

  dbms_sql.parse(v_cursor1,text_select,DBMS_SQL.V7);
  dbms_sql.parse(v_cursor2,text_update,DBMS_SQL.V7);

  dbms_sql.define_array(v_cursor1,1,v_customer_id,v_BatchSize,1);
  dbms_sql.define_array(v_cursor1,2,v_site_use_id,v_BatchSize,1);
  dbms_sql.define_array(v_cursor1,3,v_currency_code,v_BatchSize,1);
  dbms_sql.define_array(v_cursor1,4,v_trx_date,v_BatchSize,1);
  dbms_sql.define_array(v_cursor1,5,v_cum_balance,v_BatchSize,1);

   v_return_code := dbms_sql.execute(v_cursor1);

  --This is the fetch loop. Each call to FETCH_ROWS will retrive v_BatchSize
  --rows of data. The loop is over when FETCH_ROWS returns a value< v_BatchSize.

  LOOP

    v_customer_id.delete;
    v_site_use_id.delete;
    v_currency_code.delete;
    v_trx_date.delete;
    v_cum_balance.delete;

    v_NumRows := DBMS_SQL.FETCH_ROWS(v_cursor1);
    DBMS_SQL.COLUMN_VALUE(v_cursor1,1,v_customer_id);
    DBMS_SQL.COLUMN_VALUE(v_cursor1,2,v_site_use_id);
    DBMS_SQL.COLUMN_VALUE(v_cursor1,3,v_currency_code);
    DBMS_SQL.COLUMN_VALUE(v_cursor1,4,v_trx_date);
    DBMS_SQL.COLUMN_VALUE(v_cursor1,5,v_cum_balance);

   --The special case of v_NumRows = 0 needs to be checked here. This
   --means that the previous fetch returned all the remaining rows and
   --therefore we are done with the loop.

    if (v_NumRows = 0)  then
     EXIT;
    end if;

  --Use BIND_ARRAYS to specify the input variables for the insert.
  --only elements 1..V_NumRows will be used.

    DBMS_SQL.BIND_ARRAY(v_cursor2,':cum_balance',v_cum_balance);
    DBMS_SQL.BIND_ARRAY(v_cursor2,':as_of_date',v_trx_date);
    DBMS_SQL.BIND_ARRAY(v_cursor2,':customer_id',v_customer_id);
    DBMS_SQL.BIND_ARRAY(v_cursor2,':site_use_id',v_site_use_id);
    DBMS_SQL.BIND_ARRAY(v_cursor2,':currency_code',v_currency_code);
    DBMS_SQL.BIND_ARRAY(v_cursor2,':as_of_date',v_trx_date);

    v_return_code := DBMS_SQL.EXECUTE(v_cursor2);

    EXIT WHEN v_NumRows < v_BatchSize;
  COMMIT;
  END LOOP;
  COMMIT;
    DBMS_SQL.CLOSE_CURSOR(v_cursor1);
    DBMS_SQL.CLOSE_CURSOR(v_cursor2);

 end;
 ELSE
 /*
       If credit Management is not installed, the parallel dml operation should be disabled(which is already enabled)
       If the dml operations are not disabled then ORA-12839 error will be thrown
 */
 EXECUTE IMMEDIATE 'alter session disable parallel query';

END IF; --is credit management installed

  /* 6149811 - remove ar_conc_process_req row
     and submit child process to submit the events that
     were held during runtime */
  block_events('UNBLOCK',FND_GLOBAL.conc_request_id);
  submit_held_events;

  l_return := fnd_profile.save('AR_CMGT_ALLOW_SUMMARY_TABLE_REFRESH',
                                  'N','APPL',222);


 ELSE
  fnd_file.put_line(fnd_file.log,'The profile AR_CMGT_ALLOW_SUMMARY_TABLE_REFRESH = N');

 END IF;

  /* over commit to insure that deleted rows are recorded */
  COMMIT;

  fnd_file.put_line(fnd_file.log,'AR_TRX_SUMMARY_PKG.refresh_all(-)');
EXCEPTION
 WHEN others THEN
 raise;
END refresh_all;
--------------------------------------------------------------
/* Bug 6149811 - multthreading and performance enhancements
   7518998 - allow small vs large customer list for perf
      p_list_size = ALL or ACTIVE */
--------------------------------------------------------------
PROCEDURE collect_customers(
       p_max_workers    IN NUMBER,
       p_worker_number  IN NUMBER,
       p_list_size      IN VARCHAR2 DEFAULT 'ALL',
       p_cust_id        IN OUT NOCOPY l_cust_id_type) IS

    CURSOR c_cust_all IS
         SELECT DISTINCT customer_id
         FROM   ar_payment_schedules_all
         WHERE  MOD(customer_id, p_max_workers) = p_worker_number
         AND    payment_schedule_id > 0;

    CURSOR c_cust_active IS
         SELECT DISTINCT customer_id
         FROM   ar_payment_schedules_all
         WHERE  MOD(customer_id, p_max_workers) = p_worker_number
         AND    payment_schedule_id > 0
         AND    trx_date > add_months(sysdate, -24);

    l_rows NUMBER;
BEGIN
    arp_standard.debug('arp_trx_summary_pkg.collect_customers()+');
    arp_standard.debug('  p_worker_number = ' || p_worker_number);
    arp_standard.debug('  p_list_size     = ' || p_list_size);

    /* The processing of ar_trx_bal_summary requires all customers,
       but the one for ar_trx_summary only requires active customers.
       So we can rebuild the list for each table separately and
       significantly cust the discarded data from the ar_trx_summary
       routine(s) */
    p_cust_id.delete;

    IF p_list_size = 'ALL'
    THEN
      /* ALL, consider any customer represented in PS table */
         OPEN c_cust_all;
         FETCH c_cust_all BULK COLLECT INTO p_cust_id;
           l_rows := c_cust_all%ROWCOUNT;
         CLOSE c_cust_all;

    ELSE
      /* ACTIVE, meaning with PS rows < 24 months old */
         OPEN c_cust_active;
         FETCH c_cust_active BULK COLLECT INTO p_cust_id;
           l_rows := c_cust_active%ROWCOUNT;
         CLOSE c_cust_active;

      /* Populate GT table for use in HWM and Largest INV subroutines */
      FORALL i IN p_cust_id.FIRST .. p_cust_id.LAST
      INSERT INTO ar_cust_search_gt
         (customer_id)
      VALUES(p_cust_id(i));

      /* FOR i IN p_cust_id.FIRST .. p_cust_id.LAST
         LOOP
            arp_standard.debug('  p_cust_id(' || i || ') = ' || p_cust_id(i));
         END LOOP;  */

    END IF;


      /* Display number of customers in conc log */
      fnd_file.put_line(FND_FILE.LOG, ' worker ' || p_worker_number ||
            ' of ' || p_max_workers || ' number of customers: ' ||
              l_rows);

    arp_standard.debug('  count of distinct customers = ' || l_rows);
    arp_standard.debug('arp_trx_summary_pkg.collect_customers()-');
END collect_customers;


/* 8784962 - Allow for call to this function that only clears
   ar_trx_summary or both ar_trx_bal_summary and ar_trx_summary.

   legal values are A(all), B(bal only), S(summary only) */

PROCEDURE clear_summary_tables(p_table_to_clear IN VARCHAR2) IS
  l_status          VARCHAR2(1);  -- junk variable
  l_industry        VARCHAR2(1);  -- junk variable
  l_schema          VARCHAR2(30);
BEGIN
  IF FND_INSTALLATION.get_app_info('AR', l_status, l_industry, l_schema)
  THEN
     IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Retrieved schema for AR   : ' || l_schema);
     END IF;
  ELSE
     IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Problem retrieving AR schema name from fnd_installation');
     END IF;
     arp_standard.debug('EXCEPTION: arp_trx_summary_pkg.clear_summary_tables');
     RETURN;
  END IF;

  arp_standard.debug('Table to clear = ' || p_table_to_clear);

  /* If schema is set, clear the tables */
  IF l_schema IS NOT NULL
  THEN
    IF PG_DEBUG in ('Y','C')
    THEN
       arp_standard.debug('truncating table data');
    END IF;
    IF p_table_to_clear IN ('A','B')
    THEN
       EXECUTE IMMEDIATE 'truncate table ' || l_schema || '.AR_TRX_BAL_SUMMARY';
    END IF;

    IF p_table_to_clear IN ('A','S')
    THEN
       EXECUTE IMMEDIATE 'truncate table ' || l_schema || '.AR_TRX_SUMMARY';
    END IF;
  END IF;

END clear_summary_tables;

PROCEDURE clear_summary_by_customer(p_cust_id IN l_cust_id_type) IS
BEGIN
  IF PG_DEBUG in ('Y','C')
  THEN
     arp_standard.debug('ar_trx_summary_pkg.clear_summary_by_customer()+');
  END IF;

  FORALL i IN 1..p_cust_id.COUNT
    DELETE FROM AR_TRX_BAL_SUMMARY
    WHERE  cust_account_id = p_cust_id(i);

  FORALL i IN 1..p_cust_id.COUNT
    DELETE FROM AR_TRX_SUMMARY
    WHERE  cust_account_id = p_cust_id(i);

  IF PG_DEBUG in ('Y','C')
  THEN
     arp_standard.debug('ar_trx_summary_pkg.clear_summary_by_customer()-');
  END IF;
END clear_summary_by_customer;

PROCEDURE submit_child_workers(p_max_workers IN NUMBER,
                               p_skip_secondary_processes IN VARCHAR2,
                               p_fast_delete IN VARCHAR2) IS
      l_reqid          NUMBER;
      l_program        VARCHAR2(30) := 'ARSUMREFX' ;
      l_appl_short     VARCHAR2(30) := 'AR' ;

BEGIN
  IF PG_DEBUG in ('Y','C')
  THEN
     arp_standard.debug('ar_trx_summary_pkg.submit_child_workers()+');
  END IF;

  FOR i IN 1..(p_max_workers - 1) LOOP
         l_reqid :=  FND_REQUEST.SUBMIT_REQUEST (
                              application=>l_appl_short,
                              program=>l_program,
                              sub_request=>FALSE,
			      argument1=>p_max_workers,
			      argument2=>i,
                              argument3=>p_skip_secondary_processes,
                              argument4=>p_fast_delete );
  END LOOP;

  /* forced commit to get child workers active */
  COMMIT;

  IF PG_DEBUG in ('Y','C')
  THEN
     arp_standard.debug('ar_trx_summary_pkg.submit_child_workers()-');
  END IF;

END submit_child_workers;

PROCEDURE submit_held_events IS
      l_reqid          NUMBER;
      l_program        VARCHAR2(30) := 'ARSUMREFEV' ;
      l_appl_short     VARCHAR2(30) := 'AR' ;

BEGIN
  IF PG_DEBUG in ('Y','C')
  THEN
     arp_standard.debug('ar_trx_summary_pkg.submit_held_events()+');
  END IF;

    l_reqid :=  FND_REQUEST.SUBMIT_REQUEST (
                          application=>l_appl_short,
                          program=>l_program,
                          sub_request=>FALSE);

  IF PG_DEBUG in ('Y','C')
  THEN
     arp_standard.debug('  request_id = ' || l_reqid);
     arp_standard.debug('ar_trx_summary_pkg.submit_held_events()-');
  END IF;

END submit_held_events;

PROCEDURE block_events(p_action IN VARCHAR2,
                       p_request_id IN NUMBER) IS
BEGIN
  IF PG_DEBUG in ('Y','C')
  THEN
     arp_standard.debug('ar_trx_summary_pkg.block_events()+');
     arp_standard.debug('   p_action = ' || p_action);
     arp_standard.debug('   p_request_id = ' || p_request_id);
  END IF;

  IF p_action = 'BLOCK'
  THEN
     INSERT INTO AR_CONC_PROCESS_REQUESTS
        (CONCURRENT_PROGRAM_NAME, REQUEST_ID)
        VALUES ('ARSUMREF',p_request_id);
  ELSIF p_action = 'UNBLOCK'
  THEN
     DELETE FROM AR_CONC_PROCESS_REQUESTS
       WHERE CONCURRENT_PROGRAM_NAME = 'ARSUMREF'
       AND   REQUEST_ID = p_request_id;
  ELSE
     IF PG_DEBUG in ('Y','C')
     THEN
        arp_standard.debug('EXCEPTION:  Invalid p_action value');
     END IF;
  END IF;

  COMMIT;

  IF PG_DEBUG in ('Y','C')
  THEN
     arp_standard.debug('ar_trx_summary_pkg.block_events()-');
  END IF;
END;

PROCEDURE load_trx_bal_summary(p_cust_id        IN l_cust_id_type)
IS
BEGIN
  IF PG_DEBUG in ('Y','C')
  THEN
     arp_standard.debug('ar_trx_summary_pkg.load_trx_bal_summary()+');
  END IF;

  FORALL i IN 1..p_cust_id.COUNT
   INSERT INTO AR_TRX_BAL_SUMMARY
     (CUST_ACCOUNT_ID,
      SITE_USE_ID,
      CURRENCY,
      ORG_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      OP_INVOICES_VALUE,
      OP_INVOICES_COUNT,
      OP_CREDIT_MEMOS_VALUE,
      OP_CREDIT_MEMOS_COUNT,
      OP_DEPOSITS_VALUE,
      OP_DEPOSITS_COUNT,
      OP_CHARGEBACK_VALUE,
      OP_CHARGEBACK_COUNT,
      OP_DEBIT_MEMOS_VALUE,
      OP_DEBIT_MEMOS_COUNT,
      OP_BILLS_RECEIVABLES_VALUE,
      OP_BILLS_RECEIVABLES_COUNT,
      UNRESOLVED_CASH_VALUE,
      UNRESOLVED_CASH_COUNT,
      PAST_DUE_INV_VALUE,
      PAST_DUE_INV_INST_COUNT,
      INV_AMT_IN_DISPUTE,
      DISPUTED_INV_COUNT,
      BEST_CURRENT_RECEIVABLES,
      RECEIPTS_AT_RISK_VALUE,
      LAST_PAYMENT_AMOUNT,
      LAST_PAYMENT_DATE,
      LAST_PAYMENT_NUMBER,
      PENDING_ADJ_VALUE
      )
      (SELECT D.CUSTOMER_ID,
       D.CUSTOMER_SITE_USE_ID,
       D.CURRENCY_CODE,
       D.ORG_ID,
       SYSDATE,
       -2003,
       SYSDATE,
       -2003,
       -2003,
       nvl(SUM(D.OP_INV_SUM),0)   OP_INV_SUM,
       nvl(SUM(D.OP_INV_COUNT),0) OP_INV_COUNT,
       nvl(SUM(D.OP_CM_SUM),0)    OP_CM_SUM,
       nvl(SUM(D.OP_CM_COUNT),0)  OP_CM_COUNT,
       nvl(SUM(D.OP_DEP_SUM),0)   OP_DEP_SUM,
       nvl(SUM(D.OP_DEP_COUNT),0) OP_DEP_COUNT,
       nvl(SUM(D.OP_CB_SUM),0)    OP_CB_SUM,
       nvl(SUM(D.OP_CB_COUNT),0)  OP_CB_COUNT,
       nvl(SUM(D.OP_DM_SUM),0)    OP_DM_SUM,
       nvl(SUM(D.OP_DM_COUNT),0)  OP_DM_COUNT,
       nvl(SUM(D.OP_BR_SUM),0)    OP_BR_SUM,
       nvl(SUM(D.OP_BR_COUNT),0)  OP_BR_COUNT,
       nvl(SUM(D.UNRESOLVED_CASH_VALUE),0)    UNRESOLVED_CASH_VALUE,
       nvl(SUM(D.UNRESOLVED_CASH_COUNT),0)    UNRESOLVED_CASH_COUNT,
       nvl(SUM(D.PAST_DUE_INV_VALUE),0)       PAST_DUE_INV_VALUE,
       nvl(SUM(D.PAST_DUE_INV_COUNT),0)       PAST_DUE_INV_COUNT,
       nvl(SUM(D.INV_AMT_IN_DISPUTE),0)       INV_AMT_IN_DISPUTE,
       nvl(SUM(D.INV_DISPUTE_COUNT),0)        INV_DISPUTE_COUNT,
       nvl(SUM(D.BEST_CURRENT_RECEIVABLES),0) BEST_CURRENT_RECEIVABLES,
       nvl(SUM(D.RECEIPT_AT_RISK_AMT),0)      RECEIPT_AT_RISK_AMT,
       nvl(SUM(D.LAST_RECEIPT_AMOUNT),0)      LAST_RECEIPT_AMOUNT,
       MAX(D.LAST_RECEIPT_DATE)               LAST_RECEIPT_DATE,
       nvl(MAX(D.LAST_RECEIPT_NUMBER),0)      LAST_RECEIPT_NUMBER,
       nvl(SUM(D.PENDING_ADJ_AMT),0)          PENDING_ADJ_AMT
FROM (
SELECT C.CUSTOMER_ID,
       nvl(C.CUSTOMER_SITE_USE_ID,-99) CUSTOMER_SITE_USE_ID,
       C.INVOICE_CURRENCY_CODE CURRENCY_CODE,
       C.ORG_ID,
       SUM(DECODE(CLASS,'INV', C.AMOUNT_DUE_REMAINING,0))       OP_INV_SUM,
       COUNT(DECODE(CLASS,'INV', DECODE(C.STATUS,'OP',
                           C.PAYMENT_SCHEDULE_ID,NULL),NULL))   OP_INV_COUNT,
       SUM(DECODE(CLASS,'CM', C.AMOUNT_DUE_REMAINING,0) )       OP_CM_SUM,
       COUNT(DECODE(CLASS,'CM', DECODE(C.STATUS,'OP',
                           C.PAYMENT_SCHEDULE_ID,NULL),NULL))   OP_CM_COUNT,
       SUM(DECODE(CLASS,'CB', C.AMOUNT_DUE_REMAINING,0))        OP_CB_SUM,
       COUNT(DECODE(CLASS,'CB',DECODE(C.STATUS, 'OP',
                           C.PAYMENT_SCHEDULE_ID,NULL),NULL))   OP_CB_COUNT,
       SUM(DECODE(C.CLASS,'DEP', C.AMOUNT_DUE_REMAINING) )      OP_DEP_SUM,
       COUNT(DECODE(C.CLASS,'DEP', DECODE(C.STATUS ,'OP',
                           C.PAYMENT_SCHEDULE_ID,NULL),NULL))   OP_DEP_COUNT,
       SUM(DECODE(C.CLASS,'DM', C.AMOUNT_DUE_REMAINING ,0))     OP_DM_SUM,
       COUNT(DECODE(C.CLASS,'DM', DECODE(C.STATUS, 'OP',
                           C.PAYMENT_SCHEDULE_ID,NULL),NULL))   OP_DM_COUNT,
       SUM(DECODE(C.CLASS,'BR', C.AMOUNT_DUE_REMAINING, NULL))  OP_BR_SUM,
       COUNT(DECODE(C.CLASS,'BR', DECODE(C.STATUS, 'OP',
                           C.PAYMENT_SCHEDULE_ID,NULL),NULL))   OP_BR_COUNT,
       SUM(DECODE(C.CLASS,'PMT', C.AMOUNT_DUE_REMAINING * -1, NULL)) UNRESOLVED_CASH_VALUE,
       COUNT(DECODE(C.CLASS,'PMT', DECODE(C.STATUS, 'OP',
                           C.PAYMENT_SCHEDULE_ID,NULL),NULL))   UNRESOLVED_CASH_COUNT,
       SUM(DECODE(CLASS,'INV',DECODE(C.STATUS, 'OP',
                                DECODE(SIGN(TRUNC(SYSDATE) -
                                            TRUNC(NVL(C.DUE_DATE, SYSDATE))),1,
                                  (C.AMOUNT_DUE_ORIGINAL
                                    - NVL(C.AMOUNT_APPLIED,0)
                                    + NVL(C.AMOUNT_ADJUSTED,0)
                                    + NVL(C.AMOUNT_CREDITED,0)),
                                        0),0),0))               PAST_DUE_INV_VALUE,
       COUNT(DECODE(C.CLASS,'INV',DECODE(C.STATUS, 'OP',
                                DECODE(SIGN(TRUNC(SYSDATE) -
                                          TRUNC(NVL(C.DUE_DATE, SYSDATE))),1,
                                          C.PAYMENT_SCHEDULE_ID,
                                          NULL),NULL),NULL))    PAST_DUE_INV_COUNT,
       SUM(DECODE(CLASS,'INV',C.AMOUNT_IN_DISPUTE,0))           INV_AMT_IN_DISPUTE,
       COUNT(DECODE(C.CLASS,'INV',DECODE(C.AMOUNT_IN_DISPUTE,
                                   NULL,NULL,0,NULL,C.PAYMENT_SCHEDULE_ID),
                                   NULL))                       INV_DISPUTE_COUNT,
       SUM(DECODE(C.CLASS,
                   'INV', 1,
                   'DM',  1,
                   'CB',  1,
                   'DEP', 1,
                   'BR',  1,
                    0)
                   * DECODE(SIGN(C.DUE_DATE-SYSDATE),
                          -1,0,C.AMOUNT_DUE_REMAINING ))
                                                                BEST_CURRENT_RECEIVABLES,
       0 RECEIPT_AT_RISK_AMT ,
       0 LAST_RECEIPT_AMOUNT,
       TO_DATE(NULL) LAST_RECEIPT_DATE,
       NULL LAST_RECEIPT_NUMBER,
       SUM(C.AMOUNT_ADJUSTED_PENDING) PENDING_ADJ_AMT
FROM AR_PAYMENT_SCHEDULES_ALL C
WHERE c.customer_id = p_cust_id(i)
GROUP BY C.CUSTOMER_ID,
       C.CUSTOMER_SITE_USE_ID,
       C.INVOICE_CURRENCY_CODE ,
       C.ORG_ID
UNION ALL
SELECT  /*+ LEADING a1 INDEX (B ar_cash_receipts_u1) */
        A1.CUSTOMER_ID,
        A1.CUSTOMER_SITE_USE_ID,
        A1.CURRENCY,
        A1.ORG_ID ,
        0 OP_INV_SUM,
       0 OP_INV_COUNT,
       0 OP_CM_SUM,
       0 OP_CM_COUNT,
       0 OP_CB_SUM,
       0 OP_CB_COUNT,
       0 OP_DEP_SUM,
       0 OP_DEP_COUNT,
       0 OP_DM_SUM,
       0 OP_DM_COUNT,
       0 OP_BR_SUM,
       0 OP_BR_COUNT,
       0 UNRESOLVED_CASH_VALUE,
       0 UNRESOLVED_CASH_COUNT,
       0 PAST_DUE_INV_VALUE,
       0 PAST_DUE_INV_COUNT,
       0 INV_AMT_IN_DISPUTE,
       0 INV_DISPUTE_COUNT,
       0 BEST_CURRENT_RECEIVABLES_ADO,
       0 RECEIPT_AT_RISK_AMT,
       B.AMOUNT         LAST_RECEIPT_AMOUNT,
       B.RECEIPT_DATE   LAST_RECEIPT_DATE,
       B.RECEIPT_NUMBER LAST_RECEIPT_NUMBER,
       0 PENDING_ADJ_AMT
FROM (
select /*+ INDEX (cr ar_cash_receipts_n2) */
       cr.pay_from_customer  customer_id,
       nvl(cr.customer_site_use_id, -99) customer_site_use_id,
       cr.currency_code currency,
       cr.org_id,
       to_number(substr(max(
          to_char(cr.receipt_date, 'YYYYMMDD') ||
          ltrim(to_char(cr.cash_receipt_id, '0999999999999999999999'))),9)) last_cash_receipt_id
from   ar_cash_receipts_all cr
where  NVL(cr.confirmed_flag, 'Y') = 'Y'
and    cr.reversal_date is null
and    cr.pay_from_customer = p_cust_id(i)
and    cr.type = 'CASH'
group by pay_from_customer, customer_site_use_id, currency_code, org_id)  a1,
      AR_CASH_RECEIPTS_ALL B
WHERE a1.LAST_CASH_RECEIPT_ID  = B.CASH_RECEIPT_ID
UNION ALL
SELECT /*+ LEADING(cr) INDEX(cr,AR_CASH_RECEIPTS_N2) */
       CR.PAY_FROM_CUSTOMER CUSTOMER_ID,
       NVL(CR.CUSTOMER_SITE_USE_ID,-99) CUSTOMER_SITE_USE_ID,
       CR.CURRENCY_CODE CURRENCY_CODE,
       CR.ORG_ID ORG_ID,
       0 OP_INV_SUM,
       0 OP_INV_COUNT,
       0 OP_CM_SUM,
       0 OP_CM_COUNT,
       0 OP_CB_SUM,
       0 OP_CB_COUNT,
       0 OP_DEP_SUM,
       0 OP_DEP_COUNT,
       0 OP_DM_SUM,
       0 OP_DM_COUNT,
       0 OP_BR_SUM,
       0 OP_BR_COUNT,
       0 UNRESOLVED_CASH_VALUE,
       0 UNRESOLVED_CASH_COUNT,
       0 PAST_DUE_INV_VALUE,
       0 PAST_DUE_INV_COUNT,
       0 INV_AMT_IN_DISPUTE,
       0 INV_DISPUTE_COUNT,
       0 BEST_CURRENT_RECEIVABLES_ADO,
       SUM(DECODE(RAP.APPLIED_PAYMENT_SCHEDULE_ID, -2, NULL, CRH.AMOUNT))
                                                           RECEIPT_AT_RISK_AMT,
       0 LAST_RECEIPT_AMOUNT,
       TO_DATE(NULL) LAST_RECEIPT_DATE,
       NULL LAST_RECEIPT_NUMBER,
       0 PENDING_ADJ_AMT
 FROM AR_CASH_RECEIPTS_ALL CR,
      AR_CASH_RECEIPT_HISTORY_ALL CRH,
      AR_RECEIVABLE_APPLICATIONS_ALL RAP
 WHERE NVL(CR.CONFIRMED_FLAG, 'Y') = 'Y'
   AND CR.REVERSAL_DATE IS NULL
   AND CR.CASH_RECEIPT_ID = CRH.CASH_RECEIPT_ID
   AND CR.PAY_FROM_CUSTOMER = p_cust_id(i)
   AND CRH.CURRENT_RECORD_FLAG = 'Y'
   AND CRH.STATUS NOT IN (DECODE (CRH.FACTOR_FLAG, 'Y', 'RISK_ELIMINATED',
                                        'N', 'CLEARED'), 'REVERSED')
   AND RAP.CASH_RECEIPT_ID(+) = CR.CASH_RECEIPT_ID
   AND RAP.APPLIED_PAYMENT_SCHEDULE_ID(+) = -2
 GROUP BY CR.PAY_FROM_CUSTOMER,NVL(CR.CUSTOMER_SITE_USE_ID,-99),
          CR.ORG_ID,CR.CURRENCY_CODE
) D
GROUP BY D.CUSTOMER_ID,D.CUSTOMER_SITE_USE_ID,D.CURRENCY_CODE,D.ORG_ID);

  IF PG_DEBUG in ('Y','C')
  THEN
     arp_standard.debug('ar_trx_summary_pkg.load_trx_bal_summary()-');
  END IF;

END load_trx_bal_summary;

PROCEDURE load_trx_summary(p_cust_id IN l_cust_id_type)
IS
BEGIN
  IF PG_DEBUG in ('Y','C')
  THEN
     arp_standard.debug('ar_trx_summary_pkg.load_trx_summary()+');
  END IF;

  /* Dev Note:  I think I can further simplify this code .. particularly
     the logic for:
      COUNT_OF_INV_INST_PAID_LATE
      COUNT_OF_TOT_INV_INST_PAID
      INV_PAID_AMOUNT  */

  FORALL i IN 1..p_cust_id.COUNT
  INSERT into ar_trx_summary
   (CUST_ACCOUNT_ID,
    SITE_USE_ID,
    CURRENCY,
    ORG_ID,
    AS_OF_DATE,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    TOTAL_INVOICES_VALUE,
    TOTAL_INVOICES_COUNT,
    TOTAL_CREDIT_MEMOS_VALUE ,
    TOTAL_CREDIT_MEMOS_COUNT,
    TOTAL_CHARGEBACK_VALUE,
    TOTAL_CHARGEBACK_COUNT,
    TOTAL_DEPOSITS_VALUE,
    TOTAL_DEPOSITS_COUNT,
    TOTAL_DEBIT_MEMOS_VALUE,
    TOTAL_DEBIT_MEMOS_COUNT,
    TOTAL_BILLS_RECEIVABLES_VALUE,
    TOTAL_BILLS_RECEIVABLES_COUNT,
    TOTAL_CASH_RECEIPTS_VALUE,
    TOTAL_CASH_RECEIPTS_COUNT,
    COUNT_OF_DISC_INV_INST,
    DAYS_CREDIT_GRANTED_SUM,
    COUNT_OF_INV_INST_PAID_LATE,
    COUNT_OF_TOT_INV_INST_PAID,
    INV_PAID_AMOUNT,
    INV_INST_PMT_DAYS_SUM,
    NSF_STOP_PAYMENT_COUNT,
    NSF_STOP_PAYMENT_AMOUNT,
    SUM_APP_AMT,
    TOTAL_EARNED_DISC_VALUE,
    TOTAL_EARNED_DISC_COUNT,
    TOTAL_UNEARNED_DISC_VALUE,
    TOTAL_UNEARNED_DISC_COUNT,
    SUM_APP_AMT_DAYS_LATE,
    TOTAL_ADJUSTMENTS_VALUE,
    TOTAL_ADJUSTMENTS_COUNT)
    ( select D.customer_id,
        D.customer_site_use_id,
        D.currency_code,
        D.org_id,
        D.as_of_date,
        sysdate,
        -2003,
        sysdate,
        -2003,
        -2003,
        sum(decode(D.TOT_INV_SUM,0,null,D.TOT_INV_SUM)) TOT_INV_SUM,
        sum(decode(D.TOT_INV_COUNT,0,null,D.TOT_INV_COUNT)) TOT_INV_COUNT,
        SUM(decode(D.TOT_CM_SUM,0,null,D.TOT_CM_SUM)) TOT_CM_SUM,
        SUM(decode(D.TOT_CM_COUNT,0,null,D.TOT_CM_COUNT)) TOT_CM_COUNT,
        sum(decode(D.TOT_CB_SUM,0,null,D.TOT_CB_SUM)) TOT_CB_SUM,
        SUM(decode(D.TOT_CB_COUNT,0,null,D.TOT_CB_COUNT)) TOT_CB_COUNT,
        SUM(decode(D.TOT_DEP_SUM,0,null,D.TOT_DEP_SUM)) TOT_DEP_SUM,
        SUM(decode(D.TOT_DEP_COUNT,0,null,D.TOT_DEP_COUNT)) TOT_DEP_COUNT,
        SUM(decode(D.TOT_DM_SUM,0,null,D.TOT_DM_SUM)) TOT_DM_SUM,
        SUM(decode(D.TOT_DM_COUNT,0,null,D.TOT_DM_COUNT)) TOT_DM_COUNT,
        SUM(decode(D.TOT_BR_SUM,0,null,D.TOT_BR_SUM)) TOT_BR_SUM,
        SUM(decode(D.TOT_BR_COUNT,0,null,D.TOT_BR_COUNT)) TOT_BR_COUNT,
        SUM(decode(D.TOT_PMT_SUM,0,null,D.TOT_PMT_SUM)) TOT_PMT_SUM,
        SUM(decode(D.TOT_PMT_COUNT,0,null,D.TOT_PMT_COUNT)) TOT_PMT_COUNT,
        SUM(decode(D.disc_inv_inst_count,0,null,D.disc_inv_inst_count)) disc_inv_inst_count,
        SUM(decode(D.days_credit_granted_sum,0,null,D.days_credit_granted_sum)) days_credit_granted_sum,
        SUM(decode(D.COUNT_OF_INV_INST_PAID_LATE,0,null,D.COUNT_OF_INV_INST_PAID_LATE)) COUNT_OF_INV_INST_PAID_LATE,
        SUM(decode(D.COUNT_OF_TOT_INV_INST_PAID,0,null,D.COUNT_OF_TOT_INV_INST_PAID)) COUNT_OF_TOT_INV_INST_PAID,
        SUM(decode(D.INV_PAID_AMOUNT,0,null,D.INV_PAID_AMOUNT)) INV_PAID_AMOUNT,
        SUM(decode(D.inv_inst_pmt_days_sum,0,null,D.inv_inst_pmt_days_sum)) inv_inst_pmt_days_sum,
        sum(decode(D.NSF_STOP_PAYMENT_COUNT,0,null,D.NSF_STOP_PAYMENT_COUNT)) NSF_STOP_PAYMENT_COUNT,
        sum(decode(D.NSF_STOP_PAYMENT_AMOUNT,0,null,D.NSF_STOP_PAYMENT_AMOUNT)) NSF_STOP_PAYMENT_AMOUNT,
        sum(decode(D.sum_amt_applied,0,null,D.sum_amt_applied)) sum_amt_applied,
        sum(decode(D.edisc_taken,0,null,D.edisc_taken)) edisc_taken,
        sum(decode(D.edisc_taken,0,null,D.edisc_count)) edisc_count,
        sum(decode(D.unedisc_taken,0,null,D.unedisc_taken)) unedisc_taken,
        sum(decode(D.unedisc_taken,0,null,D.unedisc_count)) unedisc_count,
        sum(decode(D.app_amt_days_late,0,null,D.app_amt_days_late)) app_amt_days_late,
        sum(decode(D.adj_amount,0,null,D.adj_amount)) adj_amount,
        sum(decode(D.adj_count,0,null,D.adj_count)) adj_count
from ( select  C.customer_id,
        C.customer_site_use_id,
        C.currency_code,
        C.org_id,
        C.trx_date as_of_date,
        sum(DECODE(C.class,'INV',C.amount_due_original,0 ))     TOT_INV_SUM,
        count(decode(C.class,'INV',C.payment_schedule_id,null)) TOT_INV_COUNT,
        sum(DECODE(C.class,'CM',C.amount_due_original,0 ))      TOT_CM_SUM,
        count(decode(C.class,'CM',C.payment_schedule_id,null))  TOT_CM_COUNT,
        sum(DECODE(C.class,'CB',C.amount_due_original,0 ))      TOT_CB_SUM,
        count(decode(C.class,'CB',C.payment_schedule_id,null))  TOT_CB_COUNT,
        sum(DECODE(C.class,'DEP',C.amount_due_original,0 ))     TOT_DEP_SUM,
        count(decode(C.class,'DEP',C.payment_schedule_id,null)) TOT_DEP_COUNT,
        sum(DECODE(C.class,'DM',C.amount_due_original,0 ))      TOT_DM_SUM,
        count(decode(C.class,'DM',C.payment_schedule_id,null))  TOT_DM_COUNT,
        sum(DECODE(C.class,'BR',C.amount_due_original,0))       TOT_BR_SUM,
        count(decode(C.class,'BR',C.payment_schedule_id,null))  TOT_BR_COUNT,
        sum(DECODE(C.class,'PMT',C.amount_due_original * -1 ,0 ))     TOT_PMT_SUM,
        count(decode(C.class,'PMT',C.payment_schedule_id,null)) TOT_PMT_COUNT,
        sum(DECODE(C.class, 'INV', DECODE((nvl(C.edisc_taken,0) +
               nvl(C.unedisc_taken,0)), 0, 0, 1),0))            DISC_INV_INST_COUNT,
        sum(decode(C.class,'INV',((C.due_date - C.trx_date)*(nvl(C.amount_due_original,0)+
                                   nvl(C.ADJ_AMOUNT,0))),null)) DAYS_CREDIT_GRANTED_SUM,
        sum(decode(C.class,'INV',
                      DECODE(sign(NVL(C.AMOUNT_APPLIED,0)),0,null,
                          DECODE(SIGN((C.AMOUNT_DUE_ORIGINAL
                           - NVL(C.AMOUNT_APPLIED,0)
                           - nvl(C.edisc_taken,0)
                           - nvl(C.unedisc_taken,0)
                           + NVL(C.ADJ_AMOUNT,0))),SIGN(C.AMOUNT_DUE_ORIGINAL),
                            null,
                            decode(sign(C.due_date - C.actual_date_closed),
                            -1, 1,null))),null))                COUNT_OF_INV_INST_PAID_LATE,
        sum(decode(C.class,'INV',
                       DECODE(sign(NVL(C.AMOUNT_APPLIED,0)),0,null,
                           DECODE(SIGN((C.AMOUNT_DUE_ORIGINAL
                           - NVL(C.AMOUNT_APPLIED,0)
                           - nvl(C.edisc_taken,0)
                           - nvl(C.unedisc_taken,0)
                           + NVL(C.ADJ_AMOUNT,0))),SIGN(C.AMOUNT_DUE_ORIGINAL)
                           ,null,
                            1)),null))                           COUNT_OF_TOT_INV_INST_PAID,
        sum(decode(C.class,'INV',DECODE(SIGN((C.AMOUNT_DUE_ORIGINAL
                   - NVL(C.AMOUNT_APPLIED,0)
                   - nvl(C.edisc_taken,0)
                   - nvl(C.unedisc_taken,0)
                   + NVL(C.ADJ_AMOUNT,0))),SIGN(C.AMOUNT_DUE_ORIGINAL),
                    null,nvl(C.amount_applied,0)),null))     INV_PAID_AMOUNT,
        sum(decode(C.class,'INV',1,null))           COUNT_OF_TOT_INV_INST,
        0 inv_inst_pmt_days_sum,
        0 NSF_STOP_PAYMENT_COUNT,
        0 NSF_STOP_PAYMENT_AMOUNT,
        0 sum_amt_applied,
        0 edisc_taken,
        0 edisc_count,
        0 unedisc_taken,
        0 unedisc_count,
        0 app_amt_days_late,
        0 ADJ_AMOUNT,
        0 ADJ_COUNT
 FROM  (
 SELECT A.CUSTOMER_ID,
        A.CUSTOMER_SITE_USE_ID,
        A.CURRENCY_CODE,
        A.ORG_ID ,
        A.CLASS,
        A.DUE_DATE,
        A.TRX_DATE,
        A.actual_date_closed,
        A.PAYMENT_SCHEDULE_ID,
        A.AMOUNT_DUE_ORIGINAL,
        A.AMOUNT_IN_DISPUTE,
        A.AMOUNT_APPLIED,
        A.edisc_taken,
        A.unedisc_taken,
        SUM(ADJ.amount) adj_amount
  FROM (
  SELECT  PS.CUSTOMER_ID,
       NVL(PS.CUSTOMER_SITE_USE_ID,-99) CUSTOMER_SITE_USE_ID,
       PS.INVOICE_CURRENCY_CODE CURRENCY_CODE,
       PS.ORG_ID,
       PS.CLASS,
       PS.DUE_DATE DUE_DATE,
       PS.TRX_DATE,
       PS.actual_date_closed,
       PS.PAYMENT_SCHEDULE_ID,
       PS.AMOUNT_DUE_ORIGINAL,
       PS.AMOUNT_IN_DISPUTE AMOUNT_IN_DISPUTE,
       SUM(  RA.AMOUNT_APPLIED) AMOUNT_APPLIED,
       sum(decode(ps.class, 'INV',
                decode(ra.earned_discount_taken,0,
                         null,ra.earned_discount_taken), null)) edisc_taken,
       sum(decode(ps.class, 'INV',
                decode(ra.unearned_discount_taken,0,
                         null,ra.unearned_discount_taken), null)) unedisc_taken
   FROM  AR_PAYMENT_SCHEDULES_all ps,
         AR_RECEIVABLE_APPLICATIONS_ALL RA
  WHERE  RA.APPLIED_PAYMENT_SCHEDULE_ID(+) = PS.PAYMENT_SCHEDULE_ID
    AND  RA.DISPLAY(+) = 'Y'
    AND  RA.STATUS(+) = 'APP'
    AND  PS.CUSTOMER_ID = p_cust_id(i)
    AND  RA.APPLY_DATE(+) >= add_months(sysdate, -24)
    AND  PS.TRX_DATE >= add_months(sysdate, -24)
 GROUP BY PS.CUSTOMER_ID,  NVL(PS.CUSTOMER_SITE_USE_ID,-99),
          PS.INVOICE_CURRENCY_CODE, PS.ORG_ID,
          PS.CLASS, PS.TRX_DATE, PS.DUE_DATE,
          PS.AMOUNT_DUE_ORIGINAL,
          PS.amount_in_dispute,
          ps.actual_date_closed, PS.PAYMENT_SCHEDULE_ID
       ) A,
         AR_ADJUSTMENTS_ALL ADJ
  WHERE A.PAYMENT_SCHEDULE_ID = ADJ.PAYMENT_SCHEDULE_ID(+)
    AND  ADJ.STATUS(+) = 'A'
 GROUP BY A.CUSTOMER_ID,  A.CUSTOMER_SITE_USE_ID,
          A.CURRENCY_CODE, A.ORG_ID,
          A.CLASS, A.TRX_DATE,A.DUE_DATE,
          A.AMOUNT_DUE_ORIGINAL, A.AMOUNT_IN_DISPUTE,
          A.actual_date_closed,A.AMOUNT_APPLIED,
          A.edisc_taken,A.unedisc_taken,
          A.PAYMENT_SCHEDULE_ID
      ) C
 group by C.customer_id,
        C.customer_site_use_id,
        C.currency_code,
        C.org_id,
        C.trx_date
UNION
select  cr.pay_from_customer customer_id,
        nvl(cr.customer_site_use_id,-99) customer_site_use_id,
        cr.currency_code invoice_currency_code,
        cr.org_id,
        cr.reversal_date as_of_date,
        0 TOT_INV_SUM,
        0 TOT_INV_COUNT,
        0 TOT_CM_SUM,
        0 TOT_CM_COUNT,
        0 TOT_CB_SUM,
        0 TOT_CB_COUNT,
        0 TOT_DEP_SUM,
        0 TOT_DEP_COUNT,
        0 TOT_DM_SUM,
        0 TOT_DM_COUNT,
        0 TOT_BR_SUM,
        0 TOT_BR_COUNT,
        0 TOT_PMT_SUM,
        0 TOT_PMT_COUNT,
        0 disc_inv_inst_count,
        0 days_credit_granted_sum,
        0 COUNT_OF_INV_INST_PAID_LATE,
        0 COUNT_OF_TOT_INV_INST_PAID,
        0 INV_PAID_AMOUNT,
        0 COUNT_OF_TOT_INV_INST,
        0 inv_inst_pmt_days,
        count(cr.cash_receipt_id) NSF_STOP_PAYMENT_COUNT,
        sum(cr.amount) NSF_STOP_PAYMENT_AMOUNT,
        0 sum_amt_applied,
        0 edisc_taken,
        0 edisc_count,
        0 unedisc_taken,
        0 unedisc_count,
        0 app_amt_days_late,
        0 adj_amount,
        0 adj_count
 from   ar_cash_receipts_all cr,
        ar_cash_receipt_history_all crh
 where  cr.cash_receipt_id = crh.cash_receipt_id
    and crh.current_record_flag = 'Y'
    and crh.status = 'REVERSED'
    and cr.status = 'REV'
    and cr.reversal_category = 'NSF'
    and cr.reversal_date > add_months(sysdate, -24)
    and cr.pay_from_customer = p_cust_id(i)
 group by cr.pay_from_customer,
        nvl(cr.customer_site_use_id,-99),
        cr.currency_code,
        cr.org_id,
        cr.reversal_date
UNION
select  customer_id,
        customer_site_use_id,
        invoice_currency_code,
        org_id,
        apply_date as_of_date,
        0 TOT_INV_SUM,
        0 TOT_INV_COUNT,
        0 TOT_CM_SUM,
        0 TOT_CM_COUNT,
        0 TOT_CB_SUM,
        0 TOT_CB_COUNT,
        0 TOT_DEP_SUM,
        0 TOT_DEP_COUNT,
        0 TOT_DM_SUM,
        0 TOT_DM_COUNT,
        0 TOT_BR_SUM,
        0 TOT_BR_COUNT,
        0 TOT_PMT_SUM,
        0 TOT_PMT_COUNT,
        0 disc_inv_inst_count,
        0 days_credit_granted_sum,
        0 COUNT_OF_INV_INST_PAID_LATE,
        0 COUNT_OF_TOT_INV_INST_PAID,
        0 INV_PAID_AMOUNT,
        0 COUNT_OF_TOT_INV_INST,
        sum(decode(inv_inst_pmt_days,0,null,inv_inst_pmt_days)) inv_inst_pmt_days,
        0 NSF_STOP_PAYMENT_COUNT,
        0 NSF_STOP_PAYMENT_AMOUNT,
        sum(decode(sum_amt_applied,0,null,sum_amt_applied)) sum_amt_applied,
        sum(decode(edisc_taken,0,null,edisc_taken)) edisc_taken,
        sum(decode(edisc_taken,0,null,edisc_count)) edisc_count,
        sum(decode(unedisc_taken,0,null,unedisc_taken)) unedisc_taken,
        sum(decode(unedisc_taken,0,null,unedisc_count)) unedisc_count,
        sum(decode(app_amt_days_late,0,null,app_amt_days_late)) app_amt_days_late,
        0 adj_amount,
        0 adj_count
from ( select ps.customer_id,
        ps.customer_site_use_id,
        ps.invoice_currency_code,
        ps.org_id,
        trunc(ra.apply_date) apply_date,
        ra.cash_receipt_id,
        ra.applied_payment_schedule_id,
        sum(decode(ps.class, 'INV',ra.amount_applied,0)) sum_amt_applied,
        sum(decode(ps.class, 'INV',((ra.apply_date - (ps.trx_date + nvl(rt.printing_lead_days,0)))
                                  * (nvl(ra.amount_applied,0))),null)) inv_inst_pmt_days,
        sum(decode(ps.class, 'INV', decode(ra.earned_discount_taken,0,null,ra.earned_discount_taken), null)) edisc_taken,
        sum(decode(ps.class, 'INV',decode(nvl(ra.earned_discount_taken,0),0,null,1),null)) edisc_count,
        sum(decode(ps.class, 'INV', decode(ra.unearned_discount_taken,0,null,ra.unearned_discount_taken), null)) unedisc_taken,
        sum(decode(ps.class, 'INV',decode(nvl(ra.unearned_discount_taken,0),0,null,1),null)) unedisc_count,
        sum(decode(ps.class, 'INV',
        (ra.apply_date - ps.due_date) * ra.amount_applied, null)) app_amt_days_late
 from   ar_payment_schedules_all ps,
        ra_terms_b rt,
        ar_receivable_applications_all ra
 where  ps.payment_schedule_id = ra.applied_payment_schedule_id
  and   ps.customer_id = p_cust_id(i)
  and   ps.term_id = rt.term_id(+)
  and   ra.status =  'APP'
  and   ra.display = 'Y'
  and   ra.application_type = 'CASH'
  and   ra.apply_date >= add_months(sysdate, -24)
  group by ps.customer_id,
        ps.customer_site_use_id,
        ps.invoice_currency_code,
        ps.org_id,
        trunc(ra.apply_date),
        ra.cash_receipt_id,
        ra.applied_payment_schedule_id
        )
  group by customer_id,
        customer_site_use_id,
        invoice_currency_code,
        org_id,
        apply_date
UNION
select  ps.customer_id,
        ps.customer_site_use_id,
        ps.invoice_currency_code,
        ps.org_id,
        adj.apply_date as_of_date,
        0 TOT_INV_SUM,
        0 TOT_INV_COUNT,
        0 TOT_CM_SUM,
        0 TOT_CM_COUNT,
        0 TOT_CB_SUM,
        0 TOT_CB_COUNT,
        0 TOT_DEP_SUM,
        0 TOT_DEP_COUNT,
        0 TOT_DM_SUM,
        0 TOT_DM_COUNT,
        0 TOT_BR_SUM,
        0 TOT_BR_COUNT,
        0 TOT_PMT_SUM,
        0 TOT_PMT_COUNT,
        0 disc_inv_inst_count,
        0 days_credit_granted_sum,
        0 COUNT_OF_INV_INST_PAID_LATE,
        0 COUNT_OF_TOT_INV_INST_PAID,
        0 INV_PAID_AMOUNT,
        0 COUNT_OF_TOT_INV_INST,
        0 inv_inst_pmt_days,
        0 NSF_STOP_PAYMENT_COUNT,
        0 NSF_STOP_PAYMENT_AMOUNT,
        0 sum_amt_applied,
        0 edisc_taken,
        0 edisc_count,
        0 unedisc_taken,
        0 unedisc_count,
        0 app_amt_days_late,
        sum(adj.amount) adj_amount,
        count(adjustment_id) adj_count
 from   ar_payment_schedules_all ps,
        ar_adjustments_all adj
 where  ps.customer_id = p_cust_id(i)
   and  ps.payment_schedule_id = adj.payment_schedule_id
   and  adj.receivables_trx_id(+) > 0
   and  ps.trx_date > add_months(sysdate, -24)
   and  adj.status = 'A'
   and  adj.apply_date > add_months(sysdate, -24)
group by ps.customer_id,
         ps.customer_site_use_id,
         ps.invoice_currency_code,
         ps.org_id,
         adj.apply_date
) D
group by D.customer_id,
        D.customer_site_use_id,
        D.currency_code,
        D.org_id,
        D.as_of_date);

  IF PG_DEBUG in ('Y','C')
  THEN
     arp_standard.debug('ar_trx_summary_pkg.load_trx_summary()-');
  END IF;
END load_trx_summary;

PROCEDURE load_largest_inv_info
IS
v_cursor1       NUMBER;
v_cursor2       NUMBER;
v_BatchSize     INTEGER := 1000;
v_NumRows       INTEGER;
v_customer_id   DBMS_SQL.NUMBER_TABLE;
v_site_use_id   DBMS_SQL.NUMBER_TABLE;
v_currency_code DBMS_SQL.VARCHAR2_TABLE;
v_trx_date      DBMS_SQL.DATE_TABLE;
v_amount        DBMS_SQL.NUMBER_TABLE;
v_cust_trx_id   DBMS_SQL.NUMBER_TABLE;
v_return_code   INTEGER;
text_select     VARCHAR2(4000);
text_update     VARCHAR2(4000);

BEGIN
  IF PG_DEBUG in ('Y','C')
  THEN
     arp_standard.debug('ar_trx_summary_pkg.load_largest_inv_info()+');
  END IF;

  text_select :=
     'SELECT customer_id, customer_site_use_id,
       invoice_currency_code, trunc(trx_date), amount,customer_trx_id
     FROM (
      select customer_id, customer_site_use_id,
             invoice_currency_code,
             trx_date, amount,customer_trx_id,
             RANK() OVER (PARTITION BY customer_id,
                                       customer_site_use_id,
                                       invoice_currency_code,
                                       trx_date
                          ORDER BY amount desc, trx_date desc,
                                      customer_trx_id desc) rank_amount
      from ( select ps.customer_id, ps.customer_site_use_id,
                    ps.invoice_currency_code, ps.customer_trx_id,
                    ps.trx_date, SUM(ps.amount_due_original) amount
             from   ar_payment_schedules_all ps,
                    ar_cust_search_gt gt
             where  ps.customer_id = gt.customer_id
             and    ps.class = '||''''||'INV'||''''||
              ' and  trx_date >= add_months(sysdate, -24)
             group by ps.customer_id, ps.customer_site_use_id,
                      ps.invoice_currency_code, ps.trx_date, ps.customer_trx_id
            )
     )
     WHERE rank_amount = 1';

  IF PG_DEBUG in ('Y','C')
  THEN
     arp_standard.debug(text_select);
  END IF;

  text_update := 'Update /*+ INDEX(ats AR_TRX_SUMMARY_U1) */ ar_trx_summary ats
                    set LARGEST_INV_AMOUNT = :amount,
                        LARGEST_INV_CUST_TRX_ID = :cust_trx_id,
                        LARGEST_INV_DATE = :trx_date,
                        LAST_UPDATE_DATE  = sysdate,
                        LAST_UPDATED_BY   = FND_GLOBAL.user_id,
                        LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
                  where cust_account_id = :customer_id
                    and SITE_USE_ID = :site_use_id
                    and CURRENCY = :currency_code
                    and AS_OF_DATE = :trx_date';

  v_cursor1 := dbms_sql.open_cursor;
  v_cursor2 := dbms_sql.open_cursor;

  dbms_sql.parse(v_cursor1,text_select,DBMS_SQL.V7);
  dbms_sql.parse(v_cursor2,text_update,DBMS_SQL.V7);

  dbms_sql.define_array(v_cursor1,1,v_customer_id,v_BatchSize,1);
  dbms_sql.define_array(v_cursor1,2,v_site_use_id,v_BatchSize,1);
  dbms_sql.define_array(v_cursor1,3,v_currency_code,v_BatchSize,1);
  dbms_sql.define_array(v_cursor1,4,v_trx_date,v_BatchSize,1);
  dbms_sql.define_array(v_cursor1,5,v_amount,v_BatchSize,1);
  dbms_sql.define_array(v_cursor1,6,v_cust_trx_id,v_BatchSize,1);

   v_return_code := dbms_sql.execute(v_cursor1);

  --This is the fetch loop. Each call to FETCH_ROWS will retrive v_BatchSize
  --rows of data. The loop is over when FETCH_ROWS returns a value< v_BatchSize.

  LOOP

    v_customer_id.delete;
    v_site_use_id.delete;
    v_currency_code.delete;
    v_trx_date.delete;
    v_cust_trx_id.delete;
    v_amount.delete;

    v_NumRows := DBMS_SQL.FETCH_ROWS(v_cursor1);
    DBMS_SQL.COLUMN_VALUE(v_cursor1,1,v_customer_id);
    DBMS_SQL.COLUMN_VALUE(v_cursor1,2,v_site_use_id);
    DBMS_SQL.COLUMN_VALUE(v_cursor1,3,v_currency_code);
    DBMS_SQL.COLUMN_VALUE(v_cursor1,4,v_trx_date);
    DBMS_SQL.COLUMN_VALUE(v_cursor1,5,v_amount);
    DBMS_SQL.COLUMN_VALUE(v_cursor1,6,v_cust_trx_id);

   --The special case of v_NumRows = 0 needs to be checked here. This
   --means that the previous fetch returned all the remaining rows and
   --therefore we are done with the loop.

    if (v_NumRows = 0)  then
     EXIT;
    end if;

  --Use BIND_ARRAYS to specify the input variables for the insert.
  --only elements 1..V_NumRows will be used.

    DBMS_SQL.BIND_ARRAY(v_cursor2,':amount',v_amount);
    DBMS_SQL.BIND_ARRAY(v_cursor2,':cust_trx_id',v_cust_trx_id);
    DBMS_SQL.BIND_ARRAY(v_cursor2,':customer_id',v_customer_id);
    DBMS_SQL.BIND_ARRAY(v_cursor2,':site_use_id',v_site_use_id);
    DBMS_SQL.BIND_ARRAY(v_cursor2,':currency_code',v_currency_code);
    DBMS_SQL.BIND_ARRAY(v_cursor2,':trx_date',v_trx_date);

    v_return_code := DBMS_SQL.EXECUTE(v_cursor2);

    EXIT WHEN v_NumRows < v_BatchSize;

  END LOOP;
    DBMS_SQL.CLOSE_CURSOR(v_cursor1);
    DBMS_SQL.CLOSE_CURSOR(v_cursor2);

  IF PG_DEBUG in ('Y','C')
  THEN
     arp_standard.debug('ar_trx_summary_pkg.load_largest_inv_info()-');
  END IF;
END load_largest_inv_info;

PROCEDURE load_high_watermark IS
v_cursor1       NUMBER;
v_cursor2       NUMBER;
v_BatchSize     INTEGER := 1000;
v_NumRows       INTEGER;
v_customer_id   DBMS_SQL.NUMBER_TABLE;
v_site_use_id   DBMS_SQL.NUMBER_TABLE;
v_currency_code DBMS_SQL.VARCHAR2_TABLE;
v_trx_date      DBMS_SQL.DATE_TABLE;
v_cum_balance   DBMS_SQL.NUMBER_TABLE;
v_return_code   INTEGER;
text_select     VARCHAR2(4000);
text_update     VARCHAR2(4000);

BEGIN
  IF PG_DEBUG in ('Y','C')
  THEN
     arp_standard.debug('ar_trx_summary_pkg.load_high_watermark()+');
  END IF;

  /* 7518998 - Changed first subquery to UNION ALL, forced
      ra rows to be CASH, and completely removed CM app subquery */
  text_select :=
'with cust_list as
   (select /*+ cardinality(g,1) */ customer_id from ar_cust_search_gt g)
select customer_id, customer_site_use_id, invoice_currency_code,
       as_of_date , cum_balance
from (
select customer_id, customer_site_use_id, invoice_currency_code,
       as_of_date , sum(net_amount) OVER (PARTITION BY customer_id,
        customer_site_use_id, invoice_currency_code
        ORDER BY customer_id, customer_site_use_id,
        invoice_currency_code ROWS UNBOUNDED PRECEDING) cum_balance
from (
select customer_id, customer_site_use_id, invoice_currency_code,
       as_of_date , sum(net_amount) net_amount
from
(select ps.customer_id, ps.customer_site_use_id, ps.invoice_currency_code,
        ps.trx_date as_of_date, sum(ps.amount_due_original) net_amount
 from  ar_payment_schedules_all ps
 where ps.class in ('||''''||'INV'||''''||','
                     ||''''||'CM'||''''||','
                     ||''''||'DM'||''''||','
                     ||''''||'DEP'||''''||','
                     ||''''||'BR'||''''||','
                     ||''''||'CB'||''''||')
 and ps.customer_id in (select customer_id from cust_list)
 group by ps.customer_id, ps.customer_site_use_id,
          ps.invoice_currency_code, ps.trx_date
 union all
 select ps.customer_id, ps.customer_site_use_id, ps.invoice_currency_code,
        ra.apply_date as_of_date,
        sum(-ra.amount_applied
            -nvl(ra.earned_discount_taken,0)
            -nvl(ra.unearned_discount_taken,0)) net_amount
 from ar_payment_schedules_all ps,
      ar_receivable_applications_all ra
 where ps.payment_schedule_id = ra.applied_payment_schedule_id
  and  ps.customer_id in (select customer_id from cust_list)
  and  ra.status = '||''''||'APP'||''''||'
  and  ra.application_type = '||''''||'CASH'||''''||'
  and  nvl(ra.confirmed_flag,'||''''||'Y'||''''||') = '||''''||'Y'||''''||'
  and  ps.class in ('||''''||'INV'||''''||','
                     ||''''||'CM'||''''||','
                     ||''''||'DM'||''''||','
                     ||''''||'DEP'||''''||','
                     ||''''||'BR'||''''||','
                     ||''''||'CB'||''''||')
 group by ps.customer_id, ps.customer_site_use_id,
          ps.invoice_currency_code, ra.apply_date
 union all
 select ps.customer_id, ps.customer_site_use_id, ps.invoice_currency_code,
        adj.apply_date as_of_date, sum(adj.amount)
 from  ar_payment_schedules_all ps,
       ar_adjustments_all adj
 where ps.payment_schedule_id = adj.payment_schedule_id
  and  ps.class in ('||''''||'INV'||''''||','
                     ||''''||'CM'||''''||','
                     ||''''||'DM'||''''||','
                     ||''''||'DEP'||''''||','
                     ||''''||'BR'||''''||','
                     ||''''||'CB'||''''||')
  and  adj.status = '||''''||'A'||''''||'
  and  ps.customer_id in (select customer_id from cust_list)
 group by ps.customer_id, ps.customer_site_use_id,
          ps.invoice_currency_code, adj.apply_date
)
group by customer_id, customer_site_use_id, invoice_currency_code,
       as_of_date
order by customer_id, customer_site_use_id,  invoice_currency_code,
       as_of_date )
       )
 where as_of_date > add_months(sysdate , -24)';

  IF PG_DEBUG in ('Y','C')
  THEN
     arp_standard.debug(text_select);
  END IF;

  text_update :=
             'Update /*+ INDEX(ats AR_TRX_SUMMARY_U1) */ ar_trx_summary ats
               set   OP_BAL_HIGH_WATERMARK      = :cum_balance,
                     OP_BAL_HIGH_WATERMARK_DATE = :as_of_date,
                     LAST_UPDATE_DATE  = sysdate,
                     LAST_UPDATED_BY   = FND_GLOBAL.user_id,
                     LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
                  where cust_account_id = :customer_id
                    and SITE_USE_ID = :site_use_id
                    and CURRENCY = :currency_code
                    and AS_OF_DATE = :as_of_date';

  v_cursor1 := dbms_sql.open_cursor;
  v_cursor2 := dbms_sql.open_cursor;

  dbms_sql.parse(v_cursor1,text_select,DBMS_SQL.V7);
  dbms_sql.parse(v_cursor2,text_update,DBMS_SQL.V7);

  dbms_sql.define_array(v_cursor1,1,v_customer_id,v_BatchSize,1);
  dbms_sql.define_array(v_cursor1,2,v_site_use_id,v_BatchSize,1);
  dbms_sql.define_array(v_cursor1,3,v_currency_code,v_BatchSize,1);
  dbms_sql.define_array(v_cursor1,4,v_trx_date,v_BatchSize,1);
  dbms_sql.define_array(v_cursor1,5,v_cum_balance,v_BatchSize,1);

   v_return_code := dbms_sql.execute(v_cursor1);

  --This is the fetch loop. Each call to FETCH_ROWS will retrive v_BatchSize
  --rows of data. The loop is over when FETCH_ROWS returns a value< v_BatchSize.

  LOOP

    v_customer_id.delete;
    v_site_use_id.delete;
    v_currency_code.delete;
    v_trx_date.delete;
    v_cum_balance.delete;

    v_NumRows := DBMS_SQL.FETCH_ROWS(v_cursor1);
    DBMS_SQL.COLUMN_VALUE(v_cursor1,1,v_customer_id);
    DBMS_SQL.COLUMN_VALUE(v_cursor1,2,v_site_use_id);
    DBMS_SQL.COLUMN_VALUE(v_cursor1,3,v_currency_code);
    DBMS_SQL.COLUMN_VALUE(v_cursor1,4,v_trx_date);
    DBMS_SQL.COLUMN_VALUE(v_cursor1,5,v_cum_balance);

   --The special case of v_NumRows = 0 needs to be checked here. This
   --means that the previous fetch returned all the remaining rows and
   --therefore we are done with the loop.

    if (v_NumRows = 0)  then
     EXIT;
    end if;

  --Use BIND_ARRAYS to specify the input variables for the insert.
  --only elements 1..V_NumRows will be used.

    DBMS_SQL.BIND_ARRAY(v_cursor2,':cum_balance',v_cum_balance);
    DBMS_SQL.BIND_ARRAY(v_cursor2,':as_of_date',v_trx_date);
    DBMS_SQL.BIND_ARRAY(v_cursor2,':customer_id',v_customer_id);
    DBMS_SQL.BIND_ARRAY(v_cursor2,':site_use_id',v_site_use_id);
    DBMS_SQL.BIND_ARRAY(v_cursor2,':currency_code',v_currency_code);
    DBMS_SQL.BIND_ARRAY(v_cursor2,':as_of_date',v_trx_date);

    v_return_code := DBMS_SQL.EXECUTE(v_cursor2);

    EXIT WHEN v_NumRows < v_BatchSize;

  END LOOP;

    DBMS_SQL.CLOSE_CURSOR(v_cursor1);
    DBMS_SQL.CLOSE_CURSOR(v_cursor2);

  IF PG_DEBUG in ('Y','C')
  THEN
     arp_standard.debug('ar_trx_summary_pkg.load_high_watermark()-');
  END IF;

END load_high_watermark;

PROCEDURE refresh_summary_data(
       errbuf      IN OUT NOCOPY VARCHAR2,
       retcode     IN OUT NOCOPY VARCHAR2,
       p_max_workers IN NUMBER,
       p_worker_number IN NUMBER,
       p_skip_secondary_processes IN VARCHAR2 DEFAULT NULL,
       p_fast_delete IN VARCHAR2 DEFAULT 'Y'
      ) IS

  l_worker_number   NUMBER;
  l_max_workers     NUMBER;
  l_po_value        VARCHAR2(10);
  l_return          BOOLEAN;
BEGIN
  IF PG_DEBUG in ('Y','C')
  THEN
     arp_standard.debug('ar_trx_summary_pkg.refresh_summary_data()+');
     arp_standard.debug('  p_skip_secondary_processes = ' || p_skip_secondary_processes);
  END IF;

  /* Check profile, if set to N, then terminate program */
  l_po_value := fnd_profile.value('AR_CMGT_ALLOW_SUMMARY_TABLE_REFRESH');

  IF nvl(l_po_value,'N') = 'N'
  THEN
     fnd_file.put_line(fnd_file.log,
         'The profile AR_CMGT_ALLOW_SUMMARY_TABLE_REFRESH = N');
     IF PG_DEBUG in ('Y','C')
     THEN
        arp_standard.debug('  AR_CMGT_ALLOW_SUMMARY_TABLE_REFRESH = N');
        arp_standard.debug('ar_trx_summary_pkg.refresh_summary_data()-');
     END IF;

     retcode := SUCCESS;
     RETURN;
  END IF;

  /* Initialize worker settings */
  IF p_max_workers IS NULL
  THEN
     l_max_workers := 1;
  ELSE
     l_max_workers := p_max_workers;
  END IF;

  IF p_worker_number IS NULL
  THEN
     l_worker_number := 0;  -- zero is the master
  ELSIF p_worker_number > p_max_workers - 1
  THEN
     return;
  ELSE
     l_worker_number := p_worker_number;
  END IF;

  IF PG_DEBUG in ('Y','C')
  THEN
     arp_standard.debug('  l_max_workers   = ' || l_max_workers);
     arp_standard.debug('  l_worker_number = ' || l_worker_number);
  END IF;

  /* so now we should have l_max_workers as some integer
     and l_worker_number is zero for master and 1 through l_max_workers -1
     (0 through 3)

     The only differences between zero and the other workers is that zero will
     truncate the tables, submit the others, and submit held events.
  */

  /* Clear the tables and submit the others */
  IF l_worker_number = 0
  THEN
     /* Dump the summary tables */
     IF p_fast_delete = 'Y'
     THEN
        clear_summary_tables('A');  -- clear both tables
     END IF;

     /* Now submit the other workers */
     IF l_max_workers > 1
     THEN
       submit_child_workers(l_max_workers,p_skip_secondary_processes,
                            p_fast_delete);
     END IF;
  END IF;

  /* From this point on, all logic is processed by all workers
     and there is no special treatment for worker zero
  */

  /* block all events until this worker completes */
  block_events('BLOCK',FND_GLOBAL.conc_request_id);

  /* Collect customers for processing (ALL) */
  collect_customers(l_max_workers, l_worker_number,
                    'ALL', t_cust_id);

  /* Handle local delete when p_fast_delete = 'N'
     Note that this does not commit changes until the worker
     completes */
  IF NVL(p_fast_delete,'N') <> 'Y'
  THEN
     clear_summary_by_customer(t_cust_id);
  END IF;

  load_trx_bal_summary(t_cust_id);

  /* Check if OCM is installed/setup first before
     executing trx_summary functions */
  IF ar_cmgt_credit_request_api.is_credit_management_installed
  THEN
     /* Collect customers for processing (ACTIVE) */
     collect_customers(l_max_workers, l_worker_number,
                    'ACTIVE', t_cust_id);

     load_trx_summary(t_cust_id);

     /* Following two procedures use ar_cust_search_gt content */
     /* p_skip_secondary_processes gives us an easy way to determine
        which of these processes is consuming the most time.  This would
        be a simple way to bypass these if the customer was absolutely not
        using them */
     IF NVL(p_skip_secondary_processes,'NONE') NOT IN ('ALL','LOAD_LARGEST')
     THEN
        load_largest_inv_info;
     END IF;

     IF NVL(p_skip_secondary_processes,'NONE') NOT IN ('ALL','HIGH_WATERMARK')
     THEN
        load_high_watermark;
     END IF;
  END IF;

  /* unblock events for this worker */
  block_events('UNBLOCK',FND_GLOBAL.conc_request_id);

  /* Need to process held events here.. not sure how yet */
  IF l_worker_number = 0
  THEN
     submit_held_events;
  END IF;

  /* Set profile back to N */
  l_return := fnd_profile.save('AR_CMGT_ALLOW_SUMMARY_TABLE_REFRESH',
                                  'N','APPL',222);


  /* Final commit of new data */
  COMMIT;

  IF PG_DEBUG in ('Y','C')
  THEN
     arp_standard.debug('ar_trx_summary_pkg.refresh_summary_data()-');
  END IF;

  retcode := SUCCESS;
  RETURN;

END refresh_summary_data;

PROCEDURE process_held_events(
       errbuf      IN OUT NOCOPY VARCHAR2,
       retcode     IN OUT NOCOPY VARCHAR2) IS

   CURSOR get_raised_events IS
       SELECT *
       FROM   ar_sum_ref_event_hist;

   l_list         WF_PARAMETER_LIST_T;
   l_status       VARCHAR2(1);  -- junk variable
   l_industry     VARCHAR2(1);  -- junk variable
   l_schema       VARCHAR2(30);
   l_count        NUMBER := 0;
BEGIN
  fnd_file.put_line(fnd_file.log,'arp_trx_summary_pkg.process_held_events()+');

  IF PG_DEBUG in ('Y','C')
  THEN
     arp_standard.debug('ar_trx_summary_pkg.process_held_events()+');
  END IF;

    /* Process the business events that have been raised running the run of this
       concurrent program so far */

  FOR l_be_hist_rec in get_raised_events LOOP

    -- initialization of object variables
    l_list := WF_PARAMETER_LIST_T();

     -- add more parameters to the parameters list
     IF l_be_hist_rec.customer_trx_id IS NOT NULL
     THEN
        wf_event.AddParameterToList(p_name => 'CUSTOMER_TRX_ID',
                           p_value => l_be_hist_rec.customer_trx_id,
                           p_parameterlist => l_list);
     END IF;

     IF l_be_hist_rec.payment_schedule_id IS NOT NULL
     THEN
        wf_event.AddParameterToList(p_name => 'PAYMENT_SCHEDULE_ID',
                           p_value => l_be_hist_rec.customer_trx_id,
                           p_parameterlist => l_list);
     END IF;

     IF  l_be_hist_rec.CASH_RECEIPT_ID IS NOT NULL
     THEN
        wf_event.AddParameterToList(p_name => 'CASH_RECEIPT_ID',
                           p_value => l_be_hist_rec.CASH_RECEIPT_ID,
                           p_parameterlist => l_list);
     END IF;

     IF  l_be_hist_rec.RECEIVABLE_APPLICATION_ID IS NOT NULL
     THEN
        wf_event.AddParameterToList(p_name => 'RECEIVABLE_APPLICATION_ID',
                           p_value => l_be_hist_rec.RECEIVABLE_APPLICATION_ID,
                           p_parameterlist => l_list);
     END IF;

     IF  l_be_hist_rec.ADJUSTMENT_ID IS NOT NULL
     THEN
        wf_event.AddParameterToList(p_name => 'ADJUSTMENT_ID',
                           p_value => l_be_hist_rec.ADJUSTMENT_ID,
                           p_parameterlist => l_list);
     END IF;

     IF  l_be_hist_rec.HISTORY_ID IS NOT NULL
     THEN

        IF l_be_hist_rec.ADJUSTMENT_ID IS NOT NULL
        THEN

             wf_event.AddParameterToList(p_name => 'APPROVAL_ACTN_HIST_ID',
                           p_value => l_be_hist_rec.HISTORY_ID,
                           p_parameterlist => l_list);
        ELSE
             wf_event.AddParameterToList(p_name => 'HISTORY_ID',
                           p_value => l_be_hist_rec.HISTORY_ID,
                           p_parameterlist => l_list);
        END IF;
     END IF;

     IF  l_be_hist_rec.REQUEST_ID IS NOT NULL
     THEN
         wf_event.AddParameterToList(p_name => 'REQUEST_ID',
                           p_value => l_be_hist_rec.REQUEST_ID,
                           p_parameterlist => l_list);
     END IF;

     -- Raise Event
     AR_CMGT_EVENT_PKG.raise_event(
            p_event_name        => l_be_hist_rec.business_event_name,
            p_event_key         => l_be_hist_rec.event_key,
            p_parameters        => l_list );

     l_list.DELETE;
     l_count := l_count + 1;
  END LOOP;

  fnd_file.put_line(fnd_file.log,' events processed = ' || l_count);

  /* Clean out the AR_SUM_REF_EVENT_HIST table */
  IF FND_INSTALLATION.get_app_info('AR', l_status, l_industry, l_schema)
  THEN
     IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Retrieved schema for AR   : ' || l_schema);
     END IF;
  ELSE
     IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Problem retrieving AR schema name from fnd_installation');
     END IF;
     arp_standard.debug('EXCEPTION: arp_trx_summary_pkg.process_held_events');
     RETURN;
  END IF;

  /* If schema is set, clear event table */
  IF l_schema IS NOT NULL
  THEN
    /* clear the event holding table as well */
    EXECUTE IMMEDIATE 'truncate table ' || l_schema || '.AR_SUM_REF_EVENT_HIST';
  END IF;

  /* Delete any remaining rows (for refresh) from conc table
     This is really just precautionary in that (in theory), no events
     should be held at this point. */
  DELETE FROM AR_CONC_PROCESS_REQUESTS
   WHERE CONCURRENT_PROGRAM_NAME = 'ARSUMREF';

  COMMIT;

  fnd_file.put_line(fnd_file.log,'arp_trx_summary_pkg.process_held_events()-');

  IF PG_DEBUG in ('Y','C')
  THEN
     arp_standard.debug('ar_trx_summary_pkg.process_held_events()-');
  END IF;
END process_held_events;

END AR_TRX_SUMMARY_PKG;

/
