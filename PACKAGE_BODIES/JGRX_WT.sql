--------------------------------------------------------
--  DDL for Package Body JGRX_WT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JGRX_WT" AS
/* $Header: jgrxwtb.pls 120.13 2006/09/22 17:43:34 dbetanco ship $ */
/**************************************************************************
 *  Record Structure to hold placeholder values				  *
 **************************************************************************/

  type param_t is record (	p_gldate_from		 DATE,
			  	p_gldate_to		 DATE,
  				p_supplier_from		 VARCHAR2(240),
  				p_supplier_to		 VARCHAR2(240),
				p_supp_tax_reg_num 	 VARCHAR2(20),
  				p_invoice_number	 VARCHAR2(50),
				p_reporting_level	 VARCHAR2(50),
				p_reporting_context 	 VARCHAR2(50),
/* Bug 3017170 - Increased the width to 1000 from 50 */
                        p_legal_entity_id        NUMBER,
				p_acct_flexfield_from 	 VARCHAR2(1000),
				p_acct_flexfield_to   	 VARCHAR2(1000),
				p_org_type		 VARCHAR2(25),
				p_location		 NUMBER(15),
				p_res_inc_categ		 VARCHAR2(80),
				p_for_inc_categ		 VARCHAR2(80)
			 );

  parm param_t;

/**************************************************************************
 *  Definition of private variables to be used inside the package 	  *
 **************************************************************************/

 l_coa_id	gl_sets_of_books.chart_of_accounts_id%TYPE;
 l_msg		varchar2(500);
 l_retcode	number :=0;
 l_errbuf	varchar2(2000);

 TYPE lookup_rectype is record(
             PRODUCT                      VARCHAR2(3),
             LOOKUP_TYPE                  VARCHAR2(60),
             LOOKUP_CODE                  VARCHAR2(30),
             MEANING                      VARCHAR2(80));
 lookup_meaning_rec lookup_rectype;
 TYPE lookup_tabtype is table of lookup_rectype
        index by binary_integer;

 p_gbl_lookup_table lookup_tabtype;

/**************************************************************************
 *                    Private Procedures Specification                    *
 **************************************************************************/

/**************************************************************************
 *                                                                        *
 * Name       : CONSTRUCT_SELECT, CONSTRUCT_FROM, CONSTRUCT_WHERE         *
 * Purpose    : These procedures are used to construct the complete       *
 *              SELECT statement  		                          *
 *              					                  *
 **************************************************************************/

 PROCEDURE CONSTRUCT_SELECT;
 PROCEDURE CONSTRUCT_FROM;
 PROCEDURE CONSTRUCT_WHERE;
 PROCEDURE build_gbl_lookup_table;


/**************************************************************************
 *                   		Public Procedures                         *
 **************************************************************************/

/**************************************************************************
 *                                                                        *
 * Name       : Get_Withholding_Tax                                       *
 * Purpose    : This is the core generic withholding tax routine, which   *
 *              populates the interface table JG_ZZ_AP_WHT_ITF.           *
 *		This has a call to the following:      			  *
 *              1. Before Report - where it constructs the basic SELECT   *
 *              2. Bind - binds the variables				  *
 *                                                                        *
 **************************************************************************/
 PROCEDURE GET_WITHHOLDING_TAX (request_id	in number,
  				section_name	in varchar2,
				retcode		out NOCOPY number,
				errbuf		out NOCOPY varchar2)
 IS
 BEGIN
	fa_rx_util_pkg.debug('jgrx_wt.get_withholding_tax()+');

	-- Initialize request
	fa_rx_util_pkg.init_request('jgrx_wt.get_withholding_tax', request_id);

	fa_rx_util_pkg.assign_report(section_name,
				true,
				'jgrx_wt.before_report;',
				NULL,
				NULL,
				NULL);

   fa_rx_util_pkg.run_report('jgrx_wt.get_withholding_tax', retcode, errbuf);

	fa_rx_util_pkg.debug('jgrx_wt.get_withholding_tax()-');

 END GET_WITHHOLDING_TAX;


/**************************************************************************
 *                                                                        *
 * Name       : jg_wht_extract   	                                  *
 * Purpose    : This plug-in is specific to suit Korean withholding tax   *
 *		needs. It has the following procedures 			  *
 *		1. Call to the BASIC procedure Get_Withholding_Tax        *
 *              2. Before Report - To add conditions specific to Korea    *
 *              3. Bind - binds the variables				  *
 *              4. After Fetch - does manipulation on fetched record      *
 *                                                                        *
 **************************************************************************/
 PROCEDURE jg_wht_extract (	p_gldate_from		in DATE,
				p_gldate_to		in DATE,
				p_supplier_from		in VARCHAR2,
				p_supplier_to		in VARCHAR2,
				p_supp_tax_reg_num 	in VARCHAR2,
				p_invoice_number	in VARCHAR2,
				p_reporting_level	in VARCHAR2,
				p_reporting_context 	in VARCHAR2,
                        p_legal_entity_id       in NUMBER,
				p_acct_flexfield_from 	in VARCHAR2,
				p_acct_flexfield_to   	in VARCHAR2,
				p_org_type		in VARCHAR2,
				p_location		in NUMBER,
				p_res_inc_categ		in VARCHAR2,
				p_for_inc_categ		in VARCHAR2,
				request_id		in NUMBER,
				retcode			out NOCOPY NUMBER,
				errbuf			out NOCOPY VARCHAR2)
  IS
  BEGIN

	fa_rx_util_pkg.debug('jgrx_wt.jg_wht_extract()+');

	-- Initialize request
	fa_rx_util_pkg.init_request('jgrx_wt.jg_wht_extract', request_id);

  -- Store the parameters in a variable which can be accessed globally across
  -- all procedures
	parm.p_gldate_from		:= p_gldate_from;
	parm.p_gldate_to		:= p_gldate_to;
	parm.p_supplier_from		:= p_supplier_from;
	parm.p_supplier_to		:= p_supplier_to;
	parm.p_supp_tax_reg_num 	:= p_supp_tax_reg_num;
	parm.p_invoice_number		:= p_invoice_number;
	parm.p_reporting_level		:= p_reporting_level;
	parm.p_reporting_context 	:= p_reporting_context;
      parm.p_legal_entity_id        := p_legal_entity_id;
	parm.p_acct_flexfield_from 	:= p_acct_flexfield_from;
	parm.p_acct_flexfield_to   	:= p_acct_flexfield_to;
	parm.p_org_type			:= p_org_type;
	parm.p_location			:= p_location;
	parm.p_res_inc_categ		:= p_res_inc_categ;
	parm.p_for_inc_categ		:= p_for_inc_categ;


  -- Call to construct the basic query. The basic SELECT statement is built in
  -- this stage. Plug-in would add what is specific to the report. No data is
  -- inserted into the interface table at this stage.


  jgrx_wt.get_withholding_tax( request_id,
			  'get_withholding_tax',
			  retcode,
			  errbuf);

  -- Plug-in code is executed here.

  fa_rx_util_pkg.assign_report('get_withholding_tax',
				true,
				'jgrx_wt.wht_before_report;',
				'jgrx_wt.wht_bind(:CURSOR_SELECT);',
				'jgrx_wt.wht_after_fetch;',
				NULL);

  fa_rx_util_pkg.run_report('jgrx_wt.jg_wht_extract', retcode, errbuf);

  fa_rx_util_pkg.debug('jgrx_wt.jg_wht_extract()-');

  END jg_wht_extract;

