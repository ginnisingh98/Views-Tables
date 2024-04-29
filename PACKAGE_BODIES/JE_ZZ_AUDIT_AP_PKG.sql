--------------------------------------------------------
--  DDL for Package Body JE_ZZ_AUDIT_AP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_ZZ_AUDIT_AP_PKG" 
-- $Header: jezzauditapb.pls 120.13.12010000.6 2009/04/27 13:43:13 rshergil ship $
AS

/*
REM +======================================================================+
REM Name: BeforeReport
REM
REM Description: This function is called before the data template is processed
REM              and sets all the required variables and populates the data in
REM              the required tmp tables.
REM
REM Parameters:
REM
REM +======================================================================+
*/
  FUNCTION BeforeReport RETURN BOOLEAN IS
  BEGIN

    DECLARE
      l_functcurr     VARCHAR2(15);

      l_curr_name     VARCHAR2(40);
      l_real_inv_amt  NUMBER;
      l_payment_amt   NUMBER;
      l_txbl_disc_amt NUMBER;
      l_txbl_amt      NUMBER;
      l_tax_disc_amt  NUMBER;
      l_txbl_amt2     NUMBER;
      l_rec_tax_amt   NUMBER;
      l_tax_amt       NUMBER;
      l_item_tax_amt  NUMBER;
      l_coaid         NUMBER;
      l_ledger_name   VARCHAR2(30);
      l_errbuf        VARCHAR2(132);
      l_errbuf2       VARCHAR2(132);
      l_ledger_id     NUMBER;
      l_start_date    DATE;
      l_end_date      DATE;
      l_prt_inv_amt   NUMBER;
      l_address_line_1                VARCHAR (240);
      l_address_line_2                VARCHAR (240);
      l_address_line_3                VARCHAR (240);
      l_address_line_4                VARCHAR (240);
      l_city                          VARCHAR (60);
      l_company_name                  VARCHAR (240);
      l_contact_name                  VARCHAR (360);
      l_country                       VARCHAR (60);
      l_func_curr                     VARCHAR (30);
      l_legal_entity_name             VARCHAR (240);
      l_period_end_date               DATE;
      l_period_start_date             DATE;
      l_phone_number                  VARCHAR (40);
      l_postal_code                   VARCHAR (60);
      l_registration_num              VARCHAR (30);
      l_reporting_status              VARCHAR (60);
      l_tax_payer_id                  VARCHAR (60);
      l_tax_registration_num          VARCHAR (240);
      l_tax_regime                    VARCHAR2(240);
      l_entity_identifier             VARCHAR2(360);
      l_trx_ccid                      NUMBER;
      l_tax_ccid                      NUMBER;
      l_acc_no                        VARCHAR2(25);
      l_company                       VARCHAR2(25);
      errbuf			      VARCHAR2(1000);
      INVALID_LEDGER		      EXCEPTION;
      l_company_desc                  VARCHAR2(240);
      -- Added for GLOB-006 ER
      l_province                      VARCHAR2(120);
      l_comm_num                      VARCHAR2(30);
      l_vat_reg_num                   VARCHAR2(50);
      -- end here


      CURSOR company_info IS
	SELECT DISTINCT jg_info_v5
	FROM jg_zz_vat_trx_gt;

      CURSOR C_GENERIC(p_start_date DATE, p_end_date DATE) IS
        SELECT SUBSTR(ven.vendor_name, 1, 10)                       ven_name
              ,SUBSTR(ven.segment1, 1, 8)                           ven_no
              ,inv.invoice_type_lookup_code                         inv_type
              ,SUM(nvl(dis.base_amount, dis.amount))                tax_amt
              ,item.tax_recovery_rate                               rec_per
              ,NULL                                                 company
              ,NULL                                                 acc_no
              ,tax.percentage_rate                                  tax_rate
              ,tax.tax_rate_id                                      tax_id
              ,tax.offset_tax_rate_code                             offset_tax_rate_code
              ,inv.global_attribute1                                tax_type
              ,SUBSTR(inv.invoice_num, 1, 10)                       inv_no
              ,MIN(dis.accounting_date)                             acc_date
              ,inv.invoice_id                                       invoice_id
              ,inv.cancelled_date                                   cancelled_date
              ,COUNT(dis.charge_applicable_to_dist_id)              item_line_cnt
              ,MAX(dis.charge_applicable_to_dist_id)                charge_dist_id
              ,chk.void_date                                        check_void_date
              ,SUM(NVL(aip.invoice_base_amount, aip.amount))        pay_amt
              ,dis.line_type_lookup_code                            line_type_lookup_code
              ,item.line_type_lookup_code                           line_type_lookup_code_item
              ,ppdis.line_type_lookup_code                          line_type_lookup_code_prepay
              ,item.reversal_flag                                   reversal_flag_item
              ,aip.reversal_flag                                    reversal_flag_pay
              ,ppdis.reversal_flag                                  reversal_flag_prepay
              ,dis.parent_reversal_id                               parent_reversal_id
              ,inv.base_amount                                      base_amount
              ,inv.invoice_amount                                   invoice_amount
              ,chk.void_date                                        void_date
              ,chk.future_pay_due_date                              future_pay_due_date
              ,chk.check_date                                       check_date
              ,inv.payment_status_flag                              payment_status_flag
              ,aip.accounting_date                                  accounting_date
              ,aip.reversal_inv_pmt_id                              reversal_inv_pmt_id
              ,zl.application_id
              ,zl.event_class_code
              ,zl.trx_line_id
              ,zl.entity_code
        FROM   po_vendors               ven
              ,ap_invoices              inv
              ,ap_invoice_distributions dis
              ,zx_rates_b               tax
              ,ap_invoice_distributions item
              ,ap_invoices              pp
              ,ap_invoice_distributions ppdis
              ,ap_checks                chk
              ,ap_invoice_payments      aip
              ,ap_invoice_lines         apl
              ,zx_lines                 zl
              ,zx_lines_det_factors     zldf
	WHERE  ( ( P_LEDGER_ID IS NULL AND P_COMPANY IS NULL AND inv.legal_entity_id = G_LE_ID )
	  OR  ( P_LEDGER_ID IS NOT NULL AND P_COMPANY IS NULL AND inv.set_of_books_id = P_LEDGER_ID )
          OR  ( P_COMPANY IS NOT NULL AND inv.set_of_books_id = P_LEDGER_ID
		and get_balancing_segment(dis.dist_code_combination_id) = P_COMPANY) )
	AND	ven.vendor_id = inv.vendor_id
        AND    dis.invoice_id = inv.invoice_id
        AND    tax.tax_rate_id = dis.tax_code_id
        AND    dis.charge_applicable_to_dist_id =
               item.invoice_distribution_id
        AND    inv.global_attribute_category = zldf.document_sub_type
--        AND    dis.line_type_lookup_code = 'TAX'
        AND    inv.invoice_id = apl.invoice_id
        AND    apl.invoice_id = zl.trx_id
        AND    apl.line_number = zl.trx_line_number
        AND    apl.application_id = zl.application_id
        AND    zl.entity_code = 'AP_INVOICES'
        AND    inv.invoice_type_lookup_code = zl.event_class_code
        AND    dis.invoice_line_number = apl.line_number
        AND    zl.application_id = zldf.application_id
        AND    zl.event_class_code = zldf.event_class_code
        AND    zl.entity_code = zldf.entity_code
        AND    zl.trx_id = zldf.trx_id
        AND    zl.trx_line_id = zldf.trx_line_id
