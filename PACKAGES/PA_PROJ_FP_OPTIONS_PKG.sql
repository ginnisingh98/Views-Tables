--------------------------------------------------------
--  DDL for Package PA_PROJ_FP_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJ_FP_OPTIONS_PKG" AUTHID CURRENT_USER as
/* $Header: PAFPPOTS.pls 120.3.12010000.2 2009/05/25 14:57:43 gboomina ship $ */
-- Start of Comments
-- Package name     : PA_PROJ_FP_OPTIONS_PKG
-- Purpose          :
-- History          :
-- 15-May-2002 Vejayara Added parameters for columns factor_by_code
--                      and plan_in_multi_curr_flag
-- 14-Aug-2002 Vejayara Added parameters for financial planning in all
--                      procedures
-- 23-Apr-2003 Rravipat Bug 2920954 Added parameters to insert_row and
--                      update_row  apis for new coulmns:
--                        select_cost_res_auto_flag
--                        cost_res_planning_level
--                        select_rev_res_auto_flag
--                        revenue_res_planning_level
--                        select_all_res_auto_flag
--                        all_res_planning_level
--
--   26-JUN-2003 jwhite        - Plannable Task Dev Effort:
--                               For the Insert_Row procedure, add the
--                               following IN-parameters:
--                               1) p_refresh_required_flag
--	                         2) p_request_id
--	                         3) p_processing_code

--   r11.5 FP.M Developement ----------------------------------
--
--   08-JAN-2004 jwhite     - Bug 3362316
--                            Extensively rewrote
--                            1) Insert_Row
--                            2) Update_Row
--
--                            Please Note:
--                            Some of the table column names
--                            are 30-charaters long. So, they
--                            must be abbreviated to include the
--                            "p_" prefix (PLS-00114).
--
--     'P_COST_NON_LABOR_RES_RATE_SCH_ID' -> P_CST_NON_LABR_RES_RATE_SCH_ID
--     'P_REV_NON_LABOR_RES_RATE_SCH_ID'  -> P_REV_NON_LABR_RES_RATE_SCH_ID
--     'P_ALL_NON_LABOR_RES_RATE_SCH_ID'  -> P_ALL_NON_LABR_RES_RATE_SCH_ID
--     'P_GEN_COST_INCL_CHANGE_DOC_FLAG'  -> P_GN_COST_INCL_CHANGE_DOC_FLAG
--     'P_GEN_COST_RET_MANUAL_LINE_FLAG'  -> P_GN_COST_RET_MANUAL_LINE_FLAG
--     'P_GEN_COST_INCL_UNSPENT_AMT_FLAG' -> P_GN_CST_INCL_UNSPENT_AMT_FLAG
--     'P_GEN_REV_INCL_UNSPENT_AMT_FLAG'  -> P_GN_REV_INCL_UNSPENT_AMT_FLAG
--     'P_GEN_ALL_INCL_UNSPENT_AMT_FLAG'  -> P_GN_ALL_INCL_UNSPENT_AMT_FLAG
--     'P_GEN_COST_ACTUAL_AMTS_THRU_CODE' -> P_GN_CST_ACTUAL_AMTS_THRU_CODE
--     'P_GEN_REV_ACTUAL_AMTS_THRU_CODE'  -> P_GN_REV_ACTUAL_AMTS_THRU_CODE
--     'P_GEN_ALL_ACTUAL_AMTS_THRU_CODE'  -> P_GN_ALL_ACTUAL_AMTS_THRU_CODE
--

--   26-jan-2004 rravipat   - Bug 3354518 (IDC)
--                            Included new column track_workplan_costs_flag
--                            in the apis insert_row and update_row

--   27-jan-2004 rravipat   - Bug 3354518 (IDC)
--                            Removed referenced to column RES_CLASS_BURDEN_SCH_ID
--                            in apis insert_row and update_row as this
--                            column has been removed.

--   20-MAR-2004 rravipat  - Bug 3519062
--                           Impact of new columns to pa_proj_fp_options
--                           New columns have been included to hold workplan
--                           version details if workplan is the source of
--                           generation

--  23-APR-2004 rravipat   - Bug 3580727
--                           The following column should be dropped
--                           ALL_EMP_RATE_SCH_ID
--                           ALL_JOB_RATE_SCH_ID
--                           ALL_NON_LABOR_RES_RATE_SCH_ID
--                           ALL_RES_CLASS_RATE_SCH_ID
--                           ALL_BURDEN_RATE_SCH_ID
--                           GEN_REV_INCL_UNSPENT_AMT_FLAG
--  01-SEP-2004 nkumbi     - Bug 5462471
--                           Included parameter revenue_derivation_method in Insert_Row, update_row


-- NOTE             :
-- End of Comments




