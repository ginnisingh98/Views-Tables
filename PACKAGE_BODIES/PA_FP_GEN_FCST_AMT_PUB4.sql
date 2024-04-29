--------------------------------------------------------
--  DDL for Package Body PA_FP_GEN_FCST_AMT_PUB4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_GEN_FCST_AMT_PUB4" as
/* $Header: PAFPFG4B.pls 120.5 2007/02/06 09:51:54 dthakker ship $ */

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE GET_ETC_BDGT_COMPLETE_AMTS (
           P_SRC_RES_ASG_ID             IN PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE,
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
  l_module_name  VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_FCST_AMT_PUB4.GEN_ETC_BDGT_COMPLETE_AMTS';

  l_structure_type              VARCHAR2(30):= null;
  l_structure_status            VARCHAR2(30):= null;
  l_structure_status_flag       VARCHAR2(1):= null;
  l_wp_structure_version_id     NUMBER;
  lx_percent_complete           NUMBER;
  l_percent_complete            NUMBER;

  l_rate_based_flag             VARCHAR2(1);
  l_currency_flag               VARCHAR2(30);
  l_currency_count_flag         VARCHAR2(1);
  l_pc_currency_code            pa_projects_all.project_currency_code%type;
  l_pfc_currency_code           pa_projects_all.project_currency_code%type;
  l_rev_gen_method              VARCHAR2(3);

  l_target_version_type         pa_budget_versions.version_type%type;
  l_tot_currency_code_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
  l_tot_quantity_tab            PA_PLSQL_DATATYPES.NumTabTyp;
  l_tot_raw_cost_tab            PA_PLSQL_DATATYPES.NumTabTyp;
  l_tot_brdn_cost_tab           PA_PLSQL_DATATYPES.NumTabTyp;
  l_tot_revenue_tab             PA_PLSQL_DATATYPES.NumTabTyp;

  l_etc_quantity_tab            PA_PLSQL_DATATYPES.NumTabTyp;

  /*For average rates*/
  l_pc_rate_quantity            NUMBER;
  l_pc_rate_raw_cost            NUMBER;
  l_pc_rate_brdn_cost           NUMBER;
  l_pc_rate_revenue             NUMBER;
  l_pfc_rate_raw_cost           NUMBER;
  l_pfc_rate_brdn_cost          NUMBER;
  l_pfc_rate_revenue            NUMBER;

  l_txn_rate_quantity           NUMBER;
  l_txn_rate_raw_cost           NUMBER;
  l_txn_rate_brdn_cost          NUMBER;
  l_txn_rate_revenue            NUMBER;

  l_txn_raw_cost_rate_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  l_txn_brdn_cost_rate_tab      PA_PLSQL_DATATYPES.NumTabTyp;
  l_txn_revenue_rate_tab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_pc_raw_cost_rate_tab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_pc_brdn_cost_rate_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  l_pc_revenue_rate_tab         PA_PLSQL_DATATYPES.NumTabTyp;
  l_pfc_raw_cost_rate_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  l_pfc_brdn_cost_rate_tab      PA_PLSQL_DATATYPES.NumTabTyp;
  l_pfc_revenue_rate_tab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_transaction_source_code     VARCHAR2(30);

  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_data                        VARCHAR2(2000);
  l_msg_index_out               NUMBER:=0;

BEGIN
    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function => 'GEN_ETC_BDGT_COMPLETE_AMTS',
                                    p_debug_mode=> p_pa_debug_mode);
    END IF;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_COUNT := 0;

    /* Get percent complete from workplan side:
       For getting the financial percent complete,
       we dont have to pass the structure version id.
       It always comes from the latest published
       financial structure version. */
    IF P_ETC_SOURCE_CODE = 'FINANCIAL_PLAN' THEN
        l_structure_type := 'FINANCIAL';
    ELSE
        l_structure_type := 'WORKPLAN';
        l_wp_structure_version_id := P_WP_STRUCTURE_VERSION_ID;

        l_structure_status_flag :=
            PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(
                P_FP_COLS_TGT_REC.X_PROJECT_ID,l_wp_structure_version_id);
        IF l_structure_status_flag = 'Y' THEN
            l_structure_status := 'PUBLISHED';
        ELSE
            l_structure_status := 'WORKING';
        END IF;
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Before calling PA_PROGRESS_UTILS.REDEFAULT_BASE_PC',
             p_module_name => l_module_name,
             p_log_level   => 5);
    END IF;
    PA_PROGRESS_UTILS.REDEFAULT_BASE_PC (
        p_Project_ID            => P_FP_COLS_TGT_REC.X_PROJECT_ID,
        p_Proj_element_id       => P_TASK_ID,
        p_Structure_type        => l_structure_type,
        p_object_type           => 'PA_TASKS',
        p_As_Of_Date            => P_ACTUALS_THRU_DATE,
        P_STRUCTURE_VERSION_ID  => l_wp_structure_version_id,
        P_STRUCTURE_STATUS      => l_structure_status,
        p_calling_context       => 'FINANCIAL_PLANNING',
        X_base_percent_complete => lx_percent_complete,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data );
    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
            (p_msg         =>  'After calling PA_PROGRESS_UTILS.REDEFAULT_BASE_PC,
                                return status is:'||x_return_status,
             p_module_name => l_module_name,
             p_log_level   => 5);
    END IF;
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    l_percent_complete := NVL(lx_percent_complete,0)/100;
    IF (l_percent_complete = 1) THEN
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RETURN;
    END IF;

    IF NVL(P_TGT_RES_ASG_ID,-99)>0 THEN
        SELECT rate_based_flag
        INTO l_rate_based_flag
        FROM pa_resource_assignments
        WHERE resource_assignment_id = p_tgt_res_asg_id;
    ELSE
        l_rate_based_flag:='N';
    END IF;

   /* When generate cost based revenue version, always take PFC
       When target version is not multi currency enabled, take PC */
    l_currency_flag := 'TC';

    l_rev_gen_method := nvl(P_FP_COLS_TGT_REC.x_revenue_derivation_method,PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(P_FP_COLS_TGT_REC.x_project_id)); -- Bug 5462471
    --l_rev_gen_method := PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(P_FP_COLS_TGT_REC.x_project_id);

    IF (p_fp_cols_tgt_rec.x_version_type = 'REVENUE' and l_rev_gen_method = 'C') THEN
        l_currency_flag := 'PFC';
    ELSIF p_fp_cols_tgt_rec.X_PLAN_IN_MULTI_CURR_FLAG = 'N' THEN
        l_currency_flag := 'PC';
    END IF;

    /* No matter ETC source is 'FINANCIAL_PLAN' or 'WORKPLAN_RESOURCES',
       always get total plan amounts in PC or TC or PFC (bug fix 4102848) from financial data model.*/
    l_pc_currency_code := p_fp_cols_tgt_rec.x_project_currency_code;
    l_pfc_currency_code := p_fp_cols_tgt_rec.x_projfunc_currency_code;
    SELECT  /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
            DECODE(l_currency_flag,
                'PC', l_pc_currency_code,
                'TC', txn_currency_code,
                'PFC',l_pfc_currency_code),
            SUM(NVL(total_plan_quantity,0)),
            SUM(DECODE(l_currency_flag,
                        'PC',NVL(total_pc_raw_cost,0),
                        'TC',NVL(total_txn_raw_cost,0),
                        'PFC',NVL(total_pfc_raw_cost,0))),
            SUM(DECODE(l_currency_flag,
                        'PC', NVL(total_pc_burdened_cost,0),
                        'TC', NVL(total_txn_burdened_cost,0),
                        'PFC', NVL(total_pfc_burdened_cost,0))),
            SUM(DECODE(l_currency_flag,
                        'PC', NVL(total_pc_revenue,0),
                        'TC', NVL(total_txn_revenue,0),
                        'PFC', NVL(total_pfc_revenue,0)))
    BULK COLLECT INTO
            l_tot_currency_code_tab,
            l_tot_quantity_tab,
            l_tot_raw_cost_tab,
            l_tot_brdn_cost_tab,
            l_tot_revenue_tab
    FROM PA_FP_CALC_AMT_TMP2
    WHERE resource_assignment_id = p_src_res_asg_id
    AND transaction_source_code = p_etc_source_code
    GROUP BY DECODE(l_currency_flag, 'PC', l_pc_currency_code,
                                     'TC', txn_currency_code,
                                     'PFC',l_pfc_currency_code);

    l_target_version_type := p_fp_cols_src_rec.x_version_type;
    IF l_rate_based_flag = 'N' THEN
        l_tot_quantity_tab := l_tot_raw_cost_tab;
    END IF;

    /* Get total ETC quantity */
    FOR i IN 1..l_tot_currency_code_tab.count LOOP
        l_etc_quantity_tab(i) := l_tot_quantity_tab(i) * (1 - l_percent_complete);
    END LOOP;

    /*When not taking periodic rates, we need to calculate out the average rates
      from the source resource assignments that are mapped to the current target
      resource assignment.*/
    FOR i IN 1..l_tot_currency_code_tab.count LOOP
        SELECT  /*+ INDEX(pa_fp_calc_amt_tmp2,PA_FP_CALC_AMT_TMP2_N2)*/
                NVL(SUM(NVL(total_plan_quantity,0)),0),
                NVL(DECODE(l_currency_flag, 'TC', SUM(NVL(total_txn_raw_cost,0)),
                                            'PC', SUM(NVL(total_pc_raw_cost,0)),
                                            'PFC', SUM(NVL(total_pfc_raw_cost,0))),0),
                NVL(DECODE(l_currency_flag, 'TC', SUM(NVL(total_txn_burdened_cost,0)),
                                            'PC', SUM(NVL(total_pc_burdened_cost,0)),
                                            'PFC', SUM(NVL(total_pfc_burdened_cost,0))),0),
                NVL(DECODE(l_currency_flag, 'TC', SUM(NVL(total_txn_revenue,0)),
                                            'PC', SUM(NVL(total_pc_revenue,0)),
                                            'PFC', SUM(NVL(total_pfc_revenue,0))),0),
                NVL(SUM(NVL(total_pc_raw_cost,0)),0),
                NVL(SUM(NVL(total_pc_burdened_cost,0)),0),
                NVL(SUM(NVL(total_pc_revenue,0)),0),
                NVL(SUM(NVL(total_pfc_raw_cost,0)),0),
                NVL(SUM(NVL(total_pfc_burdened_cost,0)),0),
                NVL(SUM(NVL(total_pfc_revenue,0)),0)
        INTO    l_txn_rate_quantity,
                l_txn_rate_raw_cost,
                l_txn_rate_brdn_cost,
                l_txn_rate_revenue,
                l_pc_rate_raw_cost,
                l_pc_rate_brdn_cost,
                l_pc_rate_revenue,
                l_pfc_rate_raw_cost,
                l_pfc_rate_brdn_cost,
                l_pfc_rate_revenue
        FROM pa_fp_calc_amt_tmp2
        WHERE resource_assignment_id = p_src_res_asg_id
        AND DECODE(l_currency_flag, 'TC', txn_currency_code,
            'PC', l_tot_currency_code_tab(i),
            'PFC', l_tot_currency_code_tab(i)) = l_tot_currency_code_tab(i)
        AND transaction_source_code IN ('FINANCIAL_PLAN','WORKPLAN_RESOURCES');

        IF l_rate_based_flag = 'N' THEN
            l_txn_rate_quantity := l_txn_rate_raw_cost;
        END IF;

