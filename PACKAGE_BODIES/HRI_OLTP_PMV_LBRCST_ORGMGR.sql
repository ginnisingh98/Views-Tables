--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_LBRCST_ORGMGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_LBRCST_ORGMGR" AS
/* $Header: hrirplom.pkb 120.15 2006/03/14 20:12:44 rlpatil noship $ */

  l_currency         VARCHAR2(10);
  l_rateType        VARCHAR2(10);


-- ----------------------------------------------------
--  This procedure frames the Query for the Report Labor Cost Distribution By Organization.
-- ----------------------------------------------------

PROCEDURE GET_ORG_SQL(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql          OUT NOCOPY VARCHAR2,
                      x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sqltext               VARCHAR2(32767);
  l_custom_rec            BIS_QUERY_ATTRIBUTES;

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


l_currency := l_parameter_rec.currency_code;

IF l_currency =bis_common_parameters.get_currency_code              THEN
    l_rateType:=bis_common_parameters.get_rate_type;
ELSIF l_currency =bis_common_parameters.get_secondary_currency_code THEN
    l_rateType:=bis_common_parameters.get_secondary_rate_type;
END IF;



/* Build query */

l_sqltext :=
'SELECT                         -- Labor Cost Distribution By Organization
 ID                                                     HRI_P_CHAR2_GA
,name                                                   HRI_P_CHAR1_GA
,budgeted_amount                                        HRI_P_MEASURE1
,committed_amount                                       HRI_P_MEASURE2
,actual_amount                                          HRI_P_MEASURE3
,total                                                  HRI_P_MEASURE4
,total                                                  HRI_P_MEASURE7
,available                                              HRI_P_MEASURE5
,((available - prev_available)*100/decode(prev_available,0,1,prev_available)) HRI_P_MEASURE6
,SUM(budgeted_amount) OVER ()                            HRI_P_GRAND_TOTAL1
,SUM(committed_amount) OVER ()                           HRI_P_GRAND_TOTAL2
,SUM(actual_amount) OVER ()                              HRI_P_GRAND_TOTAL3
,SUM(total) OVER ()                                      HRI_P_GRAND_TOTAL4
,SUM(available) OVER ()                                  HRI_P_GRAND_TOTAL5
,((SUM(available) OVER() - SUM(prev_available) OVER())*100/decode(SUM(prev_available) OVER(),0,1,SUM(prev_available) OVER())) HRI_P_GRAND_TOTAL6
,1                                                      HRI_P_ORDER_BY_1
FROM
 (
  SELECT
   ORGANIZATION_ID                                                              id
  ,hr_general.decode_organization(ORGANIZATION_ID)                              name
  ,NVL(SUM(budgeted_amount), 0)                                                 budgeted_amount
  ,SUM(actual_amount)                                                           actual_amount
  ,SUM(committed_amount)                                                        committed_amount
  ,SUM(actual_amount) + SUM(committed_amount)                                   total
  ,SUM(budgeted_amount) - NVL((SUM(actual_amount) + SUM(committed_amount)),0)   available
  ,SUM(prev_available)                                                          prev_available
  FROM
    (
    (SELECT  ORGANIZATION_ID,
             null                                                      BUDGETED_AMOUNT,
	     HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
              (CURRENCY_CODE,
               '''||l_currency||''',
               &BIS_CURRENT_ASOF_DATE,
               SUM(ACTUAL_VALUE),
               '''||l_rateType||''')                                   ACTUAL_AMOUNT,
             HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
              (CURRENCY_CODE,
               '''||l_currency||''',
               &BIS_CURRENT_ASOF_DATE,
               SUM(COMMITMENT_VALUE),
               '''||l_rateType||''')                                   COMMITTED_AMOUNT,
             HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
              (CURRENCY_CODE,
               '''||l_currency||''',
               &BIS_CURRENT_ASOF_DATE,
            HRI_OLTP_PMV_LBRCST_ORGMGR.CALC_PREV_VALUE_ORG
               (&HRI_PERSON+HRI_PER_USRDR_H
               ,ORGANIZATION_ID
               ,&BIS_PREVIOUS_EFFECTIVE_START_DATE
               ,&BIS_PREVIOUS_EFFECTIVE_END_DATE
               ,''AVAIL''
               ),
               '''||l_rateType||''')                                    PREV_AVAILABLE
       FROM HRI_MDP_CMNTS_ACTLS_ORG_MV
      WHERE ORGMGR_ID = &HRI_PERSON+HRI_PER_USRDR_H
        AND EFFECTIVE_START_DATE <= &BIS_CURRENT_EFFECTIVE_END_DATE
        AND EFFECTIVE_END_DATE   >= &BIS_CURRENT_EFFECTIVE_START_DATE
      GROUP BY  ORGANIZATION_ID,
		CURRENCY_CODE )
     UNION ALL
     (SELECT ORGANIZATION_ID,
             HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
	      (CURRENCY_CODE,
               '''||l_currency||''',
               &BIS_CURRENT_ASOF_DATE,
               SUM(BUDGET_VALUE),
               '''||l_rateType||''')               BUDGETED_AMOUNT,
            null                                   ACTUAL_AMOUNT,
            null                                   COMMITTED_AMOUNT,
	    null                                   PREV_AVAILABLE
       FROM HRI_MDP_BDGTS_LBRCST_ORG_MV
      WHERE ORGMGR_ID             = &HRI_PERSON+HRI_PER_USRDR_H
        AND EFFECTIVE_START_DATE <= &BIS_CURRENT_EFFECTIVE_END_DATE
        AND EFFECTIVE_END_DATE   >= &BIS_CURRENT_EFFECTIVE_START_DATE
      GROUP BY  ORGANIZATION_ID,
		CURRENCY_CODE )
      )
      GROUP BY  ORGANIZATION_ID
      )
  &ORDER_BY_CLAUSE';


  x_custom_sql := l_SQLText;



END GET_ORG_SQL;


-- ----------------------------------------------------
--  This procedure calculates the previous period Budgeted, Commitment and actual Labor Cost values for
--  the Report Labor Cost Distribution By Organization.
-- ----------------------------------------------------

FUNCTION CALC_PREV_VALUE_ORG(p_ORGMGR_ID              NUMBER,
                             p_organization_id        NUMBER,
                             p_effective_start_date   DATE,
                             p_effective_end_date     DATE,
                             p_type                   VARCHAR2)
RETURN NUMBER IS

CURSOR prev_tot_budget IS
    SELECT SUM(bdg.BUDGET_VALUE)  budgeted_amount
      FROM HRI_MDP_BDGTS_LBRCST_ORG_MV bdg
    WHERE bdg.ORGMGR_ID = p_ORGMGR_ID
      AND bdg.EFFECTIVE_START_DATE <= p_effective_end_date
      AND bdg.EFFECTIVE_END_DATE   >= p_effective_start_date
      AND bdg.organization_id       = p_organization_id ;

CURSOR prev_tot_actual_cmmt IS
  SELECT SUM(act.ACTUAL_VALUE),
         SUM(act.COMMITMENT_VALUE)
    FROM HRI_MDP_CMNTS_ACTLS_ORG_MV act
   WHERE act.ORGMGR_ID = p_ORGMGR_ID
     AND act.EFFECTIVE_START_DATE <= p_effective_end_date
     AND act.EFFECTIVE_END_DATE   >= p_effective_start_date
     AND act.organization_id       = p_organization_id;

l_budgeted_amount number;
l_actual_amount number;
l_committed_amount number;
l_available number := 0;

BEGIN
  OPEN prev_tot_budget;
  FETCH prev_tot_budget INTO l_budgeted_amount;
  CLOSE prev_tot_budget;

  OPEN prev_tot_actual_cmmt;
  FETCH prev_tot_actual_cmmt into l_actual_amount,l_committed_amount;
  CLOSE prev_tot_actual_cmmt;

  l_available := nvl(l_budgeted_amount,0) - (nvl(l_actual_amount,0) + nvl(l_committed_amount,0));

   IF (p_type = 'AVAIL')     THEN
    return l_available;
   ELSIF (p_type = 'ACTUAL') THEN
    return l_actual_amount;
   ELSIF (p_type = 'CMMT')   THEN
    return l_committed_amount;
   ELSIF (p_type = 'BDGT')   THEN
    return l_budgeted_amount;
   ELSE
    return 0;
   END IF;

END CALC_PREV_VALUE_ORG;


-- ----------------------------------------------------
--  This procedure frames the Query for Labor Cost KPI.
-- ----------------------------------------------------

PROCEDURE GET_KPI_SQL(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql          OUT NOCOPY VARCHAR2,
                      x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sqltext               VARCHAR2(32767);
  l_custom_rec            BIS_QUERY_ATTRIBUTES;

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

l_currency:= l_parameter_rec.currency_code;

IF l_currency =bis_common_parameters.get_currency_code              THEN
    l_rateType:=bis_common_parameters.get_rate_type;
ELSIF l_currency =bis_common_parameters.get_secondary_currency_code THEN
    l_rateType:=bis_common_parameters.get_secondary_rate_type;
END IF;


/* Build query */

l_sqltext :=

'SELECT                            -- Labor Cost KPI
   ID                     VIEWBYID
  ,value                  VIEWBY
  ,c1                    HRI_P_MEASURE1
  ,c2                    HRI_P_MEASURE2
  ,c3                    HRI_P_MEASURE3
  ,c4                    HRI_P_MEASURE4
  ,c5                    HRI_P_MEASURE5
  ,c6                    HRI_P_MEASURE6
  ,c7                    HRI_P_MEASURE7
  ,c8                    HRI_P_MEASURE8
  ,c9                    HRI_P_MEASURE9
  ,sum(c2) over()        HRI_P_GRAND_TOTAL1
  ,sum(c7) over()        HRI_P_GRAND_TOTAL2
  ,SUM(c1) over()        HRI_P_GRAND_TOTAL3
  ,sum(c6) over()        HRI_P_GRAND_TOTAL4
  ,sum(c3) over()        HRI_P_GRAND_TOTAL5
  ,sum(c8) over()        HRI_P_GRAND_TOTAL6
  ,SUM(c5) over()        HRI_P_GRAND_TOTAL7
  ,sum(c9) over()        HRI_P_GRAND_TOTAL8
FROM
(
  SELECT  tab.ORGMGR_ID ID
          ,per.value
          ,tab.budgeted_amount                                              c1
          ,tab.actual_amount                                                c2
          ,tab.committed_amount                                             c3
          ,(tab.actual_amount + tab.committed_amount)                       c4
          ,tab.budgeted_amount - (tab.actual_amount + tab.committed_amount) c5
          ,tab.prev_budgeted                                                c6
          ,tab.prev_actual                                                  c7
          ,tab.prev_commited                                                c8
          ,tab.prev_budgeted - (tab.prev_actual + tab.prev_commited )       c9
    FROM
    (
    (
      SELECT  ORGMGR_ID,
              SUM(ACTUAL_AMOUNT)     ACTUAL_AMOUNT,
	      SUM(COMMITTED_AMOUNT)  COMMITTED_AMOUNT ,
	      SUM(PREV_ACTUAL)       PREV_ACTUAL,
	      SUM(PREV_COMMITED)     PREV_COMMITED,
              SUM(BUDGETED_AMOUNT)   BUDGETED_AMOUNT,
	      SUM(PREV_BUDGETED)     PREV_BUDGETED
        FROM
     (
     (
      SELECT ORGMGR_ID,
             null                                                      BUDGETED_AMOUNT,
	     null                                                      PREV_BUDGETED,
             HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
              (CURRENCY_CODE,
               '''||l_currency||''',
               &BIS_CURRENT_ASOF_DATE,
               SUM(ACTUAL_VALUE),
               '''||l_rateType||''')                                   ACTUAL_AMOUNT,
             HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
              (CURRENCY_CODE,
               '''||l_currency||''',
               &BIS_CURRENT_ASOF_DATE,
               SUM(COMMITMENT_VALUE),
               '''||l_rateType||''')                                   COMMITTED_AMOUNT,
             HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
              (CURRENCY_CODE,
               '''||l_currency||''',
               &BIS_CURRENT_ASOF_DATE,
               HRI_OLTP_PMV_LBRCST_ORGMGR.GET_KPI_MGR_TOTALS
               (&HRI_PERSON+HRI_PER_USRDR_H
                ,&BIS_PREVIOUS_EFFECTIVE_START_DATE
                ,&BIS_PREVIOUS_EFFECTIVE_END_DATE
                ,''ACTUAL''
               )    ,
              '''||l_rateType||''')                                   PREV_ACTUAL,
             HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
              (CURRENCY_CODE,
               '''||l_currency||''',
               &BIS_CURRENT_ASOF_DATE,
               HRI_OLTP_PMV_LBRCST_ORGMGR.GET_KPI_MGR_TOTALS
               (&HRI_PERSON+HRI_PER_USRDR_H
                ,&BIS_PREVIOUS_EFFECTIVE_START_DATE
                ,&BIS_PREVIOUS_EFFECTIVE_END_DATE
                ,''CMMT''
               )    ,
              '''||l_rateType||''')                                   PREV_COMMITED
       FROM HRI_MDP_CMNTS_ACTLS_ORG_MV
      WHERE ORGMGR_ID = &HRI_PERSON+HRI_PER_USRDR_H
        AND EFFECTIVE_START_DATE <= &BIS_CURRENT_EFFECTIVE_END_DATE
        AND EFFECTIVE_END_DATE   >= &BIS_CURRENT_EFFECTIVE_START_DATE
	AND ORGANIZATION_ID IN (SELECT SUB_ORGANIZATION_ID
	                          FROM HRI_CS_SUPH_ORGMGR_CT
				 WHERE SUP_PERSON_ID=&HRI_PERSON+HRI_PER_USRDR_H
				   AND SUB_PERSON_ID = SUP_PERSON_ID
				   AND SUB_RELATIVE_LEVEL = 0
				   AND &BIS_CURRENT_ASOF_DATE BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE)
      GROUP BY  ORGMGR_ID,
		CURRENCY_CODE )
      UNION ALL
     (SELECT ORGMGR_ID,
             HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
	      (CURRENCY_CODE,
               '''||l_currency||''',
               &BIS_CURRENT_ASOF_DATE,
               SUM(BUDGET_VALUE),
               '''||l_rateType||''')                budgeted_amount,
            HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
             (CURRENCY_CODE,
              '''||l_currency||''',
              &BIS_CURRENT_ASOF_DATE,
              HRI_OLTP_PMV_LBRCST_ORGMGR.GET_KPI_MGR_TOTALS
               (&HRI_PERSON+HRI_PER_USRDR_H
                ,&BIS_PREVIOUS_EFFECTIVE_START_DATE
                ,&BIS_PREVIOUS_EFFECTIVE_END_DATE
                ,''BDGT''
               ),
              '''||l_rateType||''')                                    prev_budgeted,
	      null                                                     ACTUAL_AMOUNT,
	      null                                                     COMMITTED_AMOUNT,
	      null                                                     PREV_ACTUAL,
	      null                                                     PREV_COMMITED

       FROM HRI_MDP_BDGTS_LBRCST_ORG_MV
      WHERE ORGMGR_ID = &HRI_PERSON+HRI_PER_USRDR_H
        AND EFFECTIVE_START_DATE <= &BIS_CURRENT_EFFECTIVE_END_DATE
        AND EFFECTIVE_END_DATE   >= &BIS_CURRENT_EFFECTIVE_START_DATE
	AND ORGANIZATION_ID IN (SELECT SUB_ORGANIZATION_ID
	                          FROM HRI_CS_SUPH_ORGMGR_CT
				 WHERE SUP_PERSON_ID=&HRI_PERSON+HRI_PER_USRDR_H
				   AND SUB_PERSON_ID = SUP_PERSON_ID
				   AND SUB_RELATIVE_LEVEL = 0
				   AND &BIS_CURRENT_ASOF_DATE BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE)

      GROUP BY  ORGMGR_ID,
		CURRENCY_CODE )

      )
      GROUP BY  ORGMGR_ID
      )
      UNION ALL
     (
      SELECT  ORGMGR_ID,
              SUM(ACTUAL_AMOUNT)     ACTUAL_AMOUNT,
	      SUM(COMMITTED_AMOUNT)  COMMITTED_AMOUNT ,
	      SUM(PREV_ACTUAL)       PREV_ACTUAL,
	      SUM(PREV_COMMITED)     PREV_COMMITED,
              SUM(BUDGETED_AMOUNT)   BUDGETED_AMOUNT,
	      SUM(PREV_BUDGETED)     PREV_BUDGETED
       FROM
       (
       (
      SELECT ORGMGR_ID,
             null                                                      BUDGETED_AMOUNT,
	     null                                                      PREV_BUDGETED,
             HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
              (CURRENCY_CODE,
               '''||l_currency||''',
               &BIS_CURRENT_ASOF_DATE,
               SUM(ACTUAL_VALUE),
               '''||l_rateType||''')                                   ACTUAL_AMOUNT,
             HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
              (CURRENCY_CODE,
               '''||l_currency||''',
               &BIS_CURRENT_ASOF_DATE,
               SUM(COMMITMENT_VALUE),
               '''||l_rateType||''')                                   COMMITTED_AMOUNT,
             HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
              (CURRENCY_CODE,
               '''||l_currency||''',
               &BIS_CURRENT_ASOF_DATE,
               HRI_OLTP_PMV_LBRCST_ORGMGR.GET_KPI_TOTALS
               (&HRI_PERSON+HRI_PER_USRDR_H
	        ,&BIS_PREVIOUS_EFFECTIVE_START_DATE
                ,&BIS_PREVIOUS_EFFECTIVE_END_DATE
                ,''ACTUAL''
               )    ,
              '''||l_rateType||''')                                   PREV_ACTUAL,
             HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
              (CURRENCY_CODE,
               '''||l_currency||''',
               &BIS_CURRENT_ASOF_DATE,
               HRI_OLTP_PMV_LBRCST_ORGMGR.GET_KPI_TOTALS
               (&HRI_PERSON+HRI_PER_USRDR_H
	        ,&BIS_PREVIOUS_EFFECTIVE_START_DATE
                ,&BIS_PREVIOUS_EFFECTIVE_END_DATE
                ,''CMMT''
               )    ,
              '''||l_rateType||''')                                   PREV_COMMITED
       FROM HRI_MDP_CMNTS_ACTLS_MV
      WHERE ORGMGR_ID          IN      (SELECT  SUB_PERSON_ID FROM HRI_CS_SUPH_ORGMGR_CT WHERE SUP_PERSON_ID = &HRI_PERSON+HRI_PER_USRDR_H AND SUB_RELATIVE_LEVEL =1 AND &BIS_CURRENT_ASOF_DATE BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE)
      AND EFFECTIVE_START_DATE <= &BIS_CURRENT_EFFECTIVE_END_DATE
      AND EFFECTIVE_END_DATE   >= &BIS_CURRENT_EFFECTIVE_START_DATE
      GROUP BY  ORGMGR_ID,
		CURRENCY_CODE )
      UNION ALL
     (SELECT ORGMGR_ID,
             HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
	      (CURRENCY_CODE,
               '''||l_currency||''',
               &BIS_CURRENT_ASOF_DATE,
               SUM(BUDGET_VALUE),
               '''||l_rateType||''')                                   BUDGETED_AMOUNT,
            HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
             (CURRENCY_CODE,
              '''||l_currency||''',
              &BIS_CURRENT_ASOF_DATE,
              HRI_OLTP_PMV_LBRCST_ORGMGR.GET_KPI_TOTALS
               (&HRI_PERSON+HRI_PER_USRDR_H
	        ,&BIS_PREVIOUS_EFFECTIVE_START_DATE
                ,&BIS_PREVIOUS_EFFECTIVE_END_DATE
                ,''BDGT''
               ),
              '''||l_rateType||''')                                    PREV_BUDGETED,
	      null                                                     ACTUAL_AMOUNT,
	      null                                                     COMMITTED_AMOUNT,
	      null                                                     PREV_ACTUAL,
	      null                                                     PREV_COMMITED
       FROM HRI_MDP_BDGTS_LBRCST_MV
      WHERE ORGMGR_ID            IN      (SELECT  SUB_PERSON_ID FROM HRI_CS_SUPH_ORGMGR_CT WHERE SUP_PERSON_ID = &HRI_PERSON+HRI_PER_USRDR_H AND SUB_RELATIVE_LEVEL =1 AND &BIS_CURRENT_ASOF_DATE BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE)
        AND EFFECTIVE_START_DATE <= &BIS_CURRENT_EFFECTIVE_END_DATE
        AND EFFECTIVE_END_DATE   >= &BIS_CURRENT_EFFECTIVE_START_DATE
      GROUP BY  ORGMGR_ID,
                CURRENCY_CODE )
      )
      GROUP BY ORGMGR_ID
      )
      ) tab,
      HRI_DBI_CL_PER_N_V per
      WHERE tab.orgmgr_id = per.ID
        AND &BIS_CURRENT_ASOF_DATE BETWEEN per.EFFECTIVE_START_DATE AND per.EFFECTIVE_END_DATE
    )';


  x_custom_sql := l_SQLText;

END GET_KPI_SQL;


-- ----------------------------------------------------
--  This procedure calculates the Budgeted, Commitment and actual Labor Cost Grand Totals for
--  the Labor Cost KPI.
-- ----------------------------------------------------

FUNCTION GET_KPI_TOTALS(p_ORGMGR_ID              NUMBER,
                        p_effective_start_date   DATE,
                        p_effective_end_date     DATE,
                        p_type                   VARCHAR2
                        )
RETURN NUMBER IS

CURSOR Budget IS
   SELECT SUM(bdg.BUDGET_VALUE) budgeted_amount
     FROM HRI_MDP_BDGTS_LBRCST_MV bdg
    WHERE bdg.ORGMGR_ID = p_ORGMGR_ID
      AND bdg.EFFECTIVE_START_DATE <= p_effective_end_date
      AND bdg.EFFECTIVE_END_DATE   >= p_effective_start_date;

CURSOR actls_cmnts IS
  SELECT SUM(act.ACTUAL_VALUE),
         SUM(act.COMMITMENT_VALUE)
    FROM HRI_MDP_CMNTS_ACTLS_MV act
   WHERE act.ORGMGR_ID = p_ORGMGR_ID
     AND act.EFFECTIVE_START_DATE <= p_effective_end_date
     AND act.EFFECTIVE_END_DATE   >= p_effective_start_date;

l_budgeted_amount number;
l_actual_amount number;
l_committed_amount number;
l_available number := 0;

BEGIN

  OPEN Budget;
  FETCH Budget INTO l_budgeted_amount;
  CLOSE Budget;

  OPEN actls_cmnts;
  FETCH actls_cmnts into l_actual_amount,l_committed_amount;
  CLOSE actls_cmnts;

  l_available := nvl(l_budgeted_amount,0) - (nvl(l_actual_amount,0) + nvl(l_committed_amount,0));

   IF (p_type = 'AVAIL')     THEN
    return l_available;
   ELSIF (p_type = 'ACTUAL') THEN
    return l_actual_amount;
   ELSIF (p_type = 'CMMT')   THEN
    return l_committed_amount;
   ELSIF (p_type = 'BDGT')   THEN
    return l_budgeted_amount;
   ELSE
    return 0;
   END IF;

END GET_KPI_TOTALS;


-- ----------------------------------------------------
--  This procedure calculates the Budgeted, Commitment and actual Labor Cost Grand Totals of
--  the organizations directly owned by the Manager for the Labor Cost KPI.
-- ----------------------------------------------------

FUNCTION GET_KPI_MGR_TOTALS(p_ORGMGR_ID              NUMBER,
                            p_effective_start_date   DATE,
                            p_effective_end_date     DATE,
                            p_type                   VARCHAR2
                            )
RETURN NUMBER IS

CURSOR Budget IS
   SELECT SUM(bdg.BUDGET_VALUE) budgeted_amount
     FROM HRI_MDP_BDGTS_LBRCST_ORG_MV bdg
    WHERE bdg.ORGMGR_ID = p_ORGMGR_ID
      AND bdg.EFFECTIVE_START_DATE <= p_effective_end_date
      AND bdg.EFFECTIVE_END_DATE   >= p_effective_start_date
      AND ORGANIZATION_ID IN   (SELECT SUB_ORGANIZATION_ID
	                          FROM HRI_CS_SUPH_ORGMGR_CT
				 WHERE SUP_PERSON_ID=p_ORGMGR_ID
				   AND SUB_PERSON_ID = SUP_PERSON_ID
				   AND SUB_RELATIVE_LEVEL = 0
				   AND p_effective_end_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE);


CURSOR actls_cmnts IS
  SELECT SUM(act.ACTUAL_VALUE),
         SUM(act.COMMITMENT_VALUE)
    FROM HRI_MDP_CMNTS_ACTLS_ORG_MV act
   WHERE act.ORGMGR_ID = p_ORGMGR_ID
     AND act.EFFECTIVE_START_DATE <= p_effective_end_date
     AND act.EFFECTIVE_END_DATE   >= p_effective_start_date
     AND ORGANIZATION_ID IN    (SELECT SUB_ORGANIZATION_ID
	                          FROM HRI_CS_SUPH_ORGMGR_CT
				 WHERE SUP_PERSON_ID=p_ORGMGR_ID
				   AND SUB_PERSON_ID = SUP_PERSON_ID
				   AND SUB_RELATIVE_LEVEL = 0
				   AND p_effective_end_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE);
l_budgeted_amount number;
l_actual_amount number;
l_committed_amount number;
l_available number := 0;

BEGIN

  OPEN Budget;
  FETCH Budget INTO l_budgeted_amount;
  CLOSE Budget;

  OPEN actls_cmnts;
  FETCH actls_cmnts into l_actual_amount,l_committed_amount;
  CLOSE actls_cmnts;

  l_available := nvl(l_budgeted_amount,0) - (nvl(l_actual_amount,0) + nvl(l_committed_amount,0));

   IF (p_type = 'AVAIL')     THEN
    return l_available;
   ELSIF (p_type = 'ACTUAL') THEN
    return l_actual_amount;
   ELSIF (p_type = 'CMMT')   THEN
    return l_committed_amount;
   ELSIF (p_type = 'BDGT')   THEN
    return l_budgeted_amount;
   ELSE
    return 0;
   END IF;

END GET_KPI_MGR_TOTALS;


-- ----------------------------------------------------
--  This procedure calculates the previous period Budgeted, Commitment and actual Labor Cost values for
--  the Report Labor Cost Distribution By Position.
-- ----------------------------------------------------

FUNCTION CALC_PREV_VALUE_POS(p_ORGMGR_ID              NUMBER,
                             p_organization_id        NUMBER,
                             p_effective_start_date   DATE,
                             p_effective_end_date     DATE,
                             p_position_id            NUMBER )
RETURN NUMBER IS

CURSOR prev_tot_budget IS
 SELECT SUM(bdg.BUDGET_VALUE) budgeted_amount
   FROM HRI_MDP_BDGTS_LBRCST_ORGMGR_CT bdg
  WHERE bdg.ORGMGR_ID             = p_ORGMGR_ID
    AND bdg.organization_id       = decode(p_organization_id,0,bdg.ORGANIZATION_ID,p_organization_id)
    AND bdg.position_id           = p_position_id
    AND bdg.EFFECTIVE_START_DATE <= p_effective_end_date
    AND bdg.EFFECTIVE_END_DATE   >= p_effective_start_date;

CURSOR prev_tot_actual_cmmt IS
 SELECT SUM(act.ACTUAL_VALUE),
        SUM(act.COMMITMENT_VALUE)
   FROM HRI_MDP_CMNTS_ACTLS_ORGMGR_CT act
  WHERE act.ORGMGR_ID             = p_ORGMGR_ID
    AND act.organization_id       = decode(p_organization_id,0,act.ORGANIZATION_ID,p_organization_id)
    AND act.position_id           = p_position_id
    AND act.EFFECTIVE_START_DATE <= p_effective_end_date
    AND act.EFFECTIVE_END_DATE   >= p_effective_start_date;

l_budgeted_amount number;
l_actual_amount number;
l_committed_amount number;
l_available number := 0;

BEGIN
  OPEN prev_tot_budget;
  FETCH prev_tot_budget INTO l_budgeted_amount;
  CLOSE prev_tot_budget;

  OPEN prev_tot_actual_cmmt;
  FETCH prev_tot_actual_cmmt INTO l_actual_amount,l_committed_amount;
  CLOSE prev_tot_actual_cmmt;


  l_available := nvl(l_budgeted_amount,0) - (nvl(l_actual_amount,0) + nvl(l_committed_amount,0));

 RETURN l_available;

END CALC_PREV_VALUE_POS;


-- ----------------------------------------------------
--  This procedure frames the Query for the Report Labor Cost Distribution By Position.
-- ----------------------------------------------------

PROCEDURE GET_POS_SQL(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql          OUT NOCOPY VARCHAR2,
                      x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sqltext               VARCHAR2(32767);
  l_custom_rec            BIS_QUERY_ATTRIBUTES;

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;


BEGIN

/* Initialize out parameters */

  l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Get common parameter values */
/*  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_page_parameter_tbl,
         p_parameter_rec       => l_parameter_rec,
         p_bind_tab            => l_bind_tab); */

 hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_page_parameter_tbl,
         p_parameter_rec       => l_parameter_rec,
         p_bind_tab            => l_bind_tab);

l_currency:= l_parameter_rec.currency_code;

IF l_currency =bis_common_parameters.get_currency_code              THEN
    l_rateType:=bis_common_parameters.get_rate_type;
ELSIF l_currency =bis_common_parameters.get_secondary_currency_code THEN
    l_rateType:=bis_common_parameters.get_secondary_rate_type;
END IF;

l_sqltext :=
'SELECT                            -- Labor Cost Distribution By Position
   pos.name                                      HRI_P_CHAR1_GA
  ,tab.budgeted_amount                           HRI_P_MEASURE1
  ,tab.committed_amount                          HRI_P_MEASURE2
  ,tab.actual_amount                             HRI_P_MEASURE3
  ,tab.total                                     HRI_P_MEASURE4
  ,tab.total                                     HRI_P_MEASURE7
  ,tab.available                                 HRI_P_MEASURE5
  ,(tab.available - tab.prev_available)*100/decode(tab.prev_available,0,1,tab.prev_available)   HRI_P_MEASURE6
  ,SUM(tab.budgeted_amount) OVER ()              HRI_P_GRAND_TOTAL1
  ,SUM(tab.committed_amount) OVER ()              HRI_P_GRAND_TOTAL2
  ,SUM(tab.actual_amount) OVER ()                 HRI_P_GRAND_TOTAL3
  ,SUM(tab.total) OVER ()                         HRI_P_GRAND_TOTAL4
  ,SUM(tab.available) OVER ()                     HRI_P_GRAND_TOTAL5
  ,SUM((tab.available - tab.prev_available)*100/decode(tab.prev_available,0,1,tab.prev_available) ) OVER ()           HRI_P_GRAND_TOTAL6
  ,tab.id                                         HRI_P_CHAR3_GA
  ,1                                              HRI_P_ORDER_BY_1
FROM
 (
  SELECT
   POSITION_ID                                                                  id
  ,SUM(budgeted_amount)                                                         budgeted_amount
  ,SUM(actual_amount)                                                           actual_amount
  ,SUM(committed_amount)                                                        committed_amount
  ,SUM(actual_amount) + SUM(committed_amount)                                   total
  ,SUM(budgeted_amount) - NVL((SUM(actual_amount) + SUM(committed_amount)),0)   available
  ,SUM(prev_available)                                                          prev_available
  FROM
    (
    (SELECT  POSITION_ID,
             null                                                      BUDGETED_AMOUNT,
	     HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
              (CURRENCY_CODE,
               '''||l_currency||''',
               &BIS_CURRENT_ASOF_DATE,
               SUM(ACTUAL_VALUE),
               '''||l_rateType||''')                                   ACTUAL_AMOUNT,
             HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
              (CURRENCY_CODE,
               '''||l_currency||''',
               &BIS_CURRENT_ASOF_DATE,
               SUM(COMMITMENT_VALUE),
               '''||l_rateType||''')                                   COMMITTED_AMOUNT,
             HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
              (CURRENCY_CODE,
               '''||l_currency||''',
               &BIS_CURRENT_ASOF_DATE,
             HRI_OLTP_PMV_LBRCST_ORGMGR.CALC_PREV_VALUE_POS
               (&HRI_PERSON+HRI_PER_USRDR_H
                ,&HRI_P_CHAR2_GA
                ,&BIS_PREVIOUS_EFFECTIVE_START_DATE
                ,&BIS_PREVIOUS_EFFECTIVE_END_DATE
		,POSITION_ID
               ),
               '''||l_rateType||''')                                    PREV_AVAILABLE
       FROM HRI_MDP_CMNTS_ACTLS_ORGMGR_CT
      WHERE ORGMGR_ID = &HRI_PERSON+HRI_PER_USRDR_H
        AND EFFECTIVE_START_DATE <= &BIS_CURRENT_EFFECTIVE_END_DATE
        AND EFFECTIVE_END_DATE   >= &BIS_CURRENT_EFFECTIVE_START_DATE
        AND ORGANIZATION_ID       = decode(&HRI_P_CHAR2_GA,0,ORGANIZATION_ID,&HRI_P_CHAR2_GA)
      GROUP BY  POSITION_ID,
		CURRENCY_CODE )
     UNION ALL
     (SELECT POSITION_ID,
             HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
	      (CURRENCY_CODE,
               '''||l_currency||''',
               &BIS_CURRENT_ASOF_DATE,
               SUM(BUDGET_VALUE),
               '''||l_rateType||''')               BUDGETED_AMOUNT,
            null                                   ACTUAL_AMOUNT,
            null                                   COMMITTED_AMOUNT,
	    null                                   PREV_AVAILABLE
       FROM HRI_MDP_BDGTS_LBRCST_ORGMGR_CT
      WHERE ORGMGR_ID             = &HRI_PERSON+HRI_PER_USRDR_H
        AND EFFECTIVE_START_DATE <= &BIS_CURRENT_EFFECTIVE_END_DATE
        AND EFFECTIVE_END_DATE   >= &BIS_CURRENT_EFFECTIVE_START_DATE
        AND ORGANIZATION_ID       = decode(&HRI_P_CHAR2_GA,0,ORGANIZATION_ID,&HRI_P_CHAR2_GA)
      GROUP BY  POSITION_ID,
		CURRENCY_CODE )
      )
      GROUP BY  POSITION_ID
      )tab,
      HR_ALL_POSITIONS_F pos
  WHERE pos.POSITION_ID = tab.ID
    AND &BIS_CURRENT_ASOF_DATE BETWEEN pos.EFFECTIVE_START_DATE AND pos.EFFECTIVE_END_DATE
  &ORDER_BY_CLAUSE';

  x_custom_sql := l_SQLText;

END GET_POS_SQL;


-- ----------------------------------------------------
--  This procedure frames the Query for the Report Position Occupancy Report.
-- ----------------------------------------------------

PROCEDURE GET_POS_DTL_SQL(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql          OUT NOCOPY VARCHAR2,
                          x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_lnk_profile_chk       NUMBER;
  l_lnk_emp_name          VARCHAR2(255);
  l_sqltext               VARCHAR2(32767);
  l_custom_rec            BIS_QUERY_ATTRIBUTES;

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

l_currency:= l_parameter_rec.currency_code;

IF l_currency =bis_common_parameters.get_currency_code THEN
    l_rateType:=bis_common_parameters.get_rate_type;
ELSIF l_currency =bis_common_parameters.get_secondary_currency_code THEN
    l_rateType:=bis_common_parameters.get_secondary_rate_type;
END IF;

          l_lnk_profile_chk := hri_oltp_pmv_util_pkg.chk_emp_dir_lnk(p_parameter_rec  => l_parameter_rec
                                                                 ,p_bind_tab       => l_bind_tab);

	  IF (l_lnk_profile_chk = 1 AND l_parameter_rec.time_curr_end_date = TRUNC(SYSDATE) ) THEN
		l_lnk_emp_name := 'pFunctionName=HR_EMPDIR_EMPDTL_PROXY_SS&pId=HRI_P_CHAR9_GA&OAPB=FII_HR_BRAND_TEXT';
	  ELSE
	    l_lnk_emp_name := '';
	  END IF ;

/* Build query */
l_sqltext :=
'SELECT                             -- Position Occupancy Report
  a.value                                              HRI_P_CHAR1_GA
  ,a.organization                                      HRI_P_MEASURE1
  ,a.job                                               HRI_P_MEASURE2
  ,a.position                                          HRI_P_MEASURE3
  ,a.grade                                             HRI_P_MEASURE4
  ,a.committed_amount                                  HRI_P_MEASURE5
  ,a.actual_amount                                     HRI_P_MEASURE6
  ,a.actual_amount + a.committed_amount                HRI_P_MEASURE7
  ,SUM(a.committed_amount) OVER ()                     HRI_P_GRAND_TOTAL1
  ,SUM(a.actual_amount) OVER ()                        HRI_P_GRAND_TOTAL2
  ,SUM(a.actual_amount + a.committed_amount) OVER ()   HRI_P_GRAND_TOTAL3
  ,a.id                                                HRI_P_CHAR9_GA
  ,'''||l_lnk_emp_name||'''                            HRI_P_DRILL_URL1
  ,a.order_by                                          HRI_P_ORDER_BY_1
FROM
 (SELECT
     paf.value
     ,paf.id
     ,1                                                       order_by
     ,hr_general.decode_organization(act.organization_id)     organization
     ,pos.name                                                position
     , HR_GENERAL.DECODE_JOB(act.job_id)                      job
     , HR_GENERAL.DECODE_GRADE(act.grade_id)                  grade
     , HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
       (act.CURRENCY_CODE,
        '''||l_currency||''',
        &BIS_CURRENT_ASOF_DATE,
        SUM(act.ACTUAL_VALUE),
        '''||l_rateType||''')                                  actual_amount
     ,HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
      (act.CURRENCY_CODE,
       '''||l_currency||''',
       &BIS_CURRENT_ASOF_DATE,
       SUM(act.COMMITMENT_VALUE),
       '''||l_rateType||''')                                   committed_amount
  FROM HRI_MDP_CMNTS_ACTLS_ORGMGR_CT act,
       PER_ALL_ASSIGNMENTS_F paa,
       HRI_CL_PER_V          paf,
       HR_ALL_POSITIONS_F    pos
 WHERE act.ORGMGR_ID = &HRI_PERSON+HRI_PER_USRDR_H
   AND act.EFFECTIVE_START_DATE <= &BIS_CURRENT_EFFECTIVE_END_DATE
   AND act.EFFECTIVE_END_DATE   >= &BIS_CURRENT_EFFECTIVE_START_DATE
   AND act.ORGANIZATION_ID       = decode(&HRI_P_CHAR2_GA,0,act.ORGANIZATION_ID,&HRI_P_CHAR2_GA)
   AND act.POSITION_ID           = decode(&HRI_P_CHAR3_GA,0,act.POSITION_ID,&HRI_P_CHAR3_GA)
   AND paf.ID                    = paa.PERSON_ID
   AND paa.ASSIGNMENT_ID         = act.ASSIGNMENT_ID
   AND pos.POSITION_ID           = act.POSITION_ID
   AND &BIS_CURRENT_ASOF_DATE BETWEEN pos.EFFECTIVE_START_DATE AND pos.EFFECTIVE_END_DATE
   AND &BIS_CURRENT_ASOF_DATE BETWEEN paa.EFFECTIVE_START_DATE AND paa.EFFECTIVE_END_DATE
   AND &BIS_CURRENT_ASOF_DATE BETWEEN paf.EFFECTIVE_START_DATE AND paf.EFFECTIVE_END_DATE
 GROUP BY act.ASSIGNMENT_ID,
          paf.value,
          paf.id,
	  pos.name,
	  act.CURRENCY_CODE,
	  act.ORGANIZATION_ID,
          act.JOB_ID,
	  act.GRADE_ID,
	  1
  ) a
  WHERE 1=1 &ORDER_BY_CLAUSE';

  x_custom_sql := l_SQLText;

END GET_POS_DTL_SQL;


-- ----------------------------------------------------
--  This procedure calculates the previous period Budgeted, Commitment and actual Labor Cost values for
--  the Report Labor Cost Distribution By Element.
-- ----------------------------------------------------

FUNCTION CALC_PREV_VALUE_ELE(p_ORGMGR_ID             NUMBER,
                             p_organization_id       NUMBER,
                             p_position_id           NUMBER,
                             p_effective_start_date  DATE,
                             p_effective_end_date    DATE,
                             p_element_type_id       NUMBER)
RETURN NUMBER IS

CURSOR prev_tot_budget IS
    SELECT SUM(bdg.BUDGET_VALUE) budgeted_amount
      FROM HRI_MDP_BDGTS_LBRCST_ORGMGR_CT bdg
     WHERE bdg.ORGMGR_ID             = p_ORGMGR_ID
       AND bdg.ORGANIZATION_ID       = decode(p_organization_id,0,bdg.ORGANIZATION_ID,p_organization_id)
       AND bdg.POSITION_ID           = decode(p_position_id,0,bdg.POSITION_ID,p_position_id)
       AND bdg.ELEMENT_TYPE_ID       = P_ELEMENT_TYPE_ID
       AND bdg.EFFECTIVE_START_DATE <= p_effective_end_date
       AND bdg.EFFECTIVE_END_DATE   >= p_effective_start_date;


CURSOR prev_tot_actual_cmmt IS
    SELECT SUM(act.ACTUAL_VALUE),
           SUM(act.COMMITMENT_VALUE)
      FROM HRI_MDP_CMNTS_ACTLS_ORGMGR_CT act
     WHERE act.ORGMGR_ID             = p_ORGMGR_ID
       AND act.ORGANIZATION_ID       = decode(p_organization_id,0,act.ORGANIZATION_ID,p_organization_id)
       AND act.POSITION_ID           = decode(p_position_id,0,act.POSITION_ID,p_position_id)
       AND act.ELEMENT_TYPE_ID       = P_ELEMENT_TYPE_ID
       AND act.EFFECTIVE_START_DATE <= p_effective_end_date
       AND act.EFFECTIVE_END_DATE   >= p_effective_start_date;

l_budgeted_amount number;
l_actual_amount number;
l_committed_amount number;
l_available number := 0;

BEGIN
  OPEN prev_tot_budget;
  FETCH prev_tot_budget INTO l_budgeted_amount;
  CLOSE prev_tot_budget;

  OPEN prev_tot_actual_cmmt;
  FETCH prev_tot_actual_cmmt INTO l_actual_amount,l_committed_amount;
  CLOSE prev_tot_actual_cmmt;


  l_available := nvl(l_budgeted_amount,0) - (nvl(l_actual_amount,0) + nvl(l_committed_amount,0));


    RETURN l_available;

END CALC_PREV_VALUE_ELE;


-- ----------------------------------------------------
--  This procedure frames the Query for the Report Labor Cost Distribution By Element.
-- ----------------------------------------------------

PROCEDURE GET_ELE_SQL(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql          OUT NOCOPY VARCHAR2,
                      x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sqltext               VARCHAR2(32767);
  l_custom_rec            BIS_QUERY_ATTRIBUTES;

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

l_currency:= l_parameter_rec.currency_code;

IF l_currency =bis_common_parameters.get_currency_code THEN
    l_rateType:=bis_common_parameters.get_rate_type;
ELSIF l_currency =bis_common_parameters.get_secondary_currency_code THEN
    l_rateType:=bis_common_parameters.get_secondary_rate_type;
END IF;

 l_sqltext :=

'SELECT                           -- Labor Cost Distribution By Element
 tab.id                                                     HRI_P_CHAR3_GA
,ele.element_name                                           HRI_P_CHAR1_GA
,tab.budgeted_amount                                        HRI_P_MEASURE1
,tab.committed_amount                                       HRI_P_MEASURE2
,tab.actual_amount                                          HRI_P_MEASURE3
,tab.total                                                  HRI_P_MEASURE4
,tab.total                                                  HRI_P_MEASURE7
,tab.available                                              HRI_P_MEASURE5
,((tab.available - tab.prev_available)*100/(decode(tab.prev_available,0,1,tab.prev_available)))                        HRI_P_MEASURE6
,SUM(tab.budgeted_amount) OVER ()                           HRI_P_GRAND_TOTAL1
,SUM(tab.committed_amount) OVER ()                           HRI_P_GRAND_TOTAL2
,SUM(tab.actual_amount) OVER ()                              HRI_P_GRAND_TOTAL3
,SUM(tab.total) OVER ()                                      HRI_P_GRAND_TOTAL4
,SUM(tab.available) OVER ()                                  HRI_P_GRAND_TOTAL5
,SUM(((tab.available - tab.prev_available)*100/(decode(tab.prev_available,0,1,tab.prev_available))) ) OVER ()           HRI_P_GRAND_TOTAL6
,tab.order_by                                               HRI_P_ORDER_BY_1
FROM
 (
  SELECT
   ELEMENT_TYPE_ID                                                              id
  ,1                                                                            order_by
  ,SUM(budgeted_amount)                                                         budgeted_amount
  ,SUM(actual_amount)                                                           actual_amount
  ,SUM(committed_amount)                                                        committed_amount
  ,SUM(actual_amount) + SUM(committed_amount)                                   total
  ,SUM(budgeted_amount) - NVL((SUM(actual_amount) + SUM(committed_amount)),0)   available
  ,SUM(prev_available)                                                          prev_available
 FROM
    (
    (SELECT  ELEMENT_TYPE_ID,
             null                                                      BUDGETED_AMOUNT,
	     HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
              (CURRENCY_CODE,
               '''||l_currency||''',
               &BIS_CURRENT_ASOF_DATE,
               SUM(ACTUAL_VALUE),
               '''||l_rateType||''')                                   ACTUAL_AMOUNT,
             HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
              (CURRENCY_CODE,
               '''||l_currency||''',
               &BIS_CURRENT_ASOF_DATE,
               SUM(COMMITMENT_VALUE),
               '''||l_rateType||''')                                   COMMITTED_AMOUNT,
             HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
              (CURRENCY_CODE,
               '''||l_currency||''',
               &BIS_CURRENT_ASOF_DATE,
               HRI_OLTP_PMV_LBRCST_ORGMGR.CALC_PREV_VALUE_ELE
                (&HRI_PERSON+HRI_PER_USRDR_H
                 ,&HRI_P_CHAR2_GA
		 ,&HRI_P_CHAR4_GA
                 ,&BIS_PREVIOUS_EFFECTIVE_START_DATE
                 ,&BIS_PREVIOUS_EFFECTIVE_END_DATE
		 ,ELEMENT_TYPE_ID
                ) ,
                '''||l_rateType||''')                                    PREV_AVAILABLE
       FROM HRI_MDP_CMNTS_ACTLS_ORGMGR_CT
      WHERE ORGMGR_ID = &HRI_PERSON+HRI_PER_USRDR_H
        AND EFFECTIVE_START_DATE <= &BIS_CURRENT_EFFECTIVE_END_DATE
        AND EFFECTIVE_END_DATE   >= &BIS_CURRENT_EFFECTIVE_START_DATE
        AND ORGANIZATION_ID       = decode(&HRI_P_CHAR2_GA,0,ORGANIZATION_ID,&HRI_P_CHAR2_GA)
        AND POSITION_ID           = decode(&HRI_P_CHAR4_GA,0,POSITION_ID,&HRI_P_CHAR4_GA)
      GROUP BY  ELEMENT_TYPE_ID,
		CURRENCY_CODE )
     UNION ALL
     (SELECT ELEMENT_TYPE_ID,
             HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
	      (CURRENCY_CODE,
               '''||l_currency||''',
               &BIS_CURRENT_ASOF_DATE,
               SUM(BUDGET_VALUE),
               '''||l_rateType||''')               BUDGETED_AMOUNT,
            null                                   ACTUAL_AMOUNT,
            null                                   COMMITTED_AMOUNT,
	    null                                   PREV_AVAILABLE
       FROM HRI_MDP_BDGTS_LBRCST_ORGMGR_CT
      WHERE ORGMGR_ID             = &HRI_PERSON+HRI_PER_USRDR_H
        AND EFFECTIVE_START_DATE <= &BIS_CURRENT_EFFECTIVE_END_DATE
        AND EFFECTIVE_END_DATE   >= &BIS_CURRENT_EFFECTIVE_START_DATE
        AND ORGANIZATION_ID       = decode(&HRI_P_CHAR2_GA,0,ORGANIZATION_ID,&HRI_P_CHAR2_GA)
        AND POSITION_ID           = decode(&HRI_P_CHAR4_GA,0,POSITION_ID,&HRI_P_CHAR4_GA)
      GROUP BY  ELEMENT_TYPE_ID,
		CURRENCY_CODE )
      )
      GROUP BY  ELEMENT_TYPE_ID
      )tab,
      PAY_ELEMENT_TYPES_F ele
WHERE ele.ELEMENT_TYPE_ID       = tab.ID
  AND &BIS_CURRENT_ASOF_DATE BETWEEN ele.EFFECTIVE_START_DATE AND ele.EFFECTIVE_END_DATE
&ORDER_BY_CLAUSE';



x_custom_sql := l_SQLText;

END GET_ELE_SQL;


-- ----------------------------------------------------
--  This procedure calculates the previous period Budgeted, Commitment and actual Labor Cost values for
--  the Report Labor Cost Distribution By Funding Source.
-- ----------------------------------------------------

FUNCTION CALC_PREV_VALUE_FSC(p_ORGMGR_ID                   NUMBER,
                             p_organization_id             NUMBER,
                             p_position_id                 NUMBER,
                             p_effective_start_date        DATE,
                             p_effective_end_date          DATE,
                             p_element_type_id             NUMBER,
                             p_cost_allocation_keyflex_id  NUMBER)
RETURN NUMBER IS

CURSOR prev_tot_budget IS
    SELECT SUM(bdg.BUDGET_VALUE) budgeted_amount
    FROM HRI_MDP_BDGTS_LBRCST_ORGMGR_CT bdg
    WHERE bdg.ORGMGR_ID                  = p_ORGMGR_ID
      AND bdg.ORGANIZATION_ID            = decode(p_organization_id,0,bdg.ORGANIZATION_ID,p_organization_id)
      AND bdg.POSITION_ID                = decode(p_position_id,0,bdg.POSITION_ID,p_position_id)
      AND bdg.ELEMENT_TYPE_ID            = decode(p_element_type_id,0,bdg.ELEMENT_TYPE_ID,p_element_type_id)
      AND bdg.COST_ALLOCATION_KEYFLEX_ID = p_cost_allocation_keyflex_id
      AND bdg.EFFECTIVE_START_DATE      <= p_effective_end_date
      AND bdg.EFFECTIVE_END_DATE        >= p_effective_start_date;

CURSOR prev_tot_actual_cmmt IS
    SELECT  SUM(act.ACTUAL_VALUE),
            SUM(act.COMMITMENT_VALUE)
      FROM HRI_MDP_CMNTS_ACTLS_ORGMGR_CT act
     WHERE act.ORGMGR_ID                  = p_ORGMGR_ID
       AND act.ORGANIZATION_ID            = decode(p_organization_id,0,act.ORGANIZATION_ID,p_organization_id)
       AND act.POSITION_ID                = decode(p_position_id,0,act.POSITION_ID,p_position_id)
       AND act.ELEMENT_TYPE_ID            = decode(p_element_type_id,0,act.ELEMENT_TYPE_ID,p_element_type_id)
       AND act.COST_ALLOCATION_KEYFLEX_ID = p_cost_allocation_keyflex_id
       AND act.EFFECTIVE_START_DATE      <= p_effective_end_date
       AND act.EFFECTIVE_END_DATE        >= p_effective_start_date;

l_budgeted_amount number;
l_actual_amount number;
l_committed_amount number;
l_available number := 0;

BEGIN
  OPEN prev_tot_budget;
  FETCH prev_tot_budget INTO l_budgeted_amount;
  CLOSE prev_tot_budget;

  OPEN prev_tot_actual_cmmt;
  FETCH prev_tot_actual_cmmt INTO l_actual_amount,l_committed_amount;
  CLOSE prev_tot_actual_cmmt;

  l_available := nvl(l_budgeted_amount,0) - (nvl(l_actual_amount,0) + nvl(l_committed_amount,0));

  RETURN l_available;
END CALC_PREV_VALUE_FSC;


-- ----------------------------------------------------
--  This procedure frames the Query for the Report Labor Cost Distribution By Funding Source.
-- ----------------------------------------------------

PROCEDURE GET_FSC_SQL(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql          OUT NOCOPY VARCHAR2,
                      x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sqltext               VARCHAR2(32767);
  l_custom_rec            BIS_QUERY_ATTRIBUTES;

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


l_currency:= l_parameter_rec.currency_code;

IF l_currency =bis_common_parameters.get_currency_code THEN
    l_rateType:=bis_common_parameters.get_rate_type;
ELSIF l_currency =bis_common_parameters.get_secondary_currency_code THEN
    l_rateType:=bis_common_parameters.get_secondary_rate_type;
END IF;


 l_sqltext :=
'SELECT                          -- Labor Cost Distribution By Funding Source
 pck.concatenated_segments        HRI_P_CHAR1_GA
,tab.budgeted_amount              HRI_P_MEASURE1
,tab.committed_amount             HRI_P_MEASURE2
,tab.actual_amount                HRI_P_MEASURE3
,tab.total                        HRI_P_MEASURE4
,tab.total                        HRI_P_MEASURE7
,tab.available                    HRI_P_MEASURE5
,((tab.available - tab.prev_available)*100/(decode(tab.prev_available,0,1,tab.prev_available)))                  HRI_P_MEASURE6
,SUM(tab.budgeted_amount) OVER () HRI_P_GRAND_TOTAL1
,SUM(tab.committed_amount) OVER () HRI_P_GRAND_TOTAL2
,SUM(tab.actual_amount) OVER ()    HRI_P_GRAND_TOTAL3
,SUM(tab.total) OVER ()            HRI_P_GRAND_TOTAL4
,SUM(tab.available) OVER ()        HRI_P_GRAND_TOTAL5
,SUM( ((tab.available - tab.prev_available)*100/(decode(tab.prev_available,0,1,tab.prev_available))) ) OVER ()    HRI_P_GRAND_TOTAL6
,1                                 HRI_P_ORDER_BY_1
FROM
 (
  SELECT
   COST_ALLOCATION_KEYFLEX_ID                                                   id
  ,SUM(budgeted_amount)                                                         budgeted_amount
  ,SUM(actual_amount)                                                           actual_amount
  ,SUM(committed_amount)                                                        committed_amount
  ,SUM(actual_amount) + SUM(committed_amount)                                   total
  ,SUM(budgeted_amount) - NVL((SUM(actual_amount) + SUM(committed_amount)),0)   available
  ,SUM(prev_available)                                                          prev_available
 FROM
    (
    (SELECT  COST_ALLOCATION_KEYFLEX_ID,
             null                                                      BUDGETED_AMOUNT,
	     HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
              (CURRENCY_CODE,
               '''||l_currency||''',
               &BIS_CURRENT_ASOF_DATE,
               SUM(ACTUAL_VALUE),
               '''||l_rateType||''')                                   ACTUAL_AMOUNT,
             HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
              (CURRENCY_CODE,
               '''||l_currency||''',
               &BIS_CURRENT_ASOF_DATE,
               SUM(COMMITMENT_VALUE),
               '''||l_rateType||''')                                   COMMITTED_AMOUNT,
             HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
              (CURRENCY_CODE,
               '''||l_currency||''',
               &BIS_CURRENT_ASOF_DATE,
               HRI_OLTP_PMV_LBRCST_ORGMGR.CALC_PREV_VALUE_FSC
                (&HRI_PERSON+HRI_PER_USRDR_H
                 ,&HRI_P_CHAR2_GA
                 ,&HRI_P_CHAR4_GA
                 ,&BIS_PREVIOUS_EFFECTIVE_START_DATE
                 ,&BIS_PREVIOUS_EFFECTIVE_END_DATE
	         ,&HRI_P_CHAR3_GA
	         ,COST_ALLOCATION_KEYFLEX_ID
                ) ,
              '''||l_rateType||''')                                    PREV_AVAILABLE
       FROM HRI_MDP_CMNTS_ACTLS_ORGMGR_CT
      WHERE ORGMGR_ID = &HRI_PERSON+HRI_PER_USRDR_H
        AND EFFECTIVE_START_DATE <= &BIS_CURRENT_EFFECTIVE_END_DATE
        AND EFFECTIVE_END_DATE   >= &BIS_CURRENT_EFFECTIVE_START_DATE
        AND ORGANIZATION_ID       = DECODE(&HRI_P_CHAR2_GA,0,ORGANIZATION_ID,&HRI_P_CHAR2_GA)
        AND POSITION_ID           = DECODE(&HRI_P_CHAR4_GA,0,POSITION_ID,&HRI_P_CHAR4_GA)
        AND ELEMENT_TYPE_ID       = DECODE(&HRI_P_CHAR3_GA,0,ELEMENT_TYPE_ID,&HRI_P_CHAR3_GA)
      GROUP BY  COST_ALLOCATION_KEYFLEX_ID,
		CURRENCY_CODE )
     UNION ALL
     (SELECT COST_ALLOCATION_KEYFLEX_ID,
             HRI_OLTP_VIEW_CURRENCY.CONVERT_CURRENCY_AMOUNT
	      (CURRENCY_CODE,
               '''||l_currency||''',
               &BIS_CURRENT_ASOF_DATE,
               SUM(BUDGET_VALUE),
               '''||l_rateType||''')               BUDGETED_AMOUNT,
            null                                   ACTUAL_AMOUNT,
            null                                   COMMITTED_AMOUNT,
	    null                                   PREV_AVAILABLE
       FROM HRI_MDP_BDGTS_LBRCST_ORGMGR_CT
      WHERE ORGMGR_ID = &HRI_PERSON+HRI_PER_USRDR_H
        AND EFFECTIVE_START_DATE <= &BIS_CURRENT_EFFECTIVE_END_DATE
        AND EFFECTIVE_END_DATE   >= &BIS_CURRENT_EFFECTIVE_START_DATE
        AND ORGANIZATION_ID       = DECODE(&HRI_P_CHAR2_GA,0,ORGANIZATION_ID,&HRI_P_CHAR2_GA)
        AND POSITION_ID           = DECODE(&HRI_P_CHAR4_GA,0,POSITION_ID,&HRI_P_CHAR4_GA)
        AND ELEMENT_TYPE_ID       = DECODE(&HRI_P_CHAR3_GA,0,ELEMENT_TYPE_ID,&HRI_P_CHAR3_GA)
      GROUP BY  COST_ALLOCATION_KEYFLEX_ID,
		CURRENCY_CODE )
      )
      GROUP BY  COST_ALLOCATION_KEYFLEX_ID
      )tab,
      pay_cost_allocation_keyflex pck
WHERE pck.COST_ALLOCATION_KEYFLEX_ID = tab.ID
&ORDER_BY_CLAUSE';

  x_custom_sql := l_SQLText;

END GET_FSC_SQL;

END HRI_OLTP_PMV_LBRCST_ORGMGR;


/
