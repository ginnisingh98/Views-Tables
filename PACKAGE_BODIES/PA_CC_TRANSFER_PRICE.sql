--------------------------------------------------------
--  DDL for Package Body PA_CC_TRANSFER_PRICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CC_TRANSFER_PRICE" AS
/*  $Header: PAXCCTPB.pls 120.13.12010000.5 2009/02/16 10:41:27 amehrotr ship $ */

-------------------------------------------------------------------------------
-- Define global variables
/** Added for Org Forecasting **/

  G_prvdr_org_id_Tab                PA_PLSQL_DATATYPES.IdTabTyp;
  G_bg_id_Tab                       PA_PLSQL_DATATYPES.IdTabTyp;
  G_acct_currency_code_Tab          PA_PLSQL_DATATYPES.Char15TabTyp;
  G_cc_default_rate_type_Tab        PA_PLSQL_DATATYPES.Char15TabTyp;
  G_cc_def_rate_date_code_Tab       PA_PLSQL_DATATYPES.Char15TabTyp;
  G_exp_org_struct_ver_tab          PA_PLSQL_DATATYPES.IdTabTyp;
  G_Calling_Module                  VARCHAR2(30);
/** End for Org Forecasting   **/

  G_prvdr_org_id		NUMBER;
  G_bg_id			NUMBER;
  G_prvdr_legal_entity_id	NUMBER;
  G_acct_currency_code		VARCHAR2(15);
  G_cc_default_rate_type 	VARCHAR2(30);
  G_cc_default_rate_date_code 	VARCHAR2(1);
  G_processed_thru_date		DATE;
  G_array_size			Number;
  G_Basis_Exists		Boolean;
  G_Bill_Rate_Exists		Boolean;
  G_Burden_Rate_Exists		Boolean;
  G_global_access             varchar2(1):= pa_cross_business_grp.IsCrossBGProfile;

--DevDrop2 Changes
--Added org_struct variables.

  G_exp_org_struct_ver_id       Number;
  G_prj_org_struct_ver_id       Number;

  G_prev_rcvr_org_id            Number := -999999 ;

-- Define WHO columns
  G_created_by			Number;
  G_last_updated_by		Number;
  G_last_update_login		Number;
  G_creation_date		Date;
  G_last_update_date		Date;
  G_sysdate			Date := sysdate;
-------------------------------------------------------------------------------

g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

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
        x_proj_tp_rate_type      IN OUT NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
        x_proj_tp_rate_date      IN OUT NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
        x_proj_tp_exchange_rate  IN OUT NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
        x_proj_transfer_price    IN OUT NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
--
        x_projfunc_tp_rate_type  IN OUT NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
        x_projfunc_tp_rate_date  IN OUT NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
        x_projfunc_tp_exchange_rate      IN OUT NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
        x_projfunc_transfer_price        IN OUT NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
--End   Added for devdrop2
	x_denom_tp_currency_code IN OUT	NOCOPY  PA_PLSQL_DATATYPES.Char15TabTyp,
	x_denom_transfer_price	 IN OUT	NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
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
        x_tp_job_id               IN OUT  NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
	x_error_code	          IN OUT  NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
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

        )
IS

l_processed_thru_date      Date;
l_expenditure_item_date    PA_PLSQL_DATATYPES.DateTabTyp;
l_fixed_date               PA_PLSQL_DATATYPES.DateTabTyp;
l_denom_raw_cost_amount	   PA_PLSQL_DATATYPES.NumTabTyp;
l_denom_burdened_cost_amount PA_PLSQL_DATATYPES.NumTabTyp;
l_raw_revenue_amount       PA_PLSQL_DATATYPES.NumTabTyp;
l_quantity                 PA_PLSQL_DATATYPES.NumTabTyp;
l_pa_date		   PA_PLSQL_DATATYPES.DateTabTyp;
l_denom_transfer_price	   PA_PLSQL_DATATYPES.NumTabTyp;
l_acct_tp_rate_date	   PA_PLSQL_DATATYPES.DateTabTyp;
l_acct_tp_exchange_rate	   PA_PLSQL_DATATYPES.NumTabTyp;
l_acct_transfer_price	   PA_PLSQL_DATATYPES.NumTabTyp;
l_tp_bill_rate		   PA_PLSQL_DATATYPES.NumTabTyp;
l_tp_base_amount	   PA_PLSQL_DATATYPES.NumTabTyp;
l_tp_bill_markup_percentage PA_PLSQL_DATATYPES.NumTabTyp;
l_tp_schedule_line_percentage PA_PLSQL_DATATYPES.NumTabTyp;
p_prvdr_operating_unit       PA_PLSQL_DATATYPES.IdTabTyp; /*Bug 2438805 */
l_tp_rule_percentage         PA_PLSQL_DATATYPES.NumTabTyp;
v_denom_transfer_price     Number;
l_return_status            Number;

/*Bill rate Discount*/
l_labor_schdl_fixed_date   PA_PLSQL_DATATYPES.DateTabTyp;
l_nl_task_sch_date         PA_PLSQL_DATATYPES.DateTabTyp;
l_nl_proj_sch_date         PA_PLSQL_DATATYPES.DateTabTyp;
l_raw_cost                 PA_PLSQL_DATATYPES.NumTabTyp;
l_burden_cost             PA_PLSQL_DATATYPES.NumTabTyp;
l_bill_rate_multiplier    PA_PLSQL_DATATYPES.NumTabTyp;
l_raw_cost_rate           PA_PLSQL_DATATYPES.NumTabTyp;
l_exp_raw_cost            PA_PLSQL_DATATYPES.NumTabTyp;

--Start Added for devdrop2
l_proj_tp_rate_date      PA_PLSQL_DATATYPES.DateTabTyp;
l_proj_tp_exchange_rate  PA_PLSQL_DATATYPES.NumTabTyp;
l_proj_transfer_price    PA_PLSQL_DATATYPES.NumTabTyp;
--
l_projfunc_tp_rate_date          PA_PLSQL_DATATYPES.DateTabTyp;
l_projfunc_tp_exchange_rate      PA_PLSQL_DATATYPES.NumTabTyp;
l_projfunc_transfer_price        PA_PLSQL_DATATYPES.NumTabTyp;

--End   Added for devdrop2

BEGIN

-- Convert the data

   pa_debug.set_err_stack ('Get_Transfer_Price_Wrapper');
   pa_debug.set_process(
	    x_process => 'PLSQL',
	    x_debug_mode => p_debug_mode);

   pa_debug.G_Err_Stage := 'Starting Get_Transfer_Price wrapper';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;
   pa_debug.G_Err_Stage :=
    'Transfer Price API Start Date and Time is '
				  ||to_char(sysdate,'DD-MON-YYYY:HH24-MI-SS');
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;
   pa_debug.G_Err_Stage :=
   '--------------------------------------------------------------------------';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

   For i IN 1..p_array_size
   LOOP

         l_expenditure_item_date(i) := to_date(p_expenditure_item_date(i),'YYYY/MM/DD'); /*File.Date.5*/
         l_fixed_date(i) := to_date(p_tp_fixed_date(i),'YYYY/MM/DD');  /*file.Date.5*/

	 IF p_pa_date.exists(i) THEN
            l_pa_date(i) := to_date(p_pa_date(i),'YYYY/MM/DD');  /*File.Date.5*/
         ELSE
	    l_pa_date(i) := null;
         END IF;

	IF (not (x_denom_tp_currency_code.exists(i))) THEN
           x_denom_tp_currency_code(i) := null;
        END IF;
	IF (not (x_acct_tp_rate_type.exists(i))) THEN
	    x_acct_tp_rate_type(i) := null ;
        END IF;
	IF (not (x_cc_markup_base_code.exists(i))) THEN
	   x_cc_markup_base_code(i) := null;
        END IF;

	IF (not (x_tp_ind_compiled_set_id.exists(i))) THEN
	   x_tp_ind_compiled_set_id (i) := null;
        END IF;

	IF (not (x_error_code.exists(i))) THEN
	    x_error_code(i) := null;
        END IF;

         IF (x_acct_tp_rate_date.exists(i)) THEN
            l_acct_tp_rate_date(i) := to_date (x_acct_tp_rate_date(i),'YYYY/MM/DD');  /*File.Date.5*/
         ELSE
	    l_acct_tp_rate_date(i) := null;
         END IF;

/*BIll rate discount*/
         l_raw_cost(i)               := to_number(p_raw_cost(i));
         l_burden_cost(i)            := to_number(p_burden_cost(i));
         l_bill_rate_multiplier(i)   := to_number(p_bill_rate_multiplier(i));
         l_raw_cost_rate(i)          := to_number(p_raw_cost_rate(i));
         l_exp_raw_cost(i)           := to_number(p_exp_raw_cost(i));

         IF (p_labor_schdl_fixed_date.exists(i)) THEN
            l_labor_schdl_fixed_date(i) := to_date (p_labor_schdl_fixed_date(i),'YYYY/MM/DD');/*File.Date.5*/
         ELSE
	    l_labor_schdl_fixed_date(i) := null;
         END IF;

         IF (l_nl_task_sch_date.exists(i)) THEN
            l_nl_task_sch_date(i) := to_date (l_nl_task_sch_date(i),'YYYY/MM/DD');/*File.Date.5*/
         ELSE
	    l_nl_task_sch_date(i) := null;
         END IF;

         IF (l_nl_proj_sch_date.exists(i)) THEN
            l_nl_proj_sch_date(i) := to_date (l_nl_proj_sch_date(i),'YYYY/MM/DD');/*File.Date.5*/
         ELSE
	    l_nl_proj_sch_date(i) := null;
         END IF;


         l_denom_raw_cost_amount (i) := to_number(p_denom_raw_cost_amount(i));

         l_denom_burdened_cost_amount(i) :=
				to_number((p_denom_burdened_cost_amount(i)));

         l_raw_revenue_amount(i) := to_number(p_raw_revenue_amount(i));
         l_quantity(i) := to_number(p_quantity(i));

	 IF x_denom_transfer_price.exists(i) THEN
            l_denom_transfer_price(i) := to_number(x_denom_transfer_price(i));
         ELSE
	    l_denom_transfer_price(i) := null;
         END IF;

	 IF (x_acct_tp_exchange_rate.exists(i)) THEN
            l_acct_tp_exchange_rate(i) := to_number(x_acct_tp_exchange_rate(i));
         ELSE
	    l_acct_tp_exchange_rate(i) := null;
         END IF;

         IF (x_acct_transfer_price.exists(i)) THEN
            l_acct_transfer_price (i) := to_number((x_acct_transfer_price(i)));
         ELSE
	    l_acct_transfer_price(i) := null;
         END IF;

         IF (x_tp_bill_rate.exists(i)) THEN
             l_tp_bill_rate(i) := to_number(x_tp_bill_rate(i));
         ELSE
	    l_tp_bill_rate(i) := null;
         END IF;

         IF (x_tp_base_amount.exists(i)) THEN
             l_tp_base_amount (i):= to_number(x_tp_base_amount(i));
         ELSE
             l_tp_base_amount (i):= null;
         END IF;

         IF (x_tp_bill_markup_percentage.exists(i)) THEN
	     l_tp_bill_markup_percentage(i) :=
			      to_number(x_tp_bill_markup_percentage(i));
         ELSE
	     l_tp_bill_markup_percentage(i) := null;
         END IF;

	 IF (x_tp_schedule_line_percentage.exists(i)) THEN
             l_tp_schedule_line_percentage(i) :=
	              to_number (x_tp_schedule_line_percentage(i));
         ELSE
             l_tp_schedule_line_percentage(i) := null;
         END IF;

         IF (x_tp_rule_percentage.exists(i)) THEN
            l_tp_rule_percentage (i) := to_number(x_tp_rule_percentage(i));
         ELSE
            l_tp_rule_percentage (i) := null;
         END IF;

--Start   Added for devdrop2

         IF (x_proj_tp_rate_date.exists(i)) THEN
            l_proj_tp_rate_date (i) := to_date(x_proj_tp_rate_date(i),'YYYY/MM/DD');/*File.Date.5*/
         ELSE
            l_proj_tp_rate_date (i) := null;
         END IF;

         IF (x_proj_tp_exchange_rate.exists(i)) THEN
            l_proj_tp_exchange_rate (i) := to_number(x_proj_tp_exchange_rate(i));
         ELSE
            l_proj_tp_exchange_rate (i) := null;
         END IF;

         IF (x_proj_transfer_price.exists(i)) THEN
            l_proj_transfer_price (i) := to_number(x_proj_transfer_price(i));
         ELSE
            l_proj_transfer_price (i) := null;
         END IF;


         IF (x_projfunc_tp_rate_date.exists(i)) THEN
            l_projfunc_tp_rate_date (i) := to_date(x_projfunc_tp_rate_date(i),'YYYY/MM/DD');/*File.Date.5*/
         ELSE
            l_projfunc_tp_rate_date (i) := null;
         END IF;

         IF (x_projfunc_tp_exchange_rate.exists(i)) THEN
            l_projfunc_tp_exchange_rate (i) := to_number(x_projfunc_tp_exchange_rate(i));
         ELSE
            l_projfunc_tp_exchange_rate (i) := null;
         END IF;

         IF (x_projfunc_transfer_price.exists(i)) THEN
            l_projfunc_transfer_price (i) := to_number(x_projfunc_transfer_price(i));
         ELSE
            l_projfunc_transfer_price (i) := null;
         END IF;

         p_prvdr_operating_unit(i) :=NULL; /* Bug 2438805 */

-- Log Information :

   IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG','----------------------------------------------------');
         pa_debug.write_file('LOG','p_expenditure_item_id '||p_expenditure_item_id(i));
         pa_debug.write_file('LOG','x_proj_tp_rate_type '||x_proj_tp_rate_type(i));
         pa_debug.write_file('LOG','x_proj_tp_rate_date '||x_proj_tp_rate_date(i));
         pa_debug.write_file('LOG','x_proj_tp_exchange_rate '||x_proj_tp_exchange_rate(i));
         pa_debug.write_file('LOG','x_projfunc_tp_rate_type '||x_projfunc_tp_rate_type(i));
         pa_debug.write_file('LOG','x_projfunc_tp_rate_date '||x_projfunc_tp_rate_date(i));
         pa_debug.write_file('LOG','x_projfunc_tp_exchange_rate '||x_proj_tp_rate_type(i));
         pa_debug.write_file('LOG','x_acct_tp_rate_type '||x_acct_tp_rate_type(i));
         pa_debug.write_file('LOG','x_acct_tp_rate_date '||x_acct_tp_rate_date(i));
         pa_debug.write_file('LOG','x_acct_tp_exchange_rate '||x_acct_tp_exchange_rate(i));

         pa_debug.write_file('LOG','p_project_currency_code '||p_project_currency_code(i));
         pa_debug.write_file('LOG','p_projfunc_currency_code '||p_projfunc_currency_code(i));
         pa_debug.write_file('LOG','x_denom_tp_currency_code '||x_denom_tp_currency_code(i));
   END IF;

--End   Added for devdrop2

   END LOOP;

   pa_debug.G_Err_Stage := 'Calling actual Transfer Price API';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

   Get_Transfer_Price (
	p_module_name => p_module_name,
 	p_prvdr_organization_id => p_prvdr_organization_id,
        p_recvr_org_id => p_recvr_org_id,
        p_recvr_organization_id => p_recvr_organization_id,
        p_expnd_organization_id => p_expnd_organization_id,
        p_expenditure_item_id => p_expenditure_item_id,
        p_expenditure_type => p_expenditure_type,
	p_expenditure_category => p_expenditure_category,
	p_expenditure_item_date => l_expenditure_item_date,
	p_labor_non_labor_flag => p_labor_non_labor_flag,
	p_system_linkage_function => p_system_linkage_function,
	p_task_id => p_task_id,
	p_tp_schedule_id => p_tp_schedule_id,
	p_denom_currency_code => p_denom_currency_code,
	p_project_currency_code => p_project_currency_code,
--Start Added for devdrop2
        p_projfunc_currency_code  => p_projfunc_currency_code,
--End   Added for devdrop2
	p_revenue_distributed_flag => p_revenue_distributed_flag,
	p_processed_thru_date => p_processed_thru_date,
	p_compute_flag => p_compute_flag,
	p_tp_fixed_date => l_fixed_date,
	p_denom_raw_cost_amount => l_denom_raw_cost_amount,
	p_denom_burdened_cost_amount => l_denom_burdened_cost_amount,
	p_raw_revenue_amount => l_raw_revenue_amount,
	p_project_id => p_project_id,
	p_quantity => l_quantity,
	p_incurred_by_person_id => p_incurred_by_person_id,
	p_job_id => p_job_id,
	p_non_labor_resource => p_non_labor_resource,
	p_nl_resource_organization_id => p_nl_resource_organization_id,
	p_pa_date => l_pa_date,
	p_array_size => p_array_size,
	p_debug_mode => p_debug_mode,
--Start Added for devdrop2
        p_tp_amt_type_code    => p_tp_amt_type_code,
        p_assignment_id       => p_assignment_id,
        x_proj_tp_rate_type      => x_proj_tp_rate_type,
        x_proj_tp_rate_date      => l_proj_tp_rate_date,
        x_proj_tp_exchange_rate  => l_proj_tp_exchange_rate,
        x_proj_transfer_price    => l_proj_transfer_price,
--
        x_projfunc_tp_rate_type  => x_projfunc_tp_rate_type,
        x_projfunc_tp_rate_date  => l_projfunc_tp_rate_date,
        x_projfunc_tp_exchange_rate => l_projfunc_tp_exchange_rate,
        x_projfunc_transfer_price      => l_projfunc_transfer_price,
--End   Added for devdrop2
	x_denom_tp_currency_code => x_denom_tp_currency_code,
	x_denom_transfer_price => l_denom_transfer_price,
	x_acct_tp_rate_type => 	x_acct_tp_rate_type,
	x_acct_tp_rate_date => l_acct_tp_rate_date,
	x_acct_tp_exchange_rate => l_acct_tp_exchange_rate,
	x_acct_transfer_price => l_acct_transfer_price,
	x_cc_markup_base_code => x_cc_markup_base_code,
	x_tp_ind_compiled_set_id => x_tp_ind_compiled_set_id,
	x_tp_bill_rate => l_tp_bill_rate,
	x_tp_base_amount => l_tp_base_amount,
	x_tp_bill_markup_percentage => l_tp_bill_markup_percentage,
	x_tp_schedule_line_percentage => l_tp_schedule_line_percentage,
	x_tp_rule_percentage => l_tp_rule_percentage,
        x_tp_job_id =>x_tp_job_id   ,
        p_prvdr_operating_unit    =>      p_prvdr_operating_unit, /* Bug 2438805 */
	x_error_code => x_error_code,
        x_return_status => l_return_status,
/*Bill rate discount */
        p_dist_rule                     => p_dist_rule,
        p_mcb_flag                      => p_mcb_flag,
        p_bill_rate_multiplier          => l_bill_rate_multiplier,
        p_raw_cost                      => l_raw_cost,
        p_labor_schdl_discnt            => p_labor_schdl_discnt,
        p_labor_schdl_fixed_date        => l_labor_schdl_fixed_date,
        p_bill_job_grp_id               => p_bill_job_grp_id,
        p_labor_sch_type                => p_labor_sch_type,
        p_project_org_id                => p_project_org_id,
        p_project_type                  => p_project_type,
        p_exp_func_curr_code            => p_exp_func_curr_code,
        p_incurred_by_organz_id         => p_incurred_by_organz_id,
        p_raw_cost_rate                 => l_raw_cost_rate,
        p_override_to_organz_id         => p_override_to_organz_id,
        p_emp_bill_rate_schedule_id     => p_emp_bill_rate_schedule_id,
        p_job_bill_rate_schedule_id     => p_job_bill_rate_schedule_id,
        p_exp_raw_cost                  => l_exp_raw_cost,
        p_assignment_precedes_task      => p_assignment_precedes_task,

        p_burden_cost                   => l_burden_cost,
        p_task_nl_bill_rate_org_id      => p_task_nl_bill_rate_org_id,
        p_proj_nl_bill_rate_org_id      => p_proj_nl_bill_rate_org_id,
        p_task_nl_std_bill_rate_sch     => p_task_nl_std_bill_rate_sch,
        p_proj_nl_std_bill_rate_sch     => p_proj_nl_std_bill_rate_sch,
        p_nl_task_sch_date              => l_nl_task_sch_date,
        p_nl_proj_sch_date              => l_nl_proj_sch_date,
        p_nl_task_sch_discount          => p_nl_task_sch_discount,
        p_nl_proj_sch_discount          => p_nl_proj_sch_discount,
        p_nl_sch_type                   => p_nl_sch_type,
	p_task_nl_std_bill_rate_sch_id  => p_task_nl_std_bill_rate_sch_id,
	p_proj_nl_std_bill_rate_sch_id  => p_proj_nl_std_bill_rate_sch_id,
        p_uom_flag                      => p_uom_flag
	);


       --  Convert the number and dates to varchar2
        pa_debug.G_Err_Stage := 'Doing the data type Conversion ';
   	IF g1_debug_mode  = 'Y' THEN
        pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	END IF;
        For i in 1..p_array_size
	LOOP
              pa_debug.G_Err_Stage := 'Processing EI: '||
                                                p_expenditure_item_id(i);
   	      IF g1_debug_mode  = 'Y' THEN
              pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	      END IF;

              pa_debug.G_Err_Stage := 'Rejection Code: '|| x_error_code(i);
   	      IF g1_debug_mode  = 'Y' THEN
              pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	      END IF;

	      x_acct_tp_rate_date(i) := to_char(l_acct_tp_rate_date(i),'YYYY/MM/DD');/*File.Date.5*/

	      x_denom_transfer_price(i) := to_char(l_denom_transfer_price(i));
   	      IF g1_debug_mode  = 'Y' THEN
              pa_debug.write_file('LOG',
			       'Denom TP ='||x_denom_transfer_price(i));
   	      END IF;

              /** Bug# 1063619 : while converting the tp_exchange_rate
				 to char it was causing buffer overflow
				 because the number field was returning
				 value that had more than 30 characters */

              x_acct_tp_exchange_rate(i):=
		substr(to_char(l_acct_tp_exchange_rate(i)),1,30);
	      x_acct_transfer_price (i) := to_char(l_acct_transfer_price(i));
   	      IF g1_debug_mode  = 'Y' THEN
              pa_debug.write_file('LOG','Acct TP ='||x_acct_transfer_price(i));
   	      END IF;
	      x_tp_bill_rate (i) := to_char(l_tp_bill_rate (i));
	      x_tp_base_amount (i) := to_char(l_tp_base_amount(i));
	      x_tp_bill_markup_percentage (i) :=
				to_char(l_tp_bill_markup_percentage(i));
	      x_tp_schedule_line_percentage(i) :=
                              to_char (l_tp_schedule_line_percentage(i));
	      x_tp_rule_percentage(i) :=
                        to_char(l_tp_rule_percentage(i));

--Start   Added for devdrop2

   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG','------END OF THE PROCESS-----------------');
         pa_debug.write_file('LOG','l_expenditure_item_id   '||to_char(p_expenditure_item_id(i)));
         pa_debug.write_file('LOG','l_expenditure_item_date '||to_char(l_expenditure_item_date(i)));
         pa_debug.write_file('LOG','x_denom_tp_currency_code '||x_denom_tp_currency_code(i));
         pa_debug.write_file('LOG','l_proj_tp_rate_date '||to_char(l_proj_tp_rate_date(i)));
         pa_debug.write_file('LOG','l_proj_tp_exchange_rate '||to_char(l_proj_tp_exchange_rate(i)));
         pa_debug.write_file('LOG','l_proj_transfer_price '||to_char(l_proj_transfer_price(i)));
         pa_debug.write_file('LOG','l_projfunc_tp_rate_date '||to_char(l_projfunc_tp_rate_date(i)));
         pa_debug.write_file('LOG','l_projfunc_tp_exchange_rate '||to_char(l_projfunc_tp_exchange_rate(i)));
         pa_debug.write_file('LOG','l_projfunc_transfer_price '||to_char(l_projfunc_transfer_price(i)));
         pa_debug.write_file('LOG','-----------------------------------------');
   	END IF;

        x_proj_tp_rate_date(i)   := to_char(l_proj_tp_rate_date(i),'YYYY/MM/DD');
        x_proj_tp_exchange_rate(i)  :=  substr(to_char(l_proj_tp_exchange_rate(i)),1,30);
        x_proj_transfer_price(i)    := l_proj_transfer_price(i);
--
        x_projfunc_tp_rate_date(i)  := to_char(l_projfunc_tp_rate_date(i),'YYYY/MM/DD');
        x_projfunc_tp_exchange_rate(i) :=  substr(to_char(l_projfunc_tp_exchange_rate(i)),1,30);
        x_projfunc_transfer_price(i)      := to_char(l_projfunc_transfer_price(i));

--End   Added for devdrop2

              pa_debug.G_Err_Stage := 'Completing the loop';
   	      IF g1_debug_mode  = 'Y' THEN
              pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	      END IF;
	END LOOP;

        x_return_status := l_return_status;

   pa_debug.G_Err_Stage :=
    'Transfer Price API End Date and Time is '
				  ||to_char(sysdate,'DD-MON-YYYY:HH24-MI-SS');
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

END Get_Transfer_Price;


