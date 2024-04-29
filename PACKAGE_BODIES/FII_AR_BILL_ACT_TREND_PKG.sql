--------------------------------------------------------
--  DDL for Package Body FII_AR_BILL_ACT_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_BILL_ACT_TREND_PKG" AS
/*  $Header: FIIARDBIBATB.pls 120.3.12000000.2 2007/04/09 20:22:27 vkazhipu ship $ */

--   This package will provide sql statements to retrieve data for Billing Activity


FUNCTION get_view_by return VARCHAR2 IS
BEGIN

IF (fii_ar_util_pkg.g_page_period_type = 'FII_TIME_WEEK') THEN
 return  FND_MESSAGE.GET_STRING('FII','FII_AR_DBI_WEEK');
ELSIF  (fii_ar_util_pkg.g_page_period_type = 'FII_TIME_ENT_PERIOD') THEN
 return FND_MESSAGE.GET_STRING('FII','FII_AR_DBI_MONTH');
ELSIF  (fii_ar_util_pkg.g_page_period_type = 'FII_TIME_ENT_QTR') THEN
 return FND_MESSAGE.GET_STRING('FII','FII_AR_DBI_QUARTER');
ELSE
 return FND_MESSAGE.GET_STRING('FII','FII_AR_DBI_YEAR');
END IF;

END get_view_by;


PROCEDURE get_billing_act_trend (
  p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL, bill_act_trend_sql out NOCOPY VARCHAR2,
  bill_trend_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sql_stmt			VARCHAR2(30000);

  l_org_where                   VARCHAR2(30);
  l_industry_where              VARCHAR2(240);
  l_where_clause                VARCHAR2(1000);
  l_child_party_where           VARCHAR2(60);


  l_time_dim_ltc              VARCHAR2(120);
  l_period_type               VARCHAR2(30);

  l_start_date                VARCHAR2(30);
  l_end_date                  VARCHAR2(30);

BEGIN


    /* Reset Global Variables */
    fii_ar_util_pkg.reset_globals;

     /* Get the parameters that the user has selected */
  fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);

 /* Populate the dimension combination(s) that the user has access to */
  fii_ar_util_pkg.populate_summary_gt_tables;



IF (fii_ar_util_pkg.g_party_id <> '-111') THEN
    l_child_party_where := ' AND f.party_id   = cal.party_id ';
END IF;


IF fii_ar_util_pkg.g_industry_id <> '-111'  THEN

      l_industry_where := ' and f.class_code=cal.class_code and f.class_category=cal.class_category';

END IF;

    l_org_where := ' and f.org_id=cal.org_id';

-- The below mentioned variable will make the code easy to understand.
  l_where_clause := l_child_party_where||l_org_where||l_industry_where;

  /* Find out which time dimension level table needs to be hit.
     This is based on the period type chosen */
   l_period_type := fii_ar_util_pkg.g_page_period_type;


 IF ( l_period_type = 'FII_TIME_WEEK') THEN
        l_time_dim_ltc := 'FII_TIME_WEEK';
 ELSIF (l_period_type = 'FII_TIME_ENT_PERIOD') THEN
        l_time_dim_ltc := 'FII_TIME_ENT_PERIOD';
 ELSIF (l_period_type = 'FII_TIME_ENT_QTR') THEN
        l_time_dim_ltc := 'FII_TIME_ENT_QTR';
 ELSE
        l_time_dim_ltc := 'FII_TIME_ENT_YEAR';
 END IF;


