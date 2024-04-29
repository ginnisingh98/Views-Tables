--------------------------------------------------------
--  DDL for Package Body PJI_PMV_AVL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_PMV_AVL" AS
-- $Header: PJIRR01B.pls 120.4 2005/11/12 17:15:34 appldev noship $

-- CACHE THE LABOUR UNITS OPTION SPECIFIED IN THE PJI SETUP.
   G_LABOUR_UNITS         VARCHAR2(40);
   G_AVL_THRESHOLD_VAL    NUMBER;

-- FORWARD DECLARATION.
PROCEDURE GET_AVAILABLE_SINCE_INFO(P_AVL_RES_DET_TBL IN OUT NOCOPY  PJI_REP_RA5_TBL, P_AS_OF_DATE NUMBER, P_THRESHOLD NUMBER);
PROCEDURE GET_CURRENT_LAST_PROJECT_INFO(P_AVL_RES_DET_TBL IN OUT NOCOPY  PJI_REP_RA5_TBL, P_AS_OF_DATE NUMBER);
PROCEDURE GET_NEXT_ASSIGNMENT_INFO(P_AVL_RES_DET_TBL IN OUT NOCOPY  PJI_REP_RA5_TBL, P_AS_OF_DATE NUMBER);



/****************************************************
 * RA1: AVAILABLE TIME SUMMARY REPORT FUNCTIONS
 ****************************************************/
PROCEDURE GET_SQL_PJI_REP_RA1 (P_PAGE_PARAMETER_TBL IN BIS_PMV_PAGE_PARAMETER_TBL
                             , X_PMV_SQL OUT NOCOPY  VARCHAR2
                             , X_PMV_OUTPUT OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL)
IS
BEGIN

    PJI_PMV_ENGINE.GENERATE_SQL(P_PAGE_PARAMETER_TBL  => P_PAGE_PARAMETER_TBL
                         ,P_SELECT_LIST         =>
                              'FACT.CAPACITY  "PJI_REP_MSR_3",
                               FACT.CONFIRMED  "PJI_REP_MSR_4",
                               FACT.PROVISIONAL  "PJI_REP_MSR_5",
                               FACT.UNASSIGNED  "PJI_REP_MSR_11",
                               FACT.AVAILABLE  "PJI_REP_MSR_12",
                               FACT.PERCENT_AVAILABLE  "PJI_REP_MSR_13",
                               FACT.PERCENT_ACTUAL_UTILIZATION  "PJI_REP_MSR_14",
                               FACT.PERCENT_SCHEDULED_UTILIZATION  "PJI_REP_MSR_15",
                               FACT.REDUCE_CAP_A  "PJI_REP_MSR_27",
                               FACT.REDUCE_CAP_S  "PJI_REP_MSR_28",
                               FACT.TOT_WTD_A  "PJI_REP_MSR_29",
                               FACT.CONF_WTD_S  "PJI_REP_MSR_30",
                               FACT.PJI_REP_TOTAL_1 "PJI_REP_TOTAL_1",
                               FACT.PJI_REP_TOTAL_2 "PJI_REP_TOTAL_2",
                               FACT.PJI_REP_TOTAL_3 "PJI_REP_TOTAL_3",
                               FACT.PJI_REP_TOTAL_4 "PJI_REP_TOTAL_4",
                               FACT.PJI_REP_TOTAL_5 "PJI_REP_TOTAL_5",
                               FACT.PJI_REP_TOTAL_6 "PJI_REP_TOTAL_6",
                               FACT.PJI_REP_TOTAL_7 "PJI_REP_TOTAL_7",
                               FACT.PJI_REP_TOTAL_8 "PJI_REP_TOTAL_8",
                               FACT.PJI_REP_TOTAL_9 "PJI_REP_TOTAL_9",
                               FACT.PJI_REP_TOTAL_10 "PJI_REP_TOTAL_10",
                               FACT.PJI_REP_TOTAL_11 "PJI_REP_TOTAL_11",
                               FACT.PJI_REP_TOTAL_12 "PJI_REP_TOTAL_12"'
                               ,P_SQL_STATEMENT       => X_PMV_SQL
                               ,P_PMV_OUTPUT          => X_PMV_OUTPUT,
                                P_REGION_CODE         => 'PJI_REP_RA1',
                                P_PLSQL_DRIVER        => 'PJI_PMV_AVL.PLSQLDRIVER_RA1',
                                P_PLSQL_DRIVER_PARAMS =>   '<<ORGANIZATION+FII_OPERATING_UNITS>>, ' ||
                                                           '<<ORGANIZATION+PJI_ORGANIZATIONS>>, ' ||
                                                           '<<AVAILABILITY_THRESHOLD+AVAILABILITY_THRESHOLD>>, ' ||
                                                           '<<AS_OF_DATE>>, ' ||
                                                           '<<PERIOD_TYPE>>, ' ||
                                                           '<<VIEW_BY>>');
END GET_SQL_PJI_REP_RA1;

FUNCTION PLSQLDRIVER_RA1 (
   P_OPERATING_UNIT        IN VARCHAR2 DEFAULT NULL,
   P_ORGANIZATION          IN VARCHAR2,
   P_THRESHOLD             IN NUMBER,
   P_AS_OF_DATE            IN NUMBER,
   P_PERIOD_TYPE           IN VARCHAR2,
   P_VIEW_BY               IN VARCHAR2
)  RETURN PJI_REP_RA1_TBL
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   L_AVL_DAYS_SUM_TBL    PJI_REP_RA1_TBL := PJI_REP_RA1_TBL();

   L_TOP_ORGANIZATION_NAME  VARCHAR2(240);
   L_TOP_ORG_INDEX          NUMBER:=0;

   L_CAPACITY                      NUMBER:=0;
   L_CAPACITY_A                    NUMBER:=0;
   L_CONFIRMED                     NUMBER:=0;
   L_PROVISIONAL                   NUMBER:=0;
   L_UNASSIGNED                    NUMBER:=0;
   L_AVAILABLE                     NUMBER:=0;
   L_PT_AVAILABLE                  NUMBER:=0;
   L_PT_ACTUAL_UTILIZATION         NUMBER:=0;
   L_PT_SCHEDULED_UTILIZATION      NUMBER:=0;

   L_TO_CAPACITY                      NUMBER:=0;
   L_TO_CAPACITY_A                    NUMBER:=0;
   L_TO_CONFIRMED                     NUMBER:=0;
   L_TO_PROVISIONAL                   NUMBER:=0;
   L_TO_UNASSIGNED                    NUMBER:=0;
   L_TO_AVAILABLE                     NUMBER:=0;
   L_TO_PT_AVAILABLE                  NUMBER:=0;
   L_TO_PT_ACTUAL_UTILIZATION         NUMBER:=0;
   L_TO_PT_SCHEDULED_UTILIZATION      NUMBER:=0;

   L_REDUCE_CAP_A                  NUMBER:=0;
   L_REDUCE_CAP_S                  NUMBER:=0;
   L_TOT_WTD_A                     NUMBER:=0;
   L_CONF_WTD_S                    NUMBER:=0;

   L_TO_REDUCE_CAP_A                  NUMBER:=0;
   L_TO_REDUCE_CAP_S                  NUMBER:=0;
   L_TO_TOT_WTD_A                     NUMBER:=0;
   L_TO_CONF_WTD_S                    NUMBER:=0;

   L_ORG_NAME                      VARCHAR2(240);
   L_URL                           VARCHAR2(2000);
   L_THRESHOLD                     NUMBER:=P_THRESHOLD;

BEGIN

   PJI_PMV_ENGINE.CONVERT_OPERATING_UNIT (P_OPERATING_UNIT_IDS=>P_OPERATING_UNIT,
                                          P_VIEW_BY=>P_VIEW_BY);
   PJI_PMV_ENGINE.CONVERT_ORGANIZATION   (P_TOP_ORGANIZATION_ID=>P_ORGANIZATION,
							              P_VIEW_BY=>P_VIEW_BY,
							              P_TOP_ORGANIZATION_NAME => L_TOP_ORGANIZATION_NAME);
   PJI_PMV_ENGINE.CONVERT_TIME(P_AS_OF_DATE=>P_AS_OF_DATE,
                               P_PERIOD_TYPE=>P_PERIOD_TYPE,
                               P_VIEW_BY=>P_VIEW_BY,
                               P_PARSE_PRIOR=>NULL,
                               P_REPORT_TYPE=>NULL,
                               P_COMPARATOR=>NULL,
                               P_PARSE_ITD=>NULL,
                               P_FULL_PERIOD_FLAG =>'Y');
 IF G_LABOUR_UNITS IS NULL THEN
	 BEGIN
     	   SELECT REPORT_LABOR_UNITS
           INTO G_LABOUR_UNITS
           FROM PJI_SYSTEM_SETTINGS;
       EXCEPTION
           WHEN OTHERS THEN
             G_LABOUR_UNITS := NULL;
       END;
   END IF;

 IF G_AVL_THRESHOLD_VAL IS NULL THEN
   BEGIN
       SELECT VALUE
       INTO G_AVL_THRESHOLD_VAL
       FROM PJI_AVL_THRESHOLDS_V
       WHERE ID = P_THRESHOLD;
   EXCEPTION
       WHEN OTHERS THEN
         G_AVL_THRESHOLD_VAL := 100;
   END;
END IF;

IF P_THRESHOLD IS NULL THEN
   BEGIN
      SELECT  DISTINCT
       FIRST_VALUE(ID) OVER (ORDER BY VALUE DESC) INTO L_THRESHOLD
       FROM PJI_AVL_THRESHOLDS_V;
   END;
END IF;


   SELECT PJI_REP_RA1(
            ORGANIZATION_ID
           , SUM(CAPACITY)
           , SUM(CAPACITY_A)
           , SUM(CONFIRMED)
           , SUM(PROVISIONAL)
           , SUM(UNASSIGNED)
           , DECODE (L_THRESHOLD,  1, SUM(AVL_BKT1)
                                 , 2, SUM(AVL_BKT2)
                                 , 3, SUM(AVL_BKT3)
                                 , 4, SUM(AVL_BKT4)
                                 , 5, SUM(AVL_BKT5)
                                 , 0)
           , 0
           , 0
           , 0
           , SUM(REDUCE_CAP_A)
           , SUM(REDUCE_CAP_S)
           , SUM(TOT_WTD_A)
           , SUM(CONF_WTD_S)
           , 0
           , 0
           , 0
           , 0
           , 0
           , 0
           , 0
           , 0
           , 0
           , 0
           , 0
           , 0
	   , 0)
   BULK COLLECT INTO L_AVL_DAYS_SUM_TBL
   FROM (
	 /* Bug 3515594 */
         SELECT /*+ ORDERED */
               HORG.NAME    ORGANIZATION_ID
              ,CAPACITY_HRS /
                   DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY,
                                         'WEEKS',IMP.FTE_WEEK, 1)  CAPACITY
              ,0   CAPACITY_A
              ,(CONF_HRS_S - NVL(CONF_OVERCOM_HRS_S,0)) /
                   DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY,
                                         'WEEKS',IMP.FTE_WEEK, 1)  CONFIRMED
              ,(PROV_HRS_S - NVL(PROV_OVERCOM_HRS_S,0)) /
                   DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY,
                                         'WEEKS',IMP.FTE_WEEK, 1)  PROVISIONAL
              ,UNASSIGNED_HRS_S /
                   DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY,
                                         'WEEKS',IMP.FTE_WEEK, 1)  UNASSIGNED
              ,0   REDUCE_CAP_A
              ,REDUCE_CAPACITY_HRS_S /
                   DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY,
                                         'WEEKS',IMP.FTE_WEEK, 1)  REDUCE_CAP_S
              ,0   TOT_WTD_A
              ,CONF_WTD_ORG_HRS_S /
                   DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY,
                                         'WEEKS',IMP.FTE_WEEK, 1)  CONF_WTD_S
              ,CASE WHEN (AVAILABLE_RES_COUNT_BKT1_S = 0) THEN 0 ELSE
                AVAILABLE_HRS_BKT1_S /
                    DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY,
                                           'WEEKS',IMP.FTE_WEEK, 1) END   AVL_BKT1
              ,CASE WHEN (AVAILABLE_RES_COUNT_BKT2_S = 0) THEN 0 ELSE
                AVAILABLE_HRS_BKT2_S /
                    DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY,
                                           'WEEKS',IMP.FTE_WEEK, 1) END   AVL_BKT2
              ,CASE WHEN (AVAILABLE_RES_COUNT_BKT3_S = 0) THEN 0 ELSE
                AVAILABLE_HRS_BKT3_S /
                    DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY,
                                           'WEEKS',IMP.FTE_WEEK, 1) END   AVL_BKT3
              ,CASE WHEN (AVAILABLE_RES_COUNT_BKT4_S = 0) THEN 0 ELSE
                AVAILABLE_HRS_BKT4_S /
                    DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY,
                                           'WEEKS',IMP.FTE_WEEK, 1) END   AVL_BKT4
              ,CASE WHEN (AVAILABLE_RES_COUNT_BKT5_S = 0) THEN 0 ELSE
                AVAILABLE_HRS_BKT5_S /
                    DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY,
                                           'WEEKS',IMP.FTE_WEEK, 1) END   AVL_BKT5
           FROM  PJI_PMV_TIME_DIM_TMP    TIME,
                 PJI_PMV_ORGZ_DIM_TMP    HORG,
                 PJI_RM_ORGO_F_MV        FCT,
                 PJI_PMV_ORG_DIM_TMP     HOU,
                 PA_IMPLEMENTATIONS_ALL  IMP
           WHERE FCT.EXPENDITURE_ORG_ID  = HOU.ID
             AND FCT.EXPENDITURE_ORGANIZATION_ID = HORG.ID
             AND HOU.ID                  = IMP.ORG_ID
             AND FCT.TIME_ID             = TIME.ID
             AND FCT.PERIOD_TYPE_ID      = TIME.PERIOD_TYPE
             AND FCT.CALENDAR_TYPE       = TIME.CALENDAR_TYPE
             AND TIME.AMOUNT_TYPE=2
           UNION ALL
           SELECT /*+ ORDERED */
               HORG.NAME    ORGANIZATION_ID
              ,0  CAPACITY
              ,CAPACITY_HRS /
                   DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY,
                                         'WEEKS',IMP.FTE_WEEK, 1)  CAPACITY_A
              ,0  CONFIRMED
              ,0  PROVISIONAL
              ,0  UNASSIGNED
              ,REDUCE_CAPACITY_HRS_A /
                   DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY,
                                         'WEEKS',IMP.FTE_WEEK, 1)  REDUCE_CAP_A
              ,0   REDUCE_CAP_S
              ,TOTAL_WTD_ORG_HRS_A /
                   DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY,
                                         'WEEKS',IMP.FTE_WEEK, 1)  TOT_WTD_A
              ,0   CONF_WTD_S
              ,0   AVL_BKT1
              ,0   AVL_BKT2
              ,0   AVL_BKT3
              ,0   AVL_BKT4
              ,0   AVL_BKT5
           FROM  PJI_PMV_TIME_DIM_TMP    TIME,
                 PJI_PMV_ORGZ_DIM_TMP    HORG,
                 PJI_RM_ORGO_F_MV        FCT,
                 PJI_PMV_ORG_DIM_TMP     HOU,
                 PA_IMPLEMENTATIONS_ALL  IMP
           WHERE FCT.EXPENDITURE_ORG_ID  = HOU.ID
             AND FCT.EXPENDITURE_ORGANIZATION_ID = HORG.ID
             AND HOU.ID                  = IMP.ORG_ID
             AND FCT.TIME_ID             = TIME.ID
             AND FCT.PERIOD_TYPE_ID      = TIME.PERIOD_TYPE
             AND FCT.CALENDAR_TYPE       = DECODE(FCT.PERIOD_TYPE_ID,1, 'C',TIME.CALENDAR_TYPE)
             AND TIME.AMOUNT_TYPE=1
           UNION ALL
           SELECT NAME      ORGANIZATION_ID
                 , 0        CAPACITY
                 , 0        CAPACITY_A
                 , 0        CONFIRMED
                 , 0        PROVISIONAL
                 , 0        UNASSIGNED
                 , 0        REDUCE_CAP_A
                 , 0        REDUCE_CAP_S
                 , 0        TOT_WTD_A
                 , 0        CONF_WTD_S
                 , 0        AVL_BKT1
                 , 0        AVL_BKT2
                 , 0        AVL_BKT3
                 , 0        AVL_BKT4
                 , 0        AVL_BKT5
           FROM PJI_PMV_ORGZ_DIM_TMP
           WHERE NAME <> '-1'
   ) GROUP BY ORGANIZATION_ID;

