--------------------------------------------------------
--  DDL for Package Body PA_FP_WP_GEN_BUDGET_AMT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_WP_GEN_BUDGET_AMT_PUB" as
/* $Header: PAFPWPGB.pls 120.13.12010000.4 2009/12/29 10:58:29 kmaddi ship $ */
P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE GENERATE_WP_BUDGET_AMT
          (P_PROJECT_ID                   IN           PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID            IN           PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_PLAN_CLASS_CODE              IN           PA_FIN_PLAN_TYPES_B.PLAN_CLASS_CODE%TYPE,
           P_GEN_SRC_CODE                 IN           PA_PROJ_FP_OPTIONS.GEN_ALL_SRC_CODE%TYPE,
           P_COST_PLAN_TYPE_ID            IN           PA_PROJ_FP_OPTIONS.GEN_SRC_COST_PLAN_TYPE_ID%TYPE,
           P_COST_VERSION_ID              IN           PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_RETAIN_MANUAL_FLAG           IN           VARCHAR2,
           P_CALLED_MODE                  IN           VARCHAR2,
           P_INC_CHG_DOC_FLAG             IN           VARCHAR2,
           P_INC_BILL_EVENT_FLAG          IN           VARCHAR2,
           P_INC_OPEN_COMMIT_FLAG         IN           VARCHAR2,
           P_CI_ID_TAB                    IN           PA_PLSQL_DATATYPES.IdTabTyp,
           P_INIT_MSG_FLAG                IN           VARCHAR2,
           P_COMMIT_FLAG                  IN           VARCHAR2,
           P_CALLING_CONTEXT              IN           VARCHAR2,
           P_ETC_PLAN_TYPE_ID             IN           PA_PROJ_FP_OPTIONS.FIN_PLAN_TYPE_ID%TYPE,
           P_ETC_PLAN_VERSION_ID          IN           PA_PROJ_FP_OPTIONS.FIN_PLAN_VERSION_ID%TYPE,
           P_ETC_PLAN_VERSION_NAME        IN           PA_BUDGET_VERSIONS.VERSION_NAME%TYPE,
           P_ACTUALS_THRU_DATE            IN           PA_PERIODS_ALL.END_DATE%TYPE,
           PX_DELETED_RES_ASG_ID_TAB      IN  OUT NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp,
           PX_GEN_RES_ASG_ID_TAB          IN  OUT NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp,
           X_RETURN_STATUS                OUT NOCOPY   VARCHAR2,
           X_MSG_COUNT                    OUT NOCOPY   NUMBER,
           X_MSG_DATA                     OUT NOCOPY   VARCHAR2)
IS
    l_module_name VARCHAR2(100) := 'pa.plsql.PA_FP_WP_GEN_BUDGET_AMT_PUB.GENERATE_WP_BUDGET_AMT';
    l_fp_cols_rec_source           PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
    l_fp_cols_rec_target           PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
    l_wp_ptype_id                  Number;
    l_wp_status                    VARCHAR2(20);
    l_wp_id                        Number := NULL;
    l_source_id                    Number;
    l_gen_src_code                 VARCHAR2(100);
    l_gen_src_plan_ver_code        VARCHAR2(100);
    l_proj_resource_id             PA_PLSQL_DATATYPES.IdTabTyp;

    /* Source Code constants */
    lc_WorkPlanSrcCode             CONSTANT PA_PROJ_FP_OPTIONS.GEN_COST_SRC_CODE%TYPE
                                       := 'WORKPLAN_RESOURCES';
    lc_FinancialPlanSrcCode        CONSTANT PA_PROJ_FP_OPTIONS.GEN_COST_SRC_CODE%TYPE
                                       := 'FINANCIAL_PLAN';

    l_fp_options_id                pa_proj_fp_options.proj_fp_options_id%TYPE;
    l_gen_src_plan_ver_cod         VARCHAR2(100);
    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(2000);
    l_data                         VARCHAR2(2000);
    l_msg_index_out                NUMBER;

    l_stru_sharing_code            pa_projects_all.STRUCTURE_SHARING_CODE%TYPE;

    /* Flag parameters for calling Calculate API */
    l_calculate_api_code           VARCHAR2(30);
    l_refresh_rates_flag           VARCHAR2(1);
    l_refresh_conv_rates_flag      VARCHAR2(1);
    l_spread_required_flag         VARCHAR2(1);
    l_conv_rates_required_flag     VARCHAR2(1);
    l_rollup_required_flag         VARCHAR2(1);
    l_raTxn_rollup_api_call_flag   VARCHAR2(1); -- Added for IPM new entity ER

    /* Local PL/SQL table used for calling Calculate API */
    l_source_context               pa_fp_res_assignments_tmp.source_context%TYPE :='RESOURCE_ASSIGNMENT';
    l_delete_budget_lines_tab      SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
    l_spread_amts_flag_tab         SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
    l_txn_currency_code_tab        SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();
    l_txn_currency_override_tab    SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();
    l_addl_qty_tab                 SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_src_raw_cost_tab             SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_addl_raw_cost_tab            SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_src_brdn_cost_tab            SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_addl_burdened_cost_tab       SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_src_revenue_tab              SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_addl_revenue_tab             SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_raw_cost_rate_tab            SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_b_cost_rate_tab              SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_b_cost_rate_override_tab     SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_bill_rate_tab                SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_line_start_date_tab          SYSTEM.pa_date_tbl_type:=SYSTEM.pa_date_tbl_type();
    l_line_end_date_tab            SYSTEM.pa_date_tbl_type:=SYSTEM.pa_date_tbl_type();

    l_tgt_res_asg_id_tab           SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_tgt_rate_based_flag_tab      SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
    l_start_date_tab               pa_plsql_datatypes.DateTabTyp;
    l_txn_currency_code            pa_plsql_datatypes.Char15TabTyp;
    l_end_date_tab                 pa_plsql_datatypes.DateTabTyp;
    l_periiod_name_tab             pa_plsql_datatypes.Char30TabTyp;
    l_cost_rate_override_tab       SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_bill_rate_override_tab       SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_src_quantity_tab             SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();

    l_sysdate_trunc                DATE;
    l_txn_currency_flag            VARCHAR2(1) := 'Y';

    -- Bug 4115015: We should not query the cost/revenue amount columns
    -- directly since they store rounded amounts, whereas we need unrounded
    -- amounts to accurately compute override rates. Instead, we should
    -- multiply the quantity by appropriate rate multipliers to compute
    -- the unrounded cost/revenue amounts.

    -- ER 4376722: To carry out the Task Billability logic, we need to
    -- modify the cursors to fetch the task billable_flag for each target
    -- resource. Since ra.task_id can be NULL or 0, we take the outer
    -- join: NVL(ra.task_id,0) = ta.task_id (+). By default, tasks are
    -- billable, so we SELECT NVL(ta.billable_flag,'Y').

    /*when multi currency is not enabled, then take project currency and amts,
      when multi currency is enabled, then take transaction currency and amts,
      when target is approved budget version, then take projfunc currency and amts.
      Don't pick up amounts for budget lines with non-null rejection codes. */
    CURSOR budget_line_src_to_cal
        (c_proj_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE ,
         c_projfunc_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE) IS

    SELECT /*+ INDEX(tmp4,PA_RES_LIST_MAP_TMP4_N2)*/
           ra.resource_assignment_id,
           ra.rate_based_flag,
           decode(l_txn_currency_flag,
                  'Y', sbl.txn_currency_code,
                  'N', c_proj_currency_code,
                  'A', c_projfunc_currency_code),
           sum(quantity),
           /*
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.quantity *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate),   --sbl.txn_raw_cost
                      'N', sbl.quantity * NVL(sbl.project_cost_exchange_rate,1) *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate),   --sbl.project_raw_cost
                      'A', sbl.quantity * NVL(sbl.projfunc_cost_exchange_rate,1) *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate))), --sbl.raw_cost
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.quantity *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate),   --sbl.txn_burdened_cost
                      'N', sbl.quantity * NVL(sbl.project_cost_exchange_rate,1) *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate),   --sbl.project_burdened_cost
                      'A', sbl.quantity * NVL(sbl.projfunc_cost_exchange_rate,1) *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate))), --sbl.burdened_cost
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.quantity *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate),   --sbl.txn_revenue
                      'N', sbl.quantity * NVL(sbl.project_cost_exchange_rate,1) *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate),   --sbl.project_revenue
                      'A', sbl.quantity * NVL(sbl.projfunc_cost_exchange_rate,1) *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate))), --sbl.revenue */
           -- Bug 8937993. Need to pull use source rates for only the plannned quantity.
           sum(decode(l_txn_currency_flag,
                      'Y', (((sbl.quantity - nvl(sbl.init_quantity,0)) *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate))
                           + NVL(sbl.txn_init_raw_cost,0)),   																							--sbl.txn_raw_cost
                      'N', ((((sbl.quantity - nvl(sbl.init_quantity,0)) *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate))
                           + NVL(sbl.txn_init_raw_cost,0)) * NVL(sbl.project_cost_exchange_rate,1)) ,   		--sbl.project_raw_cost
                      'A', ((((sbl.quantity - nvl(sbl.init_quantity,0)) *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate))
                           + NVL(sbl.txn_init_raw_cost,0)) * NVL(sbl.projfunc_cost_exchange_rate,1))
                           )), 																																							--sbl.raw_cost
           sum(decode(l_txn_currency_flag,
                      'Y', (((sbl.quantity - nvl(sbl.init_quantity,0)) *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate))
                           + NVL(sbl.txn_init_burdened_cost,0)),   																					--sbl.txn_burdened_cost
                      'N', ((((sbl.quantity - nvl(sbl.init_quantity,0))  *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate))
                           + NVL(sbl.txn_init_burdened_cost,0)) * NVL(sbl.project_cost_exchange_rate,1)),   --sbl.project_burdened_cost
                      'A', ((((sbl.quantity - nvl(sbl.init_quantity,0)) *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate))
                           + NVL(sbl.txn_init_burdened_cost,0)) * NVL(sbl.projfunc_cost_exchange_rate,1))
                           )), 																																							 --sbl.burdened_cost
           sum(decode(l_txn_currency_flag,
                      'Y', (((sbl.quantity - nvl(sbl.init_quantity,0)) *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate))
                           + NVL(sbl.txn_init_revenue,0)),   																								 --sbl.txn_revenue
                      'N', ((((sbl.quantity - nvl(sbl.init_quantity,0)) *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate))
                           + NVL(sbl.txn_init_revenue,0)) * NVL(sbl.project_cost_exchange_rate,1)) ,   			 --sbl.project_revenue
                      'A', ((((sbl.quantity - nvl(sbl.init_quantity,0))  *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate))
                           + NVL(sbl.txn_init_revenue,0)) * NVL(sbl.projfunc_cost_exchange_rate,1))
                           )),
           NULL,
           NULL,
           NULL,
           NVL(ta.billable_flag,'Y')                       /* Added for ER 4376722 */
    FROM pa_res_list_map_tmp4 tmp4,
         pa_budget_lines sbl,
         pa_resource_assignments ra,
         pa_tasks ta                                       /* Added for ER 4376722 */
    WHERE tmp4.txn_source_id = sbl.resource_assignment_id
          and sbl.budget_version_id = l_source_id
          and tmp4.txn_resource_assignment_id = ra.resource_assignment_id
          and ra.budget_version_id = p_budget_version_id
          and sbl.cost_rejection_code is null
          and sbl.revenue_rejection_code is null
          and sbl.burden_rejection_code is null
          and sbl.other_rejection_code is null
          and sbl.pc_cur_conv_rejection_code is null
          and sbl.pfc_cur_conv_rejection_code is null
          and NVL(ra.task_id,0) = ta.task_id (+)           /* Added for ER 4376722 */
          --and ta.project_id = P_PROJECT_ID               /* Added for ER 4376722 */
          and ra.project_id = P_PROJECT_ID                 /* Added for Bug 4543795 */
    GROUP BY ra.resource_assignment_id,
             ra.rate_based_flag,
             decode(l_txn_currency_flag,
                  'Y', sbl.txn_currency_code,
                  'N', c_proj_currency_code,
                  'A', c_projfunc_currency_code),
             NULL,
             NULL,
             NULL,
             NVL(ta.billable_flag,'Y');                    /* Added for ER 4376722 */

      /* Added for bug #4938603 */
       CURSOR fcst_bdgt_line_actual_qty
           (c_res_asgn_id       PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE,
            c_txn_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE
           ) IS
       SELECT sum(nvl(init_quantity,0))
         FROM pa_budget_lines
        WHERE resource_assignment_id = c_res_asgn_id
          AND txn_currency_code = c_txn_currency_code;

       l_total_plan_qty               NUMBER;
       l_init_qty                     NUMBER;

    /* String constants for valid Calling Context values */
    lc_BudgetGeneration            CONSTANT VARCHAR2(30) := 'BUDGET_GENERATION';
    lc_ForecastGeneration          CONSTANT VARCHAR2(30) := 'FORECAST_GENERATION';

    /* Local copy of the Calling Context that will be checked instead of p_calling_context */
    l_calling_context              VARCHAR2(30);

    /* Pro-rate API variables */
    l_mapped_src_res_asg_id_tab    PA_PLSQL_DATATYPES.IdTabTyp;
    l_prorated_quantity            PA_BUDGET_LINES.QUANTITY%TYPE;
    l_prorated_txn_raw_cost        PA_BUDGET_LINES.TXN_RAW_COST%TYPE;
    l_prorated_txn_burdened_cost   PA_BUDGET_LINES.TXN_BURDENED_COST%TYPE;
    l_prorated_txn_revenue         PA_BUDGET_LINES.TXN_REVENUE%TYPE;
    l_prorated_proj_raw_cost       PA_BUDGET_LINES.PROJECT_RAW_COST%TYPE;
    l_prorated_proj_burdened_cost  PA_BUDGET_LINES.PROJECT_BURDENED_COST%TYPE;
    l_prorated_proj_revenue        PA_BUDGET_LINES.PROJECT_REVENUE%TYPE;

    /* This cursor is the revenue forecast generation analogue of the cursor
     * budget_line_src_to_cal. As such, changes to that cursor should likely be
     * mirorred here. See comments above the other cursor for more info.
     * This cursor differs from the other one in that it only picks up source
     * data with starting date after the forecast's actuals through period. */
    CURSOR fcst_budget_line_src_to_cal
        (c_proj_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE,
         c_projfunc_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE,
         c_src_time_phased_code PA_PROJ_FP_OPTIONS.COST_TIME_PHASED_CODE%TYPE) IS
    SELECT /*+ INDEX(tmp4,PA_RES_LIST_MAP_TMP4_N2)*/
           ra.resource_assignment_id,
           ra.rate_based_flag,
           decode(l_txn_currency_flag,
                  'Y', sbl.txn_currency_code,
                  'N', c_proj_currency_code,
                  'A', c_projfunc_currency_code),
           sum(quantity),
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.quantity *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate),   --sbl.txn_raw_cost
                      'N', sbl.quantity * NVL(sbl.project_cost_exchange_rate,1) *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate),   --sbl.project_raw_cost
                      'A', sbl.quantity * NVL(sbl.projfunc_cost_exchange_rate,1) *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate))), --sbl.raw_cost
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.quantity *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate),   --sbl.txn_burdened_cost
                      'N', sbl.quantity * NVL(sbl.project_cost_exchange_rate,1) *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate),   --sbl.project_burdened_cost
                      'A', sbl.quantity * NVL(sbl.projfunc_cost_exchange_rate,1) *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate))), --sbl.burdened_cost
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.quantity *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate),   --sbl.txn_revenue
                      'N', sbl.quantity * NVL(sbl.project_cost_exchange_rate,1) *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate),   --sbl.project_revenue
                      'A', sbl.quantity * NVL(sbl.projfunc_cost_exchange_rate,1) *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate))), --sbl.revenue
           NULL,
           NULL,
           NULL,
           NVL(ta.billable_flag,'Y')                       /* Added for ER 4376722 */
    FROM pa_res_list_map_tmp4 tmp4,
         pa_budget_lines sbl,
         pa_resource_assignments ra,
         pa_tasks ta                                       /* Added for ER 4376722 */
    WHERE tmp4.txn_source_id = sbl.resource_assignment_id
          and sbl.budget_version_id = l_source_id
          and tmp4.txn_resource_assignment_id = ra.resource_assignment_id
          and ra.budget_version_id = p_budget_version_id
          and sbl.start_date > decode( c_src_time_phased_code,
                                       'N', sbl.start_date-1, P_ACTUALS_THRU_DATE )
          and sbl.cost_rejection_code is null
          and sbl.revenue_rejection_code is null
          and sbl.burden_rejection_code is null
          and sbl.other_rejection_code is null
          and sbl.pc_cur_conv_rejection_code is null
          and sbl.pfc_cur_conv_rejection_code is null
          and NVL(ra.task_id,0) = ta.task_id (+)           /* Added for ER 4376722 */
          --and ta.project_id = P_PROJECT_ID               /* Added for ER 4376722 */
          and ra.project_id = P_PROJECT_ID                 /* Added for Bug 4543795 */
    GROUP BY ra.resource_assignment_id,
             ra.rate_based_flag,
             decode(l_txn_currency_flag,
                  'Y', sbl.txn_currency_code,
                  'N', c_proj_currency_code,
                  'A', c_projfunc_currency_code),
             NULL,
             NULL,
             NULL,
             NVL(ta.billable_flag,'Y');                    /* Added for ER 4376722 */

    -- Bug 4192970: Added extra cursor for Forecast Generation context when
    -- Source time phasing is None. When Source time phasing is PA or GL,
    -- use the fcst_budget_line_src_to_cal cursor. For more comments/details,
    -- please see the other cursor.
    CURSOR fcst_bdgt_line_src_to_cal_none
        (c_proj_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE,
         c_projfunc_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE,
         c_src_time_phased_code PA_PROJ_FP_OPTIONS.COST_TIME_PHASED_CODE%TYPE) IS
    SELECT /*+ INDEX(tmp4,PA_RES_LIST_MAP_TMP4_N2)*/
           ra.resource_assignment_id,
           ra.rate_based_flag,
           decode(l_txn_currency_flag,
                  'Y', sbl.txn_currency_code,
                  'N', c_proj_currency_code,
                  'A', c_projfunc_currency_code),
           sum(sbl.quantity-NVL(sbl.init_quantity,0)),
           sum(decode(l_txn_currency_flag,
                      'Y', (sbl.quantity-NVL(sbl.init_quantity,0)) *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate),   --sbl.txn_raw_cost
                      'N', (sbl.quantity-NVL(sbl.init_quantity,0)) * NVL(sbl.project_cost_exchange_rate,1) *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate),   --sbl.project_raw_cost
                      'A', (sbl.quantity-NVL(sbl.init_quantity,0)) * NVL(sbl.projfunc_cost_exchange_rate,1) *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate))), --sbl.raw_cost
           sum(decode(l_txn_currency_flag,
                      'Y', (sbl.quantity-NVL(sbl.init_quantity,0)) *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate),   --sbl.txn_burdened_cost
                      'N', (sbl.quantity-NVL(sbl.init_quantity,0)) * NVL(sbl.project_cost_exchange_rate,1) *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate),   --sbl.project_burdened_cost
                      'A', (sbl.quantity-NVL(sbl.init_quantity,0)) * NVL(sbl.projfunc_cost_exchange_rate,1) *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate))), --sbl.burdened_cost
           sum(decode(l_txn_currency_flag,
                      'Y', (sbl.quantity-NVL(sbl.init_quantity,0)) *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate),   --sbl.txn_revenue
                      'N', (sbl.quantity-NVL(sbl.init_quantity,0)) * NVL(sbl.project_cost_exchange_rate,1) *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate),   --sbl.project_revenue
                      'A', (sbl.quantity-NVL(sbl.init_quantity,0)) * NVL(sbl.projfunc_cost_exchange_rate,1) *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate))), --sbl.revenue
           NULL,
           NULL,
           NULL,
           NVL(ta.billable_flag,'Y')                       /* Added for ER 4376722 */
    FROM pa_res_list_map_tmp4 tmp4,
         pa_budget_lines sbl,
         pa_resource_assignments ra,
         pa_tasks ta                                       /* Added for ER 4376722 */
    WHERE tmp4.txn_source_id = sbl.resource_assignment_id
          and sbl.budget_version_id = l_source_id
          and tmp4.txn_resource_assignment_id = ra.resource_assignment_id
          and ra.budget_version_id = p_budget_version_id
          and sbl.cost_rejection_code is null
          and sbl.revenue_rejection_code is null
          and sbl.burden_rejection_code is null
          and sbl.other_rejection_code is null
          and sbl.pc_cur_conv_rejection_code is null
          and sbl.pfc_cur_conv_rejection_code is null
          and NVL(sbl.quantity,0) <> NVL(sbl.init_quantity,0)
          and NVL(ra.task_id,0) = ta.task_id (+)           /* Added for ER 4376722 */
          --and ta.project_id = P_PROJECT_ID               /* Added for ER 4376722 */
          and ra.project_id = P_PROJECT_ID                 /* Added for Bug 4543795 */
    GROUP BY ra.resource_assignment_id,
             ra.rate_based_flag,
             decode(l_txn_currency_flag,
                  'Y', sbl.txn_currency_code,
                  'N', c_proj_currency_code,
                  'A', c_projfunc_currency_code),
             NULL,
             NULL,
             NULL,
             NVL(ta.billable_flag,'Y');                    /* Added for ER 4376722 */

    l_res_class_id_tab             pa_plsql_datatypes.IdTabTyp;
    l_res_asg_id_tmp_tab           pa_plsql_datatypes.IdTabTyp;
    l_res_class_code_tab           PA_PLSQL_DATATYPES.Char30TabTyp;
    l_count number;
    l_count1 number;
    l_count2 number;

    l_versioning_enabled           varchar2(10);
    l_version_type                 varchar2(50);

    l_rev_gen_method               VARCHAR2(3);
    l_res_asg_uom_update_tab       pa_plsql_datatypes.IdTabTyp;

    l_wp_track_cost_flag           VARCHAR2(1);
    tmp_flag                       varchar2(1);
    tmp_rlm_tab                    pa_plsql_datatypes.IdTabTyp;
    tmp_task_tab                   pa_plsql_datatypes.IdTabTyp;
    tmp_ra_tab                     pa_plsql_datatypes.IdTabTyp;
    l_uncategorized_flag           pa_resource_lists_all_bg.uncategorized_flag%type;

    l_appr_cost_plan_type_flag     PA_BUDGET_VERSIONS.APPROVED_COST_PLAN_TYPE_FLAG%TYPE;
    l_appr_rev_plan_type_flag      PA_BUDGET_VERSIONS.APPROVED_COST_PLAN_TYPE_FLAG%TYPE;
    l_source_version_type          PA_BUDGET_VERSIONS.VERSION_TYPE%TYPE;
    l_target_version_type          PA_BUDGET_VERSIONS.VERSION_TYPE%TYPE;
    l_dummy                        NUMBER;

    --Local pl/sql table to call Map_Rlmi_Rbs api
    l_TXN_SOURCE_ID_tab            PA_PLSQL_DATATYPES.IdTabTyp;
    l_TXN_SOURCE_TYPE_CODE_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
    l_PERSON_ID_tab                PA_PLSQL_DATATYPES.IdTabTyp;
    l_JOB_ID_tab                   PA_PLSQL_DATATYPES.IdTabTyp;
    l_ORGANIZATION_ID_tab          PA_PLSQL_DATATYPES.IdTabTyp;
    l_VENDOR_ID_tab                PA_PLSQL_DATATYPES.IdTabTyp;
    l_EXPENDITURE_TYPE_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
    l_EVENT_TYPE_tab               PA_PLSQL_DATATYPES.Char30TabTyp;
    l_NON_LABOR_RESOURCE_tab       PA_PLSQL_DATATYPES.Char20TabTyp;
    l_EXPENDITURE_CATEGORY_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
    l_REVENUE_CATEGORY_CODE_tab    PA_PLSQL_DATATYPES.Char30TabTyp;
    l_NLR_ORGANIZATION_ID_tab      PA_PLSQL_DATATYPES.IdTabTyp;
    l_EVENT_CLASSIFICATION_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
    l_SYS_LINK_FUNCTION_tab        PA_PLSQL_DATATYPES.Char30TabTyp;
    l_PROJECT_ROLE_ID_tab          PA_PLSQL_DATATYPES.IdTabTyp;
    l_RESOURCE_CLASS_CODE_tab      PA_PLSQL_DATATYPES.Char30TabTyp;
    l_MFC_COST_TYPE_ID_tab         PA_PLSQL_DATATYPES.IDTabTyp;
    l_RESOURCE_CLASS_FLAG_tab      PA_PLSQL_DATATYPES.Char1TabTyp;
    l_FC_RES_TYPE_CODE_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
    l_INVENTORY_ITEM_ID_tab        PA_PLSQL_DATATYPES.IDTabTyp;
    l_ITEM_CATEGORY_ID_tab         PA_PLSQL_DATATYPES.IDTabTyp;
    l_PERSON_TYPE_CODE_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
    l_BOM_RESOURCE_ID_tab          PA_PLSQL_DATATYPES.IDTabTyp;
    l_NAMED_ROLE_tab               PA_PLSQL_DATATYPES.Char80TabTyp;
    l_INCURRED_BY_RES_FLAG_tab     PA_PLSQL_DATATYPES.Char1TabTyp;
    l_RATE_BASED_FLAG_tab          PA_PLSQL_DATATYPES.Char1TabTyp;
    l_TXN_TASK_ID_tab              PA_PLSQL_DATATYPES.IdTabTyp;
    l_TXN_WBS_ELEMENT_VER_ID_tab   PA_PLSQL_DATATYPES.IdTabTyp;
    l_TXN_RBS_ELEMENT_ID_tab       PA_PLSQL_DATATYPES.IdTabTyp;
    l_TXN_PLAN_START_DATE_tab      PA_PLSQL_DATATYPES.DateTabTyp;
    l_TXN_PLAN_END_DATE_tab        PA_PLSQL_DATATYPES.DateTabTyp;

    --out param from PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS
    l_map_txn_source_id_tab        PA_PLSQL_DATATYPES.IdTabTyp;
    l_map_rlm_id_tab               PA_PLSQL_DATATYPES.IdTabTyp;
    l_map_rbs_element_id_tab       PA_PLSQL_DATATYPES.IdTabTyp;
    l_map_txn_accum_header_id_tab  PA_PLSQL_DATATYPES.IdTabTyp;

    l_etc_start_date               DATE;

    l_calc_qty_tmp     NUMBER;
    l_calc_tmp_rev     NUMBER;

    /* Bug 3968748: PL/SQL tables for populating PA_FP_GEN_RATE_TMP */
    l_nrb_ra_id_tab                PA_PLSQL_DATATYPES.IdTabTyp;
    l_nrb_txn_curr_code_tab        PA_PLSQL_DATATYPES.Char30TabTyp;
    l_nrb_bcost_rate_tab           PA_PLSQL_DATATYPES.NumTabTyp;
    l_nrb_rcost_rate_tab           PA_PLSQL_DATATYPES.NumTabTyp;
    l_index                        NUMBER;

    /* Variables Added for ER 4376722 */
    l_billable_flag_tab            SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();

    -- This index is used to track the running index of the _tmp_ tables
    l_tmp_index                    NUMBER;

    -- These _tmp_ tables will be used for removing non-billable tasks.
    l_tmp_tgt_res_asg_id_tab       SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_tmp_tgt_rate_based_flag_tab  SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
    l_tmp_txn_currency_code_tab    SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();
    l_tmp_src_quantity_tab         SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_tmp_src_raw_cost_tab         SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_tmp_src_brdn_cost_tab        SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_tmp_src_revenue_tab          SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_tmp_cost_rate_override_tab   SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_tmp_b_cost_rate_override_tab SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_tmp_bill_rate_override_tab   SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_tmp_billable_flag_tab        SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();

    -- Added in IPM to track if a record in the existing set of
    -- pl/sql tables needs to be removed.
    l_remove_record_flag_tab       PA_PLSQL_DATATYPES.Char1TabTyp;
    l_remove_records_flag          VARCHAR2(1);

