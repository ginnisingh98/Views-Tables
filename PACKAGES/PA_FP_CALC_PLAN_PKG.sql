--------------------------------------------------------
--  DDL for Package PA_FP_CALC_PLAN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_CALC_PLAN_PKG" AUTHID CURRENT_USER AS
--$Header: PAFPCALS.pls 120.9.12010000.4 2009/06/15 10:17:17 gboomina ship $

-- Package level global variables
  g_spread_from_date   DATE;
 	G_populate_mrc_tab_flag         VARCHAR2(10) := 'N';

--For Bug 6722414
    g_from_etc_client_extn_flag     VARCHAR2(1);
-- Package variables for PJI reporting APIs
        /* global system tables declared for calling reporting api at the end */
        g_rep_budget_line_id_tab        SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        g_rep_res_assignment_id_tab     SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        g_rep_start_date_tab            SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
        g_rep_end_date_tab              SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
        g_rep_period_name_tab           SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
        g_rep_txn_curr_code_tab         SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();
        g_rep_quantity_tab              SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        g_rep_txn_raw_cost_tab          SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        g_rep_txn_burdened_cost_tab     SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        g_rep_txn_revenue_tab           SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        g_rep_project_curr_code_tab     SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();
        g_rep_project_raw_cost_tab      SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        g_rep_project_burden_cost_tab   SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        g_rep_project_revenue_tab       SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        g_rep_projfunc_curr_code_tab    SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();
        g_rep_projfunc_raw_cost_tab     SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        g_rep_projfunc_burden_cost_tab  SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
        g_rep_projfunc_revenue_tab      SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
	/*bug fix:5116157 */
	g_rep_line_mode_tab 		SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();
	g_rep_rate_base_flag_tab        SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();

/* Initialize reporting tbls */
PROCEDURE Init_reporting_Tbls ;

/* This API calls the PJI reporting procedures to rollup of the budget lines
 * to the task and project level
 */
PROCEDURE Add_Toreporting_Tabls
                (p_calling_module               IN      Varchar2 Default 'CALCULATE_API'
                ,p_activity_code                IN      Varchar2 Default 'UPDATE'
                ,p_budget_version_id            IN      Number
                ,p_budget_line_id               IN      Number
                ,p_resource_assignment_id       IN      Number
                ,p_start_date                   IN      Date
                ,p_end_date                     IN      Date
                ,p_period_name                  IN      Varchar2
                ,p_txn_currency_code            IN      Varchar2
                ,p_quantity                     IN      Number
                ,p_txn_raw_cost                 IN      Number
                ,p_txn_burdened_cost            IN      Number
                ,p_txn_revenue                  IN      Number
                ,p_project_currency_code        IN      Varchar2
                ,p_project_raw_cost             IN      Number
                ,p_project_burdened_cost        IN      Number
                ,p_project_revenue              IN      Number
                ,p_projfunc_currency_code       IN      Varchar2
                ,p_projfunc_raw_cost            IN      Number
                ,p_projfunc_burdened_cost       IN      Number
                ,p_projfunc_revenue             IN      Number
		,p_rep_line_mode                IN      Varchar2
                ,x_msg_data                     OUT NOCOPY Varchar2
                ,x_return_status                OUT NOCOPY Varchar2
                );

PROCEDURE delete_budget_lines (p_budget_version_id         IN  pa_budget_lines.budget_version_id%type
			       ,p_resource_assignment_id    IN  pa_resource_assignments.resource_assignment_id%TYPE
                               ,p_txn_currency_code         IN  pa_budget_lines.txn_currency_code%TYPE
                               ,p_line_start_date           IN  pa_budget_lines.start_date%TYPE
                               ,p_line_end_date             IN  pa_budget_lines.end_date%TYPE
			       ,p_source_context            IN  varchar2
                               ,x_return_status             OUT NOCOPY VARCHAR2
                               ,x_msg_count                 OUT NOCOPY NUMBER
                               ,x_msg_data                  OUT NOCOPY VARCHAR2
			       ,x_num_rowsdeleted           OUT NOCOPY NUMBER
                               );

