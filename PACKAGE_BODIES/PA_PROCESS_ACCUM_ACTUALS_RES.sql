--------------------------------------------------------
--  DDL for Package Body PA_PROCESS_ACCUM_ACTUALS_RES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROCESS_ACCUM_ACTUALS_RES" AS
/* $Header: PAACRESB.pls 120.2 2005/08/31 11:08:00 vmangulu noship $ */

--    This Procedure      - Processes ITD,YTD and PTD amounts in the
--                          PA_PROJECT_ACCUM_ACTUALS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks. The Project-Resource records
--                          are also created/updated.

Procedure   Process_it_yt_pt_res
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_resource_list_id in Number,
                                 x_resource_list_Member_id in Number,
                                 x_resource_id in Number,
                                 x_resource_list_assignment_id in Number,
                                 x_track_as_labor_flag In Varchar2,
                                 x_rollup_Qty_flag In Varchar2,
                                 x_unit_of_measure In Varchar2,
                                 x_current_period In Varchar2,
                                 X_Revenue In Number,
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Labor_Hours In Number,
                                 X_Quantity In Number,
                                 X_Billable_Quantity In Number,
                                 X_Billable_Raw_Cost In Number,
                                 X_Billable_Burdened_Cost In Number,
                                 X_Billable_Labor_Hours In Number,
				 x_actual_cost_flag In Varchar2,
				 x_revenue_flag In Varchar2,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895


Recs_processed Number := 0;
Res_Recs_processed Number := 0;
V_Old_Stack       Varchar2(630);

Begin
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      X_err_stack ||'->PA_PROCESS_ACCUM_ACTUALS_RES.Process_it_yt_pt_res';
      pa_debug.debug(x_err_stack);