/***************************************************************************
 *                                                                         *
 * Name       : before_report	                                  	   *
 * Purpose    : This procedure constructs the basic SELECT and INSERT      *
 *		statement to populate the interface table JG_ZZ_AP_WHT_ITF *
 *									   *
 ***************************************************************************/
  PROCEDURE before_report
  IS
  BEGIN
	 fa_rx_util_pkg.debug('jgrx_wt.before_report(+)');

	  -- Get the Reporting SOB_ID, SOB_NAME, Functional_currency_code
	  fnd_profile.get('GL_SET_OF_BKS_ID', jgrx_wt.var.sob_id);

	  begin
		select name, currency_code, chart_of_accounts_id
		into jgrx_wt.var.reporting_sob_name,
	             jgrx_wt.var.func_currency_code, l_coa_id
		from gl_sets_of_books
		where set_of_books_id = jgrx_wt.var.sob_id;
	  exception
		WHEN no_data_found THEN
		  RAISE_APPLICATION_ERROR(-20010,sqlerrm);
	  end;

   	  -- Call to construct the basic select, from and where clauses
	  CONSTRUCT_SELECT;
	  CONSTRUCT_FROM;
	  CONSTRUCT_WHERE;

  END before_report;

/***************************************************************************
 *                                                                         *
 * Name       : wht_before_report	                                   *
 * Purpose    : This procedure has Korean specific WHERE clauses           *
 *		for populating the interface table JG_ZZ_AP_WHT_ITF        *
 *									   *
 ***************************************************************************/

  PROCEDURE wht_before_report
  IS
    l_where_flex	VARCHAR2(2000);
    b_acct_flexfield_from VARCHAR2(1000);
    b_acct_flexfield_to   VARCHAR2(1000);
  BEGIN

    b_acct_flexfield_from := parm.p_acct_flexfield_from;
    b_acct_flexfield_to   := parm.p_acct_flexfield_to;
    --
    -- In the WHERE clause, check for Korean context.
    --
    /* Commented out NOCOPY as the category can be null when there are no mandatory
       segments in the gdf
    fa_rx_util_pkg.Where_clause := fa_rx_util_pkg.Where_clause ||' and
    hrl1.global_attribute_category = ''JA.KR.PERWSLOC.WITHHOLDING'' ';
    fa_rx_util_pkg.Where_clause := fa_rx_util_pkg.Where_clause ||' and
    atc.global_attribute_category = ''JA.KR.APXTADTC.WITHHOLDING'' ';
    fa_rx_util_pkg.Where_clause := fa_rx_util_pkg.Where_clause ||' and
    pvs.global_attribute_category = ''JA.KR.APXVDMVD.WITHHOLDING'' ';  */

    --
    -- Add the WHERE clause specific to the Korean Withholding Report
    --
    If parm.p_gldate_from IS NOT NULL then
       fa_rx_util_pkg.Where_clause := fa_rx_util_pkg.Where_clause ||' and
       ind.accounting_date>= :b_gldate_from';
    End If;
    If parm.p_gldate_to IS NOT NULL then
       fa_rx_util_pkg.Where_clause := fa_rx_util_pkg.Where_clause ||' and
       ind.accounting_date <= :b_gldate_to';
    End If;
    If parm.p_supplier_from IS NOT NULL then
       fa_rx_util_pkg.Where_clause := fa_rx_util_pkg.Where_clause ||' and
       UPPER(pov.vendor_name) >= UPPER(:b_supplier_from)';
    End If;
    If parm.p_supplier_to IS NOT NULL then
       fa_rx_util_pkg.Where_clause := fa_rx_util_pkg.Where_clause ||' and
       UPPER(pov.vendor_name) <= UPPER(:b_supplier_to)';
    End If;
    If parm.p_supp_tax_reg_num IS NOT NULL then
       fa_rx_util_pkg.Where_clause := fa_rx_util_pkg.Where_clause ||' and
 		UPPER(pov.vat_registration_num) = UPPER(:b_supp_tax_reg_num)';
    End If;
    If parm.p_invoice_number IS NOT NULL then
       fa_rx_util_pkg.Where_clause := fa_rx_util_pkg.Where_clause ||' and
       UPPER(ap_inv.invoice_num) = UPPER(:b_invoice_number)';
    End If;
    If parm.p_org_type IS NOT NULL then
       fa_rx_util_pkg.Where_clause := fa_rx_util_pkg.Where_clause ||' and
       UPPER(pov.organization_type_lookup_code) = UPPER(:b_org_type)';
    End If;
    If parm.p_location IS NOT NULL then
	fa_rx_util_pkg.Where_clause := fa_rx_util_pkg.Where_clause ||' and
	hrl1.location_id = :b_location';
    End If;

    If parm.p_res_inc_categ IS NOT NULL then
	fa_rx_util_pkg.Where_clause := fa_rx_util_pkg.Where_clause ||' and
	UPPER(atc.global_attribute9) = UPPER(:b_res_inc_categ)';
    End If;

    If parm.p_for_inc_categ IS NOT NULL then
	fa_rx_util_pkg.Where_clause := fa_rx_util_pkg.Where_clause ||' and
	 UPPER(atc.global_attribute5) = UPPER(:b_for_inc_categ)';
    End If;

    If parm.p_legal_entity_id IS NOT NULL then
	fa_rx_util_pkg.Where_clause := fa_rx_util_pkg.Where_clause ||' and
	 ap_inv.legal_entity_id =(:b_legal_entity_id)';
    End If;

    -- Build the WHERE clause to restrict data based on the accounting flex
    -- field range specified.
    If (parm.p_acct_flexfield_from IS NOT NULL
       and parm.p_acct_flexfield_to IS NOT NULL) then
    	l_where_flex := FA_RX_FLEX_PKG.FLEX_SQL(P_APPLICATION_ID => 101,
        		    		 P_ID_FLEX_CODE => 'GL#',
        		    		 P_ID_FLEX_NUM => L_COA_ID,
        		    		 P_TABLE_ALIAS => 'CC',
        		    		 P_MODE => 'WHERE',
        		    		 P_QUALIFIER => 'ALL',
        		    		 P_FUNCTION => 'BETWEEN',
        		    		 P_OPERAND1 => b_acct_flexfield_from,
        		    		 P_OPERAND2 => b_acct_flexfield_to);

        l_where_flex := ' and '||l_where_flex;
    fa_rx_util_pkg.Where_clause := fa_rx_util_pkg.Where_clause || l_where_flex;
    End if;

  fa_rx_util_pkg.debug('jgrx_wt.wht_before_report()-');

  END wht_before_report;


