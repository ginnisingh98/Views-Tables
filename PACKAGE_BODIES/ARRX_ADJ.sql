--------------------------------------------------------
--  DDL for Package Body ARRX_ADJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARRX_ADJ" as
/* $Header: ARRXADJB.pls 120.24.12010000.3 2009/08/12 09:44:33 kknekkal ship $ */

-- make following vars global :
CO_SEG_WHERE                   varchar2(500);
ACCOUNTING_METHOD              varchar2(30);

-- define the following function to get total amount from ar_Distributions
-- table and do away with breakdown listing per account which is not
-- necessary in a register type report

-- bug 4214787 : remove string that sets dist.org_id because this is not always
-- the correct condition when reporting level is NOT Operating Unit
function dist_details (adj_id in NUMBER, coa_id in NUMBER, rep_id in NUMBER, ret_type in VARCHAR2)
--Bug fix 5595083, replacing the reference of var.p_coa_id to var.chart_of_accounts_id
RETURN NUMBER IS

l_stmt VARCHAR2(2000);
ret_amt NUMBER;

begin

   l_stmt :=
'select decode( ''' || ret_type || ''',
               ''ENTERED'', sum(round(nvl(dist.amount_cr,(dist.amount_dr)*-1),2)),
               ''ACCTD'', sum(nvl(dist.acctd_amount_cr,(dist.acctd_amount_dr)*-1)))
   from ar_distributions_all dist, gl_code_combinations glc
  where  dist.source_id = ' ||  adj_id ||
  ' and  dist.source_Table = ''ADJ''
    and  dist.source_Type in ( ''ADJ'',
                               ''TAX'',
                               ''FINCHRG'',
                               ''ADJ_NON_REC_TAX'',
                               ''DEFERRED_TAX'',
                               ''FINCHRG_NON_REC_TAX'')
    and glc.code_combination_id = dist.code_combination_id
    and glc.chart_of_accounts_id = ' || coa_id ||
    ' ' || co_seg_where;

   execute immediate l_stmt into ret_amt;

   return ret_amt;
end;

-- define a function that determines all ccid in ar_distributions for this
-- adjustment have the same balancing segment

-- bug 4214787 : remove string that sets dist.org_id because this is not always
-- the correct condition when reporting level is NOT Operating Unit
function dist_ccid (adj_id in number, coa_id in NUMBER, rep_id in NUMBER) RETURN
NUMBER IS

TYPE         cur_typ IS REF CURSOR;
l_stmt       VARCHAR2(2000);
ret_amt      NUMBER;
c_dist       cur_typ;
bal_seg1     varchar2(30);
bal_seg2     varchar2(30);
use_ccid     number;
begin

l_stmt := 'select FA_RX_FLEX_PKG.GET_VALUE(101,''GL#'', ' || coa_id || ', ''GL_BALANCING'',dist.CODE_COMBINATION_ID), ' ||
          ' dist.code_Combination_id from ar_distributions_all dist, gl_code_combinations glc where  dist.source_id = ' ||  adj_id ||
          ' and  dist.source_Table = ''ADJ'' and  dist.source_Type = ''REC'' ' ||' and glc.code_combination_id = dist.code_combination_id and glc.chart_of_accounts_id = ' ||
          coa_id || ' ' || co_seg_where;

open c_dist for l_stmt;
bal_seg1 := '-1';
bal_seg2 := '-1';

loop

     FETCH c_dist into bal_seg1, use_ccid;
     EXIT WHEN c_dist%NOTFOUND;

     if bal_seg1 <> bal_seg2 AND bal_seg2 <> -1 then
        -- multiple bal segs for this adjustment
        return -666;
     else
        bal_seg2 := bal_seg1;
     end if;

end loop;

close c_dist;
return use_ccid;

exception
when no_data_found then

   l_stmt := 'select adj.code_combination_id from ar_adjustments_all adj, gl_code_combinations glc ' ||
             ' where adj.adjustment_id = ' || adj_id ||
             ' and glc.code_combination_id = adj.code_combination_id ' ||
             ' and glc.chart_of_accounts_id = ' || coa_id || ' ' || co_seg_where;

   execute immediate l_stmt into use_ccid;
   return use_ccid;
end;
--
-- Main AR Adjustments RX Report function
--
procedure aradj_rep (
   request_id                 in   number,
   p_reporting_level          in   number,
   p_reporting_entity         in   number,
   p_sob_id                   in   number,
   p_coa_id                   in   number,
   p_co_seg_low               in   varchar2,
   p_co_seg_high              in   varchar2,
   p_gl_date_low              in   date,
   p_gl_date_high             in   date,
   p_currency_code_low        in   varchar2,
   p_currency_code_high       in   varchar2,
   p_trx_date_low             in   date,
   p_trx_date_high            in   date,
   p_due_date_low             in   date,
   p_due_date_high            in   date,
   p_invoice_type_low         in   varchar2,
   p_invoice_type_high        in   varchar2,
   p_adj_type_low             in   varchar2,
   p_adj_type_high            in   varchar2,
   p_doc_seq_name             in   varchar2,
   p_doc_seq_low              in   number,
   p_doc_seq_high             in   number,
   retcode                    out NOCOPY  number,
   errbuf                     out NOCOPY  varchar2)
is

begin

  -- Asssign parameters to global variable
  -- These values will be used within the before_report trigger

   var.p_reporting_level        := p_reporting_level;
   var.p_reporting_entity_id    := p_reporting_entity;
   var.p_sob_id                 := p_sob_id;
   var.request_id               := request_id;
   var.p_coa_id			:= p_coa_id;
   var.p_gl_date_low            := p_gl_date_low;
   var.p_gl_date_high           := p_gl_date_high;
   var.p_trx_date_low           := p_trx_date_low;
   var.p_trx_date_high          := p_trx_date_high;
   var.p_due_date_low           := p_due_date_low;
   var.p_due_date_high          := p_due_date_high;
   var.p_invoice_type_low       := p_invoice_type_low;
   var.p_invoice_type_high      := p_invoice_type_high;
   var.p_adj_type_low           := p_adj_type_low;
   var.p_adj_type_high          := p_adj_type_high;
   var.p_currency_code_low      := p_currency_code_low;
   var.p_currency_code_high     := p_currency_code_high;
   var.p_co_seg_low             := p_co_seg_low;
   var.p_co_seg_high            := p_co_seg_high;
   var.p_doc_seq_name 		:= p_doc_seq_name;
   var.p_doc_seq_low 		:= p_doc_seq_low;
   var.p_doc_seq_high 		:= p_doc_seq_high;
fa_rx_util_pkg.enable_debug;
  --
  -- Initialize request
   fa_rx_util_pkg.init_request('arrx_adj.aradj_rep',request_id,'AR_ADJUSTMENTS_REP_ITF');


/* Bug 5244313 Setting the SOB based on the Reporting context */
  if p_reporting_level = 1000 then
   var.books_id := p_reporting_entity;
    mo_global.init('AR');
    mo_global.set_policy_context('M',null);

  elsif p_reporting_level = 3000 then

   select set_of_books_id
    into   var.books_id
    from  ar_system_parameters_all
    where org_id = p_reporting_entity;

    mo_global.init('AR');
    mo_global.set_policy_context('S',p_reporting_entity);

  end if;

  --
  -- Assign report triggers for this report.
  -- This report has one section called AR RECEIPT
  -- NOTE:
  --    before_report is assigned 'arrx_adj.adj_before_report;'
  --    bind is assigned 'arrx_rc.bind(:CURSOR_SELECT);'
  --  Each trigger event is assigned with the full procedure name (including package name).
  --  They end with a ';'.
  --  The bind trigger requires one host variable ':CURSOR_SELECT'.
   fa_rx_util_pkg.assign_report('AR ADJUSTMENTS',
                true,
                'arrx_adj.aradj_before_report;',
                'arrx_adj.aradj_bind(:CURSOR_SELECT);',
                'arrx_adj.aradj_after_fetch;',
                null);

  --
  -- Run the report. Make sure to pass as parameter the same
  -- value passed to p_calling_proc in init_request().
   fa_rx_util_pkg.run_report('arrx_adj.aradj_rep', retcode, errbuf);

   fa_rx_util_pkg.debug('arrx_adj.aradj_rep()-');

exception
   when others then
      fa_rx_util_pkg.log(sqlcode);
      fa_rx_util_pkg.log(sqlerrm);
      fa_rx_util_pkg.debug(sqlcode);
      fa_rx_util_pkg.debug(sqlerrm);
      fa_rx_util_pkg.debug('arrx_adj.aradj_rep(EXCEPTION)-');
end aradj_rep;


-- This is the before trigger for the main Adj Report ---

-- bug 4214787 :
-- a) use arpt_sql_func_util to get trx type information
-- b) remove join to RA_CUST_TRX_TYPES and AR_RECEIVABLES_TRX

procedure aradj_before_report
is
	CURRENCY_CODE_WHERE		varchar2(500);
	INVOICE_TYPE_WHERE		varchar2(500);
	DUE_DATE_WHERE			varchar2(500);
	TRX_DATE_WHERE			varchar2(500);
	ADJ_TYPE_WHERE			varchar2(500);
	GL_DATE_WHERE			varchar2(500);
	REC_BALANCING_WHERE		varchar2(500);
	ADJ_ACCT_WHERE			varchar2(800);
	SEQ_NAME_WHERE			varchar2(100);
	SEQ_NUMBER_WHERE		varchar2(100);

	OPER				varchar2(10);
	OP1				varchar2(25);
	OP2				varchar2(25);

	SORTBY_DECODE			varchar2(300); /*bug5968198*/
	D_OR_I_DECODE			varchar2(200);
	ADJ_CLASS_DECODE		varchar2(200);
	POSTABLE_DECODE			varchar2(100);

	BALANCING_ORDER_BY		varchar2(100);

	-- Bug 2099632
	SHOW_BILL_WHERE			varchar2(100);
	SHOW_BILL_FROM			varchar2(100);
	BILL_FLAG			varchar2(1);

        L_CUST_ORG_WHERE               VARCHAR2(500);
        L_PAY_ORG_WHERE                VARCHAR2(500);
        L_ADJ_ORG_WHERE                VARCHAR2(500);
        L_CI_ORG_WHERE                 VARCHAR2(500);
        L_TRX_ORG_WHERE                VARCHAR2(500);
        L_SYSPARAM_ORG_WHERE           VARCHAR2(500);--New variable for bug fix 5595083
        acct_stmt                      VARCHAR2(600);--New variable for bug fix 5595083

        DIST_ENTERED                   VARCHAR2(500);
        DIST_ACCTD                     VARCHAR2(500);
        DIST_CCID_STR                  VARCHAR2(500);

begin

	fa_rx_util_pkg.debug('arrx_adj.adj_before_report()+');

        --
  	-- Get Profile GL_SET_OF_BKS_ID
  	--
   	fa_rx_util_pkg.debug('GL_GET_PROFILE_BKS_ID');

--      bug 5244313
--        var.books_id := arp_global.sysparam.set_of_books_id;

	--
  	-- Get CHART_OF_ACCOUNTS_ID
  	--
  	fa_rx_util_pkg.debug('GL_GET_CHART_OF_ACCOUNTS_ID');

	select CHART_OF_ACCOUNTS_ID,CURRENCY_CODE,NAME
	into var.chart_of_accounts_id,var.functional_currency_code,var.organization_name
	from GL_SETS_OF_BOOKS
	where SET_OF_BOOKS_ID = var.books_id;

        fa_rx_util_pkg.debug('Chart of Accounts ID : '||var.chart_of_accounts_id);
        fa_rx_util_pkg.debug('Functional Currency  : '||var.functional_currency_code);
        fa_rx_util_pkg.debug('Organization Name    : '||var.organization_name);

        -- Get Accounting Method --5244313
        --bug fix 5595083
        --Changing the logic of getting the accounting_method. The accounting_method should belong to the ledger for which the report is being generated.
        --SELECT  distinct ACCOUNTING_METHOD
        --INTO  ACCOUNTING_METHOD
        --FROM  ar_system_parameters;

        XLA_MO_REPORTING_API.Initialize(var.p_reporting_level, var.p_reporting_entity_id, 'AUTO');

        L_CUST_ORG_WHERE   := XLA_MO_REPORTING_API.Get_Predicate('CUST',NULL);
        L_PAY_ORG_WHERE    := XLA_MO_REPORTING_API.Get_Predicate('PAY',NULL);
        L_ADJ_ORG_WHERE    := XLA_MO_REPORTING_API.Get_Predicate('ADJ',NULL);
        L_TRX_ORG_WHERE    := XLA_MO_REPORTING_API.Get_Predicate('TRX',NULL);

        --Bug fix 5595083 starts
        L_SYSPARAM_ORG_WHERE :=  XLA_MO_REPORTING_API.Get_Predicate('SYSPARAM',NULL);
        acct_stmt := 'select distinct ACCOUNTING_METHOD FROM  ar_system_parameters_all SYSPARAM  where ACCOUNTING_METHOD is not null ' || L_SYSPARAM_ORG_WHERE ;
        IF var.p_reporting_level = 3000 then
          IF var.p_reporting_entity_id IS NOT NULL THEN
            execute immediate acct_stmt into  ACCOUNTING_METHOD using  var.p_reporting_entity_id,  var.p_reporting_entity_id;
          END IF;
        ELSE
          execute immediate acct_stmt into  ACCOUNTING_METHOD;
       END IF;
        --Bug fix 5595083 ends
	--
	-- Figure out NOCOPY the where clause for the parameters
	--
	fa_rx_util_pkg.debug('AR_GET_PARAMETERS');

--
--CURRENCY_CODE where clause
--

	IF var.p_currency_code_low IS NULL AND var.p_currency_code_high IS NULL THEN
	      CURRENCY_CODE_WHERE := NULL;
	ELSIF var.p_currency_code_low IS NULL THEN
	      CURRENCY_CODE_WHERE := ' AND TRX.INVOICE_CURRENCY_CODE <= :p_currency_code_high';
        ELSIF var.p_currency_code_high IS NULL THEN
              CURRENCY_CODE_WHERE := ' AND TRX.INVOICE_CURRENCY_CODE >= :p_currency_code_low';
        ELSE
	      CURRENCY_CODE_WHERE := ' AND TRX.INVOICE_CURRENCY_CODE BETWEEN :p_currency_code_low AND :p_currency_code_high';
   	END IF;

--
-- INVOICE_TYPE where clause
--

	IF var.p_invoice_type_low IS NULL AND var.p_invoice_type_high IS NULL THEN
	      INVOICE_TYPE_WHERE := NULL;
	ELSIF var.p_invoice_type_low IS NULL THEN
	      INVOICE_TYPE_WHERE := ' AND arpt_sql_func_util.get_trx_type_details(trx.cust_trx_type_id,''NAME'',trx.org_id) <= :p_invoice_type_high';
	ELSIF var.p_invoice_type_high IS NULL THEN
	      INVOICE_TYPE_WHERE := ' AND arpt_sql_func_util.get_trx_type_details(trx.cust_trx_type_id,''NAME'', trx.org_id) >= :p_invoice_type_low';
	ELSE
	      INVOICE_TYPE_WHERE := ' AND  arpt_sql_func_util.get_trx_type_details(trx.cust_trx_type_id,''NAME'',trx.org_id) ' ||
                                    ' BETWEEN :p_invoice_type_low AND :p_invoice_type_high';
	END IF;

--
-- TRX date where clause--
--
	IF var.p_trx_date_low IS NULL AND var.p_trx_date_high IS NULL THEN
      	      TRX_DATE_WHERE := NULL;
   	ELSIF var.p_trx_date_low IS NULL THEN
      	      TRX_DATE_WHERE := ' AND TRX.TRX_DATE <= :p_trx_date_high';
   	ELSIF var.p_trx_date_high IS NULL THEN
      	      TRX_DATE_WHERE := ' AND TRX.TRX_DATE >= :p_trx_date_low';
   	ELSE
      	      TRX_DATE_WHERE := ' AND TRX.TRX_DATE BETWEEN :p_trx_date_low AND :p_trx_date_high';
        END IF;

--
-- DUE_DATE where clause
--

	IF var.p_due_date_low IS NULL AND var.p_due_date_high IS NULL THEN
      	      DUE_DATE_WHERE := NULL;
   	ELSIF var.p_due_date_low IS NULL THEN
      	      DUE_DATE_WHERE := ' AND PAY.DUE_DATE <= :p_due_date_high';
   	ELSIF var.p_due_date_high IS NULL THEN
      	      DUE_DATE_WHERE := ' AND PAY.DUE_DATE >= :p_due_date_low';
   	ELSE
      	      DUE_DATE_WHERE := ' AND PAY.DUE_DATE BETWEEN :p_due_date_low AND :p_due_date_high';
        END IF;

        IF var.p_co_seg_low IS NULL AND var.p_co_seg_high IS NULL THEN
                OPER := NULL;
        ELSIF var.p_co_seg_low IS NULL THEN
                OPER := '<=';
                OP1 := var.p_co_seg_high;
                OP2 := NULL;
        ELSIF var.p_co_seg_high IS NULL THEN
                OPER := '>=';
                OP1 := var.p_co_seg_low;
                OP2 := NULL;
        ELSE
                OPER := 'BETWEEN';
                OP1 := var.p_co_seg_low;
                OP2 := var.p_co_seg_high;
        END IF;

        IF OPER IS NULL THEN
                CO_SEG_WHERE := NULL;
        ELSE
      		CO_SEG_WHERE := ' AND '||
         	FA_RX_FLEX_PKG.FLEX_SQL(
                             p_application_id => 101,
                             p_id_flex_code => 'GL#',
                             p_id_flex_num => var.chart_of_accounts_id,
                             p_table_alias => 'glc',
                             p_mode => 'WHERE',
                             p_qualifier => 'GL_BALANCING',
                             p_function => OPER,
                             p_operand1 => OP1,
                             p_operand2 => OP2);
        END IF;

--
-- ADJ_TYPE_WHERE clause
--

	IF var.p_adj_type_low IS NULL AND var.p_adj_type_high IS NULL THEN
	      ADJ_TYPE_WHERE := NULL;
	ELSIF var.p_adj_type_low IS NULL THEN
	      ADJ_TYPE_WHERE := ' AND ADJ.TYPE <= :p_adj_type_high';
	ELSIF var.p_adj_type_high IS NULL THEN
	      ADJ_TYPE_WHERE := ' AND ADJ.TYPE >= :p_adj_type_low';
	ELSE
	      ADJ_TYPE_WHERE := ' AND ADJ.TYPE BETWEEN :p_adj_type_low AND :p_adj_type_high';
	END IF;

--
-- GL_DATE_WHERE clause
--

	IF var.p_gl_date_low IS NULL AND var.p_gl_date_high IS NULL THEN
      	      GL_DATE_WHERE := NULL;
   	ELSIF var.p_gl_date_low IS NULL THEN
      	      GL_DATE_WHERE := ' AND ADJ.GL_DATE <= :p_gl_date_high';
   	ELSIF var.p_gl_date_high IS NULL THEN
      	      GL_DATE_WHERE := ' AND ADJ.GL_DATE >= :p_gl_date_low';
   	ELSE
      	      GL_DATE_WHERE := ' AND ADJ.GL_DATE BETWEEN :p_gl_date_low AND :p_gl_date_high';
        END IF;

--
-- Doc Name Where
--

	IF var.p_doc_seq_name is not null then
        	SEQ_NAME_WHERE := ' AND adj.doc_sequence_id = :p_doc_seq_name ';
	ELSE
		SEQ_NAME_WHERE := NULL;
        END IF;

--
-- Doc Number Where
--

	IF var.p_doc_seq_low is not NULL and var.p_doc_seq_high is not null then
        	SEQ_NUMBER_WHERE := ' AND adj.doc_sequence_value BETWEEN :p_doc_seq_low AND :p_doc_seq_high ';
        ELSIF var.p_doc_seq_low is not null then
                SEQ_NUMBER_WHERE := ' AND adj.doc_sequence_value >= :p_doc_seq_low ';
        ELSIF var.p_doc_seq_high is not null then
                SEQ_NUMBER_WHERE := ' AND adj.doc_sequence_value <= :p_doc_seq_high ';
        ELSE
		SEQ_NUMBER_WHERE := NULL;
        END IF;

-- Bug 2099632
-- SHOW_BILL_WHERE

-- Bug 2209444 Changed fnd_profile to ar_setup procedure
	ar_setup.get( name => 'AR_SHOW_BILLING_NUMBER',
			 val  => BILL_FLAG );
	IF (BILL_FLAG = 'Y') THEN
	  SHOW_BILL_WHERE := 'AND pay.cons_inv_id = ci.cons_inv_id(+)';
	  SHOW_BILL_FROM  := ', ar_cons_inv_all ci ';
          L_CI_ORG_WHERE  := XLA_MO_REPORTING_API.Get_Predicate('CI',NULL);
	ELSE
	  SHOW_BILL_WHERE := NULL;
	  SHOW_BILL_FROM  := NULL;
          L_CI_ORG_WHERE  := NULL;
	END IF;

--
-- Define DECODE statements
--
/*bug5968198*/
	SORTBY_DECODE    := 'decode(upper(:p_order_by),''CUSTOMER'', decode(UPPER(party.party_type), ''ORGANIZATION'', org.organization_name,
                            ''PERSON'', per.person_name, party.party_name),''INVOICE NUMBER'', trx.trx_number,trx.trx_number)';

	D_OR_I_DECODE  := 'decode(adj.adjustment_type,''C'',decode( arpt_sql_func_util.get_trx_type_details(trx.cust_trx_type_id,''TYPE'',trx.org_id), ''GUAR'', ''I'', ''D''),'''')';

	POSTABLE_DECODE  := 'decode(adj.postable, ''Y'', :c_Yes, :c_No)';

	ADJ_CLASS_DECODE := 'decode(adj.adjustment_type, ''C'', look.meaning, ' ||
                            'decode(arpt_sql_func_util.get_rec_trx_type(adj.receivables_trx_id), ''FINCHRG'',''Finance'',''Adjustment''))';
