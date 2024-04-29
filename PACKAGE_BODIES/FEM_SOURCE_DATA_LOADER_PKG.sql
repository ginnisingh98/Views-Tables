--------------------------------------------------------
--  DDL for Package Body FEM_SOURCE_DATA_LOADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_SOURCE_DATA_LOADER_PKG" AS
/* $Header: fem_srcdata_ldr.plb 120.7 2008/01/23 19:08:28 gcheng ship $ */

--
-- Private Package Variables and exceptions
--

  G_LOG_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.level_statement;
  G_LOG_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.level_procedure;
  G_LOG_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.level_event;
  G_LOG_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.level_error;
  G_LOG_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.level_unexpected;

  G_API_VERSION             CONSTANT NUMBER      := 1.0;
  G_FALSE                   CONSTANT VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                    CONSTANT VARCHAR2(1) := FND_API.G_TRUE;
  G_RET_STS_SUCCESS         CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR           CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR     CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
  G_PKG_NAME                CONSTANT VARCHAR2(30) := 'FEM_SOURCE_DATA_LOADER_PKG';

  G_DEFAULT_DIM_GRP_SIZE    CONSTANT NUMBER := 5;
  G_MAX_DIMS                CONSTANT NUMBER := 150;
  G_INSERT_STMT_TYPE        CONSTANT VARCHAR2(10) := 'INSERT';
  G_INCOMPLETE_LOAD_STATUS  CONSTANT VARCHAR2(10) := 'INCOMPLETE';
  G_COMPLETE_L0AD_STATUS    CONSTANT VARCHAR2(10) := 'COMPLETE';
  G_DATETIME_FORMAT         CONSTANT VARCHAR2(24) := 'DD-MM-YYYY HH24:MI:SS';
  G_NULL_VALUE              CONSTANT VARCHAR2(8)  := '-1=2_3~4';

  g_log_current_level       NUMBER;

  TYPE xdim_info_rec_type IS RECORD
     (vs_id                  FEM_GLOBAL_VS_COMBO_DEFS.value_set_id%TYPE,
      member_b_table_name    FEM_XDIM_DIMENSIONS.member_b_table_name%TYPE,
      member_col             FEM_XDIM_DIMENSIONS.member_col%TYPE,
      member_disp_code_col   FEM_XDIM_DIMENSIONS.member_display_code_col%TYPE,
      target_col_data_type   FEM_XDIM_DIMENSIONS.member_data_type_code%TYPE,
      target_col             FEM_TAB_COLUMNS_V.column_name%TYPE,
      int_disp_code_col      FEM_TAB_COLUMNS_V.interface_column_name%TYPE);

  TYPE xdim_info_tbl_type IS TABLE OF xdim_info_rec_type INDEX BY BINARY_INTEGER;

  g_xdim_info_tbl            xdim_info_tbl_type;
  g_num_dims                 NUMBER;

  e_unexp_error              EXCEPTION;

  -- Start of Replacement Enhancement
  TYPE proc_keys_info_rec_type IS RECORD
   (
      target_col             FEM_TAB_COLUMNS_V.column_name%TYPE,
      interface_col          FEM_TAB_COLUMNS_V.interface_column_name%TYPE,
      target_nullable        ALL_TAB_COLUMNS.nullable%TYPE);

  TYPE g_proc_keys_info_type IS TABLE OF proc_keys_info_rec_type INDEX BY BINARY_INTEGER;
  g_proc_keys_tbl            g_proc_keys_info_type;
  g_proc_key_dim_num         NUMBER;

  v_param_list                wf_parameter_list_t;     -- Parameter list for Business Event
  -- End of Replacement Enhancement


--
-- Procedure
--     Main
-- Purpose
--       This is the program executable for the Source Data Loader
--      concurrent program.  It controls the flow of the loading process.
-- History
--     09-07-04    GCHENG        Created
--     02-26-06    HKANIVEN      Made modification to the code for raising
--                               Business event upon succesful loading of data.
-- Arguments
--    errbuf             : Message to return to conc mgr
--    retcode            : Return code to conc mgr
--    p_obj_def_id       : Object Definition ID that identifies the rule
--                           version being executed.
--    p_exec_mode        : Execution mode, S (Snapshot)/R (Replacement)
--                                         E (Error Reprocessing)
--    p_ledger_id        : Ledger to load data for
--    p_cal_period_id    : Period to load data for
--    p_dataset_code     : Dataset to load data for
--    p_source_system_code  : Source system to load data for
-- Notes
--
PROCEDURE Main (
  errbuf                OUT NOCOPY  VARCHAR2,
  retcode               OUT NOCOPY  VARCHAR2,
  p_obj_def_id          IN          VARCHAR2,
  p_exec_mode           IN          VARCHAR2,
  p_ledger_id           IN          VARCHAR2,
  p_cal_period_id       IN          VARCHAR2,
  p_dataset_code        IN          VARCHAR2,
  p_source_system_code  IN          VARCHAR2
) IS

  C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_source_data_loader_pkg.main';

  l_obj_def_id              NUMBER;
  l_ledger_id               NUMBER;
  l_cal_period_id           NUMBER;
  l_dataset_code            NUMBER;
  l_source_system_code      NUMBER;

  l_object_id               FEM_OBJECT_CATALOG_B.object_id%TYPE;
  l_table_name              FEM_TABLE_CLASS_ASSIGNMT_V.table_name%TYPE;
  l_ledger_dc               FEM_LEDGERS_B.ledger_display_code%TYPE;
  l_calp_dim_grp_dc         FEM_DIMENSION_GRPS_B.dimension_group_display_code%TYPE;
  l_cal_per_end_date        FEM_CAL_PERIODS_ATTR.date_assign_value%TYPE;
  l_cal_per_number          FEM_CAL_PERIODS_ATTR.number_assign_value%TYPE;
  l_dataset_dc              FEM_DATASETS_B.dataset_display_code%TYPE;
  l_source_system_dc        FEM_SOURCE_SYSTEMS_B.source_system_display_code%TYPE;

  l_condition               VARCHAR2(1000);
  l_dummy_boolean           BOOLEAN;
  l_process_registered      BOOLEAN := FALSE;
  l_prev_req_id             FND_CONCURRENT_REQUESTS.request_id%TYPE;
  l_exec_state              VARCHAR2(30);
  l_reuse_slices            VARCHAR2(1);
  l_prg_stat                VARCHAR2(30);
  l_exec_status             VARCHAR2(30);
  l_exception_code          VARCHAR2(30);
  l_eng_step                FEM_MP_OBJ_STEP_METHODS.step_name%type;
  l_interface_table_name    VARCHAR2(30);
  l_status                  FND_PRODUCT_INSTALLATIONS.status%TYPE;
  l_industry                FND_PRODUCT_INSTALLATIONS.industry%TYPE;
  l_schema_name             FND_ORACLE_USERID.oracle_username%TYPE;
  l_return_status           VARCHAR2(1);
  l_request_id              NUMBER;

  e_exp_error               EXCEPTION;
BEGIN
  -- set value of debug log current level
  g_log_current_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_request_id := FND_GLOBAL.Conc_Request_Id;

  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Init var
  l_return_status      := G_RET_STS_UNEXP_ERROR;
  l_obj_def_id         := to_number(p_obj_def_id);
  l_ledger_id          := to_number(p_ledger_id);
  l_cal_period_id      := to_number(p_cal_period_id);
  l_dataset_code       := to_number(p_dataset_code);
  l_source_system_code := to_number(p_source_system_code);

  Validate_Loader_Parameters(
    p_obj_def_id               => l_obj_def_id,
    p_exec_mode                => p_exec_mode,
    p_ledger_id                => l_ledger_id,
    p_cal_period_id            => l_cal_period_id,
    p_dataset_code             => l_dataset_code,
    p_source_system_code       => l_source_system_code,
    x_object_id                => l_object_id,
    x_table_name               => l_table_name,
    x_calp_dim_grp_dc          => l_calp_dim_grp_dc,
    x_cal_per_end_date         => l_cal_per_end_date,
    x_cal_per_number           => l_cal_per_number,
    x_dataset_dc               => l_dataset_dc,
    x_source_system_dc         => l_source_system_dc,
    x_ledger_dc                => l_ledger_dc,
    x_return_status            => l_return_status);

  -- Bug 5124844 hkaniven start
  -- Start of Replacement enhancement

    FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_SD_LDR_PARAMETERS',
         p_token1   => 'DIM_GRP',
         p_value1   => l_calp_dim_grp_dc,
         p_token2   => 'PER_NUM',
         p_value2   => l_cal_per_number,
         p_token3   => 'END_DATE',
         p_value3   => l_cal_per_end_date,
         p_token4   => 'LEDGER_DC',
         p_value4   => l_ledger_dc,
         p_token5   => 'DATASET_DC',
         p_value5   => l_dataset_dc,
         p_token6   => 'SOURCE_DC',
         p_value6   => l_source_system_dc,
         p_token7   => 'EXEC_MODE',
         p_value7   => p_exec_mode,
         p_token8   => 'TABLE_NAME',
         p_value8   => l_table_name);

    FEM_ENGINES_PKG.Tech_Message
        (p_severity => G_LOG_LEVEL_STATEMENT,
         p_module   => C_MODULE,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_SD_LDR_PARAMETERS',
         p_token1   => 'DIM_GRP',
         p_value1   => l_calp_dim_grp_dc,
         p_token2   => 'PER_NUM',
         p_value2   => l_cal_per_number,
         p_token3   => 'END_DATE',
         p_value3   => l_cal_per_end_date,
         p_token4   => 'LEDGER_DC',
         p_value4   => l_ledger_dc,
         p_token5   => 'DATASET_DC',
         p_value5   => l_dataset_dc,
         p_token6   => 'SOURCE_DC',
         p_value6   => l_source_system_dc,
         p_token7   => 'EXEC_MODE',
         p_value7   => p_exec_mode,
         p_token8   => 'TABLE_NAME',
         p_value8   => l_table_name);

  -- End of Replacement enhancement
  -- Bug 5124844 hkaniven end

  IF l_return_status = G_RET_STS_ERROR THEN
    RAISE e_exp_error;
  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
    RAISE e_unexp_error;
  END IF;

  Register_Process_Execution (
    p_object_id           => l_object_id,
    p_obj_def_id          => l_obj_def_id,
    p_table_name          => l_table_name,
    p_exec_mode           => p_exec_mode,
    p_ledger_id           => l_ledger_id,
    p_cal_period_id       => l_cal_period_id,
    p_dataset_code        => l_dataset_code,
    p_source_system_code  => l_source_system_code,
    p_request_id          => FND_GLOBAL.Conc_Request_Id,
    p_user_id             => FND_GLOBAL.User_Id,
    p_login_id            => FND_GLOBAL.Login_Id,
    p_program_id          => FND_GLOBAL.Conc_Program_Id,
    p_program_application_id => FND_GLOBAL.Prog_Appl_ID,
    x_prev_req_id         => l_prev_req_id,
    x_exec_state          => l_exec_state,
    x_return_status       => l_return_status);

  IF l_return_status = G_RET_STS_SUCCESS THEN
    l_process_registered := TRUE;
  ELSIF l_return_status = G_RET_STS_ERROR THEN
    RAISE e_exp_error;
  ELSE
    RAISE e_unexp_error;
  END IF;

  -- Find the schema name for FEM to allow truncation of the global
  -- temporary table FEM_SOURCE_DATA_INTERIM_GT.
  IF NOT FND_INSTALLATION.Get_App_Info
           (application_short_name => 'FEM',
            status                 => l_status,
            industry               => l_industry,
            oracle_schema          => l_schema_name) THEN
    IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_PROCEDURE,
        p_module   => C_MODULE,
        p_msg_text => 'Failed in obtaining the schema name for FEM');
    END IF;

    RAISE e_unexp_error;
  END IF;

  -- Get the interface table name
  SELECT interface_table_name
  INTO l_interface_table_name
  FROM fem_tables_b
  WHERE table_name = l_table_name;

  Set_MP_Condition (
    p_exec_mode                => p_exec_mode,
    p_calp_dim_grp_dc          => l_calp_dim_grp_dc,
    p_cal_per_end_date         => l_cal_per_end_date,
    p_cal_per_number           => l_cal_per_number,
    p_dataset_dc               => l_dataset_dc,
    p_source_system_dc         => l_source_system_dc,
    p_ledger_dc                => l_ledger_dc,
    x_condition                => l_condition,
    x_return_status            => l_return_status);

  IF l_return_status = G_RET_STS_ERROR THEN
    RAISE e_exp_error;
  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
    RAISE e_unexp_error;
  END IF;

  -- If the object execution state is RESTART, then the MP framework
  -- picks up where it left off in the previous attempt, with the
  -- next unprocessed data slice.
  --
  -- For object execution states of NORMAL or RERUN, the MP framework
  -- must re-compute the data slices.  Some RERUN cases may be able to
  -- reuse the previous run's slices, but it's not guaranteed that the
  -- data in the table hasn't changed between runs.
  IF l_exec_state = 'RESTART' THEN
    l_reuse_slices := 'Y';
  ELSE
    l_reuse_slices := 'N';
  END IF;

  FEM_MULTI_PROC_PKG.Master (
     x_prg_stat                 => l_prg_stat,
     x_exception_code           => l_exception_code,
     p_rule_id                  => l_object_id,
     p_eng_step                 => 'ALL',
     p_data_table               => l_interface_table_name,
     p_eng_sql                  => null,
     p_eng_prg                  => 'FEM_SOURCE_DATA_LOADER_PKG.Process_Data',
     p_condition                => l_condition,
     p_failed_req_id            => l_prev_req_id,
     p_reuse_slices             => l_reuse_slices,
     p_arg1                     => FND_GLOBAL.Conc_Request_Id,
     p_arg2                     => p_exec_mode,
     p_arg3                     => l_table_name,
     p_arg4                     => l_interface_table_name,
     p_arg5                     => l_object_id,
     p_arg6                     => l_ledger_id,
     p_arg7                     => l_cal_period_id,
     p_arg8                     => l_dataset_code,
     p_arg9                     => l_source_system_code,
     p_arg10                    => l_schema_name,
     p_arg11                    => l_condition);

  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_PROCEDURE,
        p_module   => C_MODULE,
        p_msg_text => 'MP Master return with status '||l_prg_stat);
  END IF;


  IF l_prg_stat = 'COMPLETE:NORMAL' THEN
    l_exec_status := 'SUCCESS';

  -- Start of Replacement enhancement

  -- Business Event should be raised after the successful completion
  -- Prepare the parameter list

    WF_EVENT.addparametertolist
    (p_name => 'REQUEST_ID',
     p_value => l_request_id,
     p_parameterlist => v_param_list);
    WF_EVENT.addparametertolist
    (p_name => 'OBJECT_ID',
     p_value => l_object_id,
     p_parameterlist => v_param_list);
    WF_EVENT.addparametertolist
    (p_name => 'EXEC_MODE',
     p_value => p_exec_mode,
     p_parameterlist => v_param_list);
    WF_EVENT.addparametertolist
    (p_name => 'TABLE_NAME',
     p_value => l_table_name,
     p_parameterlist => v_param_list);
    WF_EVENT.addparametertolist
    (p_name => 'LEDGER_ID',
     p_value => p_ledger_id,
     p_parameterlist => v_param_list);
    WF_EVENT.addparametertolist
    (p_name => 'CAL_PERIOD_ID',
     p_value => p_cal_period_id,
     p_parameterlist => v_param_list);
    WF_EVENT.addparametertolist
    (p_name => 'DATASET_CODE',
     p_value => p_dataset_code,
     p_parameterlist => v_param_list);
    WF_EVENT.addparametertolist
    (p_name => 'SOURCE_SYSTEM_CODE',
     p_value => p_source_system_code,
     p_parameterlist => v_param_list);
    WF_EVENT.addparametertolist
    (p_name => 'LOAD_STATUS',
     p_value => 'COMPLETE',
     p_parameterlist => v_param_list);

    WF_EVENT.RAISE
    (p_event_name => 'oracle.apps.fem.loader.fact.execute',
     p_event_key => NULL,
     p_parameters => v_param_list );

    v_param_list.DELETE;

  -- End of Replacement enhancement

  ELSE
    IF l_exception_code = 'FEM_MP_NO_DATA_SLICES_ERR' THEN
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_SD_LDR_NO_SLICES',
         p_token1   => 'DIM_GRP',
         p_value1   => l_calp_dim_grp_dc,
         p_token2   => 'PER_NUM',
         p_value2   => l_cal_per_number,
         p_token3   => 'END_DATE',
         p_value3   => FND_DATE.date_to_displayDT(l_cal_per_end_date),
         p_token4   => 'LEDGER_DC',
         p_value4   => l_ledger_dc,
         p_token5   => 'DATASET_DC',
         p_value5   => l_dataset_dc,
         p_token6   => 'SOURCE_DC',
         p_value6   => l_source_system_dc,
         p_token7   => 'EXEC_MODE',
         p_value7   => p_exec_mode);
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => G_LOG_LEVEL_STATEMENT,
         p_module   => C_MODULE,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_SD_LDR_NO_SLICES',
         p_token1   => 'DIM_GRP',
         p_value1   => l_calp_dim_grp_dc,
         p_token2   => 'PER_NUM',
         p_value2   => l_cal_per_number,
         p_token3   => 'END_DATE',
         p_value3   => FND_DATE.date_to_displayDT(l_cal_per_end_date),
         p_token4   => 'LEDGER_DC',
         p_value4   => l_ledger_dc,
         p_token5   => 'DATASET_DC',
         p_value5   => l_dataset_dc,
         p_token6   => 'SOURCE_DC',
         p_value6   => l_source_system_dc,
         p_token7   => 'EXEC_MODE',
         p_value7   => p_exec_mode);
    END IF;
    l_exec_status := 'ERROR_RERUN';
  END IF;

  Post_Process (
    p_object_id           => l_object_id,
    p_obj_def_id          => l_obj_def_id,
    p_table_name          => l_table_name,
    p_exec_mode           => p_exec_mode,
    p_ledger_id           => l_ledger_id,
    p_cal_period_id       => l_cal_period_id,
    p_dataset_code        => l_dataset_code,
    p_source_system_code  => l_source_system_code,
    p_exec_status         => l_exec_status,
    p_request_id          => FND_GLOBAL.Conc_Request_Id,
    p_user_id             => FND_GLOBAL.User_Id,
    p_login_id            => FND_GLOBAL.Login_Id,
    x_return_status       => l_return_status);

  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

