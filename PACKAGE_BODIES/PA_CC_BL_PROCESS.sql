--------------------------------------------------------
--  DDL for Package Body PA_CC_BL_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CC_BL_PROCESS" AS
/* $Header: PAXBLPRB.pls 120.7.12010000.5 2009/06/11 19:52:46 djanaswa ship $ */

-- Specification of private procedures for this package
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE new_distribution;
PROCEDURE delete_distribution;
PROCEDURE update_distribution;
PROCEDURE reverse_distribution;
PROCEDURE update_ei(p_upd_type IN VARCHAR2);
PROCEDURE ei_mass_update;
PROCEDURE clean_tables;
PROCEDURE log_message( p_message IN VARCHAR2);
PROCEDURE set_curr_function(p_function IN VARCHAR2);
PROCEDURE reset_curr_function;

-- Record to hold attributes of current row being processed
lcur                      CcdRecType;

-- Record to hold attributes of last distribution processed earlier
MaxRec                    CcdRecType;

  g_eicnt                   PLS_INTEGER;


  g_initialization_done     BOOLEAN := FALSE;
  --g_mrc_enabled             boolean;

  G_BL_LINE_TYPE   CONSTANT   pa_cc_dist_lines_all.line_type%TYPE := 'BL';

  -- g_org_id stores the current OU.
  g_org_id pa_implementations_all.org_id%type ;

-- Declaration of individual elements to avoid ORA-3113 error because
-- FORALL does not allow insert of elements of %rowtype

  in_acct_currency_code        PA_PLSQL_DATATYPES.Char15TabTyp;
  in_acct_tp_exchange_rate     PA_PLSQL_DATATYPES.NumTabTyp;
  in_acct_tp_rate_date         PA_PLSQL_DATATYPES.Char30TabTyp;
  in_acct_tp_rate_type         PA_PLSQL_DATATYPES.Char30TabTyp;
  in_amount                    PA_PLSQL_DATATYPES.NumTabTyp;
  in_bill_markup_percentage    PA_PLSQL_DATATYPES.NumTabTyp;
  in_bill_rate                 PA_PLSQL_DATATYPES.NumTabTyp;
  in_RowId                     PA_PLSQL_DATATYPES.RowidTabTyp;
  in_cc_rejection_code         PA_PLSQL_DATATYPES.Char30TabTyp;
  in_cc_dist_line_id           PA_PLSQL_DATATYPES.IDTabTyp;
  in_cr_code_combination_id    PA_PLSQL_DATATYPES.IDTabTyp;
  in_cross_charge_code         PA_PLSQL_DATATYPES.Char1TabTyp;
  in_denom_tp_currency_code    PA_PLSQL_DATATYPES.Char15TabTyp;
  in_denom_transfer_price      PA_PLSQL_DATATYPES.NumTabTyp;
  in_dist_line_id_reversed     PA_PLSQL_DATATYPES.IDTabTyp;
  in_dr_code_combination_id    PA_PLSQL_DATATYPES.IDTabTyp;
  in_expenditure_item_id       PA_PLSQL_DATATYPES.IDTabTyp;
  in_expenditure_item_date     PA_PLSQL_DATATYPES.DateTabTyp;
  in_ind_compiled_set_id       PA_PLSQL_DATATYPES.IDTabTyp;
  in_line_num                  PA_PLSQL_DATATYPES.IDTabTyp;
  in_line_num_reversed         PA_PLSQL_DATATYPES.NumTabTyp;
  in_line_type                 PA_PLSQL_DATATYPES.Char2TabTyp;
  in_markup_calc_base_code     PA_PLSQL_DATATYPES.Char1TabTyp;
  in_org_id                    PA_PLSQL_DATATYPES.IDTabTyp;
  in_pa_date                   PA_PLSQL_DATATYPES.Char30TabTyp;
  in_gl_date                   PA_PLSQL_DATATYPES.Char30TabTyp;         /* EPP */
  in_pa_period_name            PA_PLSQL_DATATYPES.Char30TabTyp;         /* EPP */
  in_gl_period_name            PA_PLSQL_DATATYPES.Char30TabTyp;         /* EPP */
  in_project_id                PA_PLSQL_DATATYPES.IDTabTyp;
  in_prvdr_org_id              PA_PLSQL_DATATYPES.IDTabTyp;
  in_reference_1               PA_PLSQL_DATATYPES.NumTabTyp;
  in_reference_2               PA_PLSQL_DATATYPES.Char240TabTyp;
  in_reference_3               PA_PLSQL_DATATYPES.NumTabTyp;
  in_reversed_flag             PA_PLSQL_DATATYPES.Char1TabTyp;
  in_rule_percentage           PA_PLSQL_DATATYPES.NumTabTyp;
  in_schedule_line_percentage  PA_PLSQL_DATATYPES.NumTabTyp;
  in_task_id                   PA_PLSQL_DATATYPES.IDTabTyp;
  in_tp_base_amount            PA_PLSQL_DATATYPES.NumTabTyp;
  in_tp_job_id                 PA_PLSQL_DATATYPES.NumTabTyp;
  in_upd_type                  PA_PLSQL_DATATYPES.Char1TabTyp;

/*Added for cross proj*/
  in_tp_amt_type_code          PA_PLSQL_DATATYPES.Char30TabTyp;
  in_project_tp_rate_type         PA_PLSQL_DATATYPES.Char30TabTyp;
  in_project_tp_rate_date         PA_PLSQL_DATATYPES.Char30TabTyp;
  in_project_tp_exchange_rate PA_PLSQL_DATATYPES.Char30TabTyp;
  in_project_transfer_price   PA_PLSQL_DATATYPES.Char30TabTyp;
  in_projfunc_tp_rate_type     PA_PLSQL_DATATYPES.Char30TabTyp;
  in_projfunc_tp_rate_date     PA_PLSQL_DATATYPES.Char30TabTyp;
  in_projfunc_tp_exchange_rate PA_PLSQL_DATATYPES.Char30TabTyp;
  in_projfunc_transfer_price   PA_PLSQL_DATATYPES.Char30TabTyp;

  in_project_tp_currency_code  PA_PLSQL_DATATYPES.Char15TabTyp;
  in_projfunc_tp_currency_code PA_PLSQL_DATATYPES.Char15TabTyp;
/*End for cross proj*/

-- Keeps track of the current line number for the distribution

  l_new_line_num  PLS_INTEGER;

  lb_attributes_same             boolean;
  lb_attributes_diff             boolean;
  lb_regular_ei                  boolean;
  lb_adjusting_ei                boolean;
  lb_borrlent                    boolean;
  lb_non_borrlent                boolean;
  lb_net_zero                    boolean;
  lb_non_net_zero                boolean;
  lb_have_last_line              boolean;
  lb_no_last_line                boolean;
  lb_xfaced_last_line            boolean;
  lb_non_xfaced_last_line        boolean;
  lb_regular_last_line           boolean;
  lb_irregular_last_line         boolean;
  lb_ei_denom_tp_null            boolean;
  lb_not_ei_denom_tp_null        boolean;
  lb_reverse_future_period       boolean;    -- Bug 8538911
-------------------------------------------------------------------------------
--              pa_bl_pr
-------------------------------------------------------------------------------

PROCEDURE pa_bl_pr
	(
         p_module_name			IN  VARCHAR2
        ,p_debug_mode                   IN  VARCHAR2
        ,p_acct_currency_code           IN  OUT NOCOPY pa_expenditure_items_all.acct_currency_code%TYPE
        ,p_acct_tp_exchange_rate	IN  OUT NOCOPY PA_PLSQL_DATATYPES.char30tabtyp
        ,p_acct_tp_rate_date		IN  OUT NOCOPY PA_PLSQL_DATATYPES.char30tabtyp
        ,p_acct_tp_rate_type		IN  OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp
        ,p_acct_transfer_price		IN  OUT NOCOPY PA_PLSQL_DATATYPES.char30tabtyp
        ,p_adjusted_exp_item_id         IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_array_size			IN  Number
        ,p_cc_markup_base_code	        IN  OUT NOCOPY PA_PLSQL_DATATYPES.Char1TabTyp
        ,p_cc_rejection_code		IN  OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp
        ,p_compute_flag 		IN  PA_PLSQL_DATATYPES.Char1TabTyp
        ,p_cr_code_combination_id       IN  OUT NOCOPY PA_PLSQL_DATATYPES.IDTabTyp
        ,p_cross_charge_code            IN  PA_PLSQL_DATATYPES.Char1TabTyp
        ,p_denom_burdened_cost_amount 	IN  PA_PLSQL_DATATYPES.char30tabtyp
        ,p_denom_currency_code		IN  PA_PLSQL_DATATYPES.Char15TabTyp
        ,p_denom_raw_cost_amount	IN  PA_PLSQL_DATATYPES.char30tabtyp
        ,p_denom_tp_currency_code	IN  OUT NOCOPY PA_PLSQL_DATATYPES.Char15TabTyp
        ,p_denom_transfer_price		IN  OUT NOCOPY PA_PLSQL_DATATYPES.char30tabtyp
        ,p_dr_code_combination_id       IN  OUT NOCOPY PA_PLSQL_DATATYPES.IDTabTyp
        ,p_exp_item_rowid               IN  PA_PLSQL_DATATYPES.char30tabtyp
        ,p_expenditure_category 	IN  PA_PLSQL_DATATYPES.char30tabtyp
        ,p_expenditure_item_date 	IN  PA_PLSQL_DATATYPES.char30tabtyp
        ,p_expenditure_item_id		IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_expenditure_type	        IN  PA_PLSQL_DATATYPES.Char30TabTyp
        ,p_expnd_organization_id	IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_incurred_by_person_id 	IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_job_id 			IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_labor_non_labor_flag		IN  PA_PLSQL_DATATYPES.Char1TabTyp
        ,p_login_id                     IN  NUMBER
        ,p_net_zero_flag       		IN  PA_PLSQL_DATATYPES.Char1TabTyp
        ,p_nl_resource_organization_id	IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_non_labor_resource 		IN  PA_PLSQL_DATATYPES.Char20TabTyp
        ,p_pa_date                      IN  PA_PLSQL_DATATYPES.char30tabtyp
        ,p_gl_date                      IN  PA_PLSQL_DATATYPES.char30tabtyp
        ,p_pa_period_name               IN  PA_PLSQL_DATATYPES.char30tabtyp
        ,p_gl_period_name               IN  PA_PLSQL_DATATYPES.char30tabtyp
        ,p_primary_sob_id               IN  gl_sets_of_books.set_of_books_id%TYPE
        ,p_processed_thru_date 		IN  Date
        ,p_program_application_id       IN  NUMBER
        ,p_program_id                   IN  NUMBER
        ,p_project_currency_code	IN  PA_PLSQL_DATATYPES.Char15TabTyp
        ,p_project_id 			IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_prvdr_org_id         	IN  pa_implementations_all.org_id%TYPE
        ,p_prvdr_organization_id	IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_quantity 			IN  PA_PLSQL_DATATYPES.char30tabtyp
        ,p_raw_revenue_amount 		IN  PA_PLSQL_DATATYPES.char30tabtyp
        ,p_recvr_org_id			IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_recvr_organization_id	IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_request_id                   IN  NUMBER
        ,p_revenue_distributed_flag 	IN  PA_PLSQL_DATATYPES.Char1TabTyp
        ,p_system_linkage_function 	IN  PA_PLSQL_DATATYPES.Char30TabTyp
        ,p_task_id			IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_tp_base_amount		IN  OUT NOCOPY PA_PLSQL_DATATYPES.char30tabtyp
        ,p_tp_bill_markup_percentage	IN  OUT NOCOPY PA_PLSQL_DATATYPES.char30tabtyp
        ,p_tp_bill_rate			IN  OUT NOCOPY PA_PLSQL_DATATYPES.char30tabtyp
        ,p_tp_fixed_date		IN  PA_PLSQL_DATATYPES.char30tabtyp
        ,p_tp_ind_compiled_set_id       IN  OUT NOCOPY PA_PLSQL_DATATYPES.IDTabTyp
        ,p_tp_job_id                    IN  OUT NOCOPY PA_PLSQL_DATATYPES.IDTabTyp
        ,p_tp_rule_percentage		IN  OUT NOCOPY PA_PLSQL_DATATYPES.char30tabtyp
        ,p_tp_schedule_id		IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_tp_schedule_line_percentage	IN  OUT NOCOPY PA_PLSQL_DATATYPES.char30tabtyp
        ,p_user_id                      IN  NUMBER
/*Added for cross proj*/
        ,p_tp_amt_type_code            IN  PA_PLSQL_DATATYPES.Char30TabTyp
        ,p_assignment_id               IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_projfunc_currency_code      IN  PA_PLSQL_DATATYPES.Char15TabTyp
        ,p_project_tp_rate_type           IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp
        ,p_project_tp_rate_date           IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp
        ,p_project_tp_exchange_rate       IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp
        ,p_projfunc_tp_rate_type       IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp
        ,p_projfunc_tp_rate_date       IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp
        ,p_projfunc_tp_exchange_rate   IN OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
/*End for cross proj*/
/* Bill rate Discount*/
        p_dist_rule                     IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_mcb_flag                      IN       PA_PLSQL_DATATYPES.Char1TabTyp,
        p_bill_rate_multiplier          IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_raw_cost                      IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_labor_schdl_discnt            IN       PA_PLSQL_DATATYPES.Char30TabTyp, /* bug#3221791 */
        p_labor_schdl_fixed_date        IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_bill_job_grp_id               IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_labor_sch_type                IN       PA_PLSQL_DATATYPES.Char1TabTyp,
        p_project_org_id                IN       PA_PLSQL_DATATYPES.NumTabTyp ,
        p_project_type                  IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_exp_func_curr_code            IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_incurred_by_organz_id         IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_raw_cost_rate                 IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_override_to_organz_id         IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_emp_bill_rate_schedule_id     IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_job_bill_rate_schedule_id     IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_exp_raw_cost                  IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_assignment_precedes_task      IN       PA_PLSQL_DATATYPES.Char1TabTyp,

        p_burden_cost                   IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_task_nl_bill_rate_org_id      IN       PA_PLSQL_DATATYPES.IdTabTyp,
        p_proj_nl_bill_rate_org_id      IN       PA_PLSQL_DATATYPES.IdTabTyp,
        p_task_nl_std_bill_rate_sch     IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_proj_nl_std_bill_rate_sch     IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_nl_sch_type                   IN       PA_PLSQL_DATATYPES.Char1TabTyp,
        p_nl_task_sch_date              IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_nl_proj_sch_date              IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_nl_task_sch_discount          IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_nl_proj_sch_discount          IN       PA_PLSQL_DATATYPES.NumTabTyp,
/* Added the last two parameters for Doosan Rate api changes */
        p_task_nl_std_bill_rate_sch_id     IN PA_PLSQL_DATATYPES.NumTabTyp       DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_proj_nl_std_bill_rate_sch_id     IN PA_PLSQL_DATATYPES.NumTabTyp       DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
/* Added for UOM enhancement */
        p_uom_flag                      IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab

        ) IS

i                       PLS_INTEGER;
x_return_status         NUMBER;
l_reversal_reqd         BOOLEAN;
l_prev_rec_exist        BOOLEAN;
l_parent_dist_code      VARCHAR2(2);

l_source_eid            pa_expenditure_items_all.expenditure_item_id%TYPE;
l_transfer_status_code  pa_cc_dist_lines_all.transfer_status_code%TYPE;

/*Added for cross proj*/
p_project_transfer_price            PA_PLSQL_DATATYPES.Char30TabTyp;
p_projfunc_transfer_price        PA_PLSQL_DATATYPES.Char30TabTyp;
/*End for cross proj*/

l_exists                NUMBER;  -- Bug 8538911

BEGIN


-- Set Debugging info
   IF p_debug_mode = 'Y'
   THEN
          pa_cc_utils.g_debug_mode := TRUE;
   ELSE
          pa_cc_utils.g_debug_mode := FALSE;
   END IF;


   set_curr_function('pa_bl_pr');

   pa_debug.set_process( x_process => 'PLSQL',
			 x_debug_mode => p_debug_mode);
			 pa_debug.G_Err_Stage := 'Starting pa_bl_pr' ;



IF P_DEBUG_MODE = 'Y' THEN
   log_message('reverse_distribution: ' || '50: Entered pa_bl_pr');
END IF;

-- Perform initalization if it is not already done
IF g_initialization_done
THEN
  null;
ELSE
-- Perform initialization like determining reporting sob, etc.
    initialization (
                p_request_id              => p_request_id
               ,p_program_application_id  => p_program_application_id
               ,p_program_id              => p_program_id
               ,p_user_id                 => p_user_id
               ,p_login_id                => p_login_id
               ,p_prvdr_org_id            => p_prvdr_org_id
               ,p_primary_sob_id          => p_primary_sob_id
		   );

END IF;


-- Initialize record counters
g_ucnt := 0;
g_icnt := 0;
g_dcnt := 0;
g_eicnt:= 0;

   IF P_DEBUG_MODE = 'Y' THEN
      log_message('reverse_distribution: ' || '100: Selected org id');
   END IF;

-----------------------------------------------------------------
--   Compute Transfer Price for all eligible items
-----------------------------------------------------------------

-- Call the Transfer Price API to get determine the Transfer Price and
-- its attributes

IF P_DEBUG_MODE = 'Y' THEN
   log_message('reverse_distribution: ' || '150: Calling transfer price API');
END IF;


