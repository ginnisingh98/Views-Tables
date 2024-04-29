--------------------------------------------------------
--  DDL for Package Body JA_JAINDTBR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_JAINDTBR_XMLP_PKG" AS
/* $Header: JAINDTBRB.pls 120.1 2007/12/25 16:17:09 dwkrishn noship $ */
  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
    Y VARCHAR2(15);
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;

 /* FUNCTION OPEN_BAL_TRFORMULA(CUSTOMER_ID IN NUMBER
                             ,CURR_CODE IN VARCHAR2) RETURN NUMBER IS
    LV_INV_CLASS CONSTANT AR_PAYMENT_SCHEDULES_ALL.CLASS%TYPE DEFAULT 'INV';
    LV_DM_CLASS CONSTANT AR_PAYMENT_SCHEDULES_ALL.CLASS%TYPE DEFAULT 'DM';
    LV_CM_CLASS CONSTANT AR_PAYMENT_SCHEDULES_ALL.CLASS%TYPE DEFAULT 'CM';
    LV_DEP_CLASS CONSTANT AR_PAYMENT_SCHEDULES_ALL.CLASS%TYPE DEFAULT 'DEP';
    LV_REC_ACCOUNT_CLASS CONSTANT RA_CUST_TRX_LINE_GL_DIST_ALL.ACCOUNT_CLASS%TYPE DEFAULT 'REC';
    LV_REV_STATUS CONSTANT AR_CASH_RECEIPT_HISTORY_ALL.STATUS%TYPE DEFAULT 'REVERSED';
    LV_ACT_STATUS CONSTANT AR_CASH_RECEIPT_HISTORY_ALL.STATUS%TYPE DEFAULT 'ACTIVITY';
    LV_LOSS_SOURCE_TYPE CONSTANT AR_DISTRIBUTIONS_ALL.SOURCE_TYPE%TYPE DEFAULT 'EXCH_LOSS';
    LV_GAIN_SOURCE_TYPE CONSTANT AR_DISTRIBUTIONS_ALL.SOURCE_TYPE%TYPE DEFAULT 'EXCH_GAIN';
    CURSOR GET_DEBIT_AMOUNT IS
      SELECT
        SUM((B.AMOUNT)) SUM_EXT_AMOUNT,
        SUM((B.AMOUNT) * NVL(A.EXCHANGE_RATE
               ,1))
      FROM
        RA_CUSTOMER_TRX_ALL A,
        AR_PAYMENT_SCHEDULES_ALL C,
        RA_CUST_TRX_LINE_GL_DIST_ALL B
      WHERE A.BILL_TO_CUSTOMER_ID = CUSTOMER_ID
        AND A.CUSTOMER_TRX_ID = C.CUSTOMER_TRX_ID
        AND C.CLASS In ( LV_INV_CLASS , LV_DM_CLASS , LV_DEP_CLASS )
        AND C.GL_DATE <= TRUNC(P_START_DATE)
        AND A.INVOICE_CURRENCY_CODE = CURR_CODE
        AND A.COMPLETE_FLAG = 'Y'
        AND B.CUSTOMER_TRX_ID = A.CUSTOMER_TRX_ID
        AND A.ORG_ID = NVL(P_ORGANIZATION_ID
         ,A.ORG_ID)
        AND B.ACCOUNT_CLASS = LV_REC_ACCOUNT_CLASS
        AND B.LATEST_REC_FLAG = 'Y'
        AND C.PAYMENT_SCHEDULE_ID IN (
        SELECT
          MIN(PAYMENT_SCHEDULE_ID)
        FROM
          AR_PAYMENT_SCHEDULES_ALL
        WHERE CUSTOMER_TRX_ID = C.CUSTOMER_TRX_ID );
    CURSOR GET_CREDIT_AMOUNT IS
      SELECT
        SUM(A.AMOUNT) SUM_AMOUNT,
        SUM(A.AMOUNT * NVL(A.EXCHANGE_RATE
               ,1.00)) SUM_AMOUNT_EXCHANGE
      FROM
        AR_CASH_RECEIPTS_ALL A
      WHERE A.PAY_FROM_CUSTOMER = CUSTOMER_ID
        AND A.ORG_ID = NVL(P_ORGANIZATION_ID
         ,A.ORG_ID)
        AND A.CURRENCY_CODE = CURR_CODE
        AND EXISTS (
        SELECT
          1
        FROM
          AR_CASH_RECEIPT_HISTORY_ALL
        WHERE CASH_RECEIPT_ID = A.CASH_RECEIPT_ID
          AND ORG_ID = NVL(P_ORGANIZATION_ID
           ,A.ORG_ID)
          AND GL_DATE <= TRUNC(P_START_DATE) );
    CURSOR GET_REVERSAL_AMOUNT IS
      SELECT
        SUM(A.AMOUNT) SUM_AMOUNT,
        SUM(A.AMOUNT * NVL(A.EXCHANGE_RATE
               ,1.00)) SUM_AMOUNT_EXCHANGE
      FROM
        AR_CASH_RECEIPTS_ALL A,
        AR_CASH_RECEIPT_HISTORY_ALL B
      WHERE A.PAY_FROM_CUSTOMER = CUSTOMER_ID
        AND A.CASH_RECEIPT_ID = B.CASH_RECEIPT_ID
        AND B.GL_DATE <= TRUNC(P_START_DATE)
        AND B.STATUS = LV_REV_STATUS
        AND A.REVERSAL_DATE is not null
        AND A.ORG_ID = NVL(P_ORGANIZATION_ID
         ,A.ORG_ID)
        AND A.CURRENCY_CODE = CURR_CODE;
    CURSOR GET_DISCOUNT_CUR(CP_APP_TYPE IN AR_RECEIVABLE_APPLICATIONS_ALL.APPLICATION_TYPE%TYPE) IS
      SELECT
        NVL(SUM(ABS(NVL(D.EARNED_DISCOUNT_TAKEN
                       ,0)))
           ,0) SUM_AMOUNT,
        NVL(SUM(ABS(NVL(D.ACCTD_EARNED_DISCOUNT_TAKEN
                       ,0)))
           ,0) SUM_AMOUNT_EXCHANGE
      FROM
        RA_CUSTOMER_TRX_ALL B,
        AR_RECEIVABLE_APPLICATIONS_ALL D
      WHERE B.BILL_TO_CUSTOMER_ID = CUSTOMER_ID
        AND B.COMPLETE_FLAG = 'Y'
        AND TRUNC(D.GL_DATE) <= TRUNC(P_START_DATE)
        AND D.APPLIED_CUSTOMER_TRX_ID = B.CUSTOMER_TRX_ID
        AND B.INVOICE_CURRENCY_CODE = CURR_CODE
        AND D.EARNED_DISCOUNT_TAKEN is not null
        AND D.EARNED_DISCOUNT_TAKEN <> 0
        AND B.ORG_ID = NVL(P_ORGANIZATION_ID
         ,B.ORG_ID)
        AND D.APPLICATION_TYPE = CP_APP_TYPE
        AND D.DISPLAY = 'Y';
    CURSOR GET_ADJUSTMENT_AMOUNT IS
      SELECT
        SUM(A.AMOUNT),
        SUM(A.AMOUNT * NVL(B.EXCHANGE_RATE
               ,1.00)) SUM_AMOUNT_EXCHANGE
      FROM
        AR_ADJUSTMENTS_ALL A,
        AR_CASH_RECEIPTS_ALL B
      WHERE A.ASSOCIATED_CASH_RECEIPT_ID = B.CASH_RECEIPT_ID
        AND B.PAY_FROM_CUSTOMER = CUSTOMER_ID
        AND A.GL_DATE <= TRUNC(P_START_DATE)
        AND B.ORG_ID = NVL(P_ORGANIZATION_ID
         ,B.ORG_ID)
        AND B.CURRENCY_CODE = CURR_CODE;
    CURSOR C_GET_NONFC_ADJ_AMOUNT IS
      SELECT
        SUM(B.AMOUNT),
        SUM(B.AMOUNT * NVL(C.EXCHANGE_RATE
               ,1.00)) SUM_AMOUNT_EXCHANGE
      FROM
        AR_ADJUSTMENTS_ALL B,
        RA_CUSTOMER_TRX_ALL C,
        AR_PAYMENT_SCHEDULES_ALL D,
        GL_CODE_COMBINATIONS E
      WHERE B.CUSTOMER_TRX_ID = C.CUSTOMER_TRX_ID
        AND C.BILL_TO_CUSTOMER_ID = CUSTOMER_ID
        AND B.GL_DATE <= TRUNC(P_START_DATE)
        AND E.CODE_COMBINATION_ID = B.CODE_COMBINATION_ID
        AND B.PAYMENT_SCHEDULE_ID = D.PAYMENT_SCHEDULE_ID
        AND B.CUSTOMER_TRX_ID = D.CUSTOMER_TRX_ID
        AND B.STATUS = 'A'
        AND C.ORG_ID = NVL(P_ORGANIZATION_ID
         ,B.ORG_ID)
        AND C.INVOICE_CURRENCY_CODE = CURR_CODE;
    CURSOR GET_EXCHANGE_GAINLOSS_CR IS
      SELECT
        SUM(E.AMOUNT_CR) SUM_AMOUNT,
        SUM(E.ACCTD_AMOUNT_CR) SUM_EXCHANGE_AMOUNT
      FROM
        RA_CUSTOMER_TRX_ALL B,
        AR_CASH_RECEIPTS_ALL C,
        AR_RECEIVABLE_APPLICATIONS_ALL D,
        AR_DISTRIBUTIONS_ALL E
      WHERE B.CUSTOMER_TRX_ID = D.APPLIED_CUSTOMER_TRX_ID
        AND C.CASH_RECEIPT_ID = D.CASH_RECEIPT_ID
        AND E.SOURCE_ID = D.RECEIVABLE_APPLICATION_ID
        AND B.ORG_ID = NVL(P_ORGANIZATION_ID
         ,B.ORG_ID)
        AND E.SOURCE_TYPE IN ( LV_LOSS_SOURCE_TYPE , LV_GAIN_SOURCE_TYPE )
        AND B.INVOICE_CURRENCY_CODE = CURR_CODE
        AND B.BILL_TO_CUSTOMER_ID = CUSTOMER_ID
        AND TRUNC(D.GL_DATE) <= TRUNC(P_START_DATE);
    CURSOR GET_EXCHANGE_GAINLOSS_DR IS
      SELECT
        SUM(E.AMOUNT_DR) SUM_AMOUNT,
        SUM(E.ACCTD_AMOUNT_DR) SUM_EXCHANGE_AMOUNT
      FROM
        RA_CUSTOMER_TRX_ALL B,
        AR_CASH_RECEIPTS_ALL C,
        AR_RECEIVABLE_APPLICATIONS_ALL D,
        AR_DISTRIBUTIONS_ALL E
      WHERE B.CUSTOMER_TRX_ID = D.APPLIED_CUSTOMER_TRX_ID
        AND C.CASH_RECEIPT_ID = D.CASH_RECEIPT_ID
        AND E.SOURCE_ID = D.RECEIVABLE_APPLICATION_ID
        AND B.ORG_ID = NVL(P_ORGANIZATION_ID
         ,B.ORG_ID)
        AND B.INVOICE_CURRENCY_CODE = CURR_CODE
        AND B.BILL_TO_CUSTOMER_ID = CUSTOMER_ID
        AND TRUNC(D.GL_DATE) <= TRUNC(P_START_DATE)
        AND E.SOURCE_TYPE IN ( LV_LOSS_SOURCE_TYPE , LV_GAIN_SOURCE_TYPE );
    V_TR_DR_AMT NUMBER;
    V_FUNC_DR_AMT NUMBER;
    V_TR_CR_AMT NUMBER;
    V_FUNC_CR_AMT NUMBER;
    V_TR_REV_AMT NUMBER;
    V_FUNC_REV_AMT NUMBER;
    V_TRAN_TOT_AMT NUMBER;
    V_FUNC_TOT_AMT NUMBER;
    V_CRE_MEMO_AMT NUMBER;
    V_CRE_MEMO_FUNC_AMT NUMBER;
    V_TR_ADJ_AMT NUMBER;
    V_FUNC_ADJ_AMT NUMBER;
    V_EXCH_GAIN_AMT NUMBER;
    V_EXCH_LOSS_AMT NUMBER;
    V_TR_NONFC_ADJ_AMOUNT NUMBER;
    V_FUNC_NONFC_ADJ_AMOUNT NUMBER;
    V_TR_DISC_CR_AMT NUMBER;
    V_FUNC_DISC_CR_AMT NUMBER;
    V_TRAN_RCP_W_OFF NUMBER;
    V_FUNC_RCP_W_OFF NUMBER;
    V_EXCH_LOSS_FUNC_AMT NUMBER;
    V_EXCH_GAIN_FUNC_AMT NUMBER;
    CURSOR C_RECEIPT_W_OFF IS
      SELECT
        SUM(C.AMOUNT_APPLIED) SUM_AMOUNT,
        SUM(C.AMOUNT_APPLIED * NVL(A.EXCHANGE_RATE
               ,1.00)) SUM_AMOUNT_EXCHANGE
      FROM
        AR_CASH_RECEIPTS_ALL A,
        AR_CASH_RECEIPT_HISTORY_ALL B,
        AR_RECEIVABLE_APPLICATIONS_ALL C
      WHERE A.PAY_FROM_CUSTOMER = CUSTOMER_ID
        AND TRUNC(B.GL_DATE) <= TRUNC(P_START_DATE)
        AND A.CASH_RECEIPT_ID = B.CASH_RECEIPT_ID
        AND A.CASH_RECEIPT_ID = C.CASH_RECEIPT_ID
        AND C.CASH_RECEIPT_HISTORY_ID = B.CASH_RECEIPT_HISTORY_ID
        AND C.APPLIED_PAYMENT_SCHEDULE_ID = - 3
        AND C.STATUS = LV_ACT_STATUS
        AND A.CURRENCY_CODE = CURR_CODE
        AND B.REVERSAL_GL_DATE IS NULL
        AND B.CURRENT_RECORD_FLAG = 'Y'
        AND A.ORG_ID = NVL(P_ORGANIZATION_ID
         ,A.ORG_ID)
        AND not exists (
        SELECT
          1
        FROM
          AR_CASH_RECEIPT_HISTORY_ALL
        WHERE CASH_RECEIPT_ID = B.CASH_RECEIPT_ID
          AND STATUS = LV_REV_STATUS );
  BEGIN
    SELECT
      SUM((B.AMOUNT)) SUM_EXT_AMOUNT,
      SUM((B.AMOUNT) * NVL(A.EXCHANGE_RATE
             ,1))
    INTO V_CRE_MEMO_AMT,V_CRE_MEMO_FUNC_AMT
    FROM
      RA_CUSTOMER_TRX_ALL A,
      AR_PAYMENT_SCHEDULES_ALL C,
      RA_CUST_TRX_LINE_GL_DIST_ALL B
    WHERE A.BILL_TO_CUSTOMER_ID = CUSTOMER_ID
      AND A.CUSTOMER_TRX_ID = C.CUSTOMER_TRX_ID
      AND C.CLASS In ( LV_CM_CLASS )
      AND C.GL_DATE <= TRUNC(P_START_DATE)
      AND A.INVOICE_CURRENCY_CODE = CURR_CODE
      AND A.COMPLETE_FLAG = 'Y'
      AND B.CUSTOMER_TRX_ID = A.CUSTOMER_TRX_ID
      AND A.ORG_ID = NVL(P_ORGANIZATION_ID
       ,A.ORG_ID)
      AND B.ACCOUNT_CLASS = LV_REC_ACCOUNT_CLASS
      AND C.PAYMENT_SCHEDULE_ID in (
      SELECT
        MIN(PAYMENT_SCHEDULE_ID)
      FROM
        AR_PAYMENT_SCHEDULES_ALL
      WHERE CUSTOMER_TRX_ID = C.CUSTOMER_TRX_ID );
    OPEN GET_DEBIT_AMOUNT;
    FETCH GET_DEBIT_AMOUNT
     INTO V_TR_DR_AMT,V_FUNC_DR_AMT;
    CLOSE GET_DEBIT_AMOUNT;
    OPEN GET_CREDIT_AMOUNT;
    FETCH GET_CREDIT_AMOUNT
     INTO V_TR_CR_AMT,V_FUNC_CR_AMT;
    CLOSE GET_CREDIT_AMOUNT;
    OPEN GET_REVERSAL_AMOUNT;
    FETCH GET_REVERSAL_AMOUNT
     INTO V_TR_REV_AMT,V_FUNC_REV_AMT;
    CLOSE GET_REVERSAL_AMOUNT;
    OPEN GET_ADJUSTMENT_AMOUNT;
    FETCH GET_ADJUSTMENT_AMOUNT
     INTO V_TR_ADJ_AMT,V_FUNC_ADJ_AMT;
    CLOSE GET_ADJUSTMENT_AMOUNT;
    OPEN C_GET_NONFC_ADJ_AMOUNT;
    FETCH C_GET_NONFC_ADJ_AMOUNT
     INTO V_TR_NONFC_ADJ_AMOUNT,V_FUNC_NONFC_ADJ_AMOUNT;
    CLOSE C_GET_NONFC_ADJ_AMOUNT;
    OPEN GET_EXCHANGE_GAINLOSS_CR;
    FETCH GET_EXCHANGE_GAINLOSS_CR
     INTO V_EXCH_GAIN_AMT,V_EXCH_GAIN_FUNC_AMT;
    CLOSE GET_EXCHANGE_GAINLOSS_CR;
    OPEN GET_EXCHANGE_GAINLOSS_DR;
    FETCH GET_EXCHANGE_GAINLOSS_DR
     INTO V_EXCH_LOSS_AMT,V_EXCH_LOSS_FUNC_AMT;
    CLOSE GET_EXCHANGE_GAINLOSS_DR;
    OPEN GET_DISCOUNT_CUR('CASH');
    FETCH GET_DISCOUNT_CUR
     INTO V_TR_DISC_CR_AMT,V_FUNC_DISC_CR_AMT;
    CLOSE GET_DISCOUNT_CUR;
    OPEN C_RECEIPT_W_OFF;
    FETCH C_RECEIPT_W_OFF
     INTO V_TRAN_RCP_W_OFF,V_FUNC_RCP_W_OFF;
    CLOSE C_RECEIPT_W_OFF;
    FUNC_OPEN_BAL := (NVL(V_FUNC_DR_AMT
                        ,0) + NVL(V_FUNC_REV_AMT
                        ,0)) + NVL(V_CRE_MEMO_FUNC_AMT
                        ,0) - NVL(V_FUNC_CR_AMT
                        ,0) - NVL(V_FUNC_DISC_CR_AMT
                        ,0) + NVL(V_FUNC_RCP_W_OFF
                        ,0) + NVL(V_EXCH_GAIN_FUNC_AMT
                        ,0) - NVL(V_EXCH_LOSS_FUNC_AMT
                        ,0) - ABS(NVL(V_FUNC_NONFC_ADJ_AMOUNT
                            ,0));
    V_TRAN_TOT_AMT := (NVL(V_TR_DR_AMT
                         ,0) + NVL(V_TR_REV_AMT
                         ,0)) + NVL(V_CRE_MEMO_AMT
                         ,0) - NVL(V_TR_DISC_CR_AMT
                         ,0) - (NVL(V_TR_CR_AMT
                         ,0)) + NVL(V_TRAN_RCP_W_OFF
                         ,0) - ABS(NVL(V_TR_NONFC_ADJ_AMOUNT
                             ,0));
    RETURN (NVL(V_TRAN_TOT_AMT
              ,0));
  END OPEN_BAL_TRFORMULA;
*/
function open_bal_trFormula (P_CUSTOMER_ID IN NUMBER
                             ,P_CURR_CODE IN VARCHAR2) RETURN NUMBER IS