--
        AND    dis.match_status_flag IS NOT NULL
        AND    dis.accounting_date BETWEEN p_start_date AND p_end_date
        AND    dis.tax_recoverable_flag = 'Y'
        AND    item.prepay_distribution_id = ppdis.invoice_distribution_id
        AND    ppdis.invoice_id = pp.invoice_id
        AND    inv.invoice_id = aip.invoice_id
        AND    chk.check_id = aip.check_id
        AND    aip.accounting_date BETWEEN p_start_date AND p_end_date
        GROUP  BY  SUBSTR(ven.vendor_name, 1, 10)
                  ,SUBSTR(ven.segment1, 1, 8)
                  ,inv.invoice_type_lookup_code
                  ,item.tax_recovery_rate
                  ,tax.percentage_rate
                  ,tax.tax_rate_id
                  ,tax.offset_tax_rate_code
                  ,inv.global_attribute1
                  ,SUBSTR(inv.invoice_num, 1, 10)
                  ,inv.invoice_id
                  ,inv.cancelled_date
                  ,chk.void_date
                  ,dis.line_type_lookup_code
                  ,item.line_type_lookup_code
                  ,ppdis.line_type_lookup_code
                  ,item.reversal_flag
                  ,aip.reversal_flag
                  ,ppdis.reversal_flag
                  ,dis.parent_reversal_id
                  ,inv.base_amount
                  ,inv.invoice_amount
                  ,chk.void_date
                  ,chk.future_pay_due_date
                  ,chk.check_date
                  ,inv.payment_status_flag
                  ,aip.accounting_date
                  ,aip.reversal_inv_pmt_id
                  ,zl.application_id
                  ,zl.event_class_code
                  ,zl.trx_line_id
                  ,zl.entity_code;

      CURSOR C_FETCH_LEDGER_INFO IS
        SELECT ledger_id
              ,chart_of_accounts_id
              ,ledger_name
              ,currency_code
        FROM   gl_ledger_le_v
        WHERE  legal_entity_id = G_LE_ID
        AND    ledger_category_code = 'PRIMARY';



      CURSOR C_FETCH_PERIOD IS
        SELECt last_day(add_months((P_REP_DATE),-1))+1 START_DATE,
	       last_day((P_REP_DATE)) END_DATE
	FROM dual;

      CURSOR C_TAX_AMT IS
        SELECT SUM(jg_info_n17) cs_item_tax_amt
              ,jg_info_n8 charge_dist_id
              ,jg_info_n7 item_line_cnt
              ,jg_info_n1 tax_amt
              ,jg_info_n5 invoice_id
              ,jg_info_v8 tax_type
              ,jg_info_v4 inv_type
              ,jg_info_n10 l_real_inv_amt
              ,jg_info_n11 l_txbl_disc_amt
              ,jg_info_n12 l_payment_amt
              ,jg_info_d2 check_void_date
        FROM   JG_ZZ_VAT_TRX_GT
	WHERE  jg_info_v30='JEFRTXDC'
        GROUP  BY jg_info_n8
                 ,jg_info_n7
                 ,jg_info_n1
                 ,jg_info_n5
                 ,jg_info_v8
                 ,jg_info_v4
                 ,jg_info_n10
                 ,jg_info_n11
                 ,jg_info_n12
                 ,jg_info_d2;

      CURSOR c_curr_name (p_functcurr    VARCHAR2)
      IS
        SELECT substr(name, 1, 40) name
              ,precision
        INTO   l_curr_name
              ,g_precision
        FROM   fnd_currencies_vl
        WHERE  currency_code = p_functcurr;

      CURSOR c_inv_less_tax_flag
      IS
        SELECT disc_is_inv_less_tax_flag
        FROM   ap_system_parameters;

      CURSOR c_get_trx_ccid (p_trx_id                     NUMBER
                            ,p_application_id             NUMBER
                            ,p_event_class_code           VARCHAR2
                            ,p_trx_line_id                NUMBER
                            ,p_entity_code                VARCHAR2)
      IS
        SELECT xla_event.event_id
              ,xla_head.ae_header_id
              ,xla_line.code_combination_id
              ,xla_head.period_name
              ,zx_dist.rec_nrec_tax_dist_id
        FROM   zx_lines                 zx_line
              ,zx_lines_det_factors     zx_det
              ,zx_rec_nrec_dist         zx_dist
              ,zx_taxes_vl              zx_tax
              ,zx_rates_vl              zx_rate
              ,xla_transaction_entities xla_ent
              ,xla_events               xla_event
              ,xla_ae_headers           xla_head
              ,xla_ae_lines             xla_line
              ,xla_distribution_links   xla_dist
              ,xla_acct_class_assgns    acs
              ,xla_assignment_defns_b   asd
        WHERE  zx_det.internal_organization_id = zx_line.internal_organization_id
        AND    zx_det.application_id = zx_line.application_id
        AND    zx_det.application_id = 200
        AND    zx_det.entity_code = zx_line.entity_code
        AND    zx_det.event_class_code = zx_line.event_class_code
        AND    zx_det.trx_id = zx_line.trx_id
        AND    zx_line.trx_id = xla_ent.source_id_int_1 -- Accounting Joins
        AND    zx_det.application_id = xla_ent.application_id
        AND    xla_ent.entity_code = 'AP_INVOICES'
        AND    xla_ent.entity_id = xla_event.entity_id
        AND    xla_event.event_id = xla_head.event_id
        AND    xla_head.ae_header_id = xla_line.ae_header_id
        AND    xla_dist.event_id = xla_event.event_id
        AND    acs.program_code = 'TAX_REP_LEDGER_PROCUREMENT'
        AND    acs.program_code = asd.program_code
        AND    asd.assignment_code = acs.assignment_code
        AND    asd.enabled_flag = 'Y'
        AND    acs.accounting_class_code = xla_line.accounting_class_code -- Accounting Joins Enda
        AND    xla_dist.source_distribution_id_num_1 = zx_dist.trx_line_dist_id
        AND    xla_dist.source_distribution_type = 'AP_INVOICE_DISTRIBUTIONS'
        AND    zx_line.tax_line_id = zx_dist.tax_line_id
        AND    zx_det.tax_reporting_flag = 'Y'
        AND    zx_line.tax_id = zx_tax.tax_id
        AND    zx_line.tax_rate_id = nvl(zx_rate.source_id, zx_rate.tax_rate_id)
        AND    zx_line.entity_code = p_entity_code
        AND    zx_line.trx_id = p_trx_id
        AND    zx_line.application_id = p_application_id
        AND    zx_line.event_class_code = p_event_class_code
        AND    zx_line.trx_line_id = p_trx_line_id
        AND    (zx_rate.source_id IS NOT NULL);

      CURSOR c_get_tax_ccid (p_trx_id                     NUMBER
                            ,p_application_id             NUMBER
                            ,p_event_class_code           VARCHAR2
                            ,p_trx_line_id                NUMBER
                            ,p_entity_code                VARCHAR2)
      IS
        SELECT xla_event.event_id
              ,xla_head.ae_header_id
              ,xla_line.code_combination_id
              ,xla_head.period_name
              ,zx_dist.rec_nrec_tax_dist_id
        FROM   zx_lines                 zx_line
              ,zx_lines_det_factors     zx_det
              ,zx_rec_nrec_dist         zx_dist
              ,zx_taxes_vl              zx_tax
              ,zx_rates_vl              zx_rate
              ,xla_transaction_entities xla_ent
              ,xla_events               xla_event
              ,xla_ae_headers           xla_head
              ,xla_ae_lines             xla_line
              ,xla_distribution_links   xla_dist
              ,xla_acct_class_assgns    acs
              ,xla_assignment_defns_b   asd
        WHERE  zx_det.internal_organization_id = zx_line.internal_organization_id
        AND    zx_det.application_id = zx_line.application_id
        AND    zx_det.application_id = 200
        AND    zx_det.entity_code = zx_line.entity_code
        AND    zx_det.event_class_code = zx_line.event_class_code
        AND    zx_det.trx_id = zx_line.trx_id
        AND    zx_line.trx_id = xla_ent.source_id_int_1 -- Accounting Joins
        AND    zx_det.application_id = xla_ent.application_id
        AND    xla_ent.entity_code = 'AP_INVOICES'
        AND    xla_ent.entity_id = xla_event.entity_id
        AND    xla_event.event_id = xla_head.event_id
        AND    xla_head.ae_header_id = xla_line.ae_header_id
        AND    xla_dist.event_id = xla_event.event_id
        AND    acs.program_code = 'TAX_REP_LEDGER_PROCUREMENT'
        AND    acs.program_code = asd.program_code
        AND    asd.assignment_code = acs.assignment_code
        AND    asd.enabled_flag = 'Y'
        AND    acs.accounting_class_code = xla_line.accounting_class_code -- Accounting Joins Enda
        AND    xla_dist.tax_rec_nrec_dist_ref_id = zx_dist.rec_nrec_tax_dist_id
        AND    xla_dist.source_distribution_type = 'AP_INVOICE_DISTRIBUTIONS'
        AND    zx_line.tax_line_id = zx_dist.tax_line_id
        AND    zx_det.tax_reporting_flag = 'Y'
        AND    zx_line.tax_id = zx_tax.tax_id
        AND    zx_line.tax_rate_id = nvl(zx_rate.source_id, zx_rate.tax_rate_id)
        AND    zx_line.entity_code = p_entity_code
        AND    zx_line.trx_id = p_trx_id
        AND    zx_line.application_id = p_application_id
        AND    zx_line.event_class_code = p_event_class_code
        AND    zx_line.trx_line_id = p_trx_line_id
        AND    (zx_rate.source_id IS NOT NULL);

    BEGIN
      BEGIN

	BEGIN
	/* If calling report is AUDIT-AP Non TRL Extract(coomon extract) */

	IF P_CALLING_REPORT = 'JGZZAPAE'  OR P_REPORT_BY='Y' THEN
	BEGIN
		select  cfgd.legal_entity_id,
		        cfg.ledger_id,
			cfg.balancing_segment_value,
			cfg.entity_identifier
		INTO	P_LEGAL_ENTITY_ID,
			P_LEDGER_ID,
			P_COMPANY,
			l_entity_identifier
		from   jg_zz_vat_rep_entities cfg
		      ,jg_zz_vat_rep_entities cfgd
		where  cfg.vat_reporting_entity_id =  P_VAT_REPORTING_ENTITY_ID
		 and ( ( cfg.entity_type_code  = 'ACCOUNTING'
			 and cfg.mapping_vat_rep_entity_id = cfgd.vat_reporting_entity_id
		         )
			 or
		         ( cfg.entity_type_code  = 'LEGAL'
			  and cfg.vat_reporting_entity_id = cfgd.vat_reporting_entity_id
			)
		     );

		SELECT period_start_date,
		       period_end_date
		INTO l_start_date,
		     l_end_date
		FROM  JG_ZZ_VAT_REP_STATUS
		WHERE VAT_REPORTING_ENTITY_ID=P_VAT_REPORTING_ENTITY_ID
		AND TAX_CALENDAR_PERIOD= P_PERIOD
		AND ROWNUM = 1;

               l_period_start_date := l_start_date;
	       l_period_end_date := l_end_date;

	        EXCEPTION
	          WHEN OTHERS THEN
	          fnd_file.put_line(fnd_file.log,' An error occured while extracting the LE ,Ledger and BSV for entered Reporting Identifier. Error : ' || SUBSTR(SQLERRM, 1, 200));
	END;
	END IF;

	  fnd_file.put_line(fnd_file.log,'***Parameters and Locla Variables Values  : ');
          fnd_file.put_line(fnd_file.log,'P_VAT_REPORTING_ENTITY_ID :'||P_VAT_REPORTING_ENTITY_ID );
          fnd_file.put_line(fnd_file.log,'P_LEGAL_ENTITY_ID :'||P_LEGAL_ENTITY_ID );
	  fnd_file.put_line(fnd_file.log,'P_LEDGER_ID :'||P_LEDGER_ID);
	  fnd_file.put_line(fnd_file.log,'P_COMPANY :'||P_COMPANY);
          fnd_file.put_line(fnd_file.log,'l_period_start_date :'||l_period_start_date);
	  fnd_file.put_line(fnd_file.log,'l_period_end_date :'||l_period_end_date);

	SELECT registration_number,legal_entity_name INTO l_tax_payer_id,l_legal_entity_name
	FROM   xle_registrations_v
	WHERE  legal_entity_id= P_LEGAL_ENTITY_ID
	and    legislative_category= 'INCOME_TAX'
	and    identifying = 'Y';

	 fnd_file.put_line(fnd_file.log,'l_tax_payer_id (registration Number) :'||l_tax_payer_id);
         fnd_file.put_line(fnd_file.log,'legal_entity_name :'||l_legal_entity_name );

	G_LE_ID := P_LEGAL_ENTITY_ID;

        EXCEPTION
        WHEN OTHERS THEN
          fnd_file.put_line(fnd_file.log,' An error occured while extracting the Tax Payer ID for a LE. Error : ' || SUBSTR(SQLERRM, 1, 200));

	END;


	IF P_LEDGER_ID IS NULL THEN

        FOR c_ledger_info IN C_FETCH_LEDGER_INFO
        LOOP
          l_ledger_id   := c_ledger_info.ledger_id;
          l_coaid       := c_ledger_info.chart_of_accounts_id;
          l_ledger_name := c_ledger_info.ledger_name;
          l_functcurr   := c_ledger_info.currency_code;
	  l_func_curr   := c_ledger_info.currency_code;
        END LOOP;

	  fnd_file.put_line(fnd_file.log,'l_ledger_id :'||l_ledger_id );
          fnd_file.put_line(fnd_file.log,'l_coaid :'||l_coaid );
	  fnd_file.put_line(fnd_file.log,'l_ledger_name :'||l_ledger_name);
	  fnd_file.put_line(fnd_file.log,'l_functcurr :'||l_functcurr);

	ELSE
	BEGIN
	 GL_INFO.gl_get_ledger_info(P_LEDGER_ID,l_coaid,l_ledger_name,l_functcurr,errbuf);
	 l_func_curr := l_functcurr;

		 IF errbuf IS NOT NULL THEN

			RAISE INVALID_LEDGER;

		 END IF;

          fnd_file.put_line(fnd_file.log,'l_ledger_id :'||l_ledger_id );
          fnd_file.put_line(fnd_file.log,'l_coaid :'||l_coaid );
	  fnd_file.put_line(fnd_file.log,'l_ledger_name :'||l_ledger_name);
	  fnd_file.put_line(fnd_file.log,'l_functcurr :'||l_functcurr);

	 EXCEPTION
          WHEN INVALID_LEDGER THEN
          fnd_file.put_line(fnd_file.log,errbuf);
	END;
	END IF;


	IF P_REPORT_BY='N'  THEN

	BEGIN

		FOR c_period_info IN C_FETCH_PERIOD
		LOOP
	          l_start_date := c_period_info.start_date;
		  l_end_date   := c_period_info.end_date;
		  l_period_start_date := l_start_date;
		  l_period_end_date := l_end_date;
		END LOOP;

		 fnd_file.put_line(fnd_file.log,'l_start_date :'||l_start_date);
                 fnd_file.put_line(fnd_file.log,' l_end_date :'|| l_end_date );

		EXCEPTION
	          WHEN OTHERS THEN
		  fnd_file.put_line(fnd_file.log,' An error occured while extracting the period start and end date. Error : ' || SUBSTR(SQLERRM, 1, 200));
	END;
	END IF;


        fnd_file.put_line(fnd_file.log,'Calling jg_zz_common_pkg.company_detail');
         jg_zz_common_pkg.company_detail(x_company_name           => l_company_name
                                  ,x_registration_number    => l_registration_num
                                  ,x_country                => l_country
                                  ,x_address1               => l_address_line_1
                                  ,x_address2               => l_address_line_2
                                  ,x_address3               => l_address_line_3
                                  ,x_address4               => l_address_line_4
                                  ,x_city                   => l_city
                                  ,x_postal_code            => l_postal_code
                                  ,x_contact                => l_contact_name
                                  ,x_phone_number           => l_phone_number
                                  ,x_province               => l_province
                                  ,x_comm_number            => l_comm_num
                                  ,x_vat_reg_num            => l_vat_reg_num
                                  ,pn_legal_entity_id       => G_LE_ID
                                  ,p_vat_reporting_entity_id => P_VAT_REPORTING_ENTITY_ID);

		fnd_file.put_line(fnd_file.log,'Company Information :');
		fnd_file.put_line(fnd_file.log,'l_company_name :'||l_company_name);
		fnd_file.put_line(fnd_file.log,'l_registration_num :'||l_registration_num);
		fnd_file.put_line(fnd_file.log,'l_country :'||l_country);
		fnd_file.put_line(fnd_file.log,'l_address_line_1 :'||l_address_line_1);
		fnd_file.put_line(fnd_file.log,'l_address_line_3 :'||l_address_line_3);
		fnd_file.put_line(fnd_file.log,'l_address_line_4 :'||l_address_line_4);
		fnd_file.put_line(fnd_file.log,'l_city :'||l_city);




        INSERT INTO JG_ZZ_VAT_TRX_GT
        (
          jg_info_n1
         ,jg_info_v1
         ,jg_info_v2
         ,jg_info_v3
         ,jg_info_v4  --l_tax_payer_id
         ,jg_info_v5
         ,jg_info_v6
         ,jg_info_v7
         ,jg_info_v8
         ,jg_info_v9
         ,jg_info_v10
         ,jg_info_v11
         ,jg_info_v12
         ,jg_info_v13
         ,jg_info_v14  --l_func_curr
      -- ,jg_info_v15  --l_reporting_status
         ,jg_info_v16
         ,jg_info_d1
         ,jg_info_d2
	 ,jg_info_v18
	 ,jg_info_v19
         ,jg_info_v30
        )
        VALUES
        (
           G_LE_ID
          ,l_company_name
          ,l_legal_entity_name
          ,l_registration_num
          ,l_tax_payer_id
          ,l_contact_name
          ,l_address_line_1
          ,l_address_line_2
          ,l_address_line_3
          ,l_address_line_4
          ,l_city
          ,l_country
          ,l_phone_number
          ,l_postal_code
          ,l_func_curr
       -- ,l_reporting_status
          ,l_tax_regime
          ,l_period_end_date
          ,l_period_start_date
	  ,l_ledger_name
	  ,l_entity_identifier
          ,'H'
        );

      EXCEPTION
        WHEN OTHERS THEN
          fnd_file.put_line(fnd_file.log,' An error occured while extracting the legal entity information. Error : ' || SUBSTR(SQLERRM, 1, 200));
      END;

      BEGIN

        FOR c_curr IN c_curr_name (l_functcurr)
        LOOP
          l_curr_name := c_curr.name;
          g_precision := c_curr.precision;
        END LOOP;

	fnd_file.put_line(fnd_file.log,'l_curr_name :'||l_curr_name);
	fnd_file.put_line(fnd_file.log,'g_precision :'||g_precision);

        G_CURR_NAME   := l_curr_name;
        G_LEDGER_CURR := l_functcurr;
        G_STRUCT_NUM  := l_coaid;
        G_LEDGER_NAME := l_ledger_name;
      EXCEPTION
        WHEN OTHERS THEN
          fnd_file.put_line(fnd_file.log,' An error occured while extracting the currency name and precision. Error : ' || SUBSTR(SQLERRM, 1, 200));
      END;

      BEGIN
        FOR c_inv_less_tax IN c_inv_less_tax_flag
        LOOP
          G_disc_isinvlesstax_flag := c_inv_less_tax.disc_is_inv_less_tax_flag;
        END LOOP;

	fnd_file.put_line(fnd_file.log,'G_disc_isinvlesstax_flag :'||G_disc_isinvlesstax_flag);

      EXCEPTION
        WHEN OTHERS THEN
          fnd_file.put_line(fnd_file.log,' An error occured while extracting the discount invoice less tax flag. Error : ' || SUBSTR(SQLERRM, 1, 200));
      END;

	fnd_file.put_line(fnd_file.log,'Calling Main Fucntion ....');

      IF P_CALLING_REPORT = 'JEFRTXDC' THEN
        BEGIN
 	fnd_file.put_line(fnd_file.log,' P_CALLING_REPORT = JEFRTXDC - Ture ');

	--Query A1
	--Bug 5337430 : Code added to pick up DEB/M invoices
	--This logic is based on the following rules:
	--1. Any validated DEB/M invoice will be picked up based on the accounting date
	--2. A payment made to a DEB/M invoice does not impact a DEB/M invoice
	--3. Invoice cancellation will result in an additional negative line being picked up
	--   The invoice amount, taxable amount and recoverable tax amount will be
	--   negative for this line
	--4. Payment amount will be null for a DEB/M invoice
	--5. A DEB/M prepayment invoice will be picked up if it satisfies conditions 1
	INSERT
	INTO jg_zz_vat_trx_gt(
	    jg_info_v2 --ven_name
	,   jg_info_v3 --ven_no
	,   jg_info_n18 --recoverable_tax_amount
	,   jg_info_n2 --rec_per
	,   jg_info_v5 --company
	,   jg_info_v6 --acc_no
	,   jg_info_n4 --tax_rate
	,   jg_info_v7 --tax_id
	,   jg_info_v8 --tax_type
	,   jg_info_v9 --inv_no
	,   jg_info_d1 --acc_date
	,   jg_info_n12 --l_payment_amt
	,   jg_info_n13 --l_txbl_amt
	,   jg_info_n19 --l_prt_inv_amt
	,   jg_info_v10 -- company_desc
	,   jg_info_v11 -- invoice status
	,   jg_info_v30)
        SELECT
        -- bug 8299240 - start
	  -- SUBSTR(ven.vendor_name,   1,   10) ven_name,
        ven.vendor_name ven_name,
        -- bug 8299240 - end
	  SUBSTR(ven.segment1,   1,   8) ven_no,
	  SUM(nvl(inv.exchange_rate,1)*zl.rec_nrec_tax_amt) recoverable_tax_amount,
	  zl.rec_nrec_rate rec_per,
	  get_balancing_segment(acctinfo.dist_code_combination_id) company,
	  get_accounting_segment(acctinfo.dist_code_combination_id) acc_no,
	  tax.percentage_rate tax_rate,
	  tax.tax_rate_id tax_id,
	  'DEB/M' tax_type,
        -- bug 8299240 - start
	  -- SUBSTR(inv.invoice_num,   1,   10) inv_no,
        inv.invoice_num inv_no,
        -- bug 8299240 - end
	  dis.accounting_date acc_date,
	  NULL payment_amt,
	  nvl(inv.exchange_rate,1)*dis.amount txbl_amt,
	  decode(dis.parent_reversal_id,   NULL,   decode(nvl(dis.reversal_flag,   'N'),   'Y',   nvl(inv.exchange_rate,1)*inv.cancelled_amount,   nvl(inv.exchange_rate,1)*inv.invoice_amount),
	  -1 * nvl(inv.exchange_rate,1) * inv.cancelled_amount) prt_inv_amt,
	  NULL,
	  decode(dis.parent_reversal_id, NULL,' ','C'),
	  'JEFRTXDC'
	FROM zx_rec_nrec_dist zl,
	  zx_rates_b tax,
	  ap_invoices inv,
	  ap_invoice_distributions dis,
	  po_vendors ven,
	  ap_invoice_distributions acctinfo
	WHERE ((P_LEDGER_ID IS NULL AND P_COMPANY IS NULL AND inv.legal_entity_id = G_LE_ID)
	 OR (P_LEDGER_ID IS NOT NULL AND P_COMPANY IS NULL AND inv.set_of_books_id = P_LEDGER_ID)
         OR (P_COMPANY IS NOT NULL AND inv.set_of_books_id = P_LEDGER_ID AND get_balancing_segment(dis.dist_code_combination_id) = P_COMPANY))
	 AND ven.vendor_id = inv.vendor_id
	 AND inv.invoice_id = dis.invoice_id
	 AND zl.rec_nrec_tax_dist_id = acctinfo.detail_tax_dist_id
         AND inv.invoice_id = acctinfo.invoice_id
	 AND zl.trx_id = inv.invoice_id
	 AND zl.recoverable_flag = 'Y'
	 AND tax.tax_rate_id = zl.tax_rate_id
	 AND zl.entity_code = 'AP_INVOICES'
	 AND dis.line_type_lookup_code <> 'PREPAY'
	 AND zl.trx_line_dist_id = dis.invoice_distribution_id
	 AND dis.match_status_flag IS NOT NULL
	 AND dis.accounting_date BETWEEN l_start_date AND l_end_date
         -- bug 8460485 - start
         AND nvl(dis.reversal_flag,'N') = 'N'
         AND nvl(zl.reverse_flag,'N') = 'N'
         -- bug 8460485 - end
         AND EXISTS ( SELECT 1 FROM zx_lines_det_factors zldf
         WHERE SUBSTR(zldf.document_sub_type,   LENGTH(zldf.document_sub_type) -4,   5) = 'DEB/M'
	 AND zldf.trx_id = inv.invoice_id )
	GROUP BY zl.trx_line_dist_id,
          tax.tax_rate_id,
	  tax.percentage_rate,
	  zl.rec_nrec_rate,
	  decode(dis.parent_reversal_id,   NULL,   decode(nvl(dis.reversal_flag,   'N'),   'Y',   nvl(inv.exchange_rate,1)*inv.cancelled_amount,   nvl(inv.exchange_rate,1)*inv.invoice_amount),
	  -1 * nvl(inv.exchange_rate,1) * inv.cancelled_amount),
	  -- bug 8299240 - start
	  -- SUBSTR(ven.vendor_name,   1,   10) ven_name,
        ven.vendor_name,
        -- bug 8299240 - end
	  SUBSTR(ven.segment1,   1,   8),
	  inv.invoice_type_lookup_code,
	  get_balancing_segment(acctinfo.dist_code_combination_id),
	  get_accounting_segment(acctinfo.dist_code_combination_id),
	  dis.accounting_date,
	  inv.invoice_num,
	  nvl(inv.exchange_rate,1)*dis.amount,
	  inv.cancelled_date,
	  decode(dis.parent_reversal_id, NULL,' ','C');

        --Query A2
	--Bug 5383153 : Code added to pick up application of prepayment with tax lines
	--to DEB/M invoices
	--This logic is based on the following rules:
        --The following are the two types of prepayments possible:
	--
        --Type I. Prepayment without a tax line
        --Type II. Prepayment with a tax line (and is of type DEB/M)
	--
        --1. Prepayments of Type I will not be shown in the report irrespective of
        --   whether type are paid or not
        --2. The application of prepayment of Type I on DEB/M invoices will not impact
        --   the way the invoice is displayed on the report
        --3. Prepayments of Type II will be shown in the report based on their invoice
        --   accounting date. This case is handled by Query A1
        --4. When Prepayments of Type II are applied to a DEB/M invoice, A negative
        --   line will appear on the invoice with amounts equal to the applied prepayment
        --   amounts. This is necessary as tax on prepayment has already be reported (in Case 3).
	--   Case 4 is handled in this query
	INSERT
	INTO jg_zz_vat_trx_gt(
	    jg_info_v2 --ven_name
	,   jg_info_v3 --ven_no
	,   jg_info_n18 --recoverable_tax_amount
	,   jg_info_n2 --rec_per
	,   jg_info_v5 --company
	,   jg_info_v6 --acc_no
	,   jg_info_n4 --tax_rate
	,   jg_info_v7 --tax_id
	,   jg_info_v8 --tax_type
	,   jg_info_v9 --inv_no
	,   jg_info_d1 --acc_date
	,   jg_info_n12 --l_payment_amt
	,   jg_info_n13 --l_txbl_amt
	,   jg_info_n19 --l_prt_inv_amt
	,   jg_info_v10 -- company_desc
	,   jg_info_v11 -- invoice status
	,   jg_info_v30)
        SELECT
	  -- bug 8299240 - start
	  -- SUBSTR(ven.vendor_name,   1,   10) ven_name,
        ven.vendor_name ven_name,
        -- bug 8299240 - end
	  SUBSTR(ven.segment1,   1,   8) ven_no,
	  SUM(nvl(inv.exchange_rate,1)*zl.rec_nrec_tax_amt) recoverable_tax_amount,
	  zl.rec_nrec_rate rec_per,
	  get_balancing_segment(acctinfo.dist_code_combination_id) company,
	  get_accounting_segment(acctinfo.dist_code_combination_id) acc_no,
	  tax.percentage_rate tax_rate,
	  tax.tax_rate_id tax_id,
	  'DEB/M' tax_type,
	  -- bug 8299240 - start
	  -- SUBSTR(inv.invoice_num,   1,   10) inv_no,
        inv.invoice_num inv_no,
        -- bug 8299240 - end
	  dis.accounting_date acc_date,
	  NULL payment_amt,
	  nvl(inv.exchange_rate,1)*dis.amount txbl_amt,
	  decode(inv.cancelled_date,NULL,nvl(inv.exchange_rate,1)*inv.invoice_amount, nvl(inv.exchange_rate,1)*inv.cancelled_amount) prt_inv_amt,
	  NULL,
	  'P',
	  'JEFRTXDC'
	FROM zx_rec_nrec_dist zl,
	  zx_rates_b tax,
	  ap_invoices inv,
	  ap_invoice_distributions dis,
	  po_vendors ven,
	  ap_invoice_distributions acctinfo
	WHERE ((P_LEDGER_ID IS NULL AND P_COMPANY IS NULL AND inv.legal_entity_id = G_LE_ID)
	 OR (P_LEDGER_ID IS NOT NULL AND P_COMPANY IS NULL AND inv.set_of_books_id = P_LEDGER_ID)
         OR (P_COMPANY IS NOT NULL AND inv.set_of_books_id = P_LEDGER_ID AND get_balancing_segment(dis.dist_code_combination_id) = P_COMPANY))
	 AND ven.vendor_id = inv.vendor_id
	 AND inv.invoice_id = dis.invoice_id
	 AND zl.rec_nrec_tax_dist_id = acctinfo.detail_tax_dist_id
         AND inv.invoice_id = acctinfo.invoice_id
	 AND zl.trx_id = inv.invoice_id
	 AND zl.recoverable_flag = 'Y'
	 AND tax.tax_rate_id = zl.tax_rate_id
	 AND zl.entity_code = 'AP_INVOICES'
	 AND dis.line_type_lookup_code = 'PREPAY'
	 AND zl.trx_line_dist_id = dis.invoice_distribution_id
	 AND dis.match_status_flag IS NOT NULL
	 AND (dis.accounting_date BETWEEN l_start_date AND l_end_date)
         AND EXISTS ( SELECT 1 FROM zx_lines_det_factors zldf
         WHERE SUBSTR(zldf.document_sub_type,   LENGTH(zldf.document_sub_type) -4,   5) = 'DEB/M'
	 AND zldf.trx_id = inv.invoice_id )
	GROUP BY zl.trx_line_dist_id,
          tax.tax_rate_id,
	  tax.percentage_rate,
	  zl.rec_nrec_rate,
	  decode(inv.cancelled_date,NULL,nvl(inv.exchange_rate,1)*inv.invoice_amount, nvl(inv.exchange_rate,1)*inv.cancelled_amount),
	  -- bug 8299240 - start
	  -- SUBSTR(ven.vendor_name,   1,   10) ven_name,
        ven.vendor_name ,
        -- bug 8299240 - end
	  SUBSTR(ven.segment1,   1,   8),
	  inv.invoice_type_lookup_code,
	  get_balancing_segment(acctinfo.dist_code_combination_id),
	  get_accounting_segment(acctinfo.dist_code_combination_id),
	  dis.accounting_date,
	  inv.invoice_num,
	  nvl(inv.exchange_rate,1)*dis.amount,
	  inv.cancelled_date,
	  inv.invoice_amount,
          inv.cancelled_amount;

	--Query B1
        --Bug 5383171 : Query to pick up all CRE/M invoices that have been paid
	--This logic is based on the following rules:
	--1. A CRE/M invoice that is not paid will not be picked up
	--2. CRE/M invoices will be picked based on their future payment date
	--   (or payment date, if the future payment date is null)
	--3. If a CRE/M invoice is partially paid, then the taxable amount and
	--   the recoverable tax amount will be prorated using this formula
	--   Taxable amount = (Original Taxable Amount)*(Payment Amount/Invoice Amount)
	--   Recoverable tax amount = (Original Recoveral tax amount)*(Payment Amount/Invoice Amount)
	--4. A CRE/M invoice that does not have a tax line will not be picked
	--5. A CRE/M prepayment invoice will be picked up if it satisfies conditions 1 to 4
	--6. Invoice cancellation does not affect a CRE/M invoice
	--7. Voiding a payment will result in an additional negative line being
	--   picked up for the invoice. The payment amount, taxable amount and
	--   recoverable tax amount will be negative for this line
	INSERT
	INTO jg_zz_vat_trx_gt(
	    jg_info_v2 --ven_name
	,   jg_info_v3 --ven_no
	,   jg_info_n18 --recoverable_tax_amount
	,   jg_info_n2 --rec_per
	,   jg_info_v5 --company
	,   jg_info_v6 --acc_no
	,   jg_info_n4 --tax_rate
	,   jg_info_v7 --tax_id
	,   jg_info_v8 --tax_type
	,   jg_info_v9 --inv_no
	,   jg_info_d1 --acc_date
	,   jg_info_n12 --l_payment_amt
	,   jg_info_n13 --l_txbl_amt
	,   jg_info_n19 --l_prt_inv_amt
	,   jg_info_v10 -- company_desc
	,   jg_info_v11 -- invoice status
	,   jg_info_v30)
	SELECT
	  -- bug 8299240 - start
	  -- SUBSTR(ven.vendor_name,   1,   10) ven_name,
        ven.vendor_name ven_name,
        -- bug 8299240 - end
	  SUBSTR(ven.segment1,   1,   8) ven_no,
	  SUM(nvl(inv.exchange_rate,1)*zl.rec_nrec_tax_amt) * ((nvl(aip.exchange_rate,1)*aip.amount + nvl(aip.exchange_rate,1) * nvl(aip.discount_taken,0))
	  /decode(inv.cancelled_date,NULL,nvl(inv.exchange_rate,1)*inv.invoice_amount, nvl(inv.exchange_rate,1)*inv.cancelled_amount)) recoverable_tax_amount,
	  zl.rec_nrec_rate rec_per,
	  get_balancing_segment(acctinfo.dist_code_combination_id) company,
	  get_accounting_segment(decode(zl.def_rec_settlement_option_code,'DEFERRED', ACCOUNTS.tax_account_ccid, acctinfo.dist_code_combination_id)) acc_no,
	  tax.percentage_rate tax_rate,
	  tax.tax_rate_id tax_id,
	  'CRE/M' tax_type,
	  -- bug 8299240 - start
	  -- SUBSTR(inv.invoice_num,   1,   10) inv_no,
        inv.invoice_num inv_no,
        -- bug 8299240 - end
	  decode(chk.future_pay_due_date, NULL, aip.accounting_date, decode(sign(aip.accounting_date-chk.future_pay_due_date),1, aip.accounting_date, chk.future_pay_due_date)) acc_date,
	  (nvl(aip.exchange_rate,1)*aip.amount + nvl(aip.exchange_rate,1) * nvl(aip.discount_taken,0)) payment_amt,
          nvl(inv.exchange_rate,1)*dis.amount * ((nvl(aip.exchange_rate,1)*aip.amount + nvl(aip.exchange_rate,1) * nvl(aip.discount_taken,0))
	  /decode(inv.cancelled_date,NULL,nvl(inv.exchange_rate,1)*inv.invoice_amount, nvl(inv.exchange_rate,1)*inv.cancelled_amount)) txbl_amt,
	  decode(inv.cancelled_date,NULL,nvl(inv.exchange_rate,1)*inv.invoice_amount, nvl(inv.exchange_rate,1)*inv.cancelled_amount) prt_inv_amt,
	  NULL,
	  decode(aip.reversal_inv_pmt_id,NULL,' ','V'),
	  'JEFRTXDC'
	FROM  zx_rates_b tax,
	  ap_invoices inv,
	  ap_invoice_distributions dis,
	  po_vendors ven,
	  ap_invoice_payments aip,
	  ap_checks_all chk,
	  ap_invoice_distributions acctinfo,
        zx_rec_nrec_dist zl LEFT OUTER JOIN zx_accounts ACCOUNTS
        ON (accounts.TAX_ACCOUNT_ENTITY_ID =
        nvl(zl.ACCOUNT_SOURCE_TAX_RATE_ID, zl.TAX_RATE_ID)
        AND accounts.TAX_ACCOUNT_ENTITY_CODE = 'RATES'
        AND accounts.INTERNAL_ORGANIZATION_ID = zl.INTERNAL_ORGANIZATION_ID
        AND accounts.LEDGER_ID = zl.LEDGER_ID )
	WHERE ((p_ledger_id IS NULL
	 AND p_company IS NULL
	 AND inv.legal_entity_id = g_le_id) OR(p_ledger_id IS NOT NULL
	 AND p_company IS NULL
	 AND inv.set_of_books_id = p_ledger_id) OR(p_company IS NOT NULL
	 AND inv.set_of_books_id = p_ledger_id
	 AND get_balancing_segment(dis.dist_code_combination_id) = p_company))
	 AND ven.vendor_id = inv.vendor_id
	 AND inv.invoice_id = dis.invoice_id
	 AND aip.invoice_id = inv.invoice_id
	 AND zl.rec_nrec_tax_dist_id = acctinfo.detail_tax_dist_id
         AND inv.invoice_id = acctinfo.invoice_id
	 AND chk.check_id = aip.check_id
	 AND zl.trx_id = inv.invoice_id
	 AND zl.recoverable_flag = 'Y'
	 AND tax.tax_rate_id = zl.tax_rate_id
	 AND zl.entity_code = 'AP_INVOICES'
	 AND zl.trx_line_dist_id = dis.invoice_distribution_id
	 AND dis.line_type_lookup_code <> 'PREPAY'
	 AND dis.match_status_flag IS NOT NULL
	 AND decode(chk.future_pay_due_date, NULL, aip.accounting_date, decode(sign(aip.accounting_date-chk.future_pay_due_date),1, aip.accounting_date, chk.future_pay_due_date)) BETWEEN l_start_date AND l_end_date
	 AND dis.parent_reversal_id IS NULL
	 -- Bug 8307032 discarded and reversed lines should not be picked
 	 and nvl(dis.reversal_flag,'N') = 'N'
 	 and nvl(zl.reverse_flag,'N')= 'N'
	 AND EXISTS ( SELECT 1 FROM zx_lines_det_factors zldf WHERE
	     SUBSTR(zldf.document_sub_type,   LENGTH(zldf.document_sub_type) -4,   5) = 'CRE/M'
	     AND zldf.trx_id = inv.invoice_id )
	GROUP BY zl.trx_line_dist_id,
          tax.tax_rate_id,
	  tax.percentage_rate,
	  zl.rec_nrec_rate,
	  inv.cancelled_amount,
	  -- bug 8299240 - start
	  -- SUBSTR(ven.vendor_name,   1,   10) ven_name,
        ven.vendor_name ,
        -- bug 8299240 - end
	  SUBSTR(ven.segment1,   1,   8),
	  inv.invoice_type_lookup_code,
	  get_balancing_segment(acctinfo.dist_code_combination_id),
	  get_accounting_segment(decode(zl.def_rec_settlement_option_code,'DEFERRED', ACCOUNTS.tax_account_ccid, acctinfo.dist_code_combination_id)),
	  aip.accounting_date,
	  inv.invoice_num,
	  dis.amount,
	  inv.cancelled_date,
	  aip.amount,
	  aip.discount_taken,
	  inv.invoice_amount,
	  chk.future_pay_due_date,
	  decode(aip.reversal_inv_pmt_id,NULL,' ','V'),
	  inv.exchange_rate,
	  aip.exchange_rate;

	--Query B2
        --Bug 5383181 : Query to pick up all prepayments with tax lines that have
	--been applied to a CRE/M invoice
	--Prepayments with tax lines will be handled as follows:
	--1. Prepayments of this type will be shown in the report based on their payment
	--   due date (or payment date, if payment due date is null). This is handled
	--   in the previous query
	--2. When such prepayments are applied to a CRE/M invoice, a postive
	--   line will appear on the invoice with tax amount equal to the prepayment tax
	--   amount. A corrosponding negative line will also appear in order to
	--   compensate the positive line. The sum of payment, taxable and recoverable
	--   tax amounts of both the lines will be zero. This is necessary as the tax on
	--   prepayment has already be reported in case 1 and the lines are
	--   displayed on the report for informational purposes only.
	--
	--   The first insert is for the positive line, the second insert
	--   is for the negative line
	INSERT
	INTO jg_zz_vat_trx_gt(
	    jg_info_v2 --ven_name
	,   jg_info_v3 --ven_no
	,   jg_info_n18 --recoverable_tax_amount
	,   jg_info_n2 --rec_per
	,   jg_info_v5 --company
	,   jg_info_v6 --acc_no
	,   jg_info_n4 --tax_rate
	,   jg_info_v7 --tax_id
	,   jg_info_v8 --tax_type
	,   jg_info_v9 --inv_no
	,   jg_info_d1 --acc_date
	,   jg_info_n12 --l_payment_amt
	,   jg_info_n13 --l_txbl_amt
	,   jg_info_n19 --l_prt_inv_amt
	,   jg_info_v10 -- company_desc
	,   jg_info_v11 -- invoice status
	,   jg_info_v30)
	SELECT
	  -- bug 8299240 - start
	  -- SUBSTR(ven.vendor_name,   1,   10) ven_name,
        ven.vendor_name ven_name,
        -- bug 8299240 - end
	  SUBSTR(ven.segment1,   1,   8) ven_no,
	  SUM(nvl(inv.exchange_rate,1)*zl.rec_nrec_tax_amt)*-1 recoverable_tax_amount,
	  zl.rec_nrec_rate rec_per,
	  get_balancing_segment(acctinfo.dist_code_combination_id) company,
	  get_accounting_segment(decode(zl.def_rec_settlement_option_code,'DEFERRED', ACCOUNTS.tax_account_ccid, acctinfo.dist_code_combination_id)) acc_no,
	  tax.percentage_rate tax_rate,
	  tax.tax_rate_id tax_id,
	  'CRE/M' tax_type,
	  -- bug 8299240 - start
	  -- SUBSTR(inv.invoice_num,   1,   10) inv_no,
        inv.invoice_num inv_no,
        -- bug 8299240 - end
	  dis.accounting_date acc_date,
	  (SUM(nvl(inv.exchange_rate,1)*zl.rec_nrec_tax_amt) + SUM(nvl(inv.exchange_rate,1)*nrec.rec_nrec_tax_amt) + nvl(inv.exchange_rate,1)*dis.amount)*-1 payment_amt,
	  nvl(inv.exchange_rate,1)*dis.amount*-1 txbl_amt,
	  decode(inv.cancelled_date,NULL,nvl(inv.exchange_rate,1)*inv.invoice_amount, nvl(inv.exchange_rate,1)*inv.cancelled_amount) prt_inv_amt,
	  NULL,
	  'P',
	  'JEFRTXDC'
	FROM  zx_rates_b tax,
	  ap_invoices inv,
	  ap_invoice_distributions dis,
	  po_vendors ven,
	  zx_rec_nrec_dist nrec,
	  ap_invoice_distributions acctinfo,
        zx_rec_nrec_dist zl LEFT OUTER JOIN zx_accounts ACCOUNTS
        ON (accounts.TAX_ACCOUNT_ENTITY_ID =
        nvl(zl.ACCOUNT_SOURCE_TAX_RATE_ID, zl.TAX_RATE_ID)
        AND accounts.TAX_ACCOUNT_ENTITY_CODE = 'RATES'
        AND accounts.INTERNAL_ORGANIZATION_ID = zl.INTERNAL_ORGANIZATION_ID
        AND accounts.LEDGER_ID = zl.LEDGER_ID )
	WHERE ((P_LEDGER_ID IS NULL AND P_COMPANY IS NULL AND inv.legal_entity_id = G_LE_ID)
	 OR (P_LEDGER_ID IS NOT NULL AND P_COMPANY IS NULL AND inv.set_of_books_id = P_LEDGER_ID)
         OR (P_COMPANY IS NOT NULL AND inv.set_of_books_id = P_LEDGER_ID AND get_balancing_segment(dis.dist_code_combination_id) = P_COMPANY))
	 AND ven.vendor_id = inv.vendor_id
	 AND inv.invoice_id = dis.invoice_id
	 AND zl.rec_nrec_tax_dist_id = acctinfo.detail_tax_dist_id
       AND inv.invoice_id = acctinfo.invoice_id
	 AND zl.trx_id = inv.invoice_id
	 AND zl.recoverable_flag = 'Y'
	 AND tax.tax_rate_id = zl.tax_rate_id
	 AND zl.entity_code = 'AP_INVOICES'
	 AND zl.trx_line_dist_id = dis.invoice_distribution_id
	 AND dis.match_status_flag IS NOT NULL
	 AND dis.accounting_date BETWEEN l_start_date AND l_end_date
       AND dis.line_type_lookup_code = 'PREPAY'
	 AND nrec.entity_code = 'AP_INVOICES'
	 AND nrec.trx_line_dist_id = dis.invoice_distribution_id
       AND nrec.trx_id = inv.invoice_id
	 AND nrec.recoverable_flag = 'N'
       AND EXISTS ( SELECT 1 FROM zx_lines_det_factors zldf WHERE
	     SUBSTR(zldf.document_sub_type,   LENGTH(zldf.document_sub_type) -4,   5) = 'CRE/M'
	     AND zldf.trx_id = inv.invoice_id )
	GROUP BY zl.trx_line_dist_id,
	  tax.tax_rate_id,
	  tax.percentage_rate,
	  zl.rec_nrec_rate,
	  decode(inv.cancelled_date,NULL,nvl(inv.exchange_rate,1)*inv.invoice_amount, nvl(inv.exchange_rate,1)*inv.cancelled_amount),
	  -- bug 8299240 - start
	  -- SUBSTR(ven.vendor_name,   1,   10) ven_name,
        ven.vendor_name ,
        -- bug 8299240 - end
	  SUBSTR(ven.segment1,   1,   8),
	  inv.invoice_type_lookup_code,
	  get_balancing_segment(acctinfo.dist_code_combination_id),
	  get_accounting_segment(decode(zl.def_rec_settlement_option_code,'DEFERRED', ACCOUNTS.tax_account_ccid, acctinfo.dist_code_combination_id)),
	  dis.accounting_date,
	  inv.invoice_num,
	  dis.amount,
	  inv.cancelled_date,
	  inv.exchange_rate;



	INSERT
	INTO jg_zz_vat_trx_gt(
	    jg_info_v2 --ven_name
	,   jg_info_v3 --ven_no
	,   jg_info_n18 --recoverable_tax_amount
	,   jg_info_n2 --rec_per
	,   jg_info_v5 --company
	,   jg_info_v6 --acc_no
	,   jg_info_n4 --tax_rate
	,   jg_info_v7 --tax_id
	,   jg_info_v8 --tax_type
	,   jg_info_v9 --inv_no
	,   jg_info_d1 --acc_date
	,   jg_info_n12 --l_payment_amt
	,   jg_info_n13 --l_txbl_amt
	,   jg_info_n19 --l_prt_inv_amt
	,   jg_info_v10 -- company_desc
	,   jg_info_v11 -- invoice status
	,   jg_info_v30)
	SELECT
	  -- bug 8299240 - start
	  -- SUBSTR(ven.vendor_name,   1,   10) ven_name,
        ven.vendor_name ven_name,
        -- bug 8299240 - end
	  SUBSTR(ven.segment1,   1,   8) ven_no,
	  SUM(nvl(inv.exchange_rate,1)*zl.rec_nrec_tax_amt) recoverable_tax_amount,
	  zl.rec_nrec_rate rec_per,
	  get_balancing_segment(acctinfo.dist_code_combination_id) company,
	  get_accounting_segment(decode(zl.def_rec_settlement_option_code,'DEFERRED', ACCOUNTS.tax_account_ccid, acctinfo.dist_code_combination_id)) acc_no,
	  tax.percentage_rate tax_rate,
	  tax.tax_rate_id tax_id,
	  'CRE/M' tax_type,
	  -- bug 8299240 - start
	  -- SUBSTR(inv.invoice_num,   1,   10) inv_no,
        inv.invoice_num inv_no,
        -- bug 8299240 - end
	  dis.accounting_date acc_date,
	  SUM(nvl(inv.exchange_rate,1)*zl.rec_nrec_tax_amt) + SUM(nvl(inv.exchange_rate,1)*nrec.rec_nrec_tax_amt) + nvl(inv.exchange_rate,1)*dis.amount payment_amt,
	  nvl(inv.exchange_rate,1)*dis.amount txbl_amt,
	  decode(inv.cancelled_date,NULL,nvl(inv.exchange_rate,1)*inv.invoice_amount, nvl(inv.exchange_rate,1)*inv.cancelled_amount) prt_inv_amt,
	  NULL,
	  'P',
	  'JEFRTXDC'
	FROM zx_rates_b tax,
	  ap_invoices inv,
	  ap_invoice_distributions dis,
	  po_vendors ven,
	  zx_rec_nrec_dist nrec,
	  ap_invoice_distributions acctinfo,
        zx_rec_nrec_dist zl LEFT OUTER JOIN zx_accounts ACCOUNTS
        ON (accounts.TAX_ACCOUNT_ENTITY_ID =
        nvl(zl.ACCOUNT_SOURCE_TAX_RATE_ID, zl.TAX_RATE_ID)
        AND accounts.TAX_ACCOUNT_ENTITY_CODE = 'RATES'
        AND accounts.INTERNAL_ORGANIZATION_ID = zl.INTERNAL_ORGANIZATION_ID
        AND accounts.LEDGER_ID = zl.LEDGER_ID )
	WHERE ((P_LEDGER_ID IS NULL AND P_COMPANY IS NULL AND inv.legal_entity_id = G_LE_ID)
	 OR (P_LEDGER_ID IS NOT NULL AND P_COMPANY IS NULL AND inv.set_of_books_id = P_LEDGER_ID)
         OR (P_COMPANY IS NOT NULL AND inv.set_of_books_id = P_LEDGER_ID AND get_balancing_segment(dis.dist_code_combination_id) = P_COMPANY))
	 AND ven.vendor_id = inv.vendor_id
	 AND inv.invoice_id = dis.invoice_id
	 AND zl.rec_nrec_tax_dist_id = acctinfo.detail_tax_dist_id
       AND inv.invoice_id = acctinfo.invoice_id
	 AND zl.trx_id = inv.invoice_id
	 AND zl.recoverable_flag = 'Y'
	 AND tax.tax_rate_id = zl.tax_rate_id
	 AND zl.entity_code = 'AP_INVOICES'
	 AND zl.trx_line_dist_id = dis.invoice_distribution_id
	 AND dis.match_status_flag IS NOT NULL
	 AND dis.accounting_date BETWEEN l_start_date AND l_end_date
       AND dis.line_type_lookup_code = 'PREPAY'
	 AND nrec.entity_code = 'AP_INVOICES'
	 AND nrec.trx_line_dist_id = dis.invoice_distribution_id
       AND nrec.trx_id = inv.invoice_id
	 AND nrec.recoverable_flag = 'N'
       AND EXISTS ( SELECT 1 FROM zx_lines_det_factors zldf WHERE
	     SUBSTR(zldf.document_sub_type,   LENGTH(zldf.document_sub_type) -4,   5) = 'CRE/M'
	     AND zldf.trx_id = inv.invoice_id )
	GROUP BY zl.trx_line_dist_id,
	  tax.tax_rate_id,
	  tax.percentage_rate,
	  zl.rec_nrec_rate,
	  decode(inv.cancelled_date,NULL,nvl(inv.exchange_rate,1)*inv.invoice_amount, nvl(inv.exchange_rate,1)*inv.cancelled_amount),
	  -- bug 8299240 - start
	  -- SUBSTR(ven.vendor_name,   1,   10) ven_name,
        ven.vendor_name ,
        -- bug 8299240 - end
	  SUBSTR(ven.segment1,   1,   8),
	  inv.invoice_type_lookup_code,
	  get_balancing_segment(acctinfo.dist_code_combination_id),
	  get_accounting_segment(decode(zl.def_rec_settlement_option_code,'DEFERRED', ACCOUNTS.tax_account_ccid, acctinfo.dist_code_combination_id)),
	  dis.accounting_date,
	  inv.invoice_num,
	  dis.amount,
	  inv.cancelled_date,
	  inv.exchange_rate;


        --Query B3
        --Bug 5383181 : Query to pick up all prepayments without a tax line that have
	--been applied to a CRE/M invoice
	--Prepayments without tax lines will be handled as follows:
	--1. Prepayments of this type will not be shown in the report irrespective
	--   of whether they are paid or not
	--2. The application of such prepayments on CRE/M invoices will be consider
	--   as a normal payment. In such a case the recoveral tax amount and the
	--   taxable amount will be prorated based on prepayment amount
	--   Taxable amount = (Original Taxable Amount)*(prepayment Amount/Invoice Amount)
	--   Recoverable tax amount = (Original Recoveral tax amount)*(prepayment Amount/Invoice Amount)
	INSERT
	INTO jg_zz_vat_trx_gt(
	    jg_info_v2 --ven_name
	,   jg_info_v3 --ven_no
	,   jg_info_n18 --recoverable_tax_amount
	,   jg_info_n2 --rec_per
	,   jg_info_v5 --company
	,   jg_info_v6 --acc_no
	,   jg_info_n4 --tax_rate
	,   jg_info_v7 --tax_id
	,   jg_info_v8 --tax_type
	,   jg_info_v9 --inv_no
	,   jg_info_d1 --acc_date
	,   jg_info_n12 --l_payment_amt
	,   jg_info_n13 --l_txbl_amt
	,   jg_info_n19 --l_prt_inv_amt
	,   jg_info_v10 -- company_desc
	,   jg_info_v11 -- invoice status
	,   jg_info_v30)
        SELECT
	  -- bug 8299240 - start
	  -- SUBSTR(ven.vendor_name,   1,   10) ven_name,
        ven.vendor_name ven_name,
        -- bug 8299240 - end
	  SUBSTR(ven.segment1,   1,   8) ven_no,
	  SUM(nvl(inv.exchange_rate,1)*zl.rec_nrec_tax_amt) * ((-1 * nvl(inv.exchange_rate,1) * pre.amount)
	  /decode(inv.cancelled_date,NULL,nvl(inv.exchange_rate,1)*inv.invoice_amount, nvl(inv.exchange_rate,1)*inv.cancelled_amount)) recoverable_tax_amount,
	  zl.rec_nrec_rate rec_per,
	  get_balancing_segment(acctinfo.dist_code_combination_id) company,
	  get_accounting_segment(decode(zl.def_rec_settlement_option_code,'DEFERRED', ACCOUNTS.tax_account_ccid, acctinfo.dist_code_combination_id)) acc_no,
	  tax.percentage_rate tax_rate,
	  tax.tax_rate_id tax_id,
	  'CRE/M' tax_type,
	  -- bug 8299240 - start
	  -- SUBSTR(inv.invoice_num,   1,   10) inv_no,
        inv.invoice_num inv_no,
        -- bug 8299240 - end
	  pre.accounting_date acc_date,
	  -1 * nvl(inv.exchange_rate,1) * pre.amount payment_amt,
	  nvl(inv.exchange_rate,1) * dis.amount * ((-1 * nvl(inv.exchange_rate,1) * pre.amount)
	  /decode(inv.cancelled_date,NULL,nvl(inv.exchange_rate,1)*inv.invoice_amount, nvl(inv.exchange_rate,1)*inv.cancelled_amount)) txbl_amt,
	  decode(inv.cancelled_date,NULL,nvl(inv.exchange_rate,1)*inv.invoice_amount, nvl(inv.exchange_rate,1)*inv.cancelled_amount) prt_inv_amt,
	  NULL,
	  'PP',
	  'JEFRTXDC'
	FROM zx_rates_b tax,
	  ap_invoices inv,
	  ap_invoice_distributions dis,
	  po_vendors ven,
        ap_invoice_distributions pre,
	  ap_invoice_distributions acctinfo,
        zx_rec_nrec_dist zl LEFT OUTER JOIN zx_accounts ACCOUNTS
        ON (accounts.TAX_ACCOUNT_ENTITY_ID =
        nvl(zl.ACCOUNT_SOURCE_TAX_RATE_ID, zl.TAX_RATE_ID)
        AND accounts.TAX_ACCOUNT_ENTITY_CODE = 'RATES'
        AND accounts.INTERNAL_ORGANIZATION_ID = zl.INTERNAL_ORGANIZATION_ID
        AND accounts.LEDGER_ID = zl.LEDGER_ID )
	WHERE ((p_ledger_id IS NULL
	 AND p_company IS NULL
	 AND inv.legal_entity_id = g_le_id) OR(p_ledger_id IS NOT NULL
	 AND p_company IS NULL
	 AND inv.set_of_books_id = p_ledger_id) OR(p_company IS NOT NULL
	 AND inv.set_of_books_id = p_ledger_id
	 AND get_balancing_segment(dis.dist_code_combination_id) = p_company))
	 AND ven.vendor_id = inv.vendor_id
	 AND inv.invoice_id = dis.invoice_id
       AND inv.invoice_id = pre.invoice_id
	 AND zl.rec_nrec_tax_dist_id = acctinfo.detail_tax_dist_id
       AND inv.invoice_id = acctinfo.invoice_id
	 AND zl.trx_id = inv.invoice_id
	 AND zl.recoverable_flag = 'Y'
	 AND tax.tax_rate_id = zl.tax_rate_id
	 AND zl.entity_code = 'AP_INVOICES'
	 AND zl.trx_line_dist_id = dis.invoice_distribution_id
	 AND dis.line_type_lookup_code = 'ITEM'
	 AND dis.match_status_flag IS NOT NULL
       AND pre.line_type_lookup_code = 'PREPAY'
       AND pre.match_status_flag IS NOT NULL
       AND NOT EXISTS ( SELECT 1 FROM zx_rec_nrec_dist zlp where
	     zlp.trx_id = inv.invoice_id
	     AND zlp.entity_code = 'AP_INVOICES'
	     AND zlp.trx_line_dist_id = pre.invoice_distribution_id )
	 AND pre.accounting_date BETWEEN l_start_date AND l_end_date
	 AND dis.parent_reversal_id IS NULL
	  -- Bug 8307032 discarded and reversed lines should not be picked
 	  and nvl(dis.reversal_flag,'N') = 'N'
 	  and nvl(zl.reverse_flag,'N')= 'N'
	 AND EXISTS ( SELECT 1 FROM zx_lines_det_factors zldf WHERE
	     SUBSTR(zldf.document_sub_type,   LENGTH(zldf.document_sub_type) -4,   5) = 'CRE/M'
	     AND zldf.trx_id = inv.invoice_id )
	GROUP BY zl.trx_line_dist_id,
	  tax.tax_rate_id,
	  tax.percentage_rate,
	  zl.rec_nrec_rate,
	  inv.cancelled_amount,
	  -- bug 8299240 - start
	  -- SUBSTR(ven.vendor_name,   1,   10) ven_name,
        ven.vendor_name ,
        -- bug 8299240 - end
	  SUBSTR(ven.segment1,   1,   8),
	  inv.invoice_type_lookup_code,
	  get_balancing_segment(acctinfo.dist_code_combination_id),
	  get_accounting_segment(decode(zl.def_rec_settlement_option_code,'DEFERRED', ACCOUNTS.tax_account_ccid, acctinfo.dist_code_combination_id)),
	  pre.accounting_date,
	  inv.invoice_num,
	  dis.amount,
	  inv.cancelled_date,
	  pre.amount,
	  inv.invoice_amount,
	  inv.exchange_rate;


        --Code to updated the records with the balancing segment description
	FOR c_balancing_segment IN company_info
	LOOP
		SELECT distinct ffv.description
		INTO l_company_desc
	        FROM   fnd_id_flex_segments_vl fif
		       ,fnd_flex_values_vl      ffv
	        WHERE  fif.id_flex_code = 'GL#'
	        AND    fif.application_id = 101
	        AND    fif.id_flex_num = g_struct_num
	        AND    ffv.flex_value = c_balancing_segment.jg_info_v5
	        AND    ffv.flex_value_set_id = fif.flex_value_set_id;

		UPDATE jg_zz_vat_trx_gt
		SET jg_info_v10 = l_company_desc
		WHERE jg_info_v5 = c_balancing_segment.jg_info_v5;
	END LOOP;
	CLOSE company_info;


        EXCEPTION
          WHEN OTHERS THEN
            fnd_file.put_line(fnd_file.log,' An error occured while inserting and updating data to the global tmp table. Error : ' || SUBSTR(SQLERRM, 1, 200));
        END;

      ELSE
      --If calling report is not JEFRTXDC
        BEGIN
          FOR c_data_rec1 IN C_GENERIC(l_start_date, l_end_date)
          LOOP

            FOR c_trx_ccid IN c_get_trx_ccid (c_data_rec1.invoice_id
                                            , c_data_rec1.application_id
                                            , c_data_rec1.event_class_code
                                            , c_data_rec1.trx_line_id
                                            , c_data_rec1.entity_code)
            LOOP
              l_trx_ccid := c_trx_ccid.code_combination_id;
            END LOOP;

            FOR c_tax_ccid IN c_get_tax_ccid (c_data_rec1.invoice_id
                                            , c_data_rec1.application_id
                                            , c_data_rec1.event_class_code
                                            , c_data_rec1.trx_line_id
                                            , c_data_rec1.entity_code)
            LOOP
              l_tax_ccid := c_tax_ccid.code_combination_id;
            END LOOP;

            l_acc_no := get_accounting_segment(l_tax_ccid);
            l_company := get_balancing_segment(l_trx_ccid, l_company_desc);

            INSERT INTO JG_ZZ_VAT_TRX_GT
              (jg_info_v1                   --ven_name
              ,jg_info_v2                   --ven_no
              ,jg_info_v3                   --inv_type
              ,jg_info_n1                   --tax_amt
              ,jg_info_n2                   --rec_per
              ,jg_info_v4                   --company
              ,jg_info_v5                   --acc_no
              ,jg_info_n3                   --tax_rate
              ,jg_info_v6                   --tax_id
              ,jg_info_v7                   --offset_tax_rate_code
              ,jg_info_v8                   --tax_type
              ,jg_info_v9                   --inv_no
              ,jg_info_d1                   --acc_date
              ,jg_info_n4                   --invoice_id
              ,jg_info_d2                   --cancelled_date
              ,jg_info_n5                   --item_line_cnt
              ,jg_info_n6                   --charge_dist_id
              ,jg_info_d3                   --check_void_date
              ,jg_info_n7                   --pay_amt
              ,jg_info_v10                  --line_type_lookup_code
              ,jg_info_v11                  --line_type_lookup_code_item
              ,jg_info_v12                  --line_type_lookup_code_prepay
              ,jg_info_v13                  --reversal_flag_item
              ,jg_info_v14                  --reversal_flag_pay
              ,jg_info_v15                  --reversal_flag_prepay
              ,jg_info_n8                   --parent_reversal_id
              ,jg_info_n9                   --base_amount
              ,jg_info_n10                  --invoice_amount
              ,jg_info_d4                   --void_date
              ,jg_info_d5                   --future_pay_due_date
              ,jg_info_d6                   --check_date
              ,jg_info_v16                  --payment_status_flag
              ,jg_info_d7                   --accounting_date
              ,jg_info_n11                  --reversal_inv_pmt_id
              ,jg_info_v17                  --c_company
               )
            VALUES
              (c_data_rec1.ven_name                         --jg_info_v1
              ,c_data_rec1.ven_no                           --jg_info_v2
              ,c_data_rec1.inv_type                         --jg_info_v3
              ,c_data_rec1.tax_amt                          --jg_info_n1
              ,c_data_rec1.rec_per                          --jg_info_n2
              ,c_data_rec1.company                          --jg_info_v4
              ,c_data_rec1.acc_no                           --jg_info_v5
              ,c_data_rec1.tax_rate                         --jg_info_n3
              ,c_data_rec1.tax_id                           --jg_info_v6
              ,c_data_rec1.offset_tax_rate_code             --jg_info_v7
              ,c_data_rec1.tax_type                         --jg_info_v8
              ,c_data_rec1.inv_no                           --jg_info_v9
              ,c_data_rec1.acc_date                         --jg_info_d1
              ,c_data_rec1.invoice_id                       --jg_info_n4
              ,c_data_rec1.cancelled_date                   --jg_info_d2
              ,c_data_rec1.item_line_cnt                    --jg_info_n5
              ,c_data_rec1.charge_dist_id                   --jg_info_n6
              ,c_data_rec1.check_void_date                  --jg_info_d3
              ,c_data_rec1.pay_amt                          --jg_info_n7
              ,c_data_rec1.line_type_lookup_code            --jg_info_v10
              ,c_data_rec1.line_type_lookup_code_item       --jg_info_v11
              ,c_data_rec1.line_type_lookup_code_prepay     --jg_info_v12
              ,c_data_rec1.reversal_flag_item               --jg_info_v13
              ,c_data_rec1.reversal_flag_pay                --jg_info_v14
              ,c_data_rec1.reversal_flag_prepay             --jg_info_v15
              ,c_data_rec1.parent_reversal_id               --jg_info_n8
              ,c_data_rec1.base_amount                      --jg_info_n9
              ,c_data_rec1.invoice_amount                   --jg_info_n10
              ,c_data_rec1.void_date                        --jg_info_d4
              ,c_data_rec1.future_pay_due_date              --jg_info_d5
              ,c_data_rec1.check_date                       --jg_info_d6
              ,c_data_rec1.payment_status_flag              --jg_info_v16
              ,c_data_rec1.accounting_date                  --jg_info_d7
              ,c_data_rec1.reversal_inv_pmt_id              --jg_info_n11
              ,l_company_desc                               --jg_info_v17
               );

          END LOOP;

      EXCEPTION
        WHEN OTHERS THEN
          fnd_file.put_line(fnd_file.log,' An error occured while inserting data into the global tmp table in the generic cursor. Error : ' || SUBSTR(SQLERRM, 1, 200));
      END;
      END IF;
      IF (P_COMPANY IS NOT NULL) THEN

        get_boiler_plates;

      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        fnd_file.put_line(fnd_file.log,' An unexpected error occured in the before report trigger. Error : ' || SUBSTR(SQLERRM, 1, 200));
        RETURN FALSE;
    END;
	fnd_file.put_line(fnd_file.log,'End of the before report trigger ');

    RETURN(TRUE);
  END;

