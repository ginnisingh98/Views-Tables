--------------------------------------------------------
--  DDL for Package Body PA_PROCESS_ACCUM_ACTUALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROCESS_ACCUM_ACTUALS" AS
/* $Header: PAACTSKB.pls 120.2 2005/08/31 11:08:04 vmangulu noship $ */

-- The procedures are called by PA_MAINT_PROJECT_ACCUMS.Process_Txn_Accum

Procedure   Process_it_yt_pt_tasks
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_Proj_Accum_id In Number,
                                 x_current_period In Varchar2,
                                 X_Revenue In Number,
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Labor_Hours In Number,
                                 X_Billable_Raw_Cost In Number,
                                 X_Billable_Burdened_Cost In Number,
                                 X_Billable_Labor_Hours In Number,
                                 X_Unit_Of_Measure In Varchar2,
                                 x_actual_cost_flag  In Varchar2,
                                 x_revenue_flag  In Varchar2,
                                 X_Recs_processed Out NOCOPY Number , --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

-- This procedure processes the ITD,YTD and PTD figures for Actuals
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
   x_err_stack||'->PA_PROCESS_ACCUM_ACTUALS.Process_it_yt_pt_tasks';

   pa_debug.debug(x_err_stack);

   -- The follwing Update statement updates all records in the given task
   -- WBS hierarchy.It will update only the Project-task combination records
   -- and the Project level record (Task id = 0 and Resourcelist member id = 0)

   IF ( x_actual_cost_flag = 'Y' ) THEN

     Update PA_PROJECT_ACCUM_ACTUALS  PAA SET
         RAW_COST_ITD               = RAW_COST_ITD + X_Raw_Cost,
         RAW_COST_YTD               = RAW_COST_YTD + X_Raw_Cost,
         RAW_COST_PTD               = RAW_COST_PTD + X_Raw_Cost,
         BILLABLE_RAW_COST_ITD      = BILLABLE_RAW_COST_ITD +
                                      X_Billable_Raw_Cost,
         BILLABLE_RAW_COST_YTD      = BILLABLE_RAW_COST_YTD +
                                      X_Billable_Raw_Cost,
         BILLABLE_RAW_COST_PTD      = BILLABLE_RAW_COST_PTD +
                                      X_Billable_Raw_Cost,
         BURDENED_COST_ITD          = BURDENED_COST_ITD + X_Burdened_Cost,
         BURDENED_COST_YTD          = BURDENED_COST_YTD + X_Burdened_Cost,
         BURDENED_COST_PTD          = BURDENED_COST_PTD + X_Burdened_Cost,
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
         LAST_UPDATED_BY            = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE           = Trunc(Sysdate),
         LAST_UPDATE_LOGIN          = pa_proj_accum_main.x_last_update_login
         Where PAA.Project_Accum_id     In
        (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = 0 and
         Pah.Task_id in (Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id)  UNION
         select  to_number(X_Proj_accum_id) from sys.dual);

     x_recs_processed := Recs_processed + SQL%ROWCOUNT;

   END IF;
   IF ( x_revenue_flag = 'Y' ) THEN

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
         pah.Resource_list_member_id = 0 and
         Pah.Task_id in (Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id) UNION
         select  to_number(X_Proj_accum_id) from sys.dual);

    x_recs_processed := Recs_processed + SQL%ROWCOUNT;

    END IF;

    -- Restore the old x_err_stack;
    x_err_stack := V_Old_Stack;

Exception
  When others Then
     x_err_code := SQLCODE;
     RAISE;

End Process_it_yt_pt_tasks;

Procedure   Process_it_yt_pp_tasks
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_Proj_Accum_id In Number,
                                 x_current_period In Varchar2,
                                 X_Revenue In Number,
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Labor_Hours In Number,
                                 X_Billable_Raw_Cost In Number,
                                 X_Billable_Burdened_Cost In Number,
                                 X_Billable_Labor_Hours In Number,
                                 X_Unit_Of_Measure In Varchar2,
                                 x_actual_cost_flag  In Varchar2,
                                 x_revenue_flag  In Varchar2,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

