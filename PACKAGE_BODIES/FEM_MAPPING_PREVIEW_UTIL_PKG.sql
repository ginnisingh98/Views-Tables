--------------------------------------------------------
--  DDL for Package Body FEM_MAPPING_PREVIEW_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_MAPPING_PREVIEW_UTIL_PKG" AS
/* $Header: fem_mapping_preview_util_pkg.plb 120.5 2008/02/08 22:06:54 gcheng ship $ */

-------------------------------------------------------------------------------
-- PRIVATE CONSTANTS
-------------------------------------------------------------------------------

G_PKG_NAME           CONSTANT VARCHAR2(30) := 'FEM_MAPPING_PREVIEW_UTIL_PKG';
G_FACT_ALIAS         CONSTANT VARCHAR2(1)  := 'F';
G_DIM_ALIAS          CONSTANT VARCHAR2(1)  := 'D';
G_STAT_ALIAS         CONSTANT VARCHAR2(1) := 'S';
G_MATCH_ALIAS        CONSTANT VARCHAR2(1)  := 'M';
G_DIM_TEMPLATE_TABLE CONSTANT VARCHAR2(30) := 'FEM_DIM_TEMPLATE';
G_SOURCE             CONSTANT FEM_ALLOC_PREVIEW_STATS.preview_row_group%TYPE
                                := 'SOURCE';
G_DRIVER             CONSTANT FEM_ALLOC_PREVIEW_STATS.preview_row_group%TYPE
                                := 'DRIVER';
G_DEBIT              CONSTANT FEM_ALLOC_PREVIEW_STATS.preview_row_group%TYPE
                                := 'DEBIT';
G_CREDIT             CONSTANT FEM_ALLOC_PREVIEW_STATS.preview_row_group%TYPE
                                := 'CREDIT';
G_ACCT_TRANS_TYPE    CONSTANT VARCHAR2(30) := 'ACCOUNT_TRANS';
G_LEDGER_TYPE        CONSTANT VARCHAR2(30) := 'LEDGER';
G_OTHER_TABLE_TYPE   CONSTANT VARCHAR2(30) := 'OTHER_TABLE_TYPE';
G_RETRIEVE_STAT      CONSTANT FEM_ALLOC_BR_OBJECTS.map_rule_type_code%TYPE
                                := 'RETRIEVE_STATISTICS';
G_BY_DIMENSION       CONSTANT FEM_ALLOC_BR_OBJECTS.map_rule_type_code%TYPE
                                := 'DIMENSION';
G_FACTOR_TABLE       CONSTANT FEM_ALLOC_BR_OBJECTS.map_rule_type_code%TYPE
                                := 'FACTOR_TABLE';
G_NUMBER_TYPE        CONSTANT VARCHAR2(15) := 'NUMBER';
G_VARCHAR_TYPE       CONSTANT VARCHAR2(15) := 'VARCHAR';
G_UNSUPPORTED_TYPE   CONSTANT VARCHAR2(15) := 'UNSUPPORTED';
G_LEDGER_AMOUNT_COL  CONSTANT VARCHAR2(30) := 'XTD_BALANCE_F';

-------------------------------------------------------------------------------
-- PRIVATE SPECIFICATIONS
-------------------------------------------------------------------------------

PROCEDURE GetSelectClause(
  p_preview_obj_def_id     IN NUMBER,
  p_preview_obj_id         IN NUMBER,
  p_request_id             IN NUMBER,
  p_preview_row_group      IN VARCHAR2,
  p_fact_table_name        IN VARCHAR2,
  x_select_clause          OUT NOCOPY VARCHAR2);

PROCEDURE GetMapTableType(
  p_table_name             IN VARCHAR2,
  x_map_table_type         OUT NOCOPY VARCHAR2);

PROCEDURE GetOutputMatchingTable(
  p_preview_obj_def_id      IN NUMBER,
  x_output_match_temp_table OUT NOCOPY VARCHAR2,
  x_output_match_fact_table OUT NOCOPY VARCHAR2);

PROCEDURE GetFromClause(
  p_fact_table_name         IN VARCHAR2,
  x_from_clause             OUT NOCOPY VARCHAR2);

PROCEDURE GetWhereClause(
  p_preview_obj_def_id      IN NUMBER,
  p_preview_row_group       IN VARCHAR2,
  p_map_obj_def_id          IN NUMBER,
  p_map_rule_type           IN VARCHAR2,
  p_function_cd             IN VARCHAR2,
  p_sub_obj_id              IN NUMBER,
  p_fact_table_name         IN VARCHAR2,
  p_request_id              IN NUMBER,
  p_preview_obj_id          IN NUMBER,
  x_map_where_clause        OUT NOCOPY VARCHAR2,
  x_where_clause            OUT NOCOPY VARCHAR2);

PROCEDURE GetInputWhereClause(
  p_preview_obj_def_id      IN NUMBER,
  p_preview_row_group       IN VARCHAR2,
  p_map_obj_def_id          IN NUMBER,
  p_map_rule_type           IN VARCHAR2,
  p_fact_table_name         IN VARCHAR2,
  p_sub_obj_id              IN NUMBER,
  p_request_id              IN NUMBER,
  p_preview_obj_id          IN NUMBER,
  x_map_where_clause        OUT NOCOPY VARCHAR2,
  x_where_clause            OUT NOCOPY VARCHAR2);

PROCEDURE GetOutputWhereClause(
  p_preview_obj_def_id      IN NUMBER,
  p_map_obj_def_id          IN NUMBER,
  p_function_cd             IN VARCHAR2,
  p_fact_table_name         IN VARCHAR2,
  x_where_clause            OUT NOCOPY VARCHAR2);

PROCEDURE CreateTempTable(
  p_temp_table_seq      IN NUMBER,
  p_preview_obj_def_id  IN NUMBER,
  p_preview_obj_id      IN NUMBER,
  p_preview_row_group   IN VARCHAR2,
  p_preview_display_seq IN NUMBER,
  p_request_id          IN NUMBER,
  p_map_obj_id          IN VARCHAR2,
  p_map_obj_def_id      IN VARCHAR2,
  p_map_rule_type       IN VARCHAR2,
  p_fact_table_name     IN VARCHAR2,
  p_function_cd         IN VARCHAR2,
  p_sub_obj_id          IN NUMBER,
  x_map_where_clause    OUT NOCOPY VARCHAR2,
  x_temp_table_name     OUT NOCOPY VARCHAR2);

PROCEDURE CreatePreviewStats(
  p_preview_obj_def_id     IN NUMBER,
  p_preview_row_group      IN VARCHAR2,
  p_preview_display_seq    IN NUMBER,
  p_fact_table_name        IN VARCHAR2,
  p_temp_table_name        IN VARCHAR2,
  p_map_where_clause       IN VARCHAR2,
  p_preview_obj_id         IN NUMBER,
  p_request_id             IN NUMBER);

PROCEDURE CreatePreviewMaps(
  p_preview_obj_def_id     IN NUMBER,
  p_preview_row_group      IN VARCHAR2,
  p_fact_table_name        IN VARCHAR2,
  p_preview_obj_id         IN NUMBER,
  p_request_id             IN NUMBER);

PROCEDURE UpdatePreviewStats(
  p_preview_obj_def_id      IN NUMBER,
  p_preview_row_group       IN VARCHAR2,
  p_temp_table_name         IN VARCHAR2,
  p_map_table_type          IN VARCHAR2,
  p_map_obj_def_id          IN NUMBER,
  p_ledger_id               IN NUMBER,
  p_cal_period_id           IN NUMBER);

PROCEDURE GetPreviewAmount(
  p_preview_obj_def_id      IN NUMBER,
  p_preview_row_group       IN VARCHAR2,
  p_temp_table_name         IN VARCHAR2,
  p_map_table_type          IN VARCHAR2,
  p_map_obj_def_id          IN NUMBER,
  p_ledger_id               IN NUMBER,
  p_cal_period_id           IN NUMBER,
  x_functional_currency     OUT NOCOPY VARCHAR2,
  x_preview_amount_total    OUT NOCOPY NUMBER);

PROCEDURE GetPreviewRowCount(
  p_temp_table_name         IN VARCHAR2,
  x_preview_row_count       OUT NOCOPY NUMBER);

PROCEDURE CleanOutputTable(
  p_temp_table_name         IN VARCHAR2,
  p_fact_table_name         IN VARCHAR2,
  p_map_table_type          IN VARCHAR2,
  p_preview_row_group       IN VARCHAR2,
  p_preview_obj_id          IN NUMBER,
  p_request_id              IN NUMBER);

PROCEDURE PopulateDimensionNames(
  p_preview_obj_def_id      IN NUMBER,
  p_preview_row_group       IN VARCHAR2,
  p_temp_table_name         IN VARCHAR2,
  p_fact_table_name         IN VARCHAR2,
  p_ledger_id               IN NUMBER);

PROCEDURE GetByDimParams(
  p_preview_obj_def_id      IN NUMBER,
  p_preview_row_group       IN VARCHAR2,
  p_map_obj_def_id          IN NUMBER,
  p_map_rule_type           IN VARCHAR2,
  p_fact_table_name         IN VARCHAR2,
  x_by_dimension_column     OUT NOCOPY VARCHAR2,
  x_by_dimension_id         OUT NOCOPY VARCHAR2,
  x_by_dimension_value      OUT NOCOPY VARCHAR2);

-------------------------------------------------------------------------------
-- PUBLIC BODIES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- PROCEDURE
--   Remove_Results
--
-- DESCRIPTION
--   This procedure removes the results generated by a Preview execution.
--   It deletes data from the FEM_ALLOC_PREVIEW_STATS and
--   FEM_ALLOC_PREVIEW_MAPS tables.  It also calls
--   FEM_UD_PKG.Remove_Process_Locks to remove the Process Lock
--   registration data, and along with it the Preview temporary tables.
--
--   The Preview UI and FEM_BR_MAPPING_PREVIEW_PVT.DeleteObjectDefinition
--   call this API to remove existing Preview results.
--
-- IN
--   p_object_id    -  Preview rule identifier
--
-------------------------------------------------------------------------------
PROCEDURE Remove_Results(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
  p_commit              IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
  p_encoded             IN  VARCHAR2   DEFAULT FND_API.G_TRUE,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  p_preview_obj_def_id  IN  NUMBER)
-------------------------------------------------------------------------------
IS

  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_mapping_preview_util_pkg.remove_results';
  C_API_NAME          CONSTANT VARCHAR2(30) := 'Remove_Results';
  C_API_VERSION       CONSTANT NUMBER := 1.0;
--
  e_api_error         EXCEPTION;
  v_request_id        NUMBER;
  v_preview_obj_id    FEM_OBJECT_DEFINITION_B.object_id%TYPE;
--
  -- Gets all object executions for a given preview rule.
  -- In some cases, only fem_pl_requests gets registered and so
  -- in that case, cannot rely on fem_pl_object_executions - hence the UNION.
  CURSOR c_prvw_execs(cv_obj_def_id NUMBER, cv_request_id NUMBER) IS
    SELECT request_id
    FROM fem_pl_object_executions
    WHERE exec_object_definition_id = cv_obj_def_id
    UNION
    SELECT cv_request_id
    FROM dual
    ORDER BY request_id;
