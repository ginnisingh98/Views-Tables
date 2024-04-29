--------------------------------------------------------
--  DDL for Package Body PA_FP_REV_GEN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_REV_GEN_PUB" as
/* $Header: PAFPGCRB.pls 120.7 2007/02/06 09:57:59 dthakker ship $ */

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE GEN_COST_BASED_REVENUE
          (P_BUDGET_VERSION_ID   IN           PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC         IN           PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_ETC_START_DATE      IN           PA_BUDGET_VERSIONS.ETC_START_DATE%TYPE,
           X_RETURN_STATUS       OUT   NOCOPY VARCHAR2,
           X_MSG_COUNT           OUT   NOCOPY NUMBER,
           X_MSG_DATA            OUT   NOCOPY VARCHAR2) IS

l_module_name         VARCHAR2(200) := 'pa.plsql.PA_FP_REV_GEN_PUB.GEN_COST_BASED_REVENUE';

l_pfc_project_value            PA_PROJECTS_ALL.PROJECT_VALUE%TYPE;
l_pc_project_value             PA_PROJECTS_ALL.PROJECT_VALUE%TYPE;
l_pfc_burdened_cost            PA_BUDGET_VERSIONS.BURDENED_COST%TYPE := 0;
l_pfc_revenue                  PA_BUDGET_VERSIONS.REVENUE%TYPE := 0;
l_rev_tab                      PA_PLSQL_DATATYPES.NumTabTyp;
l_rev                          NUMBER;
l_running_rev                  NUMBER := 0;
l_diff                         NUMBER;

l_msg_count                    NUMBER;
l_msg_data                     VARCHAR2(2000);
l_data                         VARCHAR2(2000);
l_msg_index_out                NUMBER:=0;

--l_total_cost                 PA_BUDGET_VERSIONS.BURDENED_COST%TYPE;
l_budget_line_id_tab           PA_PLSQL_DATATYPES.IdTabTyp;
l_txn_revenue_tab              PA_PLSQL_DATATYPES.NumTabTyp;
l_project_revenue_tab          PA_PLSQL_DATATYPES.NumTabTyp;
l_revenue_tab                  PA_PLSQL_DATATYPES.NumTabTyp;

l_txn_burdened_cost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
l_pc_burdened_cost_tab         PA_PLSQL_DATATYPES.NumTabTyp;
l_burdened_cost_tab            PA_PLSQL_DATATYPES.NumTabTyp;
l_quantity_tab                 PA_PLSQL_DATATYPES.NumTabTyp;

l_txn_rev_tab                  PA_PLSQL_DATATYPES.NumTabTyp;
l_pc_rev_tab                   PA_PLSQL_DATATYPES.NumTabTyp;
l_pfc_rev_tab                  PA_PLSQL_DATATYPES.NumTabTyp;
l_rev_pc_exchg_rate_tab        PA_PLSQL_DATATYPES.NumTabTyp;
l_rev_pfc_exchg_rate_tab       PA_PLSQL_DATATYPES.NumTabTyp;
l_txn_bill_rate_override_tab   PA_PLSQL_DATATYPES.NumTabTyp;


l_running_txn_rev              NUMBER := 0;
l_running_pc_rev               NUMBER := 0;
l_ratio                        NUMBER;

l_plan_class_code              PA_FIN_PLAN_TYPES_B.PLAN_CLASS_CODE%TYPE;
l_init_rev_sum                 PA_BUDGET_LINES.INIT_REVENUE%TYPE := 0;
l_pc_init_rev_sum              PA_BUDGET_LINES.PROJECT_INIT_REVENUE%TYPE := 0;
l_burdened_cost_sum            PA_BUDGET_LINES.BURDENED_COST%TYPE;

l_appr_cost_plan_type_flag     PA_BUDGET_VERSIONS.APPROVED_COST_PLAN_TYPE_FLAG%TYPE;
l_appr_rev_plan_type_flag      PA_BUDGET_VERSIONS.APPROVED_COST_PLAN_TYPE_FLAG%TYPE;
l_fin_plan_type_id             PA_PROJ_FP_OPTIONS.FIN_PLAN_TYPE_ID%TYPE;
l_version_type                 PA_BUDGET_VERSIONS.VERSION_TYPE%TYPE;
l_approved_fp_version_id       PA_PROJ_FP_OPTIONS.FIN_PLAN_VERSION_ID%TYPE;
l_approved_fp_options_id       PA_PROJ_FP_OPTIONS.PROJ_FP_OPTIONS_ID%TYPE;

l_cost_or_rev_code             VARCHAR2(30) := 'COST';

--l_pfc_burdened_cost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
l_txn_raw_cost_tab             PA_PLSQL_DATATYPES.NumTabTyp;
l_pc_raw_cost_tab              PA_PLSQL_DATATYPES.NumTabTyp;
l_pfc_raw_cost_tab             PA_PLSQL_DATATYPES.NumTabTyp;

l_res_asg_id_tab               PA_PLSQL_DATATYPES.IdTabTyp;
l_start_date_tab               PA_PLSQL_DATATYPES.DateTabTyp;
l_eliminated_flag_tab          PA_PLSQL_DATATYPES.Char1TabTyp;

l_budget_line_id_tmp           PA_BUDGET_LINES.BUDGET_LINE_ID%TYPE;
l_res_asg_id_tmp               PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE;
l_start_date_tmp               PA_BUDGET_LINES.START_DATE%TYPE;
l_txn_currency_code_tmp        PA_BUDGET_LINES.TXN_CURRENCY_CODE%TYPE;
l_budget_line_id_dup           PA_BUDGET_LINES.BUDGET_LINE_ID%TYPE;

l_upd_count                    NUMBER := 0;
l_del_count                    NUMBER := 0;
l_dup_bl_id                    NUMBER;
l_budget_line_id_upd_tab       PA_PLSQL_DATATYPES.IdTabTyp;
l_budget_line_id_del_tab       PA_PLSQL_DATATYPES.IdTabTyp;
l_txn_burdened_cost_upd_tab    PA_PLSQL_DATATYPES.NumTabTyp;
l_pc_burdened_cost_upd_tab     PA_PLSQL_DATATYPES.NumTabTyp;
l_pfc_burdened_cost_upd_tab    PA_PLSQL_DATATYPES.NumTabTyp;

l_txn_raw_cost_upd_tab         PA_PLSQL_DATATYPES.NumTabTyp;
l_pc_raw_cost_upd_tab          PA_PLSQL_DATATYPES.NumTabTyp;
l_pfc_raw_cost_upd_tab         PA_PLSQL_DATATYPES.NumTabTyp;

l_txn_revenue_upd_tab          PA_PLSQL_DATATYPES.NumTabTyp;
l_pc_revenue_upd_tab           PA_PLSQL_DATATYPES.NumTabTyp;
l_pfc_revenue_upd_tab          PA_PLSQL_DATATYPES.NumTabTyp;

l_quantity_upd_tab             PA_PLSQL_DATATYPES.NumTabTyp;

l_dup_bl_num                   NUMBER;
l_bill_amt_pfc_revenue         NUMBER;
l_bill_amt_pc_revenue          NUMBER;

l_txn_currency_code_tab        PA_PLSQL_DATATYPES.Char30TabTyp;

--Added foll 3 variables for bug 4127427 to calculate l_ratio for PC seperately
l_pc_burdened_cost             PA_BUDGET_LINES.PROJECT_BURDENED_COST%TYPE := 0;
l_pc_revenue                   PA_BUDGET_LINES.PROJECT_REVENUE%TYPE := 0;
l_ratio_pc                     NUMBER;

/* Variables added for Bug 4549862 */
l_gen_src_code                  PA_PROJ_FP_OPTIONS.GEN_COST_SRC_CODE%TYPE;

-- Variables added for IPM Enhancements
l_ra_id_tab                PA_PLSQL_DATATYPES.IdTabTyp;
l_ipm_currency_code_tab    PA_PLSQL_DATATYPES.Char15TabTyp;
l_rc_rate_override_tab     PA_PLSQL_DATATYPES.NumTabTyp;
l_bc_rate_override_tab     PA_PLSQL_DATATYPES.NumTabTyp;
l_calling_module           VARCHAR2(30);

-- Added in IPM to track if a record in the existing set of
-- pl/sql tables needs to be removed.
l_remove_record_flag_tab       PA_PLSQL_DATATYPES.Char1TabTyp;
l_remove_records_flag          VARCHAR2(1);

l_tmp_index                    NUMBER;
l_tmp_budget_line_id_tab       PA_PLSQL_DATATYPES.IdTabTyp;
l_tmp_txn_burdened_cost_tab    PA_PLSQL_DATATYPES.NumTabTyp;
l_tmp_pc_burdened_cost_tab     PA_PLSQL_DATATYPES.NumTabTyp;
l_tmp_burdened_cost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
l_tmp_quantity_tab             PA_PLSQL_DATATYPES.NumTabTyp;
l_tmp_txn_raw_cost_tab         PA_PLSQL_DATATYPES.NumTabTyp;
l_tmp_pc_raw_cost_tab          PA_PLSQL_DATATYPES.NumTabTyp;
l_tmp_pfc_raw_cost_tab         PA_PLSQL_DATATYPES.NumTabTyp;
l_tmp_res_asg_id_tab           PA_PLSQL_DATATYPES.IdTabTyp;
l_tmp_start_date_tab           PA_PLSQL_DATATYPES.DateTabTyp;
l_tmp_txn_currency_code_tab    PA_PLSQL_DATATYPES.Char30TabTyp;
l_tmp_txn_revenue_tab          PA_PLSQL_DATATYPES.NumTabTyp;
l_tmp_project_revenue_tab      PA_PLSQL_DATATYPES.NumTabTyp;
l_tmp_revenue_tab              PA_PLSQL_DATATYPES.NumTabTyp;

