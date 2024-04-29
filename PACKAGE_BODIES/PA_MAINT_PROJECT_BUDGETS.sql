--------------------------------------------------------
--  DDL for Package Body PA_MAINT_PROJECT_BUDGETS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MAINT_PROJECT_BUDGETS" AS
/* $Header: PAACBUDB.pls 120.2 2005/09/26 15:06:48 jwhite noship $ */

--
--History:
--    	xx-xxx-xxxx     who?		- Created
--
--      26-SEP-2002	jwhite		- Converted to support both r11.5.7 Budget and FP models.
--                                        1) modified cursors to include FP model.
--                                        2) passed fin_plan_type_id to lower-level procedures for
--                                           table insert.
--      31-Jan-2004     sacgupta        - Modified cursor PA_Budget_Cur. Added logic to consider
--                                        x_Budget_Type_Code if passed as a parameter.
--
Procedure Process_Budget_Txns  (X_project_id in Number,
                                X_impl_opt  In Varchar2,
                                x_Proj_accum_id   in Number,
                                x_Budget_Type_code in Varchar2,
                                x_current_period in Varchar2,
                                x_prev_period    in Varchar2,
                                x_current_year   in Number,
                                x_prev_accum_period in Varchar2,
                                x_current_start_date In Date,
                                x_current_end_date  In Date,
                                x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                x_err_code      In Out NOCOPY Number ) Is --File.Sql.39 bug 4440895

-- This cursor fetches all records from pavw669 views
-- which have not yet been accumulated.

CURSOR PA_Budget_Cur IS
Select
   PAB.PROJECT_ID,
   PAB.BUDGET_TYPE_CODE,
   PAB.fin_plan_type_id,
   PAB.TASK_ID task_id,
   PAB.RESOURCE_LIST_MEMBER_ID,
   PAB.RESOURCE_LIST_ID,
   PAB.RESOURCE_ID,
----------------------
   SUM(NVL(PAB.BASE_RAW_COST,0)) BASE_RAW_COST,
   SUM(NVL(PAB.BASE_BURDENED_COST,0)) BASE_BURDENED_COST,
   SUM(NVL(PAB.BASE_REVENUE,0)) BASE_REVENUE,
   SUM(NVL(PAB.BASE_QUANTITY,0)) BASE_QUANTITY,
   SUM(NVL(PAB.BASE_LABOR_QUANTITY,0)) BASE_LABOR_QUANTITY,
   SUM(NVL(PAB.ORIG_RAW_COST,0)) ORIG_RAW_COST,
   SUM(NVL(PAB.ORIG_BURDENED_COST,0)) ORIG_BURDENED_COST,
   SUM(NVL(PAB.ORIG_REVENUE,0)) ORIG_REVENUE,
   SUM(NVL(PAB.ORIG_QUANTITY,0)) ORIG_QUANTITY,
   SUM(NVL(PAB.ORIG_LABOR_QUANTITY,0)) ORIG_LABOR_QUANTITY,
----------------------
   SUM(NVL(PAB.RAW_COST_ITD_BASE,0))		BASE_RAW_COST_ITD,
   SUM(NVL(PAB.BURDENED_COST_ITD_BASE,0))	BASE_BURDENED_COST_ITD,
   SUM(NVL(PAB.REVENUE_ITD_BASE,0))		BASE_REVENUE_ITD,
   SUM(NVL(PAB.QUANTITY_ITD_BASE,0))		BASE_QUANTITY_ITD,
   SUM(NVL(PAB.LABOR_QUANTITY_ITD_BASE,0))	BASE_LABOR_QUANTITY_ITD,
   SUM(NVL(PAB.RAW_COST_PTD_BASE,0))		BASE_RAW_COST_PTD,
   SUM(NVL(PAB.BURDENED_COST_PTD_BASE,0))	BASE_BURDENED_COST_PTD,
   SUM(NVL(PAB.REVENUE_PTD_BASE,0))		BASE_REVENUE_PTD,
   SUM(NVL(PAB.QUANTITY_PTD_BASE,0))		BASE_QUANTITY_PTD,
   SUM(NVL(PAB.LABOR_QUANTITY_PTD_BASE,0))	BASE_LABOR_QUANTITY_PTD,
   SUM(NVL(PAB.RAW_COST_PP_BASE,0))		BASE_RAW_COST_PP,
   SUM(NVL(PAB.BURDENED_COST_PP_BASE,0))	BASE_BURDENED_COST_PP,
   SUM(NVL(PAB.REVENUE_PP_BASE,0))		BASE_REVENUE_PP,
   SUM(NVL(PAB.QUANTITY_PP_BASE,0))		BASE_QUANTITY_PP,
   SUM(NVL(PAB.LABOR_QUANTITY_PP_BASE,0))	BASE_LABOR_QUANTITY_PP,
   SUM(NVL(PAB.RAW_COST_YTD_BASE,0))		BASE_RAW_COST_YTD,
   SUM(NVL(PAB.BURDENED_COST_YTD_BASE,0))	BASE_BURDENED_COST_YTD,
   SUM(NVL(PAB.REVENUE_YTD_BASE,0))		BASE_REVENUE_YTD,
   SUM(NVL(PAB.QUANTITY_YTD_BASE,0))		BASE_QUANTITY_YTD,
   SUM(NVL(PAB.LABOR_QUANTITY_YTD_BASE,0))	BASE_LABOR_QUANTITY_YTD,
   SUM(NVL(PAB.RAW_COST_ITD_ORIG,0))		ORIG_RAW_COST_ITD,
   SUM(NVL(PAB.BURDENED_COST_ITD_ORIG,0))	ORIG_BURDENED_COST_ITD,
   SUM(NVL(PAB.REVENUE_ITD_ORIG,0))		ORIG_REVENUE_ITD,
   SUM(NVL(PAB.QUANTITY_ITD_ORIG,0))		ORIG_QUANTITY_ITD,
   SUM(NVL(PAB.LABOR_QUANTITY_ITD_ORIG,0))	ORIG_LABOR_QUANTITY_ITD,
   SUM(NVL(PAB.RAW_COST_PTD_ORIG,0))		ORIG_RAW_COST_PTD,
   SUM(NVL(PAB.BURDENED_COST_PTD_ORIG,0))	ORIG_BURDENED_COST_PTD,
   SUM(NVL(PAB.REVENUE_PTD_ORIG,0))		ORIG_REVENUE_PTD,
   SUM(NVL(PAB.QUANTITY_PTD_ORIG,0))		ORIG_QUANTITY_PTD,
   SUM(NVL(PAB.LABOR_QUANTITY_PTD_ORIG,0))	ORIG_LABOR_QUANTITY_PTD,
   SUM(NVL(PAB.RAW_COST_PP_ORIG,0))		ORIG_RAW_COST_PP,
   SUM(NVL(PAB.BURDENED_COST_PP_ORIG,0))	ORIG_BURDENED_COST_PP,
   SUM(NVL(PAB.REVENUE_PP_ORIG,0))		ORIG_REVENUE_PP,
   SUM(NVL(PAB.QUANTITY_PP_ORIG,0))		ORIG_QUANTITY_PP,
   SUM(NVL(PAB.LABOR_QUANTITY_PP_ORIG,0))	ORIG_LABOR_QUANTITY_PP,
   SUM(NVL(PAB.RAW_COST_YTD_ORIG,0))		ORIG_RAW_COST_YTD,
   SUM(NVL(PAB.BURDENED_COST_YTD_ORIG,0))	ORIG_BURDENED_COST_YTD,
   SUM(NVL(PAB.REVENUE_YTD_ORIG,0))		ORIG_REVENUE_YTD,
   SUM(NVL(PAB.QUANTITY_YTD_ORIG,0))		ORIG_QUANTITY_YTD,
   SUM(NVL(PAB.LABOR_QUANTITY_YTD_ORIG,0))	ORIG_LABOR_QUANTITY_YTD,
   PAB.UNIT_OF_MEASURE_BASE BASE_UNIT_OF_MEASURE,
   PAB.UNIT_OF_MEASURE_ORIG ORIG_UNIT_OF_MEASURE,
   PAB.ROLLUP_QUANTITY_FLAG,
   PAB.RESOURCE_LIST_ASSIGNMENT_ID
FROM
 (
  SELECT
   BGT.PROJECT_ID,
   BGT.BUDGET_TYPE_CODE,
   BGT.fin_plan_type_id,
   BGT.TASK_ID,
   BGT.RESOURCE_LIST_MEMBER_ID,
   BGT.RESOURCE_LIST_ID,
   BGT.RESOURCE_ID,
   BGT.BASE_RAW_COST,
   BGT.BASE_BURDENED_COST,
   BGT.BASE_REVENUE,
   BGT.BASE_QUANTITY,
   BGT.BASE_LABOR_QUANTITY,
   BGT.ORIG_RAW_COST,
   BGT.ORIG_BURDENED_COST,
   BGT.ORIG_REVENUE,
   BGT.ORIG_QUANTITY,
   BGT.ORIG_LABOR_QUANTITY,
   BGT.RAW_COST_ITD_BASE,
   BGT.BURDENED_COST_ITD_BASE,
   BGT.REVENUE_ITD_BASE,
   BGT.QUANTITY_ITD_BASE,
   BGT.LABOR_QUANTITY_ITD_BASE,
   BGT.RAW_COST_PTD_BASE,
   BGT.BURDENED_COST_PTD_BASE,
   BGT.REVENUE_PTD_BASE,
   BGT.QUANTITY_PTD_BASE,
   BGT.LABOR_QUANTITY_PTD_BASE,
   BGT.RAW_COST_PP_BASE,
   BGT.BURDENED_COST_PP_BASE,
   BGT.REVENUE_PP_BASE,
   BGT.QUANTITY_PP_BASE,
   BGT.LABOR_QUANTITY_PP_BASE,
   BGT.RAW_COST_YTD_BASE,
   BGT.BURDENED_COST_YTD_BASE,
   BGT.REVENUE_YTD_BASE,
   BGT.QUANTITY_YTD_BASE,
   BGT.LABOR_QUANTITY_YTD_BASE,
   BGT.RAW_COST_ITD_ORIG,
   BGT.BURDENED_COST_ITD_ORIG,
   BGT.REVENUE_ITD_ORIG,
   BGT.QUANTITY_ITD_ORIG,
   BGT.LABOR_QUANTITY_ITD_ORIG,
   BGT.RAW_COST_PTD_ORIG,
   BGT.BURDENED_COST_PTD_ORIG,
   BGT.REVENUE_PTD_ORIG,
   BGT.QUANTITY_PTD_ORIG,
   BGT.LABOR_QUANTITY_PTD_ORIG,
   BGT.RAW_COST_PP_ORIG,
   BGT.BURDENED_COST_PP_ORIG,
   BGT.REVENUE_PP_ORIG,
   BGT.QUANTITY_PP_ORIG,
   BGT.LABOR_QUANTITY_PP_ORIG,
   BGT.RAW_COST_YTD_ORIG,
   BGT.BURDENED_COST_YTD_ORIG,
   BGT.REVENUE_YTD_ORIG,
   BGT.QUANTITY_YTD_ORIG,
   BGT.LABOR_QUANTITY_YTD_ORIG,
   BGT.UNIT_OF_MEASURE_BASE,
   BGT.UNIT_OF_MEASURE_ORIG,
   PAR.ROLLUP_QUANTITY_FLAG,
   PARLA.RESOURCE_LIST_ASSIGNMENT_ID
   FROM  PA_TODATE_BASE_ORIG_BUDGET_V BGT
          , PA_RESOURCES PAR
          , PA_RESOURCE_LIST_ASSIGNMENTS PARLA
   WHERE BGT.PROJECT_ID = x_project_id
    and BGT.RESOURCE_ACCUMULATED_FLAG = 'N'
    and BGT.RESOURCE_ID = PAR.RESOURCE_ID
    And PARLA.PROJECT_ID = x_project_id
    and PARLA.RESOURCE_LIST_ID = BGT.RESOURCE_LIST_ID
    and bgt.budget_type_code IS NOT NULL                 -- r11.5.7 Budget Model
    and bgt.budget_type_code = NVL(x_budget_type_code, bgt.budget_type_code)  -- Added by Sachin.
   UNION ALL
  SELECT
   BGT.PROJECT_ID,
   to_char(BGT.fin_plan_type_id)    BUDGET_TYPE_CODE,
   BGT.fin_plan_type_id,
   BGT.TASK_ID,
   BGT.RESOURCE_LIST_MEMBER_ID,
   BGT.RESOURCE_LIST_ID,
   BGT.RESOURCE_ID,
   BGT.BASE_RAW_COST,
   BGT.BASE_BURDENED_COST,
   BGT.BASE_REVENUE,
   BGT.BASE_QUANTITY,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_BASE,'HOURS',BGT.BASE_LABOR_QUANTITY,to_number(null)),to_number(null)),
                BGT.BASE_LABOR_QUANTITY)   BASE_LABOR_QUANTITY,
   BGT.ORIG_RAW_COST,
   BGT.ORIG_BURDENED_COST,
   BGT.ORIG_REVENUE,
   BGT.ORIG_QUANTITY,
    decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_ORIG,'HOURS',BGT.ORIG_LABOR_QUANTITY,to_number(null)),to_number(null)),
                BGT.ORIG_LABOR_QUANTITY)  ORIG_LABOR_QUANTITY,
   BGT.RAW_COST_ITD_BASE,
   BGT.BURDENED_COST_ITD_BASE,
   BGT.REVENUE_ITD_BASE,
   BGT.QUANTITY_ITD_BASE,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_BASE,'HOURS',BGT.LABOR_QUANTITY_ITD_BASE,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_ITD_BASE)  LABOR_QUANTITY_ITD_BASE,
   BGT.RAW_COST_PTD_BASE,
   BGT.BURDENED_COST_PTD_BASE,
   BGT.REVENUE_PTD_BASE,
   BGT.QUANTITY_PTD_BASE,
      decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_BASE,'HOURS',BGT.LABOR_QUANTITY_PTD_BASE,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_PTD_BASE)  LABOR_QUANTITY_PTD_BASE,
   BGT.RAW_COST_PP_BASE,
   BGT.BURDENED_COST_PP_BASE,
   BGT.REVENUE_PP_BASE,
   BGT.QUANTITY_PP_BASE,
       decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_BASE,'HOURS',BGT.LABOR_QUANTITY_PP_BASE,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_PP_BASE)  LABOR_QUANTITY_PP_BASE,
   BGT.RAW_COST_YTD_BASE,
   BGT.BURDENED_COST_YTD_BASE,
   BGT.REVENUE_YTD_BASE,
   BGT.QUANTITY_YTD_BASE,
        decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_BASE,'HOURS',BGT.LABOR_QUANTITY_YTD_BASE,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_YTD_BASE)  LABOR_QUANTITY_YTD_BASE,
   BGT.RAW_COST_ITD_ORIG,
   BGT.BURDENED_COST_ITD_ORIG,
   BGT.REVENUE_ITD_ORIG,
   BGT.QUANTITY_ITD_ORIG,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_ORIG,'HOURS',BGT.LABOR_QUANTITY_ITD_ORIG,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_ITD_ORIG)  LABOR_QUANTITY_ITD_ORIG,
   BGT.RAW_COST_PTD_ORIG,
   BGT.BURDENED_COST_PTD_ORIG,
   BGT.REVENUE_PTD_ORIG,
   BGT.QUANTITY_PTD_ORIG,
       decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_ORIG,'HOURS',BGT.LABOR_QUANTITY_PTD_ORIG,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_PTD_ORIG)  LABOR_QUANTITY_PTD_ORIG,
   BGT.RAW_COST_PP_ORIG,
   BGT.BURDENED_COST_PP_ORIG,
   BGT.REVENUE_PP_ORIG,
   BGT.QUANTITY_PP_ORIG,
      decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_ORIG,'HOURS',BGT.LABOR_QUANTITY_PP_ORIG,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_PP_ORIG)  LABOR_QUANTITY_PP_ORIG,
   BGT.RAW_COST_YTD_ORIG,
   BGT.BURDENED_COST_YTD_ORIG,
   BGT.REVENUE_YTD_ORIG,
   BGT.QUANTITY_YTD_ORIG,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_ORIG,'HOURS',BGT.LABOR_QUANTITY_YTD_ORIG,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_YTD_ORIG)  LABOR_QUANTITY_YTD_ORIG,
   BGT.UNIT_OF_MEASURE_BASE,
   BGT.UNIT_OF_MEASURE_ORIG,
   PAR.ROLLUP_QUANTITY_FLAG,
   PARLA.RESOURCE_LIST_ASSIGNMENT_ID
   FROM  PA_TODATE_BASE_ORIG_BUDGET_V BGT
          , PA_RESOURCES PAR
          , PA_RESOURCE_LIST_ASSIGNMENTS PARLA
   WHERE BGT.PROJECT_ID = x_project_id
    and BGT.RESOURCE_ACCUMULATED_FLAG = 'N'
    and BGT.RESOURCE_ID = PAR.RESOURCE_ID
    And PARLA.PROJECT_ID = x_project_id
    and PARLA.RESOURCE_LIST_ID = BGT.RESOURCE_LIST_ID
    and bgt.budget_type_code IS NULL                   -- FP Model Plan Type
    and x_budget_type_code is null                     -- Added by Sachin
   UNION ALL
  SELECT
   BGT.PROJECT_ID,
   'AC'    BUDGET_TYPE_CODE,
   BGT.fin_plan_type_id,
   BGT.TASK_ID,
   BGT.RESOURCE_LIST_MEMBER_ID,
   BGT.RESOURCE_LIST_ID,
   BGT.RESOURCE_ID,
   BGT.BASE_RAW_COST,
   BGT.BASE_BURDENED_COST,
   0   BASE_REVENUE,
   BGT.BASE_QUANTITY,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_BASE,'HOURS',BGT.BASE_LABOR_QUANTITY,to_number(null)),to_number(null)),
                BGT.BASE_LABOR_QUANTITY)   BASE_LABOR_QUANTITY,
   BGT.ORIG_RAW_COST,
   BGT.ORIG_BURDENED_COST,
   0   ORIG_REVENUE,
   BGT.ORIG_QUANTITY,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_ORIG,'HOURS',BGT.ORIG_LABOR_QUANTITY,to_number(null)),to_number(null)),
                BGT.ORIG_LABOR_QUANTITY)  ORIG_LABOR_QUANTITY,
   BGT.RAW_COST_ITD_BASE,
   BGT.BURDENED_COST_ITD_BASE,
   0   REVENUE_ITD_BASE,
   BGT.QUANTITY_ITD_BASE,
      decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_BASE,'HOURS',BGT.LABOR_QUANTITY_ITD_BASE,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_ITD_BASE)  LABOR_QUANTITY_ITD_BASE,
   BGT.RAW_COST_PTD_BASE,
   BGT.BURDENED_COST_PTD_BASE,
   0   REVENUE_PTD_BASE,
   BGT.QUANTITY_PTD_BASE,
      decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_BASE,'HOURS',BGT.LABOR_QUANTITY_PTD_BASE,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_PTD_BASE)  LABOR_QUANTITY_PTD_BASE,
   BGT.RAW_COST_PP_BASE,
   BGT.BURDENED_COST_PP_BASE,
   0   REVENUE_PP_BASE,
   BGT.QUANTITY_PP_BASE,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_BASE,'HOURS',BGT.LABOR_QUANTITY_PP_BASE,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_PP_BASE)  LABOR_QUANTITY_PP_BASE,
   BGT.RAW_COST_YTD_BASE,
   BGT.BURDENED_COST_YTD_BASE,
   0   REVENUE_YTD_BASE,
   BGT.QUANTITY_YTD_BASE,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_BASE,'HOURS',BGT.LABOR_QUANTITY_YTD_BASE,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_YTD_BASE)  LABOR_QUANTITY_YTD_BASE,
   BGT.RAW_COST_ITD_ORIG,
   BGT.BURDENED_COST_ITD_ORIG,
   0   REVENUE_ITD_ORIG,
   BGT.QUANTITY_ITD_ORIG,
      decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_ORIG,'HOURS',BGT.LABOR_QUANTITY_ITD_ORIG,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_ITD_ORIG)  LABOR_QUANTITY_ITD_ORIG,
   BGT.RAW_COST_PTD_ORIG,
   BGT.BURDENED_COST_PTD_ORIG,
   0   REVENUE_PTD_ORIG,
   BGT.QUANTITY_PTD_ORIG,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_ORIG,'HOURS',BGT.LABOR_QUANTITY_PTD_ORIG,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_PTD_ORIG)  LABOR_QUANTITY_PTD_ORIG,
   BGT.RAW_COST_PP_ORIG,
   BGT.BURDENED_COST_PP_ORIG,
   0   REVENUE_PP_ORIG,
   BGT.QUANTITY_PP_ORIG,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_ORIG,'HOURS',BGT.LABOR_QUANTITY_PP_ORIG,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_PP_ORIG)  LABOR_QUANTITY_PP_ORIG,
   BGT.RAW_COST_YTD_ORIG,
   BGT.BURDENED_COST_YTD_ORIG,
   0   REVENUE_YTD_ORIG,
   BGT.QUANTITY_YTD_ORIG,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_ORIG,'HOURS',BGT.LABOR_QUANTITY_YTD_ORIG,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_YTD_ORIG)  LABOR_QUANTITY_YTD_ORIG,
   BGT.UNIT_OF_MEASURE_BASE,
   BGT.UNIT_OF_MEASURE_ORIG,
   PAR.ROLLUP_QUANTITY_FLAG,
   PARLA.RESOURCE_LIST_ASSIGNMENT_ID
   FROM  PA_TODATE_BASE_ORIG_BUDGET_V BGT
          , PA_RESOURCES PAR
          , PA_RESOURCE_LIST_ASSIGNMENTS PARLA
   WHERE BGT.PROJECT_ID = x_project_id
    and BGT.RESOURCE_ACCUMULATED_FLAG = 'N'
    and BGT.RESOURCE_ID = PAR.RESOURCE_ID
    And PARLA.PROJECT_ID = x_project_id
    and PARLA.RESOURCE_LIST_ID = BGT.RESOURCE_LIST_ID
    and bgt.budget_type_code IS NULL                   -- FP Model PSI AC Record
    and nvl(bgt.approved_cost_plan_type_flag,'N') = 'Y'         -- -- APPROVED C-O-S-T
    and 'AC' = NVL(x_budget_type_code, 'AC')           -- Added by Sachin.
   UNION ALL
 SELECT
   BGT.PROJECT_ID,
   'AR'    BUDGET_TYPE_CODE,
   BGT.fin_plan_type_id,
   BGT.TASK_ID,
   BGT.RESOURCE_LIST_MEMBER_ID,
   BGT.RESOURCE_LIST_ID,
   BGT.RESOURCE_ID,
   0   BASE_RAW_COST,
   0   BASE_BURDENED_COST,
   BGT.BASE_REVENUE,
   BGT.BASE_QUANTITY,
      decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_BASE,'HOURS',BGT.BASE_LABOR_QUANTITY,to_number(null)),to_number(null)),
                BGT.BASE_LABOR_QUANTITY)   BASE_LABOR_QUANTITY,
   0   ORIG_RAW_COST,
   0   ORIG_BURDENED_COST,
   BGT.ORIG_REVENUE,
   BGT.ORIG_QUANTITY,
      decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_ORIG,'HOURS',BGT.ORIG_LABOR_QUANTITY,to_number(null)),to_number(null)),
                BGT.ORIG_LABOR_QUANTITY)  ORIG_LABOR_QUANTITY,
   0   RAW_COST_ITD_BASE,
   0   BURDENED_COST_ITD_BASE,
   BGT.REVENUE_ITD_BASE,
   BGT.QUANTITY_ITD_BASE,
      decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_BASE,'HOURS',BGT.LABOR_QUANTITY_ITD_BASE,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_ITD_BASE)  LABOR_QUANTITY_ITD_BASE,
   0   RAW_COST_PTD_BASE,
   0   BURDENED_COST_PTD_BASE,
   BGT.REVENUE_PTD_BASE,
   BGT.QUANTITY_PTD_BASE,
       decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_BASE,'HOURS',BGT.LABOR_QUANTITY_PTD_BASE,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_PTD_BASE)  LABOR_QUANTITY_PTD_BASE,
   0   RAW_COST_PP_BASE,
   0   BURDENED_COST_PP_BASE,
   BGT.REVENUE_PP_BASE,
   BGT.QUANTITY_PP_BASE,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_BASE,'HOURS',BGT.LABOR_QUANTITY_PP_BASE,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_PP_BASE)  LABOR_QUANTITY_PP_BASE,
   0   RAW_COST_YTD_BASE,
   0   BURDENED_COST_YTD_BASE,
   BGT.REVENUE_YTD_BASE,
   BGT.QUANTITY_YTD_BASE,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_BASE,'HOURS',BGT.LABOR_QUANTITY_YTD_BASE,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_YTD_BASE)  LABOR_QUANTITY_YTD_BASE,
   0   RAW_COST_ITD_ORIG,
   0   BURDENED_COST_ITD_ORIG,
   BGT.REVENUE_ITD_ORIG,
   BGT.QUANTITY_ITD_ORIG,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_ORIG,'HOURS',BGT.LABOR_QUANTITY_ITD_ORIG,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_ITD_ORIG)  LABOR_QUANTITY_ITD_ORIG,
   0   RAW_COST_PTD_ORIG,
   0   BURDENED_COST_PTD_ORIG,
   BGT.REVENUE_PTD_ORIG,
   BGT.QUANTITY_PTD_ORIG,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_ORIG,'HOURS',BGT.LABOR_QUANTITY_PTD_ORIG,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_PTD_ORIG)  LABOR_QUANTITY_PTD_ORIG,
   0   RAW_COST_PP_ORIG,
   0   BURDENED_COST_PP_ORIG,
   BGT.REVENUE_PP_ORIG,
   BGT.QUANTITY_PP_ORIG,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_ORIG,'HOURS',BGT.LABOR_QUANTITY_PP_ORIG,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_PP_ORIG)  LABOR_QUANTITY_PP_ORIG,
   0   RAW_COST_YTD_ORIG,
   0   BURDENED_COST_YTD_ORIG,
   BGT.REVENUE_YTD_ORIG,
   BGT.QUANTITY_YTD_ORIG,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_ORIG,'HOURS',BGT.LABOR_QUANTITY_YTD_ORIG,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_YTD_ORIG)  LABOR_QUANTITY_YTD_ORIG,
   BGT.UNIT_OF_MEASURE_BASE,
   BGT.UNIT_OF_MEASURE_ORIG,
   PAR.ROLLUP_QUANTITY_FLAG,
   PARLA.RESOURCE_LIST_ASSIGNMENT_ID
   FROM  PA_TODATE_BASE_ORIG_BUDGET_V BGT
          , PA_RESOURCES PAR
          , PA_RESOURCE_LIST_ASSIGNMENTS PARLA
   WHERE BGT.PROJECT_ID = x_project_id
    and BGT.RESOURCE_ACCUMULATED_FLAG = 'N'
    and BGT.RESOURCE_ID = PAR.RESOURCE_ID
    And PARLA.PROJECT_ID = x_project_id
    and PARLA.RESOURCE_LIST_ID = BGT.RESOURCE_LIST_ID
    and bgt.budget_type_code IS NULL                   -- FP Model PSI AR Record
    and nvl(bgt.approved_rev_plan_type_flag,'N') = 'Y'          -- -- APPROVED R-E-V-E-N-U-E
    and 'AR' = NVL(x_budget_type_code, 'AR')           -- Added by Sachin.
 UNION ALL
  SELECT
   BGT.PROJECT_ID,
   'FC'    BUDGET_TYPE_CODE,
   BGT.fin_plan_type_id,
   BGT.TASK_ID,
   BGT.RESOURCE_LIST_MEMBER_ID,
   BGT.RESOURCE_LIST_ID,
   BGT.RESOURCE_ID,
   BGT.BASE_RAW_COST,
   BGT.BASE_BURDENED_COST,
   0   BASE_REVENUE,
   BGT.BASE_QUANTITY,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_BASE,'HOURS',BGT.BASE_LABOR_QUANTITY,to_number(null)),to_number(null)),
                BGT.BASE_LABOR_QUANTITY)   BASE_LABOR_QUANTITY,
   BGT.ORIG_RAW_COST,
   BGT.ORIG_BURDENED_COST,
   0   ORIG_REVENUE,
   BGT.ORIG_QUANTITY,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_ORIG,'HOURS',BGT.ORIG_LABOR_QUANTITY,to_number(null)),to_number(null)),
                BGT.ORIG_LABOR_QUANTITY)  ORIG_LABOR_QUANTITY,
   BGT.RAW_COST_ITD_BASE,
   BGT.BURDENED_COST_ITD_BASE,
   0   REVENUE_ITD_BASE,
   BGT.QUANTITY_ITD_BASE,
      decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_BASE,'HOURS',BGT.LABOR_QUANTITY_ITD_BASE,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_ITD_BASE)  LABOR_QUANTITY_ITD_BASE,
   BGT.RAW_COST_PTD_BASE,
   BGT.BURDENED_COST_PTD_BASE,
   0   REVENUE_PTD_BASE,
   BGT.QUANTITY_PTD_BASE,
      decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_BASE,'HOURS',BGT.LABOR_QUANTITY_PTD_BASE,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_PTD_BASE)  LABOR_QUANTITY_PTD_BASE,
   BGT.RAW_COST_PP_BASE,
   BGT.BURDENED_COST_PP_BASE,
   0   REVENUE_PP_BASE,
   BGT.QUANTITY_PP_BASE,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_BASE,'HOURS',BGT.LABOR_QUANTITY_PP_BASE,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_PP_BASE)  LABOR_QUANTITY_PP_BASE,
   BGT.RAW_COST_YTD_BASE,
   BGT.BURDENED_COST_YTD_BASE,
   0   REVENUE_YTD_BASE,
   BGT.QUANTITY_YTD_BASE,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_BASE,'HOURS',BGT.LABOR_QUANTITY_YTD_BASE,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_YTD_BASE)  LABOR_QUANTITY_YTD_BASE,
   BGT.RAW_COST_ITD_ORIG,
   BGT.BURDENED_COST_ITD_ORIG,
   0   REVENUE_ITD_ORIG,
   BGT.QUANTITY_ITD_ORIG,
      decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_ORIG,'HOURS',BGT.LABOR_QUANTITY_ITD_ORIG,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_ITD_ORIG)  LABOR_QUANTITY_ITD_ORIG,
   BGT.RAW_COST_PTD_ORIG,
   BGT.BURDENED_COST_PTD_ORIG,
   0   REVENUE_PTD_ORIG,
   BGT.QUANTITY_PTD_ORIG,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_ORIG,'HOURS',BGT.LABOR_QUANTITY_PTD_ORIG,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_PTD_ORIG)  LABOR_QUANTITY_PTD_ORIG,
   BGT.RAW_COST_PP_ORIG,
   BGT.BURDENED_COST_PP_ORIG,
   0   REVENUE_PP_ORIG,
   BGT.QUANTITY_PP_ORIG,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_ORIG,'HOURS',BGT.LABOR_QUANTITY_PP_ORIG,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_PP_ORIG)  LABOR_QUANTITY_PP_ORIG,
   BGT.RAW_COST_YTD_ORIG,
   BGT.BURDENED_COST_YTD_ORIG,
   0   REVENUE_YTD_ORIG,
   BGT.QUANTITY_YTD_ORIG,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_ORIG,'HOURS',BGT.LABOR_QUANTITY_YTD_ORIG,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_YTD_ORIG)  LABOR_QUANTITY_YTD_ORIG,
   BGT.UNIT_OF_MEASURE_BASE,
   BGT.UNIT_OF_MEASURE_ORIG,
   PAR.ROLLUP_QUANTITY_FLAG,
   PARLA.RESOURCE_LIST_ASSIGNMENT_ID
   FROM  PA_TODATE_BASE_ORIG_BUDGET_V BGT
          , PA_RESOURCES PAR
          , PA_RESOURCE_LIST_ASSIGNMENTS PARLA
   WHERE BGT.PROJECT_ID = x_project_id
    and BGT.RESOURCE_ACCUMULATED_FLAG = 'N'
    and BGT.RESOURCE_ID = PAR.RESOURCE_ID
    And PARLA.PROJECT_ID = x_project_id
    and PARLA.RESOURCE_LIST_ID = BGT.RESOURCE_LIST_ID
    and bgt.budget_type_code IS NULL                   -- FP Model PSI FC Record
    and nvl(bgt.primary_cost_forecast_flag,'N') = 'Y'  -- -- PRIMARY FORECAST C-O-S-T
    and 'FC' = NVL(x_budget_type_code, 'FC')
