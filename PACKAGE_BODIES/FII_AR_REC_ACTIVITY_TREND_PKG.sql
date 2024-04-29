--------------------------------------------------------
--  DDL for Package Body FII_AR_REC_ACTIVITY_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_REC_ACTIVITY_TREND_PKG" AS
/* $Header: FIIARDBIRTB.pls 120.5.12000000.2 2007/04/09 20:20:42 vkazhipu ship $ */

PROCEDURE get_rec_activity_trend (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        open_rec_sql             OUT NOCOPY VARCHAR2,
        open_rec_output          OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS

l_viewby_id 			VARCHAR2(50);
l_viewby			VARCHAR2(250);
l_party_where 			VARCHAR2(250);
l_parent_party_where 		VARCHAR2(250);
l_collector_where		VARCHAR2(250);
l_industry_where		VARCHAR2(500);
l_cust_acct_where		VARCHAR2(250);
l_cust_self_drill		VARCHAR2(500);
l_past_due_rec_drill		VARCHAR2(500);
l_open_rec_drill		VARCHAR2(500);
l_select			VARCHAR2(15000);
l_col_select			VARCHAR2(1000);
l_prior_column			VARCHAR2(500);
l_group_by 			VARCHAR2(100) := NULL;
l_order_by			VARCHAR2(250);
l_order_column			VARCHAR2(250);
l_select_curr_end_prd		VARCHAR2(5000);
l_end_date			VARCHAR2(50);
l_start_date			VARCHAR2(50);
l_per_from 			VARCHAR2(100);

BEGIN

fii_ar_util_pkg.reset_globals;
fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);

/* The call populates the AR global temp table. */
fii_ar_util_pkg.populate_summary_gt_tables;

/* Defining the where clause for PARTY_ID*/
IF fii_ar_util_pkg.g_party_id <> '-111' THEN
	l_party_where := ' AND f.party_id   = time.party_id ';
END IF;

/* Defining the where clause for COLLECTOR_ID*/
IF fii_ar_util_pkg.g_collector_id <> '-111' THEN
	l_collector_where := 'AND f.collector_id = time.collector_id ';
END IF;

/* Defining industry where clause for specific industry */
IF fii_ar_util_pkg.g_industry_id <> '-111' THEN
        l_industry_where :=  ' AND time.class_code = f.class_code AND time.class_category = f.class_category';
END IF;

/* Defining the table to be used based on Period Type chosen.*/
CASE fii_ar_util_pkg.g_page_period_type
WHEN  'FII_TIME_WEEK' THEN
	l_per_from:=' fii_time_week ';
WHEN 'FII_TIME_ENT_PERIOD' THEN
	l_per_from:=' fii_time_ent_period ';
WHEN 'FII_TIME_ENT_QTR' THEN
	l_per_from:=' fii_time_ent_qtr ';
WHEN 'FII_TIME_ENT_YEAR' THEN
	l_per_from:=' fii_time_ent_year ';
END CASE;

/* The select statement checks wethere asofdate chosen is end of current week/month/qtr/year.
If True then no need to add a new select ELSE need to add a select statement to get amount
upto asofdate chosen for the current period. */

IF fii_ar_util_pkg.g_as_of_date = fii_ar_util_pkg.g_curr_per_end THEN
        l_select_curr_end_prd :=' ';
        l_end_date := ' :ASOF_DATE ';