--        hr_utility.trace('l_txn_rate_quantity == '||l_txn_rate_quantity);
--        hr_utility.trace('l_pfc_rate_revenue == '||l_pfc_rate_revenue);
--        hr_utility.trace('l_pfc_revenue_rate_tab == '||l_pfc_rate_revenue/l_txn_rate_quantity);

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
            l_pfc_raw_cost_rate_tab(i) := l_pfc_rate_raw_cost
                                        / l_txn_rate_quantity;
            l_pfc_brdn_cost_rate_tab(i) := l_pfc_rate_brdn_cost
                                         / l_txn_rate_quantity;
            l_pfc_revenue_rate_tab(i) := l_pfc_rate_revenue
                                       / l_txn_rate_quantity;
        ELSE
            l_txn_raw_cost_rate_tab(i) := NULL;
            l_txn_brdn_cost_rate_tab(i) := NULL;
            l_txn_revenue_rate_tab(i) := NULL;
            l_pc_raw_cost_rate_tab(i) := NULL;
            l_pc_brdn_cost_rate_tab(i) := NULL;
            l_pc_revenue_rate_tab(i) := NULL;
            l_pfc_raw_cost_rate_tab(i) := NULL;
            l_pfc_brdn_cost_rate_tab(i) := NULL;
            l_pfc_revenue_rate_tab(i) := NULL;
        END IF;
    END LOOP;


    /* If commitment is not included, record is inserted directly as
       'ETC' record, if commitment is to be considered, record is
       inserted as 'TOTAL_ETC' for further processing. */
    IF P_FP_COLS_TGT_REC.X_GEN_INCL_OPEN_COMM_FLAG = 'Y' THEN
        l_transaction_source_code := 'TOTAL_ETC';
    ELSE
        l_transaction_source_code := 'ETC';
    END IF;

    /* Insert total ETC amounts */
    FORALL i IN 1..l_tot_currency_code_tab.count
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
            l_etc_quantity_tab(i) * l_pfc_raw_cost_rate_tab(i),
            l_etc_quantity_tab(i) * l_pfc_brdn_cost_rate_tab(i),
            l_etc_quantity_tab(i) * l_pfc_revenue_rate_tab(i),
            l_transaction_source_code );

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
               (p_msg         =>  'Invalid Arguments Passed',
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
        -- dbms_output.put_line('error msg :'||x_msg_data);
        FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_GEN_FCST_AMT_PUB4',
                     p_procedure_name  => 'GEN_ETC_BDGT_COMPLETE_AMTS',
                     p_error_text      => substr(sqlerrm,1,240));

        IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         =>  'Unexpected Error'||substr(sqlerrm, 1, 240),
                p_module_name => l_module_name,
                p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END GET_ETC_BDGT_COMPLETE_AMTS;

