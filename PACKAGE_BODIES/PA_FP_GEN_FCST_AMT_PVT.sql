--------------------------------------------------------
--  DDL for Package Body PA_FP_GEN_FCST_AMT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_GEN_FCST_AMT_PVT" as
/* $Header: PAFPFGVB.pls 120.6 2007/02/06 09:54:11 dthakker ship $ */
P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

/*=======================================================================================
  This procedure will return the total transaction amount for the given planning resource
  =======================================================================================*/
PROCEDURE GET_TOTAL_PLAN_TXN_AMTS
          (P_PROJECT_ID                IN          PA_PROJECTS_ALL.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID         IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_BV_ID_ETC_WP              IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_BV_ID_ETC_FP              IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC_ETC_WP        IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_FP_COLS_REC_ETC_FP        IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_FP_COLS_REC               IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_TASK_ID                   IN          PA_RESOURCE_ASSIGNMENTS.TASK_ID%TYPE,
           P_LATEST_PUBLISH_FP_WBS_ID  IN          NUMBER,
           P_CALLING_CONTEXT           IN          VARCHAR2,
           X_TXN_AMT_REC               OUT  NOCOPY PA_FP_GEN_FCST_AMT_PUB.TXN_AMT_REC_TYP,
           X_RETURN_STATUS             OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT                 OUT  NOCOPY NUMBER,
           X_MSG_DATA                  OUT  NOCOPY VARCHAR2) IS

l_module_name         VARCHAR2(200) := 'pa.plsql.pa_fp_gen_fcst_amt_pub.get_total_plan_txn_amts';

l_res_asg_id_tab      PA_PLSQL_DATATYPES.IdTabTyp;

/* Local variables for calling pa_fp_gen_amount_utils.get_values_for_planning_rate api */
 l_res_format_id                     PA_RESOURCE_LIST_MEMBERS.RES_FORMAT_ID%TYPE;
 l_resource_asn_rec                  PA_FP_GEN_AMOUNT_UTILS.RESOURCE_ASN_REC;
 l_pa_tasks_rec                      PA_FP_GEN_AMOUNT_UTILS.PA_TASKS_REC;
 l_pa_projects_all_rec               PA_FP_GEN_AMOUNT_UTILS.PA_PROJECTS_ALL_REC;
 l_proj_fp_options_rec               PA_FP_GEN_AMOUNT_UTILS.PROJ_FP_OPTIONS_REC;
/* end */
/* Local variables for calling get_planning_rate api */
 l_task_bill_rate_org_id            pa_tasks.non_labor_bill_rate_org_id%TYPE;
 l_task_sch_discount                pa_tasks.non_labor_schedule_discount%TYPE;
 l_task_sch_date                    pa_tasks.non_labor_schedule_fixed_date%TYPE;
 l_task_nl_std_bill_rt_sch_id       pa_tasks.non_lab_std_bill_rt_sch_id%TYPE;
 l_task_emp_bill_rate_sch_id        pa_tasks.emp_bill_rate_schedule_id%TYPE;
 l_task_job_bill_rate_sch_id        pa_tasks.job_bill_rate_schedule_id%TYPE;
 l_task_lab_bill_rate_org_id        pa_tasks.labor_bill_rate_org_id%TYPE;
 l_task_lab_sch_type                pa_tasks.labor_sch_type%TYPE;
 l_task_non_labor_sch_type          pa_tasks.non_labor_sch_type%TYPE;
 l_top_task_id                      pa_tasks.top_task_id%TYPE;
 --Bug 4108350: Fixed the type mismatch for l_lab_sch_type.
 l_lab_sch_type                     pa_tasks.labor_sch_type%TYPE; --emp_bill_rate_schedule_id%TYPE;
 l_rate_task_id                     pa_resource_assignments.task_id%TYPE;

 l_txn_currency_code                 pa_fp_rollup_tmp.txn_currency_code%TYPE := NULL;
 l_txn_plan_quantity                 pa_fp_rollup_tmp.quantity%TYPE := NULL;
 l_budget_lines_start_date           pa_fp_rollup_tmp.start_date%TYPE := NULL;
 l_budget_line_id                    pa_fp_rollup_tmp.budget_line_id%TYPE := NULL;
 l_burden_cost_rate_override         pa_fp_rollup_tmp.burden_cost_rate_override%TYPE := NULL;
 l_rw_cost_rate_override             pa_fp_rollup_tmp.rw_cost_rate_override%TYPE := NULL;
 l_bill_rate_override                pa_fp_rollup_tmp.bill_rate_override%TYPE := NULL;
 l_txn_raw_cost                      pa_fp_rollup_tmp.txn_raw_cost%TYPE := NULL;
 l_txn_burdened_cost                 pa_fp_rollup_tmp.txn_burdened_cost%TYPE := NULL;
 l_txn_revenue                       pa_fp_rollup_tmp.txn_revenue%TYPE := NULL;

 l_emp_bill_rate_sch_id              pa_projects_all.emp_bill_rate_schedule_id%TYPE;
 l_job_bill_rate_sch_id              pa_projects_all.job_bill_rate_schedule_id%TYPE;
 l_lab_bill_rate_org_id              pa_projects_all.labor_bill_rate_org_id%TYPE;
 l_non_labor_sch_type                pa_projects_all.non_labor_sch_type%TYPE;

 l_txn_currency_code_override        pa_fp_res_assignments_tmp.txn_currency_code_override%TYPE;
 l_assignment_id                     pa_project_assignments.assignment_id%TYPE := NULL;
 l_cost_rate_multiplier              CONSTANT pa_labor_cost_multipliers.multiplier%TYPE := 1;
 l_bill_rate_multiplier              CONSTANT NUMBER := 1;
 l_cost_sch_type                     VARCHAR2(30) := 'COST';
 l_mfc_cost_source                   CONSTANT NUMBER := 2;
 l_calculate_mode                    VARCHAR2(60);
 l_bill_rate                         NUMBER;
 l_cost_rate                         NUMBER;
 l_burden_cost_rate                  NUMBER;
 l_burden_multiplier                 NUMBER;
 l_raw_cost                          NUMBER;
 l_burden_cost                       NUMBER;
 l_raw_revenue                       NUMBER;
 l_bill_markup_percentage            NUMBER;
 l_cost_txn_curr_code                VARCHAR2(30);
 l_rev_txn_curr_code                 VARCHAR2(30);
 l_raw_cost_rejection_code           VARCHAR2(30);
 l_burden_cost_rejection_code        VARCHAR2(30);
 l_revenue_rejection_code            VARCHAR2(30);
 l_cost_ind_compiled_set_id          NUMBER;
/* end */

/* Local variables pa_fp_multi_currency_pkg.conv_mc_bulk */
 l_res_asn_id_tab                    pa_fp_multi_currency_pkg.number_type_tab;
 l_start_date_tab                    pa_fp_multi_currency_pkg.date_type_tab;
 l_end_date_tab                      pa_fp_multi_currency_pkg.date_type_tab;
 l_res_list_member_id_tab            pa_fp_multi_currency_pkg.number_type_tab; /* Bug 4070849 */
 l_txn_currency_code_tab             pa_fp_multi_currency_pkg.char240_type_tab;
 l_txn_rw_cost_tab                   pa_fp_multi_currency_pkg.number_type_tab;
 l_txn_burdend_cost_tab              pa_fp_multi_currency_pkg.number_type_tab;
 l_txn_rev_tab                       pa_fp_multi_currency_pkg.number_type_tab;
 l_projfunc_currency_code_tab        pa_fp_multi_currency_pkg.char240_type_tab;
 l_projfunc_cost_rate_type_tab       pa_fp_multi_currency_pkg.char240_type_tab;
 l_projfunc_cost_rate_tab            pa_fp_multi_currency_pkg.number_type_tab;
 l_projfunc_cost_rate_date_tab       pa_fp_multi_currency_pkg.date_type_tab;
 l_projfunc_rev_rate_type_tab        pa_fp_multi_currency_pkg.char240_type_tab;
 l_projfunc_rev_rate_tab             pa_fp_multi_currency_pkg.number_type_tab;
 l_projfunc_rev_rate_date_tab        pa_fp_multi_currency_pkg.date_type_tab;
 l_projfunc_raw_cost_tab             pa_fp_multi_currency_pkg.number_type_tab;
 l_projfunc_burdened_cost_tab        pa_fp_multi_currency_pkg.number_type_tab;
 l_projfunc_revenue_tab              pa_fp_multi_currency_pkg.number_type_tab;
 l_projfunc_rejection_tab            pa_fp_multi_currency_pkg.char30_type_tab;
 l_proj_raw_cost_tab                 pa_fp_multi_currency_pkg.number_type_tab;
 l_proj_burdened_cost_tab            pa_fp_multi_currency_pkg.number_type_tab;
 l_proj_revenue_tab                  pa_fp_multi_currency_pkg.number_type_tab;
 l_proj_rejection_tab                pa_fp_multi_currency_pkg.char30_type_tab;
 l_proj_currency_code_tab            pa_fp_multi_currency_pkg.char240_type_tab;
 l_proj_cost_rate_type_tab           pa_fp_multi_currency_pkg.char240_type_tab;
 l_proj_cost_rate_tab                pa_fp_multi_currency_pkg.number_type_tab;
 l_proj_cost_rate_date_tab           pa_fp_multi_currency_pkg.date_type_tab;
 l_proj_rev_rate_type_tab            pa_fp_multi_currency_pkg.char240_type_tab;
 l_proj_rev_rate_tab                 pa_fp_multi_currency_pkg.number_type_tab;
 l_proj_rev_rate_date_tab            pa_fp_multi_currency_pkg.date_type_tab;
 l_user_validate_flag_tab            pa_fp_multi_currency_pkg.char240_type_tab;
/* end */

 l_count                             NUMBER;
 l_msg_count                         NUMBER;
 l_data                              VARCHAR2(2000);
 l_msg_data                          VARCHAR2(2000);
 l_msg_index_out                     NUMBER;

 l_struct_sharing_code               PA_PROJECTS_ALL.STRUCTURE_SHARING_CODE%TYPE;
/* Values for l_struct_sharing_code can be
   SHARE_FULL
   SHARE_PARTIAL
   SPLIT_MAPPING
   SPLIT_NO_MAPPING */

 l_ins_bill_rate                     NUMBER;
 l_ins_cost_rate                     NUMBER;
 l_ins_burd_cost_rate                NUMBER;
 l_ins_burd_multiplier               NUMBER;
/*
 l_ins_raw_cost                      NUMBER;
 l_ins_burden_cost                   NUMBER;
 l_ins_raw_revenue                   NUMBER;
*/
 l_ins_bill_markup_perc              NUMBER;
 l_ins_cost_txn_curr_code            VARCHAR2(30);
 l_ins_rev_txn_curr_code             VARCHAR2(30);
 l_ins_raw_cost_rej_code             VARCHAR2(30);
 l_ins_burd_cost_rej_code            VARCHAR2(30);
 l_ins_rev_rej_code                  VARCHAR2(30);
 l_ins_cost_ind_com_set_id           NUMBER;

 l_ins_pfc_raw_cost_tab              pa_fp_multi_currency_pkg.number_type_tab;
 l_ins_pfc_burd_cost_tab             pa_fp_multi_currency_pkg.number_type_tab;
 l_ins_pfc_revenue_tab               pa_fp_multi_currency_pkg.number_type_tab;
 l_ins_pfc_rejection_tab             pa_fp_multi_currency_pkg.char30_type_tab;
 l_ins_pc_raw_cost_tab               pa_fp_multi_currency_pkg.number_type_tab;
 l_ins_pc_burdened_cost_tab          pa_fp_multi_currency_pkg.number_type_tab;
 l_ins_pc_revenue_tab                pa_fp_multi_currency_pkg.number_type_tab;
 l_ins_pc_rejection_tab              pa_fp_multi_currency_pkg.char30_type_tab;

