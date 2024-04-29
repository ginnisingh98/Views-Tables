--------------------------------------------------------
--  DDL for Package PA_FP_CALC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_CALC_UTILS" AUTHID CURRENT_USER AS
--$Header: PAFPCL1S.pls 120.7 2007/02/06 09:49:11 dthakker ship $


PROCEDURE populate_spreadCalc_Tmp (
                p_budget_version_id              IN  Number
		,p_budget_version_type           IN  Varchar2
		,p_calling_module                IN  Varchar2
                ,p_source_context                IN  Varchar2
                ,p_time_phased_code              IN  Varchar2
		,p_apply_progress_flag           IN  Varchar2 DEFAULT 'N'
                ,p_rollup_required_flag          IN  Varchar2 DEFAULT 'Y'
		,p_refresh_rates_flag            IN  Varchar2 DEFAULT 'N'
                ,p_refresh_conv_rates_flag       IN  Varchar2 DEFAULT 'N'
                ,p_mass_adjust_flag              IN  Varchar2 DEFAULT 'N'
		,p_time_phase_changed_flag   	 IN Varchar2 DEFAULT 'N'  /* Bug fix:4613444 */
		,p_wp_cost_changed_flag          IN Varchar2 DEFAULT 'N' /* Bug fix:5309529*/
                ,x_resource_assignment_tab       IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_delete_budget_lines_tab       IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_spread_amts_flag_tab          IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_txn_currency_code_tab         IN  OUT NOCOPY SYSTEM.pa_varchar2_15_tbl_type
                ,x_txn_currency_override_tab     IN  OUT NOCOPY SYSTEM.pa_varchar2_15_tbl_type
                ,x_total_qty_tab                 IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_addl_qty_tab                  IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_total_raw_cost_tab            IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_addl_raw_cost_tab             IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_total_burdened_cost_tab       IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_addl_burdened_cost_tab        IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_total_revenue_tab             IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_addl_revenue_tab              IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_raw_cost_rate_tab             IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_rw_cost_rate_override_tab     IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_b_cost_rate_tab               IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_b_cost_rate_override_tab      IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_bill_rate_tab                 IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_bill_rate_override_tab        IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_line_start_date_tab           IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_line_end_date_tab             IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_apply_progress_flag_tab       IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_spread_curve_id_old_tab       IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_spread_curve_id_new_tab       IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_sp_fixed_date_old_tab         IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_sp_fixed_date_new_tab         IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_plan_start_date_old_tab       IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_plan_start_date_new_tab       IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_plan_end_date_old_tab         IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_plan_end_date_new_tab         IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_re_spread_flag_tab            IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_sp_curve_change_flag_tab      IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_plan_dates_change_flag_tab    IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_spfix_date_flag_tab           IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_mfc_cost_change_flag_tab      IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_mfc_cost_type_id_old_tab      IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_mfc_cost_type_id_new_tab      IN  OUT NOCOPY SYSTEM.pa_num_tbl_type
                ,x_rlm_id_change_flag_tab        IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
		,x_plan_sdate_shrunk_flag_tab    IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_plan_edate_shrunk_flag_tab    IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_mfc_cost_refresh_flag_tab     IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
		,x_ra_in_multi_cur_flag_tab      IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
		,x_quantity_changed_flag_tab     IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_raw_cost_changed_flag_tab     IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_cost_rate_changed_flag_tab    IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_burden_cost_changed_flag_tab  IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_burden_rate_changed_flag_tab  IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_rev_changed_flag_tab          IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_bill_rate_changed_flag_tab    IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
		,x_multcur_plan_start_date_tab   IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
                ,x_multcur_plan_end_date_tab     IN  OUT NOCOPY SYSTEM.pa_date_tbl_type
	        ,x_fp_task_billable_flag_tab     IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
		/*5664280:mrup3 merge */
		,x_cost_rt_miss_num_flag_tab     IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_burd_rt_miss_num_flag_tab     IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_bill_rt_miss_num_flag_tab     IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_Qty_miss_num_flag_tab         IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_Rw_miss_num_flag_tab          IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_Br_miss_num_flag_tab          IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_Rv_miss_num_flag_tab          IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_rev_only_entry_flag_tab       IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
		/* bug fix:5726773 */
 	        ,x_neg_Qty_Changflag_tab         IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
 	        ,x_neg_Raw_Changflag_tab         IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
 	        ,x_neg_Burd_Changflag_tab        IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
 	        ,x_neg_rev_Changflag_tab         IN  OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type
                ,x_return_status                 OUT NOCOPY VARCHAR2
                ,x_msg_data                      OUT NOCOPY varchar2
                );