EXCEPTION
  WHEN e_exp_error THEN
    -- Process locks clean up is only necessary if registration
    -- had already taken place.
    IF l_process_registered THEN
      Post_Process (
        p_object_id           => l_object_id,
        p_obj_def_id          => l_obj_def_id,
        p_table_name          => l_table_name,
        p_exec_mode           => p_exec_mode,
        p_ledger_id           => l_ledger_id,
        p_cal_period_id       => l_cal_period_id,
        p_dataset_code        => l_dataset_code,
        p_source_system_code  => l_source_system_code,
        p_exec_status         => 'ERROR_RERUN',
        p_request_id          => FND_GLOBAL.Conc_Request_Id,
        p_user_id             => FND_GLOBAL.User_Id,
        p_login_id            => FND_GLOBAL.Login_Id,
        x_return_status       => l_return_status);
    ELSE
      -- Post error rerun message to concurrent log
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_EXEC_RERUN');
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => G_LOG_LEVEL_STATEMENT,
         p_module   => C_MODULE,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_EXEC_RERUN');
    END IF;

    -- set request status to error
    l_dummy_boolean := FND_CONCURRENT.Set_Completion_Status
                      (status => 'ERROR', message => NULL);
  WHEN others THEN
    FEM_ENGINES_PKG.User_Message
      (p_app_name => 'FEM',
       p_msg_name => 'FEM_UNEXPECTED_ERROR',
       p_token1   => 'ERR_MSG',
       p_value1   => SQLERRM);
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => G_LOG_LEVEL_UNEXPECTED,
       p_module   => C_MODULE,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_UNEXPECTED_ERROR',
       p_token1   => 'ERR_MSG',
       p_value1   => SQLERRM);

    -- Process locks clean up is only necessary if registration
    -- had already taken place.
    IF l_process_registered THEN
      Post_Process (
        p_object_id           => l_object_id,
        p_obj_def_id          => l_obj_def_id,
        p_table_name          => l_table_name,
        p_exec_mode           => p_exec_mode,
        p_ledger_id           => l_ledger_id,
        p_cal_period_id       => l_cal_period_id,
        p_dataset_code        => l_dataset_code,
        p_source_system_code  => l_source_system_code,
        p_exec_status         => 'ERROR_RERUN',
        p_request_id          => FND_GLOBAL.Conc_Request_Id,
        p_user_id             => FND_GLOBAL.User_Id,
        p_login_id            => FND_GLOBAL.Login_Id,
        x_return_status       => l_return_status);
    ELSE
      -- Post error rerun message to concurrent log
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_EXEC_RERUN');
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => G_LOG_LEVEL_STATEMENT,
         p_module   => C_MODULE,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_EXEC_RERUN');
    END IF;

    -- set request status to error
    l_dummy_boolean := FND_CONCURRENT.Set_Completion_Status
                      (status => 'ERROR', message => NULL);
END Main;

--
-- Procedure
--     Validate_Loader_Parameters
-- Purpose
--      Validates the set of parameters passed into the Main module.
-- History
--     09-07-04    GCHENG        Created
-- Arguments
--    p_obj_def_id       : Object Definition ID that identifies the rule
--                           version being executed.
--    p_exec_mode        : Execution mode, S (Snapshot)/R (Replacement)/
--                       :                 E (Error Reprocessing)
--    p_ledger_id        : Ledger to load data for
--    p_cal_period_id    : Period to load data for
--    p_dataset_code     : Dataset to load data for
--    p_source_system_code  : Source system to load data for
--    x_object_id        : Object ID that identifies the rule being executed.
--    x_table_name       : Source data target table name
--    x_calp_dim_grp_dc  : Cal period dimension group display code
--    x_cal_per_end_date : Cal period end period date
--    x_cal_per_number   : Cal period number
--    x_dataset_dc       : Dataset display code
--    x_source_system_dc : Source system display code
--    x_ledger_dc        : Ledger display code
--    x_return_status    : Return status
--                           (look at FND_API for the possible statuses)
--
-- Notes
--
PROCEDURE Validate_Loader_Parameters (
  p_obj_def_id          IN          NUMBER,
  p_exec_mode           IN          VARCHAR2,
  p_ledger_id           IN          NUMBER,
  p_cal_period_id       IN          NUMBER,
  p_dataset_code        IN          NUMBER,
  p_source_system_code  IN          NUMBER,
  x_object_id           OUT NOCOPY  NUMBER,
  x_table_name          OUT NOCOPY  VARCHAR2,
  x_calp_dim_grp_dc     OUT NOCOPY  VARCHAR2,
  x_cal_per_end_date    OUT NOCOPY  DATE,
  x_cal_per_number      OUT NOCOPY  NUMBER,
  x_dataset_dc          OUT NOCOPY  VARCHAR2,
  x_source_system_dc    OUT NOCOPY  VARCHAR2,
  x_ledger_dc           OUT NOCOPY  VARCHAR2,
  x_return_status       OUT NOCOPY  VARCHAR2
) IS
  C_OBJECT_TYPE          CONSTANT VARCHAR2(18) := 'SOURCE_DATA_LOADER';
  C_TABLE_CLASSIFICATION CONSTANT VARCHAR2(17) := 'SOURCE_DATA_TABLE';
  C_MODULE               CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_source_data_loader_pkg.validate_loader_parameters';

  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(4000);
  l_ledger_calendar_id  NUMBER;
  l_ledger_per_hier_obj_def_id NUMBER;
BEGIN

  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  Validate_Obj_Def(
    p_api_version     => G_API_VERSION,
    p_object_type     => C_OBJECT_TYPE,
    p_obj_def_id      => p_obj_def_id,
    x_object_id       => x_object_id,
    x_table_name      => x_table_name,
    x_msg_count       => l_msg_count,
    x_msg_data        => l_msg_data,
    x_return_status   => x_return_status);

  IF l_msg_count > 0 THEN
    Get_Put_Messages (
      p_msg_count => l_msg_count,
      p_msg_data => l_msg_data);
   END IF;

  IF x_return_status = G_RET_STS_SUCCESS THEN
    Validate_Table(
      p_api_version   => G_API_VERSION,
      p_object_type   => C_OBJECT_TYPE,
      p_table_name    => x_table_name,
      p_table_classification => C_TABLE_CLASSIFICATION,
      x_msg_count     => l_msg_count,
      x_msg_data      => l_msg_data,
      x_return_status => x_return_status);

    IF l_msg_count > 0 THEN
      Get_Put_Messages (
        p_msg_count => l_msg_count,
        p_msg_data  => l_msg_data);
    END IF;
  END IF;

  IF x_return_status = G_RET_STS_SUCCESS THEN
    Validate_Exec_Mode(
      p_api_version   => G_API_VERSION,
      p_object_type   => C_OBJECT_TYPE,
      p_exec_mode     => p_exec_mode,
      x_msg_count     => l_msg_count,
      x_msg_data      => l_msg_data,
      x_return_status => x_return_status);

    IF l_msg_count > 0 THEN
      Get_Put_Messages (
        p_msg_count => l_msg_count,
        p_msg_data  => l_msg_data);
    END IF;
  END IF;

  IF x_return_status = G_RET_STS_SUCCESS THEN
    Validate_Ledger(
      p_api_version   => G_API_VERSION,
      p_object_type   => C_OBJECT_TYPE,
      p_ledger_id     => p_ledger_id,
      x_ledger_dc     => x_ledger_dc,
      x_ledger_calendar_id => l_ledger_calendar_id,
      x_ledger_per_hier_obj_def_id => l_ledger_per_hier_obj_def_id,
      x_msg_count     => l_msg_count,
      x_msg_data      => l_msg_data,
      x_return_status => x_return_status);

    IF l_msg_count > 0 THEN
      Get_Put_Messages (
        p_msg_count => l_msg_count,
        p_msg_data => l_msg_data);
    END IF;
  END IF;

  IF x_return_status = G_RET_STS_SUCCESS THEN
    Validate_Cal_Period(
      p_api_version                 => G_API_VERSION,
      p_object_type                 => C_OBJECT_TYPE,
      p_cal_period_id               => p_cal_period_id,
      p_ledger_id                   => p_ledger_id,
      p_ledger_calendar_id          => l_ledger_calendar_id,
      p_ledger_per_hier_obj_def_id  => l_ledger_per_hier_obj_def_id,
      x_calp_dim_grp_dc             => x_calp_dim_grp_dc,
      x_cal_per_end_date            => x_cal_per_end_date,
      x_cal_per_number              => x_cal_per_number,
      x_msg_count                   => l_msg_count,
      x_msg_data                    => l_msg_data,
      x_return_status               => x_return_status);

    IF l_msg_count > 0 THEN
      Get_Put_Messages (
        p_msg_count => l_msg_count,
        p_msg_data => l_msg_data);
    END IF;
  END IF;

  IF x_return_status = G_RET_STS_SUCCESS THEN
    Validate_Dataset(
      p_api_version    => G_API_VERSION,
      p_object_type    => C_OBJECT_TYPE,
      p_dataset_code   => p_dataset_code,
      x_dataset_dc     => x_dataset_dc,
      x_msg_count      => l_msg_count,
      x_msg_data       => l_msg_data,
      x_return_status  => x_return_status);

    IF l_msg_count > 0 THEN
      Get_Put_Messages (
        p_msg_count => l_msg_count,
        p_msg_data => l_msg_data);
    END IF;
  END IF;

  IF x_return_status = G_RET_STS_SUCCESS THEN
    Validate_Source_System(
      p_api_version        => G_API_VERSION,
      p_object_type        => C_OBJECT_TYPE,
      p_source_system_code => p_source_system_code,
      x_source_system_dc   => x_source_system_dc,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      x_return_status      => x_return_status);

    IF l_msg_count > 0 THEN
      Get_Put_Messages (
        p_msg_count => l_msg_count,
        p_msg_data  => l_msg_data);
    END IF;
  END IF;

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Returning with status of '||x_return_status);
  END IF;
  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

EXCEPTION
  WHEN others THEN
    x_return_status := G_RET_STS_UNEXP_ERROR;

END Validate_Loader_Parameters;

--
-- Procedure
--     Register Process Execution
-- Purpose
--     This procedure performs the initial process execution registration
--     mandated by the FEM process lock architecture.  Details on the
--     the architecture can be found in the Process Lock APIs
--     detail design document.
--
-- History
--     09-07-04    GCHENG        Created
-- Arguments
--    p_object_id        : Object ID that identifies the rule being executed.
--    p_obj_def_id       : Object Definition ID that identifies the rule
--                           version being executed.
--    p_table_name       : Source Data Table Name
--    p_exec_mode        : Execution mode, S (Snapshot)/R (Replacement)
--                                         E (Error Reprocessing)
--    p_ledger_id        : Ledger to load data for
--    p_cal_period_id    : Period to load data for
--    p_dataset_code     : Dataset to load data for
--    p_source_system_code  : Source system to load data for
--    p_request_id       : Concurrent request ID
--    p_user_id          : User ID
--    p_login_id         : Login ID
--    p_program_id       : Concurrent program ID
--    p_program_application_id  :  Concurrent program application ID
--    x_prev_req_id      : Previously run (and now restarted) concurrent
--                                  request ID
--    x_exec_state       : Object execution status set by call to
--                           FEM_PL_PKG.Register_Object_Execution
--    x_return_status    : Return status
--                           (look at FND_API for the possible statuses)
-- Notes
--
PROCEDURE Register_Process_Execution (
  p_object_id           IN          NUMBER,
  p_obj_def_id          IN          NUMBER,
  p_table_name          IN          VARCHAR2,
  p_exec_mode           IN          VARCHAR2,
  p_ledger_id           IN          NUMBER,
  p_cal_period_id       IN          NUMBER,
  p_dataset_code        IN          NUMBER,
  p_source_system_code  IN          NUMBER,
  p_request_id          IN          NUMBER,
  p_user_id             IN          NUMBER,
  p_login_id            IN          NUMBER,
  p_program_id          IN          NUMBER,
  p_program_application_id IN       NUMBER,
  x_prev_req_id         OUT NOCOPY  NUMBER,
  x_exec_state          OUT NOCOPY  VARCHAR2,
  x_return_status       OUT NOCOPY  VARCHAR2
) IS
  C_MODULE             CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_source_data_loader_pkg.register_process_execution';
  l_obj_exec_failed     VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(4000);
  l_return_status       VARCHAR2(1);

  e_process_lock_error  EXCEPTION;
BEGIN

  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;
  -- Log parameters
  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Object ID is '||p_object_id);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Object Definition ID is '||p_obj_def_id);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Table Name is '||p_table_name);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Exec Mode is '||p_exec_mode);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Ledger ID is '||p_ledger_id);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Calendar Period ID is '||p_cal_period_id);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Datset Code is '||p_dataset_code);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Source System Code is '||p_source_system_code);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Concurrent Request ID is '||p_request_id);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: User ID is '||p_user_id);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Login ID is '||p_login_id);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Concurrent Program ID is '||p_program_id);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Concurrent Program Application ID is '||
         p_program_application_id);
  END IF;

  -- Init var
  l_obj_exec_failed := G_FALSE;

  FEM_PL_PKG.Register_Request
        (p_api_version            => G_API_VERSION,
         p_commit                 => G_TRUE,
         p_cal_period_id          => p_cal_period_id,
         p_ledger_id              => p_ledger_id,
         p_output_dataset_code    => p_dataset_code,
         p_source_system_code     => p_source_system_code,
         p_request_id             => p_request_id,
         p_user_id                => p_user_id,
         p_last_update_login      => p_login_id,
         p_program_id             => p_program_id,
         p_program_login_id       => p_login_id,
         p_program_application_id => p_program_application_id,
         p_exec_mode_code         => p_exec_mode,
         p_table_name             => p_table_name,
         x_msg_count              => l_msg_count,
         x_msg_data               => l_msg_data,
         x_return_status          => l_return_status);

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.Tech_Message
           (p_severity => G_LOG_LEVEL_STATEMENT,
            p_module   => C_MODULE,
            p_msg_text => 'Call to FEM_PL_PKG.Register_Request returned with status '
              ||l_return_status);
  END IF;

  IF l_msg_count > 0 THEN
    Get_Put_Messages (
      p_msg_count => l_msg_count,
      p_msg_data => l_msg_data);
   END IF;

  IF l_return_status <> G_RET_STS_SUCCESS THEN
    RAISE e_process_lock_error;
  END IF;

  FEM_PL_PKG.Register_Object_Execution
        (p_api_version               => G_API_VERSION,
         p_commit                    => G_TRUE,
         p_request_id                => p_request_id,
         p_object_id                 => p_object_id,
         p_exec_object_definition_id => p_obj_def_id,
         p_user_id                   => p_user_id,
         p_last_update_login         => p_login_id,
         p_exec_mode_code            => p_exec_mode,
         x_exec_state                => x_exec_state,
         x_prev_request_id           => x_prev_req_id,
         x_msg_count                 => l_msg_count,
         x_msg_data                  => l_msg_data,
         x_return_status             => l_return_status);

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.Tech_Message
           (p_severity => G_LOG_LEVEL_STATEMENT,
            p_module   => C_MODULE,
            p_msg_text => 'Call to FEM_PL_PKG.Register_Object_Execution returned with '
              ||' status as '||l_return_status
              ||', execution state as '||x_exec_state
              ||' and previous request ID as '||to_char(x_prev_req_id));
  END IF;

  IF l_msg_count > 0 THEN
    Get_Put_Messages (
      p_msg_count => l_msg_count,
      p_msg_data => l_msg_data);
   END IF;

  IF l_return_status <> G_RET_STS_SUCCESS THEN
    -- Regardless of the reason why object execution did not succeed
    -- we want to flag it to allow for cleanup in the exceptions block
    l_obj_exec_failed := G_TRUE;
    RAISE e_process_lock_error;
  END IF;

  FEM_PL_PKG.Register_Object_Def
        (p_api_version          => G_API_VERSION,
         p_commit               => G_TRUE,
         p_request_id           => p_request_id,
         p_object_id            => p_object_id,
         p_object_definition_id => p_obj_def_id,
         p_user_id              => p_user_id,
         p_last_update_login    => p_login_id,
         x_msg_count            => l_msg_count,
         x_msg_data             => l_msg_data,
         x_return_status        => l_return_status);

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.Tech_Message
           (p_severity => G_LOG_LEVEL_STATEMENT,
            p_module   => C_MODULE,
            p_msg_text => 'Call to FEM_PL_PKG.Register_Object_Def returned with status '
              ||l_return_status);
  END IF;

  IF l_msg_count > 0 THEN
    Get_Put_Messages (
      p_msg_count => l_msg_count,
      p_msg_data => l_msg_data);
   END IF;

  IF l_return_status <> G_RET_STS_SUCCESS THEN
    RAISE e_process_lock_error;
  END IF;

  FEM_PL_PKG.Register_Table
        (p_api_version        => G_API_VERSION,
         p_commit             => G_TRUE,
         p_request_id         => p_request_id,
         p_object_id          => p_object_id,
         p_table_name         => p_table_name,
         p_statement_type     => G_INSERT_STMT_TYPE,
         p_num_of_output_rows => 0,
         p_user_id            => p_user_id,
         p_last_update_login  => p_login_id,
         x_msg_count          => l_msg_count,
         x_msg_data           => l_msg_data,
         x_return_status      => l_return_status);

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.Tech_Message
           (p_severity => G_LOG_LEVEL_STATEMENT,
            p_module   => C_MODULE,
            p_msg_text => 'Call to FEM_PL_PKG.Register_Table returned with status '
              ||l_return_status);
  END IF;

  IF l_msg_count > 0 THEN
    Get_Put_Messages (
      p_msg_count => l_msg_count,
      p_msg_data => l_msg_data);
   END IF;

  IF l_return_status <> G_RET_STS_SUCCESS THEN
    RAISE e_process_lock_error;
  END IF;

  -- Register Data Location
  BEGIN
    FEM_DIMENSION_UTIL_PKG.register_data_location
     (p_request_id   => p_request_id,
      p_object_id    => p_object_id,
      p_table_name   => p_table_name,
      p_ledger_id    => p_ledger_id,
      p_cal_per_id   => p_cal_period_id,
      p_dataset_cd   => p_dataset_code,
      p_source_cd    => p_source_system_code,
      p_load_status  => G_INCOMPLETE_LOAD_STATUS);
   EXCEPTION
     WHEN others THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

      FEM_ENGINES_PKG.Tech_Message
           (p_severity => G_LOG_LEVEL_STATEMENT,
            p_module   => C_MODULE,
            p_msg_text => 'Call to FEM_DIMENSION_UTIL_PKG.register_data_location '
              ||'failed unexpectedly.');
       RAISE;
  END;

  -- This commit is for the call to Register Data Locations.
  -- All other API's commit work as it completes successfully.
  COMMIT;

  x_return_status := G_RET_STS_SUCCESS;

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Procedure returning with status of '||x_return_status);
  END IF;
  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