l_source_bv_id number;
l_txn_src_code   PA_RESOURCE_ASSIGNMENTS.TRANSACTION_SOURCE_CODE%TYPE;
BEGIN
      --Setting initial values
      X_MSG_COUNT := 0;
      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

      IF p_pa_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function     => 'GET_TOTAL_PLAN_TXN_AMTS'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
      END IF;

     l_struct_sharing_code := NVL(PA_PROJECT_STRUCTURE_UTILS.
                get_Structure_sharing_code(P_PROJECT_ID=> P_PROJECT_ID),'SHARE_FULL');
     --dbms_output.put_line('Value for Structure_sharing_code: '|| l_struct_sharing_code);
  /* hr_utility.trace('etc wp bv id :'||P_BV_ID_ETC_WP);
  hr_utility.trace('etc fp bv id :'||P_BV_ID_ETC_FP);  */
    IF p_calling_context = 'WORK_PLAN' THEN
       l_source_bv_id := P_BV_ID_ETC_WP;
    ELSE
       l_source_bv_id := P_BV_ID_ETC_FP;
    END IF;

    -- Bug 5094401: If the source budget_version_id is null,
    -- then return without doing any further processing since
    -- no planned amounts are available foro this task.
    IF l_source_bv_id IS NULL THEN
        IF p_pa_debug_mode = 'Y' THEN
           PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN;
    END IF;

    IF p_calling_context = 'WORK_PLAN' THEN
       l_txn_src_code := 'WORKPLAN_RESOURCES';
    ELSE
       l_txn_src_code := p_calling_context;
    END IF;

    /* hr_utility.trace_on(null,'mftest');  */
    IF (   p_calling_context = 'WORK_PLAN'
        AND
           p_fp_cols_rec_etc_wp.x_track_workplan_costs_flag = 'Y'
        AND
           l_struct_sharing_code = 'SHARE_FULL')
        OR
           p_calling_context = 'FINANCIAL_PLAN'   THEN
                INSERT INTO PA_FP_CALC_AMT_TMP1
                    ( RESOURCE_ASSIGNMENT_ID
                     ,BUDGET_VERSION_ID
                      ,PROJECT_ID
                      ,TASK_ID
                      ,RESOURCE_LIST_MEMBER_ID
                      ,UNIT_OF_MEASURE
                      ,TRACK_AS_LABOR_FLAG
                      ,RESOURCE_ASSIGNMENT_TYPE
                      ,PLANNING_START_DATE
                      ,PLANNING_END_DATE
                      ,RES_TYPE_CODE
                      ,FC_RES_TYPE_CODE
                      ,RESOURCE_CLASS_CODE
                      ,ORGANIZATION_ID
                      ,JOB_ID
                      ,PERSON_ID
                      ,EXPENDITURE_TYPE
                      ,EXPENDITURE_CATEGORY
                      ,REVENUE_CATEGORY_CODE
                      ,EVENT_TYPE
                      ,SUPPLIER_ID
                      ,PROJECT_ROLE_ID
                      ,PERSON_TYPE_CODE
                      ,NON_LABOR_RESOURCE
                      ,BOM_RESOURCE_ID
                      ,INVENTORY_ITEM_ID
                      ,ITEM_CATEGORY_ID
                      ,BILLABLE_PERCENT
                      ,TRANSACTION_SOURCE_CODE
                      ,MFC_COST_TYPE_ID
                      ,PROCURE_RESOURCE_FLAG
                      ,INCURRED_BY_RES_FLAG
                      ,RATE_JOB_ID
                      ,RATE_EXPENDITURE_TYPE
                      ,TA_DISPLAY_FLAG
                      ,RATE_BASED_FLAG
                      ,USE_TASK_SCHEDULE_FLAG
                      ,RATE_EXP_FUNC_CURR_CODE
                      ,RATE_EXPENDITURE_ORG_ID
                      ,INCUR_BY_RES_CLASS_CODE
                      ,INCUR_BY_ROLE_ID
                      ,RESOURCE_CLASS_FLAG
                      ,NAMED_ROLE
                      ,ETC_METHOD_CODE
                      ,MAPPED_FIN_TASK_ID)
                    (SELECT  ra.resource_assignment_id,
                             ra.budget_version_id,
                             ra.project_id,
                             ra.task_id,
                             ra.resource_list_member_id,
                             ra.unit_of_measure,
                             ra.track_as_labor_flag,
                             ra.resource_assignment_type,
                             ra.planning_start_date,
                             ra.planning_end_date,
                             ra.res_type_code,
                             ra.fc_res_type_code,
                             ra.resource_class_code,
                             ra.organization_id,
                             ra.job_id,
                             ra.person_id,
                             ra.expenditure_type,
                             ra.expenditure_category,
                             ra.revenue_category_code,
                             ra.event_type,
                             ra.supplier_id,
                             ra.project_role_id,
                             ra.person_type_code,
                             ra.non_labor_resource,
                             ra.bom_resource_id,
                             ra.inventory_item_id,
                             ra.item_category_id,
                             ra.billable_percent,
                             l_txn_src_code,
                             ra.mfc_cost_type_id,
                             ra.procure_resource_flag,
                             ra.incurred_by_res_flag,
                             ra.rate_job_id,
                             ra.rate_expenditure_type,
                             ra.ta_display_flag,
                             ra.rate_based_flag,
                             ra.use_task_schedule_flag,
                             ra.rate_exp_func_curr_code,
                             ra.rate_expenditure_org_id,
                             ra.incur_by_res_class_code,
                             ra.incur_by_role_id,
                             ra.resource_class_flag,
                             ra.named_role,
                             ra.etc_method_code,
                             ra.task_id
                     FROM    pa_resource_assignments ra
                     WHERE   ra.budget_version_id      = l_source_bv_id
                     AND     NVL(ra.task_id,0)         = p_task_id AND
                     EXISTS (SELECT 1 from pa_budget_lines bl WHERE
                             ra.resource_assignment_id =
                             bl.resource_assignment_id AND
                             rownum < 2));
   /* hr_utility.trace('no fo recs inserted in tmp1:'||sql%rowcount);
  hr_utility.trace('p task id :'||p_task_id );
  hr_utility.trace('budget ver id  '||p_budget_version_id) ;  */

     --dbms_output.put_line('No. of rows inserted in tmp1 : '|| sql%rowcount);

                INSERT INTO PA_FP_CALC_AMT_TMP2
                            (resource_assignment_id,
                             txn_currency_code,
                             total_plan_quantity,
                             total_txn_raw_cost,
                             total_txn_burdened_cost,
                             total_txn_revenue,
                             total_pc_raw_cost,
                             total_pc_burdened_cost,
                             total_pc_revenue,
                             total_pfc_raw_cost,
                             total_pfc_burdened_cost,
                             total_pfc_revenue,
                             transaction_source_code )
                    (SELECT  ra.resource_assignment_id,
                             decode(p_fp_cols_rec.x_plan_in_multi_curr_flag,
                                    'Y',bl.txn_currency_code,
                                    'N',p_fp_cols_rec.x_project_currency_code),
                             sum(bl.quantity),
                             sum(decode(p_fp_cols_rec.x_plan_in_multi_curr_flag,
                                     'Y',bl.txn_raw_cost,
                                     'N',bl.project_raw_cost)),
                             sum(decode(p_fp_cols_rec.x_plan_in_multi_curr_flag,
                                     'Y',bl.txn_burdened_cost,
                                     'N',bl.project_burdened_cost)),
                             sum(decode(p_fp_cols_rec.x_plan_in_multi_curr_flag,
                                     'Y',bl.txn_revenue,
                                     'N',bl.project_revenue)),
                             sum(bl.project_raw_cost),
                             sum(bl.project_burdened_cost),
                             sum(bl.project_revenue),
                             sum(bl.raw_cost),
                             sum(bl.burdened_cost),
                             sum(bl.revenue),
                             l_txn_src_code
                      FROM   pa_budget_lines bl,
                             pa_resource_assignments ra
                     WHERE   ra.resource_assignment_id = bl.resource_assignment_id
                             and ra.budget_version_id = l_source_bv_id
                             and NVL(ra.task_id,0) = p_task_id
                             AND bl.COST_REJECTION_CODE IS NULL
                             AND bl.REVENUE_REJECTION_CODE IS NULL
                             AND bl.BURDEN_REJECTION_CODE IS NULL
                             AND bl.OTHER_REJECTION_CODE IS NULL
                             AND bl.PC_CUR_CONV_REJECTION_CODE IS NULL
                             AND bl.PFC_CUR_CONV_REJECTION_CODE IS NULL
                     GROUP BY ra.resource_assignment_id,l_txn_src_code,
                              decode(p_fp_cols_rec.x_plan_in_multi_curr_flag,
                                    'Y',bl.txn_currency_code,
                                    'N',p_fp_cols_rec.x_project_currency_code));

  -- hr_utility.trace('no fo recs inserted in tmp2:'||sql%rowcount);

     --dbms_output.put_line('No. of rows inserted in tmp2 : '|| sql%rowcount);

    ELSIF (p_calling_context = 'WORK_PLAN'
        AND p_fp_cols_rec_etc_wp.x_track_workplan_costs_flag = 'Y'
        AND l_struct_sharing_code = 'SPLIT_NO_MAPPING') THEN
                INSERT INTO PA_FP_CALC_AMT_TMP1
                    ( RESOURCE_ASSIGNMENT_ID
                      ,BUDGET_VERSION_ID
                      ,PROJECT_ID
                      ,TASK_ID
                      ,RESOURCE_LIST_MEMBER_ID
                      ,UNIT_OF_MEASURE
                      ,TRACK_AS_LABOR_FLAG
                      ,RESOURCE_ASSIGNMENT_TYPE
                      ,PLANNING_START_DATE
                      ,PLANNING_END_DATE
                      ,RES_TYPE_CODE
                      ,FC_RES_TYPE_CODE
                      ,RESOURCE_CLASS_CODE
                      ,ORGANIZATION_ID
                      ,JOB_ID
                      ,PERSON_ID
                      ,EXPENDITURE_TYPE
                      ,EXPENDITURE_CATEGORY
                      ,REVENUE_CATEGORY_CODE
                      ,EVENT_TYPE
                      ,SUPPLIER_ID
                      ,PROJECT_ROLE_ID
                      ,PERSON_TYPE_CODE
                      ,NON_LABOR_RESOURCE
                      ,BOM_RESOURCE_ID
                      ,INVENTORY_ITEM_ID
                      ,ITEM_CATEGORY_ID
                      ,BILLABLE_PERCENT
                      ,TRANSACTION_SOURCE_CODE
                      ,MFC_COST_TYPE_ID
                      ,PROCURE_RESOURCE_FLAG
                      ,INCURRED_BY_RES_FLAG
                      ,RATE_JOB_ID
                      ,RATE_EXPENDITURE_TYPE
                      ,TA_DISPLAY_FLAG
                      ,RATE_BASED_FLAG
                      ,USE_TASK_SCHEDULE_FLAG
                      ,RATE_EXP_FUNC_CURR_CODE
                      ,RATE_EXPENDITURE_ORG_ID
                      ,INCUR_BY_RES_CLASS_CODE
                      ,INCUR_BY_ROLE_ID
                      ,RESOURCE_CLASS_FLAG
                      ,NAMED_ROLE
                      ,ETC_METHOD_CODE
                      ,MAPPED_FIN_TASK_ID)
                    (SELECT  ra.resource_assignment_id,
                             ra.budget_version_id,
                             ra.project_id,
                             ra.task_id,
                             ra.resource_list_member_id,
                             ra.unit_of_measure,
                             ra.track_as_labor_flag,
                             ra.resource_assignment_type,
                             ra.planning_start_date,
                             ra.planning_end_date,
                             ra.res_type_code,
                             ra.fc_res_type_code,
                             ra.resource_class_code,
                             ra.organization_id,
                             ra.job_id,
                             ra.person_id,
                             ra.expenditure_type,
                             ra.expenditure_category,
                             ra.revenue_category_code,
                             ra.event_type,
                             ra.supplier_id,
                             ra.project_role_id,
                             ra.person_type_code,
                             ra.non_labor_resource,
                             ra.bom_resource_id,
                             ra.inventory_item_id,
                             ra.item_category_id,
                             ra.billable_percent,
                             l_txn_src_code,
                             ra.mfc_cost_type_id,
                             ra.procure_resource_flag,
                             ra.incurred_by_res_flag,
                             ra.rate_job_id,
                             ra.rate_expenditure_type,
                             ra.ta_display_flag,
                             ra.rate_based_flag,
                             ra.use_task_schedule_flag,
                             ra.rate_exp_func_curr_code,
                             ra.rate_expenditure_org_id,
                             ra.incur_by_res_class_code,
                             ra.incur_by_role_id,
                             ra.resource_class_flag,
                             ra.named_role,
                             ra.etc_method_code,
                             0
                     FROM    pa_resource_assignments ra
                     WHERE   ra.budget_version_id      = l_source_bv_id);

     --dbms_output.put_line('No. of rows inserted in tmp1 : '|| sql%rowcount);

                INSERT INTO PA_FP_CALC_AMT_TMP2
                            (resource_assignment_id,
                             txn_currency_code,
                             total_plan_quantity,
                             total_txn_raw_cost,
                             total_txn_burdened_cost,
                             total_txn_revenue,
                             total_pc_raw_cost,
                             total_pc_burdened_cost,
                             total_pc_revenue,
                             total_pfc_raw_cost,
                             total_pfc_burdened_cost,
                             total_pfc_revenue,
                             transaction_source_code )
                    (SELECT  ra.resource_assignment_id,
                             decode(p_fp_cols_rec.x_plan_in_multi_curr_flag,
                                    'Y',bl.txn_currency_code,
                                    'N',p_fp_cols_rec.x_project_currency_code),
                             sum(bl.quantity),
                             sum(decode(p_fp_cols_rec.x_plan_in_multi_curr_flag,
                                     'Y',bl.txn_raw_cost,
                                     'N',bl.project_raw_cost)),
                             sum(decode(p_fp_cols_rec.x_plan_in_multi_curr_flag,
                                     'Y',bl.txn_burdened_cost,
                                     'N',bl.project_burdened_cost)),
                             sum(decode(p_fp_cols_rec.x_plan_in_multi_curr_flag,
                                     'Y',bl.txn_revenue,
                                     'N',bl.project_revenue)),
                             sum(bl.project_raw_cost),
                             sum(bl.project_burdened_cost),
                             sum(bl.project_revenue),
                             sum(bl.raw_cost),
                             sum(bl.burdened_cost),
                             sum(bl.revenue),
                             l_txn_src_code
                      FROM   pa_budget_lines bl,
                             pa_resource_assignments ra
                     WHERE   ra.budget_version_id  = l_source_bv_id
                             AND ra.resource_assignment_id = bl.resource_assignment_id
                             AND bl.COST_REJECTION_CODE IS NULL
                             AND bl.REVENUE_REJECTION_CODE IS NULL
                             AND bl.BURDEN_REJECTION_CODE IS NULL
                             AND bl.OTHER_REJECTION_CODE IS NULL
                             AND bl.PC_CUR_CONV_REJECTION_CODE IS NULL
                             AND bl.PFC_CUR_CONV_REJECTION_CODE IS NULL
                     GROUP BY ra.resource_assignment_id,l_txn_src_code,
                              decode(p_fp_cols_rec.x_plan_in_multi_curr_flag,
                                    'Y',bl.txn_currency_code,
                                    'N',p_fp_cols_rec.x_project_currency_code));

    ELSIF (   p_calling_context = 'WORK_PLAN'
        AND
           p_fp_cols_rec_etc_wp.x_track_workplan_costs_flag = 'Y'
        AND
           l_struct_sharing_code <> 'SHARE_FULL') THEN
                INSERT INTO PA_FP_CALC_AMT_TMP1
                    ( RESOURCE_ASSIGNMENT_ID
                     ,BUDGET_VERSION_ID
                      ,PROJECT_ID
                      ,TASK_ID
                      ,RESOURCE_LIST_MEMBER_ID
                      ,UNIT_OF_MEASURE
                      ,TRACK_AS_LABOR_FLAG
                      ,RESOURCE_ASSIGNMENT_TYPE
                      ,PLANNING_START_DATE
                      ,PLANNING_END_DATE
                      ,RES_TYPE_CODE
                      ,FC_RES_TYPE_CODE
                      ,RESOURCE_CLASS_CODE
                      ,ORGANIZATION_ID
                      ,JOB_ID
                      ,PERSON_ID
                      ,EXPENDITURE_TYPE
                      ,EXPENDITURE_CATEGORY
                      ,REVENUE_CATEGORY_CODE
                      ,EVENT_TYPE
                      ,SUPPLIER_ID
                      ,PROJECT_ROLE_ID
                      ,PERSON_TYPE_CODE
                      ,NON_LABOR_RESOURCE
                      ,BOM_RESOURCE_ID
                      ,INVENTORY_ITEM_ID
                      ,ITEM_CATEGORY_ID
                      ,BILLABLE_PERCENT
                      ,TRANSACTION_SOURCE_CODE
                      ,MFC_COST_TYPE_ID
                      ,PROCURE_RESOURCE_FLAG
                      ,INCURRED_BY_RES_FLAG
                      ,RATE_JOB_ID
                      ,RATE_EXPENDITURE_TYPE
                      ,TA_DISPLAY_FLAG
                      ,RATE_BASED_FLAG
                      ,USE_TASK_SCHEDULE_FLAG
                      ,RATE_EXP_FUNC_CURR_CODE
                      ,RATE_EXPENDITURE_ORG_ID
                      ,INCUR_BY_RES_CLASS_CODE
                      ,INCUR_BY_ROLE_ID
                      ,RESOURCE_CLASS_FLAG
                      ,NAMED_ROLE
                      ,ETC_METHOD_CODE
                      ,MAPPED_FIN_TASK_ID)
                    (SELECT  ra.resource_assignment_id,
                             ra.budget_version_id,
                             ra.project_id,
                             ra.task_id,
                             ra.resource_list_member_id,
                             ra.unit_of_measure,
                             ra.track_as_labor_flag,
                             ra.resource_assignment_type,
                             ra.planning_start_date,
                             ra.planning_end_date,
                             ra.res_type_code,
                             ra.fc_res_type_code,
                             ra.resource_class_code,
                             ra.organization_id,
                             ra.job_id,
                             ra.person_id,
                             ra.expenditure_type,
                             ra.expenditure_category,
                             ra.revenue_category_code,
                             ra.event_type,
                             ra.supplier_id,
                             ra.project_role_id,
                             ra.person_type_code,
                             ra.non_labor_resource,
                             ra.bom_resource_id,
                             ra.inventory_item_id,
                             ra.item_category_id,
                             ra.billable_percent,
                             l_txn_src_code,
                             ra.mfc_cost_type_id,
                             ra.procure_resource_flag,
                             ra.incurred_by_res_flag,
                             ra.rate_job_id,
                             ra.rate_expenditure_type,
                             ra.ta_display_flag,
                             ra.rate_based_flag,
                             ra.use_task_schedule_flag,
                             ra.rate_exp_func_curr_code,
                             ra.rate_expenditure_org_id,
                             ra.incur_by_res_class_code,
                             ra.incur_by_role_id,
                             ra.resource_class_flag,
                             ra.named_role,
                             ra.etc_method_code,
                             v.mapped_fin_task_id
                     FROM    pa_resource_assignments ra,
                             pa_map_wp_to_fin_tasks_v v
                     WHERE
                             ra.budget_version_id      = l_source_bv_id
                     AND     v.mapped_fin_task_id      = p_task_id
                     AND     v.parent_structure_version_id =
                     p_fp_cols_rec_etc_wp.x_project_structure_version_id
                     AND     v.proj_element_id = ra.task_id);

     --dbms_output.put_line('No. of rows inserted in tmp1 : '|| sql%rowcount);

                INSERT INTO PA_FP_CALC_AMT_TMP2
                            (resource_assignment_id,
                             txn_currency_code,
                             total_plan_quantity,
                             total_txn_raw_cost,
                             total_txn_burdened_cost,
                             total_txn_revenue,
                             total_pc_raw_cost,
                             total_pc_burdened_cost,
                             total_pc_revenue,
                             total_pfc_raw_cost,
                             total_pfc_burdened_cost,
                             total_pfc_revenue,
                             transaction_source_code )
                    (SELECT  ra.resource_assignment_id,
                             decode(p_fp_cols_rec.x_plan_in_multi_curr_flag,
                                    'Y',bl.txn_currency_code,
                                    'N',p_fp_cols_rec.x_project_currency_code),
                             sum(bl.quantity),
                             sum(decode(p_fp_cols_rec.x_plan_in_multi_curr_flag,
                                     'Y',bl.txn_raw_cost,
                                     'N',bl.project_raw_cost)),
                             sum(decode(p_fp_cols_rec.x_plan_in_multi_curr_flag,
                                     'Y',bl.txn_burdened_cost,
                                     'N',bl.project_burdened_cost)),
                             sum(decode(p_fp_cols_rec.x_plan_in_multi_curr_flag,
                                     'Y',bl.txn_revenue,
                                     'N',bl.project_revenue)),
                             sum(bl.project_raw_cost),
                             sum(bl.project_burdened_cost),
                             sum(bl.project_revenue),
                             sum(bl.raw_cost),
                             sum(bl.burdened_cost),
                             sum(bl.revenue),
                             l_txn_src_code
                      FROM   pa_budget_lines bl,
                             pa_resource_assignments ra,
                             pa_map_wp_to_fin_tasks_v v
                     WHERE   ra.resource_assignment_id = bl.resource_assignment_id
                             and ra.budget_version_id  = l_source_bv_id
                             and v.parent_structure_version_id = p_fp_cols_rec_etc_wp.x_project_structure_version_id
                             and v.mapped_fin_task_id = p_task_id
                             and NVL(ra.task_id,0) = v.proj_element_id
                             AND bl.COST_REJECTION_CODE IS NULL
                             AND bl.REVENUE_REJECTION_CODE IS NULL
                             AND bl.BURDEN_REJECTION_CODE IS NULL
                             AND bl.OTHER_REJECTION_CODE IS NULL
                             AND bl.PC_CUR_CONV_REJECTION_CODE IS NULL
                             AND bl.PFC_CUR_CONV_REJECTION_CODE IS NULL
                     GROUP BY ra.resource_assignment_id,l_txn_src_code,
                              decode(p_fp_cols_rec.x_plan_in_multi_curr_flag,
                                    'Y',bl.txn_currency_code,
                                    'N',p_fp_cols_rec.x_project_currency_code));

  -- hr_utility.trace('no fo recs inserted in tmp2:'||sql%rowcount);;

     --dbms_output.put_line('No. of rows inserted in tmp2 : '|| sql%rowcount);

              ELSE
                 /*else part is used when p_calling_context = 'WORK_PLAN'and
                   p_fp_cols_rec_etc_wp.x_track_workplan_costs_flag = 'N'  and
                   structure sharing code is not null */
     --dbms_output.put_line('Value for track_workplan_costs_flag:' || p_fp_cols_rec_etc_wp.x_track_workplan_costs_flag);
                INSERT INTO PA_FP_CALC_AMT_TMP1
                    ( RESOURCE_ASSIGNMENT_ID
                     ,BUDGET_VERSION_ID
                      ,PROJECT_ID
                      ,TASK_ID
                      ,RESOURCE_LIST_MEMBER_ID
                      ,UNIT_OF_MEASURE
                      ,TRACK_AS_LABOR_FLAG
                      ,RESOURCE_ASSIGNMENT_TYPE
                      ,PLANNING_START_DATE
                      ,PLANNING_END_DATE
                      ,RES_TYPE_CODE
                      ,FC_RES_TYPE_CODE
                      ,RESOURCE_CLASS_CODE
                      ,ORGANIZATION_ID
                      ,JOB_ID
                      ,PERSON_ID
                      ,EXPENDITURE_TYPE
                      ,EXPENDITURE_CATEGORY
                      ,REVENUE_CATEGORY_CODE
                      ,EVENT_TYPE
                      ,SUPPLIER_ID
                      ,PROJECT_ROLE_ID
                      ,PERSON_TYPE_CODE
                      ,NON_LABOR_RESOURCE
                      ,BOM_RESOURCE_ID
                      ,INVENTORY_ITEM_ID
                      ,ITEM_CATEGORY_ID
                      ,BILLABLE_PERCENT
                      ,TRANSACTION_SOURCE_CODE
                      ,MFC_COST_TYPE_ID
                      ,PROCURE_RESOURCE_FLAG
                      ,INCURRED_BY_RES_FLAG
                      ,RATE_JOB_ID
                      ,RATE_EXPENDITURE_TYPE
                      ,TA_DISPLAY_FLAG
                      ,RATE_BASED_FLAG
                      ,USE_TASK_SCHEDULE_FLAG
                      ,RATE_EXP_FUNC_CURR_CODE
                      ,RATE_EXPENDITURE_ORG_ID
                      ,INCUR_BY_RES_CLASS_CODE
                      ,INCUR_BY_ROLE_ID
                      ,RESOURCE_CLASS_FLAG
                      ,NAMED_ROLE
                      ,ETC_METHOD_CODE
                      ,MAPPED_FIN_TASK_ID)
                    (SELECT  ra.resource_assignment_id,
                             ra.budget_version_id,
                             ra.project_id,
                             ra.task_id,
                             ra.resource_list_member_id,
                             ra.unit_of_measure,
                             ra.track_as_labor_flag,
                             ra.resource_assignment_type,
                             ra.planning_start_date,
                             ra.planning_end_date,
                             ra.res_type_code,
                             ra.fc_res_type_code,
                             ra.resource_class_code,
                             ra.organization_id,
                             ra.job_id,
                             ra.person_id,
                             ra.expenditure_type,
                             ra.expenditure_category,
                             ra.revenue_category_code,
                             ra.event_type,
                             ra.supplier_id,
                             ra.project_role_id,
                             ra.person_type_code,
                             ra.non_labor_resource,
                             ra.bom_resource_id,
                             ra.inventory_item_id,
                             ra.item_category_id,
                             ra.billable_percent,
                             l_txn_src_code,
                             ra.mfc_cost_type_id,
                             ra.procure_resource_flag,
                             ra.incurred_by_res_flag,
                             ra.rate_job_id,
                             ra.rate_expenditure_type,
                             ra.ta_display_flag,
                             ra.rate_based_flag,
                             ra.use_task_schedule_flag,
                             ra.rate_exp_func_curr_code,
                             ra.rate_expenditure_org_id,
                             ra.incur_by_res_class_code,
                             ra.incur_by_role_id,
                             ra.resource_class_flag,
                             ra.named_role,
                             ra.etc_method_code,
                             v.mapped_fin_task_id
                     FROM    pa_resource_assignments ra,
                             pa_map_wp_to_fin_tasks_v v
                     WHERE
                             ra.budget_version_id      = l_source_bv_id
                     AND     v.mapped_fin_task_id      = p_task_id
                     AND     v.parent_structure_version_id =
                     p_fp_cols_rec_etc_wp.x_project_structure_version_id
                     AND     v.proj_element_id = ra.task_id);

     --dbms_output.put_line('No. of rows inserted in tmp1 : '|| sql%rowcount);


                     SELECT resource_assignment_id,
                            planning_start_date,
                            planning_end_date,
                            resource_list_member_id
                     BULK COLLECT
                     INTO   l_res_asg_id_tab,
                            l_start_date_tab,
                            l_end_date_tab,
                            l_res_list_member_id_tab  /* Bug 4070849 */
                     FROM   pa_fp_calc_amt_tmp1
                     WHERE NVL(mapped_fin_task_id,0) = p_task_id;

     --dbms_output.put_line('Count value for l_res_asg_id_tab : '||l_res_asg_id_tab.count );

                     IF l_res_asg_id_tab.count = 0 THEN
                        IF p_pa_debug_mode = 'Y' THEN
                           PA_DEBUG.Reset_Curr_Function;
                        END IF;
                        RETURN;
                     END IF;

                     SELECT o.projfunc_cost_rate_type
                           ,o.projfunc_cost_rate_date
                           ,o.projfunc_rev_rate_type
                           ,o.projfunc_rev_rate_date
                           ,o.project_cost_rate_type
                           ,o.project_cost_rate_date
                           ,o.project_rev_rate_type
                           ,o.project_rev_rate_date
                     BULK COLLECT
                     INTO   l_projfunc_cost_rate_type_tab,
                            l_projfunc_cost_rate_date_tab,
                            l_projfunc_rev_rate_type_tab,
                            l_projfunc_rev_rate_date_tab,
                            l_proj_cost_rate_type_tab,
                            l_proj_cost_rate_date_tab,
                            l_proj_rev_rate_type_tab,
                            l_proj_rev_rate_date_tab
                     FROM  pa_proj_fp_options o
                     WHERE o.fin_plan_version_id = p_budget_version_id;

                     SELECT  project_currency_code
                            ,projfunc_currency_code
                     BULK   COLLECT
                     INTO   l_proj_currency_code_tab,
                            l_projfunc_currency_code_tab
                     FROM   pa_projects_all
                     WHERE  project_id = p_project_id;

                     FOR i IN 1..l_res_asg_id_tab.count LOOP
                          --Calling  the Get_values_for_planning_Rate api
                            IF p_pa_debug_mode = 'Y' THEN
                                 pa_fp_gen_amount_utils.fp_debug
                                (p_called_mode => p_calling_context,
                                 p_msg         => 'Before calling
                                        pa_fp_gen_amount_utils.get_values_for_planning_rate',
                                 p_module_name => l_module_name,
                                 p_log_level   => 5);
                            END IF;
                            PA_FP_GEN_AMOUNT_UTILS.GET_VALUES_FOR_PLANNING_RATE
                            (p_project_id               => p_project_id,
                             p_budget_version_id        => p_budget_version_id,
                             p_resource_assignment_id   => l_res_asg_id_tab(i),
                             p_task_id                  => p_task_id,
                             p_resource_list_member_id  => l_res_list_member_id_tab(i), /* Bug 4070849 */
                             p_txn_currency_code        => l_txn_currency_code,
                             x_res_format_id            => l_res_format_id,
                             x_resource_asn_rec         => l_resource_asn_rec,
                             x_pa_tasks_rec             => l_pa_tasks_rec,
                             x_pa_projects_all_rec      => l_pa_projects_all_rec,
                             x_proj_fp_options_rec      => l_proj_fp_options_rec,
                             x_return_status            => x_return_status,
                             x_msg_count                => x_msg_count,
                             x_msg_data               => x_msg_data);
                           IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                           END IF;
                           IF p_pa_debug_mode = 'Y' THEN
                                 pa_fp_gen_amount_utils.fp_debug
                                (p_called_mode => p_calling_context,
                                 p_msg         => 'Status after calling
                                              pa_fp_gen_amount_utils.
                                              get_values_for_planning_rate'
                                              ||x_return_status,
                                 p_module_name => l_module_name,
                                 p_log_level   => 5);
                           END IF;
                         /* dbms_output.put_line('get_values_for_planning_rate api: '
                                                  ||X_RETURN_STATUS); */

                        /* Assigning project or task values to local variables */
                           IF p_task_id =0  THEN /* project level */
                               l_task_bill_rate_org_id      := NULL;
                               l_task_sch_discount          := NULL;
                               l_task_sch_date              := NULL;
                               l_task_nl_std_bill_rt_sch_id := NULL;
                               l_task_emp_bill_rate_sch_id  := NULL;
                               l_task_job_bill_rate_sch_id  := NULL;
                               l_task_lab_bill_rate_org_id  := NULL;
                               l_task_lab_sch_type          := NULL;
                               l_task_non_labor_sch_type    := NULL;
                               l_top_task_id                := NULL;
                               l_rate_task_id               := NULL;
                               /* If task level attributes are not found
                                  then the following atributes can be
                                  taken from the project level */
                               l_emp_bill_rate_sch_id := l_pa_projects_all_rec.x_emp_bill_rate_schedule_id;
                               l_job_bill_rate_sch_id := l_pa_projects_all_rec.x_job_bill_rate_schedule_id;
                               l_lab_bill_rate_org_id := l_pa_projects_all_rec.x_labor_bill_rate_org_id;
                               l_lab_sch_type         := l_pa_projects_all_rec.x_labor_sch_type;
                               l_non_labor_sch_type   := l_pa_projects_all_rec.x_non_labor_sch_type;
                          ELSE
                               l_task_bill_rate_org_id      := l_pa_tasks_rec.x_task_bill_rate_org_id;
                               l_task_sch_discount          := l_pa_tasks_rec.x_task_sch_discount;
                               l_task_sch_date              := l_pa_tasks_rec.x_task_sch_date;
                               l_task_nl_std_bill_rt_sch_id := l_pa_tasks_rec.x_task_nl_std_bill_rt_sch_id;
                               l_task_emp_bill_rate_sch_id  := l_pa_tasks_rec.x_task_emp_bill_rate_sch_id;
                               l_task_job_bill_rate_sch_id  := l_pa_tasks_rec.x_task_job_bill_rate_sch_id;
                               l_task_lab_bill_rate_org_id  := l_pa_tasks_rec.x_task_lab_bill_rate_org_id;
                               l_task_lab_sch_type          := l_pa_tasks_rec.x_task_lab_sch_type;
                               l_task_non_labor_sch_type    := l_pa_tasks_rec.x_task_non_labor_sch_type;
                               l_top_task_id                := l_pa_tasks_rec.x_top_task_id;
                               l_rate_task_id               := l_resource_asn_rec.x_rate_task_id;
                               /* Task level attributes are found
                                  the following atributes can be
                                  taken from the task level */
                               l_emp_bill_rate_sch_id        := l_task_emp_bill_rate_sch_id;
                               l_job_bill_rate_sch_id        := l_task_job_bill_rate_sch_id;
                               l_lab_bill_rate_org_id        := l_task_lab_bill_rate_org_id;
                               l_lab_sch_type                := l_task_lab_sch_type;
                               l_non_labor_sch_type          := l_task_non_labor_sch_type;
                          END IF;
                          IF l_proj_fp_options_rec.
                             x_fp_budget_version_type = 'REVENUE' THEN
                                   l_calculate_mode  := 'REVENUE';
                          ELSIF l_proj_fp_options_rec.
                                x_fp_budget_version_type = 'COST' THEN
                                   l_calculate_mode  := 'COST';
                          ELSIF l_proj_fp_options_rec.
                                x_fp_budget_version_type = 'ALL' THEN
                                   l_calculate_mode  := 'COST_REVENUE';
                          END IF;

                          --Calling  the Get_planning_Rates api
                            IF p_pa_debug_mode = 'Y' THEN
                               pa_fp_gen_amount_utils.fp_debug
                                (p_called_mode => p_calling_context,
                                 p_msg         => 'Before calling
                                       pa_plan_revenue.Get_planning_Rates',
                                 p_module_name => l_module_name,
                                 p_log_level   => 5);
                            END IF;
                            PA_PLAN_REVENUE.GET_PLANNING_RATES
                             (p_project_id                 => p_project_id
                             ,p_task_id                    => l_rate_task_id
                             ,p_top_task_id                => l_top_task_id
                             ,p_person_id                  => l_resource_asn_rec.x_person_id
                             ,p_job_id                     => l_resource_asn_rec.x_job_id
                             ,p_bill_job_grp_id            => l_pa_projects_all_rec.x_bill_job_group_id
                             ,p_resource_class             => l_resource_asn_rec.x_resource_class_code
                             ,p_planning_resource_format   => l_res_format_id
                             ,p_use_planning_rates_flag    => l_proj_fp_options_rec.x_fp_use_planning_rt_flag
                             ,p_rate_based_flag            => l_resource_asn_rec.x_rate_based_flag
                             ,p_uom                        => l_resource_asn_rec.x_unit_of_measure
                             ,p_system_linkage             => NULL
                             ,p_project_organz_id          => l_pa_projects_all_rec.x_carrying_out_organization_id
                             ,p_rev_res_class_rate_sch_id  => l_proj_fp_options_rec.x_fp_res_cl_bill_rate_sch_id
                             ,p_cost_res_class_rate_sch_id => l_proj_fp_options_rec.x_fp_res_cl_raw_cost_sch_id
                             ,p_rev_task_nl_rate_sch_id    => l_task_nl_std_bill_rt_sch_id
                             ,p_rev_proj_nl_rate_sch_id    => l_pa_projects_all_rec.x_non_lab_std_bill_rt_sch_id
                             ,p_rev_job_rate_sch_id        => l_job_bill_rate_sch_id
                             ,p_rev_emp_rate_sch_id        => l_emp_bill_rate_sch_id
                             ,p_plan_rev_job_rate_sch_id   => l_proj_fp_options_rec.x_fp_rev_job_rate_sch_id
                             ,p_plan_cost_job_rate_sch_id  => l_proj_fp_options_rec.x_fp_cost_job_rate_sch_id
                             ,p_plan_rev_emp_rate_sch_id   => l_proj_fp_options_rec.x_fp_rev_emp_rate_sch_id
                             ,p_plan_cost_emp_rate_sch_id  => l_proj_fp_options_rec.x_fp_cost_emp_rate_sch_id
                             ,p_plan_rev_nlr_rate_sch_id   => l_proj_fp_options_rec.x_fp_rev_non_lab_rs_rt_sch_id
                             ,p_plan_cost_nlr_rate_sch_id  => l_proj_fp_options_rec.x_fp_cost_non_lab_rs_rt_sch_id
                             ,p_plan_burden_cost_sch_id    => l_proj_fp_options_rec.x_fp_cost_burden_rate_sch_id
                             ,p_calculate_mode             => l_calculate_mode
                             ,p_mcb_flag                   => l_pa_projects_all_rec.x_multi_currency_billing_flag
                             ,p_cost_rate_multiplier       => l_cost_rate_multiplier
                             ,p_bill_rate_multiplier       => l_bill_rate_multiplier
                             ,p_quantity                   => l_txn_plan_quantity
                             ,p_item_date                  => l_budget_lines_start_date
                             ,p_cost_sch_type              => l_cost_sch_type
                             ,p_labor_sch_type             => l_lab_sch_type
                             ,p_non_labor_sch_type         => l_non_labor_sch_type
                             ,p_labor_schdl_discnt         => NULL
                             ,p_labor_bill_rate_org_id     => l_lab_bill_rate_org_id
                             ,p_labor_std_bill_rate_schdl  => NULL
                             ,p_labor_schdl_fixed_date     => NULL
                             ,p_assignment_id              => l_assignment_id
                             ,p_project_org_id             => l_pa_projects_all_rec.x_org_id
                             ,p_project_type               => l_pa_projects_all_rec.x_project_type
                             ,p_expenditure_type           => nvl(l_resource_asn_rec.x_expenditure_type,
                                                              l_resource_asn_rec.x_rate_expenditure_type)
                             ,p_non_labor_resource         => l_resource_asn_rec.x_non_labor_resource
                             ,p_incurred_by_organz_id      => l_resource_asn_rec.x_organization_id
                             ,p_override_to_organz_id      => l_resource_asn_rec.x_organization_id
                             ,p_expenditure_org_id         => nvl(l_resource_asn_rec.x_rate_expenditure_org_id,
                                                                  l_pa_projects_all_rec.x_org_id)
                             ,p_assignment_precedes_task   => l_pa_projects_all_rec.x_assign_precedes_task
                             ,p_planning_transaction_id    => l_budget_line_id
                             ,p_task_bill_rate_org_id      => l_task_bill_rate_org_id
                             ,p_project_bill_rate_org_id   => l_pa_projects_all_rec.x_non_labor_bill_rate_org_id
                             ,p_nlr_organization_id        => nvl(l_resource_asn_rec.x_organization_id,
                                                              l_pa_projects_all_rec.x_carrying_out_organization_id)
                             ,p_project_sch_date           => l_pa_projects_all_rec.x_non_labor_sch_fixed_date
                             ,p_task_sch_date              => l_task_sch_date
                             ,p_project_sch_discount       => l_pa_projects_all_rec.x_non_labor_schedule_discount
                             ,p_task_sch_discount          => l_task_sch_discount
                             ,p_inventory_item_id          => l_resource_asn_rec.x_inventory_item_id
                             ,p_BOM_resource_Id            => l_resource_asn_rec.x_bom_resource_id
                             ,p_mfc_cost_type_id           => l_resource_asn_rec.x_mfc_cost_type_id
                             ,p_item_category_id           => l_resource_asn_rec.x_item_category_id
                             ,p_mfc_cost_source            => l_mfc_cost_source
                             ,p_cost_override_rate         => l_rw_cost_rate_override
                             ,p_revenue_override_rate      => l_bill_rate_override
                             ,p_override_burden_cost_rate  => l_burden_cost_rate_override
                             ,p_override_currency_code     => l_txn_currency_code_override
                             ,p_txn_currency_code          => l_txn_currency_code
                             ,p_raw_cost                   => l_txn_raw_cost
                             ,p_burden_cost                => l_txn_burdened_cost
                             ,p_raw_revenue                => l_txn_revenue
                             ,x_bill_rate                  => l_bill_rate
                             ,x_cost_rate                  => l_cost_rate
                             ,x_burden_cost_rate           => l_burden_cost_rate
                             ,x_burden_multiplier          => l_burden_multiplier
                             ,x_raw_cost                   => l_raw_cost
                             ,x_burden_cost                => l_burden_cost
                             ,x_raw_revenue                => l_raw_revenue
                             ,x_bill_markup_percentage     => l_bill_markup_percentage
                             ,x_cost_txn_curr_code         => l_cost_txn_curr_code
                             ,x_rev_txn_curr_code          => l_rev_txn_curr_code
                             ,x_raw_cost_rejection_code    => l_raw_cost_rejection_code
                             ,x_burden_cost_rejection_code => l_burden_cost_rejection_code
                             ,x_revenue_rejection_code     => l_revenue_rejection_code
                             ,x_cost_ind_compiled_set_id   => l_cost_ind_compiled_set_id
                             ,x_return_status              => x_return_status
                             ,x_msg_data                   => x_msg_data
                             ,x_msg_count                  => x_msg_count);
                             IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                             END IF;
                             IF p_pa_debug_mode = 'Y' THEN
                                  pa_fp_gen_amount_utils.fp_debug
                                   (p_called_mode => p_calling_context,
                                    p_msg         => 'Status after calling
                                                     pa_plan_revenue.Get_planning_Rates'
                                                     ||x_return_status,
                                    p_module_name => l_module_name,
                                    p_log_level   => 5);
                             END IF;
                           /*dbms_output.put_line('Status of Get_planning_Rates api: '
                                                   ||X_RETURN_STATUS); */

                           l_ins_bill_rate          := l_bill_rate;
                           l_ins_cost_rate          := l_cost_rate;
                           l_ins_burd_cost_rate     := l_burden_cost_rate;
                           l_ins_burd_multiplier    := l_burden_multiplier;
                           l_ins_pfc_raw_cost_tab(l_ins_pfc_raw_cost_tab.count+1)
                           := l_raw_cost;
                           l_ins_pfc_burd_cost_tab(l_ins_pfc_burd_cost_tab.count+1)
                           := l_burden_cost;
                           l_ins_pfc_revenue_tab(l_ins_pfc_revenue_tab.count+1)
                           := l_raw_revenue;
                           l_ins_bill_markup_perc   := l_bill_markup_percentage;
                           l_ins_cost_txn_curr_code := l_cost_txn_curr_code;
                           l_ins_rev_txn_curr_code  := l_rev_txn_curr_code;
                           l_ins_raw_cost_rej_code  := l_raw_cost_rejection_code;
                           l_ins_burd_cost_rej_code := l_burden_cost_rejection_code;
                           l_ins_rev_rej_code       := l_revenue_rejection_code;
                           l_ins_cost_ind_com_set_id:= l_cost_ind_compiled_set_id;

                          IF p_fp_cols_rec.x_plan_in_multi_curr_flag = 'N' AND
                             l_cost_txn_curr_code <>
                             p_fp_cols_rec.X_PROJECT_CURRENCY_CODE THEN
                             --Calling  the conv_mc_bulk api
                               IF p_pa_debug_mode = 'Y' THEN
                                  pa_fp_gen_amount_utils.fp_debug
                                   (p_called_mode => p_calling_context,
                                    p_msg         => 'Before calling
                                                          pa_fp_multi_currency_pkg.conv_mc_bulk',
                                    p_module_name => l_module_name,
                                    p_log_level   => 5);
                               END IF;

                               l_res_asn_id_tab.delete;
                               l_start_date_tab.delete;
                               l_end_date_tab.delete;
                               l_txn_currency_code_tab.delete;
                               l_txn_rw_cost_tab.delete;
                               l_txn_burdend_cost_tab.delete;
                               l_txn_rev_tab.delete;
                               l_projfunc_currency_code_tab.delete;
                               l_projfunc_cost_rate_type_tab.delete;
                               l_projfunc_cost_rate_tab.delete;
                               l_projfunc_cost_rate_date_tab.delete;
                               l_projfunc_rev_rate_type_tab.delete;
                               l_projfunc_rev_rate_tab.delete;
                               l_projfunc_rev_rate_date_tab.delete;
                               l_projfunc_raw_cost_tab.delete;
                               l_projfunc_burdened_cost_tab.delete;
                               l_projfunc_revenue_tab.delete;
                               l_projfunc_rejection_tab.delete;
                               l_proj_raw_cost_tab.delete;
                               l_proj_burdened_cost_tab.delete;
                               l_proj_revenue_tab.delete;
                               l_proj_rejection_tab.delete;
                               l_proj_currency_code_tab.delete;
                               l_proj_cost_rate_type_tab.delete;
                               l_proj_cost_rate_tab.delete;
                               l_proj_cost_rate_date_tab.delete;
                               l_proj_rev_rate_type_tab.delete;
                               l_proj_rev_rate_tab.delete;
                               l_proj_rev_rate_date_tab.delete;
                               l_user_validate_flag_tab.delete;

                               PA_FP_MULTI_CURRENCY_PKG.CONV_MC_BULK(
                                   p_resource_assignment_id_tab  => l_res_asn_id_tab
                                  ,p_start_date_tab              => l_start_date_tab
                                  ,p_end_date_tab                => l_end_date_tab
                                  ,p_txn_currency_code_tab       => l_txn_currency_code_tab
                                  ,p_txn_raw_cost_tab            => l_txn_rw_cost_tab
                                  ,p_txn_burdened_cost_tab       => l_txn_burdend_cost_tab
                                  ,p_txn_revenue_tab             => l_txn_rev_tab
                                  ,p_projfunc_currency_code_tab  => l_projfunc_currency_code_tab
                                  ,p_projfunc_cost_rate_type_tab => l_projfunc_cost_rate_type_tab
                                  ,p_projfunc_cost_rate_tab      => l_projfunc_cost_rate_tab
                                  ,p_projfunc_cost_rate_date_tab => l_projfunc_cost_rate_date_tab
                                  ,p_projfunc_rev_rate_type_tab  => l_projfunc_rev_rate_type_tab
                                  ,p_projfunc_rev_rate_tab       => l_projfunc_rev_rate_tab
                                  ,p_projfunc_rev_rate_date_tab  => l_projfunc_rev_rate_date_tab
                                  ,x_projfunc_raw_cost_tab       => l_projfunc_raw_cost_tab
                                  ,x_projfunc_burdened_cost_tab  => l_projfunc_burdened_cost_tab
                                  ,x_projfunc_revenue_tab        => l_projfunc_revenue_tab
                                  ,x_projfunc_rejection_tab      => l_projfunc_rejection_tab
                                  ,p_proj_currency_code_tab      => l_proj_currency_code_tab
                                  ,p_proj_cost_rate_type_tab     => l_proj_cost_rate_type_tab
                                  ,p_proj_cost_rate_tab          => l_proj_cost_rate_tab
                                  ,p_proj_cost_rate_date_tab     => l_proj_cost_rate_date_tab
                                  ,p_proj_rev_rate_type_tab      => l_proj_rev_rate_type_tab
                                  ,p_proj_rev_rate_tab           => l_proj_rev_rate_tab
                                  ,p_proj_rev_rate_date_tab      => l_proj_rev_rate_date_tab
                                  ,x_proj_raw_cost_tab           => l_proj_raw_cost_tab
                                  ,x_proj_burdened_cost_tab      => l_proj_burdened_cost_tab
                                  ,x_proj_revenue_tab            => l_proj_revenue_tab
                                  ,x_proj_rejection_tab          => l_proj_rejection_tab
                                  ,p_user_validate_flag_tab      => l_user_validate_flag_tab
                                  ,p_calling_module              => 'FORECAST_GENERATION'-- Added for Bug#5395732
                                  ,x_return_status               => x_return_status
                                  ,x_msg_count                   => x_msg_count
                                  ,x_msg_data                    => x_msg_data);
                                 IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                                     RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                                 END IF;
                                 IF p_pa_debug_mode = 'Y' THEN
                                    pa_fp_gen_amount_utils.fp_debug
                                    (p_called_mode => p_calling_context,
                                     p_msg         => 'Status after calling
                                                     pa_fp_multi_currency_pkg.conv_mc_bulk: '
                                                    ||x_return_status,
                                     p_module_name => l_module_name,
                                     p_log_level   => 5);
                                 END IF;
                              /* dbms_output.put_line('Status of conv_mc_bulk api: '
                                                       ||X_RETURN_STATUS); */
                          END IF;
                            l_ins_pfc_raw_cost_tab := l_projfunc_raw_cost_tab;
                            l_ins_pfc_burd_cost_tab:= l_projfunc_burdened_cost_tab;
                            l_ins_pfc_revenue_tab  := l_projfunc_revenue_tab;
                            l_ins_pfc_rejection_tab:= l_projfunc_rejection_tab;
                            l_ins_pc_raw_cost_tab  := l_proj_raw_cost_tab;
                            l_ins_pc_burdened_cost_tab:= l_proj_burdened_cost_tab;
                            l_ins_pc_revenue_tab   := l_proj_revenue_tab;
                            l_ins_pc_rejection_tab := l_proj_rejection_tab;
                        END LOOP;

                  /* bulk insert */
                  FORALL m IN 1..l_res_asn_id_tab.count
                        INSERT INTO pa_fp_calc_amt_tmp2
                               (resource_assignment_id,
                                total_pc_raw_cost,
                                total_pc_burdened_cost,
                                total_pc_revenue,
                                total_pfc_raw_cost,
                                total_pfc_burdened_cost,
                                total_pfc_revenue,
                                transaction_source_code )
                        VALUES
                               (l_res_asn_id_tab(m),
                                l_ins_pc_raw_cost_tab(m),
                                l_ins_pc_burdened_cost_tab(m),
                                l_ins_pc_revenue_tab(m),
                                l_ins_pfc_raw_cost_tab(m),
                                l_ins_pfc_burd_cost_tab(m),
                                l_ins_pfc_revenue_tab(m),
                                l_txn_src_code);
      END IF;
   /* select not required as the amounts will be populated
     in the tmp table.
                     SELECT   total_plan_quantity,
                              total_txn_raw_cost,
                              total_txn_burdened_cost,
                              total_txn_revenue
                     INTO     x_txn_amt_rec.quantity_sum,
                              x_txn_amt_rec.txn_raw_cost_sum,
                              x_txn_amt_rec.txn_burdened_cost_sum,
                              x_txn_amt_rec.txn_revenue_sum
                     FROM     pa_fp_calc_amt_tmp2;
         */
    IF p_pa_debug_mode = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
    END IF;

