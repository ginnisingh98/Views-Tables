--------------------------------------------------------
--  DDL for Package Body APRX_PY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."APRX_PY" as
/* $Header: aprxpyb.pls 120.2.12010000.3 2009/09/16 12:36:53 skyadav ship $ */

--
-- Structure to hold values of all parameters
--
type param_t is record (
	payment_date_start	date,
	payment_date_end	date,
	payment_currency_code	varchar2(15),
	payment_bank_account_name	varchar2(80),
	payment_method		varchar2(25),
	payment_type_flag		varchar2(25),
	ledger_id            number,         /* bug8760710 */
	payment_actual_date	varchar2(20)
);
param param_t;

--
-- Main AP Payment RX Report function
--
procedure payment_register_run (
	p_payment_date_start in date,
	p_payment_date_end in date,
	p_payment_currency_code in varchar2,
	p_payment_bank_account_name in varchar2,
	p_payment_method in varchar2,
	p_payment_type_flag in varchar2,
	p_ledger_id     in      number,         /* bug8760710 */
	request_id	in	number,
	retcode	out NOCOPY	number,
	errbuf	out NOCOPY	varchar2
)
is
begin
  fa_rx_util_pkg.debug('aprx_py.payment_register_run()+');

  --
  -- Assign parameters to global variable
  -- These values will be used within the before_report trigger
  param.payment_date_start := Trunc(p_payment_date_start);
  param.payment_date_end := Trunc(p_payment_date_end)+1-1/24/60/60;
  param.payment_currency_code := p_payment_currency_code;
  param.payment_bank_account_name := p_payment_bank_account_name;
  param.payment_method := p_payment_method;
  param.payment_type_flag := p_payment_type_flag;
  param.ledger_id := p_ledger_id;           /* bug8760710 */


  --
  -- Initialize request
  fa_rx_util_pkg.init_request('aprx_py.payment_run', request_id);

  --
  -- Assign report triggers for this report.
  -- This report has one section called PAYMENT
  -- NOTE:
  --    before_report is assigned 'aprx_py.register_before_report;'
  --    bind is assigned 'aprx_py.register_bind(:CURSOR_SELECT);'
  --    There is no trigger assigned for after_fetch or after_report
  --  Each trigger event is assigned with the full procedure name (including package name).
  --  They end with a ';'.
  --  The bind trigger requires one host variable ':CURSOR_SELECT'.
  fa_rx_util_pkg.assign_report('PAYMENT',
		true,
		'aprx_py.register_before_report;',
		'aprx_py.register_bind(:CURSOR_SELECT);',
		null, null);

  --
  -- Run the report. Make sure to pass as parameter the same
  -- value passed to p_calling_proc in init_request().
  fa_rx_util_pkg.run_report('aprx_py.payment_run', retcode, errbuf);

  fa_rx_util_pkg.debug('aprx_py.payment_register_run()-');
end payment_register_run;


--
-- This procedure is a plug-in for the Thailand Payment Actual Report
--
procedure payment_actual_run (
	p_payment_date_start 	in date,
	p_payment_date_end 	in date,
	p_payment_currency_code in varchar2,
	p_payment_bank_account_name in varchar2,
	p_payment_method 	in varchar2,
	p_payment_type_flag 	in varchar2,
	p_ledger_id             in number,         /* bug8760710 */
	request_id		in number,
	retcode	out NOCOPY	number,
	errbuf	out NOCOPY	varchar2
)
is
begin
  fa_rx_util_pkg.debug('aprx_py.payment_actual_run()+');

  --
  -- Initialize the request
  fa_rx_util_pkg.init_request('aprx_py.payment_actual_run', request_id);


  --
  -- Call the main payment report
  payment_register_run(	p_payment_date_start,
		p_payment_date_end,
		p_payment_currency_code,
		p_payment_bank_account_name,
		p_payment_method,
		p_payment_type_flag,
		p_ledger_id,                   /* bug8760710 */
		request_id,
		retcode,
		errbuf);

  --
  -- Assign triggers specific to this report
  -- Make sure that you make your assignment to the correct section ('PAYMENT')
  fa_rx_util_pkg.assign_report('PAYMENT',
		true,
		'aprx_py.actual_before_report;',
		null, null, null);

  --
  -- Run the report.
  -- Make sure to pass the p_calling_proc assigned from within this procedure ('aprx_py.payment_actual_run')
  fa_rx_util_pkg.run_report('aprx_py.payment_actual_run', retcode, errbuf);

  fa_rx_util_pkg.debug('aprx_py.payment_actual_run()-');