PROCEDURE GET_ETC_BDGT_COMPLETE_AMTS_BLK (
           P_SRC_RES_ASG_ID_TAB          IN PA_PLSQL_DATATYPES.IdTabTyp,
	   P_TGT_RES_ASG_ID_TAB		 IN PA_PLSQL_DATATYPES.IdTabTyp,
	   P_FP_COLS_SRC_REC_FP		 IN PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_FP_COLS_SRC_REC_WP          IN PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
	   P_FP_COLS_TGT_REC		 IN PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
	   P_TASK_ID_TAB  		 IN PA_PLSQL_DATATYPES.IdTabTyp,
	   P_RES_LIST_MEMBER_ID_TAB IN PA_PLSQL_DATATYPES.IdTabTyp,
	   P_ETC_SOURCE_CODE_TAB	 IN PA_PLSQL_DATATYPES.Char30TabTyp,
	   P_WP_STRUCTURE_VERSION_ID     IN PA_PROJ_ELEM_VER_STRUCTURE.ELEMENT_VERSION_ID%TYPE,
	   P_ACTUALS_THRU_DATE 		 IN PA_PERIODS_ALL.END_DATE%TYPE,
	   P_PLANNING_OPTIONS_FLAG	 IN VARCHAR2,
	   X_RETURN_STATUS		 OUT  NOCOPY VARCHAR2,
	   X_MSG_COUNT			 OUT  NOCOPY NUMBER,
	   X_MSG_DATA	           	 OUT  NOCOPY VARCHAR2)
