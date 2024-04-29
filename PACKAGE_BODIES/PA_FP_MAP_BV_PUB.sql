--------------------------------------------------------
--  DDL for Package Body PA_FP_MAP_BV_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_MAP_BV_PUB" as
/* $Header: PAFPMBTB.pls 120.0 2005/05/29 19:14:08 appldev noship $ */
P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE  GEN_MAP_BV_TO_TARGET_RL
          (P_SOURCE_BV_ID 	       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_TARGET_FP_COLS_REC        IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_ETC_FP_COLS_REC           IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_CB_FP_COLS_REC            IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_COMMIT_FLAG               IN          VARCHAR2,
           P_INIT_MSG_FLAG             IN          VARCHAR2,
           P_ACTUAL_THRU_DATE       IN            PA_PERIODS_ALL.END_DATE%TYPE,
           X_RETURN_STATUS             OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT                 OUT  NOCOPY NUMBER,
           X_MSG_DATA	               OUT  NOCOPY VARCHAR2) IS

l_module_name         VARCHAR2(200) := 'pa.plsql.pa_fp_map_bv_pub.gen_map_bv_to_target_rl';

CURSOR txn_sum_csr(c_project_currency_code PA_BUDGET_LINES.PROJECT_CURRENCY_CODE%TYPE,
                   c_multi_curr_flag PA_PROJ_FP_OPTIONS.PLAN_IN_MULTI_CURR_FLAG%TYPE)IS
SELECT  /*+ INDEX(t3,PA_FP_CALC_AMT_TMP3_N2)*/
        t3.res_list_member_id,
        ra.task_id,
        decode(c_multi_curr_flag,'Y',bl.txn_currency_code,
               'N',c_project_currency_code),
        sum(bl.quantity),
        sum(decode(c_multi_curr_flag,'Y',bl.txn_raw_cost,
                                     'N',bl.project_raw_cost)),
        sum(decode(c_multi_curr_flag,'Y',bl.txn_burdened_cost,
                                     'N',bl.project_burdened_cost)),
        sum(decode(c_multi_curr_flag,'Y',bl.txn_revenue,
                                     'N',bl.project_revenue)),
        sum(bl.project_raw_cost),
        sum(bl.project_burdened_cost),
        sum(bl.project_revenue),
        sum(bl.raw_cost),
        sum(bl.burdened_cost),
        sum(bl.revenue)
FROM    pa_resource_assignments ra,
        pa_budget_lines bl,
        pa_fp_calc_amt_tmp3 t3
WHERE   ra.resource_assignment_id = bl.resource_assignment_id
AND     ra.resource_assignment_id = t3.res_asg_id
AND     ra.budget_version_id      = p_source_bv_id
AND     bl.end_date <= nvl(p_actual_thru_date,bl.end_date)
and     bl.cost_rejection_code is null
and     bl.revenue_rejection_code is null
and     bl.burden_rejection_code is null
and     bl.other_rejection_code is null
and     bl.pc_cur_conv_rejection_code is null
and     bl.pfc_cur_conv_rejection_code is null
GROUP   BY
        t3.res_list_member_id,
        ra.task_id,
        decode(c_multi_curr_flag,'Y',bl.txn_currency_code,
               'N',c_project_currency_code);

l_txn_currency_code_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
l_rlm_id_tab                     PA_PLSQL_DATATYPES.IdTabTyp;
l_task_id_tab                    PA_PLSQL_DATATYPES.IdTabTyp;
l_qty_tab                        PA_PLSQL_DATATYPES.NumTabTyp;
l_txn_raw_cost_sum_tab           PA_PLSQL_DATATYPES.NumTabTyp;
l_txn_burdend_cost_sum_tab       PA_PLSQL_DATATYPES.NumTabTyp;
l_txn_revenue_sum_tab            PA_PLSQL_DATATYPES.NumTabTyp;
l_pc_raw_cost_sum_tab            PA_PLSQL_DATATYPES.NumTabTyp;
l_pc_burdend_cost_sum_tab        PA_PLSQL_DATATYPES.NumTabTyp;
l_pc_revenue_sum_tab             PA_PLSQL_DATATYPES.NumTabTyp;
l_pfc_raw_cost_sum_tab            PA_PLSQL_DATATYPES.NumTabTyp;
l_pfc_burdend_cost_sum_tab        PA_PLSQL_DATATYPES.NumTabTyp;
l_pfc_revenue_sum_tab             PA_PLSQL_DATATYPES.NumTabTyp;


