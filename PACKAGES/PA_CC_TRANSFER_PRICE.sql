--------------------------------------------------------
--  DDL for Package PA_CC_TRANSFER_PRICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CC_TRANSFER_PRICE" AUTHID CURRENT_USER AS
/*  $Header: PAXCCTPS.pls 120.2 2007/02/09 05:28:27 anuagraw ship $  */

-------------------------------------------------------------------------------
  -- Procedure
  -- Get_Transfer_Price
  -- Purpose
  -- Called from Borrowed and Lent Process and IC Billing program
  -- This procedure is overloaded procedure. This procedure accepts
  -- amount,percentage (float) and Date datatypes as Varchar2 and does the
  -- explicit conversion.

PROCEDURE Get_Transfer_Price
	(
	p_module_name			IN	VARCHAR2,
 	p_prvdr_organization_id		IN 	PA_PLSQL_DATATYPES.IdTabTyp,
        p_recvr_org_id			IN 	PA_PLSQL_DATATYPES.IdTabTyp,
        p_recvr_organization_id		IN 	PA_PLSQL_DATATYPES.IdTabTyp,
        p_expnd_organization_id		IN 	PA_PLSQL_DATATYPES.IdTabTyp,
        p_expenditure_item_id		IN 	PA_PLSQL_DATATYPES.IdTabTyp,
        p_expenditure_type		IN 	PA_PLSQL_DATATYPES.Char30TabTyp,
	p_expenditure_category		IN	PA_PLSQL_DATATYPES.Char30TabTyp,
	p_expenditure_item_date 	IN	PA_PLSQL_DATATYPES.Char30TabTyp,
	p_labor_non_labor_flag		IN	PA_PLSQL_DATATYPES.Char1TabTyp,
	p_system_linkage_function 	IN	PA_PLSQL_DATATYPES.Char30TabTyp,
	p_task_id			IN	PA_PLSQL_DATATYPES.IdTabTyp,
	p_tp_schedule_id		IN	PA_PLSQL_DATATYPES.IdTabTyp,
	p_denom_currency_code		IN	PA_PLSQL_DATATYPES.Char15TabTyp,
	p_project_currency_code		IN	PA_PLSQL_DATATYPES.Char15TabTyp,
--Start Added for devdrop2
        p_projfunc_currency_code        IN      PA_PLSQL_DATATYPES.Char15TabTyp,
--End   Added for devdrop2
	p_revenue_distributed_flag 	IN	PA_PLSQL_DATATYPES.Char1TabTyp,
	p_processed_thru_date 		IN	Date,
	p_compute_flag 			IN	PA_PLSQL_DATATYPES.Char1TabTyp,
	p_tp_fixed_date			IN	PA_PLSQL_DATATYPES.Char30TabTyp,
	p_denom_raw_cost_amount		IN	PA_PLSQL_DATATYPES.Char30TabTyp,
	p_denom_burdened_cost_amount 	IN	PA_PLSQL_DATATYPES.Char30TabTyp,
	p_raw_revenue_amount 		IN	PA_PLSQL_DATATYPES.Char30TabTyp,
	p_project_id 			IN	PA_PLSQL_DATATYPES.IdTabTyp,
	p_quantity 			IN	PA_PLSQL_DATATYPES.Char30TabTyp,
	p_incurred_by_person_id 	IN	PA_PLSQL_DATATYPES.IdTabTyp,
	p_job_id 			IN	PA_PLSQL_DATATYPES.IdTabTyp,
	p_non_labor_resource 		IN	PA_PLSQL_DATATYPES.Char20TabTyp,
	p_nl_resource_organization_id	IN	PA_PLSQL_DATATYPES.IdTabTyp,
	p_pa_date 			IN	PA_PLSQL_DATATYPES.Char30TabTyp
				default PA_PLSQL_DATATYPES.EmptyChar30Tab,
	p_array_size			IN	Number,
	p_debug_mode			IN	Varchar2,
--Start Added for devdrop2
        p_tp_amt_type_code              IN      PA_PLSQL_DATATYPES.Char30TabTyp,
        p_assignment_id                 IN      PA_PLSQL_DATATYPES.IdTabTyp,
	x_proj_tp_rate_type	 IN OUT	NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
	x_proj_tp_rate_date	 IN OUT	NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
	x_proj_tp_exchange_rate	 IN OUT	NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
	x_proj_transfer_price	 IN OUT	NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
--
	x_projfunc_tp_rate_type	 IN OUT	NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
	x_projfunc_tp_rate_date	 IN OUT	NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
	x_projfunc_tp_exchange_rate	 IN OUT	NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
	x_projfunc_transfer_price	 IN OUT	NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
--End   Added for devdrop2
	x_denom_tp_currency_code IN OUT	NOCOPY  PA_PLSQL_DATATYPES.Char15TabTyp,
	x_denom_transfer_price	 IN OUT	 NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
	x_acct_tp_rate_type	 IN OUT	NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
	x_acct_tp_rate_date	 IN OUT	NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
	x_acct_tp_exchange_rate	 IN OUT	NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
	x_acct_transfer_price	 IN OUT	NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
	x_cc_markup_base_code	 IN OUT	NOCOPY  PA_PLSQL_DATATYPES.Char1TabTyp,
	x_tp_ind_compiled_set_id IN OUT	NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp,
	x_tp_bill_rate		 IN OUT	NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
	x_tp_base_amount	 IN OUT	NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
       x_tp_bill_markup_percentage IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
     x_tp_schedule_line_percentage IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
     x_tp_rule_percentage         IN OUT  NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
        x_tp_job_id              IN OUT NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp,
	x_error_code		  IN OUT  NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
	x_return_status		OUT 	NOCOPY   NUMBER	,
/* Bill rate Discount*/
        p_dist_rule                     IN       PA_PLSQL_DATATYPES.Char30TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar30Tab,
        p_mcb_flag                      IN       PA_PLSQL_DATATYPES.Char1TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar1Tab,
        p_bill_rate_multiplier          IN       PA_PLSQL_DATATYPES.Char30TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar30Tab,
        p_raw_cost                      IN       PA_PLSQL_DATATYPES.Char30TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar30Tab,
        /* bug#3221791 */
        p_labor_schdl_discnt            IN       PA_PLSQL_DATATYPES.Char30TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar30Tab,
        p_labor_schdl_fixed_date        IN       PA_PLSQL_DATATYPES.Char30TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar30Tab,
        p_bill_job_grp_id               IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_labor_sch_type                IN       PA_PLSQL_DATATYPES.Char1TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar1Tab,
        p_project_org_id                IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_project_type                  IN       PA_PLSQL_DATATYPES.Char30TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar30Tab,
        p_exp_func_curr_code            IN       PA_PLSQL_DATATYPES.Char30TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar30Tab,
        p_incurred_by_organz_id         IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_raw_cost_rate                 IN       PA_PLSQL_DATATYPES.Char30TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar30Tab,
        p_override_to_organz_id         IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_emp_bill_rate_schedule_id     IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_job_bill_rate_schedule_id     IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_exp_raw_cost                  IN       PA_PLSQL_DATATYPES.Char30TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar30Tab,
        p_assignment_precedes_task      IN       PA_PLSQL_DATATYPES.Char1TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar1Tab,

        p_burden_cost                   IN       PA_PLSQL_DATATYPES.Char30TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar30Tab,
        p_task_nl_bill_rate_org_id      IN       PA_PLSQL_DATATYPES.IdTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyIdTab,
        p_proj_nl_bill_rate_org_id      IN       PA_PLSQL_DATATYPES.IdTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyIdTab,
        p_task_nl_std_bill_rate_sch     IN       PA_PLSQL_DATATYPES.Char30TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar30Tab,
        p_proj_nl_std_bill_rate_sch     IN       PA_PLSQL_DATATYPES.Char30TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar30Tab,
        p_nl_task_sch_date              IN       PA_PLSQL_DATATYPES.Char30TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar30Tab,
        p_nl_proj_sch_date              IN       PA_PLSQL_DATATYPES.Char30TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar30Tab,
        p_nl_task_sch_discount          IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_nl_proj_sch_discount          IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_nl_sch_type                   IN       PA_PLSQL_DATATYPES.Char1TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar1Tab,
                                      /* Added the two parameters for Doosan rate api enhancement */
        p_task_nl_std_bill_rate_sch_id     IN PA_PLSQL_DATATYPES.NumTabTyp       DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_proj_nl_std_bill_rate_sch_id     IN PA_PLSQL_DATATYPES.NumTabTyp       DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_uom_flag                      IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab

        );