lv_inv_class constant ar_payment_schedules_all.class%type:= 'INV';  --rchandan for bug#4428980
lv_dm_class constant ar_payment_schedules_all.class%type:= 'DM';    --rchandan for bug#4428980
lv_cm_class constant ar_payment_schedules_all.class%type:= 'CM';    --rchandan for bug#4428980
lv_dep_class constant ar_payment_schedules_all.class%type:= 'DEP';  --rchandan for bug#4428980
lv_rec_account_class CONSTANT ra_cust_trx_line_gl_dist_all.account_class%TYPE := 'REC'; --rchandan for bug#4428980
lv_rev_status CONSTANT ar_cash_receipt_history_all.status%TYPE := 'REVERSED'; --rchandan for bug#4428980
lv_act_status CONSTANT ar_cash_receipt_history_all.status%TYPE := 'ACTIVITY'; --rchandan for bug#4428980
lv_loss_source_Type CONSTANT ar_distributions_all.source_Type%TYPE := 'EXCH_LOSS'; --rchandan for bug#4428980
lv_gain_source_Type CONSTANT ar_distributions_all.source_Type%TYPE := 'EXCH_GAIN' ; --rchandan for bug#4428980

Cursor Get_debit_amount IS
Select
        sum((b.amount)) sum_ext_amount,
        sum((b.amount) * NVL(a.exchange_rate,1))