FOR I IN 1..L_AVL_DAYS_SUM_TBL.COUNT
  LOOP
		IF L_AVL_DAYS_SUM_TBL(I).ORGANIZATION_ID = L_TOP_ORGANIZATION_NAME THEN
				L_TOP_ORG_INDEX:=I;

				L_TO_CAPACITY     := NVL(L_AVL_DAYS_SUM_TBL(I).CAPACITY     ,0);
				L_TO_CAPACITY_A   := NVL(L_AVL_DAYS_SUM_TBL(I).CAPACITY_A   ,0);
				L_TO_CONFIRMED    := NVL(L_AVL_DAYS_SUM_TBL(I).CONFIRMED    ,0);
				L_TO_PROVISIONAL  := NVL(L_AVL_DAYS_SUM_TBL(I).PROVISIONAL  ,0);
				L_TO_UNASSIGNED   := NVL(L_AVL_DAYS_SUM_TBL(I).UNASSIGNED   ,0);
				L_TO_AVAILABLE    := NVL(L_AVL_DAYS_SUM_TBL(I).AVAILABLE    ,0);
	            L_TO_REDUCE_CAP_A := NVL(L_AVL_DAYS_SUM_TBL(I).REDUCE_CAP_A ,0);
                L_TO_REDUCE_CAP_S := NVL(L_AVL_DAYS_SUM_TBL(I).REDUCE_CAP_S ,0);
                L_TO_TOT_WTD_A    := NVL(L_AVL_DAYS_SUM_TBL(I).TOT_WTD_A    ,0);
                L_TO_CONF_WTD_S   := NVL(L_AVL_DAYS_SUM_TBL(I).CONF_WTD_S   ,0);

        ELSE
				L_CAPACITY    := L_CAPACITY
				          + NVL(L_AVL_DAYS_SUM_TBL(I).CAPACITY ,0);
				L_CAPACITY_A  := L_CAPACITY_A
				          + NVL(L_AVL_DAYS_SUM_TBL(I).CAPACITY_A ,0);
				L_CONFIRMED     :=L_CONFIRMED
				          + NVL(L_AVL_DAYS_SUM_TBL(I).CONFIRMED ,0);
				L_PROVISIONAL   :=L_PROVISIONAL
				          + NVL(L_AVL_DAYS_SUM_TBL(I).PROVISIONAL ,0);
				L_UNASSIGNED    :=L_UNASSIGNED
				          + NVL(L_AVL_DAYS_SUM_TBL(I).UNASSIGNED ,0);
				L_AVAILABLE   :=L_AVAILABLE
				          + NVL(L_AVL_DAYS_SUM_TBL(I).AVAILABLE ,0);
	            L_REDUCE_CAP_A:= L_REDUCE_CAP_A
                          + NVL(L_AVL_DAYS_SUM_TBL(I).REDUCE_CAP_A ,0);
                L_REDUCE_CAP_S:=   L_REDUCE_CAP_S
                          + NVL(L_AVL_DAYS_SUM_TBL(I).REDUCE_CAP_S ,0);
                L_TOT_WTD_A:=   L_TOT_WTD_A
                          + NVL(L_AVL_DAYS_SUM_TBL(I).TOT_WTD_A ,0);
                L_CONF_WTD_S:=   L_CONF_WTD_S
                          + NVL(L_AVL_DAYS_SUM_TBL(I).CONF_WTD_S ,0);

 END IF;
END LOOP;

IF NVL(L_TOP_ORG_INDEX, 0) <> 0 THEN
		L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).CAPACITY
    		:= NVL(L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).CAPACITY,0)
                    -L_CAPACITY;

		L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).CAPACITY_A
    		:= NVL(L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).CAPACITY_A,0)
                    -L_CAPACITY_A;

		L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).CONFIRMED
		    := NVL(L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).CONFIRMED ,0)
                    -L_CONFIRMED;

		L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).PROVISIONAL
		    := NVL(L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).PROVISIONAL ,0)
                    -L_PROVISIONAL;

		L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).UNASSIGNED
		    := NVL(L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).UNASSIGNED ,0)
                    -L_UNASSIGNED;

		L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).AVAILABLE
		    := NVL(L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).AVAILABLE,0)
                    -L_AVAILABLE;

        L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).REDUCE_CAP_A
            := NVL(L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).REDUCE_CAP_A ,0)
                     - L_REDUCE_CAP_A;

        L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).REDUCE_CAP_S
            := NVL(L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).REDUCE_CAP_S ,0)
                    - L_REDUCE_CAP_S ;

        L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).TOT_WTD_A
               := NVL(L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).TOT_WTD_A ,0)
               - L_TOT_WTD_A;

        L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).CONF_WTD_S
           := NVL(L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).CONF_WTD_S ,0)
           - L_CONF_WTD_S;

IF
        NVL(L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).CAPACITY_A  ,0) =0 AND
        NVL(L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).CAPACITY    ,0) =0 AND
        NVL(L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).CONFIRMED   ,0) =0 AND
        NVL(L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).PROVISIONAL ,0) =0 AND
        NVL(L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).UNASSIGNED  ,0) =0 AND
        NVL(L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).AVAILABLE   ,0) =0 AND
        NVL(L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).REDUCE_CAP_A,0) =0 AND
        NVL(L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).TOT_WTD_A   ,0) =0 AND
        NVL(L_AVL_DAYS_SUM_TBL(L_TOP_ORG_INDEX).CONF_WTD_S  ,0) =0
     THEN
        L_AVL_DAYS_SUM_TBL.DELETE(L_TOP_ORG_INDEX);
END IF;

	L_CAPACITY       := L_TO_CAPACITY;
	L_CAPACITY_A     := L_TO_CAPACITY_A;
	L_CONFIRMED      := L_TO_CONFIRMED;
	L_PROVISIONAL    := L_TO_PROVISIONAL;
	L_UNASSIGNED     := L_TO_UNASSIGNED;
	L_AVAILABLE      := L_TO_AVAILABLE;
    L_REDUCE_CAP_A   := L_TO_REDUCE_CAP_A;
    L_REDUCE_CAP_S   := L_TO_REDUCE_CAP_S;
    L_TOT_WTD_A      := L_TO_TOT_WTD_A;
    L_CONF_WTD_S     := L_TO_CONF_WTD_S;

 END IF;

IF L_AVL_DAYS_SUM_TBL.COUNT > 0 THEN
FOR I IN L_AVL_DAYS_SUM_TBL.FIRST..L_AVL_DAYS_SUM_TBL.LAST
  LOOP
    IF L_AVL_DAYS_SUM_TBL.EXISTS(I) THEN

    	IF NVL(L_AVL_DAYS_SUM_TBL(I).CAPACITY, 0)=0 THEN
           L_AVL_DAYS_SUM_TBL(I).PERCENT_AVAILABLE:= NULL;
        ELSE
           L_AVL_DAYS_SUM_TBL(I).PERCENT_AVAILABLE:=
               (L_AVL_DAYS_SUM_TBL(I).AVAILABLE
                    /L_AVL_DAYS_SUM_TBL(I).CAPACITY)*100;
        END IF;

	IF (NVL(L_AVL_DAYS_SUM_TBL(I).CAPACITY_A, 0)  -
                NVL(L_AVL_DAYS_SUM_TBL(I).REDUCE_CAP_A, 0))=0 THEN
                 L_AVL_DAYS_SUM_TBL(I).PERCENT_ACTUAL_UTILIZATION :=NULL;
        ELSE
                L_AVL_DAYS_SUM_TBL(I).PERCENT_ACTUAL_UTILIZATION:=
                     (L_AVL_DAYS_SUM_TBL(I).TOT_WTD_A/
                      (L_AVL_DAYS_SUM_TBL(I).CAPACITY_A -
                        L_AVL_DAYS_SUM_TBL(I).REDUCE_CAP_A))*100;
        END IF;

	    IF (NVL(L_AVL_DAYS_SUM_TBL(I).CAPACITY, 0) -
                        NVL(L_AVL_DAYS_SUM_TBL(I).REDUCE_CAP_S, 0))=0 THEN
             L_AVL_DAYS_SUM_TBL(I).PERCENT_SCHEDULED_UTILIZATION :=NULL;
        ELSE

           L_AVL_DAYS_SUM_TBL(I).PERCENT_SCHEDULED_UTILIZATION:=
               (L_AVL_DAYS_SUM_TBL(I).CONF_WTD_S/
                     (L_AVL_DAYS_SUM_TBL(I).CAPACITY
                     - L_AVL_DAYS_SUM_TBL(I).REDUCE_CAP_S))*100;
        END IF;

			L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_1 := L_CAPACITY;
			L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_2 := L_CONFIRMED;
			L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_3 := L_PROVISIONAL;
			L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_4 := L_UNASSIGNED;
			L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_5 := L_AVAILABLE;
			L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_9 := L_REDUCE_CAP_A ;
			L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_10 :=L_REDUCE_CAP_S;
			L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_11 :=L_TOT_WTD_A;
			L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_12 :=L_CONF_WTD_S ;
			L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_13 :=L_CAPACITY_A ;

        IF NVL(L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_1, 0)=0 THEN
                L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_6:= NULL;
           ELSE
              L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_6:=
               (L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_5
                 /L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_1)*100;
        END IF;

        IF NVL(L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_13-
                 L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_9, 0)=0 THEN
                L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_7:= NULL;
           ELSE
              L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_7:=
               (L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_11
                 /(L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_13-
                 L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_9))*100;
        END IF;

        IF NVL(L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_1-
                 L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_10, 0)=0 THEN
                L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_8:= NULL;
           ELSE
              L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_8:=
               (L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_12
                 /(L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_1-
                 L_AVL_DAYS_SUM_TBL(I).PJI_REP_TOTAL_10))*100;
        END IF;
    END IF;
  END LOOP;
END IF;

   COMMIT;
 RETURN L_AVL_DAYS_SUM_TBL;
END PLSQLDRIVER_RA1;


/****************************************************
 * RA2: CURRENT AVAILABLE RESOURCES REPORT FUNCTIONS
 ****************************************************/
PROCEDURE GET_SQL_PJI_REP_RA2 (P_PAGE_PARAMETER_TBL IN BIS_PMV_PAGE_PARAMETER_TBL
                             , X_PMV_SQL OUT NOCOPY  VARCHAR2
                             , X_PMV_OUTPUT OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL)
 IS
BEGIN

    PJI_PMV_ENGINE.GENERATE_SQL(P_PAGE_PARAMETER_TBL  => P_PAGE_PARAMETER_TBL
                            ,P_SELECT_LIST =>
                            'FACT.CURR_AVL_RES  "PJI_REP_MSR_2",
			     FACT.CURR_AVL_RES_URL_PARAMS "PJI_REP_MSR_12",
			     FACT.TOTAL_RESOURCES  "PJI_REP_MSR_3",
                             FACT.CURR_AVL_RES_PER  "PJI_REP_MSR_4",
                             FACT.W1  "PJI_REP_MSR_5",
			     FACT.W1_URL_PARAMS "PJI_REP_MSR_15",
			     FACT.W2  "PJI_REP_MSR_6",
			     FACT.W2_URL_PARAMS "PJI_REP_MSR_16",
			     FACT.W3  "PJI_REP_MSR_7",
			     FACT.W3_URL_PARAMS "PJI_REP_MSR_17",
			     FACT.W4  "PJI_REP_MSR_8",
			     FACT.W4_URL_PARAMS "PJI_REP_MSR_18",
			     FACT.PJI_REP_TOTAL_1 "PJI_REP_TOTAL_1",
                             FACT.PJI_REP_TOTAL_2 "PJI_REP_TOTAL_2",
                             FACT.PJI_REP_TOTAL_7 "PJI_REP_TOTAL_3",
                             FACT.PJI_REP_TOTAL_3 "PJI_REP_TOTAL_4",
                             FACT.PJI_REP_TOTAL_4 "PJI_REP_TOTAL_5",
                             FACT.PJI_REP_TOTAL_5 "PJI_REP_TOTAL_6",
                             FACT.PJI_REP_TOTAL_6 "PJI_REP_TOTAL_7"'
                               ,P_SQL_STATEMENT       => X_PMV_SQL
                               ,P_PMV_OUTPUT          => X_PMV_OUTPUT,
                                P_REGION_CODE         => 'PJI_REP_RA2',
                                P_PLSQL_DRIVER        => 'PJI_PMV_AVL.PLSQLDRIVER_RA2',
                                P_PLSQL_DRIVER_PARAMS =>   '<<ORGANIZATION+FII_OPERATING_UNITS>>, ' ||
                                                           '<<ORGANIZATION+PJI_ORGANIZATIONS>>, ' ||
                                                           '<<AVAILABILITY_THRESHOLD+AVAILABILITY_THRESHOLD>>, ' ||
                                                           '<<AS_OF_DATE>>, ' ||
                                                           '<<VIEW_BY>>');
END GET_SQL_PJI_REP_RA2;

FUNCTION PLSQLDRIVER_RA2 (
   P_OPERATING_UNIT        IN VARCHAR2 DEFAULT NULL,
   P_ORGANIZATION          IN VARCHAR2,
   P_THRESHOLD             IN NUMBER,
   P_AS_OF_DATE            IN NUMBER,
   P_VIEW_BY               IN VARCHAR2
)  RETURN PJI_REP_RA2_TBL
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   L_CUR_AVL_RES_TBL        PJI_REP_RA2_TBL := PJI_REP_RA2_TBL();
   TYPE T_WEEK_IDS IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE T_WEEK_END_DATE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   L_THRESHOLD           NUMBER          := P_THRESHOLD;
   L_AS_OF_DATE          NUMBER          := P_AS_OF_DATE;


   L_TOP_ORGANIZATION_NAME  VARCHAR2(240);
   L_TOP_ORG_INDEX          NUMBER;

   L_TOTAL_CURR_AVL_RES     NUMBER := 0;
   L_TOTAL_TOTAL_RESOURCES  NUMBER := 0;
   L_TOTAL_W1               NUMBER := 0;
   L_TOTAL_W2               NUMBER := 0;
   L_TOTAL_W3               NUMBER := 0;
   L_TOTAL_W4               NUMBER := 0;
   L_TOTAL_CURR_AVL_RES_PER NUMBER := 0;

   L_TO_TOTAL_CURR_AVL_RES     NUMBER := 0;
   L_TO_TOTAL_TOTAL_RESOURCES  NUMBER := 0;
   L_TO_TOTAL_W1               NUMBER := 0;
   L_TO_TOTAL_W2               NUMBER := 0;
   L_TO_TOTAL_W3               NUMBER := 0;
   L_TO_TOTAL_W4               NUMBER := 0;
   L_TO_TOTAL_CURR_AVL_RES_PER NUMBER := 0;

   L_WEEK_IDS                  T_WEEK_IDS;
   L_WEEK_END_DATE             T_WEEK_END_DATE;
   L_CALENDAR_TYPE             VARCHAR2(1):='E';
   L_PERIOD_TYPE_ID            NUMBER:=16;
BEGIN

   PJI_PMV_ENGINE.CONVERT_OPERATING_UNIT (P_OPERATING_UNIT, P_VIEW_BY);
   PJI_PMV_ENGINE.CONVERT_ORGANIZATION (P_ORGANIZATION, P_VIEW_BY, L_TOP_ORGANIZATION_NAME);

   -- DELETE THE TIME DIMENSION TEMP TABLE FIRST BEFORE INSERTING AGAIN.
   DELETE PJI_PMV_TIME_DIM_TMP;

   ----------------------------------------------------
   -- THIS PART OF THE CODE GET THE NEXT FOUR WEEKS
   -- TIME_ID FROM THE AS_OF_DATE AND INSERT INTO THE
   -- TIME DIMENSION TEMP TABLE
   -----------------------------------------------------

   SELECT WEEK_ID , TO_CHAR(END_DATE,'J')
   BULK COLLECT INTO
   L_WEEK_IDS , L_WEEK_END_DATE
   FROM FII_TIME_WEEK
   WHERE 1 = 1
   AND TO_DATE(P_AS_OF_DATE+28,'J') >= START_DATE
   AND TO_DATE(P_AS_OF_DATE,'J') <= END_DATE;

   CASE (L_WEEK_IDS.COUNT)
   WHEN 0 THEN
          L_WEEK_IDS(1):=NULL;
          L_WEEK_END_DATE(1):=NULL;
          L_WEEK_IDS(2):=NULL;
          L_WEEK_END_DATE(2):=NULL;
          L_WEEK_IDS(3):=NULL;
          L_WEEK_END_DATE(3):=NULL;
          L_WEEK_IDS(4):=NULL;
          L_WEEK_END_DATE(4):=NULL;
          L_WEEK_IDS(5):=NULL;
          L_WEEK_END_DATE(5):=NULL;
   WHEN 1 THEN
          L_WEEK_IDS(2):=NULL;
          L_WEEK_END_DATE(2):=NULL;
          L_WEEK_IDS(3):=NULL;
          L_WEEK_END_DATE(3):=NULL;
          L_WEEK_IDS(4):=NULL;
          L_WEEK_END_DATE(4):=NULL;
          L_WEEK_IDS(5):=NULL;
          L_WEEK_END_DATE(5):=NULL;
   WHEN 2 THEN NULL;
          L_WEEK_IDS(3):=NULL;
          L_WEEK_END_DATE(3):=NULL;
          L_WEEK_IDS(4):=NULL;
          L_WEEK_END_DATE(4):=NULL;
          L_WEEK_IDS(5):=NULL;
          L_WEEK_END_DATE(5):=NULL;
   WHEN 3 THEN NULL;
          L_WEEK_IDS(4):=NULL;
          L_WEEK_END_DATE(4):=NULL;
          L_WEEK_IDS(5):=NULL;
          L_WEEK_END_DATE(5):=NULL;
   WHEN 4 THEN NULL;
          L_WEEK_IDS(5):=NULL;
          L_WEEK_END_DATE(5):=NULL;
   ELSE
          NULL;
   END CASE;
   -------------------------------------------
   -- END OF GETTING NEXT FOUR WEEKS TIME ID
   -------------------------------------------