--------------------------------------------------------------------------------
  -- Procedure
  -- Get_Transfer_Price
  -- Purpose
  -- Called from Borrowed and Lent Process and IC Billing
  -- It calculates Transfer Price

PROCEDURE Get_Transfer_Price
	(
	p_module_name			IN	VARCHAR2,
 	p_prvdr_organization_id		IN 	PA_PLSQL_DATATYPES.IdTabTyp,
        p_recvr_org_id			IN 	PA_PLSQL_DATATYPES.IdTabTyp,
        p_recvr_organization_id		IN 	PA_PLSQL_DATATYPES.IdTabTyp,
        p_expnd_organization_id		IN 	PA_PLSQL_DATATYPES.IdTabTyp,
        p_expenditure_item_id		IN 	PA_PLSQL_DATATYPES.IdTabTyp,
        p_expenditure_type		IN 	PA_PLSQL_DATATYPES.Char30TabTyp,
	p_expenditure_category		IN	PA_PLSQL_DATATYPES.Char30TabTyp,
	p_expenditure_item_date 	IN	PA_PLSQL_DATATYPES.DateTabTyp,
	p_labor_non_labor_flag		IN	PA_PLSQL_DATATYPES.Char1TabTyp,
	p_system_linkage_function 	IN	PA_PLSQL_DATATYPES.Char30TabTyp,
	p_task_id			IN	PA_PLSQL_DATATYPES.IdTabTyp,
	p_tp_schedule_id		IN	PA_PLSQL_DATATYPES.IdTabTyp,
	p_denom_currency_code		IN	PA_PLSQL_DATATYPES.Char15TabTyp,
	p_project_currency_code		IN	PA_PLSQL_DATATYPES.Char15TabTyp,
--Start Added for devdrop2
        p_projfunc_currency_code        IN      PA_PLSQL_DATATYPES.Char15TabTyp,
--End   Added for devdrop2
	p_revenue_distributed_flag 	IN	PA_PLSQL_DATATYPES.Char1TabTyp,
	p_processed_thru_date 		IN	Date,
	p_compute_flag 			IN	PA_PLSQL_DATATYPES.Char1TabTyp,
	p_tp_fixed_date			IN	PA_PLSQL_DATATYPES.DateTabTyp,
	p_denom_raw_cost_amount		IN	PA_PLSQL_DATATYPES.NumTabTyp,
	p_denom_burdened_cost_amount 	IN	PA_PLSQL_DATATYPES.NumTabTyp,
	p_raw_revenue_amount 		IN	PA_PLSQL_DATATYPES.NumTabTyp,
	p_project_id 			IN	PA_PLSQL_DATATYPES.IdTabTyp,
	p_quantity 			IN	PA_PLSQL_DATATYPES.NumTabTyp,
	p_incurred_by_person_id 	IN	PA_PLSQL_DATATYPES.IdTabTyp,
	p_job_id 			IN	PA_PLSQL_DATATYPES.IdTabTyp,
	p_non_labor_resource 		IN	PA_PLSQL_DATATYPES.Char20TabTyp,
	p_nl_resource_organization_id	IN	PA_PLSQL_DATATYPES.IdTabTyp,
	p_pa_date 			IN	PA_PLSQL_DATATYPES.DateTabTyp
				   default      PA_PLSQL_DATATYPES.EmptyDateTab,
	p_array_size			IN	Number,
	p_debug_mode			IN	Varchar2,
--Start Added for devdrop2
        p_tp_amt_type_code              IN      PA_PLSQL_DATATYPES.Char30TabTyp,
        p_assignment_id                 IN      PA_PLSQL_DATATYPES.IdTabTyp,
        p_prvdr_operating_unit          IN      PA_PLSQL_DATATYPES.IdTabTyp
                               DEFAULT PA_PLSQL_DATATYPES.EmptyIDTab ,
--
        x_proj_tp_rate_type      IN OUT NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
        x_proj_tp_rate_date      IN OUT NOCOPY  PA_PLSQL_DATATYPES.DateTabTyp,
        x_proj_tp_exchange_rate  IN OUT NOCOPY  PA_PLSQL_DATATYPES.NumTabTyp,
        x_proj_transfer_price    IN OUT NOCOPY  PA_PLSQL_DATATYPES.NumTabTyp,
--
        x_projfunc_tp_rate_type  IN OUT NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
        x_projfunc_tp_rate_date  IN OUT NOCOPY  PA_PLSQL_DATATYPES.DateTabTyp,
        x_projfunc_tp_exchange_rate      IN OUT NOCOPY  PA_PLSQL_DATATYPES.NumTabTyp,
        x_projfunc_transfer_price        IN OUT NOCOPY  PA_PLSQL_DATATYPES.NumTabTyp,
--End   Added for devdrop2
	x_denom_tp_currency_code  IN OUT NOCOPY PA_PLSQL_DATATYPES.Char15TabTyp,
	x_denom_transfer_price	  IN OUT NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,
	x_acct_tp_rate_type	  IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
	x_acct_tp_rate_date	  IN OUT NOCOPY	PA_PLSQL_DATATYPES.DateTabTyp,
	x_acct_tp_exchange_rate	  IN OUT NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,
	x_acct_transfer_price	  IN OUT NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,
	x_cc_markup_base_code	  IN OUT NOCOPY PA_PLSQL_DATATYPES.Char1TabTyp,
	x_tp_ind_compiled_set_id  IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
	x_tp_bill_rate		  IN OUT NOCOPY	PA_PLSQL_DATATYPES.NumTabTyp,
	x_tp_base_amount	  IN OUT NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,
	x_tp_bill_markup_percentage IN OUT NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,
       x_tp_schedule_line_percentage IN OUT NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,
	x_tp_rule_percentage	  IN OUT NOCOPY	PA_PLSQL_DATATYPES.NumTabTyp,
        x_tp_job_id              IN OUT NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp,
	x_error_code		  IN OUT NOCOPY    PA_PLSQL_DATATYPES.Char30TabTyp,
	x_return_status		OUT 	NOCOPY NUMBER	,/*File.sql.39*/
/* Bill rate Discount*/
        p_dist_rule                     IN       PA_PLSQL_DATATYPES.Char30TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar30Tab,
        p_mcb_flag                      IN       PA_PLSQL_DATATYPES.Char1TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar1Tab,
        p_bill_rate_multiplier          IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_raw_cost                      IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        /* bug#3221791 */
        p_labor_schdl_discnt            IN       PA_PLSQL_DATATYPES.Char30TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar30Tab,
        p_labor_schdl_fixed_date        IN       PA_PLSQL_DATATYPES.DateTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyDateTab,
        p_bill_job_grp_id               IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_labor_sch_type                IN       PA_PLSQL_DATATYPES.Char1TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar1Tab,
        p_project_org_id                IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_project_type                  IN       PA_PLSQL_DATATYPES.Char30TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar30Tab,
        p_exp_func_curr_code            IN       PA_PLSQL_DATATYPES.Char30TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar30Tab,
        p_incurred_by_organz_id         IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_raw_cost_rate                 IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_override_to_organz_id         IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_emp_bill_rate_schedule_id     IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_job_bill_rate_schedule_id     IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_exp_raw_cost                  IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_assignment_precedes_task      IN       PA_PLSQL_DATATYPES.Char1TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar1Tab,

        p_burden_cost                   IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_task_nl_bill_rate_org_id      IN       PA_PLSQL_DATATYPES.IdTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyIDTab,
        p_proj_nl_bill_rate_org_id      IN       PA_PLSQL_DATATYPES.IdTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyIdTab,
        p_task_nl_std_bill_rate_sch     IN       PA_PLSQL_DATATYPES.Char30TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar30Tab,
        p_proj_nl_std_bill_rate_sch     IN       PA_PLSQL_DATATYPES.Char30TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar30Tab,
        p_nl_task_sch_date              IN       PA_PLSQL_DATATYPES.DateTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyDateTab,
        p_nl_proj_sch_date              IN       PA_PLSQL_DATATYPES.DateTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyDateTab,
        p_nl_task_sch_discount          IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_nl_proj_sch_discount          IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_nl_sch_type                   IN       PA_PLSQL_DATATYPES.Char1TabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyChar1Tab,
                                      /* Added the two parameters for Doosan rate api enhancement */
        p_task_nl_std_bill_rate_sch_id     IN PA_PLSQL_DATATYPES.NumTabTyp       DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_proj_nl_std_bill_rate_sch_id     IN PA_PLSQL_DATATYPES.NumTabTyp       DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_uom_flag                      IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab

        );