BEGIN
    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.set_curr_function( p_function   => 'GENERATE_WP_BUDGET_AMT',
                                    p_debug_mode => p_pa_debug_mode );
    END IF;
    --hr_utility.trace_on(null,'mftest');
    --hr_utility.trace('==BEGIN==');

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;

    --l_rev_gen_method := PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(p_project_id); Bug 5462471

    l_wp_track_cost_flag :=
        NVL( PA_FP_WP_GEN_AMT_UTILS.GET_WP_TRACK_COST_AMT_FLAG(p_project_id), 'N' );

    select trunc(sysdate) into l_sysdate_trunc from dual;

    IF p_init_msg_flag = 'Y' THEN
        FND_MSG_PUB.initialize;
    END IF;

    /* Set the local calling context to p_calling_context if it is a valid value.
     * Otherwise, default l_calling_context to budget generation. */
    IF p_calling_context = lc_BudgetGeneration OR
       p_calling_context = lc_ForecastGeneration THEN
        l_calling_context := p_calling_context;
    ELSE
        l_calling_context := lc_BudgetGeneration;
    END IF;

    IF P_PROJECT_ID is null or p_budget_version_id is null THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
            ( p_called_mode => p_called_mode,
              p_msg         => 'Before calling PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS',
              p_module_name => l_module_name,
              p_log_level   => 5 );
    END IF;
    /*Calling the UTIL API to get the target financial plan info l_fp_cols_rec_target*/
    PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
        ( P_PROJECT_ID         => P_PROJECT_ID,
          P_BUDGET_VERSION_ID  => P_BUDGET_VERSION_ID,
          X_FP_COLS_REC        => l_fp_cols_rec_target,
          X_RETURN_STATUS      => x_return_status,
          X_MSG_COUNT          => x_msg_count,
          X_MSG_DATA           => x_msg_data );
    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
            ( p_called_mode => p_called_mode,
              p_msg         => 'Status after calling
                               PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS: '
                               ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5 );
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    l_rev_gen_method := nvl(l_fp_cols_rec_target.x_revenue_derivation_method,PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(p_project_id)); --Bug 5462471

    IF l_calling_context = lc_BudgetGeneration THEN
        l_gen_src_code := l_fp_cols_rec_target.x_gen_src_code;
    ELSIF  l_calling_context = lc_ForecastGeneration THEN
        l_gen_src_code := l_fp_cols_rec_target.x_gen_etc_src_code;
    END IF;

    l_stru_sharing_code := PA_PROJECT_STRUCTURE_UTILS.get_Structure_sharing_code(
        p_project_id=> p_project_id );
        -- SHARE_FULL
        -- SHARE_PARTIAL
        -- SPLIT_NO_MAPPING
        -- SPLILT_MAPPING
    -- dbms_output.put_line('proj id           '||p_project_id );
    -- dbms_output.put_line('bv   id           '||p_budget_version_id );
    -- dbms_output.put_line('stru sharing code '||l_stru_sharing_code );
    IF l_stru_sharing_code is null
        AND  PA_PROJECT_STRUCTURE_UTILS.check_financial_enabled( p_project_id )= 'Y'
        AND  l_gen_src_code = 'WORKPLAN_RESOURCES' THEN
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                              p_msg_name       => 'PA_ONLY_FIN_STRUCT');
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;
    /**SRC WORKPLAN VER CODE: CURRENT_WORKING; LAST_PUBLISHED; BASELINED.
      *SRC FINPLAN VER CODE:  CURRENT_WORKING;
      *                       CURRENT_BASELINED; ORIGINAL_BASELINED;
      *                       CURRENT_APPROVED; ORIGINAL_APPROVED.**/


        --dbms_output.put_line('src code val :'||l_gen_src_code );

    /* In the context of budget generation, it is necessary to derive values
     * for l_source_id and l_wp_id.
     * In the context of forecast generation, l_source_id is passed in as
     * p_etc_plan_version_id. Furthermore, currently, this API only supports
     * forecast generation when the target is revenue-only and the source is
     * a cost or cost-and-revenue forecast. Hence l_wp_id can be left as NULL. */

    IF l_calling_context = lc_BudgetGeneration THEN
	IF (l_gen_src_code = 'WORKPLAN_RESOURCES') THEN
	    /*Get latest published/current working/baselined work plan version id*/
	    IF l_fp_cols_rec_target.x_gen_src_wp_version_id is not NULL THEN
		l_source_id := l_fp_cols_rec_target.x_gen_src_wp_version_id;
		/* the x_gen_src_wp_version_id is the budget version id
		   corresponding to the work plan structure version id selected
		   as the source for the budget generation when the budget
		   generation source is Work plan. */
		SELECT project_structure_version_id
                INTO   l_wp_id
                FROM   pa_budget_versions
                WHERE  budget_version_id = l_source_id;
	    ELSE
		l_versioning_enabled :=
		    PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(p_project_id);
		IF l_versioning_enabled = 'Y' THEN
		    l_wp_status := l_fp_cols_rec_target.x_gen_src_wp_ver_code;
		    --dbms_output.put_line('ver code val :'||l_wp_status );
		    IF (l_wp_status = 'LAST_PUBLISHED') THEN
			l_wp_id := PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION
				       ( P_PROJECT_ID => p_project_id );
			IF l_wp_id is null THEN
			    PA_UTILS.ADD_MESSAGE
				( p_app_short_name => 'PA',
				  p_msg_name       => 'PA_LATEST_WPID_NULL');
			    raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
			END IF;
		    ELSIF (l_wp_status = 'CURRENT_WORKING') THEN
			--dbms_output.put_line('inside cw  chk  :');
	                l_wp_id := PA_PROJECT_STRUCTURE_UTILS.GET_CURRENT_WORKING_VER_ID
                                       ( P_PROJECT_ID => p_project_id);
                        IF l_wp_id is null THEN
                            --dbms_output.put_line('cw id is null  calling latest pub  :');
                            l_wp_id := PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION
                                           ( P_PROJECT_ID => p_project_id );
                        END IF;
                        --dbms_output.put_line('wp id value : '||l_wp_id);
                        IF l_wp_id is null THEN
                            PA_UTILS.ADD_MESSAGE
                                ( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_CW_WPID_NULL');
                            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                        END IF;
                    -- Bug 4426511: Changed 'BASELINE', which was INCORRECT, to 'BASELINED'.
                    ELSIF (l_wp_status = 'BASELINED') THEN
                        l_wp_id := PA_PROJECT_STRUCTURE_UTILS.GET_BASELINE_STRUCT_VER
                                       ( P_PROJECT_ID => p_project_id );
                        IF l_wp_id is null THEN
                            PA_UTILS.ADD_MESSAGE
                                ( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_BASELINED_WPID_NULL');
                            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                        END IF;
                    END IF;
                ELSE
                    l_wp_id := PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION
                                   ( P_PROJECT_ID => p_project_id );
                    IF l_wp_id is null THEN
                        PA_UTILS.ADD_MESSAGE
                            ( p_app_short_name => 'PA',
                              p_msg_name       => 'PA_LATEST_WPID_NULL');
                        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;
                END IF;
                /*Get the budget version id for the requried work plan version id
                 *SOURCE: work plan budget version id: l_source_id
                 *TARGET: financial budget version id: P_BUDGET_VERSION_ID*/

                l_source_id := Pa_Fp_wp_gen_amt_utils.get_wp_version_id
                                   ( p_project_id      => p_project_id,
                                     p_plan_type_id    => l_wp_ptype_id,
                                     p_proj_str_ver_id => l_wp_id );
            END IF;

             --dbms_output.put_line('l_source_id:    '||l_source_id );
             --l_txn_currency_flag := '1';

             l_version_type := l_fp_cols_rec_target.x_version_type;
            /*As of now, we have the l_wp_id as wp struct version id
             * l_source_id as wp fin version id
             * Now, we need to update back to pa_proj_fp_options*/
            IF l_version_type = 'COST' THEN
                UPDATE PA_PROJ_FP_OPTIONS
                SET    GEN_SRC_COST_WP_VERSION_ID = l_source_id
                WHERE  fin_plan_version_id = P_BUDGET_VERSION_ID;
            ELSIF l_version_type = 'ALL' THEN
                UPDATE PA_PROJ_FP_OPTIONS
                SET    GEN_SRC_ALL_WP_VERSION_ID = l_source_id
                WHERE  fin_plan_version_id = P_BUDGET_VERSION_ID;
            ELSIF l_version_type = 'REVENUE' THEN
                UPDATE PA_PROJ_FP_OPTIONS
                SET    GEN_SRC_REV_WP_VERSION_ID = l_source_id
                WHERE  fin_plan_version_id = P_BUDGET_VERSION_ID;
            END IF;

            /*project structure version id is populated when create new version.
            IF ( l_stru_sharing_code = 'SHARE_FULL' OR
                 l_stru_sharing_code = 'SHARE_PARTIAL' ) AND
               l_fp_cols_rec_target.X_FIN_PLAN_LEVEL_CODE <> 'P' THEN
                UPDATE PA_BUDGET_VERSIONS
                SET    project_structure_version_id = l_wp_id
                WHERE  budget_version_id = P_BUDGET_VERSION_ID;
            END IF;*/
        ELSIF (l_gen_src_code = 'FINANCIAL_PLAN') THEN
            IF l_fp_cols_rec_target.x_gen_src_plan_version_id IS NOT NULL THEN
                l_source_id := l_fp_cols_rec_target.x_gen_src_plan_version_id;
            ELSE
                l_gen_src_plan_ver_code :=  l_fp_cols_rec_target.X_GEN_SRC_PLAN_VER_CODE;
                IF l_gen_src_plan_ver_code = 'CURRENT_BASELINED'
                   OR l_gen_src_plan_ver_code = 'ORIGINAL_BASELINED'
                   OR l_gen_src_plan_ver_code = 'CURRENT_APPROVED'
                   OR l_gen_src_plan_ver_code = 'ORIGINAL_APPROVED' THEN
                   /*Get the current baselined or original baselined version*/
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_fp_gen_amount_utils.fp_debug
                           ( p_called_mode => p_called_mode,
                             p_msg         => 'Before calling
                                              pa_fp_gen_amount_utils.Get_Curr_Original_Version_Info',
                             p_module_name => l_module_name,
                             p_log_level   => 5 );
                    END IF;
                    pa_fp_gen_amount_utils.Get_Curr_Original_Version_Info(
                        p_project_id                => P_PROJECT_ID,
                        p_fin_plan_type_id          => l_fp_cols_rec_target.X_GEN_SRC_PLAN_TYPE_ID,
                        p_version_type              => 'COST',
                        p_status_code               => l_gen_src_plan_ver_code,
                        x_fp_options_id             => l_fp_options_id,
                        x_fin_plan_version_id       => l_source_id,
                        x_return_status             => x_return_status,
                        x_msg_count                 => x_msg_count,
                        x_msg_data                  => x_msg_data );
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_fp_gen_amount_utils.fp_debug
                           ( p_called_mode => p_called_mode,
                             p_msg         => 'Status after calling
                                               pa_fp_gen_amount_utils.Get_Curr_Original_Version_Info'
                                               ||x_return_status,
                             p_module_name => l_module_name,
                             p_log_level   => 5 );
                    END IF;
                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;

                ELSIF l_gen_src_plan_ver_code = 'CURRENT_WORKING' THEN
                   /*Get the current working version*/
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_fp_gen_amount_utils.fp_debug
                            ( p_called_mode => p_called_mode,
                              p_msg         => 'Before calling
                                                pa_fin_plan_utils.Get_Curr_Working_Version_Info',
                              p_module_name => l_module_name,
                              p_log_level   => 5 );
                    END IF;
                    pa_fin_plan_utils.Get_Curr_Working_Version_Info
                        ( p_project_id                => P_PROJECT_ID,
                          p_fin_plan_type_id          => l_fp_cols_rec_target.X_GEN_SRC_PLAN_TYPE_ID,
                          p_version_type              => 'COST',
                          x_fp_options_id             => l_fp_options_id,
                          x_fin_plan_version_id       => l_source_id,
                          x_return_status             => x_return_status,
                          x_msg_count                 => x_msg_count,
                          x_msg_data                  => x_msg_data );
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_fp_gen_amount_utils.fp_debug
                            ( p_called_mode => p_called_mode,
                              p_msg         => 'Status after calling
                                               pa_fin_plan_utils.Get_Curr_Working_Version_Info'
                                               ||x_return_status,
                              p_module_name => l_module_name,
                              p_log_level   => 5 );
                    END IF;
                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;
                 ELSE
                     l_dummy := 1;
                 END IF;
            END IF;
            --dbms_output.put_line('==l_source_id:'||l_source_id);

            l_version_type := l_fp_cols_rec_target.x_version_type;
            /*As of now, we have l_source_id as fin version id
             * Now, we need to update back to pa_proj_fp_options*/
            IF l_version_type = 'COST' THEN
                UPDATE PA_PROJ_FP_OPTIONS
                SET GEN_SRC_COST_PLAN_VERSION_ID = l_source_id
                WHERE fin_plan_version_id = P_BUDGET_VERSION_ID;
            ELSIF l_version_type = 'ALL' THEN
                UPDATE PA_PROJ_FP_OPTIONS
                SET GEN_SRC_ALL_PLAN_VERSION_ID = l_source_id
                WHERE fin_plan_version_id = P_BUDGET_VERSION_ID;
            ELSIF l_version_type = 'REVENUE' THEN
                UPDATE PA_PROJ_FP_OPTIONS
                SET GEN_SRC_REV_PLAN_VERSION_ID = l_source_id
                WHERE fin_plan_version_id = P_BUDGET_VERSION_ID;
            END IF;
        END IF; -- end gen_src_code-based logic

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
	END IF;
	IF l_source_id IS NULL THEN
	    PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
				  p_msg_name       => 'PA_SRC_FP_VER_NULL');
	    raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
	END IF;
    ELSIF l_calling_context = lc_ForecastGeneration THEN
	l_source_id := p_etc_plan_version_id;
    END IF; -- context-based l_source_id, l_wp_id logic.


    /*Calling the UTIL API to get the source info l_fp_cols_rec_source*/
    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
            ( p_called_mode => p_called_mode,
              p_msg         => 'Before calling
                               PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS',
              p_module_name => l_module_name,
              p_log_level   => 5 );
    END IF;
    PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
        ( P_PROJECT_ID                 => P_PROJECT_ID,
          P_BUDGET_VERSION_ID          => l_source_id,
          X_FP_COLS_REC                => l_fp_cols_rec_source,
          X_RETURN_STATUS              => x_return_status,
          X_MSG_COUNT                  => x_msg_count,
          X_MSG_DATA                   => x_msg_data );
    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
            ( p_called_mode => p_called_mode,
              p_msg         => 'Status after calling
                               PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS: '
                               ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5 );
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    /*By now, we have both source budget version id (l_source_id)
     *                 and target budget version id (p_budget_version_id)*/
    /*source multi currency flag     target multi currency flag currency code used
        N                               N                               proj
        Y                               N                               proj
        N                               Y                               txn
        Y                               Y                               txn
      l_txn_currency_flag is 'Y' means we use txn_currency_code
      l_txn_currency_flag is 'N' means we use proj_currency_code
      l_txn_currency_flag is 'A' means we use projfunc_currency_code
     */

    SELECT NVL(APPROVED_COST_PLAN_TYPE_FLAG, 'N'),
           NVL(APPROVED_REV_PLAN_TYPE_FLAG, 'N')
           INTO
           l_appr_cost_plan_type_flag,
           l_appr_rev_plan_type_flag
    FROM PA_BUDGET_VERSIONS
    WHERE BUDGET_VERSION_ID = P_BUDGET_VERSION_ID;

    /* When the Calling Context is Forecast generation and we set l_txn_currency_flag
     * to 'A', we are really considering the case when the Source version is a Cost
     * forecast and the Target version is Revenue because this is the only case in
     * which we call this procedure from the forecast generation wrapper API. If this
     * premise changes, then this condition will need to be modified accordingly. */

    IF ((l_fp_cols_rec_target.x_version_type = 'ALL' OR
         l_fp_cols_rec_target.x_version_type = 'REVENUE') AND
        (l_appr_cost_plan_type_flag = 'Y' OR l_appr_rev_plan_type_flag = 'Y')) OR
        (l_calling_context = lc_BudgetGeneration AND l_rev_gen_method = 'C' AND
         l_fp_cols_rec_target.x_version_type = 'REVENUE') OR
        l_calling_context = lc_ForecastGeneration THEN
        l_txn_currency_flag := 'A';
    ELSIF l_fp_cols_rec_target.x_plan_in_multi_curr_flag = 'N' THEN
        l_txn_currency_flag := 'N';
    END IF;

    --hr_utility.trace('l_fp_cols_rec_target.x_plan_in_multi_curr_flag:'||l_fp_cols_rec_target.x_plan_in_multi_curr_flag);
    --hr_utility.trace('l_fp_cols_rec_target.x_project_currency_code:'||l_fp_cols_rec_target.x_project_currency_code);

    /* Bug 4119258 : The Copy Actuals API should be called before the
       resource mapping logic. Otherwise, the tmp table data will get deleted
       and no amounts will be carried over to the target version from the
       generation source.  */

    -- Bug 4114589: Moved from beginning of GENERATE_FCST_AMT_WRP to several
    -- places - this being one of them. The Copy Actuals API call is placed
    -- after calls to CREATE_RES_ASG and UPDATE_RES_ASG so that planning dates
    -- from the source are honored when possible, since resources created by
    -- the Copy Actuals API use task/project-level default dates.
    IF l_calling_context = lc_ForecastGeneration THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE       => P_CALLED_MODE,
                P_MSG               => 'Before calling pa_fp_copy_actuals_pub.copy_actuals',
                P_MODULE_NAME       => l_module_name);
        END IF;
        PA_FP_COPY_ACTUALS_PUB.COPY_ACTUALS
              (P_PROJECT_ID               => P_PROJECT_ID,
               P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
               P_FP_COLS_REC              => l_fp_cols_rec_target,
               P_END_DATE                 => P_ACTUALS_THRU_DATE,
               P_INIT_MSG_FLAG            => 'N',
               P_COMMIT_FLAG              => 'N',
               X_RETURN_STATUS            => X_RETURN_STATUS,
               X_MSG_COUNT                => X_MSG_COUNT,
               X_MSG_DATA                 => X_MSG_DATA);
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_CALLED_MODE       => P_CALLED_MODE,
                P_MSG               => 'After calling pa_fp_copy_actuals_pub.copy_actuals:'
                                       ||x_return_status,
                P_MODULE_NAME       => l_module_name);
        END IF;
        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
    END IF;

    /*populating tmp1 with PA_RESOURCE_ASSIGNMENTS*/
IF l_fp_cols_rec_source.x_resource_list_id <>
   l_fp_cols_rec_target.x_resource_list_id THEN
    DELETE FROM PA_RES_LIST_MAP_TMP1;
    DELETE from pa_res_list_map_tmp4;

    -- Bug 3962468: Previously, the code was pulling data for target resource assignments.
    --              Changed query to get source (l_source_id) resource assignments instead.

                        SELECT        PERSON_ID,
                                      JOB_ID,
                                      ORGANIZATION_ID,
                                      EXPENDITURE_TYPE,
                                      EVENT_TYPE,
                                      NON_LABOR_RESOURCE,
                                      EXPENDITURE_CATEGORY,
                                      REVENUE_CATEGORY_CODE,
                                      NVL(INCUR_BY_ROLE_ID, PROJECT_ROLE_ID),
                                      NVL(INCUR_BY_RES_CLASS_CODE,RESOURCE_CLASS_CODE),
                                      MFC_COST_TYPE_ID,
                                      RESOURCE_CLASS_FLAG,
                                      FC_RES_TYPE_CODE,
                                      INVENTORY_ITEM_ID,
                                      ITEM_CATEGORY_ID,
                                      PERSON_TYPE_CODE,
                                      BOM_RESOURCE_ID,
                                      NAMED_ROLE,
                                      INCURRED_BY_RES_FLAG,
                                      resource_assignment_id, --TXN_SOURCE_ID,
                                      'RES_ASSIGNMENT', --TXN_SOURCE_TYPE_CODE,
                                      TASK_ID,
                                      NULL, --TXN_WBS_ELEMENT_VERSION_ID,
                                      RBS_ELEMENT_ID,
                                      nvl(PLANNING_START_DATE,l_sysdate_trunc),
                                      nvl(PLANNING_END_DATE,l_sysdate_trunc),
                                      RATE_BASED_FLAG,
                                      SUPPLIER_ID
                        BULK  COLLECT
                        INTO          l_PERSON_ID_tab,
                                      l_JOB_ID_tab,
                                      l_ORGANIZATION_ID_tab,
                                      l_EXPENDITURE_TYPE_tab,
                                      l_EVENT_TYPE_tab,
                                      l_NON_LABOR_RESOURCE_tab,
                                      l_EXPENDITURE_CATEGORY_tab,
                                      l_REVENUE_CATEGORY_CODE_tab,
                                      l_PROJECT_ROLE_ID_tab,
                                      l_RESOURCE_CLASS_CODE_tab,
                                      l_MFC_COST_TYPE_ID_tab,
                                      l_RESOURCE_CLASS_FLAG_tab,
                                      l_FC_RES_TYPE_CODE_tab,
                                      l_INVENTORY_ITEM_ID_tab,
                                      l_ITEM_CATEGORY_ID_tab,
                                      l_PERSON_TYPE_CODE_tab,
                                      l_BOM_RESOURCE_ID_tab,
                                      l_NAMED_ROLE_tab,
                                      l_INCURRED_BY_RES_FLAG_tab,
                                      l_TXN_SOURCE_ID_tab,
                                      l_TXN_SOURCE_TYPE_CODE_tab,
                                      l_TXN_TASK_ID_tab,
                                      l_TXN_WBS_ELEMENT_VER_ID_tab,
                                      l_TXN_RBS_ELEMENT_ID_tab,
                                      l_TXN_PLAN_START_DATE_tab,
                                      l_TXN_PLAN_END_DATE_tab,
                                      l_RATE_BASED_FLAG_tab,
                                      l_VENDOR_ID_tab
                        FROM          PA_RESOURCE_ASSIGNMENTS ra
                        WHERE         ra.budget_version_id = l_source_id;
    IF l_TXN_SOURCE_ID_tab.count = 0 THEN
       IF P_PA_DEBUG_MODE = 'Y' THEN
           PA_DEBUG.RESET_CURR_FUNCTION;
       END IF;
       RETURN;
    END IF;

    FOR j IN 1..l_TXN_SOURCE_ID_tab.count LOOP
             l_NLR_ORGANIZATION_ID_tab(j) := null;
             l_EVENT_CLASSIFICATION_tab(j):= null;
             l_SYS_LINK_FUNCTION_tab(j)   := null;
    END LOOP;

    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_MSG           => 'Before calling PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS',
            P_MODULE_NAME   => l_module_name);
    END IF;
    -- Bug 3962468: Changed P_RESOURCE_LIST_ID parameter from
    -- l_fp_cols_rec_source.x_resource_list_id to
    -- l_fp_cols_rec_target.x_resource_list_id.
    PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS (
         P_PROJECT_ID                   => p_project_id,
         P_BUDGET_VERSION_ID            => NULL,
         P_RESOURCE_LIST_ID             => l_fp_cols_rec_target.x_resource_list_id,
         P_RBS_VERSION_ID               => NULL,
         P_CALLING_PROCESS              => 'BUDGET_GENERATION',
         P_CALLING_CONTEXT              => 'PLSQL',
         P_PROCESS_CODE                 => 'RES_MAP',
         P_CALLING_MODE                 => 'PLSQL_TABLE',
         P_INIT_MSG_LIST_FLAG           => 'N',
         P_COMMIT_FLAG                  => 'N',
         P_TXN_SOURCE_ID_TAB            => l_TXN_SOURCE_ID_tab,
         P_TXN_SOURCE_TYPE_CODE_TAB     => l_TXN_SOURCE_TYPE_CODE_tab,
         P_PERSON_ID_TAB                => l_PERSON_ID_tab,
         P_JOB_ID_TAB                   => l_JOB_ID_tab,
         P_ORGANIZATION_ID_TAB          => l_ORGANIZATION_ID_tab,
         P_VENDOR_ID_TAB                => l_VENDOR_ID_tab,
         P_EXPENDITURE_TYPE_TAB         => l_EXPENDITURE_TYPE_tab,
         P_EVENT_TYPE_TAB               => l_EVENT_TYPE_tab,
         P_NON_LABOR_RESOURCE_TAB       => l_NON_LABOR_RESOURCE_tab,
         P_EXPENDITURE_CATEGORY_TAB     => l_EXPENDITURE_CATEGORY_tab,
         P_REVENUE_CATEGORY_CODE_TAB    =>l_REVENUE_CATEGORY_CODE_tab,
         P_NLR_ORGANIZATION_ID_TAB      =>l_NLR_ORGANIZATION_ID_tab,
         P_EVENT_CLASSIFICATION_TAB     => l_EVENT_CLASSIFICATION_tab,
         P_SYS_LINK_FUNCTION_TAB        => l_SYS_LINK_FUNCTION_tab,
         P_PROJECT_ROLE_ID_TAB          => l_PROJECT_ROLE_ID_tab,
         P_RESOURCE_CLASS_CODE_TAB      => l_RESOURCE_CLASS_CODE_tab,
         P_MFC_COST_TYPE_ID_TAB         => l_MFC_COST_TYPE_ID_tab,
         P_RESOURCE_CLASS_FLAG_TAB      => l_RESOURCE_CLASS_FLAG_tab,
         P_FC_RES_TYPE_CODE_TAB         => l_FC_RES_TYPE_CODE_tab,
         P_INVENTORY_ITEM_ID_TAB        => l_INVENTORY_ITEM_ID_tab,
         P_ITEM_CATEGORY_ID_TAB         => l_ITEM_CATEGORY_ID_tab,
         P_PERSON_TYPE_CODE_TAB         => l_PERSON_TYPE_CODE_tab,
         P_BOM_RESOURCE_ID_TAB          =>l_BOM_RESOURCE_ID_tab,
         P_NAMED_ROLE_TAB               =>l_NAMED_ROLE_tab,
         P_INCURRED_BY_RES_FLAG_TAB     =>l_INCURRED_BY_RES_FLAG_tab,
         P_RATE_BASED_FLAG_TAB          =>l_RATE_BASED_FLAG_tab,
         P_TXN_TASK_ID_TAB              =>l_TXN_TASK_ID_tab,
         P_TXN_WBS_ELEMENT_VER_ID_TAB   => l_TXN_WBS_ELEMENT_VER_ID_tab,
         P_TXN_RBS_ELEMENT_ID_TAB       => l_TXN_RBS_ELEMENT_ID_tab,
         P_TXN_PLAN_START_DATE_TAB      => l_TXN_PLAN_START_DATE_tab,
         P_TXN_PLAN_END_DATE_TAB        => l_TXN_PLAN_END_DATE_tab,
         X_TXN_SOURCE_ID_TAB            =>l_map_txn_source_id_tab,
         X_RES_LIST_MEMBER_ID_TAB       =>l_map_rlm_id_tab,
         X_RBS_ELEMENT_ID_TAB           =>l_map_rbs_element_id_tab,
         X_TXN_ACCUM_HEADER_ID_TAB      =>l_map_txn_accum_header_id_tab,
         X_RETURN_STATUS                => x_return_status,
         X_MSG_COUNT                    => x_msg_count,
         X_MSG_DATA                     => x_msg_data );
    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_MSG           => 'After calling PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS: '||
                               x_return_status,
            P_MODULE_NAME   => l_module_name);
    END IF;

    SELECT /*+ INDEX(PA_RES_LIST_MAP_TMP4,PA_RES_LIST_MAP_TMP4_N1)*/
           count(*) INTO l_count1
    FROM PA_RES_LIST_MAP_TMP4
    WHERE RESOURCE_LIST_MEMBER_ID IS NULL AND rownum=1;
    IF l_count1 > 0 THEN
        PA_UTILS.ADD_MESSAGE
            (p_app_short_name => 'PA',
             p_msg_name       => 'PA_INVALID_MAPPING_ERR');
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;
    --@@
         IF P_PA_DEBUG_MODE = 'Y' THEN
         tmp_rlm_tab.delete;
         select distinct resource_list_member_id,txn_task_id
         bulk collect into tmp_rlm_tab, tmp_task_tab
         from PA_RES_LIST_MAP_TMP4;
         for i in 1..tmp_rlm_tab.count loop
             pa_fp_gen_amount_utils.fp_debug
                  (p_called_mode => p_called_mode,
                   p_msg         => 'after res mapping, @@rlm in tmp4:'||tmp_rlm_tab(i)
                                    ||'; @@task in tmp4:'||tmp_task_tab(i),
                   p_module_name => l_module_name,
                   p_log_level   => 5);
           begin
             --dbms_output.put_line('@@rlm in tmp4:'||tmp_rlm_tab(i));
             select 'Y' into tmp_flag from PA_RESource_list_members
             where resource_list_member_id = tmp_rlm_tab(i);
             --dbms_output.put_line('@@exist in rlm? '||tmp_flag);
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                  (p_called_mode => p_called_mode,
                   p_msg         => 'after res mapping, @@rlm in tmp4:'||tmp_rlm_tab(i)||
                                    '@@exist in rlm?'||tmp_flag,
                   p_module_name => l_module_name,
                   p_log_level   => 5);
             END IF;
           exception
             when no_data_found then
             --dbms_output.put_line('@@exist in rlm? '||'N');
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                  (p_called_mode => p_called_mode,
                   p_msg         => 'after res mapping, @@rlm in tmp4:'||tmp_rlm_tab(i)||
                                    '@@exist in rlm?'||'N',
                   p_module_name => l_module_name,
                   p_log_level   => 5);
             END IF;
           end;
         end loop;
         END IF;
    --@@

    /*Calling CREATE_RES_ASG API to populate missing resouce assignments for target budget version*/

    -- select count(*) into l_count from pa_resource_assignments where
    -- budget_version_id = p_budget_version_id;
    -- dbms_output.put_line('before calling cre res asg api: res_assign has: '||l_count);
ELSE
    DELETE from PA_RES_LIST_MAP_TMP4;
    INSERT INTO PA_RES_LIST_MAP_TMP4( PERSON_ID,
                                      JOB_ID,
                                      ORGANIZATION_ID,
                                      VENDOR_ID,
                                      EXPENDITURE_TYPE,
                                      EVENT_TYPE,
                                      NON_LABOR_RESOURCE,
                                      EXPENDITURE_CATEGORY,
                                      REVENUE_CATEGORY,
                                      -- NON_LABOR_RESOURCE_ORG_ID,
                                      PROJECT_ROLE_ID,
                                      RESOURCE_TYPE_CODE,
                                      RESOURCE_CLASS_CODE,
                                      MFC_COST_TYPE_ID,
                                      RESOURCE_CLASS_FLAG,
                                      FC_RES_TYPE_CODE,
                                      --BOM_LABOR_RESOURCE_ID,
                                      --BOM_EQUIP_RESOURCE_ID,
                                      INVENTORY_ITEM_ID,
                                      ITEM_CATEGORY_ID,
                                      PERSON_TYPE_CODE,
                                      BOM_RESOURCE_ID,
                                      NAMED_ROLE,
                                      INCURRED_BY_RES_FLAG,
                                      TXN_TRACK_AS_LABOR_FLAG,
                                      TXN_SOURCE_ID,
                                      TXN_SOURCE_TYPE_CODE,
                                      TXN_TASK_ID,
                                      TXN_WBS_ELEMENT_VERSION_ID,
                                      TXN_RBS_ELEMENT_ID,
                                      TXN_PLANNING_START_DATE,
                                      TXN_PLANNING_END_DATE,
                                      TXN_SP_FIXED_DATE,
                                      TXN_RESOURCE_LIST_MEMBER_ID,
                                      TXN_RATE_BASED_FLAG,
                                      RESOURCE_LIST_MEMBER_ID
                                      )
  SELECT                              PERSON_ID,
                                      JOB_ID,
                                      ORGANIZATION_ID,
                                      SUPPLIER_ID, --VENDOR_ID,
                                      EXPENDITURE_TYPE,
                                      EVENT_TYPE,
                                      NON_LABOR_RESOURCE,
                                      EXPENDITURE_CATEGORY,
                                      REVENUE_CATEGORY_CODE, --REVENUE_CATEGORY,
                                      -- NON_LABOR_RESOURCE, --NON_LABOR_RESOURCE_ORG_ID,
                                      NVL(INCUR_BY_ROLE_ID, PROJECT_ROLE_ID),
                                      RES_TYPE_CODE, --RESOURCE_TYPE_CODE,
                                      NVL(INCUR_BY_RES_CLASS_CODE,RESOURCE_CLASS_CODE),
                                      MFC_COST_TYPE_ID,
                                      RESOURCE_CLASS_FLAG,
                                      FC_RES_TYPE_CODE,
                                      --BOM_LABOR_RESOURCE_ID,
                                      --BOM_EQUIP_RESOURCE_ID,
                                      INVENTORY_ITEM_ID,
                                      ITEM_CATEGORY_ID,
                                      PERSON_TYPE_CODE,
                                      BOM_RESOURCE_ID,
                                      NAMED_ROLE,
                                      INCURRED_BY_RES_FLAG,
                                      TRACK_AS_LABOR_FLAG,
                                      resource_assignment_id, --TXN_SOURCE_ID,
                                      'RES_ASSIGNMENT', --TXN_SOURCE_TYPE_CODE,
                                      TASK_ID,
                                      NULL, --TXN_WBS_ELEMENT_VERSION_ID,
                                      RBS_ELEMENT_ID,
                                      nvl(PLANNING_START_DATE,l_sysdate_trunc),
                                      nvl(PLANNING_END_DATE,l_sysdate_trunc),
                                      SP_FIXED_DATE,
                                      RESOURCE_LIST_MEMBER_ID,
                                      RATE_BASED_FLAG,
                                      RESOURCE_LIST_MEMBER_ID
    FROM PA_RESOURCE_ASSIGNMENTS ra
    WHERE ra.budget_version_id = l_source_id;
    IF sql%rowcount = 0 THEN
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RETURN;
    END IF;
