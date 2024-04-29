--------------------------------------------------------
--  DDL for Package Body OKL_BPD_ADV_MON_RPT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BPD_ADV_MON_RPT_PVT" AS
/* $Header: OKLRAVRB.pls 120.13 2007/08/02 07:10:30 dcshanmu noship $ */

-- Procedure for Advance Monies Report Generation
PROCEDURE         DO_REPORT(p_errbuf       OUT NOCOPY VARCHAR2,
                            p_retcode      OUT NOCOPY NUMBER,
                            p_rcpt_applic_stat    IN   VARCHAR2,
                            p_From_date          IN   VARCHAR2,
                            p_To_date            IN   VARCHAR2)

IS

--Cursor for Applied Receipts
CURSOR C_Appld_Rcpts(lap_from_date DATE, lap_to_Date DATE) IS
/*SELECT DISTINCT okl_ext_csh_rcpts_b.check_number check_number,
				okl_ext_csh_rcpts_b.receipt_date receipt_date,
				okl_ext_csh_rcpts_b.remittance_amount remittance_amount,
				okx_customer_accounts_v.NAME NAME,
 				okl_ext_csh_rcpts_b.customer_number customer_number,
 				okl_ext_csh_rcpts_b.CURRENCY_CODE currency_code,
        ( SELECT  NVL(Sum(amount_applied),0)
  	  		FROM    AR_RECEIVABLE_APPLICATIONS_ALL
  	  		WHERE   status = 'ACC'
 	  			AND     cash_Receipt_id = okl_ext_csh_rcpts_b.icr_id) Amount,
 	  	  okc_k_headers_b.Contract_Number Contract_number ,
 				okl_xtl_csh_apps_b.invoice_number invoice_number,
				okl_xtl_csh_apps_b.TRX_DATE TRX_DATE,
				okl_xtl_csh_apps_b.amount_applied amount_applied
FROM    okl_ext_csh_rcpts_b,okl_xtl_csh_apps_b,okl_txl_rcpt_apps_b,
        okx_customer_accounts_v,okc_k_headers_b, okl_trx_csh_receipt_b
WHERE   okl_ext_csh_rcpts_b.ID = okl_xtl_csh_apps_b.XCR_ID_DETAILS
AND     okl_trx_csh_receipt_b.id = okl_txl_rcpt_apps_b.RCT_ID_DETAILS
AND     okl_txl_rcpt_apps_b.ILE_ID = okx_customer_accounts_v.ID1
AND     okc_k_headers_b.id(+)         = okl_txl_rcpt_apps_b.khr_id
AND     okl_trx_csh_receipt_b.receipt_type = 'ADV'
AND     okl_ext_csh_rcpts_b.RCT_ID = okl_trx_csh_receipt_b.id
AND     okl_ext_csh_rcpts_b.Receipt_date  >= NVL(lap_from_date,okl_ext_csh_rcpts_b.Receipt_date)
AND     okl_ext_csh_rcpts_b.Receipt_date  <= NVL(lap_to_Date,okl_ext_csh_rcpts_b.Receipt_date)
ORDER BY Check_number;
*/

SELECT DISTINCT a.receipt_number check_number,
				b.receipt_date receipt_date,
				b.amount remittance_amount,
				f.NAME NAME,
 				b.pay_from_customer customer_number,
 				b.CURRENCY_CODE currency_code,
        ( SELECT  NVL(Sum(amount_applied),0)
  	  		FROM    AR_RECEIVABLE_APPLICATIONS_ALL
  	  		WHERE   status = 'ACC'
 	  			AND     cash_Receipt_id = a.cash_receipt_id) Amount,
         	  	c.Contract_Number Contract_number ,
 				a.invoice_number invoice_number,
 				d.trx_date trx_date,
		( SELECT NVL(SUM(a.line_applied + a.tax_applied), 0)
            FROM okl_receipt_applications_uv
            WHERE cash_receipt_id = a.cash_receipt_id) amount_applied
FROM    okl_receipt_applications_uv a, ar_cash_receipts_all b, okc_k_headers_b c,
        ar_payment_schedules_all d, okl_trx_csh_receipt_b e, okx_customer_accounts_v f,
        ar_receivable_applications_all g