BEGIN
    /* Setting initial values */
    X_MSG_COUNT := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.SET_CURR_FUNCTION
            ( p_function    => 'GEN_COMMITMENT_AMOUNTS',
              p_debug_mode  =>  p_pa_debug_mode );
    END IF;

    IF p_fp_cols_rec.x_version_type = 'ALL' THEN
       l_cost_or_rev_code := 'COST';
    ELSE
       l_cost_or_rev_code := 'REVENUE';
    END IF;

    SELECT    fpt.PLAN_CLASS_CODE
    INTO      l_plan_class_code
    FROM      PA_BUDGET_VERSIONS bv,
              PA_FIN_PLAN_TYPES_B fpt
    WHERE     bv.BUDGET_VERSION_ID = P_BUDGET_VERSION_ID
    AND       bv.fin_plan_type_id  = fpt.fin_plan_type_id;

    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg          => 'Value of l_plan_class_code: '||l_plan_class_code,
              p_module_name  => l_module_name,
              p_log_level    => 5 );
     END IF;
   --dbms_output.put_line('Value of l_plan_class_code: '||l_plan_class_code);

    -- Bug 4549862: Initialize new l_gen_src_code variable.
    IF l_plan_class_code = 'BUDGET' THEN
        l_gen_src_code := p_fp_cols_rec.x_gen_src_code;
    ELSIF l_plan_class_code = 'FORECAST' THEN
        l_gen_src_code := p_fp_cols_rec.x_gen_etc_src_code;
    END IF;


    -- IPM : New Entity ER  --------------------------------------
    --       When the source/target planning options match, source
    --       override rates are copied to the target version in the
    --       new entity table (pa_resource_asgn_curr).
    --       When the Revenue Accrual Method is COST, all source
    --       override rates are not applicable, since revenue is
    --       derived from cost amounts.
    --       Therefore, call the MAINTAIN_DATA API in Insert mode
    --       with existing cost override rates and Null for bill
    --       rate overrides.
    -- Note: It is not necessary to actually check if the source/
    --       target planning options match to clean up the bill
    --       rate override rates.
    -- Note: In some cases, we do not have to worry about cleaning
    --       up the bill rate overrides. For example, if the source
    --       is a Cost-only version. We currently do not have the
    --       source version type readily available. This will be
    --       added in the near future to avoid uneccessary processing.

    -- Get existing cost rate overrides from pa_resource_asgn_curr.
    IF p_fp_cols_rec.x_gen_ret_manual_line_flag = 'N' THEN
	SELECT rbc.resource_assignment_id,
	       rbc.txn_currency_code,
	       rbc.txn_raw_cost_rate_override,
	       rbc.txn_burden_cost_rate_override
        BULK COLLECT
        INTO   l_ra_id_tab,
               l_ipm_currency_code_tab,
               l_rc_rate_override_tab,
               l_bc_rate_override_tab
	FROM   pa_resource_asgn_curr rbc
	WHERE  rbc.budget_version_id = p_budget_version_id;
    ELSIF p_fp_cols_rec.x_gen_ret_manual_line_flag = 'Y' THEN
        -- Only get data for non-manually added resources.
	SELECT rbc.resource_assignment_id,
	       rbc.txn_currency_code,
	       rbc.txn_raw_cost_rate_override,
	       rbc.txn_burden_cost_rate_override
        BULK COLLECT
        INTO   l_ra_id_tab,
               l_ipm_currency_code_tab,
               l_rc_rate_override_tab,
               l_bc_rate_override_tab
	FROM   pa_resource_asgn_curr rbc,
	       pa_resource_assignments ra
	WHERE  rbc.budget_version_id = p_budget_version_id
	AND    rbc.resource_assignment_id = ra.resource_assignment_id
	AND   (ra.transaction_source_code IS NOT NULL
	       OR (ra.transaction_source_code IS NULL
	           AND NOT EXISTS (SELECT null
	                           FROM   pa_budget_lines bl
	                           WHERE  bl.resource_assignment_id =
	                                  ra.resource_assignment_id )));
    END IF; -- x_gen_ret_manual_line_flag check

    -- If there are any new entity records to update, then
    -- populate the temp table and call the MAINTAIN_DATA API
    -- in Insert mode to overwrite existing records with just
    -- cost rate overrides and Null bill rate overrides.
    IF l_ra_id_tab.count > 0 THEN

        DELETE pa_resource_asgn_curr_tmp;

        FORALL i IN 1..l_ra_id_tab.count
            INSERT INTO pa_resource_asgn_curr_tmp (
                resource_assignment_id,
                txn_currency_code,
                txn_raw_cost_rate_override,
                txn_burden_cost_rate_override )
            VALUES (
                l_ra_id_tab(i),
                l_ipm_currency_code_tab(i),
                l_rc_rate_override_tab(i),
                l_bc_rate_override_tab(i) );

        IF l_plan_class_code = 'BUDGET' THEN
            l_calling_module := PA_RES_ASG_CURRENCY_PUB.G_BUDGET_GENERATION;
        ELSIF l_plan_class_code = 'FORECAST' THEN
            l_calling_module := PA_RES_ASG_CURRENCY_PUB.G_FORECAST_GENERATION;
        END IF;

        -- Call the maintenance api in INSERT mode
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG                   => 'Before calling PA_RES_ASG_CURRENCY_PUB.' ||
                                           'MAINTAIN_DATA',
              --P_CALLED_MODE           => p_called_mode,
                P_MODULE_NAME           => l_module_name);
        END IF;
        PA_RES_ASG_CURRENCY_PUB.MAINTAIN_DATA
              ( P_FP_COLS_REC           => p_fp_cols_rec,
                P_CALLING_MODULE        => l_calling_module,
                P_ROLLUP_FLAG           => 'N',
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

    END IF; --IF l_ra_id_tab.count > 0 THEN

    -- END OF IPM : New Entity ER  --------------------------------------


    SELECT NVL(APPROVED_COST_PLAN_TYPE_FLAG, 'N'),
           NVL(APPROVED_REV_PLAN_TYPE_FLAG, 'N')
           INTO
           l_appr_cost_plan_type_flag,
           l_appr_rev_plan_type_flag
    FROM PA_BUDGET_VERSIONS
    WHERE BUDGET_VERSION_ID = P_BUDGET_VERSION_ID;

    IF l_appr_cost_plan_type_flag = 'Y' OR
       l_appr_rev_plan_type_flag = 'Y' THEN
        BEGIN
            SELECT PROJFUNC_OPP_VALUE,
                   PROJECT_OPP_VALUE
            INTO   l_pfc_project_value,
                   l_pc_project_value
            FROM   PA_PROJECT_OPP_ATTRS
            WHERE  PROJECT_ID = P_FP_COLS_REC.X_PROJECT_ID;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_pfc_project_value := null;
                l_pc_project_value  := null;
        END;
    ELSE
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( P_MSG           => 'Before calling PA_FIN_PLAN_UTILS.'||
                                     'Get_Appr_Rev_Plan_Type_Info',
                  P_MODULE_NAME   => l_module_name,
                  P_LOG_LEVEL     => 5 );
        END IF;
        PA_FIN_PLAN_UTILS.Get_Appr_Rev_Plan_Type_Info
            ( p_project_id            => P_FP_COLS_REC.X_PROJECT_ID,
              x_plan_type_id          => l_fin_plan_type_id,
              x_return_status         => x_return_status,
              x_msg_count             => x_msg_count,
              x_msg_data              => x_msg_data );
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( P_MSG               => 'After calling PA_FIN_PLAN_UTILS.'||
                                         'Get_Appr_Rev_Plan_Type_Info: '||x_return_status,
                  P_MODULE_NAME       => l_module_name,
                  P_LOG_LEVEL         => 5 );
        END IF;
        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
        IF (l_fin_plan_type_id IS NULL) THEN
            BEGIN
                SELECT PROJFUNC_OPP_VALUE,
                       PROJECT_OPP_VALUE
                INTO   l_pfc_project_value,
                       l_pc_project_value
                FROM   PA_PROJECT_OPP_ATTRS
                WHERE  PROJECT_ID = P_FP_COLS_REC.X_PROJECT_ID;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_pfc_project_value := null;
                    l_pc_project_value  := null;
            END;
        ELSE
            SELECT DECODE( FIN_PLAN_PREFERENCE_CODE,
                           'REVENUE_ONLY',      'REVENUE' ,
                           'COST_AND_REV_SEP',  'REVENUE',
                           'COST_AND_REV_SAME', 'ALL')
            INTO   l_version_type
            FROM   pa_proj_fp_options
            WHERE  fin_plan_type_id = l_fin_plan_type_id
            AND    fin_plan_option_level_code = 'PLAN_TYPE'
            AND    project_id =  P_FP_COLS_REC.X_PROJECT_ID;

            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                    ( P_MSG            => 'Before calling PA_FP_GEN_AMOUNT_UTILS.'||
                                          'Get_Curr_Original_Version_Info',
                      P_MODULE_NAME    => l_module_name,
                      P_LOG_LEVEL      => 5 );
            END IF;
            PA_FP_GEN_AMOUNT_UTILS.Get_Curr_Original_Version_Info
                ( p_project_id              => P_FP_COLS_REC.X_PROJECT_ID,
                  p_fin_plan_type_id        => l_fin_plan_type_id,
                  p_version_type            => l_version_type,
                  p_status_code             => 'CURRENT_APPROVED',
                  x_fp_options_id           => l_approved_fp_options_id,
                  x_fin_plan_version_id     => l_approved_fp_version_id,
                  x_return_status           => x_return_status,
                  x_msg_count               => x_msg_count,
                  x_msg_data                => x_msg_data );
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                    ( P_MSG            => 'After calling PA_FP_GEN_AMOUNT_UTILS.'||
                                          'Get_Curr_Original_Version_Info: '||x_return_status,
                      P_MODULE_NAME    => l_module_name,
                      P_LOG_LEVEL      => 5 );
            END IF;
            IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            IF (l_approved_fp_version_id IS NULL) THEN
                BEGIN
                    SELECT PROJFUNC_OPP_VALUE,
                           PROJECT_OPP_VALUE
                    INTO   l_pfc_project_value,
                           l_pc_project_value
                    FROM   PA_PROJECT_OPP_ATTRS
                    WHERE  PROJECT_ID = P_FP_COLS_REC.X_PROJECT_ID;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_pfc_project_value := null;
                        l_pc_project_value  := null;
                END;
            ELSE
                l_pfc_project_value := 0;
                l_pc_project_value  := 0;
                SELECT NVL(REVENUE,0),
                       NVL(TOTAL_PROJECT_REVENUE,0)
                INTO   l_pfc_project_value,
                       l_pc_project_value
                FROM   PA_BUDGET_VERSIONS
                WHERE  BUDGET_VERSION_ID = l_approved_fp_version_id;
            END IF;
        END IF;
    END IF;

    IF NVL(l_pc_project_value,0) = 0 OR
       NVL(l_pfc_project_value,0) = 0 THEN
        PA_UTILS.ADD_MESSAGE
            ( p_app_short_name => 'PA',
              p_msg_name       => 'PA_FCST_NO_PRJ_VALUE' );
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF P_FP_COLS_REC.X_GEN_INCL_BILL_EVENT_FLAG = 'Y' THEN
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( P_MSG            => 'Before calling PA_FP_GEN_BILLING_AMOUNTS.'
                                      ||'GET_BILLING_EVENT_AMT_IN_PFC',
                  P_MODULE_NAME    => l_module_name,
                  P_LOG_LEVEL      => 5 );
        END IF;
        -- Added p_fp_cols_rec parameter for changes made for Bug 4067837.
        PA_FP_GEN_BILLING_AMOUNTS.GET_BILLING_EVENT_AMT_IN_PFC
            ( P_PROJECT_ID             =>  P_FP_COLS_REC.X_PROJECT_ID,
              P_BUDGET_VERSION_ID      =>  P_BUDGET_VERSION_ID,
              P_FP_COLS_REC            =>  P_FP_COLS_REC,
              P_PROJFUNC_CURRENCY_CODE =>  P_FP_COLS_REC.X_PROJFUNC_CURRENCY_CODE,
              P_PROJECT_CURRENCY_CODE  =>  P_FP_COLS_REC.X_PROJECT_CURRENCY_CODE,
              X_PROJFUNC_REVENUE       =>  l_bill_amt_pfc_revenue,
              X_PROJECT_REVENUE        =>  l_bill_amt_pc_revenue,
              X_RETURN_STATUS          =>  x_return_status,
              X_MSG_COUNT              =>  x_msg_count,
              X_MSG_DATA               =>  x_msg_data );
        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( P_MSG            => 'After calling PA_FP_GEN_BILLING_AMOUNTS.'
                                      ||'GET_BILLING_EVENT_AMT_IN_PFC',
                  P_MODULE_NAME    => l_module_name,
                  P_LOG_LEVEL      => 5);
        END IF;
    END IF;
    --dbms_output.put_line('l_pfc_project_value:'||l_pfc_project_value);
    --dbms_output.put_line('l_bill_amt_pfc_revenue:'||l_bill_amt_pfc_revenue);
    l_pfc_project_value := l_pfc_project_value - NVL(l_bill_amt_pfc_revenue,0);
    l_pc_project_value := l_pc_project_value - NVL(l_bill_amt_pc_revenue,0);

    IF p_pa_debug_mode = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
            ( p_msg         => 'Value of l_pfc_project_value: '
                               || l_pfc_project_value,
              p_module_name => l_module_name,
              p_log_level   => 5 );
        pa_fp_gen_amount_utils.fp_debug
            ( p_msg         => 'Value of l_pc_project_value: '
                               || l_pc_project_value,
              p_module_name => l_module_name,
              p_log_level   => 5 );
    END IF;

    -- Bug 4549862: Moved logic for actual revenue sum to this
    -- point in the code to avoid duplicating shared code for the
    -- resource schedule and non-resource-schedule flows later.

    IF l_plan_class_code = 'FORECAST' THEN

        -- Bug 4549862: Split query for actual revenue sum into
        -- 2 separate queries with different WHERE clauses to
        -- eliminate the DECODE statment on target time phase.

        IF p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
            SELECT    nvl(sum(nvl(init_revenue,0)),0),
                      nvl(sum(nvl(project_init_revenue,0)),0)
            INTO      l_init_rev_sum,
                      l_pc_init_rev_sum
            FROM      pa_budget_lines
            WHERE     budget_version_id = p_budget_version_id
            AND       start_date <= p_etc_start_date - 1;
        ELSIF p_fp_cols_rec.x_time_phased_code = 'N' THEN
            SELECT    nvl(sum(nvl(init_revenue,0)),0),
                      nvl(sum(nvl(project_init_revenue,0)),0)
            INTO      l_init_rev_sum,
                      l_pc_init_rev_sum
            FROM      pa_budget_lines
            WHERE     budget_version_id = p_budget_version_id;
        END IF;

        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_msg         => 'Value of l_init_rev_sum when the '
                                   || 'plan_class_code is FORECAST:'
                                   || l_init_rev_sum,
                  p_module_name => l_module_name,
                  p_log_level   => 5 );
        END IF;
        /*dbms_output.put_line('Value of l_init_rev_sum when the plan_class_code is FORECAST:'
                             ||l_init_rev_sum);*/

        l_pfc_project_value := l_pfc_project_value - l_init_rev_sum;
        l_pc_project_value  := l_pc_project_value - l_pc_init_rev_sum;

        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_msg         => 'Value of l_pfc_project_value when the '
                                   || 'plan_class_code is FORECAST: '
                                   || l_pfc_project_value,
                  p_module_name => l_module_name,
                  p_log_level   => 5 );
            pa_fp_gen_amount_utils.fp_debug
                ( p_msg         => 'Value of l_pc_project_value when the '
                                   || 'plan_class_code is FORECAST: '
                                   || l_pc_project_value,
                  p_module_name => l_module_name,
                  p_log_level   => 5 );
        END IF;
        /* dbms_output.put_line('Value of l_pfc_project_value when the plan_class_code is FORECAST:'
                             ||l_pfc_project_value);*/

    END IF; -- l_plan_class_code = 'FORECAST' check


    -- Bug 4549862: If Billing Event and/or Actual Revenue amounts
    -- are more than the total project value, do not generate any
    -- cost-based revenue amounts. This check is orthogonal to the
    -- main issue addresed in the bug.

    IF l_pc_project_value <= 0 OR
       l_pfc_project_value <= 0 THEN

        -- Bug 4549862: If the source is Staffing Plan, then all the budget
        -- line (quantity and cost) data is being stored in PA_FP_ROLLUP_TMP.
        -- Before returning from this API, call PUSH_RES_SCH_DATA_TO_BL to
        -- Insert/Update data from the temp table to the budget lines.

        IF l_gen_src_code = 'RESOURCE_SCHEDULE' THEN
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                    ( P_MSG            => 'Before calling PA_FP_REV_GEN_PUB.'
                                          ||'PUSH_RES_SCH_DATA_TO_BL',
                      P_MODULE_NAME    => l_module_name,
                      P_LOG_LEVEL      => 5 );
            END IF;
            PA_FP_REV_GEN_PUB.PUSH_RES_SCH_DATA_TO_BL
                ( P_BUDGET_VERSION_ID  => p_budget_version_id,
                  P_FP_COLS_REC        => p_fp_cols_rec,
                  P_ETC_START_DATE     => p_etc_start_date,
                  P_PLAN_CLASS_CODE    => l_plan_class_code,
                  X_RETURN_STATUS      => x_return_status,
                  X_MSG_COUNT          => x_msg_count,
                  X_MSG_DATA           => x_msg_data );
            IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                    ( P_MSG            => 'After calling PA_FP_REV_GEN_PUB.'
                                          ||'PUSH_RES_SCH_DATA_TO_BL',
                      P_MODULE_NAME    => l_module_name,
                      P_LOG_LEVEL      => 5);
            END IF;
        END IF; -- insert/update temp table data to budget lines

        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN;
    END IF;

    l_pfc_burdened_cost := 0;
    l_pfc_revenue := 0;

    -- Bug 4549862: When the target version is ALL, accrual method is COST,
    -- and source is Staffing Plan, fetch burdened cost sums and individual
    -- records for processing from PA_FP_ROLLUP_TMP, only selecting records
    -- with BILLABLE_FLAG = 'Y'.
    -- Note that checking l_gen_src_code determines this scenario, since
    -- accrual method is COST for the entire API and generation of Revenue-
    -- only versions from Staffing Plan is not supported.
    -- In all other cases, fetch burdened cost sums and individual records
    -- from PA_BUDGET_LINES using the existing logic.

    IF l_gen_src_code = 'RESOURCE_SCHEDULE' THEN

        IF  l_plan_class_code = 'BUDGET' THEN

            /* selecting the total burdened cost for pfc amounts. */
            BEGIN
                SELECT    nvl(sum(nvl(bl.projfunc_burdened_cost,0)),0),
                          nvl(sum(nvl(bl.project_burdened_cost,0)),0)
                INTO      l_pfc_burdened_cost,
                          l_pc_burdened_cost
                FROM      pa_fp_rollup_tmp bl,
                          pa_resource_assignments ra
                WHERE     ra.budget_version_id = p_budget_version_id
                AND       ra.resource_assignment_id = bl.resource_assignment_id
                AND       bl.cost_rejection_code is null
                AND       bl.burden_rejection_code is null
                AND       bl.pc_cur_conv_rejection_code is null
                AND       bl.pfc_cur_conv_rejection_code is null
                AND       bl.BILLABLE_FLAG = 'Y';
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_pfc_burdened_cost := 0;
            END;

            SELECT    bl.budget_line_id,
                      nvl(bl.txn_burdened_cost,0),
                      nvl(bl.project_burdened_cost,0),
                      nvl(bl.projfunc_burdened_cost,0),
                      nvl(bl.quantity,0),
                      nvl(bl.txn_raw_cost,0),
                      nvl(bl.project_raw_cost,0),
                      nvl(bl.projfunc_raw_cost,0),
                      bl.resource_assignment_id,
                      bl.start_date,
                      bl.txn_currency_code
            BULK      COLLECT
            INTO      l_budget_line_id_tab,
                      l_txn_burdened_cost_tab,
                      l_pc_burdened_cost_tab,
                      l_burdened_cost_tab,
                      l_quantity_tab,
                      l_txn_raw_cost_tab,
                      l_pc_raw_cost_tab,
                      l_pfc_raw_cost_tab,
                      l_res_asg_id_tab,
                      l_start_date_tab,
                      l_txn_currency_code_tab
            FROM      pa_fp_rollup_tmp bl,
                      pa_resource_assignments ra
            WHERE     ra.budget_version_id = p_budget_version_id
            AND       ra.resource_assignment_id = bl.resource_assignment_id
            AND       bl.cost_rejection_code is null
            AND       bl.burden_rejection_code is null
            AND       bl.pc_cur_conv_rejection_code is null
            AND       bl.pfc_cur_conv_rejection_code is null
            AND       bl.BILLABLE_FLAG = 'Y'
            ORDER BY  bl.resource_assignment_id,
                      bl.start_date;
            IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                    ( p_msg         => 'Count of l_budget_line_id_tab when the '
                                       || 'plan_class_code is BUDGET: '
                                       || l_budget_line_id_tab.count,
                      p_module_name => l_module_name,
                      p_log_level   => 5 );
            END IF;
            /* dbms_output.put_line('Count of l_budget_line_id_tab when the plan_class_code is BUDGET:'
                              ||l_budget_line_id_tab.count);*/

        ELSIF  l_plan_class_code = 'FORECAST' THEN

            -- In regards to the PA_FP_ROLLUP_TMP table, we are not maintaining
            -- the None-timephase invariant that plan amount columns store Total
            -- Amounts (planned plus actual amounts). Thus, there is no need to
            -- subtract out actual amounts in the Select statement. Furthermore,
            -- the temp table stores only ETC amounts, so checking bl.start_date
            -- >= p_etc_start_date is ok for both time phased and non-time-phased
            -- versions here.

            SELECT     bl.budget_line_id,
                       nvl(bl.txn_burdened_cost,0),
                       nvl(bl.project_burdened_cost,0),
                       nvl(bl.projfunc_burdened_cost,0),
                       nvl(bl.quantity, 0),
                       nvl(bl.txn_raw_cost,0),
                       nvl(bl.project_raw_cost,0),
                       nvl(bl.projfunc_raw_cost,0),
                       bl.resource_assignment_id,
                       bl.start_date,
                       bl.txn_currency_code
             BULK      COLLECT
             INTO      l_budget_line_id_tab,
                       l_txn_burdened_cost_tab,
                       l_pc_burdened_cost_tab,
                       l_burdened_cost_tab,
                       l_quantity_tab,
                       l_txn_raw_cost_tab,
                       l_pc_raw_cost_tab,
                       l_pfc_raw_cost_tab,
                       l_res_asg_id_tab,
                       l_start_date_tab,
                       l_txn_currency_code_tab
             FROM      pa_fp_rollup_tmp bl,
                       pa_resource_assignments ra
             WHERE     ra.budget_version_id = p_budget_version_id
             AND       ra.resource_assignment_id = bl.resource_assignment_id
             AND       bl.start_date >= p_etc_start_date
             AND       bl.cost_rejection_code is null
             AND       bl.burden_rejection_code is null
             AND       bl.pc_cur_conv_rejection_code is null
             AND       bl.pfc_cur_conv_rejection_code is null
             AND       bl.BILLABLE_FLAG = 'Y'
             ORDER BY  bl.resource_assignment_id,
                       bl.start_date;

            IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                    ( p_msg         => 'Count of l_budget_line_id_tab when the '
                                       || 'plan_class_code is FORECAST: '
                                       || l_budget_line_id_tab.count,
                      p_module_name => l_module_name,
                      p_log_level   => 5 );
            END IF;

            SELECT    nvl(sum(nvl(bl.projfunc_burdened_cost,0)),0),
                      nvl(sum(nvl(bl.project_burdened_cost,0)),0)
            INTO      l_pfc_burdened_cost,
                      l_pc_burdened_cost
            FROM      pa_fp_rollup_tmp bl,
                      pa_resource_assignments ra
            WHERE     ra.budget_version_id = p_budget_version_id
            AND       ra.resource_assignment_id = bl.resource_assignment_id
            AND       bl.start_date >= p_etc_start_date
            AND       bl.cost_rejection_code is null
            AND       bl.burden_rejection_code is null
            AND       bl.pc_cur_conv_rejection_code is null
            AND       bl.pfc_cur_conv_rejection_code is null
            AND       bl.BILLABLE_FLAG = 'Y';

            IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                ( p_msg         => 'Value of l_pfc_burdened_cost when the '
                                   || 'plan_class_code is FORECAST: '
                                   || l_pfc_burdened_cost,
                  p_module_name => l_module_name,
                  p_log_level   => 5 );
            END IF;
            /* dbms_output.put_line('Value of l_pfc_burdened_cost when the plan_class_code is FORECAST:'
                                 ||l_pfc_burdened_cost);*/

        END IF; -- plan class code check

    ELSE -- l_gen_src_code <> 'RESOURCE_SCHEDULE'

        IF  l_plan_class_code = 'BUDGET' THEN
            /* selecting the total burdened cost and revenue for pfc amounts. */
            IF P_FP_COLS_REC.x_version_type = 'ALL' THEN
                BEGIN
                    SELECT    nvl(sum(nvl(bl.burdened_cost,0)),0),
                              nvl(sum(nvl(bl.project_burdened_cost,0)),0)
                    INTO      l_pfc_burdened_cost,
                              l_pc_burdened_cost
                    FROM      pa_budget_lines bl,
                              pa_resource_assignments ra,
                              pa_tasks ta                                   /* Bug 4546405, ER 4376722 */
                    WHERE     bl.budget_version_id = p_budget_version_id
                    AND       ra.budget_version_id = p_budget_version_id
                    AND       ra.resource_assignment_id = bl.resource_assignment_id
                    AND       ra.transaction_source_code is not null
                    AND       bl.cost_rejection_code is null
                    AND       bl.revenue_rejection_code is null
                    AND       bl.burden_rejection_code is null
                    AND       bl.other_rejection_code is null
                    AND       bl.pc_cur_conv_rejection_code is null
                    AND       bl.pfc_cur_conv_rejection_code is null
                    AND       NVL(ra.task_id,0) = ta.task_id (+)            /* Bug 4546405, ER 4376722 */
                    AND       NVL(ta.billable_flag,'Y') = 'Y'               /* Bug 4546405, ER 4376722 */
                    AND       ra.project_id = P_FP_COLS_REC.X_PROJECT_ID;   /* Added for Bug 4546405 */
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_pfc_burdened_cost := 0;
                END;
            ELSE
                BEGIN
                    SELECT    nvl(sum(nvl(bl.txn_revenue,0)),0),
                              nvl(sum(nvl(bl.project_revenue,0)),0)
                    INTO      l_pfc_revenue,
                              l_pc_revenue
                    FROM      pa_budget_lines bl,
                              pa_resource_assignments ra,
                              pa_tasks ta                                   /* Bug 4546405, ER 4376722 */
                    WHERE     bl.budget_version_id = p_budget_version_id
                    AND       ra.budget_version_id = p_budget_version_id
                    AND       ra.resource_assignment_id = bl.resource_assignment_id
                    AND       ra.transaction_source_code is not null
                    AND       bl.cost_rejection_code is null
                    AND       bl.revenue_rejection_code is null
                    AND       bl.burden_rejection_code is null
                    AND       bl.other_rejection_code is null
                    AND       bl.pc_cur_conv_rejection_code is null
                    AND       bl.pfc_cur_conv_rejection_code is null
                    AND       NVL(ra.task_id,0) = ta.task_id (+)            /* Bug 4546405, ER 4376722 */
                    AND       NVL(ta.billable_flag,'Y') = 'Y'               /* Bug 4546405, ER 4376722 */
                    AND       ra.project_id = P_FP_COLS_REC.X_PROJECT_ID;   /* Added for Bug 4546405 */
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_pfc_revenue := 0;
                END;
            END IF;
            SELECT    bl.budget_line_id,
                      nvl(bl.txn_burdened_cost,0),
                      nvl(bl.project_burdened_cost,0),
                      nvl(bl.burdened_cost,0),
                      nvl(bl.txn_revenue,0),
                      nvl(bl.project_revenue,0),
                      nvl(bl.revenue,0),
                      nvl(bl.quantity,0),
                      --nvl(bl.burdened_cost,0),
                      nvl(bl.txn_raw_cost,0),
                      nvl(bl.project_raw_cost,0),
                      nvl(bl.raw_cost,0),
                      bl.resource_assignment_id,
                      bl.start_date,
                      bl.txn_currency_code
            BULK      COLLECT
            INTO      l_budget_line_id_tab,
                      l_txn_burdened_cost_tab,
                      l_pc_burdened_cost_tab,
                      l_burdened_cost_tab,
                      l_txn_revenue_tab,
                      l_project_revenue_tab,
                      l_revenue_tab,
                      l_quantity_tab,
                      --l_pfc_burdened_cost_tab,
                      l_txn_raw_cost_tab,
                      l_pc_raw_cost_tab,
                      l_pfc_raw_cost_tab,
                      l_res_asg_id_tab,
                      l_start_date_tab,
                      l_txn_currency_code_tab
            FROM      pa_budget_lines bl,
                      pa_resource_assignments ra,
                      pa_tasks ta                                   /* Bug 4546405, ER 4376722 */
            WHERE     bl.budget_version_id = p_budget_version_id
            AND       ra.budget_version_id = p_budget_version_id
            AND       ra.resource_assignment_id = bl.resource_assignment_id
            AND       ra.transaction_source_code is not null
            AND       bl.cost_rejection_code is null
            AND       bl.revenue_rejection_code is null
            AND       bl.burden_rejection_code is null
            AND       bl.other_rejection_code is null
            AND       bl.pc_cur_conv_rejection_code is null
            AND       bl.pfc_cur_conv_rejection_code is null
            AND       NVL(ra.task_id,0) = ta.task_id (+)            /* Bug 4546405, ER 4376722 */
            AND       NVL(ta.billable_flag,'Y') = 'Y'               /* Bug 4546405, ER 4376722 */
            AND       ra.project_id = P_FP_COLS_REC.X_PROJECT_ID    /* Added for Bug 4546405 */
            ORDER BY  bl.resource_assignment_id,
                      bl.start_date;
            IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                    ( p_msg         => 'Count of l_budget_line_id_tab when the '
                                       || 'plan_class_code is BUDGET: '
                                       || l_budget_line_id_tab.count,
                      p_module_name => l_module_name,
                      p_log_level   => 5 );
            END IF;
            /* dbms_output.put_line('Count of l_budget_line_id_tab when the plan_class_code is BUDGET:'
                              ||l_budget_line_id_tab.count);*/
        ELSIF  l_plan_class_code = 'FORECAST' THEN