/***************************************************************************
 *                                                                         *
 * Name       : wht_bind	                                  	   *
 * Purpose    : This procedure accepts an integer parameter :CURSOR_SELECT *
 *		and binds the parameter to variables			   *
 *									   *
 ***************************************************************************/

  PROCEDURE wht_bind(c in integer)
  IS
   b_gldate_from  		date;
   b_gldate_to			date;
   b_supplier_from		varchar2(240);
   b_supplier_to		varchar2(240);
   b_supp_tax_reg_num 		varchar2(20);
   b_invoice_number		varchar2(50);
   b_acct_flexfield_from 	varchar2(1000);
   b_acct_flexfield_to 		varchar2(1000);
   b_legal_entity_id          number;
   b_org_type			varchar2(25);
   b_location			number(15);
   b_res_inc_categ 		varchar2(80);
   b_for_inc_categ 		varchar2(80);

  BEGIN

   fa_rx_util_pkg.debug('jgrx_wt.wht_bind()+');

   If parm.p_gldate_from IS NOT NULL then
    fa_rx_util_pkg.debug('Binding b_gldate_from');
    dbms_sql.bind_variable(c, 'b_gldate_from', parm.p_gldate_from);
   End If;

   If parm.p_gldate_to IS NOT NULL then
    fa_rx_util_pkg.debug('Binding b_gldate_to');
    dbms_sql.bind_variable(c, 'b_gldate_to', parm.p_gldate_to);
   End If;

   If parm.p_supplier_from IS NOT NULL then
    fa_rx_util_pkg.debug('Binding b_supplier_from');
    dbms_sql.bind_variable(c, 'b_supplier_from', parm.p_supplier_from);
   End If;

   If parm.p_supplier_to IS NOT NULL then
    fa_rx_util_pkg.debug('Binding b_supplier_to');
    dbms_sql.bind_variable(c, 'b_supplier_to', parm.p_supplier_to);
   End If;

   If parm.p_supp_tax_reg_num IS NOT NULL then
    fa_rx_util_pkg.debug('Binding b_supp_tax_reg_num');
    dbms_sql.bind_variable(c, 'b_supp_tax_reg_num', parm.p_supp_tax_reg_num);
   End If;

   If parm.p_invoice_number IS NOT NULL then
    fa_rx_util_pkg.debug('Binding b_invoice_number');
    dbms_sql.bind_variable(c, 'b_invoice_number', parm.p_invoice_number);
   End If;

/* Commented out NOCOPY for Bug 1339331

   If parm.p_acct_flexfield_from IS NOT NULL then
    fa_rx_util_pkg.debug('Binding b_acct_flexfield_from');
    dbms_sql.bind_variable(c, 'b_acct_flexfield_from',parm.p_acct_flexfield_from);
   End If;

   If parm.p_acct_flexfield_to IS NOT NULL then
    fa_rx_util_pkg.debug('Binding b_acct_flexfield_to');
    dbms_sql.bind_variable(c, 'b_acct_flexfield_to', parm.p_acct_flexfield_to);
   End If;
  End Comment for Bug 1339331 */

   If parm.p_org_type IS NOT NULL then
    fa_rx_util_pkg.debug('Binding b_org_type');
    dbms_sql.bind_variable(c, 'b_org_type', parm.p_org_type);
   End If;

   If parm.p_location IS NOT NULL then
    fa_rx_util_pkg.debug('Binding b_location');
    dbms_sql.bind_variable(c, 'b_location', parm.p_location);
   End If;

   If parm.p_res_inc_categ IS NOT NULL then
    fa_rx_util_pkg.debug('Binding b_res_inc_categ');
    dbms_sql.bind_variable(c, 'b_res_inc_categ', parm.p_res_inc_categ);
   End If;

   If parm.p_for_inc_categ IS NOT NULL then
    fa_rx_util_pkg.debug('Binding b_for_inc_categ');
    dbms_sql.bind_variable(c, 'b_for_inc_categ', parm.p_for_inc_categ);
   End If;

   If parm.p_legal_entity_id IS NOT NULL then
    fa_rx_util_pkg.debug('Binding b_legal_entity_id');
    dbms_sql.bind_variable(c, 'b_legal_entity_id', parm.p_legal_entity_id);
   End If;


   fa_rx_util_pkg.debug('jgrx_wt.wht_bind()-');
 END wht_bind;

/***************************************************************************
 *                                                                         *
 * Name       : wht_after_fetch                                  	   *
 * Purpose    : This procedure does any manipulation required on the       *
 *		fetched record before populating the interface table       *
 *		JG_ZZ_AP_WHT_ITF 					   *
 *									   *
 ***************************************************************************/
 PROCEDURE wht_after_fetch
 IS
 BEGIN
  fa_rx_util_pkg.debug('jgrx_wt.wht_after_fetch()+');

  jgrx_wt.var.total_wht_amount := jgrx_wt.var.resident_tax+
  					jgrx_wt.var.income_tax;
  /* Bug 1339324 */
  IF jgrx_wt.var.amt_subject_to_wh is NULL then
        jgrx_wt.var.amt_subject_to_wh := jgrx_wt.var.invoice_amount;
  END IF;

  /* Bug 1347708 */
  IF (jgrx_wt.var.total_wht_amount > 0 and jgrx_wt.var.amt_subject_to_wh > 0)
  THEN
        jgrx_wt.var.amt_subject_to_wh := -1 * jgrx_wt.var.amt_subject_to_wh;
  END IF;

  jgrx_wt.var.recognized_expense_amt := jgrx_wt.var.amt_subject_to_wh*
   			to_number(jgrx_wt.var.recognized_expense_percent)/100;

  jgrx_wt.var.nominal_or_reg_tax_rate :=
				nvl(to_number(jgrx_wt.var.nominal_tax_rate),
						jgrx_wt.var.tax_rate);

  IF (jgrx_wt.var.withholding_tax_type = 'INCOME') THEN
	jgrx_wt.var.inc_wh_tax_base_amt := jgrx_wt.var.amt_subject_to_wh-
				nvl(jgrx_wt.var.recognized_expense_amt,0);
	jgrx_wt.var.inc_wh_tax_base_amt := Ap_Utilities_Pkg.Ap_Round_Currency
					(jgrx_wt.var.inc_wh_tax_base_amt,
					 jgrx_wt.var.func_currency_code);
  ELSE
	 jgrx_wt.var.inc_wh_tax_base_amt := 0;
  END IF;

  IF (jgrx_wt.var.withholding_tax_type = 'RESIDENT') THEN
	jgrx_wt.var.res_wh_tax_base_amt := jgrx_wt.var.amt_subject_to_wh;
  ELSE
        jgrx_wt.var.res_wh_tax_base_amt := 0;
  END IF;

  jgrx_wt.var.total_tax_base_amt := nvl(jgrx_wt.var.res_wh_tax_base_amt,0) +
			            nvl(jgrx_wt.var.inc_wh_tax_base_amt,0);

   IF (jgrx_wt.var.create_dist = 'PAYMENT') then
       jgrx_wt.var.net_amount:= jgrx_wt.var.payment_amount;
   ELSIF (jgrx_wt.var.create_dist = 'APPROVAL') then
    declare
     l_amount NUMBER := 0;
    begin
     select sum(nvl(ind.base_amount,ind.amount))
     into l_amount
     from ap_invoice_distributions_all ind
     where ind.invoice_id = jgrx_wt.var.invoice_id
     and ind.line_type_lookup_code = 'AWT'
     and ind.org_id = jgrx_wt.var.org_id;
     jgrx_wt.var.net_amount:= jgrx_wt.var.invoice_amount + l_amount;
    exception
     WHEN no_data_found THEN
        RAISE_APPLICATION_ERROR(-20010,sqlerrm);
     when others then
        fa_rx_util_pkg.debug( 'Exception in wht_after_fetch'||
                  			SQLCODE||';'||SQLERRM);
    end;
   END IF;

  jgrx_wt.var.supp_concatenated_address := jgrx_wt.var.supplier_address_line1
    || jgrx_wt.var.supplier_address_line2|| jgrx_wt.var.supplier_address_line3
    || jgrx_wt.var.supplier_country|| jgrx_wt.var.supplier_postal_code;

  jgrx_wt.var.accounting_flexfield := FA_RX_FLEX_PKG.GET_VALUE
  			(P_APPLICATION_ID => 101,
        	    	 P_ID_FLEX_CODE => 'GL#',
        	    	 P_ID_FLEX_NUM => L_COA_ID,
        	    	 P_QUALIFIER => 'ALL',
			 P_CCID => jgrx_wt.var.dist_code_combination_id);

  jgrx_wt.var.biz_inc_sub_categ_meaning := get_lookup_meaning('FND',
					 'JAKR_AP_AWT_BIZ_INC_SUB_CAT',
				 jgrx_wt.var.business_inc_sub_category);

  jgrx_wt.var.org_type_meaning := get_lookup_meaning('PO',
					 'ORGANIZATION TYPE',
					 jgrx_wt.var.organization_type);

  jgrx_wt.var.wh_tax_type_meaning :=  get_lookup_meaning('FND',
					 'JAKR_AP_AWT_TAX_TYPE',
					jgrx_wt.var.withholding_tax_type);

  jgrx_wt.var.res_inc_categ_meaning :=  get_lookup_meaning('FND',
					 'JAKR_AP_AWT_INC_CAT_DOMESTIC',
					jgrx_wt.var.resident_inc_categ_code);

  jgrx_wt.var.for_inc_categ_meaning := get_lookup_meaning('FND',
					 'JAKR_AP_AWT_INC_CAT_FOREIGN',
					jgrx_wt.var.foreign_inc_categ_code);

  fa_rx_util_pkg.debug('jgrx_wt.wht_after_fetch()-');

 END wht_after_fetch;