-- The follwing Update statement updates all records in the given task
-- WBS hierarchy.It will update only the Project-task-resource combination
-- records and the Project-Resource level record(Task id = 0 and
-- Resourcelist member id <> 0)

      IF(x_actual_cost_flag = 'Y') THEN
        Update PA_PROJECT_ACCUM_ACTUALS  PAA SET
         RAW_COST_ITD = RAW_COST_ITD + X_Raw_Cost,
         RAW_COST_YTD = RAW_COST_YTD + X_Raw_Cost,
         RAW_COST_PTD = RAW_COST_PTD + X_Raw_Cost,
         BILLABLE_RAW_COST_ITD = BILLABLE_RAW_COST_ITD +
                                 X_Billable_Raw_Cost,
         BILLABLE_RAW_COST_YTD = BILLABLE_RAW_COST_YTD +
                                 X_Billable_Raw_Cost,
         BILLABLE_RAW_COST_PTD = BILLABLE_RAW_COST_PTD +
                                 X_Billable_Raw_Cost,
         BURDENED_COST_ITD     = BURDENED_COST_ITD + X_Burdened_Cost,
         BURDENED_COST_YTD     = BURDENED_COST_YTD + X_Burdened_Cost,
         BURDENED_COST_PTD     = BURDENED_COST_PTD + X_Burdened_Cost,
         BILLABLE_BURDENED_COST_ITD = BILLABLE_BURDENED_COST_ITD +
                                      X_Billable_Burdened_Cost,
         BILLABLE_BURDENED_COST_YTD = BILLABLE_BURDENED_COST_YTD +
                                      X_Billable_Burdened_Cost,
         BILLABLE_BURDENED_COST_PTD = BILLABLE_BURDENED_COST_PTD +
                                      X_Billable_Burdened_Cost,
         LABOR_HOURS_ITD            = LABOR_HOURS_ITD + X_Labor_Hours,
         LABOR_HOURS_YTD            = LABOR_HOURS_YTD + X_Labor_Hours,
         LABOR_HOURS_PTD            = LABOR_HOURS_PTD + X_Labor_Hours,
         BILLABLE_LABOR_HOURS_ITD   = BILLABLE_LABOR_HOURS_ITD +
                                      X_Billable_Labor_Hours,
         BILLABLE_LABOR_HOURS_YTD   = BILLABLE_LABOR_HOURS_YTD +
                                      X_Billable_Labor_Hours,
         BILLABLE_LABOR_HOURS_PTD   = BILLABLE_LABOR_HOURS_PTD +
                                      X_Billable_Labor_Hours,
         QUANTITY_ITD               = QUANTITY_ITD + X_Quantity,
         QUANTITY_YTD               = QUANTITY_YTD + X_Quantity,
         QUANTITY_PTD               = QUANTITY_PTD + X_Quantity,
         BILLABLE_QUANTITY_ITD      = BILLABLE_QUANTITY_ITD + X_Billable_Quantity,
         BILLABLE_QUANTITY_YTD      = BILLABLE_QUANTITY_YTD + X_Billable_Quantity,
         BILLABLE_QUANTITY_PTD      = BILLABLE_QUANTITY_PTD + X_Billable_Quantity,
         LAST_UPDATED_BY            = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE           = Trunc(Sysdate),
         LAST_UPDATE_LOGIN          = pa_proj_accum_main.x_last_update_login
         Where PAA.Project_Accum_id     In
        (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = x_resource_list_Member_id and
         Pah.Task_id in (select 0 from sys.dual union
         Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id));
         x_recs_processed := Recs_processed + SQL%ROWCOUNT;
      END IF;
      IF(x_revenue_flag = 'Y') THEN
        Update PA_PROJECT_ACCUM_ACTUALS  PAA SET
         REVENUE_ITD                = REVENUE_ITD + X_Revenue,
         REVENUE_YTD                = REVENUE_YTD + X_Revenue,
         REVENUE_PTD                = REVENUE_PTD + X_Revenue,
         LAST_UPDATED_BY            = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE           = Trunc(Sysdate),
         LAST_UPDATE_LOGIN          = pa_proj_accum_main.x_last_update_login
         Where PAA.Project_Accum_id     In
        (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = x_resource_list_Member_id and
         Pah.Task_id in (select 0 from sys.dual union
         Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id));
         x_recs_processed := Recs_processed + SQL%ROWCOUNT;
      END IF;

      --      Restore the old x_err_stack;
      x_err_stack := V_Old_Stack;
Exception
  When Others Then
       x_err_code := SQLCODE;
       RAISE;
End Process_it_yt_pt_res;

-- This procedure         - Processes ITD,YTD and PP  amounts in the
--                          PA_PROJECT_ACCUM_ACTUALS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.  The Project-Resource records
--                          are also created/updated.

Procedure   Process_it_yt_pp_res
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_resource_list_id in Number,
                                 x_resource_list_Member_id in Number,
                                 x_resource_id in Number,
                                 x_resource_list_assignment_id in Number,
                                 x_track_as_labor_flag In Varchar2,
                                 x_rollup_Qty_flag In Varchar2,
                                 x_unit_of_measure In Varchar2,
                                 x_current_period In Varchar2,
                                 X_Revenue In Number,
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Labor_Hours In Number,
                                 X_Quantity In Number,
                                 X_Billable_Quantity In Number,
                                 X_Billable_Raw_Cost In Number,
                                 X_Billable_Burdened_Cost In Number,
                                 X_Billable_Labor_Hours In Number,
				 x_actual_cost_flag In Varchar2,
				 x_revenue_flag In Varchar2,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

Recs_processed Number := 0;
Res_Recs_processed Number := 0;
V_Old_Stack       Varchar2(630);

Begin

      V_Old_Stack := x_err_stack;
      x_err_stack :=
      X_err_stack ||'->PA_PROCESS_ACCUM_ACTUALS_RES.Process_it_yt_pp_res';

      pa_debug.debug(x_err_stack);

