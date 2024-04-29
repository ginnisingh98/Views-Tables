--------------------------------------------------------
--  DDL for Package Body FII_AR_DSO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_DSO_PKG" AS
/* $Header: FIIARDBIDSOB.pls 120.27 2007/05/15 20:48:52 vkazhipu ship $ */

-- Function to return the DSO period for displaying in the parameter portlet
FUNCTION get_dso_period_param RETURN VARCHAR2 IS
	period VARCHAR2(50);
BEGIN
	period := fii_ar_util_pkg.get_dso_period_profile;

	IF period <> -1 THEN
		period := period || ' Days';
	END IF;

	RETURN period;
END get_dso_period_param;

-- Function to return the list of Receivables category enabled in the Receivables Setup page
FUNCTION get_net_rec_column RETURN VARCHAR2 IS
	net_rec_col VARCHAR2(500);
BEGIN
	-- Flags from Receivable Setup
	fii_ar_util_pkg.get_dso_table_values;

	-- Adding columns that are enabled in the Receivables Setup page
	net_rec_col := '';
	g_open_rec_column_dso := '';
	g_open_rec_column_dsot := '';
	g_hit_rct_aging := 'N';
        FOR a IN fii_ar_util_pkg.g_dso_table.FIRST..fii_ar_util_pkg.g_dso_table.LAST LOOP
                CASE
                        WHEN fii_ar_util_pkg.g_dso_table(a).dso_type = 'INV' AND fii_ar_util_pkg.g_dso_table(a).dso_value = 'Y' THEN
                                net_rec_col := net_rec_col  || ' + sum(f.inv_amount)';
                                g_open_rec_column_dso := g_open_rec_column_dso  || ' + sum(f.inv_amount)';
                                g_open_rec_column_dsot := g_open_rec_column_dsot  || ' + sum(inline_query.inv_amount)';
                        WHEN fii_ar_util_pkg.g_dso_table(a).dso_type = 'DM' AND fii_ar_util_pkg.g_dso_table(a).dso_value = 'Y' THEN
                                net_rec_col := net_rec_col  || ' + sum(f.dm_amount)';
                                g_open_rec_column_dso := g_open_rec_column_dso  || ' + sum(f.dm_amount)';
                                g_open_rec_column_dsot := g_open_rec_column_dsot  || ' + sum(inline_query.dm_amount)';
                        WHEN fii_ar_util_pkg.g_dso_table(a).dso_type = 'CB' AND fii_ar_util_pkg.g_dso_table(a).dso_value = 'Y' THEN
                                net_rec_col := net_rec_col  || ' + sum(f.cb_amount)';
                                g_open_rec_column_dso := g_open_rec_column_dso  || ' + sum(f.cb_amount)';
                                g_open_rec_column_dsot := g_open_rec_column_dsot  || ' + sum(inline_query.cb_amount)';
                        WHEN fii_ar_util_pkg.g_dso_table(a).dso_type = 'BR' AND fii_ar_util_pkg.g_dso_table(a).dso_value = 'Y' THEN
                                net_rec_col := net_rec_col  || ' + sum(f.br_amount)';
                                g_open_rec_column_dso := g_open_rec_column_dso  || ' + sum(f.br_amount)';
                                g_open_rec_column_dsot := g_open_rec_column_dsot  || ' + sum(inline_query.br_amount)';
                        WHEN fii_ar_util_pkg.g_dso_table(a).dso_type = 'DEP' AND fii_ar_util_pkg.g_dso_table(a).dso_value = 'Y' THEN
                                net_rec_col := net_rec_col  || ' + sum(f.dep_amount)';
                                g_open_rec_column_dso := g_open_rec_column_dso  || ' + sum(f.dep_amount)';
                                g_open_rec_column_dsot := g_open_rec_column_dsot  || ' + sum(inline_query.dep_amount)';
                        WHEN fii_ar_util_pkg.g_dso_table(a).dso_type = 'CM' AND fii_ar_util_pkg.g_dso_table(a).dso_value = 'Y' THEN
                                net_rec_col := net_rec_col  || ' + sum(f.on_account_credit_amount)';
                        WHEN fii_ar_util_pkg.g_dso_table(a).dso_type = 'UNDEP' AND fii_ar_util_pkg.g_dso_table(a).dso_value = 'Y' THEN
                                net_rec_col := net_rec_col  || ' - sum(f.unapp_dep_amount)';
			WHEN fii_ar_util_pkg.g_dso_table(a).dso_type = 'UNREC' AND fii_ar_util_pkg.g_dso_table(a).dso_value = 'Y' THEN
				g_hit_rct_aging := 'Y';
                        WHEN fii_ar_util_pkg.g_dso_table(a).dso_type = 'OACB' AND fii_ar_util_pkg.g_dso_table(a).dso_value = 'Y' THEN
                                net_rec_col := net_rec_col  || ' - sum(f.on_account_cash_amount)';
                        WHEN fii_ar_util_pkg.g_dso_table(a).dso_type = 'OCB' AND fii_ar_util_pkg.g_dso_table(a).dso_value = 'Y' THEN
                                net_rec_col := net_rec_col  || ' - sum(f.claim_amount)';
                        WHEN fii_ar_util_pkg.g_dso_table(a).dso_type = 'PREPAY' AND fii_ar_util_pkg.g_dso_table(a).dso_value = 'Y' THEN
                                net_rec_col := net_rec_col  || ' - sum(f.prepayment_amount)';
			ELSE
				NULL;
                END CASE;
        END LOOP;

	-- If none of the category is enabled in setup page, it returns NULL
	IF net_rec_col = '' THEN
       		 net_rec_col := 'NULL';
	ELSE
       		 net_rec_col := '0' || net_rec_col;
	END IF;

	IF g_open_rec_column_dso IS NOT NULL THEN
		g_open_rec_column_dso := '0' || g_open_rec_column_dso;
	END IF;

	IF g_open_rec_column_dsot IS NOT NULL THEN
		g_open_rec_column_dsot := '0' || g_open_rec_column_dsot;
	END IF;

	RETURN net_rec_col;