UNION ALL
 SELECT
   BGT.PROJECT_ID,
   'FR'    BUDGET_TYPE_CODE,
   BGT.fin_plan_type_id,
   BGT.TASK_ID,
   BGT.RESOURCE_LIST_MEMBER_ID,
   BGT.RESOURCE_LIST_ID,
   BGT.RESOURCE_ID,
   0   BASE_RAW_COST,
   0   BASE_BURDENED_COST,
   BGT.BASE_REVENUE,
   BGT.BASE_QUANTITY,
      decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_BASE,'HOURS',BGT.BASE_LABOR_QUANTITY,to_number(null)),to_number(null)),
                BGT.BASE_LABOR_QUANTITY)   BASE_LABOR_QUANTITY,
   0   ORIG_RAW_COST,
   0   ORIG_BURDENED_COST,
   BGT.ORIG_REVENUE,
   BGT.ORIG_QUANTITY,
      decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_ORIG,'HOURS',BGT.ORIG_LABOR_QUANTITY,to_number(null)),to_number(null)),
                BGT.ORIG_LABOR_QUANTITY)  ORIG_LABOR_QUANTITY,
   0   RAW_COST_ITD_BASE,
   0   BURDENED_COST_ITD_BASE,
   BGT.REVENUE_ITD_BASE,
   BGT.QUANTITY_ITD_BASE,
      decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_BASE,'HOURS',BGT.LABOR_QUANTITY_ITD_BASE,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_ITD_BASE)  LABOR_QUANTITY_ITD_BASE,
   0   RAW_COST_PTD_BASE,
   0   BURDENED_COST_PTD_BASE,
   BGT.REVENUE_PTD_BASE,
   BGT.QUANTITY_PTD_BASE,
       decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_BASE,'HOURS',BGT.LABOR_QUANTITY_PTD_BASE,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_PTD_BASE)  LABOR_QUANTITY_PTD_BASE,
   0   RAW_COST_PP_BASE,
   0   BURDENED_COST_PP_BASE,
   BGT.REVENUE_PP_BASE,
   BGT.QUANTITY_PP_BASE,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_BASE,'HOURS',BGT.LABOR_QUANTITY_PP_BASE,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_PP_BASE)  LABOR_QUANTITY_PP_BASE,
   0   RAW_COST_YTD_BASE,
   0   BURDENED_COST_YTD_BASE,
   BGT.REVENUE_YTD_BASE,
   BGT.QUANTITY_YTD_BASE,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_BASE,'HOURS',BGT.LABOR_QUANTITY_YTD_BASE,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_YTD_BASE)  LABOR_QUANTITY_YTD_BASE,
   0   RAW_COST_ITD_ORIG,
   0   BURDENED_COST_ITD_ORIG,
   BGT.REVENUE_ITD_ORIG,
   BGT.QUANTITY_ITD_ORIG,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_ORIG,'HOURS',BGT.LABOR_QUANTITY_ITD_ORIG,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_ITD_ORIG)  LABOR_QUANTITY_ITD_ORIG,
   0   RAW_COST_PTD_ORIG,
   0   BURDENED_COST_PTD_ORIG,
   BGT.REVENUE_PTD_ORIG,
   BGT.QUANTITY_PTD_ORIG,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_ORIG,'HOURS',BGT.LABOR_QUANTITY_PTD_ORIG,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_PTD_ORIG)  LABOR_QUANTITY_PTD_ORIG,
   0   RAW_COST_PP_ORIG,
   0   BURDENED_COST_PP_ORIG,
   BGT.REVENUE_PP_ORIG,
   BGT.QUANTITY_PP_ORIG,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_ORIG,'HOURS',BGT.LABOR_QUANTITY_PP_ORIG,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_PP_ORIG)  LABOR_QUANTITY_PP_ORIG,
   0   RAW_COST_YTD_ORIG,
   0   BURDENED_COST_YTD_ORIG,
   BGT.REVENUE_YTD_ORIG,
   BGT.QUANTITY_YTD_ORIG,
     decode(bgt.track_as_labor_flag, NULL,decode(bgt.resource_class_code, 'PEOPLE',
            decode(BGT.UNIT_OF_MEASURE_ORIG,'HOURS',BGT.LABOR_QUANTITY_YTD_ORIG,to_number(null)),to_number(null)),
                BGT.LABOR_QUANTITY_YTD_ORIG)  LABOR_QUANTITY_YTD_ORIG,
   BGT.UNIT_OF_MEASURE_BASE,
   BGT.UNIT_OF_MEASURE_ORIG,
   PAR.ROLLUP_QUANTITY_FLAG,
   PARLA.RESOURCE_LIST_ASSIGNMENT_ID
   FROM  PA_TODATE_BASE_ORIG_BUDGET_V BGT
          , PA_RESOURCES PAR
          , PA_RESOURCE_LIST_ASSIGNMENTS PARLA
   WHERE BGT.PROJECT_ID = x_project_id
    and BGT.RESOURCE_ACCUMULATED_FLAG = 'N'
    and BGT.RESOURCE_ID = PAR.RESOURCE_ID
    And PARLA.PROJECT_ID = x_project_id
    and PARLA.RESOURCE_LIST_ID = BGT.RESOURCE_LIST_ID
    and bgt.budget_type_code IS NULL                   -- FP Model PSI FR Record
    and nvl(bgt.primary_rev_forecast_flag,'N') = 'Y'   -- -- PRIMARY FORECAST R-E-V-E-N-U-E
    and 'FR' = NVL(x_budget_type_code, 'FR')
 ) PAB
GROUP BY
   PAB.PROJECT_ID,
   PAB.BUDGET_TYPE_CODE,
   PAB.fin_plan_type_id,
   PAB.TASK_ID,
   PAB.RESOURCE_LIST_MEMBER_ID,
   PAB.RESOURCE_LIST_ID,
   PAB.RESOURCE_ID,
   PAB.UNIT_OF_MEASURE_BASE,
   PAB.UNIT_OF_MEASURE_ORIG,
   PAB.ROLLUP_QUANTITY_FLAG,
   PAB.RESOURCE_LIST_ASSIGNMENT_ID;

CURSOR PA_Budget_versions_cur
IS
SELECT Distinct
       Budget_Type_Code,
       Budget_Version_id
FROM
  (
      SELECT  Budget_Type_Code
              , Budget_Version_id
      FROM  PA_BUDGET_VERSIONS
      Where Project_Id = x_project_id
      And   Current_Flag = 'Y'
      and   budget_type_code IS NOT NULL                -- r11.5.7 Budgets Model
      UNION ALL
      SELECT  to_char(fin_plan_type_id)  Budget_Type_Code
              , Budget_Version_id
      FROM  PA_BUDGET_VERSIONS
      Where Project_Id = x_project_id
      And   Current_Flag = 'Y'
      and   budget_type_code IS NULL                 -- FP Model Plan Type, #3561255, changed to 'IS NULL'
      UNION ALL
      SELECT  'AC'   Budget_Type_Code
              , Budget_Version_id
      FROM  PA_BUDGET_VERSIONS
      Where Project_Id = x_project_id
      And   Current_Flag = 'Y'
      and   budget_type_code IS NULL                 -- FP Model PSI AC Record, #3561255, changed to 'IS NULL'
      and   nvl(approved_cost_plan_type_flag,'N') = 'Y'           -- -- APPROVED C-O-S-T
      UNION ALL
      SELECT  'AR'  Budget_Type_Code
              , Budget_Version_id
      FROM  PA_BUDGET_VERSIONS
      Where Project_Id = x_project_id
      And   Current_Flag = 'Y'
      and   budget_type_code IS NULL                 -- FP Model PSI AC Record,  #3561255, changed to 'IS NULL'
      and   nvl(approved_rev_plan_type_flag,'N') = 'Y'            -- -- APPROVED R-E-V-E-N-U-E
      UNION ALL
      SELECT  'FC'   Budget_Type_Code
              , Budget_Version_id
      FROM  PA_BUDGET_VERSIONS
      Where Project_Id = x_project_id
      And   Current_Flag = 'Y'
      and   budget_type_code IS NULL                 -- FP Model PSI FC Record
      and   nvl(primary_cost_forecast_flag,'N') = 'Y'           -- -- PRIMARY FORECAST C-O-S-T
      UNION ALL
      SELECT  'FR'  Budget_Type_Code
              , Budget_Version_id
      FROM  PA_BUDGET_VERSIONS
      Where Project_Id = x_project_id
      And   Current_Flag = 'Y'
      and   budget_type_code IS NULL                 -- FP Model PSI AC Record
      and   nvl(primary_rev_forecast_flag,'N') = 'Y'            -- -- PRIMARY FORECAST R-E-V-E-N-U-E
   );


  PA_budget_versions_Rec  PA_Budget_versions_cur%ROWTYPE;
  tot_recs_processed  	  Number := 0;
  x_Budget_rec  	  PA_Budget_Cur%ROWTYPE;
  x_recs_processed 	  Number := 0;

  curr_budget_type_code         Varchar2(30);
  curr_fin_plan_type_id         Number(15);
  curr_task_id                  Number(15);
  curr_rlmid                    Number(15);
  curr_rlid                     Number(15);
  curr_rid                      Number(15);
  curr_rlaid                    Number(15);
  curr_rlup_qty_flag            varchar2(1);
  curr_buom                     varchar2(30);
  curr_ouom                     varchar2(30);

  fetch_rec                     Boolean := true;
  first_rec                     Boolean := true;
  get_wbs                       Boolean := true;

  V_Base_Burdened_Cost_Flag	Varchar2(1) := 'N';
  V_Base_Labor_Hours_Flag	Varchar2(1) := 'N';
  V_Base_Raw_Cost_Flag		Varchar2(1) := 'N';
  V_Base_Revenue_Flag		Varchar2(1) := 'N';
  V_Orig_Burdened_Cost_Flag	Varchar2(1) := 'N';
  V_Orig_Labor_Hours_Flag	Varchar2(1) := 'N';
  V_Orig_Quantity_Flag		Varchar2(1) := 'N';
  V_Base_Quantity_Flag		Varchar2(1) := 'N';
  V_Orig_Raw_Cost_Flag		Varchar2(1) := 'N';
  V_Orig_Revenue_Flag		Varchar2(1) := 'N';
  V_task_array                  task_id_tabtype;
  v_noof_tasks                  Number := 0;
  v_err_stage			Varchar2(80);
  v_err_stack			Varchar2(630);
  V_Old_Stack			Varchar2(630);