From
        ra_customer_trx_all              A,
        ar_payment_schedules_all         C,
        ra_cust_trx_line_gl_dist_all     B
Where
        a.bill_to_customer_id   =  P_CUSTOMER_ID
AND     a.customer_trx_id       = c.customer_trx_id
AND     c.class In(lv_inv_class,lv_dm_class,lv_dep_class)--rchandan for bug#4428980
--AND     trunc(a.trx_date)      <= trunc( p_start_date)
AND     c.gl_date <= trunc( p_start_date)
AND     a.invoice_currency_code =  P_CURR_CODE
AND     a.complete_flag         = 'Y'
AND     b.customer_trx_id       = a.customer_trx_id
AND     a.org_id                = NVL( P_ORGANIZATION_ID, a.org_id)
AND     b.account_class         = lv_rec_account_class--rchandan for bug#4428980
and     b.latest_rec_flag       = 'Y'
AND     c.Payment_schedule_id
IN      (SELECT MIN(PAYMENT_SCHEDULE_ID)
         FROM   AR_PAYMENT_SCHEDULES_ALL
         WHERE  CUSTOMER_TRX_ID = C.CUSTOMER_TRX_ID
        )
;

Cursor  Get_credit_amount IS
Select
        sum(a.amount) sum_amount,
        sum(a.amount * NVL(a.exchange_rate,1.00)) sum_amount_exchange