IF P_THRESHOLD IS NULL THEN
   BEGIN
      SELECT  DISTINCT
       FIRST_VALUE(ID) OVER (ORDER BY VALUE DESC) INTO L_THRESHOLD
       FROM PJI_AVL_THRESHOLDS_V;
   END;
END IF;


   SELECT PJI_REP_RA2(
            ORGANIZATION_ID
           ,SUM(CURR_AVL)
	   ,PJI_PMV_UTIL.ra2_ra5_url(p_as_of_date,'W0',ID,p_operating_unit,l_threshold)
	   ,SUM(TOTAL_RESOURCES)
           ,SUM(WEEK_1)
           ,PJI_PMV_UTIL.ra2_ra5_url(p_as_of_date,'W1',ID,p_operating_unit,l_threshold)
	   ,SUM(WEEK_2)
           ,PJI_PMV_UTIL.ra2_ra5_url(p_as_of_date,'W2',ID,p_operating_unit,l_threshold)
	   ,SUM(WEEK_3)
           ,PJI_PMV_UTIL.ra2_ra5_url(p_as_of_date,'W3',ID,p_operating_unit,l_threshold)
	   ,SUM(WEEK_4)
           ,PJI_PMV_UTIL.ra2_ra5_url(p_as_of_date,'W4',ID,p_operating_unit,l_threshold)
	   ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL)
   BULK COLLECT INTO L_CUR_AVL_RES_TBL
   FROM (
       SELECT  /*+ ORDERED */
               HORG.NAME           ORGANIZATION_ID
	      ,HORG.ID             ID
              ,TOTAL_RES_COUNT     TOTAL_RESOURCES
              ,FCT.AVAILABILITY    CURR_AVL
              ,0 WEEK_1
              ,0 WEEK_2
              ,0 WEEK_3
              ,0 WEEK_4
       FROM PJI_PMV_ORGZ_DIM_TMP    HORG,
            PJI_CA_ORGO_F_MV        FCT,
            PJI_PMV_ORG_DIM_TMP     HOU
       WHERE FCT.EXPENDITURE_ORG_ID = HOU.ID
         AND FCT.EXPENDITURE_ORGANIZATION_ID    = HORG.ID
         AND FCT.TIME_ID            = L_WEEK_IDS(1)
         AND FCT.CALENDAR_TYPE      = L_CALENDAR_TYPE
         AND FCT.PERIOD_TYPE_ID     = L_PERIOD_TYPE_ID
         AND FCT.THRESHOLD          = L_THRESHOLD
         AND FCT.AS_OF_DATE        <= L_WEEK_END_DATE(1)
       UNION ALL
       SELECT  /*+ ORDERED */
               HORG.NAME           ORGANIZATION_ID
	      ,HORG.ID             ID
              ,0 TOTAL_RESOURCES
              ,0 CURR_AVL
              ,FCT.AVAILABILITY    WEEK_1
              ,0 WEEK_2
              ,0 WEEK_3
              ,0 WEEK_4
       FROM PJI_PMV_ORGZ_DIM_TMP    HORG,
            PJI_CA_ORGO_F_MV        FCT,
            PJI_PMV_ORG_DIM_TMP     HOU
       WHERE FCT.EXPENDITURE_ORG_ID = HOU.ID
         AND FCT.EXPENDITURE_ORGANIZATION_ID    = HORG.ID
         AND FCT.TIME_ID            = L_WEEK_IDS(2)
         AND FCT.CALENDAR_TYPE      = L_CALENDAR_TYPE
         AND FCT.PERIOD_TYPE_ID     = L_PERIOD_TYPE_ID
         AND FCT.THRESHOLD          = L_THRESHOLD
         AND FCT.AS_OF_DATE        <= L_WEEK_END_DATE(2)
       UNION ALL
       SELECT  /*+ ORDERED */
               HORG.NAME           ORGANIZATION_ID
	      ,HORG.ID             ID
              ,0 TOTAL_RESOURCES
              ,0 CURR_AVL
              ,0 WEEK_1
              ,FCT.AVAILABILITY    WEEK_2
              ,0 WEEK_3
              ,0 WEEK_4
       FROM PJI_PMV_ORGZ_DIM_TMP    HORG,
            PJI_CA_ORGO_F_MV        FCT,
            PJI_PMV_ORG_DIM_TMP     HOU
       WHERE FCT.EXPENDITURE_ORG_ID = HOU.ID
         AND FCT.EXPENDITURE_ORGANIZATION_ID    = HORG.ID
         AND FCT.TIME_ID            = L_WEEK_IDS(3)
         AND FCT.CALENDAR_TYPE      = L_CALENDAR_TYPE
         AND FCT.PERIOD_TYPE_ID     = L_PERIOD_TYPE_ID
         AND FCT.THRESHOLD          = L_THRESHOLD
         AND FCT.AS_OF_DATE        <= L_WEEK_END_DATE(3)
       UNION ALL
       SELECT  /*+ ORDERED */
               HORG.NAME           ORGANIZATION_ID
	      ,HORG.ID             ID
              ,0 TOTAL_RESOURCES
              ,0 CURR_AVL
              ,0 WEEK_1
              ,0 WEEK_2
              ,FCT.AVAILABILITY    WEEK_3
              ,0 WEEK_4
       FROM PJI_PMV_ORGZ_DIM_TMP    HORG,
            PJI_CA_ORGO_F_MV        FCT,
            PJI_PMV_ORG_DIM_TMP     HOU
       WHERE FCT.EXPENDITURE_ORG_ID = HOU.ID
         AND FCT.EXPENDITURE_ORGANIZATION_ID    = HORG.ID
         AND FCT.TIME_ID            = L_WEEK_IDS(4)
         AND FCT.CALENDAR_TYPE      = L_CALENDAR_TYPE
         AND FCT.PERIOD_TYPE_ID     = L_PERIOD_TYPE_ID
         AND FCT.THRESHOLD          = L_THRESHOLD
         AND FCT.AS_OF_DATE        <= L_WEEK_END_DATE(4)
       UNION ALL
       SELECT  /*+ ORDERED */
               HORG.NAME           ORGANIZATION_ID
	      ,HORG.ID             ID
              ,0 TOTAL_RESOURCES
              ,0 CURR_AVL
              ,0 WEEK_1
              ,0 WEEK_2
              ,0 WEEK_3
              ,FCT.AVAILABILITY    WEEK_4
       FROM PJI_PMV_ORGZ_DIM_TMP    HORG,
            PJI_CA_ORGO_F_MV        FCT,
            PJI_PMV_ORG_DIM_TMP     HOU
       WHERE FCT.EXPENDITURE_ORG_ID = HOU.ID
         AND FCT.EXPENDITURE_ORGANIZATION_ID    = HORG.ID
         AND FCT.TIME_ID            = L_WEEK_IDS(5)
         AND FCT.CALENDAR_TYPE      = L_CALENDAR_TYPE
         AND FCT.PERIOD_TYPE_ID     = L_PERIOD_TYPE_ID
         AND FCT.THRESHOLD          = L_THRESHOLD
         AND FCT.AS_OF_DATE        <= L_WEEK_END_DATE(5)
       UNION ALL
       SELECT
              NAME     ORGANIZATION_ID
	     ,ID       ID
             ,0        TOTAL_RESOURCES
             ,0        CURR_AVL
             ,0        WEEK_1
             ,0        WEEK_2
             ,0        WEEK_3
             ,0        WEEK_4
       FROM PJI_PMV_ORGZ_DIM_TMP
       WHERE NAME <> '-1'
   ) GROUP BY ORGANIZATION_ID, ID;

   FOR I IN 1..L_CUR_AVL_RES_TBL.COUNT
   LOOP
      IF L_CUR_AVL_RES_TBL(I).ORGANIZATION_ID = L_TOP_ORGANIZATION_NAME THEN
         L_TOP_ORG_INDEX:=I;

         L_TO_TOTAL_CURR_AVL_RES    := NVL(L_CUR_AVL_RES_TBL(I).CURR_AVL_RES, 0);
         L_TO_TOTAL_TOTAL_RESOURCES := NVL(L_CUR_AVL_RES_TBL(I).TOTAL_RESOURCES, 0);
         L_TO_TOTAL_W1 := NVL(L_CUR_AVL_RES_TBL(I).W1, 0);
         L_TO_TOTAL_W2 := NVL(L_CUR_AVL_RES_TBL(I).W2, 0);
         L_TO_TOTAL_W3 := NVL(L_CUR_AVL_RES_TBL(I).W3, 0);
         L_TO_TOTAL_W4 := NVL(L_CUR_AVL_RES_TBL(I).W4, 0);

      ELSE
         L_TOTAL_CURR_AVL_RES := L_TOTAL_CURR_AVL_RES+NVL(L_CUR_AVL_RES_TBL(I).CURR_AVL_RES, 0);
         L_TOTAL_TOTAL_RESOURCES := L_TOTAL_TOTAL_RESOURCES+NVL(L_CUR_AVL_RES_TBL(I).TOTAL_RESOURCES, 0);
         L_TOTAL_W1 := L_TOTAL_W1 + NVL(L_CUR_AVL_RES_TBL(I).W1, 0);
         L_TOTAL_W2 := L_TOTAL_W2 + NVL(L_CUR_AVL_RES_TBL(I).W2, 0);
         L_TOTAL_W3 := L_TOTAL_W3 + NVL(L_CUR_AVL_RES_TBL(I).W3, 0);
         L_TOTAL_W4 := L_TOTAL_W4 + NVL(L_CUR_AVL_RES_TBL(I).W4, 0);
         IF NVL(L_CUR_AVL_RES_TBL(I).TOTAL_RESOURCES, 0) <> 0 THEN
            L_CUR_AVL_RES_TBL(I).CURR_AVL_RES_PER:=
            (L_CUR_AVL_RES_TBL(I).CURR_AVL_RES * 100)/L_CUR_AVL_RES_TBL(I).TOTAL_RESOURCES;
         ELSE
            L_CUR_AVL_RES_TBL(I).CURR_AVL_RES_PER:=NULL;
         END IF;
      END IF;
   END LOOP;

   IF NVL(L_TOP_ORG_INDEX, 0) > 0 THEN
      L_CUR_AVL_RES_TBL(L_TOP_ORG_INDEX).CURR_AVL_RES := L_CUR_AVL_RES_TBL(L_TOP_ORG_INDEX).CURR_AVL_RES - L_TOTAL_CURR_AVL_RES;
      L_CUR_AVL_RES_TBL(L_TOP_ORG_INDEX).TOTAL_RESOURCES := L_CUR_AVL_RES_TBL(L_TOP_ORG_INDEX).TOTAL_RESOURCES - L_TOTAL_TOTAL_RESOURCES;
      L_CUR_AVL_RES_TBL(L_TOP_ORG_INDEX).W1 := L_CUR_AVL_RES_TBL(L_TOP_ORG_INDEX).W1 - L_TOTAL_W1;
      L_CUR_AVL_RES_TBL(L_TOP_ORG_INDEX).W2 := L_CUR_AVL_RES_TBL(L_TOP_ORG_INDEX).W2 - L_TOTAL_W2;
      L_CUR_AVL_RES_TBL(L_TOP_ORG_INDEX).W3 := L_CUR_AVL_RES_TBL(L_TOP_ORG_INDEX).W3 - L_TOTAL_W3;
      L_CUR_AVL_RES_TBL(L_TOP_ORG_INDEX).W4 := L_CUR_AVL_RES_TBL(L_TOP_ORG_INDEX).W4 - L_TOTAL_W4;
      IF NVL(L_CUR_AVL_RES_TBL(L_TOP_ORG_INDEX).TOTAL_RESOURCES, 0) <> 0 THEN
         L_CUR_AVL_RES_TBL(L_TOP_ORG_INDEX).CURR_AVL_RES_PER := (L_CUR_AVL_RES_TBL(L_TOP_ORG_INDEX).CURR_AVL_RES * 100)/L_CUR_AVL_RES_TBL(L_TOP_ORG_INDEX).TOTAL_RESOURCES;
      ELSE
         L_CUR_AVL_RES_TBL(L_TOP_ORG_INDEX).CURR_AVL_RES_PER := NULL;
      END IF;
   END IF;

   FOR I IN 1..L_CUR_AVL_RES_TBL.COUNT
   LOOP
      L_CUR_AVL_RES_TBL(I).PJI_REP_TOTAL_1 := L_TO_TOTAL_CURR_AVL_RES;
      L_CUR_AVL_RES_TBL(I).PJI_REP_TOTAL_2 := L_TO_TOTAL_TOTAL_RESOURCES;
      L_CUR_AVL_RES_TBL(I).PJI_REP_TOTAL_3 := L_TO_TOTAL_W1;
      L_CUR_AVL_RES_TBL(I).PJI_REP_TOTAL_4 := L_TO_TOTAL_W2;
      L_CUR_AVL_RES_TBL(I).PJI_REP_TOTAL_5 := L_TO_TOTAL_W3;
      L_CUR_AVL_RES_TBL(I).PJI_REP_TOTAL_6 := L_TO_TOTAL_W4;

      IF NVL(L_CUR_AVL_RES_TBL(I).PJI_REP_TOTAL_2, 0) <> 0 THEN
         L_CUR_AVL_RES_TBL(I).PJI_REP_TOTAL_7 := (L_CUR_AVL_RES_TBL(I).PJI_REP_TOTAL_1 * 100)/L_CUR_AVL_RES_TBL(I).PJI_REP_TOTAL_2;
      ELSE
         L_CUR_AVL_RES_TBL(I).PJI_REP_TOTAL_7 := NULL;
      END IF;
   END LOOP;

   IF NVL(L_CUR_AVL_RES_TBL(L_TOP_ORG_INDEX).CURR_AVL_RES, 0) = 0
      AND NVL(L_CUR_AVL_RES_TBL(L_TOP_ORG_INDEX).TOTAL_RESOURCES, 0) = 0
      AND NVL(L_CUR_AVL_RES_TBL(L_TOP_ORG_INDEX).W1, 0) = 0
      AND NVL(L_CUR_AVL_RES_TBL(L_TOP_ORG_INDEX).W2, 0) = 0
      AND NVL(L_CUR_AVL_RES_TBL(L_TOP_ORG_INDEX).W3, 0) = 0
      AND NVL(L_CUR_AVL_RES_TBL(L_TOP_ORG_INDEX).W4, 0) = 0
      AND NVL(L_CUR_AVL_RES_TBL(L_TOP_ORG_INDEX).CURR_AVL_RES_PER, 0) = 0
   THEN
      L_CUR_AVL_RES_TBL.DELETE(L_TOP_ORG_INDEX);
   END IF;

   COMMIT;
   RETURN L_CUR_AVL_RES_TBL;

END PLSQLDRIVER_RA2;


/******************************************************
 * RA3: AVAILABLE RESOURCE DURATION REPORT FUNCTIONS
 ******************************************************/
PROCEDURE GET_SQL_PJI_REP_RA3 (P_PAGE_PARAMETER_TBL IN BIS_PMV_PAGE_PARAMETER_TBL
                             , X_PMV_SQL OUT NOCOPY  VARCHAR2
                             , X_PMV_OUTPUT OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL)
 IS
