--------------------------------------------------------
--  DDL for Package Body JERX_TO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JERX_TO" AS
/* $Header: jegrtob.pls 120.9.12010000.3 2010/02/18 06:52:47 gkumares ship $ */


  PROCEDURE JE_AP_TURNOVER_EXTRACT(
        errbuf             OUT NOCOPY  VARCHAR2,
  	retcode            OUT NOCOPY  NUMBER,
	p_app_short_name	in varchar2,
	p_set_of_books_id	in varchar2,
        p_period_start_date	in varchar2,
        p_period_end_date	in varchar2,
	p_range_type		in varchar2,
	p_cs_name_from		in varchar2,
	p_cs_name_to		in varchar2,
	p_cs_number_from	in varchar2,
	p_cs_number_to		in varchar2,
	p_currency_code		in varchar2,
        p_rule_id		in varchar2,
	p_inv_amount_limit	in varchar2,
	p_balance_type		in varchar2,
	p_request_id	        in number,
        p_legal_entity_id       in number)

  IS


/* This cursor selects all the records needed to populate the interface table. */

   CURSOR c_vendor_turnover IS
   SELECT
        p_request_id			ap_request_id,
	substr(pv.vendor_name,1,80)	vendor_name,
	pv.segment1			segment1,
	nvl(papf.national_identifier,nvl(pv.individual_1099,pv.num_1099)) num_1099,
	pv.vat_registration_num 	vat_registration_number,
	pvs.vendor_site_code		vendor_site_code,
	pv.standard_industry_class	standard_industry_class,
	pvs.address_line1		address_line1,
	pvs.address_line2		address_line2,
	pvs.address_line3		address_line3,
	pvs.city			city,
	pvs.state			state,
	pvs.zip				zip,
	pvs.province			province,
	pvs.country			country,
	ai.invoice_num			invoice_num,
	ai.invoice_id			invoice_id,
	ai.invoice_date			invoice_date,
	ai.invoice_currency_code	invoice_currency_code,
	sum(nvl(aid.amount,0))		distribution_total,
	ai.invoice_type_lookup_code	invoice_type_lookup_code,
	sum(nvl(aid.base_amount,0))	distribution_base_total,
	decode(nvl(pv.global_attribute1,'N'),'Y','PUBLIC SECTOR COMPANIES',
		pv.vendor_type_lookup_code)	vendor_type_lookup_code,
	0				created_by,
        sysdate				creation_date,
        sysdate				last_update_date,
        0				last_updated_by,
        NULL				last_update_login
   FROM
	po_vendors pv,
	(SELECT distinct person_id
	     ,national_identifier
	 FROM PER_ALL_PEOPLE_F  WHERE trunc(sysdate) BETWEEN effective_start_date AND effective_end_date) papf,
	po_vendor_sites_all pvs,
	ap_invoices_all 	ai,
	ap_invoice_distributions_all	aid
   WHERE
    	pv.vendor_id = ai.vendor_id
	and nvl(pv.employee_id, -99) = papf.person_id (+)
	and ai.vendor_site_id = pvs.vendor_site_id(+) and
 	((p_range_type = 'NAME' and (pv.vendor_name between
			nvl(p_cs_name_from, pv.vendor_name) and
			nvl(p_cs_name_to,pv.vendor_name))) OR
 	 (p_range_type = 'NUMBER' and (pv.segment1 between
			nvl(p_cs_number_from, pv.segment1) and
			nvl(p_cs_number_to,pv.segment1)))) and
	pvs.pay_site_flag = 'Y' and
	ai.invoice_currency_code = nvl(p_currency_code, ai.invoice_currency_code) and
	ai.set_of_books_id = TO_NUMBER(p_set_of_books_id) and
        ai.legal_entity_id = p_legal_entity_id and
	ai.invoice_id = aid.invoice_id and
	aid.accounting_date >= TO_DATE(p_period_start_date,'DD/MM/YYYY HH24:MI:SS') and
	aid.accounting_date <= TO_DATE(p_period_end_date,'DD/MM/YYYY HH24:MI:SS') and
	(aid.posted_flag = 'Y' or aid.ACCRUAL_POSTED_FLAG = 'Y' or
	  aid.CASH_POSTED_FLAG = 'Y') and
	(nvl(pv.vendor_type_lookup_code,'X') not in (select lookup_code
					    from je_gr_trnovr_rule_lines irl,
					     je_gr_trnovr_rules ir
					    where ir.trnovr_rule_id = p_rule_id
					    and irl.trnovr_rule_id = ir.trnovr_rule_id
					    and irl.lookup_type = 'VENDOR TYPE'
					    and irl.exclude_flag = 'Y' )) AND
	(ai.invoice_type_lookup_code not in (select lookup_code
					     from je_gr_trnovr_rule_lines irl,
						 je_gr_trnovr_rules ir
					     where ir.trnovr_rule_id = p_rule_id
					     and irl.trnovr_rule_id = ir.trnovr_rule_id
					     and irl.lookup_type = 'INVOICE TYPE'
					     and irl.exclude_flag = 'Y')) AND
	(aid.line_type_lookup_code not in    (select lookup_code
					      from je_gr_trnovr_rule_lines irl,
						   je_gr_trnovr_rules ir
					      where ir.trnovr_rule_id = p_rule_id
					      and irl.trnovr_rule_id = ir.trnovr_rule_id
					      and irl.lookup_type = 'INVOICE DISTRIBUTION TYPE'
					      and irl.exclude_flag = 'Y'))
   GROUP BY
        pv.vendor_name,
        pv.vendor_type_lookup_code,
        pv.standard_industry_class,
        pvs.country,
        pvs.state,
        pvs.province,
        pvs.city,
        pvs.address_line1,
        pvs.address_line2,
	pvs.address_line3,
        pvs.zip,
        ai.invoice_num,
	ai.invoice_id,
        ai.invoice_type_lookup_code,
        ai.invoice_date,
        ai.invoice_currency_code,
        pv.segment1,
        nvl(papf.national_identifier,nvl(pv.individual_1099,pv.num_1099)),
        pv.vat_registration_num,
	pv.global_attribute1,
        pvs.vendor_site_code
   HAVING
        (decode(sign(SUM(nvl(aid.base_amount,NVL(aid.amount,0)))),to_number(p_balance_type),
		abs(SUM(nvl(aid.base_amount,NVL(aid.amount,0)))),p_inv_amount_limit)) > p_inv_amount_limit;

   ctr	NUMBER		:= 0;

  BEGIN

     /* The following loop navigates through each and every record of the cursor
	and calls the generic procedure to insert the data in the interface table. */





    FOR rec in c_vendor_turnover
    LOOP
	ctr := ctr + 1;
	GENERIC_INSERT_TO_ITF(
		     errbuf,
		     retcode,
		     rec.ap_request_id,
                     rec.vendor_name,
                     rec.segment1,
                     rec.num_1099,
                     rec.vat_registration_number,
		     rec.vendor_site_code,
                     rec.standard_industry_class,
                     rec.address_line1,
                     rec.address_line2,
		     rec.address_line3,
                     rec.city,
                     rec.state,
                     rec.zip,
                     rec.province,
                     rec.country,
		     rec.invoice_num,
	             rec.invoice_id,
		     rec.invoice_date,
                     rec.invoice_currency_code,
		     rec.distribution_total,
                     rec.invoice_type_lookup_code,
                     rec.distribution_base_total,
                     rec.vendor_type_lookup_code,
		     rec.created_by,
                     rec.creation_date,
                     rec.last_update_date,
                     rec.last_updated_by,
        	     rec.last_update_login);
    END LOOP;

    IF ctr = 0 THEN
	fnd_file.put_line(FND_FILE.OUTPUT,'******* NO DATA FOUND ******');
    ELSE
    	COMMIT;
    END IF;

    fnd_file.put_line(FND_FILE.OUTPUT,'Concurrent Request Processed Successfully...');
    retcode := 0;

    EXCEPTION
		WHEN OTHERS THEN
			retcode := 2;
    			fnd_file.put_line(FND_FILE.LOG,'Error occurred during extract process...');
			ROLLBACK;

    END JE_AP_TURNOVER_EXTRACT;


    -- This  procedure extracts the data for the AR Turnover Report.