--------------------------------------------------------------------------------
  -- Procedure
  -- Get_Transfer_Price
  -- Purpose
  -- Called from Borrowed and Lent Process and IC Billing
  -- It calculates Transfer Price for Provider Cross Charge Process

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
	      p_prvdr_operating_unit          IN      PA_PLSQL_DATATYPES.IdTabTyp /** Added for Org Forecasting **/
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
	      x_tp_job_id               IN OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
		x_error_code		  IN OUT NOCOPY    PA_PLSQL_DATATYPES.Char30TabTyp,
		x_return_status			OUT NOCOPY 	NUMBER	,/*FIle.sql.39*/
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
             p_task_nl_std_bill_rate_sch_id     IN       PA_PLSQL_DATATYPES.NumTabTyp
                                                          DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
             p_proj_nl_std_bill_rate_sch_id     IN       PA_PLSQL_DATATYPES.NumTabTyp
                                                          DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
            p_uom_flag                      IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab
		)

	IS

	l_compute_flag PA_PLSQL_DATATYPES.Char1TabTyp;
	l_tp_base_curr_code PA_PLSQL_DATATYPES.Char15TabTyp;
	l_tp_schedule_line_id PA_PLSQL_DATATYPES.IdTabTyp;
	l_tp_rule_id PA_PLSQL_DATATYPES.IdTabTyp;
        l_error_code	VARCHAR2(30); /* bug#3115422 changed type from PA_PLSQL_DATATYPES.Char30TabTyp to VARCHAR2(30) */

	l_error_message VARCHAR2(2000);
	l_rate_date     Date;
	l_new_rate_date Date;
	l_status        Number;
	l_rate_type     Varchar2(30);
	l_exchange_rate Number;
	l_denominator Number;
	l_numerator  Number;
	l_denom_tp_currency_code Varchar2(15);
	l_denom_transfer_price   Number;
	l_acct_transfer_price   Number;
	l_tp_bill_rate           Number;
	l_tp_bill_markup_percentage Number;

	--Start Added for devdrop2

	l_tp_rate_ovrd     Number ;
	l_tp_currency_ovrd  Varchar2(30);
	l_tp_calc_base_code_ovrd Varchar2(15);
	l_tp_percent_applied_ovrd  Number;

	l_project_bil_rate_date_code  Varchar2(30);
	l_project_bil_rate_type       Varchar2(30);
	l_project_bil_rate_date       Date;
	l_project_bil_exchange_rate   Number;
	l_project_transfer_price      Number;

	l_projfunc_bil_rate_date_code Varchar2(30);
	l_projfunc_bil_rate_type      Varchar2(30);
	l_projfunc_bil_rate_date      Date;
	l_projfunc_bil_exchange_rate  Number;
	l_projfunc_transfer_price     Number;

	l_prev_project_id             Number;

	l_stage                        Number;
	l_transaction_type	      Varchar2(20) := Null;  /** Added for Org Forecasting **/
	l_multi_currency_billing_flag Varchar2(1);

	--End   Added for devdrop2

	/* bug#3115422 start */
	l_exp_func_curr_code      VARCHAR2(30);
	l_sl_function             NUMBER;

	l_bill_rate              NUMBER;
	l_adjust_bill_rate       NUMBER;--4038485
	l_markup_percentage      NUMBER;
	l_rev_currency_code      VARCHAR2(30);
	l_return_status          varchar2(240);
	l_msg_count              NUMBER;
	l_msg_data               VARCHAR2(240);
	l_raw_cost_rate          NUMBER;

	l_project_currency_code  varchar2(50) := null;
	l_project_raw_cost           number := null;

	l_tp_base_Curr_code1	varchar2(50);

	l_rate_type1 	        VARCHAR2(50)  := NULL;  -- For Bug 5276842

	cursor PROJ_VALUES (p_expenditure_item_id IN NUMBER) IS
	  select project_raw_cost,
	       project_currency_code
	  from pa_expenditure_items_all where expenditure_item_id=p_expenditure_item_id;
	/* bug#3115422 end */

	unexpected_result exception;

	BEGIN
	   pa_debug.Set_err_stack ('Get_Transfer_Price');

	   pa_debug.G_Err_Stage := 'Starting Get_Transfer_Price';
   	   IF g1_debug_mode  = 'Y' THEN
	   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	   END IF;

	/** Added for Org Forecasting **/

	   If p_module_name = 'FORECAST' then
	   l_transaction_type := 'FORECAST';
	   Else
	   l_transaction_type := 'ACTUAL';
	   End If;

   G_Array_Size := p_array_size;
   G_processed_thru_date := p_processed_thru_date;
   G_Calling_module := p_module_name;

   l_compute_flag := p_compute_flag;

   Init_who_cols;

   Get_Provider_Attributes(p_prvdr_operating_unit,
                           x_error_code); /** Parameter Added for Org Forecasting **/

   If p_module_name <> 'FORECAST' Then /** Added for Org Forecasting **/

   -- Given a org_id , get provider's legal_entity_id and business_group_id
   Get_legal_entity (G_prvdr_org_id,G_prvdr_legal_entity_id);

   -- If Callling Module is Forecast then moved this call in
   -- Get_Schedule_Line to Set G_prvdr_legal_entity_id for every
   -- provider_org_id separately

   End If;

   -- Print all the global variables
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',' Array Size = '||to_char(G_array_size));
   pa_debug.write_file('LOG',' Processed thru date = '
				     ||to_char(G_processed_thru_date));
   pa_debug.write_file('LOG',' Provider Org ID = '
				     ||to_char(G_prvdr_org_id));
   pa_debug.write_file('LOG',' Provider"s Legal Entity ID = '
				     ||to_char(G_prvdr_legal_entity_id));
   pa_debug.write_file('LOG',' Buiseness Group ID = '
				     ||to_char(G_bg_id));
   pa_debug.write_file('LOG',' Default Curr Conversion Rate Type = '
				     ||G_cc_default_rate_type);
   pa_debug.write_file('LOG',' Default Curr Conversion Rate Date Code = '
				     ||G_cc_default_rate_date_code);
   pa_debug.write_file('LOG',' Default Currency Code  = '
				     ||G_acct_currency_code );
   END IF;

   -- Validate input parameters and identify transactions passes for only
   -- currency conversion and not for recalculation.
   Validate_Array
	(
      p_prvdr_operating_unit,    /** New Parameter Added for Org Forecasting **/
	p_tp_schedule_id,
	x_denom_tp_currency_code,
      G_acct_currency_code,
	x_denom_transfer_price,
	x_acct_tp_rate_type,
	x_acct_tp_rate_date,
	x_acct_transfer_price,
	x_acct_tp_exchange_rate,
	l_compute_flag,
	x_error_code
	);

   -- Call Pre Client extension to calculate transfer price
   pa_debug.G_Err_Stage := 'Calling Pre-Client Extension............';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;
   For i in 1 .. G_Array_Size
   LOOP

      If G_Calling_module = 'FORECAST' Then /** Added for Org Forecasting **/
         Set_Global_Variables (p_prvdr_operating_unit(i));
      End If;

      IF (l_compute_flag (i) = 'Y' and x_error_code(i) is null ) THEN
         pa_debug.G_Err_Stage := 'Processing Expenditure ID: '||
					to_char(p_expenditure_item_id(i));
   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	END IF;

	 PA_CC_TP_CLIENT_EXTN.Determine_Transfer_Price
	    (
              L_transaction_type,
              G_prvdr_org_id,
     	      p_prvdr_organization_id(i),
              p_recvr_org_id(i),
              p_recvr_organization_id(i),
              p_expnd_organization_id(i),
              p_expenditure_item_id(i),
              p_expenditure_type(i),
              p_system_linkage_function(i),
	      p_task_id(i),
	      p_project_id(i),
	      p_quantity(i),
	      p_incurred_by_person_id(i),
	      l_denom_tp_currency_code,
	      l_denom_transfer_price,
	      l_tp_bill_rate,
	      l_tp_bill_markup_percentage,
	      l_error_message,
	      l_status
	      );

          -- Validate if the amount is calculated by extension
	  -- Also, mark the transactions where transfer price is calculated by
	  -- Pre-client extension.
	  IF (l_status = 0) THEN

	     IF (l_denom_transfer_price IS NOT NULL) THEN
   		IF g1_debug_mode  = 'Y' THEN
		pa_debug.write_file('LOG','Pre-client Bill Rate = '
					   ||to_char(l_tp_bill_rate));
		pa_debug.write_file('LOG','Pre-client markup = '
				     ||to_char(l_tp_bill_markup_percentage));
   		END IF;

	        IF (l_denom_tp_currency_code IS NULL) THEN
		   x_error_code(i) := 'PA_CC_TP_PREC_CURR_NULL';

                ELSE

		-- Check one of Bill Rate and Markup is available
		-- Both should not be null neither both could be not null

		      IF ( l_tp_bill_rate IS NULL AND
                           l_tp_bill_markup_percentage IS NULL) THEN

		          x_error_code(i) := 'PA_CC_TP_PREC_BILL_MRKUP_NULL';
                      ElSIF ( l_tp_bill_rate IS NOT NULL AND
                              l_tp_bill_markup_percentage IS NOT NULL) THEN

		             x_error_code(i) :=
					 'PA_CC_TP_PREC_BILL_MRKUP_VALUE';
                      ELSE
		         --Pre-client extension is successful
		         l_compute_flag(i) := 'P';
			 x_denom_transfer_price(i) := l_denom_transfer_price;
			 x_denom_tp_currency_code(i):= l_denom_tp_currency_code;
			 x_tp_bill_rate(i) := l_tp_bill_rate;
			 x_tp_bill_markup_percentage(i) :=
				    l_tp_bill_markup_percentage;
   			IF g1_debug_mode  = 'Y' THEN
		         pa_debug.write_file('LOG',
			   'Transfer Price calculated by Pre-Client extension');
		         pa_debug.write_file('LOG','Transfer Price = '||
					 to_char(x_denom_transfer_price(i)));
		         pa_debug.write_file('LOG','Transfer Price currency = '||
						x_denom_tp_currency_code(i));
   			END IF;

                      END IF;

	        END IF;

             END IF;/** x_denom_transfer_price(i) IS NOT NULL **/

          ELSIF (l_status > 0 ) THEN
	     -- Application error occurred with client extension
	     --x_error_code(i) := 'PA_CC_TP_PREC_APPS_ERROR'; -- Commented for 2661949
	     x_error_code(i) := l_error_message; -- Added for 2661949
             pa_debug.G_Err_Stage :=
	     Substr( 'Application error from Pre-Client extension'||
		       'while processing expenditure_item :'||
		       to_char(p_expenditure_item_id(i))||'Error Message :'
		       || l_error_message,1,2000);
   	     IF g1_debug_mode  = 'Y' THEN
             pa_debug.write_file('LOG',pa_debug.G_Err_Stage,1);
   	     END IF;

          ELSIF (l_status  < 0) THEN
	     x_error_code(i) := l_error_message; -- Added for 2661949
             pa_debug.G_Err_Stage :=
	       Substr( 'Unexpected error from Pre-Client extension'||
		       'while processing expenditure_item :'||
		       to_char(p_expenditure_item_id(i))||'Error Message :'
		       || l_error_message,1,2000);

   	     IF g1_debug_mode  = 'Y' THEN
             pa_debug.write_file('LOG',pa_debug.G_Err_Stage,1);
   	     END IF;
	     raise unexpected_result;

          END IF; /** l_status **/

--Start Added for devdrop2

-- Add the assignment override logic here
-- and set the compute_flag = 'P'


IF ( ( l_compute_flag(i) = 'Y' ) AND
     ( p_assignment_id(i) is not null ) AND
     ( nvl(p_assignment_precedes_task(i),'N')='Y') ) then /* added for bug#3142053 */

BEGIN

   Select
      tp_rate_override,
      tp_currency_override,
      tp_calc_base_code_override,
      tp_percent_applied_override
   into
      l_tp_rate_ovrd,
      l_tp_currency_ovrd,
      l_tp_calc_base_code_ovrd,
      l_tp_percent_applied_ovrd
   from
      pa_project_assignments
   where
       assignment_id = p_assignment_id(i)
   and p_expenditure_item_date(i) between
              start_date and end_date ;

   if ( l_tp_rate_ovrd is not null  ) then
    if(p_system_linkage_function(i) in ('ST','OT'))  then  /* Added the condition for bug 6310246 */
      x_denom_transfer_price(i) := p_quantity(i) * nvl(l_tp_rate_ovrd,0);
      x_denom_tp_currency_code(i):= l_tp_currency_ovrd;
      x_tp_bill_rate(i) := nvl(l_tp_rate_ovrd,0);
      l_compute_flag(i) := 'A';
	End if;

  elsif ( l_tp_calc_base_code_ovrd is not null ) then

      l_compute_flag(i) := 'A';

     if ( l_tp_calc_base_code_ovrd = 'R' ) then

     /* bug#3115422 start */
     if p_raw_revenue_amount(i) is null then

	   OPEN PROJ_VALUES(p_expenditure_item_id(i));
	   FETCH proj_values into
	    l_project_raw_cost,
	    l_project_currency_code;
	   ClOSE PROJ_VALUES;
           /* Added for bill rate disount and transfer price revenue*/
           IF (p_system_linkage_function(i) in ('ST','OT'))  then
	           IF g1_debug_mode  = 'Y' THEN
                   pa_debug.write_file('LOG','in assignment override within Assignment_Rev_Amt');
   		   END IF;
                    pa_revenue.Assignment_Rev_Amt(
                                 p_project_id                 => P_project_id(i)
                                 ,p_task_id                   => P_task_id(i)
                                 ,p_item_date                 => P_expenditure_item_date(i)
                                 ,p_item_id                   => p_assignment_id(i)
                                 ,p_bill_rate_multiplier      => p_bill_rate_multiplier(i)
                                 ,p_quantity                  => p_quantity(i)
                                 ,p_person_id                 => p_incurred_by_person_id(i)
                                 ,p_raw_cost                  => p_raw_cost(i)
                                 /* bug#3221791 added to_number */
                                 ,p_labor_schdl_discnt        => to_number(p_labor_schdl_discnt(i))
                                 ,p_labor_bill_rate_org_id    => NULL
                                 ,p_labor_std_bill_rate_schdl => NULL
                                 ,p_labor_schdl_fixed_date    => p_labor_schdl_fixed_date(i)
                                 ,p_bill_job_grp_id           => p_bill_job_grp_id(i)
                                 ,p_labor_sch_type            => p_labor_sch_type(i)
                                 ,p_project_org_id            => p_project_org_id(i)
                                 ,p_project_type              => p_project_type(i)
                                 ,p_expenditure_type          => p_expenditure_type(i)
                                 ,p_exp_func_curr_code        => p_exp_func_curr_code(i)
                                 ,p_incurred_by_organz_id     => p_incurred_by_organz_id(i)
                                 ,p_raw_cost_rate             => p_raw_cost_rate(i)
                                 ,p_override_to_organz_id     => p_override_to_organz_id(i)
                                 ,p_emp_bill_rate_schedule_id => p_emp_bill_rate_schedule_id(i)
                                 ,p_job_bill_rate_schedule_id => p_job_bill_rate_schedule_id(i)
                                 ,p_resource_job_id           => NULL
                                 ,p_exp_raw_cost              => p_exp_raw_cost(i)
                                 ,p_expenditure_org_id        => p_expnd_organization_id(i)
                                 ,p_projfunc_currency_code    => p_projfunc_currency_code(i)
                                 ,p_assignment_precedes_task  => p_assignment_precedes_task(i)
                                 ,p_sys_linkage_function      => p_system_linkage_function(i)
                                 ,x_bill_rate                 => l_bill_rate
                                 ,x_raw_revenue               => x_tp_base_amount(i)
                                 ,x_txn_currency_code         => l_tp_base_Curr_code1
                                 ,x_rev_currency_code         => l_rev_currency_code
                                 ,x_markup_percentage         => l_markup_percentage
                                 ,x_return_status             => l_return_status
                                 ,x_msg_count                 => l_msg_count
                                 ,x_msg_data                  => l_msg_data
                                 ,p_mcb_flag                  => p_mcb_flag(i)
                                 ,p_denom_raw_cost            => p_denom_raw_cost_amount(i)
                                 ,p_denom_curr_code           => p_denom_currency_code(i)
                                 ,p_called_process            => 'PA'
                                 ,p_project_raw_cost         => l_project_raw_cost
                                 ,p_project_currency_code     => l_project_currency_code
				 ,x_adjusted_bill_rate         => l_adjust_bill_rate); --4038485
   		   IF g1_debug_mode  = 'Y' THEN
                   pa_debug.write_file('LOG','in assignment override completed Assignment_Rev_Amt');
   	           END IF;

	   end if;  /* end of system linkage */
	   IF g1_debug_mode  = 'Y' THEN
	   pa_debug.write_file('LOG','x_base revenue amount' || x_tp_base_amount(i) ||'code : ' ||l_tp_base_curr_code1);
	   END IF;
	   IF l_msg_data is NULL then
	    IF x_tp_base_amount(i) is NULL THEN
	     l_error_code := 'PA_CC_TP_REV_AMT_NULL';
	    END IF;
	   ELSE
	    l_error_code := l_msg_data;
	   END IF;
	   /* Added for bill rate disount and transfer price revenue*/

      x_denom_transfer_price(i) := x_tp_base_amount(i) * (nvl(l_tp_percent_applied_ovrd,100)/100);
      x_denom_tp_currency_code(i) := l_tp_base_Curr_code1;
     else
      x_denom_transfer_price(i) := p_raw_revenue_amount(i) * (nvl(l_tp_percent_applied_ovrd,100)/100);
      x_denom_tp_currency_code(i) := p_projfunc_currency_code(i);
     end if; /* end for p_raw_revenue_amount */

     /* bug#3115422 end */

     elsif ( l_tp_calc_base_code_ovrd = 'C' ) then

      x_denom_transfer_price(i) := p_denom_raw_cost_amount(i)* (nvl(l_tp_percent_applied_ovrd,100)/100);
      x_denom_tp_currency_code(i) := p_denom_currency_code(i);

     elsif ( l_tp_calc_base_code_ovrd = 'B' ) then

       x_denom_transfer_price(i) :=
          nvl(p_denom_burdened_cost_amount(i),0) * (nvl(l_tp_percent_applied_ovrd,100)/100);
       x_denom_tp_currency_code(i) := p_denom_currency_code(i);

     end if; /* asg_tp_calc_base_code_ovrd = 'B'  */

   end if; /* asg_tp_calc_base_code_ovrd is not null  */

 EXCEPTION
   when NO_DATA_FOUND then
     null;
   when others  then
     raise;
 END;

end if; /* l_compute_flag(i) = 'Y'  */

--End   Added for devdrop2

         pa_debug.G_Err_Stage := 'Completed Processing Expenditure ID: '||
					to_char(p_expenditure_item_id(i));
   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	END IF;

      END IF; /**l_compute_flag (i) = 'Y' and x_error_code(i) IS NULL**/

   END LOOP;


   pa_debug.G_Err_Stage := 'Completes Pre-Client Extension............';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

   -- Get the schedule_line_id and the right rule_id associated with it.

   Get_Schedule_Line(
        p_expenditure_item_id,
        p_expenditure_item_date, /* Added for Bug 3118101 */
 	p_prvdr_organization_id,
        p_recvr_org_id,
        p_recvr_organization_id,
	p_labor_non_labor_flag,
	p_tp_schedule_id,
	l_compute_flag,
-- Start Added for devdrop2
        p_tp_amt_type_code,
-- End   Added for devdrop2
        p_prvdr_operating_unit, /** Added for Org Forecasting **/
	x_error_code,
	l_tp_schedule_line_id,
	x_tp_schedule_line_percentage,
	l_tp_rule_id
		   );

   -- Get the transfer price amount using calc_method_code and also the
   -- other OUT parameters

   Get_Transfer_Price_Amount
	(
	l_tp_rule_id,
        p_expenditure_item_id,
        p_expenditure_type,
	p_expenditure_item_date,
        p_expnd_organization_id,
	p_project_id,
        p_task_id,
	p_denom_currency_code,
	p_projfunc_currency_code,
	p_revenue_distributed_flag,
	l_compute_flag,
	p_denom_raw_cost_amount,
	p_denom_burdened_cost_amount,
	p_raw_revenue_amount,
	p_quantity,
	p_incurred_by_person_id,
	p_job_id,
	p_non_labor_resource,
	p_nl_resource_organization_id,
	p_system_linkage_function,
	x_tp_schedule_line_percentage,
	p_tp_fixed_date,
	x_denom_tp_currency_code,
	x_denom_transfer_price,
	x_cc_markup_base_code,
	x_tp_ind_compiled_set_id,
	x_tp_bill_rate,
	l_tp_base_curr_code,
	x_tp_base_amount,
	x_tp_bill_markup_percentage,
	x_tp_rule_percentage,
        x_tp_job_id          ,
	x_error_code,
/* Bill rate Discount*/
        p_dist_rule,
        p_mcb_flag,
        p_bill_rate_multiplier,
        p_raw_cost,
        p_labor_schdl_discnt,
        p_labor_schdl_fixed_date,
        p_bill_job_grp_id,
        p_labor_sch_type,
        p_project_org_id,
        p_project_type,
        p_exp_func_curr_code,
        p_incurred_by_organz_id,
        p_raw_cost_rate,
        p_override_to_organz_id,
        p_emp_bill_rate_schedule_id,
        p_job_bill_rate_schedule_id,
        p_exp_raw_cost,
        p_assignment_precedes_task,
        p_assignment_id ,

        p_burden_cost,
        p_task_nl_bill_rate_org_id,
        p_proj_nl_bill_rate_org_id,
        p_task_nl_std_bill_rate_sch,
        p_proj_nl_std_bill_rate_sch,
        p_nl_task_sch_date,
        p_nl_proj_sch_date,
        p_nl_task_sch_discount,
        p_nl_proj_sch_discount,
        p_nl_sch_type,
/*Added for Doosan rate api enhancement */
        p_task_nl_std_bill_rate_sch_id,
        p_proj_nl_std_bill_rate_sch_id,
        p_uom_flag);


   -- Call Post Client extension to calculate transfer price


   For i in 1 .. G_Array_Size
   LOOP
      IF (l_compute_flag (i) = 'Y' and x_error_code(i) IS NULL) THEN

         If G_Calling_module = 'FORECAST' Then   /** Added for Org Forecasting **/
         Set_Global_Variables (p_prvdr_operating_unit(i));
         End If;

	 -- Don't consider transactions identified for adjustment and
	 -- also transfer price already calculated by Pre-client extension.
         pa_debug.G_Err_Stage := 'Calling Post-client extension';
   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	END IF;

	 PA_CC_TP_CLIENT_EXTN.Override_Transfer_Price
	    (
              L_Transaction_type,
              G_prvdr_org_id,
 	      p_prvdr_organization_id(i),
              p_recvr_org_id(i),
              p_recvr_organization_id(i),
              p_expnd_organization_id(i),
              p_expenditure_item_id(i),
              p_expenditure_type(i),
              p_system_linkage_function(i),
	      p_task_id(i),
	      p_project_id(i),
	      p_quantity(i),
	      p_incurred_by_person_id(i),
	      l_tp_base_curr_code(i),
	      x_tp_base_amount(i),
	      x_denom_tp_currency_code(i),
	      x_denom_transfer_price(i),
	      l_denom_tp_currency_code,
	      l_denom_transfer_price,
	      l_tp_bill_rate,
	      l_tp_bill_markup_percentage,
	      l_error_message,
	      l_status
	      );
         pa_debug.G_Err_Stage := 'After Call to Post-client extension';
   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	END IF;

          -- Validate if the amount is calculated by extension
	  -- Also, mark the transactions where transfer price is calculated by
	  -- Post-client extension.
	  IF (l_status = 0) THEN
	     IF (l_denom_transfer_price IS NOT NULL) THEN

	     IF (NVL(l_denom_transfer_price,-99) <>
	         NVL(x_denom_transfer_price(i),-99) ) THEN

		IF (l_denom_tp_currency_code IS NULL) THEN

		   x_error_code(i) := 'PA_CC_TP_POSC_CURR_NULL';

                ELSE
		-- Check one of Bill Rate and Markup is available
		-- Both should not be null neither both could be not null

		   IF ( l_tp_bill_rate IS NULL) AND
                      (l_tp_bill_markup_percentage IS NULL) THEN

		      x_error_code(i) := 'PA_CC_TP_POSC_BILL_MRKUP_NULL';
                   ELSIF ( l_tp_bill_rate IS NOT NULL) AND
                         (l_tp_bill_markup_percentage IS NOT NULL) THEN

		         x_error_code(i) :=
					 'PA_CC_TP_POSC_BILL_MRKUP_VALUE';
                   ELSE
		         --Post-client extension is successful
		         l_compute_flag(i) := 'O';
			 x_denom_transfer_price(i) := l_denom_transfer_price;
                         x_tp_bill_rate(i) := l_tp_bill_rate;
			 x_tp_bill_markup_percentage(i) :=
					   l_tp_bill_markup_percentage;
			 -- Bug 5263275 Assigned the from clent extn
			 x_denom_tp_currency_code(i) := l_denom_tp_currency_code;

	           END IF;

               END IF;/** x_denom_transfer_price(i) IS NOT NULL **/

             END IF;

	     ELSE
		-- Check if IN transfer price was not null and OUT is made null
		-- then error out

		IF (x_denom_transfer_price(i) IS NOT NULL) THEN

		   x_error_code (i) := 'PA_CC_TP_POSC_TP_NULL';

		END IF;

	     END IF;

          ELSIF (l_status > 0 ) THEN
	     -- Application error occurred with client extension
	     --x_error_code(i) := 'PA_CC_TP_POSC_APPS_ERROR';-- Commented for 2661949
	     x_error_code(i) := l_error_message;-- Added for 2661949
             pa_debug.G_Err_Stage :=
	     Substr( 'Application error from Post-Client extension'||
		       'while processing expenditure_item :'||
		       to_char(p_expenditure_item_id(i))||'Error Message :'
		       || l_error_message,1,2000);
   	     IF g1_debug_mode  = 'Y' THEN
             pa_debug.write_file('LOG',pa_debug.G_Err_Stage,1); -- Changed for 2661949
   	     END IF;

          ELSIF (l_status  < 0) THEN
	     x_error_code(i) := l_error_message; -- Added for 2661949
             pa_debug.G_Err_Stage :=
	       Substr( 'Unexpected error from Post-Client extension'||
		       'while processing expenditure_item :'||
		       to_char(p_expenditure_item_id(i))||'Error Message :'
		       || l_error_message,1,2000);
   	     IF g1_debug_mode  = 'Y' THEN
             pa_debug.write_file('LOG',pa_debug.G_Err_Stage,1);
   	     END IF;
	     raise unexpected_result;

          END IF; /** l_status **/

      END IF; /**l_compute_flag (i) = 'Y' and x_error_code(i) IS NULL**/

   END LOOP;


   -- Currency Conversion
   pa_debug.G_Err_Stage := 'Do Currency Conversion';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

--Start devdrops2 change

  l_prev_project_id := -1;

--End   devdrops2 change

   For i in 1 .. G_Array_Size
   LOOP