END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
            ( p_called_mode => p_called_mode,
              p_msg         => 'Before calling
                               pa_fp_gen_budget_amt_pub.create_res_asg',
              p_module_name => l_module_name,
              p_log_level   => 5 );
    END IF;
    PA_FP_GEN_BUDGET_AMT_PUB.CREATE_RES_ASG
        ( P_PROJECT_ID            => P_PROJECT_ID,
          P_BUDGET_VERSION_ID     => P_BUDGET_VERSION_ID,
          P_STRU_SHARING_CODE     => l_stru_sharing_code,
          P_GEN_SRC_CODE          => l_gen_src_code,
          P_FP_COLS_REC           => l_fp_cols_rec_target,
          P_WP_STRUCTURE_VER_ID   => l_wp_id,
          X_RETURN_STATUS         => x_return_status,
          X_MSG_COUNT             => x_msg_count,
          X_MSG_DATA              => x_msg_data );

    -- select count(*) into l_count1 from PA_RES_LIST_MAP_TMP4;
    -- dbms_output.put_line('after calling  cre res asg api, tmp4 has: '||l_count1);
    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
            ( p_called_mode => p_called_mode,
              p_msg         => 'Status after calling
                               pa_fp_gen_budget_amt_pub.create_res_asg: '
                               ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5 );
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;
    /*
         IF P_PA_DEBUG_MODE = 'Y' THEN
         tmp_rlm_tab.delete;
         tmp_task_tab.delete;
         tmp_ra_tab.delete;
         select resource_list_member_id, task_id, resource_assignment_id
         bulk collect into tmp_rlm_tab, tmp_task_tab, tmp_ra_tab
         from PA_RESOURCE_ASSIGNMENTS
         where budget_version_id = P_BUDGET_VERSION_ID;
         for i in 1..tmp_ra_tab.count loop
                pa_fp_gen_amount_utils.fp_debug
                  (p_called_mode => p_called_mode,
                   p_msg         => 'after create res asg, rlm in RA:'||tmp_rlm_tab(i)
                                    ||'; task in RA:'||tmp_task_tab(i)
                                    ||'; ra id in RA:'||tmp_ra_tab(i),
                   p_module_name => l_module_name,
                   p_log_level   => 5);
         end loop;
         END IF;
    */

    -- select count(*) into l_count from pa_resource_assignments where
    -- budget_version_id = p_budget_version_id;
    -- dbms_output.put_line('after calling cre res asg api: res_assign has: '||l_count);
    -- dbms_output.put_line('--------------');

  --     select count(*) into l_count from pa_resource_assignments where
  --          budget_version_id = p_budget_version_id;
  --  dbms_output.put_line('before calling upd res asg api: res assign has: '||l_count);

    /*Calling UPDATE_RES_ASG API to update resource_assignment_id in tmp4 for target budget version*/
    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
            ( p_called_mode => p_called_mode,
              p_msg         => 'Before calling
                               PA_FP_GEN_BUDGET_AMT_PUB.UPDATE_RES_ASG',
              p_module_name => l_module_name,
              p_log_level   => 5 );
    END IF;
    PA_FP_GEN_BUDGET_AMT_PUB.UPDATE_RES_ASG
        ( P_PROJECT_ID         => P_PROJECT_ID,
          P_BUDGET_VERSION_ID  => P_BUDGET_VERSION_ID,
          P_STRU_SHARING_CODE  => l_stru_sharing_code,
          P_GEN_SRC_CODE       => l_gen_src_code,
          P_FP_COLS_REC        => l_fp_cols_rec_target,
          P_WP_STRUCTURE_VER_ID=> l_wp_id,
          X_RETURN_STATUS      => x_return_status,
          X_MSG_COUNT          => x_msg_count,
          X_MSG_DATA           => x_msg_data );

    --select count(*) into l_count1 from PA_RES_LIST_MAP_TMP4
    --where TXN_RESOURCE_ASSIGNMENT_ID is not null;
    --hr_utility.trace('aft call update_res_asg, tmp4 with not null txn_res_asg_id '||l_count1);

    --  select count(*) into l_count from pa_resource_assignments where
    --        budget_version_id = p_budget_version_id;
    -- dbms_output.put_line('after calling upd res asg api: res assign has: '||l_count);
    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
            ( p_called_mode => p_called_mode,
              p_msg         => 'Status after calling
                               PA_FP_GEN_BUDGET_AMT_PUB.UPDATE_RES_ASG: '
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5 );
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

 /*  Bug 4057932 When structure is not fully shared source res/target resource mapping will not be one on one. In this case, rate based flag update is not happening correctly This code fixes the issue */

        -- SQL Repository Bug 4884824; SQL ID 14903770
        -- Fixed Full Index Scan violation by replacing
        -- existing hint with leading hint.
        SELECT /*+ LEADING(tmp) */
               DISTINCT txn_resource_assignment_id
        BULK COLLECT
        INTO l_tgt_res_asg_id_tab
        FROM pa_res_list_map_tmp4 tmp, pa_resource_assignments ra
        WHERE tmp.txn_resource_assignment_id = ra.resource_assignment_id
          AND ra.rate_based_flag = 'Y'
          AND tmp.txn_rate_based_flag = 'N';

        IF l_tgt_res_asg_id_tab.count <> 0 THEN
            FORALL i IN 1..l_tgt_res_asg_id_tab.count
                UPDATE pa_resource_assignments
                SET rate_based_flag = 'N',
                    unit_of_measure = 'DOLLARS'
                WHERE resource_assignment_id = l_tgt_res_asg_id_tab(i);

            l_tgt_res_asg_id_tab.delete;

        END IF;

    /*
         IF P_PA_DEBUG_MODE = 'Y' THEN
         tmp_rlm_tab.delete;
         tmp_task_tab.delete;
         tmp_ra_tab.delete;
         select distinct resource_list_member_id,txn_task_id,txn_resource_assignment_id
         bulk collect into tmp_rlm_tab, tmp_task_tab, tmp_ra_tab
         from PA_RES_LIST_MAP_TMP4;
         for i in 1..tmp_rlm_tab.count loop
             pa_fp_gen_amount_utils.fp_debug
                  (p_called_mode => p_called_mode,
                   p_msg         => 'after update res asg, @@rlm in tmp4:'||tmp_rlm_tab(i)
                                    ||'; @@task in tmp4:'||tmp_task_tab(i)
                                    ||'; @@ra id in tmp4:'||tmp_ra_tab(i),
                   p_module_name => l_module_name,
                   p_log_level   => 5);
         end loop;
         END IF;
    */


    /* Before generation of target budget lines, we need to ensure that
     * previously generated budget lines are deleted. If the Retain Manually
     * Added Plan Lines flag is 'N', then the wrapper API will have already
     * cleared all budget lines for us. However, if the flag is 'Y', then we
     * must Delete (non-actuals) budget lines for resources that are not
     * manually added/edited.  */
    IF p_retain_manual_flag = 'Y' THEN
        IF l_calling_context = lc_BudgetGeneration THEN
            DELETE FROM pa_budget_lines bl
            WHERE budget_version_id = p_budget_version_id
            AND EXISTS
                ( SELECT /*+ INDEX(tmp,PA_RES_LIST_MAP_TMP4_N2)*/ 1
                  FROM   pa_res_list_map_tmp4 tmp
                  WHERE  tmp.txn_resource_assignment_id = bl.resource_assignment_id
                  AND    rownum = 1 );
        ELSIF l_calling_context = lc_ForecastGeneration THEN
            l_etc_start_date := PA_FP_GEN_AMOUNT_UTILS.GET_ETC_START_DATE
                                    ( p_budget_version_id );
            IF l_fp_cols_rec_target.x_time_phased_code IN ('P','G') THEN
                DELETE FROM pa_budget_lines bl
                WHERE budget_version_id = p_budget_version_id
                AND EXISTS
                    ( SELECT /*+ INDEX(tmp,PA_RES_LIST_MAP_TMP4_N2)*/ 1
                      FROM   pa_res_list_map_tmp4 tmp
                      WHERE  tmp.txn_resource_assignment_id = bl.resource_assignment_id
                      AND    rownum = 1 )
                AND bl.start_date >= l_etc_start_date;
             END IF;
        END IF;
    END IF; -- end budget line deletion

    /**Populating target budget lines by summing up the values.
      *unique identifiers for pa_budget_lines:
      *1.resource_assignment_id : corresponds to one budget_version_id;
      *=one planning element;  rlmID from pa_resource_assignment
      *2.currency
      *3.start_date**/
    --hr_utility.trace('source ver:'||l_fp_cols_rec_source.X_BUDGET_VERSION_ID);
    --hr_utility.trace('target ver:'||l_fp_cols_rec_target.X_BUDGET_VERSION_ID);
    --hr_utility.trace('source:'||l_fp_cols_rec_source.X_TIME_PHASED_CODE);
    --hr_utility.trace('target:'||l_fp_cols_rec_target.X_TIME_PHASED_CODE);
    --hr_utility.trace('source bv id:'||l_fp_cols_rec_source.X_budget_version_id);
    --hr_utility.trace('source rl id:'||l_fp_cols_rec_source.X_resource_list_id);
    --hr_utility.trace('source rl id:'||l_fp_cols_rec_source.X_time_phased_code);
    --hr_utility.trace('target bv id:'||l_fp_cols_rec_target.X_budget_version_id);
    --hr_utility.trace('target rl id:'||l_fp_cols_rec_target.X_resource_list_id);
    --hr_utility.trace('source rl id:'||l_fp_cols_rec_source.X_resource_list_id);

    SELECT NVL(UNCATEGORIZED_FLAG,'N') into l_uncategorized_flag
    FROM pa_resource_lists_all_bg
    WHERE resource_list_id = l_fp_cols_rec_target.X_resource_list_id;

    -- ER 4376722: Consolidated update of UOM and rate_based_flag for
    -- cost-based Revenue generation within the this API before any
    -- cursor is called. This ensures that values in the rate_base_flag
    -- pl/sql tables are accurate. Before this change, an identical
    -- update was done in MAINTAIN_BUDGET_LINES as well as in this API
    -- after cursors were used and generation logic was performed.

    IF l_fp_cols_rec_target.x_version_type = 'REVENUE' and
       l_rev_gen_method = 'C' THEN
        l_res_asg_uom_update_tab.DELETE;
        SELECT DISTINCT txn_resource_assignment_id
        BULK COLLECT INTO l_res_asg_uom_update_tab
        FROM pa_res_list_map_tmp4;

        FORALL i IN 1..l_res_asg_uom_update_tab.count
            UPDATE pa_resource_assignments
               SET unit_of_measure = 'DOLLARS',
                   rate_based_flag = 'N'
             WHERE resource_assignment_id = l_res_asg_uom_update_tab(i);
    END IF;

    /*When time phases are same, always take periodic amounts from the source*/
    IF l_fp_cols_rec_source.X_TIME_PHASED_CODE =
       l_fp_cols_rec_target.X_TIME_PHASED_CODE
    THEN
        /*API to populating from Source budget lines table to Target budget lines table*/
        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_called_mode => p_called_mode,
                  p_msg         => 'Before calling
                                   PA_FP_WP_GEN_BUDGET_AMT_PUB.MAINTAIN_BUDGET_LINES',
                  p_module_name => l_module_name,
                  p_log_level   => 5 );
        END IF;
        PA_FP_WP_GEN_BUDGET_AMT_PUB.MAINTAIN_BUDGET_LINES
            ( P_PROJECT_ID            => P_PROJECT_ID,
              P_SOURCE_BV_ID          => l_source_id,
              P_TARGET_BV_ID          => P_BUDGET_VERSION_ID,
              P_CALLING_CONTEXT       => l_calling_context,
              P_ACTUALS_THRU_DATE     => P_ACTUALS_THRU_DATE,
              P_RETAIN_MANUAL_FLAG    => P_RETAIN_MANUAL_FLAG,
              X_RETURN_STATUS         => x_return_Status,
              X_MSG_COUNT             => x_msg_count,
              X_MSG_DATA              => x_msg_data );
        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_called_mode => p_called_mode,
                  p_msg         => 'Status after calling
                                   PA_FP_WP_GEN_BUDGET_AMT_PUB.MAINTAIN_BUDGET_LINES: '
                                  ||x_return_status,
                  p_module_name => l_module_name,
                  p_log_level   => 5 );
        END IF;
        IF x_return_Status <> FND_API.G_RET_STS_SUCCESS THEN
            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

        -- Bug 4686742: Logic has been added to call Calculate inside the
        -- MAINTAIN_BUDGET_LINE API when the Target is a Work-based Revenue
        -- Forecast. Hence, processing is complete, so just return.

        IF l_calling_context = lc_ForecastGeneration AND
           l_fp_cols_rec_target.x_version_type = 'REVENUE' AND
           l_rev_gen_method = 'T' THEN
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.RESET_CURR_FUNCTION;
            END IF;
            RETURN;
        END IF;

        /*We need to sum up the quantity and amount to pass to calculate API*/
        SELECT bl.resource_assignment_id,
               ra.rate_based_flag,
               bl.txn_currency_code,
               sum(bl.quantity),
               sum(bl.txn_raw_cost),
               sum(bl.txn_burdened_cost),
               sum(bl.txn_revenue),
               null, --bl.txn_cost_rate_override
               null, --bl.burden_cost_rate_override
               null  --bl.txn_bill_rate_override
        BULK COLLECT
        INTO  l_tgt_res_asg_id_tab,
              l_tgt_rate_based_flag_tab,
              l_txn_currency_code_tab,
              l_src_quantity_tab,
              l_src_raw_cost_tab,
              l_src_brdn_cost_tab,
              l_src_revenue_tab,
              l_cost_rate_override_tab,
              l_b_cost_rate_override_tab,
              l_bill_rate_override_tab
        FROM  pa_Budget_lines bl,
              pa_resource_assignments ra
        WHERE bl.budget_version_id = p_budget_version_id
              AND ra.budget_version_id = p_budget_version_id
              AND bl.resource_assignment_id = ra.resource_assignment_id
              AND EXISTS (SELECT /*+ INDEX(tmp4,PA_RES_LIST_MAP_TMP4_N2)*/ 1
                          FROM pa_res_list_map_tmp4 tmp4
                          WHERE ra.resource_assignment_id = tmp4.txn_resource_assignment_id
                                AND rownum = 1)
              and bl.cost_rejection_code is null
              and bl.revenue_rejection_code is null
              and bl.burden_rejection_code is null
              and bl.other_rejection_code is null
              and bl.pc_cur_conv_rejection_code is null
              and bl.pfc_cur_conv_rejection_code is null
        GROUP BY bl.resource_assignment_id,
                 ra.rate_based_flag,
                 bl.txn_currency_code,
                 null, --bl.txn_cost_rate_override
                 null, --bl.burden_cost_rate_override
                 null; --bl.txn_bill_rate_override

        /*bug: 3804791 and 3831190*/
        IF l_fp_cols_rec_target.x_version_type = 'REVENUE' and l_rev_gen_method = 'C' THEN
            /* updating the spread curve id to NULL as we are going to carry over
               the spread from the source version to the target version even though the
               target version resource list is different from the source. This will happen only
               when the target resource list is 'None'. */
            IF (l_fp_cols_rec_source.X_resource_list_id <>
               l_fp_cols_rec_target.X_resource_list_id AND
               l_uncategorized_flag = 'Y') THEN
                FORALL i IN 1..l_tgt_res_asg_id_tab.count
                    UPDATE PA_RESOURCE_ASSIGNMENTS
                    SET SPREAD_CURVE_ID = NULL,
                        SP_FIXED_DATE = NULL
                    WHERE resource_assignment_id = l_tgt_res_asg_id_tab(i);
            END IF;

            /* Bug Fix (Internal testing): We need to sync up the planning dates
             * before leaving this flow since it is not handled by the forecast
             * generation flow, and is normally handled by the Calculate API in
             * the budget generation flow. */
            IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                    ( p_msg         => 'Before calling
                                        pa_fp_maintain_actual_pub.sync_up_planning_dates',
                      p_module_name => l_module_name,
                      p_log_level   => 5 );
            END IF;
            PA_FP_MAINTAIN_ACTUAL_PUB.SYNC_UP_PLANNING_DATES
		( P_BUDGET_VERSION_ID => p_budget_version_id,
		  X_RETURN_STATUS     => x_return_Status,
		  X_MSG_COUNT         => x_msg_count,
		  X_MSG_DATA          => x_msg_data );
	    IF p_pa_debug_mode = 'Y' THEN
		pa_fp_gen_amount_utils.fp_debug
		    ( p_msg         => 'Status after calling
			  	        pa_fp_maintain_actual_pub.sync_up_planning_dates'
				        ||x_return_status,
	 	      p_module_name => l_module_name,
		      p_log_level   => 5 );
	    END IF;

            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.RESET_CURR_FUNCTION;
            END IF;
            RETURN;
        END IF; /*end bug: 3804791 and 3831190*/
    /**times phases or res list for source and target are different**/
    ELSE
        -- dbms_output.put_line('Time phase are different');

        /* Fetch data from the appropriate cursor based on the Calling Context:
         *   'BUDGET_GENERATION'   => use the budget_line_src_to_cal cursor.
         *   'FORECAST_GENERATION' => use the fcst_budget_line_src_to_cal cursor. */
        IF l_calling_context = lc_BudgetGeneration  THEN
            OPEN budget_line_src_to_cal
                (l_fp_cols_rec_target.x_project_currency_code,
                 l_fp_cols_rec_target.x_projfunc_currency_code);
            FETCH budget_line_src_to_cal
            BULK COLLECT
            INTO l_tgt_res_asg_id_tab,
                 l_tgt_rate_based_flag_tab,
                 l_txn_currency_code_tab,
                 l_src_quantity_tab,
                 l_src_raw_cost_tab,
                 l_src_brdn_cost_tab,
                 l_src_revenue_tab,
                 l_cost_rate_override_tab,
                 l_b_cost_rate_override_tab,
                 l_bill_rate_override_tab,
                 l_billable_flag_tab;
            CLOSE budget_line_src_to_cal;
        ELSIF l_calling_context = lc_ForecastGeneration AND
              l_fp_cols_rec_source.x_time_phased_code IN ('P','G') THEN
            OPEN fcst_budget_line_src_to_cal
                 (l_fp_cols_rec_target.x_project_currency_code,
                  l_fp_cols_rec_target.x_projfunc_currency_code,
                  l_fp_cols_rec_source.x_time_phased_code);
            FETCH fcst_budget_line_src_to_cal
            BULK COLLECT
            INTO l_tgt_res_asg_id_tab,
                 l_tgt_rate_based_flag_tab,
                 l_txn_currency_code_tab,
                 l_src_quantity_tab,
                 l_src_raw_cost_tab,
                 l_src_brdn_cost_tab,
                 l_src_revenue_tab,
                 l_cost_rate_override_tab,
                 l_b_cost_rate_override_tab,
                 l_bill_rate_override_tab,
                 l_billable_flag_tab;
            CLOSE fcst_budget_line_src_to_cal;

            /* Get the pro-rated amounts (if any) for each resource assignment, and
             * add them back into the corresponding PL/SQL tables.
             * Note that we currently only support the case when source time phasing
             * is GL and target time phasing is PA (or vise versa). */

            IF (l_fp_cols_rec_source.X_TIME_PHASED_CODE = 'G'
                AND l_fp_cols_rec_target.X_TIME_PHASED_CODE = 'P') OR
               (l_fp_cols_rec_source.X_TIME_PHASED_CODE = 'P'
                AND l_fp_cols_rec_target.X_TIME_PHASED_CODE = 'G') THEN

                FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                    /* Get source resource assignments that map to the current target
                     * resource assignment into l_mapped_src_res_asg_id_tab. */
                    l_mapped_src_res_asg_id_tab.delete;

                    SELECT /*+ INDEX(tmp,PA_RES_LIST_MAP_TMP4_N2)*/
                           tmp.txn_source_id BULK COLLECT INTO l_mapped_src_res_asg_id_tab
                      FROM pa_res_list_map_tmp4 tmp
                     WHERE tmp.txn_resource_assignment_id = l_tgt_res_asg_id_tab(i);

                    /* API to get pro-rated amounts for the first source period, which may
                     * be passed by during source data collection if the target's actual through
                     * date falls between the start and end dates of the first source period. */
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                            ( p_called_mode => p_called_mode,
                              p_msg         => 'Before calling ' ||
                                               'PA_FP_GEN_PUB.PRORATE_UNALIGNED_PERIOD_AMTS',
                              p_module_name => l_module_name,
                              p_log_level   => 5 );
                    END IF;
                    PA_FP_GEN_PUB.PRORATE_UNALIGNED_PERIOD_AMTS
                        ( P_SRC_RES_ASG_ID_TAB    => l_mapped_src_res_asg_id_tab,
                          P_TARGET_RES_ASG_ID     => l_tgt_res_asg_id_tab(i),
                          P_CURRENCY_CODE         => l_txn_currency_code_tab(i),
                          P_CURRENCY_CODE_FLAG    => l_txn_currency_flag,
                          P_ACTUAL_THRU_DATE      => p_actuals_thru_date,
                          X_QUANTITY              => l_prorated_quantity,
                          X_TXN_RAW_COST          => l_prorated_txn_raw_cost,
                          X_TXN_BURDENED_COST     => l_prorated_txn_burdened_cost,
                          X_TXN_REVENUE           => l_prorated_txn_revenue,
                          X_PROJ_RAW_COST         => l_prorated_proj_raw_cost,
                          X_PROJ_BURDENED_COST    => l_prorated_proj_burdened_cost,
                          X_PROJ_REVENUE          => l_prorated_proj_revenue,
                          X_RETURN_STATUS         => x_return_Status,
                          X_MSG_COUNT             => x_msg_count,
                          X_MSG_DATA              => x_msg_data );
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                            ( p_called_mode => p_called_mode,
                              p_msg         => 'Status after calling ' ||
                                               'PA_FP_GEN_PUB.PRORATE_UNALIGNED_PERIOD_AMTS: ' ||
                                               x_return_status,
                              p_module_name => l_module_name,
                              p_log_level   => 5 );
                    END IF;
                    IF x_return_Status <> FND_API.G_RET_STS_SUCCESS THEN
                        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;

                    /* Add pro-rated txn amounts to the amount tables for current resource assignment */
                    /* For now, we do not make use of the amounts in project currency. */
                    l_src_quantity_tab(i)  := l_src_quantity_tab(i)  + l_prorated_quantity;
                    l_src_raw_cost_tab(i)  := l_src_raw_cost_tab(i)  + l_prorated_txn_raw_cost;
                    l_src_brdn_cost_tab(i) := l_src_brdn_cost_tab(i) + l_prorated_txn_burdened_cost;
                    l_src_revenue_tab(i)   := l_src_revenue_tab(i)   + l_prorated_txn_revenue;
                END LOOP;
            END IF; -- timephase PA/GL check

        ELSIF l_calling_context = lc_ForecastGeneration AND
              l_fp_cols_rec_source.x_time_phased_code = 'N' THEN
            OPEN fcst_bdgt_line_src_to_cal_none
                 (l_fp_cols_rec_target.x_project_currency_code,
                  l_fp_cols_rec_target.x_projfunc_currency_code,
                  l_fp_cols_rec_source.x_time_phased_code);
            FETCH fcst_bdgt_line_src_to_cal_none
            BULK COLLECT
            INTO l_tgt_res_asg_id_tab,
                 l_tgt_rate_based_flag_tab,
                 l_txn_currency_code_tab,
                 l_src_quantity_tab,
                 l_src_raw_cost_tab,
                 l_src_brdn_cost_tab,
                 l_src_revenue_tab,
                 l_cost_rate_override_tab,
                 l_b_cost_rate_override_tab,
                 l_bill_rate_override_tab,
                 l_billable_flag_tab;
            CLOSE fcst_bdgt_line_src_to_cal_none;
        END IF; -- context-based data fetching

        -- Bug 3968616: Moved retain manually-edited lines logic from outside the logic
        -- block handling pl/sql data population to inside the Else block so that it is
        -- only executed when source and target planning options do not match.
        -- Update 12/2/04: We have changed the retain lines logic so that mapping to
        -- manually-edited resources are removed from the tmp4 table. As a result, the
        -- previous logic mentioned above has been removed.

        -- Old budget line deletion logic was here.

        /*Please refer to document: How to derive the rate*/
        l_source_version_type := l_fp_cols_rec_source.x_version_type;
        l_target_version_type := l_fp_cols_rec_target.x_version_type;

    /* ER 4376722:
     * When the Target is a Revenue-only Budget:
     * A) Do not generate quantity or amounts for non-billable tasks.
     * When the Target is a Revenue-only Forecast:
     * B) Do not generate quantity or amounts for non-rate-based
     *    resources of non-billable tasks.
     * C) Generate quantity but not amounts for rate-based resources
     *    of non-billable tasks.
     *
     * The simple algorithm to do (A) and (B) is as follows:
     * 0. Clear out any data in the _tmp_ tables.
     * 1. Copy records into _tmp_ tables for
     * a) billable tasks when the context is Budget Generation
     * b) billable tasks when the context is Forecast Generation
     * c) rate-based resources of non-billable tasks when the
     *    context is Forecast Generation
     * 2. Copy records from _tmp_ tables back to non-temporary tables.
     *
     * The result is that, afterwards, we do not process non-billable
     * task records in the Budget Generation context, and we do not
     * process non-rate-based resources of non-billable tasks in the
     * Forecast Generation Context. Hence, quantity and amounts for
     * those resources will not be generated.
     *
     * Note that case (C) is handled later at the end of the
     * Forecast Generation logic.
     **/

    IF l_target_version_type = 'REVENUE' THEN

        -- 0. Clear out any data in the _tmp_ tables.
        l_tmp_tgt_res_asg_id_tab.delete;
        l_tmp_tgt_rate_based_flag_tab.delete;
        l_tmp_txn_currency_code_tab.delete;
        l_tmp_src_quantity_tab.delete;
        l_tmp_src_raw_cost_tab.delete;
        l_tmp_src_brdn_cost_tab.delete;
        l_tmp_src_revenue_tab.delete;
        l_tmp_cost_rate_override_tab.delete;
        l_tmp_b_cost_rate_override_tab.delete;
        l_tmp_bill_rate_override_tab.delete;
        l_tmp_billable_flag_tab.delete;

        -- 1. Copy records into _tmp_ tables for
        -- a) billable tasks when the context is Budget Generation
        -- b) billable tasks when the context is Forecast Generation
        -- c) rate-based resources of non-billable tasks when the
        --    context is Forecast Generation
        l_tmp_index := 0;
        FOR i IN 1..l_tgt_res_asg_id_tab.count LOOP
            IF ( l_calling_context = lc_BudgetGeneration AND
                 l_billable_flag_tab(i) = 'Y' ) OR
               ( l_calling_context = lc_ForecastGeneration AND
                 ( l_billable_flag_tab(i) = 'Y' OR
                 ( l_billable_flag_tab(i) = 'N' AND l_tgt_rate_based_flag_tab(i) = 'Y' ))) THEN

                l_tmp_tgt_res_asg_id_tab.extend;
                l_tmp_tgt_rate_based_flag_tab.extend;
                l_tmp_txn_currency_code_tab.extend;
                l_tmp_src_quantity_tab.extend;
                l_tmp_src_raw_cost_tab.extend;
                l_tmp_src_brdn_cost_tab.extend;
                l_tmp_src_revenue_tab.extend;
                l_tmp_cost_rate_override_tab.extend;
                l_tmp_b_cost_rate_override_tab.extend;
                l_tmp_bill_rate_override_tab.extend;
                l_tmp_billable_flag_tab.extend;

                l_tmp_index := l_tmp_index + 1;
                l_tmp_tgt_res_asg_id_tab(l_tmp_index)       := l_tgt_res_asg_id_tab(i);
                l_tmp_tgt_rate_based_flag_tab(l_tmp_index)  := l_tgt_rate_based_flag_tab(i);
                l_tmp_txn_currency_code_tab(l_tmp_index)    := l_txn_currency_code_tab(i);
                l_tmp_src_quantity_tab(l_tmp_index)         := l_src_quantity_tab(i);
                l_tmp_src_raw_cost_tab(l_tmp_index)         := l_src_raw_cost_tab(i);
                l_tmp_src_brdn_cost_tab(l_tmp_index)        := l_src_brdn_cost_tab(i);
                l_tmp_src_revenue_tab(l_tmp_index)          := l_src_revenue_tab(i);
                l_tmp_cost_rate_override_tab(l_tmp_index)   := l_cost_rate_override_tab(i);
                l_tmp_b_cost_rate_override_tab(l_tmp_index) := l_b_cost_rate_override_tab(i);
                l_tmp_bill_rate_override_tab(l_tmp_index)   := l_bill_rate_override_tab(i);
                l_tmp_billable_flag_tab(l_tmp_index)        := l_billable_flag_tab(i);
            END IF;
        END LOOP;

        -- 2. Copy records from _tmp_ tables back to non-temporary tables.
        l_tgt_res_asg_id_tab       := l_tmp_tgt_res_asg_id_tab;
        l_tgt_rate_based_flag_tab  := l_tmp_tgt_rate_based_flag_tab;
        l_txn_currency_code_tab    := l_tmp_txn_currency_code_tab;
        l_src_quantity_tab         := l_tmp_src_quantity_tab;
        l_src_raw_cost_tab         := l_tmp_src_raw_cost_tab;
        l_src_brdn_cost_tab        := l_tmp_src_brdn_cost_tab;
        l_src_revenue_tab          := l_tmp_src_revenue_tab;
        l_cost_rate_override_tab   := l_tmp_cost_rate_override_tab;
        l_b_cost_rate_override_tab := l_tmp_b_cost_rate_override_tab;
        l_bill_rate_override_tab   := l_tmp_bill_rate_override_tab;
        l_billable_flag_tab        := l_tmp_billable_flag_tab;

    END IF; -- ER 4376722 billability logic for REVENUE versions

    l_remove_records_flag := 'N';
    -- Initialize l_remove_record_flag_tab
    FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
        l_remove_record_flag_tab(i) := 'N';
    END LOOP;

    /* We split up the generation logic here based on whether the Calling Context
     * indicates we are performing budget generation or forecast generation. */
    IF l_calling_context = lc_BudgetGeneration THEN
        IF l_source_version_type = 'COST' AND l_target_version_type = 'COST' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                IF l_tgt_rate_based_flag_tab(i) = 'N' AND
                   NOT( l_wp_track_cost_flag = 'N' AND
                        l_gen_src_code = lc_WorkPlanSrcCode ) THEN
                    l_src_quantity_tab(i):= l_src_raw_cost_tab(i);
                END IF;
                IF l_src_quantity_tab(i) <> 0 THEN
                    l_cost_rate_override_tab(i) := l_src_raw_cost_tab(i) / l_src_quantity_tab(i);
                    l_b_cost_rate_override_tab(i) := l_src_brdn_cost_tab(i) / l_src_quantity_tab(i);
                    IF l_tgt_rate_based_flag_tab(i) = 'N' THEN
                        l_cost_rate_override_tab(i) := 1;
                    END IF;
                END IF;
            END LOOP;
        ELSIF l_source_version_type = 'COST' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'T' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                IF l_tgt_rate_based_flag_tab(i) = 'N' AND
                   NOT( l_wp_track_cost_flag = 'N' AND
                        l_gen_src_code = lc_WorkPlanSrcCode ) THEN
                    l_src_quantity_tab(i):= l_src_raw_cost_tab(i); --???

                    -- Bug 4568011: Commented out revenue and bill rate override
                    -- pl/sql table assignments so that the Calculate API will
                    -- compute revenue amounts.
                    -- l_src_revenue_tab(i) := l_src_raw_cost_tab(i);
                    -- l_bill_rate_override_tab(i) := 1;
                END IF;
                IF l_src_quantity_tab(i) <> 0 THEN
                    l_cost_rate_override_tab(i) := l_src_raw_cost_tab(i) / l_src_quantity_tab(i);
                    l_b_cost_rate_override_tab(i) := l_src_brdn_cost_tab(i) / l_src_quantity_tab(i);
                    IF l_tgt_rate_based_flag_tab(i) = 'N' THEN
                        l_cost_rate_override_tab(i) := 1;
                    END IF;
                END IF;
                l_src_raw_cost_tab(i) := NULL;
                l_src_brdn_cost_tab(i) := NULL;
            END LOOP;
        ELSIF l_source_version_type = 'COST' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'C' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                l_src_quantity_tab(i):= l_src_brdn_cost_tab(i);
                l_src_revenue_tab(i) := l_src_brdn_cost_tab(i);
                l_src_raw_cost_tab(i) := NULL;
                l_src_brdn_cost_tab(i) := NULL;
                l_bill_rate_override_tab(i) := 1;
            END LOOP;
        ELSIF l_source_version_type = 'COST' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'E' THEN
            /*Revenue is only based on billing events, which is handled seperately*/
            l_dummy := 1;
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.RESET_CURR_FUNCTION;
            END IF;
            RETURN;
        ELSIF l_source_version_type = 'COST' AND
              l_target_version_type = 'ALL' AND
              l_rev_gen_method = 'T' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                IF l_tgt_rate_based_flag_tab(i) = 'N' AND
                   NOT( l_wp_track_cost_flag = 'N' AND
                        l_gen_src_code = lc_WorkPlanSrcCode ) THEN
                    l_dummy := 1; --l_src_quantity_tab(i):= l_src_raw_cost_tab(i);
                END IF;
                IF l_src_quantity_tab(i) <> 0 THEN
                    l_cost_rate_override_tab(i) := l_src_raw_cost_tab(i) / l_src_quantity_tab(i);
                    l_b_cost_rate_override_tab(i) := l_src_brdn_cost_tab(i) / l_src_quantity_tab(i);
                    IF l_tgt_rate_based_flag_tab(i) = 'N' THEN
                        l_cost_rate_override_tab(i) := 1;
                    END IF;
                END IF;
            END LOOP;
        ELSIF l_source_version_type = 'COST' AND
              l_target_version_type = 'ALL' AND
              l_rev_gen_method = 'C' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                IF l_tgt_rate_based_flag_tab(i) = 'N' AND
                   NOT( l_wp_track_cost_flag = 'N' AND
                        l_gen_src_code = lc_WorkPlanSrcCode ) THEN
                    l_src_quantity_tab(i):= l_src_raw_cost_tab(i);
                END IF;
                IF l_src_quantity_tab(i) <> 0 THEN
                    l_cost_rate_override_tab(i) := l_src_raw_cost_tab(i) / l_src_quantity_tab(i);
                    l_b_cost_rate_override_tab(i) := l_src_brdn_cost_tab(i) / l_src_quantity_tab(i);
                    IF l_tgt_rate_based_flag_tab(i) = 'N' THEN
                        l_cost_rate_override_tab(i) := 1;
                    END IF;
                END IF;
            END LOOP;
        ELSIF l_source_version_type = 'COST' AND
              l_target_version_type = 'ALL' AND
              l_rev_gen_method = 'E' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                IF l_tgt_rate_based_flag_tab(i) = 'N' AND
                   NOT( l_wp_track_cost_flag = 'N' AND
                        l_gen_src_code = lc_WorkPlanSrcCode ) THEN
                    l_src_quantity_tab(i):= l_src_raw_cost_tab(i);
                END IF;
                IF l_src_quantity_tab(i) <> 0 THEN
                    l_cost_rate_override_tab(i) := l_src_raw_cost_tab(i) / l_src_quantity_tab(i);
                    l_b_cost_rate_override_tab(i) := l_src_brdn_cost_tab(i) / l_src_quantity_tab(i);
                    IF l_tgt_rate_based_flag_tab(i) = 'N' THEN
                        l_cost_rate_override_tab(i) := 1;
                    END IF;
                END IF;
            END LOOP;
            /*Revenue is only based on billing events, which is handled seperately*/
---============================================================================
        ELSIF l_source_version_type = 'REVENUE' AND
              l_target_version_type = 'COST' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                IF  l_tgt_rate_based_flag_tab(i) = 'N' THEN
                    l_src_quantity_tab(i):= l_src_revenue_tab(i); --???
                END IF;
                l_src_revenue_tab(i) := NULL;
            END LOOP;
        ELSIF l_source_version_type = 'REVENUE' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'T' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                IF  l_tgt_rate_based_flag_tab(i) = 'N' THEN
                    l_src_quantity_tab(i):= l_src_revenue_tab(i);
                END IF;
                IF l_src_quantity_tab(i) <> 0 THEN
                    l_bill_rate_override_tab(i) := l_src_revenue_tab(i) / l_src_quantity_tab(i);
                END IF;
            END LOOP;
        ELSIF l_source_version_type = 'REVENUE' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'C' THEN
            /*This is invalid operation, had been handled at the beginning of process*/
            l_dummy := 1;
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.RESET_CURR_FUNCTION;
            END IF;
            RETURN;
        ELSIF l_source_version_type = 'REVENUE' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'E' THEN
            /*Revenue is only based on billing events, which is handled seperately*/
            l_dummy := 1;
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.RESET_CURR_FUNCTION;
            END IF;
            RETURN;
        ELSIF l_source_version_type = 'REVENUE' AND
              l_target_version_type = 'ALL' AND
              l_rev_gen_method = 'T' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                IF  l_tgt_rate_based_flag_tab(i) = 'N' THEN
                    l_src_quantity_tab(i):= l_src_revenue_tab(i);
                END IF;
                IF l_src_quantity_tab(i) <> 0 THEN
                    l_bill_rate_override_tab(i) := l_src_revenue_tab(i)/l_src_quantity_tab(i);
                END IF;
            END LOOP;
        ELSIF l_source_version_type = 'REVENUE' AND
              l_target_version_type = 'ALL' AND
              l_rev_gen_method = 'C' THEN
            /*This is invalid operation, had been handled at the beginning of process*/
            l_dummy := 1;
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.RESET_CURR_FUNCTION;
            END IF;
            RETURN;
        ELSIF l_source_version_type = 'REVENUE' AND
              l_target_version_type = 'ALL' AND
              l_rev_gen_method = 'E' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                IF  l_tgt_rate_based_flag_tab(i) = 'N' THEN
                    l_src_quantity_tab(i):= l_src_revenue_tab(i); --???
                END IF;
            l_src_revenue_tab(i) := NULL;
            END LOOP;
            /*Revenue is only based on billing events, which is handled seperately*/
