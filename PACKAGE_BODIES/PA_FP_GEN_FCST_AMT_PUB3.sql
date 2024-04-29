--------------------------------------------------------
--  DDL for Package Body PA_FP_GEN_FCST_AMT_PUB3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_GEN_FCST_AMT_PUB3" as
/* $Header: PAFPFG3B.pls 120.7.12010000.2 2009/05/25 14:52:54 gboomina ship $ */

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

/* Assumption:
 *1.Before getting into this procedure, we have all total plan amounts and commitment
  amounts populated in temporary table PA_FP_CALC_AMT_TMP2 table with transaction
  source codes of 'WORKPLAN'/'FINPLAN' or 'OPEN_COMMITMENTS'.
  2.Rate based flag for target resource assignment gets updated correctly before coming
  into any of ETC methods.
  3.All considered scenarios:
    Rate_based
      non multi currency enabled: use PC
      multi currency enabled
        actuals currency is subset of total currency: use TC, currency based substraction
        actuals currency is not subset of total currency: use TC, prorate ETC quantity
    Non_rate_based
      non multi currency enabled: use PC
      multi currency enabled
        actuals currency not subset of total currency: use TC, currency based substraction
        actuals currency not subset of total currency: Compute ETC quantity in PC, prorate
            this ETC quantity to different planning currencies based on PC amounts,
            convert back from PC to TC.
*/

PROCEDURE GET_ETC_REMAIN_BDGT_AMTS
          (P_SRC_RES_ASG_ID             IN PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE,
           P_TGT_RES_ASG_ID             IN PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE,
           P_FP_COLS_SRC_REC            IN PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_FP_COLS_TGT_REC            IN PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_TASK_ID                    IN PA_TASKS.TASK_ID%TYPE,
           P_RESOURCE_LIST_MEMBER_ID    IN PA_RESOURCE_LIST_MEMBERS.RESOURCE_LIST_MEMBER_ID%TYPE,
           P_ETC_SOURCE_CODE            IN PA_TASKS.GEN_ETC_SOURCE_CODE%TYPE,
           P_WP_STRUCTURE_VERSION_ID    IN PA_PROJ_ELEM_VER_STRUCTURE.ELEMENT_VERSION_ID%TYPE,
           P_ACTUALS_THRU_DATE          IN PA_PERIODS_ALL.END_DATE%TYPE,
           P_PLANNING_OPTIONS_FLAG      IN VARCHAR2,
           X_RETURN_STATUS              OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT                  OUT  NOCOPY NUMBER,
           X_MSG_DATA                   OUT  NOCOPY VARCHAR2)
IS
  l_module_name  VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_FCST_AMT_PUB3.GEN_ETC_REMAIN_BDGT_AMTS';

  l_currency_flag               VARCHAR2(30);
  l_rate_based_flag             VARCHAR2(1);
  l_currency_count_for_flag     NUMBER;
  l_prorating_always_flag       VARCHAR2(1);
  l_target_version_type         pa_budget_versions.version_type%type;

  /* For PC amounts */
  l_pc_currency_code            pa_projects_all.project_currency_code%type;
  l_tot_quantity_pc_pfc         NUMBER;
  l_tot_raw_cost_pc_pfc         NUMBER;
  l_tot_brdn_cost_pc_pfc        NUMBER;
  l_tot_revenue_pc_pfc          NUMBER;

  l_act_quantity_pc_pfc         NUMBER;

  /*For workplan actuals*/
  lx_act_quantity               NUMBER;
  lx_act_txn_currency_code      VARCHAR2(30);
  lx_act_txn_raw_cost           NUMBER;
  lx_act_txn_brdn_cost          NUMBER;
  lx_act_pc_raw_cost            NUMBER;
  lx_act_pc_brdn_cost           NUMBER;
  lx_act_pfc_raw_cost           NUMBER;
  lx_act_pfc_brdn_cost          NUMBER;

  l_etc_quantity_pc_pfc         NUMBER;

  /* For TC amounts */
  l_tot_currency_code_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
  l_tot_quantity_tab            PA_PLSQL_DATATYPES.NumTabTyp;
  l_tot_raw_cost_tab            PA_PLSQL_DATATYPES.NumTabTyp;
  l_tot_brdn_cost_tab           PA_PLSQL_DATATYPES.NumTabTyp;
  l_tot_revenue_tab             PA_PLSQL_DATATYPES.NumTabTyp;
  l_tot_quantity_sum            NUMBER;

  l_act_currency_code_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
  l_act_quantity_tab            PA_PLSQL_DATATYPES.NumTabTyp;
  l_act_raw_cost_tab            PA_PLSQL_DATATYPES.NumTabTyp;
  l_act_brdn_cost_tab           PA_PLSQL_DATATYPES.NumTabTyp;
  l_act_revenue_tab             PA_PLSQL_DATATYPES.NumTabTyp;
  l_act_quantity_sum            NUMBER;

  /* ForPFC amounts */
  l_pfc_currency_code           pa_projects_all.project_currency_code%type;
  l_rev_gen_method              VARCHAR2(3);


  /* For ETC amounts */
  l_etc_quantity_tab            PA_PLSQL_DATATYPES.NumTabTyp;
  l_etc_quantity_sum            NUMBER;

  l_currency_count_act_min_tot  NUMBER;
  l_currency_prorate_act_flag   VARCHAR2(1);
  l_exit_flag                   VARCHAR2(1) := 'N';

  /*For PC_TC amounts*/
  l_tot_quantity_pc_tab         PA_PLSQL_DATATYPES.NumTabTyp;
  l_tot_raw_cost_pc_tab         PA_PLSQL_DATATYPES.NumTabTyp;
  l_tot_brdn_cost_pc_tab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_tot_revenue_pc_tab          PA_PLSQL_DATATYPES.NumTabTyp;
  l_tot_quantity_pc_sum         NUMBER;
  l_act_quantity_pc_sum         NUMBER;
  l_etc_quantity_pc_tab         PA_PLSQL_DATATYPES.NumTabTyp;
  l_etc_quantity_pc_sum         NUMBER;

  /*For average rates*/
  l_pc_pfc_rate_quantity        NUMBER;
  l_pc_pfc_rate_raw_cost        NUMBER;
  l_pc_pfc_rate_brdn_cost       NUMBER;
  l_pc_pfc_rate_revenue         NUMBER;

  l_pc_rate_quantity            NUMBER;
  l_pc_rate_raw_cost            NUMBER;
  l_pc_rate_brdn_cost           NUMBER;
  l_pc_rate_revenue             NUMBER;

  l_txn_rate_quantity           NUMBER;
  l_txn_rate_raw_cost           NUMBER;
  l_txn_rate_brdn_cost          NUMBER;
  l_txn_rate_revenue            NUMBER;

  l_pc_pfc_raw_cost_rate        NUMBER;
  l_pc_pfc_brdn_cost_rate       NUMBER;
  l_pc_pfc_revenue_rate         NUMBER;

  l_txn_raw_cost_rate_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  l_txn_brdn_cost_rate_tab      PA_PLSQL_DATATYPES.NumTabTyp;
  l_txn_revenue_rate_tab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_pc_raw_cost_rate_tab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_pc_brdn_cost_rate_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  l_pc_revenue_rate_tab         PA_PLSQL_DATATYPES.NumTabTyp;
  l_transaction_source_code     VARCHAR2(30);

  /*For txn currency conversion*/
  l_task_id                     pa_tasks.task_id%type;
  l_planning_start_date         pa_resource_assignments.planning_start_date%type;
  lx_acc_rate_date              DATE;
  lx_acct_rate_type             VARCHAR2(50);
  lx_acct_exch_rate             NUMBER;
  lx_acct_raw_cost              NUMBER;
  lx_project_rate_type          VARCHAR2(50);
  lx_project_rate_date          DATE;
  lx_project_exch_rate          NUMBER;
  lx_projfunc_cost_rate_type    VARCHAR2(50);
  lx_projfunc_cost_rate_date    DATE;
  lx_projfunc_cost_exch_rate    NUMBER;
  l_projfunc_raw_cost           NUMBER;

  /* Status variable for GET_CURRENCY_AMOUNTS api */
  l_status                      Varchar2(100);
  g_project_name                pa_projects_all.name%TYPE;

  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_data                    VARCHAR2(2000);
  l_msg_index_out           NUMBER:=0;
BEGIN
    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function     => 'GEN_ETC_REMAIN_BDGT_AMTS',
                                    p_debug_mode   =>  p_pa_debug_mode);
    END IF;

    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_COUNT := 0;

    /*Currency usage should be determined at the beginning.
      Default to use Transaction Currency (TC)
      If target version is not multi currency enabled, take Project Currency (PC)
      IF target version is multi currency enabled, the target planning resource is non
      rate based, and actuals currencies are not subset of the total currencies. We need
      to take PC amounts as quantity, sum up total quantity minus actual quantity,
      prorate this total PC ETC quantity across the planning currencies. Then convert
      them back from PC to TC (PC_TC).*/

    IF nvl(p_tgt_res_asg_id,0) > 0 THEN
        SELECT rate_based_flag
        INTO l_rate_based_flag
        FROM pa_resource_assignments
        WHERE resource_assignment_id = p_tgt_res_asg_id;
    ELSE
        l_rate_based_flag:='N';
    END IF;

    l_currency_flag := 'TC';

      l_rev_gen_method := nvl(P_FP_COLS_TGT_REC.x_revenue_derivation_method,PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(P_FP_COLS_TGT_REC.x_project_id)); -- Bug 5462471

    --l_rev_gen_method := PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(P_FP_COLS_TGT_REC.x_project_id);

    IF (p_fp_cols_tgt_rec.x_version_type = 'REVENUE' and l_rev_gen_method = 'C') THEN
        l_currency_flag := 'PFC';
    ELSIF p_fp_cols_tgt_rec.X_PLAN_IN_MULTI_CURR_FLAG = 'N' THEN
        l_currency_flag := 'PC';
    ELSIF l_rate_based_flag = 'N' THEN
        SELECT COUNT(*) INTO l_currency_count_for_flag FROM (
            SELECT /*+ INDEX(act_tmp,PA_FP_FCST_GEN_TMP1_N1) INDEX(tot_tmp,PA_FP_CALC_AMT_TMP1_N1)*/
                   DISTINCT act_tmp.txn_currency_code
            FROM PA_FP_FCST_GEN_TMP1 act_tmp,
            PA_FP_CALC_AMT_TMP1 tot_tmp
            WHERE act_tmp.project_element_id = tot_tmp.task_id
            AND act_tmp.res_list_member_id = tot_tmp.resource_list_member_id
            AND tot_tmp.target_res_asg_id = p_tgt_res_asg_id
            AND data_type_code = DECODE(P_ETC_SOURCE_CODE,
                                        'WORKPLAN_RESOURCES', 'ETC_WP',
                                        'FINANCIAL_PLAN', 'ETC_FP')
            MINUS
            SELECT /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N1)*/
                   DISTINCT txn_currency_code
            FROM PA_FP_CALC_AMT_TMP2
            WHERE target_res_asg_id = p_tgt_res_asg_id
            AND transaction_source_code = p_etc_source_code
        ) WHERE rownum = 1;

        IF l_currency_count_for_flag > 0 THEN
            l_currency_flag := 'PC_TC';
        END IF;
    END IF;

    /**************BY THIS TIME, WE DECIDED TO USE EITHER PC,TC,PC_TC or PFC**********/

    l_target_version_type := p_fp_cols_tgt_rec.x_version_type;
    l_pc_currency_code := p_fp_cols_tgt_rec.x_project_currency_code;
    l_pfc_currency_code := p_fp_cols_tgt_rec.x_projfunc_currency_code;
    IF l_currency_flag = 'PC' OR l_currency_flag = 'PFC' THEN
        /* No matter ETC source is 'FINANCIAL_PLAN' or 'WORKPLAN_RESOURCES', always get
           total plan amounts in PC or PFC from financial data model.*/
        SELECT  /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
                NVL(SUM(NVL(total_plan_quantity,0)),0),
                NVL(SUM(NVL(
                    DECODE(l_currency_flag, 'PC', total_pc_raw_cost,
                                            'PFC', total_pfc_raw_cost),0)),0),
                NVL(SUM(NVL(
                    DECODE(l_currency_flag, 'PC', total_pc_burdened_cost,
                                            'PFC', total_pfc_burdened_cost),0)),0),
                NVL(SUM(NVL(
                    DECODE(l_currency_flag, 'PC', total_pc_revenue,
                                            'PFC', total_pfc_revenue),0)),0)
        INTO    l_tot_quantity_pc_pfc,
                l_tot_raw_cost_pc_pfc,
                l_tot_brdn_cost_pc_pfc,
                l_tot_revenue_pc_pfc
        FROM PA_FP_CALC_AMT_TMP2
        WHERE resource_assignment_id = p_src_res_asg_id
        AND transaction_source_code = p_etc_source_code;

        IF l_rate_based_flag = 'N' THEN
            l_tot_quantity_pc_pfc := l_tot_raw_cost_pc_pfc;
        END IF;

        IF p_etc_source_code = 'FINANCIAL_PLAN' THEN
            SELECT /*+ INDEX(PA_FP_FCST_GEN_TMP1,PA_FP_FCST_GEN_TMP1_N1)*/
                   DECODE(l_currency_flag,
                    'PC', NVL(SUM(DECODE(l_rate_based_flag,
                        'Y', quantity,
                        'N', NVL(prj_raw_cost,0))),0),
                    'PFC', NVL(SUM(DECODE(l_rate_based_flag,
                        'Y', quantity,
                        'N', NVL(pou_raw_cost,0))),0))
            INTO l_act_quantity_pc_pfc
            FROM PA_FP_FCST_GEN_TMP1
            WHERE project_element_id = p_task_id
            AND res_list_member_id = p_resource_list_member_id
            AND data_type_code = 'ETC_FP';

        ELSIF p_etc_source_code = 'WORKPLAN_RESOURCES' THEN
            /*Bug fix for 3973511
              Workplan side only stores amounts in one currency for each planning
              resource. Instead of relying on pa_progress_utils.get_actuals_for_task
              to get actuals data, we query directly to pa_budget_lines to get actual
              data from source workplan budget version */
            IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug(
                    p_msg         => 'Before calling PA_FP_GEN_FCST_AMT_PUB1.'||
                                    'GET_WP_ACTUALS_FOR_RA',
                    p_module_name => l_module_name,
                    p_log_level   => 5);
            END IF;
            PA_FP_GEN_FCST_AMT_PUB1.GET_WP_ACTUALS_FOR_RA
                (P_FP_COLS_SRC_REC        => p_fp_cols_src_rec,
                P_FP_COLS_TGT_REC        => p_fp_cols_tgt_rec,
                P_SRC_RES_ASG_ID         => p_src_res_asg_id,
                P_TASK_ID                => p_task_id,
                P_RES_LIST_MEM_ID        => p_resource_list_member_id,
                P_ACTUALS_THRU_DATE      => p_actuals_thru_date,
                X_ACT_QUANTITY           => lx_act_quantity,
                X_ACT_TXN_CURRENCY_CODE  => lx_act_txn_currency_code,
                X_ACT_TXN_RAW_COST       => lx_act_txn_raw_cost,
                X_ACT_TXN_BRDN_COST      => lx_act_txn_brdn_cost,
                X_ACT_PC_RAW_COST        => lx_act_pc_raw_cost,
                X_ACT_PC_BRDN_COST       => lx_act_pc_brdn_cost,
                X_ACT_PFC_RAW_COST       => lx_act_pfc_raw_cost,
                X_ACT_PFC_BRDN_COST      => lx_act_pfc_brdn_cost,
                X_RETURN_STATUS          => x_return_status,
                X_MSG_COUNT              => x_msg_count,
                X_MSG_DATA               => x_msg_data );
            IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug(
                    p_msg         => 'After calling PA_FP_GEN_FCST_AMT_PUB1.'||
                                     'GET_WP_ACTUALS_FOR_RA in remain_bdgt:'||x_return_status,
                    p_module_name => l_module_name,
                    p_log_level   => 5);
            END IF;
            IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            IF l_rate_based_flag = 'Y' THEN
                l_act_quantity_pc_pfc := lx_act_quantity;
            ELSE
                IF l_currency_flag = 'PC' THEN
                    l_act_quantity_pc_pfc :=  lx_act_pc_raw_cost;
                ELSIF l_currency_flag = 'PFC' THEN
                    l_act_quantity_pc_pfc :=  lx_act_pfc_raw_cost;
                END IF;
            END IF;
        END IF;

        /* Get total ETC quantity */
        l_etc_quantity_pc_pfc := l_tot_quantity_pc_pfc - l_act_quantity_pc_pfc;
        IF l_etc_quantity_pc_pfc <= 0  THEN
            /* actual quantity > total ETC quantity, only need to spread
               commitment and actual data*/
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.RESET_CURR_FUNCTION;
            END IF;
            RETURN;
        END IF;

        /*  hr_utility.trace('project currency:'||l_ppc_currency_code);
            hr_utility.trace('etc qty '||l_etc_quantity_pc );*/

        /*When not taking periodic rates, we need to calculate out the average
          rates from the source resource assignments that are mapped to the current
          target resource assignmentInsert the single PC record for total ETC.*/
        SELECT  /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
                NVL(SUM(NVL(total_plan_quantity,0)),0),
                DECODE(l_currency_flag,
                    'PC', NVL(SUM(NVL(total_pc_raw_cost,0)),0),
                    'PFC', NVL(SUM(NVL(total_pfc_raw_cost,0)),0)),
                DECODE(l_currency_flag,
                    'PC', NVL(SUM(NVL(total_pc_burdened_cost,0)),0),
                    'PFC', NVL(SUM(NVL(total_pfc_burdened_cost,0)),0)),
                DECODE(l_currency_flag,
                    'PC', NVL(SUM(NVL(total_pc_revenue,0)),0),
                    'PFC', NVL(SUM(NVL(total_pfc_revenue,0)),0))
        INTO    l_pc_pfc_rate_quantity,
                l_pc_pfc_rate_raw_cost,
                l_pc_pfc_rate_brdn_cost,
                l_pc_pfc_rate_revenue
        FROM pa_fp_calc_amt_tmp2
        WHERE resource_assignment_id = p_src_res_asg_id
          AND transaction_source_code in ('FINANCIAL_PLAN',
                                          'WORKPLAN_RESOURCES');

        IF l_rate_based_flag = 'N' THEN
            l_pc_pfc_rate_quantity := l_pc_pfc_rate_raw_cost;
        END IF;

        IF l_pc_pfc_rate_quantity <> 0 THEN
            l_pc_pfc_raw_cost_rate := l_pc_pfc_rate_raw_cost / l_pc_pfc_rate_quantity;
            l_pc_pfc_brdn_cost_rate := l_pc_pfc_rate_brdn_cost / l_pc_pfc_rate_quantity;
            l_pc_pfc_revenue_rate := l_pc_pfc_rate_revenue / l_pc_pfc_rate_quantity;
        ELSE
            l_pc_pfc_raw_cost_rate := NULL;
            l_pc_pfc_brdn_cost_rate := NULL;
            l_pc_pfc_revenue_rate := NULL;
        END IF;

        /*Insert single PC record
          If commitment is not included, record is inserted directly as 'ETC'
          record, if commitment is to be considered, record is inserted as
          'TOTAL_ETC' for further processing. */
        IF P_FP_COLS_TGT_REC.X_GEN_INCL_OPEN_COMM_FLAG = 'Y' THEN
            l_transaction_source_code := 'TOTAL_ETC';
        ELSE
            l_transaction_source_code := 'ETC';
        END IF;

        INSERT INTO PA_FP_CALC_AMT_TMP2 (
                RESOURCE_ASSIGNMENT_ID,
                TARGET_RES_ASG_ID,
                ETC_CURRENCY_CODE,
                ETC_PLAN_QUANTITY,
                ETC_TXN_RAW_COST,
                ETC_TXN_BURDENED_COST,
                ETC_TXN_REVENUE,
                ETC_PC_RAW_COST,
                ETC_PC_BURDENED_COST,
                ETC_PC_REVENUE,
                ETC_PFC_RAW_COST,
                ETC_PFC_BURDENED_COST,
                ETC_PFC_REVENUE,
                TRANSACTION_SOURCE_CODE)
        VALUES (
                P_SRC_RES_ASG_ID,
                P_TGT_RES_ASG_ID,
                DECODE(l_currency_flag, 'PC', l_pc_currency_code,
                                        'PFC', l_pfc_currency_code),
                l_etc_quantity_pc_pfc,
                l_etc_quantity_pc_pfc * l_pc_pfc_raw_cost_rate,
                l_etc_quantity_pc_pfc * l_pc_pfc_brdn_cost_rate,
                l_etc_quantity_pc_pfc * l_pc_pfc_revenue_rate,
                DECODE(l_currency_flag,
                    'PC', l_etc_quantity_pc_pfc * l_pc_pfc_raw_cost_rate,
                    'PFC', NULL),
                DECODE(l_currency_flag,
                    'PC', l_etc_quantity_pc_pfc * l_pc_pfc_brdn_cost_rate,
                    'PFC', NULL),
                DECODE(l_currency_flag,
                    'PC', l_etc_quantity_pc_pfc * l_pc_pfc_revenue_rate,
                    'PFC', NULL),
                DECODE(l_currency_flag,
                    'PFC', l_etc_quantity_pc_pfc * l_pc_pfc_raw_cost_rate,
                    'PC', NULL),
                DECODE(l_currency_flag,
                    'PFC', l_etc_quantity_pc_pfc * l_pc_pfc_brdn_cost_rate,
                    'PC', NULL),
                DECODE(l_currency_flag,
                    'PFC', l_etc_quantity_pc_pfc * l_pc_pfc_revenue_rate,
                    'PC', NULL),
                l_transaction_source_code);

    /**************BY THIS TIME, WE HAVE ALL ETC DATA FOR PC or PFC*********/

    ELSIF l_currency_flag = 'TC' THEN
        /* No matter ETC source is 'FINANCIAL_PLAN' or 'WORKPLAN_RESOURCES', always
           get total plan amounts by txn currency from financial data model.*/
        SELECT  /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
                txn_currency_code,
                SUM(NVL(total_plan_quantity,0)),
                SUM(NVL(total_txn_raw_cost,0)),
                SUM(NVL(total_txn_burdened_cost,0)),
                SUM(NVL(total_txn_revenue,0))
        BULK COLLECT INTO
                l_tot_currency_code_tab,
                l_tot_quantity_tab,
                l_tot_raw_cost_tab,
                l_tot_brdn_cost_tab,
                l_tot_revenue_tab
        FROM PA_FP_CALC_AMT_TMP2
        WHERE resource_assignment_id = p_src_res_asg_id
        AND transaction_source_code = p_etc_source_code
        GROUP BY txn_currency_code;

        IF l_tot_currency_code_tab.count = 0 THEN
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.RESET_CURR_FUNCTION;
            END IF;
            RETURN;
        END IF;
        IF l_rate_based_flag = 'N' THEN
            l_tot_quantity_tab := l_tot_raw_cost_tab;
        END IF;

        /* Bug 4085203
           The total plan amounts should be summed up irrespective of rate based
           or non rate based. Because for non rate based resource, we used the
           sum value when plan and actuals are using same one currency. When
           plan and actuals are using more than one currencies, the flow will
           not use the sum amounts.*/
        l_tot_quantity_sum := 0;
        FOR i IN 1..l_tot_quantity_tab.count LOOP
            l_tot_quantity_sum := l_tot_quantity_sum + NVL(l_tot_quantity_tab(i),0);
        END LOOP;

        IF p_etc_source_code = 'FINANCIAL_PLAN' THEN
            SELECT  /*+ INDEX(PA_FP_FCST_GEN_TMP1,PA_FP_FCST_GEN_TMP1_N1)*/
                    txn_currency_code,
                    SUM(NVL(quantity,0)),
                    SUM(NVL(txn_raw_cost,0)),
                    SUM(NVL(txn_brdn_cost,0)),
                    SUM(NVL(txn_revenue,0))
            BULK COLLECT INTO
                    l_act_currency_code_tab,
                    l_act_quantity_tab,
                    l_act_raw_cost_tab,
                    l_act_brdn_cost_tab,
                    l_act_revenue_tab
            FROM PA_FP_FCST_GEN_TMP1
            WHERE project_element_id = p_task_id
            AND res_list_member_id = p_resource_list_member_id
            AND data_type_code = 'ETC_FP'
            GROUP BY txn_currency_code;

            IF l_rate_based_flag = 'N' THEN
                l_act_quantity_tab := l_act_raw_cost_tab;
            END IF;

            /* Bug 4085203
               The total actual amounts should be summed up irrespective of rate based
               or non rate based. Because for non rate based resource, we used the
               sum value when plan and actuals are using same one currency. When
               plan and actuals are using more than one currencies, the flow will
               not use the sum amounts.*/
            l_act_quantity_sum := 0;
            FOR i IN 1..l_act_quantity_tab.count LOOP
                l_act_quantity_sum := l_act_quantity_sum + l_act_quantity_tab(i);
            END LOOP;

        ELSIF p_etc_source_code = 'WORKPLAN_RESOURCES' THEN
            /*Bug fix for 3973511
              Workplan side only stores amounts in one currency for each planning
              resource. Instead of relying on pa_progress_utils.get_actuals_for_task
              to get actuals data, we query directly to pa_budget_lines to get actual
              data from source workplan budget version */
            IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug(
                    p_msg         => 'Before calling PA_FP_GEN_FCST_AMT_PUB1.'||
                                    'GET_WP_ACTUALS_FOR_RA',
                    p_module_name => l_module_name,
                    p_log_level   => 5);
            END IF;
            PA_FP_GEN_FCST_AMT_PUB1.GET_WP_ACTUALS_FOR_RA
                (P_FP_COLS_SRC_REC        => p_fp_cols_src_rec,
                P_FP_COLS_TGT_REC        => p_fp_cols_tgt_rec,
                P_SRC_RES_ASG_ID         => p_src_res_asg_id,
                P_TASK_ID                => p_task_id,
                P_RES_LIST_MEM_ID        => p_resource_list_member_id,
                P_ACTUALS_THRU_DATE      => p_actuals_thru_date,
                X_ACT_QUANTITY           => lx_act_quantity,
                X_ACT_TXN_CURRENCY_CODE  => lx_act_txn_currency_code,
                X_ACT_TXN_RAW_COST       => lx_act_txn_raw_cost,
                X_ACT_TXN_BRDN_COST      => lx_act_txn_brdn_cost,
                X_ACT_PC_RAW_COST        => lx_act_pc_raw_cost,
                X_ACT_PC_BRDN_COST       => lx_act_pc_brdn_cost,
                X_ACT_PFC_RAW_COST       => lx_act_pfc_raw_cost,
                X_ACT_PFC_BRDN_COST      => lx_act_pfc_brdn_cost,
                X_RETURN_STATUS          => x_return_status,
                X_MSG_COUNT              => x_msg_count,
                X_MSG_DATA               => x_msg_data );
            IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug(
                    p_msg         => 'After calling PA_FP_GEN_FCST_AMT_PUB1.'||
                                     'GET_WP_ACTUALS_FOR_RA in remain_bdgt:'||x_return_status,
                    p_module_name => l_module_name,
                    p_log_level   => 5);
            END IF;
            IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            l_act_currency_code_tab(1) := lx_act_txn_currency_code;
            l_act_quantity_tab(1) := lx_act_quantity;
            l_act_raw_cost_tab(1) := lx_act_txn_raw_cost;
            l_act_brdn_cost_tab(1):= lx_act_txn_brdn_cost;
            l_act_revenue_tab(1) := 0;

            IF l_rate_based_flag = 'N' THEN
                l_act_quantity_tab := l_act_raw_cost_tab;
            END IF;

            l_act_quantity_sum := l_act_quantity_tab(1);
        END IF;


        /* Check the relationship between total currency codes and actual currency
           codes. If actual currency codes are subset of total currency codes, then,
           take currency based approach; otherwise, take prorating based approach.
           'C' means take currency based calculation
           'P' means take prorating based calculation */

        SELECT COUNT(*)
        INTO l_currency_count_act_min_tot
        FROM (
            SELECT /*+ INDEX(PA_FP_FCST_GEN_TMP1,PA_FP_FCST_GEN_TMP1_N1)*/
                   DISTINCT txn_currency_code
            FROM PA_FP_FCST_GEN_TMP1
            WHERE project_element_id = p_task_id
            AND res_list_member_id = p_resource_list_member_id
            AND data_type_code = DECODE(P_ETC_SOURCE_CODE,
                                        'WORKPLAN_RESOURCES', 'ETC_WP',
                                        'FINANCIAL_PLAN', 'ETC_FP')
            MINUS
            SELECT /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
                   DISTINCT txn_currency_code
            FROM PA_FP_CALC_AMT_TMP2
            WHERE resource_assignment_id  = p_src_res_asg_id
            AND transaction_source_code = p_etc_source_code
        ) WHERE rownum = 1;

        IF l_currency_count_act_min_tot = 0 THEN
            l_currency_prorate_act_flag := 'C';
        ELSE
            l_currency_prorate_act_flag := 'P';
        END IF;

        /*Bug fix: 4085203: If there only exists one plan currency,
          one actual currency and they are same, no matter it's rate
          based resource or non rate based resource, if etc quantity is
          calculated as less or equal to zero, then don't generate the ETC.*/
        IF  l_act_currency_code_tab.count = 1 AND l_tot_currency_code_tab.count = 1 THEN
            l_etc_quantity_sum := l_tot_quantity_sum - l_act_quantity_sum;
            IF l_etc_quantity_sum <= 0 THEN
                IF P_PA_DEBUG_MODE = 'Y' THEN
                    PA_DEBUG.RESET_CURR_FUNCTION;
                END IF;
                RETURN;
            ELSE
                l_etc_quantity_tab(1) := l_etc_quantity_sum;
            END IF;
        ELSE
            l_exit_flag := 'N';
            IF l_currency_prorate_act_flag = 'C' THEN
                FOR i IN 1..l_tot_currency_code_tab.count LOOP
                    IF l_exit_flag = 'Y' THEN
                        EXIT;
                    END IF;
                    l_etc_quantity_tab(i) := l_tot_quantity_tab(i);
                    FOR j IN 1..l_act_currency_code_tab.count LOOP
                        IF l_tot_currency_code_tab(i) = l_act_currency_code_tab(j) THEN
                            l_etc_quantity_tab(i) := l_etc_quantity_tab(i) - l_act_quantity_tab(j);
                            IF l_etc_quantity_tab(i) <= 0 THEN
                                l_currency_prorate_act_flag := 'P';
                                l_etc_quantity_tab.delete;
                                l_exit_flag := 'Y';
                                EXIT;
                            END IF;
                        END IF;
                    END LOOP;
                END LOOP;
            END IF;

            IF l_currency_prorate_act_flag = 'P' THEN
                IF l_rate_based_flag = 'N' THEN
                    l_currency_flag := 'PC_TC';
                ELSIF l_rate_based_flag = 'Y' THEN
                    l_etc_quantity_sum := l_tot_quantity_sum - l_act_quantity_sum;
                    IF l_etc_quantity_sum <= 0 THEN
                        /* If actual quantity >= total planned quantity, no non-commitment ETC
                           available, only actual and commitment amounts need to be spreaded */
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                            PA_DEBUG.RESET_CURR_FUNCTION;
                        END IF;
                        RETURN;
                    END IF;

                    FOR i IN 1..l_tot_currency_code_tab.count LOOP
                        IF l_tot_quantity_sum <> 0 THEN
                            l_etc_quantity_tab(i) := l_etc_quantity_sum
                                * (l_tot_quantity_tab (i) / l_tot_quantity_sum) ;
                        ELSE
                            l_etc_quantity_tab(i) := NULL;
                        END IF;
                        /*  hr_utility.trace(i||'th');
                            hr_utility.trace('etc qty '||l_etc_qty );
                            hr_utility.trace('etc curr'||l_ETC_CURRENCY_CODE );
                            hr_utility.trace('etc rc  '||l_etc_txn_raw_cost );
                            hr_utility.trace('etc bc  '||l_etc_txn_brdn_cost );  */
                    END LOOP;
                END IF;
            END IF;
        END IF;

        /*currency_flag may get changed to 'PC_TC', when actual currencies is subset of
         planning currencies, target resource is non_rate_based, but actual amount for
         one particular currency is less than plan amount. Then we need to revert from
         currency based approach to prorating based approach.For non_rate_based resource,
         prorating falls in to currency code of 'PC_TC'.*/
        IF l_currency_flag = 'TC' THEN
            /*When not taking periodic rates, we need to calculate out the average
              rates from the source resource assignments that are mapped to the current
              target resource assignment.*/
            FOR i IN 1..l_tot_currency_code_tab.count LOOP
                SELECT  /*+ INDEX(pa_fp_calc_amt_tmp2,PA_FP_CALC_AMT_TMP2_N2)*/
                        NVL(SUM(NVL(total_plan_quantity,0)),0),
                        NVL(SUM(NVL(total_txn_raw_cost,0)),0),
                        NVL(SUM(NVL(total_txn_burdened_cost,0)),0),
                        NVL(SUM(NVL(total_txn_revenue,0)),0),
                        NVL(SUM(NVL(total_pc_raw_cost,0)),0),
                        NVL(SUM(NVL(total_pc_burdened_cost,0)),0),
                        NVL(SUM(NVL(total_pc_revenue,0)),0)
                INTO    l_txn_rate_quantity,
                        l_txn_rate_raw_cost,
                        l_txn_rate_brdn_cost,
                        l_txn_rate_revenue,
                        l_pc_rate_raw_cost,
                        l_pc_rate_brdn_cost,
                        l_pc_rate_revenue
                FROM pa_fp_calc_amt_tmp2
                WHERE resource_assignment_id = p_src_res_asg_id
                AND txn_currency_code = l_tot_currency_code_tab(i)
                AND transaction_source_code in ('FINANCIAL_PLAN',
                                                'WORKPLAN_RESOURCES');

                IF l_rate_based_flag = 'N' THEN
                    l_txn_rate_quantity := l_txn_rate_raw_cost;
                END IF;

                IF l_txn_rate_quantity <> 0 THEN
                    l_txn_raw_cost_rate_tab(i) := l_txn_rate_raw_cost
                                                / l_txn_rate_quantity;
                    l_txn_brdn_cost_rate_tab(i) := l_txn_rate_brdn_cost
                                                / l_txn_rate_quantity;
                    l_txn_revenue_rate_tab(i) := l_txn_rate_revenue
                                                / l_txn_rate_quantity;
                    l_pc_raw_cost_rate_tab(i) := l_pc_rate_raw_cost
                                                / l_txn_rate_quantity;
                    l_pc_brdn_cost_rate_tab(i) := l_pc_rate_brdn_cost
                                                / l_txn_rate_quantity;
                    l_pc_revenue_rate_tab(i) := l_pc_rate_revenue
                                                / l_txn_rate_quantity;
                ELSE
                    l_txn_raw_cost_rate_tab(i) := NULL;
                    l_txn_brdn_cost_rate_tab(i) := NULL;
                    l_txn_revenue_rate_tab(i) := NULL;
                    l_pc_raw_cost_rate_tab(i) := NULL;
                    l_pc_brdn_cost_rate_tab(i) := NULL;
                    l_pc_revenue_rate_tab(i) := NULL;
                END IF;
            END LOOP;

            /*Bulk insert
              If commitment is not included, record is inserted directly as 'ETC'
              record, if commitment is to be considered, record is inserted as
              'TOTAL_ETC' for further processing. */
            IF P_FP_COLS_TGT_REC.X_GEN_INCL_OPEN_COMM_FLAG = 'Y' THEN
                l_transaction_source_code := 'TOTAL_ETC';
            ELSE
                l_transaction_source_code := 'ETC';
            END IF;
            FORALL i IN 1..l_etc_quantity_tab.count
                INSERT INTO PA_FP_CALC_AMT_TMP2 (
                    RESOURCE_ASSIGNMENT_ID,
                    TARGET_RES_ASG_ID,
                    ETC_CURRENCY_CODE,
                    ETC_PLAN_QUANTITY,
                    ETC_TXN_RAW_COST,
                    ETC_TXN_BURDENED_COST,
                    ETC_TXN_REVENUE,
                    ETC_PC_RAW_COST,
                    ETC_PC_BURDENED_COST,
                    ETC_PC_REVENUE,
                    TRANSACTION_SOURCE_CODE )
                VALUES (
                    P_SRC_RES_ASG_ID,
                    P_TGT_RES_ASG_ID,
                    l_tot_currency_code_tab(i),
                    l_etc_quantity_tab(i),
                    l_etc_quantity_tab(i) * l_txn_raw_cost_rate_tab(i),
                    l_etc_quantity_tab(i) * l_txn_brdn_cost_rate_tab(i),
                    l_etc_quantity_tab(i) * l_txn_revenue_rate_tab(i),
                    l_etc_quantity_tab(i) * l_pc_raw_cost_rate_tab(i),
                    l_etc_quantity_tab(i) * l_pc_brdn_cost_rate_tab(i),
                    l_etc_quantity_tab(i) * l_pc_revenue_rate_tab(i),
                    l_transaction_source_code);
        END IF;
    END IF;
    /**************NOW WE HAVE ALL ETC DATA IN TC*************/

    IF l_currency_flag = 'PC_TC' THEN
        /*Take PC for calculation, then convert back to TC.
          This only happens for non rate based resources*/

        /*No matter ETC source is 'FINANCIAL_PLAN' or 'WORKPLAN_RESOURCES',
          always get total plan amounts in PC from financial data model*/
        SELECT  /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
                txn_currency_code,
                SUM(NVL(total_plan_quantity,0)),
                SUM(NVL(total_pc_raw_cost,0)),
                SUM(NVL(total_pc_burdened_cost,0)),
                SUM(NVL(total_pc_revenue,0))
        BULK COLLECT INTO
                l_tot_currency_code_tab,
                l_tot_quantity_pc_tab,
                l_tot_raw_cost_pc_tab,
                l_tot_brdn_cost_pc_tab,
                l_tot_revenue_pc_tab
        FROM PA_FP_CALC_AMT_TMP2
        WHERE resource_assignment_id = p_src_res_asg_id
        AND transaction_source_code = p_etc_source_code
        GROUP BY txn_currency_code;

        IF l_target_version_type = 'COST' OR l_target_version_type = 'ALL' THEN
            l_tot_quantity_pc_tab := l_tot_raw_cost_pc_tab;
        ELSE
            l_tot_quantity_pc_tab := l_tot_revenue_pc_tab;
        END IF;

        l_tot_quantity_pc_sum := 0;
        FOR i IN 1..l_tot_quantity_pc_tab.count LOOP
            l_tot_quantity_pc_sum := l_tot_quantity_pc_sum + l_tot_quantity_pc_tab(i);
        END LOOP;

        IF  p_etc_source_code = 'FINANCIAL_PLAN' THEN
            SELECT  /*+ INDEX(PA_FP_FCST_GEN_TMP1,PA_FP_FCST_GEN_TMP1_N1)*/
                    NVL(SUM( DECODE(l_rate_based_flag,
                    'Y', NVL(quantity,0),
                    'N', NVL(prj_raw_cost,0))),0)
            INTO    l_act_quantity_pc_sum
            FROM PA_FP_FCST_GEN_TMP1
            WHERE project_element_id = p_task_id
            AND res_list_member_id = p_resource_list_member_id
            AND data_type_code = 'ETC_FP';

        ELSIF p_etc_source_code = 'WORKPLAN_RESOURCES' THEN
            /*Workplan side only stores amounts in one currency for each planning
              resource, so still rely on pa_progress_utils.get_actuals_for_task to
              get actuals data. This part needs to be revisted when workplan side is
              changed to support multi currencies.*/
            IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug(
                    p_msg         => 'Before calling PA_FP_GEN_FCST_AMT_PUB1.'||
                                    'GET_WP_ACTUALS_FOR_RA',
                    p_module_name => l_module_name,
                    p_log_level   => 5);
            END IF;
            PA_FP_GEN_FCST_AMT_PUB1.GET_WP_ACTUALS_FOR_RA
                (P_FP_COLS_SRC_REC        => p_fp_cols_src_rec,
                P_FP_COLS_TGT_REC        => p_fp_cols_tgt_rec,
                P_SRC_RES_ASG_ID         => p_src_res_asg_id,
                P_TASK_ID                => p_task_id,
                P_RES_LIST_MEM_ID        => p_resource_list_member_id,
                P_ACTUALS_THRU_DATE      => p_actuals_thru_date,
                X_ACT_QUANTITY           => lx_act_quantity,
                X_ACT_TXN_CURRENCY_CODE  => lx_act_txn_currency_code,
                X_ACT_TXN_RAW_COST       => lx_act_txn_raw_cost,
                X_ACT_TXN_BRDN_COST      => lx_act_txn_brdn_cost,
                X_ACT_PC_RAW_COST        => lx_act_pc_raw_cost,
                X_ACT_PC_BRDN_COST       => lx_act_pc_brdn_cost,
                X_ACT_PFC_RAW_COST       => lx_act_pfc_raw_cost,
                X_ACT_PFC_BRDN_COST      => lx_act_pfc_brdn_cost,
                X_RETURN_STATUS          => x_return_status,
                X_MSG_COUNT              => x_msg_count,
                X_MSG_DATA               => x_msg_data );
            IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug(
                    p_msg         => 'After calling PA_FP_GEN_FCST_AMT_PUB1.'||
                                     'GET_WP_ACTUALS_FOR_RA in remain_bdgt:'||x_return_status,
                    p_module_name => l_module_name,
                    p_log_level   => 5);
            END IF;
            IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            l_act_quantity_pc_sum :=  lx_act_pc_raw_cost;

        END IF;

        /*Prorate total ETC quantity in PC based according to the transaction
          currency codes from the plan totals.*/
        /*Get total ETC quantity and Prorate ETC quantity*/
        l_etc_quantity_pc_sum := l_tot_quantity_pc_sum - l_act_quantity_pc_sum;
        IF l_etc_quantity_pc_sum <= 0 THEN
            /* actual quantity > total ETC quantity,only need to spread
               commitment data and actual data*/
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.RESET_CURR_FUNCTION;
            END IF;
            RETURN;
        END IF;
        FOR i IN 1..l_tot_currency_code_tab.count LOOP
            IF NVL(l_tot_quantity_pc_sum,0) <> 0 THEN
               l_etc_quantity_pc_tab(i) := l_etc_quantity_pc_sum
                   * (l_tot_quantity_pc_tab(i) / l_tot_quantity_pc_sum) ;
            ELSE
               l_etc_quantity_pc_tab(i) := NULL;
               --l_etc_quantity_pc_tab(i) := l_etc_quantity_pc_sum; -- ???
            END IF;
        END LOOP;

        /* Convert PC into TC */
        FOR i IN 1..l_tot_currency_code_tab.count LOOP
            IF l_tot_currency_code_tab(i) = l_pc_currency_code THEN
                l_etc_quantity_tab(i) := l_etc_quantity_pc_tab(i);
            ELSE
                l_etc_quantity_tab(i) := NULL;
                BEGIN
                    SELECT task_id,
                           planning_start_date
                    INTO l_task_id,
                         l_planning_start_date
                    FROM pa_resource_assignments
                    WHERE resource_assignment_id = p_src_res_asg_id;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_task_id := NULL;
                        l_planning_start_date := NULL;
                END;
                IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug(
                        p_msg         => 'Before calling pa_multi_currency_txn.'||
                                         'get_currency_amounts in remain_bdgt',
                        p_module_name => l_module_name,
                        p_log_level   => 5);
                END IF;
                -- Bug 4091344: Changed P_status parameter from x_return_status to
                -- local variable l_status. Afterwards, we check l_status and set
                -- x_return_status accordingly.
                pa_multi_currency_txn.get_currency_amounts (
                    P_project_id        => p_fp_cols_tgt_rec.x_project_id,
                    P_exp_org_id        => NULL,
                    P_calling_module    => 'WORKPLAN',
                    P_task_id           => l_task_id,
                    P_EI_date           => l_planning_start_date,
                    P_denom_raw_cost    => l_etc_quantity_pc_tab(i),
                    P_denom_curr_code   => l_pc_currency_code,
                    P_acct_curr_code    => l_pc_currency_code,
                    P_accounted_flag    => 'N',
                    P_acct_rate_date    => lx_acc_rate_date,
                    P_acct_rate_type    => lx_acct_rate_type,
                    P_acct_exch_rate    => lx_acct_exch_rate,
                    P_acct_raw_cost     => lx_acct_raw_cost,
                    P_project_curr_code => l_tot_currency_code_tab(i),
                    P_project_rate_type => lx_project_rate_type,
                    P_project_rate_date => lx_project_rate_date,
                    P_project_exch_rate => lx_project_exch_rate,
                    P_project_raw_cost  => l_etc_quantity_tab(i),
                    P_projfunc_curr_code=> l_pc_currency_code,
                    P_projfunc_cost_rate_type   => lx_projfunc_cost_rate_type,
                    P_projfunc_cost_rate_date   => lx_projfunc_cost_rate_date,
                    P_projfunc_cost_exch_rate   => lx_projfunc_cost_exch_rate,
                    P_projfunc_raw_cost => l_projfunc_raw_cost,
                    P_system_linkage    => 'NER',
                    P_status            => l_status,
                    P_stage             => x_msg_count);


                IF lx_project_exch_rate IS NULL OR l_status IS NOT NULL THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    g_project_name := NULL;
                    BEGIN
                       SELECT name INTO g_project_name from
                       PA_PROJECTS_ALL WHERE
                       project_id = p_fp_cols_tgt_rec.x_project_id;
                    EXCEPTION
                    WHEN OTHERS THEN
                         g_project_name := NULL;
                    END;
                    PA_UTILS.ADD_MESSAGE
                        ( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_FP_PROJ_NO_TXNCONVRATE'
                          ,p_token1         => 'G_PROJECT_NAME'
                          ,p_value1         => g_project_name
                          ,p_token2         => 'FROMCURRENCY'
                          ,p_value2         => l_pc_currency_code
                          ,p_token3         => 'TOCURRENCY'
                          ,p_value3         => l_tot_currency_code_tab(i) );
                     x_msg_data := 'PA_FP_PROJ_NO_TXNCONVRATE';
                END IF;
                IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug(
                        p_msg         => 'After calling pa_multi_currency_txn.'||
                                         'get_currency_amounts in remain_bdgt:'||x_return_status,
                        p_module_name => l_module_name,
                        p_log_level   => 5);
                END IF;
                IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;
            END IF;
        END LOOP;

        /*When not taking periodic rates, we need to calculate out the average rates
          from the source resource assignments that are mapped to the current target
          resource assignment.*/

        FOR i IN 1..l_tot_currency_code_tab.count LOOP
            SELECT  /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
                    NVL(SUM(NVL(total_plan_quantity,0)),0),
                    NVL(SUM(NVL(total_txn_raw_cost,0)),0),
                    NVL(SUM(NVL(total_txn_burdened_cost,0)),0),
                    NVL(SUM(NVL(total_txn_revenue,0)),0),
                    NVL(SUM(NVL(total_pc_raw_cost,0)),0),
                    NVL(SUM(NVL(total_pc_burdened_cost,0)),0),
                    NVL(SUM(NVL(total_pc_revenue,0)),0)
            INTO    l_txn_rate_quantity,
                    l_txn_rate_raw_cost,
                    l_txn_rate_brdn_cost,
                    l_txn_rate_revenue,
                    l_pc_rate_raw_cost,
                    l_pc_rate_brdn_cost,
                    l_pc_rate_revenue
            FROM pa_fp_calc_amt_tmp2
            WHERE resource_assignment_id = p_src_res_asg_id
            AND txn_currency_code = l_tot_currency_code_tab(i)
            AND transaction_source_code in ('FINANCIAL_PLAN' ,
                                            'WORKPLAN_RESOURCES');

            l_txn_raw_cost_rate_tab(i) := 1;
            l_txn_rate_quantity := l_txn_rate_raw_cost;

            IF l_txn_rate_raw_cost <> 0 THEN
                l_txn_brdn_cost_rate_tab(i) := l_txn_rate_brdn_cost
                                              / l_txn_rate_raw_cost;
                l_txn_revenue_rate_tab(i) := l_txn_rate_revenue
                                              / l_txn_rate_raw_cost;
                l_pc_raw_cost_rate_tab(i) := l_pc_rate_raw_cost
                                            / l_txn_rate_raw_cost;
                l_pc_brdn_cost_rate_tab(i) := l_pc_rate_brdn_cost
                                            / l_txn_rate_raw_cost;
                l_pc_revenue_rate_tab(i) := l_pc_rate_revenue
                                            / l_txn_rate_raw_cost;
            ELSE
                l_txn_brdn_cost_rate_tab(i) := NULL;
                l_txn_revenue_rate_tab(i) := NULL;
                l_pc_raw_cost_rate_tab(i) := NULL;
                l_pc_brdn_cost_rate_tab(i) := NULL;
                l_pc_revenue_rate_tab(i) := NULL;
            END IF;
        END LOOP;

        /* Bulk insert
           If commitment is not included, record is inserted directly as 'ETC'
           record,if commitment is to be considered, record is inserted as
           'TOTAL_ETC' for further processing.*/
        IF P_FP_COLS_TGT_REC.X_GEN_INCL_OPEN_COMM_FLAG = 'Y' THEN
            l_transaction_source_code := 'TOTAL_ETC';
        ELSE
            l_transaction_source_code := 'ETC';
        END IF;

        FORALL i IN 1..l_etc_quantity_tab.count
            INSERT INTO PA_FP_CALC_AMT_TMP2 (
                RESOURCE_ASSIGNMENT_ID,
                TARGET_RES_ASG_ID,
                ETC_CURRENCY_CODE,
                ETC_PLAN_QUANTITY,
                ETC_TXN_RAW_COST,
                ETC_TXN_BURDENED_COST,
                ETC_TXN_REVENUE,
                ETC_PC_RAW_COST,
                ETC_PC_BURDENED_COST,
                ETC_PC_REVENUE,
                TRANSACTION_SOURCE_CODE )
            VALUES (
                P_SRC_RES_ASG_ID,
                P_TGT_RES_ASG_ID,
                l_tot_currency_code_tab(i),
                l_etc_quantity_tab(i),
                l_etc_quantity_tab(i) * l_txn_raw_cost_rate_tab(i),
                l_etc_quantity_tab(i) * l_txn_brdn_cost_rate_tab(i),
                l_etc_quantity_tab(i) * l_txn_revenue_rate_tab(i),
                l_etc_quantity_tab(i) * l_pc_raw_cost_rate_tab(i),
                l_etc_quantity_tab(i) * l_pc_brdn_cost_rate_tab(i),
                l_etc_quantity_tab(i) * l_pc_revenue_rate_tab(i),
                l_transaction_source_code);

    /***************NOW WE HAVE ALL ETC DATA IN PC_TC*************/

    END IF;
    /* End the check for 'PC', 'TC' and 'PC_TC'*/

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
               (p_msg         => 'Invalid Arguments Passed',
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
        --dbms_output.put_line('error msg :'||x_msg_data);
        FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_GEN_FCST_AMT_PUB3',
                     p_procedure_name  => 'GEN_ETC_REMAIN_BDGT_AMTS',
                     p_error_text      => substr(sqlerrm,1,240));

        IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                p_module_name => l_module_name,
                p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END GET_ETC_REMAIN_BDGT_AMTS;

