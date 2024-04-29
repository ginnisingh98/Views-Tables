--------------------------------------------------------
--  DDL for Package Body PA_FP_GEN_FCST_AMT_PUB1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_GEN_FCST_AMT_PUB1" as
/* $Header: PAFPFG2B.pls 120.5.12010000.6 2009/08/05 10:44:05 bnoorbha ship $ */

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

/**
 * This procedure updates planning txn level override rates
 * for NON-RATE-BASED txns in the following ways:
 * 1. In Cost and Revenue together target versions,
 *    for non-rate-based txns with only revenue amounts:
 *    a. Set bill rate override to 1
 *    b. Set cost rate overrides to 0
 * 2. Null out any existing rate overrides for non-rate-based
 *    txns that do not have any budget lines.
 *
 * IMPORTANT NOTE:
 * This procedure should only be called before the final
 * rollup of amounts in the pa_resource_asgn_curr table.
 * The impact of calling this API out of order is that rolled
 * up amounts and average rates will be nulled out for
 * updated planning txns!
 *
 * Also worth noting is that this procedure is package-private.
 */
PROCEDURE UPD_NRB_TXN_OVR_RATES
          (P_PROJECT_ID              IN          PA_PROJECTS_ALL.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC             IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_ETC_START_DATE          IN          DATE,
           X_RETURN_STATUS           OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT               OUT  NOCOPY NUMBER,
           X_MSG_DATA                OUT  NOCOPY VARCHAR2 )
IS
    l_package_name                 VARCHAR2(30) := 'PA_FP_GEN_FCST_AMT_PUB1';
    l_procedure_name               VARCHAR2(30) := 'UPD_NRB_TXN_OVR_RATES';
    l_module_name                  VARCHAR2(100);

    -- This cursor gets distinct (resource_assignment_id,txn_currency_code)
    -- values for any non-rate-based txns in the given budget version
    -- (p_budget_version_id) that have only (ETC) revenue amounts.
    -- This cursor can be used for both timephased and non-timephased
    -- Budgets and Forecasts, since only (plan-actual) values are checked.
    -- Also, the cursor considers both manually and non-manually added
    -- lines since Update Case 1 applies to both cases.

    -- ER 5726773: Instead of selecting only planning transactions with
    -- positive internal Plan/ETC quantity, relax the restriction to only
    -- non-zero internal Plan/ETC quantity.

    CURSOR rev_only_nrb_txns_csr IS
    SELECT bl.resource_assignment_id,
           bl.txn_currency_code
    FROM   pa_resource_assignments ra,
           pa_budget_lines bl
    WHERE  ra.budget_version_id = p_budget_version_id
    AND    ra.project_id = p_project_id
    AND    ra.rate_based_flag = 'N'
    AND    bl.resource_assignment_id = ra.resource_assignment_id
    AND    bl.cost_rejection_code is null
    AND    bl.revenue_rejection_code is null
    AND    bl.burden_rejection_code is null
    AND    bl.other_rejection_code is null
    AND    bl.pc_cur_conv_rejection_code is null
    AND    bl.pfc_cur_conv_rejection_code is null
    GROUP BY bl.resource_assignment_id,
             bl.txn_currency_code
    HAVING nvl(sum(bl.txn_raw_cost),0)-nvl(sum(bl.txn_init_raw_cost),0) = 0
    and    nvl(sum(bl.quantity),0)-nvl(sum(bl.init_quantity),0) <> 0
    and    nvl(sum(bl.quantity),0)-nvl(sum(bl.init_quantity),0) =
           nvl(sum(bl.txn_revenue),0)-nvl(sum(bl.txn_init_revenue),0);

    -- This cursor gets distinct (resource_assignment_id,txn_currency_code)
    -- values for any non-rate-based txns in the given budget version
    -- (p_budget_version_id) that have existing txn-level rate overrides
    -- but no (ETC) budget lines.
    -- This cursor can be used for both timephased and non-timephased
    -- Budgets and Forecasts, since a plan qty vs. actual qty check is
    -- used (instead of relying on etc_start_date).
    -- Also, the cursor considers both manually and non-manually added
    -- lines since Update Case 2 applies to both cases.
    -- For an explanation of why budget line rejection codes are not
    -- checked by this cursor, refer to Closed Issue #2 in the comment
    -- block for Update Case 2.

    CURSOR nrb_txns_without_bl_csr IS
    SELECT rbc.resource_assignment_id,
           rbc.txn_currency_code
    FROM   pa_resource_assignments ra,
           pa_resource_asgn_curr rbc
    WHERE  ra.budget_version_id = p_budget_version_id
    AND    ra.project_id = p_project_id
    AND    ra.rate_based_flag = 'N'
    AND    rbc.resource_assignment_id = ra.resource_assignment_id
    AND NOT EXISTS
          ( SELECT null
            FROM   pa_budget_lines bl
            WHERE  bl.resource_assignment_id = rbc.resource_assignment_id
            AND    bl.txn_currency_code = rbc.txn_currency_code
            AND    nvl(bl.quantity,0) <> nvl(bl.init_quantity,0) )
    AND  ( rbc.txn_raw_cost_rate_override is not null    OR
           rbc.txn_burden_cost_rate_override is not null OR
           rbc.txn_bill_rate_override is not null );

    l_res_asg_id_tab               PA_PLSQL_DATATYPES.NumTabTyp;
    l_txn_currency_code_tab        PA_PLSQL_DATATYPES.Char30TabTyp;

    -- This flag tracks if the pa_resource_asgn_curr_tmp global
    -- temp table has been deleted/cleared yet.
    l_rbc_tmp_tbl_deleted_flag     VARCHAR2(1);

    -- This flag tracks if calling maintain_data API in Insert
    -- mode is required at the end of this procedure.
    l_maint_data_ins_req_flag      VARCHAR2(1);

    -- This will be used for the p_calling_module parameter
    -- of the MAINTAIN_DATA API.
    l_calling_module               VARCHAR2(30);

    l_log_level                    NUMBER := 5;
    l_msg_count                    NUMBER;
    l_data                         VARCHAR2(1000);
    l_msg_data                     VARCHAR2(1000);
    l_msg_index_out                NUMBER;
BEGIN
    l_module_name := 'pa.plsql.' || l_package_name || '.' || l_procedure_name;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;

    IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.SET_CURR_FUNCTION( p_function   => l_procedure_name,
                                    p_debug_mode => p_pa_debug_mode );
    END IF;

     -- Print values of Input Parameters to debug log
    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'Input Parameters for '
                               || l_module_name || '():',
            --p_called_mode => p_called_mode,
              p_module_name => l_module_name,
              p_log_level   => l_log_level );
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'P_PROJECT_ID:['||p_project_id||']',
            --p_called_mode => p_called_mode,
              p_module_name => l_module_name,
              p_log_level   => l_log_level );
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'P_BUDGET_VERSION_ID:['||p_budget_version_id||']',
            --p_called_mode => p_called_mode,
              p_module_name => l_module_name,
              p_log_level   => l_log_level );
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'P_FP_COLS_REC.X_PLAN_CLASS_CODE:[' ||
                                p_fp_cols_rec.x_plan_class_code || ']',
            --p_called_mode => p_called_mode,
              p_module_name => l_module_name,
              p_log_level   => l_log_level );
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'P_FP_COLS_REC.X_VERSION_TYPE:[' ||
                                p_fp_cols_rec.x_version_type || ']',
            --p_called_mode => p_called_mode,
              p_module_name => l_module_name,
              p_log_level   => l_log_level );
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'P_ETC_START_DATE:['||p_etc_start_date||']',
            --p_called_mode => p_called_mode,
              p_module_name => l_module_name,
              p_log_level   => l_log_level );
    END IF; -- IF p_pa_debug_mode = 'Y' THEN

    -- Validate input parameters
    IF p_project_id is NULL OR
       p_budget_version_id is NULL OR
     ( p_etc_start_date is NULL AND
       p_fp_cols_rec.x_plan_class_code = 'FORECAST' ) THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( p_msg         => 'Input Parameter Validation FAILED',
                --p_called_mode => p_called_mode,
                  p_module_name => l_module_name,
                  p_log_level   => l_log_level );
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RETURN;
    END IF;

    -- Initialize l_calling_module
    IF p_fp_cols_rec.x_plan_class_code = 'BUDGET' THEN
        l_calling_module := 'BUDGET_GENERATION';
    ELSIF p_fp_cols_rec.x_plan_class_code = 'FORECAST' THEN
        l_calling_module := 'FORECAST_GENERATION';
    END IF;

    -- Initialize l_rbc_tmp_tbl_deleted_flag.
    -- Intended Usage:
    -- Logic that deletes the pa_resource_asgn_curr_tmp
    -- global temp table should set this flag to 'Y' so that
    -- downstream code knows that the table has been cleared
    -- by this procedure.
    l_rbc_tmp_tbl_deleted_flag := 'N';

    -- Initialize l_maint_data_ins_req_flag
    -- Intended Usage:
    -- Logic that requires the maintain_data API to be
    -- called in Insert mode should set this flag to 'Y'.
    -- The purpose of this flag is to group together all
    -- txns that need to be updated so that maintain_data
    -- can be called just once.
    l_maint_data_ins_req_flag := 'N';

    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'Beginning Update Case 1',
            --p_called_mode => p_called_mode,
              p_module_name => l_module_name,
              p_log_level   => l_log_level );
    END IF;

    /**
     * Update Case 1:
     * In Cost and Revenue together target versions
     * for non-rate-based txns with only revenue amounts:
     * a. Set bill rate override to 1
     * b. Set cost rate overrides to 0
     *
     * Background:
     * By default, quantity = txn_raw_cost for non-rate-based
     * txns at the periodic line level. In IPM, it is possible
     * to have non-rate-based txns with just revenue amounts
     * (without cost amounts); quantity = txn_revenue in such
     * cases. The problem is that when users update or refresh
     * the revenue for such txns, the Calculate API defaults
     * quantity to raw cost in the absence of txn-level rate
     * overrides, which is functionally incorrect. If txn-level
     * rate overrides are set according to (a) and (b) above,
     * then the Calculate API behaves correctly.
     **/
    IF p_fp_cols_rec.x_version_type = 'ALL' THEN

        -- Get distinct (resource_assignment_id,txn_currency_code)
        -- values for non-rate-based txns having only revenue amounts.
        OPEN   rev_only_nrb_txns_csr;
        FETCH  rev_only_nrb_txns_csr
        BULK COLLECT
        INTO   l_res_asg_id_tab,
               l_txn_currency_code_tab;
        CLOSE  rev_only_nrb_txns_csr;

        IF l_res_asg_id_tab.count > 0 THEN

            l_maint_data_ins_req_flag := 'Y';

            IF l_rbc_tmp_tbl_deleted_flag = 'N' THEN
                DELETE pa_resource_asgn_curr_tmp;
                l_rbc_tmp_tbl_deleted_flag := 'Y';

                IF p_pa_debug_mode = 'Y' THEN
                    PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                        ( p_msg         => 'Records Deleted from pa_resource_asgn_curr_tmp',
                        --p_called_mode => p_called_mode,
                          p_module_name => l_module_name,
                          p_log_level   => l_log_level );
                END IF;
            END IF; -- IF l_rbc_tmp_tbl_deleted_flag = 'N' THEN

            FORALL i IN 1..l_res_asg_id_tab.count
                INSERT INTO PA_RESOURCE_ASGN_CURR_TMP
                    ( resource_assignment_id,
                      txn_currency_code,
	              txn_raw_cost_rate_override,
	              txn_burden_cost_rate_override,
	              txn_bill_rate_override )
                VALUES
                    ( l_res_asg_id_tab(i),
                      l_txn_currency_code_tab(i),
                      0,   -- txn_raw_cost_rate_override
                      0,   -- txn_burden_cost_rate_override
                      1 ); -- txn_bill_rate_override

            IF p_pa_debug_mode = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                    ( p_msg         => 'Number of records Inserted into ' ||
                                       'PA_RESOURCE_ASGN_CURR_TMP:['||sql%Rowcount||']',
                    --p_called_mode => p_called_mode,
                      p_module_name => l_module_name,
                      p_log_level   => l_log_level );
            END IF;
        END IF; -- IF l_res_asg_id_tab.count > 0 THEN

    END IF; -- IF p_fp_cols_rec.x_version_type = 'ALL' THEN
    /* End Update Case 1 */

    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'Beginning Update Case 2',
            --p_called_mode => p_called_mode,
              p_module_name => l_module_name,
              p_log_level   => l_log_level );
    END IF;

    /**
     * Update Case 2:
     * Null out any existing rate overrides for non-rate-based
     * txns that do not have any budget lines.
     *
     * Background:
     * In IPM, non-rate-based txns are considered 'amount-based'
     * and rates are not functionally meaningful. Thus, internal
     * txn-level rates are not displayed to users. When users
     * enter amounts on a blank line (i.e. for a txn that does
     * not have any budget lines), calculation of amounts should
     * not be affected by old internal txn-level rates.
     *
     * Open/Closed Issues:
     * 1. Does this apply only to ETC budget lines?
     * Answer: Yes. Since actuals are read-only, the absence of
     * ETC budget lines would fall under the blank line scenario.
     * 2. Should this consider only lines w/o rejections?
     * Answer: No. Here's an example where rates should be retained:
     * Src/Tgt options match. Src has cost rate overrides
     * that get copied to tgt. However, bill rate is missing
     * for the txn, so revenue_rejection_code stamped. We
     * should not null out the cost rates in this case.
     **/

    -- Get distinct (resource_assignment_id,txn_currency_code)
    -- values for non-rate-based txns that have existing txn-level
    -- rate overrides but no (ETC) budget lines.
    OPEN   nrb_txns_without_bl_csr;
    FETCH  nrb_txns_without_bl_csr
    BULK COLLECT
    INTO   l_res_asg_id_tab,
           l_txn_currency_code_tab;
    CLOSE  nrb_txns_without_bl_csr;

    IF l_res_asg_id_tab.count > 0 THEN

        l_maint_data_ins_req_flag := 'Y';

        IF l_rbc_tmp_tbl_deleted_flag = 'N' THEN
            DELETE pa_resource_asgn_curr_tmp;
            l_rbc_tmp_tbl_deleted_flag := 'Y';

            IF p_pa_debug_mode = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                    ( p_msg         => 'Records Deleted from pa_resource_asgn_curr_tmp',
                    --p_called_mode => p_called_mode,
                      p_module_name => l_module_name,
                      p_log_level   => l_log_level );
            END IF;
        END IF; -- IF l_rbc_tmp_tbl_deleted_flag = 'N' THEN

        -- Because the planning txns involved in Update Case 1
        -- and Update Case 2 are mutually exclusive, no extra
        -- logic needs to be added to avoid duplicate records
        -- begin inserted into pa_resource_asgn_curr_tmp.
        --
        -- In the future, if additional Update Cases with
        -- overlapping txns are added, then a precedence of
        -- updates will need to be determined with corresponding
        -- updates to the global temporary table.

        -- Note: all rate overrides are implicitly set to Null.
        FORALL i IN 1..l_res_asg_id_tab.count
            INSERT INTO PA_RESOURCE_ASGN_CURR_TMP
                ( resource_assignment_id,
                  txn_currency_code )
            VALUES
                ( l_res_asg_id_tab(i),
                  l_txn_currency_code_tab(i) );

        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( p_msg         => 'Number of records Inserted into ' ||
                                   'PA_RESOURCE_ASGN_CURR_TMP:['||sql%Rowcount||']',
                --p_called_mode => p_called_mode,
                  p_module_name => l_module_name,
                  p_log_level   => l_log_level );
        END IF;
    END IF; -- IF l_res_asg_id_tab.count > 0 THEN
    /* End Update Case 2 */


    -- Call MAINTAIN_DATA to Insert rate overrides into the
    -- pa_resource_asgn_curr table if required.
    -- Note: temp table data should be completed populated
    -- by this point by the preceding Update Cases.

    IF l_maint_data_ins_req_flag = 'Y' THEN

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

    END IF; -- IF l_maint_data_ins_req_flag = 'Y' THEN

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
                   ( p_pkg_name        => l_package_name,
                     p_procedure_name  => l_procedure_name,
                     p_error_text      => substr(sqlerrm,1,240));

        IF p_pa_debug_mode = 'Y' THEN
           PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
             p_module_name => l_module_name,
             p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END UPD_NRB_TXN_OVR_RATES;


/**
 * This procedure populates the PA_FP_GEN_RATE_TMP table with values from the
 * PA_BUDGET_LINES table for the given (source resource assignment, txn currency code)
 * parameter combination.
 *
 * The target resource assignment id is currently unused.
 */
PROCEDURE POPULATE_GEN_RATE
          (P_SOURCE_RES_ASG_ID       IN            PA_BUDGET_LINES.RESOURCE_ASSIGNMENT_ID%TYPE,
           P_TARGET_RES_ASG_ID       IN            PA_BUDGET_LINES.RESOURCE_ASSIGNMENT_ID%TYPE,
           P_TXN_CURRENCY_CODE       IN            PA_BUDGET_LINES.TXN_CURRENCY_CODE%TYPE,
           X_RETURN_STATUS           OUT  NOCOPY   VARCHAR2,
           X_MSG_COUNT               OUT  NOCOPY   NUMBER,
           X_MSG_DATA                OUT  NOCOPY   VARCHAR2)
IS
    l_package_name                 VARCHAR2(30) := 'PA_FP_GEN_FCST_AMT_PUB1';
    l_procedure_name               VARCHAR2(30) := 'POPULATE_GEN_RATE';
    l_module_name                  VARCHAR2(100);

    CURSOR bl_rates_cur (c_res_asg_id PA_BUDGET_LINES.RESOURCE_ASSIGNMENT_ID%TYPE) IS
        SELECT bl.period_name,
               NVL(bl.txn_cost_rate_override,bl.txn_standard_cost_rate),
               NVL(bl.burden_cost_rate_override,bl.burden_cost_rate),
               NVL(bl.txn_bill_rate_override,bl.txn_standard_bill_rate)
          FROM pa_budget_lines bl
         WHERE bl.resource_assignment_id = c_res_asg_id
           AND bl.txn_currency_code = p_txn_currency_code;

    l_period_name_tab              PA_PLSQL_DATATYPES.Char30TabTyp;
    l_raw_cost_rate_tab            PA_PLSQL_DATATYPES.NumTabTyp;
    l_burdened_cost_rate_tab       PA_PLSQL_DATATYPES.NumTabTyp;
    l_revenue_bill_rate_tab        PA_PLSQL_DATATYPES.NumTabTyp;
    l_count                        NUMBER;
    l_msg_count                    NUMBER;
    l_data                         VARCHAR2(1000);
    l_msg_data                     VARCHAR2(1000);
    l_msg_index_out                NUMBER;
BEGIN
    l_module_name := 'pa.plsql.' || l_package_name || '.' || l_procedure_name;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;

    IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.SET_CURR_FUNCTION( p_function   => l_procedure_name,
                                    p_debug_mode => p_pa_debug_mode );
    END IF;

    IF p_source_res_asg_id IS NULL OR p_txn_currency_code is NULL THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RETURN;
    END IF;

    /* Get data for Source resource assignment */
    OPEN bl_rates_cur ( p_source_res_asg_id );
    FETCH bl_rates_cur
    BULK COLLECT
    INTO l_period_name_tab,
         l_raw_cost_rate_tab,
         l_burdened_cost_rate_tab,
         l_revenue_bill_rate_tab;
    CLOSE bl_rates_cur;

    /* Bug 4117267 added TARGET_RES_ASG_ID column in the INSERT stmt. */

    FORALL i IN 1..l_period_name_tab.count
        INSERT INTO PA_FP_GEN_RATE_TMP
             ( SOURCE_RES_ASG_ID,
               TXN_CURRENCY_CODE,
               PERIOD_NAME,
               RAW_COST_RATE,
               BURDENED_COST_RATE,
               REVENUE_BILL_RATE,
               TARGET_RES_ASG_ID)
        VALUES
             ( p_source_res_asg_id,
               p_txn_currency_code,
               l_period_name_tab(i),
               l_raw_cost_rate_tab(i),
               l_burdened_cost_rate_tab(i),
               l_revenue_bill_rate_tab(i),
               p_target_res_asg_id );

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
                   ( p_pkg_name        => l_package_name,
                     p_procedure_name  => l_procedure_name,
                     p_error_text      => substr(sqlerrm,1,240));

        IF p_pa_debug_mode = 'Y' THEN
           PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
             p_module_name => l_module_name,
             p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END POPULATE_GEN_RATE;


/**
 * This procedure checks for rate-based target txns that have source txns in
 * different units of measurement mapped to them. Such target txns are updated
 * in the pa_resource_assignments table to be non rate-based with UOM equal to
 * currency.
 *
 * Currently the P_FP_COLS_REC parameter is unused. This, however, will likely
 * change with future modifications.
 */
PROCEDURE CHK_UPD_RATE_BASED_FLAG
          (P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC             IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           X_RETURN_STATUS           OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT               OUT  NOCOPY NUMBER,
           X_MSG_DATA                OUT  NOCOPY VARCHAR2)
IS
    l_module_name  VARCHAR2(200) := 'pa.plsql.pa_fp_gen_fcst_amt_pub1.chk_upd_rate_based_flag';

    CURSOR get_res_asg_cur IS
    SELECT /*+ INDEX(tmp,PA_FP_CALC_AMT_TMP1_N1)*/
           DISTINCT(tmp.target_res_asg_id)
      FROM pa_fp_calc_amt_tmp1 tmp,
           pa_resource_assignments ra
     WHERE ra.resource_assignment_id = tmp.target_res_asg_id
       and ra.budget_version_id = p_budget_version_id
       and ra.rate_based_flag = 'Y'
     GROUP BY tmp.target_res_asg_id
    HAVING COUNT(DISTINCT(tmp.unit_of_measure)) > 1;

    l_res_asg_id_tab              PA_PLSQL_DATATYPES.IdTabTyp;

    l_currency_code      CONSTANT PA_RESOURCE_ASSIGNMENTS.UNIT_OF_MEASURE%TYPE := 'DOLLARS';
    l_last_updated_by             NUMBER := FND_GLOBAL.user_id;
    l_last_update_login           NUMBER := FND_GLOBAL.login_id;

    l_count                       NUMBER;
    l_msg_count                   NUMBER;
    l_data                        VARCHAR2(1000);
    l_msg_data                    VARCHAR2(1000);
    l_msg_index_out               NUMBER;
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;

    IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.SET_CURR_FUNCTION( p_function   => 'CHK_UPD_RATE_BASED_FLAG',
                                    p_debug_mode => p_pa_debug_mode );
    END IF;

    OPEN get_res_asg_cur;
    FETCH get_res_asg_cur
    BULK COLLECT
    INTO l_res_asg_id_tab;
    CLOSE get_res_asg_cur;

    IF l_res_asg_id_tab.count = 0 THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RETURN;
    END IF;

    FORALL i IN 1..l_res_asg_id_tab.count
        UPDATE pa_resource_assignments
           SET rate_based_flag = 'N',
               unit_of_measure = l_currency_code,
               last_update_date = SYSDATE,
               last_updated_by = l_last_updated_by,
               last_update_login = l_last_update_login
         WHERE resource_assignment_id = l_res_asg_id_tab(i);

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
                   ( p_pkg_name        => 'PA_FP_GEN_FCST_AMT_PUB1',
                     p_procedure_name  => 'CHK_UPD_RATE_BASED_FLAG',
                     p_error_text      => substr(sqlerrm,1,240));

        IF p_pa_debug_mode = 'Y' THEN
           PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
             p_module_name => l_module_name,
             p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END CHK_UPD_RATE_BASED_FLAG;


/**As of now, this procedure will be called three times for 3 different sources,
  *the taking param for P_DATA_TYPE_CODE are: ETC_FP, ETC_WP, TARGET_FP
  *Instead of calling this 3 times, we need to verfity whether resource list
  *are same between eitehr two or 3 of them. If they do, we only need to call
  *this  procedure 2 or 1 times, instead of 3.
  *WILL BE CHANGED LATER**/
PROCEDURE CALL_SUMM_POP_TMPS
          (P_PROJECT_ID              IN          PA_PROJECTS_ALL.PROJECT_ID%TYPE,
           P_CALENDAR_TYPE           IN          VARCHAR2,
           P_RECORD_TYPE             IN          VARCHAR2,
           P_RESOURCE_LIST_ID        IN          NUMBER,
           P_STRUCT_VER_ID           IN          NUMBER,
           P_ACTUALS_THRU_DATE       IN          PA_PERIODS_ALL.END_DATE%TYPE,
           P_DATA_TYPE_CODE          IN          VARCHAR2,
           X_RETURN_STATUS           OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT               OUT  NOCOPY NUMBER,
           X_MSG_DATA                OUT  NOCOPY VARCHAR2)
IS
    l_module_name  VARCHAR2(200) := 'pa.plsql.pa_fp_gen_fcst_amt_pub1.call_summ_pop_tmps';
    l_project_id_tab            SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_resource_list_id_tab      SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_struct_ver_id_tab         SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_calendar_type_tab         SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();
    l_end_date_tab              SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();

    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(2000);
    l_data                       VARCHAR2(2000);
    l_msg_index_out              NUMBER:=0;
    l_count                      NUMBER;
    l_rlm_id                     pa_resource_list_members.resource_list_member_id%TYPE;
    l_uncategorized_flag         VARCHAR2(1);
BEGIN
    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function     => 'CALL_SUMM_POP_TMPS',
                                    p_debug_mode   =>  p_pa_debug_mode);
    END IF;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_COUNT := 0;

    l_project_id_tab.extend;
    l_resource_list_id_tab.extend;
    l_struct_ver_id_tab.extend;
    l_calendar_type_tab.extend;
    l_end_date_tab.extend;
    l_project_id_tab(1) := P_PROJECT_ID;
    l_resource_list_id_tab(1) := P_RESOURCE_LIST_ID;
    l_struct_ver_id_tab(1) := P_STRUCT_VER_ID;
    l_calendar_type_tab(1) := P_CALENDAR_TYPE;
    l_end_date_tab(1) := P_ACTUALS_THRU_DATE;

    IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_fp_gen_amount_utils.fp_debug
           (p_msg         => 'Before calling PJI_FM_XBS_ACCUM_UTILS.get_summarized_data;'
                             ||'project id passed to get_summarized:'||l_project_id_tab(1)
                             ||'; resource_list_id:'||l_resource_list_id_tab(1)
                             ||'; structure version id:'||l_struct_ver_id_tab(1)
                             ||'; end date:'||p_actuals_thru_date
                             ||'; calendar type:'||p_calendar_type
                             ||'; record type:'||p_record_type,
            p_module_name => l_module_name,
            p_log_level   => 5);
    END IF;
    --dbms_output.put_line('Before calling pji api');
    --Calling PJI API to get table pji_fm_xbs_accum_tmp1 populated
    PJI_FM_XBS_ACCUM_UTILS.get_summarized_data(
        p_project_ids           => l_project_id_tab,
        p_resource_list_ids     => l_resource_list_id_tab,
        p_struct_ver_ids        => l_struct_ver_id_tab,
        p_start_date            => NULL,
        p_end_date              => l_end_date_tab,
        p_start_period_name     => NULL,
        p_end_period_name       => NULL,
        p_calendar_type         => l_calendar_type_tab,
--        p_extraction_type       => NULL,
--        p_calling_context       => NULL,
        p_record_type           => p_record_type,
        p_currency_type         => 6,
        x_return_status         => x_return_status,
        x_msg_code              => x_msg_data);
    IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_fp_gen_amount_utils.fp_debug
           (p_msg         => 'After calling PJI_FM_XBS_ACCUM_UTILS.get_summarized_data,
                            return status is:'||x_return_status,
            p_module_name => l_module_name,
            p_log_level   => 5);
    END IF;
    select count(*) into l_count from PJI_FM_XBS_ACCUM_TMP1;
    --hr_utility.trace('CALLSUM: After calling pji api,  PJI_FM_XBS_ACCUM_TMP1 has:'|| l_count);
    --hr_utility.trace('CALLSUM: After calling pji api: '||x_return_status);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    /* Update rlm_id for all rows in pji_fm_xbs_accum_tmp1 if the resource list
     * (p_fp_cols_rec.X_RESOURCE_LIST_ID) is None - Uncategorized.
     * This logic is not handled by the PJI generic resource mapping API. */

    SELECT NVL(uncategorized_flag,'N')
      INTO l_uncategorized_flag
      FROM pa_resource_lists_all_bg
     WHERE resource_list_id = p_resource_list_id;

    IF l_uncategorized_flag = 'Y' THEN
        l_rlm_id := PA_FP_GEN_AMOUNT_UTILS.GET_RLM_ID (
                       p_project_id          => p_project_id,
                       p_resource_list_id    => p_resource_list_id,
                       p_resource_class_code => 'FINANCIAL_ELEMENTS' );
        UPDATE pji_fm_xbs_accum_tmp1
           SET res_list_member_id = l_rlm_id;
    END IF;

    INSERT INTO PA_FP_FCST_GEN_TMP1 (
                PROJECT_ID,
                STRUCT_VERSION_ID,
                PROJECT_ELEMENT_ID,
                CALENDAR_TYPE,
                PERIOD_NAME,
                PLAN_VERSION_ID,
                RES_LIST_MEMBER_ID,
                QUANTITY,
                TXN_CURRENCY_CODE,
                TXN_RAW_COST,
                TXN_BRDN_COST,
                TXN_REVENUE,
                TXN_LABOR_RAW_COST,
                TXN_LABOR_BRDN_COST,
                TXN_EQUIP_RAW_COST,
                TXN_EQUIP_BRDN_COST,
                TXN_BASE_RAW_COST,
                TXN_BASE_BRDN_COST,
                TXN_BASE_LABOR_RAW_COST,
                TXN_BASE_LABOR_BRDN_COST,
                TXN_BASE_EQUIP_RAW_COST,
                TXN_BASE_EQUIP_BRDN_COST,
                PRJ_RAW_COST,
                PRJ_BRDN_COST,
                PRJ_REVENUE,
                PRJ_LABOR_RAW_COST,
                PRJ_LABOR_BRDN_COST,
                PRJ_EQUIP_RAW_COST,
                PRJ_EQUIP_BRDN_COST,
                PRJ_BASE_RAW_COST,
                PRJ_BASE_BRDN_COST,
                PRJ_BASE_LABOR_RAW_COST,
                PRJ_BASE_LABOR_BRDN_COST,
                PRJ_BASE_EQUIP_RAW_COST,
                PRJ_BASE_EQUIP_BRDN_COST,
                POU_RAW_COST,
                POU_BRDN_COST,
                POU_REVENUE,
                POU_LABOR_RAW_COST,
                POU_LABOR_BRDN_COST,
                POU_EQUIP_RAW_COST,
                POU_EQUIP_BRDN_COST,
                POU_BASE_RAW_COST,
                POU_BASE_BRDN_COST,
                POU_BASE_LABOR_RAW_COST,
                POU_BASE_LABOR_BRDN_COST,
                POU_BASE_EQUIP_RAW_COST,
                POU_BASE_EQUIP_BRDN_COST,
                LABOR_HOURS,
                EQUIPMENT_HOURS,
                SOURCE_ID,
                DATA_TYPE_CODE )
    (SELECT     PROJECT_ID,
                STRUCT_VERSION_ID,
                PROJECT_ELEMENT_ID,
                CALENDAR_TYPE,
                PERIOD_NAME,
                PLAN_VERSION_ID,
                RES_LIST_MEMBER_ID,
                QUANTITY,
                TXN_CURRENCY_CODE,
                TXN_RAW_COST,
                TXN_BRDN_COST,
                TXN_REVENUE,
                TXN_LABOR_RAW_COST,
                TXN_LABOR_BRDN_COST,
                TXN_EQUIP_RAW_COST,
                TXN_EQUIP_BRDN_COST,
                TXN_BASE_RAW_COST,
                TXN_BASE_BRDN_COST,
                TXN_BASE_LABOR_RAW_COST,
                TXN_BASE_LABOR_BRDN_COST,
                TXN_BASE_EQUIP_RAW_COST,
                TXN_BASE_EQUIP_BRDN_COST,
                PRJ_RAW_COST,
                PRJ_BRDN_COST,
                PRJ_REVENUE,
                PRJ_LABOR_RAW_COST,
                PRJ_LABOR_BRDN_COST,
                PRJ_EQUIP_RAW_COST,
                PRJ_EQUIP_BRDN_COST,
                PRJ_BASE_RAW_COST,
                PRJ_BASE_BRDN_COST,
                PRJ_BASE_LABOR_RAW_COST,
                PRJ_BASE_LABOR_BRDN_COST,
                PRJ_BASE_EQUIP_RAW_COST,
                PRJ_BASE_EQUIP_BRDN_COST,
                POU_RAW_COST,
                POU_BRDN_COST,
                POU_REVENUE,
                POU_LABOR_RAW_COST,
                POU_LABOR_BRDN_COST,
                POU_EQUIP_RAW_COST,
                POU_EQUIP_BRDN_COST,
                POU_BASE_RAW_COST,
                POU_BASE_BRDN_COST,
                POU_BASE_LABOR_RAW_COST,
                POU_BASE_LABOR_BRDN_COST,
                POU_BASE_EQUIP_RAW_COST,
                POU_BASE_EQUIP_BRDN_COST,
                LABOR_HOURS,
                EQUIPMENT_HOURS,
                SOURCE_ID,
                P_DATA_TYPE_CODE
    FROM PJI_FM_XBS_ACCUM_TMP1 );
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
             ( p_pkg_name       => 'PA_FP_GEN_FCST_AMT_PUB1'
              ,p_procedure_name => 'CALL_SUMM_POP_TMPS');
           IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                p_module_name => l_module_name,
                p_log_level   => 5);
                PA_DEBUG.Reset_Curr_Function;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END CALL_SUMM_POP_TMPS;

