--------------------------------------------------------
--  DDL for Package PA_RES_LIST_ASSIGNMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RES_LIST_ASSIGNMENTS" AUTHID CURRENT_USER AS
/* $Header: PARLASMS.pls 120.1 2005/08/19 16:55:03 mwasowic noship $ */

 Procedure Create_Rl_Assgmt (X_Project_id  In Number,
                             X_Resource_list_id  In Number,
                             X_Resource_list_Assgmt_id Out NOCOPY Number, --File.Sql.39 bug 4440895
                             X_err_code  IN  Out NOCOPY Number, --File.Sql.39 bug 4440895
                             X_err_stage IN  Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                             x_err_stack IN  Out NOCOPY Varchar2 ) ; --File.Sql.39 bug 4440895

 Procedure   Get_Rl_Assgmt (X_Project_id  In Number,
                            X_Resource_list_id  In Number,
                            X_Resource_list_Assgmt_id Out NOCOPY Number, --File.Sql.39 bug 4440895
                            X_err_code  IN  Out NOCOPY Number, --File.Sql.39 bug 4440895
                            X_err_stage IN  Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                            x_err_stack IN  Out NOCOPY Varchar2 ) ; --File.Sql.39 bug 4440895

 Procedure Create_Rl_Uses  (X_Project_id              In Number,
                            X_Resource_list_Assgmt_id In  Number,
                            X_Use_Code                In Varchar2,
                            X_err_code  IN  Out NOCOPY Number, --File.Sql.39 bug 4440895
                            X_err_stage IN  Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                            x_err_stack IN  Out NOCOPY Varchar2 ) ; --File.Sql.39 bug 4440895

 Procedure Delete_Rl_Uses  (X_Resource_list_Assgmt_id In Number,
                            X_Use_Code      IN Varchar2,
                            X_err_code  IN  Out NOCOPY Number, --File.Sql.39 bug 4440895
                            X_err_stage IN  Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                            x_err_stack IN  Out NOCOPY Varchar2 ) ; --File.Sql.39 bug 4440895

 Procedure Delete_Rl_Assgmt(X_Resource_list_Assgmt_id In Number,
                            X_err_code  IN  Out NOCOPY Number, --File.Sql.39 bug 4440895
                            X_err_stage IN  Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                            x_err_stack IN  Out NOCOPY Varchar2 ) ; --File.Sql.39 bug 4440895

END;

 

/