/*
REM +======================================================================+
REM Name: C_PRT_INV_AMTFormula
REM
REM Description: This function is used to calculate the invoice
REM              amount.
REM
REM Parameters:
REM             p_cancelled_date => The invoice cancellation date
REM             P_START_DATE => Period Start date
REM             P_END_DATE => Period end date
REM             p_real_inv_amt => actual invoice amount
REM +======================================================================+
*/
  FUNCTION C_PRT_INV_AMTFormula
  (
    p_cancelled_date IN DATE
   ,p_start_date     IN DATE
   ,p_end_date       IN DATE
   ,p_real_inv_amt   IN NUMBER
  ) RETURN VARCHAR2 IS
  BEGIN

    IF p_cancelled_date IS NOT NULL
       AND p_cancelled_date BETWEEN p_start_date AND p_end_date THEN
      RETURN(0);
    ELSE
      RETURN(p_real_inv_amt);

    END IF;
  END;

/*
REM +======================================================================+
REM Name: g_companygroupfilter
REM
REM Description: This function is used as a group filter for grouping the data
REM
REM Parameters:
REM +======================================================================+
*/
  FUNCTION g_companygroupfilter(company IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN

    IF (G_DATA_FOUND IS NULL) THEN
      G_DATA_FOUND := company;
      RETURN(TRUE);
    ELSE
      RETURN(TRUE);
    END IF;
    RETURN(TRUE);
  END;

/*
REM +======================================================================+
REM Name: get_lookup_meaning
REM
REM Description: This procedure returns the lookup meaning of the lookup code provided
REM
REM Parameters:
REM             p_lookup_type => The lookup type
REM             p_lookup_code => Lookup code
REM             x_lookup_meaning => Lookup meaning.
REM +======================================================================+
*/
  PROCEDURE get_lookup_meaning
  (
    p_lookup_type    IN VARCHAR2
   ,p_lookup_code    IN VARCHAR2
   ,x_lookup_meaning IN OUT NOCOPY VARCHAR2
  ) IS

    w_meaning VARCHAR2(80);

    CURSOR c_lookup_meaning (p_lookup_type     VARCHAR2
                            ,p_lookup_code     VARCHAR2)
    IS
      SELECT meaning
      FROM   fnd_lookups
      WHERE  lookup_type = p_lookup_type
      AND    lookup_code = p_lookup_code;

  BEGIN

    FOR c_meaning IN c_lookup_meaning (p_lookup_type, p_lookup_code)
    LOOP
      w_meaning := c_meaning.meaning;
    END LOOP;

    x_lookup_meaning := w_meaning;

  EXCEPTION
    WHEN no_data_found THEN
      x_lookup_meaning := NULL;
  END;

/*
REM +======================================================================+
REM Name: get_boiler_plates
REM
REM Description: This procedure sets the company title and industry code
REM
REM Parameters:
REM +======================================================================+
*/
  PROCEDURE get_boiler_plates IS

    w_industry_code VARCHAR2(20);
    w_industry_stat VARCHAR2(20);

  BEGIN

    IF fnd_installation.get(0, 0, w_industry_stat, w_industry_code) THEN
      IF w_industry_code = 'C' THEN
        G_company_title := NULL;
      ELSE
        get_lookup_meaning('IND_COMPANY', w_industry_code, G_company_title);
      END IF;
    END IF;

    G_INDUSTRY_CODE := w_Industry_code;

  END;


/*
REM +======================================================================+
REM Name: c_payment_amtformula
REM
REM Description: This function calculates the payment amount
REM
REM Parameters:
REM             p_tax_type => Tax type
REM             p_inv_type => Invoice Type
REM             p_invoice_id => Invoice Id
REM             p_pay_amt =>
REM             p_start_date => Period start date
REM             p_end_date => period end date
REM +======================================================================+
*/
  FUNCTION c_payment_amtformula
  (
    p_tax_type   IN VARCHAR2
   ,p_inv_type   IN VARCHAR2
   ,p_invoice_id IN NUMBER
   ,p_pay_amt    IN NUMBER
   ,p_start_date IN DATE
   ,p_end_date   IN DATE
  ) RETURN NUMBER IS
    l_prep_pay_amt  NUMBER := 0;
    l_payment_amt   NUMBER := 0;
    l_ppp_amt       NUMBER := 0;
    l_total_payment NUMBER := 0;

    CURSOR c_get_amount (p_invoice_id        NUMBER
                        ,p_start_date        DATE
                        ,p_end_date          DATE)
    IS
      SELECT SUM(nvl(p.invoice_base_amount, p.amount)) amount
      FROM   ap_invoice_payments p
      WHERE  p.invoice_id = p_invoice_id
      AND    p.accounting_date BETWEEN p_start_date AND p_end_date;

    CURSOR c_get_prepay_amount ( p_invoice_id        NUMBER
                                ,p_start_date        DATE
                                ,p_end_date          DATE)
    IS
      SELECT SUM(nvl(pp.base_amount, pp.amount) + nvl(ppt.base_amount, ppt.amount)) prepay_amount
      FROM   ap_invoice_distributions pp
            ,ap_invoice_distributions ppt
      WHERE  pp.invoice_id = p_invoice_id
      AND    ppt.invoice_id = p_invoice_id
      AND    pp.line_type_lookup_code = 'PREPAY'
      AND    pp.charge_applicable_to_dist_id = ppt.invoice_distribution_id
      AND    nvl(pp.reversal_flag, 'N') <> 'Y'
      AND    pp.accounting_date BETWEEN p_start_date AND p_end_date;

    CURSOR c_get_pre_pay_amount (p_invoice_id        NUMBER
                                ,p_start_date        DATE
                                ,p_end_date          DATE)
    IS
      SELECT (-1) * SUM(nvl(ppp.base_amount, ppp.amount))  prepay_amount
      FROM   ap_invoice_distributions ppp
      WHERE  ppp.invoice_id = p_invoice_id
      AND    ppp.line_type_lookup_code = 'PREPAY'
      AND    nvl(ppp.reversal_flag, 'N') <> 'Y'
      AND    ppp.accounting_date BETWEEN p_start_date AND p_end_date
      AND    NOT EXISTS (SELECT 'x'
              FROM   ap_invoice_distributions ptax
              WHERE  ptax.invoice_id = p_invoice_id
              AND    ppp.charge_applicable_to_dist_id = ptax.invoice_distribution_id);


  BEGIN

    IF p_tax_type = 'CRE/M'
       AND p_inv_type <> 'PREPAYMENT_APPLICATION' THEN
      IF p_inv_type LIKE '%JEPP' THEN

        FOR c_amount IN c_get_amount (p_invoice_id, p_start_date, p_end_date)
        LOOP
          l_payment_amt := c_amount.amount;
        END LOOP;

        FOR c_prepay_amount IN c_get_prepay_amount (p_invoice_id, p_start_date, p_end_date)
        LOOP
          l_prep_pay_amt := c_prepay_amount.prepay_amount;
        END LOOP;

        IF l_prep_pay_amt IS NULL THEN

          FOR c_pre_pay_amount IN c_get_pre_pay_amount (p_invoice_id, p_start_date, p_end_date)
          LOOP
            l_prep_pay_amt := c_pre_pay_amount.prepay_amount;
          END LOOP;

        END IF;

        l_total_payment := abs(l_prep_pay_amt) + nvl(l_payment_amt, 0);

        RETURN(l_total_payment);

      ELSE

        l_prep_pay_amt := 0;

      END IF;

      FOR c_pre_pay_amount IN c_get_pre_pay_amount (p_invoice_id, p_start_date, p_end_date)
      LOOP
        l_ppp_amt := c_pre_pay_amount.prepay_amount;
      END LOOP;

      FOR c_amount IN c_get_amount (p_invoice_id, p_start_date, p_end_date)
      LOOP
        l_payment_amt := c_amount.amount;
      END LOOP;

      l_total_payment := round(nvl(l_payment_amt, 0) -
                               nvl(l_prep_pay_amt, 0) - nvl(l_ppp_amt, 0),
                               G_PRECISION);

    ELSE
      l_total_payment := p_pay_amt;
    END IF;

    RETURN(l_total_payment);
  EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,' An error occured while calculating the payment amount. Error : ' || SUBSTR(SQLERRM, 1, 200));
  END;