-- Removed the p_compute_flag(i) = 'Y' check

        IF ( x_error_code(i) IS NULL) THEN

         If G_Calling_module = 'FORECAST' Then   /** Added for Org Forecasting **/
         Set_Global_Variables (p_prvdr_operating_unit(i));
         End If;

	 IF (x_denom_transfer_price(i) IS NOT NULL) THEN
	    IF (x_denom_tp_currency_code(i) IS NOT NULL) THEN

	       IF (l_compute_flag(i) = 'C') THEN
                   pa_debug.G_Err_Stage := 'Converting adjustment cases';
   		   IF g1_debug_mode  = 'Y' THEN
                   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   		   END IF;
	       -- Convert the adjustment cases
		  IF (x_acct_tp_rate_type(i) = 'User' AND
		      x_acct_tp_exchange_rate(i) IS NOT NULL) THEN
		      -- Do the conversion using the rate
                      x_acct_transfer_price(i):=
		        pa_currency.round_currency_amt(x_denom_transfer_price(i)
			*x_acct_tp_exchange_rate(i));
                  ELSE
		      IF (x_acct_tp_rate_type(i) IS NOT NULL
			 AND x_acct_tp_rate_date(i) IS NOT NULL) THEN

          begin -- Bug 7423839
 		      IF g1_debug_mode  = 'Y' THEN
                     pa_debug.write_file('LOG', '1:i= '||i|| ' f_curr '||x_denom_tp_currency_code(i)||' t_curr '||G_acct_currency_code);
                     pa_debug.write_file('LOG', 'r_date '||x_acct_tp_rate_date(i)|| ' r_type '||x_acct_tp_rate_type(i)||' amt '||x_denom_transfer_price(i));
                     pa_debug.write_file('LOG', 'xfer_price '||l_acct_transfer_price|| ' denom '||l_denominator||' num '||l_numerator);
                     pa_debug.write_file('LOG', 'rate '||x_acct_tp_exchange_rate(i));
 		      END IF;
		         -- Use type and date to convert
                         PA_MULTI_CURRENCY.Convert_Amount(
			    p_from_currency => x_denom_tp_currency_code(i),
			    p_to_currency => G_acct_currency_code ,
			    p_conversion_date => x_acct_tp_rate_date(i),
			    p_conversion_type => x_acct_tp_rate_type(i),
			    p_amount => x_denom_transfer_price(i),
			    p_user_validate_flag => 'Y',
			    p_handle_exception_flag => 'Y',
			    p_converted_amount => l_acct_transfer_price,
			    p_denominator => l_denominator,
			    p_numerator => l_numerator,
			    p_rate => x_acct_tp_exchange_rate(i),
			    x_status => l_error_message
			    );
          exception
          when others then
 		      IF g1_debug_mode  = 'Y' THEN
                     pa_debug.write_file('LOG', 'r_date '||x_acct_tp_rate_date(i)|| ' r_type '||x_acct_tp_rate_type(i));
                     pa_debug.write_file('LOG', 'xfer_price '||l_acct_transfer_price|| ' denom '||l_denominator||' num '||l_numerator);
                     pa_debug.write_file('LOG', 'rate '||x_acct_tp_exchange_rate(i)|| ' err msg '||substr(l_error_message,1,300));
 		      END IF;
             if l_error_message IS NULL THEN
                   l_error_message := 'OTHERS';
             end if;
          end;
	              IF l_error_message is NOT NULL THEN
			       x_error_code(i) := 'PA_CC_TP_CONVERT_AMT';
                            ELSE
			     x_acct_transfer_price (i) := l_acct_transfer_price;
                            END IF;
                       ELSE
			  x_error_code(i) := 'PA_CC_TP_RATE_TYPE_DATE_NULL';
                       END IF;


                  END IF;

	       ELSE 	  /** else (l_compute_flag(i) = 'C'**/

		  -- Consider the cases where transfer price calculated by
		  -- Pre-client extension or APIs or Post -client extension
                  IF (G_cc_default_rate_date_code = 'E') THEN
		     l_rate_date := p_expenditure_item_date(i);

                  ELSIF (G_cc_default_rate_date_code = 'P') THEN
		     IF (p_pa_date.exists(i)and p_pa_date(i) IS NOT NULL) THEN
			 l_rate_date := p_pa_date(i);
                     ELSE
			-- Calculate pa_Date
			l_rate_date := pa_utils2.get_pa_date(
				       p_ei_date => p_expenditure_item_date(i),
				       p_gl_date => sysdate,
				       p_org_id  => G_prvdr_org_id /* p_prvdr_organization_id(i) modified for bug 3535443 */  /**CBGA**/
							   );
                     END IF;
                   END IF;

		  -- Call extension to Override currency attributes

		  PA_MULTI_CURR_CLIENT_EXTN.Override_Curr_Conv_Attributes
		   (
		     p_project_id => p_project_id(i),
		     p_task_id => p_task_id(i),
		     p_transaction_class => 'Transfer Price',
		     p_expenditure_item_id => p_expenditure_item_id(i),
		     p_expenditure_type_class => p_system_linkage_function(i),
		     p_expenditure_type => p_expenditure_type(i),
		     p_expenditure_category => p_expenditure_category(i),
		     p_from_currency_code => x_denom_tp_currency_code(i),
		     p_to_currency_code => G_Acct_currency_code,
		     p_conversion_type => G_cc_default_rate_type,
		     p_conversion_date => l_rate_date,
		     x_rate_type => l_rate_type,
		     x_rate_date => l_new_rate_date,
		     x_exchange_rate => l_exchange_rate,
		     x_error_message => l_error_message,
		     x_status => l_status
		     );


                    IF (l_status = 0) THEN
		       -- success
		       l_error_message := null;

  --  Added the below code for Bug 5276842
			IF l_rate_type <>  'User'  and l_rate_type IS NOT NULL THEN
		           BEGIN
				SELECT conversion_type
				INTO l_rate_type1
				FROM gl_daily_conversion_types
				WHERE (user_conversion_type = l_rate_type
					OR conversion_type = l_rate_type);
                                l_rate_type := l_rate_type1;
		            EXCEPTION
                  	     WHEN NO_DATA_FOUND THEN
	                          l_error_message := 'PA_EXCH_RATE_TYPE_INVALID';
                            END;
			END IF;
  --  End of changes for bug 5276842

		       IF (l_rate_type = 'User' and l_exchange_rate IS NOT NULL)
			   THEN
		          -- Do the conversion using the rate
                          l_acct_transfer_price :=
		           pa_currency.round_currency_amt(
			   x_denom_transfer_price(i)*l_exchange_rate);

                       ELSIF (l_rate_type IS NOT NULL and l_new_rate_date IS
			      NOT NULL and l_error_message IS NULL) THEN
                         -- Added the condition of l_error_message for Bug 5276842
		         -- Use type and date to convert
			   l_rate_date := l_new_rate_date;
                  begin --Bug 7423839
     		      IF g1_debug_mode  = 'Y' THEN
                         pa_debug.write_file('LOG', '2:i= '||i|| ' f_curr '||x_denom_tp_currency_code(i)||' t_curr '||G_acct_currency_code);
                         pa_debug.write_file('LOG', 'r_date '||l_rate_date|| ' r_type '||l_rate_type||' amt '||x_denom_transfer_price(i));
                         pa_debug.write_file('LOG', 'xfer_price '||l_acct_transfer_price|| ' denom '||l_denominator||' num '||l_numerator);
                         pa_debug.write_file('LOG', 'rate '||l_exchange_rate);
     		      END IF;
                           PA_MULTI_CURRENCY.Convert_Amount(
			    p_from_currency => x_denom_tp_currency_code(i),
			    p_to_currency => G_acct_currency_code ,
			    p_conversion_date => l_rate_date,
			    p_conversion_type => l_rate_type,
			    p_amount => x_denom_transfer_price(i),
			    p_user_validate_flag => 'Y',
			    p_handle_exception_flag => 'Y',
			    p_converted_amount => l_acct_transfer_price,
			    p_denominator => l_denominator,
			    p_numerator => l_numerator,
			    p_rate => l_exchange_rate,
			    x_status => l_error_message
			    );
                 exception
                      when others then
     		      IF g1_debug_mode  = 'Y' THEN
                         pa_debug.write_file('LOG', 'r_date '||l_rate_date|| ' r_type '||l_rate_type);
                         pa_debug.write_file('LOG', 'xfer_price '||l_acct_transfer_price|| ' denom '||l_denominator||' num '||l_numerator);
                         pa_debug.write_file('LOG', 'rate '||l_exchange_rate|| ' err msg '||substr(l_error_message,1,300));
     		      END IF;
                      if l_error_message IS NULL THEN
                         l_error_message := 'OTHERS';
                      end if;
                 end;
                        ELSIF (l_error_message IS NULL) THEN
                       -- Added the condition of l_error_message for Bug 5276842
			   -- Use default rate_type and rate_date to convert
                           pa_debug.G_Err_Stage := 'Using default rate type';
   			   IF g1_debug_mode  = 'Y' THEN
                           pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   			   END IF;
			   l_rate_type := G_cc_default_rate_type;

                  begin --Bug 7423839
     		      IF g1_debug_mode  = 'Y' THEN
                         pa_debug.write_file('LOG', '3:i= '||i|| ' f_curr '||x_denom_tp_currency_code(i)||' t_curr '||G_acct_currency_code);
                         pa_debug.write_file('LOG', 'r_date '||l_rate_date|| ' r_type '||l_rate_type||' amt '||x_denom_transfer_price(i));
                         pa_debug.write_file('LOG', 'xfer_price '||l_acct_transfer_price|| ' denom '||l_denominator||' num '||l_numerator);
                         pa_debug.write_file('LOG', 'rate '||l_exchange_rate);
     		      END IF;
                           PA_MULTI_CURRENCY.Convert_Amount(
			    p_from_currency => x_denom_tp_currency_code(i),
			    p_to_currency => G_acct_currency_code ,
			    p_conversion_date => l_rate_date,
			    p_conversion_type => l_rate_type,
			    p_amount => x_denom_transfer_price(i),
			    p_user_validate_flag => 'Y',
			    p_handle_exception_flag => 'Y',
			    p_converted_amount => l_acct_transfer_price,
			    p_denominator => l_denominator,
			    p_numerator => l_numerator,
			    p_rate => l_exchange_rate,
			    x_status => l_error_message
			    );
                 exception
                      when others then
     		      IF g1_debug_mode  = 'Y' THEN
                         pa_debug.write_file('LOG', 'r_date '||l_rate_date|| ' r_type '||l_rate_type);
                         pa_debug.write_file('LOG', 'xfer_price '||l_acct_transfer_price|| ' denom '||l_denominator||' num '||l_numerator);
                         pa_debug.write_file('LOG', 'rate '||l_exchange_rate|| ' err msg '||substr(l_error_message,1,300));
     		      END IF;
                      if l_error_message IS NULL THEN
                         l_error_message := 'OTHERS';
                      end if;
                 end;

                        END IF;

			IF l_error_message IS NOT NULL THEN

			   x_error_code(i) := 'PA_CC_TP_CONVERT_AMT';
   			   IF g1_debug_mode  = 'Y' THEN
                           pa_debug.write_file('LOG',
				  Substr (l_error_message,1,2000),1);
   			   END IF;
                        ELSE
			   x_acct_transfer_price (i) := l_acct_transfer_price;
			   x_acct_tp_rate_type(i) := l_rate_type;
			   x_acct_tp_rate_date(i) := l_rate_date;
			   x_acct_tp_exchange_rate(i) := l_exchange_rate;

			   -- bug 7489360
			   x_proj_tp_rate_type(i) := l_rate_type;
			   x_proj_tp_rate_date(i) := l_rate_date;
			   x_projfunc_tp_rate_type(i) := l_rate_type;
			   x_projfunc_tp_rate_date(i) := l_rate_date;

                           pa_debug.G_Err_Stage := 'Rate Type ='||l_rate_type;
   			   IF g1_debug_mode  = 'Y' THEN
                           pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   			   END IF;
                        END IF;

                    ELSIF (l_status > 0) THEN
			-- Application error occurred in extension to override
			-- currency conversion attributes
		      -- x_error_code(i) := 'PA_CC_TP_OVERIDE_APP_ERROR';
		       x_error_code(i) := l_error_message; -- Added for 2661949
                       pa_debug.G_Err_Stage :=
	                 Substr( 'Application error from Currency conversion
			   override extension'||
			   'while processing expenditure_item :'||
		           to_char(p_expenditure_item_id(i))||'Error Message :'
		           || l_error_message,1,2000);
   		       IF g1_debug_mode  = 'Y' THEN
                       pa_debug.write_file('LOG',pa_debug.G_Err_Stage,1);
   		       END IF;
                    ELSIF (l_status < 0) THEN

			-- Unexpected error occurred in extension to override
			-- currency conversion attributes
		       --x_error_code(i) := 'PA_CC_TP_OVERIDE_ORA_ERROR';
			 x_error_code(i) := l_error_message; -- Added for 2661949
                       pa_debug.G_Err_Stage :=
	                 Substr( 'Unexpected error from Currency conversion
			   override extension'||
			   'while processing expenditure_item :'||
		           to_char(p_expenditure_item_id(i))||'Error Message :'
		           || l_error_message,1,2000);
   		       IF g1_debug_mode  = 'Y' THEN
                       pa_debug.write_file('LOG',pa_debug.G_Err_Stage,1);
   		       END IF;
		      raise unexpected_result;
                    ELSE
		       x_error_code (i) := 'PA_CC_TP_INVALID_OVERIDE_STATUS';
                    END IF;

  l_multi_currency_billing_flag := 'N';

/*  IF ( ( p_tp_amt_type_code(i) is not NULL )
         and ( p_tp_amt_type_code(i) =  'REVENUE_TRANSFER' ) ) then        commented for bug6712230*/
   If  NVL(p_tp_amt_type_code(i),'COST_REVENUE') is not NULL THEN /* Added NVL for bug 6891120 -- bug6712230 */
--Start devdrop2  changes
-- Converting the denorm to projfunc and proj for amt_type 'REVENUE_TRANSFER'

               SELECT   project_bil_rate_date_code,
                        project_bil_rate_type,
                        project_bil_rate_date,
                        project_bil_exchange_rate,
                        projfunc_bil_rate_date_code,
                        projfunc_bil_rate_type,
                        projfunc_bil_rate_date,
                        nvl(multi_currency_billing_flag,'N'),
                        projfunc_bil_exchange_rate
               INTO     l_project_bil_rate_date_code,
                        l_project_bil_rate_type,
                        l_project_bil_rate_date,
                        l_project_bil_exchange_rate,
                        l_projfunc_bil_rate_date_code,
                        l_projfunc_bil_rate_type,
                        l_projfunc_bil_rate_date,
                        l_multi_currency_billing_flag,
                        l_projfunc_bil_exchange_rate
               FROM       pa_projects_all
               WHERE      project_id = p_project_id(i);
  if p_tp_amt_type_code(i) =  'REVENUE_TRANSFER'  THEN               /*bug6389559*/
   IF ( l_multi_currency_billing_flag = 'Y' ) THEN

   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG','l_project_bil_rate_date_code: '||l_project_bil_rate_date_code);
         pa_debug.write_file('LOG','l_project_bil_rate_type: '||l_project_bil_rate_type);
         pa_debug.write_file('LOG','l_project_bil_rate_date: '||l_project_bil_rate_date);
         pa_debug.write_file('LOG','l_project_bil_exchange_rate: '||l_project_bil_exchange_rate);

         pa_debug.write_file('LOG','l_projfunc_bil_rate_date_code: '||l_projfunc_bil_rate_date_code);
         pa_debug.write_file('LOG','l_projfunc_bil_rate_type: '||l_projfunc_bil_rate_type);
         pa_debug.write_file('LOG','l_projfunc_bil_rate_date: '||l_projfunc_bil_rate_date);
         pa_debug.write_file('LOG','l_projfunc_bil_exchange_rate: '||l_projfunc_bil_exchange_rate);

         pa_debug.write_file('LOG','pa_date : '||p_pa_date(i));
         pa_debug.write_file('LOG','x_denom_tp_currency_code : '||x_denom_tp_currency_code(i));
         pa_debug.write_file('LOG','p_project_currency_code : '||p_project_currency_code(i));
   	END IF;
--
--Converting into Project currency attributes
-- for tp_amt_type_code = 'REVENUE_TRANSFER'

               IF (l_project_bil_rate_type = 'User') THEN

                 IF (l_project_bil_exchange_rate IS NOT NULL) THEN

                   l_project_transfer_price:=
                      pa_currency.round_trans_currency_amt
                       (x_denom_transfer_price(i)*l_project_bil_exchange_rate,
                          p_project_currency_code(i));
                 ELSE
                      x_error_code(i) := 'PA_CC_TP_CONVERT_AMT';
   		     IF g1_debug_mode  = 'Y' THEN
                      pa_debug.write_file('LOG','ERROR NO USER RATE ');
   		     END IF;

                 END IF;
                else

                   IF (l_project_bil_rate_date_code = 'PA_INVOICE_DATE' ) THEN
                         l_project_bil_rate_date := G_processed_thru_date;
                   END IF;

     IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG','BEFORE CONVERT: l_project_bil_rate_type: '||l_project_bil_rate_type);
         pa_debug.write_file('LOG','BEFORE CONVERT: l_project_bil_rate_date: '||l_project_bil_rate_date);
     END IF;
             begin --Bug 7423839
     		      IF g1_debug_mode  = 'Y' THEN
                         pa_debug.write_file('LOG', '4:i= '||i|| ' f_curr '||x_denom_tp_currency_code(i)||' t_curr '||p_project_currency_code(i));
                         pa_debug.write_file('LOG', 'r_date '||l_project_bil_rate_date|| ' r_type '||l_project_bil_rate_type||' amt '||x_denom_transfer_price(i));
                         pa_debug.write_file('LOG', 'xfer_price '||l_project_transfer_price|| ' denom '||l_denominator||' num '||l_numerator);
                         pa_debug.write_file('LOG', 'rate '||l_project_bil_exchange_rate);
     		      END IF;
                    PA_MULTI_CURRENCY.Convert_Amount(
                    p_from_currency => x_denom_tp_currency_code(i),
                    p_to_currency => p_project_currency_code(i),
                    p_conversion_date => l_project_bil_rate_date,
                    p_conversion_type => l_project_bil_rate_type,
                    p_amount => x_denom_transfer_price(i),
                    p_user_validate_flag => 'Y',
                    p_handle_exception_flag => 'Y',
                    p_converted_amount => l_project_transfer_price,
                    p_denominator => l_denominator,
                    p_numerator => l_numerator,
                    p_rate => l_project_bil_exchange_rate,
                    x_status => l_error_message
                    );
                      exception
                      when others then
     		      IF g1_debug_mode  = 'Y' THEN
                         pa_debug.write_file('LOG', 'r_date '||l_project_bil_rate_date|| ' r_type '||l_project_bil_rate_type);
                         pa_debug.write_file('LOG', 'xfer_price '||l_project_transfer_price|| ' denom '||l_denominator||' num '||l_numerator);
                         pa_debug.write_file('LOG', 'rate '||l_project_bil_exchange_rate|| ' err msg '||substr(l_error_message,1,300));
     		      END IF;
                      if l_error_message IS NULL THEN
                         l_error_message := 'OTHERS';
                      end if;
                 end;


         IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG','l_error_message : '||l_error_message);
         pa_debug.write_file('LOG','AFTER  CONVERT: l_project_bil_rate_type: '||l_project_bil_rate_type);
         pa_debug.write_file('LOG','AFTER  CONVERT: l_project_bil_rate_date: '||l_project_bil_rate_date);
     	 END IF;

                    IF l_error_message IS NOT NULL THEN

                      x_error_code(i) := 'PA_CC_TP_CONVERT_AMT';
     		      IF g1_debug_mode  = 'Y' THEN
                      pa_debug.write_file('LOG',
                        Substr (l_error_message,1,2000));
     		      END IF;
                    ELSE
                      x_proj_transfer_price (i) := l_project_transfer_price;
                      x_proj_tp_rate_type(i) := l_project_bil_rate_type;
                      x_proj_tp_rate_date(i) := l_project_bil_rate_date;
                      x_proj_tp_exchange_rate(i) := l_project_bil_exchange_rate;
                      pa_debug.G_Err_Stage := 'Rate Type ='||l_project_bil_rate_type;
     		      IF g1_debug_mode  = 'Y' THEN
                      pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
     		      END IF;
                    END IF;


                 END IF; /* esle l_project_bil_rate_type = 'User'*/


--
--Converting into Project functional currency attributes
-- for tp_amt_type_code = 'REVENUE_TRANSFER'
--

               IF (l_projfunc_bil_rate_type = 'User' AND
                  l_projfunc_bil_exchange_rate IS NOT NULL) THEN

                   l_projfunc_transfer_price:=
                      pa_currency.round_trans_currency_amt
                       (x_denom_transfer_price(i)*l_projfunc_bil_exchange_rate,
                          p_projfunc_currency_code(i));
                else

                   IF (l_projfunc_bil_rate_date_code = 'PA_INVOICE_DATE' ) THEN
                         l_projfunc_bil_rate_date := G_processed_thru_date;
                   END IF;

                  begin  -- Bug 7423839
     		      IF g1_debug_mode  = 'Y' THEN
                         pa_debug.write_file('LOG', '5:i= '||i|| ' f_curr '||x_denom_tp_currency_code(i)||' t_curr '||p_projfunc_currency_code(i));
                         pa_debug.write_file('LOG', 'r_date '||l_projfunc_bil_rate_date|| ' r_type '||l_projfunc_bil_rate_type||' amt '||x_denom_transfer_price(i));
                         pa_debug.write_file('LOG', 'xfer_price '||l_projfunc_transfer_price|| ' denom '||l_denominator||' num '||l_numerator);
                         pa_debug.write_file('LOG', 'rate '||l_projfunc_bil_exchange_rate);
     		      END IF;
                    PA_MULTI_CURRENCY.Convert_Amount(
                    p_from_currency => x_denom_tp_currency_code(i),
                    p_to_currency => p_projfunc_currency_code(i),
                    p_conversion_date => l_projfunc_bil_rate_date,
                    p_conversion_type => l_projfunc_bil_rate_type,
                    p_amount => x_denom_transfer_price(i),
                    p_user_validate_flag => 'Y',
                    p_handle_exception_flag => 'Y',
                    p_converted_amount => l_projfunc_transfer_price,
                    p_denominator => l_denominator,
                    p_numerator => l_numerator,
                    p_rate => l_projfunc_bil_exchange_rate,
                    x_status => l_error_message
                    );
                 exception
                      when others then
     		      IF g1_debug_mode  = 'Y' THEN
                         pa_debug.write_file('LOG', 'r_date '||l_projfunc_bil_rate_date|| ' r_type '||l_projfunc_bil_rate_type);
                         pa_debug.write_file('LOG', 'xfer_price '||l_projfunc_transfer_price|| ' denom '||l_denominator||' num '||l_numerator);
                         pa_debug.write_file('LOG', 'rate '||l_projfunc_bil_exchange_rate|| ' err msg '||substr(l_error_message,1,300));
     		      END IF;
                      if l_error_message IS NULL THEN
                         l_error_message := 'OTHERS';
                      end if;
                 end;

                    IF l_error_message IS NOT NULL THEN

                      x_error_code(i) := 'PA_CC_TP_CONVERT_AMT';
     		      IF g1_debug_mode  = 'Y' THEN
                      pa_debug.write_file('LOG',
                        Substr (l_error_message,1,2000));
     		      END IF;
                    ELSE
                      x_projfunc_transfer_price (i) := l_projfunc_transfer_price;
                      x_projfunc_tp_rate_type(i) := l_projfunc_bil_rate_type;
                      x_projfunc_tp_rate_date(i) := l_projfunc_bil_rate_date;
                      x_projfunc_tp_exchange_rate(i) := l_projfunc_bil_exchange_rate;
                      pa_debug.G_Err_Stage := 'Rate Type ='||l_projfunc_bil_rate_type;
     		      IF g1_debug_mode  = 'Y' THEN
                      pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
     		      END IF;
                    END IF;


                 END IF; /* esle l_projfunc_bil_rate_type = 'User'*/

     IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG','AFTER CONVERSION');
         pa_debug.write_file('LOG','l_project_bil_rate_date_code: '||l_project_bil_rate_date_code);
         pa_debug.write_file('LOG','l_project_bil_rate_type: '||l_project_bil_rate_type);
         pa_debug.write_file('LOG','l_project_bil_rate_date: '||l_project_bil_rate_date);
         pa_debug.write_file('LOG','l_project_bil_exchange_rate: '||l_project_bil_exchange_rate);

         pa_debug.write_file('LOG','l_projfunc_bil_rate_date_code: '||l_projfunc_bil_rate_date_code);
         pa_debug.write_file('LOG','l_projfunc_bil_rate_type: '||l_projfunc_bil_rate_type);
         pa_debug.write_file('LOG','l_projfunc_bil_rate_date: '||l_projfunc_bil_rate_date);
         pa_debug.write_file('LOG','l_projfunc_bil_exchange_rate: '||l_projfunc_bil_exchange_rate);
     END IF;

    END IF ; /** l_multi_currency_billing_flag = 'Y' **/
  END IF; /** p_tp_amt_type_code(i) = 'REVENUE_TRANSFER' **/

--End devdrop2 changes



--Start devdrop2  changes

/** Currency conversion for p_tp_amt_type_code in ( 'COST_TRANSFER','COST_REVENUE') **/

             IF ( (nvl(p_tp_amt_type_code(i),'COST_REVENUE') in ( 'COST_TRANSFER','COST_REVENUE') )
                  OR
                  (l_multi_currency_billing_flag = 'N' ) ) then

               /* call the cost currency conversion api */

pa_multi_currency_txn.get_currency_amounts(
           P_project_id  => p_project_id(i),
           P_exp_org_id  => p_prvdr_operating_unit(i),
           p_Calling_module => p_module_name,
           P_task_id    => p_task_id(i),
           P_EI_date    => p_expenditure_item_date(i),
           P_denom_raw_cost   => x_denom_transfer_price(i),
           P_denom_curr_code   => x_denom_tp_currency_code(i),
           P_acct_curr_code    => G_acct_currency_code,
           P_accounted_flag    => 'N',
           P_acct_rate_date    => x_acct_tp_rate_date(i),
           P_acct_rate_type    => x_acct_tp_rate_type(i),
           P_acct_exch_rate    => x_acct_tp_exchange_rate(i),
           P_acct_raw_cost     => x_acct_transfer_price(i),
           P_project_curr_code => p_project_currency_code(i),
           P_project_rate_type => x_proj_tp_rate_type(i),
           P_project_rate_date => x_proj_tp_rate_date(i),
           P_project_exch_rate => x_proj_tp_exchange_rate(i),
           P_project_raw_cost  => x_proj_transfer_price(i),
           P_projfunc_curr_code => p_projfunc_currency_code(i),
           P_projfunc_cost_rate_type => x_projfunc_tp_rate_type(i),
           P_projfunc_cost_rate_date => x_projfunc_tp_rate_date(i),
           P_projfunc_cost_exch_rate => x_projfunc_tp_exchange_rate(i),
           P_projfunc_raw_cost           => x_projfunc_transfer_price(i),
           P_system_linkage    => p_system_linkage_function(i),
           P_status            => x_error_code(i),
           P_stage             => l_stage );

           END IF; /*else p_tp_amt_type_code(i) in ( 'COST_TRANSFER','COST_REVENUE') */
      END IF; /* if p_tp_amt_type_code is NOT NULL  - bug6389559*/
--End devdrop2 changes

  END IF; /** (l_compute_flag(i) = 'C'**/

	    ELSE
	       x_error_code(i) := 'PA_CC_TP_CONV_DENOM_CURR_NULL';
            END IF; /** x_denom_tp_currency_code(i) is not null **/
	 END IF; /** x_denom_transfer_price(i) IS NOT NULL **/

      END IF; /**  x_error_code(i) IS NULL **/

   END LOOP;

   pa_debug.G_Err_Stage := 'Completed Get_Transfer_Price with success';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;
   x_return_status := 0;
   pa_debug.Reset_err_stack;

EXCEPTION
   when unexpected_result THEN
   IF g1_debug_mode  = 'Y' THEN
      pa_debug.write_file('LOG','Unexpected Error in Transfer Price API' );
      pa_debug.write_file('LOG',pa_debug.G_Err_Stack);
      pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

   when others then

   IF g1_debug_mode  = 'Y' THEN
      pa_debug.write_file('LOG','Unexpected Error in Transfer Price API' );
      pa_debug.write_file('LOG',pa_debug.G_Err_Stack);
      pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

      raise;

END GET_transfer_price;

-------------------------------------------------------------------------------
PROCEDURE Init_who_cols
IS
BEGIN

   pa_debug.Set_err_stack ('Init_who_cols');
   pa_debug.G_Err_Stage := 'Inside Init_who_cols';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

   G_created_by        := nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1);
   G_last_update_login := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')), -1);
   G_last_updated_by   := G_created_by;
   G_creation_date     := G_sysdate;
   G_last_update_date  := G_sysdate ;

   pa_debug.Reset_err_stack;

END Init_who_cols ;

-------------------------------------------------------------------------------

PROCEDURE Get_Legal_Entity (
	p_org_id		IN	NUMBER,
	x_legal_entity_id 	OUT	NOCOPY NUMBER /*File.sql.39*/
			)
IS

Cursor c_legal_entity
is
SELECT org_information2 legal_entity_id
  FROM hr_organization_information
 WHERE organization_id = p_org_id
   AND org_information_context = 'Operating Unit Information';

/* Commented for bug 4920063. Added Above statement for LE
select legal_entity_id
from   pa_implementations_all
where  org_id = p_org_id;*/

/*l_legal_entity   pa_implementations_all.legal_entity_id%TYPE;	 Commented for bug 2920063*/

l_legal_entity hr_organization_information.org_information2%TYPE;

BEGIN

   pa_debug.Set_err_stack ('Get_Legal_Entity');
   pa_debug.G_Err_Stage := 'Get Legal Entity of Org'||to_char(p_org_id);
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

   open c_legal_entity;
   fetch c_legal_entity into  l_legal_entity;
   close c_legal_entity;

   IF l_legal_entity IS NOT NULL THEN
      x_legal_entity_id := to_number(l_legal_entity);
       -- conversion required as legal_entity_id is stored as varchar2
       -- in hr_operating_units
   END IF;

   pa_debug.Reset_err_stack;

EXCEPTION

WHEN OTHERS THEN
raise;

END Get_Legal_Entity;
-------------------------------------------------------------------------------
PROCEDURE Set_Global_Variables   /** Added for Org Forecasting **/
          ( p_org_id              IN      NUMBER)
IS

BEGIN

--SS-ORG-CHANGE
--Added nvl to G_prvdr_org_id

IF nvl(G_prvdr_org_id,-1) <> p_org_id and g_Calling_Module = 'FORECAST' Then

   pa_debug.Set_err_stack ('Set_Global_Variables ');
   pa_debug.G_Err_Stage := 'Set_Global_Variables '||to_char(p_org_id);
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

  G_prvdr_org_id 			:= G_prvdr_org_id_Tab(p_org_id);
  G_bg_id        			:= G_bg_id_Tab(p_org_id);
  G_acct_currency_code 		:= G_acct_currency_code_Tab(p_org_id);
  G_cc_default_rate_type 	:= G_cc_default_rate_type_Tab(p_org_id);
  G_cc_default_rate_date_code := G_cc_def_rate_date_code_Tab(p_org_id);
  G_exp_org_struct_ver_id     := G_exp_org_struct_ver_Tab(p_org_id);

END IF;

EXCEPTION

WHEN OTHERS THEN
raise;
END Set_Global_Variables;

-------------------------------------------------------------------------------
PROCEDURE Get_business_group (
        p_org_id                IN      NUMBER,
        x_business_group_id     OUT     NOCOPY NUMBER /*File.sql.39*/
                        )
IS

Cursor c_business_group
is
select business_group_id
from   hr_operating_units
where  organization_id = p_org_id;

l_business_group   hr_operating_units.business_group_id%TYPE;

BEGIN
   pa_debug.Set_err_stack ('Get_Business_group');
   pa_debug.G_Err_Stage := 'Get bisiness_group of Org'||to_char(p_org_id);
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

   open c_business_group;
   fetch c_business_group into  l_business_group;
   close c_business_group;

   IF l_business_group IS NOT NULL THEN
      x_business_group_id := l_business_group;
   END IF;

   pa_debug.Reset_err_stack;

EXCEPTION

WHEN OTHERS THEN
raise;

END Get_business_group;

-------------------------------------------------------
PROCEDURE Get_Provider_Attributes (
                p_prvdr_operating_unit         IN      PA_PLSQL_DATATYPES.IdTabTyp
                               DEFAULT PA_PLSQL_DATATYPES.EmptyIDTab,
                x_error_code            IN OUT  NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp )
IS
   cursor c_ou_attributes
   is
   select org_id,business_group_id,cc_default_rate_type,cc_default_rate_date_code,
          EXP_ORG_STRUCTURE_VERSION_ID
   from pa_implementations;

   cursor c_ou_attributes_fcst (l_org_id number)
   is
   select org_id,business_group_id,cc_default_rate_type,cc_default_rate_date_code,
          EXP_ORG_STRUCTURE_VERSION_ID
   from pa_implementations_all
   where org_id = l_org_id;

   cursor c_ou_curr_code_fcst (l_org_id Number)
   is
   SELECT FC.Currency_Code
     FROM FND_CURRENCIES FC,
          GL_SETS_OF_BOOKS GB,
          PA_IMPLEMENTATIONS_ALL IMP
    WHERE FC.Currency_Code = DECODE(IMP.Set_Of_Books_ID, Null, Null,GB.CURRENCY_CODE)
      AND GB.Set_Of_Books_ID = IMP.Set_Of_Books_ID
      AND IMP.Org_Id = l_org_id;

   l_provider_org_id pa_implementations.org_id%type;

BEGIN
   pa_debug.Set_err_stack ('Get_Provider_Attributes');
   pa_debug.G_Err_Stage := 'Inside Get_Provider_Attributes';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

     If G_Calling_module = 'FORECAST' Then
        Begin
          For i in 1 .. G_array_size Loop
	   pa_debug.G_Err_Stage := 'i: '||to_char(i)||' error code : '||x_error_code(i);
   	   IF g1_debug_mode  = 'Y' THEN
   	   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	   END IF;


          l_provider_org_id := nvl(p_prvdr_operating_unit(i),-1);
            If   G_prvdr_org_id_tab.Exists(l_provider_org_id)
            Then Null;
   		IF g1_debug_mode  = 'Y' THEN
		pa_debug.write_file('LOG','i :'||to_char(i)||' Exist ');
   		END IF;
            Else
                open  c_ou_attributes_fcst (l_provider_org_id);
                fetch c_ou_attributes_fcst
                into  G_prvdr_org_id_tab(l_provider_org_id),
                      G_bg_id_tab(l_provider_org_id),
                      G_cc_default_rate_type_tab(l_provider_org_id),
                      G_cc_def_rate_date_code_tab(l_provider_org_id),
                      G_exp_org_struct_ver_tab(l_provider_org_id);
                close c_ou_attributes_fcst;

                open  c_ou_curr_code_fcst (l_provider_org_id);

                fetch c_ou_curr_code_fcst
                into  G_acct_currency_code_Tab (l_provider_org_id);
                Close c_ou_curr_code_fcst ;


             End If; /** G_prvdr_org_id_tab.Exists **/

   pa_debug.G_Err_Stage :=  'I : '||to_char(i)||' p_prvdr_operating_unit(i) '||to_char(l_provider_org_id)||
                           ' G_prvdr_org_id_tab(l_provider_org_id): '||to_char(G_prvdr_org_id_tab(l_provider_org_id));

   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

          End loop;
        End;
     Else /** Since Calling Module is Not FORECAST Code need not be independant of OU **/
   open c_ou_attributes;

