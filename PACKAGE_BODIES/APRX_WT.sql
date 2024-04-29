--------------------------------------------------------
--  DDL for Package Body APRX_WT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."APRX_WT" AS
/* $Header: aprxwtb.pls 120.2.12010000.5 2009/08/27 14:24:59 sjetti ship $ */

  -- Structure to hold values of parameters
  -- These include parameters which are passed in the core and all the plug-ins
  type param_t is record (
        p_date_from	          varchar2(20),
        p_date_to                 varchar2(20),
        p_supplier_from           varchar2(80),
        p_supplier_to             varchar2(80),
        p_supplier_type           varchar2(25),
        p_system_acct_method      varchar2(240)
                        );
  parm param_t;

  -- Core Report function

  PROCEDURE GET_WITHOLDING_TAX (
        request_id      	  in  number,
        section_name              in varchar2,
        retcode                   out NOCOPY number,
        errbuf                    out NOCOPY varchar2
                      )
  IS
  BEGIN

    fa_rx_util_pkg.debug('aprx_wt.get_witholding_tax()+');

     -- Initialize request

     fa_rx_util_pkg.init_request('aprx_wt.get_witholding_tax', request_id);

     fa_rx_util_pkg.assign_report(section_name,
                true,
                'aprx_wt.before_report;',
                NULL,
                NULL,
                NULL);

     fa_rx_util_pkg.run_report('aprx_wt.get_witholding_tax', retcode, errbuf);

     fa_rx_util_pkg.debug('aprx_wt.get_witholding_tax()-');

  END GET_WITHOLDING_TAX;

  -- This  procedure is a plug-in for the (Tax Letter) Report

  PROCEDURE ap_wht_tax_report  (
        p_date_from               in varchar2,
        p_date_to                 in varchar2,
        p_supplier_from           in varchar2,
        p_supplier_to             in varchar2,
        p_supplier_type           in varchar2,
        request_id                in  number,
        retcode                   out NOCOPY number,
        errbuf                    out NOCOPY varchar2
       )
  IS
    BEGIN
     fa_rx_util_pkg.debug('aprx_wt.ap_wht_tax_report()+');
     fa_rx_util_pkg.debug('p_date_from  '||p_date_from);
     fa_rx_util_pkg.debug('canonical date from   '||to_char(fnd_date.canonical_to_date(p_date_from)));
     fa_rx_util_pkg.init_request('aprx_wt.ap_wht_tax_report', request_id);

      -- Store the paremters in a variable which can be accesed globally accross all procedures
      parm.p_date_from               := p_date_from;
      parm.p_date_to                 := p_date_to;
      parm.p_supplier_from           := p_supplier_from;
      parm.p_supplier_to             := p_supplier_to;
      parm.p_supplier_type           := p_supplier_type;

      -- Call the core report.This executes the core report and the SELECT statement of the core
      -- is built.Now the plug-in has to add only what is specific to it.
      -- No data is inserted into the interface table.

      aprx_wt.get_witholding_tax (
        request_id,
        'get_witholding_tax',
        retcode,
        errbuf);

      -- Continue with the execution of the plug-in
      fa_rx_util_pkg.assign_report('get_witholding_tax',
                 true,
                'aprx_wt.awt_before_report;',
                'aprx_wt.awt_bind(:CURSOR_SELECT);',
                NULL, null);

      fa_rx_util_pkg.run_report('aprx_wt.ap_wht_tax_report', retcode, errbuf);

      fa_rx_util_pkg.debug('aprx_wt.ap_wht_tax_report()-');

    END ap_wht_tax_report;

