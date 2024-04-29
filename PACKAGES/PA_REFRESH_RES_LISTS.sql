--------------------------------------------------------
--  DDL for Package PA_REFRESH_RES_LISTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_REFRESH_RES_LISTS" AUTHID CURRENT_USER AS
/* $Header: PAACREFS.pls 120.1 2005/08/19 16:14:11 mwasowic noship $ */
-- Process_Res_List - This procedure accumulates the Actuals and Commitments
--                    for a given Resource list

  Procedure Process_Res_Lists     (x_project_id in Number,
                                   x_Resource_list_id In Number,
                                   x_current_period in Varchar2,
                                   x_prev_period    in Varchar2,
                                   x_current_year   in Number,
                                   x_current_start_date In Date,
                                   x_current_end_date  In Date,
                                   x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                   x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                   x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

End PA_REFRESH_RES_LISTS;

 

/