--------------------------------------------------------------------------------
-- Set the global variables provider_org_id,cc_default_rate_type,
-- cc_default_rate_date etc.

PROCEDURE Get_Provider_Attributes (
                p_prvdr_operating_unit         IN      PA_PLSQL_DATATYPES.IdTabTyp
                               DEFAULT PA_PLSQL_DATATYPES.EmptyIDTab,
		x_error_code            IN OUT  NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp )
;
--------------------------------------------------------------------------------

PROCEDURE SET_GLOBAL_VARIABLES (
		p_org_id		IN	NUMBER)
;
--------------------------------------------------------------------------------

-- Validate the input parameters
--  Check if schedule_id is null
--  Mark the transactions where transfer price calculation not needed i.e they
--  are marked for only currency conversion.

PROCEDURE Validate_Array
	(
        p_prvdr_operating_unit         IN      PA_PLSQL_DATATYPES.IdTabTyp
                               DEFAULT PA_PLSQL_DATATYPES.EmptyIDTab ,
	p_tp_schedule_id		IN	PA_PLSQL_DATATYPES.IdTabTyp,
	p_denom_tp_currency_code	IN 	PA_PLSQL_DATATYPES.Char15TabTyp,
        p_acct_currency_code            IN      varchar2 ,
	p_denom_transfer_price		IN 	PA_PLSQL_DATATYPES.NumTabTyp,
	p_acct_tp_rate_type		IN 	PA_PLSQL_DATATYPES.Char30TabTyp,
	p_acct_tp_rate_date		IN 	PA_PLSQL_DATATYPES.DateTabTyp,
	p_acct_transfer_price		IN 	PA_PLSQL_DATATYPES.NumTabTyp,
	p_acct_tp_exchange_rate         IN      PA_PLSQL_DATATYPES.NumTabTyp,
	x_compute_flag 		IN OUT 	NOCOPY  PA_PLSQL_DATATYPES.Char1TabTyp,
	x_error_code		IN OUT  NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp
	);