EXCEPTION
      WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_called_mode => p_calling_context,
                p_msg         => 'Invalid Resource assignment Id',
                p_module_name => l_module_name,
                p_log_level   => 5);
              PA_DEBUG.Reset_Curr_Function;
          END IF;
          RAISE;

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
               (p_called_mode => p_calling_context,
                p_msg         => 'Invalid Arguments Passed',
                p_module_name => l_module_name,
                p_log_level   => 5);
              PA_DEBUG.Reset_Curr_Function;
        END IF;
        RAISE;

      WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_data      := SUBSTR(SQLERRM,1,240);
           FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_FCST_AMT_PVT'
              ,p_procedure_name => 'GET_TOTAL_PLAN_TXN_AMTS');
           IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_called_mode => p_calling_context,
                p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                p_module_name => l_module_name,
                p_log_level   => 5);
                PA_DEBUG.Reset_Curr_Function;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GET_TOTAL_PLAN_TXN_AMTS;

PROCEDURE UPDATE_TOTAL_PLAN_AMTS
          (P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           X_RETURN_STATUS           OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT               OUT  NOCOPY NUMBER,
           X_MSG_DATA                OUT  NOCOPY VARCHAR2) IS

l_module_name         VARCHAR2(200) := 'pa.plsql.pa_fp_gen_fcst_amt_pub.update_total_plan_amts';

