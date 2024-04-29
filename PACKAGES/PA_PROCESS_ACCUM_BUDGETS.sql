--------------------------------------------------------
--  DDL for Package PA_PROCESS_ACCUM_BUDGETS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROCESS_ACCUM_BUDGETS" AUTHID CURRENT_USER AS
/* $Header: PABUTSKS.pls 120.1 2005/08/19 16:17:24 mwasowic noship $ */

-- Modified on 10/29/98 by S Sanckar to include a new procedure
-- Process_all_tasks_bud that updates the raw_cost, burdened_cost, quantity,
-- labor_quantity and revenue values for baselined and original budgets
-- This will update the amount columns for period_to_date and prior_period
-- and year_to_date apart from inception_to_date periods.

-- This package contains the following procedures

-- Process_all_tasks_bud      - Processes ITD,YTD,PTD and PP amounts in the
--			    PA_PROJECT_ACCUM_BUDGETS table. For the given
--			    Project_Task combination, records are created/
--			    updated and rolled up to all the higher tasks.

-- Process_it_yt_pt_tasks_bud - Processes ITD,YTD and PTD amounts in the
--                          PA_PROJECT_ACCUM_BUDGETS table. For the
--                          given Project-Task combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.

-- Process_it_yt_pp_tasks_bud - Processes ITD,YTD and PP  amounts in the
--                          PA_PROJECT_ACCUM_BUDGETS table. For the
--                          given Project-Task combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.

-- Process_it_pp_tasks_bud   -  Processes ITD and PP amounts in the
--                          PA_PROJECT_ACCUM_BUDGETS table. For the
--                          given Project-Task combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.

-- Process_it_yt_tasks_bud   -  Processes ITD and YTD amounts in the
--                          PA_PROJECT_ACCUM_BUDGETS table. For the
--                          given Project-Task combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.

-- Process_it_tasks_bud      -  Processes ITD amounts in the
--                          PA_PROJECT_ACCUM_BUDGETS table. For the
--                          given Project-Task combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.

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
				 x_err_code		   In Out NOCOPY Number); --File.Sql.39 bug 4440895

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
                                 x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

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
                                 x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895


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
                                 x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895


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
                                 x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

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
                                 x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895
END;

 

/