BEGIN

    PJI_PMV_ENGINE.GENERATE_SQL(P_PAGE_PARAMETER_TBL  => P_PAGE_PARAMETER_TBL
                               ,P_SELECT_LIST      =>
                               'FACT.EXP_ORGANIZATION_ID "VIEWBYID",
                                FACT.CURR_AVL_RES  "PJI_REP_MSR_2",
                                FACT.TOTAL_AVL_RES  "PJI_REP_MSR_3",
                                FACT.TOTAL_RESOURCES  "PJI_REP_MSR_4",
                                FACT.TOTAL_AVL_RES_PERCENT  "PJI_REP_MSR_5",
                                FACT.BUCKET1  "PJI_REP_MSR_11",
                                FACT.BUCKET2  "PJI_REP_MSR_12",
                                FACT.BUCKET3  "PJI_REP_MSR_13",
                                FACT.BUCKET4  "PJI_REP_MSR_14",
                                FACT.BUCKET5  "PJI_REP_MSR_15",
                                FACT.PJI_REP_TOTAL_1 "PJI_REP_TOTAL_1",
                                FACT.PJI_REP_TOTAL_2 "PJI_REP_TOTAL_2",
                                FACT.PJI_REP_TOTAL_3 "PJI_REP_TOTAL_3",
                                FACT.PJI_REP_TOTAL_4 "PJI_REP_TOTAL_4",
                                FACT.PJI_REP_TOTAL_5 "PJI_REP_TOTAL_5",
                                FACT.PJI_REP_TOTAL_6 "PJI_REP_TOTAL_6",
                                FACT.PJI_REP_TOTAL_7 "PJI_REP_TOTAL_7",
                                FACT.PJI_REP_TOTAL_8 "PJI_REP_TOTAL_8",
                                FACT.PJI_REP_TOTAL_9 "PJI_REP_TOTAL_9"'
                               ,P_SQL_STATEMENT       => X_PMV_SQL
                               ,P_PMV_OUTPUT          => X_PMV_OUTPUT,
                                P_REGION_CODE         => 'PJI_REP_RA3',
                                P_PLSQL_DRIVER        => 'PJI_PMV_AVL.PLSQLDRIVER_RA3',
                                P_PLSQL_DRIVER_PARAMS =>   '<<ORGANIZATION+FII_OPERATING_UNITS>>, ' ||
                                                           '<<ORGANIZATION+PJI_ORGANIZATIONS>>, ' ||
                                                           '<<AVAILABILITY_THRESHOLD+AVAILABILITY_THRESHOLD>>, ' ||
                                                           '<<AVAILABILITY_TYPE+AVAILABILITY_TYPE>>, ' ||
                                                           '<<AS_OF_DATE>>, ' ||
                                                           '<<PERIOD_TYPE>>, ' ||
                                                           '<<VIEW_BY>>');
END GET_SQL_PJI_REP_RA3;

FUNCTION PLSQLDRIVER_RA3 (
   P_OPERATING_UNIT        IN VARCHAR2 DEFAULT NULL,
   P_ORGANIZATION          IN VARCHAR2,
   P_THRESHOLD             IN NUMBER,
   P_AVL_TYPE              IN VARCHAR2,
   P_AS_OF_DATE            IN NUMBER,
   P_PERIOD_TYPE           IN VARCHAR2,
   P_VIEW_BY               IN VARCHAR2
)  RETURN PJI_REP_RA3_TBL
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   L_AVL_RES_DUR_TBL     PJI_REP_RA3_TBL := PJI_REP_RA3_TBL();
   L_THRESHOLD           NUMBER          := P_THRESHOLD;
   L_AS_OF_DATE          NUMBER          := P_AS_OF_DATE;
   L_AVL_TYPE            VARCHAR2(60)    := P_AVL_TYPE;

   L_CURR_AVL_RES            NUMBER:=0;
   L_TOTAL_AVL_RES           NUMBER:=0;
   L_TOTAL_RESOURSES         NUMBER:=0;
   L_AVL_1_5_DAYS            NUMBER:=0;
   L_AVL_6_10_DAYS           NUMBER:=0;
   L_AVL_11_15_DAYS          NUMBER:=0;
   L_AVL_16_20_DAYS          NUMBER:=0;
   L_AVL_MORE_THAN_20_DAYS   NUMBER:=0;

   L_TO_CURR_AVL_RES            NUMBER:=0;
   L_TO_TOTAL_AVL_RES           NUMBER:=0;
   L_TO_TOTAL_RESOURSES         NUMBER:=0;
   L_TO_AVL_1_5_DAYS            NUMBER:=0;
   L_TO_AVL_6_10_DAYS           NUMBER:=0;
   L_TO_AVL_11_15_DAYS          NUMBER:=0;
   L_TO_AVL_16_20_DAYS          NUMBER:=0;
   L_TO_AVL_MORE_THAN_20_DAYS   NUMBER:=0;

   L_TOP_ORGANIZATION_NAME  VARCHAR2(240);
   L_TOP_ORG_INDEX          NUMBER:=0;
   l_DAY_CALENDAR_TYPE      VARCHAR2(1):='C';
   l_DAY_PERIOD_TYPE        NUMBER:=1;
BEGIN

   PJI_PMV_ENGINE.CONVERT_OPERATING_UNIT (P_OPERATING_UNIT, P_VIEW_BY);
   PJI_PMV_ENGINE.CONVERT_ORGANIZATION (P_ORGANIZATION, P_VIEW_BY, L_TOP_ORGANIZATION_NAME);
   PJI_PMV_ENGINE.CONVERT_TIME (P_AS_OF_DATE=>P_AS_OF_DATE,
                               P_PERIOD_TYPE=>P_PERIOD_TYPE,
                               P_VIEW_BY    =>P_VIEW_BY,
                               P_PARSE_PRIOR=>NULL,
                               P_REPORT_TYPE=>NULL,
                               P_COMPARATOR =>NULL,
                               P_PARSE_ITD  =>NULL,
                               P_FULL_PERIOD_FLAG =>'Y');

   -- IF P_AS_OF_DATE IS NULL, THEN SET THE DEFAULT VALUE TO SYSDATE
   IF L_AS_OF_DATE IS NULL THEN
      L_AS_OF_DATE := TO_NUMBER(TO_CHAR(SYSDATE, 'J'));
   END IF;

   -- IF AVAILABILITY TYPE IS NULL, SET TO 'CUMULATIVE'
   IF L_AVL_TYPE IS NULL THEN
      L_AVL_TYPE := 'CUMULATIVE';
   END IF;

   -- RETURN DIFFERENT SQL DEPENDING ON THE AVAILABILITY TYPE
   -- EITHER CUMULATIVE OR CONSECUTIVE

IF P_THRESHOLD IS NULL THEN
   BEGIN
      SELECT  DISTINCT
       FIRST_VALUE(ID) OVER (ORDER BY VALUE DESC) INTO L_THRESHOLD
       FROM PJI_AVL_THRESHOLDS_V;
   END;
END IF;


       SELECT PJI_REP_RA3    ( ORGANIZATION_ID
                              , EXP_ORGANIZATION_ID
                              ,SUM(AVAILABILITY)
                              ,SUM(CUR_AVL_1)
                                + SUM(CUR_AVL_2)
                                + SUM(CUR_AVL_3)
                                + SUM(CUR_AVL_4)
                                + SUM(CUR_AVL_5)
                              ,SUM(TOTAL_RES_COUNT)
                              , 0
                              ,SUM(CUR_AVL_1)
                              ,SUM(CUR_AVL_2)
                              ,SUM(CUR_AVL_3)
                              ,SUM(CUR_AVL_4)
                              ,SUM(CUR_AVL_5)
                              , 0
                              , 0
                              , 0
                              , 0
                              , 0
                              , 0
                              , 0
                              , 0
                              , 0)
       BULK COLLECT INTO L_AVL_RES_DUR_TBL
       FROM (
            SELECT /*+ ORDERED */
                   HORG.NAME    ORGANIZATION_ID
                  , HORG.ID     EXP_ORGANIZATION_ID
                  , DECODE (L_THRESHOLD, 1, available_res_count_bkt1_s,
                                         2, available_res_count_bkt2_s,
                                         3, available_res_count_bkt3_s,
                                         4, available_res_count_bkt4_s,
                                         5, available_res_count_bkt5_s) AVAILABILITY
                  , 0  TOTAL_RES_COUNT
                  , 0  CUR_AVL_1
                  , 0  CUR_AVL_2
                  , 0  CUR_AVL_3
                  , 0  CUR_AVL_4
                  , 0  CUR_AVL_5
            FROM PJI_PMV_ORGZ_DIM_TMP HORG,
                 PJI_RM_ORGO_F_MV FCT,
                 PJI_PMV_ORG_DIM_TMP HOU
            WHERE FCT.EXPENDITURE_ORG_ID = HOU.ID
              AND FCT.EXPENDITURE_ORGANIZATION_ID = HORG.ID
              AND FCT.PERIOD_TYPE_ID = l_DAY_PERIOD_TYPE
              AND FCT.CALENDAR_TYPE  = l_DAY_CALENDAR_TYPE
              AND FCT.TIME_ID = L_AS_OF_DATE
            UNION ALL
            SELECT /*+ ORDERED */
                   HORG.NAME                       ORGANIZATION_ID
                  , HORG.ID                        EXP_ORGANIZATION_ID
                  , 0  AVAILABILITY
                  , TOTAL_RES_COUNT  TOTAL_RES_COUNT
                  , DECODE (L_AVL_TYPE, 'CUMULATIVE', BCKT_1_CM,
                                        'CONSECUTIVE', BCKT_1_CS, 0) CUR_AVL_1
                  , DECODE (L_AVL_TYPE, 'CUMULATIVE', BCKT_2_CM,
                                        'CONSECUTIVE', BCKT_2_CS, 0) CUR_AVL_2
                  , DECODE (L_AVL_TYPE, 'CUMULATIVE', BCKT_3_CM,
                                        'CONSECUTIVE', BCKT_3_CS, 0) CUR_AVL_3
                  , DECODE (L_AVL_TYPE, 'CUMULATIVE', BCKT_4_CM,
                                        'CONSECUTIVE', BCKT_4_CS, 0) CUR_AVL_4
                  , DECODE (L_AVL_TYPE, 'CUMULATIVE', BCKT_5_CM,
                                        'CONSECUTIVE', BCKT_5_CS, 0) CUR_AVL_5
           FROM  PJI_PMV_ORGZ_DIM_TMP HORG,
                 PJI_PMV_TIME_DIM_TMP TIME,
                 PJI_AV_ORGO_F_MV FCT,
                 PJI_PMV_ORG_DIM_TMP HOU
            WHERE FCT.EXPENDITURE_ORG_ID = HOU.ID
              AND FCT.EXPENDITURE_ORGANIZATION_ID = HORG.ID
              AND FCT.TIME_ID = TIME.ID
              AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
              AND FCT.CALENDAR_TYPE  = TIME.CALENDAR_TYPE
              AND FCT.THRESHOLD = L_THRESHOLD
              AND FCT.AS_OF_DATE <= L_AS_OF_DATE
           AND TIME.AMOUNT_TYPE=2
UNION ALL
            SELECT /*+ ORDERED */
                   NAME
                  , ID
                  , 0  AVAILABILITY
                  , 0  TOTAL_RES_COUNT
                  , 0  CUR_AVL_1
                  , 0  CUR_AVL_2
                  , 0  CUR_AVL_3
                  , 0  CUR_AVL_4
                  , 0  CUR_AVL_5
            FROM PJI_PMV_ORGZ_DIM_TMP HORG
            WHERE NAME <> '-1')
            GROUP BY ORGANIZATION_ID,
                     EXP_ORGANIZATION_ID;

-- ********************************************

   FOR I IN 1..L_AVL_RES_DUR_TBL.COUNT
     LOOP
   		IF L_AVL_RES_DUR_TBL(I).ORGANIZATION_ID = L_TOP_ORGANIZATION_NAME THEN
   			 L_TOP_ORG_INDEX:=I;

                   L_TO_CURR_AVL_RES    := NVL(L_AVL_RES_DUR_TBL(I).CURR_AVL_RES, 0);
                   L_TO_TOTAL_AVL_RES   := NVL(L_AVL_RES_DUR_TBL(I).TOTAL_AVL_RES, 0);
                   L_TO_TOTAL_RESOURSES := NVL(L_AVL_RES_DUR_TBL(I).TOTAL_RESOURCES, 0);
                   L_TO_AVL_1_5_DAYS    := NVL(L_AVL_RES_DUR_TBL(I).BUCKET1, 0);
                   L_TO_AVL_6_10_DAYS   := NVL(L_AVL_RES_DUR_TBL(I).BUCKET2, 0);
                   L_TO_AVL_11_15_DAYS  := NVL(L_AVL_RES_DUR_TBL(I).BUCKET3, 0);
                   L_TO_AVL_16_20_DAYS  := NVL(L_AVL_RES_DUR_TBL(I).BUCKET4, 0);
                   L_TO_AVL_MORE_THAN_20_DAYS := NVL(L_AVL_RES_DUR_TBL(I).BUCKET5, 0);

           ELSE
                   L_CURR_AVL_RES  :=L_CURR_AVL_RES
   				          + NVL(L_AVL_RES_DUR_TBL(I).CURR_AVL_RES, 0);

                   L_TOTAL_AVL_RES := L_TOTAL_AVL_RES
   				          + NVL(L_AVL_RES_DUR_TBL(I).TOTAL_AVL_RES, 0);

                   L_TOTAL_RESOURSES        :=L_TOTAL_RESOURSES
                                   + NVL(L_AVL_RES_DUR_TBL(I).TOTAL_RESOURCES, 0);

                   L_AVL_1_5_DAYS           :=L_AVL_1_5_DAYS
                                   + NVL(L_AVL_RES_DUR_TBL(I).BUCKET1, 0);

                   L_AVL_6_10_DAYS          :=L_AVL_6_10_DAYS
                                   + NVL(L_AVL_RES_DUR_TBL(I).BUCKET2, 0);

                   L_AVL_11_15_DAYS         :=L_AVL_11_15_DAYS
                                   + NVL(L_AVL_RES_DUR_TBL(I).BUCKET3, 0);

                   L_AVL_16_20_DAYS         :=L_AVL_16_20_DAYS
                                   + NVL(L_AVL_RES_DUR_TBL(I).BUCKET4, 0);

                   L_AVL_MORE_THAN_20_DAYS  :=L_AVL_MORE_THAN_20_DAYS
                                   + NVL(L_AVL_RES_DUR_TBL(I).BUCKET5, 0);

           END IF;
   END LOOP;

   IF NVL(L_TOP_ORG_INDEX, 0) <>0 THEN
   		L_AVL_RES_DUR_TBL(L_TOP_ORG_INDEX).CURR_AVL_RES
       		:= NVL(L_AVL_RES_DUR_TBL(L_TOP_ORG_INDEX).CURR_AVL_RES,0)
                       -L_CURR_AVL_RES;

   		L_AVL_RES_DUR_TBL(L_TOP_ORG_INDEX).TOTAL_AVL_RES
       		:= NVL(L_AVL_RES_DUR_TBL(L_TOP_ORG_INDEX).TOTAL_AVL_RES,0)
                       -L_TOTAL_AVL_RES;

   		L_AVL_RES_DUR_TBL(L_TOP_ORG_INDEX).TOTAL_RESOURCES
       		:= NVL(L_AVL_RES_DUR_TBL(L_TOP_ORG_INDEX).TOTAL_RESOURCES,0)
                       -L_TOTAL_RESOURSES;

   		L_AVL_RES_DUR_TBL(L_TOP_ORG_INDEX).BUCKET1
       		:= NVL(L_AVL_RES_DUR_TBL(L_TOP_ORG_INDEX).BUCKET1,0)
                       -L_AVL_1_5_DAYS;

   		L_AVL_RES_DUR_TBL(L_TOP_ORG_INDEX).BUCKET2
       		:= NVL(L_AVL_RES_DUR_TBL(L_TOP_ORG_INDEX).BUCKET2,0)
                       -L_AVL_6_10_DAYS;

     		L_AVL_RES_DUR_TBL(L_TOP_ORG_INDEX).BUCKET3
       		:= NVL(L_AVL_RES_DUR_TBL(L_TOP_ORG_INDEX).BUCKET3,0)
                       -L_AVL_11_15_DAYS;

   		L_AVL_RES_DUR_TBL(L_TOP_ORG_INDEX).BUCKET4
       		:= NVL(L_AVL_RES_DUR_TBL(L_TOP_ORG_INDEX).BUCKET4,0)
                       -L_AVL_16_20_DAYS;

   		L_AVL_RES_DUR_TBL(L_TOP_ORG_INDEX).BUCKET5
       		:= NVL(L_AVL_RES_DUR_TBL(L_TOP_ORG_INDEX).BUCKET5,0)
                       -L_AVL_MORE_THAN_20_DAYS;

      IF
           NVL(L_AVL_RES_DUR_TBL(L_TOP_ORG_INDEX).CURR_AVL_RES   ,0) =0 AND
           NVL(L_AVL_RES_DUR_TBL(L_TOP_ORG_INDEX).TOTAL_AVL_RES   ,0) =0 AND
           NVL(L_AVL_RES_DUR_TBL(L_TOP_ORG_INDEX).TOTAL_RESOURCES ,0) =0 AND
           NVL(L_AVL_RES_DUR_TBL(L_TOP_ORG_INDEX).TOTAL_AVL_RES_PERCENT  ,0) =0 AND
           NVL(L_AVL_RES_DUR_TBL(L_TOP_ORG_INDEX).BUCKET1   ,0) =0 AND
           NVL(L_AVL_RES_DUR_TBL(L_TOP_ORG_INDEX).BUCKET2   ,0) =0 AND
           NVL(L_AVL_RES_DUR_TBL(L_TOP_ORG_INDEX).BUCKET3   ,0) =0 AND
           NVL(L_AVL_RES_DUR_TBL(L_TOP_ORG_INDEX).BUCKET4   ,0) =0 AND
           NVL(L_AVL_RES_DUR_TBL(L_TOP_ORG_INDEX).BUCKET5   ,0) =0
        THEN
           L_AVL_RES_DUR_TBL.DELETE(L_TOP_ORG_INDEX);
      END IF;

      L_CURR_AVL_RES           :=L_TO_CURR_AVL_RES;
      L_TOTAL_AVL_RES          :=L_TO_TOTAL_AVL_RES;
      L_TOTAL_RESOURSES        :=L_TO_TOTAL_RESOURSES;
      L_AVL_1_5_DAYS           :=L_TO_AVL_1_5_DAYS;
      L_AVL_6_10_DAYS          :=L_TO_AVL_6_10_DAYS;
      L_AVL_11_15_DAYS         :=L_TO_AVL_11_15_DAYS;
      L_AVL_16_20_DAYS         :=L_TO_AVL_16_20_DAYS;
      L_AVL_MORE_THAN_20_DAYS  :=L_TO_AVL_MORE_THAN_20_DAYS;

    END IF;

    IF L_AVL_RES_DUR_TBL.COUNT > 0 THEN
      FOR I IN L_AVL_RES_DUR_TBL.FIRST..L_AVL_RES_DUR_TBL.LAST
      LOOP
        IF L_AVL_RES_DUR_TBL.EXISTS(I) THEN
           IF NVL(L_AVL_RES_DUR_TBL(I).TOTAL_RESOURCES, 0)=0 THEN
              L_AVL_RES_DUR_TBL(I).TOTAL_AVL_RES_PERCENT:= NULL;
           ELSE
              L_AVL_RES_DUR_TBL(I).TOTAL_AVL_RES_PERCENT:=
                  (L_AVL_RES_DUR_TBL(I).TOTAL_AVL_RES
                       /L_AVL_RES_DUR_TBL(I).TOTAL_RESOURCES)*100;
           END IF;
        END IF;
      END LOOP;

      FOR I IN L_AVL_RES_DUR_TBL.FIRST..L_AVL_RES_DUR_TBL.LAST
      LOOP
        IF L_AVL_RES_DUR_TBL.EXISTS(I) THEN
   			L_AVL_RES_DUR_TBL(I).PJI_REP_TOTAL_1 := L_CURR_AVL_RES ;
   			L_AVL_RES_DUR_TBL(I).PJI_REP_TOTAL_2 := L_TOTAL_AVL_RES;
   			L_AVL_RES_DUR_TBL(I).PJI_REP_TOTAL_3 := L_TOTAL_RESOURSES;
   			L_AVL_RES_DUR_TBL(I).PJI_REP_TOTAL_5 := L_AVL_1_5_DAYS;
   			L_AVL_RES_DUR_TBL(I).PJI_REP_TOTAL_6 := L_AVL_6_10_DAYS;
   			L_AVL_RES_DUR_TBL(I).PJI_REP_TOTAL_7 := L_AVL_11_15_DAYS;
   			L_AVL_RES_DUR_TBL(I).PJI_REP_TOTAL_8 := L_AVL_16_20_DAYS;
   			L_AVL_RES_DUR_TBL(I).PJI_REP_TOTAL_9 := L_AVL_MORE_THAN_20_DAYS;


           IF NVL(L_AVL_RES_DUR_TBL(I).PJI_REP_TOTAL_3, 0)=0 THEN
                   L_AVL_RES_DUR_TBL(I).PJI_REP_TOTAL_4:= NULL;
           ELSE
                   L_AVL_RES_DUR_TBL(I).PJI_REP_TOTAL_4:=
                  (L_AVL_RES_DUR_TBL(I).PJI_REP_TOTAL_2
                    /L_AVL_RES_DUR_TBL(I).PJI_REP_TOTAL_3)*100;
           END IF;
        END IF;
      END LOOP;
    END IF;

   --*********************************************

   COMMIT;
   RETURN L_AVL_RES_DUR_TBL;