pa_cc_transfer_price.get_transfer_price
  (
    p_module_name                  => p_module_name
    ,p_prvdr_organization_id       => p_prvdr_organization_id
    ,p_recvr_org_id                => p_recvr_org_id
    ,p_recvr_organization_id       => p_recvr_organization_id
    ,p_expnd_organization_id       => p_expnd_organization_id
    ,p_expenditure_item_id         => p_expenditure_item_id
    ,p_expenditure_type            => p_expenditure_type
    ,p_expenditure_category        => p_expenditure_category
    ,p_expenditure_item_date       => p_expenditure_item_date
    ,p_labor_non_labor_flag        => p_labor_non_labor_flag
    ,p_system_linkage_function     => p_system_linkage_function
    ,p_task_id                     => p_task_id
    ,p_tp_schedule_id              => p_tp_schedule_id
    ,p_denom_currency_code         => p_denom_currency_code
    ,p_project_currency_code       => p_project_currency_code
    ,p_revenue_distributed_flag    => p_revenue_distributed_flag
    ,p_processed_thru_date         => p_processed_thru_date
    ,p_compute_flag                => p_compute_flag
    ,p_tp_fixed_date               => p_tp_fixed_date
    ,p_denom_raw_cost_amount       => p_denom_raw_cost_amount
    ,p_denom_burdened_cost_amount  => p_denom_burdened_cost_amount
    ,p_raw_revenue_amount          => p_raw_revenue_amount
    ,p_project_id                  => p_project_id
    ,p_quantity                    => p_quantity
    ,p_incurred_by_person_id       => p_incurred_by_person_id
    ,p_job_id                      => p_job_id
    ,p_non_labor_resource          => p_non_labor_resource
    ,p_nl_resource_organization_id => p_nl_resource_organization_id
    ,p_pa_date                     => p_pa_date
    ,p_array_size                  => p_array_size
    ,p_debug_mode                  => p_debug_mode
    ,x_denom_tp_currency_code      => p_denom_tp_currency_code
    ,x_denom_transfer_price        => p_denom_transfer_price
    ,x_acct_tp_rate_type           => p_acct_tp_rate_type
    ,x_acct_tp_rate_date           => p_acct_tp_rate_date
    ,x_acct_tp_exchange_rate       => p_acct_tp_exchange_rate
    ,x_acct_transfer_price         => p_acct_transfer_price
    ,x_cc_markup_base_code         => p_cc_markup_base_code
    ,x_tp_ind_compiled_set_id      => p_tp_ind_compiled_set_id
    ,x_tp_bill_rate                => p_tp_bill_rate
    ,x_tp_base_amount              => p_tp_base_amount
    ,x_tp_bill_markup_percentage   => p_tp_bill_markup_percentage
    ,x_tp_job_id                   => p_tp_job_id
    ,x_tp_schedule_line_percentage => p_tp_schedule_line_percentage
    ,x_tp_rule_percentage          => p_tp_rule_percentage
    ,x_error_code                  => p_cc_rejection_code
    ,x_return_status               => x_return_status
  /* Added for cross proj*/
    ,p_projfunc_currency_code      => p_projfunc_currency_code
    ,p_tp_amt_type_code            => p_tp_amt_type_code
    ,p_assignment_id               => p_assignment_id
    ,x_proj_tp_rate_type           => p_project_tp_rate_type
    ,x_proj_tp_rate_date           => p_project_tp_rate_date
    ,x_proj_tp_exchange_rate       => p_project_tp_exchange_rate
    ,x_proj_transfer_price         => p_project_transfer_price
    ,x_projfunc_tp_rate_type       => p_projfunc_tp_rate_type
    ,x_projfunc_tp_rate_date       => p_projfunc_tp_rate_date
    ,x_projfunc_tp_exchange_rate   => p_projfunc_tp_exchange_rate
    ,x_projfunc_transfer_price     => p_projfunc_transfer_price,
  /* End for cross proj*/
/*Bill rate discount */
        p_dist_rule                     => p_dist_rule,
        p_mcb_flag                      => p_mcb_flag,
        p_bill_rate_multiplier          => p_bill_rate_multiplier,
        p_raw_cost                      => p_raw_cost,
        p_labor_schdl_discnt            => p_labor_schdl_discnt,
        p_labor_schdl_fixed_date        => p_labor_schdl_fixed_date,
        p_bill_job_grp_id               => p_bill_job_grp_id,
        p_labor_sch_type                => p_labor_sch_type,
        p_project_org_id                => p_project_org_id,
        p_project_type                  => p_project_type,
        p_exp_func_curr_code            => p_exp_func_curr_code,
        p_incurred_by_organz_id         => p_incurred_by_organz_id,
        p_raw_cost_rate                 => p_raw_cost_rate,
        p_override_to_organz_id         => p_override_to_organz_id,
        p_emp_bill_rate_schedule_id     => p_emp_bill_rate_schedule_id,
        p_job_bill_rate_schedule_id     => p_job_bill_rate_schedule_id,
        p_exp_raw_cost                  => p_exp_raw_cost,
        p_assignment_precedes_task      => p_assignment_precedes_task,

        p_burden_cost                   => p_burden_cost,
        p_task_nl_bill_rate_org_id      => p_task_nl_bill_rate_org_id,
        p_proj_nl_bill_rate_org_id      => p_proj_nl_bill_rate_org_id,
        p_task_nl_std_bill_rate_sch     => p_task_nl_std_bill_rate_sch,
        p_proj_nl_std_bill_rate_sch     => p_proj_nl_std_bill_rate_sch,
        p_nl_task_sch_date              => p_nl_task_sch_date,
        p_nl_proj_sch_date              => p_nl_proj_sch_date,
        p_nl_task_sch_discount          => p_nl_task_sch_discount,
        p_nl_proj_sch_discount          => p_nl_proj_sch_discount,
        p_nl_sch_type                   => p_nl_sch_type,
        p_task_nl_std_bill_rate_sch_id  => p_task_nl_std_bill_rate_sch_id,
        p_proj_nl_std_bill_rate_sch_id  => p_proj_nl_std_bill_rate_sch_id,
        p_uom_flag                      => p_uom_flag
);

IF P_DEBUG_MODE = 'Y' THEN
   log_message('reverse_distribution: ' || '200: Finished transfer price API');
END IF;


-----------------------------------------------------------
--                 Start checking individual EIs
-----------------------------------------------------------

IF P_DEBUG_MODE = 'Y' THEN
   log_message('reverse_distribution: ' || '250: Checking elements');
END IF;

FOR i in 1 .. p_array_size
LOOP

 IF P_DEBUG_MODE = 'Y' THEN
    log_message('reverse_distribution: ' || '300: Processing EI Id: ' || to_char(p_expenditure_item_id(i)));
 END IF;

 /* remove this later */
 IF P_DEBUG_MODE = 'Y' THEN
    log_message('reverse_distribution: ' || '300: pa_date [' || p_pa_date(i) ||
              '] p_gl_date [' || p_gl_date(i) ||
       '] p_pa_period_name [' || p_pa_period_name(i) ||
       '] p_gl_period_name [' || p_gl_period_name(i) || ']');
 END IF;

 /* remove this later */

-- If there are no rejections on the line, only then it needs to be
-- processed. If there are rejections, just update the EI with the
-- appropriate status code and move on to the next item

 lcur.cc_rejection_code        := p_cc_rejection_code(i);
 lcur.EIRowId                  := chartorowid(p_exp_item_rowid(i));

 IF lcur.cc_rejection_code IS NOT NULL
 THEN
-- If there is a rejection recorded already, then no processing needs
-- to be done other than recording the fact that the EI needs to be
-- updated with a rejection code

    IF P_DEBUG_MODE = 'Y' THEN
          log_message('reverse_distribution: ' || '350: Rejection in EI : ' || lcur.cc_rejection_code);
    END IF;
    update_ei('R');
    IF P_DEBUG_MODE = 'Y' THEN
           log_message('reverse_distribution: ' || '400: Back from call to update_ei');
    END IF;

 ELSE
     IF P_DEBUG_MODE = 'Y' THEN
             log_message('reverse_distribution: ' || '450: No rejection in EI...processing');
        log_message('reverse_distribution: ' || '500: Transfer price amount = ' || p_acct_transfer_price(i));
     END IF;
-- Set flags to record status of record retrieved

-- Copy all attributes of the current record of the table to globally
-- accessible single record
   lcur.acct_currency_code       := p_acct_currency_code;
   lcur.acct_tp_exchange_rate    := p_acct_tp_exchange_rate(i);
   lcur.acct_tp_rate_date        := to_date(p_acct_tp_rate_date(i),'YYYY/MM/DD');
   lcur.acct_tp_rate_type        := p_acct_tp_rate_type(i);
   lcur.amount                   := p_acct_transfer_price(i);
   lcur.adjusted_exp_item_id     := p_adjusted_exp_item_id(i);
   lcur.bill_markup_percentage   := p_tp_bill_markup_percentage(i);
   lcur.bill_rate                := p_tp_bill_rate(i);
   lcur.CcdRowId                 := null;
   lcur.cr_code_combination_id   := p_cr_code_combination_id(i);
   lcur.cross_charge_code        := p_cross_charge_code(i);
   lcur.denom_tp_currency_code   := p_denom_tp_currency_code(i);/*Added for bug 2150468 */
   lcur.denom_transfer_price     := p_denom_transfer_price(i);
   lcur.dist_line_id_reversed    := null;
   lcur.dr_code_combination_id   := p_dr_code_combination_id(i);
   lcur.expenditure_item_id      := p_expenditure_item_id(i);
   lcur.expenditure_item_date    := to_date(p_expenditure_item_date(i),'YYYY/MM/DD');
   lcur.ind_compiled_set_id      := p_tp_ind_compiled_set_id(i);
   lcur.line_num                 := null;
   lcur.line_num_reversed        := null;
   lcur.markup_calc_base_code    := p_cc_markup_base_code(i);
   lcur.pa_date                  := to_date(p_pa_date(i),'YYYY/MM/DD');
   lcur.gl_date                  := to_date(p_gl_date(i),'YYYY/MM/DD');                    /* EPP */
   lcur.pa_period_name           := p_pa_period_name(i);             /* EPP */
   lcur.gl_period_name           := p_gl_period_name(i);             /* EPP */
   lcur.project_id               := p_project_id(i);
   lcur.reversed_flag            := null;
   lcur.rule_percentage          := p_tp_rule_percentage(i);
   lcur.schedule_line_percentage := p_tp_schedule_line_percentage(i);
   lcur.task_id                  := p_task_id(i);
   lcur.tp_base_amount           := p_tp_base_amount(i);
   lcur.tp_job_id                := p_tp_job_id(i);

/*Added for cross proj*/
   lcur.tp_amt_type_code         := p_tp_amt_type_code(i);
   lcur.project_tp_rate_type     := p_project_tp_rate_type(i);
   lcur.project_tp_rate_date     := to_date(p_project_tp_rate_date(i),'YYYY/MM/DD');
   lcur.project_tp_exchange_rate := p_project_tp_exchange_rate(i);
   lcur.project_transfer_price   := p_project_transfer_price(i);
   lcur.projfunc_tp_rate_type    := p_projfunc_tp_rate_type(i);
   lcur.projfunc_tp_rate_date    := to_date(p_projfunc_tp_rate_date(i),'YYYY/MM/DD');
   lcur.projfunc_tp_exchange_rate:= p_projfunc_tp_exchange_rate(i);
   lcur.projfunc_transfer_price  := p_projfunc_transfer_price(i);

   lcur.project_tp_currency_code := p_project_currency_code(i);
   lcur.projfunc_tp_currency_code:= p_projfunc_currency_code(i);
/*End for cross proj*/

-- Determine if adjusting EI or original EI. Also determine which EI
-- is the source for further distributions. For regular EIs, this is
-- the same EI while for adjusting EIs, it is the EI that is being
-- adjusted

     IF lcur.adjusted_exp_item_id IS NULL
     THEN
       IF P_DEBUG_MODE = 'Y' THEN
          log_message('reverse_distribution: ' || '550: Detected regular EI');
       END IF;
       lb_regular_ei   := TRUE;
       lb_adjusting_ei := FALSE;
       l_source_eid    := lcur.expenditure_item_id;
     ELSE
       IF P_DEBUG_MODE = 'Y' THEN
          log_message('reverse_distribution: ' || '600: Detected reversing EI');
       END IF;
       lb_regular_ei   := FALSE;
       lb_adjusting_ei := TRUE;
       l_source_eid    := lcur.adjusted_exp_item_id;
     END IF;

    -- Determine if net zero or not. Net zero will always be true for
    -- adjusting EI but set it here anyway

 /* Bug 8538911 . Modified the below code section to distinguish the reverse future period EIs from other adjusting EIs*/
lb_reverse_future_period := FALSE;
l_exists := 0;

     IF p_net_zero_flag(i) = 'Y'
     THEN
           if lb_regular_ei then
         begin
                        select 1 into l_exists
                        from dual
                        where exists
                                ( select 'Reverse in future period net-zero pair'
                                        from pa_expenditure_items_all ei,
                                                 pa_cost_distribution_lines_all cdl,
                                                 pa_cost_distribution_lines_all reversal_cdl
                                        where ei.adjusted_expenditure_item_id = lcur.expenditure_item_id
                                          and ei.expenditure_item_id = reversal_cdl.expenditure_item_id
                                          and cdl.expenditure_item_id = lcur.expenditure_item_id
                                          and cdl.pa_period_name <> reversal_cdl.pa_period_name
                                );
                IF P_DEBUG_MODE = 'Y' THEN
                        log_message('reverse_distribution: ' || '620: Reverse in Future period net-zero pair, original EI');
                END IF;
                exception
                        when others then
                                l_exists := 0;
                end;
           else  -- lb_regular_ei
                 begin
                        select 1 into l_exists
                        from dual
                        where exists
                                ( select 'Reverse in future period net-zero pair'
                                        from pa_expenditure_items_all parent_ei,
                                             pa_cost_distribution_lines_all cdl,
                                                 pa_cost_distribution_lines_all parent_cdl
                                        where parent_ei.expenditure_item_id = lcur.adjusted_exp_item_id
                                          and parent_ei.expenditure_item_id = parent_cdl.expenditure_item_id
                                          and cdl.expenditure_item_id = lcur.expenditure_item_id
                                          and parent_cdl.pa_period_name <> cdl.pa_period_name
                                );
                IF l_exists = 1 THEN
                        lb_reverse_future_period := TRUE;
                        lb_regular_ei := TRUE;
                        lb_adjusting_ei := FALSE;
                END IF;
                IF P_DEBUG_MODE = 'Y' THEN
                log_message('reverse_distribution: ' || '630: Reverse in Future period net-zero pair, reversal EI');
                END IF;
                exception
                when others then
                        l_exists := 0;
                end;
       end if; -- lb_regular_ei
     END IF; --p_net_zero_flag (shweta)

     IF l_exists = 0 and p_net_zero_flag(i) = 'Y' THEN
     -- IF p_net_zero_flag(i) = 'Y'
       IF P_DEBUG_MODE = 'Y' THEN
          log_message('reverse_distribution: ' || '650: Detected net zero EI');
       END IF;
       lb_net_zero     := TRUE;
       lb_non_net_zero := FALSE;
     ELSE
       IF P_DEBUG_MODE = 'Y' THEN
          log_message('reverse_distribution: ' || '700: Detected non-net-zero EI');
       END IF;
       lb_net_zero     := FALSE;
       lb_non_net_zero := TRUE;
     END IF;
   /* Bug 8538911 changes end */

    -- Determine the cross charge code of the EI

     IF lcur.cross_charge_code = 'B'
     THEN
       IF P_DEBUG_MODE = 'Y' THEN
          log_message('reverse_distribution: ' || '750: Borrowed and Lent EI');
       END IF;
       lb_borrlent     := TRUE;
       lb_non_borrlent := FALSE;
     ELSE
       IF P_DEBUG_MODE = 'Y' THEN
          log_message('reverse_distribution: ' || '800: Non-borrowed and lent EI');
       END IF;
       lb_borrlent     := FALSE;
       lb_non_borrlent := TRUE;
     END IF;

-- Reset line attributes before looking for the last distribution

 lb_have_last_line       := FALSE;
 lb_no_last_line         := TRUE;
 lb_regular_last_line    := FALSE ;
 lb_irregular_last_line  := FALSE;
 lb_xfaced_last_line     := FALSE;
 lb_non_xfaced_last_line := FALSE;
 l_new_line_num          := 0;  -- Keep at zero; increment before insert

