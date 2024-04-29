--------------------------------------------------------
--  DDL for Package PA_MAINT_PROJECT_ACCUMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MAINT_PROJECT_ACCUMS" AUTHID CURRENT_USER AS
/* $Header: PAACACTS.pls 120.1 2005/08/19 16:13:32 mwasowic noship $ */
-- This Package consists of the following procedures

-- Process_Txn_Accum  - This reads the PA_TXN_ACCUM and processes the
--                      transactions
-- create_accum_actuals - This creates the header and details records in
--                        PA_PROJECT_ACCUM_HEADERS and PA_PROJECT_ACCUM_ACTUALS
-- Initialize Actuals - this initializes the TO_date numbers in the
--                      Pa_Project_Accum_Actuals table whenever there is
--                      a change in the Accumulation period
-- Initialize Budgets - this initializes the TO_date numbers in the
--                      Pa_project_accum_budgets table whenever there is
--                      a change in the Accumulation period
-- Initialize commitments - this initializes the TO_date numbers  in the
--                          Pa_project_accum_commitments table whenever
--                          there is a change in the Accumulation period

-- Apr-09-99 Changes made to combine Process_txn_accum and Process_txn_accum_cmt
-- procedures and process_txn_accum procedure simplified

TYPE task_id_tabtype IS TABLE OF PA_TASKS.TASK_ID%TYPE INDEX BY BINARY_INTEGER;


  New_raw_cost_itd		NUMBER := 0;
  New_raw_cost_ytd		NUMBER := 0;
  New_raw_cost_ptd		NUMBER := 0;
  New_raw_cost_pp 		NUMBER := 0;

  New_quantity_itd		NUMBER := 0;
  New_quantity_ytd		NUMBER := 0;
  New_quantity_ptd		NUMBER := 0;
  New_quantity_pp 		NUMBER := 0;

  New_bill_quantity_itd		NUMBER := 0;
  New_bill_quantity_ytd		NUMBER := 0;
  New_bill_quantity_ptd		NUMBER := 0;
  New_bill_quantity_pp 		NUMBER := 0;

  New_cmt_raw_cost_itd		NUMBER := 0;
  New_cmt_raw_cost_ytd		NUMBER := 0;
  New_cmt_raw_cost_ptd		NUMBER := 0;
  New_cmt_raw_cost_pp 		NUMBER := 0;

  New_burd_cost_itd		NUMBER := 0;
  New_burd_cost_ytd		NUMBER := 0;
  New_burd_cost_ptd		NUMBER := 0;
  New_burd_cost_pp 		NUMBER := 0;

  New_cmt_burd_cost_itd		NUMBER := 0;
  New_cmt_burd_cost_ytd		NUMBER := 0;
  New_cmt_burd_cost_ptd		NUMBER := 0;
  New_cmt_burd_cost_pp 		NUMBER := 0;

  New_labor_hours_itd		NUMBER := 0;
  New_labor_hours_ytd		NUMBER := 0;
  New_labor_hours_ptd		NUMBER := 0;
  New_labor_hours_pp 		NUMBER := 0;

  New_revenue_itd		NUMBER := 0;
  New_revenue_ytd		NUMBER := 0;
  New_revenue_ptd		NUMBER := 0;
  New_revenue_pp 		NUMBER := 0;

  New_bill_raw_cost_itd		NUMBER := 0;
  New_bill_raw_cost_ytd		NUMBER := 0;
  New_bill_raw_cost_ptd		NUMBER := 0;
  New_bill_raw_cost_pp 		NUMBER := 0;

  New_bill_burd_cost_itd	NUMBER := 0;
  New_bill_burd_cost_ytd	NUMBER := 0;
  New_bill_burd_cost_ptd	NUMBER := 0;
  New_bill_burd_cost_pp 	NUMBER := 0;

  New_bill_labor_hours_itd	NUMBER := 0;
  New_bill_labor_hours_ytd	NUMBER := 0;
  New_bill_labor_hours_ptd	NUMBER := 0;
  New_bill_labor_hours_pp	NUMBER := 0;

  New_cmt_quantity_itd		NUMBER := 0;
  New_cmt_quantity_ytd		NUMBER := 0;
  New_cmt_quantity_ptd		NUMBER := 0;
  New_cmt_quantity_pp 		NUMBER := 0;

  Prt_raw_cost_itd		NUMBER := 0;
  Prt_raw_cost_ytd		NUMBER := 0;
  Prt_raw_cost_ptd		NUMBER := 0;
  Prt_raw_cost_pp 		NUMBER := 0;

  Prt_quantity_itd		NUMBER := 0;
  Prt_quantity_ytd		NUMBER := 0;
  Prt_quantity_ptd		NUMBER := 0;
  Prt_quantity_pp 		NUMBER := 0;

  Prt_bill_quantity_itd		NUMBER := 0;
  Prt_bill_quantity_ytd		NUMBER := 0;
  Prt_bill_quantity_ptd		NUMBER := 0;
  Prt_bill_quantity_pp 		NUMBER := 0;

  Prt_cmt_raw_cost_itd		NUMBER := 0;
  Prt_cmt_raw_cost_ytd		NUMBER := 0;
  Prt_cmt_raw_cost_ptd		NUMBER := 0;
  Prt_cmt_raw_cost_pp 		NUMBER := 0;

  Prt_burd_cost_itd		NUMBER := 0;
  Prt_burd_cost_ytd		NUMBER := 0;
  Prt_burd_cost_ptd		NUMBER := 0;
  Prt_burd_cost_pp 		NUMBER := 0;

  Prt_cmt_burd_cost_itd		NUMBER := 0;
  Prt_cmt_burd_cost_ytd		NUMBER := 0;
  Prt_cmt_burd_cost_ptd		NUMBER := 0;
  Prt_cmt_burd_cost_pp 		NUMBER := 0;

  Prt_labor_hours_itd		NUMBER := 0;
  Prt_labor_hours_ytd		NUMBER := 0;
  Prt_labor_hours_ptd		NUMBER := 0;
  Prt_labor_hours_pp 		NUMBER := 0;

  Prt_revenue_itd		NUMBER := 0;
  Prt_revenue_ytd		NUMBER := 0;
  Prt_revenue_ptd		NUMBER := 0;
  Prt_revenue_pp 		NUMBER := 0;

  Prt_bill_raw_cost_itd		NUMBER := 0;
  Prt_bill_raw_cost_ytd		NUMBER := 0;
  Prt_bill_raw_cost_ptd		NUMBER := 0;
  Prt_bill_raw_cost_pp 		NUMBER := 0;

  Prt_bill_burd_cost_itd	NUMBER := 0;
  Prt_bill_burd_cost_ytd	NUMBER := 0;
  Prt_bill_burd_cost_ptd	NUMBER := 0;
  Prt_bill_burd_cost_pp 	NUMBER := 0;

  Prt_bill_labor_hours_itd	NUMBER := 0;
  Prt_bill_labor_hours_ytd	NUMBER := 0;
  Prt_bill_labor_hours_ptd	NUMBER := 0;
  Prt_bill_labor_hours_pp	NUMBER := 0;

  Prt_cmt_quantity_itd		NUMBER := 0;
  Prt_cmt_quantity_ytd		NUMBER := 0;
  Prt_cmt_quantity_ptd		NUMBER := 0;
  Prt_cmt_quantity_pp 		NUMBER := 0;

  Tsk_raw_cost_itd		NUMBER := 0;
  Tsk_raw_cost_ytd		NUMBER := 0;
  Tsk_raw_cost_ptd		NUMBER := 0;
  Tsk_raw_cost_pp 		NUMBER := 0;

  Tsk_quantity_itd		NUMBER := 0;
  Tsk_quantity_ytd		NUMBER := 0;
  Tsk_quantity_ptd		NUMBER := 0;
  Tsk_quantity_pp 		NUMBER := 0;

  Tsk_bill_quantity_itd		NUMBER := 0;
  Tsk_bill_quantity_ytd		NUMBER := 0;
  Tsk_bill_quantity_ptd		NUMBER := 0;
  Tsk_bill_quantity_pp 		NUMBER := 0;

  Tsk_cmt_raw_cost_itd		NUMBER := 0;
  Tsk_cmt_raw_cost_ytd		NUMBER := 0;
  Tsk_cmt_raw_cost_ptd		NUMBER := 0;
  Tsk_cmt_raw_cost_pp 		NUMBER := 0;

  Tsk_burd_cost_itd		NUMBER := 0;
  Tsk_burd_cost_ytd		NUMBER := 0;
  Tsk_burd_cost_ptd		NUMBER := 0;
  Tsk_burd_cost_pp 		NUMBER := 0;

  Tsk_cmt_burd_cost_itd		NUMBER := 0;
  Tsk_cmt_burd_cost_ytd		NUMBER := 0;
  Tsk_cmt_burd_cost_ptd		NUMBER := 0;
  Tsk_cmt_burd_cost_pp 		NUMBER := 0;

  Tsk_labor_hours_itd		NUMBER := 0;
  Tsk_labor_hours_ytd		NUMBER := 0;
  Tsk_labor_hours_ptd		NUMBER := 0;
  Tsk_labor_hours_pp 		NUMBER := 0;

  Tsk_revenue_itd		NUMBER := 0;
  Tsk_revenue_ytd		NUMBER := 0;
  Tsk_revenue_ptd		NUMBER := 0;
  Tsk_revenue_pp 		NUMBER := 0;

  Tsk_bill_raw_cost_itd		NUMBER := 0;
  Tsk_bill_raw_cost_ytd		NUMBER := 0;
  Tsk_bill_raw_cost_ptd		NUMBER := 0;
  Tsk_bill_raw_cost_pp 		NUMBER := 0;

  Tsk_bill_burd_cost_itd	NUMBER := 0;
  Tsk_bill_burd_cost_ytd	NUMBER := 0;
  Tsk_bill_burd_cost_ptd	NUMBER := 0;
  Tsk_bill_burd_cost_pp 	NUMBER := 0;

  Tsk_bill_labor_hours_itd	NUMBER := 0;
  Tsk_bill_labor_hours_ytd	NUMBER := 0;
  Tsk_bill_labor_hours_ptd	NUMBER := 0;
  Tsk_bill_labor_hours_pp	NUMBER := 0;

  Tsk_cmt_quantity_itd		NUMBER := 0;
  Tsk_cmt_quantity_ytd		NUMBER := 0;
  Tsk_cmt_quantity_ptd		NUMBER := 0;
  Tsk_cmt_quantity_pp 		NUMBER := 0;