--============================================================================
        ELSIF l_source_version_type = 'ALL' AND l_target_version_type = 'COST' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                IF l_tgt_rate_based_flag_tab(i) = 'N' THEN
                    l_src_quantity_tab(i):= l_src_raw_cost_tab(i);
                END IF;
                l_src_revenue_tab(i) := NULL;
                IF l_src_quantity_tab(i) <> 0 THEN
                    l_cost_rate_override_tab(i) := l_src_raw_cost_tab(i) / l_src_quantity_tab(i);
                    l_b_cost_rate_override_tab(i) := l_src_brdn_cost_tab(i) / l_src_quantity_tab(i);
                ELSE -- Added for IPM
                    l_remove_record_flag_tab(i) := 'Y';
                    l_remove_records_flag := 'Y';
                END IF;
            END LOOP;
        ELSIF l_source_version_type = 'ALL' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'T' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP

                -- Bug 4568011: When Source revenue amounts exist, the
                -- Calculate API should honor those amounts instead of
                -- computing revenue amounts. For this to happen, the
                -- REVENUE_BILL_RATE column of the PA_FP_GEN_RATE_TMP
                -- table needs to be populated with the bill rate override.
                -- Likewise, when Source revenue amounts do not exist,
                -- the Calculate API should compute revenue amounts. In
                -- this case, the bill rate override should be NULL.

                IF l_tgt_rate_based_flag_tab(i) = 'N' THEN
                    IF l_src_revenue_tab(i) IS NOT NULL THEN
                        l_src_quantity_tab(i):= l_src_revenue_tab(i);
                    ELSE
                        l_src_quantity_tab(i):= l_src_raw_cost_tab(i);
                    END IF;
                END IF;
                IF l_src_quantity_tab(i) <> 0 THEN
                    l_cost_rate_override_tab(i) := l_src_raw_cost_tab(i) / l_src_quantity_tab(i);
                    l_b_cost_rate_override_tab(i) := l_src_brdn_cost_tab(i) / l_src_quantity_tab(i);
                    l_bill_rate_override_tab(i) := l_src_revenue_tab(i) / l_src_quantity_tab(i);
                ELSE -- Added for IPM
                    l_remove_record_flag_tab(i) := 'Y';
                    l_remove_records_flag := 'Y';
                END IF;
                l_src_raw_cost_tab(i) := NULL;
                l_src_brdn_cost_tab(i) := NULL;
            END LOOP;
       ELSIF l_source_version_type = 'ALL' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'C' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                l_src_quantity_tab(i):= l_src_brdn_cost_tab(i);
                l_src_revenue_tab(i) := l_src_brdn_cost_tab(i);
                l_src_raw_cost_tab(i) := NULL;
                l_src_brdn_cost_tab(i) := NULL;
                l_bill_rate_override_tab(i) := 1;
                -- Added for IPM
                IF nvl(l_src_quantity_tab(i),0) = 0 THEN
                    l_remove_record_flag_tab(i) := 'Y';
                    l_remove_records_flag := 'Y';
                END IF;
            END LOOP;
        ELSIF l_source_version_type = 'ALL' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'E' THEN
            /*Revenue is only based on billing events, which is handled seperately*/
            l_dummy := 1;
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.RESET_CURR_FUNCTION;
            END IF;
            RETURN;
        ELSIF l_source_version_type = 'ALL' AND
              l_target_version_type = 'ALL' AND
              l_rev_gen_method = 'T' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                IF l_tgt_rate_based_flag_tab(i) = 'N' THEN
                    -- Modified for IPM
                    IF nvl(l_src_raw_cost_tab(i),0) = 0 THEN
                        -- Source is a revenue-only txn (qty = rev).
                        l_src_quantity_tab(i):= l_src_revenue_tab(i);
                    ELSE
                        l_src_quantity_tab(i):= l_src_raw_cost_tab(i);
                    END IF;
                END IF;
                IF l_src_quantity_tab(i) <> 0 THEN
                    l_cost_rate_override_tab(i) := l_src_raw_cost_tab(i) / l_src_quantity_tab(i);
                    l_b_cost_rate_override_tab(i) := l_src_brdn_cost_tab(i) / l_src_quantity_tab(i);
                    l_bill_rate_override_tab(i) := l_src_revenue_tab(i) / l_src_quantity_tab(i);
                ELSE -- Added for IPM
                    l_remove_record_flag_tab(i) := 'Y';
                    l_remove_records_flag := 'Y';
                END IF;
             END LOOP;
        ELSIF l_source_version_type = 'ALL' AND
              l_target_version_type = 'ALL' AND
              l_rev_gen_method = 'C' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                IF l_tgt_rate_based_flag_tab(i) = 'N' THEN
                    -- Modified for IPM
                    IF nvl(l_src_raw_cost_tab(i),0) = 0 THEN
                        -- Source is a revenue-only txn (qty = rev).
                        -- Do not generate cost from a revenue amount.
                        -- Nulling out qty will cause the record to be skipped.
                        l_src_quantity_tab(i):= null;
                    ELSE
                        l_src_quantity_tab(i):= l_src_raw_cost_tab(i);
                    END IF;
                END IF;
                l_src_revenue_tab(i) := l_src_brdn_cost_tab(i);
                IF l_src_quantity_tab(i) <> 0 THEN
                    l_cost_rate_override_tab(i) := l_src_raw_cost_tab(i) / l_src_quantity_tab(i);
                    l_b_cost_rate_override_tab(i) := l_src_brdn_cost_tab(i) / l_src_quantity_tab(i);
                    l_bill_rate_override_tab(i) := l_src_revenue_tab(i) / l_src_quantity_tab(i);
                ELSE -- Added for IPM
                    l_remove_record_flag_tab(i) := 'Y';
                    l_remove_records_flag := 'Y';
                END IF;
            END LOOP;
        ELSIF l_source_version_type = 'ALL' AND
              l_target_version_type = 'ALL' AND
              l_rev_gen_method = 'E' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                IF  l_tgt_rate_based_flag_tab(i) = 'N' THEN
                    -- Modified for IPM
                    IF nvl(l_src_raw_cost_tab(i),0) = 0 THEN
                        -- Source is a revenue-only txn (qty = rev).
                        -- Do not double count the revenue amount.
                        -- Nulling out qty will cause the record to be skipped.
                        l_src_quantity_tab(i):= null;
                    ELSE
                        l_src_quantity_tab(i):= l_src_raw_cost_tab(i);
                    END IF;
                END IF;
                IF l_src_quantity_tab(i) <> 0 THEN
                    l_cost_rate_override_tab(i) := l_src_raw_cost_tab(i) / l_src_quantity_tab(i);
                    l_b_cost_rate_override_tab(i) := l_src_brdn_cost_tab(i) / l_src_quantity_tab(i);
                ELSE -- Added for IPM
                    l_remove_record_flag_tab(i) := 'Y';
                    l_remove_records_flag := 'Y';
                END IF;
                /* When generation is Event-based, we get revenues from the billing events. If we
                 * include revenues from the source, revenues will be double counted. Therefore,
                 * we set source revenue amounts to NULL so calculate API doesn't include. */
                l_src_revenue_tab(i) := NULL;
            END LOOP;
            /*Revenue is only based on billing events, which is handled seperately.*/
        END IF;
        /*End refer to document: How to derive the rate*/

    /* Revenue forecast generation logic */
    ELSIF l_calling_context = lc_ForecastGeneration THEN
        IF l_source_version_type = 'COST' AND
           l_target_version_type = 'REVENUE' AND
           l_rev_gen_method = 'T' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                IF l_tgt_rate_based_flag_tab(i) = 'N' THEN
                    /* currently using raw cost instead of burden cost to mimic budget generation logic */
                    l_src_quantity_tab(i)  := l_src_raw_cost_tab(i); --???

                    -- Bug 4568011: Commented out revenue and bill rate override
                    -- pl/sql table assignments so that the Calculate API will
                    -- compute revenue amounts.
                    -- l_src_revenue_tab(i)   := l_src_raw_cost_tab(i);
                    -- l_bill_rate_override_tab(i) := 1;
                END IF;
                IF l_src_quantity_tab(i) <> 0 THEN
                    l_cost_rate_override_tab(i) := l_src_raw_cost_tab(i) / l_src_quantity_tab(i);
                    l_b_cost_rate_override_tab(i) := l_src_brdn_cost_tab(i) / l_src_quantity_tab(i);
                END IF;
                l_src_raw_cost_tab(i)  := NULL;
                l_src_brdn_cost_tab(i) := NULL;
            END LOOP;
        ELSIF l_source_version_type = 'COST' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'C' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                l_src_quantity_tab(i)  := l_src_brdn_cost_tab(i);
                l_src_revenue_tab(i)   := l_src_brdn_cost_tab(i);
                l_src_raw_cost_tab(i)  := NULL;
                l_src_brdn_cost_tab(i) := NULL;
                l_bill_rate_override_tab(i) := 1;
            END LOOP;
        ELSIF l_source_version_type = 'COST' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'E' THEN
            /* This stub is here for completeness in the flow of the generation logic.
             * We do nothing here because the wrapper API does not call this procedure
             * in the case of Event-based revenue generation. Hence, we should never
             * arrive here in a valid code path. */
            l_dummy := 1;
        ELSIF l_source_version_type = 'ALL' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'T' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP

                -- Bug 4568011: When Source revenue amounts exist, the
                -- Calculate API should honor those amounts instead of
                -- computing revenue amounts. For this to happen, the
                -- REVENUE_BILL_RATE column of the PA_FP_GEN_RATE_TMP
                -- table needs to be populated with the bill rate override.
                -- Likewise, when Source revenue amounts do not exist,
                -- the Calculate API should compute revenue amounts. In
                -- this case, the bill rate override should be NULL.

                IF l_tgt_rate_based_flag_tab(i) = 'N' THEN
                    IF l_src_revenue_tab(i) IS NOT NULL THEN
                        l_src_quantity_tab(i):= l_src_revenue_tab(i);
                    ELSE
                        l_src_quantity_tab(i):= l_src_raw_cost_tab(i);
                    END IF;
                END IF;
                IF l_src_quantity_tab(i) <> 0 THEN
                    l_cost_rate_override_tab(i) := l_src_raw_cost_tab(i) / l_src_quantity_tab(i);
                    l_b_cost_rate_override_tab(i) := l_src_brdn_cost_tab(i) / l_src_quantity_tab(i);
                    l_bill_rate_override_tab(i) := l_src_revenue_tab(i) / l_src_quantity_tab(i);
                ELSE -- Added for IPM
                    l_remove_record_flag_tab(i) := 'Y';
                    l_remove_records_flag := 'Y';
                END IF;
                l_src_raw_cost_tab(i)  := NULL;
                l_src_brdn_cost_tab(i) := NULL;
            END LOOP;
        ELSIF l_source_version_type = 'ALL' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'C' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                l_src_quantity_tab(i)  := l_src_brdn_cost_tab(i);
                l_src_revenue_tab(i)   := l_src_brdn_cost_tab(i);
                l_src_raw_cost_tab(i)  := NULL;
                l_src_brdn_cost_tab(i) := NULL;
                l_bill_rate_override_tab(i) := 1;
                -- Added for IPM
                IF nvl(l_src_quantity_tab(i),0) = 0 THEN
                    l_remove_record_flag_tab(i) := 'Y';
                    l_remove_records_flag := 'Y';
                END IF;
            END LOOP;
        ELSIF l_source_version_type = 'ALL' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'E' THEN
            /* This stub is here for completeness in the flow of the generation logic.
             * We do nothing here because the wrapper API does not call this procedure
             * in the case of Event-based revenue generation. Hence, we should never
             * arrive here in a valid code path. */
            l_dummy := 1;
        END IF; -- revenue forecast logic

    END IF; -- context-based generation logic


    /* ER 4376722: When the Target is a Revenue-only Forecast, we
     * generate quantity but not revenue for rate-based resources of
     * non-billable tasks. To do this, null out revenue amounts and
     * rate overrides for rate-based resources of non-billable tasks.
     * Note that we handle the case of non-rated-based resources
     * of non-billable tasks earlier in the code. */

    IF l_target_version_type = 'REVENUE' AND
       l_calling_context = lc_ForecastGeneration THEN
        FOR i IN 1..l_tgt_res_asg_id_tab.count LOOP
            IF l_billable_flag_tab(i) = 'N' AND
               l_tgt_rate_based_flag_tab(i) = 'Y' THEN
                l_src_revenue_tab(i) := NULL;
                l_bill_rate_override_tab(i) := NULL;
                -- null out cost rate overrides in case of Work-based revenue
                l_cost_rate_override_tab(i) := NULL;
                l_b_cost_rate_override_tab(i) := NULL;
            END IF;
        END LOOP;
    END IF; -- ER 4376722 billability logic for REVENUE Forecast

    /* ER 4376722: When the Target is a Cost and Revenue together
     * version, we do not generate revenue for non-billable tasks.
     * To do this, simply null out revenue amounts for non-billable
     * tasks. The result is that revenue amounts for non-billable
     * tasks will not be written to the budget lines. */

    IF l_target_version_type = 'ALL' THEN
        -- Null out revenue amounts for non-billable tasks
        FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
            IF l_billable_flag_tab(i) = 'N' THEN
	        l_src_revenue_tab(i) := null;
	        l_bill_rate_override_tab(i) := null;

                -- IPM: If the current txn has only revenue amounts,
                -- then process using the rules for revenue-only versions.
                IF ( l_calling_context = lc_BudgetGeneration AND
                     nvl(l_src_raw_cost_tab(i),0) = 0 ) OR
                   ( l_calling_context = lc_ForecastGeneration AND
                     nvl(l_src_raw_cost_tab(i),0) = 0 AND
                     l_tgt_rate_based_flag_tab(i) = 'N' ) THEN
                    -- Skip over the record in this case so that
                    -- cost is not generated from a revenue amount.
                    l_remove_record_flag_tab(i) := 'Y';
                    l_remove_records_flag := 'Y';
                END IF; -- revenue-only txn logic
            END IF;
        END LOOP;
    END IF; -- ER 4376722 billability logic for ALL versions

    -- Added in IPM. If there are any pl/sql table records that need to
    -- be removed, use a separate set of _tmp_ tables to filter them out.

    IF l_remove_records_flag = 'Y' THEN

        -- 0. Clear out any data in the _tmp_ tables.
        l_tmp_tgt_res_asg_id_tab.delete;
        l_tmp_tgt_rate_based_flag_tab.delete;
        l_tmp_txn_currency_code_tab.delete;
        l_tmp_src_quantity_tab.delete;
        l_tmp_src_raw_cost_tab.delete;
        l_tmp_src_brdn_cost_tab.delete;
        l_tmp_src_revenue_tab.delete;
        l_tmp_cost_rate_override_tab.delete;
        l_tmp_b_cost_rate_override_tab.delete;
        l_tmp_bill_rate_override_tab.delete;
        l_tmp_billable_flag_tab.delete;

        -- 1. Copy records into _tmp_ tables
        l_tmp_index := 0;
        FOR i IN 1..l_tgt_res_asg_id_tab.count LOOP
            IF l_remove_record_flag_tab(i) <> 'Y' THEN
                l_tmp_tgt_res_asg_id_tab.extend;
                l_tmp_tgt_rate_based_flag_tab.extend;
                l_tmp_txn_currency_code_tab.extend;
                l_tmp_src_quantity_tab.extend;
                l_tmp_src_raw_cost_tab.extend;
                l_tmp_src_brdn_cost_tab.extend;
                l_tmp_src_revenue_tab.extend;
                l_tmp_cost_rate_override_tab.extend;
                l_tmp_b_cost_rate_override_tab.extend;
                l_tmp_bill_rate_override_tab.extend;
                l_tmp_billable_flag_tab.extend;

                l_tmp_index := l_tmp_index + 1;
                l_tmp_tgt_res_asg_id_tab(l_tmp_index)       := l_tgt_res_asg_id_tab(i);
                l_tmp_tgt_rate_based_flag_tab(l_tmp_index)  := l_tgt_rate_based_flag_tab(i);
                l_tmp_txn_currency_code_tab(l_tmp_index)    := l_txn_currency_code_tab(i);
                l_tmp_src_quantity_tab(l_tmp_index)         := l_src_quantity_tab(i);
                l_tmp_src_raw_cost_tab(l_tmp_index)         := l_src_raw_cost_tab(i);
                l_tmp_src_brdn_cost_tab(l_tmp_index)        := l_src_brdn_cost_tab(i);
                l_tmp_src_revenue_tab(l_tmp_index)          := l_src_revenue_tab(i);
                l_tmp_cost_rate_override_tab(l_tmp_index)   := l_cost_rate_override_tab(i);
                l_tmp_b_cost_rate_override_tab(l_tmp_index) := l_b_cost_rate_override_tab(i);
                l_tmp_bill_rate_override_tab(l_tmp_index)   := l_bill_rate_override_tab(i);
                l_tmp_billable_flag_tab(l_tmp_index)        := l_billable_flag_tab(i);
            END IF;
        END LOOP;

        -- 2. Copy records from _tmp_ tables back to non-temporary tables.
        l_tgt_res_asg_id_tab       := l_tmp_tgt_res_asg_id_tab;
        l_tgt_rate_based_flag_tab  := l_tmp_tgt_rate_based_flag_tab;
        l_txn_currency_code_tab    := l_tmp_txn_currency_code_tab;
        l_src_quantity_tab         := l_tmp_src_quantity_tab;
        l_src_raw_cost_tab         := l_tmp_src_raw_cost_tab;
        l_src_brdn_cost_tab        := l_tmp_src_brdn_cost_tab;
        l_src_revenue_tab          := l_tmp_src_revenue_tab;
        l_cost_rate_override_tab   := l_tmp_cost_rate_override_tab;
        l_b_cost_rate_override_tab := l_tmp_b_cost_rate_override_tab;
        l_bill_rate_override_tab   := l_tmp_bill_rate_override_tab;
        l_billable_flag_tab        := l_tmp_billable_flag_tab;

    END IF; -- IPM record removal logic

   /*********************************************************************
 	   ER 5726773: Commenting out logic that filters out planning
 	                transaction records with: (total plan quantity <= 0).

 	--   Bug #4938603: Adding code to filter out records with
	--    total plan quantity < 0

    -- 0. Clear out any data in the _tmp_ tables.
    l_tmp_tgt_res_asg_id_tab.delete;
    l_tmp_tgt_rate_based_flag_tab.delete;
    l_tmp_txn_currency_code_tab.delete;
    l_tmp_src_quantity_tab.delete;
    l_tmp_src_raw_cost_tab.delete;
    l_tmp_src_brdn_cost_tab.delete;
    l_tmp_src_revenue_tab.delete;
    l_tmp_cost_rate_override_tab.delete;
    l_tmp_b_cost_rate_override_tab.delete;
    l_tmp_bill_rate_override_tab.delete;
    l_tmp_billable_flag_tab.delete;

    l_tmp_index := 0;
    -- 1. Copy records into _tmp_ tables for
    FOR i IN 1..l_tgt_res_asg_id_tab.count LOOP
        IF (l_calling_context = lc_BudgetGeneration) THEN
            l_total_plan_qty := nvl(l_src_quantity_tab(i),0);
        ELSIF (l_calling_context = lc_ForecastGeneration) THEN
            OPEN fcst_bdgt_line_actual_qty(l_tgt_res_asg_id_tab(i),l_txn_currency_code_tab(i));
            FETCH fcst_bdgt_line_actual_qty INTO l_init_qty ;
            CLOSE fcst_bdgt_line_actual_qty;
            l_total_plan_qty := nvl(l_init_qty,0) + nvl(l_src_quantity_tab(i),0);
        END IF;
        IF l_total_plan_qty > 0 THEN
            l_tmp_tgt_res_asg_id_tab.extend;
            l_tmp_tgt_rate_based_flag_tab.extend;
            l_tmp_txn_currency_code_tab.extend;
            l_tmp_src_quantity_tab.extend;
            l_tmp_src_raw_cost_tab.extend;
            l_tmp_src_brdn_cost_tab.extend;
            l_tmp_src_revenue_tab.extend;
            l_tmp_cost_rate_override_tab.extend;
            l_tmp_b_cost_rate_override_tab.extend;
            l_tmp_bill_rate_override_tab.extend;
            l_tmp_billable_flag_tab.extend;

            l_tmp_index := l_tmp_index + 1;
            l_tmp_tgt_res_asg_id_tab(l_tmp_index)       := l_tgt_res_asg_id_tab(i);
            l_tmp_tgt_rate_based_flag_tab(l_tmp_index)  := l_tgt_rate_based_flag_tab(i);
            l_tmp_txn_currency_code_tab(l_tmp_index)    := l_txn_currency_code_tab(i);
            l_tmp_src_quantity_tab(l_tmp_index)         := l_src_quantity_tab(i);
            l_tmp_src_raw_cost_tab(l_tmp_index)         := l_src_raw_cost_tab(i);
            l_tmp_src_brdn_cost_tab(l_tmp_index)        := l_src_brdn_cost_tab(i);
            l_tmp_src_revenue_tab(l_tmp_index)          := l_src_revenue_tab(i);
            l_tmp_cost_rate_override_tab(l_tmp_index)   := l_cost_rate_override_tab(i);
            l_tmp_b_cost_rate_override_tab(l_tmp_index) := l_b_cost_rate_override_tab(i);
            l_tmp_bill_rate_override_tab(l_tmp_index)   := l_bill_rate_override_tab(i);
            l_tmp_billable_flag_tab(l_tmp_index)        := l_billable_flag_tab(i);
        END IF;
    END LOOP;

    -- 2. Copy records from _tmp_ tables back to non-temporary tables.
    l_tgt_res_asg_id_tab       := l_tmp_tgt_res_asg_id_tab;
    l_tgt_rate_based_flag_tab  := l_tmp_tgt_rate_based_flag_tab;
    l_txn_currency_code_tab    := l_tmp_txn_currency_code_tab;
    l_src_quantity_tab         := l_tmp_src_quantity_tab;
    l_src_raw_cost_tab         := l_tmp_src_raw_cost_tab;
    l_src_brdn_cost_tab        := l_tmp_src_brdn_cost_tab;
    l_src_revenue_tab          := l_tmp_src_revenue_tab;
    l_cost_rate_override_tab   := l_tmp_cost_rate_override_tab;
    l_b_cost_rate_override_tab := l_tmp_b_cost_rate_override_tab;
    l_bill_rate_override_tab   := l_tmp_bill_rate_override_tab;
    l_billable_flag_tab        := l_tmp_billable_flag_tab;

    -- End of code for #4938603

   ER 5726773: End of commented out section.
 *********************************************************************/

    -- ER 4376722: Consolidated update of UOM and rate_based_flag for
    -- cost-based Revenue generation within the this API before any
    -- cursor is called. This ensures that values in the rate_base_flag
    -- pl/sql tables are accurate. Before this change, an identical
    -- update was done in MAINTAIN_BUDGET_LINES as well as in this API
    -- after cursors were used and generation logic was performed.

/******************** Commented Out *********************
    IF l_fp_cols_rec_target.x_version_type = 'REVENUE' and
       l_rev_gen_method = 'C' THEN
        l_res_asg_uom_update_tab.DELETE;
        SELECT DISTINCT txn_resource_assignment_id
        BULK COLLECT INTO l_res_asg_uom_update_tab
        FROM pa_res_list_map_tmp4;

        FORALL i IN 1..l_res_asg_uom_update_tab.count
            UPDATE pa_resource_assignments
               SET unit_of_measure = 'DOLLARS',
                   rate_based_flag = 'N'
             WHERE resource_assignment_id = l_res_asg_uom_update_tab(i);
    END IF;
******************** End Commenting **********************/

    -- Bug 3968748: We need to populate the PA_FP_GEN_RATE_TMP table with
    -- burdened cost rates for non-rate-based resources for Calculate API
    -- when generating work-based revenue for a Revenue-only target version.

    -- Bug 4216423: We now need to populate PA_FP_GEN_RATE_TMP with cost
    -- rates for both rate-based and non-rate based resources when generating
    -- work-based revenue for a Revenue-only target version.

    /* ER 4376722: Note that we do not need to modify the logic for populating
     * PA_FP_GEN_RATE_TMP here, since we already removed pl/sql table records
     * for non-billable tasks earlier in the code for Revenue-only target versions. */

    -- Bug 4568011: Added REVENUE_BILL_RATE to list of inserted columns.
    -- When the value is non-null, the Calculate API will honor the given
    -- bill rate instead of computing revenue amounts.

    IF l_fp_cols_rec_target.x_version_type = 'REVENUE' AND l_rev_gen_method = 'T' THEN
        DELETE pa_fp_gen_rate_tmp;
        /* For summary level calculation, we should leave period_name NULL */
        FORALL i IN 1..l_tgt_res_asg_id_tab.count
            INSERT INTO pa_fp_gen_rate_tmp
                   ( TARGET_RES_ASG_ID,
                     TXN_CURRENCY_CODE,
                     RAW_COST_RATE,
                     BURDENED_COST_RATE,
                     REVENUE_BILL_RATE )            /* Added for Bug 4568011 */
            VALUES ( l_tgt_res_asg_id_tab(i),
                     l_txn_currency_code_tab(i),
                     l_cost_rate_override_tab(i),
                     l_b_cost_rate_override_tab(i),
                     l_bill_rate_override_tab(i) ); /* Added for Bug 4568011 */
    END IF;

  END IF;
  /* end if for source and target time phase and res list chk */

-- ER 5726773: Pass cost amounts as Null instead of 0 for
 	     -- non-rate-based, revenue-only txns in Cost-and-Revenue-together
 	     -- versions to avoid such txns disappearing during generation.
 	     IF l_target_version_type = 'ALL' THEN
 	         FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
 	             IF l_tgt_rate_based_flag_tab(i) = 'N' AND
 	                nvl(l_src_raw_cost_tab(i),0) = 0 AND
 	                nvl(l_src_revenue_tab(i),0) <> 0 THEN
 	                 l_src_raw_cost_tab(i) := null;
 	                 l_src_brdn_cost_tab(i) := null;
 	             END IF;
 	         END LOOP;
 	     END IF;

    --hr_utility.trace('??l_tgt_res_asg_id_tab.count:'|| l_tgt_res_asg_id_tab.count);
    --hr_utility.trace('??l_src_revenue_tab.count:'||l_src_revenue_tab.count);
    /*Initializing every pl/sql table to null*/
    FOR i in 1 .. l_tgt_res_asg_id_tab.count LOOP
        l_delete_budget_lines_tab.extend;
        l_spread_amts_flag_tab.extend;
        l_txn_currency_override_tab.extend;
        l_addl_qty_tab.extend;
        l_addl_raw_cost_tab.extend;
        l_addl_burdened_cost_tab.extend;
        l_addl_revenue_tab.extend;
        l_raw_cost_rate_tab.extend;
        l_b_cost_rate_tab.extend;
        l_bill_rate_tab.extend;
        l_line_start_date_tab.extend;
        l_line_end_date_tab.extend;

        l_delete_budget_lines_tab(i)    :=  Null;
        l_spread_amts_flag_tab(i)       :=  'Y';
        l_txn_currency_override_tab(i)  :=  Null;
        l_addl_qty_tab(i)               :=  Null;
        l_addl_raw_cost_tab(i)          :=  Null;
        l_addl_burdened_cost_tab(i)     :=  Null;
        l_addl_revenue_tab(i)           :=  Null;
        l_raw_cost_rate_tab(i)          :=  Null;
        l_b_cost_rate_tab(i)            :=  Null;
        l_bill_rate_tab(i)              :=  Null;
        l_line_start_date_tab(i)        :=  Null;
        l_line_end_date_tab(i)          :=  Null;

        --hr_utility.trace('----'||i||'-----');
        --hr_utility.trace('ra:'||l_tgt_res_asg_id_tab(i));
        --hr_utility.trace('rate based flag:'||l_tgt_rate_based_flag_tab(i));
        --hr_utility.trace('txn currency:'||l_txn_currency_code_tab(i));
        --hr_utility.trace('qty:'||l_src_quantity_tab(i));
        --hr_utility.trace('cost rate override:'||l_cost_rate_override_tab(i));
        --hr_utility.trace('bill rate override:'||l_bill_rate_override_tab(i));
        --hr_utility.trace('total brdn:'||l_src_brdn_cost_tab(i));
        --hr_utility.trace('total raw:'||l_src_raw_cost_tab(i));
        --hr_utility.trace('total_rev:'||l_src_revenue_tab(i));
    END LOOP;

    IF l_fp_cols_rec_target.x_version_type = 'REVENUE'
       AND l_rev_gen_method = 'C'
       AND l_wp_track_cost_flag <> 'Y' THEN
        delete from pa_fp_calc_amt_tmp2;
        FORALL i IN 1..l_tgt_res_asg_id_tab.count
            INSERT INTO pa_fp_calc_amt_tmp2(
            resource_assignment_id,
            txn_currency_code,
            TOTAL_PLAN_QUANTITY)
            VALUES(
            l_tgt_res_asg_id_tab(i),
            l_txn_currency_code_tab(i),
            l_src_quantity_tab(i));
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RETURN;
    END IF;

    /* Get the api code for the Calculate API call. */
    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_called_mode => p_called_mode,
              p_msg         => 'Before calling ' ||
                               'PA_FP_WP_GEN_BUDGET_AMT_PUB.GET_CALC_API_FLAG_PARAMS',
              p_module_name => l_module_name,
              p_log_level   => 5 );
    END IF;
    PA_FP_WP_GEN_BUDGET_AMT_PUB.GET_CALC_API_FLAG_PARAMS
       ( P_PROJECT_ID          => p_project_id,
         P_FP_COLS_REC_SOURCE  => l_fp_cols_rec_source,
         P_FP_COLS_REC_TARGET  => l_fp_cols_rec_target,
         P_CALLING_CONTEXT     => l_calling_context,
         X_CALCULATE_API_CODE  => l_calculate_api_code,
         X_RETURN_STATUS       => x_return_status,
         X_MSG_COUNT           => x_msg_count,
         X_MSG_DATA            => x_msg_data );
    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_called_mode => p_called_mode,
              p_msg         => 'Status after calling ' ||
                               'PA_FP_WP_GEN_BUDGET_AMT_PUB.GET_CALC_API_FLAG_PARAMS: ' ||
                               x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5 );
    END IF;
    IF x_return_Status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    /* Parse l_calculate_api_code to get the flag parameters for Calculate API */
    l_refresh_rates_flag         := SUBSTR(l_calculate_api_code,1,1);
    l_refresh_conv_rates_flag    := SUBSTR(l_calculate_api_code,2,1);
    l_spread_required_flag       := SUBSTR(l_calculate_api_code,3,1);
    l_conv_rates_required_flag   := SUBSTR(l_calculate_api_code,4,1);
    -- Bug 4149684: Added p_rollup_required_flag to parameter list of Calculate API with
    -- value 'N' so that calling PJI rollup api is bypassed for increased performance.
    l_rollup_required_flag       := 'N';
    l_raTxn_rollup_api_call_flag := 'N'; -- Added for IPM new entity ER

    /* Following part is commented out for bug 4297552
       For the context Forecast Generation, the total amounts should be passed
       to 'Calculate'. Actual plus the ETC amount. Currently, this API is called only when
       the plan version is a Revenue only Forecast version.
    IF p_calling_context = lc_ForecastGeneration THEN
       FOR k IN 1 .. l_tgt_res_asg_id_tab.COUNT LOOP
           BEGIN
              SELECT sum(init_quantity),sum(init_revenue) into
              l_calc_qty_tmp, l_calc_tmp_rev FROM
              pa_budget_lines where
              resource_assignment_id = l_tgt_res_asg_id_tab(k) AND
              txn_currency_code = l_txn_currency_code_tab(k);
           EXCEPTION
           WHEN NO_DATA_FOUND THEN
                l_calc_qty_tmp := 0;
                l_calc_tmp_rev := 0;
           END;
           l_src_quantity_tab(k) := nvl(l_src_quantity_tab(k),0) + nvl(l_calc_qty_tmp,0);
           l_src_revenue_tab(k)  := nvl(l_src_revenue_tab(k),0)  + nvl(l_calc_tmp_rev,0);
       END LOOP;
    END IF; */

    --hr_utility.trace('bef calling calculate api:'||x_return_status);
    /*Calling the calculate API*/
    IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_called_mode => p_called_mode,
              p_msg         => 'Before calling
                               PA_FP_CALC_PLAN_PKG.calculate',
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;
    PA_FP_CALC_PLAN_PKG.calculate(
                       p_project_id                    => P_PROJECT_ID,
                       p_budget_version_id             => P_BUDGET_VERSION_ID,
                       p_refresh_rates_flag            => l_refresh_rates_flag,
                       p_refresh_conv_rates_flag       => l_refresh_conv_rates_flag,
                       p_spread_required_flag          => l_spread_required_flag,
                       p_conv_rates_required_flag      => l_conv_rates_required_flag,
                       p_rollup_required_flag          => l_rollup_required_flag,
                       p_source_context                => l_source_context,
                       p_resource_assignment_tab       => l_tgt_res_asg_id_tab,
                       p_delete_budget_lines_tab       => l_delete_budget_lines_tab,
                       p_spread_amts_flag_tab          => l_spread_amts_flag_tab,
                       p_txn_currency_code_tab         => l_txn_currency_code_tab,
                       p_txn_currency_override_tab     => l_txn_currency_override_tab,
                       p_total_qty_tab                 => l_src_quantity_tab,
                       p_addl_qty_tab                  => l_addl_qty_tab,
                       p_total_raw_cost_tab            => l_src_raw_cost_tab,
                       p_addl_raw_cost_tab             => l_addl_raw_cost_tab,
                       p_total_burdened_cost_tab       => l_src_brdn_cost_tab,
                       p_addl_burdened_cost_tab        => l_addl_burdened_cost_tab,
                       p_total_revenue_tab             => l_src_revenue_tab,
                       p_addl_revenue_tab              => l_addl_revenue_tab,
                       p_raw_cost_rate_tab             => l_raw_cost_rate_tab,
                       p_rw_cost_rate_override_tab     => l_cost_rate_override_tab,
                       p_b_cost_rate_tab               => l_b_cost_rate_tab,
                       p_b_cost_rate_override_tab      => l_b_cost_rate_override_tab,
                       p_bill_rate_tab                 => l_bill_rate_tab,
                       p_bill_rate_override_tab        => l_bill_rate_override_tab,
                       p_line_start_date_tab           => l_line_start_date_tab,
                       p_line_end_date_tab             => l_line_end_date_tab,
                       p_calling_module                => l_calling_context,
                       p_raTxn_rollup_api_call_flag    => l_raTxn_rollup_api_call_flag,
                       x_return_status                 => x_return_status,
                       x_msg_count                     => x_msg_count,
                       x_msg_data                      => x_msg_data);
    --hr_utility.trace('aft calling calculate api: '||x_return_status);

    IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_called_mode => p_called_mode,
              p_msg         => 'Status after calling
                              PA_FP_CALC_PLAN_PKG.calculate: '
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;
    IF x_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;
    IF p_commit_flag = 'Y' THEN
       COMMIT;
    END IF;
    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.RESET_CURR_FUNCTION;
    END IF;
EXCEPTION
    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count = 1 THEN
            PA_INTERFACE_UTILS_PUB.get_messages
                ( p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
            x_msg_data := l_data;
            x_msg_count := l_msg_count;
        ELSE
            x_msg_count := l_msg_count;
        END IF;

        ROLLBACK;

        x_return_status := FND_API.G_RET_STS_ERROR;

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_called_mode => p_called_mode,
                  p_msg         => 'Invalid Arguments Passed',
                  p_module_name => l_module_name,
                  p_log_level   => 5 );
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE;

    WHEN OTHERS THEN
        rollback;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(sqlerrm,1,240);
        -- dbms_output.put_line('error msg :'||x_msg_data);
        FND_MSG_PUB.add_exc_msg
            ( p_pkg_name        => 'PA_FP_WP_GEN_BUDGET_AMT_PUB',
              p_procedure_name  => 'GENERATE_WP_BUDGET_AMT',
              p_error_text      => substr(sqlerrm,1,240));
        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_called_mode => p_called_mode,
                  p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                  p_module_name => l_module_name,
                  p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GENERATE_WP_BUDGET_AMT;


PROCEDURE MAINTAIN_BUDGET_LINES
          (P_PROJECT_ID                   IN           PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_SOURCE_BV_ID                 IN           PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_TARGET_BV_ID                 IN           PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_CALLING_CONTEXT              IN           VARCHAR2,
           P_ACTUALS_THRU_DATE            IN           PA_PERIODS_ALL.END_DATE%TYPE,
           P_RETAIN_MANUAL_FLAG           IN           VARCHAR2,
           X_RETURN_STATUS                OUT NOCOPY   VARCHAR2,
           X_MSG_COUNT                    OUT NOCOPY   NUMBER,
           X_MSG_DATA                     OUT NOCOPY   VARCHAR2)