-- Select the attributes of the last line
-- For adjusting EIs, the last line is picked up from the adjusted EI

  BEGIN

   l_new_line_num := 0;
   IF P_DEBUG_MODE = 'Y' THEN
      log_message('reverse_distribution: ' || '850: Examine last line');
   END IF;

   SELECT rowid,
          cc_dist_line_id,
          acct_currency_code,
          acct_tp_exchange_rate,
          acct_tp_rate_date,
          acct_tp_rate_type,
          amount,
          bill_markup_percentage,
          bill_rate,
          cr_code_combination_id,
          cross_charge_code,
          denom_tp_currency_code,
          denom_transfer_price,
          dist_line_id_reversed,
          dr_code_combination_id,
          expenditure_item_id,
          ind_compiled_set_id,
          line_num,
          line_num_reversed,
          markup_calc_base_code,
          project_id,
          reversed_flag,
          rule_percentage,
          schedule_line_percentage,
          task_id,
          tp_base_amount,
          tp_job_id,
 	  transfer_status_code,
         /* Added for cross proj*/
          tp_amt_type_code,
          project_tp_rate_type,
	  project_tp_rate_date,
          project_tp_exchange_rate,
          project_transfer_price,
          projfunc_tp_rate_type,
          projfunc_tp_rate_date,
          projfunc_tp_exchange_rate,
          projfunc_transfer_price,

	  project_tp_currency_code,
	  projfunc_tp_currency_code
         /*End for cross proj*/
     INTO
 	  maxrec.CcdRowid,
	  maxrec.cc_dist_line_id,
          maxrec.acct_currency_code,
          maxrec.acct_tp_exchange_rate,
          maxrec.acct_tp_rate_date,
          maxrec.acct_tp_rate_type,
          maxrec.amount,
          maxrec.bill_markup_percentage,
          maxrec.bill_rate,
          maxrec.cr_code_combination_id,
          maxrec.cross_charge_code,
          maxrec.denom_tp_currency_code,
          maxrec.denom_transfer_price,
          maxrec.dist_line_id_reversed,
          maxrec.dr_code_combination_id,
          maxrec.expenditure_item_id,
          maxrec.ind_compiled_set_id,
          maxrec.line_num,
          maxrec.line_num_reversed,
          maxrec.markup_calc_base_code,
          maxrec.project_id,
          maxrec.reversed_flag,
          maxrec.rule_percentage,
          maxrec.schedule_line_percentage,
          maxrec.task_id,
          maxrec.tp_base_amount,
          maxrec.tp_job_id,
 	  l_transfer_status_code,
        /*Added for cross proj*/
          maxrec.tp_amt_type_code,
          maxrec.project_tp_rate_type,
          maxrec.project_tp_rate_date,
          maxrec.project_tp_exchange_rate,
          maxrec.project_transfer_price,
          maxrec.projfunc_tp_rate_type,
          maxrec.projfunc_tp_rate_date,
          maxrec.projfunc_tp_exchange_rate,
          maxrec.projfunc_transfer_price,

	  maxrec.project_tp_currency_code,
	  maxrec.projfunc_tp_currency_code
        /*end for cross proj*/
     FROM pa_cc_dist_lines
    WHERE expenditure_item_id = l_source_eid
      AND line_type = G_BL_LINE_TYPE
      AND line_num = (SELECT max(line_num)
 		       FROM pa_cc_dist_lines
 		      WHERE expenditure_item_id = l_source_eid
 			AND line_type = G_BL_LINE_TYPE);

   IF P_DEBUG_MODE = 'Y' THEN
      log_message('reverse_distribution: ' || '900: Found last line');
   END IF;

   lb_have_last_line       := TRUE;
   lb_no_last_line         := FALSE;


 -- Determine whether the last distribution is a reversing distribution
 -- or a regular one

   IF MaxRec.dist_line_id_reversed IS NULL

   THEN
      IF P_DEBUG_MODE = 'Y' THEN
         log_message('reverse_distribution: ' || '950: Regular line');
      END IF;
      lb_regular_last_line   := TRUE;
      lb_irregular_last_line := FALSE;
   ELSE
      IF P_DEBUG_MODE = 'Y' THEN
         log_message('reverse_distribution: ' || '1000: Reversing line');
      END IF;
      lb_regular_last_line   := FALSE;
      lb_irregular_last_line := TRUE;
   END IF;

 -- Determine whether the last distribution has been interfaced to GL

   IF l_transfer_status_code = 'A'

   THEN
      IF P_DEBUG_MODE = 'Y' THEN
         log_message('reverse_distribution: ' || '1050: Interfaced line');
      END IF;
      lb_xfaced_last_line       := TRUE;
      lb_non_xfaced_last_line   := FALSE;
   ELSE
      IF P_DEBUG_MODE = 'Y' THEN
         log_message('reverse_distribution: ' || '1100: Non Interfaced line');
      END IF;
      lb_xfaced_last_line       := FALSE;
      lb_non_xfaced_last_line   := TRUE;
   END IF;

 -- For a regular EI, the new distribution has a line number greater
 -- than the last distribution of the same type. For an adjusting EI,
 -- the distribution line number is always 1 (since an adjusting EI
 -- cannot be adjusted further and will always have only a single line)
 -- Need not check for a regular EI as there will be a max distribution
 -- only for a regular EI
 -- Keep at max; increment before insert

   /* Bug 5263823 */
   IF lcur.adjusted_exp_item_id IS NULL THEN
	   l_new_line_num   := MaxRec.line_num;
   ELSE
	   l_new_line_num   := 0;
   END if;


  EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
       IF P_DEBUG_MODE = 'Y' THEN
          log_message('reverse_distribution: ' || '1150: No last line found');
       END IF;
       l_new_line_num          := 0;  -- True for adjusting EIs also
       lb_have_last_line := FALSE;
       lb_no_last_line   := TRUE;

   WHEN OTHERS
   THEN
       IF P_DEBUG_MODE = 'Y' THEN
          log_message('reverse_distribution: ' || '1200: Exception in getting last line');
       END IF;
	 raise;
  END;


   IF P_DEBUG_MODE = 'Y' THEN
      log_message('reverse_distribution: ' || '1250: Comparing attributes');
   END IF;
   lb_attributes_same := FALSE;

-- If a reversal line is available, check if reversal is required by
-- comparing all attributes
-- If it is not a Borrowed and Lent transaction, then the attributes
-- are different by default as Transfer Price need not be calculated

 IF lb_have_last_line and lb_borrlent
   AND
    (
	((MaxRec.schedule_line_percentage IS NULL
	      AND lcur.schedule_line_percentage IS NULL ) OR
	      (MaxRec.schedule_line_percentage IS NULL ))/*Cross proj*/
	AND  ((MaxRec.bill_rate IS NULL AND lcur.bill_rate IS NULL ) OR
	      (MaxRec.bill_rate  = lcur.bill_rate ))
	AND  ((MaxRec.bill_markup_percentage IS NULL
	      AND lcur.bill_markup_percentage IS NULL ) OR
	      (MaxRec.bill_markup_percentage = lcur.bill_markup_percentage ))
	AND  ((MaxRec.ind_compiled_set_id IS NULL
	      AND lcur.ind_compiled_set_id IS NULL ) OR
	      (MaxRec.ind_compiled_set_id = lcur.ind_compiled_set_id ))
	AND  ((MaxRec.markup_calc_base_code IS NULL
	      AND lcur.markup_calc_base_code IS NULL ) OR
	      (MaxRec.markup_calc_base_code = lcur.markup_calc_base_code ))
	AND  ((MaxRec.tp_base_amount IS NULL
	      AND lcur.tp_base_amount IS NULL ) OR
	      (MaxRec.tp_base_amount = lcur.tp_base_amount ))
	AND  ((MaxRec.tp_job_id IS NULL
	      AND lcur.tp_job_id IS NULL ) OR
	      (MaxRec.tp_job_id = lcur.tp_job_id ))
	AND  ((MaxRec.acct_tp_rate_date IS NULL
	      AND lcur.acct_tp_rate_date IS NULL ) OR
	      (MaxRec.acct_tp_rate_date = lcur.acct_tp_rate_date ))
	AND  ((MaxRec.acct_tp_rate_type IS NULL
	      AND lcur.acct_tp_rate_type IS NULL ) OR
	      (MaxRec.acct_tp_rate_type = lcur.acct_tp_rate_type ))
	AND  ((MaxRec.acct_tp_exchange_rate IS NULL
	      AND lcur.acct_tp_exchange_rate IS NULL ) OR
	      (MaxRec.acct_tp_exchange_rate = lcur.acct_tp_exchange_rate ))
/*Added cross proj*/
	AND  ((MaxRec.tp_amt_type_code IS NULL
	      AND lcur.tp_amt_type_code IS NULL ) OR
	      (MaxRec.tp_amt_type_code = lcur.tp_amt_type_code ))
	AND  ((MaxRec.project_tp_rate_date IS NULL
	      AND lcur.project_tp_rate_date IS NULL ) OR
	      (MaxRec.project_tp_rate_date = lcur.project_tp_rate_date ))
	AND  ((MaxRec.project_tp_rate_type IS NULL
	      AND lcur.project_tp_rate_type IS NULL ) OR
	      (MaxRec.project_tp_rate_type = lcur.project_tp_rate_type ))
	AND  ((MaxRec.project_tp_exchange_rate IS NULL
	      AND lcur.project_tp_exchange_rate IS NULL ) OR
	      (MaxRec.project_tp_exchange_rate = lcur.project_tp_exchange_rate ))
	AND  ((MaxRec.project_transfer_price IS NULL
	      AND lcur.project_transfer_price IS NULL ) OR
	      (MaxRec.project_transfer_price = lcur.project_transfer_price ))
	AND  ((MaxRec.projfunc_tp_rate_date IS NULL
	      AND lcur.projfunc_tp_rate_date IS NULL ) OR
	      (MaxRec.projfunc_tp_rate_date = lcur.projfunc_tp_rate_date ))
	AND  ((MaxRec.projfunc_tp_rate_type IS NULL
	      AND lcur.projfunc_tp_rate_type IS NULL ) OR
	      (MaxRec.projfunc_tp_rate_type = lcur.projfunc_tp_rate_type ))
	AND  ((MaxRec.projfunc_tp_exchange_rate IS NULL
	      AND lcur.projfunc_tp_exchange_rate IS NULL ) OR
	      (MaxRec.projfunc_tp_exchange_rate = lcur.projfunc_tp_exchange_rate ))
	AND  ((MaxRec.projfunc_transfer_price IS NULL
	      AND lcur.projfunc_transfer_price IS NULL ) OR
	      (MaxRec.projfunc_transfer_price = lcur.projfunc_transfer_price ))

	AND  ((MaxRec.project_tp_currency_code IS NULL
	      AND lcur.project_tp_currency_code IS NULL ) OR
	      (MaxRec.project_tp_currency_code =
					    lcur.project_tp_currency_code ))
	AND  ((MaxRec.projfunc_tp_currency_code IS NULL
	      AND lcur.projfunc_tp_currency_code IS NULL ) OR
	      (MaxRec.projfunc_tp_currency_code =
					    lcur.projfunc_tp_currency_code ))
/*End for cross proj*/
	AND  (MaxRec.denom_tp_currency_code  =  lcur.denom_tp_currency_code)
	AND  (MaxRec.denom_transfer_price    =  lcur.denom_transfer_price)
	AND  (MaxRec.dr_code_combination_id  =  lcur.dr_code_combination_id)
	AND  (MaxRec.cr_code_combination_id  =  lcur.cr_code_combination_id)
    )
 THEN
    IF P_DEBUG_MODE = 'Y' THEN
       log_message('reverse_distribution: ' || '1300: Attributes same');
    END IF;
    lb_attributes_same := TRUE;
    lb_attributes_diff := FALSE;
 ELSE
    IF P_DEBUG_MODE = 'Y' THEN
       log_message('reverse_distribution: ' || '1350: Attributes NOT same');
    END IF;
    lb_attributes_same := FALSE;
    lb_attributes_diff := TRUE;
 END IF;

-- Messages for debug
-- bug 8538911 begin
  IF lb_regular_ei
  THEN
  if lb_reverse_future_period then
     IF P_DEBUG_MODE = 'Y' THEN
        log_message('reverse_distribution: ' || '1400: Check: Future Period Reversed EI');
     END IF;
   else
     IF P_DEBUG_MODE = 'Y' THEN
        log_message('reverse_distribution: ' || '1400: Check: Regular EI');
     END IF;
   end if;
  END IF;
-- bug 8538911 end

  IF lb_adjusting_ei

  THEN
     IF P_DEBUG_MODE = 'Y' THEN
        log_message('reverse_distribution: ' || '1450: Check: Adjusting EI');
     END IF;
  END IF;

  IF lb_non_net_zero

  THEN
     IF P_DEBUG_MODE = 'Y' THEN
        log_message('reverse_distribution: ' || '1500: Check: Not net zero');
     END IF;
  END IF;

  IF lb_net_zero

  THEN
     IF P_DEBUG_MODE = 'Y' THEN
        log_message('reverse_distribution: ' || '1550: Check: Net zero');
     END IF;
  END IF;

  IF lb_borrlent

  THEN
     IF P_DEBUG_MODE = 'Y' THEN
        log_message('reverse_distribution: ' || '1600: Check: Borrowed and Lent');
     END IF;
  END IF;

  IF lb_non_borrlent

  THEN
     IF P_DEBUG_MODE = 'Y' THEN
        log_message('reverse_distribution: ' || '1650: Check: Not Borrowed and Lent');
     END IF;
  END IF;

  IF lb_have_last_line
  THEN
     IF P_DEBUG_MODE = 'Y' THEN
        log_message('reverse_distribution: ' || '1700: Check: Have last line');
     END IF;
      IF lb_regular_last_line
      THEN
         IF P_DEBUG_MODE = 'Y' THEN
            log_message('reverse_distribution: ' || '1750: Check: Regular last line');
         END IF;
      END IF;

      IF lb_irregular_last_line
      THEN
         IF P_DEBUG_MODE = 'Y' THEN
            log_message('reverse_distribution: ' || '1800: Check: Reversing last line');
         END IF;
      END IF;

      IF lb_xfaced_last_line
      THEN
         IF P_DEBUG_MODE = 'Y' THEN
            log_message('reverse_distribution: ' || '1850: Check: Interfaced last line');
         END IF;
      END IF;

      IF lb_non_xfaced_last_line
      THEN
         IF P_DEBUG_MODE = 'Y' THEN
            log_message('reverse_distribution: ' || '1900: Check: Non - interfaced last line');
         END IF;
      END IF;
  END IF;

  IF lb_no_last_line
  THEN
     IF P_DEBUG_MODE = 'Y' THEN
        log_message('reverse_distribution: ' || '1950: Check: No last line');
     END IF;
  END IF;

-- End of debug messages

--
-- The logic for deciding the action to be taken on an item is based
-- on the following table. The first few columns (up to Attr Same)
-- specify the attributes of the transaction while the last few
-- columns specify the action to be taken. The columns are as follows:
--
--  1 - Serial number of the rule
--
--  Conditions:
--
-- 2 - The type of item. An item can be an original EI or a reversing
-- EI. Orig and Rev refer to the two possible values
--
-- 3 - Net Zero. Whether the item is a net zero item. For example,
-- case 7 referes to an original item which is not a net zero item,
-- case 12 refers to an original net zero item while Case 20 refers to
-- a reversing net zero item
--
-- 4 - The current value of the cross charge code on the EI
-- 5 - Whether the Item has a CC Distribution
--
-- 6 - Whether the last distribution has been transferred to Oracle
-- General Ledger
--
-- 7 - Whether the last distribution is a regular distribution. The
-- last line can be a regular or reversing distribution
--
-- 8 - Whether the current attributes for the EI (e.g. Transfer price
-- calculated in the current run) are the same as the attributes of
-- the last distribution line
--
-- Actions:
--
--  9 - Whether the last distribution should be reversed (X-indicates reverse)
--              X - Reverse
--
-- 10 - Whether a new distribution should be created (X-indicates reverse)
--              X - Create new
--
-- 11 - Whether the existing distribution should be updated
--              X - update
--
-- 12 - Whether the existing distribution should be deleted
--              X  - delete
--              X* - delete distribution of reversed EI
--
-- 13 - How the EI should be updated
--              U  - Update with current values determined
--              N  - Update with current values determined
--                   but reverse the amounts
--              G  - Wipe out all attributes on reversed EI
--              X  - Leave attributes unchanged (except
--                   processed flag)
--
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
-- | 1 | 2  | 3  | 4  | 5  | 6  | 7  | 8  |9 |10|11|12|13|
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
-- |Sr |Type|Net | CC |Have|Xfer|Reg |Attr|R |N |U |D |EI|
-- |   |    |zero|Code|Last|last|last|Same|e |e |p |e |U |
-- |   |    |    |    |Line|line|line|    |v |w |d |l |p |
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
-- |  1|Orig|  No|   B| Yes| Yes| Yes|  No| X| X|  |  | A|
-- | 1a|Orig|  No|   B| Yes| Yes| Yes| Yes|  |  |  |  | A|
-- |  2|Orig|  No|   B| Yes| Yes|  No|    |  | X|  |  | A|
-- |  3|Orig|  No|   B| Yes|  No| Yes|  No|  |  | X|  | A|
-- | 3a|Orig|  No|   B| Yes|  No| Yes| Yes|  |  |  |  | A|
-- |  4|Orig|  No|   B| Yes|  No|  No|    |  | X|  |  | A|
-- |  5|Orig|  No|   B|  No|    |    |    |  | X|  |  | A|
-- |  6|Orig|  No| NXI|  No|    |    |    |  |  |  |  | X|
-- |  7|Orig|  No| NXI| Yes| Yes| Yes|    | X|  |  |  | X|
-- |  8|Orig|  No| NXI| Yes| Yes|  No|    |  |  |  |  | X|
-- |  9|Orig|  No| NXI| Yes|  No| Yes|    |  |  |  | X| X|
-- | 10|Orig|  No| NXI| Yes|  No|  No|    |  |  |  |  | X|
-- | 11|Orig| Yes|   B| Yes| Yes| Yes|    |  |  |  |  | A|
-- | 12|Orig| Yes|   B| Yes| Yes|  No|    |  |  |  |  | A|
-- | 13|Orig| Yes|   B| Yes|  No| Yes|    |  |  |  |  | A|
-- | 14|Orig| Yes|   B| Yes|  No|  No|    |  |  |  |  | A|
-- | 15|Orig| Yes|   B|  No|    |    |    |  |  |  |  | X|
-- | 16|Orig| Yes| NXI| Yes| Yes| Yes|    | X|  |  |  | X|
-- | 17|Orig| Yes| NXI| Yes| Yes|  No|    |  |  |  |  | X|
-- | 18|Orig| Yes| NXI| Yes|  No| Yes|    |  |  |  | X| X|
-- | 19|Orig| Yes| NXI| Yes|  No|  No|    |  |  |  |  | X|
-- | 20|Orig| Yes| NXI|  No|    |    |    |  |  |  |  | X|
-- | 21| Adj| Yes|   B| Yes| Yes| Yes|    | X|  |  |  | N|
-- | 22| Adj| Yes|   B| Yes|  No| Yes|    |  |  |  |X*| G|
-- | 23| Adj| Yes|   B| Yes|    |  No|    |  |  |  |  | X|
-- | 24| Adj| Yes|   B|  No|    |    |    |  |  |  |  | X|
-- | 25| Adj| Yes| NXI|    |    |    |    |  |  |  |  | X|
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
--
--
--
--  DELETE the existing distribution
--  Note that in case 22 below, the existing distribution
--  is on the adjusted EI.  The delete_distribution procedure
--  simply deletes the distribution based on the rowid
--  of the distribution retrieved.  For adjusting EIs
--  the distribution retrieved is the last distribution
--  of the adjusted EI
--
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
-- | 1 | 2  | 3  | 4  | 5  | 6  | 7  | 8  |9 |10|11|12|13|
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
-- |Sr |Type|Net | CC |Have|Xfer|Reg |Attr|R |N |U |D |EI|
-- |   |    |zero|Code|Last|last|last|Same|e |e |p |e |U |
-- |   |    |    |    |Line|line|line|    |v |w |d |l |p |
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
-- |  9|Orig|  No| NXI| Yes|  No| Yes|    |  |  |  | X| X|
-- | 18|Orig| Yes| NXI| Yes|  No| Yes|    |  |  |  | X| X|
-- | 22| Adj| Yes|   B| Yes|  No| Yes|    |  |  |  |X*| G|
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
--

  IF (lb_regular_last_line AND lb_non_xfaced_last_line) AND
       ((lb_regular_ei AND  lb_non_borrlent) OR
          (lb_adjusting_ei AND lb_borrlent ))
  THEN
    -- Delete the existing distribution if required
       IF P_DEBUG_MODE = 'Y' THEN
          log_message('reverse_distribution: ' || '2000: Deleting distribution');
       END IF;
       delete_distribution;
       IF P_DEBUG_MODE = 'Y' THEN
          log_message('reverse_distribution: ' || '2050: delete_distribution call over');
       END IF;
  END IF;