--bbb
            IF p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
                SELECT    bl.budget_line_id,
	                          nvl(bl.txn_burdened_cost,0),
                          nvl(bl.project_burdened_cost,0),
                          nvl(bl.burdened_cost,0),
                          nvl(bl.txn_revenue,0),
                          nvl(bl.project_revenue,0),
                          nvl(bl.revenue,0),
                          nvl(bl.quantity, 0),
                          --nvl(bl.burdened_cost,0),
                          nvl(bl.txn_raw_cost,0),
                          nvl(bl.project_raw_cost,0),
                          nvl(bl.raw_cost,0),
                          bl.resource_assignment_id,
                          bl.start_date,
                          bl.txn_currency_code
                BULK      COLLECT
                INTO      l_budget_line_id_tab,
                          l_txn_burdened_cost_tab,
                          l_pc_burdened_cost_tab,
                          l_burdened_cost_tab,
                          l_txn_revenue_tab,
                          l_project_revenue_tab,
                          l_revenue_tab,
                          l_quantity_tab,
                          --l_pfc_burdened_cost_tab,
                          l_txn_raw_cost_tab,
                          l_pc_raw_cost_tab,
                          l_pfc_raw_cost_tab,
                          l_res_asg_id_tab,
                          l_start_date_tab,
                          l_txn_currency_code_tab
                FROM      pa_budget_lines bl,
                          pa_resource_assignments ra,
                          pa_tasks ta                                   /* Bug 4546405, ER 4376722 */
                WHERE     bl.budget_version_id = p_budget_version_id
                AND       ra.budget_version_id = p_budget_version_id
                AND       ra.resource_assignment_id = bl.resource_assignment_id
                AND       ra.transaction_source_code is not null
                AND       bl.start_date >= p_etc_start_date
                AND       bl.cost_rejection_code is null
                AND       bl.revenue_rejection_code is null
                AND       bl.burden_rejection_code is null
                AND       bl.other_rejection_code is null
                AND       bl.pc_cur_conv_rejection_code is null
                AND       bl.pfc_cur_conv_rejection_code is null
                AND       NVL(ra.task_id,0) = ta.task_id (+)            /* Bug 4546405, ER 4376722 */
                AND       NVL(ta.billable_flag,'Y') = 'Y'               /* Bug 4546405, ER 4376722 */
                AND       ra.project_id = P_FP_COLS_REC.X_PROJECT_ID    /* Added for Bug 4546405 */
                ORDER BY  bl.resource_assignment_id,
                          bl.start_date;
            ELSIF p_fp_cols_rec.x_time_phased_code = 'N' THEN
                -- Bug 4292083: As a result of changes for this bug, we now maintain
                -- the invariant that planned columns always store the Total amount.
                -- Since we are only interested in ETC amounts, we need to subtract
                -- out the Actual amounts.
                -- Bug 4232094: Added WHERE clause condition:
                --     NVL(bl.quantity,0) <> NVL(bl.init_quantity,0)
                -- to address the None timephase case so that we only pick up budget
                -- lines that have Plan amounts.
                SELECT    bl.budget_line_id,
                          nvl(bl.txn_burdened_cost,0) - nvl(bl.txn_init_burdened_cost,0),
                          nvl(bl.project_burdened_cost,0) - nvl(bl.project_init_burdened_cost,0),
                          nvl(bl.burdened_cost,0) - nvl(bl.init_burdened_cost,0),
                          nvl(bl.txn_revenue,0) - nvl(bl.txn_init_revenue,0),
                          nvl(bl.project_revenue,0) - nvl(bl.project_init_revenue,0),
                          nvl(bl.revenue,0) - nvl(bl.init_revenue,0),
                          nvl(bl.quantity,0) - nvl(bl.init_quantity,0),
                          --nvl(bl.burdened_cost,0) - nvl(bl.init_burdened_cost,0),
                          nvl(bl.txn_raw_cost,0) - nvl(bl.txn_init_raw_cost,0),
                          nvl(bl.project_raw_cost,0) - nvl(bl.project_init_raw_cost,0),
                          nvl(bl.raw_cost,0) - nvl(bl.init_raw_cost,0),
                          bl.resource_assignment_id,
                          bl.start_date,
                          bl.txn_currency_code
                BULK      COLLECT
                INTO      l_budget_line_id_tab,
                          l_txn_burdened_cost_tab,
                          l_pc_burdened_cost_tab,
                          l_burdened_cost_tab,
                          l_txn_revenue_tab,
                          l_project_revenue_tab,
                          l_revenue_tab,
                          l_quantity_tab,
                          --l_pfc_burdened_cost_tab,
                          l_txn_raw_cost_tab,
                          l_pc_raw_cost_tab,
                          l_pfc_raw_cost_tab,
                          l_res_asg_id_tab,
                          l_start_date_tab,
                          l_txn_currency_code_tab
                FROM      pa_budget_lines bl,
                          pa_resource_assignments ra,
                          pa_tasks ta                                   /* Bug 4546405, ER 4376722 */
                WHERE     bl.budget_version_id = p_budget_version_id
                AND       ra.budget_version_id = p_budget_version_id
                AND       ra.resource_assignment_id = bl.resource_assignment_id
                AND       ra.transaction_source_code is not null
                AND       bl.cost_rejection_code is null
                AND       bl.revenue_rejection_code is null
                AND       bl.burden_rejection_code is null
                AND       bl.other_rejection_code is null
                AND       bl.pc_cur_conv_rejection_code is null
                AND       bl.pfc_cur_conv_rejection_code is null
                AND       NVL(bl.quantity,0) <> NVL(bl.init_quantity,0)
                AND       NVL(ra.task_id,0) = ta.task_id (+)            /* Bug 4546405, ER 4376722 */
                AND       NVL(ta.billable_flag,'Y') = 'Y'               /* Bug 4546405, ER 4376722 */
                AND       ra.project_id = P_FP_COLS_REC.X_PROJECT_ID    /* Added for Bug 4546405 */
                ORDER BY  bl.resource_assignment_id,
                          bl.start_date;
            END IF; -- timephased check

            IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                    ( p_msg         => 'Count of l_budget_line_id_tab when the '
                                       || 'plan_class_code is FORECAST: '
                                       || l_budget_line_id_tab.count,
                      p_module_name => l_module_name,
                      p_log_level   => 5 );
            END IF;
            /* dbms_output.put_line('Count of l_budget_line_id_tab when the plan_class_code is FORECAST:'
                                  ||l_budget_line_id_tab.count);*/

            -- Bug 4549862: Moved query for actual revenue sum to an earlier
            -- point in the code to avoid duplicating shared code for the
            -- resource schedule and non-resource-schedule flows.

            -- Bug 4232094: Added WHERE clause condition:
            --     NVL(bl.quantity,0) <> NVL(bl.init_quantity,0)
            -- to address the None timephase case so that we only pick up budget
            -- lines that have Plan amounts.
            IF p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
                SELECT    nvl(sum(nvl(bl.burdened_cost,0)),0),
                          nvl(sum(nvl(bl.revenue,0)),0),
                          nvl(sum(nvl(bl.project_burdened_cost,0)),0),
                          nvl(sum(nvl(bl.project_revenue,0)),0)
                INTO      l_pfc_burdened_cost,
                          l_pfc_revenue,
                          l_pc_burdened_cost,
                          l_pc_revenue
                FROM      pa_budget_lines bl,
                          pa_resource_assignments ra,
                          pa_tasks ta                                   /* Bug 4546405, ER 4376722 */
                WHERE     bl.budget_version_id = p_budget_version_id
                AND       ra.budget_version_id = p_budget_version_id
                AND       ra.resource_assignment_id = bl.resource_assignment_id
                AND       ra.transaction_source_code is not null
                AND       bl.start_date >= p_etc_start_date
                AND       bl.cost_rejection_code is null
                AND       bl.revenue_rejection_code is null
                AND       bl.burden_rejection_code is null
                AND       bl.other_rejection_code is null
                AND       bl.pc_cur_conv_rejection_code is null
                AND       bl.pfc_cur_conv_rejection_code is null
                AND       NVL(ra.task_id,0) = ta.task_id (+)            /* Bug 4546405, ER 4376722 */
                AND       NVL(ta.billable_flag,'Y') = 'Y'               /* Bug 4546405, ER 4376722 */
                AND       ra.project_id = P_FP_COLS_REC.X_PROJECT_ID;   /* Added for Bug 4546405 */
            ELSIF p_fp_cols_rec.x_time_phased_code = 'N' THEN
                -- Bug 4292083: As a result of changes for this bug, we now maintain
                -- the invariant that planned columns always store the Total amount.
                -- Since we are only interested in ETC amounts, we need to subtract
                -- out the Actual amounts.
                SELECT    nvl(sum(nvl(bl.burdened_cost,0) - nvl(bl.init_burdened_cost,0)),0),
                          nvl(sum(nvl(bl.revenue,0) - nvl(bl.init_revenue,0)),0),
                          nvl(sum(nvl(bl.project_burdened_cost,0) - nvl(bl.project_init_burdened_cost,0)),0),
                          nvl(sum(nvl(bl.project_revenue,0) - nvl(bl.project_init_revenue,0)),0)
                INTO      l_pfc_burdened_cost,
                          l_pfc_revenue,
                          l_pc_burdened_cost,
                          l_pc_revenue
                FROM      pa_budget_lines bl,
                          pa_resource_assignments ra,
                          pa_tasks ta                                   /* Bug 4546405, ER 4376722 */
                WHERE     bl.budget_version_id = p_budget_version_id
                AND       ra.budget_version_id = p_budget_version_id
                AND       ra.resource_assignment_id = bl.resource_assignment_id
                AND       ra.transaction_source_code is not null
                AND       bl.cost_rejection_code is null
                AND       bl.revenue_rejection_code is null
                AND       bl.burden_rejection_code is null
                AND       bl.other_rejection_code is null
                AND       bl.pc_cur_conv_rejection_code is null
                AND       bl.pfc_cur_conv_rejection_code is null
                AND       NVL(bl.quantity,0) <> NVL(bl.init_quantity,0)
                AND       NVL(ra.task_id,0) = ta.task_id (+)            /* Bug 4546405, ER 4376722 */
                AND       NVL(ta.billable_flag,'Y') = 'Y'               /* Bug 4546405, ER 4376722 */
                AND       ra.project_id = P_FP_COLS_REC.X_PROJECT_ID;   /* Added for Bug 4546405 */
            END IF; -- timephased check

            IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                ( p_msg         => 'Value of l_pfc_burdened_cost when the '
                                   || 'plan_class_code is FORECAST: '
                                   || l_pfc_burdened_cost,
                  p_module_name => l_module_name,
                  p_log_level   => 5 );
            END IF;
            /* dbms_output.put_line('Value of l_pfc_burdened_cost when the plan_class_code is FORECAST:'
                                 ||l_pfc_burdened_cost);*/

            -- Bug 4549862: Moved subtraction of actual revenue sum from
            -- total project value to an earlier point in the code to avoid
            -- duplicating shared code for the resource schedule and
            -- non-resource-schedule flows.

        END IF; -- plan class code check

    END IF; -- resource schedule flow check

    -- Bug 4549862: Combined the three IF conditions (each in a separate
    -- set of parenthesis) into a single IF statement to avoid repeating
    -- the code to call the PUSH_RES_SCH_DATA_TO_BL API. Previously, each
    -- IF block performed the same logic to RETURN from this procedure.

    IF ( l_budget_line_id_tab.count = 0 ) OR
       ( l_cost_or_rev_code = 'COST' AND l_pfc_burdened_cost = 0 ) OR
       ( l_cost_or_rev_code = 'REVENUE' AND l_pfc_revenue  = 0 ) THEN

        -- Bug 4549862: If the source is Staffing Plan, then all the budget
        -- line (quantity and cost) data is being stored in PA_FP_ROLLUP_TMP.
        -- Before returning from this API, call PUSH_RES_SCH_DATA_TO_BL to
        -- Insert/Update data from the temp table to the budget lines.

        IF l_gen_src_code = 'RESOURCE_SCHEDULE' THEN
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                    ( P_MSG            => 'Before calling PA_FP_REV_GEN_PUB.'
                                          ||'PUSH_RES_SCH_DATA_TO_BL',
                      P_MODULE_NAME    => l_module_name,
                      P_LOG_LEVEL      => 5 );
            END IF;
            PA_FP_REV_GEN_PUB.PUSH_RES_SCH_DATA_TO_BL
                ( P_BUDGET_VERSION_ID  => p_budget_version_id,
                  P_FP_COLS_REC        => p_fp_cols_rec,
                  P_ETC_START_DATE     => p_etc_start_date,
                  P_PLAN_CLASS_CODE    => l_plan_class_code,
                  X_RETURN_STATUS      => x_return_status,
                  X_MSG_COUNT          => x_msg_count,
                  X_MSG_DATA           => x_msg_data );
            IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                    ( P_MSG            => 'After calling PA_FP_REV_GEN_PUB.'
                                          ||'PUSH_RES_SCH_DATA_TO_BL',
                      P_MODULE_NAME    => l_module_name,
                      P_LOG_LEVEL      => 5);
            END IF;
        END IF; -- insert/update temp table data to budget lines

        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN;
    END IF;

    IF l_cost_or_rev_code = 'COST' THEN
        l_ratio := l_pfc_project_value/l_pfc_burdened_cost;
        l_ratio_pc := l_pc_project_value/l_pc_burdened_cost;
    ELSIF l_cost_or_rev_code = 'REVENUE' THEN
        l_ratio := l_pfc_project_value/l_pfc_revenue;
        l_ratio_pc := l_pc_project_value/l_pc_revenue;
    END IF;

    IF p_pa_debug_mode = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
            ( p_msg         => 'Value of l_ratio, l_ratio_pc:'
                               ||l_ratio||','||l_ratio_pc,
              p_module_name => l_module_name,
              p_log_level   => 5 );
    END IF;

    -- IPM : Remove any records with zero burdened cost (which have already
    --       had NVL applied). This will avoid erroneously stamping revenue
    --       as 0 in certain cases.

    l_remove_records_flag := 'N';
    -- Initialize l_remove_record_flag_tab
    FOR i in 1..l_budget_line_id_tab.count LOOP
        l_remove_record_flag_tab(i) := 'N';
    END LOOP;

    FOR i in 1..l_budget_line_id_tab.count LOOP
        -- Note that the IF condition below will not result in a no_data_found
        -- on l_txn_revenue_tab(i) as long as the restriction is in place that
        -- generation of Revenue-only version from Staffing Plan is not supported.
        -- This is guaranteed by Case 2 of the Validate_Support_Cases() API.
        IF ( l_cost_or_rev_code = 'COST' AND l_txn_burdened_cost_tab(i) = 0 ) OR
           ( l_cost_or_rev_code = 'REVENUE' AND l_txn_revenue_tab(i) = 0 ) THEN
            l_remove_record_flag_tab(i) := 'Y';
            l_remove_records_flag := 'Y';
        END IF;
    END LOOP;

    IF l_remove_records_flag = 'Y' THEN

        -- 0. Clear out any data in the _tmp_ tables.
	l_tmp_budget_line_id_tab.delete;
	l_tmp_txn_burdened_cost_tab.delete;
	l_tmp_pc_burdened_cost_tab.delete;
	l_tmp_burdened_cost_tab.delete;
	l_tmp_quantity_tab.delete;
	l_tmp_txn_raw_cost_tab.delete;
	l_tmp_pc_raw_cost_tab.delete;
	l_tmp_pfc_raw_cost_tab.delete;
	l_tmp_res_asg_id_tab.delete;
	l_tmp_start_date_tab.delete;
	l_tmp_txn_currency_code_tab.delete;

	IF l_gen_src_code <> 'RESOURCE_SCHEDULE' THEN
	    l_tmp_txn_revenue_tab.delete;
	    l_tmp_project_revenue_tab.delete;
	    l_tmp_revenue_tab.delete;
	END IF;

        -- 1. Copy records into _tmp_ tables
        l_tmp_index := 0;
        FOR i IN 1..l_budget_line_id_tab.count LOOP
            IF l_remove_record_flag_tab(i) <> 'Y' THEN
                l_tmp_index := l_tmp_index + 1;
		l_tmp_budget_line_id_tab(l_tmp_index)    := l_budget_line_id_tab(i);
		l_tmp_txn_burdened_cost_tab(l_tmp_index) := l_txn_burdened_cost_tab(i);
		l_tmp_pc_burdened_cost_tab(l_tmp_index)  := l_pc_burdened_cost_tab(i);
		l_tmp_burdened_cost_tab(l_tmp_index)     := l_burdened_cost_tab(i);
		l_tmp_quantity_tab(l_tmp_index)          := l_quantity_tab(i);
		l_tmp_txn_raw_cost_tab(l_tmp_index)      := l_txn_raw_cost_tab(i);
		l_tmp_pc_raw_cost_tab(l_tmp_index)       := l_pc_raw_cost_tab(i);
		l_tmp_pfc_raw_cost_tab(l_tmp_index)      := l_pfc_raw_cost_tab(i);
		l_tmp_res_asg_id_tab(l_tmp_index)        := l_res_asg_id_tab(i);
		l_tmp_start_date_tab(l_tmp_index)        := l_start_date_tab(i);
		l_tmp_txn_currency_code_tab(l_tmp_index) := l_txn_currency_code_tab(i);

                IF l_gen_src_code <> 'RESOURCE_SCHEDULE' THEN
                    l_tmp_txn_revenue_tab(l_tmp_index)       := l_txn_revenue_tab(i);
                    l_tmp_project_revenue_tab(l_tmp_index)   := l_project_revenue_tab(i);
                    l_tmp_revenue_tab(l_tmp_index)           := l_revenue_tab(i);
                END IF;
            END IF;
        END LOOP;

        -- 2. Copy records from _tmp_ tables back to non-temporary tables.
		l_budget_line_id_tab    := l_tmp_budget_line_id_tab;
		l_txn_burdened_cost_tab := l_tmp_txn_burdened_cost_tab;
		l_pc_burdened_cost_tab  := l_tmp_pc_burdened_cost_tab;
		l_burdened_cost_tab     := l_tmp_burdened_cost_tab;
		l_quantity_tab          := l_tmp_quantity_tab;
		l_txn_raw_cost_tab      := l_tmp_txn_raw_cost_tab;
		l_pc_raw_cost_tab       := l_tmp_pc_raw_cost_tab;
		l_pfc_raw_cost_tab      := l_tmp_pfc_raw_cost_tab;
		l_res_asg_id_tab        := l_tmp_res_asg_id_tab;
		l_start_date_tab        := l_tmp_start_date_tab;
		l_txn_currency_code_tab := l_tmp_txn_currency_code_tab;

                IF l_gen_src_code <> 'RESOURCE_SCHEDULE' THEN
                    l_txn_revenue_tab       := l_tmp_txn_revenue_tab;
                    l_project_revenue_tab   := l_tmp_project_revenue_tab;
                    l_revenue_tab           := l_tmp_revenue_tab;
                END IF;

    END IF; -- IPM record removal logic


    -- Bug 4096111: Relaxed restriction on when we match the total
    -- revenue to the Project Opportunity Value; we now also do the
    -- matching logic whenever the target is a Revenue version. Also,
    -- reordered the IF and ELSE blocks and conditions.

    --dbms_output.put_line('Value of l_ratio:'||l_ratio);

    IF ( p_fp_cols_rec.x_plan_in_multi_curr_flag = 'N' OR
         l_appr_cost_plan_type_flag = 'Y' OR
         l_appr_rev_plan_type_flag = 'Y' OR
         p_fp_cols_rec.x_version_type = 'REVENUE' ) THEN

        FOR i in 1..l_budget_line_id_tab.count LOOP
            IF l_cost_or_rev_code = 'COST' THEN
                l_txn_rev_tab(i)  := l_txn_burdened_cost_tab(i) * l_ratio;
                l_pc_rev_tab(i)  := l_pc_burdened_cost_tab(i) * l_ratio_pc;
            ELSIF l_cost_or_rev_code = 'REVENUE' THEN
                l_txn_rev_tab(i)  := l_txn_revenue_tab(i) * l_ratio;
                l_pc_rev_tab(i)  := l_project_revenue_tab(i) * l_ratio_pc;
            END IF;

            /*Handling rounding - Start*/
            l_txn_rev_tab(i) :=  pa_currency.round_trans_currency_amt1
                    (x_amount       => l_txn_rev_tab(i),
                     x_curr_Code    => l_txn_currency_code_tab(i));
            l_pc_rev_tab(i) :=  pa_currency.round_trans_currency_amt1
                    (x_amount       => l_pc_rev_tab(i),
                     x_curr_Code    => P_FP_COLS_REC.X_PROJECT_CURRENCY_CODE);
            /*Handling rounding - End*/

            l_running_txn_rev := l_running_txn_rev + l_txn_rev_tab(i);
            l_running_pc_rev := l_running_pc_rev + l_pc_rev_tab(i);

            IF i = l_budget_line_id_tab.count THEN
                IF l_running_txn_rev <> l_pfc_project_value THEN
                    l_diff := l_pfc_project_value -l_running_txn_rev ;
                    l_txn_rev_tab(i)  := l_txn_rev_tab(i) + l_diff;
                END IF;
                IF l_running_pc_rev <> l_pc_project_value THEN
                    l_diff := l_pc_project_value -l_running_pc_rev ;
                    l_pc_rev_tab(i)  := l_pc_rev_tab(i) + l_diff;
                END IF;
            END IF;

            IF l_txn_rev_tab(i) <> 0 THEN
                l_rev_pc_exchg_rate_tab(i)  := l_pc_rev_tab(i)/l_txn_rev_tab(i);
            ELSE
                l_rev_pc_exchg_rate_tab(i)  := NULL;
            END IF;

            IF l_quantity_tab(i) <> 0 THEN
                IF l_cost_or_rev_code = 'COST' THEN
                    l_txn_bill_rate_override_tab(i):= l_txn_rev_tab(i)/l_quantity_tab(i);
                ELSIF l_cost_or_rev_code = 'REVENUE' THEN
                    l_txn_bill_rate_override_tab(i):= 1;
                END IF;
            ELSE
                l_txn_bill_rate_override_tab(i):= NULL;
            END IF;
        END LOOP;

        IF l_gen_src_code = 'RESOURCE_SCHEDULE' THEN

            FORALL j in 1..l_budget_line_id_tab.count
                UPDATE  pa_fp_rollup_tmp
                SET     txn_revenue                = l_txn_rev_tab(j),
                        projfunc_revenue           = l_txn_rev_tab(j),
                        project_revenue            = l_pc_rev_tab(j),
                        projfunc_rev_rate_type     = 'User',
                        project_rev_rate_type      = 'User'
                WHERE   budget_line_id             = l_budget_line_id_tab(j);

        ELSE -- l_gen_src_code <> 'RESOURCE_SCHEDULE'

            IF l_cost_or_rev_code = 'COST' THEN
                IF p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
                    FORALL j in 1..l_budget_line_id_tab.count
                        UPDATE  pa_budget_lines
                        SET     quantity                   = l_quantity_tab(j),
                                txn_revenue                = l_txn_rev_tab(j),
                                txn_bill_rate_override     = l_txn_bill_rate_override_tab(j),
                                revenue                    = l_txn_rev_tab(j),
                                projfunc_rev_rate_type     = 'User',
                                projfunc_rev_exchange_rate = 1,
                                project_revenue            = l_pc_rev_tab(j),
                                project_rev_rate_type      = 'User',
                                project_rev_exchange_rate  = l_rev_pc_exchg_rate_tab(j)
                        WHERE   budget_line_id             = l_budget_line_id_tab(j);
                -- Bug 4292083: As a result of changes for this bug, we now maintain
                -- the invariant that planned columns always store the Total amount.
                -- We need to add Actuals to Plan amounts.
                ELSIF p_fp_cols_rec.x_time_phased_code = 'N' THEN
                    FORALL j in 1..l_budget_line_id_tab.count
                        UPDATE  pa_budget_lines
                        SET     quantity                   = NVL(init_quantity,0) + l_quantity_tab(j),
                                txn_revenue                = NVL(txn_init_revenue,0) + l_txn_rev_tab(j),
                                txn_bill_rate_override     = l_txn_bill_rate_override_tab(j),
                                revenue                    = NVL(init_revenue,0) + l_txn_rev_tab(j),
                                projfunc_rev_rate_type     = 'User',
                                projfunc_rev_exchange_rate = 1,
                                project_revenue            = NVL(project_init_revenue,0) + l_pc_rev_tab(j),
                                project_rev_rate_type      = 'User',
                                project_rev_exchange_rate  = l_rev_pc_exchg_rate_tab(j)
                        WHERE   budget_line_id             = l_budget_line_id_tab(j);
                END IF; -- time phase check
            ELSIF l_cost_or_rev_code = 'REVENUE' THEN
                IF p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
                    FORALL jj in 1..l_budget_line_id_tab.count
                        UPDATE  pa_budget_lines
                        SET     quantity                   = l_txn_rev_tab(jj),
                                txn_revenue                = l_txn_rev_tab(jj),
                                txn_bill_rate_override     = l_txn_bill_rate_override_tab(jj),
                                revenue                    = l_txn_rev_tab(jj),
                                projfunc_rev_rate_type     = 'User',
                                projfunc_rev_exchange_rate = 1,
                                project_revenue            = l_pc_rev_tab(jj),
                                project_rev_rate_type      = 'User',
                                project_rev_exchange_rate  = l_rev_pc_exchg_rate_tab(jj)
                        WHERE   budget_line_id             = l_budget_line_id_tab(jj);
                -- Bug 4292083: As a result of changes for this bug, we now maintain
                -- the invariant that planned columns always store the Total amount.
                -- We need to add Actuals to Plan amounts.
                ELSIF p_fp_cols_rec.x_time_phased_code = 'N' THEN
                    FORALL jj in 1..l_budget_line_id_tab.count
                        UPDATE  pa_budget_lines
                        SET     quantity                   = NVL(init_quantity,0) + l_txn_rev_tab(jj),
                                txn_revenue                = NVL(txn_init_revenue,0) + l_txn_rev_tab(jj),
                                txn_bill_rate_override     = l_txn_bill_rate_override_tab(jj),
                                revenue                    = NVL(init_revenue,0) + l_txn_rev_tab(jj),
                                projfunc_rev_rate_type     = 'User',
                                projfunc_rev_exchange_rate = 1,
                                project_revenue            = NVL(project_init_revenue,0) + l_pc_rev_tab(jj),
                                project_rev_rate_type      = 'User',
                                project_rev_exchange_rate  = l_rev_pc_exchg_rate_tab(jj)
                        WHERE   budget_line_id             = l_budget_line_id_tab(jj);
                END IF; -- time phase check
            END IF;
                IF p_pa_debug_mode = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug
                        ( p_msg         => 'No. of rows updated in bdgt_lines '
                                           || 'table when multi_curr_flag is N: '
                                           || sql%rowcount,
                          p_module_name => l_module_name,
                          p_log_level   => 5 );
                END IF;
            /* dbms_output.put_line('No. of rows updated in bdgt_lines table when multi_curr_flag is N: '
                             ||sql%rowcount);*/

        END IF; -- l_gen_src_code = 'RESOURCE_SCHEDULE' check

    ELSE -- process without matching the Project Opp Value

        IF l_cost_or_rev_code = 'COST' THEN
            FOR i in 1..l_budget_line_id_tab.count LOOP
                l_txn_rev_tab(i) := l_txn_burdened_cost_tab(i) * l_ratio;
                l_pc_rev_tab(i)  := l_pc_burdened_cost_tab(i) * l_ratio_pc;
                l_pfc_rev_tab(i) := l_burdened_cost_tab(i) * l_ratio;
            END LOOP;
        ELSIF l_cost_or_rev_code = 'REVENUE' THEN
            FOR i in 1..l_budget_line_id_tab.count LOOP
                l_txn_rev_tab(i) := l_txn_revenue_tab(i) * l_ratio;
                l_pc_rev_tab(i)  := l_project_revenue_tab(i) * l_ratio_pc;
                l_pfc_rev_tab(i) := l_revenue_tab(i) * l_ratio;
            END LOOP;
        END IF;
        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_msg         => 'Value of l_txn_rev_tab.count:'||l_txn_rev_tab.count,
                  p_module_name => l_module_name,
                  p_log_level   => 5 );
        END IF;

        FOR j in 1..l_txn_rev_tab.count LOOP
            IF l_txn_rev_tab(j) <> 0 THEN
                l_rev_pc_exchg_rate_tab(j)  := l_pc_rev_tab(j)/l_txn_rev_tab(j);
                l_rev_pfc_exchg_rate_tab(j) := l_pfc_rev_tab(j)/l_txn_rev_tab(j);
            ELSE
                l_rev_pc_exchg_rate_tab(j)  := NULL;
                l_rev_pfc_exchg_rate_tab(j) := NULL;
            END IF;

            IF l_quantity_tab(j) <> 0 THEN
                IF l_cost_or_rev_code = 'COST' THEN
                    l_txn_bill_rate_override_tab(j):= l_txn_rev_tab(j)/l_quantity_tab(j);
                ELSIF l_cost_or_rev_code = 'REVENUE' THEN
                    l_txn_bill_rate_override_tab(j):= 1;
                END IF;
            ELSE
                l_txn_bill_rate_override_tab(j):= NULL;
            END IF;

            /*Handling rounding - Start*/
            l_txn_rev_tab(j) :=  pa_currency.round_trans_currency_amt1
                    (x_amount       => l_txn_rev_tab(j),
                     x_curr_Code    => l_txn_currency_code_tab(j));
            /*Handling rounding - End*/
        END LOOP;

        IF l_gen_src_code = 'RESOURCE_SCHEDULE' THEN

            FORALL k in 1..l_budget_line_id_tab.count
                UPDATE  pa_fp_rollup_tmp
                SET     txn_revenue                = l_txn_rev_tab(k),
                        projfunc_revenue           = l_pfc_rev_tab(k),
                        project_revenue            = l_pc_rev_tab(k),
                        projfunc_rev_rate_type     = 'User',
                        project_rev_rate_type      = 'User'
                WHERE   budget_line_id             = l_budget_line_id_tab(k);

        ELSE -- l_gen_src_code <> 'RESOURCE_SCHEDULE'

            IF l_cost_or_rev_code = 'COST' THEN

                IF p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
                    FORALL k in 1..l_budget_line_id_tab.count
                    UPDATE  pa_budget_lines
                    SET quantity                   = l_quantity_tab(k),
                        txn_revenue                = l_txn_rev_tab(k),
                        txn_bill_rate_override     = l_txn_bill_rate_override_tab(k),
                        project_rev_rate_type      = 'User',
                        project_rev_exchange_rate  = l_rev_pc_exchg_rate_tab(k),
                        projfunc_rev_rate_type     = 'User',
                        projfunc_rev_exchange_rate = l_rev_pfc_exchg_rate_tab(k)
                    WHERE   budget_line_id         = l_budget_line_id_tab(k);
                -- Bug 4292083: As a result of changes for this bug, we now maintain
                -- the invariant that planned columns always store the Total amount.
                -- We need to add Actuals to Plan amounts.
                ELSIF p_fp_cols_rec.x_time_phased_code = 'N' THEN
                    FORALL k in 1..l_budget_line_id_tab.count
                    UPDATE  pa_budget_lines
                    SET quantity                   = NVL(init_quantity,0) + l_quantity_tab(k),
                        txn_revenue                = NVL(txn_init_revenue,0) + l_txn_rev_tab(k),
                        txn_bill_rate_override     = l_txn_bill_rate_override_tab(k),
                        project_rev_rate_type      = 'User',
                        project_rev_exchange_rate  = l_rev_pc_exchg_rate_tab(k),
                        projfunc_rev_rate_type     = 'User',
                        projfunc_rev_exchange_rate = l_rev_pfc_exchg_rate_tab(k)
                    WHERE   budget_line_id         = l_budget_line_id_tab(k);
                END IF; -- time phase check
            ELSIF l_cost_or_rev_code = 'REVENUE' THEN
                IF p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
                    FORALL kk in 1..l_budget_line_id_tab.count
                    UPDATE  pa_budget_lines
                    SET quantity                   = l_txn_rev_tab(kk),
                        txn_revenue                = l_txn_rev_tab(kk),
                        txn_bill_rate_override     = l_txn_bill_rate_override_tab(kk),
                        project_rev_rate_type      = 'User',
                        project_rev_exchange_rate  = l_rev_pc_exchg_rate_tab(kk),
                        projfunc_rev_rate_type     = 'User',
                        projfunc_rev_exchange_rate = l_rev_pfc_exchg_rate_tab(kk)
                    WHERE   budget_line_id         = l_budget_line_id_tab(kk);
                -- Bug 4292083: As a result of changes for this bug, we now maintain
                -- the invariant that planned columns always store the Total amount.
                -- We need to add Actuals to Plan amounts.
                ELSIF p_fp_cols_rec.x_time_phased_code = 'N' THEN
                    FORALL kk in 1..l_budget_line_id_tab.count
                    UPDATE  pa_budget_lines
                    SET quantity                   = NVL(init_quantity,0) + l_txn_rev_tab(kk),
                        txn_revenue                = NVL(txn_init_revenue,0) + l_txn_rev_tab(kk),
                        txn_bill_rate_override     = l_txn_bill_rate_override_tab(kk),
                        project_rev_rate_type      = 'User',
                        project_rev_exchange_rate  = l_rev_pc_exchg_rate_tab(kk),
                        projfunc_rev_rate_type     = 'User',
                        projfunc_rev_exchange_rate = l_rev_pfc_exchg_rate_tab(kk)
                    WHERE   budget_line_id         = l_budget_line_id_tab(kk);
                END IF; -- time phase check
            END IF;
            IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                    ( p_msg         => 'No. of rows updated in bdgt_lines table '
                                       || 'when multi_curr_flag is Y: '||sql%rowcount,
                      p_module_name => l_module_name,
                      p_log_level   => 5 );
            END IF;

        END IF; -- l_gen_src_code = 'RESOURCE_SCHEDULE' check

    END IF; -- revenue calculation


    -- Bug 4549862: At this point, revenue amounts have been computed.
    -- If the source is Staffing Plan, then all the budget line data
    -- is stored in PA_FP_ROLLUP_TMP. Before returning from this API,
    -- we need to call PUSH_RES_SCH_DATA_TO_BL to Insert/Update data
    -- from the temp table to the budget lines.

    IF l_gen_src_code = 'RESOURCE_SCHEDULE' THEN

        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( P_MSG            => 'Before calling PA_FP_REV_GEN_PUB.'
                                      ||'PUSH_RES_SCH_DATA_TO_BL',
                  P_MODULE_NAME    => l_module_name,
                  P_LOG_LEVEL      => 5 );
        END IF;
        PA_FP_REV_GEN_PUB.PUSH_RES_SCH_DATA_TO_BL
            ( P_BUDGET_VERSION_ID  => p_budget_version_id,
              P_FP_COLS_REC        => p_fp_cols_rec,
              P_ETC_START_DATE     => p_etc_start_date,
              P_PLAN_CLASS_CODE    => l_plan_class_code,
              X_RETURN_STATUS      => x_return_status,
              X_MSG_COUNT          => x_msg_count,
              X_MSG_DATA           => x_msg_data );
        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( P_MSG            => 'After calling PA_FP_REV_GEN_PUB.'
                                      ||'PUSH_RES_SCH_DATA_TO_BL',
                  P_MODULE_NAME    => l_module_name,
                  P_LOG_LEVEL      => 5);
        END IF;

    END IF; -- insert/update temp table data to budget lines

    /* IF p_fp_cols_rec.x_version_type = 'REVENUE' THEN
       UPDATE pa_budget_lines
       SET    quantity = null
       WHERE  budget_version_id = p_budget_version_id;
       END IF;   */

    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.Reset_Curr_Function;
    END IF;