PROCEDURE CHECK_SINGLE_CURRENCY
          (P_TGT_RES_ASG_ID             IN PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE,
           X_SINGLE_CURRENCY_FLAG       OUT  NOCOPY VARCHAR2,
           X_RETURN_STATUS              OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT                  OUT  NOCOPY NUMBER,
           X_MSG_DATA                   OUT  NOCOPY VARCHAR2)
IS
  l_module_name  VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_FCST_AMT_PUB3.CHECK_SINGLE_CURRENCY';

  l_currency_count_for_flag     VARCHAR2(1);

  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_data                        VARCHAR2(2000);
  l_msg_index_out               NUMBER:=0;
BEGIN

    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function     => 'CHECK_SINGLE_CURRENCY',
                                    p_debug_mode   =>  p_pa_debug_mode);
    END IF;

    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_COUNT := 0;

    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.RESET_CURR_FUNCTION;
    END IF;

    SELECT COUNT(*) INTO l_currency_count_for_flag FROM (
        SELECT /*+ INDEX(tot_tmp,PA_FP_CALC_AMT_TMP2_N1)*/
               DISTINCT txn_currency_code
        FROM PA_FP_CALC_AMT_TMP2
        WHERE target_res_asg_id = p_tgt_res_asg_id
        AND (transaction_source_code = 'FINANCIAL_PLAN'
        OR transaction_source_code = 'WORKPLAN_RESOURCES'
        OR transaction_source_code = 'COMMITMENT')
        UNION
        SELECT /*+ INDEX(tot_tmp,PA_FP_CALC_AMT_TMP2_N1)*/
               DISTINCT act_tmp.txn_currency_code
        FROM PA_FP_FCST_GEN_TMP1 act_tmp,
             PA_FP_CALC_AMT_TMP2 tot_tmp
        WHERE act_tmp.source_id = tot_tmp.resource_assignment_id
        AND tot_tmp.target_res_asg_id = p_tgt_res_asg_id
    ) WHERE rownum <= 2;

    IF l_currency_count_for_flag <= 1 THEN
        X_SINGLE_CURRENCY_FLAG := 'Y';
    ELSE
        X_SINGLE_CURRENCY_FLAG := 'N';
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
               (p_msg         => 'Invalid Arguments Passed',
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
        --dbms_output.put_line('error msg :'||x_msg_data);
        FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_GEN_FCST_AMT_PUB3',
                     p_procedure_name  => 'CHECK_SINGLE_CURRENCY',
                     p_error_text      => substr(sqlerrm,1,240));

        IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                p_module_name => l_module_name,
                p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END CHECK_SINGLE_CURRENCY;


/* Assumption:
   1.Before getting into this procedure, we have called all ETC methods to derive the total
   ETC quantity and populated them in the temporary table PA_FP_CALC_AMT_TMP2 with
   transaction source codes of 'TOTAL_ETC'.
   2.Commitment can only be considered for cost/all version. For revenue forecast version,
   user can't select include commitment option from the UI.
   3.No matter for cost, revenue or all forecast version, always pick up cost/revenue rate
   from the source whenever applicable. */

/* Bug 4369741: Replaced single planning options flag parameter with
 * 2 separate parameters - 1 for Workplan and 1 for Financial Plan. */

PROCEDURE GET_ETC_COMMITMENT_AMTS
          (P_FP_COLS_TGT_REC            IN PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_WP_PLANNING_OPTIONS_FLAG   IN VARCHAR2, /* Added for Bug 4369741 */
           P_FP_PLANNING_OPTIONS_FLAG   IN VARCHAR2, /* Added for Bug 4369741 */
           X_RETURN_STATUS              OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT                  OUT  NOCOPY NUMBER,
           X_MSG_DATA                   OUT  NOCOPY VARCHAR2)
IS
  l_module_name  VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_FCST_AMT_PUB3.GEN_ETC_COMMITMENT_AMTS';

  l_currency_flag               VARCHAR2(30);
  l_rate_based_flag             VARCHAR2(1);
  l_currency_count_for_flag     NUMBER;
  l_prorating_always_flag       VARCHAR2(1);
  l_target_version_type         pa_budget_versions.version_type%type;

  l_source_version_type         pa_budget_versions.version_type%type; /* Added for IPM */
  l_tgt_res_asg_id_tab          PA_PLSQL_DATATYPES.NumTabTyp;
  l_src_res_asg_id_tab          PA_PLSQL_DATATYPES.NumTabTyp;  /* Created for bug fix 4117267*/
  l_cmt_count                   NUMBER;

  /* For PC amounts */
  l_pc_currency_code            pa_projects_all.project_currency_code%type;
  l_cmt_quantity_pc_pfc         NUMBER;
  l_cmt_raw_cost_pc_pfc         NUMBER;
  l_cmt_brdn_cost_pc_pfc        NUMBER;
  l_cmt_revenue_pc_pfc          NUMBER;

  l_etc_quantity_pc_pfc         NUMBER;
  l_etc_noncmt_quantity_pc_pfc  NUMBER;

  /* For PFC amounts */
  l_pfc_currency_code           pa_projects_all.project_currency_code%type;
  l_rev_gen_method              VARCHAR2(3);

  /* For TC amounts */
  l_etc_currency_code_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
  l_etc_quantity_tab            PA_PLSQL_DATATYPES.NumTabTyp;
  l_etc_quantity_sum            NUMBER;

  l_cmt_currency_code_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
  l_cmt_quantity_tab            PA_PLSQL_DATATYPES.NumTabTyp;
  l_cmt_raw_cost_tab            PA_PLSQL_DATATYPES.NumTabTyp;
  l_cmt_brdn_cost_tab           PA_PLSQL_DATATYPES.NumTabTyp;
  l_cmt_quantity_sum            NUMBER;

  l_etc_noncmt_quantity_tab     PA_PLSQL_DATATYPES.NumTabTyp;
  l_etc_noncmt_raw_cost_tab     PA_PLSQL_DATATYPES.NumTabTyp;
  l_etc_noncmt_brdn_cost_tab    PA_PLSQL_DATATYPES.NumTabTyp;
  l_etc_noncmt_quantity_sum     NUMBER;

  /*For PC_TC amounts*/
  l_etc_quantity_pc_tab         PA_PLSQL_DATATYPES.NumTabTyp;
  l_etc_raw_cost_pc_tab         PA_PLSQL_DATATYPES.NumTabTyp;
  l_etc_brdn_cost_pc_tab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_etc_revenue_pc_tab          PA_PLSQL_DATATYPES.NumTabTyp; -- Added for IPM
  l_etc_quantity_pc_sum         NUMBER;

  l_cmt_quantity_pc_tab         PA_PLSQL_DATATYPES.NumTabTyp;
  l_cmt_raw_cost_pc_tab         PA_PLSQL_DATATYPES.NumTabTyp;
  l_cmt_brdn_cost_pc_tab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_cmt_quantity_pc_sum         NUMBER;

  l_etc_noncmt_quantity_pc_tab  PA_PLSQL_DATATYPES.NumTabTyp;
  l_etc_noncmt_raw_cost_pc_tab  PA_PLSQL_DATATYPES.NumTabTyp;
  l_etc_noncmt_brdn_cost_pc_tab PA_PLSQL_DATATYPES.NumTabTyp;
  l_etc_noncmt_quantity_pc_sum  NUMBER;

  /*For average rates*/
  l_pc_pfc_rate_quantity        NUMBER;
  l_pc_pfc_rate_raw_cost        NUMBER;
  l_pc_pfc_rate_brdn_cost       NUMBER;
  l_pc_pfc_rate_revenue         NUMBER;
  l_txn_rate_quantity           NUMBER;
  l_txn_rate_raw_cost           NUMBER;
  l_txn_rate_brdn_cost          NUMBER;
  l_txn_rate_revenue            NUMBER;

  l_pc_pfc_raw_cost_rate        NUMBER;
  l_pc_pfc_brdn_cost_rate       NUMBER;
  l_pc_pfc_revenue_rate         NUMBER;
  l_txn_raw_cost_rate_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  l_txn_brdn_cost_rate_tab      PA_PLSQL_DATATYPES.NumTabTyp;
  l_txn_revenue_rate_tab        PA_PLSQL_DATATYPES.NumTabTyp;

  l_transaction_source_code     VARCHAR2(30);

  /*For txn currency conversion*/
  l_task_id                     pa_tasks.task_id%type;
  l_planning_start_date         pa_resource_assignments.planning_start_date%type;
  lx_acc_rate_date              DATE;
  lx_acct_rate_type             VARCHAR2(50);
  lx_acct_exch_rate             NUMBER;
  lx_acct_raw_cost              NUMBER;
  lx_project_rate_type          VARCHAR2(50);
  lx_project_rate_date          DATE;
  lx_project_exch_rate          NUMBER;
  lx_projfunc_cost_rate_type    VARCHAR2(50);
  lx_projfunc_cost_rate_date    DATE;
  lx_projfunc_cost_exch_rate    NUMBER;
  l_projfunc_raw_cost           NUMBER;

  l_currency_prorate_cmt_flag   VARCHAR2(1);
  l_currency_count_cmt_min_tot  NUMBER;
  l_exit_flag                   VARCHAR2(1);
  l_continue_loop_flag          VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_data                        VARCHAR2(2000);
  l_msg_index_out               NUMBER:=0;

  l_dummy                       NUMBER;

  /* Bug 4369741: Added cursor src_tgt_cur_wp_fp_opt_same to be used in
   * the following scenarios:
   * 1. Target ETC generation source = 'WORKPLAN_RESOURCES'
   *    P_WP_PLANNING_OPTIONS_FLAG = Y
   * 2. Target ETC generation source = 'FINANCIAL_PLAN'
   *    P_FP_PLANNING_OPTIONS_FLAG = Y
   * 3. Target ETC generation source = 'TASK_LEVEL_SEL'
   *    P_WP_PLANNING_OPTIONS_FLAG = Y
   *    P_FP_PLANNING_OPTIONS_FLAG = Y */

  CURSOR src_tgt_cur_wp_fp_opt_same IS
  SELECT DISTINCT target_res_asg_id,
                  resource_assignment_id
  FROM PA_FP_CALC_AMT_TMP2
  WHERE TRANSACTION_SOURCE_CODE = 'TOTAL_ETC';

  /* Bug 4369741: Added cursor src_tgt_cur_wp_fp_opt_diff to be used in
   * the following scenarios:
   * 1. Target ETC generation source = 'WORKPLAN_RESOURCES'
   *    P_WP_PLANNING_OPTIONS_FLAG = N
   * 2. Target ETC generation source = 'FINANCIAL_PLAN'
   *    P_FP_PLANNING_OPTIONS_FLAG = N
   * 3. Target ETC generation source = 'TASK_LEVEL_SEL'
   *    P_WP_PLANNING_OPTIONS_FLAG = N
   *    P_FP_PLANNING_OPTIONS_FLAG = N */

  CURSOR src_tgt_cur_wp_fp_opt_diff IS
  SELECT DISTINCT target_res_asg_id,
                  NULL
  FROM PA_FP_CALC_AMT_TMP2
  WHERE TRANSACTION_SOURCE_CODE = 'TOTAL_ETC';

  /* Bug 4369741: Added cursor src_tgt_cur_wp_opt_same to be used in
   * the following scenarios:
   * 1. Target ETC generation source = 'TASK_LEVEL_SEL'
   *    P_WP_PLANNING_OPTIONS_FLAG = Y
   *    P_FP_PLANNING_OPTIONS_FLAG = N */

  CURSOR src_tgt_cur_wp_opt_same IS
  SELECT /*+ INDEX(tmp,PA_FP_CALC_AMT_TMP1_N1)*/
	 DISTINCT tmp.target_res_asg_id tgt_res_asg_id,
                  tmp.resource_assignment_id src_res_asg_id
  FROM PA_FP_CALC_AMT_TMP1 tmp_ra,
       PA_FP_CALC_AMT_TMP2 tmp
  WHERE tmp.TRANSACTION_SOURCE_CODE = 'TOTAL_ETC'
  AND   tmp_ra.target_res_asg_id = tmp.target_res_asg_id
  AND   tmp_ra.transaction_source_code = 'WORKPLAN_RESOURCES'
  UNION ALL
  SELECT /*+ INDEX(tmp,PA_FP_CALC_AMT_TMP1_N1)*/
	 DISTINCT tmp.target_res_asg_id tgt_res_asg_id,
                  NULL src_res_asg_id
  FROM PA_FP_CALC_AMT_TMP1 tmp_ra,
       PA_FP_CALC_AMT_TMP2 tmp
  WHERE tmp.TRANSACTION_SOURCE_CODE = 'TOTAL_ETC'
  AND   tmp_ra.target_res_asg_id = tmp.target_res_asg_id
  AND   tmp_ra.transaction_source_code = 'FINANCIAL_PLAN';

  /* Bug 4369741: Added cursor src_tgt_cur_fp_opt_same to be used in
   * the following scenarios:
   * 1. Target ETC generation source = 'TASK_LEVEL_SEL'
   *    P_WP_PLANNING_OPTIONS_FLAG = N
   *    P_FP_PLANNING_OPTIONS_FLAG = Y */

  CURSOR src_tgt_cur_fp_opt_same IS
  SELECT /*+ INDEX(tmp,PA_FP_CALC_AMT_TMP1_N1)*/
	 DISTINCT tmp.target_res_asg_id tgt_res_asg_id,
                  tmp.resource_assignment_id src_res_asg_id
  FROM PA_FP_CALC_AMT_TMP1 tmp_ra,
       PA_FP_CALC_AMT_TMP2 tmp
  WHERE tmp.TRANSACTION_SOURCE_CODE = 'TOTAL_ETC'
  AND   tmp_ra.target_res_asg_id = tmp.target_res_asg_id
  AND   tmp_ra.transaction_source_code = 'FINANCIAL_PLAN'
  UNION ALL
  SELECT /*+ INDEX(tmp,PA_FP_CALC_AMT_TMP1_N1)*/
	 DISTINCT tmp.target_res_asg_id tgt_res_asg_id,
                  NULL src_res_asg_id
  FROM PA_FP_CALC_AMT_TMP1 tmp_ra,
       PA_FP_CALC_AMT_TMP2 tmp
  WHERE tmp.TRANSACTION_SOURCE_CODE = 'TOTAL_ETC'
  AND   tmp_ra.target_res_asg_id = tmp.target_res_asg_id
  AND   tmp_ra.transaction_source_code = 'WORKPLAN_RESOURCES';

  -- Variables added for Bug 5203622
  l_other_rej_code              PA_BUDGET_LINES.OTHER_REJECTION_CODE%TYPE;
  l_other_rej_code_tab          PA_PLSQL_DATATYPES.Char30TabTyp;

