--------------------------------------------------------
--  DDL for Package Body PA_PROJ_FP_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJ_FP_OPTIONS_PKG" as
/* $Header: PAFPPOTB.pls 120.3.12010000.2 2009/05/25 14:57:21 gboomina ship $ */
-- Start of Comments
-- Package name     : PA_PROJ_FP_OPTIONS_PKG
-- Purpose          :
-- History          :
-- 15-May-2002 Vejayara Added parameters for columns factor_by_code
--                      and plan_in_multi_curr_flag
-- 14-Aug-2002 Vejayara Added parameters for financial planning in all
--                      procedures
-- 22-Aug-2002 Manoj    found bugs in insert row and update row. Fixed it.
--                      In update row decode for newly added columns is not appropriate.
--                      In insert row sequence was not proper. Changed this in last version.
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
--


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
-- 6-Arp-2005 prachand       Added code for webAdi Changes
--                           Added the code for insertion
--                           insertion and updation of the
--                           additional parameters p_cost_layout_code,
--                           p_revenue_layout_code , and p_all_layout_code
-- 18-JUL-2006 nkumbi        - Bug 5462471
   --                           Included parameter revenue_derivation_method in Insert_Row, update_row
-- NOTE             :
-- End of Comments

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'PA_PROJ_FP_OPTIONS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'PAFPPOTB.pls';

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
 /** Bug 3580727
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
        IN PA_PROJ_FP_OPTIONS.revenue_derivation_method%TYPE := FND_API.G_MISS_CHAR --Bug 5462471
	, p_copy_etc_from_plan_flag
        IN PA_PROJ_FP_OPTIONS.copy_etc_from_plan_flag%TYPE := FND_API.G_MISS_CHAR  --bug 8318932
 ,x_row_id                        OUT NOCOPY ROWID --File.Sql.39 bug 4440895
 ,x_return_status                 OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 IS
   CURSOR C2 IS SELECT pa_proj_fp_options_s.nextval FROM sys.dual;
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (px_proj_fp_options_id IS NULL) OR
         (px_proj_fp_options_id = FND_API.G_MISS_NUM) then
       open c2;
       fetch c2 into px_proj_fp_options_id;
       close c2;
   end if;
   INSERT INTO pa_proj_fp_options(
    proj_fp_options_id
   ,record_version_number
   ,project_id
   ,fin_plan_option_level_code
   ,fin_plan_type_id
   ,fin_plan_start_date
   ,fin_plan_end_date
   ,fin_plan_preference_code
   ,cost_amount_set_id
   ,revenue_amount_set_id
   ,all_amount_set_id
   ,cost_fin_plan_level_code
   ,cost_time_phased_code
   ,cost_resource_list_id
   ,revenue_fin_plan_level_code
   ,revenue_time_phased_code
   ,revenue_resource_list_id
   ,all_fin_plan_level_code
   ,all_time_phased_code
   ,all_resource_list_id
   ,report_labor_hrs_from_code
   ,fin_plan_version_id
   ,default_amount_type_code
   ,default_amount_subtype_code
   ,approved_cost_plan_type_flag
   ,approved_rev_plan_type_flag
   ,projfunc_cost_rate_type
   ,projfunc_cost_rate_date_type
   ,projfunc_cost_rate_date
   ,projfunc_rev_rate_type
   ,projfunc_rev_rate_date_type
   ,projfunc_rev_rate_date
   ,project_cost_rate_type
   ,project_cost_rate_date_type
   ,project_cost_rate_date
   ,project_rev_rate_type
   ,project_rev_rate_date_type
   ,project_rev_rate_date
   ,margin_derived_from_code
   ,select_cost_res_auto_flag
   ,cost_res_planning_level
   ,select_rev_res_auto_flag
   ,revenue_res_planning_level
   ,select_all_res_auto_flag
   ,all_res_planning_level
   ,last_update_date
   ,last_updated_by
   ,creation_date
   ,created_by
   ,last_update_login
   ,factor_by_code
   ,plan_in_multi_curr_flag
   ,process_update_wbs_flag
   ,request_id
   ,plan_processing_code
     ,primary_cost_forecast_flag
     ,primary_rev_forecast_flag
     ,use_planning_rates_flag
     ,rbs_version_id
     ,res_class_raw_cost_sch_id
     ,res_class_bill_rate_sch_id
     ,cost_emp_rate_sch_id
     ,cost_job_rate_sch_id
     ,cost_non_labor_res_rate_sch_id
     ,cost_res_class_rate_sch_id
     ,cost_burden_rate_sch_id
     ,cost_current_planning_period
     ,cost_period_mask_id
     ,rev_emp_rate_sch_id
     ,rev_job_rate_sch_id
     ,rev_non_labor_res_rate_sch_id
     ,rev_res_class_rate_sch_id
     ,rev_current_planning_period
     ,rev_period_mask_id
     /** Bug 3580727
         ,all_emp_rate_sch_id
         ,all_job_rate_sch_id
         ,all_non_labor_res_rate_sch_id
         ,all_res_class_rate_sch_id
         ,all_burden_rate_sch_id
     **/
     ,all_current_planning_period
     ,all_period_mask_id
     ,gen_cost_src_code
     ,gen_cost_etc_src_code
     ,gen_cost_incl_change_doc_flag
     ,gen_cost_incl_open_comm_flag
     ,gen_cost_ret_manual_line_flag
     ,gen_cost_incl_unspent_amt_flag
     ,gen_rev_src_code
     ,gen_rev_etc_src_code
     ,gen_rev_incl_change_doc_flag
     ,gen_rev_incl_bill_event_flag
     ,gen_rev_ret_manual_line_flag
     /** Bug 3580727
         ,gen_rev_incl_unspent_amt_flag
     **/
     ,gen_src_cost_plan_type_id
     ,gen_src_cost_plan_version_id
     ,gen_src_cost_plan_ver_code
     ,gen_src_rev_plan_type_id
     ,gen_src_rev_plan_version_id
     ,gen_src_rev_plan_ver_code
     ,gen_src_all_plan_type_id
     ,gen_src_all_plan_version_id
     ,gen_src_all_plan_ver_code
     ,gen_all_src_code
     ,gen_all_etc_src_code
     ,gen_all_incl_change_doc_flag
     ,gen_all_incl_open_comm_flag
     ,gen_all_ret_manual_line_flag
     ,gen_all_incl_bill_event_flag
     ,gen_all_incl_unspent_amt_flag
     ,gen_cost_actual_amts_thru_code
     ,gen_rev_actual_amts_thru_code
     ,gen_all_actual_amts_thru_code
     ,track_workplan_costs_flag
     ,gen_src_cost_wp_version_id
     ,gen_src_cost_wp_ver_code
     ,gen_src_rev_wp_version_id
     ,gen_src_rev_wp_ver_code
     ,gen_src_all_wp_version_id
     ,gen_src_all_wp_ver_code
     ,cost_layout_code
     ,revenue_layout_code
     ,all_layout_code
     ,revenue_derivation_method --Bug 5462471
     ,copy_etc_from_plan_flag --bug 8318932
    ) values (
    DECODE( px_proj_fp_options_id, FND_API.G_MISS_NUM, NULL,
                  px_proj_fp_options_id)
   ,1
   ,DECODE( p_project_id, FND_API.G_MISS_NUM, NULL, p_project_id)
   ,DECODE( p_fin_plan_option_level_code, FND_API.G_MISS_CHAR, NULL, p_fin_plan_option_level_code)
   ,DECODE( p_fin_plan_type_id, FND_API.G_MISS_NUM, NULL, p_fin_plan_type_id)
   ,DECODE( p_fin_plan_start_date, FND_API.G_MISS_DATE, to_date(NULL), p_fin_plan_start_date)
   ,DECODE( p_fin_plan_end_date, FND_API.G_MISS_DATE, to_date(NULL), p_fin_plan_end_date)
   ,DECODE( p_fin_plan_preference_code, FND_API.G_MISS_CHAR, NULL, p_fin_plan_preference_code)
   ,DECODE( p_cost_amount_set_id, FND_API.G_MISS_NUM, NULL, p_cost_amount_set_id)
   ,DECODE( p_revenue_amount_set_id, FND_API.G_MISS_NUM, NULL, p_revenue_amount_set_id)
   ,DECODE( p_all_amount_set_id, FND_API.G_MISS_NUM, NULL, p_all_amount_set_id)
   ,DECODE( p_cost_fin_plan_level_code, FND_API.G_MISS_CHAR, NULL, p_cost_fin_plan_level_code)
   ,DECODE( p_cost_time_phased_code, FND_API.G_MISS_CHAR, NULL, p_cost_time_phased_code)
   ,DECODE( p_cost_resource_list_id, FND_API.G_MISS_NUM, NULL, p_cost_resource_list_id)
   ,DECODE( p_revenue_fin_plan_level_code, FND_API.G_MISS_CHAR, NULL, p_revenue_fin_plan_level_code)
   ,DECODE( p_revenue_time_phased_code, FND_API.G_MISS_CHAR, NULL, p_revenue_time_phased_code)
   ,DECODE( p_revenue_resource_list_id, FND_API.G_MISS_NUM, NULL, p_revenue_resource_list_id)
   ,DECODE( p_all_fin_plan_level_code, FND_API.G_MISS_CHAR, NULL, p_all_fin_plan_level_code)
   ,DECODE( p_all_time_phased_code, FND_API.G_MISS_CHAR, NULL, p_all_time_phased_code)
   ,DECODE( p_all_resource_list_id, FND_API.G_MISS_NUM, NULL, p_all_resource_list_id)
   ,DECODE( p_report_labor_hrs_from_code, FND_API.G_MISS_CHAR, NULL, p_report_labor_hrs_from_code)
   ,DECODE( p_fin_plan_version_id, FND_API.G_MISS_NUM, NULL, p_fin_plan_version_id)
   ,DECODE( p_default_amount_type_code  , FND_API.G_MISS_CHAR, NULL,  p_default_amount_type_code)
   ,DECODE( p_default_amount_subtype_code  , FND_API.G_MISS_CHAR, NULL,  p_default_amount_subtype_code)
   ,DECODE( p_approved_cost_plan_type_flag , FND_API.G_MISS_CHAR, NULL,  p_approved_cost_plan_type_flag)
   ,DECODE( p_approved_rev_plan_type_flag , FND_API.G_MISS_CHAR, NULL,  p_approved_rev_plan_type_flag)
   ,DECODE( p_projfunc_cost_rate_type     , FND_API.G_MISS_CHAR, NULL,  p_projfunc_cost_rate_type)
   ,DECODE( p_projfunc_cost_rate_date_type , FND_API.G_MISS_CHAR, NULL, p_projfunc_cost_rate_date_type)
   ,DECODE( p_projfunc_cost_rate_date     , FND_API.G_MISS_DATE, NULL,  p_projfunc_cost_rate_date)
   ,DECODE( p_projfunc_rev_rate_type      , FND_API.G_MISS_CHAR, NULL,  p_projfunc_rev_rate_type)
   ,DECODE( p_projfunc_rev_rate_date_type , FND_API.G_MISS_CHAR, NULL,  p_projfunc_rev_rate_date_type)
   ,DECODE( p_projfunc_rev_rate_date      , FND_API.G_MISS_DATE, NULL,  p_projfunc_rev_rate_date)
   ,DECODE( p_project_cost_rate_type      , FND_API.G_MISS_CHAR, NULL, p_project_cost_rate_type)
   ,DECODE( p_project_cost_rate_date_type , FND_API.G_MISS_CHAR, NULL, p_project_cost_rate_date_type)
   ,DECODE( p_project_cost_rate_date      , FND_API.G_MISS_DATE, NULL, p_project_cost_rate_date)
   ,DECODE( p_project_rev_rate_type       , FND_API.G_MISS_CHAR, NULL, p_project_rev_rate_type)
   ,DECODE( p_project_rev_rate_date_type  , FND_API.G_MISS_CHAR, NULL, p_project_rev_rate_date_type)
   ,DECODE( p_project_rev_rate_date       , FND_API.G_MISS_DATE, NULL, p_project_rev_rate_date)
   ,DECODE( p_margin_derived_from_code    , FND_API.G_MISS_CHAR, NULL, p_margin_derived_from_code)
   ,DECODE( p_select_cost_res_auto_flag   , FND_API.G_MISS_CHAR, NULL, p_select_cost_res_auto_flag)
   ,DECODE( p_cost_res_planning_level     , FND_API.G_MISS_CHAR, NULL, p_cost_res_planning_level)
   ,DECODE( p_select_rev_res_auto_flag    , FND_API.G_MISS_CHAR, NULL, p_select_rev_res_auto_flag)
   ,DECODE( p_revenue_res_planning_level  , FND_API.G_MISS_CHAR, NULL, p_revenue_res_planning_level)
   ,DECODE( p_select_all_res_auto_flag    , FND_API.G_MISS_CHAR, NULL, p_select_all_res_auto_flag)
   ,DECODE( p_all_res_planning_level      , FND_API.G_MISS_CHAR, NULL, p_all_res_planning_level)
   ,sysdate
   ,fnd_global.user_id
   ,sysdate
   ,fnd_global.user_id
   ,fnd_global.login_id
   ,DECODE( p_factor_by_code, FND_API.G_MISS_CHAR, NULL, p_factor_by_code)
   ,DECODE( p_plan_in_multi_curr_flag, FND_API.G_MISS_CHAR, NULL, p_plan_in_multi_curr_flag)
   ,DECODE(p_refresh_required_flag, FND_API.G_MISS_CHAR, NULL, p_refresh_required_flag)
   ,DECODE(p_request_id, FND_API.G_MISS_NUM, NULL, p_request_id)
   ,DECODE(p_processing_code, FND_API.G_MISS_CHAR, NULL, p_processing_code)
     ,DECODE(p_primary_cost_forecast_flag,    FND_API.G_MISS_CHAR, NULL,  p_primary_cost_forecast_flag)
     ,DECODE(p_primary_rev_forecast_flag,     FND_API.G_MISS_CHAR, NULL,  p_primary_rev_forecast_flag)
     ,DECODE(p_use_planning_rates_flag,       FND_API.G_MISS_CHAR, NULL,  p_use_planning_rates_flag)
     ,DECODE(p_rbs_version_id,                FND_API.G_MISS_NUM,  NULL,  p_rbs_version_id)
     ,DECODE(p_res_class_raw_cost_sch_id,     FND_API.G_MISS_NUM,  NULL,  p_res_class_raw_cost_sch_id)
     ,DECODE(p_res_class_bill_rate_sch_id,    FND_API.G_MISS_NUM,  NULL,  p_res_class_bill_rate_sch_id)
     ,DECODE(p_cost_emp_rate_sch_id,          FND_API.G_MISS_NUM,  NULL,  p_cost_emp_rate_sch_id)
     ,DECODE(p_cost_job_rate_sch_id,          FND_API.G_MISS_NUM,  NULL,  p_cost_job_rate_sch_id)
     ,DECODE(p_cst_non_labr_res_rate_sch_id,  FND_API.G_MISS_NUM,  NULL,  p_cst_non_labr_res_rate_sch_id)
     ,DECODE(p_cost_res_class_rate_sch_id,    FND_API.G_MISS_NUM,  NULL,  p_cost_res_class_rate_sch_id)
     ,DECODE(p_cost_burden_rate_sch_id,       FND_API.G_MISS_NUM,  NULL,  p_cost_burden_rate_sch_id)
     ,DECODE(p_cost_current_planning_period,  FND_API.G_MISS_CHAR, NULL,  p_cost_current_planning_period)
     ,DECODE(p_cost_period_mask_id,           FND_API.G_MISS_NUM,  NULL,  p_cost_period_mask_id)
     ,DECODE(p_rev_emp_rate_sch_id,           FND_API.G_MISS_NUM,  NULL,  p_rev_emp_rate_sch_id)
     ,DECODE(p_rev_job_rate_sch_id,           FND_API.G_MISS_NUM,  NULL,  p_rev_job_rate_sch_id)
     ,DECODE(p_rev_non_labr_res_rate_sch_id,  FND_API.G_MISS_NUM,  NULL,  p_rev_non_labr_res_rate_sch_id)
     ,DECODE(p_rev_res_class_rate_sch_id,     FND_API.G_MISS_NUM,  NULL,  p_rev_res_class_rate_sch_id)
     ,DECODE(p_rev_current_planning_period,   FND_API.G_MISS_CHAR, NULL,  p_rev_current_planning_period)
     ,DECODE(p_rev_period_mask_id,            FND_API.G_MISS_NUM,  NULL,  p_rev_period_mask_id)
     /** Bug 3580727
         ,DECODE(p_all_emp_rate_sch_id,           FND_API.G_MISS_NUM,  NULL,  p_all_emp_rate_sch_id)
         ,DECODE(p_all_job_rate_sch_id,           FND_API.G_MISS_NUM,  NULL,  p_all_job_rate_sch_id)
         ,DECODE(p_all_non_labr_res_rate_sch_id,  FND_API.G_MISS_NUM,  NULL,  p_all_non_labr_res_rate_sch_id)
         ,DECODE(p_all_res_class_rate_sch_id,     FND_API.G_MISS_NUM,  NULL,  p_all_res_class_rate_sch_id)
         ,DECODE(p_all_burden_rate_sch_id,        FND_API.G_MISS_NUM,  NULL,  p_all_burden_rate_sch_id)
     **/
     ,DECODE(p_all_current_planning_period,   FND_API.G_MISS_CHAR, NULL,  p_all_current_planning_period)
     ,DECODE(p_all_period_mask_id,            FND_API.G_MISS_NUM,  NULL,  p_all_period_mask_id)
     ,DECODE(p_gen_cost_src_code,             FND_API.G_MISS_CHAR, NULL,  p_gen_cost_src_code)
     ,DECODE(p_gen_cost_etc_src_code,         FND_API.G_MISS_CHAR, NULL,  p_gen_cost_etc_src_code)
     ,DECODE(p_gn_cost_incl_change_doc_flag,  FND_API.G_MISS_CHAR, NULL,  p_gn_cost_incl_change_doc_flag)
     ,DECODE(p_gen_cost_incl_open_comm_flag,  FND_API.G_MISS_CHAR, NULL,  p_gen_cost_incl_open_comm_flag)
     ,DECODE(p_gn_cost_ret_manual_line_flag,  FND_API.G_MISS_CHAR, NULL,  p_gn_cost_ret_manual_line_flag)
     ,DECODE(p_gn_cst_incl_unspent_amt_flag,  FND_API.G_MISS_CHAR, NULL,  p_gn_cst_incl_unspent_amt_flag)
     ,DECODE(p_gen_rev_src_code,              FND_API.G_MISS_CHAR, NULL,  p_gen_rev_src_code)
     ,DECODE(p_gen_rev_etc_src_code,          FND_API.G_MISS_CHAR, NULL,  p_gen_rev_etc_src_code)
     ,DECODE(p_gen_rev_incl_change_doc_flag,  FND_API.G_MISS_CHAR, NULL,  p_gen_rev_incl_change_doc_flag)
     ,DECODE(p_gen_rev_incl_bill_event_flag,  FND_API.G_MISS_CHAR, NULL,  p_gen_rev_incl_bill_event_flag)
     ,DECODE(p_gen_rev_ret_manual_line_flag,  FND_API.G_MISS_CHAR, NULL,  p_gen_rev_ret_manual_line_flag)
     /** Bug 3580727
         ,DECODE(p_gn_rev_incl_unspent_amt_flag,  FND_API.G_MISS_CHAR, NULL,  p_gn_rev_incl_unspent_amt_flag)
     **/
     ,DECODE(p_gen_src_cost_plan_type_id,     FND_API.G_MISS_NUM,  NULL,  p_gen_src_cost_plan_type_id)
     ,DECODE(p_gen_src_cost_plan_version_id,  FND_API.G_MISS_NUM,  NULL,  p_gen_src_cost_plan_version_id)
     ,DECODE(p_gen_src_cost_plan_ver_code,    FND_API.G_MISS_CHAR, NULL,  p_gen_src_cost_plan_ver_code)
     ,DECODE(p_gen_src_rev_plan_type_id,      FND_API.G_MISS_NUM,  NULL,  p_gen_src_rev_plan_type_id)
     ,DECODE(p_gen_src_rev_plan_version_id,   FND_API.G_MISS_NUM,  NULL,  p_gen_src_rev_plan_version_id)
     ,DECODE(p_gen_src_rev_plan_ver_code,     FND_API.G_MISS_CHAR, NULL,  p_gen_src_rev_plan_ver_code)
     ,DECODE(p_gen_src_all_plan_type_id,      FND_API.G_MISS_NUM,  NULL,  p_gen_src_all_plan_type_id)
     ,DECODE(p_gen_src_all_plan_version_id,   FND_API.G_MISS_NUM,  NULL,  p_gen_src_all_plan_version_id)
     ,DECODE(p_gen_src_all_plan_ver_code,     FND_API.G_MISS_CHAR, NULL,  p_gen_src_all_plan_ver_code)
     ,DECODE(p_gen_all_src_code,              FND_API.G_MISS_CHAR, NULL,  p_gen_all_src_code)
     ,DECODE(p_gen_all_etc_src_code,          FND_API.G_MISS_CHAR, NULL,  p_gen_all_etc_src_code)
     ,DECODE(p_gen_all_incl_change_doc_flag,  FND_API.G_MISS_CHAR, NULL,  p_gen_all_incl_change_doc_flag)
     ,DECODE(p_gen_all_incl_open_comm_flag,   FND_API.G_MISS_CHAR, NULL,  p_gen_all_incl_open_comm_flag)
     ,DECODE(p_gen_all_ret_manual_line_flag,  FND_API.G_MISS_CHAR, NULL,  p_gen_all_ret_manual_line_flag)
     ,DECODE(p_gen_all_incl_bill_event_flag,  FND_API.G_MISS_CHAR, NULL,  p_gen_all_incl_bill_event_flag)
     ,DECODE(p_gn_all_incl_unspent_amt_flag,  FND_API.G_MISS_CHAR, NULL,  p_gn_all_incl_unspent_amt_flag)
     ,DECODE(p_gn_cst_actual_amts_thru_code,  FND_API.G_MISS_CHAR, NULL,  p_gn_cst_actual_amts_thru_code)
     ,DECODE(p_gn_rev_actual_amts_thru_code,  FND_API.G_MISS_CHAR, NULL,  p_gn_rev_actual_amts_thru_code)
     ,DECODE(p_gn_all_actual_amts_thru_code,  FND_API.G_MISS_CHAR, NULL,  p_gn_all_actual_amts_thru_code)
     ,DECODE(p_track_workplan_costs_flag,     FND_API.G_MISS_CHAR, NULL,  p_track_workplan_costs_flag)
     -- bug 3519062 start of workplan gen source related columns
     ,DECODE(p_gen_src_cost_wp_version_id,   FND_API.G_MISS_NUM,  NULL,  p_gen_src_cost_wp_version_id)
     ,DECODE(p_gen_src_cost_wp_ver_code,     FND_API.G_MISS_CHAR, NULL,  p_gen_src_cost_wp_ver_code)
     ,DECODE(p_gen_src_rev_wp_version_id,    FND_API.G_MISS_NUM,  NULL,  p_gen_src_rev_wp_version_id)
     ,DECODE(p_gen_src_rev_wp_ver_code,      FND_API.G_MISS_CHAR, NULL,  p_gen_src_rev_wp_ver_code)
     ,DECODE(p_gen_src_all_wp_version_id,    FND_API.G_MISS_NUM,  NULL,  p_gen_src_all_wp_version_id)
     ,DECODE(p_gen_src_all_wp_ver_code,      FND_API.G_MISS_CHAR, NULL,  p_gen_src_all_wp_ver_code)
     ,DECODE(p_cost_layout_code       ,      FND_API.G_MISS_CHAR, NULL,  p_cost_layout_code)
     ,DECODE(p_revenue_layout_code,          FND_API.G_MISS_CHAR, NULL,  p_revenue_layout_code)
     ,DECODE(p_all_layout_code,          FND_API.G_MISS_CHAR, NULL,  p_all_layout_code)
     -- bug 3519062 end of workplan gen source related columns
    ,DECODE(p_revenue_derivation_method,FND_API.G_MISS_CHAR,NULL,p_revenue_derivation_method) -- Bug 5462471
    ,DECODE(p_copy_etc_from_plan_flag,FND_API.G_MISS_CHAR,NULL,p_copy_etc_from_plan_flag) --bug 8318932
);

EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_PROJ_FP_OPTIONS_PKG'
                               ,p_procedure_name
                                => 'Insert_Row');
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Insert_Row;



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
 /** Bug 3580727
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
 -- bug 3519062 end of workplan gen source related columns

 --Added for webAdi changes for the amount types to be displayed
 ,p_cost_layout_code
     IN PA_PROJ_FP_OPTIONS.cost_layout_code%TYPE := FND_API.G_MISS_CHAR
 ,p_revenue_layout_code
     IN PA_PROJ_FP_OPTIONS.revenue_layout_code%TYPE := FND_API.G_MISS_CHAR
 ,p_all_layout_code
     IN PA_PROJ_FP_OPTIONS.all_layout_code%TYPE := FND_API.G_MISS_CHAR
 ,p_revenue_derivation_method
        IN PA_PROJ_FP_OPTIONS.revenue_derivation_method%TYPE := FND_API.G_MISS_CHAR --Bug 5462471
 , p_copy_etc_from_plan_flag
        IN PA_PROJ_FP_OPTIONS.copy_etc_from_plan_flag%TYPE := FND_API.G_MISS_CHAR  --bug 8318932
 ,p_row_id
    IN ROWID                                                  := NULL
 ,x_return_status                 OUT NOCOPY VARCHAR2)  --File.Sql.39 bug 4440895
IS
BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 UPDATE pa_proj_fp_options
 SET
  record_version_number = nvl(record_version_number,0) +1
 ,project_id = DECODE( p_project_id, FND_API.G_MISS_NUM, project_id,
                                   p_project_id)
 ,fin_plan_option_level_code = DECODE( p_fin_plan_option_level_code,
                                                                   FND_API.G_MISS_CHAR,
                                           fin_plan_option_level_code,
                                           p_fin_plan_option_level_code)
 ,fin_plan_type_id = DECODE( p_fin_plan_type_id, FND_API.G_MISS_NUM,
                                            fin_plan_type_id, p_fin_plan_type_id)
 ,fin_plan_start_date   = DECODE( p_fin_plan_start_date, FND_API.G_MISS_DATE,
                                                    fin_plan_start_date,
                                  p_fin_plan_start_date)
 ,fin_plan_end_date   = DECODE( p_fin_plan_end_date, FND_API.G_MISS_DATE,
                                                  fin_plan_end_date, p_fin_plan_end_date)
 ,fin_plan_preference_code = DECODE( p_fin_plan_preference_code,
                                                                 FND_API.G_MISS_CHAR,
                                         fin_plan_preference_code,
                                         p_fin_plan_preference_code)
 ,cost_amount_set_id = DECODE( p_cost_amount_set_id, FND_API.G_MISS_NUM,
                                                 cost_amount_set_id, p_cost_amount_set_id)
 ,revenue_amount_set_id = DECODE( p_revenue_amount_set_id, FND_API.G_MISS_NUM,
                                                    revenue_amount_set_id,
                                  p_revenue_amount_set_id)
 ,all_amount_set_id = DECODE( p_all_amount_set_id, FND_API.G_MISS_NUM,
                                                all_amount_set_id, p_all_amount_set_id)
 ,cost_fin_plan_level_code = DECODE( p_cost_fin_plan_level_code,
                                                          FND_API.G_MISS_CHAR,
                                     cost_fin_plan_level_code,
                                     p_cost_fin_plan_level_code)
 ,cost_time_phased_code = DECODE( p_cost_time_phased_code, FND_API.G_MISS_CHAR,
                                                    cost_time_phased_code,
                                  p_cost_time_phased_code)
 ,cost_resource_list_id = DECODE( p_cost_resource_list_id, FND_API.G_MISS_NUM,
                                                    cost_resource_list_id,
                                  p_cost_resource_list_id)
 ,revenue_fin_plan_level_code = DECODE( p_revenue_fin_plan_level_code,
                                                                FND_API.G_MISS_CHAR,
                                        revenue_fin_plan_level_code,
                                        p_revenue_fin_plan_level_code)
 ,revenue_time_phased_code = DECODE( p_revenue_time_phased_code,
                                                          FND_API.G_MISS_CHAR,
                                     revenue_time_phased_code,
                                     p_revenue_time_phased_code)
 ,revenue_resource_list_id = DECODE( p_revenue_resource_list_id,
                                                          FND_API.G_MISS_NUM,
                                     revenue_resource_list_id,
                                     p_revenue_resource_list_id)
 ,all_fin_plan_level_code = DECODE( p_all_fin_plan_level_code,
                                                         FND_API.G_MISS_CHAR,
                                    all_fin_plan_level_code,
                                    p_all_fin_plan_level_code)
 ,all_time_phased_code = DECODE( p_all_time_phased_code, FND_API.G_MISS_CHAR,
                                                   all_time_phased_code, p_all_time_phased_code)
 ,all_resource_list_id = DECODE( p_all_resource_list_id, FND_API.G_MISS_NUM,
                                                   all_resource_list_id, p_all_resource_list_id)
 ,report_labor_hrs_from_code = DECODE( p_report_labor_hrs_from_code,
                                                                FND_API.G_MISS_CHAR,
                                        report_labor_hrs_from_code,
                                        p_report_labor_hrs_from_code)
 ,fin_plan_version_id = DECODE( p_fin_plan_version_id, FND_API.G_MISS_NUM,
                                                 fin_plan_version_id, p_fin_plan_version_id)
 ,plan_in_multi_curr_flag          = DECODE(p_plan_in_multi_curr_flag         ,
                FND_API.G_MISS_CHAR  ,plan_in_multi_curr_flag, p_plan_in_multi_curr_flag )
 ,factor_by_code                   = DECODE(p_factor_by_code                  ,
                FND_API.G_MISS_CHAR  ,factor_by_code ,p_factor_by_code)
 ,default_amount_type_code         = DECODE(p_default_amount_type_code        ,
                FND_API.G_MISS_CHAR,default_amount_type_code, p_default_amount_type_code)
 ,default_amount_subtype_code      = DECODE(p_default_amount_subtype_code     ,
                FND_API.G_MISS_CHAR,default_amount_subtype_code, p_default_amount_subtype_code      )
 ,approved_cost_plan_type_flag     = DECODE(p_approved_cost_plan_type_flag    ,
                FND_API.G_MISS_CHAR,approved_cost_plan_type_flag, p_approved_cost_plan_type_flag     )
 ,approved_rev_plan_type_flag      = DECODE(p_approved_rev_plan_type_flag     ,
                FND_API.G_MISS_CHAR,approved_rev_plan_type_flag, p_approved_rev_plan_type_flag      )
 ,projfunc_cost_rate_type          = DECODE(p_projfunc_cost_rate_type         ,
                FND_API.G_MISS_CHAR,projfunc_cost_rate_type,p_projfunc_cost_rate_type          )
 ,projfunc_cost_rate_date_type     = DECODE(p_projfunc_cost_rate_date_type    ,
                FND_API.G_MISS_CHAR,projfunc_cost_rate_date_type, p_projfunc_cost_rate_date_type     )
 ,projfunc_cost_rate_date          = DECODE(p_projfunc_cost_rate_date         ,
                FND_API.G_MISS_DATE,projfunc_cost_rate_date, p_projfunc_cost_rate_date          )
 ,projfunc_rev_rate_type           = DECODE(p_projfunc_rev_rate_type          ,
                FND_API.G_MISS_CHAR,projfunc_rev_rate_type, p_projfunc_rev_rate_type           )
 ,projfunc_rev_rate_date_type      = DECODE(p_projfunc_rev_rate_date_type     ,
                FND_API.G_MISS_CHAR,projfunc_rev_rate_date_type, p_projfunc_rev_rate_date_type      )
 ,projfunc_rev_rate_date           = DECODE(p_projfunc_rev_rate_date          ,
                FND_API.G_MISS_DATE,projfunc_rev_rate_date, p_projfunc_rev_rate_date           )
 ,project_cost_rate_type           = DECODE(p_project_cost_rate_type          ,
                FND_API.G_MISS_CHAR,project_cost_rate_type, p_project_cost_rate_type           )
 ,project_cost_rate_date_type      = DECODE(p_project_cost_rate_date_type     ,
                FND_API.G_MISS_CHAR,project_cost_rate_date_type, p_project_cost_rate_date_type      )
 ,project_cost_rate_date           = DECODE(p_project_cost_rate_date          ,
                FND_API.G_MISS_DATE,project_cost_rate_date, p_project_cost_rate_date           )
 ,project_rev_rate_type            = DECODE(p_project_rev_rate_type           ,
                FND_API.G_MISS_CHAR,project_rev_rate_type, p_project_rev_rate_type            )
 ,project_rev_rate_date_type       = DECODE(p_project_rev_rate_date_type      ,
                FND_API.G_MISS_CHAR,project_rev_rate_date_type, p_project_rev_rate_date_type       )
 ,project_rev_rate_date            = DECODE(p_project_rev_rate_date           ,
                FND_API.G_MISS_DATE,project_rev_rate_date, p_project_rev_rate_date            )
 ,margin_derived_from_code         = DECODE(p_margin_derived_from_code        ,
                FND_API.G_MISS_CHAR,margin_derived_from_code, p_margin_derived_from_code         )
 ,select_cost_res_auto_flag        = DECODE( p_select_cost_res_auto_flag      ,
                FND_API.G_MISS_CHAR, select_cost_res_auto_flag, p_select_cost_res_auto_flag)
 ,cost_res_planning_level          = DECODE( p_cost_res_planning_level        ,
                FND_API.G_MISS_CHAR, cost_res_planning_level, p_cost_res_planning_level)
 ,select_rev_res_auto_flag         = DECODE( p_select_rev_res_auto_flag       ,
                FND_API.G_MISS_CHAR, select_rev_res_auto_flag, p_select_rev_res_auto_flag)
 ,revenue_res_planning_level       = DECODE( p_revenue_res_planning_level     ,
                FND_API.G_MISS_CHAR, revenue_res_planning_level, p_revenue_res_planning_level)
 ,select_all_res_auto_flag         = DECODE( p_select_all_res_auto_flag       ,
                FND_API.G_MISS_CHAR, select_all_res_auto_flag, p_select_all_res_auto_flag)
 ,all_res_planning_level           = DECODE( p_all_res_planning_level         ,
                FND_API.G_MISS_CHAR, all_res_planning_level, p_all_res_planning_level)
 ,last_update_date = sysdate
 ,last_updated_by = fnd_global.user_id
 ,last_update_login = fnd_global.login_id
 ,primary_cost_forecast_flag       = DECODE(p_primary_cost_forecast_flag,
                FND_API.G_MISS_CHAR, primary_cost_forecast_flag, p_primary_cost_forecast_flag)
 ,primary_rev_forecast_flag        = DECODE(p_primary_rev_forecast_flag,
                FND_API.G_MISS_CHAR, primary_rev_forecast_flag, p_primary_rev_forecast_flag)
 ,use_planning_rates_flag          = DECODE(p_use_planning_rates_flag,
                FND_API.G_MISS_CHAR, use_planning_rates_flag, p_use_planning_rates_flag)
 ,rbs_version_id            = DECODE(p_rbs_version_id,
                FND_API.G_MISS_NUM,  rbs_version_id,  p_rbs_version_id)
 ,res_class_raw_cost_sch_id        = DECODE(p_res_class_raw_cost_sch_id,
                FND_API.G_MISS_NUM,  res_class_raw_cost_sch_id, p_res_class_raw_cost_sch_id)
 ,res_class_bill_rate_sch_id       = DECODE(p_res_class_bill_rate_sch_id,
                FND_API.G_MISS_NUM,  res_class_bill_rate_sch_id, p_res_class_bill_rate_sch_id)
 ,cost_emp_rate_sch_id             = DECODE(p_cost_emp_rate_sch_id,
                FND_API.G_MISS_NUM,  cost_emp_rate_sch_id, p_cost_emp_rate_sch_id)
 ,cost_job_rate_sch_id             = DECODE(p_cost_job_rate_sch_id,
                FND_API.G_MISS_NUM,  cost_job_rate_sch_id,  p_cost_job_rate_sch_id)
 ,cost_non_labor_res_rate_sch_id   = DECODE(P_CST_NON_LABR_RES_RATE_SCH_ID,
                FND_API.G_MISS_NUM,  cost_non_labor_res_rate_sch_id, P_CST_NON_LABR_RES_RATE_SCH_ID)
 ,cost_res_class_rate_sch_id       = DECODE(p_cost_res_class_rate_sch_id,
                FND_API.G_MISS_NUM,  cost_res_class_rate_sch_id, p_cost_res_class_rate_sch_id)
 ,cost_burden_rate_sch_id          = DECODE(p_cost_burden_rate_sch_id,
                FND_API.G_MISS_NUM,  cost_burden_rate_sch_id, p_cost_burden_rate_sch_id)
 ,cost_current_planning_period     = DECODE(p_cost_current_planning_period,
                FND_API.G_MISS_CHAR, cost_current_planning_period, p_cost_current_planning_period)
 ,cost_period_mask_id              = DECODE(p_cost_period_mask_id,
                FND_API.G_MISS_NUM,  cost_period_mask_id, p_cost_period_mask_id)
 ,rev_emp_rate_sch_id              = DECODE(p_rev_emp_rate_sch_id,
                FND_API.G_MISS_NUM,  rev_emp_rate_sch_id, p_rev_emp_rate_sch_id)
 ,rev_job_rate_sch_id              = DECODE(p_rev_job_rate_sch_id,
                FND_API.G_MISS_NUM,  rev_job_rate_sch_id, p_rev_job_rate_sch_id)
 ,rev_non_labor_res_rate_sch_id    = DECODE(P_REV_NON_LABR_RES_RATE_SCH_ID,
                FND_API.G_MISS_NUM,  rev_non_labor_res_rate_sch_id, P_REV_NON_LABR_RES_RATE_SCH_ID)
 ,rev_res_class_rate_sch_id        = DECODE(p_rev_res_class_rate_sch_id,
                FND_API.G_MISS_NUM,  rev_res_class_rate_sch_id, p_rev_res_class_rate_sch_id)
 ,rev_current_planning_period      = DECODE(p_rev_current_planning_period,
                FND_API.G_MISS_CHAR, rev_current_planning_period, p_rev_current_planning_period)
 ,rev_period_mask_id               = DECODE(p_rev_period_mask_id,
                FND_API.G_MISS_NUM,  rev_period_mask_id, p_rev_period_mask_id)
 /** Bug 3580727
     ,all_emp_rate_sch_id              = DECODE(p_all_emp_rate_sch_id,
                    FND_API.G_MISS_NUM,  all_emp_rate_sch_id, p_all_emp_rate_sch_id)
     ,all_job_rate_sch_id              = DECODE(p_all_job_rate_sch_id,
                    FND_API.G_MISS_NUM,  all_job_rate_sch_id, p_all_job_rate_sch_id)
     ,all_non_labor_res_rate_sch_id    = DECODE(P_ALL_NON_LABR_RES_RATE_SCH_ID,
                    FND_API.G_MISS_NUM,  all_non_labor_res_rate_sch_id, P_ALL_NON_LABR_RES_RATE_SCH_ID)
     ,all_res_class_rate_sch_id        = DECODE(p_all_res_class_rate_sch_id,
                    FND_API.G_MISS_NUM,  all_res_class_rate_sch_id, p_all_res_class_rate_sch_id)
     ,all_burden_rate_sch_id           = DECODE(p_all_burden_rate_sch_id,
                    FND_API.G_MISS_NUM,  all_burden_rate_sch_id, p_all_burden_rate_sch_id)
 **/
 ,all_current_planning_period      = DECODE(p_all_current_planning_period,
                FND_API.G_MISS_CHAR, all_current_planning_period, p_all_current_planning_period)
 ,all_period_mask_id               = DECODE(p_all_period_mask_id,
                FND_API.G_MISS_NUM,  all_period_mask_id,  p_all_period_mask_id)
 ,gen_cost_src_code                = DECODE(p_gen_cost_src_code,
                FND_API.G_MISS_CHAR, gen_cost_src_code,  p_gen_cost_src_code)
 ,gen_cost_etc_src_code            = DECODE(p_gen_cost_etc_src_code,
                FND_API.G_MISS_CHAR, gen_cost_etc_src_code, p_gen_cost_etc_src_code)
 ,gen_cost_incl_change_doc_flag    = DECODE(P_GN_COST_INCL_CHANGE_DOC_FLAG,
                FND_API.G_MISS_CHAR, gen_cost_incl_change_doc_flag, P_GN_COST_INCL_CHANGE_DOC_FLAG)
 ,gen_cost_incl_open_comm_flag     = DECODE(p_gen_cost_incl_open_comm_flag,
                FND_API.G_MISS_CHAR, gen_cost_incl_open_comm_flag, p_gen_cost_incl_open_comm_flag)
 ,gen_cost_ret_manual_line_flag    = DECODE(P_GN_COST_RET_MANUAL_LINE_FLAG,
                FND_API.G_MISS_CHAR, gen_cost_ret_manual_line_flag, P_GN_COST_RET_MANUAL_LINE_FLAG)
 ,gen_cost_incl_unspent_amt_flag   = DECODE(P_GN_CST_INCL_UNSPENT_AMT_FLAG,
                FND_API.G_MISS_CHAR, gen_cost_incl_unspent_amt_flag, P_GN_CST_INCL_UNSPENT_AMT_FLAG)
 ,gen_rev_src_code                 = DECODE(p_gen_rev_src_code,
                FND_API.G_MISS_CHAR, gen_rev_src_code, p_gen_rev_src_code)
 ,gen_rev_etc_src_code             = DECODE(p_gen_rev_etc_src_code,
                FND_API.G_MISS_CHAR, gen_rev_etc_src_code,  p_gen_rev_etc_src_code)
 ,gen_rev_incl_change_doc_flag     = DECODE(p_gen_rev_incl_change_doc_flag,
                FND_API.G_MISS_CHAR, gen_rev_incl_change_doc_flag, p_gen_rev_incl_change_doc_flag)
 ,gen_rev_incl_bill_event_flag     = DECODE(p_gen_rev_incl_bill_event_flag,
                FND_API.G_MISS_CHAR, gen_rev_incl_bill_event_flag, p_gen_rev_incl_bill_event_flag)
 ,gen_rev_ret_manual_line_flag     = DECODE(p_gen_rev_ret_manual_line_flag,
                FND_API.G_MISS_CHAR, gen_rev_ret_manual_line_flag,  p_gen_rev_ret_manual_line_flag)
 /** Bug 3580727
     ,gen_rev_incl_unspent_amt_flag    = DECODE(P_GN_REV_INCL_UNSPENT_AMT_FLAG,
                    FND_API.G_MISS_CHAR, gen_rev_incl_unspent_amt_flag, P_GN_REV_INCL_UNSPENT_AMT_FLAG)
 **/
 ,gen_src_cost_plan_type_id        = DECODE(p_gen_src_cost_plan_type_id,
                FND_API.G_MISS_NUM,  gen_src_cost_plan_type_id,  p_gen_src_cost_plan_type_id)
 ,gen_src_cost_plan_version_id     = DECODE(p_gen_src_cost_plan_version_id,
                FND_API.G_MISS_NUM, gen_src_cost_plan_version_id, p_gen_src_cost_plan_version_id)
 ,gen_src_cost_plan_ver_code       = DECODE(p_gen_src_cost_plan_ver_code,
                FND_API.G_MISS_CHAR, gen_src_cost_plan_ver_code, p_gen_src_cost_plan_ver_code)
 ,gen_src_rev_plan_type_id         = DECODE(p_gen_src_rev_plan_type_id,
                FND_API.G_MISS_NUM,  gen_src_rev_plan_type_id, p_gen_src_rev_plan_type_id)
 ,gen_src_rev_plan_version_id      = DECODE(p_gen_src_rev_plan_version_id,
                FND_API.G_MISS_NUM,  gen_src_rev_plan_version_id,p_gen_src_rev_plan_version_id)
 ,gen_src_rev_plan_ver_code       = DECODE(p_gen_src_rev_plan_ver_code,
                FND_API.G_MISS_CHAR, gen_src_rev_plan_ver_code, p_gen_src_rev_plan_ver_code)
 ,gen_src_all_plan_type_id        = DECODE(p_gen_src_all_plan_type_id,
                FND_API.G_MISS_NUM, gen_src_all_plan_type_id, p_gen_src_all_plan_type_id)
 ,gen_src_all_plan_version_id     = DECODE(p_gen_src_all_plan_version_id,
                FND_API.G_MISS_NUM, gen_src_all_plan_version_id, p_gen_src_all_plan_version_id)
 ,gen_src_all_plan_ver_code       = DECODE(p_gen_src_all_plan_ver_code,
                FND_API.G_MISS_CHAR,gen_src_all_plan_ver_code, p_gen_src_all_plan_ver_code)
 ,gen_all_src_code                = DECODE(p_gen_all_src_code,
                FND_API.G_MISS_CHAR,gen_all_src_code, p_gen_all_src_code)
 ,gen_all_etc_src_code            = DECODE(p_gen_all_etc_src_code,
                FND_API.G_MISS_CHAR, gen_all_etc_src_code,  p_gen_all_etc_src_code)
 ,gen_all_incl_change_doc_flag    = DECODE(p_gen_all_incl_change_doc_flag,
                FND_API.G_MISS_CHAR,gen_all_incl_change_doc_flag, p_gen_all_incl_change_doc_flag)
 ,gen_all_incl_open_comm_flag     = DECODE(p_gen_all_incl_open_comm_flag,
                FND_API.G_MISS_CHAR,gen_all_incl_open_comm_flag, p_gen_all_incl_open_comm_flag)
 ,gen_all_ret_manual_line_flag    = DECODE(p_gen_all_ret_manual_line_flag,
                FND_API.G_MISS_CHAR,gen_all_ret_manual_line_flag, p_gen_all_ret_manual_line_flag)
 ,gen_all_incl_bill_event_flag    = DECODE(p_gen_all_incl_bill_event_flag,
                FND_API.G_MISS_CHAR,gen_all_incl_bill_event_flag, p_gen_all_incl_bill_event_flag)
 ,gen_all_incl_unspent_amt_flag   = DECODE(P_GN_ALL_INCL_UNSPENT_AMT_FLAG,
                FND_API.G_MISS_CHAR,gen_all_incl_unspent_amt_flag, P_GN_ALL_INCL_UNSPENT_AMT_FLAG)
 ,gen_cost_actual_amts_thru_code  = DECODE(P_GN_CST_ACTUAL_AMTS_THRU_CODE,
                FND_API.G_MISS_CHAR,gen_cost_actual_amts_thru_code, P_GN_CST_ACTUAL_AMTS_THRU_CODE)
 ,gen_rev_actual_amts_thru_code   = DECODE(P_GN_REV_ACTUAL_AMTS_THRU_CODE,
                FND_API.G_MISS_CHAR,gen_rev_actual_amts_thru_code, P_GN_REV_ACTUAL_AMTS_THRU_CODE)
 ,gen_all_actual_amts_thru_code   = DECODE(P_GN_ALL_ACTUAL_AMTS_THRU_CODE,
                FND_API.G_MISS_CHAR,gen_all_actual_amts_thru_code, P_GN_ALL_ACTUAL_AMTS_THRU_CODE)
 ,track_workplan_costs_flag      = DECODE(p_track_workplan_costs_flag,
                FND_API.G_MISS_CHAR,track_workplan_costs_flag, p_track_workplan_costs_flag)
 -- bug 3519062 start of workplan generation source related columns
 ,gen_src_cost_wp_version_id     = DECODE(p_gen_src_cost_wp_version_id,
                FND_API.G_MISS_NUM, gen_src_cost_wp_version_id, p_gen_src_cost_wp_version_id)
 ,gen_src_cost_wp_ver_code       = DECODE(p_gen_src_cost_wp_ver_code,
                FND_API.G_MISS_CHAR,gen_src_cost_wp_ver_code, p_gen_src_cost_wp_ver_code)
 ,gen_src_rev_wp_version_id     = DECODE(p_gen_src_rev_wp_version_id,
                FND_API.G_MISS_NUM, gen_src_rev_wp_version_id, p_gen_src_rev_wp_version_id)
 ,gen_src_rev_wp_ver_code       = DECODE(p_gen_src_rev_wp_ver_code,
                FND_API.G_MISS_CHAR,gen_src_rev_wp_ver_code, p_gen_src_rev_wp_ver_code)
 ,gen_src_all_wp_version_id     = DECODE(p_gen_src_all_wp_version_id,
                FND_API.G_MISS_NUM, gen_src_all_wp_version_id, p_gen_src_all_wp_version_id)
 ,gen_src_all_wp_ver_code       = DECODE(p_gen_src_all_wp_ver_code,
                FND_API.G_MISS_CHAR,gen_src_all_wp_ver_code, p_gen_src_all_wp_ver_code)
 -- bug 3519062 start of workplan generation source related columns
