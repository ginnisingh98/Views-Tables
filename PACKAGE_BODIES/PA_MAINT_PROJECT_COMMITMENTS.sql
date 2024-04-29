--------------------------------------------------------
--  DDL for Package Body PA_MAINT_PROJECT_COMMITMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MAINT_PROJECT_COMMITMENTS" AS
/* $Header: PAACCMTB.pls 120.1 2005/08/19 16:13:47 mwasowic noship $ */
TYPE resource_list_id_tabtype IS
TABLE OF PA_RESOURCE_LIST_ASSIGNMENTS.RESOURCE_LIST_ID%TYPE
INDEX BY BINARY_INTEGER;

Procedure Process_Txn_Accum_Cmt (X_project_id in Number,
                                X_impl_opt  In Varchar2,
                                x_Proj_accum_id   in Number,
                                x_current_period in Varchar2,
                                x_prev_period    in Varchar2,
                                x_current_year   in Number,
                                x_prev_accum_period in Varchar2,
                                x_current_start_date In Date,
                                x_current_end_date  In Date,
                                x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                x_err_code      In Out NOCOPY Number ) Is --File.Sql.39 bug 4440895

-- This cursor fetches all resource lists assigned to the given project
CURSOR Reslist_assgmt_Cur IS
SELECT Distinct
       Resource_list_id
FROM
  PA_RESOURCE_LIST_ASSIGNMENTS
Where Project_id = X_project_id;

  x_resource_list_id resource_list_id_tabtype;
  x_Res_accum_Res_list_id  Number := 0;
  x_Res_accum_txn_accum_id Number := 0;

-- This cursor fetches all relevant records from PA_RESOURCE_ACCUM_DETAILS
-- for the purpose of creating the resource level records in the
-- Accumulation tables

CURSOR Res_accum_Cur IS
SELECT
  Para.RESOURCE_LIST_ASSIGNMENT_ID,
  Para.RESOURCE_LIST_ID,
  Para.RESOURCE_LIST_MEMBER_ID,
  Para.RESOURCE_ID ,
  Parl.TRACK_AS_LABOR_FLAG,
  Par.ROLLUP_QUANTITY_FLAG ,
  Par.UNIT_OF_MEASURE
FROM
  PA_RESOURCE_ACCUM_DETAILS Para,
  PA_RESOURCES Par,
  PA_RESOURCE_LIST_MEMBERS Parl
WHERE Para.Txn_Accum_id = x_Res_accum_txn_accum_id and
        Para.Resource_list_id = x_Res_accum_Res_list_id and
        Para.Resource_list_id = Parl.Resource_list_id and
        Para.Resource_list_member_id = Parl.Resource_list_member_id and
        nvl(parl.migration_code,'-99') <> 'N' and
        Para.Resource_id  = Par.Resource_Id ;

-- This cursor fetches all relevant commitment records from PA_TXN_ACCUM
-- table

CURSOR PA_Txn_Accum_Cur IS

SELECT DISTINCT
  PTA.TXN_ACCUM_ID,
  PTA.TASK_ID,
  PTA.PA_PERIOD,
  PTA.GL_PERIOD,
  NVL(PTA.TOT_CMT_RAW_COST,0) TOT_CMT_RAW_COST,
  NVL(PTA.TOT_CMT_BURDENED_COST,0) TOT_CMT_BURDENED_COST,
  NVL(PTA.TOT_CMT_QUANTITY,0) TOT_CMT_QUANTITY,
  PTA.UNIT_OF_MEASURE,
  PAP.PERIOD_YEAR
FROM
  PA_TXN_ACCUM PTA,
  PA_PERIODS_V PAP
WHERE PTA.Project_Id = x_project_id
AND PTA.CMT_Rollup_flag = 'Y'
AND PTA.PA_PERIOD = PAP.PERIOD_NAME
AND PAP.PA_END_DATE <= x_current_end_date;

x_res_list_rec Reslist_assgmt_Cur%ROWTYPE;
x_txn_accum_rec PA_Txn_Accum_Cur%ROWTYPE;
x_res_accum_rec Res_accum_Cur%ROWTYPE;
No_of_res_lists             Number := 0;
x_recs_processed            Number := 0;
tot_recs_processed          Number := 0;
V_Old_Stack                 Varchar2(630);

Begin

      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_MAINT_PROJECT_COMMITMENTS.Process_Txn_Accum_Cmt';
      pa_debug.debug(x_err_stack);