/* Local variable to call the pa_rlmi_rbs_map_pub.map_rlmi_rbs api */
l_rbs_version_id			Number;
l_calling_process			Varchar2(30);
l_calling_context			varchar2(30);
l_process_code				varchar2(30);
l_calling_mode				Varchar2(30);
l_init_msg_list_flag			Varchar2(1);
l_commit_flag				Varchar2(1);
l_TXN_SOURCE_ID_tab              PA_PLSQL_DATATYPES.IdTabTyp;
l_TXN_SOURCE_TYPE_CODE_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
l_PERSON_ID_tab                  PA_PLSQL_DATATYPES.IdTabTyp;
l_JOB_ID_tab                     PA_PLSQL_DATATYPES.IdTabTyp;
l_ORGANIZATION_ID_tab            PA_PLSQL_DATATYPES.IdTabTyp;
l_VENDOR_ID_tab                  PA_PLSQL_DATATYPES.IdTabTyp;
l_EXPENDITURE_TYPE_tab           PA_PLSQL_DATATYPES.Char30TabTyp;
l_EVENT_TYPE_tab                 PA_PLSQL_DATATYPES.Char30TabTyp;
l_NON_LABOR_RESOURCE_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
l_EXPENDITURE_CATEGORY_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
l_REVENUE_CATEGORY_CODE_tab      PA_PLSQL_DATATYPES.Char30TabTyp;
l_NLR_ORGANIZATION_ID_tab        PA_PLSQL_DATATYPES.IdTabTyp;
l_EVENT_CLASSIFICATION_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
l_SYS_LINK_FUNCTION_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
l_PROJECT_ROLE_ID_tab            PA_PLSQL_DATATYPES.IdTabTyp;
l_RESOURCE_CLASS_CODE_tab        PA_PLSQL_DATATYPES.Char30TabTyp;
l_MFC_COST_TYPE_ID_tab           PA_PLSQL_DATATYPES.IdTabTyp;
l_RESOURCE_CLASS_FLAG_tab        PA_PLSQL_DATATYPES.Char1TabTyp;
l_FC_RES_TYPE_CODE_tab           PA_PLSQL_DATATYPES.Char30TabTyp;
l_INVENTORY_ITEM_ID_tab          PA_PLSQL_DATATYPES.IdTabTyp;
l_ITEM_CATEGORY_ID_tab           PA_PLSQL_DATATYPES.IdTabTyp;
l_PERSON_TYPE_CODE_tab           PA_PLSQL_DATATYPES.Char30TabTyp;
l_BOM_RESOURCE_ID_tab            PA_PLSQL_DATATYPES.IdTabTyp;
l_NAMED_ROLE_tab                 PA_PLSQL_DATATYPES.Char80TabTyp;
l_INCURRED_BY_RES_FLAG_tab       PA_PLSQL_DATATYPES.Char1TabTyp;
l_RATE_BASED_FLAG_tab            PA_PLSQL_DATATYPES.Char1TabTyp;
l_TXN_TASK_ID_tab                PA_PLSQL_DATATYPES.IdTabTyp;
l_TXN_WBS_ELEMENT_VER_ID_tab     PA_PLSQL_DATATYPES.IdTabTyp;
l_TXN_RBS_ELEMENT_ID_tab         PA_PLSQL_DATATYPES.IdTabTyp;
l_TXN_PLAN_START_DATE_tab        PA_PLSQL_DATATYPES.DateTabTyp;
l_TXN_PLAN_END_DATE_tab          PA_PLSQL_DATATYPES.DateTabTyp;
l_res_list_member_id_tab         PA_PLSQL_DATATYPES.IdTabTyp;
l_rbs_element_id_tab             PA_PLSQL_DATATYPES.IdTabTyp;
l_txn_accum_header_id_tab        PA_PLSQL_DATATYPES.IdTabTyp;
l_txn_src_id_tab                 PA_PLSQL_DATATYPES.IdTabTyp;

