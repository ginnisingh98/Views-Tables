--------------------------------------------------------
--  DDL for Package Body PA_FP_COMMITMENT_AMOUNTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_COMMITMENT_AMOUNTS" as
/* $Header: PAFPCMTB.pls 120.3 2006/01/13 18:29:51 dkuo noship $ */

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE GET_COMMITMENT_AMTS
          (P_PROJECT_ID                     IN              PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID 	            IN              PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC                    IN              PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           PX_GEN_RES_ASG_ID_TAB            IN OUT          NOCOPY PA_PLSQL_DATATYPES.IdTabTyp, --File.Sql.39 bug 4440895
           PX_DELETED_RES_ASG_ID_TAB        IN OUT          NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,   --File.Sql.39 bug 4440895
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
        ,TMP.TXN_TASK_ID
        ,TMP.RESOURCE_LIST_MEMBER_ID
        ,DECODE(c_multi_curr_flag, 'Y',
                CT.DENOM_CURRENCY_CODE,
                CT.PROJECT_CURRENCY_CODE) currency_code
        ,MAX(P.planning_start_date) planning_start_date
        ,MAX(P.planning_end_date)   planning_end_date
        ,MIN(NVL(CT.CMT_NEED_BY_DATE,CT.EXPENDITURE_ITEM_DATE))
        ,MAX(NVL(CT.CMT_NEED_BY_DATE,CT.EXPENDITURE_ITEM_DATE))
        ,SUM(DECODE(c_multi_curr_flag, 'Y',
                    CT.DENOM_RAW_COST,
                    CT.PROJ_RAW_COST)) tot_raw_cost
        ,SUM(DECODE(c_multi_curr_flag, 'Y',
                    CT.DENOM_BURDENED_COST,
                    CT.PROJ_BURDENED_COST)) tot_burdened_cost
        ,SUM(CT.proj_raw_cost)
        ,SUM(CT.proj_burdened_cost)
        ,SUM(CT.acct_raw_cost)
        ,SUM(CT.acct_burdened_cost)
        ,SUM(NVL(CT.TOT_CMT_QUANTITY,
             DECODE(c_multi_curr_flag, 'Y',
                    CT.DENOM_RAW_COST,
                    CT.PROJ_RAW_COST)) ) tot_quantity
FROM     PA_COMMITMENT_TXNS CT,
         PA_RES_LIST_MAP_TMP4 TMP,
         PA_RESOURCE_ASSIGNMENTS P
WHERE    TMP.TXN_SOURCE_ID         = CT.CMT_LINE_ID
AND      CT.PROJECT_ID             = P_PROJECT_ID
AND      NVL(CT.generation_error_flag,'N') = 'N'
AND      P.RESOURCE_ASSIGNMENT_ID  = TMP.TXN_RESOURCE_ASSIGNMENT_ID
AND      P.BUDGET_VERSION_ID       = P_BUDGET_VERSION_ID
GROUP BY P.RESOURCE_ASSIGNMENT_ID,
         TMP.TXN_TASK_ID
        ,TMP.RESOURCE_LIST_MEMBER_ID
        ,DECODE(c_multi_curr_flag, 'Y',
                CT.DENOM_CURRENCY_CODE,
                CT.PROJECT_CURRENCY_CODE);


l_res_asg_id                PA_PLSQL_DATATYPES.IdTabTyp;
l_currency_code             PA_PLSQL_DATATYPES.Char15TabTyp;
l_tphase                    PA_PLSQL_DATATYPES.Char30TabTyp;
l_exp_itm_date              PA_PLSQL_DATATYPES.DateTabTyp;
l_commstart_date            PA_PLSQL_DATATYPES.DateTabTyp;
l_commend_date              PA_PLSQL_DATATYPES.DateTabTyp;
l_ra_start_date             PA_PLSQL_DATATYPES.DateTabTyp;
l_ra_end_date               PA_PLSQL_DATATYPES.DateTabTyp;
l_raw_cost_sum              PA_PLSQL_DATATYPES.NumTabTyp;
l_burdened_cost_sum         PA_PLSQL_DATATYPES.NumTabTyp;
l_pc_raw_cost_sum           PA_PLSQL_DATATYPES.NumTabTyp;
l_pc_burdened_cost_sum      PA_PLSQL_DATATYPES.NumTabTyp;
l_pfc_raw_cost_sum          PA_PLSQL_DATATYPES.NumTabTyp;
l_pfc_burdened_cost_sum     PA_PLSQL_DATATYPES.NumTabTyp;
l_quantity_sum_tab          PA_PLSQL_DATATYPES.NumTabTyp;
l_DELETED_RES_ASG_ID_TAB    PA_PLSQL_DATATYPES.IdTabTyp;
l_bl_raw_cost_sum_tab       PA_PLSQL_DATATYPES.NumTabTyp;
l_bl_burden_cost_sum_tab    PA_PLSQL_DATATYPES.NumTabTyp;
l_bl_quantity_sum_tab       PA_PLSQL_DATATYPES.NumTabTyp;
l_unit_of_measure_tab       PA_PLSQL_DATATYPES.Char30TabTyp;

l_budget_line_id            PA_BUDGET_LINES.BUDGET_LINE_ID%TYPE;
l_budget_line_id_tmp        PA_BUDGET_LINES.BUDGET_LINE_ID%TYPE;
l_qty_tmp                   NUMBER:= 0;
l_upd_count                 NUMBER:= 0;
l_bl_cmt_raw_diff           NUMBER:= 0;
l_bl_cmt_burden_diff        NUMBER:= 0;
l_bl_cmt_quantity_diff      NUMBER:= 0;

l_txn_cost_rate_override    PA_BUDGET_LINES.TXN_COST_RATE_OVERRIDE%TYPE;
l_burden_cost_rate_override PA_BUDGET_LINES.BURDEN_COST_RATE_OVERRIDE%TYPE;

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
l_msg_index_out             NUMBER := 0;

l_res_assgn_id_tab          PA_PLSQL_DATATYPES.IdTabTyp;
l_rlm_id_tab                PA_PLSQL_DATATYPES.IdTabTyp;

l_gen_res_asg_id_tab        PA_PLSQL_DATATYPES.IdTabTyp;
l_chk_duplicate_flag        VARCHAR2(1) := 'N';

l_resource_class_id         PA_RESOURCE_CLASSES_B.RESOURCE_CLASS_ID%TYPE;

l_txn_currency_code_tab       SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();
l_txn_currency_override_tab   SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();
l_total_raw_cost_tab          SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_total_burdened_cost_tab     SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_total_quantity_tab          SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_total_revenue_tab           SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_raw_cost_rate_tab           SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_b_cost_rate_tab             SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_rw_cost_rate_override_tab   SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_b_cost_rate_override_tab    SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_line_start_date_tab         SYSTEM.pa_date_tbl_type:=SYSTEM.pa_date_tbl_type();
l_line_end_date_tab           SYSTEM.pa_date_tbl_type:=SYSTEM.pa_date_tbl_type();
l_resource_assignment_id_tab  SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_spread_amts_flag_tab        SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
l_delete_budget_lines_tab     SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();

l_bl_start_date             DATE;
l_bl_end_date               DATE;
l_bl_period_name            PA_PERIODS_ALL.PERIOD_NAME%TYPE;
l_etc_start_date            DATE;
l_reference_start_date      DATE;

l_count1                    NUMBER;
l_date                      DATE;
l_burden_rate               NUMBER;
l_burden_override_rate      NUMBER;
l_task_id_tab               PA_PLSQL_DATATYPES.IdTabTyp;
l_res_list_mem_id_tab       PA_PLSQL_DATATYPES.IdTabTyp;

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

l_tmp4   Number := 0;

BEGIN
    X_MSG_COUNT := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF p_pa_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function     => 'GEN_COMMITMENT_AMOUNTS'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
    END IF;

   l_stru_sharing_code := PA_PROJECT_STRUCTURE_UTILS.get_Structure_sharing_code(P_PROJECT_ID=> P_PROJECT_ID);

   DELETE FROM PA_RES_LIST_MAP_TMP1;

   SELECT   RESOURCE_CLASS_ID
   INTO     l_resource_class_id
   FROM     PA_RESOURCE_CLASSES_B
   WHERE    RESOURCE_CLASS_CODE = 'FINANCIAL_ELEMENTS';

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

   IF l_TXN_SOURCE_ID_tab.count = 0 THEN
      IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.Reset_Curr_Function;
      END IF;
      RETURN;
   END IF;
   --dbms_output.put_line('l_TXN_SOURCE_ID_tab.count: '||l_TXN_SOURCE_ID_tab.count);
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

    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;
   --dbms_output.put_line('l_map_rlm_id_tab.count: '||l_map_rlm_id_tab.count);

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

 --dbms_output.put_line('Return status after calling PA_FP_GEN_BUDGET_AMT_PUB.CREATE_RES_ASG: '||X_RETURN_STATUS);
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
 --dbms_output.put_line('Return status after calling PA_FP_GEN_BUDGET_AMT_PUB.UPDATE_RES_ASG: '||X_RETURN_STATUS);
       IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling pa_fp_gen_budget_amt_pub.update_res_asg'
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
       END IF;

   l_appl_id := PA_PERIOD_PROCESS_PKG.Application_id;
   OPEN     SUM_COMM_CRSR(P_FP_COLS_REC.X_TIME_PHASED_CODE,
                          P_FP_COLS_REC.X_PLAN_IN_MULTI_CURR_FLAG,
                          l_appl_id,
                          P_FP_COLS_REC.X_SET_OF_BOOKS_ID,
                          P_FP_COLS_REC.X_ORG_ID);
   FETCH    SUM_COMM_CRSR
   BULK     COLLECT
   INTO     l_res_asg_id
           ,l_task_id_tab
           ,l_res_list_mem_id_tab
           ,l_currency_code
           ,l_ra_start_date
           ,l_ra_end_date
           ,l_commstart_date
           ,l_commend_date
           ,l_raw_cost_sum
           ,l_burdened_cost_sum
           ,l_pc_raw_cost_sum
           ,l_pc_burdened_cost_sum
           ,l_pfc_raw_cost_sum
           ,l_pfc_burdened_cost_sum
           ,l_quantity_sum_tab;
           --,l_unit_of_measure_tab;
   CLOSE SUM_COMM_CRSR;
 --dbms_output.put_line('l_res_asg_id.count: '||l_res_asg_id.count);

      --SELECT   count(*) INTO l_tmp4
      --FROM     PA_RES_LIST_MAP_TMP4;

      --dbms_output.put_line('res_map_Tmp4 table count: '|| l_tmp4);

          INSERT INTO PA_FP_CALC_AMT_TMP1(
                      RESOURCE_ASSIGNMENT_ID,
                      BUDGET_VERSION_ID,
                      PROJECT_ID,
                      TASK_ID,
                      RESOURCE_LIST_MEMBER_ID,
                      UNIT_OF_MEASURE,
                      PLANNING_START_DATE,
                      PLANNING_END_DATE,
                      FC_RES_TYPE_CODE,
                      RESOURCE_CLASS_CODE,
                      ORGANIZATION_ID,
                      JOB_ID,
                      PERSON_ID,
                      EXPENDITURE_TYPE,
                      EXPENDITURE_CATEGORY,
                      EVENT_TYPE,
                      PROJECT_ROLE_ID,
                      PERSON_TYPE_CODE,
                      NON_LABOR_RESOURCE,
                      BOM_RESOURCE_ID,
                      INVENTORY_ITEM_ID,
                      ITEM_CATEGORY_ID,
                      TRANSACTION_SOURCE_CODE,
                      MFC_COST_TYPE_ID,
                      INCURRED_BY_RES_FLAG,
                      RATE_BASED_FLAG,
                      NAMED_ROLE,
                      ETC_METHOD_CODE,
                      TARGET_RLM_ID,
                      MAPPED_FIN_TASK_ID)
         SELECT       /*+ leading(tmp4) */  -- SQL Repository Bug 4884824; SQL ID 14901250.
                      TMP4.TXN_RESOURCE_ASSIGNMENT_ID,
                      TMP4.TXN_BUDGET_VERSION_ID,
                      TMP4.TXN_PROJECT_ID,
                      TMP4.TXN_TASK_ID,
                      TMP4.RESOURCE_LIST_MEMBER_ID,
                      CT.UNIT_OF_MEASURE,
                      TMP4.TXN_PLANNING_START_DATE,
                      TMP4.TXN_PLANNING_END_DATE,
                      TMP4.FC_RES_TYPE_CODE,
                      TMP4.RESOURCE_CLASS_CODE,
                      TMP4.ORGANIZATION_ID,
                      TMP4.JOB_ID,
                      TMP4.PERSON_ID,
                      TMP4.EXPENDITURE_TYPE,
                      TMP4.EXPENDITURE_CATEGORY,
                      TMP4.EVENT_TYPE,
                      TMP4.PROJECT_ROLE_ID,
                      TMP4.PERSON_TYPE_CODE,
                      TMP4.NON_LABOR_RESOURCE,
                      TMP4.BOM_RESOURCE_ID,
                      TMP4.INVENTORY_ITEM_ID,
                      TMP4.ITEM_CATEGORY_ID,
                      'OPEN_COMMITMENTS',
                      TMP4.MFC_COST_TYPE_ID,
                      TMP4.INCURRED_BY_RES_FLAG,
                      TMP4.TXN_RATE_BASED_FLAG,
                      TMP4.NAMED_ROLE,
                      TMP4.TXN_ETC_METHOD_CODE,
                      TMP4.RESOURCE_LIST_MEMBER_ID,
                      TMP4.TXN_TASK_ID
          FROM        PA_RES_LIST_MAP_TMP4 TMP4, PA_COMMITMENT_TXNS CT
          WHERE       CT.CMT_LINE_ID        = TMP4.TXN_SOURCE_ID;

          --dbms_output.put_line('calc_tmp1 table count: '||sql%rowcount);

          FORALL i IN 1..l_res_asg_id.count
                    INSERT INTO PA_FP_CALC_AMT_TMP2(
                                     TARGET_RES_ASG_ID
                                   , TXN_CURRENCY_CODE
                                   , TOTAL_PLAN_QUANTITY
                                   , TOTAL_TXN_RAW_COST
                                   , TOTAL_TXN_BURDENED_COST
                                   , TOTAL_PC_RAW_COST
                                   , TOTAL_PC_BURDENED_COST
                                   , TOTAL_PFC_RAW_COST
                                   , TOTAL_PFC_BURDENED_COST
                                   --, TARGET_RES_ASG_ID
                                   ,TRANSACTION_SOURCE_CODE
                                   )
                               VALUES(l_res_asg_id(i),
                                      l_currency_code(i),
                                      l_quantity_sum_tab(i),
                                      l_raw_cost_sum(i),
                                      l_burdened_cost_sum(i),
                                      l_pc_raw_cost_sum(i),
                                      l_pc_burdened_cost_sum(i),
                                      l_pfc_raw_cost_sum(i),
                                      l_pfc_burdened_cost_sum(i),
                                      'OPEN_COMMITMENTS'
                                    );
          --dbms_output.put_line('calc_tmp2 table count: '||sql%rowcount);

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
      RAISE;

    WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      := SUBSTR(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_COMMITMENT_AMOUNTS'
              ,p_procedure_name => 'GEN_COMMITMENT_AMOUNTS');
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

 END GET_COMMITMENT_AMTS;

END PA_FP_COMMITMENT_AMOUNTS;

/