-- The follwing Update statement updates all records in the given task
-- WBS hierarchy.It will update only the Project-task-resource combination
-- records and the Project-Resource level record(Task id = 0 and
-- Resourcelist member id <> 0)
      IF(x_actual_cost_flag = 'Y') THEN
        Update PA_PROJECT_ACCUM_ACTUALS  PAA SET
         RAW_COST_ITD                   = RAW_COST_ITD + X_Raw_Cost,
         RAW_COST_YTD                   = RAW_COST_YTD + X_Raw_Cost,
         RAW_COST_PP                    = RAW_COST_PP + X_Raw_Cost,
         BILLABLE_RAW_COST_ITD          = BILLABLE_RAW_COST_ITD +
                                          X_Billable_Raw_Cost,
         BILLABLE_RAW_COST_YTD          = BILLABLE_RAW_COST_YTD +
                                          X_Billable_Raw_Cost,
         BILLABLE_RAW_COST_PP           = BILLABLE_RAW_COST_PP +
                                          X_Billable_Raw_Cost,
         BURDENED_COST_ITD              = BURDENED_COST_ITD + X_Burdened_Cost,
         BURDENED_COST_YTD              = BURDENED_COST_YTD + X_Burdened_Cost,
         BURDENED_COST_PP               = BURDENED_COST_PP + X_Burdened_Cost,
         BILLABLE_BURDENED_COST_ITD     = BILLABLE_BURDENED_COST_ITD +
                                          X_Billable_Burdened_Cost,
         BILLABLE_BURDENED_COST_YTD     = BILLABLE_BURDENED_COST_YTD +
                                          X_Billable_Burdened_Cost,
         BILLABLE_BURDENED_COST_PP      = BILLABLE_BURDENED_COST_PP +
                                          X_Billable_Burdened_Cost,
         LABOR_HOURS_ITD                = LABOR_HOURS_ITD + X_Labor_Hours,
         LABOR_HOURS_YTD                = LABOR_HOURS_YTD + X_Labor_Hours,
         LABOR_HOURS_PP                 = LABOR_HOURS_PP + X_Labor_Hours,
         BILLABLE_LABOR_HOURS_ITD       = BILLABLE_LABOR_HOURS_ITD +
                                          X_Billable_Labor_Hours,
         BILLABLE_LABOR_HOURS_YTD       = BILLABLE_LABOR_HOURS_YTD +
                                          X_Billable_Labor_Hours,
         BILLABLE_LABOR_HOURS_PP        = BILLABLE_LABOR_HOURS_PP +
                                          X_Billable_Labor_Hours,
         QUANTITY_ITD                   = QUANTITY_ITD + X_Quantity,
         QUANTITY_YTD                   = QUANTITY_YTD + X_Quantity,
         QUANTITY_PP                    = QUANTITY_PP + X_Quantity,
         BILLABLE_QUANTITY_ITD          = BILLABLE_QUANTITY_ITD +
                                          X_Billable_Quantity,
         BILLABLE_QUANTITY_YTD          = BILLABLE_QUANTITY_YTD +
                                          X_Billable_Quantity,
         BILLABLE_QUANTITY_PP           = BILLABLE_QUANTITY_PP  +
                                          X_Billable_Quantity,
         LAST_UPDATED_BY                = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE               = Trunc(Sysdate),
         LAST_UPDATE_LOGIN              = pa_proj_accum_main.x_last_update_login
         Where PAA.Project_Accum_id     In
         (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = x_resource_list_Member_id and
         Pah.Task_id in (select 0 from sys.dual union
         Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id));
         x_recs_processed := Recs_processed + SQL%ROWCOUNT;
      END IF;
      IF(x_revenue_flag = 'Y') THEN
        Update PA_PROJECT_ACCUM_ACTUALS  PAA SET
         REVENUE_ITD                    = REVENUE_ITD + X_Revenue,
         REVENUE_YTD                    = REVENUE_YTD + X_Revenue,
         REVENUE_PP                     = REVENUE_PP + X_Revenue,
         LAST_UPDATED_BY                = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE               = Trunc(Sysdate),
         LAST_UPDATE_LOGIN              = pa_proj_accum_main.x_last_update_login
         Where PAA.Project_Accum_id     In
         (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = x_resource_list_Member_id and
         Pah.Task_id in (select 0 from sys.dual
        union Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id));
         x_recs_processed := Recs_processed + SQL%ROWCOUNT;
      END IF;

         -- Restore the old x_err_stack;
         x_err_stack := V_Old_Stack;
