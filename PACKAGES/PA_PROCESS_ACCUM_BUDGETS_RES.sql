--------------------------------------------------------
--  DDL for Package PA_PROCESS_ACCUM_BUDGETS_RES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROCESS_ACCUM_BUDGETS_RES" AUTHID CURRENT_USER AS
/* $Header: PABURESS.pls 120.1 2005/08/19 16:17:14 mwasowic noship $ */

-- Modified on 10/29/98 by S Sanckar to include a new procedure
-- Process_all_res_bud that updates the raw_cost, burdened_cost, quantity,
-- labor_quantity and revenue values for baselined and original budgets
-- This will update the amount columns for period_to_date and prior_period
-- and year_to_date apart from inception_to_date periods.

TYPE task_id_tabtype IS TABLE OF PA_TASKS.TASK_ID%TYPE INDEX BY BINARY_INTEGER;
-- This package contains the following procedures

-- Process_all_res_bud 	      - Processes ITD,YTD,PP and PTD amounts in the
--			    PA_PROJECT_ACCUM_BUDGETS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks. The Project-Resource records
--                          are also created/updated.

-- This package contains the following procedures

-- Process_it_yt_pt_res_bud   - Processes ITD,YTD and PTD amounts in the
--                          PA_PROJECT_ACCUM_BUDGETS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks. The Project-Resource records
--                          are also created/updated.

-- Process_it_yt_pp_res_bud   - Processes ITD,YTD and PP  amounts in the
--                          PA_PROJECT_ACCUM_BUDGETS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.  The Project-Resource records
--                          are also created/updated.

-- Process_it_pp_res_bud     -  Processes ITD and PP amounts in the
--                          PA_PROJECT_ACCUM_BUDGETS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks. The Project-Resource records
--                          are also created/updated.

-- Process_it_yt_res_bud     -  Processes ITD and YTD amounts in the
--                          PA_PROJECT_ACCUM_BUDGETS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks. The Project-Resource records
--                          are also created/updated.

-- Process_it_res_bud        -  Processes ITD amounts in the
--                          PA_PROJECT_ACCUM_BUDGETS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks. The Project-Resource records
--                          are also created/updated.

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
                                 x_err_code      	   In Out NOCOPY Number ); --File.Sql.39 bug 4440895

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
                                 x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895


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
                                 x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895


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
                                 x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895


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
                                 x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895


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
                                 x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895


END;

 

/