PROCEDURE chk_req_rate_api_inputs (  p_budget_version_id             IN pa_budget_versions.budget_version_id%TYPE
                                    ,p_budget_version_type           IN pa_budget_versions.version_type%TYPE
                                    ,p_person_id                     IN pa_resource_assignments.person_id%TYPE
                                    ,p_job_id                        IN pa_resource_assignments.job_id%TYPE
                                    ,p_resource_class                IN pa_resource_assignments.resource_class_code%TYPE
                                    ,p_rate_based_flag               IN pa_resource_assignments.rate_based_flag%TYPE
                                    ,p_uom                           IN pa_resource_assignments.unit_of_measure%TYPE
                                    ,p_quantity                      IN pa_budget_lines.quantity%TYPE
                                    ,p_item_date                     IN pa_budget_lines.start_date%TYPE
                                    ,p_non_labor_resource            IN pa_resource_assignments.non_labor_resource%TYPE
                                    ,p_expenditure_org_id            IN pa_resource_assignments.rate_expenditure_org_id%TYPE
                                    ,p_nlr_organization_id           IN pa_resource_assignments.organization_id%TYPE
                                    ,p_cost_override_rate            IN pa_fp_res_assignments_tmp.rw_cost_rate_override%TYPE
                                    ,p_revenue_override_rate         IN pa_fp_res_assignments_tmp.bill_rate_override%TYPE
                                    ,p_raw_cost                      IN pa_fp_res_assignments_tmp.txn_raw_cost%TYPE
                                    ,p_burden_cost                   IN pa_fp_res_assignments_tmp.txn_burdened_cost%TYPE
                                    ,p_raw_revenue                   IN pa_fp_res_assignments_tmp.txn_revenue%TYPE
                                    ,p_override_currency_code        IN pa_fp_res_assignments_tmp.txn_currency_code%TYPE
                                    ,x_return_status                 OUT NOCOPY VARCHAR2
                                    ,x_msg_count                     OUT NOCOPY NUMBER
                                    ,x_msg_data                      OUT NOCOPY VARCHAR2
                                    );


PROCEDURE populate_rollup_tmp (  p_budget_version_id            IN NUMBER
                               ,x_return_status                 OUT NOCOPY VARCHAR2
                               ,x_msg_count                     OUT NOCOPY NUMBER
                               ,x_msg_data                      OUT NOCOPY VARCHAR2);

-- gboomina for AAI Requirement - Start
-- Modifying this procedure to take calling mode as a parameter
-- so that this api can be called from Collect actuals flow
PROCEDURE rollup_pf_pfc_to_ra ( p_budget_version_id             IN NUMBER
                               ,p_calling_module                IN VARCHAR2 DEFAULT 'CALCULATE_API'
                               ,x_return_status                 OUT NOCOPY VARCHAR2
                               ,x_msg_count                     OUT NOCOPY NUMBER
                               ,x_msg_data                      OUT NOCOPY VARCHAR2);
 -- gboomina for AAI Requirement - End

PROCEDURE rollup_pf_pfc_to_bv ( p_budget_version_id             IN  pa_budget_versions.budget_version_id%TYPE
                               ,x_return_status                 OUT NOCOPY VARCHAR2
                               ,x_msg_count                     OUT NOCOPY NUMBER
                               ,x_msg_data                      OUT NOCOPY VARCHAR2);