IS
    l_module_name VARCHAR2(100) := 'pa.plsql.PA_FP_WP_GEN_BUDGET_AMT_PUB.MAINTAIN_BUDGET_LINES';
    l_txn_currency_flag            VARCHAR2(1):='Y';

    /* String constants for valid Calling Context values */
    lc_BudgetGeneration            CONSTANT VARCHAR2(30) := 'BUDGET_GENERATION';
    lc_ForecastGeneration          CONSTANT VARCHAR2(30) := 'FORECAST_GENERATION';

    /* Source Code constants */
    lc_WorkPlanSrcCode             CONSTANT PA_PROJ_FP_OPTIONS.GEN_COST_SRC_CODE%TYPE
                                       := 'WORKPLAN_RESOURCES';
    lc_FinancialPlanSrcCode        CONSTANT PA_PROJ_FP_OPTIONS.GEN_COST_SRC_CODE%TYPE
                                       := 'FINANCIAL_PLAN';

    /* Local copy of the Calling Context that will be checked instead of p_calling_context */
    l_calling_context              VARCHAR2(30);

    -- Bug 4115015: We need unrounded amounts to accurately compute
    -- override rates. Therefore, we have added an extra set of txn
    -- amounts prefixed by "_unrounded". Unrounded amounts are computed
    -- by multiplying quantity by the appropriate rate multipliers.

    -- ER 4376722: To carry out the Task Billability logic, we need to
    -- modify the cursors to fetch the task billable_flag for each target
    -- resource. Since ra.task_id can be NULL or 0, we take the outer
    -- join: NVL(ra.task_id,0) = ta.task_id (+). By default, tasks are
    -- billable, so we SELECT NVL(ta.billable_flag,'Y').

    /*when multi currency is not enabled, then take project currency and amts,
      when multi currency is enabled, then take transaction currency and amts,
      when target is approved budget version, then take projfunc currency and amts.
      Don't pick up amounts for budget lines with non-null rejection codes. */
    CURSOR budget_line_src_tgt(c_proj_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE,
                               c_projfunc_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE) IS
    SELECT /*+ INDEX(tmp4,PA_RES_LIST_MAP_TMP4_N2)*/
           ra.resource_assignment_id,
           ra.rate_based_flag,
           sbl.start_date,
           sbl.end_date,
           sbl.period_name,
           decode(l_txn_currency_flag,
                 'Y', sbl.txn_currency_code,
                 'N', c_proj_currency_code,
                 'A', c_projfunc_currency_code),
           sum(sbl.quantity),
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.txn_raw_cost,
                      'N', sbl.project_raw_cost,
                      'A', sbl.raw_cost)),
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.txn_burdened_cost,
                      'N', sbl.project_burdened_cost,
                      'A', sbl.burdened_cost)),
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.txn_revenue,
                      'N', sbl.project_revenue,
                      'A', sbl.revenue)),
           /*
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.quantity *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate),   --sbl.txn_raw_cost
                      'N', sbl.quantity * NVL(sbl.project_cost_exchange_rate,1) *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate),   --sbl.project_raw_cost
                      'A', sbl.quantity * NVL(sbl.projfunc_cost_exchange_rate,1) *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate))), --sbl.raw_cost
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.quantity *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate),   --sbl.txn_burdened_cost
                      'N', sbl.quantity * NVL(sbl.project_cost_exchange_rate,1) *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate),   --sbl.project_burdened_cost
                      'A', sbl.quantity * NVL(sbl.projfunc_cost_exchange_rate,1) *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate))), --sbl.burdened_cost
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.quantity *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate),   --sbl.txn_revenue
                      'N', sbl.quantity * NVL(sbl.project_cost_exchange_rate,1) *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate),   --sbl.project_revenue
                      'A', sbl.quantity * NVL(sbl.projfunc_cost_exchange_rate,1) *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate))), --sbl.revenue */
           -- Bug 8937993. Need to pull use source rates for only the plannned quantity.
           sum(decode(l_txn_currency_flag,
                      'Y', (((sbl.quantity - nvl(sbl.init_quantity,0)) *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate))
                           + NVL(sbl.txn_init_raw_cost,0)),   																							--sbl.txn_raw_cost
                      'N', ((((sbl.quantity - nvl(sbl.init_quantity,0)) *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate))
                           + NVL(sbl.txn_init_raw_cost,0)) * NVL(sbl.project_cost_exchange_rate,1)) ,   		--sbl.project_raw_cost
                      'A', ((((sbl.quantity - nvl(sbl.init_quantity,0)) *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate))
                           + NVL(sbl.txn_init_raw_cost,0)) * NVL(sbl.projfunc_cost_exchange_rate,1))
                           )), 																																							--sbl.raw_cost
           sum(decode(l_txn_currency_flag,
                      'Y', (((sbl.quantity - nvl(sbl.init_quantity,0)) *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate))
                           + NVL(sbl.txn_init_burdened_cost,0)),   																					--sbl.txn_burdened_cost
                      'N', ((((sbl.quantity - nvl(sbl.init_quantity,0))  *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate))
                           + NVL(sbl.txn_init_burdened_cost,0)) * NVL(sbl.project_cost_exchange_rate,1)),   --sbl.project_burdened_cost
                      'A', ((((sbl.quantity - nvl(sbl.init_quantity,0)) *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate))
                           + NVL(sbl.txn_init_burdened_cost,0)) * NVL(sbl.projfunc_cost_exchange_rate,1))
                           )), 																																							 --sbl.burdened_cost
           sum(decode(l_txn_currency_flag,
                      'Y', (((sbl.quantity - nvl(sbl.init_quantity,0)) *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate))
                           + NVL(sbl.txn_init_revenue,0)),   																								 --sbl.txn_revenue
                      'N', ((((sbl.quantity - nvl(sbl.init_quantity,0)) *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate))
                           + NVL(sbl.txn_init_revenue,0)) * NVL(sbl.project_cost_exchange_rate,1)) ,   			 --sbl.project_revenue
                      'A', ((((sbl.quantity - nvl(sbl.init_quantity,0))  *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate))
                           + NVL(sbl.txn_init_revenue,0)) * NVL(sbl.projfunc_cost_exchange_rate,1))
                           )),
           sum(sbl.project_raw_cost),
           sum(sbl.project_burdened_cost),
           sum(sbl.project_revenue),
           sum(sbl.raw_cost),
           sum(sbl.burdened_cost),
           sum(sbl.revenue),
           NULL,
           NULL,
           NULL,
           NVL(ta.billable_flag,'Y'),                      /* Added for ER 4376722 */
           avg(sbl.txn_markup_percent)                     /* Added for Bug 5166047 */
    FROM pa_res_list_map_tmp4 tmp4,
         pa_budget_lines sbl,
         pa_resource_assignments ra,
         pa_tasks ta                                       /* Added for ER 4376722 */
    WHERE tmp4.txn_source_id = sbl.resource_assignment_id
          and sbl.budget_version_id = p_source_bv_id
          and tmp4.txn_resource_assignment_id = ra.resource_assignment_id
          and ra.budget_version_id = p_target_bv_id
          and sbl.cost_rejection_code is null
          and sbl.revenue_rejection_code is null
          and sbl.burden_rejection_code is null
          and sbl.other_rejection_code is null
          and sbl.pc_cur_conv_rejection_code is null
          and sbl.pfc_cur_conv_rejection_code is null
          and NVL(ra.task_id,0) = ta.task_id (+)           /* Added for ER 4376722 */
          --and ta.project_id = P_PROJECT_ID               /* Added for ER 4376722 */
          and ra.project_id = P_PROJECT_ID                 /* Added for Bug 4543795 */
    GROUP BY ra.resource_assignment_id,
             ra.rate_based_flag,
             sbl.start_date,
             sbl.end_date,
             sbl.period_name,
             decode(l_txn_currency_flag,
                 'Y', sbl.txn_currency_code,
                 'N', c_proj_currency_code,
                 'A', c_projfunc_currency_code),
             NULL,
             NULL,
             NULL,
             NVL(ta.billable_flag,'Y');                    /* Added for ER 4376722 */

    --Start Changes Bug 6411406
    -- Created this cursor for non time phased scenario while generation of budget line.
    CURSOR budget_line_src_tgt_none(c_proj_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE,
                                    c_projfunc_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE) IS
    SELECT /*+ INDEX(tmp4,PA_RES_LIST_MAP_TMP4_N2)*/
           ra.resource_assignment_id,
           ra.rate_based_flag,
           ra.planning_start_date,
           ra.planning_end_date,
           null,
           decode(l_txn_currency_flag,
                 'Y', sbl.txn_currency_code,
                 'N', c_proj_currency_code,
                 'A', c_projfunc_currency_code),
           sum(sbl.quantity),
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.txn_raw_cost,
                      'N', sbl.project_raw_cost,
                      'A', sbl.raw_cost)),
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.txn_burdened_cost,
                      'N', sbl.project_burdened_cost,
                      'A', sbl.burdened_cost)),
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.txn_revenue,
                      'N', sbl.project_revenue,
                      'A', sbl.revenue)),
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.quantity *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate),
                      'N', sbl.quantity * NVL(sbl.project_cost_exchange_rate,1) *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate),
                      'A', sbl.quantity * NVL(sbl.projfunc_cost_exchange_rate,1) *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate))),
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.quantity *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate),
                      'N', sbl.quantity * NVL(sbl.project_cost_exchange_rate,1) *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate),
                      'A', sbl.quantity * NVL(sbl.projfunc_cost_exchange_rate,1) *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate))),
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.quantity *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate),
                      'N', sbl.quantity * NVL(sbl.project_cost_exchange_rate,1) *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate),
                      'A', sbl.quantity * NVL(sbl.projfunc_cost_exchange_rate,1) *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate))),
           sum(sbl.project_raw_cost),
           sum(sbl.project_burdened_cost),
           sum(sbl.project_revenue),
           sum(sbl.raw_cost),
           sum(sbl.burdened_cost),
           sum(sbl.revenue),
           NULL,
           NULL,
           NULL,
           NVL(ta.billable_flag,'Y')
    FROM pa_res_list_map_tmp4 tmp4,
         pa_budget_lines sbl,
         pa_resource_assignments ra,
         pa_tasks ta
    WHERE tmp4.txn_source_id = sbl.resource_assignment_id
          and sbl.budget_version_id = p_source_bv_id
          and tmp4.txn_resource_assignment_id = ra.resource_assignment_id
          and ra.budget_version_id = p_target_bv_id
          and sbl.cost_rejection_code is null
          and sbl.revenue_rejection_code is null
          and sbl.burden_rejection_code is null
          and sbl.other_rejection_code is null
          and sbl.pc_cur_conv_rejection_code is null
          and sbl.pfc_cur_conv_rejection_code is null
          and NVL(ra.task_id,0) = ta.task_id (+)
          and ra.project_id = P_PROJECT_ID
    GROUP BY ra.resource_assignment_id,
             ra.rate_based_flag,
             ra.planning_start_date,
             ra.planning_end_date,
             NULL,
             decode(l_txn_currency_flag,
                 'Y', sbl.txn_currency_code,
                 'N', c_proj_currency_code,
                 'A', c_projfunc_currency_code),
             NULL,
             NULL,
             NULL,
             NVL(ta.billable_flag,'Y');
    --End Changes Bug 6411406


    /* This cursor is the revenue forecast generation analogue of the cursor
     * budget_line_src_tgt. As such, changes to that cursor should likely be
     * mirorred here. See comments above the other cursor for more info.
     * This cursor differs from the other one in that it only picks up source
     * data with starting date after the forecast's actuals through period. */
    CURSOR fcst_budget_line_src_tgt
               (c_proj_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE,
                c_projfunc_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE,
                c_src_time_phased_code PA_PROJ_FP_OPTIONS.COST_TIME_PHASED_CODE%TYPE) IS
    SELECT /*+ INDEX(tmp4,PA_RES_LIST_MAP_TMP4_N2)*/
           ra.resource_assignment_id,
           ra.rate_based_flag,
           sbl.start_date,
           sbl.end_date,
           sbl.period_name,
           decode(l_txn_currency_flag,
                 'Y', sbl.txn_currency_code,
                 'N', c_proj_currency_code,
                 'A', c_projfunc_currency_code),
           sum(sbl.quantity),
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.txn_raw_cost,
                      'N', sbl.project_raw_cost,
                      'A', sbl.raw_cost)),
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.txn_burdened_cost,
                      'N', sbl.project_burdened_cost,
                      'A', sbl.burdened_cost)),
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.txn_revenue,
                      'N', sbl.project_revenue,
                      'A', sbl.revenue)),
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.quantity *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate),   --sbl.txn_raw_cost
                      'N', sbl.quantity * NVL(sbl.project_cost_exchange_rate,1) *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate),   --sbl.project_raw_cost
                      'A', sbl.quantity * NVL(sbl.projfunc_cost_exchange_rate,1) *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate))), --sbl.raw_cost
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.quantity *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate),   --sbl.txn_burdened_cost
                      'N', sbl.quantity * NVL(sbl.project_cost_exchange_rate,1) *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate),   --sbl.project_burdened_cost
                      'A', sbl.quantity * NVL(sbl.projfunc_cost_exchange_rate,1) *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate))), --sbl.burdened_cost
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.quantity *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate),   --sbl.txn_revenue
                      'N', sbl.quantity * NVL(sbl.project_cost_exchange_rate,1) *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate),   --sbl.project_revenue
                      'A', sbl.quantity * NVL(sbl.projfunc_cost_exchange_rate,1) *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate))), --sbl.revenue
           sum(sbl.project_raw_cost),
           sum(sbl.project_burdened_cost),
           sum(sbl.project_revenue),
           sum(sbl.raw_cost),
           sum(sbl.burdened_cost),
           sum(sbl.revenue),
           NULL,
           NULL,
           NULL,
           NVL(ta.billable_flag,'Y'),                      /* Added for ER 4376722 */
           avg(sbl.txn_markup_percent)                     /* Added for Bug 5166047 */
    FROM pa_res_list_map_tmp4 tmp4,
         pa_budget_lines sbl,
         pa_resource_assignments ra,
         pa_tasks ta                                       /* Added for ER 4376722 */
    WHERE tmp4.txn_source_id = sbl.resource_assignment_id
          and sbl.budget_version_id = p_source_bv_id
          and tmp4.txn_resource_assignment_id = ra.resource_assignment_id
          and ra.budget_version_id = p_target_bv_id
          and sbl.start_date > decode( c_src_time_phased_code,
                                       'N', sbl.start_date-1, P_ACTUALS_THRU_DATE )
          and sbl.cost_rejection_code is null
          and sbl.revenue_rejection_code is null
          and sbl.burden_rejection_code is null
          and sbl.other_rejection_code is null
          and sbl.pc_cur_conv_rejection_code is null
          and sbl.pfc_cur_conv_rejection_code is null
          and NVL(ra.task_id,0) = ta.task_id (+)           /* Added for ER 4376722 */
          --and ta.project_id = P_PROJECT_ID               /* Added for ER 4376722 */
          and ra.project_id = P_PROJECT_ID                 /* Added for Bug 4543795 */
    GROUP BY ra.resource_assignment_id,
             ra.rate_based_flag,
             sbl.start_date,
             sbl.end_date,
             sbl.period_name,
             decode(l_txn_currency_flag,
                 'Y', sbl.txn_currency_code,
                 'N', c_proj_currency_code,
                 'A', c_projfunc_currency_code),
             NULL,
             NULL,
             NULL,
             NVL(ta.billable_flag,'Y');                    /* Added for ER 4376722 */

    -- Bug 4192970: Added extra cursor for Forecast Generation context when
    -- Source time phasing is None. When Source time phasing is PA or GL,
    -- use the fcst_budget_line_src_tgt cursor. For more comments/details,
    -- please see the other cursor.

    CURSOR fcst_budget_line_src_tgt_none
               (c_proj_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE,
                c_projfunc_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE,
                c_src_time_phased_code PA_PROJ_FP_OPTIONS.COST_TIME_PHASED_CODE%TYPE) IS
    SELECT /*+ INDEX(tmp4,PA_RES_LIST_MAP_TMP4_N2)*/
           ra.resource_assignment_id,
           ra.rate_based_flag,
           sbl.start_date,
           sbl.end_date,
           sbl.period_name,
           decode(l_txn_currency_flag,
                 'Y', sbl.txn_currency_code,
                 'N', c_proj_currency_code,
                 'A', c_projfunc_currency_code),
           sum(sbl.quantity-NVL(sbl.init_quantity,0)),
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.txn_raw_cost - NVL(sbl.txn_init_raw_cost,0),
                      'N', sbl.project_raw_cost - NVL(sbl.project_init_raw_cost,0),
                      'A', sbl.raw_cost - NVL(sbl.init_raw_cost,0))),
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.txn_burdened_cost - NVL(sbl.txn_init_burdened_cost,0),
                      'N', sbl.project_burdened_cost - NVL(sbl.project_init_burdened_cost,0),
                      'A', sbl.burdened_cost - NVL(sbl.init_burdened_cost,0))),
           sum(decode(l_txn_currency_flag,
                      'Y', sbl.txn_revenue - NVL(sbl.txn_init_revenue,0),
                      'N', sbl.project_revenue - NVL(sbl.project_init_revenue,0),
                      'A', sbl.revenue - NVL(sbl.init_revenue,0))),
           sum(decode(l_txn_currency_flag,
                      'Y', (sbl.quantity-NVL(sbl.init_quantity,0)) *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate),   --sbl.txn_raw_cost
                      'N', (sbl.quantity-NVL(sbl.init_quantity,0)) * NVL(sbl.project_cost_exchange_rate,1) *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate),   --sbl.project_raw_cost
                      'A', (sbl.quantity-NVL(sbl.init_quantity,0)) * NVL(sbl.projfunc_cost_exchange_rate,1) *
                           NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate))), --sbl.raw_cost
           sum(decode(l_txn_currency_flag,
                      'Y', (sbl.quantity-NVL(sbl.init_quantity,0)) *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate),   --sbl.txn_burdened_cost
                      'N', (sbl.quantity-NVL(sbl.init_quantity,0)) * NVL(sbl.project_cost_exchange_rate,1) *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate),   --sbl.project_burdened_cost
                      'A', (sbl.quantity-NVL(sbl.init_quantity,0)) * NVL(sbl.projfunc_cost_exchange_rate,1) *
                           NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate))), --sbl.burdened_cost
           sum(decode(l_txn_currency_flag,
                      'Y', (sbl.quantity-NVL(sbl.init_quantity,0)) *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate),   --sbl.txn_revenue
                      'N', (sbl.quantity-NVL(sbl.init_quantity,0)) * NVL(sbl.project_cost_exchange_rate,1) *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate),   --sbl.project_revenue
                      'A', (sbl.quantity-NVL(sbl.init_quantity,0)) * NVL(sbl.projfunc_cost_exchange_rate,1) *
                           NVL(sbl.txn_bill_rate_override,sbl.txn_standard_bill_rate))), --sbl.revenue
           sum(sbl.project_raw_cost - NVL(sbl.project_init_raw_cost,0)),
           sum(sbl.project_burdened_cost - NVL(sbl.project_init_burdened_cost,0)),
           sum(sbl.project_revenue - NVL(sbl.project_init_revenue,0)),
           sum(sbl.raw_cost - NVL(sbl.init_raw_cost,0)),
           sum(sbl.burdened_cost - NVL(sbl.init_burdened_cost,0)),
           sum(sbl.revenue - NVL(sbl.init_revenue,0)),
           NULL,
           NULL,
           NULL,
           NVL(ta.billable_flag,'Y'),                      /* Added for ER 4376722 */
           avg(sbl.txn_markup_percent)                     /* Added for Bug 5166047 */
    FROM pa_res_list_map_tmp4 tmp4,
         pa_budget_lines sbl,
         pa_resource_assignments ra,
         pa_tasks ta                                       /* Added for ER 4376722 */
    WHERE tmp4.txn_source_id = sbl.resource_assignment_id
          and sbl.budget_version_id = p_source_bv_id
          and tmp4.txn_resource_assignment_id = ra.resource_assignment_id
          and ra.budget_version_id = p_target_bv_id
          and sbl.cost_rejection_code is null
          and sbl.revenue_rejection_code is null
          and sbl.burden_rejection_code is null
          and sbl.other_rejection_code is null
          and sbl.pc_cur_conv_rejection_code is null
          and sbl.pfc_cur_conv_rejection_code is null
          and NVL(sbl.quantity,0) <> NVL(sbl.init_quantity,0)
	  and NVL(ra.task_id,0) = ta.task_id (+)           /* Added for ER  4376722 */
          --and ta.project_id = P_PROJECT_ID               /* Added for ER  4376722 */
          and ra.project_id = P_PROJECT_ID                 /* Added for Bug 4543795 */
    GROUP BY ra.resource_assignment_id,
             ra.rate_based_flag,
             sbl.start_date,
             sbl.end_date,
             sbl.period_name,
             decode(l_txn_currency_flag,
                 'Y', sbl.txn_currency_code,
                 'N', c_proj_currency_code,
                 'A', c_projfunc_currency_code),
             NULL,
             NULL,
             NULL,
             NVL(ta.billable_flag,'Y');                    /* Added for ER 4376722 */

    /* Added for bug #4938603 */
    CURSOR fcst_bdgt_line_actual_qty
        (c_res_asgn_id       PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE,
         c_txn_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE
        ) IS
    SELECT sum(nvl(init_quantity,0))
      FROM pa_budget_lines
     WHERE resource_assignment_id = c_res_asgn_id
       AND txn_currency_code = c_txn_currency_code;

    /* Additional types and variables added for Bug 4938603 */
    TYPE Char15ToNum
    IS TABLE OF NUMBER INDEX BY PA_BUDGET_LINES.TXN_CURRENCY_CODE%TYPE;

    TYPE NumToChar15ToNum
    IS TABLE OF Char15ToNum INDEX BY BINARY_INTEGER;

    ra_id_tab                      NumToChar15ToNum;
    new_currency_tab               Char15ToNum;
    l_ra_id                        NUMBER;
    l_currency                     PA_BUDGET_LINES.TXN_CURRENCY_CODE%TYPE;
    n_index                        NUMBER;
    s_index                        PA_BUDGET_LINES.TXN_CURRENCY_CODE%TYPE;
    l_total_plan_qty               NUMBER;
    l_init_qty                     NUMBER;

    l_tgt_res_asg_id_tab           pa_plsql_datatypes.IdTabTyp;
    l_tgt_rate_based_flag_tab      pa_plsql_datatypes.Char15TabTyp;
    l_start_date_tab               pa_plsql_datatypes.DateTabTyp;
    l_txn_currency_code_tab        pa_plsql_datatypes.Char15TabTyp;
    l_end_date_tab                 pa_plsql_datatypes.DateTabTyp;
    l_periiod_name_tab             pa_plsql_datatypes.Char30TabTyp;
    l_src_quantity_tab             pa_plsql_datatypes.NumTabTyp;
    l_txn_raw_cost_tab             pa_plsql_datatypes.NumTabTyp;
    l_txn_brdn_cost_tab            pa_plsql_datatypes.NumTabTyp;
    l_txn_revenue_tab              pa_plsql_datatypes.NumTabTyp;

    /* Bug 4115015: We use unrounded txn amounts for computing overrides. */
    l_override_quantity            NUMBER;
    l_unrounded_txn_raw_cost_tab   pa_plsql_datatypes.NumTabTyp;
    l_unrounded_txn_brdn_cost_tab  pa_plsql_datatypes.NumTabTyp;
    l_unrounded_txn_revenue_tab    pa_plsql_datatypes.NumTabTyp;

    l_pfc_brdn_cost_tab            pa_plsql_datatypes.NumTabTyp;
    l_pfc_raw_cost_tab             pa_plsql_datatypes.NumTabTyp;
    l_pfc_revenue_tab              pa_plsql_datatypes.NumTabTyp;

    l_pc_brdn_cost_tab             pa_plsql_datatypes.NumTabTyp;
    l_pc_raw_cost_tab              pa_plsql_datatypes.NumTabTyp;
    l_pc_revenue_tab               pa_plsql_datatypes.NumTabTyp;

    l_cost_rate_override_tab       pa_plsql_datatypes.NumTabTyp;
    l_b_cost_rate_override_tab     pa_plsql_datatypes.NumTabTyp;
    l_bill_rate_override_tab       pa_plsql_datatypes.NumTabTyp;

    l_fp_cols_rec_source           PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
    l_fp_cols_rec_target           PA_FP_GEN_AMOUNT_UTILS.FP_COLS;

    /* Variables for COMPARE_ETC_SRC_TARGET_FP_OPT API call */
    l_gen_src_code                 PA_PROJ_FP_OPTIONS.GEN_COST_SRC_CODE%TYPE;
    l_wp_src_plan_ver_id           PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE;
    l_fp_src_plan_ver_id           PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE;
    l_same_planning_options_flag   VARCHAR2(1);

    /* PL/SQL tables for copying source resource assignment attributes */
    l_task_id_tab                  PA_PLSQL_DATATYPES.IdTabTyp;
    l_res_list_member_id_tab       PA_PLSQL_DATATYPES.IdTabTyp;

    l_resource_class_flag_tab      PA_PLSQL_DATATYPES.Char15TabTyp;
    l_resource_class_code_tab      PA_PLSQL_DATATYPES.Char30TabTyp;
    l_res_type_code_tab            PA_PLSQL_DATATYPES.Char30TabTyp;
    l_person_id_tab                PA_PLSQL_DATATYPES.IdTabTyp;
    l_job_id_tab                   PA_PLSQL_DATATYPES.IdTabTyp;
    l_person_type_code_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
    l_named_role_tab               PA_PLSQL_DATATYPES.Char80TabTyp;
    l_bom_resource_id_tab          PA_PLSQL_DATATYPES.IdTabTyp;
    l_non_labor_resource_tab       PA_PLSQL_DATATYPES.Char20TabTyp;
    l_inventory_item_id_tab        PA_PLSQL_DATATYPES.IdTabTyp;
    l_item_category_id_tab         PA_PLSQL_DATATYPES.IdTabTyp;
    l_project_role_id_tab          PA_PLSQL_DATATYPES.IdTabTyp;
    l_organization_id_tab          PA_PLSQL_DATATYPES.IdTabTyp;
    l_fc_res_type_code_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
    l_expenditure_type_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
    l_expenditure_category_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
    l_event_type_tab               PA_PLSQL_DATATYPES.Char30TabTyp;
    l_revenue_category_code_tab    PA_PLSQL_DATATYPES.Char30TabTyp;
    l_supplier_id_tab              PA_PLSQL_DATATYPES.IdTabTyp;
    l_spread_curve_id_tab          PA_PLSQL_DATATYPES.IdTabTyp;
    l_etc_method_code_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
    l_mfc_cost_type_id_tab         PA_PLSQL_DATATYPES.IdTabTyp;
    l_incurred_by_res_flag_tab     PA_PLSQL_DATATYPES.Char15TabTyp;
    l_incur_by_res_cls_code_tab    PA_PLSQL_DATATYPES.Char30TabTyp;
    l_incur_by_role_id_tab         PA_PLSQL_DATATYPES.IdTabTyp;
    l_unit_of_measure_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
    l_rate_based_flag_tab          PA_PLSQL_DATATYPES.Char15TabTyp;
    -- IPM: Added table for copying source resource_rate_based_flag values.
    l_res_rate_based_flag_tab      PA_PLSQL_DATATYPES.Char15TabTyp;
    l_rate_expenditure_type_tab    PA_PLSQL_DATATYPES.Char30TabTyp;
    l_rate_func_curr_code_tab      PA_PLSQL_DATATYPES.Char30TabTyp;
    l_org_id_tab                   PA_PLSQL_DATATYPES.IdTabTyp;

    l_last_updated_by              PA_RESOURCE_ASSIGNMENTS.LAST_UPDATED_BY%TYPE
				       := FND_GLOBAL.user_id;
    l_last_update_login            PA_RESOURCE_ASSIGNMENTS.LAST_UPDATE_LOGIN%TYPE
				       := FND_GLOBAL.login_id;

    l_rev_gen_method               VARCHAR2(3);
    l_res_asg_uom_update_tab       pa_plsql_datatypes.IdTabTyp;

    l_appr_cost_plan_type_flag     PA_BUDGET_VERSIONS.APPROVED_COST_PLAN_TYPE_FLAG%TYPE;
    l_appr_rev_plan_type_flag      PA_BUDGET_VERSIONS.APPROVED_COST_PLAN_TYPE_FLAG%TYPE;

    /* Bug 3968748: PL/SQL tables for populating PA_FP_GEN_RATE_TMP */
    l_nrb_ra_id_tab                PA_PLSQL_DATATYPES.IdTabTyp;
    l_nrb_txn_curr_code_tab        PA_PLSQL_DATATYPES.Char30TabTyp;
    l_nrb_bcost_rate_tab           PA_PLSQL_DATATYPES.NumTabTyp;
    l_nrb_period_name_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
    l_nrb_rcost_rate_tab           PA_PLSQL_DATATYPES.NumTabTyp;
    l_index                        NUMBER;

    l_msg_count number;
    l_data VARCHAR2(2000);
    l_msg_data VARCHAR2(2000);
    l_msg_index_out number;

    l_source_version_type          PA_BUDGET_VERSIONS.VERSION_TYPE%TYPE;
    l_target_version_type          PA_BUDGET_VERSIONS.VERSION_TYPE%TYPE;
    l_dummy                        NUMBER;
    l_wp_track_cost_flag           VARCHAR2(1);

    -- Variables added for Bug 4292083
    l_index_tab                    PA_PLSQL_DATATYPES.IdTabTyp;
    l_upd_index_tab                PA_PLSQL_DATATYPES.IdTabTyp;
    l_upd_index                    NUMBER;
    l_ins_index                    NUMBER;
    l_tab_index                    NUMBER;
    l_next_update                  NUMBER;

    -- pl/sql tables for when Target is None timephased Forecast
    l_ins_tgt_res_asg_id_tab       pa_plsql_datatypes.IdTabTyp;
    l_ins_start_date_tab           pa_plsql_datatypes.DateTabTyp;
    l_ins_txn_currency_code_tab    pa_plsql_datatypes.Char15TabTyp;
    l_ins_end_date_tab             pa_plsql_datatypes.DateTabTyp;
    l_ins_periiod_name_tab         pa_plsql_datatypes.Char30TabTyp;
    l_ins_src_quantity_tab         pa_plsql_datatypes.NumTabTyp;
    l_ins_txn_raw_cost_tab         pa_plsql_datatypes.NumTabTyp;
    l_ins_txn_brdn_cost_tab        pa_plsql_datatypes.NumTabTyp;
    l_ins_txn_revenue_tab          pa_plsql_datatypes.NumTabTyp;
    l_ins_pfc_revenue_tab          pa_plsql_datatypes.NumTabTyp;
    l_ins_pc_revenue_tab           pa_plsql_datatypes.NumTabTyp;
    l_ins_cost_rate_override_tab   pa_plsql_datatypes.NumTabTyp;
    l_ins_bcost_rate_override_tab  pa_plsql_datatypes.NumTabTyp;
    l_ins_bill_rate_override_tab   pa_plsql_datatypes.NumTabTyp;

    -- pl/sql tables for when Target is None timephased Forecast
    l_upd_tgt_res_asg_id_tab       pa_plsql_datatypes.IdTabTyp;
    l_upd_start_date_tab           pa_plsql_datatypes.DateTabTyp;
    l_upd_txn_currency_code_tab    pa_plsql_datatypes.Char15TabTyp;
    l_upd_end_date_tab             pa_plsql_datatypes.DateTabTyp;
    l_upd_periiod_name_tab         pa_plsql_datatypes.Char30TabTyp;
    l_upd_src_quantity_tab         pa_plsql_datatypes.NumTabTyp;
    l_upd_txn_raw_cost_tab         pa_plsql_datatypes.NumTabTyp;
    l_upd_txn_brdn_cost_tab        pa_plsql_datatypes.NumTabTyp;
    l_upd_txn_revenue_tab          pa_plsql_datatypes.NumTabTyp;
    l_upd_pfc_revenue_tab          pa_plsql_datatypes.NumTabTyp;
    l_upd_pc_revenue_tab           pa_plsql_datatypes.NumTabTyp;
    l_upd_cost_rate_override_tab   pa_plsql_datatypes.NumTabTyp;
    l_upd_bcost_rate_override_tab  pa_plsql_datatypes.NumTabTyp;
    l_upd_bill_rate_override_tab   pa_plsql_datatypes.NumTabTyp;

    /* Variables Added for ER 4376722 */
    l_billable_flag_tab            PA_PLSQL_DATATYPES.Char1TabTyp;
    /* Variables Added for Bug 5166047 */
    l_markup_percent_tab           PA_PLSQL_DATATYPES.NumTabTyp;

    -- This index is used to track the running index of the _tmp_ tables
    l_tmp_index                    NUMBER;

    -- These _tmp_ tables will be used for removing non-billable tasks.
    l_tmp_tgt_res_asg_id_tab       pa_plsql_datatypes.IdTabTyp;
    l_tmp_tgt_rate_based_flag_tab  pa_plsql_datatypes.Char15TabTyp;
    l_tmp_start_date_tab           pa_plsql_datatypes.DateTabTyp;
    l_tmp_end_date_tab             pa_plsql_datatypes.DateTabTyp;
    l_tmp_periiod_name_tab         pa_plsql_datatypes.Char30TabTyp;
    l_tmp_txn_currency_code_tab    pa_plsql_datatypes.Char15TabTyp;
    l_tmp_src_quantity_tab         pa_plsql_datatypes.NumTabTyp;
    l_tmp_txn_raw_cost_tab         pa_plsql_datatypes.NumTabTyp;
    l_tmp_txn_brdn_cost_tab        pa_plsql_datatypes.NumTabTyp;
    l_tmp_txn_revenue_tab          pa_plsql_datatypes.NumTabTyp;
    l_tmp_unr_txn_raw_cost_tab     pa_plsql_datatypes.NumTabTyp;
    l_tmp_unr_txn_brdn_cost_tab    pa_plsql_datatypes.NumTabTyp;
    l_tmp_unr_txn_revenue_tab      pa_plsql_datatypes.NumTabTyp;
    l_tmp_pc_raw_cost_tab          pa_plsql_datatypes.NumTabTyp;
    l_tmp_pc_brdn_cost_tab         pa_plsql_datatypes.NumTabTyp;
    l_tmp_pc_revenue_tab           pa_plsql_datatypes.NumTabTyp;
    l_tmp_pfc_raw_cost_tab         pa_plsql_datatypes.NumTabTyp;
    l_tmp_pfc_brdn_cost_tab        pa_plsql_datatypes.NumTabTyp;
    l_tmp_pfc_revenue_tab          pa_plsql_datatypes.NumTabTyp;
    l_tmp_cost_rate_override_tab   pa_plsql_datatypes.NumTabTyp;
    l_tmp_bcost_rate_override_tab  pa_plsql_datatypes.NumTabTyp;
    l_tmp_bill_rate_override_tab   pa_plsql_datatypes.NumTabTyp;
    l_tmp_billable_flag_tab        PA_PLSQL_DATATYPES.Char1TabTyp;
    l_tmp_markup_percent_tab       PA_PLSQL_DATATYPES.NumTabTyp; -- Added for Bug 5166047

    /* Flag parameters for calling Calculate API */
    l_refresh_rates_flag           VARCHAR2(1);
    l_refresh_conv_rates_flag      VARCHAR2(1);
    l_spread_required_flag         VARCHAR2(1);
    l_conv_rates_required_flag     VARCHAR2(1);
    l_rollup_required_flag         VARCHAR2(1);
    l_raTxn_rollup_api_call_flag   VARCHAR2(1); -- Added for IPM new entity ER

    /* Additional Calculate API parameters added for Bug 4686742 */
    l_source_context               pa_fp_res_assignments_tmp.source_context%TYPE;
    l_cal_tgt_res_asg_id_tab       SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_cal_start_date_tab           SYSTEM.pa_date_tbl_type:=SYSTEM.pa_date_tbl_type();
    l_cal_txn_currency_code_tab    SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();
    l_cal_end_date_tab             SYSTEM.pa_date_tbl_type:=SYSTEM.pa_date_tbl_type();
    l_cal_src_quantity_tab         SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_cal_txn_raw_cost_tab         SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_cal_txn_brdn_cost_tab        SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_cal_txn_revenue_tab          SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_cal_cost_rate_override_tab   SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_cal_bill_rate_override_tab   SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_cal_b_cost_rate_override_tab SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();

    l_raw_cost_rate_tab            SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_b_cost_rate_tab              SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_bill_rate_tab                SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();

    -- IPM: Added local variable to pass variable values of the
    --      p_calling_module parameter of the MAINTAIN_DATA API.
    l_calling_module             VARCHAR2(30);
    l_count                      NUMBER;

    -- Added in IPM to track if a record in the existing set of
    -- pl/sql tables needs to be removed.
    l_remove_record_flag_tab       PA_PLSQL_DATATYPES.Char1TabTyp;
    l_remove_records_flag          VARCHAR2(1);

