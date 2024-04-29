--------------------------------------------------------
--  DDL for Package Body JG_ZZ_SUMMARY_AP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_SUMMARY_AP_PKG" 
-- $Header: jgzzsummaryapb.pls 120.29.12010000.17 2010/02/10 14:35:53 rahulkum ship $
AS

  /*
  REM +======================================================================+
  REM Name: UNPAID_AMT
  REM
  REM Description: This function is used to calculate the unpaid
  REM              amount on an invoice.
  REM
  REM Parameters:
  REM             pn_inv_id => The invoice id
  REM             pn_inv_amount => The invoice amount in functional currency.
  REM             pn_taxable_amount => The taxable amount of the invoice.
  REM             pv_offset_tax_code => The offset tax code for the invoice if any
  REM             pd_end_date => Period end date of the period.
  REM +======================================================================+
  */

  g_debug constant boolean := true;

  FUNCTION unpaid_amt(pn_inv_id          NUMBER
                     ,pn_inv_amount      NUMBER
                     ,pn_taxable_amount  NUMBER
                     ,pv_offset_tax_code VARCHAR2
                     ,pd_end_date        DATE) RETURN NUMBER IS

    l_inv_amt           NUMBER;
    l_unpaid_amt        NUMBER;
    l_exchange_rate     NUMBER;
    l_prepay_on_inv_amt NUMBER;
    l_sbe_flag          VARCHAR2(10);
    l_cleared_amount    NUMBER;
    CURSOR c_amount_remaining
    IS
      SELECT nvl(SUM(amount_remaining), -9999) amount_remaining
        FROM ap_invoices_all          INV
            ,ap_invoice_payments_all  PAY
            ,ap_checks_all            CHECKS
            ,ap_payment_schedules_all APS
       WHERE APS.invoice_id = inv.invoice_id
         AND inv.invoice_id = pay.invoice_id
         AND checks.check_id = pay.check_id
         AND pn_inv_id = inv.invoice_id
         AND checks.status_lookup_code IN ('CLEARED', 'RECONCILED','CLEARED BUT UNACCOUNTED', 'RECONCILED UNACCOUNTED')
         AND trunc(checks.cleared_date) <= pd_end_date;

    CURSOR c_prepay_inv_amount
    IS
      SELECT ABS(NVL(SUM(apid.amount), 0)) prepay_on_inv_amt
        FROM ap_invoice_distributions_all apid
       WHERE PREPAY_DISTRIBUTION_ID IS NOT NULL
         AND invoice_id = pn_inv_id;

    CURSOR c_inv_amount
    IS
      SELECT nvl(base_amount, invoice_amount)  invoice_amount
            ,nvl(exchange_rate, 1) exchange_rate
        FROM ap_invoices_all
       WHERE invoice_id = pn_inv_id;

    CURSOR c_cleared_amount
    IS
      SELECT NVL(SUM(checks.amount),0)
	FROM ap_invoices_all INV
	    ,ap_invoice_payments_all PAY
	    ,ap_checks_all CHECKS
	    WHERE pn_inv_id = inv.invoice_id
	    AND checks.check_id = pay.check_id
	    AND inv.invoice_id = pay.invoice_id
	    AND checks.status_lookup_code IN ('CLEARED', 'RECONCILED','CLEARED BUT UNACCOUNTED', 'RECONCILED UNACCOUNTED')
	    AND trunc(checks.cleared_date) <= pd_end_date;
    CURSOR c_sbe_flag
    IS
        SELECT nvl(pv.small_business_flag,'N') small_business_flag
            FROM po_vendors pv, ap_invoices_all  inv
                WHERE inv.invoice_id = pn_inv_id
                AND inv.vendor_id  =  pv.vendor_id;
  BEGIN

    FOR c_amt_remaining IN c_amount_remaining
    LOOP
      l_unpaid_amt := c_amt_remaining.amount_remaining;
    END LOOP;

    -- get the prepayments applied to the invoice with
    -- include prepay flag as 'NO'

    FOR c_prepay_inv_amt IN c_prepay_inv_amount
    LOOP
      l_prepay_on_inv_amt := c_prepay_inv_amt.prepay_on_inv_amt;
    END LOOP;

    FOR c_inv_amt IN c_inv_amount
    LOOP
      l_inv_amt := c_inv_amt.invoice_amount;
      l_exchange_rate := c_inv_amt.exchange_rate;
    END LOOP;

    FOR cv_sbe_flag IN c_sbe_flag
    LOOP
      l_sbe_flag := cv_sbe_flag.small_business_flag;
    END LOOP;

    IF l_inv_amt <> 0 THEN
      IF pv_offset_tax_code IS NOT NULL THEN
        IF l_unpaid_amt = -9999 THEN
          l_unpaid_amt    := l_inv_amt;
          l_exchange_rate := 1;
        END IF;
        l_unpaid_amt := l_unpaid_amt - l_prepay_on_inv_amt;
        l_unpaid_amt := (l_unpaid_amt * (pn_taxable_amount / l_inv_amt));
        RETURN(l_unpaid_amt * l_exchange_rate);
      ELSE
        -- Added the modified Unpaid amount Logic for bug 5768048 starts
        -- Here I am restricting my modified logic of unpaid amount
	  -- for Non-Offset Invoices with SBE flag as Y
        IF l_sbe_flag ='Y' THEN
	    IF c_cleared_amount%ISOPEN THEN
	      CLOSE c_cleared_amount;
	    END IF;
	    OPEN c_cleared_amount;
	      FETCH c_cleared_amount INTO l_cleared_amount;
	    CLOSE c_cleared_amount;
	    l_unpaid_amt := l_inv_amt - l_cleared_amount;
	-- Added the modified Unpaid amount Logic for bug 5768048 ends
	ELSE
	    IF l_unpaid_amt = -9999 THEN
	      l_unpaid_amt    := l_inv_amt;
	      l_exchange_rate := 1;
	    END IF;
        END IF;
	l_unpaid_amt := l_unpaid_amt - l_prepay_on_inv_amt;
	l_unpaid_amt := (l_unpaid_amt * (pn_inv_amount / l_inv_amt));
	RETURN(l_unpaid_amt * l_exchange_rate);
      END IF;
    ELSE
      RETURN NULL;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      if g_debug = true then
        fnd_file.put_line(fnd_file.log,' An error occured while calculating the unpaid amount. Error : ' || SUBSTR(SQLERRM,1,200));
      end if;
      RETURN NULL;
  END unpaid_amt;