--DevDrop2 Changes
--Added G_exp_org_struct_ver_id variable.

     fetch c_ou_attributes
     into G_prvdr_org_id,G_bg_id,G_cc_default_rate_type,
    	  G_cc_default_rate_date_code,
          G_exp_org_struct_ver_id;

     close c_ou_attributes;

   -- Get accounting currency code of the provider
      G_acct_currency_code := PA_MULTI_CURRENCY.Get_Acct_Currency_Code;
     End If;  /** End p_module_name = 'FORECAST' **/
   pa_debug.Reset_err_stack;

EXCEPTION
   when others then
      raise;

END Get_Provider_Attributes;
--------------------------------------------------------------------------------
PROCEDURE Validate_Array
	(
        p_prvdr_operating_unit         IN      PA_PLSQL_DATATYPES.IdTabTyp
                               DEFAULT PA_PLSQL_DATATYPES.EmptyIDTab ,
	p_tp_schedule_id			IN	PA_PLSQL_DATATYPES.IdTabTyp,
	p_denom_tp_currency_code	IN 	PA_PLSQL_DATATYPES.Char15TabTyp,
      p_acct_currency_code          IN      varchar2 ,
	p_denom_transfer_price		IN 	PA_PLSQL_DATATYPES.NumTabTyp,
	p_acct_tp_rate_type		IN 	PA_PLSQL_DATATYPES.Char30TabTyp,
	p_acct_tp_rate_date		IN 	PA_PLSQL_DATATYPES.DateTabTyp,
	p_acct_transfer_price		IN 	PA_PLSQL_DATATYPES.NumTabTyp,
	p_acct_tp_exchange_rate       IN    PA_PLSQL_DATATYPES.NumTabTyp,
	x_compute_flag 			IN OUT  NOCOPY 	PA_PLSQL_DATATYPES.Char1TabTyp,
	x_error_code			IN OUT  NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp
	)
IS
l_acct_currency_code FND_CURRENCIES.CURRENCY_CODE%TYPE ;  /** Added for Org Forecasting **/
BEGIN
   pa_debug.Set_err_stack ('Validate_Array');
   pa_debug.G_Err_Stage := 'Starting Validate_Array';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

l_acct_currency_code  := p_acct_currency_code;   /** Added for Org Forecasting **/

   For i in 1 .. G_array_Size
   Loop
      pa_debug.G_Err_Stage := 'Start Loop';
      -- Consider records with error_code is null and compute_flag = 'Y'
      IF (x_compute_flag(i) = 'Y' ) THEN
	  IF ( x_error_code(i) IS NULL ) THEN
          -- Check if transfer price is already available -
             pa_debug.G_Err_Stage := 'Flagged as error-free';
   	     IF g1_debug_mode  = 'Y' THEN
             pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	     END IF;

            IF G_Calling_Module = 'FORECAST' Then /** Added for Org Forecasting **/
               l_acct_currency_code := G_acct_currency_code_Tab(p_prvdr_operating_unit(i));
            END IF; /** Module Name = FORECAST **/

          IF (p_denom_transfer_price(i) IS NOT NULL
            and nvl(p_denom_tp_currency_code(i),'-1') <> nvl(l_acct_currency_code,'-1')) THEN
	/** Changed p_acct_currency_code to l_acct_currency_code for  Org Forecasting **/
              pa_debug.G_Err_Stage := 'Reconversion Case';
   	      IF g1_debug_mode  = 'Y' THEN
              pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	      END IF;
              -- Check if all conversion attributes are provided

		IF( ( (p_acct_tp_rate_type(i) IS NOT NULL) AND
		       (p_acct_tp_rate_date(i) IS NOT NULL) )
		     OR
		     ((p_acct_tp_rate_type(i) = 'User') AND
		      (p_acct_tp_exchange_rate(i) IS NOT NULL) ) )  THEN


		-- Only reconversion needed

		    x_compute_flag(i) := 'C';

                ELSE
		   x_error_code(i) := 'PA_CC_TP_CURR_CONVERSION_ATTR';
                END IF;

           ELSE
              pa_debug.G_Err_Stage := 'Calculate Transfer Price';
	      -- Need to calculate transfer price

	      -- Check if schedule_id is provided
	      IF p_tp_schedule_id(i) IS NULL THEN
		 x_error_code(i) := 'PA_CC_TP_SCH_ID_NULL';
              END IF;

           END IF; /** p_denom_transfer_price IS NOT NULL **/
	   END IF;

       END IF; /**x_compute_flag(i) = 'Y' AND x_error_code(i) IS NULL **/

   END Loop;

   pa_debug.Reset_err_stack;
   pa_debug.G_Err_Stage := 'Exitting Validate_Array ';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

EXCEPTION
   when others then
      raise;
END Validate_Array;
--------------------------------------------------------------------------------
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
        p_prvdr_operating_unit          IN      PA_PLSQL_DATATYPES.IdTabTyp
                               DEFAULT PA_PLSQL_DATATYPES.EmptyIDTab ,
				/** Added for Org Forecasting **/

--End   Added for devdrop2
	x_error_code		IN OUT  NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
	x_tp_schedule_line_id	OUT	NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp,
      x_tp_schedule_line_percentage IN OUT NOCOPY  PA_PLSQL_DATATYPES.NumTabTyp,
	x_tp_rule_id		OUT	NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp
			  )
IS
l_tp_schedule_line_id	Number;
l_start_date_active	Date;
l_end_date_active	Date;
l_tp_rule_id      Number;
l_percentage_applied Number;
p_sort_order Number;  -- Added for bug 5753774

BEGIN

   pa_debug.Set_err_stack ('Get_Schedule_Line');
   pa_debug.G_Err_Stage := 'Starting Get_Schedule_Line';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

   For i in 1 ..G_array_Size
   Loop
      If G_Calling_module = 'FORECAST' Then   /** Added for Org Forecasting **/

      pa_debug.G_Err_Stage := 'p_prvdr_operating_unit: '||
					to_char(p_prvdr_operating_unit(i));
   IF g1_debug_mode  = 'Y' THEN
      pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

      Set_Global_Variables (p_prvdr_operating_unit(i));
      Get_legal_entity (G_prvdr_org_id,G_prvdr_legal_entity_id);
      End If;


      pa_debug.G_Err_Stage := 'Processing Expenditure ID: '||
					to_char(p_expenditure_item_id(i));
   IF g1_debug_mode  = 'Y' THEN
      pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

      pa_debug.G_Err_Stage := 'p_compute_flag: '||p_compute_flag(i);
   IF g1_debug_mode  = 'Y' THEN
      pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

      pa_debug.G_Err_Stage := 'x_error_code: '||x_error_code(i);
   IF g1_debug_mode  = 'Y' THEN
      pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

      IF (p_compute_flag(i) = 'Y' AND
		x_error_code(i) is null ) THEN

   --check if the schedule line already exists in PA_CC_TP_SCHEDULE_LINE_LOOKUP
          Get_Schedule_Line_From_Lookup(
 	      p_prvdr_organization_id (i),
              p_recvr_org_id (i),
              p_recvr_organization_id(i),
	      p_tp_schedule_id (i),
	      p_labor_non_labor_flag(i),
--Start Added for devdrop2
	      p_tp_amt_type_code(i),
--End   Added for devdrop2
              /* Start Added for 3118101 */
              p_expenditure_item_date(i),
              /* End Added for 3118101 */

	      x_tp_schedule_line_id(i) );

          IF x_tp_schedule_line_id(i) IS NULL THEN
	  -- Find out schedule_line_id

             pa_debug.G_Err_Stage := 'Find out  Schedule_Line_ID';
             Determine_Schedule_Line(
 	         p_prvdr_organization_id(i),
                 p_recvr_org_id(i),
                 p_recvr_organization_id(i),
	         p_tp_schedule_id(i),
		 p_labor_non_labor_flag(i),
                 /* Start Added for 3118101 */
                 p_expenditure_item_date(i),
                 /* End Added for 3118101 */
--Start Added for devdrop2
                 p_tp_amt_type_code(i),
--End   Added for devdrop2
	         x_tp_schedule_line_id(i),
	         l_tp_rule_id,
	         l_percentage_applied,
	         l_start_date_active,
	         l_end_date_active,
                 p_sort_order, -- added for bug 5753774
	         x_error_code(i)  );

     		 IF g1_debug_mode  = 'Y' THEN
                 pa_debug.write_file('LOG','Error Code'||x_error_code(i));
   	         END IF;

	       l_tp_schedule_line_id := x_tp_schedule_line_id(i);

               IF ( x_error_code(i) IS NULL ) THEN
	       -- No error from Determine_Schedule_Line

                  pa_debug.G_Err_Stage := 'Insert Schedule Line into Lookup';
              --   pa_debug.G_Err_Stage := 'Sort order is :'||x_sort_order ;/*bug 5753774*/

                  Insert_Schedule_Line_Into_Lkp(
 	                   p_prvdr_organization_id(i),
                           p_recvr_org_id (i),
                           p_recvr_organization_id(i),
	                   p_tp_schedule_id (i),
	                   l_tp_schedule_line_id,
                           p_labor_non_labor_flag(i),
--Start Added for devdrop2
	                   p_tp_amt_type_code(i),
--End   Added for devdrop2
	                   l_start_date_active,
	                   l_end_date_active,
                           p_sort_order,   -- added for bug 5753774
			   x_error_code(i)
	                                       );
               END IF;

          ELSE

	     l_tp_schedule_line_id := x_tp_schedule_line_id(i);
	     -- Get Schedule Line attributes
             pa_debug.G_Err_Stage := 'Get Schedule Line Attributes';

             Get_Schedule_Line_Attributes(
	         l_tp_schedule_line_id,
                 p_labor_non_labor_flag(i),
	         l_tp_rule_id,
	         l_percentage_applied,
		 x_error_code(i) );
          END IF;
	  -- Set the OUT variables
	  x_tp_schedule_line_id(i) := l_tp_schedule_line_id;
          x_tp_schedule_line_percentage(i) := l_percentage_applied;
	  x_tp_rule_id (i) := l_tp_rule_id;
          pa_debug.G_Err_Stage := 'Rule ID is '||to_char(x_tp_rule_id(i));
          IF g1_debug_mode  = 'Y' THEN
          pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
          END IF;


      END IF; /** p_compute_flag = 'Y' and x_error_code is null **/

   pa_debug.G_Err_Stage := 'Completed Processing the item';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;
   pa_debug.G_Err_Stage := '..................................................';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

   End Loop;

   pa_debug.Reset_err_stack;
   pa_debug.G_Err_Stage := 'Exitting Get_Schedule_Line';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      raise;

END Get_Schedule_Line;
------------------------------------------------------------------------------
PROCEDURE Get_Schedule_Line_From_Lookup(
 	p_prvdr_organization_id		IN 	Number,
        p_recvr_org_id			IN 	Number,
        p_recvr_organization_id		IN 	Number,
	p_tp_schedule_id		IN	Number,
	p_labor_flag		        IN	Varchar2,
--Start Added for devdrop2
	p_tp_amt_type_code              IN      Varchar2,
--End   Added for devdrop2
        /* Start Added for 3118101 */
        p_expenditure_item_date         IN      Date,
        /* End Added for 3118101 */
	x_tp_schedule_line_id		OUT	NOCOPY Number /*File.sql.39*/
					)
IS

Cursor c_schedule_line
is
select tp_schedule_line_id
from   PA_CC_TP_SCHEDULE_LINE_LKP
where
      tp_schedule_id = p_tp_schedule_id
and   prvdr_organization_id = p_prvdr_organization_id
and   recvr_organization_id = p_recvr_organization_id
and   prvdr_org_id        = G_prvdr_org_id
and   recvr_org_id        = p_recvr_org_id
and   labor_flag          = p_labor_flag
and    decode( nvl(tp_amt_type_code,'COST_REVENUE'),
               'COST_REVENUE',nvl(p_tp_amt_type_code,'COST_REVENUE'),
               tp_amt_type_code)       = nvl(p_tp_amt_type_code,'COST_REVENUE')
/* and   trunc(G_processed_thru_date) between  Commented for 3118101 */
and   trunc(p_expenditure_item_date) between      /* Added for 3118101 */
      trunc(start_date_active) and
/*    trunc(NVL(end_date_active,G_processed_thru_date)); Commented for 3118101 */
      trunc(NVL(end_date_active,p_expenditure_item_date))  /* Added for 3118101 */
ORDER BY sort_order; /*Bug 5753774*/

BEGIN
   pa_debug.Set_err_stack ('Get_Schedule_Line_From_Lookup');
   pa_debug.G_Err_Stage := 'Starting Get_Schedule_Line_From_Lookup';
   IF g1_debug_mode  = 'Y' THEN
   Pa_debug.write_file('LOG',pa_debug.G_Err_Stage);

   Pa_debug.write_file('LOG','prvdr_oranz_id '||p_prvdr_organization_id||
                             ' recv_organz_id '||p_recvr_organization_id||
                             'prvdr_org_id '||G_prvdr_org_id||
                             'p_recvr_org_id '||p_recvr_org_id||
                             ' sch_id '||p_tp_schedule_id);
   Pa_debug.write_file('LOG','p_labor_flag '||p_labor_flag||
                             ' tp_amt_type_code  '||p_tp_amt_type_code||
                            ' p_expenditure_item_date  '||to_char(p_expenditure_item_date));  /* Added for 3118101 */
   END IF;

   open c_schedule_line;

   fetch c_schedule_line
   into x_tp_schedule_line_id;

   close c_schedule_line;


   pa_debug.Reset_err_stack;
   pa_debug.G_Err_Stage := 'Exitting Get_Schedule_Line_From_Lookup';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      raise;
END Get_Schedule_Line_From_Lookup;
-------------------------------------------------------------------------------
PROCEDURE Determine_Schedule_Line(
 	p_prvdr_organization_id		IN 	Number,
        p_recvr_org_id			IN 	Number,
        p_recvr_organization_id		IN 	Number,
	p_tp_schedule_id		IN	Number,
	p_labor_non_labor_flag		IN	Varchar2,
        /* Start Added for 3118101 */
        p_expenditure_item_date         IN      Date,
        /* End Added for 3118101 */
--Start Added for devdrop2
        p_tp_amt_type_code              IN      Varchar2,
--End   Added for devdrop2
	x_tp_schedule_line_id		OUT	NOCOPY Number,/*File.sql.39*/
	x_tp_rule_id		        OUT	NOCOPY Number,/*File.sql.39*/
	x_percentage_applied            OUT	NOCOPY Number,/*File.sql.39*/
	x_start_date_active		OUT	NOCOPY Date,/*File.sql.39*/
	x_end_date_active		OUT	NOCOPY Date,/*File.sql.39*/
        x_sort_order                    OUT     NOCOPY NUMBER/*bug 5753774*/,
	x_error_code			IN OUT	NOCOPY VARCHAR2 /*File.sql.39*/
				    )
IS

cursor c_rule( l_prvdr_organization_id Number,
	       l_recvr_organization_id Number)
is
select tp_schedule_line_id,sort_order,  -- Added for bug 5753774
       Decode(p_labor_non_labor_flag,'Y',labor_tp_rule_id,
	      nl_tp_rule_id) rule_id,
       Decode(p_labor_non_labor_flag,'Y',labor_percentage_applied,
	nl_percentage_applied) percentage_applied
	,start_date_active
	,end_date_active
from   pa_cc_tp_schedule_lines
where  tp_schedule_id = p_tp_schedule_id
and    prvdr_organization_id = l_prvdr_organization_id
and    recvr_organization_id = l_recvr_organization_id
and    decode( nvl(tp_amt_type_code,'COST_REVENUE'),
               'COST_REVENUE',nvl(p_tp_amt_type_code,'COST_REVENUE'),
               tp_amt_type_code)       = nvl(p_tp_amt_type_code,'COST_REVENUE')
and    ((p_labor_non_labor_flag='Y' and labor_tp_rule_id is not null)
         OR (p_labor_non_labor_flag='N' and nl_tp_rule_id is not null))
/* and    trunc(G_processed_thru_date) between trunc(start_date_active) Commented for 3118101 */
and    trunc(p_expenditure_item_date) between trunc(start_date_active)  /* Added for 3118101 */
/*     and trunc(NVL(end_date_active,G_processed_thru_date)); Commented for 3118101 */
       and trunc(NVL(end_date_active,p_expenditure_item_date)); /* Added for 3118101 */

--DevDrop2 Changes start

cursor c_parent_rule ( l_prvdr_organization_id Number,
                       l_recvr_organization_id Number)
is
select a.tp_schedule_line_id,sort_order, -- Added for bug 5753774
       Decode(p_labor_non_labor_flag,'Y',a.labor_tp_rule_id,
              a.nl_tp_rule_id) rule_id,
       Decode(p_labor_non_labor_flag,'Y',a.labor_percentage_applied,
        a.nl_percentage_applied) percentage_applied,
        a.start_date_active,
        a.end_date_active
from  pa_cc_tp_schedule_lines a,
      pa_org_hierarchy_denorm b,
      pa_org_hierarchy_denorm c
where a.tp_schedule_id = p_tp_schedule_id
and   a.PRVDR_ORGANIZATION_ID = b.PARENT_ORGANIZATION_ID
and   b.CHILD_ORGANIZATION_ID = l_prvdr_organization_id
and   a.RECVR_ORGANIZATION_ID = c.PARENT_ORGANIZATION_ID
and   c.CHILD_ORGANIZATION_ID = l_recvr_organization_id
and   b.org_hierarchy_version_id = G_exp_org_struct_ver_id
and   c.org_hierarchy_version_id = G_prj_org_struct_ver_id
and  b.pa_org_use_type = 'TP_SCHEDULE'
and  c.pa_org_use_type = 'TP_SCHEDULE'
and    decode( nvl(tp_amt_type_code,'COST_REVENUE'),
               'COST_REVENUE',nvl(p_tp_amt_type_code,'COST_REVENUE'),
               tp_amt_type_code)       = nvl(p_tp_amt_type_code,'COST_REVENUE')
and    ((p_labor_non_labor_flag='Y' and a.labor_tp_rule_id is not null)
         OR (p_labor_non_labor_flag='N' and a.nl_tp_rule_id is not null))
/* and    trunc(G_processed_thru_date) between trunc(a.start_date_active)   Commented for 3118101 */
and    trunc(p_expenditure_item_date) between trunc(a.start_date_active) /* Added for 3118101 */
/*     and trunc(NVL(a.end_date_active,G_processed_thru_date)) Commented for 3118101 */
       and trunc(NVL(a.end_date_active,p_expenditure_item_date)) /* Added for 3118101 */
order by  b.parent_level desc , c.PARENT_LEVEL desc;


cursor c_prvdr_organz_rule( l_prvdr_organization_id Number,
               l_recvr_organization_id Number)
is
select tp_schedule_line_id,sort_order,  -- Added for bug 5753774
       Decode(p_labor_non_labor_flag,'Y',labor_tp_rule_id,
              nl_tp_rule_id) rule_id,
       Decode(p_labor_non_labor_flag,'Y',labor_percentage_applied,
        nl_percentage_applied) percentage_applied
        ,start_date_active
        ,end_date_active
from   pa_cc_tp_schedule_lines a,
       pa_org_hierarchy_denorm b
where  a.tp_schedule_id = p_tp_schedule_id
and   a.PRVDR_ORGANIZATION_ID = b.PARENT_ORGANIZATION_ID
and   b.CHILD_ORGANIZATION_ID = l_prvdr_organization_id
and   b.org_hierarchy_version_id = G_exp_org_struct_ver_id
and    a.recvr_organization_id = l_recvr_organization_id
and  b.pa_org_use_type = 'TP_SCHEDULE'
and    decode( nvl(tp_amt_type_code,'COST_REVENUE'),
               'COST_REVENUE',nvl(p_tp_amt_type_code,'COST_REVENUE'),
               tp_amt_type_code)       = nvl(p_tp_amt_type_code,'COST_REVENUE')
and    ((p_labor_non_labor_flag='Y' and a.labor_tp_rule_id is not null)
         OR (p_labor_non_labor_flag='N' and a.nl_tp_rule_id is not null))
/* and    trunc(G_processed_thru_date) between trunc(a.start_date_active) Commented for 3118101 */
and    trunc(p_expenditure_item_date) between trunc(a.start_date_active)  /* Added for 3118101 */
/*     and trunc(NVL(a.end_date_active,G_processed_thru_date)) Commented for 3118101 */
       and trunc(NVL(a.end_date_active,p_expenditure_item_date)) /* Added for 3118101 */
order by  b.parent_level desc;

--DevDrop2 Changes End


--DevDrop2 Changes
--Added pa_org_hierarchy_denorm join to the below cursor.


cursor c_other_rule(l_prvdr_organization_id NUMBER)
is
select a.tp_schedule_line_id,sort_order, -- Added for Bug 5753774
       Decode(p_labor_non_labor_flag,'Y',a.labor_tp_rule_id,
				  a.nl_tp_rule_id) rule_id,
       Decode(p_labor_non_labor_flag,'Y',a.labor_percentage_applied,
       a.nl_percentage_applied) percentage_applied
	,a.start_date_active
	,a.end_date_active
from   pa_cc_tp_schedule_lines a,
       pa_org_hierarchy_denorm b
where  a.tp_schedule_id = p_tp_schedule_id
and   a.PRVDR_ORGANIZATION_ID = b.PARENT_ORGANIZATION_ID
and   b.CHILD_ORGANIZATION_ID = l_prvdr_organization_id
and    a.recvr_organization_id is null
and   b.org_hierarchy_version_id = G_exp_org_struct_ver_id
and  b.pa_org_use_type = 'TP_SCHEDULE'
and    decode( nvl(tp_amt_type_code,'COST_REVENUE'),
               'COST_REVENUE',nvl(p_tp_amt_type_code,'COST_REVENUE'),
               tp_amt_type_code)       = nvl(p_tp_amt_type_code,'COST_REVENUE')
and    ((p_labor_non_labor_flag='Y' and a.labor_tp_rule_id is not null)
         OR (p_labor_non_labor_flag='N' and a.nl_tp_rule_id is not null))
/* and    trunc(G_processed_thru_date) between trunc(a.start_date_active) Commented for 3118101 */
and    trunc(p_expenditure_item_date) between trunc(a.start_date_active)  /* Added for 3118101 */
/*     and trunc(NVL(a.end_date_active,G_processed_thru_date)) Commented for 3118101 */
       and trunc(NVL(a.end_date_active,p_expenditure_item_date))  /* Added for 3118101 */
order by b.parent_level  desc;

cursor c_default_rule
is
select tp_schedule_line_id,sort_order, --Added for bug 5753774
       Decode(p_labor_non_labor_flag,'Y',labor_tp_rule_id,
                                  nl_tp_rule_id) rule_id,
       Decode(p_labor_non_labor_flag,'Y',labor_percentage_applied,
       nl_percentage_applied) percentage_applied
        ,start_date_active
        ,end_date_active
from   pa_cc_tp_schedule_lines
where  tp_schedule_id = p_tp_schedule_id
and    default_flag ='Y'
and    ((p_labor_non_labor_flag='Y' and labor_tp_rule_id is not null)
         OR (p_labor_non_labor_flag='N' and nl_tp_rule_id is not null))
/* and    trunc(G_processed_thru_date) between trunc(start_date_active) Commented for 3118101 */
and    trunc(p_expenditure_item_date) between trunc(start_date_active) /* Added for 3118101 */
/*     and trunc(NVL(end_date_active,G_processed_thru_date)); Commented for 3118101 */
       and trunc(NVL(end_date_active,p_expenditure_item_date)); /* Added for 3118101 */

l_recvr_legal_entity_id	Number;
l_recvr_business_group_id number;

BEGIN
   pa_debug.Set_err_stack ('Determine_Schedule_Line');
   pa_debug.G_Err_Stage := 'Starting Determine_Schedule_Line';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);


         pa_debug.write_file('LOG',
                     'p_prvdr_organization_id '||p_prvdr_organization_id);
         pa_debug.write_file('LOG',
                     'p_recvr_org_id '||p_recvr_org_id);
         pa_debug.write_file('LOG',
                     'p_recvr_organization_id '||p_recvr_organization_id);
         pa_debug.write_file('LOG',
                     'p_recvr_org_id '||p_recvr_org_id);
         pa_debug.write_file('LOG',
                     'p_tp_schedule_id '||p_tp_schedule_id);
         pa_debug.write_file('LOG',
                     'p_labor_non_labor_flag '||p_labor_non_labor_flag);
         pa_debug.write_file('LOG',
                     'p_tp_amt_type_code '||p_tp_amt_type_code);
         pa_debug.write_file('LOG',
                     'G_exp_org_struct_ver_id '||G_exp_org_struct_ver_id);
         pa_debug.write_file('LOG',
                     'G_prj_org_struct_ver_id '||G_prj_org_struct_ver_id);
   END IF;

   -- Use Rule1


   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG','Testing Rule 1');
   END IF;

   open c_rule (p_prvdr_organization_id,p_recvr_organization_id);
   fetch c_rule
   into x_tp_schedule_line_id,x_sort_order,x_tp_rule_id,x_percentage_applied, -- added for bug 5753774
			      x_start_date_active,x_end_date_active;

   IF c_rule%FOUND THEN
      IF (x_tp_rule_id IS NOT NULL) THEN
         close c_rule;
         pa_debug.Reset_err_stack;
         pa_debug.G_Err_Stage := 'Schedule Line found using Rule1';
   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
         pa_debug.write_file('LOG','x_tp_schedule_line_id='||x_tp_schedule_line_id); -- Added for bug 5753774
          pa_debug.write_file('LOG','x_sort_order='||x_sort_order);

   	END IF;
         Return;
      END IF;
   END IF;

   close c_rule;

--DevDrop2 Changes  Start

   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG','Testing Parent Rule ');
   	END IF;

  if ( nvl(G_prev_rcvr_org_id,-1) <> nvl(p_recvr_org_id,-1) ) then
    G_prev_rcvr_org_id := p_recvr_org_id;
    select PROJ_ORG_STRUCTURE_VERSION_ID into G_prj_org_struct_ver_id
    from pa_implementations_all
    where org_id = nvl(G_prev_rcvr_org_id,-1); /* For Bug 5900371. Modified nvl(org_id,-1) to org_id as Org_id is mandatory in R12 and hence can never be Null */
  end if;


   open c_parent_rule (p_prvdr_organization_id,p_recvr_organization_id);
   fetch c_parent_rule
   into x_tp_schedule_line_id,x_sort_order,x_tp_rule_id,x_percentage_applied, --added for bug 5753774
                              x_start_date_active,x_end_date_active;

   IF c_parent_rule%FOUND THEN
      IF (x_tp_rule_id IS NOT NULL) THEN
         close c_parent_rule;
         pa_debug.Reset_err_stack;
         pa_debug.G_Err_Stage := 'Schedule Line found using Parent Rule';
   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
          pa_debug.write_file('LOG','x_tp_schedule_line_id='||x_tp_schedule_line_id); -- Added for bug 5753774
          pa_debug.write_file('LOG','x_sort_order='||x_sort_order);
   	END IF;
         Return;
      END IF;
   END IF;


--DevDrop2 Changes  End

--Devdrop2 Changes Changed c_rule cursor to c_prvdr_organz_rule

   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG','Testing Rule 2');
   	END IF;

/* **************************************************************
 COMMENTED FOR LEGAL ENTITY TRANSFER PRICE SCHEDULE. aFTER 12.0 THERE
 IS NO CONCEPT OF OU,LE AND BG check every thing should be maintained
   in org hierarchy

   -- Use Rule2
   open c_prvdr_organz_rule (p_prvdr_organization_id,p_recvr_org_id);
   fetch c_prvdr_organz_rule
   into x_tp_schedule_line_id,x_sort_order,x_tp_rule_id,x_percentage_applied  --Added for bug 5753774
			      ,x_start_date_active,x_end_date_active;


   IF c_prvdr_organz_rule%FOUND THEN
      IF (x_tp_rule_id IS NOT NULL) THEN
         close c_prvdr_organz_rule;
         pa_debug.Reset_err_stack;
         pa_debug.G_Err_Stage := 'Schedule Line found using Rule2';
   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	END IF;
         Return;
      END IF;
   END IF;

   close c_prvdr_organz_rule;

   -- Get receiver's legal entity id
   Get_Legal_Entity (p_recvr_org_id, l_recvr_legal_entity_id);


--Devdrop2 Changes Changed c_rule cursor to c_prvdr_organz_rule
   -- Use Rule3
   open c_prvdr_organz_rule (p_prvdr_organization_id,l_recvr_legal_entity_id);
   fetch c_prvdr_organz_rule
   into x_tp_schedule_line_id,x_sort_order,x_tp_rule_id,x_percentage_applied  --Added for bug 5753774
			      ,x_start_date_active,x_end_date_active;

   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG','Testing Rule 3');
   	END IF;
   IF c_prvdr_organz_rule%FOUND THEN
      IF (x_tp_rule_id IS NOT NULL) THEN
         close c_prvdr_organz_rule;
         pa_debug.Reset_err_stack;
         pa_debug.G_Err_Stage := 'Schedule Line found using Rule3';
   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	END IF;
         Return;
      END IF;
   END IF;

   close c_prvdr_organz_rule;

   --Get receiver's business group id
      get_business_group(p_recvr_org_id, l_recvr_business_group_id);

--Devdrop2 Changes Changed c_rule cursor to c_prvdr_organz_rule
   --Use Rule4
   if G_global_access = 'Y' then
     open c_prvdr_organz_rule(p_prvdr_organization_id,l_recvr_business_group_id);
     fetch c_prvdr_organz_rule
     into  x_tp_schedule_line_id,x_sort_order,x_tp_rule_id,x_percentage_applied --Added for bug 5753774
                              ,x_start_date_active,x_end_date_active;
   IF g1_debug_mode  = 'Y' THEN
     pa_debug.write_file('LOG','Testing Rule 4');
   END IF;
     IF c_prvdr_organz_rule%FOUND THEN
        IF (x_tp_rule_id IS NOT NULL) THEN
           close c_prvdr_organz_rule;
           pa_debug.Reset_err_stack;
           pa_debug.G_Err_Stage := 'Schedule Line found using Rule4';
   	   IF g1_debug_mode  = 'Y' THEN
           pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	   END IF;
           Return;
        END IF;
     END IF;

     close c_prvdr_organz_rule;
   end if;  ****************************************************************
   ***************************************************End for comment for Legal Entity*/


   -- Use Rule2
   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG','Testing Rule 2');
   	END IF;
   open c_other_rule (p_prvdr_organization_id);
   fetch c_other_rule
   into x_tp_schedule_line_id,x_sort_order,x_tp_rule_id,x_percentage_applied  -- Added for bug 5753774
			      ,x_start_date_active,x_end_date_active;

   IF c_other_rule%FOUND THEN
      IF (x_tp_rule_id IS NOT NULL) THEN
         close c_other_rule;
         pa_debug.Reset_err_stack;
         pa_debug.G_Err_Stage := 'Schedule Line found using Rule5';
   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	END IF;
         Return;
      END IF;
   END IF;

   close c_other_rule;