PROCEDURE GEN_AVERAGE_OF_ACTUALS_WRP
          (P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_TASK_ID                 IN          PA_RESOURCE_ASSIGNMENTS.TASK_ID%TYPE,
           P_ACTUALS_THRU_DATE       IN          DATE,
           P_FP_COLS_REC             IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_ACTUALS_FROM_PERIOD      IN         PA_PERIODS_ALL.PERIOD_NAME%TYPE,
           P_ACTUALS_TO_PERIOD        IN         PA_PERIODS_ALL.PERIOD_NAME%TYPE,
           P_ETC_FROM_PERIOD         IN          PA_PERIODS_ALL.PERIOD_NAME%TYPE,
           P_ETC_TO_PERIOD           IN          PA_PERIODS_ALL.PERIOD_NAME%TYPE,
           X_RETURN_STATUS           OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT               OUT  NOCOPY NUMBER,
           X_MSG_DATA                OUT  NOCOPY VARCHAR2)
IS
  l_module_name  VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_FCST_AMT_PUB1.GEN_AVERAGE_OF_ACTUALS_WRP';
  l_task_id_flag VARCHAR2(1);
  CURSOR get_res_asg_cur(c_task_id_flag VARCHAR2) IS
  SELECT ra.resource_assignment_id,
         ra.resource_list_member_id,
         ra.planning_start_date,
         ra.planning_end_date,
         p_task_id
  FROM pa_resource_assignments ra
  WHERE c_task_id_flag = 'Y' AND
        ra.budget_version_id = P_BUDGET_VERSION_ID
        AND ra.task_id = P_TASK_ID
  UNION ALL
  SELECT ra.resource_assignment_id,
         ra.resource_list_member_id,
         ra.planning_start_date,
         ra.planning_end_date,
         ra.task_id
  FROM pa_resource_assignments ra
  WHERE c_task_id_flag = 'N' AND
        ra.budget_version_id = P_BUDGET_VERSION_ID;

  -- Bug 4040832, 3970800: Modified project-level cursor to get
  -- actuals data from PJI table instead of target budget lines.
  CURSOR get_res_asg_cur_proj IS
  SELECT /*+ INDEX(tmp,PA_FP_FCST_GEN_TMP1_N1)*/
         DISTINCT ra.resource_assignment_id,
         tmp.res_list_member_id,
         ra.planning_start_date,
         ra.planning_end_date,
         tmp.project_element_id
   FROM PA_FP_FCST_GEN_TMP1 tmp,
        pa_resource_assignments ra
   WHERE tmp.project_element_id = p_task_id AND
         ra.budget_version_id = P_BUDGET_VERSION_ID AND
         NVL(ra.task_id,0) = 0 AND
         ra.resource_list_member_id = tmp.res_list_member_id;

  -- Bug 4237961: The following 4 cursors have been added for the
  -- Retain Manually Added Lines logic (_ml) for PA/GL and None (_none).

  CURSOR get_res_asg_cur_ml(c_task_id_flag VARCHAR2) IS
  SELECT ra.resource_assignment_id,
         ra.resource_list_member_id,
         ra.planning_start_date,
         ra.planning_end_date,
         p_task_id
  FROM pa_resource_assignments ra
  WHERE c_task_id_flag = 'Y' AND
        ra.budget_version_id = P_BUDGET_VERSION_ID
        AND ra.task_id = P_TASK_ID
        AND ( ra.transaction_source_code IS NOT NULL
              OR ( ra.transaction_source_code IS NULL
                   AND NOT EXISTS ( SELECT 1
                                    FROM   pa_budget_lines bl
                                    WHERE  bl.resource_assignment_id =
                                           ra.resource_assignment_id
                                    AND    bl.start_date > p_actuals_thru_date
                                    AND    rownum < 2 )))
  UNION ALL
  SELECT ra.resource_assignment_id,
         ra.resource_list_member_id,
         ra.planning_start_date,
         ra.planning_end_date,
         ra.task_id
  FROM pa_resource_assignments ra
  WHERE c_task_id_flag = 'N' AND
        ra.budget_version_id = P_BUDGET_VERSION_ID
        AND ( ra.transaction_source_code IS NOT NULL
              OR ( ra.transaction_source_code IS NULL
                   AND NOT EXISTS ( SELECT 1
                                    FROM   pa_budget_lines bl
                                    WHERE  bl.resource_assignment_id =
                                           ra.resource_assignment_id
                                    AND    bl.start_date > p_actuals_thru_date
                                    AND    rownum < 2 )));

  CURSOR get_res_asg_cur_ml_none(c_task_id_flag VARCHAR2) IS
  SELECT ra.resource_assignment_id,
         ra.resource_list_member_id,
         ra.planning_start_date,
         ra.planning_end_date,
         p_task_id
  FROM pa_resource_assignments ra
  WHERE c_task_id_flag = 'Y' AND
        ra.budget_version_id = P_BUDGET_VERSION_ID
        AND ra.task_id = P_TASK_ID
        AND ( ra.transaction_source_code IS NOT NULL
              OR ( ra.transaction_source_code IS NULL
                   AND NOT EXISTS ( SELECT 1
                                    FROM   pa_budget_lines bl
                                    WHERE  bl.resource_assignment_id =
                                           ra.resource_assignment_id
                                    AND    NVL(quantity,0) <> NVL(init_quantity,0)
                                    AND    rownum < 2 )))
  UNION ALL
  SELECT ra.resource_assignment_id,
         ra.resource_list_member_id,
         ra.planning_start_date,
         ra.planning_end_date,
         ra.task_id
  FROM pa_resource_assignments ra
  WHERE c_task_id_flag = 'N' AND
        ra.budget_version_id = P_BUDGET_VERSION_ID
        AND ( ra.transaction_source_code IS NOT NULL
              OR ( ra.transaction_source_code IS NULL
                   AND NOT EXISTS ( SELECT 1
                                    FROM   pa_budget_lines bl
                                    WHERE  bl.resource_assignment_id =
                                           ra.resource_assignment_id
                                    AND    NVL(quantity,0) <> NVL(init_quantity,0)
                                    AND    rownum < 2 )));

  CURSOR get_res_asg_cur_proj_ml IS
  SELECT /*+ INDEX(tmp,PA_FP_FCST_GEN_TMP1_N1)*/
         DISTINCT ra.resource_assignment_id,
         tmp.res_list_member_id,
         ra.planning_start_date,
         ra.planning_end_date,
         tmp.project_element_id
   FROM PA_FP_FCST_GEN_TMP1 tmp,
        pa_resource_assignments ra
   WHERE tmp.project_element_id = p_task_id AND
         ra.budget_version_id = P_BUDGET_VERSION_ID AND
         NVL(ra.task_id,0) = 0 AND
         ra.resource_list_member_id = tmp.res_list_member_id
         AND ( ra.transaction_source_code IS NOT NULL
               OR ( ra.transaction_source_code IS NULL
                    AND NOT EXISTS ( SELECT 1
                                     FROM   pa_budget_lines bl
                                     WHERE  bl.resource_assignment_id =
                                            ra.resource_assignment_id
                                     AND    bl.start_date > p_actuals_thru_date
                                     AND    rownum < 2 )));

  CURSOR get_res_asg_cur_proj_ml_none IS
  SELECT /*+ INDEX(tmp,PA_FP_FCST_GEN_TMP1_N1)*/
         DISTINCT ra.resource_assignment_id,
         tmp.res_list_member_id,
         ra.planning_start_date,
         ra.planning_end_date,
         tmp.project_element_id
   FROM PA_FP_FCST_GEN_TMP1 tmp,
        pa_resource_assignments ra
   WHERE tmp.project_element_id = p_task_id AND
         ra.budget_version_id = P_BUDGET_VERSION_ID AND
         NVL(ra.task_id,0) = 0 AND
         ra.resource_list_member_id = tmp.res_list_member_id
         AND ( ra.transaction_source_code IS NOT NULL
               OR ( ra.transaction_source_code IS NULL
                    AND NOT EXISTS ( SELECT 1
                                     FROM   pa_budget_lines bl
                                     WHERE  bl.resource_assignment_id =
                                            ra.resource_assignment_id
                                     AND    NVL(quantity,0) <> NVL(init_quantity,0)
                                     AND    rownum < 2 )));

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

  l_res_asg_id_tab                      PA_PLSQL_DATATYPES.IdTabTyp;
  l_rlm_id_tab                          PA_PLSQL_DATATYPES.IdTabTyp;
  l_task_id_tab                         PA_PLSQL_DATATYPES.IdTabTyp;
  l_currency_code                       PA_BUDGET_LINES.TXN_CURRENCY_CODE%TYPE;
  l_planning_start_date_tab             PA_PLSQL_DATATYPES.DateTabTyp;
  l_planning_end_date_tab               PA_PLSQL_DATATYPES.DateTabTyp;

  l_actual_from_date       PA_PERIODS_ALL.START_DATE%TYPE;
  l_actual_to_date         PA_PERIODS_ALL.START_DATE%TYPE;
  l_currency_count         NUMBER;
  l_currency_flag          VARCHAR2(2);

  l_msg_count                  NUMBER;
  l_msg_data                   VARCHAR2(2000);
  l_data                       VARCHAR2(2000);
  l_msg_index_out              NUMBER:=0;
BEGIN
    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function     => 'GEN_AVERAGE_OF_ACTUALS_WRP',
                                    p_debug_mode   =>  p_pa_debug_mode);
    END IF;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_COUNT := 0;

    IF p_task_id IS NULL THEN
       l_task_id_flag := 'N';
    ELSE
       l_task_id_flag := 'Y';
    END IF;

    /* Getting the start_date for given actual period based on time phase code */
    IF p_fp_cols_rec.x_time_phased_code = 'P' THEN
        /* Getting the actual_from_date for the given actual_from_period(PA Period) */
        OPEN   pa_start_date_csr(p_actuals_from_period);
        FETCH  pa_start_date_csr
        INTO   l_actual_from_date;
        CLOSE  pa_start_date_csr;
        /* Getting the actual_to_date for the given actual_to_period(PA Period) */
        OPEN   pa_start_date_csr(p_actuals_to_period);
        FETCH  pa_start_date_csr
        INTO   l_actual_to_date;
        CLOSE  pa_start_date_csr;
    ELSIF p_fp_cols_rec.x_time_phased_code = 'G' THEN
        /* Getting the actual_from_date for the given actual_from_period(GL Period) */
        OPEN   gl_start_date_csr(p_actuals_from_period);
        FETCH  gl_start_date_csr
        INTO   l_actual_from_date;
        CLOSE  gl_start_date_csr;
        /* Getting the actual_to_date for the given actual_to_period(GL Period) */
        OPEN   gl_start_date_csr(p_actuals_to_period);
        FETCH  gl_start_date_csr
        INTO   l_actual_to_date;
        CLOSE  gl_start_date_csr;
    END IF;

    -- Bug 4233720 : When the Target version is Revenue with ETC Source of
    -- Average of Actuals, we should not go with the project-level cursor.
    -- Instead, we should use get_res_asg_cur to get all the resource
    -- assignments. In this case, p_task_id will be passed as Null, so
    -- l_task_id_flag will be 'Y'.

    IF p_fp_cols_rec.x_gen_ret_manual_line_flag = 'N' THEN
        IF P_FP_COLS_REC.X_FIN_PLAN_LEVEL_CODE = 'P' AND
           NOT ( P_FP_COLS_REC.X_VERSION_TYPE = 'REVENUE' AND
                 P_FP_COLS_REC.X_GEN_ETC_SRC_CODE = 'AVERAGE_ACTUALS' ) THEN
            OPEN get_res_asg_cur_proj;
            FETCH get_res_asg_cur_proj
            BULK COLLECT
            INTO l_res_asg_id_tab,
                 l_rlm_id_tab,
                 l_planning_start_date_tab,
                 l_planning_end_date_tab,
                 l_task_id_tab;
            CLOSE get_res_asg_cur_proj;
        ELSE
            OPEN get_res_asg_cur(l_task_id_flag);
            FETCH get_res_asg_cur
            BULK COLLECT
            INTO l_res_asg_id_tab,
                 l_rlm_id_tab,
                 l_planning_start_date_tab,
                 l_planning_end_date_tab,
                 l_task_id_tab;
            CLOSE get_res_asg_cur;
        END IF;
    ELSIF p_fp_cols_rec.x_gen_ret_manual_line_flag = 'Y' THEN
        -- Bug 4237961: In addition to the IF/ELSE logic from the Retain
        -- Manual Flag = 'N' case, check the Target time phase code. If
        -- PA/GL, then use the _ml version of the cursor. If None time
        -- phase, then use the _ml_none version of the cursor.
        IF P_FP_COLS_REC.X_FIN_PLAN_LEVEL_CODE = 'P' AND
           NOT ( P_FP_COLS_REC.X_VERSION_TYPE = 'REVENUE' AND
                 P_FP_COLS_REC.X_GEN_ETC_SRC_CODE = 'AVERAGE_ACTUALS' ) THEN
            IF p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
                OPEN get_res_asg_cur_proj_ml;
                FETCH get_res_asg_cur_proj_ml
                BULK COLLECT
                INTO l_res_asg_id_tab,
                     l_rlm_id_tab,
                     l_planning_start_date_tab,
                     l_planning_end_date_tab,
                     l_task_id_tab;
                CLOSE get_res_asg_cur_proj_ml;
            ELSIF p_fp_cols_rec.x_time_phased_code = 'N' THEN
                OPEN get_res_asg_cur_proj_ml_none;
                FETCH get_res_asg_cur_proj_ml_none
                BULK COLLECT
                INTO l_res_asg_id_tab,
                     l_rlm_id_tab,
                     l_planning_start_date_tab,
                     l_planning_end_date_tab,
                     l_task_id_tab;
                CLOSE get_res_asg_cur_proj_ml_none;
            END IF;
        ELSE
            IF p_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
                OPEN get_res_asg_cur_ml(l_task_id_flag);
                FETCH get_res_asg_cur_ml
                BULK COLLECT
                INTO l_res_asg_id_tab,
                     l_rlm_id_tab,
                     l_planning_start_date_tab,
                     l_planning_end_date_tab,
                     l_task_id_tab;
                CLOSE get_res_asg_cur_ml;
            ELSIF p_fp_cols_rec.x_time_phased_code = 'N' THEN
                OPEN get_res_asg_cur_ml_none(l_task_id_flag);
                FETCH get_res_asg_cur_ml_none
                BULK COLLECT
                INTO l_res_asg_id_tab,
                     l_rlm_id_tab,
                     l_planning_start_date_tab,
                     l_planning_end_date_tab,
                     l_task_id_tab;
                CLOSE get_res_asg_cur_ml_none;
            END IF;
        END IF;
    END IF;

    IF l_res_asg_id_tab.count = 0 THEN
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'inside  GEN_AVERAGE_OF_ACTUALS_WRP,no res asg, return...',
                p_module_name => l_module_name,
                p_log_level   => 5);
          PA_DEBUG.RESET_CURR_FUNCTION;
       END IF;
       RETURN;
    END IF;
    FOR i IN 1..l_res_asg_id_tab.count LOOP
        SELECT COUNT(DISTINCT txn_currency_code)
               INTO l_currency_count
        FROM PA_BUDGET_LINES
        WHERE resource_assignment_id = l_res_asg_id_tab(i)
              AND start_date BETWEEN l_actual_from_date AND l_actual_to_date;
        IF l_currency_count <>0 THEN
            /* If we have actual txn amounts in only one currency then the ETC amount
               will be generated in the same currency.   */
            IF l_currency_count = 1 THEN
                l_currency_flag := 'TC';
                SELECT DISTINCT txn_currency_code
                       INTO l_currency_code
                FROM PA_BUDGET_LINES
                WHERE resource_assignment_id = l_res_asg_id_tab(i)
                      AND start_date BETWEEN l_actual_from_date AND l_actual_to_date;
            /* If we have actual txn amounts in more than one currency then the ETC amount
               will be generated in PC by taking the average amount from PC amount. */
            ELSIF l_currency_count > 1 THEN
                l_currency_flag := 'PC';
                l_currency_code := P_FP_COLS_REC.x_project_currency_code;
            END IF;

            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Before calling PA_FP_GEN_FCST_AMT_PVT.GEN_AVERAGE_OF_ACTUALS',
                p_module_name => l_module_name,
                p_log_level   => 5);
            END IF;
            PA_FP_GEN_FCST_AMT_PVT.GEN_AVERAGE_OF_ACTUALS
               (P_BUDGET_VERSION_ID             => P_BUDGET_VERSION_ID,
                P_TASK_ID                       => l_task_id_tab(i),
                P_RES_LIST_MEMBER_ID            => l_rlm_id_tab(i),
                P_TXN_CURRENCY_CODE             => l_currency_code,
                P_CURRENCY_FLAG                 => l_currency_flag,
                P_PLANNING_START_DATE           => l_planning_start_date_tab(i),
                P_PLANNING_END_DATE             => l_planning_end_date_tab(i),
                P_ACTUALS_THRU_DATE             => P_ACTUALS_THRU_DATE,
                P_FP_COLS_REC                   => P_FP_COLS_REC,
                P_ACTUAL_FROM_PERIOD            => P_ACTUALS_FROM_PERIOD,
                P_ACTUAL_TO_PERIOD              => P_ACTUALS_TO_PERIOD,
                P_ETC_FROM_PERIOD               => P_ETC_FROM_PERIOD,
                P_ETC_TO_PERIOD                 => P_ETC_TO_PERIOD,
                P_RESOURCE_ASSIGNMENT_ID        => l_res_asg_id_tab(i),
                X_RETURN_STATUS                 => X_RETURN_STATUS,
                X_MSG_COUNT                     => X_MSG_COUNT,
                X_MSG_DATA                      => X_MSG_DATA );
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'After calling PA_FP_GEN_FCST_AMT_PVT.GEN_AVERAGE_OF_ACTUALS,
                               return status is: '||x_return_status,
                p_module_name => l_module_name,
                p_log_level   => 5);
            END IF;
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
        END IF;
	        /* end if for checking currency count <> 0 */
    END LOOP;

    -- Bug 4165701: Since the generation source is Average of Actuals, we
    -- need to NULL out the spread curves of the generated resources.
    FORALL i IN 1..l_res_asg_id_tab.count
        UPDATE pa_resource_assignments
        SET    spread_curve_id = NULL,
               sp_fixed_date = NULL,
               transaction_source_code = 'AVERAGE_ACTUALS' -- bug 4232619
        WHERE  resource_assignment_id = l_res_asg_id_tab(i);

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
        FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_GEN_FCST_AMT_PUB1',
                     p_procedure_name  => 'GEN_AVERAGE_OF_ACTUALS_WRP',
                     p_error_text      => substr(sqlerrm,1,240));

        IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                p_module_name => l_module_name,
                p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END GEN_AVERAGE_OF_ACTUALS_WRP;

/**Valid values for param:P_ETC_SOURCE_CODE
  * --ETC_WP
  * --ETC_FP
  * --TARGET_FP
  **/
PROCEDURE GET_ETC_REMAIN_BDGT_AMTS
        (P_ETC_SOURCE_CODE           IN          VARCHAR2,
         P_RESOURCE_ASSIGNMENT_ID    IN          NUMBER,
         P_TASK_ID                   IN          NUMBER,
         P_RESOURCE_LIST_MEMBER_ID   IN          NUMBER,
         P_ACTUALS_THRU_DATE         IN          PA_PERIODS_ALL.END_DATE%TYPE,
         P_FP_COLS_REC               IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
         P_WP_STRUCTURE_VERSION_ID   IN          PA_PROJ_ELEM_VER_STRUCTURE.ELEMENT_VERSION_ID%TYPE,
         X_RETURN_STATUS             OUT  NOCOPY VARCHAR2,
         X_MSG_COUNT                 OUT  NOCOPY NUMBER,
         X_MSG_DATA                  OUT  NOCOPY VARCHAR2)
IS
  l_module_name  VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_FCST_AMT_PUB1.GEN_ETC_REMAIN_BDGT_AMTS';

  l_currency_count_tot                  NUMBER;
  l_currency_count_act                  NUMBER;
  l_currency_code_tot                   PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE;
  l_currency_code_act                   PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE;
  l_currency_flag                       VARCHAR2(2);
  l_etc_currency_code                   PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE;

  l_tot_qty                             NUMBER;
  l_tot_txn_raw_cost                    NUMBER;
  l_tot_txn_brdn_cost                   NUMBER;

  l_act_qty                             NUMBER;
  l_act_txn_raw_cost                    NUMBER;
  l_act_txn_brdn_cost                   NUMBER;

  l_etc_qty                             NUMBER;
  l_etc_txn_raw_cost                    NUMBER;
  l_etc_txn_brdn_cost                   NUMBER;

  l_act_work_qty                NUMBER;
  l_tot_work_qty                NUMBER;
  l_ppl_act_cost_pc             NUMBER;
  l_eqpmt_act_cost_pc           NUMBER;
  l_oth_act_cost_pc             NUMBER;
  l_ppl_act_cst_fc              NUMBER;
  l_eqpmt_act_cost_fc           NUMBER;
  l_oth_act_cost_fc             NUMBER;
  l_txn_currency_code           VARCHAR2(30);
  l_ppl_act_cost_tc             NUMBER;
  l_eqpmt_act_cost_tc           NUMBER;
  l_oth_act_cost_tc             NUMBER;
  l_ppl_act_rawcost_pc          NUMBER;
  l_eqpmt_act_rawcost_pc        NUMBER;
  l_oth_act_rawcost_pc          NUMBER;
  l_ppl_act_rawcst_fc           NUMBER;
  l_eqpmt_act_rawcost_fc        NUMBER;
  l_oth_act_rawcost_fc          NUMBER;
  l_ppl_act_rawcost_tc          NUMBER;
  l_eqpmt_act_rawcost_tc        NUMBER;
  l_oth_act_rawcost_tc          NUMBER;

  l_oth_quantity                NUMBER;
  l_act_labor_effort            NUMBER;
  l_act_eqpmt_effort            NUMBER;
  l_uom                         VARCHAR2(30);

  l_msg_count                  NUMBER;
  l_msg_data                   VARCHAR2(2000);
  l_data                       VARCHAR2(2000);
  l_msg_index_out              NUMBER:=0;