/*
REM +======================================================================+
REM Name: cf_rec_tax_calcformula
REM
REM Description: This function calculates the recoverable tax
REM
REM Parameters:
REM             p_rec_per =>
REM +======================================================================+
*/
  FUNCTION cf_rec_tax_calcformula(p_rec_per IN NUMBER) RETURN CHAR IS
    l_rec_rate NUMBER;
  BEGIN

    IF p_rec_per IS NOT NULL THEN
      RETURN(to_char(round(p_rec_per, 2)) || '%');
    ELSE
      RETURN(NULL);
    END IF;
  END;

/*
REM +======================================================================+
REM Name: C_PRT_AMT_TXBLFormula
REM
REM Description: This function calculates the amount taxable
REM
REM Parameters:
REM             p_tax_type,p_const_num,p_inv_type,p_tax_rate,p_invoice_id
REM             p_tax_id,p_start_date,p_end_date,p_real_inv_amt,p_cancelled_date
REM             p_check_void_date,p_payment_amt,p_txbl_disc_amt,p_tax_disc_amt
REM +======================================================================+
*/
  FUNCTION C_PRT_AMT_TXBLFormula
  (
    p_tax_type                VARCHAR2
   ,p_const_num               VARCHAR2
   ,p_inv_type                VARCHAR2
   ,p_tax_rate                NUMBER
   ,p_invoice_id              NUMBER
   ,p_tax_id                  NUMBER
   ,p_offset_tax_rate_code    VARCHAR2
   ,p_start_date              DATE
   ,p_end_date                DATE
   ,p_real_inv_amt            NUMBER
   ,p_cancelled_date          DATE
   ,p_check_void_date         DATE
   ,p_payment_amt             NUMBER
   ,p_txbl_disc_amt           NUMBER
   ,p_tax_disc_amt            NUMBER
  ) RETURN VARCHAR2 IS

  BEGIN

    DECLARE
      tbl_amt          NUMBER;
      l_payment_amt    NUMBER;
      tbl_amt1         NUMBER;
      l_error_position VARCHAR2(20);
      l_taxable_amount NUMBER;

      CURSOR c_get_amount (  p_invoice_id         NUMBER
                            ,p_tax_id             NUMBER
                            ,p_start_date         DATE
                            ,p_end_date           DATE)
      IS
        SELECT  SUM(nvl(dis.base_amount, dis.amount)) amount
	FROM   ap_invoice_distributions dis
	WHERE  dis.invoice_id = p_invoice_id
	AND    dis.line_type_lookup_code NOT IN ('REC_TAX','NONREC_TAX','PREPAY')
	AND    dis.accounting_date BETWEEN p_start_date AND p_end_date;


     CURSOR c_get_off_amount (   p_invoice_id             NUMBER
                                ,p_offset_tax_rate_code   VARCHAR2
                                ,p_start_date             DATE
                                ,p_end_date               DATE)
      IS
        SELECT SUM(nvl(dis.base_amount, dis.amount))  amount
        FROM   ap_invoice_distributions dis
              ,zx_rates_b               tax
        WHERE  dis.line_type_lookup_code NOT IN ('TAX', 'PREPAY')
        AND    tax.tax_rate_id = dis.tax_code_id
        AND    dis.invoice_id = p_invoice_id
        AND    tax.offset_tax_rate_code = p_offset_tax_rate_code
        AND    dis.accounting_date BETWEEN p_start_date AND p_end_date;

      CURSOR c_get_amount_prepay (   p_invoice_id         NUMBER
                                    ,p_tax_id             NUMBER
                                    ,p_start_date         DATE
                                    ,p_end_date           DATE)
      IS
        SELECT SUM(nvl(dis.base_amount, dis.amount))  amount
        FROM   ap_invoice_distributions dis
              ,zx_rates_b               tax
        WHERE  tax.tax_rate_id = dis.tax_code_id
        AND    dis.invoice_id = p_invoice_id
        AND    tax.tax_rate_id = p_tax_id
        AND    dis.line_type_lookup_code = 'PREPAY'
        AND    dis.accounting_date BETWEEN p_start_date AND p_end_date;

      CURSOR c_get_amount_deb (  p_invoice_id         NUMBER
                                ,p_tax_id             NUMBER
                                ,p_start_date         DATE
                                ,p_end_date           DATE)
      IS
        SELECT SUM(nvl(dis.base_amount, dis.amount) * aip.discount_lost / p_real_inv_amt) amount
        FROM   ap_invoice_distributions dis
              ,zx_rates_b               tax
              ,ap_invoice_payments      aip
              ,ap_invoices              inv
        WHERE  dis.line_type_lookup_code NOT IN ('TAX', 'PREPAY')
        AND    inv.invoice_id = dis.invoice_id
        AND    inv.invoice_id = aip.invoice_id
        AND    dis.invoice_id = p_invoice_id
        AND    tax.tax_rate_id = dis.tax_code_id
        AND    tax.tax_rate_id = p_tax_id
        AND    aip.accounting_date BETWEEN p_start_date AND p_end_date;

      CURSOR c_get_off_amount_deb (  p_invoice_id             NUMBER
                                    ,p_offset_tax_rate_code   VARCHAR2
                                    ,p_start_date             DATE
                                    ,p_end_date               DATE)
      IS
        SELECT SUM(nvl(dis.base_amount, dis.amount) * aip.discount_lost / p_real_inv_amt)  amount
        FROM   ap_invoice_distributions dis
              ,zx_rates_b               tax
              ,ap_invoice_payments      aip
              ,ap_invoices              inv
        WHERE  dis.line_type_lookup_code NOT IN ('TAX', 'PREPAY')
        AND    inv.invoice_id = dis.invoice_id
        AND    inv.invoice_id = aip.invoice_id
        AND    dis.invoice_id = p_invoice_id
        AND    tax.tax_rate_id = dis.tax_code_id
        AND    tax.offset_tax_rate_code = p_offset_tax_rate_code
        AND    aip.accounting_date BETWEEN p_start_date AND p_end_date;

      CURSOR c_get_amount_cre_rev (  p_invoice_id         NUMBER
                                    ,p_tax_id             NUMBER)
      IS
        SELECT (-1) * SUM(nvl(dis.base_amount, dis.amount))  amount
        FROM   ap_invoice_distributions dis
              ,zx_rates_b               tax
        WHERE  dis.line_type_lookup_code NOT IN ('TAX', 'PREPAY')
        AND    dis.invoice_id = p_invoice_id
        AND    tax.tax_rate_id = p_tax_id
        AND    dis.tax_code_id = tax.tax_rate_id
        AND    dis.parent_reversal_id IS NOT NULL;

      CURSOR c_get_amount_cre (  p_invoice_id         NUMBER
                                ,p_tax_id             NUMBER)
      IS
        SELECT SUM(nvl(dis.base_amount, dis.amount))  amount
        FROM   ap_invoice_distributions dis
              ,zx_rates_b               tax
        WHERE  dis.line_type_lookup_code NOT IN ('TAX', 'PREPAY')
        AND    dis.invoice_id = p_invoice_id
        AND    tax.tax_rate_id = p_tax_id
        AND    dis.tax_code_id = tax.tax_rate_id;

      CURSOR c_get_off_amount_cre (  p_invoice_id             NUMBER
                                    ,p_offset_tax_rate_code   VARCHAR2)
      IS
        SELECT SUM(nvl(dis.base_amount, dis.amount))  amount
        FROM   ap_invoice_distributions dis
              ,zx_rates_b               tax
        WHERE  dis.line_type_lookup_code NOT IN ('TAX', 'PREPAY')
        AND    dis.invoice_id = p_invoice_id
        AND    tax.offset_tax_rate_code = p_offset_tax_rate_code
        AND    dis.tax_code_id = tax.tax_rate_id;

      CURSOR c_get_amount_cre_calc (  p_invoice_id         NUMBER
                                     ,p_tax_id             NUMBER)
      IS
        SELECT SUM(nvl(dis.base_amount, dis.amount)) * (p_payment_amt / p_real_inv_amt)  amount
        FROM   ap_invoice_distributions dis
              ,zx_rates_b               tax
        WHERE  dis.line_type_lookup_code NOT IN ('TAX', 'PREPAY')
        AND    dis.invoice_id = p_invoice_id
        AND    tax.tax_rate_id = p_tax_id
        AND    dis.tax_code_id = tax.tax_rate_id;

    BEGIN

      IF p_tax_type = 'DEB/M'
         AND p_const_num = 'A' THEN
        IF p_inv_type <> 'PREPAYMENT_APPLICATION' THEN
          IF p_tax_rate >= 0 THEN

	   FOR c_amt IN c_get_amount (p_invoice_id, p_tax_id, p_start_date, p_end_date )
            LOOP
              tbl_amt := c_amt.amount;
            END LOOP;

          ELSIF p_tax_rate < 0 THEN
            FOR c_off_amt IN c_get_off_amount (p_invoice_id, p_offset_tax_rate_code, p_start_date, p_end_date )
            LOOP
              tbl_amt := c_off_amt.amount;
            END LOOP;

          END IF;
        ELSE

          FOR c_amt_prepay IN c_get_amount_prepay (p_invoice_id, p_tax_id, p_start_date, p_end_date )
          LOOP
            tbl_amt := c_amt_prepay.amount;
          END LOOP;

        END IF;
      ELSIF p_tax_type = 'DEB/M'
            AND p_const_num = 'C' THEN
        IF p_tax_rate >= 0 THEN
          FOR c_amt_deb IN c_get_amount_deb (p_invoice_id, p_tax_id, p_start_date, p_end_date )
          LOOP
            tbl_amt := c_amt_deb.amount;
          END LOOP;

        ELSIF p_tax_rate < 0 THEN
          FOR c_off_amt_deb IN c_get_off_amount_deb (p_invoice_id, p_offset_tax_rate_code, p_start_date, p_end_date )
          LOOP
            tbl_amt := c_off_amt_deb.amount;
          END LOOP;

        END IF;
      ELSIF p_tax_type = 'CRE/M' THEN
        IF p_inv_type <> 'PREPAYMENT_APPLICATION' THEN
          IF p_inv_type NOT LIKE '%JEPP' THEN

            IF p_tax_rate >= 0 THEN

              IF p_cancelled_date IS NOT NULL THEN

                IF p_check_void_date BETWEEN p_start_date AND p_end_date THEN
                  tbl_amt := 0;
                ELSE

                  FOR c_amt_cre_rev IN c_get_amount_cre_rev (p_invoice_id, p_tax_id)
                  LOOP
                    tbl_amt := c_amt_cre_rev.amount;
                  END LOOP;

                END IF;

              ELSE

                FOR c_amt_cre IN c_get_amount_cre (p_invoice_id, p_tax_id)
                LOOP
                  tbl_amt := c_amt_cre.amount;
                END LOOP;

              END IF;

            ELSIF p_tax_rate < 0 THEN
              FOR c_off_amt_cre IN c_get_off_amount_cre (p_invoice_id, p_offset_tax_rate_code)
              LOOP
                tbl_amt := c_off_amt_cre.amount;
              END LOOP;

            END IF;

          ELSE

            IF p_tax_rate >= 0 THEN
              FOR c_amt_cre_calc IN c_get_amount_cre_calc (p_invoice_id, p_tax_id)
              LOOP
                tbl_amt := c_amt_cre_calc.amount;
              END LOOP;

              l_taxable_amount := to_char(round(tbl_amt, G_PRECISION));

            ELSIF p_tax_rate < 0 THEN
              FOR c_off_amt_cre_l IN c_get_off_amount_cre (p_invoice_id, p_offset_tax_rate_code)
              LOOP
                tbl_amt := c_off_amt_cre_l.amount;
              END LOOP;

              l_taxable_amount := tbl_amt;
            END IF;

          END IF;

        ELSE
          FOR c_amt_prepay_l IN c_get_amount_prepay (p_invoice_id, p_tax_id, p_start_date, p_end_date )
          LOOP
            tbl_amt := c_amt_prepay_l.amount;
          END LOOP;

        END IF;
      END IF;

      IF ((p_tax_type = 'DEB/M') OR ((p_tax_type = 'CRE/M') AND
         (p_inv_type = 'PREPAYMENT_APPLICATION' OR
         p_inv_type LIKE '%JEPP'))) THEN
        l_taxable_amount := to_char(round(tbl_amt, G_PRECISION));
      ELSE
        IF p_real_inv_amt - p_txbl_disc_amt - p_tax_disc_amt = 0 THEN
          l_taxable_amount := to_char(round(((-1) * tbl_amt -
                                            p_txbl_disc_amt), G_PRECISION));
        ELSE
          l_taxable_amount := to_char(round((tbl_amt - p_txbl_disc_amt) *
                                            p_payment_amt / (p_real_inv_amt -
                                            p_txbl_disc_amt -
                                            p_tax_disc_amt), G_PRECISION));
        END IF;
      END IF;

      RETURN(l_taxable_amount); -- currency format this amount for use.

    EXCEPTION
      WHEN OTHERS THEN
        fnd_file.put_line(fnd_file.log,' An error occured while calculating the amount taxable. Error : ' || SUBSTR(SQLERRM, 1, 200));
        raise_application_error(-20101, NULL);
    END;

  END;