Begin
      -- The Get_config_Option is called for various columns in the Budget
      -- table, to ensure that they have been configured for accumulation.
      -- If any column is not configured , then the column would not be
      -- accumulated (the amount would be 0s in those cases )

      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_MAINT_PROJECT_BUDGETS.Process_Budget_Txns';

      pa_debug.debug(x_err_stack);

      PA_ACCUM_UTILS.Get_config_Option
                             (X_project_id ,
                              'BUDGETS',
                              'BASE_BURDENED_COST',
                              V_Base_Burdened_Cost_Flag,
                              x_err_code ,
                              x_err_stage ,
                              x_err_stack );

      PA_ACCUM_UTILS.Get_config_Option
                             (X_project_id ,
                              'BUDGETS',
                              'BASE_LABOR_HOURS',
                              V_Base_Labor_Hours_Flag,
                              x_err_code ,
                              x_err_stage ,
                              x_err_stack );

      PA_ACCUM_UTILS.Get_config_Option
                             (X_project_id ,
                              'BUDGETS',
                              'BASE_RAW_COST',
                              V_Base_Raw_Cost_Flag,
                              x_err_code ,
                              x_err_stage ,
                              x_err_stack );

      PA_ACCUM_UTILS.Get_config_Option
                             (X_project_id ,
                              'BUDGETS',
                              'BASE_REVENUE',
                              V_Base_Revenue_Flag,
                              x_err_code ,
                              x_err_stage ,
                              x_err_stack );

      PA_ACCUM_UTILS.Get_config_Option
                             (X_project_id ,
                              'BUDGETS',
                              'ORIG_BURDENED_COST',
                              V_Orig_Burdened_Cost_Flag,
                              x_err_code ,
                              x_err_stage ,
                              x_err_stack );

      PA_ACCUM_UTILS.Get_config_Option
                             (X_project_id ,
                              'BUDGETS',
                              'ORIG_LABOR_HOURS',
                              V_Orig_Labor_Hours_Flag,
                              x_err_code ,
                              x_err_stage ,
                              x_err_stack );

      PA_ACCUM_UTILS.Get_config_Option
                             (X_project_id ,
                              'BUDGETS',
                              'ORIG_QUANTITY',
                              V_Orig_Quantity_Flag,
                              x_err_code ,
                              x_err_stage ,
                              x_err_stack );

      PA_ACCUM_UTILS.Get_config_Option
                             (X_project_id ,
                              'BUDGETS',
                              'BASE_QUANTITY',
                              V_Base_Quantity_Flag,
                              x_err_code ,
                              x_err_stage ,
                              x_err_stack );

      PA_ACCUM_UTILS.Get_config_Option
                             (X_project_id ,
                              'BUDGETS',
                              'ORIG_RAW_COST',
                              V_Orig_Raw_Cost_Flag,
                              x_err_code ,
                              x_err_stage ,
                              x_err_stack );

      PA_ACCUM_UTILS.Get_config_Option
                             (X_project_id ,
                              'BUDGETS',
                              'ORIG_REVENUE',
                              V_Orig_Revenue_Flag,
                              x_err_code ,
                              x_err_stage ,
                              x_err_stack );
      -- Read all relevant Budget records in a loop

--      For x_Budget_rec in PA_Budget_Cur LOOP

      -- Based on the Configuration option, set the value either as 0
      -- or retain the fetched value
   initialize_res_level;
   initialize_task_level;
   initialize_project_level;
   first_rec := true;

   open pa_budget_cur;
   Loop
       If fetch_rec = true then
          fetch pa_budget_cur into x_budget_rec;
       end if;
       fetch_rec := true;

     If first_rec = true or (x_budget_rec.budget_type_code = curr_budget_type_code AND
        x_budget_rec.task_id = curr_task_id AND
        x_budget_rec.resource_list_member_id = curr_rlmid AND
        pa_budget_cur%found) THEN

      first_rec := false;
      If  V_Base_Burdened_Cost_Flag = 'Y' Then
          V_Base_Burdened_Cost_ptd := V_Base_Burdened_Cost_ptd +
                                      x_Budget_rec.Base_Burdened_Cost_ptd;
          V_Base_Burdened_Cost_itd := V_Base_Burdened_Cost_itd +
                                      x_Budget_rec.Base_Burdened_Cost_itd;
          V_Base_Burdened_Cost_pp  := V_Base_Burdened_Cost_pp +
                                      x_Budget_rec.Base_Burdened_Cost_pp ;
          V_Base_Burdened_Cost_ytd := V_Base_Burdened_Cost_ytd +
                                      x_Budget_rec.Base_Burdened_Cost_ytd;
      End If;
      TOT_BASE_BURDENED_COST := TOT_BASE_BURDENED_COST +
                                x_budget_rec.base_burdened_cost;
      If  V_Base_Labor_Hours_Flag = 'Y' Then
          V_Base_Labor_Hours_ptd := V_Base_Labor_Hours_ptd +
                                    x_Budget_rec.Base_Labor_Quantity_ptd;
          V_Base_Labor_Hours_itd := V_Base_Labor_Hours_itd +
                                    x_Budget_rec.Base_Labor_Quantity_itd;
          V_Base_Labor_Hours_pp  := V_Base_Labor_Hours_pp +
                                    x_Budget_rec.Base_Labor_Quantity_pp ;
          V_Base_Labor_Hours_ytd := V_Base_Labor_Hours_ytd +
                                    x_Budget_rec.Base_Labor_Quantity_ytd;
      End If;
      TOT_BASE_LABOR_HOURS := TOT_BASE_LABOR_HOURS +
                              x_budget_rec.base_labor_quantity;
      If  V_Base_Raw_Cost_Flag = 'Y' Then
          V_Base_Raw_Cost_ptd := V_Base_Raw_Cost_ptd +
                                 x_Budget_rec.Base_Raw_Cost_ptd;
          V_Base_Raw_Cost_itd := V_Base_Raw_Cost_itd +
                                 x_Budget_rec.Base_Raw_Cost_itd;
          V_Base_Raw_Cost_pp  := V_Base_Raw_Cost_pp +
                                 x_Budget_rec.Base_Raw_Cost_pp ;
          V_Base_Raw_Cost_ytd := V_Base_Raw_Cost_ytd +
                                 x_Budget_rec.Base_Raw_Cost_ytd;
      End If;
      TOT_BASE_RAW_COST := TOT_BASE_RAW_COST +
                           x_budget_rec.base_raw_cost;
      If  V_Base_Revenue_Flag = 'Y' Then
          V_Base_Revenue_ptd := V_Base_Revenue_ptd +
                                x_Budget_rec.Base_Revenue_ptd;
          V_Base_Revenue_itd := V_Base_Revenue_itd +
                                x_Budget_rec.Base_Revenue_itd;
          V_Base_Revenue_pp  := V_Base_Revenue_pp +
                                x_Budget_rec.Base_Revenue_pp ;
          V_Base_Revenue_ytd := V_Base_Revenue_ytd +
                                x_Budget_rec.Base_Revenue_ytd;
      End If;
      TOT_BASE_REVENUE := TOT_BASE_REVENUE +
                          x_budget_rec.base_revenue;
      If  V_Orig_Burdened_Cost_Flag = 'Y' Then
          V_Orig_Burdened_Cost_ptd := V_Orig_Burdened_Cost_ptd +
                                      x_Budget_rec.Orig_Burdened_Cost_ptd;
          V_Orig_Burdened_Cost_itd := V_Orig_Burdened_Cost_itd +
                                      x_Budget_rec.Orig_Burdened_Cost_itd;
          V_Orig_Burdened_Cost_pp  := V_Orig_Burdened_Cost_pp +
                                      x_Budget_rec.Orig_Burdened_Cost_pp ;
          V_Orig_Burdened_Cost_ytd := V_Orig_Burdened_Cost_ytd +
                                      x_Budget_rec.Orig_Burdened_Cost_ytd;
      End If;
      TOT_ORIG_BURDENED_COST := TOT_ORIG_BURDENED_COST +
                                x_budget_rec.orig_burdened_cost;
      If  V_Orig_Labor_Hours_Flag  = 'Y' Then
          V_Orig_Labor_Hours_ptd := V_Orig_Labor_Hours_ptd +
                                    x_Budget_rec.Orig_Labor_Quantity_ptd;
          V_Orig_Labor_Hours_itd := V_Orig_Labor_Hours_itd +
                                    x_Budget_rec.Orig_Labor_Quantity_itd;
          V_Orig_Labor_Hours_pp  := V_Orig_Labor_Hours_pp +
                                    x_Budget_rec.Orig_Labor_Quantity_pp ;
          V_Orig_Labor_Hours_ytd := V_Orig_Labor_Hours_ytd +
                                    x_Budget_rec.Orig_Labor_Quantity_ytd;
      End If;
      TOT_ORIG_LABOR_HOURS := TOT_ORIG_LABOR_HOURS +
                              x_budget_rec.orig_labor_quantity;
      If  V_Orig_Quantity_Flag  = 'Y' and x_budget_rec.rollup_quantity_flag = 'Y' Then
          V_Orig_Quantity_ptd := V_Orig_Quantity_ptd +
                                 x_Budget_rec.Orig_Quantity_ptd;
          V_Orig_Quantity_itd := V_Orig_Quantity_itd +
                                 x_Budget_rec.Orig_Quantity_itd;
          V_Orig_Quantity_pp  := V_Orig_Quantity_pp +
                                 x_Budget_rec.Orig_Quantity_pp ;
          V_Orig_Quantity_ytd := V_Orig_Quantity_ytd +
                                 x_Budget_rec.Orig_Quantity_ytd;
      TOT_ORIG_QUANTITY := TOT_ORIG_QUANTITY +
                           x_budget_rec.orig_quantity;
      End If;
      If  V_Base_Quantity_Flag  = 'Y' and x_budget_rec.rollup_quantity_flag = 'Y' Then
          V_Base_Quantity_ptd := V_Base_Quantity_ptd +
                                 x_Budget_rec.Base_Quantity_ptd;
          V_Base_Quantity_itd := V_Base_Quantity_itd +
                                 x_Budget_rec.Base_Quantity_itd;
          V_Base_Quantity_pp  := V_Base_Quantity_pp +
                                 x_Budget_rec.Base_Quantity_pp ;
          V_Base_Quantity_ytd := V_Base_Quantity_ytd +
                                 x_Budget_rec.Base_Quantity_ytd;
      TOT_BASE_QUANTITY := TOT_BASE_QUANTITY +
                           x_budget_rec.base_quantity;
      End If;
      If  V_Orig_Raw_Cost_Flag = 'Y' Then
          V_Orig_Raw_Cost_ptd := V_Orig_Raw_Cost_ptd +
                                 x_Budget_rec.Orig_Raw_Cost_ptd;
          V_Orig_Raw_Cost_itd := V_Orig_Raw_Cost_itd +
                                 x_Budget_rec.Orig_Raw_Cost_itd;
          V_Orig_Raw_Cost_pp  := V_Orig_Raw_Cost_pp +
                                 x_Budget_rec.Orig_Raw_Cost_pp ;
          V_Orig_Raw_Cost_ytd := V_Orig_Raw_Cost_ytd +
                                 x_Budget_rec.Orig_Raw_Cost_ytd;
      End If;
      TOT_ORIG_RAW_COST := TOT_ORIG_RAW_COST +
                           x_budget_rec.orig_raw_cost;
      If  V_Orig_Revenue_Flag = 'Y' Then
          V_Orig_Revenue_ptd := V_Orig_Revenue_ptd +
                                x_Budget_rec.Orig_Revenue_ptd;
          V_Orig_Revenue_itd := V_Orig_Revenue_itd +
                                x_Budget_rec.Orig_Revenue_itd;
          V_Orig_Revenue_pp  := V_Orig_Revenue_pp +
                                x_Budget_rec.Orig_Revenue_pp ;
          V_Orig_Revenue_ytd := V_Orig_Revenue_ytd +
                                x_Budget_rec.Orig_Revenue_ytd;
      End If;
      TOT_ORIG_REVENUE := TOT_ORIG_REVENUE +
                          x_budget_rec.orig_revenue;

    else
           If curr_task_id = 0 then
                add_project_amounts;
           -- create P,B,0,R
                Process_all_buds
		      (x_project_id,
                       x_current_period,
                       curr_task_id,
                       curr_rlid,
                       curr_rlmid,
                       curr_rid,
                       curr_rlaid,
                       curr_rlup_qty_flag,
                       curr_budget_type_code,
                       curr_fin_plan_type_id,
                       curr_buom,
                       curr_ouom,
                       X_Recs_processed,
                       x_err_stack,
                       x_err_stage,
                       x_err_code);
                if x_budget_rec.task_id <> curr_task_id then
                    Get_all_higher_tasks_bud
	         		(x_project_id ,
                                 x_budget_rec.task_id ,
			         0,             -- resource_list_member_id
                                 v_task_array,
                                 v_noof_tasks,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code);
                end if;
              if x_budget_rec.budget_type_code <> curr_budget_type_code
                OR pa_budget_cur%notfound then
                  Process_bud_code
                      (x_project_id,
                       x_current_period,
                       0,
                       0,
                       0,
                       0,
                       0,
                       curr_rlup_qty_flag,
                       curr_budget_type_code,
                       curr_fin_plan_type_id,
                       curr_buom,
                       curr_ouom,
                       X_Recs_processed,
                       x_err_stack,
                       x_err_stage,
                       x_err_code);

                    COMMIT;

                    initialize_project_level;
             end if;
           else
                add_project_amounts;
                add_task_amounts;
                if get_wbs = true then
                    Get_all_higher_tasks_bud
                                (x_project_id ,
                                 curr_task_id ,
                                 0,             -- resource_list_member_id
                                 v_task_array,
                                 v_noof_tasks,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code);
                     get_wbs := false;
                end if;

                for i in 1..v_noof_tasks loop
                  -- create P,B,T,R
                Process_all_buds
		      (x_project_id,
                       x_current_period,
                       v_task_array(i),
                       curr_rlid,
                       curr_rlmid,
                       curr_rid,
                       curr_rlaid,
                       curr_rlup_qty_flag,
                       curr_budget_type_code,
                       curr_fin_plan_type_id,
                       curr_buom,
                       curr_ouom,
                       X_Recs_processed,
                       x_err_stack,
                       x_err_stage,
                       x_err_code);
                end loop;
                     -- create P,B,0,R
                  Process_all_buds
                      (x_project_id,
                       x_current_period,
                       0,
                       curr_rlid,
                       curr_rlmid,
                       curr_rid,
                       curr_rlaid,
                       curr_rlup_qty_flag,
                       curr_budget_type_code,
                       curr_fin_plan_type_id,
                       curr_buom,
                       curr_ouom,
                       X_Recs_processed,
                       x_err_stack,
                       x_err_stage,
                       x_err_code);
                  -- create P,B,T,0
                if x_budget_rec.task_id <> curr_task_id or
                   x_budget_rec.budget_type_code <> curr_budget_type_code or
                   pa_budget_cur%notfound then
                for i in 1..v_noof_tasks loop
                 Process_all_tasks
		      (x_project_id,
                       x_current_period,
                       v_task_array(i),
                       0,
                       0,
                       0,
                       0,
                       curr_rlup_qty_flag,
                       curr_budget_type_code,
                       curr_fin_plan_type_id,
                       curr_buom,
                       curr_ouom,
                       X_Recs_processed,
                       x_err_stack,
                       x_err_stage,
                       x_err_code);
                end loop;
                    Get_all_higher_tasks_bud
	         		(x_project_id ,
                                 x_budget_rec.task_id ,
			         0,             -- resource_list_member_id
                                 v_task_array,
                                 v_noof_tasks,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code);
                initialize_task_level;
                end if;
             if x_budget_rec.budget_type_code <> curr_budget_type_code
                OR pa_budget_cur%notfound then
                  Process_bud_code
                      (x_project_id,
                       x_current_period,
                       0,
                       0,
                       0,
                       0,
                       0,
                       curr_rlup_qty_flag,
                       curr_budget_type_code,
                       curr_fin_plan_type_id,
                       curr_buom,
                       curr_ouom,
                       X_Recs_processed,
                       x_err_stack,
                       x_err_stage,
                       x_err_code);
                    initialize_project_level;

                   COMMIT;
             end if;
         end if;
           initialize_res_level;
           fetch_rec := false;
     end if;

     exit when pa_budget_cur%notfound;

     curr_task_id := x_budget_rec.task_id;
     curr_budget_type_code := x_budget_rec.budget_type_code;
     curr_fin_plan_type_id := x_budget_rec.fin_plan_type_id;
     curr_rlmid := x_budget_rec.resource_list_member_id;
     curr_rlid :=  x_budget_rec.resource_list_id;
     curr_rid :=  x_budget_rec.resource_id;
     curr_rlaid := x_budget_rec.resource_list_assignment_id;
     curr_rlup_qty_flag := x_budget_rec.rollup_quantity_flag;
     curr_buom := X_budget_rec.Base_Unit_Of_Measure;
     curr_ouom := X_budget_rec.Orig_Unit_Of_Measure;

   end loop;
  close pa_budget_cur;
      -- If Budget_type is given as input, process only that budget type
      -- Else process all budget types.

-- After processing all budget records, mark the budget versions as accumulated

         For PA_budget_versions_Rec  In PA_Budget_versions_cur LOOP
           If nvl(x_Budget_Type_code,PA_budget_versions_Rec.BUDGET_TYPE_CODE)
              = PA_budget_versions_Rec.BUDGET_TYPE_CODE  Then
              Update PA_BUDGET_VERSIONS SET
                RESOURCE_ACCUMULATED_FLAG = 'Y' WHERE
                BUDGET_VERSION_ID = PA_budget_versions_Rec.BUDGET_VERSION_ID;
           End If;
        END LOOP;
        COMMIT;
--      Restore the old x_err_stack;

        x_err_stack := V_Old_Stack;

Exception
  When Others Then
    x_err_code := SQLCODE;
    RAISE;

END Process_Budget_Txns;

Procedure Process_Budget_Tot   (X_project_id in Number,
                                x_Proj_accum_id   in Number,
                                x_Budget_Type_code in Varchar2,
                                x_current_period in Varchar2,
                                x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

-- This procedure is not being used at all.(Ignore call to PA_BUDGET_BY_RESOURCE_V)

CURSOR PA_Budget_Cur IS
SELECT
       PAB.TASK_ID,
       PAB.BUDGET_TYPE_CODE,
       PAB.RESOURCE_LIST_MEMBER_ID,
       PAB.RESOURCE_LIST_ID,PAB.RESOURCE_ID,
       NVL(PAB.BASE_RAW_COST,0) BASE_RAW_COST,
       NVL(PAB.BASE_BURDENED_COST,0) BASE_BURDENED_COST,
       NVL(PAB.BASE_REVENUE,0) BASE_REVENUE,
       NVL(PAB.BASE_QUANTITY,0) BASE_QUANTITY,
       NVL(PAB.BASE_LABOR_QUANTITY,0) BASE_LABOR_QUANTITY,
       NVL(PAB.ORIG_RAW_COST,0) ORIG_RAW_COST,
       NVL(PAB.ORIG_BURDENED_COST,0) ORIG_BURDENED_COST,
       NVL(PAB.ORIG_REVENUE,0) ORIG_REVENUE,
       NVL(PAB.ORIG_QUANTITY,0) ORIG_QUANTITY,
       NVL(PAB.ORIG_LABOR_QUANTITY,0) ORIG_LABOR_QUANTITY,
       PAR.ROLLUP_QUANTITY_FLAG,
       PARLA.RESOURCE_LIST_ASSIGNMENT_ID
FROM
       PA_BUDGET_BY_RESOURCE_V PAB,
       PA_RESOURCES PAR,
       PA_RESOURCE_LIST_ASSIGNMENTS PARLA
WHERE  PAB.PROJECT_ID = x_project_id
AND    PAB.RESOURCE_ACCUMULATED_FLAG = 'N'
AND    PAB.RESOURCE_ID = PAR.RESOURCE_ID
And PARLA.PROJECT_ID = x_project_id
and PARLA.RESOURCE_LIST_ID = PAB.RESOURCE_LIST_ID;

x_Budget_rec  PA_Budget_Cur%ROWTYPE;
tot_recs_processed  Number := 0;
x_recs_processed Number := 0;
v_err_code Number := 0;
v_orig_qty Number := 0;
v_Base_qty Number := 0;
V_Old_Stack       Varchar2(630);
Begin

         V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_MAINT_PROJECT_BUDGETS.Process_Budget_Tot';
      pa_debug.debug(x_err_stack);

         For x_Budget_rec in PA_Budget_Cur LOOP

-- If Budget_type is given as input, process only that budget type
-- Else process all budget types.

         IF Nvl(x_budget_type_code,x_Budget_rec.BUDGET_TYPE_CODE) =
                x_Budget_rec.Budget_type_code Then
-- If the Rollup_Quantity_flag of the Resource is 'Y' then Roll up
-- Quantity amounts

      -- Create task/resource and combination records for WBS

      create_accum_budgets
                         (x_project_id,
                          x_budget_rec.task_id,
                          x_budget_rec.budget_type_code,
                          x_current_period,
                          x_Recs_processed,
                          x_err_stack,
                          x_err_stage,
                          x_err_code);

      create_accum_budgets_res
                         (x_project_id,
                          x_budget_rec.task_id,
                          x_budget_rec.resource_list_id,
                          x_budget_rec.resource_list_Member_id,
                          x_budget_rec.resource_id,
                          x_budget_rec.resource_list_assignment_id,
                          x_budget_rec.budget_type_code,
                          x_current_period,
                          X_Recs_processed,
                          x_err_stack,
                          x_err_stage,
                          x_err_code);

              IF x_Budget_rec.ROLLUP_QUANTITY_FLAG = 'Y' Then
                 v_Orig_Qty := x_Budget_rec.ORIG_QUANTITY;
                 v_Base_Qty := x_Budget_rec.BASE_QUANTITY;
              ELSE
                 v_Orig_Qty := 0;
                 v_Base_Qty := 0;
              END IF;
-- The following Update statement will update all the following records

-- Project level record
-- Project and fetched Task and all upper tasks in the hierarchy without
-- resource
-- Project and fetched task and all upper tasks with the fetched resource
-- Project and fetched resource

              Update PA_PROJECT_ACCUM_BUDGETS PAB SET
                BASE_RAW_COST_TOT      = NVL(BASE_RAW_COST_TOT,0 ) +
					 x_budget_rec.BASE_RAW_COST,
                BASE_BURDENED_COST_TOT = NVL(BASE_BURDENED_COST_TOT,0) +
					 x_budget_rec.BASE_BURDENED_COST,
                ORIG_RAW_COST_TOT      = NVL(ORIG_RAW_COST_TOT,0) +
					 x_budget_rec.ORIG_RAW_COST,
                ORIG_BURDENED_COST_TOT = NVL(ORIG_BURDENED_COST_TOT,0) +
					 x_budget_rec.ORIG_BURDENED_COST,
                BASE_REVENUE_TOT       = NVL(BASE_REVENUE_TOT,0 ) +
					 x_budget_rec.BASE_REVENUE,
                ORIG_REVENUE_TOT       = NVL(ORIG_REVENUE_TOT,0 ) +
					 x_budget_rec.ORIG_REVENUE,
                BASE_LABOR_HOURS_TOT   = NVL(BASE_LABOR_HOURS_TOT,0) +
					 x_budget_rec.BASE_LABOR_QUANTITY,
                ORIG_LABOR_HOURS_TOT   = NVL(ORIG_LABOR_HOURS_TOT,0 ) +
					 x_budget_rec.ORIG_LABOR_QUANTITY,
                BASE_QUANTITY_TOT      = NVL(BASE_QUANTITY_TOT,0) +
					 V_Base_Qty,
                ORIG_QUANTITY_TOT      = NVL(ORIG_QUANTITY_TOT,0) +
					 V_Orig_Qty,
                LAST_UPDATED_BY        = pa_proj_accum_main.x_last_updated_by,
                LAST_UPDATE_DATE       = Trunc(Sysdate),
                LAST_UPDATE_LOGIN      = pa_proj_accum_main.x_last_update_login
                Where Budget_Type_Code = x_Budget_rec.BUDGET_TYPE_CODE
                AND
                  (PAB.Project_Accum_id     In
                  (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
                   Where Pah.Project_id = x_project_id and
                   pah.Resource_list_member_id = 0 and
                   Pah.Task_id in (Select Pt.Task_Id from PA_TASKS pt
                   start with pt.task_id = x_budget_rec.TASK_ID
                   connect by prior pt.parent_task_id = pt.task_id)
                   UNION
                   select to_number(X_Proj_accum_id) from sys.dual
                   UNION
                  (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
                   Where Pah.Project_id = x_project_id and
                   pah.Resource_list_member_id =
                   x_Budget_rec.RESOURCE_LIST_MEMBER_ID and
                   Pah.Task_id in (select 0 from sys.dual union
                   Select Pt.Task_Id from PA_TASKS pt
                   start with pt.task_id = x_budget_rec.TASK_ID
                   connect by prior pt.parent_task_id = pt.task_id)))
                  );
                tot_Recs_processed := tot_Recs_processed + SQL%ROWCOUNT;
          END IF;
        END LOOP;
--      Restore the old x_err_stack;
              x_err_stack := V_Old_Stack;

Exception
  When Others Then
    x_err_code := SQLCODE;
    RAISE;
End Process_Budget_Tot;

-- This procedure creates the records in pa_project_accum_budgets
-- for all the task break down hierarachy

Procedure create_accum_budgets
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_budget_type_code In Varchar2,
                                 x_current_period In Varchar2,
                                 x_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number )  --File.Sql.39 bug 4440895