EXCEPTION
    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
        /** MRC Elimination changes: PA_MRC_FINPLAN.G_CALLING_MODULE := Null; **/
        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count = 1 THEN
            PA_INTERFACE_UTILS_PUB.get_messages
                ( p_encoded        => FND_API.G_TRUE
                 ,p_msg_index      => 1
                 ,p_msg_count      => l_msg_count
                 ,p_msg_data       => l_msg_data
                 ,p_data           => l_data
                 ,p_msg_index_out  => l_msg_index_out );
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
            ( p_pkg_name       => 'PA_FP_REV_GEN_PUB'
             ,p_procedure_name => 'GEN_COST_BASED_REVENUE' );

        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GEN_COST_BASED_REVENUE;

/**
 * Created as part of fix for Bug 4549862.
 *
 * This private procedure is meant to be used by GEN_COST_BASED_REVENUE
 * when generating a Cost and Revenue together version with source of
 * Staffing Plan and revenue accrual method of COST.
 *
 * This procedure propagates generation data stored in PA_FP_ROLLUP_TMP
 * and Inserts/Updates it into PA_BUDGET_LINES. This includes txn/pc/pfc
 * amounts, rate overrides, pc/pfc exchange rates, cost/revenue rate types,
 * and rejection codes.
 *
 * This API should always be called by GEN_COST_BASED_REVENUE before
 * returning with return status of Success.
 **/