Exception
  When Others Then
       x_err_code := SQLCODE;
       RAISE;

End Process_it_yt_pp_res;

-- Process_it_pp_res     -  Processes ITD and PP amounts in the
--                          PA_PROJECT_ACCUM_ACTUALS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks. The Project-Resource records
--                          are also created/updated.

Procedure   Process_it_pp_res
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_resource_list_id in Number,
                                 x_resource_list_Member_id in Number,
                                 x_resource_id in Number,
                                 x_resource_list_assignment_id in Number,
                                 x_track_as_labor_flag In Varchar2,
                                 x_rollup_Qty_flag In Varchar2,
                                 x_unit_of_measure In Varchar2,
                                 x_current_period In Varchar2,
                                 X_Revenue In Number,
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Labor_Hours In Number,
                                 X_Quantity In Number,
                                 X_Billable_Quantity In Number,
                                 X_Billable_Raw_Cost In Number,
                                 X_Billable_Burdened_Cost In Number,
                                 X_Billable_Labor_Hours In Number,
				 x_actual_cost_flag In Varchar2,
				 x_revenue_flag In Varchar2,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

Recs_processed Number := 0;
Res_Recs_processed Number := 0;
V_Old_Stack       Varchar2(630);

Begin
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      X_err_stack ||'->PA_PROCESS_ACCUM_ACTUALS_RES.Process_it_pp_res';

      pa_debug.debug(x_err_stack);

-- The follwing Update statement updates all records in the given task
-- WBS hierarchy.It will update only the Project-task-resource combination
-- records and the Project-Resource level record(Task id = 0 and
-- Resourcelist member id <> 0)
      IF(x_actual_cost_flag = 'Y') THEN
        Update PA_PROJECT_ACCUM_ACTUALS  PAA SET
         RAW_COST_ITD               = RAW_COST_ITD + X_Raw_Cost,
         RAW_COST_PP                = RAW_COST_PP + X_Raw_Cost,
         BILLABLE_RAW_COST_ITD      = BILLABLE_RAW_COST_ITD +
                                      X_Billable_Raw_Cost,
         BILLABLE_RAW_COST_PP       = BILLABLE_RAW_COST_PP +
                                      X_Billable_Raw_Cost,
         BURDENED_COST_ITD          = BURDENED_COST_ITD + X_Burdened_Cost,
         BURDENED_COST_PP           = BURDENED_COST_PP + X_Burdened_Cost,
         BILLABLE_BURDENED_COST_ITD = BILLABLE_BURDENED_COST_ITD +
                                      X_Billable_Burdened_Cost,
         BILLABLE_BURDENED_COST_PP  = BILLABLE_BURDENED_COST_PP +
                                      X_Billable_Burdened_Cost,
         LABOR_HOURS_ITD            = LABOR_HOURS_ITD + X_Labor_Hours,
         LABOR_HOURS_PP             = LABOR_HOURS_PP + X_Labor_Hours,
         BILLABLE_LABOR_HOURS_ITD   = BILLABLE_LABOR_HOURS_ITD +
                                      X_Billable_Labor_Hours,
         BILLABLE_LABOR_HOURS_PP    = BILLABLE_LABOR_HOURS_PP +
                                      X_Billable_Labor_Hours,
         QUANTITY_ITD               = QUANTITY_ITD + X_Quantity,
         QUANTITY_PP                = QUANTITY_PP + X_Quantity,
         BILLABLE_QUANTITY_ITD      = BILLABLE_QUANTITY_ITD + X_Billable_Quantity,
         BILLABLE_QUANTITY_PP       = BILLABLE_QUANTITY_PP + X_Billable_Quantity,
         LAST_UPDATED_BY            = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE           = Trunc(Sysdate),
         LAST_UPDATE_LOGIN          = pa_proj_accum_main.x_last_update_login
         Where PAA.Project_Accum_id     In
        (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = x_resource_list_Member_id and
         Pah.Task_id in (select 0 from sys.dual union
         Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id));
         x_recs_processed := Recs_processed + SQL%ROWCOUNT;
      END IF;
      IF(x_revenue_flag = 'Y') THEN
        Update PA_PROJECT_ACCUM_ACTUALS  PAA SET
         REVENUE_ITD                = REVENUE_ITD + X_Revenue,
         REVENUE_PP                 = REVENUE_PP + X_Revenue,
         LAST_UPDATED_BY            = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE           = Trunc(Sysdate),
         LAST_UPDATE_LOGIN          = pa_proj_accum_main.x_last_update_login
         Where PAA.Project_Accum_id     In
        (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = x_resource_list_Member_id and
         Pah.Task_id in (select 0 from sys.dual union
        Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id));
         x_recs_processed := Recs_processed + SQL%ROWCOUNT;
      END IF;

         -- Restore the old x_err_stack;
         x_err_stack := V_Old_Stack;