IS

Recs_processed Number := 0;
V_Accum_id     Number := 0;
V_task_array task_id_tabtype;
v_noof_tasks Number := 0;
v_err_code Number := 0;
other_recs_processed Number := 0;
V_Old_Stack       Varchar2(630);
Begin
   V_Old_Stack := x_err_stack;
   x_err_stack :=
   x_err_stack||'->PA_MAINT_PROJECT_BUDGETS.create_accum_budgets';

   -- This checks for budgets record in PA_PROJECT_ACCUM_BUDGETS for this
   -- project and task combination. It is possible that there might be a
   -- header record for this combination in PA_PROJECT_ACCUM_HEADERS, but
   -- no corresponding detail record. The procedure called below,will
   -- check for the existence of the detail records and if not available
   -- would create it.

   pa_accum_utils.Check_budget_Details
                             (x_project_id,
                              x_task_id,
                              0,
                              x_budget_type_code,
                              other_recs_processed,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);

   Recs_processed := Recs_processed + other_recs_processed;

   -- The following procedure would return all the tasks in the given task
   -- WBS hierarchy, including the given task, which do not have a header
   -- record . The return parameter is an array of records.


   Get_all_higher_tasks_bud
			(x_project_id ,
                         x_task_id ,
			 0,             -- resource_list_member_id
                         v_task_array,
                         v_noof_tasks,
                         x_err_stack,
                         x_err_stage,
                         x_err_code);
   -- If the above procedure had returned any tasks , then we need to insert
   -- header record and budgets record. We need to process the tasks one by one
   -- since we require the Accum_id for each detail record.
   -- Eg: If the given task (the one fetched from PA_TXN_ACCUM) was say
   -- 1.1.1, then the first time,    Get_all_higher_tasks would return,
   -- 1.1.1, 1.1,  and 1. We create three header records and three detail records
   -- in the Project_accum_budgets table. The next time , if the given task
   -- is 1.1.2, the Get_all_higher_tasks would return only 1.1.2, since
   -- 1.1 and 1 are already available in the Pa_project_accum_headers. Those
   -- two records would have been processed by the Update statements.

   If v_noof_tasks > 0 Then
       For i in 1..v_noof_tasks LOOP
        Select PA_PROJECT_ACCUM_HEADERS_S.Nextval into V_Accum_id
        From sys.Dual;
        PA_MAINT_PROJECT_ACCUMS.Insert_Headers_tasks
			        (X_project_id,
                                 v_task_array(i),
                                 x_current_period,
                                 v_accum_id,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code);

       Recs_processed := Recs_processed + 1;
       Insert into PA_PROJECT_ACCUM_BUDGETS (
       PROJECT_ACCUM_ID,BUDGET_TYPE_CODE,BASE_RAW_COST_ITD,BASE_RAW_COST_YTD,
       BASE_RAW_COST_PP, BASE_RAW_COST_PTD,
       BASE_BURDENED_COST_ITD,BASE_BURDENED_COST_YTD,
       BASE_BURDENED_COST_PP,BASE_BURDENED_COST_PTD,
       ORIG_RAW_COST_ITD,ORIG_RAW_COST_YTD,
       ORIG_RAW_COST_PP, ORIG_RAW_COST_PTD,
       ORIG_BURDENED_COST_ITD,ORIG_BURDENED_COST_YTD,
       ORIG_BURDENED_COST_PP,ORIG_BURDENED_COST_PTD,
       BASE_QUANTITY_ITD,BASE_QUANTITY_YTD,BASE_QUANTITY_PP,
       BASE_QUANTITY_PTD,
       ORIG_QUANTITY_ITD,ORIG_QUANTITY_YTD,ORIG_QUANTITY_PP,
       ORIG_QUANTITY_PTD,
       BASE_LABOR_HOURS_ITD,BASE_LABOR_HOURS_YTD,BASE_LABOR_HOURS_PP,
       BASE_LABOR_HOURS_PTD,
       ORIG_LABOR_HOURS_ITD,ORIG_LABOR_HOURS_YTD,ORIG_LABOR_HOURS_PP,
       ORIG_LABOR_HOURS_PTD,
       BASE_REVENUE_ITD,BASE_REVENUE_YTD,BASE_REVENUE_PP,BASE_REVENUE_PTD,
       ORIG_REVENUE_ITD,ORIG_REVENUE_YTD,ORIG_REVENUE_PP,ORIG_REVENUE_PTD,
       BASE_UNIT_OF_MEASURE,ORIG_UNIT_OF_MEASURE,
       BASE_RAW_COST_TOT,BASE_BURDENED_COST_TOT,ORIG_RAW_COST_TOT,
       ORIG_BURDENED_COST_TOT,BASE_REVENUE_TOT,ORIG_REVENUE_TOT,
       BASE_LABOR_HOURS_TOT,ORIG_LABOR_HOURS_TOT,BASE_QUANTITY_TOT,
       ORIG_QUANTITY_TOT,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN) Values
       (V_Accum_id,x_budget_type_code,
        0,0,0,0,
        0,0,
        0,0,
        0,0,0,0,
        0,0,
        0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        NULL,NULL,
        0,0,0,0,0,0,0,0,0,0,
        pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);
        Recs_processed := Recs_processed + 1;
      END LOOP;

    End If;
    x_recs_processed := Recs_processed;
    x_err_stack := V_Old_Stack;

EXCEPTION
    When Others then
    x_err_code := SQLCODE;
    RAISE;
END create_accum_budgets;

-- This procedure creates records in HEADERS/budgets table for
-- task/resource_list_member_id combination

Procedure create_accum_budgets_res
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_resource_list_id in Number,
                                 x_resource_list_Member_id in Number,
                                 x_resource_id in Number,
                                 x_resource_list_assignment_id in Number,
                                 x_budget_type_code in Varchar2,
                                 x_current_period In Varchar2,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

CURSOR Proj_Res_level_Cur IS
SELECT Project_Accum_Id
FROM
PA_PROJECT_ACCUM_HEADERS
WHERE Project_id = X_project_id
AND Task_Id = 0
AND Resource_list_Member_id = X_resource_list_member_id;

Recs_processed Number := 0;
V_Accum_id     Number := 0;
V_task_array task_id_tabtype;
v_noof_tasks Number := 0;
Res_Recs_processed Number := 0;
V_Old_Stack       Varchar2(630);

Begin
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      X_err_stack ||'->PA_MAINT_PROJECT_BUDGETS.create_accum_budgets_res';

      -- This checks for budgets record in PA_PROJECT_ACCUM_ACTUALS for this
      -- project,task and resource combination.It is possible that there might be a
      -- header record for this combination in PA_PROJECT_ACCUM_HEADERS, but
      -- no corresponding detail record. The procedure called below,will
      -- check for the existence of the detail records and if not available
      -- would create it.

        PA_ACCUM_UTILS.Check_budget_Details
                             (x_project_id,
                              x_task_id,
                              x_resource_list_Member_id,
                              x_budget_type_code,
                              Res_recs_processed,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);

        Recs_processed := Recs_processed + Res_recs_processed;

        -- This checks for budgets record in PA_PROJECT_ACCUM_ACTUALS for this
        -- project and Resource combination. It is possible that there might be a
        -- header record for this combination in PA_PROJECT_ACCUM_HEADERS, but
        -- no corresponding detail record. The procedure called below,will
        -- check for the existence of the detail records and if not available
        -- would create it.

        PA_ACCUM_UTILS.Check_budget_Details
                             (x_project_id,
                              0,
                              x_resource_list_Member_id,
                              x_budget_type_code,
                              res_recs_processed,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);
        Recs_processed := Recs_processed + Res_recs_processed;

        -- The following procedure would return all the tasks in the given task
        -- WBS hierarchy, including the given task, which do not have a header
        -- record . The return parameter is an array of records.

        v_noof_tasks := 0;

        Get_all_higher_tasks_bud  (x_project_id ,
                                   x_task_id ,
                                   x_resource_list_member_id,
                                   v_task_array,
                                   v_noof_tasks,
                                   x_err_stack,
                                   x_err_stage,
                                   x_err_code);

-- If the above procedure had returned any tasks , then we need to insert
-- header record and budgets record. We need to process the tasks one by one
-- since we require the Accum_id for each detail record.
-- Eg: If the given task (the one fetched from PA_TXN_ACCUM) was say
-- 1.1.1, then the first time,    Get_all_higher_tasks would return,
-- 1.1.1, 1.1,  and 1. We create three header records and three detail records
-- in the Project_accum_budgets table. The next time , if the given task
-- is 1.1.2, the Get_all_higher_tasks would return only 1.1.2, since
-- 1.1 and 1 are already available in the Pa_project_accum_headers. Those
-- two records would have been processed by the Update statements.

    If v_noof_tasks > 0 Then
       For i in 1..v_noof_tasks LOOP
        Select PA_PROJECT_ACCUM_HEADERS_S.Nextval into V_Accum_id
        From sys.Dual;
        PA_process_accum_actuals_res.insert_headers_res
			     (x_project_id,
                              v_task_array(i),
                              x_resource_list_id ,
                              x_resource_list_Member_id ,
                              x_resource_id ,
                              x_resource_list_assignment_id ,
                              x_current_period,
                              v_accum_id,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);
       Recs_processed := Recs_processed + 1;
       Insert into PA_PROJECT_ACCUM_BUDGETS (
       PROJECT_ACCUM_ID,BUDGET_TYPE_CODE,BASE_RAW_COST_ITD,BASE_RAW_COST_YTD,
       BASE_RAW_COST_PP, BASE_RAW_COST_PTD,
       BASE_BURDENED_COST_ITD,BASE_BURDENED_COST_YTD,
       BASE_BURDENED_COST_PP,BASE_BURDENED_COST_PTD,
       ORIG_RAW_COST_ITD,ORIG_RAW_COST_YTD,
       ORIG_RAW_COST_PP, ORIG_RAW_COST_PTD,
       ORIG_BURDENED_COST_ITD,ORIG_BURDENED_COST_YTD,
       ORIG_BURDENED_COST_PP,ORIG_BURDENED_COST_PTD,
       BASE_QUANTITY_ITD,BASE_QUANTITY_YTD,BASE_QUANTITY_PP,
       BASE_QUANTITY_PTD,
       ORIG_QUANTITY_ITD,ORIG_QUANTITY_YTD,ORIG_QUANTITY_PP,
       ORIG_QUANTITY_PTD,
       BASE_LABOR_HOURS_ITD,BASE_LABOR_HOURS_YTD,BASE_LABOR_HOURS_PP,
       BASE_LABOR_HOURS_PTD,
       ORIG_LABOR_HOURS_ITD,ORIG_LABOR_HOURS_YTD,ORIG_LABOR_HOURS_PP,
       ORIG_LABOR_HOURS_PTD,
       BASE_REVENUE_ITD,BASE_REVENUE_YTD,BASE_REVENUE_PP,BASE_REVENUE_PTD,
       ORIG_REVENUE_ITD,ORIG_REVENUE_YTD,ORIG_REVENUE_PP,ORIG_REVENUE_PTD,
       BASE_UNIT_OF_MEASURE,ORIG_UNIT_OF_MEASURE,
       BASE_RAW_COST_TOT,BASE_BURDENED_COST_TOT,ORIG_RAW_COST_TOT,
       ORIG_BURDENED_COST_TOT,BASE_REVENUE_TOT,ORIG_REVENUE_TOT,
       BASE_LABOR_HOURS_TOT,ORIG_LABOR_HOURS_TOT,BASE_QUANTITY_TOT,
       ORIG_QUANTITY_TOT,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN) Values
       (V_Accum_id,x_budget_type_code,
        0,0,0,0,
        0,0,
        0,0,
        0,0,0,0,
        0,0,
        0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        NULL,NULL,
        0,0,0,0,0,0,0,0,0,0,
        pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);

        Recs_processed := Recs_processed + 1;
      END LOOP;
    End If;
-- This will check for the Project-Resource combination in the Header records
-- and if not present create the Header and Detail records for budgets
    Open Proj_Res_level_Cur;
    Fetch Proj_Res_level_Cur Into V_Accum_Id;
    IF Proj_Res_level_Cur%NOTFOUND Then
       Select PA_PROJECT_ACCUM_HEADERS_S.Nextval into V_Accum_id
       From sys.Dual;
       PA_process_accum_actuals_res.insert_headers_res
                          (x_project_id,
                           0,
                           x_resource_list_id ,
                           x_resource_list_Member_id ,
                           x_resource_id ,
                           x_resource_list_assignment_id ,
                           x_current_period,
                           v_accum_id,
                           x_err_stack,
                           x_err_stage,
                           x_err_code);

       Recs_processed := Recs_processed + 1;
       Insert into PA_PROJECT_ACCUM_BUDGETS (
       PROJECT_ACCUM_ID,BUDGET_TYPE_CODE,BASE_RAW_COST_ITD,BASE_RAW_COST_YTD,
       BASE_RAW_COST_PP, BASE_RAW_COST_PTD,
       BASE_BURDENED_COST_ITD,BASE_BURDENED_COST_YTD,
       BASE_BURDENED_COST_PP,BASE_BURDENED_COST_PTD,
       ORIG_RAW_COST_ITD,ORIG_RAW_COST_YTD,
       ORIG_RAW_COST_PP, ORIG_RAW_COST_PTD,
       ORIG_BURDENED_COST_ITD,ORIG_BURDENED_COST_YTD,
       ORIG_BURDENED_COST_PP,ORIG_BURDENED_COST_PTD,
       BASE_QUANTITY_ITD,BASE_QUANTITY_YTD,BASE_QUANTITY_PP,
       BASE_QUANTITY_PTD,
       ORIG_QUANTITY_ITD,ORIG_QUANTITY_YTD,ORIG_QUANTITY_PP,
       ORIG_QUANTITY_PTD,
       BASE_LABOR_HOURS_ITD,BASE_LABOR_HOURS_YTD,BASE_LABOR_HOURS_PP,
       BASE_LABOR_HOURS_PTD,
       ORIG_LABOR_HOURS_ITD,ORIG_LABOR_HOURS_YTD,ORIG_LABOR_HOURS_PP,
       ORIG_LABOR_HOURS_PTD,
       BASE_REVENUE_ITD,BASE_REVENUE_YTD,BASE_REVENUE_PP,BASE_REVENUE_PTD,
       ORIG_REVENUE_ITD,ORIG_REVENUE_YTD,ORIG_REVENUE_PP,ORIG_REVENUE_PTD,
       BASE_UNIT_OF_MEASURE,ORIG_UNIT_OF_MEASURE,
       BASE_RAW_COST_TOT,BASE_BURDENED_COST_TOT,ORIG_RAW_COST_TOT,
       ORIG_BURDENED_COST_TOT,BASE_REVENUE_TOT,ORIG_REVENUE_TOT,
       BASE_LABOR_HOURS_TOT,ORIG_LABOR_HOURS_TOT,BASE_QUANTITY_TOT,
       ORIG_QUANTITY_TOT,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN) Values
       (V_Accum_id,x_budget_type_code,
        0,0,0,0,
        0,0,
        0,0,
        0,0,0,0,
        0,0,
        0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        NULL,NULL,
        0,0,0,0,0,0,0,0,0,0,
        pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);
        Recs_processed := Recs_processed + 1;
    END IF;
    Close Proj_Res_level_Cur;
    x_recs_processed := Recs_processed;

    --  Restore the old x_err_stack;

    x_err_stack := V_Old_Stack;
Exception
  When Others Then
       x_err_code := SQLCODE;
       RAISE;
End create_accum_budgets_res;

