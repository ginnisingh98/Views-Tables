--------------------------------------------------------
--  DDL for Package Body JE_BE_CSSR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_BE_CSSR_PKG" AS
/* $Header: jebecsrb.pls 120.1.12010000.3 2008/09/02 07:16:30 vgadde ship $ */

procedure main(
 p_errbuf     OUT NOCOPY VARCHAR2,
 p_retcode    OUT NOCOPY VARCHAR2,
 p_vat_reporting_entity_id  jg_zz_vat_rep_entities.vat_reporting_entity_id%TYPE,
 p_rep_period        gl_periods.period_name%TYPE,
 p_fax_number        varchar2,
 p_email             varchar2,
 p_resp_email        varchar2,
 p_trans_resp        varchar2,
 p_trans_ackn        varchar2,
 p_sec_resp          varchar2,
 p_sec_ackn          varchar2)is

 cursor c_get_reg_det(p_vat_reporting_entity_id  jg_zz_vat_rep_entities.vat_reporting_entity_id%TYPE) is
 SELECT substr(legal.tax_registration_number,3),
        legal.legal_entity_id
 FROM jg_zz_vat_rep_entities legal,
      jg_zz_vat_rep_entities acc
  WHERE acc.vat_reporting_entity_id = p_vat_reporting_entity_id
  AND  ((acc.entity_type_code = 'ACCOUNTING'
         AND acc.mapping_vat_rep_entity_id = legal.vat_reporting_entity_id)
        OR
         (acc.entity_type_code = 'LEGAL'
          and acc.vat_reporting_entity_id = legal.vat_reporting_entity_id)
         );


 cursor c_get_iso_lang is
  select lower(ISO_LANGUAGE) from fnd_languages
  where language_code = userenv('LANG');

 l_iso_lang varchar2(4);
 l_be_reg_number jg_zz_vat_rep_entities.tax_registration_number%type;

 l_survey_code varchar2(50);
 l_proc_status varchar2(200);
 l_legal_entity_name        xle_registrations.registered_name%TYPE;
 l_tel_num     hz_parties.primary_phone_number%TYPE;
 l_legal_entity_id jg_zz_vat_rep_entities.legal_entity_id%TYPE;
 l_dummy varchar2(100);
 l_exc_survey_code_null exception;
 l_exc_lang_limit exception;

begin

 fnd_file.put_line(fnd_file.log,'Parameters..');
 fnd_file.put_line(fnd_file.log,'p_vat_reporting_entity_id  :'||p_vat_reporting_entity_id);
 fnd_file.put_line(fnd_file.log,'p_rep_period  :'||p_rep_period);
 fnd_file.put_line(fnd_file.log,'p_fax_number  :'||p_fax_number);
 fnd_file.put_line(fnd_file.log,'p_email       :'||p_email);
 fnd_file.put_line(fnd_file.log,'p_resp_email  :'||p_resp_email);
 fnd_file.put_line(fnd_file.log,'p_trans_resp  :'||p_trans_resp);
 fnd_file.put_line(fnd_file.log,'p_trans_ackn  :'||p_trans_ackn);
 fnd_file.put_line(fnd_file.log,'p_sec_resp  :'||p_sec_resp);
 fnd_file.put_line(fnd_file.log,'p_sec_ackn  :'||p_sec_ackn);

 open c_get_reg_det(p_vat_reporting_entity_id);
 fetch c_get_reg_det into l_be_reg_number,l_legal_entity_id;
 close c_get_reg_det;

JG_ZZ_COMMON_PKG.company_detail(x_company_name =>l_legal_entity_name
                               ,x_registration_number=>l_dummy
                               ,x_country=>l_dummy
                               ,x_address1=>l_dummy
                               ,x_address2=>l_dummy
                               ,x_address3=>l_dummy
                               ,x_address4=>l_dummy
                               ,x_city=>l_dummy
                               ,x_postal_code=>l_dummy
                               ,x_contact=>l_dummy
                               ,x_phone_number =>l_tel_num
                               ,x_province=>l_dummy
                               ,x_comm_number=>l_dummy
                               ,x_vat_reg_num =>l_dummy
			                   ,pn_legal_entity_id => l_legal_entity_id
			                   ,p_vat_reporting_entity_id=>p_vat_reporting_entity_id
                               );


 --get the value of form/survey code

 fnd_profile.get('JEBE_CSSR_SURVEY_CODE',l_survey_code);

 fnd_file.put_line(fnd_file.log,'Survey Code :'||l_survey_code);

 if (l_survey_code  is null ) then
  raise l_exc_survey_code_null;
 end if;

 open c_get_iso_lang;
 fetch c_get_iso_lang into l_iso_lang;
 close c_get_iso_lang;

 if( l_iso_lang not in ('en','nl','fr','de' )) then
    raise l_exc_lang_limit;
 end if;

 l_proc_status := 'Initilising the xml';

 g_vc_spacing  := 1;

 fnd_file.put_line(fnd_file.log,'Generating admin data....');

 get_admin_data(
  p_vat_reg_num       =>l_be_reg_number,
  p_email_address     =>p_email,
  p_tel_num           =>l_tel_num,
  p_fax_num           =>p_fax_number,
  p_name              =>l_legal_entity_name,
  p_email_resp        =>p_resp_email,
  p_trans_resp        =>p_trans_resp,
  p_trans_ackn        =>p_trans_ackn,
  p_sec_resp          =>p_sec_resp,
  p_sec_ackn          =>p_sec_ackn,
  p_survey_code       =>l_survey_code,
  p_period            =>p_rep_period
 );

 fnd_file.put_line(fnd_file.log,'Completed admin data');

 fnd_file.put_line(fnd_file.log,'Generating content data...');
 get_content_data (l_survey_code,p_rep_period,p_vat_reporting_entity_id);
 fnd_file.put_line(fnd_file.log,'Completed content data');