/* ***************************************************************
COMMENTED FOR LEGAL ENTITY TRANSFER PRICE SCHEDULE. aFTER 12.0 THERE
IS NO CONCEPT OF OU,LE AND BG check every thing  should be maintained
   in org hierarchy
   -- Use Rule6
   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG','Testing Rule 6');
   	END IF;
   open c_rule (G_Prvdr_Org_id,p_recvr_org_id);
   fetch c_rule
   into x_tp_schedule_line_id,x_sort_order,x_tp_rule_id,x_percentage_applied  -- Added for bug 5753774
			      ,x_start_date_active,x_end_date_active;

   IF c_rule%FOUND THEN
      IF (x_tp_rule_id IS NOT NULL) THEN
         close c_rule;
         pa_debug.Reset_err_stack;
         pa_debug.G_Err_Stage := 'Schedule Line found using Rule6';
   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	END IF;
         Return;
      END IF;
   END IF;

   close c_rule;

   -- Use Rule7
   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG','Testing Rule 7');
   	END IF;
   open c_rule (G_prvdr_org_id,l_recvr_legal_entity_id);
   fetch c_rule
   into x_tp_schedule_line_id,x_sort_order,x_tp_rule_id,x_percentage_applied  -- Added for bug 5753774
			     , x_start_date_active,x_end_date_active;

   IF c_rule%FOUND THEN
      IF (x_tp_rule_id IS NOT NULL) THEN
         close c_rule;
         pa_debug.Reset_err_stack;
         pa_debug.G_Err_Stage := 'Schedule Line found using Rule7';
   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	END IF;
         Return;
      END IF;
   END IF;

   close c_rule;

   --Use Rule 8
  if G_global_access='Y' then
   IF g1_debug_mode  = 'Y' THEN
     pa_debug.write_file('LOG','Testing Rule 8');
   END IF;
     open c_rule(G_prvdr_org_id,l_recvr_business_group_id);
     fetch c_rule
     into x_tp_schedule_line_id,x_sort_order,x_tp_rule_id,x_percentage_applied -- Added for bug 5753774
                             , x_start_date_active,x_end_date_active;
     IF c_rule%FOUND THEN
        IF (x_tp_rule_id IS NOT NULL) THEN
           close c_rule;
           pa_debug.Reset_err_stack;
           pa_debug.G_Err_Stage := 'Schedule Line found using Rule8';
   	IF g1_debug_mode  = 'Y' THEN
           pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	END IF;
           Return;
        END IF;
     END IF;

   close c_rule;
 end if;

   -- Use Rule9
   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG','Testing Rule 9 '|| to_char(G_prvdr_org_id));
   	END IF;
   open c_other_rule (G_prvdr_org_id);
   fetch c_other_rule
   into x_tp_schedule_line_id,x_sort_order,x_tp_rule_id,x_percentage_applied  -- Added for bug 5753774
			      ,x_start_date_active,x_end_date_active;

   IF c_other_rule%FOUND THEN
         pa_debug.G_Err_Stage := 'Cursor matched Rule9';
   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	END IF;

      IF (x_tp_rule_id IS NOT NULL) THEN
         close c_other_rule;
         pa_debug.Reset_err_stack;
         pa_debug.G_Err_Stage := 'Schedule Line found using Rule9';
   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	END IF;
         Return;
      END IF;
   END IF;

   close c_other_rule;


   -- Use Rule10
   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG','Testing Rule 10');
   	END IF;
   open c_rule (G_prvdr_legal_entity_id,l_recvr_legal_entity_id);
   fetch c_rule
   into x_tp_schedule_line_id,x_sort_order,x_tp_rule_id,x_percentage_applied  -- Added for bug 5753774
			      ,x_start_date_active,x_end_date_active;

   IF c_rule%FOUND THEN
      IF (x_tp_rule_id IS NOT NULL) THEN
         close c_rule;
         pa_debug.Reset_err_stack;
         pa_debug.G_Err_Stage := 'Schedule Line found using Rule10';
   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	END IF;
         Return;
      END IF;
   END IF;

   close c_rule;

  --Use Rule 11
   if G_global_access ='Y' then
   IF g1_debug_mode  = 'Y' THEN
     pa_debug.write_file('LOG','Testing Rule 11');
   END IF;
     open c_rule (G_prvdr_legal_entity_id,l_recvr_business_group_id);
     fetch c_rule
     into x_tp_schedule_line_id,x_sort_order,x_tp_rule_id,x_percentage_applied -- Added for 5753774
                              ,x_start_date_active,x_end_date_active;
     IF c_rule%FOUND THEN
       IF (x_tp_rule_id IS NOT NULL) THEN
         close c_rule;
         pa_debug.Reset_err_stack;
         pa_debug.G_Err_Stage := 'Schedule Line found using Rule11';
   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	END IF;
         Return;
      END IF;
     END IF;

   close c_rule;
  end if;

   -- Use Rule12
   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG','Testing Rule 12');
   	END IF;
   open c_other_rule (G_prvdr_legal_entity_id);
   fetch c_other_rule
   into x_tp_schedule_line_id,x_sort_order,x_tp_rule_id,x_percentage_applied  -- added for bug 5753774
			      ,x_start_date_active,x_end_date_active;

   IF c_other_rule%FOUND THEN
      IF (x_tp_rule_id IS NOT NULL) THEN
         close c_other_rule;
         pa_debug.Reset_err_stack;
         pa_debug.G_Err_Stage := 'Schedule Line found using Rule12';
   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	END IF;
         Return;
      END IF;
   END IF;
   close c_other_rule;

   --Use Rule 13
 if G_global_access='Y' then
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG','Testing Rule 13');
   END IF;
   open c_rule(G_bg_id,l_recvr_business_group_id);
   fetch c_rule
   into x_tp_schedule_line_id,x_sort_order,x_tp_rule_id,x_percentage_applied  -- Added for bug 5753774
                              ,x_start_date_active,x_end_date_active;
    IF c_rule%FOUND THEN
      IF (x_tp_rule_id IS NOT NULL) THEN
         close c_rule;
         pa_debug.Reset_err_stack;
         pa_debug.G_Err_Stage := 'Schedule Line found using Rule13';
   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	END IF;
         Return;
      END IF;
   END IF;
   close c_rule;
 end if;

   -- Use Rule14
   open c_other_rule (G_bg_id);
   fetch c_other_rule
   into x_tp_schedule_line_id,x_sort_order,x_tp_rule_id,x_percentage_applied  -- added for bug 5753774
			      ,x_start_date_active,x_end_date_active;

   IF c_other_rule%FOUND THEN
      IF (x_tp_rule_id IS NOT NULL) THEN
         close c_other_rule;
         pa_debug.Reset_err_stack;
         pa_debug.G_Err_Stage := 'Schedule Line found using Rule14';
   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	END IF;
         Return;
      END IF;
   END IF;

   close c_other_rule; *********************************************
   *********************************************************End for Legal Entity */

  ---Use default rule
   open c_default_rule;
   fetch c_default_rule
   into  x_tp_schedule_line_id,x_sort_order,x_tp_rule_id,x_percentage_applied -- added for bug 5753774
                              ,x_start_date_active,x_end_date_active;
   if c_default_rule%found then
      IF (x_tp_rule_id IS NOT NULL) THEN
         close c_default_rule;
         pa_debug.Reset_err_stack;
         pa_debug.G_Err_Stage := 'Schedule Line found using default rule';
   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	END IF;
         Return;
      END IF;
   END IF;

   x_error_code := 'PA_CC_TP_NO_SCHEDULE_LINE';
   pa_debug.Reset_err_stack;
   pa_debug.G_Err_Stage := 'Exitting Determine_Schedule_Line';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      raise;
END Determine_Schedule_Line;

-------------------------------------------------------------------------------
PROCEDURE Insert_Schedule_Line_Into_Lkp(
 	p_prvdr_organization_id		IN 	Number,
        p_recvr_org_id			IN 	Number,
        p_recvr_organization_id		IN 	Number,
	p_tp_schedule_id		IN	Number,
	p_tp_schedule_line_id		IN	Number,
	p_labor_flag			IN	Varchar2,
--Start Added for devdrop2
	p_tp_amt_type_code              IN      Varchar2,
--End   Added for devdrop2
	p_start_date_active		IN	Date,
	p_end_date_active		IN	Date,
        p_sort_order                    IN   Number,   -- Added for bug 5753774
	x_error_code			IN OUT 	NOCOPY Varchar2 /*File.sql.39*/
					)
IS

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
   pa_debug.Set_err_stack ('Insert_Schedule_Line_Into_Lkp');
   pa_debug.G_Err_Stage := 'Starting Insert_Schedule_Line_Into_Lkp';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

   INSERT INTO
   PA_CC_TP_SCHEDULE_LINE_LKP
   (tp_schedule_id,
    tp_schedule_line_id,
    prvdr_org_id,
    prvdr_organization_id,
    recvr_org_id,
    recvr_organization_id,
    labor_flag,
    tp_amt_type_code,
    start_date_active,
    sort_order, -- Added for bug 5753774
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    end_date_active,
    last_update_login)
    VALUES
   (p_tp_schedule_id,
    p_tp_schedule_line_id,
    G_prvdr_org_id,
    p_prvdr_organization_id,
    p_recvr_org_id,
    p_recvr_organization_id,
    p_labor_flag,
    p_tp_amt_type_code,
    p_start_date_active,
    p_sort_order,     -- Added for bug 5753774
    G_creation_date,
    G_created_by,
    G_last_update_date,
    G_last_updated_by,
    p_end_date_active,
    G_last_update_login);

    -- commit the autonomous transaction
    commit;

   pa_debug.Reset_err_stack;
   pa_debug.G_Err_Stage := 'Exitting Insert_Schedule_Line_Into_Lkp';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

EXCEPTION
   WHEN Dup_val_on_index THEN
      pa_debug.Reset_err_stack;
      null;
   WHEN OTHERS THEN
      raise;

END Insert_Schedule_Line_Into_Lkp;
--------------------------------------------------------------------------------
PROCEDURE Get_Schedule_Line_Attributes(
	p_tp_schedule_line_id		IN	Number,
	p_labor_flag		        IN	Varchar2,
	x_tp_rule_id		        OUT	NOCOPY Number, /*File.sql.39*/
	x_percentage_applied	        OUT	NOCOPY Number, /*File.sql.39*/
	x_error_code			IN OUT	NOCOPY VARCHAR2 /*File.sql.39*/
					)
IS

cursor c_schedule_line_attr
is
select
Decode (p_labor_flag ,'Y', labor_tp_rule_id,nl_tp_rule_id ),
Decode (p_labor_flag,'Y',labor_percentage_applied,nl_percentage_applied)
from pa_cc_tp_schedule_lines
where tp_schedule_line_id = p_tp_schedule_line_id;

BEGIN
   pa_debug.Set_err_stack ('Get_Schedule_Line_Attributes');
   pa_debug.G_Err_Stage := 'Starting Get_Schedule_Line_Attributes';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

   open c_schedule_line_attr;
   fetch c_schedule_line_attr
   into  x_tp_rule_id,x_percentage_applied ;

   IF c_schedule_line_attr%NOTFOUND THEN
      x_error_code := 'PA_CC_TP_NO_SCHEDULE_LINE_FOR_ID';
   END IF;

   close c_schedule_line_attr;

   pa_debug.Reset_err_stack;
   pa_debug.G_Err_Stage := 'Exitting Get_Schedule_Line_Attributes';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      raise;

END Get_Schedule_Line_Attributes;
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
	x_tp_bill_rate	         IN OUT	NOCOPY  PA_PLSQL_DATATYPES.NumTabTyp,
	x_tp_base_curr_code	OUT	NOCOPY  PA_PLSQL_DATATYPES.Char15TabTyp,
	x_tp_base_amount        IN OUT	NOCOPY  PA_PLSQL_DATATYPES.NumTabTyp,
      x_tp_bill_markup_percentage IN OUT NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,
	x_tp_rule_percentage	IN OUT	NOCOPY  PA_PLSQL_DATATYPES.NumTabTyp,
        x_tp_job_id              IN OUT NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp,
	x_error_code		IN OUT	NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
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
        p_task_nl_std_bill_rate_sch_id  IN       PA_PLSQL_DATATYPES.NumTabTyp
                                                  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_proj_nl_std_bill_rate_sch_id  IN       PA_PLSQL_DATATYPES.NumTabTyp
                                                  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_uom_flag                      IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab

			)
IS

l_rate_schedule_id PA_PLSQL_DATATYPES.IdTabTyp;
l_calc_method_code PA_PLSQL_DATATYPES.Char1TabTyp;
l_empty_calc_method_code PA_PLSQL_DATATYPES.Char1TabTyp;
l_basis_compute_flag PA_PLSQL_DATATYPES.Char1TabTyp;
l_bill_rate_compute_flag PA_PLSQL_DATATYPES.Char1TabTyp;
l_burden_rate_compute_flag PA_PLSQL_DATATYPES.Char1TabTyp;

BEGIN
   pa_debug.Set_err_stack ('Get_Transfer_Price_Amount');
   pa_debug.G_Err_Stage := 'Starting Get_Transfer_Price_Amount';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;


	l_calc_method_code := l_empty_calc_method_code;

   -- Get Rule attributes
   Get_Rule_Attributes(
	p_tp_rule_id,
	p_compute_flag,
	l_calc_method_code,
	x_cc_markup_base_code,
	x_tp_rule_percentage,
	l_rate_schedule_id,
	x_error_code
	);

   -- Set base_curr_code and base_amt based on cc_markup_base_code
   -- if base_code is 'burden' then recalculate burden amount if needed.
   -- Also set the flags basis_compute_flag, bill_rate_compute_flag dependending
   -- on calc_method_code.

   Set_Base_Amount_And_Flag(
        p_expenditure_item_id,
        p_expenditure_type,
	p_expenditure_item_date,
        p_expnd_organization_id,
	p_project_id,
        p_task_id,
	p_tp_fixed_date,
	l_calc_method_code,
	x_cc_markup_base_code,
	p_denom_currency_code,
	p_projfunc_currency_code,
	p_denom_raw_cost_amount,
	p_denom_burdened_cost_amount,
	p_raw_revenue_amount,
	p_revenue_distributed_flag,
	p_compute_flag,
	x_tp_ind_compiled_set_id,
	x_error_code,
	l_basis_compute_flag,
	l_bill_rate_compute_flag,
	l_burden_rate_compute_flag,
	x_tp_base_curr_code,
	x_tp_base_amount,
/*Bill rate Discount*/
        p_dist_rule,
        p_mcb_flag,
        p_bill_rate_multiplier,
        p_quantity,
        p_incurred_by_person_id,
        p_raw_cost,
        p_labor_schdl_discnt,
        p_labor_schdl_fixed_date,
        p_bill_job_grp_id,
        p_labor_sch_type,
        p_project_org_id,
        p_project_type,
        p_exp_func_curr_code,
        p_incurred_by_organz_id,
        p_raw_cost_rate,
        p_override_to_organz_id,
        p_emp_bill_rate_schedule_id,
        p_job_bill_rate_schedule_id,
        p_exp_raw_cost,
        p_assignment_precedes_task,
        p_system_linkage_function,
        p_assignment_id ,

        p_burden_cost                   ,
        p_task_nl_bill_rate_org_id         ,
        p_proj_nl_bill_rate_org_id      ,
        p_task_nl_std_bill_rate_sch        ,
        p_proj_nl_std_bill_rate_sch     ,
        p_non_labor_resource            ,
        p_nl_task_sch_date               ,
        p_nl_proj_sch_date               ,
        p_nl_task_sch_discount          ,
        p_nl_proj_sch_discount          ,
        p_nl_sch_type,
  /*Added for Doosan rate api enhancement */
        p_task_nl_std_bill_rate_sch_id,
        p_proj_nl_std_bill_rate_sch_id,
        p_uom_flag);


   Determine_Transfer_Price
	(
        p_expenditure_item_id,
        p_expnd_organization_id,
        p_expenditure_type,
	p_expenditure_item_date,
	p_tp_fixed_date,
	p_system_linkage_function,
	p_task_id,
	x_tp_base_curr_code,
	x_tp_base_amount,
	p_tp_schedule_line_percentage,
        x_tp_rule_percentage,
	p_compute_flag,
	p_quantity,
	p_incurred_by_person_id,
	p_job_id,
	l_rate_schedule_id,
	p_non_labor_resource,
	l_basis_compute_flag,
	l_bill_rate_compute_flag,
	l_burden_rate_compute_flag,
	x_denom_tp_currency_code,
	x_denom_transfer_price,
	x_tp_ind_compiled_set_id,
	x_tp_bill_rate,
	x_tp_bill_markup_percentage,
        x_tp_job_id,
	x_error_code
        );


   pa_debug.Reset_err_stack;
   pa_debug.G_Err_Stage := 'Exitting Get_Transfer_Price_Amount';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      raise;

END Get_Transfer_Price_Amount;
-------------------------------------------------------------------------------
-- Get rule attributes from pa_cc_tp_rules table

PROCEDURE Get_Rule_Attributes(
	p_tp_rule_id			IN	PA_PLSQL_DATATYPES.IdTabTyp,
	p_compute_flag			IN	PA_PLSQL_DATATYPES.Char1TabTyp,
	x_calc_method_code	OUT	NOCOPY  PA_PLSQL_DATATYPES.Char1TabTyp,
	x_cc_markup_base_code	IN OUT	NOCOPY  PA_PLSQL_DATATYPES.Char1TabTyp,
	x_rule_percentage	IN OUT	NOCOPY  PA_PLSQL_DATATYPES.NumTabTyp,
	x_schedule_id		OUT	NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp,
	x_error_code		IN OUT	NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp
					)
IS

Cursor c_rule_attributes(l_tp_rule_id Number)
IS
select calc_method_code,markup_calc_base_code,percentage_applied,schedule_id
from pa_cc_tp_rules
where tp_rule_id = l_tp_rule_id;

	l_schedule_id		PA_PLSQL_DATATYPES.IdTabTyp;

BEGIN
   x_schedule_id := l_schedule_id;
   pa_debug.Set_err_stack ('Get_Rule_Attributes');
   pa_debug.G_Err_Stage := 'Starting Get_Rule_Attributes';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

   For i in 1 .. G_Array_Size
   Loop
      IF (p_compute_flag(i) = 'Y' and x_error_code(i) is null) THEN
          pa_debug.G_Err_Stage := 'Fetching Get_Rule_Attributes';
          pa_debug.G_Err_Stage := 'Rule ID is '|| to_char(p_tp_rule_id(i));

      open c_rule_attributes (p_tp_rule_id(i));
      --open c_rule_attributes (3342);
      fetch c_rule_attributes
      into  x_calc_method_code(i),x_cc_markup_base_code(i),x_rule_percentage(i),
            x_schedule_id(i);
      close c_rule_attributes;
      END IF;

   END Loop;


   pa_debug.Reset_err_stack;
   pa_debug.G_Err_Stage := 'Exitting Get_Rule_Attributes';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      raise;
END Get_Rule_Attributes;
-------------------------------------------------------------------------------
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
	p_projfunc_currency_code	IN	PA_PLSQL_DATATYPES.Char15TabTyp,
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
	/*Bill rate Discount  */
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
        p_task_nl_std_bill_rate_sch_id  IN       PA_PLSQL_DATATYPES.NumTabTyp   DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_proj_nl_std_bill_rate_sch_id  IN       PA_PLSQL_DATATYPES.NumTabTyp   DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
      p_uom_flag                      IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab
      )

IS
l_base_amount	NUMBER;
l_burden_cost   Number;
l_denom_burdened_cost_amount Number;
l_burdening_allowed VARCHAR2(1);
l_burden_amt_display_method VARCHAR2(1);
l_error_code	VARCHAR2(30);
l_status_code Number;
l_stage Number;
l_fixed_date Date;
l_compiled_multiplier Number;
l_compiled_set_id NUMBER;
l_check_line NUMBER; /* 2469987 */

l_burden_calc_curr_code PA_PLSQL_DATATYPES.Char15TabTyp;  /* 2215942 */
l_burden_calc_amount    PA_PLSQL_DATATYPES.NumTabTyp;     /* 2215942 */
l_burden_error_code     PA_PLSQL_DATATYPES.Char30TabTyp;  /* 2215942 */
l_rate_schedule_id      PA_PLSQL_DATATYPES.IdTabTyp;      /* 2215942 */
l_tp_ind_compiled_set_id  PA_PLSQL_DATATYPES.IdTabTyp;    /* 2215942 */

l_exp_func_curr_code      VARCHAR2(30);
l_sl_function             NUMBER;

l_bill_rate              NUMBER;
l_adjusted_bill_rate              NUMBER; --4038485
l_markup_percentage      NUMBER;
l_rev_currency_code      VARCHAR2(30);
l_return_status          varchar2(240);
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(240);
l_raw_cost_rate          NUMBER;

/* Added for bug 2668753 */
   l_project_currency_code  varchar2(50) := null;
   l_project_raw_cost           number := null;
   l_project_burdened_cost  number := null;
   l_proj_func_burdened_cost number := null;
   l_exp_func_burdened_cost  number := null;

/* Added for bug 2697945 */
   l_bill_trans_raw_revenue number := null;
   l_bill_trans_currency_code varchar2(50) := null;
/* Added for bug 2820252 */
   l_bill_trans_adjusted_revenue number := null;
   exp_not_found   exception;

   l_dist_rule BOOLEAN :=TRUE;/*Added for bug 2863350*/

cursor PROJ_VALUES (p_expenditure_item_id IN NUMBER) IS
  select project_raw_cost,
       project_currency_code,
       project_burdened_cost,
       burden_cost,
       acct_burdened_cost,
/* Added for bug 2697945 */
       bill_trans_raw_revenue,
       bill_trans_currency_code,
/* Added for bug 2820252 */
       bill_trans_adjusted_revenue
      from pa_expenditure_items_all where expenditure_item_id=p_expenditure_item_id;
/* End of Changes for bug 2668753 */
 l_nl_bill_rate NUMBER;
 l_nl_adjusted_bill_rate  NUMBER;--4038485
 l_nl_markup_percentage NUMBER;
BEGIN
   pa_debug.Set_err_stack ('Set_Base_Amount_And_Flag');
   pa_debug.G_Err_Stage := 'Starting Set_Base_Amount_And_Flag';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

   For i in 1 .. G_Array_Size
   Loop
      -- Initialize the flags

      x_basis_compute_flag(i) := 'N';
      x_bill_rate_compute_flag(i) := 'N';
      x_burden_rate_compute_flag(i) := 'N';

   /* Added for bug 2668753 */
/* For Information-- This piece of code added for bug 2668753 might result in performance issues */

   l_project_currency_code  := null;
   l_project_raw_cost         := null;
   l_project_burdened_cost  := null;
   l_proj_func_burdened_cost := null;
   l_exp_func_burdened_cost   := null;
/* Added for bug 2697945 */

   l_bill_trans_raw_revenue  := null;
   l_bill_trans_currency_code  := null;

/* Added for bug 2820252 */
   l_bill_trans_adjusted_revenue := null;

 /*  IF condition added for Bug 2780325 */

IF (p_mcb_flag.exists(i))THEN

IF ( nvl(p_mcb_flag(i),'N') = 'Y' ) THEN
BEGIN
   OPEN PROJ_VALUES(p_expenditure_item_id(i));
-- IF(PROJ_VALUES%FOUND) THEN    /* Commented for bug 2697945 */

   FETCH proj_values into
    l_project_raw_cost,
    l_project_currency_code,
    l_project_burdened_cost,
    l_proj_func_burdened_cost,
    l_exp_func_burdened_cost,
    l_bill_trans_raw_revenue,    --Added for bug 2697945
    l_bill_trans_currency_code,
    l_bill_trans_adjusted_revenue;   --Added for bug 2820252

--END IF;
/* Added for bug 2697945 */

IF(PROJ_VALUES%NOTFOUND) THEN
       IF g1_debug_mode  = 'Y' THEN
       pa_debug.write_file('LOG','No Data Found for the Expenditure Item Id :'||p_expenditure_item_id(i));
       END IF;

if PROJ_VALUES%ISOPEN THEN
CLOSE PROJ_VALUES;
end if;

-- EXIT;   /* Commented this line and added the following line for bug 2697945 */
RAISE exp_not_found;
END IF;
/* End of Changes done for bug 2697945 */

CLOSE PROJ_VALUES;

EXCEPTION
/* Added EXP_NOT_FOUND for bug 2697945 */

WHEN EXP_NOT_FOUND THEN
 if PROJ_VALUES%ISOPEN THEN
     CLOSE PROJ_VALUES;
 end if;
RAISE;
WHEN OTHERS THEN
 if PROJ_VALUES%ISOPEN THEN
     CLOSE PROJ_VALUES;
 end if;
RAISE;
END;

END IF;

/* End of Changes for bug 2668753 */

END IF; /* 2780325 */
   IF (p_compute_flag(i) = 'Y' and x_error_code(i) IS NULL) THEN
       l_error_code := null; /** Fixed Bug: 1063455 **/
       l_burden_error_code := x_error_code;  /* 2215942  */

       pa_debug.G_Err_Stage :=
		     'Processing EI: '||to_char(p_expenditure_item_id(i));
       IF g1_debug_mode  = 'Y' THEN
       pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
       END IF;
      IF p_cc_markup_base_code(i) = 'C' THEN
				       -- Raw Cost

	 -- Check If Raw Cost amount is Null
	 IF p_denom_raw_cost_amount(i) is not null THEN
	    x_tp_base_amount(i) := p_denom_raw_cost_amount(i);
	    x_tp_base_curr_code(i) := p_denom_currency_code(i);
   	    IF g1_debug_mode  = 'Y' THEN
            pa_debug.write_file('LOG','Base is raw cost');
            END IF;
         ELSE
	    l_error_code := 'PA_CC_TP_RAW_COST_NULL';
	 END IF;

      ELSIF p_cc_markup_base_code(i) = 'R' THEN
				      -- Raw Revenue
   	    IF g1_debug_mode  = 'Y' THEN
            pa_debug.write_file('LOG','Base is raw rev');
            END IF;
      /*The below block is added for bug 2863550 */
            IF(p_dist_rule.exists(i)) THEN
                    IF (substr(p_dist_rule(i),1,4) = 'WORK') THEN
                         l_dist_rule:=TRUE;
                    ELSE
                         l_dist_rule :=FALSE;
                    END IF;
            ELSE
                 l_dist_rule :=TRUE;
            END IF;
	 -- Check If revenue amount is distributed
	    IF p_revenue_distributed_flag(i) IN ('Y','P') AND l_dist_rule THEN  /*l_dist_rule added for 2863550*/
           /*substr(p_dist_rule(i),1,4) = 'WORK' THEN*//*Added P for bug 2636678 and added p_dist_rule for bug 2663736*/
	    -- Check If Revenue amount is Null
	       IF p_raw_revenue_amount(i) IS NOT NULL THEN
