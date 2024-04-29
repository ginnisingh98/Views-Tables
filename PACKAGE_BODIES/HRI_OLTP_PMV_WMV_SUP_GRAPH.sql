--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_WMV_SUP_GRAPH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_WMV_SUP_GRAPH" AS
/* $Header: hriopbdg.pkb 120.2 2006/01/05 00:43:08 anmajumd noship $ */

g_rtn                   VARCHAR2(30) := '
';


PROCEDURE GET_SQL2(p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
                    x_custom_sql       OUT NOCOPY VARCHAR2,
                    x_custom_output    OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS

  l_custom_rec            BIS_QUERY_ATTRIBUTES;
  l_security_clause       VARCHAR2(4000);
  l_SQLText               VARCHAR2(4000);
/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;
  l_debug_header          VARCHAR(550);
/* Pre-calculations */
  l_previous_periods      NUMBER;
  l_projection_periods    NUMBER;
  l_trend_table           VARCHAR2(4000);
g_rtn                     VARCHAR2(30) := '
';

BEGIN
/* Initialize table/record variables */
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Get security clause for Manager based security */
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');

/* Get common parameter values */
  hri_oltp_pmv_util_param.get_parameters_from_table
                         (p_page_parameter_tbl  => p_page_parameter_tbl
                         ,p_parameter_rec       => l_parameter_rec
                         ,p_bind_tab            => l_bind_tab);

/*  get fii offset table for alias in main query and Variables */
   HRI_OLTP_PMV_QUERY_TIME.GET_TIME_CLAUSE
          ('Y'
          ,l_parameter_rec.page_period_type
          ,l_parameter_rec.time_comparison_type
          ,l_trend_table
          ,l_previous_periods
          ,l_projection_periods  );

l_SQLText :=
        ' SELECT  -- Headcount Budget Trend
          a.period_as_of_date      VIEWBY,
          a.period_as_of_date      VIEWBYID,
          a.period_order           hri_p_order_by_1,
          a.period_as_of_date      hri_p_graph_x_label_time,
          SUM(decode(hri_dbi_wmv_budget.comp_date(a.period_as_of_date,trunc(&BIS_CURRENT_ASOF_DATE))
                , ''N'', b.total_headcount
                ,''Y'', null) )    hri_p_wmv_sum_mv,
          c.budget_value           hri_p_wmv_budget_sum_mv
     FROM '||l_trend_table || ' a,
         HRI_MDP_SUP_WRKFC_SUP_MV b,
         hri_dbi_wmv_budget_mv c
    WHERE b.supervisor_person_id = &HRI_PERSON+HRI_PER_USRDR_H
      AND a.period_as_of_date BETWEEN b.effective_start_date AND b.effective_end_date
      AND c.supervisor_id(+) = b.supervisor_person_id
      AND b.wkth_wktyp_sk_fk = ''EMP''
      AND NVL(c.effective_date,SYSDATE) = ( SELECT  NVL(MAX(e.effective_date),SYSDATE)
                                            FROM    hri_dbi_wmv_budget_mv e
                                            WHERE   e.supervisor_id = c.supervisor_id
                                            AND     e.effective_date <= a.period_as_of_date
                                            AND     e.count_type = ''TOTAL_WMV_BUDGET'')
      AND c.count_type(+) = ''TOTAL_WMV_BUDGET''
          '|| l_security_clause ||'
GROUP BY a.period_order
       , a.period_as_of_date
       , c.budget_value
ORDER BY a.period_order ASC' ;

  x_custom_sql := l_sqltext;

  l_custom_rec.attribute_name := ':TIME_PERIOD_TYPE';
  l_custom_rec.attribute_value := l_parameter_rec.page_period_type;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':TIME_PROJECT_PERIOD_TYPE';
  l_custom_rec.attribute_value := l_parameter_rec.page_period_type;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':TIME_COMPARISON_TYPE';
  l_custom_rec.attribute_value := l_parameter_rec.time_comparison_type;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':TIME_PROJECT_COMPARISON_TYPE';
  l_custom_rec.attribute_value :=  l_parameter_rec.time_comparison_type;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':TIME_PERIOD_NUMBER';
  l_custom_rec.attribute_value := l_previous_periods;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':TIME_PROJECT_PERIOD_NUMBER';
  l_custom_rec.attribute_value := l_projection_periods;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(6) := l_custom_rec;

END;

END HRI_OLTP_PMV_WMV_SUP_GRAPH;

/