PROCEDURE convert_ra_txn_currency
            ( p_budget_version_id         IN pa_budget_versions.budget_version_id%TYPE
             ,p_resource_assignment_id    IN pa_resource_assignments.resource_assignment_id%TYPE
             ,p_txn_currency_code         IN pa_budget_lines.txn_currency_code%TYPE
             ,p_budget_line_id            IN pa_budget_lines.budget_line_id%TYPE
             ,p_txn_raw_cost              IN pa_fp_rollup_tmp.txn_raw_cost%TYPE
             ,p_txn_burdened_cost         IN pa_fp_rollup_tmp.txn_burdened_cost%TYPE
             ,p_txn_revenue               IN pa_fp_rollup_tmp.txn_revenue%TYPE
             ,x_projfunc_currency_code    OUT NOCOPY pa_fp_rollup_tmp.projfunc_currency_code%TYPE
             ,x_projfunc_raw_cost         OUT NOCOPY pa_fp_rollup_tmp.projfunc_raw_cost%TYPE
             ,x_projfunc_burdened_cost    OUT NOCOPY pa_fp_rollup_tmp.projfunc_burdened_cost%TYPE
             ,x_projfunc_revenue          OUT NOCOPY pa_fp_rollup_tmp.projfunc_revenue%TYPE
             ,x_projfunc_rejection_code   OUT NOCOPY pa_fp_rollup_tmp.pfc_cur_conv_rejection_code%TYPE
             ,x_project_currency_code     OUT NOCOPY pa_fp_rollup_tmp.project_currency_code%TYPE
             ,x_project_raw_cost          OUT NOCOPY pa_fp_rollup_tmp.project_raw_cost%TYPE
             ,x_project_burdened_cost     OUT NOCOPY pa_fp_rollup_tmp.project_burdened_cost%TYPE
             ,x_project_revenue           OUT NOCOPY pa_fp_rollup_tmp.project_revenue%TYPE
             ,x_project_rejection_code    OUT NOCOPY pa_fp_rollup_tmp.pc_cur_conv_rejection_code%TYPE
             ,x_return_status             OUT NOCOPY VARCHAR2
             ,x_msg_count                 OUT NOCOPY NUMBER
             ,x_msg_data                  OUT NOCOPY VARCHAR2);


PROCEDURE calculate (  p_project_id                    IN  pa_projects_all.project_id%TYPE
                      ,p_budget_version_id             IN  pa_budget_versions.budget_version_id%TYPE
                      ,p_refresh_rates_flag            IN  VARCHAR2 := 'N'
                      ,p_refresh_conv_rates_flag       IN  VARCHAR2 := 'N'
                      ,p_spread_required_flag          IN  VARCHAR2 := 'Y'
                      ,p_conv_rates_required_flag      IN  VARCHAR2 := 'Y'
                      ,p_rollup_required_flag          IN  VARCHAR2 := 'Y'
                      ,p_mass_adjust_flag              IN  VARCHAR2 := 'N'
		      ,p_apply_progress_flag           IN  VARCHAR2 := 'N'
		      ,p_wp_cost_changed_flag          IN  VARCHAR2 := 'N'
                      ,p_time_phase_changed_flag       IN  VARCHAR2 := 'N'
                      ,p_quantity_adj_pct              IN  NUMBER   := NULL
                      ,p_cost_rate_adj_pct             IN  NUMBER   := NULL
                      ,p_burdened_rate_adj_pct         IN  NUMBER   := NULL
                      ,p_bill_rate_adj_pct             IN  NUMBER   := NULL
		      ,p_raw_cost_adj_pct              IN  NUMBER   := NULL
		      ,p_burden_cost_adj_pct           IN  NUMBER   := NULL
		      ,p_revenue_adj_pct               IN  NUMBER   := NULL
                      ,p_source_context                IN  pa_fp_res_assignments_tmp.source_context%TYPE
		      ,p_calling_module		       IN  VARCHAR2  DEFAULT   'UPDATE_PLAN_TRANSACTION'
		      ,p_activity_code		       IN  VARCHAR2  DEFAULT   'CALCULATE'
                      ,p_resource_assignment_tab       IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_delete_budget_lines_tab       IN  SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type()
                      ,p_spread_amts_flag_tab          IN  SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type()
                      ,p_txn_currency_code_tab         IN  SYSTEM.pa_varchar2_15_tbl_type    DEFAULT SYSTEM.pa_varchar2_15_tbl_type()
                      ,p_txn_currency_override_tab     IN  SYSTEM.pa_varchar2_15_tbl_type    DEFAULT SYSTEM.pa_varchar2_15_tbl_type()
                      ,p_total_qty_tab                 IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_addl_qty_tab                  IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_total_raw_cost_tab            IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_addl_raw_cost_tab             IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_total_burdened_cost_tab       IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_addl_burdened_cost_tab        IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_total_revenue_tab             IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_addl_revenue_tab              IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_raw_cost_rate_tab             IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_rw_cost_rate_override_tab     IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_b_cost_rate_tab               IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_b_cost_rate_override_tab      IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_bill_rate_tab                 IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_bill_rate_override_tab        IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_line_start_date_tab           IN  SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type()
                      ,p_line_end_date_tab             IN  SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type()
		      ,p_mfc_cost_type_id_old_tab      IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_mfc_cost_type_id_new_tab      IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_spread_curve_id_old_tab       IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_spread_curve_id_new_tab       IN  SYSTEM.pa_num_tbl_type            DEFAULT SYSTEM.pa_num_tbl_type()
                      ,p_sp_fixed_date_old_tab         IN  SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type()
                      ,p_sp_fixed_date_new_tab         IN  SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type()
                      ,p_plan_start_date_old_tab       IN  SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type()
                      ,p_plan_start_date_new_tab       IN  SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type()
                      ,p_plan_end_date_old_tab         IN  SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type()
                      ,p_plan_end_date_new_tab         IN  SYSTEM.pa_date_tbl_type           DEFAULT SYSTEM.pa_date_tbl_type()
                      ,p_re_spread_flag_tab            IN  SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type()
                      ,p_rlm_id_change_flag_tab        IN  SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type()
                      ,p_del_spread_calc_tmp1_flg      IN VARCHAR2 := 'Y' /* Bug: 4309290.Added the parameter to identify if
                                                                         PA_FP_SPREAD_CALC_TMP1 table      */
		      ,p_fp_task_billable_flag_tab     IN  SYSTEM.pa_varchar2_1_tbl_type     DEFAULT SYSTEM.pa_varchar2_1_tbl_type() /* default 'D' */
		      ,p_clientExtn_api_call_flag      IN  VARCHAR2 DEFAULT 'Y'
		      ,p_raTxn_rollup_api_call_flag    IN  VARCHAR2 DEFAULT 'Y' /* Bug fix:4900436 */
                      ,x_return_status                 OUT NOCOPY VARCHAR2
                      ,x_msg_count                     OUT NOCOPY NUMBER
                      ,x_msg_data                      OUT VARCHAR2);

