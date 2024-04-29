--------------------------------------------------------
--  DDL for Package Body FII_AR_TRX_ACT_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_TRX_ACT_DTL_PKG" AS
/* $Header: FIIARDBITADB.pls 120.27 2007/07/03 20:17:33 mmanasse ship $ */

PROCEDURE get_trx_act_dtl(
	p_page_parameter_tbl			IN		BIS_PMV_PAGE_PARAMETER_TBL,
	p_trx_act_dtl_sql			OUT NOCOPY	VARCHAR2,
	p_trx_act_dtl_output			OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL
) IS

sqlstmt 		VARCHAR2(24000);	-- Variable that stores the final SQL query
l_viewby_id		VARCHAR2(240);		-- Variable to store the viewby_id based on viewby selected in the report
l_view_by		VARCHAR2(240);		-- Variable to store the viewby based on viewby selected in the report
l_collector_where	VARCHAR2(240);		-- Variable to store the dynamic collector filter
l_customer_where	VARCHAR2(240);		-- Variable to store the dynamic customer filter
l_customer_acc_where	VARCHAR2(240);		-- Variable to store the dynamic customer account filter
l_child_party_where	VARCHAR2(240);          -- Variable to store the dynamic party id filter
l_cust_acc_drill	VARCHAR2(1000);		-- Variable to store drill parameter to view report at customer account level
l_cust_drill		VARCHAR2(1000);		-- Variable to store self-drill parameter to view report to explore child nodes
l_inv_drill		VARCHAR2(1000);		-- Variable to store drill parameter for Invoice column
l_dm_drill		VARCHAR2(1000);		-- Variable to store drill parameter for Debit Memo column
l_cb_drill		VARCHAR2(1000);         -- Variable to store drill parameter for Chargeback column
l_unapp_drill		VARCHAR2(1000);         -- Variable to store drill parameter for Unapplied column
l_viewby_drill 		VARCHAR2(1000);         -- Variable to store drill parameter for View By column
l_amt_inv_drill 	VARCHAR2(1000);         -- Variable to store drill parameter for Invoice column
l_amt_dm_drill 		VARCHAR2(1000);         -- Variable to store drill parameter for Debit Memo column
l_amt_cb_drill 		VARCHAR2(1000);         -- Variable to store drill parameter for Chargeback column
l_amt_unapp_drill 	VARCHAR2(1000);         -- Variable to store drill parameter for Unapplied column
l_global_start_date	VARCHAR2(240);		-- Variable to store the globla start date
l_viewby		VARCHAR2(240);		-- Variable to store the view by column description clause
l_group_by		VARCHAR2(240);		-- Variable to store the group by clause
l_order_by              VARCHAR2(240);          -- Variable to store the order by clause
l_order_by_util         VARCHAR2(240);          -- Variable to store the order by clause returned from the util pkg
l_order_column          VARCHAR2(100);          -- Variable to store the order by column
l_where_clause		VARCHAR2(1000);		-- Variable to store the WHERE clause dynamically
l_from_clause		VARCHAR2(1000);		-- Variable to store the FROM clause dynamically
l_cust_account		VARCHAR2(30);		-- Variable to store Customer Account Id passed from the parent report
l_function_name		VARCHAR2(100);		-- Variable to store the function name that is being called
l_sysdate		VARCHAR2(30);		-- Variable to store sysdate for sending it to child report
l_balance_drill		VARCHAR2(2000);		-- Variable to store the drill on balance column
l_balance_col		VARCHAR2(1000); 	-- Variable to store Balance column source dynamically
l_col_curr_suffix	VARCHAR2(100);		-- Variable to store the currency suffix