/* Commented the following two lines for bug 2697945 and added the next two lines as part of fix */

	  /*        x_tp_base_amount(i) := p_raw_revenue_amount(i);
	          x_tp_base_curr_code(i) := p_projfunc_currency_code(i);  */

  /* Changed the following two lines for bug 2696945 */

                    x_tp_base_amount(i)    :=  nvl(l_bill_trans_adjusted_revenue,nvl(l_bill_trans_raw_revenue,p_raw_revenue_amount(i)));
                                                    /* Changed the above line for bug 2820252 */
                    x_tp_base_curr_code(i) :=  nvl(l_bill_trans_currency_code,p_projfunc_currency_code(i));

               ELSE
                  /* Code Added for Bug#2469987 -- Start */
                  BEGIN
                    SELECT 1 INTO l_check_line
                      FROM DUAL
                     WHERE EXISTS (
                           SELECT  1
                             FROM  pa_cust_rev_dist_lines_all
                            WHERE  expenditure_item_id = p_expenditure_item_id(i)
                           UNION ALL
                           SELECT  1
                             FROM  pa_cc_dist_lines_all
                            WHERE  expenditure_item_id = p_expenditure_item_id(i));

                     x_tp_base_amount(i) := 0;
                     x_tp_base_curr_code(i) := p_projfunc_currency_code(i);

                  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     x_tp_base_amount(i) := 0;
                     x_tp_base_curr_code(i) := p_projfunc_currency_code(i);
                  WHEN OTHERS THEN
	             l_error_code := 'PA_CC_TP_REV_AMT_NULL';
                  END;
               END IF; /* Revenue amount is not null */
                  /* Code Added for Bug#2469987 -- End */
            ELSE
   	       IF g1_debug_mode  = 'Y' THEN
               pa_debug.write_file('LOG',
		      'Rev flag is '||p_revenue_distributed_flag(i));
   	       END IF;
                   /* Added for bill rate disount and transfer price revenue*/
                  IF (p_sys_linkage_function(i) in ('ST','OT'))  then
   		   IF g1_debug_mode  = 'Y' THEN
                   pa_debug.write_file('LOG','within Assignment_Rev_Amt');
   		   END IF;
                    pa_revenue.Assignment_Rev_Amt(
                                 p_project_id                 => P_project_id(i)
                                 ,p_task_id                   => P_task_id(i)
                                 ,p_item_date                 => P_expenditure_item_date(i)
                                 ,p_item_id                   => p_assignment_id(i)
                                 ,p_bill_rate_multiplier      => p_bill_rate_multiplier(i)
                                 ,p_quantity                  => p_quantity(i)
                                 ,p_person_id                 => p_person_id(i)
                                 ,p_raw_cost                  => p_raw_cost(i)
                                   /* bug#3221791 added to_number */
                                 ,p_labor_schdl_discnt        => to_number(p_labor_schdl_discnt(i))
                                 ,p_labor_bill_rate_org_id    => NULL
                                 ,p_labor_std_bill_rate_schdl => NULL
                                 ,p_labor_schdl_fixed_date    => p_labor_schdl_fixed_date(i)
                                 ,p_bill_job_grp_id           => p_bill_job_grp_id(i)
                                 ,p_labor_sch_type            => p_labor_sch_type(i)
                                 ,p_project_org_id            => p_project_org_id(i)
                                 ,p_project_type              => p_project_type(i)
                                 ,p_expenditure_type          => p_expenditure_type(i)
                                 ,p_exp_func_curr_code        => p_exp_func_curr_code(i)
                                 ,p_incurred_by_organz_id     => p_incurred_by_organz_id(i)
                                 ,p_raw_cost_rate             => p_raw_cost_rate(i)
                                 ,p_override_to_organz_id     => p_override_to_organz_id(i)
                                 ,p_emp_bill_rate_schedule_id => p_emp_bill_rate_schedule_id(i)
                                 ,p_job_bill_rate_schedule_id => p_job_bill_rate_schedule_id(i)
                                 ,p_resource_job_id           => NULL
                                 ,p_exp_raw_cost              => p_exp_raw_cost(i)
                                 ,p_expenditure_org_id        => p_expnd_organization_id(i)
                                 ,p_projfunc_currency_code    => p_projfunc_currency_code(i)
                                 ,p_assignment_precedes_task  => p_assignment_precedes_task(i)
                                 ,p_sys_linkage_function      => p_sys_linkage_function(i)
                                 ,x_bill_rate                 => l_bill_rate
                                 ,x_raw_revenue               => x_tp_base_amount(i)
                                 ,x_txn_currency_code         => x_tp_base_Curr_code(i)
                                 ,x_rev_currency_code         => l_rev_currency_code
                                 ,x_markup_percentage         => l_markup_percentage
                                 ,x_return_status             => l_return_status
                                 ,x_msg_count                 => l_msg_count
                                 ,x_msg_data                  => l_msg_data
                                 ,p_mcb_flag                  => p_mcb_flag(i)
                                 ,p_denom_raw_cost            => p_denom_raw_cost_amount(i)
                                 ,p_denom_curr_code           => p_denom_currency_code(i)
                                 ,p_called_process            => 'PA'
                               /* Added for bug 2668753 */
                                 ,p_project_raw_cost         => l_project_raw_cost
                                 ,p_project_currency_code     => l_project_currency_code
				 ,x_adjusted_bill_rate         => l_adjusted_bill_rate);--4038485
   		   IF g1_debug_mode  = 'Y' THEN
                   pa_debug.write_file('LOG','completed Assignment_Rev_Amt');
   	           END IF;

                         ELSE
   		   IF g1_debug_mode  = 'Y' THEN
                   pa_debug.write_file('LOG','Non Labor Revenue Amount');
   		   END IF;
			    l_exp_func_curr_code := p_exp_func_curr_code(i);
			    select decode(p_sys_linkage_function(i),'BTC',6,2)
			      into l_sl_function
			     from  dual;

			     IF p_raw_cost_rate(i) IS NULL THEN
			      SELECT DECODE(nvl(COST_RATE_FLAG,'N'),'N',1,NULL)
				INTO l_raw_cost_rate
				FROM PA_EXPENDITURE_TYPES
			      where EXPENDITURE_TYPE = p_expenditure_type(i);
			     ELSE
			      l_raw_cost_rate := p_raw_cost_rate(i);
			     END IF;
                            pa_revenue.Non_Labor_Rev_amount(
                                 p_project_id                   => p_project_id(i),
                                 p_task_id                      => p_task_id(i),
                                 p_bill_rate_multiplier         => p_bill_rate_multiplier(i),
                                 p_quantity                     => p_quantity(i),
                                 p_raw_cost                     => p_raw_cost(i),
                                 p_burden_cost                  => p_burden_cost(i),
                                 p_denom_raw_cost               => p_denom_raw_cost_amount(i),
                                 p_denom_burdened_cost          => p_denom_burdened_cost_amount(i),
                                 p_expenditure_item_date        => p_expenditure_item_date(i),
                                 p_task_bill_rate_org_id        => p_task_nl_bill_rate_org_id(i),
                                 p_project_bill_rate_org_id     => p_proj_nl_bill_rate_org_id(i),
                                 p_task_std_bill_rate_sch       => p_task_nl_std_bill_rate_sch(i),
                                 p_project_std_bill_rate_sch    => p_proj_nl_std_bill_rate_sch(i),
                                 p_project_org_id               => p_project_org_id(i),
                                 p_sl_function                  => l_sl_function,
                                 p_denom_currency_code          => p_denom_currency_code(i),
                                 p_proj_func_currency           => p_projfunc_currency_code(i),
                                 p_expenditure_type             => p_expenditure_type(i),
                                 p_non_labor_resource           => p_non_labor_resource(i),
                                 p_task_sch_date                => p_nl_task_sch_date(i),
                                 p_project_sch_date             => p_nl_proj_sch_date(i),
                                 p_project_sch_discount         => p_nl_proj_sch_discount(i),
                                 p_task_sch_discount            => p_nl_task_sch_discount(i),
                                 p_mcb_flag                     => p_mcb_flag(i),
                                 p_non_labor_sch_type           => p_nl_sch_type(i),
                                 p_project_type                 => p_project_type(i),
                                 p_exp_raw_cost                 => p_exp_raw_cost(i),
                                 p_raw_cost_rate                => l_raw_cost_rate,
                                 p_incurred_by_organz_id        => p_incurred_by_organz_id(i),
                                 p_override_to_organz_id        => p_override_to_organz_id(i),
                                 px_exp_func_curr_code          => l_exp_func_curr_code,
                                 x_raw_revenue                  => x_tp_base_amount(i),
				 x_rev_curr_code                => x_tp_base_Curr_code(i),
                                 x_return_status                => l_return_status,
                                 x_msg_count                    => l_msg_count,
                                 x_msg_data                     => l_msg_data,
                                 /* Added for bug 2668753 */
                                 p_project_raw_cost             => l_project_raw_cost,
                                 p_project_currency_code        => l_project_currency_code,
                                 p_project_burdened_cost        => l_project_burdened_cost,
                                 p_proj_func_burdened_cost      => l_proj_func_burdened_cost,
                                 p_exp_func_burdened_cost       => l_exp_func_burdened_cost,
                                 p_task_nl_std_bill_rate_sch_id => p_task_nl_std_bill_rate_sch_id(i),
                                 p_proj_nl_std_bill_rate_sch_id => p_proj_nl_std_bill_rate_sch_id(i),
                                 x_bill_rate                    => l_nl_bill_rate,
                                 x_markup_percentage            => l_nl_markup_percentage,
                                 x_adjusted_bill_rate           => l_nl_adjusted_bill_rate,--4038485
                                 p_uom_flag                     => p_uom_flag(i));

   			  IF g1_debug_mode  = 'Y' THEN
                          pa_debug.write_file('LOG','Completed Non Labor Revenue Amount');
   		          END IF;
                          END IF;
   		   IF g1_debug_mode  = 'Y' THEN
                   pa_debug.write_file('LOG','x_base revenue amount' || x_tp_base_amount(i) || 'code : ' ||x_tp_base_curr_code(i));
   		   END IF;
		       IF l_msg_data is NULL then
                         IF x_tp_base_amount(i) is NULL THEN
	                    l_error_code := 'PA_CC_TP_REV_AMT_NULL';
                         END IF;
                       ELSE
                         l_error_code := l_msg_data;
                       END IF;
                   /* Added for bill rate disount and transfer price revenue*/
          END IF;
      ELSIF p_cc_markup_base_code(i) = 'B' THEN
				     -- Burdened Cost
         l_denom_burdened_cost_amount := p_denom_burdened_cost_amount(i);
	 IF (l_denom_burdened_cost_amount IS  NULL) THEN
          -- Check if Burden cost is null
	    l_error_code := 'PA_CC_TP_BURDN_COST_NULL';
         ELSE
	  -- Check if burden cost needs to be recalculated
	    IF (p_denom_burdened_cost_amount(i) = p_denom_raw_cost_amount(i))
                THEN

               Get_Burdening_Details(p_project_id (i),
				     l_burdening_allowed,
				     l_burden_amt_display_method
				     );

          IF g1_debug_mode  = 'Y' THEN
	  pa_debug.write_file('LOG','Project_id is: '
                                 ||to_char(p_project_id(i)));

          pa_debug.write_file('LOG','Burdening flag is : '
                                 ||l_burdening_allowed);

          pa_debug.write_file('LOG','burden amount allowed flag is: '
                                 ||l_burden_amt_display_method);
          END IF;

          -- Check if project allows burdening
	       IF (l_burdening_allowed = 'Y' ) THEN
	       -- Check if burden amount is displayed on separate transaction

		  IF l_burden_amt_display_method = 'D' THEN
		     -- calculate the correct burden_amount

		     l_fixed_date := p_fixed_date(i);

		     IF p_fixed_date(i) is NULL THEN
			l_fixed_date := p_expenditure_item_date(i);
                     END IF;
		/**

	             PA_COST_PLUS.view_indirect_cost (
				  transaction_id => p_expenditure_item_id(i),
				  transaction_type => 'PA',
				  task_id => p_task_id(i),
				  effective_date => l_fixed_date,
				  expenditure_type => p_expenditure_type(i),
				  organization_id => p_expnd_organization_id(i),
				  schedule_type => 'C',
				  direct_cost => p_denom_raw_cost_amount(i),
				  indirect_cost => l_denom_burdened_cost_amount,
				  status => l_status_code,
				  stage => l_stage
				  );
                  **/
		     -- Get the multiplier
/* Added the declare sction for the bug#2215942  */

                     DECLARE
                        l_burden_sch_rev_id Number;
                        l_Stage Number;
                        l_Status Number;
                        l_burden_calc_amount_l number;
                        l_tp_ind_compiled_set_id_l Number;
                        t_rate_sch_rev_id number;     /* bug#3117191 */
                        t_sch_fixed_date date;        /* bug#3117191 */


		     BEGIN
/*Bug 1729820 */
/* commented for the bug#2215942, starts here  */
/*
                        SELECT cost_ind_compiled_set_id
                        INTO l_compiled_set_id
                        FROM pa_expenditure_items_all
                        WHERE expenditure_item_id =  p_expenditure_item_id(i);
*/
/* commented for the bug#2215942, ends here  */
/* Changes ends for bug 1729820 */
/* commented for the bug#2215942, starts here  */
/*

		        l_compiled_multiplier :=
			   pa_cost_plus.Get_Mltplr_For_Compiled_Set
							  (l_compiled_set_id);
                        l_denom_burdened_cost_amount :=
			  p_denom_raw_cost_amount(i)* (1+l_compiled_multiplier);
*/
/* commented for the bug#2215942, ends here  */

/* Code added for the bug 2215942, starts here  */

                        x_burden_rate_compute_flag(i) := 'Y';

    /* added for bug#3117191 */
    PA_CLIENT_EXTN_BURDEN.Override_Rate_Rev_Id(
            'ACTUAL',
            p_expenditure_item_id(i),                  -- Transaction Item Id
            'PA',                                      -- Transaction Type
            p_task_id(i),                              -- Task Id
            'C',                                       -- Schedule Type
            p_expenditure_item_date(i),                -- EI Date
            t_sch_fixed_date,                          -- Sch_fixed_date (Out)
            t_rate_sch_rev_id,                         -- Rate_sch_rev_id (Out)
            l_status);                                 -- Status   (Out)

    /* Begin bug 5169080 */
    if (nvl(l_status , 0 ) <> 0) THEN
         l_error_code := 'PA_CC_TP_ERROR_BURDEN_CALC';
    end if;
    /* End bug 5169080 */


    IF (t_rate_sch_rev_id IS NOT NULL) THEN
         l_burden_sch_rev_id := t_rate_sch_rev_id;
             PA_COST_PLUS.Get_Burden_Amount1(
                        p_expenditure_type(i),
                        p_expnd_organization_id(i),
                        p_denom_raw_cost_amount(i),
                        l_burden_calc_amount_l,
                        l_burden_sch_rev_id,
                        l_tp_ind_compiled_set_id_l,
                        l_status,
                        l_stage
                        );
   /* end for bug#3117191 */
   ELSE /* bug#3117191 */

/* get the task level burden schedule id by considering the task level overrides  */
                        select NVL(OVR_COST_IND_RATE_SCH_ID, COST_IND_RATE_SCH_ID)
                          into l_rate_schedule_id(i)
                          from pa_tasks
                         where task_id in
                             ( select task_id
                                 from pa_expenditure_items_all
                                where expenditure_item_id = p_expenditure_item_id(i)
                             );
/* Get the burden amount from the call to the procedure PA_COST_PLUS.Get_Burden_Amount,
   which gets the revision for the given burden schedule, then burden structure,
   then cost base from the burden structure corresponding to the expenditure type,
   then sum of the compiled multipliers  */

             PA_COST_PLUS.Get_Burden_Amount(
                        l_rate_schedule_id(i),
                        p_expenditure_item_date(i),
                        p_expenditure_type(i),
                        p_expnd_organization_id(i),
                        p_denom_raw_cost_amount(i),
                        l_burden_calc_amount_l,
                        l_burden_sch_rev_id,
                        l_tp_ind_compiled_set_id_l,
                        l_status,
                        l_stage
                        );
    END IF; /* bug#3117191 */

                        l_burden_calc_amount(i) := l_burden_calc_amount_l;
                        l_tp_ind_compiled_set_id(i) := l_tp_ind_compiled_set_id_l;


                        l_denom_burdened_cost_amount :=
                                p_denom_raw_cost_amount(i)+l_burden_calc_amount(i);

/* Code added for the bug 2215942, ends here  */


                     EXCEPTION
			when no_data_found then

                           l_error_code := 'PA_CC_TP_ERROR_BURDEN_CALC';
		     END;


                  END IF;/** burden_amt_display_method = 'D' **/
               END IF; /** l_burdening_allowed **/

	    END IF;/** p_denom_burdened_cost_amount=p_denom_raw_cost_amount **/
        END IF; /** Burden Cost is null **/

	    IF (l_error_code is null) THEN

	          x_tp_base_amount(i) := l_denom_burdened_cost_amount;
	          x_tp_base_curr_code(i) := p_denom_currency_code(i);

            END IF;
      ELSE
	 l_error_code := 'PA_CC_TP_INVALID_BASE_CODE';

      END IF; /** p_cc_markup_base_code **/

      IF (l_error_code IS NULL) THEN
   	 IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG','Base Amount is: '
	                         ||to_char(x_tp_base_amount(i)));
        pa_debug.write_file('LOG','Base currency is: '
	                          ||x_tp_base_curr_code(i));
   	 END IF;
	 -- No error encountered yet
	 IF p_calc_method_code(i) = 'A' THEN
	    -- Use Basis
	    G_Basis_Exists := TRUE;
	    x_basis_compute_flag(i) := 'Y';
         ELSIF p_calc_method_code(i) = 'R' THEN
	    -- Use Bill Rate Schedule
	    G_Bill_Rate_Exists := TRUE;
	    x_bill_rate_compute_flag(i) := 'Y';
         ELSIF p_calc_method_code(i) = 'B' THEN
	    -- Use Burden schedule
	    G_Burden_Rate_Exists := TRUE;
	    x_burden_rate_compute_flag(i) := 'Y';
         END IF;
      ELSE
	 x_error_code(i) := l_error_code;

      END IF;



   END IF;/**  p_compute_flag(i) = 'Y' and x_error_code(i) IS NULL **/

   END LOOP;

   pa_debug.Reset_err_stack;
   pa_debug.G_Err_Stage := 'Exitting Set_Base_Amount_And_Flag';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      raise;

END Set_Base_Amount_And_Flag;
--------------------------------------------------------------------------------
Procedure Get_Burdening_Details(p_project_id 	IN NUMBER,
				x_burdening_allowed OUT NOCOPY VARCHAR2, /*File.sql.39*/
				x_burden_amt_display_method OUT NOCOPY VARCHAR2 /*File.sql.39*/
				     )
IS
/* Bug 1729820 _ Changed to pa_projects_all and pa_project_types_all */

Cursor c_burdening_details
IS
select type.burden_cost_flag,type.burden_amt_display_method
from   pa_projects_all proj ,pa_project_types_all type
where  proj.project_id = p_project_id
and    proj.project_type = type.project_type
and    proj.org_id = type.org_id;   /** Added this condition while making changes for Org Forecasting **/
BEGIN
   pa_debug.Set_err_stack ('Get_Burdening_Details');
   pa_debug.G_Err_Stage := 'Starting Get_Burdening_Details';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

   open c_burdening_details;
   fetch c_burdening_details
   into x_burdening_allowed,x_burden_amt_display_method;
   close c_burdening_details;

   pa_debug.Reset_err_stack;
   pa_debug.G_Err_Stage := 'Exitting Get_Burdening_Details';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      raise;

END Get_Burdening_Details;
--------------------------------------------------------------------------------

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
	x_denom_transfer_price	IN  OUT	NOCOPY  PA_PLSQL_DATATYPES.NumTabTyp,
	x_tp_ind_compiled_set_id IN OUT	NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp,
	x_tp_bill_rate		 IN OUT	NOCOPY  PA_PLSQL_DATATYPES.NumTabTyp,
      x_tp_bill_markup_percentage IN OUT NOCOPY  PA_PLSQL_DATATYPES.NumTabTyp,
        x_tp_job_id               IN OUT NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp,
	x_error_code		IN OUT  NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp
        )
IS

l_basis_calc_curr_code PA_PLSQL_DATATYPES.Char15TabTyp;
l_basis_calc_amount    PA_PLSQL_DATATYPES.NumTabTyp;
l_basis_error_code	PA_PLSQL_DATATYPES.Char30TabTyp;
l_bill_calc_curr_code PA_PLSQL_DATATYPES.Char15TabTyp;
l_bill_calc_amount    PA_PLSQL_DATATYPES.NumTabTyp;
l_tp_bill_rate        PA_PLSQL_DATATYPES.NumTabTyp;
l_tp_bill_markup_percentage PA_PLSQL_DATATYPES.NumTabTyp;
l_bill_error_stage	VARCHAR2(80);
l_bill_reject_cnt Number;
l_bill_error_code	PA_PLSQL_DATATYPES.Char30TabTyp;
l_burden_error_code	PA_PLSQL_DATATYPES.Char30TabTyp;
l_burden_calc_curr_code PA_PLSQL_DATATYPES.Char15TabTyp;
l_burden_calc_amount    PA_PLSQL_DATATYPES.NumTabTyp;
l_exp_uom               PA_PLSQL_DATATYPES.Char30TabTyp;
l_bill_rate_compute_flag PA_PLSQL_DATATYPES.Char1TabTyp;
l_burden_status	NUMBER;
l_burden_stage NUMBER;
l_temp_transfer_price NUMBER;


BEGIN
   pa_debug.Set_err_stack ('Determine_Transfer_Price');
   pa_debug.G_Err_Stage := 'Starting Determine_Transfer_Price';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;
   l_bill_rate_compute_flag := p_bill_rate_compute_flag;

   l_basis_error_code := x_error_code;
   l_burden_error_code := x_error_code;
   l_bill_error_code := x_error_code;

   IF G_Basis_Exists THEN
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG','Using Basis');
   END IF;
      Get_Basis_Amount(
	 p_tp_base_curr_code => p_tp_base_curr_code,
	 p_tp_base_amount => p_tp_base_amount,
	 p_compute_flag => p_basis_compute_flag,
	 p_array_size => G_array_size,
	 x_denom_tp_curr_code => l_basis_calc_curr_code,
	 x_amount => l_basis_calc_amount,
	 x_error_code => l_basis_error_code
		);
   END IF;

   IF G_Bill_Rate_Exists THEN
      -- Call Bill rate API
   IF g1_debug_mode  = 'Y' THEN
    pa_debug.write_file('LOG','Using Bill Rate');
   END IF;

      pa_bill_schedule.get_computed_bill_rate(
	 p_array_size => G_Array_Size,
	 p_bill_rate_sch_id => p_rate_schedule_id,
	 p_expenditure_item_id => p_expenditure_item_id,
	 p_exp_sys_linkage => p_system_linkage_function,
	 p_expenditure_type => p_expenditure_type,
	 p_expenditure_item_date => p_expenditure_item_date,
	 p_fixed_date => p_fixed_date,
	 p_quantity => p_quantity,
	 p_incurred_by_person_id => p_incurred_by_person_id,
	 p_non_labor_resource => p_non_labor_resource,
	 p_base_curr => p_tp_base_curr_code,
	 p_base_amt => p_tp_base_amount,
	 p_exp_uom =>l_exp_uom ,
	 p_compute_flag => l_bill_rate_compute_flag,
	 x_error_code => l_bill_error_code,
	 x_reject_cnt => l_bill_reject_cnt,
	 x_computed_rate => l_tp_bill_rate,
	 x_computed_markup => l_tp_bill_markup_percentage,
	 x_computed_currency => l_bill_calc_curr_code,
	 x_computed_amount => l_bill_calc_amount,
         x_tp_job_id => x_tp_job_id,
	 x_error_stage => l_bill_error_stage
	 );
    END IF;


   IF G_Burden_Rate_Exists THEN
      -- Call Burden rate API
   IF g1_debug_mode  = 'Y' THEN
    pa_debug.write_file('LOG','Using Burden schedule');
   END IF;
      get_burden_amount(
	  p_array_size => G_array_size,
          p_burden_schedule_id => p_rate_schedule_id,
	  p_expenditure_item_date => p_expenditure_item_date,
          p_fixed_date => p_fixed_date,
          p_expenditure_type => p_expenditure_type,
          p_organization_id => p_expnd_organization_id,
	  p_raw_amount_curr_code => p_tp_base_curr_code,
          p_raw_amount => p_tp_base_amount ,
	  p_compute_flag => p_burden_rate_compute_flag,
	  x_computed_currency => l_burden_calc_curr_code,
          x_burden_amount => l_burden_calc_amount,
          x_compiled_set_id => x_tp_ind_compiled_set_id,
	  x_error_code => l_burden_error_code
	  );
   END IF;

   -- Now set the out parameters transfer price ,denom transfer price currency
   -- code and error code.
   For i in 1 .. G_Array_Size
   Loop
      IF (p_compute_flag(i) = 'Y' and x_error_code(i) is null) THEN

	 IF (p_basis_compute_flag(i) = 'Y') THEN

	    IF ((l_basis_error_code.exists(i)
			   AND l_basis_error_code(i) IS NOT NULL)) THEN
	       x_error_code(i) := l_basis_error_code(i);
            ELSE
	        x_denom_tp_currency_code(i) := l_basis_calc_curr_code(i);
	        l_temp_transfer_price := l_basis_calc_amount(i)*
				 (NVL(p_tp_schedule_line_percentage(i),100)/100)
				   * (NVL(p_tp_rule_percentage(i),100)/100);
	        x_denom_transfer_price(i) := pa_currency.round_trans_currency_amt
					(l_temp_transfer_price,
						x_denom_tp_currency_code(i));
            END IF; /** Checking error code **/

         ELSIF (p_bill_rate_compute_flag(i) = 'Y') THEN

	    IF (l_bill_error_code.exists(i)
			    AND l_bill_error_code(i) IS NOT NULL) THEN
	        x_error_code(i) := l_bill_error_code(i);
            ELSE
	       x_tp_bill_rate(i) := l_tp_bill_rate(i);
	       x_tp_bill_markup_percentage(i) := l_tp_bill_markup_percentage(i);
	       x_denom_tp_currency_code(i) := l_bill_calc_curr_code(i);
	       l_temp_transfer_price := l_bill_calc_amount(i)*
				  (NVL(p_tp_schedule_line_percentage(i),100)/100)
				     * (NVL(p_tp_rule_percentage(i),100)/100);
	       x_denom_transfer_price(i) := pa_currency.round_trans_currency_amt
					(l_temp_transfer_price,
						x_denom_tp_currency_code(i));
            END IF;

         ELSIF (p_burden_rate_compute_flag(i) = 'Y') THEN

	    IF (l_burden_error_code.exists(i)
			   AND l_burden_error_code(i) IS NOT NULL ) THEN
	       x_error_code(i) := l_burden_error_code(i);
            ELSE

	       x_denom_tp_currency_code(i) := l_burden_calc_curr_code(i);
	       l_temp_transfer_price := l_burden_calc_amount(i)*
				  (NVL(p_tp_schedule_line_percentage(i),100)/100)
				     * (NVL(p_tp_rule_percentage(i),100)/100);
	       x_denom_transfer_price(i) := pa_currency.round_trans_currency_amt
					(l_temp_transfer_price,
						x_denom_tp_currency_code(i));
            END IF;
         END IF;

      END IF; /**  p_compute_flag(i) = 'Y' and x_error_code(i) is null  **/

   END Loop;

   pa_debug.Reset_err_stack;
   pa_debug.G_Err_Stage := 'Exitting Determine_transfer_price';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;
EXCEPTION

   WHEN OTHERS THEN
      raise;
END Determine_transfer_Price;
--------------------------------------------------------------------------------
PROCEDURE Get_Basis_Amount(
	p_compute_flag			IN	PA_PLSQL_DATATYPES.Char1TabTyp,
	p_tp_base_curr_code		IN	PA_PLSQL_DATATYPES.Char15TabTyp,
	p_tp_base_amount		IN	PA_PLSQL_DATATYPES.NumTabTyp,
	p_array_size			IN	Number,
	x_denom_tp_curr_code	OUT	NOCOPY PA_PLSQL_DATATYPES.Char15TabTyp,
	x_amount		OUT	NOCOPY PA_PLSQL_DATATYPES.NumTabTyp,
	x_error_code		IN OUT	NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp
			)
IS
BEGIN
   pa_debug.Set_err_stack ('Get_Basis_Amount');
   pa_debug.G_Err_Stage := 'Starting Get_Basis_Amount';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;
   For i in 1 .. p_Array_Size
   Loop
      IF (p_compute_flag(i) = 'Y' AND x_error_code(i) IS NULL) THEN
         pa_debug.G_Err_Stage := 'Processing Get_Basis_Amount';
   	IF g1_debug_mode  = 'Y' THEN
         pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	END IF;
	 IF (p_tp_base_curr_code(i) IS NOT NULL
	     and p_tp_base_amount(i) IS NOT NULL) THEN
             pa_debug.G_Err_Stage:='Setting currency,amount in Get_Basis_Amount';
   	     IF g1_debug_mode  = 'Y' THEN
             pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   	     END IF;
	     x_denom_tp_curr_code(i) := p_tp_base_curr_code(i);
	     x_amount(i) := p_tp_base_amount(i);
         ELSE
	    x_error_code(i) := 'PA_CC_TP_BASE_CURR_AMT_NULL';
         END IF;
      END IF;
   End Loop;

   pa_debug.Reset_err_stack;
   pa_debug.G_Err_Stage := 'Exitting Get_Basis_Amount';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

EXCEPTION

WHEN OTHERS THEN
    raise;
END Get_Basis_Amount;
-------------------------------------------------------------------------------
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
			)
IS

l_status NUMBER;
l_stage NUMBER;
l_burden_sch_rev_id Number;
l_burden_amount Number;
l_effective_date Date;

unexpected_result exception;

