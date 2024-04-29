--------------------------------------------------------
--  DDL for Package PA_PROCESS_ACCUM_ACTUALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROCESS_ACCUM_ACTUALS" AUTHID CURRENT_USER AS
/* $Header: PAACTSKS.pls 120.1 2005/08/19 16:14:59 mwasowic noship $ */

TYPE task_id_tabtype IS TABLE OF PA_TASKS.TASK_ID%TYPE INDEX BY BINARY_INTEGER;

-- This package contains the following procedures

-- Process_it_yt_pt_tasks - Processes ITD,YTD and PTD amounts in the
--                          PA_PROJECT_ACCUM_ACTUALS table. For the
--                          given Project-Task combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.

-- Process_it_yt_pp_tasks - Processes ITD,YTD and PP  amounts in the
--                          PA_PROJECT_ACCUM_ACTUALS table. For the
--                          given Project-Task combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.

-- Process_it_pp_tasks   -  Processes ITD and PP amounts in the
--                          PA_PROJECT_ACCUM_ACTUALS table. For the
--                          given Project-Task combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.

-- Process_it_yt_tasks   -  Processes ITD and YTD amounts in the
--                          PA_PROJECT_ACCUM_ACTUALS table. For the
--                          given Project-Task combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.

-- Process_it_tasks      -  Processes ITD amounts in the
--                          PA_PROJECT_ACCUM_ACTUALS table. For the
--                          given Project-Task combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.

     Procedure   Process_it_yt_pt_tasks
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_Proj_Accum_Id In Number,
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
                                 X_err_Code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895
     Procedure   Process_it_yt_pp_tasks
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_Proj_Accum_Id In Number,
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
                                 X_err_Code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895
     Procedure   Process_it_pp_tasks
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_Proj_Accum_Id In Number,
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
                                 X_err_Code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895
     Procedure   Process_it_yt_tasks
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_Proj_Accum_Id In Number,
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
                                 X_err_Code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

     Procedure   Process_it_tasks
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_Proj_Accum_Id In Number,
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
                                 X_err_Code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

END;

 

/