From
        ar_cash_receipts_all            A
Where
        a.pay_from_customer    =  P_CUSTOMER_ID
AND     a.org_id               = NVL( P_ORGANIZATION_ID, a.org_id)
AND     a.currency_code        =  P_CURR_CODE
--Added the below by Sanjikum for Bug #3962497
AND 		EXISTS (	SELECT	1
									FROM		ar_cash_receipt_history_all
									WHERE 	cash_receipt_id = a.cash_receipt_id
									AND 		org_id = NVL( P_ORGANIZATION_ID, a.org_id)
									AND 		gl_date <= trunc( p_start_date)
							 );

Cursor  get_reversal_amount IS
Select
        sum(a.amount) sum_amount,
        sum(a.amount * NVL(a.exchange_rate,1.00)) sum_amount_exchange
From
        ar_cash_receipts_all A ,
        ar_cash_receipt_history_all B
Where
        a.pay_from_customer =  P_CUSTOMER_ID
and     a.cash_receipt_id = b.cash_receipt_id
AND     b.gl_date          <= trunc( p_start_date)
--and     b.current_record_flag   = 'Y' --Commented by Sanjikum for Bug #3962497
AND 	 	b.status                      = lv_rev_status --Added by Sanjikum for Bug #3962497--rchandan for bug#4428980
and     a.reversal_date is not null
AND     a.org_id            = NVL( P_ORGANIZATION_ID, a.org_id) -- added by sriram
AND     a.currency_code     =  P_CURR_CODE;