exception
 when l_exc_survey_code_null then
  fnd_file.put_line(fnd_file.log,'-------------');
  fnd_file.put_line(fnd_file.log,'  ERROR LOG  ');
  fnd_file.put_line(fnd_file.log,'-------------');
  fnd_file.put_line(fnd_file.log,' JE_BE_CSSR_PKG: JEBE: Survey code Profile Option not set ');
  fnd_file.put_line(fnd_file.log,'-------------');
  P_RETCODE := 2;
  RETURN;

 when l_exc_lang_limit then
  fnd_file.put_line(fnd_file.log,'-------------');
  fnd_file.put_line(fnd_file.log,'  ERROR LOG  ');
  fnd_file.put_line(fnd_file.log,'-------------');
  fnd_file.put_line(fnd_file.log,' JE_BE_CSSR_PKG: The Report can be run for only the following languages');
  fnd_file.put_line(fnd_file.log,' EN DE NL FR ');
  fnd_file.put_line(fnd_file.log,'-------------');
  P_RETCODE := 2;
  RETURN;

 when others then
  fnd_file.put_line(fnd_file.log,'-------------');
  fnd_file.put_line(fnd_file.log,'  ERROR LOG  ');
  fnd_file.put_line(fnd_file.log,'-------------');
  fnd_file.put_line(fnd_file.log,' Unexpected error occured in the JE_BE_CSSR_PKG package');
  fnd_file.put_line(fnd_file.log,' Please check if all the setup is done properly');
  fnd_file.put_line(fnd_file.log,'-------------');
  raise;
end main;

procedure get_admin_data
(
 p_vat_reg_num varchar2,
 p_email_address     varchar2,
 p_tel_num           varchar2,
 p_fax_num           varchar2,
 p_name              varchar2,
 p_email_resp        varchar2,
 p_trans_resp        varchar2,
 p_trans_ackn        varchar2,
 p_sec_resp          varchar2,
 p_sec_ackn          varchar2,
 p_survey_code       varchar2,
 p_period            varchar2
)

is
 l_var varchar2(2000);
 l_proc_status varchar2(200);
 l_level number(15);

 l_sysdate varchar2(200);
 l_string            varchar2(200);
 l_iso_lang varchar2(4);
 cursor c_get_iso_lang is
  select lower(ISO_LANGUAGE) from fnd_languages
  where language_code = userenv('LANG');

begin
 -- getting the date in the required xml standard
 select to_char(sysdate,'yyyy-mm-dd') ||'T'
        || to_char(sysdate,'hh:mi:ss')
 into l_sysdate
 from dual;
 --main open