/* Compare the In params value with the existsing budget line values
* and populate the changed flags. Based on these flag apply the
* precedence and set the addl variables to pass it to spread api
*/
PROCEDURE Compare_With_BdgtLine_Values
         (p_resource_ass_id    IN Number
         ,p_txn_currency_code  IN Varchar2
         ,p_line_start_date    IN Date
         ,p_line_end_date      IN Date
	 ,p_bdgt_version_type  IN Varchar2
         ,p_rate_based_flag    IN Varchar2
	 ,p_apply_progress_flag IN Varchar2
	 ,p_resAttribute_changed_flag IN Varchar2
	/* Bug fix:4263265 Added these param to avoid deriving rate overrides */
         ,p_qty_changed_flag            IN Varchar2
         ,p_raw_cost_changed_flag       IN Varchar2
         ,p_rw_cost_rate_changed_flag   IN Varchar2
         ,p_burden_cost_changed_flag    IN Varchar2
         ,p_b_cost_rate_changed_flag    IN Varchar2
         ,p_rev_changed_flag            IN Varchar2
         ,p_bill_rate_changed_flag      IN Varchar2
	 ,p_revenue_only_entry_flag  IN Varchar2
	/* end of bug fix 4263265 */
         ,p_txn_currency_code_ovr IN OUT NOCOPY Varchar2
         ,p_txn_plan_quantity     IN OUT NOCOPY Number
         ,p_txn_raw_cost          IN OUT NOCOPY Number
         ,p_txn_raw_cost_rate     IN OUT NOCOPY Number
         ,p_txn_rw_cost_rate_override IN OUT NOCOPY Number
         ,p_txn_burdened_cost         IN OUT NOCOPY Number
         ,p_txn_b_cost_rate           IN OUT NOCOPY Number
         ,p_txn_b_cost_rate_override  IN OUT NOCOPY Number
         ,p_txn_revenue                 IN OUT NOCOPY Number
         ,p_txn_bill_rate               IN OUT NOCOPY Number
         ,p_txn_bill_rate_override      IN OUT NOCOPY Number
         ,x_qty_changed_flag            OUT NOCOPY Varchar2
         ,x_raw_cost_changed_flag       OUT NOCOPY Varchar2
         ,x_rw_cost_rate_changed_flag   OUT NOCOPY Varchar2
         ,x_burden_cost_changed_flag    OUT NOCOPY Varchar2
         ,x_b_cost_rate_changed_flag    OUT NOCOPY Varchar2
         ,x_rev_changed_flag            OUT NOCOPY Varchar2
         ,x_bill_rate_changed_flag      OUT NOCOPY Varchar2
         ,x_bill_rt_ovr_changed_flag    OUT NOCOPY Varchar2
         ,x_txn_revenue_addl            OUT NOCOPY Number
         ,x_txn_raw_cost_addl           OUT NOCOPY Number
         ,x_txn_plan_quantity_addl      OUT NOCOPY Number
         ,x_txn_burdened_cost_addl      OUT NOCOPY Number
         ,x_init_raw_cost               OUT NOCOPY Number
         ,x_init_burdened_cost          OUT NOCOPY Number
         ,x_init_revenue                OUT NOCOPY Number
         ,x_init_quantity               OUT NOCOPY Number
         ,x_bl_raw_cost                 OUT NOCOPY Number
         ,x_bl_burdened_cost            OUT NOCOPY Number
         ,x_bl_revenue                 	OUT NOCOPY Number
         ,x_bl_quantity       		OUT NOCOPY Number
         );


