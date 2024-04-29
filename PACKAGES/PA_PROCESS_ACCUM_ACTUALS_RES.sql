--------------------------------------------------------
--  DDL for Package PA_PROCESS_ACCUM_ACTUALS_RES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROCESS_ACCUM_ACTUALS_RES" AUTHID CURRENT_USER AS
/* $Header: PAACRESS.pls 120.1 2005/08/19 16:14:20 mwasowic noship $ */

-- This package contains the following procedures

-- Process_it_yt_pt_res   - Processes ITD,YTD and PTD amounts in the
--                          PA_PROJECT_ACCUM_ACTUALS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks. The Project-Resource records
--                          are also created/updated.

-- Process_it_yt_pp_res   - Processes ITD,YTD and PP  amounts in the
--                          PA_PROJECT_ACCUM_ACTUALS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.  The Project-Resource records
--                          are also created/updated.

-- Process_it_pp_res     -  Processes ITD and PP amounts in the
--                          PA_PROJECT_ACCUM_ACTUALS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks. The Project-Resource records
--                          are also created/updated.

-- Process_it_yt_res     -  Processes ITD and YTD amounts in the
--                          PA_PROJECT_ACCUM_ACTUALS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks. The Project-Resource records
--                          are also created/updated.

-- Process_it_res        -  Processes ITD amounts in the
--                          PA_PROJECT_ACCUM_ACTUALS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks. The Project-Resource records
--                          are also created/updated.

-- Insert_Headers_res    - Inserts Header records in the
--                         PA_PROJECT_ACCUM_HEADERS table for the given
--                         Project-Task-Resource combination

     Procedure   Process_it_yt_pt_res
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_resource_list_id in Number,
                                 x_resource_list_Member_id in Number,
                                 x_resource_id in Number,
                                 x_resource_list_assignment_id in Number,
                                 x_track_as_labor_flag In Varchar2,
                                 x_rollup_qty_flag In Varchar2,
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
                                 X_err_Code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895
     Procedure   Process_it_yt_pp_res
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_resource_list_id in Number,
                                 x_resource_list_Member_id in Number,
                                 x_resource_id in Number,
                                 x_resource_list_assignment_id in Number,
                                 x_track_as_labor_flag In Varchar2,
                                 x_rollup_qty_flag In Varchar2,
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
                                 X_err_Code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895
     Procedure   Process_it_pp_res
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_resource_list_id in Number,
                                 x_resource_list_Member_id in Number,
                                 x_resource_id in Number,
                                 x_resource_list_assignment_id in Number,
                                 x_track_as_labor_flag In Varchar2,
                                 x_rollup_qty_flag In Varchar2,
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
                                 X_err_Code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

     Procedure   Process_it_yt_res
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_resource_list_id in Number,
                                 x_resource_list_Member_id in Number,
                                 x_resource_id in Number,
                                 x_resource_list_assignment_id in Number,
                                 x_track_as_labor_flag In Varchar2,
                                 x_rollup_qty_flag In Varchar2,
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
                                 X_err_Code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895


     Procedure   Process_it_res
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_resource_list_id in Number,
                                 x_resource_list_Member_id in Number,
                                 x_resource_id in Number,
                                 x_resource_list_assignment_id in Number,
                                 x_track_as_labor_flag In Varchar2,
                                 x_rollup_qty_flag In Varchar2,
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
                                 X_err_Code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

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
                                 X_err_Code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

END;

 

/
