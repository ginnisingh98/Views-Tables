--------------------------------------------------------
--  DDL for Package Body PA_FP_GEN_COMMITMENT_AMOUNTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_GEN_COMMITMENT_AMOUNTS" as
/* $Header: PAFPGACB.pls 120.7 2007/02/06 09:55:19 dthakker ship $ */

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE GEN_COMMITMENT_AMOUNTS
          (P_PROJECT_ID                     IN              PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID 	            IN              PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC                    IN              PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           PX_GEN_RES_ASG_ID_TAB            IN OUT NOCOPY   PA_PLSQL_DATATYPES.IdTabTyp,
           PX_DELETED_RES_ASG_ID_TAB        IN OUT NOCOPY   PA_PLSQL_DATATYPES.IdTabTyp,
           X_RETURN_STATUS                  OUT   NOCOPY    VARCHAR2,
           X_MSG_COUNT                      OUT   NOCOPY    NUMBER,
           X_MSG_DATA	                    OUT   NOCOPY    VARCHAR2) IS

l_module_name         VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_COMMITMENT_AMOUNTS.GEN_COMMITMENT_AMOUNTS';

CURSOR   SUM_COMM_CRSR( c_tphase             PA_PROJ_FP_OPTIONS.COST_TIME_PHASED_CODE%TYPE
                       ,c_multi_curr_flag    PA_PROJ_FP_OPTIONS.PLAN_IN_MULTI_CURR_FLAG%TYPE
                       ,c_appl_id            GL_PERIOD_STATUSES.APPLICATION_ID%TYPE
                       ,c_set_of_books_id    PA_IMPLEMENTATIONS_ALL.SET_OF_BOOKS_ID%TYPE
                       ,c_org_id             PA_PROJECTS_ALL.ORG_ID%TYPE
                      )
IS
SELECT  /*+ INDEX(TMP,PA_RES_LIST_MAP_TMP4_N2)*/
         P.RESOURCE_ASSIGNMENT_ID
        ,DECODE(c_multi_curr_flag, 'Y', CT.DENOM_CURRENCY_CODE,CT.PROJECT_CURRENCY_CODE) currency_code
        ,NVL(CT.CMT_NEED_BY_DATE,CT.EXPENDITURE_ITEM_DATE)
        ,NVL(CT.CMT_NEED_BY_DATE,CT.EXPENDITURE_ITEM_DATE)
        ,DECODE(c_multi_curr_flag, 'Y', NVL(CT.DENOM_RAW_COST,0), NVL(CT.PROJ_RAW_COST,0)) tot_raw_cost
        ,DECODE(c_multi_curr_flag, 'Y', NVL(CT.DENOM_BURDENED_COST,0), NVL(CT.PROJ_BURDENED_COST,0)) tot_burdened_cost
        ,NVL(CT.PROJ_RAW_COST,0) tot_proj_raw_cost
        ,NVL(CT.PROJ_BURDENED_COST,0) tot_proj_burdened_cost
        ,NVL(CT.ACCT_RAW_COST,0) tot_projfunc_raw_cost
        ,NVL(CT.ACCT_BURDENED_COST,0) tot_projfunc_burdened_cost
        ,NVL(CT.TOT_CMT_QUANTITY,0) tot_quantity
FROM     PA_COMMITMENT_TXNS CT,
         PA_RES_LIST_MAP_TMP4 TMP,
         PA_RESOURCE_ASSIGNMENTS P
WHERE    TMP.TXN_SOURCE_ID         = CT.CMT_LINE_ID
AND      CT.PROJECT_ID             = P_PROJECT_ID
AND      NVL(CT.generation_error_flag,'N') = 'N'
AND      P.RESOURCE_ASSIGNMENT_ID  = TMP.TXN_RESOURCE_ASSIGNMENT_ID
AND      P.BUDGET_VERSION_ID       = P_BUDGET_VERSION_ID;

l_res_asg_id                PA_PLSQL_DATATYPES.IdTabTyp;
l_currency_code             PA_PLSQL_DATATYPES.Char15TabTyp;
l_tphase                    PA_PLSQL_DATATYPES.Char30TabTyp;
l_exp_itm_date              PA_PLSQL_DATATYPES.DateTabTyp;
l_commstart_date            PA_PLSQL_DATATYPES.DateTabTyp;
l_commend_date              PA_PLSQL_DATATYPES.DateTabTyp;
l_raw_cost_sum              PA_PLSQL_DATATYPES.NumTabTyp;
l_burdened_cost_sum         PA_PLSQL_DATATYPES.NumTabTyp;
l_proj_raw_cost_sum         PA_PLSQL_DATATYPES.NumTabTyp;
l_proj_burdened_cost_sum    PA_PLSQL_DATATYPES.NumTabTyp;
l_projfunc_raw_cost_sum     PA_PLSQL_DATATYPES.NumTabTyp;
l_projfunc_burdened_cost_sum   PA_PLSQL_DATATYPES.NumTabTyp;
l_quantity_sum_tab          PA_PLSQL_DATATYPES.NumTabTyp;
l_DELETED_RES_ASG_ID_TAB    PA_PLSQL_DATATYPES.IdTabTyp;
l_bl_raw_cost_sum_tab       PA_PLSQL_DATATYPES.NumTabTyp;
l_bl_burden_cost_sum_tab    PA_PLSQL_DATATYPES.NumTabTyp;
l_bl_quantity_sum_tab       PA_PLSQL_DATATYPES.NumTabTyp;

l_qty_tmp                   NUMBER:= 0;
l_txn_raw_cost_tmp          NUMBER:= 0;
l_upd_count                 NUMBER:= 0;
l_bl_cmt_raw_diff           NUMBER:= 0;
l_bl_cmt_burden_diff        NUMBER:= 0;
l_bl_cmt_quantity_diff      NUMBER:= 0;

l_txn_cost_rate_override    PA_BUDGET_LINES.TXN_COST_RATE_OVERRIDE%TYPE;
l_burden_cost_rate_override PA_BUDGET_LINES.BURDEN_COST_RATE_OVERRIDE%TYPE;
l_proj_cost_exchange_rate   PA_BUDGET_LINES.PROJECT_COST_EXCHANGE_RATE%TYPE;
l_projfunc_cost_exchange_rate PA_BUDGET_LINES.PROJFUNC_COST_EXCHANGE_RATE%TYPE;

l_appl_id                   NUMBER;
l_cnt                       NUMBER;

l_stru_sharing_code         PA_PROJECTS_ALL.STRUCTURE_SHARING_CODE%TYPE;
l_budget_lines_exist        VARCHAR2(1) ;
l_call_calculate            VARCHAR2(1);

l_last_updated_by           NUMBER := FND_GLOBAL.user_id;
l_last_update_login         NUMBER := FND_GLOBAL.login_id;
l_sysdate                   DATE   := SYSDATE;
l_ret_status                VARCHAR2(100);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);
l_data                      VARCHAR2(2000);
l_msg_index_out             NUMBER:=0;
l_rate_based_flag           pa_resource_assignments.rate_based_flag%TYPE;
l_res_assgn_id_tab          PA_PLSQL_DATATYPES.IdTabTyp;
l_rlm_id_tab                PA_PLSQL_DATATYPES.IdTabTyp;

l_gen_res_asg_id_tab        PA_PLSQL_DATATYPES.IdTabTyp;
l_chk_duplicate_flag        VARCHAR2(1) := 'N';

l_resource_class_id         PA_RESOURCE_CLASSES_B.RESOURCE_CLASS_ID%TYPE;

l_bl_start_date DATE;
l_bl_end_date   DATE;
l_bl_period_name pa_periods_all.period_name%TYPE;
l_etc_start_date DATE;
l_reference_start_date DATE;
l_reference_end_date DATE;

l_count1         NUMBER;

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
l_map_txn_source_id_tab		PA_PLSQL_DATATYPES.IdTabTyp;
l_map_rlm_id_tab      		PA_PLSQL_DATATYPES.IdTabTyp;
l_map_rbs_element_id_tab    	PA_PLSQL_DATATYPES.IdTabTyp;
l_map_txn_accum_header_id_tab   PA_PLSQL_DATATYPES.IdTabTyp;

-- Bug 4251148: When the Target is a Forecast version with Cost and Revenue
-- planned together and accrual method is Work, we will call the Calculate
-- API to compute revenue amounts.

/* Flag parameters for calling Calculate API */
l_refresh_rates_flag           VARCHAR2(1);
l_refresh_conv_rates_flag      VARCHAR2(1);
l_spread_required_flag         VARCHAR2(1);
l_conv_rates_required_flag     VARCHAR2(1);
l_rollup_required_flag         VARCHAR2(1);
l_raTxn_rollup_api_call_flag   VARCHAR2(1); -- Added for IPM new entity ER

/* Local PL/SQL table used for calling Calculate API */

l_source_context               pa_fp_res_assignments_tmp.source_context%TYPE;
l_txn_currency_code_tab        SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();
l_src_raw_cost_tab             SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_src_brdn_cost_tab            SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_src_revenue_tab              SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_b_cost_rate_override_tab     SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_line_start_date_tab          SYSTEM.pa_date_tbl_type:=SYSTEM.pa_date_tbl_type();
l_line_end_date_tab            SYSTEM.pa_date_tbl_type:=SYSTEM.pa_date_tbl_type();
l_tgt_res_asg_id_tab           SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_tgt_rate_based_flag_tab      SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
l_cost_rate_override_tab       SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_bill_rate_override_tab       SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_src_quantity_tab             SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();

-- Added for Bug 4320171
l_raw_cost_rate_tab            SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_b_cost_rate_tab              SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_bill_rate_tab                SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();

l_rev_gen_method               VARCHAR2(3);
l_calc_api_required_flag       VARCHAR2(1);
l_index                        NUMBER;
bl_index                       NUMBER;

kk                             NUMBER; -- an index variable during aggregation logic
l_index_tab                    PA_PLSQL_DATATYPES.IdTabTyp;

-- temporary pl/sql tables to hold pre-aggregated amounts
l_cal_tgt_res_asg_id_tab       PA_PLSQL_DATATYPES.IdTabTyp;
l_cal_tgt_rate_based_flag_tab  PA_PLSQL_DATATYPES.Char1TabTyp;
l_cal_txn_currency_code_tab    PA_PLSQL_DATATYPES.Char30TabTyp;
l_cal_line_start_date_tab      PA_PLSQL_DATATYPES.DateTabTyp;
l_cal_line_end_date_tab        PA_PLSQL_DATATYPES.DateTabTyp;

l_cal_cmt_quantity_tab         PA_PLSQL_DATATYPES.NumTabTyp;
l_cal_cmt_raw_cost_tab         PA_PLSQL_DATATYPES.NumTabTyp;
l_cal_cmt_brdn_cost_tab        PA_PLSQL_DATATYPES.NumTabTyp;

l_cal_base_quantity_tab        PA_PLSQL_DATATYPES.NumTabTyp;
l_cal_base_raw_cost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
l_cal_base_brdn_cost_tab       PA_PLSQL_DATATYPES.NumTabTyp;

-- budget line amounts for update records
l_bl_quantity                  PA_BUDGET_LINES.QUANTITY%TYPE;
l_bl_txn_raw_cost              PA_BUDGET_LINES.TXN_RAW_COST%TYPE;
l_bl_txn_burdened_cost         PA_BUDGET_LINES.TXN_BURDENED_COST%TYPE;
l_bl_project_raw_cost          PA_BUDGET_LINES.PROJECT_RAW_COST%TYPE;
l_bl_project_burdened_cost     PA_BUDGET_LINES.PROJECT_BURDENED_COST%TYPE;
l_bl_pfc_raw_cost              PA_BUDGET_LINES.RAW_COST%TYPE;
l_bl_pfc_burdened_cost         PA_BUDGET_LINES.BURDENED_COST%TYPE;