--
--  Assign SELECT list
--

	fa_rx_util_pkg.debug('ARTX_ASSIGN_SELECT_LIST');

	-->>SELECT_START<<--

	fa_rx_util_pkg.assign_column('10',NULL					,'ORGANIZATION_NAME'			,'arrx_adj.var.organization_name' 		,'VARCHAR2',50);
	fa_rx_util_pkg.assign_column('20',NULL					,'FUNCTIONAL_CURRENCY_CODE'		,'arrx_adj.var.functional_currency_code'	,'VARCHAR2',15);
	fa_rx_util_pkg.assign_column('30',POSTABLE_DECODE			,'POSTABLE'				,'arrx_adj.var.postable'			,'VARCHAR2',15);
	fa_rx_util_pkg.assign_column('40','trx.invoice_currency_code'		,'ADJ_CURRENCY_CODE'			,'arrx_adj.var.adj_currency_code'		,'VARCHAR2',15);
	fa_rx_util_pkg.assign_column('50','1'					,'CONS'					,'arrx_adj.var.cons'				,'VARCHAR2',15);
	/*fa_rx_util_pkg.assign_column('60',SORTBY_DECODE		        	,'SORTBY'				,'arrx_adj.var.sortby'				,'VARCHAR2',30);*/
	fa_rx_util_pkg.assign_column('60',' arpt_sql_func_util.get_trx_type_details(trx.cust_trx_type_id,''NAME'',trx.org_id)'				,'ADJ_NAME'				,'arrx_adj.var.adj_name'		        ,'VARCHAR2',30);
	fa_rx_util_pkg.assign_column('70',D_OR_I_DECODE				,'D_OR_I'				,'arrx_adj.var.d_or_i'			        ,'VARCHAR2',6);
	IF (BILL_FLAG = 'Y') THEN
	  fa_rx_util_pkg.assign_column('80','decode(ci.cons_billing_number, null, trx.trx_number, SUBSTRB(trx.trx_number||''/''||rtrim(ci.cons_billing_number),1,36))'			,'TRX_NUMBER'				,'arrx_adj.var.trx_number'			,'VARCHAR2',36);--bug4612433
	ELSE
	  fa_rx_util_pkg.assign_column('80','trx.trx_number'			,'TRX_NUMBER'				,'arrx_adj.var.trx_number'			,'VARCHAR2',36);--bug4612433
	END IF;
	fa_rx_util_pkg.assign_column('90','pay.due_date'			,'DUE_DATE'				,'arrx_adj.var.due_date'			,'DATE');
	fa_rx_util_pkg.assign_column('100','adj.gl_date'			,'GL_DATE'				,'arrx_adj.var.gl_date'				,'DATE');