EXCEPTION
  WHEN e_process_lock_error THEN
    x_return_status := G_RET_STS_ERROR;
    -- No need to post error messages as it was taken care of by the calls
    -- to get_push_messages after every API call.

    IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
      FEM_ENGINES_PKG.Tech_Message
           (p_severity => G_LOG_LEVEL_STATEMENT,
            p_module   => C_MODULE,
            p_msg_text => 'Exception e_process_lock_error raised.');
    END IF;

    IF l_obj_exec_failed = G_TRUE THEN
      -- Unregister the concurrent request to clean up data
      FEM_PL_PKG.Unregister_Request
              (p_api_version   => G_API_VERSION,
               p_commit        => G_FALSE,
               p_request_id    => p_request_id,
               x_msg_count     => l_msg_count,
               x_msg_data      => l_msg_data,
               x_return_status => l_return_status);

      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'Call to FEM_PL_PKG.Unregister_Request returned with status '
              ||l_return_status);
    END IF;

  WHEN others THEN
    -- Unexpected exceptions
    x_return_status := G_RET_STS_UNEXP_ERROR;

END Register_Process_Execution;

--
-- Procedure
--     Populate_xDim_Info_Tbl
-- Purpose
--       Populates the global table g_xdim_info_tbl.
--      g_xdim_info_tbl stores the xdim properties for those dimensions
--      that belong to the table as specified by the parameter.
-- History
--     09-07-04    GCHENG        Created
-- Arguments
--    p_table_name       : Table for which xdim info will be looked up
--    p_ledger_id        : Ledger ID need to find the Global VS Combo
--    x_return_status    : Return status
--                           (look at FND_API for the possible statuses)
-- Notes
--
PROCEDURE Populate_xDim_Info_Tbl(
  p_table_name               IN          VARCHAR2,
  p_ledger_id                IN          NUMBER,
  x_return_status            OUT NOCOPY  VARCHAR2
) IS
  C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_source_data_loader_pkg.populate_xdim_info_tbl';

  l_global_vs_combo_id       NUMBER;
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(4000);
BEGIN
  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Init to zero
  g_num_dims := 0;

  -- In case this procedure is called twice in the same session
  -- make sure to remove the previous dimension elements.
  IF g_xdim_info_tbl.COUNT > 0 THEN
    IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
      FEM_ENGINES_PKG.Tech_Message
           (p_severity => G_LOG_LEVEL_STATEMENT,
            p_module   => C_MODULE,
            p_msg_text => 'g_xdim_info_tbl is not empty.  Deleting all elements'
                   ||' to ensure a fresh start when loading new dimension info.');
    END IF;

    g_xdim_info_tbl.DELETE;
  END IF;

  --
  -- lookup the global value set combination id tied to the ledger
  --
  l_global_vs_combo_id := FEM_DIMENSION_UTIL_PKG.GLOBAL_VS_COMBO_ID
            (p_encoded        => G_FALSE,
             x_return_status  => x_return_status,
             x_msg_count      => l_msg_count,
             x_msg_data       => l_msg_data,
             p_ledger_id      => p_ledger_id);

  IF l_msg_count > 0 THEN
    Get_Put_Messages (
      p_msg_count => l_msg_count,
      p_msg_data  => l_msg_data);
   END IF;

  IF x_return_status = G_RET_STS_SUCCESS THEN
    IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
      FEM_ENGINES_PKG.Tech_Message
           (p_severity => G_LOG_LEVEL_STATEMENT,
            p_module   => C_MODULE,
            p_msg_text => 'Global Value Set Combination ID is '
              ||to_char(l_global_vs_combo_id));
    END IF;
  ELSE
    FEM_ENGINES_PKG.Tech_Message
           (p_severity => G_LOG_LEVEL_STATEMENT,
            p_module   => C_MODULE,
            p_msg_text => 'Could not find the Global Value Set Combination ID '
              ||'associated with the ledger');

    RAISE e_unexp_error;
  END IF;

  --
  -- populate the dimension properties record  table
  --
  BEGIN
    SELECT gv.value_set_id,
         xd.member_b_table_name,
         xd.member_col,
         xd.member_display_code_col,
         xd.member_data_type_code,
         tc.column_name,
         tc.interface_column_name
    BULK COLLECT INTO g_xdim_info_tbl
    FROM fem_tab_columns_v tc,
       fem_xdim_dimensions xd,
       fem_global_vs_combo_defs gv
    WHERE tc.table_name = p_table_name
    AND tc.fem_data_type_code = 'DIMENSION'
    AND tc.column_name NOT IN ('CREATED_BY_OBJECT_ID','LAST_UPDATED_BY_OBJECT_ID','LEDGER_ID','CAL_PERIOD_ID','DATASET_CODE','SOURCE_SYSTEM_CODE')
    AND xd.dimension_id  = tc.dimension_id
    AND xd.dimension_id  = gv.dimension_id (+)
    AND gv.global_vs_combo_id (+) = l_global_vs_combo_id;
  EXCEPTION
    WHEN no_data_found THEN
      g_num_dims := 0;
  END;

  g_num_dims := SQL%ROWCOUNT;

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.Tech_Message
           (p_severity => G_LOG_LEVEL_STATEMENT,
            p_module   => C_MODULE,
            p_msg_text => 'Number of dimenions is '
              ||to_char(g_num_dims));
  END IF;

  IF g_num_dims > G_MAX_DIMS THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Number of dimensions for this table ('||to_number(g_num_dims)
                  ||') exceeds the maximum number of supported dimensions ('
                  ||to_number(G_MAX_DIMS)||').');
    RAISE e_unexp_error;
  END IF;

  x_return_status := G_RET_STS_SUCCESS;

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Procedure returning with status of '||x_return_status);
  END IF;
  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

EXCEPTION
  WHEN others THEN
    x_return_status := G_RET_STS_UNEXP_ERROR;

END Populate_xDim_Info_Tbl;


--
-- Procedure
--      Set_MP_Condition
-- Purpose
--       Sets the condition SQL to be passed into MP Master
-- History
--     09-14-04    GCHENG        Created
--     02-27-06    HKANIVEN      Made modifications to the condition
--                               support Replacement mode
-- Arguments
--    p_exec_mode        : Execution mode, S (Snapshot)/R (Replacement)
--                                         E (Error Reprocessing)
--    p_calp_dim_grp_dc  : Cal period dimension group display code
--    p_cal_per_end_date : Cal period end period date
--    p_cal_per_number   : Cal period number
--    p_dataset_dc       : Dataset display code
--    p_source_system_dc : Source system display code
--    p_ledger_dc        : Ledger display code
--    x_condition        : Multiprocessing p_condition
--                              dimension validation
--    x_return_status    : Return status
--                           (look at FND_API for the possible statuses)
-- Notes
--
PROCEDURE Set_MP_Condition (
  p_exec_mode                IN          VARCHAR2,
  p_calp_dim_grp_dc          IN          VARCHAR2,
  p_cal_per_end_date         IN          DATE,
  p_cal_per_number           IN          NUMBER,
  p_dataset_dc               IN          VARCHAR2,
  p_source_system_dc         IN          VARCHAR2,
  p_ledger_dc                IN          VARCHAR2,
  x_condition                OUT NOCOPY  VARCHAR2,
  x_return_status            OUT NOCOPY  VARCHAR2
) IS
  C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_source_data_loader_pkg.set_mp_condition';

BEGIN
  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  --
  -- set the condition to be passed to the multiprocessing master
  --
  x_condition :=
          ' calp_dim_grp_display_code = '''||p_calp_dim_grp_dc||''''
    ||' AND cal_period_end_date = TO_DATE('''
              ||TO_CHAR(p_cal_per_end_date, G_DATETIME_FORMAT)
              ||''','''||G_DATETIME_FORMAT||''')'
    ||' AND cal_period_number = '||TO_CHAR(p_cal_per_number)
    ||' AND source_system_display_code = '''||p_source_system_dc||''''
    ||' AND dataset_display_code = '''||p_dataset_dc||''''
    ||' AND ledger_display_code = '''||p_ledger_dc||'''';


  -- Start of Replacement mode enhancement
  -- In Replacement mode all the rows irrespective of their 'STATUS'
  -- column value should be processed
  IF (p_exec_mode = 'S') THEN
    x_condition := x_condition||' AND status = ''LOAD''';
  ELSIF p_exec_mode = 'E' THEN
    x_condition := x_condition||' AND status <> ''LOAD''';
  ELSE
    NULL;
  END IF;
  -- End of Replacement mode enhancement

  x_return_status := G_RET_STS_SUCCESS;

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Procedure returning with status of '||x_return_status);
  END IF;
  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

EXCEPTION
  WHEN others THEN
    x_return_status := G_RET_STS_UNEXP_ERROR;

END Set_MP_Condition;


--
-- Procedure
--      Prepare_Dynamic_Sql
-- Purpose
--       Sets the following dynamic sql:
--        * SQL to copy slice from interface table to interim table
--        * SQL to update the interim error_code for dimension validation
--            errors
--        * SQL to insert/replace validated rows into the target table
-- History
--     09-07-04    GCHENG        Created
--     02-26-06    HKANIVEN      Added Replacement mode support
--     04-18-06    HKANIVEN      Bug 5114554
--     06-08-07    RFLIPPO       bug#6034150
-- Arguments
--    p_object_id        : Object ID that identifies the rule being executed.
--    p_request_id       : Concurrent request ID of the Main process
--    p_ledger_id        : Ledger to load data for
--    p_cal_period_id    : Period to load data for
--    p_dataset_code     : Dataset to load data for
--    p_source_system_code  : Source system to load data for
--    p_interface_table_name : Source data interface table name
--    p_table_name       : Source data target table name
--    p_condition        : Where clause for the interface table
--    x_insert_interim_sql : SQL to copy slice from interface table
--                                   to interim table
--    x_update_interim_error_sql : SQL to update the interim error_code for
--                                 dimension validation errors
--    x_insert_target_sql : SQL to insert/replace validated rows into the
--                          target table
--    x_return_status    : Return status
--                           (look at FND_API for the possible statuses)
-- Notes
--
PROCEDURE Prepare_Dynamic_Sql (
  p_object_id                IN          NUMBER,
  p_exec_mode                IN          VARCHAR2,
  p_request_id               IN          NUMBER,
  p_ledger_id                IN          NUMBER,
  p_cal_period_id            IN          NUMBER,
  p_dataset_code             IN          NUMBER,
  p_source_system_code       IN          NUMBER,
  p_interface_table_name     IN          VARCHAR2,
  p_target_table_name        IN          VARCHAR2,
  p_condition                IN          VARCHAR2,
  x_insert_interim_sql       OUT NOCOPY  VARCHAR2,
  x_update_interim_error_sql OUT NOCOPY  VARCHAR2,
  x_insert_target_sql        OUT NOCOPY  VARCHAR2,
  x_return_status            OUT NOCOPY  VARCHAR2
) IS
  C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_source_data_loader_pkg.prepare_dynamic_sql';

  TYPE nondim_col_tbl_type IS TABLE OF FEM_TAB_COLUMNS_V.column_name%TYPE;
  l_nondim_target_col_tbl    nondim_col_tbl_type;
  l_nondim_int_col_tbl       nondim_col_tbl_type;
  l_num_nondims              NUMBER;

  l_dummy1_sql               VARCHAR2(18000);
  l_dummy2_sql               VARCHAR2(18000);

  -- Start of Replacement enhancement

  l_merge_stmt_part1         VARCHAR2(18000);
  l_merge_stmt_part2         VARCHAR2(18000);
  l_merge_stmt_part3         VARCHAR2(18000);
  l_merge_stmt_part4         VARCHAR2(18000);
  l_merge_stmt_part5         VARCHAR2(18000);
  l_merge_stmt               VARCHAR2(32000);
  l_dummy3_sql               VARCHAR2(18000);
  l_dummy4_sql               VARCHAR2(18000);
  l_dummy5_sql               VARCHAR2(18000);
  l_dummy6_sql               VARCHAR2(3500);
  l_found                    NUMBER;
  str_length                 NUMBER;
  v_count                    NUMBER;

  -- End of Replacement enhancement

  l_return_status            VARCHAR2(1);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(4000);
  l_db_tab_name              ALL_TABLES.table_name%TYPE;
  l_tab_owner                ALL_TABLES.owner%TYPE;