/**************************************************************************
 *                                                                         *
 * Name       : get_lookup_meaning	                                   *
 * Purpose    : This function returns the meaning for the matching         *
 *		lookup_type and lookup_code in po_lookup_codes,            *
 *		fnd_lookups using a memory structure.			   *
 *									   *
 **************************************************************************/

  FUNCTION get_lookup_meaning(  p_product in varchar2,
                         	p_lookup_type in varchar2,
                         	p_lookup_code in varchar2)
  RETURN varchar2
  IS
  BEGIN

   if nvl(p_gbl_lookup_table.LAST,0) <= 0 then
         build_gbl_lookup_table;
   end if;

   for i in 1 .. p_gbl_lookup_table.count loop
             if p_gbl_lookup_table(i).lookup_type = p_lookup_type and
                p_gbl_lookup_table(i).lookup_code = p_lookup_code and
                p_gbl_lookup_table(i).product = p_product
             then
                 return p_gbl_lookup_table(i).meaning ;
             end if;

   end loop;

   return (NULL);

 End;

 /**************************************************************************
 				Private Procedures
 **************************************************************************/

/**************************************************************************
 *                                                                        *
 * Name       : CONSTRUCT_SELECT, CONSTRUCT_FROM, CONSTRUCT_WHERE         *
 * Purpose    : These procedures are used to construct the complete       *
 *              SELECT statement  		                          *
 *              					                  *
 **************************************************************************/

 PROCEDURE CONSTRUCT_SELECT
 IS
 BEGIN
   -- Write the basic select statement, From and Where clause
   fa_rx_util_pkg.assign_column('1', 'hrl1.location_code', 'location_name',
    			'jgrx_wt.var.location_name', 'VARCHAR2', 60);
   fa_rx_util_pkg.assign_column('2', 'hrl1.address_line_1', 'location_address1',
 			'jgrx_wt.var.location_address1', 'VARCHAR2', 240);
   fa_rx_util_pkg.assign_column('3', 'hrl1.address_line_2', 'location_address2',
			'jgrx_wt.var.location_address2', 'VARCHAR2', 240);
   fa_rx_util_pkg.assign_column('4', 'hrl1.address_line_3', 'location_address3',
			'jgrx_wt.var.location_address3', 'VARCHAR2', 240);
   fa_rx_util_pkg.assign_column('5', 'hrl1.country', 'location_country',
			'jgrx_wt.var.location_country', 'VARCHAR2', 60);
   fa_rx_util_pkg.assign_column('6', 'hrl1.postal_code', 'location_zipcode',
			'jgrx_wt.var.location_zipcode', 'VARCHAR2', 30);
   fa_rx_util_pkg.assign_column('7', 'hrl1.telephone_number_1', 'location_phone'
		,	'jgrx_wt.var.location_phone', 'VARCHAR2', 30);
   fa_rx_util_pkg.assign_column('8', 'xle.name', 'legal_entity_name',
                 'jgrx_wt.var.legal_entity_name', 'VARCHAR2',60);
   fa_rx_util_pkg.assign_column('9', 'xle.town_or_city', 'legal_entity_city',
                  'jgrx_wt.var.legal_entity_city', 'VARCHAR2', 30);
   fa_rx_util_pkg.assign_column('10','xle.address_line_1','legal_entity_address1',
                  'jgrx_wt.var.legal_entity_address1', 'VARCHAR2', 240);
   fa_rx_util_pkg.assign_column('11', 'xle.address_line_2','legal_entity_address2',
			'jgrx_wt.var.legal_entity_address2', 'VARCHAR2', 240);
   fa_rx_util_pkg.assign_column('12', 'xle.address_line_3','legal_entity_address3',
			'jgrx_wt.var.legal_entity_address3', 'VARCHAR2', 240);
   fa_rx_util_pkg.assign_column('13', 'xle.country','legal_entity_country',
                  'jgrx_wt.var.legal_entity_country', 'VARCHAR2', 60);
   fa_rx_util_pkg.assign_column('14', 'xle.postal_code','legal_entity_zipcode',
                 'jgrx_wt.var.legal_entity_zipcode', 'VARCHAR2', 30);
   -- Modified the below to NULL for bug 4734440
   fa_rx_util_pkg.assign_column('15', NULL, 'legal_entity_phone',
                 'jgrx_wt.var.legal_entity_phone', 'VARCHAR2', 30);
   fa_rx_util_pkg.assign_column('16', 'hrl1.global_attribute1',
                 'hrl_global_attribute1', 'jgrx_wt.var.tax_registration_num', 'VARCHAR2',150);
   fa_rx_util_pkg.assign_column('17', 'hrl1.global_attribute4',
                 'hrl_global_attribute4', 'jgrx_wt.var.loc_taxable_person', 'VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('18', 'pov.vendor_id', 'supplier_id',
				'jgrx_wt.var.supplier_id', 'NUMBER');
   fa_rx_util_pkg.assign_column('19', 'pov.vendor_name', 'supplier_name',
			'jgrx_wt.var.supplier_name', 'VARCHAR2', 240);
   fa_rx_util_pkg.assign_column('20', 'pvs.vendor_site_id', 'supplier_site_id',
				'jgrx_wt.var.supplier_site_id', 'NUMBER');
   fa_rx_util_pkg.assign_column('21','pvs.vendor_site_code','supplier_site_name'
			,'jgrx_wt.var.supplier_site_name','VARCHAR2',100);
   fa_rx_util_pkg.assign_column('22', 'pov.attribute1', ' pv_attribute1',
			'jgrx_wt.var.pv_attribute1','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('23', 'pov.attribute2', ' pv_attribute2',
				'jgrx_wt.var.pv_attribute2','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('24', 'pov.attribute3', ' pv_attribute3',
				'jgrx_wt.var.pv_attribute3','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('25', 'pov.attribute4', ' pv_attribute4',
				'jgrx_wt.var.pv_attribute4','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('26', 'pov.attribute5', ' pv_attribute5',
				'jgrx_wt.var.pv_attribute5','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('27', 'pov.attribute6', ' pv_attribute6',
				'jgrx_wt.var.pv_attribute6','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('28', 'pov.attribute7', ' pv_attribute7',
				'jgrx_wt.var.pv_attribute7','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('29', 'pov.attribute8', ' pv_attribute8',
				'jgrx_wt.var.pv_attribute8','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('30', 'pov.attribute9', ' pv_attribute9',
				'jgrx_wt.var.pv_attribute9','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('31', 'pov.attribute10', ' pv_attribute10',
				'jgrx_wt.var.pv_attribute10','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('32', 'pov.attribute11', ' pv_attribute11',
				'jgrx_wt.var.pv_attribute11','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('33', 'pov.attribute12', ' pv_attribute12',
			'jgrx_wt.var.pv_attribute12','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('34', 'pov.attribute13', ' pv_attribute13',
			'jgrx_wt.var.pv_attribute13','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('35', 'pov.attribute14', ' pv_attribute14',
			'jgrx_wt.var.pv_attribute14','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('36', 'pov.attribute15', ' pv_attribute15',
			'jgrx_wt.var.pv_attribute15','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('37', 'pvs.attribute1', ' pvs_attribute1',
			'jgrx_wt.var.pvs_attribute1','VARCHAR2',150);
   fa_rx_util_pkg.assign_column('38', 'pvs.attribute2', ' pvs_attribute2',
				'jgrx_wt.var.pvs_attribute2','VARCHAR2',150);
   fa_rx_util_pkg.assign_column('39', 'pvs.attribute3', ' pvs_attribute3',
			'jgrx_wt.var.pvs_attribute3','VARCHAR2',150);
   fa_rx_util_pkg.assign_column('40', 'pvs.attribute4', ' pvs_attribute4',
			'jgrx_wt.var.pvs_attribute4','VARCHAR2',150);
   fa_rx_util_pkg.assign_column('41', 'pvs.attribute5', ' pvs_attribute5',
			'jgrx_wt.var.pvs_attribute5','VARCHAR2',150);
   fa_rx_util_pkg.assign_column('42', 'pvs.attribute6', ' pvs_attribute6',
			'jgrx_wt.var.pvs_attribute6','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('43', 'pvs.attribute7', ' pvs_attribute7',
			'jgrx_wt.var.pvs_attribute7','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('44', 'pvs.attribute8', ' pvs_attribute8',
			'jgrx_wt.var.pvs_attribute8','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('45', 'pvs.attribute9', ' pvs_attribute9',
  			'jgrx_wt.var.pvs_attribute9','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('46', 'pvs.attribute10', ' pvs_attribute10',
			'jgrx_wt.var.pvs_attribute10','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('47', 'pvs.attribute11', ' pvs_attribute11',
			'jgrx_wt.var.pvs_attribute11','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('48', 'pvs.attribute12', ' pvs_attribute12',
			'jgrx_wt.var.pvs_attribute12','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('49', 'pvs.attribute13', ' pvs_attribute13',
			'jgrx_wt.var.pvs_attribute13','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('50', 'pvs.attribute14', ' pvs_attribute14',
			'jgrx_wt.var.pvs_attribute14','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('51', 'pvs.attribute15', ' pvs_attribute15',
			'jgrx_wt.var.pvs_attribute15','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('52','ap_inv.attribute1', ' inv_attribute1',
   				'jgrx_wt.var.inv_attribute1','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('53', 'ap_inv.attribute2', ' inv_attribute2',
			'jgrx_wt.var.inv_attribute2','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('54', 'ap_inv.attribute3', ' inv_attribute3',
			'jgrx_wt.var.inv_attribute3','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('55', 'ap_inv.attribute4', ' inv_attribute4',
			'jgrx_wt.var.inv_attribute4','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('56', 'ap_inv.attribute5', ' inv_attribute5',
			'jgrx_wt.var.inv_attribute5','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('57', 'ap_inv.attribute6', ' inv_attribute6',
			'jgrx_wt.var.inv_attribute6','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('58', 'ap_inv.attribute7', ' inv_attribute7',
			'jgrx_wt.var.inv_attribute7','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('59', 'ap_inv.attribute8', ' inv_attribute8',
			'jgrx_wt.var.inv_attribute8','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('60', 'ap_inv.attribute9', ' inv_attribute9',
			'jgrx_wt.var.inv_attribute9','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('61', 'ap_inv.attribute10', ' inv_attribute10',
			'jgrx_wt.var.inv_attribute10','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('62', 'ap_inv.attribute11', ' inv_attribute11',
			'jgrx_wt.var.inv_attribute11','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('63', 'ap_inv.attribute12', ' inv_attribute12',
			'jgrx_wt.var.inv_attribute12','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('64', 'ap_inv.attribute13', ' inv_attribute13',
			'jgrx_wt.var.inv_attribute13','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('65', 'ap_inv.attribute14', ' inv_attribute14',
 			'jgrx_wt.var.inv_attribute14','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('66', 'ap_inv.attribute15', ' inv_attribute15',
			'jgrx_wt.var.inv_attribute15','VARCHAR2', 150);
  fa_rx_util_pkg.assign_column('67', 'pvs.country', 'supplier_country',
  				'jgrx_wt.var.supplier_country','VARCHAR2', 25);
   fa_rx_util_pkg.assign_column('68', 'pvs.address_line1',
   'supplier_address_line1','jgrx_wt.var.supplier_address_line1','VARCHAR2',240);
   fa_rx_util_pkg.assign_column('69', 'pvs.address_line2',
   'supplier_address_line2','jgrx_wt.var.supplier_address_line2','VARCHAR2',240);
   fa_rx_util_pkg.assign_column('70', 'pvs.address_line3',
   'supplier_address_line3','jgrx_wt.var.supplier_address_line3','VARCHAR2',240);
   fa_rx_util_pkg.assign_column('71', 'pvs.city', 'supplier_city',
				'jgrx_wt.var.supplier_city','VARCHAR2', 25);
   fa_rx_util_pkg.assign_column('72', 'pvs.zip', 'supplier_postal_code',
			'jgrx_wt.var.supplier_postal_code','VARCHAR2', 20);
   fa_rx_util_pkg.assign_column('73', 'pvs.province', 'supplier_province',
			'jgrx_wt.var.supplier_province','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('74', 'pvs.county', 'supplier_county',
			'jgrx_wt.var.supplier_county','VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('75', 'pvs.global_attribute1',
  'pvs_global_attribute1','jgrx_wt.var.supplier_taxable_person','VARCHAR2',150);
   fa_rx_util_pkg.assign_column('76', 'nvl(pvs.vat_registration_num,
   	pov.vat_registration_num)', 'supplier_tax_registration_num',
	'jgrx_wt.var.supplier_tax_registration_num','VARCHAR2', 20);
   fa_rx_util_pkg.assign_column('77','pov.num_1099', 'supplier_taxpayer_id',
			'jgrx_wt.var.supplier_taxpayer_id','VARCHAR2', 30);
   fa_rx_util_pkg.assign_column('78','pvs.global_attribute2',
'pvs_global_attribute2','jgrx_wt.var.business_inc_sub_category','VARCHAR2',150);
   fa_rx_util_pkg.assign_column('79', NULL, 'biz_inc_sub_categ_meaning',
		'jgrx_wt.var.biz_inc_sub_categ_meaning','VARCHAR2', 80);
   fa_rx_util_pkg.assign_column('80', 'ind.dist_code_combination_id',
'dist_code_combination_id','jgrx_wt.var.dist_code_combination_id', 'NUMBER',15);
   fa_rx_util_pkg.assign_column('81', 'ap_inv.invoice_num', 'transaction_number',
			'jgrx_wt.var.transaction_number','VARCHAR2', 50);
   fa_rx_util_pkg.assign_column('82', 'ind.accounting_date', 'accounting_date',
				'jgrx_wt.var.accounting_date','DATE');
   fa_rx_util_pkg.assign_column('83', 'ap_inv.voucher_num', 'document_number',
			'jgrx_wt.var.document_number','VARCHAR2', 50);
   fa_rx_util_pkg.assign_column('84', 'pov.organization_type_lookup_code',
    'organization_type', 'jgrx_wt.var.organization_type','VARCHAR2', 25);
   fa_rx_util_pkg.assign_column('85', NULL, 'org_type_meaning',
			'jgrx_wt.var.org_type_meaning','VARCHAR2', 80);
   fa_rx_util_pkg.assign_column('86', 'atc.tax_id', 'tax_id',
			   'jgrx_wt.var.tax_id', 'NUMBER', 15);
   fa_rx_util_pkg.assign_column('87', 'atr.tax_name', 'tax_code',
				'jgrx_wt.var.tax_code','VARCHAR2', 15);
   fa_rx_util_pkg.assign_column('88', 'atc.description', 'awt_description',
			'jgrx_wt.var.awt_description','VARCHAR2', 240);
   fa_rx_util_pkg.assign_column('89', 'atc.tax_type', 'tax_type',
			'jgrx_wt.var.tax_type','VARCHAR2', 25);
   fa_rx_util_pkg.assign_column('90', 'atr.tax_rate_id', 'tax_rate_id',
			'jgrx_wt.var.tax_rate_id','NUMBER', 15);
   fa_rx_util_pkg.assign_column('91', 'atr.tax_rate', 'tax_rate',
				'jgrx_wt.var.tax_rate', 'NUMBER');
   fa_rx_util_pkg.assign_column('92', 'atc.global_attribute6',
   'atc_global_attribute6','jgrx_wt.var.recognized_expense_percent',
   'VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('93', 'atc.global_attribute7',
   'atc_global_attribute7', 'jgrx_wt.var.nominal_tax_rate', 'VARCHAR2',150);
   fa_rx_util_pkg.assign_column('94', 'atc.global_attribute1',
   'atc_global_attribute1', 'jgrx_wt.var.tax_location', 'VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('95', 'atc.global_attribute4',
   'atc_global_attribute4', 'jgrx_wt.var.withholding_tax_type', 'VARCHAR2',150);
   fa_rx_util_pkg.assign_column('96', NULL,
   'wh_tax_type_meaning', 'jgrx_wt.var.wh_tax_type_meaning', 'VARCHAR2',80);
   fa_rx_util_pkg.assign_column('97', 'atc.global_attribute9',
  'atc_global_attribute9','jgrx_wt.var.resident_inc_categ_code','VARCHAR2',150);
   fa_rx_util_pkg.assign_column('98', NULL,
   'res_inc_categ_meaning', 'jgrx_wt.var.res_inc_categ_meaning','VARCHAR2',80);
   fa_rx_util_pkg.assign_column('99', 'atc.global_attribute5',
   'atc_global_attribute5','jgrx_wt.var.foreign_inc_categ_code','VARCHAR2',150);
   fa_rx_util_pkg.assign_column('100', NULL,
   'for_inc_categ_meaning', 'jgrx_wt.var.for_inc_categ_meaning', 'VARCHAR2',80);
   fa_rx_util_pkg.assign_column('101', 'pv1.vendor_name',
   'tax_authority_name', 'jgrx_wt.var.tax_authority_name', 'VARCHAR2',240);
   fa_rx_util_pkg.assign_column('102', 'ap_inv.payment_status_flag',
   				'status', 'jgrx_wt.var.status', 'VARCHAR2',1);
   fa_rx_util_pkg.assign_column('103', 'decode(atc.global_attribute4,''INCOME'',
	nvl(ind.base_amount,ind.amount),0)', 'income_tax', 'jgrx_wt.var.income_tax' ,'NUMBER');
  fa_rx_util_pkg.assign_column('104','decode(atc.global_attribute4,''RESIDENT'',
	nvl(ind.base_amount,ind.amount),0)','resident_tax', 'jgrx_wt.var.resident_tax' ,'NUMBER');
   fa_rx_util_pkg.assign_column('105', NULL, 'total_wht_amount',
				'jgrx_wt.var.total_wht_amount' ,'NUMBER');
  fa_rx_util_pkg.assign_column('106','decode(ap_sp.create_awt_dists_type,''PAYMENT
  		'',ap_inv.payment_currency_code, NULL)','payment_currency',
   			'jgrx_wt.var.payment_currency' ,  'VARCHAR2', 15);
  fa_rx_util_pkg.assign_column('107','decode(ap_sp.create_awt_dists_type,''PAYMENT
   		'',aip.invoice_payment_id, NULL)','invoice_payment_id',
			   'jgrx_wt.var.invoice_payment_id' , 'NUMBER', 15);
