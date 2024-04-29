--------------------------------------------------------
--  DDL for Package Body FII_AR_DISCOUNT_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_DISCOUNT_SUMMARY_PKG" AS
/*  $Header: FIIARDBIDSUMB.pls 120.11 2007/05/15 20:49:25 vkazhipu ship $ */

-- This package will provide SQL statements to retrieve data for Discount Summary report

PROCEDURE get_discount_summary( p_page_parameter_tbl      IN BIS_PMV_PAGE_PARAMETER_TBL
                               ,p_discount_summary_sql    OUT NOCOPY VARCHAR2
			       ,p_discount_summary_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
			      ) IS

  l_sqlstmt                     VARCHAR2(30000);

-- Variables for where clauses
  l_industry_where              VARCHAR2(500);
  l_party_where 		VARCHAR2(500);
  l_child_party_where 		VARCHAR2(500);
  l_cust_acct_where 		VARCHAR2(500);

-- Variables for drills
  l_viewby_drill		VARCHAR2(5000);
  l_discount_amt_drill		VARCHAR2(2000);
  l_discount_amt_detail_drill   VARCHAR2(2000);
  l_discount_amt_final_drill	VARCHAR2(5000);
  l_app_rec_amt_drill		VARCHAR2(2000);
  l_app_rec_amt_detail_drill	VARCHAR2(2000);
  l_app_rec_amt_final_drill	VARCHAR2(5000);
  l_days_paid_drill   		VARCHAR2(5000);
  l_days_paid_drill_1   		VARCHAR2(5000);
  l_discount_amt_drill_1		VARCHAR2(2000);
  l_app_rec_amt_drill_1		VARCHAR2(2000);

-- Only for viewby Customer
  l_inner_cust_columns		VARCHAR2(2000);

-- For Order by Clause
  l_order_by			VARCHAR2(500);
  l_order_column		VARCHAR2(500);
  l_gt_hint varchar2(500);
BEGIN
-- Call to reset the parameter variables
  fii_ar_util_pkg.reset_globals;

-- Call to get all the parameters in the report
  fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);