l_bl_init_quantity             PA_BUDGET_LINES.QUANTITY%TYPE;
l_bl_txn_init_raw_cost         PA_BUDGET_LINES.TXN_RAW_COST%TYPE;
l_bl_txn_init_burdened_cost    PA_BUDGET_LINES.TXN_BURDENED_COST%TYPE;
l_bl_project_init_raw_cost     PA_BUDGET_LINES.PROJECT_RAW_COST%TYPE;
l_bl_pfc_init_raw_cost         PA_BUDGET_LINES.RAW_COST%TYPE;
l_bl_pfc_init_burdened_cost    PA_BUDGET_LINES.BURDENED_COST%TYPE;

-- update amounts (existing budget line amounts + commitments)
l_upd_quantity                 PA_BUDGET_LINES.QUANTITY%TYPE;
l_upd_txn_raw_cost             PA_BUDGET_LINES.TXN_RAW_COST%TYPE;
l_upd_txn_burdened_cost        PA_BUDGET_LINES.TXN_BURDENED_COST%TYPE;
l_upd_project_raw_cost         PA_BUDGET_LINES.PROJECT_RAW_COST%TYPE;
l_upd_project_burdened_cost    PA_BUDGET_LINES.PROJECT_BURDENED_COST%TYPE;
l_upd_pfc_raw_cost             PA_BUDGET_LINES.RAW_COST%TYPE;
l_upd_pfc_burdened_cost        PA_BUDGET_LINES.BURDENED_COST%TYPE;

l_budget_line_id               PA_BUDGET_LINES.BUDGET_LINE_ID%TYPE;
-- stores ids of existing budget lines that need to be deleted
-- before Calculate API is called so that a difference is detected.
l_budget_line_id_tab           PA_PLSQL_DATATYPES.IdTabTyp;

/* String constants for valid Calling Context values */
lc_BudgetGeneration            CONSTANT VARCHAR2(30) := 'BUDGET_GENERATION';
lc_ForecastGeneration          CONSTANT VARCHAR2(30) := 'FORECAST_GENERATION';
l_calling_context              VARCHAR2(30);

/* Variables added for Bug 4549862 */
l_gen_src_code                  PA_PROJ_FP_OPTIONS.GEN_COST_SRC_CODE%TYPE;
l_cost_based_all_from_sp_flag   VARCHAR2(1);

-- Bug 4549862: GEN_COST_BASED_REVENUE expects the BILLABLE_FLAG and
-- BUDGET_LINE_ID columns of the PA_FP_ROLLUP_TMP to be populated.

-- Added l_bl_id_counter to track unique budget_line_id values for
-- the PA_FP_ROLLUP_TMP table. Initialize it to the MAX budget_line_id
-- value in the temp table to pick up where the Staffing Plan API left
-- off, and increment by 1 prior to each Insert to the temp table.
-- Note: these are not valid budget_line_id values in pa_budget_lines.
-- Rather, we are using the column to index records for processing of
-- cost-based revenue amounts, since an Index exists for the column.
l_bl_id_counter             NUMBER;

-- The billable flag value will be based on target task billability.
l_billable_flag                 VARCHAR2(1);

-- Bug 4549862: Whenever Commitments map to a resource having rejection
-- code data (either in PA_FP_ROLLUP_TMP when the source is Staffing Plan,
-- or in PA_BUDGET_LINES for other cases), a generic error message will be
-- added once to the error stack. For each such commitment, the relevant
-- rejection code values should be added to the error stack. After all
-- Commitments have been processed, an error should be raised. This flag
-- tracks if at least 1  commitment maps to a resource having rejection
-- code data. By default, the value should be 'N'. Set the value to 'Y'
-- in the error situation.
l_rejection_code_error_flag    VARCHAR2(1);

/* This user-defined exception is used to skip processing of
 * a commitment as we process all of the commitments in a loop. */
continue_loop                  EXCEPTION;
l_dummy                        NUMBER;

-- Bug 4549862: Variables to process rejection codes
l_rej_start_date_tab            PA_PLSQL_DATATYPES.DateTabTyp;
l_cost_rej_code_tab             PA_PLSQL_DATATYPES.Char30TabTyp;
l_burden_rej_code_tab           PA_PLSQL_DATATYPES.Char30TabTyp;
l_pc_cur_conv_rej_code_tab      PA_PLSQL_DATATYPES.Char30TabTyp;
l_pfc_cur_conv_rej_code_tab     PA_PLSQL_DATATYPES.Char30TabTyp;

l_project_name                  PA_PROJECTS_ALL.NAME%TYPE;
l_task_number                   PA_TASKS.TASK_NUMBER%TYPE;
l_resource_name                 PA_RESOURCE_LIST_MEMBERS.ALIAS%TYPE;

-- Variables added for Bug Fix 4582616
l_fp_src_plan_ver_id            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE;
l_fp_cols_rec_src_finplan       PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
l_fp_planning_options_flag      VARCHAR2(1);

-- pl/sql tables to store parameters for POPULATE_GEN_RATE API
l_sr_src_ra_id_tab              PA_PLSQL_DATATYPES.NumTabTyp;
l_sr_tgt_ra_id_tab              PA_PLSQL_DATATYPES.NumTabTyp;
l_sr_txn_currency_code_tab      PA_PLSQL_DATATYPES.Char30TabTyp;

