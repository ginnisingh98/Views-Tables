--------------------------------------------------------
--  DDL for Package Body PJI_FM_PLAN_CAL_RLPS_T
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_FM_PLAN_CAL_RLPS_T" AS
/* $Header: PJIPP05B.pls 120.9.12010000.2 2009/10/30 12:25:06 arbandyo ship $ */


g_package_name      VARCHAR2(100) := 'PJI_FM_PLAN_CAL_RLPS_T';

g_worker_id         NUMBER        := 1; -- PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;
g_default_prg_level NUMBER        := 0;

PROCEDURE PRINT_TIME(p_tag IN VARCHAR2);



PROCEDURE CREATE_FP_PA_ROLLUP IS -- Public
BEGIN
  CREATE_FP_PA_PRI_ROLLUP ;
EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CREATE_FP_PA_ROLLUP');
    RAISE;
END;


PROCEDURE CREATE_FP_GL_ROLLUP IS -- Public
BEGIN
  CREATE_FP_GL_PRI_ROLLUP ;
EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CREATE_FP_GL_ROLLUP');
    RAISE;
END;

PROCEDURE CREATE_FP_NONTP_ROLLUP IS -- Public. Not needed.
BEGIN
  NULL;
EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CREATE_FP_NONTP_ROLLUP');
    RAISE;
END;


PROCEDURE CREATE_FP_ENT_ROLLUP IS -- Public
BEGIN

  -- g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;

  INSERT INTO PJI_FP_AGGR_PJP1_T
  (
       WORKER_ID
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , LINE_TYPE
     , PRG_LEVEL
     , PLAN_TYPE_CODE   /* 4471527 */
  )
  SELECT * FROM (
  SELECT
      g_worker_id
    , fact1.PROJECT_ID
    , fact1.PROJECT_ORG_ID
    , fact1.PROJECT_ORGANIZATION_ID
    , fact1.PROJECT_ELEMENT_ID
    , DECODE (
               (grouping(qtr.ENT_YEAR_ID) || grouping(period.ENT_QTR_ID) || grouping(period.ENT_PERIOD_ID) )
             , '000', period.ENT_PERIOD_ID
             , '001', period.ENT_QTR_ID
             , '011', qtr.ENT_YEAR_ID
             , '111', -1 ) TIME_ID
    , DECODE (
               (grouping(qtr.ENT_YEAR_ID) || grouping(period.ENT_QTR_ID) || grouping(period.ENT_PERIOD_ID) )
             , '000', 32
             , '001', 64
             , '011', 128
             , '111', 2048 ) PERIOD_TYPE_ID
    , DECODE (
               grouping(qtr.ENT_YEAR_ID)
             , 0 , 'E'
             , 'A') CALENDAR_TYPE
    , RBS_AGGR_LEVEL
    , WBS_ROLLUP_FLAG
    , PRG_ROLLUP_FLAG
    , fact1.CURR_RECORD_TYPE_ID
    , fact1.CURRENCY_CODE
    , fact1.RBS_ELEMENT_ID
    , fact1.RBS_VERSION_ID
    , fact1.PLAN_VERSION_ID
    , fact1.plan_type_id
    , SUM(fact1.RAW_COST)
    , SUM(fact1.BRDN_COST)
    , SUM(fact1.REVENUE)
    , SUM(fact1.BILL_RAW_COST)
    , SUM(fact1.BILL_BRDN_COST )
    , SUM(fact1.BILL_LABOR_RAW_COST)
    , SUM(fact1.BILL_LABOR_BRDN_COST )
    , SUM(fact1.BILL_LABOR_HRS )
    , SUM(fact1.EQUIPMENT_RAW_COST )
    , SUM(fact1.EQUIPMENT_BRDN_COST )
    , SUM(fact1.CAPITALIZABLE_RAW_COST )
    , SUM(fact1.CAPITALIZABLE_BRDN_COST )
    , SUM(fact1.LABOR_RAW_COST )
    , SUM(fact1.LABOR_BRDN_COST )
    , SUM(fact1.LABOR_HRS)
    , SUM(fact1.LABOR_REVENUE)
    , SUM(fact1.EQUIPMENT_HOURS)
    , SUM(fact1.BILLABLE_EQUIPMENT_HOURS)
    , SUM(fact1.SUP_INV_COMMITTED_COST)
    , SUM(fact1.PO_COMMITTED_COST   )
    , SUM(fact1.PR_COMMITTED_COST  )
    , SUM(fact1.OTH_COMMITTED_COST)
       , SUM(fact1.ACT_LABOR_HRS)
	 , SUM(fact1.ACT_EQUIP_HRS)
	 , SUM(fact1.ACT_LABOR_BRDN_COST)
	 , SUM(fact1.ACT_EQUIP_BRDN_COST)
	 , SUM(fact1.ACT_BRDN_COST)
	 , SUM(fact1.ACT_RAW_COST)
	 , SUM(fact1.ACT_REVENUE)
       , SUM(fact1.ACT_LABOR_RAW_COST)
       , SUM(fact1.ACT_EQUIP_RAW_COST)
	 , SUM(fact1.ETC_LABOR_HRS)
	 , SUM(fact1.ETC_EQUIP_HRS)
	 , SUM(fact1.ETC_LABOR_BRDN_COST)
	 , SUM(fact1.ETC_EQUIP_BRDN_COST)
	 , SUM(fact1.ETC_BRDN_COST )
       , SUM(fact1.ETC_RAW_COST )
       , SUM(fact1.ETC_LABOR_RAW_COST)
       , SUM(fact1.ETC_EQUIP_RAW_COST)
    , SUM(CUSTOM1	)
    , SUM(CUSTOM2	)
    , SUM(CUSTOM3	)
    , SUM(CUSTOM4	)
    , SUM(CUSTOM5	)
    , SUM(CUSTOM6	)
    , SUM(CUSTOM7	)
    , SUM(CUSTOM8	)
    , SUM(CUSTOM9	)
    , SUM(CUSTOM10	)
    , SUM(CUSTOM11	)
    , SUM(CUSTOM12	)
    , SUM(CUSTOM13	)
    , SUM(CUSTOM14	)
    , SUM(CUSTOM15)
    , 'ENTR'
    , g_default_prg_level prg_level
    , fact1.PLAN_TYPE_CODE PLAN_TYPE_CODE   /* 4471527 */
    FROM
	  PJI_FP_AGGR_PJP1_T fact1  -- ,  PJI_FM_EXTR_PLNVER3_T ver
      , pji_time_ENT_PERIOD period
	, pji_time_ENT_QTR    qtr
    , pji_fm_extr_plnver3_t  ver
    WHERE
        fact1.calendar_type = 'E'
    AND period.ENT_period_id = fact1.time_id
    AND period.ENT_qtr_id = qtr.ENT_qtr_id
    AND fact1.period_type_id = 32
    AND fact1.worker_id = g_worker_id
   -- AND fact1.rbs_version_id IN (ver.rbs_struct_version_id, -1)   /* 4632551 */
    AND NVL(ver.rbs_struct_version_id, -1) = fact1.rbs_version_id
    -- AND ver.secondary_rbs_flag = 'N'
    AND fact1.plan_version_id = ver.plan_version_id
    AND fact1.plan_type_code = ver.plan_type_code    /* 4471527 */
	GROUP BY
 	  fact1.PROJECT_ID
    , fact1.PROJECT_ORG_ID
    , fact1.PROJECT_ORGANIZATION_ID
    , fact1.PROJECT_ELEMENT_ID
    , fact1.calendar_type
    , RBS_AGGR_LEVEL
    , WBS_ROLLUP_FLAG
    , PRG_ROLLUP_FLAG
    , fact1.CURR_RECORD_TYPE_ID
    , fact1.CURRENCY_CODE
    , fact1.RBS_ELEMENT_ID
    , fact1.RBS_VERSION_ID
    , fact1.PLAN_VERSION_ID
    , fact1.plan_type_id
    , fact1.plan_type_code    /* 4471527 */
    , rollup (qtr.ENT_YEAR_ID,
              period.ENT_QTR_ID,
              period.ENT_PERIOD_ID))
   WHERE period_type_id > 32
     AND period_type_id < 2048;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CREATE_FP_ENT_ROLLUP');
    RAISE;
END;


PROCEDURE CREATE_FP_PA_PRI_ROLLUP (
  p_honor_rbs  IN VARCHAR2 := 'Y'
) IS

    -- l_last_update_date     date   := SYSDATE;
    -- l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    -- l_creation_date        date   := SYSDATE;
    -- l_created_by           NUMBER := FND_GLOBAL.USER_ID;
    -- l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;
    l_calendar_type        VARCHAR2(15) := 'P';
    l_line_type            VARCHAR2(15) := 'PAR';

BEGIN

  -- g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;

  INSERT INTO pji_fp_aggr_pjp1_t
  (
         WORKER_ID
       , PROJECT_ID
       , PROJECT_ORG_ID
       , PROJECT_ORGANIZATION_ID
       , PROJECT_ELEMENT_ID
       , TIME_ID
       , PERIOD_TYPE_ID
       , CALENDAR_TYPE
       , RBS_AGGR_LEVEL
       , WBS_ROLLUP_FLAG
       , PRG_ROLLUP_FLAG
       , CURR_RECORD_TYPE_ID
       , CURRENCY_CODE
       , RBS_ELEMENT_ID
       , RBS_VERSION_ID
       , PLAN_VERSION_ID
       , PLAN_TYPE_ID
       , RAW_COST
       , BRDN_COST
       , REVENUE
       , BILL_RAW_COST
       , BILL_BRDN_COST
       , BILL_LABOR_RAW_COST
       , BILL_LABOR_BRDN_COST
       , BILL_LABOR_HRS
       , EQUIPMENT_RAW_COST
       , EQUIPMENT_BRDN_COST
       , CAPITALIZABLE_RAW_COST
       , CAPITALIZABLE_BRDN_COST
       , LABOR_RAW_COST
       , LABOR_BRDN_COST
       , LABOR_HRS
       , LABOR_REVENUE
       , EQUIPMENT_HOURS
       , BILLABLE_EQUIPMENT_HOURS
       , SUP_INV_COMMITTED_COST
       , PO_COMMITTED_COST
       , PR_COMMITTED_COST
       , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
       , CUSTOM1
       , CUSTOM2
       , CUSTOM3
       , CUSTOM4
       , CUSTOM5
       , CUSTOM6
       , CUSTOM7
       , CUSTOM8
       , CUSTOM9
       , CUSTOM10
       , CUSTOM11
       , CUSTOM12
       , CUSTOM13
       , CUSTOM14
       , CUSTOM15
       , LINE_TYPE
       -- , RATE_DANGLING_FLAG
       -- , TIME_DANGLING_FLAG
       -- , START_DATE
       -- , END_DATE
       , PRG_LEVEL
       , PLAN_TYPE_CODE    /* 4471527 */
    )
  SELECT * FROM (
  SELECT
       g_worker_id -- partition id
	, fact1.PROJECT_ID
    , fact1.PROJECT_ORG_ID
    , fact1.PROJECT_ORGANIZATION_ID
    , fact1.PROJECT_ELEMENT_ID
    , DECODE (
               (grouping(qtr.CAL_YEAR_ID) || grouping(period.CAL_QTR_ID) || grouping(period.CAL_PERIOD_ID) )
             , '000', period.CAL_PERIOD_ID
             , '001', period.CAL_QTR_ID
             , '011', qtr.CAL_YEAR_ID
             , '111', -1 ) TIME_ID
    , DECODE (
               (grouping(qtr.CAL_YEAR_ID) || grouping(period.CAL_QTR_ID) || grouping(period.CAL_PERIOD_ID) )
             , '000', 32
             , '001', 64
             , '011', 128
             , '111', 2048 ) PERIOD_TYPE_ID
    , DECODE (
               grouping(qtr.CAL_YEAR_ID)
             , 0 , l_calendar_type
             , 'A') CALENDAR_TYPE
    , fact1.RBS_AGGR_LEVEL
    , fact1.WBS_ROLLUP_FLAG
    , fact1.PRG_ROLLUP_FLAG
    , fact1.CURR_RECORD_TYPE_ID
    , fact1.CURRENCY_CODE
    , fact1.RBS_ELEMENT_ID
    , fact1.RBS_VERSION_ID
    , fact1.PLAN_VERSION_ID
	, fact1.PLAN_TYPE_ID
    , SUM(fact1.RAW_COST)  RAW_COST
    , SUM(fact1.BRDN_COST)  BRDN_COST
    , SUM(fact1.REVENUE)  REVENUE
    , SUM(fact1.BILL_RAW_COST)  BILL_RAW_COST
    , SUM(fact1.BILL_BRDN_COST )  BILL_BRDN_COST
    , SUM(fact1.BILL_LABOR_RAW_COST)  BILL_LABOR_RAW_COST
    , SUM(fact1.BILL_LABOR_BRDN_COST )  BILL_LABOR_BRDN_COST
    , SUM(fact1.BILL_LABOR_HRS )  BILL_LABOR_HRS
    , SUM(fact1.EQUIPMENT_RAW_COST )  EQUIPMENT_RAW_COST
    , SUM(fact1.EQUIPMENT_BRDN_COST ) EQUIPMENT_BRDN_COST
    , SUM(fact1.CAPITALIZABLE_RAW_COST ) CAPITALIZABLE_RAW_COST
    , SUM(fact1.CAPITALIZABLE_BRDN_COST )   CAPITALIZABLE_BRDN_COST
    , SUM(fact1.LABOR_RAW_COST )  LABOR_RAW_COST
    , SUM(fact1.LABOR_BRDN_COST ) LABOR_BRDN_COST
    , SUM(fact1.LABOR_HRS)  LABOR_HRS
    , SUM(fact1.LABOR_REVENUE)    LABOR_REVENUE
    , SUM(fact1.EQUIPMENT_HOURS)  EQUIPMENT_HOURS
    , SUM(fact1.BILLABLE_EQUIPMENT_HOURS)  BILLABLE_EQUIPMENT_HOURS
    , SUM(fact1.SUP_INV_COMMITTED_COST)   SUP_INV_COMMITTED_COST
    , SUM(fact1.PO_COMMITTED_COST   )  PO_COMMITTED_COST
    , SUM(fact1.PR_COMMITTED_COST  ) PR_COMMITTED_COST
    , SUM(fact1.OTH_COMMITTED_COST)  OTH_COMMITTED_COST
       , SUM(fact1.ACT_LABOR_HRS)
	 , SUM(fact1.ACT_EQUIP_HRS)
	 , SUM(fact1.ACT_LABOR_BRDN_COST)
	 , SUM(fact1.ACT_EQUIP_BRDN_COST)
	 , SUM(fact1.ACT_BRDN_COST)
	 , SUM(fact1.ACT_RAW_COST)
	 , SUM(fact1.ACT_REVENUE)
       , SUM(fact1.ACT_LABOR_RAW_COST)
       , SUM(fact1.ACT_EQUIP_RAW_COST)
	 , SUM(fact1.ETC_LABOR_HRS)
	 , SUM(fact1.ETC_EQUIP_HRS)
	 , SUM(fact1.ETC_LABOR_BRDN_COST)
	 , SUM(fact1.ETC_EQUIP_BRDN_COST)
	 , SUM(fact1.ETC_BRDN_COST )
       , SUM(fact1.ETC_RAW_COST )
       , SUM(fact1.ETC_LABOR_RAW_COST)
       , SUM(fact1.ETC_EQUIP_RAW_COST)
    , SUM(CUSTOM1	) CUSTOM1
    , SUM(CUSTOM2	) CUSTOM2
    , SUM(CUSTOM3	) CUSTOM3
    , SUM(CUSTOM4	) CUSTOM4
    , SUM(CUSTOM5	) CUSTOM5
    , SUM(CUSTOM6	) CUSTOM6
    , SUM(CUSTOM7	) CUSTOM7
    , SUM(CUSTOM8	) CUSTOM8
    , SUM(CUSTOM9	) CUSTOM9
    , SUM(CUSTOM10	) CUSTOM10
    , SUM(CUSTOM11	) CUSTOM11
    , SUM(CUSTOM12	) CUSTOM12
    , SUM(CUSTOM13	) CUSTOM13
    , SUM(CUSTOM14	) CUSTOM14
    , SUM(CUSTOM15) CUSTOM15
    , l_line_type line_type
    , g_default_prg_level prg_level
    , fact1.PLAN_TYPE_CODE PLAN_TYPE_CODE   /* 4471527 */
    FROM
	pji_fp_aggr_pjp1_t fact1  -- ,  PJI_FM_EXTR_PLNVER3_T ver
    , pji_time_CAL_PERIOD period
    , pji_time_CAL_QTR    qtr
    , pji_fm_extr_plnver3_t  ver
    WHERE
        fact1.calendar_type = 'P'
    AND period.cal_period_id = fact1.time_id
    AND period.cal_qtr_id = qtr.cal_qtr_id
    AND fact1.period_type_id = 32 -- > 0 -- <>  -1
    AND fact1.worker_id = g_worker_id
--    AND fact1.rbs_version_id IN (ver.rbs_struct_version_id, -1)   /* 4632551 */
    AND (
          (     NVL(ver.rbs_struct_version_id, -1) = fact1.rbs_version_id
            AND p_honor_rbs = 'Y'
          )
          OR
          ( p_honor_rbs = 'N' )
        )
    -- AND ver.secondary_rbs_flag = 'N'
    AND fact1.plan_version_id = ver.plan_version_id
   AND fact1.plan_type_code = ver.plan_type_code   /* 4471527 */
   GROUP BY
	fact1.PROJECT_ID
    , fact1.PROJECT_ORGANIZATION_ID
    , fact1.PROJECT_ORG_ID
    -- -- -- , fact1.PARTITION_ID
    , fact1.PROJECT_ELEMENT_ID
    , rollup (qtr.CAL_YEAR_ID,
              period.CAL_QTR_ID,
              period.CAL_PERIOD_ID)
    , fact1.calendar_type
    , fact1.RBS_AGGR_LEVEL
    , fact1.WBS_ROLLUP_FLAG
    , fact1.PRG_ROLLUP_FLAG
    , fact1.CURR_RECORD_TYPE_ID
    , fact1.CURRENCY_CODE
    , fact1.RBS_ELEMENT_ID
    , fact1.RBS_VERSION_ID
    , fact1.PLAN_VERSION_ID
    , fact1.PLAN_TYPE_ID
    , fact1.PLAN_TYPE_CODE )      /* 4471527 */
    WHERE period_type_id > 32
     AND period_type_id < 2048;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CREATE_FP_PA_PRI_ROLLUP');
    RAISE;
END;


PROCEDURE CREATE_FP_GL_PRI_ROLLUP (
  p_honor_rbs  IN VARCHAR2 := 'Y'
) IS
    -- l_last_update_date     date   := SYSDATE;
    -- l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    -- l_creation_date        date   := SYSDATE;
    -- l_created_by           NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;
    l_calendar_type        VARCHAR2(15) := 'G';
    l_line_type            VARCHAR2(15) := 'GLR';

BEGIN

  -- g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;

  INSERT INTO pji_fp_aggr_pjp1_t
  (
       WORKER_ID
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     -- , LAST_UPDATE_DATE
     -- , LAST_UPDATED_BY
     -- , CREATION_DATE
     -- , CREATED_BY
     -- , LAST_UPDATE_LOGIN
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , LINE_TYPE
     , PRG_LEVEL
     , PLAN_TYPE_CODE      /* 4471527 */
  )
  SELECT * FROM (
  SELECT
    -- GROUPING(qtr.CAL_YEAR_ID)  gy
    -- , GROUPING(period.CAL_QTR_ID)  gq
    -- , GROUPING(period.CAL_PERIOD_ID)  gp
	-- ,
      g_worker_id
    , fact1.PROJECT_ID
    , fact1.PROJECT_ORG_ID
    , fact1.PROJECT_ORGANIZATION_ID
    -- -- -- , fact1.PARTITION_ID
    , fact1.PROJECT_ELEMENT_ID
    , DECODE (
               (grouping(qtr.CAL_YEAR_ID) || grouping(period.CAL_QTR_ID) || grouping(period.CAL_PERIOD_ID) )
             , '000', period.CAL_PERIOD_ID
             , '001', period.CAL_QTR_ID
             , '011', qtr.CAL_YEAR_ID
             , '111', -1 ) TIME_ID
    , DECODE (
               (grouping(qtr.CAL_YEAR_ID) || grouping(period.CAL_QTR_ID) || grouping(period.CAL_PERIOD_ID) )
             , '000', 32
             , '001', 64
             , '011', 128
             , '111', 2048 ) PERIOD_TYPE_ID
    , DECODE (
               grouping(qtr.CAL_YEAR_ID)
             , 0 , l_calendar_type
             , 'A') CALENDAR_TYPE
    , fact1.RBS_AGGR_LEVEL
    , fact1.WBS_ROLLUP_FLAG
    , fact1.PRG_ROLLUP_FLAG
    , fact1.CURR_RECORD_TYPE_ID
    , fact1.CURRENCY_CODE
    , fact1.RBS_ELEMENT_ID
    , fact1.RBS_VERSION_ID
    , fact1.PLAN_VERSION_ID
	, fact1.PLAN_TYPE_ID
    , SUM(fact1.RAW_COST)  RAW_COST
    , SUM(fact1.BRDN_COST)  BRDN_COST
    , SUM(fact1.REVENUE)  REVENUE
    , SUM(fact1.BILL_RAW_COST)  BILL_RAW_COST
    , SUM(fact1.BILL_BRDN_COST )  BILL_BRDN_COST
    , SUM(fact1.BILL_LABOR_RAW_COST)  BILL_LABOR_RAW_COST
    , SUM(fact1.BILL_LABOR_BRDN_COST )  BILL_LABOR_BRDN_COST
    , SUM(fact1.BILL_LABOR_HRS )  BILL_LABOR_HRS
    , SUM(fact1.EQUIPMENT_RAW_COST )  EQUIPMENT_RAW_COST
    , SUM(fact1.EQUIPMENT_BRDN_COST ) EQUIPMENT_BRDN_COST
    , SUM(fact1.CAPITALIZABLE_RAW_COST ) CAPITALIZABLE_RAW_COST
    , SUM(fact1.CAPITALIZABLE_BRDN_COST )   CAPITALIZABLE_BRDN_COST
    , SUM(fact1.LABOR_RAW_COST )  LABOR_RAW_COST
    , SUM(fact1.LABOR_BRDN_COST ) LABOR_BRDN_COST
    , SUM(fact1.LABOR_HRS)  LABOR_HRS
    , SUM(fact1.LABOR_REVENUE)    LABOR_REVENUE
    , SUM(fact1.EQUIPMENT_HOURS)  EQUIPMENT_HOURS
    , SUM(fact1.BILLABLE_EQUIPMENT_HOURS)  BILLABLE_EQUIPMENT_HOURS
    , SUM(fact1.SUP_INV_COMMITTED_COST)   SUP_INV_COMMITTED_COST
    , SUM(fact1.PO_COMMITTED_COST   )  PO_COMMITTED_COST
    , SUM(fact1.PR_COMMITTED_COST  ) PR_COMMITTED_COST
    , SUM(fact1.OTH_COMMITTED_COST)  OTH_COMMITTED_COST
       , SUM(fact1.ACT_LABOR_HRS)
	 , SUM(fact1.ACT_EQUIP_HRS)
	 , SUM(fact1.ACT_LABOR_BRDN_COST)
	 , SUM(fact1.ACT_EQUIP_BRDN_COST)
	 , SUM(fact1.ACT_BRDN_COST)
	 , SUM(fact1.ACT_RAW_COST)
	 , SUM(fact1.ACT_REVENUE)
       , SUM(fact1.ACT_LABOR_RAW_COST)
       , SUM(fact1.ACT_EQUIP_RAW_COST)
	 , SUM(fact1.ETC_LABOR_HRS)
	 , SUM(fact1.ETC_EQUIP_HRS)
	 , SUM(fact1.ETC_LABOR_BRDN_COST)
	 , SUM(fact1.ETC_EQUIP_BRDN_COST)
	 , SUM(fact1.ETC_BRDN_COST )
       , SUM(fact1.ETC_RAW_COST )
       , SUM(fact1.ETC_LABOR_RAW_COST)
       , SUM(fact1.ETC_EQUIP_RAW_COST)
    , SUM(CUSTOM1	) CUSTOM1
    , SUM(CUSTOM2	) CUSTOM2
    , SUM(CUSTOM3	) CUSTOM3
    , SUM(CUSTOM4	) CUSTOM4
    , SUM(CUSTOM5	) CUSTOM5
    , SUM(CUSTOM6	) CUSTOM6
    , SUM(CUSTOM7	) CUSTOM7
    , SUM(CUSTOM8	) CUSTOM8
    , SUM(CUSTOM9	) CUSTOM9
    , SUM(CUSTOM10	) CUSTOM10
    , SUM(CUSTOM11	) CUSTOM11
    , SUM(CUSTOM12	) CUSTOM12
    , SUM(CUSTOM13	) CUSTOM13
    , SUM(CUSTOM14	) CUSTOM14
    , SUM(CUSTOM15) CUSTOM15
    , l_line_type
    , g_default_prg_level prg_level
    , fact1.PLAN_TYPE_CODE PLAN_TYPE_CODE   /* 4471527 */
    FROM
	pji_fp_aggr_pjp1_t fact1  -- ,  PJI_FM_EXTR_PLNVER3_T ver
    , pji_time_CAL_PERIOD period
    , pji_time_CAL_QTR    qtr
    , pji_fm_extr_plnver3_t  ver
    WHERE
        fact1.calendar_type = l_calendar_type
    AND period.cal_period_id = fact1.time_id
    AND period.cal_qtr_id = qtr.cal_qtr_id
    AND fact1.period_type_id = 32 -- <>  -1
    AND fact1.worker_id = g_worker_id
--    AND fact1.rbs_version_id IN (ver.rbs_struct_version_id, -1)   /* 4632551 */
    AND (
          (     NVL(ver.rbs_struct_version_id, -1) = fact1.rbs_version_id
            AND p_honor_rbs = 'Y'
          )
          OR
          ( p_honor_rbs = 'N' )
        )
    -- AND ver.secondary_rbs_flag = 'N'
    AND fact1.plan_version_id = ver.plan_version_id
    AND fact1.plan_type_code = ver.plan_type_code      /* 4471527 */
   GROUP BY
	fact1.PROJECT_ID
    , fact1.PROJECT_ORGANIZATION_ID
    , fact1.PROJECT_ORG_ID
    -- -- -- , fact1.PARTITION_ID
    , fact1.PROJECT_ELEMENT_ID
    , rollup (qtr.CAL_YEAR_ID,
              period.CAL_QTR_ID,
              period.CAL_PERIOD_ID)
    , fact1.calendar_type
    , fact1.RBS_AGGR_LEVEL
    , fact1.WBS_ROLLUP_FLAG
    , fact1.PRG_ROLLUP_FLAG
    , fact1.CURR_RECORD_TYPE_ID
    , fact1.CURRENCY_CODE
    , fact1.RBS_ELEMENT_ID
    , fact1.RBS_VERSION_ID
    , fact1.PLAN_VERSION_ID
    , fact1.PLAN_TYPE_ID
    , fact1.PLAN_TYPE_CODE)   /* 4471527 */
   WHERE period_type_id > 32
     AND period_type_id < 2048;


EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CREATE_FP_GL_PRI_ROLLUP');
    RAISE;
END;


PROCEDURE CREATE_FP_ALL_T_PRI_ROLLUP (
  p_honor_rbs     IN VARCHAR2 := 'Y'
, p_calendar_type IN VARCHAR2 ) IS /* Removed default value for bug 9067086 */

    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;
    l_line_type            VARCHAR2(15);
    l_time_phase_change      NUMBER := 0;
    l_calendar_type   varchar2(1); /* Added for bug 9067086 */

BEGIN

   l_calendar_type := p_calendar_type; /* Added for bug 9067086 */

  -- g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;
  /* Added for bug 9067086 starts */
  if (pji_utils.get_setup_parameter('TIME_PHASE_FLAG') = 'Y' )
     and (l_calendar_type is null) then
     select min(calendar_type)
     into l_calendar_type
     from pji_fp_aggr_pjp1_t
     where worker_id = g_worker_id;

  elsif l_calendar_type is null then
     l_calendar_type := 'G';
  end if;
  /* Added for bug 9067086 ends */

  IF (l_calendar_type NOT IN ('P', 'G','C') ) THEN  -- 'C' for time phase change
    RETURN;
  ELSE
  /* Modified for bug 9067086 starts */
    IF (l_calendar_type = 'P') THEN
      l_line_type := 'PAR';
    ELSIF (l_calendar_type = 'G') THEN
      l_line_type := 'GLR';
    ELSE
      l_line_type := 'CLR';
    END IF;
  /* Modified for bug 9067086 ends */
  END IF;
/*  4604617 */
BEGIN
    select  1 into l_time_phase_change from  PJI_FM_EXTR_PLNVER3_T VER
    where EXISTS (SELECT 1 FROM PJI_FM_EXTR_PLAN_LINES PL
         	    WHERE PL.PROJECT_ID = VER.PROJECT_ID
                    AND PL.PLAN_VERSION_ID = VER.PLAN_VERSION_ID
                    AND PL.PLAN_TYPE_ID = VER.PLAN_TYPE_ID
            	    AND PL.CALENDAR_TYPE <> VER.TIME_PHASED_TYPE_CODE);
  exception when NO_DATA_FOUND then
    null;
 end ;
IF l_time_phase_change = 0 THEN

INSERT INTO PJI_FP_AGGR_PJP1_T
  (
       WORKER_ID
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , LINE_TYPE
     , PRG_LEVEL
    , PLAN_TYPE_CODE   /* 4471527 */
  )
   SELECT
      g_worker_id
    , fact1.PROJECT_ID
    , fact1.PROJECT_ORG_ID
    , fact1.PROJECT_ORGANIZATION_ID
    , fact1.PROJECT_ELEMENT_ID
/*    , DECODE (
               (grouping(qtr.CAL_YEAR_ID) || grouping(period.CAL_QTR_ID) || grouping(period.CAL_PERIOD_ID) )
             , '000', period.CAL_PERIOD_ID
             , '001', period.CAL_QTR_ID
             , '011', qtr.CAL_YEAR_ID
             , '111', -1 ) TIME_ID
    , DECODE (
               (grouping(qtr.CAL_YEAR_ID) || grouping(period.CAL_QTR_ID) || grouping(period.CAL_PERIOD_ID) )
             , '000', 32
             , '001', 64
             , '011', 128
             , '111', 2048 ) PERIOD_TYPE_ID
    , DECODE (
               grouping(qtr.CAL_YEAR_ID)
             , 0 ,p_calendar_type
             , 'A') CALENDAR_TYPE    */
    , -1   TIME_ID
    , 2048 PERIOD_TYPE_ID
    , 'A'  CALENDAR_TYPE
    , fact1.RBS_AGGR_LEVEL
    , fact1.WBS_ROLLUP_FLAG
    , fact1.PRG_ROLLUP_FLAG
    , fact1.CURR_RECORD_TYPE_ID
    , fact1.CURRENCY_CODE
    , fact1.RBS_ELEMENT_ID
    , fact1.RBS_VERSION_ID
    , fact1.PLAN_VERSION_ID
	, fact1.PLAN_TYPE_ID
    , SUM(fact1.RAW_COST)  RAW_COST
    , SUM(fact1.BRDN_COST)  BRDN_COST
    , SUM(fact1.REVENUE)  REVENUE
    , SUM(fact1.BILL_RAW_COST)  BILL_RAW_COST
    , SUM(fact1.BILL_BRDN_COST )  BILL_BRDN_COST
    , SUM(fact1.BILL_LABOR_RAW_COST)  BILL_LABOR_RAW_COST
    , SUM(fact1.BILL_LABOR_BRDN_COST )  BILL_LABOR_BRDN_COST
    , SUM(fact1.BILL_LABOR_HRS )  BILL_LABOR_HRS
    , SUM(fact1.EQUIPMENT_RAW_COST )  EQUIPMENT_RAW_COST
    , SUM(fact1.EQUIPMENT_BRDN_COST ) EQUIPMENT_BRDN_COST
    , SUM(fact1.CAPITALIZABLE_RAW_COST ) CAPITALIZABLE_RAW_COST
    , SUM(fact1.CAPITALIZABLE_BRDN_COST )   CAPITALIZABLE_BRDN_COST
    , SUM(fact1.LABOR_RAW_COST )  LABOR_RAW_COST
    , SUM(fact1.LABOR_BRDN_COST ) LABOR_BRDN_COST
    , SUM(fact1.LABOR_HRS)  LABOR_HRS
    , SUM(fact1.LABOR_REVENUE)    LABOR_REVENUE
    , SUM(fact1.EQUIPMENT_HOURS)  EQUIPMENT_HOURS
    , SUM(fact1.BILLABLE_EQUIPMENT_HOURS)  BILLABLE_EQUIPMENT_HOURS
    , SUM(fact1.SUP_INV_COMMITTED_COST)   SUP_INV_COMMITTED_COST
    , SUM(fact1.PO_COMMITTED_COST   )  PO_COMMITTED_COST
    , SUM(fact1.PR_COMMITTED_COST  ) PR_COMMITTED_COST
    , SUM(fact1.OTH_COMMITTED_COST)  OTH_COMMITTED_COST
       , SUM(fact1.ACT_LABOR_HRS)
	 , SUM(fact1.ACT_EQUIP_HRS)
	 , SUM(fact1.ACT_LABOR_BRDN_COST)
	 , SUM(fact1.ACT_EQUIP_BRDN_COST)
	 , SUM(fact1.ACT_BRDN_COST)
	 , SUM(fact1.ACT_RAW_COST)
	 , SUM(fact1.ACT_REVENUE)
       , SUM(fact1.ACT_LABOR_RAW_COST)
       , SUM(fact1.ACT_EQUIP_RAW_COST)
	 , SUM(fact1.ETC_LABOR_HRS)
	 , SUM(fact1.ETC_EQUIP_HRS)
	 , SUM(fact1.ETC_LABOR_BRDN_COST)
	 , SUM(fact1.ETC_EQUIP_BRDN_COST)
	 , SUM(fact1.ETC_BRDN_COST )
       , SUM(fact1.ETC_RAW_COST )
       , SUM(fact1.ETC_LABOR_RAW_COST)
       , SUM(fact1.ETC_EQUIP_RAW_COST)
    , SUM(CUSTOM1	) CUSTOM1
    , SUM(CUSTOM2	) CUSTOM2
    , SUM(CUSTOM3	) CUSTOM3
    , SUM(CUSTOM4	) CUSTOM4
    , SUM(CUSTOM5	) CUSTOM5
    , SUM(CUSTOM6	) CUSTOM6
    , SUM(CUSTOM7	) CUSTOM7
    , SUM(CUSTOM8	) CUSTOM8
    , SUM(CUSTOM9	) CUSTOM9
    , SUM(CUSTOM10	) CUSTOM10
    , SUM(CUSTOM11	) CUSTOM11
    , SUM(CUSTOM12	) CUSTOM12
    , SUM(CUSTOM13	) CUSTOM13
    , SUM(CUSTOM14	) CUSTOM14
    , SUM(CUSTOM15) CUSTOM15
    ,l_line_type
    , g_default_prg_level prg_level
   , fact1.PLAN_TYPE_CODE PLAN_TYPE_CODE   /* 4471527 */
    FROM
	PJI_FP_AGGR_PJP1_T fact1
    , pji_time_CAL_PERIOD period
    , pji_time_CAL_QTR    qtr
    , pji_fm_extr_plnver3_t ver
    WHERE
        fact1.calendar_type IN ( l_calendar_type
  				 , DECODE (l_calendar_type ,'C','G','X')
				 , DECODE (l_calendar_type ,'C','P','X')
				) /* Modified for bug 9067086 */
    AND period.cal_period_id = fact1.time_id
    AND period.cal_qtr_id = qtr.cal_qtr_id
    AND fact1.period_type_id = 32
    AND ver.time_phased_type_code IN ('P', 'G') -- If non time phased plan, then calender type is C.
    AND ver.project_id = fact1.project_id
    AND ver.plan_version_id = fact1.plan_version_id
    AND ver.plan_type_code  = fact1.plan_type_code   /* 4471527 */
    AND fact1.worker_id = g_worker_id
--    AND fact1.rbs_version_id IN (ver.rbs_struct_version_id, -1)   /* 4632551 */
    AND (
          (     NVL(ver.rbs_struct_version_id, -1) = fact1.rbs_version_id
            AND p_honor_rbs = 'Y'
          )
          OR
          ( p_honor_rbs = 'N' )
        )
--    AND fact1.plan_version_id = ver.plan_version_id
   GROUP BY
	fact1.PROJECT_ID
    , fact1.PROJECT_ORGANIZATION_ID
    , fact1.PROJECT_ORG_ID
    , fact1.PROJECT_ELEMENT_ID
    , fact1.RBS_AGGR_LEVEL
    , fact1.WBS_ROLLUP_FLAG
    , fact1.PRG_ROLLUP_FLAG
    , fact1.CURR_RECORD_TYPE_ID
    , fact1.CURRENCY_CODE
    , fact1.RBS_ELEMENT_ID
    , fact1.RBS_VERSION_ID
    , fact1.PLAN_VERSION_ID
    , fact1.PLAN_TYPE_ID
    , fact1.PLAN_TYPE_CODE ;   /* 4471527 */

ELSE
/* 4604617 */
/*When Time phase change from PA/GL to None then update the existing A lines
  When Gl to PA or vice versa , insert only one -A lines */
MERGE INTO PJI_FP_AGGR_PJP1_T F1
USING ( SELECT   g_worker_id WORKER_ID
    , fact1.PROJECT_ID
    , fact1.PROJECT_ORG_ID
    , fact1.PROJECT_ORGANIZATION_ID
    , fact1.PROJECT_ELEMENT_ID
    , -1   TIME_ID
    , 2048 PERIOD_TYPE_ID
    , 'A'  CALENDAR_TYPE
    , fact1.RBS_AGGR_LEVEL
    , fact1.WBS_ROLLUP_FLAG
    , fact1.PRG_ROLLUP_FLAG
    , fact1.CURR_RECORD_TYPE_ID
    , fact1.CURRENCY_CODE
    , fact1.RBS_ELEMENT_ID
    , fact1.RBS_VERSION_ID
    , fact1.PLAN_VERSION_ID
    , fact1.PLAN_TYPE_ID
    , SUM(fact1.RAW_COST)  RAW_COST
    , SUM(fact1.BRDN_COST)  BRDN_COST
    , SUM(fact1.REVENUE)  REVENUE
    , SUM(fact1.BILL_RAW_COST)  BILL_RAW_COST
    , SUM(fact1.BILL_BRDN_COST )  BILL_BRDN_COST
    , SUM(fact1.BILL_LABOR_RAW_COST)  BILL_LABOR_RAW_COST
    , SUM(fact1.BILL_LABOR_BRDN_COST )  BILL_LABOR_BRDN_COST
    , SUM(fact1.BILL_LABOR_HRS )  BILL_LABOR_HRS
    , SUM(fact1.EQUIPMENT_RAW_COST )  EQUIPMENT_RAW_COST
    , SUM(fact1.EQUIPMENT_BRDN_COST ) EQUIPMENT_BRDN_COST
    , SUM(fact1.CAPITALIZABLE_RAW_COST ) CAPITALIZABLE_RAW_COST
    , SUM(fact1.CAPITALIZABLE_BRDN_COST )   CAPITALIZABLE_BRDN_COST
    , SUM(fact1.LABOR_RAW_COST )  LABOR_RAW_COST
    , SUM(fact1.LABOR_BRDN_COST ) LABOR_BRDN_COST
    , SUM(fact1.LABOR_HRS)  LABOR_HRS
    , SUM(fact1.LABOR_REVENUE)    LABOR_REVENUE
    , SUM(fact1.EQUIPMENT_HOURS)  EQUIPMENT_HOURS
    , SUM(fact1.BILLABLE_EQUIPMENT_HOURS)  BILLABLE_EQUIPMENT_HOURS
    , SUM(fact1.SUP_INV_COMMITTED_COST)   SUP_INV_COMMITTED_COST
    , SUM(fact1.PO_COMMITTED_COST   )  PO_COMMITTED_COST
    , SUM(fact1.PR_COMMITTED_COST  ) PR_COMMITTED_COST
    , SUM(fact1.OTH_COMMITTED_COST)  OTH_COMMITTED_COST
    , SUM(CUSTOM1	) CUSTOM1
    , SUM(CUSTOM2	) CUSTOM2
    , SUM(CUSTOM3	) CUSTOM3
    , SUM(CUSTOM4	) CUSTOM4
    , SUM(CUSTOM5	) CUSTOM5
    , SUM(CUSTOM6	) CUSTOM6
    , SUM(CUSTOM7	) CUSTOM7
    , SUM(CUSTOM8	) CUSTOM8
    , SUM(CUSTOM9	) CUSTOM9
    , SUM(CUSTOM10	) CUSTOM10
    , SUM(CUSTOM11	) CUSTOM11
    , SUM(CUSTOM12	) CUSTOM12
    , SUM(CUSTOM13	) CUSTOM13
    , SUM(CUSTOM14	) CUSTOM14
    , SUM(CUSTOM15) CUSTOM15
    , SUM(fact1.ACT_LABOR_HRS) ACT_LABOR_HRS
    , SUM(fact1.ACT_EQUIP_HRS) ACT_EQUIP_HRS
    , SUM(fact1.ACT_LABOR_BRDN_COST) ACT_LABOR_BRDN_COST
    , SUM(fact1.ACT_EQUIP_BRDN_COST) ACT_EQUIP_BRDN_COST
    , SUM(fact1.ACT_BRDN_COST) ACT_BRDN_COST
    , SUM(fact1.ACT_RAW_COST) ACT_RAW_COST
    , SUM(fact1.ACT_REVENUE) ACT_REVENUE
    , SUM(fact1.ACT_LABOR_RAW_COST) ACT_LABOR_RAW_COST
    , SUM(fact1.ACT_EQUIP_RAW_COST) ACT_EQUIP_RAW_COST
    , SUM(fact1.ETC_LABOR_HRS) ETC_LABOR_HRS
    , SUM(fact1.ETC_EQUIP_HRS) ETC_EQUIP_HRS
    , SUM(fact1.ETC_LABOR_BRDN_COST) ETC_LABOR_BRDN_COST
    , SUM(fact1.ETC_EQUIP_BRDN_COST) ETC_EQUIP_BRDN_COST
    , SUM(fact1.ETC_BRDN_COST ) ETC_BRDN_COST
    , SUM(fact1.ETC_RAW_COST ) ETC_RAW_COST
    , SUM(fact1.ETC_LABOR_RAW_COST) ETC_LABOR_RAW_COST
    , SUM(fact1.ETC_EQUIP_RAW_COST) ETC_EQUIP_RAW_COST
    , g_default_prg_level PRG_LEVEL
    , l_line_type LINE_TYPE
    , fact1.PLAN_TYPE_CODE PLAN_TYPE_CODE     /* 4471527 */
    FROM
    PJI_FP_AGGR_PJP1_T fact1
    , pji_time_CAL_PERIOD period
    , pji_time_CAL_QTR    qtr
    , pji_fm_extr_plnver3_t ver
    WHERE
        fact1.calendar_type IN ( p_calendar_type
  				 , DECODE (p_calendar_type ,'C','G','X')
				 , DECODE (p_calendar_type ,'C','P','X')
				)
    AND period.cal_period_id = fact1.time_id
    AND period.cal_qtr_id = qtr.cal_qtr_id
    AND fact1.period_type_id = 32
    AND ver.time_phased_type_code IN ('P', 'G','N') -- If non time phased plan, then calender type is C.
    AND ver.project_id = fact1.project_id
    AND ver.plan_version_id = fact1.plan_version_id
   AND ver.plan_type_code = fact1.plan_type_code    /* 4471527 */
    AND fact1.worker_id = g_worker_id
--    AND fact1.rbs_version_id IN (ver.rbs_struct_version_id, -1)   /* 4632551 */
    AND NVL(ver.rbs_struct_version_id, -1) = fact1.rbs_version_id
--    AND fact1.plan_version_id = ver.plan_version_id
   GROUP BY
	fact1.PROJECT_ID
    , fact1.PROJECT_ORGANIZATION_ID
    , fact1.PROJECT_ORG_ID
    , fact1.PROJECT_ELEMENT_ID
    , fact1.RBS_AGGR_LEVEL
    , fact1.WBS_ROLLUP_FLAG
    , fact1.PRG_ROLLUP_FLAG
    , fact1.CURR_RECORD_TYPE_ID
    , fact1.CURRENCY_CODE
    , fact1.RBS_ELEMENT_ID
    , fact1.RBS_VERSION_ID
    , fact1.PLAN_VERSION_ID
    , fact1.PLAN_TYPE_ID
    , fact1.PLAN_TYPE_CODE ) F2         /* 4471527 */
ON (F1.WORKER_ID = F2.WORKER_ID
    AND F1.PROJECT_ID = F2.PROJECT_ID
    AND F1.PROJECT_ORGANIZATION_ID = F2.PROJECT_ORGANIZATION_ID
    AND F1.PROJECT_ORG_ID = F2.PROJECT_ORG_ID
    AND F1.PROJECT_ELEMENT_ID = F2.PROJECT_ELEMENT_ID
    AND F1.RBS_AGGR_LEVEL = F2.RBS_AGGR_LEVEL
    AND F1.WBS_ROLLUP_FLAG = F2.WBS_ROLLUP_FLAG
    AND F1.PRG_ROLLUP_FLAG = F2.PRG_ROLLUP_FLAG
    AND F1.CURR_RECORD_TYPE_ID = F2.CURR_RECORD_TYPE_ID
    AND F1.CURRENCY_CODE = F2.CURRENCY_CODE
    AND F1.RBS_ELEMENT_ID = F2.RBS_ELEMENT_ID
    AND F1.RBS_VERSION_ID = F2.RBS_VERSION_ID
    AND F1.PLAN_VERSION_ID = F2.PLAN_VERSION_ID
    AND F1.PLAN_TYPE_ID = F2.PLAN_TYPE_ID
    AND F1.PLAN_TYPE_CODE = F2.PLAN_TYPE_CODE    /* 4471527 */
    AND F1.TIME_ID = F2.TIME_ID
    AND F1.CALENDAR_TYPE = F2.CALENDAR_TYPE
    AND F1.PERIOD_TYPE_ID = F2.PERIOD_TYPE_ID )
WHEN MATCHED THEN
UPDATE
SET   F1.RAW_COST = F1.RAW_COST + F2.RAW_COST
    , F1.BRDN_COST = F1.BRDN_COST + F2.BRDN_COST
    , F1.REVENUE = F1.REVENUE + F2.REVENUE
    , F1.BILL_RAW_COST = F1.BILL_RAW_COST + F2.BILL_RAW_COST
    , F1.BILL_BRDN_COST = F1.BILL_BRDN_COST + F2.BILL_BRDN_COST
    , F1.BILL_LABOR_RAW_COST = F1.BILL_LABOR_RAW_COST + F2.BILL_LABOR_RAW_COST
    , F1.BILL_LABOR_BRDN_COST = F1.BILL_LABOR_BRDN_COST + F2.BILL_LABOR_BRDN_COST
    , F1.BILL_LABOR_HRS = F1.BILL_LABOR_HRS + F2.BILL_LABOR_HRS
    , F1.EQUIPMENT_RAW_COST = F1.EQUIPMENT_RAW_COST + F2.EQUIPMENT_RAW_COST
    , F1.EQUIPMENT_BRDN_COST = F1.EQUIPMENT_BRDN_COST + F2.EQUIPMENT_BRDN_COST
    , F1.CAPITALIZABLE_RAW_COST = F1.CAPITALIZABLE_RAW_COST + F2.CAPITALIZABLE_RAW_COST
    , F1.CAPITALIZABLE_BRDN_COST = F1.CAPITALIZABLE_BRDN_COST + F2.CAPITALIZABLE_BRDN_COST
    , F1.LABOR_RAW_COST = F1.LABOR_RAW_COST + F2.LABOR_RAW_COST
    , F1.LABOR_BRDN_COST = F1.LABOR_BRDN_COST + F2.LABOR_BRDN_COST
    , F1.LABOR_HRS = F1.LABOR_HRS + F2.LABOR_HRS
    , F1.LABOR_REVENUE = F1.LABOR_REVENUE + F2.LABOR_REVENUE
    , F1.EQUIPMENT_HOURS = F1.EQUIPMENT_HOURS + F2.EQUIPMENT_HOURS
    , F1.BILLABLE_EQUIPMENT_HOURS = F1.BILLABLE_EQUIPMENT_HOURS + F2.BILLABLE_EQUIPMENT_HOURS
    , F1.SUP_INV_COMMITTED_COST = F1.SUP_INV_COMMITTED_COST + F2.SUP_INV_COMMITTED_COST
    , F1.PO_COMMITTED_COST = F1.PO_COMMITTED_COST + F2.PO_COMMITTED_COST
    , F1.PR_COMMITTED_COST = F1.PR_COMMITTED_COST + F2.PR_COMMITTED_COST
    , F1.OTH_COMMITTED_COST = F1.OTH_COMMITTED_COST + F2.OTH_COMMITTED_COST
    , F1.ACT_LABOR_HRS = F1.ACT_LABOR_HRS + F2.ACT_LABOR_HRS
    , F1.ACT_EQUIP_HRS = F1.ACT_EQUIP_HRS + F2.ACT_EQUIP_HRS
    , F1.ACT_LABOR_BRDN_COST = F1.ACT_LABOR_BRDN_COST + F2.ACT_LABOR_BRDN_COST
    , F1.ACT_EQUIP_BRDN_COST = F1.ACT_EQUIP_BRDN_COST + F2.ACT_EQUIP_BRDN_COST
    , F1.ACT_BRDN_COST = F1.ACT_BRDN_COST + F2.ACT_BRDN_COST
    , F1.ACT_RAW_COST = F1.ACT_RAW_COST + F2.ACT_RAW_COST
    , F1.ACT_REVENUE = F1.ACT_REVENUE + F2.ACT_REVENUE
    , F1.ACT_LABOR_RAW_COST = F1.ACT_LABOR_RAW_COST +F2.ACT_LABOR_RAW_COST
    , F1.ACT_EQUIP_RAW_COST = F1.ACT_EQUIP_RAW_COST + F2.ACT_EQUIP_RAW_COST
    , F1.ETC_LABOR_HRS = F1.ETC_LABOR_HRS + F2.ETC_LABOR_HRS
    , F1.ETC_EQUIP_HRS = F1.ETC_EQUIP_HRS + F2.ETC_EQUIP_HRS
    , F1.ETC_LABOR_BRDN_COST = F1.ETC_LABOR_BRDN_COST + F2.ETC_LABOR_BRDN_COST
    , F1.ETC_EQUIP_BRDN_COST = F1.ETC_EQUIP_BRDN_COST + F2.ETC_EQUIP_BRDN_COST
    , F1.ETC_BRDN_COST = F1.ETC_BRDN_COST + F2.ETC_BRDN_COST
    , F1.ETC_RAW_COST = F1.ETC_RAW_COST + F2.ETC_RAW_COST
    , F1.ETC_LABOR_RAW_COST = F1.ETC_LABOR_RAW_COST + F2.ETC_LABOR_RAW_COST
    , F1.ETC_EQUIP_RAW_COST = F1.ETC_EQUIP_RAW_COST + F2.ETC_EQUIP_RAW_COST
    , F1.CUSTOM1 = F1.CUSTOM1 + F2.CUSTOM1
    , F1.CUSTOM2 = F1.CUSTOM2 + F2.CUSTOM2
    , F1.CUSTOM3 = F1.CUSTOM3 + F2.CUSTOM3
    , F1.CUSTOM4 = F1.CUSTOM4 + F2.CUSTOM4
    , F1.CUSTOM5 = F1.CUSTOM5 + F2.CUSTOM5
    , F1.CUSTOM6 = F1.CUSTOM6 + F2.CUSTOM6
    , F1.CUSTOM7 = F1.CUSTOM7 + F2.CUSTOM7
    , F1.CUSTOM8 = F1.CUSTOM8 + F2.CUSTOM8
    , F1.CUSTOM9 = F1.CUSTOM9 + F2.CUSTOM9
    , F1.CUSTOM10 = F1.CUSTOM10 + F2.CUSTOM10
    , F1.CUSTOM11 = F1.CUSTOM11 + F2.CUSTOM11
    , F1.CUSTOM12 = F1.CUSTOM12 + F2.CUSTOM12
    , F1.CUSTOM13 = F1.CUSTOM13 + F2.CUSTOM13
    , F1.CUSTOM14 = F1.CUSTOM14 + F2.CUSTOM14
    , F1.CUSTOM15 = F1.CUSTOM15 + F2.CUSTOM15
 WHEN NOT MATCHED THEN
INSERT
  (  F1.WORKER_ID
     , F1.PROJECT_ID
     , F1.PROJECT_ORG_ID
     , F1.PROJECT_ORGANIZATION_ID
     , F1.PROJECT_ELEMENT_ID
     , F1.TIME_ID
     , F1.PERIOD_TYPE_ID
     , F1.CALENDAR_TYPE
     , F1.RBS_AGGR_LEVEL
     , F1.WBS_ROLLUP_FLAG
     , F1.PRG_ROLLUP_FLAG
     , F1.CURR_RECORD_TYPE_ID
     , F1.CURRENCY_CODE
     , F1.RBS_ELEMENT_ID
     , F1.RBS_VERSION_ID
     , F1.PLAN_VERSION_ID
     , F1.PLAN_TYPE_ID
     , F1.RAW_COST
     , F1.BRDN_COST
     , F1.REVENUE
     , F1.BILL_RAW_COST
     , F1.BILL_BRDN_COST
     , F1.BILL_LABOR_RAW_COST
     , F1.BILL_LABOR_BRDN_COST
     , F1.BILL_LABOR_HRS
     , F1.EQUIPMENT_RAW_COST
     , F1.EQUIPMENT_BRDN_COST
     , F1.CAPITALIZABLE_RAW_COST
     , F1.CAPITALIZABLE_BRDN_COST
     , F1.LABOR_RAW_COST
     , F1.LABOR_BRDN_COST
     , F1.LABOR_HRS
     , F1.LABOR_REVENUE
     , F1.EQUIPMENT_HOURS
     , F1.BILLABLE_EQUIPMENT_HOURS
     , F1.SUP_INV_COMMITTED_COST
     , F1.PO_COMMITTED_COST
     , F1.PR_COMMITTED_COST
     , F1.OTH_COMMITTED_COST
     , F1.ACT_LABOR_HRS
     , F1.ACT_EQUIP_HRS
     , F1.ACT_LABOR_BRDN_COST
     , F1.ACT_EQUIP_BRDN_COST
     , F1.ACT_BRDN_COST
     , F1.ACT_RAW_COST
     , F1.ACT_REVENUE
     , F1.ACT_LABOR_RAW_COST
     , F1.ACT_EQUIP_RAW_COST
     , F1.ETC_LABOR_HRS
     , F1.ETC_EQUIP_HRS
     , F1.ETC_LABOR_BRDN_COST
     , F1.ETC_EQUIP_BRDN_COST
     , F1.ETC_BRDN_COST
     , F1.ETC_RAW_COST
     , F1.ETC_LABOR_RAW_COST
     , F1.ETC_EQUIP_RAW_COST
     , F1.CUSTOM1
     , F1.CUSTOM2
     , F1.CUSTOM3
     , F1.CUSTOM4
     , F1.CUSTOM5
     , F1.CUSTOM6
     , F1.CUSTOM7
     , F1.CUSTOM8
     , F1.CUSTOM9
     , F1.CUSTOM10
     , F1.CUSTOM11
     , F1.CUSTOM12
     , F1.CUSTOM13
     , F1.CUSTOM14
     , F1.CUSTOM15
     , F1.LINE_TYPE
     , F1.PRG_LEVEL
     , F1.PLAN_TYPE_CODE    /* 4471527 */
  )
VALUES
(  F2.WORKER_ID
     , F2.PROJECT_ID
     , F2.PROJECT_ORG_ID
     , F2.PROJECT_ORGANIZATION_ID
     , F2.PROJECT_ELEMENT_ID
     , F2.TIME_ID
     , F2.PERIOD_TYPE_ID
     , F2.CALENDAR_TYPE
     , F2.RBS_AGGR_LEVEL
     , F2.WBS_ROLLUP_FLAG
     , F2.PRG_ROLLUP_FLAG
     , F2.CURR_RECORD_TYPE_ID
     , F2.CURRENCY_CODE
     , F2.RBS_ELEMENT_ID
     , F2.RBS_VERSION_ID
     , F2.PLAN_VERSION_ID
     , F2.PLAN_TYPE_ID
     , F2.RAW_COST
     , F2.BRDN_COST
     , F2.REVENUE
     , F2.BILL_RAW_COST
     , F2.BILL_BRDN_COST
     , F2.BILL_LABOR_RAW_COST
     , F2.BILL_LABOR_BRDN_COST
     , F2.BILL_LABOR_HRS
     , F2.EQUIPMENT_RAW_COST
     , F2.EQUIPMENT_BRDN_COST
     , F2.CAPITALIZABLE_RAW_COST
     , F2.CAPITALIZABLE_BRDN_COST
     , F2.LABOR_RAW_COST
     , F2.LABOR_BRDN_COST
     , F2.LABOR_HRS
     , F2.LABOR_REVENUE
     , F2.EQUIPMENT_HOURS
     , F2.BILLABLE_EQUIPMENT_HOURS
     , F2.SUP_INV_COMMITTED_COST
     , F2.PO_COMMITTED_COST
     , F2.PR_COMMITTED_COST
     , F2.OTH_COMMITTED_COST
     , F2.ACT_LABOR_HRS
     , F2.ACT_EQUIP_HRS
     , F2.ACT_LABOR_BRDN_COST
     , F2.ACT_EQUIP_BRDN_COST
     , F2.ACT_BRDN_COST
     , F2.ACT_RAW_COST
     , F2.ACT_REVENUE
     , F2.ACT_LABOR_RAW_COST
     , F2.ACT_EQUIP_RAW_COST
     , F2.ETC_LABOR_HRS
     , F2.ETC_EQUIP_HRS
     , F2.ETC_LABOR_BRDN_COST
     , F2.ETC_EQUIP_BRDN_COST
     , F2.ETC_BRDN_COST
     , F2.ETC_RAW_COST
     , F2.ETC_LABOR_RAW_COST
     , F2.ETC_EQUIP_RAW_COST
     , F2.CUSTOM1
     , F2.CUSTOM2
     , F2.CUSTOM3
     , F2.CUSTOM4
     , F2.CUSTOM5
     , F2.CUSTOM6
     , F2.CUSTOM7
     , F2.CUSTOM8
     , F2.CUSTOM9
     , F2.CUSTOM10
     , F2.CUSTOM11
     , F2.CUSTOM12
     , F2.CUSTOM13
     , F2.CUSTOM14
     , F2.CUSTOM15
     , F2.LINE_TYPE
     , F2.PRG_LEVEL
     , F2.PLAN_TYPE_CODE    /* 4471527 */
  );

END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CREATE_FP_ALL_T_PRI_ROLLUP');
    RAISE;
END;


PROCEDURE CREATE_FP_ALLT_PRI_AGGREGATE IS
    -- l_last_update_date     date   := SYSDATE;
    -- l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    -- l_creation_date        date   := SYSDATE;
    -- l_created_by           NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;
    l_calendar_type        VARCHAR2(15) := 'A';
    l_line_type            VARCHAR2(15) := 'ATR';
    l_time_id              NUMBER := -1;
    l_period_type_id       NUMBER := 2048;

BEGIN

  -- g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;

  INSERT INTO pji_fp_aggr_pjp1_t
  (
       WORKER_ID
     , PRG_LEVEL
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , LINE_TYPE
     , PLAN_TYPE_CODE
  )
  SELECT * FROM (
  SELECT
      g_worker_id
    , g_default_prg_level prg_level
    , fact1.PROJECT_ID
    , fact1.PROJECT_ORG_ID
    , fact1.PROJECT_ORGANIZATION_ID
    , fact1.PROJECT_ELEMENT_ID
    , l_time_id                             TIME_ID
    , l_period_type_id                      PERIOD_TYPE_ID
    , l_calendar_type                       CALENDAR_TYPE
    , fact1.RBS_AGGR_LEVEL
    , fact1.WBS_ROLLUP_FLAG
    , fact1.PRG_ROLLUP_FLAG
    , fact1.CURR_RECORD_TYPE_ID
    , fact1.CURRENCY_CODE
    , fact1.RBS_ELEMENT_ID
    , fact1.RBS_VERSION_ID
    , fact1.PLAN_VERSION_ID
	, fact1.PLAN_TYPE_ID
    , SUM(fact1.RAW_COST)  RAW_COST
    , SUM(fact1.BRDN_COST)  BRDN_COST
    , SUM(fact1.REVENUE)  REVENUE
    , SUM(fact1.BILL_RAW_COST)  BILL_RAW_COST
    , SUM(fact1.BILL_BRDN_COST )  BILL_BRDN_COST
    , SUM(fact1.BILL_LABOR_RAW_COST)  BILL_LABOR_RAW_COST
    , SUM(fact1.BILL_LABOR_BRDN_COST )  BILL_LABOR_BRDN_COST
    , SUM(fact1.BILL_LABOR_HRS )  BILL_LABOR_HRS
    , SUM(fact1.EQUIPMENT_RAW_COST )  EQUIPMENT_RAW_COST
    , SUM(fact1.EQUIPMENT_BRDN_COST ) EQUIPMENT_BRDN_COST
    , SUM(fact1.CAPITALIZABLE_RAW_COST ) CAPITALIZABLE_RAW_COST
    , SUM(fact1.CAPITALIZABLE_BRDN_COST )   CAPITALIZABLE_BRDN_COST
    , SUM(fact1.LABOR_RAW_COST )  LABOR_RAW_COST
    , SUM(fact1.LABOR_BRDN_COST ) LABOR_BRDN_COST
    , SUM(fact1.LABOR_HRS)  LABOR_HRS
    , SUM(fact1.LABOR_REVENUE)    LABOR_REVENUE
    , SUM(fact1.EQUIPMENT_HOURS)  EQUIPMENT_HOURS
    , SUM(fact1.BILLABLE_EQUIPMENT_HOURS)  BILLABLE_EQUIPMENT_HOURS
    , SUM(fact1.SUP_INV_COMMITTED_COST)   SUP_INV_COMMITTED_COST
    , SUM(fact1.PO_COMMITTED_COST   )  PO_COMMITTED_COST
    , SUM(fact1.PR_COMMITTED_COST  ) PR_COMMITTED_COST
    , SUM(fact1.OTH_COMMITTED_COST)  OTH_COMMITTED_COST
       , SUM(fact1.ACT_LABOR_HRS)
	 , SUM(fact1.ACT_EQUIP_HRS)
	 , SUM(fact1.ACT_LABOR_BRDN_COST)
	 , SUM(fact1.ACT_EQUIP_BRDN_COST)
	 , SUM(fact1.ACT_BRDN_COST)
	 , SUM(fact1.ACT_RAW_COST)
	 , SUM(fact1.ACT_REVENUE)
       , SUM(fact1.ACT_LABOR_RAW_COST)
       , SUM(fact1.ACT_EQUIP_RAW_COST)
	 , SUM(fact1.ETC_LABOR_HRS)
	 , SUM(fact1.ETC_EQUIP_HRS)
	 , SUM(fact1.ETC_LABOR_BRDN_COST)
	 , SUM(fact1.ETC_EQUIP_BRDN_COST)
	 , SUM(fact1.ETC_BRDN_COST )
       , SUM(fact1.ETC_RAW_COST )
       , SUM(fact1.ETC_LABOR_RAW_COST)
       , SUM(fact1.ETC_EQUIP_RAW_COST)
    , SUM(CUSTOM1	) CUSTOM1
    , SUM(CUSTOM2	) CUSTOM2
    , SUM(CUSTOM3	) CUSTOM3
    , SUM(CUSTOM4	) CUSTOM4
    , SUM(CUSTOM5	) CUSTOM5
    , SUM(CUSTOM6	) CUSTOM6
    , SUM(CUSTOM7	) CUSTOM7
    , SUM(CUSTOM8	) CUSTOM8
    , SUM(CUSTOM9	) CUSTOM9
    , SUM(CUSTOM10	) CUSTOM10
    , SUM(CUSTOM11	) CUSTOM11
    , SUM(CUSTOM12	) CUSTOM12
    , SUM(CUSTOM13	) CUSTOM13
    , SUM(CUSTOM14	) CUSTOM14
    , SUM(CUSTOM15) CUSTOM15
    , l_line_type
    , fact1.PLAN_TYPE_CODE PLAN_TYPE_CODE   /* 4471527 */
    FROM
	  pji_fp_aggr_pjp1_t fact1  -- ,  PJI_FM_EXTR_PLNVER3_T ver
    , pji_fm_extr_plnver3_t  ver
    WHERE
        fact1.calendar_type = l_calendar_type
    AND fact1.period_type_id = l_period_type_id
    AND fact1.time_id = l_time_id
    AND fact1.worker_id = g_worker_id
--    AND fact1.rbs_version_id IN (ver.rbs_struct_version_id, -1)   /* 4632551 */
  --  AND ( ver.rbs_struct_version_id = fact1.rbs_version_id  OR fact1.rbs_version_id = -1)
    AND NVL(ver.rbs_struct_version_id, -1) = fact1.rbs_version_id
    AND ver.secondary_rbs_flag = 'N'
    AND fact1.plan_version_id = ver.plan_version_id
    AND fact1.plan_type_code = ver.plan_type_code   /* 4471527 */
   GROUP BY
      fact1.PROJECT_ID
    , fact1.PROJECT_ORGANIZATION_ID
    , fact1.PROJECT_ORG_ID
    , fact1.PROJECT_ELEMENT_ID
    , fact1.RBS_AGGR_LEVEL
    , fact1.WBS_ROLLUP_FLAG
    , fact1.PRG_ROLLUP_FLAG
    , fact1.CURR_RECORD_TYPE_ID
    , fact1.CURRENCY_CODE
    , fact1.RBS_ELEMENT_ID
    , fact1.RBS_VERSION_ID
    , fact1.PLAN_VERSION_ID
    , fact1.PLAN_TYPE_ID
    , fact1.PLAN_TYPE_CODE) WHERE period_type_id > 32;


EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CREATE_FP_ALLT_PRI_AGGREGATE');
    RAISE;
END;


PROCEDURE CREATE_FP_ALLT_SEC_AGGREGATE IS
    -- l_last_update_date     date   := SYSDATE;
    -- l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    -- l_creation_date        date   := SYSDATE;
    -- l_created_by           NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;
    l_calendar_type        VARCHAR2(15) := 'A';
    l_line_type            VARCHAR2(15) := 'ATR';
    l_time_id              NUMBER := -1;
    l_period_type_id       NUMBER := 2048;

BEGIN

  NULL;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;


PROCEDURE CREATE_FP_PA_SEC_ROLLUP IS
    -- l_last_update_date     date   := SYSDATE;
    -- l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    -- l_creation_date        date   := SYSDATE;
    -- l_created_by           NUMBER := FND_GLOBAL.USER_ID;
    -- l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;
BEGIN

  -- g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;

  INSERT INTO pji_fp_aggr_pjp1_t
  (
       WORKER_ID
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     -- , LAST_UPDATE_DATE
     -- , LAST_UPDATED_BY
     -- , CREATION_DATE
     -- , CREATED_BY
     -- , LAST_UPDATE_LOGIN
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , LINE_TYPE
     , PRG_LEVEL
     , PLAN_TYPE_CODE   /* 4471527 */
  )
  SELECT * FROM (
  SELECT
    -- GROUPING(qtr.CAL_YEAR_ID)  gy
    -- , GROUPING(period.CAL_QTR_ID)  gq
    -- , GROUPING(period.CAL_PERIOD_ID)  gp
	-- ,
	g_worker_id
    , fact1.PROJECT_ID
    , fact1.PROJECT_ORG_ID
    , fact1.PROJECT_ORGANIZATION_ID
    -- -- -- , fact1.PARTITION_ID
    , fact1.PROJECT_ELEMENT_ID
    , DECODE (
               (grouping(qtr.CAL_YEAR_ID) || grouping(period.CAL_QTR_ID) || grouping(period.CAL_PERIOD_ID) )
             , '000', period.CAL_PERIOD_ID
             , '001', period.CAL_QTR_ID
             , '011', qtr.CAL_YEAR_ID
             , '111', -1 ) TIME_ID
    , DECODE (
               (grouping(qtr.CAL_YEAR_ID) || grouping(period.CAL_QTR_ID) || grouping(period.CAL_PERIOD_ID) )
             , '000', 32
             , '001', 64
             , '011', 128
             , '111', 2048 ) PERIOD_TYPE_ID
    , DECODE (
               grouping(qtr.CAL_YEAR_ID)
             , 0 , 'P'
             , 'A') CALENDAR_TYPE
    , fact1.RBS_AGGR_LEVEL
    , fact1.WBS_ROLLUP_FLAG
    , fact1.PRG_ROLLUP_FLAG
    , fact1.CURR_RECORD_TYPE_ID
    , fact1.CURRENCY_CODE
    , fact1.RBS_ELEMENT_ID
    , fact1.RBS_VERSION_ID
    , fact1.PLAN_VERSION_ID
	, fact1.PLAN_TYPE_ID
    -- , l_last_update_date
    -- , l_last_updated_by
    -- , l_creation_date
    -- , l_created_by
    -- , l_last_update_login
    , SUM(fact1.RAW_COST)
    , SUM(fact1.BRDN_COST)
    , SUM(fact1.REVENUE)
    , SUM(fact1.BILL_RAW_COST)
    , SUM(fact1.BILL_BRDN_COST )
    , SUM(fact1.BILL_LABOR_RAW_COST)
    , SUM(fact1.BILL_LABOR_BRDN_COST )
    , SUM(fact1.BILL_LABOR_HRS )
    , SUM(fact1.EQUIPMENT_RAW_COST )
    , SUM(fact1.EQUIPMENT_BRDN_COST )
    , SUM(fact1.CAPITALIZABLE_RAW_COST )
    , SUM(fact1.CAPITALIZABLE_BRDN_COST )
    , SUM(fact1.LABOR_RAW_COST )
    , SUM(fact1.LABOR_BRDN_COST )
    , SUM(fact1.LABOR_HRS)
    , SUM(fact1.LABOR_REVENUE)
    , SUM(fact1.EQUIPMENT_HOURS)
    , SUM(fact1.BILLABLE_EQUIPMENT_HOURS)
    , SUM(fact1.SUP_INV_COMMITTED_COST)
    , SUM(fact1.PO_COMMITTED_COST   )
    , SUM(fact1.PR_COMMITTED_COST  )
    , SUM(fact1.OTH_COMMITTED_COST)
       , SUM(fact1.ACT_LABOR_HRS)
	 , SUM(fact1.ACT_EQUIP_HRS)
	 , SUM(fact1.ACT_LABOR_BRDN_COST)
	 , SUM(fact1.ACT_EQUIP_BRDN_COST)
	 , SUM(fact1.ACT_BRDN_COST)
	 , SUM(fact1.ACT_RAW_COST)
	 , SUM(fact1.ACT_REVENUE)
       , SUM(fact1.ACT_LABOR_RAW_COST)
       , SUM(fact1.ACT_EQUIP_RAW_COST)
	 , SUM(fact1.ETC_LABOR_HRS)
	 , SUM(fact1.ETC_EQUIP_HRS)
	 , SUM(fact1.ETC_LABOR_BRDN_COST)
	 , SUM(fact1.ETC_EQUIP_BRDN_COST)
	 , SUM(fact1.ETC_BRDN_COST )
       , SUM(fact1.ETC_RAW_COST )
       , SUM(fact1.ETC_LABOR_RAW_COST)
       , SUM(fact1.ETC_EQUIP_RAW_COST)
    , SUM(CUSTOM1	)
    , SUM(CUSTOM2	)
    , SUM(CUSTOM3	)
    , SUM(CUSTOM4	)
    , SUM(CUSTOM5	)
    , SUM(CUSTOM6	)
    , SUM(CUSTOM7	)
    , SUM(CUSTOM8	)
    , SUM(CUSTOM9	)
    , SUM(CUSTOM10	)
    , SUM(CUSTOM11	)
    , SUM(CUSTOM12	)
    , SUM(CUSTOM13	)
    , SUM(CUSTOM14	)
    , SUM(CUSTOM15)
    , 'PAR'
    , g_default_prg_level prg_level
    , fact1.plan_type_code plan_type_code     /* 4471527 */
   FROM
	  pji_fp_aggr_pjp1_t fact1  -- ,  PJI_FM_EXTR_PLNVER3_T ver
    , pji_time_CAL_PERIOD period
    , pji_time_CAL_QTR    qtr
    , pji_fm_extr_plnver3_t  ver
   WHERE
        fact1.calendar_type = 'P'
    AND period.cal_period_id = fact1.time_id
    AND period.cal_qtr_id = qtr.cal_qtr_id
    AND fact1.period_type_id = 32
    AND fact1.line_type <> 'OF'
    AND fact1.worker_id = g_worker_id
  --  AND fact1.rbs_version_id IN (ver.rbs_struct_version_id, -1)   /* 4632551 */
    -- AND ( ver.rbs_struct_version_id = fact1.rbs_version_id  OR fact1.rbs_version_id = -1)
    AND NVL(ver.rbs_struct_version_id, -1) = fact1.rbs_version_id
    AND ver.secondary_rbs_flag = 'N'
    AND fact1.plan_version_id = ver.plan_version_id
    AND fact1.plan_type_code = ver.plan_type_code    /* 4471527 */
    GROUP BY
	  fact1.PROJECT_ID
    , fact1.PROJECT_ORGANIZATION_ID
    , fact1.PROJECT_ORG_ID
    -- -- -- , fact1.PARTITION_ID
    , fact1.PROJECT_ELEMENT_ID
    , rollup (qtr.CAL_YEAR_ID,
              period.CAL_QTR_ID,
              period.CAL_PERIOD_ID)
    , fact1.calendar_type
    , fact1.RBS_AGGR_LEVEL
    , fact1.WBS_ROLLUP_FLAG
    , fact1.PRG_ROLLUP_FLAG
    , fact1.CURR_RECORD_TYPE_ID
    , fact1.CURRENCY_CODE
    , fact1.RBS_ELEMENT_ID
    , fact1.RBS_VERSION_ID
    , fact1.PLAN_VERSION_ID
    , fact1.PLAN_TYPE_ID
    , fact1.PLAN_TYPE_CODE)
   WHERE 1=1
     AND period_type_id > 32
     AND period_type_id < 2048;


EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CREATE_FP_ALLT_SEC_AGGREGATE');
    RAISE;
END;


PROCEDURE CREATE_FP_GL_SEC_ROLLUP IS
    -- l_last_update_date     date   := SYSDATE;
    -- l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    -- l_creation_date        date   := SYSDATE;
    -- l_created_by           NUMBER := FND_GLOBAL.USER_ID;
    -- l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;
BEGIN

  -- g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;

  INSERT INTO pji_fp_aggr_pjp1_t
  (
       WORKER_ID
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     -- , LAST_UPDATE_DATE
     -- , LAST_UPDATED_BY
     -- , CREATION_DATE
     -- , CREATED_BY
     -- , LAST_UPDATE_LOGIN
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , LINE_TYPE
     , PRG_LEVEL
     , PLAN_TYPE_CODE     /* 4471527 */
  )
  SELECT * FROM (
  SELECT
    -- GROUPING(qtr.CAL_YEAR_ID)  gy
    -- , GROUPING(period.CAL_QTR_ID)  gq
    -- , GROUPING(period.CAL_PERIOD_ID)  gp
	-- ,
	g_worker_id
    , fact1.PROJECT_ID
    , fact1.PROJECT_ORG_ID
    , fact1.PROJECT_ORGANIZATION_ID
    -- -- -- , fact1.PARTITION_ID
    , fact1.PROJECT_ELEMENT_ID
    , DECODE (
               (grouping(qtr.CAL_YEAR_ID) || grouping(period.CAL_QTR_ID) || grouping(period.CAL_PERIOD_ID) )
             , '000', period.CAL_PERIOD_ID
             , '001', period.CAL_QTR_ID
             , '011', qtr.CAL_YEAR_ID
             , '111', -1 ) TIME_ID
    , DECODE (
               (grouping(qtr.CAL_YEAR_ID) || grouping(period.CAL_QTR_ID) || grouping(period.CAL_PERIOD_ID) )
             , '000', 32
             , '001', 64
             , '011', 128
             , '111', 2048 ) PERIOD_TYPE_ID
    , DECODE (
               grouping(qtr.CAL_YEAR_ID)
             , 0 , 'G'
             , 'A') CALENDAR_TYPE
    , fact1.RBS_AGGR_LEVEL
    , fact1.WBS_ROLLUP_FLAG
    , fact1.PRG_ROLLUP_FLAG
    , fact1.CURR_RECORD_TYPE_ID
    , fact1.CURRENCY_CODE
    , fact1.RBS_ELEMENT_ID
    , fact1.RBS_VERSION_ID
    , fact1.PLAN_VERSION_ID
    , fact1.PLAN_TYPE_ID
    -- , l_last_update_date
    -- , l_last_updated_by
    -- , l_creation_date
    -- , l_created_by
    -- , l_last_update_login
    , SUM(fact1.RAW_COST)
    , SUM(fact1.BRDN_COST)
    , SUM(fact1.REVENUE)
    , SUM(fact1.BILL_RAW_COST)
    , SUM(fact1.BILL_BRDN_COST )
    , SUM(fact1.BILL_LABOR_RAW_COST)
    , SUM(fact1.BILL_LABOR_BRDN_COST )
    , SUM(fact1.BILL_LABOR_HRS )
    , SUM(fact1.EQUIPMENT_RAW_COST )
    , SUM(fact1.EQUIPMENT_BRDN_COST )
    , SUM(fact1.CAPITALIZABLE_RAW_COST )
    , SUM(fact1.CAPITALIZABLE_BRDN_COST )
    , SUM(fact1.LABOR_RAW_COST )
    , SUM(fact1.LABOR_BRDN_COST )
    , SUM(fact1.LABOR_HRS)
    , SUM(fact1.LABOR_REVENUE)
    , SUM(fact1.EQUIPMENT_HOURS)
    , SUM(fact1.BILLABLE_EQUIPMENT_HOURS)
    , SUM(fact1.SUP_INV_COMMITTED_COST)
    , SUM(fact1.PO_COMMITTED_COST   )
    , SUM(fact1.PR_COMMITTED_COST  )
    , SUM(fact1.OTH_COMMITTED_COST)
       , SUM(fact1.ACT_LABOR_HRS)
	 , SUM(fact1.ACT_EQUIP_HRS)
	 , SUM(fact1.ACT_LABOR_BRDN_COST)
	 , SUM(fact1.ACT_EQUIP_BRDN_COST)
	 , SUM(fact1.ACT_BRDN_COST)
	 , SUM(fact1.ACT_RAW_COST)
	 , SUM(fact1.ACT_REVENUE)
       , SUM(fact1.ACT_LABOR_RAW_COST)
       , SUM(fact1.ACT_EQUIP_RAW_COST)
	 , SUM(fact1.ETC_LABOR_HRS)
	 , SUM(fact1.ETC_EQUIP_HRS)
	 , SUM(fact1.ETC_LABOR_BRDN_COST)
	 , SUM(fact1.ETC_EQUIP_BRDN_COST)
	 , SUM(fact1.ETC_BRDN_COST )
       , SUM(fact1.ETC_RAW_COST )
       , SUM(fact1.ETC_LABOR_RAW_COST)
       , SUM(fact1.ETC_EQUIP_RAW_COST)
    , SUM(CUSTOM1	)
    , SUM(CUSTOM2	)
    , SUM(CUSTOM3	)
    , SUM(CUSTOM4	)
    , SUM(CUSTOM5	)
    , SUM(CUSTOM6	)
    , SUM(CUSTOM7	)
    , SUM(CUSTOM8	)
    , SUM(CUSTOM9	)
    , SUM(CUSTOM10)
    , SUM(CUSTOM11)
    , SUM(CUSTOM12)
    , SUM(CUSTOM13)
    , SUM(CUSTOM14)
    , SUM(CUSTOM15)
    , 'GLR'
    , g_default_prg_level prg_level
    , fact1.PLAN_TYPE_CODE  PLAN_TYPE_CODE   /* 4471527 */
    FROM
	  pji_fp_aggr_pjp1_t fact1  -- ,  PJI_FM_EXTR_PLNVER3_T ver
    , pji_time_CAL_PERIOD period
	, pji_time_CAL_QTR    qtr
    , pji_fm_extr_plnver3_t  ver
    WHERE
        fact1.calendar_type = 'G'
    AND period.cal_period_id = fact1.time_id
    AND period.cal_qtr_id = qtr.cal_qtr_id
    AND fact1.period_type_id = 32
    AND fact1.line_type <> 'OF'
    AND fact1.worker_id = g_worker_id
--    AND fact1.rbs_version_id IN (ver.rbs_struct_version_id, -1)   /* 4632551 */
    -- AND ( ver.rbs_struct_version_id = fact1.rbs_version_id  OR fact1.rbs_version_id = -1)
    AND NVL(ver.rbs_struct_version_id, -1) = fact1.rbs_version_id
    AND ver.secondary_rbs_flag = 'N'
    AND fact1.plan_version_id = ver.plan_version_id
    AND fact1.plan_type_code = ver.plan_type_code    /* 4471527 */
  GROUP BY
	  fact1.PROJECT_ID
    , fact1.PROJECT_ORGANIZATION_ID
    , fact1.PROJECT_ORG_ID
    -- -- -- , fact1.PARTITION_ID
    , fact1.PROJECT_ELEMENT_ID
    , rollup (qtr.CAL_YEAR_ID,
              period.CAL_QTR_ID,
              period.CAL_PERIOD_ID)
    , fact1.calendar_type
    , fact1.RBS_AGGR_LEVEL
    , fact1.WBS_ROLLUP_FLAG
    , fact1.PRG_ROLLUP_FLAG
    , fact1.CURR_RECORD_TYPE_ID
    , fact1.CURRENCY_CODE
    , fact1.RBS_ELEMENT_ID
    , fact1.RBS_VERSION_ID
    , fact1.PLAN_VERSION_ID
    , fact1.PLAN_TYPE_ID
    , fact1.PLAN_TYPE_CODE )
   WHERE 1=1
     AND period_type_id > 32
     AND period_type_id < 2048;


EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CREATE_FP_GL_SEC_ROLLUP');
    RAISE;
END;


PROCEDURE CREATE_FP_ENT_SEC_ROLLUP IS
    -- l_last_update_date     date   := SYSDATE;
    -- l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    -- l_creation_date        date   := SYSDATE;
    -- l_created_by           NUMBER := FND_GLOBAL.USER_ID;
    -- l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;
BEGIN

  -- g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;

  INSERT INTO pji_fp_aggr_pjp1_t
  (
       WORKER_ID
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     -- , LAST_UPDATE_DATE
     -- , LAST_UPDATED_BY
     -- , CREATION_DATE
     -- , CREATED_BY
     -- , LAST_UPDATE_LOGIN
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , LINE_TYPE
     , PRG_LEVEL
     , PLAN_TYPE_CODE    /* 4471527 */
  )
  SELECT * FROM (
  SELECT
    --    GROUPING(qtr.ENT_YEAR_ID)  gy
    --, GROUPING(period.ENT_QTR_ID)  gq
    --, GROUPING(period.ENT_PERIOD_ID)  gp
	--,
      g_worker_id
    , fact1.PROJECT_ID
    , fact1.PROJECT_ORG_ID
    , fact1.PROJECT_ORGANIZATION_ID
    -- -- -- , fact1.PARTITION_ID
    , fact1.PROJECT_ELEMENT_ID
    , DECODE (
               (grouping(qtr.ENT_YEAR_ID) || grouping(period.ENT_QTR_ID) || grouping(period.ENT_PERIOD_ID) )
             , '000', period.ENT_PERIOD_ID
             , '001', period.ENT_QTR_ID
             , '011', qtr.ENT_YEAR_ID
             , '111', -1 ) TIME_ID
    , DECODE (
               (grouping(qtr.ENT_YEAR_ID) || grouping(period.ENT_QTR_ID) || grouping(period.ENT_PERIOD_ID) )
             , '000', 32
             , '001', 64
             , '011', 128
             , '111', 2048 ) PERIOD_TYPE_ID
    , DECODE (
               grouping(qtr.ENT_YEAR_ID)
             , 0 , 'E'
             , 'A') CALENDAR_TYPE
    , RBS_AGGR_LEVEL
    , WBS_ROLLUP_FLAG
    , PRG_ROLLUP_FLAG
    , fact1.CURR_RECORD_TYPE_ID
    , fact1.CURRENCY_CODE
    , fact1.RBS_ELEMENT_ID
    , fact1.RBS_VERSION_ID
    , fact1.PLAN_VERSION_ID
    , fact1.plan_type_id
    -- , l_last_update_date
    -- , l_last_updated_by
    -- , l_creation_date
    -- , l_created_by
    -- , l_last_update_login
    , SUM(fact1.RAW_COST)
    , SUM(fact1.BRDN_COST)
    , SUM(fact1.REVENUE)
    , SUM(fact1.BILL_RAW_COST)
    , SUM(fact1.BILL_BRDN_COST )
    , SUM(fact1.BILL_LABOR_RAW_COST)
    , SUM(fact1.BILL_LABOR_BRDN_COST )
    , SUM(fact1.BILL_LABOR_HRS )
    , SUM(fact1.EQUIPMENT_RAW_COST )
    , SUM(fact1.EQUIPMENT_BRDN_COST )
    , SUM(fact1.CAPITALIZABLE_RAW_COST )
    , SUM(fact1.CAPITALIZABLE_BRDN_COST )
    , SUM(fact1.LABOR_RAW_COST )
    , SUM(fact1.LABOR_BRDN_COST )
    , SUM(fact1.LABOR_HRS)
    , SUM(fact1.LABOR_REVENUE)
    , SUM(fact1.EQUIPMENT_HOURS)
    , SUM(fact1.BILLABLE_EQUIPMENT_HOURS)
    , SUM(fact1.SUP_INV_COMMITTED_COST)
    , SUM(fact1.PO_COMMITTED_COST   )
    , SUM(fact1.PR_COMMITTED_COST  )
    , SUM(fact1.OTH_COMMITTED_COST)
       , SUM(fact1.ACT_LABOR_HRS)
	 , SUM(fact1.ACT_EQUIP_HRS)
	 , SUM(fact1.ACT_LABOR_BRDN_COST)
	 , SUM(fact1.ACT_EQUIP_BRDN_COST)
	 , SUM(fact1.ACT_BRDN_COST)
	 , SUM(fact1.ACT_RAW_COST)
	 , SUM(fact1.ACT_REVENUE)
       , SUM(fact1.ACT_LABOR_RAW_COST)
       , SUM(fact1.ACT_EQUIP_RAW_COST)
	 , SUM(fact1.ETC_LABOR_HRS)
	 , SUM(fact1.ETC_EQUIP_HRS)
	 , SUM(fact1.ETC_LABOR_BRDN_COST)
	 , SUM(fact1.ETC_EQUIP_BRDN_COST)
	 , SUM(fact1.ETC_BRDN_COST )
       , SUM(fact1.ETC_RAW_COST )
       , SUM(fact1.ETC_LABOR_RAW_COST)
       , SUM(fact1.ETC_EQUIP_RAW_COST)
    , SUM(CUSTOM1	)
    , SUM(CUSTOM2	)
    , SUM(CUSTOM3	)
    , SUM(CUSTOM4	)
    , SUM(CUSTOM5	)
    , SUM(CUSTOM6	)
    , SUM(CUSTOM7	)
    , SUM(CUSTOM8	)
    , SUM(CUSTOM9	)
    , SUM(CUSTOM10	)
    , SUM(CUSTOM11	)
    , SUM(CUSTOM12	)
    , SUM(CUSTOM13	)
    , SUM(CUSTOM14	)
    , SUM(CUSTOM15)
    , 'ENTR'
    , g_default_prg_level prg_level
    , fact1.PLAN_TYPE_CODE PLAN_TYPE_CODE    /* 4471527 */
    FROM
	  pji_fp_aggr_pjp1_t fact1  -- ,  PJI_FM_EXTR_PLNVER3_T ver
      , pji_time_ENT_PERIOD period
	, pji_time_ENT_QTR    qtr
    , pji_fm_extr_plnver3_t  ver
    WHERE
        fact1.calendar_type = 'E'
    AND period.ENT_period_id = fact1.time_id
    AND period.ENT_qtr_id = qtr.ENT_qtr_id
    AND fact1.period_type_id = 32
    AND fact1.worker_id = g_worker_id
--    AND fact1.rbs_version_id IN (ver.rbs_struct_version_id, -1)   /* 4632551 */
    -- AND ( ver.rbs_struct_version_id = fact1.rbs_version_id  OR fact1.rbs_version_id = -1)
    AND NVL(ver.rbs_struct_version_id, -1) = fact1.rbs_version_id
    AND ver.secondary_rbs_flag = 'N'
    AND fact1.plan_version_id = ver.plan_version_id
    AND fact1.plan_type_code = ver.plan_type_code    /*  4471527 */
  GROUP BY
      fact1.PROJECT_ID
    , fact1.PROJECT_ORG_ID
    , fact1.PROJECT_ORGANIZATION_ID
    -- -- -- , fact1.PARTITION_ID
    , fact1.PROJECT_ELEMENT_ID
    , fact1.calendar_type
    , RBS_AGGR_LEVEL
    , WBS_ROLLUP_FLAG
    , PRG_ROLLUP_FLAG
    , fact1.CURR_RECORD_TYPE_ID
    , fact1.CURRENCY_CODE
    , fact1.RBS_ELEMENT_ID
    , fact1.RBS_VERSION_ID
    , fact1.PLAN_VERSION_ID
    , fact1.plan_type_id
    , fact1.plan_type_code    /*4471527 */
    , rollup (qtr.ENT_YEAR_ID,
              period.ENT_QTR_ID,
              period.ENT_PERIOD_ID))
   WHERE 1=1
     AND period_type_id > 32
     AND period_type_id < 2048;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CREATE_FP_ENT_SEC_ROLLUP');
    RAISE;
END;


PROCEDURE CREATE_AC_PA_ROLLUP IS
BEGIN

    -- g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;

    INSERT INTO pji_ac_aggr_pjp1_t
    (
       WORKER_ID
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , REVENUE
     , INITIAL_FUNDING_AMOUNT
     , INITIAL_FUNDING_COUNT
     , ADDITIONAL_FUNDING_AMOUNT
     , ADDITIONAL_FUNDING_COUNT
     , CANCELLED_FUNDING_AMOUNT
     , CANCELLED_FUNDING_COUNT
     , FUNDING_ADJUSTMENT_AMOUNT
     , FUNDING_ADJUSTMENT_COUNT
     , REVENUE_WRITEOFF
     , AR_INVOICE_AMOUNT
     , AR_INVOICE_COUNT
     , AR_CASH_APPLIED_AMOUNT
     , AR_INVOICE_WRITE_OFF_AMOUNT
     , AR_INVOICE_WRITEOFF_COUNT
     , AR_CREDIT_MEMO_AMOUNT
     , AR_CREDIT_MEMO_COUNT
     , UNBILLED_RECEIVABLES
     , UNEARNED_REVENUE
     , AR_UNAPPR_INVOICE_AMOUNT
     , AR_UNAPPR_INVOICE_COUNT
     , AR_APPR_INVOICE_AMOUNT
     , AR_APPR_INVOICE_COUNT
     , AR_AMOUNT_DUE
     , AR_COUNT_DUE
     , AR_AMOUNT_OVERDUE
     , AR_COUNT_OVERDUE
     , DORMANT_BACKLOG_INACTIV
     , DORMANT_BACKLOG_START
     , LOST_BACKLOG
     , ACTIVE_BACKLOG
     , REVENUE_AT_RISK
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , PRG_LEVEL
    )
  SELECT * FROM (
    SELECT
      -- GROUPING(qtr.CAL_YEAR_ID)  gy
      -- , GROUPING(period.CAL_QTR_ID)  gq
      -- , GROUPING(period.CAL_PERIOD_ID)  gp
      -- ,
       g_worker_id
     , fact1.PROJECT_ID
     , fact1.PROJECT_ORG_ID
     , fact1.PROJECT_ORGANIZATION_ID
     -- -- -- , fact1.PARTITION_ID
     , fact1.PROJECT_ELEMENT_ID
     , DECODE (
               (grouping(qtr.CAL_YEAR_ID) || grouping(period.CAL_QTR_ID) || grouping(period.CAL_PERIOD_ID) )
             , '000', period.CAL_PERIOD_ID
             , '001', period.CAL_QTR_ID
             , '011', qtr.CAL_YEAR_ID
             , '111', -1 ) TIME_ID
     , DECODE (
               (grouping(qtr.CAL_YEAR_ID) || grouping(period.CAL_QTR_ID) || grouping(period.CAL_PERIOD_ID) )
             , '000', 32
             , '001', 64
             , '011', 128
             , '111', 2048 ) PERIOD_TYPE_ID
     , fact1.CALENDAR_TYPE
     , fact1.WBS_ROLLUP_FLAG
     , fact1.PRG_ROLLUP_FLAG
     , fact1.CURR_RECORD_TYPE_ID
     , fact1.CURRENCY_CODE
     , SUM(fact1.REVENUE )
     , SUM(fact1.INITIAL_FUNDING_AMOUNT )
     , SUM(fact1.INITIAL_FUNDING_COUNT)
     , SUM(fact1.ADDITIONAL_FUNDING_AMOUNT)
     , SUM(fact1.ADDITIONAL_FUNDING_COUNT  )
     , SUM(fact1.CANCELLED_FUNDING_AMOUNT)
     , SUM(fact1.CANCELLED_FUNDING_COUNT)
     , SUM(fact1.FUNDING_ADJUSTMENT_AMOUNT)
     , SUM(fact1.FUNDING_ADJUSTMENT_COUNT)
     , SUM(fact1.REVENUE_WRITEOFF)
     , SUM(fact1.AR_INVOICE_AMOUNT)
     , SUM(fact1.AR_INVOICE_COUNT)
     , SUM(fact1.AR_CASH_APPLIED_AMOUNT)
     , SUM(fact1.AR_INVOICE_WRITE_OFF_AMOUNT)
     , SUM(fact1.AR_INVOICE_WRITEOFF_COUNT)
     , SUM(fact1.AR_CREDIT_MEMO_AMOUNT)
     , SUM(fact1.AR_CREDIT_MEMO_COUNT)
     , SUM(fact1.UNBILLED_RECEIVABLES)
     , SUM(fact1.UNEARNED_REVENUE)
     , SUM(fact1.AR_UNAPPR_INVOICE_AMOUNT)
     , SUM(fact1.AR_UNAPPR_INVOICE_COUNT)
     , SUM(fact1.AR_APPR_INVOICE_AMOUNT)
     , SUM(fact1.AR_APPR_INVOICE_COUNT)
     , SUM(fact1.AR_AMOUNT_DUE)
     , SUM(fact1.AR_COUNT_DUE)
     , SUM(fact1.AR_AMOUNT_OVERDUE)
     , SUM(fact1.AR_COUNT_OVERDUE)
     , SUM(fact1.DORMANT_BACKLOG_INACTIV)
     , SUM(fact1.DORMANT_BACKLOG_START)
     , SUM(fact1.LOST_BACKLOG)
     , SUM(fact1.ACTIVE_BACKLOG)
     , SUM(fact1.REVENUE_AT_RISK)
     , SUM(fact1.CUSTOM1)
     , SUM(fact1.CUSTOM2)
     , SUM(fact1.CUSTOM3)
     , SUM(fact1.CUSTOM4)
     , SUM(fact1.CUSTOM5)
     , SUM(fact1.CUSTOM6)
     , SUM(fact1.CUSTOM7)
     , SUM(fact1.CUSTOM8)
     , SUM(fact1.CUSTOM9)
     , SUM(fact1.CUSTOM10)
     , SUM(fact1.CUSTOM11)
     , SUM(fact1.CUSTOM12)
     , SUM(fact1.CUSTOM13)
     , SUM(fact1.CUSTOM14)
     , SUM(fact1.CUSTOM15)
     , g_default_prg_level prg_level
    FROM
      pji_ac_aggr_pjp1_t fact1
    , pji_time_CAL_PERIOD period
	, pji_time_CAL_QTR    qtr
    WHERE
        fact1.calendar_type = 'P'
    AND period.cal_period_id = fact1.time_id
    AND period.cal_qtr_id = qtr.cal_qtr_id
    AND fact1.period_type_id = 32
    AND fact1.worker_id = g_worker_id
  GROUP BY
       fact1.PROJECT_ID
     , fact1.PROJECT_ORG_ID
     , fact1.PROJECT_ORGANIZATION_ID
     -- -- -- , fact1.PARTITION_ID
     , fact1.PROJECT_ELEMENT_ID
     , fact1.CALENDAR_TYPE
     , rollup (qtr.CAL_YEAR_ID,
               period.CAL_QTR_ID,
               period.CAL_PERIOD_ID)
     , fact1.WBS_ROLLUP_FLAG
     , fact1.PRG_ROLLUP_FLAG
     , fact1.CURR_RECORD_TYPE_ID
     , fact1.CURRENCY_CODE )
   WHERE 1=1
     AND period_type_id > 32
     AND period_type_id < 2048;


EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CREATE_AC_PA_ROLLUP');
    RAISE;
END;


PROCEDURE CREATE_AC_GL_ROLLUP IS
BEGIN

    -- g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;

    INSERT INTO pji_ac_aggr_pjp1_t
    (
       worker_id
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , REVENUE
     , INITIAL_FUNDING_AMOUNT
     , INITIAL_FUNDING_COUNT
     , ADDITIONAL_FUNDING_AMOUNT
     , ADDITIONAL_FUNDING_COUNT
     , CANCELLED_FUNDING_AMOUNT
     , CANCELLED_FUNDING_COUNT
     , FUNDING_ADJUSTMENT_AMOUNT
     , FUNDING_ADJUSTMENT_COUNT
     , REVENUE_WRITEOFF
     , AR_INVOICE_AMOUNT
     , AR_INVOICE_COUNT
     , AR_CASH_APPLIED_AMOUNT
     , AR_INVOICE_WRITE_OFF_AMOUNT
     , AR_INVOICE_WRITEOFF_COUNT
     , AR_CREDIT_MEMO_AMOUNT
     , AR_CREDIT_MEMO_COUNT
     , UNBILLED_RECEIVABLES
     , UNEARNED_REVENUE
     , AR_UNAPPR_INVOICE_AMOUNT
     , AR_UNAPPR_INVOICE_COUNT
     , AR_APPR_INVOICE_AMOUNT
     , AR_APPR_INVOICE_COUNT
     , AR_AMOUNT_DUE
     , AR_COUNT_DUE
     , AR_AMOUNT_OVERDUE
     , AR_COUNT_OVERDUE
     , DORMANT_BACKLOG_INACTIV
     , DORMANT_BACKLOG_START
     , LOST_BACKLOG
     , ACTIVE_BACKLOG
     , REVENUE_AT_RISK
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , PRG_LEVEL
    )
  SELECT * FROM (
    SELECT
      -- GROUPING(qtr.CAL_YEAR_ID)  gy
      -- , GROUPING(period.CAL_QTR_ID)  gq
      -- , GROUPING(period.CAL_PERIOD_ID)  gp
      -- ,
       g_worker_id
     , fact1.PROJECT_ID
     , fact1.PROJECT_ORG_ID
     , fact1.PROJECT_ORGANIZATION_ID
     -- -- -- , fact1.PARTITION_ID
     , fact1.PROJECT_ELEMENT_ID
     , DECODE (
               (grouping(qtr.CAL_YEAR_ID) || grouping(period.CAL_QTR_ID) || grouping(period.CAL_PERIOD_ID) )
             , '000', period.CAL_PERIOD_ID
             , '001', period.CAL_QTR_ID
             , '011', qtr.CAL_YEAR_ID
             , '111', -1 ) TIME_ID
     , DECODE (
               (grouping(qtr.CAL_YEAR_ID) || grouping(period.CAL_QTR_ID) || grouping(period.CAL_PERIOD_ID) )
             , '000', 32
             , '001', 64
             , '011', 128
             , '111', 2048 ) PERIOD_TYPE_ID
     , fact1.CALENDAR_TYPE
     , fact1.WBS_ROLLUP_FLAG
     , fact1.PRG_ROLLUP_FLAG
     , fact1.CURR_RECORD_TYPE_ID
     , fact1.CURRENCY_CODE
     , SUM(fact1.REVENUE )
     , SUM(fact1.INITIAL_FUNDING_AMOUNT )
     , SUM(fact1.INITIAL_FUNDING_COUNT)
     , SUM(fact1.ADDITIONAL_FUNDING_AMOUNT)
     , SUM(fact1.ADDITIONAL_FUNDING_COUNT  )
     , SUM(fact1.CANCELLED_FUNDING_AMOUNT)
     , SUM(fact1.CANCELLED_FUNDING_COUNT)
     , SUM(fact1.FUNDING_ADJUSTMENT_AMOUNT)
     , SUM(fact1.FUNDING_ADJUSTMENT_COUNT)
     , SUM(fact1.REVENUE_WRITEOFF)
     , SUM(fact1.AR_INVOICE_AMOUNT)
     , SUM(fact1.AR_INVOICE_COUNT)
     , SUM(fact1.AR_CASH_APPLIED_AMOUNT)
     , SUM(fact1.AR_INVOICE_WRITE_OFF_AMOUNT)
     , SUM(fact1.AR_INVOICE_WRITEOFF_COUNT)
     , SUM(fact1.AR_CREDIT_MEMO_AMOUNT)
     , SUM(fact1.AR_CREDIT_MEMO_COUNT)
     , SUM(fact1.UNBILLED_RECEIVABLES)
     , SUM(fact1.UNEARNED_REVENUE)
     , SUM(fact1.AR_UNAPPR_INVOICE_AMOUNT)
     , SUM(fact1.AR_UNAPPR_INVOICE_COUNT)
     , SUM(fact1.AR_APPR_INVOICE_AMOUNT)
     , SUM(fact1.AR_APPR_INVOICE_COUNT)
     , SUM(fact1.AR_AMOUNT_DUE)
     , SUM(fact1.AR_COUNT_DUE)
     , SUM(fact1.AR_AMOUNT_OVERDUE)
     , SUM(fact1.AR_COUNT_OVERDUE)
     , SUM(fact1.DORMANT_BACKLOG_INACTIV)
     , SUM(fact1.DORMANT_BACKLOG_START)
     , SUM(fact1.LOST_BACKLOG)
     , SUM(fact1.ACTIVE_BACKLOG)
     , SUM(fact1.REVENUE_AT_RISK)
     , SUM(fact1.CUSTOM1)
     , SUM(fact1.CUSTOM2)
     , SUM(fact1.CUSTOM3)
     , SUM(fact1.CUSTOM4)
     , SUM(fact1.CUSTOM5)
     , SUM(fact1.CUSTOM6)
     , SUM(fact1.CUSTOM7)
     , SUM(fact1.CUSTOM8)
     , SUM(fact1.CUSTOM9)
     , SUM(fact1.CUSTOM10)
     , SUM(fact1.CUSTOM11)
     , SUM(fact1.CUSTOM12)
     , SUM(fact1.CUSTOM13)
     , SUM(fact1.CUSTOM14)
     , SUM(fact1.CUSTOM15)
     , g_default_prg_level prg_level
    FROM
      pji_ac_aggr_pjp1_t fact1
    , pji_time_CAL_PERIOD period
	, pji_time_CAL_QTR    qtr
    WHERE
          fact1.calendar_type = 'G'
      AND period.cal_period_id = fact1.time_id
	AND period.cal_qtr_id = qtr.cal_qtr_id
      AND fact1.period_type_id = 32
      AND fact1.worker_id = g_worker_id
    GROUP BY
       fact1.PROJECT_ID
     , fact1.PROJECT_ORG_ID
     , fact1.PROJECT_ORGANIZATION_ID
     -- -- -- , fact1.PARTITION_ID
     , fact1.PROJECT_ELEMENT_ID
     , fact1.CALENDAR_TYPE
     , rollup (qtr.CAL_YEAR_ID,
               period.CAL_QTR_ID,
               period.CAL_PERIOD_ID)
     , fact1.WBS_ROLLUP_FLAG
     , fact1.PRG_ROLLUP_FLAG
     , fact1.CURR_RECORD_TYPE_ID
     , fact1.CURRENCY_CODE )
   WHERE 1=1
     AND period_type_id > 32
     AND period_type_id < 2048;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CREATE_AC_GL_ROLLUP');
    RAISE;
END;


PROCEDURE CREATE_AC_ENT_ROLLUP IS
BEGIN

  -- g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;

  INSERT INTO pji_ac_aggr_pjp1_t
  (
       worker_id
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , REVENUE
     , INITIAL_FUNDING_AMOUNT
     , INITIAL_FUNDING_COUNT
     , ADDITIONAL_FUNDING_AMOUNT
     , ADDITIONAL_FUNDING_COUNT
     , CANCELLED_FUNDING_AMOUNT
     , CANCELLED_FUNDING_COUNT
     , FUNDING_ADJUSTMENT_AMOUNT
     , FUNDING_ADJUSTMENT_COUNT
     , REVENUE_WRITEOFF
     , AR_INVOICE_AMOUNT
     , AR_INVOICE_COUNT
     , AR_CASH_APPLIED_AMOUNT
     , AR_INVOICE_WRITE_OFF_AMOUNT
     , AR_INVOICE_WRITEOFF_COUNT
     , AR_CREDIT_MEMO_AMOUNT
     , AR_CREDIT_MEMO_COUNT
     , UNBILLED_RECEIVABLES
     , UNEARNED_REVENUE
     , AR_UNAPPR_INVOICE_AMOUNT
     , AR_UNAPPR_INVOICE_COUNT
     , AR_APPR_INVOICE_AMOUNT
     , AR_APPR_INVOICE_COUNT
     , AR_AMOUNT_DUE
     , AR_COUNT_DUE
     , AR_AMOUNT_OVERDUE
     , AR_COUNT_OVERDUE
     , DORMANT_BACKLOG_INACTIV
     , DORMANT_BACKLOG_START
     , LOST_BACKLOG
     , ACTIVE_BACKLOG
     , REVENUE_AT_RISK
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , PRG_LEVEL
  )
  SELECT * FROM (
  SELECT
      -- GROUPING(qtr.CAL_YEAR_ID)  gy
      -- , GROUPING(period.CAL_QTR_ID)  gq
      -- , GROUPING(period.CAL_PERIOD_ID)  gp
      -- ,
       g_worker_id
     , fact1.PROJECT_ID
     , fact1.PROJECT_ORG_ID
     , fact1.PROJECT_ORGANIZATION_ID
     -- -- -- , fact1.PARTITION_ID
     , fact1.PROJECT_ELEMENT_ID
     , DECODE (
               (grouping(qtr.ENT_YEAR_ID) || grouping(period.ENT_QTR_ID) || grouping(period.ENT_PERIOD_ID) )
             , '000', period.ENT_PERIOD_ID
             , '001', period.ENT_QTR_ID
             , '011', qtr.ENT_YEAR_ID
             , '111', -1 ) TIME_ID
     , DECODE (
               (grouping(qtr.ENT_YEAR_ID) || grouping(period.ENT_QTR_ID) || grouping(period.ENT_PERIOD_ID) )
             , '000', 32
             , '001', 64
             , '011', 128
             , '111', 2048 ) PERIOD_TYPE_ID
     , fact1.CALENDAR_TYPE
     , fact1.WBS_ROLLUP_FLAG
     , fact1.PRG_ROLLUP_FLAG
     , fact1.CURR_RECORD_TYPE_ID
     , fact1.CURRENCY_CODE
     , SUM(fact1.REVENUE )
     , SUM(fact1.INITIAL_FUNDING_AMOUNT )
     , SUM(fact1.INITIAL_FUNDING_COUNT)
     , SUM(fact1.ADDITIONAL_FUNDING_AMOUNT)
     , SUM(fact1.ADDITIONAL_FUNDING_COUNT  )
     , SUM(fact1.CANCELLED_FUNDING_AMOUNT)
     , SUM(fact1.CANCELLED_FUNDING_COUNT)
     , SUM(fact1.FUNDING_ADJUSTMENT_AMOUNT)
     , SUM(fact1.FUNDING_ADJUSTMENT_COUNT)
     , SUM(fact1.REVENUE_WRITEOFF)
     , SUM(fact1.AR_INVOICE_AMOUNT)
     , SUM(fact1.AR_INVOICE_COUNT)
     , SUM(fact1.AR_CASH_APPLIED_AMOUNT)
     , SUM(fact1.AR_INVOICE_WRITE_OFF_AMOUNT)
     , SUM(fact1.AR_INVOICE_WRITEOFF_COUNT)
     , SUM(fact1.AR_CREDIT_MEMO_AMOUNT)
     , SUM(fact1.AR_CREDIT_MEMO_COUNT)
     , SUM(fact1.UNBILLED_RECEIVABLES)
     , SUM(fact1.UNEARNED_REVENUE)
     , SUM(fact1.AR_UNAPPR_INVOICE_AMOUNT)
     , SUM(fact1.AR_UNAPPR_INVOICE_COUNT)
     , SUM(fact1.AR_APPR_INVOICE_AMOUNT)
     , SUM(fact1.AR_APPR_INVOICE_COUNT)
     , SUM(fact1.AR_AMOUNT_DUE)
     , SUM(fact1.AR_COUNT_DUE)
     , SUM(fact1.AR_AMOUNT_OVERDUE)
     , SUM(fact1.AR_COUNT_OVERDUE)
     , SUM(fact1.DORMANT_BACKLOG_INACTIV)
     , SUM(fact1.DORMANT_BACKLOG_START)
     , SUM(fact1.LOST_BACKLOG)
     , SUM(fact1.ACTIVE_BACKLOG)
     , SUM(fact1.REVENUE_AT_RISK)
     , SUM(fact1.CUSTOM1)
     , SUM(fact1.CUSTOM2)
     , SUM(fact1.CUSTOM3)
     , SUM(fact1.CUSTOM4)
     , SUM(fact1.CUSTOM5)
     , SUM(fact1.CUSTOM6)
     , SUM(fact1.CUSTOM7)
     , SUM(fact1.CUSTOM8)
     , SUM(fact1.CUSTOM9)
     , SUM(fact1.CUSTOM10)
     , SUM(fact1.CUSTOM11)
     , SUM(fact1.CUSTOM12)
     , SUM(fact1.CUSTOM13)
     , SUM(fact1.CUSTOM14)
     , SUM(fact1.CUSTOM15)
     , g_default_prg_level prg_level
    FROM
	   pji_ac_aggr_pjp1_t fact1
     , pji_time_ENT_PERIOD period
 	 , pji_time_ENT_QTR    qtr
    WHERE
        fact1.calendar_type = 'E'
    AND period.ENT_period_id = fact1.time_id
    AND period.ENT_qtr_id = qtr.ENT_qtr_id
    AND fact1.period_type_id = 32
    AND fact1.worker_id = g_worker_id
  GROUP BY
       fact1.PROJECT_ID
     , fact1.PROJECT_ORG_ID
     , fact1.PROJECT_ORGANIZATION_ID
     -- -- -- , fact1.PARTITION_ID
     , fact1.PROJECT_ELEMENT_ID
     , fact1.CALENDAR_TYPE
     , fact1.WBS_ROLLUP_FLAG
     , fact1.PRG_ROLLUP_FLAG
     , fact1.CURR_RECORD_TYPE_ID
     , fact1.CURRENCY_CODE
     , rollup (qtr.ENT_YEAR_ID,
              period.ENT_QTR_ID,
              period.ENT_PERIOD_ID))
   WHERE 1=1
     AND period_type_id > 32
     AND period_type_id < 2048;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CREATE_AC_ENT_ROLLUP');
    RAISE;
END;



PROCEDURE CREATE_AC_ALL_T_PRI_ROLLUP (
  p_calendar_type IN VARCHAR2 := 'G' ) IS
    -- l_last_update_date     date   := SYSDATE;
    -- l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
    -- l_creation_date        date   := SYSDATE;
    -- l_created_by           NUMBER := FND_GLOBAL.USER_ID;
    l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;
    l_line_type            VARCHAR2(15);

BEGIN

  -- g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;

  IF (p_calendar_type NOT IN ('P', 'G') ) THEN
    RETURN;
  ELSE
    IF (p_calendar_type = 'P') THEN
      l_line_type := 'PAR';
    ELSE
      l_line_type := 'GLR';
    END IF;
  END IF;

    INSERT INTO PJI_AC_AGGR_PJP1_T
    (
       worker_id
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , REVENUE
     , INITIAL_FUNDING_AMOUNT
     , INITIAL_FUNDING_COUNT
     , ADDITIONAL_FUNDING_AMOUNT
     , ADDITIONAL_FUNDING_COUNT
     , CANCELLED_FUNDING_AMOUNT
     , CANCELLED_FUNDING_COUNT
     , FUNDING_ADJUSTMENT_AMOUNT
     , FUNDING_ADJUSTMENT_COUNT
     , REVENUE_WRITEOFF
     , AR_INVOICE_AMOUNT
     , AR_INVOICE_COUNT
     , AR_CASH_APPLIED_AMOUNT
     , AR_INVOICE_WRITE_OFF_AMOUNT
     , AR_INVOICE_WRITEOFF_COUNT
     , AR_CREDIT_MEMO_AMOUNT
     , AR_CREDIT_MEMO_COUNT
     , UNBILLED_RECEIVABLES
     , UNEARNED_REVENUE
     , AR_UNAPPR_INVOICE_AMOUNT
     , AR_UNAPPR_INVOICE_COUNT
     , AR_APPR_INVOICE_AMOUNT
     , AR_APPR_INVOICE_COUNT
     , AR_AMOUNT_DUE
     , AR_COUNT_DUE
     , AR_AMOUNT_OVERDUE
     , AR_COUNT_OVERDUE
     , DORMANT_BACKLOG_INACTIV
     , DORMANT_BACKLOG_START
     , LOST_BACKLOG
     , ACTIVE_BACKLOG
     , REVENUE_AT_RISK
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , PRG_LEVEL
    )
  SELECT * FROM (
    SELECT
      -- GROUPING(qtr.CAL_YEAR_ID)  gy
      -- , GROUPING(period.CAL_QTR_ID)  gq
      -- , GROUPING(period.CAL_PERIOD_ID)  gp
      -- ,
       g_worker_id
     , fact1.PROJECT_ID
     , fact1.PROJECT_ORG_ID
     , fact1.PROJECT_ORGANIZATION_ID
     -- -- -- , fact1.PARTITION_ID
     , fact1.PROJECT_ELEMENT_ID
     , DECODE (
               (grouping(qtr.CAL_YEAR_ID) || grouping(period.CAL_QTR_ID) || grouping(period.CAL_PERIOD_ID) )
             , '000', period.CAL_PERIOD_ID
             , '001', period.CAL_QTR_ID
             , '011', qtr.CAL_YEAR_ID
             , '111', -1 ) TIME_ID
     , DECODE (
               (grouping(qtr.CAL_YEAR_ID) || grouping(period.CAL_QTR_ID) || grouping(period.CAL_PERIOD_ID) )
             , '000', 32
             , '001', 64
             , '011', 128
             , '111', 2048 ) PERIOD_TYPE_ID
     , fact1.CALENDAR_TYPE
     , fact1.WBS_ROLLUP_FLAG
     , fact1.PRG_ROLLUP_FLAG
     , fact1.CURR_RECORD_TYPE_ID
     , fact1.CURRENCY_CODE
     , SUM(fact1.REVENUE )
     , SUM(fact1.INITIAL_FUNDING_AMOUNT )
     , SUM(fact1.INITIAL_FUNDING_COUNT)
     , SUM(fact1.ADDITIONAL_FUNDING_AMOUNT)
     , SUM(fact1.ADDITIONAL_FUNDING_COUNT  )
     , SUM(fact1.CANCELLED_FUNDING_AMOUNT)
     , SUM(fact1.CANCELLED_FUNDING_COUNT)
     , SUM(fact1.FUNDING_ADJUSTMENT_AMOUNT)
     , SUM(fact1.FUNDING_ADJUSTMENT_COUNT)
     , SUM(fact1.REVENUE_WRITEOFF)
     , SUM(fact1.AR_INVOICE_AMOUNT)
     , SUM(fact1.AR_INVOICE_COUNT)
     , SUM(fact1.AR_CASH_APPLIED_AMOUNT)
     , SUM(fact1.AR_INVOICE_WRITE_OFF_AMOUNT)
     , SUM(fact1.AR_INVOICE_WRITEOFF_COUNT)
     , SUM(fact1.AR_CREDIT_MEMO_AMOUNT)
     , SUM(fact1.AR_CREDIT_MEMO_COUNT)
     , SUM(fact1.UNBILLED_RECEIVABLES)
     , SUM(fact1.UNEARNED_REVENUE)
     , SUM(fact1.AR_UNAPPR_INVOICE_AMOUNT)
     , SUM(fact1.AR_UNAPPR_INVOICE_COUNT)
     , SUM(fact1.AR_APPR_INVOICE_AMOUNT)
     , SUM(fact1.AR_APPR_INVOICE_COUNT)
     , SUM(fact1.AR_AMOUNT_DUE)
     , SUM(fact1.AR_COUNT_DUE)
     , SUM(fact1.AR_AMOUNT_OVERDUE)
     , SUM(fact1.AR_COUNT_OVERDUE)
     , SUM(fact1.DORMANT_BACKLOG_INACTIV)
     , SUM(fact1.DORMANT_BACKLOG_START)
     , SUM(fact1.LOST_BACKLOG)
     , SUM(fact1.ACTIVE_BACKLOG)
     , SUM(fact1.REVENUE_AT_RISK)
     , SUM(fact1.CUSTOM1)
     , SUM(fact1.CUSTOM2)
     , SUM(fact1.CUSTOM3)
     , SUM(fact1.CUSTOM4)
     , SUM(fact1.CUSTOM5)
     , SUM(fact1.CUSTOM6)
     , SUM(fact1.CUSTOM7)
     , SUM(fact1.CUSTOM8)
     , SUM(fact1.CUSTOM9)
     , SUM(fact1.CUSTOM10)
     , SUM(fact1.CUSTOM11)
     , SUM(fact1.CUSTOM12)
     , SUM(fact1.CUSTOM13)
     , SUM(fact1.CUSTOM14)
     , SUM(fact1.CUSTOM15)
     , g_default_prg_level prg_level
    FROM
      PJI_AC_AGGR_PJP1_T fact1
    , pji_time_CAL_PERIOD period
	, pji_time_CAL_QTR    qtr
    WHERE
          fact1.calendar_type = p_calendar_type
      AND period.cal_period_id = fact1.time_id
	AND period.cal_qtr_id = qtr.cal_qtr_id
      AND fact1.period_type_id = 32
      AND fact1.worker_id = g_worker_id
    GROUP BY
       fact1.PROJECT_ID
     , fact1.PROJECT_ORG_ID
     , fact1.PROJECT_ORGANIZATION_ID
     -- -- -- , fact1.PARTITION_ID
     , fact1.PROJECT_ELEMENT_ID
     , fact1.CALENDAR_TYPE
     , rollup (qtr.CAL_YEAR_ID,
               period.CAL_QTR_ID,
               period.CAL_PERIOD_ID)
     , fact1.WBS_ROLLUP_FLAG
     , fact1.PRG_ROLLUP_FLAG
     , fact1.CURR_RECORD_TYPE_ID
     , fact1.CURRENCY_CODE )
   WHERE 1=1
     AND period_type_id = 2048;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'CREATE_AC_ALL_T_PRI_ROLLUP');
    RAISE;
END;


--
-- Prorate PA, GL entered entries in pjp1 table.
--
PROCEDURE PRORATE_TO_ENT_PG_PJP1_D IS
BEGIN

    -- g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;

/* Commented for bug 4005006
    INSERT INTO pji_fp_aggr_pjp1_t
    (
       WORKER_ID
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , LINE_TYPE
     , TIME_DANGLING_FLAG
     , RATE_DANGLING_FLAG
     , PRG_LEVEL
	)
   SELECT
       g_worker_id worker_id
     , a.PROJECT_ID
     , a.PROJECT_ORG_ID
     , a.PROJECT_ORGANIZATION_ID
     , a.PROJECT_ELEMENT_ID
     , a.TIME_ID
     , a.PERIOD_TYPE_ID
     , a.CALENDAR_TYPE
     , a.RBS_AGGR_LEVEL
     , a.WBS_ROLLUP_FLAG
     , a.PRG_ROLLUP_FLAG
     , a.CURR_RECORD_TYPE_ID
     , a.CURRENCY_CODE
     , a.RBS_ELEMENT_ID
     , a.RBS_VERSION_ID
     , a.PLAN_VERSION_ID
     , a.PLAN_TYPE_ID
     , SUM(a.RAW_COST       )
     , SUM(a.BRDN_COST 	)
     , SUM(a.REVENUE	)
     , SUM(a.BILL_RAW_COST )
     , SUM(a.BILL_BRDN_COST )
     , SUM(a.BILL_LABOR_RAW_COST )
     , SUM(a.BILL_LABOR_BRDN_COST )
     , SUM(a.BILL_LABOR_HRS )
     , SUM(a.EQUIPMENT_RAW_COST )
     , SUM(a.EQUIPMENT_BRDN_COST )
     , SUM(a.CAPITALIZABLE_RAW_COST )
     , SUM(a.CAPITALIZABLE_BRDN_COST )
     , SUM(a.LABOR_RAW_COST )
     , SUM(a.LABOR_BRDN_COST)
     , SUM(a.LABOR_HRS )
     , SUM(a.LABOR_REVENUE )
     , SUM(a.EQUIPMENT_HOURS )
     , SUM(a.BILLABLE_EQUIPMENT_HOURS)
     , SUM(a.SUP_INV_COMMITTED_COST)
     , SUM(a.PO_COMMITTED_COST )
     , SUM(a.PR_COMMITTED_COST )
     , SUM(a.OTH_COMMITTED_COST)
       , SUM(a.ACT_LABOR_HRS)
	   , SUM(a.ACT_EQUIP_HRS)
	   , SUM(a.ACT_LABOR_BRDN_COST)
	   , SUM(a.ACT_EQUIP_BRDN_COST)
	   , SUM(a.ACT_BRDN_COST    )
	   , SUM(a.ACT_RAW_COST    )
	   , SUM(a.ACT_REVENUE    )
         , SUM(a.ACT_LABOR_RAW_COST)
         , SUM(a.ACT_EQUIP_RAW_COST)
	   , SUM(a.ETC_LABOR_HRS         )
	   , SUM(a.ETC_EQUIP_HRS        )
	   , SUM(a.ETC_LABOR_BRDN_COST )
	   , SUM(a.ETC_EQUIP_BRDN_COST)
	   , SUM(a.ETC_BRDN_COST )
         , SUM(a.ETC_RAW_COST)
         , SUM(a.ETC_LABOR_RAW_COST)
         , SUM(a.ETC_EQUIP_RAW_COST)
     , SUM(a.CUSTOM1	)
     , SUM(a.CUSTOM2	)
     , SUM(a.CUSTOM3	)
     , SUM(a.CUSTOM4	)
     , SUM(a.CUSTOM5	)
     , SUM(a.CUSTOM6	)
     , SUM(a.CUSTOM7	)
     , SUM(a.CUSTOM8	)
     , SUM(a.CUSTOM9	)
     , SUM(a.CUSTOM10	)
     , SUM(a.CUSTOM11	)
     , SUM(a.CUSTOM12	)
     , SUM(a.CUSTOM13	)
     , SUM(a.CUSTOM14	)
     , SUM(a.CUSTOM15	)
     , a.LINE_TYPE
     , a.TIME_DANGLING_FLAG
     , a.RATE_DANGLING_FLAG
     , g_default_prg_level prg_level
   FROM (
   SELECT
         fact.project_id  project_id
   	 , fact.project_ORG_ID project_ORG_ID
   	 , fact.project_ORGANIZATION_ID project_ORGANIZATION_ID
     -- , fact.PARTITION_ID PARTITION_ID
   	 , fact.PROJECT_ELEMENT_ID PROJECT_ELEMENT_ID
   	 , pa_cal.ent_period_id TIME_ID
   	 , fact.PERIOD_TYPE_ID PERIOD_TYPE_ID
   	 , 'E' CALENDAR_TYPE -- fact.CALENDAR_TYPE
     , fact.RBS_AGGR_LEVEL
     , fact.WBS_ROLLUP_FLAG
     , fact.PRG_ROLLUP_FLAG
   	 , fact.CURR_RECORD_TYPE_ID CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID PLAN_VERSION_ID
	 , fact.PLAN_TYPE_ID  PLAN_TYPE_ID
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.raw_cost
			  , '1-1'  , fact.raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			 , '00'   , fact.brdn_cost
			 , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '0-1'  , fact.brdn_cost
			 , '1-1'  , fact.brdn_cost
			 , 0  ) -- end decode
			  , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			 , '00'   , fact.revenue
			 , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '0-1'  , fact.revenue
			 , '1-1'  , fact.revenue
			 , 0  ) -- end decode
			  , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	revenue
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.bill_raw_cost
			  , '1-1'  , fact.bill_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.bill_brdn_cost
			  , '1-1'  , fact.bill_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_labor_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.bill_labor_raw_cost
			  , '1-1'  , fact.bill_labor_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_labor_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_labor_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.bill_labor_brdn_cost
			  , '1-1'  , fact.bill_labor_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_labor_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_labor_hrs
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.bill_labor_hrs
			  , '1-1'  , fact.bill_labor_hrs
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_labor_hrs
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.equipment_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.equipment_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.equipment_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.equipment_raw_cost
			  , '1-1'  , fact.equipment_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	equipment_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.equipment_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.equipment_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.equipment_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.equipment_brdn_cost
			  , '1-1'  , fact.equipment_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	equipment_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.capitalizable_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.capitalizable_raw_cost
			  , '1-1'  , fact.capitalizable_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	capitalizable_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.capitalizable_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.capitalizable_brdn_cost
			  , '1-1'  , fact.capitalizable_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	capitalizable_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.labor_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.labor_raw_cost
			  , '1-1'  , fact.labor_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	labor_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.labor_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.labor_brdn_cost
			  , '1-1'  , fact.labor_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	labor_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.labor_hrs
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.labor_hrs
			  , '1-1'  , fact.labor_hrs
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	labor_hrs
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.labor_revenue
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.labor_revenue
			  , '1-1'  , fact.labor_revenue
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	labor_revenue
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.equipment_hours
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.equipment_hours
			  , '1-1'  , fact.equipment_hours
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	equipment_hours
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.billable_equipment_hours
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.billable_equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.billable_equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.billable_equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.billable_equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.billable_equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.billable_equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.billable_equipment_hours
			  , '1-1'  , fact.billable_equipment_hours
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	billable_equipment_hours
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.sup_inv_committed_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.sup_inv_committed_cost
			  , '1-1'  , fact.sup_inv_committed_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	sup_inv_committed_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.po_committed_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.po_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.po_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.po_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.po_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.po_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.po_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.po_committed_cost
			  , '1-1'  , fact.po_committed_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	po_committed_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.pr_committed_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.pr_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.pr_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.pr_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.pr_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.pr_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.pr_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.pr_committed_cost
			  , '1-1'  , fact.pr_committed_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	pr_committed_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.oth_committed_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.oth_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.oth_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.oth_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.oth_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.oth_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.oth_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.oth_committed_cost
			  , '1-1'  , fact.oth_committed_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	oth_committed_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_LABOR_HRS
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_LABOR_HRS
			  , '1-1'  , fact.ACT_LABOR_HRS
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_LABOR_HRS
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_EQUIP_HRS
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_EQUIP_HRS
			  , '1-1'  , fact.ACT_EQUIP_HRS
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_EQUIP_HRS
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_LABOR_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_LABOR_BRDN_COST
			  , '1-1'  , fact.ACT_LABOR_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_LABOR_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_EQUIP_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_EQUIP_BRDN_COST
			  , '1-1'  , fact.ACT_EQUIP_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_EQUIP_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_BRDN_COST
			  , '1-1'  , fact.ACT_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_RAW_COST
			  , '1-1'  , fact.ACT_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_REVENUE
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_REVENUE / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_REVENUE / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_REVENUE / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_REVENUE / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_REVENUE / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_REVENUE / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_REVENUE
			  , '1-1'  , fact.ACT_REVENUE
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_REVENUE
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_LABOR_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_LABOR_RAW_COST
			  , '1-1'  , fact.ACT_LABOR_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_LABOR_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_EQUIP_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_EQUIP_RAW_COST
			  , '1-1'  , fact.ACT_EQUIP_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_EQUIP_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_LABOR_HRS
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_LABOR_HRS
			  , '1-1'  , fact.ETC_LABOR_HRS
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_LABOR_HRS
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_EQUIP_HRS
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_EQUIP_HRS
			  , '1-1'  , fact.ETC_EQUIP_HRS
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_EQUIP_HRS
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_LABOR_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_LABOR_BRDN_COST
			  , '1-1'  , fact.ETC_LABOR_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_LABOR_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_EQUIP_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_EQUIP_BRDN_COST
			  , '1-1'  , fact.ETC_EQUIP_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_EQUIP_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_BRDN_COST
			  , '1-1'  , fact.ETC_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_RAW_COST
			  , '1-1'  , fact.ETC_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_LABOR_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_LABOR_RAW_COST
			  , '1-1'  , fact.ETC_LABOR_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_LABOR_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_EQUIP_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_EQUIP_RAW_COST
			  , '1-1'  , fact.ETC_EQUIP_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_EQUIP_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom1
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom1 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom1 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom1 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom1 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom1 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom1 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom1
			  , '1-1'  , fact.custom1
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom1
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom2
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom2 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom2 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom2 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom2 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom2 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom2 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom2
			  , '1-1'  , fact.custom2
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom2
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom3
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom3 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom3 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom3 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom3 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom3 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom3 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom3
			  , '1-1'  , fact.custom3
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom3
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom4
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom4 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom4 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom4 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom4 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom4 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom4 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom4
			  , '1-1'  , fact.custom4
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom4
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom5
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom5 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom5 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom5 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom5 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom5 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom5 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom5
			  , '1-1'  , fact.custom5
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom5
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom6
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom6 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom6 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom6 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom6 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom6 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom6 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom6
			  , '1-1'  , fact.custom6
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom6
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom7
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom7 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom7 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom7 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom7 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom7 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom7 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom7
			  , '1-1'  , fact.custom7
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom7
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom8
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom8 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom8 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom8 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom8 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom8 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom8 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom8
			  , '1-1'  , fact.custom8
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom8
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom9
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom9 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom9 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom9 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom9 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom9 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom9 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom9
			  , '1-1'  , fact.custom9
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom9
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom10
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom10 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom10 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom10 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom10 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom10 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom10 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom10
			  , '1-1'  , fact.custom10
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom10
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom11
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom11 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom11 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom11 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom11 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom11 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom11 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom11
			  , '1-1'  , fact.custom11
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom11
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom12
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom12 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom12 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom12 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom12 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom12 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom12 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom12
			  , '1-1'  , fact.custom12
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom12
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom13
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom13 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom13 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom13 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom13 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom13 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom13 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom13
			  , '1-1'  , fact.custom13
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom13
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom14
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom14 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom14 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom14 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom14 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom14 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom14 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom14
			  , '1-1'  , fact.custom14
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom14
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom15
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom15 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom15 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom15 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom15 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom15 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom15 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom15
			  , '1-1'  , fact.custom15
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom15
     , 'CF'   line_type
     , fact.time_dangling_flag time_dangling_flag
     , fact.rate_dangling_flag rate_dangling_flag
     , g_default_prg_level prg_level
   FROM   pji_fp_aggr_pjp1_t fact
        , pji_time_cal_period  non_pa_cal
   	 , pji_time_ent_period  pa_cal
       , pji_fm_extr_plnver3_t  ver
   WHERE  fact.CALENDAR_TYPE IN ('P', 'G')
      AND fact.worker_id = g_worker_id
      AND non_pa_cal.cal_period_id = fact.time_id
      AND fact.line_type like 'OF%'
      AND (
	       ( pa_cal.start_date >= non_pa_cal.start_date  AND pa_cal.end_date <= non_pa_cal.end_date )
	    OR ( pa_cal.start_date <= non_pa_cal.start_date  AND pa_cal.end_date >= non_pa_cal.end_date )
	    OR ( pa_cal.start_date <= non_pa_cal.start_date  AND pa_cal.end_date <= non_pa_cal.end_date AND pa_cal.end_date >= non_pa_cal.start_date )
	    OR ( pa_cal.start_date >= non_pa_cal.start_date  AND pa_cal.end_date >= non_pa_cal.end_date AND pa_cal.start_date <= non_pa_cal.end_date )
          )
      AND fact.time_dangling_flag IS NULL
      AND fact.rate_dangling_flag IS NULL
      AND fact.period_type_id = 32
      AND fact.plan_version_id = ver.plan_version_id
      AND ver.wp_flag = 'N'
      AND ver.baselined_flag = 'Y'
	-- AND ( ver.rbs_struct_version_id = fact.rbs_version_id  OR fact.rbs_version_id = -1)
      AND NVL(ver.rbs_struct_version_id, -1) = fact.rbs_version_id
	  ) a
	  GROUP BY
	   a.PROJECT_ID
     , a.PROJECT_ORG_ID
     , a.PROJECT_ORGANIZATION_ID
     , a.PROJECT_ELEMENT_ID
     , a.TIME_ID
     , a.PERIOD_TYPE_ID
     , a.CALENDAR_TYPE
     , a.RBS_AGGR_LEVEL
     , a.WBS_ROLLUP_FLAG
     , a.PRG_ROLLUP_FLAG
     , a.CURR_RECORD_TYPE_ID
     , a.CURRENCY_CODE
     , a.RBS_ELEMENT_ID
     , a.RBS_VERSION_ID
     , a.PLAN_VERSION_ID
     , a.PLAN_TYPE_ID

	 , a.LINE_TYPE
	 , a.TIME_DANGLING_FLAG
	 , a.RATE_DANGLING_FLAG;
 End of 4005006*/

    INSERT INTO pji_fp_aggr_pjp1_t
    (
       WORKER_ID
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
     , ACT_LABOR_HRS
     , ACT_EQUIP_HRS
     , ACT_LABOR_BRDN_COST
     , ACT_EQUIP_BRDN_COST
     , ACT_BRDN_COST
     , ACT_RAW_COST
     , ACT_REVENUE
     , ACT_LABOR_RAW_COST
     , ACT_EQUIP_RAW_COST
     , ETC_LABOR_HRS
     , ETC_EQUIP_HRS
     , ETC_LABOR_BRDN_COST
     , ETC_EQUIP_BRDN_COST
     , ETC_BRDN_COST
     , ETC_RAW_COST
     , ETC_LABOR_RAW_COST
     , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , TIME_DANGLING_FLAG
     , RATE_DANGLING_FLAG
     , PRG_LEVEL
     , PLAN_TYPE_CODE    /* 4471527 */
	)
   SELECT
           g_worker_id worker_id
         , a.PROJECT_ID
         , a.PROJECT_ORG_ID
         , a.PROJECT_ORGANIZATION_ID
         , a.PROJECT_ELEMENT_ID
         , a.TIME_ID
         , a.PERIOD_TYPE_ID
         , a.CALENDAR_TYPE
         , a.RBS_AGGR_LEVEL
         , a.WBS_ROLLUP_FLAG
         , a.PRG_ROLLUP_FLAG
         , a.CURR_RECORD_TYPE_ID
         , a.CURRENCY_CODE
         , a.RBS_ELEMENT_ID
         , a.RBS_VERSION_ID
         , a.PLAN_VERSION_ID
         , a.PLAN_TYPE_ID
	 , SUM(ROUND (nvl(a.raw_cost,0)*a.factor/a.mau)*a.mau) raw_cost
	 , SUM(ROUND (nvl(a.brdn_cost,0)*a.factor/a.mau)*a.mau) brdn_cost
	 , SUM(ROUND (nvl(a.revenue,0)*a.factor/a.mau)*a.mau) revenue
	 , SUM(ROUND (nvl(a.bill_raw_cost,0)*a.factor/a.mau)*a.mau) bill_raw_cost
	 , SUM(ROUND (nvl(a.bill_brdn_cost,0)*a.factor/a.mau)*a.mau) bill_brdn_cost
	 , SUM(ROUND (nvl(a.bill_labor_raw_cost,0)*a.factor/a.mau)*a.mau) bill_labor_raw_cost
	 , SUM(ROUND (nvl(a.bill_labor_brdn_cost,0)*a.factor/a.mau)*a.mau) bill_labor_brdn_cost
	 , SUM(ROUND (nvl(a.bill_labor_hrs,0)*a.factor/a.mau)*a.mau) bill_labor_hrs
	 , SUM(ROUND (nvl(a.equipment_raw_cost,0)*a.factor/a.mau)*a.mau) equipment_raw_cost
	 , SUM(ROUND (nvl(a.equipment_brdn_cost,0)*a.factor/a.mau)*a.mau) equipment_brdn_cost
	 , SUM(ROUND (nvl(a.capitalizable_raw_cost,0)*a.factor/a.mau)*a.mau) capitalizable_raw_cost
	 , SUM(ROUND (nvl(a.capitalizable_brdn_cost,0)*a.factor/a.mau)*a.mau) capitalizable_brdn_cost
	 , SUM(ROUND (nvl(a.labor_raw_cost,0)*a.factor/a.mau)*a.mau) labor_raw_cost
	 , SUM(ROUND (nvl(a.labor_brdn_cost,0)*a.factor/a.mau)*a.mau) labor_brdn_cost
	 , SUM(ROUND (nvl(a.labor_hrs,0)*a.factor/a.mau)*a.mau) labor_hrs
	 , SUM(ROUND (nvl(a.labor_revenue,0)*a.factor/a.mau)*a.mau) labor_revenue
	 , SUM(ROUND (nvl(a.equipment_hours,0)*a.factor/a.mau)*a.mau) equipment_hours
	 , SUM(ROUND (nvl(a.billable_equipment_hours,0)*a.factor/a.mau)*a.mau) billable_equipment_hours
	 , SUM(ROUND (nvl(a.sup_inv_committed_cost,0)*a.factor/a.mau)*a.mau) sup_inv_committed_cost
	 , SUM(ROUND (nvl(a.po_committed_cost,0)*a.factor/a.mau)*a.mau) po_committed_cost
	 , SUM(ROUND (nvl(a.pr_committed_cost,0)*a.factor/a.mau)*a.mau) pr_committed_cost
	 , SUM(ROUND (nvl(a.oth_committed_cost,0)*a.factor/a.mau)*a.mau) oth_committed_cost
	 , SUM(ROUND (nvl(a.ACT_LABOR_HRS,0)*a.factor/a.mau)*a.mau) ACT_LABOR_HRS
	 , SUM(ROUND (nvl(a.ACT_EQUIP_HRS,0)*a.factor/a.mau)*a.mau) ACT_EQUIP_HRS
	 , SUM(ROUND (nvl(a.ACT_LABOR_BRDN_COST,0)*a.factor/a.mau)*a.mau) ACT_LABOR_BRDN_COST
	 , SUM(ROUND (nvl(a.ACT_EQUIP_BRDN_COST,0)*a.factor/a.mau)*a.mau) ACT_EQUIP_BRDN_COST
	 , SUM(ROUND (nvl(a.ACT_BRDN_COST,0)*a.factor/a.mau)*a.mau) ACT_BRDN_COST
	 , SUM(ROUND (nvl(a.ACT_RAW_COST,0)*a.factor/a.mau)*a.mau) ACT_RAW_COST
	 , SUM(ROUND (nvl(a.ACT_REVENUE,0)*a.factor/a.mau)*a.mau) ACT_REVENUE
	 , SUM(ROUND (nvl(a.ACT_LABOR_RAW_COST,0)*a.factor/a.mau)*a.mau) ACT_LABOR_RAW_COST
	 , SUM(ROUND (nvl(a.ACT_EQUIP_RAW_COST,0)*a.factor/a.mau)*a.mau) ACT_EQUIP_RAW_COST
	 , SUM(ROUND (nvl(a.ETC_LABOR_HRS,0)*a.factor/a.mau)*a.mau) ETC_LABOR_HRS
	 , SUM(ROUND (nvl(a.ETC_EQUIP_HRS,0)*a.factor/a.mau)*a.mau) ETC_EQUIP_HRS
	 , SUM(ROUND (nvl(a.ETC_LABOR_BRDN_COST,0)*a.factor/a.mau)*a.mau) ETC_LABOR_BRDN_COST
	 , SUM(ROUND (nvl(a.ETC_EQUIP_BRDN_COST,0)*a.factor/a.mau)*a.mau) ETC_EQUIP_BRDN_COST
	 , SUM(ROUND (nvl(a.ETC_BRDN_COST,0)*a.factor/a.mau)*a.mau) ETC_BRDN_COST
	 , SUM(ROUND (nvl(a.ETC_RAW_COST,0)*a.factor/a.mau)*a.mau) ETC_RAW_COST
	 , SUM(ROUND (nvl(a.ETC_LABOR_RAW_COST,0)*a.factor/a.mau)*a.mau) ETC_LABOR_RAW_COST
	 , SUM(ROUND (nvl(a.ETC_EQUIP_RAW_COST,0)*a.factor/a.mau)*a.mau) ETC_EQUIP_RAW_COST
	 , SUM(ROUND (nvl(a.custom1,0)*a.factor/a.mau)*a.mau) custom1
	 , SUM(ROUND (nvl(a.custom2,0)*a.factor/a.mau)*a.mau) custom2
	 , SUM(ROUND (nvl(a.custom3,0)*a.factor/a.mau)*a.mau) custom3
	 , SUM(ROUND (nvl(a.custom4,0)*a.factor/a.mau)*a.mau) custom4
	 , SUM(ROUND (nvl(a.custom5,0)*a.factor/a.mau)*a.mau) custom5
	 , SUM(ROUND (nvl(a.custom6,0)*a.factor/a.mau)*a.mau) custom6
	 , SUM(ROUND (nvl(a.custom7,0)*a.factor/a.mau)*a.mau) custom7
	 , SUM(ROUND (nvl(a.custom8,0)*a.factor/a.mau)*a.mau) custom8
	 , SUM(ROUND (nvl(a.custom9,0)*a.factor/a.mau)*a.mau) custom9
	 , SUM(ROUND (nvl(a.custom10,0)*a.factor/a.mau)*a.mau) custom10
	 , SUM(ROUND (nvl(a.custom11,0)*a.factor/a.mau)*a.mau) custom11
	 , SUM(ROUND (nvl(a.custom12,0)*a.factor/a.mau)*a.mau) custom12
	 , SUM(ROUND (nvl(a.custom13,0)*a.factor/a.mau)*a.mau) custom13
	 , SUM(ROUND (nvl(a.custom14,0)*a.factor/a.mau)*a.mau) custom14
	 , SUM(ROUND (nvl(a.custom15,0)*a.factor/a.mau)*a.mau) custom15
         , a.TIME_DANGLING_FLAG
         , a.RATE_DANGLING_FLAG
         , g_default_prg_level prg_level
         , a.plan_type_code plan_type_code    /* 4471527 */
   FROM (
   SELECT /*+ NO_MERGE */
         fact.project_id  project_id
   	 , fact.project_ORG_ID project_ORG_ID
   	 , fact.project_ORGANIZATION_ID project_ORGANIZATION_ID
   	 , fact.PROJECT_ELEMENT_ID PROJECT_ELEMENT_ID
   	 , pa_cal.ent_period_id TIME_ID
   	 , fact.PERIOD_TYPE_ID PERIOD_TYPE_ID
   	 , 'E' CALENDAR_TYPE -- fact.CALENDAR_TYPE
         , fact.RBS_AGGR_LEVEL
         , fact.WBS_ROLLUP_FLAG
         , fact.PRG_ROLLUP_FLAG
   	 , fact.CURR_RECORD_TYPE_ID CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID PLAN_VERSION_ID
	 , fact.PLAN_TYPE_ID  PLAN_TYPE_ID
	 , fact.raw_cost
	 , fact.brdn_cost
	 , fact.revenue
	 , fact.bill_raw_cost
	 , fact.bill_brdn_cost
	 , fact.bill_labor_raw_cost
	 , fact.bill_labor_brdn_cost
	 , fact.bill_labor_hrs
	 , fact.equipment_raw_cost
	 , fact.equipment_brdn_cost
	 , fact.capitalizable_raw_cost
	 , fact.capitalizable_brdn_cost
	 , fact.labor_raw_cost
	 , fact.labor_brdn_cost
	 , fact.labor_hrs
	 , fact.labor_revenue
	 , fact.equipment_hours
	 , fact.billable_equipment_hours
	 , fact.sup_inv_committed_cost
	 , fact.po_committed_cost
	 , fact.pr_committed_cost
	 , fact.oth_committed_cost
	 , fact.ACT_LABOR_HRS
	 , fact.ACT_EQUIP_HRS
	 , fact.ACT_LABOR_BRDN_COST
	 , fact.ACT_EQUIP_BRDN_COST
	 , fact.ACT_BRDN_COST
	 , fact.ACT_RAW_COST
	 , fact.ACT_REVENUE
	 , fact.ACT_LABOR_RAW_COST
	 , fact.ACT_EQUIP_RAW_COST
	 , fact.ETC_LABOR_HRS
	 , fact.ETC_EQUIP_HRS
	 , fact.ETC_LABOR_BRDN_COST
	 , fact.ETC_EQUIP_BRDN_COST
	 , fact.ETC_BRDN_COST
	 , fact.ETC_RAW_COST
	 , fact.ETC_LABOR_RAW_COST
	 , fact.ETC_EQUIP_RAW_COST
	 , fact.custom1
	 , fact.custom2
	 , fact.custom3
	 , fact.custom4
	 , fact.custom5
	 , fact.custom6
	 , fact.custom7
	 , fact.custom8
	 , fact.custom9
	 , fact.custom10
	 , fact.custom11
	 , fact.custom12
	 , fact.custom13
	 , fact.custom14
	 , fact.custom15
	 , fact.time_dangling_flag time_dangling_flag
	 , fact.rate_dangling_flag rate_dangling_flag
         , cur.mau mau
         , (LEAST(non_pa_cal.end_date,pa_cal.end_date) -
                    Greatest(non_pa_cal.start_date,pa_cal.start_date)+1)
                              / (non_pa_cal.end_date - non_pa_cal.start_date+1) factor
             , fact.plan_type_code  plan_type_code   /* 4471527 */
   FROM   pji_fp_aggr_pjp1_t fact
        , pji_time_cal_period_v  non_pa_cal
        , pji_time_ent_period_v  pa_cal
        , pji_fm_extr_plnver3_t  ver
        , (SELECT currency_code,
                   decode(nvl(MINIMUM_ACCOUNTABLE_UNIT, power(10, (-1 * PRECISION))),
                      null, 0.01,
                         0, 1,
                         nvl(MINIMUM_ACCOUNTABLE_UNIT, power(10, (-1 * PRECISION)))) mau
              FROM FND_CURRENCIES) cur
   WHERE  fact.CALENDAR_TYPE IN ('P', 'G')
      AND fact.worker_id = g_worker_id
      AND non_pa_cal.cal_period_id = fact.time_id
      AND fact.line_type like 'OF%'
      AND non_pa_cal.start_date<= pa_cal.end_date
      AND non_pa_cal.end_Date >=pa_cal.start_date
      AND fact.currency_code = cur.currency_code
      AND fact.time_dangling_flag IS NULL
      AND fact.rate_dangling_flag IS NULL
      AND fact.period_type_id = 32
      AND fact.plan_version_id = ver.plan_version_id
      AND fact.plan_type_code = ver.plan_type_code    /* 4471527 */
      AND ver.wp_flag = 'N'
      AND ver.baselined_flag = 'Y'
      -- AND ( ver.rbs_struct_version_id = fact.rbs_version_id  OR fact.rbs_version_id = -1)
      AND NVL(ver.rbs_struct_version_id, -1) = fact.rbs_version_id
	  ) a
     WHERE a.factor >0
	  GROUP BY
	   a.PROJECT_ID
     , a.PROJECT_ORG_ID
     , a.PROJECT_ORGANIZATION_ID
     , a.PROJECT_ELEMENT_ID
     , a.TIME_ID
     , a.PERIOD_TYPE_ID
     , a.CALENDAR_TYPE
     , a.RBS_AGGR_LEVEL
     , a.WBS_ROLLUP_FLAG
     , a.PRG_ROLLUP_FLAG
     , a.CURR_RECORD_TYPE_ID
     , a.CURRENCY_CODE
     , a.RBS_ELEMENT_ID
     , a.RBS_VERSION_ID
     , a.PLAN_VERSION_ID
     , a.PLAN_TYPE_ID
     , a.PLAN_TYPE_CODE     /* 4471527 */
     , a.TIME_DANGLING_FLAG
     , a.RATE_DANGLING_FLAG;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => ' PRORATE_TO_ENT_PG_PJP1_D ');
    RAISE;
END;


PROCEDURE PRORATE_TO_ENT_PG_FPRL_D IS
BEGIN

    -- g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;

    INSERT INTO pji_fp_aggr_pjp1_t -- PA, GL calendar entries in FP Reporting lines.
    (
       WORKER_ID
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , PRG_LEVEL
     , PLAN_TYPE_CODE   /* 4471527 */
	)
   SELECT
       g_worker_id worker_id
     , a.PROJECT_ID
     , a.PROJECT_ORG_ID
     , a.PROJECT_ORGANIZATION_ID
     , a.PROJECT_ELEMENT_ID
     , a.TIME_ID
     , a.PERIOD_TYPE_ID
     , a.CALENDAR_TYPE
     , a.RBS_AGGR_LEVEL
     , a.WBS_ROLLUP_FLAG
     , a.PRG_ROLLUP_FLAG
     , a.CURR_RECORD_TYPE_ID
     , a.CURRENCY_CODE
     , a.RBS_ELEMENT_ID
     , a.RBS_VERSION_ID
     , a.PLAN_VERSION_ID
     , a.PLAN_TYPE_ID
     , SUM(a.RAW_COST       )
     , SUM(a.BRDN_COST 	)
     , SUM(a.REVENUE	)
     , SUM(a.BILL_RAW_COST )
     , SUM(a.BILL_BRDN_COST )
     , SUM(a.BILL_LABOR_RAW_COST )
     , SUM(a.BILL_LABOR_BRDN_COST )
     , SUM(a.BILL_LABOR_HRS )
     , SUM(a.EQUIPMENT_RAW_COST )
     , SUM(a.EQUIPMENT_BRDN_COST )
     , SUM(a.CAPITALIZABLE_RAW_COST )
     , SUM(a.CAPITALIZABLE_BRDN_COST )
     , SUM(a.LABOR_RAW_COST )
     , SUM(a.LABOR_BRDN_COST)
     , SUM(a.LABOR_HRS )
     , SUM(a.LABOR_REVENUE )
     , SUM(a.EQUIPMENT_HOURS )
     , SUM(a.BILLABLE_EQUIPMENT_HOURS)
     , SUM(a.SUP_INV_COMMITTED_COST)
     , SUM(a.PO_COMMITTED_COST )
     , SUM(a.PR_COMMITTED_COST )
     , SUM(a.OTH_COMMITTED_COST)
       , SUM(a.ACT_LABOR_HRS)
	   , SUM(a.ACT_EQUIP_HRS)
	   , SUM(a.ACT_LABOR_BRDN_COST)
	   , SUM(a.ACT_EQUIP_BRDN_COST)
	   , SUM(a.ACT_BRDN_COST    )
	   , SUM(a.ACT_RAW_COST    )
	   , SUM(a.ACT_REVENUE    )
         , SUM(a.ACT_LABOR_RAW_COST)
         , SUM(a.ACT_EQUIP_RAW_COST)
	   , SUM(a.ETC_LABOR_HRS         )
	   , SUM(a.ETC_EQUIP_HRS        )
	   , SUM(a.ETC_LABOR_BRDN_COST )
	   , SUM(a.ETC_EQUIP_BRDN_COST)
	   , SUM(a.ETC_BRDN_COST )
         , SUM(a.ETC_RAW_COST)
         , SUM(a.ETC_LABOR_RAW_COST)
         , SUM(a.ETC_EQUIP_RAW_COST)
     , SUM(a.CUSTOM1	)
     , SUM(a.CUSTOM2	)
     , SUM(a.CUSTOM3	)
     , SUM(a.CUSTOM4	)
     , SUM(a.CUSTOM5	)
     , SUM(a.CUSTOM6	)
     , SUM(a.CUSTOM7	)
     , SUM(a.CUSTOM8	)
     , SUM(a.CUSTOM9	)
     , SUM(a.CUSTOM10	)
     , SUM(a.CUSTOM11	)
     , SUM(a.CUSTOM12	)
     , SUM(a.CUSTOM13	)
     , SUM(a.CUSTOM14	)
     , SUM(a.CUSTOM15	)
     , g_default_prg_level prg_level
     , a.plan_type_code plan_type_code    /* 4471527 */
   FROM (
   SELECT
         fact.project_id  project_id
   	 , fact.project_ORG_ID project_ORG_ID
   	 , fact.project_ORGANIZATION_ID project_ORGANIZATION_ID
     -- , fact.PARTITION_ID PARTITION_ID
   	 , fact.PROJECT_ELEMENT_ID PROJECT_ELEMENT_ID
   	 , pa_cal.ent_period_id TIME_ID
   	 , fact.PERIOD_TYPE_ID PERIOD_TYPE_ID
   	 , 'E' CALENDAR_TYPE -- fact.CALENDAR_TYPE
     , fact.RBS_AGGR_LEVEL
     , fact.WBS_ROLLUP_FLAG
     , fact.PRG_ROLLUP_FLAG
   	 , fact.CURR_RECORD_TYPE_ID CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID PLAN_VERSION_ID
	 , fact.PLAN_TYPE_ID  PLAN_TYPE_ID
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.raw_cost
			  , '1-1'  , fact.raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			 , '00'   , fact.brdn_cost
			 , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '0-1'  , fact.brdn_cost
			 , '1-1'  , fact.brdn_cost
			 , 0  ) -- end decode
			  , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			 , '00'   , fact.revenue
			 , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '0-1'  , fact.revenue
			 , '1-1'  , fact.revenue
			 , 0  ) -- end decode
			  , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	revenue
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.bill_raw_cost
			  , '1-1'  , fact.bill_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.bill_brdn_cost
			  , '1-1'  , fact.bill_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_labor_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.bill_labor_raw_cost
			  , '1-1'  , fact.bill_labor_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_labor_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_labor_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.bill_labor_brdn_cost
			  , '1-1'  , fact.bill_labor_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_labor_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_labor_hrs
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.bill_labor_hrs
			  , '1-1'  , fact.bill_labor_hrs
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_labor_hrs
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.equipment_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.equipment_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.equipment_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.equipment_raw_cost
			  , '1-1'  , fact.equipment_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	equipment_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.equipment_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.equipment_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.equipment_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.equipment_brdn_cost
			  , '1-1'  , fact.equipment_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	equipment_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.capitalizable_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.capitalizable_raw_cost
			  , '1-1'  , fact.capitalizable_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	capitalizable_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.capitalizable_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.capitalizable_brdn_cost
			  , '1-1'  , fact.capitalizable_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	capitalizable_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.labor_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.labor_raw_cost
			  , '1-1'  , fact.labor_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	labor_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.labor_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.labor_brdn_cost
			  , '1-1'  , fact.labor_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	labor_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.labor_hrs
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.labor_hrs
			  , '1-1'  , fact.labor_hrs
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	labor_hrs
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.labor_revenue
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.labor_revenue
			  , '1-1'  , fact.labor_revenue
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	labor_revenue
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.equipment_hours
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.equipment_hours
			  , '1-1'  , fact.equipment_hours
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	equipment_hours
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.billable_equipment_hours
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.billable_equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.billable_equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.billable_equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.billable_equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.billable_equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.billable_equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.billable_equipment_hours
			  , '1-1'  , fact.billable_equipment_hours
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	billable_equipment_hours
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.sup_inv_committed_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.sup_inv_committed_cost
			  , '1-1'  , fact.sup_inv_committed_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	sup_inv_committed_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.po_committed_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.po_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.po_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.po_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.po_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.po_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.po_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.po_committed_cost
			  , '1-1'  , fact.po_committed_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	po_committed_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.pr_committed_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.pr_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.pr_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.pr_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.pr_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.pr_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.pr_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.pr_committed_cost
			  , '1-1'  , fact.pr_committed_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	pr_committed_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.oth_committed_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.oth_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.oth_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.oth_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.oth_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.oth_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.oth_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.oth_committed_cost
			  , '1-1'  , fact.oth_committed_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	oth_committed_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_LABOR_HRS
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_LABOR_HRS
			  , '1-1'  , fact.ACT_LABOR_HRS
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_LABOR_HRS
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_EQUIP_HRS
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_EQUIP_HRS
			  , '1-1'  , fact.ACT_EQUIP_HRS
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_EQUIP_HRS
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_LABOR_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_LABOR_BRDN_COST
			  , '1-1'  , fact.ACT_LABOR_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_LABOR_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_EQUIP_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_EQUIP_BRDN_COST
			  , '1-1'  , fact.ACT_EQUIP_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_EQUIP_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_BRDN_COST
			  , '1-1'  , fact.ACT_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_RAW_COST
			  , '1-1'  , fact.ACT_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_REVENUE
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_REVENUE / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_REVENUE / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_REVENUE / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_REVENUE / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_REVENUE / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_REVENUE / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_REVENUE
			  , '1-1'  , fact.ACT_REVENUE
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_REVENUE
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_LABOR_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_LABOR_RAW_COST
			  , '1-1'  , fact.ACT_LABOR_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_LABOR_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_EQUIP_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_EQUIP_RAW_COST
			  , '1-1'  , fact.ACT_EQUIP_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_EQUIP_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_LABOR_HRS
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_LABOR_HRS
			  , '1-1'  , fact.ETC_LABOR_HRS
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_LABOR_HRS
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_EQUIP_HRS
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_EQUIP_HRS
			  , '1-1'  , fact.ETC_EQUIP_HRS
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_EQUIP_HRS
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_LABOR_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_LABOR_BRDN_COST
			  , '1-1'  , fact.ETC_LABOR_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_LABOR_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_EQUIP_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_EQUIP_BRDN_COST
			  , '1-1'  , fact.ETC_EQUIP_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_EQUIP_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_BRDN_COST
			  , '1-1'  , fact.ETC_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_RAW_COST
			  , '1-1'  , fact.ETC_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_LABOR_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_LABOR_RAW_COST
			  , '1-1'  , fact.ETC_LABOR_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_LABOR_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_EQUIP_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_EQUIP_RAW_COST
			  , '1-1'  , fact.ETC_EQUIP_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_EQUIP_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom1
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom1 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom1 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom1 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom1 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom1 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom1 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom1
			  , '1-1'  , fact.custom1
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom1
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom2
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom2 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom2 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom2 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom2 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom2 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom2 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom2
			  , '1-1'  , fact.custom2
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom2
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom3
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom3 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom3 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom3 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom3 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom3 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom3 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom3
			  , '1-1'  , fact.custom3
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom3
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom4
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom4 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom4 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom4 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom4 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom4 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom4 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom4
			  , '1-1'  , fact.custom4
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom4
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom5
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom5 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom5 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom5 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom5 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom5 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom5 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom5
			  , '1-1'  , fact.custom5
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom5
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom6
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom6 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom6 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom6 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom6 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom6 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom6 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom6
			  , '1-1'  , fact.custom6
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom6
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom7
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom7 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom7 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom7 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom7 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom7 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom7 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom7
			  , '1-1'  , fact.custom7
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom7
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom8
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom8 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom8 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom8 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom8 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom8 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom8 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom8
			  , '1-1'  , fact.custom8
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom8
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom9
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom9 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom9 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom9 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom9 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom9 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom9 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom9
			  , '1-1'  , fact.custom9
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom9
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom10
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom10 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom10 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom10 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom10 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom10 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom10 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom10
			  , '1-1'  , fact.custom10
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom10
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom11
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom11 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom11 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom11 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom11 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom11 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom11 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom11
			  , '1-1'  , fact.custom11
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom11
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom12
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom12 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom12 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom12 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom12 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom12 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom12 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom12
			  , '1-1'  , fact.custom12
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom12
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom13
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom13 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom13 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom13 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom13 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom13 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom13 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom13
			  , '1-1'  , fact.custom13
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom13
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom14
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom14 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom14 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom14 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom14 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom14 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom14 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom14
			  , '1-1'  , fact.custom14
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom14
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom15
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom15 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom15 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom15 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom15 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom15 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom15 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom15
			  , '1-1'  , fact.custom15
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom15
         , fact.plan_type_code   plan_type_code     /* 4471527  */
   FROM  pji_fp_xbs_accum_f  fact
       , pji_time_cal_period  non_pa_cal
    -- , pji_org_extr_info  orginfo
   	 , pji_time_ent_period  pa_cal
       , PJI_FM_EXTR_PLNVER3_T ver
   WHERE  1 = 1
      AND fact.calendar_type IN ('P', 'G')
      AND fact.period_type_id = 32
      AND non_pa_cal.cal_period_id = fact.time_id
      AND ver.project_id = fact.project_id
      AND ver.plan_version_id = fact.plan_version_id
      ANd ver.plan_type_code = fact.plan_type_code    /* 4471527 */
      -- AND orginfo.org_id = fact.PROJECT_ORG_ID
      -- AND orginfo.pa_calendar_id = pa_cal.calendar_id
      -- AND pa_cal.start_date >= non_pa_cal.start_date
      AND (
	       ( pa_cal.start_date >= non_pa_cal.start_date  AND pa_cal.end_date <= non_pa_cal.end_date )
	    OR ( pa_cal.start_date <= non_pa_cal.start_date  AND pa_cal.end_date >= non_pa_cal.end_date )
	    OR ( pa_cal.start_date <= non_pa_cal.start_date  AND pa_cal.end_date <= non_pa_cal.end_date AND pa_cal.end_date >= non_pa_cal.start_date )
	    OR ( pa_cal.start_date >= non_pa_cal.start_date  AND pa_cal.end_date >= non_pa_cal.end_date AND pa_cal.start_date <= non_pa_cal.end_date )
          )
      AND fact.period_type_id = 32
      AND ver.wp_flag = 'N'
      AND ver.baselined_flag = 'Y'
	-- AND ( ver.rbs_struct_version_id = fact.rbs_version_id  OR fact.rbs_version_id = -1)
      AND NVL(ver.rbs_struct_version_id, -1) = fact.rbs_version_id
	  ) a
	  GROUP BY
	   a.PROJECT_ID
     , a.PROJECT_ORG_ID
     , a.PROJECT_ORGANIZATION_ID
     , a.PROJECT_ELEMENT_ID
     , a.TIME_ID
     , a.PERIOD_TYPE_ID
     , a.CALENDAR_TYPE
     , a.RBS_AGGR_LEVEL
     , a.WBS_ROLLUP_FLAG
     , a.PRG_ROLLUP_FLAG
     , a.CURR_RECORD_TYPE_ID
     , a.CURRENCY_CODE
     , a.RBS_ELEMENT_ID
     , a.RBS_VERSION_ID
     , a.PLAN_VERSION_ID
     , a.PLAN_TYPE_ID
     , a.PLAN_TYPE_CODE ;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRORATE_TO_ENT_PG_FPRL_D ');
    RAISE;
END;


PROCEDURE PRORATE_TO_ENT_N_PJP1_D IS
BEGIN

    -- g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;

/* Commented for bug 4005006
    INSERT INTO pji_fp_aggr_pjp1_t   -- Non time phased entries in pjp1 table.
    (
       WORKER_ID
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , LINE_TYPE
     , TIME_DANGLING_FLAG
     , RATE_DANGLING_FLAG
     , PRG_LEVEL
   )
   SELECT
       g_worker_id worker_id
     , a.PROJECT_ID
     , a.PROJECT_ORG_ID
     , a.PROJECT_ORGANIZATION_ID
     , a.PROJECT_ELEMENT_ID
     , a.TIME_ID
     , 32 -- a.PERIOD_TYPE_ID
     , a.CALENDAR_TYPE
     , a.RBS_AGGR_LEVEL
     , a.WBS_ROLLUP_FLAG
     , a.PRG_ROLLUP_FLAG
     , a.CURR_RECORD_TYPE_ID
     , a.CURRENCY_CODE
     , a.RBS_ELEMENT_ID
     , a.RBS_VERSION_ID
     , a.PLAN_VERSION_ID
     , a.PLAN_TYPE_ID
     , SUM(a.RAW_COST       )
     , SUM(a.BRDN_COST 	)
     , SUM(a.REVENUE	)
     , SUM(a.BILL_RAW_COST )
     , SUM(a.BILL_BRDN_COST )
     , SUM(a.BILL_LABOR_RAW_COST )
     , SUM(a.BILL_LABOR_BRDN_COST )
     , SUM(a.BILL_LABOR_HRS )
     , SUM(a.EQUIPMENT_RAW_COST )
     , SUM(a.EQUIPMENT_BRDN_COST )
     , SUM(a.CAPITALIZABLE_RAW_COST )
     , SUM(a.CAPITALIZABLE_BRDN_COST )
     , SUM(a.LABOR_RAW_COST )
     , SUM(a.LABOR_BRDN_COST)
     , SUM(a.LABOR_HRS )
     , SUM(a.LABOR_REVENUE )
     , SUM(a.EQUIPMENT_HOURS )
     , SUM(a.BILLABLE_EQUIPMENT_HOURS)
     , SUM(a.SUP_INV_COMMITTED_COST)
     , SUM(a.PO_COMMITTED_COST )
     , SUM(a.PR_COMMITTED_COST )
     , SUM(a.OTH_COMMITTED_COST)
       , SUM(a.ACT_LABOR_HRS)
	   , SUM(a.ACT_EQUIP_HRS)
	   , SUM(a.ACT_LABOR_BRDN_COST)
	   , SUM(a.ACT_EQUIP_BRDN_COST)
	   , SUM(a.ACT_BRDN_COST    )
	   , SUM(a.ACT_RAW_COST    )
	   , SUM(a.ACT_REVENUE    )
         , SUM(a.ACT_LABOR_RAW_COST)
         , SUM(a.ACT_EQUIP_RAW_COST)
	   , SUM(a.ETC_LABOR_HRS         )
	   , SUM(a.ETC_EQUIP_HRS        )
	   , SUM(a.ETC_LABOR_BRDN_COST )
	   , SUM(a.ETC_EQUIP_BRDN_COST)
	   , SUM(a.ETC_BRDN_COST )
         , SUM(a.ETC_RAW_COST)
         , SUM(a.ETC_LABOR_RAW_COST)
         , SUM(a.ETC_EQUIP_RAW_COST)
     , SUM(a.CUSTOM1	)
     , SUM(a.CUSTOM2	)
     , SUM(a.CUSTOM3	)
     , SUM(a.CUSTOM4	)
     , SUM(a.CUSTOM5	)
     , SUM(a.CUSTOM6	)
     , SUM(a.CUSTOM7	)
     , SUM(a.CUSTOM8	)
     , SUM(a.CUSTOM9	)
     , SUM(a.CUSTOM10	)
     , SUM(a.CUSTOM11	)
     , SUM(a.CUSTOM12	)
     , SUM(a.CUSTOM13	)
     , SUM(a.CUSTOM14	)
     , SUM(a.CUSTOM15	)
     , a.LINE_TYPE
     , a.TIME_DANGLING_FLAG
     , a.RATE_DANGLING_FLAG
     , g_default_prg_level prg_level
   FROM (
   SELECT
         fact.project_id  project_id
   	 , fact.project_ORG_ID project_ORG_ID
   	 , fact.project_ORGANIZATION_ID project_ORGANIZATION_ID
     -- , fact.PARTITION_ID PARTITION_ID
   	 , fact.PROJECT_ELEMENT_ID PROJECT_ELEMENT_ID
   	 , pa_cal.ent_period_id TIME_ID
   	 , fact.PERIOD_TYPE_ID PERIOD_TYPE_ID
   	 , 'E' CALENDAR_TYPE -- fact.CALENDAR_TYPE
     , fact.RBS_AGGR_LEVEL
     , fact.WBS_ROLLUP_FLAG
     , fact.PRG_ROLLUP_FLAG
   	 , fact.CURR_RECORD_TYPE_ID CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID PLAN_VERSION_ID
	 , fact.PLAN_TYPE_ID  PLAN_TYPE_ID
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.raw_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.raw_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.raw_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.raw_cost
			  , '1-1'  , fact.raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			 , '00'   , fact.brdn_cost
			 , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.brdn_cost / (fact.end_date - fact.start_date + 1)
			 , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.brdn_cost / (fact.end_date - fact.start_date + 1)
			 , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.brdn_cost / (fact.end_date - fact.start_date + 1)
			 , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.brdn_cost / (fact.end_date - fact.start_date + 1)
			 , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.brdn_cost / (fact.end_date - fact.start_date + 1)
			 , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.brdn_cost / (fact.end_date - fact.start_date + 1)
			 , '0-1'  , fact.brdn_cost
			 , '1-1'  , fact.brdn_cost
			 , 0  ) -- end decode
			  , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			 , '00'   , fact.revenue
			 , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.revenue / (fact.end_date - fact.start_date + 1)
			 , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.revenue / (fact.end_date - fact.start_date + 1)
			 , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.revenue / (fact.end_date - fact.start_date + 1)
			 , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.revenue / (fact.end_date - fact.start_date + 1)
			 , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.revenue / (fact.end_date - fact.start_date + 1)
			 , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.revenue / (fact.end_date - fact.start_date + 1)
			 , '0-1'  , fact.revenue
			 , '1-1'  , fact.revenue
			 , 0  ) -- end decode
			  , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	revenue
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.bill_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.bill_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.bill_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.bill_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.bill_raw_cost
			  , '1-1'  , fact.bill_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.bill_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.bill_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.bill_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.bill_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.bill_brdn_cost
			  , '1-1'  , fact.bill_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_labor_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.bill_labor_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.bill_labor_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.bill_labor_raw_cost
			  , '1-1'  , fact.bill_labor_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_labor_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_labor_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.bill_labor_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.bill_labor_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.bill_labor_brdn_cost
			  , '1-1'  , fact.bill_labor_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_labor_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_labor_hrs
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_hrs / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_hrs / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.bill_labor_hrs / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.bill_labor_hrs / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.bill_labor_hrs / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.bill_labor_hrs / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.bill_labor_hrs
			  , '1-1'  , fact.bill_labor_hrs
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_labor_hrs
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.equipment_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.equipment_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.equipment_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.equipment_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.equipment_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.equipment_raw_cost
			  , '1-1'  , fact.equipment_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	equipment_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.equipment_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.equipment_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.equipment_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.equipment_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.equipment_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.equipment_brdn_cost
			  , '1-1'  , fact.equipment_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	equipment_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.capitalizable_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.capitalizable_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.capitalizable_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.capitalizable_raw_cost
			  , '1-1'  , fact.capitalizable_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	capitalizable_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.capitalizable_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.capitalizable_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.capitalizable_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.capitalizable_brdn_cost
			  , '1-1'  , fact.capitalizable_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	capitalizable_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.labor_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.labor_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.labor_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.labor_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.labor_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.labor_raw_cost
			  , '1-1'  , fact.labor_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	labor_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.labor_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.labor_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.labor_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.labor_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.labor_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.labor_brdn_cost
			  , '1-1'  , fact.labor_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	labor_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.labor_hrs
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_hrs / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_hrs / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.labor_hrs / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.labor_hrs / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.labor_hrs / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.labor_hrs / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.labor_hrs
			  , '1-1'  , fact.labor_hrs
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	labor_hrs
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.labor_revenue
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_revenue / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_revenue / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.labor_revenue / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.labor_revenue / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.labor_revenue / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.labor_revenue / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.labor_revenue
			  , '1-1'  , fact.labor_revenue
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	labor_revenue
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.equipment_hours
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_hours / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_hours / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.equipment_hours / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.equipment_hours / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.equipment_hours / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.equipment_hours / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.equipment_hours
			  , '1-1'  , fact.equipment_hours
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	equipment_hours
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.billable_equipment_hours
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.billable_equipment_hours / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.billable_equipment_hours / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.billable_equipment_hours / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.billable_equipment_hours / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.billable_equipment_hours / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.billable_equipment_hours / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.billable_equipment_hours
			  , '1-1'  , fact.billable_equipment_hours
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	billable_equipment_hours
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.sup_inv_committed_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.sup_inv_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.sup_inv_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.sup_inv_committed_cost
			  , '1-1'  , fact.sup_inv_committed_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	sup_inv_committed_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.po_committed_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.po_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.po_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.po_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.po_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.po_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.po_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.po_committed_cost
			  , '1-1'  , fact.po_committed_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	po_committed_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.pr_committed_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.pr_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.pr_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.pr_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.pr_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.pr_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.pr_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.pr_committed_cost
			  , '1-1'  , fact.pr_committed_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	pr_committed_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.oth_committed_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.oth_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.oth_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.oth_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.oth_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.oth_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.oth_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.oth_committed_cost
			  , '1-1'  , fact.oth_committed_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	oth_committed_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_LABOR_HRS
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_LABOR_HRS / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_LABOR_HRS / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ACT_LABOR_HRS
			  , '1-1'  , fact.ACT_LABOR_HRS
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_LABOR_HRS
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_EQUIP_HRS
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_EQUIP_HRS / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_EQUIP_HRS / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ACT_EQUIP_HRS
			  , '1-1'  , fact.ACT_EQUIP_HRS
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_EQUIP_HRS
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_LABOR_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ACT_LABOR_BRDN_COST
			  , '1-1'  , fact.ACT_LABOR_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_LABOR_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_EQUIP_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ACT_EQUIP_BRDN_COST
			  , '1-1'  , fact.ACT_EQUIP_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_EQUIP_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ACT_BRDN_COST
			  , '1-1'  , fact.ACT_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ACT_RAW_COST
			  , '1-1'  , fact.ACT_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_REVENUE
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_REVENUE / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_REVENUE / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_REVENUE / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_REVENUE / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_REVENUE / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_REVENUE / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ACT_REVENUE
			  , '1-1'  , fact.ACT_REVENUE
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_REVENUE
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_LABOR_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_LABOR_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_LABOR_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ACT_LABOR_RAW_COST
			  , '1-1'  , fact.ACT_LABOR_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_LABOR_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_EQUIP_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ACT_EQUIP_RAW_COST
			  , '1-1'  , fact.ACT_EQUIP_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_EQUIP_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_LABOR_HRS
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_LABOR_HRS / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_LABOR_HRS / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ETC_LABOR_HRS
			  , '1-1'  , fact.ETC_LABOR_HRS
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_LABOR_HRS
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_EQUIP_HRS
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_EQUIP_HRS / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_EQUIP_HRS / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ETC_EQUIP_HRS
			  , '1-1'  , fact.ETC_EQUIP_HRS
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_EQUIP_HRS
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_LABOR_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ETC_LABOR_BRDN_COST
			  , '1-1'  , fact.ETC_LABOR_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_LABOR_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_EQUIP_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ETC_EQUIP_BRDN_COST
			  , '1-1'  , fact.ETC_EQUIP_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_EQUIP_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ETC_BRDN_COST
			  , '1-1'  , fact.ETC_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ETC_RAW_COST
			  , '1-1'  , fact.ETC_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_LABOR_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_LABOR_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_LABOR_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ETC_LABOR_RAW_COST
			  , '1-1'  , fact.ETC_LABOR_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_LABOR_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_EQUIP_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ETC_EQUIP_RAW_COST
			  , '1-1'  , fact.ETC_EQUIP_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_EQUIP_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom1
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom1 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom1 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom1 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom1 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom1 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom1 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom1
			  , '1-1'  , fact.custom1
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom1
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom2
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom2 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom2 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom2 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom2 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom2 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom2 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom2
			  , '1-1'  , fact.custom2
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom2
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom3
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom3 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom3 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom3 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom3 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom3 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom3 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom3
			  , '1-1'  , fact.custom3
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom3
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom4
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom4 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom4 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom4 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom4 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom4 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom4 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom4
			  , '1-1'  , fact.custom4
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom4
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom5
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom5 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom5 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom5 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom5 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom5 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom5 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom5
			  , '1-1'  , fact.custom5
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom5
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom6
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom6 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom6 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom6 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom6 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom6 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom6 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom6
			  , '1-1'  , fact.custom6
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom6
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom7
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom7 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom7 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom7 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom7 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom7 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom7 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom7
			  , '1-1'  , fact.custom7
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom7
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom8
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom8 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom8 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom8 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom8 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom8 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom8 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom8
			  , '1-1'  , fact.custom8
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom8
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom9
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom9 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom9 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom9 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom9 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom9 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom9 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom9
			  , '1-1'  , fact.custom9
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom9
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom10
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom10 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom10 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom10 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom10 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom10 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom10 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom10
			  , '1-1'  , fact.custom10
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom10
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom11
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom11 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom11 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom11 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom11 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom11 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom11 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom11
			  , '1-1'  , fact.custom11
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom11
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom12
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom12 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom12 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom12 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom12 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom12 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom12 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom12
			  , '1-1'  , fact.custom12
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom12
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom13
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom13 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom13 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom13 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom13 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom13 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom13 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom13
			  , '1-1'  , fact.custom13
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom13
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom14
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom14 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom14 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom14 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom14 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom14 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom14 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom14
			  , '1-1'  , fact.custom14
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom14
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom15
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom15 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom15 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom15 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom15 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom15 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom15 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom15
			  , '1-1'  , fact.custom15
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom15
       , 'CN'   line_type
	 , fact.time_dangling_flag time_dangling_flag
	 , fact.rate_dangling_flag rate_dangling_flag
       , g_default_prg_level prg_level
   FROM   pji_fp_aggr_pjp1_t fact
        , pji_time_ent_period  pa_cal
        , pji_fm_extr_plnver3_t  ver
   WHERE  1=1
      AND fact.CALENDAR_TYPE = 'A'
      AND fact.worker_id = g_worker_id
      AND fact.start_date IS NOT NULL
      AND fact.end_date IS NOT NULL
	AND fact.time_dangling_flag IS NULL
	AND fact.rate_dangling_flag IS NULL
      AND (
	       (     pa_cal.start_date >= fact.start_date
               AND pa_cal.end_date <= fact.end_date ) -- fsps,pefe
	    OR (     pa_cal.start_date <= fact.start_date
               AND pa_cal.end_date >= fact.end_date ) -- psfs,fepe
	    OR (     pa_cal.start_date <= fact.start_date
               AND pa_cal.end_date <= fact.end_date
               AND pa_cal.end_date >= fact.start_date ) -- psfspefe
	    OR (     pa_cal.start_date >= fact.start_date
               AND pa_cal.end_date >= fact.end_date
               AND pa_cal.start_date <= fact.end_date )  -- fspsfepe
          )
      AND fact.line_type = 'NTP'
      AND fact.period_type_id = 2048
      AND fact.plan_version_id = ver.plan_version_id
      AND ver.wp_flag = 'N'
      AND ver.baselined_flag = 'Y'
      AND ver.time_phased_type_code = 'N'
	-- AND ( ver.rbs_struct_version_id = fact.rbs_version_id  OR fact.rbs_version_id = -1)
      AND NVL(ver.rbs_struct_version_id, -1) = fact.rbs_version_id
	  ) a
	  GROUP BY
	   a.PROJECT_ID
     , a.PROJECT_ORG_ID
     , a.PROJECT_ORGANIZATION_ID
     , a.PROJECT_ELEMENT_ID
     , a.TIME_ID
     , a.PERIOD_TYPE_ID
     , a.CALENDAR_TYPE
     , a.RBS_AGGR_LEVEL
     , a.WBS_ROLLUP_FLAG
     , a.PRG_ROLLUP_FLAG
     , a.CURR_RECORD_TYPE_ID
     , a.CURRENCY_CODE
     , a.RBS_ELEMENT_ID
     , a.RBS_VERSION_ID
     , a.PLAN_VERSION_ID
     , a.PLAN_TYPE_ID
	 , a.LINE_TYPE
	 , a.TIME_DANGLING_FLAG
	 , a.RATE_DANGLING_FLAG;
 End of 4005006*/

    INSERT INTO pji_fp_aggr_pjp1_t   -- Non time phased entries in pjp1 table.
    (
       WORKER_ID
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
     , ACT_LABOR_HRS
     , ACT_EQUIP_HRS
     , ACT_LABOR_BRDN_COST
     , ACT_EQUIP_BRDN_COST
     , ACT_BRDN_COST
     , ACT_RAW_COST
     , ACT_REVENUE
     , ACT_LABOR_RAW_COST
     , ACT_EQUIP_RAW_COST
     , ETC_LABOR_HRS
     , ETC_EQUIP_HRS
     , ETC_LABOR_BRDN_COST
     , ETC_EQUIP_BRDN_COST
     , ETC_BRDN_COST
     , ETC_RAW_COST
     , ETC_LABOR_RAW_COST
     , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , TIME_DANGLING_FLAG
     , RATE_DANGLING_FLAG
     , PRG_LEVEL
     , PLAN_TYPE_CODE    /* 4471527 */
   )
   SELECT
           g_worker_id worker_id
         , a.PROJECT_ID
         , a.PROJECT_ORG_ID
         , a.PROJECT_ORGANIZATION_ID
         , a.PROJECT_ELEMENT_ID
         , a.TIME_ID
         , 32 -- a.PERIOD_TYPE_ID
         , a.CALENDAR_TYPE
         , a.RBS_AGGR_LEVEL
         , a.WBS_ROLLUP_FLAG
         , a.PRG_ROLLUP_FLAG
         , a.CURR_RECORD_TYPE_ID
         , a.CURRENCY_CODE
         , a.RBS_ELEMENT_ID
         , a.RBS_VERSION_ID
         , a.PLAN_VERSION_ID
         , a.PLAN_TYPE_ID
	 , SUM(ROUND (nvl(a.raw_cost,0)*a.factor/a.mau)*a.mau) raw_cost
	 , SUM(ROUND (nvl(a.brdn_cost,0)*a.factor/a.mau)*a.mau) brdn_cost
	 , SUM(ROUND (nvl(a.revenue,0)*a.factor/a.mau)*a.mau) revenue
	 , SUM(ROUND (nvl(a.bill_raw_cost,0)*a.factor/a.mau)*a.mau) bill_raw_cost
	 , SUM(ROUND (nvl(a.bill_brdn_cost,0)*a.factor/a.mau)*a.mau) bill_brdn_cost
	 , SUM(ROUND (nvl(a.bill_labor_raw_cost,0)*a.factor/a.mau)*a.mau) bill_labor_raw_cost
	 , SUM(ROUND (nvl(a.bill_labor_brdn_cost,0)*a.factor/a.mau)*a.mau) bill_labor_brdn_cost
	 , SUM(ROUND (nvl(a.bill_labor_hrs,0)*a.factor/a.mau)*a.mau) bill_labor_hrs
	 , SUM(ROUND (nvl(a.equipment_raw_cost,0)*a.factor/a.mau)*a.mau) equipment_raw_cost
	 , SUM(ROUND (nvl(a.equipment_brdn_cost,0)*a.factor/a.mau)*a.mau) equipment_brdn_cost
	 , SUM(ROUND (nvl(a.capitalizable_raw_cost,0)*a.factor/a.mau)*a.mau) capitalizable_raw_cost
	 , SUM(ROUND (nvl(a.capitalizable_brdn_cost,0)*a.factor/a.mau)*a.mau) capitalizable_brdn_cost
	 , SUM(ROUND (nvl(a.labor_raw_cost,0)*a.factor/a.mau)*a.mau) labor_raw_cost
	 , SUM(ROUND (nvl(a.labor_brdn_cost,0)*a.factor/a.mau)*a.mau) labor_brdn_cost
	 , SUM(ROUND (nvl(a.labor_hrs,0)*a.factor/a.mau)*a.mau) labor_hrs
	 , SUM(ROUND (nvl(a.labor_revenue,0)*a.factor/a.mau)*a.mau) labor_revenue
	 , SUM(ROUND (nvl(a.equipment_hours,0)*a.factor/a.mau)*a.mau) equipment_hours
	 , SUM(ROUND (nvl(a.billable_equipment_hours,0)*a.factor/a.mau)*a.mau) billable_equipment_hours
	 , SUM(ROUND (nvl(a.sup_inv_committed_cost,0)*a.factor/a.mau)*a.mau) sup_inv_committed_cost
	 , SUM(ROUND (nvl(a.po_committed_cost,0)*a.factor/a.mau)*a.mau) po_committed_cost
	 , SUM(ROUND (nvl(a.pr_committed_cost,0)*a.factor/a.mau)*a.mau) pr_committed_cost
	 , SUM(ROUND (nvl(a.oth_committed_cost,0)*a.factor/a.mau)*a.mau) oth_committed_cost
	 , SUM(ROUND (nvl(a.ACT_LABOR_HRS,0)*a.factor/a.mau)*a.mau) ACT_LABOR_HRS
	 , SUM(ROUND (nvl(a.ACT_EQUIP_HRS,0)*a.factor/a.mau)*a.mau) ACT_EQUIP_HRS
	 , SUM(ROUND (nvl(a.ACT_LABOR_BRDN_COST,0)*a.factor/a.mau)*a.mau) ACT_LABOR_BRDN_COST
	 , SUM(ROUND (nvl(a.ACT_EQUIP_BRDN_COST,0)*a.factor/a.mau)*a.mau) ACT_EQUIP_BRDN_COST
	 , SUM(ROUND (nvl(a.ACT_BRDN_COST,0)*a.factor/a.mau)*a.mau) ACT_BRDN_COST
	 , SUM(ROUND (nvl(a.ACT_RAW_COST,0)*a.factor/a.mau)*a.mau) ACT_RAW_COST
	 , SUM(ROUND (nvl(a.ACT_REVENUE,0)*a.factor/a.mau)*a.mau) ACT_REVENUE
	 , SUM(ROUND (nvl(a.ACT_LABOR_RAW_COST,0)*a.factor/a.mau)*a.mau) ACT_LABOR_RAW_COST
	 , SUM(ROUND (nvl(a.ACT_EQUIP_RAW_COST,0)*a.factor/a.mau)*a.mau) ACT_EQUIP_RAW_COST
	 , SUM(ROUND (nvl(a.ETC_LABOR_HRS,0)*a.factor/a.mau)*a.mau) ETC_LABOR_HRS
	 , SUM(ROUND (nvl(a.ETC_EQUIP_HRS,0)*a.factor/a.mau)*a.mau) ETC_EQUIP_HRS
	 , SUM(ROUND (nvl(a.ETC_LABOR_BRDN_COST,0)*a.factor/a.mau)*a.mau) ETC_LABOR_BRDN_COST
	 , SUM(ROUND (nvl(a.ETC_EQUIP_BRDN_COST,0)*a.factor/a.mau)*a.mau) ETC_EQUIP_BRDN_COST
	 , SUM(ROUND (nvl(a.ETC_BRDN_COST,0)*a.factor/a.mau)*a.mau) ETC_BRDN_COST
	 , SUM(ROUND (nvl(a.ETC_RAW_COST,0)*a.factor/a.mau)*a.mau) ETC_RAW_COST
	 , SUM(ROUND (nvl(a.ETC_LABOR_RAW_COST,0)*a.factor/a.mau)*a.mau) ETC_LABOR_RAW_COST
	 , SUM(ROUND (nvl(a.ETC_EQUIP_RAW_COST,0)*a.factor/a.mau)*a.mau) ETC_EQUIP_RAW_COST
	 , SUM(ROUND (nvl(a.custom1,0)*a.factor/a.mau)*a.mau) custom1
	 , SUM(ROUND (nvl(a.custom2,0)*a.factor/a.mau)*a.mau) custom2
	 , SUM(ROUND (nvl(a.custom3,0)*a.factor/a.mau)*a.mau) custom3
	 , SUM(ROUND (nvl(a.custom4,0)*a.factor/a.mau)*a.mau) custom4
	 , SUM(ROUND (nvl(a.custom5,0)*a.factor/a.mau)*a.mau) custom5
	 , SUM(ROUND (nvl(a.custom6,0)*a.factor/a.mau)*a.mau) custom6
	 , SUM(ROUND (nvl(a.custom7,0)*a.factor/a.mau)*a.mau) custom7
	 , SUM(ROUND (nvl(a.custom8,0)*a.factor/a.mau)*a.mau) custom8
	 , SUM(ROUND (nvl(a.custom9,0)*a.factor/a.mau)*a.mau) custom9
	 , SUM(ROUND (nvl(a.custom10,0)*a.factor/a.mau)*a.mau) custom10
	 , SUM(ROUND (nvl(a.custom11,0)*a.factor/a.mau)*a.mau) custom11
	 , SUM(ROUND (nvl(a.custom12,0)*a.factor/a.mau)*a.mau) custom12
	 , SUM(ROUND (nvl(a.custom13,0)*a.factor/a.mau)*a.mau) custom13
	 , SUM(ROUND (nvl(a.custom14,0)*a.factor/a.mau)*a.mau) custom14
	 , SUM(ROUND (nvl(a.custom15,0)*a.factor/a.mau)*a.mau) custom15
         , a.TIME_DANGLING_FLAG
         , a.RATE_DANGLING_FLAG
         , g_default_prg_level prg_level
         , a.plan_type_code plan_type_code    /* 4471527   */
   FROM (
   SELECT /*+ NO_MERGE */
           fact.project_id  project_id
   	 , fact.project_ORG_ID project_ORG_ID
   	 , fact.project_ORGANIZATION_ID project_ORGANIZATION_ID
   	 , fact.PROJECT_ELEMENT_ID PROJECT_ELEMENT_ID
   	 , entCal.ent_period_id TIME_ID
   	 , fact.PERIOD_TYPE_ID PERIOD_TYPE_ID
   	 , 'E' CALENDAR_TYPE -- fact.CALENDAR_TYPE
         , fact.RBS_AGGR_LEVEL
         , fact.WBS_ROLLUP_FLAG
         , fact.PRG_ROLLUP_FLAG
   	 , fact.CURR_RECORD_TYPE_ID CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID PLAN_VERSION_ID
	 , fact.PLAN_TYPE_ID  PLAN_TYPE_ID
	 , fact.raw_cost
	 , fact.brdn_cost
	 , fact.revenue
	 , fact.bill_raw_cost
	 , fact.bill_brdn_cost
	 , fact.bill_labor_raw_cost
	 , fact.bill_labor_brdn_cost
	 , fact.bill_labor_hrs
	 , fact.equipment_raw_cost
	 , fact.equipment_brdn_cost
	 , fact.capitalizable_raw_cost
	 , fact.capitalizable_brdn_cost
	 , fact.labor_raw_cost
	 , fact.labor_brdn_cost
	 , fact.labor_hrs
	 , fact.labor_revenue
	 , fact.equipment_hours
	 , fact.billable_equipment_hours
	 , fact.sup_inv_committed_cost
	 , fact.po_committed_cost
	 , fact.pr_committed_cost
	 , fact.oth_committed_cost
	 , fact.ACT_LABOR_HRS
	 , fact.ACT_EQUIP_HRS
	 , fact.ACT_LABOR_BRDN_COST
	 , fact.ACT_EQUIP_BRDN_COST
	 , fact.ACT_BRDN_COST
	 , fact.ACT_RAW_COST
	 , fact.ACT_REVENUE
	 , fact.ACT_LABOR_RAW_COST
	 , fact.ACT_EQUIP_RAW_COST
	 , fact.ETC_LABOR_HRS
	 , fact.ETC_EQUIP_HRS
	 , fact.ETC_LABOR_BRDN_COST
	 , fact.ETC_EQUIP_BRDN_COST
	 , fact.ETC_BRDN_COST
	 , fact.ETC_RAW_COST
	 , fact.ETC_LABOR_RAW_COST
	 , fact.ETC_EQUIP_RAW_COST
	 , fact.custom1
	 , fact.custom2
	 , fact.custom3
	 , fact.custom4
	 , fact.custom5
	 , fact.custom6
	 , fact.custom7
	 , fact.custom8
	 , fact.custom9
	 , fact.custom10
	 , fact.custom11
	 , fact.custom12
	 , fact.custom13
	 , fact.custom14
	 , fact.custom15
	 , fact.time_dangling_flag time_dangling_flag
	 , fact.rate_dangling_flag rate_dangling_flag
         , cur.mau mau
         , (LEAST(fact.end_date,entCal.end_date) - Greatest(fact.start_date,entCal.start_date)+1)
                              / (fact.end_date - fact.start_date+1) factor
         , fact.plan_type_code   plan_type_code     /* 4471527 */
   FROM   pji_fp_aggr_pjp1_t fact
        , pji_time_ent_period_v  entCal
        , pji_fm_extr_plnver3_t  ver
        , (SELECT currency_code,
                   decode(nvl(MINIMUM_ACCOUNTABLE_UNIT, power(10, (-1 * PRECISION))),
                      null, 0.01,
                         0, 1,
                         nvl(MINIMUM_ACCOUNTABLE_UNIT, power(10, (-1 * PRECISION)))) mau
              FROM FND_CURRENCIES) cur
   WHERE  1=1
      AND fact.CALENDAR_TYPE = 'A'
      AND fact.worker_id = g_worker_id
      AND fact.start_date IS NOT NULL
      AND fact.end_date IS NOT NULL
      AND fact.time_dangling_flag IS NULL
      AND fact.rate_dangling_flag IS NULL
      AND fact.line_type = 'NTP'
      AND fact.period_type_id = 2048
      AND fact.plan_version_id = ver.plan_version_id
      AND fact.plan_type_code = ver.plan_type_code    /* 4471527 */
      AND ver.wp_flag = 'N'
      AND ver.baselined_flag = 'Y'
      AND ver.time_phased_type_code = 'N'
      -- AND ( ver.rbs_struct_version_id = fact.rbs_version_id  OR fact.rbs_version_id = -1)
      AND NVL(ver.rbs_struct_version_id, -1) = fact.rbs_version_id
      AND cur.currency_code = fact.currency_code
      AND ( fact.start_date <= entCal.end_date AND fact.end_date >= entCal.start_date )
	  ) a
   WHERE a.factor>0
  GROUP BY
       a.PROJECT_ID
     , a.PROJECT_ORG_ID
     , a.PROJECT_ORGANIZATION_ID
     , a.PROJECT_ELEMENT_ID
     , a.TIME_ID
     , a.PERIOD_TYPE_ID
     , a.CALENDAR_TYPE
     , a.RBS_AGGR_LEVEL
     , a.WBS_ROLLUP_FLAG
     , a.PRG_ROLLUP_FLAG
     , a.CURR_RECORD_TYPE_ID
     , a.CURRENCY_CODE
     , a.RBS_ELEMENT_ID
     , a.RBS_VERSION_ID
     , a.PLAN_VERSION_ID
     , a.PLAN_TYPE_ID
     , a.PLAN_TYPE_CODE   /* 4471527   */
     , a.TIME_DANGLING_FLAG
     , a.RATE_DANGLING_FLAG;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => ' PRORATE_TO_ENT_N_PJP1_D ');
    RAISE;
END;


PROCEDURE PRORATE_TO_ENT_PG_PJP1_SE( p_prorating_format varchar2) IS
BEGIN

    -- g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;

/* Commented for bug 4005006
    INSERT INTO pji_fp_aggr_pjp1_t   -- PA, GL calendar entries.
    (
       WORKER_ID
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , LINE_TYPE
     , TIME_DANGLING_FLAG
     , RATE_DANGLING_FLAG
     , PRG_LEVEL
   )
   SELECT
         g_worker_id WORKER_ID
       , fact.project_id  project_id
	 , fact.PROJECT_ORG_ID project_org_id
	 , fact.PROJECT_ORGANIZATION_ID project_organization_id
     -- , fact.PARTITION_ID PARTITION_ID
   	 , fact.PROJECT_ELEMENT_ID PROJECT_ELEMENT_ID
   	 , pa_cal.ent_period_id TIME_ID
   	 , fact.PERIOD_TYPE_ID PERIOD_TYPE_ID
   	 , 'E' CALENDAR_TYPE -- fact.CALENDAR_TYPE
     , fact.RBS_AGGR_LEVEL RBS_AGGR_LEVEL
     , fact.WBS_ROLLUP_FLAG WBS_ROLLUP_FLAG
     , fact.PRG_ROLLUP_FLAG PRG_ROLLUP_FLAG
     , fact.CURR_RECORD_TYPE_ID CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID PLAN_VERSION_ID
   	 , fact.PLAN_TYPE_ID PLAN_TYPE_ID
   	 , MAX(fact.RAW_COST)	 raw_cost
   	 , MAX(fact.BRDN_COST) BRDN_COST
   	 , MAX(fact.REVENUE) REVENUE
   	 , MAX(fact.BILL_RAW_COST) BILL_RAW_COST
   	 , MAX(fact.BILL_BRDN_COST) BILL_BRDN_COST
   	 , MAX(fact.BILL_LABOR_RAW_COST) BILL_LABOR_RAW_COST
   	 , MAX(fact.BILL_LABOR_BRDN_COST) BILL_LABOR_BRDN_COST
   	 , MAX(fact.BILL_LABOR_HRS) BILL_LABOR_HRS
   	 , MAX(fact.EQUIPMENT_RAW_COST) EQUIPMENT_RAW_COST
   	 , MAX(fact.EQUIPMENT_BRDN_COST) EQUIPMENT_BRDN_COST
   	 , MAX(fact.CAPITALIZABLE_RAW_COST) CAPITALIZABLE_RAW_COST
   	 , MAX(fact.CAPITALIZABLE_BRDN_COST) CAPITALIZABLE_BRDN_COST
   	 , MAX(fact.LABOR_RAW_COST) LABOR_RAW_COST
   	 , MAX(fact.LABOR_BRDN_COST) LABOR_BRDN_COST
   	 , MAX(fact.LABOR_HRS) LABOR_HRS
   	 , MAX(fact.LABOR_REVENUE) LABOR_REVENUE
   	 , MAX(fact.EQUIPMENT_HOURS) EQUIPMENT_HOURS
   	 , MAX(fact.BILLABLE_EQUIPMENT_HOURS) BILLABLE_EQUIPMENT_HOURS
   	 , MAX(fact.SUP_INV_COMMITTED_COST) SUP_INV_COMMITTED_COST
   	 , MAX(fact.PO_COMMITTED_COST) PO_COMMITTED_COST
   	 , MAX(fact.PR_COMMITTED_COST) PR_COMMITTED_COST
   	 , MAX(fact.OTH_COMMITTED_COST) OTH_COMMITTED_COST
       , MAX(fact.ACT_LABOR_HRS )
	 , MAX(fact.ACT_EQUIP_HRS )
	 , MAX(fact.ACT_LABOR_BRDN_COST )
	 , MAX(fact.ACT_EQUIP_BRDN_COST )
	 , MAX(fact.ACT_BRDN_COST )
	 , MAX(fact.ACT_RAW_COST )
	 , MAX(fact.ACT_REVENUE )
       , MAX(fact.ACT_LABOR_RAW_COST)
       , MAX(fact.ACT_EQUIP_RAW_COST)
	 , MAX(fact.ETC_LABOR_HRS )
	 , MAX(fact.ETC_EQUIP_HRS )
	 , MAX(fact.ETC_LABOR_BRDN_COST )
	 , MAX(fact.ETC_EQUIP_BRDN_COST )
	 , MAX(fact.ETC_BRDN_COST )
       , MAX(fact.ETC_RAW_COST )
       , MAX(fact.ETC_LABOR_RAW_COST)
       , MAX(fact.ETC_EQUIP_RAW_COST)
   	 , MAX(fact.CUSTOM1) CUSTOM1
   	 , MAX(fact.CUSTOM2) CUSTOM2
   	 , MAX(fact.CUSTOM3) CUSTOM3
   	 , MAX(fact.CUSTOM4) CUSTOM4
   	 , MAX(fact.CUSTOM5) CUSTOM5
   	 , MAX(fact.CUSTOM6) CUSTOM6
   	 , MAX(fact.CUSTOM7) CUSTOM7
   	 , MAX(fact.CUSTOM8) CUSTOM8
   	 , MAX(fact.CUSTOM9) CUSTOM9
   	 , MAX(fact.CUSTOM10) CUSTOM10
   	 , MAX(fact.CUSTOM11) CUSTOM11
   	 , MAX(fact.CUSTOM12) CUSTOM12
   	 , MAX(fact.CUSTOM13) CUSTOM13
   	 , MAX(fact.CUSTOM14) CUSTOM14
   	 , MAX(fact.CUSTOM15) CUSTOM15
   	 -- , DECODE ('E', 'E', MAX(pa_cal.start_date), 'S', MIN(pa_cal.start_date)) start_date
   	 -- , DECODE ('E', 'E', MAX(pa_cal.end_date), 'S', MIN(pa_cal.end_date))	 end_date
       , 'CF'   line_type
	 , fact.TIME_DANGLING_FLAG  TIME_DANGLING_FLAG
	 , fact.RATE_DANGLING_FLAG  RATE_DANGLING_FLAG
       , g_default_prg_level prg_level
   FROM   pji_fp_aggr_pjp1_t fact
        , pji_time_cal_period  non_pa_cal
        -- , pji_org_extr_info  orginfo
   	  , pji_time_ent_period  pa_cal
        , pji_fm_extr_plnver3_t  ver
   WHERE  fact.CALENDAR_TYPE IN ('P', 'G')
      AND fact.worker_id = g_worker_id
      AND non_pa_cal.cal_period_id = fact.time_id
      AND fact.line_type like 'OF%'
	AND fact.TIME_DANGLING_FLAG  IS NULL
	AND fact.RATE_DANGLING_FLAG  IS NULL
      AND ( non_pa_cal.start_date <= pa_cal.end_date AND non_pa_cal.end_date >= pa_cal.start_date )
      AND fact.period_type_id = 32
      AND fact.plan_version_id = ver.plan_version_id
      AND ver.wp_flag = 'N'
      AND ver.baselined_flag = 'Y'
	-- AND (ver.rbs_struct_version_id = fact.rbs_version_id  OR fact.rbs_version_id = -1)
      AND NVL(ver.rbs_struct_version_id, -1) = fact.rbs_version_id
   GROUP BY
       fact.project_id
	 , fact.PROJECT_ORG_ID
	 , fact.PROJECT_ORGANIZATION_ID
     -- , fact.PARTITION_ID
   	 , fact.PROJECT_ELEMENT_ID
   	 , pa_cal.ent_period_id
   	 , fact.PERIOD_TYPE_ID
   	 , fact.CALENDAR_TYPE
     , fact.RBS_AGGR_LEVEL
     , fact.WBS_ROLLUP_FLAG
     , fact.PRG_ROLLUP_FLAG
     , fact.CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID
   	 , fact.PLAN_TYPE_ID
	 , fact.TIME_DANGLING_FLAG
	 , fact.RATE_DANGLING_FLAG;
End of bug 4005006*/

    INSERT INTO pji_fp_aggr_pjp1_t   -- PA, GL calendar entries.
    (
       WORKER_ID
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
     , ACT_LABOR_HRS
     , ACT_EQUIP_HRS
     , ACT_LABOR_BRDN_COST
     , ACT_EQUIP_BRDN_COST
     , ACT_BRDN_COST
     , ACT_RAW_COST
     , ACT_REVENUE
     , ACT_LABOR_RAW_COST
     , ACT_EQUIP_RAW_COST
     , ETC_LABOR_HRS
     , ETC_EQUIP_HRS
     , ETC_LABOR_BRDN_COST
     , ETC_EQUIP_BRDN_COST
     , ETC_BRDN_COST
     , ETC_RAW_COST
     , ETC_LABOR_RAW_COST
     , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , TIME_DANGLING_FLAG
     , RATE_DANGLING_FLAG
     , PRG_LEVEL
     , PLAN_TYPE_CODE    /* 4471527 */
   )
   SELECT
           g_worker_id WORKER_ID
         , fact.project_id  project_id
	 , fact.PROJECT_ORG_ID project_org_id
	 , fact.PROJECT_ORGANIZATION_ID project_organization_id
   	 , fact.PROJECT_ELEMENT_ID PROJECT_ELEMENT_ID
   	 , pa_cal.ent_period_id TIME_ID
   	 , fact.PERIOD_TYPE_ID PERIOD_TYPE_ID
   	 , 'E' CALENDAR_TYPE -- fact.CALENDAR_TYPE
         , fact.RBS_AGGR_LEVEL RBS_AGGR_LEVEL
         , fact.WBS_ROLLUP_FLAG WBS_ROLLUP_FLAG
         , fact.PRG_ROLLUP_FLAG PRG_ROLLUP_FLAG
         , fact.CURR_RECORD_TYPE_ID CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID PLAN_VERSION_ID
   	 , fact.PLAN_TYPE_ID PLAN_TYPE_ID
   	 , SUM(fact.RAW_COST)	 raw_cost
   	 , SUM(fact.BRDN_COST) BRDN_COST
   	 , SUM(fact.REVENUE) REVENUE
   	 , SUM(fact.BILL_RAW_COST) BILL_RAW_COST
   	 , SUM(fact.BILL_BRDN_COST) BILL_BRDN_COST
   	 , SUM(fact.BILL_LABOR_RAW_COST) BILL_LABOR_RAW_COST
   	 , SUM(fact.BILL_LABOR_BRDN_COST) BILL_LABOR_BRDN_COST
   	 , SUM(fact.BILL_LABOR_HRS) BILL_LABOR_HRS
   	 , SUM(fact.EQUIPMENT_RAW_COST) EQUIPMENT_RAW_COST
   	 , SUM(fact.EQUIPMENT_BRDN_COST) EQUIPMENT_BRDN_COST
   	 , SUM(fact.CAPITALIZABLE_RAW_COST) CAPITALIZABLE_RAW_COST
   	 , SUM(fact.CAPITALIZABLE_BRDN_COST) CAPITALIZABLE_BRDN_COST
   	 , SUM(fact.LABOR_RAW_COST) LABOR_RAW_COST
   	 , SUM(fact.LABOR_BRDN_COST) LABOR_BRDN_COST
   	 , SUM(fact.LABOR_HRS) LABOR_HRS
   	 , SUM(fact.LABOR_REVENUE) LABOR_REVENUE
   	 , SUM(fact.EQUIPMENT_HOURS) EQUIPMENT_HOURS
   	 , SUM(fact.BILLABLE_EQUIPMENT_HOURS) BILLABLE_EQUIPMENT_HOURS
   	 , SUM(fact.SUP_INV_COMMITTED_COST) SUP_INV_COMMITTED_COST
   	 , SUM(fact.PO_COMMITTED_COST) PO_COMMITTED_COST
   	 , SUM(fact.PR_COMMITTED_COST) PR_COMMITTED_COST
   	 , SUM(fact.OTH_COMMITTED_COST) OTH_COMMITTED_COST
         , SUM(fact.ACT_LABOR_HRS )
	 , SUM(fact.ACT_EQUIP_HRS )
	 , SUM(fact.ACT_LABOR_BRDN_COST )
	 , SUM(fact.ACT_EQUIP_BRDN_COST )
	 , SUM(fact.ACT_BRDN_COST )
	 , SUM(fact.ACT_RAW_COST )
	 , SUM(fact.ACT_REVENUE )
         , SUM(fact.ACT_LABOR_RAW_COST)
         , SUM(fact.ACT_EQUIP_RAW_COST)
	 , SUM(fact.ETC_LABOR_HRS )
	 , SUM(fact.ETC_EQUIP_HRS )
	 , SUM(fact.ETC_LABOR_BRDN_COST )
	 , SUM(fact.ETC_EQUIP_BRDN_COST )
	 , SUM(fact.ETC_BRDN_COST )
         , SUM(fact.ETC_RAW_COST )
         , SUM(fact.ETC_LABOR_RAW_COST)
         , SUM(fact.ETC_EQUIP_RAW_COST)
   	 , SUM(fact.CUSTOM1) CUSTOM1
   	 , SUM(fact.CUSTOM2) CUSTOM2
   	 , SUM(fact.CUSTOM3) CUSTOM3
   	 , SUM(fact.CUSTOM4) CUSTOM4
   	 , SUM(fact.CUSTOM5) CUSTOM5
   	 , SUM(fact.CUSTOM6) CUSTOM6
   	 , SUM(fact.CUSTOM7) CUSTOM7
   	 , SUM(fact.CUSTOM8) CUSTOM8
   	 , SUM(fact.CUSTOM9) CUSTOM9
   	 , SUM(fact.CUSTOM10) CUSTOM10
   	 , SUM(fact.CUSTOM11) CUSTOM11
   	 , SUM(fact.CUSTOM12) CUSTOM12
   	 , SUM(fact.CUSTOM13) CUSTOM13
   	 , SUM(fact.CUSTOM14) CUSTOM14
   	 , SUM(fact.CUSTOM15) CUSTOM15
	 , fact.TIME_DANGLING_FLAG  TIME_DANGLING_FLAG
	 , fact.RATE_DANGLING_FLAG  RATE_DANGLING_FLAG
         , g_default_prg_level prg_level
         , fact.plan_type_code plan_type_code    /* 4471527 */
   FROM   pji_fp_aggr_pjp1_t fact
        , pji_time_cal_period_v  non_pa_cal
   	, pji_time_ent_period_v  pa_cal
        , pji_fm_extr_plnver3_t  ver
   WHERE  fact.CALENDAR_TYPE IN ('P', 'G')
      AND fact.worker_id = g_worker_id
      AND non_pa_cal.cal_period_id = fact.time_id
      AND fact.line_type like 'OF%'
      AND fact.TIME_DANGLING_FLAG  IS NULL
      AND fact.RATE_DANGLING_FLAG  IS NULL
      AND ( non_pa_cal.start_date <= pa_cal.end_date AND non_pa_cal.end_date >= pa_cal.start_date )
      AND fact.period_type_id = 32
      AND fact.plan_version_id = ver.plan_version_id
      AND fact.plan_type_code = ver.plan_type_code   /* 4471527 */
      AND ver.wp_flag = 'N'
      AND ver.baselined_flag = 'Y'
      -- AND (ver.rbs_struct_version_id = fact.rbs_version_id  OR fact.rbs_version_id = -1)
      AND NVL(ver.rbs_struct_version_id, -1) = fact.rbs_version_id
      AND DECODE(p_prorating_format,'S',
             DECODE(SIGN(non_pa_cal.start_Date-pa_cal.start_date),-1,0,1),
             DECODE(SIGN(non_pa_cal.end_Date - pa_cal.end_date), 1,0,1))=1
   GROUP BY
           fact.project_id
	 , fact.PROJECT_ORG_ID
	 , fact.PROJECT_ORGANIZATION_ID
   	 , fact.PROJECT_ELEMENT_ID
   	 , pa_cal.ent_period_id
   	 , fact.PERIOD_TYPE_ID
   	 , fact.CALENDAR_TYPE
         , fact.RBS_AGGR_LEVEL
         , fact.WBS_ROLLUP_FLAG
         , fact.PRG_ROLLUP_FLAG
         , fact.CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID
   	 , fact.PLAN_TYPE_ID
              , fact.PLAN_TYPE_CODE     /*4471527 */
	 , fact.TIME_DANGLING_FLAG
	 , fact.RATE_DANGLING_FLAG;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRORATE_TO_ENT_PG_PJP1_SE');
    RAISE;
END;


PROCEDURE PRORATE_TO_ENT_PG_FPRL_SE IS
BEGIN

    -- g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;

    INSERT INTO pji_fp_aggr_pjp1_t   -- PA, GL calendar entries.
    (
       WORKER_ID
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , PRG_LEVEL
     , PLAN_TYPE_CODE    /* 4471527 */
   )
   SELECT
         g_worker_id WORKER_ID
       , fact.project_id  project_id
	 , fact.PROJECT_ORG_ID project_org_id
	 , fact.PROJECT_ORGANIZATION_ID project_organization_id
     -- , fact.PARTITION_ID PARTITION_ID
   	 , fact.PROJECT_ELEMENT_ID PROJECT_ELEMENT_ID
   	 , pa_cal.ent_period_id TIME_ID
   	 , fact.PERIOD_TYPE_ID PERIOD_TYPE_ID
   	 , 'E' CALENDAR_TYPE -- fact.CALENDAR_TYPE
     , fact.RBS_AGGR_LEVEL RBS_AGGR_LEVEL
     , fact.WBS_ROLLUP_FLAG WBS_ROLLUP_FLAG
     , fact.PRG_ROLLUP_FLAG PRG_ROLLUP_FLAG
     , fact.CURR_RECORD_TYPE_ID CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID PLAN_VERSION_ID
   	 , fact.PLAN_TYPE_ID PLAN_TYPE_ID
   	 , MAX(fact.RAW_COST)	 raw_cost
   	 , MAX(fact.BRDN_COST) BRDN_COST
   	 , MAX(fact.REVENUE) REVENUE
   	 , MAX(fact.BILL_RAW_COST) BILL_RAW_COST
   	 , MAX(fact.BILL_BRDN_COST) BILL_BRDN_COST
   	 , MAX(fact.BILL_LABOR_RAW_COST) BILL_LABOR_RAW_COST
   	 , MAX(fact.BILL_LABOR_BRDN_COST) BILL_LABOR_BRDN_COST
   	 , MAX(fact.BILL_LABOR_HRS) BILL_LABOR_HRS
   	 , MAX(fact.EQUIPMENT_RAW_COST) EQUIPMENT_RAW_COST
   	 , MAX(fact.EQUIPMENT_BRDN_COST) EQUIPMENT_BRDN_COST
   	 , MAX(fact.CAPITALIZABLE_RAW_COST) CAPITALIZABLE_RAW_COST
   	 , MAX(fact.CAPITALIZABLE_BRDN_COST) CAPITALIZABLE_BRDN_COST
   	 , MAX(fact.LABOR_RAW_COST) LABOR_RAW_COST
   	 , MAX(fact.LABOR_BRDN_COST) LABOR_BRDN_COST
   	 , MAX(fact.LABOR_HRS) LABOR_HRS
   	 , MAX(fact.LABOR_REVENUE) LABOR_REVENUE
   	 , MAX(fact.EQUIPMENT_HOURS) EQUIPMENT_HOURS
   	 , MAX(fact.BILLABLE_EQUIPMENT_HOURS) BILLABLE_EQUIPMENT_HOURS
   	 , MAX(fact.SUP_INV_COMMITTED_COST) SUP_INV_COMMITTED_COST
   	 , MAX(fact.PO_COMMITTED_COST) PO_COMMITTED_COST
   	 , MAX(fact.PR_COMMITTED_COST) PR_COMMITTED_COST
   	 , MAX(fact.OTH_COMMITTED_COST) OTH_COMMITTED_COST
       , MAX(fact.ACT_LABOR_HRS )
	 , MAX(fact.ACT_EQUIP_HRS )
	 , MAX(fact.ACT_LABOR_BRDN_COST )
	 , MAX(fact.ACT_EQUIP_BRDN_COST )
	 , MAX(fact.ACT_BRDN_COST )
	 , MAX(fact.ACT_RAW_COST )
	 , MAX(fact.ACT_REVENUE )
       , MAX(fact.ACT_LABOR_RAW_COST)
       , MAX(fact.ACT_EQUIP_RAW_COST)
	 , MAX(fact.ETC_LABOR_HRS )
	 , MAX(fact.ETC_EQUIP_HRS )
	 , MAX(fact.ETC_LABOR_BRDN_COST )
	 , MAX(fact.ETC_EQUIP_BRDN_COST )
	 , MAX(fact.ETC_BRDN_COST )
       , MAX(fact.ETC_RAW_COST )
       , MAX(fact.ETC_LABOR_RAW_COST)
       , MAX(fact.ETC_EQUIP_RAW_COST)
   	 , MAX(fact.CUSTOM1) CUSTOM1
   	 , MAX(fact.CUSTOM2) CUSTOM2
   	 , MAX(fact.CUSTOM3) CUSTOM3
   	 , MAX(fact.CUSTOM4) CUSTOM4
   	 , MAX(fact.CUSTOM5) CUSTOM5
   	 , MAX(fact.CUSTOM6) CUSTOM6
   	 , MAX(fact.CUSTOM7) CUSTOM7
   	 , MAX(fact.CUSTOM8) CUSTOM8
   	 , MAX(fact.CUSTOM9) CUSTOM9
   	 , MAX(fact.CUSTOM10) CUSTOM10
   	 , MAX(fact.CUSTOM11) CUSTOM11
   	 , MAX(fact.CUSTOM12) CUSTOM12
   	 , MAX(fact.CUSTOM13) CUSTOM13
   	 , MAX(fact.CUSTOM14) CUSTOM14
   	 , MAX(fact.CUSTOM15) CUSTOM15
   	 -- , DECODE ('E', 'E', MAX(pa_cal.start_date), 'S', MIN(pa_cal.start_date)) start_date
   	 -- , DECODE ('E', 'E', MAX(pa_cal.end_date), 'S', MIN(pa_cal.end_date))	 end_date
       , g_default_prg_level prg_level
       , fact.plan_type_code   plan_type_code    /* 4471527 */
   FROM   pji_fp_xbs_accum_f  fact
       , PJI_FM_EXTR_PLNVER3_T ver
        , pji_time_cal_period  non_pa_cal
        -- , pji_org_extr_info  orginfo
   	  , pji_time_ent_period  pa_cal
   WHERE  non_pa_cal.cal_period_id = fact.time_id
      AND fact.period_type_id = 32
      AND ver.project_id = fact.project_id
      AND ver.plan_version_id = fact.plan_version_id
      AND ver.plan_type_code = fact.plan_type_code     /* 4471527 */
      AND ( non_pa_cal.start_date <= pa_cal.end_date AND non_pa_cal.end_date >= pa_cal.start_date )
      AND fact.period_type_id = 32
      AND ver.wp_flag = 'N'
      AND ver.baselined_flag = 'Y'
	-- AND (ver.rbs_struct_version_id = fact.rbs_version_id  OR fact.rbs_version_id = -1)
      AND NVL(ver.rbs_struct_version_id, -1) = fact.rbs_version_id
   GROUP BY
       fact.project_id
	 , fact.PROJECT_ORG_ID
	 , fact.PROJECT_ORGANIZATION_ID
     -- , fact.PARTITION_ID
   	 , fact.PROJECT_ELEMENT_ID
   	 , pa_cal.ent_period_id
   	 , fact.PERIOD_TYPE_ID
   	 , fact.CALENDAR_TYPE
     , fact.RBS_AGGR_LEVEL
     , fact.WBS_ROLLUP_FLAG
     , fact.PRG_ROLLUP_FLAG
     , fact.CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID
   	 , fact.PLAN_TYPE_ID
              , fact.PLAN_TYPE_CODE ;   /* 4471527 */

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRORATE_TO_ENT_PG_FPRL_SE');
    RAISE;
END;


PROCEDURE PRORATE_TO_ENT_N_PJP1_SE( p_prorating_format varchar2) IS
BEGIN

    -- g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;

/* Commented for bug 4005006

    INSERT INTO pji_fp_aggr_pjp1_t  -- Non time phased entries.
    (
       WORKER_ID
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , LINE_TYPE
     , TIME_DANGLING_FLAG
     , RATE_DANGLING_FLAG
     , PRG_LEVEL
   )
   SELECT
         g_worker_id WORKER_ID
       , fact.project_id  project_id
	 , fact.PROJECT_ORG_ID project_org_id
	 , fact.PROJECT_ORGANIZATION_ID project_organization_id
     -- , fact.PARTITION_ID PARTITION_ID
   	 , fact.PROJECT_ELEMENT_ID PROJECT_ELEMENT_ID
   	 , pa_cal.ent_period_id TIME_ID
   	 , 32 -- fact.PERIOD_TYPE_ID PERIOD_TYPE_ID
   	 , 'E' CALENDAR_TYPE -- fact.CALENDAR_TYPE
     , fact.RBS_AGGR_LEVEL RBS_AGGR_LEVEL
     , fact.WBS_ROLLUP_FLAG WBS_ROLLUP_FLAG
     , fact.PRG_ROLLUP_FLAG PRG_ROLLUP_FLAG
     , fact.CURR_RECORD_TYPE_ID CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID PLAN_VERSION_ID
   	 , fact.PLAN_TYPE_ID PLAN_TYPE_ID
   	 , MAX(fact.RAW_COST)	 raw_cost
   	 , MAX(fact.BRDN_COST) BRDN_COST
   	 , MAX(fact.REVENUE) REVENUE
   	 , MAX(fact.BILL_RAW_COST) BILL_RAW_COST
   	 , MAX(fact.BILL_BRDN_COST) BILL_BRDN_COST
   	 , MAX(fact.BILL_LABOR_RAW_COST) BILL_LABOR_RAW_COST
   	 , MAX(fact.BILL_LABOR_BRDN_COST) BILL_LABOR_BRDN_COST
   	 , MAX(fact.BILL_LABOR_HRS) BILL_LABOR_HRS
   	 , MAX(fact.EQUIPMENT_RAW_COST) EQUIPMENT_RAW_COST
   	 , MAX(fact.EQUIPMENT_BRDN_COST) EQUIPMENT_BRDN_COST
   	 , MAX(fact.CAPITALIZABLE_RAW_COST) CAPITALIZABLE_RAW_COST
   	 , MAX(fact.CAPITALIZABLE_BRDN_COST) CAPITALIZABLE_BRDN_COST
   	 , MAX(fact.LABOR_RAW_COST) LABOR_RAW_COST
   	 , MAX(fact.LABOR_BRDN_COST) LABOR_BRDN_COST
   	 , MAX(fact.LABOR_HRS) LABOR_HRS
   	 , MAX(fact.LABOR_REVENUE) LABOR_REVENUE
   	 , MAX(fact.EQUIPMENT_HOURS) EQUIPMENT_HOURS
   	 , MAX(fact.BILLABLE_EQUIPMENT_HOURS) BILLABLE_EQUIPMENT_HOURS
   	 , MAX(fact.SUP_INV_COMMITTED_COST) SUP_INV_COMMITTED_COST
   	 , MAX(fact.PO_COMMITTED_COST) PO_COMMITTED_COST
   	 , MAX(fact.PR_COMMITTED_COST) PR_COMMITTED_COST
   	 , MAX(fact.OTH_COMMITTED_COST) OTH_COMMITTED_COST
       , MAX(fact.ACT_LABOR_HRS )
	 , MAX(fact.ACT_EQUIP_HRS )
	 , MAX(fact.ACT_LABOR_BRDN_COST )
	 , MAX(fact.ACT_EQUIP_BRDN_COST )
	 , MAX(fact.ACT_BRDN_COST )
	 , MAX(fact.ACT_RAW_COST )
	 , MAX(fact.ACT_REVENUE )
       , MAX(fact.ACT_LABOR_RAW_COST)
       , MAX(fact.ACT_EQUIP_RAW_COST)
	 , MAX(fact.ETC_LABOR_HRS )
	 , MAX(fact.ETC_EQUIP_HRS )
	 , MAX(fact.ETC_LABOR_BRDN_COST )
	 , MAX(fact.ETC_EQUIP_BRDN_COST )
	 , MAX(fact.ETC_BRDN_COST )
       , MAX(fact.ETC_RAW_COST )
       , MAX(fact.ETC_LABOR_RAW_COST)
       , MAX(fact.ETC_EQUIP_RAW_COST)
   	 , MAX(fact.CUSTOM1) CUSTOM1
   	 , MAX(fact.CUSTOM2) CUSTOM2
   	 , MAX(fact.CUSTOM3) CUSTOM3
   	 , MAX(fact.CUSTOM4) CUSTOM4
   	 , MAX(fact.CUSTOM5) CUSTOM5
   	 , MAX(fact.CUSTOM6) CUSTOM6
   	 , MAX(fact.CUSTOM7) CUSTOM7
   	 , MAX(fact.CUSTOM8) CUSTOM8
   	 , MAX(fact.CUSTOM9) CUSTOM9
   	 , MAX(fact.CUSTOM10) CUSTOM10
   	 , MAX(fact.CUSTOM11) CUSTOM11
   	 , MAX(fact.CUSTOM12) CUSTOM12
   	 , MAX(fact.CUSTOM13) CUSTOM13
   	 , MAX(fact.CUSTOM14) CUSTOM14
   	 , MAX(fact.CUSTOM15) CUSTOM15
       , 'CN'   line_type
	 , fact.TIME_DANGLING_FLAG  TIME_DANGLING_FLAG
	 , fact.RATE_DANGLING_FLAG  RATE_DANGLING_FLAG
       , g_default_prg_level prg_level
   FROM   pji_fp_aggr_pjp1_t fact
   	  , pji_time_ent_period  pa_cal
        , pji_fm_extr_plnver3_t  ver
   WHERE  fact.CALENDAR_TYPE = 'A'
      AND fact.worker_id = g_worker_id
      AND fact.line_type = 'NTP'
      AND fact.start_date IS NOT NULL
      AND fact.end_date IS NOT NULL
	AND fact.TIME_DANGLING_FLAG  IS NULL
	AND fact.RATE_DANGLING_FLAG  IS NULL
      AND (
	       (     pa_cal.start_date >= fact.start_date
               AND pa_cal.end_date <= fact.end_date ) -- fsps,pefe
	    OR (     pa_cal.start_date <= fact.start_date
               AND pa_cal.end_date >= fact.end_date ) -- psfs,fepe
	    OR (     pa_cal.start_date <= fact.start_date
               AND pa_cal.end_date <= fact.end_date
               AND pa_cal.end_date >= fact.start_date ) -- psfspefe
	    OR (     pa_cal.start_date >= fact.start_date
               AND pa_cal.end_date >= fact.end_date
               AND pa_cal.start_date <= fact.end_date )  -- fspsfepe
          )
      AND fact.period_type_id = 2048
      AND fact.plan_version_id = ver.plan_version_id
      AND ver.wp_flag = 'N'
      AND ver.baselined_flag = 'Y'
      AND ver.time_phased_type_code = 'N'
  	-- AND (ver.rbs_struct_version_id = fact.rbs_version_id  OR fact.rbs_version_id = -1)
      AND NVL(ver.rbs_struct_version_id, -1) = fact.rbs_version_id
   GROUP BY
       fact.project_id
	 , fact.PROJECT_ORG_ID
	 , fact.PROJECT_ORGANIZATION_ID
     -- , fact.PARTITION_ID
   	 , fact.PROJECT_ELEMENT_ID
   	 , pa_cal.ent_period_id
   	 , fact.PERIOD_TYPE_ID
   	 , fact.CALENDAR_TYPE
     , fact.RBS_AGGR_LEVEL
     , fact.WBS_ROLLUP_FLAG
     , fact.PRG_ROLLUP_FLAG
     , fact.CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID
   	 , fact.PLAN_TYPE_ID
	 , fact.TIME_DANGLING_FLAG
	 , fact.RATE_DANGLING_FLAG;

End of bug 4005006*/

    INSERT INTO pji_fp_aggr_pjp1_t  -- Non time phased entries.
    (
       WORKER_ID
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
     , ACT_LABOR_HRS
     , ACT_EQUIP_HRS
     , ACT_LABOR_BRDN_COST
     , ACT_EQUIP_BRDN_COST
     , ACT_BRDN_COST
     , ACT_RAW_COST
     , ACT_REVENUE
     , ACT_LABOR_RAW_COST
     , ACT_EQUIP_RAW_COST
     , ETC_LABOR_HRS
     , ETC_EQUIP_HRS
     , ETC_LABOR_BRDN_COST
     , ETC_EQUIP_BRDN_COST
     , ETC_BRDN_COST
     , ETC_RAW_COST
     , ETC_LABOR_RAW_COST
     , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , TIME_DANGLING_FLAG
     , RATE_DANGLING_FLAG
     , PRG_LEVEL
     , PLAN_TYPE_CODE     /* 4471527 */
   )
   SELECT
           g_worker_id WORKER_ID
         , fact.project_id  project_id
	 , fact.PROJECT_ORG_ID project_org_id
	 , fact.PROJECT_ORGANIZATION_ID project_organization_id
   	 , fact.PROJECT_ELEMENT_ID PROJECT_ELEMENT_ID
   	 , pa_cal.ent_period_id TIME_ID
   	 , 32 -- fact.PERIOD_TYPE_ID PERIOD_TYPE_ID
   	 , 'E' CALENDAR_TYPE -- fact.CALENDAR_TYPE
         , fact.RBS_AGGR_LEVEL RBS_AGGR_LEVEL
         , fact.WBS_ROLLUP_FLAG WBS_ROLLUP_FLAG
         , fact.PRG_ROLLUP_FLAG PRG_ROLLUP_FLAG
         , fact.CURR_RECORD_TYPE_ID CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID PLAN_VERSION_ID
   	 , fact.PLAN_TYPE_ID PLAN_TYPE_ID
   	 , SUM(fact.RAW_COST)	 raw_cost
   	 , SUM(fact.BRDN_COST) BRDN_COST
   	 , SUM(fact.REVENUE) REVENUE
   	 , SUM(fact.BILL_RAW_COST) BILL_RAW_COST
   	 , SUM(fact.BILL_BRDN_COST) BILL_BRDN_COST
   	 , SUM(fact.BILL_LABOR_RAW_COST) BILL_LABOR_RAW_COST
   	 , SUM(fact.BILL_LABOR_BRDN_COST) BILL_LABOR_BRDN_COST
   	 , SUM(fact.BILL_LABOR_HRS) BILL_LABOR_HRS
   	 , SUM(fact.EQUIPMENT_RAW_COST) EQUIPMENT_RAW_COST
   	 , SUM(fact.EQUIPMENT_BRDN_COST) EQUIPMENT_BRDN_COST
   	 , SUM(fact.CAPITALIZABLE_RAW_COST) CAPITALIZABLE_RAW_COST
   	 , SUM(fact.CAPITALIZABLE_BRDN_COST) CAPITALIZABLE_BRDN_COST
   	 , SUM(fact.LABOR_RAW_COST) LABOR_RAW_COST
   	 , SUM(fact.LABOR_BRDN_COST) LABOR_BRDN_COST
   	 , SUM(fact.LABOR_HRS) LABOR_HRS
   	 , SUM(fact.LABOR_REVENUE) LABOR_REVENUE
   	 , SUM(fact.EQUIPMENT_HOURS) EQUIPMENT_HOURS
   	 , SUM(fact.BILLABLE_EQUIPMENT_HOURS) BILLABLE_EQUIPMENT_HOURS
   	 , SUM(fact.SUP_INV_COMMITTED_COST) SUP_INV_COMMITTED_COST
   	 , SUM(fact.PO_COMMITTED_COST) PO_COMMITTED_COST
   	 , SUM(fact.PR_COMMITTED_COST) PR_COMMITTED_COST
   	 , SUM(fact.OTH_COMMITTED_COST) OTH_COMMITTED_COST
         , SUM(fact.ACT_LABOR_HRS )
	 , SUM(fact.ACT_EQUIP_HRS )
	 , SUM(fact.ACT_LABOR_BRDN_COST )
	 , SUM(fact.ACT_EQUIP_BRDN_COST )
	 , SUM(fact.ACT_BRDN_COST )
	 , SUM(fact.ACT_RAW_COST )
	 , SUM(fact.ACT_REVENUE )
         , SUM(fact.ACT_LABOR_RAW_COST)
         , SUM(fact.ACT_EQUIP_RAW_COST)
	 , SUM(fact.ETC_LABOR_HRS )
	 , SUM(fact.ETC_EQUIP_HRS )
	 , SUM(fact.ETC_LABOR_BRDN_COST )
	 , SUM(fact.ETC_EQUIP_BRDN_COST )
	 , SUM(fact.ETC_BRDN_COST )
         , SUM(fact.ETC_RAW_COST )
         , SUM(fact.ETC_LABOR_RAW_COST)
         , SUM(fact.ETC_EQUIP_RAW_COST)
   	 , SUM(fact.CUSTOM1) CUSTOM1
   	 , SUM(fact.CUSTOM2) CUSTOM2
   	 , SUM(fact.CUSTOM3) CUSTOM3
   	 , SUM(fact.CUSTOM4) CUSTOM4
   	 , SUM(fact.CUSTOM5) CUSTOM5
   	 , SUM(fact.CUSTOM6) CUSTOM6
   	 , SUM(fact.CUSTOM7) CUSTOM7
   	 , SUM(fact.CUSTOM8) CUSTOM8
   	 , SUM(fact.CUSTOM9) CUSTOM9
   	 , SUM(fact.CUSTOM10) CUSTOM10
   	 , SUM(fact.CUSTOM11) CUSTOM11
   	 , SUM(fact.CUSTOM12) CUSTOM12
   	 , SUM(fact.CUSTOM13) CUSTOM13
   	 , SUM(fact.CUSTOM14) CUSTOM14
   	 , SUM(fact.CUSTOM15) CUSTOM15
	 , fact.TIME_DANGLING_FLAG  TIME_DANGLING_FLAG
	 , fact.RATE_DANGLING_FLAG  RATE_DANGLING_FLAG
         , g_default_prg_level prg_level
             , fact.plan_type_code  plan_type_code   /* 4471527 */
   FROM    pji_fp_aggr_pjp1_t fact
   	 , pji_time_ent_period_v  pa_cal
         , pji_fm_extr_plnver3_t  ver
   WHERE  fact.CALENDAR_TYPE = 'A'
      AND fact.worker_id = g_worker_id
      AND fact.line_type = 'NTP'
      AND fact.start_date IS NOT NULL
      AND fact.end_date IS NOT NULL
      AND fact.TIME_DANGLING_FLAG  IS NULL
      AND fact.RATE_DANGLING_FLAG  IS NULL
      AND ( fact.start_date <= pa_cal.end_date AND fact.end_date >= pa_cal.start_date )
      AND DECODE(p_prorating_format,'S',
             DECODE(SIGN(fact.start_Date-pa_cal.start_date),-1,0,1),
             DECODE(SIGN(fact.end_Date - pa_cal.end_date), 1,0,1))=1
      AND fact.period_type_id = 2048
      AND fact.plan_version_id = ver.plan_version_id
      AND fact.plan_type_code = ver.plan_type_code   /* 4471527 */
      AND ver.wp_flag = 'N'
      AND ver.baselined_flag = 'Y'
      AND ver.time_phased_type_code = 'N'
  	-- AND (ver.rbs_struct_version_id = fact.rbs_version_id  OR fact.rbs_version_id = -1)
      AND NVL(ver.rbs_struct_version_id, -1) = fact.rbs_version_id
   GROUP BY
           fact.project_id
	 , fact.PROJECT_ORG_ID
	 , fact.PROJECT_ORGANIZATION_ID
   	 , fact.PROJECT_ELEMENT_ID
   	 , pa_cal.ent_period_id
   	 , fact.PERIOD_TYPE_ID
 	 , fact.CALENDAR_TYPE
         , fact.RBS_AGGR_LEVEL
         , fact.WBS_ROLLUP_FLAG
         , fact.PRG_ROLLUP_FLAG
         , fact.CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID
   	 , fact.PLAN_TYPE_ID
              , fact.PLAN_TYPE_CODE   /* 4471527 */
	 , fact.TIME_DANGLING_FLAG
	 , fact.RATE_DANGLING_FLAG;


EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRORATE_TO_ENT_N_PJP1_SE');
    RAISE;
END;


PROCEDURE PRORATE_TO_PAGL_PGE_PJP1_D (p_calendar_type   IN   VARCHAR2 := NULL) IS
BEGIN

    -- g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;

/* Commented for bug 4005006
    INSERT INTO pji_fp_aggr_pjp1_t
    (
       worker_id
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
     , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , LINE_TYPE
     , TIME_DANGLING_FLAG
     , RATE_DANGLING_FLAG
     , PRG_LEVEL
	)
   SELECT
       g_worker_id worker_id
     , a.PROJECT_ID
     , a.PROJECT_ORG_ID
     , a.PROJECT_ORGANIZATION_ID
     , a.PROJECT_ELEMENT_ID
     , a.TIME_ID
     , a.PERIOD_TYPE_ID
     , a.CALENDAR_TYPE
     , a.RBS_AGGR_LEVEL
     , a.WBS_ROLLUP_FLAG
     , a.PRG_ROLLUP_FLAG
     , a.CURR_RECORD_TYPE_ID
     , a.CURRENCY_CODE
     , a.RBS_ELEMENT_ID
     , a.RBS_VERSION_ID
     , a.PLAN_VERSION_ID
     , a.PLAN_TYPE_ID
     , SUM(a.RAW_COST       )
     , SUM(a.BRDN_COST 	)
     , SUM(a.REVENUE	)
     , SUM(a.BILL_RAW_COST )
     , SUM(a.BILL_BRDN_COST )
     , SUM(a.BILL_LABOR_RAW_COST )
     , SUM(a.BILL_LABOR_BRDN_COST )
     , SUM(a.BILL_LABOR_HRS )
     , SUM(a.EQUIPMENT_RAW_COST )
     , SUM(a.EQUIPMENT_BRDN_COST )
     , SUM(a.CAPITALIZABLE_RAW_COST )
     , SUM(a.CAPITALIZABLE_BRDN_COST )
     , SUM(a.LABOR_RAW_COST )
     , SUM(a.LABOR_BRDN_COST)
     , SUM(a.LABOR_HRS )
     , SUM(a.LABOR_REVENUE )
     , SUM(a.EQUIPMENT_HOURS )
     , SUM(a.BILLABLE_EQUIPMENT_HOURS)
     , SUM(a.SUP_INV_COMMITTED_COST)
     , SUM(a.PO_COMMITTED_COST )
     , SUM(a.PR_COMMITTED_COST )
     , SUM(a.OTH_COMMITTED_COST)
       , SUM(a.ACT_LABOR_HRS)
	   , SUM(a.ACT_EQUIP_HRS)
	   , SUM(a.ACT_LABOR_BRDN_COST)
	   , SUM(a.ACT_EQUIP_BRDN_COST)
	   , SUM(a.ACT_BRDN_COST    )
	   , SUM(a.ACT_RAW_COST    )
	   , SUM(a.ACT_REVENUE    )
         , SUM(a.ACT_LABOR_RAW_COST)
         , SUM(a.ACT_EQUIP_RAW_COST)
	   , SUM(a.ETC_LABOR_HRS         )
	   , SUM(a.ETC_EQUIP_HRS        )
	   , SUM(a.ETC_LABOR_BRDN_COST )
	   , SUM(a.ETC_EQUIP_BRDN_COST)
	   , SUM(a.ETC_BRDN_COST )
         , SUM(a.ETC_RAW_COST)
         , SUM(a.ETC_LABOR_RAW_COST)
         , SUM(a.ETC_EQUIP_RAW_COST)
     , SUM(a.CUSTOM1	)
     , SUM(a.CUSTOM2	)
     , SUM(a.CUSTOM3	)
     , SUM(a.CUSTOM4	)
     , SUM(a.CUSTOM5	)
     , SUM(a.CUSTOM6	)
     , SUM(a.CUSTOM7	)
     , SUM(a.CUSTOM8	)
     , SUM(a.CUSTOM9	)
     , SUM(a.CUSTOM10	)
     , SUM(a.CUSTOM11	)
     , SUM(a.CUSTOM12	)
     , SUM(a.CUSTOM13	)
     , SUM(a.CUSTOM14	)
     , SUM(a.CUSTOM15	)
	 , a.LINE_TYPE
	 , a.TIME_DANGLING_FLAG
	 , a.RATE_DANGLING_FLAG
       , g_default_prg_level prg_level
   FROM (
   SELECT
         fact.project_id  project_id
   	 , fact.project_ORG_ID project_ORG_ID
   	 , fact.project_ORGANIZATION_ID project_ORGANIZATION_ID
     -- , fact.PARTITION_ID PARTITION_ID
   	 , fact.PROJECT_ELEMENT_ID PROJECT_ELEMENT_ID
   	 , pa_cal.cal_period_id TIME_ID
   	 , fact.PERIOD_TYPE_ID PERIOD_TYPE_ID
   	 , DECODE(fact.CALENDAR_TYPE, 'P', 'G', 'G', 'P') CALENDAR_TYPE
     , fact.RBS_AGGR_LEVEL
     , fact.WBS_ROLLUP_FLAG
     , fact.PRG_ROLLUP_FLAG
   	 , fact.CURR_RECORD_TYPE_ID CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID PLAN_VERSION_ID
	 , fact.PLAN_TYPE_ID  PLAN_TYPE_ID
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.raw_cost
			  , '1-1'  , fact.raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			 , '00'   , fact.brdn_cost
			 , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '0-1'  , fact.brdn_cost
			 , '1-1'  , fact.brdn_cost
			 , 0  ) -- end decode
			  , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			 , '00'   , fact.revenue
			 , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '0-1'  , fact.revenue
			 , '1-1'  , fact.revenue
			 , 0  ) -- end decode
			  , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	revenue
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.bill_raw_cost
			  , '1-1'  , fact.bill_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.bill_brdn_cost
			  , '1-1'  , fact.bill_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_labor_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.bill_labor_raw_cost
			  , '1-1'  , fact.bill_labor_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_labor_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_labor_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.bill_labor_brdn_cost
			  , '1-1'  , fact.bill_labor_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_labor_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_labor_hrs
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.bill_labor_hrs
			  , '1-1'  , fact.bill_labor_hrs
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_labor_hrs
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.equipment_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.equipment_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.equipment_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.equipment_raw_cost
			  , '1-1'  , fact.equipment_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	equipment_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.equipment_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.equipment_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.equipment_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.equipment_brdn_cost
			  , '1-1'  , fact.equipment_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	equipment_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.capitalizable_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.capitalizable_raw_cost
			  , '1-1'  , fact.capitalizable_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	capitalizable_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.capitalizable_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.capitalizable_brdn_cost
			  , '1-1'  , fact.capitalizable_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	capitalizable_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.labor_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.labor_raw_cost
			  , '1-1'  , fact.labor_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	labor_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.labor_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.labor_brdn_cost
			  , '1-1'  , fact.labor_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	labor_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.labor_hrs
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.labor_hrs
			  , '1-1'  , fact.labor_hrs
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	labor_hrs
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.labor_revenue
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.labor_revenue
			  , '1-1'  , fact.labor_revenue
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	labor_revenue
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.equipment_hours
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.equipment_hours
			  , '1-1'  , fact.equipment_hours
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	equipment_hours
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.billable_equipment_hours
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.billable_equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.billable_equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.billable_equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.billable_equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.billable_equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.billable_equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.billable_equipment_hours
			  , '1-1'  , fact.billable_equipment_hours
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	billable_equipment_hours
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.sup_inv_committed_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.sup_inv_committed_cost
			  , '1-1'  , fact.sup_inv_committed_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	sup_inv_committed_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.po_committed_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.po_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.po_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.po_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.po_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.po_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.po_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.po_committed_cost
			  , '1-1'  , fact.po_committed_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	po_committed_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.pr_committed_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.pr_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.pr_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.pr_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.pr_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.pr_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.pr_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.pr_committed_cost
			  , '1-1'  , fact.pr_committed_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	pr_committed_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.oth_committed_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.oth_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.oth_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.oth_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.oth_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.oth_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.oth_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.oth_committed_cost
			  , '1-1'  , fact.oth_committed_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	oth_committed_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_LABOR_HRS
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_LABOR_HRS
			  , '1-1'  , fact.ACT_LABOR_HRS
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_LABOR_HRS
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_EQUIP_HRS
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_EQUIP_HRS
			  , '1-1'  , fact.ACT_EQUIP_HRS
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_EQUIP_HRS
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_LABOR_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_LABOR_BRDN_COST
			  , '1-1'  , fact.ACT_LABOR_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_LABOR_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_EQUIP_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_EQUIP_BRDN_COST
			  , '1-1'  , fact.ACT_EQUIP_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_EQUIP_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_BRDN_COST
			  , '1-1'  , fact.ACT_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_RAW_COST
			  , '1-1'  , fact.ACT_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_REVENUE
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_REVENUE / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_REVENUE / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_REVENUE / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_REVENUE / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_REVENUE / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_REVENUE / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_REVENUE
			  , '1-1'  , fact.ACT_REVENUE
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_REVENUE
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_LABOR_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_LABOR_RAW_COST
			  , '1-1'  , fact.ACT_LABOR_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_LABOR_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_EQUIP_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_EQUIP_RAW_COST
			  , '1-1'  , fact.ACT_EQUIP_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_EQUIP_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_LABOR_HRS
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_LABOR_HRS
			  , '1-1'  , fact.ETC_LABOR_HRS
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_LABOR_HRS
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_EQUIP_HRS
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_EQUIP_HRS
			  , '1-1'  , fact.ETC_EQUIP_HRS
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_EQUIP_HRS
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_LABOR_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_LABOR_BRDN_COST
			  , '1-1'  , fact.ETC_LABOR_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_LABOR_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_EQUIP_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_EQUIP_BRDN_COST
			  , '1-1'  , fact.ETC_EQUIP_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_EQUIP_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_BRDN_COST
			  , '1-1'  , fact.ETC_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_RAW_COST
			  , '1-1'  , fact.ETC_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_LABOR_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_LABOR_RAW_COST
			  , '1-1'  , fact.ETC_LABOR_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_LABOR_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_EQUIP_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_EQUIP_RAW_COST
			  , '1-1'  , fact.ETC_EQUIP_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_EQUIP_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom1
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom1 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom1 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom1 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom1 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom1 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom1 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom1
			  , '1-1'  , fact.custom1
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom1
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom2
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom2 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom2 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom2 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom2 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom2 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom2 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom2
			  , '1-1'  , fact.custom2
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom2
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom3
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom3 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom3 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom3 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom3 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom3 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom3 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom3
			  , '1-1'  , fact.custom3
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom3
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom4
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom4 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom4 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom4 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom4 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom4 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom4 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom4
			  , '1-1'  , fact.custom4
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom4
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom5
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom5 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom5 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom5 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom5 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom5 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom5 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom5
			  , '1-1'  , fact.custom5
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom5
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom6
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom6 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom6 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom6 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom6 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom6 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom6 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom6
			  , '1-1'  , fact.custom6
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom6
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom7
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom7 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom7 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom7 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom7 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom7 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom7 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom7
			  , '1-1'  , fact.custom7
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom7
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom8
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom8 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom8 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom8 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom8 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom8 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom8 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom8
			  , '1-1'  , fact.custom8
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom8
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom9
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom9 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom9 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom9 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom9 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom9 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom9 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom9
			  , '1-1'  , fact.custom9
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom9
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom10
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom10 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom10 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom10 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom10 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom10 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom10 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom10
			  , '1-1'  , fact.custom10
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom10
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom11
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom11 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom11 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom11 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom11 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom11 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom11 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom11
			  , '1-1'  , fact.custom11
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom11
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom12
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom12 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom12 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom12 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom12 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom12 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom12 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom12
			  , '1-1'  , fact.custom12
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom12
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom13
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom13 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom13 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom13 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom13 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom13 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom13 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom13
			  , '1-1'  , fact.custom13
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom13
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom14
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom14 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom14 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom14 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom14 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom14 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom14 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom14
			  , '1-1'  , fact.custom14
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom14
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom15
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom15 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom15 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom15 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom15 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom15 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom15 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom15
			  , '1-1'  , fact.custom15
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom15
     , 'CF'   line_type
	 , fact.time_dangling_flag time_dangling_flag
	 , fact.rate_dangling_flag rate_dangling_flag
                FROM   pji_fp_aggr_pjp1_t fact
        , pji_time_cal_period  non_pa_cal
   	 , pji_org_extr_info  orginfo
   	 , pji_time_cal_period  pa_cal
       , pji_fm_extr_plnver3_t  ver
   WHERE  1=1
      AND fact.CALENDAR_TYPE <> p_calendar_type
      AND fact.worker_id = g_worker_id
      AND fact.CALENDAR_TYPE IN ('P', 'G')
      AND non_pa_cal.cal_period_id = fact.time_id
      AND orginfo.org_id = fact.PROJECT_ORG_ID
      AND DECODE(fact.calendar_type, 'P', orginfo.gl_calendar_id, 'G', orginfo.pa_calendar_id) = pa_cal.calendar_id
      AND (
	       ( pa_cal.start_date >= non_pa_cal.start_date  AND pa_cal.end_date <= non_pa_cal.end_date )
	    OR ( pa_cal.start_date <= non_pa_cal.start_date  AND pa_cal.end_date >= non_pa_cal.end_date )
	    OR ( pa_cal.start_date <= non_pa_cal.start_date  AND pa_cal.end_date <= non_pa_cal.end_date AND pa_cal.end_date >= non_pa_cal.start_date )
	    OR ( pa_cal.start_date >= non_pa_cal.start_date  AND pa_cal.end_date >= non_pa_cal.end_date AND pa_cal.start_date <= non_pa_cal.end_date )
          )
	AND fact.time_dangling_flag IS NULL
	AND fact.rate_dangling_flag IS NULL
      AND fact.period_type_id = 32
      AND fact.line_type like 'OF%'
      AND fact.plan_version_id = ver.plan_version_id
      AND ver.wp_flag = 'N'
      AND ver.baselined_flag = 'Y'
	-- AND (ver.rbs_struct_version_id = fact.rbs_version_id  OR fact.rbs_version_id = -1)
      AND NVL(ver.rbs_struct_version_id, -1) = fact.rbs_version_id
	  ) a
	  GROUP BY
	   a.PROJECT_ID
     , a.PROJECT_ORG_ID
     , a.PROJECT_ORGANIZATION_ID
     , a.PROJECT_ELEMENT_ID
     , a.TIME_ID
     , a.PERIOD_TYPE_ID
     , a.CALENDAR_TYPE
     , a.RBS_AGGR_LEVEL
     , a.WBS_ROLLUP_FLAG
     , a.PRG_ROLLUP_FLAG
     , a.CURR_RECORD_TYPE_ID
     , a.CURRENCY_CODE
     , a.RBS_ELEMENT_ID
     , a.RBS_VERSION_ID
     , a.PLAN_VERSION_ID
     , a.PLAN_TYPE_ID
	 , a.LINE_TYPE
	 , a.TIME_DANGLING_FLAG
	 , a.RATE_DANGLING_FLAG;
  End for 4005006*/

    INSERT INTO pji_fp_aggr_pjp1_t
    (
       worker_id
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
     , ACT_LABOR_HRS
     , ACT_EQUIP_HRS
     , ACT_LABOR_BRDN_COST
     , ACT_EQUIP_BRDN_COST
     , ACT_BRDN_COST
     , ACT_RAW_COST
     , ACT_REVENUE
     , ACT_LABOR_RAW_COST
     , ACT_EQUIP_RAW_COST
     , ETC_LABOR_HRS
     , ETC_EQUIP_HRS
     , ETC_LABOR_BRDN_COST
     , ETC_EQUIP_BRDN_COST
     , ETC_BRDN_COST
     , ETC_RAW_COST
     , ETC_LABOR_RAW_COST
     , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , TIME_DANGLING_FLAG
     , RATE_DANGLING_FLAG
     , PRG_LEVEL
     , PLAN_TYPE_CODE        /* 4471527 */
	)
   SELECT
       g_worker_id worker_id
     , a.PROJECT_ID
     , a.PROJECT_ORG_ID
     , a.PROJECT_ORGANIZATION_ID
     , a.PROJECT_ELEMENT_ID
     , a.TIME_ID
     , a.PERIOD_TYPE_ID
     , a.CALENDAR_TYPE
     , a.RBS_AGGR_LEVEL
     , a.WBS_ROLLUP_FLAG
     , a.PRG_ROLLUP_FLAG
     , a.CURR_RECORD_TYPE_ID
     , a.CURRENCY_CODE
     , a.RBS_ELEMENT_ID
     , a.RBS_VERSION_ID
     , a.PLAN_VERSION_ID
     , a.PLAN_TYPE_ID
     , SUM(a.RAW_COST       )
     , SUM(a.BRDN_COST 	)
     , SUM(a.REVENUE	)
     , SUM(a.BILL_RAW_COST )
     , SUM(a.BILL_BRDN_COST )
     , SUM(a.BILL_LABOR_RAW_COST )
     , SUM(a.BILL_LABOR_BRDN_COST )
     , SUM(a.BILL_LABOR_HRS )
     , SUM(a.EQUIPMENT_RAW_COST )
     , SUM(a.EQUIPMENT_BRDN_COST )
     , SUM(a.CAPITALIZABLE_RAW_COST )
     , SUM(a.CAPITALIZABLE_BRDN_COST )
     , SUM(a.LABOR_RAW_COST )
     , SUM(a.LABOR_BRDN_COST)
     , SUM(a.LABOR_HRS )
     , SUM(a.LABOR_REVENUE )
     , SUM(a.EQUIPMENT_HOURS )
     , SUM(a.BILLABLE_EQUIPMENT_HOURS)
     , SUM(a.SUP_INV_COMMITTED_COST)
     , SUM(a.PO_COMMITTED_COST )
     , SUM(a.PR_COMMITTED_COST )
     , SUM(a.OTH_COMMITTED_COST)
     , SUM(a.ACT_LABOR_HRS)
     , SUM(a.ACT_EQUIP_HRS)
     , SUM(a.ACT_LABOR_BRDN_COST)
     , SUM(a.ACT_EQUIP_BRDN_COST)
     , SUM(a.ACT_BRDN_COST    )
     , SUM(a.ACT_RAW_COST    )
     , SUM(a.ACT_REVENUE    )
     , SUM(a.ACT_LABOR_RAW_COST)
     , SUM(a.ACT_EQUIP_RAW_COST)
     , SUM(a.ETC_LABOR_HRS         )
     , SUM(a.ETC_EQUIP_HRS        )
     , SUM(a.ETC_LABOR_BRDN_COST )
     , SUM(a.ETC_EQUIP_BRDN_COST)
     , SUM(a.ETC_BRDN_COST )
     , SUM(a.ETC_RAW_COST)
     , SUM(a.ETC_LABOR_RAW_COST)
     , SUM(a.ETC_EQUIP_RAW_COST)
     , SUM(a.CUSTOM1	)
     , SUM(a.CUSTOM2	)
     , SUM(a.CUSTOM3	)
     , SUM(a.CUSTOM4	)
     , SUM(a.CUSTOM5	)
     , SUM(a.CUSTOM6	)
     , SUM(a.CUSTOM7	)
     , SUM(a.CUSTOM8	)
     , SUM(a.CUSTOM9	)
     , SUM(a.CUSTOM10	)
     , SUM(a.CUSTOM11	)
     , SUM(a.CUSTOM12	)
     , SUM(a.CUSTOM13	)
     , SUM(a.CUSTOM14	)
     , SUM(a.CUSTOM15	)
     , a.TIME_DANGLING_FLAG
     , a.RATE_DANGLING_FLAG
     , g_default_prg_level prg_level
     , a.plan_type_code plan_type_code   /* 4471527 */
   FROM (
   SELECT
           fact.project_id  project_id
   	 , fact.project_ORG_ID project_ORG_ID
   	 , fact.project_ORGANIZATION_ID project_ORGANIZATION_ID
      -- , fact.PARTITION_ID PARTITION_ID
   	 , fact.PROJECT_ELEMENT_ID PROJECT_ELEMENT_ID
   	 , calDet.sec_cal_period_id TIME_ID
   	 , fact.PERIOD_TYPE_ID PERIOD_TYPE_ID
   	 , DECODE(fact.CALENDAR_TYPE, 'P', 'G', 'G', 'P') CALENDAR_TYPE
         , fact.RBS_AGGR_LEVEL
         , fact.WBS_ROLLUP_FLAG
         , fact.PRG_ROLLUP_FLAG
   	 , fact.CURR_RECORD_TYPE_ID CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID PLAN_VERSION_ID
	 , fact.PLAN_TYPE_ID  PLAN_TYPE_ID
	 , ROUND (nvl(fact.raw_cost,0)*calDet.factor/cur.mau)*cur.mau raw_cost
	 , ROUND (nvl(fact.brdn_cost,0)*calDet.factor/cur.mau)*cur.mau brdn_cost
	 , ROUND (nvl(fact.revenue,0)*calDet.factor/cur.mau)*cur.mau revenue
	 , ROUND (nvl(fact.bill_raw_cost,0)*calDet.factor/cur.mau)*cur.mau bill_raw_cost
	 , ROUND (nvl(fact.bill_brdn_cost,0)*calDet.factor/cur.mau)*cur.mau bill_brdn_cost
	 , ROUND (nvl(fact.bill_labor_raw_cost,0)*calDet.factor/cur.mau)*cur.mau bill_labor_raw_cost
	 , ROUND (nvl(fact.bill_labor_brdn_cost,0)*calDet.factor/cur.mau)*cur.mau bill_labor_brdn_cost
	 , ROUND (nvl(fact.bill_labor_hrs,0)*calDet.factor/cur.mau)*cur.mau bill_labor_hrs
	 , ROUND (nvl(fact.equipment_raw_cost,0)*calDet.factor/cur.mau)*cur.mau equipment_raw_cost
	 , ROUND (nvl(fact.equipment_brdn_cost,0)*calDet.factor/cur.mau)*cur.mau equipment_brdn_cost
	 , ROUND (nvl(fact.capitalizable_raw_cost,0)*calDet.factor/cur.mau)*cur.mau capitalizable_raw_cost
	 , ROUND (nvl(fact.capitalizable_brdn_cost,0)*calDet.factor/cur.mau)*cur.mau capitalizable_brdn_cost
	 , ROUND (nvl(fact.labor_raw_cost,0)*calDet.factor/cur.mau)*cur.mau labor_raw_cost
	 , ROUND (nvl(fact.labor_brdn_cost,0)*calDet.factor/cur.mau)*cur.mau labor_brdn_cost
	 , ROUND (nvl(fact.labor_hrs,0)*calDet.factor/cur.mau)*cur.mau labor_hrs
	 , ROUND (nvl(fact.labor_revenue,0)*calDet.factor/cur.mau)*cur.mau labor_revenue
	 , ROUND (nvl(fact.equipment_hours,0)*calDet.factor/cur.mau)*cur.mau equipment_hours
	 , ROUND (nvl(fact.billable_equipment_hours,0)*calDet.factor/cur.mau)*cur.mau billable_equipment_hours
	 , ROUND (nvl(fact.sup_inv_committed_cost,0)*calDet.factor/cur.mau)*cur.mau sup_inv_committed_cost
	 , ROUND (nvl(fact.po_committed_cost,0)*calDet.factor/cur.mau)*cur.mau po_committed_cost
	 , ROUND (nvl(fact.pr_committed_cost,0)*calDet.factor/cur.mau)*cur.mau pr_committed_cost
	 , ROUND (nvl(fact.oth_committed_cost,0)*calDet.factor/cur.mau)*cur.mau oth_committed_cost
	 , ROUND (nvl(fact.ACT_LABOR_HRS,0)*calDet.factor/cur.mau)*cur.mau ACT_LABOR_HRS
	 , ROUND (nvl(fact.ACT_EQUIP_HRS,0)*calDet.factor/cur.mau)*cur.mau ACT_EQUIP_HRS
	 , ROUND (nvl(fact.ACT_LABOR_BRDN_COST,0)*calDet.factor/cur.mau)*cur.mau ACT_LABOR_BRDN_COST
	 , ROUND (nvl(fact.ACT_EQUIP_BRDN_COST,0)*calDet.factor/cur.mau)*cur.mau ACT_EQUIP_BRDN_COST
	 , ROUND (nvl(fact.ACT_BRDN_COST,0)*calDet.factor/cur.mau)*cur.mau ACT_BRDN_COST
	 , ROUND (nvl(fact.ACT_RAW_COST,0)*calDet.factor/cur.mau)*cur.mau ACT_RAW_COST
	 , ROUND (nvl(fact.ACT_REVENUE,0)*calDet.factor/cur.mau)*cur.mau ACT_REVENUE
	 , ROUND (nvl(fact.ACT_LABOR_RAW_COST,0)*calDet.factor/cur.mau)*cur.mau ACT_LABOR_RAW_COST
	 , ROUND (nvl(fact.ACT_EQUIP_RAW_COST,0)*calDet.factor/cur.mau)*cur.mau ACT_EQUIP_RAW_COST
	 , ROUND (nvl(fact.ETC_LABOR_HRS,0)*calDet.factor/cur.mau)*cur.mau ETC_LABOR_HRS
	 , ROUND (nvl(fact.ETC_EQUIP_HRS,0)*calDet.factor/cur.mau)*cur.mau ETC_EQUIP_HRS
	 , ROUND (nvl(fact.ETC_LABOR_BRDN_COST,0)*calDet.factor/cur.mau)*cur.mau ETC_LABOR_BRDN_COST
	 , ROUND (nvl(fact.ETC_EQUIP_BRDN_COST,0)*calDet.factor/cur.mau)*cur.mau ETC_EQUIP_BRDN_COST
	 , ROUND (nvl(fact.ETC_BRDN_COST,0)*calDet.factor/cur.mau)*cur.mau ETC_BRDN_COST
	 , ROUND (nvl(fact.ETC_RAW_COST,0)*calDet.factor/cur.mau)*cur.mau ETC_RAW_COST
	 , ROUND (nvl(fact.ETC_LABOR_RAW_COST,0)*calDet.factor/cur.mau)*cur.mau ETC_LABOR_RAW_COST
	 , ROUND (nvl(fact.ETC_EQUIP_RAW_COST,0)*calDet.factor/cur.mau)*cur.mau ETC_EQUIP_RAW_COST
	 , ROUND (nvl(fact.custom1,0)*calDet.factor/cur.mau)*cur.mau custom1
	 , ROUND (nvl(fact.custom2,0)*calDet.factor/cur.mau)*cur.mau custom2
	 , ROUND (nvl(fact.custom3,0)*calDet.factor/cur.mau)*cur.mau custom3
	 , ROUND (nvl(fact.custom4,0)*calDet.factor/cur.mau)*cur.mau custom4
	 , ROUND (nvl(fact.custom5,0)*calDet.factor/cur.mau)*cur.mau custom5
	 , ROUND (nvl(fact.custom6,0)*calDet.factor/cur.mau)*cur.mau custom6
	 , ROUND (nvl(fact.custom7,0)*calDet.factor/cur.mau)*cur.mau custom7
	 , ROUND (nvl(fact.custom8,0)*calDet.factor/cur.mau)*cur.mau custom8
	 , ROUND (nvl(fact.custom9,0)*calDet.factor/cur.mau)*cur.mau custom9
	 , ROUND (nvl(fact.custom10,0)*calDet.factor/cur.mau)*cur.mau custom10
	 , ROUND (nvl(fact.custom11,0)*calDet.factor/cur.mau)*cur.mau custom11
	 , ROUND (nvl(fact.custom12,0)*calDet.factor/cur.mau)*cur.mau custom12
	 , ROUND (nvl(fact.custom13,0)*calDet.factor/cur.mau)*cur.mau custom13
	 , ROUND (nvl(fact.custom14,0)*calDet.factor/cur.mau)*cur.mau custom14
	 , ROUND (nvl(fact.custom15,0)*calDet.factor/cur.mau)*cur.mau custom15
	 , fact.time_dangling_flag time_dangling_flag
	 , fact.rate_dangling_flag rate_dangling_flag
              , fact.plan_type_code  plan_type_code    /* 4471527 */
   FROM   pji_fp_aggr_pjp1_t fact,
         (SELECT /*+ NO_MERGE */ (LEAST(pri.end_date,sec.end_date) - Greatest(pri.start_date,sec.start_date)+1)
	                      / (pri.end_date - pri.start_date+1) factor,
	         ppa.project_id,
	         ver.rbs_struct_Version_id rbs_struct_version_id,
		 ver.plan_version_id plan_Version_id,
                           ver.plan_type_code   plan_type_code,   /* 4471527 */
		 pri.cal_period_id pri_cal_period_id,
		 sec.cal_period_id sec_cal_period_id,
		 orginfo.org_id
	    FROM
                 pji_time_cal_period_v  pri
               , pji_org_extr_info  orginfo
               , pji_time_cal_period_v  sec
               , pji_fm_extr_plnver3_t  ver
	       , pa_projects_all ppa
           WHERE  1=1
             AND ppa.org_id=orginfo.org_id
             AND pri.calendar_id in (orginfo.gl_calendar_id,orginfo.pa_calendar_id)
             AND sec.calendar_id in (orginfo.gl_calendar_id,orginfo.pa_calendar_id)
             AND ppa.project_id=ver.project_id
             AND decode(ver.time_phased_type_code,
                       'P',orginfo.pa_calendar_id,'G',orginfo.gl_calendar_id)=pri.calendar_id
             AND decode(ver.time_phased_type_code,
                       'G',orginfo.pa_calendar_id,'P',orginfo.gl_calendar_id)=sec.calendar_id
             AND ver.wp_flag = 'N'
             AND ( sec.start_date <= pri.end_date AND sec.end_date >= pri.start_date )
             AND ver.baselined_flag = 'Y') calDet,
	   (SELECT currency_code,
	           decode(nvl(MINIMUM_ACCOUNTABLE_UNIT, power(10, (-1 * PRECISION))),
		      null, 0.01,
		         0, 1,
			 nvl(MINIMUM_ACCOUNTABLE_UNIT, power(10, (-1 * PRECISION)))) mau
	      FROM FND_CURRENCIES) cur
    WHERE 1=1
      AND calDet.factor > 0
      -- AND (calDet.rbs_struct_version_id = fact.rbs_version_id  OR fact.rbs_version_id = -1)
      AND NVL(calDet.rbs_struct_version_id, -1) = fact.rbs_version_id
      AND fact.CALENDAR_TYPE <> p_calendar_type
      AND fact.worker_id = g_worker_id
      AND fact.CALENDAR_TYPE IN ('P', 'G')
      AND CalDet.pri_cal_period_id = fact.time_id
      AND calDet.org_id = fact.PROJECT_ORG_ID
      AND fact.time_dangling_flag IS NULL
      AND fact.rate_dangling_flag IS NULL
      AND fact.period_type_id = 32
      AND fact.line_type like 'OF%' -- 4518721
      AND fact.plan_version_id = calDet.plan_version_id
      AND fact.plan_type_code = calDet.plan_type_code    /* 4471527 */
      AND cur.currency_code = fact.currency_code
	  ) a
	  GROUP BY
	   a.PROJECT_ID
     , a.PROJECT_ORG_ID
     , a.PROJECT_ORGANIZATION_ID
     , a.PROJECT_ELEMENT_ID
     , a.TIME_ID
     , a.PERIOD_TYPE_ID
     , a.CALENDAR_TYPE
     , a.RBS_AGGR_LEVEL
     , a.WBS_ROLLUP_FLAG
     , a.PRG_ROLLUP_FLAG
     , a.CURR_RECORD_TYPE_ID
     , a.CURRENCY_CODE
     , a.RBS_ELEMENT_ID
     , a.RBS_VERSION_ID
     , a.PLAN_VERSION_ID
     , a.PLAN_TYPE_ID
     , a.PLAN_TYPE_CODE    /* 4471527 */
     , a.TIME_DANGLING_FLAG
     , a.RATE_DANGLING_FLAG;




EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => ' PRORATE_TO_PAGL_PGE_PJP1_D ');
    RAISE;
END;


PROCEDURE PRORATE_TO_PAGL_PGE_FPRL_D (p_calendar_type   IN   VARCHAR2 := NULL) IS
BEGIN

    -- g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;

    INSERT INTO pji_fp_aggr_pjp1_t
    (
       worker_id
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , LINE_TYPE
     , TIME_DANGLING_FLAG
     , RATE_DANGLING_FLAG
     , PRG_LEVEL
     , PLAN_TYPE_CODE   /* 4471527 */
   )
   SELECT
       g_worker_id worker_id
     , a.PROJECT_ID
     , a.PROJECT_ORG_ID
     , a.PROJECT_ORGANIZATION_ID
     , a.PROJECT_ELEMENT_ID
     , a.TIME_ID
     , a.PERIOD_TYPE_ID
     , a.CALENDAR_TYPE
     , a.RBS_AGGR_LEVEL
     , a.WBS_ROLLUP_FLAG
     , a.PRG_ROLLUP_FLAG
     , a.CURR_RECORD_TYPE_ID
     , a.CURRENCY_CODE
     , a.RBS_ELEMENT_ID
     , a.RBS_VERSION_ID
     , a.PLAN_VERSION_ID
     , a.PLAN_TYPE_ID
     , SUM(a.RAW_COST       )
     , SUM(a.BRDN_COST 	)
     , SUM(a.REVENUE	)
     , SUM(a.BILL_RAW_COST )
     , SUM(a.BILL_BRDN_COST )
     , SUM(a.BILL_LABOR_RAW_COST )
     , SUM(a.BILL_LABOR_BRDN_COST )
     , SUM(a.BILL_LABOR_HRS )
     , SUM(a.EQUIPMENT_RAW_COST )
     , SUM(a.EQUIPMENT_BRDN_COST )
     , SUM(a.CAPITALIZABLE_RAW_COST )
     , SUM(a.CAPITALIZABLE_BRDN_COST )
     , SUM(a.LABOR_RAW_COST )
     , SUM(a.LABOR_BRDN_COST)
     , SUM(a.LABOR_HRS )
     , SUM(a.LABOR_REVENUE )
     , SUM(a.EQUIPMENT_HOURS )
     , SUM(a.BILLABLE_EQUIPMENT_HOURS)
     , SUM(a.SUP_INV_COMMITTED_COST)
     , SUM(a.PO_COMMITTED_COST )
     , SUM(a.PR_COMMITTED_COST )
     , SUM(a.OTH_COMMITTED_COST)
       , SUM(a.ACT_LABOR_HRS)
	   , SUM(a.ACT_EQUIP_HRS)
	   , SUM(a.ACT_LABOR_BRDN_COST)
	   , SUM(a.ACT_EQUIP_BRDN_COST)
	   , SUM(a.ACT_BRDN_COST    )
	   , SUM(a.ACT_RAW_COST    )
	   , SUM(a.ACT_REVENUE    )
         , SUM(a.ACT_LABOR_RAW_COST)
         , SUM(a.ACT_EQUIP_RAW_COST)
	   , SUM(a.ETC_LABOR_HRS         )
	   , SUM(a.ETC_EQUIP_HRS        )
	   , SUM(a.ETC_LABOR_BRDN_COST )
	   , SUM(a.ETC_EQUIP_BRDN_COST)
	   , SUM(a.ETC_BRDN_COST )
         , SUM(a.ETC_RAW_COST)
         , SUM(a.ETC_LABOR_RAW_COST)
         , SUM(a.ETC_EQUIP_RAW_COST)
     , SUM(a.CUSTOM1	)
     , SUM(a.CUSTOM2	)
     , SUM(a.CUSTOM3	)
     , SUM(a.CUSTOM4	)
     , SUM(a.CUSTOM5	)
     , SUM(a.CUSTOM6	)
     , SUM(a.CUSTOM7	)
     , SUM(a.CUSTOM8	)
     , SUM(a.CUSTOM9	)
     , SUM(a.CUSTOM10	)
     , SUM(a.CUSTOM11	)
     , SUM(a.CUSTOM12	)
     , SUM(a.CUSTOM13	)
     , SUM(a.CUSTOM14	)
     , SUM(a.CUSTOM15	)
	 , a.LINE_TYPE
	 , a.TIME_DANGLING_FLAG
	 , a.RATE_DANGLING_FLAG
       , g_default_prg_level prg_level
       , a.plan_type_code plan_type_code    /* 4471527 */
   FROM (
   SELECT
         fact.project_id  project_id
   	 , fact.project_ORG_ID project_ORG_ID
   	 , fact.project_ORGANIZATION_ID project_ORGANIZATION_ID
     -- , fact.PARTITION_ID PARTITION_ID
   	 , fact.PROJECT_ELEMENT_ID PROJECT_ELEMENT_ID
   	 , pa_cal.cal_period_id TIME_ID
   	 , fact.PERIOD_TYPE_ID PERIOD_TYPE_ID
   	 , DECODE(fact.CALENDAR_TYPE, 'P', 'G', 'G', 'P') CALENDAR_TYPE
     , fact.RBS_AGGR_LEVEL
     , fact.WBS_ROLLUP_FLAG
     , fact.PRG_ROLLUP_FLAG
   	 , fact.CURR_RECORD_TYPE_ID CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID PLAN_VERSION_ID
	 , fact.PLAN_TYPE_ID  PLAN_TYPE_ID
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.raw_cost
			  , '1-1'  , fact.raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			 , '00'   , fact.brdn_cost
			 , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '0-1'  , fact.brdn_cost
			 , '1-1'  , fact.brdn_cost
			 , 0  ) -- end decode
			  , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			 , '00'   , fact.revenue
			 , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			 , '0-1'  , fact.revenue
			 , '1-1'  , fact.revenue
			 , 0  ) -- end decode
			  , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	revenue
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.bill_raw_cost
			  , '1-1'  , fact.bill_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.bill_brdn_cost
			  , '1-1'  , fact.bill_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_labor_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.bill_labor_raw_cost
			  , '1-1'  , fact.bill_labor_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_labor_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_labor_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.bill_labor_brdn_cost
			  , '1-1'  , fact.bill_labor_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_labor_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_labor_hrs
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.bill_labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.bill_labor_hrs
			  , '1-1'  , fact.bill_labor_hrs
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_labor_hrs
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.equipment_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.equipment_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.equipment_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.equipment_raw_cost
			  , '1-1'  , fact.equipment_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	equipment_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.equipment_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.equipment_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.equipment_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.equipment_brdn_cost
			  , '1-1'  , fact.equipment_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	equipment_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.capitalizable_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.capitalizable_raw_cost
			  , '1-1'  , fact.capitalizable_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	capitalizable_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.capitalizable_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.capitalizable_brdn_cost
			  , '1-1'  , fact.capitalizable_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	capitalizable_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.labor_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_raw_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.labor_raw_cost
			  , '1-1'  , fact.labor_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	labor_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.labor_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_brdn_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.labor_brdn_cost
			  , '1-1'  , fact.labor_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	labor_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.labor_hrs
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_hrs / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.labor_hrs
			  , '1-1'  , fact.labor_hrs
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	labor_hrs
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.labor_revenue
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.labor_revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_revenue / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.labor_revenue
			  , '1-1'  , fact.labor_revenue
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	labor_revenue
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.equipment_hours
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.equipment_hours
			  , '1-1'  , fact.equipment_hours
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	equipment_hours
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.billable_equipment_hours
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.billable_equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.billable_equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.billable_equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.billable_equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.billable_equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.billable_equipment_hours / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.billable_equipment_hours
			  , '1-1'  , fact.billable_equipment_hours
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	billable_equipment_hours
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.sup_inv_committed_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.sup_inv_committed_cost
			  , '1-1'  , fact.sup_inv_committed_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	sup_inv_committed_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.po_committed_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.po_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.po_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.po_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.po_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.po_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.po_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.po_committed_cost
			  , '1-1'  , fact.po_committed_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	po_committed_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.pr_committed_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.pr_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.pr_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.pr_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.pr_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.pr_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.pr_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.pr_committed_cost
			  , '1-1'  , fact.pr_committed_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	pr_committed_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.oth_committed_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.oth_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.oth_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.oth_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.oth_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.oth_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.oth_committed_cost / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.oth_committed_cost
			  , '1-1'  , fact.oth_committed_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	oth_committed_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_LABOR_HRS
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_LABOR_HRS
			  , '1-1'  , fact.ACT_LABOR_HRS
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_LABOR_HRS
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_EQUIP_HRS
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_EQUIP_HRS
			  , '1-1'  , fact.ACT_EQUIP_HRS
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_EQUIP_HRS
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_LABOR_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_LABOR_BRDN_COST
			  , '1-1'  , fact.ACT_LABOR_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_LABOR_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_EQUIP_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_EQUIP_BRDN_COST
			  , '1-1'  , fact.ACT_EQUIP_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_EQUIP_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_BRDN_COST
			  , '1-1'  , fact.ACT_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_RAW_COST
			  , '1-1'  , fact.ACT_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_REVENUE
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_REVENUE / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_REVENUE / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_REVENUE / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_REVENUE / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_REVENUE / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_REVENUE / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_REVENUE
			  , '1-1'  , fact.ACT_REVENUE
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_REVENUE
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_LABOR_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_LABOR_RAW_COST
			  , '1-1'  , fact.ACT_LABOR_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_LABOR_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_EQUIP_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ACT_EQUIP_RAW_COST
			  , '1-1'  , fact.ACT_EQUIP_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_EQUIP_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_LABOR_HRS
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_LABOR_HRS
			  , '1-1'  , fact.ETC_LABOR_HRS
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_LABOR_HRS
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_EQUIP_HRS
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_EQUIP_HRS
			  , '1-1'  , fact.ETC_EQUIP_HRS
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_EQUIP_HRS
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_LABOR_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_LABOR_BRDN_COST
			  , '1-1'  , fact.ETC_LABOR_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_LABOR_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_EQUIP_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_EQUIP_BRDN_COST
			  , '1-1'  , fact.ETC_EQUIP_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_EQUIP_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_BRDN_COST
			  , '1-1'  , fact.ETC_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_RAW_COST
			  , '1-1'  , fact.ETC_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_LABOR_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_LABOR_RAW_COST
			  , '1-1'  , fact.ETC_LABOR_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_LABOR_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_EQUIP_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.ETC_EQUIP_RAW_COST
			  , '1-1'  , fact.ETC_EQUIP_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_EQUIP_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom1
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom1 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom1 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom1 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom1 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom1 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom1 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom1
			  , '1-1'  , fact.custom1
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom1
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom2
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom2 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom2 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom2 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom2 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom2 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom2 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom2
			  , '1-1'  , fact.custom2
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom2
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom3
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom3 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom3 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom3 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom3 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom3 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom3 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom3
			  , '1-1'  , fact.custom3
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom3
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom4
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom4 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom4 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom4 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom4 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom4 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom4 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom4
			  , '1-1'  , fact.custom4
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom4
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom5
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom5 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom5 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom5 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom5 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom5 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom5 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom5
			  , '1-1'  , fact.custom5
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom5
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom6
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom6 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom6 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom6 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom6 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom6 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom6 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom6
			  , '1-1'  , fact.custom6
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom6
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom7
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom7 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom7 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom7 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom7 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom7 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom7 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom7
			  , '1-1'  , fact.custom7
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom7
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom8
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom8 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom8 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom8 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom8 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom8 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom8 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom8
			  , '1-1'  , fact.custom8
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom8
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom9
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom9 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom9 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom9 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom9 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom9 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom9 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom9
			  , '1-1'  , fact.custom9
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom9
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom10
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom10 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom10 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom10 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom10 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom10 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom10 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom10
			  , '1-1'  , fact.custom10
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom10
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom11
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom11 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom11 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom11 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom11 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom11 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom11 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom11
			  , '1-1'  , fact.custom11
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom11
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom12
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom12 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom12 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom12 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom12 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom12 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom12 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom12
			  , '1-1'  , fact.custom12
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom12
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom13
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom13 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom13 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom13 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom13 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom13 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom13 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom13
			  , '1-1'  , fact.custom13
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom13
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom14
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom14 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom14 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom14 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom14 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom14 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom14 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom14
			  , '1-1'  , fact.custom14
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom14
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (non_pa_cal.start_date - pa_cal.start_date) || sign (non_pa_cal.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom15
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom15 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom15 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '10'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom15 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '11'   , (pa_cal.end_date - non_pa_cal.start_date + 1) * fact.custom15 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-10'  , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom15 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '-1-1' , (non_pa_cal.end_date - pa_cal.start_date + 1) * fact.custom15 / (non_pa_cal.end_date - non_pa_cal.start_date + 1)
			  , '0-1'  , fact.custom15
			  , '1-1'  , fact.custom15
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom15
     , 'CF'   line_type
	 , NULL time_dangling_flag
	 , NULL rate_dangling_flag
              ,fact.plan_type_code plan_type_code     /*4471527 */
   FROM   pji_fp_xbs_accum_f  fact
       , PJI_FM_EXTR_PLNVER3_T ver
        , pji_time_cal_period  non_pa_cal
   	 , pji_org_extr_info  orginfo
   	 , pji_time_cal_period  pa_cal
   WHERE  1=1
      AND fact.CALENDAR_TYPE <> p_calendar_type
      AND fact.CALENDAR_TYPE IN ('P', 'G')
      AND non_pa_cal.cal_period_id = fact.time_id
      AND ver.project_id = fact.project_id
      AND ver.plan_version_id = fact.plan_version_id
      AND orginfo.org_id = fact.PROJECT_ORG_ID
      AND DECODE(fact.calendar_type, 'P', orginfo.gl_calendar_id, 'G', orginfo.pa_calendar_id) = pa_cal.calendar_id
      AND (
	       ( pa_cal.start_date >= non_pa_cal.start_date  AND pa_cal.end_date <= non_pa_cal.end_date )
	    OR ( pa_cal.start_date <= non_pa_cal.start_date  AND pa_cal.end_date >= non_pa_cal.end_date )
	    OR ( pa_cal.start_date <= non_pa_cal.start_date  AND pa_cal.end_date <= non_pa_cal.end_date AND pa_cal.end_date >= non_pa_cal.start_date )
	    OR ( pa_cal.start_date >= non_pa_cal.start_date  AND pa_cal.end_date >= non_pa_cal.end_date AND pa_cal.start_date <= non_pa_cal.end_date )
          )
      AND fact.period_type_id = 32
      AND ver.wp_flag = 'N'
      AND ver.baselined_flag = 'Y'
	  ) a
	  GROUP BY
	   a.PROJECT_ID
     , a.PROJECT_ORG_ID
     , a.PROJECT_ORGANIZATION_ID
     , a.PROJECT_ELEMENT_ID
     , a.TIME_ID
     , a.PERIOD_TYPE_ID
     , a.CALENDAR_TYPE
     , a.RBS_AGGR_LEVEL
     , a.WBS_ROLLUP_FLAG
     , a.PRG_ROLLUP_FLAG
     , a.CURR_RECORD_TYPE_ID
     , a.CURRENCY_CODE
     , a.RBS_ELEMENT_ID
     , a.RBS_VERSION_ID
     , a.PLAN_VERSION_ID
     , a.PLAN_TYPE_ID
	 , a.LINE_TYPE
	 , a.TIME_DANGLING_FLAG
	 , a.RATE_DANGLING_FLAG;


EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRORATE_TO_PAGL_PGE_FPRL_D ');
    RAISE;
END;


PROCEDURE PRORATE_TO_PAGL_N_PJP1_D (p_calendar_type   IN   VARCHAR2 := NULL) IS
BEGIN

    IF (p_calendar_type NOT IN ('P', 'G')) THEN
      RETURN;
    END IF;

    -- g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;

/* Commented for bug 4005006
    INSERT INTO pji_fp_aggr_pjp1_t  -- Non time phased entries..
    (
       worker_id
      , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , LINE_TYPE
     , TIME_DANGLING_FLAG
     , RATE_DANGLING_FLAG
     , PRG_LEVEL
	)
   SELECT
         g_worker_id  worker_id
     , a.PROJECT_ID
     , a.PROJECT_ORG_ID
     , a.PROJECT_ORGANIZATION_ID
     , a.PROJECT_ELEMENT_ID
     , a.TIME_ID
     , 32 -- a.PERIOD_TYPE_ID
     , a.CALENDAR_TYPE
     , a.RBS_AGGR_LEVEL
     , a.WBS_ROLLUP_FLAG
     , a.PRG_ROLLUP_FLAG
     , a.CURR_RECORD_TYPE_ID
     , a.CURRENCY_CODE
     , a.RBS_ELEMENT_ID
     , a.RBS_VERSION_ID
     , a.PLAN_VERSION_ID
     , a.PLAN_TYPE_ID
     , SUM(a.RAW_COST       )
     , SUM(a.BRDN_COST 	)
     , SUM(a.REVENUE	)
     , SUM(a.BILL_RAW_COST )
     , SUM(a.BILL_BRDN_COST )
     , SUM(a.BILL_LABOR_RAW_COST )
     , SUM(a.BILL_LABOR_BRDN_COST )
     , SUM(a.BILL_LABOR_HRS )
     , SUM(a.EQUIPMENT_RAW_COST )
     , SUM(a.EQUIPMENT_BRDN_COST )
     , SUM(a.CAPITALIZABLE_RAW_COST )
     , SUM(a.CAPITALIZABLE_BRDN_COST )
     , SUM(a.LABOR_RAW_COST )
     , SUM(a.LABOR_BRDN_COST)
     , SUM(a.LABOR_HRS )
     , SUM(a.LABOR_REVENUE )
     , SUM(a.EQUIPMENT_HOURS )
     , SUM(a.BILLABLE_EQUIPMENT_HOURS)
     , SUM(a.SUP_INV_COMMITTED_COST)
     , SUM(a.PO_COMMITTED_COST )
     , SUM(a.PR_COMMITTED_COST )
     , SUM(a.OTH_COMMITTED_COST)
       , SUM(a.ACT_LABOR_HRS)
	   , SUM(a.ACT_EQUIP_HRS)
	   , SUM(a.ACT_LABOR_BRDN_COST)
	   , SUM(a.ACT_EQUIP_BRDN_COST)
	   , SUM(a.ACT_BRDN_COST    )
	   , SUM(a.ACT_RAW_COST    )
	   , SUM(a.ACT_REVENUE    )
         , SUM(a.ACT_LABOR_RAW_COST)
         , SUM(a.ACT_EQUIP_RAW_COST)
	   , SUM(a.ETC_LABOR_HRS         )
	   , SUM(a.ETC_EQUIP_HRS        )
	   , SUM(a.ETC_LABOR_BRDN_COST )
	   , SUM(a.ETC_EQUIP_BRDN_COST)
	   , SUM(a.ETC_BRDN_COST )
         , SUM(a.ETC_RAW_COST)
         , SUM(a.ETC_LABOR_RAW_COST)
         , SUM(a.ETC_EQUIP_RAW_COST)
     , SUM(a.CUSTOM1	)
     , SUM(a.CUSTOM2	)
     , SUM(a.CUSTOM3	)
     , SUM(a.CUSTOM4	)
     , SUM(a.CUSTOM5	)
     , SUM(a.CUSTOM6	)
     , SUM(a.CUSTOM7	)
     , SUM(a.CUSTOM8	)
     , SUM(a.CUSTOM9	)
     , SUM(a.CUSTOM10	)
     , SUM(a.CUSTOM11	)
     , SUM(a.CUSTOM12	)
     , SUM(a.CUSTOM13	)
     , SUM(a.CUSTOM14	)
     , SUM(a.CUSTOM15	)
	 , a.LINE_TYPE
	 , a.TIME_DANGLING_FLAG
	 , a.RATE_DANGLING_FLAG
       , g_default_prg_level prg_level
  FROM (
   SELECT
         fact.project_id  project_id
   	 , fact.project_ORG_ID project_ORG_ID
   	 , fact.project_ORGANIZATION_ID project_ORGANIZATION_ID
   	 , fact.PROJECT_ELEMENT_ID PROJECT_ELEMENT_ID
   	 , pa_cal.cal_period_id TIME_ID
   	 , fact.PERIOD_TYPE_ID PERIOD_TYPE_ID
       , p_calendar_type  CALENDAR_TYPE
       , fact.RBS_AGGR_LEVEL
       , fact.WBS_ROLLUP_FLAG
       , fact.PRG_ROLLUP_FLAG
   	 , fact.CURR_RECORD_TYPE_ID CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID PLAN_VERSION_ID
	 , fact.PLAN_TYPE_ID  PLAN_TYPE_ID
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.raw_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.raw_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.raw_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.raw_cost
			  , '1-1'  , fact.raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			 , '00'   , fact.brdn_cost
			 , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.brdn_cost / (fact.end_date - fact.start_date + 1)
			 , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.brdn_cost / (fact.end_date - fact.start_date + 1)
			 , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.brdn_cost / (fact.end_date - fact.start_date + 1)
			 , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.brdn_cost / (fact.end_date - fact.start_date + 1)
			 , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.brdn_cost / (fact.end_date - fact.start_date + 1)
			 , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.brdn_cost / (fact.end_date - fact.start_date + 1)
			 , '0-1'  , fact.brdn_cost
			 , '1-1'  , fact.brdn_cost
			 , 0  ) -- end decode
			  , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			 , '00'   , fact.revenue
			 , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.revenue / (fact.end_date - fact.start_date + 1)
			 , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.revenue / (fact.end_date - fact.start_date + 1)
			 , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.revenue / (fact.end_date - fact.start_date + 1)
			 , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.revenue / (fact.end_date - fact.start_date + 1)
			 , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.revenue / (fact.end_date - fact.start_date + 1)
			 , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.revenue / (fact.end_date - fact.start_date + 1)
			 , '0-1'  , fact.revenue
			 , '1-1'  , fact.revenue
			 , 0  ) -- end decode
			  , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	revenue
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.bill_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.bill_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.bill_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.bill_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.bill_raw_cost
			  , '1-1'  , fact.bill_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.bill_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.bill_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.bill_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.bill_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.bill_brdn_cost
			  , '1-1'  , fact.bill_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_labor_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.bill_labor_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.bill_labor_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.bill_labor_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.bill_labor_raw_cost
			  , '1-1'  , fact.bill_labor_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_labor_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_labor_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.bill_labor_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.bill_labor_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.bill_labor_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.bill_labor_brdn_cost
			  , '1-1'  , fact.bill_labor_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_labor_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.bill_labor_hrs
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_hrs / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.bill_labor_hrs / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.bill_labor_hrs / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.bill_labor_hrs / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.bill_labor_hrs / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.bill_labor_hrs / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.bill_labor_hrs
			  , '1-1'  , fact.bill_labor_hrs
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	bill_labor_hrs
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.equipment_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.equipment_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.equipment_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.equipment_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.equipment_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.equipment_raw_cost
			  , '1-1'  , fact.equipment_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	equipment_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.equipment_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.equipment_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.equipment_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.equipment_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.equipment_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.equipment_brdn_cost
			  , '1-1'  , fact.equipment_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	equipment_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.capitalizable_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.capitalizable_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.capitalizable_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.capitalizable_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.capitalizable_raw_cost
			  , '1-1'  , fact.capitalizable_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	capitalizable_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.capitalizable_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.capitalizable_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.capitalizable_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.capitalizable_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.capitalizable_brdn_cost
			  , '1-1'  , fact.capitalizable_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	capitalizable_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.labor_raw_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.labor_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.labor_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.labor_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.labor_raw_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.labor_raw_cost
			  , '1-1'  , fact.labor_raw_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	labor_raw_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.labor_brdn_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.labor_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.labor_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.labor_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.labor_brdn_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.labor_brdn_cost
			  , '1-1'  , fact.labor_brdn_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	labor_brdn_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.labor_hrs
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_hrs / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_hrs / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.labor_hrs / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.labor_hrs / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.labor_hrs / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.labor_hrs / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.labor_hrs
			  , '1-1'  , fact.labor_hrs
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	labor_hrs
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.labor_revenue
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_revenue / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.labor_revenue / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.labor_revenue / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.labor_revenue / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.labor_revenue / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.labor_revenue / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.labor_revenue
			  , '1-1'  , fact.labor_revenue
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	labor_revenue
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.equipment_hours
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_hours / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.equipment_hours / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.equipment_hours / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.equipment_hours / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.equipment_hours / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.equipment_hours / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.equipment_hours
			  , '1-1'  , fact.equipment_hours
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	equipment_hours
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.billable_equipment_hours
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.billable_equipment_hours / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.billable_equipment_hours / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.billable_equipment_hours / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.billable_equipment_hours / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.billable_equipment_hours / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.billable_equipment_hours / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.billable_equipment_hours
			  , '1-1'  , fact.billable_equipment_hours
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	billable_equipment_hours
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.sup_inv_committed_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.sup_inv_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.sup_inv_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.sup_inv_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.sup_inv_committed_cost
			  , '1-1'  , fact.sup_inv_committed_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	sup_inv_committed_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.po_committed_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.po_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.po_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.po_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.po_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.po_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.po_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.po_committed_cost
			  , '1-1'  , fact.po_committed_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	po_committed_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.pr_committed_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.pr_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.pr_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.pr_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.pr_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.pr_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.pr_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.pr_committed_cost
			  , '1-1'  , fact.pr_committed_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	pr_committed_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.oth_committed_cost
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.oth_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.oth_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.oth_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.oth_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.oth_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.oth_committed_cost / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.oth_committed_cost
			  , '1-1'  , fact.oth_committed_cost
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	oth_committed_cost
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_LABOR_HRS
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_LABOR_HRS / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_LABOR_HRS / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_HRS / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ACT_LABOR_HRS
			  , '1-1'  , fact.ACT_LABOR_HRS
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_LABOR_HRS
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_EQUIP_HRS
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_EQUIP_HRS / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_EQUIP_HRS / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_HRS / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ACT_EQUIP_HRS
			  , '1-1'  , fact.ACT_EQUIP_HRS
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_EQUIP_HRS
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_LABOR_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ACT_LABOR_BRDN_COST
			  , '1-1'  , fact.ACT_LABOR_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_LABOR_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_EQUIP_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ACT_EQUIP_BRDN_COST
			  , '1-1'  , fact.ACT_EQUIP_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_EQUIP_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ACT_BRDN_COST
			  , '1-1'  , fact.ACT_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ACT_RAW_COST
			  , '1-1'  , fact.ACT_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_REVENUE
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_REVENUE / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_REVENUE / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_REVENUE / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_REVENUE / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_REVENUE / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_REVENUE / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ACT_REVENUE
			  , '1-1'  , fact.ACT_REVENUE
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_REVENUE
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_LABOR_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_LABOR_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_LABOR_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_LABOR_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ACT_LABOR_RAW_COST
			  , '1-1'  , fact.ACT_LABOR_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_LABOR_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ACT_EQUIP_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ACT_EQUIP_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ACT_EQUIP_RAW_COST
			  , '1-1'  , fact.ACT_EQUIP_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ACT_EQUIP_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_LABOR_HRS
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_LABOR_HRS / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_LABOR_HRS / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_HRS / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ETC_LABOR_HRS
			  , '1-1'  , fact.ETC_LABOR_HRS
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_LABOR_HRS
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_EQUIP_HRS
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_EQUIP_HRS / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_EQUIP_HRS / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_HRS / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ETC_EQUIP_HRS
			  , '1-1'  , fact.ETC_EQUIP_HRS
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_EQUIP_HRS
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_LABOR_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ETC_LABOR_BRDN_COST
			  , '1-1'  , fact.ETC_LABOR_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_LABOR_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_EQUIP_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ETC_EQUIP_BRDN_COST
			  , '1-1'  , fact.ETC_EQUIP_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_EQUIP_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_BRDN_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_BRDN_COST / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ETC_BRDN_COST
			  , '1-1'  , fact.ETC_BRDN_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_BRDN_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ETC_RAW_COST
			  , '1-1'  , fact.ETC_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_LABOR_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_LABOR_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_LABOR_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_LABOR_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ETC_LABOR_RAW_COST
			  , '1-1'  , fact.ETC_LABOR_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_LABOR_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.ETC_EQUIP_RAW_COST
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.ETC_EQUIP_RAW_COST / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.ETC_EQUIP_RAW_COST
			  , '1-1'  , fact.ETC_EQUIP_RAW_COST
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	ETC_EQUIP_RAW_COST
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom1
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom1 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom1 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom1 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom1 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom1 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom1 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom1
			  , '1-1'  , fact.custom1
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom1
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom2
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom2 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom2 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom2 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom2 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom2 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom2 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom2
			  , '1-1'  , fact.custom2
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom2
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom3
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom3 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom3 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom3 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom3 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom3 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom3 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom3
			  , '1-1'  , fact.custom3
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom3
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom4
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom4 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom4 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom4 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom4 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom4 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom4 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom4
			  , '1-1'  , fact.custom4
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom4
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom5
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom5 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom5 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom5 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom5 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom5 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom5 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom5
			  , '1-1'  , fact.custom5
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom5
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom6
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom6 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom6 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom6 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom6 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom6 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom6 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom6
			  , '1-1'  , fact.custom6
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom6
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom7
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom7 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom7 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom7 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom7 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom7 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom7 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom7
			  , '1-1'  , fact.custom7
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom7
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom8
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom8 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom8 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom8 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom8 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom8 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom8 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom8
			  , '1-1'  , fact.custom8
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom8
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom9
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom9 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom9 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom9 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom9 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom9 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom9 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom9
			  , '1-1'  , fact.custom9
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom9
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom10
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom10 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom10 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom10 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom10 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom10 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom10 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom10
			  , '1-1'  , fact.custom10
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom10
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom11
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom11 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom11 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom11 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom11 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom11 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom11 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom11
			  , '1-1'  , fact.custom11
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom11
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom12
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom12 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom12 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom12 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom12 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom12 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom12 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom12
			  , '1-1'  , fact.custom12
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom12
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom13
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom13 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom13 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom13 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom13 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom13 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom13 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom13
			  , '1-1'  , fact.custom13
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom13
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom14
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom14 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom14 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom14 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom14 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom14 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom14 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom14
			  , '1-1'  , fact.custom14
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom14
	 , ROUND (
             NVL (
            DECODE (
                     ( sign (fact.start_date - pa_cal.start_date) || sign (fact.end_date - pa_cal.end_date) )
			  , '00'   , fact.custom15
			  , '01'   , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom15 / (fact.end_date - fact.start_date + 1)
			  , '-11'  , (pa_cal.end_date - pa_cal.start_date + 1) * fact.custom15 / (fact.end_date - fact.start_date + 1)
			  , '10'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom15 / (fact.end_date - fact.start_date + 1)
			  , '11'   , (pa_cal.end_date - fact.start_date + 1) * fact.custom15 / (fact.end_date - fact.start_date + 1)
			  , '-10'  , (fact.end_date - pa_cal.start_date + 1) * fact.custom15 / (fact.end_date - fact.start_date + 1)
			  , '-1-1' , (fact.end_date - pa_cal.start_date + 1) * fact.custom15 / (fact.end_date - fact.start_date + 1)
			  , '0-1'  , fact.custom15
			  , '1-1'  , fact.custom15
			  , 0  ) -- end decode
			    , 0  ) -- end nvl
			/ PJI_UTILS.GET_MAU (fact.currency_code) )  -- end round
						* PJI_UTILS.GET_MAU (fact.currency_code)	custom15
     , 'CF'   line_type
	 , NULL time_dangling_flag
	 , NULL rate_dangling_flag
   FROM   pji_fp_aggr_pjp1_t fact
   	 , pji_org_extr_info  orginfo
   	 , pji_time_cal_period  pa_cal
       , pji_fm_extr_plnver3_t  ver
   WHERE  1=1
      AND fact.CALENDAR_TYPE = 'A'
      AND fact.worker_id = g_worker_id
      AND fact.start_date IS NOT NULL
      AND fact.end_date IS NOT NULL
	AND fact.time_dangling_flag IS NULL
	AND fact.rate_dangling_flag IS NULL
      AND orginfo.org_id = fact.PROJECT_ORG_ID
      AND DECODE(p_calendar_type
               , 'P', orginfo.pa_calendar_id
               , 'G', orginfo.gl_calendar_id) = pa_cal.calendar_id
      AND (
	       (     pa_cal.start_date >= fact.start_date
               AND pa_cal.end_date <= fact.end_date ) -- fsps,pefe
	    OR (     pa_cal.start_date <= fact.start_date
               AND pa_cal.end_date >= fact.end_date ) -- psfs,fepe
	    OR (     pa_cal.start_date <= fact.start_date
               AND pa_cal.end_date <= fact.end_date
               AND pa_cal.end_date >= fact.start_date ) -- psfspefe
	    OR (     pa_cal.start_date >= fact.start_date
               AND pa_cal.end_date >= fact.end_date
               AND pa_cal.start_date <= fact.end_date )  -- fspsfepe
          )
      AND fact.line_type = 'NTP'
      AND fact.period_type_id = 2048
      AND fact.plan_version_id = ver.plan_version_id
      AND ver.wp_flag = 'N'
      AND ver.baselined_flag = 'Y'
      AND ver.time_phased_type_code = 'N'
      -- AND (ver.rbs_struct_version_id = fact.rbs_version_id  OR fact.rbs_version_id = -1)
      AND NVL(ver.rbs_struct_version_id, -1) = fact.rbs_version_id
	  ) a
	  GROUP BY
	   a.PROJECT_ID
     , a.PROJECT_ORG_ID
     , a.PROJECT_ORGANIZATION_ID
     , a.PROJECT_ELEMENT_ID
     , a.TIME_ID
     , a.PERIOD_TYPE_ID
     , a.CALENDAR_TYPE
     , a.RBS_AGGR_LEVEL
     , a.WBS_ROLLUP_FLAG
     , a.PRG_ROLLUP_FLAG
     , a.CURR_RECORD_TYPE_ID
     , a.CURRENCY_CODE
     , a.RBS_ELEMENT_ID
     , a.RBS_VERSION_ID
     , a.PLAN_VERSION_ID
     , a.PLAN_TYPE_ID
	 , a.LINE_TYPE
	 , a.TIME_DANGLING_FLAG
	 , a.RATE_DANGLING_FLAG;

End for 4005006 */

    INSERT INTO pji_fp_aggr_pjp1_t  -- Non time phased entries..
    (
       worker_id
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
     , ACT_LABOR_HRS
     , ACT_EQUIP_HRS
     , ACT_LABOR_BRDN_COST
     , ACT_EQUIP_BRDN_COST
     , ACT_BRDN_COST
     , ACT_RAW_COST
     , ACT_REVENUE
     , ACT_LABOR_RAW_COST
     , ACT_EQUIP_RAW_COST
     , ETC_LABOR_HRS
     , ETC_EQUIP_HRS
     , ETC_LABOR_BRDN_COST
     , ETC_EQUIP_BRDN_COST
     , ETC_BRDN_COST
     , ETC_RAW_COST
     , ETC_LABOR_RAW_COST
     , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , TIME_DANGLING_FLAG
     , RATE_DANGLING_FLAG
     , PRG_LEVEL
     , PLAN_TYPE_CODE
	)
   SELECT
       g_worker_id  worker_id
     , a.PROJECT_ID
     , a.PROJECT_ORG_ID
     , a.PROJECT_ORGANIZATION_ID
     , a.PROJECT_ELEMENT_ID
     , a.TIME_ID
     , 32 -- a.PERIOD_TYPE_ID
     , a.CALENDAR_TYPE
     , a.RBS_AGGR_LEVEL
     , a.WBS_ROLLUP_FLAG
     , a.PRG_ROLLUP_FLAG
     , a.CURR_RECORD_TYPE_ID
     , a.CURRENCY_CODE
     , a.RBS_ELEMENT_ID
     , a.RBS_VERSION_ID
     , a.PLAN_VERSION_ID
     , a.PLAN_TYPE_ID
     , SUM(ROUND (nvl(a.raw_cost,0)*a.factor/a.mau)*a.mau) raw_cost
     , SUM(ROUND (nvl(a.brdn_cost,0)*a.factor/a.mau)*a.mau) brdn_cost
     , SUM(ROUND (nvl(a.revenue,0)*a.factor/a.mau)*a.mau) revenue
     , SUM(ROUND (nvl(a.bill_raw_cost,0)*a.factor/a.mau)*a.mau) bill_raw_cost
     , SUM(ROUND (nvl(a.bill_brdn_cost,0)*a.factor/a.mau)*a.mau) bill_brdn_cost
     , SUM(ROUND (nvl(a.bill_labor_raw_cost,0)*a.factor/a.mau)*a.mau) bill_labor_raw_cost
     , SUM(ROUND (nvl(a.bill_labor_brdn_cost,0)*a.factor/a.mau)*a.mau) bill_labor_brdn_cost
     , SUM(ROUND (nvl(a.bill_labor_hrs,0)*a.factor/a.mau)*a.mau) bill_labor_hrs
     , SUM(ROUND (nvl(a.equipment_raw_cost,0)*a.factor/a.mau)*a.mau) equipment_raw_cost
     , SUM(ROUND (nvl(a.equipment_brdn_cost,0)*a.factor/a.mau)*a.mau) equipment_brdn_cost
     , SUM(ROUND (nvl(a.capitalizable_raw_cost,0)*a.factor/a.mau)*a.mau) capitalizable_raw_cost
     , SUM(ROUND (nvl(a.capitalizable_brdn_cost,0)*a.factor/a.mau)*a.mau) capitalizable_brdn_cost
     , SUM(ROUND (nvl(a.labor_raw_cost,0)*a.factor/a.mau)*a.mau) labor_raw_cost
     , SUM(ROUND (nvl(a.labor_brdn_cost,0)*a.factor/a.mau)*a.mau) labor_brdn_cost
     , SUM(ROUND (nvl(a.labor_hrs,0)*a.factor/a.mau)*a.mau) labor_hrs
     , SUM(ROUND (nvl(a.labor_revenue,0)*a.factor/a.mau)*a.mau) labor_revenue
     , SUM(ROUND (nvl(a.equipment_hours,0)*a.factor/a.mau)*a.mau) equipment_hours
     , SUM(ROUND (nvl(a.billable_equipment_hours,0)*a.factor/a.mau)*a.mau) billable_equipment_hours         , SUM(ROUND (nvl(a.sup_inv_committed_cost,0)*a.factor/a.mau)*a.mau) sup_inv_committed_cost
     , SUM(ROUND (nvl(a.po_committed_cost,0)*a.factor/a.mau)*a.mau) po_committed_cost
     , SUM(ROUND (nvl(a.pr_committed_cost,0)*a.factor/a.mau)*a.mau) pr_committed_cost
     , SUM(ROUND (nvl(a.oth_committed_cost,0)*a.factor/a.mau)*a.mau) oth_committed_cost
     , SUM(ROUND (nvl(a.ACT_LABOR_HRS,0)*a.factor/a.mau)*a.mau) ACT_LABOR_HRS
     , SUM(ROUND (nvl(a.ACT_EQUIP_HRS,0)*a.factor/a.mau)*a.mau) ACT_EQUIP_HRS
     , SUM(ROUND (nvl(a.ACT_LABOR_BRDN_COST,0)*a.factor/a.mau)*a.mau) ACT_LABOR_BRDN_COST
     , SUM(ROUND (nvl(a.ACT_EQUIP_BRDN_COST,0)*a.factor/a.mau)*a.mau) ACT_EQUIP_BRDN_COST
     , SUM(ROUND (nvl(a.ACT_BRDN_COST,0)*a.factor/a.mau)*a.mau) ACT_BRDN_COST
     , SUM(ROUND (nvl(a.ACT_RAW_COST,0)*a.factor/a.mau)*a.mau) ACT_RAW_COST
     , SUM(ROUND (nvl(a.ACT_REVENUE,0)*a.factor/a.mau)*a.mau) ACT_REVENUE
     , SUM(ROUND (nvl(a.ACT_LABOR_RAW_COST,0)*a.factor/a.mau)*a.mau) ACT_LABOR_RAW_COST
     , SUM(ROUND (nvl(a.ACT_EQUIP_RAW_COST,0)*a.factor/a.mau)*a.mau) ACT_EQUIP_RAW_COST
     , SUM(ROUND (nvl(a.ETC_LABOR_HRS,0)*a.factor/a.mau)*a.mau) ETC_LABOR_HRS
     , SUM(ROUND (nvl(a.ETC_EQUIP_HRS,0)*a.factor/a.mau)*a.mau) ETC_EQUIP_HRS
     , SUM(ROUND (nvl(a.ETC_LABOR_BRDN_COST,0)*a.factor/a.mau)*a.mau) ETC_LABOR_BRDN_COST
     , SUM(ROUND (nvl(a.ETC_EQUIP_BRDN_COST,0)*a.factor/a.mau)*a.mau) ETC_EQUIP_BRDN_COST
     , SUM(ROUND (nvl(a.ETC_BRDN_COST,0)*a.factor/a.mau)*a.mau) ETC_BRDN_COST
     , SUM(ROUND (nvl(a.ETC_RAW_COST,0)*a.factor/a.mau)*a.mau) ETC_RAW_COST
     , SUM(ROUND (nvl(a.ETC_LABOR_RAW_COST,0)*a.factor/a.mau)*a.mau) ETC_LABOR_RAW_COST
     , SUM(ROUND (nvl(a.ETC_EQUIP_RAW_COST,0)*a.factor/a.mau)*a.mau) ETC_EQUIP_RAW_COST
     , SUM(ROUND (nvl(a.custom1,0)*a.factor/a.mau)*a.mau) custom1
     , SUM(ROUND (nvl(a.custom2,0)*a.factor/a.mau)*a.mau) custom2
     , SUM(ROUND (nvl(a.custom3,0)*a.factor/a.mau)*a.mau) custom3
     , SUM(ROUND (nvl(a.custom4,0)*a.factor/a.mau)*a.mau) custom4
     , SUM(ROUND (nvl(a.custom5,0)*a.factor/a.mau)*a.mau) custom5
     , SUM(ROUND (nvl(a.custom6,0)*a.factor/a.mau)*a.mau) custom6
     , SUM(ROUND (nvl(a.custom7,0)*a.factor/a.mau)*a.mau) custom7
     , SUM(ROUND (nvl(a.custom8,0)*a.factor/a.mau)*a.mau) custom8
     , SUM(ROUND (nvl(a.custom9,0)*a.factor/a.mau)*a.mau) custom9
     , SUM(ROUND (nvl(a.custom10,0)*a.factor/a.mau)*a.mau) custom10
     , SUM(ROUND (nvl(a.custom11,0)*a.factor/a.mau)*a.mau) custom11
     , SUM(ROUND (nvl(a.custom12,0)*a.factor/a.mau)*a.mau) custom12
     , SUM(ROUND (nvl(a.custom13,0)*a.factor/a.mau)*a.mau) custom13
     , SUM(ROUND (nvl(a.custom14,0)*a.factor/a.mau)*a.mau) custom14
     , SUM(ROUND (nvl(a.custom15,0)*a.factor/a.mau)*a.mau) custom15
     , a.TIME_DANGLING_FLAG
     , a.RATE_DANGLING_FLAG
     , g_default_prg_level prg_level
     , a.plan_type_code plan_type_Code   /* 4471527 */
  FROM (
   SELECT /*+ NO_MERGE */
           fact.project_id  project_id
   	 , fact.project_ORG_ID project_ORG_ID
   	 , fact.project_ORGANIZATION_ID project_ORGANIZATION_ID
   	 , fact.PROJECT_ELEMENT_ID PROJECT_ELEMENT_ID
   	 , pa_cal.cal_period_id TIME_ID
   	 , fact.PERIOD_TYPE_ID PERIOD_TYPE_ID
         , p_calendar_type  CALENDAR_TYPE
         , fact.RBS_AGGR_LEVEL
         , fact.WBS_ROLLUP_FLAG
         , fact.PRG_ROLLUP_FLAG
   	 , fact.CURR_RECORD_TYPE_ID CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID PLAN_VERSION_ID
	 , fact.PLAN_TYPE_ID  PLAN_TYPE_ID
         , fact.raw_cost
         , fact.brdn_cost
         , fact.revenue
         , fact.bill_raw_cost
         , fact.bill_brdn_cost
         , fact.bill_labor_raw_cost
         , fact.bill_labor_brdn_cost
         , fact.bill_labor_hrs
         , fact.equipment_raw_cost
         , fact.equipment_brdn_cost
         , fact.capitalizable_raw_cost
         , fact.capitalizable_brdn_cost
         , fact.labor_raw_cost
         , fact.labor_brdn_cost
         , fact.labor_hrs
         , fact.labor_revenue
         , fact.equipment_hours
         , fact.billable_equipment_hours
         , fact.sup_inv_committed_cost
         , fact.po_committed_cost
         , fact.pr_committed_cost
         , fact.oth_committed_cost
         , fact.ACT_LABOR_HRS
         , fact.ACT_EQUIP_HRS
         , fact.ACT_LABOR_BRDN_COST
         , fact.ACT_EQUIP_BRDN_COST
         , fact.ACT_BRDN_COST
         , fact.ACT_RAW_COST
         , fact.ACT_REVENUE
         , fact.ACT_LABOR_RAW_COST
         , fact.ACT_EQUIP_RAW_COST
         , fact.ETC_LABOR_HRS
         , fact.ETC_EQUIP_HRS
         , fact.ETC_LABOR_BRDN_COST
         , fact.ETC_EQUIP_BRDN_COST
         , fact.ETC_BRDN_COST
         , fact.ETC_RAW_COST
         , fact.ETC_LABOR_RAW_COST
         , fact.ETC_EQUIP_RAW_COST
         , fact.custom1
         , fact.custom2
         , fact.custom3
         , fact.custom4
         , fact.custom5
         , fact.custom6
         , fact.custom7
         , fact.custom8
         , fact.custom9
         , fact.custom10
         , fact.custom11
         , fact.custom12
         , fact.custom13
         , fact.custom14
         , fact.custom15
	 , NULL time_dangling_flag
	 , NULL rate_dangling_flag
         , cur.mau mau
         , (LEAST(fact.end_date,pa_cal.end_date) - Greatest(fact.start_date,pa_cal.start_date)+1)
                              / (fact.end_date - fact.start_date+1) factor
          , fact.plan_type_code    plan_type_code   /* 4471527 */
   FROM    pji_fp_aggr_pjp1_t fact
   	 , pji_org_extr_info  orginfo
   	 , pji_time_cal_period_v  pa_cal
         , pji_fm_extr_plnver3_t  ver
         ,(SELECT currency_code,
                   decode(nvl(MINIMUM_ACCOUNTABLE_UNIT, power(10, (-1 * PRECISION))),
                      null, 0.01,
                         0, 1,
                         nvl(MINIMUM_ACCOUNTABLE_UNIT, power(10, (-1 * PRECISION)))) mau
              FROM FND_CURRENCIES) cur
   WHERE  1=1
      AND fact.CALENDAR_TYPE = 'A'
      AND fact.worker_id = g_worker_id
      AND fact.start_date IS NOT NULL
      AND fact.end_date IS NOT NULL
      AND fact.time_dangling_flag IS NULL
      AND fact.rate_dangling_flag IS NULL
      AND orginfo.org_id = fact.PROJECT_ORG_ID
      AND DECODE(p_calendar_type
               , 'P', orginfo.pa_calendar_id
               , 'G', orginfo.gl_calendar_id) = pa_cal.calendar_id
      AND fact.line_type = 'NTP'
      AND fact.period_type_id = 2048
      AND fact.plan_version_id = ver.plan_version_id
      ANd fact.plan_type_code = ver.plan_type_code   /* 4471527 */
      AND ver.wp_flag = 'N'
      AND ver.baselined_flag = 'Y'
      AND ver.time_phased_type_code = 'N'
      AND ( fact.start_date <= pa_cal.end_date AND fact.end_date >= pa_cal.start_date )
      -- AND (ver.rbs_struct_version_id = fact.rbs_version_id  OR fact.rbs_version_id = -1)
      AND NVL(ver.rbs_struct_version_id, -1) = fact.rbs_version_id
      AND cur.currency_code = fact.currency_code
	  ) a
      WHERE a.factor >0
   GROUP BY
       a.PROJECT_ID
     , a.PROJECT_ORG_ID
     , a.PROJECT_ORGANIZATION_ID
     , a.PROJECT_ELEMENT_ID
     , a.TIME_ID
     , a.PERIOD_TYPE_ID
     , a.CALENDAR_TYPE
     , a.RBS_AGGR_LEVEL
     , a.WBS_ROLLUP_FLAG
     , a.PRG_ROLLUP_FLAG
     , a.CURR_RECORD_TYPE_ID
     , a.CURRENCY_CODE
     , a.RBS_ELEMENT_ID
     , a.RBS_VERSION_ID
     , a.PLAN_VERSION_ID
     , a.PLAN_TYPE_ID
     , a.PLAN_TYPE_CODE    /* 4471527 */
	 , a.TIME_DANGLING_FLAG
	 , a.RATE_DANGLING_FLAG;


EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => ' PRORATE_TO_PAGL_N_PJP1_D ');
    RAISE;
END;


PROCEDURE PRORATE_TO_PAGL_PGE_PJP1_SE (p_calendar_type    IN  VARCHAR2 := NULL,
                                       p_prorating_format IN  VARCHAR2) IS
BEGIN

    -- g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;

/* Commented for bug 4005006
    INSERT INTO pji_fp_aggr_pjp1_t -- For PA/GL entries.
    (
       worker_id
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , LINE_TYPE
     , TIME_DANGLING_FLAG
     , RATE_DANGLING_FLAG
     , PRG_LEVEL
	)
   SELECT
         g_worker_id
       , fact.project_id  project_id
	 , fact.PROJECT_ORG_ID project_org_id
	 , fact.PROJECT_ORGANIZATION_ID project_organization_id
     -- , fact.PARTITION_ID PARTITION_ID
   	 , fact.PROJECT_ELEMENT_ID PROJECT_ELEMENT_ID
   	 , pa_cal.cal_period_id TIME_ID
   	 , fact.PERIOD_TYPE_ID PERIOD_TYPE_ID
   	 , DECODE(fact.CALENDAR_TYPE, 'P', 'G', 'G', 'P') CALENDAR_TYPE
     , fact.RBS_AGGR_LEVEL RBS_AGGR_LEVEL
     , fact.WBS_ROLLUP_FLAG WBS_ROLLUP_FLAG
     , fact.PRG_ROLLUP_FLAG PRG_ROLLUP_FLAG
     , fact.CURR_RECORD_TYPE_ID CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID PLAN_VERSION_ID
   	 , fact.PLAN_TYPE_ID PLAN_TYPE_ID
   	 , MAX(fact.RAW_COST)	 raw_cost
   	 , MAX(fact.BRDN_COST) BRDN_COST
   	 , MAX(fact.REVENUE) REVENUE
   	 , MAX(fact.BILL_RAW_COST) BILL_RAW_COST
   	 , MAX(fact.BILL_BRDN_COST) BILL_BRDN_COST
   	 , MAX(fact.BILL_LABOR_RAW_COST) BILL_LABOR_RAW_COST
   	 , MAX(fact.BILL_LABOR_BRDN_COST) BILL_LABOR_BRDN_COST
   	 , MAX(fact.BILL_LABOR_HRS) BILL_LABOR_HRS
   	 , MAX(fact.EQUIPMENT_RAW_COST) EQUIPMENT_RAW_COST
   	 , MAX(fact.EQUIPMENT_BRDN_COST) EQUIPMENT_BRDN_COST
   	 , MAX(fact.CAPITALIZABLE_RAW_COST) CAPITALIZABLE_RAW_COST
   	 , MAX(fact.CAPITALIZABLE_BRDN_COST) CAPITALIZABLE_BRDN_COST
   	 , MAX(fact.LABOR_RAW_COST) LABOR_RAW_COST
   	 , MAX(fact.LABOR_BRDN_COST) LABOR_BRDN_COST
   	 , MAX(fact.LABOR_HRS) LABOR_HRS
   	 , MAX(fact.LABOR_REVENUE) LABOR_REVENUE
   	 , MAX(fact.EQUIPMENT_HOURS) EQUIPMENT_HOURS
   	 , MAX(fact.BILLABLE_EQUIPMENT_HOURS) BILLABLE_EQUIPMENT_HOURS
   	 , MAX(fact.SUP_INV_COMMITTED_COST) SUP_INV_COMMITTED_COST
   	 , MAX(fact.PO_COMMITTED_COST) PO_COMMITTED_COST
   	 , MAX(fact.PR_COMMITTED_COST) PR_COMMITTED_COST
   	 , MAX(fact.OTH_COMMITTED_COST) OTH_COMMITTED_COST
       , MAX(fact.ACT_LABOR_HRS )
	 , MAX(fact.ACT_EQUIP_HRS )
	 , MAX(fact.ACT_LABOR_BRDN_COST )
	 , MAX(fact.ACT_EQUIP_BRDN_COST )
	 , MAX(fact.ACT_BRDN_COST )
	 , MAX(fact.ACT_RAW_COST )
	 , MAX(fact.ACT_REVENUE )
       , MAX(fact.ACT_LABOR_RAW_COST)
       , MAX(fact.ACT_EQUIP_RAW_COST)
	 , MAX(fact.ETC_LABOR_HRS )
	 , MAX(fact.ETC_EQUIP_HRS )
	 , MAX(fact.ETC_LABOR_BRDN_COST )
	 , MAX(fact.ETC_EQUIP_BRDN_COST )
	 , MAX(fact.ETC_BRDN_COST )
       , MAX(fact.ETC_RAW_COST )
       , MAX(fact.ETC_LABOR_RAW_COST)
       , MAX(fact.ETC_EQUIP_RAW_COST)
   	 , MAX(fact.CUSTOM1) CUSTOM1
   	 , MAX(fact.CUSTOM2) CUSTOM2
   	 , MAX(fact.CUSTOM3) CUSTOM3
   	 , MAX(fact.CUSTOM4) CUSTOM4
   	 , MAX(fact.CUSTOM5) CUSTOM5
   	 , MAX(fact.CUSTOM6) CUSTOM6
   	 , MAX(fact.CUSTOM7) CUSTOM7
   	 , MAX(fact.CUSTOM8) CUSTOM8
   	 , MAX(fact.CUSTOM9) CUSTOM9
   	 , MAX(fact.CUSTOM10) CUSTOM10
   	 , MAX(fact.CUSTOM11) CUSTOM11
   	 , MAX(fact.CUSTOM12) CUSTOM12
   	 , MAX(fact.CUSTOM13) CUSTOM13
   	 , MAX(fact.CUSTOM14) CUSTOM14
   	 , MAX(fact.CUSTOM15) CUSTOM15
   	 -- , DECODE ('E', 'E', MAX(pa_cal.start_date), 'S', MIN(pa_cal.start_date)) start_date
   	 -- , DECODE ('E', 'E', MAX(pa_cal.end_date), 'S', MIN(pa_cal.end_date))	 end_date
       , 'CF'   line_type
	 , NULL TIME_DANGLING_FLAG
	 , NULL RATE_DANGLING_FLAG
       , g_default_prg_level prg_level
   FROM   pji_fp_aggr_pjp1_t fact
        , pji_time_cal_period  non_pa_cal
   	 , pji_org_extr_info  orginfo
   	 , pji_time_cal_period  pa_cal
       , pji_fm_extr_plnver3_t  ver
   WHERE  fact.CALENDAR_TYPE <> p_calendar_type
      AND fact.worker_id = g_worker_id
      AND fact.CALENDAR_TYPE IN ('P', 'G')
      AND non_pa_cal.cal_period_id = fact.time_id
      AND fact.line_type like 'OF%'
      AND orginfo.org_id = fact.PROJECT_ORG_ID
      AND DECODE(fact.calendar_type, 'P', orginfo.gl_calendar_id, 'G', orginfo.pa_calendar_id) = pa_cal.calendar_id
      AND pa_cal.start_date >= non_pa_cal.start_date
      AND ( non_pa_cal.end_date <= pa_cal.end_date AND non_pa_cal.end_date >= pa_cal.start_date )
      AND fact.period_type_id = 32
      AND fact.plan_version_id = ver.plan_version_id
      AND ver.wp_flag = 'N'
      AND ver.baselined_flag = 'Y'
	-- AND (ver.rbs_struct_version_id = fact.rbs_version_id OR fact.rbs_version_id = -1)
      AND NVL(ver.rbs_struct_version_id, -1) = fact.rbs_version_id
   GROUP BY
       fact.project_id
	 , fact.PROJECT_ORG_ID
	 , fact.PROJECT_ORGANIZATION_ID
     -- , fact.PARTITION_ID
   	 , fact.PROJECT_ELEMENT_ID
   	 , pa_cal.cal_period_id
   	 , fact.PERIOD_TYPE_ID
   	 , fact.CALENDAR_TYPE
     , fact.RBS_AGGR_LEVEL
     , fact.WBS_ROLLUP_FLAG
     , fact.PRG_ROLLUP_FLAG
     , fact.CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID
   	 , fact.PLAN_TYPE_ID ;

End of bug 4005006*/

    INSERT INTO pji_fp_aggr_pjp1_t -- For PA/GL entries.
    (
       worker_id
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
     , ACT_LABOR_HRS
     , ACT_EQUIP_HRS
     , ACT_LABOR_BRDN_COST
     , ACT_EQUIP_BRDN_COST
     , ACT_BRDN_COST
     , ACT_RAW_COST
     , ACT_REVENUE
     , ACT_LABOR_RAW_COST
     , ACT_EQUIP_RAW_COST
     , ETC_LABOR_HRS
     , ETC_EQUIP_HRS
     , ETC_LABOR_BRDN_COST
     , ETC_EQUIP_BRDN_COST
     , ETC_BRDN_COST
     , ETC_RAW_COST
     , ETC_LABOR_RAW_COST
     , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , TIME_DANGLING_FLAG
     , RATE_DANGLING_FLAG
     , PRG_LEVEL
     , PLAN_TYPE_CODE    /* 4471527 */
	)
   SELECT
           g_worker_id
         , fact.project_id  project_id
	 , fact.PROJECT_ORG_ID project_org_id
	 , fact.PROJECT_ORGANIZATION_ID project_organization_id
   	 , fact.PROJECT_ELEMENT_ID PROJECT_ELEMENT_ID
   	 , pa_cal.cal_period_id TIME_ID
   	 , fact.PERIOD_TYPE_ID PERIOD_TYPE_ID
   	 , DECODE(fact.CALENDAR_TYPE, 'P', 'G', 'G', 'P') CALENDAR_TYPE
         , fact.RBS_AGGR_LEVEL RBS_AGGR_LEVEL
         , fact.WBS_ROLLUP_FLAG WBS_ROLLUP_FLAG
         , fact.PRG_ROLLUP_FLAG PRG_ROLLUP_FLAG
         , fact.CURR_RECORD_TYPE_ID CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID PLAN_VERSION_ID
   	 , fact.PLAN_TYPE_ID PLAN_TYPE_ID
   	 , SUM(fact.RAW_COST)	 raw_cost
   	 , SUM(fact.BRDN_COST) BRDN_COST
   	 , SUM(fact.REVENUE) REVENUE
   	 , SUM(fact.BILL_RAW_COST) BILL_RAW_COST
   	 , SUM(fact.BILL_BRDN_COST) BILL_BRDN_COST
   	 , SUM(fact.BILL_LABOR_RAW_COST) BILL_LABOR_RAW_COST
   	 , SUM(fact.BILL_LABOR_BRDN_COST) BILL_LABOR_BRDN_COST
   	 , SUM(fact.BILL_LABOR_HRS) BILL_LABOR_HRS
   	 , SUM(fact.EQUIPMENT_RAW_COST) EQUIPMENT_RAW_COST
   	 , SUM(fact.EQUIPMENT_BRDN_COST) EQUIPMENT_BRDN_COST
   	 , SUM(fact.CAPITALIZABLE_RAW_COST) CAPITALIZABLE_RAW_COST
   	 , SUM(fact.CAPITALIZABLE_BRDN_COST) CAPITALIZABLE_BRDN_COST
   	 , SUM(fact.LABOR_RAW_COST) LABOR_RAW_COST
   	 , SUM(fact.LABOR_BRDN_COST) LABOR_BRDN_COST
   	 , SUM(fact.LABOR_HRS) LABOR_HRS
   	 , SUM(fact.LABOR_REVENUE) LABOR_REVENUE
   	 , SUM(fact.EQUIPMENT_HOURS) EQUIPMENT_HOURS
   	 , SUM(fact.BILLABLE_EQUIPMENT_HOURS) BILLABLE_EQUIPMENT_HOURS
   	 , SUM(fact.SUP_INV_COMMITTED_COST) SUP_INV_COMMITTED_COST
   	 , SUM(fact.PO_COMMITTED_COST) PO_COMMITTED_COST
   	 , SUM(fact.PR_COMMITTED_COST) PR_COMMITTED_COST
   	 , SUM(fact.OTH_COMMITTED_COST) OTH_COMMITTED_COST
         , SUM(fact.ACT_LABOR_HRS )
	 , SUM(fact.ACT_EQUIP_HRS )
	 , SUM(fact.ACT_LABOR_BRDN_COST )
	 , SUM(fact.ACT_EQUIP_BRDN_COST )
	 , SUM(fact.ACT_BRDN_COST )
	 , SUM(fact.ACT_RAW_COST )
	 , SUM(fact.ACT_REVENUE )
         , SUM(fact.ACT_LABOR_RAW_COST)
         , SUM(fact.ACT_EQUIP_RAW_COST)
	 , SUM(fact.ETC_LABOR_HRS )
	 , SUM(fact.ETC_EQUIP_HRS )
	 , SUM(fact.ETC_LABOR_BRDN_COST )
	 , SUM(fact.ETC_EQUIP_BRDN_COST )
	 , SUM(fact.ETC_BRDN_COST )
         , SUM(fact.ETC_RAW_COST )
         , SUM(fact.ETC_LABOR_RAW_COST)
         , SUM(fact.ETC_EQUIP_RAW_COST)
   	 , SUM(fact.CUSTOM1) CUSTOM1
   	 , SUM(fact.CUSTOM2) CUSTOM2
   	 , SUM(fact.CUSTOM3) CUSTOM3
   	 , SUM(fact.CUSTOM4) CUSTOM4
   	 , SUM(fact.CUSTOM5) CUSTOM5
   	 , SUM(fact.CUSTOM6) CUSTOM6
   	 , SUM(fact.CUSTOM7) CUSTOM7
   	 , SUM(fact.CUSTOM8) CUSTOM8
   	 , SUM(fact.CUSTOM9) CUSTOM9
   	 , SUM(fact.CUSTOM10) CUSTOM10
   	 , SUM(fact.CUSTOM11) CUSTOM11
   	 , SUM(fact.CUSTOM12) CUSTOM12
   	 , SUM(fact.CUSTOM13) CUSTOM13
   	 , SUM(fact.CUSTOM14) CUSTOM14
   	 , SUM(fact.CUSTOM15) CUSTOM15
	 , NULL TIME_DANGLING_FLAG
	 , NULL RATE_DANGLING_FLAG
         , g_default_prg_level prg_level
         , fact.PLAN_TYPE_CODE   PLAN_TYPE_CODe   /* 4471527 */
     FROM  pji_fp_aggr_pjp1_t fact
         , pji_time_cal_period_v  non_pa_cal
   	 , pji_org_extr_info  orginfo
   	 , pji_time_cal_period_v  pa_cal
         , pji_fm_extr_plnver3_t  ver
   WHERE  fact.CALENDAR_TYPE <> p_calendar_type
      AND fact.worker_id = g_worker_id
      AND fact.CALENDAR_TYPE IN ('P', 'G')
      AND non_pa_cal.cal_period_id = fact.time_id
      AND fact.line_type like 'OF%'
      AND orginfo.org_id = fact.PROJECT_ORG_ID
      AND DECODE(fact.calendar_type, 'P', orginfo.gl_calendar_id, 'G', orginfo.pa_calendar_id) = pa_cal.calendar_id
      AND ( non_pa_cal.start_date <= pa_cal.end_date AND non_pa_cal.end_date >= pa_cal.start_date )
      AND fact.period_type_id = 32
      AND fact.plan_version_id = ver.plan_version_id
      AND fact.plan_type_code = ver.plan_type_code   /* 4471527 */
      AND ver.wp_flag = 'N'
      AND ver.baselined_flag = 'Y'
      -- AND (ver.rbs_struct_version_id = fact.rbs_version_id OR fact.rbs_version_id = -1)
      AND NVL(ver.rbs_struct_version_id, -1) = fact.rbs_version_id
      AND DECODE(p_prorating_format,'S',
             DECODE(SIGN(non_pa_cal.start_Date-pa_cal.start_date),-1,0,1),
             DECODE(SIGN(non_pa_cal.end_Date - pa_cal.end_date), 1,0,1))=1
   GROUP BY
           fact.project_id
	 , fact.PROJECT_ORG_ID
	 , fact.PROJECT_ORGANIZATION_ID
   	 , fact.PROJECT_ELEMENT_ID
   	 , pa_cal.cal_period_id
   	 , fact.PERIOD_TYPE_ID
   	 , fact.CALENDAR_TYPE
         , fact.RBS_AGGR_LEVEL
         , fact.WBS_ROLLUP_FLAG
         , fact.PRG_ROLLUP_FLAG
         , fact.CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID
   	 , fact.PLAN_TYPE_ID
              , fact.PLAN_TYPE_CODe  ;   /* 4471527 */

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRORATE_TO_PAGL_PGE_PJP1_SE');
    RAISE;
END;


PROCEDURE PRORATE_TO_PAGL_PGE_FPRL_SE (p_calendar_type   IN   VARCHAR2 := NULL) IS
BEGIN

    -- g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;

    INSERT INTO pji_fp_aggr_pjp1_t -- For PA/GL entries.
    (
       worker_id
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , LINE_TYPE
     , TIME_DANGLING_FLAG
     , RATE_DANGLING_FLAG
     , PRG_LEVEL
     , PLAN_TYPE_CODE    /* 4471527 */
   )
   SELECT
         g_worker_id
       , fact.project_id  project_id
	 , fact.PROJECT_ORG_ID project_org_id
	 , fact.PROJECT_ORGANIZATION_ID project_organization_id
     -- , fact.PARTITION_ID PARTITION_ID
   	 , fact.PROJECT_ELEMENT_ID PROJECT_ELEMENT_ID
   	 , pa_cal.cal_period_id TIME_ID
   	 , fact.PERIOD_TYPE_ID PERIOD_TYPE_ID
   	 , DECODE(fact.CALENDAR_TYPE, 'P', 'G', 'G', 'P') CALENDAR_TYPE
     , fact.RBS_AGGR_LEVEL RBS_AGGR_LEVEL
     , fact.WBS_ROLLUP_FLAG WBS_ROLLUP_FLAG
     , fact.PRG_ROLLUP_FLAG PRG_ROLLUP_FLAG
     , fact.CURR_RECORD_TYPE_ID CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID PLAN_VERSION_ID
   	 , fact.PLAN_TYPE_ID PLAN_TYPE_ID
   	 , MAX(fact.RAW_COST)	 raw_cost
   	 , MAX(fact.BRDN_COST) BRDN_COST
   	 , MAX(fact.REVENUE) REVENUE
   	 , MAX(fact.BILL_RAW_COST) BILL_RAW_COST
   	 , MAX(fact.BILL_BRDN_COST) BILL_BRDN_COST
   	 , MAX(fact.BILL_LABOR_RAW_COST) BILL_LABOR_RAW_COST
   	 , MAX(fact.BILL_LABOR_BRDN_COST) BILL_LABOR_BRDN_COST
   	 , MAX(fact.BILL_LABOR_HRS) BILL_LABOR_HRS
   	 , MAX(fact.EQUIPMENT_RAW_COST) EQUIPMENT_RAW_COST
   	 , MAX(fact.EQUIPMENT_BRDN_COST) EQUIPMENT_BRDN_COST
   	 , MAX(fact.CAPITALIZABLE_RAW_COST) CAPITALIZABLE_RAW_COST
   	 , MAX(fact.CAPITALIZABLE_BRDN_COST) CAPITALIZABLE_BRDN_COST
   	 , MAX(fact.LABOR_RAW_COST) LABOR_RAW_COST
   	 , MAX(fact.LABOR_BRDN_COST) LABOR_BRDN_COST
   	 , MAX(fact.LABOR_HRS) LABOR_HRS
   	 , MAX(fact.LABOR_REVENUE) LABOR_REVENUE
   	 , MAX(fact.EQUIPMENT_HOURS) EQUIPMENT_HOURS
   	 , MAX(fact.BILLABLE_EQUIPMENT_HOURS) BILLABLE_EQUIPMENT_HOURS
   	 , MAX(fact.SUP_INV_COMMITTED_COST) SUP_INV_COMMITTED_COST
   	 , MAX(fact.PO_COMMITTED_COST) PO_COMMITTED_COST
   	 , MAX(fact.PR_COMMITTED_COST) PR_COMMITTED_COST
   	 , MAX(fact.OTH_COMMITTED_COST) OTH_COMMITTED_COST
       , MAX(fact.ACT_LABOR_HRS )
	 , MAX(fact.ACT_EQUIP_HRS )
	 , MAX(fact.ACT_LABOR_BRDN_COST )
	 , MAX(fact.ACT_EQUIP_BRDN_COST )
	 , MAX(fact.ACT_BRDN_COST )
	 , MAX(fact.ACT_RAW_COST )
	 , MAX(fact.ACT_REVENUE )
       , MAX(fact.ACT_LABOR_RAW_COST)
       , MAX(fact.ACT_EQUIP_RAW_COST)
	 , MAX(fact.ETC_LABOR_HRS )
	 , MAX(fact.ETC_EQUIP_HRS )
	 , MAX(fact.ETC_LABOR_BRDN_COST )
	 , MAX(fact.ETC_EQUIP_BRDN_COST )
	 , MAX(fact.ETC_BRDN_COST )
       , MAX(fact.ETC_RAW_COST )
       , MAX(fact.ETC_LABOR_RAW_COST)
       , MAX(fact.ETC_EQUIP_RAW_COST)
   	 , MAX(fact.CUSTOM1) CUSTOM1
   	 , MAX(fact.CUSTOM2) CUSTOM2
   	 , MAX(fact.CUSTOM3) CUSTOM3
   	 , MAX(fact.CUSTOM4) CUSTOM4
   	 , MAX(fact.CUSTOM5) CUSTOM5
   	 , MAX(fact.CUSTOM6) CUSTOM6
   	 , MAX(fact.CUSTOM7) CUSTOM7
   	 , MAX(fact.CUSTOM8) CUSTOM8
   	 , MAX(fact.CUSTOM9) CUSTOM9
   	 , MAX(fact.CUSTOM10) CUSTOM10
   	 , MAX(fact.CUSTOM11) CUSTOM11
   	 , MAX(fact.CUSTOM12) CUSTOM12
   	 , MAX(fact.CUSTOM13) CUSTOM13
   	 , MAX(fact.CUSTOM14) CUSTOM14
   	 , MAX(fact.CUSTOM15) CUSTOM15
   	 -- , DECODE ('E', 'E', MAX(pa_cal.start_date), 'S', MIN(pa_cal.start_date)) start_date
   	 -- , DECODE ('E', 'E', MAX(pa_cal.end_date), 'S', MIN(pa_cal.end_date))	 end_date
       , 'CF'   line_type
	 , NULL  TIME_DANGLING_FLAG
	 , NULL RATE_DANGLING_FLAG
       , g_default_prg_level prg_level
       , fact.plan_type_code  plan_type_code    /* 4471527 */
   FROM   pji_fp_xbs_accum_f  fact
       , PJI_FM_EXTR_PLNVER3_T ver
        , pji_time_cal_period  non_pa_cal
   	 , pji_org_extr_info  orginfo
   	 , pji_time_cal_period  pa_cal
   WHERE  fact.CALENDAR_TYPE <> p_calendar_type
      AND fact.CALENDAR_TYPE IN ('P', 'G')
      AND non_pa_cal.cal_period_id = fact.time_id
      AND ver.project_id = fact.project_id
      AND ver.plan_version_id = fact.plan_version_id
      ANd ver.plan_type_code = fact.plan_type_code    /*  4471527 */
      AND orginfo.org_id = fact.PROJECT_ORG_ID
      AND DECODE(fact.calendar_type, 'P', orginfo.gl_calendar_id, 'G', orginfo.pa_calendar_id) = pa_cal.calendar_id
      AND pa_cal.start_date >= non_pa_cal.start_date
      AND ( non_pa_cal.end_date <= pa_cal.end_date AND non_pa_cal.end_date >= pa_cal.start_date )
      AND fact.period_type_id = 32
      AND ver.wp_flag = 'N'
      AND ver.baselined_flag = 'Y'
      -- AND (ver.rbs_struct_version_id = fact.rbs_version_id  OR fact.rbs_version_id = -1)
      AND NVL(ver.rbs_struct_version_id, -1) = fact.rbs_version_id
   GROUP BY
       fact.project_id
	 , fact.PROJECT_ORG_ID
	 , fact.PROJECT_ORGANIZATION_ID
     -- , fact.PARTITION_ID
   	 , fact.PROJECT_ELEMENT_ID
   	 , pa_cal.cal_period_id
   	 , fact.PERIOD_TYPE_ID
   	 , fact.CALENDAR_TYPE
     , fact.RBS_AGGR_LEVEL
     , fact.WBS_ROLLUP_FLAG
     , fact.PRG_ROLLUP_FLAG
     , fact.CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID
   	 , fact.PLAN_TYPE_ID
              , fact.PLAN_TYPE_CODE ;   /* 4471527 */


EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRORATE_TO_PAGL_PGE_FPRL_SE');
    RAISE;
END;


PROCEDURE PRORATE_TO_PAGL_N_PJP1_SE (p_calendar_type    IN   VARCHAR2 := NULL,
                                     p_prorating_format IN   VARCHAR2) IS
BEGIN

    IF (p_calendar_type NOT IN ('P', 'G')) THEN
      RETURN;
    END IF;

    -- g_worker_id  := PJI_PJP_FP_CURR_WRAP.GET_WORKER_ID;
 /* Commented for bug 4005006
    INSERT INTO pji_fp_aggr_pjp1_t -- For non time phased entries.
    (
       worker_id
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     -- , PARTITION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , LINE_TYPE
     , TIME_DANGLING_FLAG
     , RATE_DANGLING_FLAG
     , PRG_LEVEL
   )
   SELECT
         g_worker_id
       , fact.project_id  project_id
	 , fact.PROJECT_ORG_ID project_org_id
	 , fact.PROJECT_ORGANIZATION_ID project_organization_id
     -- , fact.PARTITION_ID PARTITION_ID
   	 , fact.PROJECT_ELEMENT_ID PROJECT_ELEMENT_ID
   	 , pa_cal.cal_period_id TIME_ID
   	 , 32 -- fact.PERIOD_TYPE_ID PERIOD_TYPE_ID
   --    , fact.CALENDAR_TYPE CALENDAR_TYPE
         ,DECODE(pa_cal.calendar_id,orginfo.pa_calendar_id,'P',orginfo.gl_calendar_id,'G')
      , fact.RBS_AGGR_LEVEL RBS_AGGR_LEVEL
     , fact.WBS_ROLLUP_FLAG WBS_ROLLUP_FLAG
     , fact.PRG_ROLLUP_FLAG PRG_ROLLUP_FLAG
     , fact.CURR_RECORD_TYPE_ID CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID PLAN_VERSION_ID
   	 , fact.PLAN_TYPE_ID PLAN_TYPE_ID
   	 , MAX(fact.RAW_COST)	 raw_cost
   	 , MAX(fact.BRDN_COST) BRDN_COST
   	 , MAX(fact.REVENUE) REVENUE
   	 , MAX(fact.BILL_RAW_COST) BILL_RAW_COST
   	 , MAX(fact.BILL_BRDN_COST) BILL_BRDN_COST
   	 , MAX(fact.BILL_LABOR_RAW_COST) BILL_LABOR_RAW_COST
   	 , MAX(fact.BILL_LABOR_BRDN_COST) BILL_LABOR_BRDN_COST
   	 , MAX(fact.BILL_LABOR_HRS) BILL_LABOR_HRS
   	 , MAX(fact.EQUIPMENT_RAW_COST) EQUIPMENT_RAW_COST
   	 , MAX(fact.EQUIPMENT_BRDN_COST) EQUIPMENT_BRDN_COST
   	 , MAX(fact.CAPITALIZABLE_RAW_COST) CAPITALIZABLE_RAW_COST
   	 , MAX(fact.CAPITALIZABLE_BRDN_COST) CAPITALIZABLE_BRDN_COST
   	 , MAX(fact.LABOR_RAW_COST) LABOR_RAW_COST
   	 , MAX(fact.LABOR_BRDN_COST) LABOR_BRDN_COST
   	 , MAX(fact.LABOR_HRS) LABOR_HRS
   	 , MAX(fact.LABOR_REVENUE) LABOR_REVENUE
   	 , MAX(fact.EQUIPMENT_HOURS) EQUIPMENT_HOURS
   	 , MAX(fact.BILLABLE_EQUIPMENT_HOURS) BILLABLE_EQUIPMENT_HOURS
   	 , MAX(fact.SUP_INV_COMMITTED_COST) SUP_INV_COMMITTED_COST
   	 , MAX(fact.PO_COMMITTED_COST) PO_COMMITTED_COST
   	 , MAX(fact.PR_COMMITTED_COST) PR_COMMITTED_COST
   	 , MAX(fact.OTH_COMMITTED_COST) OTH_COMMITTED_COST
       , MAX(fact.ACT_LABOR_HRS )
	 , MAX(fact.ACT_EQUIP_HRS )
	 , MAX(fact.ACT_LABOR_BRDN_COST )
	 , MAX(fact.ACT_EQUIP_BRDN_COST )
	 , MAX(fact.ACT_BRDN_COST )
	 , MAX(fact.ACT_RAW_COST )
	 , MAX(fact.ACT_REVENUE )
       , MAX(fact.ACT_LABOR_RAW_COST)
       , MAX(fact.ACT_EQUIP_RAW_COST)
	 , MAX(fact.ETC_LABOR_HRS )
	 , MAX(fact.ETC_EQUIP_HRS )
	 , MAX(fact.ETC_LABOR_BRDN_COST )
	 , MAX(fact.ETC_EQUIP_BRDN_COST )
	 , MAX(fact.ETC_BRDN_COST )
       , MAX(fact.ETC_RAW_COST )
       , MAX(fact.ETC_LABOR_RAW_COST)
       , MAX(fact.ETC_EQUIP_RAW_COST)
   	 , MAX(fact.CUSTOM1) CUSTOM1
   	 , MAX(fact.CUSTOM2) CUSTOM2
   	 , MAX(fact.CUSTOM3) CUSTOM3
   	 , MAX(fact.CUSTOM4) CUSTOM4
   	 , MAX(fact.CUSTOM5) CUSTOM5
   	 , MAX(fact.CUSTOM6) CUSTOM6
   	 , MAX(fact.CUSTOM7) CUSTOM7
   	 , MAX(fact.CUSTOM8) CUSTOM8
   	 , MAX(fact.CUSTOM9) CUSTOM9
   	 , MAX(fact.CUSTOM10) CUSTOM10
   	 , MAX(fact.CUSTOM11) CUSTOM11
   	 , MAX(fact.CUSTOM12) CUSTOM12
   	 , MAX(fact.CUSTOM13) CUSTOM13
   	 , MAX(fact.CUSTOM14) CUSTOM14
   	 , MAX(fact.CUSTOM15) CUSTOM15
   	 -- , DECODE ('E', 'E', MAX(pa_cal.start_date), 'S', MIN(pa_cal.start_date)) start_date
   	 -- , DECODE ('E', 'E', MAX(pa_cal.end_date), 'S', MIN(pa_cal.end_date))	 end_date
     , 'CN'   line_type
	 , NULL  TIME_DANGLING_FLAG
	 , NULL  RATE_DANGLING_FLAG
       , g_default_prg_level prg_level
   FROM   pji_fp_aggr_pjp1_t fact
   	 , pji_org_extr_info  orginfo
   	 , pji_time_cal_period  pa_cal
       , pji_fm_extr_plnver3_t  ver
   WHERE  1=1
      AND fact.CALENDAR_TYPE = 'A'
      AND orginfo.org_id = fact.PROJECT_ORG_ID
      AND DECODE(p_calendar_type
               , 'P', orginfo.pa_calendar_id
               , 'G', orginfo.gl_calendar_id) = pa_cal.calendar_id
      AND fact.start_date IS NOT NULL
      AND fact.end_date IS NOT NULL
      AND (
	       (     pa_cal.start_date >= fact.start_date
               AND pa_cal.end_date <= fact.end_date ) -- fsps,pefe
	    OR (     pa_cal.start_date <= fact.start_date
               AND pa_cal.end_date >= fact.end_date ) -- psfs,fepe
	    OR (     pa_cal.start_date <= fact.start_date
               AND pa_cal.end_date <= fact.end_date
               AND pa_cal.end_date >= fact.start_date ) -- psfspefe
	    OR (     pa_cal.start_date >= fact.start_date
               AND pa_cal.end_date >= fact.end_date
               AND pa_cal.start_date <= fact.end_date )  -- fspsfepe
          )
      AND fact.period_type_id = 2048
      AND fact.plan_version_id = ver.plan_version_id
      AND ver.wp_flag = 'N'
      AND ver.baselined_flag = 'Y'
      AND ver.time_phased_type_code = 'N'
      AND fact.line_type = 'NTP'
      AND fact.worker_id = g_worker_id
	-- AND (ver.rbs_struct_version_id = fact.rbs_version_id  OR fact.rbs_version_id = -1)
      AND NVL(ver.rbs_struct_version_id, -1) = fact.rbs_version_id
   GROUP BY
       fact.project_id
	 , fact.PROJECT_ORG_ID
	 , fact.PROJECT_ORGANIZATION_ID
     -- , fact.PARTITION_ID
   	 , fact.PROJECT_ELEMENT_ID
   	 , pa_cal.cal_period_id
   	 , fact.PERIOD_TYPE_ID
   	 , fact.CALENDAR_TYPE
     , fact.RBS_AGGR_LEVEL
     , fact.WBS_ROLLUP_FLAG
     , fact.PRG_ROLLUP_FLAG
     , fact.CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID
   	 , fact.PLAN_TYPE_ID
	 , fact.TIME_DANGLING_FLAG
	 , fact.RATE_DANGLING_FLAG
         ,pa_cal.CALENDAR_ID,
	 orginfo.pa_calendar_id,
	 orginfo.gl_calendar_id;
 End of bug 4005006*/

    INSERT INTO pji_fp_aggr_pjp1_t -- For non time phased entries.
    (
       worker_id
     , PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
     , ACT_LABOR_HRS
     , ACT_EQUIP_HRS
     , ACT_LABOR_BRDN_COST
     , ACT_EQUIP_BRDN_COST
     , ACT_BRDN_COST
     , ACT_RAW_COST
     , ACT_REVENUE
     , ACT_LABOR_RAW_COST
     , ACT_EQUIP_RAW_COST
     , ETC_LABOR_HRS
     , ETC_EQUIP_HRS
     , ETC_LABOR_BRDN_COST
     , ETC_EQUIP_BRDN_COST
     , ETC_BRDN_COST
     , ETC_RAW_COST
     , ETC_LABOR_RAW_COST
     , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , TIME_DANGLING_FLAG
     , RATE_DANGLING_FLAG
     , PRG_LEVEL
     , PLAN_TYPE_CODE   /* 4471527 */
   )
   SELECT
           g_worker_id
         , fact.project_id  project_id
	 , fact.PROJECT_ORG_ID project_org_id
	 , fact.PROJECT_ORGANIZATION_ID project_organization_id
   	 , fact.PROJECT_ELEMENT_ID PROJECT_ELEMENT_ID
   	 , pa_cal.cal_period_id TIME_ID
   	 , 32 -- fact.PERIOD_TYPE_ID PERIOD_TYPE_ID
         , DECODE(pa_cal.calendar_id,orginfo.pa_calendar_id,'P',orginfo.gl_calendar_id,'G') CALENDAR_TYPE
         , fact.RBS_AGGR_LEVEL RBS_AGGR_LEVEL
         , fact.WBS_ROLLUP_FLAG WBS_ROLLUP_FLAG
         , fact.PRG_ROLLUP_FLAG PRG_ROLLUP_FLAG
         , fact.CURR_RECORD_TYPE_ID CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID PLAN_VERSION_ID
   	 , fact.PLAN_TYPE_ID PLAN_TYPE_ID
   	 , SUM(fact.RAW_COST)	 raw_cost
   	 , SUM(fact.BRDN_COST) BRDN_COST
   	 , SUM(fact.REVENUE) REVENUE
   	 , SUM(fact.BILL_RAW_COST) BILL_RAW_COST
   	 , SUM(fact.BILL_BRDN_COST) BILL_BRDN_COST
   	 , SUM(fact.BILL_LABOR_RAW_COST) BILL_LABOR_RAW_COST
   	 , SUM(fact.BILL_LABOR_BRDN_COST) BILL_LABOR_BRDN_COST
   	 , SUM(fact.BILL_LABOR_HRS) BILL_LABOR_HRS
   	 , SUM(fact.EQUIPMENT_RAW_COST) EQUIPMENT_RAW_COST
   	 , SUM(fact.EQUIPMENT_BRDN_COST) EQUIPMENT_BRDN_COST
   	 , SUM(fact.CAPITALIZABLE_RAW_COST) CAPITALIZABLE_RAW_COST
   	 , SUM(fact.CAPITALIZABLE_BRDN_COST) CAPITALIZABLE_BRDN_COST
   	 , SUM(fact.LABOR_RAW_COST) LABOR_RAW_COST
   	 , SUM(fact.LABOR_BRDN_COST) LABOR_BRDN_COST
   	 , SUM(fact.LABOR_HRS) LABOR_HRS
   	 , SUM(fact.LABOR_REVENUE) LABOR_REVENUE
   	 , SUM(fact.EQUIPMENT_HOURS) EQUIPMENT_HOURS
   	 , SUM(fact.BILLABLE_EQUIPMENT_HOURS) BILLABLE_EQUIPMENT_HOURS
   	 , SUM(fact.SUP_INV_COMMITTED_COST) SUP_INV_COMMITTED_COST
   	 , SUM(fact.PO_COMMITTED_COST) PO_COMMITTED_COST
   	 , SUM(fact.PR_COMMITTED_COST) PR_COMMITTED_COST
   	 , SUM(fact.OTH_COMMITTED_COST) OTH_COMMITTED_COST
         , SUM(fact.ACT_LABOR_HRS )
	 , SUM(fact.ACT_EQUIP_HRS )
	 , SUM(fact.ACT_LABOR_BRDN_COST )
	 , SUM(fact.ACT_EQUIP_BRDN_COST )
	 , SUM(fact.ACT_BRDN_COST )
	 , SUM(fact.ACT_RAW_COST )
	 , SUM(fact.ACT_REVENUE )
         , SUM(fact.ACT_LABOR_RAW_COST)
         , SUM(fact.ACT_EQUIP_RAW_COST)
	 , SUM(fact.ETC_LABOR_HRS )
	 , SUM(fact.ETC_EQUIP_HRS )
	 , SUM(fact.ETC_LABOR_BRDN_COST )
	 , SUM(fact.ETC_EQUIP_BRDN_COST )
	 , SUM(fact.ETC_BRDN_COST )
         , SUM(fact.ETC_RAW_COST )
         , SUM(fact.ETC_LABOR_RAW_COST)
         , SUM(fact.ETC_EQUIP_RAW_COST)
   	 , SUM(fact.CUSTOM1) CUSTOM1
   	 , SUM(fact.CUSTOM2) CUSTOM2
   	 , SUM(fact.CUSTOM3) CUSTOM3
   	 , SUM(fact.CUSTOM4) CUSTOM4
   	 , SUM(fact.CUSTOM5) CUSTOM5
   	 , SUM(fact.CUSTOM6) CUSTOM6
   	 , SUM(fact.CUSTOM7) CUSTOM7
   	 , SUM(fact.CUSTOM8) CUSTOM8
   	 , SUM(fact.CUSTOM9) CUSTOM9
   	 , SUM(fact.CUSTOM10) CUSTOM10
   	 , SUM(fact.CUSTOM11) CUSTOM11
   	 , SUM(fact.CUSTOM12) CUSTOM12
   	 , SUM(fact.CUSTOM13) CUSTOM13
   	 , SUM(fact.CUSTOM14) CUSTOM14
   	 , SUM(fact.CUSTOM15) CUSTOM15
	 , NULL  TIME_DANGLING_FLAG
	 , NULL  RATE_DANGLING_FLAG
         , g_default_prg_level prg_level
         , fact.PLAN_TYPE_CODE   PLAN_TYPE_CODE   /* 4471527 */
      FROM pji_fp_aggr_pjp1_t fact
   	 , pji_org_extr_info  orginfo
   	 , pji_time_cal_period_v  pa_cal
         , pji_fm_extr_plnver3_t  ver
   WHERE  1=1
      AND fact.CALENDAR_TYPE = 'A'
      AND orginfo.org_id = fact.PROJECT_ORG_ID
      AND DECODE(p_calendar_type
               , 'P', orginfo.pa_calendar_id
               , 'G', orginfo.gl_calendar_id) = pa_cal.calendar_id
      AND fact.start_date IS NOT NULL
      AND fact.end_date IS NOT NULL
      AND fact.period_type_id = 2048
      AND fact.plan_version_id = ver.plan_version_id
      AND fact.plan_type_code  = ver.plan_type_code   /* 4471527 */
      AND ver.wp_flag = 'N'
      AND ver.baselined_flag = 'Y'
      AND ver.time_phased_type_code = 'N'
      AND fact.line_type = 'NTP'
      AND fact.worker_id = g_worker_id
      -- AND (ver.rbs_struct_version_id = fact.rbs_version_id  OR fact.rbs_version_id = -1)
      AND NVL(ver.rbs_struct_version_id, -1) = fact.rbs_version_id
      AND ( fact.start_date <= pa_cal.end_date AND fact.end_date >= pa_cal.start_date )
      AND DECODE(p_prorating_format,'S',
             DECODE(SIGN(fact.start_Date-pa_cal.start_date),-1,0,1),
             DECODE(SIGN(fact.end_Date - pa_cal.end_date), 1,0,1))=1
   GROUP BY
           fact.project_id
	 , fact.PROJECT_ORG_ID
	 , fact.PROJECT_ORGANIZATION_ID
   	 , fact.PROJECT_ELEMENT_ID
   	 , pa_cal.cal_period_id
   	 , fact.PERIOD_TYPE_ID
   	 , fact.CALENDAR_TYPE
         , fact.RBS_AGGR_LEVEL
         , fact.WBS_ROLLUP_FLAG
         , fact.PRG_ROLLUP_FLAG
         , fact.CURR_RECORD_TYPE_ID
   	 , fact.CURRENCY_CODE
   	 , fact.RBS_ELEMENT_ID
   	 , fact.RBS_VERSION_ID
   	 , fact.PLAN_VERSION_ID
   	 , fact.PLAN_TYPE_ID
              , fact.PLAN_TYPE_CODe    /* 4471527 */
	 , fact.TIME_DANGLING_FLAG
	 , fact.RATE_DANGLING_FLAG
	 ,  DECODE(pa_cal.calendar_id,orginfo.pa_calendar_id,'P',orginfo.gl_calendar_id,'G');

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRORATE_TO_PAGL_N_PJP1_SE');
    RAISE;
END;


----------
-- Print time API to measure time taken by each api. Also useful for debugging.
----------
PROCEDURE PRINT_TIME(p_tag IN VARCHAR2) IS
BEGIN
  PJI_PJP_FP_CURR_WRAP.print_time(p_tag);
EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRINT_TIME');
    RAISE;
END;


END PJI_FM_PLAN_CAL_RLPS_T;

/