Exception
  When Others Then
       x_err_code := SQLCODE;
       RAISE ;
End Process_it_pp_res;

-- This procedure        -  Processes ITD and YTD amounts in the
--                          PA_PROJECT_ACCUM_ACTUALS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks. The Project-Resource records
--                          are also created/updated.

Procedure   Process_it_yt_res
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_resource_list_id in Number,
                                 x_resource_list_Member_id in Number,
                                 x_resource_id in Number,
                                 x_resource_list_assignment_id in Number,
                                 x_track_as_labor_flag In Varchar2,
                                 x_rollup_Qty_flag In Varchar2,
                                 x_unit_of_measure In Varchar2,
                                 x_current_period In Varchar2,
                                 X_Revenue In Number,
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Labor_Hours In Number,
                                 X_Quantity In Number,
                                 X_Billable_Quantity In Number,
                                 X_Billable_Raw_Cost In Number,
                                 X_Billable_Burdened_Cost In Number,
                                 X_Billable_Labor_Hours In Number,
				 x_actual_cost_flag In Varchar2,
				 x_revenue_flag In Varchar2,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

Recs_processed Number := 0;
Res_Recs_processed Number := 0;
V_Old_Stack       Varchar2(630);
Begin
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      X_err_stack ||'->PA_PROCESS_ACCUM_ACTUALS_RES.Process_it_yt_res';

      pa_debug.debug(x_err_stack);