BEGIN
 -- hr_utility.trace_on(null,'mftest');
    /* hr_utility.trace('---BEGIN---'); */
    X_MSG_COUNT := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF p_pa_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function     => 'GEN_COMMITMENT_AMOUNTS'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
    END IF;

   l_stru_sharing_code := PA_PROJECT_STRUCTURE_UTILS.get_Structure_sharing_code(P_PROJECT_ID=> P_PROJECT_ID);

   -- Bug 4549862: Moved initialization of l_calling_context
   -- here from just before call to the Calculate API.

   -- Initialize calling context Calculate API parameter
   IF p_fp_cols_rec.x_plan_class_code = 'BUDGET' THEN
       l_calling_context := lc_BudgetGeneration;
   ELSIF p_fp_cols_rec.x_plan_class_code = 'FORECAST' THEN
       l_calling_context := lc_ForecastGeneration;
   END IF;

   -- Bug 4549862: Initialize new l_gen_src_code variable.
   IF l_calling_context = lc_BudgetGeneration THEN
       l_gen_src_code := p_fp_cols_rec.x_gen_src_code;
   ELSIF  l_calling_context = lc_ForecastGeneration THEN
       l_gen_src_code := p_fp_cols_rec.x_gen_etc_src_code;
   END IF;

   -- Bug 4549862: Moved initialization of l_rev_gen_method here
   -- from just before initialization of l_calc_api_required_flag.
   --l_rev_gen_method := PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(p_project_id);
  l_rev_gen_method := nvl(p_fp_cols_rec.x_revenue_derivation_method,PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(p_project_id)); -- Bug 5462471

   -- Bug 4549862: Initialize l_cost_based_all_from_sp_flag.
   IF l_rev_gen_method = 'C' AND
      p_fp_cols_rec.x_version_type = 'ALL' AND
      l_gen_src_code = 'RESOURCE_SCHEDULE' THEN
       l_cost_based_all_from_sp_flag := 'Y';
   ELSE
       l_cost_based_all_from_sp_flag := 'N';
   END IF;

   -- Bug 4549862: The budget_line_id counter will keep track of the next
   -- unique budget_line_id in the PA_FP_ROLLUP_TMP table. Initialize it
   -- with the max rolup_id value in the table. Prior to each Insert
   -- to the temp table, increment the counter by 1.
   IF l_cost_based_all_from_sp_flag = 'Y' THEN
       BEGIN
           SELECT MAX(budget_line_id) INTO l_bl_id_counter
           FROM pa_fp_rollup_tmp;

           IF l_bl_id_counter IS NULL THEN
               l_bl_id_counter := 0;
           END IF;
       EXCEPTION
           WHEN OTHERS THEN
               l_bl_id_counter := 0;
       END;
   END IF;

    -- Bug 4549862: Initialize error flag to 'N'.
    l_rejection_code_error_flag := 'N';


   --dbms_output.put_line('Value for struct sharing code [' || l_stru_sharing_code || ']');
   /* deleting the PJI resource mapping tmp tables. */
   DELETE FROM PA_RES_LIST_MAP_TMP1;
   DELETE FROM PA_RES_LIST_MAP_TMP2;
   DELETE FROM PA_RES_LIST_MAP_TMP3;
   DELETE FROM PA_RES_LIST_MAP_TMP4;

   SELECT   RESOURCE_CLASS_ID
   INTO     l_resource_class_id
   FROM     PA_RESOURCE_CLASSES_B
   WHERE    RESOURCE_CLASS_CODE = 'FINANCIAL_ELEMENTS';

   --dbms_output.put_line('Value for res class id [' || to_char(l_resource_class_id) || ']');

   --dbms_output.put_line('inserting into PA_RES_LIST_MAP_TMP1 P_PROJECT_ID is [' || to_char(P_PROJECT_ID) || ']');
                     SELECT    ct.CMT_LINE_ID,
                               'OPEN_COMMITMENTS',
                               ct.ORGANIZATION_ID,
                               ct.VENDOR_ID,
                               ct.EXPENDITURE_TYPE,
                               ct.REVENUE_CATEGORY,
                               ct.TASK_ID
                              ,NVL(ct.CMT_NEED_BY_DATE, ct.EXPENDITURE_ITEM_DATE)
                              ,NVL(ct.CMT_NEED_BY_DATE, ct.EXPENDITURE_ITEM_DATE)
                              ,SYSTEM_LINKAGE_FUNCTION
                              ,INVENTORY_ITEM_ID
                              ,DECODE(EXPENDITURE_TYPE,null,
                               DECODE(EXPENDITURE_CATEGORY,null,NULL,
                              'EXPENDITURE_CATEGORY'),'EXPENDITURE_TYPE'),
                               NVL(ct.RESOURCE_CLASS,'FINANCIAL_ELEMENTS')
                     BULK COLLECT
                     INTO      l_TXN_SOURCE_ID_tab,
                               l_TXN_SOURCE_TYPE_CODE_tab,
                               l_ORGANIZATION_ID_tab,
                               l_VENDOR_ID_tab,
                               l_EXPENDITURE_TYPE_tab,
                               l_REVENUE_CATEGORY_CODE_tab,
                               l_TXN_TASK_ID_tab,
                               l_TXN_PLAN_START_DATE_tab,
                               l_TXN_PLAN_END_DATE_tab,
                               l_SYS_LINK_FUNCTION_tab,
                               l_INVENTORY_ITEM_ID_tab,
                               l_FC_RES_TYPE_CODE_tab,
                               l_RESOURCE_CLASS_CODE_tab
                     FROM      PA_COMMITMENT_TXNS ct, PA_RESOURCE_CLASSES_B rc
                     WHERE     ct.PROJECT_ID = P_PROJECT_ID
                     AND      NVL(CT.generation_error_flag,'N') = 'N'
                     AND       ct.RESOURCE_CLASS = rc.RESOURCE_CLASS_CODE(+);
   --dbms_output.put_line('l_TXN_SOURCE_ID_tab.count: '||l_TXN_SOURCE_ID_tab.count);
   IF l_TXN_SOURCE_ID_tab.count = 0 THEN
      IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.Reset_Curr_Function;
      END IF;
      RETURN;
   END IF;


       FOR bb in 1..l_TXN_SOURCE_ID_tab.count LOOP
            l_PERSON_ID_tab(bb)            := null;
            l_JOB_ID_tab(bb)               := null;
            l_EVENT_TYPE_tab(bb)           := null;
            l_NON_LABOR_RESOURCE_tab(bb)   := null;
            l_EXPENDITURE_CATEGORY_tab(bb) := null;
            l_NLR_ORGANIZATION_ID_tab(bb)  := null;
            l_EVENT_CLASSIFICATION_tab(bb) := null;
            l_PROJECT_ROLE_ID_tab(bb)      := null;
            l_MFC_COST_TYPE_ID_tab(bb)     := null;
            l_RESOURCE_CLASS_FLAG_tab(bb)  := null;
            l_ITEM_CATEGORY_ID_tab(bb)     := null;
            l_PERSON_TYPE_CODE_tab(bb)     := null;
            l_BOM_RESOURCE_ID_tab(bb)      := null;
            l_NAMED_ROLE_tab(bb)           := null;
            l_INCURRED_BY_RES_FLAG_tab(bb) := null;
            l_RATE_BASED_FLAG_tab(bb)      := null;
            l_TXN_WBS_ELEMENT_VER_ID_tab(bb):= null;
            l_TXN_RBS_ELEMENT_ID_tab(bb)   := null;
       END LOOP;
   --dbms_output.put_line('b4 calling MAP_RLMI_RBS api');
    IF P_PA_DEBUG_MODE = 'Y' THEN
	PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_MSG           => 'Before calling PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS',
            P_MODULE_NAME   => l_module_name);
    END IF;
    PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS (
         P_PROJECT_ID                   => p_project_id,
	 P_BUDGET_VERSION_ID     	=> NULL,
     	 P_RESOURCE_LIST_ID             => P_FP_COLS_REC.X_RESOURCE_LIST_ID,
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
	 P_JOB_ID_TAB                 	=> l_JOB_ID_tab,
	 P_ORGANIZATION_ID_TAB         	=> l_ORGANIZATION_ID_tab,
	 P_VENDOR_ID_TAB               	=> l_VENDOR_ID_tab,
	 P_EXPENDITURE_TYPE_TAB        	=> l_EXPENDITURE_TYPE_tab,
	 P_EVENT_TYPE_TAB              	=> l_EVENT_TYPE_tab,
	 P_NON_LABOR_RESOURCE_TAB      	=> l_NON_LABOR_RESOURCE_tab,
	 P_EXPENDITURE_CATEGORY_TAB    	=> l_EXPENDITURE_CATEGORY_tab,
	 P_REVENUE_CATEGORY_CODE_TAB   	=>l_REVENUE_CATEGORY_CODE_tab,
	 P_NLR_ORGANIZATION_ID_TAB     	=>l_NLR_ORGANIZATION_ID_tab,
	 P_EVENT_CLASSIFICATION_TAB    	=> l_EVENT_CLASSIFICATION_tab,
	 P_SYS_LINK_FUNCTION_TAB       	=> l_SYS_LINK_FUNCTION_tab,
	 P_PROJECT_ROLE_ID_TAB         	=> l_PROJECT_ROLE_ID_tab,
	 P_RESOURCE_CLASS_CODE_TAB     	=> l_RESOURCE_CLASS_CODE_tab,
	 P_MFC_COST_TYPE_ID_TAB        	=> l_MFC_COST_TYPE_ID_tab,
	 P_RESOURCE_CLASS_FLAG_TAB     	=> l_RESOURCE_CLASS_FLAG_tab,
	 P_FC_RES_TYPE_CODE_TAB        	=> l_FC_RES_TYPE_CODE_tab,
	 P_INVENTORY_ITEM_ID_TAB       	=> l_INVENTORY_ITEM_ID_tab,
	 P_ITEM_CATEGORY_ID_TAB        	=> l_ITEM_CATEGORY_ID_tab,
	 P_PERSON_TYPE_CODE_TAB        	=> l_PERSON_TYPE_CODE_tab,
	 P_BOM_RESOURCE_ID_TAB         	=>l_BOM_RESOURCE_ID_tab,
	 P_NAMED_ROLE_TAB              	=>l_NAMED_ROLE_tab,
	 P_INCURRED_BY_RES_FLAG_TAB    	=>l_INCURRED_BY_RES_FLAG_tab,
	 P_RATE_BASED_FLAG_TAB         	=>l_RATE_BASED_FLAG_tab,
	 P_TXN_TASK_ID_TAB             	=>l_TXN_TASK_ID_tab,
	 P_TXN_WBS_ELEMENT_VER_ID_TAB  	=> l_TXN_WBS_ELEMENT_VER_ID_tab,
	 P_TXN_RBS_ELEMENT_ID_TAB      	=> l_TXN_RBS_ELEMENT_ID_tab,
	 P_TXN_PLAN_START_DATE_TAB     	=> l_TXN_PLAN_START_DATE_tab,
	 P_TXN_PLAN_END_DATE_TAB       	=> l_TXN_PLAN_END_DATE_tab,
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
    --dbms_output.put_line('After calling PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS: '||x_return_status);
    --dbms_output.put_line('l_map_rlm_id_tab.count: '||l_map_rlm_id_tab.count);
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

      SELECT   /*+ INDEX(PA_RES_LIST_MAP_TMP4,PA_RES_LIST_MAP_TMP4_N1)*/
               count(*) INTO l_count1
      FROM     PA_RES_LIST_MAP_TMP4
      WHERE    RESOURCE_LIST_MEMBER_ID IS NULL and rownum=1;
      IF l_count1 > 0 THEN
           PA_UTILS.ADD_MESSAGE
              (p_app_short_name => 'PA',
               p_msg_name       => 'PA_INVALID_MAPPING_ERR');
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

       IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling pa_fp_gen_budget_amt_pub.create_res_asg',
              p_module_name => l_module_name,
              p_log_level   => 5);
       END IF;
       --dbms_output.put_line('calling PA_FP_GEN_BUDGET_AMT_PUB.CREATE_RES_ASG');
       PA_FP_GEN_BUDGET_AMT_PUB.CREATE_RES_ASG
           (P_PROJECT_ID               => P_PROJECT_ID,
            P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
            P_STRU_SHARING_CODE        => l_stru_sharing_code,
            P_GEN_SRC_CODE             => 'OPEN_COMMITMENTS',
            P_FP_COLS_REC              => P_FP_COLS_REC,
            X_RETURN_STATUS            => X_RETURN_STATUS,
            X_MSG_COUNT                => X_MSG_COUNT,
            X_MSG_DATA	               => X_MSG_DATA);
       IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;

       --dbms_output.put_line('after calling PA_FP_GEN_BUDGET_AMT_PUB.CREATE_RES_ASG');
       IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling pa_fp_gen_budget_amt_pub.create_res_asg'
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
       END IF;

       IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling pa_fp_gen_budget_amt_pub.update_res_asg',
              p_module_name => l_module_name,
              p_log_level   => 5);
       END IF;

       --dbms_output.put_line('calling PA_FP_GEN_BUDGET_AMT_PUB.UPDATE_RES_ASG');
       PA_FP_GEN_BUDGET_AMT_PUB.UPDATE_RES_ASG
           (P_PROJECT_ID               => P_PROJECT_ID,
            P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
            P_STRU_SHARING_CODE        => l_stru_sharing_code,
	    P_GEN_SRC_CODE             => 'OPEN_COMMITMENTS',
            P_FP_COLS_REC              => P_FP_COLS_REC,
            X_RETURN_STATUS            => X_RETURN_STATUS,
            X_MSG_COUNT                => X_MSG_COUNT,
            X_MSG_DATA	               => X_MSG_DATA);
       IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;
       --dbms_output.put_line('after calling PA_FP_GEN_BUDGET_AMT_PUB.UPDATE_RES_ASG');
       IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling pa_fp_gen_budget_amt_pub.update_res_asg'
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
       END IF;

   l_appl_id := PA_PERIOD_PROCESS_PKG.Application_id;

   /*===================================================================+
    | If plan_type_code is 'FORECAST', use the ETC_START_DATE to derive |
    | the dates for the budget lines.                                   |
    +===================================================================*/
    IF ( P_FP_COLS_REC.X_PLAN_CLASS_CODE = 'FORECAST' )
    THEN
    -- hr_utility.trace('---inside forecast plan class---');
        l_etc_start_date :=
        PA_FP_GEN_AMOUNT_UTILS.GET_ETC_START_DATE(P_FP_COLS_REC.X_BUDGET_VERSION_ID);
     -- hr_utility.trace('---etc start dt --'||to_char(l_etc_start_date,'dd-mon-rrrr'));
    END IF;

   --dbms_output.put_line('opening cursor SUM_COMM_CRSR');
   OPEN     SUM_COMM_CRSR(P_FP_COLS_REC.X_TIME_PHASED_CODE,
                          P_FP_COLS_REC.X_PLAN_IN_MULTI_CURR_FLAG,
                          l_appl_id,
                          P_FP_COLS_REC.X_SET_OF_BOOKS_ID,
                          P_FP_COLS_REC.X_ORG_ID);

   --dbms_output.put_line('fetching cursor SUM_COMM_CRSR');
   FETCH    SUM_COMM_CRSR
   BULK     COLLECT
   INTO     l_res_asg_id
           ,l_currency_code
           ,l_commstart_date
           ,l_commend_date
           ,l_raw_cost_sum
           ,l_burdened_cost_sum
           ,l_proj_raw_cost_sum
           ,l_proj_burdened_cost_sum
           ,l_projfunc_raw_cost_sum
           ,l_projfunc_burdened_cost_sum
           ,l_quantity_sum_tab;
   --dbms_output.put_line('closing cursor SUM_COMM_CRSR');
   CLOSE SUM_COMM_CRSR;

    IF l_res_asg_id.count = 0 THEN
        IF P_PA_DEBUG_MODE = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN; -- added by dkuo 2005.04.13
    END IF;

    -- Bug 4320171: Before calling the Calculate API with Source Context
    -- as BUDGET_LINE, the Resource Assignment Planning Start/End dates
    -- need to be synched up with the Commitment Dates. We can sync up the
    -- dates any time after the tmp4 table has been created and the
    -- UPDATE_RES_ASG API has been called. Thus, we have moved the call
    -- to SYNC_UP_PLANNING_DATES from the end of the API to here.

    IF p_pa_debug_mode = 'Y' THEN
          pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Before calling
                               pa_fp_maintain_actual_pub.sync_up_planning_dates',
             p_module_name => l_module_name,
             p_log_level   => 5);
    END IF;
    PA_FP_MAINTAIN_ACTUAL_PUB.SYNC_UP_PLANNING_DATES
          (P_BUDGET_VERSION_ID => p_budget_version_id,
           P_CALLING_CONTEXT   => 'GEN_COMMITMENTS',
           X_RETURN_STATUS     => x_return_Status,
           X_MSG_COUNT         => x_msg_count,
           X_MSG_DATA          => x_msg_data );
    IF p_pa_debug_mode = 'Y' THEN
          pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Status after calling
                               pa_fp_maintain_actual_pub.sync_up_planning_dates'
                               ||x_return_status,
             p_module_name => l_module_name,
             p_log_level   => 5);
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;


  -- Bug 4251148: When the Target is a Forecast version with Cost and Revenue
  -- planned together and the revenue accrual method is Work, we will call the
  -- Calculate API to compute revenue amounts.

  -- Bug 4549862: Moved initialization of l_rev_gen_method to beginning of API.

  IF p_fp_cols_rec.x_version_type = 'ALL' AND l_rev_gen_method = 'T' THEN
      l_calc_api_required_flag := 'Y';
  ELSE
      l_calc_api_required_flag := 'N';
  END IF;

  -- Initialize l_index for Calculate API pl/sql tables. Increment before use.
  l_index := 0;
  bl_index := 0;

  -- Bug 4549862: Placed contents of the main loop in a Begin/End block
  -- so that the user-defined continue_loop exception can be used to skip
  -- further processing within a loop iteration if a rejection code error
  -- is discovered. In this case, rejection codes must be checked for all
  -- commitments before an error is Raised.

  FOR i IN 1..l_res_asg_id.COUNT LOOP
  BEGIN
      /*=================================================================+
       | If Forecast use etc_start_date to derive the BL start and end   |
       |  dates. Else, use commitment start and end dates.               |
       +=================================================================*/
      /* assigning the commitment start date to the local variable for
         bug 3846278 */
    -- hr_utility.trace('---ref start date before---'||to_char(l_reference_start_date,'dd-mon-rrrr'));

      SELECT NVL(rate_based_flag,'N') INTO l_rate_based_flag
      FROM pa_resource_assignments
      WHERE
      resource_assignment_id = l_res_asg_id(i);

      IF l_rate_based_flag = 'N' THEN
         IF P_FP_COLS_REC.X_PLAN_IN_MULTI_CURR_FLAG = 'Y' THEN
             l_quantity_sum_tab(i) := l_raw_cost_sum(i);
         ELSE
             l_quantity_sum_tab(i) := l_proj_raw_cost_sum(i);
         END IF;
      END IF;

      -- Added l_reference_end_date to be used for deriving
      -- l_bl_end_date when the Target is None timephased.

      l_reference_start_date := TRUNC(l_commstart_date(i));
      l_reference_end_date   := TRUNC(l_commend_date(i));
      IF ( P_FP_COLS_REC.X_PLAN_CLASS_CODE = 'FORECAST' AND
          l_etc_start_date IS NOT NULL)
      THEN
           IF l_reference_start_date < l_etc_start_date THEN
              l_reference_start_date := l_etc_start_date;
           END IF;
           IF l_reference_end_date < l_etc_start_date THEN
              l_reference_end_date := l_etc_start_date;
           END IF;
      END IF;
    -- hr_utility.trace('---ref start date aft if chk---'||to_char(l_reference_start_date,'dd-mon-rrrr'));

      --dbms_output.put_line (' time phase [' || P_FP_COLS_REC.X_TIME_PHASED_CODE || ']');
      IF ( P_FP_COLS_REC.X_TIME_PHASED_CODE = 'P' )
      THEN
               BEGIN
                     -- SQL Repository Bug 4884718; SQL ID 14901776
                     -- Fixed Merge Join Cartesian violation by commenting out
                     -- PA_IMPLEMENTATIONS from the FROM clause of the query below.

                     SELECT pap.start_date
                           ,pap.end_date
                           ,pap.period_name
                       INTO l_bl_start_date
                           ,l_bl_end_date
                           ,l_bl_period_name
                      FROM pa_periods_all pap
                        --,pa_implementations imp /* Bug 4884718; SQL ID 14901776 */
                     WHERE l_reference_start_date BETWEEN pap.start_date AND pap.end_date
                       AND pap.org_id = p_fp_cols_rec.x_org_id;
                       -- R12 MOAC 4447573: NVL(pap.org_id,-99)

                       -- fp cols rec nvl org id is done in the util pkg.
               EXCEPTION
                            WHEN OTHERS THEN RAISE;
               END;
      ELSIF ( P_FP_COLS_REC.X_TIME_PHASED_CODE = 'G' )
      THEN
               BEGIN
                     SELECT  PERIOD.start_date,
                             PERIOD.end_date,
                             PERIOD.period_name
                       INTO  l_bl_start_date
                            ,l_bl_end_date
                            ,l_bl_period_name
                       FROM  GL_PERIOD_STATUSES PERIOD
                      WHERE  PERIOD.application_id   = pa_period_process_pkg.application_id
                        AND  PERIOD.set_of_books_id  = p_fp_cols_rec.x_set_of_books_id
                        AND  PERIOD.adjustment_period_flag = 'N'
                        AND  l_reference_start_date BETWEEN
                        PERIOD.start_date AND PERIOD.end_date;
               EXCEPTION
                  WHEN OTHERS THEN RAISE;
               END;
      END IF; -- P_FP_COLS_REC.X_TIME_PHASED_CODE = 'P'

    /* hr_utility.trace('---bef bl chk res asg id---'||l_res_asg_id(i));
    hr_utility.trace('---bef bl chk cny code ---'||l_currency_code(i)); */


      -- Bug 4549862: Now that we have the commitment period start date
      -- for timephased versions, get budget line rejection codes.
      --
      -- When l_cost_based_all_from_sp_flag = 'N', check PA_BUDGET_LINES
      -- for rejection codes. When l_cost_based_all_from_sp_flag = 'Y',
      -- check PA_FP_ROLLUP_TMP for rejection codes instead.
      -- We are only interested in checking the raw cost, burden cost,
      -- pc/pfc currency conversion rejection codes.

      IF l_cost_based_all_from_sp_flag = 'N' THEN

          IF p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
              SELECT START_DATE,
                     COST_REJECTION_CODE,
                     BURDEN_REJECTION_CODE,
                     PC_CUR_CONV_REJECTION_CODE,
                     PFC_CUR_CONV_REJECTION_CODE
              BULK COLLECT
              INTO   l_rej_start_date_tab,
                     l_cost_rej_code_tab,
                     l_burden_rej_code_tab,
                     l_pc_cur_conv_rej_code_tab,
                     l_pfc_cur_conv_rej_code_tab
              FROM   pa_budget_lines
              WHERE  resource_assignment_id = l_res_asg_id(i)
              AND    txn_currency_code      = l_currency_code(i)
              AND    start_date             = l_bl_start_date
              AND  ( cost_rejection_code is not null OR
                     burden_rejection_code is not null OR
                     pc_cur_conv_rejection_code is not null OR
                     pfc_cur_conv_rejection_code is not null );
          ELSIF p_fp_cols_rec.x_time_phased_code = 'N' THEN
              SELECT START_DATE,
                     COST_REJECTION_CODE,
                     BURDEN_REJECTION_CODE,
                     PC_CUR_CONV_REJECTION_CODE,
                     PFC_CUR_CONV_REJECTION_CODE
              BULK COLLECT
              INTO   l_rej_start_date_tab,
                     l_cost_rej_code_tab,
                     l_burden_rej_code_tab,
                     l_pc_cur_conv_rej_code_tab,
                     l_pfc_cur_conv_rej_code_tab
              FROM   pa_budget_lines
              WHERE  resource_assignment_id = l_res_asg_id(i)
              AND    txn_currency_code      = l_currency_code(i)
              AND  ( cost_rejection_code is not null OR
                     burden_rejection_code is not null OR
                     pc_cur_conv_rejection_code is not null OR
                     pfc_cur_conv_rejection_code is not null );
          END IF; -- time phase check

      ELSIF l_cost_based_all_from_sp_flag = 'Y' THEN

          IF p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
              SELECT DISTINCT
                     start_date,
                     cost_rejection_code,
                     burden_rejection_code,
                     pc_cur_conv_rejection_code,
                     pfc_cur_conv_rejection_code
              BULK COLLECT
              INTO   l_rej_start_date_tab,
                     l_cost_rej_code_tab,
                     l_burden_rej_code_tab,
                     l_pc_cur_conv_rej_code_tab,
                     l_pfc_cur_conv_rej_code_tab
              FROM   pa_fp_rollup_tmp
              WHERE  resource_assignment_id = l_res_asg_id(i)
              AND    txn_currency_code = l_currency_code(i)
              AND    start_date = l_bl_start_date
              AND  ( cost_rejection_code is not null OR
                     burden_rejection_code is not null OR
                     pc_cur_conv_rejection_code is not null OR
                     pfc_cur_conv_rejection_code is not null );
          ELSIF p_fp_cols_rec.x_time_phased_code = 'N' THEN

              -- When the target version is None timephased, it is
              -- possible for multiple requirements/assignments with
              -- different start dates to map to the same target
              -- (resource, txn currency) combination. As a result,
              -- this case is handled differently from the others;
              -- take the minimum start date as the rejection code
              -- start date. Since the version is None timephased,
              -- rejection codes can occur any time within the start
              -- and end date time span, so it is okay to use the
              -- min start date here.

              SELECT MIN(start_date),
                     cost_rejection_code,
                     burden_rejection_code,
                     pc_cur_conv_rejection_code,
                     pfc_cur_conv_rejection_code
              BULK COLLECT
              INTO   l_rej_start_date_tab,
                     l_cost_rej_code_tab,
                     l_burden_rej_code_tab,
                     l_pc_cur_conv_rej_code_tab,
                     l_pfc_cur_conv_rej_code_tab
              FROM   pa_fp_rollup_tmp
              WHERE  resource_assignment_id = l_res_asg_id(i)
              AND    txn_currency_code = l_currency_code(i)
              AND  ( cost_rejection_code is not null OR
                     burden_rejection_code is not null OR
                     pc_cur_conv_rejection_code is not null OR
                     pfc_cur_conv_rejection_code is not null )
              GROUP BY cost_rejection_code,
                     burden_rejection_code,
                     pc_cur_conv_rejection_code,
                     pfc_cur_conv_rejection_code;
          END IF; -- time phase check

      END IF; -- l_cost_based_all_from_sp_flag check

      -- Bug 4549862: Process budget line rejection codes

      IF l_rej_start_date_tab.count > 0 THEN

	  -- Bug 4549862: Add a generic error message to the error stack
          -- before pushing any rejection codes on to the stack. Only do
          -- this the first time we discover a rejection code and change
          -- the l_rejection_code_error_flag from 'N' to 'Y'.

          IF l_rejection_code_error_flag = 'N' THEN
              PA_UTILS.ADD_MESSAGE
                  ( p_app_short_name => 'PA',
                    p_msg_name       => 'PA_CMT_REJ_CODE_ERR' );
              l_rejection_code_error_flag := 'Y';
          END IF;

          -- Get other message token details
          SELECT p.name, ta.task_number, rlm.alias
          INTO   l_project_name, l_task_number, l_resource_name
          FROM   pa_resource_assignments ra,
                 pa_projects_all p,
                 pa_tasks ta,
                 pa_resource_list_members rlm
          WHERE  ra.resource_assignment_id = l_res_asg_id(i)
          AND    p.project_id = ra.project_id
          AND    ta.task_id (+) = ra.task_id
          AND    rlm.resource_list_member_id = ra.resource_list_member_id;

          -- Add rejection code error messages to the error stack.
          -- Note that the code can be null (e.g. when we select from a
          -- single budget line, we check that at least 1 rejection code
          -- is not null, but the others may be null).

          FOR j in 1..l_rej_start_date_tab.count LOOP
              IF l_cost_rej_code_tab(j) IS NOT NULL THEN
                  PA_UTILS.ADD_MESSAGE
                      ( p_app_short_name => 'PA',
                        p_msg_name       => l_cost_rej_code_tab(j),
                        p_token1         => 'PROJECT',
                        p_value1         => l_project_name,
                        p_token2         => 'TASK',
                        p_value2         => l_task_number,
                        p_token3         => 'RESOURCE_NAME',
                        p_value3         => l_resource_name,
                        p_token4         => 'START_DATE',
                        p_value4         => l_rej_start_date_tab(j) );
              END IF;
              IF l_burden_rej_code_tab(j) IS NOT NULL THEN
                  PA_UTILS.ADD_MESSAGE
                      ( p_app_short_name => 'PA',
                        p_msg_name       => l_burden_rej_code_tab(j),
                        p_token1         => 'PROJECT',
                        p_value1         => l_project_name,
                        p_token2         => 'TASK',
                        p_value2         => l_task_number,
                        p_token3         => 'RESOURCE_NAME',
                        p_value3         => l_resource_name,
                        p_token4         => 'START_DATE',
                        p_value4         => l_rej_start_date_tab(j) );
              END IF;
              IF l_pc_cur_conv_rej_code_tab(j) IS NOT NULL THEN
                  PA_UTILS.ADD_MESSAGE
                      ( p_app_short_name => 'PA',
                        p_msg_name       => l_pc_cur_conv_rej_code_tab(j),
                        p_token1         => 'PROJECT',
                        p_value1         => l_project_name,
                        p_token2         => 'TASK',
                        p_value2         => l_task_number,
                        p_token3         => 'RESOURCE_NAME',
                        p_value3         => l_resource_name,
                        p_token4         => 'START_DATE',
                        p_value4         => l_rej_start_date_tab(j) );
              END IF;
              IF l_pfc_cur_conv_rej_code_tab(j) IS NOT NULL THEN
                  PA_UTILS.ADD_MESSAGE
                      ( p_app_short_name => 'PA',
                        p_msg_name       => l_pfc_cur_conv_rej_code_tab(j),
                        p_token1         => 'PROJECT',
                        p_value1         => l_project_name,
                        p_token2         => 'TASK',
                        p_value2         => l_task_number,
                        p_token3         => 'RESOURCE_NAME',
                        p_value3         => l_resource_name,
                        p_token4         => 'START_DATE',
                        p_value4         => l_rej_start_date_tab(j) );
              END IF;
          END LOOP; -- FOR j in 1..l_rej_start_date_tab.count LOOP

      END IF; -- l_rej_start_date_tab.count > 0

      -- Bug 4549862: If the rejection code error flag is 'Y', then an error
      -- will eventually be raised, so there is no point in processing this
      -- commitment any further.

      IF l_rejection_code_error_flag = 'Y' THEN
          RAISE continue_loop;
      END IF;


      -- Bug 4549862: For the Cost-based All version from Staffing Plan
      -- flow, we do not need to check if a budget line exists for the
      -- current commitment being processed, since we will be inserting
      -- the commitment data into the PA_FP_ROLLUP_TMP table instead of
      -- pa_budget_lines for further processing. At the same time, we
      -- still want the l_budget_lines_exist flag initialized as 'N' so
      -- that logic for updating dates for None time phased versions is
      -- still executed properly.

      l_budget_lines_exist := 'N';

      IF l_cost_based_all_from_sp_flag = 'N' THEN

          BEGIN
              IF p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
                  SELECT BUDGET_LINE_ID,
                         QUANTITY,
                         TXN_RAW_COST,
                         TXN_BURDENED_COST,
                         PROJECT_RAW_COST,
                         PROJECT_BURDENED_COST,
                         RAW_COST,
                         BURDENED_COST
                  INTO   l_budget_line_id,
                         l_bl_quantity,
                         l_bl_txn_raw_cost,
                         l_bl_txn_burdened_cost,
                         l_bl_project_raw_cost,
                         l_bl_project_burdened_cost,
                         l_bl_pfc_raw_cost,
                         l_bl_pfc_burdened_cost
                  FROM   PA_BUDGET_LINES BL
                  WHERE  BL.RESOURCE_ASSIGNMENT_ID = l_res_asg_id(i)
                  AND    BL.TXN_CURRENCY_CODE      = l_currency_code(i)
                  AND    BL.START_DATE             = l_bl_start_date;
              ELSIF p_fp_cols_rec.x_time_phased_code = 'N' THEN
                  IF p_fp_cols_rec.x_plan_class_code = 'FORECAST' THEN
                      SELECT BUDGET_LINE_ID,
                             START_DATE,
                             END_DATE,
                             QUANTITY,
                             TXN_RAW_COST,
                             TXN_BURDENED_COST,
                             PROJECT_RAW_COST,
                             PROJECT_BURDENED_COST,
                             RAW_COST,
                             BURDENED_COST,
                             NVL(INIT_QUANTITY,0),
                             NVL(TXN_INIT_RAW_COST,0),
                             NVL(TXN_INIT_BURDENED_COST,0),
                             NVL(PROJECT_INIT_RAW_COST,0),
                             NVL(INIT_RAW_COST,0),
                             NVL(INIT_BURDENED_COST,0)
                      INTO   l_budget_line_id,
                             l_bl_start_date,
                             l_bl_end_date,
                             l_bl_quantity,
                             l_bl_txn_raw_cost,
                             l_bl_txn_burdened_cost,
                             l_bl_project_raw_cost,
                             l_bl_project_burdened_cost,
                             l_bl_pfc_raw_cost,
                             l_bl_pfc_burdened_cost,
                             l_bl_init_quantity,
                             l_bl_txn_init_raw_cost,
                             l_bl_txn_init_burdened_cost,
                             l_bl_project_init_raw_cost,
                             l_bl_pfc_init_raw_cost,
                             l_bl_pfc_init_burdened_cost
                      FROM   PA_BUDGET_LINES BL
                      WHERE  BL.RESOURCE_ASSIGNMENT_ID = l_res_asg_id(i)
                      AND    BL.TXN_CURRENCY_CODE      = l_currency_code(i);
                  ELSE
                      SELECT BUDGET_LINE_ID,
                             START_DATE,
                             END_DATE,
                             QUANTITY,
                             TXN_RAW_COST,
                             TXN_BURDENED_COST,
                             PROJECT_RAW_COST,
                             PROJECT_BURDENED_COST,
                             RAW_COST,
                             BURDENED_COST
                      INTO   l_budget_line_id,
                             l_bl_start_date,
                             l_bl_end_date,
                             l_bl_quantity,
                             l_bl_txn_raw_cost,
                             l_bl_txn_burdened_cost,
                             l_bl_project_raw_cost,
                             l_bl_project_burdened_cost,
                             l_bl_pfc_raw_cost,
                             l_bl_pfc_burdened_cost
                      FROM   PA_BUDGET_LINES BL
                      WHERE  BL.RESOURCE_ASSIGNMENT_ID = l_res_asg_id(i)
                      AND    BL.TXN_CURRENCY_CODE      = l_currency_code(i);
                  END IF; -- Forecast plan check
              END IF; -- time phase check
              l_budget_lines_exist := 'Y';
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  l_budget_lines_exist := 'N';
          END;
          /*dbms_output.put_line('l_budget_lines_exist [' || l_budget_lines_exist || ']');
          dbms_output.put_line('set_of_books_id: '|| p_fp_cols_rec.x_set_of_books_id);
          dbms_output.put_line('l_reference_start_date: '||l_reference_start_date);*/

      END IF; -- l_cost_based_all_from_sp_flag check


      -- We have delayed processing on l_bl_start_date and l_bl_end_date for
      -- the None time phase case to avoid an extra query to pa_budget_lines.
      IF ( P_FP_COLS_REC.X_TIME_PHASED_CODE = 'N' )
      THEN
          -- Since start_date and end_date are both non-null columns in
          -- pa_budget_lines, checking l_bl_start_date is sufficient.
          IF l_bl_start_date IS NOT NULL THEN
              IF l_reference_start_date < l_bl_start_date THEN
                  l_bl_start_date := l_reference_start_date;
              END IF;
              IF l_reference_end_date > l_bl_end_date THEN
                  l_bl_end_date := l_reference_end_date;
              END IF;
          ELSE
              l_bl_start_date := l_reference_start_date;
              l_bl_end_date :=  l_reference_end_date;
          END IF;
      END IF; -- None timephase check


      -- Bug 4549862: For the Cost-based All version from Staffing Plan
      -- flow, Insert commitment data into the PA_FP_ROLLUP_TMP table
      -- instead of pa_budget_lines for further processing by the Cost-
      -- based Revenue Generation API, which will propagate the data to
      -- the budget lines. For all other flows, proceed with existing
      -- logic for Insert/Update to the budget lines.

      IF l_cost_based_all_from_sp_flag = 'Y' THEN

          -- Increment counter to a new unique id
          l_bl_id_counter := l_bl_id_counter + 1;

          -- Get the target task billability flag
          SELECT NVL(billable_flag,'Y') INTO l_billable_flag
          FROM   pa_tasks ta,
                 pa_resource_assignments ra
          WHERE  ra.resource_assignment_id = l_res_asg_id(i)
          AND    ra.task_id = ta.task_id (+);

          INSERT INTO pa_fp_rollup_tmp(
                                 RESOURCE_ASSIGNMENT_ID,
                                 START_DATE,
                                 END_DATE,
                                 PERIOD_NAME,
                                 QUANTITY,
                                 TXN_CURRENCY_CODE,
                                 TXN_RAW_COST,
                                 TXN_BURDENED_COST,
                                 PROJECT_RAW_COST,
                                 PROJECT_BURDENED_COST,
                                 PROJFUNC_RAW_COST,
                                 PROJFUNC_BURDENED_COST,
                                 BUDGET_LINE_ID,
                                 BILLABLE_FLAG )
           VALUES(
                                 l_res_asg_id(i),
                                 l_bl_start_date,
                                 l_bl_end_date,
                                 l_bl_period_name,
                                 l_quantity_sum_tab(i),
                                 l_currency_code(i),
                                 l_raw_cost_sum(i),
                                 l_burdened_cost_sum(i),
                                 l_proj_raw_cost_sum(i),
                                 l_proj_burdened_cost_sum(i),
                                 l_projfunc_raw_cost_sum(i),
                                 l_projfunc_burdened_cost_sum(i),
                                 l_bl_id_counter,
                                 l_billable_flag );

      ELSE -- l_cost_based_all_from_sp_flag = 'N'

          /*====================================================================================+
           | If no budget lines exist for the Resource Assignment Id and the Currency Code,     |
           | Insert fresh Budget Lines.                                                         |
           |                                                                                    |
           | Bug 4251148: Modified this logic. If the Target is GL/PA timephased, we now also   |
           |              check budget line start date when checking for budget line existence. |
           |              If Calculate API call is required, then check the Target time phase:  |
           |       PA/GL: Populate the l_cal_ tables for further processing. In this case, we   |
           |              will call Calculate at the Budget Line level, which requires that     |
           |              we do not have budget lines. Therefore, bypass budget line Insert.    |
           |       None:  Populate the l_cal_ tables with just Resource Assignment Id and the   |
           |              Currency Code (amounts unneccessary). In this case, we will call the  |
           |              Calculate API at the Resource Assignment level with Partial Refresh   |
           |              of Revenue amounts. This requires that we have budget lines populated.|
           |              Therefore, still do the Insert.                                       |
           +====================================================================================*/

          -- Initialize rate overrides and exchange rates
          l_txn_cost_rate_override := NULL;
          l_burden_cost_rate_override := NULL;
          l_proj_cost_exchange_rate := NULL;
          l_projfunc_cost_exchange_rate := NULL;

          IF ( l_budget_lines_exist = 'N' ) THEN
              IF l_calc_api_required_flag = 'Y' AND
                 p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
                  l_index := l_index + 1;
                  l_cal_tgt_res_asg_id_tab(l_index)      := l_res_asg_id(i);
                  l_cal_tgt_rate_based_flag_tab(l_index) := l_rate_based_flag;
                  l_cal_txn_currency_code_tab(l_index)   := l_currency_code(i);
                  l_cal_line_start_date_tab(l_index)     := l_bl_start_date;
                  l_cal_line_end_date_tab(l_index)       := l_bl_end_date;

                  l_cal_cmt_quantity_tab(l_index)  := l_quantity_sum_tab(i);
                  l_cal_cmt_raw_cost_tab(l_index)  := l_raw_cost_sum(i);
                  l_cal_cmt_brdn_cost_tab(l_index) := l_burdened_cost_sum(i);

                  l_cal_base_quantity_tab(l_index)  := 0;
                  l_cal_base_raw_cost_tab(l_index)  := 0;
                  l_cal_base_brdn_cost_tab(l_index) := 0;
              ELSE
                  IF l_calc_api_required_flag = 'Y' AND
                     p_fp_cols_rec.x_time_phased_code = 'N' THEN
                      l_index := l_index + 1;
                      l_cal_tgt_res_asg_id_tab(l_index)      := l_res_asg_id(i);
                      l_cal_txn_currency_code_tab(l_index)   := l_currency_code(i);
                  END IF; -- Calc Required and None Time Phase

                  IF l_quantity_sum_tab(i) <> 0 THEN
                         l_txn_cost_rate_override := l_raw_cost_sum(i) / l_quantity_sum_tab(i);
                         l_burden_cost_rate_override := l_burdened_cost_sum(i) / l_quantity_sum_tab(i);
                  END IF;
                  IF l_raw_cost_sum(i) <> 0 THEN
                         l_proj_cost_exchange_rate := l_proj_raw_cost_sum(i) / l_raw_cost_sum(i);
                         l_projfunc_cost_exchange_rate := l_projfunc_raw_cost_sum(i) / l_raw_cost_sum(i);
                  END IF;

                  INSERT INTO PA_BUDGET_LINES(RESOURCE_ASSIGNMENT_ID,
                                              START_DATE,
                                              END_DATE,
                                              PERIOD_NAME,
                                              TXN_CURRENCY_CODE,
                                              TXN_RAW_COST,
                                              TXN_BURDENED_COST,
                                              PROJECT_RAW_COST,
                                              PROJECT_BURDENED_COST,
                                              RAW_COST,
                                              BURDENED_COST,
                                              QUANTITY,
                                              BUDGET_LINE_ID,
                                              BUDGET_VERSION_ID,
                                              PROJECT_CURRENCY_CODE,
                                              PROJFUNC_CURRENCY_CODE,
                                              LAST_UPDATE_DATE,
                                              LAST_UPDATED_BY,
                                              CREATION_DATE,
                                              CREATED_BY,
                                              LAST_UPDATE_LOGIN,
                                              TXN_COST_RATE_OVERRIDE,
                                              BURDEN_COST_RATE_OVERRIDE,
                                              PROJECT_COST_EXCHANGE_RATE,
                                              PROJFUNC_COST_EXCHANGE_RATE,
                                              PROJECT_COST_RATE_TYPE,
                                              PROJFUNC_COST_RATE_TYPE
                                             )
                                       VALUES(l_res_asg_id(i),
                                              l_bl_start_date,
                                              l_bl_end_date,
                                              l_bl_period_name,
                                              l_currency_code(i),
                                              l_raw_cost_sum(i),
                                              l_burdened_cost_sum(i),
                                              l_proj_raw_cost_sum(i),
                                              l_proj_burdened_cost_sum(i),
                                              l_projfunc_raw_cost_sum(i),
                                              l_projfunc_burdened_cost_sum(i),
                                              l_quantity_sum_tab(i),
                                              pa_budget_lines_s.nextval,
                                              p_budget_version_id,
                                              p_FP_COLS_REC.X_PROJECT_CURRENCY_CODE,
                                              p_FP_COLS_REC.X_PROJFUNC_CURRENCY_CODE,
                                              l_sysdate,
                                              l_last_updated_by,
                                              l_sysdate,
                                              l_last_updated_by,
                                              l_last_update_login,
                                              l_txn_cost_rate_override,
                                              l_burden_cost_rate_override,
                                              l_proj_cost_exchange_rate,
                                              l_projfunc_cost_exchange_rate,
                                              'User',
                                              'User'
                                            );
              END IF; -- l_calc_api_required_flag check

          ELSE --l_budget_lines_exist = 'Y'

          /*====================================================================================+
           | If budget lines exist for the Resource Assignment Id and Currency Code, do Update  |
           |                                                                                    |
           | Bug 4251148: Modified this logic. If the Target is GL/PA timephased, we now also   |
           |              check budget line start date when checking for budget line existence. |
           |              If Calculate API call is required, then check the Target time phase:  |
           |       PA/GL: Populate the l_cal_ tables for further processing. In this case, we   |
           |              will call Calculate at the Budget Line level, which requires that     |
           |              we do not have budget lines. Therefore, Updating the budget line is   |
           |              not needed. In fact, we track all existing budget lines and DELETE    |
           |              them later (before calling Calculate).                                |
           |       None:  Populate the l_cal_ tables with just Resource Assignment Id and the   |
           |              Currency Code (amounts unneccessary). In this case, we will call the  |
           |              Calculate API at the Resource Assignment level with Partial Refresh   |
           |              of Revenue amounts. This requires that we have budget lines populated.|
           |              Therefore, still do the Update.                                       |
           +====================================================================================*/

             ---if the record does exist then update the record in the pa_budget_lines table
             IF l_calc_api_required_flag = 'Y' AND
                p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
                 -- These budget lines will be deleted before calling Calculate
                 bl_index := bl_index + 1;
                 l_budget_line_id_tab(bl_index) := l_budget_line_id;

                 l_index := l_index + 1;
                 l_cal_tgt_res_asg_id_tab(l_index)      := l_res_asg_id(i);
                 l_cal_tgt_rate_based_flag_tab(l_index) := l_rate_based_flag;
                 l_cal_txn_currency_code_tab(l_index)   := l_currency_code(i);
                 l_cal_line_start_date_tab(l_index)     := l_bl_start_date;
                 l_cal_line_end_date_tab(l_index)       := l_bl_end_date;

                 l_cal_cmt_quantity_tab(l_index)  := l_quantity_sum_tab(i);
                 l_cal_cmt_raw_cost_tab(l_index)  := l_raw_cost_sum(i);
                 l_cal_cmt_brdn_cost_tab(l_index) := l_burdened_cost_sum(i);

                 l_cal_base_quantity_tab(l_index) := l_bl_quantity;
                 l_cal_base_raw_cost_tab(l_index) := l_bl_txn_raw_cost;
                 l_cal_base_brdn_cost_tab(l_index) := l_bl_txn_burdened_cost;
             ELSE
                 IF l_calc_api_required_flag = 'Y' AND
                    p_fp_cols_rec.x_time_phased_code = 'N' THEN
                     l_index := l_index + 1;
                     l_cal_tgt_res_asg_id_tab(l_index)      := l_res_asg_id(i);
                     l_cal_txn_currency_code_tab(l_index)   := l_currency_code(i);
                 END IF; -- Calc Required and None Timephase

                 l_upd_quantity              := nvl(l_bl_quantity,0) + l_quantity_sum_tab(i);
                 l_upd_txn_raw_cost          := nvl(l_bl_txn_raw_cost,0) + l_raw_cost_sum(i);
                 l_upd_txn_burdened_cost     := nvl(l_bl_txn_burdened_cost,0) + l_burdened_cost_sum(i);
                 l_upd_project_raw_cost      := nvl(l_bl_project_raw_cost,0) + l_proj_raw_cost_sum(i);
                 l_upd_project_burdened_cost := nvl(l_bl_project_burdened_cost,0) + l_proj_burdened_cost_sum(i);
                 l_upd_pfc_raw_cost          := nvl(l_bl_pfc_raw_cost,0) + l_projfunc_raw_cost_sum(i);
                 l_upd_pfc_burdened_cost     := nvl(l_bl_pfc_burdened_cost,0) + l_projfunc_burdened_cost_sum(i);

                 -- Rate overrides and exchange rates are initially null
                 IF p_fp_cols_rec.x_time_phased_code = 'N' AND
                    p_fp_cols_rec.x_plan_class_code = 'FORECAST' THEN
                     -- In this case, the bl amounts include the actual amounts.
                     -- To compute the rates, we should use (amounts less actuals).
                     IF (l_upd_quantity - l_bl_init_quantity) <> 0 THEN
                         l_txn_cost_rate_override :=
                             (l_upd_txn_raw_cost - l_bl_txn_init_raw_cost) /
                             (l_upd_quantity - l_bl_init_quantity);
                         l_burden_cost_rate_override :=
                             (l_upd_txn_burdened_cost - l_bl_txn_init_burdened_cost) /
                             (l_upd_quantity - l_bl_init_quantity);
                     END IF;
                     IF (l_upd_txn_raw_cost - l_bl_txn_init_raw_cost) <> 0 THEN
                         l_proj_cost_exchange_rate :=
                             (l_upd_project_raw_cost - l_bl_project_init_raw_cost) /
                             (l_upd_txn_raw_cost - l_bl_txn_init_raw_cost);
                         l_projfunc_cost_exchange_rate :=
                             (l_upd_pfc_raw_cost - l_bl_pfc_init_raw_cost) /
                             (l_upd_txn_raw_cost - l_bl_txn_init_raw_cost);
                     END IF;
                 ELSE
                     IF l_upd_quantity <> 0 THEN
                         l_txn_cost_rate_override := l_upd_txn_raw_cost / l_upd_quantity;
                         l_burden_cost_rate_override := l_upd_txn_burdened_cost / l_upd_quantity;
                     END IF;
                     IF l_upd_txn_raw_cost <> 0 THEN
                         l_proj_cost_exchange_rate := l_upd_project_raw_cost / l_upd_txn_raw_cost;
                         l_projfunc_cost_exchange_rate := l_upd_pfc_raw_cost / l_upd_txn_raw_cost;
                     END IF;
                 END IF; -- computation of rates

                /*dbms_output.put_line('Updating bl table');
                dbms_output.put_line('Time phase: '||p_fp_cols_rec.x_time_phased_code);
                dbms_output.put_line('Start_date: '||l_bl_start_date);*/


                 IF p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
                     UPDATE  PA_BUDGET_LINES
                     SET   LAST_UPDATE_DATE        = l_sysdate
                     ,     LAST_UPDATED_BY         = l_last_updated_by
                     ,     LAST_UPDATE_LOGIN       = l_last_update_login
                 --  ,     START_DATE              = l_bl_start_date
                 --  ,     END_DATE                = l_bl_end_date
                     ,     QUANTITY                = l_upd_quantity
                     ,     TXN_RAW_COST            = l_upd_txn_raw_cost
                     ,     TXN_BURDENED_COST       = l_upd_txn_burdened_cost
                     ,     PROJECT_RAW_COST        = l_upd_project_raw_cost
                     ,     PROJECT_BURDENED_COST   = l_upd_project_burdened_cost
                     ,     RAW_COST                = l_upd_pfc_raw_cost
                     ,     BURDENED_COST           = l_upd_pfc_burdened_cost
                     ,     PROJECT_COST_RATE_TYPE  = 'User'
                     ,     PROJFUNC_COST_RATE_TYPE = 'User'
                     ,     txn_cost_rate_override      = l_txn_cost_rate_override
                     ,     burden_cost_rate_override   = l_burden_cost_rate_override
                     ,     project_cost_exchange_rate  = l_proj_cost_exchange_rate
                     ,     projfunc_cost_exchange_rate = l_projfunc_cost_exchange_rate
                     WHERE BUDGET_LINE_ID = l_budget_line_id;
                 ELSIF p_fp_cols_rec.x_time_phased_code = 'N' THEN
                     UPDATE  PA_BUDGET_LINES
                     SET   LAST_UPDATE_DATE        = l_sysdate
                     ,     LAST_UPDATED_BY         = l_last_updated_by
                     ,     LAST_UPDATE_LOGIN       = l_last_update_login
                     ,     START_DATE              = l_bl_start_date
                     ,     END_DATE                = l_bl_end_date
                     ,     QUANTITY                = l_upd_quantity
                     ,     TXN_RAW_COST            = l_upd_txn_raw_cost
                     ,     TXN_BURDENED_COST       = l_upd_txn_burdened_cost
                     ,     PROJECT_RAW_COST        = l_upd_project_raw_cost
                     ,     PROJECT_BURDENED_COST   = l_upd_project_burdened_cost
                     ,     RAW_COST                = l_upd_pfc_raw_cost
                     ,     BURDENED_COST           = l_upd_pfc_burdened_cost
                     ,     PROJECT_COST_RATE_TYPE  = 'User'
                     ,     PROJFUNC_COST_RATE_TYPE = 'User'
                     ,     txn_cost_rate_override      = l_txn_cost_rate_override
                     ,     burden_cost_rate_override   = l_burden_cost_rate_override
                     ,     project_cost_exchange_rate  = l_proj_cost_exchange_rate
                     ,     projfunc_cost_exchange_rate = l_projfunc_cost_exchange_rate
                     WHERE BUDGET_LINE_ID = l_budget_line_id;
                 END IF; -- update

            --dbms_output.put_line('inserted [' || to_char(sql%rowcount) || '] records');

             END IF; -- l_calc_api_required_flag check
         END IF; -- budget line existence check

      END IF; -- l_cost_based_all_from_sp_flag = 'Y' check

  EXCEPTION
      WHEN CONTINUE_LOOP THEN
          l_dummy := 1;
      WHEN OTHERS THEN
          RAISE;
  END; -- continue loop exception block
  END LOOP; -- main loop

    -- Bug 4549862: Now that we have finished the main commitment processing
    -- loop, check if we encountered the rejection code error. If so, all the
    -- error messages have been added to the stack, so we can Raise an error.

    IF l_rejection_code_error_flag = 'Y' THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;


    -- Bug 4549862: Note that no change is required to the
    -- l_calc_api_required_flag = 'Y' code below since the
    -- accrual method is always WORK (and not COST) when
    -- l_calc_api_required_flag is 'Y'.

    IF l_calc_api_required_flag = 'Y' AND
       l_cal_tgt_res_asg_id_tab.count > 0 THEN

        /* Populate Calculate API pl/sql table pameters */
        IF p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN

          /*==========================================================================+
           | Up to this point, we have collected Resource Assignment and Budget Line  |
           | info in the l_cal_ pl/sql tables for budget lines for which we need to   |
           | include Commitment amounts. For a given unique (Resource Assignment Id,  |
           | Txn Curency Code, Budget Line Start Date) combination, we may have more  |
           | than 1 commitment. In this case, we will have multiple records in the    |
           | l_cal_ tables for the combination. To ensure that we only pass 1 record  |
           | per such combination to the Calculate API, we have the following logic:  |
           |   1. Populate PA_FP_ROLLUP_TMP with Commitment Amounts and the l_cal_    |
           |      pl/sql table Index where the amounts came from. We use ROLLUP_ID to |
           |      store the Index value.                                              |
           |   2. Fetch Aggregated Commitment Amounts using Group By.                 |
           |      Earlier, when we populated the l_cal_ tables, we made sure that the |
           |      Base amounts were the same for each (ra_id, currency, start date)   |
           |      combination. So, we use Max(ROLLUP_ID) to get the Index of a l_cal_ |
           |      record that has the Base amounts for the Group.                     |
           |   3. Add Base Amounts to Commitment Sums to get total Amount             |
           |   4. Compute rate override values.
           +==========================================================================*/

            -- Since bulk inserting the loop index variable i is syntactically
            -- not allowed, we populate an index table. This will give us the
            -- indices for entries in the l_cal_ tables.
            FOR i IN 1..l_cal_tgt_res_asg_id_tab.count LOOP
                l_index_tab(i) := i;
            END LOOP;

            -- We need to sort the pl/sql records by (RA id, currency code, start date)
            -- The pa_fp_calc_amt_tmp1 table should be unused now; use it to sort.
            DELETE PA_FP_ROLLUP_TMP;
            FORALL i IN 1..l_cal_tgt_res_asg_id_tab.count
                INSERT INTO PA_FP_ROLLUP_TMP (
                    ROLLUP_ID,                -- l_cal_ table index value
                    RESOURCE_ASSIGNMENT_ID,
                    TXN_CURRENCY_CODE,
                    START_DATE,
                    END_DATE,
		    QUANTITY,
		    TXN_RAW_COST,
		    TXN_BURDENED_COST )
                 VALUES (
                    l_index_tab(i),
                    l_cal_tgt_res_asg_id_tab(i),
                    l_cal_txn_currency_code_tab(i),
                    l_cal_line_start_date_tab(i),
                    l_cal_line_end_date_tab(i),
		    l_cal_cmt_quantity_tab(i),
		    l_cal_cmt_raw_cost_tab(i),
		    l_cal_cmt_brdn_cost_tab(i) );

            l_index_tab.delete;
            -- Aggregate Commitment amounts using Group By
            /* Populate Calculate API pl/sql table parameters with aggregated
             * amounts from l_cal_ commitment pl/sql table records. We do this
             * aggregation so that existing budget line amounts are not double
             * counted in the amounts passed to the Calculate API. */
            SELECT RESOURCE_ASSIGNMENT_ID,
                   TXN_CURRENCY_CODE,
                   START_DATE,
                   max(ROLLUP_ID),            -- l_cal_ table index value
                   max(END_DATE),
		   sum(nvl(QUANTITY,0)),
		   sum(nvl(TXN_RAW_COST,0)),
		   sum(nvl(TXN_BURDENED_COST,0)),
                   NULL,  -- revenue
                   NULL,  -- cost rate override
                   NULL,  -- burden cost rate override
                   NULL   -- bill rate override
            BULK COLLECT
            INTO   l_tgt_res_asg_id_tab,
                   l_txn_currency_code_tab,
                   l_line_start_date_tab,
                   l_index_tab,               -- l_cal_ table index value
                   l_line_end_date_tab,
                   l_src_quantity_tab,
                   l_src_raw_cost_tab,
                   l_src_brdn_cost_tab,
                   l_src_revenue_tab,
                   l_cost_rate_override_tab,
                   l_b_cost_rate_override_tab,
                   l_bill_rate_override_tab
            FROM   PA_FP_ROLLUP_TMP
            GROUP BY  RESOURCE_ASSIGNMENT_ID,
                      TXN_CURRENCY_CODE,
                      START_DATE;

            FOR i IN 1..l_index_tab.count LOOP
                kk := l_index_tab(i);
                l_tgt_rate_based_flag_tab.extend;
                l_tgt_rate_based_flag_tab(i) := l_cal_tgt_rate_based_flag_tab(kk);

                /* Add Base amounts to Commitment sums */
                l_src_quantity_tab(i)  := l_src_quantity_tab(i) +
                                          l_cal_base_quantity_tab(kk);
                l_src_raw_cost_tab(i)  := l_src_raw_cost_tab(i) +
                                          l_cal_base_raw_cost_tab(kk);
                l_src_brdn_cost_tab(i) := l_src_brdn_cost_tab(i) +
                                          l_cal_base_brdn_cost_tab(kk);
            END LOOP;

            /* Compute rate override values now that we have aggregated amounts */
            FOR i IN 1..l_tgt_res_asg_id_tab.count LOOP
                IF l_src_quantity_tab(i) <> 0 THEN
                    l_cost_rate_override_tab(i) := l_src_raw_cost_tab(i) / l_src_quantity_tab(i);
                    l_b_cost_rate_override_tab(i) := l_src_brdn_cost_tab(i) / l_src_quantity_tab(i);
                END IF;
            END LOOP;

        ELSIF p_fp_cols_rec.x_time_phased_code = 'N' THEN

          /*==========================================================================+
           | Up to this point, we have collected Resource Assignment Ids and Currency |
           | Codes for in the l_cal_ pl/sql tables for budget lines for which we need |
           | to include Commitment amounts. For a given unique (Resource Assignment   |
           | Id, Txn Curency Code) pair, we may have more than 1 commitment. In this  |
           | case, we will have duplicate records l_cal_ tables. We should only pass  |
           | 1 record per such pair to the Calculate API. The following logic gets    |
           | distinct records for the pl/sql tables parameters for the Calculate API. |
           |                                                                          |
           | Since we are calling Calculate at the Resource Assignment level with     |
           | Partial Refresh on Revenue, we do not need to pass pl/sql tables with    |
           | amounts and rate overrides as in the case of PA/GL. We just need to pass |
           | one table for Resource Assignment Ids, and one table for Currency Codes. |
           +==========================================================================*/

            -- We need to get distinct (RA id, currency code) pairs.
            -- The pa_fp_rollup_tmp table should be unused now; use it.
            DELETE PA_FP_ROLLUP_TMP;
            FORALL i IN 1..l_cal_tgt_res_asg_id_tab.count
                INSERT INTO PA_FP_ROLLUP_TMP (
                    RESOURCE_ASSIGNMENT_ID,
                    TXN_CURRENCY_CODE )        -- txn_currency_code
                 VALUES (
                    l_cal_tgt_res_asg_id_tab(i),
                    l_cal_txn_currency_code_tab(i) );

            SELECT DISTINCT
                   RESOURCE_ASSIGNMENT_ID,
                   TXN_CURRENCY_CODE
            BULK COLLECT
            INTO   l_tgt_res_asg_id_tab,
                   l_txn_currency_code_tab
            FROM   PA_FP_ROLLUP_TMP;

        END IF; -- population of Calculate API pl/sql tables


       /*=======================================================================+
        | Bug 4582616 Fix Overview                                              |
        | ------------------------                                              |
        | The reported issue is that Source Rates are not being used to compute |
        | ETC Revenue for resources that do not have Uncommitted ETC when:      |
        | C1. the Source for the resource is Financial Plan                     |
        | C2. the Source and Target are both Cost and Revenue Together versions |
        | C3. Source/Target Planning Options match.                             |
        | This is happening because, in the GEN_FCST_TASK_LEVEL_AMT API, we do  |
        | not process resources that do not have Uncommitted ETC. As a result,  |
        | source rates are not populated in PA_FP_GEN_RATE_TMP for the resource |
        | and Calculate derives the revenue using the Target's Rate Schedule.   |
        | The same issue should arise during Budget Generation when C1-C3 hold. |
        |                                                                       |
        | The fix is to populate PA_FP_GEN_RATE_TMP with periodic source rates  |
        | for resources when they do not already exist AND conditions 1-3 hold. |
        | To populate the rates, do the following:                              |
        | 1. Verify version-level conditions C2 and C3                          |
        | 2. Fetch distinct (Source Resource Assignment Id, Target Resource     |
        |    Assignment Id, Txn Currency) triples that:                                    |
        |    A. are billable                                                    |
        |    B. do not have records in pa_fp_gen_rate_tmp for the               |
        |       (Target Resource Assignment Id, Txn Currency) combo.            |
        |    C. have planning resources in the source financial plan (i.e. C1). |
        | 3. For each triple from Step 2, call the POPULATE_GEN_RATE API.       |
        | 4. If l_source_context is 'BUDGET_LINE', null-out the Raw Cost Rate   |
        |    and Burdened Cost Rate columns of PA_FP_GEN_RATE_TMP since we only |
        |    want the Calculate API to compute revenue and honor Revenue Rates. |
        |                                                                       |
        | Note that l_tgt_res_asg_id_tab and l_txn_currency_code_tab contain    |
        | are populated at this point and contain Distinct values.              |
        +=======================================================================*/

        l_fp_src_plan_ver_id := p_fp_cols_rec.x_gen_src_plan_version_id;

        -- Note that l_calc_api_required_flag = 'Y' in the current context.
        -- This guarantees that the Target is a Cost and Revenue Together
        -- version with Revenue Accrual Method as Work.

        IF l_fp_src_plan_ver_id IS NOT NULL AND
           l_gen_src_code IN ('FINANCIAL_PLAN','TASK_LEVEL_SEL') THEN

            -- Get Source Financial Plan Details
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                    P_MSG                   => 'Before calling PA_FP_GEN_AMOUNT_UTILS.'||
                                               'GET_PLAN_VERSION_DTL',
                    P_MODULE_NAME           => l_module_name,
                    P_LOG_LEVEL             => 5);
            END IF;
            PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS(
                    P_PROJECT_ID            => P_PROJECT_ID,
                    P_BUDGET_VERSION_ID     => l_fp_src_plan_ver_id,
                    X_FP_COLS_REC           => l_fp_cols_rec_src_finplan,
                    X_RETURN_STATUS         => x_return_status,
                    X_MSG_COUNT             => x_msg_count,
                    X_MSG_DATA              => x_msg_data);
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                    P_MSG                   => 'After calling PA_FP_GEN_AMOUNT_UTILS.'||
                                               'GET_PLAN_VERSION_DTL:'||x_return_status,
                    P_MODULE_NAME           => l_module_name,
                    P_LOG_LEVEL             => 5);
            END IF;
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            -- Bug 4582616 Step 1: Verify C2 - that the Source and Target are
            -- both Cost and Revenue Together versions. We already know that
            -- the Target version is 'ALL' since l_calc_api_required_flag = 'Y'.
            -- So, just check the Source version.

            IF l_fp_cols_rec_src_finplan.x_version_type = 'ALL' THEN

                -- Get Planning Options Flag for Source Financial Plan
                IF P_PA_DEBUG_MODE = 'Y' THEN
                    PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                        P_MSG         => 'Before calling PA_FP_FCST_GEN_AMT_UTILS.'||
                                         'COMPARE_ETC_SRC_TARGET_FP_OPT',
                        P_MODULE_NAME => l_module_name,
                        P_LOG_LEVEL   => 5);
                END IF;
                PA_FP_FCST_GEN_AMT_UTILS.COMPARE_ETC_SRC_TARGET_FP_OPT
                      (P_PROJECT_ID                     => P_PROJECT_ID,
                       P_WP_SRC_PLAN_VER_ID             => null,
                       P_FP_SRC_PLAN_VER_ID             => l_fp_src_plan_ver_id,
                       P_FP_TARGET_PLAN_VER_ID          => P_BUDGET_VERSION_ID,
                       X_SAME_PLANNING_OPTION_FLAG      => l_fp_planning_options_flag,
                       X_RETURN_STATUS                  => X_RETURN_STATUS,
                       X_MSG_COUNT                      => X_MSG_COUNT,
                       X_MSG_DATA                       => X_MSG_DATA);
                IF P_PA_DEBUG_MODE = 'Y' THEN
                    PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                        P_MSG         => 'After calling PA_FP_FCST_GEN_AMT_UTILS.'||
                                         'COMPARE_ETC_SRC_TARGET_FP_OPT:'||
                                         l_fp_planning_options_flag,
                        P_MODULE_NAME => l_module_name,
                        P_LOG_LEVEL   => 5);
                END IF;
                IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

                -- Bug 4582616 Step 1 (continued): Verify C3 - that the Source /
                -- Target Planning Options match.

                IF l_fp_planning_options_flag = 'Y' THEN

                    -- Bug 4582616 Step 2: Fetch distinct (Source Resource Assignment
                    -- Id, Target Resource Assignment Id, Txn Currency) triples that:
                    -- A. are billable
                    -- B. do not have records in pa_fp_gen_rate_tmp for the
                    --    (Target Resource Assignment Id, Txn Currency) combo.
                    -- C. have planning resources in the source financial plan.
                    -- The pa_fp_rollup_tmp table should be unused now, so use it
                    -- to do the above processing logic in bulk.

                    DELETE PA_FP_ROLLUP_TMP;
                    FORALL i IN 1..l_tgt_res_asg_id_tab.count
                        INSERT INTO PA_FP_ROLLUP_TMP (
                            RESOURCE_ASSIGNMENT_ID,
                            TXN_CURRENCY_CODE )
                         VALUES (
                            l_tgt_res_asg_id_tab(i),
                            l_txn_currency_code_tab(i) );

                    -- The correctness of the following SELECT statements relies
                    -- heavily on the current context - in particular, the Source
                    -- version is a Financial Plan and the Source/Target Planning
                    -- Options match (i.e. there is a 1-to-1 mapping from Source
                    -- to Target resources).

                    IF l_calling_context = lc_BudgetGeneration THEN

                        SELECT src_ra.RESOURCE_ASSIGNMENT_ID,
                               tgt_ra.RESOURCE_ASSIGNMENT_ID,
                               cmt.TXN_CURRENCY_CODE
                        BULK COLLECT
                        INTO   l_sr_src_ra_id_tab,
                               l_sr_tgt_ra_id_tab,
                               l_sr_txn_currency_code_tab
                        FROM   pa_resource_assignments src_ra,
                               pa_resource_assignments tgt_ra,
                               pa_tasks ta,
                               pa_fp_rollup_tmp cmt
                        WHERE  tgt_ra.resource_assignment_id = cmt.resource_assignment_id
                        AND    ta.task_id (+) = NVL(tgt_ra.task_id,0) -- A. check billability
                        AND    NVL(ta.billable_flag,'Y') = 'Y'        -- A. check billability
                        AND    src_ra.task_id = tgt_ra.task_id
                        AND    src_ra.resource_list_member_id = tgt_ra.resource_list_member_id
                        AND    tgt_ra.budget_version_id = p_budget_version_id
                        AND    src_ra.budget_version_id = l_fp_src_plan_ver_id
                        AND    tgt_ra.project_id = p_project_id
                        AND    src_ra.project_id = p_project_id
                        AND NOT EXISTS ( SELECT null -- B. check for existing gen_tmp records
                                         FROM   pa_fp_gen_rate_tmp gen_tmp
                                         WHERE  gen_tmp.TARGET_RES_ASG_ID = tgt_ra.resource_assignment_id
                                         AND    gen_tmp.txn_currency_code = cmt.txn_currency_code );

                    ELSIF l_calling_context = lc_ForecastGeneration THEN

                        SELECT tmp1.RESOURCE_ASSIGNMENT_ID,
                               tmp1.TARGET_RES_ASG_ID,
                               cmt.TXN_CURRENCY_CODE
                        BULK COLLECT
                        INTO   l_sr_src_ra_id_tab,
                               l_sr_tgt_ra_id_tab,
                               l_sr_txn_currency_code_tab
                        FROM   pa_fp_calc_amt_tmp1 tmp1,
                               pa_tasks ta,
                               pa_fp_rollup_tmp cmt
                        WHERE  tmp1.transaction_source_code = 'FINANCIAL_PLAN' -- C. check finplan
                        AND    tmp1.target_res_asg_id = cmt.resource_assignment_id
                        AND    ta.task_id (+) = NVL(tmp1.task_id,0) -- A. check billability
                        AND    NVL(ta.billable_flag,'Y') = 'Y'      -- A. check billability
                        AND NOT EXISTS ( SELECT null -- B. check for existing gen_tmp records
                                         FROM   pa_fp_gen_rate_tmp gen_tmp
                                         WHERE  gen_tmp.target_res_asg_id = tmp1.target_res_asg_id
                                         AND    gen_tmp.txn_currency_code = cmt.txn_currency_code );

                    END IF; -- l_calling_context check

                    -- Bug 4582616 Step 3: Populate PA_FP_GEN_RATE_TMP with missing
                    -- Periodic Source Rates.

                    FOR i IN 1..l_sr_src_ra_id_tab.count LOOP

                        IF P_PA_DEBUG_MODE = 'Y' THEN
                            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                                P_MSG           =>
                                'Before calling PA_FP_GEN_FCST_AMT_PUB1.POPULATE_GEN_RATE',
                                P_MODULE_NAME   => l_module_name,
                                P_LOG_LEVEL     => 5);
                        END IF;
                        PA_FP_GEN_FCST_AMT_PUB1.POPULATE_GEN_RATE
                           (P_SOURCE_RES_ASG_ID => l_sr_src_ra_id_tab(i),
                            P_TARGET_RES_ASG_ID => l_sr_tgt_ra_id_tab(i),
                            P_TXN_CURRENCY_CODE => l_sr_txn_currency_code_tab(i),
                            X_RETURN_STATUS     => x_return_status,
                            X_MSG_COUNT         => x_msg_count,
                            X_MSG_DATA          => x_msg_data);
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                                P_MSG           =>
                                'After calling PA_FP_GEN_FCST_AMT_PUB1.POPULATE_GEN_RATE: '||x_return_status,
                                P_MODULE_NAME   => l_module_name,
                                P_LOG_LEVEL     => 5);
                        END IF;
                        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                        END IF;

                    END LOOP; -- FOR i IN 1..l_sr_src_ra_id_tab.count LOOP

                END IF; -- l_fp_planning_options_flag = 'Y'

            END IF; -- l_fp_cols_rec_src_finplan.x_version_type = 'ALL'

        END IF; -- l_fp_src_plan_ver_id IS NOT NULL AND
                -- l_gen_src_code IN ('FINANCIAL_PLAN','TASK_LEVEL_SEL')

        /* End of Bug Fix 4582616 Steps 1-3 */


        -- Bug 4320171: As part of the changes for this bug:
        -- Initialize unused Calculate API parameter tables with NULLs
        FOR i in 1 .. l_tgt_res_asg_id_tab.count LOOP
            l_raw_cost_rate_tab.extend;
            l_b_cost_rate_tab.extend;
            l_bill_rate_tab.extend;

            l_raw_cost_rate_tab(i)          :=  Null;
            l_b_cost_rate_tab(i)            :=  Null;
            l_bill_rate_tab(i)              :=  Null;
        END LOOP;
        IF p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
            -- Bug 5073259: Due to changes in the Calculate API, quantity
            -- and rates are ignored for non-rate-based resources. Instead
            -- of nulling out amount tables, do nothing here.
            l_dummy := 1;
            /*********** COMMENTED OUT ******************
            FOR i in 1 .. l_tgt_res_asg_id_tab.count LOOP
	        l_src_raw_cost_tab(i) := null;
	        l_src_brdn_cost_tab(i) := null;
            END LOOP;
            ************ END COMMENTING *****************/
        ELSIF p_fp_cols_rec.x_time_phased_code = 'N' THEN
            FOR i in 1 .. l_tgt_res_asg_id_tab.count LOOP
		l_src_quantity_tab.extend;
		l_src_raw_cost_tab.extend;
		l_src_brdn_cost_tab.extend;
		l_src_revenue_tab.extend;
		l_cost_rate_override_tab.extend;
		l_b_cost_rate_override_tab.extend;
		l_bill_rate_override_tab.extend;
		l_line_start_date_tab.extend;
		l_line_end_date_tab.extend;

		l_src_quantity_tab(i) := null;
		l_src_raw_cost_tab(i) := null;
		l_src_brdn_cost_tab(i) := null;
		l_src_revenue_tab(i) := null;
		l_cost_rate_override_tab(i) := null;
		l_b_cost_rate_override_tab(i) := null;
		l_bill_rate_override_tab(i) := null;
		l_line_start_date_tab(i) := null;
		l_line_end_date_tab(i) := null;
            END LOOP;
        END IF;

        -- Bug 4549862: Moved initialization of l_calling_context
        -- from here to the beginning of the API.

        -- Set default values for Calculate API flag parameters
        l_refresh_rates_flag       := 'N';
        l_refresh_conv_rates_flag  := 'N';
        l_spread_required_flag     := 'N';
        l_rollup_required_flag     := 'N';
        l_raTxn_rollup_api_call_flag := 'N'; -- Added for IPM new entity ER


        IF p_fp_cols_rec.x_time_phased_code = 'N' THEN
            l_source_context := 'RESOURCE_ASSIGNMENT';
            l_refresh_rates_flag  := 'R';
        ELSE
            l_source_context := 'BUDGET_LINE';

            -- Since the source context is Budget Line, before calling the Calculate
            -- API, we need to delete existing budget lines for which we need to
            -- populate Commitment amounts.
            FORALL i IN 1.. l_budget_line_id_tab.count
                DELETE FROM PA_BUDGET_LINES
                WHERE budget_line_id = l_budget_line_id_tab(i);

            -- Bug 4582616 Step 4: Delete Raw Cost and Burdened Cost Rates from
            -- the PA_FP_GEN_RATE_TMP table since we only want the Calculate API
            -- to compute revenue and honor Revenue Rates. This Update is not
            -- necessary when the Target is None timephased because Calculate
            -- should ignore the cost rates when l_refresh_rates_flag is 'R'.

            UPDATE pa_fp_gen_rate_tmp
            SET    raw_cost_rate = null,
                   burdened_cost_rate = null;

        END IF; -- None time phase check

        --hr_utility.trace('bef calling calculate api:'||x_return_status);
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
                           p_budget_version_id             => P_BUDGET_VERSION_ID,
                           p_refresh_rates_flag            => l_refresh_rates_flag,
                           p_refresh_conv_rates_flag       => l_refresh_conv_rates_flag,
                           p_spread_required_flag          => l_spread_required_flag,
                           p_rollup_required_flag          => l_rollup_required_flag,
                           p_source_context                => l_source_context,
                           p_resource_assignment_tab       => l_tgt_res_asg_id_tab,
                           p_txn_currency_code_tab         => l_txn_currency_code_tab,
                           p_total_qty_tab                 => l_src_quantity_tab,
                           p_total_raw_cost_tab            => l_src_raw_cost_tab,
                           p_total_burdened_cost_tab       => l_src_brdn_cost_tab,
                           p_total_revenue_tab             => l_src_revenue_tab,
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
                 (p_msg         => 'Status after calling
                                  PA_FP_CALC_PLAN_PKG.calculate: '
                                  ||x_return_status,
                  p_module_name => l_module_name,
                  p_log_level   => 5);
        END IF;
        IF x_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

    END IF; -- l_calc_api_required_flag check

    IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.Reset_Curr_Function;
    END IF;

 EXCEPTION
  WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
      -- Bug Fix: 4569365. Removed MRC code.
      -- PA_MRC_FINPLAN.G_CALLING_MODULE := Null;
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE
                  ,p_msg_index      => 1
                  ,p_msg_count      => l_msg_count
                  ,p_msg_data       => l_msg_data
                  ,p_data           => l_data
                  ,p_msg_index_out  => l_msg_index_out);
           x_msg_data := l_data;
           x_msg_count := l_msg_count;
      ELSE
          x_msg_count := l_msg_count;
      END IF;
      ROLLBACK;

      x_return_status := FND_API.G_RET_STS_ERROR;

      IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.Reset_Curr_Function;
      END IF;

      RAISE;

    WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      := SUBSTR(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_COMMITMENT_AMOUNTS'
              ,p_procedure_name => 'GEN_COMMITMENT_AMOUNTS');

     IF P_PA_DEBUG_MODE = 'Y' THEN
         PA_DEBUG.Reset_Curr_Function;
     END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

 END GEN_COMMITMENT_AMOUNTS;

END PA_FP_GEN_COMMITMENT_AMOUNTS;

/
