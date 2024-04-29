--------------------------------------------------------
--  DDL for Package Body PA_PROCESS_ACCUM_BUDGETS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROCESS_ACCUM_BUDGETS" AS
/* $Header: PABUTSKB.pls 120.2 2005/08/31 11:08:12 vmangulu noship $ */

-- Modified on 10/29/98 by S Sanckar to include a new procedure
-- Process_all_tasks_bud that updates the raw_cost, burdened_cost, quantity,
-- labor_quantity and revenue values for baselined and original budgets
-- This will update the amount columns for period_to_date and prior_period
-- and year_to_date apart from inception_to_date periods.

Procedure   Process_all_tasks_bud
                                (x_project_id 		   In Number,
                                 x_task_id 		   In Number,
                                 x_Proj_Accum_Id 	   In Number,
                                 x_budget_type_code	   In Varchar2,
                                 X_Base_Raw_Cost_ptd 	   In Number,
                                 X_Base_Burdened_Cost_ptd  In Number,
                                 X_Base_Revenue_ptd 	   In Number,
                                 X_Base_Quantity_ptd       In Number,
                                 X_Base_Labor_Hours_ptd    In Number,
                                 X_Base_Raw_Cost_pp 	   In Number,
                                 X_Base_Burdened_Cost_pp   In Number,
                                 X_Base_Revenue_pp 	   In Number,
                                 X_Base_Quantity_pp        In Number,
                                 X_Base_Labor_Hours_pp     In Number,
                                 X_Base_Raw_Cost_ytd 	   In Number,
                                 X_Base_Burdened_Cost_ytd  In Number,
                                 X_Base_Revenue_ytd 	   In Number,
                                 X_Base_Quantity_ytd       In Number,
                                 X_Base_Labor_Hours_ytd    In Number,
                                 X_Base_Raw_Cost_itd 	   In Number,
                                 X_Base_Burdened_Cost_itd  In Number,
                                 X_Base_Revenue_itd 	   In Number,
                                 X_Base_Quantity_itd       In Number,
                                 X_Base_Labor_Hours_itd    In Number,
                                 X_Base_Unit_Of_Measure    In Varchar2,
                                 X_Orig_Raw_Cost_ptd 	   In Number,
                                 X_Orig_Burdened_Cost_ptd  In Number,
                                 X_Orig_Revenue_ptd 	   In Number,
                                 X_Orig_Quantity_ptd       In Number,
                                 X_Orig_Labor_Hours_ptd    In Number,
                                 X_Orig_Raw_Cost_pp  	   In Number,
                                 X_Orig_Burdened_Cost_pp   In Number,
                                 X_Orig_Revenue_pp  	   In Number,
                                 X_Orig_Quantity_pp        In Number,
                                 X_Orig_Labor_Hours_pp     In Number,
                                 X_Orig_Raw_Cost_ytd  	   In Number,
                                 X_Orig_Burdened_Cost_ytd  In Number,
                                 X_Orig_Revenue_ytd 	   In Number,
                                 X_Orig_Quantity_ytd       In Number,
                                 X_Orig_Labor_Hours_ytd    In Number,
                                 X_Orig_Raw_Cost_itd  	   In Number,
                                 X_Orig_Burdened_Cost_itd  In Number,
                                 X_Orig_Revenue_itd 	   In Number,
                                 X_Orig_Quantity_itd       In Number,
                                 X_Orig_Labor_Hours_itd    In Number,
                                 X_Orig_Unit_Of_Measure    In Varchar2,
                                 X_Recs_processed 	   Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     	   In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     	   In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      	   In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895
Recs_processed Number := 0;
V_Accum_id     Number := 0;
v_noof_tasks Number := 0;
V_oth_recs_processed  Number := 0;
V_Old_Stack       Varchar2(630);
Begin
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_BUDGETS.Process_all_tasks_bud';

      pa_debug.debug(x_err_stack);

      -- The follwing Update statement updates all records in the given task
      -- WBS hierarchy.It will update only the Project-task combination records
      -- and the Project level record (Task id = 0 and
      -- Resourcelist member id = 0)

        Update PA_PROJECT_ACCUM_BUDGETS PAB SET
         BASE_RAW_COST_ITD      = NVL(BASE_RAW_COST_ITD,0)+
				  NVL(X_Base_Raw_Cost_itd,0),
         BASE_RAW_COST_YTD      = NVL(BASE_RAW_COST_YTD,0)+
				  NVL(X_Base_Raw_Cost_ytd,0),
         BASE_RAW_COST_PTD      = NVL(BASE_RAW_COST_PTD,0)+
				  NVL(X_Base_Raw_Cost_ptd,0),
         BASE_RAW_COST_PP       = NVL(BASE_RAW_COST_PP,0) +
				  NVL(X_Base_Raw_Cost_pp,0),
         ORIG_RAW_COST_ITD      = NVL(ORIG_RAW_COST_ITD,0) +
				  NVL(X_Orig_Raw_Cost_itd,0),
         ORIG_RAW_COST_YTD      = NVL(ORIG_RAW_COST_YTD,0) +
				  NVL(X_Orig_Raw_Cost_ytd,0),
         ORIG_RAW_COST_PTD      = NVL(ORIG_RAW_COST_PTD,0) +
				  NVL(X_Orig_Raw_Cost_ptd,0),
         ORIG_RAW_COST_PP       = NVL(ORIG_RAW_COST_PP,0)  +
				  NVL(X_Orig_Raw_Cost_pp,0),
         BASE_BURDENED_COST_ITD = NVL(BASE_BURDENED_COST_ITD,0) +
                                  NVL(X_Base_Burdened_Cost_itd,0),
         BASE_BURDENED_COST_YTD = NVL(BASE_BURDENED_COST_YTD,0) +
                                  NVL(X_Base_Burdened_Cost_ytd,0),
         BASE_BURDENED_COST_PTD = NVL(BASE_BURDENED_COST_PTD,0) +
                                  NVL(X_Base_Burdened_Cost_ptd,0),
         BASE_BURDENED_COST_PP  = NVL(BASE_BURDENED_COST_PP,0)  +
                                  NVL(X_Base_Burdened_Cost_pp,0),
         ORIG_BURDENED_COST_ITD = NVL(ORIG_BURDENED_COST_ITD,0) +
                                  NVL(X_Orig_Burdened_Cost_itd,0),
         ORIG_BURDENED_COST_YTD = NVL(ORIG_BURDENED_COST_YTD,0) +
                                  NVL(X_Orig_Burdened_Cost_ytd,0),
         ORIG_BURDENED_COST_PTD = NVL(ORIG_BURDENED_COST_PTD,0) +
                                  NVL(X_Orig_Burdened_Cost_ptd,0),
         ORIG_BURDENED_COST_PP  = NVL(ORIG_BURDENED_COST_PP,0)  +
                                  NVL(X_Orig_Burdened_Cost_pp,0),
         BASE_LABOR_HOURS_ITD   = NVL(BASE_LABOR_HOURS_ITD,0) +
				  NVL(X_Base_Labor_Hours_itd,0),
         BASE_LABOR_HOURS_YTD   = NVL(BASE_LABOR_HOURS_YTD,0) +
				  NVL(X_Base_Labor_Hours_ytd,0),
         BASE_LABOR_HOURS_PTD   = NVL(BASE_LABOR_HOURS_PTD,0) +
				  NVL(X_Base_Labor_Hours_ptd,0),
         BASE_LABOR_HOURS_PP    = NVL(BASE_LABOR_HOURS_PP,0)  +
				  NVL(X_Base_Labor_Hours_pp,0),
         ORIG_LABOR_HOURS_ITD   = NVL(ORIG_LABOR_HOURS_ITD,0) +
				  NVL(X_Orig_Labor_Hours_itd,0),
         ORIG_LABOR_HOURS_YTD   = NVL(ORIG_LABOR_HOURS_YTD,0) +
				  NVL(X_Orig_Labor_Hours_ytd,0),
         ORIG_LABOR_HOURS_PTD   = NVL(ORIG_LABOR_HOURS_PTD,0) +
				  NVL(X_Orig_Labor_Hours_ptd,0),
         ORIG_LABOR_HOURS_PP    = NVL(ORIG_LABOR_HOURS_PP,0)  +
				  NVL(X_Orig_Labor_Hours_pp,0),
         BASE_QUANTITY_ITD      = NVL(BASE_QUANTITY_ITD,0) +
				  NVL(X_Base_Quantity_itd,0),
         BASE_QUANTITY_YTD      = NVL(BASE_QUANTITY_YTD,0) +
				  NVL(X_Base_Quantity_ytd,0),
         BASE_QUANTITY_PTD      = NVL(BASE_QUANTITY_PTD,0) +
				  NVL(X_Base_Quantity_ptd,0),
         BASE_QUANTITY_PP       = NVL(BASE_QUANTITY_PP,0)  +
				  NVL(X_Base_Quantity_pp,0),
         ORIG_QUANTITY_ITD      = NVL(ORIG_QUANTITY_ITD,0) +
				  NVL(X_Orig_Quantity_itd,0),
         ORIG_QUANTITY_YTD      = NVL(ORIG_QUANTITY_YTD,0) +
				  NVL(X_Orig_Quantity_ytd,0),
         ORIG_QUANTITY_PTD      = NVL(ORIG_QUANTITY_PTD,0) +
				  NVL(X_Orig_Quantity_ptd,0),
         ORIG_QUANTITY_PP       = NVL(ORIG_QUANTITY_PP,0)  +
				  NVL(X_Orig_Quantity_pp,0),
         BASE_REVENUE_ITD       = NVL(BASE_REVENUE_ITD,0) +
				  NVL(X_Base_Revenue_itd,0),
         BASE_REVENUE_YTD       = NVL(BASE_REVENUE_YTD,0) +
				  NVL(X_Base_Revenue_ytd,0),
         BASE_REVENUE_PTD       = NVL(BASE_REVENUE_PTD,0) +
				  NVL(X_Base_Revenue_ptd,0),
         BASE_REVENUE_PP        = NVL(BASE_REVENUE_PP,0)  +
				  NVL(X_Base_Revenue_pp,0),
         ORIG_REVENUE_ITD       = NVL(ORIG_REVENUE_ITD,0) +
				  NVL(X_Orig_Revenue_itd,0),
         ORIG_REVENUE_YTD       = NVL(ORIG_REVENUE_YTD,0)+
				  NVL(X_Orig_Revenue_ytd,0),
         ORIG_REVENUE_PTD       = NVL(ORIG_REVENUE_PTD,0) +
				  NVL(X_Orig_Revenue_ptd,0),
         ORIG_REVENUE_PP        = NVL(ORIG_REVENUE_PP,0) +
				  NVL(X_Orig_Revenue_pp,0),
         BASE_UNIT_OF_MEASURE   = X_Base_Unit_of_Measure,
         ORIG_UNIT_OF_MEASURE   = X_Orig_Unit_of_Measure,
         LAST_UPDATED_BY        = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE       = Trunc(Sysdate),
         LAST_UPDATE_LOGIN      = pa_proj_accum_main.x_last_update_login
         Where Budget_Type_Code = x_Budget_type_code
         And PAB.Project_Accum_id     In
         (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = 0 and
         Pah.Task_id in (Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id)
         UNION select  to_number(X_Proj_accum_id) from sys.dual);

         Recs_processed := Recs_processed + SQL%ROWCOUNT;

    x_recs_processed := Recs_processed;
--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
Exception
     When Others Then
        x_err_code := SQLCODE;
        RAISE;
End Process_all_tasks_bud;

Procedure   Process_it_yt_pt_tasks_bud
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_Proj_Accum_Id In Number,
                                 x_budget_type_code In Varchar2,
                                 x_current_period In Varchar2,
                                 X_Base_Revenue In Number,
                                 X_Base_Raw_Cost In Number,
                                 X_Base_Burdened_Cost In Number,
                                 X_Base_Labor_Hours In Number,
                                 X_Base_Quantity    In Number,
                                 X_Base_Unit_Of_Measure In Varchar2,
                                 X_Orig_Revenue In Number,
                                 X_Orig_Raw_Cost In Number,
                                 X_Orig_Burdened_Cost In Number,
                                 X_Orig_Labor_Hours In Number,
                                 X_Orig_Quantity    In Number,
                                 X_Orig_Unit_Of_Measure In Varchar2,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895


-- Process_it_yt_pt_tasks_bud - Processes ITD,YTD and PTD amounts in the
--                          PA_PROJECT_ACCUM_BUDGETS table. For the
--                          given Project-Task combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.

Recs_processed Number := 0;
V_Accum_id     Number := 0;
v_noof_tasks Number := 0;
V_oth_recs_processed  Number := 0;
V_Old_Stack       Varchar2(630);
Begin
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_BUDGETS.Process_it_yt_pt_tasks_bud';

      pa_debug.debug(x_err_stack);

      -- The follwing Update statement updates all records in the given task
      -- WBS hierarchy.It will update only the Project-task combination records
      -- and the Project level record (Task id = 0 and Resourcelist member id = 0)

        Update PA_PROJECT_ACCUM_BUDGETS  PAB SET
         BASE_RAW_COST_ITD      = NVL(BASE_RAW_COST_ITD,0) + X_Base_Raw_Cost,
         BASE_RAW_COST_YTD      = NVL(BASE_RAW_COST_YTD,0) + X_Base_Raw_Cost,
         BASE_RAW_COST_PTD      = NVL(BASE_RAW_COST_PTD,0) + X_Base_Raw_Cost,
         ORIG_RAW_COST_ITD      = ORIG_RAW_COST_ITD + X_Orig_Raw_Cost,
         ORIG_RAW_COST_YTD      = ORIG_RAW_COST_YTD + X_Orig_Raw_Cost,
         ORIG_RAW_COST_PTD      = ORIG_RAW_COST_PTD + X_Orig_Raw_Cost,
         BASE_BURDENED_COST_ITD = BASE_BURDENED_COST_ITD +
                                  X_Base_Burdened_Cost,
         BASE_BURDENED_COST_YTD = BASE_BURDENED_COST_YTD +
                                  X_Base_Burdened_Cost,
         BASE_BURDENED_COST_PTD = BASE_BURDENED_COST_PTD +
                                  X_Base_Burdened_Cost,
         ORIG_BURDENED_COST_ITD = ORIG_BURDENED_COST_ITD +
                                  X_Orig_Burdened_Cost,
         ORIG_BURDENED_COST_YTD = ORIG_BURDENED_COST_YTD +
                                  X_Orig_Burdened_Cost,
         ORIG_BURDENED_COST_PTD = ORIG_BURDENED_COST_PTD +
                                  X_Orig_Burdened_Cost,
         BASE_LABOR_HOURS_ITD   = BASE_LABOR_HOURS_ITD + X_Base_Labor_Hours,
         BASE_LABOR_HOURS_YTD   = BASE_LABOR_HOURS_YTD + X_Base_Labor_Hours,
         BASE_LABOR_HOURS_PTD   = BASE_LABOR_HOURS_PTD + X_Base_Labor_Hours,
         ORIG_LABOR_HOURS_ITD   = ORIG_LABOR_HOURS_ITD + X_Orig_Labor_Hours,
         ORIG_LABOR_HOURS_YTD   = ORIG_LABOR_HOURS_YTD + X_Orig_Labor_Hours,
         ORIG_LABOR_HOURS_PTD   = ORIG_LABOR_HOURS_PTD + X_Orig_Labor_Hours,
         BASE_QUANTITY_ITD      = BASE_QUANTITY_ITD + X_Base_Quantity,
         BASE_QUANTITY_YTD      = BASE_QUANTITY_YTD + X_Base_Quantity,
         BASE_QUANTITY_PTD      = BASE_QUANTITY_PTD + X_Base_Quantity,
         ORIG_QUANTITY_ITD      = ORIG_QUANTITY_ITD + X_Orig_Quantity,
         ORIG_QUANTITY_YTD      = ORIG_QUANTITY_YTD + X_Orig_Quantity,
         ORIG_QUANTITY_PTD      = ORIG_QUANTITY_PTD + X_Orig_Quantity,
         BASE_REVENUE_ITD       = BASE_REVENUE_ITD + X_Base_Revenue,
         BASE_REVENUE_YTD       = BASE_REVENUE_YTD + X_Base_Revenue,
         BASE_REVENUE_PTD       = BASE_REVENUE_PTD + X_Base_Revenue,
         ORIG_REVENUE_ITD       = ORIG_REVENUE_ITD + X_Orig_Revenue,
         ORIG_REVENUE_YTD       = ORIG_REVENUE_YTD + X_Orig_Revenue,
         ORIG_REVENUE_PTD       = ORIG_REVENUE_PTD + X_Orig_Revenue,
         BASE_UNIT_OF_MEASURE   = X_Base_Unit_of_Measure,
         ORIG_UNIT_OF_MEASURE   = X_Orig_Unit_of_Measure,
         LAST_UPDATED_BY        = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE       = Trunc(Sysdate),
         LAST_UPDATE_LOGIN      = pa_proj_accum_main.x_last_update_login
         Where Budget_Type_Code = x_Budget_type_code
         And PAB.Project_Accum_id     In
         (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = 0 and
         Pah.Task_id in (Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id)
         UNION select  to_number(X_Proj_accum_id) from sys.dual);

         Recs_processed := Recs_processed + SQL%ROWCOUNT;

    x_recs_processed := Recs_processed;
--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
Exception
     When Others Then
        x_err_code := SQLCODE;
        RAISE;
End Process_it_yt_pt_tasks_bud;

Procedure   Process_it_yt_pp_tasks_bud
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_Proj_Accum_Id In Number,
                                 x_budget_type_code In Varchar2,
                                 x_current_period In Varchar2,
                                 X_Base_Revenue In Number,
                                 X_Base_Raw_Cost In Number,
                                 X_Base_Burdened_Cost In Number,
                                 X_Base_Labor_Hours In Number,
                                 X_Base_Quantity    In Number,
                                 X_Base_Unit_Of_Measure In Varchar2,
                                 X_Orig_Revenue In Number,
                                 X_Orig_Raw_Cost In Number,
                                 X_Orig_Burdened_Cost In Number,
                                 X_Orig_Labor_Hours In Number,
                                 X_Orig_Quantity    In Number,
                                 X_Orig_Unit_Of_Measure In Varchar2,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895


-- Process_it_yt_pp_tasks_bud - Processes ITD,YTD and PP  amounts in the
--                          PA_PROJECT_ACCUM_BUDGETS table. For the
--                          given Project-Task combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.

Recs_processed        Number := 0;
V_Accum_id            Number := 0;
v_noof_tasks          Number := 0;
V_oth_recs_processed  Number := 0;
V_Old_Stack       Varchar2(630);
Begin
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_BUDGETS.Process_it_yt_pp_tasks_bud';

      pa_debug.debug(x_err_stack);

      -- The follwing Update statement updates all records in the given task
      -- WBS hierarchy.It will update only the Project-task combination records
      -- and the Project level record (Task id = 0 and Resourcelist member id = 0)
        Update PA_PROJECT_ACCUM_BUDGETS  PAB SET
         BASE_RAW_COST_ITD      = NVL(BASE_RAW_COST_ITD,0) + X_Base_Raw_Cost,
         BASE_RAW_COST_YTD      = NVL(BASE_RAW_COST_YTD,0) + X_Base_Raw_Cost,
         BASE_RAW_COST_PP       = NVL(BASE_RAW_COST_PP,0) + X_Base_Raw_Cost,
         ORIG_RAW_COST_ITD      = ORIG_RAW_COST_ITD + X_Orig_Raw_Cost,
         ORIG_RAW_COST_YTD      = ORIG_RAW_COST_YTD + X_Orig_Raw_Cost,
         ORIG_RAW_COST_PP       = ORIG_RAW_COST_PP + X_Orig_Raw_Cost,
         BASE_BURDENED_COST_ITD = BASE_BURDENED_COST_ITD +
                                  X_Base_Burdened_Cost,
         BASE_BURDENED_COST_YTD = BASE_BURDENED_COST_YTD +
                                  X_Base_Burdened_Cost,
         BASE_BURDENED_COST_PP  = BASE_BURDENED_COST_PP +
                                  X_Base_Burdened_Cost,
         ORIG_BURDENED_COST_ITD = ORIG_BURDENED_COST_ITD +
                                  X_Orig_Burdened_Cost,
         ORIG_BURDENED_COST_YTD = ORIG_BURDENED_COST_YTD +
                                  X_Orig_Burdened_Cost,
         ORIG_BURDENED_COST_PP  = ORIG_BURDENED_COST_PP +
                                  X_Orig_Burdened_Cost,
         BASE_LABOR_HOURS_ITD   = BASE_LABOR_HOURS_ITD + X_Base_Labor_Hours,
         BASE_LABOR_HOURS_YTD   = BASE_LABOR_HOURS_YTD + X_Base_Labor_Hours,
         BASE_LABOR_HOURS_PP    = BASE_LABOR_HOURS_PP + X_Base_Labor_Hours,
         ORIG_LABOR_HOURS_ITD   = ORIG_LABOR_HOURS_ITD + X_Orig_Labor_Hours,
         ORIG_LABOR_HOURS_YTD   = oRIG_LABOR_HOURS_YTD + X_Orig_Labor_Hours,
         ORIG_LABOR_HOURS_PP    = ORIG_LABOR_HOURS_PP + X_Orig_Labor_Hours,
         BASE_QUANTITY_ITD      = BASE_QUANTITY_ITD + X_Base_Quantity,
         BASE_QUANTITY_YTD      = BASE_QUANTITY_YTD + X_Base_Quantity,
         BASE_QUANTITY_PP       = BASE_QUANTITY_PP + X_Base_Quantity,
         ORIG_QUANTITY_ITD      = ORIG_QUANTITY_ITD + X_Orig_Quantity,
         ORIG_QUANTITY_YTD      = ORIG_QUANTITY_YTD + X_Orig_Quantity,
         ORIG_QUANTITY_PP       = ORIG_QUANTITY_PP + X_Orig_Quantity,
         BASE_REVENUE_ITD       = BASE_REVENUE_ITD + X_Base_Revenue,
         BASE_REVENUE_YTD       = BASE_REVENUE_YTD + X_Base_Revenue,
         BASE_REVENUE_PP        = BASE_REVENUE_PP + X_Base_Revenue,
         ORIG_REVENUE_ITD       = ORIG_REVENUE_ITD + X_Orig_Revenue,
         ORIG_REVENUE_YTD       = ORIG_REVENUE_YTD + X_Orig_Revenue,
         ORIG_REVENUE_PP        = ORIG_REVENUE_PP + X_Orig_Revenue,
         BASE_UNIT_OF_MEASURE   = X_Base_Unit_of_Measure,
         ORIG_UNIT_OF_MEASURE   = X_Orig_Unit_of_Measure,
         LAST_UPDATED_BY        = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE       = Trunc(Sysdate),
         LAST_UPDATE_LOGIN      = pa_proj_accum_main.x_last_update_login
         Where Budget_Type_Code = x_Budget_type_code
         And PAB.Project_Accum_id     In
         (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = 0 and
         Pah.Task_id in (Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id)
         UNION select  to_number(X_Proj_accum_id) from sys.dual);
         Recs_processed := Recs_processed + SQL%ROWCOUNT;

    x_recs_processed := Recs_processed;
--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;

Exception
     When Others Then
        x_err_code := SQLCODE;
        RAISE;
End Process_it_yt_pp_tasks_bud;

Procedure   Process_it_pp_tasks_bud
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_Proj_Accum_Id In Number,
                                 x_budget_type_code In Varchar2,
                                 x_current_period In Varchar2,
                                 X_Base_Revenue In Number,
                                 X_Base_Raw_Cost In Number,
                                 X_Base_Burdened_Cost In Number,
                                 X_Base_Labor_Hours In Number,
                                 X_Base_Quantity    In Number,
                                 X_Base_Unit_Of_Measure In Varchar2,
                                 X_Orig_Revenue In Number,
                                 X_Orig_Raw_Cost In Number,
                                 X_Orig_Burdened_Cost In Number,
                                 X_Orig_Labor_Hours In Number,
                                 X_Orig_Quantity    In Number,
                                 X_Orig_Unit_Of_Measure In Varchar2,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895


-- Process_it_pp_tasks_bud   -  Processes ITD and PP amounts in the
--                          PA_PROJECT_ACCUM_BUDGETS table. For the
--                          given Project-Task combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.

Recs_processed       Number := 0;
V_Accum_id           Number := 0;
v_noof_tasks         Number := 0;
V_oth_recs_processed Number := 0;
V_Old_Stack       Varchar2(630);
Begin

      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_BUDGETS.Process_it_pp_tasks_bud';

      pa_debug.debug(x_err_stack);

      -- The follwing Update statement updates all records in the given task
      -- WBS hierarchy.It will update only the Project-task combination records
      -- and the Project level record (Task id = 0 and Resourcelist member id = 0)
        Update PA_PROJECT_ACCUM_BUDGETS  PAB SET
         BASE_RAW_COST_ITD      = NVL(BASE_RAW_COST_ITD,0) + X_Base_Raw_Cost,
         BASE_RAW_COST_PP       = NVL(BASE_RAW_COST_PP,0) + X_Base_Raw_Cost,
         ORIG_RAW_COST_ITD      = ORIG_RAW_COST_ITD + X_Orig_Raw_Cost,
         ORIG_RAW_COST_PP       = ORIG_RAW_COST_PP + X_Orig_Raw_Cost,
         BASE_BURDENED_COST_ITD = BASE_BURDENED_COST_ITD +
                                  X_Base_Burdened_Cost,
         BASE_BURDENED_COST_PP  = BASE_BURDENED_COST_PP +
                                  X_Base_Burdened_Cost,
         ORIG_BURDENED_COST_ITD = ORIG_BURDENED_COST_ITD +
                                  X_Orig_Burdened_Cost,
         ORIG_BURDENED_COST_PP  = ORIG_BURDENED_COST_PP +
                                  X_Orig_Burdened_Cost,
         BASE_LABOR_HOURS_ITD   = BASE_LABOR_HOURS_ITD + X_Base_Labor_Hours,
         BASE_LABOR_HOURS_PP    = BASE_LABOR_HOURS_PP + X_Base_Labor_Hours,
         ORIG_LABOR_HOURS_ITD   = ORIG_LABOR_HOURS_ITD + X_Orig_Labor_Hours,
         ORIG_LABOR_HOURS_PP    = ORIG_LABOR_HOURS_PP + X_Orig_Labor_Hours,
         BASE_QUANTITY_ITD      = BASE_QUANTITY_ITD + X_Base_Quantity,
         BASE_QUANTITY_PP       = BASE_QUANTITY_PP + X_Base_Quantity,
         ORIG_QUANTITY_ITD      = ORIG_QUANTITY_ITD + X_Orig_Quantity,
         ORIG_QUANTITY_PP       = ORIG_QUANTITY_PP + X_Orig_Quantity,
         BASE_REVENUE_ITD       = BASE_REVENUE_ITD + X_Base_Revenue,
         BASE_REVENUE_PP        = BASE_REVENUE_PP + X_Base_Revenue,
         ORIG_REVENUE_ITD       = ORIG_REVENUE_ITD + X_Orig_Revenue,
         ORIG_REVENUE_PP        = ORIG_REVENUE_PP + X_Orig_Revenue,
         BASE_UNIT_OF_MEASURE   = X_Base_Unit_of_Measure,
         ORIG_UNIT_OF_MEASURE   = X_Orig_Unit_of_Measure,
         LAST_UPDATED_BY        = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE       = Trunc(Sysdate),
         LAST_UPDATE_LOGIN      = pa_proj_accum_main.x_last_update_login
         Where Budget_Type_Code = x_Budget_type_code
         And PAB.Project_Accum_id     In
         (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = 0 and
         Pah.Task_id in (Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id)
         UNION select  to_number(X_Proj_accum_id) from sys.dual);
         Recs_processed := Recs_processed + SQL%ROWCOUNT;

    x_recs_processed := Recs_processed;

--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
Exception
     When Others Then
        x_err_code := SQLCODE;
        RAISE;
End Process_it_pp_tasks_bud;

Procedure   Process_it_yt_tasks_bud
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_Proj_Accum_Id In Number,
                                 x_budget_type_code In Varchar2,
                                 x_current_period In Varchar2,
                                 X_Base_Revenue In Number,
                                 X_Base_Raw_Cost In Number,
                                 X_Base_Burdened_Cost In Number,
                                 X_Base_Labor_Hours In Number,
                                 X_Base_Quantity    In Number,
                                 X_Base_Unit_Of_Measure In Varchar2,
                                 X_Orig_Revenue In Number,
                                 X_Orig_Raw_Cost In Number,
                                 X_Orig_Burdened_Cost In Number,
                                 X_Orig_Labor_Hours In Number,
                                 X_Orig_Quantity    In Number,
                                 X_Orig_Unit_Of_Measure In Varchar2,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895


-- Process_it_yt_tasks_bud   -  Processes ITD and YTD amounts in the
--                          PA_PROJECT_ACCUM_BUDGETS table. For the
--                          given Project-Task combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.

Recs_processed        Number := 0;
V_Accum_id            Number := 0;
v_noof_tasks          Number := 0;
V_oth_recs_processed  Number := 0;
V_Old_Stack       Varchar2(630);
Begin

      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_BUDGETS.Process_it_yt_tasks_bud';

      pa_debug.debug(x_err_stack);

      -- The follwing Update statement updates all records in the given task
      -- WBS hierarchy.It will update only the Project-task combination records
      -- and the Project level record (Task id = 0 and Resourcelist member id = 0)
        Update PA_PROJECT_ACCUM_BUDGETS  PAB SET
         BASE_RAW_COST_ITD      = NVL(BASE_RAW_COST_ITD,0) + X_Base_Raw_Cost,
         BASE_RAW_COST_YTD      = NVL(BASE_RAW_COST_YTD,0) + X_Base_Raw_Cost,
         ORIG_RAW_COST_ITD      = ORIG_RAW_COST_ITD + X_Orig_Raw_Cost,
         ORIG_RAW_COST_YTD      = ORIG_RAW_COST_YTD + X_Orig_Raw_Cost,
         BASE_BURDENED_COST_ITD = BASE_BURDENED_COST_ITD +
                                  X_Base_Burdened_Cost,
         BASE_BURDENED_COST_YTD = BASE_BURDENED_COST_YTD +
                                  X_Base_Burdened_Cost,
         ORIG_BURDENED_COST_ITD = ORIG_BURDENED_COST_ITD +
                                  X_Orig_Burdened_Cost,
         ORIG_BURDENED_COST_YTD = ORIG_BURDENED_COST_YTD +
                                  X_Orig_Burdened_Cost,
         BASE_LABOR_HOURS_ITD   = BASE_LABOR_HOURS_ITD + X_Base_Labor_Hours,
         BASE_LABOR_HOURS_YTD   = BASE_LABOR_HOURS_YTD + X_Base_Labor_Hours,
         ORIG_LABOR_HOURS_ITD   = ORIG_LABOR_HOURS_ITD + X_Orig_Labor_Hours,
         ORIG_LABOR_HOURS_YTD   = ORIG_LABOR_HOURS_YTD + X_Orig_Labor_Hours,
         BASE_QUANTITY_ITD      = BASE_QUANTITY_ITD + X_Base_Quantity,
         BASE_QUANTITY_YTD      = BASE_QUANTITY_YTD + X_Base_Quantity,
         ORIG_QUANTITY_ITD      = ORIG_QUANTITY_ITD + X_Orig_Quantity,
         ORIG_QUANTITY_YTD      = ORIG_QUANTITY_YTD + X_Orig_Quantity,
         BASE_REVENUE_ITD       = BASE_REVENUE_ITD + X_Base_Revenue,
         BASE_REVENUE_YTD       = BASE_REVENUE_YTD + X_Base_Revenue,
         ORIG_REVENUE_ITD       = ORIG_REVENUE_ITD + X_Orig_Revenue,
         ORIG_REVENUE_YTD       = ORIG_REVENUE_YTD + X_Orig_Revenue,
         BASE_UNIT_OF_MEASURE   = X_Base_Unit_of_Measure,
         ORIG_UNIT_OF_MEASURE   = X_Orig_Unit_of_Measure,
         LAST_UPDATED_BY        = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE       = Trunc(Sysdate),
         LAST_UPDATE_LOGIN      = pa_proj_accum_main.x_last_update_login
         Where Budget_Type_Code = x_Budget_type_code
         And PAB.Project_Accum_id     In
         (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = 0 and
         Pah.Task_id in (Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id)
         UNION select  to_number(X_Proj_accum_id) from sys.dual);
         Recs_processed := Recs_processed + SQL%ROWCOUNT;

--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
    x_recs_processed := Recs_processed;
Exception
     When Others Then
        x_err_code := SQLCODE;
        RAISE;
End Process_it_yt_tasks_bud;

Procedure   Process_it_tasks_bud
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_Proj_Accum_Id In Number,
                                 x_budget_type_code In Varchar2,
                                 x_current_period In Varchar2,
                                 X_Base_Revenue In Number,
                                 X_Base_Raw_Cost In Number,
                                 X_Base_Burdened_Cost In Number,
                                 X_Base_Labor_Hours In Number,
                                 X_Base_Quantity    In Number,
                                 X_Base_Unit_Of_Measure In Varchar2,
                                 X_Orig_Revenue In Number,
                                 X_Orig_Raw_Cost In Number,
                                 X_Orig_Burdened_Cost In Number,
                                 X_Orig_Labor_Hours In Number,
                                 X_Orig_Quantity    In Number,
                                 X_Orig_Unit_Of_Measure In Varchar2,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895


-- Process_it_tasks_bud      -  Processes ITD amounts in the
--                          PA_PROJECT_ACCUM_BUDGETS table. For the
--                          given Project-Task combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.

Recs_processed        Number := 0;
V_Accum_id            Number := 0;
v_noof_tasks          Number := 0;
V_oth_recs_processed  Number := 0;
V_Old_Stack       Varchar2(630);
Begin

      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_BUDGETS.Process_it_tasks_bud';

      pa_debug.debug(x_err_stack);

       -- The follwing Update statement updates all records in the given task
       -- WBS hierarchy.It will update only the Project-task combination records
       -- and the Project level record (Task id = 0 and Resourcelist member id = 0)
        Update PA_PROJECT_ACCUM_BUDGETS  PAB SET
         BASE_RAW_COST_ITD      = NVL(BASE_RAW_COST_ITD,0) + X_Base_Raw_Cost,
         ORIG_RAW_COST_ITD      = ORIG_RAW_COST_ITD + X_Orig_Raw_Cost,
         BASE_BURDENED_COST_ITD = BASE_BURDENED_COST_ITD +
                                  X_Base_Burdened_Cost,
         ORIG_BURDENED_COST_ITD = ORIG_BURDENED_COST_ITD +
                                  X_Orig_Burdened_Cost,
         BASE_LABOR_HOURS_ITD   = BASE_LABOR_HOURS_ITD + X_Base_Labor_Hours,
         ORIG_LABOR_HOURS_ITD   = ORIG_LABOR_HOURS_ITD + X_Orig_Labor_Hours,
         BASE_QUANTITY_ITD      = BASE_QUANTITY_ITD + X_Base_Quantity,
         ORIG_QUANTITY_ITD      = ORIG_QUANTITY_ITD + X_Orig_Quantity,
         BASE_REVENUE_ITD       = BASE_REVENUE_ITD + X_Base_Revenue,
         ORIG_REVENUE_ITD       = ORIG_REVENUE_ITD + X_Orig_Revenue,
         BASE_UNIT_OF_MEASURE   = X_Base_Unit_of_Measure,
         ORIG_UNIT_OF_MEASURE   = X_Orig_Unit_of_Measure,
         LAST_UPDATED_BY        = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE       = Trunc(Sysdate),
         LAST_UPDATE_LOGIN      = pa_proj_accum_main.x_last_update_login
         Where Budget_Type_Code = x_Budget_type_code
         And PAB.Project_Accum_id     In
         (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = 0 and
         Pah.Task_id in (Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id)
         UNION select  to_number(X_Proj_accum_id) from sys.dual);
         Recs_processed := Recs_processed + SQL%ROWCOUNT;

--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
    x_recs_processed := Recs_processed;
Exception
     When Others Then
        x_err_code := SQLCODE;
        RAISE;
End Process_it_tasks_bud;

END;

/