l_last_updated_by              NUMBER := FND_GLOBAL.user_id;
l_last_update_login            NUMBER := FND_GLOBAL.login_id;
l_sysdate                      DATE   := SYSDATE;
BEGIN
      --Setting initial values
      X_MSG_COUNT := 0;
      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

      IF p_pa_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function     => 'UPDATE_TOTAL_PLAN_AMTS'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
      END IF;

      UPDATE pa_budget_lines
      SET    raw_cost              = nvl(raw_cost,0) + nvl(init_raw_cost,0),
             burdened_cost         = nvl(burdened_cost,0) + nvl(init_burdened_cost,0),
             revenue               = nvl(revenue,0) + nvl(init_revenue,0),
             project_raw_cost      = nvl(project_raw_cost,0) + nvl(project_init_raw_cost,0),
             project_burdened_cost = nvl(project_burdened_cost,0) +
                                         nvl(project_init_burdened_cost,0),
             project_revenue       = nvl(project_revenue,0)  + nvl(project_init_revenue,0),
             txn_raw_cost          = nvl(txn_raw_cost,0) + nvl(txn_init_raw_cost,0),
             txn_burdened_cost     = nvl(txn_burdened_cost,0) +
                                         nvl(txn_init_burdened_cost,0),
             txn_revenue           = nvl(txn_revenue,0) + nvl(txn_init_revenue,0),
             quantity              = nvl(quantity,0) + nvl(init_quantity,0),
             LAST_UPDATE_DATE      = l_sysdate,
             LAST_UPDATED_BY       = l_last_updated_by,
             LAST_UPDATE_LOGIN     = l_last_update_login
      WHERE  budget_version_id     = p_budget_version_id
      and    (resource_assignment_id,txn_currency_code) in
             (select target_res_asg_id,etc_currency_code
              from   PA_FP_CALC_AMT_TMP2
              where  transaction_source_code = 'ETC');
      -- Above and clause added for bug 4247647 ...

      IF p_pa_debug_mode = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
      END IF;