BEGIN
  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Populate g_xdim_info_tbl and g_num_dims
  Populate_xDim_Info_Tbl(
    p_table_name        => p_target_table_name,
    p_ledger_id         => p_ledger_id,
    x_return_status     => x_return_status);

  IF x_return_status <> G_RET_STS_SUCCESS THEN
    RAISE e_unexp_error;
  END IF;

  --
  -- Build SQL to insert to interim table
  -- and SQL to update error_code in the interim table
  --
  --

  -- for x_insert_interim_sql
  l_dummy1_sql :=
    'INSERT INTO fem_source_data_interim_gt (INTERFACE_ROWID';
  l_dummy2_sql :=
    'SELECT rowid';

  -- for x_update_interim_error_sql
  x_update_interim_error_sql :=
      'UPDATE fem_source_data_interim_gt g SET g.error_code = '
    ||'''FEM_SD_LDR_INV_DIM_MEMBER'' WHERE EXISTS'
    ||'(SELECT null FROM '||p_interface_table_name||' i'
    ||' WHERE i.rowid = g.interface_rowid AND ( ';

  FOR i IN 1..g_num_dims LOOP
    -- for x_insert_interim_sql
    l_dummy1_sql := l_dummy1_sql||',DIM'||to_char(i);
    l_dummy2_sql := l_dummy2_sql||','''||G_NULL_VALUE||'''';
    -- for x_update_interim_error_sql
    IF i>1 THEN
      x_update_interim_error_sql := x_update_interim_error_sql||' OR ';
    END IF;
    x_update_interim_error_sql := x_update_interim_error_sql
        ||'(i.'||g_xdim_info_tbl(i).int_disp_code_col
        ||' IS NOT NULL AND g.DIM'||to_char(i)||' IS NULL)';
  END LOOP;
  -- for x_insert_interim_sql
  l_dummy1_sql := l_dummy1_sql||') ';
  l_dummy2_sql := l_dummy2_sql||' FROM '||p_interface_table_name
                  ||' WHERE '||p_condition;
  x_insert_interim_sql := l_dummy1_sql || l_dummy2_sql;

  -- for x_update_interim_error_sql
  x_update_interim_error_sql := x_update_interim_error_sql||' ) )';


  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.Tech_Message
           (p_severity => G_LOG_LEVEL_STATEMENT,
            p_module   => C_MODULE,
            p_msg_text => 'SQL to copy data from interface to interim is:');
    FEM_ENGINES_PKG.Tech_Message
           (p_severity => G_LOG_LEVEL_STATEMENT,
            p_module   => C_MODULE,
            p_msg_text => l_dummy1_sql);
    FEM_ENGINES_PKG.Tech_Message
           (p_severity => G_LOG_LEVEL_STATEMENT,
            p_module   => C_MODULE,
            p_msg_text => l_dummy2_sql);
    FEM_ENGINES_PKG.Tech_Message
           (p_severity => G_LOG_LEVEL_STATEMENT,
            p_module   => C_MODULE,
            p_msg_text => 'SQL to set validation errors in the Interim Table is '
                       ||x_update_interim_error_sql);
  END IF;


  --
  -- Lookup the non-dimension column names
  --
  -- 06/08/2007 RFLIPPO bug#6034150 exclude cols that don't have
  --                    an interface col mapping.  Rely on table class
  --                    validation to ensure that all not null cols
  --                    have an interface col mapping
  BEGIN
    SELECT tc.column_name, tc.interface_column_name
    BULK COLLECT INTO l_nondim_target_col_tbl, l_nondim_int_col_tbl
    FROM fem_tab_columns_v tc
    WHERE tc.table_name = p_target_table_name
      AND tc.fem_data_type_code <> 'DIMENSION'
      AND tc.interface_column_name is not null
      AND tc.column_name NOT IN ('CREATED_BY_REQUEST_ID','LAST_UPDATED_BY_REQUEST_ID');
  EXCEPTION
    WHEN no_data_found THEN
      l_num_nondims := 0;
  END;

l_num_nondims := SQL%ROWCOUNT;



  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.Tech_Message
           (p_severity => G_LOG_LEVEL_STATEMENT,
            p_module   => C_MODULE,
            p_msg_text => 'Number of non-dimenion columns is '
              ||to_char(l_num_nondims));
  END IF;

  --
  -- Build SQL to insert to target table
  --
  x_insert_target_sql := null;

  IF l_num_nondims = 0 AND g_num_dims = 0 THEN
    FEM_ENGINES_PKG.Tech_Message
           (p_severity => G_LOG_LEVEL_UNEXPECTED,
            p_module   => C_MODULE,
            p_msg_text => 'This table has no columns registered in FEM_TAB_COLUMNS_V !');
    RAISE e_unexp_error;
  END IF;

  l_dummy1_sql :=
      'INSERT INTO '||p_target_table_name
    ||' (CREATED_BY_OBJECT_ID,LAST_UPDATED_BY_OBJECT_ID,CREATED_BY_REQUEST_ID,LAST_UPDATED_BY_REQUEST_ID'
    ||',LEDGER_ID,CAL_PERIOD_ID,DATASET_CODE,SOURCE_SYSTEM_CODE';
  l_dummy2_sql :=
      'SELECT '||to_char(p_object_id)||','||to_char(p_object_id)||','
    ||to_char(p_request_id)||','||to_char(p_request_id)||','
    ||to_char(p_ledger_id)||','||to_char(p_cal_period_id)||','
    ||to_char(p_dataset_code)||','||to_char(p_source_system_code);


  IF g_num_dims > 0 THEN
    FOR i IN 1..g_num_dims LOOP
      IF g_xdim_info_tbl(i).target_col NOT IN ('LEDGER_ID','CAL_PERIOD_ID',
                                        'DATASET_CODE','SOURCE_SYSTEM_CODE') THEN
        l_dummy1_sql := l_dummy1_sql||','||g_xdim_info_tbl(i).target_col;
        IF g_xdim_info_tbl(i).target_col_data_type = 'NUMBER' THEN
          l_dummy2_sql := l_dummy2_sql||',to_number(g.DIM'||to_char(i)||')';
        ELSIF g_xdim_info_tbl(i).target_col_data_type = 'DATE' THEN
          l_dummy2_sql := l_dummy2_sql||',TO_DATE(g.DIM'||to_char(i)
              ||','''||G_DATETIME_FORMAT||''')';
        ELSE
          l_dummy2_sql := l_dummy2_sql||',g.DIM'||to_char(i);
        END IF;
      END IF;
     END LOOP;
  END IF;

  IF l_num_nondims > 0 THEN
    FOR i IN 1..l_num_nondims LOOP
      l_dummy1_sql := l_dummy1_sql||','||l_nondim_target_col_tbl(i);
      l_dummy2_sql := l_dummy2_sql||',i.'||l_nondim_int_col_tbl(i);
     END LOOP;
  END IF;

  l_dummy1_sql := l_dummy1_sql||') ';
  l_dummy2_sql := l_dummy2_sql||' FROM fem_source_data_interim_gt g, '
                  ||p_interface_table_name||' i'
                  ||' WHERE i.rowid = g.interface_rowid'
                  ||' AND g.error_code IS NULL';

  x_insert_target_sql := l_dummy1_sql || l_dummy2_sql;

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.Tech_Message
           (p_severity => G_LOG_LEVEL_STATEMENT,
            p_module   => C_MODULE,
            p_msg_text => 'SQL to insert to target is:');
    FEM_ENGINES_PKG.Tech_Message
           (p_severity => G_LOG_LEVEL_STATEMENT,
            p_module   => C_MODULE,
            p_msg_text => l_dummy1_sql);
    FEM_ENGINES_PKG.Tech_Message
           (p_severity => G_LOG_LEVEL_STATEMENT,
            p_module   => C_MODULE,
            p_msg_text => l_dummy2_sql);
  END IF;


  -- Start of Replacement enhancement
  -- Prepare Dynamic 'MERGE' Statement.

  -- MERGE statement is divided into five parts
  -- Finally all of them will be combined together to form
  -- the complete MERGE statement

  -- MERGE statement parts are as follows
  --  l_merge_stmt_part1  - MERGE clause
  --  l_merge_stmt_part2  - SELECT clause
  --  l_merge_stmt_part3  - ON clause
  --  l_merge_stmt_part4  - WHEN MATCHED THEN clause
  --  l_merge_stmt_part5  - WHEN NOT MATCHED THEN clause


  IF p_exec_mode = 'R' OR p_exec_mode = 'E' THEN

   IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
     FEM_ENGINES_PKG.TECH_MESSAGE(
       p_severity => G_LOG_LEVEL_STATEMENT,
       p_module   => C_MODULE,
       p_msg_text => 'Start of MERGE statement creation');
   END IF;

   l_merge_stmt_part1 := 'MERGE INTO ' ||  p_target_table_name || ' D USING ('  ;

   l_merge_stmt_part2 := ' SELECT ' ;

   l_dummy2_sql := l_merge_stmt_part2 ;

   -- Get all the dimension values
   IF g_num_dims > 0 THEN
    FOR i IN 1..g_num_dims LOOP
        IF i = 1 THEN
  	       IF g_xdim_info_tbl(i).target_col_data_type = 'NUMBER' THEN
              l_dummy2_sql := l_dummy2_sql||' to_number(g.DIM'||to_char(i)||') DIM' || to_char(i);
           ELSIF g_xdim_info_tbl(i).target_col_data_type = 'DATE' THEN
              l_dummy2_sql := l_dummy2_sql||' TO_DATE(g.DIM'||to_char(i) ||','''||G_DATETIME_FORMAT||''') DIM'
                                || to_char(i);
           ELSE
              l_dummy2_sql := l_dummy2_sql||' g.DIM'||to_char(i) || ' DIM' || to_char(i);
           END IF;

        ELSE
           IF g_xdim_info_tbl(i).target_col_data_type = 'NUMBER' THEN
              l_dummy2_sql := l_dummy2_sql||', to_number(g.DIM'||to_char(i)||') DIM' || to_char(i);
           ELSIF g_xdim_info_tbl(i).target_col_data_type = 'DATE' THEN
              l_dummy2_sql := l_dummy2_sql||', TO_DATE(g.DIM'||to_char(i) ||','''||G_DATETIME_FORMAT||''') DIM'
                                 || to_char(i);
           ELSE
              l_dummy2_sql := l_dummy2_sql||', g.DIM'||to_char(i) || ' DIM' || to_char(i);
           END IF;
        END IF;
    END LOOP;
   END IF;

   --
   -- Get processing key information
   --

   -- Get interface table name and owner
   FEM_Database_Util_Pkg.Get_Table_Owner (
     x_return_status => l_return_status,
     x_msg_count => l_msg_count,
     x_msg_data => l_msg_data,
     p_syn_name => p_target_table_name,
     x_tab_name => l_db_tab_name,
     x_tab_owner => l_tab_owner);

   IF l_return_status <> G_RET_STS_SUCCESS THEN
     IF l_msg_count > 0 THEN
       Get_Put_Messages (
         p_msg_count => l_msg_count,
         p_msg_data => l_msg_data);
     END IF;

     IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FEM_ENGINES_PKG.TECH_MESSAGE(
         p_severity => FND_LOG.level_statement,
         p_module   => C_MODULE,
         p_msg_text => 'Call to FEM_Database_Util_Pkg.Get_Table_Owner failed');
     END IF;
     RAISE e_unexp_error;
   ELSE
     IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FEM_ENGINES_PKG.TECH_MESSAGE(
         p_severity => FND_LOG.level_statement,
         p_module   => C_MODULE,
         p_msg_text => 'l_db_tab_name = '||l_db_tab_name);
     END IF;
     IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FEM_ENGINES_PKG.TECH_MESSAGE(
         p_severity => FND_LOG.level_statement,
         p_module   => C_MODULE,
         p_msg_text => 'l_tab_owner = '||l_tab_owner);
     END IF;
   END IF;

   BEGIN
     SELECT ftc.column_name, ftc.interface_column_name, atc.nullable
     BULK COLLECT INTO g_proc_keys_tbl
     FROM fem_tab_columns_b ftc, all_tab_columns atc, fem_tab_column_prop tcp
     WHERE atc.table_name = l_db_tab_name
     AND atc.owner = l_tab_owner
     AND ftc.table_name = p_target_table_name
     AND atc.column_name = ftc.column_name
     AND ftc.table_name = tcp.table_name
     AND ftc.column_name = tcp.column_name
     AND tcp.column_property_code = 'PROCESSING_KEY';
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
          IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
            FEM_ENGINES_PKG.Tech_Message
                   (p_severity => G_LOG_LEVEL_STATEMENT,
                    p_module   => C_MODULE,
                    p_msg_text => 'Processing key columns not defined');
           END IF;

        WHEN OTHERS THEN
            RAISE e_unexp_error;
   END;

   g_proc_key_dim_num := g_proc_keys_tbl.count;

   -- Get all the non dimension values
   IF l_num_nondims > 0 THEN
     FOR i IN 1..l_num_nondims
     LOOP
       -- Bug 6040133 (FP:6019542): Since the processing key columns are not
       -- being added in the select clause in the next section, we should not
       -- exclude those non-dim PK columns from being added to the select
       -- clause here.  Commenting out this code...
       --l_found := 0;

       --FOR v IN 1..g_proc_key_dim_num
       --LOOP
       -- IF g_proc_keys_tbl(v).interface_col = l_nondim_int_col_tbl(i) THEN
       --    l_found := 1;
       --     EXIT;
       -- END IF;
       --END LOOP;

       --IF l_found <> 1 THEN
       --  l_dummy2_sql := l_dummy2_sql||',i.'||l_nondim_int_col_tbl(i);
       --  l_found := 0;
       --END IF;

       l_dummy2_sql := l_dummy2_sql||',i.'||l_nondim_int_col_tbl(i);

     END LOOP;
   END IF;

   -- Bug 6040133 (FP:6019542): Dimension columns part of the processing key
   -- are not needed in the SELECT clause because they are not being used
   -- in the MERGE stmt.  Commenting out this code...
   --
   -- Append the processing key columns to the SELECT clause
   --FOR v IN 1..g_proc_key_dim_num
   --LOOP
   --   IF g_proc_keys_tbl(v).interface_col IS NOT NULL THEN
   --    l_dummy2_sql := l_dummy2_sql||', i.'||g_proc_keys_tbl(v).interface_col;
   --   END IF;
   --END LOOP;

   l_dummy2_sql := l_dummy2_sql||' FROM fem_source_data_interim_gt g, '
                               || p_interface_table_name||' i '
                               ||' WHERE i.rowid = g.interface_rowid '
                               ||' AND g.error_code IS NULL ';

   l_merge_stmt_part2 := l_dummy2_sql || ' ) T ';

   l_merge_stmt_part3 := ' ON ( ';

   l_dummy3_sql := l_merge_stmt_part3;

   -- Bug 5114554 hkaniven start
   -- Append the processing keys to the ON clause
   -- Append the dimension columns first

   -- Bug 6040133 (FP:6019542): Should only add the 'IS NULL' check if the
   -- target column is nullable. Otherwise, we cannot take advantage of the
   -- unique index in the target table.
   FOR v IN 1..g_proc_key_dim_num
   LOOP

     FOR i IN 1..g_num_dims
     LOOP
       IF g_proc_keys_tbl(v).target_col = g_xdim_info_tbl(i).target_col THEN
         IF l_merge_stmt_part3 <> l_dummy3_sql THEN
           l_merge_stmt_part3 := l_merge_stmt_part3 || ' AND';
         END IF;

         IF g_proc_keys_tbl(v).target_nullable = 'Y' THEN
           l_merge_stmt_part3 := l_merge_stmt_part3
             || ' ((D.' || g_proc_keys_tbl(v).target_col || ' IS NULL'
             || ' AND T.DIM' || to_char(i) || ' IS NULL) OR ' || '(';
         END IF;

         l_merge_stmt_part3 := l_merge_stmt_part3
           || ' D.' || g_proc_keys_tbl(v).target_col
           || ' = ' || ' T.DIM' ||  to_char(i);

         IF g_proc_keys_tbl(v).target_nullable = 'Y' THEN
           l_merge_stmt_part3 := l_merge_stmt_part3 || '))';
         END IF;
       END IF;
     END LOOP;
   END LOOP;


  -- Append columns CAL_PERIOD_ID, LEDGER_ID,
  -- SOURCE_SYSTEM_CODE, DATASET_CODE to the ON Clause

  FOR v IN 1..g_proc_key_dim_num
  LOOP
    IF g_proc_keys_tbl(v).target_col = 'CAL_PERIOD_ID' THEN
        IF l_merge_stmt_part3 = l_dummy3_sql THEN
             l_merge_stmt_part3 := l_merge_stmt_part3 || ' D.' || g_proc_keys_tbl(v).target_col
                                                  || ' = ' ||  p_cal_period_id ;
        ELSE
             l_merge_stmt_part3 := l_merge_stmt_part3 || ' AND D.' || g_proc_keys_tbl(v).target_col
                                                  || ' = ' ||  p_cal_period_id ;
        END IF;
    ELSIF g_proc_keys_tbl(v).target_col = 'LEDGER_ID' THEN
        IF l_merge_stmt_part3 = l_dummy3_sql THEN
             l_merge_stmt_part3 := l_merge_stmt_part3 || ' D.' || g_proc_keys_tbl(v).target_col
                                                  || ' = ' ||  p_ledger_id ;
        ELSE
             l_merge_stmt_part3 := l_merge_stmt_part3 || ' AND D.' || g_proc_keys_tbl(v).target_col
                                                  || ' = ' ||  p_ledger_id ;
        END IF;
    ELSIF g_proc_keys_tbl(v).target_col = 'SOURCE_SYSTEM_CODE' THEN
        IF l_merge_stmt_part3 = l_dummy3_sql THEN
             l_merge_stmt_part3 := l_merge_stmt_part3 || ' D.' || g_proc_keys_tbl(v).target_col
                                                  || ' = ' ||  p_source_system_code ;
        ELSE
             l_merge_stmt_part3 := l_merge_stmt_part3 || ' AND D.' || g_proc_keys_tbl(v).target_col
                                                  || ' = ' ||  p_source_system_code ;
        END IF;
    ELSIF g_proc_keys_tbl(v).target_col = 'DATASET_CODE' THEN
        IF l_merge_stmt_part3 = l_dummy3_sql THEN
             l_merge_stmt_part3 := l_merge_stmt_part3 || ' D.' || g_proc_keys_tbl(v).target_col
                                                  || ' = ' ||  p_dataset_code ;
        ELSE
             l_merge_stmt_part3 := l_merge_stmt_part3 || ' AND D.' || g_proc_keys_tbl(v).target_col
                                                  || ' = ' ||  p_dataset_code ;
        END IF;
     END IF;
  END LOOP;


  -- Append non-dimension columns processing keys to the ON Clause
   FOR v IN 1..g_proc_key_dim_num
   LOOP
     FOR i IN 1..l_num_nondims
     LOOP
       IF g_proc_keys_tbl(v).target_col = l_nondim_target_col_tbl(i) THEN
         IF l_merge_stmt_part3 <> l_dummy3_sql THEN
           l_merge_stmt_part3 := l_merge_stmt_part3 || ' AND';
         END IF;

         IF g_proc_keys_tbl(v).target_nullable = 'Y' THEN
           l_merge_stmt_part3 := l_merge_stmt_part3
             || ' (( D.' || l_nondim_target_col_tbl(i) || ' IS NULL'
             || ' AND T.' || l_nondim_target_col_tbl(i) || ' IS NULL)'
             || ' OR ' || '(';
         END IF;

         l_merge_stmt_part3 := l_merge_stmt_part3
           || ' D.' || l_nondim_target_col_tbl(i)
           || ' = ' || ' T.' || l_nondim_target_col_tbl(i);

         IF g_proc_keys_tbl(v).target_nullable = 'Y' THEN
           l_merge_stmt_part3 := l_merge_stmt_part3 || '))';
         END IF;
      END IF;
    END LOOP;
  END LOOP;

  -- Bug 5114554 hkaniven end

  l_merge_stmt_part3 := l_merge_stmt_part3 || ' ) ';

  l_merge_stmt_part4 := ' WHEN MATCHED THEN UPDATE SET ' ;

  l_dummy4_sql := l_merge_stmt_part4;

  --
  -- Creating the UPDATE clause
  --

  -- Bug 5897807 (FP:5871562): Include the UNDO WHO first so we do not need to
  -- worry about whether we need to add a "," before each subsequence column
  -- being added to the update list - since "," will always be required
  -- going forward.

  -- Append the columns LAST_UPDATED_BY_OBJECT_ID, LAST_UPDATED_BY_REQUEST_ID,
  -- LEDGER_ID, CAL_PERIOD_ID, DATASET_CODE, SOURCE_SYSTEM_CODE
  -- if they dont belong to the processing key columns.
  -- The plsql table doesnt contain these values since they need a different
  -- way of handling.
  -- So all these columns if not included in the processing key combination
  -- should get updated.

  l_dummy4_sql := l_dummy4_sql || 'D.LAST_UPDATED_BY_OBJECT_ID = ' || TO_CHAR(p_object_id);
  l_dummy4_sql := l_dummy4_sql || ', D.LAST_UPDATED_BY_REQUEST_ID = ' || TO_CHAR(p_request_id);

  IF l_num_nondims > 0 THEN
    FOR i IN 1..l_num_nondims LOOP
      l_found := 0;
      FOR v IN 1..g_proc_key_dim_num
      LOOP
        IF g_proc_keys_tbl(v).target_col = l_nondim_target_col_tbl(i) THEN
          l_found := 1;
          EXIT;
        END IF;
      END LOOP;

      IF l_found <> 1 THEN
        l_dummy4_sql := l_dummy4_sql || ', D.' || l_nondim_target_col_tbl(i)
                                     || ' = T.' || l_nondim_int_col_tbl(i);
        l_found := 0;
      END IF;
    END LOOP;
  END IF;

  l_found := 0;
  FOR v IN 1..g_proc_key_dim_num
  LOOP
     IF g_proc_keys_tbl(v).target_col = 'LEDGER_ID' THEN
        l_found := 1;
        EXIT;
     END IF;
  END LOOP;

  IF l_found <> 1 THEN
   l_dummy4_sql := l_dummy4_sql || ', D.LEDGER_ID = ' || TO_CHAR(p_ledger_id);
   l_found := 0;
  END IF;


  FOR v IN 1..g_proc_key_dim_num
  LOOP
     IF g_proc_keys_tbl(v).target_col = 'CAL_PERIOD_ID' THEN
        l_found := 1;
        EXIT;
     END IF;
  END LOOP;

  IF l_found <> 1 THEN
   l_dummy4_sql := l_dummy4_sql || ', D.CAL_PERIOD_ID = ' || TO_CHAR(p_cal_period_id);
   l_found := 0;
  END IF;

  FOR v IN 1..g_proc_key_dim_num
  LOOP
     IF g_proc_keys_tbl(v).target_col = 'DATASET_CODE' THEN
        l_found := 1;
        EXIT;
     END IF;
  END LOOP;

  IF l_found <> 1 THEN
   l_dummy4_sql := l_dummy4_sql || ', D.DATASET_CODE = ' || TO_CHAR(p_dataset_code);
   l_found := 0;
  END IF;

  FOR v IN 1..g_proc_key_dim_num
    LOOP
     IF g_proc_keys_tbl(v).target_col = 'SOURCE_SYSTEM_CODE' THEN
        l_found := 1;
        EXIT;
     END IF;
  END LOOP;

  IF l_found <> 1 THEN
   l_dummy4_sql := l_dummy4_sql || ', D.SOURCE_SYSTEM_CODE = ' || TO_CHAR(p_source_system_code);
   l_found := 0;
  END IF;


  -- Append the dimension columns
  IF g_num_dims > 0 THEN
    FOR i IN 1..g_num_dims LOOP
       l_found := 0;
	      FOR v IN 1..g_proc_key_dim_num
          LOOP
                IF g_proc_keys_tbl(v).target_col = g_xdim_info_tbl(i).target_col THEN
                     l_found := 1;
                     EXIT;
                END IF;
          END LOOP;

          IF l_found <> 1 THEN
	            l_dummy4_sql := l_dummy4_sql || ', D.' || g_xdim_info_tbl(i).target_col
                                                         || ' =  T.DIM' ||  to_char(i);
          END IF;
     END LOOP;
   END IF;

  l_merge_stmt_part4 := l_dummy4_sql ;

  l_dummy6_sql := ' FROM fem_source_data_interim_gt g, '
                  ||p_interface_table_name||' i'
                  ||' WHERE i.rowid = g.interface_rowid'
                  ||' AND g.error_code IS NULL';

  -- Modify the INSERT statement created to suit the MERGE statement
  l_dummy5_sql  := 'INTO ' || p_target_table_name ;
  l_dummy5_sql := REPLACE (x_insert_target_sql, l_dummy5_sql);
  l_dummy5_sql := REPLACE  ( l_dummy5_sql, 'SELECT', 'VALUES (');
  l_dummy5_sql := REPLACE (l_dummy5_sql, l_dummy6_sql);

  l_dummy5_sql := REPLACE (l_dummy5_sql, 'g.', 'T.');
  l_dummy5_sql := REPLACE (l_dummy5_sql, 'i.', 'T.');

  l_merge_stmt_part5 := ' WHEN NOT MATCHED THEN ' || l_dummy5_sql || ')' ;

  l_merge_stmt :=  l_merge_stmt_part1 || l_merge_stmt_part2 || l_merge_stmt_part3 ||
                     l_merge_stmt_part4 || l_merge_stmt_part5;

  -- Assigning the value of 'MERGE' statement to the same variable which holds 'INSERT' statement
  -- since this is 'Replacement' mode or 'Error Reprocessing' mode.
  x_insert_target_sql := l_merge_stmt;


  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Dynamic MERGE statement in parts');

    FEM_ENGINES_PKG.TECH_MESSAGE(
       p_severity => G_LOG_LEVEL_STATEMENT,
       p_module   => C_MODULE,
       p_msg_text => 'MERGE INTO clause - l_merge_stmt_part1 ');

    str_length := 0;

    LOOP
        EXIT WHEN  str_length > LENGTH(l_merge_stmt_part1);

        FEM_ENGINES_PKG.TECH_MESSAGE(
           p_severity => G_LOG_LEVEL_STATEMENT,
           p_module   => C_MODULE,
           p_msg_text => SUBSTR(l_merge_stmt_part1,str_length+1,2000));

        str_length := str_length + 2000;
    END LOOP;

    FEM_ENGINES_PKG.TECH_MESSAGE(
       p_severity => G_LOG_LEVEL_STATEMENT,
       p_module   => C_MODULE,
       p_msg_text => 'SELECT clause - l_merge_stmt_part2 ');

    str_length := 0;

    LOOP
       EXIT WHEN  str_length > LENGTH(l_merge_stmt_part2);

       FEM_ENGINES_PKG.TECH_MESSAGE(
           p_severity => G_LOG_LEVEL_STATEMENT,
           p_module   => C_MODULE,
           p_msg_text => SUBSTR(l_merge_stmt_part2,str_length+1,2000));

       str_length := str_length + 2000;
    END LOOP;

    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'ON clause - l_merge_stmt_part3 ');

    str_length := 0;

    LOOP
        EXIT WHEN  str_length > LENGTH(l_merge_stmt_part3);

        FEM_ENGINES_PKG.TECH_MESSAGE(
           p_severity => G_LOG_LEVEL_STATEMENT,
           p_module   => C_MODULE,
           p_msg_text => SUBSTR(l_merge_stmt_part3,str_length+1,2000));

        str_length := str_length + 2000;
    END LOOP;

   FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'WHEN MATCHED THEN clause - l_merge_stmt_part4 ');

    str_length := 0;

    LOOP
        EXIT WHEN  str_length > LENGTH(l_merge_stmt_part4);

        FEM_ENGINES_PKG.TECH_MESSAGE(
           p_severity => G_LOG_LEVEL_STATEMENT,
           p_module   => C_MODULE,
           p_msg_text => SUBSTR(l_merge_stmt_part4,str_length+1,2000));

        str_length := str_length + 2000;
    END LOOP;

    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'WHEN NOT MATCHED THEN clause - l_merge_stmt_part5 ' );

    str_length := 0;

    LOOP
        EXIT WHEN  str_length > LENGTH(l_merge_stmt_part5);

        FEM_ENGINES_PKG.TECH_MESSAGE(
           p_severity => G_LOG_LEVEL_STATEMENT,
           p_module   => C_MODULE,
           p_msg_text => SUBSTR(l_merge_stmt_part5,str_length+1,2000));

        str_length := str_length + 2000;
    END LOOP;

    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Complete MERGE statement - l_merge_stmt');

    str_length := 0;

    LOOP
        EXIT WHEN  str_length > LENGTH(l_merge_stmt);

        FEM_ENGINES_PKG.TECH_MESSAGE(
           p_severity => G_LOG_LEVEL_STATEMENT,
           p_module   => C_MODULE,
           p_msg_text => SUBSTR(l_merge_stmt,str_length+1,2000));

        str_length := str_length + 2000;
    END LOOP;

  END IF;

  g_proc_keys_tbl.DELETE;

 END IF;

  -- End of Replacement enhancement

  l_nondim_target_col_tbl.DELETE;
  l_nondim_int_col_tbl.DELETE;

  x_return_status := G_RET_STS_SUCCESS;

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Procedure returning with status of '||x_return_status);
  END IF;
  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

EXCEPTION
  WHEN others THEN
    x_return_status := G_RET_STS_UNEXP_ERROR;

END Prepare_Dynamic_Sql;


--
-- Procedure
--      Process_Data
-- Purpose
--         Performs dimension validation and dimension numeric ID lookup
--        (for those dimensions that need it), and finally move the data
--        from the interface table to the target table.
--
--        This module is called by the Multiprocessing (MP) framework
--        "Master" module.
-- History
--     09-07-04    GCHENG        Created
-- Arguments
--    p_eng_sql          : Required by MP. Not currently used.
--    p_data_slice_predicate : MP data slice predicate
--    p_process_number   : Number assigned by MP Master to each subrequest.
--    p_partition_code   : Process Partition Code that is set in MP Options
--    p_fetch_limit      : Fetch limit for any bulk fetch operations
--    p_request_id       : Concurrent request ID of the Main process
--    p_exec_mode        : Execution mode, S (Snapshot)/R (Replacement)
--                                         E (Error Reprocessing)
--    p_table_name       : Source data target table name
--    p_interface_table_name : Source data interface table name
--    p_ledger_id        : Ledger to load data for
--    p_insert_interim_sql : SQL to copy slice from interface table
--                                   to interim table
--    p_update_interim_error_sql : SQL to update the interim error_code for
--                                 dimension validation errors
--    p_insert_target_sql : SQL to update the interim error_code for
--                              dimension validation
--    p_schema_name      : Schema name of FEM_SOURCE_DATA_INTERIM_GT.
-- Notes
--
PROCEDURE Process_Data (
  p_eng_sql                  IN  VARCHAR2,
  p_data_slice_predicate     IN  VARCHAR2,
  p_process_number           IN  NUMBER,
  p_partition_code           IN  NUMBER,
  p_fetch_limit              IN  NUMBER,
  p_request_id               IN  VARCHAR2,
  p_exec_mode                IN  VARCHAR2,
  p_target_table_name        IN  VARCHAR2,
  p_interface_table_name     IN  VARCHAR2,
  p_object_id                IN  NUMBER,
  p_ledger_id                IN  VARCHAR2,
  p_cal_period_id            IN  NUMBER,
  p_dataset_code             IN  NUMBER,
  p_source_system_code       IN  NUMBER,
  p_schema_name              IN  VARCHAR2,
  p_condition                IN  VARCHAR2
) IS
  C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_source_data_loader_pkg.process_data';

  l_slc_id                         NUMBER;
  l_slc_val1                       VARCHAR2(240);
  l_slc_val2                       VARCHAR2(240);
  l_slc_val3                       VARCHAR2(240);
  l_slc_val4                       VARCHAR2(240);
  l_num_vals                       NUMBER;
  l_part_name                      VARCHAR2(30);

  l_slc_status                     NUMBER;
  l_slc_msg                        VARCHAR2(80);
  l_slc_num_errors_reprocessed     NUMBER;
  l_slc_num_rows_loaded            NUMBER;
  l_slc_num_rows_rejected          NUMBER;
  l_slc_num_rows_copied            NUMBER;
  l_dummy_num                      NUMBER;

  l_insert_interim_sql             VARCHAR2(30000);
  l_update_interim_error_sql       VARCHAR2(30000);
  l_insert_target_sql              VARCHAR2(30000);
  l_dynamic_sql                    VARCHAR2(30000);
  l_dummy1_sql                     VARCHAR2(2000);
  l_dummy2_sql                     VARCHAR2(2000);
  l_dummy3_sql                     VARCHAR2(8000);
  l_dim_grp_size                   NUMBER;
  l_dim_grp_count                  NUMBER;
  l_dup_index_error                BOOLEAN;
  l_dummy_boolean                  BOOLEAN;
  l_request_status                 VARCHAR2(10);
  l_return_status                  VARCHAR2(2);
BEGIN
  -- set value of debug log current level
  g_log_current_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Init var
  l_request_status := 'NORMAL';

  -- Prepares all the dynamic SQL to be used in this session.
  -- This used to be called from the Main procedure so that
  -- the three dynamic SQL statements are only built once, as
  -- opposed to for each MP subprocess.  However, that required
  -- the SQL statements to be passed through MP.
  -- Unfortunately, MP has a 32K restriction on the param list
  -- that gets passed to the engine program
  Prepare_Dynamic_Sql (
    p_object_id                => p_object_id,
    p_exec_mode                => p_exec_mode,
    p_request_id               => p_request_id,
    p_ledger_id                => p_ledger_id,
    p_cal_period_id            => p_cal_period_id,
    p_dataset_code             => p_dataset_code,
    p_source_system_code       => p_source_system_code,
    p_interface_table_name     => p_interface_table_name,
    p_target_table_name        => p_target_table_name,
    p_condition                => p_condition,
    x_insert_interim_sql       => l_insert_interim_sql,
    x_update_interim_error_sql => l_update_interim_error_sql,
    x_insert_target_sql        => l_insert_target_sql,
    x_return_status            => l_return_status);

  IF l_return_status <> G_RET_STS_SUCCESS THEN
    IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'Call to prepare_dynamic_sql failed.');
    END IF;
    RAISE e_unexp_error;
  END IF;

  IF p_data_slice_predicate IS NOT NULL THEN
    l_insert_interim_sql := l_insert_interim_sql||' AND '||p_data_slice_predicate;
  END IF;

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'SQL to insert into interim is '||l_insert_interim_sql);
  END IF;

  -- Keep looping until no more data slices are left to process
  LOOP
    -- Initialize variables
    l_dup_index_error := FALSE;
    l_slc_num_errors_reprocessed := 0;
    l_slc_num_rows_loaded := 0;
    l_slc_num_rows_rejected := 0;
    l_slc_num_rows_copied  := 0;
    l_slc_id := to_number(null);
    l_slc_msg  := null;

    FEM_MULTI_PROC_PKG.Get_Data_Slice(
      x_slc_id       => l_slc_id,
      x_slc_val1     => l_slc_val1,
      x_slc_val2     => l_slc_val2,
      x_slc_val3     => l_slc_val3,
      x_slc_val4     => l_slc_val4,
      x_num_vals     => l_num_vals,
      x_part_name    => l_part_name,
      p_req_id       => p_request_id,
      p_proc_num     => p_process_number);

    EXIT WHEN (l_slc_id IS NULL);

    IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'Begin processing slice id '||to_char(l_slc_id));
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'Number of binding values is '||to_char(l_num_vals));
    END IF;

    -- Step 1:
     -- Copy rowid to interim table
    --
    IF (l_num_vals = 4) THEN
      EXECUTE IMMEDIATE l_insert_interim_sql
        USING l_slc_val1,l_slc_val2,l_slc_val3,l_slc_val4;
    ELSIF (l_num_vals = 3) THEN
      EXECUTE IMMEDIATE l_insert_interim_sql
        USING l_slc_val1,l_slc_val2,l_slc_val3;
    ELSIF (l_num_vals = 2) THEN
      EXECUTE IMMEDIATE l_insert_interim_sql
        USING l_slc_val1,l_slc_val2;
    ELSIF (l_num_vals = 1) THEN
      EXECUTE IMMEDIATE l_insert_interim_sql
        USING l_slc_val1;
    ELSE
      IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => G_LOG_LEVEL_STATEMENT,
          p_module   => C_MODULE,
          p_msg_text => 'Multiprocessing engine generated an unexpected number '
                     ||'of binding values: '||to_char(l_num_vals));
      END IF;
      RAISE e_unexp_error;
    END IF;

    l_slc_num_rows_copied := SQL%ROWCOUNT;

    -- Commit to release any reserved rollback space.
    -- Three is no harm is commiting now since the only transaction done
    -- so far is copying data into the global temporary interim table.
    -- If an error occurs that ends this process prematurely, there are no
    -- negative side effects as all data in global temporary tables
    -- are session specific.  If this process aborts, its session ends
    -- and all data is wiped out anyway.
    COMMIT;

    IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'Number of rows copied to the interim table is '
          ||to_char(l_slc_num_rows_copied));
    END IF;

    -- Steps 2, 3, 4:
    -- Perform dimension lookup and validiation.
    -- If there are no dimensions, skip these steps.
    --
    IF g_num_dims = 0 THEN
      IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => G_LOG_LEVEL_STATEMENT,
          p_module   => C_MODULE,
          p_msg_text => 'There are no dimensions.  No dimension validation to perform.');
      END IF;
    ELSE
      -- Step 2:
      -- Perform dimension lookup
      l_dim_grp_size := to_number(FND_PROFILE.Value('FEM_LOADER_DIM_GRP_SIZE'));
      IF nvl(l_dim_grp_size,0) <= 0 THEN
        l_dim_grp_size := G_DEFAULT_DIM_GRP_SIZE;
      ELSIF nvl(l_dim_grp_size,0) > g_num_dims THEN
        l_dim_grp_size := g_num_dims;
      END IF;

      IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => G_LOG_LEVEL_STATEMENT,
          p_module   => C_MODULE,
          p_msg_text => 'Dimension grouping size is '||l_dim_grp_size);
      END IF;

      -- Initialize counter that keeps track of how many dimensions
      -- that have been grouped
      l_dim_grp_count := 1;

      FOR dim_index IN 1..g_num_dims LOOP
        IF l_dim_grp_count = 1 THEN
          l_dynamic_sql := 'UPDATE fem_source_data_interim_gt g SET (';
          l_dummy1_sql  := '(SELECT ';
          l_dummy2_sql  := ' FROM '||p_interface_table_name||' i';
          l_dummy3_sql  := ' WHERE i.rowid=g.interface_rowid';
         END IF;

        -- UPDATE SET clause
        l_dynamic_sql := l_dynamic_sql||'g.DIM'||to_char(dim_index);

        -- SELECT clause (dimension ID lookup)
        -- Explicitly convert the data type of the member col to
        -- that of the DIMx columns (VARCHAR2) where necessary.
        IF g_xdim_info_tbl(dim_index).target_col_data_type = 'NUMBER' THEN
          l_dummy1_sql := l_dummy1_sql||'to_char(d'||to_char(dim_index)||'.'
            ||g_xdim_info_tbl(dim_index).member_col||')';
        ELSIF g_xdim_info_tbl(dim_index).target_col_data_type = 'DATE' THEN
          l_dummy1_sql := l_dummy1_sql||'to_char(d'||to_char(dim_index)||'.'
            ||g_xdim_info_tbl(dim_index).member_col
            ||','''||G_DATETIME_FORMAT||''')';
         ELSE
          l_dummy1_sql := l_dummy1_sql||'d'||to_char(dim_index)||'.'
            ||g_xdim_info_tbl(dim_index).member_col;
        END IF;

        -- FROM clause
        l_dummy2_sql := l_dummy2_sql||','
          ||g_xdim_info_tbl(dim_index).member_b_table_name||' d'||to_char(dim_index);

        -- WHERE clause
        -- match display codes
            l_dummy3_sql := l_dummy3_sql||' AND d'||to_char(dim_index)||'.'
          ||g_xdim_info_tbl(dim_index).member_disp_code_col||'(+)'
          ||'=i.'||g_xdim_info_tbl(dim_index).int_disp_code_col;

        -- make sure personal flag is N
        l_dummy3_sql := l_dummy3_sql
          ||' AND d'||to_char(dim_index)||'.'||'personal_flag(+)=''N''';
        -- if dimension has value set associated with it, make sure
        -- it matches with the value set tied to the global value set combo
        IF g_xdim_info_tbl(dim_index).vs_id IS NOT NULL THEN
          l_dummy3_sql := l_dummy3_sql||' AND d'||to_char(dim_index)||'.'
            ||'value_set_id(+)'
            ||'='||to_char(g_xdim_info_tbl(dim_index).vs_id);
        END IF;

        -- Execute the update statement when number of dimenions reach
        -- dimension group size
        IF l_dim_grp_count = l_dim_grp_size OR dim_index = g_num_dims THEN

          -- If number of dimensions to group is 1, set the error_code
          -- with the interface column name that failed validation.
          IF l_dim_grp_size = 1 THEN
            l_dynamic_sql := l_dynamic_sql||',g.error_code)='||l_dummy1_sql
              ||',decode(i.'
              ||g_xdim_info_tbl(dim_index).int_disp_code_col||',null,null,'
              ||'decode(d'||to_char(dim_index)||'.'
              ||g_xdim_info_tbl(dim_index).member_disp_code_col||',null,'
              ||''''||g_xdim_info_tbl(dim_index).int_disp_code_col||'''))'
              ||l_dummy2_sql||l_dummy3_sql||')'
              ||'WHERE g.error_code IS NULL';

          -- Else, do not try to detect error as it involves O(n^2) decode
          -- statements.
          ELSE
            l_dynamic_sql := l_dynamic_sql||')='||l_dummy1_sql||l_dummy2_sql
              ||l_dummy3_sql||')';
          END IF;

          IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
            FEM_ENGINES_PKG.TECH_MESSAGE(
              p_severity => G_LOG_LEVEL_STATEMENT,
              p_module   => C_MODULE,
              p_msg_text => 'SQL to update interim errors is '||l_dynamic_sql);
          END IF;

          EXECUTE IMMEDIATE l_dynamic_sql;

          -- Reset the dimension group counter after update statement executes
          l_dim_grp_count := 1;

          -- Commit to release any reserved rollback space.
          COMMIT;
        ELSE
          l_dim_grp_count := l_dim_grp_count+1;
          l_dynamic_sql := l_dynamic_sql||',';
          l_dummy1_sql  := l_dummy1_sql||',';
        END IF;
      END LOOP;

      -- Step 3:
      -- If dim group size <> 1.
      -- perform dimension validation.
      -- Mark those rows in interim tables that failed dimension validation.
      -- If dim group size = 1, the dimension validation was preformed
      -- at the same time of the dimension ID lookup - via decode stmts.
      IF l_dim_grp_size <> 1 THEN
        EXECUTE IMMEDIATE l_update_interim_error_sql;
        l_slc_num_rows_rejected := SQL%ROWCOUNT;
        -- Commit to release any reserved rollback space.
        COMMIT;

        IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
          FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => G_LOG_LEVEL_STATEMENT,
            p_module   => C_MODULE,
            p_msg_text => 'Number of rows that failed dimension validation in interim is '
              ||to_char(l_slc_num_rows_rejected));
        END IF;
      END IF;


      -- Step 4
      -- Update the interface table to reflect any errors found during
      --   dimension validation.
      --
      -- If any rows failed validation,
      -- copy the error_code from the interim table over as status
      -- in the interface table.
      -- Currently, the only error_code being set in the interim table
      -- is 'FEM_SD_LDR_INV_DIM_MEMBER' so it is hard coded to that
      -- for performance reasons.  Otherwise, the set status clause will need
      -- to be a subquery to the effects of:
      --   (SELECT g.error_code FROM fem_source_data_interim_gt g
      --    WHERE i.rowid = g.interface_rowid AND g.error_code IS NOT NULL)

      -- If dim group size = 1, append the specific dimension column that
      -- failed validation to FEM_SD_LDR_INV_DIM_MEMBER in the status column.
      IF l_dim_grp_size = 1 THEN
        l_dynamic_sql := 'UPDATE '||p_interface_table_name||' i'
          ||' SET i.status='
          ||' (SELECT ''FEM_SD_LDR_INV_DIM_MEMBER: ''||t.error_code'
          ||' FROM fem_source_data_interim_gt t'
          ||' WHERE t.interface_rowid=i.rowid'
          ||' AND t.error_code IS NOT NULL)'
          ||' WHERE i.rowid IN'
          ||' (SELECT g.interface_rowid FROM fem_source_data_interim_gt g'
          ||' WHERE g.error_code IS NOT NULL)';

        EXECUTE IMMEDIATE l_dynamic_sql;
        l_slc_num_rows_rejected := SQL%ROWCOUNT;

        IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
          FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => G_LOG_LEVEL_STATEMENT,
            p_module   => C_MODULE,
            p_msg_text => 'Number of rows in interface table set with dimension validation error is '
              ||to_char(l_slc_num_rows_rejected));
        END IF;

      -- If dim group size > 1, then just set the status with error code
      -- FEM_SD_LDR_INV_DIM_MEMBER - the user has to figure out which
      -- dimension column failed validation.
      ELSE
        IF l_slc_num_rows_rejected > 0 THEN
          l_dynamic_sql := 'UPDATE '||p_interface_table_name||' i'
            ||' SET i.status = ''FEM_SD_LDR_INV_DIM_MEMBER'''
            ||'  WHERE i.rowid IN'
            ||' (SELECT g.interface_rowid FROM fem_source_data_interim_gt g'
            ||' WHERE g.error_code IS NOT NULL)';

          EXECUTE IMMEDIATE l_dynamic_sql;
          l_dummy_num := SQL%ROWCOUNT;

          IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
            FEM_ENGINES_PKG.TECH_MESSAGE(
              p_severity => G_LOG_LEVEL_STATEMENT,
              p_module   => C_MODULE,
              p_msg_text => 'Number of rows in interface table set with dimension validation error is '
                ||to_char(l_dummy_num));
          END IF;

          -- See if number of error rows updated in interface table is
          -- consistent with number of error rows updated in interim table.
          IF l_dummy_num <> l_slc_num_rows_rejected THEN
            l_slc_num_rows_rejected := l_dummy_num;

            IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
              FEM_ENGINES_PKG.TECH_MESSAGE(
                p_severity => G_LOG_LEVEL_STATEMENT,
                p_module   => C_MODULE,
                p_msg_text => 'Number of error rows updated in interface table is '
                  ||' not the same as the number of error rows updated in the interim table.');
            END IF;
            RAISE e_unexp_error;
          END IF;
        END IF;

        -- Commit to release any reserved rollback space.
        COMMIT;
      END IF;
    END IF;

    -- Step 5
    -- Insert validated rows in the target table if there are
    -- actually validated rows to insert.
    IF l_slc_num_rows_rejected < l_slc_num_rows_copied THEN
      BEGIN
        EXECUTE IMMEDIATE l_insert_target_sql;
        l_slc_num_rows_loaded := SQL%ROWCOUNT;

        IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
          FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => G_LOG_LEVEL_STATEMENT,
          p_module   => C_MODULE,
          p_msg_text => 'Number of rows inserted into the target table is '
            ||to_char(l_slc_num_rows_loaded));
        END IF;
      EXCEPTION
        WHEN dup_val_on_index THEN
          l_slc_msg := 'Duplicate rows exist in this slice.';
          l_slc_num_rows_loaded := 0;
          l_dup_index_error := TRUE;
        WHEN others THEN
          IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
            FEM_ENGINES_PKG.TECH_MESSAGE(
              p_severity => G_LOG_LEVEL_STATEMENT,
              p_module   => C_MODULE,
              p_msg_text => 'Unexpected error occured when inserting into'
                ||' the target table.');
          END IF;
          RAISE;
      END;
     END IF;


    -- Step 6a
    -- If the insert to target table raised a DUP_VAL_ON_INDEX error,
    -- mark those rows with status of 'FEM_SD_LDR_DUPLICATE_ROW'.
    IF l_dup_index_error THEN
      l_dynamic_sql := 'UPDATE '||p_interface_table_name||' i'
        ||' SET i.status = ''FEM_SD_LDR_DUPLICATE_ROW'''
        ||'  WHERE i.rowid IN'
        ||' (SELECT g.interface_rowid FROM fem_source_data_interim_gt g'
        ||' WHERE g.error_code IS NULL)';

      EXECUTE IMMEDIATE l_dynamic_sql;
      -- Add to the number of rows rejected counter
      l_slc_num_rows_rejected := l_slc_num_rows_rejected + SQL%ROWCOUNT;

      IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'Number of rows in interface set with duplicate error is '
          ||to_char(SQL%ROWCOUNT));
      END IF;

    -- Step 6a
    -- If the insert to target table was successful,
    -- delete those inserted rows from the interface table.
    ELSIF l_slc_num_rows_rejected < l_slc_num_rows_copied THEN
      l_dynamic_sql := 'DELETE FROM '||p_interface_table_name||' i'
        ||' WHERE i.rowid IN (SELECT g.interface_rowid'
        ||' FROM fem_source_data_interim_gt g WHERE g.error_code IS NULL)';
      EXECUTE IMMEDIATE l_dynamic_sql;
      l_dummy_num := SQL%ROWCOUNT;

      IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'Number of rows deleted from the interface table is '
          ||to_char(l_dummy_num));
      END IF;

      -- See if number of rows deleted from the interface table is
      -- consistent with number of rows inserted into the target table.
      IF l_dummy_num <> l_slc_num_rows_loaded THEN
        l_slc_num_rows_loaded := l_dummy_num;

        IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
          FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => G_LOG_LEVEL_STATEMENT,
            p_module   => C_MODULE,
            p_msg_text => 'The number of rows deleted from the interface table'
              ||' is not the same as the number of rows inserted into the target table.');
        END IF;
        RAISE e_unexp_error;
      END IF;

    END IF;

    -- If the number of rows rejected + loaded <> copied, raise unexp error
    IF (l_slc_num_rows_rejected+l_slc_num_rows_loaded)
          <> l_slc_num_rows_copied THEN
      IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => G_LOG_LEVEL_STATEMENT,
          p_module   => C_MODULE,
          p_msg_text => 'Num rows copied ('
            ||to_char(l_slc_num_rows_copied)
            ||') does not equal num rows rejected ('
            ||to_char(l_slc_num_rows_rejected)||') plus num rows loaded ('
            ||to_char(l_slc_num_rows_loaded)||').');
      END IF;

      RAISE e_unexp_error;
    END IF;

    IF p_exec_mode = 'S' THEN
      l_slc_num_errors_reprocessed := 0;
    ELSE
      l_slc_num_errors_reprocessed := l_slc_num_rows_loaded;
    END IF;

    -- Need to make sure these two steps are in the same transaction:
    -- 5. Insert valid rows into the target table
    -- 6.
    --   a. Mark group of rows in interface table that contain at least one
    --      duplicate row.
    -- - or -
    --   b. Delete valid rows from the interface table.
    COMMIT;

    IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'Slice process summary: '
          ||to_char(l_slc_num_errors_reprocessed)||' error rows reprocessed, '
          ||to_char(l_slc_num_rows_loaded)||' rows loaded, '
          ||to_char(l_slc_num_rows_rejected)||' rows rejected.');
    END IF;

    IF l_slc_num_rows_rejected > 0 THEN
      -- set slice and request status as warning so next slice can be processed
      l_slc_status := 1;
      l_request_status := 'WARNING';
    ELSE
      l_slc_status := 0;
    END IF;

    -- ------------------------------------------------------------
    -- Truncate FEM_SOURCE_DATA_INTERIM_GT for the next data slice
    -- ------------------------------------------------------------

    IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text =>
           'Truncating '||p_schema_name||'.FEM_SOURCE_DATA_INTERIM_GT for the next data slice.');
    END IF;

    EXECUTE IMMEDIATE
        'TRUNCATE TABLE ' || p_schema_name || '.fem_source_data_interim_gt';
    COMMIT;

    FEM_MULTI_PROC_PKG.Post_Data_Slice(
      p_req_id           => p_request_id,
      p_slc_id           => l_slc_id,
      p_status           => l_slc_status,
      p_message          => l_slc_msg,
      p_rows_processed   => l_slc_num_errors_reprocessed,
      p_rows_loaded      => l_slc_num_rows_loaded,
      p_rows_rejected    => l_slc_num_rows_rejected);

    IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'Finished processing slice id '||to_char(l_slc_id)
          ||' with status of '||l_slc_status);
    END IF;
  END LOOP;

  -- set request status
  l_dummy_boolean := FND_CONCURRENT.Set_Completion_Status
                      (status => l_request_status, message => NULL);

  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

