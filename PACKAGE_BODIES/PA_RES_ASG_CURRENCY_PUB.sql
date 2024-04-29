--------------------------------------------------------
--  DDL for Package Body PA_RES_ASG_CURRENCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RES_ASG_CURRENCY_PUB" as
/* $Header: PAFPRBCB.pls 120.1.12010000.4 2009/07/28 05:45:50 kkorada ship $ */
P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

-- Private P_CALLING_MODULE values
G_PVT_MAINTAIN                 CONSTANT VARCHAR2(30) := 'MAINTAIN_DATA';
G_PVT_DELETE                   CONSTANT VARCHAR2(30) := 'DELETE_TABLE_RECORDS';
G_PVT_COPY                     CONSTANT VARCHAR2(30) := 'COPY_TABLE_RECORDS';
G_PVT_INSERT                   CONSTANT VARCHAR2(30) := 'INSERT_TABLE_RECORDS';
G_PVT_ROLLUP                   CONSTANT VARCHAR2(30) := 'ROLLUP_AMOUNTS';

--------------------------------------
--------- Local Functions  -----------
--------------------------------------

FUNCTION IS_PUBLIC_CALLING_MODULE
       ( P_CALLING_MODULE IN VARCHAR2 ) RETURN BOOLEAN
IS
BEGIN
    RETURN p_calling_module IS NOT NULL AND
           p_calling_module IN
         ( G_BUDGET_GENERATION,
           G_FORECAST_GENERATION,
           G_CALCULATE_API,
           G_UPDATE_PLAN_TRANSACTION,
           G_WORKPLAN,
           G_AMG_API,
           G_WEBADI,
           G_CHANGE_MGT,
           G_COPY_PLAN,
           G_UPGRADE );
END IS_PUBLIC_CALLING_MODULE;

FUNCTION IS_PRIVATE_CALLING_MODULE
       ( P_CALLING_MODULE IN VARCHAR2 ) RETURN BOOLEAN
IS
BEGIN
    RETURN p_calling_module IS NOT NULL AND
           p_calling_module IN
         ( G_PVT_MAINTAIN,
           G_PVT_DELETE,
           G_PVT_COPY,
           G_PVT_INSERT,
           G_PVT_ROLLUP );
END IS_PRIVATE_CALLING_MODULE;

FUNCTION IS_VALID_COPY_MODE
       ( P_COPY_MODE IN VARCHAR2 ) RETURN BOOLEAN
IS
BEGIN
    RETURN p_copy_mode IS NOT NULL AND
           p_copy_mode IN
         ( G_COPY_ALL,
           G_COPY_OVERRIDES );
END IS_VALID_COPY_MODE;

FUNCTION IS_VALID_FLAG
       ( P_FLAG IN VARCHAR2 ) RETURN BOOLEAN
IS
BEGIN
    RETURN (p_flag IS NOT NULL) AND (p_flag IN ('Y','N'));
END IS_VALID_FLAG;

-----------------------------------------------------------------------
--------- Forward declarations for local/private procedures -----------
-----------------------------------------------------------------------

PROCEDURE PRINT_INPUT_PARAMS
       ( P_CALLING_API                  IN           VARCHAR2 DEFAULT NULL,
         P_FP_COLS_REC                  IN           PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
         P_CALLING_MODULE               IN           VARCHAR2 DEFAULT NULL,
         P_DELETE_FLAG                  IN           VARCHAR2 DEFAULT NULL,
         P_COPY_FLAG                    IN           VARCHAR2 DEFAULT NULL,
         P_SRC_VERSION_ID               IN           PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE DEFAULT NULL,
         P_COPY_MODE                    IN           VARCHAR2 DEFAULT NULL,
         P_ROLLUP_FLAG                  IN           VARCHAR2 DEFAULT NULL,
         P_VERSION_LEVEL_FLAG           IN           VARCHAR2 DEFAULT NULL,
         P_CALLED_MODE                  IN           VARCHAR2 DEFAULT NULL );

PROCEDURE DELETE_TABLE_RECORDS
        ( P_FP_COLS_REC                  IN           PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
          P_CALLING_MODULE               IN           VARCHAR2,
          P_VERSION_LEVEL_FLAG           IN           VARCHAR2 DEFAULT 'N',
          P_CALLED_MODE                  IN           VARCHAR2 DEFAULT 'SELF_SERVICE',
          X_RETURN_STATUS                OUT NOCOPY   VARCHAR2,
          X_MSG_COUNT                    OUT NOCOPY   NUMBER,
          X_MSG_DATA                     OUT NOCOPY   VARCHAR2);

PROCEDURE COPY_TABLE_RECORDS
        ( P_FP_COLS_REC                  IN           PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
          P_SRC_VERSION_ID               IN           PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE DEFAULT NULL,
          P_COPY_MODE                    IN           VARCHAR2 DEFAULT 'COPY_OVERRIDES',
          P_CALLING_MODULE               IN           VARCHAR2,
          P_VERSION_LEVEL_FLAG           IN           VARCHAR2 DEFAULT 'N',
          P_CALLED_MODE                  IN           VARCHAR2 DEFAULT 'SELF_SERVICE',
          X_RETURN_STATUS                OUT NOCOPY   VARCHAR2,
          X_MSG_COUNT                    OUT NOCOPY   NUMBER,
          X_MSG_DATA                     OUT NOCOPY   VARCHAR2);

PROCEDURE INSERT_TABLE_RECORDS
        ( P_FP_COLS_REC                  IN           PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
          P_CALLING_MODULE               IN           VARCHAR2,
          P_VERSION_LEVEL_FLAG           IN           VARCHAR2 DEFAULT 'N',
          P_CALLED_MODE                  IN           VARCHAR2 DEFAULT 'SELF_SERVICE',
          X_RETURN_STATUS                OUT NOCOPY   VARCHAR2,
          X_MSG_COUNT                    OUT NOCOPY   NUMBER,
          X_MSG_DATA                     OUT NOCOPY   VARCHAR2);

PROCEDURE ROLLUP_AMOUNTS
        ( P_FP_COLS_REC                  IN           PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
          P_CALLING_MODULE               IN           VARCHAR2,
          P_VERSION_LEVEL_FLAG           IN           VARCHAR2 DEFAULT 'N',
          P_CALLED_MODE                  IN           VARCHAR2 DEFAULT 'SELF_SERVICE',
          X_RETURN_STATUS                OUT NOCOPY   VARCHAR2,
          X_MSG_COUNT                    OUT NOCOPY   NUMBER,
          X_MSG_DATA                     OUT NOCOPY   VARCHAR2);

------------------------------------------------------------------------------
--------- END OF Forward declarations for local/private procedures -----------
------------------------------------------------------------------------------

----------------------------------------
--------- Public Procedures ------------
----------------------------------------

PROCEDURE MAINTAIN_DATA
        ( P_FP_COLS_REC                  IN           PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
          P_CALLING_MODULE               IN           VARCHAR2,
          P_DELETE_FLAG                  IN           VARCHAR2,
          P_COPY_FLAG                    IN           VARCHAR2,
          P_SRC_VERSION_ID               IN           PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
          P_COPY_MODE                    IN           VARCHAR2,
          P_ROLLUP_FLAG                  IN           VARCHAR2,
          P_VERSION_LEVEL_FLAG           IN           VARCHAR2,
          P_CALLED_MODE                  IN           VARCHAR2,
          X_RETURN_STATUS                OUT NOCOPY   VARCHAR2,
          X_MSG_COUNT                    OUT NOCOPY   NUMBER,
          X_MSG_DATA                     OUT NOCOPY   VARCHAR2 )
IS
    l_module_name                  VARCHAR2(100) := 'pa.plsql.PA_RES_ASG_CURRENCY_PUB.MAINTAIN_DATA';
    l_log_level                    NUMBER := 5;

    l_msg_count                    NUMBER;
    l_data                         VARCHAR2(2000);
    l_msg_data                     VARCHAR2(2000);
    l_msg_index_out                NUMBER;

    l_parameters_valid_flag        VARCHAR2(1);

    l_ra_id_tab                    PA_PLSQL_DATATYPES.IdTabTyp;
    l_txn_currency_code_tab        PA_PLSQL_DATATYPES.Char15TabTyp;
    l_duplicate_count_tab          PA_PLSQL_DATATYPES.IdTabTyp;
    l_null_record_count            NUMBER;