BEGIN
    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function     => 'GET_ETC_COMMITMENT_AMTS',
                                    p_debug_mode   =>  p_pa_debug_mode);
    END IF;

    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_COUNT := 0;

    /* Map the total ETC data from source resource assignments to
       target resource assignments */
    /* Bug:4155153
       IF P_PLANNING_OPTIONS_FLAG is Y, source res asg and target res asg are
       one to one; if FLAG is N, source res asg and target res asg might be
       many to one, so set l_src_res_asg_id_tab values to null. This src res
       asg id will only be used to get the source version rate when planning
       options are same.*/

    /* Bug 4369741: Before, we fetched source/target resource assignment ids
     * based on a single planning options flag. Now, we need to check a flag
     * for each source. When the ETC generation source is Workplan, check
     * P_WP_PLANNING_OPTIONS_FLAG. When the ETC generation source is Financial
     * Plan, check P_FP_PLANNING_OPTIONS_FLAG. When the ETC generation source
     * is Task Level Selection, check both P_WP_PLANNING_OPTIONS_FLAG
     * and P_FP_PLANNING_OPTIONS_FLAG. */

    IF P_FP_COLS_TGT_REC.x_gen_etc_src_code = 'FINANCIAL_PLAN' THEN
        IF P_FP_PLANNING_OPTIONS_FLAG = 'Y' THEN
	    OPEN  src_tgt_cur_wp_fp_opt_same;
	    FETCH src_tgt_cur_wp_fp_opt_same
	    BULK COLLECT
	    INTO  l_tgt_res_asg_id_tab ,
	          l_src_res_asg_id_tab;
	    CLOSE src_tgt_cur_wp_fp_opt_same;
        ELSIF P_FP_PLANNING_OPTIONS_FLAG = 'N' THEN
	    OPEN  src_tgt_cur_wp_fp_opt_diff;
	    FETCH src_tgt_cur_wp_fp_opt_diff
	    BULK COLLECT
	    INTO  l_tgt_res_asg_id_tab ,
	          l_src_res_asg_id_tab;
	    CLOSE src_tgt_cur_wp_fp_opt_diff;
        ELSE
            -- error handling code stub
            l_dummy := 1;
        END IF;
    ELSIF P_FP_COLS_TGT_REC.x_gen_etc_src_code = 'WORKPLAN_RESOURCES' THEN
        IF P_WP_PLANNING_OPTIONS_FLAG = 'Y' THEN
	    OPEN  src_tgt_cur_wp_fp_opt_same;
	    FETCH src_tgt_cur_wp_fp_opt_same
	    BULK COLLECT
	    INTO  l_tgt_res_asg_id_tab ,
	          l_src_res_asg_id_tab;
	    CLOSE src_tgt_cur_wp_fp_opt_same;
        ELSIF P_WP_PLANNING_OPTIONS_FLAG = 'N' THEN
	    OPEN  src_tgt_cur_wp_fp_opt_diff;
	    FETCH src_tgt_cur_wp_fp_opt_diff
	    BULK COLLECT
	    INTO  l_tgt_res_asg_id_tab ,
	          l_src_res_asg_id_tab;
	    CLOSE src_tgt_cur_wp_fp_opt_diff;
        ELSE
            -- error handling code stub
            l_dummy := 1;
        END IF;
    ELSIF P_FP_COLS_TGT_REC.x_gen_etc_src_code = 'TASK_LEVEL_SEL' THEN
	IF P_WP_PLANNING_OPTIONS_FLAG = 'Y' AND
	   P_FP_PLANNING_OPTIONS_FLAG = 'Y' THEN
	    OPEN  src_tgt_cur_wp_fp_opt_same;
	    FETCH src_tgt_cur_wp_fp_opt_same
	    BULK COLLECT
	    INTO  l_tgt_res_asg_id_tab ,
	          l_src_res_asg_id_tab;
	    CLOSE src_tgt_cur_wp_fp_opt_same;
        ELSIF P_WP_PLANNING_OPTIONS_FLAG = 'Y' AND
              P_FP_PLANNING_OPTIONS_FLAG = 'N' THEN
            OPEN  src_tgt_cur_wp_opt_same;
            FETCH src_tgt_cur_wp_opt_same
            BULK COLLECT
            INTO  l_tgt_res_asg_id_tab ,
                  l_src_res_asg_id_tab;
            CLOSE src_tgt_cur_wp_opt_same;
        ELSIF P_WP_PLANNING_OPTIONS_FLAG = 'N' AND
   	      P_FP_PLANNING_OPTIONS_FLAG = 'Y' THEN
	    OPEN  src_tgt_cur_fp_opt_same;
	    FETCH src_tgt_cur_fp_opt_same
	    BULK COLLECT
	    INTO  l_tgt_res_asg_id_tab ,
	          l_src_res_asg_id_tab;
	    CLOSE src_tgt_cur_fp_opt_same;
	ELSIF P_WP_PLANNING_OPTIONS_FLAG = 'N' AND
	      P_FP_PLANNING_OPTIONS_FLAG = 'N' THEN
	    OPEN  src_tgt_cur_wp_fp_opt_diff;
	    FETCH src_tgt_cur_wp_fp_opt_diff
	    BULK COLLECT
	    INTO  l_tgt_res_asg_id_tab ,
	          l_src_res_asg_id_tab;
	    CLOSE src_tgt_cur_wp_fp_opt_diff;
        ELSE
            -- error handling code stub
            l_dummy := 1;
        END IF;
    ELSE
        -- error handling code stub
        l_dummy := 1;
    END IF; -- fetch source/target resource assignment ids

   --hr_utility.trace('l_src_res_asg_id_tab TMP2 data : '||l_src_res_asg_id_tab(1));
   --hr_utility.trace('l_tgt_res_asg_id_tab TMP2 data : '||l_tgt_res_asg_id_tab(1));
    l_target_version_type := p_fp_cols_tgt_rec.x_version_type;
    l_pc_currency_code := p_fp_cols_tgt_rec.x_project_currency_code;
    l_pfc_currency_code := p_fp_cols_tgt_rec.x_projfunc_currency_code;
    /* Get commitment amounts for each target resource assignment */

    FOR i IN 1..l_tgt_res_asg_id_tab.count LOOP
    -- Bug 4110695: Added wrapper loop for body of main loop so that we can use the
    -- pl/sql EXIT command to skip to the next iteration of the main loop to avoid
    -- further processing. This was done to replace RETURN with EXIT.
    FOR wrapper_loop_iterator IN 1..1 LOOP

      SELECT /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N1)*/ COUNT(*)
      INTO l_cmt_count
      FROM PA_FP_CALC_AMT_TMP2
      WHERE target_res_asg_id = l_tgt_res_asg_id_tab(i)
      AND transaction_source_code = 'OPEN_COMMITMENTS'
      AND rownum = 1;

      /* If no commitment available for the current target resource assignment,
         simply update the temp table from total_etc records to net etc records. */
      IF l_cmt_count = 0 THEN
        UPDATE /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N1)*/ PA_FP_CALC_AMT_TMP2
        SET transaction_source_code = 'ETC'
        WHERE target_res_asg_id = l_tgt_res_asg_id_tab(i)
        AND transaction_source_code = 'TOTAL_ETC';
      ELSE
        l_etc_currency_code_tab.delete;
        l_etc_quantity_tab.delete;

        l_cmt_currency_code_tab.delete;
        l_cmt_quantity_tab.delete;
        l_cmt_raw_cost_tab.delete;
        l_cmt_brdn_cost_tab.delete;

        l_etc_noncmt_quantity_tab.delete;
        l_etc_noncmt_raw_cost_tab.delete;
        l_etc_noncmt_brdn_cost_tab.delete;

        l_etc_quantity_pc_tab.delete;
        l_etc_raw_cost_pc_tab.delete;
        l_etc_brdn_cost_pc_tab.delete;

        l_cmt_quantity_pc_tab.delete;
        l_cmt_raw_cost_pc_tab.delete;
        l_cmt_brdn_cost_pc_tab.delete;

        l_etc_noncmt_quantity_pc_tab.delete;
        l_etc_noncmt_raw_cost_pc_tab.delete;
        l_etc_noncmt_brdn_cost_pc_tab.delete;

        l_txn_raw_cost_rate_tab.delete;
        l_txn_brdn_cost_rate_tab.delete;

        l_exit_flag := 'N';
        l_continue_loop_flag := 'N';
        /* Default to use Transaction Currency (TC)
           If target version is not multi currency enabled, take Project Currency (PC)
           If target version is multi currency enabled, the target planning resource is
           non rate based, and commitments currencies are not subset of the total ETC
           currencies. We need to take PC amounts as quantity, sum up total ETC quantity
           minus commitment quantity, prorate this total PC ETC quantity across the total
           ETC currencies. Then convert them back from PC to TC. (PC_TC)*/

        IF nvl(l_tgt_res_asg_id_tab(i),0)  > 0 THEN
            SELECT rate_based_flag
            INTO l_rate_based_flag
            FROM pa_resource_assignments
            WHERE resource_assignment_id = l_tgt_res_asg_id_tab(i);
        ELSE
            l_rate_based_flag:='N';
        END IF;

        l_currency_flag := 'TC';

        l_rev_gen_method := nvl(P_FP_COLS_TGT_REC.x_revenue_derivation_method,PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(P_FP_COLS_TGT_REC.x_project_id)); -- Bug 5462471
        --l_rev_gen_method := PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(P_FP_COLS_TGT_REC.x_project_id);

        IF (p_fp_cols_tgt_rec.x_version_type = 'REVENUE' and l_rev_gen_method = 'C') THEN
            l_currency_flag := 'PFC';
        ELSIF p_fp_cols_tgt_rec.X_PLAN_IN_MULTI_CURR_FLAG = 'N' THEN
            l_currency_flag := 'PC';
        ELSIF l_rate_based_flag = 'N' THEN
            SELECT /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N1)*/
                   COUNT(*) INTO l_currency_count_for_flag FROM (
                SELECT DISTINCT txn_currency_code
                FROM PA_FP_CALC_AMT_TMP2
                WHERE target_res_asg_id = l_tgt_res_asg_id_tab(i)
                AND transaction_source_code = 'OPEN_COMMITMENTS'
                MINUS
                SELECT /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N1)*/
                       DISTINCT etc_currency_code
                FROM PA_FP_CALC_AMT_TMP2
                WHERE target_res_asg_id = l_tgt_res_asg_id_tab(i)
                AND transaction_source_code = 'TOTAL_ETC'
            ) WHERE rownum = 1;
            IF l_currency_count_for_flag > 0 THEN
                l_currency_flag := 'PC_TC';
            END IF;
        END IF;

        /***********BY THIS TIME, WE DECIDED TO USE EITHER PC, TC or PC_PC*********/

        IF l_currency_flag = 'PC' or l_currency_flag = 'PFC' THEN
            /* Get total etc amounts in PC for each target resource assignment */
            SELECT /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N1)*/
                   NVL(SUM(ETC_PLAN_QUANTITY),0)
            INTO  l_etc_quantity_pc_pfc
            FROM PA_FP_CALC_AMT_TMP2
            WHERE target_res_asg_id = l_tgt_res_asg_id_tab(i)
            AND TRANSACTION_SOURCE_CODE = 'TOTAL_ETC';

            /* Get commitment amounts in PC for currency target resource assignment */
            SELECT  /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N1)*/
                    NVL(SUM(NVL(total_plan_quantity,0)),0),
                    DECODE(l_currency_flag,
                        'PC', NVL(SUM(NVL(total_pc_raw_cost,0)),0),
                        'PFC', NVL(SUM(NVL(total_pfc_raw_cost,0)),0)),
                    DECODE(l_currency_flag,
                        'PC', NVL(SUM(NVL(total_pc_burdened_cost,0)),0),
                        'PFC', NVL(SUM(NVL(total_pfc_burdened_cost,0)),0))
            INTO    l_cmt_quantity_pc_pfc,
                    l_cmt_raw_cost_pc_pfc,
                    l_cmt_brdn_cost_pc_pfc
            FROM PA_FP_CALC_AMT_TMP2
            WHERE target_res_asg_id = l_tgt_res_asg_id_tab(i)
            AND transaction_source_code = 'OPEN_COMMITMENTS';


            IF l_rate_based_flag = 'N' THEN
                l_cmt_quantity_pc_pfc := l_cmt_raw_cost_pc_pfc;
            END IF;

            /* Get total non-commitment ETC quantity */
            l_etc_noncmt_quantity_pc_pfc := l_etc_quantity_pc_pfc - l_cmt_quantity_pc_pfc;
            -- ER 5726773: Instead of directly checking if (ETC <= 0), let the
	    -- plan_etc_signs_match function decide if ETC should be generated.
	    IF NOT pa_fp_fcst_gen_amt_utils.PLAN_ETC_SIGNS_MATCH
 	                  (l_etc_quantity_pc_pfc, l_etc_noncmt_quantity_pc_pfc) THEN
 	        /* Only need to spread commitment data and actual data */
                /* We need to exit current loop, and continue with the next loop */
                l_continue_loop_flag := 'Y';
            END IF;

            IF l_continue_loop_flag <> 'Y' THEN

                -- Bug 4309993: Replaced total_plan_quantity with etc_plan_quantity
                -- in the below query to fetch the correct rate quantity.

                /*When not taking periodic rates, we need to calculate out the average
                  rates from the source resource assignments that are mapped to the
                  current target resource assignment.*/
                SELECT  /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N1)*/
                        NVL(SUM(NVL(etc_plan_quantity,0)),0),
                        NVL(SUM(DECODE(l_currency_flag,
                                'PC', NVL(etc_pc_raw_cost,0),
                                'PFC', NVL(etc_pfc_raw_cost,0))),0),
                        NVL(SUM(DECODE(l_currency_flag,
                                'PC', NVL(etc_pc_burdened_cost,0),
                                'PFC', NVL(etc_pfc_burdened_cost,0))),0),
                        NVL(SUM(DECODE(l_currency_flag,
                                'PC', NVL(etc_pc_revenue,0),
                                'PFC', NVL(etc_pfc_revenue,0))),0)
                INTO    l_pc_pfc_rate_quantity,
                        l_pc_pfc_rate_raw_cost,
                        l_pc_pfc_rate_brdn_cost,
                        l_pc_pfc_rate_revenue
                FROM pa_fp_calc_amt_tmp2
                WHERE target_res_asg_id = l_tgt_res_asg_id_tab(i)
                  AND transaction_source_code  = 'TOTAL_ETC';

                -- IPM Change:
                -- For non-rate-based target transactions,
                --   set rate quantity to rate raw cost if it exists, OR
                --   set rate quantity to rate revenue otherwise.
                -- This is done to handle source planning transactions that
                -- have only revenue amounts (without cost amounts).
                --
                -- Note that source version type is not available in the
                -- context of this API. However, the logic should still be ok.

                IF l_rate_based_flag = 'N' THEN
                    IF nvl(l_pc_pfc_rate_raw_cost,0) = 0 THEN
                        l_pc_pfc_rate_quantity := l_pc_pfc_rate_revenue;
                    ELSE
                        l_pc_pfc_rate_quantity := l_pc_pfc_rate_raw_cost;
                    END IF;
                END IF;

                -- Bug 5203622: Added OTHER REJECTION CODE logic.
                l_other_rej_code := null;
                IF l_rate_based_flag = 'N' AND
                   l_target_version_type = 'ALL' AND
                   nvl(l_pc_pfc_rate_raw_cost,0) = 0 AND
                   nvl(l_pc_pfc_rate_revenue,0) <> 0 THEN
                    l_other_rej_code := 'PA_FP_ETC_REV_FIELD_ERR';
                END IF;

                IF l_pc_pfc_rate_quantity <> 0 THEN
                    l_pc_pfc_raw_cost_rate := l_pc_pfc_rate_raw_cost / l_pc_pfc_rate_quantity;
                    l_pc_pfc_brdn_cost_rate := l_pc_pfc_rate_brdn_cost / l_pc_pfc_rate_quantity;
                    l_pc_pfc_revenue_rate := l_pc_pfc_rate_revenue / l_pc_pfc_rate_quantity;
                ELSE
                    l_pc_pfc_raw_cost_rate := NULL;
                    l_pc_pfc_brdn_cost_rate := NULL;
                    l_pc_pfc_revenue_rate := NULL;
                END IF;

                -- Bug 5203622: Store OTHER rejection code in the
                -- txn_currency_code column of pa_fp_calc_amt_tmp2.
                /* Insert the single PC record for total ETC with source rates */
                INSERT INTO PA_FP_CALC_AMT_TMP2 (
                    TARGET_RES_ASG_ID,
                    ETC_CURRENCY_CODE,
                    ETC_PLAN_QUANTITY,
                    ETC_TXN_RAW_COST,
                    ETC_TXN_BURDENED_COST,
                    ETC_TXN_REVENUE,
                    TRANSACTION_SOURCE_CODE,
                    TXN_CURRENCY_CODE, -- Added for Bug 5203622
                    RESOURCE_ASSIGNMENT_ID) -- added for bug 5359863
                VALUES (
                    l_tgt_res_asg_id_tab(i),
                    DECODE(l_currency_flag, 'PC',l_pc_currency_code,
                                            'PFC', l_pfc_currency_code),
                    l_etc_noncmt_quantity_pc_pfc,
                    l_etc_noncmt_quantity_pc_pfc * l_pc_pfc_raw_cost_rate,
                    l_etc_noncmt_quantity_pc_pfc * l_pc_pfc_brdn_cost_rate,
                    l_etc_noncmt_quantity_pc_pfc * l_pc_pfc_revenue_rate,
                    'ETC',
                    l_other_rej_code,  -- Added for Bug 5203622
                    l_src_res_asg_id_tab(i)); -- added for bug 5359863
            END IF;
            /**************BY THIS TIME, WE HAVE ALL ETC DATA FOR PC or PFC*********/

        ELSIF l_currency_flag = 'TC' THEN
            /* Get total etc amounts for multiple currencies */
            SELECT  /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N1)*/
                    etc_currency_code,
                    SUM(NVL(ETC_PLAN_QUANTITY,0))
            BULK COLLECT INTO
                    l_etc_currency_code_tab,
                    l_etc_quantity_tab
            FROM    PA_FP_CALC_AMT_TMP2
            WHERE   target_res_asg_id = l_tgt_res_asg_id_tab(i)
            AND     TRANSACTION_SOURCE_CODE = 'TOTAL_ETC'
            GROUP BY etc_currency_code;

            /* Get total non-commitment ETC quantity */
            /* Bug 4085203
               The total ETC amounts should be summed up irrespective of rate based
               or non rate based. Because for non rate based resource, we used the
               sum value when ETC and commitment are using same one currency. When
               ETC and commitment are using more than one currencies, the flow will
               not use the sum amounts.*/
            l_etc_quantity_sum := 0;
            FOR k IN 1..l_etc_quantity_tab.count LOOP
                l_etc_quantity_sum := l_etc_quantity_sum + l_etc_quantity_tab(k);
            END LOOP;

            /* Get commitment amounts for multiple currencies */
            SELECT  /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N1)*/
                    txn_currency_code,
                    SUM(NVL(total_plan_quantity,0)),
                    SUM(NVL(total_txn_raw_cost,0)),
                    SUM(NVL(total_txn_burdened_cost,0))
            BULK COLLECT INTO
                    l_cmt_currency_code_tab,
                    l_cmt_quantity_tab,
                    l_cmt_raw_cost_tab,
                    l_cmt_brdn_cost_tab
            FROM PA_FP_CALC_AMT_TMP2
            WHERE target_res_asg_id = l_tgt_res_asg_id_tab(i)
            AND transaction_source_code = 'OPEN_COMMITMENTS'
            GROUP BY txn_currency_code;

            IF l_rate_based_flag = 'N' THEN
                l_cmt_quantity_tab := l_cmt_raw_cost_tab;
            END IF;

            /* Bug 4085203
               The total commitment amounts should be summed up irrespective of rate based
               or non rate based. Because for non rate based resource, we used the
               sum value when ETC and commitment are using same one currency. When
               ETC and commitment are using more than one currencies, the flow will
               not use the sum amounts.*/
            l_cmt_quantity_sum := 0;
            FOR k IN 1..l_cmt_quantity_tab.count LOOP
                l_cmt_quantity_sum := l_cmt_quantity_sum + l_cmt_quantity_tab(k);
            END LOOP;

            /* Check the relationship between total ETC currency codes and commitment
               currency codes. If commitment currency codes are subset of total ETC
               currency codes, then, take currency based approach; otherwise, take
               prorating based approach.
               'C' means take currency based calculation
               'P' means take prorating based calculation */
            SELECT COUNT (*) INTO l_currency_count_cmt_min_tot
            FROM (
                SELECT /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N1)*/
                       DISTINCT txn_currency_code
                FROM PA_FP_CALC_AMT_TMP2
                WHERE target_res_asg_id = l_tgt_res_asg_id_tab(i)
                AND transaction_source_code = 'OPEN_COMMITMENTS'
                MINUS
                SELECT /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N1)*/
                       DISTINCT etc_currency_code
                FROM PA_FP_CALC_AMT_TMP2
                WHERE target_res_asg_id = l_tgt_res_asg_id_tab(i)
                AND transaction_source_code = 'TOTAL_ETC'
            );

            IF l_currency_count_cmt_min_tot = 0 THEN
                l_currency_prorate_cmt_flag := 'C';
            ELSE
                l_currency_prorate_cmt_flag := 'P';
            END IF;

             /*Bug fix: 4085203: If there only exists one etc currency,
              one commitment currency and they are same, no matter it's rate
              based resource or non rate based resource, if non_cmt_etc quantity is
              calculated as less or equal to zero, then don't generate the non_cmt_ETC.*/
            -- Bug 4110695: Replaced the RETURN statement with EXIT so that processing
            -- can continue for remaining planning resources. Surrounded body of main loop
            -- with a wrapper loop so that EXIT effectively skips this iteration.
            IF  l_etc_currency_code_tab.count = 1 AND l_cmt_currency_code_tab.count = 1 THEN
                l_etc_noncmt_quantity_sum := l_etc_quantity_sum - l_cmt_quantity_sum;
                -- ER 5726773: Instead of directly checking if (ETC <= 0), let the
 	        -- plan_etc_signs_match function decide if ETC should be generated.
 	        IF NOT pa_fp_fcst_gen_amt_utils.PLAN_ETC_SIGNS_MATCH
 	                      (l_etc_quantity_sum, l_etc_noncmt_quantity_sum) THEN
                    EXIT;
                ELSE
                    l_etc_noncmt_quantity_tab(1) := l_etc_noncmt_quantity_sum;
                END IF;
            ELSE
                IF l_currency_prorate_cmt_flag = 'C' THEN
                    FOR m IN 1..l_etc_currency_code_tab.count LOOP
                        IF l_exit_flag = 'Y' THEN
                            EXIT;
                        END IF;
                        l_etc_noncmt_quantity_tab(m) := l_etc_quantity_tab(m);
                        FOR n IN 1..l_cmt_currency_code_tab.count LOOP
                            IF l_etc_currency_code_tab(m) = l_cmt_currency_code_tab(n) THEN
                                l_etc_noncmt_quantity_tab(m) := l_etc_noncmt_quantity_tab(m)
                                                            - l_cmt_quantity_tab(n);
                                -- ER 5726773: Instead of directly checking if (ETC <= 0), let the
 	                        -- plan_etc_signs_match function decide if ETC should be generated.
 	                        IF NOT pa_fp_fcst_gen_amt_utils.PLAN_ETC_SIGNS_MATCH
 	                                      (l_etc_quantity_tab(m), l_etc_noncmt_quantity_tab(m)) THEN
                                    l_currency_prorate_cmt_flag := 'P';
                                    l_etc_noncmt_quantity_tab.delete;
                                    l_exit_flag := 'Y';
                                    EXIT;
                                END IF;
                            END IF;
                        END LOOP;
                    END LOOP;
                END IF;

                IF l_currency_prorate_cmt_flag = 'P' THEN
                    IF l_rate_based_flag = 'N' THEN
                        l_currency_flag := 'PC_TC';
                    ELSIF l_rate_based_flag = 'Y' THEN
                        l_etc_noncmt_quantity_sum := l_etc_quantity_sum - l_cmt_quantity_sum;
                        -- ER 5726773: Instead of directly checking if (ETC <= 0), let the
			-- plan_etc_signs_match function decide if ETC should be generated.
			IF NOT pa_fp_fcst_gen_amt_utils.PLAN_ETC_SIGNS_MATCH
 	                              (l_etc_quantity_sum, l_etc_noncmt_quantity_sum) THEN
 	                    /* no non-commitment ETC available, only actual quantity and commitment
                               quantity need to be spreaded */
                            /* We need to exit current loop, and continue with the next loop */
                            l_continue_loop_flag := 'Y';
                        ELSE
                            /* Prorate ETC quantity */
                            FOR m IN 1..l_etc_currency_code_tab.count LOOP
                                IF l_etc_quantity_sum <> 0 THEN
                                    l_etc_noncmt_quantity_tab(m) := l_etc_noncmt_quantity_sum
                                                   * (l_etc_quantity_tab (m) / l_etc_quantity_sum) ;
                                ELSE
                                    l_etc_noncmt_quantity_tab(m) := NULL;
                                END IF;
                            END LOOP;
                        END IF;
                    END IF;
                END IF;
            END IF;

            /*currency_flag may get changed to 'PC_TC', when actual currencies is subset of
              planning currencies, target resource is non_rate_based, but actual amount for
              one particular currency is less than plan amount. Then we need to revert from
              currency based approach to prorating based approach.For non_rate_based resource,
              prorating falls in to currency code of 'PC_TC'.*/
            IF l_continue_loop_flag <> 'Y' AND l_currency_flag <> 'PC_TC' THEN
                /*When not taking periodic rates, we need to calculate out the average rates
                  from the source resource assignments that are mapped to the current target
                  resource assignment.*/
                FOR k IN 1..l_etc_currency_code_tab.count LOOP
                    SELECT  /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N1)*/
                            NVL(SUM(NVL(etc_plan_quantity,0)),0),
                            NVL(SUM(NVL(etc_txn_raw_cost,0)),0),
                            NVL(SUM(NVL(etc_txn_burdened_cost,0)),0),
                            NVL(SUM(NVL(etc_txn_revenue,0)),0)
                    INTO    l_txn_rate_quantity,
                            l_txn_rate_raw_cost,
                            l_txn_rate_brdn_cost,
                            l_txn_rate_revenue
                    FROM pa_fp_calc_amt_tmp2
                    WHERE target_res_asg_id = l_tgt_res_asg_id_tab(i)
                    AND etc_currency_code = l_etc_currency_code_tab(k)
                    AND transaction_source_code = 'TOTAL_ETC';


                    -- IPM Change:
                    -- For non-rate-based target transactions,
                    --   set rate quantity to rate raw cost if it exists, OR
                    --   set rate quantity to rate revenue otherwise.
                    -- This is done to handle source planning transactions that
                    -- have only revenue amounts (without cost amounts).
                    --
                    -- Note that source version type is not available in the
                    -- context of this API. However, the logic should still be ok.

                    IF l_rate_based_flag = 'N' THEN
                        IF nvl(l_txn_rate_raw_cost,0) = 0 THEN
                            l_txn_rate_quantity := l_txn_rate_revenue;
                        ELSE
                            l_txn_rate_quantity := l_txn_rate_raw_cost;
                        END IF;
                    END IF;

                    -- Bug 5203622: Added OTHER REJECTION CODE logic.
                    l_other_rej_code_tab(k) := null;
                    IF l_rate_based_flag = 'N' AND
                       l_target_version_type = 'ALL' AND
                       nvl(l_txn_rate_raw_cost,0) = 0 AND
                       nvl(l_txn_rate_revenue,0) <> 0 THEN
                        l_other_rej_code_tab(k) := 'PA_FP_ETC_REV_FIELD_ERR';
                    END IF;

                    IF l_txn_rate_quantity <> 0 THEN
                        l_txn_raw_cost_rate_tab(k) := l_txn_rate_raw_cost
                                                / l_txn_rate_quantity;
                        l_txn_brdn_cost_rate_tab(k) := l_txn_rate_brdn_cost
                                                / l_txn_rate_quantity;
                        l_txn_revenue_rate_tab(k) := l_txn_rate_revenue
                                                / l_txn_rate_quantity;
                    ELSE
                        l_txn_raw_cost_rate_tab(k) := NULL;
                        l_txn_brdn_cost_rate_tab(k) := NULL;
                        l_txn_revenue_rate_tab(k) := NULL;
                    END IF;
                END LOOP;

                -- Bug 5203622: Store OTHER rejection code in the
                -- txn_currency_code column of pa_fp_calc_amt_tmp2.
                /* Bulk insert for the ETC amounts for current target resource
                   assignment with source rates */
                FORALL k IN 1..l_etc_currency_code_tab.count
                    INSERT INTO PA_FP_CALC_AMT_TMP2 (
                        TARGET_RES_ASG_ID,
                        ETC_CURRENCY_CODE,
                        ETC_PLAN_QUANTITY,
                        ETC_TXN_RAW_COST,
                        ETC_TXN_BURDENED_COST,
                        ETC_TXN_REVENUE,
                        TRANSACTION_SOURCE_CODE,
                        RESOURCE_ASSIGNMENT_ID,
                        TXN_CURRENCY_CODE ) -- Added for Bug 5203622
                    VALUES (
                        l_tgt_res_asg_id_tab(i),
                        l_etc_currency_code_tab(k),
                        l_etc_noncmt_quantity_tab(k),
                        l_etc_noncmt_quantity_tab(k) * l_txn_raw_cost_rate_tab(k),
                        l_etc_noncmt_quantity_tab(k) * l_txn_brdn_cost_rate_tab(k),
                        l_etc_noncmt_quantity_tab(k) * l_txn_revenue_rate_tab(k),
                        'ETC',
                        l_src_res_asg_id_tab(i),
                        l_other_rej_code_tab(k) ); -- Added for Bug 5203622
            END IF;
        END IF;
            /**************BY THIS TIME, WE HAVE NON_CMT ETC DATA FOR TC*********/

        IF l_currency_flag = 'PC_TC' THEN

            /*Take PC for calculation, then convert back to TC */
            /*No matter ETC source is 'FINANCIAL_PLAN' or 'WORKPLAN_RESOURCES',
              always get total plan amounts in PC from financial data model.*/
            l_pc_currency_code := p_fp_cols_tgt_rec.x_project_currency_code;
            SELECT  /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N1)*/
                    etc_currency_code,
                    SUM(NVL(etc_plan_quantity,0)),
                    SUM(NVL(etc_pc_raw_cost,0)),
                    SUM(NVL(etc_pc_burdened_cost,0)),
                    SUM(NVL(etc_pc_revenue,0)) -- Added in IPM
            BULK COLLECT INTO
                    l_etc_currency_code_tab,
                    l_etc_quantity_pc_tab,
                    l_etc_raw_cost_pc_tab,
                    l_etc_brdn_cost_pc_tab,
                    l_etc_revenue_pc_tab -- Added in IPM
            FROM PA_FP_CALC_AMT_TMP2
            WHERE target_res_asg_id = l_tgt_res_asg_id_tab(i)
            AND transaction_source_code = 'TOTAL_ETC'
            GROUP BY etc_currency_code;

            -- IPM Change:
            -- For non-rate-based target transactions,
            --   set target quantity to source raw cost if it exists, OR
            --   set target quantity to source revenue otherwise.
            -- This is done to handle source planning transactions that
            -- have only revenue amounts (without cost amounts).
            --
            -- Note that source version type is not available in the
            -- context of this API. However, the logic should still be ok.

            FOR k IN 1..l_etc_quantity_pc_tab.count LOOP
                IF nvl(l_etc_raw_cost_pc_tab(k),0) = 0 THEN
                    l_etc_quantity_pc_tab(k) := l_etc_revenue_pc_tab(k);
                ELSE
                    l_etc_quantity_pc_tab(k) := l_etc_raw_cost_pc_tab(k);
                END IF;
            END LOOP;

            l_etc_quantity_pc_sum := 0;
            FOR k IN 1..l_etc_quantity_pc_tab.count LOOP
                l_etc_quantity_pc_sum := l_etc_quantity_pc_sum + l_etc_quantity_pc_tab(k);
            END LOOP;

            /*Get the commitment amounts for the target planning resource in PC.*/
            SELECT  /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N1)*/
                    txn_currency_code,
                    SUM(NVL(total_plan_quantity,0)),
                    SUM(NVL(total_pc_raw_cost,0)),
                    SUM(NVL(total_pc_burdened_cost,0))
            BULK COLLECT INTO
                    l_cmt_currency_code_tab,
                    l_cmt_quantity_pc_tab,
                    l_cmt_raw_cost_pc_tab,
                    l_cmt_brdn_cost_pc_tab
            FROM PA_FP_CALC_AMT_TMP2
            WHERE target_res_asg_id = l_tgt_res_asg_id_tab(i)
            AND transaction_source_code = 'OPEN_COMMITMENTS'
            GROUP BY txn_currency_code;

            l_cmt_quantity_pc_tab := l_cmt_raw_cost_pc_tab;

            l_cmt_quantity_pc_sum := 0;
            FOR k IN 1..l_cmt_quantity_pc_tab.count LOOP
                l_cmt_quantity_pc_sum := l_cmt_quantity_pc_sum + l_cmt_quantity_pc_tab(k);
            END LOOP;

            /* Get total ETC quantity in PC */
            l_etc_noncmt_quantity_pc_sum := l_etc_quantity_pc_sum- l_cmt_quantity_pc_sum;

            -- ER 5726773: Instead of directly checking if (ETC <= 0), let the
	    -- plan_etc_signs_match function decide if ETC should be generated.
	    IF NOT pa_fp_fcst_gen_amt_utils.PLAN_ETC_SIGNS_MATCH
 	                  (l_etc_quantity_pc_sum, l_etc_noncmt_quantity_pc_sum) THEN
 	    /* only need to spread commitment data and actual data */
                l_continue_loop_flag := 'Y';
            END IF;

            IF l_continue_loop_flag <> 'Y' THEN
                /*Prorate total non-commitment ETC quantity in PC according to the transaction
                  currency codes from the total ETC.*/
                FOR k IN 1..l_etc_quantity_pc_tab.count LOOP
                    IF l_etc_quantity_pc_sum <> 0 THEN
                        l_etc_noncmt_quantity_pc_tab (k) := l_etc_noncmt_quantity_pc_sum
                                   * (l_etc_quantity_pc_tab (k) / l_etc_quantity_pc_sum) ;
                    ELSE
                        l_etc_noncmt_quantity_pc_tab (k) := NULL;
                    END IF;
                END LOOP;

               /* Convert PC into TC */
                FOR k IN 1..l_etc_currency_code_tab.count LOOP
                    IF l_etc_currency_code_tab(k) = l_pc_currency_code THEN
                        l_etc_noncmt_quantity_tab(k) := l_etc_noncmt_quantity_pc_tab(k);
                    ELSE
                        l_etc_noncmt_quantity_tab(k) := NULL;
                        BEGIN
                            SELECT  task_id,
                                    planning_start_date
                            INTO    l_task_id,
                                    l_planning_start_date
                            FROM    pa_resource_assignments
                            WHERE   resource_assignment_id = l_tgt_res_asg_id_tab(i);
                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                l_task_id := NULL;
                                l_planning_start_date := NULL;
                        END;
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                            pa_fp_gen_amount_utils.fp_debug(
                                p_msg         => 'Before calling pa_multi_currency_txn.'||
                                         'get_currency_amounts in remain_bdgt',
                                p_module_name => l_module_name,
                                p_log_level   => 5);
                        END IF;
                        pa_multi_currency_txn.get_currency_amounts (
                            P_project_id        => p_fp_cols_tgt_rec.x_project_id,
                            P_exp_org_id        => NULL,
                            P_calling_module    => 'WORKPLAN',
                            P_task_id           => l_task_id,
                            P_EI_date           => l_planning_start_date,
                            P_denom_raw_cost    => l_etc_noncmt_quantity_pc_tab(k),
                            P_denom_curr_code   => l_pc_currency_code,

                            P_acct_curr_code    => l_pc_currency_code,
                            P_accounted_flag    => 'N',
                            P_acct_rate_date    => lx_acc_rate_date,
                            P_acct_rate_type    => lx_acct_rate_type,
                            P_acct_exch_rate    => lx_acct_exch_rate,
                            P_acct_raw_cost     => lx_acct_raw_cost,

                            P_project_curr_code => l_etc_currency_code_tab(k),
                            P_project_rate_type => lx_project_rate_type,
                            P_project_rate_date => lx_project_rate_date,
                            P_project_exch_rate => lx_project_exch_rate,
                            P_project_raw_cost  => l_etc_noncmt_quantity_tab(k),

                            P_projfunc_curr_code=> l_pc_currency_code,
                            P_projfunc_cost_rate_type   => lx_projfunc_cost_rate_type,
                            P_projfunc_cost_rate_date   => lx_projfunc_cost_rate_date,
                            P_projfunc_cost_exch_rate   => lx_projfunc_cost_exch_rate,
                            P_projfunc_raw_cost => l_projfunc_raw_cost,

                            P_system_linkage    => 'NER',
                            P_status            => x_return_status,
                            P_stage             => x_msg_count) ;
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                            pa_fp_gen_amount_utils.fp_debug(
                                p_msg         => 'After calling pa_multi_currency_txn.'||
                                  'get_currency_amounts in remain_bdgt:'||x_return_status,
                                p_module_name => l_module_name,
                            p_log_level   => 5);
                        END IF;
                        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                        END IF;
                    END IF;

                END LOOP;

                /*When not taking periodic rates, we need to calculate out the average
                  rates from the source resource assignments that are mapped to the
                  current target resource assignment.*/
                FOR k IN 1..l_etc_noncmt_quantity_tab.count LOOP
                    SELECT  /*+ INDEX(pa_fp_calc_amt_tmp2,PA_FP_CALC_AMT_TMP2_N1)*/
                            NVL(SUM(NVL(etc_plan_quantity,0)),0),
                            NVL(SUM(NVL(etc_txn_raw_cost,0)),0),
                            NVL(SUM(NVL(etc_txn_burdened_cost,0)),0),
                            NVL(SUM(NVL(etc_txn_revenue,0)),0)
                    INTO    l_txn_rate_quantity,
                            l_txn_rate_raw_cost,
                            l_txn_rate_brdn_cost,
                            l_txn_rate_revenue
                    FROM pa_fp_calc_amt_tmp2
                    WHERE target_res_asg_id = l_tgt_res_asg_id_tab(i)
                    AND etc_currency_code = l_etc_currency_code_tab(k)
                    AND transaction_source_code = 'TOTAL_ETC';

	            -- IPM Change:
	            -- For non-rate-based target transactions,
	            --   set target quantity to source raw cost if it exists, OR
	            --   set target quantity to source revenue otherwise.
	            -- This is done to handle source planning transactions that
	            -- have only revenue amounts (without cost amounts).
	            --
	            -- Note that source version type is not available in the
	            -- context of this API. However, the logic should still be ok.

                    IF nvl(l_txn_rate_raw_cost,0) = 0 THEN
                        l_txn_rate_quantity := l_txn_rate_revenue;
                    ELSE
                        l_txn_rate_quantity := l_txn_rate_raw_cost;
                    END IF;

                    -- Bug 5203622: Added OTHER REJECTION CODE logic.
                    l_other_rej_code_tab(k) := null;
                    IF l_rate_based_flag = 'N' AND
                       l_target_version_type = 'ALL' AND
                       nvl(l_txn_rate_raw_cost,0) = 0 AND
                       nvl(l_txn_rate_revenue,0) <> 0 THEN
                        l_other_rej_code_tab(k) := 'PA_FP_ETC_REV_FIELD_ERR';
                    END IF;

                    IF l_txn_rate_quantity <> 0 THEN

                        l_txn_raw_cost_rate_tab(k) := l_txn_rate_raw_cost
                                                    / l_txn_rate_quantity; -- Added in IPM
                        l_txn_brdn_cost_rate_tab(k) := l_txn_rate_brdn_cost
                                                    / l_txn_rate_quantity;
                        l_txn_revenue_rate_tab(k) := l_txn_rate_revenue
                                                    / l_txn_rate_quantity;
                    ELSE
                        l_txn_raw_cost_rate_tab(k) := NULL; -- Added in IPM
                        l_txn_brdn_cost_rate_tab(k) := NULL;
                        l_txn_revenue_rate_tab(k) := NULL;
                    END IF;
                END LOOP;

                -- Bug 5203622: Store OTHER rejection code in the
                -- txn_currency_code column of pa_fp_calc_amt_tmp2.
                /* Bulk insert */
                FORALL k IN 1..l_etc_noncmt_quantity_tab.count
                    INSERT INTO PA_FP_CALC_AMT_TMP2 (
                        TARGET_RES_ASG_ID,
                        ETC_CURRENCY_CODE,
                        ETC_PLAN_QUANTITY,
                        ETC_TXN_RAW_COST,
                        ETC_TXN_BURDENED_COST,
                        ETC_TXN_REVENUE,
                        TRANSACTION_SOURCE_CODE,
                        RESOURCE_ASSIGNMENT_ID,
                        TXN_CURRENCY_CODE ) -- Added for Bug 5203622
                    VALUES (
                        l_tgt_res_asg_id_tab(i),
                        l_etc_currency_code_tab(k),
                        l_etc_noncmt_quantity_tab(k),
                        l_etc_noncmt_quantity_tab(k) * l_txn_raw_cost_rate_tab(k),
                        l_etc_noncmt_quantity_tab(k) * l_txn_brdn_cost_rate_tab(k),
                        l_etc_noncmt_quantity_tab(k) * l_txn_revenue_rate_tab(k),
                        'ETC',
                        l_src_res_asg_id_tab(i),
                        l_other_rej_code_tab(k) ); -- Added for Bug 5203622
            END IF;
        /**************NOW WE HAVE ALL ETC DATA IN PC_TC*************/

        END IF; /* End the check for PC, TC and PC_TC */
      END IF;
    END LOOP; --wrapper loop for Bug 4110695
    END LOOP;

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
               (p_msg         => 'Invalid Arguments Passed',
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
        --dbms_output.put_line('error msg :'||x_msg_data);
        FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_GEN_FCST_AMT_PUB3',
                     p_procedure_name  => 'GEN_ETC_COMMITMENT_AMTS',
                     p_error_text      => substr(sqlerrm,1,240));

        IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                p_module_name => l_module_name,
                p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END GET_ETC_COMMITMENT_AMTS;