CURSOR Get_Discount_Cur(cp_app_type ar_receivable_applications_all.application_type%type) is--rchandan for bug#4428980
Select
       nvl(sum(abs(NVL(d.earned_discount_taken,0))),0)  sum_amount,
       nvl(sum(abs(NVL(d.ACCTD_EARNED_DISCOUNT_TAKEN,0))),0)  sum_amount_exchange
From   ra_customer_trx_ALL             B,
       ar_receivable_applications_all  d
Where
       b.bill_to_customer_id   =  P_CUSTOMER_ID
AND    b.complete_flag         = 'Y'
AND    trunc(d.GL_DATE)       <= trunc( p_start_date)
AND    d.applied_customer_trx_id       = b.customer_trx_id
AND    b.invoice_currency_code =  P_CURR_CODE
AND    d.earned_discount_taken is not null
and    d.earned_discount_taken <> 0
AND    B.org_id                = nvl( P_ORGANIZATION_ID ,b.org_id)
and    d.application_type = cp_app_type --rchandan for bug#4428980
and    d.display = 'Y'
;

Cursor  get_adjustment_amount IS
SELECT  SUM(A.amount),
        SUM(A.amount * NVL(b.exchange_rate,1.00)) sum_amount_exchange
FROM    ar_adjustments_all           A,
        ar_cash_receipts_all         b