/*
REM +======================================================================+
REM Name: BEFORE_REPORT
REM
REM Description: This function is called as a before report trigger by the
REM              data template. It populates the data in the global_tmp table
REM              and creates the dynamic where clause for the data template
REM              queries(lexical reference).
REM
REM Parameters:   None
REM +======================================================================+
*/
  FUNCTION before_report RETURN BOOLEAN IS
  BEGIN

    DECLARE

	-- IL VAT Reporting 2010 ER -- Variables Declaration
	l_calendar_name VARCHAR2(15);
    l_percentage	NUMBER;
	l_max_rec_amt	NUMBER;
	l_min_rec_amt	NUMBER;
	l_total_vat_amt	NUMBER;
	l_petty_cash_vat_amt	NUMBER;
	l_calculated_max_rec_amt	NUMBER;
	l_declared_amount	NUMBER;

	l_tax_calendar_period	VARCHAR2(15);
	l_trx_date	DATE;
	l_trx_id	NUMBER;
	l_trx_number	VARCHAR2(100);
	l_cum_total_amt	NUMBER;
	l_rep_status_id	NUMBER;
	l_cur_period_end_date	DATE;

	l_count	NUMBER := 1;

	TYPE t_rep_status_id IS TABLE OF JG_ZZ_VAT_REP_STATUS.REPORTING_STATUS_ID%TYPE INDEX BY BINARY_INTEGER;
	TYPE t_trx_number IS TABLE OF JG_ZZ_VAT_TRX_DETAILS.TRX_NUMBER%TYPE INDEX BY BINARY_INTEGER;
	TYPE t_trx_date IS TABLE OF JG_ZZ_VAT_TRX_DETAILS.TRX_DATE%TYPE INDEX BY BINARY_INTEGER;
	TYPE t_il_rep_status IS TABLE OF JG_ZZ_VAT_TRX_DETAILS.IL_VAT_REP_STATUS_ID%TYPE INDEX BY BINARY_INTEGER;

	rep_status_id_rec_tab t_rep_status_id;
	trx_number_rec_tab t_trx_number;
	trx_date_rec_tab t_trx_date;
	il_rep_status_rec_tab t_il_rep_status;

	-- IL VAT Reporting 2010 ER -- Variables Declaration

      l_cleared_select              VARCHAR2(2000);
      l_cleared_select1             VARCHAR2(2000);
      l_unpaid_amt_select           VARCHAR2(2000);
      l_vat_or_offset               NUMBER;
      l_offset_tax_code_name        VARCHAR2(50);
      l_country_code                VARCHAR2(5);
      l_end_date                    DATE;
      l_unpaid_amount               NUMBER;
      l_curr_code                   VARCHAR2(50);
      l_rep_entity_name             jg_zz_vat_trx_details.rep_context_entity_name%TYPE;
      l_legal_entity_id             NUMBER;
      l_taxpayer_id                 jg_zz_vat_trx_details.taxpayer_id%TYPE;
      l_company_name                xle_registrations.registered_name%TYPE;
      l_registration_number         xle_registrations.registration_number%TYPE;
      l_country                     hz_locations.country%TYPE;
      l_address1                    hz_locations.address1%TYPE;
      l_address2                    hz_locations.address2%TYPE;
      l_address3                    hz_locations.address3%TYPE;
      l_address4                    hz_locations.address4%TYPE;
      l_city                        hz_locations.city%TYPE;
      l_postal_code                 hz_locations.postal_code%TYPE;
      l_contact                     hz_parties.party_name%TYPE;
      l_phone_number                hz_contact_points.phone_number%TYPE;
      l_tax_registration_num        VARCHAR2 (240);
      l_period_end_date             DATE;
      l_period_start_date           DATE;
      l_reporting_status            VARCHAR2 (60);
      l_lineno                      NUMBER ;
      v_count		NUMBER 		:=0;
      v_prev_vat_code	VARCHAR2(230)	:='';
      v_is_seq_updated VARCHAR2(1) := 'N';
      v_dummy		NUMBER;
      l_enable_report_sequence_flag	VARCHAR2(2);
       -- Added for Glob-006 ER
      l_province                      VARCHAR2(120);
      l_comm_num                      VARCHAR2(30);
      l_vat_reg_num                   VARCHAR2(50);
      l_ledger_id                       NUMBER;
      l_entity_type_code                VARCHAR2(30); -- Bug 8289960
      l_ledger_category_code            VARCHAR2(30); -- Bug 8289960
      -- end here


      CURSOR C_DATA IS
        SELECT jzvtd.doc_seq_value                                            SEQ_NUMBER
              ,jzvtd.tax_invoice_date                                         TAX_DATE
              ,jzvtd.billing_tp_name                                          CUSTOMER_NAME
              ,jzvtd.accounting_date                                          GL_DATE
              ,jzvtd.trx_currency_code
              ,sum(nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt)
                   + nvl(jzvtd.taxable_amt_funcl_curr, jzvtd.taxable_amt))    TOTAL_ACCOUNTED_AMOUNT
              ,sum(nvl(jzvtd.tax_amt,0) + nvl(jzvtd.taxable_amt, 0))          TOTAL_ENTERED_AMOUNT
              ,sum(nvl(jzvtd.taxable_amt, 0))                                 TAXABLE_ENTERED_AMOUNT
              ,sum(nvl(jzvtd.taxable_amt_funcl_curr, jzvtd.taxable_amt))      TAXABLE_AMOUNT
          /* fixed during UT for Bug# 5258868
          ,sum(nvl(jzvtd.tax_amt, 0)) tax_amount
          ,sum(decode(jzvtd.tax_recoverable_flag, 'Y', jzvtd.tax_amt, 0)) RECOVERABLE
          ,sum(decode(jzvtd.tax_recoverable_flag, 'N', 0, jzvtd.tax_amt)) NON_RECOVERABLE*/
          /* following 3 columns added for Bug# 5258868 */
          ,sum(nvl(jzvtd.tax_amt_funcl_curr, jzvtd.tax_amt)) tax_amount
          ,sum(decode(jzvtd.tax_recoverable_flag, 'Y', nvl(jzvtd.tax_amt_funcl_curr, jzvtd.tax_amt), 0)) recoverable
          ,sum(decode(nvl(jzvtd.tax_recoverable_flag,'Y'), 'N', nvl(jzvtd.tax_amt_funcl_curr, jzvtd.tax_amt), 0)) non_recoverable
              ,jzvtd.trx_number                                               INV_NUMBER
              ,jzvtd.trx_date                                                 INV_DATE
              ,jzvtd.billing_tp_tax_reg_num                                   TAX_REG_NUM
              ,jzvtd.tax_rate                                                 TAX_RATE
              ,jzvtd.trx_id
              ,jzvtd.tax_rate_vat_trx_type_desc
              ,jzvtd.tax_rate_code_vat_trx_type_mng
              ,jzvtd.tax_rate_code
              ,jzvtd.trx_line_class
              ,jzvtd.tax_rate_code_description
              ,jzvtd.tax_recoverable_flag rec_flag
              ,jzvtd.account_flexfield
              ,jzvtd.doc_seq_name
              /* UT TEST ,to_char(jzvtd.tax_invoice_date,'MON')               GL_PERIOD */
              , jzvrs.tax_calendar_period                                     GL_PERIOD  /* UT TEST */
              ,jzvtd.tax_rate_vat_trx_type_code
              ,jzvtd.reporting_code
              ,jzvtd.tax_line_id
              ,jzvtd.offset_flag
              ,jzvtd.offset_tax_rate_code
              ,jzvtd.chk_vat_amount_paid                                      CHK_VAT_AMOUNT_PAID
              ,jzvrs.period_end_date
          FROM jg_zz_vat_trx_details jzvtd
              ,jg_zz_vat_rep_status  jzvrs
         WHERE jzvrs.vat_reporting_entity_id = P_VAT_REPORTING_ENTITY_ID
          -- AND jzvrs.tax_calendar_period = P_TAX_CALENDAR_PERIOD --bug5867390
		AND jzvtd.tax_invoice_date <= (SELECT period_end_date
                                       FROM  jg_zz_vat_rep_status jzvrs
                                       WHERE jzvrs.vat_reporting_entity_id = P_VAT_REPORTING_ENTITY_ID
                                       AND   jzvrs.source = 'AP'
                                       AND   jzvrs.tax_calendar_period = P_TAX_CALENDAR_PERIOD)
           AND jzvrs.reporting_status_id = jzvtd.reporting_status_id
           AND jzvtd.tax_rate_register_type_code = 'TAX'
           AND jzvrs.source = 'AP'
           AND (P_VAT_TRX_TYPE IS NULL OR jzvtd.tax_rate_vat_trx_type_code = P_VAT_TRX_TYPE)
           AND (P_EX_VAT_TRX_TYPE is null or nvl(jzvtd.tax_rate_vat_trx_type_code,'#') <> P_EX_VAT_TRX_TYPE)
           AND (P_INC_PREPAYMENTS = 'Y' OR (jzvtd.trx_line_class <> 'PREPAYMENT INVOICES' AND P_INC_PREPAYMENTS = 'N') )
         GROUP BY jzvtd.reporting_code
                 ,jzvtd.doc_seq_value
                 , jzvrs.tax_calendar_period  /* UT TEST addition */
                 ,jzvtd.tax_invoice_date
                 ,jzvtd.billing_tp_name
                 ,jzvtd.accounting_date
                 ,jzvtd.trx_currency_code
                 ,trx_number
                 ,trx_date
                 ,billing_tp_tax_reg_num
                 ,tax_rate
                 ,jzvtd.trx_id
                 ,jzvtd.tax_rate_vat_trx_type_desc
                 ,jzvtd.tax_rate_code_vat_trx_type_mng
                 ,jzvtd.tax_rate_code
                 ,jzvtd.trx_line_class
                 ,jzvtd.tax_rate_code_description
                 ,jzvtd.tax_recoverable_flag
                 ,jzvtd.account_flexfield
                 ,jzvtd.doc_seq_name
                 ,jzvtd.tax_rate_vat_trx_type_code
                 ,jzvtd.chk_vat_amount_paid
                 ,jzvtd.tax_line_id
                 ,jzvtd.offset_flag
                 ,jzvtd.offset_tax_rate_code
                 ,jzvrs.period_end_date ;


      CURSOR C_NEW IS
        SELECT jzvtd.doc_seq_value seq_number
          ,jzvtd.tax_invoice_date tax_date
          ,decode(jzvtd.event_class_code, 'EXPENSE REPORTS',
                  decode(jzvtd.merchant_party_name, null,
                       jzvtd.billing_tp_name, jzvtd.merchant_party_name), jzvtd.billing_tp_name) customer_name
          ,jzvtd.accounting_date gl_date
          ,jzvtd.trx_currency_code
          ,sum(nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt)
               + nvl(jzvtd.taxable_amt_funcl_curr, jzvtd.taxable_amt)*jzvtd.tax_recovery_rate/100) total_accounted_amount
          ,sum(nvl(jzvtd.tax_amt,0) + nvl(jzvtd.taxable_amt, 0)*jzvtd.tax_recovery_rate/100)       total_entered_amount
          ,sum(nvl(jzvtd.taxable_amt, 0)*jzvtd.tax_recovery_rate/100)                              taxable_entered_amount
          ,sum(nvl(jzvtd.taxable_amt_funcl_curr, jzvtd.taxable_amt)*jzvtd.tax_recovery_rate/100)   taxable_amount
          /* fixed during UT for Bug# 5258868
          ,sum(nvl(jzvtd.tax_amt, 0)) tax_amount
          ,sum(decode(jzvtd.tax_recoverable_flag, 'Y', jzvtd.tax_amt, 0)) recoverable
          ,sum(decode(jzvtd.tax_recoverable_flag, 'N', 0, jzvtd.tax_amt)) non_recoverable */
          /* following 3 columns added for Bug# 5258868 */
          ,sum(nvl(jzvtd.tax_amt_funcl_curr, jzvtd.tax_amt))           tax_amount
          ,sum(decode(jzvtd.tax_recoverable_flag, 'Y', nvl(jzvtd.tax_amt_funcl_curr, jzvtd.tax_amt), 0)) recoverable
          ,sum(decode(nvl(jzvtd.tax_recoverable_flag,'Y'), 'N', nvl(jzvtd.tax_amt_funcl_curr, jzvtd.tax_amt), 0)) non_recoverable
          ,decode(jzvtd.event_class_code, 'EXPENSE REPORTS',
                   decode(jzvtd.merchant_party_document_number, null,
                              jzvtd.trx_number, jzvtd.merchant_party_document_number), jzvtd.trx_number) inv_number
          ,decode(jzvtd.event_class_code, 'EXPENSE REPORTS',
                   decode(jzvtd.start_expense_date, null,
                           jzvtd.trx_date, jzvtd.start_expense_date), jzvtd.trx_date) inv_date
          ,decode(jzvtd.event_class_code, 'EXPENSE REPORTS',
                   decode(jzvtd.merchant_party_tax_reg_number, null,
                            jzvtd.billing_tp_tax_reg_num, jzvtd.merchant_party_tax_reg_number), jzvtd.billing_tp_tax_reg_num) tax_reg_num
          ,jzvtd.tax_rate tax_rate
          ,jzvtd.trx_id
          ,jzvtd.tax_rate_vat_trx_type_desc
          ,jzvtd.tax_rate_code_vat_trx_type_mng
          ,jzvtd.tax_rate_code
          ,jzvtd.trx_line_class
          ,jzvtd.tax_rate_code_description
          ,jzvtd.doc_seq_name
          ,jzvrs.tax_calendar_period                        gl_period  /* UT TEST addition */
          /* UT TEST ,to_char(jzvtd.tax_invoice_date,'MON') gl_period */
          ,jzvtd.tax_rate_vat_trx_type_code
          ,jzvtd.reporting_code
          ,jzvtd.tax_line_id
          ,jzvtd.offset_flag
          ,jzvtd.offset_tax_rate_code
          ,jzvtd.chk_vat_amount_paid chk_vat_amount_paid
          ,jzvrs.period_end_date
         FROM jg_zz_vat_trx_details jzvtd
            ,jg_zz_vat_rep_status  jzvrs
         WHERE jzvrs.vat_reporting_entity_id = P_VAT_REPORTING_ENTITY_ID
          -- AND jzvrs.tax_calendar_period = P_TAX_CALENDAR_PERIOD --bug5867390
		AND jzvtd.tax_invoice_date <= (SELECT period_end_date
                                       FROM  jg_zz_vat_rep_status jzvrs
                                       WHERE jzvrs.vat_reporting_entity_id = P_VAT_REPORTING_ENTITY_ID
                                       AND   jzvrs.source = 'AP'
                                       AND   jzvrs.tax_calendar_period = P_TAX_CALENDAR_PERIOD)
           AND jzvrs.reporting_status_id = jzvtd.reporting_status_id
          -- AND jzvtd.tax_rate_register_type_code = 'TAX'
           AND jzvrs.source = 'AP'
           AND (P_VAT_TRX_TYPE IS NULL OR jzvtd.tax_rate_vat_trx_type_code = P_VAT_TRX_TYPE)
           AND (P_EX_VAT_TRX_TYPE IS NULL OR nvl(jzvtd.tax_rate_vat_trx_type_code,'#') <> P_EX_VAT_TRX_TYPE)
           AND ((jzvtd.trx_line_class <> 'PREPAYMENT INVOICES' AND P_INC_PREPAYMENTS = 'N') OR P_INC_PREPAYMENTS = 'Y')
         GROUP BY jzvtd.tax_rate_code_vat_trx_type_mng
                 ,jzvtd.tax_rate_vat_trx_type_desc
                 ,jzvtd.tax_rate_code
                 ,decode(jzvtd.event_class_code, 'EXPENSE REPORTS',
                      decode(jzvtd.merchant_party_document_number, null,
                              jzvtd.trx_number, jzvtd.merchant_party_document_number), jzvtd.trx_number)
                 ,jzvtd.doc_seq_value
                 ,jzvrs.tax_calendar_period   /* UT TEST addition */
                 ,jzvtd.tax_invoice_date
                 ,decode(jzvtd.event_class_code, 'EXPENSE REPORTS',
                    decode(jzvtd.merchant_party_name, null,
                         jzvtd.billing_tp_name, jzvtd.merchant_party_name), jzvtd.billing_tp_name)
                 ,jzvtd.accounting_date
                 ,jzvtd.trx_currency_code
                 ,decode(jzvtd.event_class_code, 'EXPENSE REPORTS',
                     decode(jzvtd.start_expense_date, null,
                           jzvtd.trx_date, jzvtd.start_expense_date), jzvtd.trx_date)
                 ,decode(jzvtd.event_class_code, 'EXPENSE REPORTS',
                     decode(jzvtd.merchant_party_tax_reg_number, null,
                            jzvtd.billing_tp_tax_reg_num, jzvtd.merchant_party_tax_reg_number), jzvtd.billing_tp_tax_reg_num)
                 ,jzvtd.tax_rate
                 ,jzvtd.trx_id
                 ,jzvtd.trx_line_class
                 ,jzvtd.tax_rate_code_description
                 ,jzvtd.doc_seq_name
                 ,jzvtd.tax_rate_vat_trx_type_code
                 ,jzvtd.chk_vat_amount_paid
                 ,jzvtd.reporting_code
                 ,jzvtd.tax_line_id
                 ,jzvtd.offset_flag
                 ,jzvtd.offset_tax_rate_code
                 ,jzvrs.period_end_date;


		     	-- Cursor for report level seq number --

			   -- Cursor for report level seq number --
              CURSOR temp_cur IS
                SELECT  jg_info_n1  seq_num,
                        jg_info_v7 vat_code,
                        tmp.rowid,
                        jg_info_v14 tax_code,
                        jg_info_n5  trx_id,
                        jg_info_v15 reporting_code
                FROM   JG_ZZ_VAT_TRX_GT tmp,
                        gl_periods glp,
                        jg_zz_vat_rep_status JZVRS
                WHERE jg_info_v9 = 'M'
                AND JZVRS.vat_reporting_entity_id = P_VAT_REPORTING_ENTITY_ID
                AND jzvrs.tax_calendar_period = P_TAX_CALENDAR_PERIOD
		AND jg_info_v16 = jzvrs.tax_calendar_period  --bug5867390
                AND GLP.period_set_name = jzvrs.tax_calendar_name
                AND jg_info_d1 between glp.start_date and glp.end_date
                AND jzvrs.source = 'AP'
                ORDER BY decode(jg_info_v15, 'OFFSET','XOFFSET','VAT'),
                        jg_info_v7, --TAX_RATE_VAT_TRX_TYPE_CODE
                        jg_info_v13,
                        jg_info_v12, --VAT_TRANSACTION_TYPE_CODE description.
                        period_year desc,
                        period_num desc,
                        jg_info_v6, --TAX CODE DESC
                        jg_info_v14, --TAX_RATE_CODE
                        jg_info_d1, --TAX_INVOICE_DATE
                        jg_info_v1,
                        jg_info_n3; /*tax_rate*/


      CURSOR C_COMPLETE IS
        SELECT jzvtd.doc_seq_value seq_number
              ,jzvtd.tax_invoice_date tax_date
              ,jzvtd.billing_tp_name customer_name
              ,jzvtd.accounting_date gl_date
              ,jzvtd.trx_currency_code
              ,jzvtd.tax_amt_funcl_curr
              ,jzvtd.taxable_amt_funcl_curr
              ,jzvtd.tax_amt  tax_amount
              ,jzvtd.taxable_amt  taxable_amount
              ,jzvtd.tax_recoverable_flag
              ,jzvtd.trx_number inv_number
              ,jzvtd.trx_date inv_date
              ,jzvtd.billing_tp_tax_reg_num tax_reg_num
              ,jzvtd.tax_rate tax_rate
              ,jzvtd.trx_id
              ,jzvtd.tax_rate_vat_trx_type_desc
              ,jzvtd.tax_rate_code_vat_trx_type_mng
              ,jzvtd.tax_rate_code
              ,jzvtd.trx_line_class
              ,jzvtd.tax_rate_code_description
              ,jzvtd.tax_recoverable_flag rec_flag
              ,jzvtd.account_flexfield
              ,jzvtd.doc_seq_name
              , jzvrs.tax_calendar_period            gl_period  /* UT TEST */
              /* UT TEST ,to_char(jzvtd.tax_invoice_date,'MON') gl_period  */
              ,jzvtd.tax_rate_vat_trx_type_code
              ,jzvtd.tax_type_code
              ,jzvtd.tax_line_id
              ,jzvtd.offset_flag
              ,jzvtd.offset_tax_rate_code
              ,jzvtd.chk_vat_amount_paid chk_vat_amount_paid
              ,jzvrs.period_end_date
	      ,jzvtd.reporting_code
          FROM jg_zz_vat_trx_details jzvtd
              ,jg_zz_vat_rep_status  jzvrs
         WHERE jzvrs.vat_reporting_entity_id = P_VAT_REPORTING_ENTITY_ID
           AND jzvrs.tax_calendar_period = P_TAX_CALENDAR_PERIOD
           AND jzvrs.reporting_status_id = jzvtd.reporting_status_id
           AND jzvrs.source = 'AP'
           AND jzvtd.tax_rate_register_type_code = 'TAX';

      CURSOR c_get_lookup_values (p_trx_type      VARCHAR2)
      IS
        SELECT meaning
              ,description
          FROM fnd_lookups
         WHERE lookup_type = 'ZX_JEBE_VAT_TRANS_TYPE'
           AND lookup_code = p_trx_type;

      CURSOR c_company_details
      IS
        SELECT jzvtd.rep_context_entity_name  company_name
              ,jzvtd.functional_currency_code functional_currency_code
          FROM jg_zz_vat_trx_details jzvtd
              ,jg_zz_vat_rep_status  jzvrs
         WHERE jzvrs.vat_reporting_entity_id = P_VAT_REPORTING_ENTITY_ID
           AND jzvrs.source = 'AP'
           AND jzvrs.tax_calendar_period = P_TAX_CALENDAR_PERIOD
           AND jzvrs.reporting_status_id = jzvtd.reporting_status_id
           and rownum < 2; /* added during UT Bug# 5258868 */

      CURSOR c_vat_or_offset (p_tax_rate_code      VARCHAR2)
      IS
        SELECT MIN(-9999) vat_or_offset
          FROM jg_zz_vat_trx_details  jzvtd
              ,jg_zz_vat_rep_status   jzvrs
         WHERE jzvtd.tax_rate_code = p_tax_rate_code
           AND jzvrs.reporting_status_id = jzvtd.reporting_status_id
           AND jzvrs.vat_reporting_entity_id = P_VAT_REPORTING_ENTITY_ID
           AND jzvrs.source = 'AP'
           AND jzvrs.tax_calendar_period = P_TAX_CALENDAR_PERIOD
           AND jzvtd.offset_tax_rate_code IS NOT NULL;

      CURSOR c_period_end_date
      IS
        SELECT period_end_date
          FROM jg_zz_vat_rep_status jzvrs
         WHERE jzvrs.vat_reporting_entity_id = P_VAT_REPORTING_ENTITY_ID
           AND jzvrs.source = 'AP'
           AND jzvrs.tax_calendar_period = P_TAX_CALENDAR_PERIOD;

	-- IL VAT Reporting 2010 ER -- Cursors

	CURSOR il_get_limits
	IS
		SELECT
			limit.max_recoverable_percentage,
			limit.max_recoverable_amt,
			limit.min_recoverable_amt,
			limit.period_set_name
		FROM
			je_il_vat_limits  limit,
			JG_ZZ_VAT_REP_STATUS JZVRS
		WHERE
			JZVRS.VAT_REPORTING_ENTITY_ID = P_VAT_REPORTING_ENTITY_ID
			AND JZVRS.TAX_CALENDAR_PERIOD = P_TAX_CALENDAR_PERIOD
			AND	JZVRS.TAX_CALENDAR_NAME	= limit.PERIOD_SET_NAME
			AND	limit.PERIOD_NAME = P_TAX_CALENDAR_PERIOD
			AND ROWNUM = 1;


	CURSOR il_get_total_vat_amt
	IS
		SELECT
			sum(decode(tax_recoverable_flag,'Y', nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt),0))
			total_vat_amt
		FROM
			jg_zz_vat_trx_details jzvtd,
			jg_zz_vat_rep_status  jzvrs
		WHERE jzvrs.source='AP'
		and     jzvrs.vat_reporting_entity_id = p_vat_reporting_entity_id
		and     jzvrs.tax_calendar_period     = p_tax_calendar_period
		and     (p_vat_trx_type is null or jzvtd.tax_rate_vat_trx_type_code = p_vat_trx_type)
		and     jzvrs.reporting_status_id     = jzvtd.reporting_status_id
		and  jzvtd.reporting_code in ('VAT-A','VAT-S', 'VAT-C', 'VAT-RA', 'VAT-RS', 'VAT-P', 'VAT-H');

	CURSOR il_get_petty_cash_vat_amt
	IS
		SELECT nvl(sum(total_vatks_amt),0) total_petty_cash_vat_amt
		FROM
		(SELECT
			sum(decode(tax_recoverable_flag,'Y', nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt),0))
			total_vatks_amt
		FROM
			jg_zz_vat_trx_details jzvtd,
			jg_zz_vat_rep_status  jzvrs
		WHERE jzvrs.source='AP'
		and   jzvrs.vat_reporting_entity_id = p_vat_reporting_entity_id
		and   jzvrs.tax_calendar_period     <> p_tax_calendar_period
		and   jzvrs.reporting_status_id     = jzvtd.reporting_status_id
		and   (jzvtd.il_vat_rep_status_id = -999 OR jzvtd.il_vat_rep_status_id = l_rep_status_id)
		and   (p_vat_trx_type is null or jzvtd.tax_rate_vat_trx_type_code = p_vat_trx_type)
		and   jzvtd.reporting_code in ('VAT-KS','VAT-KA')
		UNION ALL
		SELECT
			sum(decode(tax_recoverable_flag,'Y', nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt),0))
			total_vatks_amt
		FROM
			jg_zz_vat_trx_details jzvtd,
			jg_zz_vat_rep_status  jzvrs
		WHERE jzvrs.source='AP'
		and   jzvrs.vat_reporting_entity_id = p_vat_reporting_entity_id
		and   jzvrs.tax_calendar_period  = p_tax_calendar_period
		and   jzvrs.reporting_status_id     = jzvtd.reporting_status_id
		and   (p_vat_trx_type is null or jzvtd.tax_rate_vat_trx_type_code = p_vat_trx_type)
		and   jzvtd.reporting_code in ('VAT-KS','VAT-KA'));

	CURSOR il_get_rep_status_id
	IS
		SELECT
			jzvrs.reporting_status_id,
			jzvrs.period_end_date
		FROM
			jg_zz_vat_rep_status jzvrs
		WHERE
			jzvrs.source='AP'
			and     jzvrs.vat_reporting_entity_id = p_vat_reporting_entity_id
			and     jzvrs.tax_calendar_period     = p_tax_calendar_period;

	CURSOR il_get_petty_cash_trxs
	IS
		SELECT
			  trxs.billing_tp_name,
			  trxs.billing_tp_number,
			  trxs.billing_tp_site_name,
			  trxs.trx_date,
			  trxs.trx_number,
			  trxs.reporting_status_id,
			  trxs.total_vat_amt,
			  SUM(trxs.total_vat_amt) over (ORDER BY trxs.billing_tp_name,
					  trxs.billing_tp_number,
					  trxs.billing_tp_site_name,
				      trxs.trx_date,
					  trxs.trx_number,
					  trxs.reporting_status_id) cum_total_amt
		FROM
			  (SELECT
					  jzvtd.billing_tp_name,
					  jzvtd.billing_tp_number,
					  jzvtd.billing_tp_site_name,
				      jzvtd.trx_date,
					  jzvtd.trx_number,
					  jzvrs.reporting_status_id,
					  SUM(DECODE(jzvtd.tax_recoverable_flag,'Y', NVL(jzvtd.tax_amt_funcl_curr,NVL(jzvtd.tax_amt,0)),0)) total_vat_amt
			  FROM
					  jg_zz_vat_trx_details jzvtd,
					  jg_zz_vat_rep_status  jzvrs
			  WHERE
					  jzvrs.source='AP'
					  and  jzvrs.vat_reporting_entity_id = p_vat_reporting_entity_id
					  and  (jzvtd.il_vat_rep_status_id = -999 OR jzvtd.il_vat_rep_status_id = l_rep_status_id)
					  and  jzvrs.tax_calendar_period     <> p_tax_calendar_period
					  and  jzvrs.reporting_status_id     = jzvtd.reporting_status_id
					  and  jzvrs.period_end_date <= l_cur_period_end_date
					  and  (p_vat_trx_type is null or jzvtd.tax_rate_vat_trx_type_code = p_vat_trx_type)
					  and  jzvtd.reporting_code in ('VAT-KS','VAT-KA')
			  group by jzvtd.billing_tp_name,
					  jzvtd.billing_tp_number,
					  jzvtd.billing_tp_site_name,
				      jzvtd.trx_date,
					  jzvtd.trx_number,
					  jzvrs.reporting_status_id
			  UNION ALL
			  SELECT
					  jzvtd.billing_tp_name,
					  jzvtd.billing_tp_number,
					  jzvtd.billing_tp_site_name,
				      jzvtd.trx_date,
					  jzvtd.trx_number,
					  jzvrs.reporting_status_id,
					  SUM(DECODE(jzvtd.tax_recoverable_flag,'Y', NVL(jzvtd.tax_amt_funcl_curr,NVL(jzvtd.tax_amt,0)),0)) total_vat_amt
			  FROM
					  jg_zz_vat_trx_details jzvtd,
					  jg_zz_vat_rep_status  jzvrs
			  WHERE
					  jzvrs.source='AP'
					  and  jzvrs.vat_reporting_entity_id = p_vat_reporting_entity_id
					  and  jzvrs.tax_calendar_period     = p_tax_calendar_period
					  and  jzvrs.reporting_status_id     = jzvtd.reporting_status_id
					  and  jzvrs.period_end_date <= l_cur_period_end_date
					  and  (p_vat_trx_type is null or jzvtd.tax_rate_vat_trx_type_code = p_vat_trx_type)
					  and  jzvtd.reporting_code in ('VAT-KS','VAT-KA')
			  GROUP BY jzvtd.billing_tp_name,
					  jzvtd.billing_tp_number,
					  jzvtd.billing_tp_site_name,
				      jzvtd.trx_date,
					  jzvtd.trx_number,
					  jzvrs.reporting_status_id) trxs
		ORDER BY trxs.billing_tp_name,
					  trxs.billing_tp_number,
					  trxs.billing_tp_site_name,
				      trxs.trx_date,
					  trxs.trx_number,
					  trxs.reporting_status_id;


	CURSOR israel_new_details
	IS
	     -- VAT File Line Type - T , C, P , H
		 -- Reporting Code :
		 --       'VAT-A','VAT-KA','VAT-RA' - Fixed Assets ,
	     --       'VAT-S','VAT-C','VAT-P','VAT-H' - Other Trxs
		SELECT jzvtd.billing_tp_name vendor_name
			,jzvtd.billing_tp_number vendor_number
			,jzvtd.billing_tp_site_name site_name
			,NVL(jzvtd.billing_tp_site_tax_reg_num,jzvtd.billing_tp_tax_reg_num) tax_reg_num
			,jzvtd.trx_number inv_number
			,jzvtd.trx_date inv_date
			,NULL  import_document_number
			,NULL  import_document_date
			,DECODE(nvl2(apinv.cancelled_date,'Y','N'),'Y','CANCELLED',jzvtd.trx_line_class) trx_line_class
			,jzvtd.posted_flag
			,JG_ZZ_COMMON_PKG.get_amt_tot(jzvtd.trx_id,l_ledger_id,G_PRECISION) invoice_amount
			,sum(DECODE(tax_recoverable_flag,'Y',
				(CASE
					WHEN jzvtd.reporting_code IN ('VAT-A') THEN nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt)
					ELSE 0
				END)
				, 0)) vat_on_fixed_assets
			,sum(DECODE(tax_recoverable_flag,'Y',
				(CASE
					WHEN jzvtd.reporting_code IN ('VAT-S','VAT-C','VAT-P','VAT-H') THEN nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt)
					ELSE 0
				END)
				, 0)) vat_on_other_trxs
			,(CASE
				WHEN jzvtd.reporting_code = 'VAT-C' THEN 'C'
				WHEN jzvtd.reporting_code = 'VAT-P' THEN 'P'
				WHEN jzvtd.reporting_code = 'VAT-H' THEN 'H'
				ELSE 'T'
			  END) class
			,0	mark_trx_flag
		FROM    jg_zz_vat_trx_details jzvtd
			,jg_zz_vat_rep_status  jzvrs
			,ap_invoices_all  apinv
		WHERE   jzvrs.source='AP'
			AND     jzvrs.vat_reporting_entity_id       = P_VAT_REPORTING_ENTITY_ID
			AND     jzvrs.tax_calendar_period           = P_TAX_CALENDAR_PERIOD
			AND     JZVRS.REPORTING_STATUS_ID           = JZVTD.REPORTING_STATUS_ID
			AND     (P_VAT_TRX_TYPE is null or jzvtd.tax_rate_vat_trx_type_code = P_VAT_TRX_TYPE)
			AND     jzvtd.reporting_code IN ('VAT-A','VAT-S','VAT-C','VAT-P','VAT-H')
			AND     apinv.invoice_id = jzvtd.trx_id
		GROUP BY  jzvtd.billing_tp_name
			,jzvtd.billing_tp_number
			,jzvtd.billing_tp_site_name
			,NVL(jzvtd.billing_tp_site_tax_reg_num,jzvtd.billing_tp_tax_reg_num)
			,jzvtd.trx_number
			,jzvtd.trx_id
			,jzvtd.trx_date
			,DECODE(nvl2(apinv.cancelled_date,'Y','N'),'Y','CANCELLED',jzvtd.trx_line_class)
			,jzvtd.posted_flag
			,(CASE
				WHEN jzvtd.reporting_code = 'VAT-C' THEN 'C'
				WHEN jzvtd.reporting_code = 'VAT-P' THEN 'P'
				WHEN jzvtd.reporting_code = 'VAT-H' THEN 'H'
				ELSE 'T'
			  END)

		UNION ALL

		 -- VAT File Line Type - R
		 -- Reporting Code :
		 --       'VAT-RS'  - Other Trxs
		SELECT jzvtd.billing_tp_name vendor_name
			,jzvtd.billing_tp_number vendor_number
			,jzvtd.billing_tp_site_name site_name
			,NVL(jzvtd.billing_tp_site_tax_reg_num,jzvtd.billing_tp_tax_reg_num) tax_reg_num
			,jzvtd.trx_number inv_number
			,DECODE(length(nvl(apinvl.GLOBAL_ATTRIBUTE13,'A')),
                        1,jzvtd.trx_date,
                        19,TO_DATE(apinvl.GLOBAL_ATTRIBUTE13,'RRRR/MM/DD hh24:mi:ss'),
                        to_date(apinvl.GLOBAL_ATTRIBUTE13, 'DD-MM-RRRR')) inv_date
			,NVL(apinvl.GLOBAL_ATTRIBUTE14,apinv.invoice_num) import_document_number
			,apinvl.GLOBAL_ATTRIBUTE13 import_document_date
			,DECODE(nvl2(apinv.cancelled_date,'Y','N'),'Y','CANCELLED',jzvtd.trx_line_class) trx_line_class
			,jzvtd.posted_flag
			,JG_ZZ_COMMON_PKG.get_amt_tot(jzvtd.trx_id,l_ledger_id,G_PRECISION) invoice_amount
			,SUM(DECODE(jzvtd.reporting_code,'VAT-RA',DECODE(tax_recoverable_flag,'Y',nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt),0),0)) vat_on_fixed_assets
			,SUM(DECODE(jzvtd.reporting_code,'VAT-RS',DECODE(tax_recoverable_flag,'Y',nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt),0),0)) vat_on_other_trxs
			, 'R' class
			,0	mark_trx_flag
		FROM    jg_zz_vat_trx_details jzvtd
			,jg_zz_vat_rep_status  jzvrs
			,ap_invoices_all  apinv
			,ap_invoice_lines_all apinvl
			,zx_lines zxl
		WHERE   jzvrs.source='AP'
			AND     jzvrs.vat_reporting_entity_id       = P_VAT_REPORTING_ENTITY_ID
			AND     jzvrs.tax_calendar_period           = P_TAX_CALENDAR_PERIOD
			AND     JZVRS.REPORTING_STATUS_ID           = JZVTD.REPORTING_STATUS_ID
			AND     ( P_VAT_TRX_TYPE is null or jzvtd.tax_rate_vat_trx_type_code = P_VAT_TRX_TYPE)
			AND     jzvtd.reporting_code IN ('VAT-RS','VAT-RA')
			AND     apinv.invoice_id = jzvtd.trx_id
			AND     apinvl.invoice_id= jzvtd.trx_id
			AND     zxl.trx_id= jzvtd.trx_id
			AND     zxl.tax_line_id =jzvtd.tax_line_id
			AND     zxl.summary_tax_line_id = apinvl.summary_tax_line_id
		GROUP BY  jzvtd.billing_tp_name
			,jzvtd.billing_tp_number
			,jzvtd.billing_tp_site_name
			,NVL(jzvtd.billing_tp_site_tax_reg_num,jzvtd.billing_tp_tax_reg_num)
			,jzvtd.trx_number
			,jzvtd.trx_id
			,DECODE(length(nvl(apinvl.GLOBAL_ATTRIBUTE13,'A')),
                        1,jzvtd.trx_date,
                        19,TO_DATE(apinvl.GLOBAL_ATTRIBUTE13,'RRRR/MM/DD hh24:mi:ss'),
                        to_date(apinvl.GLOBAL_ATTRIBUTE13, 'DD-MM-RRRR'))
			,NVL(apinvl.GLOBAL_ATTRIBUTE14,apinv.invoice_num)
			,apinvl.GLOBAL_ATTRIBUTE13
			,DECODE(nvl2(apinv.cancelled_date,'Y','N'),'Y','CANCELLED',jzvtd.trx_line_class)
			,jzvtd.posted_flag

		UNION ALL
		 -- VAT File Line Type - K
		 -- Reporting Code :
		 --       'VAT-KS'  - Other Trxs
		 -- Transactions that are considered for the current period.
		SELECT jzvtd.billing_tp_name vendor_name
			,jzvtd.billing_tp_number vendor_number
			,jzvtd.billing_tp_site_name site_name
			,NVL(jzvtd.billing_tp_site_tax_reg_num,jzvtd.billing_tp_tax_reg_num) tax_reg_num
			,jzvtd.trx_number inv_number
			,jzvtd.trx_date inv_date
			,NULL  import_document_number
			,NULL  import_document_date
			,DECODE(nvl2(apinv.cancelled_date,'Y','N'),'Y','CANCELLED',jzvtd.trx_line_class) trx_line_class
			,jzvtd.posted_flag
			,JG_ZZ_COMMON_PKG.get_amt_tot(jzvtd.trx_id,l_ledger_id,G_PRECISION) invoice_amount
			,sum(DECODE(jzvtd.reporting_code,'VAT-KA',DECODE(tax_recoverable_flag,'Y', nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt), 0),0)) vat_on_fixed_assets
			,sum(DECODE(jzvtd.reporting_code,'VAT-KS',DECODE(tax_recoverable_flag,'Y', nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt), 0),0)) vat_on_other_trxs
			,'K' class
			,0	mark_trx_flag
		FROM    jg_zz_vat_trx_details jzvtd
			,jg_zz_vat_rep_status  jzvrs
			,ap_invoices_all  apinv
		WHERE   jzvrs.source='AP'
			AND     jzvrs.vat_reporting_entity_id       = P_VAT_REPORTING_ENTITY_ID
			AND		JZVTD.IL_VAT_REP_STATUS_ID			= l_rep_status_id
			-- AND     jzvrs.tax_calendar_period           = P_TAX_CALENDAR_PERIOD -- No period check
			AND     JZVRS.REPORTING_STATUS_ID           = JZVTD.REPORTING_STATUS_ID
			AND     jzvrs.period_end_date <= l_cur_period_end_date
			AND     (P_VAT_TRX_TYPE is null or jzvtd.tax_rate_vat_trx_type_code = P_VAT_TRX_TYPE)
			AND     jzvtd.reporting_code IN ('VAT-KS','VAT-KA')
			AND     apinv.invoice_id = jzvtd.trx_id
		GROUP BY  jzvtd.billing_tp_name
			,jzvtd.billing_tp_number
			,jzvtd.billing_tp_site_name
			,NVL(jzvtd.billing_tp_site_tax_reg_num,jzvtd.billing_tp_tax_reg_num)
			,jzvtd.trx_number
			,jzvtd.trx_id
			,jzvtd.trx_date
			,DECODE(nvl2(apinv.cancelled_date,'Y','N'),'Y','CANCELLED',jzvtd.trx_line_class)
			,jzvtd.posted_flag

		UNION ALL
		 -- VAT File Line Type - K
		 -- Reporting Code :
		 --       'VAT-KS'  - Other Trxs
		 -- Transactions that are not stamped for the subsequent period.
		SELECT jzvtd.billing_tp_name vendor_name
			,jzvtd.billing_tp_number vendor_number
			,jzvtd.billing_tp_site_name site_name
			,NVL(jzvtd.billing_tp_site_tax_reg_num,jzvtd.billing_tp_tax_reg_num) tax_reg_num
			,jzvtd.trx_number inv_number
			,jzvtd.trx_date inv_date
			,NULL  import_document_number
			,NULL  import_document_date
			,DECODE(nvl2(apinv.cancelled_date,'Y','N'),'Y','CANCELLED',jzvtd.trx_line_class) trx_line_class
			,jzvtd.posted_flag
			,JG_ZZ_COMMON_PKG.get_amt_tot(jzvtd.trx_id,l_ledger_id,G_PRECISION) invoice_amount
			,sum(DECODE(jzvtd.reporting_code,'VAT-KA',DECODE(tax_recoverable_flag,'Y', nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt), 0),0)) vat_on_fixed_assets
			,sum(DECODE(jzvtd.reporting_code,'VAT-KS',DECODE(tax_recoverable_flag,'Y', nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt), 0),0)) vat_on_other_trxs
			,'K' class
			,1	mark_trx_flag
		FROM    jg_zz_vat_trx_details jzvtd
			,jg_zz_vat_rep_status  jzvrs
			,ap_invoices_all  apinv
		WHERE   jzvrs.source='AP'
			AND     jzvrs.vat_reporting_entity_id       = P_VAT_REPORTING_ENTITY_ID
			--AND     jzvrs.tax_calendar_period         = P_TAX_CALENDAR_PERIOD  ( Other periods also possible)
			AND		JZVTD.IL_VAT_REP_STATUS_ID			= -999
			AND     jzvrs.period_end_date <= l_cur_period_end_date
			AND     JZVRS.REPORTING_STATUS_ID           = JZVTD.REPORTING_STATUS_ID
			AND     (P_VAT_TRX_TYPE is null or jzvtd.tax_rate_vat_trx_type_code = P_VAT_TRX_TYPE)
			AND     jzvtd.reporting_code IN ('VAT-KS','VAT-KA')
			AND     apinv.invoice_id = jzvtd.trx_id
		GROUP BY  jzvtd.billing_tp_name
			,jzvtd.billing_tp_number
			,jzvtd.billing_tp_site_name
			,NVL(jzvtd.billing_tp_site_tax_reg_num,jzvtd.billing_tp_tax_reg_num)
			,jzvtd.trx_number
			,jzvtd.trx_id
			,jzvtd.trx_date
			,DECODE(nvl2(apinv.cancelled_date,'Y','N'),'Y','CANCELLED',jzvtd.trx_line_class)
			,jzvtd.posted_flag
		ORDER BY vendor_name
			,vendor_number
			,site_name
			,class
			,inv_date
			,inv_number;

	-- Cursor for Israel VAT Non-Related to  835 File.
	CURSOR israel_details IS
	   SELECT jzvtd.billing_tp_name vendor_name
			  ,jzvtd.billing_tp_number vendor_number
			  ,jzvtd.billing_tp_site_name site_name
			  ,NVL(jzvtd.billing_tp_site_tax_reg_num,jzvtd.billing_tp_tax_reg_num) tax_reg_num
			  ,jzvtd.trx_number inv_number
				  ,jzvtd.trx_date inv_date
			  ,NULL  import_document_number
			  ,NULL  import_document_date
			  ,DECODE(nvl2(apinv.cancelled_date,'Y','N'),'Y','CANCELLED',jzvtd.trx_line_class) trx_line_class
			  ,jzvtd.posted_flag
			  -- Bug 7683525 ,SUM(Round(nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt),G_PRECISION) + DECODE(tax_recoverable_flag,'N',Round(nvl(jzvtd.taxable_amt_funcl_curr,jzvtd.taxable_amt),G_PRECISION),0)) invoice_amount
			  ,JG_ZZ_COMMON_PKG.get_amt_tot(jzvtd.trx_id,l_ledger_id,G_PRECISION) invoice_amount
			  ,sum(DECODE(tax_recoverable_flag,'Y',decode(jzvtd.reporting_code,'VAT-A',Round(nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt),G_PRECISION),0),0))  s_vat_on_fixed_assets
			  ,0 p_vat_on_fixed_assets
			  ,0 i_vat_on_fixed_assets
			  ,sum(DECODE(tax_recoverable_flag,'Y',decode(jzvtd.reporting_code,'VAT-S',Round(nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt),G_PRECISION),0),0))  s_vat_on_other_trx
			  ,0 p_vat_on_other_trx
			  ,0 i_vat_on_other_trx
			  ,sum(DECODE(tax_recoverable_flag,'Y',decode(jzvtd.reporting_code,'VAT-A',Round(nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt),G_PRECISION),0),0)) vat_fixed_assets
			  ,sum(DECODE(tax_recoverable_flag,'Y',decode(jzvtd.reporting_code,'VAT-S',Round(nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt),G_PRECISION),0),0)) vat_other_trx
			  ,'S' class
		FROM    jg_zz_vat_trx_details jzvtd
			   ,jg_zz_vat_rep_status  jzvrs
			   ,ap_invoices_all  apinv
		WHERE   jzvrs.source='AP'
		AND     jzvrs.vat_reporting_entity_id       = P_VAT_REPORTING_ENTITY_ID
		AND     jzvrs.tax_calendar_period           = P_TAX_CALENDAR_PERIOD
		AND     JZVRS.REPORTING_STATUS_ID           = JZVTD.REPORTING_STATUS_ID
		--AND     jzvtd.tax_rate_register_type_code   = 'TAX'
		AND     ( P_VAT_TRX_TYPE is null or jzvtd.tax_rate_vat_trx_type_code = P_VAT_TRX_TYPE)
		AND     jzvtd.reporting_code IN ('VAT-A','VAT-S')
		AND     apinv.invoice_id = jzvtd.trx_id
	   GROUP BY  jzvtd.billing_tp_name
				,jzvtd.billing_tp_number
				,jzvtd.billing_tp_site_name
				,NVL(jzvtd.billing_tp_site_tax_reg_num,jzvtd.billing_tp_tax_reg_num)
				,jzvtd.trx_number
				,jzvtd.trx_id
				,jzvtd.trx_date
				,DECODE(nvl2(apinv.cancelled_date,'Y','N'),'Y','CANCELLED',jzvtd.trx_line_class)
				,jzvtd.posted_flag

		UNION ALL

		SELECT jzvtd.billing_tp_name vendor_name
			  ,jzvtd.billing_tp_number vendor_number
			  ,jzvtd.billing_tp_site_name site_name
			  ,NVL(jzvtd.billing_tp_site_tax_reg_num,jzvtd.billing_tp_tax_reg_num) tax_reg_num
				  ,jzvtd.trx_number inv_number
				  ,jzvtd.trx_date inv_date
			  ,NULL import_document_number
			  ,NULL  import_document_date
			  ,DECODE(nvl2(apinv.cancelled_date,'Y','N'),'Y','CANCELLED',jzvtd.trx_line_class) trx_line_class
			  ,jzvtd.posted_flag
			  -- Bug 7683525 ,SUM(Round(nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt),G_PRECISION) + DECODE(tax_recoverable_flag,'N',Round(nvl(jzvtd.taxable_amt_funcl_curr,jzvtd.taxable_amt),G_PRECISION),0)) invoice_amount
			  ,JG_ZZ_COMMON_PKG.get_amt_tot(jzvtd.trx_id,l_ledger_id,G_PRECISION) invoice_amount
			  ,0  s_vat_on_fixed_assets
			  ,sum(DECODE(tax_recoverable_flag,'Y',decode(jzvtd.reporting_code,'VAT-KA',Round(nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt),G_PRECISION),0),0)) p_vat_on_fixed_assets
			  ,0 i_vat_on_fixed_assets
			  ,0  s_vat_on_other_trx
			  ,sum(DECODE(tax_recoverable_flag,'Y',decode(jzvtd.reporting_code,'VAT-KS',Round(nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt),G_PRECISION),0),0)) p_vat_on_other_trx
			  ,0 i_vat_on_other_trx
			  ,sum(DECODE(tax_recoverable_flag,'Y',decode(jzvtd.reporting_code,
											'VAT-KA',Round(nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt),G_PRECISION),0),0)) vat_fixed_assets
			  ,sum(DECODE(tax_recoverable_flag,'Y',decode(jzvtd.reporting_code,
											'VAT-KS',Round(nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt),G_PRECISION),0),0)) vat_other_trx
			  ,'P' class
		FROM    jg_zz_vat_trx_details jzvtd
			   ,jg_zz_vat_rep_status  jzvrs
			   ,ap_invoices_all  apinv
		WHERE   jzvrs.source='AP'
		AND     jzvrs.vat_reporting_entity_id       = P_VAT_REPORTING_ENTITY_ID
		AND     jzvrs.tax_calendar_period           = P_TAX_CALENDAR_PERIOD
		AND     JZVRS.REPORTING_STATUS_ID           = JZVTD.REPORTING_STATUS_ID
		--AND     jzvtd.tax_rate_register_type_code   = 'TAX'
		AND     ( P_VAT_TRX_TYPE is null or jzvtd.tax_rate_vat_trx_type_code = P_VAT_TRX_TYPE)
		AND     jzvtd.reporting_code IN ('VAT-KA','VAT-KS')
		AND     apinv.invoice_id = jzvtd.trx_id
	   GROUP BY  jzvtd.billing_tp_name
				,jzvtd.billing_tp_number
				,jzvtd.billing_tp_site_name
				,NVL(jzvtd.billing_tp_site_tax_reg_num,jzvtd.billing_tp_tax_reg_num)
				,jzvtd.trx_number
				,jzvtd.trx_id
				,jzvtd.trx_date
			 --   ,jzvtd.import_document_number
			 --   ,jzvtd.import_document_date
				,DECODE(nvl2(apinv.cancelled_date,'Y','N'),'Y','CANCELLED',jzvtd.trx_line_class)
				,jzvtd.posted_flag

	UNION ALL

		SELECT jzvtd.billing_tp_name vendor_name
			  ,jzvtd.billing_tp_number vendor_number
			  ,jzvtd.billing_tp_site_name site_name
			  ,NVL(jzvtd.billing_tp_site_tax_reg_num,jzvtd.billing_tp_tax_reg_num) tax_reg_num
				   ,jzvtd.trx_number inv_number
				  ,DECODE(length(nvl(apinvl.GLOBAL_ATTRIBUTE13,'A')),
							1,jzvtd.trx_date,
							19,TO_DATE(apinvl.GLOBAL_ATTRIBUTE13,'RRRR/MM/DD hh24:mi:ss'),
							to_date(apinvl.GLOBAL_ATTRIBUTE13, 'DD-MM-RRRR')) inv_date
			  ,NVL(apinvl.GLOBAL_ATTRIBUTE14,apinv.invoice_num) import_document_number
			  ,apinvl.GLOBAL_ATTRIBUTE13 import_document_date
			  ,DECODE(nvl2(apinv.cancelled_date,'Y','N'),'Y','CANCELLED',jzvtd.trx_line_class) trx_line_class
			  ,jzvtd.posted_flag
			  -- Bug 7683525 ,SUM(Round(nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt),G_PRECISION) + DECODE(tax_recoverable_flag,'N',Round(nvl(jzvtd.taxable_amt_funcl_curr,jzvtd.taxable_amt),G_PRECISION),0)) invoice_amount
			  ,JG_ZZ_COMMON_PKG.get_amt_tot(jzvtd.trx_id,l_ledger_id,G_PRECISION) invoice_amount
			  ,0 s_vat_on_fixed_assets
			  ,0 p_vat_on_fixed_assets
			  ,sum(DECODE(tax_recoverable_flag,'Y',decode(jzvtd.reporting_code,'VAT-RA',Round(nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt),G_PRECISION),0),0)) i_vat_on_fixed_assets
			  ,0  s_vat_on_other_trx
			  ,0 p_vat_on_other_trx
			  ,sum(DECODE(tax_recoverable_flag,'Y',decode(jzvtd.reporting_code,'VAT-RS',Round(nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt),G_PRECISION),0),0)) i_vat_on_other_trx
			  ,sum(DECODE(tax_recoverable_flag,'Y',decode(jzvtd.reporting_code,
											'VAT-RA',Round(nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt),G_PRECISION),0),0)) vat_fixed_assets
			  ,sum(DECODE(tax_recoverable_flag,'Y',decode(jzvtd.reporting_code,
											'VAT-RS',Round(nvl(jzvtd.tax_amt_funcl_curr,jzvtd.tax_amt),G_PRECISION),0),0)) vat_other_trx
			  , 'I' class
		FROM    jg_zz_vat_trx_details jzvtd
			   ,jg_zz_vat_rep_status  jzvrs
			   ,ap_invoices_all  apinv
			   ,ap_invoice_lines_all apinvl
			   ,zx_lines zxl
		WHERE   jzvrs.source='AP'
		AND     jzvrs.vat_reporting_entity_id       = P_VAT_REPORTING_ENTITY_ID
		AND     jzvrs.tax_calendar_period           = P_TAX_CALENDAR_PERIOD
		AND     JZVRS.REPORTING_STATUS_ID           = JZVTD.REPORTING_STATUS_ID
		-- AND     jzvtd.tax_rate_register_type_code   = 'TAX'
		AND     ( P_VAT_TRX_TYPE is null or jzvtd.tax_rate_vat_trx_type_code = P_VAT_TRX_TYPE)
		AND     jzvtd.reporting_code IN ('VAT-RA','VAT-RS')
		AND     apinv.invoice_id = jzvtd.trx_id
		AND     apinvl.invoice_id= jzvtd.trx_id
		AND     zxl.trx_id= jzvtd.trx_id
		AND     zxl.tax_line_id =jzvtd.tax_line_id
		AND     zxl.summary_tax_line_id = apinvl.summary_tax_line_id
	   -- AND     apinvl.line_type_lookup_code = 'TAX'
	   GROUP BY  jzvtd.billing_tp_name
				,jzvtd.billing_tp_number
				,jzvtd.billing_tp_site_name
				,NVL(jzvtd.billing_tp_site_tax_reg_num,jzvtd.billing_tp_tax_reg_num)
					,jzvtd.trx_number
					,jzvtd.trx_id
					,DECODE(length(nvl(apinvl.GLOBAL_ATTRIBUTE13,'A')),
						  1,jzvtd.trx_date,
						  19,TO_DATE(apinvl.GLOBAL_ATTRIBUTE13,'RRRR/MM/DD hh24:mi:ss'),
						  to_date(apinvl.GLOBAL_ATTRIBUTE13, 'DD-MM-RRRR'))
				,NVL(apinvl.GLOBAL_ATTRIBUTE14,apinv.invoice_num)
				,apinvl.GLOBAL_ATTRIBUTE13
				,DECODE(nvl2(apinv.cancelled_date,'Y','N'),'Y','CANCELLED',jzvtd.trx_line_class)
				,jzvtd.posted_flag;


    BEGIN

      p_where_clause := ' AND 1 = 1 ';

      if g_debug = true then fnd_file.put_line(fnd_file.log,'Calling JG_ZZ_COMMON_PKG.funct_curr_legal'); end if;
      JG_ZZ_COMMON_PKG.funct_curr_legal(l_curr_code
                                      ,l_rep_entity_name
                                      ,l_legal_entity_id
                                      ,l_taxpayer_id
                                      ,P_VAT_REPORTING_ENTITY_ID
                                      , pv_period_name => p_tax_calendar_period  /* UT TEST addition */
                                      );
      if g_debug = true then fnd_file.put_line(fnd_file.log,'Calling JG_ZZ_COMMON_PKG.company_detail'); end if;
      JG_ZZ_COMMON_PKG.company_detail(x_company_name     => l_company_name
                                    ,x_registration_number    =>l_registration_number
                                    ,x_country                => l_country
                                     ,x_address1               => l_address1
                                     ,x_address2               => l_address2
                                     ,x_address3               => l_address3
                                     ,x_address4               => l_address4
                                     ,x_city                   => l_city
                                     ,x_postal_code            => l_postal_code
                                     ,x_contact                => l_contact
                                     ,x_phone_number           => l_phone_number
                                     ,x_province               => l_province
                                     ,x_comm_number            => l_comm_num
                                     ,x_vat_reg_num            => l_vat_reg_num
                                     ,pn_legal_entity_id       => l_legal_entity_id
                                     ,p_vat_reporting_entity_id => P_VAT_REPORTING_ENTITY_ID);

      if g_debug = true then fnd_file.put_line(fnd_file.log,'Calling jg_zz_common_pkg.tax_registration'); end if;
      jg_zz_common_pkg.tax_registration(x_tax_registration     => l_tax_registration_num
                                          ,x_period_start_date    => l_period_start_date
                                          ,x_period_end_date      => l_period_end_date
                                          ,x_status               => l_reporting_status
                                          ,pn_vat_rep_entity_id   => p_vat_reporting_entity_id
                                          ,pv_period_name         => p_tax_calendar_period
                                          ,pv_source              => 'AP');

    l_reporting_status := JG_ZZ_VAT_REP_UTILITY.get_period_status(pn_vat_reporting_entity_id => p_vat_reporting_entity_id
								 ,pv_tax_calendar_period => p_tax_calendar_period
								 ,pv_tax_calendar_year => null
								 ,pv_source => NULL
							         ,pv_report_name => p_calling_report);

	-- Bug 8285537. Exception handled
	BEGIN
		select distinct nvl(jzvre.ledger_id,0)
					  , jzvre.entity_type_code
		into l_ledger_id,l_entity_type_code
		from jg_zz_vat_rep_entities jzvre
		where jzvre.vat_reporting_entity_id = P_VAT_REPORTING_ENTITY_ID;
	EXCEPTION
	WHEN OTHERS THEN
		l_ledger_id := 0;
		l_entity_type_code := 'NO_ENTITY_TYPE_CODE';
	END;
	-- Bug 8285537. Exception handled
	BEGIN
		select DISTINCT ledger_category_code
		into l_ledger_category_code
		from gl_ledgers
		where ledger_id = l_ledger_id;
	EXCEPTION
	WHEN OTHERS THEN
		l_ledger_category_code := 'NO_CATEGORY_CODE';
	END;

    IF ( l_entity_type_code = 'LEGAL' OR ( l_entity_type_code = 'ACCOUNTING' AND l_ledger_category_code = 'PRIMARY' ))
     THEN
      l_ledger_id := -1;
    END IF;

       INSERT INTO JG_ZZ_VAT_TRX_GT
                                     (jg_info_v1 -- curr_code
                                     ,jg_info_v2 -- entity_name
                                     ,jg_info_v3 -- taxpayer_id
                                     ,jg_info_v4 -- company_name
                                     ,jg_info_v5 -- registration_number
                                     ,jg_info_v6 -- country
                                     ,jg_info_v7 -- address1
                                     ,jg_info_v8 -- address2
                                     ,jg_info_v9 -- address3
                                     ,jg_info_v10 -- address4
                                     ,jg_info_v11 -- city
                                     ,jg_info_v12 -- postal_code
                                     ,jg_info_v13 -- contact
                                     ,jg_info_v14 -- phone_number
                                     ,jg_info_v30 -- Header record indicator
                                     ,jg_info_v15 --Tax Registration Number
                                     ,jg_info_d1 --Period start date
                                     ,jg_info_d2 --Period end date
                                     ,jg_info_v16 ) --Reporting Status
                               VALUES(
                                      l_curr_code
                                     ,l_company_name  ---l_rep_entity_name
                                     ,l_registration_number  --l_taxpayer_id
                                     ,l_company_name
                                     ,l_tax_registration_num
                                     ,l_country
                                     ,l_address1
                                     ,l_address2
                                     ,l_address3
                                     ,l_address4
                                     ,l_city
                                     ,l_postal_code
                                     ,l_contact
                                     ,l_phone_number
                                     ,'H'
                                     ,l_tax_registration_num
                                     ,l_period_start_date
                                     ,l_period_end_date
                                     ,l_reporting_status);
      if g_debug = true then fnd_file.put_line(fnd_file.log,'Inserted Company Details in JG_ZZ_VAT_TRX_GT table'); end if;

      IF P_CALLING_REPORT IS NOT NULL  THEN  --A1

        /* commented during UT TEST
        l_country_code := jg_zz_shared_pkg.GET_COUNTRY(mo_global.get_current_org_id);
        */
        -- Populate data for the other two sections

        /* added during UT */
        l_country_code := jg_zz_shared_pkg.GET_COUNTRY;
        if l_country_code is null then
          l_country_code := jg_zz_shared_pkg.GET_COUNTRY(mo_global.get_current_org_id);
        end if;

        if g_debug = true then fnd_file.put_line(fnd_file.log, 'l_country_code:'||l_country_code); end if;

        IF P_VAT_TRX_TYPE IS NOT NULL THEN
          BEGIN
            FOR c_lookup_type IN c_get_lookup_values(P_VAT_TRX_TYPE)
            LOOP
              G_VAT_TRX_TYPE_MEANING := c_lookup_type.meaning;
              G_VAT_TRX_TYPE_DESC := c_lookup_type.description;
            END LOOP;
          EXCEPTION
            WHEN OTHERS THEN
              if g_debug = true then fnd_file.put_line(fnd_file.log,' Failed while extracting the transaction type meaning. Error : ' || SUBSTR(SQLERRM,1,200)); end if;
          END;
        END IF;

        IF P_EX_VAT_TRX_TYPE IS NOT NULL THEN
          BEGIN
            FOR c_lookup_type_ex IN c_get_lookup_values(P_EX_VAT_TRX_TYPE)
            LOOP
              G_EX_VAT_TRX_TYPE_MEANING := c_lookup_type_ex.meaning;
              G_EX_VAT_TRX_TYPE_DESC := c_lookup_type_ex.description;
            END LOOP;
          EXCEPTION
            WHEN OTHERS THEN
              if g_debug = true then fnd_file.put_line(fnd_file.log,' Failed while extracting the exclude transaction type meaning. Error : ' || SUBSTR(SQLERRM,1,200)); end if;
          END;

        END IF;

        BEGIN

          FOR c_company IN c_company_details
          LOOP
            G_COMPANY_NAME := c_company.Company_Name;
            G_FUNCTIONAL_CURRENCY := c_company.FUNCTIONAL_CURRENCY_CODE;
          END LOOP;

        EXCEPTION
          WHEN OTHERS THEN
            if g_debug = true then fnd_file.put_line(fnd_file.log,' Failed while extracting the company name and the functional currency code. Error : ' || SUBSTR(SQLERRM,1,200)); end if;
        END;

      /* Get Currency Precision */

 	     BEGIN
 	          FND_FILE.PUT_LINE(FND_FILE.LOG,'Functional Currency Code :'||G_FUNCTIONAL_CURRENCY);

 	           SELECT  precision
 	             INTO  G_PRECISION
 	           FROM    fnd_currencies
 	           WHERE   currency_code = G_FUNCTIONAL_CURRENCY;

 	          FND_FILE.PUT_LINE(FND_FILE.LOG,'Functional Currency Precision :'||G_PRECISION);

 	      EXCEPTION
 	         WHEN OTHERS THEN
 	           FND_FILE.PUT_LINE(FND_FILE.LOG,'error in getting currency precision');
 	     END;