--
-- UPDATE the existing distribution
--
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
-- | 1 | 2  | 3  | 4  | 5  | 6  | 7  | 8  |9 |10|11|12|13|
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
-- |Sr |Type|Net | CC |Have|Xfer|Reg |Attr|R |N |U |D |EI|
-- |   |    |zero|Code|Last|last|last|Same|e |e |p |e |U |
-- |   |    |    |    |Line|line|line|    |v |w |d |l |p |
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
-- |  3|Orig|  No|   B| Yes|  No| Yes|  No|  |  | X|  | A|
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
--

  IF   lb_regular_ei        AND lb_non_net_zero
   AND lb_borrlent          AND lb_non_xfaced_last_line
   AND lb_regular_last_line AND lb_attributes_diff
  THEN
       IF P_DEBUG_MODE = 'Y' THEN
          log_message('reverse_distribution: ' || '2100: Updating distribution');
       END IF;
       update_distribution;
       IF P_DEBUG_MODE = 'Y' THEN
          log_message('reverse_distribution: ' || '2150: Update_distribution call over');
       END IF;
  END IF;

--
--  REVERSE a distribution under the following conditions
--
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
-- | 1 | 2  | 3  | 4  | 5  | 6  | 7  | 8  |9 |10|11|12|13|
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
-- |Sr |Type|Net | CC |Have|Xfer|Reg |Attr|R |N |U |D |EI|
-- |   |    |zero|Code|Last|last|last|Same|e |e |p |e |U |
-- |   |    |    |    |Line|line|line|    |v |w |d |l |p |
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
-- |  1|Orig|  No|   B| Yes| Yes| Yes|  No| X| X|  |  | A|
-- |  7|Orig|  No| NXI| Yes| Yes| Yes|    | X|  |  |  | X|
-- | 16|Orig| Yes| NXI| Yes| Yes| Yes|    | X|  |  |  | X|
-- | 21| Adj| Yes|   B| Yes| Yes| Yes|    | X|  |  |  | N|
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
--

  IF (lb_regular_last_line AND lb_xfaced_last_line)
  AND ( (lb_regular_ei AND lb_non_borrlent) OR
	(lb_adjusting_ei AND lb_borrlent)   OR
	(lb_regular_ei AND lb_non_net_zero AND lb_borrlent AND lb_attributes_diff))
  THEN
       IF P_DEBUG_MODE = 'Y' THEN
          log_message('reverse_distribution: ' || '2200: Reversing distribution');
       END IF;
       reverse_distribution;
       IF P_DEBUG_MODE = 'Y' THEN
          log_message('reverse_distribution: ' || '2250: Reverse distribution call over');
       END IF;
  END IF;


-- NEW distribution
--
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
-- | 1 | 2  | 3  | 4  | 5  | 6  | 7  | 8  |9 |10|11|12|13|
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
-- |Sr |Type|Net | CC |Have|Xfer|Reg |Attr|R |N |U |D |EI|
-- |   |    |zero|Code|Last|last|last|Same|e |e |p |e |U |
-- |   |    |    |    |Line|line|line|    |v |w |d |l |p |
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
-- |  1|Orig|  No|   B| Yes| Yes| Yes|  No| X| X|  |  | A|
-- |  2|Orig|  No|   B| Yes| Yes|  No|    |  | X|  |  | A|
-- |  4|Orig|  No|   B| Yes|  No|  No|    |  | X|  |  | A|
-- |  5|Orig|  No|   B|  No|    |    |    |  | X|  |  | A|
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
--

  IF  (lb_regular_ei AND lb_non_net_zero AND lb_borrlent) AND
       ( (lb_no_last_line) OR
           (lb_xfaced_last_line AND lb_regular_last_line AND lb_attributes_diff) OR
            (lb_irregular_last_line))
  THEN
       IF P_DEBUG_MODE = 'Y' THEN
          log_message('reverse_distribution: ' || '2300: New distribution');
       END IF;
       new_distribution;
       IF P_DEBUG_MODE = 'Y' THEN
          log_message('reverse_distribution: ' || '2350: New distribution call over');
       END IF;
  END IF;

--------------------------------------------------------------------
-- Update the values/flags on the EI
--------------------------------------------------------------------

-- After the distributions have been created, the EI has to be updated
-- with the relevant values/flags. There are a few choices here:
-- 1.  Update with currently derived values
-- 2.  Update with negated amounts of last distribution (for reversing
--     EIs)
-- 3.  Do not change any values
-- 4.  Wipe out attributes on reversed EI as its distribution is
--     being deleted
--
--  Update with All currently derived values
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
-- | 1 | 2  | 3  | 4  | 5  | 6  | 7  | 8  |9 |10|11|12|13|
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
-- |Sr |Type|Net | CC |Have|Xfer|Reg |Attr|R |N |U |D |EI|
-- |   |    |zero|Code|Last|last|last|Same|e |e |p |e |U |
-- |   |    |    |    |Line|line|line|    |v |w |d |l |p |
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
-- |  1|Orig|  No|   B| Yes| Yes| Yes|  No| X| X|  |  | A|
-- | 1a|Orig|  No|   B| Yes| Yes| Yes| Yes|  |  |  |  | A|
-- |  2|Orig|  No|   B| Yes| Yes|  No|    |  | X|  |  | A|
-- |  3|Orig|  No|   B| Yes|  No| Yes|  No|  |  | X|  | A|
-- | 3a|Orig|  No|   B| Yes|  No| Yes| Yes|  |  |  |  | A|
-- |  4|Orig|  No|   B| Yes|  No|  No|    |  | X|  |  | A|
-- |  5|Orig|  No|   B|  No|    |    |    |  | X|  |  | A|
-- | 11|Orig| Yes|   B| Yes| Yes| Yes|    |  |  |  |  | A|
-- | 12|Orig| Yes|   B| Yes| Yes|  No|    |  |  |  |  | A|
-- | 13|Orig| Yes|   B| Yes|  No| Yes|    |  |  |  |  | A|
-- | 14|Orig| Yes|   B| Yes|  No|  No|    |  |  |  |  | A|
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
--

-- Bug#1073836: Table was incorrect. Changed the table and modified
-- the code to have conditions to update the EI as per the table.
-- Originally, the problem was if there was no change in the Transfer
-- Price attributes (when comparing with the last line) and the cross
-- charge code was changed from B to I and back to B, then the
-- transfer price attributes get wiped out but the procedure performed
-- no updates.

 IF ( (lb_regular_ei  AND lb_borrlent)  AND
      ( (lb_non_net_zero AND lb_no_last_line) OR
        (lb_have_last_line)
      )
    )
 THEN

   IF P_DEBUG_MODE = 'Y' THEN
      log_message('reverse_distribution: ' || '2400: Updating EI with current values');
   END IF;

   update_ei('A');

   IF P_DEBUG_MODE = 'Y' THEN
      log_message('reverse_distribution: ' || '2450: Back from update_ei-A');
   END IF;

-- Otherwise, Update EI with reversed amounts
--
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
-- | 1 | 2  | 3  | 4  | 5  | 6  | 7  | 8  |9 |10|11|12|13|
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
-- |Sr |Type|Net | CC |Have|Xfer|Reg |Attr|R |N |U |D |EI|
-- |   |    |zero|Code|Last|last|last|Same|e |e |p |e |U |
-- |   |    |    |    |Line|line|line|    |v |w |d |l |p |
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
-- | 21| Adj| Yes|   B| Yes| Yes| Yes|    | X|  |  |  | N|
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
--
/* Bug 2377743 changed variable lb_non_xfaced_last_line to
 ** lb_xfaced_last_line as last line should be interface */
 ELSIF lb_adjusting_ei AND lb_borrlent AND lb_xfaced_last_line AND
       lb_regular_last_line
  THEN
       IF P_DEBUG_MODE = 'Y' THEN
          log_message('reverse_distribution: ' || '2500: Updating EI with reversed amounts');
       END IF;
       update_ei('N');
       IF P_DEBUG_MODE = 'Y' THEN
          log_message('reverse_distribution: ' || '2550: Back from update_ei-N');
       END IF;

--
-- Null out the attributes on the reversed EI (in this case the
-- corresponding distribution on the original EI is deleted)
--
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
-- | 1 | 2  | 3  | 4  | 5  | 6  | 7  | 8  |9 |10|11|12|13|
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
-- |Sr |Type|Net | CC |Have|Xfer|Reg |Attr|R |N |U |D |EI|
-- |   |    |zero|Code|Last|last|last|Same|e |e |p |e |U |
-- |   |    |    |    |Line|line|line|    |v |w |d |l |p |
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
-- | 22| Adj| Yes|   B| Yes|  No| Yes|    |  |  |  |X*| G|
-- +===+====+====+====+====+====+====+====+==+==+==+==+==+
--

 ELSIF  (lb_adjusting_ei AND lb_borrlent AND lb_non_xfaced_last_line AND
	 lb_regular_last_line)
  THEN
       IF P_DEBUG_MODE = 'Y' THEN
          log_message('reverse_distribution: ' || '2600: Update EI with null in reversed EI');
       END IF;
       update_ei('G');
       IF P_DEBUG_MODE = 'Y' THEN
          log_message('reverse_distribution: ' || '2650: Back from update_ei-G');
       END IF;
 ELSE

-- Otherwise update EI as processed without any changes to existing
-- values

       IF P_DEBUG_MODE = 'Y' THEN
          log_message('reverse_distribution: ' || '2700: Updating EI without any changes');
       END IF;
       update_ei('X');
       IF P_DEBUG_MODE = 'Y' THEN
          log_message('reverse_distribution: ' || '2750: Back from update_ei-X');
       END IF;
 END IF;

 END IF; -- if no rejection

 IF P_DEBUG_MODE = 'Y' THEN
    log_message('reverse_distribution: ' || '2800: Finished processing for current item');
 END IF;

END LOOP; -- Finished processing all input records

------------------- End of individual item processing ------------

 IF P_DEBUG_MODE = 'Y' THEN
    log_message('reverse_distribution: ' || '2850: Finished processing for ALL input items');
 END IF;

---------------------------------------------------------------
--                 Mass database operations
---------------------------------------------------------------

-- In the above steps, each EI was examined and the corresponding
-- arrays were filled with information to Insert/Update/Delete data in
-- the distributions and Update the EI table. The following section
-- performs these mass operations

 IF g_dcnt > 0
 THEN
    IF P_DEBUG_MODE = 'Y' THEN
       log_message('reverse_distribution: ' || '2900: Calling mass delete');
    END IF;
    mass_delete;
 END IF;

 IF P_DEBUG_MODE = 'Y' THEN
    log_message('reverse_distribution: ' || '2950: Checking update required, g_ucnt =  ' || g_ucnt);
 END IF;
 IF g_ucnt > 0
 THEN
    IF P_DEBUG_MODE = 'Y' THEN
       log_message('reverse_distribution: ' || '3000: Calling mass update');
    END IF;
     mass_update;
 END IF;

 IF P_DEBUG_MODE = 'Y' THEN
    log_message('reverse_distribution: ' || '3050: Checking insert required');
 END IF;

 IF g_icnt > 0
 THEN
    IF P_DEBUG_MODE = 'Y' THEN
       log_message('reverse_distribution: ' || '3100: Calling mass insert');
    END IF;
    mass_insert;
 END IF;

 IF P_DEBUG_MODE = 'Y' THEN
    log_message('reverse_distribution: ' || '3150: Calling mass EI updates');
 END IF;
 ei_mass_update;
 IF P_DEBUG_MODE = 'Y' THEN
    log_message('reverse_distribution: ' || '3200: All updates over');
 END IF;

reset_curr_function;

EXCEPTION
WHEN  OTHERS
THEN
  IF P_DEBUG_MODE = 'Y' THEN
     log_message('reverse_distribution: ' || '3250: ERROR in main procedure at '|| pa_debug.g_err_stack);
     log_message('reverse_distribution: ' || '3300: ERROR: ' || sqlerrm);
  END IF;
  raise;

END pa_bl_pr;

-------------------------------------------------------------------------------
--              initialization
-------------------------------------------------------------------------------

PROCEDURE initialization(
                           p_request_id              IN NUMBER
                          ,p_program_application_id  IN NUMBER
                          ,p_program_id              IN NUMBER
                          ,p_user_id                 IN NUMBER
                          ,p_login_id                IN NUMBER
                          ,p_prvdr_org_id            IN NUMBER
                          ,p_primary_sob_id          IN NUMBER
	               ) IS

i             PLS_INTEGER;
l_mrc_enabled VARCHAR2(1) := 'N';

CURSOR c1 (p_primary_sob_id  IN NUMBER,
	   p_org_id IN NUMBER) IS
   SELECT ledger_id,
	  currency_code
     FROM gl_alc_ledger_rships_v
    WHERE source_ledger_id = p_primary_sob_id
      AND application_id = pa_cc_utils.g_program_application_id
      AND relationship_enabled_flag = 'Y'
      AND (org_id = -99 OR org_id = p_org_id); -- R12 MRC changes
      -- AND nvl(org_id,-99) = nvl(p_org_id, -99);
      -- AND trunc(sysdate) BETWEEN start_date AND nvl(end_date, sysdate);
BEGIN

set_curr_function('initialization');

IF P_DEBUG_MODE = 'Y' THEN
   log_message('reverse_distribution: ' || '3350: Entered initialization');
END IF;

-- Copy who columns into global variables

pa_cc_utils.g_request_id             := p_request_id;
pa_cc_utils.g_program_application_id := p_program_application_id;
pa_cc_utils.g_program_id             := p_program_id;
pa_cc_utils.g_user_id                := p_user_id;
pa_cc_utils.g_login_id               := p_login_id;

-- Set global variables
pa_cc_utils.g_prvdr_org_id           := p_prvdr_org_id;
pa_cc_utils.g_primary_sob_id         := p_primary_sob_id;


-- Set initialization flag so that this procedure is not performed in
-- the second call to this package for the next set of expenditure
-- items to be processed

g_initialization_done := TRUE;


-- Determine whether MRC is enabled and remember it within this
-- package so that it does not have to be called again

  i := 0;

  IF P_DEBUG_MODE = 'Y' THEN
     log_message('reverse_distribution: ' || '3400: Getting reporting SOBs');
  END IF;

  FOR c in c1 (p_primary_sob_id, p_prvdr_org_id)
  LOOP

   i := i + 1;

   pa_cc_utils.g_reporting_sob_id(i)    := c.ledger_id;

   IF P_DEBUG_MODE = 'Y' THEN
      log_message('reverse_distribution: ' || '3450: Got a reporting SOB: ' || pa_cc_utils.g_reporting_sob_id(i));
   END IF;

   pa_cc_utils.g_reporting_curr_code(i) := c.currency_code;

  END LOOP;