/*=======================================================================================================

                                                    CORE REPORT

========================================================================================================*/


  -- This is the before report trigger for the main Report. The code which is written in the " BEFORE
  -- REPORT " triggers has been incorporated over here. The code is the common code accross all the
  -- reports.

  PROCEDURE before_report
  IS
   BEGIN
     fa_rx_util_pkg.debug('aprx_wt.before_report()+');


	fa_rx_util_pkg.debug('GL_SET_OF_BKS_ID');

	--
  	-- Get Profile GL_SET_OF_BKS_ID
  	--
   	fa_rx_util_pkg.debug('GL_GET_PROFILE_BKS_ID');
   	fnd_profile.get(
          		name => 'GL_SET_OF_BKS_ID',
          		val => var.books_id);

	--
  	-- Get CHART_OF_ACCOUNTS_ID
  	--
   	fa_rx_util_pkg.debug('GL_GET_CHART_OF_ACCOUNTS_ID');

	select	CURRENCY_CODE,NAME
   	into 	var.functional_currency_code
	,	var.organization_name
   	from 	GL_SETS_OF_BOOKS
   	where 	SET_OF_BOOKS_ID = var.books_id;




--  Bug 1759331


/*    		SELECT name
    		INTO var.organization_name
    		FROM hr_organization_units
    		WHERE organization_id = FND_PROFILE.GET('ORG_ID');

    		SELECT currency_code
    		INTO var.functional_currency_code
    		FROM gl_sets_of_books
    		WHERE set_of_books_id = FND_PROFILE.GET('GL_SET_OF_BKS_ID');
*/



     -- Get Company Information and store in placeholder variables
     BEGIN
       SELECT hrl.address_line_1,
              hrl.address_line_2,
	      hrl.address_line_3,
              hrl.town_or_city,
	      hrl.country,
              hrl.postal_code,
              hrl.region_1,
              hrl.region_2
        INTO var.Address_line1,
	     var.address_line2,
	     var.address_line3,
             var.city,
             var.country,
             var.zip,
             var.province,
             var.state
        FROM hr_locations hrl
        WHERE hrl.location_id = JG_ZZ_COMPANY_INFO.get_location_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE_APPLICATION_ERROR(-20010,sqlerrm);
      END;

       --Assign SELECT list
       -- the Select statement is build over here

       -- fa_rx_util_pkg.assign_column(#, select, insert, place, type, len);

       -->>SELECT_START<<--

       fa_rx_util_pkg.assign_column('1', 'pv1.vendor_name', 'tax_authority','aprx_wt.var.tax_authority','VARCHAR2', 240);

       fa_rx_util_pkg.assign_column('2', 'pv2.vendor_type_lookup_code', 'supplier_type','aprx_wt.var.supplier_type','VARCHAR2',25);

       fa_rx_util_pkg.assign_column('3',  'pv2.vendor_name',  'supplier_name', 'aprx_wt.var.supplier_name','VARCHAR2',240);

       fa_rx_util_pkg.assign_column('4', 'pv2.num_1099', 'taxpayer_id','aprx_wt.var.taxpayer_id','VARCHAR2',30);

       fa_rx_util_pkg.assign_column('5',  'pv2.segment1',  'supplier_number', 'aprx_wt.var.supplier_number','VARCHAR2',30);

       fa_rx_util_pkg.assign_column('6',  'pvs.vendor_site_code',  'supplier_site_code', 'aprx_wt.var.supplier_site_code','VARCHAR2',15);

       fa_rx_util_pkg.assign_column('7',  'pvs.vat_registration_num',  'vat_registration_number', 'aprx_wt.var.vat_registration_number','VARCHAR2',20);


       fa_rx_util_pkg.assign_column('8',  'pvs.address_line1',  'supplier_address_line1', 'aprx_wt.var.supplier_address_line1','VARCHAR2',240);

       fa_rx_util_pkg.assign_column('9',  'pvs.address_line2',  'supplier_address_line2', 'aprx_wt.var.supplier_address_line2','VARCHAR2',240);

       fa_rx_util_pkg.assign_column('10',  'pvs.address_line3',  'supplier_address_line3', 'aprx_wt.var.supplier_address_line3','VARCHAR2',240);

       fa_rx_util_pkg.assign_column('11',  'pvs.city',  'supplier_city', 'aprx_wt.var.supplier_city','VARCHAR2',25);

       fa_rx_util_pkg.assign_column('12',  'pvs.state',  'supplier_state', 'aprx_wt.var.supplier_state','VARCHAR2',150);

       fa_rx_util_pkg.assign_column('13',  'pvs.zip',  'supplier_zip', 'aprx_wt.var.supplier_zip','VARCHAR2',20);

       fa_rx_util_pkg.assign_column('14',  'pvs.province',  'supplier_province', 'aprx_wt.var.supplier_province','VARCHAR2',150);

       fa_rx_util_pkg.assign_column('15',  'pvs.country',  'supplier_country', 'aprx_wt.var.supplier_country','VARCHAR2',25);

       fa_rx_util_pkg.assign_column('16',  'ai.invoice_num',  'invoice_num', 'aprx_wt.var.invoice_num','VARCHAR2',50);

       fa_rx_util_pkg.assign_column('17',  'ai.invoice_amount',  'invoice_amount', 'aprx_wt.var.invoice_amount','NUMBER');

       fa_rx_util_pkg.assign_column('18',  'ai.invoice_currency_code',  'invoice_currency_code', 'aprx_wt.var.invoice_currency_code','VARCHAR2',15);

       fa_rx_util_pkg.assign_column('19',  'ai.invoice_date',  'invoice_date', 'aprx_wt.var.invoice_date','DATE');

       fa_rx_util_pkg.assign_column('20',  'atr.tax_name',  'awt_code', 'aprx_wt.var.awt_code','VARCHAR2',15);

       fa_rx_util_pkg.assign_column('21',  'atr.tax_rate',  'awt_rate', 'aprx_wt.var.awt_rate','NUMBER');

       fa_rx_util_pkg.assign_column('22',  'nvl(aid.amount*(-1),0)',  'awt_amount', 'aprx_wt.var.awt_amount','NUMBER');

       fa_rx_util_pkg.assign_column('23',  'nvl(aid.base_amount*(-1),aid.amount*(-1))',  'awt_base_amount', 'aprx_wt.var.awt_base_amount','NUMBER');

       fa_rx_util_pkg.assign_column('24',  'atg.name',  'awt_group_name', 'aprx_wt.var.awt_group_name','VARCHAR2',25);

       fa_rx_util_pkg.assign_column('25',  'aid.accounting_date',  'awt_gl_date', 'aprx_wt.var.awt_gl_date','DATE');

-- bug 8258934
--       fa_rx_util_pkg.assign_column('26',  'aid.awt_gross_amount',  'awt_gross_amount',  'aprx_wt.var.awt_gross_amount','NUMBER');
       fa_rx_util_pkg.assign_column('26',  'DECODE((ROW_NUMBER() OVER (PARTITION BY  aid.invoice_id, aid.awt_origin_group_id, aid.invoice_line_number ORDER BY aid.awt_group_id, aid.invoice_line_number, aid.distribution_line_number))'||
       ', 1, aid.awt_gross_amount , 0)',  'awt_gross_amount', 'aprx_wt.var.awt_gross_amount','NUMBER');

       fa_rx_util_pkg.assign_column('27', NULL, 'address_line1','aprx_wt.var.address_line1', 'VARCHAR2',240);

       fa_rx_util_pkg.assign_column('28', NULL, 'address_line2','aprx_wt.var.address_line2', 'VARCHAR2',240);

       fa_rx_util_pkg.assign_column('29', NULL, 'address_line3','aprx_wt.var.address_line3', 'VARCHAR2',240);

       fa_rx_util_pkg.assign_column('30', NULL, 'city','aprx_wt.var.city', 'VARCHAR2',30);

       fa_rx_util_pkg.assign_column('31', NULL, 'zip','aprx_wt.var.zip', 'VARCHAR2',30);

       fa_rx_util_pkg.assign_column('32', NULL, 'country','aprx_wt.var.country', 'VARCHAR2',60);

       fa_rx_util_pkg.assign_column('33', 'hou.name', 'organization_name','aprx_wt.var.organization_name', 'VARCHAR2',240);    --bug7621919

       fa_rx_util_pkg.assign_column('34', NULL, 'functional_currency_code','aprx_wt.var.functional_currency_code', 'VARCHAR2',15);

       fa_rx_util_pkg.assign_column('35', NULL, 'province','aprx_wt.var.province', 'VARCHAR2',150);

       fa_rx_util_pkg.assign_column('36', NULL, 'state','aprx_wt.var.state', 'VARCHAR2',150);

       -->>SELECT_END<<--


       --
       -- Assign From Clause
       --
       fa_rx_util_pkg.From_Clause :=
       	'po_vendors pv2,
         po_vendors pv1,
         po_vendor_sites pvs ,
         ap_invoices ai,
         ap_invoice_distributions aid,
         ap_tax_codes atc,
         ap_awt_groups atg,
         ap_awt_tax_rates atr,
	 hr_organization_units hou';   --bug7621919


       -- Assign Where Clause

       -- Bug 2825570. Add filter on invoice_date between start and end dates.

       fa_rx_util_pkg.Where_Clause :=   'pv2.vendor_id = ai.vendor_id and
		  			 pvs.vendor_site_id = ai.vendor_site_id and
      					 atg.group_id(+)  = aid.awt_origin_group_id and
      					 ai.invoice_id = aid.invoice_id and
      					 aid.withholding_tax_code_id  = atc.tax_id and
					 atc.name = atr.tax_name and
                                         aid.line_type_lookup_code=''AWT'' and
                                         ai.invoice_date between NVL(atr.start_date , ai.invoice_date) and NVL(atr.end_date , ai.invoice_date) and
					 atc.awt_vendor_id = pv1.vendor_id and
					 hou.organization_id = aid.org_id';    --bug7621919

        fa_rx_util_pkg.debug('aprx_wt.before_report()-');

      END BEFORE_REPORT;

/*   Bug7376771 -- Modified the tax_code_id to withholding_tax_code_id as in R12
     withholding functionality is seperated */
      -- The after fetch trigger fires after the Select statement has executed
/*
      PROCEDURE after_fetch IS
      BEGIN

      END;
*/

/*=============================================================================================

                                                    END OF CORE REPORT

===============================================================================================*/


/*===============================================================================================

                                            AP Witholding Tax Letter Report(Plug-In)

================================================================================================*/


      -- This is the before report trigger for the Plug-In. The code which is specific to the AP Witholding Tax report and Letter is written here.

      PROCEDURE awt_before_report IS
        CURSOR c_methods IS
          SELECT UPPER(accounting_method_option),
                 UPPER(secondary_accounting_method)
          FROM   ap_system_parameters;
        first_acct_method  ap_system_parameters.accounting_method_option%TYPE;
        second_acct_method ap_system_parameters.secondary_accounting_method%TYPE;

      BEGIN
        OPEN  c_methods;
        FETCH c_methods INTO first_acct_method, second_acct_method;
        CLOSE c_methods;
        IF (
          (first_acct_method = 'ACCRUAL')
          and
          (
            (second_acct_method = 'ACCRUAL')
            or
            (second_acct_method = 'NONE')
          or
          (second_acct_method is null)
          )
         ) THEN
        parm.P_System_Acct_Method := 'ACCRUAL';
        ELSIF (
          (first_acct_method = 'CASH')
          and
          (
            (second_acct_method = 'CASH')
          or
            (second_acct_method = 'NONE')
          or
            (second_acct_method is null)
            )
           ) THEN
        parm.P_System_Acct_Method := 'CASH';
      ELSE
        parm.P_System_Acct_Method := 'BOTH';
      END IF;

	fa_rx_util_pkg.debug('system_acct_method'||parm.P_System_Acct_Method);

          -- Add the WHERE clause which is specific to the AP Witholding Report

       IF parm.p_date_from IS NOT NULL THEN
         fa_rx_util_pkg.Where_clause := fa_rx_util_pkg.Where_clause || ' and aid.accounting_date >=  fnd_date.canonical_to_date(:b_date_from)' ;
        END IF;

       IF parm.p_date_to IS NOT NULL THEN
         fa_rx_util_pkg.Where_clause := fa_rx_util_pkg.Where_clause || ' and aid.accounting_date <= fnd_date.canonical_to_date(:b_date_to) ';

       END IF;

       IF parm.p_supplier_from IS NOT NULL THEN
         fa_rx_util_pkg.Where_clause := fa_rx_util_pkg.Where_clause || ' and UPPER(pv2.vendor_name) >= UPPER(:b_supplier_from)';
       END IF;

       IF parm.p_supplier_to IS NOT NULL THEN
         fa_rx_util_pkg.Where_clause := fa_rx_util_pkg.Where_clause || ' and UPPER(pv2.vendor_name) <= UPPER(:b_supplier_to)' ;
       END IF;

       IF parm.p_supplier_type IS NOT NULL THEN
         fa_rx_util_pkg.Where_clause := fa_rx_util_pkg.Where_clause || ' and pv2.vendor_type_lookup_code  = :b_supplier_type';
       END IF;

      IF parm.p_system_acct_method IS NOT NULL THEN
        fa_rx_util_pkg.Where_clause := fa_rx_util_pkg.Where_clause ||' and aid.accrual_posted_flag = decode(:b_system_acct_method,''ACCRUAL'',''Y'',''BOTH'',''Y'',aid.accrual_posted_flag)';
        fa_rx_util_pkg.Where_clause := fa_rx_util_pkg.Where_clause ||' and aid.cash_posted_flag = decode(:b_system_acct_method,''CASH'',''Y'',''BOTH'',''Y'',aid.cash_posted_flag)';
      END IF;

        fa_rx_util_pkg.debug('aprx_wt.awt_before_report()-');

      END awt_before_report;

      -- This is the bind trigger for the
      PROCEDURE awt_bind(c in integer)
      IS
        b_date_from  varchar2(20);
        b_date_to    varchar2(20);
        b_supplier_from varchar2(80);
        b_supplier_to varchar2(80);
        b_supplier_type varchar2(25);
        b_system_acct_method varchar2(240);
      BEGIN
        fa_rx_util_pkg.debug('aprx_wt.awt_bind()+');

        IF parm.p_date_from is not null then
          fa_rx_util_pkg.debug('Binding b_date_from');
          dbms_sql.bind_variable(c, 'b_date_from', parm.p_date_from);
        END IF;

        IF parm.p_date_to is not null then
          fa_rx_util_pkg.debug('Binding b_date_to');
          dbms_sql.bind_variable(c, 'b_date_to', parm.p_date_to);
        END IF;

        IF parm.p_supplier_from is not null then
          fa_rx_util_pkg.debug('Binding b_supplier_from');
          dbms_sql.bind_variable(c, 'b_supplier_from', parm.p_supplier_from);
        END IF;

        IF parm.p_supplier_to is not null then
          fa_rx_util_pkg.debug('Binding b_supplier_to');
          dbms_sql.bind_variable(c, 'b_supplier_to', parm.p_supplier_to);
        END IF;

        IF parm.p_supplier_type is not null then
          fa_rx_util_pkg.debug('Binding b_supplier_type_from');
          dbms_sql.bind_variable(c, 'b_supplier_type', parm.p_supplier_type);
        END IF;

        IF parm.p_system_acct_method is not null then
          fa_rx_util_pkg.debug('Binding b_system_acct_method');
          dbms_sql.bind_variable(c, 'b_system_acct_method', parm.p_system_acct_method);
        END IF;

        fa_rx_util_pkg.debug('aprx_wt.awt_bind()-');

     END awt_bind;


/*=============================================================================================

                                                    END OF AP WITHHOLDING TAX REPORT

===============================================================================================*/

  END APRX_WT;

/