-- This checks for the project level record in the PA_PROJECT_ACCUM_COMMITMENTS
-- table . It is possible, that there might be a header record in
-- PA_PROJECT_ACCUM_HEADERS, but no corresponding record in any/all of the
-- ACTUALS,BUDGETS,COMMITMENT tables.

        PA_ACCUM_UTILS.Check_Cmt_Details
                             (x_project_id,
                              0,
                              0,
                              x_recs_processed,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);
        tot_recs_processed := tot_recs_processed + x_recs_processed;

-- This stores all Resource lists assigned to the project in a PL/SQL table

     FOR x_res_list_rec IN Reslist_assgmt_Cur LOOP
     No_of_res_lists := No_of_res_lists + 1;
         x_resource_list_id(No_of_res_lists) :=
         x_res_list_rec.Resource_list_id;
    END LOOP;

-- Read all commitment records from PA_TXN_ACCUM
--   Fetched period = current period
--  (Update only ITD,YTD and PTD figures)-Task level figures without resources
    FOR  x_txn_accum_rec in PA_Txn_Accum_Cur LOOP
         IF (x_txn_accum_rec.PA_PERIOD =  x_current_period ) or
            (x_txn_accum_rec.GL_PERIOD = x_current_period ) Then
              PA_PROCESS_ACCUM_COMMITMENTS.Process_it_yt_pt_tasks_cmt
                                (x_project_id,
                                 x_txn_accum_rec.task_id,
                                 x_Proj_accum_id,
                                 x_current_period,
                                 x_txn_accum_rec.TOT_CMT_RAW_COST,
                                 x_txn_accum_rec.TOT_CMT_BURDENED_COST,
                                 x_txn_accum_rec.TOT_CMT_QUANTITY,
                                 x_txn_accum_rec.UNIT_OF_MEASURE,
                                 x_recs_processed,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code);

         ELSIF
--    Fetched period = Previous period
            (x_txn_accum_rec.PA_PERIOD = x_prev_period )
         or (x_txn_accum_rec.GL_PERIOD = x_prev_period ) Then
--    Fetched period = previous period and fetched year = current year
--   (Update only ITD,YTD and PP figures )- Task level figures without resources
             IF x_txn_accum_rec.PERIOD_YEAR = x_current_year Then
               PA_PROCESS_ACCUM_COMMITMENTS.Process_it_yt_pp_tasks_cmt
                                (x_project_id,
                                 x_txn_accum_rec.task_id,
                                 x_Proj_accum_id,
                                 x_current_period,
                                 x_txn_accum_rec.TOT_CMT_RAW_COST,
                                 x_txn_accum_rec.TOT_CMT_BURDENED_COST,
                                 x_txn_accum_rec.TOT_CMT_QUANTITY,
                                 x_txn_accum_rec.UNIT_OF_MEASURE,
                                 x_recs_processed,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code);
            ELSE
--      Fetched period = previous period but fetched year != current year
--      (Update only ITD and PP figures )-Task level figures without resources
               PA_PROCESS_ACCUM_COMMITMENTS.Process_it_pp_tasks_cmt
                                (x_project_id,
                                 x_txn_accum_rec.task_id,
                                 x_Proj_accum_id,
                                 x_current_period,
                                 x_txn_accum_rec.TOT_CMT_RAW_COST,
                                 x_txn_accum_rec.TOT_CMT_BURDENED_COST,
                                 x_txn_accum_rec.TOT_CMT_QUANTITY,
                                 x_txn_accum_rec.UNIT_OF_MEASURE,
                                 x_recs_processed,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code);
           END IF; -- (IF x_txn_accum_rec.PERIOD_YEAR = x_current_year )
          ELSE
--     Fetched period != current or previous period but fetched year =
--     current year
--     (Update only ITD and YTD figures)- Task level figures without resources
             IF x_txn_accum_rec.PERIOD_YEAR = x_current_year Then
               PA_PROCESS_ACCUM_COMMITMENTS.Process_it_yt_tasks_cmt
                                (x_project_id,
                                 x_txn_accum_rec.task_id,
                                 x_Proj_accum_id,
                                 x_current_period,
                                 x_txn_accum_rec.TOT_CMT_RAW_COST,
                                 x_txn_accum_rec.TOT_CMT_BURDENED_COST,
                                 x_txn_accum_rec.TOT_CMT_QUANTITY,
                                 x_txn_accum_rec.UNIT_OF_MEASURE,
                                 x_recs_processed,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code);

             ELSE