WHERE   a.cash_receipt_id = b.cash_receipt_id
AND     b.cash_receipt_id = e.cash_receipt_id
AND     b.cash_receipt_id = g.cash_receipt_id
AND     g.applied_payment_schedule_id = d.payment_schedule_id
AND     b.pay_from_customer = f.ID1
AND     a.contract_number(+) = c.contract_number
AND     e.receipt_type = 'ADV'
AND     b.Receipt_date  >= NVL(null,b.Receipt_date)
AND     b.Receipt_date  <= NVL(null,b.Receipt_date)
ORDER BY Check_number;

--Cursor for Unapplied Receipts
CURSOR C_Unappld_Rcpts(lup_from_date DATE, lup_to_Date DATE) IS
/*SELECT  DISTINCT okl_ext_csh_rcpts_b.check_number check_number,
        okl_ext_csh_rcpts_b.receipt_date receipt_date,
				okl_ext_csh_rcpts_b.remittance_amount remittance_amount,
				okx_customer_accounts_v.NAME NAME,
 				okl_ext_csh_rcpts_b.customer_number customer_number,
 				okl_ext_csh_rcpts_b.CURRENCY_CODE currency_code,
 			  ( SELECT  NVL(Sum(amount_applied),0)
  	  		FROM    AR_RECEIVABLE_APPLICATIONS_ALL
  	 			WHERE   status = 'ACC'
 	  			AND     cash_Receipt_id = okl_ext_csh_rcpts_b.icr_id)Amount,
        okc_k_headers_b.Contract_Number Contract_number
FROM    okl_ext_csh_rcpts_b,okl_txl_rcpt_apps_b,okx_customer_accounts_v,okc_k_headers_b, okl_trx_csh_receipt_b
WHERE   okl_trx_csh_receipt_b.id = okl_txl_rcpt_apps_b.RCT_ID_DETAILS
AND     okl_txl_rcpt_apps_b.ILE_ID = okx_customer_accounts_v.ID1
AND     okc_k_headers_b.id (+)        = okl_txl_rcpt_apps_b.khr_id
AND     okl_trx_csh_receipt_b.receipt_type = 'ADV'
AND     okl_ext_csh_rcpts_b.RCT_ID = okl_trx_csh_receipt_b.id
AND     okl_ext_csh_rcpts_b.Receipt_date  >= NVL(lup_From_date,okl_ext_csh_rcpts_b.Receipt_date)
AND     okl_ext_csh_rcpts_b.Receipt_date  <= NVL(lup_To_date,okl_ext_csh_rcpts_b.Receipt_date)
AND     NOT EXISTS (select id from okl_xtl_csh_apps_b where xcr_id_details = okl_ext_csh_rcpts_b.id)
ORDER BY Check_number;
*/

SELECT DISTINCT a.receipt_number check_number,
				b.receipt_date receipt_date,
				b.amount remittance_amount,
				f.NAME NAME,
 				b.pay_from_customer customer_number,
 				b.CURRENCY_CODE currency_code,
        ( SELECT  NVL(Sum(amount_applied),0)
  	  		FROM    AR_RECEIVABLE_APPLICATIONS_ALL
  	  		WHERE   status = 'ACC'
 	  			AND     cash_Receipt_id = a.cash_receipt_id) Amount,
         	  	c.Contract_Number Contract_number
FROM    okl_receipt_applications_uv a, ar_cash_receipts_all b, okc_k_headers_b c,
        okl_trx_csh_receipt_b e, okx_customer_accounts_v f
WHERE   a.cash_receipt_id = b.cash_receipt_id
AND     b.cash_receipt_id = e.cash_receipt_id
AND     b.pay_from_customer = f.ID1
AND     a.contract_number(+) = c.contract_number
AND     e.receipt_type = 'ADV'
AND     b.Receipt_date  >= NVL(null,b.Receipt_date)
AND     b.Receipt_date  <= NVL(null,b.Receipt_date)
AND     NOT EXISTS (select id from okl_txl_rcpt_apps_b where rct_id_details = e.id)
ORDER BY Check_number;

CURSOR org_csr (l_org_id IN NUMBER) IS
   SELECT name
   FROM   hr_operating_units
   WHERE  organization_id = l_org_id;

l_receipt_no		  OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%Type DEFAULT 0;
l_Cust_No             AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%Type DEFAULT 0;
l_Contract_No         okc_k_headers_b.Contract_Number%Type DEFAULT 0;

l_from_date           DATE;
l_to_date             DATE;
l_org_id              NUMBER := MO_GLOBAL.GET_CURRENT_ORG_ID();
l_org_name              VARCHAR2(240);
i                     NUMBER DEFAULT 0;
j                     NUMBER DEFAULT 0;