PROCEDURE PUSH_RES_SCH_DATA_TO_BL
          (P_BUDGET_VERSION_ID   IN           PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC         IN           PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_ETC_START_DATE      IN           PA_BUDGET_VERSIONS.ETC_START_DATE%TYPE,
           P_PLAN_CLASS_CODE     IN           PA_FIN_PLAN_TYPES_B.PLAN_CLASS_CODE%TYPE,
           X_RETURN_STATUS       OUT   NOCOPY VARCHAR2,
           X_MSG_COUNT           OUT   NOCOPY NUMBER,
           X_MSG_DATA            OUT   NOCOPY VARCHAR2) IS

l_module_name         VARCHAR2(200) := 'pa.plsql.PA_FP_REV_GEN_PUB.PUSH_RES_SCH_DATA_TO_BL';

l_msg_count                    NUMBER;
l_msg_data                     VARCHAR2(2000);
l_data                         VARCHAR2(2000);
l_msg_index_out                NUMBER:=0;

-- This cursor should be used when the target version is
-- timephased by either PA or GL.

CURSOR   GROUP_TO_INS_INTO_BL IS
SELECT   RESOURCE_ASSIGNMENT_ID,
         TXN_CURRENCY_CODE,
         START_DATE,
         END_DATE,
         PERIOD_NAME,
         SUM(QUANTITY),
         SUM(TXN_RAW_COST),
         SUM(TXN_BURDENED_COST),
         SUM(TXN_REVENUE),
         SUM(PROJECT_RAW_COST),
         SUM(PROJECT_BURDENED_COST),
         SUM(PROJECT_REVENUE),
         SUM(PROJFUNC_RAW_COST),
         SUM(PROJFUNC_BURDENED_COST),
         SUM(PROJFUNC_REVENUE),
         COST_REJECTION_CODE,
         BURDEN_REJECTION_CODE,
         PC_CUR_CONV_REJECTION_CODE,
         PFC_CUR_CONV_REJECTION_CODE,
         PROJECT_COST_RATE_TYPE,
         PROJFUNC_COST_RATE_TYPE,
         PROJECT_REV_RATE_TYPE,
         PROJFUNC_REV_RATE_TYPE
  FROM   pa_fp_rollup_tmp