,cost_layout_code              = DECODE(p_cost_layout_code,
                FND_API.G_MISS_CHAR, cost_layout_code, p_cost_layout_code)
,revenue_layout_code              = DECODE(p_revenue_layout_code,
                FND_API.G_MISS_CHAR, revenue_layout_code, p_revenue_layout_code)
,all_layout_code              = DECODE(p_all_layout_code,
                FND_API.G_MISS_CHAR, all_layout_code, p_all_layout_code)
,revenue_derivation_method    = DECODE(p_revenue_derivation_method,
                   FND_API.G_MISS_CHAR, revenue_derivation_method,p_revenue_derivation_method) -- Bug 5462471
,copy_etc_from_plan_flag    = DECODE(p_copy_etc_from_plan_flag,
                   FND_API.G_MISS_CHAR, copy_etc_from_plan_flag,p_copy_etc_from_plan_flag) -- bug 8318932
  WHERE proj_fp_options_id = p_proj_fp_options_id
   AND nvl(p_record_version_number, nvl(record_version_number,0)) =
                                    nvl(record_version_number,0);

    IF (SQL%NOTFOUND) THEN
         PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_XC_RECORD_CHANGED');
         x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_PROJ_FP_OPTIONS_PKG'
                               ,p_procedure_name
                                => 'Update_Row');
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Update_Row;