WHERE   A.associated_cash_receipt_id = b.cash_receipt_id
and     b.pay_from_customer          =  P_CUSTOMER_ID
--and     trunc(a.apply_date)         <=  trunc( p_start_date)
and     A.gl_date                   <=  trunc( p_start_date)
AND     b.org_id                     = NVL( P_ORGANIZATION_ID, b.org_id)
AND     b.currency_code              =  P_CURR_CODE;


cursor  c_get_nonfc_adj_amount is
select  sum(b.amount),
        sum(b.amount * NVL(c.exchange_rate,1.00)) sum_amount_exchange
FROM    ar_adjustments_all          b,
        ra_customer_trx_all         c,
        ar_payment_schedules_all    d,
        gl_code_combinations        e
WHERE
        b.customer_trx_id       = c.customer_trx_id
and     c.bill_to_customer_id   =  P_CUSTOMER_ID
and     b.gl_date              <= trunc( p_start_date)
and     e.code_combination_id   = b.code_combination_id
and     b.payment_schedule_id   = d.payment_schedule_id
and     b.customer_trx_id       = d.customer_trx_id
and     b.status                = 'A'
and     c.org_id                = NVL( P_ORGANIZATION_ID, b.org_id)
and     c.invoice_currency_code =  P_CURR_CODE;



--Cursor get_exchange_gain_amount is
Cursor get_exchange_gainloss_cr is
SELECT
        sum(e.amount_cr)             sum_amount     ,
        sum(e.acctd_amount_cr)       sum_exchange_amount
FROM    ra_customer_trx_all              b ,
        ar_cash_receipts_all             c,
        ar_receivable_applications_all   d,
        ar_distributions_all             e
WHERE   b.customer_trx_id            = d.APPLIED_CUSTOMER_TRX_ID
AND     c.cash_receipt_id            = d.cash_receipt_id
AND     e.SOURCE_ID                  = d.receivable_application_id
AND     b.org_id                     = nvl( p_organization_id,b.org_id)
AND     e.source_Type IN (lv_loss_source_Type, lv_gain_source_Type)--rchandan for bug#4428980
AND     b.invoice_currency_code      =  P_CURR_CODE
AND     b.BILL_TO_CUSTOMER_ID        =  P_CUSTOMER_ID
AND     TRUNC(d.gl_date)            <= trunc( p_start_date);

--Cursor get_exchange_loss_amount is
Cursor get_exchange_gainloss_dr is
SELECT
        sum(e.amount_dr)             sum_amount     ,
        sum(e.acctd_amount_dr)       sum_exchange_amount
FROM    ra_customer_trx_all              b ,
        ar_cash_receipts_all             c ,
        ar_receivable_applications_all   d ,
        ar_distributions_all             e
WHERE
        b.customer_trx_id            = d.APPLIED_CUSTOMER_TRX_ID
AND     c.cash_receipt_id            = d.cash_receipt_id
AND     e.SOURCE_ID                  = d.receivable_application_id
AND     b.org_id                     = NVL( p_organization_id,b.org_id)
AND     b.invoice_currency_code      =  P_CURR_CODE
AND     b.BILL_TO_CUSTOMER_ID        =  P_CUSTOMER_ID
AND     TRUNC(d.gl_date)            <= trunc( p_start_date)
AND     e.source_Type IN (lv_loss_source_Type, lv_gain_source_Type );--rchandan for bug#4428980

----------