BEGIN
    IF p_pa_debug_mode = 'Y' THEN
        pa_debug.set_curr_function
            ( p_function   => 'MAINTAIN_DATA',
              p_debug_mode => p_pa_debug_mode );
    END IF;

    PA_RES_ASG_CURRENCY_PUB.PRINT_INPUT_PARAMS
        ( P_CALLING_API           => G_PVT_MAINTAIN,
          P_FP_COLS_REC           => p_fp_cols_rec,
          P_CALLING_MODULE        => p_calling_module,
          P_DELETE_FLAG           => p_delete_flag,
          P_COPY_FLAG             => p_copy_flag,
          P_SRC_VERSION_ID        => p_src_version_id,
          P_COPY_MODE             => p_copy_mode,
          P_ROLLUP_FLAG           => p_rollup_flag,
          P_VERSION_LEVEL_FLAG    => p_version_level_flag,
          P_CALLED_MODE           => p_called_mode );

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;

    -- Step 0: Validate Input Parameters

    l_parameters_valid_flag := 'Y';

    IF p_fp_cols_rec.x_budget_version_id IS NULL THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( P_MSG          => 'P_fp_cols_rec.x_budget_version_id should not be null.',
                  P_CALLED_MODE  => p_called_mode,
                  P_MODULE_NAME  => l_module_name,
                  P_LOG_LEVEL    => l_log_level );
        END IF;
        l_parameters_valid_flag := 'N';
    END IF; -- minimum p_fp_cols_rec validation

    IF NOT is_public_calling_module(p_calling_module) THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( P_MSG          => 'Invalid p_calling_module value: '
                                    || p_calling_module,
                  P_CALLED_MODE  => p_called_mode,
                  P_MODULE_NAME  => l_module_name,
                  P_LOG_LEVEL    => l_log_level );
        END IF;
        l_parameters_valid_flag := 'N';
    END IF; -- p_calling_module validation

    IF NOT is_valid_flag(p_delete_flag) THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( P_MSG          => 'Invalid p_delete_flag value: '
                                    || p_delete_flag,
                  P_CALLED_MODE  => p_called_mode,
                  P_MODULE_NAME  => l_module_name,
                  P_LOG_LEVEL    => l_log_level );
        END IF;
        l_parameters_valid_flag := 'N';
    END IF; -- p_delete_flag validation

    IF NOT is_valid_flag(p_copy_flag) THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( P_MSG          => 'Invalid p_copy_flag value: '
                                    || p_copy_flag,
                  P_CALLED_MODE  => p_called_mode,
                  P_MODULE_NAME  => l_module_name,
                  P_LOG_LEVEL    => l_log_level );
        END IF;
        l_parameters_valid_flag := 'N';
    END IF; -- p_copy_flag validation

    IF p_copy_flag = 'Y' AND
       p_src_version_id IS NULL THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( P_MSG          => 'Since p_copy_flag is Y, p_src_version_id cannot be Null',
                  P_CALLED_MODE  => p_called_mode,
                  P_MODULE_NAME  => l_module_name,
                  P_LOG_LEVEL    => l_log_level );
        END IF;
        l_parameters_valid_flag := 'N';
    END IF; -- p_src_version_id validation

    IF p_copy_flag = 'Y' AND
       NOT IS_VALID_COPY_MODE(p_copy_mode) THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( P_MSG          => 'Since p_copy_flag is Y, invalid p_copy_mode value: '
                                    || p_copy_mode,
                  P_CALLED_MODE  => p_called_mode,
                  P_MODULE_NAME  => l_module_name,
                  P_LOG_LEVEL    => l_log_level );
        END IF;
        l_parameters_valid_flag := 'N';
    END IF; -- p_copy_flag validation

    IF NOT is_valid_flag(p_rollup_flag) THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( P_MSG          => 'Invalid p_rollup_flag value: '
                                    || p_rollup_flag,
                  P_CALLED_MODE  => p_called_mode,
                  P_MODULE_NAME  => l_module_name,
                  P_LOG_LEVEL    => l_log_level );
        END IF;
        l_parameters_valid_flag := 'N';
    END IF; -- p_rollup_flag validation

    IF NOT is_valid_flag(p_version_level_flag) THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( P_MSG          => 'Invalid p_version_level_flag value: '
                                    || p_version_level_flag,
                  P_CALLED_MODE  => p_called_mode,
                  P_MODULE_NAME  => l_module_name,
                  P_LOG_LEVEL    => l_log_level );
        END IF;
        l_parameters_valid_flag := 'N';
    END IF; -- p_version_level_flag validation

    -- Now that we have checked all of the input parameters,
    -- raise an error if any of the parameters was invalid.
    IF l_parameters_valid_flag = 'N' THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

     -- Step 1: Handle Deletion
    IF p_delete_flag = 'Y' THEN

        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG                   => 'Before calling PA_RES_ASG_CURRENCY_PUB.' ||
                                           'DELETE_TABLE_RECORDS',
                P_CALLED_MODE           => p_called_mode,
                P_MODULE_NAME           => l_module_name);
        END IF;
        PA_RES_ASG_CURRENCY_PUB.DELETE_TABLE_RECORDS
              ( P_FP_COLS_REC           => p_fp_cols_rec,
                P_CALLING_MODULE        => p_calling_module,
                P_VERSION_LEVEL_FLAG    => p_version_level_flag,
                P_CALLED_MODE           => p_called_mode,
                X_RETURN_STATUS         => x_return_status,
                X_MSG_COUNT             => x_msg_count,
                X_MSG_DATA              => x_msg_data );
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG                   => 'After calling PA_RES_ASG_CURRENCY_PUB.' ||
                                           'DELETE_TABLE_RECORDS: '||x_return_status,
                P_CALLED_MODE           => p_called_mode,
                P_MODULE_NAME           => l_module_name);
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;

        -- Return control to caller.
        RETURN;
    END IF; -- p_delete_flag = 'Y'

    -- Step 0 (CONTD): Additional Temp Mode Validation
    -- When processing non-delete operations in Temp Table Mode,
    -- the following validation rules apply to temp table data:
    -- 1.  delete_flag should not be 'Y'.
    --     Remove such records from the temp table.
    -- 2A. Whenever copy_flag = 'Y'
    --     (resource_assignment_id) must be unique.
    --     Raise an error if duplicates are found.
    -- 2B. Whenever copy_flag <> 'Y'
    --     (resource_assignment_id, txn_currency_code) must be unique.
    --     Raise an error if duplicates are found.
    -- 3.  (resource_assignment_id) should never be null.
    --     Raise an error if any records with null resource_assignment_id are found.
    -- 4.  Whenever copy_flag <> 'Y',
    --     txn_currency_code should not be null.
    --     Raise an error if any records with null resource_assignment_id are found.


    IF p_version_level_flag = 'N' THEN

        -- 0.1. Remove records with delete_flag = 'Y' from temp table.
        DELETE FROM pa_resource_asgn_curr_tmp
        WHERE  NVL(delete_flag,'N') = 'Y';

        IF p_copy_flag = 'Y' THEN
            -- 0.2A. Validate that no records in the temp table share the same
            -- resource_assignment_id. When the context is Copy, currency
            -- code is not populated in the temp table.
            SELECT resource_assignment_id,
                   NULL,
                   count(*)
            BULK COLLECT
            INTO   l_ra_id_tab,
                   l_txn_currency_code_tab,
                   l_duplicate_count_tab
            FROM   pa_resource_asgn_curr_tmp
            GROUP BY resource_assignment_id
            HAVING count(*) > 1;
        ELSE
            -- 0.2B. Validate that no records in the temp table share the same
            -- (resource_assignment_id, txn_currency_code) combination.
            SELECT resource_assignment_id,
                   txn_currency_code,
                   count(*)
            BULK COLLECT
            INTO   l_ra_id_tab,
                   l_txn_currency_code_tab,
                   l_duplicate_count_tab
            FROM   pa_resource_asgn_curr_tmp
            GROUP BY resource_assignment_id, txn_currency_code
            HAVING count(*) > 1;
        END IF; -- IF p_copy_flag = 'Y' THEN

        -- Raise an error if duplicates are found.
        IF l_ra_id_tab.count > 0 THEN
            IF p_pa_debug_mode = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                    ( p_msg          => 'Duplicate records found in '
                                        || 'PA_RESOURCE_ASGN_CURR_TMP '
                                        || '(count='||l_ra_id_tab.count||'):',
                      p_called_mode  => p_called_mode,
                      p_module_name  => l_module_name,
                      p_log_level    => l_log_level );
                FOR i IN 1..l_ra_id_tab.count LOOP
                    PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                        ( p_msg         => 'Record'||i||': '
                                           || 'resource_assignment_id:['||l_ra_id_tab(i)||'], '
                                           || 'txn_currency_code:['||l_txn_currency_code_tab(i)||'], '
                                           || 'number_of_duplicates:['||l_duplicate_count_tab(i)||'] ',
                          p_called_mode  => p_called_mode,
                          p_module_name  => l_module_name,
                          p_log_level    => l_log_level );
                END LOOP;
            END IF; -- debug mode logic
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF; -- duplicate record check

        -- 0.3. Raise an error if any records with null resource_assignment_id are found.
        SELECT count(*)
        INTO   l_null_record_count
        FROM   pa_resource_asgn_curr_tmp
        WHERE  resource_assignment_id IS NULL;

        IF l_null_record_count > 0 THEN
            IF p_pa_debug_mode = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                    ( p_msg          => 'Records with null resource_assignment_id found in '
                                        || 'PA_RESOURCE_ASGN_CURR_TMP '
                                        || '(count='||l_null_record_count||'):',
                      p_called_mode  => p_called_mode,
                      p_module_name  => l_module_name,
                      p_log_level    => l_log_level );
            END IF;
            --PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
            --                      p_msg_name       => 'PA_RBC_RA_ID_NULL_ERR' );
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF; -- IF l_null_record_count > 0 THEN

        -- 0.4. Whenever copy_flag <> 'Y', txn_currency_code should not be null.
        --      Raise an error if any records with null resource_assignment_id are found.
        IF p_copy_flag <> 'Y' THEN
            SELECT count(*)
            INTO   l_null_record_count
            FROM   pa_resource_asgn_curr_tmp
            WHERE  txn_currency_code IS NULL;

            IF l_null_record_count > 0 THEN
                IF p_pa_debug_mode = 'Y' THEN
                    PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                        ( p_msg          => 'Records with null txn_currency_code found in '
                                            || 'PA_RESOURCE_ASGN_CURR_TMP '
                                            || '(count='||l_null_record_count||'):',
                          p_called_mode  => p_called_mode,
                          p_module_name  => l_module_name,
                          p_log_level    => l_log_level );
                END IF;
                --PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                --                      p_msg_name       => 'PA_RBC_TXN_CUR_NULL_ERR' );
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF; -- IF l_null_record_count > 0 THEN
        END IF; --IF p_copy_flag = 'Y' THEN

    END IF; -- additional Table Mode validation


    -- Step 2: Handle Copy
    IF p_copy_flag = 'Y' THEN

        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG                   => 'Before calling PA_RES_ASG_CURRENCY_PUB.' ||
                                           'COPY_TABLE_RECORDS',
                P_CALLED_MODE           => p_called_mode,
                P_MODULE_NAME           => l_module_name);
        END IF;
        PA_RES_ASG_CURRENCY_PUB.COPY_TABLE_RECORDS
              ( P_FP_COLS_REC           => p_fp_cols_rec,
                P_SRC_VERSION_ID        => p_src_version_id,
                P_COPY_MODE             => p_copy_mode,
                P_CALLING_MODULE        => p_calling_module,
                P_VERSION_LEVEL_FLAG    => p_version_level_flag,
                P_CALLED_MODE           => p_called_mode,
                X_RETURN_STATUS         => x_return_status,
                X_MSG_COUNT             => x_msg_count,
                X_MSG_DATA              => x_msg_data );
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG                   => 'After calling PA_RES_ASG_CURRENCY_PUB.' ||
                                           'COPY_TABLE_RECORDS: '||x_return_status,
                P_CALLED_MODE           => p_called_mode,
                P_MODULE_NAME           => l_module_name);
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;

        -- Return control to caller.
        RETURN;
    END IF; -- p_copy_flag = 'Y'


    -- Step 3: Handle Insertion
    IF p_rollup_flag = 'N' THEN

        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG                   => 'Before calling PA_RES_ASG_CURRENCY_PUB.' ||
                                           'INSERT_TABLE_RECORDS',
                P_CALLED_MODE           => p_called_mode,
                P_MODULE_NAME           => l_module_name);
        END IF;
        PA_RES_ASG_CURRENCY_PUB.INSERT_TABLE_RECORDS
              ( P_FP_COLS_REC           => p_fp_cols_rec,
                P_CALLING_MODULE        => p_calling_module,
                P_VERSION_LEVEL_FLAG    => p_version_level_flag,
                P_CALLED_MODE           => p_called_mode,
                X_RETURN_STATUS         => x_return_status,
                X_MSG_COUNT             => x_msg_count,
                X_MSG_DATA              => x_msg_data );
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG                   => 'After calling PA_RES_ASG_CURRENCY_PUB.' ||
                                           'INSERT_TABLE_RECORDS: '||x_return_status,
                P_CALLED_MODE           => p_called_mode,
                P_MODULE_NAME           => l_module_name);
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

    -- Step 4: Handle Rollup of Amounts
    ELSIF p_rollup_flag = 'Y' THEN

        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG                   => 'Before calling PA_RES_ASG_CURRENCY_PUB.' ||
                                           'ROLLUP_AMOUNTS',
                P_CALLED_MODE           => p_called_mode,
                P_MODULE_NAME           => l_module_name);
        END IF;

        PA_RES_ASG_CURRENCY_PUB.ROLLUP_AMOUNTS
              ( P_FP_COLS_REC           => p_fp_cols_rec,
                P_CALLING_MODULE        => p_calling_module,
                P_VERSION_LEVEL_FLAG    => p_version_level_flag,
                P_CALLED_MODE           => p_called_mode,
                X_RETURN_STATUS         => x_return_status,
                X_MSG_COUNT             => x_msg_count,
                X_MSG_DATA              => x_msg_data );
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
                P_MSG                   => 'After calling PA_RES_ASG_CURRENCY_PUB.' ||
                                           'ROLLUP_AMOUNTS: '||x_return_status,
                P_CALLED_MODE           => p_called_mode,
                P_MODULE_NAME           => l_module_name);
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

    END IF; -- p_rollup_flag = 'Y'


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

        -- Removed ROLLBACK statement.

        x_return_status := FND_API.G_RET_STS_ERROR;

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_msg         => 'Invalid Arguments Passed',
                  p_called_mode => p_called_mode,
                  p_module_name => l_module_name,
                  p_log_level   => l_log_level );
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;

        -- Removed RAISE statement.

    WHEN OTHERS THEN
        -- Removed ROLLBACK statement.
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(sqlerrm,1,240);
        -- dbms_output.put_line('error msg :'||x_msg_data);
        FND_MSG_PUB.add_exc_msg
            ( p_pkg_name        => 'PA_RES_ASG_CURRENCY_PUB',
              p_procedure_name  => 'MAINTAIN_DATA',
              p_error_text      => substr(sqlerrm,1,240));
        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                  p_called_mode => p_called_mode,
                  p_module_name => l_module_name,
                  p_log_level   => l_log_level);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END MAINTAIN_DATA;


-----------------------------------------
--------- Private Procedures ------------
-----------------------------------------

PROCEDURE PRINT_INPUT_PARAMS
        ( P_CALLING_API                  IN           VARCHAR2,
          P_FP_COLS_REC                  IN           PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
          P_CALLING_MODULE               IN           VARCHAR2,
          P_DELETE_FLAG                  IN           VARCHAR2,
          P_COPY_FLAG                    IN           VARCHAR2,
          P_SRC_VERSION_ID               IN           PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
          P_COPY_MODE                    IN           VARCHAR2,
          P_ROLLUP_FLAG                  IN           VARCHAR2,
          P_VERSION_LEVEL_FLAG           IN           VARCHAR2,
          P_CALLED_MODE                  IN           VARCHAR2 )
IS
    l_module_name                  VARCHAR2(100) := 'pa.plsql.PA_RES_ASG_CURRENCY_PUB.PRINT_INPUT_PARAMS';
    l_log_level                    NUMBER := 5;
BEGIN
    IF p_pa_debug_mode = 'N' THEN
        RETURN;
    END IF; -- IF p_pa_debug_mode = 'N' THEN

     -- Print values of Input Parameters based on p_calling_module
    PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
        ( p_msg         => 'Input Parameters to '
                           || p_calling_api || '():',
          p_called_mode => p_called_mode,
          p_module_name => l_module_name,
          p_log_level   => l_log_level );
    PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
        ( p_msg         => 'P_FP_COLS_REC.X_BUDGET_VERSION_ID:['
                           || P_FP_COLS_REC.X_BUDGET_VERSION_ID||']',
          p_called_mode => p_called_mode,
          p_module_name => l_module_name,
          p_log_level   => l_log_level );
    PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
        ( p_msg         => 'P_FP_COLS_REC.X_VERSION_TYPE:['
                           || P_FP_COLS_REC.X_VERSION_TYPE||']',
          p_called_mode => p_called_mode,
          p_module_name => l_module_name,
          p_log_level   => l_log_level );
    PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
        ( p_msg         => 'P_FP_COLS_REC.X_PLAN_CLASS_CODE:['
                           || P_FP_COLS_REC.X_PLAN_CLASS_CODE||']',
          p_called_mode => p_called_mode,
          p_module_name => l_module_name,
          p_log_level   => l_log_level );
    PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
        ( p_msg         => 'P_CALLING_MODULE:['||P_CALLING_MODULE||']',
          p_called_mode => p_called_mode,
          p_module_name => l_module_name,
          p_log_level   => l_log_level );

    IF p_calling_api = G_PVT_MAINTAIN THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'P_DELETE_FLAG:['||P_DELETE_FLAG||']',
              p_called_mode => p_called_mode,
              p_module_name => l_module_name,
              p_log_level   => l_log_level );
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'P_COPY_FLAG:['||P_COPY_FLAG||']',
              p_called_mode => p_called_mode,
              p_module_name => l_module_name,
              p_log_level   => l_log_level );
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'P_ROLLUP_FLAG:['||P_ROLLUP_FLAG||']',
              p_called_mode => p_called_mode,
              p_module_name => l_module_name,
              p_log_level   => l_log_level );
    END IF; -- IF p_calling_api = G_PVT_MAINTAIN THEN

    IF p_calling_api IN ( G_PVT_MAINTAIN, G_PVT_COPY ) THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'P_SRC_VERSION_ID:['||P_SRC_VERSION_ID||']',
              p_called_mode => p_called_mode,
              p_module_name => l_module_name,
              p_log_level   => l_log_level );
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'P_COPY_MODE:['||P_COPY_MODE||']',
              p_called_mode => p_called_mode,
              p_module_name => l_module_name,
              p_log_level   => l_log_level );
    END IF; --IF p_calling_api IN ( G_PVT_MAINTAIN, G_PVT_COPY ) THEN

    PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
        ( p_msg         => 'P_VERSION_LEVEL_FLAG:['||P_VERSION_LEVEL_FLAG||']',
          p_called_mode => p_called_mode,
          p_module_name => l_module_name,
          p_log_level   => l_log_level );
    PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
        ( p_msg         => 'P_CALLED_MODE:['||P_CALLED_MODE||']',
          p_called_mode => p_called_mode,
          p_module_name => l_module_name,
          p_log_level   => l_log_level );


    -- Print PA_RESOURCE_ASGN_CURR_TMP data
    IF p_version_level_flag = 'N' THEN
        -- Print values of PA_RESOURCE_ASGN_CURR_TMP data
        DECLARE
            l_dbg_ra_id_tab                PA_PLSQL_DATATYPES.IdTabTyp;
            l_dbg_txn_currency_code_tab    PA_PLSQL_DATATYPES.Char15TabTyp;
            l_dbg_rc_rate_override_tab     PA_PLSQL_DATATYPES.NumTabTyp;
            l_dbg_bc_rate_override_tab     PA_PLSQL_DATATYPES.NumTabTyp;
            l_dbg_bill_rate_override_tab   PA_PLSQL_DATATYPES.NumTabTyp;
            l_dbg_delete_flag_tab          PA_PLSQL_DATATYPES.Char1TabTyp;
        BEGIN
            SELECT resource_assignment_id,
                   txn_currency_code,
                   txn_raw_cost_rate_override,
                   txn_burden_cost_rate_override,
                   txn_bill_rate_override,
                   delete_flag
            BULK COLLECT
            INTO   l_dbg_ra_id_tab,
                   l_dbg_txn_currency_code_tab,
                   l_dbg_rc_rate_override_tab,
                   l_dbg_bc_rate_override_tab,
                   l_dbg_bill_rate_override_tab,
                   l_dbg_delete_flag_tab
            FROM   pa_resource_asgn_curr_tmp
            ORDER BY resource_assignment_id, txn_currency_code;

            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( p_msg         => 'Printing PA_RESOURCE_ASGN_CURR_TMP table data '
                                   || '(count='||l_dbg_ra_id_tab.count||'):',
                  p_called_mode => p_called_mode,
                  p_module_name => l_module_name,
                  p_log_level   => l_log_level );

            FOR i IN 1..l_dbg_ra_id_tab.count LOOP
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                    ( p_msg         => 'Record'||i||': '
                                       || 'resource_assignment_id:['||l_dbg_ra_id_tab(i)||'], '
                                       || 'txn_currency_code:['||l_dbg_txn_currency_code_tab(i)||'], '
                                       || 'txn_raw_cost_rate_override:['||l_dbg_rc_rate_override_tab(i)||'], '
                                       || 'txn_burden_cost_rate_override:['||l_dbg_bc_rate_override_tab(i)||'], '
                                       || 'txn_bill_rate_override:['||l_dbg_bill_rate_override_tab(i)||'], '
                                       || 'delete_flag:['||l_dbg_delete_flag_tab(i)||']',
                      p_called_mode => p_called_mode,
                      p_module_name => l_module_name,
                      p_log_level   => l_log_level );
            END LOOP; -- FOR i IN 1..l_dbg_ra_id_tab.count LOOP
        END; -- internal begin/end block
    END IF; --IF p_version_level_flag = 'N' THEN