PROCEDURE Delete_Row
( p_proj_fp_options_id   IN pa_proj_fp_options.proj_fp_options_id%TYPE
                                      := FND_API.G_MISS_NUM
 ,p_record_version_number          IN NUMBER
                                                           := NULL
 ,p_row_id                         IN ROWID
                                                           := NULL
 ,x_return_status                 OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_proj_fp_options_id IS NOT NULL AND
           p_proj_fp_options_id <> FND_API.G_MISS_NUM) THEN

        DELETE FROM pa_proj_fp_options
         WHERE proj_fp_options_id = p_proj_fp_options_id
           AND nvl(p_record_version_number, nvl(record_version_number,0)) =
                                            nvl(record_version_number,0);
    ELSIF (p_row_id IS NOT NULL) THEN
        DELETE FROM pa_proj_fp_options
         WHERE rowid = p_row_id
           AND nvl(p_record_version_number, nvl(record_version_number,0)) =
                                            nvl(record_version_number,0);
    END IF;

    IF (SQL%NOTFOUND) THEN
         PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_XC_RECORD_CHANGED');
         x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_PROJ_FP_OPTIONS_PKG'
                               ,p_procedure_name
                                    => 'Delete_Row');
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Delete_Row;

PROCEDURE Lock_Row
( p_proj_fp_options_id   IN pa_proj_fp_options.proj_fp_options_id%TYPE
                                      := FND_API.G_MISS_NUM
 ,p_record_version_number          IN NUMBER
                                                           := NULL
 ,p_row_id                         IN ROWID
                                                           := NULL
 ,x_return_status                 OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
  l_row_id ROWID;
BEGIN
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       SELECT rowid into l_row_id
         FROM pa_proj_fp_options
        WHERE proj_fp_options_id =  p_proj_fp_options_id
           OR rowid = p_row_id
          FOR UPDATE NOWAIT;

EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_PROJ_FP_OPTIONS_PKG'
                               ,p_procedure_name
                                    => 'Lock_Row');
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Lock_Row;

END pa_proj_fp_options_pkg;

/