-- g_xml := '<cssr_document xmlns="http://www.nbb.be/cssr">';
 l_var := JE_BE_CSSR_PKG.level_up;
 fnd_file.put_line(fnd_file.output,l_var);

 fnd_file.put_line(fnd_file.output,'<cssr_document xmlns="http://www.nbb.be/cssr">');
  --admin open
  l_var := JE_BE_CSSR_PKG.level_up;
  fnd_file.put_line(fnd_file.output,l_var||'<admin creation_time="' ||l_sysdate || '">');

   -- sender info open
  l_var := JE_BE_CSSR_PKG.level_up;
     fnd_file.put_line(fnd_file.output,l_var||'<sender kbo="'||p_vat_reg_num||'">');

     --contact tag open
     l_var := JE_BE_CSSR_PKG.level_up;
     fnd_file.put_line(fnd_file.output,l_var||'<contact>');

      -- name tag open and close
      l_var := JE_BE_CSSR_PKG.level_up;
      if( p_name is not null ) then
        fnd_file.put_line(fnd_file.output,l_var||'<name>'||p_name||'</name>');
      else
        fnd_file.put_line(fnd_file.output,l_var||'</name>');
      end if;
      -- same level ..

      if(p_email_address is not null) then
          l_string := '<communication xmlns:xsi="http://www.w3.org/'||
		      '2001/XMLSchema-instance" xsi:type="Email" address="' ||
		      p_email_address || '"/>';
          fnd_file.put_line(fnd_file.output,l_var||l_string);
      end if;

      if ( p_tel_num is not null ) then
         l_string := '<communication xmlns:xsi="http://www.w3.org/'||
		 '2001/XMLSchema-instance" xsi:type="Telephone" number="' ||
		 p_tel_num || '" />';
         fnd_file.put_line(fnd_file.output,l_var||l_string);
      end if;

      if( p_fax_num is not null  ) then
         l_string := '<communication xmlns:xsi="http://www.w3.org/'||
		 '2001/XMLSchema-instance" xsi:type="Fax" number="' ||
		 p_fax_num || '" />';
         fnd_file.put_line(fnd_file.output,l_var||l_string);
      end if;

     -- contact tag close
     l_var := JE_BE_CSSR_PKG.level_down;
     fnd_file.put_line(fnd_file.output,l_var||'</contact>');
   -- sender info close
   l_var := JE_BE_CSSR_PKG.level_down;
   fnd_file.put_line(fnd_file.output,l_var||'</sender>');

   fnd_file.put_line(fnd_file.output,l_var||'<receiver/>');

   -- receiver info open
   if( p_email_resp is not null  or
       p_trans_resp is not null  or
	   p_trans_ackn is not null  or
	   p_sec_resp is not null  or
	   p_sec_ackn is not null ) then

      -- processsing parameters tag open
       fnd_file.put_line(fnd_file.output,l_var||'<processing_parameters>');

       l_var := JE_BE_CSSR_PKG.level_up;
       -- email response tag
        if ( p_email_resp is not null ) then
         fnd_file.put_line(fnd_file.output,l_var||'<email_response>'
 	                               ||lower(p_email_resp)||'</email_response>');
       end if;

       -- transform response tag
       if ( p_trans_resp is not null ) then
          fnd_file.put_line(fnd_file.output,l_var||'<transform_response>'
 		   ||lower(p_trans_resp)||'</transform_response>');
 	  end if;

       -- transform acknowledgement tag open
       if ( p_trans_ackn is not null ) then
          fnd_file.put_line(fnd_file.output,l_var||'<transform_acknowledgement>'
	 	   ||lower(p_trans_ackn)||'</transform_acknowledgement>');
	   end if;

       -- secure response tag
       if ( p_sec_resp is not null ) then
          fnd_file.put_line(fnd_file.output,l_var||'<secure_response>'
	        ||lower(p_sec_resp)||'</secure_response>');
       end if;

       -- secure acknowledgement tag
       if ( p_sec_ackn is not null ) then
          fnd_file.put_line(fnd_file.output,l_var||'<secure_acknowledgement>'
           ||lower(p_sec_ackn)||'</secure_acknowledgement>');
       end if;

      open c_get_iso_lang;
      fetch c_get_iso_lang into l_iso_lang;
      close c_get_iso_lang;
      l_string := '<lang>'||l_iso_lang||'</lang>';
      fnd_file.put_line(fnd_file.output,l_var||l_string);

      l_var := JE_BE_CSSR_PKG.level_down;

     -- processsing parameters tag close
     fnd_file.put_line(fnd_file.output,l_var||'</processing_parameters>');
    else
     fnd_file.put_line(fnd_file.output,l_var||'<processing_parameters/>');
    end if;
  --admin close
  l_var := JE_BE_CSSR_PKG.level_down;
  fnd_file.put_line(fnd_file.output,l_var||'</admin>');

end get_admin_data;


procedure get_content_data
(p_survey_code varchar2,
 p_period      varchar2,
 p_vat_reporting_entity_id jg_zz_vat_rep_entities.vat_reporting_entity_id%TYPE
)
is
  l_level number(15);
  l_var   varchar2(50);
  l_reporting_level varchar2(30);
  l_legal_entity_id jg_zz_vat_rep_entities.legal_entity_id%TYPE;
  l_ledger_id gl_ledgers.ledger_id%type;
  l_bsv  varchar2(30);

  -- ccid and sob
  cursor get_coa_id (p_sob gl_sets_of_books.set_of_books_id%type)
  is
  select CHART_OF_ACCOUNTS_ID
    from gl_sets_of_books
  where set_of_books_id = p_sob;

  cursor get_disp_period (l_rep_period gl_periods.period_name%type)
  is
  SELECT glp.period_year||'-'||decode(length(glp.period_num),2,to_char(glp.period_num),'0'||to_char(glp.period_num) ) period_num
        ,glp.start_date
        ,glp.end_date
   	    ,acc.ledger_id
	    ,acc.BALANCING_SEGMENT_VALUE
	    ,acc.entity_level_code
	    ,legal.legal_entity_id
  FROM gl_periods glp
      ,jg_zz_vat_rep_entities legal
      ,jg_zz_vat_rep_entities acc
  WHERE glp.period_set_name = legal.tax_calendar_name
  AND acc.vat_reporting_entity_id = p_vat_reporting_entity_id
  AND  ((acc.entity_type_code = 'ACCOUNTING'
       AND acc.mapping_vat_rep_entity_id = legal.vat_reporting_entity_id)
     OR
     (acc.entity_type_code = 'LEGAL'
       AND acc.vat_reporting_entity_id = legal.vat_reporting_entity_id)
      )
  AND period_name = l_rep_period;



  TYPE op_curtype IS REF CURSOR;
  op_curvar op_curtype;
  l_cntry   varchar2(25);
  l_cur     varchar2(4);
  l_rev     number;
  l_chr     number;
  l_disp_rev     varchar2(200);
  l_disp_chr     varchar2(200);
  l_op_string varchar2(500);
  l_rub     varchar2(240);

  l_disp_period  gl_periods.period_name%type;
  l_sob_id       gl_sets_of_books.set_of_books_id%type;
  l_coa_id       gl_code_combinations.CHART_OF_ACCOUNTS_ID%type;
  l_seg_name     fnd_id_flex_segments.application_column_name%type;
  l_cc_id        gl_code_combinations.code_combination_id%type;
  l_start_date   date;
  l_end_date     date;
  l_status_text  varchar2(2000);
  l_data_string  varchar2(200);

  l_sob_var gl_sets_of_books.set_of_books_id%type;
  l_string varchar2(2000);
  l_qry_string varchar2(8000);
  l_cntnt_prsnc_flag   number(1);