PROCEDURE cache_rates(
		p_budget_verson_id              IN  Number
		,p_apply_progress_flag          IN  Varchar2
                ,p_source_context                IN  pa_fp_res_assignments_tmp.source_context%TYPE
		,x_return_status                 OUT NOCOPY varchar2
		,x_msg_data                      OUT NOCOPY varchar2 ) ;

/* This API copies the override rates, currency conversion attributes, DFF attributes from cache to rollup tmp lines
 * so the after spread, the old values are retained
 */
PROCEDURE copy_BlAttributes(
                p_budget_verson_id               IN  Number
                ,p_source_context                IN  Varchar2
                ,p_calling_module                IN  Varchar2
                ,p_apply_progress_flag           IN Varchar2
                ,x_return_status                 OUT NOCOPY varchar2
                ,x_msg_data                      OUT NOCOPY varchar2
                 ) ;

/* Bug fix: 4184159 The following API will update the budget lines in bulk. This API uses oracle 9i feature of SQL%BULKEXCEPTION
 * during bulk update fails due to dup_val_on_index exception, the process the rejected rows.
 * Earlier the api was updating the budget line inside a loop for each row. this was causing the performance bottle neck
 */
PROCEDURE BLK_update_budget_lines
        (p_budget_version_id              IN  NUMBER
        ,p_calling_module                IN VARCHAR2 DEFAULT 'UPDATE_PLAN_TRANSACTION'-- Added for Bug#5395732
        ,x_return_status                 OUT NOCOPY VARCHAR2
        ,x_msg_count                     OUT NOCOPY NUMBER
        ,x_msg_data                      OUT NOCOPY VARCHAR2);

/* Throw an error If budget lines having zero qty and actuals, these lines corrupted budget lines
 * getting created through the AMG apis and budget generation process. Just abort the process
*/
PROCEDURE Check_ZeroQty_Bls
                ( p_budget_version_id  IN NUMBER
                 ,x_return_status    OUT NOCOPY VARCHAR2
                );

--Bug No.: 4224464. Added the signature for this procedure update_dffcols
PROCEDURE update_dffcols(
                p_budget_verson_id               IN  Number
                ,p_source_context                IN  Varchar2
                ,p_calling_module                IN  Varchar2
                ,p_apply_progress_flag           IN Varchar2
                ,x_return_status                 OUT NOCOPY varchar2
                ,x_msg_count                     OUT NOCOPY NUMBER
                ,x_msg_data                      OUT NOCOPY varchar2
                 ) ;

/*Bug:4272944: Added new procedure to insert zero qty budget lines from pa_fp_spread_calc_tmp1 to
*pa_budget_lines. This fix is done specific to Funding of Autobase line is failing.
*donot populate or use pa_fp_spread_calc_tmp1 table for any other purpose.
*Note: Calling API may populate this table only for AMG/MSP/Autobaseline purpose.
*/
PROCEDURE InsertFunding_ReqdLines
        ( p_budget_verson_id               IN  Number
         ,p_source_context                 IN  Varchar2
         ,p_calling_module                 IN  Varchar2
         ,p_apply_progress_flag            IN  Varchar2
         ,p_approved_rev_flag              IN  Varchar2
         ,p_autoBaseLine_flag              IN  Varchar2
         ,x_return_status                  OUT NOCOPY varchar2
         ) ;

END PA_FP_CALC_UTILS;

/