EXCEPTION
  WHEN others THEN
    ROLLBACK;
    l_slc_status := 2;
    IF l_slc_msg IS NULL THEN
      l_slc_msg := 'Unexpected error.  Abort processing.';
    END IF;

    FEM_MULTI_PROC_PKG.Post_Data_Slice(
      p_req_id           => p_request_id,
      p_slc_id           => l_slc_id,
      p_status           => l_slc_status,
      p_message          => l_slc_msg,
      p_rows_processed   => l_slc_num_errors_reprocessed,
      p_rows_loaded      => l_slc_num_rows_loaded,
      p_rows_rejected    => l_slc_num_rows_rejected);

    -- set request status
    l_dummy_boolean := FND_CONCURRENT.Set_Completion_Status
                      (status => 'ERROR', message => NULL);

    FEM_ENGINES_PKG.User_Message
      (p_app_name => 'FEM',
       p_msg_name => 'FEM_UNEXPECTED_ERROR',
       p_token1   => 'ERR_MSG',
       p_value1   => SQLERRM);
    FEM_ENGINES_PKG.Tech_Message
     (p_severity => G_LOG_LEVEL_UNEXPECTED,
      p_module   => C_MODULE,
      p_app_name => 'FEM',
      p_msg_name => 'FEM_UNEXPECTED_ERROR',
      p_token1   => 'ERR_MSG',
      p_value1   => SQLERRM);