BEGIN
    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function     => 'GEN_ETC_REMAIN_BDGT_AMTS',
                                    p_debug_mode   =>  p_pa_debug_mode);
    END IF;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_COUNT := 0;

    /*currency_flag is defaulted to PC: project currency,
      etc_currency_code is defaulted to project currency code.
      cnt of 'total' currency; cnt of 'act'; currency_flag; etc_currency_code
             1             1                     TC         tot currency code
             1             0                     TC         tot currency_code
             0             1                     TC         act currency_code
             0             0                 return without processing etc
             m             n                     PC         proj currency_code
    */
    IF P_ETC_SOURCE_CODE = 'FINANCIAL_PLAN' THEN
        l_currency_flag := 'PC';
        l_etc_currency_code := P_FP_COLS_REC.x_project_currency_code;

        SELECT /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
           COUNT(DISTINCT TXN_CURRENCY_CODE)
           INTO l_currency_count_tot
        FROM PA_FP_CALC_AMT_TMP2
        WHERE RESOURCE_ASSIGNMENT_ID = P_RESOURCE_ASSIGNMENT_ID
          AND ETC_CURRENCY_CODE IS NULL;

        SELECT /*+ INDEX(PA_FP_FCST_GEN_TMP1,PA_FP_FCST_GEN_TMP1_N1)*/
               COUNT(DISTINCT TXN_CURRENCY_CODE)
         INTO  l_currency_count_act
         FROM  PA_FP_FCST_GEN_TMP1
        WHERE  project_element_id = P_TASK_ID
          AND  res_list_member_id = P_RESOURCE_LIST_MEMBER_ID
          AND  data_type_code = P_ETC_SOURCE_CODE;
        /* hr_utility.trace('currency count tot :'||l_currency_count_tot );
        hr_utility.trace('currency count act :'||l_currency_count_act );  */
        IF l_currency_count_tot = 0 and l_currency_count_act = 0 THEN
            IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.RESET_CURR_FUNCTION;
            END IF;
            RETURN;
        END IF;

        IF l_currency_count_tot = 1
           AND l_currency_count_act = 1
           AND p_fp_cols_rec.x_plan_in_multi_curr_flag = 'Y' THEN
            SELECT /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
               DISTINCT TXN_CURRENCY_CODE
               INTO l_currency_code_tot
            FROM PA_FP_CALC_AMT_TMP2
            WHERE RESOURCE_ASSIGNMENT_ID = P_RESOURCE_ASSIGNMENT_ID
              AND ETC_CURRENCY_CODE IS NULL;

            SELECT /*+ INDEX(PA_FP_FCST_GEN_TMP1,PA_FP_FCST_GEN_TMP1_N1)*/
               DISTINCT TXN_CURRENCY_CODE
               INTO l_currency_code_act
            FROM PA_FP_FCST_GEN_TMP1
            WHERE project_element_id = P_TASK_ID
              AND res_list_member_id = P_RESOURCE_LIST_MEMBER_ID
              AND data_type_code = P_ETC_SOURCE_CODE;

            IF l_currency_code_tot = l_currency_code_act THEN
                l_currency_flag := 'TC';
                l_etc_currency_code := l_currency_code_tot;
            END IF;
        ELSIF l_currency_count_tot = 1
          AND l_currency_count_act = 0
          AND p_fp_cols_rec.x_plan_in_multi_curr_flag = 'Y' THEN
            l_currency_flag := 'TC';
            SELECT /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
               DISTINCT TXN_CURRENCY_CODE
               INTO l_etc_currency_code
            FROM PA_FP_CALC_AMT_TMP2
            WHERE RESOURCE_ASSIGNMENT_ID = P_RESOURCE_ASSIGNMENT_ID
              AND ETC_CURRENCY_CODE IS NULL;
        ELSIF l_currency_count_tot = 0
          AND l_currency_count_act = 1
          AND p_fp_cols_rec.x_plan_in_multi_curr_flag = 'Y' THEN
            l_currency_flag := 'TC';
            SELECT /*+ INDEX(PA_FP_FCST_GEN_TMP1,PA_FP_FCST_GEN_TMP1_N1)*/
               DISTINCT TXN_CURRENCY_CODE
               INTO l_etc_currency_code
            FROM PA_FP_FCST_GEN_TMP1
            WHERE project_element_id = P_TASK_ID
              AND res_list_member_id = P_RESOURCE_LIST_MEMBER_ID
              AND data_type_code = P_ETC_SOURCE_CODE;
        END IF;

        BEGIN
            SELECT /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
                   SUM(NVL(TOTAL_PLAN_QUANTITY, 0)),
                   SUM(NVL(DECODE(l_currency_flag, 'TC', TOTAL_TXN_RAW_COST,
                                                   'PC', TOTAL_PC_RAW_COST), 0)),
                   SUM(NVL(DECODE(l_currency_flag, 'TC', TOTAL_TXN_BURDENED_COST,
                                                   'PC', TOTAL_PC_BURDENED_COST),0))
                   INTO l_tot_qty,
                        l_tot_txn_raw_cost,
                        l_tot_txn_brdn_cost
            FROM PA_FP_CALC_AMT_TMP2
            WHERE RESOURCE_ASSIGNMENT_ID = P_RESOURCE_ASSIGNMENT_ID
              AND ETC_CURRENCY_CODE IS  NULL;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_tot_qty := 0;
                l_tot_txn_raw_cost := 0;
                l_tot_txn_brdn_cost := 0;
        END;
        /* hr_utility.trace('tot qty in rem plan:'||l_tot_qty );
        hr_utility.trace('tot rc in rem plan:'||l_tot_txn_raw_cost );
        hr_utility.trace('tot bc in rem plan:'||l_tot_txn_brdn_cost );  */
        /* commented the following code. B/c, the qty could be NULL AND
           we may get raw cost and burdened cost. (data issues)
        IF l_tot_qty IS NULL THEN
            -- hr_utility.trace('inside tot qty null'||l_tot_qty );
            l_tot_qty := 0;
            l_tot_txn_raw_cost := 0;
            l_tot_txn_brdn_cost := 0;
        END IF;
        */
        l_tot_qty := NVL(l_tot_qty,0);
        l_tot_txn_raw_cost := NVL(l_tot_txn_raw_cost,0);
        l_tot_txn_brdn_cost := NVL(l_tot_txn_brdn_cost,0);

        BEGIN
            SELECT SUM(NVL(quantity,0)),
                   SUM(NVL(DECODE(l_currency_flag, 'TC', txn_raw_cost,
                                                   'PC', prj_raw_cost),0)),
                   SUM(NVL(DECODE(l_currency_flag, 'TC', txn_brdn_cost,
                                                   'PC', prj_brdn_cost),0))
                   INTO
                   l_act_qty,
                   l_act_txn_raw_cost,
                   l_act_txn_brdn_cost
            FROM /*+ INDEX(PA_FP_FCST_GEN_TMP1,PA_FP_FCST_GEN_TMP1_N1)*/
                  PA_FP_FCST_GEN_TMP1
            WHERE project_element_id = P_TASK_ID
              AND res_list_member_id = P_RESOURCE_LIST_MEMBER_ID
              AND data_type_code = P_ETC_SOURCE_CODE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_act_qty := 0;
                l_act_txn_raw_cost := 0;
                l_act_txn_brdn_cost := 0;
        END;
        /* hr_utility.trace('act qty '||l_act_qty );
        hr_utility.trace('act rc  '||l_act_txn_raw_cost );
        hr_utility.trace('act bc  '||l_act_txn_brdn_cost );  */
        /* IF l_act_qty IS NULL THEN
            l_act_qty := 0;
            l_act_txn_raw_cost := 0;
            l_act_txn_brdn_cost := 0;
        END IF; */
            l_act_qty := NVL(l_act_qty,0);
            l_act_txn_raw_cost := NVL(l_act_txn_raw_cost,0);
            l_act_txn_brdn_cost := NVL(l_act_txn_brdn_cost,0);

    ELSIF P_ETC_SOURCE_CODE = 'WORKPLAN_RESOURCES' THEN
        /*getting actuals*/
        l_currency_flag := 'PC';
        l_etc_currency_code := P_FP_COLS_REC.x_project_currency_code;

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Before calling PA_PROGRESS_UTILS.'||
                                 'get_actuals_for_task in remain_bdgt',
                p_module_name => l_module_name,
                p_log_level   => 5);
        END IF;

        PA_PROGRESS_UTILS.get_actuals_for_task(
                p_project_id            => P_FP_COLS_REC.X_PROJECT_ID,
                p_wp_task_id            => P_TASK_ID,
                p_res_list_mem_id       => P_RESOURCE_LIST_MEMBER_ID,
                p_as_of_date            => P_ACTUALS_THRU_DATE,
                x_planned_work_qty      => l_tot_work_qty,
                x_actual_work_qty       => l_act_work_qty,
                x_ppl_act_cost_pc       => l_ppl_act_cost_pc,
                x_eqpmt_act_cost_pc     => l_eqpmt_act_cost_pc,
                x_oth_act_cost_pc       => l_oth_act_cost_pc,
                x_ppl_act_cost_fc       => l_ppl_act_cst_fc,
                x_eqpmt_act_cost_fc     => l_eqpmt_act_cost_fc,
                x_oth_act_cost_fc       => l_oth_act_cost_fc,
                x_act_labor_effort      => l_act_labor_effort,
                x_act_eqpmt_effort      => l_act_eqpmt_effort,
                x_unit_of_measure       => l_uom,
                x_txn_currency_code     => l_txn_currency_code,
                x_ppl_act_cost_tc       => l_ppl_act_cost_tc,
                x_eqpmt_act_cost_tc     => l_eqpmt_act_cost_tc,
                x_oth_act_cost_tc       => l_oth_act_cost_tc,
                X_PPL_ACT_RAWCOST_PC    => l_ppl_act_rawcost_pc,
                X_EQPMT_ACT_RAWCOST_PC  => l_eqpmt_act_rawcost_pc,
                X_OTH_ACT_RAWCOST_PC    => l_oth_act_rawcost_pc,
                X_PPL_ACT_RAWCOST_FC    => l_ppl_act_rawcst_fc,
                X_EQPMT_ACT_RAWCOST_FC  => l_eqpmt_act_rawcost_fc,
                X_OTH_ACT_RAWCOST_FC    => l_oth_act_rawcost_fc,
                X_PPL_ACT_RAWCOST_TC    => l_ppl_act_rawcost_tc,
                X_EQPMT_ACT_RAWCOST_TC  => l_eqpmt_act_rawcost_tc,
                X_OTH_ACT_RAWCOST_TC    => l_oth_act_rawcost_tc,
                X_OTH_QUANTITY          => l_oth_quantity,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data );
        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'After calling PA_PROGRESS_UTILS.'||
                     'get_actuals_for_task in remain_bdgt'||x_return_status,
                p_module_name => l_module_name,
                p_log_level   => 5);
        END IF;
        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
        l_act_qty := NVL(l_act_labor_effort,0) + NVL(l_act_eqpmt_effort,0)
                     + NVL(l_oth_quantity,0);
        l_act_txn_brdn_cost := nvl(l_ppl_act_cost_pc,0) +
                               nvl(l_eqpmt_act_cost_pc,0) +
                               nvl(l_oth_act_cost_pc,0);
        l_act_txn_raw_cost :=  nvl(l_ppl_act_rawcost_pc,0) +
                               nvl(l_eqpmt_act_rawcost_pc,0) +
                               nvl(l_oth_act_rawcost_pc,0);

        /*getting total*/
        SELECT /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
           COUNT(DISTINCT TXN_CURRENCY_CODE)
           INTO l_currency_count_tot
        FROM PA_FP_CALC_AMT_TMP2
        WHERE RESOURCE_ASSIGNMENT_ID = P_RESOURCE_ASSIGNMENT_ID
          AND ETC_CURRENCY_CODE IS NULL;

        IF l_currency_count_tot = 1
           AND p_fp_cols_rec.x_plan_in_multi_curr_flag = 'Y' THEN
            SELECT /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
               DISTINCT TXN_CURRENCY_CODE
               INTO l_currency_code_tot
            FROM PA_FP_CALC_AMT_TMP2
            WHERE RESOURCE_ASSIGNMENT_ID = P_RESOURCE_ASSIGNMENT_ID
              AND ETC_CURRENCY_CODE IS NULL;

            IF l_currency_code_tot = l_txn_currency_code OR
               l_txn_currency_code is NULL THEN
                l_currency_flag := 'TC';
                l_etc_currency_code := l_currency_code_tot;

                l_act_txn_brdn_cost := nvl(l_ppl_act_cost_tc,0) +
                                       nvl(l_eqpmt_act_cost_tc,0) +
                                       nvl(l_oth_act_cost_tc,0);
                l_act_txn_raw_cost :=  nvl(l_ppl_act_rawcost_tc,0) +
                                       nvl(l_eqpmt_act_rawcost_tc,0) +
                                       nvl(l_oth_act_rawcost_tc,0);
            END IF;
        END IF;

        BEGIN
            SELECT /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
                   SUM(NVL(TOTAL_PLAN_QUANTITY, 0)),
                   SUM(NVL(DECODE(l_currency_flag, 'TC', TOTAL_TXN_RAW_COST,
                                                   'PC', TOTAL_PC_RAW_COST), 0)),
                   SUM(NVL(DECODE(l_currency_flag, 'TC', TOTAL_TXN_BURDENED_COST,
                                                   'PC', TOTAL_PC_BURDENED_COST),0))
                   INTO l_tot_qty,
                        l_tot_txn_raw_cost,
                        l_tot_txn_brdn_cost
            FROM PA_FP_CALC_AMT_TMP2
            WHERE RESOURCE_ASSIGNMENT_ID = P_RESOURCE_ASSIGNMENT_ID
              AND ETC_CURRENCY_CODE IS  NULL;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_tot_qty := 0;
                l_tot_txn_raw_cost := 0;
                l_tot_txn_brdn_cost := 0;
        END;
        l_tot_qty := NVL(l_tot_qty,0);
        l_tot_txn_raw_cost := NVL(l_tot_txn_raw_cost,0);
        l_tot_txn_brdn_cost := NVL(l_tot_txn_brdn_cost,0);
        /* IF l_tot_qty IS NULL THEN
            l_tot_qty := 0;
            l_tot_txn_raw_cost := 0;
            l_tot_txn_brdn_cost := 0;
        END IF;  */

    END IF;

    l_etc_qty := l_tot_qty - l_act_qty;
    l_etc_txn_raw_cost := l_tot_txn_raw_cost - l_act_txn_raw_cost;
    l_etc_txn_brdn_cost := l_tot_txn_brdn_cost - l_act_txn_brdn_cost;
       /* hr_utility.trace('etc qty '||l_etc_qty );
       hr_utility.trace('etc curr'||l_ETC_CURRENCY_CODE );
       hr_utility.trace('etc rc  '||l_etc_txn_raw_cost );
       hr_utility.trace('etc bc  '||l_etc_txn_brdn_cost );  */

    IF l_etc_qty <> 0 OR l_etc_txn_raw_cost <> 0 OR l_etc_txn_brdn_cost <> 0 THEN
        INSERT INTO PA_FP_CALC_AMT_TMP2
           (RESOURCE_ASSIGNMENT_ID,
            ETC_CURRENCY_CODE,
            ETC_PLAN_QUANTITY,
            ETC_TXN_RAW_COST,
            ETC_TXN_BURDENED_COST)
        VALUES
           (P_RESOURCE_ASSIGNMENT_ID,
            l_etc_currency_code,
            l_etc_qty,
            l_etc_txn_raw_cost,
            l_etc_txn_brdn_cost);
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
                   ( p_pkg_name        => 'PA_FP_GEN_FCST_AMT_PUB1',
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


PROCEDURE GET_ETC_BDGT_COMPLETE_AMTS
        (P_ETC_SOURCE_CODE         IN   VARCHAR2,
         P_ETC_SRC_BUDGET_VER_ID   IN   PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
         P_RESOURCE_ASSIGNMENT_ID  IN   NUMBER,
         P_TASK_ID                 IN   NUMBER,
         P_RESOURCE_LIST_MEMBER_ID IN   NUMBER,
         P_ACTUALS_THRU_DATE       IN   PA_PERIODS_ALL.END_DATE%TYPE,
         P_FP_COLS_REC             IN   PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
         P_WP_STRUCTURE_VERSION_ID IN   PA_PROJ_ELEM_VER_STRUCTURE.ELEMENT_VERSION_ID%TYPE,
         X_RETURN_STATUS           OUT  NOCOPY VARCHAR2,
         X_MSG_COUNT               OUT  NOCOPY NUMBER,
         X_MSG_DATA                OUT  NOCOPY VARCHAR2 )
IS
  l_module_name  VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_FCST_AMT_PUB1.GEN_ETC_BDGT_COMPLETE_AMTS';

  l_currency_count_tot                  NUMBER;
  l_currency_count_bsl                  NUMBER;
  l_currency_code_tot                   PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE;
  l_currency_code_bsl                   PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE;
  l_currency_flag                       VARCHAR2(2);
  l_etc_currency_code                   PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE;

  l_tot_txn_currency_code               NUMBER;
  l_tot_qty                             NUMBER;
  l_tot_txn_raw_cost                    NUMBER;
  l_tot_txn_brdn_cost                   NUMBER;

  l_structure_type                      VARCHAR2(30);
  l_structure_status                    VARCHAR2(30);
  l_structure_status_flag               VARCHAR2(30);
  lx_percent_complete                   NUMBER;
  l_percent_complete                    NUMBER;

  l_bsln_qty                            NUMBER;
  l_bsln_txn_raw_cost                   NUMBER;
  l_bsln_txn_brdn_cost                  NUMBER;

  l_etc_qty                             NUMBER;
  l_etc_txn_raw_cost                    NUMBER;
  l_etc_txn_brdn_cost                   NUMBER;

  l_msg_count                  NUMBER;
  l_msg_data                   VARCHAR2(2000);
  l_data                       VARCHAR2(2000);
  l_msg_index_out              NUMBER:=0;
  l_WP_STRUCTURE_VERSION_ID    number;
BEGIN
    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function     => 'GEN_ETC_BDGT_COMPLETE_AMTS',
                                    p_debug_mode   =>  p_pa_debug_mode);
    END IF;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_COUNT := 0;

    l_structure_type                    := null;
    l_structure_status                  := null;
    l_structure_status_flag             := null;
    l_WP_STRUCTURE_VERSION_ID           := null;
    /* for getting the financial percent complete,
       we dont have to pass the structure version id.
       It always comes from the lates published
       financial structure version. */

    IF P_ETC_SOURCE_CODE = 'FINANCIAL_PLAN' THEN
        l_structure_type := 'FINANCIAL';
    ELSE
        l_WP_STRUCTURE_VERSION_ID := P_WP_STRUCTURE_VERSION_ID;

        l_structure_type := 'WORKPLAN';
        l_structure_status_flag :=
        PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(
                P_FP_COLS_REC.X_PROJECT_ID,l_WP_STRUCTURE_VERSION_ID);
        If l_structure_status_flag = 'Y' THEN
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
    --dbms_output.put_line('project_id:'||P_FP_COLS_REC.X_PROJECT_ID);
    --dbms_output.put_line('proj_element_id; task_id:'||P_TASK_ID);
    --dbms_output.put_line('P_ACTUALS_THRU_DATE:'||P_ACTUALS_THRU_DATE);
    --dbms_output.put_line('l_structure_status_flag:'||l_structure_status_flag);
    --dbms_output.put_line('l_structure_status:'||l_structure_status);
    --dbms_output.put_line('P_WP_STRUCTURE_VERSION_ID:'||P_WP_STRUCTURE_VERSION_ID);
    --dbms_output.put_line('l_structure_type:'||l_structure_type);
    PA_PROGRESS_UTILS.REDEFAULT_BASE_PC (
        p_Project_ID            => P_FP_COLS_REC.X_PROJECT_ID,
        p_Proj_element_id       => P_TASK_ID,
        p_Structure_type        => l_structure_type,
        p_object_type           => 'PA_TASKS',
        p_As_Of_Date            => P_ACTUALS_THRU_DATE,
        P_STRUCTURE_VERSION_ID  => l_WP_STRUCTURE_VERSION_ID,
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
    --dbms_output.put_line('BDGT_COMPLETE: p_proj_element_id:'||p_task_id);
    --dbms_output.put_line('l_percent_complete:'||lx_percent_complete);

    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;
    l_percent_complete := NVL(lx_percent_complete,0)/100;

    /*currency_flag is defaulted to PC: project currency,
      etc_currency_code is defaulted to project currency code.
      cnt of 'total' currency; cnt of 'bsln'; currency_flag; etc_currency_code
             1             1                     TC         tot currency code
             1             0                     TC         tot currency_code
             0             1                     TC         bsln currency_code
             0             0                 return without processing etc
             m             n                     PC         proj currency_code
    */
    l_currency_flag := 'PC';
    l_etc_currency_code := P_FP_COLS_REC.x_project_currency_code;

    SELECT /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
           COUNT(DISTINCT TXN_CURRENCY_CODE)
           INTO l_currency_count_tot
    FROM PA_FP_CALC_AMT_TMP2
    WHERE RESOURCE_ASSIGNMENT_ID = P_RESOURCE_ASSIGNMENT_ID
          AND ETC_CURRENCY_CODE IS NULL;

  /* SELECT COUNT(DISTINCT TXN_CURRENCY_CODE)
           INTO l_currency_count_bsl
    FROM PA_FP_CALC_AMT_TMP3
    WHERE plan_version_id = P_ETC_SRC_BUDGET_VER_ID
          AND task_id = P_TASK_ID
          AND res_list_member_id = P_RESOURCE_LIST_MEMBER_ID
          AND res_asg_id = P_RESOURCE_ASSIGNMENT_ID;*/

    IF  l_currency_count_tot = 0 THEN
        IF P_PA_DEBUG_MODE = 'Y' THEN
           PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RETURN;
    END IF;

    IF l_currency_count_tot = 1 AND
       p_fp_cols_rec.x_plan_in_multi_curr_flag = 'Y' THEN
          SELECT /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
                 DISTINCT TXN_CURRENCY_CODE
          INTO   l_currency_code_tot
          FROM   PA_FP_CALC_AMT_TMP2
          WHERE  RESOURCE_ASSIGNMENT_ID = P_RESOURCE_ASSIGNMENT_ID
          AND    ETC_CURRENCY_CODE IS NULL;
          l_currency_flag := 'TC';
          l_etc_currency_code := l_currency_code_tot;
    ELSE
          l_currency_flag := 'PC';
          l_etc_currency_code := P_FP_COLS_REC.x_project_currency_code;
    END IF;

    BEGIN
        SELECT /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
               SUM(NVL(TOTAL_PLAN_QUANTITY,0)),
               SUM(NVL(DECODE(l_currency_flag, 'TC', TOTAL_TXN_RAW_COST,
                                               'PC', TOTAL_PC_RAW_COST),0)),
               SUM(NVL(DECODE(l_currency_flag, 'TC', TOTAL_TXN_BURDENED_COST,
                                               'PC', TOTAL_PC_BURDENED_COST),0))
               INTO l_tot_qty,
                    l_tot_txn_raw_cost,
                    l_tot_txn_brdn_cost
        FROM PA_FP_CALC_AMT_TMP2
        WHERE RESOURCE_ASSIGNMENT_ID = P_RESOURCE_ASSIGNMENT_ID
              AND ETC_CURRENCY_CODE IS NULL;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_tot_qty := 0;
            l_tot_txn_raw_cost := 0;
            l_tot_txn_brdn_cost := 0;
    END;
    /* IF l_tot_qty IS NULL THEN
       l_tot_qty := 0;
       l_tot_txn_raw_cost := 0;
       l_tot_txn_brdn_cost := 0;
    END IF; */
        l_tot_qty := NVL(l_tot_qty,0);
        l_tot_txn_raw_cost := NVL(l_tot_txn_raw_cost,0);
        l_tot_txn_brdn_cost := NVL(l_tot_txn_brdn_cost,0);

    l_etc_qty := l_tot_qty -  (l_percent_complete*l_tot_qty);
    l_etc_txn_raw_cost := l_tot_txn_raw_cost - (l_percent_complete*l_tot_txn_raw_cost);
    l_etc_txn_brdn_cost := l_tot_txn_brdn_cost - (l_percent_complete*l_tot_txn_brdn_cost);

    IF l_etc_qty <> 0 OR l_etc_txn_raw_cost <> 0 OR l_etc_txn_brdn_cost <> 0 THEN
        INSERT INTO PA_FP_CALC_AMT_TMP2
           (RESOURCE_ASSIGNMENT_ID,
            ETC_CURRENCY_CODE,
            ETC_PLAN_QUANTITY,
            ETC_TXN_RAW_COST,
            ETC_TXN_BURDENED_COST)
        VALUES
           (P_RESOURCE_ASSIGNMENT_ID,
            l_etc_currency_code,
            l_etc_qty,
            l_etc_txn_raw_cost,
            l_etc_txn_brdn_cost);
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
                   ( p_pkg_name        => 'PA_FP_GEN_FCST_AMT_PUB1',
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

PROCEDURE GET_ETC_EARNED_VALUE_AMTS
        (P_ETC_SOURCE_CODE           IN          VARCHAR2,
         P_RESOURCE_ASSIGNMENT_ID    IN          NUMBER,
         P_TASK_ID                   IN          NUMBER,
         P_RESOURCE_LIST_MEMBER_ID   IN          NUMBER,
         P_ACTUALS_THRU_DATE         IN          PA_PERIODS_ALL.END_DATE%TYPE,
         P_FP_COLS_REC               IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
         P_WP_STRUCTURE_VERSION_ID   IN          PA_PROJ_ELEM_VER_STRUCTURE.ELEMENT_VERSION_ID%TYPE,
         X_RETURN_STATUS             OUT  NOCOPY VARCHAR2,
         X_MSG_COUNT                 OUT  NOCOPY NUMBER,
         X_MSG_DATA                  OUT  NOCOPY VARCHAR2
         )
IS
  l_module_name  VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_FCST_AMT_PUB1.GEN_ETC_EARNED_VALUE_AMTS';

  l_txn_currency_count_act              NUMBER;
  l_txn_currency_code_act               PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE;
  l_txn_currency_count_tot              NUMBER;
  l_txn_currency_code_tot               PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE;
  l_etc_currency_code                   PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE;

  l_act_qty                             NUMBER;
  l_act_txn_raw_cost                    NUMBER;
  l_act_txn_brdn_cost                   NUMBER;
  l_act_pc_raw_cost                     NUMBER;
  l_act_pc_brdn_cost                    NUMBER;

  l_tot_qty                             NUMBER;
  l_tot_txn_raw_cost                    NUMBER;
  l_tot_txn_brdn_cost                   NUMBER;
  l_tot_pc_raw_cost                     NUMBER;
  l_tot_pc_brdn_cost                    NUMBER;

  l_structure_type                      VARCHAR2(30);
  l_structure_status                    VARCHAR2(30);
  l_structure_status_flag               VARCHAR2(30);
  lx_percent_complete                   NUMBER;
  l_percent_complete                    NUMBER;
  l_etc_qty                             NUMBER;
  l_etc_raw_cost                        NUMBER;
  l_etc_brdn_cost                       NUMBER;

  l_act_work_qty                NUMBER;
  l_tot_work_qty                NUMBER;
  l_ppl_act_cost_pc             NUMBER;
  l_eqpmt_act_cost_pc           NUMBER;
  l_oth_act_cost_pc             NUMBER;
  l_ppl_act_cst_fc              NUMBER;
  l_eqpmt_act_cost_fc           NUMBER;
  l_oth_act_cost_fc             NUMBER;
  l_txn_currency_code           VARCHAR2(30);
  l_ppl_act_cost_tc             NUMBER;
  l_eqpmt_act_cost_tc           NUMBER;
  l_oth_act_cost_tc             NUMBER;
  l_act_labor_effort            NUMBER;
  l_act_eqpmt_effort            NUMBER;
  l_uom                         VARCHAR2(30);

  l_ppl_act_rawcost_pc          NUMBER;
  l_eqpmt_act_rawcost_pc        NUMBER;
  l_oth_act_rawcost_pc          NUMBER;
  l_ppl_act_rawcst_fc           NUMBER;
  l_eqpmt_act_rawcost_fc        NUMBER;
  l_oth_act_rawcost_fc          NUMBER;
  l_ppl_act_rawcost_tc          NUMBER;
  l_eqpmt_act_rawcost_tc        NUMBER;
  l_oth_act_rawcost_tc          NUMBER;

  l_oth_quantity                NUMBER;

  l_msg_count                  NUMBER;
  l_msg_data                   VARCHAR2(2000);
  l_data                       VARCHAR2(2000);
  l_msg_index_out              NUMBER:=0;
  l_WP_STRUCTURE_VERSION_ID    number;
  l_act_exist_flag             VARCHAR2(1):= 'N';
  l_act_txn_pc_flag            VARCHAR2(10):= 'PC';
  l_tot_txn_pc_flag            VARCHAR2(10):= 'PC';
BEGIN
    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function     => 'GEN_ETC_EARNED_VALUE_AMTS',
                                    p_debug_mode   =>  p_pa_debug_mode);
    END IF;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_COUNT := 0;

    l_structure_type                    := null;
    l_structure_status                  := null;
    l_structure_status_flag             := null;
    l_WP_STRUCTURE_VERSION_ID           := null;
    /* for getting the financial percent complete,
       we dont have to pass the structure version id.
       It always comes from the lates published
       financial structure version. */
    IF P_ETC_SOURCE_CODE = 'FINANCIAL_PLAN' THEN
        l_structure_type := 'FINANCIAL';
    ELSE
        l_WP_STRUCTURE_VERSION_ID := P_WP_STRUCTURE_VERSION_ID;
        l_structure_type := 'WORKPLAN';
        l_structure_status_flag :=
        PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(
                P_FP_COLS_REC.X_PROJECT_ID,l_WP_STRUCTURE_VERSION_ID);
        If l_structure_status_flag = 'Y' THEN
           l_structure_status := 'PUBLISHED';
        ELSE
           l_structure_status := 'WORKING';
        END IF;
    END IF;


    IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         =>  'Before calling PA_PROGRESS_UTILS.REDEFAULT_BASE_PC',
                p_module_name => l_module_name,
                p_log_level   => 5);
    END IF;
    PA_PROGRESS_UTILS.REDEFAULT_BASE_PC (
        p_Project_ID            => P_FP_COLS_REC.X_PROJECT_ID,
        p_Proj_element_id       => P_TASK_ID,
        p_Structure_type        => l_structure_type,
        p_object_type           => 'PA_TASKS',
        p_As_Of_Date            => P_ACTUALS_THRU_DATE,
        P_STRUCTURE_VERSION_ID  => l_WP_STRUCTURE_VERSION_ID,
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
    IF l_percent_complete = 1 THEN
       IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.RESET_CURR_FUNCTION;
       END IF;
       RETURN;
    END IF;

    /*Getting ACWP in both TXN and PROJ currencies*/
    IF P_ETC_SOURCE_CODE = 'FINANCIAL_PLAN' THEN
        SELECT /*+ INDEX(PA_FP_FCST_GEN_TMP1,PA_FP_FCST_GEN_TMP1_N1)*/
               COUNT(DISTINCT TXN_CURRENCY_CODE),SUM(NVL(quantity,0))
               INTO l_txn_currency_count_act,l_act_qty
        FROM PA_FP_FCST_GEN_TMP1
        WHERE project_element_id = P_TASK_ID
          AND res_list_member_id = P_RESOURCE_LIST_MEMBER_ID
          AND data_type_code = P_ETC_SOURCE_CODE;

        IF l_txn_currency_count_act = 0
           OR NVL(l_act_qty,0) = 0 THEN
            l_act_exist_flag := 'N';
        ELSIF l_txn_currency_count_act = 1
              AND p_fp_cols_rec.x_plan_in_multi_curr_flag = 'Y' THEN
            l_act_exist_flag := 'Y';
            l_act_txn_pc_flag := 'TC';
            SELECT /*+ INDEX(PA_FP_FCST_GEN_TMP1,PA_FP_FCST_GEN_TMP1_N1)*/
                   DISTINCT TXN_CURRENCY_CODE
                   INTO l_txn_currency_code_act
            FROM PA_FP_FCST_GEN_TMP1
            WHERE project_element_id = P_TASK_ID
              AND res_list_member_id = P_RESOURCE_LIST_MEMBER_ID
              AND data_type_code = P_ETC_SOURCE_CODE;

            BEGIN
              SELECT /*+ INDEX(PA_FP_FCST_GEN_TMP1,PA_FP_FCST_GEN_TMP1_N1)*/
                   SUM(NVL(quantity,0)),
                   SUM(NVL(txn_raw_cost,0)),
                   SUM(NVL(txn_brdn_cost,0)),
                   SUM(NVL(prj_raw_cost,0)),
                   SUM(NVL(prj_brdn_cost,0))
                   INTO
                   l_act_qty,
                   l_act_txn_raw_cost,
                   l_act_txn_brdn_cost,
                   l_act_pc_raw_cost,
                   l_act_pc_brdn_cost
              FROM PA_FP_FCST_GEN_TMP1
              WHERE project_element_id = P_TASK_ID
                AND res_list_member_id = P_RESOURCE_LIST_MEMBER_ID
                AND data_type_code = P_ETC_SOURCE_CODE;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_act_qty := 0;
                l_act_txn_raw_cost := 0;
                l_act_txn_brdn_cost := 0;
                l_act_pc_raw_cost := 0;
                l_act_pc_brdn_cost := 0;
            END;
        ELSE
            l_act_exist_flag := 'Y';
            l_act_txn_pc_flag := 'PC';
            BEGIN
              SELECT /*+ INDEX(PA_FP_FCST_GEN_TMP1,PA_FP_FCST_GEN_TMP1_N1)*/
                   SUM(NVL(quantity,0)),
                   SUM(NVL(prj_raw_cost,0)),
                   SUM(NVL(prj_brdn_cost,0))
                   INTO
                   l_act_qty,
                   l_act_pc_raw_cost,
                   l_act_pc_brdn_cost
              FROM PA_FP_FCST_GEN_TMP1
              WHERE project_element_id = P_TASK_ID
                AND res_list_member_id = P_RESOURCE_LIST_MEMBER_ID
                AND data_type_code = P_ETC_SOURCE_CODE;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_act_qty := 0;
                l_act_pc_raw_cost := 0;
                l_act_pc_brdn_cost := 0;
           END;
        END IF;
    ELSIF P_ETC_SOURCE_CODE = 'WORKPLAN_RESOURCES' THEN
        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Before calling PA_PROGRESS_UTILS.'||
                                 'get_actuals_for_task in earned_value',
                p_module_name => l_module_name,
                p_log_level   => 5);
        END IF;
        PA_PROGRESS_UTILS.get_actuals_for_task(
                p_project_id            => P_FP_COLS_REC.X_PROJECT_ID,
                p_wp_task_id            => P_TASK_ID,
                p_res_list_mem_id       => P_RESOURCE_LIST_MEMBER_ID,
                p_as_of_date            => P_ACTUALS_THRU_DATE,
                x_planned_work_qty      => l_tot_work_qty,
                x_actual_work_qty       => l_act_work_qty,
                x_ppl_act_cost_pc       => l_ppl_act_cost_pc,
                x_eqpmt_act_cost_pc     => l_eqpmt_act_cost_pc,
                x_oth_act_cost_pc       => l_oth_act_cost_pc,
                x_ppl_act_cost_fc       => l_ppl_act_cst_fc,
                x_eqpmt_act_cost_fc     => l_eqpmt_act_cost_fc,
                x_oth_act_cost_fc       => l_oth_act_cost_fc,
                x_act_labor_effort      => l_act_labor_effort,
                x_act_eqpmt_effort      => l_act_eqpmt_effort,
                x_unit_of_measure       => l_uom,
                x_txn_currency_code     => l_txn_currency_code,
                x_ppl_act_cost_tc       => l_ppl_act_cost_tc,
                x_eqpmt_act_cost_tc     => l_eqpmt_act_cost_tc,
                x_oth_act_cost_tc       => l_oth_act_cost_tc,
                X_PPL_ACT_RAWCOST_PC    => l_ppl_act_rawcost_pc,
                X_EQPMT_ACT_RAWCOST_PC  => l_eqpmt_act_rawcost_pc,
                X_OTH_ACT_RAWCOST_PC    => l_oth_act_rawcost_pc,
                X_PPL_ACT_RAWCOST_FC    => l_ppl_act_rawcst_fc,
                X_EQPMT_ACT_RAWCOST_FC  => l_eqpmt_act_rawcost_fc,
                X_OTH_ACT_RAWCOST_FC    => l_oth_act_rawcost_fc,
                X_PPL_ACT_RAWCOST_TC    => l_ppl_act_rawcost_tc,
                X_EQPMT_ACT_RAWCOST_TC  => l_eqpmt_act_rawcost_tc,
                X_OTH_ACT_RAWCOST_TC    => l_oth_act_rawcost_tc,
                X_OTH_QUANTITY          => l_oth_quantity,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data );
        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'After calling PA_PROGRESS_UTILS.'||
                     'get_actuals_for_task in earned_value'||x_return_status,
                p_module_name => l_module_name,
                p_log_level   => 5);
        END IF;
        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
        IF NVL(l_act_labor_effort,0) + NVL(l_act_eqpmt_effort,0)
           + NVL(l_oth_quantity,0) = 0 THEN
            l_act_exist_flag := 'N';
        ELSE
            l_act_exist_flag := 'Y';
        END IF;

        IF p_fp_cols_rec.x_plan_in_multi_curr_flag = 'Y' THEN
            l_act_txn_pc_flag := 'TC';
        ELSIF p_fp_cols_rec.x_plan_in_multi_curr_flag = 'N' THEN
            l_act_txn_pc_flag := 'PC';
        END IF;

        l_act_qty := NVL(l_act_labor_effort,0) + NVL(l_act_eqpmt_effort,0)
                     + NVL(l_oth_quantity,0);
        l_act_txn_brdn_cost := nvl(l_ppl_act_cost_tc,0) +
                               nvl(l_eqpmt_act_cost_tc,0) +
                               nvl(l_oth_act_cost_tc,0);
        l_act_txn_raw_cost :=  nvl(l_ppl_act_rawcost_tc,0) +
                               nvl(l_eqpmt_act_rawcost_tc,0) +
                               nvl(l_oth_act_rawcost_tc,0);

        l_act_pc_brdn_cost := nvl(l_ppl_act_cost_pc,0) +
                               nvl(l_eqpmt_act_cost_pc,0) +
                               nvl(l_oth_act_cost_pc,0);
        l_act_pc_raw_cost :=  nvl(l_ppl_act_rawcost_pc,0) +
                               nvl(l_eqpmt_act_rawcost_pc,0) +
                               nvl(l_oth_act_rawcost_pc,0);
        l_txn_currency_code_act := l_txn_currency_code;
    END IF;

    /*Getting TOTAL in both TXN and PROJ currencies*/
    SELECT /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
           COUNT(DISTINCT TXN_CURRENCY_CODE)
           INTO l_txn_currency_count_tot
    FROM PA_FP_CALC_AMT_TMP2
    WHERE RESOURCE_ASSIGNMENT_ID = P_RESOURCE_ASSIGNMENT_ID
          AND ETC_CURRENCY_CODE IS NULL;

    IF l_txn_currency_count_tot = 1
       AND p_fp_cols_rec.x_plan_in_multi_curr_flag = 'Y' THEN
        l_tot_txn_pc_flag := 'TC';
        SELECT /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
               DISTINCT TXN_CURRENCY_CODE
               INTO l_txn_currency_code_tot
        FROM PA_FP_CALC_AMT_TMP2
        WHERE RESOURCE_ASSIGNMENT_ID = P_RESOURCE_ASSIGNMENT_ID
              AND ETC_CURRENCY_CODE IS NULL;

        BEGIN
            SELECT /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
                   SUM(NVL(TOTAL_PLAN_QUANTITY, 0)),
                   SUM(NVL(TOTAL_TXN_RAW_COST,0)),
                   SUM(NVL(TOTAL_TXN_BURDENED_COST,0)),
                   SUM(NVL(TOTAL_PC_RAW_COST, 0)),
                   SUM(NVL(TOTAL_PC_BURDENED_COST,0))
                   INTO l_tot_qty,
                        l_tot_txn_raw_cost,
                        l_tot_txn_brdn_cost,
                        l_tot_pc_raw_cost,
                        l_tot_pc_brdn_cost
            FROM PA_FP_CALC_AMT_TMP2
            WHERE RESOURCE_ASSIGNMENT_ID = P_RESOURCE_ASSIGNMENT_ID
              AND ETC_CURRENCY_CODE IS  NULL;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_tot_qty := 0;
                l_tot_txn_raw_cost := 0;
                l_tot_txn_brdn_cost := 0;
                l_tot_pc_raw_cost := 0;
                l_tot_pc_brdn_cost := 0;
        END;
    ELSE
        l_tot_txn_pc_flag := 'PC';
        BEGIN
            SELECT /*+ INDEX(PA_FP_CALC_AMT_TMP2,PA_FP_CALC_AMT_TMP2_N2)*/
                   SUM(NVL(TOTAL_PLAN_QUANTITY, 0)),
                   SUM(NVL(TOTAL_PC_RAW_COST,0)),
                   SUM(NVL(TOTAL_PC_BURDENED_COST,0))
                   INTO l_tot_qty,
                        l_tot_pc_raw_cost,
                        l_tot_pc_brdn_cost
            FROM PA_FP_CALC_AMT_TMP2
            WHERE RESOURCE_ASSIGNMENT_ID = P_RESOURCE_ASSIGNMENT_ID
              AND ETC_CURRENCY_CODE IS  NULL;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_tot_qty := 0;
                l_tot_pc_raw_cost := 0;
                l_tot_pc_brdn_cost := 0;
        END;
    END IF;

    /* Getting ETC amounts
       1.ACWP = 0: ETC = TOTAL
       2.Percent = 0: ETC = TOTAL-ACWP
       3.OTHERS: ETC = ACWP * (1-percent)/percent*/
    l_etc_currency_code :=  P_FP_COLS_REC.x_project_currency_code;
    IF l_act_exist_flag = 'N' THEN
        l_etc_qty := l_tot_qty;
        IF l_tot_txn_pc_flag = 'PC' THEN
            l_etc_raw_cost := l_tot_pc_raw_cost;
            l_etc_brdn_cost := l_tot_pc_brdn_cost;
        ELSE
            l_etc_raw_cost := l_tot_txn_raw_cost;
            l_etc_brdn_cost := l_tot_txn_brdn_cost;
            l_etc_currency_code := l_txn_currency_code_tot;
        END IF;
    ELSIF l_percent_complete = 0 THEN
        l_etc_qty := NVL(l_tot_qty,0) - NVL(l_act_qty,0);
        IF l_tot_txn_pc_flag = 'TC' AND l_act_txn_pc_flag = 'TC' THEN
            l_etc_raw_cost := NVL(l_tot_txn_raw_cost,0) - NVL(l_act_txn_raw_cost,0);
            l_etc_brdn_cost := NVL(l_tot_txn_brdn_cost,0) - NVL(l_act_txn_brdn_cost,0);
            l_etc_currency_code := l_txn_currency_code_tot;
        ELSE
            l_etc_raw_cost := NVL(l_tot_pc_raw_cost,0) - NVL(l_act_pc_raw_cost,0);
            l_etc_brdn_cost := NVL(l_tot_pc_brdn_cost,0) - NVL(l_act_pc_brdn_cost,0);
        END IF;
    ELSE
        l_etc_qty := l_act_qty *((1-l_percent_complete)/l_percent_complete);
        IF l_act_txn_pc_flag = 'TC' THEN
            l_etc_raw_cost := l_act_txn_raw_cost *((1-l_percent_complete)/l_percent_complete);
            l_etc_brdn_cost := l_act_txn_brdn_cost *((1-l_percent_complete)/l_percent_complete);
            l_etc_currency_code := l_txn_currency_code_act;
        ELSE
            l_etc_raw_cost := l_act_pc_raw_cost *((1-l_percent_complete)/l_percent_complete);
            l_etc_brdn_cost := l_act_pc_brdn_cost *((1-l_percent_complete)/l_percent_complete);
        END IF;
    END IF;

    IF l_etc_qty <> 0 OR l_etc_raw_cost <> 0 OR l_etc_brdn_cost <> 0 THEN
        INSERT INTO PA_FP_CALC_AMT_TMP2
           (RESOURCE_ASSIGNMENT_ID,
            ETC_CURRENCY_CODE,
            ETC_PLAN_QUANTITY,
            ETC_TXN_RAW_COST,
            ETC_TXN_BURDENED_COST)
        VALUES
           (P_RESOURCE_ASSIGNMENT_ID,
            l_etc_currency_code,
            l_etc_qty,
            l_etc_raw_cost,
            l_etc_brdn_cost);
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
        -- dbms_output.put_line('error msg :'||x_msg_data);
        FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_GEN_FCST_AMT_PUB1',
                     p_procedure_name  => 'GEN_ETC_EARNED_VALUE_AMTS',
                     p_error_text      => substr(sqlerrm,1,240));

        IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                p_module_name => l_module_name,
                p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END GET_ETC_EARNED_VALUE_AMTS;