--------------------------------------------------------------------------------
-- Set the global variables for WHO columns i.e. G_created_by,G_creation_date
-- , G_last_updated_by,G_last_Update_date etc.

PROCEDURE Init_who_cols;

--------------------------------------------------------------------------------
-- Get Legal entity id of an operating unit

PROCEDURE Get_Legal_Entity (
	p_org_id		IN	NUMBER,
	x_legal_entity_id 	OUT	NOCOPY NUMBER/*File.sql.39*/
			);

--------------------------------------------------------------------------------
-- Get schedule_line_id given a schedule_id and processed_thru_date
-- Apply transfer price determination rules to identify schedule_line_id
-- for a given provider, receiver organization and operating unit combinations.
PROCEDURE Get_Schedule_Line(
        p_expenditure_item_id		IN 	PA_PLSQL_DATATYPES.IdTabTyp,
        /* Start Added for 3118101 */
        p_expenditure_item_date         IN      PA_PLSQL_DATATYPES.DateTabTyp,
        /* End Added for 3118101 */
 	p_prvdr_organization_id		IN 	PA_PLSQL_DATATYPES.IdTabTyp,
        p_recvr_org_id			IN 	PA_PLSQL_DATATYPES.IdTabTyp,
        p_recvr_organization_id		IN 	PA_PLSQL_DATATYPES.IdTabTyp,
	p_labor_non_labor_flag		IN	PA_PLSQL_DATATYPES.Char1TabTyp,
	p_tp_schedule_id		IN	PA_PLSQL_DATATYPES.IdTabTyp,
	p_compute_flag 			IN	PA_PLSQL_DATATYPES.Char1TabTyp,
--Start Added for devdrop2
        p_tp_amt_type_code              IN      PA_PLSQL_DATATYPES.Char30TabTyp,
--End   Added for devdrop2
        p_prvdr_operating_unit          IN      PA_PLSQL_DATATYPES.IdTabTyp
                               DEFAULT PA_PLSQL_DATATYPES.EmptyIDTab ,
                                /** Added for Org Forecasting **/
	x_error_code		IN OUT  NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
	x_tp_schedule_line_id	OUT	NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp,
      x_tp_schedule_line_percentage IN OUT	NOCOPY  PA_PLSQL_DATATYPES.NumTabTyp,
	x_tp_rule_id		OUT	NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp
			  );