--      Bug 1371540 Aug 2000: changed reference from Adjustment_id to Adjustment_number: jskhan
	fa_rx_util_pkg.assign_column('110','adj.adjustment_number'	        ,'ADJ_NUMBER'				,'arrx_adj.var.adj_number'			,'VARCHAR2',20);
	fa_rx_util_pkg.assign_column('120',ADJ_CLASS_DECODE			,'ADJ_CLASS'				,'arrx_adj.var.adj_class'			,'VARCHAR2',30);
	fa_rx_util_pkg.assign_column('130','adj.type'				,'ADJ_TYPE_CODE'			,'arrx_adj.var.adj_type_code'			,'VARCHAR2',30);
	fa_rx_util_pkg.assign_column('140','ladjtype.meaning'			,'ADJ_TYPE_MEANING'			,'arrx_adj.var.adj_type_meaning'		,'VARCHAR2',30);
/*bug5968198 changed to retrieve customer name based on party_type.*/
	fa_rx_util_pkg.assign_column('150','substrb(decode(UPPER(party.party_type), ''ORGANIZATION'', org.organization_name, ''PERSON'',
	                             per.person_name, party.party_name) ,1,50)'	,'CUSTOMER_NAME'			,'arrx_adj.var.customer_name'			,'VARCHAR2',50);
	fa_rx_util_pkg.assign_column('160','cust.account_number'		,'CUSTOMER_NUMBER'			,'arrx_adj.var.customer_number'			,'VARCHAR2',30);
	fa_rx_util_pkg.assign_column('170','cust.cust_account_id'			,'CUSTOMER_ID'				,'arrx_adj.var.customer_id'			,'NUMBER');
	fa_rx_util_pkg.assign_column('180','trx.trx_date'			,'TRX_DATE'				,'arrx_adj.var.trx_date'			,'DATE');

        if accounting_method = 'ACCRUAL' then

           DIST_ENTERED := 'arrx_adj.dist_details(adj.adjustment_id, ' || var.chart_of_accounts_id ||
                           ',' || var.p_reporting_entity_id || ', ''ENTERED'')';
           DIST_ACCTD   := 'arrx_adj.dist_details(adj.adjustment_id, ' || var.chart_of_accounts_id ||
                           ',' || var.p_reporting_entity_id || ', ''ACCTD'')';
           DIST_CCID_STR := 'arrx_adj.dist_ccid(adj.adjustment_id, ' || var.chart_of_accounts_id ||
                           ',' || var.p_reporting_entity_id || ')';
           fa_rx_util_pkg.assign_column('190',
                                DIST_ENTERED,
                                'ADJ_AMOUNT',
                                'arrx_adj.var.adj_amount',
                                'NUMBER');
           fa_rx_util_pkg.assign_column('200',
                                DIST_ACCTD,
                                'ACCTD_ADJ_AMOUNT',
                                'arrx_adj.var.acctd_adj_amount',
                                'NUMBER');
           fa_rx_util_pkg.assign_column('210',
                                DIST_CCID_STR,
                                'ACCOUNT_CODE_COMBINATION_ID',
                                'arrx_adj.var.account_code_combination_id',
                                'VARCHAR2',240);
        else
           fa_rx_util_pkg.assign_column('190',
                                'round(adj.amount,2)',
                                'ADJ_AMOUNT',
                                'arrx_adj.var.adj_amount',
                                'NUMBER');
           fa_rx_util_pkg.assign_column('200',
                                'adj.acctd_amount',
                                'ACCTD_ADJ_AMOUNT',
                                'arrx_adj.var.acctd_adj_amount',
                                'NUMBER');
           fa_rx_util_pkg.assign_column('210',
                                'glc.code_combination_id',
                                'ACCOUNT_CODE_COMBINATION_ID',
                                'arrx_adj.var.account_code_combination_id',
                                'VARCHAR2',240);
        end if;


   	fa_rx_util_pkg.assign_column('230',null                         	,'DEBIT_ACCOUNT_DESC'                   ,'arrx_adj.var.debit_account_desc'   		,'VARCHAR2',240);
   	fa_rx_util_pkg.assign_column('240',null                         	,'DEBIT_BALANCING'                      ,'arrx_adj.var.debit_balancing'   		,'VARCHAR2',240);
   	fa_rx_util_pkg.assign_column('250',null                         	,'DEBIT_BALANCING_DESC'                 ,'arrx_adj.var.debit_balancing_desc'		,'VARCHAR2',240);
   	fa_rx_util_pkg.assign_column('260',null                         	,'DEBIT_NATACCT'                        ,'arrx_adj.var.debit_natacct'		      	,'VARCHAR2',240);
   	fa_rx_util_pkg.assign_column('270',null                         	,'DEBIT_NATACCT_DESC'                   ,'arrx_adj.var.debit_natacct_desc'		,'VARCHAR2',240);
	fa_rx_util_pkg.assign_column('280','nvl(adj.doc_sequence_value,'''')'   ,'DOC_SEQUENCE_VALUE'                   ,'arrx_adj.var.doc_seq_value'			,'NUMBER');
	fa_rx_util_pkg.assign_column('290',null					,'DOC_SEQUENCE_NAME'			,'arrx_adj.var.doc_seq_name'			,'VARCHAR2',30);

--
-- Assign  FROM clause
--

fa_rx_util_pkg.debug('Assign FROM Clause using ALL tables');
-- Bug 1719611 Tim Dexter - added ar_distributions
fa_rx_util_pkg.from_clause := 'hz_cust_accounts_all    	cust,
                               hz_parties		party,
		               ar_lookups           	ladjtype,
        		       ar_payment_schedules_all	pay,
                               ra_customer_trx_all      trx,
        		       ar_adjustments_all       adj,
		       	       ar_lookups		look,
			       hz_organization_profiles org, /*bug5968198*/
			       hz_person_profiles       per' /*bug5968198*/
			       || SHOW_BILL_FROM;

/*
if accounting_method <> 'ACCRUAL' then
   fa_rx_util_pkg.from_clause := fa_rx_util_pkg.from_clause ||
                               ',gl_code_combinations glc ';
end if;
*/
/* Start FP Bug 5724794 - Bug 4619624 introduce join with GL_code_combination for segment based search */
if accounting_method = 'CASH'  THEN
   fa_rx_util_pkg.from_clause := fa_rx_util_pkg.from_clause ||
                               ',gl_code_combinations glc ';
elsif  accounting_method = 'ACCRUAL' AND CO_SEG_WHERE IS NOT NULL THEN
   fa_rx_util_pkg.from_clause := fa_rx_util_pkg.from_clause ||
                               ',gl_code_combinations glc , ar_distributions dist_all';

end if;
/* End FP Bug 5724794 SPDIXIT */

--
-- Assign WHERE clause
--
-- Bug 1385105 added 'and adj.receivables_trx_id <> -15' to exclude these adjustments

fa_rx_util_pkg.debug('AR_ASSIGN_WHERE_CLAUSE');
fa_rx_util_pkg.where_clause := 'trx.complete_flag = ''Y''
				and cust.cust_account_id = trx.bill_to_customer_id
			        and cust.party_id = party.party_id
				and trx.set_of_books_id = :set_of_books_id
				and trx.customer_trx_id =   pay.customer_trx_id
				and pay.payment_schedule_id = adj.payment_schedule_id
				and nvl(adj.status, ''A'') = ''A''
				and arpt_sql_func_util.get_trx_type_details(trx.cust_trx_type_id,''TYPE'',trx.org_id)
                                    in (''INV'',''DEP'',''GUAR'',''CM'',''DM'',''CB'')
				and look.lookup_type = ''INV/CM''
				and look.lookup_code = arpt_sql_func_util.get_trx_type_details(trx.cust_trx_type_id,''TYPE'',trx.org_id)
				and adj.adjustment_id > 0
				and adj.receivables_trx_id is not null
                                and adj.receivables_trx_id <> -15
				and adj.type = ladjtype.lookup_code
				and ladjtype.lookup_type = ''ADJUSTMENT_TYPE''
				and party.party_id = org.party_id(+) /*bug5968198*/
				and party.party_id = per.party_id(+) /*bug5968198*/
				and (trx.trx_date between NVL(org.effective_start_date, trx.trx_date)
				    and NVL(org.effective_end_date, trx.trx_date)
				  OR (trx.trx_date < (select min(org1.effective_start_date) from
				     hz_organization_profiles org1 where org1.party_id = party.party_id)
				    AND (trunc(trx.creation_date) between NVL(org.effective_start_date,
				     trunc(trx.creation_date)) and NVL(org.effective_end_date, trunc(trx.creation_date))
				      OR (trunc(trx.creation_date) < (select min(org1.effective_start_date)
				         from hz_organization_profiles org1 where org1.party_id = party.party_id)
				        AND org.effective_end_date is NULL))))/*bug5968198*/ /*bug6674534*//*Bug7206486*/
				and (trx.trx_date between NVL(per.effective_start_date, trx.trx_date)
				    and NVL(per.effective_end_date, trx.trx_date)
				  OR (trx.trx_date < (select min(per1.effective_start_date) from
				     hz_person_profiles per1 where per1.party_id = party.party_id)
				    AND (trunc(trx.creation_date) between NVL(per.effective_start_date,
				     trunc(trx.creation_date)) and NVL(per.effective_end_date, trunc(trx.creation_date))
				      OR (trunc(trx.creation_date) < (select min(per1.effective_start_date)
				         from hz_person_profiles per1 where per1.party_id = party.party_id)
				        AND per.effective_end_date is NULL)))) ' || /*bug5968198*/ /*bug6674534*/
				CURRENCY_CODE_WHERE || ' ' ||
				INVOICE_TYPE_WHERE || ' ' ||
				DUE_DATE_WHERE || ' ' ||
				TRX_DATE_WHERE || ' ' ||
				ADJ_TYPE_WHERE || ' ' ||
				GL_DATE_WHERE || ' ' ||
				ADJ_ACCT_WHERE || ' ' ||
				SEQ_NAME_WHERE || ' ' ||
				SEQ_NUMBER_WHERE || ' ' ||
				SHOW_BILL_WHERE || ' ' ||
                                L_CUST_ORG_WHERE  || ' ' ||
                                L_PAY_ORG_WHERE || ' ' ||
                                L_ADJ_ORG_WHERE || ' ' ||
                                L_TRX_ORG_WHERE;

/* Start FP Bug 5724794 - Changed for bug 4619624 for joining with gl_code_combinations */
if accounting_method = 'CASH' THEN
   fa_rx_util_pkg.where_clause := fa_rx_util_pkg.where_clause ||
                   ' and adj.code_combination_id = glc.code_combination_id
                   and glc.chart_of_accounts_id = :p_coa_id ' ||
                   CO_SEG_WHERE ;
elsif  accounting_method = 'ACCRUAL' AND CO_SEG_WHERE IS NOT NULL THEN
   fa_rx_util_pkg.where_clause :=  fa_rx_util_pkg.where_clause ||
                               'and glc.code_combination_id = dist_all.code_combination_id
                                and glc.chart_of_accounts_id = :p_coa_id
                                and dist_all.source_id = adj.adjustment_id
                                and dist_all.source_table = ''ADJ''
                                and dist_all.source_type in ( ''REC'') ' ||
                                ' ' || CO_SEG_WHERE ;

end if;

/*
if accounting_method <> 'ACCRUAL' then
   fa_rx_util_pkg.where_clause := fa_rx_util_pkg.where_clause ||
                   ' and adj.code_combination_id = glc.code_combination_id
                   and glc.chart_of_accounts_id = :p_coa_id ' ||
                   CO_SEG_WHERE ;
end if;
*/  /* End FP Bug 5724794 SPDIXIT*/

-- Assign ORDER BY clause
--

fa_rx_util_pkg.debug('AR_ASSIGN_ORDER_BY_CLAUSE');

fa_rx_util_pkg.order_by_clause := ' arpt_sql_func_util.get_trx_type_details(trx.cust_trx_type_id,''POST'',trx.org_id) ,
                 arpt_sql_func_util.get_trx_type_details(trx.cust_trx_type_id,''NAME'',trx.org_id),
	  	 trx.trx_number,
                 pay.due_date,
                 adj.adjustment_number';
--Bug 1371540 jskhan changing adjustment_id for adjustment_number
--               adj.adjustment_id';


fa_rx_util_pkg.log('from clause ' || fa_rx_util_pkg.from_clause );
fa_rx_util_pkg.log('Where clause ' || fa_rx_util_pkg.where_clause );

fa_rx_util_pkg.debug('arrx_adj.adj_before_report()-');

end aradj_before_report;



--
-- Bind trigger for main Adjustment Register Report
--

procedure aradj_bind (c in integer)
is

	l_Yes		VARCHAR2(80);
	l_No		VARCHAR2(80);

begin
	fa_rx_util_pkg.debug('AR_GET_BIND');
--
-- Binding vars that appear in SELECT statement depending on input params
--

        -- Bug 4214787 : only bind p_reporting_entity_id when reporting level is Operating Unit
        IF var.p_reporting_level = 3000 then
           IF var.p_reporting_entity_id IS NOT NULL THEN
                dbms_sql.bind_variable(c, 'p_reporting_entity_id', var.p_reporting_entity_id);
           END IF;
        END IF;

        IF var.p_currency_code_low IS NOT NULL THEN
                dbms_sql.bind_variable(c, 'p_currency_code_low', var.p_currency_code_low);
        END IF;

        IF var.p_currency_code_high IS NOT NULL THEN
                dbms_sql.bind_variable(c, 'p_currency_code_high', var.p_currency_code_high);
        END IF;

        IF var.p_invoice_type_low IS NOT NULL THEN
                dbms_sql.bind_variable(c, 'p_invoice_type_low', var.p_invoice_type_low);
        END IF;

        IF var.p_invoice_type_high IS NOT NULL THEN
                dbms_sql.bind_variable(c, 'p_invoice_type_high', var.p_invoice_type_high);
        END IF;


        IF var.p_trx_date_low IS NOT NULL THEN
                dbms_sql.bind_variable(c, 'p_trx_date_low', var.p_trx_date_low);
        END IF;

        IF var.p_trx_date_high IS NOT NULL THEN
                dbms_sql.bind_variable(c, 'p_trx_date_high', var.p_trx_date_high);
        END IF;


        IF var.p_due_date_low IS NOT NULL THEN
                dbms_sql.bind_variable(c, 'p_due_date_low', var.p_due_date_low);
        END IF;

        IF var.p_due_date_high IS NOT NULL THEN
                dbms_sql.bind_variable(c, 'p_due_date_high', var.p_due_date_high);
        END IF;



	IF var.p_adj_type_low IS NOT NULL THEN
                dbms_sql.bind_variable(c, 'p_adj_type_low', var.p_adj_type_low);
        END IF;

        IF var.p_adj_type_high IS NOT NULL THEN
                dbms_sql.bind_variable(c, 'p_adj_type_high', var.p_adj_type_high);
        END IF;

	IF var.p_gl_date_low IS NOT NULL THEN
		dbms_sql.bind_variable(c, 'p_gl_date_low', var.p_gl_date_low);
   	END IF;

	IF var.p_gl_date_high IS NOT NULL THEN
		dbms_sql.bind_variable(c, 'p_gl_date_high', var.p_gl_date_high);
   	END IF;

	IF var.p_doc_seq_name IS NOT NULL THEN
		dbms_sql.bind_variable(c, 'p_doc_seq_name',var.p_doc_seq_name);
    	END IF;

    	IF var.p_doc_seq_low IS NOT NULL THEN
		dbms_sql.bind_variable(c, 'p_doc_seq_low',var.p_doc_seq_low);
    	END IF;

	IF var.p_doc_seq_high IS NOT NULL THEN
		dbms_sql.bind_variable(c, 'p_doc_seq_high',var.p_doc_seq_high);
    	END IF;

	select meaning into l_Yes from AR_LOOKUPS
	where lookup_type = 'YES/NO' and lookup_code = 'Y';

	select meaning into l_No from AR_LOOKUPS
	where lookup_type = 'YES/NO' and lookup_code = 'N';

	dbms_sql.bind_variable(c, 'c_Yes', l_Yes);
	dbms_sql.bind_variable(c, 'c_No', l_No);
/* Start FP Bug 5724794 */
        if accounting_method = 'CASH' OR CO_SEG_WHERE IS NOT NULL  then
   --   if accounting_method <> 'ACCRUAL' then /* End FP Bug 5724794 SPDIXIT */
	   dbms_sql.bind_variable(c,'p_coa_id',var.chart_of_accounts_id);
        end if;

	dbms_sql.bind_variable(c,'set_of_books_id',var.books_id);

end aradj_bind;

--
-- After Fetch trigger
--

procedure aradj_after_fetch
is
begin
/* bug4230953 removed because var.currency_code and var.org_name are null
	var.functional_currency_code 	:= var.currency_code;
	var.organization_name		:= var.org_name;
*/


fa_rx_util_pkg.debug('var.account_code_combination_id = ' || var.account_code_combination_id);
fa_rx_util_pkg.debug('var.adj_number = ' || var.adj_number);
--
-- Assign acount data
--

/*
   var.debit_account :=       fa_rx_flex_pkg.get_value(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'ALL',
                              p_ccid => var.account_code_combination_id);

   var.debit_account_desc :=  substrb(fa_rx_flex_pkg.get_description(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'ALL',
                              p_data => var.debit_account),1,240);
*/

   var.debit_balancing :=     fa_rx_flex_pkg.get_value(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'GL_BALANCING',
                              p_ccid => var.account_code_combination_id);

   var.debit_balancing_desc:= substrb(fa_rx_flex_pkg.get_description(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'GL_BALANCING',
                              p_data => var.debit_balancing),1,240);
/*
   var.debit_natacct :=       fa_rx_flex_pkg.get_value(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'GL_ACCOUNT',
                              p_ccid => var.account_code_combination_id);

   var.debit_natacct_desc :=  substrb(fa_rx_flex_pkg.get_description(
                              p_application_id => 101,
                              p_id_flex_code => 'GL#',
                              p_id_flex_num => var.chart_of_accounts_id,
                              p_qualifier => 'GL_ACCOUNT',
                              p_data => var.debit_natacct),1,240);
*/
--

end aradj_after_fetch;

end ARRX_ADJ;

/