IS
  l_module_name  VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_FCST_AMT_PUB4.GEN_ETC_BDGT_COMPLETE_AMTS_BLK';

  l_structure_type              VARCHAR2(30):= null;
  l_structure_status            VARCHAR2(30):= null;
  l_structure_status_flag       VARCHAR2(1):= null;
  l_wp_structure_version_id     NUMBER;
  lx_percent_complete           NUMBER;
  l_percent_complete            NUMBER;

  l_rate_based_flag             VARCHAR2(1);
  l_currency_flag               VARCHAR2(30);
  l_currency_count_flag         VARCHAR2(1);
  l_pc_currency_code            pa_projects_all.project_currency_code%type;
  l_pfc_currency_code           pa_projects_all.project_currency_code%type;
  l_rev_gen_method              VARCHAR2(3);

  l_target_version_type         pa_budget_versions.version_type%type;
  l_source_version_type         pa_budget_versions.version_type%type; /* Added for IPM */
  l_tot_currency_code_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
  l_tot_quantity_tab            PA_PLSQL_DATATYPES.NumTabTyp;
  l_tot_raw_cost_tab            PA_PLSQL_DATATYPES.NumTabTyp;
  l_tot_brdn_cost_tab           PA_PLSQL_DATATYPES.NumTabTyp;
  l_tot_revenue_tab             PA_PLSQL_DATATYPES.NumTabTyp;

  l_etc_quantity_tab            PA_PLSQL_DATATYPES.NumTabTyp;

  /*For average rates*/
  l_pc_rate_quantity            NUMBER;
  l_pc_rate_raw_cost            NUMBER;
  l_pc_rate_brdn_cost           NUMBER;
  l_pc_rate_revenue             NUMBER;
  l_pfc_rate_raw_cost           NUMBER;
  l_pfc_rate_brdn_cost          NUMBER;
  l_pfc_rate_revenue            NUMBER;

  l_txn_rate_quantity           NUMBER;
  l_txn_rate_raw_cost           NUMBER;
  l_txn_rate_brdn_cost          NUMBER;
  l_txn_rate_revenue            NUMBER;

  l_txn_raw_cost_rate_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  l_txn_brdn_cost_rate_tab      PA_PLSQL_DATATYPES.NumTabTyp;
  l_txn_revenue_rate_tab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_pc_raw_cost_rate_tab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_pc_brdn_cost_rate_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  l_pc_revenue_rate_tab         PA_PLSQL_DATATYPES.NumTabTyp;
  l_pfc_raw_cost_rate_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  l_pfc_brdn_cost_rate_tab      PA_PLSQL_DATATYPES.NumTabTyp;
  l_pfc_revenue_rate_tab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_transaction_source_code     VARCHAR2(30);

  /*Added for Bulk insert at version level*/
  l_blk_src_res_asg_id_tab      PA_PLSQL_DATATYPES.IdTabTyp;
  l_blk_tgt_res_asg_id_tab      PA_PLSQL_DATATYPES.IdTabTyp;
  l_blk_tot_currency_code_tab   PA_PLSQL_DATATYPES.Char30TabTyp;
  l_blk_etc_quantity_tab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_blk_etc_txn_rcost_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  l_blk_etc_txn_bcost_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  l_blk_etc_txn_revenue_tab     PA_PLSQL_DATATYPES.NumTabTyp;
  l_blk_etc_pc_rcost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_blk_etc_pc_bcost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_blk_etc_pc_revenue_tab      PA_PLSQL_DATATYPES.NumTabTyp;
  l_blk_etc_pfc_rcost_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  l_blk_etc_pfc_bcost_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  l_blk_etc_pfc_revenue_tab     PA_PLSQL_DATATYPES.NumTabTyp;

  continue_loop                 EXCEPTION;
  l_count                       NUMBER := 0;
  l_dummy                       NUMBER;

  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_data                        VARCHAR2(2000);
  l_msg_index_out               NUMBER:=0;