END Process_Data;

--
-- Procedure
--      Post_Process
-- Purpose
--         Performs post-process execution logging.  Certain logging
--        operations are required only for successful completion or are
--        done differently for success and failure, so a parameter is
--        passed to indicate the mode.
--        Upon successful completion, this module is called from the
--        body of the Main module.  Upon cancellation or fatal error
--        it is called from the exception handler of the Main module.
-- History
--     09-07-04    GCHENG        Created
-- Arguments
--    p_object_id        : Object ID that identifies the rule being executed.
--    p_obj_def_id       : Object Definition ID that identifies the rule
--                           version being executed.
--    p_table_name       : Source Data Table Name
--    p_exec_mode        : Execution mode, S (Snapshot)/R (Replacement)
--                                         E (Error Reprocessing)
--    p_ledger_id        : Ledger to load data for
--    p_cal_period_id    : Period to load data for
--    p_dataset_code     : Dataset to load data for
--    p_source_system_code  : Source system to load data for
--    p_request_id       : Concurrent request ID
--    p_user_id          : User ID
--    p_login_id         : Login ID
--    x_return_status    : Return status
--                           (look at FND_API for the possible statuses)
-- Notes
--
PROCEDURE Post_Process (
  p_object_id                IN         NUMBER,
  p_obj_def_id               IN         NUMBER,
  p_table_name               IN         VARCHAR2,
  p_exec_mode                IN         VARCHAR2,
  p_ledger_id                IN         NUMBER,
  p_cal_period_id            IN         NUMBER,
  p_dataset_code             IN         NUMBER,
  p_source_system_code       IN         NUMBER,
  p_exec_status              IN         VARCHAR2,
  p_request_id               IN         NUMBER,
  p_user_id                  IN         NUMBER,
  p_login_id                 IN         NUMBER,
  x_return_status            OUT NOCOPY VARCHAR2
) IS
  C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_source_data_loader_pkg.post_process';

  l_num_errors_reprocessed   NUMBER;
  l_num_rows_loaded          NUMBER;
  l_num_rows_rejected        NUMBER;
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(4000);
  l_return_status            VARCHAR2(1);
  l_dummy_boolean            BOOLEAN;
BEGIN
  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;
  -- Log parameters
  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Execution Status is '||p_exec_status);
  END IF;

  SELECT nvl(SUM(rows_processed),0), nvl(SUM(rows_loaded),0), nvl(SUM(rows_rejected),0)
  INTO l_num_errors_reprocessed, l_num_rows_loaded, l_num_rows_rejected
  FROM fem_mp_process_ctl_t
  WHERE req_id = p_request_id;

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => G_LOG_LEVEL_STATEMENT,
       p_module   => C_MODULE,
       p_msg_text => to_char(l_num_rows_loaded)||' total rows loaded.');
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => G_LOG_LEVEL_STATEMENT,
       p_module   => C_MODULE,
       p_msg_text => to_char(l_num_errors_reprocessed)||' total error rows reprocessed.');
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => G_LOG_LEVEL_STATEMENT,
       p_module   => C_MODULE,
       p_msg_text => to_char(l_num_rows_rejected)||' total rows rejected.');
  END IF;

  -- Print to concurrent log the number of rows loaded and rejected
  FEM_ENGINES_PKG.User_Message
      (p_app_name => 'FEM',
       p_msg_name => 'FEM_SD_LDR_PROCESS_SUMMARY',
       p_token1   => 'LOADNUM',
       p_value1   => l_num_rows_loaded,
       p_token2   => 'REJECTNUM',
       p_value2   => l_num_rows_rejected);

  -- Update Number of Output Rows
  FEM_PL_PKG.Update_Num_of_Output_Rows(
    p_api_version          => G_API_VERSION,
    p_commit               => G_TRUE,
    p_request_id           => p_request_id,
    p_object_id            => p_object_id,
    p_table_name           => p_table_name,
    p_statement_type       => G_INSERT_STMT_TYPE,
    p_num_of_output_rows   => l_num_rows_loaded,
    p_user_id              => p_user_id,
    p_last_update_login    => p_login_id,
    x_msg_count            => l_msg_count,
    x_msg_data             => l_msg_data,
    x_return_status        => l_return_status);

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.Tech_Message
           (p_severity => G_LOG_LEVEL_STATEMENT,
            p_module   => C_MODULE,
            p_msg_text => 'Call to FEM_PL_PKG.Update_Num_of_Output_Rows returned with status '
              ||l_return_status);
  END IF;

  IF l_msg_count > 0 THEN
    Get_Put_Messages (
      p_msg_count => l_msg_count,
      p_msg_data  => l_msg_data);
   END IF;

  IF l_return_status <> G_RET_STS_SUCCESS THEN
    RAISE e_unexp_error;
  END IF;

  -- Update Object Execution Status
  FEM_PL_PKG.Update_Obj_Exec_Status(
    p_api_version         => G_API_VERSION,
    p_commit              => G_TRUE,
    p_request_id          => p_request_id,
    p_object_id           => p_object_id,
    p_exec_status_code    => p_exec_status,
    p_user_id             => p_user_id,
    p_last_update_login   => p_login_id,
    x_msg_count           => l_msg_count,
    x_msg_data            => l_msg_data,
    x_return_status       => l_return_status);

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.Tech_Message
           (p_severity => G_LOG_LEVEL_STATEMENT,
            p_module   => C_MODULE,
            p_msg_text => 'Call to FEM_PL_PKG.pdate_Obj_Exec_Status returned with status '
              ||l_return_status);
  END IF;

  IF l_msg_count > 0 THEN
    Get_Put_Messages (
      p_msg_count => l_msg_count,
      p_msg_data  => l_msg_data);
   END IF;

  IF l_return_status <> G_RET_STS_SUCCESS THEN
    RAISE e_unexp_error;
  END IF;

  -- Update Object Execution Errors
  FEM_PL_PKG.Update_Obj_Exec_Errors(
    p_api_version         => G_API_VERSION,
    p_commit              => G_TRUE,
    p_request_id          => p_request_id,
    p_object_id           => p_object_id,
    p_errors_reported     => l_num_rows_rejected,
    p_errors_reprocessed  => l_num_errors_reprocessed,
    p_user_id             => p_user_id,
    p_last_update_login   => p_login_id,
    x_msg_count           => l_msg_count,
    x_msg_data            => l_msg_data,
    x_return_status       => l_return_status);

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.Tech_Message
           (p_severity => G_LOG_LEVEL_STATEMENT,
            p_module   => C_MODULE,
            p_msg_text => 'Call to FEM_PL_PKG.Update_Obj_Exec_Errors returned with status '
              ||l_return_status);
  END IF;

  IF l_msg_count > 0 THEN
    Get_Put_Messages (
      p_msg_count => l_msg_count,
      p_msg_data  => l_msg_data);
   END IF;

  IF l_return_status <> G_RET_STS_SUCCESS THEN
    RAISE e_unexp_error;
  END IF;

  -- Update Request Status --
  FEM_PL_PKG.Update_Request_Status(
    p_api_version         => G_API_VERSION,
    p_commit              => G_TRUE,
    p_request_id          => p_request_id,
    p_exec_status_code    => p_exec_status,
    p_user_id             => p_user_id,
    p_last_update_login   => p_login_id,
    x_msg_count           => l_msg_count,
    x_msg_data            => l_msg_data,
    x_return_status       => l_return_status);

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.Tech_Message
           (p_severity => G_LOG_LEVEL_STATEMENT,
            p_module   => C_MODULE,
            p_msg_text => 'Call to FEM_PL_PKG.Update_Request_Status returned with status '
              ||l_return_status);
  END IF;

  IF l_msg_count > 0 THEN
    Get_Put_Messages (
      p_msg_count => l_msg_count,
      p_msg_data  => l_msg_data);
   END IF;

  IF l_return_status <> G_RET_STS_SUCCESS THEN
    RAISE e_unexp_error;
  END IF;

  -- Register Data Locations
  --
  -- Bug 4904687: Only set status to COMPLETE if both rows rejected is 0
  --              and rows loaded is greater than 0.
  --
  IF l_num_rows_rejected = 0 AND l_num_rows_loaded > 0 THEN
    BEGIN
      FEM_DIMENSION_UTIL_PKG.register_data_location
        (p_request_id    => p_request_id,
         p_object_id     => p_object_id,
         p_table_name    => p_table_name,
         p_ledger_id     => p_ledger_id,
         p_cal_per_id    => p_cal_period_id,
         p_dataset_cd    => p_dataset_code,
         p_source_cd     => p_source_system_code,
         p_load_status   => G_COMPLETE_L0AD_STATUS);

      -- This commit is for the call to Register Data Locations.
      -- All other API's commit work as it completes successfully.
      COMMIT;

     EXCEPTION
       WHEN others THEN
        FEM_ENGINES_PKG.Tech_Message
           (p_severity => G_LOG_LEVEL_STATEMENT,
            p_module   => C_MODULE,
            p_msg_text => 'Call to FEM_DIMENSION_UTIL_PKG.register_data_location '
              ||'failed unexpectedly.');
        RAISE;
    END;

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => G_LOG_LEVEL_STATEMENT,
       p_module   => C_MODULE,
       p_msg_text => 'Updated Data Location status to COMPLETE');
  END IF;

  --
  -- Log the final message to the concurrent log
  --
  IF p_exec_status = 'SUCCESS' THEN
    -- Post success message to concurrent log
    FEM_ENGINES_PKG.User_Message
      (p_app_name => 'FEM',
       p_msg_name => 'FEM_EXEC_SUCCESS');
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => G_LOG_LEVEL_STATEMENT,
       p_module   => C_MODULE,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_EXEC_SUCCESS');

    -- set request status to SUCCESS
    l_dummy_boolean := FND_CONCURRENT.Set_Completion_Status
                      (status => 'NORMAL', message => NULL);
  ELSE
    -- Post error rerun message to concurrent log
    FEM_ENGINES_PKG.User_Message
      (p_app_name => 'FEM',
       p_msg_name => 'FEM_EXEC_RERUN');
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => G_LOG_LEVEL_STATEMENT,
       p_module   => C_MODULE,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_EXEC_RERUN');

    -- set request status to ERROR_RERUN
    l_dummy_boolean := FND_CONCURRENT.Set_Completion_Status
                      (status => 'ERROR', message => NULL);
  END IF;

  --
  -- Perform cleanup
  --

  -- If all goes well, Delete_Data_Slices
  FEM_MULTI_PROC_PKG.Delete_Data_Slices(
    p_req_id => p_request_id);

  g_xdim_info_tbl.DELETE;

  x_return_status := G_RET_STS_SUCCESS;

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Procedure returning with status of '||x_return_status);
  END IF;
  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