--
BEGIN
--
  -- Standard Start of API savepoint
  SAVEPOINT  remove_results_pub;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Initialize return status to unexpected error
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (C_API_VERSION,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'INTERNAL ERROR: API Version ('||C_API_VERSION
                    ||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize FND message queue
  IF p_init_msg_list = FND_API.G_TRUE then
    FND_MSG_PUB.Initialize;
  END IF;

  -- Log procedure param values
  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_preview_obj_def_id = '||to_char(p_preview_obj_def_id));
  END IF;

  -- See if Preview has run yet
  BEGIN
    SELECT request_id
    INTO v_request_id
    FROM fem_alloc_previews
    WHERE preview_obj_def_id = p_preview_obj_def_id;
  EXCEPTION
    WHEN no_data_found THEN
      v_request_id := -1;
  END;

  -- If Preview has been run, remove the last execution, as well as
  -- any straglers out there due to errors or what not.
  IF v_request_id > -1 THEN
    -- get preview object id
    v_preview_obj_id := FEM_BUSINESS_RULE_PVT.GetObjectId(
                          p_obj_def_id => p_preview_obj_def_id);

    -- Loop through all preview executions for a given preview version
    FOR prvw_execs IN c_prvw_execs(cv_obj_def_id => p_preview_obj_def_id,
                                   cv_request_id => v_request_id) LOOP

      -- Remove process locks and temporary tables created by Preview execution
      FEM_UD_PKG.Remove_Process_Locks(
        p_api_version      => 1.0,
        p_init_msg_list    => FND_API.G_FALSE,
        p_commit           => FND_API.G_FALSE,
        p_encoded          => p_encoded,
        x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data,
        p_request_id       => prvw_execs.request_id,
        p_object_id        => v_preview_obj_id);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => FND_LOG.level_unexpected,
            p_module   => C_MODULE,
            p_msg_text => 'INTERNAL ERROR: Call to'
                        ||' FEM_UD_PKG.Remove_Process_Locks'
                        ||' failed with return status: '||x_return_status);
        END IF;

        RAISE e_api_error;
      END IF;

    END LOOP; -- FOR prvw_execs...

  END IF;  -- IF v_request_id > -1 THEN

  -- Now delete all data created by the preview execution in the
  -- persistent preview output tables

  DELETE FROM fem_alloc_preview_stats
  WHERE preview_obj_def_id = p_preview_obj_def_id;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'Deleted '||SQL%ROWCOUNT
                  ||' rows from FEM_ALLOC_PREVIEW_STATS');
  END IF;

  DELETE FROM fem_alloc_preview_maps
  WHERE preview_obj_def_id = p_preview_obj_def_id;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'Deleted '||SQL%ROWCOUNT
                  ||' rows from FEM_ALLOC_PREVIEW_MAPS');
  END IF;

  FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
EXCEPTION
  -- Since this procedure drops temp tables, rollback segments are lost
  -- and so instead of rolling back to specific save point, just rollback
  -- completely.
  WHEN e_api_error THEN
    -- When a call to an API fails, just exit because all return params
    -- have already been set by the API itself.
    ROLLBACK;
  WHEN others THEN
    ROLLBACK;

    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'Unexpected error: '||SQLERRM);
    END IF;
    IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_procedure,
        p_module   => C_MODULE,
        p_msg_text => 'End Procedure');
    END IF;

    -- Log the Oracle error message to the stack.
    FEM_ENGINES_PKG.USER_MESSAGE(
      p_app_name =>'FEM',
      p_msg_name => 'FEM_UNEXPECTED_ERROR',
      p_token1 => 'ERR_MSG',
      p_value1 => SQLERRM);

    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--
END Remove_Results;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- PROCEDURE
--   Pre_Process
--
-- DESCRIPTION
--   This procedure is responsible for the pre-processing steps
--   to prepare for CCE to run in preview mode.
--   For each "preview row group", e.g. SOURCE, DRIVER, CREDIT, DEBIT,
--   create a temporary table that mirrors the corresponding fact table
--   and store those table names in the FEM_ALLOC_PREVIEW_STATS table.
--
-- IN
--   p_obj_def_id    -  Preview rule ID
--   p_request_id    -  Preview execution concurrent request ID
--
-------------------------------------------------------------------------------
PROCEDURE Pre_Process(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
  p_commit              IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
  p_encoded             IN  VARCHAR2   DEFAULT FND_API.G_TRUE,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  p_preview_obj_def_id  IN  NUMBER,
  p_request_id          IN  NUMBER)
-------------------------------------------------------------------------------
IS

  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_mapping_preview_util_pkg.pre_process';
  C_API_NAME          CONSTANT VARCHAR2(30) := 'Pre_Process';
  C_API_VERSION       CONSTANT NUMBER := 1.0;
--
  v_preview_obj_id    FEM_OBJECT_DEFINITION_B.object_id%TYPE;
  v_map_obj_def_id    FEM_OBJECT_DEFINITION_B.object_definition_id%TYPE;
  v_map_obj_id        FEM_OBJECT_DEFINITION_B.object_id%TYPE;
  v_stat_obj_def_id   FEM_OBJECT_DEFINITION_B.object_definition_id%TYPE;
  v_fact_table_name   FEM_ALLOC_PREVIEW_STATS.fact_table_name%TYPE;
  v_temp_table_name   FEM_ALLOC_PREVIEW_STATS.temp_table_name%TYPE;
  v_map_rule_type     FEM_ALLOC_BR_OBJECTS.map_rule_type_code%TYPE;
  v_temp_table_seq    NUMBER;
  v_map_where_clause  VARCHAR2(16000);
  v_create_temp_table BOOLEAN;
  v_debit_table_name  FEM_ALLOC_PREVIEW_STATS.fact_table_name%TYPE;
--
  -- Gets information related to each preview row group needed to
  -- create the temporary tables.
  -- p_obj_def_id is the rule version of the parent mapping rule.
  CURSOR c_row_group_info (cv_obj_def_id NUMBER) IS
    SELECT f.table_name, f.function_cd, f.sub_object_id,
           m.preview_row_group, m.preview_row_group_display_seq
    FROM fem_alloc_br_formula f, fem_function_cd_mapping m
    WHERE f.function_cd = m.function_cd
    AND f.object_definition_id = cv_obj_def_id
    AND nvl(f.enable_flg,'Y') = 'Y'
    ORDER BY m.preview_row_group_process_seq;
--
BEGIN
--
  -- Standard Start of API savepoint
  SAVEPOINT  pre_process_pub;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
       p_msg_text => 'Begin Procedure');
  END IF;

  -- Initialize return status to unexpected error
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (C_API_VERSION,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'INTERNAL ERROR: API Version ('||C_API_VERSION
                    ||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize FND message queue
  IF p_init_msg_list = FND_API.G_TRUE then
    FND_MSG_PUB.Initialize;
  END IF;

  -- Log procedure param values
  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_preview_obj_def_id = '||to_char(p_preview_obj_def_id));
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_request_id = '||to_char(p_request_id));
  END IF;

  -- Get preview object_id
  v_preview_obj_id := FEM_BUSINESS_RULE_PVT.GetObjectId(
                          p_obj_def_id => p_preview_obj_def_id);

  -- Get mapping object definition id
  SELECT object_definition_id, object_id
  INTO v_map_obj_def_id, v_map_obj_id
  FROM fem_objdef_helper_rules
  WHERE helper_obj_def_id = p_preview_obj_def_id
  AND helper_object_type_code = 'MAPPING_PREVIEW';

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'v_map_obj_id = '||to_char(v_map_obj_id));
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'v_map_obj_def_id = '||to_char(v_map_obj_def_id));
  END IF;

  -- Get map rule type
  SELECT map_rule_type_code
  INTO v_map_rule_type
  FROM fem_alloc_br_objects
  WHERE map_rule_object_id = v_map_obj_id;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'v_map_rule_type = '||v_map_rule_type);
  END IF;

  -- Preview does not support Factor Table rules yet...
  IF (v_map_rule_type = G_FACTOR_TABLE) THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'Preview does not support Factor Table rules!');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Counter for number of temp objects being created
  v_temp_table_seq := 0;

  -- For each preview group, create the temporary table
  -- and insert the temporary table information in FEM_ALLOC_PREVIEW_STATS.
  FOR row_group IN c_row_group_info(cv_obj_def_id => v_map_obj_def_id) LOOP

    -- If the Mapping Rule Type is By Dimension and
    -- Preview Row Group is DRIVER, do nothing.  By Dimension rule
    -- does not have a DRIVER from the Preview perspective.
    --
    -- The reason is that CCE only looks at the "SOURCE" table when processing
    -- the By Dimension rule type.  It issues a
    --   SUM(DECODE(by_dim_col, by_dim_val, 0, balances_f)),
    --   SUM(DECODE(by_dim_col, by_dim_val, balances_f, 0))
    -- statement to get the non-By Dim value and the By Dim value in one SQL
    -- Therefore, the By Dimension temporary source table needs to contain
    -- both By Dim and non-By Dim value.

    IF (v_map_rule_type = G_BY_DIMENSION) AND
       (row_group.preview_row_group = G_DRIVER) THEN

      null;

    ELSE

      v_temp_table_seq := v_temp_table_seq + 1;

      -- First, assume fact table name is from FEM_ALLOC_BR_FORMULA.TABLE_NAME
      v_fact_table_name := row_group.table_name;

      -- If this is the driver and the mapping rule type is Retrieve Stats,
      -- get the fact table name from FEM_STAT_LOOKUPS.STAT_LOOKUP_TABLE
      -- instead of FEM_ALLOC_BR_FORMULA.TABLE_NAME.
      IF row_group.preview_row_group = G_DRIVER AND
         v_map_rule_type = G_RETRIEVE_STAT THEN

        -- First get Stat Lookup obj def id
        SELECT object_definition_id
        INTO v_stat_obj_def_id
        FROM fem_object_definition_b
        WHERE object_id = row_group.sub_object_id;

        SELECT stat_lookup_table
        INTO v_fact_table_name
        FROM fem_stat_lookups
        WHERE stat_lookup_obj_def_id = v_stat_obj_def_id;

      END IF;

      CreatePreviewMaps(
        p_preview_obj_def_id   => p_preview_obj_def_id,
        p_preview_row_group    => row_group.preview_row_group,
        p_fact_table_name      => v_fact_table_name,
        p_preview_obj_id       => v_preview_obj_id,
        p_request_id           => p_request_id);

      -- Only create one temp table for each target fact table because
      -- if the same fact table is designated for both credit and debit,
      -- it does not make sense to write out to separate temp tables.
      --
      -- Since we know from
      -- FEM_FUNCTION_CD_MAPPING.preview_row_group_process_seq
      -- that DEBIT is processed first, we will only check if CREDIT table
      -- is the same as the DEBIT table.  If there was no DEBIT table,
      -- then we automatically need to create a CREDIT table.
      v_create_temp_table := FALSE;
      IF (row_group.preview_row_group = G_DEBIT) THEN
        v_debit_table_name := v_fact_table_name;
        v_create_temp_table := TRUE;
      ELSIF (row_group.preview_row_group = G_CREDIT) THEN
        IF ((v_debit_table_name IS NOT NULL) AND
            (v_fact_table_name = v_debit_table_name)) THEN
          v_create_temp_table := FALSE;
        ELSE
          v_create_temp_table := TRUE;
        END IF;
      ELSE
        v_create_temp_table := TRUE;
      END IF;

      IF (v_create_temp_table) THEN
        CreateTempTable(
          p_temp_table_seq       => v_temp_table_seq,
          p_preview_obj_def_id   => p_preview_obj_def_id,
          p_preview_obj_id       => v_preview_obj_id,
          p_preview_row_group    => row_group.preview_row_group,
          p_preview_display_seq  => row_group.preview_row_group_display_seq,
          p_request_id           => p_request_id,
          p_map_obj_id           => v_map_obj_id,
          p_map_obj_def_id       => v_map_obj_def_id,
          p_map_rule_type        => v_map_rule_type,
          p_fact_table_name      => v_fact_table_name,
          p_function_cd          => row_group.function_cd,
          p_sub_obj_id           => row_group.sub_object_id,
          x_map_where_clause     => v_map_where_clause,
          x_temp_table_name      => v_temp_table_name);
      END IF;

      CreatePreviewStats(
        p_preview_obj_def_id   => p_preview_obj_def_id,
        p_preview_row_group    => row_group.preview_row_group,
        p_preview_display_seq  => row_group.preview_row_group_display_seq,
        p_fact_table_name      => v_fact_table_name,
        p_temp_table_name      => v_temp_table_name,
        p_map_where_clause     => v_map_where_clause,
        p_preview_obj_id       => v_preview_obj_id,
        p_request_id           => p_request_id);

    END IF; -- IF (v_map_rule_tyep = G_BY_DIMENSION) AND ...

  END LOOP;

  FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