--     Fetched period != current or previous period and fetched year !=
--     current year (Update only ITD figures )-
--     Task level figures without resources
               PA_PROCESS_ACCUM_COMMITMENTS.Process_it_tasks_cmt
                                (x_project_id,
                                 x_txn_accum_rec.task_id,
                                 x_Proj_accum_id,
                                 x_current_period,
                                 x_txn_accum_rec.TOT_CMT_RAW_COST,
                                 x_txn_accum_rec.TOT_CMT_BURDENED_COST,
                                 x_txn_accum_rec.TOT_CMT_QUANTITY,
                                 x_txn_accum_rec.UNIT_OF_MEASURE,
                                 x_recs_processed,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code);
            END IF;
         END IF;
         tot_recs_processed := tot_recs_processed + x_recs_processed;
-- At this stage , Task level figures have been updated (without resources )
-- Now Read all Resource lists and process them

   IF  No_of_res_lists > 0 then
       For i in 1..No_of_res_lists LOOP
           x_Res_accum_Res_list_id := x_resource_list_id(i);
           x_Res_accum_txn_accum_id := x_txn_accum_rec.Txn_Accum_Id;
           For  Res_Accum_rec in Res_accum_Cur LOOP
--   Fetched period = current period
--  (Update only ITD,YTD and PTD figures)-Task level figures with resources
--  and Project-Resources
            IF (x_txn_accum_rec.PA_PERIOD =  x_current_period ) or
               (x_txn_accum_rec.GL_PERIOD = x_current_period ) Then
                   PA_PROCESS_ACCUM_CMT_RES.Process_it_yt_pt_cmt_res
                                (x_project_id,
                                 x_txn_accum_rec.task_id,
                                 Res_Accum_Rec.resource_list_id ,
                                 Res_Accum_Rec.resource_list_Member_id ,
                                 Res_Accum_Rec.resource_id ,
                                 Res_Accum_Rec.resource_list_assignment_id ,
                                 Res_Accum_Rec.track_as_labor_flag ,
                                 Res_Accum_Rec.rollup_Quantity_flag ,
                                 Res_Accum_Rec.unit_of_measure ,
                                 x_current_period ,
                                 x_txn_accum_rec.TOT_CMT_RAW_COST,
                                 x_txn_accum_rec.TOT_CMT_BURDENED_COST,
                                 x_txn_accum_rec.TOT_CMT_QUANTITY,
                                 X_Recs_processed ,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code);

            ELSIF
--    Fetched period = Previous period
                 (x_txn_accum_rec.PA_PERIOD = x_prev_period )
              or (x_txn_accum_rec.GL_PERIOD = x_prev_period ) Then
--    Fetched period = previous period and fetched year = current year
--   (Update only ITD,YTD and PP figures )- Task level figures with resources
--    and Project-Resources
             IF x_txn_accum_rec.PERIOD_YEAR = x_current_year Then
               PA_PROCESS_ACCUM_CMT_RES.Process_it_yt_pp_cmt_res
                                (x_project_id,
                                 x_txn_accum_rec.task_id,
                                 Res_Accum_Rec.resource_list_id ,
                                 Res_Accum_Rec.resource_list_Member_id ,
                                 Res_Accum_Rec.resource_id ,
                                 Res_Accum_Rec.resource_list_assignment_id ,
                                 Res_Accum_Rec.track_as_labor_flag ,
                                 Res_Accum_Rec.rollup_Quantity_flag ,
                                 Res_Accum_Rec.unit_of_measure ,
                                 x_current_period ,
                                 x_txn_accum_rec.TOT_CMT_RAW_COST,
                                 x_txn_accum_rec.TOT_CMT_BURDENED_COST,
                                 x_txn_accum_rec.TOT_CMT_QUANTITY,
                                 X_Recs_processed ,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code);
             ELSE