Procedure Get_all_higher_tasks_bud (x_project_id in Number,
                                      x_task_id in Number,
                                      x_resource_list_member_id In Number,
                                      x_task_array  Out NOCOPY task_id_tabtype, --File.Sql.39 bug 4440895
                                      x_noof_tasks Out NOCOPY number, --File.Sql.39 bug 4440895
                                      x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                      x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                      x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895


-- Get_all_higher_tasks_bud  -  For the given Task Id returns all the
--                              higher level tasks in the WBS (including the given
--                              task) which are not in PA_PROJECT_ACCUM_HEADERS
--                              (Tasks with the given Resource )

CURSOR  Tasks_Cur IS
SELECT task_id
FROM
pa_tasks pt
WHERE project_id = x_project_id
START WITH task_id = x_task_id
CONNECT BY PRIOR parent_task_id = task_id;

v_noof_tasks         Number := 0;

V_Old_Stack       Varchar2(630);
Task_Rec Tasks_Cur%ROWTYPE;
Begin
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_MAINT_PROJECT_BUDGETS.Get_all_higher_tasks_bud';

      pa_debug.debug(x_err_stack);

      For Task_Rec IN Tasks_Cur LOOP
          v_noof_tasks := v_noof_tasks + 1;
          x_task_array(v_noof_tasks) := Task_Rec.Task_id;

      END LOOP;

      x_noof_tasks := v_noof_tasks;

--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
Exception
   When Others Then
     x_err_code := SQLCODE;
     RAISE ;

end Get_all_higher_tasks_bud;



Procedure Initialize_res_level is
begin
   pa_debug.debug('Initialize_res_level');

   V_Base_Burdened_Cost_itd	:=0;
   V_Base_Burdened_Cost_ptd	:=0;
   V_Base_Burdened_Cost_pp 	:=0;
   V_Base_Burdened_Cost_ytd	:=0;
   V_Base_Labor_Hours_itd	:=0;
   V_Base_Labor_Hours_ptd	:=0;
   V_Base_Labor_Hours_pp 	:=0;
   V_Base_Labor_Hours_ytd	:=0;
   V_Base_Raw_Cost_itd		:=0;
   V_Base_Raw_Cost_ptd		:=0;
   V_Base_Raw_Cost_pp 		:=0;
   V_Base_Raw_Cost_ytd		:=0;
   V_Base_Revenue_itd		:=0;
   V_Base_Revenue_ptd		:=0;
   V_Base_Revenue_pp 		:=0;
   V_Base_Revenue_ytd		:=0;
   V_Base_Quantity_itd		:=0;
   V_Base_Quantity_ptd		:=0;
   V_Base_Quantity_pp 		:=0;
   V_Base_Quantity_ytd		:=0;
   V_Orig_Burdened_Cost_itd	:=0;
   V_Orig_Burdened_Cost_ptd	:=0;
   V_Orig_Burdened_Cost_pp 	:=0;
   V_Orig_Burdened_Cost_ytd	:=0;
   V_Orig_Labor_Hours_itd	:=0;
   V_Orig_Labor_Hours_ptd	:=0;
   V_Orig_Labor_Hours_pp 	:=0;
   V_Orig_Labor_Hours_ytd	:=0;
   V_Orig_Quantity_itd		:=0;
   V_Orig_Quantity_ptd		:=0;
   V_Orig_Quantity_pp 		:=0;
   V_Orig_Quantity_ytd		:=0;
   V_Orig_Raw_Cost_itd		:=0;
   V_Orig_Raw_Cost_ptd		:=0;
   V_Orig_Raw_Cost_pp 		:=0;
   V_Orig_Raw_Cost_ytd		:=0;
   V_Orig_Revenue_itd		:=0;
   V_Orig_Revenue_ptd		:=0;
   V_Orig_Revenue_pp 		:=0;
   V_Orig_Revenue_ytd		:=0;
  TOT_ORIG_REVENUE              := 0;
  TOT_BASE_REVENUE              := 0;
  TOT_ORIG_QUANTITY             := 0;
  TOT_BASE_QUANTITY             := 0;
  TOT_ORIG_RAW_COST             := 0;
  TOT_BASE_RAW_COST             := 0;
  TOT_ORIG_BURDENED_COST        := 0;
  TOT_BASE_BURDENED_COST        := 0;
  TOT_ORIG_LABOR_HOURS          := 0;
  TOT_BASE_LABOR_HOURS          := 0;

end Initialize_res_level;

Procedure Initialize_project_level is
begin
   pa_debug.debug('Initialize_project_level');

   Prj_Base_Burdened_Cost_itd	:=0;
   Prj_Base_Burdened_Cost_ptd	:=0;
   Prj_Base_Burdened_Cost_pp 	:=0;
   Prj_Base_Burdened_Cost_ytd	:=0;
   Prj_Base_Labor_Hours_itd	:=0;
   Prj_Base_Labor_Hours_ptd	:=0;
   Prj_Base_Labor_Hours_pp 	:=0;
   Prj_Base_Labor_Hours_ytd	:=0;
   Prj_Base_Raw_Cost_itd	:=0;
   Prj_Base_Raw_Cost_ptd	:=0;
   Prj_Base_Raw_Cost_pp 	:=0;
   Prj_Base_Raw_Cost_ytd	:=0;
   Prj_Base_Revenue_itd		:=0;
   Prj_Base_Revenue_ptd		:=0;
   Prj_Base_Revenue_pp 		:=0;
   Prj_Base_Revenue_ytd		:=0;
   Prj_Base_Quantity_itd	:=0;
   Prj_Base_Quantity_ptd	:=0;
   Prj_Base_Quantity_pp 	:=0;
   Prj_Base_Quantity_ytd	:=0;
   Prj_Orig_Burdened_Cost_itd	:=0;
   Prj_Orig_Burdened_Cost_ptd	:=0;
   Prj_Orig_Burdened_Cost_pp 	:=0;
   Prj_Orig_Burdened_Cost_ytd	:=0;
   Prj_Orig_Labor_Hours_itd	:=0;
   Prj_Orig_Labor_Hours_ptd	:=0;
   Prj_Orig_Labor_Hours_pp 	:=0;
   Prj_Orig_Labor_Hours_ytd	:=0;
   Prj_Orig_Quantity_itd	:=0;
   Prj_Orig_Quantity_ptd	:=0;
   Prj_Orig_Quantity_pp 	:=0;
   Prj_Orig_Quantity_ytd	:=0;
   Prj_Orig_Raw_Cost_itd	:=0;
   Prj_Orig_Raw_Cost_ptd	:=0;
   Prj_Orig_Raw_Cost_pp 	:=0;
   Prj_Orig_Raw_Cost_ytd	:=0;
   Prj_Orig_Revenue_itd		:=0;
   Prj_Orig_Revenue_ptd		:=0;
   Prj_Orig_Revenue_pp 		:=0;
   Prj_Orig_Revenue_ytd		:=0;
   Prj_ORIG_REVENUE             := 0;
   Prj_BASE_REVENUE             := 0;
   Prj_ORIG_QUANTITY            := 0;
   Prj_BASE_QUANTITY            := 0;
   Prj_ORIG_RAW_COST            := 0;
   Prj_BASE_RAW_COST            := 0;
   Prj_ORIG_BURDENED_COST       := 0;
   Prj_BASE_BURDENED_COST       := 0;
   Prj_ORIG_LABOR_HOURS         := 0;
   Prj_BASE_LABOR_HOURS         := 0;

end Initialize_project_level;

Procedure Initialize_task_level is
begin
   pa_debug.debug('Initialize_task_level');

   Tsk_Base_Burdened_Cost_itd	:=0;
   Tsk_Base_Burdened_Cost_ptd	:=0;
   Tsk_Base_Burdened_Cost_pp 	:=0;
   Tsk_Base_Burdened_Cost_ytd	:=0;
   Tsk_Base_Labor_Hours_itd	:=0;
   Tsk_Base_Labor_Hours_ptd	:=0;
   Tsk_Base_Labor_Hours_pp 	:=0;
   Tsk_Base_Labor_Hours_ytd	:=0;
   Tsk_Base_Raw_Cost_itd	:=0;
   Tsk_Base_Raw_Cost_ptd	:=0;
   Tsk_Base_Raw_Cost_pp 	:=0;
   Tsk_Base_Raw_Cost_ytd	:=0;
   Tsk_Base_Revenue_itd		:=0;
   Tsk_Base_Revenue_ptd		:=0;
   Tsk_Base_Revenue_pp 		:=0;
   Tsk_Base_Revenue_ytd		:=0;
   Tsk_Base_Quantity_itd	:=0;
   Tsk_Base_Quantity_ptd	:=0;
   Tsk_Base_Quantity_pp 	:=0;
   Tsk_Base_Quantity_ytd	:=0;
   Tsk_Orig_Burdened_Cost_itd	:=0;
   Tsk_Orig_Burdened_Cost_ptd	:=0;
   Tsk_Orig_Burdened_Cost_pp 	:=0;
   Tsk_Orig_Burdened_Cost_ytd	:=0;
   Tsk_Orig_Labor_Hours_itd	:=0;
   Tsk_Orig_Labor_Hours_ptd	:=0;
   Tsk_Orig_Labor_Hours_pp 	:=0;
   Tsk_Orig_Labor_Hours_ytd	:=0;
   Tsk_Orig_Quantity_itd	:=0;
   Tsk_Orig_Quantity_ptd	:=0;
   Tsk_Orig_Quantity_pp 	:=0;
   Tsk_Orig_Quantity_ytd	:=0;
   Tsk_Orig_Raw_Cost_itd	:=0;
   Tsk_Orig_Raw_Cost_ptd	:=0;
   Tsk_Orig_Raw_Cost_pp 	:=0;
   Tsk_Orig_Raw_Cost_ytd	:=0;
   Tsk_Orig_Revenue_itd		:=0;
   Tsk_Orig_Revenue_ptd		:=0;
   Tsk_Orig_Revenue_pp 		:=0;
   Tsk_Orig_Revenue_ytd		:=0;
   Tsk_ORIG_REVENUE             := 0;
   Tsk_BASE_REVENUE             := 0;
   Tsk_ORIG_QUANTITY            := 0;
   Tsk_BASE_QUANTITY            := 0;
   Tsk_ORIG_RAW_COST            := 0;
   Tsk_BASE_RAW_COST            := 0;
   Tsk_ORIG_BURDENED_COST       := 0;
   Tsk_BASE_BURDENED_COST       := 0;
   Tsk_ORIG_LABOR_HOURS         := 0;
   Tsk_BASE_LABOR_HOURS         := 0;

end Initialize_task_level;

Procedure Add_task_amounts is
begin
   pa_debug.debug('Add_task_amounts');

   Tsk_Base_Burdened_Cost_itd	:= Tsk_Base_Burdened_Cost_itd + V_Base_Burdened_Cost_itd;
   Tsk_Base_Burdened_Cost_ptd	:= Tsk_Base_Burdened_Cost_ptd + V_Base_Burdened_Cost_ptd;
   Tsk_Base_Burdened_Cost_pp 	:= Tsk_Base_Burdened_Cost_pp  + V_Base_Burdened_Cost_pp;
   Tsk_Base_Burdened_Cost_ytd	:= Tsk_Base_Burdened_Cost_ytd + V_Base_Burdened_Cost_ytd;
   Tsk_Base_Labor_Hours_itd	:= Tsk_Base_Labor_Hours_itd + V_Base_Labor_Hours_itd;
   Tsk_Base_Labor_Hours_ptd	:= Tsk_Base_Labor_Hours_ptd + V_Base_Labor_Hours_ptd;
   Tsk_Base_Labor_Hours_pp 	:= Tsk_Base_Labor_Hours_pp  + V_Base_Labor_Hours_pp;
   Tsk_Base_Labor_Hours_ytd	:= Tsk_Base_Labor_Hours_ytd + V_Base_Labor_Hours_ytd;
   Tsk_Base_Raw_Cost_itd	:= Tsk_Base_Raw_Cost_itd + V_Base_Raw_Cost_itd;
   Tsk_Base_Raw_Cost_ptd	:= Tsk_Base_Raw_Cost_ptd + V_Base_Raw_Cost_ptd;
   Tsk_Base_Raw_Cost_pp 	:= Tsk_Base_Raw_Cost_pp  + V_Base_Raw_Cost_pp;
   Tsk_Base_Raw_Cost_ytd	:= Tsk_Base_Raw_Cost_ytd + V_Base_Raw_Cost_ytd;
   Tsk_Base_Revenue_itd		:= Tsk_Base_Revenue_itd + V_Base_Revenue_itd;
   Tsk_Base_Revenue_ptd		:= Tsk_Base_Revenue_ptd + V_Base_Revenue_ptd;
   Tsk_Base_Revenue_pp 		:= Tsk_Base_Revenue_pp  + V_Base_Revenue_pp;
   Tsk_Base_Revenue_ytd		:= Tsk_Base_Revenue_ytd + V_Base_Revenue_ytd;
   Tsk_Base_Quantity_itd	:= Tsk_Base_Quantity_itd + V_Base_Quantity_itd;
   Tsk_Base_Quantity_ptd	:= Tsk_Base_Quantity_ptd + V_Base_Quantity_ptd;
   Tsk_Base_Quantity_pp 	:= Tsk_Base_Quantity_pp  + V_Base_Quantity_pp;
   Tsk_Base_Quantity_ytd	:= Tsk_Base_Quantity_ytd + V_Base_Quantity_ytd;
   Tsk_Orig_Burdened_Cost_itd	:= Tsk_Orig_Burdened_Cost_itd + V_Orig_Burdened_Cost_itd;
   Tsk_Orig_Burdened_Cost_ptd	:= Tsk_Orig_Burdened_Cost_ptd + V_Orig_Burdened_Cost_ptd;
   Tsk_Orig_Burdened_Cost_pp 	:= Tsk_Orig_Burdened_Cost_pp + V_Orig_Burdened_Cost_pp;
   Tsk_Orig_Burdened_Cost_ytd	:= Tsk_Orig_Burdened_Cost_ytd + V_Orig_Burdened_Cost_ytd;
   Tsk_Orig_Labor_Hours_itd	:= Tsk_Orig_Labor_Hours_itd + V_Orig_Labor_Hours_itd;
   Tsk_Orig_Labor_Hours_ptd	:= Tsk_Orig_Labor_Hours_ptd + V_Orig_Labor_Hours_ptd;
   Tsk_Orig_Labor_Hours_pp 	:= Tsk_Orig_Labor_Hours_pp  + V_Orig_Labor_Hours_pp;
   Tsk_Orig_Labor_Hours_ytd	:= Tsk_Orig_Labor_Hours_ytd + V_Orig_Labor_Hours_ytd;
   Tsk_Orig_Quantity_itd	:= Tsk_Orig_Quantity_itd + V_Orig_Quantity_itd;
   Tsk_Orig_Quantity_ptd	:= Tsk_Orig_Quantity_ptd + V_Orig_Quantity_ptd;
   Tsk_Orig_Quantity_pp 	:= Tsk_Orig_Quantity_pp + V_Orig_Quantity_pp;
   Tsk_Orig_Quantity_ytd	:= Tsk_Orig_Quantity_ytd + V_Orig_Quantity_ytd;
   Tsk_Orig_Raw_Cost_itd	:= Tsk_Orig_Raw_Cost_itd + V_Orig_Raw_Cost_itd;
   Tsk_Orig_Raw_Cost_ptd	:= Tsk_Orig_Raw_Cost_ptd + V_Orig_Raw_Cost_ptd;
   Tsk_Orig_Raw_Cost_pp 	:= Tsk_Orig_Raw_Cost_pp + V_Orig_Raw_Cost_pp;
   Tsk_Orig_Raw_Cost_ytd	:= Tsk_Orig_Raw_Cost_ytd + V_Orig_Raw_Cost_ytd;
   Tsk_Orig_Revenue_itd		:= Tsk_Orig_Revenue_itd + V_Orig_Revenue_itd;
   Tsk_Orig_Revenue_ptd		:= Tsk_Orig_Revenue_ptd + V_Orig_Revenue_ptd;
   Tsk_Orig_Revenue_pp 		:= Tsk_Orig_Revenue_pp + V_Orig_Revenue_pp;
   Tsk_Orig_Revenue_ytd		:= Tsk_Orig_Revenue_ytd + V_Orig_Revenue_ytd;
   Tsk_ORIG_REVENUE             := Tsk_ORIG_REVENUE + tot_orig_revenue;
   Tsk_BASE_REVENUE             := Tsk_BASE_REVENUE + tot_base_revenue;
   Tsk_ORIG_QUANTITY            := Tsk_ORIG_QUANTITY + tot_orig_quantity;
   Tsk_BASE_QUANTITY            := Tsk_BASE_QUANTITY + tot_base_quantity;
   Tsk_ORIG_RAW_COST            := Tsk_ORIG_RAW_COST + tot_orig_raw_cost;
   Tsk_BASE_RAW_COST            := Tsk_BASE_RAW_COST + tot_base_raw_cost;
   Tsk_ORIG_BURDENED_COST       := Tsk_ORIG_BURDENED_COST + tot_orig_burdened_cost;
   Tsk_BASE_BURDENED_COST       := Tsk_BASE_BURDENED_COST + tot_base_burdened_cost;
   Tsk_ORIG_LABOR_HOURS         := Tsk_ORIG_LABOR_HOURS + tot_orig_labor_hours;
   Tsk_BASE_LABOR_HOURS         := Tsk_BASE_LABOR_HOURS + tot_base_labor_hours;

end Add_task_amounts;

Procedure Add_project_amounts is
begin
   pa_debug.debug('Add_project_amounts');

   Prj_Base_Burdened_Cost_itd	:= Prj_Base_Burdened_Cost_itd + V_Base_Burdened_Cost_itd;
   Prj_Base_Burdened_Cost_ptd	:= Prj_Base_Burdened_Cost_ptd + V_Base_Burdened_Cost_ptd;
   Prj_Base_Burdened_Cost_pp 	:= Prj_Base_Burdened_Cost_pp  + V_Base_Burdened_Cost_pp;
   Prj_Base_Burdened_Cost_ytd	:= Prj_Base_Burdened_Cost_ytd + V_Base_Burdened_Cost_ytd;
   Prj_Base_Labor_Hours_itd	:= Prj_Base_Labor_Hours_itd + V_Base_Labor_Hours_itd;
   Prj_Base_Labor_Hours_ptd	:= Prj_Base_Labor_Hours_ptd + V_Base_Labor_Hours_ptd;
   Prj_Base_Labor_Hours_pp 	:= Prj_Base_Labor_Hours_pp  + V_Base_Labor_Hours_pp;
   Prj_Base_Labor_Hours_ytd	:= Prj_Base_Labor_Hours_ytd + V_Base_Labor_Hours_ytd;
   Prj_Base_Raw_Cost_itd	:= Prj_Base_Raw_Cost_itd + V_Base_Raw_Cost_itd;
   Prj_Base_Raw_Cost_ptd	:= Prj_Base_Raw_Cost_ptd + V_Base_Raw_Cost_ptd;
   Prj_Base_Raw_Cost_pp 	:= Prj_Base_Raw_Cost_pp  + V_Base_Raw_Cost_pp;
   Prj_Base_Raw_Cost_ytd	:= Prj_Base_Raw_Cost_ytd + V_Base_Raw_Cost_ytd;
   Prj_Base_Revenue_itd		:= Prj_Base_Revenue_itd + V_Base_Revenue_itd;
   Prj_Base_Revenue_ptd		:= Prj_Base_Revenue_ptd + V_Base_Revenue_ptd;
   Prj_Base_Revenue_pp 		:= Prj_Base_Revenue_pp  + V_Base_Revenue_pp;
   Prj_Base_Revenue_ytd		:= Prj_Base_Revenue_ytd + V_Base_Revenue_ytd;
   Prj_Base_Quantity_itd	:= Prj_Base_Quantity_itd + V_Base_Quantity_itd;
   Prj_Base_Quantity_ptd	:= Prj_Base_Quantity_ptd + V_Base_Quantity_ptd;
   Prj_Base_Quantity_pp 	:= Prj_Base_Quantity_pp  + V_Base_Quantity_pp;
   Prj_Base_Quantity_ytd	:= Prj_Base_Quantity_ytd + V_Base_Quantity_ytd;
   Prj_Orig_Burdened_Cost_itd	:= Prj_Orig_Burdened_Cost_itd + V_Orig_Burdened_Cost_itd;
   Prj_Orig_Burdened_Cost_ptd	:= Prj_Orig_Burdened_Cost_ptd + V_Orig_Burdened_Cost_ptd;
   Prj_Orig_Burdened_Cost_pp 	:= Prj_Orig_Burdened_Cost_pp + V_Orig_Burdened_Cost_pp;
   Prj_Orig_Burdened_Cost_ytd	:= Prj_Orig_Burdened_Cost_ytd + V_Orig_Burdened_Cost_ytd;
   Prj_Orig_Labor_Hours_itd	:= Prj_Orig_Labor_Hours_itd + V_Orig_Labor_Hours_itd;
   Prj_Orig_Labor_Hours_ptd	:= Prj_Orig_Labor_Hours_ptd + V_Orig_Labor_Hours_ptd;
   Prj_Orig_Labor_Hours_pp 	:= Prj_Orig_Labor_Hours_pp  + V_Orig_Labor_Hours_pp;
   Prj_Orig_Labor_Hours_ytd	:= Prj_Orig_Labor_Hours_ytd + V_Orig_Labor_Hours_ytd;
   Prj_Orig_Quantity_itd	:= Prj_Orig_Quantity_itd + V_Orig_Quantity_itd;
   Prj_Orig_Quantity_ptd	:= Prj_Orig_Quantity_ptd + V_Orig_Quantity_ptd;
   Prj_Orig_Quantity_pp 	:= Prj_Orig_Quantity_pp + V_Orig_Quantity_pp;
   Prj_Orig_Quantity_ytd	:= Prj_Orig_Quantity_ytd + V_Orig_Quantity_ytd;
   Prj_Orig_Raw_Cost_itd	:= Prj_Orig_Raw_Cost_itd + V_Orig_Raw_Cost_itd;
   Prj_Orig_Raw_Cost_ptd	:= Prj_Orig_Raw_Cost_ptd + V_Orig_Raw_Cost_ptd;
   Prj_Orig_Raw_Cost_pp 	:= Prj_Orig_Raw_Cost_pp + V_Orig_Raw_Cost_pp;
   Prj_Orig_Raw_Cost_ytd	:= Prj_Orig_Raw_Cost_ytd + V_Orig_Raw_Cost_ytd;
   Prj_Orig_Revenue_itd		:= Prj_Orig_Revenue_itd + V_Orig_Revenue_itd;
   Prj_Orig_Revenue_ptd		:= Prj_Orig_Revenue_ptd + V_Orig_Revenue_ptd;
   Prj_Orig_Revenue_pp 		:= Prj_Orig_Revenue_pp + V_Orig_Revenue_pp;
   Prj_Orig_Revenue_ytd		:= Prj_Orig_Revenue_ytd + V_Orig_Revenue_ytd;
   Prj_ORIG_REVENUE             := Prj_ORIG_REVENUE + tot_orig_revenue;
   Prj_BASE_REVENUE             := Prj_BASE_REVENUE + tot_base_revenue;
   Prj_ORIG_QUANTITY            := Prj_ORIG_QUANTITY + tot_orig_quantity;
   Prj_BASE_QUANTITY            := Prj_BASE_QUANTITY + tot_base_quantity;
   Prj_ORIG_RAW_COST            := Prj_ORIG_RAW_COST + tot_orig_raw_cost;
   Prj_BASE_RAW_COST            := Prj_BASE_RAW_COST + tot_base_raw_cost;
   Prj_ORIG_BURDENED_COST       := Prj_ORIG_BURDENED_COST + tot_orig_burdened_cost;
   Prj_BASE_BURDENED_COST       := Prj_BASE_BURDENED_COST + tot_base_burdened_cost;
   Prj_ORIG_LABOR_HOURS         := Prj_ORIG_LABOR_HOURS + tot_orig_labor_hours;
   Prj_BASE_LABOR_HOURS         := Prj_BASE_LABOR_HOURS + tot_base_labor_hours;

end Add_project_amounts;



--
--History:
--    	xx-xxx-xxxx     who?		- Created
--
--      26-SEP-2002	jwhite		- Converted to support both r11.5.7 Budget and FP models.
--                                        1) adapted code to include fin_plan_type_id.