-- This procedure processes the ITD,YTD and PP figures for Actuals

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
      x_err_stack||'->PA_PROCESS_ACCUM_ACTUALS.Process_it_yt_pp_tasks';

      pa_debug.debug(x_err_stack);

      IF(x_actual_cost_flag = 'Y') THEN

        Update PA_PROJECT_ACCUM_ACTUALS  PAA SET
         RAW_COST_ITD                 = RAW_COST_ITD + X_Raw_Cost,
         RAW_COST_YTD                 = RAW_COST_YTD + X_Raw_Cost,
         RAW_COST_PP                  = RAW_COST_PP + X_Raw_Cost,
         BILLABLE_RAW_COST_ITD        = BILLABLE_RAW_COST_ITD +
                                        X_Billable_Raw_Cost,
         BILLABLE_RAW_COST_YTD        = BILLABLE_RAW_COST_YTD +
                                        X_Billable_Raw_Cost,
         BILLABLE_RAW_COST_PP         = BILLABLE_RAW_COST_PP +
                                        X_Billable_Raw_Cost,
         BURDENED_COST_ITD            = BURDENED_COST_ITD + X_Burdened_Cost,
         BURDENED_COST_YTD            = BURDENED_COST_YTD + X_Burdened_Cost,
         BURDENED_COST_PP             = BURDENED_COST_PP + X_Burdened_Cost,
         BILLABLE_BURDENED_COST_ITD   = BILLABLE_BURDENED_COST_ITD +
                                        X_Billable_Burdened_Cost,
         BILLABLE_BURDENED_COST_YTD   = BILLABLE_BURDENED_COST_YTD +
                                        X_Billable_Burdened_Cost,
         BILLABLE_BURDENED_COST_PP    = BILLABLE_BURDENED_COST_PP +
                                        X_Billable_Burdened_Cost,
         LABOR_HOURS_ITD              = LABOR_HOURS_ITD + X_Labor_Hours,
         LABOR_HOURS_YTD              = LABOR_HOURS_YTD + X_Labor_Hours,
         LABOR_HOURS_PP               = LABOR_HOURS_PP + X_Labor_Hours,
         BILLABLE_LABOR_HOURS_ITD     = BILLABLE_LABOR_HOURS_ITD +
                                        X_Billable_Labor_Hours,
         BILLABLE_LABOR_HOURS_YTD     = BILLABLE_LABOR_HOURS_YTD +
                                        X_Billable_Labor_Hours,
         BILLABLE_LABOR_HOURS_PP      = BILLABLE_LABOR_HOURS_PP +
                                        X_Billable_Labor_Hours,
         LAST_UPDATED_BY              = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE             = Trunc(Sysdate),
         LAST_UPDATE_LOGIN            = pa_proj_accum_main.x_last_update_login
         Where PAA.Project_Accum_id     In
        (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = 0 and
         Pah.Task_id in (Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id)
         UNION select  to_number(X_Proj_accum_id) from sys.dual);

     x_recs_processed := Recs_processed + SQL%ROWCOUNT;
     END IF;
     IF(x_revenue_flag = 'Y') THEN

        Update PA_PROJECT_ACCUM_ACTUALS  PAA SET
         REVENUE_ITD                  = REVENUE_ITD + X_Revenue,
         REVENUE_YTD                  = REVENUE_YTD + X_Revenue,
         REVENUE_PP                   = REVENUE_PP + X_Revenue,
         LAST_UPDATED_BY              = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE             = Trunc(Sysdate),
         LAST_UPDATE_LOGIN            = pa_proj_accum_main.x_last_update_login
         Where PAA.Project_Accum_id     In
        (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = 0 and
         Pah.Task_id in (Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id)
         UNION select  to_number(X_Proj_accum_id) from sys.dual);

     x_recs_processed := Recs_processed + SQL%ROWCOUNT;
     END IF;
     -- Restore the old x_err_stack;
     x_err_stack := V_Old_Stack;
Exception

  When others Then
     x_err_code := SQLCODE;
     RAISE;

End Process_it_yt_pp_tasks;

Procedure   Process_it_pp_tasks
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_Proj_Accum_id In Number,
                                 x_current_period In Varchar2,
                                 X_Revenue In Number,
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Labor_Hours In Number,
                                 X_Billable_Raw_Cost In Number,
                                 X_Billable_Burdened_Cost In Number,
                                 X_Billable_Labor_Hours In Number,
                                 X_Unit_Of_Measure In Varchar2,
                                 x_actual_cost_flag  In Varchar2,
                                 x_revenue_flag  In Varchar2,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

