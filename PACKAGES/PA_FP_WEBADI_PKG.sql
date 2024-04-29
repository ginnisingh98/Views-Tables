--------------------------------------------------------
--  DDL for Package PA_FP_WEBADI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_WEBADI_PKG" AUTHID CURRENT_USER as
/* $Header: PAFPWAPS.pls 120.8 2006/07/10 12:52:51 psingara noship $ */

/* PL/SQL table type declaration */

         TYPE l_budget_line_id_tbl_typ IS TABLE OF
                pa_budget_lines.BUDGET_LINE_ID%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_budget_version_id_tbl_typ IS TABLE OF
                pa_budget_lines.BUDGET_VERSION_ID%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_project_id_tbl_typ IS TABLE OF
                pa_resource_assignments.PROJECT_ID%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_res_assignment_id_tbl_typ IS TABLE OF
                pa_resource_assignments.RESOURCE_ASSIGNMENT_ID%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_parent_assign_id_tbl_typ IS TABLE OF
                pa_resource_assignments.PARENT_ASSIGNMENT_ID%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_res_group_name_tbl_typ IS TABLE OF
                pa_resource_list_members.ALIAS%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_res_list_member_id_tbl_typ IS TABLE OF
                pa_resource_list_members.resource_list_member_id%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_resource_id_tbl_typ IS TABLE OF
                pa_resource_list_members.resource_id%TYPE INDEX BY BINARY_INTEGER  ;
         TYPE l_task_id_tbl_typ IS TABLE OF
                pa_tasks.task_id%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_res_alias_tbl_typ IS TABLE OF
                pa_resource_list_members.ALIAS%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_task_number_tbl_typ IS TABLE OF
                pa_tasks.TASK_NUMBER%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_start_date_tbl_typ IS TABLE OF
                pa_budget_lines.START_DATE%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_end_date_tbl_typ IS TABLE OF
                pa_budget_lines.END_DATE%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_amount_tbl_typ IS TABLE OF NUMBER INDEX BY BINARY_INTEGER ;
         TYPE l_burdened_cost_tbl_typ IS TABLE OF
                pa_budget_lines.BURDENED_COST%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_revenue_tbl_typ IS TABLE OF
                pa_budget_lines.REVENUE%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_quantity_tbl_typ IS TABLE OF
                pa_budget_lines.QUANTITY%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_txn_currency_code_tbl_typ IS TABLE OF
                pa_budget_lines.TXN_CURRENCY_CODE%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_delete_flag_tbl_typ IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER ;
         TYPE l_unit_of_measure_tbl_typ IS TABLE OF
                pa_resource_assignments.UNIT_OF_MEASURE%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_description_tbl_typ IS TABLE OF
                pa_budget_lines.DESCRIPTION%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_change_reason_code_tbl_typ IS TABLE OF
                pa_budget_lines.PERIOD_NAME%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_meaning_tbl_typ IS TABLE OF
                pa_lookups.meaning%TYPE  INDEX BY BINARY_INTEGER ;

         TYPE l_pf_cost_rate_type_tbl_typ IS TABLE OF
                pa_budget_lines.PROJFUNC_COST_RATE_TYPE%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_pf_cost_rt_dt_type_tbl_typ IS TABLE OF
                pa_budget_lines.PROJFUNC_COST_RATE_DATE_TYPE%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_pf_cost_exc_rate_tbl_typ IS TABLE OF
                pa_budget_lines.PROJFUNC_COST_EXCHANGE_RATE%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_pf_cost_rate_date_tbl_typ IS TABLE OF
                pa_budget_lines.PROJFUNC_COST_RATE_DATE%TYPE INDEX BY BINARY_INTEGER ;

         TYPE l_proj_cost_rate_type_tbl_typ IS TABLE OF
                pa_budget_lines.PROJECT_COST_RATE_TYPE%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_proj_cost_rt_dt_type_tbl_typ IS TABLE OF
                pa_budget_lines.PROJECT_COST_RATE_DATE_TYPE%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_proj_cost_exc_rate_tbl_typ IS TABLE OF
                pa_budget_lines.PROJECT_COST_EXCHANGE_RATE%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_proj_cost_rate_date_tbl_typ IS TABLE OF
                pa_budget_lines.PROJECT_COST_RATE_DATE%TYPE INDEX BY BINARY_INTEGER ;

         TYPE l_pf_rev_rate_type_tbl_typ IS TABLE OF
                pa_budget_lines.PROJFUNC_REV_RATE_TYPE%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_pf_rev_rt_dt_type_tbl_typ IS TABLE OF
                pa_budget_lines.PROJFUNC_REV_RATE_DATE_TYPE%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_pf_rev_exc_rate_tbl_typ IS TABLE OF
                pa_budget_lines.PROJFUNC_REV_EXCHANGE_RATE%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_pf_rev_rate_date_tbl_typ IS TABLE OF
                pa_budget_lines.PROJFUNC_REV_RATE_DATE%TYPE INDEX BY BINARY_INTEGER ;

         TYPE l_proj_rev_rate_type_tbl_typ IS TABLE OF
                pa_budget_lines.PROJECT_REV_RATE_TYPE%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_proj_rev_rt_dt_type_tbl_typ IS TABLE OF
                pa_budget_lines.PROJECT_REV_RATE_DATE_TYPE%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_proj_rev_exc_rate_tbl_typ IS TABLE OF
                pa_budget_lines.PROJECT_REV_EXCHANGE_RATE%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_proj_rev_rate_date_tbl_typ IS TABLE OF
                pa_budget_lines.PROJECT_REV_RATE_DATE%TYPE INDEX BY BINARY_INTEGER ;

         TYPE l_proj_currency_code_tbl_typ IS TABLE OF
                pa_budget_lines.PROJECT_CURRENCY_CODE%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_pf_currency_code_tbl_typ IS TABLE OF
                pa_budget_lines.PROJFUNC_CURRENCY_CODE%TYPE INDEX BY BINARY_INTEGER ;


         TYPE l_attribute_category_tbl_typ IS TABLE OF
                pa_budget_lines.ATTRIBUTE_CATEGORY%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_attribute_tbl_typ IS TABLE OF
                pa_budget_lines.ATTRIBUTE1%TYPE INDEX BY BINARY_INTEGER ;

         TYPE l_error_flag_tbl_typ IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER ;
         TYPE l_val_error_code_tbl_typ IS TABLE OF
                pa_lookups.LOOKUP_CODE%TYPE INDEX BY BINARY_INTEGER ;

         TYPE l_period_name_tbl_typ IS TABLE OF
                pa_budget_lines.PERIOD_NAME%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_bucketing_pd_code_tbl_typ IS TABLE OF
                pa_budget_lines.BUCKETING_PERIOD_CODE%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_pm_product_code_tbl_typ IS TABLE OF
                pa_budget_lines.PM_PRODUCT_CODE%TYPE INDEX BY BINARY_INTEGER ;

         TYPE l_raw_cost_source_tbl_typ IS TABLE OF
                pa_budget_lines.RAW_COST_SOURCE%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_burdened_cost_source_tbl_typ  IS TABLE OF
                pa_budget_lines.BURDENED_COST_SOURCE%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_quantity_source_tbl_typ IS TABLE OF
                pa_budget_lines.QUANTITY%TYPE INDEX BY BINARY_INTEGER ;
         TYPE l_revenue_source_tbl_typ IS TABLE OF
                pa_budget_lines.QUANTITY%TYPE INDEX BY BINARY_INTEGER ;