/*
REM +======================================================================+
REM Name: cf_tax_amtformula
REM
REM Description: This function calculates the amount taxable
REM
REM Parameters:
REM             p_invoice_id,p_tax_type,p_inv_type,p_real_inv_amt,p_txbl_discount_amt
REM             p_tax_amt,p_payment_amt,p_check_void_date,p_start_date,p_end_date
REM +======================================================================+
*/
  FUNCTION cf_tax_amtformula
  (
    p_invoice_id        IN NUMBER
   ,p_tax_type          IN VARCHAR2
   ,p_inv_type          IN VARCHAR2
   ,p_real_inv_amt      IN NUMBER
   ,p_txbl_discount_amt IN NUMBER
   ,p_tax_amt           IN NUMBER
   ,p_payment_amt       IN NUMBER
   ,p_check_void_date   IN DATE
   ,p_start_date        IN DATE
   ,p_end_date          IN DATE
  ) RETURN NUMBER IS
    l_inv_remaining_amount NUMBER := 0;
    l_pp_tax_amount        NUMBER;

    CURSOR c_get_inv_remain_amt (p_end_date    DATE)
    IS
      SELECT round(SUM(nvl(dis.base_amount, dis.amount)), G_PRECISION) remaining_amount
      FROM   ap_invoice_distributions dis
      WHERE  dis.invoice_id = p_invoice_id
      AND    dis.accounting_date <= p_end_date;

  BEGIN

    FOR c_inv_remain_amt IN c_get_inv_remain_amt (p_end_date)
    LOOP
      l_inv_remaining_amount := c_inv_remain_amt.remaining_amount;
    END LOOP;

    IF ((p_tax_type = 'DEB/M') OR
       ((p_tax_type = 'CRE/M') AND
       (p_inv_type = 'PREPAYMENT_APPLICATION' OR p_inv_type LIKE '%JEPP'))) THEN
      IF (((p_real_inv_amt - p_txbl_discount_amt - G_tax_discount_amt) = 0) or (p_tax_type = 'DEB/M')) THEN
	RETURN(round(p_tax_amt, G_PRECISION));
      ELSE
        RETURN(round((p_tax_amt - G_tax_discount_amt) * p_payment_amt /
                     (p_real_inv_amt - p_txbl_discount_amt -
                     G_tax_discount_amt), G_PRECISION));
      END IF;
    ELSE
      IF (p_real_inv_amt - p_txbl_discount_amt - G_tax_discount_amt = 0)
         OR (l_inv_remaining_amount - p_payment_amt - p_txbl_discount_amt -
         G_tax_discount_amt <= 0) THEN

        IF p_check_void_date IS NOT NULL
           AND p_check_void_date BETWEEN p_start_date AND p_end_date THEN
          IF p_check_void_date BETWEEN p_start_date AND p_end_date THEN

            RETURN 0;
          ELSE

            RETURN(round((-1 * p_tax_amt - G_tax_discount_amt), G_PRECISION));
          END IF;
        ELSE


          RETURN(round((p_tax_amt - G_tax_discount_amt) * p_payment_amt /
                       (p_real_inv_amt - p_txbl_discount_amt -
                       G_tax_discount_amt), G_PRECISION));
        END IF;
      ELSE

        RETURN(round((p_tax_amt - G_tax_discount_amt) * p_payment_amt /
                     (p_real_inv_amt - p_txbl_discount_amt -
                     G_tax_discount_amt), G_PRECISION));
      END IF;
    END IF;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(round(p_tax_amt, G_PRECISION));
  END;