/* This API calls the main wrapper RATE api and converts the amounts from txn to txn currency if
 * cost rate and revenue rate currencies are different
 * Note: Before calling this API, pa_fp_rollup_tmp should be populated
 */
PROCEDURE Get_Res_RATEs
        (p_calling_module	   IN varchar2
	,p_activity_code	   IN varchar2
        ,p_budget_version_id       IN Number
        ,p_mass_adjust_flag        IN varchar2
	,p_apply_progress_flag     IN varchar2  DEFAULT 'N'
        ,p_precedence_progress_flag IN varchar2  DEFAULT 'N'
        ,x_return_status           OUT NOCOPY varchar2
        ,x_msg_data                OUT NOCOPY varchar2
        ,x_msg_count               OUT NOCOPY Number
        );

/* This API will apply the precedence rules on Rate Based planning transactions */
PROCEDURE Apply_NON_RATE_BASE_precedence(
	p_txn_currency_code		IN Varchar2
        ,p_rate_based_flag               IN Varchar2
        ,p_budget_version_type          IN Varchar2
        ,p_qty_changed_flag             IN Varchar2
        ,p_raw_cost_changed_flag        IN Varchar2
        ,p_rw_cost_rate_changed_flag    IN Varchar2
        ,p_burden_cost_changed_flag     IN Varchar2
        ,p_b_cost_rate_changed_flag     IN Varchar2
        ,p_rev_changed_flag             IN Varchar2
        ,p_bill_rate_changed_flag       IN Varchar2
        ,p_bill_rt_ovr_changed_flag     IN Varchar2
        ,p_init_raw_cost                IN Number
        ,p_init_burdened_cost           IN Number
        ,p_init_revenue                 IN Number
        ,p_init_quantity                IN Number
        ,p_bl_raw_cost                  IN Number
        ,p_bl_burdened_cost             IN Number
        ,p_bl_revenue                   IN Number
        ,p_bl_quantity                  IN Number
	,p_curr_cost_rate               IN Number
        ,p_curr_burden_rate             IN Number
        ,p_curr_bill_rate               IN Number
	,p_revenue_only_entry_flag      IN Varchar2
        ,x_txn_plan_quantity            IN OUT NOCOPY Number
        ,x_txn_raw_cost                 IN OUT NOCOPY Number
        ,x_txn_raw_cost_rate            IN OUT NOCOPY Number
        ,x_txn_rw_cost_rate_override    IN OUT NOCOPY Number
        ,x_txn_burdened_cost            IN OUT NOCOPY Number
        ,x_txn_b_cost_rate              IN OUT NOCOPY Number
        ,x_txn_b_cost_rate_override     IN OUT NOCOPY Number
        ,x_txn_revenue                  IN OUT NOCOPY Number
        ,x_txn_bill_rate                IN OUT NOCOPY Number
        ,x_txn_bill_rate_override       IN OUT NOCOPY Number
        ,x_txn_revenue_addl             IN OUT NOCOPY Number
        ,x_txn_raw_cost_addl            IN OUT NOCOPY Number
        ,x_txn_plan_quantity_addl       IN OUT NOCOPY Number
        ,x_txn_burdened_cost_addl       IN OUT NOCOPY Number
        );