/* Bug 4431269: Added the record type gloabl variable.
 * Using the global variable for the calling reference makes
 * code changes and the subsequent impact very less as this variable would be only populated
 * in excel upload flow only before calling calculate api and would be cleared away once the call
 * to calculate api is over. This approach also get rid of the problem of introducing any new additional
 * parameter to calculate api.

 * The valid value for the attributes G_FP_WA_CALC_CALLING_CONTEXT is 'WEBADI_CALCULATE'
 * If calculate api throws some validation error, then if the global variable has the value of
 * 'WEBADI_CALCULATE', then a call to process_errors would be made to update the interface table
 *  with appropriate error code for the validation failure agains the corresponding invalid records.
 */

 G_FP_WA_CALC_CALLING_CONTEXT        VARCHAR2(30);

 TYPE G_FP_WA_GLOBAL_VAR_REC IS RECORD
 (
    task_id            pa_resource_assignments.task_id%TYPE,
    rlm_id             pa_resource_assignments.resource_list_member_id%TYPE,
    txn_currency       pa_budget_lines.txn_currency_code%TYPE,
    error_code         pa_fp_webadi_upload_inf.val_error_code%TYPE
 );

 TYPE G_FP_WEBADI_GLOBAL IS TABLE OF G_FP_WA_GLOBAL_VAR_REC;

 g_fp_webadi_rec_tbl    G_FP_WEBADI_GLOBAL := G_FP_WEBADI_GLOBAL();

 /* Start of changes done for Bug : 4584865*/