END PLSQLDRIVER_RA3;


/******************************************************
 * RA4: AVAILABILITY TREND REPORT FUNCTIONS
 ******************************************************/
PROCEDURE GET_SQL_PJI_REP_RA4 (P_PAGE_PARAMETER_TBL IN BIS_PMV_PAGE_PARAMETER_TBL
                             , X_PMV_SQL OUT NOCOPY  VARCHAR2
                             , X_PMV_OUTPUT OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL)
 IS
BEGIN

    PJI_PMV_ENGINE.GENERATE_SQL(P_PAGE_PARAMETER_TBL  => P_PAGE_PARAMETER_TBL
                              , P_SELECT_LIST  =>
                               'FACT.UNASSIGNED     "PJI_REP_MSR_29",
                                FACT.AVAILABLE      "PJI_REP_MSR_28",
				FACT.SCHEDULED_UTIL "PJI_REP_MSR_30",
				FACT.CAPACITY       "PJI_REP_MSR_3",
                                FACT.CONFIRMED      "PJI_REP_MSR_4",
                                FACT.PROVISIONAL    "PJI_REP_MSR_5",
                                FACT.UNASSIGNED     "PJI_REP_MSR_11",
                                FACT.AVAILABLE      "PJI_REP_MSR_12",
                                FACT.AVAILABLE_URL      "PJI_REP_MSR_22",
				FACT.PER_HRS_AVAILABLE  "PJI_REP_MSR_13",
                                FACT.SCHEDULED_UTIL_PER  "PJI_REP_MSR_15"'
                               ,P_SQL_STATEMENT       => X_PMV_SQL
                               ,P_PMV_OUTPUT          => X_PMV_OUTPUT,
                                P_REGION_CODE         => 'PJI_REP_RA4',
                                P_PLSQL_DRIVER        => 'PJI_PMV_AVL.PLSQLDRIVER_RA4',
                                P_PLSQL_DRIVER_PARAMS => '<<ORGANIZATION+FII_OPERATING_UNITS>>, ' ||
                                                         '<<ORGANIZATION+PJI_ORGANIZATIONS>>, ' ||
                                                         '<<AVAILABILITY_THRESHOLD+AVAILABILITY_THRESHOLD>>, ' ||
                                                         '<<AS_OF_DATE>>, ' ||
                                                         '<<PERIOD_TYPE>>, ' ||
                                                         '<<VIEW_BY>>');
END GET_SQL_PJI_REP_RA4;

FUNCTION PLSQLDRIVER_RA4 (
   P_OPERATING_UNIT        IN VARCHAR2 DEFAULT NULL,
   P_ORGANIZATION          IN VARCHAR2,
   P_THRESHOLD             IN NUMBER,
   P_AS_OF_DATE            IN NUMBER,
   P_PERIOD_TYPE           IN VARCHAR2,
   P_VIEW_BY               IN VARCHAR2
)  RETURN PJI_REP_RA4_TBL
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   L_TOP_ORGANIZATION_NAME   VARCHAR2(240);
   L_RA4_TBL                 PJI_REP_RA4_TBL := PJI_REP_RA4_TBL();
   L_THRESHOLD               NUMBER:=P_THRESHOLD;
BEGIN

   PJI_PMV_ENGINE.CONVERT_OPERATING_UNIT (P_OPERATING_UNIT, P_VIEW_BY);

   PJI_PMV_ENGINE.CONVERT_ORGANIZATION ( P_TOP_ORGANIZATION_ID => P_ORGANIZATION
                                       , P_VIEW_BY => P_VIEW_BY
                                       , P_TOP_ORGANIZATION_NAME => L_TOP_ORGANIZATION_NAME);

   PJI_PMV_ENGINE.CONVERT_TIME ( P_AS_OF_DATE => P_AS_OF_DATE
                                         , P_PERIOD_TYPE => P_PERIOD_TYPE
                                         , P_VIEW_BY => P_VIEW_BY
                                         , P_PARSE_PRIOR => NULL
                                         , P_REPORT_TYPE => NULL
                                         , P_COMPARATOR => NULL
                                         , P_PARSE_ITD => NULL
                                         , P_FULL_PERIOD_FLAG => 'Y');

   -- GET THE LABOR UNITS
   IF G_LABOUR_UNITS IS NULL THEN
	 BEGIN
     	     SELECT REPORT_LABOR_UNITS
           INTO G_LABOUR_UNITS
           FROM PJI_SYSTEM_SETTINGS;
       EXCEPTION
           WHEN OTHERS THEN
             G_LABOUR_UNITS := NULL;
       END;
   END IF;

IF P_THRESHOLD IS NULL THEN
   BEGIN
      SELECT  DISTINCT
       FIRST_VALUE(ID) OVER (ORDER BY VALUE DESC) INTO L_THRESHOLD
       FROM PJI_AVL_THRESHOLDS_V;
   END;
END IF;


   SELECT PJI_REP_RA4(
            ORG_ID
           ,ORGANIZATION_ID
           ,TIME_ID
           ,TIME_KEY
           ,SUM(CAPACITY)
           ,SUM(CONFIRMED)
           ,SUM(PROVISIONAL)
           ,SUM(UNASSIGNED)
           ,SUM(SCHEDULED_UTIL)
           ,SUM(DECODE(L_THRESHOLD, 1, AVL_BKT1
                                  , 2, AVL_BKT2
                                  , 3, AVL_BKT3
                                  , 4, AVL_BKT4
                                  , 5, AVL_BKT5
                                  , 0))
           ,PJI_PMV_UTIL.ra4_ra5_url(TIME_ID, p_organization, p_operating_unit, l_threshold, p_period_type)
	   ,NULL
           ,NULL)
   BULK COLLECT INTO L_RA4_TBL
   FROM ( /* Bug 3515594 */
         SELECT /*+ ORDERED */
               HOU.NAME                                       ORG_ID
              ,HORG.NAME                                      ORGANIZATION_ID
              ,TIME.NAME                                      TIME_ID
              ,DECODE(P_VIEW_BY, 'TM', TIME.ORDER_BY_ID, -1)  TIME_KEY
              ,CAPACITY_HRS / DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY, 'WEEKS',IMP.FTE_WEEK, 1)
                                 CAPACITY
              ,(CONF_HRS_S - CONF_OVERCOM_HRS_S) / DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY, 'WEEKS',IMP.FTE_WEEK, 1)
				CONFIRMED
              ,(PROV_HRS_S - PROV_OVERCOM_HRS_S) / DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY, 'WEEKS',IMP.FTE_WEEK, 1)
                           PROVISIONAL
              ,UNASSIGNED_HRS_S / DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY, 'WEEKS',IMP.FTE_WEEK, 1)
                                            UNASSIGNED

              ,CONF_WTD_ORG_HRS_S / DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY, 'WEEKS',IMP.FTE_WEEK, 1)
                                           SCHEDULED_UTIL
              ,(CASE WHEN (AVAILABLE_RES_COUNT_BKT1_S = 0)
                    THEN 0 ELSE AVAILABLE_HRS_BKT1_S /
               DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY, 'WEEKS',IMP.FTE_WEEK, 1) END) AVL_BKT1
              ,(CASE WHEN (AVAILABLE_RES_COUNT_BKT2_S = 0)
                        THEN 0 ELSE AVAILABLE_HRS_BKT2_S /
               DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY, 'WEEKS',IMP.FTE_WEEK, 1) END) AVL_BKT2
              ,(CASE WHEN (AVAILABLE_RES_COUNT_BKT3_S = 0)
                        THEN 0 ELSE AVAILABLE_HRS_BKT3_S /
               DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY, 'WEEKS',IMP.FTE_WEEK, 1) END) AVL_BKT3
              ,(CASE WHEN (AVAILABLE_RES_COUNT_BKT4_S = 0)
                        THEN 0 ELSE AVAILABLE_HRS_BKT4_S /
               DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY, 'WEEKS',IMP.FTE_WEEK, 1) END) AVL_BKT4
              ,(CASE WHEN (AVAILABLE_RES_COUNT_BKT5_S = 0)
                        THEN 0 ELSE AVAILABLE_HRS_BKT5_S /
               DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY, 'WEEKS',IMP.FTE_WEEK, 1) END) AVL_BKT5

           FROM PJI_PMV_ORGZ_DIM_TMP    HORG,
                PJI_PMV_TIME_DIM_TMP    TIME,
                PJI_RM_ORGO_F_MV        FCT,
                PJI_PMV_ORG_DIM_TMP     HOU,
                PA_IMPLEMENTATIONS_ALL  IMP
           WHERE FCT.EXPENDITURE_ORG_ID  = HOU.ID
             AND FCT.EXPENDITURE_ORGANIZATION_ID = HORG.ID
             AND HOU.ID                          = IMP.ORG_ID
             AND FCT.TIME_ID                     = TIME.ID
             AND FCT.PERIOD_TYPE_ID              = TIME.PERIOD_TYPE
             AND FCT.CALENDAR_TYPE               = TIME.CALENDAR_TYPE
             AND (TIME.AMOUNT_TYPE               = 2
             OR   TIME.AMOUNT_TYPE IS NULL)
           UNION ALL
           SELECT '-1'         ORG_ID
                 ,'-1'         ORGANIZATION_ID
                 ,NAME         TIME_ID
                 ,ORDER_BY_ID  TIME_KEY
                 ,0            CAPACITY
                 ,0            CONFIRMED
                 ,0            PROVISIONAL
                 ,0            UNASSIGNED
                 ,0            SCHEDULED_UTIL
                 ,0            AVL_BKT1
                 ,0            AVL_BKT2
                 ,0            AVL_BKT3
                 ,0            AVL_BKT4
                 ,0            AVL_BKT5
           FROM PJI_PMV_TIME_DIM_TMP
           WHERE NAME <> '-1'
   ) GROUP BY ORG_ID
             ,ORGANIZATION_ID
             ,TIME_KEY
             ,TIME_ID ORDER BY TIME_KEY ASC;

   FOR I IN 1..L_RA4_TBL.COUNT
   LOOP
       IF NVL(L_RA4_TBL(I).CAPACITY,0) <> 0 THEN
          L_RA4_TBL(I).PER_HRS_AVAILABLE := (L_RA4_TBL(I).AVAILABLE/L_RA4_TBL(I).CAPACITY)*100;
          L_RA4_TBL(I).SCHEDULED_UTIL_PER := (L_RA4_TBL(I).SCHEDULED_UTIL/L_RA4_TBL(I).CAPACITY)*100;
       ELSE
          L_RA4_TBL(I).PER_HRS_AVAILABLE := NULL;
          L_RA4_TBL(I).SCHEDULED_UTIL_PER := NULL;
       END IF;
   END LOOP;
   COMMIT;

   RETURN L_RA4_TBL;

END PLSQLDRIVER_RA4;


/****************************************************
 * RA5: AVAILABLE RESOURCE DETAILS REPORT FUNCTIONS
 ****************************************************/

PROCEDURE GET_SQL_PJI_REP_RA5 (P_PAGE_PARAMETER_TBL IN BIS_PMV_PAGE_PARAMETER_TBL
                             , X_PMV_SQL OUT NOCOPY  VARCHAR2
                             , X_PMV_OUTPUT OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL)
 IS
BEGIN

    PJI_PMV_ENGINE.GENERATE_SQL(P_PAGE_PARAMETER_TBL  => P_PAGE_PARAMETER_TBL
                               ,P_SELECT_LIST         =>
                               'FACT.PERSON_NAME  "VIEWBY",
                                FACT.JOB_LEVEL  "PJI_REP_MSR_2",
                                FACT.CAPACITY  "PJI_REP_MSR_3",
                                FACT.CONFIRMED  "PJI_REP_MSR_4",
                                FACT.PROVISIONAL  "PJI_REP_MSR_5",
                                FACT.UNASSIGNED  "PJI_REP_MSR_11",
                                FACT.AVAILABLE_HOURS  "PJI_REP_MSR_12",
                                FACT.ACT_UTIL_PER  "PJI_REP_MSR_13",
                                FACT.SCH_UTIL_PER  "PJI_REP_MSR_14",
                                TO_DATE(FACT.AVAILABLE_SINCE, ''RRRR/MM/DD'')  "PJI_REP_MSR_15",
                                FACT.CURR_LAST_PROJ  "PJI_REP_MSR_16",
                                FACT.NEXT_PROJ  "PJI_REP_MSR_17",
                                TO_DATE(FACT.NEXT_ASGMT_DATE, ''RRRR/MM/DD'')  "PJI_REP_MSR_18",
                                FACT.PERSON_ID  "PJI_REP_MSR_25",
                                FACT.REDUCE_CAP_S  "PJI_REP_MSR_26",
                                FACT.REDUCE_CAP_A  "PJI_REP_MSR_27",
                                FACT.TOT_WTD_A  "PJI_REP_MSR_29",
                                FACT.CONF_WTD_S  "PJI_REP_MSR_30"'
                               ,P_SQL_STATEMENT       => X_PMV_SQL
                               ,P_PMV_OUTPUT          => X_PMV_OUTPUT,
                                P_REGION_CODE         => 'PJI_REP_RA5',
                                P_PLSQL_DRIVER        => 'PJI_PMV_AVL.PLSQLDRIVER_RA5',
                                P_PLSQL_DRIVER_PARAMS =>   '<<ORGANIZATION+FII_OPERATING_UNITS>>, ' ||
                                                           '<<ORGANIZATION+PJI_ORGANIZATIONS>>, ' ||
                                                           '<<AVAILABILITY_THRESHOLD+AVAILABILITY_THRESHOLD>>, ' ||
                                                           '<<AVAILABILITY_DAYS+AVAILABILITY_DAYS>>, ' ||
                                                           '<<AS_OF_DATE>>, ' ||
                                                           '<<PERIOD_TYPE>>, '||
                                                           '<<VIEW_BY>>');