EXCEPTION
      WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_data      := SUBSTR(SQLERRM,1,240);
           FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_FCST_AMT_PVT'
              ,p_procedure_name => 'UPDATE_TOTAL_PLAN_AMTS');
           IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                p_module_name => l_module_name,
                p_log_level   => 5);
                PA_DEBUG.Reset_Curr_Function;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END UPDATE_TOTAL_PLAN_AMTS;

PROCEDURE GET_ACTUAL_TXN_AMOUNT
          (P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_TASK_ID                 IN          PA_RESOURCE_ASSIGNMENTS.TASK_ID%TYPE,
           P_RES_LIST_MEMBER_ID      IN          PA_RESOURCE_ASSIGNMENTS.RESOURCE_LIST_MEMBER_ID%TYPE,
           P_RES_ASG_ID              IN          PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE,
           P_TXN_CURRENCY_CODE       IN          PA_BUDGET_LINES.TXN_CURRENCY_CODE%TYPE,
           P_CURRENCY_FLAG           IN          VARCHAR2,
           P_FP_COLS_REC             IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_ACTUAL_FROM_DATE        IN          PA_PERIODS_ALL.START_DATE%TYPE,
           P_ACTUAL_TO_DATE          IN          PA_PERIODS_ALL.START_DATE%TYPE,
           X_TXN_AMT_REC             OUT  NOCOPY PA_FP_GEN_FCST_AMT_PUB.TXN_AMT_REC_TYP,
           X_RETURN_STATUS           OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT               OUT  NOCOPY NUMBER,
           X_MSG_DATA                OUT  NOCOPY VARCHAR2) IS

L_MODULE_NAME         VARCHAR2(200) := 'PA.PLSQL.PA_FP_GEN_FCST_AMT_PUB.GET_ACTUAL_TXN_AMOUNT';
L_RES_ASG_ID          PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE;

L_RATE_BASED_FLAG     VARCHAR2(1);
/*'TC' REPRESENTS TXN CURRENCY CODE
  'PC' REPRESENTS PROJECT CURRENCY CODE*/
L_CURRENCY_FLAG       VARCHAR2(2) := 'TC';