PROCEDURE JE_AR_TURNOVER_EXTRACT(
        errbuf             OUT NOCOPY  VARCHAR2,
  	retcode            OUT NOCOPY  NUMBER,
	p_app_short_name	in varchar2,
	p_set_of_books_id	in varchar2,
        p_period_start_date	in varchar2,
        p_period_end_date	in varchar2,
	p_range_type		in varchar2,
	p_cs_name_from		in varchar2,
	p_cs_name_to		in varchar2,
	p_cs_number_from	in varchar2,
	p_cs_number_to		in varchar2,
	p_currency_code		in varchar2,
        p_rule_id		in varchar2,
	p_inv_amount_limit	in varchar2,
	p_balance_type		in varchar2,
	p_request_id	        in number,
        p_legal_entity_id       in number)

  IS


 /* This cursor selects all the records needed to populate the interface table. */

 CURSOR c_customer_turnover IS

   SELECT
	p_request_id			        ar_request_id,
        party.party_name                	customer_name,
	CUST_ACCT.ACCOUNT_NUMBER	    	customer_number,
        PARTY.TAX_REFERENCE             	tax_reference,
        NULL			                vat_number,
        PARTY.SIC_CODE   	            	standard_industry_class,
        loc.address1                     	address_line1,
        loc.address2                     	address_line2,
	loc.address3		         	 address_line3,
        loc.city                         	city,
        loc.state                        	state,
        loc.postal_code                  	zip,
        loc.province                     	province,
        loc.country                      	country,
        ctt.type                        	invoice_type_lookup_code,
        ctx.trx_number                  	invoice_num,
        ctx.customer_trx_id	        	invoice_id,
        ctx.trx_date                    	invoice_date,
        ctx.invoice_currency_code       	invoice_currency_code,
        sum(cgld.amount)                	distribution_total,
        sum(cgld.acctd_amount)          	distribution_base_total,
	-- Bug 3554792
        decode(nvl(cusT_ACCT.global_attribute1,'N'),'Y','PUBLIC SECTOR COMPANIES',
		CUST_ACCT.CUSTOMER_CLASS_CODE)   customer_type_lookup_code,
        0                               	created_by,
        sysdate                         	creation_date,
        sysdate                         	last_update_date,
        0                               	last_updated_by,
        NULL                            	last_update_login
   FROM
   	ra_cust_trx_types_all 		ctt,
	ra_cust_trx_line_gl_dist_all 	cgld,
	ra_customer_trx_lines_all 	ctl,
	ra_customer_trx_all 		ctx,
	--ra_site_uses rsu,   			-- obsolete R12
	--ra_addresses ad,    			-- obsolete R12
        HZ_LOCATIONS loc,
        HZ_CUST_SITE_USES_ALL  		site_uses,
        hz_cust_acct_sites_all 		acct_site,
        hz_party_sites         		party_site,
        HZ_PARTIES 			party,
        HZ_CUST_ACCOUNTS 		cust_acct
  WHERE
     CUST_ACCT.CUST_ACCOUNT_ID = ctx.bill_to_customer_id
    and acct_site.cust_acct_site_id = site_uses.cust_acct_site_id
    and acct_site.party_site_id = party_site.party_site_id
    and loc.location_id = party_site.location_id
    and ctx.customer_trx_id = ctl.customer_trx_id
    and ctx.set_of_books_id = TO_NUMBER(p_set_of_books_id)
    and ctx.legal_entity_id = p_legal_entity_id
   -- and ctx.legal_entity_id = ctt.legal_entity_id
    and ctx.org_id = ctt.org_id		--Bug 6389667
    and CUST_ACCT.CUST_ACCOUNT_ID = acct_site.cust_account_id               --customer_id
    and ((p_range_type = 'NAME' and (PARTY.PARTY_NAME between --  Bug 3554792
	nvl(p_cs_name_from,PARTY.PARTY_NAME) and nvl(p_cs_name_to,PARTY.PARTY_NAME)))
	OR
     	(p_range_type = 'NUMBER' and (CUST_ACCT.ACCOUNT_NUMBER  between
	nvl(p_cs_number_from, CUST_ACCT.ACCOUNT_NUMBER ) and nvl(p_cs_number_to,CUST_ACCT.ACCOUNT_NUMBER ))))