l_tsk_id_tab                     PA_PLSQL_DATATYPES.IdTabTyp;
l_resrc_assgn_id                 PA_PLSQL_DATATYPES.IdTabTyp;
 l_count			     NUMBER;
 l_msg_count		             NUMBER;
 l_data			             VARCHAR2(2000);
 l_msg_data		             VARCHAR2(2000);
 l_msg_index_out                     NUMBER;

l_rl_uncategorized_flag           VARCHAR2(1);
l_uc_res_list_rlm_id              NUMBER;

BEGIN
      --Setting initial values
      IF p_init_msg_flag = 'Y' THEN
           FND_MSG_PUB.initialize;
      END IF;

      X_MSG_COUNT := 0;
      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

     IF p_pa_debug_mode = 'Y' and p_init_msg_flag = 'Y' THEN
          PA_DEBUG.init_err_stack('PA_FP_MAP_BV_PUB.GEN_MAP_BV_TO_TARGET_RL');
     ELSIF p_pa_debug_mode = 'Y' and p_init_msg_flag = 'N' THEN
            pa_debug.set_curr_function( p_function     => 'GEN_MAP_BV_TO_TARGET_RL'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
     END IF;


     l_rl_uncategorized_flag := PA_FP_GEN_AMOUNT_UTILS.
     GET_RL_UNCATEGORIZED_FLAG(P_RESOURCE_LIST_ID => p_etc_fp_cols_rec.x_resource_list_id);

     l_uc_res_list_rlm_id := PA_FP_GEN_AMOUNT_UTILS.
     GET_UC_RES_LIST_RLM_ID(P_RESOURCE_LIST_ID => p_etc_fp_cols_rec.x_resource_list_id,
                            P_RESOURCE_CLASS_CODE => 'FINANCIAL_ELEMENTS');

           IF p_cb_fp_cols_rec.x_resource_list_id  <>
              p_etc_fp_cols_rec.x_resource_list_id
              AND l_rl_uncategorized_flag = 'N' THEN
                    --Calling  the map_rlmi_rbs api
                    IF p_pa_debug_mode = 'Y' THEN
                          pa_fp_gen_amount_utils.fp_debug
                          (p_msg         => 'Before calling
                                                   pa_rlmi_rbs_map_pub.map_rlmi_rbs',
                           p_module_name => l_module_name,
                           p_log_level   => 5);
                    END IF;
                 /* PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS
                      ( p_budget_version_id       => null,
                       p_resource_list_id         =>
                       p_etc_fp_cols_rec.x_resource_list_id,
                       p_rbs_version_id	          => l_rbs_version_id,
                       p_calling_process	  => 'BUDGET_GENERATION',
                       p_calling_context	  => 'PLSQL',
                       p_process_code		  => l_process_code,
                       p_calling_mode		  => 'BUDGET_VERSION',
                       p_init_msg_list_flag	  => l_init_msg_list_flag,
                       p_commit_flag		  => l_commit_flag,
                       p_TXN_SOURCE_ID_tab        => l_TXN_SOURCE_ID_tab,
                       p_TXN_SOURCE_TYPE_CODE_tab => l_TXN_SOURCE_TYPE_CODE_tab,
                       p_PERSON_ID_tab            => l_PERSON_ID_tab,
                       p_JOB_ID_tab               => l_JOB_ID_tab,
                       p_ORGANIZATION_ID_tab      => l_ORGANIZATION_ID_tab,
                       p_VENDOR_ID_tab            => l_VENDOR_ID_tab,
                       p_EXPENDITURE_TYPE_tab     => l_EXPENDITURE_TYPE_tab,
                       p_EVENT_TYPE_tab           => l_EVENT_TYPE_tab,
                       p_NON_LABOR_RESOURCE_tab   => l_NON_LABOR_RESOURCE_tab,
                       p_EXPENDITURE_CATEGORY_tab => l_EXPENDITURE_CATEGORY_tab,
                       p_REVENUE_CATEGORY_CODE_tab=> l_REVENUE_CATEGORY_CODE_tab,
                       p_NLR_ORGANIZATION_ID_tab  => l_NLR_ORGANIZATION_ID_tab,
                       p_EVENT_CLASSIFICATION_tab => l_EVENT_CLASSIFICATION_tab,
                       p_SYS_LINK_FUNCTION_tab    => l_SYS_LINK_FUNCTION_tab,
                       p_PROJECT_ROLE_ID_tab      => l_PROJECT_ROLE_ID_tab,
                       p_RESOURCE_CLASS_CODE_tab  => l_RESOURCE_CLASS_CODE_tab,
                       p_MFC_COST_TYPE_ID_tab     => l_MFC_COST_TYPE_ID_tab,
                       p_RESOURCE_CLASS_FLAG_tab  => l_RESOURCE_CLASS_FLAG_tab,
                       p_FC_RES_TYPE_CODE_tab     => l_FC_RES_TYPE_CODE_tab,
                       p_INVENTORY_ITEM_ID_tab    => l_INVENTORY_ITEM_ID_tab,
                       p_ITEM_CATEGORY_ID_tab     => l_ITEM_CATEGORY_ID_tab,
                       p_PERSON_TYPE_CODE_tab     => l_PERSON_TYPE_CODE_tab,
                       p_BOM_RESOURCE_ID_tab      => l_BOM_RESOURCE_ID_tab,
                       p_NAMED_ROLE_tab           => l_NAMED_ROLE_tab,
                       p_INCURRED_BY_RES_FLAG_tab => l_INCURRED_BY_RES_FLAG_tab,
                       p_RATE_BASED_FLAG_tab      => l_RATE_BASED_FLAG_tab,
                       p_TXN_TASK_ID_tab          => l_TXN_TASK_ID_tab,
                       p_TXN_WBS_ELEMENT_VER_ID_tab=>l_TXN_WBS_ELEMENT_VER_ID_tab,
                       p_TXN_RBS_ELEMENT_ID_tab   => l_TXN_RBS_ELEMENT_ID_tab,
                       p_TXN_PLAN_START_DATE_tab  => l_TXN_PLAN_START_DATE_tab,
                       p_TXN_PLAN_END_DATE_tab    => l_TXN_PLAN_END_DATE_tab,
                       x_txn_source_id_tab	   => l_txn_src_id_tab,
                       x_res_list_member_id_tab   => l_res_list_member_id_tab,
                       x_rbs_element_id_tab       => l_rbs_element_id_tab,
                       x_txn_accum_header_id_tab  => l_txn_accum_header_id_tab,
                       x_return_status		   => x_return_status,
                       x_msg_count	           => x_msg_count,
                       x_msg_data	           => x_msg_data); */
       /* bug 3576766 : p_project_id parameter added for
       non centrally controlled resource list mapping. */
                    --hr_utility.trace('@@@before calling PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS :'||x_return_status);
                    PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS
                      (p_project_id => P_TARGET_FP_COLS_REC.x_project_id,
                       p_budget_version_id       => null,
					   p_resource_list_id         =>
                       p_etc_fp_cols_rec.x_resource_list_id,
                       p_rbs_version_id	          =>  null,
                       p_calling_process	  => 'BUDGET_GENERATION',
                       p_calling_context	  => 'PLSQL',
                       p_process_code		  => 'RES_MAP',
                       p_calling_mode		  => 'BUDGET_VERSION',
                       p_init_msg_list_flag	  => 'N',
                       p_commit_flag		  => 'N',
                       x_txn_source_id_tab	   => l_txn_src_id_tab,
                       x_res_list_member_id_tab   => l_res_list_member_id_tab,
                       x_rbs_element_id_tab       => l_rbs_element_id_tab,
                       x_txn_accum_header_id_tab  => l_txn_accum_header_id_tab,
                       x_return_status		   => x_return_status,
                       x_msg_count	           => x_msg_count,
                       x_msg_data	           => x_msg_data);
                     --hr_utility.trace('@@after calling PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS :'||x_return_status);
                        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                        END IF;
                        IF p_pa_debug_mode = 'Y' THEN
                          pa_fp_gen_amount_utils.fp_debug
                          (p_msg         => 'Status after calling
                                              pa_rlmi_rbs_map_pub.map_rlmi_rbs'
                                              ||x_return_status,
                           p_module_name => l_module_name,
                           p_log_level   => 5);
                        END IF;
                       /* dbms_output.put_line('Status of map_rlmi_rbs api: '
                                                  ||X_RETURN_STATUS); */
                        FORALL i IN 1..l_res_list_member_id_tab.count
                         INSERT INTO PA_FP_CALC_AMT_TMP3
                                    (plan_version_id,
                                     res_list_member_id,
                                     res_asg_id)
                         VALUES
                                    (p_etc_fp_cols_rec.x_budget_version_id,
                                     l_res_list_member_id_tab(i),
                                     l_txn_src_id_tab(i));
                        SELECT  ra.task_id,
                                ra.resource_assignment_id
			BULK    COLLECT
                        INTO    l_tsk_id_tab,
                                l_resrc_assgn_id
                        FROM    pa_resource_assignments ra
                        WHERE   ra.budget_version_id = p_etc_fp_cols_rec.
                                                       x_budget_version_id;

                        FORALL m in 1..l_tsk_id_tab.count
                          UPDATE /*+ INDEX(PA_FP_CALC_AMT_TMP3,PA_FP_CALC_AMT_TMP3_N2)*/
                                 PA_FP_CALC_AMT_TMP3
                          SET    task_id    = l_tsk_id_tab(m)
                          WHERE  res_asg_id = l_resrc_assgn_id(m);

                        OPEN  txn_sum_csr(p_target_fp_cols_rec.x_project_currency_code,
                                p_target_fp_cols_rec.x_plan_in_multi_curr_flag);
                        FETCH txn_sum_csr
			BULK  COLLECT
                        INTO  l_rlm_id_tab,
                              l_task_id_tab,
                              l_txn_currency_code_tab,
                              l_qty_tab,
                              l_txn_raw_cost_sum_tab,
                              l_txn_burdend_cost_sum_tab,
                              l_txn_revenue_sum_tab,
                              l_pc_raw_cost_sum_tab,
                              l_pc_burdend_cost_sum_tab,
                              l_pc_revenue_sum_tab,
                              l_pfc_raw_cost_sum_tab,
                              l_pfc_burdend_cost_sum_tab,
                              l_pfc_revenue_sum_tab;
                       CLOSE  txn_sum_csr;

                       DELETE /*+ INDEX(PA_FP_CALC_AMT_TMP3,PA_FP_CALC_AMT_TMP3_N1)*/
                       FROM   pa_fp_calc_amt_tmp3
                       WHERE  plan_version_id =
                       P_ETC_FP_COLS_REC.x_budget_version_id;

                       FORALL k in 1..l_txn_src_id_tab.count
                             INSERT INTO pa_fp_calc_amt_tmp3
                                    (plan_version_id,
				     task_id,
				     res_list_member_id,
				     res_asg_id,
                                     txn_currency_code,
                                     quantity,
                                     txn_raw_cost,
                                     txn_burdened_cost,
                                     txn_revenue,
                                     pc_raw_cost,
                                     pc_burdened_cost,
                                     pc_revenue,
                                     pfc_raw_cost,
                                     pfc_burdened_cost,
                                     pfc_revenue)
                             VALUES (P_ETC_FP_COLS_REC.x_budget_version_id,
                                     l_task_id_tab(k),
                                     l_rlm_id_tab(k),
                                     l_txn_src_id_tab(k),
                                     l_txn_currency_code_tab(k),
                                     l_qty_tab(k),
                                     l_txn_raw_cost_sum_tab(k),
                                     l_txn_burdend_cost_sum_tab(k),
                                     l_txn_revenue_sum_tab(k),
                                     l_pc_raw_cost_sum_tab(k),
                                     l_pc_burdend_cost_sum_tab(k),
                                     l_pc_revenue_sum_tab(k),
                                     l_pfc_raw_cost_sum_tab(k),
                                     l_pfc_burdend_cost_sum_tab(k),
                                     l_pfc_revenue_sum_tab(k));
       ELSIF p_cb_fp_cols_rec.x_resource_list_id  =
              p_etc_fp_cols_rec.x_resource_list_id THEN
          INSERT INTO PA_FP_CALC_AMT_TMP3
                   (plan_version_id,
                    task_id,
                    res_list_member_id,
                    res_asg_id,
                    txn_currency_code,
                    quantity,
                    txn_raw_cost,
                    txn_burdened_cost,
                    txn_revenue,
                    pc_raw_cost,
                    pc_burdened_cost,
                    pc_revenue,
                    pfc_raw_cost,
                    pfc_burdened_cost,
                    pfc_revenue)
          (SELECT  ra.budget_version_id,
                   ra.task_id,
                   ra.resource_list_member_id,
                   ra.resource_assignment_id,
                   decode(p_target_fp_cols_rec.x_plan_in_multi_curr_flag,
                   'Y', bl.txn_currency_code,
                   'N',p_target_fp_cols_rec.x_project_currency_code),
                   sum(bl.quantity),
                   sum(decode(p_target_fp_cols_rec.x_plan_in_multi_curr_flag,
                                     'Y',bl.txn_raw_cost,
                                     'N',bl.project_raw_cost)),
                   sum(decode(p_target_fp_cols_rec.x_plan_in_multi_curr_flag,
                                     'Y',bl.txn_burdened_cost,
                                     'N',bl.project_burdened_cost)),
                   sum(decode(p_target_fp_cols_rec.x_plan_in_multi_curr_flag,
                                     'Y',bl.txn_revenue,
                                     'N',bl.project_revenue)),
                   sum(bl.project_raw_cost),
                   sum(bl.project_burdened_cost),
                   sum(bl.project_revenue),
                   sum(bl.raw_cost),
                   sum(bl.burdened_cost),
                   sum(bl.revenue)
         FROM     pa_resource_assignments ra,
                  pa_budget_lines bl
         WHERE    ra.resource_assignment_id = bl.resource_assignment_id
         AND      ra.budget_version_id      = p_source_bv_id
	 and      bl.cost_rejection_code is null
	 and      bl.revenue_rejection_code is null
	 and      bl.burden_rejection_code is null
	 and      bl.other_rejection_code is null
	 and      bl.pc_cur_conv_rejection_code is null
	 and      bl.pfc_cur_conv_rejection_code is null
         GROUP    BY
                  ra.budget_version_id,
                  ra.task_id,
                  ra.resource_list_member_id,
                  ra.resource_assignment_id,
                  decode(p_target_fp_cols_rec.x_plan_in_multi_curr_flag,
                         'Y',bl.txn_currency_code,
                         'N',p_target_fp_cols_rec.x_project_currency_code));

       ELSIF l_rl_uncategorized_flag = 'N' THEN
          INSERT INTO PA_FP_CALC_AMT_TMP3
                   (plan_version_id,
                    task_id,
                    res_list_member_id,
                    res_asg_id,
                    txn_currency_code,
                    quantity,
                    txn_raw_cost,
                    txn_burdened_cost,
                    txn_revenue,
                    pc_raw_cost,
                    pc_burdened_cost,
                    pc_revenue,
                    pfc_raw_cost,
                    pfc_burdened_cost,
                    pfc_revenue)
          (SELECT  ra.budget_version_id,
                   ra.task_id,
                   l_uc_res_list_rlm_id,
                   ra.resource_assignment_id,
                   decode(p_target_fp_cols_rec.x_plan_in_multi_curr_flag,
                   'Y', bl.txn_currency_code,
                   'N',p_target_fp_cols_rec.x_project_currency_code),
                   sum(bl.quantity),
                   sum(decode(p_target_fp_cols_rec.x_plan_in_multi_curr_flag,
                                     'Y',bl.txn_raw_cost,
                                     'N',bl.project_raw_cost)),
                   sum(decode(p_target_fp_cols_rec.x_plan_in_multi_curr_flag,
                                     'Y',bl.txn_burdened_cost,
                                     'N',bl.project_burdened_cost)),
                   sum(decode(p_target_fp_cols_rec.x_plan_in_multi_curr_flag,
                                     'Y',bl.txn_revenue,
                                     'N',bl.project_revenue)),
                   sum(bl.project_raw_cost),
                   sum(bl.project_burdened_cost),
                   sum(bl.project_revenue),
                   sum(bl.raw_cost),
                   sum(bl.burdened_cost),
                   sum(bl.revenue)
         FROM     pa_resource_assignments ra,
                  pa_budget_lines bl
         WHERE    ra.resource_assignment_id = bl.resource_assignment_id
         AND      ra.budget_version_id      = p_source_bv_id
	 and      bl.cost_rejection_code is null
	 and      bl.revenue_rejection_code is null
	 and      bl.burden_rejection_code is null
	 and      bl.other_rejection_code is null
	 and      bl.pc_cur_conv_rejection_code is null
	 and      bl.pfc_cur_conv_rejection_code is null
         GROUP    BY
                  ra.budget_version_id,
                  ra.task_id,
                  l_uc_res_list_rlm_id,
                  ra.resource_assignment_id,
                  decode(p_target_fp_cols_rec.x_plan_in_multi_curr_flag,
                         'Y',bl.txn_currency_code,
                         'N',p_target_fp_cols_rec.x_project_currency_code));
       END IF;

       IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
           PA_DEBUG.reset_err_stack;
       ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
           PA_DEBUG.Reset_Curr_Function;
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
                          (p_msg         => 'Invalid Arguments Passed',
                           p_module_name => l_module_name,
                           p_log_level   => 5);
            IF p_init_msg_flag = 'Y' THEN
                PA_DEBUG.reset_err_stack;
            ELSIF p_init_msg_flag = 'N' THEN
                PA_DEBUG.Reset_Curr_Function;
            END IF;
        END IF;
        RAISE;

      WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_data      := SUBSTR(SQLERRM,1,240);
           FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_MAP_BV_PUB'
              ,p_procedure_name => 'GEN_MAP_BV_TO_TARGET_RL');
           IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_fp_gen_amount_utils.fp_debug
                          (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                           p_module_name => l_module_name,
                           p_log_level   => 5);
                IF p_init_msg_flag = 'Y' THEN
                    PA_DEBUG.reset_err_stack;
                ELSIF p_init_msg_flag = 'N' THEN
                    PA_DEBUG.Reset_Curr_Function;
                END IF;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GEN_MAP_BV_TO_TARGET_RL;