BEGIN
    --SETTING INITIAL VALUES
    X_MSG_COUNT := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.SET_CURR_FUNCTION( P_FUNCTION     => 'GET_ACTUAL_TXN_AMOUNT'
                                    ,P_DEBUG_MODE   =>  P_PA_DEBUG_MODE);
    END IF;

    X_TXN_AMT_REC.QUANTITY_SUM          := 0;
    X_TXN_AMT_REC.TXN_RAW_COST_SUM      := 0;
    X_TXN_AMT_REC.TXN_BURDENED_COST_SUM := 0;
    X_TXN_AMT_REC.TXN_REVENUE_SUM       := 0;
    X_TXN_AMT_REC.NO_OF_PERIODS         := 0;

    IF P_FP_COLS_REC.X_FIN_PLAN_LEVEL_CODE <> 'P' OR
      (P_FP_COLS_REC.X_VERSION_TYPE = 'REVENUE' AND
       P_FP_COLS_REC.X_GEN_ETC_SRC_CODE = 'AVERAGE_ACTUALS') THEN
        SELECT NVL(rate_based_flag,'N') INTO l_rate_based_flag
        FROM pa_resource_assignments
        WHERE resource_assignment_id =  P_RES_ASG_ID;
    ELSIF P_FP_COLS_REC.X_FIN_PLAN_LEVEL_CODE = 'P' THEN
        SELECT NVL(rate_based_flag,'N') INTO l_rate_based_flag
        FROM pa_resource_assignments
        WHERE budget_version_id = p_budget_version_id
              AND resource_list_member_id = p_res_list_member_id
              AND NVL(task_id, 0) = 0;
    END IF;
    l_currency_flag := P_CURRENCY_FLAG;
    IF   p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
        /* Getting the sum of init qty,raw_cost,burdened_cost,rev
           between actual_from_date and actual_to_date for the given period(PA or GL) */
       BEGIN
           -- Bug 4233720 : When the Target version is Revenue with ETC Source of
           -- Average of Actuals, we should get that Actual data from the Target
           -- budget lines instead of from the PA_FP_FCST_GEN_TMP1 table.

           IF P_FP_COLS_REC.X_FIN_PLAN_LEVEL_CODE <> 'P' OR
             (P_FP_COLS_REC.X_VERSION_TYPE = 'REVENUE' AND
              P_FP_COLS_REC.X_GEN_ETC_SRC_CODE = 'AVERAGE_ACTUALS') THEN
               SELECT   count(*),
                        SUM (DECODE(l_currency_flag,
                              'TC', NVL(init_quantity,0),
                              'PC', DECODE(l_rate_based_flag,
                                    'Y', NVL(init_quantity,0),
                                    decode(P_FP_COLS_REC.x_version_type,
                                          'REVENUE',nvl(project_init_revenue,0),
                                           NVL(project_init_raw_cost,0)))
                             )),
                        SUM (DECODE(l_currency_flag,
                           'TC', NVL(txn_init_raw_cost,0),
                           'PC', NVL(project_init_raw_cost,0))),
                        SUM (DECODE(l_currency_flag,
                           'TC', NVL(txn_init_burdened_cost,0),
                           'PC', NVL(project_init_burdened_cost,0))),
                        SUM (DECODE(l_currency_flag,
                           'TC', NVL(txn_init_revenue,0),
                           'PC', NVL(project_init_revenue,0)))
               INTO     x_txn_amt_rec.no_of_periods,
                        x_txn_amt_rec.quantity_sum,
                        x_txn_amt_rec.txn_raw_cost_sum,
                        x_txn_amt_rec.txn_burdened_cost_sum,
                        x_txn_amt_rec.txn_revenue_sum
               FROM     pa_budget_lines
               WHERE    resource_assignment_id = P_RES_ASG_ID
               AND      start_date             >= p_actual_from_date
               AND      start_date             <= p_actual_to_date;

               IF l_currency_flag = 'PC' THEN
                   SELECT   COUNT(DISTINCT period_name) INTO x_txn_amt_rec.no_of_periods
                   FROM     pa_budget_lines
                   WHERE    resource_assignment_id = P_RES_ASG_ID
                   AND      start_date             >= p_actual_from_date
                   AND      start_date             <= p_actual_to_date;
               END IF;
           ELSIF P_FP_COLS_REC.X_FIN_PLAN_LEVEL_CODE = 'P' THEN
               IF p_fp_cols_rec.x_time_phased_code = 'P' THEN
                   IF P_FP_COLS_REC.x_version_type = 'ALL' THEN
                       SELECT   /*+ INDEX(tmp,PA_FP_FCST_GEN_TMP1_N1)*/
                                count(*),
                                SUM (DECODE(l_rate_based_flag, 'Y',
                                    NVL(quantity,0),
                                    DECODE(l_currency_flag,
                                        'PC', NVL(prj_raw_cost,0),
                                        'TC', NVL(txn_raw_cost,0))
                                    )),
                                SUM (DECODE(l_currency_flag,
                                    'TC', NVL(txn_raw_cost,0),
                                    'PC', NVL(prj_raw_cost,0))),
                                SUM (DECODE(l_currency_flag,
                                    'TC', NVL(txn_brdn_cost,0),
                                    'PC', NVL(prj_brdn_cost,0))),
                                SUM (DECODE(l_currency_flag,
                                    'TC', NVL(txn_revenue,0),
                                    'PC', NVL(prj_revenue,0)))
                       INTO     x_txn_amt_rec.no_of_periods,
                                x_txn_amt_rec.quantity_sum,
                                x_txn_amt_rec.txn_raw_cost_sum,
                                x_txn_amt_rec.txn_burdened_cost_sum,
                                x_txn_amt_rec.txn_revenue_sum
                       FROM     PA_FP_FCST_GEN_TMP1 tmp,
                                pa_periods_all pd
                       WHERE    tmp.data_type_code = 'TARGET_FP'
                       AND      tmp.project_element_id = P_TASK_ID
                       AND      tmp.res_list_member_id = P_RES_LIST_MEMBER_ID
                       AND      (NVL(tmp.quantity,0) <> 0
                       OR       NVL(tmp.txn_raw_cost,0) <> 0
                       OR       NVL(tmp.txn_brdn_cost,0) <> 0
                       OR       NVL(tmp.txn_revenue,0) <> 0)
                       AND      pd.period_name = tmp.period_name
                       AND      pd.org_id = p_fp_cols_rec.x_org_id
                       AND      pd.start_date             >= p_actual_from_date
                       AND      pd.start_date             <= p_actual_to_date;
                   ELSIF P_FP_COLS_REC.x_version_type = 'COST' THEN
                       SELECT   /*+ INDEX(tmp,PA_FP_FCST_GEN_TMP1_N1)*/
                                count(*),
                                SUM (DECODE(l_rate_based_flag, 'Y',
                                    NVL(quantity,0),
                                    DECODE(l_currency_flag,
                                        'PC', NVL(prj_raw_cost,0),
                                        'TC', NVL(txn_raw_cost,0))
                                    )),
                                SUM (DECODE(l_currency_flag,
                                    'TC', NVL(txn_raw_cost,0),
                                    'PC', NVL(prj_raw_cost,0))),
                                SUM (DECODE(l_currency_flag,
                                    'TC', NVL(txn_brdn_cost,0),
                                    'PC', NVL(prj_brdn_cost,0))),
                                SUM (DECODE(l_currency_flag,
                                    'TC', NVL(txn_revenue,0),
                                    'PC', NVL(prj_revenue,0)))
                       INTO     x_txn_amt_rec.no_of_periods,
                                x_txn_amt_rec.quantity_sum,
                                x_txn_amt_rec.txn_raw_cost_sum,
                                x_txn_amt_rec.txn_burdened_cost_sum,
                                x_txn_amt_rec.txn_revenue_sum
                       FROM     PA_FP_FCST_GEN_TMP1 tmp,
                                pa_periods_all pd
                       WHERE    tmp.data_type_code = 'TARGET_FP'
                       AND      tmp.project_element_id = P_TASK_ID
                       AND      tmp.res_list_member_id = P_RES_LIST_MEMBER_ID
                       AND      (NVL(tmp.quantity,0) <> 0
                       OR       NVL(tmp.txn_raw_cost,0) <> 0
                       OR       NVL(tmp.txn_brdn_cost,0) <> 0)
                       AND      pd.period_name = tmp.period_name
                       AND      pd.org_id = p_fp_cols_rec.x_org_id
                       AND      pd.start_date             >= p_actual_from_date
                       AND      pd.start_date             <= p_actual_to_date;
                   ELSIF P_FP_COLS_REC.x_version_type = 'REVENUE' THEN
                       SELECT   /*+ INDEX(tmp,PA_FP_FCST_GEN_TMP1_N1)*/
                                count(*),
                                SUM (DECODE(l_rate_based_flag, 'Y',
                                    NVL(quantity,0),
                                    DECODE(l_currency_flag,
                                        'PC', NVL(prj_revenue,0),
                                        'TC', NVL(txn_revenue,0))
                                    )),
                                SUM (DECODE(l_currency_flag,
                                    'TC', NVL(txn_raw_cost,0),
                                    'PC', NVL(prj_raw_cost,0))),
                                SUM (DECODE(l_currency_flag,
                                    'TC', NVL(txn_brdn_cost,0),
                                    'PC', NVL(prj_brdn_cost,0))),
                                SUM (DECODE(l_currency_flag,
                                    'TC', NVL(txn_revenue,0),
                                    'PC', NVL(prj_revenue,0)))
                       INTO     x_txn_amt_rec.no_of_periods,
                                x_txn_amt_rec.quantity_sum,
                                x_txn_amt_rec.txn_raw_cost_sum,
                                x_txn_amt_rec.txn_burdened_cost_sum,
                                x_txn_amt_rec.txn_revenue_sum
                       FROM     PA_FP_FCST_GEN_TMP1 tmp,
                                pa_periods_all pd
                       WHERE    tmp.data_type_code = 'TARGET_FP'
                       AND      tmp.project_element_id = P_TASK_ID
                       AND      tmp.res_list_member_id = P_RES_LIST_MEMBER_ID
                       AND      (NVL(tmp.quantity,0) <> 0
                       OR       NVL(tmp.txn_revenue,0) <> 0)
                       AND      pd.period_name = tmp.period_name
                       AND      pd.org_id = p_fp_cols_rec.x_org_id
                       AND      pd.start_date             >= p_actual_from_date
                       AND      pd.start_date             <= p_actual_to_date;
                   END IF;
                   IF l_currency_flag = 'PC' THEN
                       IF P_FP_COLS_REC.x_version_type = 'ALL' THEN
                           SELECT   /*+ INDEX(tmp,PA_FP_FCST_GEN_TMP1_N1)*/
                                    COUNT(DISTINCT pd.period_name) INTO x_txn_amt_rec.no_of_periods
                           FROM     PA_FP_FCST_GEN_TMP1 tmp,
                                    pa_periods_all pd
                           WHERE    tmp.data_type_code = 'TARGET_FP'
                           AND      tmp.project_element_id = P_TASK_ID
                           AND      tmp.res_list_member_id = P_RES_LIST_MEMBER_ID
                           AND      (NVL(tmp.quantity,0) <> 0
                           OR       NVL(tmp.txn_raw_cost,0) <> 0
                           OR       NVL(tmp.txn_brdn_cost,0) <> 0
                           OR       NVL(tmp.txn_revenue,0) <> 0)
                           AND      pd.period_name = tmp.period_name
                           AND      pd.org_id = p_fp_cols_rec.x_org_id
                           AND      pd.start_date             >= p_actual_from_date
                           AND      pd.start_date             <= p_actual_to_date;
                       ELSIF P_FP_COLS_REC.x_version_type = 'COST' THEN
                           SELECT   /*+ INDEX(tmp,PA_FP_FCST_GEN_TMP1_N1)*/
                                    COUNT(DISTINCT pd.period_name) INTO x_txn_amt_rec.no_of_periods
                           FROM     PA_FP_FCST_GEN_TMP1 tmp,
                                    pa_periods_all pd
                           WHERE    tmp.data_type_code = 'TARGET_FP'
                           AND      tmp.project_element_id = P_TASK_ID
                           AND      tmp.res_list_member_id = P_RES_LIST_MEMBER_ID
                           AND      (NVL(tmp.quantity,0) <> 0
                           OR       NVL(tmp.txn_raw_cost,0) <> 0
                           OR       NVL(tmp.txn_brdn_cost,0) <> 0)
                           AND      pd.period_name = tmp.period_name
                           AND      pd.org_id = p_fp_cols_rec.x_org_id
                           AND      pd.start_date             >= p_actual_from_date
                           AND      pd.start_date             <= p_actual_to_date;
                       ELSIF P_FP_COLS_REC.x_version_type = 'REVENUE' THEN
                           SELECT   /*+ INDEX(tmp,PA_FP_FCST_GEN_TMP1_N1)*/
                                    COUNT(DISTINCT pd.period_name) INTO x_txn_amt_rec.no_of_periods
                           FROM     PA_FP_FCST_GEN_TMP1 tmp,
                                    pa_periods_all pd
                           WHERE    tmp.data_type_code = 'TARGET_FP'
                           AND      tmp.project_element_id = P_TASK_ID
                           AND      tmp.res_list_member_id = P_RES_LIST_MEMBER_ID
                           AND      (NVL(tmp.quantity,0) <> 0
                           OR       NVL(tmp.txn_revenue,0) <> 0)
                           AND      pd.period_name = tmp.period_name
                           AND      pd.org_id = p_fp_cols_rec.x_org_id
                           AND      pd.start_date             >= p_actual_from_date
                           AND      pd.start_date             <= p_actual_to_date;
                       END IF;
                   END IF;
               ELSIF p_fp_cols_rec.x_time_phased_code = 'G' THEN
                   IF P_FP_COLS_REC.x_version_type = 'ALL' THEN
                       SELECT   /*+ INDEX(tmp,PA_FP_FCST_GEN_TMP1_N1)*/
                                count(*),
                                SUM (DECODE(l_rate_based_flag, 'Y',
                                    NVL(quantity,0),
                                    DECODE(l_currency_flag,
                                        'PC', NVL(prj_raw_cost,0),
                                        'TC', NVL(txn_raw_cost,0))
                                    )),
                                SUM (DECODE(l_currency_flag,
                                    'TC', NVL(txn_raw_cost,0),
                                    'PC', NVL(prj_raw_cost,0))),
                                SUM (DECODE(l_currency_flag,
                                    'TC', NVL(txn_brdn_cost,0),
                                    'PC', NVL(prj_brdn_cost,0))),
                                SUM (DECODE(l_currency_flag,
                                    'TC', NVL(txn_revenue,0),
                                    'PC', NVL(prj_revenue,0)))
                       INTO     x_txn_amt_rec.no_of_periods,
                                x_txn_amt_rec.quantity_sum,
                                x_txn_amt_rec.txn_raw_cost_sum,
                                x_txn_amt_rec.txn_burdened_cost_sum,
                                x_txn_amt_rec.txn_revenue_sum
                       FROM     PA_FP_FCST_GEN_TMP1 tmp,
                                gl_period_statuses pd
                       WHERE    tmp.data_type_code = 'TARGET_FP'
                       AND      tmp.project_element_id = P_TASK_ID
                       AND      tmp.res_list_member_id = P_RES_LIST_MEMBER_ID
                       AND      (NVL(tmp.quantity,0) <> 0
                       OR       NVL(tmp.txn_raw_cost,0) <> 0
                       OR       NVL(tmp.txn_brdn_cost,0) <> 0
                       OR       NVL(tmp.txn_revenue,0) <> 0)
                       AND      pd.period_name = tmp.period_name
                       AND      pd.application_id = PA_PERIOD_PROCESS_PKG.Application_id
                       AND      pd.set_of_books_id = p_fp_cols_rec.x_set_of_books_id
                       AND      pd.adjustment_period_flag = 'N'
                       AND      pd.start_date             >= p_actual_from_date
                       AND      pd.start_date             <= p_actual_to_date;
                   ELSIF P_FP_COLS_REC.x_version_type = 'COST' THEN
                       SELECT   /*+ INDEX(tmp,PA_FP_FCST_GEN_TMP1_N1)*/
                                count(*),
                                SUM (DECODE(l_rate_based_flag, 'Y',
                                    NVL(quantity,0),
                                    DECODE(l_currency_flag,
                                        'PC', NVL(prj_raw_cost,0),
                                        'TC', NVL(txn_raw_cost,0))
                                    )),
                                SUM (DECODE(l_currency_flag,
                                    'TC', NVL(txn_raw_cost,0),
                                    'PC', NVL(prj_raw_cost,0))),
                                SUM (DECODE(l_currency_flag,
                                    'TC', NVL(txn_brdn_cost,0),
                                    'PC', NVL(prj_brdn_cost,0))),
                                SUM (DECODE(l_currency_flag,
                                    'TC', NVL(txn_revenue,0),
                                    'PC', NVL(prj_revenue,0)))
                       INTO     x_txn_amt_rec.no_of_periods,
                                x_txn_amt_rec.quantity_sum,
                                x_txn_amt_rec.txn_raw_cost_sum,
                                x_txn_amt_rec.txn_burdened_cost_sum,
                                x_txn_amt_rec.txn_revenue_sum
                       FROM     PA_FP_FCST_GEN_TMP1 tmp,
                                gl_period_statuses pd
                       WHERE    tmp.data_type_code = 'TARGET_FP'
                       AND      tmp.project_element_id = P_TASK_ID
                       AND      tmp.res_list_member_id = P_RES_LIST_MEMBER_ID
                       AND      (NVL(tmp.quantity,0) <> 0
                       OR       NVL(tmp.txn_brdn_cost,0) <> 0
                       OR       NVL(tmp.txn_raw_cost,0) <> 0)
                       AND      pd.period_name = tmp.period_name
                       AND      pd.application_id = PA_PERIOD_PROCESS_PKG.Application_id
                       AND      pd.set_of_books_id = p_fp_cols_rec.x_set_of_books_id
                       AND      pd.adjustment_period_flag = 'N'
                       AND      pd.start_date             >= p_actual_from_date
                       AND      pd.start_date             <= p_actual_to_date;
                   ELSIF P_FP_COLS_REC.x_version_type = 'REVENUE' THEN
                       SELECT   /*+ INDEX(tmp,PA_FP_FCST_GEN_TMP1_N1)*/
                                count(*),
                                SUM (DECODE(l_rate_based_flag, 'Y',
                                    NVL(quantity,0),
                                    DECODE(l_currency_flag,
                                        'PC', NVL(prj_revenue,0),
                                        'TC', NVL(txn_revenue,0))
                                    )),
                                SUM (DECODE(l_currency_flag,
                                    'TC', NVL(txn_raw_cost,0),
                                    'PC', NVL(prj_raw_cost,0))),
                                SUM (DECODE(l_currency_flag,
                                    'TC', NVL(txn_brdn_cost,0),
                                    'PC', NVL(prj_brdn_cost,0))),
                                SUM (DECODE(l_currency_flag,
                                    'TC', NVL(txn_revenue,0),
                                    'PC', NVL(prj_revenue,0)))
                       INTO     x_txn_amt_rec.no_of_periods,
                                x_txn_amt_rec.quantity_sum,
                                x_txn_amt_rec.txn_raw_cost_sum,
                                x_txn_amt_rec.txn_burdened_cost_sum,
                                x_txn_amt_rec.txn_revenue_sum
                       FROM     PA_FP_FCST_GEN_TMP1 tmp,
                                gl_period_statuses pd
                       WHERE    tmp.data_type_code = 'TARGET_FP'
                       AND      tmp.project_element_id = P_TASK_ID
                       AND      tmp.res_list_member_id = P_RES_LIST_MEMBER_ID
                       AND      (NVL(tmp.quantity,0) <> 0
                       OR       NVL(tmp.txn_revenue,0) <> 0)
                       AND      pd.period_name = tmp.period_name
                       AND      pd.application_id = PA_PERIOD_PROCESS_PKG.Application_id
                       AND      pd.set_of_books_id = p_fp_cols_rec.x_set_of_books_id
                       AND      pd.adjustment_period_flag = 'N'
                       AND      pd.start_date             >= p_actual_from_date
                       AND      pd.start_date             <= p_actual_to_date;
                   END IF;
                   IF l_currency_flag = 'PC' THEN
                       IF P_FP_COLS_REC.x_version_type = 'ALL' THEN
                           SELECT   /*+ INDEX(tmp,PA_FP_FCST_GEN_TMP1_N1)*/
                                    COUNT(DISTINCT pd.period_name) INTO x_txn_amt_rec.no_of_periods
                           FROM     PA_FP_FCST_GEN_TMP1 tmp,
                                    gl_period_statuses pd
                           WHERE    tmp.data_type_code = 'TARGET_FP'
                           AND      tmp.project_element_id = P_TASK_ID
                           AND      tmp.res_list_member_id = P_RES_LIST_MEMBER_ID
                           AND      (NVL(tmp.quantity,0) <> 0
                           OR       NVL(tmp.txn_raw_cost,0) <> 0
                           OR       NVL(tmp.txn_brdn_cost,0) <> 0
                           OR       NVL(tmp.txn_revenue,0) <> 0)
                           AND      pd.period_name = tmp.period_name
                           AND      pd.application_id = PA_PERIOD_PROCESS_PKG.Application_id
                           AND      pd.set_of_books_id = p_fp_cols_rec.x_set_of_books_id
                           AND      pd.adjustment_period_flag = 'N'
                           AND      pd.start_date             >= p_actual_from_date
                           AND      pd.start_date             <= p_actual_to_date;
                       ELSIF P_FP_COLS_REC.x_version_type = 'COST' THEN
                           SELECT   /*+ INDEX(tmp,PA_FP_FCST_GEN_TMP1_N1)*/
                                    COUNT(DISTINCT pd.period_name) INTO x_txn_amt_rec.no_of_periods
                           FROM     PA_FP_FCST_GEN_TMP1 tmp,
                                    gl_period_statuses pd
                           WHERE    tmp.data_type_code = 'TARGET_FP'
                           AND      tmp.project_element_id = P_TASK_ID
                           AND      tmp.res_list_member_id = P_RES_LIST_MEMBER_ID
                           AND      (NVL(tmp.quantity,0) <> 0
                           OR       NVL(tmp.txn_raw_cost,0) <> 0
                           OR       NVL(tmp.txn_brdn_cost,0) <> 0)
                           AND      pd.period_name = tmp.period_name
                           AND      pd.application_id = PA_PERIOD_PROCESS_PKG.Application_id
                           AND      pd.set_of_books_id = p_fp_cols_rec.x_set_of_books_id
                           AND      pd.adjustment_period_flag = 'N'
                           AND      pd.start_date             >= p_actual_from_date
                           AND      pd.start_date             <= p_actual_to_date;
                       ELSIF P_FP_COLS_REC.x_version_type = 'REVENUE' THEN
                           SELECT   /*+ INDEX(tmp,PA_FP_FCST_GEN_TMP1_N1)*/
                                    COUNT(DISTINCT pd.period_name) INTO x_txn_amt_rec.no_of_periods
                           FROM     PA_FP_FCST_GEN_TMP1 tmp,
                                    gl_period_statuses pd
                           WHERE    tmp.data_type_code = 'TARGET_FP'
                           AND      tmp.project_element_id = P_TASK_ID
                           AND      tmp.res_list_member_id = P_RES_LIST_MEMBER_ID
                           AND      (NVL(tmp.quantity,0) <> 0
                           OR       NVL(tmp.txn_revenue,0) <> 0)
                           AND      pd.period_name = tmp.period_name
                           AND      pd.application_id = PA_PERIOD_PROCESS_PKG.Application_id
                           AND      pd.set_of_books_id = p_fp_cols_rec.x_set_of_books_id
                           AND      pd.adjustment_period_flag = 'N'
                           AND      pd.start_date             >= p_actual_from_date
                           AND      pd.start_date             <= p_actual_to_date;
                       END IF;
                   END IF;
                END IF;
            END IF;

           /* bug : 4036127 Overriding the count when the currency flag is PC.
              Only the distinct Period name count should be taken.  We can always
              use the following SELECT to get the period count. But, if the
              currency flag is TC, we can avoid this SELECT as we can get the
              count from the above sql. */

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
                x_txn_amt_rec.quantity_sum          := 0;
                x_txn_amt_rec.txn_raw_cost_sum      := 0;
                x_txn_amt_rec.txn_burdened_cost_sum := 0;
                x_txn_amt_rec.txn_revenue_sum       := 0;
                x_txn_amt_rec.no_of_periods         := 0;

            IF p_pa_debug_mode = 'Y' THEN
                 PA_DEBUG.Reset_Curr_Function;
            END IF;
            RETURN;
       END;

    ELSIF  p_fp_cols_rec.x_time_phased_code = 'N' THEN
        /* Getting the sum of init qty,raw_cost,burdened_cost,rev
           for the 'None' time phase */
         BEGIN
             -- Bug 4233720 : When the Target version is Revenue with ETC Source of
             -- Average of Actuals, we should get that Actual data from the Target
             -- budget lines instead of from the PA_FP_FCST_GEN_TMP1 table.

             IF P_FP_COLS_REC.X_FIN_PLAN_LEVEL_CODE <> 'P' OR
               (P_FP_COLS_REC.X_VERSION_TYPE = 'REVENUE' AND
                P_FP_COLS_REC.X_GEN_ETC_SRC_CODE = 'AVERAGE_ACTUALS') THEN
                 SELECT  count(*),
                         SUM (DECODE(l_rate_based_flag, 'Y',
                            NVL(init_quantity,0),
                            DECODE(l_currency_flag,
                                'PC', NVL(project_init_raw_cost,0),
                                'TC', NVL(txn_init_raw_cost,0))
                            )),
                         SUM (DECODE(l_currency_flag,
                            'TC',NVL(txn_init_raw_cost,0),
                            'PC',NVL(project_init_raw_cost,0))),
                         SUM (DECODE(l_currency_flag,
                            'TC', NVL(txn_init_burdened_cost,0),
                            'PC', NVL(project_init_burdened_cost,0))),
                         SUM (DECODE(l_currency_flag,
                            'TC', NVL(txn_init_revenue,0),
                            'PC', NVL(project_init_revenue,0)))
                 INTO     x_txn_amt_rec.no_of_periods,
                          x_txn_amt_rec.quantity_sum,
                          x_txn_amt_rec.txn_raw_cost_sum,
                          x_txn_amt_rec.txn_burdened_cost_sum,
                          x_txn_amt_rec.txn_revenue_sum
                 FROM     pa_budget_lines
                 WHERE    resource_assignment_id = P_RES_ASG_ID;
             ELSIF P_FP_COLS_REC.X_FIN_PLAN_LEVEL_CODE = 'P' THEN
                 IF P_FP_COLS_REC.x_version_type = 'ALL' THEN
                     SELECT  /*+ INDEX(PA_FP_FCST_GEN_TMP1,PA_FP_FCST_GEN_TMP1_N1)*/
                             count(*),
                             SUM (DECODE(l_rate_based_flag, 'Y',
                                 NVL(quantity,0),
                                 DECODE(l_currency_flag,
                                    'PC', NVL(prj_raw_cost,0),
                                    'TC', NVL(txn_raw_cost,0))
                                 )),
                             SUM (DECODE(l_currency_flag,
                                'TC',NVL(txn_raw_cost,0),
                                'PC',NVL(prj_raw_cost,0))),
                             SUM (DECODE(l_currency_flag,
                                'TC', NVL(txn_brdn_cost,0),
                                'PC', NVL(prj_brdn_cost,0))),
                             SUM (DECODE(l_currency_flag,
                                'TC', NVL(txn_revenue,0),
                                'PC', NVL(prj_revenue,0)))
                     INTO     x_txn_amt_rec.no_of_periods,
                              x_txn_amt_rec.quantity_sum,
                              x_txn_amt_rec.txn_raw_cost_sum,
                              x_txn_amt_rec.txn_burdened_cost_sum,
                              x_txn_amt_rec.txn_revenue_sum
                     FROM     PA_FP_FCST_GEN_TMP1
                     WHERE    data_type_code = 'TARGET_FP'
                     AND      project_element_id = P_TASK_ID
                     AND      res_list_member_id = P_RES_LIST_MEMBER_ID
                     AND      (NVL(quantity,0) <> 0
                     OR       NVL(txn_raw_cost,0) <> 0
                     OR       NVL(txn_brdn_cost,0) <> 0
                     OR       NVL(txn_revenue,0) <> 0);
                 ELSIF P_FP_COLS_REC.x_version_type = 'COST' THEN
                     SELECT  /*+ INDEX(PA_FP_FCST_GEN_TMP1,PA_FP_FCST_GEN_TMP1_N1)*/
                             count(*),
                             SUM (DECODE(l_rate_based_flag, 'Y',
                                 NVL(quantity,0),
                                 DECODE(l_currency_flag,
                                    'PC', NVL(prj_raw_cost,0),
                                    'TC', NVL(txn_raw_cost,0))
                                 )),
                             SUM (DECODE(l_currency_flag,
                                'TC',NVL(txn_raw_cost,0),
                                'PC',NVL(prj_raw_cost,0))),
                             SUM (DECODE(l_currency_flag,
                                'TC', NVL(txn_brdn_cost,0),
                                'PC', NVL(prj_brdn_cost,0))),
                             SUM (DECODE(l_currency_flag,
                                'TC', NVL(txn_revenue,0),
                                'PC', NVL(prj_revenue,0)))
                     INTO     x_txn_amt_rec.no_of_periods,
                              x_txn_amt_rec.quantity_sum,
                              x_txn_amt_rec.txn_raw_cost_sum,
                              x_txn_amt_rec.txn_burdened_cost_sum,
                              x_txn_amt_rec.txn_revenue_sum
                     FROM     PA_FP_FCST_GEN_TMP1
                     WHERE    data_type_code = 'TARGET_FP'
                     AND      project_element_id = P_TASK_ID
                     AND      res_list_member_id = P_RES_LIST_MEMBER_ID
                     AND      (NVL(quantity,0) <> 0
                     OR       NVL(txn_raw_cost,0) <> 0
                     OR       NVL(txn_brdn_cost,0) <> 0);
                 ELSIF P_FP_COLS_REC.x_version_type = 'REVENUE' THEN
                     SELECT  /*+ INDEX(PA_FP_FCST_GEN_TMP1,PA_FP_FCST_GEN_TMP1_N1)*/
                             count(*),
                             SUM (DECODE(l_rate_based_flag, 'Y',
                                 NVL(quantity,0),
                                 DECODE(l_currency_flag,
                                    'PC', NVL(prj_raw_cost,0),
                                    'TC', NVL(txn_raw_cost,0))
                                 )),
                             SUM (DECODE(l_currency_flag,
                                'TC',NVL(txn_raw_cost,0),
                                'PC',NVL(prj_raw_cost,0))),
                             SUM (DECODE(l_currency_flag,
                                'TC', NVL(txn_brdn_cost,0),
                                'PC', NVL(prj_brdn_cost,0))),
                             SUM (DECODE(l_currency_flag,
                                'TC', NVL(txn_revenue,0),
                                'PC', NVL(prj_revenue,0)))
                     INTO     x_txn_amt_rec.no_of_periods,
                              x_txn_amt_rec.quantity_sum,
                              x_txn_amt_rec.txn_raw_cost_sum,
                              x_txn_amt_rec.txn_burdened_cost_sum,
                              x_txn_amt_rec.txn_revenue_sum
                     FROM     PA_FP_FCST_GEN_TMP1
                     WHERE    data_type_code = 'TARGET_FP'
                     AND      project_element_id = P_TASK_ID
                     AND      res_list_member_id = P_RES_LIST_MEMBER_ID
                     AND      (NVL(quantity,0) <> 0
                     OR       NVL(txn_revenue,0) <> 0);
                 END IF;
             END IF;
         EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                 x_txn_amt_rec.quantity_sum          := 0;
                 x_txn_amt_rec.txn_raw_cost_sum      := 0;
                 x_txn_amt_rec.txn_burdened_cost_sum := 0;
                 x_txn_amt_rec.txn_revenue_sum       := 0;
                 x_txn_amt_rec.no_of_periods         := 0;

            IF p_pa_debug_mode = 'Y' THEN
                 PA_DEBUG.Reset_Curr_Function;
            END IF;
            RETURN;

         END;
    END IF;

    IF p_pa_debug_mode = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
    END IF;