/* Assumption:
 *1.Before getting into this procedure, we have all total plan amounts and commitment
  amounts populated in temporary table PA_FP_CALC_AMT_TMP2 table with transaction
  source codes of 'WORKPLAN'/'FINPLAN' or 'OPEN_COMMITMENTS'.
  2.Rate based flag for target resource assignment gets updated correctly before coming
  into any of ETC methods.
  3.All considered scenarios:
    Rate_based
      non multi currency enabled: use PC
      multi currency enabled
        actuals currency is subset of total currency: use TC, currency based substraction
        actuals currency is not subset of total currency: use TC, prorate ETC quantity
    Non_rate_based
      non multi currency enabled: use PC
      multi currency enabled
        actuals currency not subset of total currency: use TC, currency based substraction
        actuals currency not subset of total currency: Compute ETC quantity in PC, prorate
            this ETC quantity to different planning currencies based on PC amounts,
            convert back from PC to TC.
*/
PROCEDURE GET_ETC_REMAIN_BDGT_AMTS_BLK
          (P_SRC_RES_ASG_ID_TAB        IN  PA_PLSQL_DATATYPES.IdTabTyp,
           P_TGT_RES_ASG_ID_TAB        IN  PA_PLSQL_DATATYPES.IdTabTyp,
           P_FP_COLS_SRC_REC_FP        IN  PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_FP_COLS_SRC_REC_WP        IN  PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_FP_COLS_TGT_REC           IN  PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_TASK_ID_TAB               IN  PA_PLSQL_DATATYPES.IdTabTyp,
           P_RES_LIST_MEMBER_ID_TAB    IN  PA_PLSQL_DATATYPES.IdTabTyp,
           P_ETC_SOURCE_CODE_TAB       IN  PA_PLSQL_DATATYPES.Char30TabTyp,
           P_WP_STRUCTURE_VERSION_ID   IN  PA_PROJ_ELEM_VER_STRUCTURE.ELEMENT_VERSION_ID%TYPE,
           P_ACTUALS_THRU_DATE         IN  PA_PERIODS_ALL.END_DATE%TYPE,
           P_PLANNING_OPTIONS_FLAG     IN  VARCHAR2,
           X_RETURN_STATUS             OUT NOCOPY VARCHAR2,
           X_MSG_COUNT                 OUT NOCOPY NUMBER,
           X_MSG_DATA                  OUT NOCOPY VARCHAR2)
IS
  l_module_name  VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_FCST_AMT_PUB3.GEN_ETC_REMAIN_BDGT_AMTS_BLK';

  l_currency_flag               VARCHAR2(30);
  l_rate_based_flag             VARCHAR2(1);
  l_currency_count_for_flag     NUMBER;
  l_prorating_always_flag       VARCHAR2(1); -- currently unused
  l_target_version_type         pa_budget_versions.version_type%type;
  l_source_version_type         pa_budget_versions.version_type%type; /* Added for IPM */

  /* For PC amounts */
  l_pc_currency_code            pa_projects_all.project_currency_code%type;
  l_tot_quantity_pc_pfc         NUMBER;
  l_tot_raw_cost_pc_pfc         NUMBER;
  l_tot_brdn_cost_pc_pfc        NUMBER;
  l_tot_revenue_pc_pfc          NUMBER;

  l_act_quantity_pc_pfc         NUMBER;

  /*For workplan actuals*/
  lx_act_quantity               NUMBER;
  lx_act_txn_currency_code      VARCHAR2(30);
  lx_act_txn_raw_cost           NUMBER;
  lx_act_txn_brdn_cost          NUMBER;
  lx_act_pc_raw_cost            NUMBER;
  lx_act_pc_brdn_cost           NUMBER;
  lx_act_pfc_raw_cost           NUMBER;
  lx_act_pfc_brdn_cost          NUMBER;

  l_etc_quantity_pc_pfc         NUMBER;

  /* For TC amounts */
  l_tot_currency_code_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
  l_tot_quantity_tab            PA_PLSQL_DATATYPES.NumTabTyp;
  l_tot_raw_cost_tab            PA_PLSQL_DATATYPES.NumTabTyp;
  l_tot_brdn_cost_tab           PA_PLSQL_DATATYPES.NumTabTyp;
  l_tot_revenue_tab             PA_PLSQL_DATATYPES.NumTabTyp;
  l_tot_quantity_sum            NUMBER;

  l_act_currency_code_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
  l_act_quantity_tab            PA_PLSQL_DATATYPES.NumTabTyp;
  l_act_raw_cost_tab            PA_PLSQL_DATATYPES.NumTabTyp;
  l_act_brdn_cost_tab           PA_PLSQL_DATATYPES.NumTabTyp;
  l_act_revenue_tab             PA_PLSQL_DATATYPES.NumTabTyp;
  l_act_quantity_sum            NUMBER;

  /* ForPFC amounts */
  l_pfc_currency_code           pa_projects_all.project_currency_code%type;
  l_rev_gen_method              VARCHAR2(3);


  /* For ETC amounts */
  l_etc_quantity_tab            PA_PLSQL_DATATYPES.NumTabTyp;
  l_etc_quantity_sum            NUMBER;

  l_currency_count_act_min_tot  NUMBER;
  l_currency_prorate_act_flag   VARCHAR2(1);
  l_exit_flag                   VARCHAR2(1) := 'N';

  /*For PC_TC amounts*/
  l_tot_quantity_pc_tab         PA_PLSQL_DATATYPES.NumTabTyp;
  l_tot_raw_cost_pc_tab         PA_PLSQL_DATATYPES.NumTabTyp;
  l_tot_brdn_cost_pc_tab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_tot_revenue_pc_tab          PA_PLSQL_DATATYPES.NumTabTyp;
  l_tot_quantity_pc_sum         NUMBER;
  l_act_quantity_pc_sum         NUMBER;
  l_etc_quantity_pc_tab         PA_PLSQL_DATATYPES.NumTabTyp;
  l_etc_quantity_pc_sum         NUMBER;

  /*For average rates*/
  l_pc_pfc_rate_quantity        NUMBER;
  l_pc_pfc_rate_raw_cost        NUMBER;
  l_pc_pfc_rate_brdn_cost       NUMBER;
  l_pc_pfc_rate_revenue         NUMBER;

  l_pc_rate_quantity            NUMBER; -- currently not used
  l_pc_rate_raw_cost            NUMBER;
  l_pc_rate_brdn_cost           NUMBER;
  l_pc_rate_revenue             NUMBER;

  l_txn_rate_quantity           NUMBER;
  l_txn_rate_raw_cost           NUMBER;
  l_txn_rate_brdn_cost          NUMBER;
  l_txn_rate_revenue            NUMBER;

  l_pc_pfc_raw_cost_rate        NUMBER;
  l_pc_pfc_brdn_cost_rate       NUMBER;
  l_pc_pfc_revenue_rate         NUMBER;

  l_txn_raw_cost_rate_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  l_txn_brdn_cost_rate_tab      PA_PLSQL_DATATYPES.NumTabTyp;
  l_txn_revenue_rate_tab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_pc_raw_cost_rate_tab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_pc_brdn_cost_rate_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  l_pc_revenue_rate_tab         PA_PLSQL_DATATYPES.NumTabTyp;
  l_transaction_source_code     VARCHAR2(30);

  /*For txn currency conversion*/
  l_task_id                     pa_tasks.task_id%type;
  l_planning_start_date         pa_resource_assignments.planning_start_date%type;
  lx_acc_rate_date              DATE;
  lx_acct_rate_type             VARCHAR2(50);
  lx_acct_exch_rate             NUMBER;
  lx_acct_raw_cost              NUMBER;
  lx_project_rate_type          VARCHAR2(50);
  lx_project_rate_date          DATE;
  lx_project_exch_rate          NUMBER;
  lx_projfunc_cost_rate_type    VARCHAR2(50);
  lx_projfunc_cost_rate_date    DATE;
  lx_projfunc_cost_exch_rate    NUMBER;
  l_projfunc_raw_cost           NUMBER;

  /* Status variable for GET_CURRENCY_AMOUNTS api */
  l_status                      Varchar2(100);
  g_project_name                pa_projects_all.name%TYPE;

  /* Variables for Performance Bug 4194849 */
  l_src_res_asg_id              PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE;
  l_tgt_res_asg_id              PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE;
  l_fp_cols_src_rec             PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
  l_curr_task_id                PA_TASKS.TASK_ID%TYPE;
  l_resource_list_member_id     PA_RESOURCE_LIST_MEMBERS.RESOURCE_LIST_MEMBER_ID%TYPE;
  l_etc_source_code             PA_TASKS.GEN_ETC_SOURCE_CODE%TYPE;

  /* This user-defined exception is used to skip processing of
   * a single task as we process all of the tasks in a loop. */
  continue_loop                 EXCEPTION;
  l_dummy                       NUMBER;

  l_ins_index                   BINARY_INTEGER;
  l_ins_src_res_asg_id_tab      PA_PLSQL_DATATYPES.IdTabTyp;
  l_ins_tgt_res_asg_id_tab      PA_PLSQL_DATATYPES.IdTabTyp;
  l_ins_currency_code_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
  l_ins_etc_quantity_tab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_ins_txn_raw_cost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_ins_txn_burdened_cost_tab   PA_PLSQL_DATATYPES.NumTabTyp;
  l_ins_txn_revenue_tab         PA_PLSQL_DATATYPES.NumTabTyp;
  l_ins_pc_raw_cost_tab         PA_PLSQL_DATATYPES.NumTabTyp;
  l_ins_pc_burdened_cost_tab    PA_PLSQL_DATATYPES.NumTabTyp;
  l_ins_pc_revenue_tab          PA_PLSQL_DATATYPES.NumTabTyp;
  l_ins_pfc_raw_cost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_ins_pfc_burdened_cost_tab   PA_PLSQL_DATATYPES.NumTabTyp;
  l_ins_pfc_revenue_tab         PA_PLSQL_DATATYPES.NumTabTyp;

  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_data                    VARCHAR2(2000);
  l_msg_index_out           NUMBER:=0;

  -- Variables added for Bug 5203622
  l_act_raw_cost_pc_pfc         NUMBER;
  l_act_raw_cost_sum            NUMBER;
  l_act_raw_cost_pc_sum         NUMBER;
  l_tot_raw_cost_sum            NUMBER;
  l_tot_revenue_sum             NUMBER;
  l_tot_raw_cost_pc_sum         NUMBER;
  l_tot_revenue_pc_sum          NUMBER;
  l_other_rej_code              PA_BUDGET_LINES.OTHER_REJECTION_CODE%TYPE;
  l_other_rej_code_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
  l_ins_other_rej_code_tab      PA_PLSQL_DATATYPES.Char30TabTyp;