/*
REM +======================================================================+
REM Name: cf_txbl_discount_amtformula
REM
REM Description: This function calculates the taxable discount amount
REM
REM Parameters:
REM             p_invoice_id,p_tax_type,p_inv_type,p_tax_rate,
REM             p_start_date,p_end_date
REM +======================================================================+
*/
  FUNCTION cf_txbl_discount_amtformula
  (
    p_tax_type   IN VARCHAR2
   ,p_inv_type   IN VARCHAR2
   ,p_invoice_id IN NUMBER
   ,p_tax_rate   IN NUMBER
   ,p_start_date IN DATE
   ,p_end_date   IN DATE
  ) RETURN NUMBER IS
    l_discount_amt NUMBER := 0;
    l_txbl_damt    NUMBER := 0;

    CURSOR c_get_discount_amt (p_invoice_id        NUMBER
                              ,p_start_date        DATE
                              ,p_end_date          DATE)
    IS
      SELECT SUM(nvl(disc.discount_taken, 0)) discount_taken
      FROM   ap_invoice_payments disc
            ,ap_checks           chk
      WHERE  disc.invoice_id = p_invoice_id
      AND    disc.check_id = chk.check_id
      AND    nvl(chk.future_pay_due_date, chk.check_date) BETWEEN
             p_start_date AND p_end_date;

  BEGIN
    IF p_tax_type = 'CRE/M' AND p_inv_type <> 'PREPAYMENT_APPLICATION' THEN
      BEGIN

        FOR c_discount_amt IN c_get_discount_amt (p_invoice_id, p_start_date, p_end_date)
        LOOP
          l_discount_amt := c_discount_amt.discount_taken;
        END LOOP;

      EXCEPTION
        WHEN OTHERS THEN
          fnd_file.put_line(fnd_file.log,' An error occured while calculating the taxable discount amount. Error : ' || SUBSTR(SQLERRM, 1, 200));
          l_discount_amt := 0;
      END;
    END IF;

    IF G_disc_isinvlesstax_flag <> 'Y' THEN
      l_txbl_damt := round(l_discount_amt * (100 - p_tax_rate) / 100, G_PRECISION);
    ELSE
      l_txbl_damt := l_discount_amt;
    END IF;

    G_tax_discount_amt := l_discount_amt - l_txbl_damt;

    RETURN(l_txbl_damt);
  END;