--Cursor based on Global Temporay Table pa_fp_webadi_xface_tmp.
 CURSOR global_tmp_cur
 IS
 SELECT * FROM pa_fp_webadi_xface_tmp;
--Record based on Global Temporay Table pa_fp_webadi_xface_tmp.
-- l_global_tmp_rec   pa_fp_webadi_xface_tmp%ROWTYPE; --Bug 5284640.
--Table based on Cursor global_tmp_cur.
 TYPE global_tmp_tbl IS TABLE OF global_tmp_cur%ROWTYPE;
 l_global_tmp_tbl   global_tmp_tbl;
-- Bug 5284640 : Commented out the below variables.
/*
 l_position   NUMBER := 0;
 l_return   NUMBER := 0;
*/
/*End of Changes done for Bug : 4584865*/

PROCEDURE delete_xface
                  ( p_run_id               IN   pa_fp_webadi_upload_inf.run_id%TYPE
                   ,x_return_status        OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                   ,x_msg_count            OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
                   ,x_msg_data             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                   ,p_calling_module       IN   VARCHAR2  DEFAULT NULL
                  );

  -- Bug 3986129: FP.M Web ADI Dev changes. Added the following procedures
  Procedure validate_header_info
    ( p_calling_mode              IN           VARCHAR2  DEFAULT NULL,
      p_run_id                    IN           pa_fp_webadi_upload_inf.run_id%TYPE,
      p_budget_version_id         IN           pa_budget_versions.budget_version_id%TYPE,
      p_record_version_number     IN           pa_budget_versions.record_version_number%TYPE,
      p_pm_rec_version_number     IN           pa_period_masks_b.record_version_number%TYPE,
      p_submit_flag               IN           VARCHAR2,
      p_request_id                IN           pa_budget_versions.request_id%TYPE,
      x_return_status             OUT          NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_msg_data                  OUT          NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_msg_count                 OUT          NOCOPY NUMBER); --File.Sql.39 bug 4440895

  PROCEDURE process_errors
    ( p_run_id             IN           pa_fp_webadi_upload_inf.run_id%TYPE ,
      p_context            IN           VARCHAR2                           DEFAULT NULL,
      p_periodic_flag      IN           VARCHAR2                           DEFAULT NULL,
      p_error_code_tbl     IN           SYSTEM.PA_VARCHAR2_30_TBL_TYPE     DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE(),
      p_task_id_tbl        IN           SYSTEM.PA_NUM_TBL_TYPE             DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
      p_rlm_id_tbl         IN           SYSTEM.PA_NUM_TBL_TYPE             DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
      p_txn_curr_tbl       IN           SYSTEM.PA_VARCHAR2_30_TBL_TYPE     DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE(),
      p_amount_type_tbl    IN           SYSTEM.PA_VARCHAR2_30_TBL_TYPE     DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE(),
      p_request_id         IN           pa_budget_versions.request_id%TYPE DEFAULT NULL,
      x_return_status      OUT          NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_msg_data           OUT          NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_msg_count          OUT          NOCOPY NUMBER); --File.Sql.39 bug 4440895

  PROCEDURE process_budget_lines
    ( p_context                         IN              VARCHAR2,
      p_budget_version_id               IN              pa_budget_versions.budget_version_id%TYPE,
      p_version_info_rec                IN              pa_fp_gen_amount_utils.fp_cols,
      p_task_id_tbl                     IN              SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type(),
      p_rlm_id_tbl                      IN              SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type(),
      p_ra_id_tbl                       IN              SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type(),
      p_spread_curve_id_tbl             IN              SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type(),
      p_mfc_cost_type_id_tbl            IN              SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type(),
      p_etc_method_code_tbl             IN              SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type(),
      p_sp_fixed_date_tbl               IN              SYSTEM.pa_date_tbl_type          DEFAULT SYSTEM.pa_date_tbl_type(),
      p_res_class_code_tbl              IN              SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type(),
      p_rate_based_flag_tbl             IN              SYSTEM.pa_varchar2_1_tbl_type    DEFAULT SYSTEM.pa_varchar2_1_tbl_type(),
      p_rbs_elem_id_tbl                 IN              SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type(),
      p_txn_currency_code_tbl           IN              SYSTEM.pa_varchar2_15_tbl_type   DEFAULT SYSTEM.pa_varchar2_15_tbl_type(),
      p_planning_start_date_tbl         IN              SYSTEM.pa_date_tbl_type          DEFAULT SYSTEM.pa_date_tbl_type(),
      p_planning_end_date_tbl           IN              SYSTEM.pa_date_tbl_type          DEFAULT SYSTEM.pa_date_tbl_type(),
      p_total_qty_tbl                   IN              SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type(),
      p_total_raw_cost_tbl              IN              SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type(),
      p_total_burdened_cost_tbl         IN              SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type(),
      p_total_revenue_tbl               IN              SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type(),
      p_raw_cost_rate_tbl               IN              SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type(),
      p_burdened_cost_rate_tbl          IN              SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type(),
      p_bill_rate_tbl                   IN              SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type(),
      p_line_start_date_tbl             IN              SYSTEM.pa_date_tbl_type          DEFAULT SYSTEM.pa_date_tbl_type(),
      p_line_end_date_tbl               IN              SYSTEM.pa_date_tbl_type          DEFAULT SYSTEM.pa_date_tbl_type(),
      p_proj_cost_rate_type_tbl         IN              SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type(),
      p_proj_cost_rate_date_type_tbl    IN              SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type(),
      p_proj_cost_rate_tbl              IN              SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type(),
      p_proj_cost_rate_date_tbl         IN              SYSTEM.pa_date_tbl_type          DEFAULT SYSTEM.pa_date_tbl_type(),
      p_proj_rev_rate_type_tbl          IN              SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type(),
      p_proj_rev_rate_date_type_tbl     IN              SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type(),
      p_proj_rev_rate_tbl               IN              SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type(),
      p_proj_rev_rate_date_tbl          IN              SYSTEM.pa_date_tbl_type          DEFAULT SYSTEM.pa_date_tbl_type(),
      p_pfunc_cost_rate_type_tbl        IN              SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type(),
      p_pfunc_cost_rate_date_typ_tbl    IN              SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type(),
      p_pfunc_cost_rate_tbl             IN              SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type(),
      p_pfunc_cost_rate_date_tbl        IN              SYSTEM.pa_date_tbl_type          DEFAULT SYSTEM.pa_date_tbl_type(),
      p_pfunc_rev_rate_type_tbl         IN              SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type(),
      p_pfunc_rev_rate_date_type_tbl    IN              SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type(),
      p_pfunc_rev_rate_tbl              IN              SYSTEM.pa_num_tbl_type           DEFAULT SYSTEM.pa_num_tbl_type(),
      p_pfunc_rev_rate_date_tbl         IN              SYSTEM.pa_date_tbl_type          DEFAULT SYSTEM.pa_date_tbl_type(),
      p_change_reason_code_tbl          IN              SYSTEM.pa_varchar2_30_tbl_type   DEFAULT SYSTEM.pa_varchar2_30_tbl_type(),
      p_description_tbl                 IN              SYSTEM.pa_varchar2_2000_tbl_type DEFAULT SYSTEM.pa_varchar2_2000_tbl_type(),
      p_delete_flag_tbl                 IN              SYSTEM.pa_varchar2_1_tbl_type    DEFAULT SYSTEM.pa_varchar2_1_tbl_type(),
      x_return_status                   OUT             NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_msg_count                       OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
      x_msg_data                        OUT             NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


PROCEDURE switcher
(x_return_status                OUT                NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                    OUT                NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                     OUT                NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_submit_budget_flag           IN                 VARCHAR2       DEFAULT  'N',
 p_run_id                       IN                 pa_fp_webadi_upload_inf.run_id%TYPE,
 x_success_msg                  OUT                NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_submit_forecast_flag         IN                 VARCHAR2       DEFAULT  'N',
 p_request_id                   IN                 pa_budget_versions.request_id%TYPE   DEFAULT NULL,
 p_calling_mode                 IN                 VARCHAR2       DEFAULT  'STANDARD'
 );

  -- Bug 3986129: FP.M Web ADI Dev changes

--This API will be called when thru the concurrent request that will be used to upload MS excel data to
--Oracle Applications.
PROCEDURE process_MSExcel_data
(errbuf                      OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 retcode                     OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_submit_ver_flag           IN     VARCHAR2,
 p_run_id                    IN     pa_fp_webadi_upload_inf.run_id%TYPE);

 --Bug 4584865.
 --This API is called to insert records into pa_fp_webadi_xface_tmp
 --during downloading budget line details into excel spreadsheet.
 PROCEDURE insert_periodic_tmp_table(p_budget_version_id  IN pa_budget_versions.budget_version_id%TYPE,
                            x_return_status      OUT NOCOPY VARCHAR2,
                            x_msg_count          OUT NOCOPY NUMBER,
                            x_msg_data           OUT NOCOPY VARCHAR2);

END pa_fp_webadi_pkg;

 

/