PROCEDURE Insert_Row
( px_proj_fp_options_id
    IN OUT NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE  --File.Sql.39 bug 4440895
 ,p_project_id
    IN pa_proj_fp_options.project_id%TYPE := FND_API.G_MISS_NUM
 ,p_fin_plan_option_level_code
    IN pa_proj_fp_options.fin_plan_option_level_code%TYPE := FND_API.G_MISS_CHAR
 ,p_fin_plan_type_id
    IN pa_proj_fp_options.fin_plan_type_id%TYPE := FND_API.G_MISS_NUM
 ,p_fin_plan_start_date
    IN pa_proj_fp_options.fin_plan_start_date%TYPE := FND_API.G_MISS_DATE
 ,p_fin_plan_end_date
    IN pa_proj_fp_options.fin_plan_end_date%TYPE := FND_API.G_MISS_DATE
 ,p_fin_plan_preference_code
    IN pa_proj_fp_options.fin_plan_preference_code%TYPE := FND_API.G_MISS_CHAR
 ,p_cost_amount_set_id
    IN pa_proj_fp_options.cost_amount_set_id%TYPE := FND_API.G_MISS_NUM
 ,p_revenue_amount_set_id
    IN pa_proj_fp_options.revenue_amount_set_id%TYPE := FND_API.G_MISS_NUM
 ,p_all_amount_set_id
    IN pa_proj_fp_options.all_amount_set_id%TYPE := FND_API.G_MISS_NUM
 ,p_cost_fin_plan_level_code
    IN pa_proj_fp_options.cost_fin_plan_level_code%TYPE := FND_API.G_MISS_CHAR
 ,p_cost_time_phased_code
    IN pa_proj_fp_options.cost_time_phased_code%TYPE := FND_API.G_MISS_CHAR
 ,p_cost_resource_list_id
    IN pa_proj_fp_options.cost_resource_list_id%TYPE := FND_API.G_MISS_NUM
 ,p_revenue_fin_plan_level_code
    IN pa_proj_fp_options.revenue_fin_plan_level_code%TYPE := FND_API.G_MISS_CHAR
 ,p_revenue_time_phased_code
    IN pa_proj_fp_options.revenue_time_phased_code%TYPE := FND_API.G_MISS_CHAR
 ,p_revenue_resource_list_id
    IN pa_proj_fp_options.revenue_resource_list_id%TYPE := FND_API.G_MISS_NUM
 ,p_all_fin_plan_level_code
    IN pa_proj_fp_options.all_fin_plan_level_code%TYPE := FND_API.G_MISS_CHAR
 ,p_all_time_phased_code
    IN pa_proj_fp_options.all_time_phased_code%TYPE := FND_API.G_MISS_CHAR
 ,p_all_resource_list_id
    IN pa_proj_fp_options.all_resource_list_id%TYPE := FND_API.G_MISS_NUM
 ,p_report_labor_hrs_from_code
    IN pa_proj_fp_options.report_labor_hrs_from_code%TYPE := FND_API.G_MISS_CHAR
 ,p_fin_plan_version_id
    IN pa_proj_fp_options.fin_plan_version_id%TYPE := FND_API.G_MISS_NUM
/* added for financial planning */
 ,p_plan_in_multi_curr_flag
    IN pa_proj_fp_options.plan_in_multi_curr_flag%TYPE      := FND_API.G_MISS_CHAR
 ,p_factor_by_code
    IN pa_proj_fp_options.factor_by_code%TYPE               := FND_API.G_MISS_CHAR
 ,p_default_amount_type_code
    IN pa_proj_fp_options.default_amount_type_code%TYPE     := FND_API.G_MISS_CHAR
 ,p_default_amount_subtype_code
    IN pa_proj_fp_options.default_amount_subtype_code%TYPE  := FND_API.G_MISS_CHAR
 ,p_approved_cost_plan_type_flag
    IN pa_proj_fp_options.approved_cost_plan_type_flag%TYPE := FND_API.G_MISS_CHAR
 ,p_approved_rev_plan_type_flag
    IN pa_proj_fp_options.approved_rev_plan_type_flag%TYPE  := FND_API.G_MISS_CHAR
 ,p_projfunc_cost_rate_type
    IN pa_proj_fp_options.projfunc_cost_rate_type%TYPE      := FND_API.G_MISS_CHAR
 ,p_projfunc_cost_rate_date_type
    IN pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE := FND_API.G_MISS_CHAR
 ,p_projfunc_cost_rate_date
    IN pa_proj_fp_options.projfunc_cost_rate_date%TYPE      := FND_API.G_MISS_DATE
 ,p_projfunc_rev_rate_type
    IN pa_proj_fp_options.projfunc_rev_rate_type%TYPE       := FND_API.G_MISS_CHAR
 ,p_projfunc_rev_rate_date_type
    IN pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE  := FND_API.G_MISS_CHAR
 ,p_projfunc_rev_rate_date
    IN pa_proj_fp_options.projfunc_rev_rate_date%TYPE       := FND_API.G_MISS_DATE
 ,p_project_cost_rate_type
    IN pa_proj_fp_options.project_cost_rate_type%TYPE       := FND_API.G_MISS_CHAR
 ,p_project_cost_rate_date_type
    IN pa_proj_fp_options.project_cost_rate_date_type%TYPE  := FND_API.G_MISS_CHAR
 ,p_project_cost_rate_date
    IN pa_proj_fp_options.project_cost_rate_date%TYPE       := FND_API.G_MISS_DATE
 ,p_project_rev_rate_type
    IN pa_proj_fp_options.project_rev_rate_type%TYPE        := FND_API.G_MISS_CHAR
 ,p_project_rev_rate_date_type
    IN pa_proj_fp_options.project_rev_rate_date_type%TYPE   := FND_API.G_MISS_CHAR
 ,p_project_rev_rate_date
    IN pa_proj_fp_options.project_rev_rate_date%TYPE        := FND_API.G_MISS_DATE
 ,p_margin_derived_from_code
    IN pa_proj_fp_options.margin_derived_from_code%TYPE     := FND_API.G_MISS_CHAR
/* ended additions for fin plan */
/* Bug 2920954 start of additional parameters for post FP-k one off */
 ,p_select_cost_res_auto_flag
     IN pa_proj_fp_options.select_cost_res_auto_flag%TYPE   := FND_API.G_MISS_CHAR
 ,p_cost_res_planning_level
     IN pa_proj_fp_options.cost_res_planning_level%TYPE     := FND_API.G_MISS_CHAR
 ,p_select_rev_res_auto_flag
     IN pa_proj_fp_options.select_rev_res_auto_flag%TYPE    := FND_API.G_MISS_CHAR
 ,p_revenue_res_planning_level
     IN pa_proj_fp_options.revenue_res_planning_level%TYPE  := FND_API.G_MISS_CHAR
 ,p_select_all_res_auto_flag
     IN pa_proj_fp_options.select_all_res_auto_flag%TYPE    := FND_API.G_MISS_CHAR
 ,p_all_res_planning_level
     IN pa_proj_fp_options.all_res_planning_level%TYPE      := FND_API.G_MISS_CHAR
 ,p_refresh_required_flag
     IN pa_budget_versions.PROCESS_UPDATE_WBS_FLAG%TYPE     := FND_API.G_MISS_CHAR
 ,p_request_id
     IN pa_budget_versions.REQUEST_ID%TYPE                  := FND_API.G_MISS_NUM
 ,p_processing_code
     IN pa_budget_versions.PLAN_PROCESSING_CODE%TYPE        := FND_API.G_MISS_CHAR
/* Bug 2920954 end of additional parameters for post FP-k one off */
 ,p_primary_cost_forecast_flag
     IN PA_PROJ_FP_OPTIONS.primary_cost_forecast_flag%TYPE  := FND_API.G_MISS_CHAR
 ,p_primary_rev_forecast_flag
     IN PA_PROJ_FP_OPTIONS.primary_rev_forecast_flag%TYPE   := FND_API.G_MISS_CHAR
 ,p_use_planning_rates_flag
     IN PA_PROJ_FP_OPTIONS.use_planning_rates_flag%TYPE     := FND_API.G_MISS_CHAR
 ,p_rbs_version_id
     IN PA_PROJ_FP_OPTIONS.rbs_version_id%TYPE              := FND_API.G_MISS_NUM
 ,p_res_class_raw_cost_sch_id
     IN PA_PROJ_FP_OPTIONS.res_class_raw_cost_sch_id%TYPE   := FND_API.G_MISS_NUM
 ,p_res_class_bill_rate_sch_id
     IN PA_PROJ_FP_OPTIONS.res_class_bill_rate_sch_id%TYPE  := FND_API.G_MISS_NUM
 ,p_cost_emp_rate_sch_id
     IN PA_PROJ_FP_OPTIONS.cost_emp_rate_sch_id%TYPE        := FND_API.G_MISS_NUM
 ,p_cost_job_rate_sch_id
     IN PA_PROJ_FP_OPTIONS.cost_job_rate_sch_id%TYPE        := FND_API.G_MISS_NUM
 ,p_cst_non_labr_res_rate_sch_id
     IN PA_PROJ_FP_OPTIONS.cost_non_labor_res_rate_sch_id%TYPE := FND_API.G_MISS_NUM
 ,p_cost_res_class_rate_sch_id
     IN PA_PROJ_FP_OPTIONS.cost_res_class_rate_sch_id%TYPE  := FND_API.G_MISS_NUM
 ,p_cost_burden_rate_sch_id
     IN PA_PROJ_FP_OPTIONS.cost_burden_rate_sch_id%TYPE     := FND_API.G_MISS_NUM
 ,p_cost_current_planning_period
     IN PA_PROJ_FP_OPTIONS.cost_current_planning_period%TYPE := FND_API.G_MISS_CHAR
 ,p_cost_period_mask_id
     IN PA_PROJ_FP_OPTIONS.cost_period_mask_id%TYPE := FND_API.G_MISS_NUM
 ,p_rev_emp_rate_sch_id
     IN PA_PROJ_FP_OPTIONS.rev_emp_rate_sch_id%TYPE := FND_API.G_MISS_NUM
 ,p_rev_job_rate_sch_id
     IN PA_PROJ_FP_OPTIONS.rev_job_rate_sch_id%TYPE := FND_API.G_MISS_NUM
 ,p_rev_non_labr_res_rate_sch_id
     IN PA_PROJ_FP_OPTIONS.rev_non_labor_res_rate_sch_id%TYPE := FND_API.G_MISS_NUM
 ,p_rev_res_class_rate_sch_id
     IN PA_PROJ_FP_OPTIONS.rev_res_class_rate_sch_id%TYPE := FND_API.G_MISS_NUM
 ,p_rev_current_planning_period
     IN PA_PROJ_FP_OPTIONS.rev_current_planning_period%TYPE := FND_API.G_MISS_CHAR
 ,p_rev_period_mask_id
     IN PA_PROJ_FP_OPTIONS.rev_period_mask_id%TYPE  := FND_API.G_MISS_NUM
 /** Bug 3580727 Columns have been dropped
     ,p_all_emp_rate_sch_id
         IN PA_PROJ_FP_OPTIONS.all_emp_rate_sch_id%TYPE := FND_API.G_MISS_NUM
     ,p_all_job_rate_sch_id
         IN PA_PROJ_FP_OPTIONS.all_job_rate_sch_id%TYPE := FND_API.G_MISS_NUM
     ,p_all_non_labr_res_rate_sch_id
         IN PA_PROJ_FP_OPTIONS.all_non_labor_res_rate_sch_id%TYPE := FND_API.G_MISS_NUM
     ,p_all_res_class_rate_sch_id
         IN PA_PROJ_FP_OPTIONS.all_res_class_rate_sch_id%TYPE := FND_API.G_MISS_NUM
     ,p_all_burden_rate_sch_id
         IN PA_PROJ_FP_OPTIONS.all_burden_rate_sch_id%TYPE := FND_API.G_MISS_NUM
 **/
 ,p_all_current_planning_period
     IN PA_PROJ_FP_OPTIONS.all_current_planning_period%TYPE := FND_API.G_MISS_CHAR
 ,p_all_period_mask_id
     IN PA_PROJ_FP_OPTIONS.all_period_mask_id%TYPE := FND_API.G_MISS_NUM
 ,p_gen_cost_src_code
     IN PA_PROJ_FP_OPTIONS.gen_cost_src_code%TYPE := FND_API.G_MISS_CHAR
 ,p_gen_cost_etc_src_code
     IN PA_PROJ_FP_OPTIONS.gen_cost_etc_src_code%TYPE := FND_API.G_MISS_CHAR
 ,p_gn_cost_incl_change_doc_flag
     IN PA_PROJ_FP_OPTIONS.gen_cost_incl_change_doc_flag%TYPE := FND_API.G_MISS_CHAR
 ,p_gen_cost_incl_open_comm_flag
     IN PA_PROJ_FP_OPTIONS.gen_cost_incl_open_comm_flag%TYPE := FND_API.G_MISS_CHAR
 ,p_gn_cost_ret_manual_line_flag
     IN PA_PROJ_FP_OPTIONS.gen_cost_ret_manual_line_flag%TYPE := FND_API.G_MISS_CHAR
 ,p_gn_cst_incl_unspent_amt_flag
     IN PA_PROJ_FP_OPTIONS.gen_cost_incl_unspent_amt_flag%TYPE  := FND_API.G_MISS_CHAR
 ,p_gen_rev_src_code
     IN PA_PROJ_FP_OPTIONS.gen_rev_src_code%TYPE := FND_API.G_MISS_CHAR
 ,p_gen_rev_etc_src_code
     IN PA_PROJ_FP_OPTIONS.gen_rev_etc_src_code%TYPE := FND_API.G_MISS_CHAR
 ,p_gen_rev_incl_change_doc_flag
     IN PA_PROJ_FP_OPTIONS.gen_rev_incl_change_doc_flag%TYPE := FND_API.G_MISS_CHAR
 ,p_gen_rev_incl_bill_event_flag
     IN PA_PROJ_FP_OPTIONS.gen_rev_incl_bill_event_flag%TYPE := FND_API.G_MISS_CHAR
 ,p_gen_rev_ret_manual_line_flag
     IN PA_PROJ_FP_OPTIONS.gen_rev_ret_manual_line_flag%TYPE  := FND_API.G_MISS_CHAR
/** Bug 3580727 this column has been dropped
     ,p_gn_rev_incl_unspent_amt_flag
         IN PA_PROJ_FP_OPTIONS.gen_rev_incl_unspent_amt_flag%TYPE := FND_API.G_MISS_CHAR
**/
 ,p_gen_src_cost_plan_type_id
     IN PA_PROJ_FP_OPTIONS.gen_src_cost_plan_type_id%TYPE := FND_API.G_MISS_NUM
 ,p_gen_src_cost_plan_version_id
     IN PA_PROJ_FP_OPTIONS.gen_src_cost_plan_version_id%TYPE := FND_API.G_MISS_NUM
 ,p_gen_src_cost_plan_ver_code
     IN PA_PROJ_FP_OPTIONS.gen_src_cost_plan_ver_code%TYPE := FND_API.G_MISS_CHAR
 ,p_gen_src_rev_plan_type_id
     IN PA_PROJ_FP_OPTIONS.gen_src_rev_plan_type_id%TYPE := FND_API.G_MISS_NUM
 ,p_gen_src_rev_plan_version_id
     IN PA_PROJ_FP_OPTIONS.gen_src_rev_plan_version_id%TYPE := FND_API.G_MISS_NUM
 ,p_gen_src_rev_plan_ver_code
     IN PA_PROJ_FP_OPTIONS.gen_src_rev_plan_ver_code%TYPE := FND_API.G_MISS_CHAR
 ,p_gen_src_all_plan_type_id
     IN PA_PROJ_FP_OPTIONS.gen_src_all_plan_type_id%TYPE := FND_API.G_MISS_NUM
 ,p_gen_src_all_plan_version_id
     IN PA_PROJ_FP_OPTIONS.gen_src_all_plan_version_id%TYPE := FND_API.G_MISS_NUM
 ,p_gen_src_all_plan_ver_code
     IN PA_PROJ_FP_OPTIONS.gen_src_all_plan_ver_code%TYPE := FND_API.G_MISS_CHAR
 ,p_gen_all_src_code
     IN PA_PROJ_FP_OPTIONS.gen_all_src_code%TYPE := FND_API.G_MISS_CHAR
 ,p_gen_all_etc_src_code
     IN PA_PROJ_FP_OPTIONS.gen_all_etc_src_code%TYPE := FND_API.G_MISS_CHAR
 ,p_gen_all_incl_change_doc_flag
     IN PA_PROJ_FP_OPTIONS.gen_all_incl_change_doc_flag%TYPE := FND_API.G_MISS_CHAR
 ,p_gen_all_incl_open_comm_flag
     IN PA_PROJ_FP_OPTIONS.gen_all_incl_open_comm_flag%TYPE := FND_API.G_MISS_CHAR
 ,p_gen_all_ret_manual_line_flag
     IN PA_PROJ_FP_OPTIONS.gen_all_ret_manual_line_flag%TYPE := FND_API.G_MISS_CHAR
 ,p_gen_all_incl_bill_event_flag
     IN PA_PROJ_FP_OPTIONS.gen_all_incl_bill_event_flag%TYPE := FND_API.G_MISS_CHAR
 ,p_gn_all_incl_unspent_amt_flag
     IN PA_PROJ_FP_OPTIONS.gen_all_incl_unspent_amt_flag%TYPE := FND_API.G_MISS_CHAR
 ,p_gn_cst_actual_amts_thru_code
     IN PA_PROJ_FP_OPTIONS.gen_cost_actual_amts_thru_code%TYPE := FND_API.G_MISS_CHAR
 ,p_gn_rev_actual_amts_thru_code
     IN PA_PROJ_FP_OPTIONS.gen_rev_actual_amts_thru_code%TYPE := FND_API.G_MISS_CHAR
 ,p_gn_all_actual_amts_thru_code
     IN PA_PROJ_FP_OPTIONS.gen_all_actual_amts_thru_code%TYPE  := FND_API.G_MISS_CHAR
 ,p_track_workplan_costs_flag
     IN PA_PROJ_FP_OPTIONS.track_workplan_costs_flag%TYPE  := FND_API.G_MISS_CHAR
 -- bug 3519062 start of workplan gen source related columns
 ,p_gen_src_cost_wp_version_id
     IN PA_PROJ_FP_OPTIONS.gen_src_cost_wp_version_id%TYPE := FND_API.G_MISS_NUM
 ,p_gen_src_cost_wp_ver_code
     IN PA_PROJ_FP_OPTIONS.gen_src_cost_wp_ver_code%TYPE := FND_API.G_MISS_CHAR
 ,p_gen_src_rev_wp_version_id
     IN PA_PROJ_FP_OPTIONS.gen_src_rev_wp_version_id%TYPE := FND_API.G_MISS_NUM
 ,p_gen_src_rev_wp_ver_code
     IN PA_PROJ_FP_OPTIONS.gen_src_rev_wp_ver_code%TYPE := FND_API.G_MISS_CHAR
 ,p_gen_src_all_wp_version_id
     IN PA_PROJ_FP_OPTIONS.gen_src_all_wp_version_id%TYPE := FND_API.G_MISS_NUM
 ,p_gen_src_all_wp_ver_code
     IN PA_PROJ_FP_OPTIONS.gen_src_all_wp_ver_code%TYPE := FND_API.G_MISS_CHAR
 -- bug 3519062 end of workplan gen source related columns

 --Added for webAdi changes for the amount types to be displayed
 ,p_cost_layout_code
     IN PA_PROJ_FP_OPTIONS.cost_layout_code%TYPE := FND_API.G_MISS_CHAR
 ,p_revenue_layout_code
     IN PA_PROJ_FP_OPTIONS.revenue_layout_code%TYPE := FND_API.G_MISS_CHAR
 ,p_all_layout_code
     IN PA_PROJ_FP_OPTIONS.all_layout_code%TYPE := FND_API.G_MISS_CHAR
,p_revenue_derivation_method
        IN PA_PROJ_FP_OPTIONS.revenue_derivation_method%TYPE := FND_API.G_MISS_CHAR -- Bug 5462471
 , p_copy_etc_from_plan_flag
        IN PA_PROJ_FP_OPTIONS.copy_etc_from_plan_flag%TYPE := FND_API.G_MISS_CHAR  --bug 8318932
  ,x_row_id                        OUT NOCOPY ROWID --File.Sql.39 bug 4440895
 ,x_return_status                 OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Update_Row
( p_proj_fp_options_id
    IN pa_proj_fp_options.proj_fp_options_id%TYPE := FND_API.G_MISS_NUM
 ,p_record_version_number
    IN NUMBER                                     := NULL
 ,p_project_id
    IN pa_proj_fp_options.project_id%TYPE := FND_API.G_MISS_NUM
 ,p_fin_plan_option_level_code
    IN pa_proj_fp_options.fin_plan_option_level_code%TYPE := FND_API.G_MISS_CHAR
 ,p_fin_plan_type_id
    IN pa_proj_fp_options.fin_plan_type_id%TYPE := FND_API.G_MISS_NUM
 ,p_fin_plan_start_date
    IN pa_proj_fp_options.fin_plan_start_date%TYPE := FND_API.G_MISS_DATE
 ,p_fin_plan_end_date
    IN pa_proj_fp_options.fin_plan_end_date%TYPE := FND_API.G_MISS_DATE
 ,p_fin_plan_preference_code
    IN pa_proj_fp_options.fin_plan_preference_code%TYPE := FND_API.G_MISS_CHAR
 ,p_cost_amount_set_id
    IN pa_proj_fp_options.cost_amount_set_id%TYPE := FND_API.G_MISS_NUM
 ,p_revenue_amount_set_id
    IN pa_proj_fp_options.revenue_amount_set_id%TYPE := FND_API.G_MISS_NUM
 ,p_all_amount_set_id
    IN pa_proj_fp_options.all_amount_set_id%TYPE := FND_API.G_MISS_NUM
 ,p_cost_fin_plan_level_code
    IN pa_proj_fp_options.cost_fin_plan_level_code%TYPE := FND_API.G_MISS_CHAR
 ,p_cost_time_phased_code
    IN pa_proj_fp_options.cost_time_phased_code%TYPE := FND_API.G_MISS_CHAR
 ,p_cost_resource_list_id
    IN pa_proj_fp_options.cost_resource_list_id%TYPE := FND_API.G_MISS_NUM
 ,p_revenue_fin_plan_level_code
    IN pa_proj_fp_options.revenue_fin_plan_level_code%TYPE := FND_API.G_MISS_CHAR
 ,p_revenue_time_phased_code
    IN pa_proj_fp_options.revenue_time_phased_code%TYPE := FND_API.G_MISS_CHAR
 ,p_revenue_resource_list_id
    IN pa_proj_fp_options.revenue_resource_list_id%TYPE := FND_API.G_MISS_NUM
 ,p_all_fin_plan_level_code
    IN pa_proj_fp_options.all_fin_plan_level_code%TYPE := FND_API.G_MISS_CHAR
 ,p_all_time_phased_code
    IN pa_proj_fp_options.all_time_phased_code%TYPE := FND_API.G_MISS_CHAR
 ,p_all_resource_list_id
    IN pa_proj_fp_options.all_resource_list_id%TYPE := FND_API.G_MISS_NUM
 ,p_report_labor_hrs_from_code
    IN pa_proj_fp_options.report_labor_hrs_from_code%TYPE := FND_API.G_MISS_CHAR
 ,p_fin_plan_version_id
    IN pa_proj_fp_options.fin_plan_version_id%TYPE := FND_API.G_MISS_NUM
/* added for financial planning */
 ,p_plan_in_multi_curr_flag
    IN pa_proj_fp_options.plan_in_multi_curr_flag%TYPE      := FND_API.G_MISS_CHAR
 ,p_factor_by_code
    IN pa_proj_fp_options.factor_by_code%TYPE               := FND_API.G_MISS_CHAR
 ,p_default_amount_type_code
    IN pa_proj_fp_options.default_amount_type_code%TYPE     := FND_API.G_MISS_CHAR
 ,p_default_amount_subtype_code
    IN pa_proj_fp_options.default_amount_subtype_code%TYPE  := FND_API.G_MISS_CHAR
 ,p_approved_cost_plan_type_flag
    IN pa_proj_fp_options.approved_cost_plan_type_flag%TYPE := FND_API.G_MISS_CHAR
 ,p_approved_rev_plan_type_flag
    IN pa_proj_fp_options.approved_rev_plan_type_flag%TYPE  := FND_API.G_MISS_CHAR
 ,p_projfunc_cost_rate_type
    IN pa_proj_fp_options.projfunc_cost_rate_type%TYPE      := FND_API.G_MISS_CHAR
 ,p_projfunc_cost_rate_date_type
    IN pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE := FND_API.G_MISS_CHAR
 ,p_projfunc_cost_rate_date
    IN pa_proj_fp_options.projfunc_cost_rate_date%TYPE      := FND_API.G_MISS_DATE
 ,p_projfunc_rev_rate_type
    IN pa_proj_fp_options.projfunc_rev_rate_type%TYPE       := FND_API.G_MISS_CHAR
 ,p_projfunc_rev_rate_date_type
    IN pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE  := FND_API.G_MISS_CHAR
 ,p_projfunc_rev_rate_date
    IN pa_proj_fp_options.projfunc_rev_rate_date%TYPE       := FND_API.G_MISS_DATE
 ,p_project_cost_rate_type
    IN pa_proj_fp_options.project_cost_rate_type%TYPE       := FND_API.G_MISS_CHAR
 ,p_project_cost_rate_date_type
    IN pa_proj_fp_options.project_cost_rate_date_type%TYPE  := FND_API.G_MISS_CHAR
 ,p_project_cost_rate_date
    IN pa_proj_fp_options.project_cost_rate_date%TYPE       := FND_API.G_MISS_DATE
 ,p_project_rev_rate_type
    IN pa_proj_fp_options.project_rev_rate_type%TYPE        := FND_API.G_MISS_CHAR
 ,p_project_rev_rate_date_type
    IN pa_proj_fp_options.project_rev_rate_date_type%TYPE   := FND_API.G_MISS_CHAR
 ,p_project_rev_rate_date
    IN pa_proj_fp_options.project_rev_rate_date%TYPE        := FND_API.G_MISS_DATE
 ,p_margin_derived_from_code
    IN pa_proj_fp_options.margin_derived_from_code%TYPE     := FND_API.G_MISS_CHAR
/* ended additions for fin plan */
/* Bug 2920954 start of additional parameters for post FP-k one off */
 ,p_select_cost_res_auto_flag
     IN pa_proj_fp_options.select_cost_res_auto_flag%TYPE   := FND_API.G_MISS_CHAR
 ,p_cost_res_planning_level
     IN pa_proj_fp_options.cost_res_planning_level%TYPE     := FND_API.G_MISS_CHAR
 ,p_select_rev_res_auto_flag
     IN pa_proj_fp_options.select_rev_res_auto_flag%TYPE    := FND_API.G_MISS_CHAR
 ,p_revenue_res_planning_level
     IN pa_proj_fp_options.revenue_res_planning_level%TYPE  := FND_API.G_MISS_CHAR
 ,p_select_all_res_auto_flag
     IN pa_proj_fp_options.select_all_res_auto_flag%TYPE    := FND_API.G_MISS_CHAR
 ,p_all_res_planning_level
     IN pa_proj_fp_options.all_res_planning_level%TYPE      := FND_API.G_MISS_CHAR
/* Bug 2920954 end of additional parameters for post FP-k one off */
 ,p_primary_cost_forecast_flag
    IN PA_PROJ_FP_OPTIONS.primary_cost_forecast_flag%TYPE   := FND_API.G_MISS_CHAR
 ,p_primary_rev_forecast_flag
    IN PA_PROJ_FP_OPTIONS.primary_rev_forecast_flag%TYPE    := FND_API.G_MISS_CHAR
 ,p_use_planning_rates_flag
    IN PA_PROJ_FP_OPTIONS.use_planning_rates_flag%TYPE      := FND_API.G_MISS_CHAR
 ,p_rbs_version_id
    IN PA_PROJ_FP_OPTIONS.rbs_version_id%TYPE               := FND_API.G_MISS_NUM
 ,p_res_class_raw_cost_sch_id
    IN PA_PROJ_FP_OPTIONS.res_class_raw_cost_sch_id%TYPE    := FND_API.G_MISS_NUM
 ,p_res_class_bill_rate_sch_id
    IN PA_PROJ_FP_OPTIONS.res_class_bill_rate_sch_id%TYPE   := FND_API.G_MISS_NUM
 ,p_cost_emp_rate_sch_id
    IN PA_PROJ_FP_OPTIONS.cost_emp_rate_sch_id%TYPE         := FND_API.G_MISS_NUM
 ,p_cost_job_rate_sch_id
    IN PA_PROJ_FP_OPTIONS.cost_job_rate_sch_id%TYPE         := FND_API.G_MISS_NUM
 ,P_CST_NON_LABR_RES_RATE_SCH_ID
    IN PA_PROJ_FP_OPTIONS.cost_non_labor_res_rate_sch_id%TYPE := FND_API.G_MISS_NUM
 ,p_cost_res_class_rate_sch_id
    IN PA_PROJ_FP_OPTIONS.cost_res_class_rate_sch_id%TYPE   := FND_API.G_MISS_NUM
 ,p_cost_burden_rate_sch_id
    IN PA_PROJ_FP_OPTIONS.cost_burden_rate_sch_id%TYPE      := FND_API.G_MISS_NUM
 ,p_cost_current_planning_period
    IN PA_PROJ_FP_OPTIONS.cost_current_planning_period%TYPE := FND_API.G_MISS_CHAR
 ,p_cost_period_mask_id
    IN PA_PROJ_FP_OPTIONS.cost_period_mask_id%TYPE          := FND_API.G_MISS_NUM
 ,p_rev_emp_rate_sch_id
    IN PA_PROJ_FP_OPTIONS.rev_emp_rate_sch_id%TYPE          := FND_API.G_MISS_NUM
 ,p_rev_job_rate_sch_id
    IN PA_PROJ_FP_OPTIONS.rev_job_rate_sch_id%TYPE          := FND_API.G_MISS_NUM
 ,P_REV_NON_LABR_RES_RATE_SCH_ID
    IN PA_PROJ_FP_OPTIONS.rev_non_labor_res_rate_sch_id%TYPE := FND_API.G_MISS_NUM
 ,p_rev_res_class_rate_sch_id
    IN PA_PROJ_FP_OPTIONS.rev_res_class_rate_sch_id%TYPE    := FND_API.G_MISS_NUM
 ,p_rev_current_planning_period
    IN PA_PROJ_FP_OPTIONS.rev_current_planning_period%TYPE  := FND_API.G_MISS_CHAR
 ,p_rev_period_mask_id
    IN PA_PROJ_FP_OPTIONS.rev_period_mask_id%TYPE           := FND_API.G_MISS_NUM
 /** Bug 3580727 Columns have been dropped
     ,p_all_emp_rate_sch_id
        IN PA_PROJ_FP_OPTIONS.all_emp_rate_sch_id%TYPE          := FND_API.G_MISS_NUM
     ,p_all_job_rate_sch_id
        IN PA_PROJ_FP_OPTIONS.all_job_rate_sch_id%TYPE          := FND_API.G_MISS_NUM
     ,P_ALL_NON_LABR_RES_RATE_SCH_ID
        IN PA_PROJ_FP_OPTIONS.all_non_labor_res_rate_sch_id%TYPE := FND_API.G_MISS_NUM
     ,p_all_res_class_rate_sch_id
        IN PA_PROJ_FP_OPTIONS.all_res_class_rate_sch_id%TYPE    := FND_API.G_MISS_NUM
     ,p_all_burden_rate_sch_id
        IN PA_PROJ_FP_OPTIONS.all_burden_rate_sch_id%TYPE       := FND_API.G_MISS_NUM
 **/
 ,p_all_current_planning_period
    IN PA_PROJ_FP_OPTIONS.all_current_planning_period%TYPE  := FND_API.G_MISS_CHAR
 ,p_all_period_mask_id
    IN PA_PROJ_FP_OPTIONS.all_period_mask_id%TYPE           := FND_API.G_MISS_NUM
 ,p_gen_cost_src_code
    IN PA_PROJ_FP_OPTIONS.gen_cost_src_code%TYPE            := FND_API.G_MISS_CHAR
 ,p_gen_cost_etc_src_code
    IN PA_PROJ_FP_OPTIONS.gen_cost_etc_src_code%TYPE        := FND_API.G_MISS_CHAR
 ,P_GN_COST_INCL_CHANGE_DOC_FLAG
    IN PA_PROJ_FP_OPTIONS.gen_cost_incl_change_doc_flag%TYPE  := FND_API.G_MISS_CHAR
 ,p_gen_cost_incl_open_comm_flag
    IN PA_PROJ_FP_OPTIONS.gen_cost_incl_open_comm_flag%TYPE   := FND_API.G_MISS_CHAR
 ,P_GN_COST_RET_MANUAL_LINE_FLAG
    IN PA_PROJ_FP_OPTIONS.gen_cost_ret_manual_line_flag%TYPE  := FND_API.G_MISS_CHAR
 ,P_GN_CST_INCL_UNSPENT_AMT_FLAG
    IN PA_PROJ_FP_OPTIONS.gen_cost_incl_unspent_amt_flag%TYPE := FND_API.G_MISS_CHAR
 ,p_gen_rev_src_code
    IN PA_PROJ_FP_OPTIONS.gen_rev_src_code%TYPE             := FND_API.G_MISS_CHAR
 ,p_gen_rev_etc_src_code
    IN PA_PROJ_FP_OPTIONS.gen_rev_etc_src_code%TYPE         := FND_API.G_MISS_CHAR
 ,p_gen_rev_incl_change_doc_flag
    IN PA_PROJ_FP_OPTIONS.gen_rev_incl_change_doc_flag%TYPE := FND_API.G_MISS_CHAR
 ,p_gen_rev_incl_bill_event_flag
    IN PA_PROJ_FP_OPTIONS.gen_rev_incl_bill_event_flag%TYPE := FND_API.G_MISS_CHAR
 ,p_gen_rev_ret_manual_line_flag
    IN PA_PROJ_FP_OPTIONS.gen_rev_ret_manual_line_flag%TYPE := FND_API.G_MISS_CHAR
 /** Bug 3580727 this column has been dropped
     ,P_GN_REV_INCL_UNSPENT_AMT_FLAG
        IN PA_PROJ_FP_OPTIONS.gen_rev_incl_unspent_amt_flag%TYPE := FND_API.G_MISS_CHAR
 **/
 ,p_gen_src_cost_plan_type_id
    IN PA_PROJ_FP_OPTIONS.gen_src_cost_plan_type_id%TYPE    := FND_API.G_MISS_NUM
 ,p_gen_src_cost_plan_version_id
    IN PA_PROJ_FP_OPTIONS.gen_src_cost_plan_version_id%TYPE := FND_API.G_MISS_NUM
 ,p_gen_src_cost_plan_ver_code
    IN PA_PROJ_FP_OPTIONS.gen_src_cost_plan_ver_code%TYPE   := FND_API.G_MISS_CHAR
 ,p_gen_src_rev_plan_type_id
    IN PA_PROJ_FP_OPTIONS.gen_src_rev_plan_type_id%TYPE     := FND_API.G_MISS_NUM
 ,p_gen_src_rev_plan_version_id
    IN PA_PROJ_FP_OPTIONS.gen_src_rev_plan_version_id%TYPE  := FND_API.G_MISS_NUM
 ,p_gen_src_rev_plan_ver_code
    IN PA_PROJ_FP_OPTIONS.gen_src_rev_plan_ver_code%TYPE    := FND_API.G_MISS_CHAR
 ,p_gen_src_all_plan_type_id
    IN PA_PROJ_FP_OPTIONS.gen_src_all_plan_type_id%TYPE     := FND_API.G_MISS_NUM
 ,p_gen_src_all_plan_version_id
    IN PA_PROJ_FP_OPTIONS.gen_src_all_plan_version_id%TYPE  := FND_API.G_MISS_NUM
 ,p_gen_src_all_plan_ver_code
    IN PA_PROJ_FP_OPTIONS.gen_src_all_plan_ver_code%TYPE    := FND_API.G_MISS_CHAR
 ,p_gen_all_src_code
    IN PA_PROJ_FP_OPTIONS.gen_all_src_code%TYPE             := FND_API.G_MISS_CHAR
 ,p_gen_all_etc_src_code
    IN PA_PROJ_FP_OPTIONS.gen_all_etc_src_code%TYPE         := FND_API.G_MISS_CHAR
 ,p_gen_all_incl_change_doc_flag
    IN PA_PROJ_FP_OPTIONS.gen_all_incl_change_doc_flag%TYPE := FND_API.G_MISS_CHAR
 ,p_gen_all_incl_open_comm_flag
    IN PA_PROJ_FP_OPTIONS.gen_all_incl_open_comm_flag%TYPE  := FND_API.G_MISS_CHAR
 ,p_gen_all_ret_manual_line_flag
    IN PA_PROJ_FP_OPTIONS.gen_all_ret_manual_line_flag%TYPE := FND_API.G_MISS_CHAR
 ,p_gen_all_incl_bill_event_flag
    IN PA_PROJ_FP_OPTIONS.gen_all_incl_bill_event_flag%TYPE := FND_API.G_MISS_CHAR
 ,P_GN_ALL_INCL_UNSPENT_AMT_FLAG
    IN PA_PROJ_FP_OPTIONS.gen_all_incl_unspent_amt_flag%TYPE := FND_API.G_MISS_CHAR
 ,P_GN_CST_ACTUAL_AMTS_THRU_CODE
    IN PA_PROJ_FP_OPTIONS.gen_cost_actual_amts_thru_code%TYPE := FND_API.G_MISS_CHAR
 ,P_GN_REV_ACTUAL_AMTS_THRU_CODE
    IN PA_PROJ_FP_OPTIONS.gen_rev_actual_amts_thru_code%TYPE  := FND_API.G_MISS_CHAR
 ,P_GN_ALL_ACTUAL_AMTS_THRU_CODE
    IN PA_PROJ_FP_OPTIONS.gen_all_actual_amts_thru_code%TYPE  := FND_API.G_MISS_CHAR
 ,p_track_workplan_costs_flag
     IN PA_PROJ_FP_OPTIONS.track_workplan_costs_flag%TYPE     := FND_API.G_MISS_CHAR
 -- bug 3519062 start of workplan gen source related columns
 ,p_gen_src_cost_wp_version_id
     IN PA_PROJ_FP_OPTIONS.gen_src_cost_wp_version_id%TYPE := FND_API.G_MISS_NUM
 ,p_gen_src_cost_wp_ver_code
     IN PA_PROJ_FP_OPTIONS.gen_src_cost_wp_ver_code%TYPE := FND_API.G_MISS_CHAR
 ,p_gen_src_rev_wp_version_id
     IN PA_PROJ_FP_OPTIONS.gen_src_rev_wp_version_id%TYPE := FND_API.G_MISS_NUM
 ,p_gen_src_rev_wp_ver_code
     IN PA_PROJ_FP_OPTIONS.gen_src_rev_wp_ver_code%TYPE := FND_API.G_MISS_CHAR
 ,p_gen_src_all_wp_version_id
     IN PA_PROJ_FP_OPTIONS.gen_src_all_wp_version_id%TYPE := FND_API.G_MISS_NUM
 ,p_gen_src_all_wp_ver_code
     IN PA_PROJ_FP_OPTIONS.gen_src_all_wp_ver_code%TYPE := FND_API.G_MISS_CHAR
--Added for webAdi changes for the amount types to be displayed
 ,p_cost_layout_code
     IN PA_PROJ_FP_OPTIONS.cost_layout_code%TYPE := FND_API.G_MISS_CHAR
 ,p_revenue_layout_code
     IN PA_PROJ_FP_OPTIONS.revenue_layout_code%TYPE := FND_API.G_MISS_CHAR
 ,p_all_layout_code
     IN PA_PROJ_FP_OPTIONS.all_layout_code%TYPE := FND_API.G_MISS_CHAR
 -- bug 3519062 end of workplan gen source related columns
,p_revenue_derivation_method
        IN PA_PROJ_FP_OPTIONS.revenue_derivation_method%TYPE := FND_API.G_MISS_CHAR --Bug 5462471
 , p_copy_etc_from_plan_flag
        IN PA_PROJ_FP_OPTIONS.copy_etc_from_plan_flag%TYPE := FND_API.G_MISS_CHAR  --bug 8318932
,p_row_id
    IN ROWID                                                  := NULL
 ,x_return_status                 OUT NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895



PROCEDURE Lock_Row
( p_proj_fp_options_id   IN pa_proj_fp_options.proj_fp_options_id%TYPE
                                      := FND_API.G_MISS_NUM
 ,p_record_version_number          IN NUMBER
                                                           := NULL
 ,p_row_id                         IN ROWID
                                                           := NULL
 ,x_return_status                 OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Delete_Row
( p_proj_fp_options_id   IN pa_proj_fp_options.proj_fp_options_id%TYPE
                                      := FND_API.G_MISS_NUM
 ,p_record_version_number          IN NUMBER
                                                           := NULL
 ,p_row_id                         IN ROWID
                                                           := NULL
 ,x_return_status                 OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
End pa_proj_fp_options_pkg;

/