--      Fetched period = previous period but fetched year != current year
--      (Update only ITD and PP figures )-Task level figures with resources
--      and Project-Resources
               PA_PROCESS_ACCUM_CMT_RES.Process_it_pp_cmt_res
                                (x_project_id,
                                 x_txn_accum_rec.task_id,
                                 Res_Accum_Rec.resource_list_id ,
                                 Res_Accum_Rec.resource_list_Member_id ,
                                 Res_Accum_Rec.resource_id ,
                                 Res_Accum_Rec.resource_list_assignment_id ,
                                 Res_Accum_Rec.track_as_labor_flag ,
                                 Res_Accum_Rec.rollup_Quantity_flag ,
                                 Res_Accum_Rec.unit_of_measure ,
                                 x_current_period ,
                                 x_txn_accum_rec.TOT_CMT_RAW_COST,
                                 x_txn_accum_rec.TOT_CMT_BURDENED_COST,
                                 x_txn_accum_rec.TOT_CMT_QUANTITY,
                                 X_Recs_processed ,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code);

              END IF;
          ELSE
--     Fetched period != current or previous period but fetched year =
--     current year
--     (Update only ITD and YTD figures)- Task level figures with resources
--     and Project-Resources
             IF x_txn_accum_rec.PERIOD_YEAR = x_current_year Then
               PA_PROCESS_ACCUM_CMT_RES.Process_it_yt_cmt_res
                                (x_project_id,
                                 x_txn_accum_rec.task_id,
                                 Res_Accum_Rec.resource_list_id ,
                                 Res_Accum_Rec.resource_list_Member_id ,
                                 Res_Accum_Rec.resource_id ,
                                 Res_Accum_Rec.resource_list_assignment_id ,
                                 Res_Accum_Rec.track_as_labor_flag ,
                                 Res_Accum_Rec.rollup_Quantity_flag ,
                                 Res_Accum_Rec.unit_of_measure ,
                                 x_current_period ,
                                 x_txn_accum_rec.TOT_CMT_RAW_COST,
                                 x_txn_accum_rec.TOT_CMT_BURDENED_COST,
                                 x_txn_accum_rec.TOT_CMT_QUANTITY,
                                 X_Recs_processed ,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code);

             ELSE
--     Fetched period != current or previous period and fetched year !=
--     current year (Update only ITD figures )-
--     Task level figures with resources
--     and Project-Resources
               PA_PROCESS_ACCUM_CMT_RES.Process_it_cmt_res
                                (x_project_id,
                                 x_txn_accum_rec.task_id,
                                 Res_Accum_Rec.resource_list_id ,
                                 Res_Accum_Rec.resource_list_Member_id ,
                                 Res_Accum_Rec.resource_id ,
                                 Res_Accum_Rec.resource_list_assignment_id ,
                                 Res_Accum_Rec.track_as_labor_flag ,
                                 Res_Accum_Rec.rollup_Quantity_flag ,
                                 Res_Accum_Rec.unit_of_measure ,
                                 x_current_period ,
                                 x_txn_accum_rec.TOT_CMT_RAW_COST,
                                 x_txn_accum_rec.TOT_CMT_BURDENED_COST,
                                 x_txn_accum_rec.TOT_CMT_QUANTITY,
                                 X_Recs_processed ,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code);

           END IF;
         END IF;
           tot_recs_processed := tot_recs_processed + x_recs_processed;
           END LOOP;     -- (end the For  Res_Accum_rec in Res_accum_Cur LOOP)
        END LOOP; -- (end the For i in 1..No_of_res_lists LOOP )
   END IF;  -- (end the IF  No_of_res_lists > 0 IF)
-- After processing the record, Update the PA_TXN_ACCUM , modifying  the
-- CMT_ROLLUP_FLAG as 'Y'

      Update PA_TXN_ACCUM   Set
        last_updated_by              = pa_proj_accum_main.x_last_updated_by,
        last_update_date             = SYSDATE,
        request_id                   = pa_proj_accum_main.x_request_id,
        program_application_id       = pa_proj_accum_main.x_program_application_id,
        program_id                   = pa_proj_accum_main.x_program_id,
        program_update_date          = SYSDATE,
        CMT_ROLLUP_FLAG   = 'N' Where
        TXN_ACCUM_ID    = x_txn_accum_rec.Txn_Accum_Id;
        tot_recs_processed := tot_recs_processed + 1;
        tot_recs_processed := tot_recs_processed + x_recs_processed;
   END LOOP; -- (end the  FOR  x_txn_accum_rec in PA_Txn_Accum_Cur LOOP )

--      Restore the old x_err_stack;
              x_err_stack := V_Old_Stack;

Exception
 When Others then
   x_err_code := SQLCODE;
   RAISE;
End Process_Txn_Accum_Cmt;

End PA_MAINT_PROJECT_COMMITMENTS;

/