EXCEPTION
  -- Since this procedure drops temp tables, rollback segments are lost
  -- and so instead of rolling back to specific save point, just rollback
  -- completely.
  WHEN others THEN
    ROLLBACK;

    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'Unexpected error: '||SQLERRM);
    END IF;
    IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_procedure,
        p_module   => C_MODULE,
        p_msg_text => 'End Procedure');
    END IF;

    -- Log the Oracle error message to the stack.
    FEM_ENGINES_PKG.USER_MESSAGE(
      p_app_name =>'FEM',
      p_msg_name => 'FEM_UNEXPECTED_ERROR',
      p_token1 => 'ERR_MSG',
      p_value1 => SQLERRM);

    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--
END Pre_Process;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- PROCEDURE
--   Post_Process
--
-- DESCRIPTION
--   This procedure is responsible for the post-processing steps of:
--   1. generating the preview statistics
--   2. populating the dimension name columns in the temporary tables
--
-- IN
--   p_preview_obj_def_id    -  Preview rule ID
--   p_request_id    -  Preview execution concurrent request ID
--
-------------------------------------------------------------------------------
PROCEDURE Post_Process(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
  p_commit              IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
  p_encoded             IN  VARCHAR2   DEFAULT FND_API.G_TRUE,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  p_preview_obj_def_id  IN  NUMBER,
  p_request_id          IN  NUMBER)
-------------------------------------------------------------------------------
IS

  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_mapping_preview_util_pkg.post_process';
  C_API_NAME          CONSTANT VARCHAR2(30) := 'Post_Process';
  C_API_VERSION       CONSTANT NUMBER := 1.0;
  v_map_obj_def_id    FEM_OBJECT_DEFINITION_B.object_definition_id%TYPE;
  v_map_obj_id        FEM_OBJECT_DEFINITION_B.object_id%TYPE;
  v_preview_obj_id    FEM_OBJECT_DEFINITION_B.object_id%TYPE;
  v_ledger_id         FEM_ALLOC_PREVIEWS.ledger_id%TYPE;
  v_cal_period_id     FEM_ALLOC_PREVIEWS.cal_period_id%TYPE;
  v_map_table_type    VARCHAR2(30);
--
  -- Gets information related to each preview row group needed to
  -- update the Preview Stats and populate the dimension names.
  CURSOR c_row_group_info (cv_preview_obj_def_id NUMBER) IS
    SELECT fact_table_name, temp_table_name, preview_row_group
    FROM fem_alloc_preview_stats
    WHERE preview_obj_def_id = cv_preview_obj_def_id
    ORDER BY preview_row_group_display_seq;
--
BEGIN
--
  -- Standard Start of API savepoint
  SAVEPOINT  post_process_pub;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Initialize return status to unexpected error
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (C_API_VERSION,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'INTERNAL ERROR: API Version ('||C_API_VERSION
                    ||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize FND message queue
  IF p_init_msg_list = FND_API.G_TRUE then
    FND_MSG_PUB.Initialize;
  END IF;

  -- Log procedure param values
  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_preview_obj_def_id = '||to_char(p_preview_obj_def_id));
  END IF;

  -- Get the corresponding Mapping object id and object definition id
  SELECT object_id, object_definition_id
  INTO v_map_obj_id, v_map_obj_def_id
  FROM fem_objdef_helper_rules
  WHERE helper_obj_def_id = p_preview_obj_def_id
  AND helper_object_type_code = 'MAPPING_PREVIEW';

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'v_map_obj_def_id = '||to_char(v_map_obj_def_id));
  END IF;

  -- Get the preview object id
  v_preview_obj_id := FEM_BUSINESS_RULE_PVT.GetObjectId(
                        p_obj_def_id => p_preview_obj_def_id);

  -- Get preview parameter values
  SELECT ledger_id, cal_period_id
  INTO v_ledger_id, v_cal_period_id
  FROM fem_alloc_previews
  WHERE preview_obj_def_id = p_preview_obj_def_id;

  FOR row_group IN c_row_group_info(p_preview_obj_def_id) LOOP

    GetMapTableType(
      p_table_name       => row_group.fact_table_name,
      x_map_table_type   => v_map_table_type);

    CleanOutputTable(
      p_temp_table_name         => row_group.temp_table_name,
      p_fact_table_name         => row_group.fact_table_name,
      p_map_table_type          => v_map_table_type,
      p_preview_row_group       => row_group.preview_row_group,
      p_preview_obj_id          => v_preview_obj_id,
      p_request_id              => p_request_id);

    UpdatePreviewStats(
      p_preview_obj_def_id      => p_preview_obj_def_id,
      p_preview_row_group       => row_group.preview_row_group,
      p_temp_table_name         => row_group.temp_table_name,
      p_map_table_type          => v_map_table_type,
      p_map_obj_def_id          => v_map_obj_def_id,
      p_ledger_id               => v_ledger_id,
      p_cal_period_id           => v_cal_period_id);

    PopulateDimensionNames(
      p_preview_obj_def_id      => p_preview_obj_def_id,
      p_preview_row_group       => row_group.preview_row_group,
      p_temp_table_name         => row_group.temp_table_name,
      p_fact_table_name         => row_group.fact_table_name,
      p_ledger_id               => v_ledger_id);

  END LOOP;

  FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
EXCEPTION
  -- Since this procedure drops temp tables, rollback segments are lost
  -- and so instead of rolling back to specific save point, just rollback
  -- completely.
  WHEN others THEN
    ROLLBACK;

    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'Unexpected error: '||SQLERRM);
    END IF;
    IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_procedure,
        p_module   => C_MODULE,
        p_msg_text => 'End Procedure');
    END IF;

    -- Log the Oracle error message to the stack.
    FEM_ENGINES_PKG.USER_MESSAGE(
      p_app_name =>'FEM',
      p_msg_name => 'FEM_UNEXPECTED_ERROR',
      p_token1 => 'ERR_MSG',
      p_value1 => SQLERRM);

    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--
END Post_Process;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- PRIVATE BODIES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- PROCEDURE
--   CreateTempTable
--
-- DESCRIPTION
--   Creates the temporary table based on the fact table being passed in.
--   Also create an index on the temporary table based on the
--   fact table processing key.
--
-------------------------------------------------------------------------------
PROCEDURE CreateTempTable(
  p_temp_table_seq      IN NUMBER,
  p_preview_obj_def_id  IN NUMBER,
  p_preview_obj_id      IN NUMBER,
  p_preview_row_group   IN VARCHAR2,
  p_preview_display_seq IN NUMBER,
  p_request_id          IN NUMBER,
  p_map_obj_id          IN VARCHAR2,
  p_map_obj_def_id      IN VARCHAR2,
  p_map_rule_type       IN VARCHAR2,
  p_fact_table_name     IN VARCHAR2,
  p_function_cd         IN VARCHAR2,
  p_sub_obj_id          IN NUMBER,
  x_map_where_clause    OUT NOCOPY VARCHAR2,
  x_temp_table_name     OUT NOCOPY VARCHAR2
)
-------------------------------------------------------------------------------
IS
--
  C_MODULE             CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_mapping_preview_util_pkg.CreateTempTable';
  v_select_clause      VARCHAR2(16383);
  v_from_clause        VARCHAR2(4095);
  v_where_clause       VARCHAR2(32767);
  v_return_status      VARCHAR2(1);
  v_msg_count          NUMBER;
  v_msg_data           VARCHAR2(4000);
  v_index_name         VARCHAR2(30);
  v_index_columns      VARCHAR2(4000);
--
  CURSOR c_index_cols (cv_table_name VARCHAR2) IS
    SELECT c.column_name
    FROM dba_ind_columns c, user_synonyms s, fem_tables_b t
    WHERE t.table_name = cv_table_name
    AND t.table_name = s.synonym_name
    AND s.table_name = c.table_name
    AND t.proc_key_index_owner = c.table_owner
    AND t.proc_key_index_name = c.index_name
    AND t.proc_key_index_owner = c.index_owner
    ORDER BY column_position;
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_fact_table_name = '||p_fact_table_name);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_preview_row_group = '||p_preview_row_group);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_function_cd = '||p_function_cd);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_sub_obj_id = '||p_sub_obj_id);

  END IF;

  -- First get a unique temp table name
  FEM_DATABASE_UTIL_PKG.Get_Unique_Temp_Name(
    p_api_version           => 1.0,
    p_init_msg_list         => FND_API.G_FALSE,
    p_commit                => FND_API.G_FALSE,
    p_encoded               => FND_API.G_TRUE,
    x_return_status         => v_return_status,
    x_msg_count             => v_msg_count,
    x_msg_data              => v_msg_data,
    p_temp_type             => 'TABLE',
    p_request_id            => p_request_id,
    p_object_id             => p_preview_obj_id,
    p_table_seq             => p_temp_table_seq,
    x_temp_name             => x_temp_table_name);

  IF v_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'INTERNAL ERROR: Call to'
                    ||' FEM_DATABASE_UTIL_PKG.Get_Unique_Temp_Name'
                    ||' failed with return status: '||v_return_status);
    END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Then build the SQL to create the temporary SQL
  GetSelectClause(
    p_preview_obj_def_id    => p_preview_obj_def_id,
    p_preview_obj_id        => p_preview_obj_id,
    p_request_id            => p_request_id,
    p_preview_row_group     => p_preview_row_group,
    p_fact_table_name       => p_fact_table_name,
    x_select_clause         => v_select_clause);

  GetFromClause(
    p_fact_table_name         => p_fact_table_name,
    x_from_clause             => v_from_clause);

  GetWhereClause(
    p_preview_obj_def_id      => p_preview_obj_def_id,
    p_preview_row_group       => p_preview_row_group,
    p_map_obj_def_id          => p_map_obj_def_id ,
    p_map_rule_type           => p_map_rule_type,
    p_function_cd             => p_function_cd,
    p_sub_obj_id              => p_sub_obj_id,
    p_fact_table_name         => p_fact_table_name ,
    p_request_id              => p_request_id,
    p_preview_obj_id          => p_preview_obj_id,
    x_map_where_clause        => x_map_where_clause,
    x_where_clause            => v_where_clause);

  -- Create the temp table
  FEM_DATABASE_UTIL_PKG.Create_Temp_Table(
    p_api_version           => 1.0,
    p_init_msg_list         => FND_API.G_FALSE,
    p_commit                => FND_API.G_FALSE,
    p_encoded               => FND_API.G_TRUE,
    x_return_status         => v_return_status,
    x_msg_count             => v_msg_count,
    x_msg_data              => v_msg_data,
    p_request_id            => p_request_id,
    p_object_id             => p_preview_obj_id,
    p_pb_object_id          => p_map_obj_id,
    p_table_name            => x_temp_table_name,
    p_table_def             => 'AS '||v_select_clause||' '
                             ||v_from_clause||' '||v_where_clause);

  IF v_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'INTERNAL ERROR: Call to'
                    ||' FEM_DATABASE_UTIL_PKG.Create_Temp_Table'
                    ||' failed with return status: '||v_return_status);
    END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- First see if there are any index columns
  FOR index_col IN c_index_cols(cv_table_name => p_fact_table_name) LOOP
    IF v_index_columns IS NULL THEN
      v_index_columns := index_col.column_name;
    ELSE
      v_index_columns := v_index_columns||','||index_col.column_name;
    END IF;
  END LOOP;

  IF v_index_columns IS NOT NULL THEN

    -- Get a unique temp index name before creating it
    FEM_DATABASE_UTIL_PKG.Get_Unique_Temp_Name(
      p_api_version           => 1.0,
      p_init_msg_list         => FND_API.G_FALSE,
      p_commit                => FND_API.G_FALSE,
      p_encoded               => FND_API.G_TRUE,
      x_return_status         => v_return_status,
      x_msg_count             => v_msg_count,
      x_msg_data              => v_msg_data,
      p_temp_type             => 'INDEX',
      p_request_id            => p_request_id,
      p_object_id             => p_preview_obj_id,
      p_table_seq             => p_temp_table_seq,
      x_temp_name             => v_index_name);

    IF v_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_unexpected,
          p_module   => C_MODULE,
          p_msg_text => 'INTERNAL ERROR: Call to'
                      ||' FEM_DATABASE_UTIL_PKG.Get_Unique_Temp_Name'
                      ||' failed with return status: '||v_return_status);
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    FEM_DATABASE_UTIL_PKG.Create_Temp_Index(
      p_api_version           => 1.0,
      p_init_msg_list         => FND_API.G_FALSE,
      p_commit                => FND_API.G_FALSE,
      p_encoded               => FND_API.G_TRUE,
      x_return_status         => v_return_status,
      x_msg_count             => v_msg_count,
      x_msg_data              => v_msg_data,
      p_request_id            => p_request_id,
      p_object_id             => p_preview_obj_id,
      p_pb_object_id          => p_map_obj_id,
      p_table_name            => x_temp_table_name,
      p_index_name            => v_index_name,
      p_index_columns         => v_index_columns,
      p_unique_flag           => 'Y');

    IF v_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_unexpected,
          p_module   => C_MODULE,
          p_msg_text => 'INTERNAL ERROR: Call to'
                      ||' FEM_DATABASE_UTIL_PKG.Create_Temp_Index'
                      ||' failed with return status: '||v_return_status);
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF; -- IF v_index_columns IS NOT NULL


  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