-- The follwing Update statement updates all records in the given task
-- WBS hierarchy.It will update only the Project-task-resource combination
-- records and the Project-Resource level record(Task id = 0 and
-- Resourcelist member id <> 0)
      IF(x_actual_cost_flag = 'Y') THEN
        Update PA_PROJECT_ACCUM_ACTUALS  PAA SET
         RAW_COST_ITD               = RAW_COST_ITD + X_Raw_Cost,
         RAW_COST_YTD               = RAW_COST_YTD + X_Raw_Cost,
         BILLABLE_RAW_COST_ITD      = BILLABLE_RAW_COST_ITD +
                                      X_Billable_Raw_Cost,
         BILLABLE_RAW_COST_YTD      = BILLABLE_RAW_COST_YTD +
                                      X_Billable_Raw_Cost,
         BURDENED_COST_ITD          = BURDENED_COST_ITD + X_Burdened_Cost,
         BURDENED_COST_YTD          = BURDENED_COST_YTD + X_Burdened_Cost,
         BILLABLE_BURDENED_COST_ITD = BILLABLE_BURDENED_COST_ITD +
                                      X_Billable_Burdened_Cost,
         BILLABLE_BURDENED_COST_YTD = BILLABLE_BURDENED_COST_YTD +
                                      X_Billable_Burdened_Cost,
         LABOR_HOURS_ITD            = LABOR_HOURS_ITD + X_Labor_Hours,
         LABOR_HOURS_YTD            = LABOR_HOURS_YTD + X_Labor_Hours,
         BILLABLE_LABOR_HOURS_ITD   = BILLABLE_LABOR_HOURS_ITD +
                                      X_Billable_Labor_Hours,
         BILLABLE_LABOR_HOURS_YTD   = BILLABLE_LABOR_HOURS_YTD +
                                      X_Billable_Labor_Hours,
         QUANTITY_ITD               = QUANTITY_ITD + X_Quantity,
         QUANTITY_YTD               = QUANTITY_YTD + X_Quantity,
         BILLABLE_QUANTITY_ITD      = BILLABLE_QUANTITY_ITD + X_Billable_Quantity,
         BILLABLE_QUANTITY_YTD      = BILLABLE_QUANTITY_YTD + X_Billable_Quantity,
         LAST_UPDATED_BY            = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE           = Trunc(Sysdate),
         LAST_UPDATE_LOGIN          = pa_proj_accum_main.x_last_update_login
         Where PAA.Project_Accum_id     In
        (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = x_resource_list_Member_id and
         Pah.Task_id in (select 0 from sys.dual union
         Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id));
         x_recs_processed := Recs_processed + SQL%ROWCOUNT;
      END IF;
      IF(x_revenue_flag = 'Y') THEN
        Update PA_PROJECT_ACCUM_ACTUALS  PAA SET
         REVENUE_ITD                = REVENUE_ITD + X_Revenue,
         REVENUE_YTD                = REVENUE_YTD + X_Revenue,
         LAST_UPDATED_BY            = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE           = Trunc(Sysdate),
         LAST_UPDATE_LOGIN          = pa_proj_accum_main.x_last_update_login
         Where PAA.Project_Accum_id     In
        (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = x_resource_list_Member_id and
         Pah.Task_id in (select 0 from sys.dual union
         Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id));
         x_recs_processed := Recs_processed + SQL%ROWCOUNT;
      END IF;

         -- Restore the old x_err_stack;
         x_err_stack := V_Old_Stack;

Exception
  When Others Then
       x_err_code := SQLCODE;
       RAISE ;
End Process_it_yt_res;

-- This procedure        -  Processes ITD amounts in the
--                          PA_PROJECT_ACCUM_ACTUALS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks. The Project-Resource records
--                          are also created/updated.

Procedure   Process_it_res
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_resource_list_id in Number,
                                 x_resource_list_Member_id in Number,
                                 x_resource_id in Number,
                                 x_resource_list_assignment_id in Number,
                                 x_track_as_labor_flag In Varchar2,
                                 x_rollup_Qty_flag In Varchar2,
                                 x_unit_of_measure In Varchar2,
                                 x_current_period In Varchar2,
                                 X_Revenue In Number,
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Labor_Hours In Number,
                                 X_Quantity In Number,
                                 X_Billable_Quantity In Number,
                                 X_Billable_Raw_Cost In Number,
                                 X_Billable_Burdened_Cost In Number,
                                 X_Billable_Labor_Hours In Number,
				 x_actual_cost_flag In Varchar2,
				 x_revenue_flag In Varchar2,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

Recs_processed Number := 0;
Res_Recs_processed Number := 0;
V_Old_Stack       Varchar2(630);
Begin
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      X_err_stack ||'->PA_PROCESS_ACCUM_ACTUALS_RES.Process_it_res';

      pa_debug.debug(x_err_stack);