--length
l_Receipt#_len		    CONSTANT NUMBER DEFAULT 10;
l_Receipt_Date_len    CONSTANT NUMBER DEFAULT 12;
l_Receipt_Amount_len  CONSTANT NUMBER DEFAULT 15;
l_Customer_Name_len   CONSTANT NUMBER DEFAULT 33;
l_Customer#_len       CONSTANT NUMBER DEFAULT 10;
l_Account_Balance_len CONSTANT NUMBER DEFAULT 15;
l_Contract_Number_len CONSTANT NUMBER DEFAULT 20;
l_Invoice#_len       	CONSTANT NUMBER DEFAULT 10;
l_Invoice_Date_len   	CONSTANT NUMBER DEFAULT 12;
l_Amount_Applied_len 	CONSTANT NUMBER DEFAULT 15;
l_length_till_invc    CONSTANT NUMBER DEFAULT 116;
l_length_till_invc1    CONSTANT NUMBER DEFAULT 121;
l_total_length        CONSTANT NUMBER DEFAULT 152;

BEGIN

l_from_date:= FND_DATE.CANONICAL_TO_DATE(p_from_date);
l_to_date  := FND_DATE.CANONICAL_TO_DATE(p_to_date);

  FOR org_rec IN org_csr (l_org_id)
  LOOP
    l_org_name := org_rec.name;
  END LOOP;


  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', 52 , ' ' ) ||  fnd_message.get_string('OKL','OKLHOMENAVTITLE') ||
  RPAD(' ', 53 , ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', 52 , ' ' ) ||  fnd_message.get_string('OKL','OKL_BPD_ADV_MNY_RPT_TITLE') ||
  RPAD(' ', 53 , ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ',50, ' ' ) || '-------------------------------' || RPAD(' ', 51, ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
  Fnd_File.PUT_LINE(Fnd_File.OUTPUT, Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_OPERUNIT')
    ||' : '|| SUBSTR(l_org_name, 1, 30) || RPAD(' ', 50 , ' ' ) || fnd_message.get_string('OKL','OKL_REQUEST_ID')
    ||' : ' ||  Fnd_Global.CONC_REQUEST_ID);
  Fnd_File.PUT_LINE(Fnd_File.OUTPUT, fnd_message.get_string('OKL','OKL_AGN_RPT_CURRENCY')
    ||' : '|| okl_accounting_util.get_func_curr_code || RPAD(' ', 70 , ' ' )
	|| Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_RUN_DATE')  ||' : ' ||
    SUBSTR(TO_CHAR(SYSDATE, 'DD-MON-YYYY'), 1, 27));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', 100 , '-' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_RCPT_APP_STATUS') || ' : '
      || fnd_message.get_string('OKL',p_rcpt_applic_stat));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_FROM_DATE') || ' : ' || l_from_date);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_TO_DATE') || ' : '   || l_to_date);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', 100 , '-' ));

  --Report Header for Applied Receipts
  IF (p_rcpt_applic_stat = 'APPLIED') OR (p_rcpt_applic_stat = 'BOTH') THEN

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_BPD_ADV_MNY_RPT_APPLD_RCPT'));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', 20 , '-' ));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', l_total_length+8 , '-' ));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,GET_PROPER_LENGTH(
      fnd_message.get_string('OKL','OKL_BPD_ADV_MNY_RPT_RCPT_NO'),l_Receipt#_len,'TITLE')||' '||
      GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_BPD_ADV_MNY_RPT_RCPT_DT'),l_Receipt_Date_len,'TITLE')||' '||
      GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_BPD_ADV_MNY_RPT_RCPT_AMNT'),l_Receipt_Amount_len,'TITLE')||' '||
      GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_BPD_ADV_MNY_RPT_CUST_NAME'),l_Customer_Name_len,'TITLE')||' '||
      GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_BPD_ADV_MNY_RPT_CUST_NO'),l_Customer#_len,'TITLE')||' '||
      GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_BPD_ADV_MNY_RPT_ACCNT_BLNC'),l_Account_Balance_len,'TITLE')||' '||
      GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_BPD_ADV_MNY_RPT_CNTRCT_NO'),l_Contract_Number_len,'TITLE')||' '||
      GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_BPD_ADV_MNY_RPT_INVC_NO'),l_Invoice#_len,'TITLE')||' '||
      GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_BPD_ADV_MNY_RPT_INVC_DT'),l_Invoice_Date_len,'TITLE')||' '||
      GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_BPD_ADV_MNY_RPT_AMNT_APPLD'),l_Amount_Applied_len,'TITLE'));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('=', l_total_length+8 , '=' ));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
  -- start report Applied Receipts
      FOR r_appld_rcpts IN C_appld_Rcpts(l_from_date,l_to_date) LOOP
      	j:= j+1;
      	IF i = 0 THEN
      		l_receipt_no 	:= r_appld_rcpts.Check_number;
      		l_cust_no     := r_appld_rcpts.customer_number;
      		l_contract_no := r_appld_rcpts.contract_number;
      	END IF;
      	i:= i+1;

        IF (l_receipt_no =  r_appld_rcpts.Check_number)
           AND (l_cust_no = r_appld_rcpts.customer_number)
           AND (l_contract_no = r_appld_rcpts.contract_number) THEN

           IF i = 1 AND j = 1 THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,GET_PROPER_LENGTH(r_appld_rcpts.check_number,l_Receipt#_len,'DATA')||' '||
            GET_PROPER_LENGTH(r_appld_rcpts.receipt_date,l_Receipt_Date_len,'DATA')||' '||
            GET_PROPER_LENGTH(okl_accounting_util.format_amount(r_appld_rcpts.remittance_amount,r_appld_rcpts.currency_code)
            ,l_Receipt_Amount_len,'DATA')||' '||
            GET_PROPER_LENGTH(r_appld_rcpts.NAME,l_Customer_Name_len,'DATA')||' '||
            GET_PROPER_LENGTH(r_appld_rcpts.customer_number,l_Customer#_len,'DATA')||' '||
            GET_PROPER_LENGTH(okl_accounting_util.format_amount(r_appld_rcpts.amount,r_appld_rcpts.currency_code)
          ,l_Receipt_Amount_len,'DATA')||' '||
            GET_PROPER_LENGTH(r_appld_rcpts.contract_number,l_Contract_Number_len,'DATA')||' '||
            GET_PROPER_LENGTH(r_appld_rcpts.invoice_number,l_Invoice#_len,'DATA')||' '||
            GET_PROPER_LENGTH(r_appld_rcpts.Trx_Date,l_Invoice_Date_len,'DATA')||' '||
            GET_PROPER_LENGTH(okl_accounting_util.format_amount(r_appld_rcpts.amount_applied,r_appld_rcpts.currency_code),l_Amount_Applied_len,'DATA'));
           ELSE
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,GET_PROPER_LENGTH(' ',l_length_till_invc1,'DATA')|| ' '||
            GET_PROPER_LENGTH(r_appld_rcpts.invoice_number,l_Invoice#_len,'DATA')||' '||
            GET_PROPER_LENGTH(r_appld_rcpts.Trx_Date,l_Invoice_Date_len,'DATA')||' '||
            GET_PROPER_LENGTH(okl_accounting_util.format_amount(r_appld_rcpts.amount_applied,r_appld_rcpts.currency_code),l_Amount_Applied_len,'DATA'));
           END IF;
        ELSE
          i := 0;
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,GET_PROPER_LENGTH(r_appld_rcpts.check_number,l_Receipt#_len,'DATA')||' '||
          GET_PROPER_LENGTH(r_appld_rcpts.receipt_date,l_Receipt_Date_len,'DATA')||' '||
          GET_PROPER_LENGTH(okl_accounting_util.format_amount(r_appld_rcpts.remittance_amount,r_appld_rcpts.currency_code)
          ,l_Receipt_Amount_len,'DATA')||' '||
          GET_PROPER_LENGTH(r_appld_rcpts.NAME,l_Customer_Name_len,'DATA')||' '||
          GET_PROPER_LENGTH(r_appld_rcpts.customer_number,l_Customer#_len,'DATA')||' '||
          GET_PROPER_LENGTH(okl_accounting_util.format_amount(r_appld_rcpts.amount,r_appld_rcpts.currency_code)
          ,l_Receipt_Amount_len,'DATA')||' '||
          GET_PROPER_LENGTH(r_appld_rcpts.contract_number,l_Contract_Number_len,'DATA')||' '||
          GET_PROPER_LENGTH(r_appld_rcpts.invoice_number,l_Invoice#_len,'DATA')||' '||
          GET_PROPER_LENGTH(r_appld_rcpts.Trx_Date,l_Invoice_Date_len,'DATA')||' '||
          GET_PROPER_LENGTH(okl_accounting_util.format_amount(r_appld_rcpts.amount_applied,r_appld_rcpts.currency_code),l_Amount_Applied_len,'DATA'));
        END IF;
      END LOOP;
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(' ', l_total_length , ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', l_total_length+8 , '-' ));
  END IF;

  IF (p_rcpt_applic_stat = 'UNAPPLIED') OR (p_rcpt_applic_stat = 'BOTH') THEN
      --Report Header for Unapplied Receipts

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_BPD_ADV_MNY_RPT_UNAPPLD'));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', 20 , '-' ));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', l_length_till_invc , '-' ));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,GET_PROPER_LENGTH(
      fnd_message.get_string('OKL','OKL_BPD_ADV_MNY_RPT_RCPT_NO'),l_Receipt#_len,'TITLE')||' '||
      GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_BPD_ADV_MNY_RPT_RCPT_DT'),l_Receipt_Date_len,'TITLE')||' '||
      GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_BPD_ADV_MNY_RPT_RCPT_AMNT'),l_Receipt_Amount_len,'TITLE')||' '||
      GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_BPD_ADV_MNY_RPT_CUST_NAME'),l_Customer_Name_len,'TITLE')||' '||
      GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_BPD_ADV_MNY_RPT_CUST_NO'),l_Customer#_len,'TITLE')||' '||
      GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_BPD_ADV_MNY_RPT_ACCNT_BLNC'),l_Account_Balance_len,'TITLE')||' '||
      GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_BPD_ADV_MNY_RPT_CNTRCT_NO'),l_Contract_Number_len,'TITLE'));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('=', l_length_till_invc , '=' ));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');

     -- start report Unapplied Receipts
      FOR r_unappld_rcpts IN C_unappld_Rcpts(l_from_date,l_to_date) LOOP
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,GET_PROPER_LENGTH(r_unappld_rcpts.check_number,l_Receipt#_len,'DATA')||' '||
        GET_PROPER_LENGTH(r_unappld_rcpts.receipt_date,l_Receipt_Date_len,'DATA')||' '||
        GET_PROPER_LENGTH(okl_accounting_util.format_amount(r_unappld_rcpts.remittance_amount,r_unappld_rcpts.currency_code)
        ,l_Receipt_Amount_len,'DATA')||' '||
        GET_PROPER_LENGTH(r_unappld_rcpts.NAME,l_Customer_Name_len,'DATA')||' '||
        GET_PROPER_LENGTH(r_unappld_rcpts.customer_number,l_Customer#_len,'DATA')||' '||
        GET_PROPER_LENGTH(okl_accounting_util.format_amount(r_unappld_rcpts.amount,r_unappld_rcpts.currency_code)
        ,l_Receipt_Amount_len,'DATA')||' '||
        GET_PROPER_LENGTH(r_unappld_rcpts.contract_number,l_Contract_Number_len,'DATA'));
      END LOOP;
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(' ', l_total_length , ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', l_length_till_invc , '-' ));
  END IF;

EXCEPTION
    WHEN OTHERS THEN
       p_errbuf := SQLERRM;
       p_retcode := 2;

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLERRM);

       IF (SQLCODE <> -20001) THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
         --APP_EXCEPTION.RAISE_EXCEPTION;
          RAISE;
        ELSE
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
          --g_error_message := Sqlerrm;
          APP_EXCEPTION.RAISE_EXCEPTION;
       END IF;

END do_report;

-- Function for length formatting

FUNCTION  GET_PROPER_LENGTH(p_input_data          IN   VARCHAR2,
                            p_input_length        IN   NUMBER,
				    p_input_type          IN   VARCHAR2)
RETURN VARCHAR2

IS

x_return_data VARCHAR2(1000);

BEGIN

IF (p_input_type = 'TITLE') THEN
    IF (p_input_data IS NOT NULL) THEN
     x_return_data := RPAD(SUBSTR(ltrim(rtrim(p_input_data)),1,p_input_length),p_input_length,' ');
    ELSE
     x_return_data := RPAD(' ',p_input_length,' ');
    END IF;
ELSE
    IF (p_input_data IS NOT NULL) THEN
         IF (length(p_input_data) > p_input_length) THEN
             x_return_data := SUBSTR(p_input_data,1,p_input_length);
         ELSE
             x_return_data := RPAD(p_input_data,p_input_length,' ');
         END IF;
    ELSE
         x_return_data := RPAD(' ',p_input_length,' ');
    END IF;
END IF;

RETURN x_return_data;

END GET_PROPER_LENGTH;

END okl_bpd_adv_mon_rpt_pvt;

/