BEGIN
    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function => 'GEN_ETC_BDGT_COMPLETE_AMTS_BLK',
                                    p_debug_mode=> p_pa_debug_mode);
    END IF;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_COUNT := 0;

    IF P_SRC_RES_ASG_ID_TAB.count = 0 THEN
        RETURN;
    END IF;

    FOR main_loop IN 1..P_SRC_RES_ASG_ID_TAB.count LOOP
    BEGIN
      l_tot_currency_code_tab.delete;
      l_tot_quantity_tab.delete;
      l_tot_raw_cost_tab.delete;
      l_tot_brdn_cost_tab.delete;
      l_tot_revenue_tab.delete;

      l_txn_raw_cost_rate_tab.delete;
      l_txn_brdn_cost_rate_tab.delete;
      l_txn_revenue_rate_tab.delete;
      l_pc_raw_cost_rate_tab.delete;
      l_pc_brdn_cost_rate_tab.delete;
      l_pc_revenue_rate_tab.delete;
      l_pfc_raw_cost_rate_tab.delete;
      l_pfc_brdn_cost_rate_tab.delete;
      l_pfc_revenue_rate_tab.delete;

      l_etc_quantity_tab.delete;

      -- Bug 4346205: We need to initialize l_wp_structure_version_id and
      -- l_structure_status to NULL on each main loop iteration so that
      -- REDEFAULT_BASE_PC gives the correct percent complete for tasks
      -- with source of Financial Plan that are called after a task with
      -- source of Workplan has been processed.

      l_wp_structure_version_id := null;
      l_structure_status := null;

      /* Get percent complete from workplan side:
         For getting the financial percent complete,
         we dont have to pass the structure version id.
         It always comes from the latest published
         financial structure version. */
      IF P_ETC_SOURCE_CODE_TAB(main_loop) = 'FINANCIAL_PLAN' THEN
          l_structure_type := 'FINANCIAL';
      ELSE
          l_structure_type := 'WORKPLAN';
          l_wp_structure_version_id := P_WP_STRUCTURE_VERSION_ID;

          l_structure_status_flag :=
              PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(
                  P_FP_COLS_TGT_REC.X_PROJECT_ID,l_wp_structure_version_id);
          IF l_structure_status_flag = 'Y' THEN
              l_structure_status := 'PUBLISHED';
          ELSE
              l_structure_status := 'WORKING';
          END IF;
      END IF;

      IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_fp_gen_amount_utils.fp_debug
              (p_msg         => 'Before calling PA_PROGRESS_UTILS.REDEFAULT_BASE_PC',
               p_module_name => l_module_name,
               p_log_level   => 5);
      END IF;
      PA_PROGRESS_UTILS.REDEFAULT_BASE_PC (
          p_Project_ID            => P_FP_COLS_TGT_REC.X_PROJECT_ID,
          p_Proj_element_id       => P_TASK_ID_TAB(main_loop),
          p_Structure_type        => l_structure_type,
          p_object_type           => 'PA_TASKS',
          p_As_Of_Date            => P_ACTUALS_THRU_DATE,
          P_STRUCTURE_VERSION_ID  => l_wp_structure_version_id,
          P_STRUCTURE_STATUS      => l_structure_status,
          p_calling_context       => 'FINANCIAL_PLANNING',
          X_base_percent_complete => lx_percent_complete,
          x_return_status         => x_return_status,
          x_msg_count             => x_msg_count,
          x_msg_data              => x_msg_data );
      IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_fp_gen_amount_utils.fp_debug
              (p_msg         =>  'After calling PA_PROGRESS_UTILS.REDEFAULT_BASE_PC,
                                  return status is:'||x_return_status,
               p_module_name => l_module_name,
               p_log_level   => 5);
      END IF;
      IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      l_percent_complete := NVL(lx_percent_complete,0)/100;
      IF (l_percent_complete = 1) THEN
          RAISE continue_loop;
      END IF;

      IF NVL(P_TGT_RES_ASG_ID_TAB(main_loop),-99)>0 THEN
          SELECT rate_based_flag
          INTO l_rate_based_flag
          FROM pa_resource_assignments
          WHERE resource_assignment_id = p_tgt_res_asg_id_tab(main_loop);
      ELSE
          l_rate_based_flag:='N';
      END IF;

      /* When generate cost based revenue version, always take PFC
         When target version is not multi currency enabled, take PC */
      l_currency_flag := 'TC';
      l_rev_gen_method := nvl(P_FP_COLS_TGT_REC.x_revenue_derivation_method,PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(P_FP_COLS_TGT_REC.x_project_id)); --Bug 5462471
      --l_rev_gen_method := PA_FP_GEN_FCST_PG_PKG.GET_REV_GEN_METHOD(P_FP_COLS_TGT_REC.x_project_id);

      IF (p_fp_cols_tgt_rec.x_version_type = 'REVENUE' and l_rev_gen_method = 'C') THEN
          l_currency_flag := 'PFC';
      ELSIF p_fp_cols_tgt_rec.X_PLAN_IN_MULTI_CURR_FLAG = 'N' THEN
          l_currency_flag := 'PC';
      END IF;

      /* No matter ETC source is 'FINANCIAL_PLAN' or 'WORKPLAN_RESOURCES',
         always get total plan amounts in PC or TC or PFC (bug fix 4102848) from financial data model.*/
      l_pc_currency_code := p_fp_cols_tgt_rec.x_project_currency_code;
      l_pfc_currency_code := p_fp_cols_tgt_rec.x_projfunc_currency_code;
      SELECT  /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
              DECODE(l_currency_flag,
                  'PC', l_pc_currency_code,
                  'TC', txn_currency_code,
                  'PFC',l_pfc_currency_code),
              SUM(NVL(total_plan_quantity,0)),
              SUM(DECODE(l_currency_flag,
                          'PC',NVL(total_pc_raw_cost,0),
                          'TC',NVL(total_txn_raw_cost,0),
                          'PFC',NVL(total_pfc_raw_cost,0))),
              SUM(DECODE(l_currency_flag,
                          'PC', NVL(total_pc_burdened_cost,0),
                          'TC', NVL(total_txn_burdened_cost,0),
                          'PFC', NVL(total_pfc_burdened_cost,0))),
              SUM(DECODE(l_currency_flag,
                          'PC', NVL(total_pc_revenue,0),
                          'TC', NVL(total_txn_revenue,0),
                          'PFC', NVL(total_pfc_revenue,0)))
      BULK COLLECT INTO
              l_tot_currency_code_tab,
              l_tot_quantity_tab,
              l_tot_raw_cost_tab,
              l_tot_brdn_cost_tab,
              l_tot_revenue_tab
      FROM PA_FP_CALC_AMT_TMP2
      WHERE resource_assignment_id = p_src_res_asg_id_tab(main_loop)
      AND transaction_source_code = p_etc_source_code_tab(main_loop)
      GROUP BY DECODE(l_currency_flag, 'PC', l_pc_currency_code,
                                       'TC', txn_currency_code,
                                       'PFC',l_pfc_currency_code);

      l_target_version_type := p_fp_cols_tgt_rec.x_version_type;

      -- Get Source version tpe
      IF P_ETC_SOURCE_CODE_TAB(main_loop) = 'FINANCIAL_PLAN' THEN
          l_source_version_type := p_fp_cols_src_rec_fp.x_version_type;
      ELSE -- P_ETC_SOURCE_CODE_TAB(main_loop) = 'WORKPLAN_RESOURCES'
          l_source_version_type := p_fp_cols_src_rec_wp.x_version_type;
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

      /* Get total ETC quantity */
      FOR i IN 1..l_tot_currency_code_tab.count LOOP
          l_etc_quantity_tab(i) := l_tot_quantity_tab(i) * (1 - l_percent_complete);
      END LOOP;

      /*When not taking periodic rates, we need to calculate out the average rates
        from the source resource assignments that are mapped to the current target
        resource assignment.*/
      FOR i IN 1..l_tot_currency_code_tab.count LOOP
          SELECT  /*+ INDEX(pa_fp_calc_amt_tmp2,PA_FP_CALC_AMT_TMP2_N2)*/
                  NVL(SUM(NVL(total_plan_quantity,0)),0),
                  NVL(DECODE(l_currency_flag, 'TC', SUM(NVL(total_txn_raw_cost,0)),
                                              'PC', SUM(NVL(total_pc_raw_cost,0)),
                                              'PFC', SUM(NVL(total_pfc_raw_cost,0))),0),
                  NVL(DECODE(l_currency_flag, 'TC', SUM(NVL(total_txn_burdened_cost,0)),
                                              'PC', SUM(NVL(total_pc_burdened_cost,0)),
                                              'PFC', SUM(NVL(total_pfc_burdened_cost,0))),0),
                  NVL(DECODE(l_currency_flag, 'TC', SUM(NVL(total_txn_revenue,0)),
                                              'PC', SUM(NVL(total_pc_revenue,0)),
                                              'PFC', SUM(NVL(total_pfc_revenue,0))),0),
                  NVL(SUM(NVL(total_pc_raw_cost,0)),0),
                  NVL(SUM(NVL(total_pc_burdened_cost,0)),0),
                  NVL(SUM(NVL(total_pc_revenue,0)),0),
                  NVL(SUM(NVL(total_pfc_raw_cost,0)),0),
                  NVL(SUM(NVL(total_pfc_burdened_cost,0)),0),
                  NVL(SUM(NVL(total_pfc_revenue,0)),0)
          INTO    l_txn_rate_quantity,
                  l_txn_rate_raw_cost,
                  l_txn_rate_brdn_cost,
                  l_txn_rate_revenue,
                  l_pc_rate_raw_cost,
                  l_pc_rate_brdn_cost,
                  l_pc_rate_revenue,
                  l_pfc_rate_raw_cost,
                  l_pfc_rate_brdn_cost,
                  l_pfc_rate_revenue
          FROM pa_fp_calc_amt_tmp2
          WHERE resource_assignment_id = p_src_res_asg_id_tab(main_loop)
          AND DECODE(l_currency_flag, 'TC', txn_currency_code,
              'PC', l_tot_currency_code_tab(i),
              'PFC', l_tot_currency_code_tab(i)) = l_tot_currency_code_tab(i)
          AND transaction_source_code IN ('FINANCIAL_PLAN','WORKPLAN_RESOURCES');

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
              l_pfc_raw_cost_rate_tab(i) := l_pfc_rate_raw_cost
                                          / l_txn_rate_quantity;
              l_pfc_brdn_cost_rate_tab(i) := l_pfc_rate_brdn_cost
                                           / l_txn_rate_quantity;
              l_pfc_revenue_rate_tab(i) := l_pfc_rate_revenue
                                         / l_txn_rate_quantity;
          ELSE
              l_txn_raw_cost_rate_tab(i) := NULL;
              l_txn_brdn_cost_rate_tab(i) := NULL;
              l_txn_revenue_rate_tab(i) := NULL;
              l_pc_raw_cost_rate_tab(i) := NULL;
              l_pc_brdn_cost_rate_tab(i) := NULL;
              l_pc_revenue_rate_tab(i) := NULL;
              l_pfc_raw_cost_rate_tab(i) := NULL;
              l_pfc_brdn_cost_rate_tab(i) := NULL;
              l_pfc_revenue_rate_tab(i) := NULL;
          END IF;

          l_count := l_count + 1;
          l_blk_src_res_asg_id_tab(l_count) := P_SRC_RES_ASG_ID_TAB(main_loop);
          l_blk_tgt_res_asg_id_tab(l_count) := P_TGT_RES_ASG_ID_TAB(main_loop);
          l_blk_tot_currency_code_tab(l_count) := l_tot_currency_code_tab(i);
          l_blk_etc_quantity_tab(l_count) := l_etc_quantity_tab(i);
          l_blk_etc_txn_rcost_tab(l_count) := l_etc_quantity_tab(i) * l_txn_raw_cost_rate_tab(i);
          l_blk_etc_txn_bcost_tab(l_count) := l_etc_quantity_tab(i) * l_txn_brdn_cost_rate_tab(i);
          l_blk_etc_txn_revenue_tab(l_count) := l_etc_quantity_tab(i) * l_txn_revenue_rate_tab(i);
          l_blk_etc_pc_rcost_tab(l_count) := l_etc_quantity_tab(i) * l_pc_raw_cost_rate_tab(i);
          l_blk_etc_pc_bcost_tab(l_count) := l_etc_quantity_tab(i) * l_pc_brdn_cost_rate_tab(i);
          l_blk_etc_pc_revenue_tab(l_count) := l_etc_quantity_tab(i) * l_pc_revenue_rate_tab(i);
          l_blk_etc_pfc_rcost_tab(l_count) := l_etc_quantity_tab(i) * l_pfc_raw_cost_rate_tab(i);
          l_blk_etc_pfc_bcost_tab(l_count) := l_etc_quantity_tab(i) * l_pfc_brdn_cost_rate_tab(i);
          l_blk_etc_pfc_revenue_tab(l_count) := l_etc_quantity_tab(i) * l_pfc_revenue_rate_tab(i);
      END LOOP;

    EXCEPTION
      WHEN CONTINUE_LOOP THEN
        l_dummy := 1;
      WHEN OTHERS THEN
        RAISE;
    END;
    END LOOP; /*Main loop*/

    /* If commitment is not included, record is inserted directly as
       'ETC' record, if commitment is to be considered, record is
       inserted as 'TOTAL_ETC' for further processing. */
    IF P_FP_COLS_TGT_REC.X_GEN_INCL_OPEN_COMM_FLAG = 'Y' THEN
        l_transaction_source_code := 'TOTAL_ETC';
    ELSE
        l_transaction_source_code := 'ETC';
    END IF;

    /* Insert total ETC amounts */
    FORALL i IN 1..l_blk_tot_currency_code_tab.count
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
            TRANSACTION_SOURCE_CODE )
        VALUES (
            l_blk_src_res_asg_id_tab(i),
            l_blk_tgt_res_asg_id_tab(i),
            l_blk_tot_currency_code_tab(i),
            l_blk_etc_quantity_tab(i),
            l_blk_etc_txn_rcost_tab(i),
            l_blk_etc_txn_bcost_tab(i),
            l_blk_etc_txn_revenue_tab(i),
            l_blk_etc_pc_rcost_tab(i),
            l_blk_etc_pc_bcost_tab(i),
            l_blk_etc_pc_revenue_tab(i),
            l_blk_etc_pfc_rcost_tab(i),
            l_blk_etc_pfc_bcost_tab(i),
            l_blk_etc_pfc_revenue_tab(i),
            l_transaction_source_code );
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
               (p_msg         =>  'Invalid Arguments Passed',
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
        -- dbms_output.put_line('error msg :'||x_msg_data);
        FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_GEN_FCST_AMT_PUB4',
                     p_procedure_name  => 'GEN_ETC_BDGT_COMPLETE_AMTS_BLK',
                     p_error_text      => substr(sqlerrm,1,240));

        IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         =>  'Unexpected Error'||substr(sqlerrm, 1, 240),
                p_module_name => l_module_name,
                p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END GET_ETC_BDGT_COMPLETE_AMTS_BLK;

END PA_FP_GEN_FCST_AMT_PUB4;

/
