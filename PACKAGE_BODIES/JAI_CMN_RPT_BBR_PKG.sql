--------------------------------------------------------
--  DDL for Package Body JAI_CMN_RPT_BBR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_RPT_BBR_PKG" AS
/* $Header: jai_cmn_rpt_bbr.plb 120.1 2005/07/20 12:57:39 avallabh ship $ */

/*----------------------------------------------------------------------------------------
Filename:

Change History:

Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------
08-Jun-2005  Version 116.2 jai_cmn_rpt_bbr -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
	     as required for CASE COMPLAINCE.

13-Jun-2005  Ramananda for bug#4428980. File Version: 116.3
             Removal of SQL LITERALs is done

06-Jul-2005  Ramananda for bug#4477004. File Version: 116.4
             GL Sources and GL Categories got changed. Refer bug for the details

----------------------------------------------------------------------------------------*/

FUNCTION get_credit_balance(
			b_start_date DATE,
			b_bank_account_name VARCHAR,
			b_bank_account_num VARCHAR,
			b_org_id NUMBER) return Number is
   amt NUMBER;
    amt1 NUMBER;

    /* Added by Ramananda for bug#4407165 */
    lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rpt_bbr_pkg.get_credit_balance';

/* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
	lv_status_cleared    ar_cash_receipt_history_all.status%type ;
	lv_status_remitted   ar_cash_receipt_history_all.status%type ;
	lv_status_confirmed  ar_cash_receipt_history_all.status%type ;
	lv_status_reversed   ar_cash_receipt_history_all.status%type ;

	lv_src_payables  gl_je_headers.je_source%type ;
	lv_src_rcv       gl_je_headers.je_source%type ;


BEGIN

  --Stored function to calculate the o/b and c/b for Cash and Bank Book report
  --code modified by sridhar k to consider reversal receipts
  --whereever there is a reversal receipt, it is made negative to nullify the overall effect.

  lv_status_cleared :=   'CLEARED';
  lv_status_remitted :=  'REMITTED';
  lv_status_confirmed := 'CONFIRMED';
  lv_status_reversed := 'REVERSED'	;

   lv_src_payables := 'Payables India';
   lv_src_rcv      := 'Receivables India' ;


    SELECT SUM(DECODE(acrh.status, 'REVERSED',(acrh.amount*NVL(acrh.exchange_rate,1))*-1,
               NVL(acrh.amount, 0)*NVL(acrh.exchange_rate,1))) INTO amt
  FROM   ar_cash_receipt_history_all acrh,
         ar_cash_receipts_all acr,
         hz_cust_accounts rc,
         ce_bank_accounts ceba
  WHERE  acrh.cash_receipt_id = acr.cash_receipt_id
  AND    acr.remittance_bank_account_id = ceba.bank_account_id
  AND    acr.pay_from_customer = rc.cust_account_id (+)
  AND    acrh.status IN (lv_status_cleared, lv_status_remitted, lv_status_confirmed, lv_status_reversed) --'CLEARED', 'REMITTED', 'CONFIRMED','REVERSED') --reversal entries considered
  AND    ceba.bank_account_name = NVL(b_bank_account_name, ceba.bank_account_name)
  AND    ceba.bank_account_num = NVL(b_bank_account_num, ceba.bank_account_num)
  AND    TRUNC(acrh.gl_date ) < TRUNC(b_start_date)
  AND    (acr.org_id = b_org_id OR acr.org_id IS NULL);
  --SRW.message(3, to_char(NVL(amt, 0)));

  SELECT SUM(accounted_dr) INTO amt1
  FROM  gl_je_headers glh,
        gl_je_lines gll,
        ce_gl_accounts_ccid cega,
        ce_bank_acct_uses_all cebau,
        ce_bank_accounts ceba
  WHERE  cega.bank_acct_use_id = cebau.bank_acct_use_id
  AND    cebau.bank_account_id = ceba.bank_account_id
  AND    ceba.ap_use_allowed_flag = 'Y'
  AND    (ceba.start_date IS NULL OR ceba.start_date <= trunc(sysdate))
  AND    (ceba.end_date  IS NULL OR ceba.end_date  >= trunc(sysdate))
  AND    cebau.ap_use_enable_flag = 'Y'
  AND    (cebau.end_date IS NULL OR cebau.end_date >= trunc(sysdate))
  AND    glh.je_header_id = gll.je_header_id
  AND    cega.ap_asset_ccid =  gll.code_combination_id
  AND    ceba.bank_account_name = NVL(b_bank_account_name, ceba.bank_account_name)
  AND    ceba.bank_account_num  = NVL(b_bank_account_num, ceba.bank_account_num)
  AND    glh.je_source NOT IN (lv_src_payables, lv_src_rcv) --'Payables India', 'Receivables India')
  AND    TRUNC(glh.default_effective_date ) < TRUNC(b_start_date)
  AND    (cebau.org_id = b_org_id OR cebau.org_id IS NULL);
  --SRW.message(4, to_char(NVL(amt1, 0)));
  RETURN(NVL(amt, 0) + NVL(amt1, 0));

/* Added by Ramananda for bug#4407165 */
EXCEPTION
	WHEN OTHERS THEN
	FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
	FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
	app_exception.raise_exception;