begin

 open get_disp_period (p_period );
 fetch get_disp_period
 into l_disp_period
      ,l_start_date
      ,l_end_date
      ,l_ledger_id
      ,l_bsv
      ,l_reporting_level
      ,l_legal_entity_id;
 close get_disp_period;

 fnd_file.put_line(fnd_file.log,'Reporting level :'||l_reporting_level);
 fnd_file.put_line(fnd_file.log,'Legal Entity ID :'||l_legal_entity_id);
 fnd_file.put_line(fnd_file.log,'Ledger ID :'||l_ledger_id);
 fnd_file.put_line(fnd_file.log,'Balancing Segment Value :'||l_bsv);
 fnd_file.put_line(fnd_file.log,'Start Date  :'||l_start_date);
 fnd_file.put_line(fnd_file.log,'End Date :'||l_end_date);

 l_string := '<content xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
 ||'xsi:type="BbpAcquisitionDataset" survey="' || p_survey_code ||'" per="'
 || l_disp_period ||'">';
 l_var := JE_BE_CSSR_PKG.level_down;
 l_var := JE_BE_CSSR_PKG.level_up;
 fnd_file.put_line(fnd_file.output,l_var||l_string);

 IF l_reporting_level <> 'LE' THEN
    l_sob_id := l_ledger_id;

  -- get the chart of accounts id for the sets of books
     l_status_text := ' Deriving Chart of accounts for the SOB '|| l_sob_id;

     open get_coa_id(l_sob_id);
     fetch get_coa_id into l_coa_id;
     close get_coa_id;

    fnd_file.put_line(fnd_file.log,'Char of account id :'||l_coa_id);

   -- Get the accounting/natural segment for the chart of accounts defined.

     l_status_text := ' Get the accounting/natural segment for coa '||l_coa_id;
     l_seg_name := JE_BE_CSSR_PKG.get_accounting_segment(l_coa_id);

     fnd_file.put_line(fnd_file.log,'Accounting Segment :'||l_seg_name);

  END IF;

   l_var := JE_BE_CSSR_PKG.level_up;
   l_string := l_var ||'<form code="'||p_survey_code||'"';