-- This procedure processes the ITD,and PP figures for Actuals

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
      x_err_stack||'->PA_PROCESS_ACCUM_ACTUALS.Process_it_pp_tasks';

      pa_debug.debug(x_err_stack);

      -- The follwing Update statement updates all records in the given task
      -- WBS hierarchy.It will update only the Project-task combination records
      -- and the Project level record (Task id = 0 and Resourcelist member id = 0)
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
         LAST_UPDATED_BY            = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE           = Trunc(Sysdate),
         LAST_UPDATE_LOGIN          = pa_proj_accum_main.x_last_update_login
         Where PAA.Project_Accum_id     In
        (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = 0 and
         Pah.Task_id in (Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id)
         UNION select  to_number(X_Proj_accum_id) from sys.dual);

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
         pah.Resource_list_member_id = 0 and
         Pah.Task_id in (Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id)
         UNION select  to_number(X_Proj_accum_id) from sys.dual);

       x_recs_processed := Recs_processed + SQL%ROWCOUNT;
       END IF;
       -- Restore the old x_err_stack;

       x_err_stack := V_Old_Stack;
Exception

  When others Then
    x_err_code := SQLCODE;
     RAISE;

End Process_it_pp_tasks;

Procedure   Process_it_yt_tasks
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_Proj_Accum_id In Number,
                                 x_current_period In Varchar2,
                                 X_Revenue In Number,
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Labor_Hours In Number,
                                 X_Billable_Raw_Cost In Number,
                                 X_Billable_Burdened_Cost In Number,
                                 X_Billable_Labor_Hours In Number,
                                 X_Unit_Of_Measure In Varchar2,
                                 x_actual_cost_flag  In Varchar2,
                                 x_revenue_flag  In Varchar2,
                                 X_Recs_processed Out NOCOPY Number , --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

-- This procedure processes the ITD and YTD figures for Actuals

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
      x_err_stack||'->PA_PROCESS_ACCUM_ACTUALS.Process_it_yt_tasks';

      pa_debug.debug(x_err_stack);

      -- The follwing Update statement updates all records in the given task
      -- WBS hierarchy.It will update only the Project-task combination records
      -- and the Project level record (Task id = 0 and Resourcelist member id = 0)
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
         LAST_UPDATED_BY            = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE           = Trunc(Sysdate),
         LAST_UPDATE_LOGIN          = pa_proj_accum_main.x_last_update_login
         Where PAA.Project_Accum_id     In
        (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = 0 and
         Pah.Task_id in (Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id)
         UNION select  to_number(X_Proj_accum_id) from sys.dual);

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
         pah.Resource_list_member_id = 0 and
         Pah.Task_id in (Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id)
         UNION select  to_number(X_Proj_accum_id) from sys.dual);

      x_recs_processed := Recs_processed + SQL%ROWCOUNT;
      END IF;
    -- Restore the old x_err_stack;

    x_err_stack := V_Old_Stack;
Exception

  When others Then
     x_err_code := SQLCODE;
     RAISE;

End Process_it_yt_tasks;

Procedure   Process_it_tasks
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_Proj_Accum_id In Number,
                                 x_current_period In Varchar2,
                                 X_Revenue In Number,
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Labor_Hours In Number,
                                 X_Billable_Raw_Cost In Number,
                                 X_Billable_Burdened_Cost In Number,
                                 X_Billable_Labor_Hours In Number,
                                 X_Unit_Of_Measure In Varchar2,
                                 x_actual_cost_flag  In Varchar2,
                                 x_revenue_flag  In Varchar2,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

-- This procedure processes the ITD figures for Actuals

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
   x_err_stack||'->PA_PROCESS_ACCUM_ACTUALS.Process_it_tasks';

   pa_debug.debug(x_err_stack);

   -- The follwing Update statement updates all records in the given task
   -- WBS hierarchy.It will update only the Project-task combination records
   -- and the Project level record (Task id = 0 and Resourcelist member id = 0)
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
         LAST_UPDATED_BY            = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE           = Trunc(Sysdate),
         LAST_UPDATE_LOGIN          = pa_proj_accum_main.x_last_update_login
         Where PAA.Project_Accum_id     In
        (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = 0 and
         Pah.Task_id in (Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id)
         UNION select  to_number(X_Proj_accum_id) from sys.dual);

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
         pah.Resource_list_member_id = 0 and
         Pah.Task_id in (Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id)
         UNION select  to_number(X_Proj_accum_id) from sys.dual);

      x_recs_processed := Recs_processed + SQL%ROWCOUNT;
   END IF;
      -- Restore the old x_err_stack;

      x_err_stack := V_Old_Stack;

Exception

  When Others Then
     x_err_code := SQLCODE;
     RAISE;

End Process_it_tasks;

END PA_PROCESS_ACCUM_ACTUALS;

/