END PRINT_INPUT_PARAMS;


PROCEDURE DELETE_TABLE_RECORDS
        ( P_FP_COLS_REC                  IN           PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
          P_CALLING_MODULE               IN           VARCHAR2,
          P_VERSION_LEVEL_FLAG           IN           VARCHAR2,
          P_CALLED_MODE                  IN           VARCHAR2,
          X_RETURN_STATUS                OUT NOCOPY   VARCHAR2,
          X_MSG_COUNT                    OUT NOCOPY   NUMBER,
          X_MSG_DATA                     OUT NOCOPY   VARCHAR2)
IS
    l_module_name                  VARCHAR2(100) := 'pa.plsql.PA_RES_ASG_CURRENCY_PUB.DELETE_TABLE_RECORDS';
    l_log_level                    NUMBER := 5;

    l_msg_count                    NUMBER;
    l_data                         VARCHAR2(2000);
    l_msg_data                     VARCHAR2(2000);
    l_msg_index_out                NUMBER;

BEGIN
    IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.SET_CURR_FUNCTION
            ( p_function   => 'DELETE_TABLE_RECORDS',
              p_debug_mode => p_pa_debug_mode );
    END IF;

    PA_RES_ASG_CURRENCY_PUB.PRINT_INPUT_PARAMS
        ( P_CALLING_API           => G_PVT_DELETE,
          P_FP_COLS_REC           => p_fp_cols_rec,
          P_CALLING_MODULE        => p_calling_module,
          P_VERSION_LEVEL_FLAG    => p_version_level_flag,
          P_CALLED_MODE           => p_called_mode );

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;

    IF p_version_level_flag = 'Y' THEN

        -- VERSION LEVEL Mode:
        -- Delete records from pa_resource_asgn_curr for the version.

	DELETE FROM pa_resource_asgn_curr rbc
	WHERE  rbc.budget_version_id = p_fp_cols_rec.x_budget_version_id;

    ELSIF p_version_level_flag = 'N' THEN

        IF is_public_calling_module(p_calling_module) THEN

            -- TEMP TABLE Mode:
            -- Delete records from pa_resource_asgn_curr for all the
            -- planning resource + currency combinations specified in
            -- pa_resource_asgn_curr_tmp with delete_flag = 'Y'.

            DELETE FROM pa_resource_asgn_curr rbc
            WHERE  rbc.budget_version_id = p_fp_cols_rec.x_budget_version_id
            AND EXISTS ( SELECT null
                         FROM   pa_resource_asgn_curr_tmp tmp
                         WHERE  NVL(tmp.delete_flag,'N') = 'Y'
                         AND    rbc.resource_assignment_id = tmp.resource_assignment_id
                         AND    rbc.txn_currency_code =
                                NVL(tmp.txn_currency_code,rbc.txn_currency_code) );

        ELSIF is_private_calling_module(p_calling_module) THEN

            -- TEMP TABLE Mode:
            -- Delete records from pa_resource_asgn_curr for all the
            -- planning resource + currency combinations specified in
            -- pa_resource_asgn_curr_tmp without checking delete_flag.

            DELETE FROM pa_resource_asgn_curr rbc
            WHERE  rbc.budget_version_id = p_fp_cols_rec.x_budget_version_id
            AND EXISTS ( SELECT null
                         FROM   pa_resource_asgn_curr_tmp tmp
                         WHERE  rbc.resource_assignment_id = tmp.resource_assignment_id
                         AND    rbc.txn_currency_code =
                                NVL(tmp.txn_currency_code,rbc.txn_currency_code) );

        END IF; -- p_calling_module check

    END IF; -- p_version_level_flag check

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

        -- Removed ROLLBACK statement.

        x_return_status := FND_API.G_RET_STS_ERROR;

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_msg         => 'Invalid Arguments Passed',
                  p_called_mode => p_called_mode,
                  p_module_name => l_module_name,
                  p_log_level   => l_log_level );
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        -- Removed RAISE statement.

    WHEN OTHERS THEN
        -- Removed ROLLBACK statement.
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(sqlerrm,1,240);
        -- dbms_output.put_line('error msg :'||x_msg_data);
        FND_MSG_PUB.add_exc_msg
            ( p_pkg_name        => 'PA_RES_ASG_CURRENCY_PUB',
              p_procedure_name  => 'DELETE_TABLE_RECORDS',
              p_error_text      => substr(sqlerrm,1,240));
        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                  p_called_mode => p_called_mode,
                  p_module_name => l_module_name,
                  p_log_level   => l_log_level);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END DELETE_TABLE_RECORDS;


PROCEDURE COPY_TABLE_RECORDS
        ( P_FP_COLS_REC                  IN           PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
          P_SRC_VERSION_ID               IN           PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
          P_COPY_MODE                    IN           VARCHAR2,
          P_CALLING_MODULE               IN           VARCHAR2,
          P_VERSION_LEVEL_FLAG           IN           VARCHAR2,
          P_CALLED_MODE                  IN           VARCHAR2,
          X_RETURN_STATUS                OUT NOCOPY   VARCHAR2,
          X_MSG_COUNT                    OUT NOCOPY   NUMBER,
          X_MSG_DATA                     OUT NOCOPY   VARCHAR2)
IS
    l_module_name                  VARCHAR2(100) := 'pa.plsql.PA_RES_ASG_CURRENCY_PUB.COPY_TABLE_RECORDS';
    l_log_level                    NUMBER := 5;

    l_msg_count                    NUMBER;
    l_data                         VARCHAR2(2000);
    l_msg_data                     VARCHAR2(2000);
    l_msg_index_out                NUMBER;

    l_last_updated_by              NUMBER := FND_GLOBAL.user_id;
    l_last_update_login            NUMBER := FND_GLOBAL.login_id;
    l_sysdate                      DATE   := SYSDATE;
    l_record_version_number        NUMBER := 1;

-- This cursor gets all the source pa_resource_asgn_curr records
-- for the entire version specified by c_src_version_id.
-- This cursor should be used when p_version_level_flag is 'Y'
-- and p_copy_mode is 'COPY_ALL'.

CURSOR ver_lvl_copy_all_csr
     ( c_src_version_id PA_RESOURCE_ASSIGNMENTS.BUDGET_VERSION_ID%TYPE,
       c_tgt_version_id PA_RESOURCE_ASSIGNMENTS.BUDGET_VERSION_ID%TYPE ) IS
SELECT tgt_ra.RESOURCE_ASSIGNMENT_ID,
       src_rbc.TXN_CURRENCY_CODE,
       src_rbc.TOTAL_QUANTITY,
       src_rbc.TOTAL_INIT_QUANTITY,
       src_rbc.TXN_RAW_COST_RATE_OVERRIDE,
       src_rbc.TXN_BURDEN_COST_RATE_OVERRIDE,
       src_rbc.TXN_BILL_RATE_OVERRIDE,
       src_rbc.TXN_AVERAGE_RAW_COST_RATE,
       src_rbc.TXN_AVERAGE_BURDEN_COST_RATE,
       src_rbc.TXN_AVERAGE_BILL_RATE,
       src_rbc.TXN_ETC_RAW_COST_RATE,
       src_rbc.TXN_ETC_BURDEN_COST_RATE,
       src_rbc.TXN_ETC_BILL_RATE,
       src_rbc.TOTAL_TXN_RAW_COST,
       src_rbc.TOTAL_TXN_BURDENED_COST,
       src_rbc.TOTAL_TXN_REVENUE,
       src_rbc.TOTAL_TXN_INIT_RAW_COST,
       src_rbc.TOTAL_TXN_INIT_BURDENED_COST,
       src_rbc.TOTAL_TXN_INIT_REVENUE,
       src_rbc.TOTAL_PROJECT_RAW_COST,
       src_rbc.TOTAL_PROJECT_BURDENED_COST,
       src_rbc.TOTAL_PROJECT_REVENUE,
       src_rbc.TOTAL_PROJECT_INIT_RAW_COST,
       src_rbc.TOTAL_PROJECT_INIT_BD_COST,
       src_rbc.TOTAL_PROJECT_INIT_REVENUE,
       src_rbc.TOTAL_PROJFUNC_RAW_COST,
       src_rbc.TOTAL_PROJFUNC_BURDENED_COST,
       src_rbc.TOTAL_PROJFUNC_REVENUE,
       src_rbc.TOTAL_PROJFUNC_INIT_RAW_COST,
       src_rbc.TOTAL_PROJFUNC_INIT_BD_COST,
       src_rbc.TOTAL_PROJFUNC_INIT_REVENUE,
       src_rbc.TOTAL_DISPLAY_QUANTITY
FROM   pa_resource_assignments tgt_ra,
       pa_resource_assignments src_ra,
       pa_resource_asgn_curr src_rbc
WHERE  src_rbc.budget_version_id = c_src_version_id
AND    src_ra.resource_assignment_id = src_rbc.resource_assignment_id
AND    nvl(tgt_ra.task_id,0) = nvl(src_ra.task_id,0)
AND    tgt_ra.resource_list_member_id = src_ra.resource_list_member_id
AND    tgt_ra.budget_version_id = c_tgt_version_id;

-- This cursor gets overrides from the source pa_resource_asgn_curr
-- records for the entire version specified by c_src_version_id.
-- This cursor should be used when p_version_level_flag is 'Y'
-- and p_copy_mode is 'COPY_OVERRIDES'.

CURSOR ver_lvl_copy_overrides_csr
     ( c_src_version_id PA_RESOURCE_ASSIGNMENTS.BUDGET_VERSION_ID%TYPE,
       c_tgt_version_id PA_RESOURCE_ASSIGNMENTS.BUDGET_VERSION_ID%TYPE ) IS
SELECT tgt_ra.RESOURCE_ASSIGNMENT_ID,
       src_rbc.TXN_CURRENCY_CODE,
       src_rbc.TXN_RAW_COST_RATE_OVERRIDE,
       src_rbc.TXN_BURDEN_COST_RATE_OVERRIDE,
       src_rbc.TXN_BILL_RATE_OVERRIDE
FROM   pa_resource_assignments tgt_ra,
       pa_resource_assignments src_ra,
       pa_resource_asgn_curr src_rbc
WHERE  src_rbc.budget_version_id = c_src_version_id
AND    src_ra.resource_assignment_id = src_rbc.resource_assignment_id
AND    nvl(tgt_ra.task_id,0) = nvl(src_ra.task_id,0)
AND    tgt_ra.resource_list_member_id = src_ra.resource_list_member_id
AND    tgt_ra.budget_version_id = c_tgt_version_id;

-- This cursor gets overrides from the source pa_resource_asgn_curr
-- records for the resources specified in pa_resource_asgn_curr_tmp
-- for the version specified by c_src_version_id.
-- This cursor should be used when p_version_level_flag is 'N'
-- and p_copy_mode is 'COPY_OVERRIDES'.
-- Note: Ordered hint has been added to avoid a Merge Join Cartesian
-- join order in the execution plan.

CURSOR tbl_mode_copy_overrides_csr
     ( c_src_version_id PA_RESOURCE_ASSIGNMENTS.BUDGET_VERSION_ID%TYPE,
       c_tgt_version_id PA_RESOURCE_ASSIGNMENTS.BUDGET_VERSION_ID%TYPE ) IS
SELECT /*+ ORDERED */
       tmp.RESOURCE_ASSIGNMENT_ID,
       src_rbc.TXN_CURRENCY_CODE,
       src_rbc.TXN_RAW_COST_RATE_OVERRIDE,
       src_rbc.TXN_BURDEN_COST_RATE_OVERRIDE,
       src_rbc.TXN_BILL_RATE_OVERRIDE
FROM   pa_resource_asgn_curr src_rbc,
       pa_resource_assignments src_ra,
       pa_resource_assignments tgt_ra,
       pa_resource_asgn_curr_tmp tmp