end payment_actual_run;


--
-- This is the before report trigger for the main payment_run report.
procedure register_before_report
is
  l_param_where varchar2(2000);
begin
  fa_rx_util_pkg.debug('aprx_py.register_before_report()+');

  --
  -- Figure out NOCOPY the where clause for the parameters
  --
  l_param_where := null;

  if param.payment_date_start = param.payment_date_end then
	l_param_where := l_param_where || '
and	ch.check_date = :b_payment_date_start';
  elsif param.payment_date_start is not null and param.payment_date_end is not null then
	l_param_where := l_param_where || '
and	ch.check_date between :b_payment_date_start and :b_payment_date_end';
  elsif param.payment_date_start is not null then
	l_param_where := l_param_where || '
and	ch.check_date >= :b_payment_date_start';
  elsif param.payment_date_end is not null then
	l_param_where := l_param_where || '
and	ch.check_date <= :b_payment_date_end';
  end if;

  if param.payment_currency_code is not null then
	l_param_where := l_param_where || '
and	ch.currency_code = :b_payment_currency_code';
  end if;

  if param.payment_bank_account_name is not null then
	l_param_where := l_param_where || '
and	ch.bank_account_name = :b_payment_bank_account_name';
  end if;

  if param.payment_method is not null then
	l_param_where := l_param_where || '
and	ch.payment_method_lookup_code = :b_payment_method';
  end if;

  if param.payment_type_flag is not null then
	l_param_where := l_param_where || '