GROUP BY resource_assignment_id,
         txn_currency_code,
         start_date,
         end_date,
         period_name,
         COST_REJECTION_CODE,
         BURDEN_REJECTION_CODE,
         PC_CUR_CONV_REJECTION_CODE,
         PFC_CUR_CONV_REJECTION_CODE,
         PROJECT_COST_RATE_TYPE,
         PROJFUNC_COST_RATE_TYPE,
         PROJECT_REV_RATE_TYPE,
         PROJFUNC_REV_RATE_TYPE;

-- This cursor should be used when the target version is
-- a Budget and None timephased.
-- Assumptions:
-- 1. period_name should be populated as NULL

CURSOR   GROUP_TO_INS_INTO_NTP_BDGT_BL	 IS
SELECT   RESOURCE_ASSIGNMENT_ID,
         TXN_CURRENCY_CODE,
         MIN(START_DATE),
         MAX(END_DATE),
         PERIOD_NAME,
         SUM(QUANTITY),
         SUM(TXN_RAW_COST),
         SUM(TXN_BURDENED_COST),
         SUM(TXN_REVENUE),
         SUM(PROJECT_RAW_COST),
         SUM(PROJECT_BURDENED_COST),
         SUM(PROJECT_REVENUE),
         SUM(PROJFUNC_RAW_COST),
         SUM(PROJFUNC_BURDENED_COST),
         SUM(PROJFUNC_REVENUE),
         COST_REJECTION_CODE,
         BURDEN_REJECTION_CODE,
         PC_CUR_CONV_REJECTION_CODE,
         PFC_CUR_CONV_REJECTION_CODE,
         PROJECT_COST_RATE_TYPE,
         PROJFUNC_COST_RATE_TYPE,
         PROJECT_REV_RATE_TYPE,
         PROJFUNC_REV_RATE_TYPE
  FROM   pa_fp_rollup_tmp
GROUP BY resource_assignment_id,
         txn_currency_code,
         period_name,
         COST_REJECTION_CODE,
         BURDEN_REJECTION_CODE,
         PC_CUR_CONV_REJECTION_CODE,
         PFC_CUR_CONV_REJECTION_CODE,
         PROJECT_COST_RATE_TYPE,
         PROJFUNC_COST_RATE_TYPE,
         PROJECT_REV_RATE_TYPE,
         PROJFUNC_REV_RATE_TYPE;

-- Bug 4549862: Added cursor for when the target version is None
-- Time Phased and the context is Forecast Generation. In this
-- case, budget lines may exist with actuals. Fetch temp table
-- data for which budget lines do not yet exist, which should be
-- Inserted into pa_budget_lines.
-- The query is the same as that of GROUP_TO_INS_INTO_NTP_BDGT_BL
-- but with an additional HAVING clause to find Insert records.

CURSOR   GROUP_TO_INS_INTO_NTP_FCST_BL IS
SELECT   RESOURCE_ASSIGNMENT_ID,
         TXN_CURRENCY_CODE,
         MIN(START_DATE),
         MAX(END_DATE),
         PERIOD_NAME,
         SUM(QUANTITY),
         SUM(TXN_RAW_COST),
         SUM(TXN_BURDENED_COST),
         SUM(TXN_REVENUE),
         SUM(PROJECT_RAW_COST),
         SUM(PROJECT_BURDENED_COST),
         SUM(PROJECT_REVENUE),
         SUM(PROJFUNC_RAW_COST),
         SUM(PROJFUNC_BURDENED_COST),
         SUM(PROJFUNC_REVENUE),
         COST_REJECTION_CODE,
         BURDEN_REJECTION_CODE,
         PC_CUR_CONV_REJECTION_CODE,
         PFC_CUR_CONV_REJECTION_CODE,
         PROJECT_COST_RATE_TYPE,
         PROJFUNC_COST_RATE_TYPE,
         PROJECT_REV_RATE_TYPE,
         PROJFUNC_REV_RATE_TYPE
  FROM   pa_fp_rollup_tmp tmp
GROUP BY resource_assignment_id,
         txn_currency_code,
         period_name,
         COST_REJECTION_CODE,
         BURDEN_REJECTION_CODE,
         PC_CUR_CONV_REJECTION_CODE,
         PFC_CUR_CONV_REJECTION_CODE,
         PROJECT_COST_RATE_TYPE,
         PROJFUNC_COST_RATE_TYPE,
         PROJECT_REV_RATE_TYPE,
         PROJFUNC_REV_RATE_TYPE
HAVING ( SELECT count(*)
         FROM   pa_budget_lines bl
         WHERE  tmp.resource_assignment_id = bl.resource_assignment_id
         AND    tmp.txn_currency_code = bl.txn_currency_code ) = 0;

-- Bug 4549862: Added cursor for when the target version is None
-- Time Phased and the context is Forecast Generation. In this
-- case, budget lines may exist with actuals. Fetch temp table
-- data for which budget lines exist, which whould be Updated
-- into pa_budget_lines.
-- The query is the same as that of GROUP_TO_INS_INTO_NTP_BDGT_BL
-- but with an additional HAVING clause to find Update records.

CURSOR   GROUP_TO_UPD_INTO_NTP_FCST_BL IS
SELECT   RESOURCE_ASSIGNMENT_ID,
         TXN_CURRENCY_CODE,
         MIN(START_DATE),
         MAX(END_DATE),
         PERIOD_NAME,
         SUM(QUANTITY),
         SUM(TXN_RAW_COST),
         SUM(TXN_BURDENED_COST),
         SUM(TXN_REVENUE),
         SUM(PROJECT_RAW_COST),
         SUM(PROJECT_BURDENED_COST),
         SUM(PROJECT_REVENUE),
         SUM(PROJFUNC_RAW_COST),
         SUM(PROJFUNC_BURDENED_COST),
         SUM(PROJFUNC_REVENUE),
         COST_REJECTION_CODE,
         BURDEN_REJECTION_CODE,
         PC_CUR_CONV_REJECTION_CODE,
         PFC_CUR_CONV_REJECTION_CODE,
         PROJECT_COST_RATE_TYPE,
         PROJFUNC_COST_RATE_TYPE,
         PROJECT_REV_RATE_TYPE,
         PROJFUNC_REV_RATE_TYPE
  FROM   pa_fp_rollup_tmp tmp
GROUP BY resource_assignment_id,
         txn_currency_code,
         period_name,
         COST_REJECTION_CODE,
         BURDEN_REJECTION_CODE,
         PC_CUR_CONV_REJECTION_CODE,
         PFC_CUR_CONV_REJECTION_CODE,
         PROJECT_COST_RATE_TYPE,
         PROJFUNC_COST_RATE_TYPE,
         PROJECT_REV_RATE_TYPE,
         PROJFUNC_REV_RATE_TYPE
HAVING ( SELECT count(*)
         FROM   pa_budget_lines bl
         WHERE  tmp.resource_assignment_id = bl.resource_assignment_id
         AND    tmp.txn_currency_code = bl.txn_currency_code ) > 0;

/* Variables added for Bug 4549862 */

l_bl_RES_ASSIGNMENT_ID_tab      PA_PLSQL_DATATYPES.IDTabTyp;
l_bl_TXN_CURRENCY_CODE_tab      PA_PLSQL_DATATYPES.Char15TabTyp;
l_bl_START_DATE_tab             PA_PLSQL_DATATYPES.DateTabTyp;
l_bl_END_DATE_tab               PA_PLSQL_DATATYPES.DateTabTyp;
l_bl_PERIOD_NAME_tab            PA_PLSQL_DATATYPES.Char30TabTyp;
l_bl_QUANTITY_tab               PA_PLSQL_DATATYPES.NumTabTyp;
l_bl_TXN_RAW_COST_tab           PA_PLSQL_DATATYPES.NumTabTyp;
l_bl_TXN_BURDENED_COST_tab      PA_PLSQL_DATATYPES.NumTabTyp;
l_bl_TXN_REVENUE_tab            PA_PLSQL_DATATYPES.NumTabTyp;

l_bl_PC_RAW_COST_tab            PA_PLSQL_DATATYPES.NumTabTyp;
l_bl_PC_BURDENED_COST_tab       PA_PLSQL_DATATYPES.NumTabTyp;
l_bl_PC_REVENUE_tab             PA_PLSQL_DATATYPES.NumTabTyp;
l_bl_PFC_RAW_COST_tab           PA_PLSQL_DATATYPES.NumTabTyp;
l_bl_PFC_BURDENED_COST_tab      PA_PLSQL_DATATYPES.NumTabTyp;
l_bl_PFC_REVENUE_tab            PA_PLSQL_DATATYPES.NumTabTyp;

l_bl_COST_REJ_CODE_tab          PA_PLSQL_DATATYPES.Char30TabTyp;
l_bl_BURDEN_REJ_CODE_tab        PA_PLSQL_DATATYPES.Char30TabTyp;
l_bl_PC_CUR_REJ_CODE_tab        PA_PLSQL_DATATYPES.Char30TabTyp;
l_bl_PFC_CUR_REJ_CODE_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
l_bl_PC_COST_RT_TYPE_tab        PA_PLSQL_DATATYPES.Char30TabTyp;
l_bl_PFC_COST_RT_TYPE_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
l_bl_PC_REV_RT_TYPE_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
l_bl_PFC_REV_RT_TYPE_tab        PA_PLSQL_DATATYPES.Char30TabTyp;

l_upd_bl_RES_ASSIGNMENT_ID_tab  PA_PLSQL_DATATYPES.IDTabTyp;
l_upd_bl_TXN_CURRENCY_CODE_tab  PA_PLSQL_DATATYPES.Char15TabTyp;
l_upd_bl_START_DATE_tab         PA_PLSQL_DATATYPES.DateTabTyp;
l_upd_bl_END_DATE_tab           PA_PLSQL_DATATYPES.DateTabTyp;
l_upd_bl_PERIOD_NAME_tab        PA_PLSQL_DATATYPES.Char30TabTyp;
l_upd_bl_QUANTITY_tab           PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_bl_TXN_RAW_COST_tab       PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_bl_TXN_BURDENED_COST_tab  PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_bl_TXN_REVENUE_tab        PA_PLSQL_DATATYPES.NumTabTyp;

l_upd_bl_PC_RAW_COST_tab        PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_bl_PC_BURDENED_COST_tab   PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_bl_PC_REVENUE_tab         PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_bl_PFC_RAW_COST_tab       PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_bl_PFC_BURDENED_COST_tab  PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_bl_PFC_REVENUE_tab        PA_PLSQL_DATATYPES.NumTabTyp;

l_upd_bl_COST_REJ_CODE_tab      PA_PLSQL_DATATYPES.Char30TabTyp;
l_upd_bl_BURDEN_REJ_CODE_tab    PA_PLSQL_DATATYPES.Char30TabTyp;
l_upd_bl_PC_CUR_REJ_CODE_tab    PA_PLSQL_DATATYPES.Char30TabTyp;
l_upd_bl_PFC_CUR_REJ_CODE_tab   PA_PLSQL_DATATYPES.Char30TabTyp;
l_upd_bl_PC_COST_RT_TYPE_tab    PA_PLSQL_DATATYPES.Char30TabTyp;
l_upd_bl_PFC_COST_RT_TYPE_tab   PA_PLSQL_DATATYPES.Char30TabTyp;
l_upd_bl_PC_REV_RT_TYPE_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
l_upd_bl_PFC_REV_RT_TYPE_tab    PA_PLSQL_DATATYPES.Char30TabTyp;

l_cost_pc_exchg_rate_tab        PA_PLSQL_DATATYPES.NumTabTyp;
l_cost_pfc_exchg_rate_tab       PA_PLSQL_DATATYPES.NumTabTyp;

l_rev_pc_exchg_rate_tab         PA_PLSQL_DATATYPES.NumTabTyp;
l_rev_pfc_exchg_rate_tab        PA_PLSQL_DATATYPES.NumTabTyp;

l_txn_rcost_rate_override_tab   PA_PLSQL_DATATYPES.NumTabTyp;
l_txn_bcost_rate_override_tab   PA_PLSQL_DATATYPES.NumTabTyp;
l_txn_bill_rate_override_tab    PA_PLSQL_DATATYPES.NumTabTyp;