l_sql_stmt := 'SELECT per.name VIEWBY,
                      per.name FII_AR_VIEWBY,
		      TO_CHAR(per.end_date,''DD/MM/YYYY'')    FII_AR_PERIOD_END_DATE,
		      SUM(FII_AR_BILL_ACT_AMT) FII_AR_BILL_ACT_AMT,
                      SUM(FII_AR_BILL_ACT_COUNT) FII_AR_BILL_ACT_COUNT,
                      SUM(FII_AR_BILL_ACT_AMT_PRIOR) FII_AR_BILL_ACT_AMT_PRIOR ,
                      SUM(FII_AR_BILL_ACT_COUNT_PRIOR) FII_AR_BILL_ACT_COUNT_PRIOR ,
                      DECODE(nvl(SUM(FII_AR_BILL_ACT_AMT),0),0,NULL,
		                     DECODE(SIGN(per.end_date - :ASOF_DATE),1,
                                        ''&pFunctionName=FII_AR_BILL_ACT_TRX_CLASS&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+FII_OPERATING_UNITS&pParamIds=Y'',
                                        ''AS_OF_DATE=FII_AR_PERIOD_END_DATE&pFunctionName=FII_AR_BILL_ACT_TRX_CLASS&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+FII_OPERATING_UNITS&pParamIds=Y'')) FII_AR_BILL_ACT_AMT_DRILL
               FROM ( SELECT cal.name NAME ,
	                     cal.end_date END_DATE,
	                     cal.start_date START_DATE,
	                     cal.sequence SEQUENCE, ';

IF l_period_type = 'FII_TIME_ENT_YEAR' THEN
      l_sql_stmt := l_sql_stmt ||' f.inv_ba_amount+f.dm_ba_amount+f.cb_ba_amount
                                   +f.br_ba_amount+f.dep_ba_amount + f.cm_ba_amount FII_AR_BILL_ACT_AMT,
                                  f.inv_ba_count+f.dm_ba_count+f.cb_ba_count
                                   +f.br_ba_count+f.dep_ba_count + f.cm_ba_count FII_AR_BILL_ACT_COUNT,
				   NULL FII_AR_BILL_ACT_AMT_PRIOR,
				   NULL FII_AR_BILL_ACT_COUNT_PRIOR ';
      l_start_date := ' :SD_PRIOR ';

ELSE
     l_sql_stmt := l_sql_stmt ||' CASE WHEN cal.report_date >= :SD_SDATE THEN
			            f.inv_ba_amount+f.dm_ba_amount+f.cb_ba_amount
                                     +f.br_ba_amount+f.dep_ba_amount + f.cm_ba_amount
			          ELSE
			            NULL
			          END FII_AR_BILL_ACT_AMT,
			          CASE WHEN cal.report_date >= :SD_SDATE THEN
			            f.inv_ba_count+f.dm_ba_count+f.cb_ba_count
                                     +f.br_ba_count+f.dep_ba_count + f.cm_ba_count
			          ELSE
			            NULL
			          END FII_AR_BILL_ACT_COUNT, ';
          IF fii_ar_util_pkg.g_time_comp = 'SEQUENTIAL' THEN
	           l_sql_stmt := l_sql_stmt || 'NULL FII_AR_BILL_ACT_AMT_PRIOR,
				                NULL FII_AR_BILL_ACT_COUNT_PRIOR ';
		   l_start_date := ' :SD_PRIOR ';
	  ELSE
		   l_sql_stmt := l_sql_stmt ||'  CASE WHEN cal.report_date < :SD_SDATE THEN
			            f.inv_ba_amount+f.dm_ba_amount+f.cb_ba_amount
                                     +f.br_ba_amount+f.dep_ba_amount + f.cm_ba_amount
			          ELSE
			            NULL
			          END FII_AR_BILL_ACT_AMT_PRIOR,
			          CASE WHEN cal.report_date < :SD_SDATE THEN
			            f.inv_ba_count+f.dm_ba_count+f.cb_ba_count
                                     +f.br_ba_count+f.dep_ba_count + f.cm_ba_count
			          ELSE
			            NULL
			          END FII_AR_BILL_ACT_COUNT_PRIOR ';
	  END IF;
     l_start_date := ' :SD_PRIOR_PRIOR ';
END IF;

      l_sql_stmt:= l_sql_stmt || ' FROM fii_ar_billing_act'||fii_ar_util_pkg.g_cust_suffix ||'_mv'|| fii_ar_util_pkg.g_curr_suffix ||' f,
                                       (SELECT /*+no_merge INDEX(cal FII_TIME_STRUCTURES_N1) leading(gt) cardinality(gt 1)*/ *
				        FROM fii_ar_summary_gt gt,
					     fii_time_structures cal,
					           '||l_time_dim_ltc||' per
					           WHERE
					           BITAND(cal.record_type_id, :BITAND) = :BITAND
					           and per.end_date = cal.report_date
					           and per.start_date < ';

					       	IF fii_ar_util_pkg.g_as_of_date = fii_ar_util_pkg.g_curr_per_end THEN
   									l_end_date := ' :ASOF_DATE';
									ELSE
   									l_end_date := ' :CURR_PERIOD_START';
									END IF;

									l_sql_stmt := l_sql_stmt || l_end_date || ' AND per.start_date >= '|| l_start_date ||') cal ';

			l_sql_stmt := l_sql_stmt ||'  WHERE f.time_id=cal.time_id
				 AND f.period_type_id=cal.period_type_id ' ||l_where_clause;


  IF fii_ar_util_pkg.g_as_of_date <> fii_ar_util_pkg.g_curr_per_end THEN
    l_sql_stmt := l_sql_stmt||' UNION ALL
                         SELECT per.name NAME,
			        per.end_date END_DATE,
				per.start_date START_DATE,
				per.sequence SEQUENCE,
                                f.inv_ba_amount+f.dm_ba_amount+f.cb_ba_amount
                                   +f.br_ba_amount+f.dep_ba_amount + f.cm_ba_amount FII_AR_BILL_ACT_AMT,
                                f.inv_ba_count+f.dm_ba_count+f.cb_ba_count
                                   +f.br_ba_count+f.dep_ba_count + f.cm_ba_count FII_AR_BILL_ACT_COUNT,
                                NULL FII_AR_BILL_ACT_AMT_PRIOR,
				NULL FII_AR_BILL_ACT_COUNT_PRIOR
                         FROM '||l_time_dim_ltc ||' per,
			      fii_ar_billing_act'||fii_ar_util_pkg.g_cust_suffix ||'_mv'|| fii_ar_util_pkg.g_curr_suffix ||' f,
                              ( SELECT  /*+no_merge leading(gt) cardinality(gt 1)*/ *
			        FROM fii_time_structures cal,
				     fii_ar_summary_gt gt
                                WHERE cal.report_date = :ASOF_DATE
                                  AND BITAND(cal.record_type_id, :BITAND) = :BITAND ) cal
                         WHERE f.time_id=cal.time_id
			 AND f.period_type_id=cal.period_type_id
			 AND per.end_date = :CURR_PERIOD_END '|| l_where_clause;
 END IF;

 l_sql_stmt := l_sql_stmt|| ' ) inline_view , '||l_time_dim_ltc||' per
               WHERE per.start_date > :SD_PRIOR
	         AND per.start_date <= :ASOF_DATE
		 AND per.sequence=inline_view.sequence(+)
	      GROUP BY per.name,per.end_date,per.start_date
              ORDER BY per.start_date ';

    /* Pass back the pmv sql along with bind variables to PMV */
    fii_ar_util_pkg.bind_variable(l_sql_stmt, p_page_parameter_tbl, bill_act_trend_sql, bill_trend_output);




END get_billing_act_trend;



END ;


/