END CreateTemptable;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- PROCEDURE
--   CreatePreviewStats
--
-- DESCRIPTION
--   Inserts a row into FEM_ALLOC_PREVIEW_STATS with the temp table
--   information.  In Post_Process, the stats rows will be updated with
--   the preview statistics.
--
-------------------------------------------------------------------------------
PROCEDURE CreatePreviewStats(
  p_preview_obj_def_id     IN NUMBER,
  p_preview_row_group      IN VARCHAR2,
  p_preview_display_seq    IN NUMBER,
  p_fact_table_name        IN VARCHAR2,
  p_temp_table_name        IN VARCHAR2,
  p_map_where_clause       IN VARCHAR2,
  p_preview_obj_id         IN NUMBER,
  p_request_id             IN NUMBER
)
-------------------------------------------------------------------------------
IS
--
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_mapping_preview_util_pkg.CreatePreviewStats';
  v_row_count         NUMBER;
  v_sql               VARCHAR2(32767);
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Determine the value to store in the ESTIMATED_ROWS column.
  -- It represents the number of rows that CCE would pull into the
  -- calculations if the mapping rule were running in a normal execution
  -- (i.e. not Preview mode).  This only applies to source and driver data.
  IF p_preview_row_group IN (G_SOURCE, G_DRIVER) THEN

    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'p_map_where_clause = '||p_map_where_clause);
    END IF;

    v_sql := 'SELECT count(*)'
           ||' FROM '||p_fact_table_name||' '||G_FACT_ALIAS;

    IF (p_map_where_clause IS NOT NULL) THEN
      v_sql := v_sql || ' WHERE '||p_map_where_clause;
    END IF;

    EXECUTE IMMEDIATE v_sql INTO v_row_count;

  END IF;

  -- Insert the temp table information into FEM_ALLOC_PREVIEW_STATS
  INSERT INTO fem_alloc_preview_stats (
    preview_obj_def_id, preview_row_group, preview_row_group_display_seq,
    fact_table_name, temp_table_name, estimated_rows, created_by_request_id,
    created_by_object_id, last_updated_by_request_id, last_updated_by_object_id)
  VALUES (
    p_preview_obj_def_id, p_preview_row_group, p_preview_display_seq,
    p_fact_table_name, p_temp_table_name, v_row_count, p_request_id,
    p_preview_obj_id, p_request_id, p_preview_obj_id);


  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
END CreatePreviewStats;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- PROCEDURE
--   CreatePreviewMaps
--
-- DESCRIPTION
--   Inserts the dimension member column and dimension
--   member name column names in FEM_ALLOC_PREVIEW_MAPS.
--
-------------------------------------------------------------------------------
PROCEDURE CreatePreviewMaps(
  p_preview_obj_def_id     IN NUMBER,
  p_preview_row_group      IN VARCHAR2,
  p_fact_table_name        IN VARCHAR2,
  p_preview_obj_id         IN NUMBER,
  p_request_id             IN NUMBER
)
-------------------------------------------------------------------------------
IS
--
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_mapping_preview_util_pkg.CreatePreviewMaps';
  v_row_count         NUMBER;
  v_sql               VARCHAR2(32767);
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Insert the dimension member column and dimension
  -- member name column names in FEM_ALLOC_PREVIEW_MAPS.
  INSERT INTO fem_alloc_preview_maps(
      preview_obj_def_id, preview_row_group, dim_member_column_name,
      dim_name_column_name, created_by_request_id, created_by_object_id,
      last_updated_by_request_id, last_updated_by_object_id)
    SELECT p_preview_obj_def_id, p_preview_row_group, tc.column_name,
           substr('FEM'||rownum||'_'||p_request_id, 1, 30),
           p_request_id, p_preview_obj_id,
           p_request_id, p_preview_obj_id
    FROM fem_tab_columns_v tc
    WHERE tc.table_name = p_fact_table_name
    AND tc.fem_data_type_code = 'DIMENSION'
    AND tc.column_name IN
      (SELECT tcp.column_name
       FROM fem_tab_column_prop tcp
       WHERE tcp.table_name = tc.table_name
       AND tcp.column_property_code IN
         ('MAPPING_UI_INPUT', 'PROCESSING_KEY'))
    AND tc.column_name <> 'LEDGER_ID';


  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
END CreatePreviewMaps;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- PROCEDURE
--   GetSelectClause
--
-- DESCRIPTION
--   Constructs the SELECT clause to create the temporary table.
--   The structure of the SELECT clause is the same irrespective
--   of the mapping rule type or whether it is for an input or output table:
--     SELECT F.*, D.template_dim_name AS fem1_1234567,
--                 D.template_dim_name AS fem2_1234567, ...
--
-------------------------------------------------------------------------------
PROCEDURE GetSelectClause(
  p_preview_obj_def_id     IN NUMBER,
  p_preview_obj_id         IN NUMBER,
  p_request_id             IN NUMBER,
  p_preview_row_group      IN VARCHAR2,
  p_fact_table_name        IN VARCHAR2,
  x_select_clause          OUT NOCOPY VARCHAR2
)
-------------------------------------------------------------------------------
IS
--
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_mapping_preview_util_pkg.GetSelectClause';
--
  CURSOR c_dim (cv_preview_obj_def_id IN NUMBER,
                cv_preview_row_group IN VARCHAR2) IS
    SELECT dim_name_column_name
    FROM fem_alloc_preview_maps
    WHERE preview_obj_def_id = cv_preview_obj_def_id
    AND preview_row_group = cv_preview_row_group;
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;


  -- Start off the SELECT clause.
  -- i.e. 'SELECT F.*'
  x_select_clause := 'SELECT '||G_FACT_ALIAS||'.*';

  -- Then loop through FEM_ALLOC_PREVIEW_MAPS to get the
  -- dimension member name column names to append to the SELECT clause.
  -- i.e. ||', D.template_dim_name AS fem1_1234567'
  FOR dims IN c_dim(cv_preview_obj_def_id => p_preview_obj_def_id,
                    cv_preview_row_group  => p_preview_row_group) LOOP

    x_select_clause := x_select_clause||', '||G_DIM_ALIAS||'.'
                     ||'template_dim_name AS '
                     ||dims.dim_name_column_name;

  END LOOP;


  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'x_select_clause = '||x_select_clause);
  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
END GetSelectClause;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- PROCEDURE
--   GetMapTableType
--
-- DESCRIPTION
--   Gets the Mapping Table Type given a fact table.
--   The possibilities are:
--     Ledger type (G_LEDGER_TYPE)
--     Account or Transaction type (G_ACCT_TRANS_TYPE)
--     Other type (G_OTHER_TABLE_TYPE), such as statistic or factor table
-------------------------------------------------------------------------------
PROCEDURE GetMapTableType(
  p_table_name             IN VARCHAR2,
  x_map_table_type         OUT NOCOPY VARCHAR2
)
-------------------------------------------------------------------------------
IS
--
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_mapping_preview_util_pkg.GetMapTableType';
  v_is_ledger         VARCHAR2(1);
  v_is_acct_trans     VARCHAR2(1);
--
  -- Returns T if table is a "ledger" table and F otherwise
  CURSOR c_is_ledger(cv_table_name VARCHAR2) IS
    SELECT decode(count(*),0,'F','T')
    FROM fem_table_class_assignmt_v
    WHERE table_name = cv_table_name
    AND substr(table_classification_code,-6) = 'LEDGER';

  -- Returns T if table is an "account or transaction" table and F otherwise
  CURSOR c_is_acct_trans(cv_table_name VARCHAR2) IS
    SELECT decode(count(*),0,'F','T')
    FROM fem_table_class_assignmt_v
    WHERE table_name = cv_table_name
    AND table_classification_code IN ('ACCOUNT_PROFITABILITY',
                                      'TRANSACTION_PROFITABILITY');
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- See if table is a ledger table first
  OPEN c_is_ledger(p_table_name);
  FETCH c_is_ledger INTO v_is_ledger;
  CLOSE c_is_ledger;

  IF v_is_ledger = 'T' THEN
    x_map_table_type := G_LEDGER_TYPE;
  ELSE
    -- If table is not a ledger table,
    -- see if table is an account or transaction table.
    OPEN c_is_acct_trans(p_table_name);
    FETCH c_is_acct_trans INTO v_is_acct_trans;
    CLOSE c_is_acct_trans;

    IF v_is_acct_trans = 'T' THEN
      x_map_table_type := G_ACCT_TRANS_TYPE;
    ELSE
      -- Since it is not an account or transaction table,
      -- it must be some other type that we don't care about yet...
      x_map_table_type := G_OTHER_TABLE_TYPE;
    END IF;
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'x_map_table_type = '||x_map_table_type);
  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