PROCEDURE GET_ETC_WORK_QTY_AMTS
        (P_PROJECT_ID                IN          PA_PROJECTS_ALL.PROJECT_ID%TYPE,
         P_PROJ_CURRENCY_CODE        IN          VARCHAR2,
         P_BUDGET_VERSION_ID         IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
         P_TASK_ID                   IN          NUMBER,
         P_TARGET_RES_LIST_ID        IN          NUMBER,
         P_ACTUALS_THRU_DATE         IN          PA_PERIODS_ALL.END_DATE%TYPE,
         P_FP_COLS_REC               IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
         P_WP_STRUCTURE_VERSION_ID   IN          PA_PROJ_ELEM_VER_STRUCTURE.ELEMENT_VERSION_ID%TYPE,
         X_RETURN_STATUS             OUT  NOCOPY VARCHAR2,
         X_MSG_COUNT                 OUT  NOCOPY NUMBER,
         X_MSG_DATA                  OUT  NOCOPY VARCHAR2)
IS
  l_module_name  VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_FCST_AMT_PUB1.GEN_ETC_WORK_QTY_AMT';

  l_stru_sharing_code           pa_projects_all.STRUCTURE_SHARING_CODE%TYPE;

  l_act_work_qty                NUMBER  :=0;
  l_act_raw_cost_pc             NUMBER  :=0;
  l_act_brdn_cost_pc            NUMBER  :=0;

  l_act_work_qty_ind            NUMBER  :=0;
  l_act_raw_cost_pc_ind         NUMBER  :=0;
  l_act_brdn_cost_pc_ind        NUMBER  :=0;

  l_etc_work_qty                NUMBER  :=0;
  l_etc_raw_cost_pc             NUMBER  :=0;
  l_etc_brdn_cost_pc            NUMBER  :=0;

  l_etc_work_qty_ind            NUMBER  :=0;
  l_etc_raw_cost_pc_ind         NUMBER  :=0;
  l_etc_brdn_cost_pc_ind        NUMBER  :=0;

  l_tot_work_qty                NUMBER  :=0;

  l_tot_work_qty_ind            NUMBER;

  l_ppl_act_cost_pc             NUMBER;
  l_eqpmt_act_cost_pc           NUMBER;
  l_oth_act_cost_pc             NUMBER;
  l_ppl_act_cst_fc              NUMBER;
  l_eqpmt_act_cost_fc           NUMBER;
  l_oth_act_cost_fc             NUMBER;
  l_txn_currency_code           VARCHAR2(30);
  l_ppl_act_cost_tc             NUMBER;
  l_eqpmt_act_cost_tc           NUMBER;
  l_oth_act_cost_tc             NUMBER;
  l_act_labor_effort            NUMBER;
  l_act_eqpmt_effort            NUMBER;
  l_uom                         VARCHAR2(30);

  l_ppl_act_cost_pc_ind         NUMBER;
  l_eqpmt_act_cost_pc_ind       NUMBER;
  l_oth_act_cost_pc_ind         NUMBER;
  l_ppl_act_cst_fc_ind          NUMBER;
  l_eqpmt_act_cost_fc_ind       NUMBER;
  l_oth_act_cost_fc_ind         NUMBER;
  l_txn_currency_code_ind       VARCHAR2(30);
  l_ppl_act_cost_tc_ind         NUMBER;
  l_eqpmt_act_cost_tc_ind       NUMBER;
  l_oth_act_cost_tc_ind         NUMBER;
  l_act_labor_effort_ind        NUMBER;
  l_act_eqpmt_effort_ind        NUMBER;
  l_uom_ind                     VARCHAR2(30);
--
  l_ppl_act_rawcost_pc          NUMBER;
  l_eqpmt_act_rawcost_pc        NUMBER;
  l_oth_act_rawcost_pc          NUMBER;
  l_ppl_act_rawcst_fc           NUMBER;
  l_eqpmt_act_rawcost_fc        NUMBER;
  l_oth_act_rawcost_fc          NUMBER;
  l_ppl_act_rawcost_tc          NUMBER;
  l_eqpmt_act_rawcost_tc        NUMBER;
  l_oth_act_rawcost_tc          NUMBER;

  l_oth_quantity                NUMBER;

  l_ppl_act_rawcost_pc_ind      NUMBER;
  l_eqpmt_act_rawcost_pc_ind    NUMBER;
  l_oth_act_rawcost_pc_ind      NUMBER;
  l_ppl_act_rawcst_fc_ind       NUMBER;
  l_eqpmt_act_rawcost_fc_ind    NUMBER;
  l_oth_act_rawcost_fc_ind      NUMBER;
  l_ppl_act_rawcost_tc_ind      NUMBER;
  l_eqpmt_act_rawcost_tc_ind    NUMBER;
  l_oth_act_rawcost_tc_ind      NUMBER;

  l_oth_quantity_ind            NUMBER;
--
  l_wp_task_tab                 PA_PLSQL_DATATYPES.IdTabTyp;

  l_start_date                  DATE;
  l_completion_date             DATE;

  l_ppl_class_rlm_id            NUMBER;

  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_data                        VARCHAR2(2000);
  l_msg_index_out               NUMBER:=0;
  l_sysdate                     DATE;
  l_transaction_source_code     PA_FP_CALC_AMT_TMP2.transaction_source_code%TYPE;
BEGIN
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_COUNT := 0;
    l_sysdate := trunc(sysdate);
    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function     => 'GEN_ETC_WORK_QTY_AMTS',
                                    p_debug_mode   =>  p_pa_debug_mode);
    END IF;

    l_stru_sharing_code :=
        PA_PROJECT_STRUCTURE_UTILS.get_Structure_sharing_code(P_PROJECT_ID=> P_PROJECT_ID);
    IF l_stru_sharing_code = 'SHARE_FULL' THEN
        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Before calling PA_PROGRESS_UTILS.'||
                                 'get_actuals_for_task when SHARE_FULL',
                p_module_name => l_module_name,
                p_log_level   => 5);
        END IF;
        PA_PROGRESS_UTILS.get_actuals_for_task(
                p_project_id            => P_PROJECT_ID,
                p_wp_task_id            => P_TASK_ID,
                p_res_list_mem_id       => NULL,
                p_as_of_date            => P_ACTUALS_THRU_DATE,
                x_planned_work_qty      => l_tot_work_qty,
                x_actual_work_qty       => l_act_work_qty,
                x_ppl_act_cost_pc       => l_ppl_act_cost_pc,
                x_eqpmt_act_cost_pc     => l_eqpmt_act_cost_pc,
                x_oth_act_cost_pc       => l_oth_act_cost_pc,
                x_ppl_act_cost_fc       => l_ppl_act_cst_fc,
                x_eqpmt_act_cost_fc     => l_eqpmt_act_cost_fc,
                x_oth_act_cost_fc       => l_oth_act_cost_fc,
                x_act_labor_effort      => l_act_labor_effort,
                x_act_eqpmt_effort      => l_act_eqpmt_effort,
                x_unit_of_measure       => l_uom,
                x_txn_currency_code     => l_txn_currency_code,
                x_ppl_act_cost_tc       => l_ppl_act_cost_tc,
                x_eqpmt_act_cost_tc     => l_eqpmt_act_cost_tc,
                x_oth_act_cost_tc       => l_oth_act_cost_tc,
                X_PPL_ACT_RAWCOST_PC    => l_ppl_act_rawcost_pc,
                X_EQPMT_ACT_RAWCOST_PC  => l_eqpmt_act_rawcost_pc,
                X_OTH_ACT_RAWCOST_PC    => l_oth_act_rawcost_pc,
                X_PPL_ACT_RAWCOST_FC    => l_ppl_act_rawcst_fc,
                X_EQPMT_ACT_RAWCOST_FC  => l_eqpmt_act_rawcost_fc,
                X_OTH_ACT_RAWCOST_FC    => l_oth_act_rawcost_fc,
                X_PPL_ACT_RAWCOST_TC    => l_ppl_act_rawcost_tc,
                X_EQPMT_ACT_RAWCOST_TC  => l_eqpmt_act_rawcost_tc,
                X_OTH_ACT_RAWCOST_TC    => l_oth_act_rawcost_tc,
                X_OTH_QUANTITY          => l_oth_quantity,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data );
        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'After calling PA_PROGRESS_UTILS.'||
                     'get_actuals_for_task when SHARE_FULL'||x_return_status,
                p_module_name => l_module_name,
                p_log_level   => 5);
        END IF;
        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

        IF NVL(l_act_work_qty,0) <> 0 THEN
            l_etc_work_qty := NVL(l_tot_work_qty,0) - NVL(l_act_work_qty,0);
            l_act_brdn_cost_pc := nvl(l_ppl_act_cost_pc,0) +
                                  nvl(l_eqpmt_act_cost_pc,0) +
                                  nvl(l_oth_act_cost_pc,0);
            l_etc_brdn_cost_pc := l_etc_work_qty * (l_act_brdn_cost_pc/l_act_work_qty);
            l_act_raw_cost_pc := nvl(l_ppl_act_rawcost_pc,0) +
                                  nvl(l_eqpmt_act_rawcost_pc,0) +
                                  nvl(l_oth_act_rawcost_pc,0);
            l_etc_raw_cost_pc := l_etc_work_qty * (l_act_raw_cost_pc/l_act_work_qty);
        END IF;
    ELSIF l_stru_sharing_code = 'SHARE_PARTIAL' OR
          l_stru_sharing_code = 'SPLIT_MAPPING' THEN
        SELECT PROJ_ELEMENT_ID
               BULK COLLECT INTO l_wp_task_tab
        FROM PA_MAP_WP_TO_FIN_TASKS_V
        WHERE PARENT_STRUCTURE_VERSION_ID = P_WP_STRUCTURE_VERSION_ID
              AND MAPPED_FIN_TASK_ID = P_TASK_ID;

        FOR i IN 1..l_wp_task_tab.count LOOP
            IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                   (p_msg         => 'Before calling PA_PROGRESS_UTILS.'||
                                  'get_actuals_for_task when MAPPING',
                    p_module_name => l_module_name,
                    p_log_level   => 5);
            END IF;
            PA_PROGRESS_UTILS.get_actuals_for_task(
                p_project_id            => P_PROJECT_ID,
                p_wp_task_id            => l_wp_task_tab(i),
                p_res_list_mem_id       => NULL,
                p_as_of_date            => P_ACTUALS_THRU_DATE,
                x_planned_work_qty      => l_tot_work_qty_ind,
                x_actual_work_qty       => l_act_work_qty_ind,
                x_ppl_act_cost_pc       => l_ppl_act_cost_pc_ind,
                x_eqpmt_act_cost_pc     => l_eqpmt_act_cost_pc_ind,
                x_oth_act_cost_pc       => l_oth_act_cost_pc_ind,
                x_ppl_act_cost_fc       => l_ppl_act_cst_fc_ind,
                x_eqpmt_act_cost_fc     => l_eqpmt_act_cost_fc_ind,
                x_oth_act_cost_fc       => l_oth_act_cost_fc_ind,
                x_act_labor_effort      => l_act_labor_effort_ind,
                x_act_eqpmt_effort      => l_act_eqpmt_effort_ind,
                x_unit_of_measure       => l_uom_ind,
                x_txn_currency_code     => l_txn_currency_code_ind,
                x_ppl_act_cost_tc       => l_ppl_act_cost_tc_ind,
                x_eqpmt_act_cost_tc     => l_eqpmt_act_cost_tc_ind,
                x_oth_act_cost_tc       => l_oth_act_cost_tc_ind,
                X_PPL_ACT_RAWCOST_PC    => l_ppl_act_rawcost_pc_ind,
                X_EQPMT_ACT_RAWCOST_PC  => l_eqpmt_act_rawcost_pc_ind,
                X_OTH_ACT_RAWCOST_PC    => l_oth_act_rawcost_pc_ind,
                X_PPL_ACT_RAWCOST_FC    => l_ppl_act_rawcst_fc_ind,
                X_EQPMT_ACT_RAWCOST_FC  => l_eqpmt_act_rawcost_fc_ind,
                X_OTH_ACT_RAWCOST_FC    => l_oth_act_rawcost_fc_ind,
                X_PPL_ACT_RAWCOST_TC    => l_ppl_act_rawcost_tc_ind,
                X_EQPMT_ACT_RAWCOST_TC  => l_eqpmt_act_rawcost_tc_ind,
                X_OTH_ACT_RAWCOST_TC    => l_oth_act_rawcost_tc_ind,
                X_OTH_QUANTITY          => l_oth_quantity_ind,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data );
            IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                   (p_msg         => 'After calling PA_PROGRESS_UTILS.'||
                     'get_actuals_for_task when MAPPING'||x_return_status,
                    p_module_name => l_module_name,
                    p_log_level   => 5);
            END IF;
            IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
            IF NVL(l_act_work_qty_ind,0) <> 0 THEN
                -- ER 5726773: Sum work qty for WP tasks mapping to target task
 	        l_tot_work_qty := l_tot_work_qty + l_tot_work_qty_ind;
		l_etc_work_qty_ind := NVL(l_tot_work_qty_ind,0) - NVL(l_act_work_qty_ind,0);
                l_act_brdn_cost_pc_ind := nvl(l_ppl_act_cost_pc_ind,0) +
                                          nvl(l_eqpmt_act_cost_pc_ind,0) +
                                          nvl(l_oth_act_cost_pc_ind,0);
                l_etc_brdn_cost_pc_ind := l_etc_work_qty_ind * (l_act_brdn_cost_pc_ind/l_act_work_qty_ind);
                l_etc_brdn_cost_pc := l_etc_brdn_cost_pc + l_etc_brdn_cost_pc_ind;

                l_act_raw_cost_pc_ind := nvl(l_ppl_act_rawcost_pc_ind,0) +
                                          nvl(l_eqpmt_act_rawcost_pc_ind,0) +
                                          nvl(l_oth_act_rawcost_pc_ind,0);
                l_etc_raw_cost_pc_ind := l_etc_work_qty_ind * (l_act_raw_cost_pc_ind/l_act_work_qty_ind);
                l_etc_raw_cost_pc := l_etc_raw_cost_pc + l_etc_raw_cost_pc_ind;
            END IF;
        END LOOP;
    ELSE -- l_stru_sharing_code ='SPLIT_NO_MAPPING'
        SELECT proj_element_id
               BULK COLLECT INTO l_wp_task_tab
        FROM pa_proj_element_versions
        WHERE PARENT_STRUCTURE_VERSION_ID = P_WP_STRUCTURE_VERSION_ID
              AND OBJECT_TYPE = 'PA_TASKS';

        FOR i IN 1..l_wp_task_tab.count LOOP
            IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                   (p_msg         => 'Before calling PA_PROGRESS_UTILS.'||
                                    'get_actuals_for_task when NO_MAPPINGL',
                    p_module_name => l_module_name,
                    p_log_level   => 5);
            END IF;
            PA_PROGRESS_UTILS.get_actuals_for_task(
                p_project_id            => P_PROJECT_ID,
                p_wp_task_id            => l_wp_task_tab(i),
                p_res_list_mem_id       => NULL,
                p_as_of_date            => P_ACTUALS_THRU_DATE,
                x_planned_work_qty      => l_tot_work_qty_ind,
                x_actual_work_qty       => l_act_work_qty_ind,
                x_ppl_act_cost_pc       => l_ppl_act_cost_pc_ind,
                x_eqpmt_act_cost_pc     => l_eqpmt_act_cost_pc_ind,
                x_oth_act_cost_pc       => l_oth_act_cost_pc_ind,
                x_ppl_act_cost_fc       => l_ppl_act_cst_fc_ind,
                x_eqpmt_act_cost_fc     => l_eqpmt_act_cost_fc_ind,
                x_oth_act_cost_fc       => l_oth_act_cost_fc_ind,
                x_act_labor_effort      => l_act_labor_effort_ind,
                x_act_eqpmt_effort      => l_act_eqpmt_effort_ind,
                x_unit_of_measure       => l_uom_ind,
                x_txn_currency_code     => l_txn_currency_code_ind,
                x_ppl_act_cost_tc       => l_ppl_act_cost_tc_ind,
                x_eqpmt_act_cost_tc     => l_eqpmt_act_cost_tc_ind,
                x_oth_act_cost_tc       => l_oth_act_cost_tc_ind,
                X_PPL_ACT_RAWCOST_PC    => l_ppl_act_rawcost_pc_ind,
                X_EQPMT_ACT_RAWCOST_PC  => l_eqpmt_act_rawcost_pc_ind,
                X_OTH_ACT_RAWCOST_PC    => l_oth_act_rawcost_pc_ind,
                X_PPL_ACT_RAWCOST_FC    => l_ppl_act_rawcst_fc_ind,
                X_EQPMT_ACT_RAWCOST_FC  => l_eqpmt_act_rawcost_fc_ind,
                X_OTH_ACT_RAWCOST_FC    => l_oth_act_rawcost_fc_ind,
                X_PPL_ACT_RAWCOST_TC    => l_ppl_act_rawcost_tc_ind,
                X_EQPMT_ACT_RAWCOST_TC  => l_eqpmt_act_rawcost_tc_ind,
                X_OTH_ACT_RAWCOST_TC    => l_oth_act_rawcost_tc_ind,
                X_OTH_QUANTITY          => l_oth_quantity_ind,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data );
            IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                   (p_msg         => 'After calling PA_PROGRESS_UTILS.'||
                     'get_actuals_for_task when NO_MAPPING'||x_return_status,
                    p_module_name => l_module_name,
                    p_log_level   => 5);
            END IF;
            IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
            IF NVL(l_act_work_qty_ind,0) <> 0 THEN
                -- ER 5726773: Sum work qty for WP tasks mapping to target task
 	        l_tot_work_qty := l_tot_work_qty + l_tot_work_qty_ind;
		l_etc_work_qty_ind := NVL(l_tot_work_qty_ind,0) - NVL(l_act_work_qty_ind,0);
                l_act_brdn_cost_pc_ind := nvl(l_ppl_act_cost_pc_ind,0) +
                                          nvl(l_eqpmt_act_cost_pc_ind,0) +
                                          nvl(l_oth_act_cost_pc_ind,0);
                l_etc_brdn_cost_pc_ind := l_etc_work_qty_ind * (l_act_brdn_cost_pc_ind/l_act_work_qty_ind);
                l_etc_brdn_cost_pc := l_etc_brdn_cost_pc + l_etc_brdn_cost_pc_ind;

                l_act_raw_cost_pc_ind := nvl(l_ppl_act_rawcost_pc_ind,0) +
                                          nvl(l_eqpmt_act_rawcost_pc_ind,0) +
                                          nvl(l_oth_act_rawcost_pc_ind,0);
                l_etc_raw_cost_pc_ind := l_etc_work_qty_ind * (l_act_raw_cost_pc_ind/l_act_work_qty_ind);
                l_etc_raw_cost_pc := l_etc_raw_cost_pc + l_etc_raw_cost_pc_ind;
            END IF;
        END LOOP;
    END IF;
    /*not used in work_qty
    INSERT INTO PA_FP_CALC_AMT_TMP2 (
                RESOURCE_ASSIGNMENT_ID,
                TXN_CURRENCY_CODE,
                TOTAL_PLAN_QUANTITY,
                TOTAL_TXN_RAW_COST,
                TOTAL_TXN_BURDENED_COST)
    VALUES (    (-1) * P_TASK_ID,
                P_PROJ_CURRENCY_CODE,
                l_tot_work_qty,
                l_tot_raw_cost_pc,
                l_tot_brdn_cost_pc);*/
    -- ER 5726773: Instead of directly checking if (ETC > 0), let the
    -- plan_etc_signs_match function decide if ETC should be generated.

      IF pa_fp_fcst_gen_amt_utils.
         PLAN_ETC_SIGNS_MATCH(l_tot_work_qty,l_etc_work_qty) THEN
        IF P_FP_COLS_REC.X_GEN_INCL_OPEN_COMM_FLAG = 'Y' THEN
            l_transaction_source_code := 'TOTAL_ETC';
        ELSE
            l_transaction_source_code := 'ETC';
        END IF;
        INSERT INTO PA_FP_CALC_AMT_TMP2 (
                RESOURCE_ASSIGNMENT_ID,
                ETC_CURRENCY_CODE,
                ETC_PLAN_QUANTITY,
                ETC_TXN_RAW_COST,
                ETC_TXN_BURDENED_COST,
                TRANSACTION_SOURCE_CODE,
		ACTUAL_WORK_QTY)
        VALUES ((-1) * P_TASK_ID,
                P_PROJ_CURRENCY_CODE,
                l_etc_raw_cost_pc,
                l_etc_raw_cost_pc,
                l_etc_brdn_cost_pc,
                l_transaction_source_code,
		l_act_work_qty_ind);
    END IF;

    IF p_task_id IS NOT NULL THEN
       SELECT nvl(start_date,l_sysdate),
              nvl(completion_date,l_sysdate)
           INTO l_start_date, l_completion_date
       FROM pa_tasks
       WHERE task_id = P_TASK_ID;
    ELSE
       SELECT nvl(start_date,l_sysdate),
              nvl(completion_date,l_sysdate)
           INTO l_start_date, l_completion_date
       FROM pa_projects_all
       WHERE project_id = p_project_id;

    END IF;
    /**For work quantity, we needn't do mapping, because we get the corresponding res
      *list id (PEOPLE) for the specific rml_id**/
    l_ppl_class_rlm_id := PA_FP_GEN_AMOUNT_UTILS.GET_RLM_ID
        (P_PROJECT_ID => P_PROJECT_ID,
         P_RESOURCE_LIST_ID => P_TARGET_RES_LIST_ID,
         P_RESOURCE_CLASS_CODE => 'FINANCIAL_ELEMENTS');
    /*
    SELECT resource_list_member_id INTO l_ppl_class_rlm_id
    FROM pa_resource_list_members
    WHERE resource_list_id = P_TARGET_RES_LIST_ID
          AND resource_class_flag = 'Y'
          AND resource_class_code = 'PEOPLE';
    */
    INSERT INTO PA_FP_CALC_AMT_TMP1 (
                RESOURCE_ASSIGNMENT_ID,
                BUDGET_VERSION_ID,
                PROJECT_ID,
                TASK_ID,
                TARGET_RLM_ID,
                PLANNING_START_DATE,
                PLANNING_END_DATE,
                TRANSACTION_SOURCE_CODE,
                MAPPED_FIN_TASK_ID )
    VALUES (
                (-1) * P_TASK_ID,
                P_BUDGET_VERSION_ID,
                P_PROJECT_ID,
                P_TASK_ID,
                l_ppl_class_rlm_id,
                l_start_date,
                l_completion_date,
                'WORK_QUANTITY',
                P_TASK_ID );

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
        -- dbms_output.put_line('error msg :'||x_msg_data);
        FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_GEN_FCST_AMT_PUB1',
                     p_procedure_name  => 'GEN_ETC_WORK_QTY_AMTS',
                     p_error_text      => substr(sqlerrm,1,240));

        IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                p_module_name => l_module_name,
                p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END GET_ETC_WORK_QTY_AMTS;

PROCEDURE NONE_ETC_SRC
       (P_PROJECT_ID              IN    PA_PROJECTS_ALL.PROJECT_ID%TYPE,
        P_BUDGET_VERSION_ID       IN    PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
        P_RESOURCE_LIST_ID        IN    NUMBER,
        P_TASK_ID                 IN    NUMBER,
        X_RETURN_STATUS           OUT   NOCOPY VARCHAR2,
        X_MSG_COUNT               OUT   NOCOPY NUMBER,
        X_MSG_DATA                OUT   NOCOPY VARCHAR2)
IS
  l_module_name  VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_FCST_AMT_PUB1.NONE_ETC_SRC';
  l_task_start_date             DATE;
  l_task_completion_date        DATE;
  l_target_class_rlm_id         NUMBER;

  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_data                        VARCHAR2(2000);
  l_msg_index_out               NUMBER:=0;
  l_sysdate                     date;