-- The follwing Update statement updates all records in the given task
-- WBS hierarchy.It will update only the Project-task-resource combination
-- records and the Project-Resource level record(Task id = 0 and
-- Resourcelist member id <> 0)
      IF(x_actual_cost_flag = 'Y') THEN
        Update PA_PROJECT_ACCUM_ACTUALS  PAA SET
         RAW_COST_ITD               = RAW_COST_ITD + X_Raw_Cost,
         BILLABLE_RAW_COST_ITD      = BILLABLE_RAW_COST_ITD +
                                      X_Billable_Raw_Cost,
         BURDENED_COST_ITD          = BURDENED_COST_ITD + X_Burdened_Cost,
         BILLABLE_BURDENED_COST_ITD = BILLABLE_BURDENED_COST_ITD +
                                      X_Billable_Burdened_Cost,
         LABOR_HOURS_ITD            = LABOR_HOURS_ITD + X_Labor_Hours,
         BILLABLE_LABOR_HOURS_ITD   = BILLABLE_LABOR_HOURS_ITD +
                                      X_Billable_Labor_Hours,
         QUANTITY_ITD               = QUANTITY_ITD + X_Quantity,
         BILLABLE_QUANTITY_ITD      = BILLABLE_QUANTITY_ITD + X_Billable_Quantity,
         LAST_UPDATED_BY            = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE           = Trunc(Sysdate),
         LAST_UPDATE_LOGIN          = pa_proj_accum_main.x_last_update_login
         Where PAA.Project_Accum_id     In
        (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = x_resource_list_Member_id and
         Pah.Task_id in (select 0 from sys.dual union
         Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id));
         x_recs_processed := Recs_processed + SQL%ROWCOUNT;
      END IF;
      IF(x_revenue_flag = 'Y') THEN
        Update PA_PROJECT_ACCUM_ACTUALS  PAA SET
         REVENUE_ITD                = REVENUE_ITD + X_Revenue,
         LAST_UPDATED_BY            = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE           = Trunc(Sysdate),
         LAST_UPDATE_LOGIN          = pa_proj_accum_main.x_last_update_login
         Where PAA.Project_Accum_id     In
        (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = x_resource_list_Member_id and
         Pah.Task_id in (select 0 from sys.dual union
         Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id));
         x_recs_processed := Recs_processed + SQL%ROWCOUNT;
      END IF;

         -- Restore the old x_err_stack;
         x_err_stack := V_Old_Stack;
Exception
  When Others Then
       x_err_code := SQLCODE;
       RAISE ;
End Process_it_res;

Procedure Insert_Headers_res (X_project_id In Number,
                              x_task_id In Number,
                              x_resource_list_id in Number,
                              x_resource_list_Member_id in Number,
                              x_resource_id in Number,
                              x_resource_list_assignment_id in Number,
                              x_current_period In Varchar2,
                              x_accum_id In Number,
                              x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

-- Insert_Headers_res    - Inserts Header records in the
--                         PA_PROJECT_ACCUM_HEADERS table for the given
--                         Project-Task-Resource combination

V_Old_Stack       Varchar2(630);
Begin

        V_Old_Stack := x_err_stack;
        x_err_stack :=
        x_err_stack||'->PA_PROCESS_ACCUM_ACTUALS_RES.Insert_Headers_res';
        pa_debug.debug(x_err_stack);

        Insert into PA_PROJECT_ACCUM_HEADERS
        (PROJECT_ACCUM_ID,PROJECT_ID,TASK_ID,ACCUM_PERIOD,RESOURCE_ID,
         RESOURCE_LIST_ID,RESOURCE_LIST_ASSIGNMENT_ID,
         RESOURCE_LIST_MEMBER_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,
         REQUEST_ID,CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN )
         Values (x_Accum_id,X_project_id,x_task_id,
                 x_current_period,
                 x_resource_id,x_resource_list_id,
                 x_resource_list_assignment_id,x_resource_list_Member_id,
                 pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),pa_proj_accum_main.x_request_id,trunc(sysdate),
                 pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login );

         -- Restore the old x_err_stack;
         x_err_stack := V_Old_Stack;
Exception when dup_val_on_index then
          null;
    When Others Then
          x_err_code := SQLCODE;
          RAISE ;
End Insert_Headers_res ;

END PA_PROCESS_ACCUM_ACTUALS_RES;

/
