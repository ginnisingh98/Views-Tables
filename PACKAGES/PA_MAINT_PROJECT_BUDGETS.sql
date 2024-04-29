--------------------------------------------------------
--  DDL for Package PA_MAINT_PROJECT_BUDGETS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MAINT_PROJECT_BUDGETS" AUTHID CURRENT_USER AS
/* $Header: PAACBUDS.pls 120.1 2005/08/19 16:13:42 mwasowic noship $ */

-- This package consists of the following two procedures
-- Process_Budget_Txns - this procedure reads the PA_BUDGET_BY_PA_PERIOD_V
--                       which is a Union of PA_BASE_BUDGET_BY_PA_PERIOD_V and
--                       PA_ORIG_BUDGET_BY_PA_PERIOD_V and processes all
--                       Unaccumulated Budgets

-- Process_Budget_Tot - this procedure reads the PA_BUDGET_BY_RESOURCE_V which
--                      is a Union of PA_BASE_BUDGET_BY_RESOURCE_V and
--                      PA_ORIG_BUDGET_BY_RESOURCE_V . These views contain the
--                      total budget amounts (including the amounts for
--                      the periods beyond the defined PA_PERIODS
--
-- Modified 05/10/99  Shanif
--                    Added more procedures and variables to improve the performance
--                    of budgets processing.

  V_Base_Burdened_Cost_itd	Number :=0;
  V_Base_Burdened_Cost_ptd	Number :=0;
  V_Base_Burdened_Cost_pp 	Number :=0;
  V_Base_Burdened_Cost_ytd	Number :=0;

  V_Base_Labor_Hours_itd	Number :=0;
  V_Base_Labor_Hours_ptd	Number :=0;
  V_Base_Labor_Hours_pp 	Number :=0;
  V_Base_Labor_Hours_ytd	Number :=0;

  V_Base_Raw_Cost_itd		Number :=0;
  V_Base_Raw_Cost_ptd		Number :=0;
  V_Base_Raw_Cost_pp 		Number :=0;
  V_Base_Raw_Cost_ytd		Number :=0;

  V_Base_Revenue_itd		Number :=0;
  V_Base_Revenue_ptd		Number :=0;
  V_Base_Revenue_pp 		Number :=0;
  V_Base_Revenue_ytd		Number :=0;

  V_Base_Quantity_itd		Number :=0;
  V_Base_Quantity_ptd		Number :=0;
  V_Base_Quantity_pp 		Number :=0;
  V_Base_Quantity_ytd		Number :=0;

  V_Orig_Burdened_Cost_itd	Number :=0;
  V_Orig_Burdened_Cost_ptd	Number :=0;
  V_Orig_Burdened_Cost_pp 	Number :=0;
  V_Orig_Burdened_Cost_ytd	Number :=0;

  V_Orig_Labor_Hours_itd	Number :=0;
  V_Orig_Labor_Hours_ptd	Number :=0;
  V_Orig_Labor_Hours_pp 	Number :=0;
  V_Orig_Labor_Hours_ytd	Number :=0;

  V_Orig_Quantity_itd		Number :=0;
  V_Orig_Quantity_ptd		Number :=0;
  V_Orig_Quantity_pp 		Number :=0;
  V_Orig_Quantity_ytd		Number :=0;

  V_Orig_Raw_Cost_itd		Number :=0;
  V_Orig_Raw_Cost_ptd		Number :=0;
  V_Orig_Raw_Cost_pp 		Number :=0;
  V_Orig_Raw_Cost_ytd		Number :=0;

  V_Orig_Revenue_itd		Number :=0;
  V_Orig_Revenue_ptd		Number :=0;
  V_Orig_Revenue_pp 		Number :=0;
  V_Orig_Revenue_ytd		Number :=0;

  Prj_Base_Burdened_Cost_itd	Number :=0;
  Prj_Base_Burdened_Cost_ptd	Number :=0;
  Prj_Base_Burdened_Cost_pp 	Number :=0;
  Prj_Base_Burdened_Cost_ytd	Number :=0;

  Prj_Base_Labor_Hours_itd	Number :=0;
  Prj_Base_Labor_Hours_ptd	Number :=0;
  Prj_Base_Labor_Hours_pp 	Number :=0;
  Prj_Base_Labor_Hours_ytd	Number :=0;

  Prj_Base_Raw_Cost_itd		Number :=0;
  Prj_Base_Raw_Cost_ptd		Number :=0;
  Prj_Base_Raw_Cost_pp 		Number :=0;
  Prj_Base_Raw_Cost_ytd		Number :=0;

  Prj_Base_Revenue_itd		Number :=0;
  Prj_Base_Revenue_ptd		Number :=0;
  Prj_Base_Revenue_pp 		Number :=0;
  Prj_Base_Revenue_ytd		Number :=0;

  Prj_Base_Quantity_itd		Number :=0;
  Prj_Base_Quantity_ptd		Number :=0;
  Prj_Base_Quantity_pp 		Number :=0;
  Prj_Base_Quantity_ytd		Number :=0;

  Prj_Orig_Burdened_Cost_itd	Number :=0;
  Prj_Orig_Burdened_Cost_ptd	Number :=0;
  Prj_Orig_Burdened_Cost_pp 	Number :=0;
  Prj_Orig_Burdened_Cost_ytd	Number :=0;

  Prj_Orig_Labor_Hours_itd	Number :=0;
  Prj_Orig_Labor_Hours_ptd	Number :=0;
  Prj_Orig_Labor_Hours_pp 	Number :=0;
  Prj_Orig_Labor_Hours_ytd	Number :=0;

  Prj_Orig_Quantity_itd		Number :=0;
  Prj_Orig_Quantity_ptd		Number :=0;
  Prj_Orig_Quantity_pp 		Number :=0;
  Prj_Orig_Quantity_ytd		Number :=0;

  Prj_Orig_Raw_Cost_itd		Number :=0;
  Prj_Orig_Raw_Cost_ptd		Number :=0;
  Prj_Orig_Raw_Cost_pp 		Number :=0;
  Prj_Orig_Raw_Cost_ytd		Number :=0;

  Prj_Orig_Revenue_itd		Number :=0;
  Prj_Orig_Revenue_ptd		Number :=0;
  Prj_Orig_Revenue_pp 		Number :=0;
  Prj_Orig_Revenue_ytd		Number :=0;

  Tsk_Base_Burdened_Cost_itd	Number :=0;
  Tsk_Base_Burdened_Cost_ptd	Number :=0;
  Tsk_Base_Burdened_Cost_pp 	Number :=0;
  Tsk_Base_Burdened_Cost_ytd	Number :=0;

  Tsk_Base_Labor_Hours_itd	Number :=0;
  Tsk_Base_Labor_Hours_ptd	Number :=0;
  Tsk_Base_Labor_Hours_pp 	Number :=0;
  Tsk_Base_Labor_Hours_ytd	Number :=0;

  Tsk_Base_Raw_Cost_itd		Number :=0;
  Tsk_Base_Raw_Cost_ptd		Number :=0;
  Tsk_Base_Raw_Cost_pp 		Number :=0;
  Tsk_Base_Raw_Cost_ytd		Number :=0;

  Tsk_Base_Revenue_itd		Number :=0;
  Tsk_Base_Revenue_ptd		Number :=0;
  Tsk_Base_Revenue_pp 		Number :=0;
  Tsk_Base_Revenue_ytd		Number :=0;

  Tsk_Base_Quantity_itd		Number :=0;
  Tsk_Base_Quantity_ptd		Number :=0;
  Tsk_Base_Quantity_pp 		Number :=0;
  Tsk_Base_Quantity_ytd		Number :=0;

  Tsk_Orig_Burdened_Cost_itd	Number :=0;
  Tsk_Orig_Burdened_Cost_ptd	Number :=0;
  Tsk_Orig_Burdened_Cost_pp 	Number :=0;
  Tsk_Orig_Burdened_Cost_ytd	Number :=0;

  Tsk_Orig_Labor_Hours_itd	Number :=0;
  Tsk_Orig_Labor_Hours_ptd	Number :=0;
  Tsk_Orig_Labor_Hours_pp 	Number :=0;
  Tsk_Orig_Labor_Hours_ytd	Number :=0;

  Tsk_Orig_Quantity_itd		Number :=0;
  Tsk_Orig_Quantity_ptd		Number :=0;
  Tsk_Orig_Quantity_pp 		Number :=0;
  Tsk_Orig_Quantity_ytd		Number :=0;

  Tsk_Orig_Raw_Cost_itd		Number :=0;
  Tsk_Orig_Raw_Cost_ptd		Number :=0;
  Tsk_Orig_Raw_Cost_pp 		Number :=0;
  Tsk_Orig_Raw_Cost_ytd		Number :=0;

  Tsk_Orig_Revenue_itd		Number :=0;
  Tsk_Orig_Revenue_ptd		Number :=0;
  Tsk_Orig_Revenue_pp 		Number :=0;
  Tsk_Orig_Revenue_ytd		Number :=0;

  Tsk_ORIG_REVENUE              Number := 0;
  Tsk_BASE_REVENUE              Number := 0;
  Tsk_ORIG_QUANTITY             Number := 0;
  Tsk_BASE_QUANTITY             Number := 0;
  Tsk_ORIG_RAW_COST             Number := 0;
  Tsk_BASE_RAW_COST             Number := 0;
  Tsk_ORIG_BURDENED_COST        Number := 0;
  Tsk_BASE_BURDENED_COST        Number := 0;
  Tsk_ORIG_LABOR_HOURS          Number := 0;
  Tsk_BASE_LABOR_HOURS          Number := 0;

  TOT_ORIG_REVENUE              Number := 0;
  TOT_BASE_REVENUE              Number := 0;
  TOT_ORIG_QUANTITY             Number := 0;
  TOT_BASE_QUANTITY             Number := 0;
  TOT_ORIG_RAW_COST             Number := 0;
  TOT_BASE_RAW_COST             Number := 0;
  TOT_ORIG_BURDENED_COST        Number := 0;
  TOT_BASE_BURDENED_COST        Number := 0;
  TOT_ORIG_LABOR_HOURS          Number := 0;
  TOT_BASE_LABOR_HOURS          Number := 0;

  Prj_ORIG_REVENUE              Number := 0;
  Prj_BASE_REVENUE              Number := 0;
  Prj_ORIG_QUANTITY             Number := 0;
  Prj_BASE_QUANTITY             Number := 0;
  Prj_ORIG_RAW_COST             Number := 0;
  Prj_BASE_RAW_COST             Number := 0;
  Prj_ORIG_BURDENED_COST        Number := 0;
  Prj_BASE_BURDENED_COST        Number := 0;
  Prj_ORIG_LABOR_HOURS          Number := 0;
  Prj_BASE_LABOR_HOURS          Number := 0;

 Procedure Process_Budget_Txns (X_project_id in Number,
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
                                x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

 Procedure Process_Budget_Tot  (X_project_id in Number,
                                x_Proj_accum_id   in Number,
                                x_Budget_Type_code in Varchar2,
                                x_current_period in Varchar2,
                                x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                x_err_code      In  Out NOCOPY Number ); --File.Sql.39 bug 4440895

TYPE task_id_tabtype IS TABLE OF PA_TASKS.TASK_ID%TYPE INDEX BY BINARY_INTEGER;

Procedure create_accum_budgets
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_budget_type_code In Varchar2,
                                 x_current_period In Varchar2,
                                 x_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ) ; --File.Sql.39 bug 4440895

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
                                 x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

Procedure Get_all_higher_tasks_bud (x_project_id in Number,
                                      x_task_id in Number,
                                      x_resource_list_member_id In Number,
                                      x_task_array  Out NOCOPY task_id_tabtype, --File.Sql.39 bug 4440895
                                      x_noof_tasks Out NOCOPY number, --File.Sql.39 bug 4440895
                                      x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                      x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                      x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

Procedure Add_project_amounts;

Procedure Add_task_amounts;

Procedure Initialize_res_level;

Procedure Initialize_task_level;

Procedure Initialize_project_level;


--History:
--    	xx-xxx-xxxx     who?		- Created
--
--      26-SEP-2002	jwhite		- Converted to support both r11.5.7 Budget and FP models.
--                                        Added x_fin_plan_type_id

Procedure   Process_all_buds    (x_project_id              In Number,
                                 x_current_period          In varchar2,
                                 x_task_id                 In Number,
                                 x_resource_list_id        In Number,
                                 x_resource_list_Member_id In Number,
                                 x_resource_id             In Number,
                                 x_resource_list_assignment_id In Number,
                                 x_rollup_qty_flag         In Varchar2,
                                 x_budget_type_code        In Varchar2,
                                 x_fin_plan_type_id        IN NUMBER,
                                 X_Base_Unit_Of_Measure    In Varchar2,
                                 X_Orig_Unit_Of_Measure    In Varchar2,
                                 X_Recs_processed          Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack               In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage               In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code                In Out NOCOPY Number );  --File.Sql.39 bug 4440895
--History:
--    	xx-xxx-xxxx     who?		- Created
--
--      26-SEP-2002	jwhite		- Converted to support both r11.5.7 Budget and FP models.
--                                        Added x_fin_plan_type_id
Procedure   Process_bud_code    (x_project_id              In Number,
                                 x_current_period          In varchar2,
                                 x_task_id                 In Number,
                                 x_resource_list_id        In Number,
                                 x_resource_list_Member_id In Number,
                                 x_resource_id             In Number,
                                 x_resource_list_assignment_id In Number,
                                 x_rollup_qty_flag         In Varchar2,
                                 x_budget_type_code        In Varchar2,
                                 x_fin_plan_type_id        IN NUMBER,
                                 X_Base_Unit_Of_Measure    In Varchar2,
                                 X_Orig_Unit_Of_Measure    In Varchar2,
                                 X_Recs_processed          Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack               In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage               In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code                In Out NOCOPY Number ); --File.Sql.39 bug 4440895
--History:
--    	xx-xxx-xxxx     who?		- Created
--
--      26-SEP-2002	jwhite		- Converted to support both r11.5.7 Budget and FP models.
--                                        Added x_fin_plan_type_id
Procedure   Process_all_tasks   (x_project_id              In Number,
                                 x_current_period          In varchar2,
                                 x_task_id                 In Number,
                                 x_resource_list_id        In Number,
                                 x_resource_list_Member_id In Number,
                                 x_resource_id             In Number,
                                 x_resource_list_assignment_id In Number,
                                 x_rollup_qty_flag         In Varchar2,
                                 x_budget_type_code        In Varchar2,
                                 x_fin_plan_type_id        IN NUMBER,
                                 X_Base_Unit_Of_Measure    In Varchar2,
                                 X_Orig_Unit_Of_Measure    In Varchar2,
                                 X_Recs_processed          Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack               In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage               In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code                In Out NOCOPY Number ); --File.Sql.39 bug 4440895

End ;
 

/