-- dbms_lob.writeappend(g_xml,length(l_var||l_string),l_var||l_string);
-- fnd_file.put_line(fnd_file.output,l_var||l_string);

 --to op tag level
 l_var := JE_BE_CSSR_PKG.level_up;
 l_cntnt_prsnc_flag := 0;
 -- 4. get a list of defined mappings and get the corresponding ccids.
 -- 4a. find the totals for AP and AR and produce the codes.

 IF l_reporting_level = 'LEDGER' THEN

	l_qry_string :=
	 'SELECT  sum(charges),
	        sum(revenue),
	        country,
	        currency,
	        rubic_code
	    FROM
	        (SELECT sum(nvl(ap_dist.amount,0)) charges,
                0 revenue,
                ven.country country,
                ap_inv.INVOICE_CURRENCY_CODE currency,
                ap_inv.invoice_id invoice_id,
                decode (instr(lv.description,'':''), 0,lv.description, substr(lv.description,0,instr(lv.description,'':'')-1)) rubic_code
   	    FROM
	        ap_invoices_all ap_inv,
                ap_supplier_sites_all ven ,
                ap_invoice_distributions_all ap_dist ,
                gl_code_combinations glcc,
                fnd_lookup_values lv
	    WHERE   ap_inv.vendor_site_id            = ven.vendor_site_id
            AND ap_dist.invoice_id               = ap_inv.invoice_id
            AND ap_dist.dist_code_combination_id = glcc.code_combination_id
            AND glcc.chart_of_accounts_id        = :v_coa_id1
            AND glcc.'||l_seg_name||'         = lv.lookup_code
            AND lv.lookup_type                   = ''JEBE_NBBN_CODES''
            AND lv.LANGUAGE                      = USERENV(''LANG'')
            AND ap_inv.set_of_books_id           = :v_sob_id1
            AND ven.country                     <> ''BE''
	    AND AP_INVOICE_DISTRIBUTIONS_PKG.GET_POSTED_STATUS(
	     	                                 ap_dist.ACCRUAL_POSTED_FLAG,
	     	                                 ap_dist.CASH_POSTED_FLAG,
 	                                         ap_dist.POSTED_FLAG, ap_inv.org_id) in (''Y'',''P'')
            AND ap_dist.accounting_date BETWEEN :v_start_date1 AND :v_end_date1
            GROUP BY ap_inv.INVOICE_CURRENCY_CODE,
                ven.country ,
                ap_inv.invoice_id,
                decode (instr(lv.description,'':''), 0,lv.description, substr(lv.description,0,instr(lv.description,'':'')-1)),
                to_number(nvl(lv.tag,-999999999999999999999999999999999999999))
            HAVING sum(nvl(ap_dist.base_amount,ap_dist.amount)) >= to_number(nvl(lv.tag,-999999999999999999999999999999999999999))
            UNION ALL
          SELECT  0 charges,
                sum(nvl(AMOUNT,0)) revenue,
                hzl.country country,
                invoice_currency_code currency,
                trx.customer_trx_id invoice_id,
                decode (instr(lv.description,'':''), 0,lv.description, substr(lv.description,0,instr(lv.description,'':'')-1)) rubic_code
           FROM
	        RA_CUST_TRX_LINE_GL_DIST_ALL gld ,
                ra_customer_trx_all trx ,
                HZ_CUST_ACCOUNTS hz_cust ,
                hz_parties parties ,
                hz_party_sites hz_ps ,
                hz_locations hzl ,
                hz_cust_site_uses_all hz_csu ,
                hz_cust_acct_sites_all hz_cas ,
                gl_code_combinations glcc,
                fnd_lookup_values lv
          WHERE
	    gld.customer_trx_id       = trx.customer_trx_id
            AND trx.BILL_TO_customer_ID   = HZ_CUST.cust_account_id
            AND hz_cust.party_id          = parties.party_id
            AND hz_cas.cust_account_id    = HZ_CUST.cust_account_id
            AND trx.BILL_TO_SITE_USE_ID   = HZ_CSU.SITE_USE_ID
            AND hz_cas.cust_acct_site_id  = hz_csu.cust_acct_site_id
            AND hz_ps.party_site_id       = hz_cas.party_site_id
            AND hz_ps.party_id            = parties.party_id
            AND hz_ps.location_id         = hzl.location_id
            AND gld.code_combination_id   = glcc.code_combination_id
            AND glcc.chart_of_accounts_id = :v_coa_id2
            AND lv.lookup_type            = ''JEBE_NBBN_CODES''
            AND glcc.'||l_seg_name||'     = lv.lookup_code
            AND lv.LANGUAGE               = USERENV(''LANG'')
            AND trx.set_of_books_id       = :v_sob_id2
            AND hzl.country              <> ''BE''
            AND gld.GL_DATE BETWEEN :v_start_date2 AND :v_end_date2
	    AND trx.complete_flag = ''Y''
 	    AND gld.posting_control_id <> -3
          GROUP BY hzl.COUNTRY,
                invoice_currency_code,
                trx.customer_trx_id,
                decode (instr(lv.description,'':''), 0,lv.description, substr(lv.description,0,instr(lv.description,'':'')-1)),
                to_number(nvl(lv.tag,-999999999999999999999999999999999999999))
          HAVING sum(acctd_AMOUNT) >= to_number(nvl(lv.tag,-999999999999999999999999999999999999999))
           )
         GROUP BY country, currency, rubic_code ';

 ELSIF l_reporting_level = 'BSV' THEN

    l_qry_string :=
	 'SELECT  sum(charges),
	        sum(revenue),
	        country,
	        currency,
	        rubic_code
	    FROM
	        (SELECT sum(nvl(ap_dist.amount,0)) charges,
                0 revenue,
                ven.country country,
                ap_inv.INVOICE_CURRENCY_CODE currency,
                ap_inv.invoice_id invoice_id,
                decode (instr(lv.description,'':''), 0,lv.description, substr(lv.description,0,instr(lv.description,'':'')-1)) rubic_code
   	    FROM
	        ap_invoices_all ap_inv,
                ap_supplier_sites_all ven ,
                ap_invoice_distributions_all ap_dist ,
                gl_code_combinations glcc,
                fnd_lookup_values lv
	    WHERE   ap_inv.vendor_site_id        = ven.vendor_site_id
            AND ap_dist.invoice_id               = ap_inv.invoice_id
            AND ap_dist.dist_code_combination_id = glcc.code_combination_id
            AND glcc.chart_of_accounts_id        = :v_coa_id1
            AND glcc.'||l_seg_name||'            = lv.lookup_code
            AND lv.lookup_type                   = ''JEBE_NBBN_CODES''
            AND lv.LANGUAGE                      = USERENV(''LANG'')
            AND ap_inv.set_of_books_id           = :v_sob_id1
    	    AND JE_BE_CSSR_PKG.get_bsv(ap_inv.set_of_books_id,glcc.chart_of_accounts_id,ap_dist.dist_code_combination_id) = :bsv1
            AND ven.country                     <> ''BE''
            AND AP_INVOICE_DISTRIBUTIONS_PKG.GET_POSTED_STATUS(
	                                         ap_dist.ACCRUAL_POSTED_FLAG,
	                                         ap_dist.CASH_POSTED_FLAG,
                                                 ap_dist.POSTED_FLAG, ap_inv.org_id) in (''Y'',''P'')
            AND ap_dist.accounting_date BETWEEN :v_start_date1 AND :v_end_date1
            GROUP BY ap_inv.INVOICE_CURRENCY_CODE,
                ven.country ,
                ap_inv.invoice_id,
                decode (instr(lv.description,'':''), 0,lv.description, substr(lv.description,0,instr(lv.description,'':'')-1)),
                to_number(nvl(lv.tag,-999999999999999999999999999999999999999))
            HAVING sum(nvl(ap_dist.base_amount,ap_dist.amount)) >= to_number(nvl(lv.tag,-999999999999999999999999999999999999999))
            UNION ALL
          SELECT  0 charges,
                sum(nvl(AMOUNT,0)) revenue,
                hzl.country country,
                invoice_currency_code currency,
                trx.customer_trx_id invoice_id,
                decode (instr(lv.description,'':''), 0,lv.description, substr(lv.description,0,instr(lv.description,'':'')-1)) rubic_code
           FROM
	        RA_CUST_TRX_LINE_GL_DIST_ALL gld ,
                ra_customer_trx_all trx ,
                HZ_CUST_ACCOUNTS hz_cust ,
                hz_parties parties ,
                hz_party_sites hz_ps ,
                hz_locations hzl ,
                hz_cust_site_uses_all hz_csu ,
                hz_cust_acct_sites_all hz_cas ,
                gl_code_combinations glcc,
                fnd_lookup_values lv
          WHERE
	    gld.customer_trx_id       = trx.customer_trx_id
            AND trx.BILL_TO_customer_ID   = HZ_CUST.cust_account_id
            AND hz_cust.party_id          = parties.party_id
            AND hz_cas.cust_account_id    = HZ_CUST.cust_account_id
            AND trx.BILL_TO_SITE_USE_ID   = HZ_CSU.SITE_USE_ID
            AND hz_cas.cust_acct_site_id  = hz_csu.cust_acct_site_id
            AND hz_ps.party_site_id       = hz_cas.party_site_id
            AND hz_ps.party_id            = parties.party_id
            AND hz_ps.location_id         = hzl.location_id
            AND gld.code_combination_id   = glcc.code_combination_id
            AND glcc.chart_of_accounts_id = :v_coa_id2
            AND lv.lookup_type            = ''JEBE_NBBN_CODES''
            AND glcc.'||l_seg_name||'     = lv.lookup_code
            AND lv.LANGUAGE               = USERENV(''LANG'')
            AND trx.set_of_books_id       = :v_sob_id2
	    AND JE_BE_CSSR_PKG.get_bsv(trx.set_of_books_id,glcc.chart_of_accounts_id,gld.code_combination_id) = :bsv2
            AND hzl.country              <> ''BE''
            AND gld.GL_DATE BETWEEN :v_start_date2 AND :v_end_date2
            AND trx.complete_flag = ''Y''
	    AND gld.posting_control_id <> -3
          GROUP BY hzl.COUNTRY,
                invoice_currency_code,
                trx.customer_trx_id,
                decode (instr(lv.description,'':''), 0,lv.description, substr(lv.description,0,instr(lv.description,'':'')-1)),
                to_number(nvl(lv.tag,-999999999999999999999999999999999999999))
          HAVING sum(acctd_AMOUNT) >= to_number(nvl(lv.tag,-999999999999999999999999999999999999999))
           )
         GROUP BY country, currency, rubic_code ';

 ELSIF l_reporting_level = 'LE' THEN

     l_qry_string :=

	'SELECT  sum(charges),
        sum(revenue),
        country,
        currency,
        rubic_code
    FROM
        (SELECT sum(nvl(ap_dist.amount,0)) charges,
                0 revenue,
                ven.country country,
                ap_inv.INVOICE_CURRENCY_CODE currency,
                ap_inv.invoice_id invoice_id,
                decode (instr(lv.description,'':''), 0,lv.description, substr(lv.description,0,instr(lv.description,'':'')-1)) rubic_code
        FROM    ap_invoices_all ap_inv,
                ap_supplier_sites_all ven ,
                ap_invoice_distributions_all ap_dist ,
                fnd_lookup_values lv,
                gl_ledgers glr
        WHERE   ap_inv.legal_entity_id           = :p_legal_entity_id1
            AND ap_inv.vendor_site_id            = ven.vendor_site_id
            AND ap_dist.invoice_id               = ap_inv.invoice_id
            AND glr.ledger_id                    = ap_inv.set_of_books_id
            AND JE_BE_CSSR_PKG.get_accounting_segment(glr.chart_of_accounts_id,ap_dist.dist_code_combination_id)   = lv.lookup_code
            AND lv.lookup_type                   = ''JEBE_NBBN_CODES''
            AND lv.LANGUAGE                      = USERENV(''LANG'')
            AND ven.country                     <> ''BE''
            AND AP_INVOICE_DISTRIBUTIONS_PKG.GET_POSTED_STATUS(
	                                         ap_dist.ACCRUAL_POSTED_FLAG,
	                                         ap_dist.CASH_POSTED_FLAG,
                                                 ap_dist.POSTED_FLAG, ap_inv.org_id) in (''Y'',''P'')
            AND ap_dist.accounting_date BETWEEN :v_start_date1 AND :v_end_date1
        GROUP BY ap_inv.INVOICE_CURRENCY_CODE,
                ven.country ,
                ap_inv.invoice_id,
                decode (instr(lv.description,'':''), 0,lv.description, substr(lv.description,0,instr(lv.description,'':'')-1)),
                to_number(nvl(lv.tag,-999999999999999999999999999999999999999))
        HAVING sum(nvl(ap_dist.base_amount,ap_dist.amount)) >= to_number(nvl(lv.tag,-999999999999999999999999999999999999999))
        UNION ALL
        SELECT  0 charges,
                sum(nvl(AMOUNT,0)) revenue,
                hzl.country country,
                invoice_currency_code currency,
                trx.customer_trx_id invoice_id,
                decode (instr(lv.description,'':''), 0,lv.description, substr(lv.description,0,instr(lv.description,'':'')-1)) rubic_code
        FROM    ra_cust_trx_line_gl_dist_all gld ,
                ra_customer_trx_all  trx ,
                hz_cust_accounts     hz_cust,
                hz_cust_site_uses_all   hz_csu,
                hz_cust_acct_sites_all  hz_cas,
                hz_parties           parties,
                hz_party_sites       hz_ps,
                hz_locations         hzl,
                fnd_lookup_values lv,
                gl_ledgers glr
        WHERE   trx.legal_entity_id       = :p_legal_entity_id2
	    AND gld.customer_trx_id       = trx.customer_trx_id
            AND trx.bill_to_customer_id   = hz_cust.cust_account_id
            AND hz_cust.party_id          = parties.party_id
            AND hz_cas.cust_account_id    = hz_cust.cust_account_id
            AND trx.bill_to_site_use_id   = hz_csu.site_use_id
            AND hz_cas.cust_acct_site_id  = hz_csu.cust_acct_site_id
            AND hz_ps.party_site_id       = hz_cas.party_site_id
            AND hz_ps.party_id            = parties.party_id
            AND hz_ps.location_id         = hzl.location_id
            AND trx.set_of_books_id       = glr.ledger_id
            AND lv.lookup_type            = ''JEBE_NBBN_CODES''
            AND lv.LANGUAGE               = USERENV(''LANG'')
            AND hzl.country              <> ''BE''
            AND gld.GL_DATE BETWEEN :v_start_date2 AND :v_end_date2
            AND trx.complete_flag = ''Y''
	    AND gld.posting_control_id <> -3
            AND JE_BE_CSSR_PKG.get_accounting_segment(glr.chart_of_accounts_id, gld.code_combination_id ) = lv.lookup_code
        GROUP BY hzl.COUNTRY,
                invoice_currency_code,
                trx.customer_trx_id,
                decode (instr(lv.description,'':''), 0,lv.description, substr(lv.description,0,instr(lv.description,'':'')-1)),
                to_number(nvl(lv.tag,-999999999999999999999999999999999999999))
        HAVING sum(acctd_AMOUNT) >= to_number(nvl(lv.tag,-999999999999999999999999999999999999999))
        )
    GROUP BY country, currency, rubic_code ';
 END IF;