/*
REM +======================================================================+
REM Name: cf_item_tax_amtformula
REM
REM Description: This function calculates the item tax amount
REM
REM Parameters:
REM             p_cancelled_date,p_acc_date,p_tax_amt,p_item_line_cnt,
REM             p_start_date,p_end_date
REM +======================================================================+
*/
  FUNCTION cf_item_tax_amtformula
  (
    p_cancelled_date IN DATE
   ,p_acc_date       IN DATE
   ,p_tax_amt        IN NUMBER
   ,p_item_line_cnt  IN NUMBER
   ,p_start_date     IN DATE
   ,p_end_date       IN DATE
  ) RETURN NUMBER IS
  BEGIN
    IF p_cancelled_date IS NOT NULL
       AND p_acc_date BETWEEN p_start_date AND p_end_date THEN
      RETURN((-1) * (p_tax_amt / p_item_line_cnt));
    ELSE

      RETURN(p_tax_amt / p_item_line_cnt);

    END IF;
  END;

/*
REM +======================================================================+
REM Name: cf_real_inv_amtformula
REM
REM Description: This function calculates the actual invoice amount
REM
REM Parameters:
REM             p_invoice_id,p_invoice_amount
REM +======================================================================+
*/
  FUNCTION cf_real_inv_amtformula
  (
    p_invoice_id     IN NUMBER
   ,p_invoice_amount IN NUMBER
  ) RETURN NUMBER IS
    l_iipp_amt NUMBER;

    CURSOR c_get_inv_prepay_amt (p_invoice_id      NUMBER)
    IS
      SELECT SUM(decode(invoice_includes_prepay_flag, 'Y', nvl(base_amount, amount), 0)) iipp_amt
      FROM   ap_invoice_distributions
      WHERE  invoice_id = p_invoice_id;

  BEGIN

    FOR c_inv_prepay_amt IN c_get_inv_prepay_amt (p_invoice_id)
    LOOP
      l_iipp_amt := c_inv_prepay_amt.iipp_amt;
    END LOOP;

    RETURN(p_invoice_amount - l_iipp_amt);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN(p_invoice_amount);
  END;