WHERE  tgt_ra.budget_version_id = c_tgt_version_id
AND    src_ra.budget_version_id = c_src_version_id
AND    tgt_ra.resource_assignment_id = tmp.resource_assignment_id
AND    nvl(src_ra.task_id,0) = nvl(tgt_ra.task_id,0)
AND    src_ra.resource_list_member_id = tgt_ra.resource_list_member_id
AND    src_rbc.resource_assignment_id = src_ra.resource_assignment_id
AND    src_rbc.budget_version_id = src_ra.budget_version_id;


    -- PL/SQL tables for storing copied source rates and amount totals
    l_ra_id_tab                    PA_PLSQL_DATATYPES.IdTabTyp;
    l_txn_currency_code_tab        PA_PLSQL_DATATYPES.Char15TabTyp;
    l_total_quantity_tab           PA_PLSQL_DATATYPES.NumTabTyp;
    l_total_init_quantity_tab      PA_PLSQL_DATATYPES.NumTabTyp;
    l_raw_cost_rate_override_tab   PA_PLSQL_DATATYPES.NumTabTyp;
    l_brdn_cost_rate_override_tab  PA_PLSQL_DATATYPES.NumTabTyp;
    l_bill_rate_override_tab       PA_PLSQL_DATATYPES.NumTabTyp;
    l_avg_raw_cost_rate_tab        PA_PLSQL_DATATYPES.NumTabTyp;
    l_avg_burden_cost_rate_tab     PA_PLSQL_DATATYPES.NumTabTyp;
    l_avg_bill_rate_tab            PA_PLSQL_DATATYPES.NumTabTyp;
    l_etc_raw_cost_rate_tab        PA_PLSQL_DATATYPES.NumTabTyp;
    l_etc_burden_cost_rate_tab     PA_PLSQL_DATATYPES.NumTabTyp;
    l_etc_bill_rate_tab            PA_PLSQL_DATATYPES.NumTabTyp;
    l_txn_raw_cost_tab             PA_PLSQL_DATATYPES.NumTabTyp;
    l_txn_burdened_cost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
    l_txn_revenue_tab              PA_PLSQL_DATATYPES.NumTabTyp;
    l_txn_init_raw_cost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
    l_txn_init_burdened_cost_tab   PA_PLSQL_DATATYPES.NumTabTyp;
    l_txn_init_revenue_tab         PA_PLSQL_DATATYPES.NumTabTyp;
    l_pc_raw_cost_tab              PA_PLSQL_DATATYPES.NumTabTyp;
    l_pc_burdened_cost_tab         PA_PLSQL_DATATYPES.NumTabTyp;
    l_pc_revenue_tab               PA_PLSQL_DATATYPES.NumTabTyp;
    l_pc_init_raw_cost_tab         PA_PLSQL_DATATYPES.NumTabTyp;
    l_pc_init_burdened_cost_tab    PA_PLSQL_DATATYPES.NumTabTyp;
    l_pc_init_revenue_tab          PA_PLSQL_DATATYPES.NumTabTyp;
    l_pfc_raw_cost_tab             PA_PLSQL_DATATYPES.NumTabTyp;
    l_pfc_burdened_cost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
    l_pfc_revenue_tab              PA_PLSQL_DATATYPES.NumTabTyp;
    l_pfc_init_raw_cost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
    l_pfc_init_burdened_cost_tab   PA_PLSQL_DATATYPES.NumTabTyp;
    l_pfc_init_revenue_tab         PA_PLSQL_DATATYPES.NumTabTyp;
    l_display_quantity_tab         PA_PLSQL_DATATYPES.NumTabTyp;

    l_NULL_NumTabTyp               PA_PLSQL_DATATYPES.NumTabTyp;

    -- Indicates if the Target version is a Workplan.
    l_wp_version_flag              PA_BUDGET_VERSIONS.WP_VERSION_FLAG%TYPE;

