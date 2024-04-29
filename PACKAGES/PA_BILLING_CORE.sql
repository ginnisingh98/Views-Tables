--------------------------------------------------------
--  DDL for Package PA_BILLING_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BILLING_CORE" AUTHID CURRENT_USER as
-- $Header: PAXINBCS.pls 120.1 2005/08/19 17:14:18 mwasowic noship $

  procedure verify_baseline_funding(
		      x_project_id        in     number,
		      x_draft_version_id  in     number,
                      x_entry_level_code  in     varchar2,
                      x_proj_bu_revenue   in     number,
                      x_err_code          in out NOCOPY number, --File.Sql.39 bug 4440895
                      x_err_stage         in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                      x_err_stack         in out NOCOPY varchar2); --File.Sql.39 bug 4440895

  procedure update_funding(
                      x_project_id        in     number,
                      x_funding_level     in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                      x_err_code          in out NOCOPY number, --File.Sql.39 bug 4440895
                      x_err_stage         in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                      x_err_stack         in out NOCOPY varchar2); --File.Sql.39 bug 4440895

  procedure check_funding_level(
		      x_project_id        in     number,
                      x_funding_level     in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                      x_err_code          in out NOCOPY number, --File.Sql.39 bug 4440895
                      x_err_stage         in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                      x_err_stack         in out NOCOPY varchar2); --File.Sql.39 bug 4440895

  procedure copy_agreement(
                      x_orig_project_id   in     number,
                      x_new_project_id    in     number,
		      x_customer_id	  in	 number,
                      x_owning_organization_id    in     number default null,
                      x_agreement_currency_code   in     varchar2 default null,
                      x_amount            in     number default null,
		      x_template_flag     in     varchar2,
		      x_delta		  in	 number,
                      x_err_code          in out NOCOPY number, --File.Sql.39 bug 4440895
                      x_err_stage         in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                      x_err_stack         in out NOCOPY varchar2); --File.Sql.39 bug 4440895

  procedure copy_funding(
                      x_orig_project_id   in     number,
                      x_new_project_id    in     number,
                      x_agreement_id      in     number,
		      x_delta		  in	 number,
                      x_err_code          in out NOCOPY number, --File.Sql.39 bug 4440895
                      x_err_stage         in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                      x_err_stack         in out NOCOPY varchar2); --File.Sql.39 bug 4440895

  Function Check_funding_Exists(x_project_id        in     number) return varchar2;

  -- These changes are made for FP_M
    -- Function to check whether Top Task Customer Flag at project level
    -- can be updateable
  Function Update_Top_Task_Cust_Flag (
		      P_Project_ID	IN	Number
  ) Return Varchar2;

    -- Function to check whether Top Task Invoice Method Flag at project level
    -- can be updateable
  Function Update_Top_Task_Inv_Mthd_Flag (
		      P_Project_ID	IN	Number
  ) Return Varchar2;

    -- Function to check whether the combination of Invoice and Revenue
    -- methods are existing in Project Type distribution rules or not
  Function Check_Revenue_Invoice_Methods (
		      P_Project_ID	IN	Number
  ) Return Varchar2;

    -- Check required at Top Task level
    -- Function to check whether Top Task Customer can be updateable
    -- at Task level window
  Function Update_Top_Task_Customer (
		      P_Project_ID	IN	Number,
		      P_Task_ID		IN	Number
  ) Return Varchar2;

    -- Function to check whether Top Task Invoice Method can be updateable
    -- at Task level window
  Function Update_Top_Task_Invoice_Method (
		      P_Project_ID	IN	Number,
		      P_Task_ID		IN	Number
  ) Return Varchar2;

end pa_billing_core ;
 

/