--------------------------------------------------------------------------------
-- Get schedule_line_id from Lookup table
PROCEDURE Get_Schedule_Line_From_Lookup(
 	p_prvdr_organization_id		IN 	Number,
        p_recvr_org_id			IN 	Number,
        p_recvr_organization_id		IN 	Number,
	p_tp_schedule_id		IN	Number,
	p_labor_flag			IN      Varchar2,
	p_tp_amt_type_code		IN      Varchar2,
        /* Start Added for 3118101 */
        p_expenditure_item_date         IN      Date,
        /* End Added for 3118101 */
	x_tp_schedule_line_id		OUT	NOCOPY Number/*File.sql.39*/
					);
--------------------------------------------------------------------------------
-- Determine schedule_line_id using transfer price rules - given a combination
-- of provider org, receiver org, provider ou and receiver ou.
PROCEDURE Determine_Schedule_Line(
 	p_prvdr_organization_id		IN 	Number,
        p_recvr_org_id			IN 	Number,
        p_recvr_organization_id		IN 	Number,
	p_tp_schedule_id		IN	Number,
	p_labor_non_labor_flag          IN      Varchar2,
        /* Start Added for 3118101 */
        p_expenditure_item_date         IN      Date,
        /* End Added for 3118101 */
--Start Added for devdrop2
        p_tp_amt_type_code              IN      Varchar2,
--End   Added for devdrop2
	x_tp_schedule_line_id		OUT	NOCOPY Number,/*File.sql.39*/
	x_tp_rule_id		        OUT	NOCOPY Number,/*File.sql.39*/
	x_percentage_applied	        OUT	NOCOPY Number,/*File.sql.39*/
	x_start_date_active		OUT	NOCOPY Date,/*File.sql.39*/
	x_end_date_active		OUT	NOCOPY Date,/*File.sql.39*/
        x_sort_order                    OUT     NOCOPY Number,  /*bug5753774*/
	x_error_code			IN OUT	NOCOPY VARCHAR2/*File.sql.39*/
				    );
-------------------------------------------------------------------------------
-- Insert a row into Schedule Line lookup table.

PROCEDURE Insert_Schedule_Line_Into_Lkp(
 	p_prvdr_organization_id		IN 	Number,
        p_recvr_org_id			IN 	Number,
        p_recvr_organization_id		IN 	Number,
	p_tp_schedule_id		IN	Number,
	p_tp_schedule_line_id		IN	Number,
	p_labor_flag			IN	Varchar2,
	p_tp_amt_type_code		IN      Varchar2,
	p_start_date_active		IN	Date,
	p_end_date_active		IN	Date,
        p_sort_order                    IN      Number,   /*bug5753774*/
	x_error_code			IN OUT	NOCOPY Varchar2 /*File.sql.39*/
					);

-------------------------------------------------------------------------------
-- Get schedule_line attributes from pa_cc_tp_schedule_lines table

PROCEDURE Get_Schedule_Line_Attributes(
	p_tp_schedule_line_id		IN	Number,
	p_labor_flag                    IN      Varchar2,
	x_tp_rule_id		        OUT	NOCOPY Number, /*File.sql.39*/
	x_percentage_applied	        OUT	NOCOPY Number, /*File.sql.39*/
	x_error_code			IN OUT	NOCOPY VARCHAR2 /*File.sql.39*/
					);