l_upd_cost_pc_exchg_rate_tab    PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_cost_pfc_exchg_rate_tab   PA_PLSQL_DATATYPES.NumTabTyp;

l_upd_rev_pc_exchg_rate_tab     PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_rev_pfc_exchg_rate_tab    PA_PLSQL_DATATYPES.NumTabTyp;

l_upd_rcost_rate_override_tab   PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_bcost_rate_override_tab   PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_bill_rate_override_tab    PA_PLSQL_DATATYPES.NumTabTyp;

l_last_updated_by               NUMBER := FND_GLOBAL.user_id;
l_last_update_login             NUMBER := FND_GLOBAL.login_id;
l_sysdate                       DATE   := SYSDATE;

BEGIN
    /* Setting initial values */
    X_MSG_COUNT := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.SET_CURR_FUNCTION
            ( p_function    => 'PUSH_RES_SCH_DATA_TO_BL',
              p_debug_mode  =>  p_pa_debug_mode );
    END IF;

    -- Bug 4549862: Update pc/pfc rate types to 'User' in PA_FP_ROLLUP_TMP:
    -- 1. Revenue rate types will always be 'User', so no update needed.
    -- 2. Cost rate types for records of a given (resource assignment, txn
    --    currency, period) combination need to be updated if any record for
    --    that combination has cost rate type as 'User'. This will be the
    --    case if a commitment exists for the given combination.

    -- Bug 4619257: Update pc/pfc rate types to 'User' in PA_FP_ROLLUP_TMP:
    -- 1. The assumption that Revenue rate types will always be 'User' is
    --    incorrect when some of the assignments mapping to a resource are
    --    billable and other are non-billable.
    --    Revenue rate types for records of a given (resource assignment,
    --    txn currency, period) combination need to be updated if any
    --    record for that combination has revenue rate type as 'User'.

    IF p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
        -- Update Project Functional currency cost rate type
        UPDATE pa_fp_rollup_tmp tmp
        SET    projfunc_cost_rate_type = 'User'
        WHERE  projfunc_cost_rate_type <> 'User'
        AND    EXISTS ( SELECT null
                        FROM   pa_fp_rollup_tmp tmp2
                        WHERE  tmp2.resource_assignment_id = tmp.resource_assignment_id
                        AND    tmp2.txn_currency_code = tmp.txn_currency_code
                        AND    tmp2.start_date = tmp.start_date
                        AND    tmp2.projfunc_cost_rate_type = 'User' );

        -- Update Project currency cost rate type
        UPDATE pa_fp_rollup_tmp tmp
        SET    project_cost_rate_type = 'User'
        WHERE  project_cost_rate_type <> 'User'
        AND    EXISTS ( SELECT null
                        FROM   pa_fp_rollup_tmp tmp2
                        WHERE  tmp2.resource_assignment_id = tmp.resource_assignment_id
                        AND    tmp2.txn_currency_code = tmp.txn_currency_code
                        AND    tmp2.start_date = tmp.start_date
                        AND    tmp2.project_cost_rate_type = 'User' );

        -- Bug 4619257: Update Project Functional currency revenue rate type
        UPDATE pa_fp_rollup_tmp tmp
        SET    projfunc_rev_rate_type = 'User'
        WHERE  projfunc_rev_rate_type <> 'User'
        AND    EXISTS ( SELECT null
                        FROM   pa_fp_rollup_tmp tmp2
                        WHERE  tmp2.resource_assignment_id = tmp.resource_assignment_id
                        AND    tmp2.txn_currency_code = tmp.txn_currency_code
                        AND    tmp2.start_date = tmp.start_date
                        AND    tmp2.projfunc_rev_rate_type = 'User' );

        -- Bug 4619257: Update Project currency revenue rate type
        UPDATE pa_fp_rollup_tmp tmp
        SET    project_rev_rate_type = 'User'
        WHERE  project_rev_rate_type <> 'User'
        AND    EXISTS ( SELECT null
                        FROM   pa_fp_rollup_tmp tmp2
                        WHERE  tmp2.resource_assignment_id = tmp.resource_assignment_id
                        AND    tmp2.txn_currency_code = tmp.txn_currency_code
                        AND    tmp2.start_date = tmp.start_date
                        AND    tmp2.project_rev_rate_type = 'User' );

    ELSIF p_fp_cols_rec.x_time_phased_code = 'N' THEN
        -- Update Project Functional currency cost rate type
        UPDATE pa_fp_rollup_tmp tmp
        SET    projfunc_cost_rate_type = 'User'
        WHERE  projfunc_cost_rate_type <> 'User'
        AND    EXISTS ( SELECT null
                        FROM   pa_fp_rollup_tmp tmp2
                        WHERE  tmp2.resource_assignment_id = tmp.resource_assignment_id
                        AND    tmp2.txn_currency_code = tmp.txn_currency_code
                        AND    tmp2.projfunc_cost_rate_type = 'User' );

        -- Update Project currency cost rate type
        UPDATE pa_fp_rollup_tmp tmp
        SET    project_cost_rate_type = 'User'
        WHERE  project_cost_rate_type <> 'User'
        AND    EXISTS ( SELECT null
                        FROM   pa_fp_rollup_tmp tmp2
                        WHERE  tmp2.resource_assignment_id = tmp.resource_assignment_id
                        AND    tmp2.txn_currency_code = tmp.txn_currency_code
                        AND    tmp2.project_cost_rate_type = 'User' );

        -- Bug 4619257: Update Project Functional currency revenue rate type
        UPDATE pa_fp_rollup_tmp tmp
        SET    projfunc_rev_rate_type = 'User'
        WHERE  projfunc_rev_rate_type <> 'User'
        AND    EXISTS ( SELECT null
                        FROM   pa_fp_rollup_tmp tmp2
                        WHERE  tmp2.resource_assignment_id = tmp.resource_assignment_id
                        AND    tmp2.txn_currency_code = tmp.txn_currency_code
                        AND    tmp2.projfunc_rev_rate_type = 'User' );

        -- Bug 4619257: Update Project currency revenue rate type
        UPDATE pa_fp_rollup_tmp tmp
        SET    project_rev_rate_type = 'User'
        WHERE  project_rev_rate_type <> 'User'
        AND    EXISTS ( SELECT null
                        FROM   pa_fp_rollup_tmp tmp2
                        WHERE  tmp2.resource_assignment_id = tmp.resource_assignment_id
                        AND    tmp2.txn_currency_code = tmp.txn_currency_code
                        AND    tmp2.project_rev_rate_type = 'User' );
    END IF;


    -- Bug 4549862: If the target version is None timephased and the
    -- context is Forecast generation, then budget lines containing
    -- actuals may exist. As a result, some of the data in the temp
    -- table may need to be Inserted while other data in the table
    -- may need to be Updated in pa_budget_lines.
    --
    -- Group the temporary table data by resource assignment and txn
    -- currency code using separate cursors for the Insert/Update cases.
    -- Note that there are some cursors in GENERATE_BUDGET_AMT_RES_SCH
    -- with the same names as these cursors, but the queries are not
    -- the same.
    --
    -- One additional thing to note is that there is logic in the
    -- GENERATE_BUDGET_AMT_RES_SCH API to ensure that all project
    -- requirements/assignments that map to the same target resource
    -- have at most 1 distinct rejection code value per rejection
    -- code column in the temp table (when the target version is
    -- None timephased). This is important in guaranteeing that the
    -- cursors group the data correctly so that each ( resource /
    -- txn currency ) combination has only 1 budget line.

    IF p_fp_cols_rec.x_time_phased_code = 'N' AND
       p_plan_class_code = 'FORECAST' THEN

        -- Bug 4549862: Fetch data for Insert.
        OPEN GROUP_TO_INS_INTO_NTP_FCST_BL;
        FETCH GROUP_TO_INS_INTO_NTP_FCST_BL BULK COLLECT INTO
            l_bl_RES_ASSIGNMENT_ID_tab,
            l_bl_TXN_CURRENCY_CODE_tab,
            l_bl_START_DATE_tab,
            l_bl_END_DATE_tab,
            l_bl_PERIOD_NAME_tab,
            l_bl_QUANTITY_tab,
            l_bl_TXN_RAW_COST_tab,
            l_bl_TXN_BURDENED_COST_tab,
            l_bl_TXN_REVENUE_tab,
            l_bl_PC_RAW_COST_tab,
            l_bl_PC_BURDENED_COST_tab,
            l_bl_PC_REVENUE_tab,
            l_bl_PFC_RAW_COST_tab,
            l_bl_PFC_BURDENED_COST_tab,
            l_bl_PFC_REVENUE_tab,
            l_bl_COST_REJ_CODE_tab,
            l_bl_BURDEN_REJ_CODE_tab,
            l_bl_PC_CUR_REJ_CODE_tab,
            l_bl_PFC_CUR_REJ_CODE_tab,
            l_bl_PC_COST_RT_TYPE_tab,
            l_bl_PFC_COST_RT_TYPE_tab,
            l_bl_PC_REV_RT_TYPE_tab,
            l_bl_PFC_REV_RT_TYPE_tab;
        CLOSE GROUP_TO_INS_INTO_NTP_FCST_BL;

        -- Bug 4549862: Fetch data for Update.
        OPEN GROUP_TO_UPD_INTO_NTP_FCST_BL;
        FETCH GROUP_TO_UPD_INTO_NTP_FCST_BL BULK COLLECT INTO
            l_upd_bl_RES_ASSIGNMENT_ID_tab,
            l_upd_bl_TXN_CURRENCY_CODE_tab,
            l_upd_bl_START_DATE_tab,
            l_upd_bl_END_DATE_tab,
            l_upd_bl_PERIOD_NAME_tab,
            l_upd_bl_QUANTITY_tab,
            l_upd_bl_TXN_RAW_COST_tab,
            l_upd_bl_TXN_BURDENED_COST_tab,
            l_upd_bl_TXN_REVENUE_tab,
            l_upd_bl_PC_RAW_COST_tab,
            l_upd_bl_PC_BURDENED_COST_tab,
            l_upd_bl_PC_REVENUE_tab,
            l_upd_bl_PFC_RAW_COST_tab,
            l_upd_bl_PFC_BURDENED_COST_tab,
            l_upd_bl_PFC_REVENUE_tab,
            l_upd_bl_COST_REJ_CODE_tab,
            l_upd_bl_BURDEN_REJ_CODE_tab,
            l_upd_bl_PC_CUR_REJ_CODE_tab,
            l_upd_bl_PFC_CUR_REJ_CODE_tab,
            l_upd_bl_PC_COST_RT_TYPE_tab,
            l_upd_bl_PFC_COST_RT_TYPE_tab,
            l_upd_bl_PC_REV_RT_TYPE_tab,
            l_upd_bl_PFC_REV_RT_TYPE_tab;
        CLOSE GROUP_TO_UPD_INTO_NTP_FCST_BL;

    -- Bug 4549862: If the context is Budget generation, then we do
    -- not need to worry about the existence of budget lines containing
    -- actuals, so all temp table data can be Inserted into the budget
    -- lines table. If the context is Forecast generation and the target
    -- version is timephased by either PA or GL, then budget lines with
    -- actuals will only exist for periods through the Actuals Through
    -- Date. Since the temp table will contain ETC data in this case,
    -- all temp table data can be Inserted into the budget lines table.
    -- Therefore, in the ELSIF and ELSE blocks, fetch data for Insert.

    ELSIF p_fp_cols_rec.x_time_phased_code = 'N' AND
          p_plan_class_code = 'BUDGET' THEN

        OPEN GROUP_TO_INS_INTO_NTP_BDGT_BL;
        FETCH GROUP_TO_INS_INTO_NTP_BDGT_BL BULK COLLECT INTO
            l_bl_RES_ASSIGNMENT_ID_tab,
            l_bl_TXN_CURRENCY_CODE_tab,
            l_bl_START_DATE_tab,
            l_bl_END_DATE_tab,
            l_bl_PERIOD_NAME_tab,
            l_bl_QUANTITY_tab,
            l_bl_TXN_RAW_COST_tab,
            l_bl_TXN_BURDENED_COST_tab,
            l_bl_TXN_REVENUE_tab,
            l_bl_PC_RAW_COST_tab,
            l_bl_PC_BURDENED_COST_tab,
            l_bl_PC_REVENUE_tab,
            l_bl_PFC_RAW_COST_tab,
            l_bl_PFC_BURDENED_COST_tab,
            l_bl_PFC_REVENUE_tab,
            l_bl_COST_REJ_CODE_tab,
            l_bl_BURDEN_REJ_CODE_tab,
            l_bl_PC_CUR_REJ_CODE_tab,
            l_bl_PFC_CUR_REJ_CODE_tab,
            l_bl_PC_COST_RT_TYPE_tab,
            l_bl_PFC_COST_RT_TYPE_tab,
            l_bl_PC_REV_RT_TYPE_tab,
            l_bl_PFC_REV_RT_TYPE_tab;
        CLOSE GROUP_TO_INS_INTO_NTP_BDGT_BL;

    ELSE

        OPEN GROUP_TO_INS_INTO_BL;
        FETCH GROUP_TO_INS_INTO_BL BULK COLLECT INTO
            l_bl_RES_ASSIGNMENT_ID_tab,
            l_bl_TXN_CURRENCY_CODE_tab,
            l_bl_START_DATE_tab,
            l_bl_END_DATE_tab,
            l_bl_PERIOD_NAME_tab,
            l_bl_QUANTITY_tab,
            l_bl_TXN_RAW_COST_tab,
            l_bl_TXN_BURDENED_COST_tab,
            l_bl_TXN_REVENUE_tab,
            l_bl_PC_RAW_COST_tab,
            l_bl_PC_BURDENED_COST_tab,
            l_bl_PC_REVENUE_tab,
            l_bl_PFC_RAW_COST_tab,
            l_bl_PFC_BURDENED_COST_tab,
            l_bl_PFC_REVENUE_tab,
            l_bl_COST_REJ_CODE_tab,
            l_bl_BURDEN_REJ_CODE_tab,
            l_bl_PC_CUR_REJ_CODE_tab,
            l_bl_PFC_CUR_REJ_CODE_tab,
            l_bl_PC_COST_RT_TYPE_tab,
            l_bl_PFC_COST_RT_TYPE_tab,
            l_bl_PC_REV_RT_TYPE_tab,
            l_bl_PFC_REV_RT_TYPE_tab;
        CLOSE GROUP_TO_INS_INTO_BL;

    END IF; -- grouping temp table data


    -- Calculate cost and revenue rate overrides

    FOR i IN 1..l_bl_RES_ASSIGNMENT_ID_tab.count LOOP
        IF l_bl_QUANTITY_tab(i) <> 0 THEN
            l_txn_bill_rate_override_tab(i)  := l_bl_TXN_REVENUE_tab(i) / l_bl_QUANTITY_tab(i);
            l_txn_rcost_rate_override_tab(i) := l_bl_TXN_RAW_COST_tab(i) / l_bl_QUANTITY_tab(i);
            l_txn_bcost_rate_override_tab(i) := l_bl_TXN_BURDENED_COST_tab(i) / l_bl_QUANTITY_tab(i);
        ELSE
            l_txn_bill_rate_override_tab(i)  := null;
            l_txn_rcost_rate_override_tab(i) := null;
            l_txn_bcost_rate_override_tab(i) := null;
        END IF;
    END LOOP;

    FOR i IN 1..l_upd_bl_RES_ASSIGNMENT_ID_tab.count LOOP
        IF l_upd_bl_QUANTITY_tab(i) <> 0 THEN
            l_upd_bill_rate_override_tab(i)  := l_upd_bl_TXN_REVENUE_tab(i) / l_upd_bl_QUANTITY_tab(i);
            l_upd_rcost_rate_override_tab(i) := l_upd_bl_TXN_RAW_COST_tab(i) / l_upd_bl_QUANTITY_tab(i);
            l_upd_bcost_rate_override_tab(i) := l_upd_bl_TXN_BURDENED_COST_tab(i) / l_upd_bl_QUANTITY_tab(i);
        ELSE
            l_upd_bill_rate_override_tab(i)  := null;
            l_upd_rcost_rate_override_tab(i) := null;
            l_upd_bcost_rate_override_tab(i) := null;
        END IF;
    END LOOP;


    -- Calculate cost and revenue pc/pfc exchange rates

    FOR i IN 1..l_bl_RES_ASSIGNMENT_ID_tab.count LOOP
        -- Calculate cost pc/pfc exchange rates
        -- Assumption: Raw cost and burden cost conversion rates are the same.
        IF l_bl_TXN_RAW_COST_tab(i) <> 0 THEN
            l_cost_pc_exchg_rate_tab(i)  := l_bl_PC_RAW_COST_tab(i) / l_bl_TXN_RAW_COST_tab(i);
            l_cost_pfc_exchg_rate_tab(i) := l_bl_PFC_RAW_COST_tab(i) / l_bl_TXN_RAW_COST_tab(i);
        ELSE
            l_cost_pc_exchg_rate_tab(i)  := null;
            l_cost_pfc_exchg_rate_tab(i) := null;
        END IF;

        -- Calculate revenue pc/pfc exchange rates
        IF l_bl_TXN_REVENUE_tab(i) <> 0 THEN
            l_rev_pc_exchg_rate_tab(i)   := l_bl_PC_REVENUE_tab(i) / l_bl_TXN_REVENUE_tab(i);
            l_rev_pfc_exchg_rate_tab(i)  := l_bl_PFC_REVENUE_tab(i) / l_bl_TXN_REVENUE_tab(i);
        ELSE
            l_rev_pc_exchg_rate_tab(i)   := null;
            l_rev_pfc_exchg_rate_tab(i)  := null;
        END IF;
    END LOOP;

    FOR i IN 1..l_upd_bl_RES_ASSIGNMENT_ID_tab.count LOOP
        -- Calculate cost pc/pfc exchange rates
        -- Assumption: Raw cost and burden cost conversion rates are the same.
        IF l_upd_bl_TXN_RAW_COST_tab(i) <> 0 THEN
            l_upd_cost_pc_exchg_rate_tab(i)  := l_upd_bl_PC_RAW_COST_tab(i) / l_upd_bl_TXN_RAW_COST_tab(i);
            l_upd_cost_pfc_exchg_rate_tab(i) := l_upd_bl_PFC_RAW_COST_tab(i) / l_upd_bl_TXN_RAW_COST_tab(i);
        ELSE
            l_upd_cost_pc_exchg_rate_tab(i)  := null;
            l_upd_cost_pfc_exchg_rate_tab(i) := null;
        END IF;

        -- Calculate revenue pc/pfc exchange rates
        IF l_upd_bl_TXN_REVENUE_tab(i) <> 0 THEN
            l_upd_rev_pc_exchg_rate_tab(i)   := l_upd_bl_PC_REVENUE_tab(i) / l_upd_bl_TXN_REVENUE_tab(i);
            l_upd_rev_pfc_exchg_rate_tab(i)  := l_upd_bl_PFC_REVENUE_tab(i) / l_upd_bl_TXN_REVENUE_tab(i);
        ELSE
            l_upd_rev_pc_exchg_rate_tab(i)   := null;
            l_upd_rev_pfc_exchg_rate_tab(i)  := null;
        END IF;
    END LOOP;


    -- Insert into budget lines: quantity, cost and revenue amounts,
    -- txn currency code, period, start/end dates, pc/pfc exchange
    -- rates, cost/revenue rate types, rate overrides, and rejection codes.

    IF l_bl_RES_ASSIGNMENT_ID_tab.COUNT > 0 THEN

       FORALL bl_index IN 1 .. l_bl_START_DATE_tab.COUNT
           INSERT  INTO PA_BUDGET_LINES(
                              RESOURCE_ASSIGNMENT_ID,
                              START_DATE,
                              LAST_UPDATE_DATE,
                              LAST_UPDATED_BY,
                              CREATION_DATE,
                              CREATED_BY,
                              LAST_UPDATE_LOGIN,
                              END_DATE,
                              PERIOD_NAME,
                              QUANTITY,
                              TXN_CURRENCY_CODE,
                              BUDGET_LINE_ID,
                              BUDGET_VERSION_ID,
                              PROJECT_CURRENCY_CODE,
                              PROJFUNC_CURRENCY_CODE,
                              TXN_COST_RATE_OVERRIDE,
                              TXN_BILL_RATE_OVERRIDE,
                              BURDEN_COST_RATE_OVERRIDE,
                              TXN_RAW_COST,
                              TXN_BURDENED_COST,
                              TXN_REVENUE,
                              PROJECT_RAW_COST,
                              PROJECT_BURDENED_COST,
                              PROJECT_REVENUE,
                              RAW_COST,
                              BURDENED_COST,
                              REVENUE,
                              COST_REJECTION_CODE,
                              BURDEN_REJECTION_CODE,
                              PC_CUR_CONV_REJECTION_CODE,
                              PFC_CUR_CONV_REJECTION_CODE,
                              PROJECT_COST_EXCHANGE_RATE,
                              PROJFUNC_COST_EXCHANGE_RATE,
                              PROJECT_REV_EXCHANGE_RATE,
                              PROJFUNC_REV_EXCHANGE_RATE,
                              PROJECT_COST_RATE_TYPE,
                              PROJFUNC_COST_RATE_TYPE,
                              PROJECT_REV_RATE_TYPE,
                              PROJFUNC_REV_RATE_TYPE )
        VALUES(
                              l_bl_RES_ASSIGNMENT_ID_tab(bl_index),
                              l_bl_START_DATE_tab(bl_index),
                              l_sysdate,
                              l_last_updated_by,
                              l_sysdate,
                              l_last_updated_by,
                              l_last_update_login,
                              l_bl_END_DATE_tab(bl_index),
                              l_bl_PERIOD_NAME_tab(bl_index),
                              l_bl_QUANTITY_tab(bl_index),
                              l_bl_TXN_CURRENCY_CODE_tab(bl_index),
                              PA_BUDGET_LINES_S.nextval,
                              P_BUDGET_VERSION_ID,
                              P_FP_COLS_REC.X_PROJECT_CURRENCY_CODE,
                              P_FP_COLS_REC.X_PROJFUNC_CURRENCY_CODE,
                              l_txn_rcost_rate_override_tab(bl_index),
                              l_txn_bill_rate_override_tab(bl_index),
                              l_txn_bcost_rate_override_tab(bl_index),
                              l_bl_TXN_RAW_COST_tab(bl_index),
                              l_bl_TXN_BURDENED_COST_tab(bl_index),
                              l_bl_TXN_REVENUE_tab(bl_index),
                              l_bl_PC_RAW_COST_tab(bl_index),
                              l_bl_PC_BURDENED_COST_tab(bl_index),
                              l_bl_PC_REVENUE_tab(bl_index),
                              l_bl_PFC_RAW_COST_tab(bl_index),
                              l_bl_PFC_BURDENED_COST_tab(bl_index),
                              l_bl_PFC_REVENUE_tab(bl_index),
                              l_bl_COST_REJ_CODE_tab(bl_index),
                              l_bl_BURDEN_REJ_CODE_tab(bl_index),
                              l_bl_PC_CUR_REJ_CODE_tab(bl_index),
                              l_bl_PFC_CUR_REJ_CODE_tab(bl_index),
                              l_cost_pc_exchg_rate_tab(bl_index),
                              l_cost_pfc_exchg_rate_tab(bl_index),
                              l_rev_pc_exchg_rate_tab(bl_index),
                              l_rev_pfc_exchg_rate_tab(bl_index),
                              l_bl_PC_COST_RT_TYPE_tab(bl_index),
                              l_bl_PFC_COST_RT_TYPE_tab(bl_index),
                              l_bl_PC_REV_RT_TYPE_tab(bl_index),
                              l_bl_PFC_REV_RT_TYPE_tab(bl_index) );

    END IF; -- IF l_bl_RES_ASSIGNMENT_ID_tab.COUNT > 0 THEN


    -- Bug 4549862: If the target version is None timephased and the
    -- context is Forecast generation, then budget lines containing
    -- actuals may exist. As a result, some of the data in the temp
    -- table may need to be Inserted while other data in the table
    -- may need to be Updated in pa_budget_lines.
    --
    -- The following code Updates the budget lines.

    IF l_upd_bl_RES_ASSIGNMENT_ID_tab.COUNT > 0 THEN

       FORALL bl_index IN 1 .. l_upd_bl_START_DATE_tab.COUNT
           UPDATE PA_BUDGET_LINES
           SET    LAST_UPDATE_DATE  = l_sysdate,
                  LAST_UPDATED_BY   = l_last_updated_by,
                  LAST_UPDATE_LOGIN = l_last_update_login,
                  START_DATE        = LEAST(START_DATE, l_upd_bl_START_DATE_tab(bl_index)),
                  END_DATE          = GREATEST(END_DATE, l_upd_bl_END_DATE_tab(bl_index)),
                  QUANTITY          =
                      DECODE(INIT_QUANTITY, null, l_upd_bl_QUANTITY_tab(bl_index),
                             INIT_QUANTITY + NVL(l_upd_bl_QUANTITY_tab(bl_index),0)),
                  TXN_RAW_COST      =
                      DECODE(TXN_INIT_RAW_COST, null, l_upd_bl_TXN_RAW_COST_tab(bl_index),
                             TXN_INIT_RAW_COST + NVL(l_upd_bl_TXN_RAW_COST_tab(bl_index),0)),
                  TXN_BURDENED_COST =
                      DECODE(TXN_INIT_BURDENED_COST, null, l_upd_bl_TXN_BURDENED_COST_tab(bl_index),
                             TXN_INIT_BURDENED_COST + NVL(l_upd_bl_TXN_BURDENED_COST_tab(bl_index),0)),
                  TXN_REVENUE       =
                      DECODE(TXN_INIT_REVENUE, null, l_upd_bl_TXN_REVENUE_tab(bl_index),
                             TXN_INIT_REVENUE + NVL(l_upd_bl_TXN_REVENUE_tab(bl_index),0)),
                  PROJECT_RAW_COST      =
                      DECODE(PROJECT_INIT_RAW_COST, null, l_upd_bl_PC_RAW_COST_tab(bl_index),
                             PROJECT_INIT_RAW_COST + NVL(l_upd_bl_TXN_RAW_COST_tab(bl_index),0)),
                  PROJECT_BURDENED_COST =
                      DECODE(PROJECT_INIT_BURDENED_COST, null, l_upd_bl_PC_BURDENED_COST_tab(bl_index),
                             PROJECT_INIT_BURDENED_COST + NVL(l_upd_bl_PC_BURDENED_COST_tab(bl_index),0)),
                  PROJECT_REVENUE       =
                      DECODE(PROJECT_INIT_REVENUE, null, l_upd_bl_PC_REVENUE_tab(bl_index),
                             PROJECT_INIT_REVENUE + NVL(l_upd_bl_PC_REVENUE_tab(bl_index),0)),
                  RAW_COST              =
                      DECODE(INIT_RAW_COST, null, l_upd_bl_PFC_RAW_COST_tab(bl_index),
                             INIT_RAW_COST + NVL(l_upd_bl_PFC_RAW_COST_tab(bl_index),0)),
                  BURDENED_COST         =
                      DECODE(INIT_BURDENED_COST, null, l_upd_bl_PFC_BURDENED_COST_tab(bl_index),
                             INIT_BURDENED_COST + NVL(l_upd_bl_PFC_BURDENED_COST_tab(bl_index),0)),
                  REVENUE               =
                      DECODE(INIT_REVENUE, null, l_upd_bl_PFC_REVENUE_tab(bl_index),
                             INIT_REVENUE + NVL(l_upd_bl_PFC_REVENUE_tab(bl_index),0)),
                  TXN_COST_RATE_OVERRIDE      = l_upd_rcost_rate_override_tab(bl_index),
                  TXN_BILL_RATE_OVERRIDE      = l_upd_bill_rate_override_tab(bl_index),
                  BURDEN_COST_RATE_OVERRIDE   = l_upd_bcost_rate_override_tab(bl_index),
                  COST_REJECTION_CODE         = l_upd_bl_COST_REJ_CODE_tab(bl_index),
                  BURDEN_REJECTION_CODE       = l_upd_bl_BURDEN_REJ_CODE_tab(bl_index),
                  PC_CUR_CONV_REJECTION_CODE  = l_upd_bl_PC_CUR_REJ_CODE_tab(bl_index),
                  PFC_CUR_CONV_REJECTION_CODE = l_upd_bl_PFC_CUR_REJ_CODE_tab(bl_index),
                  PROJECT_COST_EXCHANGE_RATE  = l_upd_cost_pc_exchg_rate_tab(bl_index),
                  PROJFUNC_COST_EXCHANGE_RATE = l_upd_cost_pfc_exchg_rate_tab(bl_index),
                  PROJECT_REV_EXCHANGE_RATE   = l_upd_rev_pc_exchg_rate_tab(bl_index),
                  PROJFUNC_REV_EXCHANGE_RATE  = l_upd_rev_pfc_exchg_rate_tab(bl_index),
                  PROJECT_COST_RATE_TYPE      = l_upd_bl_PC_COST_RT_TYPE_tab(bl_index),
                  PROJFUNC_COST_RATE_TYPE     = l_upd_bl_PFC_COST_RT_TYPE_tab(bl_index),
                  PROJECT_REV_RATE_TYPE       = l_upd_bl_PC_REV_RT_TYPE_tab(bl_index),
                  PROJFUNC_REV_RATE_TYPE      = l_upd_bl_PFC_REV_RT_TYPE_tab(bl_index)
           WHERE  RESOURCE_ASSIGNMENT_ID = l_upd_bl_RES_ASSIGNMENT_ID_tab(bl_index)
           AND    TXN_CURRENCY_CODE      = l_upd_bl_TXN_CURRENCY_CODE_tab(bl_index);

    END IF; -- l_upd_bl_RES_ASSIGNMENT_ID_tab.COUNT > 0 check

    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.Reset_Curr_Function;
    END IF;

EXCEPTION
    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
	/** MRC Elimination changes: PA_MRC_FINPLAN.G_CALLING_MODULE := Null; **/
        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count = 1 THEN
            PA_INTERFACE_UTILS_PUB.get_messages
                ( p_encoded        => FND_API.G_TRUE
                 ,p_msg_index      => 1
                 ,p_msg_count      => l_msg_count
                 ,p_msg_data       => l_msg_data
                 ,p_data           => l_data
                 ,p_msg_index_out  => l_msg_index_out );
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
            ( p_pkg_name       => 'PA_FP_REV_GEN_PUB'
             ,p_procedure_name => 'PUSH_RES_SCH_DATA_TO_BL' );

        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END PUSH_RES_SCH_DATA_TO_BL;


END PA_FP_REV_GEN_PUB;

/