EXCEPTION
  WHEN others THEN
    x_return_status := G_RET_STS_UNEXP_ERROR;

    FEM_ENGINES_PKG.User_Message
      (p_app_name => 'FEM',
       p_msg_name => 'FEM_UNEXPECTED_ERROR',
       p_token1   => 'ERR_MSG',
       p_value1   => SQLERRM);
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => G_LOG_LEVEL_UNEXPECTED,
       p_module   => C_MODULE,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_UNEXPECTED_ERROR',
       p_token1   => 'ERR_MSG',
       p_value1   => SQLERRM);

    -- set request status to ERROR_RERUN
    l_dummy_boolean := FND_CONCURRENT.Set_Completion_Status
                      (status => 'ERROR', message => NULL);

END Post_Process;


PROCEDURE Get_Put_Messages (
   p_msg_count       IN   NUMBER,
   p_msg_data        IN   VARCHAR2
)
IS
  C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_source_data_loader_pkg.get_put_messages';
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(4000);
  l_msg_out          NUMBER;
  l_message          VARCHAR2(4000);
BEGIN

  FEM_ENGINES_PKG.TECH_MESSAGE
   (p_severity => G_LOG_LEVEL_STATEMENT,
    p_module   => C_MODULE,
    p_msg_text => 'Message count is '||to_char(p_msg_count));

  l_msg_data := p_msg_data;

  IF (p_msg_count = 1) THEN
    FND_MESSAGE.Set_Encoded(l_msg_data);
    l_message := FND_MESSAGE.Get;

    FEM_ENGINES_PKG.User_Message(
      p_msg_text => l_message);

    FEM_ENGINES_PKG.TECH_MESSAGE
      (p_severity => G_LOG_LEVEL_STATEMENT,
       p_module   => C_MODULE,
       p_msg_text => 'Message is '||l_message);

  ELSIF (p_msg_count > 1) THEN
    FOR i IN 1..p_msg_count LOOP
      FND_MSG_PUB.Get(
      p_msg_index => i,
      p_encoded => G_FALSE,
      p_data => l_message,
      p_msg_index_out => l_msg_out);

      FEM_ENGINES_PKG.User_Message(
        p_msg_text => l_message);

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'Message is '||l_message);
    END LOOP;
  END IF;

  FND_MSG_PUB.Initialize;

EXCEPTION
  WHEN others THEN
    FEM_ENGINES_PKG.Tech_Message
     (p_severity => G_LOG_LEVEL_UNEXPECTED,
      p_module   => C_MODULE,
      p_app_name => 'FEM',
      p_msg_name => 'FEM_UNEXPECTED_ERROR',
      p_token1   => 'ERR_MSG',
      p_value1   => SQLERRM);
    RAISE;

END Get_Put_Messages;

--
-- Procedure
--     Validate_Obj_Def
-- Purpose
--      Validates the object definition ID
-- History
--     09-07-04    GCHENG        Created
-- Arguments
--    p_api_version      : API version
--    p_object_type      : Object type code
--    p_obj_def_id       : Object definition_ID
--    p_object_id        : Object ID
--    x_table_name       : Source data target table name
--    x_msg_count        : Message count
--    x_msg_data         : Message text (if msg count = 1)
--    x_return_status    : Return status
--                           (look at FND_API for the possible statuses)
-- Notes
--
PROCEDURE  Validate_Obj_Def (
  p_api_version            IN  NUMBER,
  p_object_type            IN  VARCHAR2,
  p_obj_def_id             IN  NUMBER,
  x_object_id              OUT NOCOPY NUMBER,
  x_table_name             OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2
) IS
  C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_source_data_loader_pkg.validate_obj_def';
  C_API_VERSION   CONSTANT NUMBER := 1.0;
  C_API_NAME      CONSTANT VARCHAR2(30)  := 'Validate_Obj_Def';

  l_object_type_code   FEM_OBJECT_TYPES.object_type_code%TYPE;
  e_inv_obj_def        EXCEPTION;
BEGIN
  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;
  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Object type code is '||p_object_type);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Object definition ID is '||p_obj_def_id);
  END IF;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (C_API_VERSION,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- --------------------------------------------------------------------
  -- Validate the Object Definition ID engine parameter by making sure it
  -- exists or is an old approved copy.
  -- Bug 4107295: Check for folder security.
  -- Bug 3995222: Rely on FEM_DATA_LOADER_OBJECTS to determine the relationship
  -- between loader objects and the tables being loaded.
  -- --------------------------------------------------------------------
  BEGIN
    SELECT o.object_id, t.table_name
    INTO x_object_id, x_table_name
    FROM fem_object_definition_b od, fem_object_catalog_b o,
         fem_user_folders f, fem_data_loader_objects d,
         fem_table_class_assignmt_v t
    WHERE od.object_definition_id = p_obj_def_id
    AND od.object_id = o.object_id
    AND o.object_type_code = 'SOURCE_DATA_LOADER'
    AND o.folder_id = f.folder_id
    AND f.user_id = FND_GLOBAL.user_id
    AND d.object_id = o.object_id
    AND d.table_name = t.table_name
    AND table_classification_code = 'SOURCE_DATA_TABLE'
    AND old_approved_copy_flag = 'N';

    IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'Object ID is '||to_char(x_object_id));

      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'Table name is '||x_table_name);
    END IF;
  EXCEPTION
    WHEN no_data_found THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => G_LOG_LEVEL_STATEMENT,
          p_module   => C_MODULE,
          p_msg_text => 'Object def ID '||to_char(p_obj_def_id)
            ||' either cannot be found or is an old approved copy'
            ||' or the associated table is not enabled.');
       RAISE e_inv_obj_def;
  END;

  -- --------------------------------------------------------------------
  -- Check to make sure object type matches what is passed in.
  -- --------------------------------------------------------------------

  BEGIN
    SELECT object_type_code
    INTO l_object_type_code
    FROM fem_object_catalog_b
    WHERE object_id = x_object_id
    AND object_type_code = p_object_type;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => G_LOG_LEVEL_STATEMENT,
          p_module   => C_MODULE,
          p_msg_text => 'Object ID '||to_char(x_object_id)
            ||' cannot be found, or is not of type '||p_object_type);
       RAISE e_inv_obj_def;
  END;

  x_return_status := G_RET_STS_SUCCESS;

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Returning with status of '||x_return_status);
  END IF;
  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

EXCEPTION
  WHEN e_inv_obj_def THEN
    x_return_status := G_RET_STS_ERROR;

    FEM_ENGINES_PKG.put_message(
        p_app_name =>'FEM',
        p_msg_name =>'FEM_SD_LDR_INV_OBJ_DEF',
        p_token1 => 'OBJ_DEF_ID',
        p_value1 => p_obj_def_id);

    FEM_ENGINES_PKG.Tech_Message
        (p_severity => G_LOG_LEVEL_ERROR,
         p_module   => C_MODULE,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_SD_LDR_INV_OBJ_DEF',
         p_token1   => 'OBJ_DEF_ID',
         p_value1   => p_obj_def_id);

    FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data  => x_msg_data);

  WHEN others THEN
    x_return_status := G_RET_STS_UNEXP_ERROR;

END Validate_Obj_Def;

--
-- Procedure
--     Validate_Table
-- Purpose
--      Validates the table
-- History
--     09-07-04    GCHENG        Created
-- Arguments
--    p_api_version      : API version
--    p_object_type      : Object type code
--    p_table_name       : Table name
--    p_table_classification : Table classification
--    x_msg_count        : Message count
--    x_msg_data         : Message text (if msg count = 1)
--    x_return_status    : Return status
--                           (look at FND_API for the possible statuses)
-- Notes
--
PROCEDURE  Validate_Table (
  p_api_version            IN  NUMBER,
  p_object_type            IN  VARCHAR2,
  p_table_name             IN  VARCHAR2,
  p_table_classification   IN  VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2
) IS
  C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_source_data_loader_pkg.validate_table';
  C_API_VERSION   CONSTANT NUMBER := 1.0;
  C_API_NAME      CONSTANT VARCHAR2(30)  := 'Validate_Table';
  l_count                   NUMBER := 0;
BEGIN
  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;
  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Object type code is '||p_object_type);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Table name is '||p_table_name);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Table classification is '||p_table_classification);
  END IF;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (C_API_VERSION,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  SELECT COUNT(*)
  INTO l_count
  FROM fem_table_class_assignmt_v
  WHERE table_name = p_table_name
  AND table_classification_code = p_table_classification;

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Table classification '||p_table_classification||' has '
                 ||to_char(l_count)||' instances of table '||p_table_name);
  END IF;

  IF l_count = 1 THEN
    x_return_status := G_RET_STS_SUCCESS;
  ELSE
    x_return_status := G_RET_STS_ERROR;

    FEM_ENGINES_PKG.put_message(
      p_app_name =>'FEM',
      p_msg_name =>'FEM_SD_LDR_INV_TABLE',
      p_token1 => 'TABLE',
      p_value1 => p_table_name);

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => G_LOG_LEVEL_ERROR,
       p_module   => C_MODULE,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_SD_LDR_INV_TABLE',
       p_token1   => 'TABLE',
       p_value1   => p_table_name);
  END IF;

  FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data  => x_msg_data);

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Returning with status of '||x_return_status);
  END IF;
  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

EXCEPTION
  WHEN others THEN
    x_return_status := G_RET_STS_UNEXP_ERROR;

END Validate_Table;

--
-- Procedure
--     Validate_Exec_Mode
-- Purpose
--      Validates the execution mode.
-- History
--     09-07-04    GCHENG        Created
--     02-26-06    HKANIVEN      Modified the code to handle
--                               'R'(Reprocessing mode) as a valid mode
-- Arguments
--    p_api_version      : API version
--    p_object_type      : Object type code
--    p_exec_mode        : Execution mode
--    x_msg_count        : Message count
--    x_msg_data         : Message text (if msg count = 1)
--    x_return_status    : Return status
--                           (look at FND_API for the possible statuses)
-- Notes
--
PROCEDURE  Validate_Exec_Mode (
  p_api_version            IN  NUMBER,
  p_object_type             IN  VARCHAR2,
  p_exec_mode               IN  VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_return_status           OUT NOCOPY VARCHAR2
) IS
  C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_source_data_loader_pkg.validate_exec_mode';
  C_API_VERSION   CONSTANT NUMBER := 1.0;
  C_API_NAME      CONSTANT VARCHAR2(30)  := 'Validate_Exec_Mode';
  l_count         NUMBER := 0;

  e_invalid_object_type    EXCEPTION;
BEGIN

  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;
  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Object type code is '||p_object_type);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Exec Mode is '||p_exec_mode);
  END IF;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (C_API_VERSION,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Start of Replacement mode enhancement

  IF p_object_type = 'SOURCE_DATA_LOADER' THEN
    SELECT COUNT(*)
    INTO l_count
    FROM fnd_lookup_values
    WHERE lookup_type = 'FEM_PL_EXEC_MODE_DSC'
    AND lookup_code = p_exec_mode
    AND language = USERENV('LANG')
    AND view_application_id = 274
    AND security_group_id =
       fnd_global.lookup_security_group(lookup_type, view_application_id)
    AND enabled_flag = 'Y'
    AND lookup_code IN ('R','E','S');

  -- End of Replacement mode enhancement
  ELSE
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_UNEXPECTED,
      p_module   => C_MODULE,
      p_msg_text => 'Object type code '||p_object_type||' is not valid!');
    RAISE e_invalid_object_type;
  END IF;

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Execution mode lookup type FEM_SRCDATA_LOADER_EXEC_MODE has '
                 ||to_char(l_count)||' instances of lookup code '||p_exec_mode);
  END IF;

  IF l_count = 1 THEN
    x_return_status := G_RET_STS_SUCCESS;
  ELSE
    x_return_status := G_RET_STS_ERROR;

    FEM_ENGINES_PKG.put_message(
      p_app_name =>'FEM',
      p_msg_name =>'FEM_SD_LDR_INV_EXEC_MODE',
      p_token1 => 'EXEC_MODE',
      p_value1 => p_exec_mode);

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => G_LOG_LEVEL_ERROR,
       p_module   => C_MODULE,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_SD_LDR_INV_EXEC_MODE',
       p_token1   => 'EXEC_MODE',
       p_value1   => p_exec_mode);
  END IF;

  FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data  => x_msg_data);

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Returning with status of '||x_return_status);
  END IF;
  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

EXCEPTION
  WHEN others THEN
    x_return_status := G_RET_STS_UNEXP_ERROR;

END Validate_Exec_Mode;

--
-- Procedure
--     Validate_Ledger
-- Purpose
--      Validates the ledger ID
-- History
--     09-07-04    GCHENG        Created
-- Arguments
--    p_api_version      : API version
--    p_object_type      : Object type code
--    p_ledger_id        : Ledger ID
--    x_ledger_dc        : Ledger display code
--    x_msg_count        : Message count
--    x_msg_data         : Message text (if msg count = 1)
--    x_return_status    : Return status
--                           (look at FND_API for the possible statuses)
-- Notes
--
PROCEDURE  Validate_Ledger (
  p_api_version            IN  NUMBER,
  p_object_type            IN  VARCHAR2,
  p_ledger_id              IN  NUMBER,
  x_ledger_dc              OUT NOCOPY VARCHAR2,
  x_ledger_calendar_id     OUT NOCOPY NUMBER,
  x_ledger_per_hier_obj_def_id OUT NOCOPY NUMBER,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2
) IS
  C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_source_data_loader_pkg.validate_ledger';
  C_API_VERSION   CONSTANT NUMBER := 1.0;
  C_API_NAME      CONSTANT VARCHAR2(30)  := 'Validate_Ledger';
  l_ledger_dim_id          NUMBER;
  l_dim_attr_id            NUMBER;
  l_dim_attr_ver_id        NUMBER;
  l_ledger_per_hier_obj_id NUMBER;
  l_return_code            NUMBER;  -- 0 if success, 2 if error

  e_inv_ledger             EXCEPTION;
BEGIN

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (C_API_VERSION,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;
  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Object type code is '||p_object_type);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Ledger ID is '||p_ledger_id);
  END IF;

  x_return_status := G_RET_STS_SUCCESS;

  BEGIN
    SELECT ledger_display_code
     INTO   x_ledger_dc
     FROM   fem_ledgers_b
     WHERE  ledger_id = p_ledger_id
    AND enabled_flag  = 'Y'
    AND personal_flag = 'N';

    IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'Ledger display code is '||x_ledger_dc);
    END IF;
  EXCEPTION
     WHEN no_data_found THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => G_LOG_LEVEL_STATEMENT,
          p_module   => C_MODULE,
          p_msg_text => 'Ledger ID '||to_char(p_ledger_id)
            ||' either cannot be found or is not enabled or is personal.');
       RAISE e_inv_ledger;
  END;

   --
  -- Get the Hierarchy Object Definition ID of the Time hierarchy assigned
  -- to the given ledger. It is stored as a row-based ledger attribute.
  --

  -- Get the Dimension ID for Ledger.
  -- If this returns no data, this is an unexpected error
  -- and hence is not caught until the end of the procedure.
  SELECT dimension_id
  INTO l_ledger_dim_id
  FROM fem_dimensions_b
  WHERE dimension_varchar_label = 'LEDGER';

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'Dimension ID of Ledger dimenions is '
          ||to_char(l_ledger_dim_id));
  END IF;

  FEM_DIMENSION_UTIL_PKG.get_dim_attr_id_ver_id
           (p_dim_id      => l_ledger_dim_id,
            p_attr_label  => 'CAL_PERIOD_HIER_OBJ_DEF_ID',
            x_attr_id     => l_dim_attr_id,
            x_ver_id      => l_dim_attr_ver_id,
            x_err_code    => l_return_code);

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'FEM_DIMENSION_UTIL_PKG.get_dim_attr_id_ver_id'
          ||'(CAL_PERIOD_HIER_OBJ_DEF_ID) returned with error code of '
          ||to_char(l_return_code));
  END IF;

  IF l_return_code <> 0 THEN  -- if not success
    RAISE e_inv_ledger;
  END IF;

  BEGIN
    SELECT dim_attribute_numeric_member
    INTO x_ledger_per_hier_obj_def_id
    FROM fem_ledgers_attr
    WHERE attribute_id  = l_dim_attr_id
    AND version_id    = l_dim_attr_ver_id
    AND ledger_id     = p_ledger_id;

    IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
      FEM_ENGINES_PKG.Tech_Message
       (p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'The Ledger Calendar Period Hierarchy object definition ID is '
           ||to_char(x_ledger_per_hier_obj_def_id));
    END IF;
  EXCEPTION
    WHEN no_data_found THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'Ledger is missing a Calendar Period Hierarchy attribute.');

      RAISE e_inv_ledger;
  END;

  BEGIN
    SELECT object_id
    INTO l_ledger_per_hier_obj_id
    FROM fem_object_definition_b
    WHERE object_definition_id = x_ledger_per_hier_obj_def_id;

    IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
      FEM_ENGINES_PKG.Tech_Message
       (p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'The Ledger Calendar Period Hierarchy object ID is '
           ||to_char(l_ledger_per_hier_obj_id));
    END IF;
  EXCEPTION
    WHEN no_data_found THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'The Legder Calendar Period Hierarchy object definition '
          ||'does not have an associated object ID.');

      RAISE e_inv_ledger;
  END;

  -- Look up the Calendar ID for that hierarchy.
  BEGIN
    SELECT calendar_id
    INTO x_ledger_calendar_id
    FROM fem_hierarchies
    WHERE hierarchy_obj_id = l_ledger_per_hier_obj_id;

    IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
      FEM_ENGINES_PKG.Tech_Message
       (p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'The Calendar ID associated with the Ledger is '
           ||to_char(x_ledger_calendar_id));
    END IF;
  EXCEPTION
    WHEN no_data_found THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'The Legder Calendar Period Hierarchy object '
          ||'is not a valid Hierarchy.');

      RAISE e_inv_ledger;
  END;

  FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data  => x_msg_data);

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Returning with status of '||x_return_status);
  END IF;
  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