END get_net_rec_column;

PROCEDURE get_dso(
	p_page_parameter_tbl			IN		BIS_PMV_PAGE_PARAMETER_TBL,
	p_dso_sql				OUT NOCOPY	VARCHAR2,
	p_dso_output				OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL
) IS

sqlstmt 		VARCHAR2(20000);	-- Variable that stores the final SQL query
l_view_by		VARCHAR2(240);		-- Variable to store the viewby based on viewby selected in the report
l_customer_where	VARCHAR2(240);		-- Variable to store the dynamic customer filter
l_customer_acc_where	VARCHAR2(240);		-- Variable to store the dynamic customer account filter
l_industry_where	VARCHAR2(240);          -- Variable to store the dynamic industry filter
l_child_party_where     VARCHAR2(240);          -- Variable to store the dynamic party id filter
l_cust_drill		VARCHAR2(1000);		-- Variable to store self-drill parameter to view report to explore child nodes
l_net_rec_sum_drill	VARCHAR2(1000);         -- Variable to store the drill to net receivables summary report
l_net_rec_column	VARCHAR2(1000);		-- Variable to store the columns of categories enabled in receivables setup page
l_group_by		VARCHAR2(240);		-- Variable to store the group by clause
l_order_by		VARCHAR2(240);		-- Variable to store the order by clause
l_order_column 		VARCHAR2(100); 		-- Variable to store the order by column
l_unapp_query		VARCHAR2(2000); 	-- Variable to store the query that returns the unapplied amount
l_gt_hint varchar2(500);