----------------------------------------------------------
Procedure   Process_all_buds
                                (x_project_id 		   In Number,
                                 x_current_period          In varchar2,
                                 x_task_id 		   In Number,
                                 x_resource_list_id 	   In Number,
                                 x_resource_list_Member_id In Number,
                                 x_resource_id 		   In Number,
                                 x_resource_list_assignment_id In Number,
                                 x_rollup_qty_flag         In Varchar2,
                                 x_budget_type_code 	   In Varchar2,
                                 x_fin_plan_type_id        IN NUMBER,
                                 X_Base_Unit_Of_Measure    In Varchar2,
                                 X_Orig_Unit_Of_Measure    In Varchar2,
                                 X_Recs_processed 	   Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     	   In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     	   In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      	   In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895


Recs_processed         Number := 0;
V_Accum_id             Number := 0;
Res_Recs_processed     Number := 0;
x_pab                  Boolean := true;
V_Old_Stack       Varchar2(630);

Begin

      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_BUDGETS_RES.Process_all_buds';

      pa_debug.debug(x_err_stack);

        x_pab := true;

-- The following Update statement updates all records in the given task
-- WBS hierarchy.It will update only the Project-task-resource combination
-- records and the Project-Resource level record(Task id = 0 and
-- Resourcelist member id <> 0)
    begin
        Select project_accum_id into V_Accum_id
          from pa_project_accum_headers
         where project_id = x_project_id
           and task_id = x_task_id
           and resource_list_member_id = x_resource_list_member_id;

    exception when no_data_found then
       Select PA_PROJECT_ACCUM_HEADERS_S.Nextval into V_Accum_id
       from sys.dual;
            Insert into PA_PROJECT_ACCUM_HEADERS
           (PROJECT_ACCUM_ID,PROJECT_ID,TASK_ID,ACCUM_PERIOD,RESOURCE_ID,
            RESOURCE_LIST_ID,RESOURCE_LIST_ASSIGNMENT_ID,
            RESOURCE_LIST_MEMBER_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,
            REQUEST_ID,CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN
            )
            Values (v_accum_id,X_project_id,x_task_id,
                    x_current_period,
                    x_resource_id,x_resource_list_id,
                    x_resource_list_assignment_id,x_resource_list_Member_id,
                    pa_proj_accum_main.x_last_updated_by,
                    Trunc(sysdate),pa_proj_accum_main.x_request_id,
                    trunc(sysdate),
                    pa_proj_accum_main.x_created_by,
                    pa_proj_accum_main.x_last_update_login
                    );

       Insert into PA_PROJECT_ACCUM_BUDGETS (
       PROJECT_ACCUM_ID,BUDGET_TYPE_CODE,BASE_RAW_COST_ITD,BASE_RAW_COST_YTD,
       BASE_RAW_COST_PP, BASE_RAW_COST_PTD,
       BASE_BURDENED_COST_ITD,BASE_BURDENED_COST_YTD,
       BASE_BURDENED_COST_PP,BASE_BURDENED_COST_PTD,
       ORIG_RAW_COST_ITD,ORIG_RAW_COST_YTD,
       ORIG_RAW_COST_PP, ORIG_RAW_COST_PTD,
       ORIG_BURDENED_COST_ITD,ORIG_BURDENED_COST_YTD,
       ORIG_BURDENED_COST_PP,ORIG_BURDENED_COST_PTD,
       BASE_QUANTITY_ITD,BASE_QUANTITY_YTD,BASE_QUANTITY_PP,
       BASE_QUANTITY_PTD,
       ORIG_QUANTITY_ITD,ORIG_QUANTITY_YTD,ORIG_QUANTITY_PP,
       ORIG_QUANTITY_PTD,
       BASE_LABOR_HOURS_ITD,BASE_LABOR_HOURS_YTD,BASE_LABOR_HOURS_PP,
       BASE_LABOR_HOURS_PTD,
       ORIG_LABOR_HOURS_ITD,ORIG_LABOR_HOURS_YTD,ORIG_LABOR_HOURS_PP,
       ORIG_LABOR_HOURS_PTD,
       BASE_REVENUE_ITD,BASE_REVENUE_YTD,BASE_REVENUE_PP,BASE_REVENUE_PTD,
       ORIG_REVENUE_ITD,ORIG_REVENUE_YTD,ORIG_REVENUE_PP,ORIG_REVENUE_PTD,
       BASE_UNIT_OF_MEASURE,ORIG_UNIT_OF_MEASURE,
       BASE_RAW_COST_TOT,BASE_BURDENED_COST_TOT,ORIG_RAW_COST_TOT,
       ORIG_BURDENED_COST_TOT,BASE_REVENUE_TOT,ORIG_REVENUE_TOT,
       BASE_LABOR_HOURS_TOT,ORIG_LABOR_HOURS_TOT,BASE_QUANTITY_TOT,
       ORIG_QUANTITY_TOT,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN,
       FIN_PLAN_TYPE_ID
       )
       Values
       (
       V_Accum_id,x_budget_type_code,
       V_BASE_RAW_COST_ITD,V_BASE_RAW_COST_YTD,
       V_BASE_RAW_COST_PP, V_BASE_RAW_COST_PTD,
       V_BASE_BURDENED_COST_ITD,V_BASE_BURDENED_COST_YTD,
       V_BASE_BURDENED_COST_PP,V_BASE_BURDENED_COST_PTD,
       V_ORIG_RAW_COST_ITD,V_ORIG_RAW_COST_YTD,
       V_ORIG_RAW_COST_PP, V_ORIG_RAW_COST_PTD,
       V_ORIG_BURDENED_COST_ITD,V_ORIG_BURDENED_COST_YTD,
       V_ORIG_BURDENED_COST_PP,V_ORIG_BURDENED_COST_PTD,
       V_BASE_QUANTITY_ITD,V_BASE_QUANTITY_YTD,V_BASE_QUANTITY_PP,
       V_BASE_QUANTITY_PTD,
       V_ORIG_QUANTITY_ITD,V_ORIG_QUANTITY_YTD,V_ORIG_QUANTITY_PP,
       V_ORIG_QUANTITY_PTD,
       V_BASE_LABOR_HOURS_ITD,V_BASE_LABOR_HOURS_YTD,V_BASE_LABOR_HOURS_PP,
       V_BASE_LABOR_HOURS_PTD,
       V_ORIG_LABOR_HOURS_ITD,V_ORIG_LABOR_HOURS_YTD,V_ORIG_LABOR_HOURS_PP,
       V_ORIG_LABOR_HOURS_PTD,
       V_BASE_REVENUE_ITD,V_BASE_REVENUE_YTD,V_BASE_REVENUE_PP,V_BASE_REVENUE_PTD,
       V_ORIG_REVENUE_ITD,V_ORIG_REVENUE_YTD,V_ORIG_REVENUE_PP,V_ORIG_REVENUE_PTD,
       X_BASE_UNIT_OF_MEASURE,X_ORIG_UNIT_OF_MEASURE,
       TOT_BASE_RAW_COST,TOT_BASE_BURDENED_COST,TOT_ORIG_RAW_COST,
       TOT_ORIG_BURDENED_COST,TOT_BASE_REVENUE,TOT_ORIG_REVENUE,
       TOT_BASE_LABOR_HOURS,TOT_ORIG_LABOR_HOURS,TOT_BASE_QUANTITY,
       TOT_ORIG_QUANTITY,
       pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
       Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login,
       x_fin_plan_type_id
        );
       x_pab := false;
 end;
       If x_pab = true then
        Update PA_PROJECT_ACCUM_BUDGETS  PAB SET
         BASE_RAW_COST_ITD      = NVL(BASE_RAW_COST_ITD,0) +
				  NVL(V_Base_Raw_Cost_itd,0),
         BASE_RAW_COST_YTD      = NVL(BASE_RAW_COST_YTD,0) +
				  NVL(V_Base_Raw_Cost_ytd,0),
         BASE_RAW_COST_PTD      = NVL(BASE_RAW_COST_PTD,0) +
				  NVL(V_Base_Raw_Cost_ptd,0),
         BASE_RAW_COST_PP       = NVL(BASE_RAW_COST_PP,0)  +
				  NVL(V_Base_Raw_Cost_pp,0),
         ORIG_RAW_COST_ITD      = NVL(ORIG_RAW_COST_ITD,0) +
				  NVL(V_Orig_Raw_Cost_itd,0),
         ORIG_RAW_COST_YTD      = NVL(ORIG_RAW_COST_YTD,0) +
				  NVL(V_Orig_Raw_Cost_ytd,0),
         ORIG_RAW_COST_PTD      = NVL(ORIG_RAW_COST_PTD,0) +
				  NVL(V_Orig_Raw_Cost_ptd,0),
         ORIG_RAW_COST_PP       = NVL(ORIG_RAW_COST_PP,0)  +
				  NVL(V_Orig_Raw_Cost_pp,0),
         BASE_BURDENED_COST_ITD = NVL(BASE_BURDENED_COST_ITD,0) +
                                  NVL(V_Base_Burdened_Cost_itd,0),
         BASE_BURDENED_COST_YTD = NVL(BASE_BURDENED_COST_YTD,0) +
                                  NVL(V_Base_Burdened_Cost_ytd,0),
         BASE_BURDENED_COST_PTD = NVL(BASE_BURDENED_COST_PTD,0) +
                                  NVL(V_Base_Burdened_Cost_ptd,0),
         BASE_BURDENED_COST_PP  = NVL(BASE_BURDENED_COST_PP,0)  +
                                  NVL(V_Base_Burdened_Cost_pp,0),
         ORIG_BURDENED_COST_ITD = NVL(ORIG_BURDENED_COST_ITD,0) +
                                  NVL(V_Orig_Burdened_Cost_itd,0),
         ORIG_BURDENED_COST_YTD = NVL(ORIG_BURDENED_COST_YTD,0) +
                                  NVL(V_Orig_Burdened_Cost_ytd,0),
         ORIG_BURDENED_COST_PTD = NVL(ORIG_BURDENED_COST_PTD,0) +
                                  NVL(V_Orig_Burdened_Cost_ptd,0),
         ORIG_BURDENED_COST_PP  = NVL(ORIG_BURDENED_COST_PP,0)  +
                                  NVL(V_Orig_Burdened_Cost_pp,0),
         BASE_LABOR_HOURS_ITD   = NVL(BASE_LABOR_HOURS_ITD,0) +
				  NVL(V_Base_Labor_Hours_itd,0),
         BASE_LABOR_HOURS_YTD   = NVL(BASE_LABOR_HOURS_YTD,0) +
				  NVL(V_Base_Labor_Hours_ytd,0),
         BASE_LABOR_HOURS_PTD   = NVL(BASE_LABOR_HOURS_PTD,0) +
				  NVL(V_Base_Labor_Hours_ptd,0),
         BASE_LABOR_HOURS_PP    = NVL(BASE_LABOR_HOURS_PP,0)  +
				  NVL(V_Base_Labor_Hours_pp,0),
         ORIG_LABOR_HOURS_ITD   = NVL(ORIG_LABOR_HOURS_ITD,0) +
				  NVL(V_Orig_Labor_Hours_itd,0),
         ORIG_LABOR_HOURS_YTD   = NVL(ORIG_LABOR_HOURS_YTD,0) +
				  NVL(V_Orig_Labor_Hours_ytd,0),
         ORIG_LABOR_HOURS_PTD   = NVL(ORIG_LABOR_HOURS_PTD,0) +
				  NVL(V_Orig_Labor_Hours_ptd,0),
         ORIG_LABOR_HOURS_PP    = NVL(ORIG_LABOR_HOURS_PP,0)  +
				  NVL(V_Orig_Labor_Hours_pp,0),
         BASE_QUANTITY_ITD      = NVL(BASE_QUANTITY_ITD,0) +
				  NVL(V_Base_Quantity_itd,0),
         BASE_QUANTITY_YTD      = NVL(BASE_QUANTITY_YTD,0) +
				  NVL(V_Base_Quantity_ytd,0),
         BASE_QUANTITY_PTD      = NVL(BASE_QUANTITY_PTD,0) +
				  NVL(V_Base_Quantity_ptd,0),
         BASE_QUANTITY_PP       = NVL(BASE_QUANTITY_PP,0)  +
				  NVL(V_Base_Quantity_pp,0),
         ORIG_QUANTITY_ITD      = NVL(ORIG_QUANTITY_ITD,0) +
				  NVL(V_Orig_Quantity_itd,0),
         ORIG_QUANTITY_YTD      = NVL(ORIG_QUANTITY_YTD,0) +
				  NVL(V_Orig_Quantity_ytd,0),
         ORIG_QUANTITY_PTD      = NVL(ORIG_QUANTITY_PTD,0) +
				  NVL(V_Orig_Quantity_ptd,0),
         ORIG_QUANTITY_PP       = NVL(ORIG_QUANTITY_PP,0)  +
				  NVL(V_Orig_Quantity_pp,0),
         BASE_REVENUE_ITD       = NVL(BASE_REVENUE_ITD,0) +
				  NVL(V_Base_Revenue_itd,0),
         BASE_REVENUE_YTD       = NVL(BASE_REVENUE_YTD,0) +
				  NVL(V_Base_Revenue_ytd,0),
         BASE_REVENUE_PTD       = NVL(BASE_REVENUE_PTD,0) +
				  NVL(V_Base_Revenue_ptd,0),
         BASE_REVENUE_PP        = NVL(BASE_REVENUE_PP,0)  +
				  NVL(V_Base_Revenue_pp,0),
         ORIG_REVENUE_ITD       = NVL(ORIG_REVENUE_ITD,0) +
				  NVL(V_Orig_Revenue_itd,0),
         ORIG_REVENUE_YTD       = NVL(ORIG_REVENUE_YTD,0) +
				  NVL(V_Orig_Revenue_ytd,0),
         ORIG_REVENUE_PTD       = NVL(ORIG_REVENUE_PTD,0) +
				  NVL(V_Orig_Revenue_ptd,0),
         ORIG_REVENUE_PP        = NVL(ORIG_REVENUE_PP,0)  +
				  NVL(V_Orig_Revenue_pp,0),
         BASE_RAW_COST_TOT      = NVL(BASE_RAW_COST_TOT,0 ) +
                                  TOT_BASE_RAW_COST,
         BASE_BURDENED_COST_TOT = NVL(BASE_BURDENED_COST_TOT,0) +
                                  TOT_BASE_BURDENED_COST,
         ORIG_RAW_COST_TOT      = NVL(ORIG_RAW_COST_TOT,0) +
                                  TOT_ORIG_RAW_COST,
         ORIG_BURDENED_COST_TOT = NVL(ORIG_BURDENED_COST_TOT,0) +
                                  TOT_ORIG_BURDENED_COST,
         BASE_REVENUE_TOT       = NVL(BASE_REVENUE_TOT,0 ) +
                                  TOT_BASE_REVENUE,
         ORIG_REVENUE_TOT       = NVL(ORIG_REVENUE_TOT,0 ) +
                                  TOT_ORIG_REVENUE,
         BASE_LABOR_HOURS_TOT   = NVL(BASE_LABOR_HOURS_TOT,0) +
                                  TOT_BASE_LABOR_HOURS,
         ORIG_LABOR_HOURS_TOT   = NVL(ORIG_LABOR_HOURS_TOT,0 ) +
                                  TOT_ORIG_LABOR_HOURS,
         BASE_QUANTITY_TOT      = NVL(BASE_QUANTITY_TOT,0) +
                                  TOT_BASE_QUANTITY,
         ORIG_QUANTITY_TOT      = NVL(ORIG_QUANTITY_TOT,0) +
                                  TOT_ORIG_QUANTITY,
         BASE_UNIT_OF_MEASURE   = X_Base_Unit_of_Measure,
         ORIG_UNIT_OF_MEASURE   = X_Orig_Unit_of_Measure,
         LAST_UPDATED_BY        = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE       = Trunc(Sysdate),
         LAST_UPDATE_LOGIN      = pa_proj_accum_main.x_last_update_login,
         FIN_PLAN_TYPE_ID       = x_fin_plan_type_id
         Where Budget_Type_Code = x_Budget_type_code
         And PAB.Project_Accum_id = v_accum_id;

    if sql%notfound then
       Insert into PA_PROJECT_ACCUM_BUDGETS (
       PROJECT_ACCUM_ID,BUDGET_TYPE_CODE,BASE_RAW_COST_ITD,BASE_RAW_COST_YTD,
       BASE_RAW_COST_PP, BASE_RAW_COST_PTD,
       BASE_BURDENED_COST_ITD,BASE_BURDENED_COST_YTD,
       BASE_BURDENED_COST_PP,BASE_BURDENED_COST_PTD,
       ORIG_RAW_COST_ITD,ORIG_RAW_COST_YTD,
       ORIG_RAW_COST_PP, ORIG_RAW_COST_PTD,
       ORIG_BURDENED_COST_ITD,ORIG_BURDENED_COST_YTD,
       ORIG_BURDENED_COST_PP,ORIG_BURDENED_COST_PTD,
       BASE_QUANTITY_ITD,BASE_QUANTITY_YTD,BASE_QUANTITY_PP,
       BASE_QUANTITY_PTD,
       ORIG_QUANTITY_ITD,ORIG_QUANTITY_YTD,ORIG_QUANTITY_PP,
       ORIG_QUANTITY_PTD,
       BASE_LABOR_HOURS_ITD,BASE_LABOR_HOURS_YTD,BASE_LABOR_HOURS_PP,
       BASE_LABOR_HOURS_PTD,
       ORIG_LABOR_HOURS_ITD,ORIG_LABOR_HOURS_YTD,ORIG_LABOR_HOURS_PP,
       ORIG_LABOR_HOURS_PTD,
       BASE_REVENUE_ITD,BASE_REVENUE_YTD,BASE_REVENUE_PP,BASE_REVENUE_PTD,
       ORIG_REVENUE_ITD,ORIG_REVENUE_YTD,ORIG_REVENUE_PP,ORIG_REVENUE_PTD,
       BASE_UNIT_OF_MEASURE,ORIG_UNIT_OF_MEASURE,
       BASE_RAW_COST_TOT,BASE_BURDENED_COST_TOT,ORIG_RAW_COST_TOT,
       ORIG_BURDENED_COST_TOT,BASE_REVENUE_TOT,ORIG_REVENUE_TOT,
       BASE_LABOR_HOURS_TOT,ORIG_LABOR_HOURS_TOT,BASE_QUANTITY_TOT,
       ORIG_QUANTITY_TOT,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN,
       FIN_PLAN_TYPE_ID
       )
       Values
       (
       V_Accum_id,x_budget_type_code,
       V_BASE_RAW_COST_ITD,V_BASE_RAW_COST_YTD,
       V_BASE_RAW_COST_PP, V_BASE_RAW_COST_PTD,
       V_BASE_BURDENED_COST_ITD,V_BASE_BURDENED_COST_YTD,
       V_BASE_BURDENED_COST_PP,V_BASE_BURDENED_COST_PTD,
       V_ORIG_RAW_COST_ITD,V_ORIG_RAW_COST_YTD,
       V_ORIG_RAW_COST_PP, V_ORIG_RAW_COST_PTD,
       V_ORIG_BURDENED_COST_ITD,V_ORIG_BURDENED_COST_YTD,
       V_ORIG_BURDENED_COST_PP,V_ORIG_BURDENED_COST_PTD,
       V_BASE_QUANTITY_ITD,V_BASE_QUANTITY_YTD,V_BASE_QUANTITY_PP,
       V_BASE_QUANTITY_PTD,
       V_ORIG_QUANTITY_ITD,V_ORIG_QUANTITY_YTD,V_ORIG_QUANTITY_PP,
       V_ORIG_QUANTITY_PTD,
       V_BASE_LABOR_HOURS_ITD,V_BASE_LABOR_HOURS_YTD,V_BASE_LABOR_HOURS_PP,
       V_BASE_LABOR_HOURS_PTD,
       V_ORIG_LABOR_HOURS_ITD,V_ORIG_LABOR_HOURS_YTD,V_ORIG_LABOR_HOURS_PP,
       V_ORIG_LABOR_HOURS_PTD,
       V_BASE_REVENUE_ITD,V_BASE_REVENUE_YTD,V_BASE_REVENUE_PP,V_BASE_REVENUE_PTD,
       V_ORIG_REVENUE_ITD,V_ORIG_REVENUE_YTD,V_ORIG_REVENUE_PP,V_ORIG_REVENUE_PTD,
       X_BASE_UNIT_OF_MEASURE,X_ORIG_UNIT_OF_MEASURE,
       TOT_BASE_RAW_COST,TOT_BASE_BURDENED_COST,TOT_ORIG_RAW_COST,
       TOT_ORIG_BURDENED_COST,TOT_BASE_REVENUE,TOT_ORIG_REVENUE,
       TOT_BASE_LABOR_HOURS,TOT_ORIG_LABOR_HOURS,TOT_BASE_QUANTITY,
       TOT_ORIG_QUANTITY,
       pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
       Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login,
       x_fin_plan_type_id
        );
     end if;
  end if;
    x_recs_processed := Recs_processed;
--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
Exception
  When Others Then
       x_err_code := SQLCODE;
       RAISE;
End Process_all_buds;

--
--History:
--    	xx-xxx-xxxx     who?		- Created
--
--      26-SEP-2002	jwhite		- Converted to support both r11.5.7 Budget and FP models.
--                                        1) adapted code to include fin_plan_type_id.