-- Begin of code for Israeli reports

        --Populated the data for VAT AP Detail Report
        IF ( P_CALLING_REPORT = 'JEILAPVR') THEN
        if g_debug = true then
			fnd_file.put_line(fnd_file.log,'Israeli VAT AP Detail Register Report concurrent is submitted');
		end if;

		 -- IL VAT Reporting 2010 ER  - Logic Changes

				-- Get the limits defined for the tax period.
				FOR cur_get_limits IN il_get_limits
				LOOP
					l_percentage	:=	cur_get_limits.max_recoverable_percentage;
					l_max_rec_amt	:=	cur_get_limits.max_recoverable_amt;
					l_min_rec_amt	:=	cur_get_limits.min_recoverable_amt;
					l_calendar_name	:=	cur_get_limits.period_set_name;
				END LOOP;

				IF l_calendar_name IS NULL THEN
					fnd_file.put_line(fnd_file.log,'Please declare the VAT limits for the tax period '||p_tax_calendar_period||' for calendar in the Israel VAT Limits Setup form.');
					raise_application_error(-20010,'Please declare the VAT limits for the tax period '||p_tax_calendar_period||' for calendar in the Israel VAT Limits Setup form.');
				END IF;
				if g_debug = true then
					fnd_file.put_line(fnd_file.log,'Percentage =' || TO_CHAR(l_percentage));
					fnd_file.put_line(fnd_file.log,'Max. Rec. Amount =' || TO_CHAR(l_max_rec_amt));
					fnd_file.put_line(fnd_file.log,'Min. Rec. Amount =' || TO_CHAR(l_min_rec_amt));
					fnd_file.put_line(fnd_file.log,'Tax Calendar Name =' || l_calendar_name);
				end if;

				-- Get the reporting status id
				FOR cur_get_rep_status_id IN il_get_rep_status_id
				LOOP
					l_rep_status_id		:= cur_get_rep_status_id.reporting_status_id;
					l_cur_period_end_date 	:= cur_get_rep_status_id.period_end_date;
				END LOOP;

				if g_debug = true then
					fnd_file.put_line(fnd_file.log,'Current Reporting Status ID = ' || TO_CHAR(l_rep_status_id));
				end if;

				IF l_rep_status_id IS NULL THEN
					RETURN (FALSE);
				END IF;

				-- If Percentage is defined then calculate the max_rec_amt.
				IF l_percentage IS NOT NULL THEN
					-- Get the total vat amt for the declared tax period. SUM('VAT-A','VAT-S',
					--  'VAT-C', 'VAT-RA', 'VAT-P', 'VAT-H')
					FOR cur_get_total_vat_amt IN il_get_total_vat_amt
					LOOP
						l_total_vat_amt	:=	cur_get_total_vat_amt.TOTAL_VAT_AMT;
					END LOOP;
					if g_debug = true then
						fnd_file.put_line(fnd_file.log,'Total VAT Amount = ' || TO_CHAR(l_total_vat_amt));
					end if;
					-- Find the Maximum Recoverable Amount from Percentage.
					l_max_rec_amt := NVL(l_total_vat_amt,0) * l_percentage / 100;
					if g_debug = true then
						fnd_file.put_line(fnd_file.log,'Max Recoverable Amount:'||to_char(l_max_rec_amt));
					end if;
				END IF;

				IF l_max_rec_amt IS NULL OR l_min_rec_amt IS NULL THEN
					fnd_file.put_line(fnd_file.log,'Please declare the Minimum and/or Maximum Recoverable Amount limits for the tax period in the Israel VAT Limits Setup form.');
					raise_application_error(-20010,'Please declare the Minimum and/or Maximum Recoverable Amount limits for the tax period in the Israel VAT Limits Setup form.');
					RETURN (FALSE);
				END IF;

				-- Get the total petty cash vat amt for the declared tax period. SUM (VAT-KS)
				FOR cur_get_petty_cash_vat_amt IN il_get_petty_cash_vat_amt
				LOOP
					l_petty_cash_vat_amt	:=	cur_get_petty_cash_vat_amt.TOTAL_PETTY_CASH_VAT_AMT;
				END LOOP;
				if g_debug = true then
					fnd_file.put_line(fnd_file.log,'Total PETTY CASH Amount = ' || TO_CHAR(l_petty_cash_vat_amt));
				end if;

				-- Find the Final VAT Amount
				IF l_max_rec_amt > l_min_rec_amt THEN
					IF l_petty_cash_vat_amt > l_max_rec_amt THEN
						l_declared_amount := l_max_rec_amt;
					ELSE
						l_declared_amount := l_petty_cash_vat_amt;
					END IF;
				ELSE
					IF l_petty_cash_vat_amt > l_min_rec_amt THEN
						l_declared_amount := l_min_rec_amt;
					ELSE
						l_declared_amount := l_petty_cash_vat_amt;
					END IF;
				END IF;

				if g_debug = true then
					fnd_file.put_line(fnd_file.log,'Declared Amount = ' || TO_CHAR(l_declared_amount));
				end if;

				-- Compare the petty cash trxs vat amt with limits.
				FOR cur_get_petty_cash_trxs IN il_get_petty_cash_trxs
				LOOP

					l_cum_total_amt	:= cur_get_petty_cash_trxs.cum_total_amt;

					IF l_cum_total_amt <= l_declared_amount THEN
						rep_status_id_rec_tab(l_count) := cur_get_petty_cash_trxs.reporting_status_id;
						trx_number_rec_tab(l_count) := cur_get_petty_cash_trxs.trx_number;
						trx_date_rec_tab(l_count) := cur_get_petty_cash_trxs.trx_date;
						il_rep_status_rec_tab(l_count) := l_rep_status_id;
					ELSE
						rep_status_id_rec_tab(l_count) := cur_get_petty_cash_trxs.reporting_status_id;
						trx_number_rec_tab(l_count) := cur_get_petty_cash_trxs.trx_number;
						trx_date_rec_tab(l_count) := cur_get_petty_cash_trxs.trx_date;
						il_rep_status_rec_tab(l_count) := -999;
					END IF;
					l_count := l_count + 1;
				END LOOP;

				-- Stamp the petty cash transactions. Update the IL_REP_STATUS_ID column in JG_ZZ_VAT_TRX_DETAILS table.
				IF l_count > 1 THEN
					BEGIN
						FORALL i_index IN 1 .. l_count-1
							UPDATE JG_ZZ_VAT_TRX_DETAILS
							SET IL_VAT_REP_STATUS_ID = il_rep_status_rec_tab(i_index)
							WHERE REPORTING_STATUS_ID = rep_status_id_rec_tab(i_index)
							AND TRX_NUMBER = trx_number_rec_tab(i_index)
							AND TRX_DATE = trx_date_rec_tab(i_index);
					EXCEPTION
						WHEN OTHERS THEN
						if g_debug = true then
							fnd_file.put_line(fnd_file.log,' Failed while Updating IL_VAT_REP_STATUS_ID column in JG_ZZ_VAT_TRX_DETAILS table. Error : ' || SUBSTR(SQLERRM,1,200));
						end if;
						RETURN (FALSE);
					END;
					if g_debug = true then
						fnd_file.put_line(fnd_file.log,'Stamped IL_VAT_REP_STATUS_ID column for petty cash trxs');
					end if;
				END IF;

		 -- IL VAT Reporting 2010 ER  - Logic Changes

        BEGIN
		-- IL VAT Reporting 2010 ER  - Logic Changes
        --Populated the data for Israel VAT AP Detail Report.
		FOR cur_israel_new_details IN israel_new_details
		LOOP

		INSERT INTO JG_ZZ_VAT_TRX_GT
		(jg_info_v1 ,   --vendor_name
		 jg_info_v6 ,   --Vendor Number
		 jg_info_v2 ,   --SITE_NAME
		 jg_info_v10 ,  --TAX_REG_NUM
		 jg_info_v11 ,  --INV_NUMBER
		 jg_info_d1 ,   --INV_DATE
		 jg_info_v12 ,  --IMPORT_DOCUMENT_NUMBER
		 jg_info_v3 ,   --TRX_LINE_CLASS
		 jg_info_v4 ,   --POSTED_FLAG
		 jg_info_n5 ,   --INVOICE_AMOUNT
		 jg_info_n12 ,  --VAT_ON_FIXED_ASSETS
		 jg_info_n13 ,  --VAT_ON_OTHER_TRXS
		 jg_info_v5  ,  --CLASS
		 jg_info_n1     --MARK_TRX_FLAG
		 )
		VALUES(
		 cur_israel_new_details.vendor_name
		,cur_israel_new_details.vendor_number
		,cur_israel_new_details.site_name
		,cur_israel_new_details.tax_reg_num
		,cur_israel_new_details.inv_number
		,cur_israel_new_details.inv_date
		,cur_israel_new_details.import_document_number
		,cur_israel_new_details.trx_line_class
		,cur_israel_new_details.posted_flag
		,cur_israel_new_details.invoice_amount
		,cur_israel_new_details.vat_on_fixed_assets
		,cur_israel_new_details.vat_on_other_trxs
		,cur_israel_new_details.class
		,cur_israel_new_details.mark_trx_flag);
		END LOOP;
        EXCEPTION
          WHEN OTHERS THEN
              if g_debug = true then fnd_file.put_line(fnd_file.log,' Failed while Inserting the ISRAEL data into GTT. Error : ' || SUBSTR(SQLERRM,1,200)); end if;
			  RETURN (FALSE);
        END;

	-- Code for Israel VAT Non-related to 835 report

	ELSIF  P_CALLING_REPORT = 'JEILN835' THEN

       if g_debug = true then
		fnd_file.put_line(fnd_file.log,'Israeli VAT-File Not Related 835 Report concurrent is submitted');
	   end if;

	    BEGIN
 		  --Populated the data for VAT-File Not Related 835 -Israel
            FOR israel_inv_lines IN israel_details
            LOOP

            INSERT INTO JG_ZZ_VAT_TRX_GT
            (jg_info_v1 ,  --vendor_name
            -- jg_info_n1 ,  --vendor_number
             jg_info_v6 ,   --Vendor Number
             jg_info_v2 ,  --SITE_NAME
             jg_info_v10 ,  --TAX_REG_NUM  /* UT TEST   jg_info_n2 => jg_info_v10*/
             jg_info_v11 ,  --INV_NUMBER   /* UT TEST   jg_info_n3 => jg_info_v11*/
             jg_info_d1 ,  --INV_DATE
             jg_info_v12 ,  --IMPORT_DOCUMENT_NUMBER  /* UT TEST    jg_info_n4 => jg_info_v12*/
             jg_info_d2 ,  --IMPORT_DOCUMENT_DATE
             jg_info_v3 ,  --TRX_LINE_CLASS
             jg_info_v4 ,  --POSTED_FLAG
             jg_info_n5 ,  --INVOICE_AMOUNT
             jg_info_n6 ,  --S_VAT_ON_FIXED_ASSETS
             jg_info_n7 ,  --P_VAT_ON_FIXED_ASSETS
             jg_info_n8 ,  --I_VAT_ON_FIXED_ASSETS
             jg_info_n9 ,  --S_VAT_ON_OTHER_TRX
             jg_info_n10 , --P_VAT_ON_OTHER_TRX
             jg_info_n11 , --I_VAT_ON_OTHER_TRX
             jg_info_n12 , --VAT_FIXED_ASSETS
             jg_info_n13 , --VAT_OTHER_TRX
             jg_info_v5    --CLASS
             )
            VALUES(
             israel_inv_lines.vendor_name
            ,israel_inv_lines.vendor_number
            ,israel_inv_lines.site_name
            ,israel_inv_lines.tax_reg_num
            ,israel_inv_lines.inv_number
            ,israel_inv_lines.inv_date
            ,israel_inv_lines.import_document_number
            ,israel_inv_lines.import_document_date
            ,israel_inv_lines.trx_line_class
            ,israel_inv_lines.posted_flag
            ,israel_inv_lines.invoice_amount
            ,israel_inv_lines.s_vat_on_fixed_assets
            ,israel_inv_lines.p_vat_on_fixed_assets
            ,israel_inv_lines.i_vat_on_fixed_assets
            ,israel_inv_lines.s_vat_on_other_trx
            ,israel_inv_lines.p_vat_on_other_trx
            ,israel_inv_lines.i_vat_on_other_trx
            ,israel_inv_lines.vat_fixed_assets
            ,israel_inv_lines.vat_other_trx
            ,israel_inv_lines.class);
          END LOOP;
        EXCEPTION
          WHEN OTHERS THEN
              if g_debug = true then fnd_file.put_line(fnd_file.log,' Failed while Inserting the ISRAEL data into GTT. Error : ' || SUBSTR(SQLERRM,1,200)); end if;
        END;