-- MRC is enabled if at least one reporting set of books is present

  IF pa_cc_utils.g_reporting_sob_id.exists(1)
  THEN
     --g_mrc_enabled := TRUE;
     IF P_DEBUG_MODE = 'Y' THEN
        log_message('reverse_distribution: ' || '3500: MRC ENABLED');
     END IF;
  ELSE
     --g_mrc_enabled := FALSE;
     IF P_DEBUG_MODE = 'Y' THEN
        log_message('reverse_distribution: ' || '3550: MRC DISABLED');
     END IF;
  END IF;


IF P_DEBUG_MODE = 'Y' THEN
   log_message('reverse_distribution: ' || '3600: Leaving initalization');
END IF;

reset_curr_function;

EXCEPTION

WHEN OTHERS
 THEN
   IF P_DEBUG_MODE = 'Y' THEN
      log_message('reverse_distribution: ' || '3650: ERROR in initalization');
   END IF;
   raise;

END initialization;



-------------------------------------------------------------------------------
--              clean_tables
-------------------------------------------------------------------------------

PROCEDURE clean_tables IS
BEGIN

set_curr_function('clean_tables');

IF P_DEBUG_MODE = 'Y' THEN
   log_message('reverse_distribution: ' || '3700: Entered clean_tables');
END IF;

  in_acct_currency_code.delete;
  in_acct_tp_exchange_rate.delete;
  in_acct_tp_rate_date.delete;
  in_acct_tp_rate_type.delete;
  in_amount.delete;
  in_bill_markup_percentage.delete;
  in_bill_rate.delete;
  in_RowId.delete;
  in_cc_rejection_code.delete;
  in_cc_dist_line_id.delete;
  in_cr_code_combination_id.delete;
  in_cross_charge_code.delete;
  in_denom_tp_currency_code.delete;
  in_denom_transfer_price.delete;
  in_dist_line_id_reversed.delete;
  in_dr_code_combination_id.delete;
  in_expenditure_item_id.delete;
  in_expenditure_item_date.delete;
  in_ind_compiled_set_id.delete;
  in_line_num.delete;
  in_line_num_reversed.delete;
  in_line_type.delete;
  in_markup_calc_base_code.delete;
  in_org_id.delete;
  in_pa_date.delete;
  in_project_id.delete;
  in_prvdr_org_id.delete;
  in_reference_1.delete;
  in_reference_2.delete;
  in_reference_3.delete;
  in_reversed_flag.delete;
  in_rule_percentage.delete;
  in_schedule_line_percentage.delete;
  in_task_id.delete;
  in_tp_base_amount.delete;
  in_tp_job_id.delete;
  in_upd_type.delete;

IF P_DEBUG_MODE = 'Y' THEN
   log_message('reverse_distribution: ' || '3750: Finished clean_tables');
END IF;
reset_curr_function;

EXCEPTION

WHEN OTHERS
 THEN
   IF P_DEBUG_MODE = 'Y' THEN
      log_message('reverse_distribution: ' || '3800: Exception in clean_tables');
   END IF;
   raise;

END clean_tables;

-------------------------------------------------------------------------------
--              update_distribution
-------------------------------------------------------------------------------

PROCEDURE update_distribution IS
BEGIN

  set_curr_function('update_distribution');

  IF P_DEBUG_MODE = 'Y' THEN
     log_message('reverse_distribution: ' || '3850: Entered update_distribution');
  END IF;
  g_ucnt  := g_ucnt + 1;

-- Copy all attributes from the current derived record

-- Store the rowid. It is used to update the record with the best
-- performance

  g_upd_rec(g_ucnt).CcdRowid := maxrec.CcdRowid;
  g_upd_rec(g_ucnt).expenditure_item_id:= lcur.expenditure_item_id;
  g_upd_rec(g_ucnt).line_num := maxrec.line_num;

  g_upd_rec(g_ucnt).acct_currency_code     := lcur.acct_currency_code;
  g_upd_rec(g_ucnt).acct_tp_exchange_rate  := lcur.acct_tp_exchange_rate;
  g_upd_rec(g_ucnt).acct_tp_rate_date      := lcur.acct_tp_rate_date;
  g_upd_rec(g_ucnt).acct_tp_rate_type      := lcur.acct_tp_rate_type;
  g_upd_rec(g_ucnt).amount                 := lcur.amount;
  g_upd_rec(g_ucnt).bill_markup_percentage := lcur.bill_markup_percentage;
  g_upd_rec(g_ucnt).bill_rate              := lcur.bill_rate;
  g_upd_rec(g_ucnt).cc_dist_line_id        := maxrec.cc_dist_line_id;
  g_upd_rec(g_ucnt).cr_code_combination_id := lcur.cr_code_combination_id;
  g_upd_rec(g_ucnt).cross_charge_code      := lcur.cross_charge_code;
  g_upd_rec(g_ucnt).denom_tp_currency_code := lcur.denom_tp_currency_code;
  g_upd_rec(g_ucnt).denom_transfer_price   := lcur.denom_transfer_price;
  g_upd_rec(g_ucnt).dr_code_combination_id := lcur.dr_code_combination_id;
  g_upd_rec(g_ucnt).expenditure_item_date  := lcur.expenditure_item_date;
  g_upd_rec(g_ucnt).ind_compiled_set_id    := lcur.ind_compiled_set_id;
  g_upd_rec(g_ucnt).line_type              := G_BL_LINE_TYPE;
  g_upd_rec(g_ucnt).markup_calc_base_code  := lcur.markup_calc_base_code;
  g_upd_rec(g_ucnt).pa_date                := lcur.pa_date;
  g_upd_rec(g_ucnt).rule_percentage        := lcur.rule_percentage;
  g_upd_rec(g_ucnt).tp_base_amount         := lcur.tp_base_amount;
  g_upd_rec(g_ucnt).tp_job_id              := lcur.tp_job_id;
  g_upd_rec(g_ucnt).schedule_line_percentage :=
			      lcur.schedule_line_percentage;
/* Added for cross proj*/
  g_upd_rec(g_ucnt).tp_amt_type_code      :=lcur.tp_amt_type_code;
  g_upd_rec(g_ucnt).project_tp_rate_type  :=lcur.project_tp_rate_type;
  g_upd_rec(g_ucnt).project_tp_rate_date  :=lcur.project_tp_rate_date;
  g_upd_rec(g_ucnt).project_tp_exchange_rate:=lcur.project_tp_exchange_rate;
  g_upd_rec(g_ucnt).project_transfer_price:=lcur.project_transfer_price;
  g_upd_rec(g_ucnt).projfunc_tp_rate_type :=lcur.projfunc_tp_rate_type;
  g_upd_rec(g_ucnt).projfunc_tp_rate_date :=lcur.projfunc_tp_rate_date;
g_upd_rec(g_ucnt).projfunc_tp_exchange_rate := lcur.projfunc_tp_exchange_rate;
  g_upd_rec(g_ucnt).projfunc_transfer_price:= lcur.projfunc_transfer_price;

  g_upd_rec(g_ucnt).project_tp_currency_code:= lcur.project_tp_currency_code;
  g_upd_rec(g_ucnt).projfunc_tp_currency_code:= lcur.projfunc_tp_currency_code;
/* End for cross proj*/

-- The upd_type tells the mass update routine that all TP related
-- fields are to be updated for this row
  g_upd_rec(g_ucnt).upd_type := 'U';

  IF P_DEBUG_MODE = 'Y' THEN
     log_message('reverse_distribution: ' || '3900: Leaving update_distribution');
  END IF;

  reset_curr_function;


EXCEPTION
WHEN OTHERS
THEN
    IF P_DEBUG_MODE = 'Y' THEN
       log_message('reverse_distribution: ' || '3950: ERROR in update_distribution');
    END IF;
    raise;

END update_distribution;

-------------------------------------------------------------------------------
--              reverse_distribution
-------------------------------------------------------------------------------

PROCEDURE reverse_distribution IS
BEGIN

  set_curr_function('reverse_distribution');

  IF P_DEBUG_MODE = 'Y' THEN
     log_message('4000: Entered reverse_distribution');
  END IF;

  g_icnt  := g_icnt + 1;
-- Copy all attributes, reversing amounts

-- Reverse amounts
  g_ins_rec(g_icnt).amount               := -maxrec.amount;
  g_ins_rec(g_icnt).denom_transfer_price := -maxrec.denom_transfer_price;

-- Base amount is negative for an adjusting EI but does not change
-- sign for a regular EI. This is because the amounts (say cost) on
-- the adjusting EI are negative while they remain positive on the
-- regular EI and the distribution needs to reflect the amount on the
-- EI

-- Also, if this is a regular EI, then the distribution is reversing
-- another line in the same EI. The reversed line needs to be marked
-- with reversed_flag = 'Y'

  IF lb_regular_ei
  THEN
      g_ins_rec(g_icnt).tp_base_amount:= maxrec.tp_base_amount;
      g_ucnt := g_ucnt + 1;
      g_upd_rec(g_ucnt).CcdRowid := maxrec.CcdRowid;

-- The upd_type tells the mass_update routine that only this field
-- needs to be updated.  R stands for reversal
      g_upd_rec(g_ucnt).upd_type := 'R';

  ELSE
      g_ins_rec(g_icnt).tp_base_amount:= -maxrec.tp_base_amount;
  END IF;

-- Reversing distribution is always created under current expenditure
-- item

  g_ins_rec(g_icnt).expenditure_item_id:= lcur.expenditure_item_id;

  g_ins_rec(g_icnt).acct_currency_code     := maxrec.acct_currency_code;
  g_ins_rec(g_icnt).acct_tp_exchange_rate  := maxrec.acct_tp_exchange_rate;
  g_ins_rec(g_icnt).acct_tp_rate_date      := maxrec.acct_tp_rate_date;
  g_ins_rec(g_icnt).acct_tp_rate_type      := maxrec.acct_tp_rate_type;
  g_ins_rec(g_icnt).bill_markup_percentage := maxrec.bill_markup_percentage;
  g_ins_rec(g_icnt).bill_rate              := maxrec.bill_rate;
  g_ins_rec(g_icnt).cr_code_combination_id := maxrec.cr_code_combination_id;
  g_ins_rec(g_icnt).cross_charge_code      := maxrec.cross_charge_code;
  g_ins_rec(g_icnt).denom_tp_currency_code := maxrec.denom_tp_currency_code;

 /*Bug# 1995400: Added this as pa_date was populated as null on reversal line*/
  g_ins_rec(g_icnt).pa_date                := lcur.pa_date;                /*Added for Bug# 1995400*/
 /*Bug# 2619217: Added this as gl_date was populated as null on reversal line*/
  g_ins_rec(g_icnt).gl_date                := lcur.gl_date;                /*Added for Bug# 2619217*/
  g_ins_rec(g_icnt).dr_code_combination_id := maxrec.dr_code_combination_id;
---  g_ins_rec(g_icnt).expenditure_item_id    := maxrec.expenditure_item_id; /* Bug 5263823 */
  g_ins_rec(g_icnt).ind_compiled_set_id    := maxrec.ind_compiled_set_id;

  -- Line number is the new line number derived earlier
  l_new_line_num             := l_new_line_num + 1;
  g_ins_rec(g_icnt).line_num := l_new_line_num;

-- Line number reversed needs to be populated only if within the same
-- EI. If this distribution is being created in an adjusting EI, then
-- this field is Null

  IF lb_regular_ei
  THEN
      g_ins_rec(g_icnt).line_num_reversed:= maxrec.line_num_reversed;
  ELSE
      g_ins_rec(g_icnt).line_num_reversed := NULL;
  END IF;

-- For records inserted by this process, the line type will always be
-- Borrowed and Lent
  g_ins_rec(g_icnt).line_type              := G_BL_LINE_TYPE;


-- The line id reversed is the max line and is always populated, even
-- for reversing EIs

  g_ins_rec(g_icnt).dist_line_id_reversed  := maxrec.cc_dist_line_id;

  g_ins_rec(g_icnt).markup_calc_base_code := maxrec.markup_calc_base_code;
  g_ins_rec(g_icnt).project_id            := maxrec.project_id;
  g_ins_rec(g_icnt).reversed_flag         := NULL;
  g_ins_rec(g_icnt).rule_percentage       := maxrec.rule_percentage;
  g_ins_rec(g_icnt).schedule_line_percentage :=
			      maxrec.schedule_line_percentage;
  g_ins_rec(g_icnt).task_id               := maxrec.task_id;
  g_ins_rec(g_icnt).tp_job_id             := maxrec.tp_job_id;

/* Added for cross proj*/
  g_ins_rec(g_icnt).tp_amt_type_code      :=maxrec.tp_amt_type_code;
  g_ins_rec(g_icnt).project_tp_rate_type  :=maxrec.project_tp_rate_type;
  g_ins_rec(g_icnt).project_tp_rate_date  :=maxrec.project_tp_rate_date;
  g_ins_rec(g_icnt).project_tp_exchange_rate:=maxrec.project_tp_exchange_rate;
  g_ins_rec(g_icnt).project_transfer_price:=(-1)*maxrec.project_transfer_price;
  g_ins_rec(g_icnt).projfunc_tp_rate_type :=maxrec.projfunc_tp_rate_type;
  g_ins_rec(g_icnt).projfunc_tp_rate_date :=maxrec.projfunc_tp_rate_date;
g_ins_rec(g_icnt).projfunc_tp_exchange_rate := maxrec.projfunc_tp_exchange_rate;
  g_ins_rec(g_icnt).projfunc_transfer_price:=(-1)* maxrec.projfunc_transfer_price;

  g_ins_rec(g_icnt).project_tp_currency_code :=maxrec.project_tp_currency_code;
  g_ins_rec(g_icnt).projfunc_tp_currency_code :=
					      maxrec.projfunc_tp_currency_code;
/* End for cross proj*/

IF P_DEBUG_MODE = 'Y' THEN
   log_message('4050: Leaving reverse_distribution');
END IF;
  reset_curr_function;


EXCEPTION
WHEN OTHERS
THEN
    IF P_DEBUG_MODE = 'Y' THEN
       log_message('4100: ERROR in reverse_distribution');
    END IF;
    raise;

END reverse_distribution;

-------------------------------------------------------------------------------
--              new_distribution
-------------------------------------------------------------------------------


PROCEDURE new_distribution IS
BEGIN

  set_curr_function('new_distribution');
  log_message('4150: Entered new_distribution');

  /* Added the following IF condition for Bug#2469987 */
  IF lcur.amount <> 0 THEN
  g_icnt  := g_icnt + 1;

-- Copy all attributes from the current derived record

  g_ins_rec(g_icnt).expenditure_item_id:= lcur.expenditure_item_id;
-- Line number is the new line number derived earlier
  l_new_line_num             := l_new_line_num + 1;
  g_ins_rec(g_icnt).line_num := l_new_line_num;

  g_ins_rec(g_icnt).acct_currency_code     := lcur.acct_currency_code;
  g_ins_rec(g_icnt).acct_tp_exchange_rate  := lcur.acct_tp_exchange_rate;
  g_ins_rec(g_icnt).acct_tp_rate_date      := lcur.acct_tp_rate_date;
  g_ins_rec(g_icnt).acct_tp_rate_type      := lcur.acct_tp_rate_type;
  g_ins_rec(g_icnt).amount                 := lcur.amount;
  g_ins_rec(g_icnt).bill_markup_percentage := lcur.bill_markup_percentage;
  g_ins_rec(g_icnt).bill_rate              := lcur.bill_rate;
  g_ins_rec(g_icnt).cr_code_combination_id := lcur.cr_code_combination_id;
  g_ins_rec(g_icnt).cross_charge_code      := lcur.cross_charge_code;
  g_ins_rec(g_icnt).denom_tp_currency_code := lcur.denom_tp_currency_code;
  g_ins_rec(g_icnt).denom_transfer_price   := lcur.denom_transfer_price;
  g_ins_rec(g_icnt).dist_line_id_reversed  := lcur.dist_line_id_reversed;
  g_ins_rec(g_icnt).dr_code_combination_id := lcur.dr_code_combination_id;

-- Expenditure Item date is required for MRC conversions
  g_ins_rec(g_icnt).expenditure_item_date  := lcur.expenditure_item_date;

  g_ins_rec(g_icnt).expenditure_item_id    := lcur.expenditure_item_id;
  g_ins_rec(g_icnt).ind_compiled_set_id    := lcur.ind_compiled_set_id;
  g_ins_rec(g_icnt).line_num_reversed      := NULL;
  g_ins_rec(g_icnt).line_type              := G_BL_LINE_TYPE;
  g_ins_rec(g_icnt).markup_calc_base_code  := lcur.markup_calc_base_code;
  g_ins_rec(g_icnt).pa_date                := lcur.pa_date;
  g_ins_rec(g_icnt).gl_date                := lcur.gl_date;             /* EPP */
  g_ins_rec(g_icnt).pa_period_name         := lcur.pa_period_name;      /* EPP */
  g_ins_rec(g_icnt).gl_period_name         := lcur.gl_period_name;      /* EPP */
  g_ins_rec(g_icnt).project_id             := lcur.project_id;
  g_ins_rec(g_icnt).reversed_flag          := NULL;
  g_ins_rec(g_icnt).rule_percentage        := lcur.rule_percentage;
  g_ins_rec(g_icnt).tp_base_amount         := lcur.tp_base_amount;
  g_ins_rec(g_icnt).tp_job_id              := lcur.tp_job_id;
  g_ins_rec(g_icnt).schedule_line_percentage :=
			      lcur.schedule_line_percentage;
  g_ins_rec(g_icnt).task_id                := lcur.task_id;