Procedure   Process_all_tasks
                                (x_project_id 		   In Number,
                                 x_current_period          In varchar2,
                                 x_task_id 		   In Number,
                                 x_resource_list_id 	   In Number,
                                 x_resource_list_Member_id In Number,
                                 x_resource_id 		   In Number,
                                 x_resource_list_assignment_id In Number,
                                 x_rollup_qty_flag         In Varchar2,
                                 x_budget_type_code 	   In Varchar2,
                                 x_fin_plan_type_id        IN NUMBER,
                                 X_Base_Unit_Of_Measure    In Varchar2,
                                 X_Orig_Unit_Of_Measure    In Varchar2,
                                 X_Recs_processed 	   Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     	   In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     	   In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      	   In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895


Recs_processed         Number := 0;
V_Accum_id             Number := 0;
Res_Recs_processed     Number := 0;
x_pab                  Boolean := true;
V_Old_Stack       Varchar2(630);

Begin

      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_BUDGETS_RES.Process_all_tasks';

      pa_debug.debug(x_err_stack);

        x_pab := true;

-- The following Update statement updates all records in the given task
-- WBS hierarchy.It will update only the Project-task-resource combination
-- records and the Project-Resource level record(Task id = 0 and
-- Resourcelist member id <> 0)
    begin
        Select project_accum_id into V_Accum_id
          from pa_project_accum_headers
         where project_id = x_project_id
           and task_id = x_task_id
           and resource_list_member_id = x_resource_list_member_id;

    exception when no_data_found then
       Select PA_PROJECT_ACCUM_HEADERS_S.Nextval into V_Accum_id
       from sys.dual;
            Insert into PA_PROJECT_ACCUM_HEADERS
           (PROJECT_ACCUM_ID,PROJECT_ID,TASK_ID,ACCUM_PERIOD,RESOURCE_ID,
            RESOURCE_LIST_ID,RESOURCE_LIST_ASSIGNMENT_ID,
            RESOURCE_LIST_MEMBER_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,
            REQUEST_ID,CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN )
            Values (v_accum_id,X_project_id,x_task_id,
                    x_current_period,
                    x_resource_id,x_resource_list_id,
                    x_resource_list_assignment_id,x_resource_list_Member_id,
                    pa_proj_accum_main.x_last_updated_by,
                    Trunc(sysdate),pa_proj_accum_main.x_request_id,
                    trunc(sysdate),
                    pa_proj_accum_main.x_created_by,
                    pa_proj_accum_main.x_last_update_login );

       Insert into PA_PROJECT_ACCUM_BUDGETS (
       PROJECT_ACCUM_ID,BUDGET_TYPE_CODE,BASE_RAW_COST_ITD,BASE_RAW_COST_YTD,
       BASE_RAW_COST_PP, BASE_RAW_COST_PTD,
       BASE_BURDENED_COST_ITD,BASE_BURDENED_COST_YTD,
       BASE_BURDENED_COST_PP,BASE_BURDENED_COST_PTD,
       ORIG_RAW_COST_ITD,ORIG_RAW_COST_YTD,
       ORIG_RAW_COST_PP, ORIG_RAW_COST_PTD,
       ORIG_BURDENED_COST_ITD,ORIG_BURDENED_COST_YTD,
       ORIG_BURDENED_COST_PP,ORIG_BURDENED_COST_PTD,
       BASE_QUANTITY_ITD,BASE_QUANTITY_YTD,BASE_QUANTITY_PP,
       BASE_QUANTITY_PTD,
       ORIG_QUANTITY_ITD,ORIG_QUANTITY_YTD,ORIG_QUANTITY_PP,
       ORIG_QUANTITY_PTD,
       BASE_LABOR_HOURS_ITD,BASE_LABOR_HOURS_YTD,BASE_LABOR_HOURS_PP,
       BASE_LABOR_HOURS_PTD,
       ORIG_LABOR_HOURS_ITD,ORIG_LABOR_HOURS_YTD,ORIG_LABOR_HOURS_PP,
       ORIG_LABOR_HOURS_PTD,
       BASE_REVENUE_ITD,BASE_REVENUE_YTD,BASE_REVENUE_PP,BASE_REVENUE_PTD,
       ORIG_REVENUE_ITD,ORIG_REVENUE_YTD,ORIG_REVENUE_PP,ORIG_REVENUE_PTD,
       BASE_UNIT_OF_MEASURE,ORIG_UNIT_OF_MEASURE,
       BASE_RAW_COST_TOT,BASE_BURDENED_COST_TOT,ORIG_RAW_COST_TOT,
       ORIG_BURDENED_COST_TOT,BASE_REVENUE_TOT,ORIG_REVENUE_TOT,
       BASE_LABOR_HOURS_TOT,ORIG_LABOR_HOURS_TOT,BASE_QUANTITY_TOT,
       ORIG_QUANTITY_TOT,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN,
       FIN_PLAN_TYPE_ID
       )
       Values
       (
        V_Accum_id,x_budget_type_code,
       Tsk_BASE_RAW_COST_ITD,Tsk_BASE_RAW_COST_YTD,
       Tsk_BASE_RAW_COST_PP, Tsk_BASE_RAW_COST_PTD,
       Tsk_BASE_BURDENED_COST_ITD,Tsk_BASE_BURDENED_COST_YTD,
       Tsk_BASE_BURDENED_COST_PP,Tsk_BASE_BURDENED_COST_PTD,
       Tsk_ORIG_RAW_COST_ITD,Tsk_ORIG_RAW_COST_YTD,
       Tsk_ORIG_RAW_COST_PP, Tsk_ORIG_RAW_COST_PTD,
       Tsk_ORIG_BURDENED_COST_ITD,Tsk_ORIG_BURDENED_COST_YTD,
       Tsk_ORIG_BURDENED_COST_PP,Tsk_ORIG_BURDENED_COST_PTD,
       Tsk_BASE_QUANTITY_ITD,Tsk_BASE_QUANTITY_YTD,Tsk_BASE_QUANTITY_PP,
       Tsk_BASE_QUANTITY_PTD,
       Tsk_ORIG_QUANTITY_ITD,Tsk_ORIG_QUANTITY_YTD,Tsk_ORIG_QUANTITY_PP,
       Tsk_ORIG_QUANTITY_PTD,
       Tsk_BASE_LABOR_HOURS_ITD,Tsk_BASE_LABOR_HOURS_YTD,Tsk_BASE_LABOR_HOURS_PP,
       Tsk_BASE_LABOR_HOURS_PTD,
       Tsk_ORIG_LABOR_HOURS_ITD,Tsk_ORIG_LABOR_HOURS_YTD,Tsk_ORIG_LABOR_HOURS_PP,
       Tsk_ORIG_LABOR_HOURS_PTD,
       Tsk_BASE_REVENUE_ITD,Tsk_BASE_REVENUE_YTD,Tsk_BASE_REVENUE_PP,Tsk_BASE_REVENUE_PTD,
       Tsk_ORIG_REVENUE_ITD,Tsk_ORIG_REVENUE_YTD,Tsk_ORIG_REVENUE_PP,Tsk_ORIG_REVENUE_PTD,
       X_BASE_UNIT_OF_MEASURE,X_ORIG_UNIT_OF_MEASURE,
       Tsk_BASE_RAW_COST,Tsk_BASE_BURDENED_COST,Tsk_ORIG_RAW_COST,
       Tsk_ORIG_BURDENED_COST,Tsk_BASE_REVENUE,Tsk_ORIG_REVENUE,
       Tsk_BASE_LABOR_HOURS,Tsk_ORIG_LABOR_HOURS,Tsk_BASE_QUANTITY,
       Tsk_ORIG_QUANTITY,
       pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
       Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login,
       x_fin_plan_type_id
       );
       x_pab := false;
 end;
       If x_pab = true then
        Update PA_PROJECT_ACCUM_BUDGETS  PAB SET
         BASE_RAW_COST_ITD      = NVL(BASE_RAW_COST_ITD,0) +
				  NVL(Tsk_Base_Raw_Cost_itd,0),
         BASE_RAW_COST_YTD      = NVL(BASE_RAW_COST_YTD,0) +
				  NVL(Tsk_Base_Raw_Cost_ytd,0),
         BASE_RAW_COST_PTD      = NVL(BASE_RAW_COST_PTD,0) +
				  NVL(Tsk_Base_Raw_Cost_ptd,0),
         BASE_RAW_COST_PP       = NVL(BASE_RAW_COST_PP,0)  +
				  NVL(Tsk_Base_Raw_Cost_pp,0),
         ORIG_RAW_COST_ITD      = NVL(ORIG_RAW_COST_ITD,0) +
				  NVL(Tsk_Orig_Raw_Cost_itd,0),
         ORIG_RAW_COST_YTD      = NVL(ORIG_RAW_COST_YTD,0) +
				  NVL(Tsk_Orig_Raw_Cost_ytd,0),
         ORIG_RAW_COST_PTD      = NVL(ORIG_RAW_COST_PTD,0) +
				  NVL(Tsk_Orig_Raw_Cost_ptd,0),
         ORIG_RAW_COST_PP       = NVL(ORIG_RAW_COST_PP,0)  +
				  NVL(Tsk_Orig_Raw_Cost_pp,0),
         BASE_BURDENED_COST_ITD = NVL(BASE_BURDENED_COST_ITD,0) +
                                  NVL(Tsk_Base_Burdened_Cost_itd,0),
         BASE_BURDENED_COST_YTD = NVL(BASE_BURDENED_COST_YTD,0) +
                                  NVL(Tsk_Base_Burdened_Cost_ytd,0),
         BASE_BURDENED_COST_PTD = NVL(BASE_BURDENED_COST_PTD,0) +
                                  NVL(Tsk_Base_Burdened_Cost_ptd,0),
         BASE_BURDENED_COST_PP  = NVL(BASE_BURDENED_COST_PP,0)  +
                                  NVL(Tsk_Base_Burdened_Cost_pp,0),
         ORIG_BURDENED_COST_ITD = NVL(ORIG_BURDENED_COST_ITD,0) +
                                  NVL(Tsk_Orig_Burdened_Cost_itd,0),
         ORIG_BURDENED_COST_YTD = NVL(ORIG_BURDENED_COST_YTD,0) +
                                  NVL(Tsk_Orig_Burdened_Cost_ytd,0),
         ORIG_BURDENED_COST_PTD = NVL(ORIG_BURDENED_COST_PTD,0) +
                                  NVL(Tsk_Orig_Burdened_Cost_ptd,0),
         ORIG_BURDENED_COST_PP  = NVL(ORIG_BURDENED_COST_PP,0)  +
                                  NVL(Tsk_Orig_Burdened_Cost_pp,0),
         BASE_LABOR_HOURS_ITD   = NVL(BASE_LABOR_HOURS_ITD,0) +
				  NVL(Tsk_Base_Labor_Hours_itd,0),
         BASE_LABOR_HOURS_YTD   = NVL(BASE_LABOR_HOURS_YTD,0) +
				  NVL(Tsk_Base_Labor_Hours_ytd,0),
         BASE_LABOR_HOURS_PTD   = NVL(BASE_LABOR_HOURS_PTD,0) +
				  NVL(Tsk_Base_Labor_Hours_ptd,0),
         BASE_LABOR_HOURS_PP    = NVL(BASE_LABOR_HOURS_PP,0)  +
				  NVL(Tsk_Base_Labor_Hours_pp,0),
         ORIG_LABOR_HOURS_ITD   = NVL(ORIG_LABOR_HOURS_ITD,0) +
				  NVL(Tsk_Orig_Labor_Hours_itd,0),
         ORIG_LABOR_HOURS_YTD   = NVL(ORIG_LABOR_HOURS_YTD,0) +
				  NVL(Tsk_Orig_Labor_Hours_ytd,0),
         ORIG_LABOR_HOURS_PTD   = NVL(ORIG_LABOR_HOURS_PTD,0) +
				  NVL(Tsk_Orig_Labor_Hours_ptd,0),
         ORIG_LABOR_HOURS_PP    = NVL(ORIG_LABOR_HOURS_PP,0)  +
				  NVL(Tsk_Orig_Labor_Hours_pp,0),
         BASE_QUANTITY_ITD      = NVL(BASE_QUANTITY_ITD,0) +
				  NVL(Tsk_Base_Quantity_itd,0),
         BASE_QUANTITY_YTD      = NVL(BASE_QUANTITY_YTD,0) +
				  NVL(Tsk_Base_Quantity_ytd,0),
         BASE_QUANTITY_PTD      = NVL(BASE_QUANTITY_PTD,0) +
				  NVL(Tsk_Base_Quantity_ptd,0),
         BASE_QUANTITY_PP       = NVL(BASE_QUANTITY_PP,0)  +
				  NVL(Tsk_Base_Quantity_pp,0),
         ORIG_QUANTITY_ITD      = NVL(ORIG_QUANTITY_ITD,0) +
				  NVL(Tsk_Orig_Quantity_itd,0),
         ORIG_QUANTITY_YTD      = NVL(ORIG_QUANTITY_YTD,0) +
				  NVL(Tsk_Orig_Quantity_ytd,0),
         ORIG_QUANTITY_PTD      = NVL(ORIG_QUANTITY_PTD,0) +
				  NVL(Tsk_Orig_Quantity_ptd,0),
         ORIG_QUANTITY_PP       = NVL(ORIG_QUANTITY_PP,0)  +
				  NVL(Tsk_Orig_Quantity_pp,0),
         BASE_REVENUE_ITD       = NVL(BASE_REVENUE_ITD,0) +
				  NVL(Tsk_Base_Revenue_itd,0),
         BASE_REVENUE_YTD       = NVL(BASE_REVENUE_YTD,0) +
				  NVL(Tsk_Base_Revenue_ytd,0),
         BASE_REVENUE_PTD       = NVL(BASE_REVENUE_PTD,0) +
				  NVL(Tsk_Base_Revenue_ptd,0),
         BASE_REVENUE_PP        = NVL(BASE_REVENUE_PP,0)  +
				  NVL(Tsk_Base_Revenue_pp,0),
         ORIG_REVENUE_ITD       = NVL(ORIG_REVENUE_ITD,0) +
				  NVL(Tsk_Orig_Revenue_itd,0),
         ORIG_REVENUE_YTD       = NVL(ORIG_REVENUE_YTD,0) +
				  NVL(Tsk_Orig_Revenue_ytd,0),
         ORIG_REVENUE_PTD       = NVL(ORIG_REVENUE_PTD,0) +
				  NVL(Tsk_Orig_Revenue_ptd,0),
         ORIG_REVENUE_PP        = NVL(ORIG_REVENUE_PP,0)  +
				  NVL(Tsk_Orig_Revenue_pp,0),
         BASE_RAW_COST_TOT      = NVL(BASE_RAW_COST_TOT,0 ) +
                                  Tsk_BASE_RAW_COST,
         BASE_BURDENED_COST_TOT = NVL(BASE_BURDENED_COST_TOT,0) +
                                  Tsk_BASE_BURDENED_COST,
         ORIG_RAW_COST_TOT      = NVL(ORIG_RAW_COST_TOT,0) +
                                  Tsk_ORIG_RAW_COST,
         ORIG_BURDENED_COST_TOT = NVL(ORIG_BURDENED_COST_TOT,0) +
                                  Tsk_ORIG_BURDENED_COST,
         BASE_REVENUE_TOT       = NVL(BASE_REVENUE_TOT,0 ) +
                                  Tsk_BASE_REVENUE,
         ORIG_REVENUE_TOT       = NVL(ORIG_REVENUE_TOT,0 ) +
                                  Tsk_ORIG_REVENUE,
         BASE_LABOR_HOURS_TOT   = NVL(BASE_LABOR_HOURS_TOT,0) +
                                  Tsk_BASE_LABOR_HOURS,
         ORIG_LABOR_HOURS_TOT   = NVL(ORIG_LABOR_HOURS_TOT,0 ) +
                                  Tsk_ORIG_LABOR_HOURS,
         BASE_QUANTITY_TOT      = NVL(BASE_QUANTITY_TOT,0) +
                                  Tsk_BASE_QUANTITY,
         ORIG_QUANTITY_TOT      = NVL(ORIG_QUANTITY_TOT,0) +
                                  Tsk_ORIG_QUANTITY,
         BASE_UNIT_OF_MEASURE   = X_Base_Unit_of_Measure,
         ORIG_UNIT_OF_MEASURE   = X_Orig_Unit_of_Measure,
         LAST_UPDATED_BY        = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE       = Trunc(Sysdate),
         LAST_UPDATE_LOGIN      = pa_proj_accum_main.x_last_update_login,
         FIN_PLAN_TYPE_ID       = x_fin_plan_type_id
         Where Budget_Type_Code = x_Budget_type_code
         And PAB.Project_Accum_id = v_accum_id;

    if sql%notfound then
       Insert into PA_PROJECT_ACCUM_BUDGETS (
       PROJECT_ACCUM_ID,BUDGET_TYPE_CODE,BASE_RAW_COST_ITD,BASE_RAW_COST_YTD,
       BASE_RAW_COST_PP, BASE_RAW_COST_PTD,
       BASE_BURDENED_COST_ITD,BASE_BURDENED_COST_YTD,
       BASE_BURDENED_COST_PP,BASE_BURDENED_COST_PTD,
       ORIG_RAW_COST_ITD,ORIG_RAW_COST_YTD,
       ORIG_RAW_COST_PP, ORIG_RAW_COST_PTD,
       ORIG_BURDENED_COST_ITD,ORIG_BURDENED_COST_YTD,
       ORIG_BURDENED_COST_PP,ORIG_BURDENED_COST_PTD,
       BASE_QUANTITY_ITD,BASE_QUANTITY_YTD,BASE_QUANTITY_PP,
       BASE_QUANTITY_PTD,
       ORIG_QUANTITY_ITD,ORIG_QUANTITY_YTD,ORIG_QUANTITY_PP,
       ORIG_QUANTITY_PTD,
       BASE_LABOR_HOURS_ITD,BASE_LABOR_HOURS_YTD,BASE_LABOR_HOURS_PP,
       BASE_LABOR_HOURS_PTD,
       ORIG_LABOR_HOURS_ITD,ORIG_LABOR_HOURS_YTD,ORIG_LABOR_HOURS_PP,
       ORIG_LABOR_HOURS_PTD,
       BASE_REVENUE_ITD,BASE_REVENUE_YTD,BASE_REVENUE_PP,BASE_REVENUE_PTD,
       ORIG_REVENUE_ITD,ORIG_REVENUE_YTD,ORIG_REVENUE_PP,ORIG_REVENUE_PTD,
       BASE_UNIT_OF_MEASURE,ORIG_UNIT_OF_MEASURE,
       BASE_RAW_COST_TOT,BASE_BURDENED_COST_TOT,ORIG_RAW_COST_TOT,
       ORIG_BURDENED_COST_TOT,BASE_REVENUE_TOT,ORIG_REVENUE_TOT,
       BASE_LABOR_HOURS_TOT,ORIG_LABOR_HOURS_TOT,BASE_QUANTITY_TOT,
       ORIG_QUANTITY_TOT,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN,
       FIN_PLAN_TYPE_ID
       )
       Values
       (
       V_Accum_id,x_budget_type_code,
       Tsk_BASE_RAW_COST_ITD,Tsk_BASE_RAW_COST_YTD,
       Tsk_BASE_RAW_COST_PP, Tsk_BASE_RAW_COST_PTD,
       Tsk_BASE_BURDENED_COST_ITD,Tsk_BASE_BURDENED_COST_YTD,
       Tsk_BASE_BURDENED_COST_PP,Tsk_BASE_BURDENED_COST_PTD,
       Tsk_ORIG_RAW_COST_ITD,Tsk_ORIG_RAW_COST_YTD,
       Tsk_ORIG_RAW_COST_PP, Tsk_ORIG_RAW_COST_PTD,
       Tsk_ORIG_BURDENED_COST_ITD,Tsk_ORIG_BURDENED_COST_YTD,
       Tsk_ORIG_BURDENED_COST_PP,Tsk_ORIG_BURDENED_COST_PTD,
       Tsk_BASE_QUANTITY_ITD,Tsk_BASE_QUANTITY_YTD,Tsk_BASE_QUANTITY_PP,
       Tsk_BASE_QUANTITY_PTD,
       Tsk_ORIG_QUANTITY_ITD,Tsk_ORIG_QUANTITY_YTD,Tsk_ORIG_QUANTITY_PP,
       Tsk_ORIG_QUANTITY_PTD,
       Tsk_BASE_LABOR_HOURS_ITD,Tsk_BASE_LABOR_HOURS_YTD,Tsk_BASE_LABOR_HOURS_PP,
       Tsk_BASE_LABOR_HOURS_PTD,
       Tsk_ORIG_LABOR_HOURS_ITD,Tsk_ORIG_LABOR_HOURS_YTD,Tsk_ORIG_LABOR_HOURS_PP,
       Tsk_ORIG_LABOR_HOURS_PTD,
       Tsk_BASE_REVENUE_ITD,Tsk_BASE_REVENUE_YTD,Tsk_BASE_REVENUE_PP,Tsk_BASE_REVENUE_PTD,
       Tsk_ORIG_REVENUE_ITD,Tsk_ORIG_REVENUE_YTD,Tsk_ORIG_REVENUE_PP,Tsk_ORIG_REVENUE_PTD,
       X_BASE_UNIT_OF_MEASURE,X_ORIG_UNIT_OF_MEASURE,
       Tsk_BASE_RAW_COST,Tsk_BASE_BURDENED_COST,Tsk_ORIG_RAW_COST,
       Tsk_ORIG_BURDENED_COST,Tsk_BASE_REVENUE,Tsk_ORIG_REVENUE,
       Tsk_BASE_LABOR_HOURS,Tsk_ORIG_LABOR_HOURS,Tsk_BASE_QUANTITY,
       Tsk_ORIG_QUANTITY,
       pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
       Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login,
       x_fin_plan_type_id
       );
     end if;
  end if;
    x_recs_processed := Recs_processed;
--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
Exception
  When Others Then
       x_err_code := SQLCODE;
       RAISE;
End Process_all_tasks;

--
--History:
--    	xx-xxx-xxxx     who?		- Created
--
--      26-SEP-2002	jwhite		- Converted to support both r11.5.7 Budget and FP models.
--                                        1) adapted code to include fin_plan_type_id.