END get_credit_balance;

FUNCTION get_debit_balance(
                                                                                                        b_start_date DATE,
                                                                                                        b_bank_account_name VARCHAR,
                                                                                                        b_bank_account_num VARCHAR,
                                                                                                        b_org_id NUMBER)
                                                                                                        RETURN Number is
        amt NUMBER;
        amt1 NUMBER;

 /* Added by Ramananda for bug#4407165 */
 lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rpt_bbr_pkg.get_debit_balance';

	lv_negotiable  ap_checks_all.status_lookup_code%TYPE;
	lv_cleared     ap_checks_all.status_lookup_code%TYPE;
	lv_voided      ap_checks_all.status_lookup_code%TYPE;

	lv_src_payables  gl_je_headers.je_source%type ;
	lv_src_rcv       gl_je_headers.je_source%type ;

 --Stored function to calculate the o/b and c/b for Cash and Bank Book report
        BEGIN

	lv_negotiable :=  'NEGOTIABLE';
        lv_cleared   :=	  'CLEARED';
	lv_voided    :=	  'VOIDED' ;

        lv_src_payables := 'Payables India';
        lv_src_rcv      := 'Receivables India' ;

	SELECT SUM(NVL(aip.amount, 0)*NVL(aip.exchange_rate,1)) INTO amt   /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
        FROM   ap_invoice_payments_all aip,
                                 ap_invoices_all api,
                                 ap_checks_all apc,
                                 ce_bank_accounts ceba
        WHERE  api.invoice_id = aip.invoice_id
        AND   aip.check_id = apc.check_id
        AND   apc.bank_account_id = ceba.bank_account_id
        AND   apc.status_lookup_code IN (lv_negotiable, lv_cleared, lv_voided) --'NEGOTIABLE', 'CLEARED','VOIDED') --added for voided payments by sridhar k
        AND   ceba.bank_account_name = NVL(b_bank_account_name, ceba.bank_account_name)
        AND   ceba.bank_account_num = NVL(b_bank_account_num, ceba.bank_account_num)
        AND    TRUNC(aip.accounting_date ) < TRUNC(b_start_date)
        AND    (api.org_id = b_org_id OR api.org_id IS NULL);
        --SRW.message(1, to_char(NVL(amt, 0)));
        SELECT SUM(accounted_cr) INTO amt1
        FROM  gl_je_headers glh,
              gl_je_lines gll,
              ce_gl_accounts_ccid cega,
              ce_bank_acct_uses_all cebau,
              ce_bank_accounts ceba
        WHERE cega.bank_acct_use_id = cebau.bank_acct_use_id
        AND   cebau.bank_account_id = ceba.bank_account_id
        AND   ceba.ap_use_allowed_flag = 'Y'
        AND   (ceba.start_date IS NULL OR ceba.start_date <= TRUNC (sysdate))
        AND   (ceba.end_date IS NULL OR ceba.end_date >= trunc(sysdate))
        AND   cebau.ap_use_enable_flag = 'Y'
        AND   (cebau.end_date IS NULL OR cebau.end_date >= trunc(sysdate))
        AND   glh.je_header_id = gll.je_header_id
        AND   cega.ap_asset_ccid =  gll.code_combination_id
        AND   ceba.bank_account_name = NVL(b_bank_account_name, ceba.bank_account_name)
        AND   ceba.bank_account_num = NVL(b_bank_account_num, ceba.bank_account_num)
        AND   glh.je_source NOT IN (lv_src_payables, lv_src_rcv) --'Payables India', 'Receivables India')
        AND   TRUNC(glh.default_effective_date ) < TRUNC(b_start_date)
        AND   (cebau.org_id = b_org_id OR cebau.org_id IS NULL);
        --SRW.message(2, to_char(NVL(amt1, 0)));
        RETURN(NVL(amt, 0) + NVL(amt1, 0));

           /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

END get_debit_balance;

END jai_cmn_rpt_bbr_pkg;

/