and	ch.payment_type_flag = :b_payment_type_flag';
  end if;

 /* Start of bug8760710 */
 if  param.ledger_id is not null then
      l_param_where:=l_param_where||'
       and sys.set_of_books_id =:b_ledger_id ';
  end if;

  /* End of bug8760710 */
  --
  -- Assign SELECT list
  --
  -- fa_rx_util_pkg.assign_column(#, select, insert, place, type, len);
-->>SELECT_START<<--
	fa_rx_util_pkg.assign_column('ORGANIZATION_NAME', null, 'ORGANIZATION_NAME', 'aprx_py.var.ORGANIZATION_NAME', '');
	fa_rx_util_pkg.assign_column('FUNCTIONAL_CURRENCY_CODE', null, 'FUNCTIONAL_CURRENCY_CODE', 'aprx_py.var.FUNCTIONAL_CURRENCY_CODE', 'VARCHAR2', 15);
	fa_rx_util_pkg.assign_column('PAYMENT_NUMBER', 'CH.CHECK_NUMBER', 'PAYMENT_NUMBER', 'aprx_py.var.PAYMENT_NUMBER', 'NUMBER');
	fa_rx_util_pkg.assign_column('PAYMENT_TYPE', 'CHTYPLKP.DISPLAYED_FIELD', 'PAYMENT_TYPE', 'aprx_py.var.PAYMENT_TYPE', 'VARCHAR2', 20);
	fa_rx_util_pkg.assign_column('PAYMENT_DOC_SEQ_NAME', 'CHDOC.NAME', 'PAYMENT_DOC_SEQ_NAME', 'aprx_py.var.PAYMENT_DOC_SEQ_NAME', 'VARCHAR2', 30);
	fa_rx_util_pkg.assign_column('PAYMENT_DOC_SEQ_VALUE', 'CH.DOC_SEQUENCE_VALUE', 'PAYMENT_DOC_SEQ_VALUE', 'aprx_py.var.PAYMENT_DOC_SEQ_VALUE', 'NUMBER');
	fa_rx_util_pkg.assign_column('PAYMENT_DATE', 'CH.CHECK_DATE', 'PAYMENT_DATE', 'aprx_py.var.PAYMENT_DATE', 'DATE');
	fa_rx_util_pkg.assign_column('PAYMENT_CURRENCY_CODE', 'CH.CURRENCY_CODE', 'PAYMENT_CURRENCY_CODE', 'aprx_py.var.PAYMENT_CURRENCY_CODE', 'VARCHAR2', 15);
	fa_rx_util_pkg.assign_column('ORIG_PAYMENT_AMOUNT', 'CH.AMOUNT', 'ORIG_PAYMENT_AMOUNT', 'aprx_py.var.ORIG_PAYMENT_AMOUNT', 'NUMBER');
	fa_rx_util_pkg.assign_column('ORIG_PAYMENT_BASE_AMOUNT', 'NVL(CH.BASE_AMOUNT, CH.AMOUNT)', 'ORIG_PAYMENT_BASE_AMOUNT', 'aprx_py.var.ORIG_PAYMENT_BASE_AMOUNT', 'NUMBER');
	fa_rx_util_pkg.assign_column('PAYMENT_AMOUNT', 'DECODE(CH.VOID_DATE, NULL, CH.AMOUNT, 0)', 'PAYMENT_AMOUNT', 'aprx_py.var.PAYMENT_AMOUNT', 'NUMBER');
	fa_rx_util_pkg.assign_column('PAYMENT_BASE_AMOUNT', 'DECODE(CH.VOID_DATE, NULL, NVL(CH.BASE_AMOUNT, CH.AMOUNT), 0)', 'PAYMENT_BASE_AMOUNT', 'aprx_py.var.PAYMENT_BASE_AMOUNT', 'NUMBER');
	fa_rx_util_pkg.assign_column('PAYMENT_EXCHANGE_RATE', 'CH.EXCHANGE_RATE', 'PAYMENT_EXCHANGE_RATE', 'aprx_py.var.PAYMENT_EXCHANGE_RATE', 'NUMBER');
	fa_rx_util_pkg.assign_column('PAYMENT_EXCHANGE_DATE', 'CH.EXCHANGE_DATE', 'PAYMENT_EXCHANGE_DATE', 'aprx_py.var.PAYMENT_EXCHANGE_DATE', 'DATE');
	fa_rx_util_pkg.assign_column('PAYMENT_EXCHANGE_TYPE', 'CH.EXCHANGE_RATE_TYPE', 'PAYMENT_EXCHANGE_TYPE', 'aprx_py.var.PAYMENT_EXCHANGE_TYPE', 'VARCHAR2', 30);
	fa_rx_util_pkg.assign_column('PAYMENT_CLEARED_DATE', 'CH.CLEARED_DATE', 'PAYMENT_CLEARED_DATE', 'aprx_py.var.PAYMENT_CLEARED_DATE', 'DATE');
	fa_rx_util_pkg.assign_column('PAYMENT_CLEARED_AMOUNT', 'CH.CLEARED_AMOUNT', 'PAYMENT_CLEARED_AMOUNT', 'aprx_py.var.PAYMENT_CLEARED_AMOUNT', 'NUMBER');
	fa_rx_util_pkg.assign_column('PAYMENT_CLEARED_BASE_AMOUNT', 'CH.CLEARED_BASE_AMOUNT', 'PAYMENT_CLEARED_BASE_AMOUNT', 'aprx_py.var.PAYMENT_CLEARED_BASE_AMOUNT', 'NUMBER');
	fa_rx_util_pkg.assign_column('PAYMENT_CLEARED_EXC_RATE', 'CH.CLEARED_EXCHANGE_RATE', 'PAYMENT_CLEARED_EXC_RATE', 'aprx_py.var.PAYMENT_CLEARED_EXC_RATE', 'NUMBER');
	fa_rx_util_pkg.assign_column('PAYMENT_CLEARED_EXC_DATE', 'CH.CLEARED_EXCHANGE_DATE', 'PAYMENT_CLEARED_EXC_DATE', 'aprx_py.var.PAYMENT_CLEARED_EXC_DATE', 'DATE');
	fa_rx_util_pkg.assign_column('PAYMENT_CLEARED_EXC_TYPE', 'CH.CLEARED_EXCHANGE_RATE_TYPE', 'PAYMENT_CLEARED_EXC_TYPE', 'aprx_py.var.PAYMENT_CLEARED_EXC_TYPE', 'VARCHAR2', 30);
	fa_rx_util_pkg.assign_column('PAYMENT_FUTURE_PAY_DUE_DATE', 'CH.FUTURE_PAY_DUE_DATE', 'PAYMENT_FUTURE_PAY_DUE_DATE', 'aprx_py.var.PAYMENT_FUTURE_PAY_DUE_DATE', 'DATE');
	fa_rx_util_pkg.assign_column('PAYMENT_VOID_FLAG', 'DECODE(CH.VOID_DATE, NULL, :b_nls_no, :b_nls_yes)', 'PAYMENT_VOID_FLAG', 'aprx_py.var.PAYMENT_VOID_FLAG', 'VARCHAR2', 10);
	fa_rx_util_pkg.assign_column('PAYMENT_PAY_METHOD', 'PMLKP.PAYMENT_METHOD_NAME', 'PAYMENT_PAY_METHOD', 'aprx_py.var.PAYMENT_PAY_METHOD', 'VARCHAR2', 25);
	fa_rx_util_pkg.assign_column('PAYMENT_STATUS', 'PSLKP.DISPLAYED_FIELD', 'PAYMENT_STATUS', 'aprx_py.var.PAYMENT_STATUS', 'VARCHAR2', 50);
-- Bug 6967238
	fa_rx_util_pkg.assign_column('PAYMENT_DOC_NAME', 'CS1.PAYMENT_DOCUMENT_NAME', 'PAYMENT_DOC_NAME', 'aprx_py.var.PAYMENT_DOC_NAME', 'VARCHAR2', 20);
	fa_rx_util_pkg.assign_column('PAYMENT_DISBURSEMENT_TYPE', 'CSLKP.DISPLAYED_FIELD', 'PAYMENT_DISBURSEMENT_TYPE', 'aprx_py.var.PAYMENT_DISBURSEMENT_TYPE', 'VARCHAR2', 25);
	fa_rx_util_pkg.assign_column('SUPPLIER_NAME', 'CH.VENDOR_NAME', 'SUPPLIER_NAME', 'aprx_py.var.SUPPLIER_NAME', 'VARCHAR2', 240);
	fa_rx_util_pkg.assign_column('SUPPLIER_NAME_ALT', 'V.VENDOR_NAME_ALT', 'SUPPLIER_NAME_ALT', 'aprx_py.var.SUPPLIER_NAME_ALT', 'VARCHAR2', 320);
	fa_rx_util_pkg.assign_column('SUPPLIER_SITE_CODE', 'CH.VENDOR_SITE_CODE', 'SUPPLIER_SITE_CODE', 'aprx_py.var.SUPPLIER_SITE_CODE', 'VARCHAR2', 15);
	fa_rx_util_pkg.assign_column('SUPPLIER_SITE_CODE_ALT', 'VS.VENDOR_SITE_CODE_ALT', 'SUPPLIER_SITE_CODE_ALT', 'aprx_py.var.SUPPLIER_SITE_CODE_ALT', 'VARCHAR2', 320);
	fa_rx_util_pkg.assign_column('SUPPLIER_ADDRESS_LINE1', 'CH.ADDRESS_LINE1', 'SUPPLIER_ADDRESS_LINE1', 'aprx_py.var.SUPPLIER_ADDRESS_LINE1', 'VARCHAR2', 240);
	fa_rx_util_pkg.assign_column('SUPPLIER_ADDRESS_LINE2', 'CH.ADDRESS_LINE2', 'SUPPLIER_ADDRESS_LINE2', 'aprx_py.var.SUPPLIER_ADDRESS_LINE2', 'VARCHAR2', 240);
	fa_rx_util_pkg.assign_column('SUPPLIER_ADDRESS_LINE3', 'CH.ADDRESS_LINE3', 'SUPPLIER_ADDRESS_LINE3', 'aprx_py.var.SUPPLIER_ADDRESS_LINE3', 'VARCHAR2', 240);
	fa_rx_util_pkg.assign_column('SUPPLIER_ADDRESS_ALT', 'VS.ADDRESS_LINES_ALT', 'SUPPLIER_ADDRESS_ALT', 'aprx_py.var.SUPPLIER_ADDRESS_ALT', 'VARCHAR2', 560);
	fa_rx_util_pkg.assign_column('SUPPLIER_CITY', 'CH.CITY', 'SUPPLIER_CITY', 'aprx_py.var.SUPPLIER_CITY', 'VARCHAR2', 25);
	fa_rx_util_pkg.assign_column('SUPPLIER_STATE', 'CH.STATE', 'SUPPLIER_STATE', 'aprx_py.var.SUPPLIER_STATE', 'VARCHAR2', 150);
	fa_rx_util_pkg.assign_column('SUPPLIER_PROVINCE', 'CH.PROVINCE', 'SUPPLIER_PROVINCE', 'aprx_py.var.SUPPLIER_PROVINCE', 'VARCHAR2', 150);
	fa_rx_util_pkg.assign_column('SUPPLIER_POSTAL_CODE', 'CH.ZIP', 'SUPPLIER_POSTAL_CODE', 'aprx_py.var.SUPPLIER_POSTAL_CODE', 'VARCHAR2', 20);
	fa_rx_util_pkg.assign_column('SUPPLIER_COUNTRY', 'CH.COUNTRY', 'SUPPLIER_COUNTRY', 'aprx_py.var.SUPPLIER_COUNTRY', 'VARCHAR2', 25);
	fa_rx_util_pkg.assign_column('SUPPLIER_TERRITORY', 'VSTERR.TERRITORY_SHORT_NAME', 'SUPPLIER_TERRITORY', 'aprx_py.var.SUPPLIER_TERRITORY', 'VARCHAR2', 80);
	fa_rx_util_pkg.assign_column('INT_BANK_NAME', 'B.BANK_NAME', 'INT_BANK_NAME', 'aprx_py.var.INT_BANK_NAME', 'VARCHAR2', 60);
	fa_rx_util_pkg.assign_column('INT_BANK_NAME_ALT', 'B.BANK_NAME_ALT', 'INT_BANK_NAME_ALT', 'aprx_py.var.INT_BANK_NAME_ALT', 'VARCHAR2', 320);
	fa_rx_util_pkg.assign_column('INT_BANK_NUMBER', 'B.BANK_NUMBER', 'INT_BANK_NUMBER', 'aprx_py.var.INT_BANK_NUMBER', 'VARCHAR2', 30);
	fa_rx_util_pkg.assign_column('INT_BANK_BRANCH_NAME', 'B.BANK_BRANCH_NAME', 'INT_BANK_BRANCH_NAME', 'aprx_py.var.INT_BANK_BRANCH_NAME', 'VARCHAR2', 60);
	fa_rx_util_pkg.assign_column('INT_BANK_BRANCH_NAME_ALT', 'B.BANK_BRANCH_NAME_ALT', 'INT_BANK_BRANCH_NAME_ALT', 'aprx_py.var.INT_BANK_BRANCH_NAME_ALT', 'VARCHAR2', 320);
	fa_rx_util_pkg.assign_column('INT_BANK_NUM', 'CH.BANK_NUM', 'INT_BANK_NUM', 'aprx_py.var.INT_BANK_NUM', 'VARCHAR2', 30);
	fa_rx_util_pkg.assign_column('INT_BANK_ACCOUNT_NAME', 'CH.BANK_ACCOUNT_NAME', 'INT_BANK_ACCOUNT_NAME', 'aprx_py.var.INT_BANK_ACCOUNT_NAME', 'VARCHAR2', 80);
	fa_rx_util_pkg.assign_column('INT_BANK_ACCOUNT_NAME_ALT', 'BA.BANK_ACCOUNT_NAME_ALT', 'INT_BANK_ACCOUNT_NAME_ALT', 'aprx_py.var.INT_BANK_ACCOUNT_NAME_ALT', 'VARCHAR2', 320);
	fa_rx_util_pkg.assign_column('INT_BANK_ACCOUNT_NUM', 'CH.BANK_ACCOUNT_NUM', 'INT_BANK_ACCOUNT_NUM', 'aprx_py.var.INT_BANK_ACCOUNT_NUM', 'VARCHAR2', 30);
	fa_rx_util_pkg.assign_column('INT_BANK_CURRENCY_CODE', 'BA.CURRENCY_CODE', 'INT_BANK_CURRENCY_CODE', 'aprx_py.var.INT_BANK_CURRENCY_CODE', 'VARCHAR2', 15);
-->>SELECT_END<<--


  --
  -- Assign From Clause
  --
  fa_rx_util_pkg.From_Clause :=
	'AP_CHECKS CH,
	FND_DOCUMENT_SEQUENCES CHDOC,
	IBY_PAYMENT_METHODS_VL PMLKP,
	AP_LOOKUP_CODES PSLKP,
	AP_LOOKUP_CODES CSLKP,
	AP_LOOKUP_CODES CHTYPLKP,
	PO_VENDORS V,
	PO_VENDOR_SITES VS,
	FND_TERRITORIES_VL VSTERR,
	CE_PAYMENT_DOCUMENTS CS1,
	CE_BANK_ACCT_USES_ALL CBAU,
	CE_BANK_BRANCHES_V B,
	CE_BANK_ACCOUNTS ba,
	ap_system_parameters sys';           /* bug8760710 */
	/*AP_BANK_BRANCHES B,
	AP_BANK_ACCOUNTS ba'; Bug 6967238
*/
  --
  -- Assign Where Clause (including the where clause from the parameters)
  --
  fa_rx_util_pkg.Where_Clause :=
	'CH.DOC_SEQUENCE_ID = CHDOC.DOC_SEQUENCE_ID(+)
AND
	CH.PAYMENT_DOCUMENT_ID = CS1.PAYMENT_DOCUMENT_ID(+) AND
	DECODE(CS1.MANUAL_PAYMENTS_ONLY_FLAG,''Y'', ''RECORDED'', ''N'', ''COMBINED'') = CSLKP.lookup_code(+) AND
	CSLKP.lookup_type(+) = ''DISBURSEMENT TYPE'' AND
	CH.PAYMENT_METHOD_CODE = PMLKP.PAYMENT_METHOD_CODE AND
	CH.STATUS_LOOKUP_CODE = PSLKP.LOOKUP_CODE AND
	PSLKP.LOOKUP_TYPE = ''CHECK STATE'' AND
	CH.PAYMENT_TYPE_FLAG = CHTYPLKP.LOOKUP_CODE AND
	VS.org_id =sys.org_id AND                                /* 8760710 */
	CHTYPLKP.LOOKUP_TYPE = ''PAYMENT TYPE''
AND
	CH.VENDOR_ID = V.vendor_id(+) AND
	CH.VENDOR_SITE_ID = VS.vendor_site_id(+) AND
	CH.COUNTRY = VSTERR.TERRITORY_CODE(+)
AND
	BA.BANK_BRANCH_ID = B.BRANCH_PARTY_ID AND
  	CH.CE_BANK_ACCT_USE_ID = cbau.BANK_ACCT_USE_ID AND
	cbau.bank_account_id = BA.bank_account_id
    '|| l_param_where; -- Bug 6967238


  --
  -- Initialize some variables
  -- Commenting for bug8760710
/*
  SELECT sob.name, sob.currency_code
  INTO aprx_py.var.ORGANIZATION_NAME, aprx_py.var.FUNCTIONAL_CURRENCY_CODE
  FROM ap_system_parameters sys, gl_sets_of_books sob
  WHERE sys.set_of_books_id = sob.set_of_books_id;
*/
  --Commenting for bug8760710

/* Start of bug8760710 */
  SELECT sob.name, sob.currency_code
  INTO aprx_py.var.ORGANIZATION_NAME, aprx_py.var.FUNCTIONAL_CURRENCY_CODE
  FROM  gl_sets_of_books sob
  WHERE  sob.set_of_books_id=param.ledger_id ;
/* End of bug8760710 */

  fa_rx_util_pkg.debug('aprx_py.register_before_report()-');
end register_before_report;


--
-- This is the bind trigger for the main payment_run report
procedure register_bind(c in integer)
is
  l_nls_yes varchar2(10);
  l_nls_no varchar2(10);
begin
  fa_rx_util_pkg.debug('aprx_py.register_bind()+');

  --
  -- These bind variables were included in the WHERE clause.
  --
  if param.payment_date_start is not null then
	fa_rx_util_pkg.debug('Binding b_payment_date_start.');
	dbms_sql.bind_variable(c, 'b_payment_date_start', param.payment_date_start);
  end if;
  if param.payment_date_end is not null and param.payment_date_end <> param.payment_date_start then
	fa_rx_util_pkg.debug('Binding b_payment_date_end.');
	dbms_sql.bind_variable(c, 'b_payment_date_end', param.payment_date_end);
  end if;

  if param.payment_currency_code is not null then
	fa_rx_util_pkg.debug('Binding b_payment_currency_code.');
	dbms_sql.bind_variable(c, 'b_payment_currency_code', param.payment_currency_code);
  end if;

  if param.payment_bank_account_name is not null then
	fa_rx_util_pkg.debug('Binding b_payment_bank_account_name.');
	dbms_sql.bind_variable(c, 'b_payment_bank_account_name', param.payment_bank_account_name);
  end if;

  if param.payment_method is not null then
	fa_rx_util_pkg.debug('Binding b_payment_method');
	dbms_sql.bind_variable(c, 'b_payment_method', param.payment_method);
  end if;

  if param.payment_type_flag is not null then
	fa_rx_util_pkg.debug('Binding b_payment_type_flag.');
	dbms_sql.bind_variable(c, 'b_payment_type_flag', param.payment_type_flag);
  end if;

  /* Start of bug8760710 */

   if param.ledger_id is not null then
	fa_rx_util_pkg.debug('Binding b_ledger_id');
	dbms_sql.bind_variable(c, 'b_ledger_id', param.ledger_id);
    end if;

  /* End of bug8760710 */


  --
  -- This bind variable was included in the select list.
  --
  select substrb(meaning,1,10) into l_nls_yes from fnd_lookups
	where lookup_type='YES_NO' and lookup_code='Y';
  select substrb(meaning,1,10) into l_nls_no from fnd_lookups
	where lookup_type='YES_NO' and lookup_code='N';
  fa_rx_util_pkg.debug('Binding b_nls_yes and b_nls_no.');
  dbms_sql.bind_variable(c, 'b_nls_yes', l_nls_yes);
  dbms_sql.bind_variable(c, 'b_nls_no', l_nls_no);

  fa_rx_util_pkg.debug('aprx_py.register_bind()-');
end register_bind;



--
-- This is the before report trigger for the payment_actual_run report
procedure actual_before_report
is
begin
  fa_rx_util_pkg.debug('aprx_py.actual_before_report()+');

  --
  -- Assign another column specific to this report
	fa_rx_util_pkg.assign_column('INV_PAY_AMOUNT', 'INVPAY.AMOUNT', 'INV_PAY_AMOUNT', 'aprx_py.var.INV_PAY_AMOUNT', 'NUMBER');
	fa_rx_util_pkg.assign_column('INV_PAY_BASE_AMOUNT', 'nvl(INVPAY.PAYMENT_BASE_AMOUNT,INVPAY.AMOUNT)', 'INV_PAY_BASE_AMOUNT', 'aprx_py.var.INV_PAY_BASE_AMOUNT', 'NUMBER');
	fa_rx_util_pkg.assign_column('INV_PAY_DISCOUNT_TAKEN', 'INVPAY.DISCOUNT_TAKEN', 'INV_PAY_DISCOUNT_TAKEN', 'aprx_py.var.INV_PAY_DISCOUNT_TAKEN', 'NUMBER');
	fa_rx_util_pkg.assign_column('INVOICE_NUM', 'INV1.INVOICE_NUM', 'INVOICE_NUM', 'aprx_py.var.INVOICE_NUM', 'VARCHAR2', 50);
	fa_rx_util_pkg.assign_column('INVOICE_DATE', 'INV1.INVOICE_DATE', 'INVOICE_DATE', 'aprx_py.var.INVOICE_DATE', 'DATE');
	fa_rx_util_pkg.assign_column('INVOICE_CURRENCY_CODE', 'INV1.INVOICE_CURRENCY_CODE', 'INVOICE_CURRENCY_CODE', 'aprx_py.var.INVOICE_CURRENCY_CODE', 'VARCHAR2', 15);
	fa_rx_util_pkg.assign_column('INVOICE_AMOUNT', 'INV1.INVOICE_AMOUNT', 'INVOICE_AMOUNT', 'aprx_py.var.INVOICE_AMOUNT', 'NUMBER');
	fa_rx_util_pkg.assign_column('INVOICE_BASE_AMOUNT', 'NVL(INV1.BASE_AMOUNT, INV1.INVOICE_AMOUNT)', 'INVOICE_BASE_AMOUNT', 'aprx_py.var.INVOICE_BASE_AMOUNT', 'NUMBER');
	fa_rx_util_pkg.assign_column('INVOICE_DESCRIPTION', 'INV1.DESCRIPTION', 'INVOICE_DESCRIPTION', 'aprx_py.var.INVOICE_DESCRIPTION', 'VARCHAR2', 240);



  -- Add to the  WHERE clause specific to this report
  fa_rx_util_pkg.From_Clause := fa_rx_util_pkg.From_Clause ||',
	AP_INVOICE_PAYMENTS INVPAY,
	AP_INVOICES inv1';

  fa_rx_util_pkg.Where_Clause := fa_rx_util_pkg.Where_Clause || '
	and CH.STATUS_LOOKUP_CODE NOT IN (''VOIDED'', ''SET UP'')
	and CH.CHECK_ID = INVPAY.CHECK_ID
	and INVPAY.INVOICE_ID = INV1.invoice_id';

    --
    -- NOTE : Differences compared to original Japanese Actual Payment Report
    -- The original used the set_of_books_id and included in the where clause a comparison with
    -- ap_invoices.set_of_books_id
    -- ap_bank_accounts.set_of_books_id
    -- po_vendors.set_of_books_id
    -- While the first two (invoices, bank accounts) do nothing for the select statement either
    -- way, the last one (vendors) causes a problem in the original. Vendors is a shared entity
    -- and you should not be looking at the set_of_books_id. I may be missing something, but
    -- the column seems unnecessary.
    --
    -- Additionally, the original compared ap_checks.vendor_name to po_vendors.vendor_name.
    -- This also is incorrect since users can change the vendor name when entering in a payment.
    -- You should always compare ap_check.vendor_id to po_vendors.vendor_id when joining these
    -- two tables.
    --

  fa_rx_util_pkg.debug('aprx_py.actual_before_report()-');
end actual_before_report;


end aprx_py;

/