BEGIN
    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.set_curr_function( p_function   => 'MAINTAIN_BUDGET_LINES',
                                    p_debug_mode => p_pa_debug_mode );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;

    --l_rev_gen_method := PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(p_project_id);

    l_wp_track_cost_flag :=
        NVL( PA_FP_WP_GEN_AMT_UTILS.GET_WP_TRACK_COST_AMT_FLAG(p_project_id), 'N' );

    /* Set the local calling context to p_calling_context if it is a valid value.
     * Otherwise, default l_calling_context to budget generation. */
    IF p_calling_context = lc_BudgetGeneration OR
       p_calling_context = lc_ForecastGeneration THEN
        l_calling_context := p_calling_context;
    ELSE
        l_calling_context := lc_BudgetGeneration;
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
            ( p_msg         => 'Before calling
                               PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS',
              p_module_name => l_module_name,
              p_log_level   => 5 );
    END IF;
    PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS (
        P_PROJECT_ID                 => P_PROJECT_ID,
        P_BUDGET_VERSION_ID          => P_SOURCE_BV_ID,
        X_FP_COLS_REC                => l_fp_cols_rec_source,
        X_RETURN_STATUS              => x_return_status,
        X_MSG_COUNT                  => x_msg_count,
        X_MSG_DATA                   => x_msg_data );
    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
            ( p_msg         => 'Status after calling
                              PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS: '
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5 );
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
            ( p_msg         => 'Before calling
                               PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS',
              p_module_name => l_module_name,
              p_log_level   => 5 );
    END IF;
    PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
        ( P_PROJECT_ID                 => P_PROJECT_ID,
          P_BUDGET_VERSION_ID          => P_TARGET_BV_ID,
          X_FP_COLS_REC                => l_fp_cols_rec_target,
          X_RETURN_STATUS              => x_return_status,
          X_MSG_COUNT                  => x_msg_count,
          X_MSG_DATA                 => x_msg_data );
    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
            ( p_msg         => 'Status after calling
                              PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS: '
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5 );
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    l_rev_gen_method := nvl(l_fp_cols_rec_target.x_revenue_derivation_method,PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(p_project_id)); --Bug 5462471

    /* Get the same planning options flag via the COMPARE_ETC_SRC_TARGET_FP_OPT API */
    IF l_calling_context = lc_BudgetGeneration THEN
        l_gen_src_code := l_fp_cols_rec_target.x_gen_src_code;
    ELSIF  l_calling_context = lc_ForecastGeneration THEN
        l_gen_src_code := l_fp_cols_rec_target.x_gen_etc_src_code;
    END IF;

    IF l_gen_src_code = lc_WorkPlanSrcCode THEN
        l_wp_src_plan_ver_id := p_source_bv_id;
    ELSIF l_gen_src_code = lc_FinancialPlanSrcCode THEN
        l_fp_src_plan_ver_id := p_source_bv_id;
    END IF;

    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'Before calling ' ||
                               'PA_FP_FCST_GEN_AMT_UTILS.COMPARE_ETC_SRC_TARGET_FP_OPT',
              p_module_name => l_module_name,
              p_log_level   => 5 );
    END IF;
    PA_FP_FCST_GEN_AMT_UTILS.COMPARE_ETC_SRC_TARGET_FP_OPT
        ( P_PROJECT_ID                => p_project_id,
          P_WP_SRC_PLAN_VER_ID        => l_wp_src_plan_ver_id,
          P_FP_SRC_PLAN_VER_ID        => l_fp_src_plan_ver_id,
          P_FP_TARGET_PLAN_VER_ID     => p_target_bv_id,
          X_SAME_PLANNING_OPTION_FLAG => l_same_planning_options_flag,
          X_RETURN_STATUS             => x_return_status,
          X_MSG_COUNT                 => x_msg_count,
          X_MSG_DATA                  => x_msg_data );
    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'Status after calling ' ||
                               'PA_FP_FCST_GEN_AMT_UTILS.COMPARE_ETC_SRC_TARGET_FP_OPT: ' ||
                               x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5 );
    END IF;
    IF x_return_Status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    /* During Budget and Forecast Generation, when the planning options match between
     * the source and target, we need to copy the attributes from the source resource
     * assignments over to their target resource assignment counterparts. */
    IF l_same_planning_options_flag = 'Y' THEN

        /* Pick up the source resource assignment attributes.
         * The where clause of this query contains the Retain Manual Lines logic. */
        SELECT /*+ INDEX(TMP,PA_RES_LIST_MAP_TMP4_N3)*/
               TMP.TXN_RESOURCE_ASSIGNMENT_ID,
               RA.RESOURCE_CLASS_FLAG,
               RA.RESOURCE_CLASS_CODE,
               RA.RES_TYPE_CODE,
               RA.PERSON_ID,
               RA.JOB_ID,
               RA.PERSON_TYPE_CODE,
               RA.NAMED_ROLE,
               RA.BOM_RESOURCE_ID,
               RA.NON_LABOR_RESOURCE,
               RA.INVENTORY_ITEM_ID,
               RA.ITEM_CATEGORY_ID,
               RA.PROJECT_ROLE_ID,
               RA.ORGANIZATION_ID,
               RA.FC_RES_TYPE_CODE,
               RA.EXPENDITURE_TYPE,
               RA.EXPENDITURE_CATEGORY,
               RA.EVENT_TYPE,
               RA.REVENUE_CATEGORY_CODE,
               RA.SUPPLIER_ID,
               RA.SPREAD_CURVE_ID,
               RA.ETC_METHOD_CODE,
               RA.MFC_COST_TYPE_ID,
               RA.INCURRED_BY_RES_FLAG,
               RA.INCUR_BY_RES_CLASS_CODE,
               RA.INCUR_BY_ROLE_ID,
               RA.UNIT_OF_MEASURE,
               RA.RATE_BASED_FLAG,
               RA.RESOURCE_RATE_BASED_FLAG, -- Added for IPM ER
               RA.RATE_EXPENDITURE_TYPE,
               RA.RATE_EXP_FUNC_CURR_CODE,
               RA.RATE_EXPENDITURE_ORG_ID
	BULK COLLECT
        INTO   l_tgt_res_asg_id_tab,
               l_resource_class_flag_tab,
               l_resource_class_code_tab,
               l_res_type_code_tab,
               l_person_id_tab,
               l_job_id_tab,
               l_person_type_code_tab,
               l_named_role_tab,
               l_bom_resource_id_tab,
               l_non_labor_resource_tab,
               l_inventory_item_id_tab,
               l_item_category_id_tab,
               l_project_role_id_tab,
               l_organization_id_tab,
               l_fc_res_type_code_tab,
               l_expenditure_type_tab,
               l_expenditure_category_tab,
               l_event_type_tab,
               l_revenue_category_code_tab,
               l_supplier_id_tab,
               l_spread_curve_id_tab,
               l_etc_method_code_tab,
               l_mfc_cost_type_id_tab,
               l_incurred_by_res_flag_tab,
               l_incur_by_res_cls_code_tab,
               l_incur_by_role_id_tab,
               l_unit_of_measure_tab,
               l_rate_based_flag_tab,
               l_res_rate_based_flag_tab, -- Added for IPM ER
               l_rate_expenditure_type_tab,
               l_rate_func_curr_code_tab,
               l_org_id_tab
        FROM   PA_RESOURCE_ASSIGNMENTS RA,
               PA_RES_LIST_MAP_TMP4 TMP
        WHERE  RA.budget_version_id = p_source_bv_id
        AND    RA.resource_assignment_id = TMP.txn_source_id;

        -- Bug 4621901: When the Target is a Revenue-only version and the Revenue
        -- Accrual Method is COST, we must enforce that UOM be 'DOLLARS' and the
        -- Rate Based Flag be 'N' even if the Source/Target Planning Options match.

        IF l_fp_cols_rec_target.x_version_type = 'REVENUE' AND
           l_rev_gen_method = 'C' THEN
            FOR i IN 1..l_unit_of_measure_tab.count LOOP
                l_unit_of_measure_tab(i) := 'DOLLARS';
                l_rate_based_flag_tab(i) := 'N';
            END LOOP;
        END IF;

        FORALL i IN 1..l_tgt_res_asg_id_tab.count
            UPDATE PA_RESOURCE_ASSIGNMENTS
            SET    RESOURCE_CLASS_FLAG         = l_resource_class_flag_tab(i),
                   RESOURCE_CLASS_CODE         = l_resource_class_code_tab(i),
                   RES_TYPE_CODE               = l_res_type_code_tab(i),
                   PERSON_ID                   = l_person_id_tab(i),
                   JOB_ID                      = l_job_id_tab(i),
                   PERSON_TYPE_CODE            = l_person_type_code_tab(i),
                   NAMED_ROLE                  = l_named_role_tab(i),
                   BOM_RESOURCE_ID             = l_bom_resource_id_tab(i),
                   NON_LABOR_RESOURCE          = l_non_labor_resource_tab(i),
                   INVENTORY_ITEM_ID           = l_inventory_item_id_tab(i),
                   ITEM_CATEGORY_ID            = l_item_category_id_tab(i),
                   PROJECT_ROLE_ID             = l_project_role_id_tab(i),
                   ORGANIZATION_ID             = l_organization_id_tab(i),
                   FC_RES_TYPE_CODE            = l_fc_res_type_code_tab(i),
                   EXPENDITURE_TYPE            = l_expenditure_type_tab(i),
                   EXPENDITURE_CATEGORY        = l_expenditure_category_tab(i),
                   EVENT_TYPE                  = l_event_type_tab(i),
                   REVENUE_CATEGORY_CODE       = l_revenue_category_code_tab(i),
                   SUPPLIER_ID                 = l_supplier_id_tab(i),
                   SPREAD_CURVE_ID             = l_spread_curve_id_tab(i),
                   ETC_METHOD_CODE             = l_etc_method_code_tab(i),
                   MFC_COST_TYPE_ID            = l_mfc_cost_type_id_tab(i),
                   INCURRED_BY_RES_FLAG        = l_incurred_by_res_flag_tab(i),
                   INCUR_BY_RES_CLASS_CODE     = l_incur_by_res_cls_code_tab(i),
                   INCUR_BY_ROLE_ID            = l_incur_by_role_id_tab(i),
                   UNIT_OF_MEASURE             = l_unit_of_measure_tab(i),
                   RATE_BASED_FLAG             = l_rate_based_flag_tab(i),
                   RESOURCE_RATE_BASED_FLAG    = l_res_rate_based_flag_tab(i), -- Added for IPM ER
                   RATE_EXPENDITURE_TYPE       = l_rate_expenditure_type_tab(i),
                   RATE_EXP_FUNC_CURR_CODE     = l_rate_func_curr_code_tab(i),
                   LAST_UPDATE_DATE            = sysdate,
                   LAST_UPDATED_BY             = l_last_updated_by,
                   LAST_UPDATE_LOGIN           = l_last_update_login,
                   RATE_EXPENDITURE_ORG_ID     = l_org_id_tab(i)
            WHERE  resource_assignment_id      = l_tgt_res_asg_id_tab(i);

        -- IPM: New Entity ER ------------------------------------------
        IF l_calling_context = lc_BudgetGeneration THEN
            l_calling_module := 'BUDGET_GENERATION';
        ELSIF l_calling_context = lc_ForecastGeneration THEN
            l_calling_module := 'FORECAST_GENERATION';
        END IF;

        IF l_fp_cols_rec_target.x_gen_ret_manual_line_flag = 'N' THEN

            -- Call the maintenance api in COPY mode
            IF p_pa_debug_mode = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                    P_MSG                   => 'Before calling PA_RES_ASG_CURRENCY_PUB.' ||
                                               'MAINTAIN_DATA',
                  --P_CALLED_MODE           => p_called_mode,
                    P_MODULE_NAME           => l_module_name);
            END IF;
            PA_RES_ASG_CURRENCY_PUB.MAINTAIN_DATA
                  ( P_FP_COLS_REC           => l_fp_cols_rec_target,
                    P_CALLING_MODULE        => l_calling_module,
                    P_COPY_FLAG             => 'Y',
                    P_SRC_VERSION_ID        => p_source_bv_id,
                    P_COPY_MODE             => 'COPY_OVERRIDES',
                    P_VERSION_LEVEL_FLAG    => 'Y',
                  --P_CALLED_MODE           => p_called_mode,
                    X_RETURN_STATUS         => x_return_status,
                    X_MSG_COUNT             => x_msg_count,
                    X_MSG_DATA              => x_msg_data );
            IF p_pa_debug_mode = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                    P_MSG                   => 'After calling PA_RES_ASG_CURRENCY_PUB.' ||
                                               'MAINTAIN_DATA: '||x_return_status,
                  --P_CALLED_MODE           => p_called_mode,
                    P_MODULE_NAME           => l_module_name);
            END IF;
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

        ELSIF l_fp_cols_rec_target.x_gen_ret_manual_line_flag = 'Y' THEN

            DELETE pa_resource_asgn_curr_tmp;

            -- Note that while (txn_resource_assignment_id, txn_currency_code) pairs
            -- should be distinct in pa_res_list_map_tmp4 because of the one-to-one
            -- source/target mapping, (txn_resource_assignment_id) by itself is not
            -- guaranteed to be unique. Hence, the DISTINCT keyword is required in the
            -- query below.

            -- Also, as per the copy_table_records API specification, when calling
            -- the maintenance API in temp table Copy mode, only target ra_id values
            -- should be populated in the temp table.

	    INSERT INTO pa_resource_asgn_curr_tmp
	        ( resource_assignment_id )
	    SELECT DISTINCT txn_resource_assignment_id
	    FROM   pa_res_list_map_tmp4;

            -- Call the maintenance api in COPY mode
            IF p_pa_debug_mode = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                    P_MSG                   => 'Before calling PA_RES_ASG_CURRENCY_PUB.' ||
                                               'MAINTAIN_DATA',
                  --P_CALLED_MODE           => p_called_mode,
                    P_MODULE_NAME           => l_module_name);
            END IF;
            PA_RES_ASG_CURRENCY_PUB.MAINTAIN_DATA
                  ( P_FP_COLS_REC           => l_fp_cols_rec_target,
                    P_CALLING_MODULE        => l_calling_module,
                    P_COPY_FLAG             => 'Y',
                    P_SRC_VERSION_ID        => p_source_bv_id,
                    P_COPY_MODE             => 'COPY_OVERRIDES',
                    P_VERSION_LEVEL_FLAG    => 'N',
                  --P_CALLED_MODE           => p_called_mode,
                    X_RETURN_STATUS         => x_return_status,
                    X_MSG_COUNT             => x_msg_count,
                    X_MSG_DATA              => x_msg_data );
            IF p_pa_debug_mode = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                    P_MSG                   => 'After calling PA_RES_ASG_CURRENCY_PUB.' ||
                                               'MAINTAIN_DATA: '||x_return_status,
                  --P_CALLED_MODE           => p_called_mode,
                    P_MODULE_NAME           => l_module_name);
            END IF;
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

        END IF; -- l_fp_cols_rec_target.x_gen_ret_manual_line_flag check

        -- Ensure that non-billable tasks do not have bill rate overrides
        -- in the new entity table by re-Inserting new entity records with
        -- existing cost rate overrides but Null bill rate overrides for
        -- non-billable tasks.

        IF l_fp_cols_rec_source.x_version_type = 'ALL' AND
           l_fp_cols_rec_target.x_version_type IN ('REVENUE','ALL') THEN

            DELETE pa_resource_asgn_curr_tmp;

	    -- Note: An outer join on pa_tasks is not needed in the query
	    -- below because we are only interested in updating resources
	    -- for non-billable tasks. Project-level tasks that require an
	    -- outer join are always billable.
	    INSERT INTO pa_resource_asgn_curr_tmp
	        ( RESOURCE_ASSIGNMENT_ID,
	          TXN_CURRENCY_CODE,
	          TXN_RAW_COST_RATE_OVERRIDE,
	          TXN_BURDEN_COST_RATE_OVERRIDE )
	    SELECT rbc.resource_assignment_id,
	           rbc.txn_currency_code,
	           rbc.txn_raw_cost_rate_override,
	           rbc.txn_burden_cost_rate_override
	    FROM   pa_resource_asgn_curr rbc
	    WHERE  rbc.budget_version_id = p_target_bv_id
	    AND    rbc.txn_bill_rate_override IS NOT NULL
	    AND EXISTS ( SELECT null
	                 FROM   pa_res_list_map_tmp4 tmp4,
	                        pa_resource_assignments ra,
	                        pa_tasks ta
	                 WHERE  rbc.resource_assignment_id = tmp4.txn_resource_assignment_id
	                 AND    tmp4.txn_resource_assignment_id = ra.resource_assignment_id
	                 AND    ra.task_id = ta.task_id
	                 AND    NVL(ta.billable_flag,'Y') = 'N' );

            l_count := SQL%ROWCOUNT;

            IF l_count > 0 THEN
                -- CALL the maintenance api in INSERT mode
                IF p_pa_debug_mode = 'Y' THEN
                    PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                        P_MSG                   => 'Before calling PA_RES_ASG_CURRENCY_PUB.' ||
                                                   'MAINTAIN_DATA',
                      --P_CALLED_MODE           => p_called_mode,
                        P_MODULE_NAME           => l_module_name);
                END IF;
                PA_RES_ASG_CURRENCY_PUB.MAINTAIN_DATA
                      ( P_FP_COLS_REC           => l_fp_cols_rec_target,
                        P_CALLING_MODULE        => l_calling_module,
                        P_VERSION_LEVEL_FLAG    => 'N',
                        P_ROLLUP_FLAG           => 'N', -- 'N' indicates Insert
                      --P_CALLED_MODE           => p_called_mode,
                        X_RETURN_STATUS         => x_return_status,
                        X_MSG_COUNT             => x_msg_count,
                        X_MSG_DATA              => x_msg_data );
                IF p_pa_debug_mode = 'Y' THEN
                    PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                        P_MSG                   => 'After calling PA_RES_ASG_CURRENCY_PUB.' ||
                                                   'MAINTAIN_DATA: '||x_return_status,
                      --P_CALLED_MODE           => p_called_mode,
                        P_MODULE_NAME           => l_module_name);
                END IF;
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;
            END IF; -- IF l_count > 0 THEN
        END IF; -- logic to null out bill rate overrides for non-billable tasks
        -- END OF IPM: New Entity ER ------------------------------------------

    ELSIF l_same_planning_options_flag = 'N' THEN

        /* In this case, source and target timephase codes match, but one of the
         * other planning options do not. As a result, we will map source resources
         * to target resources. The budget lines created by this generation process
         * may therefore contain ammounts aggregated from source amounts, in which
         * case the target spread curve will no longer reflect budget line amounts.
         * Hence, we NULL out the spread_curve_id for the target resources. */

        UPDATE pa_resource_assignments
        SET    spread_curve_id = NULL,
               sp_fixed_date = NULL
        WHERE  budget_version_id = p_target_bv_id
        AND EXISTS
            ( SELECT /*+ INDEX(tmp,PA_RES_LIST_MAP_TMP4_N2)*/ 1
              FROM   pa_res_list_map_tmp4 tmp
              WHERE  tmp.txn_resource_assignment_id = resource_assignment_id
              AND    rownum = 1 );

    END IF; -- end updating resource assignment attributes


    /*source multi currency flag     target multi currency flag currency code used
        N                               N                               proj
        Y                               N                               proj
        N                               Y                               txn
        Y                               Y                               txn
      l_txn_currency_flag is 'Y' means we use txn_currency_code
      l_txn_currency_flag is 'N' means we use proj_currency_code
      l_txn_currency_flag is 'A' means we use projfunc_currency_code
     */
    SELECT NVL(APPROVED_COST_PLAN_TYPE_FLAG, 'N'),
           NVL(APPROVED_REV_PLAN_TYPE_FLAG, 'N')
           INTO
           l_appr_cost_plan_type_flag,
           l_appr_rev_plan_type_flag
    FROM PA_BUDGET_VERSIONS
    WHERE BUDGET_VERSION_ID = l_fp_cols_rec_target.x_budget_version_id;

    /* When the Calling Context is Forecast generation and we set l_txn_currency_flag
     * to 'A', we are really considering the case when the Source version is a Cost
     * forecast and the Target version is Revenue because this is the only case in
     * which we call this procedure from the forecast generation wrapper API. If this
     * premise changes, then this condition will need to be modified accordingly. */
    IF ((l_fp_cols_rec_target.x_version_type = 'ALL' OR
         l_fp_cols_rec_target.x_version_type = 'REVENUE') AND
        (l_appr_cost_plan_type_flag = 'Y' OR l_appr_rev_plan_type_flag = 'Y')) OR
        (l_calling_context = lc_BudgetGeneration AND l_rev_gen_method = 'C' AND
         l_fp_cols_rec_target.x_version_type = 'REVENUE') OR
        l_calling_context = lc_ForecastGeneration THEN
        l_txn_currency_flag := 'A';
    ELSIF l_fp_cols_rec_target.x_plan_in_multi_curr_flag = 'N' THEN
        l_txn_currency_flag := 'N';
    END IF;

    -- Bug 4057108: Order of pl/sql tables in the FETCH statement was reversed;
    -- pc tables now placed before pfc tables for both of the cursors below.
    /* Fetch data from the appropriate cursor based on the Calling Context:
     *   'BUDGET_GENERATION'   => use the budget_line_src_tgt cursor.
     *   'FORECAST_GENERATION' => use the fcst_budget_line_src_tgt cursor. */
    IF l_calling_context = lc_BudgetGeneration  THEN
               --Start Changes Bug 6411406
        IF l_fp_cols_rec_target.x_time_phased_code = 'N' THEN
          OPEN budget_line_src_tgt_none (l_fp_cols_rec_target.x_project_currency_code,
                                    l_fp_cols_rec_target.x_projfunc_currency_code);
          FETCH budget_line_src_tgt_none
          BULK COLLECT
          INTO l_tgt_res_asg_id_tab,
               l_tgt_rate_based_flag_tab,
               l_start_date_tab,
               l_end_date_tab,
               l_periiod_name_tab,
               l_txn_currency_code_tab,
               l_src_quantity_tab,
               l_txn_raw_cost_tab,
               l_txn_brdn_cost_tab,
               l_txn_revenue_tab,
               l_unrounded_txn_raw_cost_tab,
               l_unrounded_txn_brdn_cost_tab,
               l_unrounded_txn_revenue_tab,
               l_pc_raw_cost_tab,
               l_pc_brdn_cost_tab,
               l_pc_revenue_tab,
               l_pfc_raw_cost_tab,
               l_pfc_brdn_cost_tab,
               l_pfc_revenue_tab,
               l_cost_rate_override_tab,
               l_b_cost_rate_override_tab,
               l_bill_rate_override_tab,
               l_billable_flag_tab;
          CLOSE budget_line_src_tgt_none;
        ELSE

        OPEN budget_line_src_tgt (l_fp_cols_rec_target.x_project_currency_code,
                                  l_fp_cols_rec_target.x_projfunc_currency_code);
        FETCH budget_line_src_tgt
        BULK COLLECT
        INTO l_tgt_res_asg_id_tab,
             l_tgt_rate_based_flag_tab,
             l_start_date_tab,
             l_end_date_tab,
             l_periiod_name_tab,
             l_txn_currency_code_tab,
             l_src_quantity_tab,
             l_txn_raw_cost_tab,
             l_txn_brdn_cost_tab,
             l_txn_revenue_tab,
             l_unrounded_txn_raw_cost_tab,
             l_unrounded_txn_brdn_cost_tab,
             l_unrounded_txn_revenue_tab,
             l_pc_raw_cost_tab,
             l_pc_brdn_cost_tab,
             l_pc_revenue_tab,
             l_pfc_raw_cost_tab,
             l_pfc_brdn_cost_tab,
             l_pfc_revenue_tab,
             l_cost_rate_override_tab,
             l_b_cost_rate_override_tab,
             l_bill_rate_override_tab,
             l_billable_flag_tab,           /* Added for ER 4376722 */
             l_markup_percent_tab;          /* Added for Bug 5166047 */
        CLOSE budget_line_src_tgt;
	END IF;
        --End Changes Bug 6411406

    ELSIF l_calling_context = lc_ForecastGeneration AND
          l_fp_cols_rec_source.x_time_phased_code IN ('P','G') THEN
        OPEN fcst_budget_line_src_tgt
             (l_fp_cols_rec_target.x_project_currency_code,
              l_fp_cols_rec_target.x_projfunc_currency_code,
              l_fp_cols_rec_source.x_time_phased_code);
        FETCH fcst_budget_line_src_tgt
        BULK COLLECT
        INTO l_tgt_res_asg_id_tab,
             l_tgt_rate_based_flag_tab,
             l_start_date_tab,
             l_end_date_tab,
             l_periiod_name_tab,
             l_txn_currency_code_tab,
             l_src_quantity_tab,
             l_txn_raw_cost_tab,
             l_txn_brdn_cost_tab,
             l_txn_revenue_tab,
             l_unrounded_txn_raw_cost_tab,
             l_unrounded_txn_brdn_cost_tab,
             l_unrounded_txn_revenue_tab,
             l_pc_raw_cost_tab,
             l_pc_brdn_cost_tab,
             l_pc_revenue_tab,
             l_pfc_raw_cost_tab,
             l_pfc_brdn_cost_tab,
             l_pfc_revenue_tab,
             l_cost_rate_override_tab,
             l_b_cost_rate_override_tab,
             l_bill_rate_override_tab,
             l_billable_flag_tab,           /* Added for ER 4376722 */
             l_markup_percent_tab;          /* Added for Bug 5166047 */
        CLOSE fcst_budget_line_src_tgt;
    ELSIF l_calling_context = lc_ForecastGeneration AND
          l_fp_cols_rec_source.x_time_phased_code = 'N' THEN
        OPEN fcst_budget_line_src_tgt_none
             (l_fp_cols_rec_target.x_project_currency_code,
              l_fp_cols_rec_target.x_projfunc_currency_code,
              l_fp_cols_rec_source.x_time_phased_code);
        FETCH fcst_budget_line_src_tgt_none
        BULK COLLECT
        INTO l_tgt_res_asg_id_tab,
             l_tgt_rate_based_flag_tab,
             l_start_date_tab,
             l_end_date_tab,
             l_periiod_name_tab,
             l_txn_currency_code_tab,
             l_src_quantity_tab,
             l_txn_raw_cost_tab,
             l_txn_brdn_cost_tab,
             l_txn_revenue_tab,
             l_unrounded_txn_raw_cost_tab,
             l_unrounded_txn_brdn_cost_tab,
             l_unrounded_txn_revenue_tab,
             l_pc_raw_cost_tab,
             l_pc_brdn_cost_tab,
             l_pc_revenue_tab,
             l_pfc_raw_cost_tab,
             l_pfc_brdn_cost_tab,
             l_pfc_revenue_tab,
             l_cost_rate_override_tab,
             l_b_cost_rate_override_tab,
             l_bill_rate_override_tab,
             l_billable_flag_tab,           /* Added for ER 4376722 */
             l_markup_percent_tab;          /* Added for Bug 5166047 */
        CLOSE fcst_budget_line_src_tgt_none;
    END IF; -- context-based data fetching

    -- Stop processing if no budget line data is fetched.
    IF l_tgt_res_asg_id_tab.count <= 0 THEN
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RETURN;
    END IF; -- l_tgt_res_asg_id_tab.count <= 0

    /*Please refer to document: How to derive the rate*/
    l_source_version_type := l_fp_cols_rec_source.x_version_type;
    l_target_version_type := l_fp_cols_rec_target.x_version_type;

    /* ER 4376722:
     * When the Target is a Revenue-only Budget:
     * A) Do not generate quantity or amounts for non-billable tasks.
     * When the Target is a Revenue-only Forecast:
     * B) Do not generate quantity or amounts for non-rate-based
     *    resources of non-billable tasks.
     * C) Generate quantity but not amounts for rate-based resources
     *    of non-billable tasks.
     *
     * The simple algorithm to do (A) and (B) is as follows:
     * 0. Clear out any data in the _tmp_ tables.
     * 1. Copy records into _tmp_ tables for
     * a) billable tasks when the context is Budget Generation
     * b) billable tasks when the context is Forecast Generation
     * c) rate-based resources of non-billable tasks when the
     *    context is Forecast Generation
     * 2. Copy records from _tmp_ tables back to non-temporary tables.
     *
     * The result is that, afterwards, we do not process non-billable
     * task records in the Budget Generation context, and we do not
     * process non-rate-based resources of non-billable tasks in the
     * Forecast Generation Context. Hence, quantity and amounts for
     * those resources will not be generated.
     *
     * Note that case (C) is handled later at the end of the
     * Forecast Generation logic.
     **/

    IF l_target_version_type = 'REVENUE' THEN

        -- 0. Clear out any data in the _tmp_ tables.
	l_tmp_tgt_res_asg_id_tab.delete;
	l_tmp_tgt_rate_based_flag_tab.delete;
	l_tmp_start_date_tab.delete;
	l_tmp_end_date_tab.delete;
	l_tmp_periiod_name_tab.delete;
	l_tmp_txn_currency_code_tab.delete;
	l_tmp_src_quantity_tab.delete;
	l_tmp_txn_raw_cost_tab.delete;
	l_tmp_txn_brdn_cost_tab.delete;
	l_tmp_txn_revenue_tab.delete;
	l_tmp_unr_txn_raw_cost_tab.delete;
	l_tmp_unr_txn_brdn_cost_tab.delete;
	l_tmp_unr_txn_revenue_tab.delete;
	l_tmp_pc_raw_cost_tab.delete;
	l_tmp_pc_brdn_cost_tab.delete;
	l_tmp_pc_revenue_tab.delete;
	l_tmp_pfc_raw_cost_tab.delete;
	l_tmp_pfc_brdn_cost_tab.delete;
	l_tmp_pfc_revenue_tab.delete;
	l_tmp_cost_rate_override_tab.delete;
	l_tmp_bcost_rate_override_tab.delete;
	l_tmp_bill_rate_override_tab.delete;
	l_tmp_billable_flag_tab.delete;
	l_tmp_markup_percent_tab.delete; -- Added for Bug 5166047

        -- 1. Copy records into _tmp_ tables for
        -- a) billable tasks when the context is Budget Generation
        -- b) billable tasks when the context is Forecast Generation
        -- c) rate-based resources of non-billable tasks when the
        --    context is Forecast Generation
        l_tmp_index := 0;
        FOR i IN 1..l_tgt_res_asg_id_tab.count LOOP
            IF ( l_calling_context = lc_BudgetGeneration AND
                 l_billable_flag_tab(i) = 'Y' ) OR
               ( l_calling_context = lc_ForecastGeneration AND
                 ( l_billable_flag_tab(i) = 'Y' OR
                 ( l_billable_flag_tab(i) = 'N' AND l_tgt_rate_based_flag_tab(i) = 'Y' ))) THEN

                l_tmp_index := l_tmp_index + 1;
                l_tmp_tgt_res_asg_id_tab(l_tmp_index)      := l_tgt_res_asg_id_tab(i);
                l_tmp_tgt_rate_based_flag_tab(l_tmp_index) := l_tgt_rate_based_flag_tab(i);
                l_tmp_start_date_tab(l_tmp_index)          := l_start_date_tab(i);
                l_tmp_end_date_tab(l_tmp_index)            := l_end_date_tab(i);
                l_tmp_periiod_name_tab(l_tmp_index)        := l_periiod_name_tab(i);
                l_tmp_txn_currency_code_tab(l_tmp_index)   := l_txn_currency_code_tab(i);
                l_tmp_src_quantity_tab(l_tmp_index)        := l_src_quantity_tab(i);
                l_tmp_txn_raw_cost_tab(l_tmp_index)        := l_txn_raw_cost_tab(i);
                l_tmp_txn_brdn_cost_tab(l_tmp_index)       := l_txn_brdn_cost_tab(i);
                l_tmp_txn_revenue_tab(l_tmp_index)         := l_txn_revenue_tab(i);
                l_tmp_unr_txn_raw_cost_tab(l_tmp_index)    := l_unrounded_txn_raw_cost_tab(i);
                l_tmp_unr_txn_brdn_cost_tab(l_tmp_index)   := l_unrounded_txn_brdn_cost_tab(i);
                l_tmp_unr_txn_revenue_tab(l_tmp_index)     := l_unrounded_txn_revenue_tab(i);
                l_tmp_pc_raw_cost_tab(l_tmp_index)         := l_pc_raw_cost_tab(i);
                l_tmp_pc_brdn_cost_tab(l_tmp_index)        := l_pc_brdn_cost_tab(i);
                l_tmp_pc_revenue_tab(l_tmp_index)          := l_pc_revenue_tab(i);
                l_tmp_pfc_raw_cost_tab(l_tmp_index)        := l_pfc_raw_cost_tab(i);
                l_tmp_pfc_brdn_cost_tab(l_tmp_index)       := l_pfc_brdn_cost_tab(i);
                l_tmp_pfc_revenue_tab(l_tmp_index)         := l_pfc_revenue_tab(i);
                l_tmp_cost_rate_override_tab(l_tmp_index)  := l_cost_rate_override_tab(i);
                l_tmp_bcost_rate_override_tab(l_tmp_index) := l_b_cost_rate_override_tab(i);
                l_tmp_bill_rate_override_tab(l_tmp_index)  := l_bill_rate_override_tab(i);
                l_tmp_billable_flag_tab(l_tmp_index)       := l_billable_flag_tab(i);
                l_tmp_markup_percent_tab(l_tmp_index)      := l_markup_percent_tab(i); -- Added for Bug 5166047

            END IF;
        END LOOP;

        -- 2. Copy records from _tmp_ tables back to non-temporary tables.
        l_tgt_res_asg_id_tab          := l_tmp_tgt_res_asg_id_tab;
        l_tgt_rate_based_flag_tab     := l_tmp_tgt_rate_based_flag_tab;
        l_start_date_tab              := l_tmp_start_date_tab;
        l_end_date_tab                := l_tmp_end_date_tab;
        l_periiod_name_tab            := l_tmp_periiod_name_tab;
        l_txn_currency_code_tab       := l_tmp_txn_currency_code_tab;
        l_src_quantity_tab            := l_tmp_src_quantity_tab;
        l_txn_raw_cost_tab            := l_tmp_txn_raw_cost_tab;
        l_txn_brdn_cost_tab           := l_tmp_txn_brdn_cost_tab;
        l_txn_revenue_tab             := l_tmp_txn_revenue_tab;
        l_unrounded_txn_raw_cost_tab  := l_tmp_unr_txn_raw_cost_tab;
        l_unrounded_txn_brdn_cost_tab := l_tmp_unr_txn_brdn_cost_tab;
        l_unrounded_txn_revenue_tab   := l_tmp_unr_txn_revenue_tab;
        l_pc_raw_cost_tab             := l_tmp_pc_raw_cost_tab;
        l_pc_brdn_cost_tab            := l_tmp_pc_brdn_cost_tab;
        l_pc_revenue_tab              := l_tmp_pc_revenue_tab;
        l_pfc_raw_cost_tab            := l_tmp_pfc_raw_cost_tab;
        l_pfc_brdn_cost_tab           := l_tmp_pfc_brdn_cost_tab;
        l_pfc_revenue_tab             := l_tmp_pfc_revenue_tab;
        l_cost_rate_override_tab      := l_tmp_cost_rate_override_tab;
        l_b_cost_rate_override_tab    := l_tmp_bcost_rate_override_tab;
        l_bill_rate_override_tab      := l_tmp_bill_rate_override_tab;
        l_billable_flag_tab           := l_tmp_billable_flag_tab;
        l_markup_percent_tab          := l_tmp_markup_percent_tab; -- Added for Bug 5166047

        -- Stop processing if no data remains (ie. all the tasks were non-billable).
        IF l_tgt_res_asg_id_tab.count <= 0 THEN
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.RESET_CURR_FUNCTION;
            END IF;
            RETURN;
        END IF; -- l_tgt_res_asg_id_tab.count <= 0

    END IF; -- ER 4376722 billability logic for REVENUE versions

    l_remove_records_flag := 'N';
    -- Initialize l_remove_record_flag_tab
    FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
        l_remove_record_flag_tab(i) := 'N';
    END LOOP;

    /* We split up the generation logic here based on whether the Calling Context
     * indicates we are performing budget generation or forecast generation. */
    IF l_calling_context = lc_BudgetGeneration  THEN
        IF l_source_version_type = 'COST' AND l_target_version_type = 'COST' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                l_override_quantity := l_src_quantity_tab(i);
                IF l_tgt_rate_based_flag_tab(i) = 'N' AND
                   NOT( l_wp_track_cost_flag = 'N' AND
                        l_gen_src_code = lc_WorkPlanSrcCode ) THEN
                    l_src_quantity_tab(i):= l_txn_raw_cost_tab(i);
                    l_override_quantity := l_unrounded_txn_raw_cost_tab(i);
                END IF;
                IF l_override_quantity <> 0 THEN
                    l_cost_rate_override_tab(i)   := l_unrounded_txn_raw_cost_tab(i) / l_override_quantity;
                    l_b_cost_rate_override_tab(i) := l_unrounded_txn_brdn_cost_tab(i) / l_override_quantity;
                    IF l_tgt_rate_based_flag_tab(i) = 'N' THEN
                        l_cost_rate_override_tab(i) := 1;
                    END IF;
                END IF;
            END LOOP;
        ELSIF l_source_version_type = 'COST' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'T' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                l_override_quantity := l_src_quantity_tab(i);
                IF l_tgt_rate_based_flag_tab(i) = 'N' AND
                   NOT( l_wp_track_cost_flag = 'N' AND
                        l_gen_src_code = lc_WorkPlanSrcCode ) THEN
                    l_src_quantity_tab(i):= l_txn_raw_cost_tab(i); --???
                    l_override_quantity := l_unrounded_txn_raw_cost_tab(i);
                    -- updated by dkuo
                    -- Bug 4568011: Commented out revenue and bill rate override
                    -- pl/sql table assignments so that the Calculate API will
                    -- compute revenue amounts.
                    -- l_txn_revenue_tab(i) := l_txn_raw_cost_tab(i);
                    -- l_bill_rate_override_tab(i) := 1;
                    -- l_pfc_revenue_tab(i) := l_pfc_raw_cost_tab(i);
                    -- l_pc_revenue_tab(i) := l_pc_raw_cost_tab(i);
                END IF;
                IF l_src_quantity_tab(i) <> 0 THEN
                    l_cost_rate_override_tab(i) := l_unrounded_txn_raw_cost_tab(i) / l_override_quantity;
                    l_b_cost_rate_override_tab(i) := l_unrounded_txn_brdn_cost_tab(i) / l_override_quantity;
                    IF l_tgt_rate_based_flag_tab(i) = 'N' THEN
                        l_cost_rate_override_tab(i) := 1;
                    END IF;
                END IF;
                l_txn_raw_cost_tab(i) := NULL;
                l_txn_brdn_cost_tab(i) := NULL;
            END LOOP;
        ELSIF l_source_version_type = 'COST' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'C' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                l_src_quantity_tab(i):= l_txn_brdn_cost_tab(i);
                l_txn_revenue_tab(i) := l_txn_brdn_cost_tab(i);
                l_txn_raw_cost_tab(i) := NULL;
                l_txn_brdn_cost_tab(i) := NULL;
                l_bill_rate_override_tab(i) := 1;
                l_pfc_revenue_tab(i) := l_pfc_brdn_cost_tab(i);
                l_pc_revenue_tab(i) := l_pc_brdn_cost_tab(i);
            END LOOP;
        ELSIF l_source_version_type = 'COST' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'E' THEN
            /*Revenue is only based on billing events, which is handled seperately*/
            l_dummy := 1;
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.RESET_CURR_FUNCTION;
            END IF;
            RETURN;
        ELSIF l_source_version_type = 'COST' AND
              l_target_version_type = 'ALL' AND
              l_rev_gen_method = 'T' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                l_override_quantity := l_src_quantity_tab(i);
                IF l_tgt_rate_based_flag_tab(i) = 'N' AND
                   NOT( l_wp_track_cost_flag = 'N' AND
                        l_gen_src_code = lc_WorkPlanSrcCode ) THEN
                    l_src_quantity_tab(i):= l_txn_raw_cost_tab(i);
                    l_override_quantity := l_unrounded_txn_raw_cost_tab(i);
                END IF;
                IF l_override_quantity <> 0 THEN
                    l_cost_rate_override_tab(i) := l_unrounded_txn_raw_cost_tab(i) / l_override_quantity;
                    l_b_cost_rate_override_tab(i) := l_unrounded_txn_brdn_cost_tab(i) / l_override_quantity;
                    IF l_tgt_rate_based_flag_tab(i) = 'N' THEN
                        l_cost_rate_override_tab(i) := 1;
                    END IF;
                END IF;
            END LOOP;
        ELSIF l_source_version_type = 'COST' AND
              l_target_version_type = 'ALL' AND
              l_rev_gen_method = 'C' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                l_override_quantity := l_src_quantity_tab(i);
                IF l_tgt_rate_based_flag_tab(i) = 'N' AND
                   NOT( l_wp_track_cost_flag = 'N' AND
                        l_gen_src_code = lc_WorkPlanSrcCode ) THEN
                    l_src_quantity_tab(i):= l_txn_raw_cost_tab(i);
                    l_override_quantity := l_unrounded_txn_raw_cost_tab(i);
                END IF;
                IF l_override_quantity <> 0 THEN
                    l_cost_rate_override_tab(i) := l_unrounded_txn_raw_cost_tab(i) / l_override_quantity;
                    l_b_cost_rate_override_tab(i) := l_unrounded_txn_brdn_cost_tab(i) / l_override_quantity;
                    IF l_tgt_rate_based_flag_tab(i) = 'N' THEN
                        l_cost_rate_override_tab(i) := 1;
                    END IF;
                END IF;
            END LOOP;
        ELSIF l_source_version_type = 'COST' AND
              l_target_version_type = 'ALL' AND
              l_rev_gen_method = 'E' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                l_override_quantity := l_src_quantity_tab(i);
                IF l_tgt_rate_based_flag_tab(i) = 'N' AND
                   NOT( l_wp_track_cost_flag = 'N' AND
                        l_gen_src_code = lc_WorkPlanSrcCode ) THEN
                    l_src_quantity_tab(i):= l_txn_raw_cost_tab(i);
                    l_override_quantity := l_unrounded_txn_raw_cost_tab(i);
                END IF;
                IF l_override_quantity <> 0 THEN
                    l_cost_rate_override_tab(i) := l_unrounded_txn_raw_cost_tab(i) / l_override_quantity;
                    l_b_cost_rate_override_tab(i) := l_unrounded_txn_brdn_cost_tab(i) / l_override_quantity;
                    IF l_tgt_rate_based_flag_tab(i) = 'N' THEN
                        l_cost_rate_override_tab(i) := 1;
                    END IF;
                END IF;
            END LOOP;
            /*Revenue is only based on billing events, which is handled seperately*/
---============================================================================
        ELSIF l_source_version_type = 'REVENUE' AND l_target_version_type = 'COST' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                IF  l_tgt_rate_based_flag_tab(i) = 'N' THEN
                    l_src_quantity_tab(i):= l_txn_revenue_tab(i); --???
                END IF;
                l_txn_revenue_tab(i) := NULL;
            END LOOP;
        ELSIF l_source_version_type = 'REVENUE' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'T' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                l_override_quantity := l_src_quantity_tab(i);
                IF  l_tgt_rate_based_flag_tab(i) = 'N' THEN
                    l_src_quantity_tab(i):= l_txn_revenue_tab(i);
                    l_override_quantity := l_unrounded_txn_revenue_tab(i);
                END IF;
                IF l_override_quantity <> 0 THEN
                    l_bill_rate_override_tab(i) := l_unrounded_txn_revenue_tab(i) / l_override_quantity;
                END IF;
            END LOOP;
        ELSIF l_source_version_type = 'REVENUE' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'C' THEN
            /*This is invalid operation, had been handled at the beginning of process*/
            l_dummy := 1;
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.RESET_CURR_FUNCTION;
            END IF;
            RETURN;
        ELSIF l_source_version_type = 'REVENUE' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'E' THEN
            /*Revenue is only based on billing events, which is handled seperately*/
            l_dummy := 1;
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.RESET_CURR_FUNCTION;
            END IF;
            RETURN;
        ELSIF l_source_version_type = 'REVENUE' AND
              l_target_version_type = 'ALL' AND
              l_rev_gen_method = 'T' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                l_override_quantity := l_src_quantity_tab(i);
                IF  l_tgt_rate_based_flag_tab(i) = 'N' THEN
                    l_src_quantity_tab(i):= l_txn_revenue_tab(i);
                    l_override_quantity := l_unrounded_txn_revenue_tab(i);
                END IF;
                IF l_override_quantity <> 0 THEN
                    l_bill_rate_override_tab(i) := l_unrounded_txn_revenue_tab(i) / l_src_quantity_tab(i);
                END IF;
            END LOOP;
        ELSIF l_source_version_type = 'REVENUE' AND
              l_target_version_type = 'ALL' AND
              l_rev_gen_method = 'C' THEN
            /*This is invalid operation, had been handled at the beginning of process*/
            l_dummy := 1;
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.RESET_CURR_FUNCTION;
            END IF;
            RETURN;
        ELSIF l_source_version_type = 'REVENUE' AND
              l_target_version_type = 'ALL' AND
              l_rev_gen_method = 'E' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                IF  l_tgt_rate_based_flag_tab(i) = 'N' THEN
                    l_src_quantity_tab(i):= l_txn_revenue_tab(i); --???
                END IF;
                l_txn_revenue_tab(i) := NULL;
            END LOOP;
            /*Revenue is only based on billing events, which is handled seperately*/