EXCEPTION
      WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Invalid Resource assignment Id',
                p_module_name => l_module_name,
                p_log_level   => 5);
              PA_DEBUG.Reset_Curr_Function;
          END IF;
          RAISE;

      WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_data      := SUBSTR(SQLERRM,1,240);
           FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_FCST_AMT_PVT'
              ,p_procedure_name => 'GET_ACTUAL_TXN_AMOUNT');
           IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                p_module_name => l_module_name,
                p_log_level   => 5);
                PA_DEBUG.Reset_Curr_Function;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GET_ACTUAL_TXN_AMOUNT;

PROCEDURE GEN_AVERAGE_OF_ACTUALS
          (P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_TASK_ID                 IN          PA_RESOURCE_ASSIGNMENTS.TASK_ID%TYPE,
           P_RES_LIST_MEMBER_ID      IN          PA_RESOURCE_ASSIGNMENTS.RESOURCE_LIST_MEMBER_ID%TYPE,
           P_TXN_CURRENCY_CODE       IN          PA_BUDGET_LINES.TXN_CURRENCY_CODE%TYPE,
           P_CURRENCY_FLAG           IN          VARCHAR2,
           P_PLANNING_START_DATE     IN          PA_BUDGET_LINES.START_DATE%TYPE,
           P_PLANNING_END_DATE       IN          PA_BUDGET_LINES.END_DATE%TYPE,
           P_ACTUALS_THRU_DATE       IN          DATE,
           P_FP_COLS_REC             IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_ACTUAL_FROM_PERIOD      IN          PA_PERIODS_ALL.PERIOD_NAME%TYPE,
           P_ACTUAL_TO_PERIOD        IN          PA_PERIODS_ALL.PERIOD_NAME%TYPE,
           P_ETC_FROM_PERIOD         IN          PA_PERIODS_ALL.PERIOD_NAME%TYPE,
           P_ETC_TO_PERIOD           IN          PA_PERIODS_ALL.PERIOD_NAME%TYPE,
           P_RESOURCE_ASSIGNMENT_ID  IN          PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE,
           X_RETURN_STATUS           OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT               OUT  NOCOPY NUMBER,
           X_MSG_DATA                OUT  NOCOPY VARCHAR2) IS

--Cursor used to select the start_date for PA periods
CURSOR  pa_start_date_csr(c_period PA_PERIODS_ALL.PERIOD_NAME%TYPE) IS
SELECT  start_date
FROM    pa_periods_all
WHERE   period_name = c_period
AND     org_id      = p_fp_cols_rec.x_org_id;

--Cursor used to select the start_date for GL periods
CURSOR  gl_start_date_csr(c_period PA_PERIODS_ALL.PERIOD_NAME%TYPE) IS
SELECT  start_date
FROM    gl_period_statuses
WHERE   period_name            = c_period
AND     application_id         = PA_PERIOD_PROCESS_PKG.Application_id
AND     set_of_books_id        = p_fp_cols_rec.x_set_of_books_id
AND     adjustment_period_flag = 'N';

l_module_name            VARCHAR2(200) := 'pa.plsql.pa_fp_gen_fcst_amt_pvt.gen_average_of_actuals';
l_txn_amt_rec            PA_FP_GEN_FCST_AMT_PUB.TXN_AMT_REC_TYP;
l_future_no_of_period    NUMBER;
l_res_asg_id             PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE;
l_amt_dtls_tbl           PA_FP_MAINTAIN_ACTUAL_PUB.l_amt_dtls_tbl_typ;

l_period_name_tab        PA_PLSQL_DATATYPES.Char30TabTyp;
l_start_date_tab         PA_PLSQL_DATATYPES.DateTabTyp;
l_end_date_tab           PA_PLSQL_DATATYPES.DateTabTyp;

l_actual_from_date       PA_PERIODS_ALL.START_DATE%TYPE;
l_actual_to_date         PA_PERIODS_ALL.START_DATE%TYPE;
l_etc_from_date          PA_PERIODS_ALL.START_DATE%TYPE;
l_etc_to_date            PA_PERIODS_ALL.START_DATE%TYPE;

l_txn_raw_cost_sum       PA_BUDGET_LINES.TXN_RAW_COST%TYPE;
l_txn_burdened_cost_sum  PA_BUDGET_LINES.TXN_BURDENED_COST%TYPE;
l_txn_revenue_sum        PA_BUDGET_LINES.TXN_REVENUE%TYPE;
l_quantity_sum           PA_BUDGET_LINES.QUANTITY%TYPE;

l_count                  NUMBER;
l_msg_count              NUMBER;
l_data                   VARCHAR2(2000);
l_msg_data               VARCHAR2(2000);
l_msg_index_out          NUMBER;
l_rate_based_flag        PA_RESOURCE_ASSIGNMENTS.RATE_BASED_FLAG%TYPE;

/* Variables Added for ER 4376722 */
l_billable_flag          PA_TASKS.BILLABLE_FLAG%TYPE;

BEGIN
      --Setting initial values
      X_MSG_COUNT := 0;
      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

      IF p_pa_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function     => 'GEN_AVERAGE_OF_ACTUALS'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
      END IF;

 /*Bug 4036127 -  l_rate_based_flag needed for rounding the amts. */

      IF p_resource_assignment_id is null THEN
              SELECT ra.resource_assignment_id,
                     ra.rate_based_flag,
                     NVL(ta.billable_flag,'Y')                           /* Added for ER 4376722 */
              INTO   l_res_asg_id,
                     l_rate_based_flag,
                     l_billable_flag                                     /* Added for ER 4376722 */
              FROM   pa_resource_assignments ra,
                     pa_tasks ta                                         /* Added for ER 4376722 */
              WHERE  ra.budget_version_id       = p_budget_version_id
              AND    NVL(ra.task_id,0)          = p_task_id
              AND    ra.resource_list_member_id = p_res_list_member_id
              AND    NVL(ra.task_id,0)          = ta.task_id (+);        /* Added for ER 4376722 */
      ELSE
              l_res_asg_id := p_resource_assignment_id;

              SELECT ra.rate_based_flag,
                     NVL(ta.billable_flag,'Y')                           /* Added for ER 4376722 */
              INTO   l_rate_based_flag,
                     l_billable_flag                                     /* Added for ER 4376722 */
              FROM   pa_resource_assignments ra,
                     pa_tasks ta                                         /* Added for ER 4376722 */
              WHERE  ra.resource_assignment_id  = l_res_asg_id
              AND    NVL(ra.task_id,0)          = ta.task_id (+);        /* Added for ER 4376722 */
      END IF;

--hr_utility.trace('l_rate_based_flag : '||l_rate_based_flag);


      /* ER 4376722: When the Target is a Revenue-only version, we do not
       * generate quantity or amounts for non-billable, non-rate-based tasks.
       * For Average of Actuals, we can RETURN to avoid generating amounts. */

      IF l_billable_flag = 'N' AND
         l_rate_based_flag = 'N' AND
         p_fp_cols_rec.x_version_type = 'REVENUE' THEN
	  IF p_pa_debug_mode = 'Y' THEN
	         PA_DEBUG.Reset_Curr_Function;
	  END IF;
          RETURN;
      END IF; -- ER 4376722 billability logic for REVENUE versions


       /* Getting the start_date for given actual period based on time phase code */
       IF  p_fp_cols_rec.x_time_phased_code = 'P' THEN
           /* Getting the actual_from_date for the given actual_from_period(PA Period) */
            OPEN   pa_start_date_csr(p_actual_from_period);
            FETCH  pa_start_date_csr
            INTO   l_actual_from_date;
            CLOSE  pa_start_date_csr;
           /* Getting the actual_to_date for the given actual_to_period(PA Period) */
            OPEN   pa_start_date_csr(p_actual_to_period);
            FETCH  pa_start_date_csr
            INTO   l_actual_to_date;
            CLOSE  pa_start_date_csr;
           /* Getting the etc_from_date for the given etc_from_period(PA Period) */
            OPEN   pa_start_date_csr(p_etc_from_period);
            FETCH  pa_start_date_csr
            INTO   l_etc_from_date;
            CLOSE  pa_start_date_csr;
           /* Getting the etc_to_date for the given etc_to_period(PA Period) */
            OPEN   pa_start_date_csr(p_etc_to_period);
            FETCH  pa_start_date_csr
            INTO   l_etc_to_date;
            CLOSE  pa_start_date_csr;

    ELSIF p_fp_cols_rec.x_time_phased_code = 'G' THEN
           /* Getting the actual_from_date for the given actual_from_period(GL Period) */
            OPEN   gl_start_date_csr(p_actual_from_period);
            FETCH  gl_start_date_csr
            INTO   l_actual_from_date;
            CLOSE  gl_start_date_csr;
           /* Getting the actual_to_date for the given actual_to_period(GL Period) */
            OPEN   gl_start_date_csr(p_actual_to_period);
            FETCH  gl_start_date_csr
            INTO   l_actual_to_date;
            CLOSE  gl_start_date_csr;
           /* Getting the etc_from_date for the given etc_from_period(GL Period) */
            OPEN   gl_start_date_csr(p_etc_from_period);
            FETCH  gl_start_date_csr
            INTO   l_etc_from_date;
            CLOSE  gl_start_date_csr;
           /* Getting the etc_to_date for the given etc_to_period(GL Period) */
            OPEN   gl_start_date_csr(p_etc_to_period);
            FETCH  gl_start_date_csr
            INTO   l_etc_to_date;
            CLOSE  gl_start_date_csr;
    END IF;

       /* Calling  the get actual txn amt api to get
          the sum of init qty,cost and rev for the given period */
       IF p_pa_debug_mode = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Before calling
                                 pa_fp_gen_fcst_amt_pvt.get_actual_txn_amount:'
                                 ||'P_RES_ASG_ID:'||l_res_asg_id
                                 ||';P_ACTUAL_FROM_DATE:'||l_actual_from_date
                                 ||';P_ACTUAL_TO_DATE:'||l_actual_to_date
                                 ||';P_CURRENCY_FLAG:'||P_CURRENCY_FLAG,
                p_module_name => l_module_name,
                p_log_level   => 5);
       END IF;
        PA_FP_GEN_FCST_AMT_PVT.GET_ACTUAL_TXN_AMOUNT
          (P_BUDGET_VERSION_ID    => P_BUDGET_VERSION_ID,
           P_TASK_ID              => P_TASK_ID,
           P_RES_LIST_MEMBER_ID   => P_RES_LIST_MEMBER_ID,
           P_RES_ASG_ID           => l_res_asg_id,
           P_TXN_CURRENCY_CODE    => P_TXN_CURRENCY_CODE,
           P_CURRENCY_FLAG        => P_CURRENCY_FLAG,
           P_FP_COLS_REC          => P_FP_COLS_REC,
           P_ACTUAL_FROM_DATE     => l_actual_from_date,
           P_ACTUAL_TO_DATE       => l_actual_to_date,
           X_TXN_AMT_REC          => l_txn_amt_rec,
           X_RETURN_STATUS        => X_RETURN_STATUS,
           X_MSG_COUNT            => X_MSG_COUNT,
           X_MSG_DATA             => X_MSG_DATA);
       IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;
       IF p_pa_debug_mode = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Status after calling
                                    pa_fp_gen_fcst_amt_pvt.get_actual_txn_amount: '
                                    ||x_return_status,
                p_module_name => l_module_name,
                p_log_level   => 5);
       END IF;
       --dbms_output.put_line('Status of get_actual_txn_amount api: '||X_RETURN_STATUS);

       /* Getting the period_name, start_date, end_date
          between the etc_from_date and least(p_planning_end_date,l_etc_to_date)
          based on the time phase code*/
           IF p_fp_cols_rec.x_time_phased_code ='P' THEN
                  SELECT period_name, start_date, end_date
                  BULK   COLLECT
                  INTO   l_period_name_tab, l_start_date_tab, l_end_date_tab
                  FROM   pa_periods_all
                  WHERE  org_id = p_fp_cols_rec.x_org_id
                  AND    start_date >= l_etc_from_date
                  AND    start_date <= least(p_planning_end_date,l_etc_to_date);
           ELSIF p_fp_cols_rec.x_time_phased_code ='G' THEN
                  SELECT period_name, start_date, end_date
                  BULK   COLLECT
                  INTO   l_period_name_tab, l_start_date_tab, l_end_date_tab
                  FROM   gl_period_statuses
                  WHERE  application_id         = PA_PERIOD_PROCESS_PKG.Application_id
                  AND    set_of_books_id        = p_fp_cols_rec.x_set_of_books_id
                  AND    adjustment_period_flag = 'N'
                  AND    start_date >= l_etc_from_date
                  AND    start_date <= least(p_planning_end_date,l_etc_to_date);
           END IF;
           IF  l_period_name_tab.count = 0 THEN
                    IF p_pa_debug_mode = 'Y' THEN
                           PA_DEBUG.Reset_Curr_Function;
                    END IF;
               RETURN;
           END IF;

           IF  l_txn_amt_rec.no_of_periods > 0 THEN
                 l_txn_raw_cost_sum      := (l_txn_amt_rec.txn_raw_cost_sum/l_txn_amt_rec.no_of_periods);
                 l_txn_burdened_cost_sum := (l_txn_amt_rec.txn_burdened_cost_sum/l_txn_amt_rec.no_of_periods);
                 l_txn_revenue_sum       := (l_txn_amt_rec.txn_revenue_sum/l_txn_amt_rec.no_of_periods);
                 l_quantity_sum          := (l_txn_amt_rec.quantity_sum/l_txn_amt_rec.no_of_periods);
           END IF;

           IF p_pa_debug_mode = 'Y' THEN
                     pa_fp_gen_amount_utils.fp_debug
                            (p_msg       => '===in average_of_actuals,l_txn_amt_rec.no_of_periods:'
                                           ||l_txn_amt_rec.no_of_periods||';l_txn_amt_rec.txn_raw_cost_sum:'
                                           ||l_txn_amt_rec.txn_raw_cost_sum||';l_txn_amt_rec.txn_burdened_cost_sum:'
                                           ||l_txn_amt_rec.txn_burdened_cost_sum||';l_txn_amt_rec.txn_revenue_sum:'
                                           ||l_txn_amt_rec.txn_revenue_sum||';l_txn_amt_rec.quantity_sum:'
                                           ||l_txn_amt_rec.quantity_sum,
                             p_module_name => l_module_name,
                             p_log_level   => 5);
           END IF;

           IF l_txn_raw_cost_sum = 0      AND
              l_txn_burdened_cost_sum = 0 AND
              l_txn_revenue_sum = 0       AND
              l_quantity_sum = 0          THEN
                    IF p_pa_debug_mode = 'Y' THEN
                           PA_DEBUG.Reset_Curr_Function;
                    END IF;
                  RETURN;
           END IF;