END GET_SQL_PJI_REP_RA5;

FUNCTION PLSQLDRIVER_RA5 (
   P_OPERATING_UNIT        IN VARCHAR2 DEFAULT NULL,
   P_ORGANIZATION          IN VARCHAR2,
   P_THRESHOLD             IN NUMBER,
   P_AVL_DAYS              IN NUMBER,
   P_AS_OF_DATE            IN NUMBER,
   P_PERIOD_TYPE           IN VARCHAR2,
   P_VIEW_BY               IN VARCHAR2
)  RETURN PJI_REP_RA5_TBL
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   L_AVL_RES_DET_TBL     PJI_REP_RA5_TBL := PJI_REP_RA5_TBL();
   L_AS_OF_DATE          NUMBER := P_AS_OF_DATE;
   L_MIN_DAYS            NUMBER;
   L_MAX_DAYS            NUMBER;
   G_LABOUR_UNITS         VARCHAR2(40);
   L_DAY_PERIOD_TYPE     NUMBER:=1;
   L_DAY_CALENDAR_TYPE   VARCHAR2(1):='C';
BEGIN

   PJI_PMV_ENGINE.CONVERT_OPERATING_UNIT (P_OPERATING_UNIT, P_VIEW_BY);
   PJI_PMV_ENGINE.CONVERT_ORGANIZATION (P_ORGANIZATION, P_VIEW_BY);
   PJI_PMV_ENGINE.CONVERT_TIME ( P_AS_OF_DATE => P_AS_OF_DATE
                                         , P_PERIOD_TYPE => P_PERIOD_TYPE
                                         , P_VIEW_BY => P_VIEW_BY
                                         , P_PARSE_PRIOR => NULL
                                         , P_REPORT_TYPE => NULL
                                         , P_COMPARATOR => NULL
                                         , P_PARSE_ITD => NULL
                                         , P_FULL_PERIOD_FLAG => 'Y');

   -- SET THE MIN_DAYS AND MAX_DAYS VARIABLES,
   -- DETERMINED BY THE AVAILABLE_DAYS PARAMETER

   BEGIN
      SELECT FROM_VALUE           FROM_VALUE
      , NVL(TO_VALUE,POWER(2,32)) TO_VALUE
      INTO L_MIN_DAYS
      , L_MAX_DAYS
      FROM PJI_MT_BUCKETS
      WHERE
      BUCKET_SET_CODE = 'PJI_RES_AVL_DAYS'
      AND SEQ = P_AVL_DAYS;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         L_MIN_DAYS:= 1;
         L_MAX_DAYS:= POWER(2, 32);
   END;

   -- GET THE LABOR UNITS
   IF G_LABOUR_UNITS IS NULL THEN
	 BEGIN
     	     SELECT REPORT_LABOR_UNITS
           INTO G_LABOUR_UNITS
           FROM PJI_SYSTEM_SETTINGS;
       EXCEPTION
           WHEN OTHERS THEN
             G_LABOUR_UNITS := NULL;
       END;
   END IF;


   SELECT PJI_REP_RA5(
            PERSON_NAME
           ,PERSON_ID
           ,NULL
           ,SUM(CAPACITY)
           ,SUM(CAPACITY_A)
           ,SUM(CONFIRMED)
           ,SUM(PROVISIONAL)
           ,SUM(UNASSIGNED)
           ,SUM(AVAILABLE)
           ,SUM(AVAILABLE_HOURS)
           ,SUM(AVAILABLE_DAYS)
           ,SUM(TOT_WTD_A)
           ,SUM(CONF_WTD_S)
           ,SUM(REDUCE_CAP_A)
           ,SUM(REDUCE_CAP_S)
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL)
   BULK COLLECT INTO L_AVL_RES_DET_TBL
   FROM ( /* Bug 3515594 */
         SELECT /*+ ORDERED */
              NULL                            PERSON_NAME
             ,FCT.PERSON_ID                   PERSON_ID
             ,CAPACITY_HRS / DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY, 'WEEKS',IMP.FTE_WEEK, 1)          CAPACITY
             ,0 CAPACITY_A
             ,CONF_HRS_S  / DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY, 'WEEKS',IMP.FTE_WEEK, 1)          CONFIRMED
             ,PROV_HRS_S  / DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY, 'WEEKS',IMP.FTE_WEEK, 1)          PROVISIONAL
             ,UNASSIGNED_HRS_S / DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY, 'WEEKS',IMP.FTE_WEEK, 1)      UNASSIGNED
             ,0			 TOT_WTD_A
             ,CONF_WTD_ORG_HRS_S / DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY, 'WEEKS',IMP.FTE_WEEK, 1)    CONF_WTD_S
             ,0          REDUCE_CAP_A
             ,REDUCE_CAPACITY_HRS_S / DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY, 'WEEKS',IMP.FTE_WEEK, 1) REDUCE_CAP_S
             ,0 AVAILABLE
	     ,DECODE(P_THRESHOLD,  1, DECODE(NVL(AVAILABLE_RES_COUNT_BKT1_S, 0),0,0,AVAILABLE_HRS_BKT1_S)
                                 , 2, DECODE(NVL(AVAILABLE_RES_COUNT_BKT2_S, 0),0,0,AVAILABLE_HRS_BKT2_S)
                                 , 3, DECODE(NVL(AVAILABLE_RES_COUNT_BKT3_S, 0),0,0,AVAILABLE_HRS_BKT3_S)
                                 , 4, DECODE(NVL(AVAILABLE_RES_COUNT_BKT4_S, 0),0,0,AVAILABLE_HRS_BKT4_S)
                                 , 5, DECODE(NVL(AVAILABLE_RES_COUNT_BKT5_S, 0),0,0,AVAILABLE_HRS_BKT5_S)
				 ,DECODE(NVL(AVAILABLE_RES_COUNT_BKT5_S, 0),0,0,AVAILABLE_HRS_BKT5_S)
                                  ) / DECODE(G_LABOUR_UNITS , 'DAYS', IMP.FTE_DAY
							    , 'WEEKS', IMP.FTE_WEEK
							    , 1) AVAILABLE_HOURS
             ,DECODE(P_THRESHOLD, 1, AVAILABLE_RES_COUNT_BKT1_S
                                , 2, AVAILABLE_RES_COUNT_BKT2_S
                                , 3, AVAILABLE_RES_COUNT_BKT3_S
                                , 4, AVAILABLE_RES_COUNT_BKT4_S
                                , 5, AVAILABLE_RES_COUNT_BKT5_S
				, AVAILABLE_RES_COUNT_BKT5_S
                     ) AVAILABLE_DAYS
         FROM PJI_PMV_ORGZ_DIM_TMP    HORG,
              PJI_PMV_TIME_DIM_TMP    TIME,
              PJI_RM_RES_F            FCT,
              PJI_PMV_ORG_DIM_TMP     HOU,
              PA_IMPLEMENTATIONS_ALL  IMP
         WHERE FCT.EXPENDITURE_ORG_ID  = HOU.ID
           AND FCT.EXPENDITURE_ORGANIZATION_ID = HORG.ID
           AND FCT.TIME_ID        = TIME.ID
           AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
           AND FCT.CALENDAR_TYPE  = TIME.CALENDAR_TYPE
           AND TIME.AMOUNT_TYPE   = 2
           AND HOU.ID             = IMP.ORG_ID
		 UNION ALL
		 /* Bug 3515594 */
         SELECT /*+ ORDERED */
              NULL                            PERSON_NAME
             ,FCT.PERSON_ID                   PERSON_ID
             ,0          CAPACITY
             ,CAPACITY_HRS / DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY, 'WEEKS',IMP.FTE_WEEK, 1)          CAPACITY_A
             ,0          CONFIRMED
             ,0          PROVISIONAL
             ,0			 UNASSIGNED
             ,TOTAL_WTD_ORG_HRS_A / DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY, 'WEEKS',IMP.FTE_WEEK, 1)   TOT_WTD_A
             ,0          CONF_WTD_S
             ,REDUCE_CAPACITY_HRS_A / DECODE(G_LABOUR_UNITS, 'DAYS', IMP.FTE_DAY, 'WEEKS',IMP.FTE_WEEK, 1) REDUCE_CAP_A
             ,0          REDUCE_CAP_S
             ,0          AVAILABLE
             ,0          AVAILABLE_HOURS
             ,0          AVAILABLE_DAYS
         FROM PJI_PMV_ORGZ_DIM_TMP    HORG,
              PJI_PMV_TIME_DIM_TMP    TIME,
              PJI_RM_RES_F            FCT,
              PJI_PMV_ORG_DIM_TMP     HOU,
              PA_IMPLEMENTATIONS_ALL  IMP
         WHERE FCT.EXPENDITURE_ORG_ID  = HOU.ID
           AND FCT.EXPENDITURE_ORGANIZATION_ID = HORG.ID
           AND FCT.TIME_ID        = TIME.ID
           AND FCT.PERIOD_TYPE_ID = TIME.PERIOD_TYPE
           AND FCT.CALENDAR_TYPE  = TIME.CALENDAR_TYPE
           AND TIME.AMOUNT_TYPE   = 1
           AND HOU.ID             = IMP.ORG_ID
         UNION ALL
         SELECT /*+ ORDERED */
              NULL                            PERSON_NAME
             ,FCT.PERSON_ID                   PERSON_ID
             ,0          CAPACITY
             ,0          CAPACITY_A
             ,0          CONFIRMED
             ,0          PROVISIONAL
             ,0			 UNASSIGNED
             ,0			 TOT_WTD_A
             ,0          CONF_WTD_S
             ,0          REDUCE_CAP_A
             ,0          REDUCE_CAP_S
             ,DECODE(P_THRESHOLD, 1, AVAILABLE_RES_COUNT_BKT1_S
                                , 2, AVAILABLE_RES_COUNT_BKT2_S
                                , 3, AVAILABLE_RES_COUNT_BKT3_S
                                , 4, AVAILABLE_RES_COUNT_BKT4_S
                                , 5, AVAILABLE_RES_COUNT_BKT5_S
				, AVAILABLE_RES_COUNT_BKT5_S
                     ) AVAILABLE

             ,0          AVAILABLE_HOURS
             ,0          AVAILABLE_DAYS
         FROM PJI_PMV_ORGZ_DIM_TMP    HORG,
              PJI_RM_RES_F            FCT,
              PJI_PMV_ORG_DIM_TMP     HOU
         WHERE FCT.EXPENDITURE_ORG_ID  = HOU.ID
           AND FCT.EXPENDITURE_ORGANIZATION_ID = HORG.ID
           AND FCT.TIME_ID        = P_AS_OF_DATE
           AND FCT.PERIOD_TYPE_ID = L_DAY_PERIOD_TYPE
           AND FCT.CALENDAR_TYPE  = L_DAY_CALENDAR_TYPE
   )
   GROUP BY PERSON_NAME, PERSON_ID
   HAVING SUM(AVAILABLE_DAYS) BETWEEN L_MIN_DAYS AND L_MAX_DAYS
   ORDER BY PERSON_ID;

   -- CHECK THAT AT LEAST ONE RECORD EXISTS IN THE COLLECTION
   -- BEFORE GOING INTO THE LOOP
   FOR I IN 1..L_AVL_RES_DET_TBL.COUNT LOOP

        -- GET PERSON_ID OF THE RECORD TO GET THE NAME
        -- FROM PA_RESOURCES_DENORM
        BEGIN
          SELECT RESOURCE_NAME
          INTO L_AVL_RES_DET_TBL(I).PERSON_NAME
          FROM PA_RESOURCES_DENORM
          WHERE PERSON_ID = L_AVL_RES_DET_TBL(I).PERSON_ID
          AND   ROWNUM=1;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
        -- NOTE TO VIJAY M.
        -- PLACE CALLS TO FOLLOWING API'S TO POPULATE THE COLUMNS
        -- (AVAILABLE_SINCE, CURR_LAST_PROJ, NEXT_PROJ, NEXT_ASGMT_DATE):
        -- PJI_PMV_UTIL.GET_AVAILABLE_FROM
        -- PJI_PMV_UTIL.GET_PROJECTS
        -- PJI_PMV_UTIL.GET_NEXT_ASGMT_DATE
        -- SINCE THE LOGIC FOR THE ABOVE API'S ARE BOUND TO CHANGE, THE
        -- CALLS TO ABOVE APIS ARE NOT BELOW.
        IF NVL((L_AVL_RES_DET_TBL(I).CAPACITY_A-L_AVL_RES_DET_TBL(I).REDUCE_CAP_A),0) <> 0 THEN
           L_AVL_RES_DET_TBL(I).ACT_UTIL_PER := (L_AVL_RES_DET_TBL(I).TOT_WTD_A/
                     ((L_AVL_RES_DET_TBL(I).CAPACITY_A-L_AVL_RES_DET_TBL(I).REDUCE_CAP_A))*100);
        ELSE
           L_AVL_RES_DET_TBL(I).ACT_UTIL_PER := NULL;
        END IF;

        IF NVL((L_AVL_RES_DET_TBL(I).CAPACITY-L_AVL_RES_DET_TBL(I).REDUCE_CAP_S),0) <> 0 THEN
           L_AVL_RES_DET_TBL(I).SCH_UTIL_PER := (L_AVL_RES_DET_TBL(I).CONF_WTD_S/
                     ((L_AVL_RES_DET_TBL(I).CAPACITY-L_AVL_RES_DET_TBL(I).REDUCE_CAP_S))*100);
        ELSE
           L_AVL_RES_DET_TBL(I).ACT_UTIL_PER := NULL;
        END IF;

        IF L_AVL_RES_DET_TBL(I).PERSON_ID IS NOT NULL THEN
           L_AVL_RES_DET_TBL(I).JOB_LEVEL := PJI_PMV_UTIL.GET_JOB_LEVEL( L_AVL_RES_DET_TBL(I).PERSON_ID, TO_DATE(P_AS_OF_DATE,'J'));
        ELSE
           L_AVL_RES_DET_TBL(I).JOB_LEVEL := NULL;
        END IF;
   END LOOP;
   IF L_AVL_RES_DET_TBL.COUNT > 0 THEN
        GET_AVAILABLE_SINCE_INFO(L_AVL_RES_DET_TBL, p_As_Of_Date, P_THRESHOLD);
        GET_CURRENT_LAST_PROJECT_INFO(L_AVL_RES_DET_TBL, p_As_Of_Date);
        GET_NEXT_ASSIGNMENT_INFO(L_AVL_RES_DET_TBL, p_As_Of_Date);
   END IF;
   COMMIT;
   RETURN L_AVL_RES_DET_TBL;

END PLSQLDRIVER_RA5;

PROCEDURE GET_PROJECT_INFO(P_PERSON_ID NUMBER, P_TIME_ID IN NUMBER, X_PROJECTS_NAME OUT NOCOPY  VARCHAR2, X_BILLABLE_FLAG OUT VARCHAR2)
AS
l_Project_List	VARCHAR2(300);
l_Time_ID		NUMBER:=P_TIME_ID;
l_Period_Type_ID	NUMBER:=1;
l_Calendar_Type	VARCHAR2(1):='C';
l_Record_Type	VARCHAR2(1):='A';
BEGIN
	FOR cur_Projects_List IN (SELECT DISTINCT prj.name name
					FROM pji_rm_res_wt_f fct
					,pa_projects_all prj
					WHERE
					prj.project_id = fct.project_id
					AND fct.person_id = p_Person_ID
					AND fct.time_id = l_Time_ID
					AND fct.period_type_id = l_Period_Type_ID
					AND fct.calendar_type = l_Calendar_Type
					AND fct.record_type = l_Record_Type)
	LOOP
		IF NVL(LENGTH(l_Project_List), 0) < 240 THEN
			IF l_Project_List IS NULL THEN
				l_Project_List := cur_Projects_List.name;
			ELSE
				l_Project_List := l_Project_List||','||cur_Projects_List.name;
			END IF;
		END IF;
	END LOOP;
	X_PROJECTS_NAME := SUBSTR(l_Project_List, 1, 240);
END GET_PROJECT_INFO;

