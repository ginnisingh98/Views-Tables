--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_HDCNT_ORGMGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_HDCNT_ORGMGR" AS
/* $Header: hriophom.pkb 120.12 2006/03/14 20:13:23 rlpatil noship $ */

-- ----------------------------------------------------
--  This procedure frames the Query for the Headcount KPI.
-- ----------------------------------------------------


PROCEDURE GET_KPI_SQL(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql          OUT NOCOPY VARCHAR2,
                      x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sqltext              VARCHAR2(32767);
  l_custom_rec           BIS_QUERY_ATTRIBUTES;

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

/* Build query */
l_sqltext :=

'SELECT                                -- Headcount KPI
   ID                                                 VIEWBYID
  ,value                                              VIEWBY
  ,budgeted_amount                                   HRI_P_MEASURE1
  ,actual_amount                                     HRI_P_MEASURE2
  ,(budgeted_amount -  actual_amount)                HRI_P_MEASURE5
  ,prev_budgeted                                     HRI_P_MEASURE6
  ,prev_actual                                       HRI_P_MEASURE7
  ,(prev_budgeted -  prev_actual)                    HRI_P_MEASURE9
  ,sum(actual_amount) over()                         HRI_P_GRAND_TOTAL1
  ,sum(prev_actual) over()                           HRI_P_GRAND_TOTAL2
  ,sum(budgeted_amount) over()                       HRI_P_GRAND_TOTAL3
  ,sum(prev_budgeted) over()                         HRI_P_GRAND_TOTAL4
  ,sum((budgeted_amount -  actual_amount)) over()    HRI_P_GRAND_TOTAL7
  ,sum((prev_budgeted -  prev_actual)) over()        HRI_P_GRAND_TOTAL8
FROM
(
  SELECT  tab.ORGMGR_ID ID
          ,per.value
          ,NVL(tab.budgeted_amount,0)   BUDGETED_AMOUNT
          ,NVL(tab.actual_amount,0)     ACTUAL_AMOUNT
          ,NVL(tab.prev_budgeted,0)     PREV_BUDGETED
	  ,NVL(tab.prev_actual,0)       PREV_ACTUAL
    FROM
    (
     (
      SELECT  ORGMGR_ID,
              SUM(ACTUAL_AMOUNT)     ACTUAL_AMOUNT,
	      SUM(PREV_ACTUAL)       PREV_ACTUAL,
              SUM(BUDGETED_AMOUNT)   BUDGETED_AMOUNT,
	      SUM(PREV_BUDGETED)     PREV_BUDGETED
       FROM
       (
       (
      SELECT ORGMGR_ID,
             null                                                      BUDGETED_AMOUNT,
	     null                                                      PREV_BUDGETED,
             sum(DIRECT_HEADCOUNT)                                     ACTUAL_AMOUNT,
             HRI_OLTP_PMV_HDCNT_ORGMGR.GET_KPI_MGR_TOTALS
               (&HRI_PERSON+HRI_PER_USRDR_H
                ,&BIS_PREVIOUS_EFFECTIVE_START_DATE
                ,&BIS_PREVIOUS_EFFECTIVE_END_DATE
                ,''ACTUAL''
               )                                                       PREV_ACTUAL
       FROM HRI_MDP_WRKFC_MV
      WHERE ORGMGR_ID  = &HRI_PERSON+HRI_PER_USRDR_H
        AND &BIS_CURRENT_ASOF_DATE BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
      GROUP BY ORGMGR_ID )
      UNION ALL
    (SELECT   ORGMGR_ID,
              SUM(HEADCOUNT_VALUE)                                     BUDGETED_AMOUNT,
              HRI_OLTP_PMV_HDCNT_ORGMGR.GET_KPI_MGR_TOTALS
               (&HRI_PERSON+HRI_PER_USRDR_H
	        ,&BIS_PREVIOUS_EFFECTIVE_START_DATE
                ,&BIS_PREVIOUS_EFFECTIVE_END_DATE
                ,''BDGT''
               )                                                       PREV_BUDGETED,
	      null                                                     ACTUAL_AMOUNT,
              null                                                     PREV_ACTUAL
      FROM
     (SELECT  ORGMGR_ID,
              ORGANIZATION_ID,
	      POSITION_ID,
              CASE WHEN BUDGET_AGGREGATE = ''ACCUMULATE''  THEN SUM(HEADCOUNT_VALUE)
                   WHEN BUDGET_AGGREGATE = ''AVERAGE''  THEN AVG(HEADCOUNT_VALUE)
                   WHEN BUDGET_AGGREGATE = ''MAXIMUM''  THEN MAX(HEADCOUNT_VALUE)
                   ELSE SUM(HEADCOUNT_VALUE)
               END                                                     HEADCOUNT_VALUE
       FROM HRI_MDP_BDGTS_HDCNT_ORGMGR_CT
      WHERE ORGMGR_ID             = &HRI_PERSON+HRI_PER_USRDR_H
        AND EFFECTIVE_START_DATE <= &BIS_CURRENT_EFFECTIVE_END_DATE
        AND EFFECTIVE_END_DATE   >= &BIS_CURRENT_EFFECTIVE_START_DATE
	AND ORGANIZATION_ID IN (SELECT SUB_ORGANIZATION_ID
	                          FROM HRI_CS_SUPH_ORGMGR_CT
				 WHERE SUP_PERSON_ID=&HRI_PERSON+HRI_PER_USRDR_H
				   AND SUB_PERSON_ID = SUP_PERSON_ID
				   AND SUB_RELATIVE_LEVEL = 0
				   AND &BIS_CURRENT_ASOF_DATE BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE)

      GROUP BY  ORGMGR_ID,
                ORGANIZATION_ID,
                POSITION_ID,
                BUDGET_AGGREGATE )
      GROUP BY  ORGMGR_ID
     )
      )
      GROUP BY ORGMGR_ID
      )
      UNION ALL
     (
      SELECT  ORGMGR_ID,
              SUM(ACTUAL_AMOUNT)     ACTUAL_AMOUNT,
	      SUM(PREV_ACTUAL)       PREV_ACTUAL,
              SUM(BUDGETED_AMOUNT)   BUDGETED_AMOUNT,
	      SUM(PREV_BUDGETED)     PREV_BUDGETED
       FROM
       (
       (
      SELECT ORGMGR_ID,
             null                                                      BUDGETED_AMOUNT,
	     null                                                      PREV_BUDGETED,
             sum(TOTAL_HEADCOUNT)                                      ACTUAL_AMOUNT,
             HRI_OLTP_PMV_HDCNT_ORGMGR.GET_KPI_TOTALS
               (ORGMGR_ID
                ,&BIS_PREVIOUS_EFFECTIVE_START_DATE
                ,&BIS_PREVIOUS_EFFECTIVE_END_DATE
                ,''ACTUAL''
               )                                                       PREV_ACTUAL
       FROM HRI_MDP_WRKFC_ORGMGR_MV
      WHERE ORGMGR_ID          IN      (SELECT  SUB_PERSON_ID FROM HRI_CS_SUPH_ORGMGR_CT WHERE SUP_PERSON_ID = &HRI_PERSON+HRI_PER_USRDR_H AND SUB_RELATIVE_LEVEL =1 AND &BIS_CURRENT_ASOF_DATE BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE)
        AND &BIS_CURRENT_ASOF_DATE BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
      GROUP BY ORGMGR_ID)
      UNION ALL
     (SELECT  ORGMGR_ID,
              SUM(HEADCOUNT_VALUE)                                     BUDGETED_AMOUNT,
              HRI_OLTP_PMV_HDCNT_ORGMGR.GET_KPI_TOTALS
               (ORGMGR_ID
	        ,&BIS_PREVIOUS_EFFECTIVE_START_DATE
                ,&BIS_PREVIOUS_EFFECTIVE_END_DATE
                ,''BDGT''
               )                                                       PREV_BUDGETED,
	      null                                                     ACTUAL_AMOUNT,
              null                                                     PREV_ACTUAL
        FROM
     (SELECT  ORGMGR_ID,
              ORGANIZATION_ID,
              POSITION_ID,
              CASE WHEN BUDGET_AGGREGATE = ''ACCUMULATE''  THEN SUM(HEADCOUNT_VALUE)
                   WHEN BUDGET_AGGREGATE = ''AVERAGE''  THEN AVG(HEADCOUNT_VALUE)
                   WHEN BUDGET_AGGREGATE = ''MAXIMUM''  THEN MAX(HEADCOUNT_VALUE)
                   ELSE SUM(HEADCOUNT_VALUE)
               END                                                            HEADCOUNT_VALUE
       FROM HRI_MDP_BDGTS_HDCNT_ORGMGR_CT
      WHERE ORGMGR_ID            IN      (SELECT  SUB_PERSON_ID FROM HRI_CS_SUPH_ORGMGR_CT WHERE SUP_PERSON_ID = &HRI_PERSON+HRI_PER_USRDR_H AND SUB_RELATIVE_LEVEL =1 AND &BIS_CURRENT_ASOF_DATE BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE)
        AND EFFECTIVE_START_DATE <= &BIS_CURRENT_EFFECTIVE_END_DATE
        AND EFFECTIVE_END_DATE   >= &BIS_CURRENT_EFFECTIVE_START_DATE
      GROUP BY  ORGMGR_ID,
                ORGANIZATION_ID,
                POSITION_ID,
                BUDGET_AGGREGATE )
      GROUP BY  ORGMGR_ID
     )
      )
      GROUP BY ORGMGR_ID
      )
      ) tab,
      HRI_DBI_CL_PER_N_V per
      WHERE tab.ORGMGR_ID = per.ID
        AND &BIS_CURRENT_ASOF_DATE BETWEEN per.EFFECTIVE_START_DATE AND per.EFFECTIVE_END_DATE
    )';

x_custom_sql := l_SQLText;

END GET_KPI_SQL;

-- ----------------------------------------------------
--  This procedure frames the Query for the Report Headcount Distribution By Organization.
-- ----------------------------------------------------

PROCEDURE GET_ORG_SQL(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
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

/* Pre-calculations */
  l_period_ago_total_sal  NUMBER;
  l_period_ago_wmv_count  NUMBER;
  l_period_ago_dr_count   NUMBER;
  l_period_ago_dr_sal     NUMBER;
  l_tot_wmv_start         NUMBER;


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
          (p_projection_type    => 'N'
          ,p_page_period_type   => l_parameter_rec.page_period_type
          ,p_page_comp_type     => l_parameter_rec.time_comparison_type
          ,o_trend_table        => l_trend_table
          ,o_previous_periods   => l_previous_periods
          ,o_projection_periods => l_projection_periods  );



  /* Build query */
 l_sqltext :=
'SELECT                                 -- Headcount Distribution By Organization
   name                                                        HRI_P_ORDER_BY_1
  ,name                                                        HRI_P_CHAR1_GA
  ,budgeted_amount                                             HRI_P_MEASURE1
  ,actual_amount                                               HRI_P_MEASURE3
  ,budgeted_amount- actual_amount                              HRI_P_MEASURE5
  ,((( budgeted_amount- actual_amount) -  prev_available)/decode( prev_available,0,1, prev_available))*100       HRI_P_MEASURE6
  ,sum( budgeted_amount) over()                                HRI_P_GRAND_TOTAL1
  ,sum( actual_amount) over()                                  HRI_P_GRAND_TOTAL2
  ,sum( budgeted_amount- actual_amount) over()                 HRI_P_GRAND_TOTAL3
  ,((sum( budgeted_amount- actual_amount) over() - sum( prev_available) over() )/DECODE(sum( prev_available) over(),0,1,sum( prev_available) over()))*100   HRI_P_GRAND_TOTAL4
   FROM
  (
   SELECT ORGANIZATION_ID                                                  ID,
          HR_GENERAL.DECODE_ORGANIZATION(ORGANIZATION_ID)                  NAME,
          NVL(SUM(BUDGETED_AMOUNT),0)                                      BUDGETED_AMOUNT,
	  NVL(SUM(ACTUAL_AMOUNT),0)                                        ACTUAL_AMOUNT,
          HRI_OLTP_PMV_HDCNT_ORGMGR.CALC_PREV_VALUE
              (&HRI_PERSON+HRI_PER_USRDR_H
	       ,ORGANIZATION_ID
               ,&BIS_PREVIOUS_EFFECTIVE_START_DATE
               ,&BIS_PREVIOUS_EFFECTIVE_END_DATE
               ,''AVAIL''
               )                                                       PREV_AVAILABLE
    FROM
    (
    (SELECT  ORGANIZATION_ID,
             null                                                      BUDGETED_AMOUNT,
             TOTAL_HEADCOUNT                                           ACTUAL_AMOUNT
       FROM HRI_MDP_WRKFC_ORGMGR_MV
      WHERE ORGMGR_ID = &HRI_PERSON+HRI_PER_USRDR_H
        AND &BIS_CURRENT_ASOF_DATE BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE)
     UNION ALL
     SELECT  ORGANIZATION_ID,
             SUM(BUDGETED_AMOUNT)  BUDGETED_AMOUNT,
             null                  ACTUAL_AMOUNT
       FROM
     (
     SELECT   ORGANIZATION_ID,
              POSITION_ID,
              CASE WHEN BUDGET_AGGREGATE = ''ACCUMULATE''  THEN SUM(HEADCOUNT_VALUE)
                   WHEN BUDGET_AGGREGATE = ''AVERAGE''  THEN AVG(HEADCOUNT_VALUE)
                   WHEN BUDGET_AGGREGATE = ''MAXIMUM''  THEN MAX(HEADCOUNT_VALUE)
                   ELSE SUM(HEADCOUNT_VALUE)
               END                                      BUDGETED_AMOUNT
        FROM HRI_MDP_BDGTS_HDCNT_ORGMGR_CT
       WHERE ORGMGR_ID             = &HRI_PERSON+HRI_PER_USRDR_H
         AND EFFECTIVE_START_DATE <= &BIS_CURRENT_EFFECTIVE_END_DATE
         AND EFFECTIVE_END_DATE   >= &BIS_CURRENT_EFFECTIVE_START_DATE
      GROUP BY  ORGANIZATION_ID,
                POSITION_ID,
                BUDGET_AGGREGATE
		)
    GROUP BY ORGANIZATION_ID
      )
      GROUP BY ORGANIZATION_ID
      )
   &ORDER_BY_CLAUSE';


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

  l_custom_rec.attribute_name := ':HRI_TOT_WMV_PREV';
  l_custom_rec.attribute_value := l_period_ago_wmv_count;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(6) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_TOT_WMV_START';
  l_custom_rec.attribute_value := l_tot_wmv_start;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(7) := l_custom_rec;

END GET_ORG_SQL;


-- ----------------------------------------------------
--  This procedure calculates the Budgeted, Commitment and actual Headcount Grand Totals for
--  the Headcount KPI.
-- ----------------------------------------------------

FUNCTION     GET_KPI_TOTALS(p_ORGMGR_ID              NUMBER,
                            p_effective_start_date   DATE,
                            p_effective_end_date     DATE,
                            p_type                   VARCHAR2
                            )
RETURN NUMBER IS

CURSOR Budget IS
SELECT SUM(BUDGETED) BUDGETED
  FROM
  (SELECT ORGANIZATION_ID,
          POSITION_ID,
         NVL(CASE WHEN BUDGET_AGGREGATE = 'ACCUMULATE'      THEN SUM(HEADCOUNT_VALUE)
                  WHEN BUDGET_AGGREGATE = 'AVERAGE'      THEN AVG(HEADCOUNT_VALUE)
                  WHEN BUDGET_AGGREGATE = 'MAXIMUM'      THEN MAX(HEADCOUNT_VALUE)
                  ELSE SUM(HEADCOUNT_VALUE)
                  END,0) budgeted
        FROM HRI_MDP_BDGTS_HDCNT_ORGMGR_CT
       WHERE ORGMGR_ID             = p_ORGMGR_ID
         AND EFFECTIVE_START_DATE <= p_effective_end_date
         AND EFFECTIVE_END_DATE   >= p_effective_start_date
       GROUP BY BUDGET_AGGREGATE,
                ORGANIZATION_ID,
                POSITION_ID) ;

CURSOR actls IS
      SELECT NVL(TOTAL_HEADCOUNT,0) actual
        FROM HRI_MDP_WRKFC_ORGMGR_MV
       WHERE ORGMGR_ID        = p_ORGMGR_ID
         AND p_effective_end_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE;

l_budgeted_amount number;
l_actual_amount number;
l_available number := 0;

BEGIN

  OPEN Budget;
  FETCH Budget INTO l_budgeted_amount;
  CLOSE Budget;

  OPEN actls;
  FETCH actls into l_actual_amount;
  CLOSE actls;

  l_available := l_budgeted_amount - l_actual_amount;

   IF (p_type = 'AVAIL')     THEN
    return l_available;
   ELSIF (p_type = 'ACTUAL') THEN
    return l_actual_amount;
   ELSIF (p_type = 'BDGT')   THEN
    return l_budgeted_amount;
   ELSE
    return 0;
   END IF;

END GET_KPI_TOTALS;


-- ----------------------------------------------------
--  This procedure calculates the Budgeted, Commitment and actual Headcount Grand Totals of
--  the organizations directly owned by the Manager for the Headcount KPI.
-- ----------------------------------------------------

FUNCTION GET_KPI_MGR_TOTALS(p_ORGMGR_ID              NUMBER,
                            p_effective_start_date   DATE,
                            p_effective_end_date     DATE,
                            p_type                   VARCHAR2
                            )
RETURN NUMBER IS

CURSOR Budget IS
SELECT SUM(BUDGETED) BUDGETED
  FROM
 (SELECT ORGANIZATION_ID,
         POSITION_ID,
	 NVL(CASE WHEN BUDGET_AGGREGATE = 'ACCUMULATE'      THEN SUM(HEADCOUNT_VALUE)
                  WHEN BUDGET_AGGREGATE = 'AVERAGE'      THEN AVG(HEADCOUNT_VALUE)
                  WHEN BUDGET_AGGREGATE = 'MAXIMUM'      THEN MAX(HEADCOUNT_VALUE)
                  ELSE SUM(HEADCOUNT_VALUE)
                  END,0) budgeted
        FROM HRI_MDP_BDGTS_HDCNT_ORGMGR_CT
       WHERE ORGMGR_ID             = p_ORGMGR_ID
         AND EFFECTIVE_START_DATE <= p_effective_end_date
         AND EFFECTIVE_END_DATE   >= p_effective_start_date
         AND ORGANIZATION_ID IN(SELECT SUB_ORGANIZATION_ID
                                  FROM HRI_CS_SUPH_ORGMGR_CT
				 WHERE SUP_PERSON_ID=p_ORGMGR_ID
				   AND SUB_PERSON_ID = SUP_PERSON_ID
				   AND SUB_RELATIVE_LEVEL = 0
				   AND p_effective_end_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE)
       GROUP BY BUDGET_AGGREGATE,
                ORGANIZATION_ID,
                POSITION_ID    );

CURSOR actls IS
      SELECT NVL(TOTAL_HEADCOUNT,0) actual
        FROM HRI_MDP_WRKFC_ORGMGR_MV
       WHERE ORGMGR_ID        = p_ORGMGR_ID
         AND p_effective_end_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
	 AND ORGANIZATION_ID IN(SELECT SUB_ORGANIZATION_ID
                                  FROM HRI_CS_SUPH_ORGMGR_CT
				 WHERE SUP_PERSON_ID=p_ORGMGR_ID
				   AND SUB_PERSON_ID = SUP_PERSON_ID
				   AND SUB_RELATIVE_LEVEL = 0
				   AND p_effective_end_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE);
l_budgeted_amount number;
l_actual_amount number;
l_available number := 0;

BEGIN

  OPEN Budget;
  FETCH Budget INTO l_budgeted_amount;
  CLOSE Budget;

  OPEN actls;
  FETCH actls into l_actual_amount;
  CLOSE actls;

  l_available := l_budgeted_amount - l_actual_amount;

   IF (p_type = 'AVAIL')     THEN
    return l_available;
   ELSIF (p_type = 'ACTUAL') THEN
    return l_actual_amount;
   ELSIF (p_type = 'BDGT')   THEN
    return l_budgeted_amount;
   ELSE
    return 0;
   END IF;

END GET_KPI_MGR_TOTALS;





-- ----------------------------------------------------
--  This procedure calculates the previous period Budgeted and actual Headcount values for
--  the Report Headcount Distribution By Organization.
-- ----------------------------------------------------

FUNCTION CALC_PREV_VALUE(p_supervisor_id         NUMBER,
                         p_organization_id       NUMBER,
                         p_effective_start_date  DATE,
                         p_effective_end_date    DATE,
                         p_type                  VARCHAR2)
RETURN NUMBER IS

CURSOR Budget IS
SELECT SUM(BUDGETED) BUDGETED
  FROM
 (SELECT POSITION_ID,
         NVL(CASE WHEN BUDGET_AGGREGATE = 'ACCUMULATE'      THEN SUM(HEADCOUNT_VALUE)
                  WHEN BUDGET_AGGREGATE = 'AVERAGE'      THEN AVG(HEADCOUNT_VALUE)
                  WHEN BUDGET_AGGREGATE = 'MAXIMUM'      THEN MAX(HEADCOUNT_VALUE)
                  ELSE SUM(HEADCOUNT_VALUE)
                  END,0) BUDGETED
        FROM HRI_MDP_BDGTS_HDCNT_ORGMGR_CT
       WHERE ORGMGR_ID             = p_supervisor_id
         AND EFFECTIVE_START_DATE <= p_effective_end_date
         AND EFFECTIVE_END_DATE   >= p_effective_start_date
	 AND ORGANIZATION_ID       = p_organization_id
       GROUP BY POSITION_ID,
                BUDGET_AGGREGATE );

CURSOR actls IS
      SELECT NVL(TOTAL_HEADCOUNT,0) actual
        FROM HRI_MDP_WRKFC_ORGMGR_MV
       WHERE ORGMGR_ID        = p_supervisor_id
         AND p_effective_end_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
 	 AND ORGANIZATION_ID       = p_organization_id ;

l_budgeted_amount   number;
l_actual_amount     number;
l_available         number := 0;

BEGIN

  OPEN Budget;
  FETCH Budget INTO l_budgeted_amount;
  CLOSE Budget;

  OPEN actls;
  FETCH actls into l_actual_amount;
  CLOSE actls;

  l_available := l_budgeted_amount - l_actual_amount;

   IF (p_type = 'AVAIL')     THEN
    return l_available;
   ELSIF (p_type = 'ACTUAL') THEN
    return l_actual_amount;
   ELSIF (p_type = 'BDGT')   THEN
    return l_budgeted_amount;
   ELSE
    return 0;
   END IF;

END CALC_PREV_VALUE;

END HRI_OLTP_PMV_HDCNT_ORGMGR;


/