BEGIN
    IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.SET_CURR_FUNCTION
            ( p_function   => 'COPY_TABLE_RECORDS',
              p_debug_mode => p_pa_debug_mode );
    END IF;

    PA_RES_ASG_CURRENCY_PUB.PRINT_INPUT_PARAMS
        ( P_CALLING_API           => G_PVT_COPY,
          P_FP_COLS_REC           => p_fp_cols_rec,
          P_CALLING_MODULE        => p_calling_module,
          P_SRC_VERSION_ID        => p_src_version_id,
          P_COPY_MODE             => p_copy_mode,
          P_VERSION_LEVEL_FLAG    => p_version_level_flag,
          P_CALLED_MODE           => p_called_mode );

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;

    BEGIN
        SELECT nvl(wp_version_flag,'N')
        INTO   l_wp_version_flag
        FROM   pa_budget_versions
        WHERE  budget_version_id = p_fp_cols_rec.x_budget_version_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( P_MSG          => 'Invalid p_fp_cols_rec.x_budget_version_id value: '
                                    || p_fp_cols_rec.x_budget_version_id
                                    || '. Budget version does not exist.',
                  P_CALLED_MODE  => p_called_mode,
                  P_MODULE_NAME  => l_module_name,
                  P_LOG_LEVEL    => l_log_level );
        END IF;
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END;

    -- Step 1: Select rates and amounts from the appropriate cursor.

    IF p_version_level_flag = 'Y' THEN

        IF p_copy_mode = G_COPY_ALL THEN
            OPEN ver_lvl_copy_all_csr
                (p_src_version_id,
                 p_fp_cols_rec.x_budget_version_id);
            FETCH ver_lvl_copy_all_csr
            BULK COLLECT
            INTO l_ra_id_tab,
                 l_txn_currency_code_tab,
                 l_total_quantity_tab,
                 l_total_init_quantity_tab,
                 l_raw_cost_rate_override_tab,
                 l_brdn_cost_rate_override_tab,
                 l_bill_rate_override_tab,
                 l_avg_raw_cost_rate_tab,
                 l_avg_burden_cost_rate_tab,
                 l_avg_bill_rate_tab,
                 l_etc_raw_cost_rate_tab,
                 l_etc_burden_cost_rate_tab,
                 l_etc_bill_rate_tab,
                 l_txn_raw_cost_tab,
                 l_txn_burdened_cost_tab,
                 l_txn_revenue_tab,
                 l_txn_init_raw_cost_tab,
                 l_txn_init_burdened_cost_tab,
                 l_txn_init_revenue_tab,
                 l_pc_raw_cost_tab,
                 l_pc_burdened_cost_tab,
                 l_pc_revenue_tab,
                 l_pc_init_raw_cost_tab,
                 l_pc_init_burdened_cost_tab,
                 l_pc_init_revenue_tab,
                 l_pfc_raw_cost_tab,
                 l_pfc_burdened_cost_tab,
                 l_pfc_revenue_tab,
                 l_pfc_init_raw_cost_tab,
                 l_pfc_init_burdened_cost_tab,
                 l_pfc_init_revenue_tab,
                 l_display_quantity_tab;
            CLOSE ver_lvl_copy_all_csr;
        ELSIF p_copy_mode = G_COPY_OVERRIDES THEN
            OPEN ver_lvl_copy_overrides_csr
                (p_src_version_id,
                 p_fp_cols_rec.x_budget_version_id);
            FETCH ver_lvl_copy_overrides_csr
            BULK COLLECT
            INTO l_ra_id_tab,
                 l_txn_currency_code_tab,
                 l_raw_cost_rate_override_tab,
                 l_brdn_cost_rate_override_tab,
                 l_bill_rate_override_tab;
            CLOSE ver_lvl_copy_overrides_csr;
        END IF; -- p_copy_mode check

    ELSIF p_version_level_flag = 'N' THEN

        IF p_copy_mode = G_COPY_ALL THEN
            -- This case is currently NOT supported.
            IF p_pa_debug_mode = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                    ( P_MSG          => 'The '''||G_COPY_ALL||''' copy mode is not supported '
                                        || 'when p_version_level_flag is '
                                        || p_version_level_flag,
                      P_CALLED_MODE  => p_called_mode,
                      P_MODULE_NAME  => l_module_name,
                      P_LOG_LEVEL    => l_log_level );
            END IF;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        ELSIF p_copy_mode = G_COPY_OVERRIDES THEN
            OPEN tbl_mode_copy_overrides_csr
                (p_src_version_id,
                 p_fp_cols_rec.x_budget_version_id);
            FETCH tbl_mode_copy_overrides_csr
            BULK COLLECT
            INTO l_ra_id_tab,
                 l_txn_currency_code_tab,
                 l_raw_cost_rate_override_tab,
                 l_brdn_cost_rate_override_tab,
                 l_bill_rate_override_tab;
            CLOSE tbl_mode_copy_overrides_csr;
        END IF; -- p_copy_mode check

    END IF; -- p_version_level_flag check

    -- No further processing is required if there are no records to copy.
    IF l_ra_id_tab.count <= 0 THEN
	    IF P_PA_DEBUG_MODE = 'Y' THEN
	        PA_DEBUG.RESET_CURR_FUNCTION;
	    END IF;
        RETURN;
    END IF;

    -- Step 2: Process pl/sql tables as needed.

    -- Initialize a pl/sql table of length l_ra_id_tab.count with nulls.
    -- We can use this table to null out entire tables during processing.
    -- This should perform better than nulling out records in a loop.
    l_null_NumTabTyp.delete;
    FOR i IN 1..l_ra_id_tab.count LOOP
        l_null_NumTabTyp(i) := null;
    END LOOP;

    IF p_copy_mode = G_COPY_ALL THEN
        -- ETC Rate columns should Null for Budgets,
        -- but should be populated for Forecasts and Workplans.
        -- Additionally, Actuals columns should be nulled out.
        IF l_wp_version_flag = 'N' AND
           p_fp_cols_rec.x_plan_class_code = 'BUDGET' THEN
            l_etc_raw_cost_rate_tab      := l_null_NumTabTyp;
            l_etc_burden_cost_rate_tab   := l_null_NumTabTyp;
            l_etc_bill_rate_tab          := l_null_NumTabTyp;
            l_total_init_quantity_tab    := l_null_NumTabTyp;
            l_txn_init_raw_cost_tab      := l_null_NumTabTyp;
            l_txn_init_burdened_cost_tab := l_null_NumTabTyp;
            l_txn_init_revenue_tab       := l_null_NumTabTyp;
            l_pc_init_raw_cost_tab       := l_null_NumTabTyp;
            l_pc_init_burdened_cost_tab  := l_null_NumTabTyp;
            l_pc_init_revenue_tab        := l_null_NumTabTyp;
            l_pfc_init_raw_cost_tab      := l_null_NumTabTyp;
            l_pfc_init_burdened_cost_tab := l_null_NumTabTyp;
            l_pfc_init_revenue_tab       := l_null_NumTabTyp;
        END IF; -- ETC Rate column logic

        -- Only rates and totals relevant to the version type should be populated.
        -- Cost-only versions should not have revenue rates or totals.
        IF p_fp_cols_rec.x_version_type = 'COST' THEN
            l_bill_rate_override_tab := l_null_NumTabTyp;
            l_avg_bill_rate_tab      := l_null_NumTabTyp;
            l_etc_bill_rate_tab      := l_null_NumTabTyp;
            l_txn_revenue_tab        := l_null_NumTabTyp;
            l_txn_init_revenue_tab   := l_null_NumTabTyp;
            l_pc_revenue_tab         := l_null_NumTabTyp;
            l_pc_init_revenue_tab    := l_null_NumTabTyp;
            l_pfc_revenue_tab        := l_null_NumTabTyp;
            l_pfc_init_revenue_tab   := l_null_NumTabTyp;
        -- Revenue-only versions should not have cost rates or totals.
        ELSIF p_fp_cols_rec.x_version_type = 'REVENUE' THEN
            l_raw_cost_rate_override_tab  := l_null_NumTabTyp;
            l_brdn_cost_rate_override_tab := l_null_NumTabTyp;
            l_avg_raw_cost_rate_tab       := l_null_NumTabTyp;
            l_avg_burden_cost_rate_tab    := l_null_NumTabTyp;
            l_etc_raw_cost_rate_tab       := l_null_NumTabTyp;
            l_etc_burden_cost_rate_tab    := l_null_NumTabTyp;
            l_txn_raw_cost_tab            := l_null_NumTabTyp;
            l_txn_burdened_cost_tab       := l_null_NumTabTyp;
            l_txn_init_raw_cost_tab       := l_null_NumTabTyp;
            l_txn_init_burdened_cost_tab  := l_null_NumTabTyp;
            l_pc_raw_cost_tab             := l_null_NumTabTyp;
            l_pc_burdened_cost_tab        := l_null_NumTabTyp;
            l_pc_init_raw_cost_tab        := l_null_NumTabTyp;
            l_pc_init_burdened_cost_tab   := l_null_NumTabTyp;
            l_pfc_raw_cost_tab            := l_null_NumTabTyp;
            l_pfc_burdened_cost_tab       := l_null_NumTabTyp;
            l_pfc_init_raw_cost_tab       := l_null_NumTabTyp;
            l_pfc_init_burdened_cost_tab  := l_null_NumTabTyp;
        END IF;
    ELSIF p_copy_mode = G_COPY_OVERRIDES THEN
        -- Only rates relevant to the version type should be populated.
        -- Cost-only versions should not have revenue rates.
        IF p_fp_cols_rec.x_version_type = 'COST' THEN
            l_bill_rate_override_tab := l_null_NumTabTyp;
        -- Revenue-only versions should not have cost rates.
        ELSIF p_fp_cols_rec.x_version_type = 'REVENUE' THEN
            l_raw_cost_rate_override_tab  := l_null_NumTabTyp;
            l_brdn_cost_rate_override_tab := l_null_NumTabTyp;
        END IF;
    END IF; -- p_copy_mode check

    -- Step 3: Delete target records from PA_RESOURCE_ASGN_CURR
    -- that are being copied over from source records.

    -- Populate PA_RESOURCE_ASGN_CURR_TMP with the target records.
    -- Note that the DELETE_TABLE_RECORDS API does not require the
    -- DELETE_FLAG column be populated for internal p_calling_module
    -- values (though the flag is required for public p_calling_modules).
    -- See the is_public_calling_module() and is_private_calling_module()
    -- functions for details on private/public calling modules.

    DELETE PA_RESOURCE_ASGN_CURR_TMP;

    FORALL i IN 1..l_ra_id_tab.count
        INSERT INTO PA_RESOURCE_ASGN_CURR_TMP (
            RESOURCE_ASSIGNMENT_ID,
            TXN_CURRENCY_CODE )
        VALUES (
            l_ra_id_tab(i),
            l_txn_currency_code_tab(i) );

    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( P_MSG               => 'Before calling PA_RES_ASG_CURRENCY_PUB.'
                                     || 'DELETE_TABLE_RECORDS',
              P_CALLED_MODE       => p_called_mode,
              P_MODULE_NAME       => l_module_name,
              P_LOG_LEVEL         => l_log_level );
    END IF;
    PA_RES_ASG_CURRENCY_PUB.DELETE_TABLE_RECORDS
        ( P_FP_COLS_REC           => p_fp_cols_rec,
          P_CALLING_MODULE        => G_PVT_COPY,
          P_VERSION_LEVEL_FLAG    => 'N',
          P_CALLED_MODE           => p_called_mode,
          X_RETURN_STATUS         => x_return_status,
          X_MSG_COUNT             => x_msg_count,
          X_MSG_DATA              => x_msg_data );
    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( P_MSG               => 'After calling PA_RES_ASG_CURRENCY_PUB.'
                                     || 'DELETE_TABLE_RECORDS: ' || x_return_status,
              P_CALLED_MODE       => p_called_mode,
              P_MODULE_NAME       => l_module_name,
              P_LOG_LEVEL         => l_log_level );
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    -- Step 4: Insert records into the PA_RESOURCE_ASGN_CURR table.

    IF p_copy_mode = G_COPY_ALL THEN
        FORALL i IN 1..l_ra_id_tab.count
            INSERT INTO PA_RESOURCE_ASGN_CURR (
                RA_TXN_ID,
                BUDGET_VERSION_ID,
                RESOURCE_ASSIGNMENT_ID,
                TXN_CURRENCY_CODE,
                TOTAL_QUANTITY,
                TOTAL_INIT_QUANTITY,
                TXN_RAW_COST_RATE_OVERRIDE,
                TXN_BURDEN_COST_RATE_OVERRIDE,
                TXN_BILL_RATE_OVERRIDE,
                TXN_AVERAGE_RAW_COST_RATE,
                TXN_AVERAGE_BURDEN_COST_RATE,
                TXN_AVERAGE_BILL_RATE,
                TXN_ETC_RAW_COST_RATE,
                TXN_ETC_BURDEN_COST_RATE,
                TXN_ETC_BILL_RATE,
                TOTAL_TXN_RAW_COST,
                TOTAL_TXN_BURDENED_COST,
                TOTAL_TXN_REVENUE,
                TOTAL_TXN_INIT_RAW_COST,
                TOTAL_TXN_INIT_BURDENED_COST,
                TOTAL_TXN_INIT_REVENUE,
                TOTAL_PROJECT_RAW_COST,
                TOTAL_PROJECT_BURDENED_COST,
                TOTAL_PROJECT_REVENUE,
                TOTAL_PROJECT_INIT_RAW_COST,
                TOTAL_PROJECT_INIT_BD_COST,
                TOTAL_PROJECT_INIT_REVENUE,
                TOTAL_PROJFUNC_RAW_COST,
                TOTAL_PROJFUNC_BURDENED_COST,
                TOTAL_PROJFUNC_REVENUE,
                TOTAL_PROJFUNC_INIT_RAW_COST,
                TOTAL_PROJFUNC_INIT_BD_COST,
                TOTAL_PROJFUNC_INIT_REVENUE,
                TOTAL_DISPLAY_QUANTITY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN,
                RECORD_VERSION_NUMBER )
            VALUES (
                pa_resource_asgn_curr_s.nextval,
                p_fp_cols_rec.x_budget_version_id,
                l_ra_id_tab(i),
                l_txn_currency_code_tab(i),
                l_total_quantity_tab(i),
                l_total_init_quantity_tab(i),
                l_raw_cost_rate_override_tab(i),
                l_brdn_cost_rate_override_tab(i),
                l_bill_rate_override_tab(i),
                l_avg_raw_cost_rate_tab(i),
                l_avg_burden_cost_rate_tab(i),
                l_avg_bill_rate_tab(i),
                l_etc_raw_cost_rate_tab(i),
                l_etc_burden_cost_rate_tab(i),
                l_etc_bill_rate_tab(i),
                l_txn_raw_cost_tab(i),
                l_txn_burdened_cost_tab(i),
                l_txn_revenue_tab(i),
                l_txn_init_raw_cost_tab(i),
                l_txn_init_burdened_cost_tab(i),
                l_txn_init_revenue_tab(i),
                l_pc_raw_cost_tab(i),
                l_pc_burdened_cost_tab(i),
                l_pc_revenue_tab(i),
                l_pc_init_raw_cost_tab(i),
                l_pc_init_burdened_cost_tab(i),
                l_pc_init_revenue_tab(i),
                l_pfc_raw_cost_tab(i),
                l_pfc_burdened_cost_tab(i),
                l_pfc_revenue_tab(i),
                l_pfc_init_raw_cost_tab(i),
                l_pfc_init_burdened_cost_tab(i),
                l_pfc_init_revenue_tab(i),
                l_display_quantity_tab(i),
                l_sysdate,
                l_last_updated_by,
                l_sysdate,
                l_last_updated_by,
                l_last_update_login,
                l_record_version_number );
    ELSIF p_copy_mode = G_COPY_OVERRIDES THEN
        FORALL i IN 1..l_ra_id_tab.count
            INSERT INTO PA_RESOURCE_ASGN_CURR (
                RA_TXN_ID,
                BUDGET_VERSION_ID,
                RESOURCE_ASSIGNMENT_ID,
                TXN_CURRENCY_CODE,
                TXN_RAW_COST_RATE_OVERRIDE,
                TXN_BURDEN_COST_RATE_OVERRIDE,
                TXN_BILL_RATE_OVERRIDE,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN,
                RECORD_VERSION_NUMBER )
            VALUES (
                pa_resource_asgn_curr_s.nextval,
                p_fp_cols_rec.x_budget_version_id,
                l_ra_id_tab(i),
                l_txn_currency_code_tab(i),
                l_raw_cost_rate_override_tab(i),
                l_brdn_cost_rate_override_tab(i),
                l_bill_rate_override_tab(i),
                l_sysdate,
                l_last_updated_by,
                l_sysdate,
                l_last_updated_by,
                l_last_update_login,
                l_record_version_number );
    END IF; -- p_copy_mode check

--dbms_output.put_line('Reached Copy Records');

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

        -- Removed ROLLBACK statement.

        x_return_status := FND_API.G_RET_STS_ERROR;

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_msg         => 'Invalid Arguments Passed',
                  p_called_mode => p_called_mode,
                  p_module_name => l_module_name,
                  p_log_level   => l_log_level );
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        -- Removed RAISE statement.

    WHEN OTHERS THEN
        -- Removed ROLLBACK statement.
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(sqlerrm,1,240);
        -- dbms_output.put_line('error msg :'||x_msg_data);
        FND_MSG_PUB.add_exc_msg
            ( p_pkg_name        => 'PA_RES_ASG_CURRENCY_PUB',
              p_procedure_name  => 'COPY_TABLE_RECORDS',
              p_error_text      => substr(sqlerrm,1,240));
        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                  p_called_mode => p_called_mode,
                  p_module_name => l_module_name,
                  p_log_level   => l_log_level);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END COPY_TABLE_RECORDS;


PROCEDURE INSERT_TABLE_RECORDS
        ( P_FP_COLS_REC                  IN           PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
          P_CALLING_MODULE               IN           VARCHAR2,
          P_VERSION_LEVEL_FLAG           IN           VARCHAR2,
          P_CALLED_MODE                  IN           VARCHAR2,
          X_RETURN_STATUS                OUT NOCOPY   VARCHAR2,
          X_MSG_COUNT                    OUT NOCOPY   NUMBER,
          X_MSG_DATA                     OUT NOCOPY   VARCHAR2)
IS
    l_module_name                  VARCHAR2(100) := 'pa.plsql.PA_RES_ASG_CURRENCY_PUB.INSERT_TABLE_RECORDS';
    l_log_level                    NUMBER := 5;

    l_msg_count                    NUMBER;
    l_data                         VARCHAR2(2000);
    l_msg_data                     VARCHAR2(2000);
    l_msg_index_out                NUMBER;

    l_last_updated_by              NUMBER := FND_GLOBAL.user_id;
    l_last_update_login            NUMBER := FND_GLOBAL.login_id;
    l_sysdate                      DATE   := SYSDATE;
    l_record_version_number        NUMBER := 1;

    l_ra_id_tab                    PA_PLSQL_DATATYPES.IdTabTyp;
    l_txn_currency_code_tab        PA_PLSQL_DATATYPES.Char15TabTyp;
    l_rc_rate_override_tab         PA_PLSQL_DATATYPES.NumTabTyp;
    l_bc_rate_override_tab         PA_PLSQL_DATATYPES.NumTabTyp;
    l_bill_rate_override_tab       PA_PLSQL_DATATYPES.NumTabTyp;

BEGIN

    IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.SET_CURR_FUNCTION
            ( p_function   => 'INSERT_TABLE_RECORDS',
              p_debug_mode => p_pa_debug_mode );
    END IF;

    PA_RES_ASG_CURRENCY_PUB.PRINT_INPUT_PARAMS
        ( P_CALLING_API           => G_PVT_INSERT,
          P_FP_COLS_REC           => p_fp_cols_rec,
          P_CALLING_MODULE        => p_calling_module,
          P_VERSION_LEVEL_FLAG    => p_version_level_flag,
          P_CALLED_MODE           => p_called_mode );

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;


    IF p_version_level_flag = 'Y' THEN

        -- VERSION LEVEL Mode:
        -- Insert records into PA_RESOURCE_ASGN_CURR for all planning
        -- resource + currency combinations for the given version that do
        -- not already exist in the table.

	SELECT DISTINCT
               bl.resource_assignment_id,
	       bl.txn_currency_code
	BULK COLLECT
	INTO   l_ra_id_tab,
	       l_txn_currency_code_tab
	FROM   pa_budget_lines bl,
	       pa_resource_assignments ra
	WHERE  ra.budget_version_id = p_fp_cols_rec.x_budget_version_id
	AND    bl.resource_assignment_id = ra.resource_assignment_id
	AND NOT EXISTS (SELECT null
	                FROM   pa_resource_asgn_curr rbc
	                WHERE  rbc.resource_assignment_id = bl.resource_assignment_id
	                AND    rbc.txn_currency_code = bl.txn_currency_code);

	-- Insert records with values for the following columns:
	-- (ra_txn_id, budget_version_id, resource_assignment_id, txn_currency_code).
	-- All of the remaining columns, including the rate overrides,
	-- but excluding the who columns, will be Null in this case.

	FORALL i IN 1..l_ra_id_tab.count
	    INSERT INTO pa_resource_asgn_curr (
	        RA_TXN_ID,
	        BUDGET_VERSION_ID,
	        RESOURCE_ASSIGNMENT_ID,
	        TXN_CURRENCY_CODE,
	        CREATION_DATE,
	        CREATED_BY,
	        LAST_UPDATE_DATE,
	        LAST_UPDATED_BY,
	        LAST_UPDATE_LOGIN,
	        RECORD_VERSION_NUMBER )
	    VALUES (
	        pa_resource_asgn_curr_s.nextval,
		p_fp_cols_rec.x_budget_version_id,
	        l_ra_id_tab(i),
		l_txn_currency_code_tab(i),
	        l_sysdate,
	        l_last_updated_by,
	        l_sysdate,
	        l_last_updated_by,
	        l_last_update_login,
	        l_record_version_number );

    ELSIF p_version_level_flag = 'N' THEN

        -- TEMP TABLE Mode:
        -- Delete and then Insert the records specified by the temp table
        -- into the PA_RESOURCE_ASGN_CURR table.

        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( P_MSG               => 'Before calling PA_RES_ASG_CURRENCY_PUB.'
                                         || 'DELETE_TABLE_RECORDS',
                  P_CALLED_MODE       => p_called_mode,
                  P_MODULE_NAME       => l_module_name,
                  P_LOG_LEVEL         => l_log_level );
        END IF;
        PA_RES_ASG_CURRENCY_PUB.DELETE_TABLE_RECORDS
            ( P_FP_COLS_REC           => p_fp_cols_rec,
              P_CALLING_MODULE        => G_PVT_INSERT,
              P_VERSION_LEVEL_FLAG    => p_version_level_flag,
              P_CALLED_MODE           => p_called_mode,
              X_RETURN_STATUS         => x_return_status,
              X_MSG_COUNT             => x_msg_count,
              X_MSG_DATA              => x_msg_data );
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( P_MSG               => 'After calling PA_RES_ASG_CURRENCY_PUB.'
                                         || 'DELETE_TABLE_RECORDS: ' || x_return_status,
                  P_CALLED_MODE       => p_called_mode,
                  P_MODULE_NAME       => l_module_name,
                  P_LOG_LEVEL         => l_log_level );
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

        INSERT INTO pa_resource_asgn_curr
               ( RA_TXN_ID,
                 BUDGET_VERSION_ID,
                 RESOURCE_ASSIGNMENT_ID,
                 TXN_CURRENCY_CODE,
                 TXN_RAW_COST_RATE_OVERRIDE,
                 TXN_BURDEN_COST_RATE_OVERRIDE,
                 TXN_BILL_RATE_OVERRIDE,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_LOGIN,
                 RECORD_VERSION_NUMBER,
                 expenditure_type )--for EnC
        SELECT   pa_resource_asgn_curr_s.nextval,
                 p_fp_cols_rec.x_budget_version_id,
                 tmp.resource_assignment_id,
                 tmp.txn_currency_code,
                 tmp.txn_raw_cost_rate_override,
                 tmp.txn_burden_cost_rate_override,
                 tmp.txn_bill_rate_override,
                 l_sysdate,
                 l_last_updated_by,
                 l_sysdate,
                 l_last_updated_by,
                 l_last_update_login,
                 l_record_version_number,
                 expenditure_type --for EnC
          FROM   pa_resource_asgn_curr_tmp tmp;

    END IF; -- p_version_level_flag check

--dbms_output.put_line('Reached Insert Records');

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

        -- Removed ROLLBACK statement.

        x_return_status := FND_API.G_RET_STS_ERROR;

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_msg         => 'Invalid Arguments Passed',
                  p_called_mode => p_called_mode,
                  p_module_name => l_module_name,
                  p_log_level   => l_log_level );
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        -- Removed RAISE statement.

    WHEN OTHERS THEN
        -- Removed ROLLBACK statement.
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(sqlerrm,1,240);
        -- dbms_output.put_line('error msg :'||x_msg_data);
        FND_MSG_PUB.add_exc_msg
            ( p_pkg_name        => 'PA_RES_ASG_CURRENCY_PUB',
              p_procedure_name  => 'INSERT_TABLE_RECORDS',
              p_error_text      => substr(sqlerrm,1,240));
        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                  p_called_mode => p_called_mode,
                  p_module_name => l_module_name,
                  p_log_level   => l_log_level);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END INSERT_TABLE_RECORDS;


PROCEDURE ROLLUP_AMOUNTS
        ( P_FP_COLS_REC                  IN           PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
          P_CALLING_MODULE               IN           VARCHAR2,
          P_VERSION_LEVEL_FLAG           IN           VARCHAR2,
          P_CALLED_MODE                  IN           VARCHAR2,
          X_RETURN_STATUS                OUT NOCOPY   VARCHAR2,
          X_MSG_COUNT                    OUT NOCOPY   NUMBER,
          X_MSG_DATA                     OUT NOCOPY   VARCHAR2)
IS
    l_module_name                  VARCHAR2(100) := 'pa.plsql.PA_RES_ASG_CURRENCY_PUB.ROLLUP_AMOUNTS';
    l_log_level                    NUMBER := 5;

    l_msg_count                    NUMBER;
    l_data                         VARCHAR2(2000);
    l_msg_data                     VARCHAR2(2000);
    l_msg_index_out                NUMBER;

-- This cursor computes ETC rates, average rates, and amount totals
-- for the entire version specified by c_budget_version_id.
-- This cursor should be used when p_version_level_flag is 'Y'.
-- The cursor consists of two halves, connected by UNION ALL.
-- The first half gets data for resources that have budget lines,
-- but may or may not have records in PA_RESOURCE_ASGN_CURR.
-- The second half gets data for resources that have records in
-- PA_RESOURCE_ASGN_CURR but no budget lines.

CURSOR version_level_rollup_csr
     ( c_project_id        PA_RESOURCE_ASSIGNMENTS.PROJECT_ID%TYPE,
       c_budget_version_id PA_RESOURCE_ASSIGNMENTS.BUDGET_VERSION_ID%TYPE ) IS
SELECT  bl.resource_assignment_id,                                --RESOURCE_ASSIGNMENT_ID
        bl.txn_currency_code,                                     --TXN_CURRENCY_CODE
	case when sum(nvl(bl.quantity,0)) = 0 and sum(nvl(bl.init_quantity,0)) = 0 then null else sum(nvl(bl.quantity,0)) end, --TOTAL_QUANTITY
        decode(sum(nvl(bl.init_quantity,0)),
               0,null,sum(nvl(bl.init_quantity,0))),              --TOTAL_INIT_QUANTITY
        rbc.txn_raw_cost_rate_override,                           --TXN_RAW_COST_RATE_OVERRIDE
        rbc.txn_burden_cost_rate_override,                        --TXN_BURDEN_COST_RATE_OVERRIDE
        rbc.txn_bill_rate_override,                               --TXN_BILL_RATE_OVERRIDE
        /* bug fix 5523038 : modified Avg/ETC rate calculation logic to check
         * for rejection codes instead of relying on override/standard rates */
        ( sum(decode(cost_rejection_code
                     ,null,((nvl(bl.quantity,0)-nvl(bl.init_quantity,0))
                           * nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)))
                           + nvl(bl.txn_init_raw_cost,0)
                     ,null))
          / DECODE(sum(decode(cost_rejection_code,null,nvl(bl.quantity,0),null))
                  ,0,NULL
                  ,sum(decode(cost_rejection_code,null,nvl(bl.quantity,0),null)))
        ) avg_cost_rate,                                          --TXN_AVERAGE_RAW_COST_RATE
        ( sum(decode(burden_rejection_code
                     ,null,((nvl(bl.quantity,0)-nvl(bl.init_quantity,0))
                           * nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)))
                           + nvl(bl.txn_init_burdened_cost,0)
                     ,null))
          / DECODE(sum(decode(burden_rejection_code,null,nvl(bl.quantity,0),null))
                  ,0,NULL
                  ,sum(decode(burden_rejection_code,null,nvl(bl.quantity,0),null)))
        ) avg_burden_rate,                                        --TXN_AVERAGE_BURDEN_COST_RATE
        ( sum(decode(revenue_rejection_code
                     ,null,((nvl(bl.quantity,0)-nvl(bl.init_quantity,0))
                           * nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)))
                           + nvl(bl.txn_init_revenue,0)
                     ,null))
          / DECODE(sum(decode(revenue_rejection_code,null,nvl(bl.quantity,0),null))
                  ,0,NULL
                  ,sum(decode(revenue_rejection_code,null,nvl(bl.quantity,0),null)))
        ) avg_bill_rate,                                          --TXN_AVERAGE_BILL_RATE
        ( sum(decode(cost_rejection_code
                     ,null,((nvl(bl.quantity,0)-nvl(bl.init_quantity,0))
                           * nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)))
                     ,null))
          / DECODE(sum(decode(cost_rejection_code,null,nvl(bl.quantity,0)-nvl(bl.init_quantity,0),null))
                  ,0,NULL
                  ,sum(decode(cost_rejection_code,null,nvl(bl.quantity,0)-nvl(bl.init_quantity,0),null)))
        ) etc_cost_rate,                                          --TXN_ETC_RAW_COST_RATE
        ( sum(decode(burden_rejection_code
                     ,null,((nvl(bl.quantity,0)-nvl(bl.init_quantity,0))
                           * nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)))
                     ,null))
          / DECODE(sum(decode(burden_rejection_code,null,nvl(bl.quantity,0)-nvl(bl.init_quantity,0),null))
                  ,0,NULL
                  ,sum(decode(burden_rejection_code,null,nvl(bl.quantity,0)-nvl(bl.init_quantity,0),null)))
        ) etc_burden_rate,                                        --TXN_ETC_BURDEN_COST_RATE
        ( sum(decode(revenue_rejection_code
                     ,null,((nvl(bl.quantity,0)-nvl(bl.init_quantity,0))
                           * nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)))
                     ,null))
          / DECODE(sum(decode(revenue_rejection_code,null,nvl(bl.quantity,0)-nvl(bl.init_quantity,0),null))
                  ,0,NULL
                  ,sum(decode(revenue_rejection_code,null,nvl(bl.quantity,0)-nvl(bl.init_quantity,0),null)))
        ) etc_bill_rate,                                          --TXN_ETC_BILL_RATE
        /* end bug fix 5523038 */
	 case when sum(nvl(bl.txn_raw_cost,0)) = 0 and sum(nvl(bl.txn_init_raw_cost,0)) = 0 then null else  sum(nvl(bl.txn_raw_cost,0)) end,               --TOTAL_TXN_RAW_COST
         case when sum(nvl(bl.txn_burdened_cost,0)) = 0 and sum(nvl(bl.txn_init_burdened_cost,0)) = 0 then null else  sum(nvl(bl.txn_burdened_cost,0)) end,         --TOTAL_TXN_BURDENED_COST
       /* decode(sum(nvl(bl.txn_revenue,0)),
               0,null,sum(nvl(bl.txn_revenue,0))) */
       case when sum(nvl(bl.txn_revenue,0)) = 0 and sum(nvl(bl.txn_init_revenue,0)) = 0 then null else sum(nvl(bl.txn_revenue,0)) end,                --TOTAL_TXN_REVENUE
        decode(sum(nvl(bl.txn_init_raw_cost,0)),
               0,null,sum(nvl(bl.txn_init_raw_cost,0))),          --TOTAL_TXN_INIT_RAW_COST
        decode(sum(nvl(bl.txn_init_burdened_cost,0)),
               0,null,sum(nvl(bl.txn_init_burdened_cost,0))),     --TOTAL_TXN_INIT_BURDENED_COST
        decode(sum(nvl(bl.txn_init_revenue,0)),
               0,null,sum(nvl(bl.txn_init_revenue,0))),           --TOTAL_TXN_INIT_REVENUE
        decode(sum(nvl(bl.project_raw_cost,0)),
               0,null,sum(nvl(bl.project_raw_cost,0))),           --TOTAL_PROJECT_RAW_COST
        decode(sum(nvl(bl.project_burdened_cost,0)),
               0,null,sum(nvl(bl.project_burdened_cost,0))),      --TOTAL_PROJECT_BURDENED_COST
        decode(sum(nvl(bl.project_revenue,0)),
               0,null,sum(nvl(bl.project_revenue,0))),            --TOTAL_PROJECT_REVENUE
        decode(sum(nvl(bl.project_init_raw_cost,0)),
               0,null,sum(nvl(bl.project_init_raw_cost,0))),      --TOTAL_PROJECT_INIT_RAW_COST
        decode(sum(nvl(bl.project_init_burdened_cost,0)),
               0,null,sum(nvl(bl.project_init_burdened_cost,0))), --TOTAL_PROJECT_INIT_BD_COST
        decode(sum(nvl(bl.project_init_revenue,0)),
               0,null,sum(nvl(bl.project_init_revenue,0))),       --TOTAL_PROJECT_INIT_REVENUE
        decode(sum(nvl(bl.raw_cost,0)),
               0,null,sum(nvl(bl.raw_cost,0))),                   --TOTAL_PROJFUNC_RAW_COST
        decode(sum(nvl(bl.burdened_cost,0)),
               0,null,sum(nvl(bl.burdened_cost,0))),              --TOTAL_PROJFUNC_BURDENED_COST
        decode(sum(nvl(bl.revenue,0)),
               0,null,sum(nvl(bl.revenue,0))),                    --TOTAL_PROJFUNC_REVENUE
        decode(sum(nvl(bl.init_raw_cost,0)),
               0,null,sum(nvl(bl.init_raw_cost,0))),              --TOTAL_PROJFUNC_INIT_RAW_COST
        decode(sum(nvl(bl.init_burdened_cost,0)),
               0,null,sum(nvl(bl.init_burdened_cost,0))),         --TOTAL_PROJFUNC_INIT_BD_COST
        decode(sum(nvl(bl.init_revenue,0)),
               0,null,sum(nvl(bl.init_revenue,0))),               --TOTAL_PROJFUNC_INIT_REVENUE
        decode(sum(nvl(bl.display_quantity,0)),
               0,null,sum(nvl(bl.display_quantity,0))),           --TOTAL_DISPLAY_QUANTITY
	     rbc.expenditure_type                                      --Expenditure type for Enc
FROM    pa_resource_assignments ra,
        pa_budget_lines bl,
        pa_resource_asgn_curr rbc
WHERE   bl.resource_assignment_id = rbc.resource_assignment_id (+)
AND     bl.txn_currency_code = rbc.txn_currency_code (+)
AND     ra.budget_version_id = c_budget_version_id
AND     ra.project_id = c_project_id
AND     bl.resource_assignment_id = ra.resource_assignment_id
GROUP BY bl.resource_assignment_id,
         bl.txn_currency_code,
         rbc.txn_raw_cost_rate_override,
         rbc.txn_burden_cost_rate_override,
         rbc.txn_bill_rate_override,
         rbc.expenditure_type --cklee 6/16/2009
UNION ALL
SELECT rbc.resource_assignment_id,                --RESOURCE_ASSIGNMENT_ID
       rbc.txn_currency_code,                     --TXN_CURRENCY_CODE
       null,                                      --TOTAL_QUANTITY
       null,                                      --TOTAL_INIT_QUANTITY
       rbc.txn_raw_cost_rate_override,            --TXN_RAW_COST_RATE_OVERRIDE
       rbc.txn_burden_cost_rate_override,         --TXN_BURDEN_COST_RATE_OVERRIDE
       rbc.txn_bill_rate_override,                --TXN_BILL_RATE_OVERRIDE
       null,                                      --TXN_AVERAGE_RAW_COST_RATE
       null,                                      --TXN_AVERAGE_BURDEN_COST_RATE
       null,                                      --TXN_AVERAGE_BILL_RATE
       null,                                      --TXN_ETC_RAW_COST_RATE
       null,                                      --TXN_ETC_BURDEN_COST_RATE
       null,                                      --TXN_ETC_BILL_RATE
       null,                                      --TOTAL_TXN_RAW_COST
       null,                                      --TOTAL_TXN_BURDENED_COST
       null,                                      --TOTAL_TXN_REVENUE
       null,                                      --TOTAL_TXN_INIT_RAW_COST
       null,                                      --TOTAL_TXN_INIT_BURDENED_COST
       null,                                      --TOTAL_TXN_INIT_REVENUE
       null,                                      --TOTAL_PROJECT_RAW_COST
       null,                                      --TOTAL_PROJECT_BURDENED_COST
       null,                                      --TOTAL_PROJECT_REVENUE
       null,                                      --TOTAL_PROJECT_INIT_RAW_COST
       null,                                      --TOTAL_PROJECT_INIT_BD_COST
       null,                                      --TOTAL_PROJECT_INIT_REVENUE
       null,                                      --TOTAL_PROJFUNC_RAW_COST
       null,                                      --TOTAL_PROJFUNC_BURDENED_COST
       null,                                      --TOTAL_PROJFUNC_REVENUE
       null,                                      --TOTAL_PROJFUNC_INIT_RAW_COST
       null,                                      --TOTAL_PROJFUNC_INIT_BD_COST
       null,                                      --TOTAL_PROJFUNC_INIT_REVENUE
       null,                                       --TOTAL_DISPLAY_QUANTITY
	  rbc.expenditure_type                                      --Expenditure type for Enc
FROM   pa_resource_asgn_curr rbc
WHERE  rbc.budget_version_id = c_budget_version_id
AND    NOT EXISTS (SELECT null
                   FROM   pa_budget_lines bl
                   WHERE  bl.resource_assignment_id = rbc.resource_assignment_id
                   AND    bl.txn_currency_code = rbc.txn_currency_code );


-- This cursor computes ETC rates, average rates, and amount totals
-- for the resources specified in PA_RESOURCE_ASGN_CURR_TMP.
-- This cursor should be used when p_version_level_flag is 'N'.
-- The cursor gets data for resources that have records in
-- PA_RESOURCE_ASGN_CURR but may or may not have budget lines.
-- NOTE: the cursor parameters c_project_id and c_budget_version_id
-- are not necessary here, but included in case of future use.

CURSOR table_level_rollup_csr
     ( c_project_id        PA_RESOURCE_ASSIGNMENTS.PROJECT_ID%TYPE,
       c_budget_version_id PA_RESOURCE_ASSIGNMENTS.BUDGET_VERSION_ID%TYPE ) IS
SELECT  rbc.resource_assignment_id,                              --RESOURCE_ASSIGNMENT_ID
        rbc.txn_currency_code,                                   --TXN_CURRENCY_CODE
       case when sum(nvl(bl.quantity,0)) = 0 and sum(nvl(bl.init_quantity,0)) = 0 then null else sum(nvl(bl.quantity,0)) end,  --TOTAL_QUANTITY
        decode(sum(nvl(bl.init_quantity,0)),
               0,null,sum(nvl(bl.init_quantity,0))),              --TOTAL_INIT_QUANTITY
        rbc.txn_raw_cost_rate_override,                           --TXN_RAW_COST_RATE_OVERRIDE
        rbc.txn_burden_cost_rate_override,                        --TXN_BURDEN_COST_RATE_OVERRIDE
        rbc.txn_bill_rate_override,                               --TXN_BILL_RATE_OVERRIDE
        /* bug fix 5523038 : modified Avg/ETC rate calculation logic to check
         * for rejection codes instead of relying on override/standard rates */
        ( sum(decode(cost_rejection_code
                     ,null,((nvl(bl.quantity,0)-nvl(bl.init_quantity,0))
                           * nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)))
                           + nvl(bl.txn_init_raw_cost,0)
                     ,null))
          / DECODE(sum(decode(cost_rejection_code,null,nvl(bl.quantity,0),null))
                  ,0,NULL
                  ,sum(decode(cost_rejection_code,null,nvl(bl.quantity,0),null)))
        ) avg_cost_rate,                                          --TXN_AVERAGE_RAW_COST_RATE
        ( sum(decode(burden_rejection_code
                     ,null,((nvl(bl.quantity,0)-nvl(bl.init_quantity,0))
                           * nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)))
                           + nvl(bl.txn_init_burdened_cost,0)
                     ,null))
          / DECODE(sum(decode(burden_rejection_code,null,nvl(bl.quantity,0),null))
                  ,0,NULL
                  ,sum(decode(burden_rejection_code,null,nvl(bl.quantity,0),null)))
        ) avg_burden_rate,                                        --TXN_AVERAGE_BURDEN_COST_RATE
        ( sum(decode(revenue_rejection_code
                     ,null,((nvl(bl.quantity,0)-nvl(bl.init_quantity,0))
                           * nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)))
                           + nvl(bl.txn_init_revenue,0)
                     ,null))
          / DECODE(sum(decode(revenue_rejection_code,null,nvl(bl.quantity,0),null))
                  ,0,NULL
                  ,sum(decode(revenue_rejection_code,null,nvl(bl.quantity,0),null)))
        ) avg_bill_rate,                                          --TXN_AVERAGE_BILL_RATE

        ( sum(decode(cost_rejection_code
                     ,null,((nvl(bl.quantity,0)-nvl(bl.init_quantity,0))
                           * nvl(bl.txn_cost_rate_override,nvl(bl.txn_standard_cost_rate,0)))
                     ,null))
          / DECODE(sum(decode(cost_rejection_code,null,nvl(bl.quantity,0)-nvl(bl.init_quantity,0),null))
                  ,0,NULL
                  ,sum(decode(cost_rejection_code,null,nvl(bl.quantity,0)-nvl(bl.init_quantity,0),null)))
        ) etc_cost_rate,                                          --TXN_ETC_RAW_COST_RATE
        ( sum(decode(burden_rejection_code
                     ,null,((nvl(bl.quantity,0)-nvl(bl.init_quantity,0))
                           * nvl(bl.burden_cost_rate_override,nvl(bl.burden_cost_rate,0)))
                     ,null))
          / DECODE(sum(decode(burden_rejection_code,null,nvl(bl.quantity,0)-nvl(bl.init_quantity,0),null))
                  ,0,NULL
                  ,sum(decode(burden_rejection_code,null,nvl(bl.quantity,0)-nvl(bl.init_quantity,0),null)))
        ) etc_burden_rate,                                        --TXN_ETC_BURDEN_COST_RATE
        ( sum(decode(revenue_rejection_code
                     ,null,((nvl(bl.quantity,0)-nvl(bl.init_quantity,0))
                           * nvl(bl.txn_bill_rate_override,nvl(bl.txn_standard_bill_rate,0)))
                     ,null))
          / DECODE(sum(decode(revenue_rejection_code,null,nvl(bl.quantity,0)-nvl(bl.init_quantity,0),null))
                  ,0,NULL
                  ,sum(decode(revenue_rejection_code,null,nvl(bl.quantity,0)-nvl(bl.init_quantity,0),null)))
        ) etc_bill_rate,                                          --TXN_ETC_BILL_RATE
        /* end bug fix 5523038 */
       case when sum(nvl(bl.txn_raw_cost,0)) = 0 and sum(nvl(bl.txn_init_raw_cost,0)) = 0 then null else  sum(nvl(bl.txn_raw_cost,0)) end,  --TOTAL_TXN_RAW_COST
       case when sum(nvl(bl.txn_burdened_cost,0)) = 0 and sum(nvl(bl.txn_init_burdened_cost,0)) = 0 then null else sum(nvl(bl.txn_burdened_cost,0)) end,  --TOTAL_TXN_BURDENED_COST
       case when sum(nvl(bl.txn_revenue,0)) = 0 and sum(nvl(bl.txn_init_revenue,0)) = 0 then null else sum(nvl(bl.txn_revenue,0)) end,            --TOTAL_TXN_REVENUE
        decode(sum(nvl(bl.txn_init_raw_cost,0)),
               0,null,sum(nvl(bl.txn_init_raw_cost,0))),          --TOTAL_TXN_INIT_RAW_COST
        decode(sum(nvl(bl.txn_init_burdened_cost,0)),
               0,null,sum(nvl(bl.txn_init_burdened_cost,0))),     --TOTAL_TXN_INIT_BURDENED_COST
        decode(sum(nvl(bl.txn_init_revenue,0)),
               0,null,sum(nvl(bl.txn_init_revenue,0))),           --TOTAL_TXN_INIT_REVENUE
        decode(sum(nvl(bl.project_raw_cost,0)),
               0,null,sum(nvl(bl.project_raw_cost,0))),           --TOTAL_PROJECT_RAW_COST
        decode(sum(nvl(bl.project_burdened_cost,0)),
               0,null,sum(nvl(bl.project_burdened_cost,0))),      --TOTAL_PROJECT_BURDENED_COST
        decode(sum(nvl(bl.project_revenue,0)),
               0,null,sum(nvl(bl.project_revenue,0))),            --TOTAL_PROJECT_REVENUE
        decode(sum(nvl(bl.project_init_raw_cost,0)),
               0,null,sum(nvl(bl.project_init_raw_cost,0))),      --TOTAL_PROJECT_INIT_RAW_COST
        decode(sum(nvl(bl.project_init_burdened_cost,0)),
               0,null,sum(nvl(bl.project_init_burdened_cost,0))), --TOTAL_PROJECT_INIT_BD_COST
        decode(sum(nvl(bl.project_init_revenue,0)),
               0,null,sum(nvl(bl.project_init_revenue,0))),       --TOTAL_PROJECT_INIT_REVENUE
        decode(sum(nvl(bl.raw_cost,0)),
               0,null,sum(nvl(bl.raw_cost,0))),                   --TOTAL_PROJFUNC_RAW_COST
        decode(sum(nvl(bl.burdened_cost,0)),
               0,null,sum(nvl(bl.burdened_cost,0))),              --TOTAL_PROJFUNC_BURDENED_COST
        decode(sum(nvl(bl.revenue,0)),
               0,null,sum(nvl(bl.revenue,0))),                    --TOTAL_PROJFUNC_REVENUE
        decode(sum(nvl(bl.init_raw_cost,0)),
               0,null,sum(nvl(bl.init_raw_cost,0))),              --TOTAL_PROJFUNC_INIT_RAW_COST
        decode(sum(nvl(bl.init_burdened_cost,0)),
               0,null,sum(nvl(bl.init_burdened_cost,0))),         --TOTAL_PROJFUNC_INIT_BD_COST
        decode(sum(nvl(bl.init_revenue,0)),
               0,null,sum(nvl(bl.init_revenue,0))),               --TOTAL_PROJFUNC_INIT_REVENUE
        decode(sum(nvl(bl.display_quantity,0)),
               0,null,sum(nvl(bl.display_quantity,0))),            --TOTAL_DISPLAY_QUANTITY
            rbc.expenditure_type                                   --Direct cost expenditure type for EnC
FROM    pa_budget_lines bl,
        pa_resource_asgn_curr_TMP rbc
WHERE   bl.resource_assignment_id (+) = rbc.resource_assignment_id
AND     bl.txn_currency_code (+) = rbc.txn_currency_code
--Bug 6160759
AND     bl.budget_version_id(+)= p_fp_cols_rec.x_budget_version_id
AND     bl.budget_version_id(+)= p_fp_cols_rec.x_budget_version_id
GROUP BY rbc.resource_assignment_id,
         rbc.txn_currency_code,
         rbc.txn_raw_cost_rate_override,
         rbc.txn_burden_cost_rate_override,
         rbc.txn_bill_rate_override,
         rbc.expenditure_type;

    l_last_updated_by              NUMBER := FND_GLOBAL.user_id;
    l_last_update_login            NUMBER := FND_GLOBAL.login_id;
    l_sysdate                      DATE   := SYSDATE;
    l_record_version_number        NUMBER := 1;

    -- PL/SQL tables for storing computed rates and rolled up amounts
    l_ra_id_tab                    PA_PLSQL_DATATYPES.IdTabTyp;
    l_txn_currency_code_tab        PA_PLSQL_DATATYPES.Char15TabTyp;
    l_direct_expenditure_type_tab  PA_PLSQL_DATATYPES.Char30TabTyp; --For EnC
    l_total_quantity_tab           PA_PLSQL_DATATYPES.NumTabTyp;
    l_total_init_quantity_tab      PA_PLSQL_DATATYPES.NumTabTyp;
    l_raw_cost_rate_override_tab   PA_PLSQL_DATATYPES.NumTabTyp;
    l_brdn_cost_rate_override_tab  PA_PLSQL_DATATYPES.NumTabTyp;
    l_bill_rate_override_tab       PA_PLSQL_DATATYPES.NumTabTyp;
    l_avg_raw_cost_rate_tab        PA_PLSQL_DATATYPES.NumTabTyp;
    l_avg_burden_cost_rate_tab     PA_PLSQL_DATATYPES.NumTabTyp;
    l_avg_bill_rate_tab            PA_PLSQL_DATATYPES.NumTabTyp;
    l_etc_raw_cost_rate_tab        PA_PLSQL_DATATYPES.NumTabTyp;
    l_etc_burden_cost_rate_tab     PA_PLSQL_DATATYPES.NumTabTyp;
    l_etc_bill_rate_tab            PA_PLSQL_DATATYPES.NumTabTyp;
    l_txn_raw_cost_tab             PA_PLSQL_DATATYPES.NumTabTyp;
    l_txn_burdened_cost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
    l_txn_revenue_tab              PA_PLSQL_DATATYPES.NumTabTyp;
    l_txn_init_raw_cost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
    l_txn_init_burdened_cost_tab   PA_PLSQL_DATATYPES.NumTabTyp;
    l_txn_init_revenue_tab         PA_PLSQL_DATATYPES.NumTabTyp;
    l_pc_raw_cost_tab              PA_PLSQL_DATATYPES.NumTabTyp;
    l_pc_burdened_cost_tab         PA_PLSQL_DATATYPES.NumTabTyp;
    l_pc_revenue_tab               PA_PLSQL_DATATYPES.NumTabTyp;
    l_pc_init_raw_cost_tab         PA_PLSQL_DATATYPES.NumTabTyp;
    l_pc_init_burdened_cost_tab    PA_PLSQL_DATATYPES.NumTabTyp;
    l_pc_init_revenue_tab          PA_PLSQL_DATATYPES.NumTabTyp;
    l_pfc_raw_cost_tab             PA_PLSQL_DATATYPES.NumTabTyp;
    l_pfc_burdened_cost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
    l_pfc_revenue_tab              PA_PLSQL_DATATYPES.NumTabTyp;
    l_pfc_init_raw_cost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
    l_pfc_init_burdened_cost_tab   PA_PLSQL_DATATYPES.NumTabTyp;
    l_pfc_init_revenue_tab         PA_PLSQL_DATATYPES.NumTabTyp;
    l_display_quantity_tab         PA_PLSQL_DATATYPES.NumTabTyp;

    l_NULL_NumTabTyp               PA_PLSQL_DATATYPES.NumTabTyp;

    -- Indicates if the Target version is a Workplan.
    l_wp_version_flag              PA_BUDGET_VERSIONS.WP_VERSION_FLAG%TYPE;

BEGIN

    IF p_pa_debug_mode = 'Y' THEN
        PA_DEBUG.SET_CURR_FUNCTION
            ( p_function   => 'ROLLUP_AMOUNTS',
              p_debug_mode => p_pa_debug_mode );
    END IF;

    PA_RES_ASG_CURRENCY_PUB.PRINT_INPUT_PARAMS
        ( P_CALLING_API           => G_PVT_ROLLUP,
          P_FP_COLS_REC           => p_fp_cols_rec,
          P_CALLING_MODULE        => p_calling_module,
          P_VERSION_LEVEL_FLAG    => p_version_level_flag,
          P_CALLED_MODE           => p_called_mode );

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;

    BEGIN
        SELECT nvl(wp_version_flag,'N')
        INTO   l_wp_version_flag
        FROM   pa_budget_versions
        WHERE  budget_version_id = p_fp_cols_rec.x_budget_version_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( P_MSG          => 'Invalid p_fp_cols_rec.x_budget_version_id value: '
                                    || p_fp_cols_rec.x_budget_version_id
                                    || '. Budget version does not exist.',
                  P_CALLED_MODE  => p_called_mode,
                  P_MODULE_NAME  => l_module_name,
                  P_LOG_LEVEL    => l_log_level );
        END IF;
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END;


    -- Step 1: Select rates and amounts from the appropriate cursor.

    IF p_version_level_flag = 'Y' THEN
        OPEN version_level_rollup_csr
            (p_fp_cols_rec.x_project_id,
             p_fp_cols_rec.x_budget_version_id);
        FETCH version_level_rollup_csr
        BULK COLLECT
        INTO l_ra_id_tab,
	     l_txn_currency_code_tab,
	     l_total_quantity_tab,
	     l_total_init_quantity_tab,
	     l_raw_cost_rate_override_tab,
	     l_brdn_cost_rate_override_tab,
	     l_bill_rate_override_tab,
	     l_avg_raw_cost_rate_tab,
	     l_avg_burden_cost_rate_tab,
	     l_avg_bill_rate_tab,
	     l_etc_raw_cost_rate_tab,
	     l_etc_burden_cost_rate_tab,
	     l_etc_bill_rate_tab,
	     l_txn_raw_cost_tab,
	     l_txn_burdened_cost_tab,
	     l_txn_revenue_tab,
	     l_txn_init_raw_cost_tab,
	     l_txn_init_burdened_cost_tab,
	     l_txn_init_revenue_tab,
	     l_pc_raw_cost_tab,
	     l_pc_burdened_cost_tab,
	     l_pc_revenue_tab,
	     l_pc_init_raw_cost_tab,
	     l_pc_init_burdened_cost_tab,
	     l_pc_init_revenue_tab,
	     l_pfc_raw_cost_tab,
	     l_pfc_burdened_cost_tab,
	     l_pfc_revenue_tab,
	     l_pfc_init_raw_cost_tab,
	     l_pfc_init_burdened_cost_tab,
	     l_pfc_init_revenue_tab,
	     l_display_quantity_tab,
		 l_direct_expenditure_type_tab;	 -- added for Enc
        CLOSE version_level_rollup_csr;
    ELSIF p_version_level_flag = 'N' THEN
	    OPEN table_level_rollup_csr
            (p_fp_cols_rec.x_project_id,
             p_fp_cols_rec.x_budget_version_id);
        FETCH table_level_rollup_csr
        BULK COLLECT
        INTO l_ra_id_tab,
	     l_txn_currency_code_tab,
	     l_total_quantity_tab,
	     l_total_init_quantity_tab,
	     l_raw_cost_rate_override_tab,
	     l_brdn_cost_rate_override_tab,
	     l_bill_rate_override_tab,
	     l_avg_raw_cost_rate_tab,
	     l_avg_burden_cost_rate_tab,
	     l_avg_bill_rate_tab,
	     l_etc_raw_cost_rate_tab,
	     l_etc_burden_cost_rate_tab,
	     l_etc_bill_rate_tab,
	     l_txn_raw_cost_tab,
	     l_txn_burdened_cost_tab,
	     l_txn_revenue_tab,
	     l_txn_init_raw_cost_tab,
	     l_txn_init_burdened_cost_tab,
	     l_txn_init_revenue_tab,
	     l_pc_raw_cost_tab,
	     l_pc_burdened_cost_tab,
	     l_pc_revenue_tab,
	     l_pc_init_raw_cost_tab,
	     l_pc_init_burdened_cost_tab,
	     l_pc_init_revenue_tab,
	     l_pfc_raw_cost_tab,
	     l_pfc_burdened_cost_tab,
	     l_pfc_revenue_tab,
	     l_pfc_init_raw_cost_tab,
	     l_pfc_init_burdened_cost_tab,
	     l_pfc_init_revenue_tab,
	     l_display_quantity_tab,
	     l_direct_expenditure_type_tab; --for EnC
        CLOSE table_level_rollup_csr;
	END IF; -- p_version_level_flag check

    -- No further processing is required if there are no records to rollup.
    IF l_ra_id_tab.count <= 0 THEN
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RETURN;
    END IF;


    -- Step 2: Process pl/sql tables as needed.

    -- Initialize a pl/sql table of length l_ra_id_tab.count with nulls.
    -- We can use this table to null out entire tables during processing.
    -- This should perform better than nulling out records in a loop.
    l_null_NumTabTyp.delete;
    FOR i IN 1..l_ra_id_tab.count LOOP
        l_null_NumTabTyp(i) := null;
    END LOOP;

    -- ETC Rate columns should Null for Budgets,
    -- but should be populated for Forecasts and Workplans.
    -- Additionally, Actuals columns should be nulled out.
    IF l_wp_version_flag = 'N' AND
       p_fp_cols_rec.x_plan_class_code = 'BUDGET' THEN
        l_etc_raw_cost_rate_tab      := l_null_NumTabTyp;
        l_etc_burden_cost_rate_tab   := l_null_NumTabTyp;
        l_etc_bill_rate_tab          := l_null_NumTabTyp;
        l_total_init_quantity_tab    := l_null_NumTabTyp;
        l_txn_init_raw_cost_tab      := l_null_NumTabTyp;
        l_txn_init_burdened_cost_tab := l_null_NumTabTyp;
        l_txn_init_revenue_tab       := l_null_NumTabTyp;
        l_pc_init_raw_cost_tab       := l_null_NumTabTyp;
        l_pc_init_burdened_cost_tab  := l_null_NumTabTyp;
        l_pc_init_revenue_tab        := l_null_NumTabTyp;
        l_pfc_init_raw_cost_tab      := l_null_NumTabTyp;
        l_pfc_init_burdened_cost_tab := l_null_NumTabTyp;
        l_pfc_init_revenue_tab       := l_null_NumTabTyp;
    END IF; -- ETC Rate column logic

    -- Only rates and totals relevant to the version type should be populated.
    -- Cost-only versions should not have revenue rates or totals.
    IF p_fp_cols_rec.x_version_type = 'COST' THEN
        l_bill_rate_override_tab := l_null_NumTabTyp;
        l_avg_bill_rate_tab      := l_null_NumTabTyp;
        l_etc_bill_rate_tab      := l_null_NumTabTyp;
        l_txn_revenue_tab        := l_null_NumTabTyp;
        l_txn_init_revenue_tab   := l_null_NumTabTyp;
        l_pc_revenue_tab         := l_null_NumTabTyp;
        l_pc_init_revenue_tab    := l_null_NumTabTyp;
        l_pfc_revenue_tab        := l_null_NumTabTyp;
        l_pfc_init_revenue_tab   := l_null_NumTabTyp;
    -- Revenue-only versions should not have cost rates or totals.
    ELSIF p_fp_cols_rec.x_version_type = 'REVENUE' THEN
        l_raw_cost_rate_override_tab  := l_null_NumTabTyp;
        l_brdn_cost_rate_override_tab := l_null_NumTabTyp;
        l_avg_raw_cost_rate_tab       := l_null_NumTabTyp;
        l_avg_burden_cost_rate_tab    := l_null_NumTabTyp;
        l_etc_raw_cost_rate_tab       := l_null_NumTabTyp;
        l_etc_burden_cost_rate_tab    := l_null_NumTabTyp;
        l_txn_raw_cost_tab            := l_null_NumTabTyp;
        l_txn_burdened_cost_tab       := l_null_NumTabTyp;
        l_txn_init_raw_cost_tab       := l_null_NumTabTyp;
        l_txn_init_burdened_cost_tab  := l_null_NumTabTyp;
        l_pc_raw_cost_tab             := l_null_NumTabTyp;
        l_pc_burdened_cost_tab        := l_null_NumTabTyp;
        l_pc_init_raw_cost_tab        := l_null_NumTabTyp;
        l_pc_init_burdened_cost_tab   := l_null_NumTabTyp;
        l_pfc_raw_cost_tab            := l_null_NumTabTyp;
        l_pfc_burdened_cost_tab       := l_null_NumTabTyp;
        l_pfc_init_raw_cost_tab       := l_null_NumTabTyp;
        l_pfc_init_burdened_cost_tab  := l_null_NumTabTyp;
    END IF;

    -- Step 3: Delete records from the PA_RESOURCE_ASGN_CURR table.

    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( P_MSG               => 'Before calling PA_RES_ASG_CURRENCY_PUB.'
                                     || 'DELETE_TABLE_RECORDS',
              P_CALLED_MODE       => p_called_mode,
              P_MODULE_NAME       => l_module_name,
              P_LOG_LEVEL         => l_log_level );
    END IF;
    PA_RES_ASG_CURRENCY_PUB.DELETE_TABLE_RECORDS
        ( P_FP_COLS_REC           => p_fp_cols_rec,
          P_CALLING_MODULE        => G_PVT_ROLLUP,
          P_VERSION_LEVEL_FLAG    => p_version_level_flag,
          P_CALLED_MODE           => p_called_mode,
          X_RETURN_STATUS         => x_return_status,
          X_MSG_COUNT             => x_msg_count,
          X_MSG_DATA              => x_msg_data );
    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( P_MSG               => 'After calling PA_RES_ASG_CURRENCY_PUB.'
                                     || 'DELETE_TABLE_RECORDS: ' || x_return_status,
              P_CALLED_MODE       => p_called_mode,
              P_MODULE_NAME       => l_module_name,
              P_LOG_LEVEL         => l_log_level );
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    -- Step 4: Insert records into the PA_RESOURCE_ASGN_CURR table.

    FORALL i IN 1..l_ra_id_tab.count
        INSERT INTO PA_RESOURCE_ASGN_CURR (
	    RA_TXN_ID,
	    BUDGET_VERSION_ID,
	    RESOURCE_ASSIGNMENT_ID,
	    TXN_CURRENCY_CODE,
	    TOTAL_QUANTITY,
	    TOTAL_INIT_QUANTITY,
	    TXN_RAW_COST_RATE_OVERRIDE,
	    TXN_BURDEN_COST_RATE_OVERRIDE,
	    TXN_BILL_RATE_OVERRIDE,
	    TXN_AVERAGE_RAW_COST_RATE,
	    TXN_AVERAGE_BURDEN_COST_RATE,
	    TXN_AVERAGE_BILL_RATE,
	    TXN_ETC_RAW_COST_RATE,
	    TXN_ETC_BURDEN_COST_RATE,
	    TXN_ETC_BILL_RATE,
	    TOTAL_TXN_RAW_COST,
	    TOTAL_TXN_BURDENED_COST,
	    TOTAL_TXN_REVENUE,
	    TOTAL_TXN_INIT_RAW_COST,
	    TOTAL_TXN_INIT_BURDENED_COST,
	    TOTAL_TXN_INIT_REVENUE,
	    TOTAL_PROJECT_RAW_COST,
	    TOTAL_PROJECT_BURDENED_COST,
	    TOTAL_PROJECT_REVENUE,
	    TOTAL_PROJECT_INIT_RAW_COST,
	    TOTAL_PROJECT_INIT_BD_COST,
	    TOTAL_PROJECT_INIT_REVENUE,
	    TOTAL_PROJFUNC_RAW_COST,
	    TOTAL_PROJFUNC_BURDENED_COST,
	    TOTAL_PROJFUNC_REVENUE,
	    TOTAL_PROJFUNC_INIT_RAW_COST,
	    TOTAL_PROJFUNC_INIT_BD_COST,
	    TOTAL_PROJFUNC_INIT_REVENUE,
	    TOTAL_DISPLAY_QUANTITY,
	    CREATION_DATE,
	    CREATED_BY,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    LAST_UPDATE_LOGIN,
	    RECORD_VERSION_NUMBER,
	    expenditure_type )
        VALUES (
            pa_resource_asgn_curr_s.nextval,
            p_fp_cols_rec.x_budget_version_id,
            l_ra_id_tab(i),
            l_txn_currency_code_tab(i),
            l_total_quantity_tab(i),
            l_total_init_quantity_tab(i),
            l_raw_cost_rate_override_tab(i),
            l_brdn_cost_rate_override_tab(i),
            l_bill_rate_override_tab(i),
            l_avg_raw_cost_rate_tab(i),
            l_avg_burden_cost_rate_tab(i),
            l_avg_bill_rate_tab(i),
            l_etc_raw_cost_rate_tab(i),
            l_etc_burden_cost_rate_tab(i),
            l_etc_bill_rate_tab(i),
            l_txn_raw_cost_tab(i),
            l_txn_burdened_cost_tab(i),
            l_txn_revenue_tab(i),
            l_txn_init_raw_cost_tab(i),
            l_txn_init_burdened_cost_tab(i),
            l_txn_init_revenue_tab(i),
            l_pc_raw_cost_tab(i),
            l_pc_burdened_cost_tab(i),
            l_pc_revenue_tab(i),
            l_pc_init_raw_cost_tab(i),
            l_pc_init_burdened_cost_tab(i),
            l_pc_init_revenue_tab(i),
            l_pfc_raw_cost_tab(i),
            l_pfc_burdened_cost_tab(i),
            l_pfc_revenue_tab(i),
            l_pfc_init_raw_cost_tab(i),
            l_pfc_init_burdened_cost_tab(i),
            l_pfc_init_revenue_tab(i),
            l_display_quantity_tab(i),
            l_sysdate,
            l_last_updated_by,
            l_sysdate,
            l_last_updated_by,
            l_last_update_login,
            l_record_version_number,
            l_direct_expenditure_type_tab(i) --for EnC
             );

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

        -- Removed ROLLBACK statement.

        x_return_status := FND_API.G_RET_STS_ERROR;

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_msg         => 'Invalid Arguments Passed',
                  p_called_mode => p_called_mode,
                  p_module_name => l_module_name,
                  p_log_level   => l_log_level );
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        -- Removed RAISE statement.

    WHEN OTHERS THEN
        -- Removed ROLLBACK statement.
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(sqlerrm,1,240);
        -- dbms_output.put_line('error msg :'||x_msg_data);
        FND_MSG_PUB.add_exc_msg
            ( p_pkg_name        => 'PA_RES_ASG_CURRENCY_PUB',
              p_procedure_name  => 'ROLLUP_AMOUNTS',
              p_error_text      => substr(sqlerrm,1,240));
        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
                ( p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                  p_called_mode => p_called_mode,
                  p_module_name => l_module_name,
                  p_log_level   => l_log_level);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END ROLLUP_AMOUNTS;


END PA_RES_ASG_CURRENCY_PUB;

/
