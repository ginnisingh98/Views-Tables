--------------------------------------------------------
--  DDL for Package Body FII_AR_PDUE_REC_TREND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_PDUE_REC_TREND" AS
/* $Header: FIIARDBIPTB.pls 120.6.12000000.2 2007/04/09 20:16:08 vkazhipu ship $ */



PROCEDURE get_pdue_rec_trend (
        p_page_parameter_tbl    IN  BIS_PMV_PAGE_PARAMETER_TBL,
        open_rec_sql             OUT NOCOPY VARCHAR2,
        open_rec_output          OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS

l_viewby_id 		VARCHAR2(50);
l_viewby		VARCHAR2(250);
l_party_where 		VARCHAR2(250);
l_parent_party_where 	VARCHAR2(250);
l_collector_where	VARCHAR2(250);
l_cust_acct_where	VARCHAR2(250);
l_cust_self_drill	VARCHAR2(500);
l_past_due_rec_drill	VARCHAR2(500);
l_open_rec_drill	VARCHAR2(500);
l_select		VARCHAR2(15000);
l_group_by 		VARCHAR2(100) := NULL;
l_order_by		VARCHAR2(250);
l_order_column		VARCHAR2(250);
l_select_curr_end_prd	VARCHAR2(5000);
l_end_date		VARCHAR2(50);

BEGIN

fii_ar_util_pkg.reset_globals;
fii_ar_util_pkg.get_parameters(p_page_parameter_tbl);

-- Viewby month
SELECT fii_time_api.ent_cper_end(fii_ar_util_pkg.g_as_of_date) INTO fii_ar_util_pkg.g_curr_per_end FROM DUAL;
SELECT fii_time_api.ent_pper_end(fii_ar_util_pkg.g_as_of_date) INTO fii_ar_util_pkg.g_prior_per_end FROM DUAL;


fii_ar_util_pkg.g_view_by := 'ORGANIZATION+FII_OPERATING_UNITS';
fii_ar_util_pkg.populate_summary_gt_tables;

/* Dynamically generating the where clause for PARTY_ID*/
IF fii_ar_util_pkg.g_party_id <> '-111' THEN
	l_party_where := ' AND f.party_id   = t.party_id ';
END IF;


/* Dynamically generating the where clause for COLLECTOR_ID*/
IF fii_ar_util_pkg.g_collector_id <> '-111' THEN
	l_collector_where := 'AND f.collector_id = t.collector_id ';
END IF;

IF fii_ar_util_pkg.g_as_of_date = fii_ar_util_pkg.g_curr_per_end THEN
        l_select_curr_end_prd :=' ';
        l_end_date := ' :ASOF_DATE ';

ELSE

        l_select_curr_end_prd := ' UNION ALL
        /* The select statment will return data for current month asofdate, if asofdate<> last day of month*/
        SELECT /*+ INDEX(f FII_AR_NET_REC'|| fii_ar_util_pkg.g_cust_suffix ||'_mv_N1)*/
        per.sequence sequence,
        sum(f.total_open_amount)                                FII_AR_OPEN_REC,
        sum(f.past_due_open_amount)                                  FII_AR_PDUE_REC,
        NULL    FII_AR_PRIOR_PDUE_REC
        FROM  fii_time_ent_period per,
              FII_AR_NET_REC'||fii_ar_util_pkg.g_cust_suffix ||'_mv'|| fii_ar_util_pkg.g_curr_suffix ||'  f,
              ( SELECT  /*+ no_merge leading(gt) cardinality(gt 1)*/  *  FROM fii_time_structures cal, fii_ar_summary_gt gt
              WHERE report_date = :ASOF_DATE
              AND bitand(cal.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE ) t
        WHERE    f.time_id = t.time_id
        AND f.period_type_id = t.period_type_id
        AND f.org_id = t.org_id
        AND '||fii_ar_util_pkg.get_mv_where_statement||' '||l_party_where||l_collector_where||'
        AND per.end_date = :CURR_PERIOD_END
        GROUP BY report_date, per.sequence
        ';

        l_end_date := ' :PRIOR_PERIOD_END ';

END IF;

l_select :=
'
SELECT  cy_per.name                           VIEWBY,
	to_char(cy_per.end_date,''DD/MM/YYYY'') FII_AR_MONTH_END_DATE,
	SUM(FII_AR_OPEN_REC) 		FII_AR_OPEN_REC,
	SUM(FII_AR_PDUE_REC)  		FII_AR_PDUE_REC,
	SUM(FII_AR_PRIOR_PDUE_REC)	FII_AR_PRIOR_PDUE_REC,
	SUM(FII_AR_PDUE_REC)	FII_AR_PDUE_REC_G,
	DECODE(SUM(FII_AR_PDUE_REC),NULL,NULL,0,NULL,DECODE(SIGN(cy_per.end_date - :ASOF_DATE),1,
	''&pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+FII_OPERATING_UNITS&pParamIds=Y'',
	''AS_OF_DATE=FII_AR_MONTH_END_DATE&pFunctionName=FII_AR_PASTDUE_REC_AGING&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+FII_OPERATING_UNITS&pParamIds=Y'')) FII_AR_PDUE_REC_DRILL,
	DECODE(SUM(FII_AR_OPEN_REC),NULL,NULL,0,NULL,DECODE(SIGN(cy_per.end_date - :ASOF_DATE),1,
	''&pFunctionName=FII_AR_OPEN_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+FII_OPERATING_UNITS&pParamIds=Y'',
	''AS_OF_DATE=FII_AR_MONTH_END_DATE&pFunctionName=FII_AR_OPEN_REC_SUMMARY&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ORGANIZATION+FII_OPERATING_UNITS&pParamIds=Y'')) FII_AR_OPEN_REC_DRILL
FROM
	fii_time_ent_period cy_per,
	(SELECT  /*+ INDEX(f FII_AR_NET_REC'|| fii_ar_util_pkg.g_cust_suffix ||'_mv_N1)*/
	t.sequence sequence,
	CASE	WHEN	t.report_date  >=  :SD_SDATE THEN
	sum(f.total_open_amount) ELSE NULL END 	FII_AR_OPEN_REC,
	CASE	WHEN	t.report_date  >=  :SD_SDATE THEN
	 sum(f.past_due_open_amount)	ELSE NULL END 		FII_AR_PDUE_REC,
	CASE	WHEN	t.report_date  <  :SD_SDATE THEN
	sum(f.past_due_open_amount) ELSE NULL END	FII_AR_PRIOR_PDUE_REC
 	FROM   FII_AR_NET_REC'||fii_ar_util_pkg.g_cust_suffix ||'_mv'|| fii_ar_util_pkg.g_curr_suffix ||' f,
	    	( SELECT	/*+ no_merge leading(gt) cardinality(gt 1)*/  *  FROM fii_time_structures cal, fii_ar_summary_gt gt,fii_time_ent_period per
		WHERE
		cal.report_date = per.end_date
		and per.start_date <= '||l_end_date||'
		AND per.start_date  >= :SD_PRIOR_PRIOR
		AND bitand(cal.record_type_id, :BITAND_INC_TODATE) = :BITAND_INC_TODATE ) t
	WHERE    f.time_id = t.time_id
	AND f.period_type_id = t.period_type_id
	AND f.org_id = t.org_id
	AND '||fii_ar_util_pkg.get_mv_where_statement||' '||l_party_where||l_collector_where||'
 	GROUP BY report_date, t.sequence
 '||l_select_curr_end_prd||'
) inline_view
WHERE	cy_per.start_date <= :ASOF_DATE
AND   cy_per.start_date  > :SD_PRIOR
AND   cy_per.sequence = inline_view.sequence (+)
GROUP BY cy_per.name,cy_per.end_date,cy_per.start_date
ORDER BY cy_per.start_date
';



fii_ar_util_pkg.bind_variable(l_select, p_page_parameter_tbl, open_rec_sql, open_rec_output);


END get_pdue_rec_trend;

END FII_AR_PDUE_REC_TREND;


/