fa_rx_util_pkg.assign_column('108','decode(ap_sp.create_awt_dists_type,''PAYMENT''
 ,nvl(aip.payment_base_amount,aip.amount), NULL)','payment_amount', 'jgrx_wt.var.payment_amount' , 'NUMBER');
   fa_rx_util_pkg.assign_column('109','decode(ap_sp.create_awt_dists_type,
		''PAYMENT'',apc.check_date, NULL)','payment_date',
   				'jgrx_wt.var.payment_date' , 'DATE');
   fa_rx_util_pkg.assign_column('110','decode(ap_sp.create_awt_dists_type,
  ''PAYMENT'', aip.payment_num, NULL)','payment_number',
			   'jgrx_wt.var.payment_number','NUMBER', 15);
fa_rx_util_pkg.assign_column('111','decode(ap_sp.create_awt_dists_type,''PAYMENT''
   ,apc.check_id, NULL)','check_id', 'jgrx_wt.var.check_id' , 'NUMBER', 15);
   fa_rx_util_pkg.assign_column('112','decode(ap_sp.create_awt_dists_type,
   		''PAYMENT'', apc.check_number, NULL)','check_number',
				'jgrx_wt.var.check_number','NUMBER',15);
   fa_rx_util_pkg.assign_column('113','decode(ap_sp.create_awt_dists_type,
	''PAYMENT'', nvl(apc.base_amount,apc.amount), NULL)','check_amount',
		'jgrx_wt.var.check_amount' , 'NUMBER');
   fa_rx_util_pkg.assign_column('114','ap_inv.invoice_id','invoice_id',
				'jgrx_wt.var.invoice_id' , 'NUMBER', 15);
   fa_rx_util_pkg.assign_column('115','ind.invoice_distribution_id',
  'invoice_distribution_id','jgrx_wt.var.invoice_distribution_id','NUMBER', 15);
    -- Added to handle foreign currency invoices
   fa_rx_util_pkg.assign_column('116','nvl(ap_inv.base_amount,ap_inv.invoice_amount)',	'invoice_amount', 'jgrx_wt.var.invoice_amount' , 'NUMBER');
   fa_rx_util_pkg.assign_column('117','ap_inv.invoice_date','invoice_date',
				'jgrx_wt.var.invoice_date' , 'DATE');
 fa_rx_util_pkg.assign_column('118','ap_inv.invoice_currency_code','currency_code', 			'jgrx_wt.var.currency_code' , 'VARCHAR2', 15);
   fa_rx_util_pkg.assign_column('119',NULL,'func_currency_code',
			'jgrx_wt.var.func_currency_code' , 'VARCHAR2', 15);
   fa_rx_util_pkg.assign_column('120','ind.awt_gross_amount*nvl(ap_inv.exchange_rate
	,1)','amt_subject_to_wh', 'jgrx_wt.var.amt_subject_to_wh' ,'NUMBER');
   fa_rx_util_pkg.assign_column('121',NULL, 'recognized_expense_amt',
			'jgrx_wt.var.recognized_expense_amt','NUMBER');
   fa_rx_util_pkg.assign_column('122',NULL, 'inc_wh_tax_base_amt',
			'jgrx_wt.var.inc_wh_tax_base_amt' ,'NUMBER');
   fa_rx_util_pkg.assign_column('123',NULL, 'res_wh_tax_base_amt',
			'jgrx_wt.var.res_wh_tax_base_amt' ,'NUMBER');
   fa_rx_util_pkg.assign_column('124',NULL, 'total_tax_base_amt',
			'jgrx_wt.var.total_tax_base_amt','NUMBER');
   fa_rx_util_pkg.assign_column('125', NULL, 'net_amount',
			'jgrx_wt.var.net_amount', 'NUMBER');
   fa_rx_util_pkg.assign_column('126','ind.distribution_line_number',
   	   'line_number', 'jgrx_wt.var.line_number' , 'NUMBER', 15);
   fa_rx_util_pkg.assign_column('127','ind.type_1099','TYPE_1099',
			'jgrx_wt.var.type_1099' , 'VARCHAR2', 10);
   fa_rx_util_pkg.assign_column('128','ind.description', 'item_description',
			'jgrx_wt.var.item_description' , 'VARCHAR2', 240);
   fa_rx_util_pkg.assign_column('129', 'xle.registration_number',
   'hrl_global_attribute11', 'jgrx_wt.var.corporate_id_number', 'VARCHAR2', 150);
   fa_rx_util_pkg.assign_column('130','hrl1.telephone_number_2','location_fax',
			'jgrx_wt.var.location_fax', 'VARCHAR2', 60);
   fa_rx_util_pkg.assign_column('131', NULL, 'accounting_flexfield',
			'jgrx_wt.var.accounting_flexfield', 'VARCHAR2', 1000);
   fa_rx_util_pkg.assign_column('132',NULL, 'supp_concatenated_address',
        'jgrx_wt.var.supp_concatenated_address' , 'VARCHAR2', 800);
   fa_rx_util_pkg.assign_column('133','ou.name','organization_name',
   			'jgrx_wt.var.organization_name' , 'VARCHAR2', 60);
   fa_rx_util_pkg.assign_column('134',NULL,'reporting_entity_name',
			'jgrx_wt.var.reporting_entity_name','VARCHAR2', 15);
   fa_rx_util_pkg.assign_column('135',NULL,'reporting_sob_name',
			'jgrx_wt.var.reporting_sob_name' , 'VARCHAR2', 15);
   fa_rx_util_pkg.assign_column('136', NULL, 'sob_id','jgrx_wt.var.sob_id' ,
					'VARCHAR2', 15);
   fa_rx_util_pkg.assign_column('137','ap_sp.create_awt_dists_type',
		NULL, 'jgrx_wt.var.create_dist' , 'VARCHAR2', 15);
   fa_rx_util_pkg.assign_column('138','ap_inv.org_id',
                NULL, 'jgrx_wt.var.org_id' , 'NUMBER', 15);
   fa_rx_util_pkg.assign_column('139',NULL, 'nominal_or_reg_tax_rate',
	'jgrx_wt.var.nominal_or_reg_tax_rate', 'NUMBER');
   fa_rx_util_pkg.assign_column('140','ind.invoice_line_number',
	'invoice_line_num', 'jgrx_wt.var.invoice_line_number', 'NUMBER');


 END CONSTRUCT_SELECT;

 PROCEDURE CONSTRUCT_FROM
 IS
 BEGIN
   -- Assign the FROM clause
   fa_rx_util_pkg.debug('jgrx_wt.construct_from()-');
   fa_rx_util_pkg.From_clause :=  'ap_invoices_all ap_inv,
   				   ap_invoice_distributions_all ind,
   				   po_vendors pov,
				   po_vendors pv1,
				   po_vendor_sites_all pvs,
				   ap_tax_codes_all atc,
				   ap_awt_tax_rates_all atr,
				   hr_locations_all hrl1,
				   xle_firstparty_information_v xle,
				   ap_invoice_payments_all aip,
				   ap_checks_all apc,
				   gl_code_combinations cc,
				   ap_system_parameters_all ap_sp,
				   hr_all_organization_units ou,
   				   hr_organization_information oi';


   fa_rx_util_pkg.debug('jgrx_wt.construct_from()+');

  END CONSTRUCT_FROM;

  PROCEDURE CONSTRUCT_WHERE
  IS
 	l_reporting_context VARCHAR2(25);
	l_where_reporting_context_inv 	VARCHAR2(500);
	l_where_reporting_context_ind 	VARCHAR2(500);
	l_where_reporting_context_atc 	VARCHAR2(500);
	l_where_reporting_context_atr 	VARCHAR2(500);
	l_where_reporting_context_pvs 	VARCHAR2(500);
	l_where_reporting_context_aip  	VARCHAR2(500);
	l_where_reporting_context_apc  	VARCHAR2(500);
	l_where_reporting_context_asp  	VARCHAR2(500);

   BEGIN
     -- Assign the WHERE clause
     fa_rx_util_pkg.debug('jgrx_wt.construct_Where()-');