--------------------------------------------------------------------------------
PROCEDURE Get_Transfer_Price_Amount
	(
	p_tp_rule_id			IN	PA_PLSQL_DATATYPES.IdTabTyp,
        p_expenditure_item_id		IN 	PA_PLSQL_DATATYPES.IdTabTyp,
        p_expenditure_type		IN 	PA_PLSQL_DATATYPES.Char30TabTyp,
	p_expenditure_item_date 	IN	PA_PLSQL_DATATYPES.DateTabTyp,
        p_expnd_organization_id		IN 	PA_PLSQL_DATATYPES.IdTabTyp,
        p_project_id			IN 	PA_PLSQL_DATATYPES.IdTabTyp,
        p_task_id			IN 	PA_PLSQL_DATATYPES.IdTabTyp,
	p_denom_currency_code		IN	PA_PLSQL_DATATYPES.Char15TabTyp,
	p_projfunc_currency_code		IN	PA_PLSQL_DATATYPES.Char15TabTyp,
	p_revenue_distributed_flag 	IN	PA_PLSQL_DATATYPES.Char1TabTyp,
	p_compute_flag 			IN	PA_PLSQL_DATATYPES.Char1TabTyp,
	p_denom_raw_cost_amount		IN	PA_PLSQL_DATATYPES.NumTabTyp,
	p_denom_burdened_cost_amount 	IN	PA_PLSQL_DATATYPES.NumTabTyp,
	p_raw_revenue_amount 		IN	PA_PLSQL_DATATYPES.NumTabTyp,
	p_quantity 			IN	PA_PLSQL_DATATYPES.NumTabTyp,
	p_incurred_by_person_id 	IN	PA_PLSQL_DATATYPES.IdTabTyp,
	p_job_id 			IN	PA_PLSQL_DATATYPES.IdTabTyp,
	p_non_labor_resource 		IN	PA_PLSQL_DATATYPES.Char20TabTyp,
	p_nl_resource_organization_id	IN	PA_PLSQL_DATATYPES.IdTabTyp,
	p_system_linkage_function 	IN	PA_PLSQL_DATATYPES.Char30TabTyp,
	p_tp_schedule_line_percentage	IN	PA_PLSQL_DATATYPES.NumTabTyp,
	p_tp_fixed_date 	        IN	PA_PLSQL_DATATYPES.DateTabTyp,
	x_denom_tp_currency_code IN OUT	NOCOPY  PA_PLSQL_DATATYPES.Char15TabTyp,
	x_denom_transfer_price	 IN OUT	NOCOPY  PA_PLSQL_DATATYPES.NumTabTyp,
	x_cc_markup_base_code	 IN OUT	NOCOPY  PA_PLSQL_DATATYPES.Char1TabTyp,
	x_tp_ind_compiled_set_id IN OUT	NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp,
	x_tp_bill_rate		 IN OUT	NOCOPY  PA_PLSQL_DATATYPES.NumTabTyp,
	x_tp_base_curr_code	 OUT	NOCOPY  PA_PLSQL_DATATYPES.Char15TabTyp,
	x_tp_base_amount	 IN OUT	NOCOPY  PA_PLSQL_DATATYPES.NumTabTyp,
     x_tp_bill_markup_percentage IN OUT	NOCOPY  PA_PLSQL_DATATYPES.NumTabTyp,
     x_tp_rule_percentage	 IN OUT	NOCOPY  PA_PLSQL_DATATYPES.NumTabTyp,
        x_tp_job_id              IN OUT NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp,
	x_error_code	     IN	OUT	NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
/* Bill rate Discount*/
        p_dist_rule                     IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_mcb_flag                      IN       PA_PLSQL_DATATYPES.Char1TabTyp,
        p_bill_rate_multiplier          IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_raw_cost                      IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_labor_schdl_discnt            IN       PA_PLSQL_DATATYPES.Char30TabTyp, /* bug#3221791 */
        p_labor_schdl_fixed_date        IN       PA_PLSQL_DATATYPES.DateTabTyp,
        p_bill_job_grp_id               IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_labor_sch_type                IN       PA_PLSQL_DATATYPES.Char1TabTyp,
        p_project_org_id                IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_project_type                  IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_exp_func_curr_code            IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_incurred_by_organz_id         IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_raw_cost_rate                 IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_override_to_organz_id         IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_emp_bill_rate_schedule_id     IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_job_bill_rate_schedule_id     IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_exp_raw_cost                  IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_assignment_precedes_task      IN       PA_PLSQL_DATATYPES.Char1TabTyp,
        p_assignment_id                 IN       PA_PLSQL_DATATYPES.IdTabTyp,

        p_burden_cost                   IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_task_nl_bill_rate_org_id      IN       PA_PLSQL_DATATYPES.IdTabTyp,
        p_proj_nl_bill_rate_org_id      IN       PA_PLSQL_DATATYPES.IdTabTyp,
        p_task_nl_std_bill_rate_sch     IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_proj_nl_std_bill_rate_sch     IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_nl_task_sch_date              IN       PA_PLSQL_DATATYPES.DateTabTyp,
        p_nl_proj_sch_date              IN       PA_PLSQL_DATATYPES.DateTabTyp,
        p_nl_task_sch_discount          IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_nl_proj_sch_discount          IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_nl_sch_type                   IN       PA_PLSQL_DATATYPES.Char1TabTyp,
        /* Added the two parameters for Doosan rate api enhancement */
        p_task_nl_std_bill_rate_sch_id     IN PA_PLSQL_DATATYPES.NumTabTyp       DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_proj_nl_std_bill_rate_sch_id     IN PA_PLSQL_DATATYPES.NumTabTyp       DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_uom_flag                      IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab

			);
--------------------------------------------------------------------------------
-- Get rule attributes from pa_cc_tp_rules table

PROCEDURE Get_Rule_Attributes(
	p_tp_rule_id			IN	PA_PLSQL_DATATYPES.IdTabTyp,
	p_compute_flag			IN	PA_PLSQL_DATATYPES.Char1TabTyp,
	x_calc_method_code	OUT	NOCOPY  PA_PLSQL_DATATYPES.Char1TabTyp,
	x_cc_markup_base_code	IN OUT	NOCOPY  PA_PLSQL_DATATYPES.Char1TabTyp,
	x_rule_percentage	IN OUT	NOCOPY  PA_PLSQL_DATATYPES.NumTabTyp,
	x_schedule_id		OUT	NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp,
	x_error_code	     IN	OUT	NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp
					);
--------------------------------------------------------------------------------
-- Validate each transaction, set base amount, calculate Burdened Amount
-- if actual burdened amount is not given. Also, set the Basis_Compute_Flag,
-- Bill_Rate_Compute_Flag and Burden_Rate_Compute_flag appropriately
-- using calc_method_code