/* Added for cross proj*/
  g_ins_rec(g_icnt).tp_amt_type_code      :=lcur.tp_amt_type_code;
  g_ins_rec(g_icnt).project_tp_rate_type  :=lcur.project_tp_rate_type;
  g_ins_rec(g_icnt).project_tp_rate_date  :=lcur.project_tp_rate_date;
  g_ins_rec(g_icnt).project_tp_exchange_rate:=lcur.project_tp_exchange_rate;
  g_ins_rec(g_icnt).project_transfer_price:=lcur.project_transfer_price;
  g_ins_rec(g_icnt).projfunc_tp_rate_type :=lcur.projfunc_tp_rate_type;
  g_ins_rec(g_icnt).projfunc_tp_rate_date :=lcur.projfunc_tp_rate_date;
  g_ins_rec(g_icnt).projfunc_tp_exchange_rate := lcur.projfunc_tp_exchange_rate;
  g_ins_rec(g_icnt).projfunc_transfer_price:= lcur.projfunc_transfer_price;

  g_ins_rec(g_icnt).project_tp_currency_code:= lcur.project_tp_currency_code;
  g_ins_rec(g_icnt).projfunc_tp_currency_code:= lcur.projfunc_tp_currency_code;
/* End for cross proj*/
  END IF; /* Added for Bug#2469987 */

  log_message('4200: Leaving new_distribution');
  reset_curr_function;

EXCEPTION
WHEN OTHERS
THEN
    log_message('4250: ERROR in new_distribution');
    raise;

END new_distribution;

-------------------------------------------------------------------------------
--              delete_distribution
-------------------------------------------------------------------------------

PROCEDURE delete_distribution IS
BEGIN
 set_curr_function('delete_distribution');
 log_message('4300: Entered delete_distribution');

 g_dcnt := g_dcnt + 1;
 g_del_rec(g_dcnt).CcdRowId             := maxrec.CcdRowid;
 g_del_rec(g_dcnt).cc_dist_line_id      := maxrec.cc_dist_line_id;

 log_message('4350: Leaving delete_distribution');
 reset_curr_function;

EXCEPTION
WHEN OTHERS
THEN
    log_message('4400: ERROR in delete_distribution');
    raise;

END delete_distribution;

-------------------------------------------------------------------------------
--             mass_delete
-------------------------------------------------------------------------------

-- Procedure to delete all records marked for deletion enmasse
PROCEDURE mass_delete IS
BEGIN

 set_curr_function('mass_delete');
 log_message('4450: Entered mass_delete for '|| to_char(g_dcnt));

FOR i in 1..g_dcnt
LOOP
   in_cc_dist_line_id(i)  := g_del_rec(i).cc_dist_line_id;
   in_RowId(i)            := g_del_rec(i).CcdRowId;
END LOOP;

IF g_dcnt <= 0
 THEN

 log_message('4500: NO RECORDS TO DELETE');

ELSE

 log_message('4550: Mass deletion of distributions for ' || g_dcnt || ' records');

 FORALL i in 1..g_dcnt

 DELETE FROM PA_CC_DIST_LINES
  WHERE rowid = in_RowId(i);

 log_message('4600: -- Rows deleted = ' || to_char(sql%ROWCOUNT));

 /*IF g_mrc_enabled
 THEN

    log_message('4650: Performing mass_delete for MRC');

     pa_mc_borrlent.bl_mc_delete
   	(
            p_cc_dist_line_id             => in_cc_dist_line_id
	   ,p_debug_mode                  => pa_cc_utils.g_debug_mode
           );

    log_message('4700: Finished delete for MRC');

 END IF;*/
END IF;

 log_message('4750: cleaning up');
 clean_tables;

-- Clean up array
 g_del_rec.delete;
 g_dcnt := 0;

 log_message('4800: Leaving mass_delete');

 reset_curr_function;

EXCEPTION
WHEN OTHERS
THEN
 log_message('4850: ERROR in mass_delete');
 raise;

END mass_delete;

-------------------------------------------------------------------------------
--              mass_insert
-------------------------------------------------------------------------------

PROCEDURE mass_insert IS
i  PLS_INTEGER;
rec_count integer; /* bug:8406827 */
BEGIN

  set_curr_function('mass_insert');

  log_message('4900: Entered mass_insert for '|| g_icnt);

-- Download all values into single table arrays to avoid Oracle errors
-- caused by using rec(i).field


-- g_org_id is set with the current OU.
g_org_id := mo_global.get_current_org_id ;


FOR i IN 1..g_icnt
LOOP

-- Select the next line id into the in_ variable. This is done here
-- and not directly in the INSERT statement because the line_id has to
-- be passed to MRC

  SELECT pa_cc_dist_lines_s.nextval
    INTO in_cc_dist_line_id(i)
    FROM dual;

  in_expenditure_item_id(i)      := g_ins_rec(i).expenditure_item_id;
  in_line_num(i)                 := g_ins_rec(i).line_num;
  in_acct_currency_code(i)       := g_ins_rec(i).acct_currency_code;
  in_acct_tp_exchange_rate(i)    := g_ins_rec(i).acct_tp_exchange_rate;
  in_acct_tp_rate_date(i)        := g_ins_rec(i).acct_tp_rate_date;
  in_acct_tp_rate_type(i)        := g_ins_rec(i).acct_tp_rate_type;
  in_amount(i)                   := g_ins_rec(i).amount;
  in_bill_markup_percentage(i)   := g_ins_rec(i).bill_markup_percentage;
  in_bill_rate(i)                := g_ins_rec(i).bill_rate;
  in_cr_code_combination_id(i)   := g_ins_rec(i).cr_code_combination_id;
  in_cross_charge_code(i)        := g_ins_rec(i).cross_charge_code;
  in_denom_tp_currency_code(i)   := g_ins_rec(i).denom_tp_currency_code;
  in_denom_transfer_price(i)     := g_ins_rec(i).denom_transfer_price;
  in_dist_line_id_reversed(i)    := g_ins_rec(i).dist_line_id_reversed;
  in_dr_code_combination_id(i)   := g_ins_rec(i).dr_code_combination_id;
  in_expenditure_item_date(i)    := g_ins_rec(i).expenditure_item_date;
  in_ind_compiled_set_id(i)      := g_ins_rec(i).ind_compiled_set_id;
  in_line_num_reversed(i)        := g_ins_rec(i).line_num_reversed;
  in_line_type(i)                := g_ins_rec(i).line_type;
  in_markup_calc_base_code(i)    := g_ins_rec(i).markup_calc_base_code;
  in_pa_date(i)                  := g_ins_rec(i).pa_date;
  in_gl_date(i)                  := g_ins_rec(i).gl_date;                     /* EPP */
  in_pa_period_name(i)           := g_ins_rec(i).pa_period_name;              /* EPP */
  in_gl_period_name(i)           := g_ins_rec(i).gl_period_name;              /* EPP */
  in_project_id(i)               := g_ins_rec(i).project_id;

-- prvdr_org_id is sent as an array to the MRC procedure because it
-- expects it as such. The reason for this is that MRC upgrade is
-- performed for a reporting set of books across operating units and
-- hence a combination of operating units may be present in a single
-- call

  in_prvdr_org_id(i)             := pa_cc_utils.g_prvdr_org_id;

-- The following reference_1, reference_2 and reference_3 columns are
-- only populated by the InterCompany invoicing and the MRC upgrade
-- processes. Reference_2 (type of provider reclass base) and
-- reference_3 (cdl_line_num) are used in MRC upgrade

  in_reference_1(i)              := g_ins_rec(i).reference_1;
  in_reference_2(i)              := g_ins_rec(i).reference_2;
  in_reference_3(i)              := g_ins_rec(i).reference_3;

  in_reversed_flag(i)            := g_ins_rec(i).reversed_flag;
  in_rule_percentage(i)          := g_ins_rec(i).rule_percentage;
  in_tp_base_amount(i)           := g_ins_rec(i).tp_base_amount;
  in_tp_job_id(i)                := g_ins_rec(i).tp_job_id;
  in_schedule_line_percentage(i) := g_ins_rec(i).schedule_line_percentage;
  in_task_id(i)                  := g_ins_rec(i).task_id;

  /* Added for cross proj*/
  in_tp_amt_type_code(i)         := g_ins_rec(i).tp_amt_type_code;
  in_project_tp_rate_type(i)     := g_ins_rec(i).project_tp_rate_type;
  in_project_tp_rate_date(i)     := g_ins_rec(i).project_tp_rate_date;
  in_project_tp_exchange_rate(i) := g_ins_rec(i).project_tp_exchange_rate;
  in_project_transfer_price(i)   := g_ins_rec(i).project_transfer_price;
  in_projfunc_tp_rate_type(i)    := g_ins_rec(i).projfunc_tp_rate_type;
  in_projfunc_tp_rate_date(i)    := g_ins_rec(i).projfunc_tp_rate_date;
  in_projfunc_tp_exchange_rate(i):= g_ins_rec(i).projfunc_tp_exchange_rate;
  in_projfunc_transfer_price(i)  := g_ins_rec(i).projfunc_transfer_price;

  in_project_tp_currency_code(i)  := g_ins_rec(i).project_tp_currency_code;
  in_projfunc_tp_currency_code(i)  := g_ins_rec(i).projfunc_tp_currency_code;
  /* End for cross proj*/

END LOOP;

log_message('4950: Set all values about to perform insert');

IF g_icnt <= 0
THEN

  log_message('5000: NO RECORDS TO INSERT');

ELSE

  log_message('5050: Performing insert for ' || to_char(g_icnt));

   	 /* Bug  8406827  BEGIN */
 	    FOR i in 1..g_icnt LOOP

 	    select count(*) into rec_count
 	    from pa_cc_dist_lines
 	    where
 	    expenditure_item_id=in_expenditure_item_id(i)
 	    AND line_num=in_line_num(i) ;


 	    log_message('For exp_item: ' ||in_expenditure_item_id(i)||' line_num:'||in_line_num(i)||' cc_dist_line count: '||rec_count );

 	    if (rec_count=0)then
 	    log_message('Inserting into pa_cc_dist_lines');
     INSERT
       INTO pa_cc_dist_lines
       (
         org_id		,
	 cc_dist_line_id,
         expenditure_item_id,
         line_num,
         line_type,
         cross_charge_code,
         acct_currency_code,
         amount,
         project_id,
         task_id,
         request_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         line_num_reversed,
         dist_line_id_reversed,
         reversed_flag,
         denom_tp_currency_code,
         denom_transfer_price,
         acct_tp_rate_type,
         acct_tp_rate_date,
         acct_tp_exchange_rate,
         dr_code_combination_id,
         cr_code_combination_id,
         pa_date,
         gl_date,
         pa_period_name,                        /* EPP */
         gl_period_name,                        /* EPP */
         gl_batch_name,
         transfer_status_code,
         transferred_date,
         transfer_rejection_code,
         markup_calc_base_code,
         ind_compiled_set_id,
         bill_rate,
         tp_base_amount,
         tp_job_id,
         bill_markup_percentage,
         schedule_line_percentage,
         rule_percentage,
         reference_1,
         reference_2,
         reference_3,
         program_application_id,
         program_id,
         program_update_date,
         /* Added for cross proj*/
         tp_amt_type_code,
         project_tp_rate_type,
         project_tp_rate_date,
         project_tp_exchange_rate,
         project_transfer_price,
         projfunc_tp_rate_type,
         projfunc_tp_rate_date,
         projfunc_tp_exchange_rate,
         projfunc_transfer_price,

	 project_tp_currency_code,
	 projfunc_tp_currency_code
         /* End for cross proj*/
       )
       VALUES
       (
	  g_org_id ,                     -- Current OU
	  in_cc_dist_line_id(i),         -- cc_dist_line_id
          in_expenditure_item_id(i),     -- expenditure_item_id
          in_line_num(i),                -- line_num
          in_line_type(i),               -- line_type
          in_cross_charge_code(i),       -- cross_charge_code
          in_acct_currency_code(i),      -- acct_currency_code
          in_amount(i),                  -- amount
          in_project_id(i),              -- project_id
          in_task_id(i),                 -- task_id
          pa_cc_utils.g_request_id,      -- request_id
          sysdate,                       -- last_update_date
          pa_cc_utils.g_user_id,         -- last_updated_by
          sysdate,                       -- creation_date
          pa_cc_utils.g_user_id,         -- created_by
          pa_cc_utils.g_login_id,        -- last_update_login
          in_line_num_reversed(i),       -- line_num_reversed
          in_dist_line_id_reversed(i),   -- dist_line_id_reversed
          in_reversed_flag(i),           -- reversed_flag
          in_denom_tp_currency_code(i),  -- denom_tp_currency_code
          in_denom_transfer_price(i),    -- denom_transfer_price
          in_acct_tp_rate_type(i),       -- acct_tp_rate_type
          in_acct_tp_rate_date(i),       -- acct_tp_rate_date
          in_acct_tp_exchange_rate(i),   -- acct_tp_exchange_rate
          in_dr_code_combination_id(i),  -- dr_code_combination_id
          in_cr_code_combination_id(i),  -- cr_code_combination_id
          in_pa_date(i),                 -- pa_date
          in_gl_date(i),                 -- gl_date           -- EPP
          in_pa_period_name(i),          -- pa_period_name    -- EPP
          in_gl_period_name(i),          -- gl_period_name    -- EPP
          NULL,                          -- gl_batch_name
          'P',                           -- transfer_status_code
          NULL,                          -- transferred_date
          NULL,                          -- transfer_rejection_code
          in_markup_calc_base_code(i),   -- markup_calc_base_code
          in_ind_compiled_set_id(i),     -- ind_compiled_set_id
          in_bill_rate(i),               -- bill_rate
          in_tp_base_amount(i),          -- tp_base_amount
          in_tp_job_id(i),               -- tp_job_id
          in_bill_markup_percentage(i),  -- bill_markup_percentage
          in_schedule_line_percentage(i),-- schedule_line_percentage
          in_rule_percentage(i),         -- rule_percentage
          in_reference_1(i),             -- reference_1
          in_reference_2(i),             -- reference_2
          in_reference_3(i),             -- reference_3
          pa_cc_utils.g_program_application_id,      -- program_application_id
          pa_cc_utils.g_program_id,                  -- program_id
          sysdate,                        -- program_update_date
      /* Added for cross proj*/
         in_tp_amt_type_code(i),
         in_project_tp_rate_type(i),
         in_project_tp_rate_date(i),
         in_project_tp_exchange_rate(i),
         in_project_transfer_price(i),
         in_projfunc_tp_rate_type(i),
         in_projfunc_tp_rate_date(i),
         in_projfunc_tp_exchange_rate(i),
         in_projfunc_transfer_price(i),

	 in_project_tp_currency_code(i),
	 in_projfunc_tp_currency_code(i)
         /* End for cross proj*/

       );

	   else
 	 log_message('Pa_cc_dist_lines Insert aborted.');
 	 END IF;
 	 END LOOP;
 	 /*End-Chages for Bug:8406827*/

 log_message('5100: -- Rows inserted = ' || to_char(sql%ROWCOUNT));


-- Call MRC procedure to create MRC records if MRC is enabled

 /*IF g_mrc_enabled
 THEN
    log_message('5150: MRC Enabled; calling mass insert for MRC:'||
			pa_cc_utils.g_program_application_id);

    pa_mc_borrlent.bl_mc_insert
       (
	 p_primary_sob_id              => pa_cc_utils.g_primary_sob_id
	,p_prvdr_org_id                => in_prvdr_org_id
	,p_rsob_id                     => pa_cc_utils.g_reporting_sob_id
	,p_rcurrency_code              => pa_cc_utils.g_reporting_curr_code
	,p_cc_dist_line_id             => in_cc_dist_line_id
	,p_expenditure_item_id         => in_expenditure_item_id
	,p_line_num                    => in_line_num
	,p_line_type                   => in_line_type
        ,p_denom_currency_code         => in_denom_tp_currency_code
	,p_acct_tp_rate_type           => in_acct_tp_rate_type
	,p_expenditure_item_date       => in_expenditure_item_date
	,p_acct_tp_exchange_rate       => in_acct_tp_exchange_rate
	,p_denom_transfer_price        => in_denom_transfer_price
	,p_dist_line_id_reversed       => in_dist_line_id_reversed
	,p_prvdr_cost_reclass_code     => in_reference_2
	,p_cdl_line_num                => in_reference_3
	,p_login_id                    => pa_cc_utils.g_login_id
	,p_program_id                  => pa_cc_utils.g_program_id
	,p_program_application_id      => pa_cc_utils.g_program_application_id
	,p_request_id                  => pa_cc_utils.g_request_id
	,p_debug_mode                  => pa_cc_utils.g_debug_mode
       );
 END IF;*/

END IF; -- If g_icnt > 0

 clean_tables;

-- Clean up array
 g_ins_rec.delete;
 g_icnt := 0;

 log_message('5200: Leaving mass_insert');
 reset_curr_function;

EXCEPTION

 WHEN OTHERS
 THEN
   log_message('5250: ERROR in mass_insert');
   raise;

END mass_insert;

-------------------------------------------------------------------------------
--              mass_update
-------------------------------------------------------------------------------

PROCEDURE mass_update IS
i PLS_INTEGER;
BEGIN

  set_curr_function('mass_update');
  log_message('5300: About to perform mass update for ' || g_ucnt);

 FOR  i in 1..g_ucnt
 LOOP
   in_RowId(i)                     := g_upd_rec(i).CcdRowid;

