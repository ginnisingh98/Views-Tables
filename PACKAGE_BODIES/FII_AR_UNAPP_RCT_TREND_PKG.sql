--------------------------------------------------------
--  DDL for Package Body FII_AR_UNAPP_RCT_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_UNAPP_RCT_TREND_PKG" AS
/*  $Header: FIIARDBIURTB.pls 120.4.12000000.2 2007/04/09 20:16:44 vkazhipu ship $ */

-- This package will provide SQL statements to retrieve data for Unapplied Receipts Trend report

PROCEDURE get_unapp_rct_trend ( p_page_parameter_tbl      IN BIS_PMV_PAGE_PARAMETER_TBL
                               ,p_unapp_rct_trend_sql     OUT NOCOPY VARCHAR2
			       ,p_unapp_rct_trend_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
			      ) IS

  l_sqlstmt                     VARCHAR2(30000);

-- Variables for where clauses
  l_child_party_where 		VARCHAR2(300);
  l_collector_where		VARCHAR2(300);

-- Variables related to TIME table
  l_curr_per_sequence           NUMBER;
  l_curr_end_date		DATE;

-- Variables used for forming PMV SQL when report date <> end date of the month
  l_curr_period_unapp_rec_sql   VARCHAR2(10000);
  l_curr_period_total_rec_sql   VARCHAR2(10000);


BEGIN
  -- Call to reset the parameter variables
  fii_ar_util_pkg.reset_globals;

  -- Call to get all the parameters in the report
  fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);

  -- Call to populate fii_ar_summary_gt table
  fii_ar_util_pkg.populate_summary_gt_tables;

 -- Customer Dimension WHERE clause based on the report parameter
 IF (fii_ar_util_pkg.g_party_id <> '-111') THEN
     l_child_party_where := ' AND f.party_id   = inner_time.party_id ';
 END IF;

 -- Collector Dimension WHERE clause based on the report parameter

  IF (fii_ar_util_pkg.g_collector_id <> '-111') THEN
     l_collector_where := 'AND f.collector_id = inner_time.collector_id';
  END IF;

-- Getting the sequence and the last day of the month corresponding to the REPORT DATE
-- Putting NVL to ensure that SELECT clause doesn't fail when AsOfDate is not available in TIME table

   SELECT NVL(MAX(sequence),0),NVL(MAX(end_date),SYSDATE)
     INTO l_curr_per_sequence,l_curr_end_date
     FROM fii_time_ent_period
    WHERE fii_ar_util_pkg.g_as_of_date BETWEEN start_date AND end_date;