BEGIN

	-- Reads the parameters from the parameter portlet
	fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);

	-- Defaulting the View By to OU
	fii_ar_util_pkg.g_view_by := 'ORGANIZATION+FII_OPERATING_UNITS';

	-- Populates the security related global temporary tables (fii_ar_summary_gt)
	fii_ar_util_pkg.populate_summary_gt_tables;

	--Logic for sorting
	l_order_by_util := fii_ar_util_pkg.g_order_by;

	IF instr(substr(l_order_by_util,-3), 'ASC') <> 0 THEN
	-- Ascending order sorting on any column
		l_order_by := '&ORDER_BY_CLAUSE';
	ELSIF instr(l_order_by_util, 'FII_AR_ORIG_AMT DESC') <> 0 THEN
	-- Default sorting
		l_order_by := 'ORDER BY NVL(FII_AR_ORIG_AMT, -999999999) DESC';
	ELSIF instr(l_order_by_util, 'DATE') <> 0 THEN
	-- Descending order sorting on Date column
		l_order_by := '&ORDER_BY_CLAUSE';
	ELSIF instr(l_order_by_util, 'BINARY') <> 0 THEN
	-- Descending order sorting on Text column
		l_order_column := substr(l_order_by_util, instr(l_order_by_util, 'FII'), instr(l_order_by_util, ',') - instr(l_order_by_util, 'FII'));
		l_order_by := 'ORDER BY NVL(' || l_order_column || ', ''      '') DESC';
	ELSE
	-- Descending order sorting on Amount column
		l_order_column := substr(l_order_by_util,1,instr(l_order_by_util, ' DESC'));
		l_order_by := 'ORDER BY NVL('|| l_order_column ||', -999999999) DESC';
	END IF;

	l_cust_account := fii_ar_util_pkg.g_cust_account;

	-- Adding filter when one or multiple customers selected but not All
	IF fii_ar_util_pkg.g_party_id <> '-111' THEN
		l_where_clause := l_where_clause || ' AND hzca.party_id = gt.party_id AND hzca.party_id = :PARTY_ID';
	END IF;

	-- Adding filter when a single collector is selected
	IF fii_ar_util_pkg.g_collector_id <> '-111' THEN
		l_from_clause := ', fii_collectors coll';
		l_where_clause := l_where_clause
			|| ' AND coll.collector_id = gt.collector_id
			AND coll.site_use_id = f.bill_to_site_use_id
			AND coll.cust_account_id = f.bill_to_customer_id';
	END IF;

	-- Adding filter when a single industry is selected
	IF fii_ar_util_pkg.g_industry_id <> '-111' THEN
		l_from_clause := l_from_clause || ' , fii_party_mkt_class ind';
		l_where_clause := l_where_clause || ' AND ind.class_code = gt.class_code
			AND ind.party_id = hzca.party_id
			AND hzca.cust_account_id = f.bill_to_customer_id';
	END IF;

	IF l_cust_account IS NULL THEN
		l_cust_account := ' NULL ';
	ELSE
		l_where_clause := l_where_clause || ' AND f.bill_to_customer_id = :CUST_ACCOUNT';
	END IF;

	l_function_name := fii_ar_util_pkg.g_function_name;

	l_col_curr_suffix := fii_ar_util_pkg.g_col_curr_suffix;

	l_balance_col := '
					sum(ag.current_bucket_1_amount' || l_col_curr_suffix || '
					+ ag.current_bucket_2_amount' || l_col_curr_suffix || '
					+ ag.current_bucket_3_amount' || l_col_curr_suffix || '
					+ ag.past_due_bucket_1_amount' || l_col_curr_suffix || '
					+ ag.past_due_bucket_2_amount' || l_col_curr_suffix || '
					+ ag.past_due_bucket_3_amount' || l_col_curr_suffix || '
					+ ag.past_due_bucket_4_amount' || l_col_curr_suffix || '
					+ ag.past_due_bucket_5_amount' || l_col_curr_suffix || '
					+ ag.past_due_bucket_6_amount' || l_col_curr_suffix || '
					+ ag.past_due_bucket_7_amount' || l_col_curr_suffix || ')';

	IF l_function_name = 'FII_AR_INV_ACT_DTL' THEN
		l_where_clause := l_where_clause || ' AND f.class = ''INV''';
	ELSIF l_function_name = 'FII_AR_DM_ACT_DTL' THEN
		l_where_clause := l_where_clause || ' AND f.class = ''DM''';
	ELSIF l_function_name = 'FII_AR_CB_ACT_DTL' THEN
		l_where_clause := l_where_clause || ' AND f.class = ''CB''';
	ELSIF l_function_name = 'FII_AR_BILLING_ACT_DTL' THEN
		l_where_clause := l_where_clause || ' AND f.class IN (''INV'',''DM'',''CB'',''CM'',''DEP'',''BR'') ';
		l_balance_col := '
				decode(f.class, ''CM'', sum(ag.on_acct_credit_amount' || l_col_curr_suffix || '),
					sum(ag.current_bucket_1_amount' || l_col_curr_suffix || '
					+ ag.current_bucket_2_amount' || l_col_curr_suffix || '
					+ ag.current_bucket_3_amount' || l_col_curr_suffix || '
					+ ag.past_due_bucket_1_amount' || l_col_curr_suffix || '
					+ ag.past_due_bucket_2_amount' || l_col_curr_suffix || '
					+ ag.past_due_bucket_3_amount' || l_col_curr_suffix || '
					+ ag.past_due_bucket_4_amount' || l_col_curr_suffix || '
					+ ag.past_due_bucket_5_amount' || l_col_curr_suffix || '
					+ ag.past_due_bucket_6_amount' || l_col_curr_suffix || '
					+ ag.past_due_bucket_7_amount' || l_col_curr_suffix || '))';
	END IF;

	SELECT TO_CHAR(TRUNC(sysdate),'DD/MM/YYYY') INTO l_sysdate FROM dual;

	l_balance_drill := 'DECODE(outer_inner_query.FII_AR_BALANCE_AMT, NULL, NULL, DECODE(outer_inner_query.FII_AR_TRAN_CLASS,''INV'',
''AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_AR_INV_ACT_HISTORY&FII_AR_CUST_TRX_ID=''||customer_trx_id
||''&FII_AR_TRAN_NUM=FII_AR_TRAN_NUM&FII_AR_TRAN_CLASS=''||outer_inner_query.FII_AR_TRAN_CLASS
||''&BIS_PMV_DRILL_CODE_FII_AR_ACCOUNT_NUM=FII_AR_ACCT_NUM&FII_AR_TRAN_CURR=FII_AR_TRAN_CURR&pParamIds=Y'',
''BR'',
''AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_AR_BR_ACT_HISTORY&FII_AR_CUST_TRX_ID=''||customer_trx_id
||''&FII_AR_TRAN_NUM=FII_AR_TRAN_NUM&FII_AR_TRAN_CLASS=''||outer_inner_query.FII_AR_TRAN_CLASS
||''&BIS_PMV_DRILL_CODE_FII_AR_ACCOUNT_NUM=FII_AR_ACCT_NUM&FII_AR_TRAN_CURR=FII_AR_TRAN_CURR&pParamIds=Y'',
''CB'',
''AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_AR_CB_ACT_HISTORY&FII_AR_CUST_TRX_ID=''||customer_trx_id
||''&FII_AR_TRAN_NUM=FII_AR_TRAN_NUM&FII_AR_TRAN_CLASS=''||outer_inner_query.FII_AR_TRAN_CLASS
||''&BIS_PMV_DRILL_CODE_FII_AR_ACCOUNT_NUM=FII_AR_ACCT_NUM&FII_AR_TRAN_CURR=FII_AR_TRAN_CURR&pParamIds=Y'',
''CM'',
''AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_AR_CM_ACT_HISTORY&FII_AR_CUST_TRX_ID=''||customer_trx_id
||''&FII_AR_TRAN_NUM=FII_AR_TRAN_NUM&FII_AR_TRAN_CLASS=''||outer_inner_query.FII_AR_TRAN_CLASS
||''&BIS_PMV_DRILL_CODE_FII_AR_ACCOUNT_NUM=FII_AR_ACCT_NUM&FII_AR_TRAN_CURR=FII_AR_TRAN_CURR&pParamIds=Y'',
''DEP'',
''AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_AR_DEP_ACT_HISTORY&FII_AR_CUST_TRX_ID=''||customer_trx_id
||''&FII_AR_TRAN_NUM=FII_AR_TRAN_NUM&FII_AR_TRAN_CLASS=''||outer_inner_query.FII_AR_TRAN_CLASS
||''&BIS_PMV_DRILL_CODE_FII_AR_ACCOUNT_NUM=FII_AR_ACCT_NUM&FII_AR_TRAN_CURR=FII_AR_TRAN_CURR&pParamIds=Y'',
''DM'',
''AS_OF_DATE='||l_sysdate||'&pFunctionName=FII_AR_DM_ACT_HISTORY&FII_AR_CUST_TRX_ID=''||customer_trx_id
||''&FII_AR_TRAN_NUM=FII_AR_TRAN_NUM&FII_AR_TRAN_CLASS=''||outer_inner_query.FII_AR_TRAN_CLASS
||''&BIS_PMV_DRILL_CODE_FII_AR_ACCOUNT_NUM=FII_AR_ACCT_NUM&FII_AR_TRAN_CURR=FII_AR_TRAN_CURR&pParamIds=Y'', '''' ))';


	-- Constructing the pmv sql query
	sqlstmt := '
	SELECT
		FII_AR_ACCT_NUM,
		FII_AR_TRAN_NUM,
		lk.meaning FII_AR_TRAN_CLASS,
		FII_AR_TRAN_TYPE,
		FII_AR_TRAN_DATE,
		FII_AR_GL_DATE,
		FII_AR_FIRST_DUE_DATE,
		FII_AR_TRAN_AMT,
		FII_AR_ORIG_AMT,
		FII_AR_BALANCE_AMT,
		FII_AR_TERMS,
		FII_AR_SOURCE,
		decode(FII_AR_TRAN_CLASS, ''INV'',
		''pFunctionName=ARBPA_TM_REAL_PREVIEW&retainBN=Y&retainAM=Y&addBreadCrumb=Y&TermsSequenceNumber=1&CustomerTrxId=''
		|| customer_trx_id  || ''&orgId='' || outer_inner_query.org_id || ''&pParamIds=Y'', '''') FII_AR_TRAN_NUM_DRILL,
		''AS_OF_DATE=' || l_sysdate ||
