--------------------------------------------------------
--  DDL for Package PA_PROCESS_ACCUM_CMT_RES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROCESS_ACCUM_CMT_RES" AUTHID CURRENT_USER AS
/* $Header: PACMTRES.pls 120.1 2005/08/19 16:19:57 mwasowic noship $ */

TYPE task_id_tabtype IS TABLE OF PA_TASKS.TASK_ID%TYPE INDEX BY BINARY_INTEGER;

-- Process_it_yt_pt_cmt_res   - Processes ITD,YTD and PTD amounts in the
--                          PA_PROJECT_ACCUM_COMMITMENTS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks. The Project-Resource records
--                          are also created/updated.

-- Process_it_yt_pp_cmt_res   - Processes ITD,YTD and PP  amounts in the
--                          PA_PROJECT_ACCUM_COMMITMENTS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.  The Project-Resource records
--                          are also created/updated.

-- Process_it_pp_cmt_res     -  Processes ITD and PP amounts in the
--                          PA_PROJECT_ACCUM_COMMITMENTS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks. The Project-Resource records
--                          are also created/updated.

-- Process_it_yt_cmt_res     -  Processes ITD and YTD amounts in the
--                          PA_PROJECT_ACCUM_COMMITMENTS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks. The Project-Resource records
--                          are also created/updated.

-- Process_it_cmt_res        -  Processes ITD amounts in the
--                          PA_PROJECT_ACCUM_COMMITMENTS table. For the
--                          given Project-Task-Resource combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks. The Project-Resource records
--                          are also created/updated.

-- Get_all_higher_tasks_cmt_res  -  For the given Task Id returns all the
--                          higher level tasks in the WBS (including the given
--                          task) which are not in PA_PROJECT_ACCUM_HEADERS
--                          (Tasks with the given Resource )


     Procedure   Process_it_yt_pt_cmt_res
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
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Quantity In Number,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

     Procedure   Process_it_yt_pp_cmt_res
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
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Quantity In Number,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

     Procedure   Process_it_pp_cmt_res
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
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Quantity In Number,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

     Procedure   Process_it_yt_cmt_res
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
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Quantity In Number,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

     Procedure   Process_it_cmt_res
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
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Quantity In Number,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895


    Procedure   Get_all_higher_tasks_cmt_res
                                     (x_project_id in Number,
                                      X_task_id in Number,
                                      x_resource_list_member_id in Number,
                                      x_task_array  Out NOCOPY task_id_tabtype, --File.Sql.39 bug 4440895
                                      x_noof_tasks Out NOCOPY number, --File.Sql.39 bug 4440895
                                      x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                      x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                      x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895


END PA_PROCESS_ACCUM_CMT_RES;

 

/