PROCEDURE Set_Base_Amount_And_Flag(
        p_expenditure_item_id		IN 	PA_PLSQL_DATATYPES.IdTabTyp,
        p_expenditure_type		IN 	PA_PLSQL_DATATYPES.Char30TabTyp,
	p_expenditure_item_date 	IN	PA_PLSQL_DATATYPES.DateTabTyp,
        p_expnd_organization_id		IN 	PA_PLSQL_DATATYPES.IdTabTyp,
        P_project_id			IN 	PA_PLSQL_DATATYPES.IdTabTyp,
        p_task_id			IN 	PA_PLSQL_DATATYPES.IdTabTyp,
	p_fixed_date 			IN	PA_PLSQL_DATATYPES.DateTabTyp,
	p_calc_method_code		IN	PA_PLSQL_DATATYPES.Char1TabTyp,
	p_cc_markup_base_code		IN	PA_PLSQL_DATATYPES.Char1TabTyp,
	p_denom_currency_code		IN	PA_PLSQL_DATATYPES.Char15TabTyp,
	p_projfunc_currency_code		IN	PA_PLSQL_DATATYPES.Char15TabTyp,
	p_denom_raw_cost_amount		IN	PA_PLSQL_DATATYPES.NumTabTyp,
	p_denom_burdened_cost_amount 	IN	PA_PLSQL_DATATYPES.NumTabTyp,
	p_raw_revenue_amount 		IN	PA_PLSQL_DATATYPES.NumTabTyp,
	p_revenue_distributed_flag 	IN	PA_PLSQL_DATATYPES.Char1TabTyp,
	p_compute_flag			IN 	PA_PLSQL_DATATYPES.Char1TabTyp,
	p_tp_ind_compiled_set_id IN OUT	NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp,
	x_error_code		IN  OUT	NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
	x_basis_compute_flag	    OUT NOCOPY  PA_PLSQL_DATATYPES.Char1TabTyp,
	x_bill_rate_compute_flag    OUT	NOCOPY  PA_PLSQL_DATATYPES.Char1TabTyp,
	x_burden_rate_compute_flag  OUT	NOCOPY  PA_PLSQL_DATATYPES.Char1TabTyp,
	x_tp_base_curr_code	    OUT	NOCOPY  PA_PLSQL_DATATYPES.Char15TabTyp,
	x_tp_base_amount	 IN OUT	NOCOPY  PA_PLSQL_DATATYPES.NumTabTyp,
/*Bill rate discount*/
        p_dist_rule                     IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_mcb_flag                      IN       PA_PLSQL_DATATYPES.Char1TabTyp,
        p_bill_rate_multiplier          IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_quantity                      IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_person_id                     IN       PA_PLSQL_DATATYPES.IdTabTyp,
        p_raw_cost                      IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_labor_schdl_discnt            IN       PA_PLSQL_DATATYPES.Char30TabTyp, /* bug#3221791 */
        p_labor_schdl_fixed_date        IN       PA_PLSQL_DATATYPES.DateTabTyp,
        p_bill_job_grp_id               IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_labor_sch_type                IN       PA_PLSQL_DATATYPES.Char1TabTyp,
        p_project_org_id                IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_project_type                  IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_exp_func_curr_code            IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_incurred_by_organz_id         IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_raw_cost_rate                 IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_override_to_organz_id         IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_emp_bill_rate_schedule_id     IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_job_bill_rate_schedule_id     IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_exp_raw_cost                  IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_assignment_precedes_task      IN       PA_PLSQL_DATATYPES.Char1TabTyp,
        p_sys_linkage_function          IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_assignment_id                 IN       PA_PLSQL_DATATYPES.IdTabTyp,

        p_burden_cost                   IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_task_nl_bill_rate_org_id      IN       PA_PLSQL_DATATYPES.IdTabTyp,
        p_proj_nl_bill_rate_org_id      IN       PA_PLSQL_DATATYPES.IdTabTyp,
        p_task_nl_std_bill_rate_sch     IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_proj_nl_std_bill_rate_sch     IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_non_labor_resource            IN       PA_PLSQL_DATATYPES.Char20TabTyp,
        p_nl_task_sch_date              IN       PA_PLSQL_DATATYPES.DateTabTyp,
        p_nl_proj_sch_date              IN       PA_PLSQL_DATATYPES.DateTabTyp,
        p_nl_task_sch_discount          IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_nl_proj_sch_discount          IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_nl_sch_type                   IN       PA_PLSQL_DATATYPES.Char1TabTyp,
        /* Added the two parameters for Doosan rate api enhancement */
        p_task_nl_std_bill_rate_sch_id     IN PA_PLSQL_DATATYPES.NumTabTyp       DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_proj_nl_std_bill_rate_sch_id     IN PA_PLSQL_DATATYPES.NumTabTyp       DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_uom_flag                      IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab
					);