PROCEDURE MAINTAIN_RBS_DTLS
          (P_BUDGET_VERSION_ID     IN   PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC        IN   PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           X_RETURN_STATUS         OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT             OUT  NOCOPY NUMBER,
           X_MSG_DATA	           OUT  NOCOPY VARCHAR2) IS
l_module_name         VARCHAR2(200) := 'pa.plsql.pa_fp_map_bv_pub.maintain_rbs_dtls';

l_res_list_member_id_tab         PA_PLSQL_DATATYPES.IdTabTyp;
l_rbs_element_id_tab             PA_PLSQL_DATATYPES.IdTabTyp;
l_txn_accum_header_id_tab        PA_PLSQL_DATATYPES.IdTabTyp;
l_txn_src_id_tab                 PA_PLSQL_DATATYPES.IdTabTyp;

 l_count			     NUMBER;
 l_msg_count		             NUMBER;
 l_data			             VARCHAR2(2000);
 l_msg_data		             VARCHAR2(2000);
 l_msg_index_out                     NUMBER;

BEGIN
           --Calling  the map_rlmi_rbs api
            IF p_pa_debug_mode = 'Y' THEN
                   pa_debug.set_curr_function( p_function => 'MAINTAIN_RBS_DTLS'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
                         pa_fp_gen_amount_utils.fp_debug
                          (p_msg         => 'Before calling
                                    pa_rlmi_rbs_map_pub.map_rlmi_rbs',
                           p_module_name => l_module_name,
                           p_log_level   => 5);
            END IF;
                    PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS
                      ( p_budget_version_id       => p_budget_version_id,
                       p_resource_list_id         => null,
                       p_rbs_version_id	          => p_fp_cols_rec.x_rbs_version_id,
                       p_calling_process	  => 'BUDGET_GENERATION',
                       p_calling_context	  => 'PLSQL',
                       p_process_code		  => 'RBS_MAP',
                       p_calling_mode		  => 'BUDGET_VERSION',
                       p_init_msg_list_flag	  => 'N',
                       p_commit_flag		  => 'N',
                       x_txn_source_id_tab	   => l_txn_src_id_tab,
                       x_res_list_member_id_tab   => l_res_list_member_id_tab,
                       x_rbs_element_id_tab       => l_rbs_element_id_tab,
                       x_txn_accum_header_id_tab  => l_txn_accum_header_id_tab,
                       x_return_status		   => x_return_status,
                       x_msg_count	           => x_msg_count,
                       x_msg_data	           => x_msg_data);
                        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                        END IF;
              IF p_pa_debug_mode = 'Y' THEN
                         pa_fp_gen_amount_utils.fp_debug
                          (p_msg         => 'Status after calling
                                      pa_rlmi_rbs_map_pub.map_rlmi_rbs'
                                      ||x_return_status,
                           p_module_name => l_module_name,
                           p_log_level   => 5);
              END IF;
              /* dbms_output.put_line('Status of map_rlmi_rbs api: '
                                                  ||X_RETURN_STATUS); */

              FORALL i IN 1..l_txn_src_id_tab.count
                   UPDATE pa_resource_assignments
                   SET    rbs_element_id         = l_rbs_element_id_tab(i),
                          txn_accum_header_id    = l_txn_accum_header_id_tab(i)
                   WHERE  resource_assignment_id = l_txn_src_id_tab(i);

        IF p_pa_debug_mode = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
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
                          (p_msg         => 'Invalid Arguments Passed',
                           p_module_name => l_module_name,
                           p_log_level   => 5);
              PA_DEBUG.Reset_Curr_Function;
        END IF;
        RAISE;

      WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_data      := SUBSTR(SQLERRM,1,240);
           FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_MAP_BV_PUB'
              ,p_procedure_name => 'MAINTAIN_RBS_DTLS');
           IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_fp_gen_amount_utils.fp_debug
                          (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                           p_module_name => l_module_name,
                           p_log_level   => 5);
                PA_DEBUG.Reset_Curr_Function;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END MAINTAIN_RBS_DTLS;

END PA_FP_MAP_BV_PUB;

/
