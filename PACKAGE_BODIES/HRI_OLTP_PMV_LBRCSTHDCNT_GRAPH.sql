--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_LBRCSTHDCNT_GRAPH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_LBRCSTHDCNT_GRAPH" AS
/* $Header: hrioplhg.pkb 120.9 2005/12/16 03:54:29 rlpatil noship $ */


l_currency  VARCHAR2(10);
l_rateType VARCHAR2(10);


-- ----------------------------------------------------
--  This procedure frames the Query for the Report Labor Cost with Headcount Trend.
-- ----------------------------------------------------

PROCEDURE GET_SQL(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                  x_custom_sql          OUT NOCOPY VARCHAR2,
                  x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sqltext              VARCHAR2(32767);
  l_custom_rec           BIS_QUERY_ATTRIBUTES;
  l_trend_table          VARCHAR2(4000);
  l_previous_periods     NUMBER;
  l_projection_periods   NUMBER;

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;


BEGIN

/* Initialize out parameters */

  l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();


/* Get common parameter values */
   hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_page_parameter_tbl,
         p_parameter_rec       => l_parameter_rec,
         p_bind_tab            => l_bind_tab);

  HRI_OLTP_PMV_QUERY_TIME.GET_TIME_CLAUSE
          (p_projection_type     => 'N'
          ,p_page_period_type    => l_parameter_rec.page_period_type
          ,p_page_comp_type      => l_parameter_rec.time_comparison_type
          ,o_trend_table         => l_trend_table
          ,o_previous_periods    => l_previous_periods
          ,o_projection_periods  => l_projection_periods  );


l_currency:= l_parameter_rec.currency_code;

IF l_currency =bis_common_parameters.get_currency_code              THEN
    l_rateType:=bis_common_parameters.get_rate_type;
ELSIF l_currency =bis_common_parameters.get_secondary_currency_code THEN
    l_rateType:=bis_common_parameters.get_secondary_rate_type;
END IF;

/* Build query */
l_sqltext :=
'SELECT                       --Labor Cost with Headcount Trend
  hc.period_as_of_date                          VIEWBYID
 ,hc.period_as_of_date                          VIEWBY