-- Framing SQL statement for the current month for as of date <> end date of the month

 IF fii_ar_util_pkg.g_as_of_date <> l_curr_end_date THEN

  -- Following variable stores the SQL for Unapplied Receipt Amount

     l_curr_period_unapp_rec_sql :=
		'	UNION ALL
		 SELECT	/*+ INDEX(f FII_AR_RCT_AGING_BASE_MV_N1)*/  '||l_curr_per_sequence||'     period_sequence
		       ,f.total_unapplied_amount      FII_AR_UNAPP_REC_AMT
		       ,f.total_unapplied_count       FII_AR_UNAPP_REC_COUNT
		       ,NULL			      FII_AR_PRIOR_UNAPP_REC_AMT
		       ,NULL			      FII_AR_PRIOR_UNAPP_REC_COUNT
		       ,NULL                          FII_AR_TOTAL_REC_AMT
		       ,NULL                          FII_AR_TOTAL_REC_COUNT
		  FROM  fii_ar_rct_aging_base_mv'||fii_ar_util_pkg.g_curr_suffix||'   f
		       ,(SELECT  /*+ no_merge leading(gt) cardinality(gt 1)*/ cal.time_id		time_id
				,cal.period_type_id	period_type_id
				,gt.*
		           FROM fii_time_structures	cal
			       ,fii_ar_summary_gt       gt
			  WHERE cal.report_date = :ASOF_DATE
		            AND BITAND(cal.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE
		        ) inner_time
		 WHERE inner_time.time_id = f.time_id
		   AND inner_time.period_type_id = f.period_type_id
		   AND f.org_id = inner_time.org_id
		   AND '||fii_ar_util_pkg.get_rct_mv_where_statement||' '||l_child_party_where||' '||l_collector_where;

-- Following variable stores the SQL for Total Receipt Amount

     l_curr_period_total_rec_sql :=
		'	UNION ALL
		 SELECT	/*+ INDEX(f FII_AR_NET_REC_BASE_MV_N1)*/  '||l_curr_per_sequence||'  period_sequence
		        ,NULL                      FII_AR_UNAPP_REC_AMT
			,NULL                      FII_AR_UNAPP_REC_COUNT
			,NULL                      FII_AR_PRIOR_UNAPP_REC_AMT
			,NULL                      FII_AR_PRIOR_UNAPP_REC_COUNT
			,CASE WHEN f.header_filter_date > LAST_DAY(ADD_MONTHS(:ASOF_DATE,-1))
			 THEN f.total_receipt_amount
			 ELSE NULL
			  END			   FII_AR_TOTAL_REC_AMT
			,CASE WHEN f.header_filter_date > LAST_DAY(ADD_MONTHS(:ASOF_DATE,-1))
			 THEN f.total_receipt_count
			 ELSE NULL
			  END			   FII_AR_TOTAL_REC_COUNT
		   FROM  fii_ar_net_rec_base_mv'||fii_ar_util_pkg.g_curr_suffix||'   f
			,(SELECT /*+no_merge leading(gt) cardinality(gt 1)*/ cal.time_id		time_id
				,cal.period_type_id	period_type_id
				,gt.*
		            FROM fii_time_structures       cal
			        ,fii_ar_summary_gt         gt
			   WHERE cal.report_date = :ASOF_DATE
		             AND BITAND(cal.record_type_id, :BITAND) =  :BITAND
		         ) inner_time
		  WHERE inner_time.time_id = f.time_id
		    AND inner_time.period_type_id     = f.period_type_id
		    AND f.org_id = inner_time.org_id
		    AND '||fii_ar_util_pkg.get_mv_where_statement||' '||l_child_party_where||' '||l_collector_where;

 END IF;

-- PMV SQL to display data on Unapplied Receipts Trend Report

l_sqlstmt :=
 'SELECT time.name		                      VIEWBY
	,TO_CHAR(time.end_date,''DD/MM/YYYY'')        FII_AR_MONTH_END_DATE
	,FII_AR_UNAPP_REC_AMT
	,FII_AR_UNAPP_REC_COUNT
	,FII_AR_TOTAL_REC_AMT
	,FII_AR_TOTAL_REC_COUNT
-- Drill on Unapplied Receipts Amount column should go to Unapplied Receipts Summary report,VIEWBY = OU
	,CASE WHEN FII_AR_UNAPP_REC_AMT = 0 OR FII_AR_UNAPP_REC_AMT IS NULL THEN NULL
	      WHEN time.end_date < :ASOF_DATE
	      THEN ''AS_OF_DATE=FII_AR_MONTH_END_DATE&pFunctionName=FII_AR_UNAPP_RCT_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+FII_OPERATING_UNITS&pParamIds=Y''
	 ELSE ''pFunctionName=FII_AR_UNAPP_RCT_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+FII_OPERATING_UNITS&pParamIds=Y''
	  END                    FII_AR_UNAPP_REC_AMT_DRILL
-- Drill on Total Receipts Amount column should go to Receipts Activity report,VIEWBY = OU
	,CASE WHEN FII_AR_TOTAL_REC_AMT = 0 OR FII_AR_TOTAL_REC_AMT IS NULL THEN NULL
	      WHEN time.end_date < :ASOF_DATE
	      THEN ''AS_OF_DATE=FII_AR_MONTH_END_DATE&pFunctionName=FII_AR_REC_ACTIVITY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+FII_OPERATING_UNITS&pParamIds=Y''
	 ELSE ''pFunctionName=FII_AR_REC_ACTIVITY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+FII_OPERATING_UNITS&pParamIds=Y''
	  END                    FII_AR_TOTAL_REC_AMT_DRILL
	,FII_AR_PRIOR_UNAPP_REC_AMT
	,FII_AR_PRIOR_UNAPP_REC_COUNT
   FROM
      ( SELECT   inner_inline_view.period_sequence      period_sequence
		,SUM(FII_AR_UNAPP_REC_AMT)		FII_AR_UNAPP_REC_AMT
		,SUM(FII_AR_UNAPP_REC_COUNT)		FII_AR_UNAPP_REC_COUNT
		,SUM(FII_AR_TOTAL_REC_AMT)		FII_AR_TOTAL_REC_AMT
		,SUM(FII_AR_TOTAL_REC_COUNT)		FII_AR_TOTAL_REC_COUNT
		,NULL					FII_AR_UNAPP_REC_AMT_DRILL
		,NULL					FII_AR_TOTAL_REC_AMT_DRILL
		,SUM(FII_AR_PRIOR_UNAPP_REC_AMT)	FII_AR_PRIOR_UNAPP_REC_AMT
		,SUM(FII_AR_PRIOR_UNAPP_REC_COUNT)	FII_AR_PRIOR_UNAPP_REC_COUNT
	   FROM
	       (SELECT /*+ INDEX(f FII_AR_RCT_AGING_BASE_mv_N1)*/ time.sequence		      period_sequence
		      ,CASE WHEN inner_time.report_date  >= :SD_SDATE
		       THEN f.total_unapplied_amount
		       ELSE NULL
			END                           FII_AR_UNAPP_REC_AMT
		      ,CASE WHEN inner_time.report_date  >= :SD_SDATE
			THEN f.total_unapplied_count
			ELSE NULL
			 END                          FII_AR_UNAPP_REC_COUNT
		      ,CASE WHEN inner_time.report_date < :SD_SDATE
			    THEN f.total_unapplied_amount
			ELSE NULL
			 END			      FII_AR_PRIOR_UNAPP_REC_AMT
		      ,CASE WHEN inner_time.report_date < :SD_SDATE
			THEN f.total_unapplied_count
			ELSE NULL
			 END                          FII_AR_PRIOR_UNAPP_REC_COUNT
		       ,NULL                          FII_AR_TOTAL_REC_AMT
		       ,NULL                          FII_AR_TOTAL_REC_COUNT
-- Since VIEWBY is always MONTH, base MV would be used
		  FROM fii_ar_rct_aging_base_mv'||fii_ar_util_pkg.g_curr_suffix||'   f
		      ,fii_time_ent_period       time
		      ,(SELECT  /*+ no_merge leading(gt) cardinality(gt 1)*/ cal.time_id		time_id
			       ,cal.period_type_id	period_type_id
			       ,cal.report_date		report_date
			       ,gt.*
		          FROM fii_time_structures       cal
			      ,fii_ar_summary_gt         gt
			 WHERE report_date IN (SELECT end_date
			                         FROM fii_time_ent_period
						WHERE start_date >= :SD_PRIOR_PRIOR
						  AND end_date <= :ASOF_DATE
					       )
			   AND BITAND(cal.record_type_id,:BITAND_INC_TODATE) = :BITAND_INC_TODATE
			) inner_time
		 WHERE inner_time.time_id = f.time_id
		   AND f.period_type_id = inner_time.period_type_id
		   AND f.org_id = inner_time.org_id
		   AND time.end_date = inner_time.report_date
		   AND '||fii_ar_util_pkg.get_rct_mv_where_statement||' '||l_child_party_where||'
		   '||l_collector_where||'
					UNION ALL
		SELECT /*+ INDEX(f FII_AR_NET_REC_BASE_mv_N1)*/
		inner_time.sequence          period_sequence
		      ,NULL                         FII_AR_UNAPP_REC_AMT
		      ,NULL                         FII_AR_UNAPP_REC_COUNT
		      ,NULL                         FII_AR_PRIOR_UNAPP_REC_AMT
                      ,NULL                         FII_AR_PRIOR_UNAPP_REC_COUNT
		      ,CASE WHEN f.header_filter_date >= inner_time.start_date
		          THEN total_receipt_amount
		       ELSE NULL
		        END			    FII_AR_TOTAL_REC_AMT
		      ,CASE WHEN f.header_filter_date >= inner_time.start_date
		          THEN total_receipt_count
		       ELSE NULL
		        END			    FII_AR_TOTAL_REC_COUNT
		  FROM fii_ar_net_rec_base_mv'||fii_ar_util_pkg.g_curr_suffix||'   f
		       ,(SELECT /*+no_merge leading(gt) cardinality(gt 1)*/ time.ent_period_id	ent_period_id
			       ,time.sequence		sequence
			       ,time.start_date         start_date
		               ,gt.*
		           FROM fii_time_ent_period     time
			       ,fii_ar_summary_gt	gt
			  WHERE time.start_date > :SD_PRIOR  -- Need to Pick only one year data
		            AND time.end_date   <= :ASOF_DATE
			) inner_time
		 WHERE inner_time.ent_period_id = f.time_id
		   AND f.period_type_id = 32
		   AND f.org_id = inner_time.org_id
		   AND '||fii_ar_util_pkg.get_mv_where_statement||' '||l_child_party_where||'
		   '||l_collector_where||''||l_curr_period_unapp_rec_sql||''||l_curr_period_total_rec_sql||'
		) inner_inline_view
	GROUP BY inner_inline_view.period_sequence
      ) inner_view
     ,fii_time_ent_period	time
WHERE time.start_date <= :ASOF_DATE
  AND time.start_date  > :SD_PRIOR
  AND time.sequence = inner_view.period_sequence (+)
-- Outer join to display all the 12 months irrespective of whether data is available or not for those months
ORDER BY time.start_date
';

-- Call to UTIL package to bind the variables

   fii_ar_util_pkg.bind_variable(l_sqlstmt
                                ,p_page_parameter_tbl
				,p_unapp_rct_trend_sql
				,p_unapp_rct_trend_output
				);

END get_unapp_rct_trend;

END fii_ar_unapp_rct_trend_pkg;

/