/* This API will apply the precedence rules on Rate Based planning transactions */
PROCEDURE Apply_RATE_BASE_precedence(
	p_txn_currency_code		IN Varchar2
        ,p_rate_based_flag               IN Varchar2
        ,p_budget_version_type          IN Varchar2
        ,p_qty_changed_flag             IN Varchar2
        ,p_raw_cost_changed_flag        IN Varchar2
        ,p_rw_cost_rate_changed_flag    IN Varchar2
        ,p_burden_cost_changed_flag     IN Varchar2
        ,p_b_cost_rate_changed_flag     IN Varchar2
        ,p_rev_changed_flag             IN Varchar2
        ,p_bill_rate_changed_flag       IN Varchar2
        ,p_bill_rt_ovr_changed_flag     IN Varchar2
        ,p_init_raw_cost                IN Number
        ,p_init_burdened_cost           IN Number
        ,p_init_revenue                 IN Number
        ,p_init_quantity                IN Number
        ,p_bl_raw_cost                  IN Number
        ,p_bl_burdened_cost             IN Number
        ,p_bl_revenue                   IN Number
        ,p_bl_quantity                  IN Number
	,p_curr_cost_rate               IN Number
        ,p_curr_burden_rate             IN Number
        ,p_curr_bill_rate               IN Number
        ,x_txn_plan_quantity            IN OUT NOCOPY Number
        ,x_txn_raw_cost                 IN OUT NOCOPY Number
        ,x_txn_raw_cost_rate            IN OUT NOCOPY Number
        ,x_txn_rw_cost_rate_override    IN OUT NOCOPY Number
        ,x_txn_burdened_cost            IN OUT NOCOPY Number
        ,x_txn_b_cost_rate              IN OUT NOCOPY Number
        ,x_txn_b_cost_rate_override     IN OUT NOCOPY Number
        ,x_txn_revenue                  IN OUT NOCOPY Number
        ,x_txn_bill_rate                IN OUT NOCOPY Number
        ,x_txn_bill_rate_override       IN OUT NOCOPY Number
        ,x_txn_revenue_addl             IN OUT NOCOPY Number
        ,x_txn_raw_cost_addl            IN OUT NOCOPY Number
        ,x_txn_plan_quantity_addl       IN OUT NOCOPY Number
        ,x_txn_burdened_cost_addl       IN OUT NOCOPY Number
        );


/* This API rounds off the amounts to currency precision level and the last budget line of resoruce per currency will be
 * updated with the rounding discrepancy amounts
 */
PROCEDURE Update_rounding_diff(
                p_project_id                     IN  pa_budget_versions.project_id%type
                ,p_budget_version_id              IN  pa_budget_versions.budget_version_id%TYPE
                ,p_calling_module                IN  VARCHAR2 DEFAULT NULL
                ,p_source_context                IN  pa_fp_res_assignments_tmp.source_context%TYPE
                ,p_wp_cost_enabled_flag          IN  varchar2
                ,p_budget_version_type           IN  varchar2
                ,x_return_status                 OUT NOCOPY VARCHAR2
                ,x_msg_count                     OUT NOCOPY NUMBER
                ,x_msg_data                      OUT NOCOPY VARCHAR2) ;

/* This API initializes the global variables  for the given budget version Id */
PROCEDURE Init_Globals(
                p_budget_version_id  IN NUMBER
		,p_source_context    IN  VARCHAR2
                ,x_return_status     OUT NOCOPY VARCHAR2
                );