/*
REM +======================================================================+
REM Name: G_DATA_FOUND_formula
REM
REM Description: Checks if company was found
REM
REM Parameters:
REM +======================================================================+
*/
  FUNCTION G_DATA_FOUND_formula RETURN VARCHAR2 IS
  BEGIN
    RETURN G_DATA_FOUND;
  END;

/*
REM +======================================================================+
REM Name: G_CURR_NAME_formula
REM
REM Description: Returns the currency
REM
REM Parameters:
REM +======================================================================+
*/
  FUNCTION G_CURR_NAME_formula RETURN VARCHAR2 IS
  BEGIN
    RETURN G_CURR_NAME;
  END;

/*
REM +======================================================================+
REM Name: G_company_title_formula
REM
REM Description: Returns the company title
REM
REM Parameters:
REM +======================================================================+
*/
  FUNCTION G_company_title_formula RETURN VARCHAR2 IS
  BEGIN
    RETURN G_company_title;
  END;

/*
REM +======================================================================+
REM Name: G_PRECISION_formula
REM
REM Description: Returns the rounding off precision.
REM
REM Parameters:
REM +======================================================================+
*/
  FUNCTION G_PRECISION_formula RETURN NUMBER IS
  BEGIN
    RETURN G_PRECISION;
  END;

/*
REM +======================================================================+
REM Name: set_display_for_gov
REM
REM Description: Setting display for gov
REM
REM Parameters:
REM +======================================================================+
*/
  FUNCTION set_display_for_gov RETURN BOOLEAN IS
  BEGIN
    IF G_INDUSTRY_CODE = 'C' THEN
      RETURN(FALSE);
    ELSE
      IF G_company_title IS NOT NULL THEN
        RETURN(TRUE);
      ELSE
        RETURN(FALSE);
      END IF;
    END IF;
    RETURN NULL;
  END;

/*
REM +======================================================================+
REM Name: set_display_for_core
REM
REM Description: Setting display for core
REM
REM Parameters:
REM +======================================================================+
*/
  FUNCTION set_display_for_core RETURN BOOLEAN IS
  BEGIN
    IF G_INDUSTRY_CODE = 'C' THEN
      RETURN(TRUE);
    ELSE
      IF G_company_title IS NOT NULL THEN
        RETURN(FALSE);
      ELSE
        RETURN(TRUE);
      END IF;
    END IF;
    RETURN NULL;
  END;


/*
REM +======================================================================+
REM Name: G_LEDGER_CURR_FORMULA
REM
REM Description: Retuns the G_LEDGER_CURR
REM
REM Parameters:
REM +======================================================================+
*/
  FUNCTION G_LEDGER_CURR_FORMULA RETURN VARCHAR2 IS
  BEGIN

    RETURN G_LEDGER_CURR;
  END;

/*
REM +======================================================================+
REM Name: G_INDUSTRY_CODE_FORMULA
REM
REM Description: Retuns the G_INDUSTRY_CODE
REM
REM Parameters:
REM +======================================================================+
*/
  FUNCTION G_INDUSTRY_CODE_FORMULA RETURN VARCHAR2 IS
  BEGIN

    RETURN G_INDUSTRY_CODE;
  END;



/*
REM +======================================================================+
REM Name: get_accounting_segment
REM
REM Description: Fetch the accounting segment values
REM
REM Parameters:
REM +======================================================================+
*/
  FUNCTION get_accounting_segment(p_ccid    IN NUMBER) RETURN VARCHAR2 IS
    l_accounting_segment VARCHAR2(20);
    l_acc_no             VARCHAR2(25);
    l_stmt               VARCHAR2(1000);
    TYPE t_crs IS REF CURSOR;
    c_crs t_crs;
  BEGIN
    l_accounting_segment := fa_rx_flex_pkg.flex_sql(p_application_id => 101
                                                   ,p_id_flex_code   => 'GL#'
                                                   ,p_id_flex_num    => G_STRUCT_NUM
                                                   ,p_table_alias    => ''
                                                   ,p_mode           => 'SELECT'
                                                   ,p_qualifier      => 'GL_ACCOUNT');
    --     The above function will return account segment in the form CC.SEGMENT1
    --     we need to drop CC. to get the actual account segment.
    l_accounting_segment := substrb(l_accounting_segment
                                   ,instrb(l_accounting_segment
                                          ,'.') + 1);

    -- Fetch the company and acc_no information
    l_stmt := ' SELECT ' || l_accounting_segment ||
              ' FROM GL_CODE_COMBINATIONS ' ||
              ' WHERE CODE_COMBINATION_ID = :LLCID';
    OPEN c_crs FOR l_stmt
      USING p_ccid;
    LOOP
      FETCH c_crs
        INTO l_acc_no;
      EXIT WHEN c_crs%NOTFOUND;
    END LOOP;
    CLOSE c_crs;
    RETURN l_acc_no;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_file.put_line(fnd_file.log,' No record was returned for the GL_Account segment. Error : ' || SUBSTR(SQLERRM,1,200));
      RETURN NULL;
  END;

/*
REM +======================================================================+
REM Name: get_balancing_segment
REM
REM Description: Fetch the GL Balancing segment value and description
REM
REM Parameters:
REM +======================================================================+
*/
  FUNCTION get_balancing_segment
  (
    p_ccid          IN  NUMBER
   ,x_company_desc  IN  OUT NOCOPY  VARCHAR2
  )
  RETURN VARCHAR2 IS
    l_balancing_segment VARCHAR2(20);
    l_company           VARCHAR2(25);
    l_stmt              VARCHAR2(1000);
    TYPE t_crs IS REF CURSOR;
    c_crs t_crs;

    CURSOR c_balancing_desc(p_coaid NUMBER, p_company VARCHAR2)
    IS
      SELECT ffv.description
      FROM   fnd_id_flex_segments_vl fif
            ,fnd_flex_values_vl      ffv
      WHERE  fif.id_flex_code = 'GL#'
      AND    fif.application_id = 101
      AND    fif.id_flex_num = p_coaid
      AND    ffv.flex_value = p_company
      AND    ffv.flex_value_set_id = fif.flex_value_set_id;

  BEGIN
    l_balancing_segment := fa_rx_flex_pkg.flex_sql(p_application_id => 101
                                                  ,p_id_flex_code   => 'GL#'
                                                  ,p_id_flex_num    => G_STRUCT_NUM
                                                  ,p_table_alias    => ''
                                                  ,p_mode           => 'SELECT'
                                                  ,p_qualifier      => 'GL_BALANCING');

    --     The above function will return balancing segment in the form CC.SEGMENT1
    --     we need to drop CC. to get the actual balancing segment.
    l_balancing_segment := substrb(l_balancing_segment
                                  ,instrb(l_balancing_segment
                                         ,'.') + 1);

    -- Fetch the company and acc_no information
    l_stmt := ' SELECT ' || l_balancing_segment ||
              ' FROM GL_CODE_COMBINATIONS ' ||
              ' WHERE CODE_COMBINATION_ID = :LLCID';
    OPEN c_crs FOR l_stmt
      USING p_ccid;
    LOOP
      FETCH c_crs
        INTO l_company;
      EXIT WHEN c_crs%NOTFOUND;
    END LOOP;
    CLOSE c_crs;
    FOR c_bal_desc IN c_balancing_desc(G_STRUCT_NUM
                                      ,l_company)
    LOOP
      x_company_desc := c_bal_desc.description;
    END LOOP;

    RETURN l_company;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_file.put_line(fnd_file.log,' No record was returned for the GL_Balancing segment. Error : ' || SUBSTR(SQLERRM,1,200));
      RETURN NULL;
  END;

  /*
REM +======================================================================+
REM Name: get_balancing_segment
REM
REM Description: Fetch the GL Balancing segment value and description
REM
REM Parameters:
REM +======================================================================+
*/
  FUNCTION get_balancing_segment
  (
    p_ccid          IN  NUMBER
  )
  RETURN VARCHAR2 IS
    l_balancing_segment VARCHAR2(20);
    l_company           VARCHAR2(25);
    l_stmt              VARCHAR2(1000);
    TYPE t_crs IS REF CURSOR;
    c_crs t_crs;

    CURSOR c_balancing_desc(p_coaid NUMBER, p_company VARCHAR2)
    IS
      SELECT ffv.description
      FROM   fnd_id_flex_segments_vl fif
            ,fnd_flex_values_vl      ffv
      WHERE  fif.id_flex_code = 'GL#'
      AND    fif.application_id = 101
      AND    fif.id_flex_num = p_coaid
      AND    ffv.flex_value = p_company
      AND    ffv.flex_value_set_id = fif.flex_value_set_id;

  BEGIN
    l_balancing_segment := fa_rx_flex_pkg.flex_sql(p_application_id => 101
                                                  ,p_id_flex_code   => 'GL#'
                                                  ,p_id_flex_num    => G_STRUCT_NUM
                                                  ,p_table_alias    => ''
                                                  ,p_mode           => 'SELECT'
                                                  ,p_qualifier      => 'GL_BALANCING');

    --     The above function will return balancing segment in the form CC.SEGMENT1
    --     we need to drop CC. to get the actual balancing segment.
    l_balancing_segment := substrb(l_balancing_segment
                                  ,instrb(l_balancing_segment
                                         ,'.') + 1);

    -- Fetch the company and acc_no information
    l_stmt := ' SELECT ' || l_balancing_segment ||
              ' FROM GL_CODE_COMBINATIONS ' ||
              ' WHERE CODE_COMBINATION_ID = :LLCID';
    OPEN c_crs FOR l_stmt
      USING p_ccid;
    LOOP
      FETCH c_crs
        INTO l_company;
      EXIT WHEN c_crs%NOTFOUND;
    END LOOP;
    CLOSE c_crs;
	RETURN l_company;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_file.put_line(fnd_file.log,' No record was returned for the GL_Balancing segment. Error : ' || SUBSTR(SQLERRM,1,200));
      RETURN NULL;
  END;

END JE_ZZ_AUDIT_AP_PKG;

/