PROCEDURE GET_AVAILABLE_SINCE_INFO(P_AVL_RES_DET_TBL IN OUT NOCOPY  PJI_REP_RA5_TBL, P_AS_OF_DATE NUMBER, P_THRESHOLD NUMBER)
AS
l_As_Of_Date		DATE:=TO_DATE(p_As_Of_Date, 'j');
l_Week_Calendar_Type	VARCHAR2(1):='E';
l_Day_Calendar_Type	VARCHAR2(1):='C';
l_Week_Period_Type_ID	NUMBER:=16;
l_Day_Period_Type_ID	NUMBER:=1;
l_Num_of_Weeks		NUMBER:=15;
l_Max_Num_of_Weeks	NUMBER:=52;

l_From_Time_ID		NUMBER;
l_To_Time_ID		NUMBER;
l_Start_Date		DATE;
l_Start_Week_ID		NUMBER;
l_Threshold			NUMBER:=P_THRESHOLD;
l_Available_Week		NUMBER;
l_Available_Since		NUMBER;

l_Project_Date		NUMBER;
l_Billable_Flag		VARCHAR2(1);
BEGIN
	/* For Current Date */
	SELECT week_id
	, start_date
	INTO l_Start_Week_ID
	,l_Start_date
	FROM
	fii_time_week
	WHERE
	l_As_Of_Date BETWEEN start_date AND end_date;

--  If threshold is null - that means that we have to pass the id for the maximum percentage value
--  from the PJI setup
--  Following snippet added because of bug4001112

   IF P_THRESHOLD is null then
      SELECT  distinct
       first_value(ID) over (ORDER BY VALUE DESC) into l_Threshold
       FROM PJI_AVL_THRESHOLDS_V;
   END IF;
-- end of snippet (bug4001112)

	FOR i IN 1..P_AVL_RES_DET_TBL.LAST
	LOOP

		l_From_Time_ID:=TO_CHAR(l_As_Of_Date,'j');
		l_To_Time_ID:=TO_CHAR(l_Start_date,'j');

		l_Available_Week:=NULL;
		l_Available_Since:=NULL;

		CASE (l_Threshold)
		WHEN 1 THEN
			SELECT TO_CHAR(TO_DATE(MAX(TIME_ID),'j'),'RRRR/MM/DD')
			INTO P_AVL_RES_DET_TBL(i).available_since
			FROM pji_rm_res_f
			WHERE 1=1
			AND person_id = P_AVL_RES_DET_TBL(i).person_id
			AND time_id BETWEEN l_To_Time_ID AND l_From_Time_ID
			AND calendar_type = l_Day_Calendar_Type
			AND period_type_id = l_Day_Period_Type_ID
			AND total_res_count <> available_res_count_bkt1_s
			AND capacity_hrs <> 0;
		WHEN 2 THEN
			SELECT TO_CHAR(TO_DATE(MAX(TIME_ID),'j'),'RRRR/MM/DD')
			INTO P_AVL_RES_DET_TBL(i).available_since
			FROM pji_rm_res_f
			WHERE 1=1
			AND person_id = P_AVL_RES_DET_TBL(i).person_id
			AND time_id BETWEEN l_To_Time_ID AND l_From_Time_ID
			AND calendar_type = l_Day_Calendar_Type
			AND period_type_id = l_Day_Period_Type_ID
			AND total_res_count <> available_res_count_bkt2_s
			AND capacity_hrs <> 0;
		WHEN 3 THEN
			SELECT TO_CHAR(TO_DATE(MAX(TIME_ID),'j'),'RRRR/MM/DD')
			INTO P_AVL_RES_DET_TBL(i).available_since
			FROM pji_rm_res_f
			WHERE 1=1
			AND person_id = P_AVL_RES_DET_TBL(i).person_id
			AND time_id BETWEEN l_To_Time_ID AND l_From_Time_ID
			AND calendar_type = l_Day_Calendar_Type
			AND period_type_id = l_Day_Period_Type_ID
			AND total_res_count <> available_res_count_bkt3_s
			AND capacity_hrs <> 0;
		WHEN 4 THEN
			SELECT TO_CHAR(TO_DATE(MAX(TIME_ID),'j'),'RRRR/MM/DD')
			INTO P_AVL_RES_DET_TBL(i).available_since
			FROM pji_rm_res_f
			WHERE 1=1
			AND person_id = P_AVL_RES_DET_TBL(i).person_id
			AND time_id BETWEEN l_To_Time_ID AND l_From_Time_ID
			AND calendar_type = l_Day_Calendar_Type
			AND period_type_id = l_Day_Period_Type_ID
			AND total_res_count <> available_res_count_bkt4_s
			AND capacity_hrs <> 0;
		WHEN 5 THEN
			SELECT TO_CHAR(TO_DATE(MAX(TIME_ID),'j'),'RRRR/MM/DD')
			INTO P_AVL_RES_DET_TBL(i).available_since
			FROM pji_rm_res_f
			WHERE 1=1
			AND person_id = P_AVL_RES_DET_TBL(i).person_id
			AND time_id BETWEEN l_To_Time_ID AND l_From_Time_ID
			AND calendar_type = l_Day_Calendar_Type
			AND period_type_id = l_Day_Period_Type_ID
			AND total_res_count <> available_res_count_bkt5_s
			AND capacity_hrs <> 0;

		ELSE
			NULL;
		END CASE;

		IF P_AVL_RES_DET_TBL(i).available_since IS NULL THEN

			CASE (l_Threshold)
			WHEN 1 THEN
				SELECT MAX(TIME_ID)
				INTO l_Available_Week
				FROM pji_rm_res_f fct
				, fii_time_week time
				WHERE 1=1
				AND time.start_date>=l_Start_Date-(7*l_Num_of_Weeks)
				AND time.end_date<=l_Start_Date
				AND fct.time_id = time.week_id
				AND fct.person_id = P_AVL_RES_DET_TBL(i).person_id
				AND fct.calendar_type = l_Week_Calendar_Type
				AND fct.period_type_id = l_Week_Period_Type_ID
				AND fct.total_res_count <> fct.available_res_count_bkt1_s
				AND fct.capacity_hrs <> 0;
			WHEN 2 THEN
				SELECT MAX(TIME_ID)
				INTO l_Available_Week
				FROM pji_rm_res_f fct
				, fii_time_week time
				WHERE 1=1
				AND time.start_date>=l_Start_Date-(7*l_Num_of_Weeks)
				AND time.end_date<=l_Start_Date
				AND fct.time_id = time.week_id
				AND fct.person_id = P_AVL_RES_DET_TBL(i).person_id
				AND fct.calendar_type = l_Week_Calendar_Type
				AND fct.period_type_id = l_Week_Period_Type_ID
				AND fct.total_res_count <> fct.available_res_count_bkt2_s
				AND fct.capacity_hrs <> 0;
			WHEN 3 THEN
				SELECT MAX(TIME_ID)
				INTO l_Available_Week
				FROM pji_rm_res_f fct
				, fii_time_week time
				WHERE 1=1
				AND time.start_date>=l_Start_Date-(7*l_Num_of_Weeks)
				AND time.end_date<=l_Start_Date
				AND fct.time_id = time.week_id
				AND fct.person_id = P_AVL_RES_DET_TBL(i).person_id
				AND fct.calendar_type = l_Week_Calendar_Type
				AND fct.period_type_id = l_Week_Period_Type_ID
				AND fct.total_res_count <> fct.available_res_count_bkt3_s
				AND fct.capacity_hrs <> 0;
			WHEN 4 THEN
				SELECT MAX(TIME_ID)
				INTO l_Available_Week
				FROM pji_rm_res_f fct
				, fii_time_week time
				WHERE 1=1
				AND time.start_date>=l_Start_Date-(7*l_Num_of_Weeks)
				AND time.end_date<=l_Start_Date
				AND fct.time_id = time.week_id
				AND fct.person_id = P_AVL_RES_DET_TBL(i).person_id
				AND fct.calendar_type = l_Week_Calendar_Type
				AND fct.period_type_id = l_Week_Period_Type_ID
				AND fct.total_res_count <> fct.available_res_count_bkt4_s
				AND fct.capacity_hrs <> 0;
			WHEN 5 THEN
				SELECT MAX(TIME_ID)
				INTO l_Available_Week
				FROM pji_rm_res_f fct
				, fii_time_week time
				WHERE 1=1
				AND time.start_date>=l_Start_Date-(7*l_Num_of_Weeks)
				AND time.end_date<=l_Start_Date
				AND fct.time_id = time.week_id
				AND fct.person_id = P_AVL_RES_DET_TBL(i).person_id
				AND fct.calendar_type = l_Week_Calendar_Type
				AND fct.period_type_id = l_Week_Period_Type_ID
				AND fct.total_res_count <> fct.available_res_count_bkt5_s
				AND fct.capacity_hrs <> 0;
			ELSE
				NULL;
			END CASE;

			IF l_Available_Week IS NULL THEN
				CASE (l_Threshold)
				WHEN 1 THEN
					SELECT MAX(TIME_ID)
					INTO l_Available_Week
					FROM pji_rm_res_f fct
					, fii_time_week time
					WHERE 1=1
					AND time.start_date>=l_Start_Date-(7*l_Max_Num_of_Weeks)
					AND time.end_date<=l_Start_Date-(7*l_Num_of_Weeks)
					AND fct.time_id = time.week_id
					AND fct.person_id = P_AVL_RES_DET_TBL(i).person_id
					AND fct.calendar_type = l_Week_Calendar_Type
					AND fct.period_type_id = l_Week_Period_Type_ID
					AND fct.total_res_count <> fct.available_res_count_bkt1_s
					AND fct.capacity_hrs <> 0;
				WHEN 2 THEN
					SELECT MAX(TIME_ID)
					INTO l_Available_Week
					FROM pji_rm_res_f fct
					, fii_time_week time
					WHERE 1=1
					AND time.start_date>=l_Start_Date-(7*l_Max_Num_of_Weeks)
					AND time.end_date<=l_Start_Date-(7*l_Num_of_Weeks)
					AND fct.time_id = time.week_id
					AND fct.person_id = P_AVL_RES_DET_TBL(i).person_id
					AND fct.calendar_type = l_Week_Calendar_Type
					AND fct.period_type_id = l_Week_Period_Type_ID
					AND fct.total_res_count <> fct.available_res_count_bkt2_s
					AND fct.capacity_hrs <> 0;
				WHEN 3 THEN
					SELECT MAX(TIME_ID)
					INTO l_Available_Week
					FROM pji_rm_res_f fct
					, fii_time_week time
					WHERE 1=1
					AND time.start_date>=l_Start_Date-(7*l_Max_Num_of_Weeks)
					AND time.end_date<=l_Start_Date-(7*l_Num_of_Weeks)
					AND fct.time_id = time.week_id
					AND fct.person_id = P_AVL_RES_DET_TBL(i).person_id
					AND fct.calendar_type = l_Week_Calendar_Type
					AND fct.period_type_id = l_Week_Period_Type_ID
					AND fct.total_res_count <> fct.available_res_count_bkt3_s
					AND fct.capacity_hrs <> 0;
				WHEN 4 THEN
					SELECT MAX(TIME_ID)
					INTO l_Available_Week
					FROM pji_rm_res_f fct
					, fii_time_week time
					WHERE 1=1
					AND time.start_date>=l_Start_Date-(7*l_Max_Num_of_Weeks)
					AND time.end_date<=l_Start_Date-(7*l_Num_of_Weeks)
					AND fct.time_id = time.week_id
					AND fct.person_id = P_AVL_RES_DET_TBL(i).person_id
					AND fct.calendar_type = l_Week_Calendar_Type
					AND fct.period_type_id = l_Week_Period_Type_ID
					AND fct.total_res_count <> fct.available_res_count_bkt4_s
					AND fct.capacity_hrs <> 0;
				WHEN 5 THEN
					SELECT MAX(TIME_ID)
					INTO l_Available_Week
					FROM pji_rm_res_f fct
					, fii_time_week time
					WHERE 1=1
					AND time.start_date>=l_Start_Date-(7*l_Max_Num_of_Weeks)
					AND time.end_date<=l_Start_Date-(7*l_Num_of_Weeks)
					AND fct.time_id = time.week_id
					AND fct.person_id = P_AVL_RES_DET_TBL(i).person_id
					AND fct.calendar_type = l_Week_Calendar_Type
					AND fct.period_type_id = l_Week_Period_Type_ID
					AND fct.total_res_count <> fct.available_res_count_bkt5_s
					AND fct.capacity_hrs <> 0;
				ELSE
					NULL;
				END CASE;
			END IF;

			IF l_Available_Week IS NOT NULL THEN
				SELECT TO_CHAR(start_date, 'j')
				, TO_CHAR(end_date, 'j')
				INTO
				l_To_Time_ID
				, l_From_Time_ID
				FROM FII_TIME_WEEK
				WHERE week_id = l_Available_Week;

				CASE (l_Threshold)
				WHEN 1 THEN
					SELECT TO_CHAR(TO_DATE(MAX(TIME_ID),'j'),'RRRR/MM/DD')
					INTO P_AVL_RES_DET_TBL(i).available_since
					FROM pji_rm_res_f
					WHERE 1=1
					AND person_id = P_AVL_RES_DET_TBL(i).person_id
					AND time_id BETWEEN l_To_Time_ID AND l_From_Time_ID
					AND calendar_type = l_Day_Calendar_Type
					AND period_type_id = l_Day_Period_Type_ID
					AND total_res_count <> available_res_count_bkt1_s
					AND capacity_hrs <> 0;
				WHEN 2 THEN
					SELECT TO_CHAR(TO_DATE(MAX(TIME_ID),'j'),'RRRR/MM/DD')
					INTO P_AVL_RES_DET_TBL(i).available_since
					FROM pji_rm_res_f
					WHERE 1=1
					AND person_id = P_AVL_RES_DET_TBL(i).person_id
					AND time_id BETWEEN l_To_Time_ID AND l_From_Time_ID
					AND calendar_type = l_Day_Calendar_Type
					AND period_type_id = l_Day_Period_Type_ID
					AND total_res_count <> available_res_count_bkt2_s
					AND capacity_hrs <> 0;
				WHEN 3 THEN
					SELECT TO_CHAR(TO_DATE(MAX(TIME_ID),'j'),'RRRR/MM/DD')
					INTO P_AVL_RES_DET_TBL(i).available_since
					FROM pji_rm_res_f
					WHERE 1=1
					AND person_id = P_AVL_RES_DET_TBL(i).person_id
					AND time_id BETWEEN l_To_Time_ID AND l_From_Time_ID
					AND calendar_type = l_Day_Calendar_Type
					AND period_type_id = l_Day_Period_Type_ID
					AND total_res_count <> available_res_count_bkt3_s
					AND capacity_hrs <> 0;
				WHEN 4 THEN
					SELECT TO_CHAR(TO_DATE(MAX(TIME_ID),'j'),'RRRR/MM/DD')
					INTO P_AVL_RES_DET_TBL(i).available_since
					FROM pji_rm_res_f
					WHERE 1=1
					AND person_id = P_AVL_RES_DET_TBL(i).person_id
					AND time_id BETWEEN l_To_Time_ID AND l_From_Time_ID
					AND calendar_type = l_Day_Calendar_Type
					AND period_type_id = l_Day_Period_Type_ID
					AND total_res_count <> available_res_count_bkt4_s
					AND capacity_hrs <> 0;
				WHEN 5 THEN
					SELECT TO_CHAR(TO_DATE(MAX(TIME_ID),'j'),'RRRR/MM/DD')
					INTO P_AVL_RES_DET_TBL(i).available_since
					FROM pji_rm_res_f
					WHERE 1=1
					AND person_id = P_AVL_RES_DET_TBL(i).person_id
					AND time_id BETWEEN l_To_Time_ID AND l_From_Time_ID
					AND calendar_type = l_Day_Calendar_Type
					AND period_type_id = l_Day_Period_Type_ID
					AND total_res_count <> available_res_count_bkt5_s
					AND capacity_hrs <> 0;
				ELSE
					NULL;
				END CASE;

			ELSE
				NULL;
			END IF;
		ELSE
			NULL;
		END IF;

		IF P_AVL_RES_DET_TBL(i).available_since IS NOT NULL THEN
			l_From_Time_ID:=LEAST(TO_CHAR(TO_DATE(P_AVL_RES_DET_TBL(i).available_since,'RRRR/MM/DD')+7, 'j'),TO_CHAR(l_As_Of_Date, 'j'));
			l_To_Time_ID:=TO_CHAR(TO_DATE(P_AVL_RES_DET_TBL(i).available_since,'RRRR/MM/DD'), 'j');
			l_Available_Since:=l_To_Time_ID;
			CASE (l_Threshold)
			WHEN 1 THEN
				SELECT TO_CHAR(TO_DATE(MIN(TIME_ID),'j'),'RRRR/MM/DD')
				INTO P_AVL_RES_DET_TBL(i).available_since
				FROM pji_rm_res_f
				WHERE 1=1
				AND person_id = P_AVL_RES_DET_TBL(i).person_id
				AND time_id BETWEEN l_To_Time_ID AND l_From_Time_ID
				AND calendar_type = l_Day_Calendar_Type
				AND period_type_id = l_Day_Period_Type_ID
				AND total_res_count = available_res_count_bkt1_s
				AND capacity_hrs <> 0;
			WHEN 2 THEN
				SELECT TO_CHAR(TO_DATE(MIN(TIME_ID),'j'),'RRRR/MM/DD')
				INTO P_AVL_RES_DET_TBL(i).available_since
				FROM pji_rm_res_f
				WHERE 1=1
				AND person_id = P_AVL_RES_DET_TBL(i).person_id
				AND time_id BETWEEN l_To_Time_ID AND l_From_Time_ID
				AND calendar_type = l_Day_Calendar_Type
				AND period_type_id = l_Day_Period_Type_ID
				AND total_res_count = available_res_count_bkt2_s
				AND capacity_hrs <> 0;
			WHEN 3 THEN
				SELECT TO_CHAR(TO_DATE(MIN(TIME_ID),'j'),'RRRR/MM/DD')
				INTO P_AVL_RES_DET_TBL(i).available_since
				FROM pji_rm_res_f
				WHERE 1=1
				AND person_id = P_AVL_RES_DET_TBL(i).person_id
				AND time_id BETWEEN l_To_Time_ID AND l_From_Time_ID
				AND calendar_type = l_Day_Calendar_Type
				AND period_type_id = l_Day_Period_Type_ID
				AND total_res_count = available_res_count_bkt3_s
				AND capacity_hrs <> 0;
			WHEN 4 THEN
				SELECT TO_CHAR(TO_DATE(MIN(TIME_ID),'j'),'RRRR/MM/DD')
				INTO P_AVL_RES_DET_TBL(i).available_since
				FROM pji_rm_res_f
				WHERE 1=1
				AND person_id = P_AVL_RES_DET_TBL(i).person_id
				AND time_id BETWEEN l_To_Time_ID AND l_From_Time_ID
				AND calendar_type = l_Day_Calendar_Type
				AND period_type_id = l_Day_Period_Type_ID
				AND total_res_count = available_res_count_bkt4_s
				AND capacity_hrs <> 0;
			WHEN 5 THEN
				SELECT TO_CHAR(TO_DATE(MIN(TIME_ID),'j'),'RRRR/MM/DD')
				INTO P_AVL_RES_DET_TBL(i).available_since
				FROM pji_rm_res_f
				WHERE 1=1
				AND person_id = P_AVL_RES_DET_TBL(i).person_id
				AND time_id BETWEEN l_To_Time_ID AND l_From_Time_ID
				AND calendar_type = l_Day_Calendar_Type
				AND period_type_id = l_Day_Period_Type_ID
				AND total_res_count = available_res_count_bkt5_s
				AND capacity_hrs <> 0;
			ELSE
				NULL;
			END CASE;
			IF P_AVL_RES_DET_TBL(i).available_since IS NOT NULL THEN
				l_From_Time_ID:=TO_CHAR(l_As_Of_Date, 'j');
				l_To_Time_ID:=TO_CHAR(TO_DATE(P_AVL_RES_DET_TBL(i).available_since,'RRRR/MM/DD'), 'j');

				CASE (l_Threshold)
				WHEN 1 THEN
					SELECT TO_CHAR(TO_DATE(MIN(TIME_ID),'j'),'RRRR/MM/DD')
					INTO P_AVL_RES_DET_TBL(i).available_since
					FROM pji_rm_res_f
					WHERE 1=1
					AND person_id = P_AVL_RES_DET_TBL(i).person_id
					AND time_id BETWEEN l_To_Time_ID AND l_From_Time_ID
					AND calendar_type = l_Day_Calendar_Type
					AND period_type_id = l_Day_Period_Type_ID
					AND total_res_count = available_res_count_bkt1_s
					AND capacity_hrs <> 0;
				WHEN 2 THEN
					SELECT TO_CHAR(TO_DATE(MIN(TIME_ID),'j'),'RRRR/MM/DD')
					INTO P_AVL_RES_DET_TBL(i).available_since
					FROM pji_rm_res_f
					WHERE 1=1
					AND person_id = P_AVL_RES_DET_TBL(i).person_id
					AND time_id BETWEEN l_To_Time_ID AND l_From_Time_ID
					AND calendar_type = l_Day_Calendar_Type
					AND period_type_id = l_Day_Period_Type_ID
					AND total_res_count = available_res_count_bkt2_s
					AND capacity_hrs <> 0;
				WHEN 3 THEN
					SELECT TO_CHAR(TO_DATE(MIN(TIME_ID),'j'),'RRRR/MM/DD')
					INTO P_AVL_RES_DET_TBL(i).available_since
					FROM pji_rm_res_f
					WHERE 1=1
					AND person_id = P_AVL_RES_DET_TBL(i).person_id
					AND time_id BETWEEN l_To_Time_ID AND l_From_Time_ID
					AND calendar_type = l_Day_Calendar_Type
					AND period_type_id = l_Day_Period_Type_ID
					AND total_res_count = available_res_count_bkt3_s
					AND capacity_hrs <> 0;
				WHEN 4 THEN
					SELECT TO_CHAR(TO_DATE(MIN(TIME_ID),'j'),'RRRR/MM/DD')
					INTO P_AVL_RES_DET_TBL(i).available_since
					FROM pji_rm_res_f
					WHERE 1=1
					AND person_id = P_AVL_RES_DET_TBL(i).person_id
					AND time_id BETWEEN l_To_Time_ID AND l_From_Time_ID
					AND calendar_type = l_Day_Calendar_Type
					AND period_type_id = l_Day_Period_Type_ID
					AND total_res_count = available_res_count_bkt4_s
					AND capacity_hrs <> 0;
				WHEN 5 THEN
					SELECT TO_CHAR(TO_DATE(MIN(TIME_ID),'j'),'RRRR/MM/DD')
					INTO P_AVL_RES_DET_TBL(i).available_since
					FROM pji_rm_res_f
					WHERE 1=1
					AND person_id = P_AVL_RES_DET_TBL(i).person_id
					AND time_id BETWEEN l_To_Time_ID AND l_From_Time_ID
					AND calendar_type = l_Day_Calendar_Type
					AND period_type_id = l_Day_Period_Type_ID
					AND total_res_count = available_res_count_bkt5_s
					AND capacity_hrs <> 0;
				ELSE
					NULL;
				END CASE;
			END IF;
		END IF;
	END LOOP;