BEGIN
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_COUNT := 0;
    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function     => 'NONE_ETC_SRC',
                                    p_debug_mode   =>  p_pa_debug_mode);
    END IF;

    l_sysdate := trunc(SYSDATE);

    IF nvl(p_task_id,0) > 0 THEN
       SELECT nvl(start_date,l_sysdate),
       nvl(completion_date,l_sysdate)
       INTO l_task_start_date, l_task_completion_date
       FROM pa_tasks
       WHERE task_id = P_TASK_ID;
    ELSE
       SELECT  nvl(start_date,l_sysdate),
       nvl(completion_date,l_sysdate)
       INTO l_task_start_date, l_task_completion_date
       FROM pa_projects_all WHERE
       project_id = p_project_id;
    END IF;
    /* for etc source as NULL or NONE the planning resource will be
       created based on the task + people resourece class combination.
       This is to generate the ETC amounts by calling the forecast
       generation client extension API.  - msoundra */

    l_target_class_rlm_id := PA_FP_GEN_AMOUNT_UTILS.GET_RLM_ID
        (P_PROJECT_ID => P_PROJECT_ID,
         P_RESOURCE_LIST_ID => P_RESOURCE_LIST_ID,
         P_RESOURCE_CLASS_CODE => 'FINANCIAL_ELEMENTS');

    -- hr_utility.trace('inside none etc  class rlm id:'||l_target_class_rlm_id);
    /* bug 3741059 target_rlm_id col should be populated instead of
       resource_list_member_id col in the following insert for the value
       l_target_class_rlm_id value. */
    INSERT INTO PA_FP_CALC_AMT_TMP1 (
        RESOURCE_ASSIGNMENT_ID,
        BUDGET_VERSION_ID,
        PROJECT_ID,
        TASK_ID,
        target_rlm_id,
        PLANNING_START_DATE,
        PLANNING_END_DATE,
        MAPPED_FIN_TASK_ID )
    VALUES (
        (-1) * P_TASK_ID,
        P_BUDGET_VERSION_ID,
        P_PROJECT_ID,
        P_TASK_ID,
        l_target_class_rlm_id,
        l_task_start_date,
        l_task_completion_date,
        P_TASK_ID );

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
        FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_GEN_FCST_AMT_PUB1',
                     p_procedure_name  => 'NONE_ETC_SOURCE',
                     p_error_text      => substr(sqlerrm,1,240));

        IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                p_module_name => l_module_name,
                p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END NONE_ETC_SRC;

PROCEDURE MAINTAIN_BUDGET_VERSION
          (P_PROJECT_ID              IN          PA_PROJECTS_ALL.PROJECT_ID%TYPE,
           P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_ETC_START_DATE          IN          DATE,
	   P_CALL_MAINTAIN_DATA_API  IN          VARCHAR2,
           X_RETURN_STATUS           OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT               OUT  NOCOPY NUMBER,
           X_MSG_DATA                OUT  NOCOPY VARCHAR2 )
IS
  l_module_name  VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_FCST_AMT_PUB1. MAINTAIN_BUDGET_VERSION';
  l_fp_version_ids_tab           SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

  l_msg_count                  NUMBER;
  l_msg_data                   VARCHAR2(2000);
  l_data                       VARCHAR2(2000);
  l_msg_index_out              NUMBER:=0;

  -- Bug Fix: 4569365. Removed MRC code.
  -- g_mrc_exception EXCEPTION;

  l_fp_cols_rec                PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
  l_wp_version_flag            pa_budget_versions.wp_version_flag%TYPE;

  -- IPM: Added local variable to pass variable values of the
  --      p_calling_module parameter of the MAINTAIN_DATA API.
  l_calling_module             VARCHAR2(30);

BEGIN
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_COUNT := 0;
    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function     => 'MAINTAIN_BUDGET_VERSION',
                                    p_debug_mode   =>  p_pa_debug_mode);
    END IF;

    /* Calling  the get_plan_version_dtls api */
    IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                             pa_fp_gen_amount_utils.get_plan_version_dtls',
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;
    PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
             (P_PROJECT_ID         => P_PROJECT_ID,
              P_BUDGET_VERSION_ID  => P_BUDGET_VERSION_ID,
              X_FP_COLS_REC        => l_fp_cols_rec,
              X_RETURN_STATUS      => X_RETURN_STATUS,
              X_MSG_COUNT          => X_MSG_COUNT,
              X_MSG_DATA           => X_MSG_DATA);
    IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling
              pa_fp_gen_amount_utils.get_plan_version_dtls'
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    -- ER 5726773: Delete any budget lines that have 0 plan quantity.
 	     -- Such lines are possible as a result of:
 	     -- 1. Multiple periodic lines mapping to the same line
 	     -- 2. Commitments mapped to a line with negative quantity
 	     -- 3. Billing events mapped to a revenue-only line with negative
 	     --    (internal) quantity

 	     DELETE FROM pa_budget_lines bl
 	     WHERE  nvl(bl.quantity,0) = 0
 	     AND    nvl(bl.burdened_cost,0) = 0   --Bug 8314994 Preventing deletion of budget line.
 	     AND    bl.budget_version_id = p_budget_version_id
 	     AND    bl.init_quantity is null
 	     AND    bl.txn_init_raw_cost is null
 	     AND    bl.txn_init_burdened_cost is null
 	     AND    bl.txn_init_revenue is null;

    /**This is to address bug 4156875.
       For none time phased, after generating budget lines from the source,
       commitments, and billing events, all budget lines of different currencies for
       the same resource assignments should be updated to the same start and end
       dates, which honor the max and min of the individual budget lines. This
       should also be updated back to resource assignments. **/
    IF l_fp_cols_rec.x_time_phased_code = 'N' THEN
        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                (p_msg         => 'Before calling pa_fp_maintain_actual_pub.'||
                                'SYNC_UP_PLANNING_DATES_NONE_TP',
                 p_module_name => l_module_name,
                 p_log_level   => 5);
        END IF;
        PA_FP_MAINTAIN_ACTUAL_PUB.SYNC_UP_PLANNING_DATES_NONE_TP
            (P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
             P_FP_COLS_REC              => l_fp_cols_rec,
             X_RETURN_STATUS            => X_RETURN_STATUS,
             X_MSG_COUNT                => X_MSG_COUNT,
             X_MSG_DATA                 => X_MSG_DATA);
        IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Status after calling pa_fp_maintain_actual_pub.'||
                           'SYNC_UP_PLANNING_DATES_NONE_TP:'||x_return_status,
                p_module_name => l_module_name,
                p_log_level   => 5);
        END IF;
        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
    END IF;

    IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                             PA_FP_GEN_PUB.MAINTAIN_FIXED_DATE_SP',
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;
    PA_FP_GEN_PUB.MAINTAIN_FIXED_DATE_SP
            (P_BUDGET_VERSION_ID    => P_BUDGET_VERSION_ID,
             P_FP_COLS_REC           => l_fp_cols_rec,
             X_RETURN_STATUS         => x_return_status,
             X_MSG_COUNT             => x_msg_count,
             X_MSG_DATA              => x_msg_data);
    IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling
              PA_FP_GEN_PUB.MAINTAIN_FIXED_DATE_SP:'||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Before calling PA_FP_MULTI_CURRENCY_PKG.CONVERT_TXN_CURRENCY',
                p_module_name => l_module_name,
                p_log_level   => 5);
    END IF;
    PA_FP_MULTI_CURRENCY_PKG.CONVERT_TXN_CURRENCY
                (p_budget_version_id          => P_BUDGET_VERSION_ID,
                 p_entire_version             => 'Y',
                 p_calling_module              => 'BUDGET_GENERATION', -- Added for Bug#5395732
                 X_RETURN_STATUS              => X_RETURN_STATUS,
                 X_MSG_COUNT                  => X_MSG_COUNT,
                 X_MSG_DATA                   => X_MSG_DATA);
    IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'After calling PA_FP_MULTI_CURRENCY_PKG.CONVERT_TXN_CURRENCY,
                            ret status: '||x_return_status,
                p_module_name => l_module_name,
                p_log_level   => 5);
    END IF;
    --dbms_output.put_line('After calling convert_txn_currency api: '||x_return_status);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Before calling PA_FP_ROLLUP_PKG.ROLLUP_BUDGET_VERSION',
                p_module_name => l_module_name,
                p_log_level   => 5);
    END IF;
    PA_FP_ROLLUP_PKG.ROLLUP_BUDGET_VERSION
               (p_budget_version_id          => P_BUDGET_VERSION_ID,
                p_entire_version             =>  'Y',
                X_RETURN_STATUS              => X_RETURN_STATUS,
                X_MSG_COUNT                  => X_MSG_COUNT,
                X_MSG_DATA                   => X_MSG_DATA);
    IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'After calling PA_FP_ROLLUP_PKG.ROLLUP_BUDGET_VERSION,
                            ret status: '||x_return_status,
                p_module_name => l_module_name,
                p_log_level   => 5);
    END IF;
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    SELECT wp_version_flag
    INTO   l_wp_version_flag
    FROM   pa_budget_versions
    WHERE  budget_version_id=p_budget_version_id;

    IF l_wp_version_flag = 'Y' THEN
       IF l_fp_cols_rec.x_fin_plan_level_code <> 'P' THEN
         /* Calling  the UPD_WBS_ELEMENT_VERSION_ID api */
         IF p_pa_debug_mode = 'Y' THEN
              pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Before calling
                               PA_FP_GEN_PUB.UPD_WBS_ELEMENT_VERSION_ID',
                p_module_name => l_module_name,
                p_log_level   => 5);
         END IF;
         PA_FP_GEN_PUB.UPD_WBS_ELEMENT_VERSION_ID
            (P_BUDGET_VERSION_ID      => P_BUDGET_VERSION_ID,
             P_STRUCTURE_VERSION_ID   => l_fp_cols_rec.x_project_structure_version_id,
             X_RETURN_STATUS          => X_RETURN_STATUS,
             X_MSG_COUNT              => X_MSG_COUNT,
             X_MSG_DATA             => X_MSG_DATA);
         IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END IF;
         IF p_pa_debug_mode = 'Y' THEN
              pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Status after calling
                PA_FP_GEN_PUB.UPD_WBS_ELEMENT_VERSION_ID'
                               ||x_return_status,
                  p_module_name => l_module_name,
                  p_log_level   => 5);
         END IF;
        END IF;
      END IF;



    IF l_fp_cols_rec.x_plan_in_multi_curr_flag = 'Y' THEN
         /* Calling insert_txn_currency api */
         IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                               pa_fp_gen_budget_amt_pub.insert_txn_currency',
              p_module_name => l_module_name,
              p_log_level   => 5);
         END IF;
         PA_FP_GEN_BUDGET_AMT_PUB.INSERT_TXN_CURRENCY
          (P_PROJECT_ID          => P_PROJECT_ID,
           P_BUDGET_VERSION_ID   => P_BUDGET_VERSION_ID,
           P_FP_COLS_REC         => l_fp_cols_rec,
           X_RETURN_STATUS       => X_RETURN_STATUS,
           X_MSG_COUNT           => X_MSG_COUNT,
           X_MSG_DATA            => X_MSG_DATA);
         IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END IF;
         IF p_pa_debug_mode = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
                   (p_msg         => 'Status after calling
                              pa_fp_gen_budget_amt_pub.insert_txn_currency'
                              ||x_return_status,
                    p_module_name => l_module_name,
                    p_log_level   => 5);
         END IF;
     END IF;
    -- Bug Fix: 4569365. Removed MRC code.

	/*
    -- Bug 4187704: Uncommented the MRC code. Also, set added logic to set
    -- PA_MRC_FINPLAN.G_CALLING_MODULE based on Target Plan Class Code.
    IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS IS NULL THEN

        IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Before calling PA_MRC_FINPLAN.CHECK_MRC_INSTALL',
                p_module_name => l_module_name,
                p_log_level   => 5);
        END IF;
        PA_MRC_FINPLAN.CHECK_MRC_INSTALL
             (x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data);
        IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'After calling PA_MRC_FINPLAN.CHECK_MRC_INSTALL,
                            ret status: '||x_return_status,
                p_module_name => l_module_name,
                p_log_level   => 5);
        END IF;
        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
    END IF;

    IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS AND
        PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'A' THEN

        IF l_fp_cols_rec.x_plan_class_code = 'FORECAST' THEN
            PA_MRC_FINPLAN.G_CALLING_MODULE := PA_MRC_FINPLAN.G_GENERATE_FORECAST;
        ELSIF l_fp_cols_rec.x_plan_class_code = 'BUDGET' THEN
            PA_MRC_FINPLAN.G_CALLING_MODULE := PA_MRC_FINPLAN.G_GENERATE_BUDGET;
        END IF;

        IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Before calling PA_MRC_FINPLAN.MAINTAIN_ALL_MC_BUDGET_LINES',
                p_module_name => l_module_name,
                p_log_level   => 5);
        END IF;
        PA_MRC_FINPLAN.MAINTAIN_ALL_MC_BUDGET_LINES
                (p_fin_plan_version_id => p_budget_version_id,
                 p_entire_version      => 'Y',
                 x_return_status       => x_return_status,
                 x_msg_count           => x_msg_count,
                 x_msg_data            => x_msg_data);
        IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'After calling PA_MRC_FINPLAN.MAINTAIN_ALL_MC_BUDGET_LINES,
                            ret status: '||x_return_status,
                p_module_name => l_module_name,
                p_log_level   => 5);
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE g_mrc_exception;
        END IF;

         PA_MRC_FINPLAN.G_CALLING_MODULE := Null;
    END IF;
    */

    l_fp_version_ids_tab.extend;
    l_fp_version_ids_tab(1) := P_BUDGET_VERSION_ID;

    IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Before calling PJI_FM_XBS_ACCUM_MAINT.PLAN_DELETE',
                p_module_name => l_module_name,
                p_log_level   => 5);
    END IF;
    PJI_FM_XBS_ACCUM_MAINT.PLAN_DELETE (
        p_fp_version_ids        => l_fp_version_ids_tab,
        x_return_status         => x_return_status,
        x_msg_code              => x_msg_data );
    IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'After calling PJI_FM_XBS_ACCUM_MAINT.PLAN_DELETE,
                            ret status: '||x_return_status,
                p_module_name => l_module_name,
                p_log_level   => 5);
    END IF;
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF l_fp_cols_rec.X_RBS_VERSION_ID IS NOT NULL THEN

         IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug
                    (p_msg         =>  'Before calling
                                pa_fp_map_bv_pub.maintain_rbs_dtls',
                     p_module_name => l_module_name,
                     p_log_level   => 5);
         END IF;
         PA_FP_MAP_BV_PUB.MAINTAIN_RBS_DTLS
               (P_BUDGET_VERSION_ID  => p_budget_version_id,
                P_FP_COLS_REC        => l_fp_cols_rec,
                X_RETURN_STATUS      => X_RETURN_STATUS,
                X_MSG_COUNT          => X_MSG_COUNT,
                X_MSG_DATA              => X_MSG_DATA);
         IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END IF;

         IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug
                    (p_msg         => 'After calling pa_fp_map_bv_pub.maintain_rbs_dtls,
                            ret status: '||x_return_status,
                     p_module_name => l_module_name,
                     p_log_level   => 5);
         END IF;
    END IF;
    IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         =>  'Before calling PJI_FM_XBS_ACCUM_MAINT.PLAN_CREATE',
                p_module_name => l_module_name,
                p_log_level   => 5);
    END IF;
    PJI_FM_XBS_ACCUM_MAINT.PLAN_CREATE (
        p_fp_version_ids        => l_fp_version_ids_tab,
        x_return_status         => x_return_status,
        x_msg_code              => x_msg_data );
    IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         =>  'After calling  PJI_FM_XBS_ACCUM_MAINT.PLAN_CREATE,
                            ret status: '||x_return_status,
                p_module_name => l_module_name,
                p_log_level   => 5);
    END IF;
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         =>  'Before calling PA_FP_GEN_BUDGET_AMT_PUB.UPDATE_BV_FOR_GEN_DATE',
                p_module_name => l_module_name,
                p_log_level   => 5);
    END IF;
    PA_FP_GEN_BUDGET_AMT_PUB.UPDATE_BV_FOR_GEN_DATE
               (P_PROJECT_ID                 => P_PROJECT_ID,
                P_BUDGET_VERSION_ID          => P_BUDGET_VERSION_ID,
                P_ETC_START_DATE             => P_ETC_START_DATE,
                X_RETURN_STATUS              => X_RETURN_STATUS,
                X_MSG_COUNT                  => X_MSG_COUNT,
                X_MSG_DATA                   => X_MSG_DATA);
    IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'After calling PA_FP_GEN_BUDGET_AMT_PUB.UPDATE_BV_FOR_GEN_DATE,
                            ret status: '||x_return_status,
                p_module_name => l_module_name,
                p_log_level   => 5);
    END IF;


    -- IPM: New Entity and Display Quantity ERs --------------------

    -- Before calling maintain_data to rollup amounts, there are
    -- a number of updates that must be performed on txn-level
    -- rate overrides for non-rate-based txns. The following API
    -- call handles those updates. Refer to the comment section at
    -- the beginning of the API for details.

    IF P_CALL_MAINTAIN_DATA_API = 'Y' THEN
    -- Call the maintenance api in ROLLUP mode
    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_MSG                   => 'Before calling PA_FP_GEN_FCST_AMT_PUB1.' ||
                                       'UPD_NRB_TXN_OVR_RATES',
          --P_CALLED_MODE           => p_called_mode,
            P_MODULE_NAME           => l_module_name);
    END IF;
    PA_FP_GEN_FCST_AMT_PUB1.UPD_NRB_TXN_OVR_RATES
          (P_PROJECT_ID              => P_PROJECT_ID,
           P_BUDGET_VERSION_ID       => P_BUDGET_VERSION_ID,
           P_FP_COLS_REC             => l_fp_cols_rec,
           P_ETC_START_DATE          => P_ETC_START_DATE,
           X_RETURN_STATUS           => X_RETURN_STATUS,
           X_MSG_COUNT               => X_MSG_COUNT,
           X_MSG_DATA                => X_MSG_DATA);
    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_MSG                   => 'After calling PA_FP_GEN_FCST_AMT_PUB1.' ||
                                       'UPD_NRB_TXN_OVR_RATES: '||x_return_status,
          --P_CALLED_MODE           => p_called_mode,
            P_MODULE_NAME           => l_module_name);
    END IF;

    -- For budgets, if we are not retaining manual lines, then
    -- all resources for the version need to be rolled up in the
    -- pa_resource_asgn_curr table. If we are retaining manual lines,
    -- then we can selectively roll up only non-manual lines to
    -- improve performance.
    -- For forecasts, we always need to roll up rates and amounts
    -- because of possible changes in actual amounts. As a result,
    -- l_fp_cols_rec.x_gen_ret_manual_line_flag does not need to be
    -- checked in this case.
    -- The same logic applies when populating the display quantity.

    -- TABLE MODE Processing: -------------------------------------

    IF ( l_fp_cols_rec.x_plan_class_code = 'BUDGET' AND
         l_fp_cols_rec.x_gen_ret_manual_line_flag = 'Y' ) THEN

        -- Bug 5029306: Display_quantity needs to be populated before
        -- amounts are rolled up. Therefore, swapped the ordering of
        -- the populate_display_qty() and maintain_data() API calls.

        -- Populate the display quantity for non-manually added resources.

        DELETE pa_resource_asgn_curr_tmp;

        INSERT INTO pa_resource_asgn_curr_tmp
            ( resource_assignment_id )
        SELECT ra.resource_assignment_id
        FROM   pa_resource_assignments ra
        WHERE  ra.budget_version_id = p_budget_version_id
        AND    ra.transaction_source_code IS NOT NULL;

        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG                   => 'Before calling PA_BUDGET_LINES_UTILS.' ||
                                           'POPULATE_DISPLAY_QTY',
              --P_CALLED_MODE           => p_called_mode,
                P_MODULE_NAME           => l_module_name);
        END IF;
        PA_BUDGET_LINES_UTILS.POPULATE_DISPLAY_QTY
              ( P_BUDGET_VERSION_ID     => p_budget_version_id,
                P_CONTEXT               => 'FINANCIAL',
                P_USE_TEMP_TABLE_FLAG   => 'Y',
                X_RETURN_STATUS         => x_return_status );
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG                   => 'After calling PA_BUDGET_LINES_UTILS.' ||
                                           'POPULATE_DISPLAY_QTY: '||x_return_status,
              --P_CALLED_MODE           => p_called_mode,
                P_MODULE_NAME           => l_module_name);
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

        -- Call MAINTAIN_DATA to roll up amounts to pa_resource_asgn_curr
        -- for non-manually added resources. First, populate temp table data.

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
               pa_resource_asgn_curr rbc
        WHERE  ra.budget_version_id = p_budget_version_id
        AND    ra.project_id = p_project_id
        AND    ra.transaction_source_code IS NOT NULL
        AND    bl.resource_assignment_id = ra.resource_assignment_id
        AND    bl.resource_assignment_id = rbc.resource_assignment_id (+)
        AND    bl.txn_currency_code = rbc.txn_currency_code (+);

        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG                   => 'Before calling PA_RES_ASG_CURRENCY_PUB.' ||
                                           'MAINTAIN_DATA',
              --P_CALLED_MODE           => p_called_mode,
                P_MODULE_NAME           => l_module_name);
        END IF;
        PA_RES_ASG_CURRENCY_PUB.MAINTAIN_DATA
              ( P_FP_COLS_REC           => l_fp_cols_rec,
                P_CALLING_MODULE        => 'BUDGET_GENERATION',
                P_ROLLUP_FLAG           => 'Y',
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

    -- VERSION LEVEL Processing: ----------------------------------

    ELSIF ( l_fp_cols_rec.x_plan_class_code = 'BUDGET' AND
            l_fp_cols_rec.x_gen_ret_manual_line_flag = 'N' )
         OR l_fp_cols_rec.x_plan_class_code = 'FORECAST' THEN

        -- Bug 5029306: Display_quantity needs to be populated before
        -- amounts are rolled up. Therefore, swapped the ordering of
        -- the populate_display_qty() and maintain_data() API calls.

        -- Populate the display quantity for all resources in the version.

        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG                   => 'Before calling PA_BUDGET_LINES_UTILS.' ||
                                           'POPULATE_DISPLAY_QTY',
              --P_CALLED_MODE           => p_called_mode,
                P_MODULE_NAME           => l_module_name);
        END IF;
        PA_BUDGET_LINES_UTILS.POPULATE_DISPLAY_QTY
              ( P_BUDGET_VERSION_ID     => p_budget_version_id,
                P_CONTEXT               => 'FINANCIAL',
                P_USE_TEMP_TABLE_FLAG   => 'N',
                X_RETURN_STATUS         => x_return_status );
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG                   => 'After calling PA_BUDGET_LINES_UTILS.' ||
                                           'POPULATE_DISPLAY_QTY: '||x_return_status,
              --P_CALLED_MODE           => p_called_mode,
                P_MODULE_NAME           => l_module_name);
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

        -- Call MAINTAIN_DATA to roll up amounts to pa_resource_asgn_curr.

        IF l_fp_cols_rec.x_plan_class_code = 'BUDGET' THEN
            l_calling_module := 'BUDGET_GENERATION';
        ELSIF l_fp_cols_rec.x_plan_class_code = 'FORECAST' THEN
            l_calling_module := 'FORECAST_GENERATION';
        END IF;

        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG                   => 'Before calling PA_RES_ASG_CURRENCY_PUB.' ||
                                           'MAINTAIN_DATA',
              --P_CALLED_MODE           => p_called_mode,
                P_MODULE_NAME           => l_module_name);
        END IF;
        PA_RES_ASG_CURRENCY_PUB.MAINTAIN_DATA
              ( P_FP_COLS_REC           => l_fp_cols_rec,
                P_CALLING_MODULE        => l_calling_module,
                P_ROLLUP_FLAG           => 'Y',
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
    END IF;

    END IF; -- IPM logic

    -- IPM: Delete records from PA_RESOURCE_ASSIGNMENTS that:
    --   1. Do not have budget lines.
    --   2. Have a non-null transaction_source_code.
    --   3. Do not have a record in the PA_RESOURCE_ASGN_CURR table.
    -- In this way, we can ensure that all records in the resource
    -- assignments table have a corresponding records in the new
    -- pa_resource_asgn_curr entity.

    DELETE FROM pa_resource_assignments ra
    WHERE  ra.budget_version_id = p_budget_version_id
    AND    ra.transaction_source_code IS NOT NULL
    AND NOT EXISTS (SELECT null
                    FROM   pa_budget_lines bl
                    WHERE  bl.resource_assignment_id = ra.resource_assignment_id)
    AND NOT EXISTS (SELECT null
                    FROM   pa_resource_asgn_curr rbc
                    WHERE  rbc.resource_assignment_id = ra.resource_assignment_id);

    -- END OF IPM: New Entity and Display Quantity ERs --------------------


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
        -- dbms_output.put_line('error msg :'||x_msg_data);
        FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_GEN_FCST_AMT_PUB1',
                     p_procedure_name  => 'MAINTAIN_BUDGET_VERSION',
                     p_error_text      => substr(sqlerrm,1,240));

        IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                p_module_name => l_module_name,
                p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END MAINTAIN_BUDGET_VERSION;



/*This function can be called under two contexts:
 1.'VER_ID' to get etc workplan version Id
 2.'VER_NAME' to get etc workplan version name*/
FUNCTION GET_ETC_WP_DTLS
          (P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_CONTEXT                 IN          VARCHAR2)
          RETURN VARCHAR2
IS
  l_project_id                  number;
  l_etc_wp_bdgt_ver_id          number;
  l_versioning_enabled          varchar2(30);
  l_etc_wp_ver_code             PA_PROJ_FP_OPTIONS.GEN_SRC_COST_WP_VER_CODE%type;
  l_etc_wp_ver_id               VARCHAR2(100);
  l_etc_wp_ver_name             PA_PROJ_ELEM_VER_STRUCTURE.name%type;
  l_dummy  VARCHAR2(100):=null;
BEGIN
    SELECT DECODE(BV.VERSION_TYPE,
                  'COST', OPT.GEN_SRC_COST_WP_VERSION_ID,
                  'REVENUE',OPT.GEN_SRC_REV_WP_VERSION_ID,
                  'ALL',OPT.GEN_SRC_ALL_WP_VERSION_ID),
           DECODE(BV.VERSION_TYPE,
                  'COST', OPT1.GEN_SRC_COST_WP_VER_CODE,
                  'REVENUE',OPT1.GEN_SRC_REV_WP_VER_CODE,
                  'ALL',OPT1.GEN_SRC_ALL_WP_VER_CODE),
                   BV.PROJECT_ID
                   INTO l_etc_wp_bdgt_ver_id,
                        l_etc_wp_ver_code,
                        l_project_id
    FROM PA_PROJ_FP_OPTIONS OPT,PA_PROJ_FP_OPTIONS OPT1,
         PA_BUDGET_VERSIONS BV
    WHERE OPT.FIN_PLAN_VERSION_ID             = P_BUDGET_VERSION_ID
          AND OPT.FIN_PLAN_VERSION_ID         = BV.BUDGET_VERSION_ID
          --AND OPT.FIN_PLAN_OPTION_LEVEL_CODE  = 'PLAN_VERSION'
          AND OPT1.FIN_PLAN_TYPE_ID           = BV.FIN_PLAN_TYPE_ID
          AND OPT1.FIN_PLAN_OPTION_LEVEL_CODE = 'PLAN_TYPE'
          AND OPT1.PROJECT_ID                 = BV.PROJECT_ID;
/* Plan_ver_code is selected at PLAN_TYPE instead of PLAN_VERSION */

    IF l_etc_wp_bdgt_ver_id is not null AND P_CONTEXT = 'VER_ID' THEN
        SELECT PROJECT_STRUCTURE_VERSION_ID into l_etc_wp_ver_id
        FROM PA_BUDGET_VERSIONS
        WHERE BUDGET_VERSION_ID = l_etc_wp_bdgt_ver_id;
        RETURN l_etc_wp_ver_id;
    END IF;
    IF l_etc_wp_bdgt_ver_id is not null AND P_CONTEXT = 'VER_NAME' THEN
        SELECT el.name INTO l_etc_wp_ver_name
        FROM pa_budget_versions bv, pa_proj_elem_ver_structure el
        WHERE bv.budget_version_id = l_etc_wp_bdgt_ver_id
              AND bv.project_structure_version_id = el.element_version_id
              AND  bv.project_id = el.project_id;
        RETURN l_etc_wp_ver_name;
    END IF;

    IF l_etc_wp_ver_code IS NULL THEN
       RETURN l_etc_wp_ver_code;
       /* version id or version name cannot be derived. */
    END IF;
    l_versioning_enabled :=
        PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(l_project_id);
    IF l_versioning_enabled = 'Y' THEN
        IF (l_etc_wp_ver_code = 'LAST_PUBLISHED') THEN
            l_etc_wp_ver_id := PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION(
                               P_PROJECT_ID => l_project_id);
        ELSIF (l_etc_wp_ver_code = 'CURRENT_WORKING') THEN
            l_etc_wp_ver_id := PA_PROJECT_STRUCTURE_UTILS.GET_CURRENT_WORKING_VER_ID(
                                P_PROJECT_ID => l_project_id);
            IF l_etc_wp_ver_id is null THEN
                l_etc_wp_ver_id := PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION(
                          P_PROJECT_ID => l_project_id);
            END IF;
        -- Bug 4426511: Changed 'BASELINE', which was INCORRECT, to 'BASELINED'.
        ELSIF (l_etc_wp_ver_code = 'BASELINED') THEN
            l_etc_wp_ver_id := PA_PROJECT_STRUCTURE_UTILS.GET_BASELINE_STRUCT_VER(
                        P_PROJECT_ID => l_project_id);
        END IF;
    ELSE
        l_etc_wp_ver_id := PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION(
                    P_PROJECT_ID => l_project_id);
    END IF;

    IF P_CONTEXT = 'VER_ID' THEN
        RETURN l_etc_wp_ver_id;
    END IF;

    IF  P_CONTEXT = 'VER_NAME' AND l_etc_wp_ver_id is not null THEN
        SELECT name INTO l_etc_wp_ver_name
        FROM pa_proj_elem_ver_structure
        WHERE element_version_id = l_etc_wp_ver_id
          AND project_id = l_project_id;
        RETURN l_etc_wp_ver_name;
    END IF;
    RETURN l_dummy;
EXCEPTION
    WHEN OTHERS THEN
        RETURN l_dummy;
END GET_ETC_WP_DTLS;

/*This function can be called under two contexts:
 1.'PTYPE_ID' to get etc finplan type Id
 2.'PTYPE_NAME' to get etc finplan type name*/
FUNCTION GET_ETC_FP_PTYPE_DTLS
          (P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_CONTEXT                 IN          VARCHAR2)
          RETURN VARCHAR2
IS
  l_src_plan_type_id            varchar2(50);
  l_src_plan_type_name          pa_fin_plan_types_vl.NAME%type;
  l_dummy varchar2(50):=null;