-- This call to be Changed due to MOAC uptake
-- Condition to check if the report is run for LE or for cross-org


     l_reporting_context := parm.p_reporting_context;

    if parm.p_legal_entity_id is null then

     fnd_mo_reporting_api.initialize(parm.p_reporting_level,
					l_reporting_context, 'AUTO');
     l_where_reporting_context_inv := fnd_mo_reporting_api.get_predicate('AP_INV', NULL, l_reporting_context);
     l_where_reporting_context_ind := fnd_mo_reporting_api.get_predicate('IND', NULL, l_reporting_context);
     l_where_reporting_context_atc := fnd_mo_reporting_api.get_predicate('ATC', NULL, l_reporting_context);
     l_where_reporting_context_atr := fnd_mo_reporting_api.get_predicate('ATR', NULL, l_reporting_context);
     l_where_reporting_context_pvs := fnd_mo_reporting_api.get_predicate('PVS', NULL, l_reporting_context);
     l_where_reporting_context_asp := fnd_mo_reporting_api.get_predicate('AP_SP', NULL, l_reporting_context);
     l_where_reporting_context_aip := fnd_mo_reporting_api.get_predicate('AIP', NULL, l_reporting_context);
     l_where_reporting_context_apc := fnd_mo_reporting_api.get_predicate('APC', NULL, l_reporting_context);

   else
 -- Set LE ID on tables with LE stamped.
 -- XLE view condition set on before wh procedure.

     l_where_reporting_context_inv := '';
     l_where_reporting_context_aip := '';
     l_where_reporting_context_apc := '';
     l_where_reporting_context_ind := '';
     l_where_reporting_context_atc := '';
     l_where_reporting_context_atr := '';
     l_where_reporting_context_pvs := '';
     l_where_reporting_context_asp := '';

   end if;