,hc.period_order                               HRI_P_ORDER_BY_1
,hc.period_as_of_date                          HRI_P_GRAPH_X_LABEL_TIME
,x.budgeted_amount                             HRI_P_MEASURE1
,x.actual_amount + x.committed_amount          HRI_P_MEASURE2
,hc.budgeted                                   HRI_P_MEASURE3
,hc.actual                                     HRI_P_MEASURE4
,to_char(hc.period_as_of_date,''DD/MM/YYYY'')  HRI_P_CHAR1_GA
FROM
(
 SELECT  b.period_as_of_date,
         b.period_order,
         b.budgeted_amount,
         a.actual_amount,
         a.committed_amount
 FROM
 (
 SELECT prds.period_as_of_date
        ,prds.period_order
        ,hri_oltp_view_currency.convert_currency_amount
        (bgt.CURRENCY_CODE,
         '''||l_currency||''',
         &BIS_CURRENT_ASOF_DATE,
         SUM(BUDGET_VALUE),
         '''||l_rateType||''')    budgeted_amount
 FROM ' || l_trend_table || ' prds,
      HRI_MDP_BDGTS_LBRCST_MV  bgt
 WHERE bgt.ORGMGR_ID(+) = &HRI_PERSON+HRI_PER_USRDR_H
   AND prds.period_start_date <= bgt.EFFECTIVE_END_DATE(+)
   AND prds.period_end_date >= bgt.EFFECTIVE_START_DATE(+)
 GROUP BY  prds.period_as_of_date,
           prds.period_order,
           bgt.CURRENCY_CODE ) b,
(
 SELECT prds.period_as_of_date
        ,prds.period_order
        ,hri_oltp_view_currency.convert_currency_amount
         (act.CURRENCY_CODE,
         '''||l_currency||''',
         &BIS_CURRENT_ASOF_DATE,
         sum(act.ACTUAL_VALUE),
         '''||l_rateType||''')  actual_amount
         ,hri_oltp_view_currency.convert_currency_amount
          (act.CURRENCY_CODE,
          '''||l_currency||''',
          &BIS_CURRENT_ASOF_DATE,
          sum(act.COMMITMENT_VALUE),
          '''||l_rateType||''')  committed_amount
 FROM  ' || l_trend_table || ' prds,
       HRI_MDP_CMNTS_ACTLS_MV act
WHERE act.ORGMGR_ID(+) = &HRI_PERSON+HRI_PER_USRDR_H
  AND prds.period_start_date <= act.EFFECTIVE_END_DATE(+)
  AND prds.period_end_date >= act.EFFECTIVE_START_DATE(+)
GROUP BY prds.period_as_of_date,
         prds.period_order,
         act.CURRENCY_CODE ) a
WHERE a.period_as_of_date = b.period_as_of_date) x,
(
SELECT a.period_as_of_date,
       a.period_order,
       b.total budgeted,
       a.total actual
FROM
(
 SELECT  prds.period_as_of_date
         ,prds.period_order
         ,NVL(sum(act.total_headcount),0) total
 FROM  ' || l_trend_table || ' prds,
       HRI_MDP_WRKFC_MV  act
 WHERE prds.PERIOD_AS_OF_DATE BETWEEN act.EFFECTIVE_START_DATE(+) AND act.EFFECTIVE_END_DATE(+)
   AND act.ORGMGR_ID(+) = &HRI_PERSON+HRI_PER_USRDR_H
GROUP BY  prds.period_as_of_date,
          prds.period_order )a,
 (
 SELECT  period_as_of_date
         ,period_order
         ,SUM(TOTAL) TOTAL
   FROM
(
 SELECT  prds.period_as_of_date
         ,prds.period_order
	 ,bgt.ORGANIZATION_ID
	 ,bgt.POSITION_ID
         ,CASE  WHEN bgt.BUDGET_AGGREGATE = ''ACCUMULATE''   THEN SUM(bgt.HEADCOUNT_VALUE)
                WHEN bgt.BUDGET_AGGREGATE = ''AVERAGE''   THEN AVG(bgt.HEADCOUNT_VALUE)
                WHEN bgt.BUDGET_AGGREGATE = ''MAXIMUM''   THEN MAX(bgt.HEADCOUNT_VALUE)
                ELSE SUM(bgt.HEADCOUNT_VALUE)
          END TOTAL
 FROM ' || l_trend_table || ' prds,
      HRI_MDP_BDGTS_HDCNT_ORGMGR_CT  bgt
 WHERE bgt.ORGMGR_ID(+) = &HRI_PERSON+HRI_PER_USRDR_H
   AND prds.period_start_date <= bgt.EFFECTIVE_END_DATE(+)
   AND prds.period_end_date   >= bgt.EFFECTIVE_START_DATE(+)
 GROUP BY prds.period_as_of_date,
          prds.period_order,
	  bgt.BUDGET_AGGREGATE,
  	  bgt.ORGANIZATION_ID,
	  bgt.POSITION_ID
)
 GROUP BY period_as_of_date,
          period_order
	  )b
WHERE  a.period_as_of_date=b.period_as_of_date ) hc
WHERE  hc.period_as_of_date = x.period_as_of_date
ORDER BY hc.period_as_of_date
';

  x_custom_sql := l_SQLText;

  l_custom_rec.attribute_name := ':TIME_PERIOD_TYPE';
  l_custom_rec.attribute_value := l_parameter_rec.page_period_type;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':TIME_COMPARISON_TYPE';
  l_custom_rec.attribute_value := l_parameter_rec.time_comparison_type;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':TIME_PERIOD_NUMBER';
  l_custom_rec.attribute_value := l_previous_periods;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':GLOBAL_CURRENCY';
  l_custom_rec.attribute_value := l_parameter_rec.currency_code;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':GLOBAL_RATE';
  l_custom_rec.attribute_value := l_parameter_rec.rate_type;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(5) := l_custom_rec;

END GET_SQL;

-- ----------------------------------------------------
--  This procedure frames the Query for the Report Budgeted and Projected Labor Cost Trend.
-- ----------------------------------------------------


PROCEDURE GET_LBRCST_SQL(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                         x_custom_sql          OUT NOCOPY VARCHAR2,
                         x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sqltext              VARCHAR2(32767);
  l_custom_rec           BIS_QUERY_ATTRIBUTES;
  l_trend_table          VARCHAR2(4000);
  l_previous_periods     NUMBER;
  l_projection_periods   NUMBER;

/* Parameter values */
  l_parameter_rec        hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab             hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;


BEGIN

/* Initialize out parameters */

  l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();


/* Get common parameter values */
   hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_page_parameter_tbl,
         p_parameter_rec       => l_parameter_rec,
         p_bind_tab            => l_bind_tab);

  HRI_OLTP_PMV_QUERY_TIME.GET_TIME_CLAUSE
          (p_projection_type     => 'N'
          ,p_page_period_type    => l_parameter_rec.page_period_type
          ,p_page_comp_type      => l_parameter_rec.time_comparison_type
          ,o_trend_table         => l_trend_table
          ,o_previous_periods    => l_previous_periods
          ,o_projection_periods  => l_projection_periods  );