BEGIN
    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function     => 'GEN_ETC_REMAIN_BDGT_AMTS_BLK',
                                    p_debug_mode   =>  p_pa_debug_mode);
    END IF;

    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_COUNT := 0;

    FOR main_loop IN 1..p_src_res_asg_id_tab.count LOOP
    BEGIN

        /* Initialize Local Variables for Bug 4194849 */
        l_src_res_asg_id := p_src_res_asg_id_tab(main_loop);
        l_tgt_res_asg_id := p_tgt_res_asg_id_tab(main_loop);
        l_curr_task_id := p_task_id_tab(main_loop);
        l_resource_list_member_id := p_res_list_member_id_tab(main_loop);
        l_etc_source_code := p_etc_source_code_tab(main_loop);

        IF l_etc_source_code = 'FINANCIAL_PLAN' THEN
            l_fp_cols_src_rec := p_fp_cols_src_rec_fp;
        ELSIF l_etc_source_code = 'WORKPLAN_RESOURCES' THEN
            l_fp_cols_src_rec := p_fp_cols_src_rec_wp;
        END IF;

        /* Delete pl/sql tables for the current task being processed. */
        l_tot_currency_code_tab.delete;
        l_tot_quantity_tab.delete;
        l_tot_raw_cost_tab.delete;
        l_tot_brdn_cost_tab.delete;
        l_tot_revenue_tab.delete;

        l_act_currency_code_tab.delete;
        l_act_quantity_tab.delete;
        l_act_raw_cost_tab.delete;
        l_act_brdn_cost_tab.delete;
        l_act_revenue_tab.delete;

        l_tot_quantity_pc_tab.delete;
        l_tot_raw_cost_pc_tab.delete;
        l_tot_brdn_cost_pc_tab.delete;
        l_tot_revenue_pc_tab.delete;
        l_etc_quantity_pc_tab.delete;

        l_txn_raw_cost_rate_tab.delete;
        l_txn_brdn_cost_rate_tab.delete;
        l_txn_revenue_rate_tab.delete;
        l_pc_raw_cost_rate_tab.delete;
        l_pc_brdn_cost_rate_tab.delete;
        l_pc_revenue_rate_tab.delete;

        -- Bug 4231106: Before populating l_etc_quantity_tab, delete existing records
        l_etc_quantity_tab.delete;

        /*Currency usage should be determined at the beginning.
          Default to use Transaction Currency (TC)
          If target version is not multi currency enabled, take Project Currency (PC)
          IF target version is multi currency enabled, the target planning resource is non
          rate based, and actuals currencies are not subset of the total currencies. We need
          to take PC amounts as quantity, sum up total quantity minus actual quantity,
          prorate this total PC ETC quantity across the planning currencies. Then convert
          them back from PC to TC (PC_TC).*/

        IF nvl(l_tgt_res_asg_id,0) > 0 THEN
            SELECT rate_based_flag
            INTO l_rate_based_flag
            FROM pa_resource_assignments
            WHERE resource_assignment_id = l_tgt_res_asg_id;
        ELSE
            l_rate_based_flag:='N';
        END IF;

        l_currency_flag := 'TC';
        l_rev_gen_method := nvl(P_FP_COLS_TGT_REC.x_revenue_derivation_method,PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(P_FP_COLS_TGT_REC.x_project_id)); -- Bug 5462471
        --l_rev_gen_method := PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(P_FP_COLS_TGT_REC.x_project_id);

        IF (p_fp_cols_tgt_rec.x_version_type = 'REVENUE' and l_rev_gen_method = 'C') THEN
            l_currency_flag := 'PFC';
        ELSIF p_fp_cols_tgt_rec.X_PLAN_IN_MULTI_CURR_FLAG = 'N' THEN
            l_currency_flag := 'PC';
        ELSIF l_rate_based_flag = 'N' THEN
            SELECT COUNT(*) INTO l_currency_count_for_flag FROM (
                SELECT /*+ INDEX(act_tmp,PA_FP_FCST_GEN_TMP1_N1) INDEX(tot_tmp,PA_FP_CALC_AMT_TMP1_N1)*/
                       DISTINCT act_tmp.txn_currency_code
                FROM PA_FP_FCST_GEN_TMP1 act_tmp,
                PA_FP_CALC_AMT_TMP1 tot_tmp
                WHERE act_tmp.project_element_id = tot_tmp.task_id
                AND act_tmp.res_list_member_id = tot_tmp.resource_list_member_id
                AND tot_tmp.target_res_asg_id = l_tgt_res_asg_id
                AND data_type_code = DECODE(L_ETC_SOURCE_CODE,
                                            'WORKPLAN_RESOURCES', 'ETC_WP',
                                            'FINANCIAL_PLAN', 'ETC_FP')
                MINUS
                SELECT /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N1)*/
                       DISTINCT txn_currency_code
                FROM PA_FP_CALC_AMT_TMP2
                WHERE target_res_asg_id = l_tgt_res_asg_id
                AND transaction_source_code = l_etc_source_code
            ) WHERE rownum = 1;

            IF l_currency_count_for_flag > 0 THEN
                l_currency_flag := 'PC_TC';
            END IF;
        END IF;

        /**************BY THIS TIME, WE DECIDED TO USE EITHER PC,TC,PC_TC or PFC**********/

        -- Get Source version tpe
        IF l_etc_source_code = 'FINANCIAL_PLAN' THEN
            l_source_version_type := p_fp_cols_src_rec_fp.x_version_type;
        ELSE -- l_etc_source_code = 'WORKPLAN_RESOURCES'
            l_source_version_type := p_fp_cols_src_rec_wp.x_version_type;
        END IF;

        l_target_version_type := p_fp_cols_tgt_rec.x_version_type;
        l_pc_currency_code := p_fp_cols_tgt_rec.x_project_currency_code;
        l_pfc_currency_code := p_fp_cols_tgt_rec.x_projfunc_currency_code;
        IF l_currency_flag = 'PC' OR l_currency_flag = 'PFC' THEN
            /* No matter ETC source is 'FINANCIAL_PLAN' or 'WORKPLAN_RESOURCES', always get
               total plan amounts in PC or PFC from financial data model.*/
            SELECT  /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
                    NVL(SUM(NVL(total_plan_quantity,0)),0),
                    NVL(SUM(NVL(
                        DECODE(l_currency_flag, 'PC', total_pc_raw_cost,
                                                'PFC', total_pfc_raw_cost),0)),0),
                    NVL(SUM(NVL(
                        DECODE(l_currency_flag, 'PC', total_pc_burdened_cost,
                                                'PFC', total_pfc_burdened_cost),0)),0),
                    NVL(SUM(NVL(
                        DECODE(l_currency_flag, 'PC', total_pc_revenue,
                                                'PFC', total_pfc_revenue),0)),0)
            INTO    l_tot_quantity_pc_pfc,
                    l_tot_raw_cost_pc_pfc,
                    l_tot_brdn_cost_pc_pfc,
                    l_tot_revenue_pc_pfc
            FROM PA_FP_CALC_AMT_TMP2
            WHERE resource_assignment_id = l_src_res_asg_id
            AND transaction_source_code = l_etc_source_code;

            -- IPM Change:
            -- For non-rate-based target transactions,
            -- if the Source is a Cost and Revenue together version,
            -- then regardless of the Target version type:
            --   set target quantity to source raw cost if it exists, OR
            --   set target quantity to source revenue otherwise.
            -- This is done to handle source planning transactions that
            -- have only revenue amounts (without cost amounts).
            --
            -- For non-rate-based target transactions and other Source
            -- version types, set target quantity to source raw cost as before.

            IF l_rate_based_flag = 'N' THEN
                IF l_source_version_type = 'ALL' THEN
                    IF nvl(l_tot_raw_cost_pc_pfc,0) = 0 THEN
                        l_tot_quantity_pc_pfc := l_tot_revenue_pc_pfc;
                    ELSE
                        l_tot_quantity_pc_pfc := l_tot_raw_cost_pc_pfc;
                    END IF;
                ELSE
                    l_tot_quantity_pc_pfc := l_tot_raw_cost_pc_pfc;
                END IF;
            END IF;

            IF l_etc_source_code = 'FINANCIAL_PLAN' THEN
                SELECT /*+ INDEX(PA_FP_FCST_GEN_TMP1,PA_FP_FCST_GEN_TMP1_N1)*/
                       DECODE(l_currency_flag,
                        'PC', NVL(SUM(DECODE(l_rate_based_flag,
                            'Y', quantity,
                            'N', NVL(prj_raw_cost,0))),0),
                        'PFC', NVL(SUM(DECODE(l_rate_based_flag,
                            'Y', quantity,
                            'N', NVL(pou_raw_cost,0))),0)),
                       DECODE(l_currency_flag,  -- Added for Bug 5203622
                        'PC',  NVL(SUM(NVL(prj_raw_cost,0)),0),
                        'PFC', NVL(SUM(NVL(pou_raw_cost,0)),0))
                INTO l_act_quantity_pc_pfc,
                     l_act_raw_cost_pc_pfc  -- Added for Bug 5203622
                FROM PA_FP_FCST_GEN_TMP1
                WHERE project_element_id = l_curr_task_id
                AND res_list_member_id = l_resource_list_member_id
                AND data_type_code = 'ETC_FP';

            ELSIF l_etc_source_code = 'WORKPLAN_RESOURCES' THEN
                /*Bug fix for 3973511
                  Workplan side only stores amounts in one currency for each planning
                  resource. Instead of relying on pa_progress_utils.get_actuals_for_task
                  to get actuals data, we query directly to pa_budget_lines to get actual
                  data from source workplan budget version */
                IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug(
                        p_msg         => 'Before calling PA_FP_GEN_FCST_AMT_PUB1.'||
                                        'GET_WP_ACTUALS_FOR_RA',
                        p_module_name => l_module_name,
                        p_log_level   => 5);
                END IF;
                PA_FP_GEN_FCST_AMT_PUB1.GET_WP_ACTUALS_FOR_RA
                   (P_FP_COLS_SRC_REC        => l_fp_cols_src_rec,
                    P_FP_COLS_TGT_REC        => p_fp_cols_tgt_rec,
                    P_SRC_RES_ASG_ID         => l_src_res_asg_id,
                    P_TASK_ID                => l_curr_task_id,
                    P_RES_LIST_MEM_ID        => l_resource_list_member_id,
                    P_ACTUALS_THRU_DATE      => p_actuals_thru_date,
                    X_ACT_QUANTITY           => lx_act_quantity,
                    X_ACT_TXN_CURRENCY_CODE  => lx_act_txn_currency_code,
                    X_ACT_TXN_RAW_COST       => lx_act_txn_raw_cost,
                    X_ACT_TXN_BRDN_COST      => lx_act_txn_brdn_cost,
                    X_ACT_PC_RAW_COST        => lx_act_pc_raw_cost,
                    X_ACT_PC_BRDN_COST       => lx_act_pc_brdn_cost,
                    X_ACT_PFC_RAW_COST       => lx_act_pfc_raw_cost,
                    X_ACT_PFC_BRDN_COST      => lx_act_pfc_brdn_cost,
                    X_RETURN_STATUS          => x_return_status,
                    X_MSG_COUNT              => x_msg_count,
                    X_MSG_DATA               => x_msg_data );
                IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug(
                        p_msg         => 'After calling PA_FP_GEN_FCST_AMT_PUB1.'||
                                         'GET_WP_ACTUALS_FOR_RA in remain_bdgt:'||x_return_status,
                        p_module_name => l_module_name,
                        p_log_level   => 5);
                END IF;
                IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

                IF l_rate_based_flag = 'Y' THEN
                    l_act_quantity_pc_pfc := lx_act_quantity;
                    l_act_raw_cost_pc_pfc := lx_act_txn_raw_cost; -- Added for Bug 5203622
                ELSE
                    IF l_currency_flag = 'PC' THEN
                        l_act_quantity_pc_pfc :=  lx_act_pc_raw_cost;
                        l_act_raw_cost_pc_pfc :=  lx_act_pc_raw_cost;  -- Added for Bug 5203622
                    ELSIF l_currency_flag = 'PFC' THEN
                        l_act_quantity_pc_pfc :=  lx_act_pfc_raw_cost;
                        l_act_raw_cost_pc_pfc :=  lx_act_pfc_raw_cost; -- Added for Bug 5203622
                    END IF;
                END IF;
            END IF;

            /* Get total ETC quantity */
            l_etc_quantity_pc_pfc := l_tot_quantity_pc_pfc - l_act_quantity_pc_pfc;
            -- ER 5726773: Instead of directly checking if (ETC <= 0), let the
	    -- plan_etc_signs_match function decide if ETC should be generated.
	    IF NOT pa_fp_fcst_gen_amt_utils.PLAN_ETC_SIGNS_MATCH
 	                  (l_tot_quantity_pc_pfc, l_etc_quantity_pc_pfc) THEN
 	    /* only need to spread commitment and actual data*/
                RAISE continue_loop;
            END IF;

            -- Bug 5203622: Added OTHER REJECTION CODE logic.
            l_other_rej_code := null;
            IF l_rate_based_flag = 'N' AND
               l_source_version_type = 'ALL' AND
               l_target_version_type = 'ALL' AND
               nvl(l_tot_raw_cost_pc_pfc,0) = 0 AND
               nvl(l_tot_revenue_pc_pfc,0) <> 0 AND
               nvl(l_act_raw_cost_pc_pfc,0) <> 0 THEN
                l_other_rej_code := 'PA_FP_ETC_REV_FIELD_ERR';
            END IF;

            /*  hr_utility.trace('project currency:'||l_ppc_currency_code);
                hr_utility.trace('etc qty '||l_etc_quantity_pc );*/

            /*When not taking periodic rates, we need to calculate out the average
              rates from the source resource assignments that are mapped to the current
              target resource assignmentInsert the single PC record for total ETC.*/
            SELECT  /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
                    NVL(SUM(NVL(total_plan_quantity,0)),0),
                    DECODE(l_currency_flag,
                        'PC', NVL(SUM(NVL(total_pc_raw_cost,0)),0),
                        'PFC', NVL(SUM(NVL(total_pfc_raw_cost,0)),0)),
                    DECODE(l_currency_flag,
                        'PC', NVL(SUM(NVL(total_pc_burdened_cost,0)),0),
                        'PFC', NVL(SUM(NVL(total_pfc_burdened_cost,0)),0)),
                    DECODE(l_currency_flag,
                        'PC', NVL(SUM(NVL(total_pc_revenue,0)),0),
                        'PFC', NVL(SUM(NVL(total_pfc_revenue,0)),0))
            INTO    l_pc_pfc_rate_quantity,
                    l_pc_pfc_rate_raw_cost,
                    l_pc_pfc_rate_brdn_cost,
                    l_pc_pfc_rate_revenue
            FROM pa_fp_calc_amt_tmp2
            WHERE resource_assignment_id = l_src_res_asg_id
              AND transaction_source_code in ('FINANCIAL_PLAN',
                                              'WORKPLAN_RESOURCES');

            -- IPM Change:
            -- For non-rate-based target transactions,
            -- if the Source is a Cost and Revenue together version,
            -- then regardless of the Target version type:
            --   set rate quantity to rate raw cost if it exists, OR
            --   set rate quantity to rate revenue otherwise.
            -- This is done to handle source planning transactions that
            -- have only revenue amounts (without cost amounts).
            --
            -- For non-rate-based target transactions and other Source
            -- version types, set rate quantity to rate raw cost as before.

            IF l_rate_based_flag = 'N' THEN
                IF l_source_version_type = 'ALL' THEN
                    IF nvl(l_pc_pfc_rate_raw_cost,0) = 0 THEN
                        l_pc_pfc_rate_quantity := l_pc_pfc_rate_revenue;
                    ELSE
                        l_pc_pfc_rate_quantity := l_pc_pfc_rate_raw_cost;
                    END IF;
                ELSE
                    l_pc_pfc_rate_quantity := l_pc_pfc_rate_raw_cost;
                END IF;
            END IF;

            IF l_pc_pfc_rate_quantity <> 0 THEN
                l_pc_pfc_raw_cost_rate := l_pc_pfc_rate_raw_cost / l_pc_pfc_rate_quantity;
                l_pc_pfc_brdn_cost_rate := l_pc_pfc_rate_brdn_cost / l_pc_pfc_rate_quantity;
                l_pc_pfc_revenue_rate := l_pc_pfc_rate_revenue / l_pc_pfc_rate_quantity;
            ELSE
                l_pc_pfc_raw_cost_rate := NULL;
                l_pc_pfc_brdn_cost_rate := NULL;
                l_pc_pfc_revenue_rate := NULL;
            END IF;

	    l_ins_index := l_ins_src_res_asg_id_tab.count + 1;
	    l_ins_src_res_asg_id_tab(l_ins_index) := l_src_res_asg_id;
	    l_ins_tgt_res_asg_id_tab(l_ins_index) := l_tgt_res_asg_id;
	    l_ins_etc_quantity_tab(l_ins_index) := l_etc_quantity_pc_pfc;
	    l_ins_txn_raw_cost_tab(l_ins_index) :=
                l_etc_quantity_pc_pfc * l_pc_pfc_raw_cost_rate;
	    l_ins_txn_burdened_cost_tab(l_ins_index) :=
                l_etc_quantity_pc_pfc * l_pc_pfc_brdn_cost_rate;
	    l_ins_txn_revenue_tab(l_ins_index) :=
                l_etc_quantity_pc_pfc * l_pc_pfc_revenue_rate;
            -- Added for Bug 5203622
            l_ins_other_rej_code_tab(l_ins_index) := l_other_rej_code;

            IF l_currency_flag = 'PC' THEN
                l_ins_currency_code_tab(l_ins_index) := l_pc_currency_code;
                l_ins_pc_raw_cost_tab(l_ins_index) :=
                    l_etc_quantity_pc_pfc * l_pc_pfc_raw_cost_rate;
                l_ins_pc_burdened_cost_tab(l_ins_index) :=
                    l_etc_quantity_pc_pfc * l_pc_pfc_brdn_cost_rate;
                l_ins_pc_revenue_tab(l_ins_index) :=
                    l_etc_quantity_pc_pfc * l_pc_pfc_revenue_rate;
                l_ins_pfc_raw_cost_tab(l_ins_index) := NULL;
                l_ins_pfc_burdened_cost_tab(l_ins_index) := NULL;
                l_ins_pfc_revenue_tab(l_ins_index) := NULL;
            ELSIF l_currency_flag = 'PFC' THEN
                l_ins_currency_code_tab(l_ins_index) := l_pfc_currency_code;
                l_ins_pc_raw_cost_tab(l_ins_index) := NULL;
                l_ins_pc_burdened_cost_tab(l_ins_index) := NULL;
                l_ins_pc_revenue_tab(l_ins_index) := NULL;
                l_ins_pfc_raw_cost_tab(l_ins_index) :=
                    l_etc_quantity_pc_pfc * l_pc_pfc_raw_cost_rate;
                l_ins_pfc_burdened_cost_tab(l_ins_index) :=
                    l_etc_quantity_pc_pfc * l_pc_pfc_brdn_cost_rate;
                l_ins_pfc_revenue_tab(l_ins_index) :=
                    l_etc_quantity_pc_pfc * l_pc_pfc_revenue_rate;
            ELSE
                l_ins_currency_code_tab(l_ins_index) := NULL;
                l_ins_pc_raw_cost_tab(l_ins_index) := NULL;
                l_ins_pc_burdened_cost_tab(l_ins_index) := NULL;
                l_ins_pc_revenue_tab(l_ins_index) := NULL;
                l_ins_pfc_raw_cost_tab(l_ins_index) := NULL;
                l_ins_pfc_burdened_cost_tab(l_ins_index) := NULL;
                l_ins_pfc_revenue_tab(l_ins_index) := NULL;
            END IF;

        /**************BY THIS TIME, WE HAVE ALL ETC DATA FOR PC or PFC*********/

        ELSIF l_currency_flag = 'TC' THEN
            /* No matter ETC source is 'FINANCIAL_PLAN' or 'WORKPLAN_RESOURCES', always
               get total plan amounts by txn currency from financial data model.*/
            SELECT  /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
                    txn_currency_code,
                    SUM(NVL(total_plan_quantity,0)),
                    SUM(NVL(total_txn_raw_cost,0)),
                    SUM(NVL(total_txn_burdened_cost,0)),
                    SUM(NVL(total_txn_revenue,0))
            BULK COLLECT INTO
                    l_tot_currency_code_tab,
                    l_tot_quantity_tab,
                    l_tot_raw_cost_tab,
                    l_tot_brdn_cost_tab,
                    l_tot_revenue_tab
            FROM PA_FP_CALC_AMT_TMP2
            WHERE resource_assignment_id = l_src_res_asg_id
            AND transaction_source_code = l_etc_source_code
            GROUP BY txn_currency_code;

            IF l_tot_currency_code_tab.count = 0 THEN
                RAISE continue_loop;
            END IF;

            -- IPM Change:
            -- For non-rate-based target transactions,
            -- if the Source is a Cost and Revenue together version,
            -- then regardless of the Target version type:
            --   set target quantity to source raw cost if it exists, OR
            --   set target quantity to source revenue otherwise.
            -- This is done to handle source planning transactions that
            -- have only revenue amounts (without cost amounts).
            --
            -- For non-rate-based target transactions and other Source
            -- version types, set target quantity to source raw cost as before.

            IF l_rate_based_flag = 'N' THEN
                IF l_source_version_type = 'ALL' THEN
                    -- Set total quantity for each Currency depending on whether
                    -- source raw cost exists (i.e. if it is a revenue-only txn).
                    FOR i IN 1..l_tot_quantity_tab.count LOOP
                        IF nvl(l_tot_raw_cost_tab(i),0) = 0 THEN
                            l_tot_quantity_tab(i) := l_tot_revenue_tab(i);
                        ELSE
                            l_tot_quantity_tab(i) := l_tot_raw_cost_tab(i);
                        END IF;
                    END LOOP;
                ELSE
                    l_tot_quantity_tab := l_tot_raw_cost_tab;
                END IF;
            END IF;

            /* Bug 4085203
               The total plan amounts should be summed up irrespective of rate based
               or non rate based. Because for non rate based resource, we used the
               sum value when plan and actuals are using same one currency. When
               plan and actuals are using more than one currencies, the flow will
               not use the sum amounts.*/
            -- Added l_tot_raw_cost_sum, l_tot_revenue_sum for Bug 5203622
            l_tot_quantity_sum := 0;
            l_tot_raw_cost_sum := 0;
            l_tot_revenue_sum  := 0;
            FOR i IN 1..l_tot_quantity_tab.count LOOP
                l_tot_quantity_sum := l_tot_quantity_sum + NVL(l_tot_quantity_tab(i),0);
                l_tot_raw_cost_sum := l_tot_raw_cost_sum + NVL(l_tot_raw_cost_tab(i),0);
                l_tot_revenue_sum  := l_tot_revenue_sum  + NVL(l_tot_revenue_tab(i),0);
            END LOOP;

            IF l_etc_source_code = 'FINANCIAL_PLAN' THEN
                SELECT  /*+ INDEX(PA_FP_FCST_GEN_TMP1,PA_FP_FCST_GEN_TMP1_N1)*/
                        txn_currency_code,
                        SUM(NVL(quantity,0)),
                        SUM(NVL(txn_raw_cost,0)),
                        SUM(NVL(txn_brdn_cost,0)),
                        SUM(NVL(txn_revenue,0))
                BULK COLLECT INTO
                        l_act_currency_code_tab,
                        l_act_quantity_tab,
                        l_act_raw_cost_tab,
                        l_act_brdn_cost_tab,
                        l_act_revenue_tab
                FROM PA_FP_FCST_GEN_TMP1
                WHERE project_element_id = l_curr_task_id
                AND res_list_member_id = l_resource_list_member_id
                AND data_type_code = 'ETC_FP'
                GROUP BY txn_currency_code;

                IF l_rate_based_flag = 'N' THEN
                    l_act_quantity_tab := l_act_raw_cost_tab;
                END IF;

                /* Bug 4085203
                   The total actual amounts should be summed up irrespective of rate based
                   or non rate based. Because for non rate based resource, we used the
                   sum value when plan and actuals are using same one currency. When
                   plan and actuals are using more than one currencies, the flow will
                   not use the sum amounts.*/
                l_act_quantity_sum := 0;
                l_act_raw_cost_sum := 0; -- Added for Bug 5203622
                FOR i IN 1..l_act_quantity_tab.count LOOP
                    l_act_quantity_sum := l_act_quantity_sum + l_act_quantity_tab(i);
                    -- Added for Bug 5203622
                    l_act_raw_cost_sum := l_act_raw_cost_sum + l_act_raw_cost_tab(i);
                END LOOP;

            ELSIF l_etc_source_code = 'WORKPLAN_RESOURCES' THEN
                /*Bug fix for 3973511
                  Workplan side only stores amounts in one currency for each planning
                  resource. Instead of relying on pa_progress_utils.get_actuals_for_task
                  to get actuals data, we query directly to pa_budget_lines to get actual
                  data from source workplan budget version */
                IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug(
                        p_msg         => 'Before calling PA_FP_GEN_FCST_AMT_PUB1.'||
                                        'GET_WP_ACTUALS_FOR_RA',
                        p_module_name => l_module_name,
                        p_log_level   => 5);
                END IF;
                PA_FP_GEN_FCST_AMT_PUB1.GET_WP_ACTUALS_FOR_RA
                   (P_FP_COLS_SRC_REC        => l_fp_cols_src_rec,
                    P_FP_COLS_TGT_REC        => p_fp_cols_tgt_rec,
                    P_SRC_RES_ASG_ID         => l_src_res_asg_id,
                    P_TASK_ID                => l_curr_task_id,
                    P_RES_LIST_MEM_ID        => l_resource_list_member_id,
                    P_ACTUALS_THRU_DATE      => p_actuals_thru_date,
                    X_ACT_QUANTITY           => lx_act_quantity,
                    X_ACT_TXN_CURRENCY_CODE  => lx_act_txn_currency_code,
                    X_ACT_TXN_RAW_COST       => lx_act_txn_raw_cost,
                    X_ACT_TXN_BRDN_COST      => lx_act_txn_brdn_cost,
                    X_ACT_PC_RAW_COST        => lx_act_pc_raw_cost,
                    X_ACT_PC_BRDN_COST       => lx_act_pc_brdn_cost,
                    X_ACT_PFC_RAW_COST       => lx_act_pfc_raw_cost,
                    X_ACT_PFC_BRDN_COST      => lx_act_pfc_brdn_cost,
                    X_RETURN_STATUS          => x_return_status,
                    X_MSG_COUNT              => x_msg_count,
                    X_MSG_DATA               => x_msg_data );
                IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug(
                        p_msg         => 'After calling PA_FP_GEN_FCST_AMT_PUB1.'||
                                         'GET_WP_ACTUALS_FOR_RA in remain_bdgt:'||x_return_status,
                        p_module_name => l_module_name,
                        p_log_level   => 5);
                END IF;
                IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

                l_act_currency_code_tab(1) := lx_act_txn_currency_code;
                l_act_quantity_tab(1) := lx_act_quantity;
                l_act_raw_cost_tab(1) := lx_act_txn_raw_cost;
                l_act_brdn_cost_tab(1):= lx_act_txn_brdn_cost;
                l_act_revenue_tab(1) := 0;

                IF l_rate_based_flag = 'N' THEN
                    l_act_quantity_tab := l_act_raw_cost_tab;
                END IF;

                l_act_quantity_sum := l_act_quantity_tab(1);
            END IF;


            /* Check the relationship between total currency codes and actual currency
               codes. If actual currency codes are subset of total currency codes, then,
               take currency based approach; otherwise, take prorating based approach.
               'C' means take currency based calculation
               'P' means take prorating based calculation */

            SELECT COUNT(*)
            INTO l_currency_count_act_min_tot
            FROM (
                SELECT /*+ INDEX(PA_FP_FCST_GEN_TMP1,PA_FP_FCST_GEN_TMP1_N1)*/
                       DISTINCT txn_currency_code
                FROM PA_FP_FCST_GEN_TMP1
                WHERE project_element_id = l_curr_task_id
                AND res_list_member_id = l_resource_list_member_id
                AND data_type_code = DECODE(L_ETC_SOURCE_CODE,
                                            'WORKPLAN_RESOURCES', 'ETC_WP',
                                            'FINANCIAL_PLAN', 'ETC_FP')
                MINUS
                SELECT /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
                       DISTINCT txn_currency_code
                FROM PA_FP_CALC_AMT_TMP2
                WHERE resource_assignment_id  = l_src_res_asg_id
                AND transaction_source_code = l_etc_source_code
            ) WHERE rownum = 1;

            IF l_currency_count_act_min_tot = 0 THEN
                l_currency_prorate_act_flag := 'C';
            ELSE
                l_currency_prorate_act_flag := 'P';
            END IF;

            /*Bug fix: 4085203: If there only exists one plan currency,
              one actual currency and they are same, no matter it's rate
              based resource or non rate based resource, if etc quantity is
              calculated as less or equal to zero, then don't generate the ETC.*/
            IF  l_act_currency_code_tab.count = 1 AND l_tot_currency_code_tab.count = 1 THEN
                l_etc_quantity_sum := l_tot_quantity_sum - l_act_quantity_sum;
                -- ER 5726773: Instead of directly checking if (ETC <= 0), let the
 	        -- plan_etc_signs_match function decide if ETC should be generated.
 	        IF NOT pa_fp_fcst_gen_amt_utils.PLAN_ETC_SIGNS_MATCH
 	                      (l_tot_quantity_sum, l_etc_quantity_sum) THEN
                    RAISE continue_loop;
                ELSE
                    l_etc_quantity_tab(1) := l_etc_quantity_sum;

                    -- Bug 5203622: Store OTHER rejection code in the
                    -- txn_currency_code column of pa_fp_calc_amt_tmp2.
                    l_other_rej_code_tab(1) := null;
	            IF l_rate_based_flag = 'N' AND
	               l_source_version_type = 'ALL' AND
	               l_target_version_type = 'ALL' AND
	               nvl(l_tot_raw_cost_sum,0) = 0 AND
	               nvl(l_tot_revenue_sum,0) <> 0 AND
	               nvl(l_act_raw_cost_sum,0) <> 0 THEN
	                l_other_rej_code_tab(1) := 'PA_FP_ETC_REV_FIELD_ERR';
	            END IF;
                END IF;
            ELSE
                l_exit_flag := 'N';
                IF l_currency_prorate_act_flag = 'C' THEN
                    FOR i IN 1..l_tot_currency_code_tab.count LOOP
                        IF l_exit_flag = 'Y' THEN
                            EXIT;
                        END IF;
                        l_etc_quantity_tab(i) := l_tot_quantity_tab(i);
                        l_other_rej_code_tab(i) := null; -- Added for Bug 5203622

                        FOR j IN 1..l_act_currency_code_tab.count LOOP
                            IF l_tot_currency_code_tab(i) = l_act_currency_code_tab(j) THEN
                                l_etc_quantity_tab(i) := l_etc_quantity_tab(i) - l_act_quantity_tab(j);

                                -- Bug 5203622: Added OTHER REJECTION CODE logic.
                                IF l_rate_based_flag = 'N' AND
                                   l_source_version_type = 'ALL' AND
                                   l_target_version_type = 'ALL' AND
                                   nvl(l_tot_raw_cost_tab(i),0) = 0 AND
                                   nvl(l_tot_revenue_tab(i),0) <> 0 AND
                                   nvl(l_act_raw_cost_tab(j),0) <> 0 THEN
                                    l_other_rej_code_tab(i) := 'PA_FP_ETC_REV_FIELD_ERR';
                                END IF;

                                -- ER 5726773: Instead of directly checking if (ETC <= 0), let the
 	                        -- plan_etc_signs_match function decide if ETC should be prorated.
 	                        IF NOT pa_fp_fcst_gen_amt_utils.PLAN_ETC_SIGNS_MATCH
 	                                      (l_tot_quantity_tab(i), l_etc_quantity_tab(i)) THEN
                                    l_currency_prorate_act_flag := 'P';
                                    l_etc_quantity_tab.delete;
                                    l_other_rej_code_tab.delete;  -- Added for Bug 5203622
                                    l_exit_flag := 'Y';
                                    EXIT;
                                END IF;
                            END IF;
                        END LOOP;
                    END LOOP;
                END IF;

                IF l_currency_prorate_act_flag = 'P' THEN
                    IF l_rate_based_flag = 'N' THEN
                        l_currency_flag := 'PC_TC';
                    ELSIF l_rate_based_flag = 'Y' THEN
                        l_etc_quantity_sum := l_tot_quantity_sum - l_act_quantity_sum;
                        -- ER 5726773: Instead of directly checking if (ETC <= 0), let the
			-- plan_etc_signs_match function decide if ETC should be generated.
			IF NOT pa_fp_fcst_gen_amt_utils.PLAN_ETC_SIGNS_MATCH
 	                              (l_tot_quantity_sum, l_etc_quantity_sum) THEN
 	               /* no non-commitment ETC available,
 	                   only actual and commitment amounts need to be spreaded */
                            RAISE continue_loop;
                        END IF;

                        FOR i IN 1..l_tot_currency_code_tab.count LOOP
                            IF l_tot_quantity_sum <> 0 THEN
                                l_etc_quantity_tab(i) := l_etc_quantity_sum
                                    * (l_tot_quantity_tab (i) / l_tot_quantity_sum) ;
                            ELSE
                                l_etc_quantity_tab(i) := NULL;
                            END IF;
                            /*  hr_utility.trace(i||'th');
                                hr_utility.trace('etc qty '||l_etc_qty );
                                hr_utility.trace('etc curr'||l_ETC_CURRENCY_CODE );
                                hr_utility.trace('etc rc  '||l_etc_txn_raw_cost );
                                hr_utility.trace('etc bc  '||l_etc_txn_brdn_cost );  */
                        END LOOP;
                    END IF;
                END IF;
            END IF;

            /*currency_flag may get changed to 'PC_TC', when actual currencies is subset of
             planning currencies, target resource is non_rate_based, but actual amount for
             one particular currency is less than plan amount. Then we need to revert from
             currency based approach to prorating based approach.For non_rate_based resource,
             prorating falls in to currency code of 'PC_TC'.*/
            IF l_currency_flag = 'TC' THEN
                /*When not taking periodic rates, we need to calculate out the average
                  rates from the source resource assignments that are mapped to the current
                  target resource assignment.*/
                FOR i IN 1..l_tot_currency_code_tab.count LOOP
                    SELECT  /*+ INDEX(pa_fp_calc_amt_tmp2,PA_FP_CALC_AMT_TMP2_N2)*/
                            NVL(SUM(NVL(total_plan_quantity,0)),0),
                            NVL(SUM(NVL(total_txn_raw_cost,0)),0),
                            NVL(SUM(NVL(total_txn_burdened_cost,0)),0),
                            NVL(SUM(NVL(total_txn_revenue,0)),0),
                            NVL(SUM(NVL(total_pc_raw_cost,0)),0),
                            NVL(SUM(NVL(total_pc_burdened_cost,0)),0),
                            NVL(SUM(NVL(total_pc_revenue,0)),0)
                    INTO    l_txn_rate_quantity,
                            l_txn_rate_raw_cost,
                            l_txn_rate_brdn_cost,
                            l_txn_rate_revenue,
                            l_pc_rate_raw_cost,
                            l_pc_rate_brdn_cost,
                            l_pc_rate_revenue
                    FROM pa_fp_calc_amt_tmp2
                    WHERE resource_assignment_id = l_src_res_asg_id
                    AND txn_currency_code = l_tot_currency_code_tab(i)
                    AND transaction_source_code in ('FINANCIAL_PLAN',
                                                    'WORKPLAN_RESOURCES');


                    -- IPM Change:
                    -- For non-rate-based target transactions,
                    -- if the Source is a Cost and Revenue together version,
                    -- then regardless of the Target version type:
                    --   set rate quantity to rate raw cost if it exists, OR
                    --   set rate quantity to rate revenue otherwise.
                    -- This is done to handle source planning transactions that
                    -- have only revenue amounts (without cost amounts).
                    --
                    -- For non-rate-based target transactions and other Source
                    -- version types, set rate quantity to rate raw cost as before.

                    IF l_rate_based_flag = 'N' THEN
                        IF l_source_version_type = 'ALL' THEN
                            IF nvl(l_txn_rate_raw_cost,0) = 0 THEN
                                l_txn_rate_quantity := l_txn_rate_revenue;
                            ELSE
                                l_txn_rate_quantity := l_txn_rate_raw_cost;
                            END IF;
                        ELSE
                            l_txn_rate_quantity := l_txn_rate_raw_cost;
                        END IF;
                    END IF;

                    IF l_txn_rate_quantity <> 0 THEN
                        l_txn_raw_cost_rate_tab(i) := l_txn_rate_raw_cost
                                                    / l_txn_rate_quantity;
                        l_txn_brdn_cost_rate_tab(i) := l_txn_rate_brdn_cost
                                                    / l_txn_rate_quantity;
                        l_txn_revenue_rate_tab(i) := l_txn_rate_revenue
                                                    / l_txn_rate_quantity;
                        l_pc_raw_cost_rate_tab(i) := l_pc_rate_raw_cost
                                                    / l_txn_rate_quantity;
                        l_pc_brdn_cost_rate_tab(i) := l_pc_rate_brdn_cost
                                                    / l_txn_rate_quantity;
                        l_pc_revenue_rate_tab(i) := l_pc_rate_revenue
                                                    / l_txn_rate_quantity;
                    ELSE
                        l_txn_raw_cost_rate_tab(i) := NULL;
                        l_txn_brdn_cost_rate_tab(i) := NULL;
                        l_txn_revenue_rate_tab(i) := NULL;
                        l_pc_raw_cost_rate_tab(i) := NULL;
                        l_pc_brdn_cost_rate_tab(i) := NULL;
                        l_pc_revenue_rate_tab(i) := NULL;
                    END IF;
                END LOOP;

		FOR i IN 1..l_etc_quantity_tab.count LOOP
		    l_ins_index := l_ins_src_res_asg_id_tab.count + 1;
		    l_ins_src_res_asg_id_tab(l_ins_index) := l_src_res_asg_id;
		    l_ins_tgt_res_asg_id_tab(l_ins_index) := l_tgt_res_asg_id;
		    l_ins_currency_code_tab(l_ins_index) := l_tot_currency_code_tab(i);
		    l_ins_etc_quantity_tab(l_ins_index) := l_etc_quantity_tab(i);
		    l_ins_txn_raw_cost_tab(l_ins_index) :=
		        l_etc_quantity_tab(i) * l_txn_raw_cost_rate_tab(i);
		    l_ins_txn_burdened_cost_tab(l_ins_index) :=
		        l_etc_quantity_tab(i) * l_txn_brdn_cost_rate_tab(i);
		    l_ins_txn_revenue_tab(l_ins_index) :=
		        l_etc_quantity_tab(i) * l_txn_revenue_rate_tab(i);
		    l_ins_pc_raw_cost_tab(l_ins_index) :=
		        l_etc_quantity_tab(i) * l_pc_raw_cost_rate_tab(i);
		    l_ins_pc_burdened_cost_tab(l_ins_index) :=
		        l_etc_quantity_tab(i) * l_pc_brdn_cost_rate_tab(i);
		    l_ins_pc_revenue_tab(l_ins_index) :=
		        l_etc_quantity_tab(i) * l_pc_revenue_rate_tab(i);
		    l_ins_pfc_raw_cost_tab(l_ins_index) := NULL;
		    l_ins_pfc_burdened_cost_tab(l_ins_index) := NULL;
		    l_ins_pfc_revenue_tab(l_ins_index) := NULL;
                    -- Added for Bug 5203622
                    l_ins_other_rej_code_tab(l_ins_index) := l_other_rej_code_tab(i);
		END LOOP;

            END IF;
        END IF;
        /**************NOW WE HAVE ALL ETC DATA IN TC*************/

        IF l_currency_flag = 'PC_TC' THEN
            /*Take PC for calculation, then convert back to TC.
              This only happens for non rate based resources*/

            /*No matter ETC source is 'FINANCIAL_PLAN' or 'WORKPLAN_RESOURCES',
              always get total plan amounts in PC from financial data model*/
            SELECT  /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
                    txn_currency_code,
                    SUM(NVL(total_plan_quantity,0)),
                    SUM(NVL(total_pc_raw_cost,0)),
                    SUM(NVL(total_pc_burdened_cost,0)),
                    SUM(NVL(total_pc_revenue,0))
            BULK COLLECT INTO
                    l_tot_currency_code_tab,
                    l_tot_quantity_pc_tab,
                    l_tot_raw_cost_pc_tab,
                    l_tot_brdn_cost_pc_tab,
                    l_tot_revenue_pc_tab
            FROM PA_FP_CALC_AMT_TMP2
            WHERE resource_assignment_id = l_src_res_asg_id
            AND transaction_source_code = l_etc_source_code
            GROUP BY txn_currency_code;

            -- Bug 4244609: Previously, we assigned raw cost or revenue to quantity
            -- based on Target version type. Now, we always set quantity = raw cost
            -- for non-rate-based resources.

            -- IPM Change:
            -- For non-rate-based target transactions,
            -- if the Source is a Cost and Revenue together version,
            -- then regardless of the Target version type:
            --   set target quantity to source raw cost if it exists, OR
            --   set target quantity to source revenue otherwise.
            -- This is done to handle source planning transactions that
            -- have only revenue amounts (without cost amounts).
            --
            -- For non-rate-based target transactions and other Source
            -- version types, set target quantity to source raw cost as before.

            IF l_source_version_type = 'ALL' THEN
                -- Set total quantity for each Currency depending on whether
                -- source raw cost exists (i.e. if it is a revenue-only txn).
                FOR i IN 1..l_tot_quantity_pc_tab.count LOOP
                    IF nvl(l_tot_raw_cost_pc_tab(i),0) = 0 THEN
                        l_tot_quantity_pc_tab(i) := l_tot_revenue_pc_tab(i);
                    ELSE
                        l_tot_quantity_pc_tab(i) := l_tot_raw_cost_pc_tab(i);
                    END IF;
                END LOOP;
            ELSE
                l_tot_quantity_pc_tab := l_tot_raw_cost_pc_tab;
            END IF;

            -- Added l_tot_raw_cost_pc_sum, l_tot_revenue_pc_sum for Bug 5203622
            l_tot_quantity_pc_sum := 0;
            l_tot_raw_cost_pc_sum := 0;
            l_tot_revenue_pc_sum  := 0;
            FOR i IN 1..l_tot_quantity_pc_tab.count LOOP
                l_tot_quantity_pc_sum := l_tot_quantity_pc_sum + l_tot_quantity_pc_tab(i);
                l_tot_raw_cost_pc_sum := l_tot_raw_cost_pc_sum + l_tot_raw_cost_pc_tab(i);
                l_tot_revenue_pc_sum  := l_tot_revenue_pc_sum  + l_tot_revenue_pc_tab(i);
            END LOOP;

            IF  l_etc_source_code = 'FINANCIAL_PLAN' THEN
                SELECT  /*+ INDEX(PA_FP_FCST_GEN_TMP1,PA_FP_FCST_GEN_TMP1_N1)*/
                        NVL(SUM( DECODE(l_rate_based_flag,
                        'Y', NVL(quantity,0),
                        'N', NVL(prj_raw_cost,0))),0),
                        NVL(SUM(NVL(prj_raw_cost,0)),0)
                INTO    l_act_quantity_pc_sum,
                        l_act_raw_cost_pc_sum  -- Added for Bug 5203622
                FROM PA_FP_FCST_GEN_TMP1
                WHERE project_element_id = l_curr_task_id
                AND res_list_member_id = l_resource_list_member_id
                AND data_type_code = 'ETC_FP';

            ELSIF l_etc_source_code = 'WORKPLAN_RESOURCES' THEN
                /*Workplan side only stores amounts in one currency for each planning
                  resource, so still rely on pa_progress_utils.get_actuals_for_task to
                  get actuals data. This part needs to be revisted when workplan side is
                  changed to support multi currencies.*/
                IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug(
                        p_msg         => 'Before calling PA_FP_GEN_FCST_AMT_PUB1.'||
                                        'GET_WP_ACTUALS_FOR_RA',
                        p_module_name => l_module_name,
                        p_log_level   => 5);
                END IF;
                PA_FP_GEN_FCST_AMT_PUB1.GET_WP_ACTUALS_FOR_RA
                   (P_FP_COLS_SRC_REC        => l_fp_cols_src_rec,
                    P_FP_COLS_TGT_REC        => p_fp_cols_tgt_rec,
                    P_SRC_RES_ASG_ID         => l_src_res_asg_id,
                    P_TASK_ID                => l_curr_task_id,
                    P_RES_LIST_MEM_ID        => l_resource_list_member_id,
                    P_ACTUALS_THRU_DATE      => p_actuals_thru_date,
                    X_ACT_QUANTITY           => lx_act_quantity,
                    X_ACT_TXN_CURRENCY_CODE  => lx_act_txn_currency_code,
                    X_ACT_TXN_RAW_COST       => lx_act_txn_raw_cost,
                    X_ACT_TXN_BRDN_COST      => lx_act_txn_brdn_cost,
                    X_ACT_PC_RAW_COST        => lx_act_pc_raw_cost,
                    X_ACT_PC_BRDN_COST       => lx_act_pc_brdn_cost,
                    X_ACT_PFC_RAW_COST       => lx_act_pfc_raw_cost,
                    X_ACT_PFC_BRDN_COST      => lx_act_pfc_brdn_cost,
                    X_RETURN_STATUS          => x_return_status,
                    X_MSG_COUNT              => x_msg_count,
                    X_MSG_DATA               => x_msg_data );
                IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug(
                        p_msg         => 'After calling PA_FP_GEN_FCST_AMT_PUB1.'||
                                         'GET_WP_ACTUALS_FOR_RA in remain_bdgt:'||x_return_status,
                        p_module_name => l_module_name,
                        p_log_level   => 5);
                END IF;
                IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

                l_act_quantity_pc_sum :=  lx_act_pc_raw_cost;
                l_act_raw_cost_pc_sum :=  lx_act_pc_raw_cost; -- Added for Bug 5203622
            END IF;

            /*Prorate total ETC quantity in PC based according to the transaction
              currency codes from the plan totals.*/
            /*Get total ETC quantity and Prorate ETC quantity*/
            l_etc_quantity_pc_sum := l_tot_quantity_pc_sum - l_act_quantity_pc_sum;
            -- ER 5726773: Instead of directly checking if (ETC <= 0), let the
	    -- plan_etc_signs_match function decide if ETC should be generated.
	    IF NOT pa_fp_fcst_gen_amt_utils.PLAN_ETC_SIGNS_MATCH
 	                  (l_tot_quantity_pc_sum, l_etc_quantity_pc_sum) THEN
 	    /* only need to spread commitment data and actual data*/
                RAISE continue_loop;
            END IF;

            -- Bug 5203622: Added OTHER REJECTION CODE logic.
            l_other_rej_code := null;
            IF l_rate_based_flag = 'N' AND
               l_source_version_type = 'ALL' AND
               l_target_version_type = 'ALL' AND
               nvl(l_tot_raw_cost_pc_sum,0) = 0 AND
               nvl(l_tot_revenue_pc_sum,0) <> 0 AND
               nvl(l_act_raw_cost_pc_sum,0) <> 0 THEN
                l_other_rej_code := 'PA_FP_ETC_REV_FIELD_ERR';
            END IF;

            FOR i IN 1..l_tot_currency_code_tab.count LOOP
                IF NVL(l_tot_quantity_pc_sum,0) <> 0 THEN
                   l_etc_quantity_pc_tab(i) := l_etc_quantity_pc_sum
                       * (l_tot_quantity_pc_tab(i) / l_tot_quantity_pc_sum) ;
                ELSE
                   l_etc_quantity_pc_tab(i) := NULL;
                   --l_etc_quantity_pc_tab(i) := l_etc_quantity_pc_sum; -- ???
                END IF;
                -- Added for Bug 5203622
                l_other_rej_code_tab(i) := l_other_rej_code;
            END LOOP;

            /* Convert PC into TC */
            FOR i IN 1..l_tot_currency_code_tab.count LOOP
                IF l_tot_currency_code_tab(i) = l_pc_currency_code THEN
                    l_etc_quantity_tab(i) := l_etc_quantity_pc_tab(i);
                ELSE
                    l_etc_quantity_tab(i) := NULL;
                    BEGIN
                        SELECT task_id,
                               planning_start_date
                        INTO l_task_id,
                             l_planning_start_date
                        FROM pa_resource_assignments
                        WHERE resource_assignment_id = l_src_res_asg_id;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            l_task_id := NULL;
                            l_planning_start_date := NULL;
                    END;
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_fp_gen_amount_utils.fp_debug(
                            p_msg         => 'Before calling pa_multi_currency_txn.'||
                                             'get_currency_amounts in remain_bdgt',
                            p_module_name => l_module_name,
                            p_log_level   => 5);
                    END IF;
                    -- Bug 4091344: Changed P_status parameter from x_return_status to
                    -- local variable l_status. Afterwards, we check l_status and set
                    -- x_return_status accordingly.
                    pa_multi_currency_txn.get_currency_amounts (
                        P_project_id        => p_fp_cols_tgt_rec.x_project_id,
                        P_exp_org_id        => NULL,
                        P_calling_module    => 'WORKPLAN',
                        P_task_id           => l_task_id,
                        P_EI_date           => l_planning_start_date,
                        P_denom_raw_cost    => l_etc_quantity_pc_tab(i),
                        P_denom_curr_code   => l_pc_currency_code,
                        P_acct_curr_code    => l_pc_currency_code,
                        P_accounted_flag    => 'N',
                        P_acct_rate_date    => lx_acc_rate_date,
                        P_acct_rate_type    => lx_acct_rate_type,
                        P_acct_exch_rate    => lx_acct_exch_rate,
                        P_acct_raw_cost     => lx_acct_raw_cost,
                        P_project_curr_code => l_tot_currency_code_tab(i),
                        P_project_rate_type => lx_project_rate_type,
                        P_project_rate_date => lx_project_rate_date,
                        P_project_exch_rate => lx_project_exch_rate,
                        P_project_raw_cost  => l_etc_quantity_tab(i),
                        P_projfunc_curr_code=> l_pc_currency_code,
                        P_projfunc_cost_rate_type   => lx_projfunc_cost_rate_type,
                        P_projfunc_cost_rate_date   => lx_projfunc_cost_rate_date,
                        P_projfunc_cost_exch_rate   => lx_projfunc_cost_exch_rate,
                        P_projfunc_raw_cost => l_projfunc_raw_cost,
                        P_system_linkage    => 'NER',
                        P_status            => l_status,
                        P_stage             => x_msg_count);


                    IF lx_project_exch_rate IS NULL OR l_status IS NOT NULL THEN
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        g_project_name := NULL;
                        BEGIN
                           SELECT name INTO g_project_name from
                           PA_PROJECTS_ALL WHERE
                           project_id = p_fp_cols_tgt_rec.x_project_id;
                        EXCEPTION
                        WHEN OTHERS THEN
                             g_project_name := NULL;
                        END;
                        PA_UTILS.ADD_MESSAGE
                            ( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_FP_PROJ_NO_TXNCONVRATE'
                              ,p_token1         => 'G_PROJECT_NAME'
                              ,p_value1         => g_project_name
                              ,p_token2         => 'FROMCURRENCY'
                              ,p_value2         => l_pc_currency_code
                              ,p_token3         => 'TOCURRENCY'
                              ,p_value3         => l_tot_currency_code_tab(i) );
                         x_msg_data := 'PA_FP_PROJ_NO_TXNCONVRATE';
                    END IF;
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_fp_gen_amount_utils.fp_debug(
                            p_msg         => 'After calling pa_multi_currency_txn.'||
                                             'get_currency_amounts in remain_bdgt:'||x_return_status,
                            p_module_name => l_module_name,
                            p_log_level   => 5);
                    END IF;
                    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;
                END IF;
            END LOOP;

            /*When not taking periodic rates, we need to calculate out the average rates
              from the source resource assignments that are mapped to the current target
              resource assignment.*/

            FOR i IN 1..l_tot_currency_code_tab.count LOOP
                SELECT  /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
                        NVL(SUM(NVL(total_plan_quantity,0)),0),
                        NVL(SUM(NVL(total_txn_raw_cost,0)),0),
                        NVL(SUM(NVL(total_txn_burdened_cost,0)),0),
                        NVL(SUM(NVL(total_txn_revenue,0)),0),
                        NVL(SUM(NVL(total_pc_raw_cost,0)),0),
                        NVL(SUM(NVL(total_pc_burdened_cost,0)),0),
                        NVL(SUM(NVL(total_pc_revenue,0)),0)
                INTO    l_txn_rate_quantity,
                        l_txn_rate_raw_cost,
                        l_txn_rate_brdn_cost,
                        l_txn_rate_revenue,
                        l_pc_rate_raw_cost,
                        l_pc_rate_brdn_cost,
                        l_pc_rate_revenue
                FROM pa_fp_calc_amt_tmp2
                WHERE resource_assignment_id = l_src_res_asg_id
                AND txn_currency_code = l_tot_currency_code_tab(i)
                AND transaction_source_code in ('FINANCIAL_PLAN' ,
                                                'WORKPLAN_RESOURCES');

                -- IPM Change:
                -- For non-rate-based target transactions,
                -- if the Source is a Cost and Revenue together version,
                -- then regardless of the Target version type:
                --   set rate quantity to rate raw cost if it exists, OR
                --   set rate quantity to rate revenue otherwise.
                -- This is done to handle source planning transactions that
                -- have only revenue amounts (without cost amounts).
                --
                -- For non-rate-based target transactions and other Source
                -- version types, set rate quantity to rate raw cost as before.

                IF l_source_version_type = 'ALL' THEN
                    IF nvl(l_txn_rate_raw_cost,0) = 0 THEN
                        l_txn_rate_quantity := l_txn_rate_revenue;
                    ELSE
                        l_txn_rate_quantity := l_txn_rate_raw_cost;
                    END IF;
                ELSE
                    l_txn_rate_quantity := l_txn_rate_raw_cost;
                END IF;

                -- IPM Change:
                -- Since quantity can now be either raw cost or revenue,
                -- rates should not always be computed by dividing by raw
                -- cost. Code modified to use l_txn_rate_quantity instead.
                IF l_txn_rate_quantity <> 0 THEN
                    l_txn_raw_cost_rate_tab(i) := l_txn_rate_raw_cost
                                                  / l_txn_rate_quantity; -- Added in IPM
                    l_txn_brdn_cost_rate_tab(i) := l_txn_rate_brdn_cost
                                                  / l_txn_rate_quantity;
                    l_txn_revenue_rate_tab(i) := l_txn_rate_revenue
                                                  / l_txn_rate_quantity;
                    l_pc_raw_cost_rate_tab(i) := l_pc_rate_raw_cost
                                                / l_txn_rate_quantity;
                    l_pc_brdn_cost_rate_tab(i) := l_pc_rate_brdn_cost
                                                / l_txn_rate_quantity;
                    l_pc_revenue_rate_tab(i) := l_pc_rate_revenue
                                                / l_txn_rate_quantity;
                ELSE
                    l_txn_raw_cost_rate_tab(i) := NULL; -- Added in IPM
                    l_txn_brdn_cost_rate_tab(i) := NULL;
                    l_txn_revenue_rate_tab(i) := NULL;
                    l_pc_raw_cost_rate_tab(i) := NULL;
                    l_pc_brdn_cost_rate_tab(i) := NULL;
                    l_pc_revenue_rate_tab(i) := NULL;
                END IF;
            END LOOP;

            FOR i IN 1..l_etc_quantity_tab.count LOOP
                l_ins_index := l_ins_src_res_asg_id_tab.count + 1;
                l_ins_src_res_asg_id_tab(l_ins_index) := l_src_res_asg_id;
                l_ins_tgt_res_asg_id_tab(l_ins_index) := l_tgt_res_asg_id;
                l_ins_currency_code_tab(l_ins_index) := l_tot_currency_code_tab(i);
                l_ins_etc_quantity_tab(l_ins_index) := l_etc_quantity_tab(i);
                l_ins_txn_raw_cost_tab(l_ins_index) :=
                    l_etc_quantity_tab(i) * l_txn_raw_cost_rate_tab(i);
                l_ins_txn_burdened_cost_tab(l_ins_index) :=
                    l_etc_quantity_tab(i) * l_txn_brdn_cost_rate_tab(i);
                l_ins_txn_revenue_tab(l_ins_index) :=
                    l_etc_quantity_tab(i) * l_txn_revenue_rate_tab(i);
                l_ins_pc_raw_cost_tab(l_ins_index) :=
                    l_etc_quantity_tab(i) * l_pc_raw_cost_rate_tab(i);
                l_ins_pc_burdened_cost_tab(l_ins_index) :=
                    l_etc_quantity_tab(i) * l_pc_brdn_cost_rate_tab(i);
                l_ins_pc_revenue_tab(l_ins_index) :=
                    l_etc_quantity_tab(i) * l_pc_revenue_rate_tab(i);
                l_ins_pfc_raw_cost_tab(l_ins_index) := NULL;
                l_ins_pfc_burdened_cost_tab(l_ins_index) := NULL;
                l_ins_pfc_revenue_tab(l_ins_index) := NULL;
                -- Added for Bug 5203622
                l_ins_other_rej_code_tab(l_ins_index) := l_other_rej_code_tab(i);
            END LOOP;

        /***************NOW WE HAVE ALL ETC DATA IN PC_TC*************/

        END IF;
        /* End the check for 'PC', 'TC' and 'PC_TC'*/

    EXCEPTION
        WHEN CONTINUE_LOOP THEN
            l_dummy := 1;
        WHEN OTHERS THEN
            RAISE;
    END;
    END LOOP; -- main loop

    /* If commitment is not included, record is inserted directly as 'ETC'
       record,if commitment is to be considered, record is inserted as
       'TOTAL_ETC' for further processing.*/
    IF P_FP_COLS_TGT_REC.X_GEN_INCL_OPEN_COMM_FLAG = 'Y' THEN
        l_transaction_source_code := 'TOTAL_ETC';
    ELSE
        l_transaction_source_code := 'ETC';
    END IF;

    -- Bug 5203622: Store OTHER rejection code in the
    -- txn_currency_code column of pa_fp_calc_amt_tmp2.
    FORALL i IN 1..l_ins_etc_quantity_tab.count
        INSERT INTO PA_FP_CALC_AMT_TMP2
               ( RESOURCE_ASSIGNMENT_ID,
                 TARGET_RES_ASG_ID,
                 ETC_CURRENCY_CODE,
                 ETC_PLAN_QUANTITY,
                 ETC_TXN_RAW_COST,
                 ETC_TXN_BURDENED_COST,
                 ETC_TXN_REVENUE,
                 ETC_PC_RAW_COST,
                 ETC_PC_BURDENED_COST,
                 ETC_PC_REVENUE,
                 ETC_PFC_RAW_COST,
                 ETC_PFC_BURDENED_COST,
                 ETC_PFC_REVENUE,
                 TRANSACTION_SOURCE_CODE,
                 TXN_CURRENCY_CODE ) -- Added for Bug 5203622
        VALUES ( l_ins_src_res_asg_id_tab(i),
                 l_ins_tgt_res_asg_id_tab(i),
                 l_ins_currency_code_tab(i),
                 l_ins_etc_quantity_tab(i),
                 l_ins_txn_raw_cost_tab(i),
                 l_ins_txn_burdened_cost_tab(i),
                 l_ins_txn_revenue_tab(i),
                 l_ins_pc_raw_cost_tab(i),
                 l_ins_pc_burdened_cost_tab(i),
                 l_ins_pc_revenue_tab(i),
                 l_ins_pfc_raw_cost_tab(i),
                 l_ins_pfc_burdened_cost_tab(i),
                 l_ins_pfc_revenue_tab(i),
                 l_transaction_source_code,
                 l_ins_other_rej_code_tab(i) ); -- Added for Bug 5203622

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
               (p_msg         => 'Invalid Arguments Passed',
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
        --dbms_output.put_line('error msg :'||x_msg_data);
        FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_GEN_FCST_AMT_PUB3',
                     p_procedure_name  => 'GEN_ETC_REMAIN_BDGT_AMTS_BLK',
                     p_error_text      => substr(sqlerrm,1,240));

        IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                p_module_name => l_module_name,
                p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END GET_ETC_REMAIN_BDGT_AMTS_BLK;