BEGIN

	-- Clear global parameters AND read the new parameters
	-- Sets all g_% variables to its default values
	fii_ar_util_pkg.reset_globals;

	-- Reads the parameters from the parameter portlet
	fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);

	-- Populates the security related global temporary tables (fii_ar_summary_gt)
	fii_ar_util_pkg.populate_summary_gt_tables;

	-- Gets the view by
	l_view_by := fii_ar_util_pkg.g_view_by;

	-- Adding columns that are enabled in the Receivables Setup page
	l_net_rec_column := get_net_rec_column;

	l_customer_acc_where := '';
	l_group_by := '';
	l_customer_where := '';
	l_cust_drill := '''''';
	l_net_rec_sum_drill := 'DECODE(' || g_open_rec_column_dso || ', 0, '''', ''pFunctionName=FII_AR_NET_REC_SUM&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID'')';
  l_gt_hint := ' leading(gt) cardinality(gt 1) ';

	IF l_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS' THEN
		-- filter for customer account
		l_customer_acc_where := ' AND f.cust_account_id = v.cust_account_id';
		l_net_rec_sum_drill := '''''';
		l_gt_hint := ' leading(gt.gt) cardinality(gt.gt 1) ';
	ELSIF  l_view_by = 'CUSTOMER+FII_CUSTOMERS' THEN
		-- Defining the group by clause, the filter on parent_party id and customer drill when viewby is Customer
		l_group_by := ', v.is_self_flag, v.is_leaf_flag';
		l_customer_where := ' AND f.parent_party_id = v.parent_party_id';
		l_cust_drill := 'DECODE(v.is_leaf_flag, ''Y'', '''', DECODE(v.is_self_flag, ''Y'', '''', ''pFunctionName=FII_AR_DSO&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY''))';
	ELSE
	   IF (fii_ar_util_pkg.g_party_id <> '-111') THEN
	     l_net_rec_sum_drill := 'DECODE(' || g_open_rec_column_dso || ', 0, '''', ''pFunctionName=FII_AR_NET_REC_SUM&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID'')';
	   ELSE
	     l_net_rec_sum_drill := 'DECODE(' || g_open_rec_column_dso || ', 0, '''', ''pFunctionName=FII_AR_NET_REC_SUM&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID'')';
	   END IF;
	END IF;

	-- Defining industry where clause for specific industry or viewby is Industry
	IF (fii_ar_util_pkg.g_industry_id <> '-111' AND l_view_by <> 'CUSTOMER+FII_CUSTOMERS')
		OR l_view_by = 'FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS' THEN
		l_industry_where :=  ' AND v.class_code = f.class_code AND v.class_category = f.class_category';
	ELSE
		l_industry_where := '';
	END IF;

        -- Adding Filter on party_id
        IF (fii_ar_util_pkg.g_party_id <> '-111' OR fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMERS') THEN
                l_child_party_where := ' AND f.party_id   = v.party_id ';
        ELSE
                l_child_party_where := '';
        END IF;

	-- Constructing the ORDER BY clause
	IF instr(fii_ar_util_pkg.g_order_by,',') <> 0 THEN
		IF instr(fii_ar_util_pkg.g_order_by,'VIEWBY') <> 0 THEN
			l_order_by := ' ORDER BY ' || fii_ar_util_pkg.g_order_by;
		ELSE
			l_order_by := ' ORDER BY NVL(FII_AR_DSO, -999999999) DESC';
		END IF;
	ELSIF instr(fii_ar_util_pkg.g_order_by, ' DESC') <> 0 THEN
		l_order_column := substr(fii_ar_util_pkg.g_order_by,1,instr(fii_ar_util_pkg.g_order_by, ' DESC'));
		l_order_by := ' ORDER BY NVL(' || l_order_column || ', -999999999) DESC';
	ELSE
		l_order_by := ' &ORDER_BY_CLAUSE';
	END IF;

	IF g_hit_rct_aging = 'Y' THEN
		l_unapp_query := '
			UNION ALL
			SELECT 	/*+ INDEX(f FII_AR_RCT_AGING'|| fii_ar_util_pkg.g_cust_suffix ||'_mv_N1)*/ v.viewby 	 			VIEWBY,
				v.viewby_code				VIEWBYID,
				-sum(f.unapp_amount)			FII_AR_NET_REC_AMT,
				NULL 					FII_AR_BILLED_AMT,
				NULL		 			FII_AR_VIEW_BY_DRILL,
				NULL			 		FII_AR_NET_REC_AMT_DRILL
			FROM 	fii_ar_rct_aging' || fii_ar_util_pkg.g_cust_suffix || '_mv' || fii_ar_util_pkg.g_curr_suffix || ' f,
				(
					SELECT /*+ no_merge INDEX(cal FII_TIME_STRUCTURES_N1) '||l_gt_hint|| ' */  *
					FROM 	fii_time_structures cal,
						' || fii_ar_util_pkg.get_from_statement || ' gt
					WHERE cal.report_date = :ASOF_DATE
						AND (bitand(cal.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE)
						AND ' || fii_ar_util_pkg.get_where_statement || '
				) v
			WHERE 	f.time_id = v.time_id
				AND f.period_type_id = v.period_type_id
				AND f.org_id = v.org_id
				AND '||fii_ar_util_pkg.get_rct_mv_where_statement||' '
				|| l_customer_where
				|| l_child_party_where
				|| l_customer_acc_where
				|| l_industry_where || '
			GROUP BY v.viewby_code, v.VIEWBY' || l_group_by || ' , v.record_type_id';
	ELSE
		l_unapp_query := '';
	END IF;

	-- Constructing the pmv sql query
	sqlstmt := '
	SELECT VIEWBY,
		VIEWBYID,
    		round(sum(FII_AR_NET_REC_AMT)  * :DSO_PERIOD / NULLIF(sum(FII_AR_BILLED_AMT),0)) FII_AR_DSO,
		sum(FII_AR_NET_REC_AMT) FII_AR_NET_REC_AMT,
		sum(FII_AR_BILLED_AMT) FII_AR_BILLED_AMT,
		max(FII_AR_VIEW_BY_DRILL) FII_AR_VIEW_BY_DRILL,
		max(FII_AR_NET_REC_AMT_DRILL) FII_AR_NET_REC_AMT_DRILL,
		(sum(sum(FII_AR_NET_REC_AMT)) over() * :DSO_PERIOD / NULLIF(sum(sum(FII_AR_BILLED_AMT)) over(),0)) FII_AR_GT_DSO,
		sum(sum(FII_AR_NET_REC_AMT)) over() FII_AR_GT_NET_REC_AMT,
		sum(sum(FII_AR_BILLED_AMT)) over() FII_AR_GT_BILLED_AMT
		FROM
		(
			SELECT 	/*+ INDEX(f FII_AR_NET_REC'|| fii_ar_util_pkg.g_cust_suffix ||'_mv_N1)*/
			v.viewby 	 			VIEWBY,
				v.viewby_code				VIEWBYID,
				CASE WHEN bitand(v.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE THEN
					' || l_net_rec_column || '
				ELSE
					NULL
				END 					FII_AR_NET_REC_AMT,
				CASE WHEN bitand(v.record_type_id, :DSO_BITAND) = :DSO_BITAND THEN
					sum(f.billed_amount)
				ELSE
					NULL
				END 					FII_AR_BILLED_AMT,
				' || l_cust_drill || ' 			FII_AR_VIEW_BY_DRILL,
				' || l_net_rec_sum_drill || ' 		FII_AR_NET_REC_AMT_DRILL
			FROM 	fii_ar_net_rec' || fii_ar_util_pkg.g_cust_suffix || '_mv' || fii_ar_util_pkg.g_curr_suffix || ' f,
				(
					SELECT /*+ no_merge INDEX(cal FII_TIME_STRUCTURES_N1) '||l_gt_hint|| ' */ *
					FROM 	fii_time_structures cal,
						' || fii_ar_util_pkg.get_from_statement || ' gt
					WHERE cal.report_date = :ASOF_DATE
						AND (bitand(cal.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE
							OR bitand(cal.record_type_id, :DSO_BITAND) = :DSO_BITAND)
						AND ' || fii_ar_util_pkg.get_where_statement || '
				) v
			WHERE 	f.time_id = v.time_id
				AND f.period_type_id = v.period_type_id
				AND f.org_id = v.org_id
				AND '||fii_ar_util_pkg.get_mv_where_statement||' '|| l_customer_where
				|| l_child_party_where
				|| l_customer_acc_where
				|| l_industry_where || '
			GROUP BY v.viewby_code, v.VIEWBY' || l_group_by || ' , v.record_type_id
			' || l_unapp_query || '
		) inline_query
		GROUP BY VIEWBYID, VIEWBY
	' || l_order_by;

	-- Calling the bind_variable API
	fii_ar_util_pkg.bind_variable(
		p_sqlstmt 		=> sqlstmt,
		p_Page_parameter_tbl 	=> p_page_parameter_tbl,
		p_sql_output 		=> p_dso_sql,
		p_bind_output_table 	=> p_dso_output
	);

END get_dso;

PROCEDURE get_dso_trend(
	p_page_parameter_tbl			IN		BIS_PMV_PAGE_PARAMETER_TBL,
	p_dso_sql				OUT NOCOPY	VARCHAR2,
	p_dso_output				OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL
) IS

sqlstmt 		VARCHAR2(20000);	-- Variable that stores the final SQL query
l_customer_where	VARCHAR2(240);		-- Variable to store the dynamic customer filter
l_industry_where	VARCHAR2(240);          -- Variable to store the dynamic industry filter
l_child_party_where     VARCHAR2(240);          -- Variable to store the dynamic party id filter
l_net_rec_sum_drill	VARCHAR2(1000);         -- Variable to store the drill to net receivables summary report
l_net_rec_column	VARCHAR2(1000);		-- Variable to store the columns of categories enabled in receivables setup page
l_curr_query		VARCHAR2(2000);		-- Variable to store the query to return the values for current period
l_unapp_amount_query	VARCHAR2(2000);		-- Variable to store the query to retrieve unapplied amount
l_curr_unapp_query	VARCHAR2(2000);		-- Variable to store the query to return unapplied amount for the current month


BEGIN

	-- Clear global parameters AND read the new parameters
	-- Sets all g_% variables to its default values
	fii_ar_util_pkg.reset_globals;

	-- Reads the parameters from the parameter portlet
	fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);

	-- Populates the security related global temporary tables (fii_ar_summary_gt)
	fii_ar_util_pkg.populate_summary_gt_tables;

	l_net_rec_sum_drill := 'pFunctionName=FII_AR_NET_REC_SUM&VIEW_BY=ORGANIZATION+FII_OPERATING_UNITS&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID';

        -- Adding Filter on party_id when Customer is NOT All
        IF fii_ar_util_pkg.g_party_id <> '-111' THEN
                l_child_party_where := ' AND f.party_id   = v.party_id ';
        ELSE
                l_child_party_where := '';
        END IF;

	-- Defining industry where clause for specific industry when Industry is NOT All
	IF fii_ar_util_pkg.g_industry_id <> '-111' THEN
		l_industry_where :=  ' AND v.class_code = f.class_code AND v.class_category = f.class_category';
	ELSE
		l_industry_where := '';
	END IF;

	-- Adding columns that are enabled in the Receivables Setup page
	l_net_rec_column := get_net_rec_column;

	IF fii_ar_util_pkg.g_as_of_date <> LAST_DAY(fii_ar_util_pkg.g_as_of_date) THEN
	l_curr_query := '
			UNION ALL
			-- Query to return data for current month
			SELECT /*+ INDEX(f FII_AR_NET_REC'|| fii_ar_util_pkg.g_cust_suffix ||'_mv_N1)*/
				v.sequence FII_EFFECTIVE_NUM,
				CASE WHEN bitand(v.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE THEN
					' || l_net_rec_column || '
				ELSE
					NULL
				END 			FII_AR_NET_REC_AMT,
                       		NULL 			FII_AR_NET_REC_PRIOR_AMT,
				CASE WHEN bitand(v.record_type_id, :DSO_BITAND) = :DSO_BITAND THEN
					sum(f.billed_amount)
				ELSE
					NULL
				END 			FII_AR_BILLED_AMT,
				NULL 			FII_AR_BILLED_PRIOR_AMT,
				sum(f.inv_amount) inv_amount, sum(f.dm_amount) dm_amount, sum(f.cb_amount) cb_amount, sum(f.br_amount) br_amount, sum(f.dep_amount) dep_amount
			FROM
				fii_ar_net_rec' || fii_ar_util_pkg.g_cust_suffix || '_mv' || fii_ar_util_pkg.g_curr_suffix || ' f,
				(
					SELECT /*+ no_merge cardinality(gt 1)*/ *
					FROM fii_ar_summary_gt gt,
					(
						SELECT /*+ no_merge INDEX(cal FII_TIME_STRUCTURES_N1) */ per.sequence, cal.time_id, cal.period_type_id, per.start_date, per.end_date, cal.record_type_id
						FROM fii_time_ent_period per, fii_time_structures cal
						WHERE per.end_date = last_day(:ASOF_DATE)
							AND cal.report_date = :ASOF_DATE
							AND (bitand(cal.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE
								OR bitand(cal.record_type_id, :DSO_BITAND) = :DSO_BITAND)
					) cal_per
				) v
			WHERE
				f.time_id               = v.time_id
				AND f.period_type_id    = v.period_type_id
				AND f.org_id            = v.org_id
				AND '||fii_ar_util_pkg.get_mv_where_statement||' '|| l_child_party_where || '
				' || l_industry_where || '
			GROUP BY v.sequence, v.start_date, v.end_date, v.record_type_id';
	l_curr_unapp_query := '
			UNION ALL
			-- Query to return unapplied amount for current month
			SELECT /*+ INDEX(f FII_AR_RCT_AGING'|| fii_ar_util_pkg.g_cust_suffix ||'_mv_N1)*/
				v.sequence FII_EFFECTIVE_NUM,
				-sum(f.unapp_amount) FII_AR_NET_REC_AMT,
                       		NULL FII_AR_NET_REC_PRIOR_AMT,
				NULL FII_AR_BILLED_AMT,
				NULL FII_AR_BILLED_PRIOR_AMT,
				NULL inv_amount, NULL dm_amount, NULL cb_amount, NULL br_amount, NULL dep_amount
			FROM
				fii_ar_rct_aging' || fii_ar_util_pkg.g_cust_suffix || '_mv' || fii_ar_util_pkg.g_curr_suffix || ' f,
				(
					SELECT /*+ no_merge cardinality(gt 1) */ *
					FROM fii_ar_summary_gt gt,
					(
						SELECT /*+ no_merge INDEX(cal FII_TIME_STRUCTURES_N1) */ per.sequence, cal.time_id, cal.period_type_id, per.start_date, per.end_date, cal.record_type_id
						FROM fii_time_ent_period per, fii_time_structures cal
						WHERE per.end_date = last_day(:ASOF_DATE)
							AND cal.report_date = :ASOF_DATE
							AND (bitand(cal.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE)
					) cal_per
				) v
			WHERE
				f.time_id               = v.time_id
				AND f.period_type_id    = v.period_type_id
				AND f.org_id            = v.org_id
				AND '||fii_ar_util_pkg.get_rct_mv_where_statement||' ' || l_child_party_where || '
				' || l_industry_where || '
			GROUP BY v.sequence, v.start_date, v.end_date, v.record_type_id';
	ELSE
	l_curr_query := '';
	l_curr_unapp_query := '';
	END IF;

	IF g_hit_rct_aging = 'Y' THEN
		l_unapp_amount_query := '
			UNION ALL
			-- Query to return unapplied amount for months other than current month
			SELECT /*+ INDEX(f FII_AR_RCT_AGING'|| fii_ar_util_pkg.g_cust_suffix ||'_mv_N1)*/
				v.sequence FII_EFFECTIVE_NUM,
				CASE WHEN v.start_date > :SD_PRIOR THEN
				-sum(f.unapp_amount) ELSE NULL END FII_AR_NET_REC_AMT,
	                        CASE WHEN v.end_date <= last_day(:SD_PRIOR) THEN
				-sum(f.unapp_amount) ELSE NULL END FII_AR_NET_REC_PRIOR_AMT,
				NULL FII_AR_BILLED_AMT,
				NULL FII_AR_BILLED_PRIOR_AMT,
				NULL inv_amount, NULL dm_amount, NULL cb_amount, NULL br_amount, NULL dep_amount
			FROM
				fii_ar_rct_aging' || fii_ar_util_pkg.g_cust_suffix || '_mv' || fii_ar_util_pkg.g_curr_suffix || ' f,
				(
					SELECT /*+ no_merge cardinality(gt 1) */ *
					FROM fii_ar_summary_gt gt,
					(
						SELECT /*+ no_merge INDEX(cal FII_TIME_STRUCTURES_N1) */ per.sequence, cal.time_id, cal.period_type_id, per.start_date, per.end_date, cal.record_type_id
						FROM fii_time_ent_period per, fii_time_structures cal
						WHERE 	per.start_date > :SD_PRIOR_PRIOR AND per.end_date	<= :ASOF_DATE
							AND cal.report_date = per.end_date
							AND (bitand(cal.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE)
					) cal_per
				) v
			WHERE
				f.time_id 		= v.time_id
				AND f.period_type_id 	= v.period_type_id
				AND f.org_id 		= v.org_id
				AND '||fii_ar_util_pkg.get_rct_mv_where_statement||' ' || l_child_party_where || '
				' || l_industry_where || '
			GROUP BY v.sequence, v.start_date, v.end_date, v.record_type_id';
	ELSE
		l_unapp_amount_query := '';
	END IF;

	sqlstmt := '
	SELECT
		cy_per.name 											VIEWBY,
		round(sum(FII_AR_NET_REC_AMT)  * :DSO_PERIOD / NULLIF(sum(FII_AR_BILLED_AMT),0)) 		FII_AR_DSO,
		sum(FII_AR_NET_REC_AMT) 									FII_AR_NET_REC_AMT,
		sum(FII_AR_BILLED_AMT) 										FII_AR_BILLED_AMT,
		round(sum(FII_AR_NET_REC_AMT) * :DSO_PERIOD / NULLIF(sum(FII_AR_BILLED_AMT),0)) 		FII_AR_DSO_G,
		round(sum(FII_AR_NET_REC_PRIOR_AMT)  * :DSO_PERIOD / NULLIF(sum(FII_AR_BILLED_PRIOR_AMT),0)) 	FII_AR_PRIOR_DSO_G,
		round(sum(FII_AR_NET_REC_AMT)  * :DSO_PERIOD / NULLIF(sum(FII_AR_BILLED_AMT),0)) 		FII_AR_CURRENT_DSO_G,
		CASE WHEN :ASOF_DATE >= cy_per.start_date AND :ASOF_DATE <= cy_per.end_date THEN
			DECODE(' || g_open_rec_column_dsot || ', 0, '''', ''' || l_net_rec_sum_drill || ''')
		ELSE
			''AS_OF_DATE=''|| to_char(cy_per.end_date,''DD/MM/YYYY'')||''&pFunctionName=FII_AR_NET_REC_SUM&VIEW_BY=ORGANIZATION+FII_OPERATING_UNITS&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID''
		END 												FII_AR_NET_REC_AMT_DRILL
	FROM
		fii_time_ent_period cy_per,
		(
			-- Query to return data for months other than current month
			SELECT /*+ INDEX(f FII_AR_NET_REC'|| fii_ar_util_pkg.g_cust_suffix ||'_mv_N1)*/
				v.sequence FII_EFFECTIVE_NUM,
				CASE WHEN v.start_date > :SD_PRIOR AND bitand(v.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE THEN
					' || l_net_rec_column || '
				ELSE
					NULL
				END FII_AR_NET_REC_AMT,
	                        CASE WHEN v.end_date <= last_day(:SD_PRIOR) AND bitand(v.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE THEN
					' || l_net_rec_column || '
				ELSE
					NULL
				END FII_AR_NET_REC_PRIOR_AMT,
                      		CASE WHEN v.start_date > :SD_PRIOR AND bitand(v.record_type_id, :DSO_BITAND) = :DSO_BITAND THEN
					sum(f.billed_amount)
				ELSE
					NULL
				END FII_AR_BILLED_AMT,
                      		CASE WHEN v.end_date <= last_day(:SD_PRIOR) AND bitand(v.record_type_id, :DSO_BITAND) = :DSO_BITAND THEN
					sum(f.billed_amount)
				ELSE
					NULL
				END FII_AR_BILLED_PRIOR_AMT,
				sum(f.inv_amount) inv_amount, sum(f.dm_amount) dm_amount, sum(f.cb_amount) cb_amount, sum(f.br_amount) br_amount, sum(f.dep_amount) dep_amount
			FROM
				fii_ar_net_rec' || fii_ar_util_pkg.g_cust_suffix || '_mv' || fii_ar_util_pkg.g_curr_suffix || ' f,
				(
					SELECT /*+ no_merge cardinality(gt 1) */ *
					FROM fii_ar_summary_gt gt,
					(
						SELECT /*+ no_merge INDEX(cal FII_TIME_STRUCTURES_N1) */ per.sequence, cal.time_id, cal.period_type_id, per.start_date, per.end_date, cal.record_type_id
						FROM fii_time_ent_period per, fii_time_structures cal
						WHERE 	per.start_date > :SD_PRIOR_PRIOR AND per.end_date	<= :ASOF_DATE
							AND cal.report_date = per.end_date
							AND (bitand(cal.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE
								OR bitand(cal.record_type_id, :DSO_BITAND) = :DSO_BITAND)
					) cal_per
				) v
			WHERE
				f.time_id 		= v.time_id
				AND f.period_type_id 	= v.period_type_id
				AND f.org_id 		= v.org_id
				AND '||fii_ar_util_pkg.get_mv_where_statement||' '|| l_child_party_where || '
				' || l_industry_where || '
			GROUP BY v.sequence, v.start_date, v.end_date, v.record_type_id
			' || l_curr_query || '
			' || l_unapp_amount_query || '
			' || l_curr_unapp_query || '
		) inline_query
	WHERE
		cy_per.start_date <= :ASOF_DATE
		AND cy_per.start_date  > :SD_PRIOR
		AND cy_per.sequence = inline_query.fii_effective_num (+)
	GROUP BY inline_query.fii_effective_num, cy_per.sequence, cy_per.start_date, cy_per.name, cy_per.end_date
	ORDER BY cy_per.start_date';

	-- Calling the bind_variable API
	fii_ar_util_pkg.bind_variable(
		p_sqlstmt 		=> sqlstmt,
		p_Page_parameter_tbl 	=> p_page_parameter_tbl,
		p_sql_output 		=> p_dso_sql,
		p_bind_output_table 	=> p_dso_output
	);

END get_dso_trend;

END fii_ar_dso_pkg;


/
