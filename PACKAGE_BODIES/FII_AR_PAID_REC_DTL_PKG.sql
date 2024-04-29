--------------------------------------------------------
--  DDL for Package Body FII_AR_PAID_REC_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_PAID_REC_DTL_PKG" AS
/* $Header: FIIARDBIPRDB.pls 120.26 2007/07/03 20:21:34 mmanasse ship $ */

PROCEDURE get_paid_rec_dtl(
	p_page_parameter_tbl			IN		BIS_PMV_PAGE_PARAMETER_TBL,
	p_paid_rec_dtl_sql			OUT NOCOPY	VARCHAR2,
	p_paid_rec_dtl_output			OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL
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
l_order_by_util         VARCHAR2(240);          -- Variable to store the order by clause returned from util pkg
l_order_column          VARCHAR2(100);          -- Variable to store the order by column
l_col_curr_suffix	VARCHAR2(100); 		-- Variable to store the suffix for columns based on currency
l_sysdate		VARCHAR2(20);		-- Variable to store sysdate for sending it to child report

BEGIN

	-- Reads the parameters from the parameter portlet
	fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);

	--Logic for sorting
	l_order_by_util := fii_ar_util_pkg.g_order_by;

	IF instr(substr(l_order_by_util,-3), 'ASC') <> 0 THEN
	-- Ascending order sorting on any column
		l_order_by := '&ORDER_BY_CLAUSE';
	ELSIF instr(l_order_by_util, 'FII_AR_PAID_AMT DESC') <> 0 THEN
	-- Default sorting
		l_order_by := 'ORDER BY NVL(FII_AR_PAID_AMT, -999999999) DESC';
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

	l_col_curr_suffix := fii_ar_util_pkg.g_col_curr_suffix;

	SELECT TO_CHAR(TRUNC(sysdate),'DD/MM/YYYY') INTO l_sysdate FROM dual;

	-- Constructing the pmv sql query
	sqlstmt := '
	SELECT
		hzca.account_number FII_AR_ACCT_NUM,
		FII_AR_TRAN_NUM,
		lk.meaning FII_AR_TRAN_CLASS,
		ractt.DESCRIPTION FII_AR_TRAN_TYPE,
		FII_AR_TRAN_DATE,
		FII_AR_GL_DATE,
		FII_AR_FIRST_DUE_DATE,
		FII_AR_TRAN_AMT,
		FII_AR_ORIG_AMT,
		FII_AR_PAID_AMT,
		FII_AR_ADJUST_AMT,
		FII_AR_BALANCE_AMT,
		FII_AR_DISC_TAKEN_AMT,
		ratt.description FII_AR_TERMS,
		rabs.description FII_AR_SOURCE,
		decode(FII_AR_TRAN_CLASS, ''INV'',
			''pFunctionName=ARBPA_TM_REAL_PREVIEW&retainBN=Y&retainAM=Y&addBreadCrumb=Y&TermsSequenceNumber=1&CustomerTrxId=''
			|| customer_trx_id || ''&pParamIds=Y'', '''') FII_AR_TRAN_NUM_DRILL,
		 decode(lk.lookup_code,''PMT'','''',''pFunctionName=FII_AR_SCHD_PMT_DISCNT&FII_AR_CUST_TRX_ID='' || customer_trx_id ||
		''&FII_AR_TRAN_NUM=FII_AR_TRAN_NUM&FII_CURRENCIES='||'''||FII_AR_TRAN_CURR||'''||'&BIS_PMV_DRILL_CODE_FII_AR_CUST_ACCOUNT=FII_AR_ACCT_NUM&pParamIds=Y'') FII_AR_FIRST_DUE_DATE_DRILL,
		''pFunctionName=FII_AR_APP_RCT_DTL&TRX_NUM='' || customer_trx_id || ''&BIS_PMV_DRILL_CODE_FII_AR_CASH_RECEIPT_ID=''
		|| :CASH_RECEIPT_ID || ''&pParamIds=Y'' FII_AR_PAID_AMT_DRILL,
		decode(FII_AR_BALANCE_AMT, NULL, '''', ''AS_OF_DATE=' || l_sysdate || '&pFunctionName=FII_AR_INV_ACT_HISTORY&FII_AR_CUST_TRX_ID=''
		|| outer_inner_query.customer_trx_id || ''&FII_AR_TRAN_NUM=FII_AR_TRAN_NUM&FII_AR_TRAN_CLASS='' || outer_inner_query.FII_AR_TRAN_CLASS
		|| ''&BIS_PMV_DRILL_CODE_FII_AR_ACCOUNT_NUM=FII_AR_ACCT_NUM&FII_AR_TRAN_CURR=FII_AR_TRAN_CURR&pParamIds=Y'') FII_AR_BALANCE_AMT_DRILL,
		decode(outer_inner_query.order_ref_number, NULL, '''',
			''pFunctionName=ONT_PORTAL_ORDERDETAILS&HeaderId='' || (select ooh.header_id
				from oe_order_headers_all ooh
				where outer_inner_query.order_ref_number    = to_char(ooh.order_number) )) FII_AR_SOURCE_DRILL,
		sum(FII_AR_ORIG_AMT) over() FII_AR_GT_ORIG_AMT,
		sum(FII_AR_PAID_AMT) over() FII_AR_GT_PAID_AMT,
		sum(FII_AR_ADJUST_AMT) over() FII_AR_GT_ADJUST_AMT,
		sum(FII_AR_BALANCE_AMT) over() FII_AR_GT_BALANCE_AMT,
		sum(FII_AR_DISC_TAKEN_AMT) over() FII_AR_GT_DISC_TAKEN_AMT
	FROM
	(
		SELECT
			inner_query.customer_trx_id, max(inner_query.cust_trx_type_id) cust_trx_type_id, max(inner_query.term_id) term_id,
			max(inner_query.batch_source_id) batch_source_id,max(inner_query.bill_to_customer_id)bill_to_customer_id,
			max(inner_query.order_ref_number) order_ref_number,
			max(inner_query.invoice_currency_code) invoice_currency_code,
			max(FII_AR_TRAN_NUM) FII_AR_TRAN_NUM,
			max(FII_AR_TRAN_CLASS) FII_AR_TRAN_CLASS,
			max(inner_query.org_id) org_id,
			max(FII_AR_TRAN_DATE) FII_AR_TRAN_DATE,
			max(FII_AR_GL_DATE) FII_AR_GL_DATE,
			max(FII_AR_FIRST_DUE_DATE) FII_AR_FIRST_DUE_DATE,
			max(inner_query.invoice_currency_code) || '' '' || to_char(sum(FII_AR_TRAN_AMT),''999,999,999,999'') FII_AR_TRAN_AMT,
			sum(FII_AR_ORIG_AMT) FII_AR_ORIG_AMT,
			SUM(fII_AR_PAID_AMT) FII_AR_PAID_AMT,
			sum(FII_AR_ADJUST_AMT) FII_AR_ADJUST_AMT,
			sum(FII_AR_BALANCE_AMT) FII_AR_BALANCE_AMT,
			sum(FII_AR_DISC_TAKEN_AMT) FII_AR_DISC_TAKEN_AMT,
			max(inner_query.invoice_currency_code) FII_AR_TRAN_CURR
		FROM
		(
			SELECT
				f.customer_trx_id, f.org_id, f.cust_trx_type_id, f.term_id, f.batch_source_id, f.bill_to_customer_id,
				f.invoice_currency_code,
				f.order_ref_number order_ref_number,
				f.transaction_number FII_AR_TRAN_NUM,
				f.class FII_AR_TRAN_CLASS,
				f.TRX_DATE FII_AR_TRAN_DATE,
				f.GL_DATE FII_AR_GL_DATE,
				min(f.DUE_DATE) FII_AR_FIRST_DUE_DATE,
				sum(f.amount_due_original_trx) FII_AR_TRAN_AMT,
				sum(f.amount_due_original' || l_col_curr_suffix || ') FII_AR_ORIG_AMT,
				sum(h.amount_applied_trx' || l_col_curr_suffix || ') FII_AR_PAID_AMT,
				NULL FII_AR_ADJUST_AMT,
				NULL FII_AR_BALANCE_AMT,
				sum(f.earned_discount_amount' || l_col_curr_suffix || ') + sum(f.unearned_discount_amount' || l_col_curr_suffix || ') FII_AR_DISC_TAKEN_AMT
			FROM
				fii_ar_pmt_schedules_f f,
				(select h1.applied_customer_trx_id, sum(h1.amount_applied_trx_prim) amount_applied_trx_prim,
                                        sum(h1.amount_applied_trx_sec) amount_applied_trx_sec
                                 from fii_ar_receipts_f h1
				 where h1.cash_receipt_id = :CASH_RECEIPT_ID
				 and h1.application_status = ''APP''
				 and h1.filter_date <= :ASOF_DATE
				 and h1.applied_customer_trx_id IS NOT NULL
				 group by h1.applied_customer_trx_id) h
			WHERE
				f.customer_trx_id = h.applied_customer_trx_id
				AND f.filter_date <= :ASOF_DATE
			GROUP BY f.customer_trx_id, f.order_ref_number, f.bill_to_customer_id, f.transaction_number, f.class, f.org_id,
				f.cust_trx_type_id, f.TRX_DATE, f.GL_DATE, f.invoice_currency_code, f.term_id, f.batch_source_id
			UNION ALL
			SELECT
				f.customer_trx_id, f.org_id, f.cust_trx_type_id, f.term_id, f.batch_source_id, f.bill_to_customer_id,
				f.invoice_currency_code,
				f.order_ref_number order_ref_number,
				f.transaction_number FII_AR_TRAN_NUM,
				f.class FII_AR_TRAN_CLASS,
				f.TRX_DATE FII_AR_TRAN_DATE,
				f.GL_DATE FII_AR_GL_DATE,
				min(f.DUE_DATE) FII_AR_FIRST_DUE_DATE,
				sum(f.amount_due_original_trx) FII_AR_TRAN_AMT,
				sum(f.amount_due_original' || l_col_curr_suffix || ') FII_AR_ORIG_AMT,
				sum(h.amount_applied_trx' || l_col_curr_suffix || ') FII_AR_PAID_AMT,
				NULL FII_AR_ADJUST_AMT,
				NULL FII_AR_BALANCE_AMT,
				sum(f.earned_discount_amount' || l_col_curr_suffix || ') + sum(f.unearned_discount_amount' || l_col_curr_suffix || ') FII_AR_DISC_TAKEN_AMT
			FROM
				fii_ar_pmt_schedules_f f,
				(select h1.payment_schedule_id, sum(h1.amount_applied_trx_prim) amount_applied_trx_prim,
                                        sum(h1.amount_applied_trx_sec) amount_applied_trx_sec
                                 from fii_ar_receipts_f h1
				 where h1.cash_receipt_id = :CASH_RECEIPT_ID
				 and h1.application_status = ''APP''
				 and h1.filter_date <= :ASOF_DATE
				 and h1.applied_customer_trx_id IS NULL
				 group by h1.payment_schedule_id) h
			WHERE
				f.payment_schedule_id = h.payment_schedule_id
				AND f.filter_date <= :ASOF_DATE
			GROUP BY f.customer_trx_id, f.order_ref_number, f.bill_to_customer_id, f.transaction_number, f.class, f.org_id,
				f.cust_trx_type_id, f.TRX_DATE, f.GL_DATE, f.invoice_currency_code, f.term_id, f.batch_source_id
			UNION ALL
			SELECT
				f.customer_trx_id, NULL org_id, NULL cust_trx_type_id, NULL term_id, NULL batch_source_id, NULL bill_to_customer_id,
				NULL invoice_currency_code,
				NULL order_ref_number,
				NULL FII_AR_TRAN_NUM,
				NULL FII_AR_TRAN_CLASS,
				NULL FII_AR_TRAN_DATE,
				NULL FII_AR_GL_DATE,
				NULL FII_AR_FIRST_DUE_DATE,
				NULL FII_AR_TRAN_AMT,
				NULL FII_AR_ORIG_AMT,
				NULL FII_AR_PAID_AMT,
				decode(ag.adjustment_id, NULL, NULL, sum(ag.current_bucket_1_amount' || l_col_curr_suffix || ')
					+ sum(ag.current_bucket_2_amount' || l_col_curr_suffix || ')
					+ sum(ag.current_bucket_3_amount' || l_col_curr_suffix || ')
					+ sum(ag.past_due_bucket_1_amount' || l_col_curr_suffix || ')
					+ sum(ag.past_due_bucket_2_amount' || l_col_curr_suffix || ')
					+ sum(ag.past_due_bucket_3_amount' || l_col_curr_suffix || ')
					+ sum(ag.past_due_bucket_4_amount' || l_col_curr_suffix || ')
					+ sum(ag.past_due_bucket_5_amount' || l_col_curr_suffix || ')
					+ sum(ag.past_due_bucket_6_amount' || l_col_curr_suffix || ')
					+ sum(ag.past_due_bucket_7_amount' || l_col_curr_suffix || ')) FII_AR_ADJUST_AMT,
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
					+ ag.past_due_bucket_7_amount' || l_col_curr_suffix || ')) FII_AR_BALANCE_AMT,
				NULL FII_AR_DISC_TAKEN_AMT
			FROM
				fii_ar_pmt_schedules_f f,
				fii_ar_aging_receivables ag,
				(select h1.applied_customer_trx_id
                                 from fii_ar_receipts_f h1
				 where h1.cash_receipt_id = :CASH_RECEIPT_ID
				 and h1.application_status = ''APP''
				 and h1.filter_date <= :ASOF_DATE
				 and h1.applied_customer_trx_id IS NOT NULL
				 group by h1.applied_customer_trx_id) h

			WHERE
				f.customer_trx_id = h.applied_customer_trx_id
				AND ag.event_date <= :ASOF_DATE
				AND f.payment_schedule_id = ag.payment_schedule_id
				AND f.filter_date <= :ASOF_DATE
				GROUP BY f.customer_trx_id, ag.adjustment_id, f.class
			UNION ALL
			SELECT
				f.customer_trx_id, NULL org_id, NULL cust_trx_type_id, NULL term_id, NULL batch_source_id, NULL bill_to_customer_id,
				NULL invoice_currency_code,
				NULL order_ref_number,
				NULL FII_AR_TRAN_NUM,
				NULL FII_AR_TRAN_CLASS,
				NULL FII_AR_TRAN_DATE,
				NULL FII_AR_GL_DATE,
				NULL FII_AR_FIRST_DUE_DATE,
				NULL FII_AR_TRAN_AMT,
				NULL FII_AR_ORIG_AMT,
				NULL FII_AR_PAID_AMT,
				decode(ag.adjustment_id, NULL, NULL, sum(ag.current_bucket_1_amount' || l_col_curr_suffix || ')
					+ sum(ag.current_bucket_2_amount' || l_col_curr_suffix || ')
					+ sum(ag.current_bucket_3_amount' || l_col_curr_suffix || ')
					+ sum(ag.past_due_bucket_1_amount' || l_col_curr_suffix || ')
					+ sum(ag.past_due_bucket_2_amount' || l_col_curr_suffix || ')
					+ sum(ag.past_due_bucket_3_amount' || l_col_curr_suffix || ')
					+ sum(ag.past_due_bucket_4_amount' || l_col_curr_suffix || ')
					+ sum(ag.past_due_bucket_5_amount' || l_col_curr_suffix || ')
					+ sum(ag.past_due_bucket_6_amount' || l_col_curr_suffix || ')
					+ sum(ag.past_due_bucket_7_amount' || l_col_curr_suffix || ')) FII_AR_ADJUST_AMT,
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
					+ ag.past_due_bucket_7_amount' || l_col_curr_suffix || ')) FII_AR_BALANCE_AMT,
				NULL FII_AR_DISC_TAKEN_AMT
			FROM
				fii_ar_pmt_schedules_f f,
				fii_ar_aging_receivables ag,
				(select h1.payment_schedule_id
                                 from fii_ar_receipts_f h1
				 where h1.cash_receipt_id = :CASH_RECEIPT_ID
				 and h1.application_status = ''APP''
				 and h1.filter_date <= :ASOF_DATE
				 and h1.applied_customer_trx_id IS NULL
				 group by h1.payment_schedule_id) h
			WHERE
				f.payment_schedule_id = h.payment_schedule_id
				AND ag.event_date <= :ASOF_DATE
				AND f.payment_schedule_id = ag.payment_schedule_id
				AND f.filter_date <= :ASOF_DATE
				GROUP BY f.customer_trx_id, ag.adjustment_id, f.class
		) inner_query
		GROUP BY inner_query.customer_trx_id
	)outer_inner_query,
		ar_lookups lk,
		ra_cust_trx_types_all ractt,
		ra_terms_tl ratt,
		ra_batch_sources_all rabs,
		hz_cust_accounts hzca
	WHERE
		outer_inner_query.FII_AR_TRAN_CLASS = lk.lookup_code
		AND lk.lookup_type= ''INV/CM/ADJ''
		AND outer_inner_query.cust_trx_type_id = ractt.cust_trx_type_id(+)
		AND outer_inner_query.FII_AR_TRAN_CLASS = ractt.type(+)
		AND outer_inner_query.org_id = ractt.org_id(+)
		AND outer_inner_query.term_id = ratt.term_id(+)
		AND ratt.language(+) = USERENV(''LANG'')
		AND outer_inner_query.batch_source_id = rabs.batch_source_id(+)
		AND outer_inner_query.org_id = rabs.org_id(+)
		AND outer_inner_query.bill_to_customer_id = hzca.cust_account_id
	' || l_order_by;

	-- Calling the bind_variable API
	fii_ar_util_pkg.bind_variable(
		p_sqlstmt 		=> sqlstmt,
		p_page_parameter_tbl 	=> p_page_parameter_tbl,
		p_sql_output 		=> p_paid_rec_dtl_sql,
		p_bind_output_table 	=> p_paid_rec_dtl_output
	);

END get_paid_rec_dtl;

END fii_ar_paid_rec_dtl_pkg;


/