-- End of code for Israeli reports

-- Begin of code for ECE and Crotia reports.

      ELSE  -- i.e P_CALLING_REPORT <> 'JEILAPVR' and JEILN835

        BEGIN
          FOR c_data_rec1 IN c_new
          LOOP

            FOR c_vat_offset IN c_vat_or_offset (c_data_rec1.tax_rate_code)
            LOOP
              l_vat_or_offset := c_vat_offset.vat_or_offset;
            END LOOP;

            l_unpaid_amount := unpaid_amt(pn_inv_id                =>  c_data_rec1.trx_id
                                         ,pn_inv_amount            =>  c_data_rec1.total_accounted_amount
                                         ,pn_taxable_amount        =>  c_data_rec1.taxable_amount
                                         ,pv_offset_tax_code       =>  c_data_rec1.OFFSET_TAX_RATE_CODE
                                         ,pd_end_date              =>  c_data_rec1.PERIOD_END_DATE);


            INSERT INTO JG_ZZ_VAT_TRX_GT
              (jg_info_n1 -- seq_number
              ,jg_info_v1 -- inv_number
              ,jg_info_v2 -- customer_name
              ,jg_info_d1 -- tax_date
              ,jg_info_d2 -- inv_date
              ,jg_info_d3 -- accounting_date
              ,jg_info_v3 -- tax_code_description
              ,jg_info_n2 -- taxable_amount
              ,jg_info_n3 -- tax_rate
              ,jg_info_n4 -- tax_amount
              ,jg_info_n5 -- trx_id , invoice_id
              ,jg_info_v4 -- trx_class_code
              ,jg_info_v5 -- trx_currency_code
              ,jg_info_n6 -- Recoverable Tax
              ,jg_info_n7 -- Non-Recoverable Tax
              ,jg_info_v6 -- Tax Code Description
              ,jg_info_n8 -- Functional Amount
              ,jg_info_n10 -- Transaction Amount
              ,jg_info_n13 -- Transaction Amount Offset
              ,jg_info_v9 -- Rec flag
              ,jg_info_v10 -- Doc Sequence Name
              ,jg_info_v11 -- tax_reg_num
              ,jg_info_v12 -- tax_code_vat_trx_type_code
              ,jg_info_v13 -- TAX_CODE_VAT_TRX_TYPE_MEANING
              ,jg_info_v14 -- TAX_CODE
              ,jg_info_v7 --  TAX_RATE_VAT_TRX_TYPE_CODE
              ,jg_info_n12
              ,jg_info_v15 -- Reporting_Code
              ,jg_info_n15 -- Pure VAT or VAT with Offset derived in the variable l_vat_or_offset
              ,jg_info_v16 -- period_name
              ,jg_info_v17 -- offset_flag
              ,jg_info_v18 -- offset_tax_rate_code
              ,jg_info_v19 -- CHK_VAT_AMOUNT_PAID
              ,jg_info_n14 -- non_recoverable_unpaid amount
               )
            VALUES
              (c_data_rec1.seq_number
              ,c_data_rec1.inv_number
              ,c_data_rec1.customer_name
              ,c_data_rec1.tax_date
              ,c_data_rec1.inv_date
              ,c_data_rec1.gl_date
              ,c_data_rec1.tax_rate_code_description
              ,c_data_rec1.taxable_amount
              ,c_data_rec1.tax_rate
              ,c_data_rec1.tax_amount
              ,c_data_rec1.trx_id
              ,c_data_rec1.trx_line_class
              ,c_data_rec1.trx_currency_code
              ,c_data_rec1.recoverable
              ,c_data_rec1.non_recoverable
              ,c_data_rec1.tax_rate_code_description
              ,c_data_rec1.total_accounted_amount
              ,c_data_rec1.total_entered_amount
              ,c_data_rec1.taxable_entered_amount
              ,'M'
              ,c_data_rec1.doc_seq_name
              ,c_data_rec1.tax_reg_num
              ,c_data_rec1.tax_rate_vat_trx_type_desc
              ,c_data_rec1.tax_rate_code_vat_trx_type_mng
              ,c_data_rec1.tax_rate_code
              ,c_data_rec1.tax_rate_vat_trx_type_code
              ,decode(NVL(c_data_rec1.chk_vat_amount_paid, 'N'), 'N', 0, 1)
              ,c_data_rec1.reporting_code
              ,l_vat_or_offset
              ,c_data_rec1.gl_period
              ,c_data_rec1.offset_flag
              ,c_data_rec1.offset_tax_rate_code
              ,c_data_rec1.chk_vat_amount_paid
              ,l_unpaid_amount);

          END LOOP;
        EXCEPTION
          WHEN OTHERS THEN
          if g_debug = true then fnd_file.put_line(fnd_file.log,' Failed while populating the data into the global tmp table for c_new. Error : ' || SUBSTR(SQLERRM,1,200)); end if;
        END;

        -- Populate data for the Summary by GL period
        BEGIN
          FOR c_data_rec IN c_data
          LOOP

            l_unpaid_amount := unpaid_amt(pn_inv_id                =>  c_data_rec.trx_id
                                         ,pn_inv_amount            =>  c_data_rec.total_accounted_amount
                                         ,pn_taxable_amount        =>  c_data_rec.taxable_amount
                                         ,pv_offset_tax_code       =>  c_data_rec.OFFSET_TAX_RATE_CODE
                                         ,pd_end_date              =>  c_data_rec.PERIOD_END_DATE);

            INSERT INTO JG_ZZ_VAT_TRX_GT
              (jg_info_n1 -- seq_number
              ,jg_info_v1 -- inv_number
              ,jg_info_v2 -- customer_name
              ,jg_info_d1 -- tax_date
              ,jg_info_d2 -- inv_date
              ,jg_info_d3 -- accounting_date
              ,jg_info_v3 -- tax_code_description
              ,jg_info_n2 -- taxable_amount
              ,jg_info_n3 -- tax_rate
              ,jg_info_n4 -- tax_amount
              ,jg_info_n5 -- trx_id
              ,jg_info_v4 -- trx_class_code
              ,jg_info_v5 -- trx_currency_code
              ,jg_info_n6 -- Recoverable Tax
              ,jg_info_n7 -- Non-Recoverable Tax
              ,jg_info_v6 -- Tax Code Description
              ,jg_info_n8 -- Functional Amount
              ,jg_info_n10 -- Transaction Amount
              ,jg_info_n13 -- Transaction Amount Offset
              ,jg_info_v9 -- Rec flag
              ,jg_info_v8 -- ACCOUNT FLEXFIELD
              ,jg_info_v10 -- Doc Sequence Name
              ,jg_info_v11 -- tax_reg_num
              ,jg_info_v12 -- tax_rate_vat_trx_type_desc
              ,jg_info_v13 -- tax_rate_code_vat_trx_type_mng
              ,jg_info_v14 -- TAX_RATE_CODE
              ,jg_info_v7 -- TAX_CODE_VAT_TRX_TYPE_CODE
              ,jg_info_n12
              ,jg_info_v15 -- REPORTING_CODE
              ,jg_info_v16 -- period_name
              ,jg_info_v17 -- offset_flag
              ,jg_info_v18 -- offset_tax_rate_code
              ,jg_info_v19 -- CHK_VAT_AMOUNT_PAID
              ,jg_info_n14 -- non_recoverable_unpaid amount
               )
            VALUES
              (c_data_rec.seq_number
              ,c_data_rec.inv_number
              ,c_data_rec.customer_name
              ,c_data_rec.tax_date
              ,c_data_rec.inv_date
              ,c_data_rec.gl_date
              ,c_data_rec.tax_rate_code_description
              ,c_data_rec.taxable_amount
              ,c_data_rec.tax_rate
              ,c_data_rec.tax_amount
              ,c_data_rec.trx_id
              ,c_data_rec.trx_line_class
              ,c_data_rec.trx_currency_code
              ,c_data_rec.recoverable
              ,c_data_rec.non_recoverable
              ,c_data_rec.tax_rate_code_description
              ,c_data_rec.total_accounted_amount
              ,c_data_rec.total_entered_amount
              ,c_data_rec.taxable_entered_amount
              ,'S'
              ,c_data_rec.account_flexfield
              ,c_data_rec.doc_seq_name
              ,c_data_rec.tax_reg_num
              ,c_data_rec.tax_rate_vat_trx_type_desc
              ,c_data_rec.tax_rate_code_vat_trx_type_mng
              ,c_data_rec.tax_rate_code
              ,c_data_rec.tax_rate_vat_trx_type_code
              ,decode(NVL(c_data_rec.chk_vat_amount_paid, 'N'), 'N', 0, 1)
              ,c_data_rec.reporting_code
              ,c_data_rec.gl_period
              ,c_data_rec.offset_flag
              ,c_data_rec.offset_tax_rate_code
              ,c_data_rec.chk_vat_amount_paid
              ,l_unpaid_amount);

          END LOOP;
        EXCEPTION
          WHEN OTHERS THEN
            if g_debug = true then fnd_file.put_line(fnd_file.log,' Failed while populating the data into the global tmp table for c_data. Error : ' || SUBSTR(SQLERRM,1,200)); end if;
        END;

        BEGIN
          FOR c_end_date IN c_period_end_date
          LOOP
            l_end_date := c_end_date.PERIOD_END_DATE;
          END LOOP;

          EXCEPTION
            WHEN OTHERS THEN
              if g_debug = true then fnd_file.put_line(fnd_file.log,' Failed while selecting the period end date. Error : ' || SUBSTR(SQLERRM,1,200)); end if;
        END;

		--  Implementing seq num ---------
	BEGIN
		SELECT NVL(enable_report_sequence_flag ,'N')
			INTO l_enable_report_sequence_flag
	        FROM jg_zz_vat_rep_entities
		WHERE vat_reporting_entity_id = P_VAT_REPORTING_ENTITY_ID;

		IF l_enable_report_sequence_flag = 'Y' THEN

			FOR c_data IN temp_cur
			LOOP
				IF c_data.vat_code <> v_prev_vat_code  or c_data.vat_code IS NULL THEN
					v_count	:= 0;
				END IF;

				 	SELECT  distinct JG_INFO_V40
						INTO v_is_seq_updated
					FROM JG_ZZ_VAT_TRX_GT T1
					WHERE   T1.jg_info_n5 = c_data.trx_id
					AND T1.jg_info_v7 = c_data.vat_code
					AND T1.jg_info_v15 = c_data.reporting_code;

					IF NVL(v_is_seq_updated,'N') <> 'Y' THEN

						v_count := v_count+1;

					       UPDATE JG_ZZ_VAT_TRX_GT SET jg_info_n1 = v_count ,
					          jg_info_v40 = 'Y'
		               		       WHERE jg_info_n5 = c_data.trx_id
				               AND  jg_info_v7 = c_data.vat_code
					       AND  jg_info_v15 = c_data.reporting_code;
					END IF;

				v_prev_vat_code := c_data.vat_code;

 			  END LOOP;
		   END IF;
		 EXCEPTION
                 WHEN OTHERS THEN
                 fnd_file.put_line(fnd_file.log,' Failed while Implementing seq num : ' || SUBSTR(SQLERRM,1,200));
	    END;
	-- End of Implementing seq num ---------

        P_WHERE_CLAUSE := ' AND ';

        -- Exclude paid transactions for the
        -- Annex Report
        l_cleared_select := '(SELECT NVL((SELECT  NVL(SUM(pay.payment_base_amount),0)
                              FROM ap_invoices_all INV, ap_invoice_payments_all PAY, ap_checks_all CHECKS
                              WHERE inv.invoice_id = pay.invoice_id
                              AND checks.check_id = pay.check_id
                              AND jg_info_n5 = inv.invoice_id
                              AND checks.status_lookup_code IN ( ''CLEARED'' , ''RECONCILED'' , ''CLEARED BUT UNACCOUNTED'', ''RECONCILED UNACCOUNTED'' )';

        l_cleared_select1 := '* decode(jg_info_n15, NULL, jg_info_n8, jg_info_n2)
                            / (SELECT inv1.base_amount
                               FROM   ap_invoices_all   INV1
                               WHERE  jg_info_n5 = inv1.invoice_id ),0) from dual )';

        l_unpaid_amt_select := 'AND (SELECT nvl(sum(amount_remaining),99999)
                                     FROM    ap_invoices_all              INV,
                                             ap_invoice_payments_all      PAY,
                                             ap_checks_all            CHECKS,
                                             ap_payment_schedules_all APS
                                     WHERE   APS.invoice_id   = inv.invoice_id
                                     AND     inv.invoice_id = pay.invoice_id
                                     AND checks.check_id = pay.check_id
                                     AND jg_info_n5  = inv.invoice_id
                                     AND checks.status_lookup_code IN ( ''CLEARED'' , ''RECONCILED'' , ''CLEARED BUT UNACCOUNTED'', ''RECONCILED UNACCOUNTED'' )';


        IF P_VAT_TRX_TYPE IS NULL
          AND P_EX_VAT_TRX_TYPE IS NULL THEN

          IF ((l_country_code = 'HU' OR l_country_code = 'PL')) THEN

            P_WHERE_CLAUSE := P_WHERE_CLAUSE || ' (((jg_info_n4 > ' || l_cleared_select
                       || ' AND trunc(checks.cleared_date) <= ''' || l_end_date
                       || ''' AND NVL(jg_info_v19,''N'') = ''Y'') ' || l_cleared_select1
                       || ' ) AND (jg_info_n12 = 1 ) AND jg_info_n15 IS NULL ' || l_unpaid_amt_select
                       || ' AND trunc(checks.cleared_date) <= '''||l_end_date||''' ) > 0 AND '''||l_country_code||'''  <> ''PL'')'
                       || ' OR ((decode(jg_info_n15, NULL, jg_info_n8, jg_info_n2) > ' ||l_cleared_select
                       || ' AND trunc(checks.cleared_date) <= ''' || l_end_date || ''' AND ( ''' || l_country_code || ''' = ''PL'' OR '
                       || '  NVL(jg_info_v19,''N'') = ''N'' )) ' || l_cleared_select1 || ' ) AND (''' || l_country_code || ''' = ''PL'' OR '
                       || 'jg_info_n12 = 0 ) ' || l_unpaid_amt_select ||' AND trunc(checks.cleared_date) <= ''' || l_end_date || ''' ) > 0  ))';

          ELSIF (l_country_code = 'SK') THEN

            P_WHERE_CLAUSE := P_WHERE_CLAUSE || ' ((jg_info_n4 <= ' || l_cleared_select ||' AND trunc(checks.cleared_date) <= ''' ||l_end_date
                       || ''' AND jg_info_v19 = ''Y'') AND (jg_info_n12 = 1 )) OR (jg_info_n12 = 0 ))';

          ELSIF (l_country_code = 'HR') THEN
            /*
            || Vendor Invoice Tax Report, Croatia
            || ELSIF added by Ramananda.
            || Requirements of this report are satisfied with the ECE Payables Tax Report
            || No Filtering conditions are required for Croatia
            */
              if g_debug = true then fnd_file.put_line(fnd_file.log,'Croatian Supplier Invoice Tax Report concurrent is submitted' ); end if;
              NULL ;
          END IF;

        ELSE
          IF ((l_country_code = 'HU' OR l_country_code = 'PL')) THEN


            P_WHERE_CLAUSE := P_WHERE_CLAUSE || ' (((jg_info_n4 > ' ||  l_cleared_select
               || ' AND trunc(checks.cleared_date) <= ''' ||l_end_date|| ''' AND NVL(jg_info_v19,''N'') = ''Y'') '
               || l_cleared_select1 || ' ) AND (jg_info_n12 = 1 ) AND jg_info_n15 IS NULL ' || l_unpaid_amt_select
               || ' AND trunc(checks.cleared_date) <= ''' ||l_end_date|| ''' ) > 0 AND ''' ||l_country_code|| ''' <> ''PL'' )'
               || ' OR ((decode(jg_info_n15, NULL, jg_info_n8, jg_info_n2) > ' || l_cleared_select
               || ' AND trunc(checks.cleared_date) <= ''' ||l_end_date|| ''' AND ( '''|| l_country_code
               || ''' = ''PL'' OR NVL(jg_info_v19,''N'') = ''N''))' || l_cleared_select1 || ') AND (''' ||l_country_code|| ''' = ''PL'''
               || ' OR jg_info_n12 = 0 ) ' || l_unpaid_amt_select|| ' AND trunc(checks.cleared_date) <= ''' ||l_end_date|| ''' ) > 0 ))';


          ELSIF (l_country_code = 'SK') THEN

            P_WHERE_CLAUSE := P_WHERE_CLAUSE || ' ((jg_info_n4 <= ' || l_cleared_select
               || ' AND trunc(checks.cleared_date) <= ''' ||l_end_date
               || ''' AND jg_info_v19 = ''Y'') AND (jg_info_n12 = 1 )) OR (jg_info_n12 = 0 ))';

          ELSIF (l_country_code = 'HR') THEN
              if g_debug = true then fnd_file.put_line(fnd_file.log,'Croatian Supplier Invoice Tax Report concurrent is submitted' ); end if;
              NULL ;
          END IF;

        END IF ;

        IF P_WHERE_CLAUSE = ' AND ' THEN
          P_WHERE_CLAUSE := ' AND 1 = 1 ';
        END IF;

       END IF;  --END IF for IF l_country_code = 'IL'

-- End of code for ECE and Crotia reports.

      ELSE    -- FOR IF calling report is NULL

        BEGIN
          FOR c_data_rec2 IN c_complete
          LOOP


            INSERT INTO JG_ZZ_VAT_TRX_GT
              (jg_info_n1 -- seq_number
              ,jg_info_v1 -- inv_number
              ,jg_info_v2 -- customer_name
              ,jg_info_d1 -- tax_date
              ,jg_info_d2 -- inv_date
              ,jg_info_d3 -- accounting_date
              ,jg_info_v3 -- tax_code_description
              ,jg_info_n2 -- taxable_amount
              ,jg_info_n3 -- tax_rate
              ,jg_info_n4 -- tax_amount
              ,jg_info_n5 -- trx_id
              ,jg_info_v4 -- trx_class_code
              ,jg_info_v5 -- trx_currency_code
              ,jg_info_v20 -- TAX_RECOVERABLE_FLAG
              ,jg_info_v6 -- Tax Code Description
              ,jg_info_n8 -- TAX_AMT_FUNCL_CURR
              ,jg_info_n10 -- TAXABLE_AMT_FUNCL_CURR
              ,jg_info_v8 -- ACCOUNT FLEXFIELD
              ,jg_info_v10 -- Doc Sequence Name
              ,jg_info_v11 -- tax_reg_num
              ,jg_info_v12 -- TAX_RATE_VAT_TRX_TYPE_DESC
              ,jg_info_v13 -- TAX_CODE_VAT_TRX_TYPE_MEANING
              ,jg_info_v14 -- TAX_CODE
              ,jg_info_v7 -- TAX_CODE_VAT_TRX_TYPE_CODE
              ,jg_info_v15 -- TAX_CODE_TYPE_CODE
              ,jg_info_v16 -- period_name
              ,jg_info_v17 -- offset_flag
              ,jg_info_v18 -- offset_tax_rate_code
              ,jg_info_v19 -- CHK_VAT_AMOUNT_PAID
	      ,jg_info_v21 -- reporting_code
               )
            VALUES
              (c_data_rec2.seq_number
              ,c_data_rec2.inv_number
              ,c_data_rec2.customer_name
              ,c_data_rec2.tax_date
              ,c_data_rec2.inv_date
              ,c_data_rec2.gl_date
              ,c_data_rec2.tax_rate_code_description
              ,c_data_rec2.taxable_amount
              ,c_data_rec2.tax_rate
              ,c_data_rec2.tax_amount
              ,c_data_rec2.trx_id
              ,c_data_rec2.trx_line_class
              ,c_data_rec2.trx_currency_code
              ,c_data_rec2.tax_recoverable_flag
              ,c_data_rec2.tax_rate_code_description
              ,c_data_rec2.tax_amt_funcl_curr
              ,c_data_rec2.taxable_amt_funcl_curr
              ,c_data_rec2.account_flexfield
              ,c_data_rec2.doc_seq_name
              ,c_data_rec2.tax_reg_num
              ,c_data_rec2.tax_rate_vat_trx_type_desc
              ,c_data_rec2.tax_rate_code_vat_trx_type_mng
              ,c_data_rec2.tax_rate_code
              ,c_data_rec2.tax_rate_vat_trx_type_code
              ,c_data_rec2.tax_type_code
              ,c_data_rec2.gl_period
              ,c_data_rec2.offset_flag
              ,c_data_rec2.offset_tax_rate_code
              ,c_data_rec2.chk_vat_amount_paid
	      ,c_data_rec2.reporting_code);

          END LOOP;

        EXCEPTION
          WHEN OTHERS THEN
            if g_debug = true then fnd_file.put_line(fnd_file.log,' Failed while populating data in the global tmp table for the generic cursor. Error : ' || SUBSTR(SQLERRM,1,200)); end if;
        END;

      END IF;


    EXCEPTION
      WHEN OTHERS THEN
        if g_debug = true then fnd_file.put_line(fnd_file.log,' An error occured in the before report trigger. Error : ' || SUBSTR(SQLERRM,1,200)); end if;
        RETURN(FALSE);
    END;

    if g_debug = true then
      fnd_file.put_line(fnd_file.log,'P_WHERE_CLAUSE: ' ||P_WHERE_CLAUSE);
    end if;

    RETURN(TRUE);

  END before_report;

/*
REM +======================================================================+
REM Name: GET_EX_VAT_TRX_TYPE_MEANING
REM
REM Description: Returns the Vat Transaction type meaning
REM
REM Parameters:   None
REM +======================================================================+
*/
  FUNCTION get_vat_trx_type_meaning RETURN VARCHAR2 IS
  BEGIN
    RETURN G_VAT_TRX_TYPE_MEANING;
  END get_vat_trx_type_meaning;

/*
REM +======================================================================+
REM Name: GET_EX_VAT_TRX_TYPE_MEANING
REM
REM Description: Returns the Exclude Vat Transaction type meaning
REM
REM Parameters:   None
REM +======================================================================+
*/
  FUNCTION get_ex_vat_trx_type_meaning RETURN VARCHAR2 IS
  BEGIN
    RETURN G_EX_VAT_TRX_TYPE_MEANING;
  END get_ex_vat_trx_type_meaning;

/*
REM +======================================================================+
REM Name: GET_VAT_TRX_TYPE_DESC
REM
REM Description: Returns the Vat Transaction type description
REM
REM Parameters:   None
REM +======================================================================+
*/
  FUNCTION get_vat_trx_type_desc RETURN VARCHAR2 IS
  BEGIN
    RETURN G_VAT_TRX_TYPE_DESC;
  END get_vat_trx_type_desc;

/*
REM +======================================================================+
REM Name: GET_EX_VAT_TRX_TYPE_DESC
REM
REM Description: Returns the Exclude Vat Transaction type description
REM
REM Parameters:   None
REM +======================================================================+
*/
  FUNCTION get_ex_vat_trx_type_desc RETURN VARCHAR2 IS
  BEGIN
    RETURN G_EX_VAT_TRX_TYPE_DESC;
  END get_ex_vat_trx_type_desc;

/*
REM +======================================================================+
REM Name: GET_PREPAYMENTS_MEANING
REM
REM Description: Returns the Include Prepayments parameter meaning.
REM
REM Parameters:   None
REM +======================================================================+
*/
  FUNCTION get_prepayments_meaning RETURN VARCHAR2 IS
    CURSOR c_prepay_meaning
    IS
      SELECT meaning
        FROM fnd_lookups
       WHERE lookup_code = P_INC_PREPAYMENTS
         AND lookup_type = 'YES_NO';

  BEGIN

    IF P_INC_PREPAYMENTS IS NOT NULL THEN
      FOR c_meaning IN c_prepay_meaning
      LOOP
        G_INC_PREPAYMENTS := c_meaning.meaning;
      END LOOP;
    END IF;

    RETURN G_INC_PREPAYMENTS;

  EXCEPTION
    WHEN OTHERS THEN
      if g_debug = true then fnd_file.put_line(fnd_file.log,' Failed while extracting the prepayments meaning. Error : ' || SUBSTR(SQLERRM,1,200)); end if;
      RETURN NULL;
  END get_prepayments_meaning;

/*
REM +======================================================================+
REM Name: GET_FUNCTIONAL_CURRENCY
REM
REM Description: Returns the functional currency
REM
REM Parameters:   None
REM +======================================================================+
*/
  FUNCTION get_functional_currency RETURN VARCHAR2 IS
  BEGIN
    RETURN G_FUNCTIONAL_CURRENCY;
  END get_functional_currency;

/*
REM +======================================================================+
REM Name: CF_TAX_CODE_TYPE_CODE
REM
REM Description: Returns 1 or 0 based on the tax type.
REM
REM Parameters:   TAX_CODE_TYPE_CODE => Whether tax is VAT or OFFSET
REM +======================================================================+
*/
  FUNCTION CF_Tax_Code_Type_Code(TAX_CODE_TYPE_CODE VARCHAR2) RETURN NUMBER IS
  BEGIN
    IF TAX_CODE_TYPE_CODE = 'XOFFSET' THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  END;

/*
REM +======================================================================+
REM Name: GET_TRN
REM
REM Description: Fetches and returns the TRN number
REM
REM Parameters:   None
REM +======================================================================+
*/
  FUNCTION get_trn RETURN VARCHAR2 IS
    l_trn         VARCHAR2(30) := '';

    CURSOR c_get_trn
    IS
      SELECT JZVRS.TAX_REGISTRATION_NUMBER
      FROM   JG_ZZ_VAT_REP_STATUS JZVRS
      WHERE  JZVRS.VAT_REPORTING_ENTITY_ID = P_VAT_REPORTING_ENTITY_ID
      /* added during UT */
      AND (P_TAX_CALENDAR_PERIOD is null and  jzvrs.tax_calendar_period = P_TAX_CALENDAR_PERIOD)
      AND jzvrs.source = 'AP'
      AND    rownum = 1;

  BEGIN

    FOR c_trn IN c_get_trn
    LOOP
      l_trn := c_trn.TAX_REGISTRATION_NUMBER;
    END LOOP;

    RETURN l_trn;
  EXCEPTION
    WHEN OTHERS THEN
      if g_debug = true then
        fnd_file.put_line(fnd_file.log,' Failed while extracting the Tax Reginstration Number. Error : ' || SUBSTR(SQLERRM,1,200));
      end if;
      Return NULL;
  END get_trn;

/*
REM +======================================================================+
REM Name: CF_SEQ_NO
REM
REM Description: This function returns the sequence number for a particular
REM              country. The sequence no is incremented each time this
REM              function is called.
REM
REM Parameters:   None
REM +======================================================================+
*/
  FUNCTION CF_seq_no RETURN NUMBER IS
  l_country_code       VARCHAR2(5);
  BEGIN
    /* added during UT */
    l_country_code := jg_zz_shared_pkg.GET_COUNTRY;
    if l_country_code is null then
      l_country_code := jg_zz_shared_pkg.GET_COUNTRY(mo_global.get_current_org_id);
    end if;

    IF l_country_code = 'PL' THEN
      G_SEQ_NO := G_SEQ_NO + 1;
      RETURN (G_SEQ_NO);
    ELSE
      RETURN NULL;
    END IF;

  END CF_seq_no;

END JG_ZZ_SUMMARY_AP_PKG;

/