l_gt_hint := ' leading(gt) cardinality(gt 1) ';
-- Frame the order by clause for the report sql
  IF(INSTR(fii_ar_util_pkg.g_order_by,',') <> 0) THEN

  -- Above means that more than one column is sortable on the report
  -- So, sort on the default column, FII_AR_DISCOUNT_AMT in descending order
  -- NVL is added to make sure the null values appear last

   l_order_by := 'ORDER BY NVL(FII_AR_DISCOUNT_AMT, -999999999) DESC';

  ELSIF(INSTR(fii_ar_util_pkg.g_order_by, ' DESC') <> 0)THEN

  -- Above means that a particular sort column is clicked to have descending order
  -- Here, all the null values should appear last on the report

   l_order_column := SUBSTR(fii_ar_util_pkg.g_order_by,1,INSTR(fii_ar_util_pkg.g_order_by, ' DESC'));
   l_order_by := 'ORDER BY NVL('|| l_order_column ||', -999999999) DESC';

  ELSE

  -- Following is the case when a sort in ascending order is chosen.
  -- Following variable is provided by PMV

   l_order_by := '&ORDER_BY_CLAUSE';

  END IF;

  -- Call to populate fii_ar_summary_gt table

  fii_ar_util_pkg.populate_summary_gt_tables;

  -- Assigning VIEWBY drill to NULL

  l_viewby_drill := '''''';

 -- Defining industry where clause for specific industry or when viewby is Industry
 IF (fii_ar_util_pkg.g_industry_id <> '-111' AND fii_ar_util_pkg.g_view_by <> 'CUSTOMER+FII_CUSTOMERS') OR
       fii_ar_util_pkg.g_view_by = 'FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS' THEN

	l_industry_where :=  ' AND time.class_code = f.class_code AND time.class_category = f.class_category';
 END IF;

 -- Customer Dimension where clause
 IF (fii_ar_util_pkg.g_party_id <> '-111' OR fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMERS') THEN
  l_child_party_where := ' AND f.party_id   = time.party_id ';
 END IF;

-- Defining drills for Discount Amount, Applied Receipt Amount and Days Paid column shown on the report

   l_discount_amt_drill := 'pFunctionName=FII_AR_DISCOUNT_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
   l_discount_amt_detail_drill := 'pFunctionName=FII_AR_APP_RCT_ACT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
   l_app_rec_amt_drill  := 'pFunctionName=FII_AR_REC_ACTIVITY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
   l_app_rec_amt_detail_drill := 'pFunctionName=FII_AR_APP_RCT_ACT_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
   l_days_paid_drill    := 'pFunctionName=FII_AR_COLL_EFFECTIVENESS&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';

-- Done for drill to detailed reports
IF fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS' THEN
   l_gt_hint := ' leading(gt.gt) cardinality(gt.gt 1) ';
   l_discount_amt_detail_drill := 'pFunctionName=FII_AR_APP_RCT_ACT_DTL&BIS_PMV_DRILL_CODE_FII_CUSTOMER_ACCOUNT=VIEWBYID&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||inner_view.party_id||''&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
   l_app_rec_amt_detail_drill := 'pFunctionName=FII_AR_APP_RCT_ACT_DTL&BIS_PMV_DRILL_CODE_FII_CUSTOMER_ACCOUNT=VIEWBYID&BIS_PMV_DRILL_CODE_CUSTOMER+FII_CUSTOMERS=''||inner_view.party_id||''&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
END IF;

-- Select, where, group by clauses based on viewby
IF((fii_ar_util_pkg.g_view_by = 'ORGANIZATION+FII_OPERATING_UNITS')
		OR (fii_ar_util_pkg.g_view_by = 'FII_TRADING_PARTNER_CLASS+FII_TRADING_PARTNER_MKT_CLASS')) THEN
   IF (fii_ar_util_pkg.g_party_id <> '-111') THEN
    l_discount_amt_drill_1 := 'pFunctionName=FII_AR_DISCOUNT_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
    l_app_rec_amt_drill_1 := 'pFunctionName=FII_AR_REC_ACTIVITY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
    l_days_paid_drill_1 := 'pFunctionName=FII_AR_COLL_EFFECTIVENESS&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMER_ACCOUNTS&pParamIds=Y';
   ELSE
    l_discount_amt_drill_1 := 'pFunctionName=FII_AR_DISCOUNT_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
    l_app_rec_amt_drill_1 := 'pFunctionName=FII_AR_REC_ACTIVITY&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
    l_days_paid_drill_1 := 'pFunctionName=FII_AR_COLL_EFFECTIVENESS&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
   END IF;

   l_discount_amt_final_drill := ''''||l_discount_amt_drill_1||'''';
   l_app_rec_amt_final_drill := ''''||l_app_rec_amt_drill_1||'''';
   l_days_paid_drill := l_days_paid_drill_1;
  ELSIF(fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS') THEN
     l_discount_amt_final_drill := ''''||l_discount_amt_detail_drill||'''';

     l_app_rec_amt_final_drill := ''''||l_app_rec_amt_detail_drill||'''';

     l_days_paid_drill := '';  -- Disabling drill on Weighted Average Days Paid column

  -- WHERE clause for Customer Account
     l_cust_acct_where := 'AND f.cust_account_id = time.cust_account_id';

  ELSIF(fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMERS') THEN
	IF (fii_ar_util_pkg.g_is_hierarchical_flag = 'Y') THEN
	    l_discount_amt_final_drill :=
		'CASE WHEN is_self_flag = ''Y'' OR is_leaf_flag =  ''Y''
		         THEN '''||l_discount_amt_detail_drill||'''
                 ELSE '''||l_discount_amt_drill||'''
                  END';

	    l_app_rec_amt_final_drill :=
		'CASE WHEN is_self_flag = ''Y'' OR is_leaf_flag =  ''Y''
		         THEN '''||l_app_rec_amt_detail_drill||'''
	         ELSE '''||l_app_rec_amt_drill||'''
		 END';

	-- Self drill. Reqd only in case of Viewby Customer
        -- Check dynamically if the node is leaf or not. In case of Non-Leaf Node, following drill is to be enabled.

           l_viewby_drill := 'pFunctionName=FII_AR_DISCOUNT_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y';
	   l_viewby_drill := 'CASE WHEN is_self_flag = ''Y'' OR is_leaf_flag = ''Y''
	                      THEN ''''
			      ELSE '''||l_viewby_drill||'''
			       END';
	ELSE
	    l_discount_amt_final_drill := ''''||l_discount_amt_detail_drill||'''';

	    l_app_rec_amt_final_drill := ''''||l_app_rec_amt_detail_drill||'''';

	END IF;

        -- SELECT clause, GROUP BY clause and WHERE clause for Customer Dimension
	   l_inner_cust_columns := ',is_self_flag, is_leaf_flag';
           l_party_where := 'AND f.parent_party_id = time.parent_party_id';

  END IF;

-- Included party_id which is passed on the DRILL to detailed reports

  IF fii_ar_util_pkg.g_view_by = 'CUSTOMER+FII_CUSTOMER_ACCOUNTS' THEN
     l_inner_cust_columns := l_inner_cust_columns || ' ,time.party_id';
  END IF;

-- PMV SQL to display data on Discount Summary Report

l_sqlstmt :=
	'SELECT  inner_view.viewby	 VIEWBY
	        ,viewby_id		 VIEWBYID
		,FII_AR_DISCOUNT_AMT
		,(FII_AR_DISCOUNT_AMT - (FII_AR_PRIOR_UNEARNED_DISC_AMT + FII_AR_PRIOR_EARNED_DISC_AMT))*100
			/NULLIF((FII_AR_PRIOR_UNEARNED_DISC_AMT + FII_AR_PRIOR_EARNED_DISC_AMT),0)
												FII_AR_DISCOUNT_CHANGE
		,FII_AR_APP_REC_PERCENT
		,FII_AR_EARNED_DISC_PERCENT
		,FII_AR_EARNED_DISC_AMT
		,(FII_AR_EARNED_DISC_AMT - FII_AR_PRIOR_EARNED_DISC_AMT)*100
			/NULLIF(FII_AR_PRIOR_EARNED_DISC_AMT,0)					FII_AR_EARNED_DISC_CHANGE
		,FII_AR_UNEARNED_DISC_PERCENT
		,FII_AR_UNEARNED_DISC_AMT
		,(FII_AR_UNEARNED_DISC_AMT - FII_AR_PRIOR_UNEARNED_DISC_AMT)*100
				/NULLIF(FII_AR_PRIOR_UNEARNED_DISC_AMT,0)			FII_AR_UNEARNED_DISC_CHANGE
		,FII_AR_APP_REC_AMT
		,FII_AR_WTD_DAYS_PAID/NULLIF(FII_AR_APP_REC_AMT,0)				FII_AR_DAYS_PAID
		,FII_AR_WTD_TERMS_PAID/NULLIF(FII_AR_APP_REC_AMT,0)				FII_AR_TERMS_PAID
		,SUM (FII_AR_DISCOUNT_AMT) OVER ()						FII_AR_GT_DISCOUNT_AMT
		,(SUM(FII_AR_DISCOUNT_AMT) OVER () - (SUM(FII_AR_PRIOR_UNEARNED_DISC_AMT) OVER ()
				+ SUM(FII_AR_PRIOR_EARNED_DISC_AMT) OVER ()))*100
			/NULLIF((SUM(FII_AR_PRIOR_UNEARNED_DISC_AMT) OVER () + SUM(FII_AR_PRIOR_EARNED_DISC_AMT) OVER ()),0)
												FII_AR_GT_DISCOUNT_CHANGE
		,(SUM(FII_AR_UNEARNED_DISC_AMT) OVER () + SUM(FII_AR_EARNED_DISC_AMT) OVER ())*100
			/NULLIF(SUM(FII_AR_APP_REC_AMT) OVER (),0)				FII_AR_GT_APP_REC_PERCENT
		,SUM(FII_AR_EARNED_DISC_AMT) OVER ()*100
			/NULLIF((SUM(FII_AR_UNEARNED_DISC_AMT) OVER () + SUM(FII_AR_EARNED_DISC_AMT) OVER ()),0)
												FII_AR_GT_EARNED_DISC_PERCENT
		,SUM(FII_AR_EARNED_DISC_AMT) OVER ()						FII_AR_GT_EARNED_DISC_AMT
		,(SUM(FII_AR_EARNED_DISC_AMT) OVER () - SUM(FII_AR_PRIOR_EARNED_DISC_AMT) OVER ())*100
				/NULLIF(SUM(FII_AR_PRIOR_EARNED_DISC_AMT) OVER (),0)		FII_AR_GT_EARNED_DISC_CHANGE
		,SUM(FII_AR_UNEARNED_DISC_AMT) OVER ()*100
				/NULLIF((SUM(FII_AR_UNEARNED_DISC_AMT) OVER () + SUM(FII_AR_EARNED_DISC_AMT) OVER ()),0)
												FII_AR_GT_UNEARN_DISC_PERCENT
		,SUM(FII_AR_UNEARNED_DISC_AMT) OVER ()						FII_AR_GT_UNEARN_DISC_AMT
		,(SUM(FII_AR_UNEARNED_DISC_AMT) OVER () - SUM(FII_AR_PRIOR_UNEARNED_DISC_AMT) OVER ())*100
			/NULLIF(SUM(FII_AR_PRIOR_UNEARNED_DISC_AMT) OVER (),0)			FII_AR_GT_UNEARN_DISC_CHANGE
		,SUM(FII_AR_APP_REC_AMT) OVER ()						FII_AR_GT_APP_REC_AMT
		,SUM(FII_AR_WTD_DAYS_PAID) OVER ()/NULLIF(SUM(FII_AR_APP_REC_AMT) OVER (),0)	FII_AR_GT_DAYS_PAID
		,SUM(FII_AR_WTD_TERMS_PAID) OVER ()/NULLIF(SUM(FII_AR_APP_REC_AMT) OVER (),0)	FII_AR_GT_TERMS_PAID
		,FII_AR_PRIOR_UNEARNED_DISC_AMT
		,FII_AR_PRIOR_EARNED_DISC_AMT
		,FII_AR_PRIOR_APP_REC_PERCENT
		,CASE WHEN FII_AR_DISCOUNT_AMT = 0 OR FII_AR_DISCOUNT_AMT IS NULL THEN NULL
		 ELSE '||l_discount_amt_final_drill||'
		  END										FII_AR_DISCOUNT_AMT_DRILL
		,CASE WHEN FII_AR_APP_REC_AMT = 0 OR FII_AR_APP_REC_AMT IS NULL THEN NULL
		 ELSE '||l_app_rec_amt_final_drill||'
		  END										FII_AR_APP_REC_AMT_DRILL
		,CASE WHEN FII_AR_WTD_DAYS_PAID/NULLIF(FII_AR_APP_REC_AMT,0) = 0
			   OR FII_AR_WTD_DAYS_PAID/NULLIF(FII_AR_APP_REC_AMT,0) IS NULL THEN NULL
		 ELSE '''||l_days_paid_drill||'''
		  END										FII_AR_DAYS_PAID_DRILL
		,'||l_viewby_drill||'								FII_AR_VIEW_BY_DRILL
	  FROM
	       (SELECT  /*+ INDEX(f FII_AR_NET_REC'|| fii_ar_util_pkg.g_cust_suffix ||'_mv_N1)*/  VIEWBY
			,time.viewby_code   viewby_id
			'||l_inner_cust_columns||'
			,SUM(CASE WHEN report_date = :ASOF_DATE THEN unearned_discount_amount
			       ELSE NULL END) + SUM(CASE WHEN report_date = :ASOF_DATE THEN earned_discount_amount
			                               ELSE NULL END)				FII_AR_DISCOUNT_AMT
			,SUM(CASE WHEN report_date = :PREVIOUS_ASOF_DATE
			        THEN unearned_discount_amount ELSE NULL END)			FII_AR_PRIOR_UNEARNED_DISC_AMT
			,SUM(CASE WHEN report_date = :PREVIOUS_ASOF_DATE THEN earned_discount_amount
				ELSE NULL END)							FII_AR_PRIOR_EARNED_DISC_AMT
			,(SUM(CASE WHEN report_date = :ASOF_DATE THEN unearned_discount_amount ELSE NULL END)
			          + SUM(CASE WHEN report_date = :ASOF_DATE THEN earned_discount_amount ELSE NULL END))*100
				/NULLIF(SUM(CASE WHEN report_date = :ASOF_DATE THEN app_amount ELSE NULL END),0)
												FII_AR_APP_REC_PERCENT
			,SUM(CASE WHEN report_date = :ASOF_DATE THEN earned_discount_amount ELSE NULL END)*100
				/NULLIF((SUM(CASE WHEN report_date = :ASOF_DATE THEN unearned_discount_amount
				         ELSE NULL END) + SUM(CASE WHEN report_date = :ASOF_DATE
						THEN earned_discount_amount ELSE NULL END)),0)
												FII_AR_EARNED_DISC_PERCENT
			,SUM(CASE WHEN report_date = :ASOF_DATE THEN earned_discount_amount
					ELSE NULL END)						FII_AR_EARNED_DISC_AMT
			,SUM(CASE WHEN report_date = :ASOF_DATE THEN unearned_discount_amount ELSE NULL END)*100
				/NULLIF((SUM(CASE WHEN report_date = :ASOF_DATE THEN unearned_discount_amount ELSE NULL END)
					+ SUM(CASE WHEN report_date = :ASOF_DATE THEN earned_discount_amount ELSE NULL END)),0)
												FII_AR_UNEARNED_DISC_PERCENT
			,SUM(CASE WHEN report_date = :ASOF_DATE THEN unearned_discount_amount
						ELSE NULL END)					FII_AR_UNEARNED_DISC_AMT
			,SUM(CASE WHEN report_date = :ASOF_DATE THEN app_amount ELSE NULL END)	FII_AR_APP_REC_AMT
			,SUM(CASE WHEN report_date = :ASOF_DATE THEN wtd_days_paid_num
					ELSE NULL END)						FII_AR_WTD_DAYS_PAID
			,SUM(CASE WHEN report_date = :ASOF_DATE THEN wtd_terms_paid_num
					ELSE NULL END)						FII_AR_WTD_TERMS_PAID
			,(SUM(CASE WHEN report_date = :PREVIOUS_ASOF_DATE THEN unearned_discount_amount ELSE NULL END)
					+ SUM(CASE WHEN report_date = :PREVIOUS_ASOF_DATE THEN earned_discount_amount ELSE NULL END))*100
				/NULLIF(SUM(CASE WHEN report_date = :PREVIOUS_ASOF_DATE THEN app_amount ELSE NULL END),0)
												FII_AR_PRIOR_APP_REC_PERCENT
		   FROM fii_ar_net_rec'||fii_ar_util_pkg.g_cust_suffix||'_mv'||fii_ar_util_pkg.g_curr_suffix||'  f
		       ,(SELECT /*+ no_merge '||l_gt_hint|| ' */  cal.time_id         time_id
		               ,cal.period_type_id  period_type_id
			       ,cal.report_date     report_date
			       ,gt.*        -- Picking all the columns from Security table -- parent_party_id,party_id,org_id,
			                    -- collector_id, is_leaf_flag,class_code,class_category,viewby, viewby_code
			   FROM fii_time_structures	cal
                               ,'||fii_ar_util_pkg.get_from_statement||'   gt  -- Security table
		          WHERE report_date IN (:ASOF_DATE,:PREVIOUS_ASOF_DATE)
		            AND BITAND(cal.record_type_id, :BITAND) = :BITAND  -- Bitand value changes with PeriodType
			    AND '||fii_ar_util_pkg.get_where_statement||'
			 )			time
                  WHERE f.time_id = time.time_id
                    AND f.period_type_id = time.period_type_id
                    AND f.org_id = time.org_id
                    AND '||fii_ar_util_pkg.get_mv_where_statement||' '||l_child_party_where||'
		    '||l_cust_acct_where||'
		    '||l_party_where||'
		    '||l_industry_where||'
               GROUP BY time.viewby_code '||l_inner_cust_columns||', VIEWBY
		) inner_view
	'||l_order_by;

-- Call to UTIL package to bind the variables

   fii_ar_util_pkg.bind_variable(l_sqlstmt
                                ,p_page_parameter_tbl
				,p_discount_summary_sql
				,p_discount_summary_output
				);

END get_discount_summary;

END fii_ar_discount_summary_pkg;

/