Procedure Process_Txn_Accum  (x_project_id in Number,
                              x_impl_opt  In Varchar2,
                              x_Proj_accum_id   in Number,
                              x_current_period in Varchar2,
                              x_prev_period    in Varchar2,
                              x_current_year   in Number,
                              x_prev_accum_period in Varchar2,
                              x_current_start_date In Date,
                              x_current_end_date  In Date,
                              x_actual_cost_flag  In Varchar2,
                              x_revenue_flag  In Varchar2,
                              x_commitments_flag  In Varchar2,
                              x_resource_list_id In number,
                              x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

 Procedure Check_Accum_Res_Tasks( x_project_id In Number,
                                  x_task_id    In Number,
				  x_proj_accum_id IN Number,
				  x_current_period IN VARCHAR2,
                                  x_resource_list_id in Number,
                                  x_resource_list_Member_id in Number,
                                  x_resource_id in Number,
                                  x_resource_list_assignment_id in Number,
                                  x_create_actuals IN Varchar2,
                                  x_create_commit  IN Varchar2,
                                  x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                  x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                  x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895
 Procedure Check_Accum_wbs ( x_project_id In Number,
                                  x_task_id    In Number,
				  x_proj_accum_id IN Number,
				  x_current_period IN VARCHAR2,
                                  x_resource_list_id in Number,
                                  x_resource_list_Member_id in Number,
                                  x_resource_id in Number,
                                  x_resource_list_assignment_id in Number,
                                  x_create_wbs_actuals IN Varchar2,
                                  x_create_wbs_commit  IN Varchar2,
                                  x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                  x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                  x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895
Procedure create_accum_actuals
                             (x_project_id In Number,
                              x_task_id In Number,
                              x_current_period In Varchar2,
                              x_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                              x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

Procedure create_accum_actuals_res
                             (x_project_id In Number,
                              x_task_id In Number,
                              x_resource_list_id in Number,
                              x_resource_list_Member_id in Number,
                              x_resource_id in Number,
                              x_resource_list_assignment_id in Number,
                              x_current_period In Varchar2,
                              x_Recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                              x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

Procedure Get_all_higher_tasks
			     (x_project_id in Number,
                              x_task_id in Number,
                              x_resource_list_member_id in Number,
                              x_task_array  Out NOCOPY task_id_tabtype, --File.Sql.39 bug 4440895
                              x_noof_tasks Out NOCOPY number, --File.Sql.39 bug 4440895
                              x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_Code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

Procedure Insert_Headers_tasks
			     (x_project_id In Number,
                              x_task_id In Number,
                              x_current_period In Varchar2,
                              x_accum_id In Number,
                              x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

Procedure Initialize_actuals
			     (x_project_id  In Number,
                              x_accum_id    In Number,
                              x_impl_opt    In Varchar2,
                              x_current_period In Varchar2,
                              x_prev_period    In Varchar2,
                              x_prev_Accum_period In Varchar2,
                              x_current_year  In Number,
                              x_prev_year     In Number,
                              x_prev_accum_year In Number,
                              x_current_start_date In Date,
                              x_current_end_date In Date,
                              x_prev_start_date In Date,
                              x_prev_end_date In Date,
                              x_prev_accum_start_date In Date,
                              x_prev_accum_end_date In Date,
                              x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

Procedure Initialize_budgets
			     (x_project_id  In Number,
                              x_accum_id    In Number,
                              x_impl_opt    In Varchar2,
                              x_budget_type In Varchar2,
                              x_current_period In Varchar2,
                              x_prev_period    In Varchar2,
                              x_prev_accum_period In Varchar2,
                              x_current_year  In Number,
                              x_prev_year     In Number,
                              x_prev_accum_year In Number,
                              x_current_start_date In Date,
                              x_current_end_date In Date,
                              x_prev_start_date In Date,
                              x_prev_end_date In Date,
                              x_prev_accum_start_date In Date,
                              x_prev_accum_end_date In Date,
                              x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

Procedure initialize_commitments
                             (x_project_id  In Number,
                              x_accum_id    In Number,
                              x_impl_opt    In Varchar2,
                              x_current_period In Varchar2,
                              x_prev_period    In Varchar2,
                              x_prev_accum_period In Varchar2,
                              x_current_year  In Number,
                              x_prev_year     In Number,
                              x_prev_accum_year In Number,
                              x_current_start_date In Date,
                              x_current_end_date In Date,
                              x_prev_start_date In Date,
                              x_prev_end_date In Date,
                              x_prev_accum_start_date In Date,
                              x_prev_accum_end_date In Date,
                              x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

Procedure Initialize_task_level;

Procedure Initialize_parent_level;

Procedure Initialize_project_level;

Procedure Add_Parent_amounts;

Procedure Add_Project_amounts;

End ;

 

/