BEGIN

    SELECT DECODE(BV.VERSION_TYPE,
                  'COST', OPT.GEN_SRC_COST_PLAN_TYPE_ID,
                  'REVENUE',OPT.GEN_SRC_REV_PLAN_TYPE_ID,
                  'ALL',OPT.GEN_SRC_ALL_PLAN_TYPE_ID),
           PT.NAME
           INTO l_src_plan_type_id,
                l_src_plan_type_name
    FROM PA_PROJ_FP_OPTIONS OPT,
         PA_BUDGET_VERSIONS BV,
         pa_fin_plan_types_vl PT
    WHERE
          OPT.FIN_PLAN_VERSION_ID = P_BUDGET_VERSION_ID
          AND P_BUDGET_VERSION_ID = BV.BUDGET_VERSION_ID
          AND DECODE(BV.VERSION_TYPE,
                  'COST', OPT.GEN_SRC_COST_PLAN_TYPE_ID,
                  'REVENUE',OPT.GEN_SRC_REV_PLAN_TYPE_ID,
                  'ALL',OPT.GEN_SRC_ALL_PLAN_TYPE_ID)
          = PT.FIN_PLAN_TYPE_ID;

    IF P_CONTEXT = 'PTYPE_ID' THEN
        RETURN l_src_plan_type_id;
    END IF;

    IF  P_CONTEXT = 'PTYPE_NAME' THEN
        RETURN l_src_plan_type_name;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN l_dummy;
END GET_ETC_FP_PTYPE_DTLS;

/*This function can be called under two contexts:
 1.'VER_ID' to get etc finplan version Id
 2.'VER_NAME' to get etc finplan version name*/
FUNCTION GET_ETC_FP_PVERSION_DTLS
          (P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_CONTEXT                 IN          VARCHAR2)
          RETURN VARCHAR2
IS
  l_project_id                  number;
  l_etc_fp_ver_code             varchar2(20);
  l_src_plan_type_id            number;
  l_etc_fp_ver_id               varchar2(50);
  l_etc_fp_ver_name             pa_budget_versions.version_name%type;
  l_fp_options_id               number;

   l_return_status              varchar2(10);
   l_msg_count                  number;
   l_msg_data                   varchar2(50);
   l_dummy varchar2(50):=null;
BEGIN

    SELECT DECODE(BV.VERSION_TYPE,
                  'COST', OPT.GEN_SRC_COST_PLAN_VERSION_ID,
                  'REVENUE',OPT.GEN_SRC_REV_PLAN_VERSION_ID,
                  'ALL',OPT.GEN_SRC_ALL_PLAN_VERSION_ID),
           DECODE(BV.VERSION_TYPE,
                  'COST', OPT1.GEN_SRC_COST_PLAN_VER_CODE,
                  'REVENUE',OPT1.GEN_SRC_REV_PLAN_VER_CODE,
                  'ALL',OPT1.GEN_SRC_ALL_PLAN_VER_CODE),
           DECODE(BV.VERSION_TYPE,
                  'COST', OPT.GEN_SRC_COST_PLAN_TYPE_ID,
                  'REVENUE',OPT.GEN_SRC_REV_PLAN_TYPE_ID,
                  'ALL',OPT.GEN_SRC_ALL_PLAN_TYPE_ID),
                  BV.PROJECT_ID
           INTO l_etc_fp_ver_id,
                l_etc_fp_ver_code,
                l_src_plan_type_id,
                l_project_id
    FROM  PA_PROJ_FP_OPTIONS OPT, PA_PROJ_FP_OPTIONS OPT1,
          PA_BUDGET_VERSIONS BV
    WHERE BV.BUDGET_VERSION_ID            = P_BUDGET_VERSION_ID
    AND   OPT.FIN_PLAN_VERSION_ID         = BV.BUDGET_VERSION_ID
    AND   OPT1.PROJECT_ID                 = BV.PROJECT_ID
    AND   OPT1.FIN_PLAN_TYPE_ID           = BV.FIN_PLAN_TYPE_ID
    AND   OPT1.FIN_PLAN_OPTION_LEVEL_CODE = 'PLAN_TYPE';
/* Plan_ver_code is selected at PLAN_TYPE instead of PLAN_VERSION */

    IF l_etc_fp_ver_id is not null AND P_CONTEXT = 'VER_ID' THEN
        RETURN l_etc_fp_ver_id;
    END IF;
    IF l_etc_fp_ver_id is not null AND P_CONTEXT = 'VER_NAME' THEN
        SELECT version_name INTO l_etc_fp_ver_name
        FROM PA_BUDGET_VERSIONS
        WHERE BUDGET_VERSION_ID = l_etc_fp_ver_id;
        RETURN l_etc_fp_ver_name;
    END IF;

    IF l_etc_fp_ver_code = 'CURRENT_BASELINED'
       OR l_etc_fp_ver_code = 'ORIGINAL_BASELINED'
       OR l_etc_fp_ver_code = 'CURRENT_APPROVED'
       OR l_etc_fp_ver_code = 'ORIGINAL_APPROVED' THEN
        /*Get the current baselined or original baselined version*/
        pa_fp_gen_amount_utils.Get_Curr_Original_Version_Info(
                    p_project_id                => l_project_id,
                    p_fin_plan_type_id          => l_src_plan_type_id,
                    p_version_type              => 'COST',
                    p_status_code               => l_etc_fp_ver_code,
                    x_fp_options_id             => l_fp_options_id,
                    x_fin_plan_version_id       => l_etc_fp_ver_id,
                    x_return_status             => l_return_status,
                    x_msg_count                 => l_msg_count,
                    x_msg_data                  => l_msg_data);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN l_dummy;
        END IF;
    ELSIF l_etc_fp_ver_code = 'CURRENT_WORKING' THEN
         /*Get the current working version*/
        pa_fin_plan_utils.Get_Curr_Working_Version_Info(
                   p_project_id                => l_project_id,
                   p_fin_plan_type_id          => l_src_plan_type_id,
                   p_version_type              => 'COST',
                   x_fp_options_id             => l_fp_options_id,
                   x_fin_plan_version_id       => l_etc_fp_ver_id,
                   x_return_status             => l_return_status,
                   x_msg_count                 => l_msg_count,
                   x_msg_data                  => l_msg_data);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN l_dummy;
        END IF;
    ELSE
         RETURN l_dummy;
    END IF;
    IF P_CONTEXT = 'VER_ID' THEN
        RETURN l_etc_fp_ver_id;
    END IF;

    IF  P_CONTEXT = 'VER_NAME' THEN
        SELECT version_name INTO l_etc_fp_ver_name
        FROM PA_BUDGET_VERSIONS
        WHERE BUDGET_VERSION_ID = l_etc_fp_ver_id;
        RETURN l_etc_fp_ver_name;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN l_dummy;
END GET_ETC_FP_PVERSION_DTLS;


PROCEDURE GET_WP_ACTUALS_FOR_RA
          (P_FP_COLS_SRC_REC         IN PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_FP_COLS_TGT_REC         IN PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_SRC_RES_ASG_ID          IN PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE,
           P_TASK_ID                 IN PA_TASKS.TASK_ID%TYPE,
           P_RES_LIST_MEM_ID         IN PA_RESOURCE_LIST_MEMBERS.RESOURCE_LIST_MEMBER_ID%TYPE,
           P_ACTUALS_THRU_DATE       IN DATE,
           X_ACT_QUANTITY            OUT NOCOPY NUMBER,
           X_ACT_TXN_CURRENCY_CODE   OUT NOCOPY PA_BUDGET_LINES.TXN_CURRENCY_CODE%TYPE,
           X_ACT_TXN_RAW_COST        OUT NOCOPY NUMBER,
           X_ACT_TXN_BRDN_COST       OUT NOCOPY NUMBER,
           X_ACT_PC_RAW_COST         OUT NOCOPY NUMBER,
           X_ACT_PC_BRDN_COST        OUT NOCOPY NUMBER,
           X_ACT_PFC_RAW_COST        OUT NOCOPY NUMBER,
           X_ACT_PFC_BRDN_COST       OUT NOCOPY NUMBER,
           X_RETURN_STATUS           OUT  NOCOPY VARCHAR2,
           X_MSG_COUNT               OUT  NOCOPY NUMBER,
           X_MSG_DATA                OUT  NOCOPY VARCHAR2 )
IS
  l_module_name  VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_FCST_AMT_PUB1.GET_ACTUALS_FOR_RA';

  l_wp_bdgt_ver_id              pa_budget_versions.budget_version_id%type;

  l_txn_currency_code_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
  l_init_quantity_tab           PA_PLSQL_DATATYPES.NumTabTyp;
  l_txn_init_raw_cost_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  l_txn_init_brdn_cost_tab      PA_PLSQL_DATATYPES.NumTabTyp;
  l_prj_init_raw_cost_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  l_prj_init_brdn_cost_tab           PA_PLSQL_DATATYPES.NumTabTyp;
  l_init_raw_cost_tab           PA_PLSQL_DATATYPES.NumTabTyp;
  l_init_brdn_cost_tab          PA_PLSQL_DATATYPES.NumTabTyp;

  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_data                        VARCHAR2(2000);
  l_msg_index_out               NUMBER:=0;
BEGIN
    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function => 'GEN_ETC_BDGT_COMPLETE_AMTS',
                                    p_debug_mode => p_pa_debug_mode);
    END IF;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_COUNT := 0;

    l_wp_bdgt_ver_id := p_fp_cols_tgt_rec.x_gen_src_wp_version_id;

    -- Bug 4285554: When source time phase is None, do not check for
    -- end_date <= p_actuals_thru_date when picking up actuals.

    IF p_fp_cols_src_rec.x_time_phased_code = 'N' THEN
        SELECT  txn_currency_code,
                SUM(NVL(init_quantity,0)),
                SUM(NVL(txn_init_raw_cost,0)),
                SUM(NVL(txn_init_burdened_cost,0)),
                SUM(NVL(project_init_raw_cost,0)),
                SUM(NVL(project_init_burdened_cost,0)),
                SUM(NVL(init_raw_cost,0)),
                SUM(NVL(init_burdened_cost,0))
        BULK COLLECT INTO
                l_txn_currency_code_tab,
                l_init_quantity_tab,
                l_txn_init_raw_cost_tab,
                l_txn_init_brdn_cost_tab,
                l_prj_init_raw_cost_tab,
                l_prj_init_brdn_cost_tab,
                l_init_raw_cost_tab,
                l_init_brdn_cost_tab
        FROM    pa_budget_lines
        WHERE   budget_version_id = l_wp_bdgt_ver_id
          AND   resource_assignment_id = p_src_res_asg_id
          AND   init_quantity is not null
        GROUP BY txn_currency_code;
    ELSE
        SELECT  txn_currency_code,
                SUM(NVL(init_quantity,0)),
                SUM(NVL(txn_init_raw_cost,0)),
                SUM(NVL(txn_init_burdened_cost,0)),
                SUM(NVL(project_init_raw_cost,0)),
                SUM(NVL(project_init_burdened_cost,0)),
                SUM(NVL(init_raw_cost,0)),
                SUM(NVL(init_burdened_cost,0))
        BULK COLLECT INTO
                l_txn_currency_code_tab,
                l_init_quantity_tab,
                l_txn_init_raw_cost_tab,
                l_txn_init_brdn_cost_tab,
                l_prj_init_raw_cost_tab,
                l_prj_init_brdn_cost_tab,
                l_init_raw_cost_tab,
                l_init_brdn_cost_tab
        FROM    pa_budget_lines
        WHERE   budget_version_id = l_wp_bdgt_ver_id
          AND   resource_assignment_id = p_src_res_asg_id
          AND   end_date <= p_actuals_thru_date
          AND   init_quantity is not null
        GROUP BY txn_currency_code;
    END IF; -- source time phase check

     /*Workplan side only stores amounts in one currency for each planning
       resource. This part needs to be revisted when workplan side is changed
       to support multi currencies.*/
    IF l_txn_currency_code_tab.count >= 1 THEN
        X_ACT_TXN_CURRENCY_CODE := l_txn_currency_code_tab(1);
        X_ACT_QUANTITY := l_init_quantity_tab(1);
        X_ACT_TXN_RAW_COST := l_txn_init_raw_cost_tab(1);
        X_ACT_TXN_BRDN_COST := l_txn_init_brdn_cost_tab(1);
        X_ACT_PC_RAW_COST := l_prj_init_raw_cost_tab(1);
        X_ACT_PC_BRDN_COST := l_prj_init_brdn_cost_tab(1);
        X_ACT_PFC_RAW_COST := l_init_raw_cost_tab(1);
        X_ACT_PFC_BRDN_COST := l_init_brdn_cost_tab(1);
    ELSIF l_txn_currency_code_tab.count = 0 THEN
        X_ACT_TXN_CURRENCY_CODE := p_fp_cols_tgt_rec.x_project_currency_code;
        X_ACT_QUANTITY := 0;
        X_ACT_TXN_RAW_COST := 0;
        X_ACT_TXN_BRDN_COST := 0;
        X_ACT_PC_RAW_COST := 0;
        X_ACT_PC_BRDN_COST := 0;
        X_ACT_PFC_RAW_COST := 0;
        X_ACT_PFC_BRDN_COST := 0;
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
        -- dbms_output.put_line('error msg :'||x_msg_data);
        FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_GEN_FCST_AMT_PUB1',
                     p_procedure_name  => 'GET_WP_ACTUALS_FOR_RA',
                     p_error_text      => substr(sqlerrm,1,240));

        IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                p_module_name => l_module_name,
                p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END GET_WP_ACTUALS_FOR_RA;

PROCEDURE call_clnt_extn_and_update_bl(
             p_project_id              IN          pa_projects_all.project_id%TYPE
            ,p_budget_version_id       IN          pa_budget_versions.budget_version_id%TYPE
            ,x_call_maintain_data_api  OUT  NOCOPY VARCHAR2
            ,X_RETURN_STATUS           OUT  NOCOPY VARCHAR2
            ,X_MSG_COUNT               OUT  NOCOPY NUMBER
            ,X_MSG_DATA                OUT  NOCOPY VARCHAR2) IS

  l_msg_count                        NUMBER;
  l_msg_data                         VARCHAR2(2000);
  l_data                             VARCHAR2(2000);
  l_msg_index_out                    NUMBER:=0;
  l_module_name                      VARCHAR2(200) := 'call_clnt_extn_and_update_bl';

  l_fp_cols_rec                      PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
  l_budget_lines_exist               VARCHAR2(1) DEFAULT 'N';

  l_ra_id_tbl                        SYSTEM.pa_num_tbl_type;
  l_task_id_tbl                      SYSTEM.pa_num_tbl_type;
  l_rlm_id_tbl                       SYSTEM.pa_num_tbl_type;
  l_txn_currency_code_tbl            SYSTEM.pa_varchar2_15_tbl_type;
  l_planning_start_date_tbl          SYSTEM.pa_date_tbl_type;
  l_planning_end_date_tbl            SYSTEM.pa_date_tbl_type;
  l_total_qty_tbl                    SYSTEM.pa_num_tbl_type;
  l_txn_raw_cost_tbl                 SYSTEM.pa_num_tbl_type;
  l_txn_burdened_cost_tbl            SYSTEM.pa_num_tbl_type;
  l_txn_revenue_tbl                  SYSTEM.pa_num_tbl_type;
  l_raw_cost_rate_tbl                SYSTEM.pa_num_tbl_type;
  l_burdened_cost_rate_tbl           SYSTEM.pa_num_tbl_type;
  l_bill_rate_tbl                    SYSTEM.pa_num_tbl_type;
  l_line_start_date_tbl              SYSTEM.pa_date_tbl_type;
  l_line_end_date_tbl                SYSTEM.pa_date_tbl_type;

  l_disp_quant_tbl                   SYSTEM.pa_num_tbl_type;
  l_init_quantity_tbl                SYSTEM.pa_num_tbl_type;
  l_init_raw_cost_tbl                SYSTEM.pa_num_tbl_type;
  l_init_burd_cost_tbl               SYSTEM.pa_num_tbl_type;
  l_init_revenue_tbl                 SYSTEM.pa_num_tbl_type;
  l_tras_source_code_tbl             SYSTEM.pa_varchar2_30_tbl_type;


  l_ra_id_tbl_1                      SYSTEM.pa_num_tbl_type;
  l_task_id_tbl_1                    SYSTEM.pa_num_tbl_type;
  l_rlm_id_tbl_1                     SYSTEM.pa_num_tbl_type;
  l_txn_currency_code_tbl_1          SYSTEM.pa_varchar2_15_tbl_type;
  l_planning_start_date_tbl_1        SYSTEM.pa_date_tbl_type;
  l_planning_end_date_tbl_1          SYSTEM.pa_date_tbl_type;
  l_etc_qty_tbl_1                  SYSTEM.pa_num_tbl_type;
  l_txn_raw_cost_tbl_1               SYSTEM.pa_num_tbl_type;
  l_txn_burdened_cost_tbl_1          SYSTEM.pa_num_tbl_type;
  l_total_revenue_tbl_1              SYSTEM.pa_num_tbl_type;
  l_raw_cost_rate_tbl_1              SYSTEM.pa_num_tbl_type;
  l_burdened_cost_rate_tbl_1         SYSTEM.pa_num_tbl_type;
  l_bill_rate_tbl_1                  SYSTEM.pa_num_tbl_type;
  l_line_start_date_tbl_1            SYSTEM.pa_date_tbl_type;
  l_line_end_date_tbl_1              SYSTEM.pa_date_tbl_type;
  l_period_name_tbl_1                SYSTEM.pa_varchar2_30_tbl_type;
  l_disp_quant_tbl_1                 SYSTEM.pa_num_tbl_type;
  l_init_quantity_tbl_1              SYSTEM.pa_num_tbl_type;
  l_init_raw_cost_tbl_1              SYSTEM.pa_num_tbl_type;
  l_init_burd_cost_tbl_1             SYSTEM.pa_num_tbl_type;
  l_init_revenue_tbl_1               SYSTEM.pa_num_tbl_type;
  l_txn_revenue_tbl_1                SYSTEM.pa_num_tbl_type;


  l_ext_period_name_tab              PA_PLSQL_DATATYPES.Char30TabTyp;
  l_ext_raw_cost_rate_tab            PA_PLSQL_DATATYPES.NumTabTyp;
  l_ext_burdened_cost_rate_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  l_ext_revenue_bill_rate_tab        PA_PLSQL_DATATYPES.NumTabTyp;

  l_plan_txn_prd_amt_tbl_1           PA_FP_FCST_GEN_CLIENT_EXT.l_plan_txn_prd_amt_tbl;
  l_input_period_rates_tbl           PA_FP_FCST_GEN_CLIENT_EXT.l_pds_rate_dtls_tab;
  l_period_rates_tbl                 PA_FP_FCST_GEN_CLIENT_EXT.l_pds_rate_dtls_tab;


  l_cal_etc_qty_tab                  SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
  l_cal_etc_raw_cost_tab             SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
  l_cal_etc_burdened_cost_tab        SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
  l_cal_etc_revenue_tab              SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
  l_cal_raid_tab                     SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
  l_cal_txn_currency_code_tab        SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();


   l_upd_rbf_tbl_1                      SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();

   l_rate_based_flag_tbl             SYSTEM.pa_varchar2_15_tbl_type;
   l_res_rate_based_flag_tbl         SYSTEM.pa_varchar2_15_tbl_type;
   l_etc_method_code_tbl             SYSTEM.pa_varchar2_30_tbl_type;


  l_plan_txn_prd_amt_tbl_1_bak       PA_FP_FCST_GEN_CLIENT_EXT.l_plan_txn_prd_amt_tbl;
  l_upd_bud_line_tbl                 PA_FP_FCST_GEN_CLIENT_EXT.l_plan_txn_prd_amt_tbl;

  TYPE del_bud_line_rec IS RECORD ( ra_id               pa_budget_lines.resource_assignment_id%TYPE
                                   ,txn_curr_code       pa_budget_lines.txn_currency_code%TYPE
                                   ,period_name         pa_budget_lines.period_name%TYPE);


  TYPE l_upd_bgt_line_rec IS RECORD
  (
   ra_id               pa_budget_lines.resource_assignment_id%TYPE,
   txn_curr_code       pa_budget_lines.txn_currency_code%TYPE,
   period_name         pa_budget_lines.period_name%TYPE,
   tot_quantity        pa_budget_lines.quantity%TYPE,        -- this attribute is used to update the total quantity field in pa_budget_lines
   txn_raw_cost        pa_budget_lines.txn_raw_cost%TYPE,
   txn_burdened_cost   pa_budget_lines.txn_burdened_cost%TYPE,
   txn_revenue         pa_budget_lines.txn_revenue%TYPE,
   RAW_COST_RATE       pa_budget_lines.txn_standard_cost_rate%TYPE,
   BURDENED_COST_RATE  pa_budget_lines.burden_cost_rate%TYPE,
   REVENUE_BILL_RATE   pa_budget_lines.txn_standard_bill_rate%TYPE,
   disp_quantity       pa_budget_lines.display_quantity%TYPE);


  TYPE   l_ra_id_tbl_prest is TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_ra_id_tbl_present l_ra_id_tbl_prest;

  TYPE l_upd_budget_line_tbl IS TABLE OF l_upd_bgt_line_rec;
  l_upd_bgt_line_tbl l_upd_budget_line_tbl := l_upd_budget_line_tbl();

  TYPE del_bud_line_tbl IS TABLE OF del_bud_line_rec;
  l_del_bud_line_tbl del_bud_line_tbl := del_bud_line_tbl();

  --Record created for updating rate_based_flag in pa_resource_assignments.
  TYPE update_rbf_rec IS RECORD( ra_id            pa_resource_assignments.resource_assignment_id%TYPE,
                                 rate_based_flag  pa_resource_assignments.rate_based_flag%TYPE);
  --pl/sql table created for updating rate_based_flag in pa_resource_assignments.
  TYPE update_rbf_tbl IS TABLE OF update_rbf_rec;
  l_upd_rbf_tbl update_rbf_tbl;

  TYPE description_tbl IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(30);
  l_description_tbl description_tbl;

  l_etc_start_date                    DATE;
  l_act_thru_date                     DATE;

  l_txn_raw_cost_rate_override        NUMBER;
  l_txn_burd_cost_rate_override       NUMBER;
  l_txn_bill_rate_override            NUMBER;
  l_txn_avg_raw_cost_rate             NUMBER;
  l_txn_avg_burden_cost_rate          NUMBER;
  l_txn_avg_bill_rate                 NUMBER;

  l_txn_raw_cost_rate_ovrrid_tbl      SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
  l_txn_burd_cst_rate_ovrrid_tbl      SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
  l_txn_bill_rate_ovrrid_tbl          SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
  l_txn_avg_raw_cost_rate_tbl         SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
  l_txn_avg_burd_cost_rate_tbl        SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
  l_txn_avg_bill_rate_tbl             SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
  l_txn_src_code_tbl                  SYSTEM.pa_varchar2_30_tbl_type :=SYSTEM.pa_varchar2_30_tbl_type();
  l_etc_source_tbl                  SYSTEM.pa_varchar2_80_tbl_type :=SYSTEM.pa_varchar2_80_tbl_type();


  l_period_data_modified              VARCHAR2(1) DEFAULT 'N';
  l_ra_multi_curr                    VARCHAR2(1) DEFAULT 'N';

  l_task_id_tab                       SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
  l_unit_of_measure_tbl               SYSTEM.pa_varchar2_30_tbl_type:=SYSTEM.pa_varchar2_30_tbl_type();
  l_found                             VARCHAR2(1);
  l_call_calculate_flag               VARCHAR2(1) := 'N';
  l_calc_cur_txn_flag               VARCHAR2(1) := 'N';
  l_total_quantity                    NUMBER;
  l_etc_qty                           NUMBER;
  l_etc_raw_cost                      NUMBER;
  l_etc_burdened_cost                 NUMBER;
  l_etc_revenue                       NUMBER;
  l_actual_qty                        NUMBER;
  l_actual_raw_cost                   NUMBER;
  l_actual_burdened_cost              NUMBER;
  l_actual_revenue                    NUMBER;
  l_task_percent_complete             NUMBER;
  l_fcst_etc_qty                      NUMBER;
  l_fcst_etc_raw_cost                 NUMBER;
  l_fcst_etc_burdened_cost            NUMBER;
  l_fcst_etc_revenue                  NUMBER;

  l_raw_cost_rate                     NUMBER;
  l_burden_cost_rate                  NUMBER;
  l_bill_rate                         NUMBER;
  l_raw_cost                          NUMBER;
  l_burdened_cost                     NUMBER;
  l_revenue                           NUMBER;
  l_upd_count                         NUMBER := 0;
  l_del_count                         NUMBER := 0;
  k                                   NUMBER;
  l_set_rbf                           VARCHAR2(1);
  l_rate_change_indicator             VARCHAR2(1) := 'N';
  l_etc_method_code                   VARCHAR2(30);
  l_etc_plan_qty                      NUMBER;
  l_act_work_qty                      NUMBER;
  l_miss_num           CONSTANT      NUMBER     := FND_API.G_MISS_NUM;
  l_struct_status_flag   VARCHAR2(1);
  l_proj_per_comp                    NUMBER;



BEGIN

    x_call_maintain_data_api := 'Y';
    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function => 'call_clnt_extn_and_update_bl',
                                    p_debug_mode => p_pa_debug_mode);
    END IF;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    X_MSG_COUNT := 0;



    IF p_project_id IS NULL OR p_budget_version_id IS NULL THEN
        IF p_pa_debug_mode = 'Y' THEN
           pa_fp_gen_amount_utils.fp_debug
                       (p_msg         => 'PA_FP_INV_PARAM_PASSED',
                        p_module_name => l_module_name,
                        p_log_level   => 5);
           PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE  PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling pa_fp_gen_amount_utils.get_plan_version_dtls',
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;

    PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
             (P_PROJECT_ID         => P_PROJECT_ID,
              P_BUDGET_VERSION_ID  => P_BUDGET_VERSION_ID,
              X_FP_COLS_REC        => l_fp_cols_rec,
              X_RETURN_STATUS      => X_RETURN_STATUS,
              X_MSG_COUNT          => X_MSG_COUNT,
              X_MSG_DATA           => X_MSG_DATA);
    IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling pa_fp_gen_amount_utils.get_plan_version_dtls'||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    l_etc_start_date := PA_FP_GEN_AMOUNT_UTILS.GET_ETC_START_DATE(p_budget_version_id);
    l_act_thru_date  := PA_FP_GEN_AMOUNT_UTILS.GET_ACTUALS_THRU_DATE(p_budget_version_id);



   --Calling this procedure to set the global parameters to for getting the task percent complete.

    l_struct_status_flag := PA_PROJECT_STRUCTURE_UTILS.check_struc_ver_published(p_project_id,
                                                            l_fp_cols_rec.x_project_structure_version_id);


    --Setting the global parameters for the use of the api get_physical_pc_complete to get the task percent complete.
        pa_fin_plan_utils.g_fp_wa_struct_ver_id      := l_fp_cols_rec.x_project_structure_version_id;
        pa_fin_plan_utils.g_fp_wa_struct_status_flag := l_struct_status_flag;