--============================================================================
        ELSIF l_source_version_type = 'ALL' AND l_target_version_type = 'COST' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                l_override_quantity := l_src_quantity_tab(i);
                IF l_tgt_rate_based_flag_tab(i) = 'N' THEN
                    l_src_quantity_tab(i):= l_txn_raw_cost_tab(i);
                    l_override_quantity := l_unrounded_txn_raw_cost_tab(i);
                END IF;
                l_txn_revenue_tab(i) := NULL;
                IF l_override_quantity <> 0 THEN
                    l_cost_rate_override_tab(i) := l_unrounded_txn_raw_cost_tab(i) / l_override_quantity;
                    l_b_cost_rate_override_tab(i) := l_unrounded_txn_brdn_cost_tab(i) / l_override_quantity;
                ELSE -- Added for IPM
                    l_remove_record_flag_tab(i) := 'Y';
                    l_remove_records_flag := 'Y';
                END IF;
            END LOOP;
        ELSIF l_source_version_type = 'ALL' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'T' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP

                -- Bug 4568011: When Source revenue amounts exist, the
                -- Calculate API should honor those amounts instead of
                -- computing revenue amounts. For this to happen, the
                -- REVENUE_BILL_RATE column of the PA_FP_GEN_RATE_TMP
                -- table needs to be populated with the bill rate override.
                -- Likewise, when Source revenue amounts do not exist,
                -- the Calculate API should compute revenue amounts. In
                -- this case, the bill rate override should be NULL.

                l_override_quantity := l_src_quantity_tab(i);
                IF l_tgt_rate_based_flag_tab(i) = 'N' THEN
                    IF l_txn_revenue_tab(i) IS NOT NULL THEN
                        l_src_quantity_tab(i):= l_txn_revenue_tab(i);
                        l_override_quantity := l_unrounded_txn_revenue_tab(i);
                    ELSE
                        l_src_quantity_tab(i):= l_txn_raw_cost_tab(i);
                        l_override_quantity := l_unrounded_txn_raw_cost_tab(i);
                    END IF;
                END IF;
                l_txn_raw_cost_tab(i) := NULL;
                l_txn_brdn_cost_tab(i) := NULL;
                IF l_override_quantity <> 0 THEN
                    l_cost_rate_override_tab(i) := l_unrounded_txn_raw_cost_tab(i) / l_override_quantity;
                    l_b_cost_rate_override_tab(i) := l_unrounded_txn_brdn_cost_tab(i) / l_override_quantity;
                    l_bill_rate_override_tab(i) := l_unrounded_txn_revenue_tab(i) / l_override_quantity;
                ELSE -- Added for IPM
                    l_remove_record_flag_tab(i) := 'Y';
                    l_remove_records_flag := 'Y';
                END IF;
            END LOOP;
        ELSIF l_source_version_type = 'ALL' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'C' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                l_src_quantity_tab(i):= l_txn_brdn_cost_tab(i);
                l_txn_revenue_tab(i) := l_txn_brdn_cost_tab(i);
                l_txn_raw_cost_tab(i) := NULL;
                l_txn_brdn_cost_tab(i) := NULL;
                l_bill_rate_override_tab(i) := 1;
                l_pfc_revenue_tab(i) := l_pfc_brdn_cost_tab(i);
                l_pc_revenue_tab(i) := l_pc_brdn_cost_tab(i);
                -- Added for IPM
                IF nvl(l_src_quantity_tab(i),0) = 0 THEN
                    l_remove_record_flag_tab(i) := 'Y';
                    l_remove_records_flag := 'Y';
                END IF;
            END LOOP;
        ELSIF l_source_version_type = 'ALL' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'E' THEN
            /*Revenue is only based on billing events, which is handled seperately*/
            l_dummy := 1;
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.RESET_CURR_FUNCTION;
            END IF;
            RETURN;
        ELSIF l_source_version_type = 'ALL' AND
              l_target_version_type = 'ALL' AND
              l_rev_gen_method = 'T' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                l_override_quantity := l_src_quantity_tab(i);
                IF l_tgt_rate_based_flag_tab(i) = 'N' THEN
                    -- Modified for IPM
                    IF nvl(l_txn_raw_cost_tab(i),0) = 0 THEN
                        -- Source is a revenue-only txn (qty = rev).
                        l_src_quantity_tab(i):= l_txn_revenue_tab(i);
                        l_override_quantity := l_unrounded_txn_revenue_tab(i);
                    ELSE
                        l_src_quantity_tab(i):= l_txn_raw_cost_tab(i);
                        l_override_quantity := l_unrounded_txn_raw_cost_tab(i);
                    END IF;
                END IF;
                IF l_override_quantity <> 0 THEN
                    l_cost_rate_override_tab(i) := l_unrounded_txn_raw_cost_tab(i) / l_override_quantity;
                    l_b_cost_rate_override_tab(i) := l_unrounded_txn_brdn_cost_tab(i) / l_override_quantity;
                    l_bill_rate_override_tab(i) := l_unrounded_txn_revenue_tab(i) / l_override_quantity;
                ELSE -- Added for IPM
                    l_remove_record_flag_tab(i) := 'Y';
                    l_remove_records_flag := 'Y';
                END IF;
             END LOOP;
        ELSIF l_source_version_type = 'ALL' AND
              l_target_version_type = 'ALL' AND
              l_rev_gen_method = 'C' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                l_override_quantity := l_src_quantity_tab(i);
                IF l_tgt_rate_based_flag_tab(i) = 'N' THEN
                    -- Modified for IPM
                    IF nvl(l_txn_raw_cost_tab(i),0) = 0 THEN
                        -- Source is a revenue-only txn (qty = rev).
                        -- Do not generate cost from a revenue amount.
                        -- Nulling out qty will cause the record to be skipped.
                        l_src_quantity_tab(i):= null;
                        l_override_quantity := null;
                    ELSE
                        l_src_quantity_tab(i):= l_txn_raw_cost_tab(i);
                        l_override_quantity := l_unrounded_txn_raw_cost_tab(i);
                    END IF;
                END IF;
                l_txn_revenue_tab(i) := l_txn_brdn_cost_tab(i);
                IF l_override_quantity <> 0 THEN
                    l_cost_rate_override_tab(i) := l_unrounded_txn_raw_cost_tab(i) / l_override_quantity;
                    l_b_cost_rate_override_tab(i) := l_unrounded_txn_brdn_cost_tab(i) / l_override_quantity;
                    l_bill_rate_override_tab(i) := l_unrounded_txn_revenue_tab(i) / l_override_quantity;
                ELSE -- Added for IPM
                    l_remove_record_flag_tab(i) := 'Y';
                    l_remove_records_flag := 'Y';
                END IF;
            END LOOP;
        ELSIF l_source_version_type = 'ALL' AND
              l_target_version_type = 'ALL' AND
              l_rev_gen_method = 'E' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                l_override_quantity := l_src_quantity_tab(i);
                IF  l_tgt_rate_based_flag_tab(i) = 'N' THEN
                    -- Modified for IPM
                    IF nvl(l_txn_raw_cost_tab(i),0) = 0 THEN
                        -- Source is a revenue-only txn (qty = rev).
                        -- Do not double count the revenue amount.
                        -- Nulling out qty will cause the record to be skipped.
                        l_src_quantity_tab(i):= null;
                        l_override_quantity := null;
                    ELSE
                        l_src_quantity_tab(i):= l_txn_raw_cost_tab(i);
                        l_override_quantity := l_unrounded_txn_raw_cost_tab(i);
                    END IF;
                END IF;
                IF l_override_quantity <> 0 THEN
                    l_cost_rate_override_tab(i) := l_unrounded_txn_raw_cost_tab(i) / l_override_quantity;
                    l_b_cost_rate_override_tab(i) := l_unrounded_txn_brdn_cost_tab(i) / l_override_quantity;
                ELSE -- Added for IPM
                    l_remove_record_flag_tab(i) := 'Y';
                    l_remove_records_flag := 'Y';
                END IF;
                /* When generation is Event-based, we get revenues from the billing events. If we
                 * include revenues from the source, revenues will be double counted. Therefore,
                 * we set source revenue amounts to NULL so calculate API doesn't include. */
                l_txn_revenue_tab(i) := NULL;
            END LOOP;
            /*Revenue is only based on billing events, which is handled seperately.*/
        END IF;
        /*End refer to document: How to derive the rate*/
    /* Revenue forecast generation logic */
    ELSIF l_calling_context = lc_ForecastGeneration THEN
        IF l_source_version_type = 'COST' AND
           l_target_version_type = 'REVENUE' AND
           l_rev_gen_method = 'T' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                l_override_quantity := l_src_quantity_tab(i);
                IF l_tgt_rate_based_flag_tab(i) = 'N' THEN
                    -- currently using budgeting logic's approach because of some bug possibility.
                    l_src_quantity_tab(i):= l_txn_raw_cost_tab(i); --???
                    l_override_quantity := l_unrounded_txn_raw_cost_tab(i);

                    -- Bug 4568011: Commented out revenue and bill rate override
                    -- pl/sql table assignments so that the Calculate API will
                    -- compute revenue amounts.
                    -- l_txn_revenue_tab(i) := l_txn_raw_cost_tab(i);
                    -- l_bill_rate_override_tab(i) := 1;
                    -- l_pfc_revenue_tab(i) := l_pfc_raw_cost_tab(i);
                    -- l_pc_revenue_tab(i) := l_pc_raw_cost_tab(i);
                END IF;
                IF l_override_quantity <> 0 THEN
                    l_cost_rate_override_tab(i) := l_unrounded_txn_raw_cost_tab(i) / l_override_quantity;
                    l_b_cost_rate_override_tab(i) := l_unrounded_txn_brdn_cost_tab(i) / l_override_quantity;
                END IF;
                l_txn_raw_cost_tab(i) := NULL;
                l_txn_brdn_cost_tab(i) := NULL;
            END LOOP;
        ELSIF l_source_version_type = 'COST' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'C' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                l_src_quantity_tab(i):= l_txn_brdn_cost_tab(i);
                l_txn_revenue_tab(i) := l_txn_brdn_cost_tab(i);
                l_txn_raw_cost_tab(i) := NULL;
                l_txn_brdn_cost_tab(i) := NULL;
                l_bill_rate_override_tab(i) := 1;
                l_pfc_revenue_tab(i) := l_pfc_brdn_cost_tab(i);
                l_pc_revenue_tab(i) := l_pc_brdn_cost_tab(i);
            END LOOP;
        ELSIF l_source_version_type = 'COST' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'E' THEN
            /* This stub is here for completeness in the flow of the generation logic.
             * We do nothing here because the wrapper API does not call this procedure
             * in the case of Event-based revenue generation. Hence, we should never
             * arrive here in a valid code path. */
            l_dummy := 1;
        ELSIF l_source_version_type = 'ALL' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'T' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP

                -- Bug 4568011: When Source revenue amounts exist, the
                -- Calculate API should honor those amounts instead of
                -- computing revenue amounts. For this to happen, the
                -- REVENUE_BILL_RATE column of the PA_FP_GEN_RATE_TMP
                -- table needs to be populated with the bill rate override.
                -- Likewise, when Source revenue amounts do not exist,
                -- the Calculate API should compute revenue amounts. In
                -- this case, the bill rate override should be NULL.

                l_override_quantity := l_src_quantity_tab(i);
                IF l_tgt_rate_based_flag_tab(i) = 'N' THEN
                    IF l_txn_revenue_tab(i) IS NOT NULL THEN
                        l_src_quantity_tab(i):= l_txn_revenue_tab(i);
                        l_override_quantity := l_unrounded_txn_revenue_tab(i);
                    ELSE
                        l_src_quantity_tab(i):= l_txn_raw_cost_tab(i);
                        l_override_quantity := l_unrounded_txn_raw_cost_tab(i);
                    END IF;
                END IF;
                l_txn_raw_cost_tab(i) := NULL;
                l_txn_brdn_cost_tab(i) := NULL;
                IF l_override_quantity <> 0 THEN
                    l_cost_rate_override_tab(i) := l_unrounded_txn_raw_cost_tab(i) / l_override_quantity;
                    l_b_cost_rate_override_tab(i) := l_unrounded_txn_brdn_cost_tab(i) / l_override_quantity;
                    l_bill_rate_override_tab(i) := l_unrounded_txn_revenue_tab(i) / l_override_quantity;
                ELSE -- Added for IPM
                    l_remove_record_flag_tab(i) := 'Y';
                    l_remove_records_flag := 'Y';
                END IF;
            END LOOP;
        ELSIF l_source_version_type = 'ALL' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'C' THEN
            FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                l_src_quantity_tab(i):= l_txn_brdn_cost_tab(i);
                l_txn_revenue_tab(i) := l_txn_brdn_cost_tab(i);
                l_txn_raw_cost_tab(i) := NULL;
                l_txn_brdn_cost_tab(i) := NULL;
                l_bill_rate_override_tab(i) := 1;
                l_pfc_revenue_tab(i) := l_pfc_brdn_cost_tab(i);
                l_pc_revenue_tab(i) := l_pc_brdn_cost_tab(i);
                -- Added for IPM
                IF nvl(l_src_quantity_tab(i),0) = 0 THEN
                    l_remove_record_flag_tab(i) := 'Y';
                    l_remove_records_flag := 'Y';
                END IF;
            END LOOP;
        ELSIF l_source_version_type = 'ALL' AND
              l_target_version_type = 'REVENUE' AND
              l_rev_gen_method = 'E' THEN
            /* This stub is here for completeness in the flow of the generation logic.
             * We do nothing here because the wrapper API does not call this procedure
             * in the case of Event-based revenue generation. Hence, we should never
             * arrive here in a valid code path. */
            l_dummy := 1;
        END IF;
    END IF; -- context-based generation logic

    /* ER 4376722: When the Target is a Revenue-only Forecast, we
     * generate quantity but not revenue for rate-based resources of
     * non-billable tasks. To do this, null out revenue amounts and
     * rate overrides for rate-based resources of non-billable tasks.
     * Note that we handle the case of non-rated-based resources
     * of non-billable tasks earlier in the code. */

    IF l_target_version_type = 'REVENUE' AND
       l_calling_context = lc_ForecastGeneration THEN
        FOR i IN 1..l_tgt_res_asg_id_tab.count LOOP
            IF l_billable_flag_tab(i) = 'N' AND
               l_tgt_rate_based_flag_tab(i) = 'Y' THEN
                l_txn_revenue_tab(i) := null;
                l_pfc_revenue_tab(i) := null;
                l_pc_revenue_tab(i)  := null;
                l_bill_rate_override_tab(i) := NULL;
                l_markup_percent_tab(i) := NULL; -- Added for Bug 5166047
                -- null out cost rate overrides in case of Work-based revenue
                l_cost_rate_override_tab(i) := NULL;
                l_b_cost_rate_override_tab(i) := NULL;
            END IF;
        END LOOP;
    END IF; -- ER 4376722 billability logic for REVENUE Forecast

    /* ER 4376722: When the Target is a Cost and Revenue together
     * version, we do not generate revenue for non-billable tasks.
     * To do this, simply null out revenue amounts for non-billable
     * tasks. The result is that revenue amounts for non-billable
     * tasks will not be written to the budget lines. */

    IF l_target_version_type = 'ALL' THEN
        -- Null out revenue amounts for non-billable tasks
        FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
            IF l_billable_flag_tab(i) = 'N' THEN
                l_txn_revenue_tab(i) := null;
                l_pfc_revenue_tab(i) := null;
                l_pc_revenue_tab(i)  := null;
                l_bill_rate_override_tab(i) := null;
                l_markup_percent_tab(i) := null; -- Added for Bug 5166047

                -- IPM: If the current txn has only revenue amounts,
                -- then process using the rules for revenue-only versions.
                IF ( l_calling_context = lc_BudgetGeneration AND
                     nvl(l_txn_raw_cost_tab(i),0) = 0 ) OR
                   ( l_calling_context = lc_ForecastGeneration AND
                     nvl(l_txn_raw_cost_tab(i),0) = 0 AND
                     l_tgt_rate_based_flag_tab(i) = 'N' ) THEN
                    -- Skip over the record in this case so that
                    -- cost is not generated from a revenue amount.
                    l_remove_record_flag_tab(i) := 'Y';
                    l_remove_records_flag := 'Y';
                END IF; -- revenue-only txn logic
            END IF;
        END LOOP;
    END IF; -- ER 4376722 billability logic for ALL versions


    -- Added in IPM. If there are any pl/sql table records that need to
    -- be removed, use a separate set of _tmp_ tables to filter them out.

     IF l_remove_records_flag = 'Y' THEN

        -- 0. Clear out any data in the _tmp_ tables.
	l_tmp_tgt_res_asg_id_tab.delete;
	l_tmp_tgt_rate_based_flag_tab.delete;
	l_tmp_start_date_tab.delete;
	l_tmp_end_date_tab.delete;
	l_tmp_periiod_name_tab.delete;
	l_tmp_txn_currency_code_tab.delete;
	l_tmp_src_quantity_tab.delete;
	l_tmp_txn_raw_cost_tab.delete;
	l_tmp_txn_brdn_cost_tab.delete;
	l_tmp_txn_revenue_tab.delete;
	l_tmp_unr_txn_raw_cost_tab.delete;
	l_tmp_unr_txn_brdn_cost_tab.delete;
	l_tmp_unr_txn_revenue_tab.delete;
	l_tmp_pc_raw_cost_tab.delete;
	l_tmp_pc_brdn_cost_tab.delete;
	l_tmp_pc_revenue_tab.delete;
	l_tmp_pfc_raw_cost_tab.delete;
	l_tmp_pfc_brdn_cost_tab.delete;
	l_tmp_pfc_revenue_tab.delete;
	l_tmp_cost_rate_override_tab.delete;
	l_tmp_bcost_rate_override_tab.delete;
	l_tmp_bill_rate_override_tab.delete;
	l_tmp_billable_flag_tab.delete;
	l_tmp_markup_percent_tab.delete; -- Added for Bug 5166047

        -- 1. Copy records into _tmp_ tables
        l_tmp_index := 0;
        FOR i IN 1..l_tgt_res_asg_id_tab.count LOOP
            IF l_remove_record_flag_tab(i) <> 'Y' THEN

                l_tmp_index := l_tmp_index + 1;
                l_tmp_tgt_res_asg_id_tab(l_tmp_index)      := l_tgt_res_asg_id_tab(i);
                l_tmp_tgt_rate_based_flag_tab(l_tmp_index) := l_tgt_rate_based_flag_tab(i);
                l_tmp_start_date_tab(l_tmp_index)          := l_start_date_tab(i);
                l_tmp_end_date_tab(l_tmp_index)            := l_end_date_tab(i);
                l_tmp_periiod_name_tab(l_tmp_index)        := l_periiod_name_tab(i);
                l_tmp_txn_currency_code_tab(l_tmp_index)   := l_txn_currency_code_tab(i);
                l_tmp_src_quantity_tab(l_tmp_index)        := l_src_quantity_tab(i);
                l_tmp_txn_raw_cost_tab(l_tmp_index)        := l_txn_raw_cost_tab(i);
                l_tmp_txn_brdn_cost_tab(l_tmp_index)       := l_txn_brdn_cost_tab(i);
                l_tmp_txn_revenue_tab(l_tmp_index)         := l_txn_revenue_tab(i);
                l_tmp_unr_txn_raw_cost_tab(l_tmp_index)    := l_unrounded_txn_raw_cost_tab(i);
                l_tmp_unr_txn_brdn_cost_tab(l_tmp_index)   := l_unrounded_txn_brdn_cost_tab(i);
                l_tmp_unr_txn_revenue_tab(l_tmp_index)     := l_unrounded_txn_revenue_tab(i);
                l_tmp_pc_raw_cost_tab(l_tmp_index)         := l_pc_raw_cost_tab(i);
                l_tmp_pc_brdn_cost_tab(l_tmp_index)        := l_pc_brdn_cost_tab(i);
                l_tmp_pc_revenue_tab(l_tmp_index)          := l_pc_revenue_tab(i);
                l_tmp_pfc_raw_cost_tab(l_tmp_index)        := l_pfc_raw_cost_tab(i);
                l_tmp_pfc_brdn_cost_tab(l_tmp_index)       := l_pfc_brdn_cost_tab(i);
                l_tmp_pfc_revenue_tab(l_tmp_index)         := l_pfc_revenue_tab(i);
                l_tmp_cost_rate_override_tab(l_tmp_index)  := l_cost_rate_override_tab(i);
                l_tmp_bcost_rate_override_tab(l_tmp_index) := l_b_cost_rate_override_tab(i);
                l_tmp_bill_rate_override_tab(l_tmp_index)  := l_bill_rate_override_tab(i);
                l_tmp_billable_flag_tab(l_tmp_index)       := l_billable_flag_tab(i);
                l_tmp_markup_percent_tab(l_tmp_index)      := l_markup_percent_tab(i); -- Added for Bug 5166047
            END IF;
        END LOOP;

        -- 2. Copy records from _tmp_ tables back to non-temporary tables.
        l_tgt_res_asg_id_tab          := l_tmp_tgt_res_asg_id_tab;
        l_tgt_rate_based_flag_tab     := l_tmp_tgt_rate_based_flag_tab;
        l_start_date_tab              := l_tmp_start_date_tab;
        l_end_date_tab                := l_tmp_end_date_tab;
        l_periiod_name_tab            := l_tmp_periiod_name_tab;
        l_txn_currency_code_tab       := l_tmp_txn_currency_code_tab;
        l_src_quantity_tab            := l_tmp_src_quantity_tab;
        l_txn_raw_cost_tab            := l_tmp_txn_raw_cost_tab;
        l_txn_brdn_cost_tab           := l_tmp_txn_brdn_cost_tab;
        l_txn_revenue_tab             := l_tmp_txn_revenue_tab;
        l_unrounded_txn_raw_cost_tab  := l_tmp_unr_txn_raw_cost_tab;
        l_unrounded_txn_brdn_cost_tab := l_tmp_unr_txn_brdn_cost_tab;
        l_unrounded_txn_revenue_tab   := l_tmp_unr_txn_revenue_tab;
        l_pc_raw_cost_tab             := l_tmp_pc_raw_cost_tab;
        l_pc_brdn_cost_tab            := l_tmp_pc_brdn_cost_tab;
        l_pc_revenue_tab              := l_tmp_pc_revenue_tab;
        l_pfc_raw_cost_tab            := l_tmp_pfc_raw_cost_tab;
        l_pfc_brdn_cost_tab           := l_tmp_pfc_brdn_cost_tab;
        l_pfc_revenue_tab             := l_tmp_pfc_revenue_tab;
        l_cost_rate_override_tab      := l_tmp_cost_rate_override_tab;
        l_b_cost_rate_override_tab    := l_tmp_bcost_rate_override_tab;
        l_bill_rate_override_tab      := l_tmp_bill_rate_override_tab;
        l_billable_flag_tab           := l_tmp_billable_flag_tab;
        l_markup_percent_tab          := l_tmp_markup_percent_tab; -- Added for Bug 5166047

        -- Stop processing if no data remains (ie. all records removed).
        IF l_tgt_res_asg_id_tab.count <= 0 THEN
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.RESET_CURR_FUNCTION;
            END IF;
            RETURN;
        END IF; -- l_tgt_res_asg_id_tab.count <= 0

    END IF; -- IPM record removal logic

  /*********************************************************************
  ER 5726773: Commenting out logic that filters out planning
 	               transaction records with: (total plan quantity <= 0).

    -- Bug #4938603: Adding code to filter out records with
    --  total plan quantity < 0
    -- Sum quantity by (ra_id,currency)
    FOR i IN 1..l_tgt_res_asg_id_tab.count LOOP
        l_ra_id := l_tgt_res_asg_id_tab(i);
        l_currency := l_txn_currency_code_tab(i);
        IF ra_id_tab.EXISTS(l_ra_id) THEN
            IF ra_id_tab(l_ra_id).EXISTS(l_currency) THEN
                -- Add source quantity to running total
                ra_id_tab(l_ra_id)(l_currency) :=
                    ra_id_tab(l_ra_id)(l_currency) + nvl(l_src_quantity_tab(i),0);
            ELSE
                -- Start the running total
                ra_id_tab(l_ra_id)(l_currency) := nvl(l_src_quantity_tab(i),0);
            END IF;
        ELSE -- ra_id_tab(l_ra_id does not exist
            -- Assignment for pl/sql tables is BY VALUE, so it
            -- is okay to reuse new_currency_tab after deletion.
            new_currency_tab.DELETE;
            new_currency_tab(l_currency) := nvl(l_src_quantity_tab(i),0);
            ra_id_tab(l_ra_id) := new_currency_tab;
        END IF;
    END LOOP;

    -- For Forecasts, add total Actual Quantity to total ETC Quantity.
    -- Do a double loop over resource assignments and then currency.
    IF (l_calling_context = lc_ForecastGeneration) THEN
        IF ra_id_tab.count > 0 THEN
            n_index := ra_id_tab.FIRST;
            LOOP
             -- START LOOP BODY (n_index)
                IF ra_id_tab(n_index).count > 0 THEN
                    s_index := ra_id_tab(n_index).FIRST;
                    LOOP
                        -- START LOOP BODY (s_index)
                        OPEN fcst_bdgt_line_actual_qty(n_index,s_index);
                        FETCH fcst_bdgt_line_actual_qty INTO l_init_qty;
                        CLOSE fcst_bdgt_line_actual_qty;
                        ra_id_tab(n_index)(s_index) :=
                            ra_id_tab(n_index)(s_index) + nvl(l_init_qty,0);
                  -- END LOOP BODY (s_index)
                     EXIT WHEN s_index = ra_id_tab(n_index).LAST;
                  -- Increment the loop iterator
                        s_index := ra_id_tab(n_index).NEXT(s_index);
                    END LOOP;
                END IF; --IF ra_id_tab(n_index).count > 0 THEN
                -- END LOOP BODY (n_index)
                EXIT WHEN n_index = ra_id_tab.LAST;
                -- Increment the loop iterator
                n_index := ra_id_tab.NEXT(n_index);
            END LOOP;
        END IF; --IF ra_id_tab.count > 0 THEN
    END IF; --IF (l_calling_context = lc_ForecastGeneration) THEN

    -- 0. Clear out any data in the _tmp_ tables.
    l_tmp_tgt_res_asg_id_tab.delete;
    l_tmp_tgt_rate_based_flag_tab.delete;
    l_tmp_start_date_tab.delete;
    l_tmp_end_date_tab.delete;
    l_tmp_periiod_name_tab.delete;
    l_tmp_txn_currency_code_tab.delete;
    l_tmp_src_quantity_tab.delete;
    l_tmp_txn_raw_cost_tab.delete;
    l_tmp_txn_brdn_cost_tab.delete;
    l_tmp_txn_revenue_tab.delete;
    l_tmp_unr_txn_raw_cost_tab.delete;
    l_tmp_unr_txn_brdn_cost_tab.delete;
    l_tmp_unr_txn_revenue_tab.delete;
    l_tmp_pc_raw_cost_tab.delete;
    l_tmp_pc_brdn_cost_tab.delete;
    l_tmp_pc_revenue_tab.delete;
    l_tmp_pfc_raw_cost_tab.delete;
    l_tmp_pfc_brdn_cost_tab.delete;
    l_tmp_pfc_revenue_tab.delete;
    l_tmp_cost_rate_override_tab.delete;
    l_tmp_bcost_rate_override_tab.delete;
    l_tmp_bill_rate_override_tab.delete;
    l_tmp_billable_flag_tab.delete;
    l_tmp_markup_percent_tab.delete; -- Added for Bug 5166047

    l_tmp_index := 0;
    -- 1. Copy records into _tmp_ tables for
    FOR i IN 1..l_tgt_res_asg_id_tab.count LOOP

        IF ra_id_tab.EXISTS(l_tgt_res_asg_id_tab(i)) AND
           ra_id_tab(l_tgt_res_asg_id_tab(i)).EXISTS(l_txn_currency_code_tab(i)) AND
           ra_id_tab(l_tgt_res_asg_id_tab(i))(l_txn_currency_code_tab(i)) > 0 THEN

            l_tmp_index := l_tmp_index + 1;
            l_tmp_tgt_res_asg_id_tab(l_tmp_index)      := l_tgt_res_asg_id_tab(i);
            l_tmp_tgt_rate_based_flag_tab(l_tmp_index) := l_tgt_rate_based_flag_tab(i);
            l_tmp_start_date_tab(l_tmp_index)          := l_start_date_tab(i);
            l_tmp_end_date_tab(l_tmp_index)            := l_end_date_tab(i);
            l_tmp_periiod_name_tab(l_tmp_index)        := l_periiod_name_tab(i);
            l_tmp_txn_currency_code_tab(l_tmp_index)   := l_txn_currency_code_tab(i);
            l_tmp_src_quantity_tab(l_tmp_index)        := l_src_quantity_tab(i);
            l_tmp_txn_raw_cost_tab(l_tmp_index)        := l_txn_raw_cost_tab(i);
            l_tmp_txn_brdn_cost_tab(l_tmp_index)       := l_txn_brdn_cost_tab(i);
            l_tmp_txn_revenue_tab(l_tmp_index)         := l_txn_revenue_tab(i);
            l_tmp_unr_txn_raw_cost_tab(l_tmp_index)    := l_unrounded_txn_raw_cost_tab(i);
            l_tmp_unr_txn_brdn_cost_tab(l_tmp_index)   := l_unrounded_txn_brdn_cost_tab(i);
            l_tmp_unr_txn_revenue_tab(l_tmp_index)     := l_unrounded_txn_revenue_tab(i);
            l_tmp_pc_raw_cost_tab(l_tmp_index)         := l_pc_raw_cost_tab(i);
            l_tmp_pc_brdn_cost_tab(l_tmp_index)        := l_pc_brdn_cost_tab(i);
            l_tmp_pc_revenue_tab(l_tmp_index)          := l_pc_revenue_tab(i);
            l_tmp_pfc_raw_cost_tab(l_tmp_index)        := l_pfc_raw_cost_tab(i);
            l_tmp_pfc_brdn_cost_tab(l_tmp_index)       := l_pfc_brdn_cost_tab(i);
            l_tmp_pfc_revenue_tab(l_tmp_index)         := l_pfc_revenue_tab(i);
            l_tmp_cost_rate_override_tab(l_tmp_index)  := l_cost_rate_override_tab(i);
            l_tmp_bcost_rate_override_tab(l_tmp_index) := l_b_cost_rate_override_tab(i);
            l_tmp_bill_rate_override_tab(l_tmp_index)  := l_bill_rate_override_tab(i);
            l_tmp_billable_flag_tab(l_tmp_index)       := l_billable_flag_tab(i);
            l_tmp_markup_percent_tab(l_tmp_index)      := l_markup_percent_tab(i); -- Added for Bug 5166047
        END IF;
    END LOOP;

     -- 2. Copy records from _tmp_ tables back to non-temporary tables.
    l_tgt_res_asg_id_tab          := l_tmp_tgt_res_asg_id_tab;
    l_tgt_rate_based_flag_tab     := l_tmp_tgt_rate_based_flag_tab;
    l_start_date_tab              := l_tmp_start_date_tab;
    l_end_date_tab                := l_tmp_end_date_tab;
    l_periiod_name_tab            := l_tmp_periiod_name_tab;
    l_txn_currency_code_tab       := l_tmp_txn_currency_code_tab;
    l_src_quantity_tab            := l_tmp_src_quantity_tab;
    l_txn_raw_cost_tab            := l_tmp_txn_raw_cost_tab;
    l_txn_brdn_cost_tab           := l_tmp_txn_brdn_cost_tab;
    l_txn_revenue_tab             := l_tmp_txn_revenue_tab;
    l_unrounded_txn_raw_cost_tab  := l_tmp_unr_txn_raw_cost_tab;
    l_unrounded_txn_brdn_cost_tab := l_tmp_unr_txn_brdn_cost_tab;
    l_unrounded_txn_revenue_tab   := l_tmp_unr_txn_revenue_tab;
    l_pc_raw_cost_tab             := l_tmp_pc_raw_cost_tab;
    l_pc_brdn_cost_tab            := l_tmp_pc_brdn_cost_tab;
    l_pc_revenue_tab              := l_tmp_pc_revenue_tab;
    l_pfc_raw_cost_tab            := l_tmp_pfc_raw_cost_tab;
    l_pfc_brdn_cost_tab           := l_tmp_pfc_brdn_cost_tab;
    l_pfc_revenue_tab             := l_tmp_pfc_revenue_tab;
    l_cost_rate_override_tab      := l_tmp_cost_rate_override_tab;
    l_b_cost_rate_override_tab    := l_tmp_bcost_rate_override_tab;
    l_bill_rate_override_tab      := l_tmp_bill_rate_override_tab;
    l_billable_flag_tab           := l_tmp_billable_flag_tab;
    l_markup_percent_tab          := l_tmp_markup_percent_tab; -- Added for Bug 5166047

    -- End of code for #4938603

    ER 5726773: End of commented out section.
 *********************************************************************/

    -- ER 4376722: Consolidated update of UOM and rate_based_flag for
    -- cost-based Revenue generation within the GENERATE_WP_BUDGET_AMT
    -- API before any cursor is called. This ensures that the values
    -- in the rate_base_flag pl/sql tables are accurate. Before this
    -- change, an identical update was done in GENERATE_WP_BUDGET_AMT
    -- as well as in this API after cursors were used and generation
    -- logic was performed.