-- The upd_type variable tells this routine about the fields that need
-- to be updated. For reversal of existing lines, the reversed line
-- needs to be updated with a reversed flag of 'Y' and other fields
-- are untouched (the corresponding table values will not contain
-- anything as they are uninitialized to conserve memory). For the
-- up_type of 'U', all transfer price fields are updated

  IF g_upd_rec(i).upd_type = 'U'
  THEN
    in_acct_currency_code(i)       := g_upd_rec(i).acct_currency_code;
    in_acct_tp_exchange_rate(i)    := g_upd_rec(i).acct_tp_exchange_rate;
    in_acct_tp_rate_date(i)        := g_upd_rec(i).acct_tp_rate_date;
    in_acct_tp_rate_type(i)        := g_upd_rec(i).acct_tp_rate_type;
    in_amount(i)                   := g_upd_rec(i).amount;
    in_bill_markup_percentage(i)   := g_upd_rec(i).bill_markup_percentage;
    in_bill_rate(i)                := g_upd_rec(i).bill_rate;
    in_cc_dist_line_id(i)          := g_upd_rec(i).cc_dist_line_id;
    in_cr_code_combination_id(i)   := g_upd_rec(i).cr_code_combination_id;
    in_cross_charge_code(i)        := g_upd_rec(i).cross_charge_code;
    in_denom_tp_currency_code(i)   := g_upd_rec(i).denom_tp_currency_code;
    in_denom_transfer_price(i)     := g_upd_rec(i).denom_transfer_price;
    in_dr_code_combination_id(i)   := g_upd_rec(i).dr_code_combination_id;

-- EI date is required for MRC conversions
    in_expenditure_item_date(i)    := g_upd_rec(i).expenditure_item_date;


    in_ind_compiled_set_id(i)      := g_upd_rec(i).ind_compiled_set_id;
    in_line_type(i)                := g_upd_rec(i).line_type;
    in_markup_calc_base_code(i)    := g_upd_rec(i).markup_calc_base_code;

    in_pa_date(i)                  := g_upd_rec(i).pa_date;

-- prvdr_org_id is sent as an array to the MRC procedure because it
-- expects it as such. The reason for this is that MRC upgrade is
-- performed for a reporting set of books across operating units and
-- hence a combination of operating units may be present in a single
-- call

    in_prvdr_org_id(i)             := pa_cc_utils.g_prvdr_org_id;

-- The following reference_1, reference_2 and reference_3 columns are
-- only populated by the InterCompany invoicing and the MRC upgrade
-- processes. Reference_2 (type of provider reclass base) and
-- reference_3 (cdl_line_num) are used in MRC upgrade

    in_reference_1(i)              := g_upd_rec(i).reference_1;
    in_reference_2(i)              := g_upd_rec(i).reference_2;
    in_reference_3(i)              := g_upd_rec(i).reference_3;

    in_rule_percentage(i)          := g_upd_rec(i).rule_percentage;
    in_tp_base_amount(i)           := g_upd_rec(i).tp_base_amount;
    in_tp_job_id(i)                := g_upd_rec(i).tp_job_id;
    in_schedule_line_percentage(i) := g_upd_rec(i).schedule_line_percentage;
    in_upd_type(i)                 := 'U';
/* Added for cross proj*/
    in_tp_amt_type_code(i)      :=g_upd_rec(i).tp_amt_type_code;
    in_project_tp_rate_type(i)  :=g_upd_rec(i).project_tp_rate_type;
    in_project_tp_rate_date(i)  :=g_upd_rec(i).project_tp_rate_date;
    in_project_tp_exchange_rate(i):=g_upd_rec(i).project_tp_exchange_rate;
    in_project_transfer_price(i):=g_upd_rec(i).project_transfer_price;
    in_projfunc_tp_rate_type(i) :=g_upd_rec(i).projfunc_tp_rate_type;
    in_projfunc_tp_rate_date(i) :=g_upd_rec(i).projfunc_tp_rate_date;
    in_projfunc_tp_exchange_rate(i) := g_upd_rec(i).projfunc_tp_exchange_rate;
    in_projfunc_transfer_price(i):= g_upd_rec(i).projfunc_transfer_price;

    in_project_tp_currency_code(i):= g_upd_rec(i).project_tp_currency_code;
    in_projfunc_tp_currency_code(i):= g_upd_rec(i).projfunc_tp_currency_code;
/* End for cross proj*/
  ELSE
    in_upd_type(i)                 := 'R';
    in_acct_currency_code(i)       := NULL;
    in_acct_tp_exchange_rate(i)    := NULL;
    in_acct_tp_rate_date(i)        := NULL;
    in_acct_tp_rate_type(i)        := NULL;
    in_amount(i)                   := NULL;
    in_bill_markup_percentage(i)   := NULL;
    in_bill_rate(i)                := NULL;
    in_cc_dist_line_id(i)          := NULL;
    in_cr_code_combination_id(i)   := NULL;
    in_cross_charge_code(i)        := NULL;
    in_denom_tp_currency_code(i)   := NULL;
    in_denom_transfer_price(i)     := NULL;
    in_dr_code_combination_id(i)   := NULL;
    in_expenditure_item_date(i)    := NULL;
    in_ind_compiled_set_id(i)      := NULL;
    in_line_type(i)                := NULL;
    in_markup_calc_base_code(i)    := NULL;
    in_pa_date(i)                  := NULL;
    in_prvdr_org_id(i)             := NULL;
    in_reference_1(i)              := NULL;
    in_reference_2(i)              := NULL;
    in_reference_3(i)              := NULL;
    in_rule_percentage(i)          := NULL;
    in_tp_base_amount(i)           := NULL;
    in_tp_job_id(i)                := NULL;
    in_schedule_line_percentage(i) := NULL;
/* Added for cross proj*/
    in_tp_amt_type_code(i)      :=NULL;
    in_project_tp_rate_type(i)  :=NULL;
    in_project_tp_rate_date(i)  :=NULL;
    in_project_tp_exchange_rate(i):=NULL;
    in_project_transfer_price(i):=NULL;
    in_projfunc_tp_rate_type(i) :=NULL;
    in_projfunc_tp_rate_date(i) :=NULL;
    in_projfunc_tp_exchange_rate(i) := NULL;
    in_projfunc_transfer_price(i):= NULL;

    in_project_tp_currency_code(i):= NULL;
    in_projfunc_tp_currency_code(i):= NULL;
/* End for cross proj*/
  END IF;

 END LOOP;

 log_message('5350: Applying updates to database');

-- Update all records

IF g_ucnt <= 0
THEN
  log_message('5400: NO RECORDS TO UPDATE');
ELSE

  log_message('5450: Updating for ' || to_char(g_ucnt));

  FORALL i in 1..g_ucnt
  UPDATE pa_cc_dist_lines
     SET
     reversed_flag =
       decode(in_upd_type(i), 'U', reversed_flag, 'Y'),
    acct_currency_code =
       decode(in_upd_type(i), 'U',
         in_acct_currency_code(i), acct_currency_code),
    acct_tp_exchange_rate =
       decode(in_upd_type(i), 'U',
         in_acct_tp_exchange_rate(i), acct_tp_exchange_rate),
    acct_tp_rate_date =
       decode(in_upd_type(i), 'U',
         in_acct_tp_rate_date(i), acct_tp_rate_date),
    acct_tp_rate_type =
       decode(in_upd_type(i), 'U',
         in_acct_tp_rate_type(i), acct_tp_rate_type),
    amount =
       decode(in_upd_type(i), 'U',
         in_amount(i), amount),
    bill_markup_percentage =
       decode(in_upd_type(i), 'U',
         in_bill_markup_percentage(i), bill_markup_percentage),
    bill_rate =
       decode(in_upd_type(i), 'U',
         in_bill_rate(i), bill_rate),
    cr_code_combination_id =
       decode(in_upd_type(i), 'U',
         in_cr_code_combination_id(i), cr_code_combination_id),
    cross_charge_code =
       decode(in_upd_type(i), 'U',
         in_cross_charge_code(i), cross_charge_code),
    denom_tp_currency_code =
       decode(in_upd_type(i), 'U',
         in_denom_tp_currency_code(i), denom_tp_currency_code),
    denom_transfer_price =
       decode(in_upd_type(i), 'U',
         in_denom_transfer_price(i), denom_transfer_price),
    dr_code_combination_id =
       decode(in_upd_type(i), 'U',
         in_dr_code_combination_id(i), dr_code_combination_id),
    ind_compiled_set_id =
       decode(in_upd_type(i), 'U',
         in_ind_compiled_set_id(i), ind_compiled_set_id),
    markup_calc_base_code =
       decode(in_upd_type(i), 'U',
         in_markup_calc_base_code(i), markup_calc_base_code),
    reference_1 =
       decode(in_upd_type(i), 'U',
         in_reference_1(i), reference_1),
    reference_2 =
       decode(in_upd_type(i), 'U',
         in_reference_2(i), reference_2),
    reference_3 =
       decode(in_upd_type(i), 'U',
         in_reference_3(i), reference_3),
    rule_percentage =
       decode(in_upd_type(i), 'U',
         in_rule_percentage(i), rule_percentage),
    tp_base_amount =
       decode(in_upd_type(i), 'U',
         in_tp_base_amount(i), tp_base_amount),
    tp_job_id =
       decode(in_upd_type(i), 'U',
         in_tp_job_id(i), tp_job_id),
    schedule_line_percentage =
       decode(in_upd_type(i), 'U',
         in_schedule_line_percentage(i), schedule_line_percentage),
  /*Added Cross proj*/
    tp_amt_type_code   =  decode(in_upd_type(i), 'U',
	  in_tp_amt_type_code(i),tp_amt_type_code),
    project_tp_rate_type   =  decode(in_upd_type(i), 'U',
	  in_project_tp_rate_type(i),project_tp_rate_type),
    project_tp_rate_date   =  decode(in_upd_type(i), 'U',
	  in_project_tp_rate_date(i),project_tp_rate_date),
    project_tp_exchange_rate=   decode(in_upd_type(i), 'U',
	  in_project_tp_exchange_rate(i),project_tp_exchange_rate),
    project_transfer_price  =   decode(in_upd_type(i), 'U',
	  in_project_transfer_price(i),project_transfer_price),
    projfunc_tp_rate_type   =   decode(in_upd_type(i), 'U',
	  in_projfunc_tp_rate_type(i),projfunc_tp_rate_type),
    projfunc_tp_rate_date   =   decode(in_upd_type(i), 'U',
	  in_projfunc_tp_rate_date(i),projfunc_tp_rate_date),
    projfunc_tp_exchange_rate=   decode(in_upd_type(i), 'U',
	  (in_projfunc_tp_exchange_rate(i)),projfunc_tp_exchange_rate),
    projfunc_transfer_price  =   decode(in_upd_type(i), 'U',
	  in_projfunc_transfer_price(i),projfunc_transfer_price),

    project_tp_currency_code  =   decode(in_upd_type(i), 'U',
	  in_project_tp_currency_code(i),project_tp_currency_code),
    projfunc_tp_currency_code  =   decode(in_upd_type(i), 'U',
	  in_projfunc_tp_currency_code(i),projfunc_tp_currency_code),
  /*End Cross proj*/
     last_updated_by             = pa_cc_utils.g_user_id,
     last_update_login           = pa_cc_utils.g_login_id,
     last_update_date            = sysdate,
     request_id                  = pa_cc_utils.g_request_id,
     program_application_id      = pa_cc_utils.g_program_application_id,
     program_id                  = pa_cc_utils.g_program_id,
     program_update_date         = sysdate
  WHERE rowid = in_RowId(i);

  log_message('5500: -- Rows updated = ' || to_char(sql%ROWCOUNT));



  /*IF g_mrc_enabled
  THEN

    log_message('5550: Performing MRC for mass_update');
    log_message('5600: first line id passed ' || in_cc_dist_line_id(1));

    pa_mc_borrlent.bl_mc_update
       (
	 p_primary_sob_id              => pa_cc_utils.g_primary_sob_id
	,p_prvdr_org_id                => in_prvdr_org_id
	,p_rsob_id                     => pa_cc_utils.g_reporting_sob_id
	,p_rcurrency_code              => pa_cc_utils.g_reporting_curr_code
	,p_cc_dist_line_id             => in_cc_dist_line_id
	,p_line_type                   => in_line_type
	,p_upd_type                    => in_upd_type
	,p_expenditure_item_date       => in_expenditure_item_date
        ,p_denom_currency_code         => in_denom_tp_currency_code
	,p_acct_tp_rate_type           => in_acct_tp_rate_type
	,p_acct_tp_exchange_rate       => in_acct_tp_exchange_rate
	,p_denom_transfer_price        => in_denom_transfer_price
	,p_prvdr_cost_reclass_code     => in_reference_2
	,p_cdl_line_num                => in_reference_3
	,p_login_id                    => pa_cc_utils.g_login_id
	,p_program_id                  => pa_cc_utils.g_program_id
	,p_program_application_id      => pa_cc_utils.g_program_application_id
	,p_request_id                  => pa_cc_utils.g_request_id
	,p_debug_mode                  => pa_cc_utils.g_debug_mode
        );

     log_message('5650: Finished MRC update');

  END IF;*/

END IF; -- IF g_ucnt > 0

  clean_tables;

-- Clear up mass update records
  g_upd_rec.delete;
  g_ucnt := 0;

  log_message('5700: Leaving mass_update');
  reset_curr_function;

EXCEPTION
WHEN OTHERS
  THEN
    log_message('5750: ERROR in mass_update');
    raise;

END mass_update;


-------------------------------------------------------------------------------
--              update_ei
-------------------------------------------------------------------------------
PROCEDURE update_ei(p_upd_type IN VARCHAR2) IS
BEGIN

set_curr_function('update_ei');
IF P_DEBUG_MODE = 'Y' THEN
   log_message('5800: Entered update_ei');
END IF;

-- Mark current EI as rejected
IF p_upd_type = 'R'
THEN
  IF P_DEBUG_MODE = 'Y' THEN
     log_message('update_ei: ' || '5850: Rejected EI');
  END IF;
  g_eicnt                             := g_eicnt + 1;
  g_ei_rec(g_eicnt).EiRowId           := lcur.EIRowId;
  g_ei_rec(g_eicnt).upd_type          := 'R';
  g_ei_rec(g_eicnt).cc_rejection_code := lcur.cc_rejection_code;

-- IF all fields need updating with current values
ELSIF p_upd_type = 'A'
THEN
  IF P_DEBUG_MODE = 'Y' THEN
     log_message('update_ei: ' || '5900: Update with current values');
  END IF;
  g_eicnt                                  := g_eicnt + 1;
  g_ei_rec(g_eicnt).EiRowId                := lcur.EIRowId;
  g_ei_rec(g_eicnt).upd_type               := 'A';
  g_ei_rec(g_eicnt).acct_tp_exchange_rate  := lcur.acct_tp_exchange_rate;
  g_ei_rec(g_eicnt).acct_tp_rate_date      := lcur.acct_tp_rate_date;
  g_ei_rec(g_eicnt).acct_tp_rate_type      := lcur.acct_tp_rate_type;
  g_ei_rec(g_eicnt).amount                 := lcur.amount;
  g_ei_rec(g_eicnt).bill_markup_percentage := lcur.bill_markup_percentage;
  g_ei_rec(g_eicnt).bill_rate              := lcur.bill_rate;
  g_ei_rec(g_eicnt).denom_tp_currency_code := lcur.denom_tp_currency_code;
  g_ei_rec(g_eicnt).denom_transfer_price   := lcur.denom_transfer_price;
  g_ei_rec(g_eicnt).ind_compiled_set_id    := lcur.ind_compiled_set_id;
  g_ei_rec(g_eicnt).markup_calc_base_code  := lcur.markup_calc_base_code;
  g_ei_rec(g_eicnt).rule_percentage        := lcur.rule_percentage;
  g_ei_rec(g_eicnt).tp_base_amount         := lcur.tp_base_amount;
  g_ei_rec(g_eicnt).tp_job_id              := lcur.tp_job_id;
  g_ei_rec(g_eicnt).schedule_line_percentage :=
			      lcur.schedule_line_percentage;
/* Added for cross proj*/
  g_ei_rec(g_eicnt).tp_amt_type_code      :=lcur.tp_amt_type_code;
  g_ei_rec(g_eicnt).project_tp_rate_type  :=lcur.project_tp_rate_type;
  g_ei_rec(g_eicnt).project_tp_rate_date  :=lcur.project_tp_rate_date;
  g_ei_rec(g_eicnt).project_tp_exchange_rate:=lcur.project_tp_exchange_rate;
  g_ei_rec(g_eicnt).project_transfer_price:=lcur.project_transfer_price;
  g_ei_rec(g_eicnt).projfunc_tp_rate_type :=lcur.projfunc_tp_rate_type;
  g_ei_rec(g_eicnt).projfunc_tp_rate_date :=lcur.projfunc_tp_rate_date;
g_ei_rec(g_eicnt).projfunc_tp_exchange_rate := lcur.projfunc_tp_exchange_rate;
  g_ei_rec(g_eicnt).projfunc_transfer_price:= lcur.projfunc_transfer_price;

  g_ei_rec(g_eicnt).project_tp_currency_code:= lcur.project_tp_currency_code;
  g_ei_rec(g_eicnt).projfunc_tp_currency_code:= lcur.projfunc_tp_currency_code;
/* End for cross proj*/