END GetMapTableType;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- PROCEDURE
--   GetOutputMatchingTable
--
-- BACKGROUND
--   Unlike ledger tables, if the output table is an account or transaction
--   table, the corresponding temporary table needs to be created with data
--   from the output fact table already populated in it.  The reason why
--   data needs to exist in the temporary output table before Preview
--   begins processing is that CCE only performs updates on the output table
--   if it is an account or transaction table.  In contrast, CCE always
--   inserts into ledger tables.  Therefore, if the output table is
--   a ledger table, the temporary table does not need to be created with
--   data already populated in it.
--
--   Instead of creating a complete copy of the output fact table when
--   creating the corresponding temporary table, only preload the temporary
--   output table with the set of data that will be updated.
--   However, since determining the exact set of output data that will be
--   updated is rewriting a good portion of the CCE, the preloaded data
--   will just be based on the data that match with the corresponding
--   input account or transaction table, or the "output matching table".
--
-- DESCRIPTION
--   The purpose of this procedure is to determine the "output matching table".
--   The "output matching table" is the temporary driver table,
--   unless the driver is a ledger table or there is no driver table.
--   Otherwise, the "output matching table" is the temporary source table.
--   The statistic table is not considered a driver table for the purpose
--   of determining the "output matching table".  In other words,
--   for a Retrieve Statistic rule type, the "output matching table"
--   is the temporary source table.
--
-- ASSUMPTION
--   Before this API can be called, the temporary tables for the source
--   and driver tables have to be first created.  That is the purpose
--   of the FEM_FUNCTION_CD_MAPPING.PREVIEW_ROW_GROUP_PROCESS_SEQ column.
--   The Pre_Process procedure relies on that column to determine the
--   order in which to create the temporary tables.
--
-------------------------------------------------------------------------------
PROCEDURE GetOutputMatchingTable(
  p_preview_obj_def_id      IN NUMBER,
  x_output_match_temp_table OUT NOCOPY VARCHAR2,
  x_output_match_fact_table OUT NOCOPY VARCHAR2
)
-------------------------------------------------------------------------------
IS
--
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_mapping_preview_util_pkg.GetOutputMatchingTable';
  v_map_rule_type     FEM_ALLOC_BR_OBJECTS.map_rule_type_code%TYPE;
  v_fact_table_name   FEM_ALLOC_PREVIEW_STATS.fact_table_name%TYPE;
  v_temp_table_name   FEM_ALLOC_PREVIEW_STATS.temp_table_name%TYPE;
  v_map_table_type    VARCHAR2(30);
  v_temp_table_group  FEM_ALLOC_PREVIEW_STATS.preview_row_group%TYPE;
--
  -- Retrieves the temporary and fact table names
  -- given the Preview Row Group and Preview rule version
  CURSOR c_preview_tables (cv_preview_obj_def_id IN NUMBER,
                           cv_preview_row_group IN VARCHAR2) IS
    SELECT s.temp_table_name, s.fact_table_name
    FROM fem_alloc_preview_stats s
    WHERE s.preview_obj_def_id = cv_preview_obj_def_id
    AND s.preview_row_group = cv_preview_row_group;
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- First assume the temp table group is DRIVER
  v_temp_table_group := G_DRIVER;

  -- See if a driver table exists
  OPEN c_preview_tables(p_preview_obj_def_id, v_temp_table_group);
  FETCH c_preview_tables INTO v_temp_table_name, v_fact_table_name;
  CLOSE c_preview_tables;

  IF v_temp_table_name IS NULL THEN
    -- If no driver, then output match table must be the TEMP SOURCE table
    v_temp_table_group := G_SOURCE;
  ELSE
    -- If a driver table exists, check the mapping table type.
    GetMapTableType(
      p_table_name       => v_fact_table_name,
      x_map_table_type   => v_map_table_type);

    -- If driver table type is not account/trans, then output match table
    -- is the TEMP SOURCE table.
    IF v_map_table_type <> G_ACCT_TRANS_TYPE THEN
      v_temp_table_group := G_SOURCE;
    END IF;
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'v_temp_table_group = '||v_temp_table_group);
  END IF;

  -- If the temp table group is no longer DRIVER, then get the
  -- temp table name associated with the new temp table group.
  IF v_temp_table_group <> G_DRIVER THEN
    OPEN c_preview_tables(p_preview_obj_def_id, v_temp_table_group);
    FETCH c_preview_tables INTO v_temp_table_name, v_fact_table_name;
    CLOSE c_preview_tables;
  END IF;

  x_output_match_temp_table := v_temp_table_name;
  x_output_match_fact_table := v_fact_table_name;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'x_output_match_temp_table = '||x_output_match_temp_table);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'x_output_match_fact_table = '||x_output_match_fact_table);
  END IF;

  -- An output match table should always be found.
  -- If not, then raise unexpected error...
  IF x_output_match_temp_table IS NULL THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'x_output_match_temp_table should NOT be NULL!');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
END GetOutputMatchingTable;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- PROCEDURE
--   GetFromClause
--
-- DESCRIPTION
--   Constructs the FROM clause to create the temporary table.
--   The FROM clause looks like this for all table types:
--     FROM <fact table> F, fem_dim_template D
--
-------------------------------------------------------------------------------
PROCEDURE GetFromClause(
  p_fact_table_name         IN VARCHAR2,
  x_from_clause             OUT NOCOPY VARCHAR2
)
-------------------------------------------------------------------------------
IS
--
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_mapping_preview_util_pkg.GetFromClause';
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Set the FROM clause in the form of:
  --   FROM <output fact table> a, fem_dim_template b
  x_from_clause := ' FROM '||p_fact_table_name||' '||G_FACT_ALIAS||', '
                 ||G_DIM_TEMPLATE_TABLE||' '||G_DIM_ALIAS;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'x_from_clause = '||x_from_clause);
  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
END GetFromClause;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- PROCEDURE
--   GetInputWhereClause
--
-- DESCRIPTION
--   Constructs the WHERE clause to create the temporary input table.
--   The general structure of the WHERE clause is:
--      WHERE <condition filter in mapping rule>
--      AND <parameter filter>
--      AND <preview filter>
--      AND rownum <= <maximum number of rows parameter>
--   If the table is a Statistic table and the row group is DRIVER,
--   then the WHERE CLAUSE looks like:
--      WHERE <statistic condition filter>
--      AND <constant columns>
--      AND <preview filter>
--      AND rownum <= <maximum number of rows parameter>
--
-------------------------------------------------------------------------------
PROCEDURE GetInputWhereClause(
  p_preview_obj_def_id     IN NUMBER,
  p_preview_row_group      IN VARCHAR2,
  p_map_obj_def_id         IN NUMBER,
  p_map_rule_type          IN VARCHAR2,
  p_fact_table_name        IN VARCHAR2,
  p_sub_obj_id             IN NUMBER,
  p_request_id             IN NUMBER,
  p_preview_obj_id         IN NUMBER,
  x_map_where_clause       OUT NOCOPY VARCHAR2,
  x_where_clause           OUT NOCOPY VARCHAR2
)
-------------------------------------------------------------------------------
IS
--
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_mapping_preview_util_pkg.GetInputWhereClause';
  v_map_table_type    VARCHAR2(30);
  v_condition_filter  VARCHAR2(16000);
  v_return_status     VARCHAR2(1);
  v_msg_count         NUMBER;
  v_msg_data          VARCHAR2(4000);
  v_effective_date    VARCHAR2(30);
  v_ledger_id         FEM_ALLOC_PREVIEWS.ledger_id%TYPE;
  v_cal_period_id     FEM_ALLOC_PREVIEWS.cal_period_id %TYPE;
  v_dsg_obj_def_id    FEM_ALLOC_PREVIEWS.dsg_obj_def_id%TYPE;
  v_query_row_limit   FEM_ALLOC_PREVIEWS.query_row_limit%TYPE;
  v_stat_obj_def_id   FEM_OBJECT_DEFINITION_B.object_definition_id%TYPE;
  v_stat_cond_obj_def_id FEM_STAT_LOOKUPS.condition_obj_def_id%TYPE;
  v_preview_cond_obj_id  FEM_ALLOC_PREVIEWS.source_condition_obj_id%TYPE;
  v_by_dimension_column  FEM_ALLOC_BR_DIMENSIONS.alloc_dim_col_name%TYPE;
  v_by_dimension_id      FEM_DIMENSIONS_B.dimension_id%TYPE;
  v_by_dimension_value   VARCHAR2(38);  -- max size of number