IF  l_reporting_level = 'LE' THEN

  OPEN op_curvar FOR l_qry_string USING l_legal_entity_id,
                                        l_start_date,
                                        l_end_date,
					l_legal_entity_id,
					l_start_date,
                                        l_end_date;

ELSIF l_reporting_level = 'LEDGER' THEN

  OPEN op_curvar FOR l_qry_string USING l_coa_id,
                                        l_sob_id,
                                        l_start_date,
                                        l_end_date,
                                        l_coa_id,
                                        l_sob_id,
                                        l_start_date,
                                        l_end_date;

ELSIF l_reporting_level = 'BSV' THEN

  OPEN op_curvar FOR l_qry_string USING l_coa_id,
                                        l_sob_id,
					l_bsv,
                                        l_start_date,
                                        l_end_date,
                                        l_coa_id,
                                        l_sob_id,
					l_bsv,
                                        l_start_date,
                                        l_end_date;
END IF;

  loop
   fetch op_curvar into l_chr,l_rev,l_cntry,l_cur,l_rub;
   exit when op_curvar%notfound;
   /* -ve values should not be present in the report */
   /* -ve chr should be + ve rev and -ve rev should be +ve chr */
   /* Amounts should be rounded. No digits after decimal.*/
   IF l_rev >= 0 AND l_chr >= 0 THEN
    l_disp_rev := to_char(round(l_rev));
    l_disp_chr := to_char(round(l_chr));
   ELSIF l_rev >= 0 AND l_chr <= 0 THEN
    l_disp_rev := to_char(round(l_rev + (l_chr * -1)));
    l_disp_chr := '0';
   ELSIF l_rev <= 0 AND l_chr >= 0 THEN
    l_disp_rev := '0';
    l_disp_chr := to_char(round(l_chr + (l_rev * -1)));
   ELSIF l_rev <= 0 and l_chr <= 0 THEN
    l_disp_rev := to_char(round(l_chr));
    l_disp_chr := to_char(round(l_rev));
   END IF;

   l_op_string := '<op rub="'||rtrim(l_rub)||'"'||
                  ' cntry="' || l_cntry ||'"'||
                  ' cur="' || l_cur ||'"'||
                  ' rev="' || l_disp_rev ||'"'||
   	 		      ' chr="' || l_disp_chr ||'"'||
				  ' />' ;

    if ( l_cntnt_prsnc_flag = 0) then
       l_cntnt_prsnc_flag := 1;
       fnd_file.put_line(fnd_file.output,l_string ||' nihil = "false">');
    end if;
    fnd_file.put_line(fnd_file.output,l_var||l_op_string);
  end loop;
  CLOSE op_curvar;