/******************** Commented Out *********************
    IF l_fp_cols_rec_target.x_version_type = 'REVENUE' and l_rev_gen_method = 'C' THEN
        l_res_asg_uom_update_tab.DELETE;
        SELECT DISTINCT txn_resource_assignment_id
        BULK COLLECT INTO l_res_asg_uom_update_tab
        FROM pa_res_list_map_tmp4;

        FORALL i IN 1..l_res_asg_uom_update_tab.count
            UPDATE pa_resource_assignments
            SET unit_of_measure = 'DOLLARS',
                rate_based_flag = 'N'
            WHERE resource_assignment_id = l_res_asg_uom_update_tab(i);
    END IF;
******************** End Commenting **********************/

    -- Bug 3968748: We need to populate the PA_FP_GEN_RATE_TMP table with
    -- burdened cost rates for non-rate-based resources for Calculate API
    -- when generating work-based revenue for a Revenue-only target version.

    -- Bug 4216423: We now need to populate PA_FP_GEN_RATE_TMP with cost
    -- rates for both rate-based and non-rate based resources when generating
    -- work-based revenue for a Revenue-only target version.

    /* ER 4376722: Note that we do not need to modify the logic for populating
     * PA_FP_GEN_RATE_TMP here, since we already removed pl/sql table records
     * for non-billable tasks earlier in the code for Revenue-only target versions. */

    -- Bug 4568011: Added REVENUE_BILL_RATE to list of inserted columns.
    -- When the value is non-null, the Calculate API will honor the given
    -- bill rate instead of computing revenue amounts.

    IF l_fp_cols_rec_target.x_version_type = 'REVENUE' AND l_rev_gen_method = 'T' THEN
        DELETE pa_fp_gen_rate_tmp;
        /* For periodic calculation, we should populate the period name. */
        FORALL i IN 1..l_tgt_res_asg_id_tab.count
            INSERT INTO pa_fp_gen_rate_tmp
                   ( TARGET_RES_ASG_ID,
                     TXN_CURRENCY_CODE,
                     PERIOD_NAME,
                     RAW_COST_RATE,
                     BURDENED_COST_RATE,
                     REVENUE_BILL_RATE )            /* Added for Bug 4568011 */
            VALUES ( l_tgt_res_asg_id_tab(i),
                     l_txn_currency_code_tab(i),
                     l_periiod_name_tab(i),
                     l_cost_rate_override_tab(i),
                     l_b_cost_rate_override_tab(i),
                     l_bill_rate_override_tab(i) ); /* Added for Bug 4568011 */
        -- Null out cost rate overrides
        FOR i IN 1..l_tgt_res_asg_id_tab.count LOOP
            l_cost_rate_override_tab(i) := NULL;
            l_b_cost_rate_override_tab(i) := NULL;
        END LOOP;
    END IF;

     /*
     hr_utility.trace('....................');
     hr_utility.trace('??before insert, l_tgt_res_asg_id_tab.count:'||l_tgt_res_asg_id_tab.count);
     for i in 1..l_tgt_res_asg_id_tab.count loop
     IF l_tgt_res_asg_id_tab(i) = 20705 THEN
     hr_utility.trace('==='||i||'==');
     hr_utility.trace('l_tgt_res_asg_id_tab('||i||'):'|| l_tgt_res_asg_id_tab(i));
     hr_utility.trace('l_txn_currency_code_tab('||i||'):'|| l_txn_currency_code_tab(i));
     hr_utility.trace('l_src_quantity_tab('||i||'):'||l_src_quantity_tab(i));
     hr_utility.trace('l_txn_brdn_cost_tab('||i||'):'||l_txn_brdn_cost_tab(i));
     hr_utility.trace('l_txn_revenue_tab('||i||'):'||l_txn_revenue_tab(i));
     END IF;
     end loop;*/
    --dbms_output.put_line('l_tgt_res_asg_id_tab.count:'||l_tgt_res_asg_id_tab.count);

    -- Note that l_tgt_res_asg_id_tab.count should be greater than 0
    -- at this point, since we checked this condition earlier. However,
    -- to be on the safe side, check once more to avoid unecessary work.
    IF l_tgt_res_asg_id_tab.count <= 0 THEN
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RETURN;
    END IF; -- l_tgt_res_asg_id_tab.count <= 0

    /* Bug 4686742: BEGIN CODE FIX */

    -- Bug 4686742: When the Target is a Work-based Revenue-only Forecast,
    -- call the Calculate API in periodic mode instead of Inserting/Updating
    -- the budget lines now and calling the Calculate API at the resource
    -- level later when control returns to the GENERATE_WP_BUDGET_AMT API.

    IF l_calling_context = lc_ForecastGeneration AND
       l_fp_cols_rec_target.x_version_type = 'REVENUE' AND
       l_rev_gen_method = 'T' THEN
        /***** Commented for bug 5325254
        -- According to the VALIDATE_SUPPORT_CASES API (Case 3):
        --    Forecast generation from Workplan and/or Financial Plan when
        --    source is non-time phased is not supported.
        -- This check is not necessary as long as the validation api is
        -- working properly.
        --
        -- IMPORTANT NOTE: If we decide to support this case in the future,
        -- then additional logic (similar to that in GEN_COMMITMENT_AMOUNTS)
        -- will need to be written:
        -- a) Budget line data will need to be Inserted for Target (resource,
        --    txn currency) combinations without any actuals.
        -- b) Budget line quantities, revenues, and end dates will need to be
        --    Updated for Target (resource, txn currency) combinations with
        --    actuals.
        -- c) The Calculate API will need to be called with l_source_context
        --    as 'RESOURCE_ASSIGNMENT' and l_refresh_rates_flag as 'R'.

        IF l_fp_cols_rec_source.x_time_phased_code = 'N' THEN
            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_WP_FP_NON_TIME_PHASED_ERR' );
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
        End of comments for bug 5325254.  *****/

        /* Following logic applies when Target timephase is PA/GL. */

        -- Copy budget line data into Calculate API table parameters
        FOR i IN 1..l_tgt_res_asg_id_tab.count LOOP

            l_raw_cost_rate_tab.EXTEND;
            l_b_cost_rate_tab.EXTEND;
            l_bill_rate_tab.EXTEND;
            l_cal_tgt_res_asg_id_tab.EXTEND;
            l_cal_start_date_tab.EXTEND;
            l_cal_txn_currency_code_tab.EXTEND;
            l_cal_end_date_tab.EXTEND;
            l_cal_src_quantity_tab.EXTEND;
            l_cal_txn_raw_cost_tab.EXTEND;
            l_cal_txn_brdn_cost_tab.EXTEND;
            l_cal_txn_revenue_tab.EXTEND;
            l_cal_cost_rate_override_tab.EXTEND;
            l_cal_bill_rate_override_tab.EXTEND;
            l_cal_b_cost_rate_override_tab.EXTEND;

            l_raw_cost_rate_tab(i)            := Null;
            l_b_cost_rate_tab(i)              := Null;
            l_bill_rate_tab(i)                := Null;
            l_cal_tgt_res_asg_id_tab(i)       := l_tgt_res_asg_id_tab(i);
            l_cal_start_date_tab(i)           := l_start_date_tab(i);
            l_cal_txn_currency_code_tab(i)    := l_txn_currency_code_tab(i);
            l_cal_end_date_tab(i)             := l_end_date_tab(i);
            l_cal_src_quantity_tab(i)         := l_src_quantity_tab(i);
            l_cal_txn_raw_cost_tab(i)         := l_txn_raw_cost_tab(i);
            l_cal_txn_brdn_cost_tab(i)        := l_txn_brdn_cost_tab(i);
            l_cal_txn_revenue_tab(i)          := l_txn_revenue_tab(i);
            l_cal_cost_rate_override_tab(i)   := l_cost_rate_override_tab(i);
            l_cal_bill_rate_override_tab(i)   := l_bill_rate_override_tab(i);
            l_cal_b_cost_rate_override_tab(i) := l_b_cost_rate_override_tab(i);

        END LOOP; -- FOR i IN 1..l_tgt_res_asg_id_tab.count LOOP

        -- Set default values for Calculate API flag parameters
        l_refresh_rates_flag         := 'N';
        l_refresh_conv_rates_flag    := 'N';
        l_spread_required_flag       := 'N';
        l_rollup_required_flag       := 'N';
        l_raTxn_rollup_api_call_flag := 'N'; -- Added for IPM new entity ER

        -- Note that when the source context is Budget Line, Calculate
        -- requires that budget lines do not already exist for the
        -- (resource, currency, period) combinations to be processed.
        -- We do not need to perform a DELETE here since we are only
        -- processing ETC lines, which should not exist at this point.
        l_source_context := 'BUDGET_LINE';

        --Calling the calculate API
        IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                 (p_msg         => 'Before calling
                                   PA_FP_CALC_PLAN_PKG.calculate',
                  p_module_name => l_module_name,
                  p_log_level   => 5);
        END IF;
        PA_FP_CALC_PLAN_PKG.calculate(
                           p_project_id                    => P_PROJECT_ID,
                           p_budget_version_id             => P_TARGET_BV_ID,
                           p_refresh_rates_flag            => l_refresh_rates_flag,
                           p_refresh_conv_rates_flag       => l_refresh_conv_rates_flag,
                           p_spread_required_flag          => l_spread_required_flag,
                           p_rollup_required_flag          => l_rollup_required_flag,
                           p_source_context                => l_source_context,
                           p_resource_assignment_tab       => l_cal_tgt_res_asg_id_tab,
                           p_txn_currency_code_tab         => l_cal_txn_currency_code_tab,
                           p_total_qty_tab                 => l_cal_src_quantity_tab,
                           p_total_raw_cost_tab            => l_cal_txn_raw_cost_tab,
                           p_total_burdened_cost_tab       => l_cal_txn_brdn_cost_tab,
                           p_total_revenue_tab             => l_cal_txn_revenue_tab,
                           p_raw_cost_rate_tab             => l_raw_cost_rate_tab,
                           p_rw_cost_rate_override_tab     => l_cal_cost_rate_override_tab,
                           p_b_cost_rate_tab               => l_b_cost_rate_tab,
                           p_b_cost_rate_override_tab      => l_cal_b_cost_rate_override_tab,
                           p_bill_rate_tab                 => l_bill_rate_tab,
                           p_bill_rate_override_tab        => l_cal_bill_rate_override_tab,
                           p_line_start_date_tab           => l_cal_start_date_tab,
                           p_line_end_date_tab             => l_cal_end_date_tab,
                           p_calling_module                => l_calling_context,
                           p_raTxn_rollup_api_call_flag    => l_raTxn_rollup_api_call_flag, --Added for IPM new entity ER
                           x_return_status                 => x_return_status,
                           x_msg_count                     => x_msg_count,
                           x_msg_data                      => x_msg_data);
        --hr_utility.trace('aft calling calculate api: '||x_return_status);
        IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                 (p_msg         => 'Status after calling
                                  PA_FP_CALC_PLAN_PKG.calculate: '
                                  ||x_return_status,
                  p_module_name => l_module_name,
                  p_log_level   => 5);
        END IF;
        IF x_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RETURN;
    END IF; -- Work-based Revenue Forecast logic

    /* Bug 4686742: END CODE FIX (note: more logic in GENERATE_WP_BUDGET_AMT) */

    -- Bug 5166047: At this point, we have carried around the average
    -- markup percent for each planning txn. And, the markup percent has
    -- been nulled out as needed for compliance with billability logic.
    -- The following conditions are required to honor source markup:
    -- 1. The source/target planning options must match.
    --    This guarantees that there is a 1-to-1 map between source
    --    and target txns, so that the average markup percent is in fact
    --    the actual markup percent.
    -- 2. The target version should have revenue amounts.
    -- 3. The revenue accrual method should be Work.
    --    Markup percent is not used for Cost or Event based revenue.
    -- When the above conditions are NOT met, null out the markup percent.

    IF NOT
     ( l_same_planning_options_flag = 'Y' AND
       l_target_version_type IN ('REVENUE','ALL') AND
       l_rev_gen_method = 'T' ) THEN
        FOR i IN 1..l_tgt_res_asg_id_tab.count LOOP
            l_markup_percent_tab(i) := null;
        END LOOP;
    END IF;

    -- Note for Bug 5166047:
    -- Since the Calculate API is called for Work-based Revenue-only Fcsts,
    -- and this API is only called in forecast generation for Revenue-only
    -- forecasts, the revenue accrual method must be Cost or Event at this point.
    -- Since markup should only be copied when the revenue accrual method is
    -- Work, we do not need to make further changes to the block below.

    IF l_calling_context = lc_ForecastGeneration  AND
       l_fp_cols_rec_target.x_time_phased_code = 'N' THEN

        -- Since bulk inserting the loop index variable i is syntactically
        -- not allowed, we populate an index table. This will give us the
        -- indices for resources that need to be inserted/updated.
        FOR i IN 1..l_tgt_res_asg_id_tab.count LOOP
            l_index_tab(i) := i;
        END LOOP;

        DELETE PA_FP_CALC_AMT_TMP2;
        -- The ETC_PLAN_QUANTITY is used to store the pl/sql table index.
        FORALL i IN 1..l_tgt_res_asg_id_tab.count
            INSERT INTO PA_FP_CALC_AMT_TMP2 (
                ETC_PLAN_QUANTITY,
                RESOURCE_ASSIGNMENT_ID,
                TXN_CURRENCY_CODE )
             VALUES (
                l_index_tab(i),
                l_tgt_res_asg_id_tab(i),
                l_txn_currency_code_tab(i) );

        /* Get indices for budget lines we need to UPDATE */
        SELECT /*+ INDEX(tmp,PA_FP_CALC_AMT_TMP2_N2)*/
               tmp.ETC_PLAN_QUANTITY
        BULK COLLECT INTO l_upd_index_tab
        FROM   pa_budget_lines bl,
               pa_fp_calc_amt_tmp2 tmp
        WHERE  bl.budget_version_id = P_TARGET_BV_ID
        AND    bl.resource_assignment_id = tmp.resource_assignment_id
        AND    bl.txn_currency_code = tmp.txn_currency_code
        ORDER BY tmp.ETC_PLAN_QUANTITY ASC;

        /* Separate budget line data into INSERT and UPDATE tables */

	    -- These indexes are used for the insert/update pl/sql tables
	    l_upd_index := 0;
	    l_ins_index := 0;

	    -- l_tab_index is the index into l_upd_index_tab
	    l_tab_index := 1;
	    -- This is index of the next entry in l_tgt_res_asg_id_tab that is an update
	    l_next_update := 0;

	    FOR i IN 1..l_tgt_res_asg_id_tab.count LOOP
	        IF l_next_update < i AND l_tab_index <= l_upd_index_tab.count THEN
	            l_next_update := l_upd_index_tab(l_tab_index);
	            l_tab_index := l_tab_index + 1;
	        END IF;
	        IF i = l_next_update THEN
	            -- Populate update pl/sql tables
	            l_upd_index := l_upd_index + 1;
	            l_upd_tgt_res_asg_id_tab(l_upd_index)      := l_tgt_res_asg_id_tab(i);
	            l_upd_start_date_tab(l_upd_index)          := l_start_date_tab(i);
	            l_upd_txn_currency_code_tab(l_upd_index)   := l_txn_currency_code_tab(i);
	            l_upd_end_date_tab(l_upd_index)            := l_end_date_tab(i);
	            l_upd_periiod_name_tab(l_upd_index)        := l_periiod_name_tab(i);
	            l_upd_src_quantity_tab(l_upd_index)        := l_src_quantity_tab(i);
	            l_upd_txn_raw_cost_tab(l_upd_index)        := l_txn_raw_cost_tab(i);
	            l_upd_txn_brdn_cost_tab(l_upd_index)       := l_txn_brdn_cost_tab(i);
	            l_upd_txn_revenue_tab(l_upd_index)         := l_txn_revenue_tab(i);
	            l_upd_pfc_revenue_tab(l_upd_index)         := l_pfc_revenue_tab(i);
	            l_upd_pc_revenue_tab(l_upd_index)          := l_pc_revenue_tab(i);
	            l_upd_cost_rate_override_tab(l_upd_index)  := l_cost_rate_override_tab(i);
	            l_upd_bcost_rate_override_tab(l_upd_index) := l_b_cost_rate_override_tab(i);
	            l_upd_bill_rate_override_tab(l_upd_index)  := l_bill_rate_override_tab(i);
	        ELSE
	            -- Populate insert pl/sql tables
	            l_ins_index := l_ins_index + 1;
	            l_ins_tgt_res_asg_id_tab(l_ins_index)      := l_tgt_res_asg_id_tab(i);
	            l_ins_start_date_tab(l_ins_index)          := l_start_date_tab(i);
	            l_ins_txn_currency_code_tab(l_ins_index)   := l_txn_currency_code_tab(i);
	            l_ins_end_date_tab(l_ins_index)            := l_end_date_tab(i);
	            l_ins_periiod_name_tab(l_ins_index)        := l_periiod_name_tab(i);
	            l_ins_src_quantity_tab(l_ins_index)        := l_src_quantity_tab(i);
	            l_ins_txn_raw_cost_tab(l_ins_index)        := l_txn_raw_cost_tab(i);
	            l_ins_txn_brdn_cost_tab(l_ins_index)       := l_txn_brdn_cost_tab(i);
	            l_ins_txn_revenue_tab(l_ins_index)         := l_txn_revenue_tab(i);
	            l_ins_pfc_revenue_tab(l_ins_index)         := l_pfc_revenue_tab(i);
	            l_ins_pc_revenue_tab(l_ins_index)          := l_pc_revenue_tab(i);
	            l_ins_cost_rate_override_tab(l_ins_index)  := l_cost_rate_override_tab(i);
	            l_ins_bcost_rate_override_tab(l_ins_index) := l_b_cost_rate_override_tab(i);
	            l_ins_bill_rate_override_tab(l_ins_index)  := l_bill_rate_override_tab(i);
	        END IF;
	    END LOOP;

        /* Now that we have insert/update tables populated, do Insert */
        FORALL i IN 1..l_ins_tgt_res_asg_id_tab.count
            INSERT INTO PA_BUDGET_LINES (
                BUDGET_LINE_ID,
                BUDGET_VERSION_ID,
                RESOURCE_ASSIGNMENT_ID,
                START_DATE,
                TXN_CURRENCY_CODE,
                TXN_RAW_COST,
                TXN_BURDENED_COST,
                TXN_REVENUE,
                REVENUE,
                PROJECT_REVENUE,
                END_DATE,
                PERIOD_NAME,
                QUANTITY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                PROJECT_CURRENCY_CODE,
                PROJFUNC_CURRENCY_CODE,
                TXN_COST_RATE_OVERRIDE,
                BURDEN_COST_RATE_OVERRIDE,
                TXN_BILL_RATE_OVERRIDE)
             VALUES (
                pa_budget_lines_s.nextval,
                P_TARGET_BV_ID,
                l_ins_tgt_res_asg_id_tab(i),
                l_ins_start_date_tab(i),
                l_ins_txn_currency_code_tab(i),
                l_ins_txn_raw_cost_tab(i),
                l_ins_txn_brdn_cost_tab(i),
                l_ins_txn_revenue_tab(i),
                l_ins_pfc_revenue_tab(i),
                l_ins_pc_revenue_tab(i),
                l_ins_end_date_tab(i),
                l_ins_periiod_name_tab(i),
                l_ins_src_quantity_tab(i),
                sysdate,
                FND_GLOBAL.USER_ID,
                sysdate,
                FND_GLOBAL.USER_ID,
                FND_GLOBAL.LOGIN_ID,
                l_fp_cols_rec_target.X_PROJECT_CURRENCY_CODE,
                l_fp_cols_rec_target.X_PROJFUNC_CURRENCY_CODE,
                l_ins_cost_rate_override_tab(i),
                l_ins_bcost_rate_override_tab(i),
                l_ins_bill_rate_override_tab(i));

        IF l_upd_tgt_res_asg_id_tab.count > 0 THEN
            /* Now, go through the Update logic */

            IF l_rev_gen_method = 'C' AND
               l_fp_cols_rec_target.x_version_type = 'REVENUE' THEN

                -- ER 4376722: Changed the update logic as follows.
                -- Before: Set amount = NVL(actual amount,0) + update amount.
                -- After:  If actual amount is null, then set amount = update amount.
                --         If actual amount is not null, then
                --            set amount = actual amount + NVL(update amount, 0)
                --         The new logic preserves the non-null actual amounts.
                -- This change is necessary in case update revenue is Null. Using the
                -- old logic, we would set revenue to NVL(actual revenue,0) + Null,
                -- which is just Null. In other words, the actual revenue would be lost.
                -- Using the new logic, we would set revenue to actual revenue +
                -- NVL(NULL,0) = actual revenue.
                --
                -- Also, modified range of iteration to use l_upd_tgt_res_asg_id_tab.count
                -- instead of l_ins_tgt_res_asg_id_tab.count.

                -- Add Actuals to Plan columns since Calculate API not called in this flow.
                FORALL i IN 1..l_upd_tgt_res_asg_id_tab.count
                    UPDATE PA_BUDGET_LINES
                    SET    TXN_RAW_COST      =
                               DECODE(TXN_INIT_RAW_COST, null, l_upd_txn_raw_cost_tab(i),
                                      TXN_INIT_RAW_COST + NVL(l_upd_txn_raw_cost_tab(i),0)),
                           TXN_BURDENED_COST =
                               DECODE(TXN_INIT_BURDENED_COST, null, l_upd_txn_brdn_cost_tab(i),
                                      TXN_INIT_BURDENED_COST + NVL(l_upd_txn_brdn_cost_tab(i),0)),
                           TXN_REVENUE       =
				   DECODE(TXN_INIT_REVENUE, null, l_upd_txn_revenue_tab(i),
				          TXN_INIT_REVENUE + NVL(l_upd_txn_revenue_tab(i),0)),
                           REVENUE           =
				   DECODE(INIT_REVENUE, null, l_upd_pfc_revenue_tab(i),
				          INIT_REVENUE + NVL(l_upd_pfc_revenue_tab(i),0)),
                           PROJECT_REVENUE   =
				   DECODE(PROJECT_INIT_REVENUE, null, l_upd_pc_revenue_tab(i),
				          PROJECT_INIT_REVENUE + NVL(l_upd_pc_revenue_tab(i),0)),
                           QUANTITY          =
                               DECODE(INIT_QUANTITY, null, l_upd_src_quantity_tab(i),
                                      INIT_QUANTITY + NVL(l_upd_src_quantity_tab(i),0)),
                           START_DATE        = l_upd_start_date_tab(i),
                           END_DATE          = l_upd_end_date_tab(i),
                           PERIOD_NAME       = l_upd_periiod_name_tab(i),
                           LAST_UPDATE_DATE  = sysdate,
                           LAST_UPDATED_BY   = FND_GLOBAL.USER_ID,
                           LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
                           TXN_COST_RATE_OVERRIDE    = l_upd_cost_rate_override_tab(i),
                           BURDEN_COST_RATE_OVERRIDE = l_upd_bcost_rate_override_tab(i),
                           TXN_BILL_RATE_OVERRIDE    = l_upd_bill_rate_override_tab(i)
                     WHERE budget_version_id = P_TARGET_BV_ID
                     AND   resource_assignment_id = l_upd_tgt_res_asg_id_tab(i)
                     AND   txn_currency_code = l_upd_txn_currency_code_tab(i);
            ELSE
                -- ER 4376722: Modified range of iteration to use l_upd_tgt_res_asg_id_tab.count
                -- instead of l_ins_tgt_res_asg_id_tab.count.

                -- Set Plan columns to source plan amounts; Calculate API called in this flow.
                FORALL i IN 1..l_upd_tgt_res_asg_id_tab.count
                    UPDATE PA_BUDGET_LINES
                    SET    TXN_RAW_COST      = l_upd_txn_raw_cost_tab(i),
                           TXN_BURDENED_COST = l_upd_txn_brdn_cost_tab(i),
                           TXN_REVENUE       = l_upd_txn_revenue_tab(i),
                           REVENUE           = l_upd_pfc_revenue_tab(i),
                           PROJECT_REVENUE   = l_upd_pc_revenue_tab(i),
                           QUANTITY          = l_upd_src_quantity_tab(i),
                           START_DATE        = l_upd_start_date_tab(i),
                           END_DATE          = l_upd_end_date_tab(i),
                           PERIOD_NAME       = l_upd_periiod_name_tab(i),
                           LAST_UPDATE_DATE  = sysdate,
                           LAST_UPDATED_BY   = FND_GLOBAL.USER_ID,
                           LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
                           TXN_COST_RATE_OVERRIDE    = l_upd_cost_rate_override_tab(i),
                           BURDEN_COST_RATE_OVERRIDE = l_upd_bcost_rate_override_tab(i),
                           TXN_BILL_RATE_OVERRIDE    = l_upd_bill_rate_override_tab(i)
                     WHERE budget_version_id = P_TARGET_BV_ID
                     AND   resource_assignment_id = l_upd_tgt_res_asg_id_tab(i)
                     AND   txn_currency_code = l_upd_txn_currency_code_tab(i);
            END IF; -- Cost-based Revenue check
        END IF; -- Update logic
    ELSE
        FORALL i IN l_tgt_res_asg_id_tab.FIRST..l_tgt_res_asg_id_tab.LAST
            INSERT INTO PA_BUDGET_LINES (
                BUDGET_LINE_ID,
                BUDGET_VERSION_ID,
                RESOURCE_ASSIGNMENT_ID,
                START_DATE,
                TXN_CURRENCY_CODE,
                TXN_RAW_COST,
                TXN_BURDENED_COST,
                TXN_REVENUE,
                REVENUE,
                PROJECT_REVENUE,
                END_DATE,
                PERIOD_NAME,
                QUANTITY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                PROJECT_CURRENCY_CODE,
                PROJFUNC_CURRENCY_CODE,
                TXN_COST_RATE_OVERRIDE,
                BURDEN_COST_RATE_OVERRIDE,
                TXN_BILL_RATE_OVERRIDE,
                TXN_MARKUP_PERCENT )        /* Added for Bug 5166047 */
             VALUES (
                pa_budget_lines_s.nextval,
                P_TARGET_BV_ID,
                l_tgt_res_asg_id_tab(i),
                l_start_date_tab(i),
                l_txn_currency_code_tab(i),
                l_txn_raw_cost_tab(i),
                l_txn_brdn_cost_tab(i),
                l_txn_revenue_tab(i),
                l_pfc_revenue_tab(i),
                l_pc_revenue_tab(i),
                l_end_date_tab(i),
                l_periiod_name_tab(i),
                l_src_quantity_tab(i),
                sysdate,
                FND_GLOBAL.USER_ID,
                sysdate,
                FND_GLOBAL.USER_ID,
                FND_GLOBAL.LOGIN_ID,
                l_fp_cols_rec_target.X_PROJECT_CURRENCY_CODE,
                l_fp_cols_rec_target.X_PROJFUNC_CURRENCY_CODE,
                l_cost_rate_override_tab(i),
                l_b_cost_rate_override_tab(i),
                '', /* bug 7693017 */
                l_markup_percent_tab(i));   /* Added for Bug 5166047 */
        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_msg         => 'After inserting into target budget lines',
                  p_module_name => l_module_name,
                  p_log_level   => 5 );
        END IF;
    END IF; -- (Forecast + None timephase) check

    -- IPM: New Entity ER ------------------------------------------
    -- Overview:
    -- The maintenance api (maintain_data) needs to be called to
    -- Rollup budget line amounts. This is required since budget
    -- lines are manually created before calling the Calculate API,
    -- which needs the rolled up amounts for its processing.
    -- This helps to avoid doubling of budget generation amounts
    -- when the source/target timephase codes are equal.

    IF l_calling_context = lc_BudgetGeneration THEN
        l_calling_module := 'BUDGET_GENERATION';
    ELSIF l_calling_context = lc_ForecastGeneration THEN
        l_calling_module := 'FORECAST_GENERATION';
    END IF;

    DELETE pa_resource_asgn_curr_tmp;

    INSERT INTO pa_resource_asgn_curr_tmp
        ( resource_assignment_id,
          txn_currency_code,
          txn_raw_cost_rate_override,
          txn_burden_cost_rate_override,
          txn_bill_rate_override )
    SELECT DISTINCT
           bl.resource_assignment_id,
           bl.txn_currency_code,
           rbc.txn_raw_cost_rate_override,
           rbc.txn_burden_cost_rate_override,
           rbc.txn_bill_rate_override
    FROM   pa_resource_assignments ra,
           pa_budget_lines bl,
           pa_resource_asgn_curr rbc,
           pa_res_list_map_tmp4 tmp4
    WHERE  ra.budget_version_id = p_target_bv_id
    AND    ra.project_id = p_project_id
    AND    ra.resource_assignment_id = tmp4.txn_resource_assignment_id
    AND    bl.resource_assignment_id = ra.resource_assignment_id
    AND    bl.resource_assignment_id = rbc.resource_assignment_id (+)
    AND    bl.txn_currency_code = rbc.txn_currency_code (+);

    -- Call the maintenance api in ROLLUP mode
    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_MSG                   => 'Before calling PA_RES_ASG_CURRENCY_PUB.' ||
                                       'MAINTAIN_DATA',
          --P_CALLED_MODE           => p_called_mode,
            P_MODULE_NAME           => l_module_name);
    END IF;
    PA_RES_ASG_CURRENCY_PUB.MAINTAIN_DATA
          ( P_FP_COLS_REC           => l_fp_cols_rec_target,
            P_CALLING_MODULE        => l_calling_module,
            P_VERSION_LEVEL_FLAG    => 'N',
            P_ROLLUP_FLAG           => 'Y',
          --P_CALLED_MODE           => p_called_mode,
            X_RETURN_STATUS         => x_return_status,
            X_MSG_COUNT             => x_msg_count,
            X_MSG_DATA              => x_msg_data );
    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_MSG                   => 'After calling PA_RES_ASG_CURRENCY_PUB.' ||
                                       'MAINTAIN_DATA: '||x_return_status,
          --P_CALLED_MODE           => p_called_mode,
            P_MODULE_NAME           => l_module_name);
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;
    -- END OF IPM: New Entity ER ------------------------------------------

    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.RESET_CURR_FUNCTION;
    END IF;

 EXCEPTION
     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count = 1 THEN
            PA_INTERFACE_UTILS_PUB.get_messages
                ( p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
            x_msg_data := l_data;
            x_msg_count := l_msg_count;
        ELSE
            x_msg_count := l_msg_count;
        END IF;

        ROLLBACK;

        x_return_status := FND_API.G_RET_STS_ERROR;
        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_msg         => 'Invalid Arguments Passed',
                  p_module_name => l_module_name,
                  p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE;
    WHEN OTHERS THEN
        rollback;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(sqlerrm,1,240);
        FND_MSG_PUB.add_exc_msg
            ( p_pkg_name        => 'PA_FP_WP_GEN_BUDGET_AMT_PUB',
              p_procedure_name  => 'MAINTAIN_BUDGET_LINES',
              p_error_text      => substr(sqlerrm,1,240) );

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                  p_module_name => l_module_name,
                  p_log_level   => 5 );
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END MAINTAIN_BUDGET_LINES;


/**
 * This procedure returns the flag parameters required by the Calculate API.
 * The flags are returned as a single string, x_calculate_api_code, which must
 * be parsed to retrieve individual flag values. The string is layed out as
 *    x_calculate_api_code = 'ABCD'
 * where
 *    A = x_refresh_rates_flag
 *    B = x_refresh_conv_rates_flag
 *    C = x_spread_required_flag
 *    D = x_conv_rates_required_flag
 * Thus, to retrieve the refresh rates flag, for example, use the expression
 *    l_refresh_rates_flag := SUBSTR(x_calculate_api_code,1,1);
 * and to retrieve the spread required flag, use the expression
 *    l_spread_required_flag := SUBSTR(x_calculate_api_code,3,1);
 * Note that each flag has value either 'Y' or 'N'.
 * Lastly, this description should be updated any time the layout of
 * x_calculate_api_code is modified.
 */
PROCEDURE GET_CALC_API_FLAG_PARAMS
   (P_PROJECT_ID                   IN           PA_PROJECTS_ALL.PROJECT_ID%TYPE,
    P_FP_COLS_REC_SOURCE           IN           PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
    P_FP_COLS_REC_TARGET           IN           PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
    P_CALLING_CONTEXT              IN           VARCHAR2,
    X_CALCULATE_API_CODE           OUT NOCOPY   VARCHAR2,
    X_RETURN_STATUS                OUT NOCOPY   VARCHAR2,
    X_MSG_COUNT                    OUT NOCOPY   NUMBER,
    X_MSG_DATA                     OUT NOCOPY   VARCHAR2)
IS
    l_module_name VARCHAR2(100) := 'PA.PLSQL.PA_FP_WP_GEN_BUDGET_AMT_PUB.'
                                   || 'GET_CALC_API_FLAG_PARAMS';

    l_uncategorized_flag           PA_RESOURCE_LISTS_ALL_BG.UNCATEGORIZED_FLAG%TYPE;
    l_wp_track_cost_flag           VARCHAR2(1);

    /* Time-phase determines if budget lines have been populated by generation code */
    l_same_time_phase_flag   VARCHAR2(1);

    /* Source Code constants */
    lc_WorkPlanSrcCode             CONSTANT PA_PROJ_FP_OPTIONS.GEN_COST_SRC_CODE%TYPE
                                       := 'WORKPLAN_RESOURCES';
    lc_FinancialPlanSrcCode        CONSTANT PA_PROJ_FP_OPTIONS.GEN_COST_SRC_CODE%TYPE
                                       := 'FINANCIAL_PLAN';

    /* String constants for valid Calling Context values */
    lc_BudgetGeneration            CONSTANT VARCHAR2(30) := 'BUDGET_GENERATION';
    lc_ForecastGeneration          CONSTANT VARCHAR2(30) := 'FORECAST_GENERATION';

    l_gen_src_code                 PA_PROJ_FP_OPTIONS.GEN_COST_SRC_CODE%TYPE;
    l_source_version_type          PA_BUDGET_VERSIONS.VERSION_TYPE%TYPE;
    l_target_version_type          PA_BUDGET_VERSIONS.VERSION_TYPE%TYPE;
    l_rev_gen_method               VARCHAR2(1);

    /* Local Calculate API flag parameters */
    l_refresh_rates_flag           VARCHAR2(1);
    l_refresh_conv_rates_flag      VARCHAR2(1);
    l_spread_required_flag         VARCHAR2(1);
    l_conv_rates_required_flag     VARCHAR2(1);

    l_count                        NUMBER;
    l_msg_count                    NUMBER;
    l_data                         VARCHAR2(1000);
    l_msg_data                     VARCHAR2(1000);
    l_msg_index_out                NUMBER;
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;

    IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.SET_CURR_FUNCTION
            ( p_function   => 'GET_CALC_API_FLAG_PARAMS',
              p_debug_mode => p_pa_debug_mode );
    END IF;

    /* Check that the input parameters are not null */
    IF p_project_id IS NULL THEN
        PA_UTILS.ADD_MESSAGE
            ( p_app_short_name => 'PA',
              p_msg_name       => 'PA_FP_INV_PARAM_PASSED' );
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    /* Initialize local variables */
    l_rev_gen_method := nvl(p_fp_cols_rec_target.x_revenue_derivation_method,PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(p_project_id)); --Bug 5462471
    l_source_version_type := p_fp_cols_rec_source.x_version_type;
    l_target_version_type := p_fp_cols_rec_target.x_version_type;

    -- Bug 5705549: When l_rev_gen_method is null, only raise an error if the
    -- target version has revenue (i.e. version type is 'ALL' or 'REVENUE').
    IF l_source_version_type IS NULL OR
       l_target_version_type IS NULL OR
      (l_rev_gen_method IS NULL AND
       l_target_version_type IN ('ALL','REVENUE')) THEN
        PA_UTILS.ADD_MESSAGE
            ( p_app_short_name => 'PA',
              p_msg_name       => 'PA_FP_INV_PARAM_PASSED' );
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    l_wp_track_cost_flag :=
        NVL( PA_FP_WP_GEN_AMT_UTILS.GET_WP_TRACK_COST_AMT_FLAG(p_project_id), 'N' );

    IF p_calling_context = lc_BudgetGeneration THEN
        l_gen_src_code := p_fp_cols_rec_target.x_gen_src_code;
    ELSIF  p_calling_context = lc_ForecastGeneration THEN
        l_gen_src_code := p_fp_cols_rec_target.x_gen_etc_src_code;
    END IF;

    /* Set the same time-phase flag */
    IF p_fp_cols_rec_source.x_time_phased_code =
       p_fp_cols_rec_target.x_time_phased_code THEN
        l_same_time_phase_flag := 'Y';
    ELSE
        l_same_time_phase_flag := 'N';
    END IF;

    /* Initialize Calculate API parameter flags.
     * Defaults are chosen to maximize the number of cases covered by default. */
    l_refresh_rates_flag := 'N';
    l_refresh_conv_rates_flag := 'N';
    l_spread_required_flag := 'N';
    l_conv_rates_required_flag := 'Y';

    IF l_same_time_phase_flag = 'N' THEN
        l_spread_required_flag := 'Y';
    END IF;

    IF l_wp_track_cost_flag = 'N' AND
       l_gen_src_code = lc_WorkPlanSrcCode AND
       l_same_time_phase_flag = 'Y' THEN
        l_refresh_rates_flag := 'Y';
    END IF;

    /* Scenarios with non-default parameter values */
    IF l_gen_src_code = lc_FinancialPlanSrcCode OR
       ( l_wp_track_cost_flag = 'Y' AND
         l_gen_src_code = lc_WorkPlanSrcCode ) THEN
        IF l_same_time_phase_flag = 'Y' THEN
            IF l_source_version_type = 'COST' AND
               l_target_version_type = 'REVENUE' AND
               l_rev_gen_method = 'T' THEN
                l_refresh_rates_flag := 'Y';
            ELSIF l_source_version_type = 'COST' AND
                  l_target_version_type = 'ALL' AND
                  l_rev_gen_method = 'T' THEN
                l_refresh_rates_flag := 'R';
            ELSIF l_source_version_type = 'REVENUE' AND
                  l_target_version_type = 'COST' THEN
                  /* l_rev_gen_method = 'T' THEN */ -- commented out for Bug 5705549
                l_refresh_rates_flag := 'Y';
            ELSIF l_source_version_type = 'REVENUE' AND
                  l_target_version_type = 'ALL' AND
                  l_rev_gen_method = 'T' THEN
                l_refresh_rates_flag := 'C';
            END IF;
        ELSE
            -- Bug 4024983: The partial refresh flag value R (Refresh revenue
            -- amt only) and C (Refresh cost amt only) should be used only when
            -- the budget lines are created by the generation process. When
            -- budget lines have not be created, we can pass the spread flag
            -- as 'Y' and the refresh rates flag as 'N'.
            IF l_source_version_type = 'COST' AND
               l_target_version_type = 'ALL' AND
               l_rev_gen_method = 'T' THEN
                l_refresh_rates_flag := 'N'; --'R';
            ELSIF l_source_version_type = 'REVENUE' AND
                  l_target_version_type = 'ALL' AND
                  l_rev_gen_method = 'T' THEN
                l_refresh_rates_flag := 'N'; --'C';
            END IF;
        END IF; -- l_same_time_phase_flag
    ELSIF ( l_wp_track_cost_flag = 'N' AND
            l_gen_src_code = lc_WorkPlanSrcCode ) THEN
        IF l_same_time_phase_flag = 'Y' THEN
            IF l_source_version_type = 'COST' AND
               l_target_version_type = 'ALL' AND
               l_rev_gen_method = 'C' THEN
                l_refresh_rates_flag := 'C';
            ELSIF l_source_version_type = 'COST' AND
                  l_target_version_type = 'ALL' AND
                  l_rev_gen_method = 'E' THEN
                l_refresh_rates_flag := 'C';
            END IF;
        ELSE
            IF l_source_version_type = 'COST' AND
               l_target_version_type = 'ALL' AND
               l_rev_gen_method = 'C' THEN
                l_refresh_rates_flag := 'N'; --'C';
            ELSIF l_source_version_type = 'COST' AND
                  l_target_version_type = 'ALL' AND
                  l_rev_gen_method = 'E' THEN
                l_refresh_rates_flag := 'N'; --'C';
           END IF;
        END IF; -- l_same_time_phase_flag
    END IF; -- l_wp_track_cost_flag

    /* The order in which the parameters are concatenated is important.
     * Reference the description at the top of this procedure for details.
     * None of the flags should be NULL, since that would alter the layout
     * of the return code. */
    x_calculate_api_code := l_refresh_rates_flag
                            || l_refresh_conv_rates_flag
                            || l_spread_required_flag
                            || l_conv_rates_required_flag;
   /* dbms_output.put_line(' l_refresh_rates_flag:' || l_refresh_rates_flag );
   dbms_output.put_line(' l_refresh_conv_rates_flag:' || l_refresh_conv_rates_flag );
   dbms_output.put_line(' l_spread_required_flag:' || l_spread_required_flag );
   dbms_output.put_line(' l_conv_rates_required_flag:' || l_conv_rates_required_flag );
   dbms_output.put_line('inside calc api code api :' || x_calculate_api_code );   */
    IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.RESET_CURR_FUNCTION;
    END IF;
EXCEPTION
    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count = 1 THEN
            PA_INTERFACE_UTILS_PUB.GET_MESSAGES
                ( p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out );
            x_msg_data := l_data;
            x_msg_count := l_msg_count;
        ELSE
            x_msg_count := l_msg_count;
        END IF;

        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( p_msg         => 'Invalid Arguments Passed',
                  p_module_name => l_module_name,
                  p_log_level   => 5 );
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(sqlerrm,1,240);
        FND_MSG_PUB.ADD_EXC_MSG
            ( p_pkg_name        => 'PA_FP_WP_GEN_BUDGET_AMT_PUB',
              p_procedure_name  => 'GET_CALC_API_FLAG_PARAMS',
              p_error_text      => substr(sqlerrm,1,240) );

        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                  p_module_name => l_module_name,
                  p_log_level   => 5 );
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GET_CALC_API_FLAG_PARAMS;

END PA_FP_WP_GEN_BUDGET_AMT_PUB;

/
