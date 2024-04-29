--------------------------------------------------------
--  DDL for Package Body PA_PROCESS_ACCUM_BUDGETS_RES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROCESS_ACCUM_BUDGETS_RES" AS
/* $Header: PABURESB.pls 120.2 2005/08/31 11:08:08 vmangulu noship $ */

-- Modified on 10/29/98 by S Sanckar to include a new procedure
-- Process_all_res_bud that updates the raw_cost, burdened_cost, quantity,
-- labor_quantity and revenue values for baselined and original budgets
-- This will update the amount columns for period_to_date and prior_period
-- and year_to_date apart from inception_to_date periods.

Procedure   Process_all_res_bud
                                (x_project_id 		   In Number,
                                 x_task_id 		   In Number,
                                 x_resource_list_id 	   In Number,
                                 x_resource_list_Member_id In Number,
                                 x_resource_id 		   In Number,
                                 x_resource_list_assignment_id In Number,
                                 x_rollup_qty_flag         In Varchar2,
                                 x_budget_type_code 	   In Varchar2,
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

Recs_processed         Number := 0;
V_Accum_id             Number := 0;
V_task_array           task_id_tabtype;
v_noof_tasks           Number := 0;
V_Orig_Qty_ptd         Number := 0;
V_Orig_Qty_pp          Number := 0;
V_Orig_Qty_ytd         Number := 0;
V_Orig_Qty_itd         Number := 0;
V_Base_Qty_ptd         Number := 0;
V_Base_Qty_pp          Number := 0;
V_Base_Qty_ytd         Number := 0;
V_Base_Qty_itd         Number := 0;
Res_Recs_processed     Number := 0;
V_Old_Stack       Varchar2(630);

Begin

      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_BUDGETS_RES.Process_all_res_bud';

      pa_debug.debug(x_err_stack);

      -- Quantity would be rolledup only if the Rollup_Quantity_flag against the
      -- Resource is 'Y'

        If  x_rollup_qty_flag = 'Y' Then
            V_Base_Qty_ptd := X_Base_Quantity_ptd;
            V_Base_Qty_pp  := X_Base_Quantity_pp ;
            V_Base_Qty_ytd := X_Base_Quantity_ytd;
            V_Base_Qty_itd := X_Base_Quantity_itd;
            V_Orig_Qty_ptd := X_Orig_Quantity_ptd;
            V_Orig_Qty_pp  := X_Orig_Quantity_pp ;
            V_Orig_Qty_ytd := X_Orig_Quantity_ytd;
            V_Orig_Qty_itd := X_Orig_Quantity_itd;
        Else
            V_Base_Qty_ptd := 0;
            V_Base_Qty_pp  := 0;
            V_Base_Qty_ytd := 0;
            V_Base_Qty_itd := 0;
            V_Orig_Qty_ptd := 0;
            V_Orig_Qty_pp  := 0;
            V_Orig_Qty_ytd := 0;
            V_Orig_Qty_itd := 0;
        End If;

-- The following Update statement updates all records in the given task
-- WBS hierarchy.It will update only the Project-task-resource combination
-- records and the Project-Resource level record(Task id = 0 and
-- Resourcelist member id <> 0)

        Update PA_PROJECT_ACCUM_BUDGETS  PAB SET
         BASE_RAW_COST_ITD      = NVL(BASE_RAW_COST_ITD,0) +
				  NVL(X_Base_Raw_Cost_itd,0),
         BASE_RAW_COST_YTD      = NVL(BASE_RAW_COST_YTD,0) +
				  NVL(X_Base_Raw_Cost_ytd,0),
         BASE_RAW_COST_PTD      = NVL(BASE_RAW_COST_PTD,0) +
				  NVL(X_Base_Raw_Cost_ptd,0),
         BASE_RAW_COST_PP       = NVL(BASE_RAW_COST_PP,0)  +
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
				  NVL(V_Base_Qty_itd,0),
         BASE_QUANTITY_YTD      = NVL(BASE_QUANTITY_YTD,0) +
				  NVL(V_Base_Qty_ytd,0),
         BASE_QUANTITY_PTD      = NVL(BASE_QUANTITY_PTD,0) +
				  NVL(V_Base_Qty_ptd,0),
         BASE_QUANTITY_PP       = NVL(BASE_QUANTITY_PP,0)  +
				  NVL(V_Base_Qty_pp,0),
         ORIG_QUANTITY_ITD      = NVL(ORIG_QUANTITY_ITD,0) +
				  NVL(V_Orig_Qty_itd,0),
         ORIG_QUANTITY_YTD      = NVL(ORIG_QUANTITY_YTD,0) +
				  NVL(V_Orig_Qty_ytd,0),
         ORIG_QUANTITY_PTD      = NVL(ORIG_QUANTITY_PTD,0) +
				  NVL(V_Orig_Qty_ptd,0),
         ORIG_QUANTITY_PP       = NVL(ORIG_QUANTITY_PP,0)  +
				  NVL(V_Orig_Qty_pp,0),
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
         ORIG_REVENUE_YTD       = NVL(ORIG_REVENUE_YTD,0) +
				  NVL(X_Orig_Revenue_ytd,0),
         ORIG_REVENUE_PTD       = NVL(ORIG_REVENUE_PTD,0) +
				  NVL(X_Orig_Revenue_ptd,0),
         ORIG_REVENUE_PP        = NVL(ORIG_REVENUE_PP,0)  +
				  NVL(X_Orig_Revenue_pp,0),
         BASE_UNIT_OF_MEASURE   = X_Base_Unit_of_Measure,
         ORIG_UNIT_OF_MEASURE   = X_Orig_Unit_of_Measure,
         LAST_UPDATED_BY        = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE       = Trunc(Sysdate),
         LAST_UPDATE_LOGIN      = pa_proj_accum_main.x_last_update_login
         Where Budget_Type_Code = x_Budget_type_code
         And (PAB.Project_Accum_id     In
         (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = x_resource_list_member_id and
          Pah.Task_id in (select 0 from sys.dual union
         Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id))) ;

    x_recs_processed := Recs_processed;
--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
Exception
  When Others Then
       x_err_code := SQLCODE;
       RAISE;
End Process_all_res_bud;

Procedure   Process_it_yt_pt_res_bud
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_resource_list_id in Number,
                                 x_resource_list_Member_id in Number,
                                 x_resource_id in Number,
                                 x_resource_list_assignment_id in Number,
                                 x_rollup_qty_flag In Varchar2,
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


-- Process_it_yt_pt_res_bud   - Processes ITD,YTD and PTD amounts in the
--                          PA_PROJECT_ACCUM_BUDGETS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks. The Project-Resource records
--                          are also created/updated.
Recs_processed         Number := 0;
V_Accum_id             Number := 0;
V_task_array           task_id_tabtype;
v_noof_tasks           Number := 0;
V_Orig_Qty             Number := 0;
V_Base_Qty             Number := 0;
Res_Recs_processed     Number := 0;
V_Old_Stack       Varchar2(630);

Begin

      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_BUDGETS_RES.Process_it_yt_pt_res_bud';

      pa_debug.debug(x_err_stack);

      -- Quantity would be rolledup only if the Rollup_Quantity_flag against the
      -- Resource is 'Y'

        If  x_rollup_qty_flag = 'Y' Then
            V_Base_Qty := X_Base_Quantity;
            V_Orig_Qty := X_Orig_Quantity;
        Else
            V_Base_Qty := 0;
            V_Orig_Qty := 0;
        End If;

-- The follwing Update statement updates all records in the given task
-- WBS hierarchy.It will update only the Project-task-resource combination
-- records and the Project-Resource level record(Task id = 0 and
-- Resourcelist member id <> 0)

        Update PA_PROJECT_ACCUM_BUDGETS  PAB SET
         BASE_RAW_COST_ITD      = BASE_RAW_COST_ITD + X_Base_Raw_Cost,
         BASE_RAW_COST_YTD      = BASE_RAW_COST_YTD + X_Base_Raw_Cost,
         BASE_RAW_COST_PTD      = BASE_RAW_COST_PTD + X_Base_Raw_Cost,
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
         BASE_QUANTITY_ITD      = BASE_QUANTITY_ITD + V_Base_Qty,
         BASE_QUANTITY_YTD      = BASE_QUANTITY_YTD + V_Base_Qty,
         BASE_QUANTITY_PTD      = BASE_QUANTITY_PTD + V_Base_Qty,
         ORIG_QUANTITY_ITD      = ORIG_QUANTITY_ITD + V_Orig_Qty,
         ORIG_QUANTITY_YTD      = ORIG_QUANTITY_YTD + V_Orig_Qty,
         ORIG_QUANTITY_PTD      = ORIG_QUANTITY_PTD + V_Orig_Qty,
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
         And (PAB.Project_Accum_id     In
         (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = x_resource_list_member_id and
          Pah.Task_id in (select 0 from sys.dual union
         Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id))) ;

    x_recs_processed := Recs_processed;
--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
Exception
  When Others Then
       x_err_code := SQLCODE;
       RAISE;
End Process_it_yt_pt_res_bud;

Procedure   Process_it_yt_pp_res_bud
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_resource_list_id in Number,
                                 x_resource_list_Member_id in Number,
                                 x_resource_id in Number,
                                 x_resource_list_assignment_id in Number,
                                 x_rollup_qty_flag In Varchar2,
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


-- Process_it_yt_pp_res_bud   - Processes ITD,YTD and PP  amounts in the
--                          PA_PROJECT_ACCUM_BUDGETS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.  The Project-Resource records
--                          are also created/updated.
Recs_processed         Number := 0;
V_Accum_id             Number := 0;
V_task_array           task_id_tabtype;
v_noof_tasks           Number := 0;
V_Orig_Qty             Number := 0;
V_Base_Qty             Number := 0;
Res_Recs_processed     Number := 0;
V_Old_Stack       Varchar2(630);

Begin
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_BUDGETS_RES.Process_it_yt_pp_res_bud';

      pa_debug.debug(x_err_stack);

-- Quantity would be rolledup only if the Rollup_Quantity_flag against the
-- Resource is 'Y'

        If  x_rollup_qty_flag = 'Y' Then
            V_Base_Qty := X_Base_Quantity;
            V_Orig_Qty := X_Orig_Quantity;
        Else
            V_Base_Qty := 0;
            V_Orig_Qty := 0;
        End If;

-- The follwing Update statement updates all records in the given task
-- WBS hierarchy.It will update only the Project-task-resource combination
-- records and the Project-Resource level record(Task id = 0 and
-- Resourcelist member id <> 0)

        Update PA_PROJECT_ACCUM_BUDGETS  PAB SET
         BASE_RAW_COST_ITD       = BASE_RAW_COST_ITD + X_Base_Raw_Cost,
         BASE_RAW_COST_YTD       = BASE_RAW_COST_YTD + X_Base_Raw_Cost,
         BASE_RAW_COST_PP        = BASE_RAW_COST_PP + X_Base_Raw_Cost,
         ORIG_RAW_COST_ITD       = ORIG_RAW_COST_ITD + X_Orig_Raw_Cost,
         ORIG_RAW_COST_YTD       = ORIG_RAW_COST_YTD + X_Orig_Raw_Cost,
         ORIG_RAW_COST_PP        = ORIG_RAW_COST_PP + X_Orig_Raw_Cost,
         BASE_BURDENED_COST_ITD  = BASE_BURDENED_COST_ITD +
                                   X_Base_Burdened_Cost,
         BASE_BURDENED_COST_YTD  = BASE_BURDENED_COST_YTD +
                                   X_Base_Burdened_Cost,
         BASE_BURDENED_COST_PP   = BASE_BURDENED_COST_PP +
                                   X_Base_Burdened_Cost,
         ORIG_BURDENED_COST_ITD  = ORIG_BURDENED_COST_ITD +
                                   X_Orig_Burdened_Cost,
         ORIG_BURDENED_COST_YTD  = ORIG_BURDENED_COST_YTD +
                                   X_Orig_Burdened_Cost,
         ORIG_BURDENED_COST_PP   = ORIG_BURDENED_COST_PP +
                                   X_Orig_Burdened_Cost,
         BASE_LABOR_HOURS_ITD    = BASE_LABOR_HOURS_ITD + X_Base_Labor_Hours,
         BASE_LABOR_HOURS_YTD    = BASE_LABOR_HOURS_YTD + X_Base_Labor_Hours,
         BASE_LABOR_HOURS_PP     = BASE_LABOR_HOURS_PP + X_Base_Labor_Hours,
         ORIG_LABOR_HOURS_ITD    = ORIG_LABOR_HOURS_ITD + X_Orig_Labor_Hours,
         ORIG_LABOR_HOURS_YTD    = ORIG_LABOR_HOURS_YTD + X_Orig_Labor_Hours,
         ORIG_LABOR_HOURS_PP     = ORIG_LABOR_HOURS_PP + X_Orig_Labor_Hours,
         BASE_QUANTITY_ITD       = BASE_QUANTITY_ITD + V_Base_Qty,
         BASE_QUANTITY_YTD       = BASE_QUANTITY_YTD + V_Base_Qty,
         BASE_QUANTITY_PP        = BASE_QUANTITY_PP + V_Base_Qty,
         ORIG_QUANTITY_ITD       = ORIG_QUANTITY_ITD + V_Orig_Qty,
         ORIG_QUANTITY_YTD       = ORIG_QUANTITY_YTD + V_Orig_Qty,
         ORIG_QUANTITY_PP        = ORIG_QUANTITY_PP + V_Orig_Qty,
         BASE_REVENUE_ITD        = BASE_REVENUE_ITD + X_Base_Revenue,
         BASE_REVENUE_YTD        = BASE_REVENUE_YTD + X_Base_Revenue,
         BASE_REVENUE_PP         = BASE_REVENUE_PP + X_Base_Revenue,
         ORIG_REVENUE_ITD        = ORIG_REVENUE_ITD + X_Orig_Revenue,
         ORIG_REVENUE_YTD        = ORIG_REVENUE_YTD + X_Orig_Revenue,
         ORIG_REVENUE_PP         = ORIG_REVENUE_PP + X_Orig_Revenue,
         BASE_UNIT_OF_MEASURE    = X_Base_Unit_of_Measure,
         ORIG_UNIT_OF_MEASURE    = X_Orig_Unit_of_Measure,
         LAST_UPDATED_BY         = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE        = Trunc(Sysdate),
         LAST_UPDATE_LOGIN       = pa_proj_accum_main.x_last_update_login
         Where Budget_Type_Code  = x_Budget_type_code
         And (PAB.Project_Accum_id     In
         (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = x_resource_list_member_id and
         Pah.Task_id in (select 0 from sys.dual union
         Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id))) ;
         Recs_processed := Recs_processed + SQL%ROWCOUNT;

    x_recs_processed := Recs_processed;
--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
Exception
  When Others Then
       x_err_code := SQLCODE;
       RAISE;
End Process_it_yt_pp_res_bud;

Procedure   Process_it_pp_res_bud
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_resource_list_id in Number,
                                 x_resource_list_Member_id in Number,
                                 x_resource_id in Number,
                                 x_resource_list_assignment_id in Number,
                                 x_rollup_qty_flag In Varchar2,
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


-- Process_it_pp_res_bud     -  Processes ITD and PP amounts in the
--                          PA_PROJECT_ACCUM_BUDGETS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks. The Project-Resource records
--                          are also created/updated.

Recs_processed        Number := 0;
V_Accum_id            Number := 0;
V_task_array          task_id_tabtype;
v_noof_tasks          Number := 0;
V_Orig_Qty            Number := 0;
V_Base_Qty            Number := 0;
Res_Recs_processed    Number := 0;
V_Old_Stack       Varchar2(630);

Begin
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_BUDGETS_RES.Process_it_pp_res_bud';

      pa_debug.debug(x_err_stack);

-- Quantity would be rolledup only if the Rollup_Quantity_flag against the
-- Resource is 'Y'

        If  x_rollup_qty_flag = 'Y' Then
            V_Base_Qty := X_Base_Quantity;
            V_Orig_Qty := X_Orig_Quantity;
        Else
            V_Base_Qty := 0;
            V_Orig_Qty := 0;
        End If;

-- The follwing Update statement updates all records in the given task
-- WBS hierarchy.It will update only the Project-task-resource combination
-- records and the Project-Resource level record(Task id = 0 and
-- Resourcelist member id <> 0)

        Update PA_PROJECT_ACCUM_BUDGETS  PAB SET
         BASE_RAW_COST_ITD       = BASE_RAW_COST_ITD + X_Base_Raw_Cost,
         BASE_RAW_COST_PP        = BASE_RAW_COST_PP + X_Base_Raw_Cost,
         ORIG_RAW_COST_ITD       = ORIG_RAW_COST_ITD + X_Orig_Raw_Cost,
         ORIG_RAW_COST_PP        = ORIG_RAW_COST_PP + X_Orig_Raw_Cost,
         BASE_BURDENED_COST_ITD  = BASE_BURDENED_COST_ITD +
                                   X_Base_Burdened_Cost,
         BASE_BURDENED_COST_PP   = BASE_BURDENED_COST_PP +
                                   X_Base_Burdened_Cost,
         ORIG_BURDENED_COST_ITD  = ORIG_BURDENED_COST_ITD +
                                   X_Orig_Burdened_Cost,
         ORIG_BURDENED_COST_PP   = ORIG_BURDENED_COST_PP +
                                   X_Orig_Burdened_Cost,
         BASE_LABOR_HOURS_ITD    = BASE_LABOR_HOURS_ITD + X_Base_Labor_Hours,
         BASE_LABOR_HOURS_PP     = BASE_LABOR_HOURS_PP + X_Base_Labor_Hours,
         ORIG_LABOR_HOURS_ITD    = ORIG_LABOR_HOURS_ITD + X_Orig_Labor_Hours,
         ORIG_LABOR_HOURS_PP     = ORIG_LABOR_HOURS_PP + X_Orig_Labor_Hours,
         BASE_QUANTITY_ITD       = BASE_QUANTITY_ITD + V_Base_Qty,
         BASE_QUANTITY_PP        = BASE_QUANTITY_PP + V_Base_Qty,
         ORIG_QUANTITY_ITD       = ORIG_QUANTITY_ITD + V_Orig_Qty,
         ORIG_QUANTITY_PP        = ORIG_QUANTITY_PP + V_Orig_Qty,
         BASE_REVENUE_ITD        = BASE_REVENUE_ITD + X_Base_Revenue,
         BASE_REVENUE_PP         = BASE_REVENUE_PP + X_Base_Revenue,
         ORIG_REVENUE_ITD        = ORIG_REVENUE_ITD + X_Orig_Revenue,
         ORIG_REVENUE_PP         = ORIG_REVENUE_PP + X_Orig_Revenue,
         BASE_UNIT_OF_MEASURE    = X_Base_Unit_of_Measure,
         ORIG_UNIT_OF_MEASURE    = X_Orig_Unit_of_Measure,
         LAST_UPDATED_BY         = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE        = Trunc(Sysdate),
         LAST_UPDATE_LOGIN       = pa_proj_accum_main.x_last_update_login
         Where Budget_Type_Code  = x_Budget_type_code
         And (PAB.Project_Accum_id     In
         (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = x_resource_list_member_id and
         Pah.Task_id in (select 0 from sys.dual union
         Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id))) ;
         Recs_processed := Recs_processed + SQL%ROWCOUNT;

    x_recs_processed := Recs_processed;
--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
Exception
  When Others Then
       x_err_code := SQLCODE;
       RAISE;
End Process_it_pp_res_bud;

Procedure   Process_it_yt_res_bud
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_resource_list_id in Number,
                                 x_resource_list_Member_id in Number,
                                 x_resource_id in Number,
                                 x_resource_list_assignment_id in Number,
                                 x_rollup_qty_flag In Varchar2,
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


-- Process_it_yt_res_bud     -  Processes ITD and YTD amounts in the
--                          PA_PROJECT_ACCUM_BUDGETS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks. The Project-Resource records
--                          are also created/updated.
Recs_processed      Number := 0;
V_Accum_id          Number := 0;
V_task_array        task_id_tabtype;
v_noof_tasks        Number := 0;
V_Orig_Qty          Number := 0;
V_Base_Qty          Number := 0;
Res_Recs_processed  Number := 0;
V_Old_Stack       Varchar2(630);

Begin
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_BUDGETS_RES.Process_it_yt_res_bud';

      pa_debug.debug(x_err_stack);

-- Quantity would be rolledup only if the Rollup_Quantity_flag against the
-- Resource is 'Y'

        If  x_rollup_qty_flag = 'Y' Then
            V_Base_Qty := X_Base_Quantity;
            V_Orig_Qty := X_Orig_Quantity;
        Else
            V_Base_Qty := 0;
            V_Orig_Qty := 0;
        End If;

-- The follwing Update statement updates all records in the given task
-- WBS hierarchy.It will update only the Project-task-resource combination
-- records and the Project-Resource level record(Task id = 0 and
-- Resourcelist member id <> 0)

        Update PA_PROJECT_ACCUM_BUDGETS  PAB SET
         BASE_RAW_COST_ITD      = BASE_RAW_COST_ITD + X_Base_Raw_Cost,
         BASE_RAW_COST_YTD      = BASE_RAW_COST_YTD + X_Base_Raw_Cost,
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
         BASE_QUANTITY_ITD      = BASE_QUANTITY_ITD + V_Base_Qty,
         BASE_QUANTITY_YTD      = BASE_QUANTITY_YTD + V_Base_Qty,
         ORIG_QUANTITY_ITD      = ORIG_QUANTITY_ITD + V_Orig_Qty,
         ORIG_QUANTITY_YTD      = ORIG_QUANTITY_YTD + V_Orig_Qty,
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
         And (PAB.Project_Accum_id     In
         (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = x_resource_list_member_id and
         Pah.Task_id in (select 0 from sys.dual union
         Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id))) ;
         Recs_processed := Recs_processed + SQL%ROWCOUNT;

    x_recs_processed := Recs_processed;
--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
Exception
  When Others Then
       x_err_code := SQLCODE;
       RAISE;
End Process_it_yt_res_bud;

Procedure   Process_it_res_bud
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_resource_list_id in Number,
                                 x_resource_list_Member_id in Number,
                                 x_resource_id in Number,
                                 x_resource_list_assignment_id in Number,
                                 x_rollup_qty_flag In Varchar2,
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


-- Process_it_res_bud        -  Processes ITD amounts in the
--                          PA_PROJECT_ACCUM_BUDGETS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks. The Project-Resource records
--                          are also created/updated.
Recs_processed      Number := 0;
V_Accum_id          Number := 0;
V_task_array        task_id_tabtype;
v_noof_tasks        Number := 0;
V_Orig_Qty          Number := 0;
V_Base_Qty          Number := 0;
Res_Recs_processed  Number := 0;
V_Old_Stack       Varchar2(630);

Begin
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack ||'->PA_PROCESS_ACCUM_BUDGETS_RES.Process_it_res_bud';

      pa_debug.debug(x_err_stack);

-- Quantity would be rolledup only if the Rollup_Quantity_flag against the
-- Resource is 'Y'

        If  x_rollup_qty_flag = 'Y' Then
            V_Base_Qty := X_Base_Quantity;
            V_Orig_Qty := X_Orig_Quantity;
        Else
            V_Base_Qty := 0;
            V_Orig_Qty := 0;
        End If;

-- The follwing Update statement updates all records in the given task
-- WBS hierarchy.It will update only the Project-task-resource combination
-- records and the Project-Resource level record(Task id = 0 and
-- Resourcelist member id <> 0)

        Update PA_PROJECT_ACCUM_BUDGETS  PAB SET
         BASE_RAW_COST_ITD      = BASE_RAW_COST_ITD + X_Base_Raw_Cost,
         ORIG_RAW_COST_ITD      = ORIG_RAW_COST_ITD + X_Orig_Raw_Cost,
         BASE_BURDENED_COST_ITD = BASE_BURDENED_COST_ITD +
                                  X_Base_Burdened_Cost,
         ORIG_BURDENED_COST_ITD = ORIG_BURDENED_COST_ITD +
                                  X_Orig_Burdened_Cost,
         BASE_LABOR_HOURS_ITD   = BASE_LABOR_HOURS_ITD + X_Base_Labor_Hours,
         ORIG_LABOR_HOURS_ITD   = ORIG_LABOR_HOURS_ITD + X_Orig_Labor_Hours,
         BASE_QUANTITY_ITD      = BASE_QUANTITY_ITD + V_Base_Qty,
         ORIG_QUANTITY_ITD      = ORIG_QUANTITY_ITD + V_Orig_Qty,
         BASE_REVENUE_ITD       = BASE_REVENUE_ITD + X_Base_Revenue,
         ORIG_REVENUE_ITD       = ORIG_REVENUE_ITD + X_Orig_Revenue,
         BASE_UNIT_OF_MEASURE   = X_Base_Unit_of_Measure,
         ORIG_UNIT_OF_MEASURE   = X_Orig_Unit_of_Measure,
         LAST_UPDATED_BY        = pa_proj_accum_main.x_last_updated_by,
         LAST_UPDATE_DATE       = Trunc(Sysdate),
         LAST_UPDATE_LOGIN      = pa_proj_accum_main.x_last_update_login
         Where Budget_Type_Code = x_Budget_type_code
         And (PAB.Project_Accum_id     In
         (Select Pah.Project_Accum_id from PA_PROJECT_ACCUM_HEADERS PAH
         Where Pah.Project_id = x_project_id and
         pah.Resource_list_member_id = x_resource_list_member_id and
          Pah.Task_id in (select 0 from sys.dual union
         Select Pt.Task_Id from PA_TASKS pt
         start with pt.task_id = x_task_id
         connect by prior pt.parent_task_id = pt.task_id))) ;
         Recs_processed := Recs_processed + SQL%ROWCOUNT;

    x_recs_processed := Recs_processed;
--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;

Exception
  When Others Then
       x_err_code := SQLCODE;
       RAISE;
End Process_it_res_bud;
END;

/