-- end loop;
 --to form tag level
 l_var := JE_BE_CSSR_PKG.level_down;
  if( l_cntnt_prsnc_flag = 1 ) then
   l_string := '</form>';
   fnd_file.put_line(fnd_file.output,l_var||l_string);
  else
   fnd_file.put_line(fnd_file.output,l_string ||' nihil = "true" />');
  end if;

 --content tag close
 l_var := JE_BE_CSSR_PKG.level_down;
 fnd_file.put_line(fnd_file.output,l_var||'</content>');

 --main close
 l_var := JE_BE_CSSR_PKG.level_down;
 fnd_file.put_line(fnd_file.output,'</cssr_document>');

end get_content_data;

function level_up
 return varchar2
is
 l_var varchar2(200);
begin
 g_vc_spacing := g_vc_spacing+1;
 l_var := ' ';--fnd_global.newline();
 for i in 1..g_vc_spacing-1 loop
   l_var :=l_var||'  ';
 end loop;
return l_var;
end level_up;

function level_down return varchar2
is
 l_var varchar2(200);
begin
 g_vc_spacing := g_vc_spacing-1;
 l_var :=' ';-- fnd_global.newline();
 for i in 1..g_vc_spacing-1 loop
   l_var :=l_var||'  ';
 end loop;
