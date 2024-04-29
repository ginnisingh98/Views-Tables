--------------------------------------------------------
--  DDL for Package PA_DELETE_ACCUM_RECS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_DELETE_ACCUM_RECS" AUTHID CURRENT_USER AS
/* $Header: PAACDELS.pls 120.1 2005/08/19 16:14:01 mwasowic noship $ */

--  -- Package Internal Globals (bug 2633920) -------------------------------------

     G_Prj_Lvl_project_id  pa_projects_all.project_id%TYPE := NULL;
     G_Prj_Lvl_Accum_Id    pa_project_accum_headers.project_accum_id%TYPE := NULL;


-- This package contains the following procedures ----------------------------------

-- Delete_Project_Commitments - This deletes the records from
--                              PA_PROJECT_ACCUM_COMMITMENTS for the
--                              given project.This procedure will be
--                              called everytime commitments are accumulated

-- Delete_Project_Budgets - This deletes the records from
--                          PA_PROJECT_ACCUM_BUDGETS for the
--                          given project and Budget type. This procedure
--                          will be called every time Budgets are accumulated

-- Delete_Project_Actuals - This deletes the records from
--                          PA_PROJECT_ACCUM_ACTUALS for the
--                          given project. This procedure would be called
--                          every time Actuals are refreshed

-- Delete_Res_List_Actuals - This deletes the records from
--                          PA_PROJECT_ACCUM_ACTUALS for the
--                          given project and Resource list .
--                          This procedure would be called
--                          every time Actuals are refreshed for a Resource list

-- Delete_Res_List_Commitments - This deletes the records from
--                               PA_PROJECT_ACCUM_COMMITMENTS for the
--                               given project and Resource list .
--                               This procedure would be called
--                               every time commitments are refreshed for a
--                               Resource list

-- Delete_Project_Accum_Headers - This checks for any records in
--                                PA_PROJECT_ACCUM_HEADERS which does not
--                                have any corresponding Actuals,Budgets and
--                                commitments and deletes such records
--                                This procedure would be called after
--                                a Project is refreshed

-- Bug 2633920
-- Get_Proj_Lvl_Accum_Id     - This procedure populates the package globals
--                             used for processing by the following procedures:
--                             - Delete_Project_Commitments
--                             - Delete_Project_Budgets
--                             - Delete_Project_Actuals


   Procedure Delete_Project_Commitments (x_project_Id In Number,
                                         x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                         x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                         x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

   Procedure Delete_Project_Budgets     (x_project_Id In Number,
                                         x_budget_Type_Code In Varchar2,
                                         x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                         x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                         x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

   Procedure Delete_Project_Actuals     (x_project_Id In Number,
                                         x_err_stack   In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                         x_err_stage   In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                         x_err_code    In Out NOCOPY Number ); --File.Sql.39 bug 4440895

   Procedure Delete_Res_List_Actuals      (x_project_id    In Number,
                                           x_Resource_list_id In Number,
                                           x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                           x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                           x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

   Procedure Delete_Res_List_Commitments (x_project_id In Number,
                                          x_Resource_list_id In Number,
                                          x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                          x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                          x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

   Procedure Delete_Project_Accum_Headers (x_project_id In Number,
                                           x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                           x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                           x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895
   -- bug 2633920
   PROCEDURE Get_Prj_Lvl_Accum_Id (p_project_id             IN   NUMBER
                                     , x_Prj_Lvl_Accum_Id   OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
                                     , x_msg_count          OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
                                     , x_msg_data           OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                     , x_return_status      OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                     );




End ;
 

/