/* Bug 5726773 : CheckZeroQTyNegETC API is obsoleted : remove the API from package spec to avoid confusion of making calls
 * this API
 * Bug fix:4395494: added the following API CheckZeroQTyNegETC  in spec so that it can be used in Change order flows
 * Bug fix: 4387004:  This API is added for checking -ve ETC quantity / zero planned quantity
 * with non-zero actual quantity for planning resource and txn currency combination
 *
 * Bug 4290043.Included parameters so as to pass the amounts/actuals as pl-sql tbls input.
 * The pl-sql tbls are assumed to be ordered by resource assignment id and each record in the pl-sql
 * tbl corresponds to a record in pa_budget_lines.p_calling_context can be GLB_TBL (Global Temp Table)
 * or PLS_TBL(Pl-Sql tbl)
 */

/* ERs: MRC Enhancements:This API builds plsql table of records required for MRC conversions
 */
PROCEDURE Populate_MRC_plsqlTabs
                (p_calling_module               IN      Varchar2 Default 'CALCULATE_API'
                ,p_budget_version_id            IN      Number
                ,p_budget_line_id               IN      Number
                ,p_resource_assignment_id       IN      Number
                ,p_start_date                   IN      Date
                ,p_end_date                     IN      Date
                ,p_period_name                  IN      Varchar2 Default NULL
                ,p_txn_currency_code            IN      Varchar2
                ,p_quantity                     IN      Number   Default NULL
                ,p_txn_raw_cost                 IN      Number   Default NULL
                ,p_txn_burdened_cost            IN      Number   Default NULL
                ,p_txn_revenue                  IN      Number   Default NULL
                ,p_project_currency_code        IN      Varchar2 Default NULL
                ,p_project_raw_cost             IN      Number   Default NULL
                ,p_project_burdened_cost        IN      Number   Default NULL
                ,p_project_revenue              IN      Number   Default NULL
                ,p_projfunc_currency_code       IN      Varchar2 Default NULL
                ,p_projfunc_raw_cost            IN      Number   Default NULL
                ,p_projfunc_burdened_cost       IN      Number   Default NULL
                ,p_projfunc_revenue             IN      Number   Default NULL
                ,p_delete_flag                  IN      Varchar2 := 'N'
                ,p_billable_flag                IN      Varchar2 := 'Y'
                ,p_project_cost_rate_type       IN      Varchar2 default NULL
                ,p_project_cost_exchange_rate   IN      Number   default NULL
                ,p_project_cost_rate_date_type  IN      Varchar2 default NULL
                ,p_project_cost_rate_date       IN      Date     default NULL
                ,p_project_rev_rate_type        IN      Varchar2 default NULL
                ,p_project_rev_exchange_rate    IN      Number   default NULL
                ,p_project_rev_rate_date_type   IN      Varchar2 default NULL
                ,p_project_rev_rate_date        IN      Date     default NULL
                ,p_projfunc_cost_rate_type      IN      Varchar2 default NULL
                ,p_projfunc_cost_exchange_rate  IN      Number   default NULL
                ,p_projfunc_cost_rate_date_type IN      Varchar2 default NULL
                ,p_projfunc_cost_rate_date      IN      Date     default NULL
                ,p_projfunc_rev_rate_type       IN      Varchar2 default NULL
                ,p_projfunc_rev_exchange_rate   IN      Number   default NULL
                ,p_projfunc_rev_rate_date_type  IN      Varchar2 default NULL
                ,p_projfunc_rev_rate_date       IN      Date     default NULL
                ,x_msg_data                     OUT NOCOPY Varchar2
                ,x_return_status                OUT NOCOPY Varchar2
                );

PROCEDURE Init_MRC_plsqlTabs;

PROCEDURE SetGatherTmpTblIndxStats
        (p_table_name    IN VARCHAR2
        ,p_numRow    IN NUMBER
        ,x_return_status OUT NOCOPY VARCHAR2 );

/* Added for bug 5028631 */
PROCEDURE Process_skipped_records
        ( p_budget_version_id              IN  NUMBER
        ,p_calling_mode                    IN  VARCHAR2
        ,p_source_context                  IN  VARCHAR2
        ,x_return_status                 OUT NOCOPY VARCHAR2
        ,x_msg_count                     OUT NOCOPY NUMBER
        ,x_msg_data                      OUT NOCOPY VARCHAR2);

END PA_FP_CALC_PLAN_PKG;

/