l_currency:= l_parameter_rec.currency_code;

IF l_currency =bis_common_parameters.get_currency_code               THEN
    l_rateType:=bis_common_parameters.get_rate_type;
ELSIF l_currency =bis_common_parameters.get_secondary_currency_code  THEN
    l_rateType:=bis_common_parameters.get_secondary_rate_type;
END IF;



/* Build query */
  l_sqltext :=
'SELECT                            --Budgeted and Projected Labor Cost Trend
 a.period_as_of_date                              VIEWBYID
,a.period_as_of_date                              VIEWBY
,a.period_order                                  HRI_P_ORDER_BY_1
,a.period_as_of_date                             HRI_P_GRAPH_X_LABEL_TIME
,b.budgeted_amount                               HRI_P_MEASURE2
,a.actual_amount + a.committed_amount            HRI_P_MEASURE4
,to_char(a.period_as_of_date,''DD/MM/YYYY'')     HRI_P_CHAR1_GA
FROM
 (
 SELECT  prds.period_as_of_date
         ,prds.period_order
         ,hri_oltp_view_currency.convert_currency_amount
         (bgt.CURRENCY_CODE,
          '''||l_currency||''',
          &BIS_CURRENT_ASOF_DATE,
          SUM(BUDGET_VALUE),
          '''||l_rateType||''')    budgeted_amount
 FROM   ' || l_trend_table || ' prds,
        HRI_MDP_BDGTS_LBRCST_ORG_MV  bgt
 WHERE  bgt.ORGMGR_ID(+) = &HRI_PERSON+HRI_PER_USRDR_H
        AND prds.period_start_date <= bgt.EFFECTIVE_END_DATE(+)
	AND prds.period_end_date >= bgt.EFFECTIVE_START_DATE(+)
GROUP BY  prds.period_as_of_date,
          prds.period_order,
          bgt.CURRENCY_CODE ) b,
(
 SELECT  prds.period_as_of_date
         ,prds.period_order
	 ,hri_oltp_view_currency.convert_currency_amount
          (act.CURRENCY_CODE,
           '''||l_currency||''',
           &BIS_CURRENT_ASOF_DATE,
           sum(act.ACTUAL_VALUE),
           '''||l_rateType||''')  actual_amount
         ,hri_oltp_view_currency.convert_currency_amount
          (act.CURRENCY_CODE,
           '''||l_currency||''',
           &BIS_CURRENT_ASOF_DATE,
           sum(act.COMMITMENT_VALUE),
           '''||l_rateType||''')  committed_amount
 FROM   ' || l_trend_table || ' prds,
        HRI_MDP_CMNTS_ACTLS_ORG_MV act
 WHERE  act.ORGMGR_ID(+) = &HRI_PERSON+HRI_PER_USRDR_H
        AND prds.period_start_date <= act.EFFECTIVE_END_DATE(+)
	AND prds.period_end_date >= act.EFFECTIVE_START_DATE(+)
GROUP BY  prds.period_as_of_date,
          prds.period_order,
          act.CURRENCY_CODE)a
WHERE b.PERIOD_AS_OF_DATE=a.PERIOD_AS_OF_DATE
ORDER BY  a.period_as_of_date
';

  x_custom_sql := l_SQLText;

  l_custom_rec.attribute_name := ':TIME_PERIOD_TYPE';
  l_custom_rec.attribute_value := l_parameter_rec.page_period_type;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':TIME_COMPARISON_TYPE';
  l_custom_rec.attribute_value := l_parameter_rec.time_comparison_type;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':TIME_PERIOD_NUMBER';
  l_custom_rec.attribute_value := l_previous_periods;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':GLOBAL_CURRENCY';
  l_custom_rec.attribute_value := l_parameter_rec.currency_code;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':GLOBAL_RATE';
  l_custom_rec.attribute_value := l_parameter_rec.rate_type;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(5) := l_custom_rec;

END GET_LBRCST_SQL;


-- ----------------------------------------------------
--  This procedure frames the Query for the Report Budgeted and Actual Headcount Trend.
-- ----------------------------------------------------

