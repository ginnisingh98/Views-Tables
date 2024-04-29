--------------------------------------------------------
--  DDL for Package PA_PROCESS_ACCUM_COMMITMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROCESS_ACCUM_COMMITMENTS" AUTHID CURRENT_USER AS
/* $Header: PACMTSKS.pls 120.1 2005/08/19 16:20:05 mwasowic noship $ */

TYPE task_id_tabtype IS TABLE OF PA_TASKS.TASK_ID%TYPE INDEX BY BINARY_INTEGER;
-- This package contains the following procedures

-- Process_it_yt_pt_tasks_cmt - Processes ITD,YTD and PTD amounts in the
--                          PA_PROJECT_ACCUM_COMMITMENTS table. For the
--                          given Project-Task combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.

-- Process_it_yt_pp_tasks_cmt - Processes ITD,YTD and PP  amounts in the
--                          PA_PROJECT_ACCUM_COMMITMENTS table. For the
--                          given Project-Task combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.

-- Process_it_pp_tasks_cmt   -  Processes ITD and PP amounts in the
--                          PA_PROJECT_ACCUM_COMMITMENTS table. For the
--                          given Project-Task combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.

-- Process_it_yt_tasks_cmt   -  Processes ITD and YTD amounts in the
--                          PA_PROJECT_ACCUM_COMMITMENTS table. For the
--                          given Project-Task combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.

-- Process_it_tasks_cmt      -  Processes ITD amounts in the
--                          PA_PROJECT_ACCUM_COMMITMENTS table. For the
--                          given Project-Task combination,records are
--                          created/updated and rolled up to all the
--                          higher level tasks.

-- Get_all_higher_tasks_cmt  -  For the given Task Id returns all the
--                          higher level tasks in the WBS (including the given
--                          task) which are not in PA_PROJECT_ACCUM_HEADERS

     Procedure   Process_it_yt_pt_tasks_cmt
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_Proj_Accum_Id In Number,
                                 x_current_period In Varchar2,
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Quantity In Number,
                                 X_Unit_Of_Measure In Varchar2,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895
     Procedure   Process_it_yt_pp_tasks_cmt
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_Proj_Accum_Id In Number,
                                 x_current_period In Varchar2,
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Quantity In Number,
                                 X_Unit_Of_Measure In Varchar2,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895
     Procedure   Process_it_pp_tasks_cmt
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_Proj_Accum_Id In Number,
                                 x_current_period In Varchar2,
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Quantity In Number,
                                 X_Unit_Of_Measure In Varchar2,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895
     Procedure   Process_it_yt_tasks_cmt
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_Proj_Accum_Id In Number,
                                 x_current_period In Varchar2,
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Quantity In Number,
                                 X_Unit_Of_Measure In Varchar2,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895
     Procedure   Process_it_tasks_cmt
                                (x_project_id In Number,
                                 x_task_id In Number,
                                 x_Proj_Accum_Id In Number,
                                 x_current_period In Varchar2,
                                 X_Raw_Cost In Number,
                                 X_Burdened_Cost In Number,
                                 X_Quantity In Number,
                                 X_Unit_Of_Measure In Varchar2,
                                 X_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

    Procedure   Get_all_higher_tasks_cmt (x_project_id in Number,
                                      X_task_id in Number,
                                      x_task_array  Out NOCOPY task_id_tabtype, --File.Sql.39 bug 4440895
                                      x_noof_tasks Out NOCOPY number, --File.Sql.39 bug 4440895
                                      x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                      x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                      x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

END;

 

/