return l_var;
end level_down;

/*
REM +======================================================================+
REM Name: get_bsv
REM
REM Description: This function is called in the generic cursor for getting the
REM              BSV for each invoice distribution.
REM
REM
REM Parameters:  ccid  (code combination id)
REM
REM +======================================================================+
*/

FUNCTION get_bsv(p_ledger_id number,p_choac_id number,p_cc_id number) RETURN VARCHAR2 IS

l_segment VARCHAR2(30);
bal_segment_value VARCHAR2(25);

BEGIN

  SELECT application_column_name
  INTO   l_segment
  FROM   fnd_segment_attribute_values
  WHERE    id_flex_code               = 'GL#'
    AND    attribute_value            = 'Y'
    AND    segment_attribute_type     = 'GL_BALANCING'
    AND    application_id             = 101
    AND    id_flex_num = p_choac_id;

  EXECUTE IMMEDIATE 'SELECT '||l_segment ||
                  ' FROM gl_code_combinations '||
                  ' WHERE code_combination_id = '||p_cc_id
  INTO bal_segment_value;

  RETURN (bal_segment_value);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_file.put_line(fnd_file.log,' Exception in get_bsv function : ' || SUBSTR(SQLERRM,1,200));
      RETURN NULL;

END get_bsv;

/*
REM +======================================================================+
REM Name: get_accounting_segment
REM
REM Description: This function is called in the generic cursor for getting the
REM              Accounting Segment for each invoice distribution.
REM
REM
REM Parameters:  p_coa_id  (Chart of account id)
REM
REM +======================================================================+
*/

FUNCTION get_accounting_segment(p_coa_id  number,p_cc_id number default null) RETURN VARCHAR2 IS

l_segment VARCHAR2(30);
l_segment_value VARCHAR(30);


BEGIN

--Get the accounting/natural segment for the chart of accounts defined.

   SELECT application_column_name
    INTO l_segment
   FROM FND_SEGMENT_ATTRIBUTE_VALUES
   WHERE id_flex_num            = p_coa_id --50714
   AND segment_attribute_type = 'GL_ACCOUNT'
   AND id_flex_code           = 'GL#'
   AND attribute_value        = 'Y'
   AND application_id         = 101;

  IF p_cc_id IS NOT NULL THEN

   EXECUTE IMMEDIATE 'SELECT '||l_segment ||
                  ' FROM gl_code_combinations '||
                  ' WHERE code_combination_id = '||p_cc_id||
                  ' AND chart_of_accounts_id = '||p_coa_id
  INTO l_segment_value;

    RETURN (l_segment_value);

  END IF;

  RETURN (l_segment);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_file.put_line(fnd_file.log,' No record was returned for the Accounting segment. Error : ' || SUBSTR(SQLERRM,1,200));
      RETURN NULL;

END get_accounting_segment;


end JE_BE_CSSR_PKG;

/
