--------------------------------------------------------
--  DDL for Package PA_MAINT_PROJECT_COMMITMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MAINT_PROJECT_COMMITMENTS" AUTHID CURRENT_USER AS
/* $Header: PAACCMTS.pls 120.1 2005/08/19 16:13:52 mwasowic noship $ */

-- This package consists of the following procedure

-- Process_Txn_Accum_Cmt - This procedure reads and processes all commitment
--                         records in the PA_TXN_ACCUM table

Procedure Process_Txn_Accum_Cmt  (x_project_id in Number,
                                  x_impl_opt  In Varchar2,
                                  x_proj_accum_id   in Number,
                                  x_current_period in Varchar2,
                                  x_prev_period    in Varchar2,
                                  x_current_year   in Number,
                                  x_prev_accum_period in Varchar2,
                                  x_current_start_date In Date,
                                  x_current_end_date  In Date,
                                  x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                  x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                  x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

End ;

 

/