Procedure   Process_bud_code
                                (x_project_id 		   In Number,
                                 x_current_period          In varchar2,
                                 x_task_id 		   In Number,
                                 x_resource_list_id 	   In Number,
                                 x_resource_list_Member_id In Number,
                                 x_resource_id 		   In Number,
                                 x_resource_list_assignment_id In Number,
                                 x_rollup_qty_flag         In Varchar2,
                                 x_budget_type_code 	   In Varchar2,
                                 x_fin_plan_type_id        IN NUMBER,
                                 X_Base_Unit_Of_Measure    In Varchar2,
                                 X_Orig_Unit_Of_Measure    In Varchar2,
                                 X_Recs_processed 	   Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     	   In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     	   In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      	   In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

Recs_processed         Number := 0;
V_Accum_id             Number := 0;
Res_Recs_processed     Number := 0;
x_pab                  Boolean := true;
V_Old_Stack       Varchar2(630);

Begin

      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_BUDGETS_RES.Process_bud_code';

      pa_debug.debug(x_err_stack);

        x_pab := true;

-- The following Update statement updates all records in the given task
-- WBS hierarchy.It will update only the Project-task-resource combination
-- records and the Project-Resource level record(Task id = 0 and
-- Resourcelist member id <> 0)
    begin
        Select project_accum_id into V_Accum_id
          from pa_project_accum_headers
         where project_id = x_project_id
           and task_id = x_task_id
           and resource_list_member_id = x_resource_list_member_id;

    exception when no_data_found then
       Select PA_PROJECT_ACCUM_HEADERS_S.Nextval into V_Accum_id
       from sys.dual;
            Insert into PA_PROJECT_ACCUM_HEADERS
           (PROJECT_ACCUM_ID,PROJECT_ID,TASK_ID,ACCUM_PERIOD,RESOURCE_ID,
            RESOURCE_LIST_ID,RESOURCE_LIST_ASSIGNMENT_ID,
            RESOURCE_LIST_MEMBER_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,
            REQUEST_ID,CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN )
            Values (v_accum_id,X_project_id,x_task_id,
                    x_current_period,
                    x_resource_id,x_resource_list_id,
                    x_resource_list_assignment_id,x_resource_list_Member_id,
                    pa_proj_accum_main.x_last_updated_by,
                    Trunc(sysdate),pa_proj_accum_main.x_request_id,
                    trunc(sysdate),
                    pa_proj_accum_main.x_created_by,
                    pa_proj_accum_main.x_last_update_login );

       Insert into PA_PROJECT_ACCUM_BUDGETS (
       PROJECT_ACCUM_ID,BUDGET_TYPE_CODE,BASE_RAW_COST_ITD,BASE_RAW_COST_YTD,
       BASE_RAW_COST_PP, BASE_RAW_COST_PTD,
       BASE_BURDENED_COST_ITD,BASE_BURDENED_COST_YTD,
       BASE_BURDENED_COST_PP,BASE_BURDENED_COST_PTD,
       ORIG_RAW_COST_ITD,ORIG_RAW_COST_YTD,
       ORIG_RAW_COST_PP, ORIG_RAW_COST_PTD,
       ORIG_BURDENED_COST_ITD,ORIG_BURDENED_COST_YTD,
       ORIG_BURDENED_COST_PP,ORIG_BURDENED_COST_PTD,
       BASE_QUANTITY_ITD,BASE_QUANTITY_YTD,BASE_QUANTITY_PP,
       BASE_QUANTITY_PTD,
       ORIG_QUANTITY_ITD,ORIG_QUANTITY_YTD,ORIG_QUANTITY_PP,
       ORIG_QUANTITY_PTD,
       BASE_LABOR_HOURS_ITD,BASE_LABOR_HOURS_YTD,BASE_LABOR_HOURS_PP,
       BASE_LABOR_HOURS_PTD,
       ORIG_LABOR_HOURS_ITD,ORIG_LABOR_HOURS_YTD,ORIG_LABOR_HOURS_PP,
       ORIG_LABOR_HOURS_PTD,
       BASE_REVENUE_ITD,BASE_REVENUE_YTD,BASE_REVENUE_PP,BASE_REVENUE_PTD,
       ORIG_REVENUE_ITD,ORIG_REVENUE_YTD,ORIG_REVENUE_PP,ORIG_REVENUE_PTD,
       BASE_UNIT_OF_MEASURE,ORIG_UNIT_OF_MEASURE,
       BASE_RAW_COST_TOT,BASE_BURDENED_COST_TOT,ORIG_RAW_COST_TOT,
       ORIG_BURDENED_COST_TOT,BASE_REVENUE_TOT,ORIG_REVENUE_TOT,
       BASE_LABOR_HOURS_TOT,ORIG_LABOR_HOURS_TOT,BASE_QUANTITY_TOT,
       ORIG_QUANTITY_TOT,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN,
       FIN_PLAN_TYPE_ID
       )
       Values
       (
        V_Accum_id,x_budget_type_code,
       Prj_BASE_RAW_COST_ITD,Prj_BASE_RAW_COST_YTD,
       Prj_BASE_RAW_COST_PP, Prj_BASE_RAW_COST_PTD,
       Prj_BASE_BURDENED_COST_ITD,Prj_BASE_BURDENED_COST_YTD,
       Prj_BASE_BURDENED_COST_PP,Prj_BASE_BURDENED_COST_PTD,
       Prj_ORIG_RAW_COST_ITD,Prj_ORIG_RAW_COST_YTD,
       Prj_ORIG_RAW_COST_PP, Prj_ORIG_RAW_COST_PTD,
       Prj_ORIG_BURDENED_COST_ITD,Prj_ORIG_BURDENED_COST_YTD,
       Prj_ORIG_BURDENED_COST_PP,Prj_ORIG_BURDENED_COST_PTD,
       Prj_BASE_QUANTITY_ITD,Prj_BASE_QUANTITY_YTD,Prj_BASE_QUANTITY_PP,
       Prj_BASE_QUANTITY_PTD,
       Prj_ORIG_QUANTITY_ITD,Prj_ORIG_QUANTITY_YTD,Prj_ORIG_QUANTITY_PP,
       Prj_ORIG_QUANTITY_PTD,
       Prj_BASE_LABOR_HOURS_ITD,Prj_BASE_LABOR_HOURS_YTD,Prj_BASE_LABOR_HOURS_PP,
       Prj_BASE_LABOR_HOURS_PTD,
       Prj_ORIG_LABOR_HOURS_ITD,Prj_ORIG_LABOR_HOURS_YTD,Prj_ORIG_LABOR_HOURS_PP,
       Prj_ORIG_LABOR_HOURS_PTD,
       Prj_BASE_REVENUE_ITD,Prj_BASE_REVENUE_YTD,Prj_BASE_REVENUE_PP,Prj_BASE_REVENUE_PTD,
       Prj_ORIG_REVENUE_ITD,Prj_ORIG_REVENUE_YTD,Prj_ORIG_REVENUE_PP,Prj_ORIG_REVENUE_PTD,
       X_BASE_UNIT_OF_MEASURE,X_ORIG_UNIT_OF_MEASURE,
       Prj_BASE_RAW_COST,Prj_BASE_BURDENED_COST,Prj_ORIG_RAW_COST,
       Prj_ORIG_BURDENED_COST,Prj_BASE_REVENUE,Prj_ORIG_REVENUE,
       Prj_BASE_LABOR_HOURS,Prj_ORIG_LABOR_HOURS,Prj_BASE_QUANTITY,
       Prj_ORIG_QUANTITY,
       pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
       Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login,
       x_fin_plan_type_id
       );
       x_pab := false;
 end;
       If x_pab = true then
        Update PA_PROJECT_ACCUM_BUDGETS  PAB SET
         BASE_RAW_COST_ITD      = NVL(BASE_RAW_COST_ITD,0) +
				  NVL(Prj_Base_Raw_Cost_itd,0),
         BASE_RAW_COST_YTD      = NVL(BASE_RAW_COST_YTD,0) +
				  NVL(Prj_Base_Raw_Cost_ytd,0),
         BASE_RAW_COST_PTD      = NVL(BASE_RAW_COST_PTD,0) +
				  NVL(Prj_Base_Raw_Cost_ptd,0),
         BASE_RAW_COST_PP       = NVL(BASE_RAW_COST_PP,0)  +
				  NVL(Prj_Base_Raw_Cost_pp,0),
         ORIG_RAW_COST_ITD      = NVL(ORIG_RAW_COST_ITD,0) +
				  NVL(Prj_Orig_Raw_Cost_itd,0),
         ORIG_RAW_COST_YTD      = NVL(ORIG_RAW_COST_YTD,0) +
				  NVL(Prj_Orig_Raw_Cost_ytd,0),
         ORIG_RAW_COST_PTD      = NVL(ORIG_RAW_COST_PTD,0) +
				  NVL(Prj_Orig_Raw_Cost_ptd,0),
         ORIG_RAW_COST_PP       = NVL(ORIG_RAW_COST_PP,0)  +
				  NVL(Prj_Orig_Raw_Cost_pp,0),
         BASE_BURDENED_COST_ITD = NVL(BASE_BURDENED_COST_ITD,0) +
                                  NVL(Prj_Base_Burdened_Cost_itd,0),
         BASE_BURDENED_COST_YTD = NVL(BASE_BURDENED_COST_YTD,0) +
                                  NVL(Prj_Base_Burdened_Cost_ytd,0),
         BASE_BURDENED_COST_PTD = NVL(BASE_BURDENED_COST_PTD,0) +
                                  NVL(Prj_Base_Burdened_Cost_ptd,0),
         BASE_BURDENED_COST_PP  = NVL(BASE_BURDENED_COST_PP,0)  +
                                  NVL(Prj_Base_Burdened_Cost_pp,0),
         ORIG_BURDENED_COST_ITD = NVL(ORIG_BURDENED_COST_ITD,0) +
                                  NVL(Prj_Orig_Burdened_Cost_itd,0),
         ORIG_BURDENED_COST_YTD = NVL(ORIG_BURDENED_COST_YTD,0) +
                                  NVL(Prj_Orig_Burdened_Cost_ytd,0),
         ORIG_BURDENED_COST_PTD = NVL(ORIG_BURDENED_COST_PTD,0) +
                                  NVL(Prj_Orig_Burdened_Cost_ptd,0),
         ORIG_BURDENED_COST_PP  = NVL(ORIG_BURDENED_COST_PP,0)  +
                                  NVL(Prj_Orig_Burdened_Cost_pp,0),
         BASE_LABOR_HOURS_ITD   = NVL(BASE_LABOR_HOURS_ITD,0) +
				  NVL(Prj_Base_Labor_Hours_itd,0),
         BASE_LABOR_HOURS_YTD   = NVL(BASE_LABOR_HOURS_YTD,0) +
				  NVL(Prj_Base_Labor_Hours_ytd,0),
         BASE_LABOR_HOURS_PTD   = NVL(BASE_LABOR_HOURS_PTD,0) +
				  NVL(Prj_Base_Labor_Hours_ptd,0),
         BASE_LABOR_HOURS_PP    = NVL(BASE_LABOR_HOURS_PP,0)  +
				  NVL(Prj_Base_Labor_Hours_pp,0),
         ORIG_LABOR_HOURS_ITD   = NVL(ORIG_LABOR_HOURS_ITD,0) +
				  NVL(Prj_Orig_Labor_Hours_itd,0),
         ORIG_LABOR_HOURS_YTD   = NVL(ORIG_LABOR_HOURS_YTD,0) +
				  NVL(Prj_Orig_Labor_Hours_ytd,0),
         ORIG_LABOR_HOURS_PTD   = NVL(ORIG_LABOR_HOURS_PTD,0) +
				  NVL(Prj_Orig_Labor_Hours_ptd,0),
         ORIG_LABOR_HOURS_PP    = NVL(ORIG_LABOR_HOURS_PP,0)  +
				  NVL(Prj_Orig_Labor_Hours_pp,0),
         BASE_QUANTITY_ITD      = NVL(BASE_QUANTITY_ITD,0) +
				  NVL(Prj_Base_Quantity_itd,0),
         BASE_QUANTITY_YTD      = NVL(BASE_QUANTITY_YTD,0) +
				  NVL(Prj_Base_Quantity_ytd,0),
         BASE_QUANTITY_PTD      = NVL(BASE_QUANTITY_PTD,0) +
				  NVL(Prj_Base_Quantity_ptd,0),
         BASE_QUANTITY_PP       = NVL(BASE_QUANTITY_PP,0)  +
				  NVL(Prj_Base_Quantity_pp,0),
         ORIG_QUANTITY_ITD      = NVL(ORIG_QUANTITY_ITD,0) +
				  NVL(Prj_Orig_Quantity_itd,0),
         ORIG_QUANTITY_YTD      = NVL(ORIG_QUANTITY_YTD,0) +
				  NVL(Prj_Orig_Quantity_ytd,0),
         ORIG_QUANTITY_PTD      = NVL(ORIG_QUANTITY_PTD,0) +
				  NVL(Prj_Orig_Quantity_ptd,0),
         ORIG_QUANTITY_PP       = NVL(ORIG_QUANTITY_PP,0)  +
				  NVL(Prj_Orig_Quantity_pp,0),
         BASE_REVENUE_ITD       = NVL(BASE_REVENUE_ITD,0) +
				  NVL(Prj_Base_Revenue_itd,0),
         BASE_REVENUE_YTD       = NVL(BASE_REVENUE_YTD,0) +
				  NVL(Prj_Base_Revenue_ytd,0),
         BASE_REVENUE_PTD       = NVL(BASE_REVENUE_PTD,0) +
				  NVL(Prj_Base_Revenue_ptd,0),
         BASE_REVENUE_PP        = NVL(BASE_REVENUE_PP,0)  +
				  NVL(Prj_Base_Revenue_pp,0),
         ORIG_REVENUE_ITD       = NVL(ORIG_REVENUE_ITD,0) +
				  NVL(Prj_Orig_Revenue_itd,0),
         ORIG_REVENUE_YTD       = NVL(ORIG_REVENUE_YTD,0) +
				  NVL(Prj_Orig_Revenue_ytd,0),
         ORIG_REVENUE_PTD       = NVL(ORIG_REVENUE_PTD,0) +
				  NVL(Prj_Orig_Revenue_ptd,0),
         ORIG_REVENUE_PP        = NVL(ORIG_REVENUE_PP,0)  +
				  NVL(Prj_Orig_Revenue_pp,0),
         BASE_RAW_COST_TOT      = NVL(BASE_RAW_COST_TOT,0 ) +
                                  Prj_BASE_RAW_COST,
         BASE_BURDENED_COST_TOT = NVL(BASE_BURDENED_COST_TOT,0) +
                                  Prj_BASE_BURDENED_COST,
         ORIG_RAW_COST_TOT      = NVL(ORIG_RAW_COST_TOT,0) +
                                  Prj_ORIG_RAW_COST,
         ORIG_BURDENED_COST_TOT = NVL(ORIG_BURDENED_COST_TOT,0) +
                                  Prj_ORIG_BURDENED_COST,
         BASE_REVENUE_TOT       = NVL(BASE_REVENUE_TOT,0 ) +
                                  Prj_BASE_REVENUE,
         ORIG_REVENUE_TOT       = NVL(ORIG_REVENUE_TOT,0 ) +
                                  Prj_ORIG_REVENUE,
         BASE_LABOR_HOURS_TOT   = NVL(BASE_LABOR_HOURS_TOT,0) +
                                  Prj_BASE_LABOR_HOURS,
         ORIG_LABOR_HOURS_TOT   = NVL(ORIG_LABOR_HOURS_TOT,0 ) +
                                  Prj_ORIG_LABOR_HOURS,
         BASE_QUANTITY_TOT      = NVL(BASE_QUANTITY_TOT,0) +
                                  Prj_BASE_QUANTITY,
         ORIG_QUANTITY_TOT      = NVL(ORIG_QUANTITY_TOT,0) +
                                  Prj_ORIG_QUANTITY,
         BASE_UNIT_OF_MEASURE   = X_Base_Unit_of_Measure,
         ORIG_UNIT_OF_MEASURE   = X_Orig_Unit_of_Measure,
         LAST_UPDATED_BY        = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE       = Trunc(Sysdate),
         LAST_UPDATE_LOGIN      = pa_proj_accum_main.x_last_update_login,
         FIN_PLAN_TYPE_ID       = x_fin_plan_type_id
         Where Budget_Type_Code = x_Budget_type_code
         And PAB.Project_Accum_id = v_accum_id;

    if sql%notfound then
       Insert into PA_PROJECT_ACCUM_BUDGETS (
       PROJECT_ACCUM_ID,BUDGET_TYPE_CODE,BASE_RAW_COST_ITD,BASE_RAW_COST_YTD,
       BASE_RAW_COST_PP, BASE_RAW_COST_PTD,
       BASE_BURDENED_COST_ITD,BASE_BURDENED_COST_YTD,
       BASE_BURDENED_COST_PP,BASE_BURDENED_COST_PTD,
       ORIG_RAW_COST_ITD,ORIG_RAW_COST_YTD,
       ORIG_RAW_COST_PP, ORIG_RAW_COST_PTD,
       ORIG_BURDENED_COST_ITD,ORIG_BURDENED_COST_YTD,
       ORIG_BURDENED_COST_PP,ORIG_BURDENED_COST_PTD,
       BASE_QUANTITY_ITD,BASE_QUANTITY_YTD,BASE_QUANTITY_PP,
       BASE_QUANTITY_PTD,
       ORIG_QUANTITY_ITD,ORIG_QUANTITY_YTD,ORIG_QUANTITY_PP,
       ORIG_QUANTITY_PTD,
       BASE_LABOR_HOURS_ITD,BASE_LABOR_HOURS_YTD,BASE_LABOR_HOURS_PP,
       BASE_LABOR_HOURS_PTD,
       ORIG_LABOR_HOURS_ITD,ORIG_LABOR_HOURS_YTD,ORIG_LABOR_HOURS_PP,
       ORIG_LABOR_HOURS_PTD,
       BASE_REVENUE_ITD,BASE_REVENUE_YTD,BASE_REVENUE_PP,BASE_REVENUE_PTD,
       ORIG_REVENUE_ITD,ORIG_REVENUE_YTD,ORIG_REVENUE_PP,ORIG_REVENUE_PTD,
       BASE_UNIT_OF_MEASURE,ORIG_UNIT_OF_MEASURE,
       BASE_RAW_COST_TOT,BASE_BURDENED_COST_TOT,ORIG_RAW_COST_TOT,
       ORIG_BURDENED_COST_TOT,BASE_REVENUE_TOT,ORIG_REVENUE_TOT,
       BASE_LABOR_HOURS_TOT,ORIG_LABOR_HOURS_TOT,BASE_QUANTITY_TOT,
       ORIG_QUANTITY_TOT,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN,
       FIN_PLAN_TYPE_ID
       )
        Values
       (
       V_Accum_id,x_budget_type_code,
       Prj_BASE_RAW_COST_ITD,Prj_BASE_RAW_COST_YTD,
       Prj_BASE_RAW_COST_PP, Prj_BASE_RAW_COST_PTD,
       Prj_BASE_BURDENED_COST_ITD,Prj_BASE_BURDENED_COST_YTD,
       Prj_BASE_BURDENED_COST_PP,Prj_BASE_BURDENED_COST_PTD,
       Prj_ORIG_RAW_COST_ITD,Prj_ORIG_RAW_COST_YTD,
       Prj_ORIG_RAW_COST_PP, Prj_ORIG_RAW_COST_PTD,
       Prj_ORIG_BURDENED_COST_ITD,Prj_ORIG_BURDENED_COST_YTD,
       Prj_ORIG_BURDENED_COST_PP,Prj_ORIG_BURDENED_COST_PTD,
       Prj_BASE_QUANTITY_ITD,Prj_BASE_QUANTITY_YTD,Prj_BASE_QUANTITY_PP,
       Prj_BASE_QUANTITY_PTD,
       Prj_ORIG_QUANTITY_ITD,Prj_ORIG_QUANTITY_YTD,Prj_ORIG_QUANTITY_PP,
       Prj_ORIG_QUANTITY_PTD,
       Prj_BASE_LABOR_HOURS_ITD,Prj_BASE_LABOR_HOURS_YTD,Prj_BASE_LABOR_HOURS_PP,
       Prj_BASE_LABOR_HOURS_PTD,
       Prj_ORIG_LABOR_HOURS_ITD,Prj_ORIG_LABOR_HOURS_YTD,Prj_ORIG_LABOR_HOURS_PP,
       Prj_ORIG_LABOR_HOURS_PTD,
       Prj_BASE_REVENUE_ITD,Prj_BASE_REVENUE_YTD,Prj_BASE_REVENUE_PP,Prj_BASE_REVENUE_PTD,
       Prj_ORIG_REVENUE_ITD,Prj_ORIG_REVENUE_YTD,Prj_ORIG_REVENUE_PP,Prj_ORIG_REVENUE_PTD,
       X_BASE_UNIT_OF_MEASURE,X_ORIG_UNIT_OF_MEASURE,
       Prj_BASE_RAW_COST,Prj_BASE_BURDENED_COST,Prj_ORIG_RAW_COST,
       Prj_ORIG_BURDENED_COST,Prj_BASE_REVENUE,Prj_ORIG_REVENUE,
       Prj_BASE_LABOR_HOURS,Prj_ORIG_LABOR_HOURS,Prj_BASE_QUANTITY,
       Prj_ORIG_QUANTITY,
        pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login,
       x_fin_plan_type_id
       );
     end if;
  end if;
    x_recs_processed := Recs_processed;
--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
Exception
  When Others Then
       x_err_code := SQLCODE;
       RAISE;
End Process_bud_code;
----------------------------------------------------------
End PA_MAINT_PROJECT_BUDGETS;

/