END GET_AVAILABLE_SINCE_INFO;

PROCEDURE GET_CURRENT_LAST_PROJECT_INFO(P_AVL_RES_DET_TBL IN OUT NOCOPY  PJI_REP_RA5_TBL, P_AS_OF_DATE NUMBER)
AS
l_As_Of_Date		DATE:=TO_DATE(p_As_Of_Date, 'j');
l_Week_Calendar_Type	VARCHAR2(1):='E';
l_Day_Calendar_Type	VARCHAR2(1):='C';
l_Week_Period_Type_ID	NUMBER:=16;
l_Day_Period_Type_ID	NUMBER:=1;
l_Num_of_Weeks		NUMBER:=15;
l_Max_Num_of_Weeks	NUMBER:=52;

l_From_Time_ID		NUMBER;
l_To_Time_ID		NUMBER;
l_Start_Date		DATE;
l_Start_Week_ID		NUMBER;
l_Available_Week		NUMBER;
l_Available_Date		DATE;

l_Project_Date		NUMBER;
l_Billable_Flag		VARCHAR2(1);
BEGIN
	/* For Current Date */
	SELECT week_id
	, start_date
	INTO l_Start_Week_ID
	,l_Start_date
	FROM
	fii_time_week
	WHERE
	l_As_Of_Date BETWEEN start_date AND end_date;

	FOR i IN 1..P_AVL_RES_DET_TBL.LAST
	LOOP
		l_Available_Week:=NULL;
		l_Available_Date:=NULL;

		IF NVL(P_AVL_RES_DET_TBL(i).AVAILABLE, 0) = 1 THEN

			l_From_Time_ID:=TO_CHAR(l_As_Of_Date,'j');
			l_To_Time_ID:=TO_CHAR(l_Start_date,'j');

			SELECT TO_DATE(MAX(TIME_ID),'j')
			INTO l_Available_Date
			FROM pji_rm_res_f
			WHERE 1=1
			AND person_id = P_AVL_RES_DET_TBL(i).person_id
			AND time_id BETWEEN l_To_Time_ID AND l_From_Time_ID
			AND calendar_type = l_Day_Calendar_Type
			AND period_type_id = l_Day_Period_Type_ID
			AND capacity_hrs<>available_hrs_bkt1_s
			AND capacity_hrs <> 0;

			IF l_Available_Date IS NULL THEN
				SELECT MAX(TIME_ID)
				INTO l_Available_Week
				FROM pji_rm_res_f fct
				, fii_time_week time
				WHERE 1=1
				AND time.start_date>=l_Start_Date-(7*l_Num_of_Weeks)
				AND time.end_date<=l_Start_Date
				AND fct.time_id = time.week_id
				AND fct.person_id = P_AVL_RES_DET_TBL(i).person_id
				AND fct.calendar_type = l_Week_Calendar_Type
				AND fct.period_type_id = l_Week_Period_Type_ID
				AND fct.capacity_hrs <> fct.available_hrs_bkt1_s
				AND fct.capacity_hrs <> 0;

				IF l_Available_Week IS NULL THEN
					SELECT MAX(TIME_ID)
					INTO l_Available_Week
					FROM pji_rm_res_f fct
					, fii_time_week time
					WHERE 1=1
					AND time.start_date>=l_Start_Date-(7*l_Max_Num_of_Weeks)
					AND time.end_date<=l_Start_Date-(7*l_Num_of_Weeks)
					AND fct.time_id = time.week_id
					AND fct.person_id = P_AVL_RES_DET_TBL(i).person_id
					AND fct.calendar_type = l_Week_Calendar_Type
					AND fct.period_type_id = l_Week_Period_Type_ID
					AND fct.capacity_hrs <> fct.available_hrs_bkt1_s
					AND fct.capacity_hrs <> 0;
				END IF;

				IF l_Available_Week IS NOT NULL THEN
					SELECT TO_CHAR(start_date, 'j')
					, TO_CHAR(end_date, 'j')
					INTO
					l_To_Time_ID
					, l_From_Time_ID
					FROM FII_TIME_WEEK
					WHERE week_id = l_Available_Week;

					SELECT TO_DATE(MAX(TIME_ID),'j')
					INTO l_Available_Date
					FROM pji_rm_res_f
					WHERE 1=1
					AND person_id = P_AVL_RES_DET_TBL(i).person_id
					AND time_id BETWEEN l_To_Time_ID AND l_From_Time_ID
					AND calendar_type = l_Day_Calendar_Type
					AND period_type_id = l_Day_Period_Type_ID
					AND capacity_hrs <> available_hrs_bkt1_s
					AND capacity_hrs <> 0;
				END IF;
			END IF;
		END IF;
		IF l_Available_Date IS NOT NULL OR NVL(P_AVL_RES_DET_TBL(i).AVAILABLE, 0) = 0 THEN
			IF l_Available_Date IS NOT NULL THEN
				l_Project_Date:=TO_CHAR(l_Available_Date, 'j');
			ELSE
				l_Project_Date:=TO_CHAR(l_As_Of_Date, 'j');
			END IF;
			GET_PROJECT_INFO(P_AVL_RES_DET_TBL(i).person_id
						, l_Project_Date
						, P_AVL_RES_DET_TBL(i).curr_last_proj
						, l_Billable_Flag);
		END IF;
	END LOOP;
END GET_CURRENT_LAST_PROJECT_INFO;

PROCEDURE GET_NEXT_ASSIGNMENT_INFO(P_AVL_RES_DET_TBL IN OUT NOCOPY  PJI_REP_RA5_TBL, P_AS_OF_DATE NUMBER)
AS
l_As_Of_Date		DATE:=TO_DATE(p_As_Of_Date, 'j');
l_Week_Calendar_Type	VARCHAR2(1):='E';
l_Day_Calendar_Type	VARCHAR2(1):='C';
l_Week_Period_Type_ID	NUMBER:=16;
l_Day_Period_Type_ID	NUMBER:=1;
l_Num_of_Weeks		NUMBER:=15;
l_Max_Num_of_Weeks	NUMBER:=52;

l_From_Time_ID		NUMBER;
l_To_Time_ID		NUMBER;
l_End_Date			DATE;
l_End_Week_ID		NUMBER;
l_Available_Week		NUMBER;

l_Billable_Flag		VARCHAR2(1);
BEGIN
	/* For Current Date */
	SELECT week_id
	, end_date
	INTO l_End_Week_ID
	,l_End_date
	FROM
	fii_time_week
	WHERE
	l_As_Of_Date BETWEEN start_date AND end_date;

	FOR i IN 1..P_AVL_RES_DET_TBL.LAST
	LOOP
		l_Available_Week:=NULL;

		IF NVL(P_AVL_RES_DET_TBL(i).AVAILABLE, 1) = 1 THEN

			l_From_Time_ID:=TO_CHAR(l_As_Of_Date,'j');
			l_To_Time_ID:=TO_CHAR(l_End_date,'j');

			SELECT TO_CHAR(TO_DATE(MIN(TIME_ID),'j'),'RRRR/MM/DD')
			INTO P_AVL_RES_DET_TBL(i).next_asgmt_date
			FROM pji_rm_res_f
			WHERE 1=1
			AND person_id = P_AVL_RES_DET_TBL(i).person_id
			AND time_id BETWEEN l_From_Time_ID AND l_To_Time_ID
			AND calendar_type = l_Day_Calendar_Type
			AND period_type_id = l_Day_Period_Type_ID
			AND capacity_hrs<>available_hrs_bkt1_s
			AND capacity_hrs <> 0;

			IF P_AVL_RES_DET_TBL(i).next_asgmt_date IS NULL THEN
				SELECT MIN(TIME_ID)
				INTO l_Available_Week
				FROM pji_rm_res_f fct
				, fii_time_week time
				WHERE 1=1
				AND time.start_date>=l_End_Date
				AND time.end_date<=l_End_Date+(7*l_Num_of_Weeks)
				AND fct.time_id = time.week_id
				AND fct.person_id = P_AVL_RES_DET_TBL(i).person_id
				AND fct.calendar_type = l_Week_Calendar_Type
				AND fct.period_type_id = l_Week_Period_Type_ID
				AND fct.capacity_hrs <> fct.available_hrs_bkt1_s
				AND fct.capacity_hrs <> 0;

				IF l_Available_Week IS NULL THEN
					SELECT MIN(TIME_ID)
					INTO l_Available_Week
					FROM pji_rm_res_f fct
					, fii_time_week time
					WHERE 1=1
					AND time.start_date>=l_End_Date+(7*l_Num_of_Weeks)
					AND time.end_date<=l_End_Date+(7*l_Max_Num_of_Weeks)
					AND fct.time_id = time.week_id
					AND fct.person_id = P_AVL_RES_DET_TBL(i).person_id
					AND fct.calendar_type = l_Week_Calendar_Type
					AND fct.period_type_id = l_Week_Period_Type_ID
					AND fct.capacity_hrs <> fct.available_hrs_bkt1_s
					AND fct.capacity_hrs <> 0;
				END IF;

				IF l_Available_Week IS NOT NULL THEN
					SELECT TO_CHAR(start_date, 'j')
					, TO_CHAR(end_date, 'j')
					INTO
					l_To_Time_ID
					, l_From_Time_ID
					FROM FII_TIME_WEEK
					WHERE week_id = l_Available_Week;

					SELECT TO_CHAR(TO_DATE(MIN(TIME_ID),'j'),'RRRR/MM/DD')
					INTO P_AVL_RES_DET_TBL(i).next_asgmt_date
					FROM pji_rm_res_f
					WHERE 1=1
					AND person_id = P_AVL_RES_DET_TBL(i).person_id
					AND time_id BETWEEN l_To_Time_ID AND l_From_Time_ID
					AND calendar_type = l_Day_Calendar_Type
					AND period_type_id = l_Day_Period_Type_ID
					AND capacity_hrs <> available_hrs_bkt1_s
					AND capacity_hrs <> 0;
				END IF;
			END IF;
		END IF;
		IF P_AVL_RES_DET_TBL(i).next_asgmt_date IS NOT NULL THEN
			GET_PROJECT_INFO(P_AVL_RES_DET_TBL(i).person_id
						, TO_CHAR(TO_DATE(P_AVL_RES_DET_TBL(i).next_asgmt_date,'RRRR/MM/DD'), 'j')
						, P_AVL_RES_DET_TBL(i).next_proj
						, l_Billable_Flag);
		END IF;
	END LOOP;
END GET_NEXT_ASSIGNMENT_INFO;

END PJI_PMV_AVL;


/
