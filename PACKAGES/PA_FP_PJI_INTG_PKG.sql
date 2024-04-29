--------------------------------------------------------
--  DDL for Package PA_FP_PJI_INTG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_PJI_INTG_PKG" AUTHID CURRENT_USER AS
--$Header: PAFPUT4S.pls 120.3 2007/02/06 10:15:03 dthakker ship $

/* This is the main api called from calculate, budget generation process to update the
 * reporting PJI data when budget lines are created,updated or deleted.
 * The following params values must be passed
 * p_activity_code             'UPDATE',/'DELETE'
 * p_calling_module            name of API, for calculate 'CALCULATE_API'
 * p_start_date                BudgetLine StartDate
 * p_end_date                  BudgetLine Enddate
 * If activity = 'UPDATE' then all the amounts and currency columns must be passed
 * if activity = 'DELETE' then -ve budgetLine amounts will be selected from DB and passed in params will be ignored
 * NOTE: BEFORE CALLING THIS API, a record must exists in pa_resource_assignments for the p_resource_assignment_id
 *       AND CALL THIS API ONLY IF THERE ARE NO REJECTION CODES STAMPED ON THE BUDGET LINES
 */
PROCEDURE update_reporting_lines
		(p_calling_module               IN      Varchar2 Default 'CALCULATE_API'
		,p_activity_code                IN      Varchar2 Default 'UPDATE'
		,p_budget_version_id 		IN 	Number
		,p_budget_line_id		IN	Number
		,p_resource_assignment_id       IN 	Number
		,p_start_date			IN 	Date
		,p_end_date			IN 	Date
		,p_period_name                  IN      Varchar2
		,p_txn_currency_code            IN      Varchar2
                ,p_quantity           		IN 	Number
		,p_txn_raw_cost       		IN      Number
                ,p_txn_burdened_cost  		IN      Number
                ,p_txn_revenue        		IN      Number
		,p_project_currency_code        IN      Varchar2
                ,p_project_raw_cost       	IN      Number
                ,p_project_burdened_cost  	IN      Number
                ,p_project_revenue        	IN      Number
		,p_projfunc_currency_code       IN      Varchar2
                ,p_projfunc_raw_cost      	IN      Number
                ,p_projfunc_burdened_cost 	IN      Number
                ,p_projfunc_revenue       	IN      Number
                ,x_msg_data           		OUT NOCOPY Varchar2
		,x_msg_count			OUT NOCOPY Number
                ,x_return_status     		OUT NOCOPY Varchar2
		) ;

/* THIS API IS CREATED FOR BULK PROCESS OF DATA.
 * NOTE: ALL PARAMS MUST BE PASSED , passing Null or incomplete params will error out
 * the calling API must initialize all params and pass it
 */
PROCEDURE blk_update_reporting_lines
	(p_calling_module                IN Varchar2 Default 'CALCULATE_API'
        ,p_activity_code                 IN Varchar2 Default 'UPDATE'
        ,p_budget_version_id             IN Number
	,p_rep_budget_line_id_tab        IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_res_assignment_id_tab     IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_start_date_tab            IN SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type()
        ,p_rep_end_date_tab              IN SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type()
        ,p_rep_period_name_tab           IN SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type()
        ,p_rep_txn_curr_code_tab         IN SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type()
        ,p_rep_quantity_tab              IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_txn_raw_cost_tab          IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_txn_burdened_cost_tab     IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_txn_revenue_tab           IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_project_curr_code_tab     IN SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type()
        ,p_rep_project_raw_cost_tab      IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_project_burden_cost_tab   IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_project_revenue_tab       IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_projfunc_curr_code_tab    IN SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type()
        ,p_rep_projfunc_raw_cost_tab     IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_projfunc_burden_cost_tab  IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_projfunc_revenue_tab      IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_act_quantity_tab             IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_txn_act_raw_cost_tab         IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_txn_act_burd_cost_tab        IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_txn_act_rev_tab              IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_prj_act_raw_cost_tab     IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_prj_act_burd_cost_tab    IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_prj_act_rev_tab          IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_pf_act_raw_cost_tab    IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_pf_act_burd_cost_tab   IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
        ,p_rep_pf_act_rev_tab         IN SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type()
	/* bug fix:5116157 */
	,p_rep_line_mode_tab          IN SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type()
	,p_rep_rate_base_flag_tab     IN SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type()
	,x_msg_data                     OUT NOCOPY Varchar2
        ,x_msg_count                    OUT NOCOPY Number
        ,x_return_status                OUT NOCOPY Varchar2
	) ;

/* This is an wrapper api, which in turn calls update_reporting_lines and passes
 * each budget line to reporting api
 *This is the main api called from calculate, budget generation process to update the
 * reporting PJI data when budget lines are created,updated or deleted.
 * The following params values must be passed
 * p_activity_code             'UPDATE',/'DELETE'
 * p_calling_module            name of API, for ex: 'CALCULATE_API'
 * If activity = 'UPDATE' then +ve budgetLine amounts will be selected from DB
 * if activity = 'DELETE' then -ve budgetLine amounts will be selected from DB
 * NOTE: BEFORE CALLING THIS API, a record must exists in pa_resource_assignments for the p_resource_assignment_id
 *       AND a budget line must exists in pa_budget_lines for the given p_budget_line_id .
 */
PROCEDURE update_reporting_lines_frombl
                (p_calling_module               IN      Varchar2 Default 'CALCULATE_API'
                ,p_activity_code                IN      Varchar2 Default 'UPDATE'
                ,p_budget_version_id            IN      Number
                ,p_resource_assignment_id       IN      Number
                ,p_budget_line_id               IN      Number
                ,x_msg_data                     OUT NOCOPY Varchar2
                ,x_msg_count                    OUT NOCOPY Number
                ,x_return_status                OUT NOCOPY Varchar2
                ) ;

END PA_FP_PJI_INTG_PKG;

/
