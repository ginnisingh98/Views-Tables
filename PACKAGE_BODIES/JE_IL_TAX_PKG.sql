--------------------------------------------------------
--  DDL for Package Body JE_IL_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_IL_TAX_PKG" 
-- $Header: jeilwhtapb.pls 120.11.12010000.15 2010/05/04 06:51:18 spasupun ship $
AS

	--------------------------------------------------------------------------------
	-- constant for first party details
	--------------------------------------------------------------------------------
	C_FIRST_PARTY_QUERY VARCHAR2(8000) :=
	'SELECT
	    JE_IL_TAX_PKG.IS_NUMBER(max(decode(person_last_name, ''TN'', person_first_name)),''DFN'') Deduction_File_Number,
	    JE_IL_TAX_PKG.IS_NUMBER(max(decode(person_last_name, ''TM'', person_first_name)),''CTPID'') Tax_Payer_ID,
	    max(decode(q1.le_role ,''Legal Contact'',email_address,null)) Email,
	    ''96'' Type_Code,
	    :P_Manual_Rpt_Exist P_Manual,
	    :P_Comp_Rpt_Exist P_Complimentary_Rpt,
	    :P_Payer_Position P_Payer_Pos
	FROM hz_parties,
	    (SELECT subject_id ,XLE_CONTACT_GRP.concat_contact_roles (subject_id,object_id) le_role
	      FROM hz_relationships
	      WHERE object_id = (
	                SELECT party_id
	                FROM xle_firstparty_information_v
	                WHERE legal_entity_id = :P_Legal_Entity_ID
	                )
	AND relationship_code = ''CONTACT_OF''
	AND directional_flag = ''F'' ) q1
	WHERE party_id = q1.subject_id';

	C_FIRST_PARTY_NULL_QUERY  VARCHAR2(2000) :=
	'SELECT NULL Deduction_File_Number, NULL Tax_Payer_ID,
	    NULL Email, NULL Type_Code, NULL P_Manual,
	    NULL P_Complimentary_Rpt, NULL P_Payer_Pos
	FROM DUAL';


	--------------------------------------------------------------------------------
	-- constant for payment details
	--------------------------------------------------------------------------------
	C_PAYMENT_INFO_QUERY VARCHAR2(8000) :=
	'SELECT aag.name awt_group_name, ''A'' awt_flag
	FROM ap_invoices_all ai,
	  ap_invoice_payments_all aip,
	  ap_awt_groups aag,
	  ap_checks_all ac
	WHERE ac.check_id = :check_id
	 AND ac.check_id = aip.check_id
	 AND aip.invoice_id = ai.invoice_id
         AND aag.group_id = nvl(ai.awt_group_id, ai.pay_awt_group_id)
	 AND rownum = 1';

	C_PAYMENT_INFO_NULL_QUERY  VARCHAR2(1000) :=
	'SELECT NULL awt_group_name, NULL awt_flag FROM DUAL';

	--------------------------------------------------------------------------------
	-- constant for vendor balance details
	--------------------------------------------------------------------------------
	C_VENDOR_BALANCE_QUERY VARCHAR2(8000) :=
	'SELECT (SUM(acctd_rounded_cr) - SUM(acctd_rounded_dr)) vendor_balance,
	  party_id vendor_id3,
	  party_site_id vendor_site_id3
	FROM xla_trial_balances
	WHERE party_id = :vendor_id2
	 AND party_site_id = :vendor_site_id2
	 AND ledger_id = :p_ledger_id
	 AND definition_code IN
	  (SELECT definition_code
	   FROM xla_tb_definitions_b
	   WHERE ledger_id = :p_ledger_id)
	AND gl_date BETWEEN :p_start_date AND :p_end_date
	GROUP BY party_site_id, party_id
	HAVING(SUM(acctd_rounded_cr) - SUM(acctd_rounded_dr)) > 0';

	C_VENDOR_BALANCE_NULL_QUERY  VARCHAR2(1000) :=
	'SELECT NULL vendor_balance, NULL vendor_id3, NULL vendor_site_id3 FROM DUAL';

	--------------------------------------------------------------------------------
	-- constant for AWT Tax Rate Details
	--------------------------------------------------------------------------------
	C_AWT_TAXRATES_QUERY VARCHAR2(8000) :=
	'SELECT vendor_site_id rate_site_id,
	  tax_name tax_name,
	  tax_rate tax_rate,
	  to_char(start_date,   ''DD-MON-YYYY'') start_date1,
	  to_char(end_date,   ''DD-MON-YYYY'') end_date1,
	  comments comments
	FROM ap_awt_tax_rates_all
	WHERE vendor_site_id = :vendor_site_id2 ';

	C_AWT_TAXRATES_NULL_QUERY  VARCHAR2(1000) :=
	'SELECT NULL rate_site_id, NULL tax_name,
	  NULL tax_rate, NULL start_date1,
	  NULL end_date1, NULL comments
	FROM DUAL';

	--------------------------------------------------------------------------------
	-- constant for count lines
	--------------------------------------------------------------------------------
	C_COUNT_LINES_QUERY VARCHAR2(8000);

	C_COUNT_LINES_NULL_QUERY  VARCHAR2(1000) :=
	'SELECT NULL count_lines FROM DUAL';

	--------------------------------------------------------------------------------
	-- constant for count vendor
	--------------------------------------------------------------------------------
	C_COUNT_VENDORS_QUERY VARCHAR2(8000);

	C_COUNT_VENDORS_NULL_QUERY  VARCHAR2(1000) :=
	'SELECT NULL Count_Vendors FROM DUAL';

  /*
  REM +======================================================================+
  REM Name: IS_NUMBER
  REM
  REM Description: This function is called in the query Q_FIRST_PARTY ,Q_VENDOR_SITE
  REM              of data template, for validating the Deduction File Number and
  REM		   Taxpayer Id of the company and Taxpayer id of the supplier.
  REM
  REM Parameters:
  REM            p_str1 :  String needs to be validated.
  REM            p_str2 :  Idenfies the type of validating string.
  REM
  REM +======================================================================+
  */

 FUNCTION IS_NUMBER (p_str1 VARCHAR2,p_str2 VARCHAR2) RETURN VARCHAR2 IS

    n           NUMBER;

  BEGIN

   n := TO_NUMBER(p_str1);
   RETURN p_str1;

  EXCEPTION
  WHEN OTHERS THEN
    IF p_str2 = 'DFN' THEN
	    fnd_message.set_name('JE', 'JE_IL_INVALID_DFN');
	    fnd_file.put_line(fnd_file.log,fnd_message.get);
    ELSIF p_str2 = 'CTPID' THEN
	    fnd_message.set_name('JE', 'JE_IL_INVALID_TAXPAYER_ID');
	    fnd_file.put_line(fnd_file.log,fnd_message.get);
    ELSE
	    fnd_message.set_name('JE', 'JE_IL_INVALID_SUP_TAXPAYER_ID');
	    fnd_message.set_token('P_VENDOR_NUM',p_str2);
	    fnd_file.put_line(fnd_file.log,fnd_message.get);
    END IF;

    RETURN NULL;

  END IS_NUMBER;


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
  FUNCTION BeforeReport RETURN BOOLEAN IS
   l_currency_code gl_ledgers.currency_code%TYPE;

    BEGIN
    -- Get the profile value FND: Debug Log Enabled to print debug messages
	fnd_debug_log  := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

	-- default values
	p_name_level     := NVL(p_name_level,'NONE');
	p_information_level := NVL(p_information_level,'NONE');
	p_vendor_type := NVL(p_vendor_type,'NONE');
	p_vat_reg_no          := '  ';
	p_vendor_type_col 	  := ' 0 B1, 0 B2 ';
	p_vendor_type_cond 	  := '  ';
	p_vendor_name_cond 	  := '  ';
	p_vendor_site_cond 	  := '  ';

	--
	-- Identifying primary ledger id
	--
	BEGIN
		SELECT primary_ledger_id
		INTO l_primary_ledger_id
		FROM gl_ledger_relationships
		WHERE target_ledger_id = p_ledger_id
		AND (target_ledger_category_code = 'PRIMARY' OR source_ledger_id <> target_ledger_id)
		AND ROWNUM = 1;
	EXCEPTION
	WHEN OTHERS THEN
	l_primary_ledger_id := 0;
		IF fnd_debug_log = 'Y' THEN
			fnd_file.put_line(fnd_file.log,'Error Message:'||SQLERRM||'Error Code:'||SQLCODE);
		END IF;
	return FALSE;
	END;


	BEGIN

		SELECT currency_code
		 INTO l_currency_code
		FROM gl_ledgers
		WHERE ledger_id = p_ledger_id;

		IF l_currency_code = 'ILS' THEN
			l_currency_check := ' AND 1=1 ';
		ELSE
			l_currency_check := ' AND 1=2 ';
		END IF;
	EXCEPTION

	WHEN OTHERS THEN
	l_currency_code := NULL;
		IF fnd_debug_log = 'Y' THEN
			fnd_file.put_line(fnd_file.log,'Error Message:'||SQLERRM||'Error Code:'||SQLCODE);
		END IF;
	 return FALSE;
	END;



	-- <Vendor name column based on Name Level>
	IF p_name_level = 'VAN' THEN
		p_vendor_name_col := ' pvend.vendor_name_alt vendor_name1, ';
	ELSE
		p_vendor_name_col := ' pvend.vendor_name vendor_name1, ';
	END IF;

	-- <Vendor site code column based on Name Level>
	IF p_name_level = 'VSAN' THEN
		p_vendor_sitecode_col := ' pvs.vendor_site_code_alt vendor_site_code, ';
	ELSE
		p_vendor_sitecode_col := ' pvs.vendor_site_code vendor_site_code, ';
	END IF;

	-- <Columns based on Information Level>
	IF p_information_level = 'S' THEN
		-- Vat registration Num
		p_vat_reg_no := ' (SELECT zx.rep_registration_number
						FROM zx_party_tax_profile zx
					    WHERE pvs.party_site_id = zx.party_id
					    AND zx.party_type_code = ''THIRD_PARTY_SITE''
						AND ROWNUM = 1) vat_reg_no, ';
		-- Flex value condition for IRS Tax officer column
		p_flex_value_cond := ' pvs.global_attribute11 ';
		-- Deduction type
		p_deduction_type_cond := '  pvs.global_attribute17 ';
		-- Exp IRS
		p_exp_irs_cond := 'CASE pvs.GLOBAL_ATTRIBUTE15
		                    WHEN ''1'' THEN 1
				    WHEN ''2'' THEN 2
				    WHEN ''3'' THEN 3
				    WHEN ''9'' THEN 1
				    WHEN ''92'' THEN 2
				    WHEN ''93'' THEN 3
				    WHEN ''21'' THEN 1
				    WHEN ''22'' THEN 2
				    WHEN ''23'' THEN 3
				    ELSE NULL END Exp_IRS';
		-- Supplier Type
		p_supplier_type := 'CASE pvs.GLOBAL_ATTRIBUTE15
		                    WHEN ''1'' THEN 0
				    WHEN ''2'' THEN 0
				    WHEN ''3'' THEN 0
				    WHEN ''9'' THEN 4
				    WHEN ''92'' THEN 4
				    WHEN ''93'' THEN 4
				    WHEN ''21'' THEN 2
				    WHEN ''22'' THEN 2
				    WHEN ''23'' THEN 2
				    ELSE NULL END SUPPLIER_TYPE';

		p_bank_supplier := 'DECODE(pvs.global_attribute17,''08'',
						CASE pvs.global_attribute15
						  WHEN ''9'' THEN 1
						  WHEN ''92'' THEN 1
						  WHEN ''93'' THEN 1
						  ELSE 0 END,0) BANK_SUPPLIER ';

		l_foreign_suppliers_check := ' AND pvs1.global_attribute17 = ''08''
		                               AND pvs1.global_attribute15 in (''9'',''92'',''93'') ';

		-- Business Sector
		p_business_sec_cond := ' pvs.global_attribute14 business_sector, ';
		-- Tax payer ID
		-- p_tax_payerid_cond := ' decode(pvs.global_attribute15,   ''9'',   ''999999999'',   nvl(papf.national_identifier,   nvl(pvend.individual_1099,   pvend.num_1099)))  ';
		   p_tax_payerid_cond := ' CASE pvs.global_attribute15  WHEN ''9'' THEN ''999999999'' WHEN ''92'' THEN ''999999999''  WHEN ''93'' THEN ''999999999'' ELSE  nvl(papf.national_identifier,   nvl(pvend.individual_1099,   pvend.num_1099)) END';
	ELSE
		-- Flex value condition for IRS Tax officer column
		p_flex_value_cond := ' pvend.global_attribute11 ';
		-- Deduction type
		p_deduction_type_cond := '  pvend.global_attribute17 ';
		-- Exp IRS
		p_exp_irs_cond := 'CASE pvend.GLOBAL_ATTRIBUTE15
		                    WHEN ''1'' THEN 1
				    WHEN ''2'' THEN 2
				    WHEN ''3'' THEN 3
				    WHEN ''9'' THEN 1
				    WHEN ''92'' THEN 2
				    WHEN ''93'' THEN 3
				    WHEN ''21'' THEN 1
				    WHEN ''22'' THEN 2
				    WHEN ''23'' THEN 3
				    ELSE NULL END Exp_IRS';
		-- Supplier Type
		p_supplier_type := 'CASE pvend.GLOBAL_ATTRIBUTE15
		                    WHEN ''1'' THEN 0
				    WHEN ''2'' THEN 0
				    WHEN ''3'' THEN 0
				    WHEN ''9'' THEN 4
				    WHEN ''92'' THEN 4
				    WHEN ''93'' THEN 4
				    WHEN ''21'' THEN 2
				    WHEN ''22'' THEN 2
				    WHEN ''23'' THEN 2
				    ELSE NULL END SUPPLIER_TYPE';

		p_bank_supplier := 'DECODE(pvend.global_attribute17,''08'',
						CASE pvend.global_attribute15
						  WHEN ''9'' THEN 1
						  WHEN ''92'' THEN 1
						  WHEN ''93'' THEN 1
						  ELSE 0 END,0) BANK_SUPPLIER ';

		l_foreign_suppliers_check := ' AND pvend1.global_attribute17 = ''08''
		                               AND pvend1.global_attribute15 in (''9'',''92'',''93'') ';

		-- Business Sector
		p_business_sec_cond := ' pvend.global_attribute14 business_sector, ';
		-- Tax payer ID
		-- p_tax_payerid_cond := ' decode(pvend.global_attribute15,   ''9'',   ''999999999'',   nvl(papf.national_identifier,   nvl(pvend.individual_1099,   pvend.num_1099)))  ';

		   p_tax_payerid_cond := ' CASE pvend.global_attribute15 WHEN ''9'' THEN ''999999999'' WHEN ''92'' THEN ''999999999''  WHEN ''93'' THEN ''999999999'' ELSE  nvl(papf.national_identifier,   nvl(pvend.individual_1099,   pvend.num_1099)) END';
	END IF;

	IF p_information_level = 'V' THEN
		-- Vat registration Num
		p_vat_reg_no := ' pvend.vat_registration_num vat_reg_no, ';
		-- Condition on global attribute
		p_global_cond := ' nvl(pvend.global_attribute15,-1) ';
	ELSE
		-- Condition on global attribute
		p_global_cond := ' nvl(pvs.global_attribute15,-1) ';
	END IF;


   -- <conditions based on FROM Supplier Number>
	IF p_from_supplier_number IS NULL THEN
		p_supplier_num_from := ' ';
	ELSE
		p_supplier_num_from := ' AND pvend.segment1 >= '''|| to_char(p_from_supplier_number) ||'''';
	END IF;

   -- <conditions based on TO Supplier Number>
	IF p_to_supplier_number IS NULL THEN
		p_supplier_num_to := ' ';
	ELSE
		p_supplier_num_to := ' AND pvend.segment1 <= '''|| to_char(p_to_supplier_number) ||'''';
	END IF;

   -- Condition based on vendor type
    IF p_vendor_type = 'A' THEN
		 p_vendor_type_col := ' 999 B1, 0 B2 ';
		 p_vendor_type_cond := ' AND ' || p_global_cond || ' in  (''1'',''2'',''3'',''9'',''92'',''93'',''21'',''22'',''23'') ';
	ELSIF p_vendor_type = 'F' THEN
		 p_vendor_type_col := ' 0 B1, 9 B2 ';
		 p_vendor_type_cond := ' AND ' || p_global_cond || ' in  (''9'',''92'',''93'') ';
	ELSIF p_vendor_type = 'O' THEN
		p_vendor_type_col := ' 0 B1, 99 B2 ';
		p_vendor_type_cond := ' AND ' || p_global_cond || ' not in (''9'',''92'',''93'') ';
	END IF;

	-- Condition based on vendor name and vendor site
	IF P_Report_Name = 'JEILWHTR' THEN
		IF P_Vendor_Name IS NOT NULL THEN
		p_vendor_name_cond := ' AND pvend.vendor_id = '''|| P_Vendor_Name ||'''';
		END IF;
		IF P_Vendor_Site IS NOT NULL THEN
		p_vendor_site_cond := ' AND pvs.vendor_site_id = '''|| P_Vendor_Site ||'''';
		END IF;
	END IF;

		--------------------------------------------------------------------------------
		-- constant for count lines
		--------------------------------------------------------------------------------
		C_COUNT_LINES_QUERY :=
		' SELECT SUM(countv) count_lines
		 FROM
		  (SELECT DISTINCT ac.vendor_site_id vendor_site_id2, (
		   CASE
		   WHEN SUM(nvl(nvl(aid.base_amount,    aid.amount) *-1,    0)) < 0
		        OR(SUM(nvl(aip.payment_base_amount,    aip.amount)) +
		        SUM(nvl(nvl(aid.base_amount,    aid.amount) *-1,    0))) < 0
		   THEN 0
		   ELSE 1
		   END) countv
		   FROM ap_invoices_all ai,
		     ap_invoice_distributions_all aid,
		     ap_checks_all ac,
		     ap_invoice_payments_all aip
		  WHERE ai.invoice_id = aid.invoice_id
		   AND ac.check_id = aip.check_id
		   AND aip.invoice_id = ai.invoice_id
		   AND ai.set_of_books_id = ' || l_primary_ledger_id || '
		   AND aid.set_of_books_id = ' || l_primary_ledger_id || '
		   AND ai.legal_entity_id = :p_legal_entity_id
		   AND aid.line_type_lookup_code = ''AWT''
		   AND aid.awt_flag = ''A''
		   AND aid.awt_invoice_payment_id IS NOT NULL
		   AND(aid.accounting_date >= :p_start_date
		   AND aid.accounting_date <= :p_end_date)
		   GROUP BY ac.vendor_site_id) ';

		--------------------------------------------------------------------------------
		-- constant for count vendor
		--------------------------------------------------------------------------------
		C_COUNT_VENDORS_QUERY :=
				'SELECT  SUM(DECODE(SUM(countv), SUM(countt), 1, 0)) Count_Vendors
								FROM po_vendors pvend,
							   po_vendor_sites_all pvs,
							   (SELECT distinct person_id
									,national_identifier
						 FROM PER_ALL_PEOPLE_F WHERE trunc(sysdate) BETWEEN effective_start_date AND effective_end_date) papf,
							  (SELECT distinct ac.vendor_site_id Vendor_Site_IDs,
										   ( CASE
											 WHEN  SUM(NVL(NVL(aid.base_amount,aid.amount)*-1,0)) < 0
											 OR (SUM(NVL(aip.payment_base_amount,aip.amount)) +
											 SUM(NVL(NVL(aid.base_amount,aid.amount)*-1,0))) < 0
												  THEN 0
												  ELSE 1
												  END ) countv,
												  COUNT(distinct(ac.vendor_site_id)) countt
								  FROM  ap_invoices_all 			ai
										   ,ap_invoice_distributions_all 	aid
										   ,ap_checks_all 		ac
										   ,ap_invoice_payments_all 	aip
								  WHERE ai.invoice_id = aid.invoice_id
								  AND ac.check_id=aip.check_id
								  AND aip.invoice_id=ai.invoice_id
								  AND ai.set_of_books_id = ' || l_primary_ledger_id || '
								  AND aid.set_of_books_id = ' || l_primary_ledger_id || '
								  AND ai.legal_entity_id = :P_Legal_Entity_ID
								  AND aid.line_type_lookup_code	= ''AWT''
								  AND ((aid.awt_flag = ''A''
								  AND aid.awt_invoice_payment_id = aip.invoice_payment_id))
								  AND (aid.accounting_date >= :P_START_DATE
								  AND aid.accounting_date <= :P_END_DATE)
							  GROUP BY ac.vendor_site_id
							   UNION
								SELECT distinct ac1.vendor_site_id Vendor_Site_IDs,
					                	   ( CASE
									WHEN  SUM(NVL(aip1.payment_base_amount,aip1.amount)) < 0
									THEN 0
									 ELSE 1
								     END ) countv,
								     COUNT(distinct(ac1.vendor_site_id)) countt
								FROM  AP_INVOICE_PAYMENTS_ALL aip1
								     ,AP_CHECKS_ALL ac1
						                     ,PO_VENDORS pvend1
					                             ,PO_VENDOR_SITES_ALL pvs1
								WHERE aip1.check_id = ac1.check_id
								 AND   aip1.set_of_books_id= ' || l_primary_ledger_id || '
								 AND   ac1.global_attribute_category=''JE.IL.APXPAWKB.CHECKS''
								 AND   NVL(ac1.global_attribute1,0) > 0
								 AND aip1.accounting_date >=:P_START_DATE
								 AND aip1.accounting_date <=:P_END_DATE
						                 AND ac1.vendor_id= pvend1.vendor_id
						                 AND ac1.vendor_site_id = pvs1.vendor_site_id
						                 AND pvend1.vendor_id = pvs1.vendor_id
						                 AND :P_REPORT_NAME = ''JEILWHTT''
								 '|| l_currency_check
								 || l_foreign_suppliers_check|| '
						                 group by ac1.vendor_site_id) q1
				WHERE pvend.vendor_id = pvs.vendor_id
				AND nvl(pvend.employee_id, -99) = papf.person_id (+)
				AND pvs.vendor_site_id = q1.Vendor_Site_IDs
				GROUP BY ' || p_tax_payerid_cond;

	--Condition based on Order By column
	IF P_Order_By = 'T' THEN
		p_order_by_cond := p_tax_payerid_cond || ' Order_By1 ';
	ELSE
		p_order_by_cond := ' pvend.segment1  Order_By1 ';
	END IF;

	IF P_Report_Name = 'JEILWHTT' THEN
      p_first_party_query := C_FIRST_PARTY_QUERY;
	ELSE
      p_first_party_query := C_FIRST_PARTY_NULL_QUERY;
    END IF;

	IF P_Report_Name = 'JEILWHTD' THEN
		p_payment_info_query := C_PAYMENT_INFO_NULL_QUERY;
		p_awt_taxrates_query := C_AWT_TAXRATES_NULL_QUERY;
	ELSE
		p_payment_info_query := C_PAYMENT_INFO_QUERY;
		p_awt_taxrates_query := C_AWT_TAXRATES_QUERY;
	END IF;

	IF P_Report_Name = 'JEILWHTR' THEN
		p_vendor_balance_query := C_VENDOR_BALANCE_NULL_QUERY;
		p_count_lines_query := C_COUNT_LINES_NULL_QUERY;
		p_count_vendors_query := C_COUNT_VENDORS_NULL_QUERY;
	ELSE
		p_vendor_balance_query := C_VENDOR_BALANCE_QUERY;
		p_count_lines_query := C_COUNT_LINES_QUERY;
		p_count_vendors_query := C_COUNT_VENDORS_QUERY ;
	END IF;

	IF P_Report_Name = 'JEILWHTT' THEN

		 BEGIN
		   SELECT period_set_name
			INTO l_period_set_name
		   FROM gl_ledgers
		   WHERE ledger_id = l_primary_ledger_id;

       l_period_set_name := ''''||l_period_set_name||'''';

		EXCEPTION
		WHEN OTHERS THEN
		l_period_set_name := NULL;
		IF fnd_debug_log = 'Y' THEN
			fnd_file.put_line(fnd_file.log,'Error Message:'||SQLERRM||'Error Code:'||SQLCODE);
		END IF;
		RETURN FALSE;
		END;

	END IF;


	RETURN TRUE;

  END BeforeReport;
/*
 REM +======================================================================+
 REM Name: get_amounts
 REM
 REM Description: This function is called from get_gross_amount Function
 REM              This functions fetches the Payment + Withholding Amount for
 REM              a given Ledger ID from SLA tables.
 REM              It also gets the AWT amounts, for Withholdings created at
 REM              different scenarios from SLA tables
 REM Parameters:  InvoiceID, Accounting Start and End Date, Payment Void or Not
 REM +======================================================================+
 */
 FUNCTION get_amounts (pn_invoice_id NUMBER,pn_check_id NUMBER,pd_start_date DATE, pd_end_date DATE, pv_void NUMBER ) RETURN NUMBER
 IS
 ln_invoice_id NUMBER;
 ln_gross_amount NUMBER;
 ln_awt_amount NUMBER;
 ln_invoice_amount NUMBER;
 ln_event_id NUMBER;
 ln_pay_invoice_id NUMBER;
 ln_awt_event NUMBER;
 ln_sign NUMBER;
 lv_invoice_type VARCHAR2(20);
 --Bug 9151599 Modified cursors c_get_gross and c_get_gross_void
 ln_bank_awt_amount NUMBER;
 ln_bank_awt_check NUMBER := -1;

 CURSOR c_get_gross IS
 SELECT xlah.event_id pay_event_id ,
        aip.invoice_id invoice_id,
       SUM(xdln.unrounded_accounted_dr) gross_amount
	   FROM (select distinct a.invoice_id,a.accounting_event_id  from ap_invoice_payments_all a
	        WHERE   a.invoice_id  = pn_invoice_id
     	    AND a.check_id    = pn_check_id
            AND a.accounting_date >= pd_start_date
			AND a.accounting_date  <= pd_end_date
            AND a.reversal_inv_pmt_id IS NULL) aip,
         xla_ae_lines   xdln     ,
         xla_ae_headers   xlah
            WHERE aip.accounting_event_id = xlah.event_id
			AND xlah.application_id     = xdln.application_id
            AND xdln.unrounded_accounted_dr      IS NOT NULL
            AND xlah.ae_header_id                 = xdln.ae_header_id
            AND xlah.ledger_id                    = p_ledger_id
            AND xlah.accounting_entry_status_code = 'F'
        GROUP BY xlah.event_id,
             aip.invoice_id;

 CURSOR c_get_gross_void IS
 SELECT xlah.event_id pay_event_id ,
        aip.invoice_id invoice_id,
       SUM(xdln.unrounded_accounted_dr) gross_amount
	   FROM (select distinct a.invoice_id,a.accounting_event_id  from ap_invoice_payments_all a
	        WHERE   a.invoice_id  = pn_invoice_id
     	    AND a.check_id    = pn_check_id
            AND a.accounting_date >= pd_start_date
			AND a.accounting_date  <= pd_end_date
            AND a.reversal_inv_pmt_id IS NOT NULL) aip,
         xla_ae_lines   xdln     ,
         xla_ae_headers   xlah
            WHERE aip.accounting_event_id = xlah.event_id
		 AND xlah.application_id     = xdln.application_id
         AND xdln.unrounded_accounted_dr IS NOT NULL
         AND xlah.ae_header_id                 = xdln.ae_header_id
         AND xlah.ledger_id                    = p_ledger_id
         AND xlah.accounting_entry_status_code = 'F'
       GROUP BY xlah.event_id   ,
                aip.invoice_id;

 CURSOR c_get_payevent_awt(cn_invoice_id NUMBER, cn_event_id NUMBER) IS
 SELECT xlah.event_id event,
       SUM(NVL(xdln.unrounded_accounted_dr,xdln.unrounded_accounted_cr)) pay_amount
    FROM xla_ae_lines   xdln,
         xla_ae_headers   xlah     ,
	 ap_invoice_payments_all aip
        WHERE  aip.invoice_id             = cn_invoice_id
          AND aip.check_id                = pn_check_id
          AND aip.accounting_event_id     = cn_event_id
          AND (xdln.unrounded_accounted_dr      IS NOT NULL
                 OR
               xdln.unrounded_accounted_cr      IS NOT NULL)
		AND xlah.application_id     = xdln.application_id
	    AND xlah.ae_header_id         = xdln.ae_header_id
	    AND xdln.accounting_class_code  ='AWT'
        AND xlah.event_id                     = aip.accounting_event_id
        AND xlah.ledger_id                    = p_ledger_id
        AND xlah.accounting_entry_status_code = 'F'
        GROUP BY
	     xlah.event_id;

 CURSOR c_get_invwht_check (cn_invoice_id NUMBER) IS
 SELECT ai.invoice_id invoice_id
	FROM  ap_invoice_payments_all aip,
	      ap_invoice_distributions_all aid,
	      ap_invoices_all ai
		WHERE   ai.invoice_id = cn_invoice_id
			AND ai.invoice_id = aip.invoice_id
			AND aip.invoice_id = aid.invoice_id
			AND aid.line_type_lookup_code  = 'AWT'
			AND aip.accounting_event_id = aid.accounting_event_id
            AND ROWNUM =1;

 CURSOR c_get_invevent_awt(cn_invoice_id NUMBER) IS
 SELECT xdln.event_id    event,
       SUM(xdln.unrounded_accounted_dr) pay_amount
    FROM ap_invoice_distributions_all aid ,
         xla_distribution_links   xdln,
         xla_ae_headers     xlah
        WHERE  aid.invoice_id = cn_invoice_id
            AND aid.line_type_lookup_code  = 'AWT'
			AND xlah.application_id     = xdln.application_id
            AND xdln.event_id                     = aid.accounting_event_id
            AND xdln.unrounded_accounted_dr      IS NOT NULL
            AND xlah.ae_header_id                 = xdln.ae_header_id
            AND xlah.event_id                     = xdln.event_id
            AND xlah.ledger_id                    = p_ledger_id
            AND xdln.source_distribution_id_num_1 = aid.invoice_distribution_id
            AND xlah.accounting_entry_status_code = 'F'
            AND xdln.source_distribution_type='AP_INV_DIST'
        GROUP BY xdln.event_id;

 CURSOR c_get_bank_awt IS
 SELECT TO_NUMBER(ac.global_attribute1) bank_wht_amount
 FROM AP_CHECKS_ALL ac
      ,PO_VENDORS pv
      ,PO_VENDOR_SITES_ALL pvs
 WHERE ac.check_id =pn_check_id
 AND   ac.vendor_id = pv.vendor_id
 AND   ac.vendor_site_id = pvs.vendor_site_id
 AND   pv.vendor_id = pvs.vendor_id
 AND   ac.global_attribute_category='JE.IL.APXPAWKB.CHECKS'
 AND   ( ( p_information_level = 'V'
           AND pv.global_attribute17 = '08'
           AND pv.global_attribute15 in ('9','92','93'))
	  OR
	  ( p_information_level = 'S'
	    AND pvs.global_attribute17 = '08'
            AND pvs.global_attribute15 in ('9','92','93'))
	);





 BEGIN
 gn_awt_amount := 0;
 gn_invoice_id := -99;
 ln_sign := 1;

 IF pv_void IS NULL THEN

  FOR rec_gross IN c_get_gross
  LOOP
    ln_gross_amount   := rec_gross.gross_amount;
    ln_invoice_id     := rec_gross.invoice_id;
    ln_event_id       := rec_gross.pay_event_id;
  END LOOP;

 ELSE

  FOR rec_gross_void IN c_get_gross_void
  LOOP
    ln_gross_amount   := rec_gross_void.gross_amount;
    ln_invoice_id     := rec_gross_void.invoice_id;
    ln_event_id       := rec_gross_void.pay_event_id;
  END LOOP;

 END IF;

 FOR rec_invwht IN c_get_invwht_check(ln_invoice_id)
 LOOP
   ln_pay_invoice_id :=  rec_invwht.invoice_id;
 END LOOP;

 FOR rec_bank_wht IN c_get_bank_awt
 LOOP
   ln_awt_amount :=  rec_bank_wht.bank_wht_amount;
   ln_bank_awt_check := 1;
 END LOOP;



 IF ln_invoice_id = ln_pay_invoice_id THEN
	FOR rec_payevent_awt IN c_get_payevent_awt(ln_invoice_id,ln_event_id)
	LOOP
   		ln_awt_amount :=  rec_payevent_awt.pay_amount;
   		ln_awt_event  :=  rec_payevent_awt.event;
	END LOOP;
 ELSIF ln_bank_awt_check <> 1 THEN

	BEGIN
		SELECT SUM(xdln.unrounded_accounted_dr) INTO ln_invoice_amount
			FROM ap_invoice_distributions_all aid ,
			     xla_distribution_links    xdln,
                             xla_ae_headers    xlah
		WHERE aid.invoice_id = ln_invoice_id
                AND aid.line_type_lookup_code  <> 'AWT'
                AND xdln.event_id                     = aid.accounting_event_id
            	AND xdln.unrounded_accounted_dr      IS NOT NULL
				AND xlah.application_id     = xdln.application_id
            	AND xlah.ae_header_id                 = xdln.ae_header_id
            	AND xlah.event_id                     = xdln.event_id
            	AND xlah.ledger_id                    = p_ledger_id
            	AND xdln.source_distribution_id_num_1 = aid.invoice_distribution_id
            	AND xlah.accounting_entry_status_code = 'F'
				AND xdln.source_distribution_type = 'AP_INV_DIST';
	EXCEPTION
	WHEN others THEN
        ln_invoice_amount := 0;
		IF fnd_debug_log = 'Y' THEN
			fnd_file.put_line(fnd_file.log,'Error Message:'||SQLERRM||'Error Code:'||SQLCODE);
		END IF;
	END;

	FOR rec_invevent_awt IN c_get_invevent_awt(ln_invoice_id)
	LOOP
   		ln_awt_amount :=  (rec_invevent_awt.pay_amount*ln_gross_amount)/(ln_invoice_amount-rec_invevent_awt.pay_amount);
   		ln_awt_event  :=  rec_invevent_awt.event;
   		ln_gross_amount := ln_gross_amount + NVL(ln_awt_amount,0);
	END LOOP;

	IF fnd_debug_log = 'Y' THEN
		fnd_file.put_line(fnd_file.log,'Return from Cursor c_get_invevent_awt:Invoice ID:'||ln_invoice_id||'Amount:'||ln_gross_amount);
	END IF;

 END IF;

 BEGIN
 IF ln_invoice_id = ln_pay_invoice_id or ln_bank_awt_check = 1 THEN

    SELECT SIGN(SUM(NVL(aip.payment_base_amount,aip.amount))) INTO ln_sign
        FROM ap_invoice_payments_all aip
            WHERE aip.accounting_event_id = ln_event_id;
 ELSE

    SELECT SIGN(NVL(aip.payment_base_amount,aip.amount)) INTO ln_sign
        FROM ap_invoice_payments_all aip
    WHERE aip.invoice_id = ln_invoice_id
    AND aip.accounting_event_id = ln_event_id;

 END IF;

 EXCEPTION
 WHEN others THEN
 ln_sign := 1;
END;

ln_gross_amount := ln_gross_amount * ln_sign;

 BEGIN
 SELECT invoice_type_lookup_code INTO lv_invoice_type
   FROM ap_invoices_all WHERE invoice_id = ln_invoice_id;
 EXCEPTION
 WHEN others THEN
 lv_invoice_type := 'STANDARD';
 END;

 IF lv_invoice_type = 'CREDIT' THEN
   ln_awt_amount := 0;
 ELSE
   IF pv_void IS NULL THEN
     ln_awt_amount := ln_awt_amount;
   ELSE
     ln_awt_amount := ln_awt_amount * (-1);
   END IF;
 END IF;

 gn_awt_amount := NVL(ln_awt_amount,0);
 gn_invoice_id := NVL(ln_invoice_id,-99);
	IF fnd_debug_log = 'Y' THEN
		fnd_file.put_line(fnd_file.log,'Return 1:'||ln_gross_amount);
		fnd_file.put_line(fnd_file.log,'Return 2:'||gn_awt_amount);
	END IF;
 RETURN ln_gross_amount;
 END get_amounts;
   /*
 REM +======================================================================+
 REM Name: get_gross_amount
 REM
 REM Description: This function is called from XML query Q_PAYMENTS
 REM              This functions fetches the Payment + Withholding Amount for
 REM              a given Ledger ID from SLA tables by making a call to get_amounts.
 REM Parameters:  InvoiceID, Accounting Start and End Date, Payment Void or Not
 REM +======================================================================+
 */
 FUNCTION get_gross_amount(pn_invoice_id NUMBER,pn_check_id NUMBER,pd_start_date DATE, pd_end_date DATE, pv_void NUMBER)
 RETURN NUMBER
 IS
 vn_ret_gross NUMBER;
 ln_pay_invoice_id NUMBER;
 i number;
 t number;
 ln_invoice_id number;
 ln_check_id number;
 v_tot_cnt number;   -- Bug 8548767
 v_cre_cnt number;   -- Bug 8548767
 v_temp varchar2(1); -- Bug 8548767
 CURSOR c_get_invwht_check (cn_invoice_id NUMBER) IS
 SELECT ai.invoice_id invoice_id
	FROM  ap_invoice_payments_all aip,
	      ap_invoice_distributions_all aid,
	      ap_invoices_all ai
		WHERE   ai.invoice_id = cn_invoice_id
			AND ai.invoice_id = aip.invoice_id
			AND aip.invoice_id = aid.invoice_id
			AND aid.line_type_lookup_code  = 'AWT'
			AND aip.accounting_event_id = aid.accounting_event_id
            AND ROWNUM =1;

 BEGIN
    BEGIN

   t :=0;

   for i in 1..t_check_inv.count loop

    if t_check_inv(i).check_id = pn_check_id then
       t := 1;
       ln_check_id := t_check_inv(i).check_id;
       ln_invoice_id := t_check_inv(i).invoice_id;
    end if;

   end loop;

  EXCEPTION
  WHEN others THEN
   ln_check_id := NULL;
   ln_invoice_id := NULL;
  END;

  if t=0 then
       ln_check_id := NULL;
       ln_invoice_id := NULL;
  end if;


  FOR rec_invwht IN c_get_invwht_check(pn_invoice_id)
  LOOP
   ln_pay_invoice_id :=  rec_invwht.invoice_id;
  END LOOP;


  IF ln_pay_invoice_id = pn_invoice_id THEN
	IF fnd_debug_log = 'Y' THEN
		fnd_file.put_line(fnd_file.log,'pn_check_id :'||pn_check_id);
		fnd_file.put_line(fnd_file.log,'gn_check_id :'||gn_check_id);
		fnd_file.put_line(fnd_file.log,'pn_invoice_id :'||pn_invoice_id);
		fnd_file.put_line(fnd_file.log,'gn_invoice_id :'||gn_invoice_id);
	END IF;
     IF ( (NVL(ln_check_id,-99) =  pn_check_id ) and (nvl(ln_invoice_id,-99) <> pn_invoice_id)) THEN
      gn_awt_amount :=0;
		IF fnd_debug_log = 'Y' THEN
			fnd_file.put_line(fnd_file.log,'Returning gross amt as 0 for second ');
		END IF;
      RETURN 0;
     END IF;
  END IF;

    BEGIN

/* Bug 8548767 Start
   If there are more than one invoice corresponding to a check_id,if credit memo invoice happens to be first
   invoice that gets picked then AWT amount will be 0 for always.

   So modified code as below

   If credit memo invoice is picked first then do not put that on the PL/SQL table.
   Bye pass it similar to code above.If not process it normally.
*/

if t=0 then

	select count(1) into v_tot_cnt from ap_invoices_all where invoice_id in (
	select invoice_id from ap_invoice_payments_all where check_id = pn_check_id);

	select count(1) into v_cre_cnt from ap_invoices_all where invoice_id in (
	select invoice_id from ap_invoice_payments_all where check_id = pn_check_id)
	and INVOICE_TYPE_LOOKUP_CODE = 'CREDIT';

	if nvl(v_tot_cnt,0) > nvl(v_cre_cnt,0) then
		begin
			select 'N' into v_temp from ap_invoices_all where invoice_id = pn_invoice_id
			and INVOICE_TYPE_LOOKUP_CODE = 'CREDIT';
		exception when others then
			v_temp := 'Y';
		end;
		if v_temp = 'N' then
			gn_awt_amount :=0;
			return 0;
		end if;
	--elsif nvl(v_tot_cnt,0) = nvl(v_cre_cnt,0) then
	else
		v_temp := 'Y';
	end if;

	if v_temp = 'Y' then

		t_check_inv(t_check_inv.count+1).check_id:=pn_check_id;
		t_check_inv(t_check_inv.count).invoice_id:=pn_invoice_id;

	end if;

end if;
-- Bug 8548767 End

        vn_ret_gross := NVL(get_amounts(pn_invoice_id,pn_check_id, pd_start_date, pd_end_date,pv_void),0);
    EXCEPTION
    WHEN others THEN -- Don't Error out the report. Display 0
        vn_ret_gross := 0;
		IF fnd_debug_log = 'Y' THEN
			fnd_file.put_line(fnd_file.log,'Error Message:'||SQLERRM||'Error Code:'||SQLCODE);
		END IF;
    END;
	IF fnd_debug_log = 'Y' THEN
		fnd_file.put_line(fnd_file.log,'Return gross:'||vn_ret_gross);
	END IF;
    RETURN vn_ret_gross;
 END get_gross_amount;
   /*
 REM +======================================================================+
 REM Name: get_amounts
 REM
 REM Description: This function is called from XML query Q_PAYMENTS
 REM              This functions fetches the Withholding Amount for
 REM              a given Ledger ID from SLA tables.
 REM              When get_amounts is called from get_gross_amount
 REM              it fetches the AWT data and updates the Global Varieble
 REM              gn_awt_amount. This function fetches data from this GT Varieble
 REM Parameters:  InvoiceID, Accounting Start and End Date, Payment Void or Not
 REM +======================================================================+
 */
 FUNCTION get_awt_amount
 RETURN NUMBER
 IS
 vn_ret_awt NUMBER;
 BEGIN
        vn_ret_awt := NVL(gn_awt_amount,0);
		IF fnd_debug_log = 'Y' THEN
			fnd_file.put_line(fnd_file.log,'Return awt:'||vn_ret_awt);
		END IF;
 RETURN vn_ret_awt;
 END get_awt_amount;
   /*
 REM +======================================================================+
 REM Name: get_invoice_id
 REM
 REM Description: This function is called from XML query Q_PAYMENTS
 REM              This functions fetches the Valid Invoice Id
 REM              which passed the validation in the Cursor c_get_gross
 REM              of the function get_amounts
 REM Parameters:  InvoiceID, Accounting Start and End Date, Payment Void or Not
 REM +======================================================================+
 */
 FUNCTION get_invoice_id
 RETURN NUMBER
 IS
 vn_ret_invoice_id NUMBER;
 BEGIN
        vn_ret_invoice_id := NVL(gn_invoice_id,-99);
		IF fnd_debug_log = 'Y' THEN
			fnd_file.put_line(fnd_file.log,'Return Invoice:'||vn_ret_invoice_id);
		END IF;
 RETURN vn_ret_invoice_id;
 END get_invoice_id;

END JE_IL_TAX_PKG;

/