ELSE

   	l_select_curr_end_prd := ' UNION ALL
        /* The select statment will return data for current week/month/qtr/year upto asofdate,
	if asofdate<> last day of period*/
        SELECT
        per.sequence sequence,
	CASE	WHEN	(f.header_filter_date >= per.start_date
			AND f.header_filter_date <= :ASOF_DATE)  THEN
        sum(f.total_receipt_amount) ELSE NULL END    	FII_AR_REC_AMT,
	CASE	WHEN	(f.header_filter_date >= per.start_date
			AND f.header_filter_date <= :ASOF_DATE) THEN
        sum(f.total_receipt_count)  ELSE NULL END      	FII_AR_REC_COUNT,
        sum(f.app_amount)	    		FII_AR_REC_APP_AMT,
        sum(f.app_count)         		FII_AR_REC_APP_COUNT,
        NULL    				FII_AR_PRIOR_REC_AMT
        FROM  '||l_per_from||' per,
              FII_AR_NET_REC'||fii_ar_util_pkg.g_cust_suffix ||'_mv'|| fii_ar_util_pkg.g_curr_suffix ||'  f,
              ( SELECT   *  FROM fii_time_structures cal, '||fii_ar_util_pkg.get_from_statement||' gt
              WHERE report_date = :ASOF_DATE
              AND bitand(cal.record_type_id, :BITAND) = :BITAND
	      AND '||fii_ar_util_pkg.get_where_statement||') time
        WHERE    f.time_id = time.time_id
        AND f.period_type_id = time.period_type_id
        AND f.org_id = time.org_id
        AND '||fii_ar_util_pkg.get_mv_where_statement||' '||l_party_where||l_collector_where||l_industry_where||'
        AND per.end_date = :CURR_PERIOD_END
        GROUP BY report_date, per.sequence, f.header_filter_date, per.start_date
        ';

        l_end_date := ' :CURR_PERIOD_START ';

END IF;

/* This condition handles, wethere parameter compare to chosen is Prior Period and show Prior Data or not. */

IF fii_ar_util_pkg.g_time_comp = 'SEQUENTIAL' THEN
	l_prior_column:= ' NULL FII_AR_PRIOR_REC_AMT ';
	l_start_date := ' :SD_PRIOR ';
ELSE
	IF fii_ar_util_pkg.g_page_period_type = 'FII_TIME_ENT_YEAR' THEN
		l_prior_column:= ' NULL FII_AR_PRIOR_REC_AMT ';
		l_start_date := ' :SD_PRIOR ';
	ELSE
		l_prior_column:= ' CASE	WHEN	time.report_date  <  :SD_SDATE AND f.header_filter_date >= MIN(per.start_date) THEN sum(f.total_receipt_amount) ELSE NULL END	FII_AR_PRIOR_REC_AMT ';
		l_start_date := ' :SD_PRIOR_PRIOR ';
	END IF;
END IF;


IF fii_ar_util_pkg.g_page_period_type = 'FII_TIME_ENT_YEAR' THEN

l_col_select :=	' sum(f.total_receipt_amount) 	FII_AR_REC_AMT,
	sum(f.total_receipt_count) 	FII_AR_REC_COUNT,
	sum(f.app_amount) 		FII_AR_REC_APP_AMT,
	sum(f.app_count) 		FII_AR_REC_APP_COUNT, ';

ELSE

l_col_select :=	' CASE	WHEN	time.report_date  >=  :SD_SDATE
		AND (f.header_filter_date >= MIN(per.start_date)
		AND f.header_filter_date <= time.report_date) THEN
	sum(f.total_receipt_amount) ELSE NULL END 	FII_AR_REC_AMT,
	CASE	WHEN	time.report_date  >=  :SD_SDATE
		AND (f.header_filter_date >= MIN(per.start_date)
		AND f.header_filter_date <= time.report_date) THEN
	sum(f.total_receipt_count) ELSE NULL END 	FII_AR_REC_COUNT,
	CASE	WHEN	time.report_date  >=  :SD_SDATE THEN
	sum(f.app_amount) ELSE NULL END 		FII_AR_REC_APP_AMT,
	CASE	WHEN	time.report_date  >=  :SD_SDATE THEN
	sum(f.app_count) ELSE NULL END 			FII_AR_REC_APP_COUNT, ';
END IF;

/* Final Select statement */