BEGIN

   pa_debug.Set_err_stack ('Get_Burden_Amount');
   pa_debug.G_Err_Stage := 'Starting Get_Burden_Amount';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

   For i in 1 .. p_array_size
   LOOP

      IF (p_compute_flag(i) = 'Y' and x_error_code(i) IS NULL) THEN

	 IF p_fixed_date(i) is null THEN
	    l_effective_date := p_expenditure_item_date(i);
         else
	    l_effective_date := p_fixed_date(i);
         END IF;

   	 IF g1_debug_mode  = 'Y' THEN
	 pa_debug.write_file('LOG','Burden Schedule ID: '
				      ||to_char(p_burden_schedule_id(i)));
	 pa_debug.write_file('LOG','Effective Date: '
				    ||to_char(l_effective_date));
	 pa_debug.write_file('LOG','Expenditure Type: '
				    ||p_expenditure_type(i));
	 pa_debug.write_file('LOG','Expenditure Organization ID: '
				    ||to_char(p_organization_id(i)));
	 pa_debug.write_file('LOG','Raw Amount IS : '
				    ||to_char(p_raw_amount(i)));
   	 END IF;

	 PA_COST_PLUS.Get_Burden_Amount(
			p_burden_schedule_id(i),
			l_effective_date,
			p_expenditure_type(i),
			p_organization_id(i),
			p_raw_amount(i),
			l_burden_amount,
			l_burden_sch_rev_id,
			x_compiled_set_id(i),
		        l_status,
			l_stage
			);


          IF l_status = 0 THEN
	     x_computed_currency(i) := p_raw_amount_curr_code(i);
	     x_burden_amount(i) := l_burden_amount;
   	     IF g1_debug_mode  = 'Y' THEN
	     pa_debug.write_file('LOG','Burden Amount IS : '
				    ||to_char(l_burden_amount));
	     pa_debug.write_file('LOG','Burden Schedule Revision ID : '
				    ||to_char(l_burden_sch_rev_id));
	     pa_debug.write_file('LOG','Compilede Set ID : '
				    ||to_char(x_compiled_set_id(i)));
   	     END IF;
	  ELSIF l_status < 0 THEN
             pa_debug.G_Err_Stage := 'Error in PA_COST_PLUS.Get_Burden_Amount';
	     -- unhandled exception
	     raise unexpected_result;
          ELSIF l_status > 0 THEN
	     x_error_code(i) := 'PA_CC_TP_ERROR_BURDEN_RATE';
          END IF;

      END IF; /** (p_compute_flag = 'Y' and x_error_code IS NULL) **/

   End Loop;

   pa_debug.Reset_err_stack;
   pa_debug.G_Err_Stage := 'Exitting Get_Burden_Amount';
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',pa_debug.G_Err_Stage);
   END IF;

EXCEPTION

   WHEN unexpected_result THEN
      raise;

   WHEN OTHERS THEN
      raise;
END Get_Burden_Amount;
--------------------------------------------------------------------------------


/* Bug 3051110-Added procedure Get_Initial_Transfer_Price for TP Enhancement. */

PROCEDURE Get_Initial_Transfer_Price
( p_assignment_id     IN         pa_project_assignments.assignment_id%TYPE
 ,p_start_date        IN        pa_project_assignments.start_date%TYPE
 ,p_debug_mode        IN         VARCHAR2 DEFAULT 'N'
 ,x_transfer_price_rate OUT     NOCOPY pa_project_assignments.transfer_price_rate%TYPE /*file.sql.39*/
 ,x_transfer_pr_rate_curr OUT  NOCOPY pa_project_assignments.transfer_pr_rate_curr%TYPE  /*file.sql.39*/
 ,x_return_status     OUT NOCOPY       VARCHAR2 /*file.sql.39*/
 ,x_msg_data          OUT NOCOPY       VARCHAR2 /*file.sql.39*/
 ,x_msg_count         OUT NOCOPY       Number /*file.sql.39*/
)
IS

CURSOR Cur_Forecast_Items(c_assignment_id pa_project_assignments.assignment_id%TYPE,
  c_start_date pa_project_assignments.start_date%TYPE)  IS SELECT
FI.forecast_item_id,
FI.forecast_item_type,
FI.EXPENDITURE_ORG_ID,
FI.EXPENDITURE_ORGANIZATION_ID,
FI.PROJECT_ORG_ID,
FI.PROJECT_ORGANIZATION_ID,
FI.PROJECT_ID,
FI.PROJECT_TYPE_CLASS,
FI.PERSON_ID,
FI.RESOURCE_ID,
FI.ASSIGNMENT_ID,
FI.ITEM_DATE,
FI.ITEM_UOM,
FI.PVDR_PA_PERIOD_NAME,
FI.RCVR_PA_PERIOD_NAME,
FI.EXPENDITURE_TYPE,
FI.EXPENDITURE_TYPE_CLASS,
FI.Tp_Amount_Type,
FI.Delete_Flag
FROM
Pa_Forecast_Items FI
WHERE        FI.Assignment_id = c_assignment_id
AND          FI.Error_Flag = 'N'
AND          FI.Delete_Flag = 'N'
AND	     FI.Item_Date = c_start_date;

Cursor FI_Attributes(C_PROJECT_ORG_ID pa_forecasting_options.ORG_ID%TYPE,
                     C_EXPENDITURE_TYPE pa_expenditure_types.expenditure_type%TYPE,
		     C_PVDR_PA_PERIOD_NAME Pa_periods_all.PERIOD_NAME%TYPE,
		     C_EXPENDITURE_ORG_ID pa_forecasting_options.ORG_ID%TYPE)
IS
SELECT
FCST.JOB_COST_RATE_SCHEDULE_ID,
EXP.Expenditure_CATEGORY,
PERIODS.End_Date
FROM
Pa_periods_all PERIODS,
Pa_forecasting_options_all Fcst,
Pa_expenditure_types Exp
WHERE
Exp.Expenditure_type = C_EXPENDITURE_TYPE
AND          PERIODS.PERIOD_NAME = C_PVDR_PA_PERIOD_NAME
AND          PERIODS.ORG_ID = C_EXPENDITURE_ORG_ID
AND          FCST.ORG_ID  = C_PROJECT_ORG_ID;

Cursor Proj_Details(c_project_id pa_projects_all.project_id%type) IS
              SELECT Project_Type,
               DISTRIBUTION_RULE,
               BILL_JOB_GROUP_ID,
               COST_JOB_GROUP_ID,
               JOB_BILL_RATE_SCHEDULE_ID,
               EMP_BILL_RATE_SCHEDULE_ID,
               PROJECT_CURRENCY_CODE,
               PROJECT_RATE_DATE,
               PROJECT_RATE_TYPE,
               PROJECT_BIL_RATE_DATE_CODE,
               PROJECT_BIL_RATE_TYPE,
               PROJECT_BIL_RATE_DATE,
               PROJECT_BIL_EXCHANGE_RATE,
               PROJFUNC_CURRENCY_CODE,
               PROJFUNC_COST_RATE_TYPE,
               PROJFUNC_COST_RATE_DATE,
               PROJFUNC_BIL_RATE_DATE_CODE,
               PROJFUNC_BIL_RATE_TYPE,
               PROJFUNC_BIL_RATE_DATE,
               PROJFUNC_BIL_EXCHANGE_RATE,
               LABOR_TP_SCHEDULE_ID,
               LABOR_TP_FIXED_DATE,
               LABOR_SCHEDULE_DISCOUNT,
               NVL(ASSIGN_PRECEDES_TASK, 'N'),
               LABOR_BILL_RATE_ORG_ID,
               LABOR_STD_BILL_RATE_SCHDL,
               LABOR_SCHEDULE_FIXED_DATE,
               LABOR_SCH_TYPE
             FROM  Pa_Projects_All P
             WHERE P.Project_Id = c_project_id;

Cursor Proj_Assignment(c_assignment_id pa_project_assignments.assignment_id%type) IS
	SELECT Fcst_Job_Id,
                   Fcst_Job_Group_Id,
                   Project_Role_Id,
                   ASSIGNMENT_TYPE,
                   STATUS_CODE
   	FROM
   	PA_PROJECT_ASSIGNMENTS PA
	WHERE PA.Assignment_id= c_assignment_id;

  l_calling_mode                 VARCHAR2(20);

  l_fi_id_tab                    PA_PLSQL_DATATYPES.IdTabTyp;
  l_fi_item_type_tab             PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fi_exp_orgid_tab             PA_PLSQL_DATATYPES.IdTabTyp;
  l_fi_exp_organizationid_tab    PA_PLSQL_DATATYPES.IdTabTyp;
  l_fi_proj_orgid_tab            PA_PLSQL_DATATYPES.IdTabTyp;
  l_fi_proj_organizationid_tab   PA_PLSQL_DATATYPES.IdTabTyp;
  l_fi_projid_tab                PA_PLSQL_DATATYPES.IdTabTyp;
  l_fi_proj_type_class_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fi_personid_tab              PA_PLSQL_DATATYPES.IdTabTyp;
  l_fi_resid_tab                 PA_PLSQL_DATATYPES.IdTabTyp;
  l_fi_asgid_tab                 PA_PLSQL_DATATYPES.IdTabTyp;
  l_fi_date_tab                  PA_PLSQL_DATATYPES.DateTabTyp;
  l_fi_uom_tab                   PA_PLSQL_DATATYPES.Char30TabTyp;
  l_qty_tab                      PA_PLSQL_DATATYPES.NumTabTyp;
  l_fi_pvdr_papd_tab             PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fi_rcvr_papd_tab             PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fi_exptype_tab               PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fi_exptypeclass_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fi_amount_type_tab           PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fi_delete_flag_tab           PA_PLSQL_DATATYPES.Char1TabTyp;

  l_cc_taskid_tab                PA_PLSQL_DATATYPES.IdTabTyp;
  l_cc_expitemid_tab             PA_PLSQL_DATATYPES.IdTabTyp;
  l_cc_transsource_tab           PA_PLSQL_DATATYPES.Char30TabTyp;
  l_cc_NLOrgzid_tab              PA_PLSQL_DATATYPES.IdTabTyp;
  l_cc_prvdreid_tab              PA_PLSQL_DATATYPES.IdTabTyp;
  l_cc_recvreid_tab              PA_PLSQL_DATATYPES.IdTabTyp;
  lx_cc_status_tab               PA_PLSQL_DATATYPES.Char30TabTyp;
  lx_cc_type_tab                 PA_PLSQL_DATATYPES.Char3TabTyp;
  lx_cc_code_tab                 PA_PLSQL_DATATYPES.Char1TabTyp;
  lx_cc_prvdr_orgzid_tab         PA_PLSQL_DATATYPES.IdTabTyp;
  lx_cc_recvr_orgzid_tab         PA_PLSQL_DATATYPES.IdTabTyp;
  lx_cc_recvr_orgid_tab          PA_PLSQL_DATATYPES.IdTabTyp;
  lx_cc_prvdr_orgid_tab          PA_PLSQL_DATATYPES.IdTabTyp;
  lx_cc_error_stage              VARCHAR2(500);
  lx_cc_error_code               NUMBER;

    /* Project Info */
  l_prj_type          Pa_Projects_All.Project_Type%TYPE;
  l_distribution_rule Pa_Projects_All.Distribution_Rule%TYPE;
  l_bill_job_group_id Pa_Projects_All.Bill_Job_Group_Id%TYPE;
  l_cost_job_group_id Pa_Projects_All.Cost_Job_Group_Id%TYPE;
  l_job_bill_rate_sch_id Pa_Projects_All.JOB_BILL_RATE_SCHEDULE_ID%TYPE;
  l_emp_bill_rate_sch_id Pa_Projects_All.EMP_BILL_RATE_SCHEDULE_ID%TYPE;
  l_prj_curr_code Pa_Projects_All.PROJECT_CURRENCY_CODE%TYPE;
  l_prj_rate_date Pa_Projects_All.PROJECT_RATE_DATE%TYPE;
  l_prj_rate_type Pa_Projects_All.PROJECT_RATE_TYPE%TYPE;
  l_prj_bil_rate_date_code Pa_Projects_All.PROJECT_BIL_RATE_DATE_CODE%TYPE;
  l_prj_bil_rate_type Pa_Projects_All.PROJECT_BIL_RATE_TYPE%TYPE;
  l_prj_bil_rate_date Pa_Projects_All.PROJECT_BIL_RATE_DATE%TYPE;
  l_prj_bil_ex_rate Pa_Projects_All.PROJECT_BIL_EXCHANGE_RATE%TYPE;
  l_prjfunc_curr_code Pa_Projects_All.PROJFUNC_CURRENCY_CODE%TYPE;
  l_prjfunc_cost_rate_type Pa_Projects_All.PROJFUNC_COST_RATE_TYPE%TYPE;
  l_prjfunc_cost_rate_date Pa_Projects_All.PROJFUNC_COST_RATE_DATE%TYPE;
  l_prjfunc_bil_rate_date_code Pa_Projects_All.PROJFUNC_BIL_RATE_DATE_CODE%TYPE;
  l_prjfunc_bil_rate_type Pa_Projects_All.PROJFUNC_BIL_RATE_TYPE%TYPE;
  l_prjfunc_bil_rate_date Pa_Projects_All.PROJFUNC_BIL_RATE_DATE%TYPE;
  l_prjfunc_bil_ex_rate Pa_Projects_All.PROJFUNC_BIL_EXCHANGE_RATE%TYPE;
  l_labor_tp_schedule_id Pa_Projects_All.LABOR_TP_SCHEDULE_ID%TYPE;
  l_labor_tp_fixed_date Pa_Projects_All.LABOR_TP_FIXED_DATE%TYPE;
  l_labor_sch_discount Pa_Projects_All.LABOR_SCHEDULE_DISCOUNT%TYPE;
  l_asg_precedes_task Pa_Projects_All.ASSIGN_PRECEDES_TASK%TYPE;
  l_labor_bill_rate_orgid Pa_Projects_All.LABOR_BILL_RATE_ORG_ID%TYPE;
  l_labor_std_bill_rate_sch Pa_Projects_All.LABOR_STD_BILL_RATE_SCHDL%TYPE;
  l_labor_sch_fixed_dt Pa_Projects_All.LABOR_SCHEDULE_FIXED_DATE%TYPE;
  l_labor_sch_type Pa_Projects_All.LABOR_SCH_TYPE%TYPE;

  l_fcst_opt_jobcostrate_sch_id NUMBER;

/* Project Assignment Info */

  l_asg_fcst_job_id Pa_Project_Assignments.Fcst_Job_Id%TYPE;
  l_asg_fcst_job_group_id Pa_Project_Assignments.Fcst_Job_Group_Id%TYPE;
  l_asg_project_role_id Pa_Project_Assignments.Project_Role_Id%TYPE;
  l_prj_assignment_type          PA_PROJECT_ASSIGNMENTS.ASSIGNMENT_TYPE%TYPE;
  l_prj_status_code              PA_PROJECT_ASSIGNMENTS.STATUS_CODE%TYPE;

  l_projfunc_rev_rt_dt_code_tab  PA_PLSQL_DATATYPES.Char30TabTyp;
  l_projfunc_rev_rt_date_tab     PA_PLSQL_DATATYPES.DateTabTyp;
  l_projfunc_rev_rt_type_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
  l_projfunc_rev_exch_rt_tab     PA_PLSQL_DATATYPES.NumTabTyp;
  l_projfunc_cst_rt_date_tab     PA_PLSQL_DATATYPES.DateTabTyp;
  l_projfunc_cst_rt_type_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
  l_project_rev_rt_dt_code_tab  PA_PLSQL_DATATYPES.Char30TabTyp;
  l_project_rev_rt_date_tab     PA_PLSQL_DATATYPES.DateTabTyp;
  l_project_rev_rt_type_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
  l_project_rev_exch_rt_tab     PA_PLSQL_DATATYPES.NumTabTyp;
  l_project_cst_rt_date_tab     PA_PLSQL_DATATYPES.DateTabTyp;
  l_project_cst_rt_type_tab     PA_PLSQL_DATATYPES.Char30TabTyp;

  /* Out Parameters */
  lx_rt_pfunc_bill_rate_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_pfunc_raw_revenue_tab     PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_pfunc_raw_cost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_pfunc_raw_cost_rt_tab     PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_pfunc_bd_cost_rt_tab      PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_pfunc_bd_cost_tab         PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_pfunc_rev_rt_date_tab   PA_PLSQL_DATATYPES.DateTabTyp ;
  lx_rt_pfunc_rev_rt_type_tab   PA_PLSQL_DATATYPES.Char30TabTyp;
  lx_rt_pfunc_rev_ex_rt_tab     PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_pfunc_cost_rt_date_tab  PA_PLSQL_DATATYPES.DateTabTyp;
  lx_rt_pfunc_cost_rt_type_tab  PA_PLSQL_DATATYPES.Char30TabTyp;
  lx_rt_pfunc_cost_ex_rt_tab    PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_proj_bill_rate_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_proj_raw_revenue_tab     PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_proj_raw_cost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_proj_raw_cost_rt_tab     PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_proj_bd_cost_rt_tab      PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_proj_bd_cost_tab         PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_proj_rev_rt_date_tab   PA_PLSQL_DATATYPES.DateTabTyp ;
  lx_rt_proj_rev_rt_type_tab   PA_PLSQL_DATATYPES.Char30TabTyp;
  lx_rt_proj_rev_ex_rt_tab     PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_proj_cost_rt_date_tab  PA_PLSQL_DATATYPES.DateTabTyp;
  lx_rt_proj_cost_rt_type_tab  PA_PLSQL_DATATYPES.Char30TabTyp;
  lx_rt_proj_cost_ex_rt_tab    PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_expfunc_curr_code_tab   PA_PLSQL_DATATYPES.Char15TabTyp;
  lx_rt_expfunc_cost_rt_date_tab PA_PLSQL_DATATYPES.DateTabTyp;
  lx_rt_expfunc_cost_rt_type_tab PA_PLSQL_DATATYPES.Char30TabTyp;
  lx_rt_expfunc_cost_ex_rt_tab  PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_expfunc_raw_cst_rt_tab   PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_expfunc_raw_cst_tab      PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_expfunc_bd_cst_rt_tab    PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_expfunc_bd_cst_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_cost_txn_curr_code_tab  PA_PLSQL_DATATYPES.Char15TabTyp;
  lx_rt_txn_raw_cost_rt_tab     PA_PLSQL_DATATYPES.NumTabTyp ;
  lx_rt_txn_raw_cost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_txn_bd_cost_rt_tab      PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_txn_bd_cost_tab         PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_rev_txn_curr_code_tab   PA_PLSQL_DATATYPES.Char15TabTyp;
  lx_rt_txn_rev_bill_rt_tab     PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_txn_raw_revenue_tab     PA_PLSQL_DATATYPES.NumTabTyp;
  lx_rt_rev_rejct_reason_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
  lx_rt_cst_rejct_reason_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
  lx_rt_bd_rejct_reason_tab      PA_PLSQL_DATATYPES.Char30TabTyp;
  lx_rt_others_rejct_reason_tab  PA_PLSQL_DATATYPES.Char30TabTyp;

  lx_asg_precedes_task_tab        PA_PLSQL_DATATYPES.Char1TabTyp; -- Added for bug 3255061

  lx_rt_error_msg VARCHAR2(1000);
  lx_rt_return_status VARCHAR2(30);
  lx_rt_msg_count NUMBER;
  lx_rt_msg_data VARCHAR2(100);

  ERROR_OCCURED VARCHAR2(1);

  /* Get Transfer Price Parameters */

  l_cc_exp_category Pa_Expenditure_Types.EXPENDITURE_CATEGORY%TYPE;

  l_tp_asgid                     PA_PLSQL_DATATYPES.IdTabTyp;
  l_tp_exp_category              PA_PLSQL_DATATYPES.Char30TabTyp;
  l_tp_labor_nl_flag             PA_PLSQL_DATATYPES.Char1TabTyp;
  l_tp_taskid                    PA_PLSQL_DATATYPES.IdTabTyp;
  l_tp_scheduleid                PA_PLSQL_DATATYPES.IdTabTyp;
  l_tp_denom_currcode            PA_PLSQL_DATATYPES.Char15TabTyp;
  l_tp_rev_distributed_flag      PA_PLSQL_DATATYPES.Char1TabTyp;
  l_tp_compute_flag              PA_PLSQL_DATATYPES.Char1TabTyp;
  l_tp_fixed_date                PA_PLSQL_DATATYPES.DateTabTyp;
  l_tp_denom_raw_cost            PA_PLSQL_DATATYPES.NumTabTyp;
  l_tp_denom_bd_cost             PA_PLSQL_DATATYPES.NumTabTyp;
  l_tp_raw_revenue               PA_PLSQL_DATATYPES.NumTabTyp;
  l_tp_nl_resource               PA_PLSQL_DATATYPES.Char20TabTyp;
  l_tp_nl_resource_orgzid        PA_PLSQL_DATATYPES.IdTabTyp;
  l_tp_pa_date                   PA_PLSQL_DATATYPES.DateTabTyp;
  l_prj_curr_code_tab 	PA_PLSQL_DATATYPES.Char15TabTyp;
  l_prjfunc_curr_code_tab   PA_PLSQL_DATATYPES.Char15TabTyp;
  l_tp_quantity_tab PA_PLSQL_DATATYPES.NumTabTyp;
  l_asg_fcst_jobid_tab PA_PLSQL_DATATYPES.IdTabTyp;

  lx_proj_tp_rate_type           PA_PLSQL_DATATYPES.Char30TabTyp;
  lx_proj_tp_rate_date           PA_PLSQL_DATATYPES.DateTabTyp;
  lx_proj_tp_exchange_rate       PA_PLSQL_DATATYPES.NumTabTyp;
  lx_proj_tp_amt                 PA_PLSQL_DATATYPES.NumTabTyp;
  lx_projfunc_tp_rate_type       PA_PLSQL_DATATYPES.Char30TabTyp;
  lx_projfunc_tp_rate_date       PA_PLSQL_DATATYPES.DateTabTyp;
  lx_projfunc_tp_exchange_rate   PA_PLSQL_DATATYPES.NumTabTyp;
  lx_projfunc_tp_amt             PA_PLSQL_DATATYPES.NumTabTyp;
  lx_denom_tp_currcode           PA_PLSQL_DATATYPES.Char15TabTyp;
  lx_denom_tp_amt                PA_PLSQL_DATATYPES.NumTabTyp;
  lx_expfunc_tp_rate_type        PA_PLSQL_DATATYPES.Char30TabTyp;
  lx_expfunc_tp_rate_date        PA_PLSQL_DATATYPES.DateTabTyp;
  lx_expfunc_tp_exchange_rate    PA_PLSQL_DATATYPES.NumTabTyp;
  lx_expfunc_tp_amt              PA_PLSQL_DATATYPES.NumTabTyp;
  lx_cc_markup_basecode          PA_PLSQL_DATATYPES.Char1TabTyp;
  lx_tp_ind_compiled_setid       PA_PLSQL_DATATYPES.IdTabTyp;
  lx_tp_bill_rate                PA_PLSQL_DATATYPES.NumTabTyp;
  lx_tp_base_amount              PA_PLSQL_DATATYPES.NumTabTyp;
  lx_tp_bill_markup_percent      PA_PLSQL_DATATYPES.NumTabTyp;
  lx_tp_sch_line_percent         PA_PLSQL_DATATYPES.NumTabTyp;
  lx_tp_rule_percent             PA_PLSQL_DATATYPES.NumTabTyp;
  lx_tp_job_id                   PA_PLSQL_DATATYPES.IdTabTyp;
  lx_tp_error_code               PA_PLSQL_DATATYPES.Char30TabTyp;
  l_tp_array_size                NUMBER;
  l_tp_debug_mode                VARCHAR2(30);
  lx_tp_return_status            NUMBER;


BEGIN

IF p_debug_mode = 'Y' THEN
  pa_debug.write('PA_CC_TRANSFER_PRICE.Get_Initial_Transfer_Price', 'ENTERING Get_Initial_Transfer_Price', 3);
END IF;

x_return_status     :=  FND_API.G_RET_STS_SUCCESS;

Open Cur_Forecast_Items(p_assignment_id, p_start_date);

PA_DEBUG.g_err_stage := 'Fetching Cur_Forecast_Items';
PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

  l_fi_id_tab.delete;
  l_fi_item_type_tab.delete;
  l_fi_exp_orgid_tab.delete;
  l_fi_exp_organizationid_tab.delete;
  l_fi_proj_orgid_tab.delete;
  l_fi_proj_organizationid_tab.delete;
  l_fi_projid_tab.delete;
  l_fi_proj_type_class_tab.delete;
  l_fi_personid_tab.delete;
  l_fi_resid_tab.delete;
  l_fi_asgid_tab.delete;
  l_fi_date_tab.delete;
  l_fi_uom_tab.delete;
  l_fi_pvdr_papd_tab.delete;
  l_fi_rcvr_papd_tab.delete;
  l_fi_exptype_tab.delete;
  l_fi_exptypeclass_tab.delete;
  l_fi_amount_type_tab.delete;
  l_fi_delete_flag_tab.delete;
  l_cc_taskid_tab.delete;
  l_cc_expitemid_tab.delete;
  l_cc_transsource_tab.delete;
  l_cc_NLOrgzid_tab.delete;
  l_cc_prvdreid_tab.delete;
  l_cc_recvreid_tab.delete;
  lx_cc_status_tab.delete;
  lx_cc_type_tab.delete;
  lx_cc_code_tab.delete;
  lx_cc_prvdr_orgzid_tab.delete;
  lx_cc_recvr_orgzid_tab.delete;
  lx_cc_recvr_orgid_tab.delete;
  lx_cc_prvdr_orgid_tab.delete;

FETCH Cur_Forecast_Items BULK COLLECT INTO
  l_fi_id_tab,
  l_fi_item_type_tab,
  l_fi_exp_orgid_tab,
  l_fi_exp_organizationid_tab,
  l_fi_proj_orgid_tab,
  l_fi_proj_organizationid_tab,
  l_fi_projid_tab,
  l_fi_proj_type_class_tab,
  l_fi_personid_tab,
  l_fi_resid_tab,
  l_fi_asgid_tab,
  l_fi_date_tab,
  l_fi_uom_tab,
  l_fi_pvdr_papd_tab,
  l_fi_rcvr_papd_tab,
  l_fi_exptype_tab,
  l_fi_exptypeclass_tab,
  l_fi_amount_type_tab,
  l_fi_delete_flag_tab;

CLOSE Cur_Forecast_Items;

IF p_debug_mode = 'Y' THEN
  pa_debug.write('PA_CC_TRANSFER_PRICE.Get_Initial_Transfer_Price', 'Cursor cur_forecast_items_fetched', 3);
   pa_debug.write('PA_CC_TRANSFER_PRICE.Get_Initial_Transfer_Price', 'f id:'||l_fi_id_tab(1)||' org id'||l_fi_exp_orgid_tab(1));
END IF;


        l_cc_taskid_tab(1) := NULL;
        l_cc_expitemid_tab(1) := NULL;
        l_cc_transsource_tab(1) := NULL;
        l_cc_NLOrgzid_tab(1) := NULL;
        l_cc_prvdreid_tab(1) := NULL;
        l_cc_recvreid_tab(1) := NULL;
        lx_cc_type_tab(1) := NULL;
        lx_cc_code_tab(1) := NULL;
        lx_cc_prvdr_orgzid_tab(1) := NULL;
        lx_cc_recvr_orgzid_tab(1) := NULL;
        lx_cc_recvr_orgid_tab(1) := NULL;
        lx_cc_prvdr_orgid_tab(1) := NULL;
	lx_cc_status_tab(1) := NULL;

Pa_Cc_Ident.PA_CC_IDENTIFY_TXN_FI(
	  P_ExpOrganizationIdTab     => l_fi_exp_organizationid_tab,
          P_ExpOrgidTab              => l_fi_exp_orgid_tab,
          P_ProjectIdTab             => l_fi_projid_tab,
          P_TaskIdTab                => l_cc_taskid_tab,
          P_ExpItemDateTab           => l_fi_date_tab,
          P_ExpItemIdTab             => l_cc_expitemid_tab,
          P_PersonIdTab              => l_fi_personid_tab,
          P_ExpTypeTab               => l_fi_exptype_tab,
          P_SysLinkTab               => l_fi_exptypeclass_tab,
          P_PrjOrganizationIdTab     => l_fi_proj_organizationid_tab,
          P_PrjOrgIdTab              => l_fi_proj_orgid_tab,
          P_TransSourceTab           => l_cc_transsource_tab,
          P_NLROrganizationIdTab     => l_cc_NLOrgzid_tab,
          P_PrvdrLEIdTab             => l_cc_prvdreid_tab,
          P_RecvrLEIdTab             => l_cc_recvreid_tab,
          X_StatusTab                => lx_cc_status_tab,
          X_CrossChargeTypeTab       => lx_cc_type_tab,
          X_CrossChargeCodeTab       => lx_cc_code_tab,
          X_PrvdrOrganizationIdTab   => lx_cc_prvdr_orgzid_tab,
          X_RecvrOrganizationIdTab   => lx_cc_recvr_orgzid_tab,
          X_RecvrOrgIdTab            => lx_cc_recvr_orgid_tab,
          X_PrvdrOrgIdTab            => lx_cc_prvdr_orgid_tab,
          X_Error_Stage              => lx_cc_error_stage,
          X_Error_Code               => lx_cc_error_code
	  );