v_tr_dr_amt               Number;
v_func_dr_amt             Number;
v_tr_cr_amt               Number;
v_func_cr_amt             Number;
v_tr_rev_amt              Number;
v_func_rev_amt            Number;
v_tran_tot_amt            Number;
v_func_tot_amt            Number;
v_cre_memo_amt            Number;
v_cre_memo_func_amt       Number;
v_tr_adj_amt              Number;
v_func_adj_amt            Number;
V_exch_gain_amt           Number;
V_exch_loss_amt           Number;
v_tr_nonfc_adj_amount     Number;
v_func_nonfc_adj_amount   Number;
v_tr_disc_cr_amt          Number;
v_func_disc_cr_amt        Number;
v_tran_rcp_w_off          Number;
v_func_rcp_w_off          Number;
v_exch_loss_func_amt      Number;
v_exch_gain_func_amt      Number;



Cursor  c_receipt_w_off IS
Select
        sum(c.amount_applied) sum_amount,
        sum(c.amount_applied * NVL(a.exchange_rate,1.00)) sum_amount_exchange
From
        ar_cash_receipts_all            A,
        ar_cash_receipt_history_all     B,
        ar_receivable_applications_all  c
Where
        a.pay_from_customer =  P_CUSTOMER_ID
AND     trunc(b.gl_date)   <= trunc( p_start_date)
AND     a.cash_receipt_id   = b.cash_receipt_id
and     a.cash_receipt_id   = c .cash_receipt_id
and     c.cash_receipt_history_id = b.cash_receipt_history_id
and     c.applied_payment_schedule_id = -3
and     c.status = lv_act_status--rchandan for bug#4428980
AND     a.currency_code =  P_CURR_CODE
AND     B.REVERSAL_GL_DATE IS NULL
AND     b.current_record_flag = 'Y'
AND     a.org_id=NVL( P_ORGANIZATION_ID, a.org_id)
and     not exists  -- writing this query coz when a receipt is reversed , its write off details should not be shown
 (select   1
  from     ar_cash_receipt_history_all
  where    cash_receipt_id = b.cash_receipt_id
  and    status = lv_rev_status--rchandan for bug#4428980
)
;


begin
  Select
         sum((b.amount)) sum_ext_amount,
         sum((b.amount) * NVL(a.exchange_rate,1))
  Into   v_cre_memo_amt,
         v_cre_memo_func_amt
From
        ra_customer_trx_all                A,
        ar_payment_schedules_all           C,
        ra_cust_trx_line_gl_dist_all       B
Where
        a.bill_to_customer_id =  P_CUSTOMER_ID
AND     a.customer_trx_id = c.customer_trx_id
AND     c.class In(lv_cm_class)--rchandan for bug#4428980
--AND     trunc(a.trx_date) <= trunc( p_start_date)
and     c.gl_date           <= trunc( p_start_date)
AND     a.invoice_currency_code =  P_CURR_CODE
AND     a.complete_flag = 'Y'
AND     b.customer_trx_id = a.customer_trx_id
AND     a.org_id = NVL( P_ORGANIZATION_ID, a.org_id) -- added by sriram
AND     b.account_class = lv_rec_account_class--rchandan for bug#4428980
AND     c.payment_schedule_id in
( select min(payment_schedule_id)
  from   ar_payment_schedules_all
 where   customer_trx_id = c.customer_trx_id
);

 OPEN get_debit_amount;
 FETCH get_debit_amount INTO v_tr_dr_amt, v_func_dr_amt;
 CLOSE get_debit_amount;

 OPEN get_credit_amount;
 FETCH get_credit_amount INTO v_tr_cr_amt, v_func_cr_amt;
 CLOSE get_credit_amount;

 OPEN get_reversal_amount;
 FETCH get_reversal_amount INTO v_tr_rev_amt, v_func_rev_amt;
 CLOSE get_reversal_amount;


 OPEN get_adjustment_amount;
 FETCH get_adjustment_amount INTO v_tr_adj_amt, v_func_adj_amt;
 CLOSE get_adjustment_amount;


 open  c_get_nonfc_adj_amount;
 fetch c_get_nonfc_adj_amount into v_tr_nonfc_adj_amount,v_func_nonfc_adj_amount;
 close c_get_nonfc_adj_amount;

 Open get_exchange_gainloss_cr;
 fetch get_exchange_gainloss_cr into v_exch_gain_amt , v_exch_gain_func_amt ;
 Close get_exchange_gainloss_cr;

 Open get_exchange_gainloss_dr;
 fetch get_exchange_gainloss_dr into v_exch_loss_amt, v_exch_loss_func_amt;
 Close get_exchange_gainloss_dr;

 OPEN Get_Discount_Cur('CASH') ;--rchandan for bug#4428980
 FETCH Get_Discount_Cur into v_tr_disc_cr_amt,   v_func_disc_cr_amt ;
 CLOSE Get_Discount_Cur ;

 open  c_receipt_w_off;
 fetch c_receipt_w_off into v_tran_rcp_w_off,v_func_rcp_w_off;
 close c_receipt_w_off;


  func_open_bal :=    (NVL(v_func_dr_amt,0)
                    +  NVL(v_func_rev_amt,0))
                    +  nvl(v_cre_memo_func_amt,0)
                    -  NVL(v_func_cr_amt,0)
                    -  nvl(v_func_disc_cr_amt,0)
                    +  nvl(v_func_rcp_w_off,0)
                    +  nvl(v_exch_gain_func_amt,0)
                    -  nvl(v_exch_loss_func_amt,0)
                    -  abs(nvl(v_func_nonfc_adj_amount,0)
                    );

    v_tran_tot_amt :=  ( NVL(v_tr_dr_amt,0)
                       + NVL(v_tr_rev_amt,0))
                       + nvl(v_cre_memo_amt,0)
                       -  nvl(v_tr_disc_cr_amt,0)
                       -(NVL(v_tr_cr_amt,0))
                       + nvl(v_tran_rcp_w_off,0)
                       - abs(nvl(v_tr_nonfc_adj_amount,0));


  Return(NVL(v_tran_tot_amt,0));