-- Update EI with reversed amounts
ELSIF p_upd_type = 'N'
THEN

  IF P_DEBUG_MODE = 'Y' THEN
     log_message('update_ei: ' || '5950: Update EI with reversed amounts');
  END IF;
  g_eicnt                                  := g_eicnt + 1;
  g_ei_rec(g_eicnt).EiRowId                := lcur.EIRowId;
  g_ei_rec(g_eicnt).upd_type               := 'N';

-- Reverse amounts and copy other attributes
  g_ei_rec(g_eicnt).amount                 :=  -maxrec.amount;
  g_ei_rec(g_eicnt).denom_transfer_price   :=  -maxrec.denom_transfer_price;
  g_ei_rec(g_eicnt).tp_base_amount         :=  -maxrec.tp_base_amount;
  g_ei_rec(g_eicnt).acct_tp_exchange_rate  := maxrec.acct_tp_exchange_rate;
  g_ei_rec(g_eicnt).acct_tp_rate_date      := maxrec.acct_tp_rate_date;
  g_ei_rec(g_eicnt).acct_tp_rate_type      := maxrec.acct_tp_rate_type;
  g_ei_rec(g_eicnt).bill_markup_percentage := maxrec.bill_markup_percentage;
  g_ei_rec(g_eicnt).bill_rate              := maxrec.bill_rate;
  g_ei_rec(g_eicnt).denom_tp_currency_code := maxrec.denom_tp_currency_code;
  g_ei_rec(g_eicnt).ind_compiled_set_id    := maxrec.ind_compiled_set_id;
  g_ei_rec(g_eicnt).markup_calc_base_code  := maxrec.markup_calc_base_code;
  g_ei_rec(g_eicnt).rule_percentage        := maxrec.rule_percentage;
  g_ei_rec(g_eicnt).schedule_line_percentage :=
			      maxrec.schedule_line_percentage;
  g_ei_rec(g_eicnt).tp_job_id              :=  maxrec.tp_job_id;
/* Added for cross proj*/
  g_ei_rec(g_eicnt).tp_amt_type_code      :=maxrec.tp_amt_type_code;
  g_ei_rec(g_eicnt).project_tp_rate_type  :=maxrec.project_tp_rate_type;
  g_ei_rec(g_eicnt).project_tp_rate_date  :=maxrec.project_tp_rate_date;
  g_ei_rec(g_eicnt).project_tp_exchange_rate:=maxrec.project_tp_exchange_rate;
  g_ei_rec(g_eicnt).project_transfer_price:=(-1)*maxrec.project_transfer_price;
  g_ei_rec(g_eicnt).projfunc_tp_rate_type :=maxrec.projfunc_tp_rate_type;
  g_ei_rec(g_eicnt).projfunc_tp_rate_date :=maxrec.projfunc_tp_rate_date;
  g_ei_rec(g_eicnt).projfunc_tp_exchange_rate := maxrec.projfunc_tp_exchange_rate;
  g_ei_rec(g_eicnt).projfunc_transfer_price:=(-1)* maxrec.projfunc_transfer_price;

  g_ei_rec(g_eicnt).project_tp_currency_code := maxrec.project_tp_currency_code;
  g_ei_rec(g_eicnt).projfunc_tp_currency_code
					    := maxrec.projfunc_tp_currency_code;
/* End for cross proj*/

-- Null out the attributes on the reversed EI (in this case the
-- corresponding distribution on the original EI is deleted)
-- Also null out attributes of current EI
ELSIF p_upd_type = 'G'
THEN

-- Make sure the attributes on the current EI are marked for nulling out
  IF P_DEBUG_MODE = 'Y' THEN
     log_message('update_ei: ' || '6000: Null out current EI');
  END IF;
  g_eicnt                                  := g_eicnt + 1;
  g_ei_rec(g_eicnt).EiRowId                := lcur.EIRowId;
  g_ei_rec(g_eicnt).upd_type               := 'G';

-- Also null out the attributes on the reversed EI
-- The mass update for EI works on the rowid of the EI. Since the
-- rowid of the adjusting EI is not known, it is read here and
-- populated into the array. This is not a big performance hit as this
-- is a rare case

  IF P_DEBUG_MODE = 'Y' THEN
     log_message('update_ei: ' || '6050: Null out reversed EI');
  END IF;
  g_eicnt                                  := g_eicnt + 1;
  g_ei_rec(g_eicnt).upd_type               := 'G';

  SELECT rowid
    INTO g_ei_rec(g_eicnt).EIRowId
    FROM pa_expenditure_items_all  -- _ALL table used for better performance
  WHERE expenditure_item_id = lcur.adjusted_exp_item_id;

  IF P_DEBUG_MODE = 'Y' THEN
     log_message('update_ei: ' || '6100: Successfully got rowid of reversed EI');
  END IF;

-- Otherwise update EI as processed without any changes to existing
-- values
ELSE

  IF P_DEBUG_MODE = 'Y' THEN
     log_message('update_ei: ' || '6150: No change to current EI attributes');
  END IF;
  g_eicnt                                  := g_eicnt + 1;
  g_ei_rec(g_eicnt).EiRowId                := lcur.EIRowId;
  g_ei_rec(g_eicnt).upd_type               := 'X'; /* bug2438805 changed assignment from 'G' to 'X'*/

END IF;

IF P_DEBUG_MODE = 'Y' THEN
   log_message('6200: Leaving update_ei');
END IF;

reset_curr_function;

EXCEPTION
WHEN OTHERS
  THEN
     IF P_DEBUG_MODE = 'Y' THEN
        log_message('6250: ERROR in update_ei');
     END IF;
     raise;

END update_ei;

-------------------------------------------------------------------------------
--              ei_mass_update
-------------------------------------------------------------------------------
PROCEDURE ei_mass_update IS
i  PLS_INTEGER;
BEGIN

set_curr_function('ei_mass_update');
log_message('6300: Entered ei_mass_update');

log_message('6350: Rows to EI mass update: ' ||to_char(g_eicnt));

FOR i in 1..g_eicnt
LOOP

  in_RowId(i)                 := g_ei_rec(i).EIRowid;

-- The g_ei_rec.upd_type variable tells this routine about the fields
-- that need to be updated. For upd_type with 'A' or 'N', all fields
-- need to be updated. For upd_types of 'G', the values should be set
-- to NULL while for upd_types of 'X' or 'R', the values should be
-- untouched. When the EI value is left untouched, the corresponding
-- in_ variables are still to be initialized (to NULL) to avoid
-- runtime errors. The g_ei_rec.upd_type is mapped to two
-- in_rec.upd_types depending on the operation to be performed. The
-- operations are either to update with the values in the in_ array or
-- leave them untouched. For 'X' and 'R' the values are left untouched
-- while for 'A', 'N' and 'G', the values on the EI are updated from
-- the values in the in_ array

  IF g_ei_rec(i).upd_type in ('A', 'N')
  THEN
    in_upd_type(i)                 := 'U';
    in_acct_tp_exchange_rate(i)    := g_ei_rec(i).acct_tp_exchange_rate;
    in_acct_tp_rate_date(i)        := g_ei_rec(i).acct_tp_rate_date;
    in_acct_tp_rate_type(i)        := g_ei_rec(i).acct_tp_rate_type;
    in_amount(i)                   := g_ei_rec(i).amount;
    in_bill_markup_percentage(i)   := g_ei_rec(i).bill_markup_percentage;
    in_bill_rate(i)                := g_ei_rec(i).bill_rate;
    in_cc_rejection_code(i)        := NULL;
    in_denom_tp_currency_code(i)   := g_ei_rec(i).denom_tp_currency_code;
    in_denom_transfer_price(i)     := g_ei_rec(i).denom_transfer_price;
    in_ind_compiled_set_id(i)      := g_ei_rec(i).ind_compiled_set_id;
    in_markup_calc_base_code(i)    := g_ei_rec(i).markup_calc_base_code;
    in_rule_percentage(i)          := g_ei_rec(i).rule_percentage;
    in_tp_base_amount(i)           := g_ei_rec(i).tp_base_amount;
    in_tp_job_id(i)                := g_ei_rec(i).tp_job_id;
    in_schedule_line_percentage(i) := g_ei_rec(i).schedule_line_percentage;
  /* Added for cross proj*/
  in_tp_amt_type_code(i)         := g_ei_rec(i).tp_amt_type_code;
  in_project_tp_rate_type(i)     := g_ei_rec(i).project_tp_rate_type;
  in_project_tp_rate_date(i)     := g_ei_rec(i).project_tp_rate_date;
  in_project_tp_exchange_rate(i) := g_ei_rec(i).project_tp_exchange_rate;
  in_project_transfer_price(i)   := g_ei_rec(i).project_transfer_price;
  in_projfunc_tp_rate_type(i)    := g_ei_rec(i).projfunc_tp_rate_type;
  in_projfunc_tp_rate_date(i)    := g_ei_rec(i).projfunc_tp_rate_date;
  in_projfunc_tp_exchange_rate(i):= g_ei_rec(i).projfunc_tp_exchange_rate;
  in_projfunc_transfer_price(i)  := g_ei_rec(i).projfunc_transfer_price;
  in_project_tp_currency_code(i)  := g_ei_rec(i).project_tp_currency_code;
  in_projfunc_tp_currency_code(i)  := g_ei_rec(i).projfunc_tp_currency_code;

  /* End for cross proj*/
  ELSE
    IF g_ei_rec(i).upd_type = 'G'
    THEN
       in_upd_type(i) := 'U'; -- Update EI but use null values
    ELSE
       in_upd_type(i) := 'X'; -- Do not update attributes on EI
    END IF;

-- Nullify attributes, either for the purpose of initializing them so
-- that the UPDATE statement does not bomb when they are not used or
-- for the purose of actually updating the EI with null values

    in_acct_tp_exchange_rate(i)    := NULL;
    in_acct_tp_rate_date(i)        := NULL;
    in_acct_tp_rate_type(i)        := NULL;
    in_amount(i)                   := NULL;
    in_bill_markup_percentage(i)   := NULL;
    in_bill_rate(i)                := NULL;
    in_denom_tp_currency_code(i)   := NULL;
    in_denom_transfer_price(i)     := NULL;
    in_ind_compiled_set_id(i)      := NULL;
    in_markup_calc_base_code(i)    := NULL;
    in_rule_percentage(i)          := NULL;
    in_tp_base_amount(i)           := NULL;
    in_tp_job_id(i)                := NULL;
    in_schedule_line_percentage(i) := NULL;
/* Moved this code here from if condition mentioned below */
    in_tp_amt_type_code(i)      :=NULL;
    in_project_tp_rate_type(i)  :=NULL;
    in_project_tp_rate_date(i)  :=NULL;
    in_project_tp_exchange_rate(i):=NULL;
    in_project_transfer_price(i):=NULL;
    in_projfunc_tp_rate_type(i) :=NULL;
    in_projfunc_tp_rate_date(i) :=NULL;
    in_projfunc_tp_exchange_rate(i) := NULL;
    in_projfunc_transfer_price(i):= NULL;

    in_project_tp_currency_code(i):= NULL;
    in_projfunc_tp_currency_code(i):= NULL;
/* End of code addition for bug 2438805 */
  END IF;

-- Set the rejecton code for rejected transactions
  IF g_ei_rec(i).upd_type = 'R'
  THEN
     in_cc_rejection_code(i) := g_ei_rec(i).cc_rejection_code;
/* Added for cross proj and added for bug 2165410 */
/*** Commented this code and moved it to else part of earlier if condition
 ***in_tp_amt_type_code(i)      :=NULL;
 ***in_project_tp_rate_type(i)  :=NULL;
 ***in_project_tp_rate_date(i)  :=NULL;
 ***in_project_tp_exchange_rate(i):=NULL;
 ***in_project_transfer_price(i):=NULL;
 ***in_projfunc_tp_rate_type(i) :=NULL;
 ***in_projfunc_tp_rate_date(i) :=NULL;
 ***in_projfunc_tp_exchange_rate(i) := NULL;
 ***in_projfunc_transfer_price(i):= NULL;

 ***in_project_tp_currency_code(i):= NULL;
 ***in_projfunc_tp_currency_code(i):= NULL;
 *** end of comment Bug 2438805 */
/* End for cross proj and end for bug 2165410*/
  ELSE
     in_cc_rejection_code(i) := NULL;
  END IF;

 END LOOP;

-- Update all records
-- Set cc_bl_distributed_code = 'N' if there is a rejection.
-- Otherwise, set it to 'Y' if the cross_charge_code = 'B', 'X'
-- otherwise.

  log_message('6400: About to perform mass_update' );

IF g_eicnt > 0
THEN
  FORALL i in 1..g_eicnt

  UPDATE pa_expenditure_items_all  --_All table for better performance
     SET
     cc_rejection_code = in_cc_rejection_code(i),
     cc_bl_distributed_code = decode(in_cc_rejection_code(i), NULL,
	       decode(cc_cross_charge_code, 'B', 'Y', 'X'), 'N'),
    acct_tp_exchange_rate =
       decode(in_upd_type(i), 'U',
         in_acct_tp_exchange_rate(i), acct_tp_exchange_rate),
    acct_tp_rate_date =
       decode(in_upd_type(i), 'U',
          in_acct_tp_rate_date(i), acct_tp_rate_date),
    acct_tp_rate_type =
       decode(in_upd_type(i), 'U',
         in_acct_tp_rate_type(i), acct_tp_rate_type),
    acct_transfer_price =
       decode(in_upd_type(i), 'U',
         in_amount(i), acct_transfer_price),
    tp_bill_markup_percentage =
       decode(in_upd_type(i), 'U',
         in_bill_markup_percentage(i), tp_bill_markup_percentage),
    tp_bill_rate =
       decode(in_upd_type(i), 'U',
         in_bill_rate(i), tp_bill_rate),
    denom_tp_currency_code =
       decode(in_upd_type(i), 'U',
         in_denom_tp_currency_code(i), denom_tp_currency_code),
    denom_transfer_price =
       decode(in_upd_type(i), 'U',
         in_denom_transfer_price(i), denom_transfer_price),
    tp_ind_compiled_set_id =
       decode(in_upd_type(i), 'U',
         in_ind_compiled_set_id(i), tp_ind_compiled_set_id),
    cc_markup_base_code =
       decode(in_upd_type(i), 'U',
         in_markup_calc_base_code(i), cc_markup_base_code),
    tp_rule_percentage =
       decode(in_upd_type(i), 'U',
         in_rule_percentage(i), tp_rule_percentage),
    tp_base_amount =
       decode(in_upd_type(i), 'U',
         in_tp_base_amount(i), tp_base_amount),
    tp_job_id =
       decode(in_upd_type(i), 'U',
         in_tp_job_id(i), tp_job_id),
    tp_schedule_line_percentage =
       decode(in_upd_type(i), 'U',
         in_schedule_line_percentage(i), tp_schedule_line_percentage),
  /*Added Cross proj*/
    project_tp_rate_type   =  decode(in_upd_type(i), 'U',
	  in_project_tp_rate_type(i),project_tp_rate_type),
    project_tp_rate_date   =  decode(in_upd_type(i), 'U',
	  in_project_tp_rate_date(i),project_tp_rate_date),
    project_tp_exchange_rate=   decode(in_upd_type(i), 'U',
	  in_project_tp_exchange_rate(i),project_tp_exchange_rate),
    project_transfer_price  =   decode(in_upd_type(i), 'U',
	  in_project_transfer_price(i),project_transfer_price),
    projfunc_tp_rate_type   =   decode(in_upd_type(i), 'U',
	  in_projfunc_tp_rate_type(i),projfunc_tp_rate_type),
    projfunc_tp_rate_date   =   decode(in_upd_type(i), 'U',
	  in_projfunc_tp_rate_date(i),projfunc_tp_rate_date),
    projfunc_tp_exchange_rate=   decode(in_upd_type(i), 'U',
	  (in_projfunc_tp_exchange_rate(i)),projfunc_tp_exchange_rate),
    projfunc_transfer_price  =   decode(in_upd_type(i), 'U',
	  in_projfunc_transfer_price(i),projfunc_transfer_price),
  /*End Cross proj*/
     last_updated_by             = pa_cc_utils.g_user_id,
     last_update_login           = pa_cc_utils.g_login_id,
     last_update_date            = sysdate,
     request_id                  = pa_cc_utils.g_request_id,
     program_application_id      = pa_cc_utils.g_program_application_id,
     program_id                  = pa_cc_utils.g_program_id,
     program_update_date         = sysdate
  WHERE rowid = in_RowId(i);

  log_message('6450: -- Rows updated = ' || to_char(sql%ROWCOUNT));

END IF;

  clean_tables;

-- Clean up array
  g_ei_rec.delete;

  log_message('6500: Leaving ei_mass_update');


reset_curr_function;

EXCEPTION

WHEN OTHERS
 THEN
   log_message('6550: ERROR in ei_mass_update');
   raise;

END ei_mass_update;

-------------------------------------------------------------------------------
--              log_message
-------------------------------------------------------------------------------

PROCEDURE log_message( p_message IN VARCHAR2) IS
BEGIN

  IF P_DEBUG_MODE = 'Y' THEN
     pa_cc_utils.log_message('log_message: ' || p_message);
  END IF;

END log_message;

-------------------------------------------------------------------------------
--              set_curr_function
-------------------------------------------------------------------------------

PROCEDURE set_curr_function(p_function IN VARCHAR2) IS
BEGIN

   pa_cc_utils.set_curr_function(p_function);

END;

-------------------------------------------------------------------------------
--              reset_curr_function
-------------------------------------------------------------------------------

PROCEDURE reset_curr_function IS
BEGIN

   pa_cc_utils.reset_curr_function;

END;


END pa_cc_bl_process;

/