'&pFunctionName=FII_AR_SCHD_PMT_DISCNT&BIS_PMV_DRILL_CODE_FII_AR_CUST_ACCOUNT=FII_AR_ACCT_NUM&FII_AR_TRAN_NUM=FII_AR_TRAN_NUM&FII_CURRENCIES='||'''||FII_AR_TRAN_CURR||'''||'&FII_AR_CUST_TRX_ID=''
|| customer_trx_id || ''&pParamIds=Y'' FII_AR_FIRST_DUE_DATE_DRILL,
		' || l_balance_drill || ' FII_AR_BALANCE_AMT_DRILL,

		decode(outer_inner_query.order_ref_number, NULL, '''', ''pFunctionName=ONT_PORTAL_ORDERDETAILS&HeaderId='' || ooh.header_id) FII_AR_SOURCE_DRILL,
		sum(FII_AR_ORIG_AMT) over() FII_AR_GT_ORIG_AMT,
		sum(FII_AR_BALANCE_AMT) over() FII_AR_GT_BALANCE_AMT,
		' || l_cust_account || ' FII_AR_CUST_ACCOUNT,
		FII_AR_TRAN_CURR
	FROM
	(
		SELECT
			inner_query.customer_trx_id, inner_query.org_id,
			inner_query.order_ref_number order_ref_number,
			FII_AR_ACCT_NUM,
			FII_AR_TRAN_NUM,
			FII_AR_TRAN_CLASS,
			FII_AR_TRAN_TYPE,
			FII_AR_TRAN_DATE,
			FII_AR_GL_DATE,
			FII_AR_FIRST_DUE_DATE,
			inner_query.invoice_currency_code || '' '' || to_char(sum(FII_AR_TRAN_AMT),''999,999,999,999'') FII_AR_TRAN_AMT,
			sum(FII_AR_ORIG_AMT) FII_AR_ORIG_AMT,
			sum(FII_AR_BALANCE_AMT) FII_AR_BALANCE_AMT,
			FII_AR_TERMS,
			FII_AR_SOURCE,
			inner_query.invoice_currency_code FII_AR_TRAN_CURR
		FROM
		(
			SELECT /*+ leading(gt) cardinality(gt 1) */
				f.customer_trx_id, f.org_id,
				f.invoice_currency_code,
				f.order_ref_number order_ref_number,
				hzca.account_number	FII_AR_ACCT_NUM,
				f.transaction_number FII_AR_TRAN_NUM,
				f.class FII_AR_TRAN_CLASS,
				ractt.DESCRIPTION FII_AR_TRAN_TYPE,
				f.TRX_DATE FII_AR_TRAN_DATE,
				f.GL_DATE FII_AR_GL_DATE,
				min(f.DUE_DATE) FII_AR_FIRST_DUE_DATE,
				sum(decode(ag.action, ''Transaction'', decode(ag.billing_activity_flag, ''Y'', f.amount_due_original_trx,0),0)) FII_AR_TRAN_AMT,
				sum(decode(ag.action, ''Transaction'', decode(ag.billing_activity_flag, ''Y'',f.amount_due_original' || l_col_curr_suffix || ',0),0)) FII_AR_ORIG_AMT,
					' || l_balance_col || ' FII_AR_BALANCE_AMT,
				ratt.description FII_AR_TERMS,
				rabs.description FII_AR_SOURCE
			FROM
				fii_ar_pmt_schedules_f f,
				ra_cust_trx_types_all ractt,
				ra_terms_tl ratt,
				ra_batch_sources_all rabs,
				hz_cust_accounts hzca,
				fii_ar_aging_receivables ag,
				fii_ar_summary_gt gt
				' || l_from_clause || '
			WHERE
				f.cust_trx_type_id = ractt.cust_trx_type_id(+)
				AND f.class = ractt.type
				AND f.org_id = ractt.org_id
				AND f.term_id = ratt.term_id(+)
				AND nvl(ratt.language,USERENV(''LANG'')) = USERENV(''LANG'')
				AND f.batch_source_id = rabs.batch_source_id
				AND f.org_id = rabs.org_id
				AND gt.org_id = f.org_id
				AND f.bill_to_customer_id = hzca.cust_account_id
				AND f.filter_date BETWEEN :CURR_PERIOD_START AND
				:ASOF_DATE
				AND ag.event_date BETWEEN :CURR_PERIOD_START AND
				:ASOF_DATE
				AND f.payment_schedule_id = ag.payment_schedule_id
				AND f.org_id = ag.org_id
				--AND ag.action IN (''Transaction'', ''Adjustment'', ''Application'') // Commented for Bug # 5176544 fix
				' || l_where_clause || '
			GROUP BY f.customer_trx_id, f.order_ref_number, hzca.account_number, f.transaction_number, f.class, ractt.DESCRIPTION,
					f.TRX_DATE, f.GL_DATE, f.invoice_currency_code, ratt.description, rabs.description, f.org_id
	        ) inner_query
        	GROUP BY inner_query.customer_trx_id, inner_query.order_ref_number, FII_AR_ACCT_NUM, FII_AR_TRAN_NUM, FII_AR_TRAN_CLASS,
			FII_AR_TRAN_TYPE, FII_AR_TRAN_DATE, FII_AR_GL_DATE, FII_AR_FIRST_DUE_DATE, inner_query.invoice_currency_code, FII_AR_TERMS, FII_AR_SOURCE, inner_query.org_id
	)outer_inner_query,
		ar_lookups lk,
		oe_order_headers_all ooh
	WHERE
		outer_inner_query.FII_AR_TRAN_CLASS = lk.lookup_code
		AND lk.lookup_type= ''INV/CM/ADJ''
		AND outer_inner_query.order_ref_number = to_char(ooh.order_number(+))
	' || l_order_by;

	-- Calling the bind_variable API
	fii_ar_util_pkg.bind_variable(
		p_sqlstmt 		=> sqlstmt,
		p_page_parameter_tbl 	=> p_page_parameter_tbl,
		p_sql_output 		=> p_trx_act_dtl_sql,
		p_bind_output_table 	=> p_trx_act_dtl_output
	);

END get_trx_act_dtl;

END fii_ar_trx_act_dtl_pkg;


/