End;
  FUNCTION FUNC_OPEN_BALFORMULA RETURN NUMBER IS
  BEGIN
    RETURN NULL;
  END FUNC_OPEN_BALFORMULA;

  FUNCTION CF_1FORMULA0040 RETURN VARCHAR2 IS
    CURSOR GET_ORGANIZATION_NAME IS
      SELECT
        ORGANIZATION_NAME
      FROM
        ORG_ORGANIZATION_DEFINITIONS
      WHERE ORGANIZATION_ID = P_ORGANIZATION_ID;
    CURSOR GET_LOCATION_DETAILS IS
      SELECT
        LOCATION_ID,
        ADDRESS_LINE_1,
        ADDRESS_LINE_2,
        ADDRESS_LINE_3,
        COUNTRY
      FROM
        HR_ORGANIZATION_UNITS_V
      WHERE ORGANIZATION_ID = P_ORGANIZATION_ID;
    CURSOR GET_LOCATION_NAME(V_LOC_ID IN NUMBER) IS
      SELECT
        DESCRIPTION
      FROM
        HR_LOCATIONS
      WHERE LOCATION_ID = V_LOC_ID;
    V_ORG_NAME VARCHAR2(60);
    V_LOC_ID NUMBER;
  BEGIN
    OPEN GET_ORGANIZATION_NAME;
    FETCH GET_ORGANIZATION_NAME
     INTO V_ORG_NAME;
    CLOSE GET_ORGANIZATION_NAME;
    OPEN GET_LOCATION_DETAILS;
    FETCH GET_LOCATION_DETAILS
     INTO V_LOC_ID,ADD1,ADD2,ADD3,COUNTRY;
    CLOSE GET_LOCATION_DETAILS;
    OPEN GET_LOCATION_NAME(V_LOC_ID);
    FETCH GET_LOCATION_NAME
     INTO LOC_NAME;
    CLOSE GET_LOCATION_NAME;
    RETURN (V_ORG_NAME);
  END CF_1FORMULA0040;

  FUNCTION P_CUSTOMER_TYPEVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_CUSTOMER_TYPEVALIDTRIGGER;

  FUNCTION P_CUSTOMER_IDVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_CUSTOMER_IDVALIDTRIGGER;

  FUNCTION P_CUSTOMER_ID2VALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_CUSTOMER_ID2VALIDTRIGGER;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    /*SRW.MESSAGE(1001
               ,' - after Param form With P_Organization_id = ' || P_ORGANIZATION_ID)*/NULL;
    /*SRW.MESSAGE(1002
               ,' - after Param form With P_customer_id = ' || P_CUSTOMER_ID)*/NULL;
    /*SRW.MESSAGE(1003
               ,' - after Param form With P_customer_id2 = ' || P_CUSTOMER_ID2)*/NULL;
    /*SRW.MESSAGE(1004
               ,' - after Param form With P_customer_type = ' || P_CUSTOMER_TYPE)*/NULL;
    /*SRW.MESSAGE(1005
               ,' - after Param form With P_end_date = ' || P_END_DATE1)*/NULL;
    /*SRW.MESSAGE(1006
               ,' - after Param form With P_start_date = ' || P_START_DATE)*/NULL;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.MESSAGE(1275
               ,'Report Version is 120.2 Last modified date is 25/07/2005')*/NULL;
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    P_START_DATE1 := TO_CHAR(P_START_DATE,'DD-MM-YYYY');
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION FUNC_OPEN_BAL_P RETURN NUMBER IS
  BEGIN
    RETURN FUNC_OPEN_BAL;
  END FUNC_OPEN_BAL_P;

  FUNCTION ADD1_P RETURN VARCHAR2 IS
  BEGIN
    RETURN ADD1;
  END ADD1_P;

  FUNCTION ADD2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN ADD2;
  END ADD2_P;

  FUNCTION ADD3_P RETURN VARCHAR2 IS
  BEGIN
    RETURN ADD3;
  END ADD3_P;

  FUNCTION COUNTRY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN COUNTRY;
  END COUNTRY_P;

  FUNCTION LOC_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN LOC_NAME;
  END LOC_NAME_P;

END JA_JAINDTBR_XMLP_PKG;



/
