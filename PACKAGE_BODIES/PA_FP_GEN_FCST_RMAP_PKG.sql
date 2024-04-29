--------------------------------------------------------
--  DDL for Package Body PA_FP_GEN_FCST_RMAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_GEN_FCST_RMAP_PKG" as
/* $Header: PAFPFGRB.pls 120.2 2006/01/16 10:54:19 appldev noship $ */

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

/** This method is used to map the ETC source txns to the target
 *  plan version resource list. */
PROCEDURE FCST_SRC_TXNS_RMAP
          ( P_PROJECT_ID         IN            PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
            P_BUDGET_VERSION_ID  IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
            P_FP_COLS_REC        IN            PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
            X_RETURN_STATUS      OUT  NOCOPY   VARCHAR2,
            X_MSG_COUNT          OUT  NOCOPY   NUMBER,
            X_MSG_DATA           OUT  NOCOPY   VARCHAR2 )
IS
    --preparing input param for PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS
    -- Bug 4070976: Because we have added some pre-processing before this
    -- cursor is used, we should only pick up resources with null values for
    -- TARGET_RLM_ID, which have not been processed yet.
    CURSOR map_to_target_fp_cur IS
    SELECT tmp1.RESOURCE_ASSIGNMENT_ID, --p_TXN_SOURCE_ID,
           'RES_ASSIGNMENTS', --tmp1.TXN_SOURCE_TYPE_CODE,
           tmp1.PERSON_ID,
           tmp1.JOB_ID,
           tmp1.ORGANIZATION_ID,
           tmp1.SUPPLIER_ID,
           tmp1.EXPENDITURE_TYPE,
           tmp1.EVENT_TYPE,
           tmp1.NON_LABOR_RESOURCE,
           tmp1.EXPENDITURE_CATEGORY,
           tmp1.REVENUE_CATEGORY_CODE,
           NULL, --tmp1.NLR_ORGANIZATION_ID,
           tmp1.event_type,--tmp1.EVENT_CLASSIFICATION,
           NULL, --tmp1.SYS_LINK_FUNCTION,
           NVL(tmp1.INCUR_BY_ROLE_ID,tmp1.PROJECT_ROLE_ID),
           NVL(tmp1.INCUR_BY_RES_CLASS_CODE,tmp1.RESOURCE_CLASS_CODE),
           tmp1.MFC_COST_TYPE_ID,
           tmp1.RESOURCE_CLASS_FLAG,
           tmp1.FC_RES_TYPE_CODE,
           tmp1.INVENTORY_ITEM_ID,
           tmp1.ITEM_CATEGORY_ID,
           tmp1.PERSON_TYPE_CODE,
           tmp1.BOM_RESOURCE_ID,
           tmp1.NAMED_ROLE,
           tmp1.INCURRED_BY_RES_FLAG,
           tmp1.RATE_BASED_FLAG,
           tmp1.mapped_fin_task_id,
           NULL, --TXN_WBS_ELEMENT_VER_ID
           NULL, --tmp1.TXN_RBS_ELEMENT_ID,
           tmp1.planning_start_date, --TXN_PLAN_START_DATE,
           tmp1.planning_end_date --TXN_PLAN_END_DATE
      FROM PA_FP_CALC_AMT_TMP1 tmp1
     WHERE RESOURCE_ASSIGNMENT_ID > 0
       AND TRANSACTION_SOURCE_CODE <> 'OPEN_COMMITMENTS'
       AND TARGET_RLM_ID IS NULL;

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

    /*after calling create_res_asg and update_res_asg
     *we will create the new res_asg_id for the mapped
     *rlm_id and task id for target budget_version; and
     *also, the newly created res_asg_id is written back
     *to PA_FP_PLANNING_RES_TMP1. We need to update this
     *value to calc_amt_tmp1 and calc_amt_tmp2 to facilitae
     *our future operation. */
    CURSOR update_res_asg IS
    SELECT task_id,
           resource_list_member_id,
           resource_assignment_id
      FROM PA_FP_PLANNING_RES_TMP1;

    l_upd_task_id_tab              PA_PLSQL_DATATYPES.NumTabTyp;
    l_upd_rlm_id_tab               PA_PLSQL_DATATYPES.NumTabTyp;
    l_upd_target_ra_id_tab         PA_PLSQL_DATATYPES.NumTabTyp;

    l_upd_ra_id_tab1               PA_PLSQL_DATATYPES.NumTabTyp;
    l_upd_target_ra_id_tab1        PA_PLSQL_DATATYPES.NumTabTyp;

    l_count_tmp                    NUMBER;
    p_called_mode                  varchar2(20) := 'SELF_SERVICE';

    /* PL/SQL tables for updating target transaction_source_code values */
    l_tgt_res_asg_id_tab           PA_PLSQL_DATATYPES.IdTabTyp;
    l_txn_src_code_tab             PA_PLSQL_DATATYPES.Char30TabTyp;

    l_sysdate                      DATE;
    l_last_updated_by              PA_RESOURCE_ASSIGNMENTS.LAST_UPDATED_BY%TYPE;
    l_last_update_login            PA_RESOURCE_ASSIGNMENTS.LAST_UPDATE_LOGIN%TYPE;

    /* Local copy of target version details for getting source version ids. */
    l_fp_cols_rec                  PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
    l_resource_list_id             PA_BUDGET_VERSIONS.RESOURCE_LIST_ID%TYPE;

    /* Date update variables */
    l_res_asg_id_tab               PA_PLSQL_DATATYPES.IdTabTyp;
    l_start_date_tab               PA_PLSQL_DATATYPES.DateTabTyp;
    l_end_date_tab                 PA_PLSQL_DATATYPES.DateTabTyp;

    l_etc_start_date               DATE;

    l_module_name VARCHAR2(100) := 'pa.plsql.PA_FP_GEN_FCST_RMAP_PKG.FCST_SRC_TXNS_RMAP';
    l_count                        NUMBER;
    l_msg_count                    NUMBER;
    l_data                         VARCHAR2(1000);
    l_msg_data                     VARCHAR2(1000);
    l_msg_index_out                NUMBER;
    l_uncategorized_flag           VARCHAR2(1);
    l_rlm_id                       NUMBER;
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;

    IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.SET_CURR_FUNCTION( p_function   => 'FCST_SRC_TXNS_RMAP',
                                    p_debug_mode => p_pa_debug_mode );
    END IF;

    SELECT NVL(uncategorized_flag,'N')
    INTO   l_uncategorized_flag
    FROM   pa_resource_lists_all_bg
    WHERE  resource_list_id = p_fp_cols_rec.X_RESOURCE_LIST_ID;

    IF l_uncategorized_flag = 'Y' THEN
        l_rlm_id := PA_FP_GEN_AMOUNT_UTILS.GET_RLM_ID
                        ( p_project_id          => p_project_id,
                          p_resource_list_id    => p_fp_cols_rec.X_RESOURCE_LIST_ID,
                          p_resource_class_code => 'FINANCIAL_ELEMENTS' );
        UPDATE PA_FP_CALC_AMT_TMP1
        SET target_rlm_id = l_rlm_id;
    ELSIF l_uncategorized_flag = 'N' THEN

        -- Beginning of code change for Bug 4070976 --
        /* We get a fresh local copy of the target version details because
         * p_fp_cols_rec does not have the updated source version ids. */
        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_msg         => 'Before calling
                                    pa_fp_gen_amount_utils.get_plan_version_dtls',
                  p_module_name => l_module_name,
                  p_log_level   => 5 );
        END IF;
        PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
            ( P_BUDGET_VERSION_ID       => p_budget_version_id,
              X_FP_COLS_REC             => l_fp_cols_rec,
              X_RETURN_STATUS           => x_return_status,
              X_MSG_COUNT               => x_msg_count,
              X_MSG_DATA                => x_msg_data );
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_msg         => 'Status after calling
                                    pa_fp_gen_amount_utils.get_plan_version_dtls: ' ||
                                    x_return_status,
                  p_module_name => l_module_name,
                  p_log_level   => 5 );
        END IF;

        /* If target has a Workplan source AND source and target resource lists
         * match, then copy source rlm_id to target_rlm_id for WP records in tmp1. */
        IF l_fp_cols_rec.x_gen_src_wp_version_id IS NOT NULL THEN
            SELECT resource_list_id
            INTO   l_resource_list_id
            FROM   pa_budget_versions
            WHERE  budget_version_id = l_fp_cols_rec.x_gen_src_wp_version_id;

            IF l_fp_cols_rec.x_resource_list_id = l_resource_list_id THEN
                UPDATE PA_FP_CALC_AMT_TMP1
                SET    target_rlm_id = resource_list_member_id
                WHERE  transaction_source_code = 'WORKPLAN_RESOURCES';
            END IF;
        END IF;

        /* If target has a Financial Plan source AND source and target resource lists
         * match, then copy source rlm_id to target_rlm_id for FP records in tmp1. */
        IF l_fp_cols_rec.x_gen_src_plan_version_id IS NOT NULL THEN
            SELECT resource_list_id
            INTO   l_resource_list_id
            FROM   pa_budget_versions
            WHERE  budget_version_id = l_fp_cols_rec.x_gen_src_plan_version_id;

            IF l_fp_cols_rec.x_resource_list_id = l_resource_list_id THEN
                UPDATE PA_FP_CALC_AMT_TMP1
                SET    target_rlm_id = resource_list_member_id
                WHERE  transaction_source_code = 'FINANCIAL_PLAN';
            END IF;
        END IF;
        -- End of code change for Bug 4070976 --

        OPEN map_to_target_fp_cur;
        FETCH map_to_target_fp_cur
        BULK COLLECT
        INTO l_TXN_SOURCE_ID_tab,
             l_TXN_SOURCE_TYPE_CODE_tab,
             l_PERSON_ID_tab,
             l_JOB_ID_tab,
             l_ORGANIZATION_ID_tab,
             l_VENDOR_ID_tab,
             l_EXPENDITURE_TYPE_tab,
             l_EVENT_TYPE_tab,
             l_NON_LABOR_RESOURCE_tab,
             l_EXPENDITURE_CATEGORY_tab,
             l_REVENUE_CATEGORY_CODE_tab,
             l_NLR_ORGANIZATION_ID_tab,
             l_EVENT_CLASSIFICATION_tab,
             l_SYS_LINK_FUNCTION_tab,
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
             l_RATE_BASED_FLAG_tab,
             l_TXN_TASK_ID_tab,
             l_TXN_WBS_ELEMENT_VER_ID_tab,
             l_TXN_RBS_ELEMENT_ID_tab,
             l_TXN_PLAN_START_DATE_tab,
             l_TXN_PLAN_END_DATE_tab;
        CLOSE map_to_target_fp_cur;

                    /*IF p_pa_debug_mode = 'Y' THEN
                         pa_fp_gen_amount_utils.fp_debug
                        (p_msg         => 'Value of l_txn_source_id_tab.count: '||l_txn_source_id_tab.count,
                         p_module_name => l_module_name,
                         p_log_level   => 5);
                    END IF;*/
        --dbms_output.put_line('--l_txn_source_id_tab.count:'||l_txn_source_id_tab.count);

        IF ( l_TXN_SOURCE_ID_tab.count > 0 ) THEN
            IF p_pa_debug_mode = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG (
                    P_CALLED_MODE   => p_called_mode,
                    P_MSG           => 'Before calling PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS',
                    P_MODULE_NAME   => l_module_name );
            END IF;

            /* bug 3576766 : p_project_id parameter added for
               non centrally controlled resource list mapping. */
            -- select count(*) into l_count_tmp from PA_FP_CALC_AMT_TMP1;
            -- hr_utility.trace('=!!!=PA_FP_CALC_AMT_TMP1.count bef calling res map api'||l_count_tmp);
            PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS (
                P_PROJECT_ID                   => p_project_id,
                P_BUDGET_VERSION_ID            => NULL,
                P_RESOURCE_LIST_ID             => P_FP_COLS_REC.X_RESOURCE_LIST_ID,
                P_RBS_VERSION_ID               => NULL,
                P_CALLING_PROCESS              => 'FORECAST_GENERATION',
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
                P_REVENUE_CATEGORY_CODE_TAB    => l_REVENUE_CATEGORY_CODE_tab,
                P_NLR_ORGANIZATION_ID_TAB      => l_NLR_ORGANIZATION_ID_tab,
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
                P_BOM_RESOURCE_ID_TAB          => l_BOM_RESOURCE_ID_tab,
                P_NAMED_ROLE_TAB               => l_NAMED_ROLE_tab,
                P_INCURRED_BY_RES_FLAG_TAB     => l_INCURRED_BY_RES_FLAG_tab,
                P_RATE_BASED_FLAG_TAB          => l_RATE_BASED_FLAG_tab,
                P_TXN_TASK_ID_TAB              => l_TXN_TASK_ID_tab,
                P_TXN_WBS_ELEMENT_VER_ID_TAB   => l_TXN_WBS_ELEMENT_VER_ID_tab,
                P_TXN_RBS_ELEMENT_ID_TAB       => l_TXN_RBS_ELEMENT_ID_tab,
                P_TXN_PLAN_START_DATE_TAB      => l_TXN_PLAN_START_DATE_tab,
                P_TXN_PLAN_END_DATE_TAB        => l_TXN_PLAN_END_DATE_tab,
                X_TXN_SOURCE_ID_TAB            => l_map_txn_source_id_tab,
                X_RES_LIST_MEMBER_ID_TAB       => l_map_rlm_id_tab,
                X_RBS_ELEMENT_ID_TAB           => l_map_rbs_element_id_tab,
                X_TXN_ACCUM_HEADER_ID_TAB      => l_map_txn_accum_header_id_tab,
                X_RETURN_STATUS                => x_return_status,
                X_MSG_COUNT                    => x_msg_count,
                X_MSG_DATA                     => x_msg_data );
            IF p_pa_debug_mode = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                    P_CALLED_MODE   => p_called_mode,
                    P_MSG           => 'After calling PA_RLMI_RBS_MAP_PUB.MAP_RLMI_RBS: '||
                                       x_return_status,
                    P_MODULE_NAME   => l_module_name);
            END IF;
            IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            /**Previously, we populate latest published fwbs back to pa_budget_versions,
               but, if planning at task level, project_structure_version_id is already
               in pa_budget_versions, if planning at project level,project_structure
               version_id not needed in pa_budget_versions. So update deleted **/

            --select count(*) into l_count_tmp from PA_FP_CALC_AMT_TMP1;

                /*IF p_pa_debug_mode = 'Y' THEN
                     pa_fp_gen_amount_utils.fp_debug
                    (p_msg         => 'Count of  PA_FP_CALC_AMT_TMP1: '||l_count_tmp,
                     p_module_name => l_module_name,
                     p_log_level   => 5);
                END IF;*/

            --dbms_output.put_line('@@tmp1 has:'||l_count_tmp);
            --select count(*) into l_count_tmp from PA_FP_CALC_AMT_TMP1
            --where task_id = 0;
            --dbms_output.put_line('@@tmp1 with 0 task_id has:'||l_count_tmp);

            /* hr_utility.trace('==PA_FP_CALC_AMT_TMP1.count aft res map call'||l_count_tmp);
            hr_utility.trace('map rlm id tab count '||l_map_rlm_id_tab.count);
            hr_utility.trace('map src id tab count '||l_map_txn_source_id_tab.count); */
                /*IF p_pa_debug_mode = 'Y' THEN
                     pa_fp_gen_amount_utils.fp_debug
                    (p_msg         => 'Value of l_map_rlm_id_tab.count: '||l_map_rlm_id_tab.count,
                     p_module_name => l_module_name,
                     p_log_level   => 5);
                END IF;*/

            FORALL i IN 1..l_map_rlm_id_tab.count
                UPDATE /*+ INDEX(PA_FP_CALC_AMT_TMP1,PA_FP_CALC_AMT_TMP1_N2)*/
                       PA_FP_CALC_AMT_TMP1
                SET target_rlm_id = l_map_rlm_id_tab(i)
                WHERE resource_assignment_id = l_map_txn_source_id_tab(i);

            -- hr_utility.trace('no of rows updated in tmp1 aft res map:'||sql%rowcount);
            -- delete from calc_amt_tmp1;
            -- insert into calc_amt_tmp1 select * from pa_fp_calc_amt_tmp1;
        END IF;
        /* end if for table count greater than zero   */
    END IF;
    /* uncategorized flag check */

    /* end  if for calling the mapping api for the target version */

    --select count(*) into l_count_tmp
    --from pa_resource_assignments where budget_version_id = P_BUDGET_VERSION_ID;
    --dbms_output.put_line('@@before maintain_res_asg, count of pa_resource_asgs:' ||l_count_tmp);
    --hr_utility.trace('before calling maintain res asg');

    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_CALLED_MODE   => P_CALLED_MODE,
            P_MSG           => 'Before calling PA_FP_GEN_FCST_AMT_PUB.MAINTAIN_RES_ASG',
            P_MODULE_NAME   => l_module_name );
    END IF;
    PA_FP_GEN_FCST_AMT_PUB.MAINTAIN_RES_ASG(
                P_PROJECT_ID            => P_PROJECT_ID,
                P_BUDGET_VERSION_ID     => P_BUDGET_VERSION_ID,
                P_FP_COLS_REC           => P_FP_COLS_REC,
                X_RETURN_STATUS         => x_return_status,
                X_MSG_COUNT             => x_msg_count,
                X_MSG_DATA              => x_msg_data );
    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_CALLED_MODE   => P_CALLED_MODE,
            P_MSG           => 'After calling PA_FP_GEN_FCST_AMT_PUB.'||
                               'MAINTAIN_RES_ASG: '||x_return_status,
            P_MODULE_NAME   => l_module_name);
    END IF;
    --hr_utility.trace('after calling maintain res asg:'||x_return_status);
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;
    --select count(*) into l_count_tmp
    --from pa_resource_assignments where budget_version_id = P_BUDGET_VERSION_ID;
    --dbms_output.put_line('@@after maintain_res_asg,count of pa_resource_asgs:' ||l_count_tmp);

    -- Bug 3982592: Between forecast generation processes users may have changed
    -- planning resource start and end dates. Thus, we must update the resource
    -- assignments table with the source dates in pa_fp_planning_res_tmp1.
    -- Bug 4114589: Moved logic for bug 3982592 from UPDATE_RES_ASG to here
    -- so that we only update the planning dates once. Added manual lines logic.

    -- Bug 4301959: Modified the Retain Manually Added Lines logic to
    -- handle the non-time phased case separately, using the (quantity <>
    -- actual quantity) check instead of (start_date > etc_start_date).

    IF p_fp_cols_rec.X_GEN_RET_MANUAL_LINE_FLAG = 'N' THEN
        SELECT resource_assignment_id,
               MIN(planning_start_date),
               MAX(planning_end_date)
        BULK COLLECT
        INTO l_res_asg_id_tab,
             l_start_date_tab,
             l_end_date_tab
        FROM pa_fp_planning_res_tmp1
        GROUP BY resource_assignment_id;
    ELSIF p_fp_cols_rec.X_GEN_RET_MANUAL_LINE_FLAG = 'Y' THEN
        IF p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
            l_etc_start_date :=
                PA_FP_GEN_AMOUNT_UTILS.GET_ETC_START_DATE(p_budget_version_id);

            SELECT /*+ INDEX(tmp1,PA_FP_PLANNING_RES_TMP1_N1)*/
                   tmp1.resource_assignment_id,
                   MIN(tmp1.planning_start_date),
                   MAX(tmp1.planning_end_date)
            BULK COLLECT
            INTO l_res_asg_id_tab,
                 l_start_date_tab,
                 l_end_date_tab
            FROM pa_fp_planning_res_tmp1 tmp1,
                 pa_resource_assignments ra
            WHERE ra.budget_version_id = p_budget_version_id
            AND   ra.task_id = tmp1.task_id
            AND   ra.resource_list_member_id = tmp1.resource_list_member_id
          --AND   ra.resource_assignment_id = tmp1.resource_assignment_id
            AND   ( ra.transaction_source_code IS NOT NULL
                    OR ( ra.transaction_source_code IS NULL
                         AND NOT EXISTS ( SELECT 1
                                          FROM   pa_budget_lines bl
                                          WHERE  bl.resource_assignment_id =
                                                 ra.resource_assignment_id
                                          AND    bl.start_date >= l_etc_start_date
                                          AND    rownum = 1 )))
            GROUP BY tmp1.resource_assignment_id;
        ELSIF p_fp_cols_rec.x_time_phased_code = 'N' THEN
             SELECT /*+ INDEX(tmp1,PA_FP_PLANNING_RES_TMP1_N1)*/
                   tmp1.resource_assignment_id,
                   MIN(tmp1.planning_start_date),
                   MAX(tmp1.planning_end_date)
            BULK COLLECT
            INTO l_res_asg_id_tab,
                 l_start_date_tab,
                 l_end_date_tab
            FROM pa_fp_planning_res_tmp1 tmp1,
                 pa_resource_assignments ra
            WHERE ra.budget_version_id = p_budget_version_id
            AND   ra.task_id = tmp1.task_id
            AND   ra.resource_list_member_id = tmp1.resource_list_member_id
          --AND   ra.resource_assignment_id = tmp1.resource_assignment_id
            AND   ( ra.transaction_source_code IS NOT NULL
                    OR ( ra.transaction_source_code IS NULL
                         AND NOT EXISTS ( SELECT 1
                                          FROM   pa_budget_lines bl
                                          WHERE  bl.resource_assignment_id =
                                                 ra.resource_assignment_id
                                          AND    NVL(bl.quantity,0) <>
                                                 NVL(bl.init_quantity,0)
                                          AND    rownum = 1 )))
            GROUP BY tmp1.resource_assignment_id;
        END IF; -- time phase check
    END IF;

    l_last_updated_by := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;
    l_sysdate := SYSDATE;

    FORALL i in 1..l_res_asg_id_tab.count
        UPDATE pa_resource_assignments
           SET planning_start_date = l_start_date_tab(i),
               planning_end_date = l_end_date_tab(i),
               last_update_date = l_sysdate,
               last_updated_by = l_last_updated_by,
               last_update_login = l_last_update_login,
               record_version_number = record_version_number + 1
         WHERE resource_assignment_id = l_res_asg_id_tab(i);

    -- End Bug 3982592

    /**Now, the new res_asg_id needs to be populated back from pjlanning_tmp1
      *to calc_tmp1 and calc_tmp2**/

    OPEN update_res_asg;
    FETCH update_res_asg
    BULK COLLECT
    INTO l_upd_task_id_tab,
         l_upd_rlm_id_tab,
         l_upd_target_ra_id_tab;
    CLOSE update_res_asg;

            /*IF p_pa_debug_mode = 'Y' THEN
                 pa_fp_gen_amount_utils.fp_debug
                (p_msg         => 'Value of l_upd_target_ra_id_tab.count: '||l_upd_target_ra_id_tab.count,
                 p_module_name => l_module_name,
                 p_log_level   => 5);
            END IF;*/
    --hr_utility.trace('++++l_upd_task_id_tab.count:'||l_upd_task_id_tab.count);
    --for i in 1..l_upd_task_id_tab.count LOOP
    --hr_utility.trace('+++l_upd_task_id_tab(i):'||l_upd_task_id_tab(i));
    --hr_utility.trace('+++l_upd_rlm_id_tab(i):'||l_upd_rlm_id_tab(i));
    --hr_utility.trace('+++l_upd_target_ra_id_tab(i):'||l_upd_target_ra_id_tab(i));
    --end loop;
    --hr_utility.trace('==l_upd_task_id_tab.count'||l_upd_task_id_tab.count);

    IF P_FP_COLS_REC.X_FIN_PLAN_LEVEL_CODE = 'L' THEN
        FORALL i IN 1..l_upd_target_ra_id_tab.count
            UPDATE /*+ INDEX(PA_FP_CALC_AMT_TMP1,PA_FP_CALC_AMT_TMP1_N3)*/
                   PA_FP_CALC_AMT_TMP1
            SET target_res_asg_id = l_upd_target_ra_id_tab(i)
            WHERE mapped_fin_task_id = l_upd_task_id_tab(i)
                  AND target_rlm_id = l_upd_rlm_id_tab(i);
    ELSIF P_FP_COLS_REC.X_FIN_PLAN_LEVEL_CODE = 'T' THEN
        FORALL i IN 1..l_upd_target_ra_id_tab.count
            UPDATE /*+ INDEX(PA_FP_CALC_AMT_TMP1,PA_FP_CALC_AMT_TMP1_N3)*/
                   PA_FP_CALC_AMT_TMP1
            SET target_res_asg_id = l_upd_target_ra_id_tab(i)
            WHERE mapped_fin_task_id = l_upd_task_id_tab(i)
                  AND target_rlm_id = l_upd_rlm_id_tab(i);
    ELSIF P_FP_COLS_REC.X_FIN_PLAN_LEVEL_CODE = 'P' THEN
        FORALL i IN 1..l_upd_target_ra_id_tab.count
            -- SQL Repository Bug 4884824; SQL ID 14901771
            -- Fixed Full Index Scan violation by replacing
            -- existing hint with leading hint.
            UPDATE /*+ LEADING(PA_FP_CALC_AMT_TMP1) */
                   PA_FP_CALC_AMT_TMP1
            SET target_res_asg_id = l_upd_target_ra_id_tab(i)
            WHERE target_rlm_id = l_upd_rlm_id_tab(i);
    END IF;

    /* Since the ETC generation source can change between successive generations,
     * we need to update the transaction_source_code for target resources. */

    -- Bug 4301959: Modified the Retain Manually Added Lines logic to
    -- handle the non-time phased case separately, using the (quantity <>
    -- actual quantity) check instead of (start_date > etc_start_date).

    IF p_fp_cols_rec.X_GEN_RET_MANUAL_LINE_FLAG = 'N' THEN
        SELECT DISTINCT target_res_asg_id, transaction_source_code
        BULK COLLECT
        INTO   l_tgt_res_asg_id_tab,
               l_txn_src_code_tab
        FROM   PA_FP_CALC_AMT_TMP1;
    ELSIF p_fp_cols_rec.X_GEN_RET_MANUAL_LINE_FLAG = 'Y' THEN
        IF p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
            SELECT /*+ INDEX(tmp1,PA_FP_CALC_AMT_TMP1_N1)*/
                   DISTINCT tmp1.target_res_asg_id, tmp1.transaction_source_code
            BULK COLLECT
            INTO   l_tgt_res_asg_id_tab,
                   l_txn_src_code_tab
            FROM   PA_FP_CALC_AMT_TMP1 tmp1,
                   pa_resource_assignments ra
            WHERE  ra.budget_version_id = p_budget_version_id
            AND    ra.resource_assignment_id = tmp1.target_res_asg_id
            AND    ( ra.transaction_source_code IS NOT NULL
                     OR ( ra.transaction_source_code IS NULL
                          AND NOT EXISTS ( SELECT 1
                                           FROM   pa_budget_lines bl
                                           WHERE  bl.resource_assignment_id =
                                                  ra.resource_assignment_id
                                           AND    bl.start_date >= l_etc_start_date
                                           AND    rownum = 1 )));
        ELSIF p_fp_cols_rec.x_time_phased_code = 'N' THEN
            SELECT /*+ INDEX(tmp1,PA_FP_CALC_AMT_TMP1_N1)*/
                   DISTINCT tmp1.target_res_asg_id, tmp1.transaction_source_code
            BULK COLLECT
            INTO   l_tgt_res_asg_id_tab,
                   l_txn_src_code_tab
            FROM   PA_FP_CALC_AMT_TMP1 tmp1,
                   pa_resource_assignments ra
            WHERE  ra.budget_version_id = p_budget_version_id
            AND    ra.resource_assignment_id = tmp1.target_res_asg_id
            AND    ( ra.transaction_source_code IS NOT NULL
                     OR ( ra.transaction_source_code IS NULL
                          AND NOT EXISTS ( SELECT 1
                                           FROM   pa_budget_lines bl
                                           WHERE  bl.resource_assignment_id =
                                                  ra.resource_assignment_id
                                           AND    NVL(bl.quantity,0) <>
                                                  NVL(bl.init_quantity,0)
                                           AND    rownum = 1 )));
        END IF; -- time phase check
    END IF;

    l_sysdate := SYSDATE;
    l_last_updated_by := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    FORALL i in 1..l_tgt_res_asg_id_tab.count
        UPDATE pa_resource_assignments
        SET    transaction_source_code = l_txn_src_code_tab(i),
               last_update_date = l_sysdate,
               last_updated_by = l_last_updated_by,
               last_update_login = l_last_update_login,
               record_version_number = record_version_number + 1
        WHERE  resource_assignment_id = l_tgt_res_asg_id_tab(i);

    SELECT resource_assignment_id, target_res_asg_id
    BULK COLLECT
    INTO l_upd_ra_id_tab1,
         l_upd_target_ra_id_tab1
    FROM PA_FP_CALC_AMT_TMP1;

    --hr_utility.trace('??l_upd_ra_id_tab1.count:'||l_upd_ra_id_tab1.count);
    --for i in 1.. l_upd_ra_id_tab1.count LOOP
    --hr_utility.trace('??l_upd_ra_id_tab1(i):'||l_upd_ra_id_tab1(i));
    --hr_utility.trace('??l_upd_target_ra_id_tab1(i):'||l_upd_target_ra_id_tab1(i));
    --END LOOP;
             /*IF p_pa_debug_mode = 'Y' THEN
                 pa_fp_gen_amount_utils.fp_debug
                (p_msg         => 'Value of l_upd_ra_id_tab1.count: '||l_upd_ra_id_tab1.count,
                 p_module_name => l_module_name,
                 p_log_level   => 5);
            END IF;*/

    FORALL i IN 1..l_upd_ra_id_tab1.count
        UPDATE /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
               PA_FP_CALC_AMT_TMP2
        SET target_res_asg_id = l_upd_target_ra_id_tab1(i)
        WHERE resource_assignment_id = l_upd_ra_id_tab1(i);

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
                  p_msg_index_out  => l_msg_index_out);
            x_msg_data := l_data;
            x_msg_count := l_msg_count;
        ELSE
            x_msg_count := l_msg_count;
        END IF;

        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF p_pa_debug_mode = 'Y' THEN
           PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            (p_msg         => 'Invalid Arguments Passed',
             p_module_name => l_module_name,
             p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(sqlerrm,1,240);
        FND_MSG_PUB.ADD_EXC_MSG
                   ( p_pkg_name        => 'PA_FP_GEN_FCST_RMAP_PKG',
                     p_procedure_name  => 'FCST_SRC_TXNS_RMAP',
                     p_error_text      => substr(sqlerrm,1,240));

        IF p_pa_debug_mode = 'Y' THEN
           PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
             p_module_name => l_module_name,
             p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END FCST_SRC_TXNS_RMAP;

END PA_FP_GEN_FCST_RMAP_PKG;

/