--    and loc.address_id = site_uses.address_id
    and site_uses.site_use_id = ctx.bill_to_site_use_id
    and ctx.cust_trx_type_id = ctt.cust_trx_type_id
    and ctx.invoice_currency_code = nvl(p_currency_code,ctx.invoice_currency_code)
    and cgld.customer_trx_line_id = ctl.customer_trx_line_id
    and cgld.gl_date >= TO_DATE(p_period_start_date,'DD/MM/YYYY HH24:MI:SS')
    and cgld.gl_date <= TO_DATE(p_period_end_date,'DD/MM/YYYY HH24:MI:SS')
    and cgld.gl_posted_date is not null
    and CUST_ACCT.PARTY_ID = PARTY.PARTY_ID
    and (nvl(CUST_ACCT.CUSTOMER_CLASS_CODE ,'X')  not in ( select lookup_code
 	  						from
 	  							je_gr_trnovr_rule_lines  irl,
	            						je_gr_trnovr_rules ir
	 						where
	 							ir.trnovr_rule_id = p_rule_id
         							and    irl.trnovr_rule_id = ir.trnovr_rule_id
	 							and     irl.lookup_type = 'CUSTOMER CLASS'
	 							and     irl.exclude_flag = 'Y'))
    and (ctt.type not in  ( select lookup_code
 	 		  from
 	 		  	je_gr_trnovr_rule_lines  irl,
    	          		je_gr_trnovr_rules ir
	 		 where
	 		 	ir.trnovr_rule_id = p_rule_id
	 			and    irl.trnovr_rule_id = ir.trnovr_rule_id
	 			and     irl.lookup_type = 'INV/CM'
	 			and     irl.exclude_flag = 'Y'))
    and (ctl.line_type not in ( select lookup_code
 				from
 					je_gr_trnovr_rule_lines  irl,
               				je_gr_trnovr_rules ir
				where
					ir.trnovr_rule_id = p_rule_id
 					and    irl.trnovr_rule_id = ir.trnovr_rule_id
 					and    irl.lookup_type = 'STD_LINE_TYPE'
 					and    irl.exclude_flag = 'Y'))

  GROUP BY
        PARTY.PARTY_NAME,
        CUST_ACCT.ACCOUNT_NUMBER,
        CUST_ACCT.CUSTOMER_CLASS_CODE ,
        PARTY.TAX_REFERENCE,
        PARTY.SIC_CODE,
	CUST_ACCT.GLOBAL_ATTRIBUTE1,
        loc.city,
        loc.state,
	loc.province,
        loc.country,
        loc.address1,
        loc.address2,
	loc.address3,
        loc.postal_code,
        ctt.type,
        ctx.trx_number,
	ctx.customer_trx_id,
        cgld.gl_date,
        ctx.customer_trx_id,
        ctx.trx_date,
        ctx.invoice_currency_code
   HAVING
    (decode(sign(sum(nvl(cgld.acctd_amount,nvl(cgld.amount,0)))),to_number(p_balance_type),
     abs(sum(nvl(cgld.acctd_amount,nvl(cgld.amount,0)))),p_inv_amount_limit)) > p_inv_amount_limit;

        ctr NUMBER := 0;

  BEGIN

  /* The following loop navigates through each and every record of the cursor and calls the generic
       procedure to insert the data in the interface table. */


    FOR rec in c_customer_turnover

    LOOP

        GENERIC_INSERT_TO_ITF(	errbuf,retcode,rec.ar_request_id,
        			rec.customer_name,
        			rec.customer_number,
        			rec.tax_reference,
        			rec.vat_number,
        			NULL,
        			rec.standard_industry_class,
        			rec.address_line1,
        			rec.address_line2,
				rec.address_line3,
        			rec.city,
        			rec.state,
        			rec.zip,
        			rec.province,
        			rec.country,
				rec.invoice_num,
				rec.invoice_id,
				rec.invoice_date,
                                rec.invoice_currency_code,
				rec.distribution_total,
        			rec.invoice_type_lookup_code,
        			rec.distribution_base_total,
        			rec.customer_type_lookup_code,
        			rec.created_by,
                                rec.creation_date,
        			rec.last_update_date,
        			rec.last_updated_by,
        			rec.last_update_login);

	ctr := ctr + 1;

    END LOOP;

    IF ctr = 0 THEN
        fnd_file.put_line(FND_FILE.OUTPUT,'******* NO DATA FOUND ******');
        retcode := 2;
    ELSE
        COMMIT;
    END IF;

    fnd_file.put_line(FND_FILE.OUTPUT,'Concurrent Request Processed Successfully...');
    retcode := 0;

    EXCEPTION

		WHEN OTHERS THEN
			retcode := 2;
    			fnd_file.put_line(FND_FILE.LOG,'Error occurred during extract process...');
			ROLLBACK;

  END JE_AR_TURNOVER_EXTRACT;


  PROCEDURE GENERIC_INSERT_TO_ITF(  errbuf             OUT NOCOPY  VARCHAR2,
  	retcode            OUT NOCOPY  NUMBER,
	p_request_id            in number,
        p_cust_sup_name         in varchar2,
        p_cust_sup_number       in varchar2,
        p_tax_payer_id          in varchar2,
        p_vat_registration_number in varchar2,
        p_supplier_site_code    in varchar2,
        p_profession            in varchar2,
        p_address_line1         in varchar2,
        p_address_line2         in varchar2,
	p_address_line3		in varchar2,
        p_city                  in varchar2,
        p_state                 in varchar2,
        p_zip                   in varchar2,
        p_province              in varchar2,
        p_country               in varchar2,
        p_inv_trx_number        in varchar2,
	p_inv_trx_id		in number,
        p_inv_trx_date          in date,
        p_inv_trx_currency_code in varchar2,
        p_inv_trx_amount        in number,
        p_inv_trx_type          in varchar2,
        p_acctd_inv_trx_amount  in number,
        p_cust_sup_type_code    in varchar2,
        p_created_by            in number,
	p_creation_date		in date,
        p_last_update_date      in date,
        p_last_updated_by       in number,
        p_last_update_login     in number)
  IS

  BEGIN


        INSERT INTO JE_GR_AR_AP_TRNOVR_ITF (
		REQUEST_ID
	 	,CUST_SUP_TYPE_CODE
 		,CUST_SUP_NAME
 		,CUST_SUP_NUMBER
 		,TAX_PAYER_ID
 		,VAT_REGISTRATION_NUMBER
 		,SUPPLIER_SITE_CODE
 		,PROFESSION
 		,ADDRESS_LINE1
 		,ADDRESS_LINE2
 		,ADDRESS_LINE3
 		,CITY
 		,STATE
 		,ZIP
 		,PROVINCE
 		,COUNTRY
 		,INV_TRX_TYPE
 		,INV_TRX_NUMBER
 		,INV_TRX_ID
		,INV_TRX_DATE
 		,INV_TRX_CURRENCY_CODE
 		,INV_TRX_AMOUNT
 		,ACCTD_INV_TRX_AMOUNT
 		,CREATED_BY
 		,CREATION_DATE
 		,LAST_UPDATE_DATE
 		,LAST_UPDATED_BY
 		,LAST_UPDATE_LOGIN
   		)
                values(
		p_request_id,
        	p_cust_sup_type_code,
        	p_cust_sup_name,
        	p_cust_sup_number,
        	p_tax_payer_id,
        	p_vat_registration_number,
        	p_supplier_site_code,
        	p_profession,
        	p_address_line1,
        	p_address_line2,
		p_address_line3,
        	p_city,
        	p_state,
        	p_zip,
        	p_province,
        	p_country,
        	p_inv_trx_type,
        	p_inv_trx_number,
		p_inv_trx_id,
        	p_inv_trx_date,
        	p_inv_trx_currency_code,
        	p_inv_trx_amount,
        	p_acctd_inv_trx_amount,
        	p_created_by,
		p_creation_date,
        	p_last_update_date,
        	p_last_updated_by,
        	p_last_update_login);
  EXCEPTION

	WHEN OTHERS THEN
		fnd_file.put_line(FND_FILE.log,'While Inserting the Record into Interface Table');
		retcode := 2;

  END GENERIC_INSERT_TO_ITF;


  END JERX_TO;

/