PROCEDURE GET_HDCNT_SQL(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                        x_custom_sql          OUT NOCOPY VARCHAR2,
                        x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sqltext              VARCHAR2(32767);
  l_custom_rec           BIS_QUERY_ATTRIBUTES;
  l_trend_table          VARCHAR2(4000);
  l_previous_periods     NUMBER;
  l_projection_periods   NUMBER;

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;


BEGIN

/* Initialize out parameters */

  l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();


/* Get common parameter values */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_page_parameter_tbl,
         p_parameter_rec       => l_parameter_rec,
         p_bind_tab            => l_bind_tab);


  HRI_OLTP_PMV_QUERY_TIME.GET_TIME_CLAUSE
          (p_projection_type     => 'N'
          ,p_page_period_type    => l_parameter_rec.page_period_type
          ,p_page_comp_type      => l_parameter_rec.time_comparison_type
          ,o_trend_table         => l_trend_table
          ,o_previous_periods    => l_previous_periods
          ,o_projection_periods  => l_projection_periods  );


/* Build query */
  l_sqltext :=
'SELECT                          --  Headcount Budget Trend
 a.period_as_of_date                            VIEWBYID
,a.period_as_of_date                            VIEWBY
,a.period_order                                HRI_P_ORDER_BY_1
,a.period_as_of_date                           HRI_P_GRAPH_X_LABEL_TIME
,b.total                                      HRI_P_MEASURE1
,a.total                                      HRI_P_MEASURE2
,to_char(a.period_as_of_date,''DD/MM/YYYY'')   HRI_P_CHAR1_GA
FROM
 (
  SELECT  prds.period_as_of_date
          ,prds.period_order
          ,NVL(sum(act.total_headcount),0) total
 FROM  ' || l_trend_table || ' prds,
       HRI_MDP_WRKFC_MV  act
 WHERE prds.PERIOD_AS_OF_DATE BETWEEN act.EFFECTIVE_START_DATE(+) AND act.EFFECTIVE_END_DATE(+)
       AND act.ORGMGR_ID(+) = &HRI_PERSON+HRI_PER_USRDR_H
 Group by prds.PERIOD_AS_OF_DATE
          ,prds.PERIOD_ORDER  )a,
  (
 SELECT  period_as_of_date
         ,period_order
         ,SUM(TOTAL) TOTAL
   FROM
(
 SELECT  prds.period_as_of_date
         ,prds.period_order
	 ,bgt.ORGANIZATION_ID
	 ,bgt.POSITION_ID
         ,CASE  WHEN bgt.BUDGET_AGGREGATE = ''ACCUMULATE''   THEN SUM(bgt.HEADCOUNT_VALUE)
                WHEN bgt.BUDGET_AGGREGATE = ''AVERAGE''   THEN AVG(bgt.HEADCOUNT_VALUE)
                WHEN bgt.BUDGET_AGGREGATE = ''MAXIMUM''   THEN MAX(bgt.HEADCOUNT_VALUE)
                ELSE SUM(bgt.HEADCOUNT_VALUE)
          END TOTAL
 FROM ' || l_trend_table || ' prds,
      HRI_MDP_BDGTS_HDCNT_ORGMGR_CT  bgt
 WHERE bgt.ORGMGR_ID(+) = &HRI_PERSON+HRI_PER_USRDR_H
   AND prds.period_start_date <= bgt.EFFECTIVE_END_DATE(+)
   AND prds.period_end_date   >= bgt.EFFECTIVE_START_DATE(+)
 GROUP BY prds.period_as_of_date,
          prds.period_order,
	  bgt.BUDGET_AGGREGATE,
  	  bgt.ORGANIZATION_ID,
	  bgt.POSITION_ID
)
 GROUP BY period_as_of_date,
          period_order
	  )b
WHERE a.period_as_of_date=b.period_as_of_date
ORDER BY a.period_as_of_date';

  x_custom_sql := l_SQLText;

  l_custom_rec.attribute_name := ':TIME_PERIOD_TYPE';
  l_custom_rec.attribute_value := l_parameter_rec.page_period_type;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':TIME_COMPARISON_TYPE';
  l_custom_rec.attribute_value := l_parameter_rec.time_comparison_type;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':TIME_PERIOD_NUMBER';
  l_custom_rec.attribute_value := l_previous_periods;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':GLOBAL_CURRENCY';
  l_custom_rec.attribute_value := l_parameter_rec.currency_code;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':GLOBAL_RATE';
  l_custom_rec.attribute_value := l_parameter_rec.rate_type;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(5) := l_custom_rec;

END GET_HDCNT_SQL;

END HRI_OLTP_PMV_LBRCSTHDCNT_GRAPH;


/