--
  CURSOR c_stat_cols (cv_stat_obj_def_id NUMBER) IS
    SELECT stat_lookup_tbl_col, relational_operand, value
    FROM fem_stat_lookup_rel s
    WHERE s.stat_lookup_obj_def_id = cv_stat_obj_def_id
    AND s.value IS NOT NULL;
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Get various preview attributes
  SELECT FND_DATE.Date_To_Canonical(effective_date),
         ledger_id, cal_period_id, dsg_obj_def_id, query_row_limit,
         decode(p_preview_row_group, G_SOURCE, source_condition_obj_id,
                                               driver_condition_obj_id)
  INTO   v_effective_date, v_ledger_id, v_cal_period_id, v_dsg_obj_def_id,
         v_query_row_limit, v_preview_cond_obj_id
  FROM   fem_alloc_previews
  WHERE  preview_obj_def_id = p_preview_obj_def_id;

  -- The general structure of the WHERE clause is:
  --   WHERE <condition filter in mapping rule>
  --   AND <parameter filter>
  --   AND <preview filter>
  --   AND rownum <= <maximum number of rows parameter>
  IF (p_map_rule_type <> G_RETRIEVE_STAT) OR
     (p_preview_row_group <> G_DRIVER) THEN

    -- Set the by dimension parameters to pass into the Predicate procedure
    GetByDimParams(
      p_preview_obj_def_id      => p_preview_obj_def_id,
      p_preview_row_group       => p_preview_row_group,
      p_map_obj_def_id          => p_map_obj_def_id,
      p_map_rule_type           => p_map_rule_type,
      p_fact_table_name         => p_fact_table_name,
      x_by_dimension_column     => v_by_dimension_column,
      x_by_dimension_id         => v_by_dimension_id,
      x_by_dimension_value      => v_by_dimension_value);

    -- Get <condition filter + parameter filter>
    FEM_ASSEMBLER_PREDICATE_API.Generate_Assembler_Predicate(
      x_predicate_string     => x_where_clause,
      x_return_status        => v_return_status,
      x_msg_count            => v_msg_count,
      x_msg_data             => v_msg_data,
      p_condition_obj_id     => p_sub_obj_id,
      p_rule_effective_date  => v_effective_date,
      p_DS_IO_Def_ID         => v_dsg_obj_def_id,
      p_Output_Period_ID     => v_cal_period_id,
      p_Request_ID           => p_request_id,
      p_Object_ID            => p_preview_obj_id,
      p_Ledger_ID            => v_ledger_id,
      p_by_dimension_column  => v_by_dimension_column,
      p_by_dimension_id      => v_by_dimension_id,
      p_by_dimension_value   => v_by_dimension_value,
      p_fact_table_name      => p_fact_table_name,
      p_table_alias          => G_FACT_ALIAS,
      p_Ledger_Flag          => 'N',
      p_api_version          => 1.0,
      p_init_msg_list        => FND_API.G_FALSE,
      p_commit               => FND_API.G_FALSE,
      p_encoded              => FND_API.G_TRUE);

    IF v_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_statement,
          p_module   => C_MODULE,
          p_msg_text => 'INTERNAL ERROR: Call to'
                      ||' FEM_ASSEMBLER_PREDICATE_API.Generate_Assembler_Predicate'
                      ||' failed with return status: '||v_return_status);
      END IF;
    END IF;

    -- Assembler API should always generate some WHERE clause
    IF x_where_clause IS NULL THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  ELSE
  -- If the table is a Statistic table and the row group is DRIVER,
  -- then the WHERE CLAUSE looks like:
  --   WHERE <statistic condition filter>
  --   AND <constant columns>
  --   AND <preview filter>
  --   AND rownum <= <maximum number of rows parameter>

    -- First get Stat Lookup obj def id
    SELECT object_definition_id
    INTO v_stat_obj_def_id
    FROM fem_object_definition_b
    WHERE object_id = p_sub_obj_id;

    -- Then build the WHERE clause for the stat columns that is bound to
    -- defined values as part of the stat definition.
    FOR stat_col IN c_stat_cols(cv_stat_obj_def_id => v_stat_obj_def_id) LOOP

      IF x_where_clause IS NOT NULL THEN
        x_where_clause := x_where_clause||' AND ';
      END IF;

      x_where_clause := x_where_clause||G_FACT_ALIAS||'.'
                      ||stat_col.stat_lookup_tbl_col
                      ||stat_col.relational_operand||''''
                      ||stat_col.value||'''';

    END LOOP;

     -- Get <statistic condition filter> if one exists
    SELECT condition_obj_def_id
    INTO v_stat_cond_obj_def_id
    FROM fem_stat_lookups
    WHERE stat_lookup_obj_def_id = v_stat_obj_def_id;

    IF v_stat_cond_obj_def_id IS NOT NULL THEN
      FEM_CONDITIONS_API.generate_condition_predicate(
        p_api_version            => 1.0,
        p_init_msg_list          => FND_API.G_FALSE,
        p_commit                 => FND_API.G_FALSE,
        p_encoded                => FND_API.G_TRUE,
        p_condition_obj_id       => FEM_BUSINESS_RULE_PVT.GetObjectId(
                                      p_obj_def_id => v_stat_cond_obj_def_id),
        p_rule_effective_date    => v_effective_date,
        p_input_fact_table_name  => p_fact_table_name,
        p_table_alias            => G_FACT_ALIAS,
        p_display_predicate      => 'N',
        p_return_predicate_type  => 'BOTH',
        p_logging_turned_on      => 'Y',
        x_return_status          => v_return_status,
        x_msg_count              => v_msg_count,
        x_msg_data               => v_msg_data,
        x_predicate_string       => v_condition_filter);

      IF v_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => FND_LOG.level_statement,
            p_module   => C_MODULE,
            p_msg_text => 'INTERNAL ERROR: Call to'
                        ||' FEM_CONDITIONS_API.generate_condition_predicate'
                        ||' failed with return status: '||v_return_status);
        END IF;

        -- Only raise error if return status is Unexpected Error because
        -- the Condition API can return with error even if the issue
        -- is that a dimension/column does not exist on the table that
        -- the condition applied to.  This is not an error condition from
        -- the CCE perspective.
        IF v_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;

      -- Only append if condition filter is not null
      IF v_condition_filter IS NOT NULL THEN
        x_where_clause := x_where_clause||' AND '||v_condition_filter;
      END IF;
    END IF; -- IF v_stat_cond_obj_def_id IS NOT NULL THEN

  END IF;  -- IF p_map_rule_type <> G_RETRIEVE_STAT THEN

  -- Before appending the additional preview filter, store the
  -- WHERE clause just based on the parameters and mapping rule definition.
  -- This will be used later when creating the Preview Statistics
  -- to get the number of rows that CCE would pull into the calculations
  -- if the mapping rule were running in a normal execution
  -- (i.e. not Preview mode).
  x_map_where_clause := x_where_clause;

  -- Get <preview filter> if one exists
  IF v_preview_cond_obj_id IS NOT NULL THEN
    FEM_CONDITIONS_API.generate_condition_predicate(
      p_api_version            => 1.0,
      p_init_msg_list          => FND_API.G_FALSE,
      p_commit                 => FND_API.G_FALSE,
      p_encoded                => FND_API.G_TRUE,
      p_condition_obj_id       => v_preview_cond_obj_id,
      p_rule_effective_date    => v_effective_date,
      p_input_fact_table_name  => p_fact_table_name,
      p_table_alias            => G_FACT_ALIAS,
      p_display_predicate      => 'N',
      p_return_predicate_type  => 'BOTH',
      p_logging_turned_on      => 'Y',
      x_return_status          => v_return_status,
      x_msg_count              => v_msg_count,
      x_msg_data               => v_msg_data,
      x_predicate_string       => v_condition_filter);

    IF v_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_statement,
          p_module   => C_MODULE,
          p_msg_text => 'INTERNAL ERROR: Call to'
                      ||' FEM_CONDITIONS_API.generate_condition_predicate'
                      ||' failed with return status: '||v_return_status);
      END IF;

      -- Only raise error if return status is Unexpected Error because
      -- the Condition API can return with error even if the issue
      -- is that a dimension/column does not exist on the table that
      -- the condition applied to.  This is not an error condition from
      -- the CCE perspective.
      IF v_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    -- Only append if condition filter is not null
    IF v_condition_filter IS NOT NULL THEN
      x_where_clause := x_where_clause||' AND '||v_condition_filter;
    END IF;

  END IF; -- IF p_preview_cond_obj_id IS NOT NULL THEN

  -- Finally, add the WHERE keyword and query row limit
  IF x_where_clause IS NULL THEN
    x_where_clause := 'WHERE '||'rownum <= '||v_query_row_limit;
  ELSE
    x_where_clause := 'WHERE '||x_where_clause
                    ||' AND '||'rownum <= '||v_query_row_limit;
  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
END GetInputWhereClause;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- PROCEDURE
--   GetOutputWhereClause
--
-- DESCRIPTION
--   Constructs the WHERE clause to create the temporary output table.
--   If the table is a Ledger table, the WHERE clause is:
--     	WHERE 1=0
--   If the table is an account/transaction table,
--   then the WHERE clause looks like:
--      WHERE <same as value filter>
--      AND <matching table filter>
--
--   Matching table filter:
--      (PK_COL1, PK_COL2, ... ) IN (SELECT PK_COL1, PK_COL2, ...
--                                   FROM <output matching table>)
-------------------------------------------------------------------------------
PROCEDURE GetOutputWhereClause(
  p_preview_obj_def_id      IN NUMBER,
  p_map_obj_def_id          IN NUMBER,
  p_function_cd             IN VARCHAR2,
  p_fact_table_name         IN VARCHAR2,
  x_where_clause            OUT NOCOPY VARCHAR2
)
-------------------------------------------------------------------------------
IS
--
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_mapping_preview_util_pkg.GetOutputWhereClause';
  v_map_table_type    VARCHAR2(30);
  v_output_match_temp_table VARCHAR2(30);
  v_output_match_fact_table VARCHAR2(30);
  v_output_pk_sql     VARCHAR2(8000);
  v_match_pk_sql      VARCHAR2(8000);
--
  CURSOR c_value_cols (cv_map_obj_def_id NUMBER, cv_function_cd VARCHAR2) IS
    SELECT alloc_dim_col_name, nvl(to_char(dimension_value),
                                   dimension_value_char) dim_value
    FROM fem_alloc_br_dimensions
    WHERE object_definition_id = cv_map_obj_def_id
    AND function_cd = cv_function_cd
    AND alloc_dim_usage_code = 'VALUE';

  CURSOR c_match_cols (cv_fact_table VARCHAR2, cv_match_fact_table VARCHAR2,
                       cv_map_obj_def_id NUMBER, cv_function_cd VARCHAR) IS
    SELECT o.column_name output_col, m.column_name match_col
    FROM fem_tab_column_prop o, fem_tab_columns_v m
    WHERE o.table_name = cv_fact_table
    AND o.column_property_code = 'PROCESSING_KEY'
    AND m.table_name = cv_match_fact_table
    AND o.column_name = m.column_name
    AND o.column_name NOT IN
      (SELECT alloc_dim_col_name
       FROM fem_alloc_br_dimensions
       WHERE object_definition_id = cv_map_obj_def_id
       AND function_cd = cv_function_cd
       AND alloc_dim_usage_code = 'VALUE');

