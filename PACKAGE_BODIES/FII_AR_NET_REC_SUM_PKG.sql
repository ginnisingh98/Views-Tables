--------------------------------------------------------
--  DDL for Package Body FII_AR_NET_REC_SUM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_NET_REC_SUM_PKG" AS
/* $Header: FIIARDBINRB.pls 120.18 2007/05/15 20:50:02 vkazhipu ship $ */

PROCEDURE get_net_rec_sum(
	p_page_parameter_tbl			IN		BIS_PMV_PAGE_PARAMETER_TBL,
	p_net_rec_sum_sql			OUT NOCOPY	VARCHAR2,
	p_net_rec_sum_output			OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL
) IS

sqlstmt 		VARCHAR2(24000);	-- Variable that stores the final SQL query
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
l_unapp_sum_drill	VARCHAR2(1000);         -- Variable to store drill parameter for Unapplied column
l_viewby_drill 		VARCHAR2(1000);         -- Variable to store drill parameter for View By column
l_amt_inv_drill 	VARCHAR2(1000);         -- Variable to store drill parameter for Invoice column
l_amt_dm_drill 		VARCHAR2(1000);         -- Variable to store drill parameter for Debit Memo column
l_amt_cb_drill 		VARCHAR2(1000);         -- Variable to store drill parameter for Chargeback column
l_amt_unapp_drill 	VARCHAR2(1000);         -- Variable to store drill parameter for Unapplied column
l_global_start_date	VARCHAR2(240);		-- Variable to store the globla start date
l_order_by              VARCHAR2(240);          -- Variable to store the order by clause
l_order_column          VARCHAR2(100);          -- Variable to store the order by column
l_self_flag_where	VARCHAR2(100);		-- Variable to retrieve is_self_flag dynamically
l_self_flag_where_d	VARCHAR2(100);		-- Variable to retrieve is_self_flag dynamically for dummy purpose
l_gt_hint varchar2(500);
l_cust_acc_drill_1	VARCHAR2(1000);		-- Variable to store drill parameter to view report at customer account level
l_unapp_sum_drill_1	VARCHAR2(1000);         -- Variable to store drill parameter for Unapplied column
BEGIN

	-- Clear global parameters AND read the new parameters
	-- Sets all g_% variables to its default values
	fii_ar_util_pkg.reset_globals;

	-- Reads the parameters from the parameter portlet
	fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);
  l_gt_hint := ' leading(gt) cardinality(gt 1) ';
	-- Populates the security related global temporary tables (fii_ar_summary_gt)
	fii_ar_util_pkg.populate_summary_gt_tables;

	l_view_by := fii_ar_util_pkg.g_view_by;

	-- Adding Filter on collector_id only if Collector is 'All'
	IF fii_ar_util_pkg.g_collector_id <> '-111' OR l_view_by = 'FII_COLLECTOR+FII_COLLECTOR' THEN
		l_collector_where := ' AND f.collector_id = v.collector_id';
	ELSE
		l_collector_where := '';
	END IF;

	-- Adding Filter on party_id
	IF (fii_ar_util_pkg.g_party_id <> '-111' OR fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMERS') THEN
		l_child_party_where := ' AND f.party_id   = v.party_id ';
	ELSE
		l_child_party_where := '';
	END IF;

	-- Defining the drills
	l_cust_acc_drill 	:= '''pFunctionName=FII_AR_NET_REC_SUM&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID''';
	l_cust_drill 		:= '''pFunctionName=FII_AR_NET_REC_SUM&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY''';
	l_inv_drill 		:= '''pFunctionName=FII_AR_OPEN_INV_DTL&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID''';
	l_dm_drill 		:= '''pFunctionName=FII_AR_OPEN_DM_DTL&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID''';
	l_cb_drill 		:= '''pFunctionName=FII_AR_OPEN_CB_DTL&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID''';
	l_unapp_drill 		:= '''pFunctionName=FII_AR_UNAPP_RCT_DTL&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID''';
	l_unapp_sum_drill 	:= '''pFunctionName=FII_AR_UNAPP_RCT_SUMMARY&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID''';

	l_self_flag_where := ', v.is_self_flag';
	l_self_flag_where_d := ', NULL is_self_flag';

	IF l_view_by = 'ORGANIZATION+FII_OPERATING_UNITS' OR l_view_by = 'FII_COLLECTOR+FII_COLLECTOR' THEN
		l_viewby_drill 		:= '''''';
		IF (fii_ar_util_pkg.g_party_id <> '-111') THEN
		 l_cust_acc_drill 	:= '''pFunctionName=FII_AR_NET_REC_SUM&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID''';
		 l_unapp_sum_drill 	:= '''pFunctionName=FII_AR_UNAPP_RCT_SUMMARY&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID''';
		ELSE
		 l_cust_acc_drill 	:= '''pFunctionName=FII_AR_NET_REC_SUM&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID''';
		 l_unapp_sum_drill 	:= '''pFunctionName=FII_AR_UNAPP_RCT_SUMMARY&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID''';
		END IF;
		l_amt_inv_drill 	:= 'DECODE(sum(inline_query.inv_amount), 0, '''', ' || l_cust_acc_drill || ')';
		l_amt_dm_drill 		:= 'DECODE(sum(inline_query.dm_amount), 0, '''', ' || l_cust_acc_drill || ')';
		l_amt_cb_drill 		:= 'DECODE(sum(inline_query.cb_amount), 0, '''', ' || l_cust_acc_drill || ')';
		l_amt_unapp_drill 	:= 'DECODE(nvl(sum(inline_query.unapp_amount),0), 0, '''', ' || l_unapp_sum_drill || ')';
	ELSIF l_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS' THEN
	  l_gt_hint := ' leading(gt.gt) cardinality(gt.gt 1) ';
		l_viewby_drill 		:= '''''';
		l_amt_inv_drill 	:=  'DECODE(sum(inline_query.inv_amount), 0, '''', ' ||
'''pFunctionName=FII_AR_OPEN_INV_DTL&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS='' || max(inline_query.party_id) || ''&FII_AR_CUST_ACCOUNT='' || inline_query.viewby_code)';
		l_amt_dm_drill 		:= 'DECODE(sum(inline_query.dm_amount), 0, '''', ' ||
'''pFunctionName=FII_AR_OPEN_DM_DTL&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS='' || max(inline_query.party_id) || ''&FII_AR_CUST_ACCOUNT='' || inline_query.viewby_code)';
		l_amt_cb_drill 		:= 'DECODE(sum(inline_query.cb_amount), 0, '''', ' ||
'''pFunctionName=FII_AR_OPEN_CB_DTL&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS='' || max(inline_query.party_id) || ''&FII_AR_CUST_ACCOUNT='' || inline_query.viewby_code)';
		l_amt_unapp_drill 	:=  'DECODE(nvl(sum(inline_query.unapp_amount),0), 0, '''', ' ||
'''pFunctionName=FII_AR_UNAPP_RCT_DTL&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS='' || max(inline_query.party_id) || ''&FII_AR_CUST_ACCOUNT='' || inline_query.viewby_code)';
		-- Adding Filter on customer account only when viewby is Customer account
		l_customer_acc_where 	:= ' AND f.cust_account_id = v.cust_account_id';
		l_self_flag_where := '';
		l_self_flag_where_d := '';
	ELSIF l_view_by = 'CUSTOMER+FII_CUSTOMERS' THEN
		l_viewby_drill 		:= 'DECODE(max(inline_query.is_leaf_flag), ''Y'', '''', DECODE(max(inline_query.is_self_flag), ''Y'', '''',' || l_cust_drill || '))';
		l_amt_inv_drill 	:= 'DECODE(sum(inline_query.inv_amount), 0, '''', DECODE(max(inline_query.is_leaf_flag), ''Y'',' || l_inv_drill || ', DECODE(max(inline_query.is_self_flag), ''Y'', ' || l_inv_drill || ',' || l_cust_acc_drill || ')))';
		l_amt_dm_drill 		:= 'DECODE(sum(inline_query.dm_amount), 0, '''', DECODE(max(inline_query.is_leaf_flag), ''Y'',' || l_dm_drill || ', DECODE(max(inline_query.is_self_flag), ''Y'', ' || l_dm_drill || ',' || l_cust_acc_drill ||  ')))';
		l_amt_cb_drill 		:= 'DECODE(sum(inline_query.cb_amount), 0, '''', DECODE(max(inline_query.is_leaf_flag), ''Y'',' || l_cb_drill || ', DECODE(max(inline_query.is_self_flag), ''Y'', ' || l_cb_drill || ',' || l_cust_acc_drill || ')))';
		l_amt_unapp_drill 	:= 'DECODE(nvl(sum(inline_query.unapp_amount),0), 0, '''', DECODE(max(inline_query.is_leaf_flag), ''Y'',' || l_unapp_drill || ', DECODE(max(inline_query.is_self_flag), ''Y'', ' || l_unapp_drill || ',' || l_unapp_sum_drill || ')))';
		-- Defining the view by column and the group by clause when viewby is Customer
		l_customer_where 	:= ' AND f.parent_party_id = v.parent_party_id';
	END IF;

        -- Constructing the ORDER BY clause
        IF instr(fii_ar_util_pkg.g_order_by,',') <> 0 THEN
                l_order_by := ' ORDER BY NVL(FII_AR_NET_REC_AMT, -999999999) DESC';
        ELSIF instr(fii_ar_util_pkg.g_order_by, ' DESC') <> 0 THEN
                l_order_column := substr(fii_ar_util_pkg.g_order_by,1,instr(fii_ar_util_pkg.g_order_by, ' DESC'));
                l_order_by := ' ORDER BY NVL(' || l_order_column || ', -999999999) DESC';
        ELSE
                l_order_by := ' &ORDER_BY_CLAUSE';
        END IF;

	-- Constructing the pmv sql query
	sqlstmt := '
	SELECT
		inline_query.viewby					VIEWBY,
		inline_query.viewby_code	 			VIEWBYID,
		sum(inline_query.inv_amount) + sum(inline_query.dm_amount) + sum(inline_query.cb_amount) + sum(inline_query.br_amount)
		+ sum(inline_query.dep_amount) + sum(inline_query.on_account_credit_amount) - sum(inline_query.unapp_dep_amount)
		- nvl(sum(inline_query.unapp_amount), 0) - sum(inline_query.on_account_cash_amount) - sum(inline_query.claim_amount)
		- sum(inline_query.prepayment_amount)	 		FII_AR_NET_REC_AMT,
		sum(inline_query.inv_amount)				FII_AR_INV_AMT,
		sum(inline_query.dm_amount)				FII_AR_DEB_MEMO_AMT,
		sum(inline_query.cb_amount)				FII_AR_CHARGEBACK_AMT,
		sum(inline_query.br_amount)				FII_AR_BILLS_REC_AMT,
		sum(inline_query.dep_amount)				FII_AR_UNP_DEP_AMT,
		sum(inline_query.on_account_credit_amount)		FII_AR_ON_ACC_CREDIT_AMT,
		sum(inline_query.unapp_dep_amount)			FII_AR_UNAPP_DEP_AMT,
		nvl(sum(inline_query.unapp_amount), 0)			FII_AR_UNAPP_AMT,
		sum(inline_query.on_account_cash_amount)		FII_AR_ON_ACC_CASH_AMT,
		sum(inline_query.claim_amount)				FII_AR_CLAIMS_AMT,
		sum(inline_query.prepayment_amount)			FII_AR_PREPAYMENT_AMT,
		' || l_viewby_drill || '				FII_AR_VIEW_BY_DRILL,
		' || l_amt_inv_drill || '				FII_AR_INV_AMT_DRILL,
		' || l_amt_dm_drill || '				FII_AR_DEB_MEMO_AMT_DRILL,
		' || l_amt_cb_drill || '				FII_AR_CHARGEBACK_AMT_DRILL,
		' || l_amt_unapp_drill || '				FII_AR_UNAPP_AMT_DRILL,
		sum(sum(inline_query.inv_amount)) over() + sum(sum(inline_query.dm_amount)) over()
		+ sum(sum(inline_query.cb_amount)) over() + sum(sum(inline_query.br_amount)) over()
		+ sum(sum(inline_query.dep_amount)) over() + sum(sum(inline_query.on_account_credit_amount)) over()
		- sum(sum(inline_query.unapp_dep_amount)) over() - nvl(sum(sum(inline_query.unapp_amount)) over(), 0)
		- sum(sum(inline_query.on_account_cash_amount)) over() - sum(sum(inline_query.claim_amount)) over()
		- sum(sum(inline_query.prepayment_amount)) over() FII_AR_GT_NET_REC_AMT,
                sum(sum(inline_query.inv_amount)) over() 		FII_AR_GT_INV_AMT,
		sum(sum(inline_query.dm_amount)) over()			FII_AR_GT_DEB_MEMO_AMT,
		sum(sum(inline_query.cb_amount)) over()			FII_AR_GT_CHARGEBACK_AMT,
		sum(sum(inline_query.br_amount)) over()			FII_AR_GT_BILLS_REC_AMT,
		sum(sum(inline_query.dep_amount)) over()		FII_AR_GT_UNP_DEP_AMT,
		sum(sum(inline_query.on_account_credit_amount)) over()	FII_AR_GT_ON_ACC_CREDIT_AMT,
		sum(sum(inline_query.unapp_dep_amount)) over()		FII_AR_GT_UNAPP_DEP_AMT,
		nvl(sum(sum(inline_query.unapp_amount)) over(), 0)	FII_AR_GT_UNAPP_AMT,
		sum(sum(inline_query.on_account_cash_amount)) over()	FII_AR_GT_ON_ACC_CASH_AMT,
		sum(sum(inline_query.claim_amount)) over()		FII_AR_GT_CLAIMS_AMT,
		sum(sum(inline_query.prepayment_amount)) over()		FII_AR_GT_PREPAYMENT_AMT
	FROM
	(
		SELECT /*+ INDEX(f FII_AR_NET_REC'|| fii_ar_util_pkg.g_cust_suffix ||'_mv_N1)*/
			v.viewby, v.viewby_code,
			f.inv_amount, f.dm_amount, f.cb_amount, f.br_amount, f.dep_amount,
			f.on_account_credit_amount, f.unapp_dep_amount, NULL unapp_amount,
			f.on_account_cash_amount, f.claim_amount, f.prepayment_amount
			' || l_self_flag_where || ', v.is_leaf_flag, f.party_id
		FROM
			fii_ar_net_rec' || fii_ar_util_pkg.g_cust_suffix || '_mv' || fii_ar_util_pkg.g_curr_suffix || ' f,
			(
				SELECT /*+ no_merge '||l_gt_hint|| ' */ *
				FROM 	fii_time_structures cal,
					' || fii_ar_util_pkg.get_from_statement || ' gt
				WHERE 	cal.report_date = :ASOF_DATE
					AND bitand(cal.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE
					AND ' || fii_ar_util_pkg.get_where_statement || '
			) v
		WHERE
			f.time_id = v.time_id
			AND f.period_type_id = v.period_type_id
			AND f.org_id = v.org_id
			AND '||fii_ar_util_pkg.get_mv_where_statement||' '|| l_collector_where
			|| l_customer_where
			|| l_child_party_where
			|| l_customer_acc_where || '
		UNION ALL
		SELECT /*+ INDEX(f FII_AR_RCT_AGING'|| fii_ar_util_pkg.g_cust_suffix ||'_mv_N1)*/
			v.viewby, v.viewby_code,
			NULL inv_amount, NULL dm_amount, NULL cb_amount, NULL br_amount, NULL dep_amount,
			NULL on_account_credit_amount, NULL unapp_dep_amount, f.unapp_amount,
			NULL on_account_cash_amount, NULL claim_amount, NULL prepayment_amount
			' || l_self_flag_where_d || ', NULL is_leaf_flag, NULL party_id
		FROM
			fii_ar_rct_aging' || fii_ar_util_pkg.g_cust_suffix || '_mv' || fii_ar_util_pkg.g_curr_suffix || ' f,
			(
				SELECT /*+ no_merge '||l_gt_hint|| ' */ *
				FROM 	fii_time_structures cal,
					' || fii_ar_util_pkg.get_from_statement || ' gt
				WHERE 	cal.report_date = :ASOF_DATE
					AND bitand(cal.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE
					AND ' || fii_ar_util_pkg.get_where_statement || '
			) v
		WHERE
			f.time_id = v.time_id
			AND f.period_type_id = v.period_type_id
			AND f.org_id = v.org_id
			AND '||fii_ar_util_pkg.get_rct_mv_where_statement||' '
			|| l_collector_where
			|| l_customer_where
			|| l_child_party_where
			|| l_customer_acc_where || '
	) inline_query
	GROUP BY inline_query.viewby_code, inline_query.viewby'
	|| l_order_by;

	-- Calling the bind_variable API
	fii_ar_util_pkg.bind_variable(
		p_sqlstmt 		=> sqlstmt,
		p_page_parameter_tbl 	=> p_page_parameter_tbl,
		p_sql_output 		=> p_net_rec_sum_sql,
		p_bind_output_table 	=> p_net_rec_sum_output
	);

END get_net_rec_sum;

END fii_ar_net_rec_sum_pkg;


/