/*Bug 4036127 - Rounded all the amts */

         IF l_rate_based_flag = 'Y' THEN
                l_quantity_sum := pa_fin_plan_utils2.round_quantity
                                (p_quantity => l_quantity_sum);
         ELSE
                l_quantity_sum :=  pa_currency.round_trans_currency_amt1
                                (x_amount       => l_quantity_sum,
                                 x_curr_Code    => p_txn_currency_code);
         END IF;
                l_txn_raw_cost_sum := pa_currency.round_trans_currency_amt1
                                (x_amount       => l_txn_raw_cost_sum,
                                 x_curr_Code    => p_txn_currency_code);
                l_txn_burdened_cost_sum := pa_currency.round_trans_currency_amt1
                                (x_amount       => l_txn_burdened_cost_sum,
                                 x_curr_Code    => p_txn_currency_code);


           /* ER 4376722: When the Target is a Cost and Revenue together
            * version, we do not generate revenue for non-billable tasks.
            * To do this, simply null out revenue amounts for non-billable
            * tasks. The result is that revenue amounts for non-billable
            * tasks will not be written to the budget lines. */
           IF l_billable_flag = 'N' AND
              p_fp_cols_rec.x_version_type = 'ALL' THEN

               l_txn_revenue_sum := NULL;

           /* ER 4376722: When the Target is a Revenue-only version, we generate
            * quantity but not revenue for non-billable, rate-based tasks. */
           ELSIF l_billable_flag = 'N' AND
                 l_rate_based_flag = 'Y' AND
                 p_fp_cols_rec.x_version_type = 'REVENUE' THEN

               l_txn_revenue_sum := NULL;

           ELSE
               l_txn_revenue_sum := pa_currency.round_trans_currency_amt1
                                (x_amount       => l_txn_revenue_sum,
                                 x_curr_Code    => p_txn_currency_code);
           END IF; -- ER 4376722 billability logic for REVENUE versions


           FOR j IN 1..l_period_name_tab.count LOOP
                         l_amt_dtls_tbl(j).period_name      := l_period_name_tab(j);
                         l_amt_dtls_tbl(j).start_date       := l_start_date_tab(j);
                         l_amt_dtls_tbl(j).end_date         := l_end_date_tab(j);
                         l_amt_dtls_tbl(j).txn_raw_cost     := l_txn_raw_cost_sum;
                         l_amt_dtls_tbl(j).txn_burdened_cost:= l_txn_burdened_cost_sum;
                         l_amt_dtls_tbl(j).txn_revenue      := l_txn_revenue_sum;
                         l_amt_dtls_tbl(j).quantity         := l_quantity_sum;
           END LOOP;


                  --Calling  the maintain actual amt ra api
                  IF p_pa_debug_mode = 'Y' THEN
                       pa_fp_gen_amount_utils.fp_debug
                       (p_msg         => 'Before calling
                                             pa_fp_maintain_actual_pub.maintain_actual_amt_ra',
                        p_module_name => l_module_name,
                        p_log_level   => 5);
                  END IF;
                  PA_FP_MAINTAIN_ACTUAL_PUB.MAINTAIN_ACTUAL_AMT_RA
                       (P_PROJECT_ID              => p_fp_cols_rec.x_project_id,
                        P_BUDGET_VERSION_ID       => P_BUDGET_VERSION_ID,
                        P_RESOURCE_ASSIGNMENT_ID  => l_res_asg_id,
                        P_TXN_CURRENCY_CODE       => P_TXN_CURRENCY_CODE,
                        P_AMT_DTLS_REC_TAB        => l_amt_dtls_tbl,
                        P_CALLING_CONTEXT         => 'FP_GEN_FCST_COPY_ACTUAL',
                        P_TXN_AMT_TYPE_CODE       => 'PLANNING_TXN',
                        X_RETURN_STATUS           => X_RETURN_STATUS,
                        X_MSG_COUNT               => X_MSG_COUNT,
                        X_MSG_DATA                => X_MSG_DATA);
                  IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;
                  IF p_pa_debug_mode = 'Y' THEN
                       pa_fp_gen_amount_utils.fp_debug
                       (p_msg         => 'Status after calling
                                              pa_fp_maintain_actual_pub.maintain_actual_amt_ra: '
                                              ||x_return_status,
                        p_module_name => l_module_name,
                        p_log_level   => 5);
                  END IF;
           --dbms_output.put_line('Status of maintain_actual_amt_ra api: '||X_RETURN_STATUS);

     IF P_PA_DEBUG_MODE = 'Y' THEN
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
             ( p_pkg_name       => 'PA_FP_GEN_FCST_AMT_PVT'
              ,p_procedure_name => 'GEN_AVERAGE_OF_ACTUALS');
           IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_fp_gen_amount_utils.fp_debug
                       (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                        p_module_name => l_module_name,
                        p_log_level   => 5);
                PA_DEBUG.Reset_Curr_Function;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GEN_AVERAGE_OF_ACTUALS;

/**The following API is to address bug 4145383.
  *Scenario: Other sources (Actual or commitment etc): Rate-based;
  *          Generated amount from main source: Non rate-based
  *Strategy: Only take amount from other sources. Need to convert
  *          the rate-based flag of the actual to be non rate-based.
  *Implementation: parse pa_fp_calc_amt_tmp1 table to check each target
  *                resource assignment,for each rate based target res asg,
  *                as long as there exists one source res asg with rate
  *                based flag of 'N', target res asg will be updated to
  *                non rate based. And for this target res asg, all existing
  *                budget lines will be updated accordingly. **/
PROCEDURE UPD_TGT_RATE_BASED_FLAG
          (P_FP_COLS_REC             IN   PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           X_RETURN_STATUS           OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT               OUT  NOCOPY NUMBER,
           X_MSG_DATA                OUT  NOCOPY VARCHAR2)
IS
    l_module_name  VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_FCST_AMT_PVT.upd_tgt_rate_based_flag';

    l_tgt_res_asg_tab           pa_plsql_datatypes.IdTabTyp;
    l_budget_line_id_tab        pa_plsql_datatypes.IdTabTyp;
    l_init_raw_cost_tab         pa_plsql_datatypes.NumTabTyp;
    l_raw_cost_tab              pa_plsql_datatypes.NumTabTyp;
    l_init_rev_tab              pa_plsql_datatypes.NumTabTyp;
    l_rev_tab                   pa_plsql_datatypes.NumTabTyp;

    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(2000);
    l_data                       VARCHAR2(2000);
    l_msg_index_out              NUMBER:=0;

    l_etc_start_date               DATE;
    l_bv_id                      NUMBER;
BEGIN
    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function     => 'UPD_TGT_RATE_BASED_FLAG',
                                    p_debug_mode   =>  p_pa_debug_mode);
    END IF;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    -- Bug 4170419 : Start
    --SELECT /*+ INDEX(tmp,PA_FP_CALC_AMT_TMP1_N1)*/
    --       DISTINCT target_res_asg_id
    --BULK COLLECT
    --INTO l_tgt_res_asg_tab
    --FROM pa_fp_calc_amt_tmp1 tmp, pa_resource_assignments ra
    --WHERE tmp.target_res_asg_id = ra.resource_assignment_id
    --  AND ra.rate_based_flag = 'Y'
    --  AND tmp.rate_based_flag = 'N';
    l_bv_id := p_fp_cols_rec.x_budget_version_id;

    IF p_fp_cols_rec.X_GEN_RET_MANUAL_LINE_FLAG = 'N' THEN

        -- SQL Repository Bug 4884824; SQL ID 14902397
        -- Fixed Full Index Scan violation by replacing
        -- existing hint with leading hint.
        SELECT /*+ LEADING(tmp) */
               DISTINCT target_res_asg_id
        BULK COLLECT
        INTO l_tgt_res_asg_tab
        FROM pa_fp_calc_amt_tmp1 tmp, pa_resource_assignments ra
        WHERE tmp.target_res_asg_id = ra.resource_assignment_id
        AND ra.rate_based_flag = 'Y'
        AND tmp.rate_based_flag = 'N';

    ELSIF p_fp_cols_rec.X_GEN_RET_MANUAL_LINE_FLAG = 'Y' THEN
        If p_fp_cols_rec.x_time_phased_code IN ('P','G') then
            l_etc_start_date := PA_FP_GEN_AMOUNT_UTILS.get_etc_start_date
                ( p_fp_cols_rec.x_budget_version_id );

            -- SQL Repository Bug 4884824; SQL ID 14902422
            -- Fixed Full Index Scan violation by replacing
            -- existing hint with leading hint.
            SELECT /*+ LEADING(tmp) */
                   DISTINCT target_res_asg_id
            BULK COLLECT
            INTO l_tgt_res_asg_tab
            FROM pa_fp_calc_amt_tmp1 tmp, pa_resource_assignments ra
            WHERE tmp.target_res_asg_id = ra.resource_assignment_id
            AND ra.rate_based_flag = 'Y'
            AND tmp.rate_based_flag = 'N'
            AND    ( ra.transaction_source_code is not null
                     OR
                     (ra.transaction_source_code is null and NOT exists
                       (select 1
                        from pa_budget_lines pbl
                        where pbl.resource_assignment_id = ra.resource_assignment_id
                        and   pbl.start_date >= l_etc_start_date
                       )
                     )
                   );
       Else
            -- SQL Repository Bug 4884824; SQL ID 14902440
            -- Fixed Full Index Scan violation by replacing
            -- existing hint with leading hint.
            SELECT /*+ LEADING(tmp) */
                   DISTINCT target_res_asg_id
            BULK COLLECT
            INTO l_tgt_res_asg_tab
            FROM pa_fp_calc_amt_tmp1 tmp, pa_resource_assignments ra
            WHERE tmp.target_res_asg_id = ra.resource_assignment_id
            AND ra.rate_based_flag = 'Y'
            AND tmp.rate_based_flag = 'N'
            AND    ( ra.transaction_source_code is not null
                     OR
                     (ra.transaction_source_code is null and NOT exists
                      (select 1
                       from pa_budget_lines pbl
                       where pbl.resource_assignment_id = ra.resource_assignment_id
                       and   NVL(pbl.quantity,0) <> NVL(pbl.init_quantity,0)
                      )
                     )
                   );
       End If;
       -- Bug 4170419 : End
    END IF; -- manual lines check

    IF l_tgt_res_asg_tab.count = 0 THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN;
    END IF;

    FORALL i IN 1..l_tgt_res_asg_tab.count
        UPDATE pa_resource_assignments
        SET rate_based_flag = 'N',
            unit_of_measure = 'DOLLARS'
        WHERE resource_assignment_id = l_tgt_res_asg_tab(i);

    DELETE FROM pa_res_list_map_tmp1;
    FORALL i IN 1..l_tgt_res_asg_tab.count
        INSERT INTO pa_res_list_map_tmp1(txn_resource_assignment_id)
        VALUES (l_tgt_res_asg_tab(i));

    /* bl.bv id check added for perf bug 4183364 */

    SELECT bl.budget_line_id,
           bl.txn_init_raw_cost,
           bl.txn_raw_cost,
           bl.txn_init_revenue,
           bl.txn_revenue
    BULK COLLECT
    INTO l_budget_line_id_tab,
         l_init_raw_cost_tab,
         l_raw_cost_tab,
         l_init_rev_tab,
         l_rev_tab
    FROM pa_budget_lines bl, pa_res_list_map_tmp1 tmp
    WHERE bl.budget_version_id = l_bv_id AND
          tmp.txn_resource_assignment_id = bl.resource_assignment_id;

    IF l_budget_line_id_tab.count = 0 THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN;
    END IF;

    IF P_FP_COLS_REC.X_VERSION_TYPE = 'REVENUE' THEN
        FORALL i IN 1..l_budget_line_id_tab.count
            UPDATE pa_budget_lines
            SET init_quantity = l_init_rev_tab(i),
                quantity = l_rev_tab(i)
            WHERE budget_line_id = l_budget_line_id_tab(i);
    ELSE
        FORALL i IN 1..l_budget_line_id_tab.count
            UPDATE pa_budget_lines
            SET init_quantity = l_init_raw_cost_tab(i),
                quantity = l_raw_cost_tab(i)
            WHERE budget_line_id = l_budget_line_id_tab(i);
    END IF;

    IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.Reset_Curr_Function;
    END IF;
EXCEPTION
     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
          l_msg_count := FND_MSG_PUB.count_msg;
          IF l_msg_count = 1 THEN
              PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE
                  ,p_msg_index      => 1
                  ,p_msg_count      => l_msg_count
                  ,p_msg_data       => l_msg_data
                  ,p_data           => l_data
                  ,p_msg_index_out  => l_msg_index_out);
                 x_msg_data  := l_data;
                 x_msg_count := l_msg_count;
          ELSE
                x_msg_count := l_msg_count;
          END IF;
          ROLLBACK;

          x_return_status := FND_API.G_RET_STS_ERROR;
          IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write_log(
                  x_module    => l_module_name,
                  x_msg     => 'Invalid Arguments Passed',
                  x_log_level => 5);
              PA_DEBUG.Reset_Curr_Function;
          END IF;
          RAISE;

      WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_data      := SUBSTR(SQLERRM,1,240);
           FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_FCST_AMT_PVT'
              ,p_procedure_name => 'UPD_TGT_RATE_BASED_FLAG');
           IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write_log(
                     x_module    => l_module_name,
                     x_msg       => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                     x_log_level => 5);
                PA_DEBUG.Reset_Curr_Function;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END UPD_TGT_RATE_BASED_FLAG;

END PA_FP_GEN_FCST_AMT_PVT;

/