-------------------------------------------------------------------------------
PROCEDURE Determine_Transfer_Price
	(
        p_expenditure_item_id		IN 	PA_PLSQL_DATATYPES.IdTabTyp,
        p_expnd_organization_id		IN 	PA_PLSQL_DATATYPES.IdTabTyp,
        p_expenditure_type		IN 	PA_PLSQL_DATATYPES.Char30TabTyp,
	p_expenditure_item_date 	IN	PA_PLSQL_DATATYPES.DateTabTyp,
	p_fixed_date 			IN	PA_PLSQL_DATATYPES.DateTabTyp,
	p_system_linkage_function 	IN	PA_PLSQL_DATATYPES.Char30TabTyp,
	p_task_id			IN	PA_PLSQL_DATATYPES.IdTabTyp,
	p_tp_base_curr_code		IN	PA_PLSQL_DATATYPES.Char15TabTyp,
	p_tp_base_amount		IN	PA_PLSQL_DATATYPES.NumTabTyp,
	p_tp_schedule_line_percentage	IN	PA_PLSQL_DATATYPES.NumTabTyp,
	p_tp_rule_percentage		IN	PA_PLSQL_DATATYPES.NumTabTyp,
	p_compute_flag 			IN	PA_PLSQL_DATATYPES.Char1TabTyp,
	p_quantity 			IN	PA_PLSQL_DATATYPES.NumTabTyp,
	p_incurred_by_person_id 	IN	PA_PLSQL_DATATYPES.IdTabTyp,
	p_job_id 			IN	PA_PLSQL_DATATYPES.IdTabTyp,
	p_rate_schedule_id 		IN	PA_PLSQL_DATATYPES.IdTabTyp,
	p_non_labor_resource 		IN	PA_PLSQL_DATATYPES.Char20TabTyp,
	p_basis_compute_flag		IN	PA_PLSQL_DATATYPES.Char1TabTyp,
	p_bill_rate_compute_flag	IN	PA_PLSQL_DATATYPES.Char1TabTyp,
	p_burden_rate_compute_flag	IN	PA_PLSQL_DATATYPES.Char1TabTyp,
	x_denom_tp_currency_code IN OUT NOCOPY  PA_PLSQL_DATATYPES.Char15TabTyp,
	x_denom_transfer_price	 IN OUT	NOCOPY  PA_PLSQL_DATATYPES.NumTabTyp,
	x_tp_ind_compiled_set_id IN OUT	NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp,
	x_tp_bill_rate		 IN OUT	NOCOPY  PA_PLSQL_DATATYPES.NumTabTyp,
        x_tp_bill_markup_percentage IN OUT NOCOPY  PA_PLSQL_DATATYPES.NumTabTyp,
        x_tp_job_id              IN OUT NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp,
	x_error_code		IN OUT  NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp
        );

--------------------------------------------------------------------------------
-- Get transfer price amount when calc_method_code is basis.

PROCEDURE Get_Basis_Amount(
	p_compute_flag			IN	PA_PLSQL_DATATYPES.Char1TabTyp,
	p_tp_base_curr_code		IN	PA_PLSQL_DATATYPES.Char15TabTyp,
	p_tp_base_amount		IN	PA_PLSQL_DATATYPES.NumTabTyp,
	p_array_size                    IN	Number,
	x_denom_tp_curr_code 	OUT	NOCOPY PA_PLSQL_DATATYPES.Char15TabTyp,
	x_amount		OUT	NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,
	x_error_code		IN OUT	NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp
			);
-------------------------------------------------------------------------------
-- Get transfer price amount when calc_method_code is use burden rate schedule.
-- This procedure is basically a wrapper for PA_COST_PLUS.Get_Burden_Amount
-- in order to process array.

PROCEDURE Get_Burden_Amount(
          p_array_size			IN      Number,
          p_burden_schedule_id 		IN 	PA_PLSQL_DATATYPES.IdTabTyp,
	  p_expenditure_item_date	IN	PA_PLSQL_DATATYPES.DateTabTyp,
          p_fixed_date                  IN	PA_PLSQL_DATATYPES.DateTabTyp,
          p_expenditure_type 		IN	PA_PLSQL_DATATYPES.Char30TabTyp,
          p_organization_id 		IN	PA_PLSQL_DATATYPES.IdTabTyp,
	  p_raw_amount_curr_code	IN	PA_PLSQL_DATATYPES.Char15TabTyp,
          p_raw_amount 			IN	PA_PLSQL_DATATYPES.NumTabTyp,
	  p_compute_flag		IN	PA_PLSQL_DATATYPES.Char1TabTyp,
	  x_computed_currency 	OUT     NOCOPY  PA_PLSQL_DATATYPES.Char15TabTyp,
          x_burden_amount 	OUT     NOCOPY  PA_PLSQL_DATATYPES.NumTabTyp,
          x_compiled_set_id 	IN OUT  NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp,
	  x_error_code		IN OUT	NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp
			);
---------------------------------------------------------------------------------
Procedure Get_Burdening_Details(p_project_id 	IN NUMBER,
				x_burdening_allowed OUT NOCOPY VARCHAR2, /*File.sql.39*/
				x_burden_amt_display_method OUT NOCOPY VARCHAR2 /*File.sql.39*/
				);
-------------------------------------------------------------------------------

PROCEDURE Get_business_group (
        p_org_id                IN      NUMBER,
        x_business_group_id     OUT     NOCOPY NUMBER/*File.sql.39*/
                        );
--------------------------------------------------------------------------------

/* Bug 3051110-Added for TP Enhancement, This procedure calculates the
Transfer Price Rate for the assignment id passed */

PROCEDURE Get_Initial_Transfer_Price
( p_assignment_id     IN         pa_project_assignments.assignment_id%TYPE
 ,p_start_date        IN        pa_project_assignments.start_date%TYPE
 ,p_debug_mode        IN        VARCHAR2  DEFAULT 'N'
 ,x_transfer_price_rate OUT     NOCOPY pa_project_assignments.transfer_price_rate%TYPE /*File.sql.39*/
 ,x_transfer_pr_rate_curr OUT   NOCOPY pa_project_assignments.transfer_pr_rate_curr%TYPE  /*File.sql.39*/
 ,x_return_status     OUT        NOCOPY VARCHAR2 /*File.sql.39*/
 ,x_msg_data          OUT        NOCOPY VARCHAR2 /*File.sql.39*/
 ,x_msg_count         OUT        NOCOPY Number /*File.sql.39*/
);

END PA_CC_TRANSFER_PRICE;


/