l_select :=
'
SELECT	 cy_per.name                          VIEWBY,
	cy_per.name                          FII_AR_VIEWBY,
	to_char(cy_per.end_date,''DD/MM/YYYY'') FII_AR_PERIOD_END_DATE,
	SUM(FII_AR_REC_AMT) 		FII_AR_REC_AMT,
	SUM(FII_AR_REC_COUNT)  		FII_AR_REC_COUNT,
	SUM(FII_AR_REC_APP_AMT) 	FII_AR_REC_APP_AMT,
	SUM(FII_AR_REC_APP_COUNT)  	FII_AR_REC_APP_COUNT,
	SUM(FII_AR_PRIOR_REC_AMT)	FII_AR_PRIOR_REC_AMT,
	SUM(FII_AR_REC_AMT)		FII_AR_REC_AMT_G,
	DECODE(SUM(FII_AR_REC_AMT),0,NULL,NULL,NULL,DECODE(SIGN(cy_per.end_date - :ASOF_DATE),1,
	''&pFunctionName=FII_AR_REC_ACTIVITY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+FII_OPERATING_UNITS&pParamIds=Y'',
	''AS_OF_DATE=FII_AR_PERIOD_END_DATE&pFunctionName=FII_AR_REC_ACTIVITY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+FII_OPERATING_UNITS&pParamIds=Y'')) FII_AR_REC_AMT_DRILL
FROM
	'||l_per_from||'  cy_per,
	(SELECT /*+ INDEX(f FII_AR_NET_REC'|| fii_ar_util_pkg.g_cust_suffix ||'_mv_N1)*/
	per.sequence sequence,
	'||l_col_select||l_prior_column||'
 	FROM    '||l_per_from||'  per,
	    	FII_AR_NET_REC'||fii_ar_util_pkg.g_cust_suffix ||'_mv'|| fii_ar_util_pkg.g_curr_suffix ||' f,
	    	( SELECT	/*+ no_merge leading(gt) cardinality(gt 1)*/ *  FROM fii_time_structures cal, '||fii_ar_util_pkg.get_from_statement||' gt
		WHERE report_date in
			(SELECT end_date from '||l_per_from||' cy_per WHERE cy_per.start_date <  '||l_end_date||'
			AND   cy_per.start_date  >= '||l_start_date||'  )
 		AND bitand(cal.record_type_id, :BITAND) = :BITAND
		AND '||fii_ar_util_pkg.get_where_statement||') time
	WHERE    f.time_id = time.time_id
	AND f.period_type_id = time.period_type_id
	AND f.org_id = time.org_id
	AND '||fii_ar_util_pkg.get_mv_where_statement||' '||l_party_where||l_collector_where||l_industry_where||'
 	AND per.end_date = time.report_date
	GROUP BY report_date, per.sequence, f.header_filter_date
 '||l_select_curr_end_prd||'
) inline_view
WHERE	cy_per.start_date <= :ASOF_DATE
AND   cy_per.start_date  > :SD_PRIOR
AND   cy_per.sequence = inline_view.sequence (+)
GROUP BY cy_per.name,cy_per.end_date,cy_per.start_date
ORDER BY cy_per.start_date
';


fii_ar_util_pkg.bind_variable(l_select, p_page_parameter_tbl, open_rec_sql, open_rec_output);


END get_rec_activity_trend;

/* This function returns the label for the First column in the report, based on period chosen. */
FUNCTION get_label RETURN VARCHAR2 IS
stmt VARCHAR2(240);
BEGIN

CASE fii_ar_util_pkg.g_page_period_type
WHEN  'FII_TIME_WEEK' THEN
	stmt:= FND_MESSAGE.GET_STRING('FII','FII_AR_DBI_WEEK');
WHEN 'FII_TIME_ENT_PERIOD' THEN
	stmt:= FND_MESSAGE.GET_STRING('FII','FII_AR_DBI_MONTH');
WHEN 'FII_TIME_ENT_QTR' THEN
	stmt:= FND_MESSAGE.GET_STRING('FII','FII_AR_DBI_QUARTER');
WHEN 'FII_TIME_ENT_YEAR' THEN
	stmt:= FND_MESSAGE.GET_STRING('FII','FII_AR_DBI_YEAR');
END CASE;

        Return stmt;

END get_label;

END FII_AR_REC_ACTIVITY_TREND_PKG;


/