EXCEPTION
  WHEN e_inv_ledger THEN
    x_return_status := G_RET_STS_ERROR;

    FEM_ENGINES_PKG.put_message(
        p_app_name =>'FEM',
        p_msg_name =>'FEM_SD_LDR_INV_LEDGER',
        p_token1 => 'LEDGER',
        p_value1 => p_ledger_id);

    FEM_ENGINES_PKG.Tech_Message
        (p_severity => G_LOG_LEVEL_ERROR,
         p_module   => C_MODULE,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_SD_LDR_INV_LEDGER',
         p_token1   => 'LEDGER',
         p_value1   => p_ledger_id);

    FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data  => x_msg_data);

  WHEN others THEN
    x_return_status := G_RET_STS_UNEXP_ERROR;

END Validate_Ledger;

--
-- Procedure
--     Validate_Cal_Period
-- Purpose
--      Validates the calendar period ID
-- History
--     09-07-04    GCHENG        Created
-- Arguments
--    p_api_version      : API version
--    p_object_type      : Object type code
--    p_cal_period_id    : Calendar period ID
--    p_ledger_id        : Object ID that identifies the rule being executed.
--    p_ledger_calendar_id : Calendar ID associated to the ledger
--    p_ledger_per_hier_obj_def_id : Hierarchy object def ID
--    x_calp_dim_grp_dc  : Cal period dimension group display code
--    x_cal_per_end_date : Cal period end period date
--    x_cal_per_number   : Cal period number
--    x_msg_count        : Message count
--    x_msg_data         : Message text (if msg count = 1)
--    x_return_status    : Return status
--                           (look at FND_API for the possible statuses)
-- Notes
--
PROCEDURE  Validate_Cal_Period (
  p_api_version            IN  NUMBER,
  p_object_type            IN  VARCHAR2,
  p_cal_period_id          IN  NUMBER,
  p_ledger_id              IN  NUMBER,
  p_ledger_calendar_id     IN  NUMBER,
  p_ledger_per_hier_obj_def_id IN NUMBER,
  x_calp_dim_grp_dc        OUT NOCOPY VARCHAR2,
  x_cal_per_end_date       OUT NOCOPY DATE,
  x_cal_per_number         OUT NOCOPY NUMBER,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_return_status           OUT NOCOPY VARCHAR2
) IS
  C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_source_data_loader_pkg.validate_cal_period';
  C_API_VERSION   CONSTANT NUMBER := 1.0;
  C_API_NAME      CONSTANT VARCHAR2(30)  := 'Validate_Cal_Period';
  l_cal_per_calendar_id    NUMBER;
  l_cal_per_dim_grp_id     NUMBER;
  l_dummy                  VARCHAR2(1);
  l_cal_per_dim_id         NUMBER;
  l_dim_attr_id            NUMBER;
  l_dim_attr_ver_id        NUMBER;
  l_return_code            NUMBER;  -- 0 if success, 2 if error

  e_inv_cal_period         EXCEPTION;
  e_mismatch_calendar      EXCEPTION;
  e_per_not_in_ledger      EXCEPTION;
BEGIN

  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;
  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Object type code is '||p_object_type);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Calendar Period ID is '||p_cal_period_id);
  END IF;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (C_API_VERSION,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Get the calendar of the cal period
  BEGIN
    SELECT calendar_id, dimension_group_id
     INTO   l_cal_per_calendar_id,  l_cal_per_dim_grp_id
     FROM   fem_cal_periods_b
     WHERE  cal_period_id = p_cal_period_id
    AND enabled_flag  = 'Y'
    AND personal_flag = 'N';

    IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
      FEM_ENGINES_PKG.Tech_Message
       (p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'The Calendar Period Calendar ID is '
            ||to_char(l_cal_per_calendar_id)
           ||'and the Calendar Period Dimension Group ID is '
           ||to_char(l_cal_per_dim_grp_id));
    END IF;
  EXCEPTION
     WHEN no_data_found THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'Calendar Period ID '||to_char(p_cal_period_id)
            ||' either cannot be found or is not enabled or is personal.');
      RAISE e_inv_cal_period;
  END;

  -- Make sure the calendar period and ledger share the same calendar
  IF l_cal_per_calendar_id <> p_ledger_calendar_id THEN
    RAISE e_mismatch_calendar;
  END IF;

  BEGIN
    SELECT dimension_group_display_code
    INTO x_calp_dim_grp_dc
    FROM fem_dimension_grps_b
    WHERE dimension_group_id = l_cal_per_dim_grp_id;

    IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
      FEM_ENGINES_PKG.Tech_Message
       (p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'The Calendar Period Dimension Group Display Code is '
          ||x_calp_dim_grp_dc);
    END IF;

  EXCEPTION
    WHEN no_data_found THEN
      FEM_ENGINES_PKG.Tech_Message
       (p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'The Calendar Period Dimension Group cannot be found.');

      RAISE e_inv_cal_period;
  END;

  --
  -- Get the Dimension ID for Ledger.
  -- If this returns no data, this is an unexpected error
  -- and hence is not caught until the end of the procedure.
  --

  SELECT dimension_id
  INTO l_cal_per_dim_id
  FROM fem_dimensions_b
  WHERE dimension_varchar_label = 'CAL_PERIOD';

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'Dimension ID of Calendar Period dimenions is '
          ||to_char(l_cal_per_dim_id));
  END IF;

  -- Retrieve the CAL_PERIOD_END_DATE attribute of the Cal Period ID
  -- and set it into a package variable.
  FEM_DIMENSION_UTIL_PKG.get_dim_attr_id_ver_id
           (p_dim_id      => l_cal_per_dim_id,
            p_attr_label  => 'CAL_PERIOD_END_DATE',
            x_attr_id     => l_dim_attr_id,
            x_ver_id      => l_dim_attr_ver_id,
            x_err_code    => l_return_code);

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'FEM_DIMENSION_UTIL_PKG.get_dim_attr_id_ver_id'
          ||'(CAL_PERIOD_END_DATE) returned with error code of '
          ||to_char(l_return_code));
  END IF;

  IF l_return_code <> 0 THEN  -- did not succeed
    RAISE e_inv_cal_period;
  END IF;

  BEGIN
    SELECT date_assign_value
    INTO x_cal_per_end_date
    FROM fem_cal_periods_attr
    WHERE attribute_id  = l_dim_attr_id
    AND version_id    = l_dim_attr_ver_id
    AND cal_period_id = p_cal_period_id;

    IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
      FEM_ENGINES_PKG.Tech_Message
       (p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'The Calendar Period End Date is '
           ||FND_DATE.date_to_displayDT(x_cal_per_end_date));
    END IF;
  EXCEPTION
    WHEN no_data_found THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'Calendar Period is missing Calendar Period End Date attribute.');

    RAISE e_inv_cal_period;
  END;

  -- Get the Calendar Period Number from the GL_PERIOD_NUM attribute of the
  -- Cal Period ID and set it into a package variable.
  FEM_DIMENSION_UTIL_PKG.get_dim_attr_id_ver_id
           (p_dim_id      => l_cal_per_dim_id,
            p_attr_label  => 'GL_PERIOD_NUM',
            x_attr_id     => l_dim_attr_id,
            x_ver_id      => l_dim_attr_ver_id,
            x_err_code    => l_return_code);

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'FEM_DIMENSION_UTIL_PKG.get_dim_attr_id_ver_id'
          ||'(CGL_PERIOD_NUM) returned with error code of '
          ||to_char(l_return_code));
  END IF;

  IF l_return_code <> 0 THEN  -- did not succeed
     RAISE e_inv_cal_period;
  END IF;

  BEGIN
    SELECT number_assign_value
    INTO x_cal_per_number
    FROM fem_cal_periods_attr
    WHERE attribute_id  = l_dim_attr_id
    AND version_id    = l_dim_attr_ver_id
    AND cal_period_id = p_cal_period_id;

    IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
      FEM_ENGINES_PKG.Tech_Message
       (p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'The Calendar Period Number is '
           ||to_char(x_cal_per_number));
    END IF;
  EXCEPTION
    WHEN no_data_found THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'Calendar Period is missing Calendar Period Number attribute.');

    RAISE e_inv_cal_period;
  END;

  x_return_status := G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data  => x_msg_data);

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Returning with status of '||x_return_status);
  END IF;
  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

EXCEPTION
  WHEN e_inv_cal_period THEN
    x_return_status := G_RET_STS_ERROR;

    FEM_ENGINES_PKG.put_message(
        p_app_name =>'FEM',
        p_msg_name =>'FEM_SD_LDR_INV_CAL_PER',
        p_token1 => 'CAL_PER',
        p_value1 => p_cal_period_id);

    FEM_ENGINES_PKG.Tech_Message
        (p_severity => G_LOG_LEVEL_ERROR,
         p_module   => C_MODULE,
         p_app_name => 'FEM',
         p_msg_name =>'FEM_SD_LDR_INV_CAL_PER',
         p_token1 => 'CAL_PER',
         p_value1 => p_cal_period_id);

    FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data  => x_msg_data);

  WHEN e_mismatch_calendar THEN
    x_return_status := G_RET_STS_ERROR;

    FEM_ENGINES_PKG.put_message(
        p_app_name =>'FEM',
        p_msg_name =>'FEM_SD_LDR_MISMATCH_CALENDAR',
        p_token1 => 'LEDGER',
        p_value1 => p_ledger_id,
        p_token2 => 'CAL_PER',
        p_value2 => p_cal_period_id);

    FEM_ENGINES_PKG.Tech_Message
        (p_severity => G_LOG_LEVEL_ERROR,
         p_module   => C_MODULE,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_SD_LDR_MISMATCH_CALENDAR',
         p_token1   => 'LEDGER',
         p_value1   => p_ledger_id,
         p_token2   => 'CAL_PER',
         p_value2   => p_cal_period_id);

    FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data  => x_msg_data);

  WHEN others THEN
    x_return_status := G_RET_STS_UNEXP_ERROR;

END Validate_Cal_Period;

--
-- Procedure
--     Validate_Dataset
-- Purpose
--      Validates the dataset code
-- History
--     09-07-04    GCHENG        Created
-- Arguments
--    p_api_version      : API version
--    p_object_type      : Object type code
--    p_datset_code      : Dataset code
--    x_dateset_dc       : Dataset display code
--    x_msg_count        : Message count
--    x_msg_data         : Message text (if msg count = 1)
--    x_return_status    : Return status
--                           (look at FND_API for the possible statuses)
-- Notes
--
PROCEDURE  Validate_Dataset (
  p_api_version            IN  NUMBER,
  p_object_type            IN  VARCHAR2,
  p_dataset_code           IN  NUMBER,
  x_dataset_dc             OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2
) IS
  C_MODULE   CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_source_data_loader_pkg.validate_dataset';
  C_API_VERSION   CONSTANT NUMBER := 1.0;
  C_API_NAME      CONSTANT VARCHAR2(30)  := 'Validate_Dataset';
  l_dataset_dim_id         NUMBER;
  l_dim_attr_id            NUMBER;
  l_dim_attr_ver_id        NUMBER;
  l_return_code            NUMBER;  -- 0 if success, 2 if error
BEGIN

  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;
  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Object type code is '||p_object_type);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Dataset code is '||p_dataset_code);
  END IF;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (C_API_VERSION,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := G_RET_STS_SUCCESS;

  --
  -- Check to make sure dataset code that is enabled and not personal exists
  --

  BEGIN
    SELECT dataset_display_code
     INTO   x_dataset_dc
     FROM   fem_datasets_b
     WHERE  dataset_code = p_dataset_code
    AND enabled_flag  = 'Y'
    AND personal_flag = 'N';
  EXCEPTION
     WHEN no_data_found THEN
       x_return_status := G_RET_STS_ERROR;

      FEM_ENGINES_PKG.put_message(
        p_app_name =>'FEM',
        p_msg_name =>'FEM_SD_LDR_INV_DATASET',
        p_token1 => 'DATASET',
        p_value1 => p_dataset_code);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => G_LOG_LEVEL_ERROR,
         p_module   => C_MODULE,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_SD_LDR_INV_DATASET',
         p_token1   => 'DATASET',
         p_value1   => p_dataset_code);
  END;

  --
  -- Make sure Dataset has a Balance Type attribute value.
  -- Unless users go "under the hood" this should never fail.
  --
  IF x_return_status = G_RET_STS_SUCCESS THEN
    -- If this returns no data, this is an unexpected error
    -- and hence is not caught until the end of the procedure.
    SELECT dimension_id
    INTO l_dataset_dim_id
    FROM fem_dimensions_b
    WHERE dimension_varchar_label = 'DATASET';

    IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'Dimension ID of Dataset dimenions is '
          ||to_char(l_dataset_dim_id));
    END IF;

    FEM_DIMENSION_UTIL_PKG.get_dim_attr_id_ver_id
      (p_dim_id      => l_dataset_dim_id,
       p_attr_label  => 'DATASET_BALANCE_TYPE_CODE',
        x_attr_id     => l_dim_attr_id,
        x_ver_id      => l_dim_attr_ver_id,
        x_err_code    => l_return_code);

    IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => G_LOG_LEVEL_STATEMENT,
        p_module   => C_MODULE,
        p_msg_text => 'FEM_DIMENSION_UTIL_PKG.get_dim_attr_id_ver_id'
          ||'(DATASET_BALANCE_TYPE_CODE) returned with error code of '
          ||to_char(l_return_code));
    END IF;

    IF l_return_code = 0 THEN
      BEGIN
        SELECT 0
        INTO l_return_code
        FROM fem_datasets_attr
        WHERE attribute_id  = l_dim_attr_id
        AND version_id    = l_dim_attr_ver_id
        AND dataset_code  = p_dataset_code;
      EXCEPTION
        WHEN no_data_found THEN
          l_return_code := 2;  -- error

          FEM_ENGINES_PKG.TECH_MESSAGE(
              p_severity => G_LOG_LEVEL_STATEMENT,
              p_module   => C_MODULE,
               p_msg_text => 'Dataset is missing a balance type attribute.');
      END;
    END IF;

    IF l_return_code <> 0 THEN
      x_return_status := G_RET_STS_ERROR;

      FEM_ENGINES_PKG.put_message(
        p_app_name =>'FEM',
        p_msg_name =>'FEM_SD_LDR_INV_BAL_TYPE',
        p_token1 => 'DATASET',
        p_value1 => p_dataset_code);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => G_LOG_LEVEL_ERROR,
         p_module   => C_MODULE,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_SD_LDR_INV_BAL_TYPE',
         p_token1   => 'DATASET',
         p_value1   => p_dataset_code);
    END IF;
  END IF;


  FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data  => x_msg_data);

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Returning with status of '||x_return_status);
  END IF;
  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

EXCEPTION
  WHEN others THEN
    x_return_status := G_RET_STS_UNEXP_ERROR;

END Validate_Dataset;

--
-- Procedure
--     Validate_Source_System
-- Purpose
--      Validates the source system code
-- History
--     09-07-04    GCHENG        Created
-- Arguments
--    p_api_version      : API version
--    p_object_type      : Object type code
--    p_source_system_code : Source system code
--    x_source_system_dc : Source system display code
--    x_msg_count        : Message count
--    x_msg_data         : Message text (if msg count = 1)
--    x_return_status    : Return status
--                           (look at FND_API for the possible statuses)
-- Notes
--
PROCEDURE  Validate_Source_System (
  p_api_version            IN  NUMBER,
  p_object_type            IN  VARCHAR2,
  p_source_system_code     IN  NUMBER,
  x_source_system_dc       OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2
) IS
  C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_source_data_loader_pkg.validate_source_system';
  C_API_VERSION   CONSTANT NUMBER := 1.0;
  C_API_NAME      CONSTANT VARCHAR2(30)  := 'Validate_Source_System';
BEGIN

  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;
  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Object type code is '||p_object_type);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Parameter: Source system code is '||p_source_system_code);
  END IF;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (C_API_VERSION,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := G_RET_STS_SUCCESS;

  BEGIN
    SELECT source_system_display_code
     INTO   x_source_system_dc
     FROM   fem_source_systems_b
     WHERE  source_system_code = p_source_system_code
    AND enabled_flag  = 'Y'
    AND personal_flag = 'N';
  EXCEPTION
     WHEN no_data_found THEN
       x_return_status := G_RET_STS_ERROR;

      FEM_ENGINES_PKG.put_message(
        p_app_name =>'FEM',
        p_msg_name =>'FEM_SD_LDR_INV_SOURCE',
        p_token1 => 'SOURCE',
        p_value1 => p_source_system_code);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => G_LOG_LEVEL_ERROR,
         p_module   => C_MODULE,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_SD_LDR_INV_SOURCE',
         p_token1   => 'SOURCE',
         p_value1   => p_source_system_code);
  END;

  FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data  => x_msg_data);

  IF G_LOG_LEVEL_STATEMENT >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_STATEMENT,
      p_module   => C_MODULE,
      p_msg_text => 'Returning with status of '||x_return_status);
  END IF;
  IF G_LOG_LEVEL_PROCEDURE >= g_log_current_level THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => G_LOG_LEVEL_PROCEDURE,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

EXCEPTION
  WHEN others THEN
    x_return_status := G_RET_STS_UNEXP_ERROR;

END Validate_Source_System;

END FEM_SOURCE_DATA_LOADER_PKG;

/