-- legal entity id is set at running time.
-- also removed:and  ou.organization_id = oi.org_information2

     fa_rx_util_pkg.where_clause :=
 		   '  ap_inv.invoice_id = ind.invoice_id
 		 and  ind.line_type_lookup_code= ''AWT''
     		 and  ap_inv.vendor_id = pov.vendor_id
		 and  ap_inv.vendor_site_id = pvs.vendor_site_id
		 and  ind.WITHHOLDING_tax_code_id = atc.tax_id
                 /* Commented out NOCOPY the following condition to consider manual wh.
		 and  ind.awt_tax_rate_id = atr.tax_rate_id */
		 and  atc.name = atr.tax_name
                 and  ind.accounting_date >= nvl(atr.start_date,ind.accounting_date)
                 and  ind.accounting_date <= nvl(atr.end_date,ind.accounting_date)
		 and  cc.code_combination_id = ind.dist_code_combination_id
		 and  pv1.vendor_id  = atc.awt_vendor_id
		 and  hrl1.location_id = atc.global_attribute1
		 and  aip.invoice_payment_id(+) = ind.awt_invoice_payment_id
		 and  apc.check_id(+) = aip.check_id
                 and  ap_inv.legal_entity_id = xle.legal_entity_id
		 and  oi.organization_id = ap_inv.org_id
		 and  ap_sp.org_id = ap_inv.org_id
                 and  oi.org_information_context = ''Operating Unit Information''
                 and  ou.organization_id = oi.org_information2
		 '    || l_where_reporting_context_inv
                      || l_where_reporting_context_ind
                      || l_where_reporting_context_pvs
                      || l_where_reporting_context_atc
                      || l_where_reporting_context_atr
                      || l_where_reporting_context_asp
                      || l_where_reporting_context_aip
                      || l_where_reporting_context_apc ;

 END CONSTRUCT_WHERE;

 /**************************************************************************
 *                                                                         *
 * Name       :  build_gbl_lookup_table	                                   *
 * Purpose    : This procedure builds p_gbl_lookup_table for use by        *
 *		function get_lookup_meaning		 	           *
 *									   *
 **************************************************************************/
 PROCEDURE build_gbl_lookup_table is
    cursor  lookup_meaning_cursor is
    Select  'PO', lookup_type, lookup_code, displayed_field
    from    po_lookup_codes
    where   lookup_type in ('ORGANIZATION TYPE')
    and sysdate < nvl(inactive_date, sysdate+1)
    union all
    select 'FND',lookup_type, lookup_code, meaning
    from fnd_lookups
    where    lookup_type in ('JAKR_AP_AWT_BIZ_INC_SUB_CAT',
    			     'JAKR_AP_AWT_TAX_TYPE',
    			     'JAKR_AP_AWT_INC_CAT_DOMESTIC',
    			     'JAKR_AP_AWT_INC_CAT_FOREIGN')
    and enabled_flag = 'Y';
    l_index number := 0;
 Begin
     fa_rx_util_pkg.debug('build_gbl_lookup_table()+');

     open lookup_meaning_cursor;
     loop
        fetch lookup_meaning_cursor into lookup_meaning_rec;
        exit when lookup_meaning_cursor%notfound;
        l_index := l_index + 1;
        p_gbl_lookup_table(l_index) := lookup_meaning_rec;
      end loop;

      if lookup_meaning_cursor%isopen then
           close lookup_meaning_cursor;
      end if;
     fa_rx_util_pkg.debug('build_gbl_lookup_table()-');
 Exception
    when others then
       fa_rx_util_pkg.debug(
                 'Exception in build_gbl_lookup_table:'||
                  SQLCODE||';'||SQLERRM);
       if lookup_meaning_cursor%isopen then
           close lookup_meaning_cursor;
       end if;
 End build_gbl_lookup_table ;


 PROCEDURE append_errbuf(p_msg in varchar2) is
 BEGIN
   if  nvl(length(L_ERRBUF),0) = 0 THEN
         L_ERRBUF := p_msg;
   elsif nvl(length(L_ERRBUF),0) < 2000 - nvl(length(p_msg),0) then
         L_ERRBUF := L_ERRBUF ||';'||p_msg;
   end if;
   L_ERRBUF := L_ERRBUF || fnd_global.newline;
 END append_errbuf;

 PROCEDURE set_retcode(p_retcode in number) is
 BEGIN
    If p_retcode = 2 then
           L_RETCODE := p_retcode;
    elsif p_retcode = 1 then
           IF L_RETCODE = 2 then
               NULL;
           ELSE
               L_RETCODE := p_retcode;
           END IF;
    end if;
 END set_retcode;

END jgrx_wt;

/