-- Getting the project percent complete.

    IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Getting the project percent complete',
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;

      PA_PROGRESS_UTILS.REDEFAULT_BASE_PC (
          p_Project_ID            => p_project_id,
          p_Proj_element_id       => NULL,
          p_Structure_type        => 'FINANCIAL',
          p_object_type           => 'PA_STRUCTURES',
          p_As_Of_Date            => l_act_thru_date,
          P_STRUCTURE_VERSION_ID  => NULL,
          P_STRUCTURE_STATUS      => NULL,
          p_calling_context       => 'FINANCIAL_PLANNING',
          X_base_percent_complete => l_proj_per_comp,
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





    IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Start of bulk collecting budget lines',
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;

    -- debu: testing: calling populate_display_quantity
    PA_BUDGET_LINES_UTILS.populate_display_qty
        (p_budget_version_id          => p_budget_version_id,
         p_context                    => 'FINANCIAL',
         x_return_status              => X_RETURN_STATUS);

        IF X_RETURN_STATUS <>  FND_API.G_RET_STS_SUCCESS THEN
            IF P_PA_debug_mode = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
                 (p_msg         => 'Status after calling PA_BUDGET_LINES_UTILS.populate_display_qty'||X_RETURN_STATUS,
                  p_module_name => l_module_name,
                  p_log_level   => 5);
            END IF;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

    -- UT Fix: calling maintain_data API to synch up PA_RESOURCE_ASGN_CURR so that this table can be used
    -- further down in this API and in Calculate API when it is called in RESOURCE_ASSIGNMENT mode.
        -- Call MAINTAIN_DATA to roll up amounts to pa_resource_asgn_curr


        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG                   => 'Before calling PA_FP_GEN_FCST_AMT_PUB1.' ||
                                           'UPD_NRB_TXN_OVR_RATES',
              --P_CALLED_MODE           => p_called_mode,
                P_MODULE_NAME           => l_module_name);
        END IF;
        PA_FP_GEN_FCST_AMT_PUB1.UPD_NRB_TXN_OVR_RATES
              (P_PROJECT_ID              => P_PROJECT_ID,
               P_BUDGET_VERSION_ID       => P_BUDGET_VERSION_ID,
               P_FP_COLS_REC             => l_fp_cols_rec,
               P_ETC_START_DATE          => l_etc_start_date,
               X_RETURN_STATUS           => X_RETURN_STATUS,
               X_MSG_COUNT               => X_MSG_COUNT,
               X_MSG_DATA                => X_MSG_DATA);
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG                   => 'After calling PA_FP_GEN_FCST_AMT_PUB1.' ||
                                           'UPD_NRB_TXN_OVR_RATES: '||x_return_status,
              --P_CALLED_MODE           => p_called_mode,
                P_MODULE_NAME           => l_module_name);
        END IF;
        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;




        PA_RES_ASG_CURRENCY_PUB.MAINTAIN_DATA
       ( p_fp_cols_rec           => l_fp_cols_rec,
         p_calling_module        => 'FORECAST_GENERATION',
         p_rollup_flag           => 'Y',
         p_version_level_flag    => 'Y',
         p_called_mode           => 'SELF_SERVICE',
         x_return_status         => X_RETURN_STATUS,
         x_msg_data              => X_MSG_DATA,
         x_msg_count             => X_MSG_COUNT);

         IF X_RETURN_STATUS <>  FND_API.G_RET_STS_SUCCESS THEN
             IF P_PA_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                 (p_msg         => 'Status after calling PA_RES_ASG_CURRENCY_PUB.maintain_data'||X_RETURN_STATUS,
                  p_module_name => l_module_name,
                  p_log_level   => 5);
             END IF;
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END IF;


    -- Adding the call to sync up the planning dates with the budget line dates for a non time phased version if the

        IF l_fp_cols_rec.x_time_phased_code IN ('N') THEN
            PA_FP_MAINTAIN_ACTUAL_PUB.SYNC_UP_PLANNING_DATES_NONE_TP
                (P_BUDGET_VERSION_ID        => P_BUDGET_VERSION_ID,
                 P_FP_COLS_REC              => l_fp_cols_rec,
                 X_RETURN_STATUS            => X_RETURN_STATUS,
                 X_MSG_COUNT                => X_MSG_COUNT,
                 X_MSG_DATA                 => X_MSG_DATA);

            IF X_RETURN_STATUS <>  FND_API.G_RET_STS_SUCCESS THEN
                 IF P_PA_debug_mode = 'Y' THEN
                    pa_fp_gen_amount_utils.fp_debug
                     (p_msg         => 'PA_FP_MAINTAIN_ACTUAL_PUB.SYNC_UP_PLANNING_DATES_NONE_TP'||X_RETURN_STATUS,
                      p_module_name => l_module_name,
                      p_log_level   => 5);
                 END IF;
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
        END IF;



    --Checking if budget lines exist for the forecast version and collecting the budget lines
    SELECT  prac.resource_assignment_id
           ,prac.txn_currency_code
           ,prac.total_quantity - NVL(prac.total_init_quantity,0)
           ,prac.total_txn_raw_cost - NVL(prac.total_txn_init_raw_cost,0)
           ,prac.total_txn_burdened_cost -NVL(prac.total_txn_init_burdened_cost,0)
           ,prac.total_txn_revenue - NVL(prac.total_txn_init_revenue,0)
           ,DECODE (prac.total_display_quantity, NULL, NULL, (prac.total_display_quantity - NVL(prac.total_init_quantity,0)))
           ,prac.total_init_quantity
           ,prac.total_txn_init_raw_cost
           ,prac.total_txn_init_burdened_cost
           ,prac.total_txn_init_revenue
           ,pra.task_id
           ,pra.RESOURCE_LIST_MEMBER_ID
           ,pra.unit_of_measure
           ,pra.rate_based_flag
           ,pra.resource_rate_based_flag
           ,pra.etc_method_code
           ,prac.txn_raw_cost_rate_override
           ,prac.txn_burden_cost_rate_override
           ,prac.txn_bill_rate_override
           ,prac.txn_average_raw_cost_rate
           ,prac.txn_average_burden_cost_rate
           ,prac.txn_average_bill_rate
           ,pra.transaction_source_code
           ,pra.planning_end_date
           ,decode(pra.transaction_source_code,NULL,NULL,
                    (SELECT meaning
                     FROM PA_LOOKUPS
                     WHERE LOOKUP_TYPE='PA_FP_FCST_GEN_SRC_ALL'
                     AND LOOKUP_CODE= pra.transaction_source_code)) etc_source
    BULK COLLECT INTO
           l_ra_id_tbl_1
          ,l_txn_currency_code_tbl_1
          ,l_etc_qty_tbl_1 /* ETC QTY */
          ,l_txn_raw_cost_tbl_1
          ,l_txn_burdened_cost_tbl_1
          ,l_txn_revenue_tbl_1
          ,l_disp_quant_tbl_1
          ,l_init_quantity_tbl_1
          ,l_init_raw_cost_tbl_1
          ,l_init_burd_cost_tbl_1
          ,l_init_revenue_tbl_1
          ,l_task_id_tab
          ,l_rlm_id_tbl
          ,l_unit_of_measure_tbl
          ,l_rate_based_flag_tbl
          ,l_res_rate_based_flag_tbl
          ,l_etc_method_code_tbl
          ,l_txn_raw_cost_rate_ovrrid_tbl
          ,l_txn_burd_cst_rate_ovrrid_tbl
          ,l_txn_bill_rate_ovrrid_tbl
          ,l_txn_avg_raw_cost_rate_tbl
          ,l_txn_avg_burd_cost_rate_tbl
          ,l_txn_avg_bill_rate_tbl
          ,l_txn_src_code_tbl
          ,l_planning_end_date_tbl_1
          ,l_etc_source_tbl
    FROM  pa_resource_asgn_curr prac,
          pa_resource_assignments pra
    WHERE prac.budget_version_id = p_budget_version_id
    AND   pra.budget_version_id = p_budget_version_id
    AND   prac.resource_assignment_id = pra.resource_assignment_id;

    IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'End of bulk collecting budget lines',
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;

            -- the for loop for all the resource assignments for the client extension will be called , that are collected
            -- from the above selects
            -- need to put if for the plsql table to check the count

        l_upd_rbf_tbl := update_rbf_tbl();
        l_upd_rbf_tbl.DELETE;

        IF  l_ra_id_tbl_1.COUNT > 0 THEN


            FOR C1 IN (select lookup_code, meaning from pa_lookups where lookup_type = 'PA_FP_FCST_GEN_CLNT_EXTN_LU') loop
                 l_description_tbl(c1.lookup_code) := c1.meaning;
            END LOOP;



            DELETE from PA_FP_GEN_RATE_TMP;
            FOR kk in l_ra_id_tbl_1.FIRST .. l_ra_id_tbl_1.LAST
            LOOP

                     l_calc_cur_txn_flag := 'N';
                     l_etc_qty := l_disp_quant_tbl_1(kk);
                     l_etc_raw_cost := l_txn_raw_cost_tbl_1(kk);
                     l_etc_burdened_cost := l_txn_burdened_cost_tbl_1(kk);
                     l_etc_revenue := l_txn_revenue_tbl_1(kk);
                     l_actual_qty :=  l_init_quantity_tbl_1(kk);
                     l_actual_raw_cost := l_init_raw_cost_tbl_1(kk);
                     l_actual_burdened_cost := l_init_burd_cost_tbl_1(kk);
                     l_actual_revenue := l_init_revenue_tbl_1(kk);
                     l_total_quantity := l_etc_qty_tbl_1(kk) + l_init_quantity_tbl_1(kk);
    IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before collecting budget lines for a ra id',
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;

                     SELECT
                         pbl.period_name
                        ,NVL(pbl.txn_cost_rate_override,pbl.txn_standard_cost_rate)
                        ,NVL(pbl.burden_cost_rate_override,pbl.burden_cost_rate)
                        ,NVL(pbl.txn_bill_rate_override,pbl.txn_standard_bill_rate)
                        ,pbl.quantity
                        ,pbl.start_date
                        ,pbl.end_date
                        ,pbl.txn_raw_cost
                        ,pbl.txn_burdened_cost
                        ,pbl.txn_revenue
                        ,pbl.display_quantity
                        ,pbl.init_quantity
                        ,pbl.txn_init_raw_cost
                        ,pbl.txn_init_burdened_cost
                        ,pbl.txn_init_revenue
                    BULK COLLECT INTO
                         l_ext_period_name_tab
                        ,l_ext_raw_cost_rate_tab
                        ,l_ext_burdened_cost_rate_tab
                        ,l_ext_revenue_bill_rate_tab
                        ,l_total_qty_tbl
                        ,l_line_start_date_tbl
                        ,l_line_end_date_tbl
                        ,l_txn_raw_cost_tbl
                        ,l_txn_burdened_cost_tbl
                        ,l_txn_revenue_tbl
                        ,l_disp_quant_tbl
                        ,l_init_quantity_tbl
                        ,l_init_raw_cost_tbl
                        ,l_init_burd_cost_tbl
                        ,l_init_revenue_tbl
                     FROM   pa_budget_lines pbl
                     WHERE  resource_assignment_id  = l_ra_id_tbl_1(kk)
                     AND    txn_currency_code = l_txn_currency_code_tbl_1(kk)
                     ORDER BY pbl.start_date; -- Added for Bug 8718969

    IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'After collecting budget lines for a ra id',
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;


                     -- populate the override rates table to be passed for the lines
                     l_input_period_rates_tbl.delete;
                     l_plan_txn_prd_amt_tbl_1.delete;

                     FOR j IN 1..l_ext_period_name_tab.count
                     LOOP
                         l_input_period_rates_tbl(j).period_name := l_ext_period_name_tab(j);
                         l_input_period_rates_tbl(j).raw_cost_rate := l_ext_raw_cost_rate_tab(j);
                         l_input_period_rates_tbl(j).burdened_cost_rate := l_ext_burdened_cost_rate_tab(j);
                         l_input_period_rates_tbl(j).revenue_bill_rate := l_ext_revenue_bill_rate_tab(j);

                         l_plan_txn_prd_amt_tbl_1(j).period_name := l_ext_period_name_tab(j);

                         IF l_fp_cols_rec.x_time_phased_code IN ('P' , 'G') THEN
                             l_plan_txn_prd_amt_tbl_1(j).txn_raw_cost := l_txn_raw_cost_tbl(j);
                             l_plan_txn_prd_amt_tbl_1(j).txn_burdened_cost := l_txn_burdened_cost_tbl(j);
                             l_plan_txn_prd_amt_tbl_1(j).txn_revenue := l_txn_revenue_tbl(j);
                             l_plan_txn_prd_amt_tbl_1(j).etc_quantity := l_disp_quant_tbl(j);

                         ELSE
                             l_plan_txn_prd_amt_tbl_1(j).txn_raw_cost := l_txn_raw_cost_tbl(j) - l_init_raw_cost_tbl(j);
                             l_plan_txn_prd_amt_tbl_1(j).txn_burdened_cost := l_txn_burdened_cost_tbl(j) - l_init_burd_cost_tbl(j);
                             l_plan_txn_prd_amt_tbl_1(j).txn_revenue := l_txn_revenue_tbl(j) - l_init_revenue_tbl(j);
                             l_plan_txn_prd_amt_tbl_1(j).etc_quantity := l_disp_quant_tbl(j) - l_init_quantity_tbl(j);
                         END IF;

                         l_plan_txn_prd_amt_tbl_1(j).init_quantity := l_init_quantity_tbl(j);
                         l_plan_txn_prd_amt_tbl_1(j).init_raw_cost := l_init_raw_cost_tbl(j);
                         l_plan_txn_prd_amt_tbl_1(j).init_burdened_cost := l_init_burd_cost_tbl(j);
                         l_plan_txn_prd_amt_tbl_1(j).init_revenue := l_init_revenue_tbl(j);

                            IF NOT (l_fp_cols_rec.x_gen_ret_manual_line_flag = 'N' AND l_txn_src_code_tbl(kk) IS NULL )
                               AND l_line_end_date_tbl(j) < NVL (l_etc_start_date,l_line_end_date_tbl(j) + 1) THEN
                                   l_plan_txn_prd_amt_tbl_1(j).description := l_description_tbl('CLOSED_PERIOD');
                                   l_plan_txn_prd_amt_tbl_1(j).periodic_line_editable := 'N';
                            ELSIF (l_fp_cols_rec.x_gen_ret_manual_line_flag = 'Y' AND l_txn_src_code_tbl(kk) IS NULL) THEN
                                   l_plan_txn_prd_amt_tbl_1(j).description := l_description_tbl('MANUALLY_ADDED_LINE'); -- Modified to MANUALLY_ADDED_LINE for Bug #5979618
                                     l_plan_txn_prd_amt_tbl_1(j).periodic_line_editable := 'N';
                            ELSE
                                  l_plan_txn_prd_amt_tbl_1(j).description := l_description_tbl('EDITABLE');
                                  l_plan_txn_prd_amt_tbl_1(j).periodic_line_editable := 'Y';
                            END IF;

                     END LOOP;


            -- Call the client extension for each planning transaction
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                            P_MSG           =>
                            'Before calling pa_fp_fcst_gen_client_ext.fcst_gen_client_extn',
                            P_MODULE_NAME   => l_module_name);
                    END IF;
            --back up the values to be compared later
                    l_plan_txn_prd_amt_tbl_1_bak := l_plan_txn_prd_amt_tbl_1;
                    l_period_data_modified := 'N';

            -- call the client extns;

            -- Fetching the etc method code for the temp table used in calcuate.

            l_etc_method_code := NULL;
            l_etc_plan_qty := NULL;
            l_act_work_qty := NULL;

            BEGIN
                -- for etc_method_code
                SELECT tmp1.etc_method_code
                INTO   l_etc_method_code
                FROM   PA_FP_CALC_AMT_TMP1 tmp1,
                       PA_FP_CALC_AMT_TMP2 tmp2
                WHERE  tmp1.TARGET_RES_ASG_ID = l_ra_id_tbl_1(kk)
                AND    tmp2.TARGET_RES_ASG_ID = l_ra_id_tbl_1(kk)
                AND    tmp1.resource_assignment_id = tmp2.resource_assignment_id
                AND    tmp1.target_res_asg_id = tmp2.target_res_asg_id
                AND    tmp2.txn_currency_code =  l_txn_currency_code_tbl_1(kk)
                AND    tmp1.transaction_source_code <> 'OPEN_COMMITMENTS'
                AND    tmp2.transaction_source_code =  'ETC';

                -- for work quantity
                /* In work quantity flows, resource_assignment_id is inserted as (-1) * task_id
                 * so we have to split this select into two to get the below values separately.
                 * -- Below code commented since this doesnt work. The tmp2
                 * table is empty for work qty flows! ... Logic needs to be put
                 * for this...
                SELECT tmp2.etc_plan_quantity
                      ,tmp2.actual_work_qty
                INTO   l_etc_plan_qty
                      ,l_act_work_qty
                FROM  PA_FP_CALC_AMT_TMP1 tmp1,
                      PA_FP_CALC_AMT_TMP2 tmp2
                WHERE tmp1.resource_assignment_id = ((-1) * l_task_id_tab(kk))
                AND   tmp2.resource_assignment_id = ((-1) * l_task_id_tab(kk))
                AND   tmp1.resource_assignment_id = tmp2.resource_assignment_id
                AND   tmp1.mapped_fin_task_id = l_task_id_tab(kk)
                AND   tmp1.transaction_source_code = 'WORK_QUANTITY';

                *****/

            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                  l_etc_method_code := NULL;
                  l_etc_plan_qty := NULL;
                  l_act_work_qty := NULL;
            WHEN OTHERS THEN
                  /* Ideally this part of code should never get executed.
                   * This is put just to ensure that the fst generation flow
                   * doesnt break just for want of the etc_method_code
                   * information parameter */
                  l_etc_method_code := NULL;
                  l_etc_plan_qty := NULL;
                  l_act_work_qty := NULL;

            END;


                   l_task_percent_complete :=PA_FIN_PLAN_UTILS.get_physical_pc_complete
                                               (p_project_id => p_project_id
                                                ,p_proj_element_id =>l_task_id_tab(kk));

                    PA_FP_FCST_GEN_CLIENT_EXT.FCST_GEN_CLIENT_EXTN
                   (P_PROJECT_ID                => P_PROJECT_ID,
                    P_BUDGET_VERSION_ID         => P_BUDGET_VERSION_ID,
                    P_RESOURCE_ASSIGNMENT_ID    => l_ra_id_tbl_1(kk),
                    P_TASK_ID                   => l_task_id_tab(kk),
                    P_TASK_PERCENT_COMPLETE     => l_task_percent_complete,
                    P_PROJECT_PERCENT_COMPLETE  => l_proj_per_comp,
                    P_RESOURCE_LIST_MEMBER_ID   => l_rlm_id_tbl(kk),
                    P_UNIT_OF_MEASURE           => l_unit_of_measure_tbl(kk),
                    P_TXN_CURRENCY_CODE         => l_txn_currency_code_tbl_1(kk),
                    P_ETC_QTY                   => l_etc_qty,
                    P_ETC_RAW_COST              => l_etc_raw_cost,
                    P_ETC_BURDENED_COST         => l_etc_burdened_cost,
                    P_ETC_REVENUE               => l_etc_revenue,
                    P_ETC_SOURCE                => l_etc_source_tbl(kk),
                    P_ETC_GEN_METHOD            => l_etc_method_code,
                    P_ACTUAL_THRU_DATE          => l_act_thru_date,
                    P_ETC_START_DATE            => l_act_thru_date+1,
                    P_ETC_END_DATE              => l_planning_end_date_tbl_1(kk),
                    P_PLANNED_WORK_QTY          => l_etc_plan_qty,
                    P_ACTUAL_WORK_QTY           => l_act_work_qty,
                    P_ACTUAL_QTY                => l_actual_qty,
                    P_ACTUAL_RAW_COST           => l_actual_raw_cost,
                    P_ACTUAL_BURDENED_COST      => l_actual_burdened_cost,
                    P_ACTUAL_REVENUE            => l_actual_revenue,
                    P_PERIOD_RATES_TBL          => l_input_period_rates_tbl,
                    X_ETC_QTY                   => l_fcst_etc_qty,
                    X_ETC_RAW_COST              => l_fcst_etc_raw_cost,
                    X_ETC_BURDENED_COST         => l_fcst_etc_burdened_cost,
                    X_ETC_REVENUE               => l_fcst_etc_revenue,
                    X_PERIOD_RATES_TBL          => l_period_rates_tbl,
                    p_override_raw_cost_rate    => l_txn_raw_cost_rate_ovrrid_tbl(kk),
                    p_override_burd_cost_rate   => l_txn_burd_cst_rate_ovrrid_tbl(kk),
                    p_override_bill_rate        => l_txn_bill_rate_ovrrid_tbl(kk),
                    p_avg_raw_cost_rate         => l_txn_avg_raw_cost_rate_tbl(kk),
                    p_avg_burd_cost_rate        => l_txn_avg_burd_cost_rate_tbl(kk),
                    p_avg_bill_rate             => l_txn_avg_bill_rate_tbl(kk),
                    px_period_amts_tbl          => l_plan_txn_prd_amt_tbl_1,
                    px_period_data_modified     => l_period_data_modified,
                    X_RETURN_STATUS             => x_return_status,
                    X_MSG_DATA                  => x_msg_data,
                    X_MSG_COUNT                 => x_msg_count);




                    IF P_PA_DEBUG_MODE = 'Y' THEN
                        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                            P_MSG           => 'After calling pa_fp_fcst_gen_client_ext.fcst_gen_client_extn: '||x_return_status,
                            P_MODULE_NAME   => l_module_name);
                    END IF;
                    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;


                   IF l_ra_id_tbl_present.exists(l_ra_id_tbl_1(kk)) THEN
                        l_ra_multi_curr := 'Y';
                        IF l_upd_rbf_tbl.count > 0 THEN -- added for bug 5516731
                           FOR u IN l_upd_rbf_tbl.FIRST..l_upd_rbf_tbl.LAST LOOP
                             IF  l_upd_rbf_tbl(u).ra_id = l_ra_id_tbl_1(kk) THEN
                               l_upd_rbf_tbl.DELETE(u);
                             END IF;
                           End LOOP;
                        END IF; -- added for bug 5516731
                   ELSE
                        l_ra_id_tbl_present(l_ra_id_tbl_1(kk)) := l_ra_id_tbl_1(kk);
                        l_ra_multi_curr := 'N';
                   END IF;

        -- validating the modified amounts
                    IF l_fp_cols_rec.x_time_phased_code IN ('P' , 'G') THEN
                       IF NVL(l_period_data_modified,'N') = 'Y' THEN
                    -- loop thru the backup table and the recieved table to see whether the period line is present
                    -- and if so get it.
                          IF l_plan_txn_prd_amt_tbl_1_bak.COUNT > 0 AND l_plan_txn_prd_amt_tbl_1.COUNT > 0 THEN
                             IF l_rate_based_flag_tbl(kk) = 'N' AND l_res_rate_based_flag_tbl(kk) = 'Y' THEN
                                 l_set_rbf := 'N';
                                 IF l_ra_multi_curr = 'N' THEN
                                     <<OUTERLOOP>> FOR d IN l_plan_txn_prd_amt_tbl_1_bak.FIRST..l_plan_txn_prd_amt_tbl_1_bak.LAST LOOP
                                        <<INNERLOOP>> FOR e IN l_plan_txn_prd_amt_tbl_1.FIRST..l_plan_txn_prd_amt_tbl_1.LAST LOOP
                                            IF l_plan_txn_prd_amt_tbl_1(e).period_name = l_plan_txn_prd_amt_tbl_1_bak(d).period_name THEN
                                               IF l_plan_txn_prd_amt_tbl_1(e).etc_quantity IS NULL AND
                                                  (l_plan_txn_prd_amt_tbl_1(e).txn_raw_cost IS NOT NULL OR
                                                  l_plan_txn_prd_amt_tbl_1(e).txn_burdened_cost IS NOT NULL OR
                                                  l_plan_txn_prd_amt_tbl_1(e).txn_revenue IS NOT NULL) THEN
                                                  l_set_rbf := 'N';
                                                  EXIT OUTERLOOP;
                                               ELSE
                                                  l_set_rbf := 'Y';
                                               END IF;
                                            END IF;
                                        END LOOP;
                                     END LOOP;
                                 END IF;
                                 IF l_set_rbf = 'Y' THEN
                                    l_upd_rbf_tbl.extend(1);
                                    l_upd_rbf_tbl(l_upd_rbf_tbl.COUNT).ra_id := l_ra_id_tbl_1(kk);
                                 END IF;
                             END IF;

                             FOR j IN l_plan_txn_prd_amt_tbl_1_bak.first .. l_plan_txn_prd_amt_tbl_1_bak.last
                             LOOP

                                l_found := 'N';
                                k := null;
                                FOR z IN l_plan_txn_prd_amt_tbl_1.first .. l_plan_txn_prd_amt_tbl_1.last
                                LOOP

                                   IF l_plan_txn_prd_amt_tbl_1_bak(j).period_name = l_plan_txn_prd_amt_tbl_1(z).period_name THEN
                                      l_found := 'Y';
                                      k :=z;
                                      EXIT;
                                   END IF;
                                END LOOP; --l_plan_txn_prd_amt_tbl_1 (k)
                                -- if the line is found and that line is editable

                                IF l_plan_txn_prd_amt_tbl_1_bak(j).periodic_line_editable = 'Y' and l_found = 'Y' AND
                                   (NVL(l_plan_txn_prd_amt_tbl_1_bak(j).etc_quantity,l_miss_num) <>
                                    NVL(l_plan_txn_prd_amt_tbl_1(k).etc_quantity,l_miss_num) OR
                                    NVL(l_plan_txn_prd_amt_tbl_1_bak(j).txn_raw_cost,l_miss_num) <>
                                            NVL(l_plan_txn_prd_amt_tbl_1(k).txn_raw_cost,l_miss_num) OR
                                    NVL(l_plan_txn_prd_amt_tbl_1_bak(j).txn_burdened_cost,l_miss_num) <>
                                            NVL(l_plan_txn_prd_amt_tbl_1(k).txn_burdened_cost,l_miss_num) OR
                                    NVL(l_plan_txn_prd_amt_tbl_1_bak(j).txn_revenue,l_miss_num) <>
                                    NVL(l_plan_txn_prd_amt_tbl_1(k).txn_revenue,l_miss_num)) THEN
                                    /*Start of the rounding handing*/

                                    -- if resource_rate_based_flag is N for the planning transaction, then we are ignoring any update
                                    -- on the etc_quantity. So updating it aas null. For other cases, we might have to honor the changes
                                    -- done for etc_quantity by the client extn.
                                    IF l_res_rate_based_flag_tbl(kk) = 'N' THEN
                                        l_plan_txn_prd_amt_tbl_1(k).etc_quantity := NULL;
                                    ELSIF l_plan_txn_prd_amt_tbl_1(k).etc_quantity IS NOT NULL THEN
                                        l_plan_txn_prd_amt_tbl_1(k).etc_quantity := pa_fin_plan_utils2.round_quantity
                                                        (p_quantity => l_plan_txn_prd_amt_tbl_1(k).etc_quantity);
                                    END IF;

                                    IF l_fp_cols_rec.x_version_type = 'COST' OR l_fp_cols_rec.x_version_type = 'ALL' THEN
                                       IF l_plan_txn_prd_amt_tbl_1(k).txn_raw_cost IS NOT NULL THEN
                                           l_plan_txn_prd_amt_tbl_1(k).txn_raw_cost := pa_currency.round_trans_currency_amt1
                                                                                       (x_amount    => l_plan_txn_prd_amt_tbl_1(k).txn_raw_cost,
                                                                                        x_curr_Code => l_txn_currency_code_tbl_1(kk));
                                       END IF;
                                       IF l_plan_txn_prd_amt_tbl_1(k).txn_burdened_cost IS NOT NULL THEN
                                           l_plan_txn_prd_amt_tbl_1(k).txn_burdened_cost := pa_currency.round_trans_currency_amt1
                                                                                             (x_amount    => l_plan_txn_prd_amt_tbl_1(k).txn_burdened_cost,
                                                                                              x_curr_Code => l_txn_currency_code_tbl_1(kk));
                                       END IF;
                                    END IF;
                                    IF l_fp_cols_rec.x_version_type = 'REVENUE' OR l_fp_cols_rec.x_version_type = 'ALL' THEN
                                       IF l_plan_txn_prd_amt_tbl_1(k).txn_revenue IS NOT NULL THEN
                                           l_plan_txn_prd_amt_tbl_1(k).txn_revenue  := pa_currency.round_trans_currency_amt1
                                                                                             (x_amount    => l_plan_txn_prd_amt_tbl_1(k).txn_revenue,
                                                                                              x_curr_Code => l_txn_currency_code_tbl_1(kk));
                                       END IF;
                                    END IF;
                                   /*End of the rounding handling*/

                                    -- if all amounts have been nulled out , delete that budget line ,
                                    -- populating the del_bug_line table to be deleted.

                                     -- else populationg the upd budget line table.
                                     -- and taking care of the precedence rules.

                                    IF l_rate_based_flag_tbl(kk) = 'Y' AND l_res_rate_based_flag_tbl(kk) = 'Y'
                                        AND l_plan_txn_prd_amt_tbl_1(k).etc_quantity IS NOT NULL THEN

                                         l_upd_bgt_line_tbl.extend(1);
                                         l_upd_count := l_upd_bgt_line_tbl.COUNT;
                                         l_upd_bgt_line_tbl(l_upd_count).ra_id :=  l_ra_id_tbl_1(kk);
                                         l_upd_bgt_line_tbl(l_upd_count).txn_curr_code := l_txn_currency_code_tbl_1(kk);

                                         l_upd_bgt_line_tbl(l_upd_count).period_name := l_plan_txn_prd_amt_tbl_1_bak(j).period_name;
                                         l_upd_bgt_line_tbl(l_upd_count).txn_raw_cost := l_plan_txn_prd_amt_tbl_1_bak(j).txn_raw_cost;
                                         l_upd_bgt_line_tbl(l_upd_count).txn_burdened_cost := l_plan_txn_prd_amt_tbl_1_bak(j).txn_burdened_cost;
                                         l_upd_bgt_line_tbl(l_upd_count).txn_revenue := l_plan_txn_prd_amt_tbl_1_bak(j).txn_revenue;
                                         l_upd_bgt_line_tbl(l_upd_count).raw_cost_rate := l_ext_raw_cost_rate_tab(j);
                                         l_upd_bgt_line_tbl(l_upd_count).BURDENED_COST_RATE := l_ext_burdened_cost_rate_tab(j);
                                         l_upd_bgt_line_tbl(l_upd_count).REVENUE_BILL_RATE := l_ext_revenue_bill_rate_tab(j);
                                         l_upd_bgt_line_tbl(l_upd_count).disp_quantity := l_plan_txn_prd_amt_tbl_1_bak(j).etc_quantity;
                                         -- the etc_quantity field would contain total_quantity for the budget line. so adding back the init value also
                                         -- though there would not be any actual quantity for open periods.
                                         l_upd_bgt_line_tbl(l_upd_count).tot_quantity := l_plan_txn_prd_amt_tbl_1_bak(j).etc_quantity + Nvl(l_plan_txn_prd_amt_tbl_1_bak(j).init_quantity, 0);



                                         IF Nvl(l_plan_txn_prd_amt_tbl_1(k).etc_quantity, 0) <> Nvl(l_plan_txn_prd_amt_tbl_1_bak(j).etc_quantity, 0) THEN

                                                -- update the changed quantity - making display quantity equal to total quantity.
                                                l_upd_bgt_line_tbl(l_upd_count).tot_quantity := l_plan_txn_prd_amt_tbl_1(j).etc_quantity + Nvl(l_plan_txn_prd_amt_tbl_1_bak(j).init_quantity, 0);
                                                l_upd_bgt_line_tbl(l_upd_count).disp_quantity := l_plan_txn_prd_amt_tbl_1(j).etc_quantity + Nvl(l_plan_txn_prd_amt_tbl_1_bak(j).init_quantity, 0);
                                                IF l_fp_cols_rec.x_version_type = 'COST' OR l_fp_cols_rec.x_version_type = 'ALL' THEN

                                                    IF l_plan_txn_prd_amt_tbl_1(k).txn_raw_cost IS NULL THEN
                                                       l_upd_bgt_line_tbl(l_upd_count).txn_raw_cost := NULL;
                                                       l_upd_bgt_line_tbl(l_upd_count).raw_cost_rate := 0;
                                                    ELSE
                                                       l_upd_bgt_line_tbl(l_upd_count).txn_raw_cost := l_plan_txn_prd_amt_tbl_1(k).txn_raw_cost;
                                                       l_upd_bgt_line_tbl(l_upd_count).raw_cost_rate := l_plan_txn_prd_amt_tbl_1(k).txn_raw_cost
                                                                                                                    /l_plan_txn_prd_amt_tbl_1(k).etc_quantity;
                                                    END IF;
                                                    IF l_plan_txn_prd_amt_tbl_1(k).txn_burdened_cost IS NULL THEN
                                                       l_upd_bgt_line_tbl(l_upd_count).txn_burdened_cost := NULL;
                                                       l_upd_bgt_line_tbl(l_upd_count).burdened_cost_rate := 0;
                                                    ELSE
                                                       l_upd_bgt_line_tbl(l_upd_count).txn_burdened_cost := l_plan_txn_prd_amt_tbl_1(k).txn_burdened_cost;
                                                       l_upd_bgt_line_tbl(l_upd_count).burdened_cost_rate := l_plan_txn_prd_amt_tbl_1(k).txn_burdened_cost
                                                                                                                         /l_plan_txn_prd_amt_tbl_1(k).etc_quantity;
                                                    END IF;
                                                END IF;
                                                IF l_fp_cols_rec.x_version_type = 'REVENUE' OR l_fp_cols_rec.x_version_type = 'ALL' THEN
                                                    IF l_plan_txn_prd_amt_tbl_1(k).txn_revenue IS NULL THEN
                                                       l_upd_bgt_line_tbl(l_upd_count).txn_revenue := NULL;
                                                       l_upd_bgt_line_tbl(l_upd_count).revenue_bill_rate := 0;
                                                    ELSE
                                                       l_upd_bgt_line_tbl(l_upd_count).txn_revenue := l_plan_txn_prd_amt_tbl_1(k).txn_revenue;
                                                       l_upd_bgt_line_tbl(l_upd_count).revenue_bill_rate := l_plan_txn_prd_amt_tbl_1(k).txn_revenue
                                                                                                           /l_plan_txn_prd_amt_tbl_1(k).etc_quantity;
                                                    END IF;
                                                END IF;
                                         ELSE
                                                IF l_fp_cols_rec.x_version_type = 'COST' OR l_fp_cols_rec.x_version_type = 'ALL' THEN

                                                    IF l_plan_txn_prd_amt_tbl_1(k).txn_raw_cost IS NULL THEN
                                                       l_upd_bgt_line_tbl(l_upd_count).txn_raw_cost := NULL;
                                                       l_upd_bgt_line_tbl(l_upd_count).raw_cost_rate := 0;
                                                    ELSIF l_plan_txn_prd_amt_tbl_1(k).txn_raw_cost <> l_plan_txn_prd_amt_tbl_1_bak(j).txn_raw_cost THEN
                                                       l_upd_bgt_line_tbl(l_upd_count).txn_raw_cost := l_plan_txn_prd_amt_tbl_1(k).txn_raw_cost;
                                                       l_upd_bgt_line_tbl(l_upd_count).raw_cost_rate := l_plan_txn_prd_amt_tbl_1(k).txn_raw_cost
                                                                                                                    /l_plan_txn_prd_amt_tbl_1(k).etc_quantity;
                                                    END IF;
                                                    IF l_plan_txn_prd_amt_tbl_1(k).txn_burdened_cost IS NULL THEN
                                                       l_upd_bgt_line_tbl(l_upd_count).txn_burdened_cost := NULL;
                                                       l_upd_bgt_line_tbl(l_upd_count).burdened_cost_rate := 0;
                                                    ELSIF l_plan_txn_prd_amt_tbl_1(k).txn_burdened_cost <> l_plan_txn_prd_amt_tbl_1_bak(j).txn_burdened_cost THEN
                                                       l_upd_bgt_line_tbl(l_upd_count).txn_burdened_cost := l_plan_txn_prd_amt_tbl_1(k).txn_burdened_cost;
                                                       l_upd_bgt_line_tbl(l_upd_count).burdened_cost_rate := l_plan_txn_prd_amt_tbl_1(k).txn_burdened_cost
                                                                                                                         /l_plan_txn_prd_amt_tbl_1(k).etc_quantity;
                                                    END IF;
                                                END IF;
                                                IF l_fp_cols_rec.x_version_type = 'REVENUE' OR l_fp_cols_rec.x_version_type = 'ALL' THEN
                                                    IF l_plan_txn_prd_amt_tbl_1(k).txn_revenue IS NULL THEN
                                                       l_upd_bgt_line_tbl(l_upd_count).txn_revenue := NULL;
                                                       l_upd_bgt_line_tbl(l_upd_count).revenue_bill_rate := 0;
                                                    ELSIF l_plan_txn_prd_amt_tbl_1(k).txn_revenue <>  l_plan_txn_prd_amt_tbl_1_bak(j).txn_revenue THEN
                                                       l_upd_bgt_line_tbl(l_upd_count).txn_revenue := l_plan_txn_prd_amt_tbl_1(k).txn_revenue;
                                                       l_upd_bgt_line_tbl(l_upd_count).revenue_bill_rate := l_plan_txn_prd_amt_tbl_1(k).txn_revenue
                                                                                                           /l_plan_txn_prd_amt_tbl_1(k).etc_quantity;
                                                    END IF;
                                                END IF;
                                         END IF;

                                    ELSIF l_rate_based_flag_tbl(kk) = 'Y' AND l_res_rate_based_flag_tbl(kk) = 'Y'
                                          AND l_plan_txn_prd_amt_tbl_1(k).etc_quantity IS NULL THEN

                                        /* Quantity null or nulled out means the bl has to be deletedc */
                                           l_del_bud_line_tbl.extend(1);
                                           l_del_count := l_del_bud_line_tbl.COUNT;
                                           l_del_bud_line_tbl(l_del_count).ra_id := l_ra_id_tbl_1(kk);
                                           l_del_bud_line_tbl(l_del_count).txn_curr_code := l_txn_currency_code_tbl_1(kk);
                                           l_del_bud_line_tbl(l_del_count).period_name := l_plan_txn_prd_amt_tbl_1(k).period_name;

                                    ELSIF l_rate_based_flag_tbl(kk) = 'N' AND l_res_rate_based_flag_tbl(kk) = 'Y'
                                         AND l_set_rbf = 'Y' AND l_plan_txn_prd_amt_tbl_1(k).etc_quantity IS NOT NULL THEN

                                         l_upd_bgt_line_tbl.extend(1);
                                         l_upd_count := l_upd_bgt_line_tbl.COUNT;
                                         l_upd_bgt_line_tbl(l_upd_count).ra_id :=  l_ra_id_tbl_1(kk);
                                         l_upd_bgt_line_tbl(l_upd_count).txn_curr_code := l_txn_currency_code_tbl_1(kk);
                                         l_upd_bgt_line_tbl(l_upd_count).period_name := l_plan_txn_prd_amt_tbl_1(k).period_name;
                                         l_upd_bgt_line_tbl(l_upd_count).disp_quantity := l_plan_txn_prd_amt_tbl_1(k).etc_quantity;
                                         l_upd_bgt_line_tbl(l_upd_count).tot_quantity := l_plan_txn_prd_amt_tbl_1(k).etc_quantity;


                                         IF l_fp_cols_rec.x_version_type = 'COST' OR l_fp_cols_rec.x_version_type = 'ALL' THEN
                                            IF l_plan_txn_prd_amt_tbl_1(k).txn_raw_cost IS NOT NULL THEN
                                               l_upd_bgt_line_tbl(l_upd_count).txn_raw_cost := l_plan_txn_prd_amt_tbl_1(k).txn_raw_cost;
                                               l_upd_bgt_line_tbl(l_upd_count).raw_cost_rate := l_plan_txn_prd_amt_tbl_1(k).txn_raw_cost/l_plan_txn_prd_amt_tbl_1(k).etc_quantity;
                                               IF l_plan_txn_prd_amt_tbl_1(k).txn_burdened_cost IS NOT NULL THEN
                                                  l_upd_bgt_line_tbl(l_upd_count).txn_burdened_cost := l_plan_txn_prd_amt_tbl_1(k).txn_burdened_cost;
                                                  l_upd_bgt_line_tbl(l_upd_count).burdened_cost_rate := l_plan_txn_prd_amt_tbl_1(k).txn_burdened_cost/l_plan_txn_prd_amt_tbl_1(k).etc_quantity;
                                               ELSE
                                                  l_upd_bgt_line_tbl(l_upd_count).txn_burdened_cost := NULL;
                                                  l_upd_bgt_line_tbl(l_upd_count).burdened_cost_rate := 0;
                                               END IF;
                                            ELSIF l_plan_txn_prd_amt_tbl_1(k).txn_burdened_cost IS NOT NULL THEN
                                               l_upd_bgt_line_tbl(l_upd_count).txn_burdened_cost := l_plan_txn_prd_amt_tbl_1(k).txn_burdened_cost;
                                               l_upd_bgt_line_tbl(l_upd_count).burdened_cost_rate := l_plan_txn_prd_amt_tbl_1(k).txn_burdened_cost
                                                                                                    /l_plan_txn_prd_amt_tbl_1(k).etc_quantity;
                                               l_upd_bgt_line_tbl(l_upd_count).txn_raw_cost := l_plan_txn_prd_amt_tbl_1(k).txn_burdened_cost;
                                               l_upd_bgt_line_tbl(l_upd_count).raw_cost_rate := l_upd_bgt_line_tbl(l_upd_count).txn_raw_cost
                                                                                               /l_plan_txn_prd_amt_tbl_1(k).etc_quantity;
                                            ELSE
                                               l_upd_bgt_line_tbl(l_upd_count).txn_raw_cost := NULL;
                                               l_upd_bgt_line_tbl(l_upd_count).raw_cost_rate := 0;
                                               l_upd_bgt_line_tbl(l_upd_count).txn_burdened_cost := NULL;
                                               l_upd_bgt_line_tbl(l_upd_count).burdened_cost_rate := 0;
                                            END IF;
                                         END IF;
                                         IF l_fp_cols_rec.x_version_type = 'REVENUE' OR l_fp_cols_rec.x_version_type = 'ALL' THEN
                                            IF l_plan_txn_prd_amt_tbl_1(k).txn_revenue IS NOT NULL THEN
                                               l_upd_bgt_line_tbl(l_upd_count).txn_revenue := l_plan_txn_prd_amt_tbl_1(k).txn_revenue;
                                               l_upd_bgt_line_tbl(l_upd_count).revenue_bill_rate := l_plan_txn_prd_amt_tbl_1(k).txn_revenue
                                                                                                   /l_plan_txn_prd_amt_tbl_1(k).etc_quantity;
                                            ELSE
                                               l_upd_bgt_line_tbl(l_upd_count).txn_revenue := NULL;
                                               l_upd_bgt_line_tbl(l_upd_count).revenue_bill_rate := 0;
                                            END IF;
                                         END IF;
                                   ELSE

                                           l_upd_bgt_line_tbl.extend(1);
                                           l_upd_count := l_upd_bgt_line_tbl.COUNT;
                                           l_upd_bgt_line_tbl(l_upd_count).ra_id :=  l_ra_id_tbl_1(kk);
                                           l_upd_bgt_line_tbl(l_upd_count).txn_curr_code := l_txn_currency_code_tbl_1(kk);
                                           l_upd_bgt_line_tbl(l_upd_count).period_name := l_plan_txn_prd_amt_tbl_1_bak(j).period_name;
                                           l_upd_bgt_line_tbl(l_upd_count).disp_quantity := NULL;


                                           l_upd_bgt_line_tbl(l_upd_count).txn_raw_cost := l_plan_txn_prd_amt_tbl_1_bak(j).txn_raw_cost;
                                           l_upd_bgt_line_tbl(l_upd_count).txn_burdened_cost := l_plan_txn_prd_amt_tbl_1_bak(j).txn_burdened_cost;
                                           l_upd_bgt_line_tbl(l_upd_count).txn_revenue := l_plan_txn_prd_amt_tbl_1_bak(j).txn_revenue;
                                           l_upd_bgt_line_tbl(l_upd_count).raw_cost_rate := l_ext_raw_cost_rate_tab(j);
                                           l_upd_bgt_line_tbl(l_upd_count).BURDENED_COST_RATE := l_ext_burdened_cost_rate_tab(j);
                                           l_upd_bgt_line_tbl(l_upd_count).REVENUE_BILL_RATE := l_ext_revenue_bill_rate_tab(j);
                                           /* ALL CONDITIONS WOULD FIT HERE */
                                           IF l_fp_cols_rec.x_version_type = 'COST' OR l_fp_cols_rec.x_version_type = 'ALL' THEN
                                              IF l_plan_txn_prd_amt_tbl_1(k).txn_raw_cost IS NOT NULL THEN
                                                 l_upd_bgt_line_tbl(l_upd_count).txn_raw_cost := l_plan_txn_prd_amt_tbl_1(k).txn_raw_cost;
                                                 l_upd_bgt_line_tbl(l_upd_count).tot_quantity := l_plan_txn_prd_amt_tbl_1(k).txn_raw_cost;
                                                 l_upd_bgt_line_tbl(l_upd_count).raw_cost_rate := l_plan_txn_prd_amt_tbl_1(k).txn_raw_cost / l_upd_bgt_line_tbl(l_upd_count).tot_quantity;
                                                 IF l_plan_txn_prd_amt_tbl_1(k).txn_burdened_cost IS NOT NULL THEN
                                                    l_upd_bgt_line_tbl(l_upd_count).txn_burdened_cost := l_plan_txn_prd_amt_tbl_1(k).txn_burdened_cost;
                                                    l_upd_bgt_line_tbl(l_upd_count).BURDENED_COST_RATE := l_upd_bgt_line_tbl(l_upd_count).txn_burdened_cost/ l_upd_bgt_line_tbl(l_upd_count).tot_quantity;
                                                 ELSE
                                                    l_upd_bgt_line_tbl(l_upd_count).txn_burdened_cost := NULL;
                                                    l_upd_bgt_line_tbl(l_upd_count).BURDENED_COST_RATE := 0;
                                                 END IF;
                                              ELSIF l_plan_txn_prd_amt_tbl_1(k).txn_burdened_cost IS NOT NULL THEN
                                                    l_upd_bgt_line_tbl(l_upd_count).txn_burdened_cost := l_plan_txn_prd_amt_tbl_1(k).txn_burdened_cost;
                                                    l_upd_bgt_line_tbl(l_upd_count).tot_quantity := l_plan_txn_prd_amt_tbl_1(k).txn_burdened_cost;
                                                    l_upd_bgt_line_tbl(l_upd_count).BURDENED_COST_RATE := l_upd_bgt_line_tbl(l_upd_count).txn_burdened_cost / l_upd_bgt_line_tbl(l_upd_count).tot_quantity;
                                                    l_upd_bgt_line_tbl(l_upd_count).txn_raw_cost := l_plan_txn_prd_amt_tbl_1(k).txn_burdened_cost;
                                                    l_upd_bgt_line_tbl(l_upd_count).raw_cost_rate := l_upd_bgt_line_tbl(l_upd_count).txn_raw_cost / l_upd_bgt_line_tbl(l_upd_count).tot_quantity;
                                              ELSIF l_fp_cols_rec.x_version_type = 'ALL' AND l_plan_txn_prd_amt_tbl_1(k).txn_revenue IS NOT NULL THEN
                                                    l_upd_bgt_line_tbl(l_upd_count).txn_burdened_cost := NULL;
                                                    l_upd_bgt_line_tbl(l_upd_count).BURDENED_COST_RATE := 0;
                                                    l_upd_bgt_line_tbl(l_upd_count).txn_raw_cost := NULL;
                                                    l_upd_bgt_line_tbl(l_upd_count).raw_cost_rate := 0;
                                                    l_upd_bgt_line_tbl(l_upd_count).txn_revenue := l_plan_txn_prd_amt_tbl_1(k).txn_revenue;
                                                    l_upd_bgt_line_tbl(l_upd_count).tot_quantity := l_plan_txn_prd_amt_tbl_1(k).txn_revenue;
                                                    l_upd_bgt_line_tbl(l_upd_count).raw_cost_rate := l_plan_txn_prd_amt_tbl_1(k).txn_revenue / l_upd_bgt_line_tbl(l_upd_count).tot_quantity;
                                              ELSE
                                                    l_del_bud_line_tbl.extend(1);
                                                    l_del_count := l_del_bud_line_tbl.COUNT;
                                                    l_del_bud_line_tbl(l_del_count).ra_id := l_ra_id_tbl_1(kk);
                                                    l_del_bud_line_tbl(l_del_count).txn_curr_code := l_txn_currency_code_tbl_1(kk);
                                                    l_del_bud_line_tbl(l_del_count).period_name := l_plan_txn_prd_amt_tbl_1(k).period_name;
                                              END IF;
                                           END IF;
                                           IF l_fp_cols_rec.x_version_type = 'REVENUE' OR l_fp_cols_rec.x_version_type = 'ALL' THEN
                                              IF l_plan_txn_prd_amt_tbl_1(k).txn_revenue IS NOT NULL THEN
                                                 IF l_fp_cols_rec.x_version_type = 'REVENUE' THEN
                                                    l_upd_bgt_line_tbl(l_upd_count).txn_revenue := l_plan_txn_prd_amt_tbl_1(k).txn_revenue;
                                                    l_upd_bgt_line_tbl(l_upd_count).tot_quantity := l_plan_txn_prd_amt_tbl_1(k).txn_revenue;
                                                 ELSE
                                                    l_upd_bgt_line_tbl(l_upd_count).txn_revenue := l_plan_txn_prd_amt_tbl_1(k).txn_revenue;
                                                 END IF;
                                                 l_upd_bgt_line_tbl(l_upd_count).REVENUE_BILL_RATE := l_plan_txn_prd_amt_tbl_1(k).txn_revenue / l_upd_bgt_line_tbl(l_upd_count).tot_quantity;
                                              ELSIF l_fp_cols_rec.x_version_type = 'REVENUE' THEN
                                                 l_del_bud_line_tbl.extend(1);
                                                 l_del_count := l_del_bud_line_tbl.COUNT;
                                                 l_del_bud_line_tbl(l_del_count).ra_id := l_ra_id_tbl_1(kk);
                                                 l_del_bud_line_tbl(l_del_count).txn_curr_code := l_txn_currency_code_tbl_1(kk);
                                                 l_del_bud_line_tbl(l_del_count).period_name := l_plan_txn_prd_amt_tbl_1(k).period_name;
                                              ELSE
                                                 l_upd_bgt_line_tbl(l_upd_count).txn_revenue := NULL;
                                                 l_upd_bgt_line_tbl(l_upd_count).REVENUE_BILL_RATE := 0;

                                              END IF;
                                           END IF;
                                    END IF; -- rate based check
                                END IF; -- period line editable.
                         END LOOP; --l_plan_txn_prd_amt_tbl_1 (j)
                      END IF;  -- l_plan_txn_prd_amt_tbl_1 and l_plan_txn_prd_amt_tbl_1_bak count > 0


                     -- if the periodic data has not been modified then use the scalar parameters and call calculate.
                     -- populate the calcuate table
                   ELSIF NVL(l_period_data_modified,'N') = 'N' THEN
                     -- This logic is exactly same as the case when time phasing
                     -- = N condition.. the next else if.. any changes here might have to be done there too..

                            -- first check, if the values passed to the client extn has changed. If there is any change, then
                            -- prepare variables to call calculate.
                            -- first loop through the rate tables to check if any rate has changed by the client extn.
                             l_rate_change_indicator := 'N';
                             IF l_input_period_rates_tbl.COUNT > 0 THEN
                                 FOR r IN l_input_period_rates_tbl.FIRST .. l_input_period_rates_tbl.LAST LOOP
                                     IF l_input_period_rates_tbl(r).period_name = l_period_rates_tbl(r).period_name THEN
                                             IF nvl(l_input_period_rates_tbl(r).raw_cost_rate,l_miss_num) <> nvl(l_period_rates_tbl(r).raw_cost_rate,l_miss_num) OR
                                                nvl(l_input_period_rates_tbl(r).burdened_cost_rate,l_miss_num) <> nvl(l_period_rates_tbl(r).burdened_cost_rate,l_miss_num) OR
                                                nvl(l_input_period_rates_tbl(r).revenue_bill_rate,l_miss_num) <> nvl(l_period_rates_tbl(r).revenue_bill_rate,l_miss_num) THEN
                                                     l_rate_change_indicator := 'Y';
                                                     EXIT;
                                             END IF;
                                     END IF; -- if same period
                                 END LOOP;
                             END IF;
                             --IF l_txn_src_code_tbl(kk) IS NOT NULL AND   Commented for Bug8681973
                             IF l_rate_change_indicator = 'Y' OR
                                nvl(l_etc_qty,l_miss_num) <> nvl(l_fcst_etc_qty,l_miss_num) OR
                                nvl(l_etc_raw_cost,l_miss_num) <> nvl(l_fcst_etc_raw_cost,l_miss_num) OR
                                nvl(l_etc_burdened_cost,l_miss_num) <> nvl(l_fcst_etc_burdened_cost,l_miss_num) OR
                                nvl(l_etc_revenue,l_miss_num) <> nvl(l_fcst_etc_revenue,l_miss_num) THEN
                                    l_call_calculate_flag := 'Y';
                                    l_calc_cur_txn_flag := 'Y';
                                    l_cal_etc_qty_tab.extend(1);
                                    l_cal_etc_raw_cost_tab.extend(1);
                                    l_cal_etc_burdened_cost_tab.extend(1);
                                    l_cal_etc_revenue_tab.extend(1);
                                    l_cal_raid_tab.extend(1);
                                    l_cal_txn_currency_code_tab.extend(1);

                                    l_cal_txn_currency_code_tab(l_cal_txn_currency_code_tab.count) :=  l_txn_currency_code_tbl_1(kk);
                                    l_cal_raid_tab(l_cal_raid_tab.count) := l_ra_id_tbl_1(kk);
                                    IF l_fcst_etc_qty IS NOT NULL THEN
                                        l_cal_etc_qty_tab(l_cal_etc_qty_tab.count) := l_fcst_etc_qty;
                                        -- update the pra table to make it a rate based transaction in case resource rate
                                        --based flag is 'Y' and quantity is passed.
                                        IF l_rate_based_flag_tbl(kk) = 'N' and l_res_rate_based_flag_tbl(kk) = 'Y' THEN
                                             IF l_ra_multi_curr = 'N' THEN
                                                l_upd_rbf_tbl_1.extend(1);
                                                l_upd_rbf_tbl_1(l_upd_rbf_tbl_1.count) := l_ra_id_tbl_1(kk);
                                             END IF;
                                        END IF;
                                    ELSE
                                        l_cal_etc_qty_tab(l_cal_etc_qty_tab.count) := l_etc_qty_tbl_1(kk); /* ETC QTY */
                                    END IF;
                                    l_cal_etc_raw_cost_tab(l_cal_etc_raw_cost_tab.count) := l_fcst_etc_raw_cost; --, 0) + l_init_raw_cost_tbl_1(kk);
                                    l_cal_etc_burdened_cost_tab(l_cal_etc_burdened_cost_tab.count) := l_fcst_etc_burdened_cost;-- + l_init_burd_cost_tbl_1(kk);
                                    l_cal_etc_revenue_tab(l_cal_etc_revenue_tab.count) := l_fcst_etc_revenue;-- + l_init_revenue_tbl_1(kk);

                           END IF; -- something has changed
                    END IF; -- l_period_data_modified

                -- for a non time phased version take the scalar parameters and call calculate.
                -- populate the calcuate table
             ELSIF  l_fp_cols_rec.x_time_phased_code IN ('N') THEN
                     -- This logic is exactly same as the case when periodic data modified = N
                     -- ie., the previous else if.. any changes here might have to be done there too..

                 l_rate_change_indicator := 'N';
                 IF l_input_period_rates_tbl.COUNT > 0 THEN
                     FOR r IN l_input_period_rates_tbl.FIRST .. l_input_period_rates_tbl.LAST LOOP
                             IF nvl(l_input_period_rates_tbl(r).raw_cost_rate,l_miss_num) <> nvl(l_period_rates_tbl(r).raw_cost_rate,l_miss_num) OR
                                nvl(l_input_period_rates_tbl(r).burdened_cost_rate,l_miss_num) <> nvl(l_period_rates_tbl(r).burdened_cost_rate,l_miss_num) OR
                                nvl(l_input_period_rates_tbl(r).revenue_bill_rate,l_miss_num) <> nvl(l_period_rates_tbl(r).revenue_bill_rate,l_miss_num) THEN
                                     l_rate_change_indicator := 'Y';
                                     EXIT;
                             END IF;
                     END LOOP;
                 END IF;
                 --IF l_txn_src_code_tbl(kk) IS NOT NULL AND Commented for Bug8681973
                 IF l_rate_change_indicator = 'Y' OR
                    nvl(l_etc_qty,l_miss_num) <> nvl(l_fcst_etc_qty,l_miss_num) OR
                    nvl(l_etc_raw_cost,l_miss_num) <> nvl(l_fcst_etc_raw_cost,l_miss_num) OR
                    nvl(l_etc_burdened_cost,l_miss_num) <> nvl(l_fcst_etc_burdened_cost,l_miss_num) OR
                    nvl(l_etc_revenue,l_miss_num) <> nvl(l_fcst_etc_revenue,l_miss_num) THEN
                        l_call_calculate_flag := 'Y';
                        l_calc_cur_txn_flag := 'Y';
                        l_cal_etc_qty_tab.extend(1);
                        l_cal_etc_raw_cost_tab.extend(1);
                        l_cal_etc_burdened_cost_tab.extend(1);
                        l_cal_etc_revenue_tab.extend(1);
                        l_cal_raid_tab.extend(1);
                        l_cal_txn_currency_code_tab.extend(1);

                        l_cal_txn_currency_code_tab(l_cal_txn_currency_code_tab.count) :=  l_txn_currency_code_tbl_1(kk);
                        l_cal_raid_tab(l_cal_raid_tab.count) := l_ra_id_tbl_1(kk);

                        IF l_fcst_etc_qty IS NOT NULL THEN
                            l_cal_etc_qty_tab(l_cal_etc_qty_tab.count) := l_fcst_etc_qty;
                            -- update the pra table to make it a rate based transaction in case resource rate
                            --based flag is 'Y' and quantity is passed.
                            IF l_rate_based_flag_tbl(kk) = 'N' and l_res_rate_based_flag_tbl(kk) = 'Y' THEN
                                IF l_ra_multi_curr = 'N' THEN
                                    l_upd_rbf_tbl_1.extend(1);
                                    l_upd_rbf_tbl_1(l_upd_rbf_tbl_1.count) := l_ra_id_tbl_1(kk);
                                END IF;
                            END IF;
                        ELSE
                            l_cal_etc_qty_tab(l_cal_etc_qty_tab.count) := l_etc_qty_tbl_1(kk);
                        END IF;
                        l_cal_etc_raw_cost_tab(l_cal_etc_raw_cost_tab.count) := l_fcst_etc_raw_cost; --, 0) + l_init_raw_cost_tbl_1(kk);
                        l_cal_etc_burdened_cost_tab(l_cal_etc_burdened_cost_tab.count) := l_fcst_etc_burdened_cost;-- + l_init_burd_cost_tbl_1(kk);
                        l_cal_etc_revenue_tab(l_cal_etc_revenue_tab.count) := l_fcst_etc_revenue;-- + l_init_revenue_tbl_1(kk);

                 END IF; -- something has changed
             END IF;--      l_fp_cols_rec.x_time_phased_code

             IF l_calc_cur_txn_flag = 'Y' and l_period_rates_tbl.count > 0 THEN   -- Added and condition for Bug8681973
                FOR j IN l_period_rates_tbl.FIRST..l_period_rates_tbl.LAST LOOP
                    INSERT INTO PA_FP_GEN_RATE_TMP
                                ( TXN_CURRENCY_CODE,
                                  PERIOD_NAME,
                                  RAW_COST_RATE,
                                  BURDENED_COST_RATE,
                                  REVENUE_BILL_RATE
                                )
                    VALUES
                               ( l_txn_currency_code_tbl_1(kk),
                                 l_period_rates_tbl(j).period_name,
                                 l_period_rates_tbl(j).raw_cost_rate,
                                 l_period_rates_tbl(j).burdened_cost_rate,
                                 l_period_rates_tbl(j).revenue_bill_rate
                               );
                END LOOP;
             END IF; -- l_call_calculate_flag = 'Y'

         END LOOP;
     END IF; -- ra_id table count > 0


    -- update the budget lines with the changes values
    IF l_upd_count > 0 THEN

        FOR i in l_upd_bgt_line_tbl.first..l_upd_bgt_line_tbl.last
        LOOP


            UPDATE pa_budget_lines
            SET  txn_raw_cost      = l_upd_bgt_line_tbl(i).txn_raw_cost
                ,txn_revenue       = l_upd_bgt_line_tbl(i).txn_revenue
                ,txn_burdened_cost = l_upd_bgt_line_tbl(i).txn_burdened_cost
                ,display_quantity  = l_upd_bgt_line_tbl(i).disp_quantity
                ,quantity          = l_upd_bgt_line_tbl(i).tot_quantity -- updating total quantity
                ,txn_cost_rate_override  = l_upd_bgt_line_tbl(i).  raw_cost_rate -- updating rates
                ,burden_cost_rate_override = l_upd_bgt_line_tbl(i).burdened_cost_rate -- updating rates
                ,txn_bill_rate_override    = l_upd_bgt_line_tbl(i).revenue_bill_rate -- updating rates
                ,cost_rejection_code = NULL
                ,revenue_rejection_code =NULL
                ,burden_rejection_code = NULL
                ,other_rejection_code = NULL
            WHERE
                resource_assignment_id = l_upd_bgt_line_tbl(i).ra_id
            AND txn_currency_code  =   l_upd_bgt_line_tbl(i).txn_curr_code
            AND period_name  = NVL(l_upd_bgt_line_tbl(i).period_name , period_name);
        END LOOP;
    END IF;



    -- delete the budget lines for the changed amounts.
    IF l_del_count > 0 THEN

        FOR i in l_del_bud_line_tbl.first..l_del_bud_line_tbl.last
        LOOP
            DELETE FROM  pa_budget_lines
            WHERE
            resource_assignment_id = l_del_bud_line_tbl(i).ra_id
            AND txn_currency_code  =   l_del_bud_line_tbl(i).txn_curr_code
            AND period_name  = NVL(l_del_bud_line_tbl(i).period_name , period_name);
        END LOOP;
    END IF;

   --Update the rate_based_flag in pa_resource_assignments.
     IF l_upd_rbf_tbl.COUNT > 0 THEN

        FOR upd IN l_upd_rbf_tbl.FIRST..l_upd_rbf_tbl.LAST LOOP
           UPDATE pa_resource_assignments
           SET    rate_based_flag = 'Y'
           WHERE  resource_assignment_id = l_upd_rbf_tbl(upd).ra_id;
        END LOOP;
     END IF;

    -- call calculate in case required







   IF  NVL(l_call_calculate_flag,'N')  = 'Y' THEN


        IF l_upd_rbf_tbl_1.count > 0 THEN

            FORALL upd IN 1..l_upd_rbf_tbl_1.COUNT
               UPDATE pa_resource_assignments
               SET    rate_based_flag = 'Y'
               WHERE  resource_assignment_id = l_upd_rbf_tbl_1(upd);
        END IF;

          --For Bug 6722414
         pa_fp_calc_plan_pkg.g_from_etc_client_extn_flag := 'Y';

          PA_FP_CALC_PLAN_PKG.calculate(
          p_calling_module                => 'FORECAST_GENERATION'
         ,p_project_id                    => p_project_id
         ,p_budget_version_id             => p_budget_version_id
         ,P_REFRESH_RATES_FLAG            => 'N'
         ,P_REFRESH_CONV_RATES_FLAG       => 'N'
         ,P_SPREAD_REQUIRED_FLAG          => 'Y'
         ,P_CONV_RATES_REQUIRED_FLAG      => 'N'
         ,p_rollup_required_flag          => 'N'
         ,p_source_context                => 'RESOURCE_ASSIGNMENT'
         ,p_resource_assignment_tab       => l_cal_raid_tab
         ,p_txn_currency_code_tab         => l_cal_txn_currency_code_tab
         ,p_total_qty_tab                 => l_cal_etc_qty_tab
         ,p_total_raw_cost_tab            => l_cal_etc_raw_cost_tab
         ,p_total_burdened_cost_tab       => l_cal_etc_burdened_cost_tab
         ,p_total_revenue_tab             => l_cal_etc_revenue_tab
         ,p_raTxn_rollup_api_call_flag    => 'N'
         ,x_return_status                 => x_return_status
         ,x_msg_count                     => l_msg_count
         ,x_msg_data                      => l_msg_data);

        --For Bug 6722414
         pa_fp_calc_plan_pkg.g_from_etc_client_extn_flag := 'N';

        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG           =>
                'After calling PA_FP_CALC_PLAN_PKG.calculate '
                                ||x_return_status,
                P_MODULE_NAME   => l_module_name);
        END IF;
        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
    END IF;