--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- First get mapping table type
  GetMapTableType(
    p_table_name       => p_fact_table_name,
    x_map_table_type   => v_map_table_type);

  IF v_map_table_type = G_LEDGER_TYPE THEN

    x_where_clause := '1=0';

  ELSIF v_map_table_type = G_ACCT_TRANS_TYPE THEN

    -- First restrict based on those columns with values already defined
    FOR value_col IN c_value_cols(cv_map_obj_def_id => p_map_obj_def_id,
                                  cv_function_cd    => p_function_cd) LOOP
      IF value_col.dim_value IS NOT NULL THEN

        IF x_where_clause IS NOT NULL THEN
          x_where_clause := x_where_clause||' AND ';
        END IF;

        x_where_clause := x_where_clause||G_FACT_ALIAS||'.'
                        ||value_col.alloc_dim_col_name
                        ||'='''||value_col.dim_value||'''';
      END IF;
    END LOOP;

    -- Get matching output table information
    GetOutputMatchingTable(
      p_preview_obj_def_id      => p_preview_obj_def_id,
      x_output_match_temp_table => v_output_match_temp_table,
      x_output_match_fact_table => v_output_match_fact_table);

    -- Then restrict based on matching processing key columns between
    -- output table and matching output table.
    FOR match_col IN c_match_cols(cv_fact_table  => p_fact_table_name,
                             cv_match_fact_table => v_output_match_fact_table,
                             cv_map_obj_def_id   => p_map_obj_def_id,
                             cv_function_cd      => p_function_cd) LOOP

      IF v_output_pk_sql IS NOT NULL THEN
        v_output_pk_sql := v_output_pk_sql||',';
        v_match_pk_sql := v_match_pk_sql||',';
      END IF;

      v_output_pk_sql := v_output_pk_sql
                       ||G_FACT_ALIAS||'.'||match_col.output_col;
      v_match_pk_sql := v_match_pk_sql
                       ||G_MATCH_ALIAS||'.'||match_col.match_col;

    END LOOP;

    -- Create <matching table filter>:
    --      (PK_COL1, PK_COL2, ... ) IN (SELECT PK_COL1, PK_COL2, ...
    --                                   FROM <output matching table>)
    IF v_output_pk_sql IS NOT NULL THEN
      IF x_where_clause IS NOT NULL THEN
        x_where_clause := x_where_clause||' AND ';
      END IF;

      x_where_clause := x_where_clause||'('||v_output_pk_sql||')'
                      ||' IN (SELECT '||v_match_pk_sql||' FROM '
                      ||v_output_match_temp_table||' '||G_MATCH_ALIAS||')';
    END IF;

  ELSE

    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'Unsupported output table type: '||v_map_table_type);
    END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  -- Finally, add the WHERE keyword
  IF x_where_clause IS NOT NULL THEN
    x_where_clause := 'WHERE '||x_where_clause;
  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
END GetOutputWhereClause;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- PROCEDURE
--   GetWhereClause
--
-- DESCRIPTION
--   Constructs the WHERE clause to create the temporary table.
--   The structure of the WHERE clause differs depending on the
--   mapping rule type or whether it is for an input or output table.
--
-------------------------------------------------------------------------------
PROCEDURE GetWhereClause(
  p_preview_obj_def_id      IN NUMBER,
  p_preview_row_group       IN VARCHAR2,
  p_map_obj_def_id          IN NUMBER,
  p_map_rule_type           IN VARCHAR2,
  p_function_cd             IN VARCHAR2,
  p_sub_obj_id              IN NUMBER,
  p_fact_table_name         IN VARCHAR2,
  p_request_id              IN NUMBER,
  p_preview_obj_id          IN NUMBER,
  x_map_where_clause        OUT NOCOPY VARCHAR2,
  x_where_clause            OUT NOCOPY VARCHAR2
)
-------------------------------------------------------------------------------
IS
--
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_mapping_preview_util_pkg.GetWhereClause';
  v_map_table_type    VARCHAR2(30);
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  IF p_preview_row_group IN (G_SOURCE, G_DRIVER) THEN

    GetInputWhereClause(
      p_preview_obj_def_id   => p_preview_obj_def_id,
      p_preview_row_group    => p_preview_row_group,
      p_map_obj_def_id       => p_map_obj_def_id,
      p_map_rule_type        => p_map_rule_type,
      p_fact_table_name      => p_fact_table_name ,
      p_sub_obj_id           => p_sub_obj_id,
      p_request_id           => p_request_id,
      p_preview_obj_id       => p_preview_obj_id,
      x_map_where_clause     => x_map_where_clause,
      x_where_clause         => x_where_clause);

  ELSE

    GetOutputWhereClause(
      p_preview_obj_def_id      => p_preview_obj_def_id,
      p_map_obj_def_id          => p_map_obj_def_id,
      p_function_cd             => p_function_cd,
      p_fact_table_name         => p_fact_table_name,
      x_where_clause            => x_where_clause);

  END IF;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'x_where_clause = '||x_where_clause);
  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
END GetWhereClause;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- PROCEDURE
--   UpdatePreviewStats
--
-- DESCRIPTION
--   Populate the following columns in FEM_ALLOC_PREVIEW_STATS:
--   1. PREVIEW_AMOUNT_TOTAL: Sum of the source, driver, debit and credit
--        amounts that CCE used or generated during the Preview run.
--   2. PREVIEW_ROWS: Number of rows for the source and driver data that
--        CCE used during the Preview run.
--
-------------------------------------------------------------------------------
PROCEDURE UpdatePreviewStats(
  p_preview_obj_def_id      IN NUMBER,
  p_preview_row_group       IN VARCHAR2,
  p_temp_table_name         IN VARCHAR2,
  p_map_table_type          IN VARCHAR2,
  p_map_obj_def_id          IN NUMBER,
  p_ledger_id               IN NUMBER,
  p_cal_period_id           IN NUMBER
)
-------------------------------------------------------------------------------
IS
--
  C_MODULE                  CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_mapping_preview_util_pkg.UpdatePreviewStats';
  v_functional_currency     FEM_ALLOC_PREVIEW_STATS.amount_currency_code%TYPE;
  v_amount_total            FEM_ALLOC_PREVIEW_STATS.preview_amount_total%TYPE;
  v_row_count               FEM_ALLOC_PREVIEW_STATS.preview_rows%TYPE;
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  GetPreviewAmount(
    p_preview_obj_def_id      => p_preview_obj_def_id,
    p_preview_row_group       => p_preview_row_group,
    p_temp_table_name         => p_temp_table_name,
    p_map_table_type          => p_map_table_type,
    p_map_obj_def_id          => p_map_obj_def_id,
    p_ledger_id               => p_ledger_id,
    p_cal_period_id           => p_cal_period_id,
    x_functional_currency     => v_functional_currency,
    x_preview_amount_total    => v_amount_total);

  GetPreviewRowCount(
    p_temp_table_name         => p_temp_table_name,
    x_preview_row_count       => v_row_count);

  UPDATE fem_alloc_preview_stats
  SET preview_amount_total = v_amount_total,
      amount_currency_code = v_functional_currency,
      preview_rows = v_row_count
  WHERE preview_obj_def_id = p_preview_obj_def_id
  AND preview_row_group = p_preview_row_group;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
END UpdatePreviewStats;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- PROCEDURE
--   GetPreviewAmount
--
-- DESCRIPTION
--   Returns the summed amount and its associated currency for a given
--   temporary table.  If the individual amounts are represented in
--   currencies other than the functional currency, this procedure will
--   convert those amounts to the functional currency amount before
--   summing them.
--
-------------------------------------------------------------------------------
PROCEDURE GetPreviewAmount(
  p_preview_obj_def_id      IN NUMBER,
  p_preview_row_group       IN VARCHAR2,
  p_temp_table_name         IN VARCHAR2,
  p_map_table_type          IN VARCHAR2,
  p_map_obj_def_id          IN NUMBER,
  p_ledger_id               IN NUMBER,
  p_cal_period_id           IN NUMBER,
  x_functional_currency     OUT NOCOPY VARCHAR2,
  x_preview_amount_total    OUT NOCOPY NUMBER
)
-------------------------------------------------------------------------------
IS
--
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_mapping_preview_util_pkg.GetPreviewAmount';
  v_dim_id            FEM_DIMENSIONS_B.dimension_id%TYPE;
  v_dim_attr_id       FEM_DIM_ATTRIBUTES_B.attribute_id%TYPE;
  v_dim_attr_ver_id   FEM_DIM_ATTR_VERSIONS_B.version_id%TYPE;
  v_return_code       NUMBER;
  v_cal_per_end_date  FEM_CAL_PERIODS_ATTR.date_assign_value%TYPE;
  v_amount_column     FEM_ALLOC_BR_FORMULA.column_name%TYPE;
  v_sql               VARCHAR2(4000);
  v_amount            NUMBER;
  v_conv_amount       NUMBER;
  v_amount_currency   FEM_BALANCES.currency_code%TYPE;
  v_denom             NUMBER;
  v_numer             NUMBER;
  v_rate              NUMBER;

  TYPE RefCurTyp IS REF CURSOR;  -- define weak REF CURSOR type
  amount_cv       RefCurTyp;
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Amount total does not make sense for DRIVER data.
  -- Therefore, this procedure will simply set the amount and currency
  -- OUT params to NULL and return when preview row group is DRIVER.
  IF p_preview_row_group = G_DRIVER THEN
    x_functional_currency := NULL;
    x_preview_amount_total := NULL;
    RETURN;
  END IF;

  --
  -- First get functional currency
  --
  SELECT dimension_id
  INTO v_dim_id
  FROM fem_dimensions_b
  WHERE dimension_varchar_label = 'LEDGER';

  FEM_DIMENSION_UTIL_PKG.get_dim_attr_id_ver_id
           (p_dim_id      => v_dim_id,
            p_attr_label  => 'LEDGER_FUNCTIONAL_CRNCY_CODE',
            x_attr_id     => v_dim_attr_id,
            x_ver_id      => v_dim_attr_ver_id,
            x_err_code    => v_return_code);

  IF v_return_code <> 0 THEN  -- if not success
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'INTERNAL ERROR: Call to'
                    ||' FEM_DIMENSION_UTIL_PKG.get_dim_attr_id_ver_id'
                    ||' to get LEDGER_FUNCTIONAL_CRNCY_CODE attribute'
                    ||' information failed with return code: '||v_return_code);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  SELECT dim_attribute_varchar_member
  INTO x_functional_currency
  FROM fem_ledgers_attr
  WHERE attribute_id  = v_dim_attr_id
  AND version_id    = v_dim_attr_ver_id
  AND ledger_id     = p_ledger_id;

  IF x_functional_currency IS NULL THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'Functional currency does not exist for the ledger'
                    ||' id: '||p_ledger_id);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Then get calendar period end date.
  --
  SELECT dimension_id
  INTO v_dim_id
  FROM fem_dimensions_b
  WHERE dimension_varchar_label = 'CAL_PERIOD';

  FEM_DIMENSION_UTIL_PKG.get_dim_attr_id_ver_id
           (p_dim_id      => v_dim_id,
            p_attr_label  => 'CAL_PERIOD_END_DATE',
            x_attr_id     => v_dim_attr_id,
            x_ver_id      => v_dim_attr_ver_id,
            x_err_code    => v_return_code);

  IF v_return_code <> 0 THEN  -- if not success
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'INTERNAL ERROR: Call to'
                    ||' FEM_DIMENSION_UTIL_PKG.get_dim_attr_id_ver_id'
                    ||' to get CAL_PERIOD_END_DATE attribute'
                    ||' information failed with return code: '||v_return_code);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  SELECT date_assign_value
  INTO v_cal_per_end_date
  FROM fem_cal_periods_attr
  WHERE attribute_id  = v_dim_attr_id
  AND version_id    = v_dim_attr_ver_id
  AND cal_period_id = p_cal_period_id;

  IF v_cal_per_end_date IS NULL THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'Calendar Period End Date does not exist for this'
                    ||' calendar period: '||p_cal_period_id);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.Tech_Message(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'The Calendar Period End Date is '
         ||FND_DATE.date_to_displayDT(v_cal_per_end_date));
  END IF;


  --
  -- Find the amount column for the table.
  --

  -- For Ledger tables, the amount column is always XTD_BALANCE_F.
  -- For Account/Transaction tables, the amount column is stored in
  -- FEM_ALLOC_BR_FORMULA.column_name
  IF p_map_table_type = G_LEDGER_TYPE THEN

    v_amount_column := G_LEDGER_AMOUNT_COL;

  ELSIF p_map_table_type = G_ACCT_TRANS_TYPE THEN

    SELECT f.column_name
    INTO v_amount_column
    FROM fem_alloc_br_formula f, fem_function_cd_mapping m
    WHERE f.object_definition_id = p_map_obj_def_id
    AND f.function_cd = m.function_cd
    AND m.preview_row_group = p_preview_row_group;

    IF v_amount_column IS NULL THEN
      IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_unexpected,
          p_module   => C_MODULE,
          p_msg_text => 'Amount column is null for this preview group: '
                      ||p_preview_row_group);
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  ELSE

    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'Unexpected table classification type: '
                    ||p_map_table_type);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF; -- IF p_map_table_type = G_LEDGER_TYPE THEN

  --
  -- Sum amount column, grouped by currency
  --
  v_sql := 'SELECT SUM('||v_amount_column||'), currency_code'
        ||' FROM '||p_temp_table_name
        ||' GROUP BY currency_code';

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'Preview amount SQL = '||v_sql);
  END IF;

  -- Initialize amount
  x_preview_amount_total := 0;

  OPEN amount_cv FOR v_sql;

  LOOP

    FETCH amount_cv INTO v_amount, v_amount_currency;
    EXIT WHEN amount_cv%NOTFOUND;

    -- If the amount is NULL for some reason, take that to mean zero.
    IF v_amount IS NULL THEN
      v_amount := 0;
    END IF;

    BEGIN
      GL_CURRENCY_API.Convert_Closest_Amount(
	x_from_currency	     => v_amount_currency,
	x_to_currency        => x_functional_currency,
	x_conversion_date    => v_cal_per_end_date,
	x_conversion_type    => 'CORPORATE',
	x_user_rate          => null,
	x_amount             => v_amount,
	x_max_roll_days	     => 730, -- based on hardcoded value in CCE
	x_converted_amount   => v_conv_amount,
	x_denominator        => v_denom,
	x_numerator  	     => v_numer,
	x_rate		     => v_rate);
    EXCEPTION
      -- If there are any issues getting the rate,
      -- do no conversion and push a warning message in the message stack.
      WHEN others THEN
        FEM_ENGINES_PKG.PUT_MESSAGE(
          p_app_name     => 'FEM',
          p_msg_name     => 'NO_XLATE_RATE_FOUND',
          p_token1       => 'FROM_CURRENCY',
          p_value1       => v_amount_currency,
          p_token2       => 'TO_CURRENCY',
          p_value2       => x_functional_currency);

        v_conv_amount := v_amount;
    END;

    x_preview_amount_total := x_preview_amount_total + v_conv_amount;

  END LOOP;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
END GetPreviewAmount;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- PROCEDURE
--   GetPreviewRowCount
--
-- DESCRIPTION
--   Gets the row count for a Preview Row Group.  Instead of passing in
--   the row group, pass in the temporary table associated with the
--   row group.  This way, this API just needs to perform a SELECT count(*)
--   against it to obtain the row count.
--   No additional WHERE clause is needed because whatever is in the
--   temporary table is what is part of the Preview execution.
--
--   Caveat: For output data (debit/credit), if the table is an
--   account or transaction table, this API needs to first clear out
--   all rows that the CCE did not update as part of its processing.
--   The reason this is needed is because initially, when the output
--   temporary tables were created (by the Pre_Process procedure),
--   the initial data populated was most likely more than what CCE
--   was going to write out to (actually, update).  It was done to
--   simplify the logic in the Pre_Process procedure.  Without that
--   simplification, the Pre_Process procedure would need to basically
--   implement the logic in CCE to determine exactly which rows CCE
--   was going to update --- way too big a task.
--
-------------------------------------------------------------------------------
PROCEDURE GetPreviewRowCount(
  p_temp_table_name         IN VARCHAR2,
  x_preview_row_count       OUT NOCOPY NUMBER
)
-------------------------------------------------------------------------------
IS
--
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_mapping_preview_util_pkg.GetPreviewRowCount';
  v_sql               VARCHAR2(4000);
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Get row count
  v_sql := 'SELECT count(*) FROM '||p_temp_table_name;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'Preview Row Count SQL = '||v_sql);
  END IF;

  EXECUTE IMMEDIATE v_sql INTO x_preview_row_count;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
END GetPreviewRowCount;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- PROCEDURE
--   CleanOutputTable
--
-- DESCRIPTION
--   If the output table is an account or transaction table, this procedure
--   needs to first clear out all rows that the CCE did not update as
--   part of its processing.
--
--   The reason this is needed is initially, when the output
--   temporary tables were created (by the Pre_Process procedure),
--   the initial data populated was most likely more than what CCE
--   was going to write out to (actually, update).  It was done to
--   simplify the logic in the Pre_Process procedure.  Without that
--   simplification, the Pre_Process procedure would need to basically
--   implement the logic in CCE to determine exactly which rows CCE
--   was going to update --- way too big a task.
--
-------------------------------------------------------------------------------
PROCEDURE CleanOutputTable(
  p_temp_table_name         IN VARCHAR2,
  p_fact_table_name         IN VARCHAR2,
  p_map_table_type          IN VARCHAR2,
  p_preview_row_group       IN VARCHAR2,
  p_preview_obj_id          IN NUMBER,
  p_request_id              IN NUMBER
)
-------------------------------------------------------------------------------
IS
--
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_mapping_preview_util_pkg.CleanOutputTable';
  v_sql               VARCHAR2(4000);
  v_map_table_type    VARCHAR2(30);
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- If this is an output table and account/transaction table,
  -- delete data from the temporary table that the CCE did not process.
  IF ((p_preview_row_group IN (G_DEBIT, G_CREDIT)) AND
      (p_map_table_type = G_ACCT_TRANS_TYPE)) THEN

    v_sql := 'DELETE FROM '||p_temp_table_name
          ||' WHERE last_updated_by_request_id <> :1'
          ||' AND last_updated_by_object_id <> :2';

    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Delete unprocessed data SQL = '||v_sql);
    END IF;

    EXECUTE IMMEDIATE v_sql USING p_request_id, p_preview_obj_id;

  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
END CleanOutputTable;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- PROCEDURE
--   PopulateDimensionNames
--
-- DESCRIPTION
--   The temporary tables contain not just the dimension id/code columns
--   but also the dimension name columns for each of those dimension
--   id/code columns.  After CCE has gone through processing (and
--   we have cleaned out the output tables via CleanOutputTable),
--   the temporary tables are close to its final state.  All that needs
--   to be done is to populate those empty dimension name columns.
--
--   This procedure populates those columns by issue one large update
--   statement that looks like this:
--    UPDATE <temporary_table> t
--    SET
--     t.<dim1_name_column> =
--      Nvl((SELECT d1.<dim_name>
--           FROM <dim1_vl_view> d1
--           WHERE d1.<dim_member_column> = t.<dim1_member_column>
--           -- only needed for VSR dimensions
--           AND d1.value_set_id = <dim1_value_set_id>),
--          DECODE(t.<dim1_member_column>,NULL,NULL,
--            REPLACE('Dimension name missing: FEMDIMNAMETOKEN',
--                    'FEMDIMNAMETOKEN', t.<dim1_member_column>))
--          ),
--     t.<dim2_name_column> =
--      Nvl((SELECT d2.<dim_name>
--           FROM <dim2_vl_view> d2
--           WHERE d2.<dim_member_column> = t.<dim2_member_column>),
--          DECODE(t.<dim2_member_column>,NULL,NULL,
--            REPLACE('Dimension name missing: FEMDIMNAMETOKEN',
--                    'FEMDIMNAMETOKEN', t.<dim2_member_column>))
--          ),
--     <etc>
--
-------------------------------------------------------------------------------
PROCEDURE PopulateDimensionNames(
  p_preview_obj_def_id      IN NUMBER,
  p_preview_row_group       IN VARCHAR2,
  p_temp_table_name         IN VARCHAR2,
  p_fact_table_name         IN VARCHAR2,
  p_ledger_id               IN NUMBER
)
-------------------------------------------------------------------------------
IS
--
  C_MODULE                  CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_mapping_preview_util_pkg.PopulateDimensionNames';
  C_TOKEN                   CONSTANT VARCHAR2(20) := 'FEMDIMNAMETOKEN';
  v_return_status           VARCHAR2(1);
  v_msg_count               NUMBER;
  v_msg_data                VARCHAR2(4000);
  v_global_vs_combo_id      FEM_GLOBAL_VS_COMBO_DEFS.global_vs_combo_id%TYPE;
  v_warning                 FEM_DIM_TEMPLATE.template_dim_name%TYPE;
  v_sql                     VARCHAR2(32767);
--
  CURSOR c_dim_info (cv_preview_obj_def_id NUMBER,
                     cv_preview_row_group VARCHAR2,
                     cv_fact_table VARCHAR2,
                     cv_global_vs_combo_id NUMBER) IS
    SELECT pm.dim_member_column_name, pm.dim_name_column_name,
           xd.member_name_col, xd.member_vl_object_name, xd.member_col,
           gv.value_set_id
    FROM fem_alloc_preview_maps pm, fem_tab_columns_v tc,
         fem_xdim_dimensions xd, fem_global_vs_combo_defs gv
    WHERE pm.preview_obj_def_id = cv_preview_obj_def_id
      AND pm.preview_row_group = cv_preview_row_group
      AND pm.dim_member_column_name = tc.column_name
      AND tc.table_name = cv_fact_table
      AND xd.dimension_id  = tc.dimension_id
      AND xd.dimension_id  = gv.dimension_id (+)
      AND gv.global_vs_combo_id (+) = cv_global_vs_combo_id;
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- lookup the global value set combination id tied to the ledger
  v_global_vs_combo_id := FEM_DIMENSION_UTIL_PKG.global_vs_combo_id
                           (p_encoded        => FND_API.G_FALSE,
                            x_return_status  => v_return_status,
                            x_msg_count      => v_msg_count,
                            x_msg_data       => v_msg_data,
                            p_ledger_id      => p_ledger_id);

  IF v_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
         p_msg_text => 'INTERNAL ERROR: Call to'
                     ||' FEM_DIMENSION_UTIL_PKG.global_vs_combo_id'
                     ||' failed with return status: '||v_return_status);
    END IF;
  END IF;

  -- Get the text to store in the dimension name column if
  -- no dimension name was found.
  FND_MESSAGE.set_name('FEM','FEM_PREVIEW_DIM_NAME_MISSING');
  v_warning := FND_MESSAGE.get;

  -- Start building the repeating section of the UPDATE sql to
  -- popluate the dimension names.
  FOR dim IN c_dim_info(cv_preview_obj_def_id => p_preview_obj_def_id,
                        cv_preview_row_group  => p_preview_row_group,
                        cv_fact_table         => p_fact_table_name,
                        cv_global_vs_combo_id => v_global_vs_combo_id) LOOP

    -- Add the comma separate between columns being updated if this is
    -- not the first column being updated.
    IF v_sql IS NOT NULL THEN
      v_sql := v_sql||',';
    END IF;

    v_sql := v_sql||G_FACT_ALIAS||'.'||dim.dim_name_column_name||'='
           ||'NVL((SELECT '||G_DIM_ALIAS||'.'||dim.member_name_col
           ||' FROM '||dim.member_vl_object_name||' '||G_DIM_ALIAS
           ||' WHERE '||G_DIM_ALIAS||'.'||dim.member_col||'='
           ||G_FACT_ALIAS||'.'||dim.dim_member_column_name;

    -- Add the value set filter if it applies to the dimension
    IF dim.value_set_id IS NOT NULL THEN
      v_sql := v_sql||' AND '||G_DIM_ALIAS||'.value_set_id='||dim.value_set_id;
    END IF;

    v_sql := v_sql||'),'
           ||'DECODE('||G_FACT_ALIAS||'.'||dim.dim_member_column_name
           ||',NULL,NULL,'
           ||'REPLACE('''||v_warning||''','''||C_TOKEN||''','
           ||G_FACT_ALIAS||'.'||dim.dim_member_column_name||')))';

  END LOOP;

  -- Only run SQL if there are dimensions to be updated
  IF v_sql IS NOT NULL THEN

    -- Add the beginning part of the UPDATE sql to popluate the dimension names
    v_sql := 'UPDATE '||p_temp_table_name||' '||G_FACT_ALIAS||' SET '||v_sql;

    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => v_sql);
    END IF;

    EXECUTE IMMEDIATE v_sql;

  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
END PopulateDimensionNames;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- PROCEDURE
--   GetByDimParams
--
-- DESCRIPTION
--   Get the three By Dimension specific parameters that needs to
--   passed into FEM_ASSEMBLER_PREDICATE_API.Generate_Assembler_Predicate.
--
--   If mapping rule type is not By Dimension or preview group is not Source,
--   set all parameters to NULL.
--
--   If mapping rule type is By Dimension and preview group is Source,
--   then get the parameter values from these tables:
--   FEM_ALLOC_BR_DIMENSIONS, FEM_TAB_COLUMNS_B, and FEM_XDIM_DIMENSIONS
--
-------------------------------------------------------------------------------
PROCEDURE GetByDimParams(
  p_preview_obj_def_id      IN NUMBER,
  p_preview_row_group       IN VARCHAR2,
  p_map_obj_def_id          IN NUMBER,
  p_map_rule_type           IN VARCHAR2,
  p_fact_table_name         IN VARCHAR2,
  x_by_dimension_column     OUT NOCOPY VARCHAR2,
  x_by_dimension_id         OUT NOCOPY VARCHAR2,
  x_by_dimension_value      OUT NOCOPY VARCHAR2
)
-------------------------------------------------------------------------------
IS
--
  C_MODULE                  CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_mapping_preview_util_pkg.GetByDimParams';
  C_BYDIM_FUNCIONCD         CONSTANT VARCHAR2(10) := 'LEAFFUNC';
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- If mapping rule type is By Dimensions, get by dim param values.
  -- Else, set them to null.
  IF ((p_map_rule_type = G_BY_DIMENSION) AND
      (p_preview_row_group = G_SOURCE)) THEN
    SELECT abd.alloc_dim_col_name, xd.dimension_id,
           decode(xd.member_data_type_code,'NUMBER',abd.dimension_value,
                                           abd.dimension_value_char)
    INTO x_by_dimension_column, x_by_dimension_id, x_by_dimension_value
    FROM fem_alloc_br_dimensions abd, fem_tab_columns_b tc,
         fem_xdim_dimensions xd
    WHERE abd.object_definition_id = p_map_obj_def_id
    AND abd.function_cd = C_BYDIM_FUNCIONCD
    AND tc.table_name = p_fact_table_name
    AND abd.alloc_dim_col_name = tc.column_name
    AND tc.dimension_id = xd.dimension_id;
  ELSE
    x_by_dimension_column := NULL;
    x_by_dimension_id     := NULL;
    x_by_dimension_value  := NULL;
  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
END GetByDimParams;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------

END FEM_MAPPING_PREVIEW_UTIL_PKG;

/
