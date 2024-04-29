--------------------------------------------------------
--  DDL for Package Body PA_REFRESH_RES_LISTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_REFRESH_RES_LISTS" AS
/* $Header: PAACREFB.pls 120.1 2005/08/19 16:14:06 mwasowic noship $ */
TYPE resource_list_id_tabtype IS
TABLE OF PA_RESOURCE_LIST_ASSIGNMENTS.RESOURCE_LIST_ID%TYPE
INDEX BY BINARY_INTEGER;

-- Process_All_Res_Lists - This procedure accumulates the Actuals and
--                         Commitments for a given Resource lists for a Project

Procedure Process_Res_Lists     (x_project_id in Number,
				 x_resource_list_id In Number,
                                 x_current_period in Varchar2,
                                 x_prev_period    in Varchar2,
                                 x_current_year   in Number,
                                 x_current_start_date In Date,
                                 x_current_end_date  In Date,
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895


-- This Cursor fetches all Resource lists assigned to the project

CURSOR Reslist_assgmt_Cur IS
Select Distinct Resource_list_id
FROM
PA_RESOURCE_LIST_ASSIGNMENTS
Where Project_id = X_project_id
and resource_list_id = NVL(x_resource_list_id,resource_list_id);

  v_Res_accum_txn_accum_id Number := 0;
  v_Resource_list_id Number := 0;

-- This Cursor gets all Resources from the PA_RESOURCE_ACCUM_DETAILS
-- pertaining to the Resource list

CURSOR Res_accum_Cur IS
Select
  Para.RESOURCE_LIST_ASSIGNMENT_ID,
  Para.RESOURCE_LIST_ID,
  Para.RESOURCE_LIST_MEMBER_ID,
  Para.RESOURCE_ID,
  Parl.TRACK_AS_LABOR_FLAG,
  Par.ROLLUP_QUANTITY_FLAG,
  Par.UNIT_OF_MEASURE
  from
  PA_RESOURCE_ACCUM_DETAILS Para,
  PA_RESOURCES Par,
  PA_RESOURCE_LIST_MEMBERS Parl
Where Para.Txn_Accum_id = v_Res_accum_txn_accum_id and
      Para.Resource_list_id = v_Resource_list_id and
      Para.Resource_list_id = Parl.Resource_list_id and
      Para.Resource_list_member_id = Parl.Resource_list_member_id and
      nvl(parl.migration_code,'-99') <> 'N' and
      Para.Resource_id  = Par.Resource_Id ;

-- This cursor reads all transactions from the PA_TXN_ACCUM

CURSOR All_PA_Txn_Accum_Cur is
SELECT DISTINCT
  PTA.TXN_ACCUM_ID,
  PTA.TASK_ID,
  PTA.PA_PERIOD,
  PTA.GL_PERIOD,
  NVL(PTA.TOT_REVENUE,0) TOT_REVENUE ,
  NVL(PTA.TOT_RAW_COST,0) TOT_RAW_COST ,
  NVL(PTA.TOT_BURDENED_COST,0) TOT_BURDENED_COST,
  NVL(PTA.TOT_QUANTITY,0) TOT_QUANTITY ,
  NVL(PTA.TOT_LABOR_HOURS,0) TOT_LABOR_HOURS,
  NVL(PTA.TOT_BILLABLE_RAW_COST,0) TOT_BILLABLE_RAW_COST,
  NVL(PTA.TOT_BILLABLE_BURDENED_COST,0) TOT_BILLABLE_BURDENED_COST,
  NVL(PTA.TOT_BILLABLE_QUANTITY,0) TOT_BILLABLE_QUANTITY,
  NVL(PTA.TOT_BILLABLE_LABOR_HOURS,0) TOT_BILLABLE_LABOR_HOURS,
  NVL(PTA.TOT_CMT_RAW_COST,0) TOT_CMT_RAW_COST,
  NVL(PTA.TOT_CMT_BURDENED_COST,0) TOT_CMT_BURDENED_COST,
  NVL(PTA.TOT_CMT_QUANTITY,0) TOT_CMT_QUANTITY,
  PAP.PERIOD_YEAR
  FROM
  PA_TXN_ACCUM PTA,
  PA_PERIODS_V PAP
  WHERE PTA.Project_Id = x_project_id
  AND PTA.PA_PERIOD = PAP.PERIOD_NAME
  AND PAP.PA_END_DATE <= x_current_end_date;

  x_resource_list_array resource_list_id_tabtype;
  x_res_list_rec Reslist_assgmt_Cur%ROWTYPE;
  x_all_txn_accum_rec All_PA_Txn_Accum_Cur%ROWTYPE;
  x_res_accum_rec Res_accum_Cur%ROWTYPE;
  v_err_code Number := 0;
  x_recs_processed number := 0;
  tot_recs_processed Number := 0;
  No_of_res_lists    Number := 0;
  x_quantity         NUMBER :=0;
  x_billable_quantity NUMBER :=0;
  V_Old_Stack       Varchar2(630);

Begin

   V_Old_Stack := x_err_stack;
  x_err_stack :=
  x_err_stack ||'->PA_REFRESH_RES_LISTS.Process_All_Res_Lists';
  pa_debug.debug(x_err_stack);

-- Fetch all resource lists assigned to the project

  FOR x_res_list_rec IN Reslist_assgmt_Cur LOOP
     No_of_res_lists := No_of_res_lists + 1;
        x_resource_list_array(No_of_res_lists) :=
        x_res_list_rec.Resource_list_id;
  END LOOP;

  IF No_of_res_lists > 0 Then  -- (IF #1)

-- Read All txn_accum records and process Actuals as well as Commitments

    FOR x_all_txn_accum_rec IN All_PA_Txn_Accum_Cur LOOP
     v_Res_accum_txn_accum_id := x_all_txn_accum_rec.Txn_Accum_Id;
     FOR i in 1..No_of_res_lists LOOP
         v_resource_list_id := x_resource_list_array(i);
-- Fetch the Resource Accum records

      FOR  Res_Accum_rec in Res_accum_Cur LOOP

           pa_maint_project_accums.create_accum_actuals_res
                                (x_project_id,
                                 x_all_txn_accum_rec.task_id,
                                 Res_Accum_Rec.resource_list_id ,
                                 Res_Accum_Rec.resource_list_Member_id ,
                                 Res_Accum_Rec.resource_id ,
                                 Res_Accum_Rec.resource_list_assignment_id ,
                                 x_current_period,
                                 x_Recs_processed,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code);
           IF ( Res_Accum_Rec.rollup_Quantity_flag = 'Y') THEN
              x_quantity := x_all_txn_accum_rec.TOT_QUANTITY;
              x_billable_quantity := x_all_txn_accum_rec.TOT_BILLABLE_QUANTITY;
           ELSE
              x_quantity := 0;
              x_billable_quantity :=0;
           END IF;

    --   Fetched period = current period
    --  (Update only ITD,YTD and PTD figures)-Task level figures with resources
    --  and Project-Resources  - ACTUALS

           IF (x_all_txn_accum_rec.PA_PERIOD =  x_current_period ) or --(IF #2)
              (x_all_txn_accum_rec.GL_PERIOD = x_current_period ) Then

                   PA_PROCESS_ACCUM_ACTUALS_RES.Process_it_yt_pt_res
                                (x_project_id,
                                 x_all_txn_accum_rec.task_id,
                                 Res_Accum_Rec.resource_list_id ,
                                 Res_Accum_Rec.resource_list_Member_id ,
                                 Res_Accum_Rec.resource_id ,
                                 Res_Accum_Rec.resource_list_assignment_id ,
                                 Res_Accum_Rec.track_as_labor_flag ,
                                 Res_Accum_Rec.rollup_Quantity_flag ,
                                 Res_Accum_Rec.unit_of_measure ,
                                 x_current_period ,
                                 x_all_txn_accum_rec.TOT_REVENUE,
                                 x_all_txn_accum_rec.TOT_RAW_COST,
                                 x_all_txn_accum_rec.TOT_BURDENED_COST,
                                 x_all_txn_accum_rec.TOT_LABOR_HOURS,
				 x_quantity,
				 x_billable_quantity,
                                 x_all_txn_accum_rec.TOT_BILLABLE_RAW_COST,
                                 x_all_txn_accum_rec.TOT_BILLABLE_BURDENED_COST,
                                 x_all_txn_accum_rec.TOT_BILLABLE_LABOR_HOURS,
		                 'Y',  -- x_actual_cost_flag
                                 'Y',  -- x_revenue_flag
                                 X_Recs_processed ,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code);
                   tot_recs_processed := tot_recs_processed + x_recs_processed;

    --   Fetched period = current period
    --  (Update only ITD,YTD and PTD figures)-Task level figures with resources
    --  and Project-Resources  - COMMITMENTS

                   PA_PROCESS_ACCUM_CMT_RES.Process_it_yt_pt_cmt_res
                                (x_project_id,
                                 x_all_txn_accum_rec.task_id,
                                 Res_Accum_Rec.resource_list_id ,
                                 Res_Accum_Rec.resource_list_Member_id ,
                                 Res_Accum_Rec.resource_id ,
                                 Res_Accum_Rec.resource_list_assignment_id ,
                                 Res_Accum_Rec.track_as_labor_flag ,
                                 Res_Accum_Rec.rollup_Quantity_flag ,
                                 Res_Accum_Rec.unit_of_measure ,
                                 x_current_period ,
                                 x_all_txn_accum_rec.TOT_CMT_RAW_COST,
                                 x_all_txn_accum_rec.TOT_CMT_BURDENED_COST,
                                 x_all_txn_accum_rec.TOT_CMT_QUANTITY,
                                 X_Recs_processed ,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code);

                    tot_recs_processed := tot_recs_processed + x_recs_processed;
           ELSIF -- (for IF #2)
--    Fetched period = Previous period
                 (x_all_txn_accum_rec.PA_PERIOD = x_prev_period )
              or (x_all_txn_accum_rec.GL_PERIOD = x_prev_period ) Then
             IF x_all_txn_accum_rec.PERIOD_YEAR = x_current_year Then --(IF #3)

--    Fetched period = previous period and fetched year = current year
--   (Update only ITD,YTD and PP figures )- Task level figures with resources
--    and Project-Resources   - ACTUALS

                 PA_PROCESS_ACCUM_ACTUALS_RES.Process_it_yt_pp_res
                                (x_project_id,
                                 x_all_txn_accum_rec.task_id,
                                 Res_Accum_Rec.resource_list_id ,
                                 Res_Accum_Rec.resource_list_Member_id ,
                                 Res_Accum_Rec.resource_id ,
                                 Res_Accum_Rec.resource_list_assignment_id ,
                                 Res_Accum_Rec.track_as_labor_flag ,
                                 Res_Accum_Rec.rollup_Quantity_flag ,
                                 Res_Accum_Rec.unit_of_measure ,
                                 x_current_period ,
                                 x_all_txn_accum_rec.TOT_REVENUE,
                                 x_all_txn_accum_rec.TOT_RAW_COST,
                                 x_all_txn_accum_rec.TOT_BURDENED_COST,
                                 x_all_txn_accum_rec.TOT_LABOR_HOURS,
				 x_quantity,
				 x_billable_quantity,
                                 x_all_txn_accum_rec.TOT_BILLABLE_RAW_COST,
                                 x_all_txn_accum_rec.TOT_BILLABLE_BURDENED_COST,
                                 x_all_txn_accum_rec.TOT_BILLABLE_LABOR_HOURS,
		                 'Y',  -- x_actual_cost_flag
                                 'Y',  -- x_revenue_flag
                                 X_Recs_processed ,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code);

                 tot_recs_processed := tot_recs_processed + x_recs_processed;

--    Fetched period = previous period and fetched year = current year
--   (Update only ITD,YTD and PP figures )- Task level figures with resources
--    and Project-Resources   - COMMITMENTS

                 PA_PROCESS_ACCUM_CMT_RES.Process_it_yt_pp_cmt_res
                                (x_project_id,
                                 x_all_txn_accum_rec.task_id,
                                 Res_Accum_Rec.resource_list_id ,
                                 Res_Accum_Rec.resource_list_Member_id ,
                                 Res_Accum_Rec.resource_id ,
                                 Res_Accum_Rec.resource_list_assignment_id ,
                                 Res_Accum_Rec.track_as_labor_flag ,
                                 Res_Accum_Rec.rollup_Quantity_flag ,
                                 Res_Accum_Rec.unit_of_measure ,
                                 x_current_period ,
                                 x_all_txn_accum_rec.TOT_CMT_RAW_COST,
                                 x_all_txn_accum_rec.TOT_CMT_BURDENED_COST,
                                 x_all_txn_accum_rec.TOT_CMT_QUANTITY,
                                 X_Recs_processed ,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code);

                    tot_recs_processed := tot_recs_processed + x_recs_processed;
              ELSE  -- (for IF #3)
--      Fetched period = previous period but fetched year != current year
--      (Update only ITD and PP figures )-Task level figures with resources
--      and Project-Resources - ACTUALS

               PA_PROCESS_ACCUM_ACTUALS_RES.Process_it_pp_res
                                (x_project_id,
                                 x_all_txn_accum_rec.task_id,
                                 Res_Accum_Rec.resource_list_id ,
                                 Res_Accum_Rec.resource_list_Member_id ,
                                 Res_Accum_Rec.resource_id ,
                                 Res_Accum_Rec.resource_list_assignment_id ,
                                 Res_Accum_Rec.track_as_labor_flag ,
                                 Res_Accum_Rec.rollup_Quantity_flag ,
                                 Res_Accum_Rec.unit_of_measure ,
                                 x_current_period ,
                                 x_all_txn_accum_rec.TOT_REVENUE,
                                 x_all_txn_accum_rec.TOT_RAW_COST,
                                 x_all_txn_accum_rec.TOT_BURDENED_COST,
                                 x_all_txn_accum_rec.TOT_LABOR_HOURS,
				 x_quantity,
				 x_billable_quantity,
                                 x_all_txn_accum_rec.TOT_BILLABLE_RAW_COST,
                                 x_all_txn_accum_rec.TOT_BILLABLE_BURDENED_COST,
                                 x_all_txn_accum_rec.TOT_BILLABLE_LABOR_HOURS,
		                 'Y',  -- x_actual_cost_flag
                                 'Y',  -- x_revenue_flag
                                 X_Recs_processed ,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code);

                tot_recs_processed := tot_recs_processed + x_recs_processed;

--      Fetched period = previous period but fetched year != current year
--      (Update only ITD and PP figures )-Task level figures with resources
--      and Project-Resources - COMMITMENTS

                PA_PROCESS_ACCUM_CMT_RES.Process_it_pp_cmt_res
                                (x_project_id,
                                 x_all_txn_accum_rec.task_id,
                                 Res_Accum_Rec.resource_list_id ,
                                 Res_Accum_Rec.resource_list_Member_id ,
                                 Res_Accum_Rec.resource_id ,
                                 Res_Accum_Rec.resource_list_assignment_id ,
                                 Res_Accum_Rec.track_as_labor_flag ,
                                 Res_Accum_Rec.rollup_Quantity_flag ,
                                 Res_Accum_Rec.unit_of_measure ,
                                 x_current_period ,
                                 x_all_txn_accum_rec.TOT_CMT_RAW_COST,
                                 x_all_txn_accum_rec.TOT_CMT_BURDENED_COST,
                                 x_all_txn_accum_rec.TOT_CMT_QUANTITY,
                                 X_Recs_processed ,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code);

                    tot_recs_processed := tot_recs_processed + x_recs_processed;
              END IF; -- (IF #3)
           ELSE  -- (for IF #2)
             IF x_all_txn_accum_rec.PERIOD_YEAR = x_current_year Then --(IF #4)

--     Fetched period != current or previous period but fetched year =
--     current year
--     (Update only ITD and YTD figures)- Task level figures with resources
--     and Project-Resources  - ACTUALS

               PA_PROCESS_ACCUM_ACTUALS_RES.Process_it_yt_res
                                (x_project_id,
                                 x_all_txn_accum_rec.task_id,
                                 Res_Accum_Rec.resource_list_id ,
                                 Res_Accum_Rec.resource_list_Member_id ,
                                 Res_Accum_Rec.resource_id ,
                                 Res_Accum_Rec.resource_list_assignment_id ,
                                 Res_Accum_Rec.track_as_labor_flag ,
                                 Res_Accum_Rec.rollup_Quantity_flag ,
                                 Res_Accum_Rec.unit_of_measure ,
                                 x_current_period ,
                                 x_all_txn_accum_rec.TOT_REVENUE,
                                 x_all_txn_accum_rec.TOT_RAW_COST,
                                 x_all_txn_accum_rec.TOT_BURDENED_COST,
                                 x_all_txn_accum_rec.TOT_LABOR_HOURS,
				 x_quantity,
				 x_billable_quantity,
                                 x_all_txn_accum_rec.TOT_BILLABLE_RAW_COST,
                                 x_all_txn_accum_rec.TOT_BILLABLE_BURDENED_COST,
                                 x_all_txn_accum_rec.TOT_BILLABLE_LABOR_HOURS,
		                 'Y',  -- x_actual_cost_flag
                                 'Y',  -- x_revenue_flag
                                 X_Recs_processed ,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code);

                 tot_recs_processed := tot_recs_processed + x_recs_processed;

--     Fetched period != current or previous period but fetched year =
--     current year
--     (Update only ITD and YTD figures)- Task level figures with resources
--     and Project-Resources - COMMITMENTS

               PA_PROCESS_ACCUM_CMT_RES.Process_it_yt_cmt_res
                                (x_project_id,
                                 x_all_txn_accum_rec.task_id,
                                 Res_Accum_Rec.resource_list_id ,
                                 Res_Accum_Rec.resource_list_Member_id ,
                                 Res_Accum_Rec.resource_id ,
                                 Res_Accum_Rec.resource_list_assignment_id ,
                                 Res_Accum_Rec.track_as_labor_flag ,
                                 Res_Accum_Rec.rollup_Quantity_flag ,
                                 Res_Accum_Rec.unit_of_measure ,
                                 x_current_period ,
                                 x_all_txn_accum_rec.TOT_CMT_RAW_COST,
                                 x_all_txn_accum_rec.TOT_CMT_BURDENED_COST,
                                 x_all_txn_accum_rec.TOT_CMT_QUANTITY,
                                 X_Recs_processed ,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code);

                    tot_recs_processed := tot_recs_processed + x_recs_processed;
              ELSE -- (If #4)
--     Fetched period != current or previous period and fetched year !=
--     current year (Update only ITD figures )-
--     Task level figures with resources
--     and Project-Resources  - ACTUALS

               PA_PROCESS_ACCUM_ACTUALS_RES.Process_it_res
                                (x_project_id,
                                 x_all_txn_accum_rec.task_id,
                                 Res_Accum_Rec.resource_list_id ,
                                 Res_Accum_Rec.resource_list_Member_id ,
                                 Res_Accum_Rec.resource_id ,
                                 Res_Accum_Rec.resource_list_assignment_id ,
                                 Res_Accum_Rec.track_as_labor_flag ,
                                 Res_Accum_Rec.rollup_Quantity_flag ,
                                 Res_Accum_Rec.unit_of_measure ,
                                 x_current_period ,
                                 x_all_txn_accum_rec.TOT_REVENUE,
                                 x_all_txn_accum_rec.TOT_RAW_COST,
                                 x_all_txn_accum_rec.TOT_BURDENED_COST,
                                 x_all_txn_accum_rec.TOT_LABOR_HOURS,
				 x_quantity,
				 x_billable_quantity,
                                 x_all_txn_accum_rec.TOT_BILLABLE_RAW_COST,
                                 x_all_txn_accum_rec.TOT_BILLABLE_BURDENED_COST,
                                 x_all_txn_accum_rec.TOT_BILLABLE_LABOR_HOURS,
		                 'Y',  -- x_actual_cost_flag
                                 'Y',  -- x_revenue_flag
                                 X_Recs_processed ,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code);

                 tot_recs_processed := tot_recs_processed + x_recs_processed;

--     Fetched period != current or previous period and fetched year !=
--     current year (Update only ITD figures )-
--     Task level figures with resources
--     and Project-Resources  - COMMITMENTS

               PA_PROCESS_ACCUM_CMT_RES.Process_it_cmt_res
                                (x_project_id,
                                 x_all_txn_accum_rec.task_id,
                                 Res_Accum_Rec.resource_list_id ,
                                 Res_Accum_Rec.resource_list_Member_id ,
                                 Res_Accum_Rec.resource_id ,
                                 Res_Accum_Rec.resource_list_assignment_id ,
                                 Res_Accum_Rec.track_as_labor_flag ,
                                 Res_Accum_Rec.rollup_Quantity_flag ,
                                 Res_Accum_Rec.unit_of_measure ,
                                 x_current_period ,
                                 x_all_txn_accum_rec.TOT_CMT_RAW_COST,
                                 x_all_txn_accum_rec.TOT_CMT_BURDENED_COST,
                                 x_all_txn_accum_rec.TOT_CMT_QUANTITY,
                                 X_Recs_processed ,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code);

                    tot_recs_processed := tot_recs_processed + x_recs_processed;
              END IF; -- (IF # 4)
           END IF;    -- (IF # 2)
        END LOOP; -- (Res_Accum_rec in Res_accum_Cur LOOP )
       END LOOP; -- (1..No_of_res_lists LOOP )
     END LOOP;   -- (x_all_txn_accum_rec IN All_PA_Txn_Accum_Cur LOOP )


     -- Now Update the Resource list assignement record, to set the
     -- Resource list as Accumulated

     Update PA_RESOURCE_LIST_ASSIGNMENTS
     SET
            RESOURCE_LIST_ACCUMULATED_FLAG  = 'Y'
     Where
            PROJECT_ID           = x_project_id
     AND    RESOURCE_LIST_ID     = NVL(x_resource_list_id, RESOURCE_LIST_ID);

   END IF;  -- (IF #1)

   -- Restore the old x_err_stack;

   x_err_stack := V_Old_Stack;
Exception
   When Others Then
        x_err_code := SQLCODE;
        RAISE ;
End Process_Res_Lists;

End PA_REFRESH_RES_LISTS;

/