/* -- ER 5726773: Commenting out call to CheckZeroQTyNegETC.
   -- The api has been removed and should no longer be called.

   IF  NVL(l_call_calculate_flag,'N')  = 'N' THEN

         DELETE FROM pa_fp_spread_calc_tmp;

         FORALL kk IN 1..l_ra_id_tbl_1.COUNT
            INSERT INTO pa_fp_spread_calc_tmp
            (budget_version_id,
             resource_assignment_id)
            VALUES
            (p_budget_version_id,
             l_ra_id_tbl_1(kk));

         PA_FP_CALC_PLAN_PKG.CheckZeroQTyNegETC
         (p_budget_version_id     => p_budget_version_id
         ,p_initialize            => 'Y'
         ,x_return_status         => x_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data);
   END IF;

   -- End Comment 5726773
*/
   IF l_call_calculate_flag = 'N' and l_upd_count = 0 and l_del_count = 0 THEN
     x_call_maintain_data_api := 'N';
   END IF;
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG           =>
                'After calling PA_FP_CALC_PLAN_PKG.CheckZeroQTyNegETC '
                                ||x_return_status,
                P_MODULE_NAME   => l_module_name);
        END IF;
        IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
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
    WHEN OTHERS THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(sqlerrm,1,240);
        FND_MSG_PUB.ADD_EXC_MSG
                   ( p_pkg_name        => 'PA_FP_GEN_FCST_AMT_PUB1',
                     p_procedure_name  => 'call_clnt_extn_and_update_bl',
                     p_error_text      => substr(sqlerrm,1,240));

        IF p_pa_debug_mode = 'Y' THEN
           PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
             p_module_name => l_module_name,
             p_log_level   => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END call_clnt_extn_and_update_bl;


END PA_FP_GEN_FCST_AMT_PUB1;

/