-- gboomina added for AAI Requirement bug 8318932 - start
/* AAI Enhancement
    * This method is meant to get the periodic budget lines from the source and
    * create the same in destination and then update the intermediate tmp2 with
    * the etc values.
    * The processing in this api happens in phases in first phase we direclty
    * copy the budgetlines  from the source plan if the time phase match and
    * in second phase we distribute or club the amounts based on the time phases
    * of source and destination.
    */
   PROCEDURE GET_ETC_FROM_SRC_BDGT
             (P_FP_COLS_SRC_FP_REC                                                                IN PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
              P_FP_COLS_SRC_WP_REC                                                                IN PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
              P_FP_COLS_TGT_REC                                                                        IN PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
              P_ACTUALS_THRU_DATE                                                                 IN PA_PERIODS_ALL.END_DATE%TYPE,
              X_RETURN_STATUS                                                                                OUT  NOCOPY VARCHAR2,
              X_MSG_COUNT                                                                                                OUT  NOCOPY NUMBER,
              X_MSG_DATA                                                                           OUT  NOCOPY VARCHAR2)
   IS


     l_module_name  VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_FCST_AMT_PUB3.GET_ETC_FROM_SRC_BDGT';
           l_txn_currency_flag                    varchar2(1) := 'Y';

     -- Cursor For fully coping budget lines from source.
           CURSOR fcst_budget_line_src_tgt_all
                                                                   (c_proj_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE,
                   c_projfunc_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE,
                   c_target_bv_id NUMBER,
                   c_project_id   NUMBER ) IS
      SELECT  ra.resource_assignment_id,
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
              NULL,
              NULL
       FROM PA_FP_CALC_AMT_TMP2 tmp4,
            pa_budget_lines sbl,
            pa_resource_assignments ra
       WHERE tmp4.resource_assignment_id = sbl.resource_assignment_id
           and (tmp4.TRANSACTION_SOURCE_CODE = 'WORKPLAN_RESOURCES' OR
                tmp4.TRANSACTION_SOURCE_CODE = 'FINANCIAL_PLAN')
         and tmp4.TARGET_RES_ASG_ID = ra.resource_assignment_id
         and ra.budget_version_id = c_target_bv_id
         and sbl.end_date > P_ACTUALS_THRU_DATE
         and sbl.cost_rejection_code is null
         and sbl.burden_rejection_code is null
         and sbl.other_rejection_code is null
         and sbl.pc_cur_conv_rejection_code is null
         and sbl.pfc_cur_conv_rejection_code is null
         and ra.project_id = c_project_id
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
                NULL;

     -- This cursor is used to copy budget lines when one of the source has same time phase.
     CURSOR fcst_budget_line_src_tgt_ptl
                                                                   (c_proj_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE,
                   c_projfunc_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE,
                   c_target_bv_id NUMBER,
                   c_project_id   NUMBER,
                   c_gen_source VARCHAR2 ) IS
      SELECT  ra.resource_assignment_id,
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
              NULL,
              NULL
       FROM PA_FP_CALC_AMT_TMP2 tmp4,
            pa_budget_lines sbl,
            pa_resource_assignments ra
       WHERE tmp4.resource_assignment_id = sbl.resource_assignment_id
         and tmp4.TRANSACTION_SOURCE_CODE = c_gen_source
         and tmp4.TARGET_RES_ASG_ID = ra.resource_assignment_id
         and ra.budget_version_id = c_target_bv_id
         and sbl.end_date > P_ACTUALS_THRU_DATE
         and sbl.cost_rejection_code is null
         and sbl.burden_rejection_code is null
         and sbl.other_rejection_code is null
         and sbl.pc_cur_conv_rejection_code is null
         and sbl.pfc_cur_conv_rejection_code is null
         and ra.project_id = c_project_id
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
                NULL;

     -- This cursor will summ the budget lines when the source time phase is diff and source period span is
     -- smaller than destination based on the one of the plans which has issue.
     CURSOR fcst_bdgt_line_src_tgt_sum
                                                                   (c_proj_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE,
                   c_projfunc_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE,
                   c_target_bv_id NUMBER,
                   c_project_id   NUMBER,
                   c_time_phase VARCHAR2 ) IS
      SELECT  ra.resource_assignment_id,
              ra.rate_based_flag,
              decode(c_time_phase,'G',pa_gl.PA_START_DATE,'P',pa_gl.GL_START_DATE),
              decode(c_time_phase,'G',pa_gl.PA_END_DATE,'P',pa_gl.GL_END_DATE),
              decode(c_time_phase,'G',pa_gl.PA_PERIOD_NAME,'P',pa_gl.GL_PERIOD_NAME),
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
              NULL,
              NULL
       FROM PA_FP_CALC_AMT_TMP2 tmp4,
            pa_budget_lines sbl,
            pa_resource_assignments ra,
            PA_GL_PA_PERIODS_TMP pa_gl
       WHERE tmp4.resource_assignment_id = sbl.resource_assignment_id
         and (tmp4.TRANSACTION_SOURCE_CODE = 'WORKPLAN_RESOURCES' OR
                tmp4.TRANSACTION_SOURCE_CODE = 'FINANCIAL_PLAN')
         and tmp4.TARGET_RES_ASG_ID = ra.resource_assignment_id
         and ra.budget_version_id = c_target_bv_id
         and sbl.end_date > P_ACTUALS_THRU_DATE
         and sbl.period_name = decode(c_time_phase,'P',pa_gl.PA_PERIOD_NAME,'G',pa_gl.GL_PERIOD_NAME)
         and sbl.start_date = decode(c_time_phase,'P',pa_gl.PA_START_DATE,'G',pa_gl.GL_START_DATE)
         and sbl.cost_rejection_code is null
         and sbl.burden_rejection_code is null
         and sbl.other_rejection_code is null
         and sbl.pc_cur_conv_rejection_code is null
         and sbl.pfc_cur_conv_rejection_code is null
         and ra.project_id = c_project_id
       GROUP BY ra.resource_assignment_id,
                ra.rate_based_flag,
                decode(c_time_phase,'G',pa_gl.PA_START_DATE,'P',pa_gl.GL_START_DATE),
                    decode(c_time_phase,'G',pa_gl.PA_END_DATE,'P',pa_gl.GL_END_DATE),
                    decode(c_time_phase,'G',pa_gl.PA_PERIOD_NAME,'P',pa_gl.GL_PERIOD_NAME),
                decode(l_txn_currency_flag,
                    'Y', sbl.txn_currency_code,
                    'N', c_proj_currency_code,
                    'A', c_projfunc_currency_code),
                NULL,
                NULL;

     -- This cursor will summ the budget lines when the source time phase is diff and source period span is
     -- smaller than destination based on the one of the plans which has issue.
     CURSOR fcst_bdgt_line_src_tgt_sum_ptl
                                                                   (c_proj_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE,
                   c_projfunc_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE,
                   c_target_bv_id NUMBER,
                   c_project_id   NUMBER,
                   c_gen_source VARCHAR2,
                   c_time_phase VARCHAR2 ) IS
      SELECT  ra.resource_assignment_id,
              ra.rate_based_flag,
              decode(c_time_phase,'G',pa_gl.PA_START_DATE,'P',pa_gl.GL_START_DATE),
              decode(c_time_phase,'G',pa_gl.PA_END_DATE,'P',pa_gl.GL_END_DATE),
              decode(c_time_phase,'G',pa_gl.PA_PERIOD_NAME,'P',pa_gl.GL_PERIOD_NAME),
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
              NULL,
              NULL
       FROM PA_FP_CALC_AMT_TMP2 tmp4,
            pa_budget_lines sbl,
            pa_resource_assignments ra,
            PA_GL_PA_PERIODS_TMP pa_gl
       WHERE tmp4.resource_assignment_id = sbl.resource_assignment_id
         and tmp4.TRANSACTION_SOURCE_CODE = c_gen_source
         and tmp4.TARGET_RES_ASG_ID = ra.resource_assignment_id
         and ra.budget_version_id = c_target_bv_id
         and sbl.end_date > P_ACTUALS_THRU_DATE
         and sbl.period_name = decode(c_time_phase,'P',pa_gl.PA_PERIOD_NAME,'G',pa_gl.GL_PERIOD_NAME)
         and sbl.start_date = decode(c_time_phase,'P',pa_gl.PA_START_DATE,'G',pa_gl.GL_START_DATE)
         and sbl.cost_rejection_code is null
         and sbl.burden_rejection_code is null
         and sbl.other_rejection_code is null
         and sbl.pc_cur_conv_rejection_code is null
         and sbl.pfc_cur_conv_rejection_code is null
         and ra.project_id = c_project_id
       GROUP BY ra.resource_assignment_id,
                ra.rate_based_flag,
                decode(c_time_phase,'G',pa_gl.PA_START_DATE,'P',pa_gl.GL_START_DATE),
                    decode(c_time_phase,'G',pa_gl.PA_END_DATE,'P',pa_gl.GL_END_DATE),
                    decode(c_time_phase,'G',pa_gl.PA_PERIOD_NAME,'P',pa_gl.GL_PERIOD_NAME),
                decode(l_txn_currency_flag,
                    'Y', sbl.txn_currency_code,
                    'N', c_proj_currency_code,
                    'A', c_projfunc_currency_code),
                NULL,
                NULL;


     -- This cursor will distribute the source budget amounts into the destination budget lines uniformly such
     -- destinations end periods fall in the source period span when source period span is greater than dest.
     CURSOR fcst_bdgt_line_src_tgt_dist
                                                                   (c_proj_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE,
                   c_projfunc_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE,
                   c_target_bv_id NUMBER,
                   c_project_id   NUMBER,
                   c_time_phase VARCHAR2 ) IS
      SELECT  ra.resource_assignment_id,
              ra.rate_based_flag,
              decode(c_time_phase,'G',pa_gl.PA_START_DATE,'P',pa_gl.GL_START_DATE),
              decode(c_time_phase,'G',pa_gl.PA_END_DATE,'P',pa_gl.GL_END_DATE),
              decode(c_time_phase,'G',pa_gl.PA_PERIOD_NAME,'P',pa_gl.GL_PERIOD_NAME),
              decode(l_txn_currency_flag,
                    'Y', sbl.txn_currency_code,
                    'N', c_proj_currency_code,
                    'A', c_projfunc_currency_code),
              sum((sbl.quantity)/pa_gl.multiplier),
              sum((decode(l_txn_currency_flag,
                         'Y', sbl.txn_raw_cost,
                         'N', sbl.project_raw_cost,
                         'A', sbl.raw_cost))/pa_gl.multiplier),
              sum((decode(l_txn_currency_flag,
                         'Y', sbl.txn_burdened_cost,
                         'N', sbl.project_burdened_cost,
                         'A', sbl.burdened_cost))/pa_gl.multiplier),
              sum((decode(l_txn_currency_flag,
                         'Y', sbl.quantity *
                              NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate),   --sbl.txn_raw_cost
                         'N', sbl.quantity * NVL(sbl.project_cost_exchange_rate,1) *
                              NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate),   --sbl.project_raw_cost
                         'A', sbl.quantity * NVL(sbl.projfunc_cost_exchange_rate,1) *
                              NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate)))/pa_gl.multiplier), --sbl.raw_cost
              sum((decode(l_txn_currency_flag,
                         'Y', sbl.quantity *
                              NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate),   --sbl.txn_burdened_cost
                         'N', sbl.quantity * NVL(sbl.project_cost_exchange_rate,1) *
                              NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate),   --sbl.project_burdened_cost
                         'A', sbl.quantity * NVL(sbl.projfunc_cost_exchange_rate,1) *
                              NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate)))/pa_gl.multiplier), --sbl.burdened_cost
              NULL,
              NULL
       FROM PA_FP_CALC_AMT_TMP2 tmp4,
            pa_budget_lines sbl,
            pa_resource_assignments ra,
            PA_GL_PA_PERIODS_TMP pa_gl
       WHERE tmp4.resource_assignment_id = sbl.resource_assignment_id
         and (tmp4.TRANSACTION_SOURCE_CODE = 'WORKPLAN_RESOURCES' OR
                tmp4.TRANSACTION_SOURCE_CODE = 'FINANCIAL_PLAN')
         and tmp4.TARGET_RES_ASG_ID = ra.resource_assignment_id
         and ra.budget_version_id = c_target_bv_id
         and sbl.end_date > P_ACTUALS_THRU_DATE
         and sbl.period_name = decode(c_time_phase,'P',pa_gl.PA_PERIOD_NAME,'G',pa_gl.GL_PERIOD_NAME)
         and sbl.start_date = decode(c_time_phase,'P',pa_gl.PA_START_DATE,'G',pa_gl.GL_START_DATE)
         and sbl.cost_rejection_code is null
         and sbl.burden_rejection_code is null
         and sbl.other_rejection_code is null
         and sbl.pc_cur_conv_rejection_code is null
         and sbl.pfc_cur_conv_rejection_code is null
         and ra.project_id = c_project_id
       GROUP BY ra.resource_assignment_id,
                ra.rate_based_flag,
                decode(c_time_phase,'G',pa_gl.PA_START_DATE,'P',pa_gl.GL_START_DATE),
                    decode(c_time_phase,'G',pa_gl.PA_END_DATE,'P',pa_gl.GL_END_DATE),
                    decode(c_time_phase,'G',pa_gl.PA_PERIOD_NAME,'P',pa_gl.GL_PERIOD_NAME),
                decode(l_txn_currency_flag,
                    'Y', sbl.txn_currency_code,
                    'N', c_proj_currency_code,
                    'A', c_projfunc_currency_code),
                NULL,
                NULL;

     -- This cursor will distribute the source budget amounts into the destination budget lines uniformly such
     -- destinations end periods fall in the source period span when source period span is greater than dest.
     CURSOR fcst_bdgt_line_src_tgt_dist_pt
                                                                   (c_proj_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE,
                   c_projfunc_currency_code PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE,
                   c_target_bv_id NUMBER,
                   c_project_id   NUMBER,
                   c_gen_source VARCHAR2,
                   c_time_phase VARCHAR2 ) IS
      SELECT  ra.resource_assignment_id,
              ra.rate_based_flag,
              decode(c_time_phase,'G',pa_gl.PA_START_DATE,'P',pa_gl.GL_START_DATE),
              decode(c_time_phase,'G',pa_gl.PA_END_DATE,'P',pa_gl.GL_END_DATE),
              decode(c_time_phase,'G',pa_gl.PA_PERIOD_NAME,'P',pa_gl.GL_PERIOD_NAME),
              decode(l_txn_currency_flag,
                    'Y', sbl.txn_currency_code,
                    'N', c_proj_currency_code,
                    'A', c_projfunc_currency_code),
              sum((sbl.quantity)/pa_gl.multiplier),
              sum((decode(l_txn_currency_flag,
                         'Y', sbl.txn_raw_cost,
                         'N', sbl.project_raw_cost,
                         'A', sbl.raw_cost))/pa_gl.multiplier),
              sum((decode(l_txn_currency_flag,
                         'Y', sbl.txn_burdened_cost,
                         'N', sbl.project_burdened_cost,
                         'A', sbl.burdened_cost))/pa_gl.multiplier),
              sum((decode(l_txn_currency_flag,
                         'Y', sbl.quantity *
                              NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate),   --sbl.txn_raw_cost
                         'N', sbl.quantity * NVL(sbl.project_cost_exchange_rate,1) *
                              NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate),   --sbl.project_raw_cost
                         'A', sbl.quantity * NVL(sbl.projfunc_cost_exchange_rate,1) *
                              NVL(sbl.txn_cost_rate_override,sbl.txn_standard_cost_rate)))/pa_gl.multiplier), --sbl.raw_cost
              sum((decode(l_txn_currency_flag,
                         'Y', sbl.quantity *
                              NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate),   --sbl.txn_burdened_cost
                         'N', sbl.quantity * NVL(sbl.project_cost_exchange_rate,1) *
                              NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate),   --sbl.project_burdened_cost
                         'A', sbl.quantity * NVL(sbl.projfunc_cost_exchange_rate,1) *
                              NVL(sbl.burden_cost_rate_override,sbl.burden_cost_rate)))/pa_gl.multiplier), --sbl.burdened_cost
              NULL,
              NULL
       FROM PA_FP_CALC_AMT_TMP2 tmp4,
            pa_budget_lines sbl,
            pa_resource_assignments ra,
            PA_GL_PA_PERIODS_TMP pa_gl
       WHERE tmp4.resource_assignment_id = sbl.resource_assignment_id
         and tmp4.TRANSACTION_SOURCE_CODE = c_gen_source
         and tmp4.TARGET_RES_ASG_ID = ra.resource_assignment_id
         and ra.budget_version_id = c_target_bv_id
         and sbl.end_date > P_ACTUALS_THRU_DATE
         and sbl.period_name = decode(c_time_phase,'P',pa_gl.PA_PERIOD_NAME,'G',pa_gl.GL_PERIOD_NAME)
         and sbl.start_date = decode(c_time_phase,'P',pa_gl.PA_START_DATE,'G',pa_gl.GL_START_DATE)
         and sbl.cost_rejection_code is null
         and sbl.burden_rejection_code is null
         and sbl.other_rejection_code is null
         and sbl.pc_cur_conv_rejection_code is null
         and sbl.pfc_cur_conv_rejection_code is null
         and ra.project_id = c_project_id
       GROUP BY ra.resource_assignment_id,
                ra.rate_based_flag,
                decode(c_time_phase,'G',pa_gl.PA_START_DATE,'P',pa_gl.GL_START_DATE),
                    decode(c_time_phase,'G',pa_gl.PA_END_DATE,'P',pa_gl.GL_END_DATE),
                    decode(c_time_phase,'G',pa_gl.PA_PERIOD_NAME,'P',pa_gl.GL_PERIOD_NAME),
                decode(l_txn_currency_flag,
                    'Y', sbl.txn_currency_code,
                    'N', c_proj_currency_code,
                    'A', c_projfunc_currency_code),
                NULL,
                NULL;

     l_tgt_res_asg_id_tab                      pa_plsql_datatypes.IdTabTyp;
     l_tgt_rate_based_flag_tab                 pa_plsql_datatypes.Char15TabTyp;
     l_start_date_tab                          pa_plsql_datatypes.DateTabTyp;
     l_txn_currency_code_tab                   pa_plsql_datatypes.Char15TabTyp;
     l_end_date_tab                            pa_plsql_datatypes.DateTabTyp;
     l_period_name_tab                         pa_plsql_datatypes.Char30TabTyp;
     l_src_quantity_tab                        pa_plsql_datatypes.NumTabTyp;
     l_txn_raw_cost_tab                        pa_plsql_datatypes.NumTabTyp;
     l_txn_brdn_cost_tab                       pa_plsql_datatypes.NumTabTyp;
     l_unround_txn_raw_cost_tab                pa_plsql_datatypes.NumTabTyp;
     l_unround_txn_brdn_cost_tab               pa_plsql_datatypes.NumTabTyp;
     l_pfc_brdn_cost_tab                       pa_plsql_datatypes.NumTabTyp;
     l_pfc_raw_cost_tab                        pa_plsql_datatypes.NumTabTyp;
     l_pc_brdn_cost_tab                        pa_plsql_datatypes.NumTabTyp;
     l_pc_raw_cost_tab                         pa_plsql_datatypes.NumTabTyp;
     l_cost_rate_override_tab                  pa_plsql_datatypes.NumTabTyp;
     l_b_cost_rate_override_tab                pa_plsql_datatypes.NumTabTyp;

     -- Used to store partial
     l_pr_tgt_res_asg_id_tab               pa_plsql_datatypes.IdTabTyp;
     l_pr_tgt_rate_based_flag_tab          pa_plsql_datatypes.Char15TabTyp;
     l_pr_start_date_tab                   pa_plsql_datatypes.DateTabTyp;
     l_pr_txn_currency_code_tab            pa_plsql_datatypes.Char15TabTyp;
     l_pr_end_date_tab                     pa_plsql_datatypes.DateTabTyp;
     l_pr_period_name_tab                          pa_plsql_datatypes.Char30TabTyp;
     l_pr_src_quantity_tab                 pa_plsql_datatypes.NumTabTyp;
     l_pr_txn_raw_cost_tab                 pa_plsql_datatypes.NumTabTyp;
     l_pr_txn_brdn_cost_tab                pa_plsql_datatypes.NumTabTyp;
     l_pr_unround_txn_raw_cost_tab                 pa_plsql_datatypes.NumTabTyp;
     l_pr_unround_txn_brdn_cost_tab                pa_plsql_datatypes.NumTabTyp;
     l_pr_pfc_brdn_cost_tab                pa_plsql_datatypes.NumTabTyp;
     l_pr_pfc_raw_cost_tab                 pa_plsql_datatypes.NumTabTyp;
     l_pr_pc_brdn_cost_tab                 pa_plsql_datatypes.NumTabTyp;
     l_pr_pc_raw_cost_tab                  pa_plsql_datatypes.NumTabTyp;
     l_pr_cost_rate_override_tab           pa_plsql_datatypes.NumTabTyp;
     l_pr_b_cost_rate_override_tab         pa_plsql_datatypes.NumTabTyp;



     l_last_updated_by                     PA_RESOURCE_ASSIGNMENTS.LAST_UPDATED_BY%TYPE
                                                                                                                          := FND_GLOBAL.user_id;
     l_last_update_login                   PA_RESOURCE_ASSIGNMENTS.LAST_UPDATE_LOGIN%TYPE
                                                                                                                          := FND_GLOBAL.login_id;

           l_override_quantity                    NUMBER;
     l_copy_lines                                                                          varchar2(20);
     l_is_gl_greater                                               VARCHAR2(1) := 'N';
     l_is_pa_greater                 VARCHAR2(1) := 'N';
     l_end_date                      DATE;
     l_dist_amounts                  VARCHAR2(1) := 'N';
     l_msg_count                                                                           NUMBER;
     l_data                                                                                                        VARCHAR2(2000);
     l_msg_data                                                                                    VARCHAR2(2000);
     l_msg_index_out                                                               NUMBER;

   BEGIN

           IF p_pa_debug_mode = 'Y' THEN
         pa_debug.set_curr_function( p_function     => 'GET_ETC_FROM_SRC_BDGT',
                                     p_debug_mode   =>  p_pa_debug_mode);
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;
     x_msg_count := 0;

     IF P_FP_COLS_SRC_FP_REC.X_TIME_PHASED_CODE = P_FP_COLS_TGT_REC.X_TIME_PHASED_CODE AND
        P_FP_COLS_SRC_WP_REC.X_TIME_PHASED_CODE = P_FP_COLS_TGT_REC.X_TIME_PHASED_CODE THEN
        l_copy_lines := 'ALL';
     ELSIF P_FP_COLS_SRC_FP_REC.X_TIME_PHASED_CODE = P_FP_COLS_TGT_REC.X_TIME_PHASED_CODE /* AND
        P_FP_COLS_SRC_WP_REC.X_TIME_PHASED_CODE <> P_FP_COLS_TGT_REC.X_TIME_PHASED_CODE */THEN
        l_copy_lines := 'FINANCIAL_PLAN';
     ELSIF /*P_FP_COLS_SRC_FP_REC.X_TIME_PHASED_CODE <> P_FP_COLS_TGT_REC.X_TIME_PHASED_CODE AND*/
        P_FP_COLS_SRC_WP_REC.X_TIME_PHASED_CODE = P_FP_COLS_TGT_REC.X_TIME_PHASED_CODE THEN
        l_copy_lines := 'WORKPLAN_RESOURCES';
     ELSE
        l_copy_lines := 'NONE';
     END IF;

     -- Need to check up if we need to do this.
     IF P_FP_COLS_TGT_REC.x_plan_in_multi_curr_flag ='N' THEN
           l_txn_currency_flag := 'N';
     ELSE
           l_txn_currency_flag := 'A';
     END IF;

     IF l_copy_lines = 'ALL' THEN
            OPEN fcst_budget_line_src_tgt_all
              (P_FP_COLS_TGT_REC.x_project_currency_code,
               P_FP_COLS_TGT_REC.x_projfunc_currency_code,
               P_FP_COLS_TGT_REC.X_BUDGET_VERSION_ID,
               P_FP_COLS_TGT_REC.x_project_id);
         FETCH fcst_budget_line_src_tgt_all
         BULK COLLECT
         INTO l_tgt_res_asg_id_tab,
              l_tgt_rate_based_flag_tab,
              l_start_date_tab,
              l_end_date_tab,
              l_period_name_tab,
              l_txn_currency_code_tab,
              l_src_quantity_tab,
              l_txn_raw_cost_tab,
              l_txn_brdn_cost_tab,
              l_unround_txn_raw_cost_tab,
              l_unround_txn_brdn_cost_tab,
              l_cost_rate_override_tab,
              l_b_cost_rate_override_tab;
        CLOSE fcst_budget_line_src_tgt_all;

        IF l_tgt_res_asg_id_tab.count > 0 THEN
                FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                   l_override_quantity := l_src_quantity_tab(i);
                   IF l_tgt_rate_based_flag_tab(i) = 'N' THEN
                       l_src_quantity_tab(i):= l_txn_raw_cost_tab(i);
                       l_override_quantity := l_unround_txn_raw_cost_tab(i);
                   END IF;
                   IF l_override_quantity <> 0 THEN
                       l_cost_rate_override_tab(i)   := l_unround_txn_raw_cost_tab(i) / l_override_quantity;
                       l_b_cost_rate_override_tab(i) := l_unround_txn_brdn_cost_tab(i) / l_override_quantity;
                       IF l_tgt_rate_based_flag_tab(i) = 'N' THEN
                           l_cost_rate_override_tab(i) := 1;
                       END IF;
                   END IF;
                 END LOOP;


                 FORALL i IN l_tgt_res_asg_id_tab.FIRST..l_tgt_res_asg_id_tab.LAST
                         INSERT INTO PA_BUDGET_LINES (
                             BUDGET_LINE_ID,
                             BUDGET_VERSION_ID,
                             RESOURCE_ASSIGNMENT_ID,
                             START_DATE,
                             TXN_CURRENCY_CODE,
                             TXN_RAW_COST,
                             TXN_BURDENED_COST,
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
                             BURDEN_COST_RATE_OVERRIDE
                             )
                          VALUES (
                             pa_budget_lines_s.nextval,
                             P_FP_COLS_TGT_REC.X_BUDGET_VERSION_ID,
                             l_tgt_res_asg_id_tab(i),
                             l_start_date_tab(i),
                             l_txn_currency_code_tab(i),
                             l_txn_raw_cost_tab(i),
                             l_txn_brdn_cost_tab(i),
                             l_end_date_tab(i),
                             l_period_name_tab(i),
                             l_src_quantity_tab(i),
                             sysdate,
                             FND_GLOBAL.USER_ID,
                             sysdate,
                             FND_GLOBAL.USER_ID,
                             FND_GLOBAL.LOGIN_ID,
                             P_FP_COLS_TGT_REC.X_PROJECT_CURRENCY_CODE,
                             P_FP_COLS_TGT_REC.X_PROJFUNC_CURRENCY_CODE,
                             l_cost_rate_override_tab(i),
                             l_b_cost_rate_override_tab(i)
                             );
                   END IF; --l_tgt_res_asg_id_tab.count > 0

           ELSIF    l_copy_lines =  'FINANCIAL_PLAN' THEN
                   OPEN fcst_budget_line_src_tgt_ptl
                        (P_FP_COLS_TGT_REC.x_project_currency_code,
                         P_FP_COLS_TGT_REC.x_projfunc_currency_code,
                         P_FP_COLS_TGT_REC.X_BUDGET_VERSION_ID,
                         P_FP_COLS_TGT_REC.x_project_id,
                         l_copy_lines);
                   FETCH fcst_budget_line_src_tgt_ptl
                   BULK COLLECT
                   INTO l_tgt_res_asg_id_tab,
                        l_tgt_rate_based_flag_tab,
                        l_start_date_tab,
                        l_end_date_tab,
                        l_period_name_tab,
                        l_txn_currency_code_tab,
                        l_src_quantity_tab,
                        l_txn_raw_cost_tab,
                        l_txn_brdn_cost_tab,
                        l_unround_txn_raw_cost_tab,
                        l_unround_txn_brdn_cost_tab,
                        l_cost_rate_override_tab,
                        l_b_cost_rate_override_tab;
                   CLOSE fcst_budget_line_src_tgt_ptl;

                   IF l_tgt_res_asg_id_tab.count > 0 THEN

                           FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                             l_override_quantity := l_src_quantity_tab(i);
                             IF l_tgt_rate_based_flag_tab(i) = 'N'  THEN
                                 l_src_quantity_tab(i):= l_txn_raw_cost_tab(i);
                                 l_override_quantity := l_unround_txn_raw_cost_tab(i);
                             END IF;
                             IF l_override_quantity <> 0 THEN
                                 l_cost_rate_override_tab(i)   := l_unround_txn_raw_cost_tab(i) / l_override_quantity;
                                 l_b_cost_rate_override_tab(i) := l_unround_txn_brdn_cost_tab(i) / l_override_quantity;
                                 IF l_tgt_rate_based_flag_tab(i) = 'N' THEN
                                     l_cost_rate_override_tab(i) := 1;
                                 END IF;
                             END IF;
                           END LOOP;


                           FORALL i IN l_tgt_res_asg_id_tab.FIRST..l_tgt_res_asg_id_tab.LAST
                             INSERT INTO PA_BUDGET_LINES (
                                 BUDGET_LINE_ID,
                                 BUDGET_VERSION_ID,
                                 RESOURCE_ASSIGNMENT_ID,
                                 START_DATE,
                                 TXN_CURRENCY_CODE,
                                 TXN_RAW_COST,
                                 TXN_BURDENED_COST,
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
                                 RAW_COST_SOURCE,
                     BURDENED_COST_SOURCE,
                     QUANTITY_SOURCE)
                              VALUES (
                                 pa_budget_lines_s.nextval,
                                 P_FP_COLS_TGT_REC.X_BUDGET_VERSION_ID,
                                 l_tgt_res_asg_id_tab(i),
                                 l_start_date_tab(i),
                                 l_txn_currency_code_tab(i),
                                 l_txn_raw_cost_tab(i),
                                 l_txn_brdn_cost_tab(i),
                                 l_end_date_tab(i),
                                 l_period_name_tab(i),
                                 l_src_quantity_tab(i),
                                 sysdate,
                                 FND_GLOBAL.USER_ID,
                                 sysdate,
                                 FND_GLOBAL.USER_ID,
                                 FND_GLOBAL.LOGIN_ID,
                                 P_FP_COLS_TGT_REC.X_PROJECT_CURRENCY_CODE,
                                 P_FP_COLS_TGT_REC.X_PROJFUNC_CURRENCY_CODE,
                                 l_cost_rate_override_tab(i),
                                 l_b_cost_rate_override_tab(i),
                                 'SP',
                                 'SP',
                                 'SP');

                   END IF; --l_tgt_res_asg_id_tab.count > 0

           ELSIF  l_copy_lines =  'WORKPLAN_RESOURCES' THEN
                   OPEN fcst_budget_line_src_tgt_ptl
                        (P_FP_COLS_TGT_REC.x_project_currency_code,
                         P_FP_COLS_TGT_REC.x_projfunc_currency_code,
                         P_FP_COLS_TGT_REC.X_BUDGET_VERSION_ID,
                         P_FP_COLS_TGT_REC.x_project_id,
                         l_copy_lines);
                   FETCH fcst_budget_line_src_tgt_ptl
                   BULK COLLECT
                   INTO l_tgt_res_asg_id_tab,
                        l_tgt_rate_based_flag_tab,
                        l_start_date_tab,
                        l_end_date_tab,
                        l_period_name_tab,
                        l_txn_currency_code_tab,
                        l_src_quantity_tab,
                        l_txn_raw_cost_tab,
                        l_txn_brdn_cost_tab,
                        l_unround_txn_raw_cost_tab,
                        l_unround_txn_brdn_cost_tab,
                        l_cost_rate_override_tab,
                        l_b_cost_rate_override_tab;
                   CLOSE fcst_budget_line_src_tgt_ptl;

                   IF l_tgt_res_asg_id_tab.count > 0 THEN

                           FOR i in 1..l_tgt_res_asg_id_tab.count LOOP
                             l_override_quantity := l_src_quantity_tab(i);
                             IF l_tgt_rate_based_flag_tab(i) = 'N'  THEN
                                 l_src_quantity_tab(i):= l_txn_raw_cost_tab(i);
                                 l_override_quantity := l_unround_txn_raw_cost_tab(i);
                             END IF;
                             IF l_override_quantity <> 0 THEN
                                 l_cost_rate_override_tab(i)   := l_unround_txn_raw_cost_tab(i) / l_override_quantity;
                                 l_b_cost_rate_override_tab(i) := l_unround_txn_brdn_cost_tab(i) / l_override_quantity;
                                 IF l_tgt_rate_based_flag_tab(i) = 'N' THEN
                                     l_cost_rate_override_tab(i) := 1;
                                 END IF;
                             END IF;
                           END LOOP;


                           FORALL i IN l_tgt_res_asg_id_tab.FIRST..l_tgt_res_asg_id_tab.LAST
                                    INSERT INTO PA_BUDGET_LINES (
                                 BUDGET_LINE_ID,
                                 BUDGET_VERSION_ID,
                                 RESOURCE_ASSIGNMENT_ID,
                                 START_DATE,
                                 TXN_CURRENCY_CODE,
                                 TXN_RAW_COST,
                                 TXN_BURDENED_COST,
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
                                 RAW_COST_SOURCE,
                     BURDENED_COST_SOURCE,
                     QUANTITY_SOURCE)
                              VALUES (
                                 pa_budget_lines_s.nextval,
                                 P_FP_COLS_TGT_REC.X_BUDGET_VERSION_ID,
                                 l_tgt_res_asg_id_tab(i),
                                 l_start_date_tab(i),
                                 l_txn_currency_code_tab(i),
                                 l_txn_raw_cost_tab(i),
                                 l_txn_brdn_cost_tab(i),
                                 l_end_date_tab(i),
                                 l_period_name_tab(i),
                                 l_src_quantity_tab(i),
                                 sysdate,
                                 FND_GLOBAL.USER_ID,
                                 sysdate,
                                 FND_GLOBAL.USER_ID,
                                 FND_GLOBAL.LOGIN_ID,
                                 P_FP_COLS_TGT_REC.X_PROJECT_CURRENCY_CODE,
                                 P_FP_COLS_TGT_REC.X_PROJFUNC_CURRENCY_CODE,
                                 l_cost_rate_override_tab(i),
                                 l_b_cost_rate_override_tab(i),
                                 'SP',
                                 'SP',
                                 'SP');

                   END IF; -- l_tgt_res_asg_id_tab.count > 0

     END IF;  -- l_copy_lines = 'ALL'

     -- Till now copying of budgetlines directly from source is done. Now we need to prorate the data or accumulate
     -- same based on source and dest periods.

     IF l_copy_lines <> 'ALL' THEN

             -- getting planning end date to cache periods temp table only for required span.
             -- Doing this processing to avoid unnecessary periods being pulled.
             BEGIN
                     SELECT  MAX(PLANNING_END_DATE)
                     INTO l_end_date
                     FROM PA_FP_CALC_AMT_TMP1;
             EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                             SELECT  MAX(pbl.end_date)
                             INTO l_end_date
                             FROM PA_BUDGET_LINES pbl,
                             PA_FP_CALC_AMT_TMP2 tmp
                             WHERE tmp.resource_assignment_id = pbl.resource_assignment_id ;
             END;

             PROCESS_PA_GL_DATES( p_start_date       => P_ACTUALS_THRU_DATE
                                                                                                   ,p_end_date         => l_end_date
                                                                                                   ,p_org_id           => P_FP_COLS_TGT_REC.X_ORG_ID
                                                                                                   ,X_GL_GREATER_FLAG  => l_is_gl_greater
                                                                                                   ,X_RETURN_STATUS    => x_return_status
                                                                                                   ,X_MSG_COUNT        => x_msg_count
                                                                                                   ,X_MSG_DATA         => x_msg_data);

     END IF;

     -- Checking now to see if we need to distribute the source lines or club.
           IF P_FP_COLS_TGT_REC.X_TIME_PHASED_CODE = 'G' AND l_is_gl_greater = 'Y' THEN
                   l_dist_amounts := 'N';
           ELSIF P_FP_COLS_TGT_REC.X_TIME_PHASED_CODE = 'P' AND l_is_gl_greater = 'Y' THEN
                   l_dist_amounts := 'Y';
           ELSIF P_FP_COLS_TGT_REC.X_TIME_PHASED_CODE = 'G' AND l_is_gl_greater = 'N' THEN
             l_dist_amounts := 'Y';
           ELSIF P_FP_COLS_TGT_REC.X_TIME_PHASED_CODE = 'P' AND l_is_gl_greater = 'N' THEN
                   l_dist_amounts := 'N';
           ELSE
                   l_dist_amounts := 'N';
           END IF;


     IF l_copy_lines = 'NONE' THEN

           IF l_dist_amounts = 'N' THEN
                   OPEN fcst_bdgt_line_src_tgt_sum
              (P_FP_COLS_TGT_REC.x_project_currency_code,
               P_FP_COLS_TGT_REC.x_projfunc_currency_code,
               P_FP_COLS_TGT_REC.X_BUDGET_VERSION_ID,
               P_FP_COLS_TGT_REC.x_project_id,
               P_FP_COLS_SRC_WP_REC.x_time_phased_code);
         FETCH fcst_bdgt_line_src_tgt_sum
         BULK COLLECT
         INTO l_pr_tgt_res_asg_id_tab,
              l_pr_tgt_rate_based_flag_tab,
              l_pr_start_date_tab,
              l_pr_end_date_tab,
              l_pr_period_name_tab,
              l_pr_txn_currency_code_tab,
              l_pr_src_quantity_tab,
              l_pr_txn_raw_cost_tab,
              l_pr_txn_brdn_cost_tab,
              l_pr_unround_txn_raw_cost_tab,
              l_pr_unround_txn_brdn_cost_tab,
              l_pr_cost_rate_override_tab,
              l_pr_b_cost_rate_override_tab;
        CLOSE fcst_bdgt_line_src_tgt_sum;
      ELSE

                   OPEN fcst_bdgt_line_src_tgt_dist
              (P_FP_COLS_TGT_REC.x_project_currency_code,
               P_FP_COLS_TGT_REC.x_projfunc_currency_code,
               P_FP_COLS_TGT_REC.X_BUDGET_VERSION_ID,
               P_FP_COLS_TGT_REC.x_project_id,
               P_FP_COLS_SRC_WP_REC.x_time_phased_code);
         FETCH fcst_bdgt_line_src_tgt_dist
         BULK COLLECT
         INTO l_pr_tgt_res_asg_id_tab,
              l_pr_tgt_rate_based_flag_tab,
              l_pr_start_date_tab,
              l_pr_end_date_tab,
              l_pr_period_name_tab,
              l_pr_txn_currency_code_tab,
              l_pr_src_quantity_tab,
              l_pr_txn_raw_cost_tab,
              l_pr_txn_brdn_cost_tab,
              l_pr_unround_txn_raw_cost_tab,
              l_pr_unround_txn_brdn_cost_tab,
              l_pr_cost_rate_override_tab,
              l_pr_b_cost_rate_override_tab;
        CLOSE fcst_bdgt_line_src_tgt_dist;

      END IF; --l_dist_amounts = 'N'

      IF l_pr_tgt_res_asg_id_tab.count >0 THEN
              FOR i in 1..l_pr_tgt_res_asg_id_tab.count LOOP
                 l_override_quantity := l_pr_src_quantity_tab(i);
                 IF l_pr_tgt_rate_based_flag_tab(i) = 'N' THEN
                     l_pr_src_quantity_tab(i):= l_pr_txn_raw_cost_tab(i);
                     l_override_quantity := l_pr_unround_txn_raw_cost_tab(i);
                 END IF;
                 IF l_override_quantity <> 0 THEN
                     l_pr_cost_rate_override_tab(i)   := l_pr_unround_txn_raw_cost_tab(i) / l_override_quantity;
                     l_pr_b_cost_rate_override_tab(i) := l_pr_unround_txn_brdn_cost_tab(i) / l_override_quantity;
                     IF l_pr_tgt_rate_based_flag_tab(i) = 'N' THEN
                         l_pr_cost_rate_override_tab(i) := 1;
                     END IF;
                 END IF;
               END LOOP;


               FORALL i IN l_pr_tgt_res_asg_id_tab.FIRST..l_pr_tgt_res_asg_id_tab.LAST
                 INSERT INTO PA_BUDGET_LINES (
                     BUDGET_LINE_ID,
                     BUDGET_VERSION_ID,
                     RESOURCE_ASSIGNMENT_ID,
                     START_DATE,
                     TXN_CURRENCY_CODE,
                     TXN_RAW_COST,
                     TXN_BURDENED_COST,
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
                     RAW_COST_SOURCE,
                     BURDENED_COST_SOURCE,
                     QUANTITY_SOURCE)
                  VALUES (
                     pa_budget_lines_s.nextval,
                     P_FP_COLS_TGT_REC.X_BUDGET_VERSION_ID,
                     l_pr_tgt_res_asg_id_tab(i),
                     l_pr_start_date_tab(i),
                     l_pr_txn_currency_code_tab(i),
                     l_pr_txn_raw_cost_tab(i),
                     l_pr_txn_brdn_cost_tab(i),
                     l_pr_end_date_tab(i),
                     l_pr_period_name_tab(i),
                     l_pr_src_quantity_tab(i),
                     sysdate,
                     FND_GLOBAL.USER_ID,
                     sysdate,
                     FND_GLOBAL.USER_ID,
                     FND_GLOBAL.LOGIN_ID,
                     P_FP_COLS_TGT_REC.X_PROJECT_CURRENCY_CODE,
                     P_FP_COLS_TGT_REC.X_PROJFUNC_CURRENCY_CODE,
                     l_pr_cost_rate_override_tab(i),
                     l_pr_b_cost_rate_override_tab(i),
                     'SP',
                     'SP',
                     'SP');
                   END IF; --IF l_pr_tgt_res_asg_id_tab.count >0 THEN

           ELSIF l_copy_lines = 'FINANCIAL_PLAN' THEN

                   IF l_dist_amounts = 'N' THEN
                           OPEN fcst_bdgt_line_src_tgt_sum_ptl
                                (P_FP_COLS_TGT_REC.x_project_currency_code,
                                 P_FP_COLS_TGT_REC.x_projfunc_currency_code,
                                 P_FP_COLS_TGT_REC.X_BUDGET_VERSION_ID,
                                 P_FP_COLS_TGT_REC.x_project_id,
                                 'WORKPLAN_RESOURCES',
                                 P_FP_COLS_SRC_WP_REC.x_time_phased_code);
                           FETCH fcst_bdgt_line_src_tgt_sum_ptl
                           BULK COLLECT
                           INTO l_pr_tgt_res_asg_id_tab,
                                l_pr_tgt_rate_based_flag_tab,
                                l_pr_start_date_tab,
                                l_pr_end_date_tab,
                                l_pr_period_name_tab,
                                l_pr_txn_currency_code_tab,
                                l_pr_src_quantity_tab,
                                l_pr_txn_raw_cost_tab,
                                l_pr_txn_brdn_cost_tab,
                                l_pr_unround_txn_raw_cost_tab,
                                l_pr_unround_txn_brdn_cost_tab,
                                l_pr_cost_rate_override_tab,
                                l_pr_b_cost_rate_override_tab;
                           CLOSE fcst_bdgt_line_src_tgt_sum_ptl;
                   ELSE
                           OPEN fcst_bdgt_line_src_tgt_dist_pt
                              (P_FP_COLS_TGT_REC.x_project_currency_code,
                               P_FP_COLS_TGT_REC.x_projfunc_currency_code,
                               P_FP_COLS_TGT_REC.X_BUDGET_VERSION_ID,
                               P_FP_COLS_TGT_REC.x_project_id,
                               'WORKPLAN_RESOURCES',
                               P_FP_COLS_SRC_WP_REC.x_time_phased_code);
                           FETCH fcst_bdgt_line_src_tgt_dist_pt
                           BULK COLLECT
                           INTO l_pr_tgt_res_asg_id_tab,
                              l_pr_tgt_rate_based_flag_tab,
                              l_pr_start_date_tab,
                              l_pr_end_date_tab,
                              l_pr_period_name_tab,
                              l_pr_txn_currency_code_tab,
                              l_pr_src_quantity_tab,
                              l_pr_txn_raw_cost_tab,
                              l_pr_txn_brdn_cost_tab,
                              l_pr_unround_txn_raw_cost_tab,
                              l_pr_unround_txn_brdn_cost_tab,
                              l_pr_cost_rate_override_tab,
                              l_pr_b_cost_rate_override_tab;
                           CLOSE fcst_bdgt_line_src_tgt_dist_pt;

                   END IF; --l_dist_amounts = 'N'

                   IF l_pr_tgt_res_asg_id_tab.count >0 THEN
                           FOR i in 1..l_pr_tgt_res_asg_id_tab.count LOOP
                             l_override_quantity := l_pr_src_quantity_tab(i);
                             IF l_pr_tgt_rate_based_flag_tab(i) = 'N' THEN
                                 l_pr_src_quantity_tab(i):= l_pr_txn_raw_cost_tab(i);
                                 l_override_quantity := l_pr_unround_txn_raw_cost_tab(i);
                             END IF;
                             IF l_override_quantity <> 0 THEN
                                 l_pr_cost_rate_override_tab(i)   := l_pr_unround_txn_raw_cost_tab(i) / l_override_quantity;
                                 l_pr_b_cost_rate_override_tab(i) := l_pr_unround_txn_brdn_cost_tab(i) / l_override_quantity;
                                 IF l_pr_tgt_rate_based_flag_tab(i) = 'N' THEN
                                     l_pr_cost_rate_override_tab(i) := 1;
                                 END IF;
                             END IF;
                           END LOOP;

                           -- We have to merge the data for scenario where it is possible that the destination plan is project level then
                           -- for same resource assignment in destination with different source in that case we will get unique constraint
                           -- error if we have data for the same period.
                           FORALL i IN l_pr_tgt_res_asg_id_tab.FIRST..l_pr_tgt_res_asg_id_tab.LAST
                                   MERGE INTO PA_BUDGET_LINES pbl
                                   USING ( SELECT NULL                                                                                               as BUDGET_LINE_ID,
                                 P_FP_COLS_TGT_REC.X_BUDGET_VERSION_ID      as BUDGET_VERSION_ID,
                                 l_pr_tgt_res_asg_id_tab(i)                 as RESOURCE_ASSIGNMENT_ID,
                                 l_pr_start_date_tab(i)                     as START_DATE,
                                 l_pr_txn_currency_code_tab(i)              as TXN_CURRENCY_CODE,
                                 l_pr_txn_raw_cost_tab(i)                   as TXN_RAW_COST,
                                 l_pr_txn_brdn_cost_tab(i)                  as TXN_BURDENED_COST,
                                 l_pr_end_date_tab(i)                       as END_DATE,
                                 l_pr_period_name_tab(i)                    as PERIOD_NAME,
                                 l_pr_src_quantity_tab(i)                   as QUANTITY,
                                 sysdate                                    as LAST_UPDATE_DATE,
                                 FND_GLOBAL.USER_ID                         as LAST_UPDATED_BY,
                                 sysdate                                    as CREATION_DATE,
                                 FND_GLOBAL.USER_ID                         as CREATED_BY,
                                 FND_GLOBAL.LOGIN_ID                        as LAST_UPDATE_LOGIN,
                                 P_FP_COLS_TGT_REC.X_PROJECT_CURRENCY_CODE  as PROJECT_CURRENCY_CODE,
                                 P_FP_COLS_TGT_REC.X_PROJFUNC_CURRENCY_CODE as PROJFUNC_CURRENCY_CODE,
                                 l_pr_cost_rate_override_tab(i)             as TXN_COST_RATE_OVERRIDE,
                                 l_pr_b_cost_rate_override_tab(i)           as BURDEN_COST_RATE_OVERRIDE ,
                                 'SP'                                                                                                                                                         as RAW_COST_SOURCE,
                     'SP'                                                                                                                                                          as BURDENED_COST_SOURCE,
                     'SP'                                                                                                                                                         as QUANTITY_SOURCE
                                 FROM dual) tmp
                              ON ( tmp.RESOURCE_ASSIGNMENT_ID = pbl.RESOURCE_ASSIGNMENT_ID AND
                                                tmp.START_DATE = pbl.START_DATE AND
                                                tmp.TXN_CURRENCY_CODE = pbl.TXN_CURRENCY_CODE)
                              WHEN MATCHED THEN
                                 UPDATE
                                 SET  pbl.TXN_RAW_COST = nvl(pbl.TXN_RAW_COST,0) + nvl(tmp.TXN_RAW_COST,0)
                                     ,pbl.TXN_BURDENED_COST = nvl(pbl.TXN_BURDENED_COST,0) + nvl(tmp.TXN_BURDENED_COST,0)
                                     ,pbl.QUANTITY = nvl(pbl.QUANTITY,0) + nvl(tmp.QUANTITY,0)
                                     ,pbl.LAST_UPDATE_DATE = sysdate
                                     ,pbl.LAST_UPDATED_BY = FND_GLOBAL.USER_ID
                                     ,pbl.LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
                              WHEN NOT MATCHED THEN
                                             INSERT (
                                                     pbl.BUDGET_LINE_ID,
                                                     pbl.BUDGET_VERSION_ID,
                                                     pbl.RESOURCE_ASSIGNMENT_ID,
                                                     pbl.START_DATE,
                                                     pbl.TXN_CURRENCY_CODE,
                                                     pbl.TXN_RAW_COST,
                                                     pbl.TXN_BURDENED_COST,
                                                     pbl.END_DATE,
                                                     pbl.PERIOD_NAME,
                                                     pbl.QUANTITY,
                                                     pbl.LAST_UPDATE_DATE,
                                                     pbl.LAST_UPDATED_BY,
                                                     pbl.CREATION_DATE,
                                                     pbl.CREATED_BY,
                                                     pbl.LAST_UPDATE_LOGIN,
                                                     pbl.PROJECT_CURRENCY_CODE,
                                                     pbl.PROJFUNC_CURRENCY_CODE,
                                                     pbl.TXN_COST_RATE_OVERRIDE,
                                                     pbl.BURDEN_COST_RATE_OVERRIDE,
                                                     pbl.RAW_COST_SOURCE,
                                                     pbl.BURDENED_COST_SOURCE,
                                                     pbl.QUANTITY_SOURCE)
                                               VALUES (
                                                                       pa_budget_lines_s.nextval,
                                                     tmp.BUDGET_VERSION_ID,
                                                     tmp.RESOURCE_ASSIGNMENT_ID,
                                                     tmp.START_DATE,
                                                     tmp.TXN_CURRENCY_CODE,
                                                     tmp.TXN_RAW_COST,
                                                     tmp.TXN_BURDENED_COST,
                                                     tmp.END_DATE,
                                                     tmp.PERIOD_NAME,
                                                     tmp.QUANTITY,
                                                     tmp.LAST_UPDATE_DATE,
                                                     tmp.LAST_UPDATED_BY,
                                                     tmp.CREATION_DATE,
                                                     tmp.CREATED_BY,
                                                     tmp.LAST_UPDATE_LOGIN,
                                                     tmp.PROJECT_CURRENCY_CODE,
                                                     tmp.PROJFUNC_CURRENCY_CODE,
                                                     tmp.TXN_COST_RATE_OVERRIDE,
                                                     tmp.BURDEN_COST_RATE_OVERRIDE,
                                                     tmp.RAW_COST_SOURCE,
                                                tmp.BURDENED_COST_SOURCE,
                                                     tmp.QUANTITY_SOURCE);

                   END IF; --IF l_pr_tgt_res_asg_id_tab.count >0 THEN

           ELSIF l_copy_lines = 'WORKPLAN_RESOURCES' THEN


                   IF l_dist_amounts = 'N' THEN
                           OPEN fcst_bdgt_line_src_tgt_sum_ptl
                              (P_FP_COLS_TGT_REC.x_project_currency_code,
                               P_FP_COLS_TGT_REC.x_projfunc_currency_code,
                               P_FP_COLS_TGT_REC.X_BUDGET_VERSION_ID,
                               P_FP_COLS_TGT_REC.x_project_id,
                               'FINANCIAL_PLAN',
                               P_FP_COLS_SRC_FP_REC.x_time_phased_code);
                           FETCH fcst_bdgt_line_src_tgt_sum_ptl
                           BULK COLLECT
                           INTO l_pr_tgt_res_asg_id_tab,
                              l_pr_tgt_rate_based_flag_tab,
                              l_pr_start_date_tab,
                              l_pr_end_date_tab,
                              l_pr_period_name_tab,
                              l_pr_txn_currency_code_tab,
                              l_pr_src_quantity_tab,
                              l_pr_txn_raw_cost_tab,
                              l_pr_txn_brdn_cost_tab,
                              l_pr_unround_txn_raw_cost_tab,
                              l_pr_unround_txn_brdn_cost_tab,
                              l_pr_cost_rate_override_tab,
                              l_pr_b_cost_rate_override_tab;
                           CLOSE fcst_bdgt_line_src_tgt_sum_ptl;
                   ELSE
                           OPEN fcst_bdgt_line_src_tgt_dist_pt
                              (P_FP_COLS_TGT_REC.x_project_currency_code,
                               P_FP_COLS_TGT_REC.x_projfunc_currency_code,
                               P_FP_COLS_TGT_REC.X_BUDGET_VERSION_ID,
                               P_FP_COLS_TGT_REC.x_project_id,
                               'FINANCIAL_PLAN',
                               P_FP_COLS_SRC_FP_REC.x_time_phased_code);
                           FETCH fcst_bdgt_line_src_tgt_dist_pt
                           BULK COLLECT
                           INTO l_pr_tgt_res_asg_id_tab,
                              l_pr_tgt_rate_based_flag_tab,
                              l_pr_start_date_tab,
                              l_pr_end_date_tab,
                              l_pr_period_name_tab,
                              l_pr_txn_currency_code_tab,
                              l_pr_src_quantity_tab,
                              l_pr_txn_raw_cost_tab,
                              l_pr_txn_brdn_cost_tab,
                              l_pr_unround_txn_raw_cost_tab,
                              l_pr_unround_txn_brdn_cost_tab,
                              l_pr_cost_rate_override_tab,
                              l_pr_b_cost_rate_override_tab;
                           CLOSE fcst_bdgt_line_src_tgt_dist_pt;

                   END IF; --l_dist_amounts = 'N'

                   IF l_pr_tgt_res_asg_id_tab.count >0 THEN

                           FOR i in 1..l_pr_tgt_res_asg_id_tab.count LOOP
                             l_override_quantity := l_pr_src_quantity_tab(i);
                             IF l_pr_tgt_rate_based_flag_tab(i) = 'N' THEN
                                 l_pr_src_quantity_tab(i):= l_pr_txn_raw_cost_tab(i);
                                 l_override_quantity := l_pr_unround_txn_raw_cost_tab(i);
                             END IF;
                             IF l_override_quantity <> 0 THEN
                                 l_pr_cost_rate_override_tab(i)   := l_pr_unround_txn_raw_cost_tab(i) / l_override_quantity;
                                 l_pr_b_cost_rate_override_tab(i) := l_pr_unround_txn_brdn_cost_tab(i) / l_override_quantity;
                                 IF l_pr_tgt_rate_based_flag_tab(i) = 'N' THEN
                                     l_pr_cost_rate_override_tab(i) := 1;
                                 END IF;
                             END IF;
                           END LOOP;


                           -- We have to merge the data for scenario where it is possible that the destination plan is project level then
                           -- for same resource assignment in destination with different source in that case we will get unique constraint
                           -- error if we have data for the same period.
                           FORALL i IN l_pr_tgt_res_asg_id_tab.FIRST..l_pr_tgt_res_asg_id_tab.LAST
                                   MERGE INTO PA_BUDGET_LINES pbl
                                   USING ( SELECT NULL                                                                                               as BUDGET_LINE_ID,
                                 P_FP_COLS_TGT_REC.X_BUDGET_VERSION_ID      as BUDGET_VERSION_ID,
                                 l_pr_tgt_res_asg_id_tab(i)                 as RESOURCE_ASSIGNMENT_ID,
                                 l_pr_start_date_tab(i)                     as START_DATE,
                                 l_pr_txn_currency_code_tab(i)              as TXN_CURRENCY_CODE,
                                 l_pr_txn_raw_cost_tab(i)                   as TXN_RAW_COST,
                                 l_pr_txn_brdn_cost_tab(i)                  as TXN_BURDENED_COST,
                                 l_pr_end_date_tab(i)                       as END_DATE,
                                 l_pr_period_name_tab(i)                    as PERIOD_NAME,
                                 l_pr_src_quantity_tab(i)                   as QUANTITY,
                                 sysdate                                    as LAST_UPDATE_DATE,
                                 FND_GLOBAL.USER_ID                         as LAST_UPDATED_BY,
                                 sysdate                                    as CREATION_DATE,
                                 FND_GLOBAL.USER_ID                         as CREATED_BY,
                                 FND_GLOBAL.LOGIN_ID                        as LAST_UPDATE_LOGIN,
                                 P_FP_COLS_TGT_REC.X_PROJECT_CURRENCY_CODE  as PROJECT_CURRENCY_CODE,
                                 P_FP_COLS_TGT_REC.X_PROJFUNC_CURRENCY_CODE as PROJFUNC_CURRENCY_CODE,
                                 l_pr_cost_rate_override_tab(i)             as TXN_COST_RATE_OVERRIDE,
                                 l_pr_b_cost_rate_override_tab(i)           as BURDEN_COST_RATE_OVERRIDE,
                                 'SP'                                                                                                                                                         as RAW_COST_SOURCE,
                     'SP'                                                                                                                                                          as BURDENED_COST_SOURCE,
                     'SP'                                                                                                                                                   as QUANTITY_SOURCE
                                 FROM dual) tmp
                              ON ( tmp.RESOURCE_ASSIGNMENT_ID = pbl.RESOURCE_ASSIGNMENT_ID AND
                                                tmp.START_DATE = pbl.START_DATE AND
                                                tmp.TXN_CURRENCY_CODE = pbl.TXN_CURRENCY_CODE)
                              WHEN MATCHED THEN
                                 UPDATE
                                 SET  pbl.TXN_RAW_COST = nvl(pbl.TXN_RAW_COST,0) + nvl(tmp.TXN_RAW_COST,0)
                                     ,pbl.TXN_BURDENED_COST = nvl(pbl.TXN_BURDENED_COST,0) + nvl(tmp.TXN_BURDENED_COST,0)
                                     ,pbl.QUANTITY = nvl(pbl.QUANTITY,0) + nvl(tmp.QUANTITY,0)
                                     ,pbl.LAST_UPDATE_DATE = sysdate
                                     ,pbl.LAST_UPDATED_BY = FND_GLOBAL.USER_ID
                                     ,pbl.LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
                              WHEN NOT MATCHED THEN
                                                   INSERT (
                                                           pbl.BUDGET_LINE_ID,
                                                           pbl.BUDGET_VERSION_ID,
                                                           pbl.RESOURCE_ASSIGNMENT_ID,
                                                           pbl.START_DATE,
                                                           pbl.TXN_CURRENCY_CODE,
                                                           pbl.TXN_RAW_COST,
                                                           pbl.TXN_BURDENED_COST,
                                                           pbl.END_DATE,
                                                           pbl.PERIOD_NAME,
                                                           pbl.QUANTITY,
                                                           pbl.LAST_UPDATE_DATE,
                                                           pbl.LAST_UPDATED_BY,
                                                           pbl.CREATION_DATE,
                                                           pbl.CREATED_BY,
                                                           pbl.LAST_UPDATE_LOGIN,
                                                           pbl.PROJECT_CURRENCY_CODE,
                                                           pbl.PROJFUNC_CURRENCY_CODE,
                                                           pbl.TXN_COST_RATE_OVERRIDE,
                                                           pbl.BURDEN_COST_RATE_OVERRIDE,
                                                           pbl.RAW_COST_SOURCE,
                                                     pbl.BURDENED_COST_SOURCE,
                                                     pbl.QUANTITY_SOURCE)
                                                     VALUES (
                                                                             pa_budget_lines_s.nextval,
                                                           tmp.BUDGET_VERSION_ID,
                                                           tmp.RESOURCE_ASSIGNMENT_ID,
                                                           tmp.START_DATE,
                                                           tmp.TXN_CURRENCY_CODE,
                                                           tmp.TXN_RAW_COST,
                                                           tmp.TXN_BURDENED_COST,
                                                           tmp.END_DATE,
                                                           tmp.PERIOD_NAME,
                                                           tmp.QUANTITY,
                                                           tmp.LAST_UPDATE_DATE,
                                                           tmp.LAST_UPDATED_BY,
                                                           tmp.CREATION_DATE,
                                                           tmp.CREATED_BY,
                                                           tmp.LAST_UPDATE_LOGIN,
                                                           tmp.PROJECT_CURRENCY_CODE,
                                                           tmp.PROJFUNC_CURRENCY_CODE,
                                                           tmp.TXN_COST_RATE_OVERRIDE,
                                                           tmp.BURDEN_COST_RATE_OVERRIDE,
                                                           tmp.RAW_COST_SOURCE,
                                                tmp.BURDENED_COST_SOURCE,
                                                     tmp.QUANTITY_SOURCE);

                   END IF; --IF l_pr_tgt_res_asg_id_tab.count >0 THEN

     END IF; -- l_copy_lines = 'NONE'

     -- Processing for pa_res_curr table:

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
            PA_FP_CALC_AMT_TMP2 tmp4
     WHERE  ra.budget_version_id = P_FP_COLS_TGT_REC.X_BUDGET_VERSION_ID
     AND    ra.project_id = P_FP_COLS_TGT_REC.x_project_id
     AND    ra.resource_assignment_id = tmp4.target_res_asg_id
     AND    bl.resource_assignment_id = ra.resource_assignment_id
     AND    bl.resource_assignment_id = rbc.resource_assignment_id (+)
     AND    bl.txn_currency_code = rbc.txn_currency_code (+);


     -- Call the maintenance api in ROLLUP mode
     IF p_pa_debug_mode = 'Y' THEN
         PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
             P_MSG                   => 'Before calling PA_RES_ASG_CURRENCY_PUB.' ||
                                        'MAINTAIN_DATA',
             P_MODULE_NAME           => l_module_name);
     END IF;
     PA_RES_ASG_CURRENCY_PUB.MAINTAIN_DATA
           ( P_FP_COLS_REC           => P_FP_COLS_TGT_REC,
             P_CALLING_MODULE        => 'FORECAST_GENERATION',
             P_VERSION_LEVEL_FLAG    => 'N',
             P_ROLLUP_FLAG           => 'Y',
             X_RETURN_STATUS         => x_return_status,
             X_MSG_COUNT             => x_msg_count,
             X_MSG_DATA              => x_msg_data );
     IF p_pa_debug_mode = 'Y' THEN
         PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
             P_MSG                   => 'After calling PA_RES_ASG_CURRENCY_PUB.' ||
                                        'MAINTAIN_DATA: '||x_return_status,
             P_MODULE_NAME           => l_module_name);
     END IF;
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;

     -- Bug 8346446 AAI QA
     -- Not pulling the source assigment id in etc2 coz it could be possible that the dest is at top task level
     -- or project or structure could be mapped or split in those cases the amounts would be doubled or trippled
     -- if the destination assignment id is mapped to multiple source asssgn ids.
     -- Pulling distinct records to avoid duplicates coz etc should be processed only for target res ids.
     INSERT INTO PA_FP_CALC_AMT_TMP2
                  ( --RESOURCE_ASSIGNMENT_ID, -- Bug 8346446
                    TARGET_RES_ASG_ID,
                    ETC_CURRENCY_CODE,
                    ETC_PLAN_QUANTITY,
                    ETC_TXN_RAW_COST,
                    ETC_TXN_BURDENED_COST,
                    TRANSACTION_SOURCE_CODE
                     )
     SELECT --tmp4.resource_assignment_id, -- bug 8346446
                            distinct
            ra.resource_assignment_id,
            sbl.txn_currency_code,
            sum(sbl.quantity),
            sum(sbl.txn_raw_cost),
            sum(sbl.txn_burdened_cost),
            'ETC'
     FROM PA_FP_CALC_AMT_TMP2 tmp4,
          pa_budget_lines sbl,
          pa_resource_assignments ra
     WHERE tmp4.TARGET_RES_ASG_ID = ra.resource_assignment_id
     AND   sbl.resource_assignment_id=ra.resource_assignment_id
     AND   ra.budget_version_id = P_FP_COLS_TGT_REC.X_BUDGET_VERSION_ID
     AND   ra.project_id = P_FP_COLS_TGT_REC.x_project_id
     AND   ra.budget_version_id = sbl.budget_version_id
     AND   sbl.init_quantity IS NULL
     GROUP BY
           tmp4.resource_assignment_id,
           ra.resource_assignment_id,
           sbl.txn_currency_code,
           'ETC';

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

     WHEN OTHERS then
           ROLLBACK;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_count     := 1;
           x_msg_data      := substr(sqlerrm,1,240);
           FND_MSG_PUB.add_exc_msg
                      ( p_pkg_name        => 'PA_FP_GEN_FCST_AMT_PUB3',
                        p_procedure_name  => 'GEN_ETC_FROM_SRC_BDGT',
                        p_error_text      => substr(sqlerrm,1,240));

           IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_fp_gen_amount_utils.fp_debug
                  (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                   p_module_name => l_module_name,
                   p_log_level   => 5);
               PA_DEBUG.RESET_CURR_FUNCTION;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END GET_ETC_FROM_SRC_BDGT;


   -- skkoppul added for AAI Requirement - start
   /*****************************************************************************
    ** This procedure populates PA_GL_PA_PERIODS_TMP temporary table with all  **
    **  the PA periods to GL period mapping and the conversion mutiplier so    **
    **  that when converting from larger period like Month to smaller period   **
    **  like week, the conversion multiplier can be used to distribute amounts **
    **  evenly. This procedure only stores the mapping entities for the lowest **
    **  start and greatest end dates of the plan.                              **
   *****************************************************************************/
   PROCEDURE PROCESS_PA_GL_DATES
             (
              p_start_date                IN         DATE,
              p_end_date                  IN         DATE,
              p_org_id                    IN         NUMBER,
              X_GL_GREATER_FLAG           OUT NOCOPY VARCHAR2,
              X_RETURN_STATUS             OUT NOCOPY VARCHAR2,
              X_MSG_COUNT                 OUT NOCOPY NUMBER,
              X_MSG_DATA                  OUT NOCOPY VARCHAR2
              )
   IS
       l_is_gl_greater     VARCHAR2(1)     := 'N';
       l_module_name                       VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_FCST_AMT_PUB3.PROCESS_PA_GL_DATES';

   BEGIN

       -- Get PA to GL mapping periods along with their period names and dates
       -- during a time period using the start and end dates
       INSERT
       INTO   PA_GL_PA_PERIODS_TMP
              (
                     PA_PERIOD_NAME ,
                     GL_PERIOD_NAME ,
                     PA_START_DATE  ,
                     PA_END_DATE    ,
                     GL_START_DATE  ,
                     GL_END_DATE
              )
              (SELECT PAP.PERIOD_NAME   ,
                      PAP.GL_PERIOD_NAME,
                      PAP.START_DATE    ,
                      PAP.END_DATE      ,
                      GLP.START_DATE    ,
                      GLP.END_DATE
              FROM    PA_PERIODS_ALL PAP    ,
                      GL_PERIODS GLP        ,
                      GL_SETS_OF_BOOKS GSOB ,
                      PA_IMPLEMENTATIONS_ALL PAIMP
              WHERE   PAP.GL_PERIOD_NAME   = GLP.PERIOD_NAME
                  AND GLP.PERIOD_SET_NAME  = GSOB.PERIOD_SET_NAME
                  AND GSOB.SET_OF_BOOKS_ID = PAIMP.SET_OF_BOOKS_ID
                  AND p_start_date        <= LEAST(PAP.END_DATE,GLP.END_DATE)
                  AND p_end_date          >= GREATEST(PAP.START_DATE,GLP.START_DATE)
                  AND PAIMP.org_id         = PAP.org_id
                  AND PAP.org_id           = p_org_id
              );

       -- check if which period has a bigger time unit ex: GL is defined as Monthly
       -- and PA periods are Weekly, GL period is greater than PA Period
       BEGIN
           SELECT 'Y'
           INTO   l_is_gl_greater
           FROM
                  (SELECT  COUNT(*)
                  FROM     PA_GL_PA_PERIODS_TMP
                  GROUP BY GL_PERIOD_NAME
                  HAVING   COUNT(*) > 1
                  )
           WHERE  rownum = 1;
       EXCEPTION
            WHEN NO_DATA_FOUND THEN
                  l_is_gl_greater := 'N';
       END;

       X_GL_GREATER_FLAG := l_is_gl_greater;
       -- whichever is the greater time unit, derive a mutiplier for each period
       -- by looking into how many smaller periods fall into the larger period
       IF l_is_gl_greater = 'Y' THEN

           UPDATE PA_GL_PA_PERIODS_TMP tmp1
           SET    multiplier =
                  (SELECT  COUNT(*)
                  FROM     PA_GL_PA_PERIODS_TMP tmp2
                  WHERE    tmp1.GL_PERIOD_NAME = tmp2.GL_PERIOD_NAME
                  GROUP BY GL_PERIOD_NAME
                  );
       ELSE
           -- two cases where l_is_gl_greater is 'N'
           -- 1) GL periods (week) have lesser time unit than PA period (month)
           -- 2) GL periods (month) have same time unit as PA period (month)
           UPDATE PA_GL_PA_PERIODS_TMP tmp1
           SET    multiplier =
                  (SELECT  COUNT(*)
                  FROM     PA_GL_PA_PERIODS_TMP tmp2
                  WHERE    tmp1.PA_PERIOD_NAME = tmp2.PA_PERIOD_NAME
                  GROUP BY PA_PERIOD_NAME
                  );
       END IF;

     IF P_PA_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.RESET_CURR_FUNCTION;
     END IF;

   EXCEPTION
        WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         rollback;
         x_msg_data      := SUBSTR(SQLERRM,1,240);
         FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_FP_GEN_FCST_AMT_PUB3'
            ,p_procedure_name => 'PROCESS_PA_GL_DATES');
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
              p_module_name => l_module_name,
              p_log_level   => 5);
              PA_DEBUG.Reset_Curr_Function;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END PROCESS_PA_GL_DATES;
   -- gboomina added for AAI Requirement bug 8318932 - end

END PA_FP_GEN_FCST_AMT_PUB3;

/