IF p_debug_mode = 'Y' THEN
  pa_debug.write('PA_CC_TRANSFER_PRICE.Get_Initial_Transfer_Price', 'Procedure PA_CC_IDENTIFY_TXN_FI executed', 3);
  pa_debug.write('PA_CC_TRANSFER_PRICE.Get_Initial_Transfer_Price', 'Status :'||lx_cc_status_tab(1), 3);
  pa_debug.write('PA_CC_TRANSFER_PRICE.Get_Initial_Transfer_Price', 'cc code:'||lx_cc_code_tab(1), 3);
END IF;


  If lx_cc_code_tab(1) in ('I', 'B') AND lx_cc_status_tab(1) is NULL THEN
        IF l_fi_item_type_tab(1) = 'R' THEN
           l_calling_mode := 'ROLE';
        ELSIF l_fi_item_type_tab(1) = 'A' THEN
           l_calling_mode := 'ASSIGNMENT';
        END IF;
        OPEN Proj_Details(l_fi_projid_tab(1));
	Fetch Proj_Details
	   INTO
               l_prj_type,
               l_distribution_rule,
               l_bill_job_group_id,
               l_cost_job_group_id,
               l_job_bill_rate_sch_id,
               l_emp_bill_rate_sch_id,
               l_prj_curr_code,
               l_prj_rate_date,
               l_prj_rate_type,
               l_prj_bil_rate_date_code,
               l_prj_bil_rate_type,
               l_prj_bil_rate_date,
               l_prj_bil_ex_rate,
               l_prjfunc_curr_code,
               l_prjfunc_cost_rate_type,
               l_prjfunc_cost_rate_date,
               l_prjfunc_bil_rate_date_code,
               l_prjfunc_bil_rate_type,
               l_prjfunc_bil_rate_date,
               l_prjfunc_bil_ex_rate,
               l_labor_tp_schedule_id,
               l_labor_tp_fixed_date,
               l_labor_sch_discount,
               l_asg_precedes_task,
               l_labor_bill_rate_orgid,
               l_labor_std_bill_rate_sch,
               l_labor_sch_fixed_dt,
               l_labor_sch_type;
	Close Proj_Details;

	l_projfunc_rev_rt_dt_code_tab.delete;
        l_projfunc_rev_rt_date_tab.delete;
        l_projfunc_rev_rt_type_tab.delete;
	l_projfunc_rev_exch_rt_tab.delete;
	l_projfunc_cst_rt_date_tab.delete;
	l_projfunc_cst_rt_type_tab.delete;
	l_project_rev_rt_dt_code_tab.delete;
        l_project_rev_rt_date_tab.delete;
        l_project_rev_rt_type_tab.delete;
	l_project_rev_exch_rt_tab.delete;
	l_project_cst_rt_date_tab.delete;
	l_project_cst_rt_type_tab.delete;
        l_tp_pa_date.delete;

        l_projfunc_rev_rt_dt_code_tab(1) := l_prjfunc_bil_rate_date_code;
        l_projfunc_rev_rt_date_tab(1) := l_prjfunc_bil_rate_date;
        l_projfunc_rev_rt_type_tab(1) := l_prjfunc_bil_rate_type;
	l_projfunc_rev_exch_rt_tab(1) := l_prjfunc_bil_ex_rate;
	l_projfunc_cst_rt_date_tab(1) := l_prjfunc_cost_rate_date;
	l_projfunc_cst_rt_type_tab(1) := l_prjfunc_cost_rate_type;
        l_project_rev_rt_dt_code_tab(1) := l_prj_bil_rate_date_code;
        l_project_rev_rt_date_tab(1) := l_prj_bil_rate_date;
        l_project_rev_rt_type_tab(1) := l_prj_bil_rate_type;
	l_project_rev_exch_rt_tab(1) := l_prj_bil_ex_rate;
	l_project_cst_rt_date_tab(1) := l_prj_rate_date;
	l_project_cst_rt_type_tab(1) := l_prj_rate_type;

	 Open Proj_Assignment(p_assignment_id);
         Fetch Proj_Assignment INTO
                   l_asg_fcst_job_id,
                   l_asg_fcst_job_group_id,
                   l_asg_project_role_id,
                   l_prj_assignment_type,
                   l_prj_status_code;
         Close Proj_Assignment;

          IF l_fi_item_type_tab(1) = 'R'  AND
             ( l_asg_fcst_job_id IS NULL  OR
               l_asg_fcst_job_group_id IS NULL ) THEN
            BEGIN
	    /* Starts here bug4004792 changed the table reference to  PA_PROJECT_ROLE_TYPES_B instead of the view PA_PROJECT_ROLE_TYPES for performance reason */
              SELECT pa_role_job_bg_utils.get_job_id(PR.project_role_id),
	             --PR.DEFAULT_JOB_ID,
                     PJ.JOB_GROUP_ID
              INTO
                     l_asg_fcst_job_id,
                     l_asg_fcst_job_group_id
              FROM PA_PROJECT_ROLE_TYPES_B PR,
                   PER_JOBS PJ
              WHERE
                   PR.PROJECT_ROLE_ID = l_asg_project_role_id AND
                   --  PJ.JOB_ID          = PR.DEFAULT_JOB_ID;
  		   PJ.JOB_ID          =pa_role_job_bg_utils.get_job_id(PR.project_role_id);
		 /* ends here */
              EXCEPTION
              WHEN NO_DATA_FOUND THEN
		IF p_debug_mode = 'Y' THEN
		  pa_debug.write('PA_CC_TRANSFER_PRICE.Get_Initial_Transfer_Price', 'No data found in pa_project_role_types', 3);
		END IF;
                l_asg_fcst_job_id := NULL;
                l_asg_fcst_job_group_id := NULL;
              WHEN OTHERS THEN
                PA_DEBUG.g_err_stage := 'Inside Prj Role others Excep';
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
            END;
          END IF;

	  Open FI_Attributes(l_fi_proj_orgid_tab(1), l_fi_exptype_tab(1), l_fi_pvdr_papd_tab(1), l_fi_exp_orgid_tab(1));
          Fetch FI_Attributes into l_fcst_opt_jobcostrate_sch_id, l_cc_exp_category, l_tp_pa_date(1);
	  Close FI_Attributes;

  l_qty_tab.delete;
  l_qty_tab(1) := 1;

IF p_debug_mode = 'Y' THEN
  pa_debug.write('PA_CC_TRANSFER_PRICE.Get_Initial_Transfer_Price', 'Just Calling PA_RATE_PVT_PKG.CALC_RATE_AMOUNT', 3);
END IF;

         PA_RATE_PVT_PKG.CALC_RATE_AMOUNT(
	 P_CALLING_MODE             =>  l_calling_mode,
	 P_RATE_CALC_DATE_TAB       =>  l_fi_date_tab,
	 P_ASGN_START_DATE          =>  p_start_date,
         P_ITEM_ID                  =>  p_assignment_id,
         P_PROJECT_ID               =>  l_fi_projid_tab(1),
	 P_QUANTITY_TAB             =>  l_qty_tab,
	 P_FORECAST_JOB_ID          =>  l_asg_fcst_job_id,
	 P_FORECAST_JOB_GROUP_ID    =>  l_asg_fcst_job_group_id,
	 P_PERSON_ID                =>  l_fi_personid_tab(1),
	 P_EXPENDITURE_ORG_ID_TAB   =>  l_fi_exp_orgid_tab,
	 P_EXPENDITURE_TYPE         =>  l_fi_exptype_tab(1),
	 P_EXPENDITURE_ORGZ_ID_TAB  =>  l_fi_exp_organizationid_tab,
	 P_PROJECT_ORG_ID           =>  l_fi_proj_orgid_tab(1),
	 P_LABOR_COST_MULTI_NAME    => NULL,
	 P_PROJ_COST_JOB_GROUP_ID   => NULL,
	 P_JOB_COST_RATE_SCHEDULE_ID =>   l_fcst_opt_jobcostrate_sch_id,
	 P_PROJECT_TYPE	             => l_prj_type,
	 P_TASK_ID		     => NULL,
	 P_BILL_RATE_MULTIPLIER      => NULL,
	 P_PROJECT_BILL_JOB_GROUP_ID => l_bill_job_group_id,
	 P_EMP_BILL_RATE_SCHEDULE_ID => l_emp_bill_rate_sch_id,
	 P_JOB_BILL_RATE_SCHEDULE_ID => l_job_bill_rate_sch_id,
	 P_DISTRIBUTION_RULE         => l_distribution_rule,
	 p_amount_calc_mode          =>  'ALL',
	 P_system_linkage            =>   l_fi_exptypeclass_tab,
 	 p_assign_precedes_task      => l_asg_precedes_task,
	 p_labor_schdl_discnt        => l_labor_sch_discount,
	 p_labor_bill_rate_org_id    => l_labor_bill_rate_orgid,
	 p_labor_std_bill_rate_schdl => l_labor_std_bill_rate_sch,
	 p_labor_schedule_fixed_date => l_labor_sch_fixed_dt,
	 p_labor_sch_type            => l_labor_sch_type,
         P_FORECAST_ITEM_ID_TAB      => l_fi_id_tab,
	 P_PROJFUNC_CURRENCY_CODE    => l_prjfunc_curr_code,
	 p_projfunc_rev_rt_dt_code_tab => l_projfunc_rev_rt_dt_code_tab,
 	 p_projfunc_rev_rt_date_tab    => l_projfunc_rev_rt_date_tab,
	 p_projfunc_rev_rt_type_tab    => l_projfunc_rev_rt_type_tab,
	 p_projfunc_rev_exch_rt_tab    => l_projfunc_rev_exch_rt_tab,
	 p_projfunc_cst_rt_date_tab    => l_projfunc_cst_rt_date_tab,
	 p_projfunc_cst_rt_type_tab    => l_projfunc_cst_rt_type_tab,
	 X_PROJFUNC_BILL_RT_TAB        => lx_rt_pfunc_bill_rate_tab,
	 x_projfunc_raw_revenue_tab    => lx_rt_pfunc_raw_revenue_tab,
	 x_projfunc_rev_rt_date_tab    => lx_rt_pfunc_rev_rt_date_tab,
	 x_projfunc_rev_rt_type_tab    => lx_rt_pfunc_rev_rt_type_tab,
	 x_projfunc_rev_exch_rt_tab    => lx_rt_pfunc_rev_ex_rt_tab,
         x_projfunc_raw_cst_tab        => lx_rt_pfunc_raw_cost_tab,
         x_projfunc_raw_cst_rt_tab     => lx_rt_pfunc_raw_cost_rt_tab,
	 x_projfunc_burdned_cst_tab    => lx_rt_pfunc_bd_cost_tab,
         x_projfunc_burdned_cst_rt_tab => lx_rt_pfunc_bd_cost_rt_tab,
	 x_projfunc_cst_rt_date_tab    => lx_rt_pfunc_cost_rt_date_tab,
	 x_projfunc_cst_rt_type_tab    => lx_rt_pfunc_cost_rt_type_tab,
	 x_projfunc_cst_exch_rt_tab    => lx_rt_pfunc_cost_ex_rt_tab,
	 p_project_currency_code       =>  l_prj_curr_code,
	 p_project_rev_rt_dt_code_tab  => l_project_rev_rt_dt_code_tab,
	 p_project_rev_rt_date_tab     => l_project_rev_rt_date_tab,
	 p_project_rev_rt_type_tab     => l_project_rev_rt_type_tab,
	 p_project_rev_exch_rt_tab     => l_project_rev_exch_rt_tab,
	 p_project_cst_rt_date_tab     => l_project_cst_rt_date_tab,
	 p_project_cst_rt_type_tab     => l_project_cst_rt_type_tab,
	 x_project_bill_rt_tab         => lx_rt_proj_bill_rate_tab,
	 x_project_raw_revenue_tab     => lx_rt_proj_raw_revenue_tab,
	 x_project_rev_rt_date_tab     => lx_rt_proj_rev_rt_date_tab,
	 x_project_rev_rt_type_tab     => lx_rt_proj_rev_rt_type_tab,
	 x_project_rev_exch_rt_tab     => lx_rt_proj_rev_ex_rt_tab,
	 x_project_raw_cst_tab         => lx_rt_proj_raw_cost_tab,
	 x_project_raw_cst_rt_tab      => lx_rt_proj_raw_cost_rt_tab,
	 x_project_burdned_cst_tab     => lx_rt_proj_bd_cost_tab,
	 x_project_burdned_cst_rt_tab  => lx_rt_proj_bd_cost_rt_tab,
	 x_project_cst_rt_date_tab     => lx_rt_proj_cost_rt_date_tab,
	 x_project_cst_rt_type_tab     => lx_rt_proj_cost_rt_type_tab,
	 x_project_cst_exch_rt_tab     => lx_rt_proj_cost_ex_rt_tab,
	 x_exp_func_curr_code_tab      => lx_rt_expfunc_curr_code_tab,
         x_exp_func_raw_cst_rt_tab     => lx_rt_expfunc_raw_cst_rt_tab,
         x_exp_func_raw_cst_tab        => lx_rt_expfunc_raw_cst_tab,
         x_exp_func_burdned_cst_rt_tab => lx_rt_expfunc_bd_cst_rt_tab,
         x_exp_func_burdned_cst_tab    => lx_rt_expfunc_bd_cst_tab,
	 x_exp_func_cst_rt_date_tab    => lx_rt_expfunc_cost_rt_date_tab,
	 x_exp_func_cst_rt_type_tab    => lx_rt_expfunc_cost_rt_type_tab,
	 x_exp_func_cst_exch_rt_tab    => lx_rt_expfunc_cost_ex_rt_tab,
	 x_cst_txn_curr_code_tab       => lx_rt_cost_txn_curr_code_tab,
	 x_txn_raw_cst_rt_tab          => lx_rt_txn_raw_cost_rt_tab,
	 x_txn_raw_cst_tab             => lx_rt_txn_raw_cost_tab,
	 x_txn_burdned_cst_rt_tab      => lx_rt_txn_bd_cost_rt_tab,
	 x_txn_burdned_cst_tab         => lx_rt_txn_bd_cost_tab,
 	 x_rev_txn_curr_code_tab       => lx_rt_rev_txn_curr_code_tab,
	 x_txn_rev_bill_rt_tab         => lx_rt_txn_rev_bill_rt_tab,
	 x_txn_rev_raw_revenue_tab     => lx_rt_txn_raw_revenue_tab,
 	 X_ERROR_MSG                   => lx_rt_error_msg,
	 X_REV_REJCT_REASON_TAB        => lx_rt_rev_rejct_reason_tab,
	 X_CST_REJCT_REASON_TAB        => lx_rt_cst_rejct_reason_tab,
         X_BURDNED_REJCT_REASON_TAB    => lx_rt_bd_rejct_reason_tab,
	 X_OTHERS_REJCT_REASON_TAB     => lx_rt_others_rejct_reason_tab,
	 X_RETURN_STATUS               => lx_rt_return_status,
	 X_MSG_COUNT                   => lx_rt_msg_count,
	 X_MSG_DATA                    => lx_rt_msg_data
);

IF p_debug_mode = 'Y' THEN
  pa_debug.write('PA_CC_TRANSFER_PRICE.Get_Initial_Transfer_Price', 'Done With the PA_RATE_PVT_PKG.CALC_RATE_AMOUNT', 3);
  pa_debug.write('PA_CC_TRANSFER_PRICE.Get_Initial_Transfer_Price', 'x_return status for calc_rate_amount is:'||x_return_status, 3);
  pa_debug.write('PA_CC_TRANSFER_PRICE.Get_Initial_Transfer_Price', 'lx_rt_rev_rejct_reason_tab COUNT:'||lx_rt_rev_rejct_reason_tab.count, 3);
  pa_debug.write('PA_CC_TRANSFER_PRICE.Get_Initial_Transfer_Price', 'lx_rt_cst_rejct_reason_tab.count :'||lx_rt_cst_rejct_reason_tab.count, 3);
  pa_debug.write('PA_CC_TRANSFER_PRICE.Get_Initial_Transfer_Price', 'lx_rt_bd_rejct_reason_tab.count:'||lx_rt_bd_rejct_reason_tab.count, 3);
  pa_debug.write('PA_CC_TRANSFER_PRICE.Get_Initial_Transfer_Price', 'lx_rt_others_rejct_reason_tab.count:'||lx_rt_others_rejct_reason_tab.count, 3);
END IF;


         ERROR_OCCURED := 'N';

	 IF lx_rt_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   ERROR_OCCURED := 'Y';
	 END IF;

           If lx_rt_rev_rejct_reason_tab.exists(1) THEN
	      IF lx_rt_rev_rejct_reason_tab(1) IS NOT NULL THEN
		IF p_debug_mode = 'Y' THEN
		  pa_debug.write('PA_CC_TRANSFER_PRICE.Get_Initial_Transfer_Price', 'Rev Reject:'||lx_rt_rev_rejct_reason_tab(1), 3);
                END IF;
	        ERROR_OCCURED := 'Y';
	   END IF;
	 END IF;

	   IF lx_rt_cst_rejct_reason_tab.exists(1) THEN
             IF lx_rt_cst_rejct_reason_tab(1) IS NOT NULL THEN
		IF p_debug_mode = 'Y' THEN
		  pa_debug.write('PA_CC_TRANSFER_PRICE.Get_Initial_Transfer_Price', 'Raw Cost Reject:'||lx_rt_cst_rejct_reason_tab(1), 3);
                END IF;
	        ERROR_OCCURED := 'Y';
	     END IF;
 	   END IF;

	   IF lx_rt_bd_rejct_reason_tab.exists(1) THEN
              IF lx_rt_bd_rejct_reason_tab(1) IS NOT NULL THEN
		IF p_debug_mode = 'Y' THEN
		  pa_debug.write('PA_CC_TRANSFER_PRICE.Get_Initial_Transfer_Price', 'Burden Cost Reject:'||lx_rt_bd_rejct_reason_tab(1), 3);
                END IF;
         	ERROR_OCCURED := 'Y';
	   END IF;
	 END IF;

	   IF lx_rt_others_rejct_reason_tab.exists(1) THEN
	      IF lx_rt_others_rejct_reason_tab(1) IS NOT NULL THEN
		IF p_debug_mode = 'Y' THEN
		  pa_debug.write('PA_CC_TRANSFER_PRICE.Get_Initial_Transfer_Price', 'Other Reject:'||lx_rt_others_rejct_reason_tab(1), 3);
                END IF;
	        ERROR_OCCURED := 'Y';
	   END IF;
 	 END IF;

	 IF ERROR_OCCURED = 'Y' THEN
             IF p_debug_mode = 'Y' THEN
		pa_debug.write('PA_CC_TRANSFER_PRICE.Get_Initial_Transfer_Price', 'Some Error Occurred, Returning null as Rate', 3);
             END IF;
	     x_transfer_price_rate := NULL;
	     x_transfer_pr_rate_curr := NULL;
             x_return_status     :=  FND_API.G_RET_STS_SUCCESS;
	     Return;
	 END IF;

	 l_tp_asgid.delete;
         l_tp_exp_category.delete;
	 l_tp_labor_nl_flag.delete;
	 l_tp_taskid.delete;
	 l_tp_scheduleid.delete;
	 l_prj_curr_code_tab.delete;
	 l_prjfunc_curr_code_tab.delete;
	 l_tp_rev_distributed_flag.delete;
	 l_tp_compute_flag.delete;
	 l_tp_fixed_date.delete;
	 l_tp_quantity_tab.delete;
	 l_asg_fcst_jobid_tab.delete;
	 l_tp_nl_resource.delete;
	 l_tp_nl_resource_orgzid.delete;
  lx_proj_tp_rate_type.delete;
  lx_proj_tp_rate_date.delete;
  lx_proj_tp_exchange_rate.delete;
  lx_proj_tp_amt.delete;
  lx_projfunc_tp_rate_type.delete;
  lx_projfunc_tp_rate_date.delete;
  lx_projfunc_tp_exchange_rate.delete;
  lx_projfunc_tp_amt.delete;
  lx_denom_tp_currcode.delete;
  lx_denom_tp_amt.delete;
  lx_expfunc_tp_rate_type.delete;
  lx_expfunc_tp_rate_date.delete;
  lx_expfunc_tp_exchange_rate.delete;
  lx_expfunc_tp_amt.delete;
  lx_cc_markup_basecode.delete;
  lx_tp_ind_compiled_setid.delete;
  lx_tp_bill_rate.delete;
  lx_tp_base_amount.delete;
  lx_tp_bill_markup_percent.delete;
  lx_tp_sch_line_percent.delete;
  lx_tp_rule_percent.delete;
  lx_tp_job_id.delete;
  lx_tp_error_code.delete;

  lx_asg_precedes_task_tab.delete; -- Added for bug 3255061

         l_tp_asgid(1) := p_assignment_id;
         l_tp_exp_category(1) := l_cc_exp_category;
         l_tp_labor_nl_flag(1) := 'Y';
	 l_tp_taskid(1) := NULL;
	 l_tp_scheduleid(1) := l_labor_tp_schedule_id;
	 l_prj_curr_code_tab(1) := l_prj_curr_code;
	 l_prjfunc_curr_code_tab(1) :=  l_prjfunc_curr_code;
	 l_tp_rev_distributed_flag(1) := 'Y';
	 l_tp_compute_flag(1) := 'Y';
	 l_tp_fixed_date(1) := l_labor_tp_fixed_date;
	 l_tp_quantity_tab(1) := 1;
	 l_asg_fcst_jobid_tab(1) := l_asg_fcst_job_id;
	 l_tp_nl_resource(1) := NULL;
	 l_tp_nl_resource_orgzid(1) := NULL;
	 l_tp_debug_mode := p_debug_mode;
  lx_proj_tp_rate_type(1) := NULL;
  lx_proj_tp_rate_date(1) := NULL;
  lx_proj_tp_exchange_rate(1) := NULL;
  lx_proj_tp_amt(1) := NULL;
  lx_projfunc_tp_rate_type(1) := NULL;
  lx_projfunc_tp_rate_date(1) := NULL;
  lx_projfunc_tp_exchange_rate(1) := NULL;
  lx_projfunc_tp_amt(1) := NULL;
  lx_denom_tp_currcode(1) := NULL;
  lx_denom_tp_amt(1) := NULL;
  lx_expfunc_tp_rate_type(1) := NULL;
  lx_expfunc_tp_rate_date(1) := NULL;
  lx_expfunc_tp_exchange_rate(1) := NULL;
  lx_expfunc_tp_amt(1) := NULL;
  lx_cc_markup_basecode(1) := NULL;
  lx_tp_ind_compiled_setid(1) := NULL;
  lx_tp_bill_rate(1) := NULL;
  lx_tp_base_amount(1) := NULL;
  lx_tp_bill_markup_percent(1) := NULL;
  lx_tp_sch_line_percent(1) := NULL;
  lx_tp_rule_percent(1) := NULL;
  lx_tp_job_id(1) := NULL;
  lx_tp_error_code(1) := NULL;

  lx_asg_precedes_task_tab(1) := l_asg_precedes_task; -- Added for bug 3255061

IF p_debug_mode = 'Y' THEN
  pa_debug.write('PA_CC_TRANSFER_PRICE.Get_Initial_Transfer_Price', 'PA_CC_TRANSFER_PRICE.GET_TRANSFER_PRICE calling', 3);
END IF;

	PA_CC_TRANSFER_PRICE.GET_TRANSFER_PRICE(
	              			p_module_name             		=> 'FORECAST',
	           			p_prvdr_organization_id   		=> lx_cc_prvdr_orgzid_tab,
	              			p_recvr_org_id            		=> lx_cc_recvr_orgid_tab,
	              			p_recvr_organization_id   		=> lx_cc_recvr_orgzid_tab,
	             			p_expnd_organization_id   		=> l_fi_exp_organizationid_tab,
	              			p_expenditure_item_id     		=> l_fi_id_tab,
	              			p_expenditure_type       		=> l_fi_exptype_tab,
	              			p_expenditure_category   		=> l_tp_exp_category,
	              			p_expenditure_item_date   		=> l_fi_date_tab,
	              			p_labor_non_labor_flag    		=> l_tp_labor_nl_flag,
                                        p_system_linkage_function 		=> l_fi_exptypeclass_tab,
	             			p_task_id               		=> l_tp_taskid,
	             			p_tp_schedule_id          		=> l_tp_scheduleid,
	             			p_denom_currency_code     		=> lx_rt_cost_txn_curr_code_tab,
	              			p_project_currency_code   		=> l_prj_curr_code_tab,
	              			p_projfunc_currency_code  		=> l_prjfunc_curr_code_tab,
	            			p_revenue_distributed_flag		=> l_tp_rev_distributed_flag,
	              			p_processed_thru_date    	 	=> sysdate,
	              			p_compute_flag            		=> l_tp_compute_flag ,
	              			p_tp_fixed_date           		=> l_tp_fixed_date,
	              			p_denom_raw_cost_amount   		=> lx_rt_txn_raw_cost_tab,
	             			p_denom_burdened_cost_amount 	        => lx_rt_txn_bd_cost_tab,
					p_raw_revenue_amount         		=> lx_rt_pfunc_raw_revenue_tab,
					p_project_id                 		=> l_fi_projid_tab,
	              			p_quantity                   		=> l_tp_quantity_tab,
	              			p_incurred_by_person_id      		=> l_fi_personid_tab,
	              			p_job_id                    	 	=> l_asg_fcst_jobid_tab,
	              			p_non_labor_resource         		=> l_tp_nl_resource,
	              			p_nl_resource_organization_id		=> l_tp_nl_resource_orgzid,
	              			p_pa_date                    		=> l_tp_pa_date,
					p_array_size                 		=> 1,
	              			p_debug_mode                 		=> l_tp_debug_mode,
	              			p_tp_amt_type_code           		=> l_fi_amount_type_tab,
	              			p_assignment_id              		=> l_tp_asgid,
	              			p_prvdr_operating_unit    		=> lx_cc_prvdr_orgid_tab,
                                        p_assignment_precedes_task              => lx_asg_precedes_task_tab, -- Added for bug 3255061
	              			x_proj_tp_rate_type          		=> lx_proj_tp_rate_type,
	              			x_proj_tp_rate_date          		=> lx_proj_tp_rate_date,
	              			x_proj_tp_exchange_rate      		=> lx_proj_tp_exchange_rate,
	              			x_proj_transfer_price        		=> lx_proj_tp_amt,
	              			x_projfunc_tp_rate_type      		=> lx_projfunc_tp_rate_type,
	             			x_projfunc_tp_rate_date      		=> lx_projfunc_tp_rate_date,
	              			x_projfunc_tp_exchange_rate  		=> lx_projfunc_tp_exchange_rate,
	              			x_projfunc_transfer_price    		=> lx_projfunc_tp_amt,
	              			x_denom_tp_currency_code     		=> lx_denom_tp_currcode,
	              			x_denom_transfer_price       		=> lx_denom_tp_amt,
	             			x_acct_tp_rate_type          		=> lx_expfunc_tp_rate_type,
	             			x_acct_tp_rate_date          		=> lx_expfunc_tp_rate_date,
	              			x_acct_tp_exchange_rate      		=> lx_expfunc_tp_exchange_rate,
	             			x_acct_transfer_price        		=> lx_expfunc_tp_amt,
	              			x_cc_markup_base_code        		=> lx_cc_markup_basecode,
	             			x_tp_ind_compiled_set_id     		=> lx_tp_ind_compiled_setid,
	              			x_tp_bill_rate               		=> lx_tp_bill_rate,
	              			x_tp_base_amount             		=> lx_tp_base_amount,
	              			x_tp_bill_markup_percentage  		=> lx_tp_bill_markup_percent,
	              			x_tp_schedule_line_percentage		=> lx_tp_sch_line_percent,
	              			x_tp_rule_percentage         		=> lx_tp_rule_percent,
	             			x_tp_job_id                  		=> lx_tp_job_id,
	              			x_error_code                 		=> lx_tp_error_code,
	             			x_return_status              		=> lx_tp_return_status  );

IF p_debug_mode = 'Y' THEN
  pa_debug.write('PA_CC_TRANSFER_PRICE.Get_Initial_Transfer_Price', 'status is : '||lx_tp_return_status, 3);
  pa_debug.write('PA_CC_TRANSFER_PRICE.Get_Initial_Transfer_Price', 'rate is :'||x_transfer_price_rate||' curr :'||x_transfer_pr_rate_curr, 3);
END IF;

                            If lx_tp_return_status <> 0 THEN
			             x_transfer_price_rate := NULL;
				     x_transfer_pr_rate_curr := NULL;
                            ELSE
			    	     x_transfer_price_rate := lx_projfunc_tp_amt(1);
                                     IF x_transfer_price_rate IS NULL THEN
                                      x_transfer_pr_rate_curr:=NULL;
                                     ELSE
                                      x_transfer_pr_rate_curr := l_prjfunc_curr_code;
                                     END IF;
		            END IF;
  ELSE
     IF p_debug_mode = 'Y' THEN
        pa_debug.write('PA_CC_TRANSFER_PRICE.Get_Initial_Transfer_Price', 'Returning with Null as value', 3);
     END IF;
     x_transfer_price_rate := NULL;
     x_transfer_pr_rate_curr := NULL;
  END IF;

x_return_status     :=  FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   WHEN OTHERS THEN
       If p_debug_mode = 'Y' THEN
          pa_debug.write('PA_CC_TRANSFER_PRICE.GET_INITIAL_TRANSFER_PRICE', 'Unhandled Exception occured', 3);
       End if;
   /*Added for File.sql.39*/
   x_transfer_price_rate := NULL;
   x_transfer_pr_rate_curr := NULL;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Get_Initial_Transfer_Price;

END PA_CC_TRANSFER_PRICE;

/
