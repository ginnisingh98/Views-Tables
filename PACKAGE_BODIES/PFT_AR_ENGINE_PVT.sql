--------------------------------------------------------
--  DDL for Package Body PFT_AR_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PFT_AR_ENGINE_PVT" AS
/* $Header: PFTVAREB.pls 120.12 2006/09/20 06:28:00 navekuma noship $ */


-------------------------------
-- Declare package constants --
-------------------------------

  -- Constants for p_exec_status_code
  G_EXEC_STATUS_RUNNING        constant varchar2(30) := 'RUNNING';
  G_EXEC_STATUS_SUCCESS        constant varchar2(30) := 'SUCCESS';
  G_EXEC_STATUS_ERROR_UNDO     constant varchar2(30) := 'ERROR_UNDO';
  G_EXEC_STATUS_ERROR_RERUN    constant varchar2(30) := 'ERROR_RERUN';

  -- Default Fetch Limit if none is specified in Profile Options
  G_DEFAULT_FETCH_LIMIT        constant number := 99999;

  -- Seeded Financial Element IDs
  G_FIN_ELEM_ID_STATISTIC      constant number := 10000;
  G_FIN_ELEM_ID_ACTIVITY_RATE  constant number := 5005;

  -- Log Level Constants
  G_LOG_LEVEL_1                constant number := fnd_log.level_statement;
  G_LOG_LEVEL_2                constant number := fnd_log.level_procedure;
  G_LOG_LEVEL_3                constant number := fnd_log.level_event;
  G_LOG_LEVEL_4                constant number := fnd_log.level_exception;
  G_LOG_LEVEL_5                constant number := fnd_log.level_error;
  G_LOG_LEVEL_6                constant number := fnd_log.level_unexpected;

  -- MP Constants
  G_MP_ENABLED                 constant boolean := false;
  G_COMPLETE_NORMAL            constant varchar2(30) := 'COMPLETE:NORMAL';


------------------------------
-- Declare package messages --
------------------------------
  G_EXEC_RERUN                       constant varchar2(30) := 'FEM_EXEC_RERUN';
  G_EXEC_SUCCESS                     constant varchar2(30) := 'FEM_EXEC_SUCCESS';
  G_UNEXPECTED_ERROR                 constant varchar2(30) := 'FEM_UNEXPECTED_ERROR';

  -- Common FEM Engine Messages
  G_ENG_NO_OUTPUT_DS_ERR             constant varchar2(30) := 'FEM_ENG_NO_OUTPUT_DS_ERR';
  G_ENG_NO_DS_GRP_OBJ_ERR            constant varchar2(30) := 'FEM_ENG_NO_OBJ_ERR';
  G_ENG_NO_SUBMIT_OBJ_ERR            constant varchar2(30) := 'FEM_ENG_NO_SUBMIT_OBJ_ERR';
  G_ENG_NO_ACT_RATE_OBJ_ERR          constant varchar2(30) := 'FEM_ENG_NO_OBJ_ERR';
  G_ENG_RS_NO_OBJ_ERR                constant varchar2(30) := 'FEM_ENG_NO_OBJ_ERR';
  G_ENG_RS_NO_OBJ_DEF_ERR            constant varchar2(30) := 'FEM_ENG_NO_OBJ_DEF_DTL_ERR';
  G_ENG_RS_BAD_LCL_VS_COMBO_ERR      constant varchar2(30) := 'FEM_ENG_BAD_LCL_VS_COMBO_ERR';
  G_ENG_NO_ACT_RATE_OBJ_DTL_ERR      constant varchar2(30) := 'FEM_ENG_NO_OBJ_DEF_DTL_ERR';
  G_ENG_NO_OBJ_DTL_ERR               constant varchar2(30) := 'FEM_ENG_NO_OBJ_DTL_ERR';
  G_ENG_BAD_HIER_DIM_ERR             constant varchar2(30) := 'FEM_ENG_BAD_HIER_DIM_ERR';
  G_ENG_BAD_DS_WCLAUSE_ERR           constant varchar2(30) := 'FEM_ENG_BAD_DS_WCLAUSE_ERR';
  G_ENG_NO_EXCH_RATE_FOUND_ERR       constant varchar2(30) := 'FEM_ENG_NO_EXCH_RATE_ERR';
  G_ENG_BAD_CURRENCY_ERR             constant varchar2(30) := 'FEM_ENG_BAD_CURRENCY_ERR';
  G_ENG_NO_DIM_ATTR_VER_ERR          constant varchar2(30) := 'FEM_ENG_NO_DIM_ATTR_VER_ERR';
  G_ENG_NO_DIM_ATTR_VAL_ERR          constant varchar2(30) := 'FEM_ENG_NO_DIM_ATTR_VAL_ERR';
  G_ENG_NO_DIM_DTL_ERR               constant varchar2(30) := 'FEM_ENG_NO_DIM_DTL_ERR';
  G_ENG_NO_OBJ_DEF_ERR               constant varchar2(30) := 'FEM_ENG_NO_OBJ_DEF_ERR';
  G_ENG_COND_WHERE_CLAUSE_ERR        constant varchar2(30) := 'FEM_ENG_COND_WHERE_CLAUSE_ERR';
  G_ENG_REQ_POST_PROC_ERR            constant varchar2(30) := 'FEM_ENG_REQ_POST_PROC_ERR';
  G_ENG_RULE_POST_PROC_ERR           constant varchar2(30) := 'FEM_ENG_RULE_POST_PROC_ERR';
  G_ENG_NO_DIM_MEMBER_ERR            constant varchar2(30) := 'FEM_ENG_NO_DIM_MEMBER_ERR';
  G_ENG_CREATE_SEQUENCE_ERR          constant varchar2(30) := 'FEM_ENG_CREATE_SEQUENCE_ERR';
  G_ENG_DROP_SEQUENCE_WRN            constant varchar2(30) := 'FEM_ENG_DROP_SEQUENCE_WRN';
  G_ENG_BAD_RS_OBJ_TYPE_ERR          constant varchar2(30) := 'FEM_ENG_BAD_RS_OBJ_TYPE_ERR';
  G_ENG_NO_CURR_CONV_TYPE_ERR        constant varchar2(30) := 'FEM_ENG_NO_PROF_OPTION_VAL_ERR';
  G_ENG_BAD_CONC_REQ_PARAM_ERR       constant varchar2(30) := 'FEM_ENG_BAD_CONC_REQ_PARAM_ERR';

	G_ENG_RS_RULE_PROCESSING_TXT       constant varchar2(30) := 'FEM_ENG_RS_RULE_PROCESSING_TXT';

  -- PFT Engine Messages
  G_AR_INSERT_ACT_DRIV_ERR           constant varchar2(30) := 'PFT_AR_INSERT_ACT_DRIV_ERR';
  G_AR_NO_DRIVER_ERR                 constant varchar2(30) := 'PFT_AR_NO_DRIVER_ERR';
  G_AR_ALL_INV_DRIV_ERR              constant varchar2(30) := 'PFT_AR_ALL_INV_DRIV_ERR';
  G_AR_NO_DRV_TBL_CLASSF_ERR         constant varchar2(30) := 'PFT_AR_NO_DRV_TBL_CLASSF_ERR';
  G_AR_ZERO_DRV_VAL_ERR              constant varchar2(30) := 'PFT_AR_ZERO_DRV_VAL_ERR';
  G_AR_UNEXP_DRV_VAL_ERR             constant varchar2(30) := 'PFT_AR_UNEXP_DRV_VAL_ERR';

-------------------------------
-- Declare package variables --
-------------------------------
  -- Exception variables
  g_prg_msg                       varchar2(2000);
  g_callstack                     varchar2(2000);

  -- Bulk Fetch Limit
  g_fetch_limit                   number;

  -- Track Event Chains
  g_track_event_chains            boolean;

  -- Currency Conversion Type
  g_currency_conv_type            varchar2(30);

--------------------------------
-- Declare package exceptions --
--------------------------------
  -- General Activity Rate Request Exception
  g_act_rate_request_error        exception;

------------------------------
  -- Global PL/SQL types
------------------------------

  type g_request_id_table is table of PFT_AR_DRIVERS_T.CREATED_BY_REQUEST_ID%TYPE
  index by BINARY_INTEGER;

  type g_object_id_table is table of PFT_AR_DRIVERS_T.CREATED_BY_OBJECT_ID%TYPE
  index by BINARY_INTEGER;

  type g_drv_table_name_table is table of PFT_AR_DRIVERS_T.SOURCE_TABLE_NAME%TYPE
  index by BINARY_INTEGER;

  type g_column_name_table is table of PFT_AR_DRIVERS_T.COLUMN_NAME%TYPE
  index by BINARY_INTEGER;

  type g_statistic_basis_id_table is table of PFT_AR_DRIVERS_T.STATISTIC_BASIS_ID%TYPE
  index by BINARY_INTEGER;

  type g_condition_obj_id_table is table of PFT_AR_DRIVERS_T.CONDITION_OBJ_ID%TYPE
  index by BINARY_INTEGER;

  type g_valid_flag_table is table of PFT_AR_DRIVERS_T.VALID_FLAG%TYPE
  index by BINARY_INTEGER;

  type g_driver_value_table is table of PFT_AR_DRIVERS_T.DRIVER_VALUE%TYPE
  index by BINARY_INTEGER;

  type g_last_update_date_table is table of PFT_AR_DRIVERS_T.LAST_UPDATE_DATE%TYPE
  index by BINARY_INTEGER;

  type g_invalid_reason_table is table of PFT_AR_DRIVERS_T.INVALID_REASON%TYPE
  index by BINARY_INTEGER;

-----------------------------------------------
-- Declare private procedures and functions --
-----------------------------------------------
PROCEDURE Request_Prep (
  p_obj_id                        in number
  ,p_effective_date_varchar       in varchar2
  ,p_ledger_id                    in number
  ,p_output_cal_period_id         in number
  ,p_dataset_grp_obj_def_id       in number
  ,p_continue_process_on_err_flg  in varchar2
  ,p_source_system_code           in number
  ,x_request_rec                  out nocopy request_record
  ,x_input_ds_b_where_clause      out nocopy long
);

PROCEDURE Get_Object_Definition (
  p_object_type_code              in varchar2
  ,p_object_id                    in number
  ,p_effective_date               in date
  ,x_obj_def_id                   out nocopy number
);

PROCEDURE Get_Dimension_Record (
  p_dimension_varchar_label       in varchar2
  ,x_dimension_rec                out nocopy dimension_record
);

PROCEDURE Get_Dim_Attribute_Value (
  p_dimension_varchar_label       in varchar2
  ,p_attribute_varchar_label      in varchar2
  ,p_member_id                    in number
  ,x_dim_attribute_varchar_member out nocopy varchar
  ,x_date_assign_value            out nocopy date
);

PROCEDURE Register_Request (
  p_request_rec                   in request_record
);

PROCEDURE Act_Rate_Rule (
  p_request_rec                   in request_record
  ,p_act_rate_obj_id              in number
  ,p_act_rate_obj_def_id          in number
  ,p_act_rate_sequence            in number
  ,p_input_ds_b_where_clause      in long
  ,x_return_status               out nocopy varchar2
);

PROCEDURE Rule_Prep (
  p_request_rec                   in request_record
  ,p_act_rate_obj_id              in number
  ,p_act_rate_obj_def_id          in number
  ,p_act_rate_sequence            in number
  ,x_rule_rec                     out nocopy rule_record
);

PROCEDURE Register_Rule (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
);

PROCEDURE Register_Object_Definition (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
  ,p_obj_def_id                   in number
);

PROCEDURE Register_Table (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
  ,p_table_name                   in varchar2
  ,p_statement_type               in varchar2
);

PROCEDURE Register_Obj_Exec_Step (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
  ,p_exec_step                    in varchar2
  ,p_exec_status_code             in varchar2
);

PROCEDURE Update_Obj_Exec_Step_Status (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
  ,p_exec_step                    in varchar2
  ,p_exec_status_code             in varchar2
);

PROCEDURE Create_Temp_Objects (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
);

PROCEDURE Drop_Temp_Objects (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
);

PROCEDURE Process_Drivers(
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
  ,p_insert_count                 out nocopy number
);

PROCEDURE Calc_Act_Rate(
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
  ,p_input_ds_b_where_clause      in long
);

PROCEDURE Register_Driver_Chains (
  p_request_id                    in number
  ,p_ledger_id                    in number
  ,p_user_id                      in number
  ,p_login_id                     in number
  ,p_act_rate_obj_id              in number
  ,p_drv_table_name               in varchar2
  ,p_statistic_basis_id           in number
  ,p_drv_cond_where_clause        in long
  ,p_input_ds_d_where_clause      in long
);

PROCEDURE Register_Source_Chains (
  p_request_id                    in number
  ,p_act_rate_obj_id              in number
  ,p_ledger_id                    in number
  ,p_input_ds_b_where_clause      in long
  ,p_user_id                      in number
  ,p_login_id                     in number
);

PROCEDURE Rule_Post_Proc (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
  ,p_input_ds_b_where_clause      in long
  ,p_exec_status_code             in varchar2
);

PROCEDURE Request_Post_Proc (
  p_request_rec                   in request_record
  ,p_exec_status_code             in varchar2
);

FUNCTION Get_Lookup_Meaning (
  p_lookup_type                   in varchar2
  ,p_lookup_code                  in varchar2
)
RETURN varchar2;

PROCEDURE Get_Put_Messages (
  p_msg_count                     in number
  ,p_msg_data                     in varchar2
);


--------------------------------------------------------------------------------
--  Package bodies for functions/procedures
--------------------------------------------------------------------------------

/*===========================================================================+
 | PROCEDURE
 |   Act_Rate_Request
 |
 | DESCRIPTION
 |   Main engine procedure for activity rate processing in PFT
 |
 | SCOPE - PUBLIC
 |
 | MODIFICATION HISTORY
 |   ammittal   01-NOV-2004  Created
 |
 +===========================================================================*/

PROCEDURE Act_Rate_Request (
  errbuf                          out nocopy varchar2
  ,retcode                        out nocopy varchar2
  ,p_obj_id                       in number
  ,p_effective_date               in varchar2
  ,p_ledger_id                    in number
  ,p_output_cal_period_id         in number
  ,p_dataset_grp_obj_def_id       in number
  ,p_continue_process_on_err_flg  in varchar2
  ,p_source_system_code           in number
)
IS

  -----------------------
  -- Declare constants --
  -----------------------
  L_API_NAME             constant varchar2(30) := 'Act_Rate_Request';
  L_API_VERSION          constant number       := 1.0;

  -----------------------
  -- Declare variables --
  -----------------------
  l_request_rec                   request_record;

  l_act_rate_obj_id               number;
  l_act_rate_obj_def_id           number;
  l_act_rate_sequence             number;

  l_act_rate_rule_def_stmt        long;
  l_input_ds_b_where_clause       long;

  l_completion_status             boolean;

  l_act_rate_exec_status_code     varchar2(30);

  l_ruleset_status                varchar2(1);

  l_return_status                 varchar2(1);
  l_msg_count                     number;
  l_msg_data                      varchar2(240);

  l_err_code                      number;
  l_err_msg                       varchar2(30);

  l_request_params_error          exception;

  ----------------------------
  -- Declare static cursors --
  ----------------------------
  cursor l_ruleset_rules_csr (
    p_request_id in number
    ,p_ruleset_obj_id in number
  ) is
  select rs.child_obj_id
  ,rs.child_obj_def_id
  ,x.exec_status_code
  from fem_ruleset_process_data rs,
       fem_pl_object_executions x
  where rs.request_id = p_request_id
  and rs.rule_set_obj_id = p_ruleset_obj_id
  and x.request_id(+) = rs.request_id
  and x.object_id(+) = rs.child_obj_id
  and x.exec_object_definition_id(+) = rs.child_obj_def_id
  order by rs.engine_execution_sequence;


/*******************************************************************************
*                                                                              *
*                               Act_Rate_Request                               *
*                               Execution Block                                *
*                                                                              *
*******************************************************************************/

BEGIN

  -- Initialize Message Stack on FND_MSG_PUB
  FND_MSG_PUB.Initialize;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'BEGIN'
  );

  ------------------------------------------------------------------------------
  -- Check for the required parameters
  ------------------------------------------------------------------------------

  IF (p_obj_id IS NULL OR p_dataset_grp_obj_def_id IS NULL OR
      p_effective_date IS NULL OR p_output_cal_period_id IS NULL OR
      p_ledger_id IS NULL) THEN

        FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_ENG_BAD_CONC_REQ_PARAM_ERR
        );
        raise g_act_rate_request_error;
  END IF;

  ------------------------------------------------------------------------------
  -- STEP 1: Request Preparation
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.tech_message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'Step 1: Request Preperation'
  );

  Request_Prep (
    p_obj_id                   => p_obj_id
    ,p_effective_date_varchar  => p_effective_date
    ,p_ledger_id               => p_ledger_id
    ,p_output_cal_period_id    => p_output_cal_period_id
    ,p_dataset_grp_obj_def_id  => p_dataset_grp_obj_def_id
    ,p_continue_process_on_err_flg => p_continue_process_on_err_flg
    ,p_source_system_code => p_source_system_code
    ,x_request_rec             => l_request_rec
    ,x_input_ds_b_where_clause => l_input_ds_b_where_clause
  );

  ------------------------------------------------------------------------------
  -- STEP 2: Register Request
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'Step 2: Register Request'
  );

  Register_Request (
    p_request_rec => l_request_rec
  );

  ------------------------------------------------------------------------------
  -- STEP 3: Start Activity Rate Processing
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'Step 3: Start Activity Rate Processing'
  );

  -- Initialize the activity rate sequence to 0
  -- For Single Rule Submit, the sequence will remain at 0.
  -- For Rule Set Submit, the sequence for rule processing will be 1 to n.
  l_act_rate_sequence := 0;

  if (l_request_rec.submit_obj_type_code <> 'RULE_SET') then

    ------------------------------------------------------------------------------
    -- STEP 3.1: Single Rule Submit Processing
    ------------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Step 3.1: Single Rule Submit Processing'
    );

    l_act_rate_obj_id := l_request_rec.submit_obj_id;
    l_act_rate_obj_def_id := null;

    ----------------------------------------------------------------------------
    -- STEP 3.1.a: Validate Single Rule Submit
    ----------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Step 3.1.a: Single Rule Submit Processing'
    );

    -- Bug fix 4426460 - ammittal 06/21/05 - The code has been uncommented
    FEM_RULE_SET_MANAGER.Validate_Rule_Public (
      x_err_code             => l_err_code
      ,x_err_msg             => l_err_msg
      ,p_rule_object_id      => l_act_rate_obj_id
      ,p_ds_io_def_id        => l_request_rec.dataset_grp_obj_def_id
      ,p_rule_effective_date => l_request_rec.effective_date_varchar
      ,p_reference_period_id => l_request_rec.output_cal_period_id
      ,p_ledger_id           => l_request_rec.ledger_id
    );

    if (l_err_code <> 0) then
      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => l_err_msg
      );
      raise g_act_rate_request_error;
    end if;
    -- End of Bug fix 4426460

    ----------------------------------------------------------------------------
    -- STEP 3.1.b: Calculate Activity Rate for Single Rule
    ----------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Step 3.1.b: Calculate Activity Rate for Single Rule'
    );

    Act_Rate_Rule (
      p_request_rec              => l_request_rec
      ,p_act_rate_obj_id         => l_act_rate_obj_id
      ,p_act_rate_obj_def_id     => l_act_rate_obj_def_id
      ,p_act_rate_sequence       => l_act_rate_sequence
      ,p_input_ds_b_where_clause => l_input_ds_b_where_clause
      ,x_return_status          => l_return_status
    );

    if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      raise g_act_rate_request_error;
    end if;

  else

    ----------------------------------------------------------------------------
    -- STEP 3.2: Rule Set Processing
    ----------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Step 3.2: Rule Set Processing'
    );

    ----------------------------------------------------------------------------
    -- STEP 3.2.a: Rule Set Pre Processing
    ----------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Step 3.2.a: Rule Set Pre Processing'
    );

    FEM_RULE_SET_MANAGER.FEM_Preprocess_RuleSet_PVT (
      p_api_version                  => 1.0
      ,p_init_msg_list               => FND_API.G_FALSE
      ,p_commit                      => FND_API.G_TRUE
      ,p_encoded                     => FND_API.G_TRUE
      ,x_return_status               => l_return_status
      ,x_msg_count                   => l_msg_count
      ,x_msg_data                    => l_msg_data
      ,p_orig_ruleset_object_id      => l_request_rec.ruleset_obj_id
      ,p_ds_io_def_id                => l_request_rec.dataset_grp_obj_def_id
      ,p_rule_effective_date         => l_request_rec.effective_date_varchar
      ,p_output_period_id            => l_request_rec.output_cal_period_id
      ,p_ledger_id                   => l_request_rec.ledger_id
      ,p_continue_process_on_err_flg => l_request_rec.continue_process_on_err_flg
      ,p_execution_mode              => 'E' --This is engine execution mode
    );

    if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      Get_Put_Messages (
        p_msg_count => l_msg_count
        ,p_msg_data => l_msg_data
      );
      raise g_act_rate_request_error;
    end if;

    ----------------------------------------------------------------------------
    -- STEP 3.2.b: Loop through all Rule Set Rules
    ----------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Step 3.2.b: Loop through all Rule Set Rules'
    );

    -- Initialize the rule set status to SUCCESS
    l_ruleset_status := FND_API.G_RET_STS_SUCCESS;

    open l_ruleset_rules_csr (
      p_request_id      => l_request_rec.request_id
      ,p_ruleset_obj_id => l_request_rec.ruleset_obj_id
    );

    loop

      fetch l_ruleset_rules_csr
      into l_act_rate_obj_id
      ,l_act_rate_obj_def_id
      ,l_act_rate_exec_status_code;

      exit when l_ruleset_rules_csr%NOTFOUND;

      l_act_rate_sequence := l_act_rate_sequence + 1;

      -- Do not process rule set rollup rules that completed successfully

      if (l_act_rate_exec_status_code is null)
        or (l_act_rate_exec_status_code <> 'SUCCESS') then

        --------------------------------------------------------------------------
        -- STEP 3.2.c: Activity Rate Rule Set Rule
        --------------------------------------------------------------------------
        FEM_ENGINES_PKG.Tech_Message (
          p_severity  => G_LOG_LEVEL_1
          ,p_module   => G_BLOCK||'.'||L_API_NAME
          ,p_msg_text => 'Step 3.2.c: Activity Rate Rule Set Rule #'||to_char(l_act_rate_sequence)
        );

        Act_Rate_Rule (
          p_request_rec              => l_request_rec
          ,p_act_rate_obj_id         => l_act_rate_obj_id
          ,p_act_rate_obj_def_id     => l_act_rate_obj_def_id
          ,p_act_rate_sequence       => l_act_rate_sequence
          ,p_input_ds_b_where_clause => l_input_ds_b_where_clause
          ,x_return_status           => l_return_status
        );

      if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        l_ruleset_status := l_return_status;
        if (l_request_rec.continue_process_on_err_flg = 'N') then
          raise g_act_rate_request_error;
        end if;
      end if;

    end if;

    end loop;

    close l_ruleset_rules_csr;

    if (l_ruleset_status <> FND_API.G_RET_STS_SUCCESS) then
      raise g_act_rate_request_error;
    end if;

  end if;

  ------------------------------------------------------------------------------
  -- STEP 4: Request Post Processing.
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'Step 4: Request Post Processing'
  );

  Request_Post_Proc (
    p_request_rec       => l_request_rec
    ,p_exec_status_code => G_EXEC_STATUS_SUCCESS
  );

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'END'
  );

EXCEPTION

  when g_act_rate_request_error then

    if (l_ruleset_rules_csr%ISOPEN) then
     close l_ruleset_rules_csr;
    end if;

    Request_Post_Proc (
      p_request_rec       => l_request_rec
      ,p_exec_status_code => G_EXEC_STATUS_ERROR_UNDO
    );

    l_completion_status := FND_CONCURRENT.Set_Completion_Status('ERROR',null);

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => g_log_level_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Activity Rate Request Exception'
    );

  when others then

    g_prg_msg := SQLERRM;
    g_callstack := DBMS_UTILITY.Format_Call_Stack;

    if (l_ruleset_rules_csr%ISOPEN) then
     close l_ruleset_rules_csr;
    end if;

    Request_Post_Proc (
      p_request_rec       => l_request_rec
      ,p_exec_status_code => G_EXEC_STATUS_ERROR_UNDO
    );

    l_completion_status := FND_CONCURRENT.Set_Completion_Status('ERROR',null);

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => g_log_level_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME||'.Unexpected_Exception'
      ,p_msg_text => g_prg_msg
    );

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => g_log_level_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME||'.Unexpected_Exception'
      ,p_msg_text => g_callstack
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_UNEXPECTED_ERROR
      ,p_token1   => 'ERR_MSG'
      ,p_value1   => g_prg_msg
    );

END Act_Rate_Request;



/*===========================================================================+
 | PROCEDURE
 |   Request_Prep
 |
 | DESCRIPTION
 |   This procedure takes the i/p variables from concurrent manager
 |   and prepares the engine with relevant information
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

PROCEDURE Request_Prep (
  p_obj_id                        in number
  ,p_effective_date_varchar       in varchar2
  ,p_ledger_id                    in number
  ,p_output_cal_period_id         in number
  ,p_dataset_grp_obj_def_id       in number
  ,p_continue_process_on_err_flg  in varchar2
  ,p_source_system_code           in number
  ,x_request_rec                  out nocopy request_record
  ,x_input_ds_b_where_clause      out nocopy long
)
IS

  L_API_NAME             constant varchar2(30) := 'Request_Prep';

  l_dimension_varchar_label       varchar2(30) := 'ACTIVITY';
  l_dummy_varchar                 varchar2(30);
  l_dummy_date                    date;

  l_object_name                   varchar2(150);
  l_object_type_code              varchar2(30);
  l_folder_name                   varchar2(150);

  l_return_status                 varchar2(1);
  l_msg_count                     number;
  l_msg_data                      varchar2(240);

  l_request_prep_error            exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'BEGIN'
  );

  ------------------------------------------------------------
  -- Set all the Submitted Parameters on the Request Record --
  ------------------------------------------------------------
  x_request_rec.submit_obj_id := p_obj_id;
  x_request_rec.effective_date_varchar := p_effective_date_varchar;
  x_request_rec.effective_date :=
    FND_DATE.Canonical_To_Date(p_effective_date_varchar);
  x_request_rec.ledger_id := p_ledger_id;
  x_request_rec.output_cal_period_id := p_output_cal_period_id;
  x_request_rec.dataset_grp_obj_def_id := p_dataset_grp_obj_def_id;
  x_request_rec.continue_process_on_err_flg := p_continue_process_on_err_flg;
  x_request_rec.source_system_code := p_source_system_code;

  -------------------------------------------------------------
  -- Set all the FND Global Parameters on the Request Record --
  -------------------------------------------------------------
  x_request_rec.user_id := FND_GLOBAL.user_id;
  x_request_rec.login_id := FND_GLOBAL.login_id;
  x_request_rec.request_id := FND_GLOBAL.conc_request_id;
  x_request_rec.resp_id := FND_GLOBAL.resp_id;
  x_request_rec.pgm_id := FND_GLOBAL.conc_program_id;
  x_request_rec.pgm_app_id := FND_GLOBAL.prog_appl_id;

  ---------------------------------------------------------
  -- Get the limit for bulk fetches from profile options --
  ---------------------------------------------------------
  g_fetch_limit := nvl (
    FND_PROFILE.Value_Specific (
      'FEM_BULK_FETCH_LIMIT'
      ,x_request_rec.user_id
      ,x_request_rec.resp_id
      ,x_request_rec.pgm_app_id)
    ,G_DEFAULT_FETCH_LIMIT
  );

  ----------------------------------------------------------
  -- Get the track event chains flag from profile options --
  ----------------------------------------------------------
  g_track_event_chains :=
    ('Y' =
      FND_PROFILE.Value_Specific (
        'FEM_TRACK_EVENT_CHAINS'
        ,x_request_rec.user_id
        ,x_request_rec.resp_id
        ,x_request_rec.pgm_app_id)
    );

  -----------------------------------------------------------
  -- Get the currency conversion type from profile options --
  -----------------------------------------------------------
  g_currency_conv_type :=
    FND_PROFILE.Value_Specific (
      'FEM_CURRENCY_CONVERSION_TYPE'
      ,x_request_rec.user_id
      ,x_request_rec.resp_id
      ,x_request_rec.pgm_app_id
    );

  if (g_currency_conv_type is null) then
    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_ENG_NO_CURR_CONV_TYPE_ERR
      ,p_token1   => 'PROFILE_OPTION_NAME'
      ,p_value1   => 'FEM_CURRENCY_CONVERSION_TYPE'
    );
    raise l_request_prep_error;
  end if;


  ------------------------------------------------------------------------------
  -- Get the object type code to determine if this is a rule set or single
  -- rule submit submission
  ------------------------------------------------------------------------------
  begin
    select object_type_code
    ,local_vs_combo_id
    into x_request_rec.submit_obj_type_code
    ,x_request_rec.local_vs_combo_id
    from fem_object_catalog_b
    where object_id = x_request_rec.submit_obj_id;
  exception
    when others then
      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_ENG_NO_SUBMIT_OBJ_ERR
        ,p_token1   => 'OBJECT_ID'
        ,p_value1   => x_request_rec.submit_obj_id
      );
      raise l_request_prep_error;
  end;

  if (x_request_rec.submit_obj_type_code = 'RULE_SET') then

    x_request_rec.ruleset_obj_id := x_request_rec.submit_obj_id;

    begin
      select object_name
      into x_request_rec.ruleset_obj_name
      from fem_object_catalog_vl
      where object_id = x_request_rec.ruleset_obj_id;
    exception
      when others then
        FEM_ENGINES_PKG.User_Message (
          p_app_name  => G_FEM
          ,p_msg_name => G_ENG_RS_NO_OBJ_ERR
          ,p_token1   => 'OBJECT_TYPE_MEANING'
          ,p_value1   => Get_Lookup_Meaning('FEM_OBJECT_TYPE_DSC','RULE_SET')
          ,p_token2   => 'OBJECT_ID'
          ,p_value2   => x_request_rec.ruleset_obj_id
        );
        raise l_request_prep_error;
    end;

    Get_Object_Definition (
      p_object_type_code => x_request_rec.submit_obj_type_code
      ,p_object_id       => x_request_rec.ruleset_obj_id
      ,p_effective_date  => x_request_rec.effective_date
      ,x_obj_def_id      => x_request_rec.ruleset_obj_def_id
    );

    -- Set the Object Type Code for the Activity Rate Request
    begin
      select rule_set_object_type_code
      into x_request_rec.act_rate_obj_type_code
      from fem_rule_sets
      where rule_set_obj_def_id = x_request_rec.ruleset_obj_def_id;
    exception
      when others then

        select object_name
              ,object_type_code
        into l_object_name
             ,l_object_type_code
        from fem_object_catalog_vl
       where object_id = p_obj_id;

        FEM_ENGINES_PKG.User_Message (
          p_app_name  => G_FEM
          ,p_msg_name => G_ENG_RS_NO_OBJ_DEF_ERR
          ,p_token1   => 'OBJECT_TYPE_MEANING'
          ,p_value1   => Get_Lookup_Meaning('FEM_OBJECT_TYPE_DSC',l_object_type_code)
          ,p_token2   => 'OBJECT_NAME'
          ,p_value2   => l_object_name
          ,p_token3   => 'EFFECTIVE_DATE'
          ,p_value3   => FND_DATE.date_to_chardate(x_request_rec.effective_date)
        );
        raise l_request_prep_error;
    end;

  else

    x_request_rec.ruleset_obj_id := null;
    x_request_rec.ruleset_obj_name := null;
    x_request_rec.ruleset_obj_def_id := null;

    -- Set the Object Type Code for the Activity Rate Process
    x_request_rec.act_rate_obj_type_code := x_request_rec.submit_obj_type_code;

  end if;

  ------------------------------------------------------------------------------
  -- Get Dimension Metadata
  ------------------------------------------------------------------------------
  Get_Dimension_Record (
    p_dimension_varchar_label    => l_dimension_varchar_label
    ,x_dimension_rec             => x_request_rec.dimension_rec
  );

  ------------------------------------------------------------------------------
  -- Validate the Processing Key on FEM_BALANCES to make sure that it can
  -- handle rollup processing on the appropriate composite dimension.
  ------------------------------------------------------------------------------
  -- Validation added with bug 4475839
  FEM_SETUP_PKG.Validate_Proc_Key (
    p_api_version              => 1.0
    ,p_init_msg_list           => FND_API.G_FALSE
    ,p_commit                  => FND_API.G_FALSE
    ,p_encoded                 => FND_API.G_TRUE
    ,x_return_status           => l_return_status
    ,x_msg_count               => l_msg_count
    ,x_msg_data                => l_msg_data
    ,p_dimension_varchar_label => l_dimension_varchar_label
    ,p_table_name              => 'FEM_BALANCES'
  );

  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
    Get_Put_Messages (
      p_msg_count => l_msg_count
      ,p_msg_data => l_msg_data
    );
    raise l_request_prep_error;
  end if;

  ------------------------------------------------------------------------------
  -- Get the Source System Code for PFT if a null param has been passed
  ------------------------------------------------------------------------------

  if (x_request_rec.source_system_code is null) then
    -- For all Activity Rate Processing default the Source System Display Code to PFT
    begin
      select source_system_code
      into x_request_rec.source_system_code
      from fem_source_systems_b
      where source_system_display_code =   G_PFT_SOURCE_SYSTEM_DC;
    exception
      when others then
        FEM_ENGINES_PKG.User_Message (
          p_app_name  => G_FEM
          ,p_msg_name => G_ENG_NO_DIM_MEMBER_ERR
          ,p_token1   => 'TABLE_NAME'
          ,p_value1   => 'FEM_SOURCE_SYSTEMS_B'
          ,p_token2   => 'MEMBER_DISPLAY_CODE'
          ,p_value2   => G_PFT_SOURCE_SYSTEM_DC
        );
        raise l_request_prep_error;
    end;

  end if;

  ------------------------------------------------------------------------------
  -- Get the Output Dataset Code
  ------------------------------------------------------------------------------
  begin
    select output_dataset_code
    into x_request_rec.output_dataset_code
    from fem_ds_input_output_defs
    where dataset_io_obj_def_id = x_request_rec.dataset_grp_obj_def_id;
  exception
    when others then

      select obj.object_name
      ,f.folder_name
      into l_object_name
      ,l_folder_name
      from fem_object_catalog_vl obj
      ,fem_folders_vl f
      where obj.object_id = x_request_rec.dataset_grp_obj_id
      and f.folder_id = obj.folder_id;

      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_ENG_NO_OUTPUT_DS_ERR
        ,p_token1   => 'FOLDER_NAME'
        ,p_value1   => l_folder_name
        ,p_token2   => 'DATASET_GRP_NAME'
        ,p_value2   => l_object_name
      );
      raise l_request_prep_error;
  end;

  ------------------------------------------------------------------------------
  -- Get the Dataset Group Object ID
  ------------------------------------------------------------------------------
  begin
    select object_id
    into x_request_rec.dataset_grp_obj_id
    from fem_object_definition_b
    where object_definition_id = x_request_rec.dataset_grp_obj_def_id;
  exception
    when others then
      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_ENG_NO_DS_GRP_OBJ_ERR
        ,p_token1   => 'OBJECT_TYPE_MEANING'
        ,p_value1   => Get_Lookup_Meaning('FEM_OBJECT_TYPE_DSC','RULE_SET')
        ,p_token2   => 'OBJECT_ID'
        ,p_value2   => x_request_rec.ruleset_obj_id
      );
      raise l_request_prep_error;
  end;

  ------------------------------------------------------------------------------
  -- Call the Where Clause Generator for source data in FEM_BALANCES
  ------------------------------------------------------------------------------
  FEM_DS_WHERE_CLAUSE_GENERATOR.FEM_Gen_DS_WClause_PVT (
    p_api_version       => 1.0
    ,p_init_msg_list    => FND_API.G_FALSE
    ,p_encoded          => FND_API.G_TRUE
    ,x_return_status    => l_return_status
    ,x_msg_count        => l_msg_count
    ,x_msg_data         => l_msg_data
    ,p_ds_io_def_id     => x_request_rec.dataset_grp_obj_def_id
    ,p_output_period_id => x_request_rec.output_cal_period_id
    ,p_table_name       => 'FEM_BALANCES'
    ,p_table_alias      => 'B'
    ,p_ledger_id        => x_request_rec.ledger_id
    ,p_where_clause     => x_input_ds_b_where_clause
  );

  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
    Get_Put_Messages (
      p_msg_count => l_msg_count
      ,p_msg_data => l_msg_data
    );
    raise l_request_prep_error;
  end if;

  if (x_input_ds_b_where_clause is null) then
    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_ENG_BAD_DS_WCLAUSE_ERR
      ,p_token1   => 'DATASET_GRP_OBJ_DEF_ID'
      ,p_value1   => x_request_rec.dataset_grp_obj_def_id
      ,p_token2   => 'OUTPUT_CAL_PERIOD_ID'
      ,p_value2   => x_request_rec.output_cal_period_id
      ,p_token3   => 'TABLE_NAME'
      ,p_value3   => 'FEM_BALANCES'
      ,p_token4   => 'LEDGER_ID'
      ,p_value4   => x_request_rec.ledger_id
    );
    raise l_request_prep_error;
  end if;

  ------------------------------------------------------------------------------
  -- Get Ledger information
  ------------------------------------------------------------------------------
  Get_Dim_Attribute_Value (
    p_dimension_varchar_label       => 'LEDGER'
    ,p_attribute_varchar_label      => 'ENTERED_CRNCY_ENABLE_FLAG'
    ,p_member_id                    => x_request_rec.ledger_id
    ,x_dim_attribute_varchar_member => x_request_rec.entered_currency_flag
    ,x_date_assign_value            => l_dummy_date
  );

  Get_Dim_Attribute_Value (
    p_dimension_varchar_label       => 'LEDGER'
    ,p_attribute_varchar_label      => 'LEDGER_FUNCTIONAL_CRNCY_CODE'
    ,p_member_id                    => x_request_rec.ledger_id
    ,x_dim_attribute_varchar_member => x_request_rec.functional_currency_code
    ,x_date_assign_value            => l_dummy_date
  );

  ------------------------------------------------------------------------------
  -- Set the exchange rate date
  ------------------------------------------------------------------------------
  if (x_request_rec.entered_currency_flag = 'Y') then

    Get_Dim_Attribute_Value (
      p_dimension_varchar_label       => 'CAL_PERIOD'
      ,p_attribute_varchar_label      => 'CAL_PERIOD_END_DATE'
      ,p_member_id                    => x_request_rec.output_cal_period_id
      ,x_dim_attribute_varchar_member => l_dummy_varchar
      ,x_date_assign_value            => x_request_rec.entered_exch_rate_date
    );

  else

    x_request_rec.entered_exch_rate_date := null;

  end if;

  -- Log all Request Record Parameters if we have low level debugging
  if ( FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) ) then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||L_API_NAME||'.x_request_rec'
      ,p_msg_text =>
        ' act_rate_obj_type_code='||x_request_rec.act_rate_obj_type_code||
        ' dataset_grp_obj_def_id='||x_request_rec.dataset_grp_obj_def_id||
        ' dataset_grp_obj_id ='||x_request_rec.dataset_grp_obj_id ||
        ' dimension_varchar_label='||x_request_rec.dimension_rec.dimension_varchar_label||
        ' effective_date='||FND_DATE.date_to_chardate(x_request_rec.effective_date)||
        ' entered_exch_rate_date='||FND_DATE.date_to_chardate(x_request_rec.entered_exch_rate_date)||
        ' entered_currency_flag ='||x_request_rec.entered_currency_flag ||
        ' functional_currency_code ='||x_request_rec.functional_currency_code ||
        ' ledger_id='||x_request_rec.ledger_id||
        ' local_vs_combo_id='||x_request_rec.local_vs_combo_id||
        ' login_id='||x_request_rec.login_id||
        ' output_cal_period_id='||x_request_rec.output_cal_period_id||
        ' output_dataset_code='||x_request_rec.output_dataset_code||
        ' pgm_id='||x_request_rec.pgm_id||
        ' pgm_app_id='||x_request_rec.pgm_app_id||
        ' request_id='||x_request_rec.request_id||
        ' resp_id='||x_request_rec.resp_id||
        ' ruleset_obj_def_id='||x_request_rec.ruleset_obj_def_id||
        ' ruleset_obj_id='||x_request_rec.ruleset_obj_id||
        ' ruleset_obj_name='||x_request_rec.ruleset_obj_name||
        ' source_system_code='||x_request_rec.source_system_code||
        ' submit_obj_id='||x_request_rec.submit_obj_id||
        ' submit_obj_type_code='||x_request_rec.submit_obj_type_code||
        ' user_id='||x_request_rec.user_id
    );

  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_request_prep_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Request Preperation Exception'
    );

    raise g_act_rate_request_error;

END Request_Prep;



/*===========================================================================+
 | PROCEDURE
 |   Get_Object_Definition
 |
 | DESCRIPTION
 |   Get the object definition from object id
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

PROCEDURE Get_Object_Definition (
  p_object_type_code              in varchar2
  ,p_object_id                    in number
  ,p_effective_date               in date
  ,x_obj_def_id                   out nocopy number
)
IS

  L_API_NAME             constant varchar2(30) := 'Get_Object_Definition';

  l_object_name                   varchar2(150);

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'BEGIN'
  );

  select d.object_definition_id
  into x_obj_def_id
  from fem_object_definition_b d
  ,fem_object_catalog_b o
  where o.object_id = p_object_id
  and o.object_type_code = p_object_type_code
  and d.object_id = o.object_id
  and p_effective_date between d.effective_start_date and d.effective_end_date
  and d.old_approved_copy_flag = 'N';

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'END'
  );

EXCEPTION

  when no_data_found then

    select object_name
    into l_object_name
    from fem_object_catalog_vl
    where object_id = p_object_id;

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_ENG_NO_OBJ_DEF_ERR
      ,p_token1   => 'OBJECT_TYPE_CODE'
      ,p_value1   => p_object_type_code
      ,p_token2   => 'OBJECT_NAME'
      ,p_value2   => l_object_name
      ,p_token3   => 'EFFECTIVE_DATE'
      ,p_value3   => FND_DATE.date_to_chardate(p_effective_date)
    );

    raise g_act_rate_request_error;

END Get_Object_Definition;



/*===========================================================================+
 | PROCEDURE
 |   Get_Dimension_Record
 |
 | DESCRIPTION
 |   Validates the input dimension and returns a dimension record containing
 |   dimension metadata
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

PROCEDURE Get_Dimension_Record (
  p_dimension_varchar_label       in varchar2
  ,x_dimension_rec                out nocopy dimension_record
)
IS

  L_API_NAME             constant varchar2(30) := 'Get_Dimension_Record';

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'BEGIN'
  );

  select dimension_id
  ,dimension_varchar_label
  ,composite_dimension_flag
  ,member_col
  ,member_b_table_name
  ,attribute_table_name as attr_table
  ,hierarchy_table_name as hier_table
  ,hier_versioning_type_code
  into x_dimension_rec
  from fem_xdim_dimensions_vl
  where dimension_varchar_label = p_dimension_varchar_label;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'END'
  );

EXCEPTION

  when no_data_found then

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_ENG_NO_DIM_DTL_ERR
      ,p_token1   => 'DIMENSION_VARCHAR_LABEL'
      ,p_value1   => p_dimension_varchar_label
    );

    raise g_act_rate_request_error;

END Get_Dimension_Record;



/*===========================================================================+
 | PROCEDURE
 |   Get_Dim_Attribute_Value
 |
 | DESCRIPTION
 |   Det Dimension Attribute Values
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

PROCEDURE Get_Dim_Attribute_Value (
  p_dimension_varchar_label       in varchar2
  ,p_attribute_varchar_label      in varchar2
  ,p_member_id                    in number
  ,x_dim_attribute_varchar_member out nocopy varchar
  ,x_date_assign_value            out nocopy date
)
IS

  L_API_NAME             constant varchar2(30) := 'Get_Dim_Attribute_Value';

  l_dimension_rec                 dimension_record;

  l_attribute_id                  number;
  l_attr_version_id               number;

  l_get_dim_att_val_error         exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'BEGIN'
  );

  Get_Dimension_Record (
    p_dimension_varchar_label    => p_dimension_varchar_label
    ,x_dimension_rec             => l_dimension_rec
  );

  begin
    select att.attribute_id
    ,ver.version_id
    into l_attribute_id
    ,l_attr_version_id
    from fem_dim_attributes_b att
    ,fem_dim_attr_versions_b ver
    where att.dimension_id = l_dimension_rec.dimension_id
    and att.attribute_varchar_label = p_attribute_varchar_label
    and ver.attribute_id = att.attribute_id
    and ver.default_version_flag = 'Y';
  exception
    when others then
      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_ENG_NO_DIM_ATTR_VER_ERR
        ,p_token1   => 'DIMENSION'
        ,p_value1   => p_dimension_varchar_label
        ,p_token2   => 'ATTRIBUTE'
        ,p_value2   => p_attribute_varchar_label
      );
      raise l_get_dim_att_val_error;
  end;

  begin
    execute immediate
    ' select dim_attribute_varchar_member'||
    ' ,date_assign_value'||
    ' from '||l_dimension_rec.attr_table||
    ' where attribute_id = :b_attribute_id'||
    ' and version_id = :b_attr_version_id'||
    ' and '||l_dimension_rec.member_col||' = :b_member_id'
    into x_dim_attribute_varchar_member
    ,x_date_assign_value
    using l_attribute_id
    ,l_attr_version_id
    ,p_member_id;
  exception
    when others then
      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_ENG_NO_DIM_ATTR_VAL_ERR
        ,p_token1   => 'DIMENSION'
        ,p_value1   => p_dimension_varchar_label
        ,p_token2   => 'ATTRIBUTE'
        ,p_value2   => p_attribute_varchar_label
      );
      raise l_get_dim_att_val_error;
  end;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_get_dim_att_val_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => g_log_level_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Get Dimension Attribute Value Exception'
    );

    raise g_act_rate_request_error;

END Get_Dim_Attribute_Value;

/*===========================================================================+
 | PROCEDURE
 |   Register_Request
 |
 | DESCRIPTION
 |   Registers the request in the processing locks tables.
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

PROCEDURE Register_Request (
  p_request_rec                   in request_record
)
IS

  L_API_NAME             constant varchar2(30) := 'Register_Request';

  l_return_status                 varchar2(1);
  l_msg_count                     number;
  l_msg_data                      varchar2(240);

  l_register_request_error        exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'BEGIN'
  );

  savepoint register_request_pub;

  -- Call the FEM_PL_PKG.Register_Request API procedure to register
  -- the concurrent request in FEM_PL_REQUESTS.
  FEM_PL_PKG.Register_Request (
    p_api_version             => 1.0
    ,p_commit                 => FND_API.G_FALSE
    ,p_cal_period_id          => p_request_rec.output_cal_period_id
    ,p_ledger_id              => p_request_rec.ledger_id
    ,p_dataset_io_obj_def_id  => p_request_rec.dataset_grp_obj_def_id
    ,p_output_dataset_code    => p_request_rec.output_dataset_code
    ,p_source_system_code     => p_request_rec.source_system_code
    ,p_effective_date         => p_request_rec.effective_date
    ,p_rule_set_obj_def_id    => p_request_rec.ruleset_obj_def_id
    ,p_rule_set_name          => p_request_rec.ruleset_obj_name
    ,p_request_id             => p_request_rec.request_id
    ,p_user_id                => p_request_rec.user_id
    ,p_last_update_login      => p_request_rec.login_id
    ,p_program_id             => p_request_rec.pgm_id
    ,p_program_login_id       => p_request_rec.login_id
    ,p_program_application_id => p_request_rec.pgm_app_id
    ,p_exec_mode_code         => null
    ,p_dimension_id           => null
    ,p_table_name             => null
    ,p_hierarchy_name         => null
    ,x_msg_count              => l_msg_count
    ,x_msg_data               => l_msg_data
    ,x_return_status          => l_return_status
  );

  -- Request Lock exists
  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
    Get_Put_Messages (
      p_msg_count => l_msg_count
      ,p_msg_data => l_msg_data
    );
    raise l_register_request_error;
  end if;

  commit;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_register_request_error then

    rollback to register_request_pub;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Register Request Exception'
    );

    raise g_act_rate_request_error;

  when g_act_rate_request_error then

    rollback to register_request_pub;
    raise g_act_rate_request_error;

  when others then

    rollback to register_request_pub;
    raise;

END Register_Request;



/*===========================================================================+
 | PROCEDURE
 |   Act_Rate_Rule
 |
 | DESCRIPTION
 |   Calculate Activity Rate
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

PROCEDURE Act_Rate_Rule (
  p_request_rec                   in request_record
  ,p_act_rate_obj_id              in number
  ,p_act_rate_obj_def_id          in number
  ,p_act_rate_sequence            in number
  ,p_input_ds_b_where_clause      in long
  ,x_return_status                out nocopy varchar2
)
IS

  L_API_NAME             constant varchar2(30) := 'Act_Rate_Rule';

  l_rule_rec                      rule_record;

  l_completion_status             boolean;

  l_find_children_stmt            long;
  l_rollup_parent_stmt            long;
  l_find_child_chains_stmt        long;
  l_num_of_input_rows_stmt        long;

  l_insert_count                  number;

  -------------------------------------
  -- Declare bulk collection columns --
  -------------------------------------
  t_top_node_id                   number_type;

  -----------------------------------------------------------
  -- Index indicating last row number for a cursor.
  -----------------------------------------------------------
  l_get_root_nodes_last_row       number;
  l_get_cond_nodes_last_row       number;

  l_act_rate_rule_error           exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'BEGIN'
  );

  -- Initialize the return status to SUCCESS

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  ------------------------------------------------------------------------------
  -- STEP 1: Rule Pre Processing
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.tech_message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'Step 1: Rule Pre Processing'
  );

  Rule_Prep (
    p_request_rec               => p_request_rec
    ,p_act_rate_obj_id          => p_act_rate_obj_id
    ,p_act_rate_obj_def_id      => p_act_rate_obj_def_id
    ,p_act_rate_sequence        => p_act_rate_sequence
    ,x_rule_rec                 => l_rule_rec
  );

  ------------------------------------------------------------------------------
  -- STEP 2: Register Rule under the same parent request
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.tech_message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'Step 2: Register Rule'
  );

  Register_Rule (
    p_request_rec => p_request_rec
    ,p_rule_rec   => l_rule_rec
  );

  ------------------------------------------------------------------------------
  -- STEP 3: Create Temporary Objects
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.tech_message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'Step 3: Create Temporary Objects'
  );

  Create_Temp_Objects (
    p_request_rec => p_request_rec
    ,p_rule_rec   => l_rule_rec
  );

  ----------------------------------------------------------------------------
  -- STEP 4: Call Process Drivers
  ----------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'Step 4: Call Process Drivers'
  );

  Process_Drivers (
    p_request_rec   => p_request_rec
    ,p_rule_rec     => l_rule_rec
    ,p_insert_count => l_insert_count
  );

  ------------------------------------------------------------------------------
  -- STEP 5: Calculate Activity Rate
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'Step 5: Calculate Activity Rate'
  );

  Calc_Act_Rate (
    p_request_rec              => p_request_rec
    ,p_rule_rec                => l_rule_rec
    ,p_input_ds_b_where_clause => p_input_ds_b_where_clause
  );

  if (g_track_event_chains) then

    ----------------------------------------------------------------------------
    -- STEP 6: Register Source Chains
    ----------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Step 6: Register Source Chains'
    );

    Register_Source_Chains (
      p_request_id               => p_request_rec.request_id
      ,p_act_rate_obj_id         => l_rule_rec.act_rate_obj_id
      ,p_ledger_id               => p_request_rec.ledger_id
      ,p_input_ds_b_where_clause => p_input_ds_b_where_clause
      ,p_user_id                 => p_request_rec.user_id
      ,p_login_id                => p_request_rec.login_id
    );

  end if;

  ------------------------------------------------------------------------------
  -- STEP 7: Rule Post Processing
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'Step 7: Rule Post Processing'
  );

  Rule_Post_Proc (
    p_request_rec              => p_request_rec
    ,p_rule_rec                => l_rule_rec
    ,p_input_ds_b_where_clause => p_input_ds_b_where_clause
    ,p_exec_status_code        => G_EXEC_STATUS_SUCCESS
  );

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_act_rate_rule_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => g_log_level_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Activity Rate Rule Exception'
    );

    -- Rule Post Processing
    Rule_Post_Proc (
      p_request_rec              => p_request_rec
      ,p_rule_rec                => l_rule_rec
      ,p_input_ds_b_where_clause => p_input_ds_b_where_clause
      ,p_exec_status_code        => G_EXEC_STATUS_ERROR_UNDO
    );

    -- Proper handling of continue processing on error
    -- raise g_act_rate_request_error;

    x_return_status := FND_API.G_RET_STS_ERROR;

  when g_act_rate_request_error then

    -- Rule Post Processing
    Rule_Post_Proc (
      p_request_rec              => p_request_rec
      ,p_rule_rec                => l_rule_rec
      ,p_input_ds_b_where_clause => p_input_ds_b_where_clause
      ,p_exec_status_code        => G_EXEC_STATUS_ERROR_UNDO
    );

    -- Proper handling of continue processing on error
    -- raise g_act_rate_request_error;

    x_return_status := FND_API.G_RET_STS_ERROR;

  when others then

    g_prg_msg := SQLERRM;
    g_callstack := DBMS_UTILITY.Format_Call_Stack;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => g_log_level_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME||'.Unexpected_Exception'
      ,p_msg_text => g_prg_msg
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_UNEXPECTED_ERROR
      ,p_token1   => 'ERR_MSG'
      ,p_value1   => g_prg_msg
    );

    -- Rule Post Processing
    Rule_Post_Proc (
      p_request_rec              => p_request_rec
      ,p_rule_rec                => l_rule_rec
      ,p_input_ds_b_where_clause => p_input_ds_b_where_clause
      ,p_exec_status_code        => G_EXEC_STATUS_ERROR_UNDO
    );


    -- Proper handling of continue processing on error
    -- raise g_act_rate_request_error;

    x_return_status := FND_API.G_RET_STS_ERROR;

END Act_Rate_Rule;



/*===========================================================================+
 | PROCEDURE
 |   Calc_Act_Rate
 |
 | DESCRIPTION
 |   ammittal - Calculate Activity Rates
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

PROCEDURE Calc_Act_Rate (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
  ,p_input_ds_b_where_clause      in long
)
IS

  L_API_NAME             constant varchar2(30) := 'Calc_Act_Rate';

  L_CALC_ACT_RATE_VALUES  constant varchar2(30) := 'CALC_ACT_RATE_VALUES';
  L_CALC_ACT_RATE_FACTORS constant varchar2(30) := 'CALC_ACT_RATE_FACTORS';

  l_mp_prog_status                varchar2(30);
  l_mp_exception_code             varchar2(30);

  l_act_rate_stmt                 long;
  l_calc_fctrs_stmt               long;
  l_drv_vals_tbl_where_clause     long;
  l_source_table_query_stmt       long;
  l_source_table_query_param1     number;
  l_source_table_query_param2     number;

  l_return_status                 varchar2(1);
  l_msg_count                     number;
  l_msg_data                      varchar2(240);

  l_calc_act_rate_error           exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'BEGIN'
  );

  -- Initialize MP variables
  l_mp_prog_status := G_COMPLETE_NORMAL;

  ------------------------------------------------------------------------------
  -- STEP 1: Update Activity Id in Balances Table
  ------------------------------------------------------------------------------

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'Step 1:  Update Activity Id in FEM_BALANCES Table'
  );

  -- A join to FEM_ACTIVITIES is
  -- necessary for Populate_Activity_Id to work properly as it needs all the
  -- component dimension columns for the join on FEM_BALANCES.

  l_source_table_query_stmt :=
  ' select act.activity_id'||
  ' from fem_activities act'||
  ' ,pft_ar_driver_values_t drv'||
  ' where drv.CREATED_BY_REQUEST_ID = :b_request_id'||
  '   and drv.CREATED_BY_OBJECT_ID = :b_act_rate_obj_id'||
  '   and drv.activity_id = act.activity_id';

  l_source_table_query_param1 := p_request_rec.request_id;
  l_source_table_query_param2 := p_rule_rec.act_rate_obj_id;

  --todo:  MP integration  (???)
  FEM_COMPOSITE_DIM_UTILS_PVT.Populate_Activity_Id (
    p_api_version                   => 1.0
    ,p_init_msg_list                => FND_API.G_FALSE
    ,p_commit                       => FND_API.G_TRUE
    ,x_return_status                => l_return_status
    ,x_msg_count                    => l_msg_count
    ,x_msg_data                     => l_msg_data
    ,p_object_type_code             => p_rule_rec.act_rate_obj_type_code
    ,p_source_table_query           => l_source_table_query_stmt
    ,p_source_table_query_param1    => l_source_table_query_param1
    ,p_source_table_query_param2    => l_source_table_query_param2
    ,p_source_table_alias           => 'act'
    ,p_target_table_name            => 'FEM_BALANCES'
    ,p_target_table_alias           => 'b'
    ,p_target_dsg_where_clause      => p_input_ds_b_where_clause
    ,p_ledger_id                    => p_request_rec.ledger_id
  );

  -- Check the return status after calling FEM_COMPOSITE_DIM_UTILS_PVT API's
  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
    Get_Put_Messages (
      p_msg_count => l_msg_count
      ,p_msg_data => l_msg_data
    );
    raise l_calc_act_rate_error;
  end if;

  ------------------------------------------------------------------------------
  -- STEP 2: Bulk Insert into Balances Table
  ------------------------------------------------------------------------------

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'Step 2:  Bulk Insert into FEM_BALANCES Table'
  );


  -- l_drv_vals_tbl_where_clause cannot have aliases, otherwise
  -- FEM_MULTI_PROC_PKG throws exception when building data slices.
  l_drv_vals_tbl_where_clause :=
  ' created_by_request_id = '||p_request_rec.request_id||
  ' and created_by_object_id = '||p_rule_rec.act_rate_obj_id;

  IF ((p_rule_rec.entered_exch_rate_den IS NOT NULL) AND (p_rule_rec.entered_exch_rate_num IS NOT NULL)) THEN

  l_act_rate_stmt :=
  ' insert into FEM_BALANCES ('||
  '   dataset_code'||
  '   ,cal_period_id'||
  '   ,creation_row_sequence'||
  '   ,source_system_code'||
  '   ,currency_code'||
  '   ,currency_type_code'||
  '   ,ledger_id'||
  '   ,financial_elem_id'||
  '   ,activity_id'||
  '   ,task_id'||
  '   ,product_id'||
  '   ,company_cost_center_org_id'||
  '   ,customer_id'||
  '   ,channel_id'||
  '   ,project_id'||
  '   ,user_dim1_id'||
  '   ,user_dim2_id'||
  '   ,user_dim3_id'||
  '   ,user_dim4_id'||
  '   ,user_dim5_id'||
  '   ,user_dim6_id'||
  '   ,user_dim7_id'||
  '   ,user_dim8_id'||
  '   ,user_dim9_id'||
  '   ,user_dim10_id'||
  '   ,natural_account_id'||
  '   ,line_item_id'||
  '   ,entity_id'||
  '   ,intercompany_id'||
  '   ,created_by_request_id'||
  '   ,created_by_object_id'||
  '   ,last_updated_by_request_id'||
  '   ,last_updated_by_object_id'||
  '   ,xtd_balance_e'||
  '   ,xtd_balance_f'||
  ' )'||
  ' select '||p_request_rec.output_dataset_code||
  ' ,'||p_request_rec.output_cal_period_id||
  ' ,'||p_rule_rec.rate_sequence_name||'.NEXTVAL'||
  ' ,'||p_request_rec.source_system_code||
  ' ,'''||p_rule_rec.entered_currency_code||''''||
  ' ,currency_type_code'||
  ' ,ledger_id'||
  ' ,'||G_FIN_ELEM_ID_ACTIVITY_RATE||
  ' ,activity_id'||
  ' ,task_id'||
  ' ,product_id'||
  ' ,company_cost_center_org_id'||
  ' ,customer_id'||
  ' ,channel_id'||
  ' ,project_id'||
  ' ,user_dim1_id'||
  ' ,user_dim2_id'||
  ' ,user_dim3_id'||
  ' ,user_dim4_id'||
  ' ,user_dim5_id'||
  ' ,user_dim6_id'||
  ' ,user_dim7_id'||
  ' ,user_dim8_id'||
  ' ,user_dim9_id'||
  ' ,user_dim10_id'||
  ' ,natural_account_id'||
  ' ,statistic_basis_id'||
  ' ,entity_id'||
  ' ,intercompany_id'||
  ' ,'||p_request_rec.request_id||
  ' ,'||p_rule_rec.act_rate_obj_id||
  ' ,'||p_request_rec.request_id||
  ' ,'||p_rule_rec.act_rate_obj_id||
  ' ,act_rate_value / '||p_rule_rec.entered_exch_rate_den||' * '||p_rule_rec.entered_exch_rate_num||
  ' ,act_rate_value'||
  ' from ('||
  '   select b.currency_type_code'||
  '   ,b.ledger_id'||
  '   ,b.activity_id'||
  '   ,b.task_id'||
  '   ,b.product_id'||
  '   ,b.company_cost_center_org_id'||
  '   ,b.customer_id'||
  '   ,b.channel_id'||
  '   ,b.project_id'||
  '   ,b.user_dim1_id'||
  '   ,b.user_dim2_id'||
  '   ,b.user_dim3_id'||
  '   ,b.user_dim4_id'||
  '   ,b.user_dim5_id'||
  '   ,b.user_dim6_id'||
  '   ,b.user_dim7_id'||
  '   ,b.user_dim8_id'||
  '   ,b.user_dim9_id'||
  '   ,b.user_dim10_id'||
  '   ,b.natural_account_id'||
  '   ,max(drv.statistic_basis_id) as statistic_basis_id'||
  '   ,b.entity_id'||
  '   ,b.intercompany_id'||
  '   ,sum(b.xtd_balance_f) / max(abs(drv.driver_value)) as act_rate_value'||
  '   from fem_balances b'||
  '   ,pft_ar_driver_values_t {{table_partition}} drv'||
  '   where b.ledger_id = '||p_request_rec.ledger_id||
  '   and b.financial_elem_id not in ('||G_FIN_ELEM_ID_STATISTIC||','||G_FIN_ELEM_ID_ACTIVITY_RATE||')'||
  '   and b.currency_type_code = ''ENTERED'''||
  '   and '||p_input_ds_b_where_clause||
  '   and not ('||
  '     b.created_by_request_id = '||p_request_rec.request_id||
  '     and b.created_by_object_id = '||p_rule_rec.act_rate_obj_id||
  '   )'||
  '   and drv.activity_id = b.activity_id'||
  -- l_drv_vals_tbl_where_clause with aliases (start)
  '   and drv.created_by_request_id = '||p_request_rec.request_id||
  '   and drv.created_by_object_id = '||p_rule_rec.act_rate_obj_id||
  -- l_drv_vals_tbl_where_clause with aliases (end)
  '   and {{data_slice}} '||
  '   group by b.currency_type_code'||
  '   ,b.currency_type_code'||
  '   ,b.ledger_id'||
  '   ,b.activity_id'||
  '   ,b.task_id'||
  '   ,b.product_id'||
  '   ,b.company_cost_center_org_id'||
  '   ,b.customer_id'||
  '   ,b.channel_id'||
  '   ,b.project_id'||
  '   ,b.user_dim1_id'||
  '   ,b.user_dim2_id'||
  '   ,b.user_dim3_id'||
  '   ,b.user_dim4_id'||
  '   ,b.user_dim5_id'||
  '   ,b.user_dim6_id'||
  '   ,b.user_dim7_id'||
  '   ,b.user_dim8_id'||
  '   ,b.user_dim9_id'||
  '   ,b.user_dim10_id'||
  '   ,b.natural_account_id'||
-- Bug fix 4619775 - ammittal 10/07/05 - The code has been commented
-- to avoid grouping by line item id as the statistic basis id from
-- drivers table is always used in the select statement
--  '   ,b.line_item_id'||
  '   ,b.entity_id'||
  '   ,b.intercompany_id'||
  ' )';

  ELSE

    l_act_rate_stmt :=
  ' insert into FEM_BALANCES ('||
  '   dataset_code'||
  '   ,cal_period_id'||
  '   ,creation_row_sequence'||
  '   ,source_system_code'||
  '   ,currency_code'||
  '   ,currency_type_code'||
  '   ,ledger_id'||
  '   ,financial_elem_id'||
  '   ,activity_id'||
  '   ,task_id'||
  '   ,product_id'||
  '   ,company_cost_center_org_id'||
  '   ,customer_id'||
  '   ,channel_id'||
  '   ,project_id'||
  '   ,user_dim1_id'||
  '   ,user_dim2_id'||
  '   ,user_dim3_id'||
  '   ,user_dim4_id'||
  '   ,user_dim5_id'||
  '   ,user_dim6_id'||
  '   ,user_dim7_id'||
  '   ,user_dim8_id'||
  '   ,user_dim9_id'||
  '   ,user_dim10_id'||
  '   ,natural_account_id'||
  '   ,line_item_id'||
  '   ,entity_id'||
  '   ,intercompany_id'||
  '   ,created_by_request_id'||
  '   ,created_by_object_id'||
  '   ,last_updated_by_request_id'||
  '   ,last_updated_by_object_id'||
  '   ,xtd_balance_e'||
  '   ,xtd_balance_f'||
  ' )'||
  ' select '||p_request_rec.output_dataset_code||
  ' ,'||p_request_rec.output_cal_period_id||
  ' ,'||p_rule_rec.rate_sequence_name||'.NEXTVAL'||
  ' ,'||p_request_rec.source_system_code||
  ' ,'''||p_rule_rec.entered_currency_code||''''||
  ' ,currency_type_code'||
  ' ,ledger_id'||
  ' ,'||G_FIN_ELEM_ID_ACTIVITY_RATE||
  ' ,activity_id'||
  ' ,task_id'||
  ' ,product_id'||
  ' ,company_cost_center_org_id'||
  ' ,customer_id'||
  ' ,channel_id'||
  ' ,project_id'||
  ' ,user_dim1_id'||
  ' ,user_dim2_id'||
  ' ,user_dim3_id'||
  ' ,user_dim4_id'||
  ' ,user_dim5_id'||
  ' ,user_dim6_id'||
  ' ,user_dim7_id'||
  ' ,user_dim8_id'||
  ' ,user_dim9_id'||
  ' ,user_dim10_id'||
  ' ,natural_account_id'||
  ' ,statistic_basis_id'||
  ' ,entity_id'||
  ' ,intercompany_id'||
  ' ,'||p_request_rec.request_id||
  ' ,'||p_rule_rec.act_rate_obj_id||
  ' ,'||p_request_rec.request_id||
  ' ,'||p_rule_rec.act_rate_obj_id||
  ' ,null'||
  ' ,act_rate_value'||
  ' from ('||
  '   select b.currency_type_code'||
  '   ,b.ledger_id'||
  '   ,b.activity_id'||
  '   ,b.task_id'||
  '   ,b.product_id'||
  '   ,b.company_cost_center_org_id'||
  '   ,b.customer_id'||
  '   ,b.channel_id'||
  '   ,b.project_id'||
  '   ,b.user_dim1_id'||
  '   ,b.user_dim2_id'||
  '   ,b.user_dim3_id'||
  '   ,b.user_dim4_id'||
  '   ,b.user_dim5_id'||
  '   ,b.user_dim6_id'||
  '   ,b.user_dim7_id'||
  '   ,b.user_dim8_id'||
  '   ,b.user_dim9_id'||
  '   ,b.user_dim10_id'||
  '   ,b.natural_account_id'||
  '   ,max(drv.statistic_basis_id) as statistic_basis_id'||
  '   ,b.entity_id'||
  '   ,b.intercompany_id'||
  '   ,sum(b.xtd_balance_f) / max(abs(drv.driver_value)) as act_rate_value'||
  '   from fem_balances b'||
  '   ,pft_ar_driver_values_t {{table_partition}} drv'||
  '   where b.ledger_id = '||p_request_rec.ledger_id||
  '   and b.financial_elem_id not in ('||G_FIN_ELEM_ID_STATISTIC||','||G_FIN_ELEM_ID_ACTIVITY_RATE||')'||
  '   and b.currency_type_code = ''ENTERED'''||
  '   and '||p_input_ds_b_where_clause||
  '   and not ('||
  '     b.created_by_request_id = '||p_request_rec.request_id||
  '     and b.created_by_object_id = '||p_rule_rec.act_rate_obj_id||
  '   )'||
  '   and drv.activity_id = b.activity_id'||
  -- l_drv_vals_tbl_where_clause with aliases (start)
  '   and drv.created_by_request_id = '||p_request_rec.request_id||
  '   and drv.created_by_object_id = '||p_rule_rec.act_rate_obj_id||
  -- l_drv_vals_tbl_where_clause with aliases (end)
  '   and {{data_slice}} '||
  '   group by b.currency_type_code'||
  '   ,b.currency_type_code'||
  '   ,b.ledger_id'||
  '   ,b.activity_id'||
  '   ,b.task_id'||
  '   ,b.product_id'||
  '   ,b.company_cost_center_org_id'||
  '   ,b.customer_id'||
  '   ,b.channel_id'||
  '   ,b.project_id'||
  '   ,b.user_dim1_id'||
  '   ,b.user_dim2_id'||
  '   ,b.user_dim3_id'||
  '   ,b.user_dim4_id'||
  '   ,b.user_dim5_id'||
  '   ,b.user_dim6_id'||
  '   ,b.user_dim7_id'||
  '   ,b.user_dim8_id'||
  '   ,b.user_dim9_id'||
  '   ,b.user_dim10_id'||
  '   ,b.natural_account_id'||
-- Bug fix 4619775 - ammittal 10/07/05 - The code has been commented
-- to avoid grouping by line item id as the statistic basis id from
-- drivers table is always used in the select statement
--  '   ,b.line_item_id'||
  '   ,b.entity_id'||
  '   ,b.intercompany_id'||
  ' )';


  END IF;

  -- Register Object Execution Step
  Register_Obj_Exec_Step (
    p_request_rec       => p_request_rec
    ,p_rule_rec         => p_rule_rec
    ,p_exec_step        => L_CALC_ACT_RATE_VALUES
    ,p_exec_status_code => G_EXEC_STATUS_RUNNING
  );

  -- Call MP API if MP is enabled, otherwise execute SQL directly
  if (G_MP_ENABLED) then

    -- Call MP Master (Pull Processing)
    FEM_MULTI_PROC_PKG.Master (
      x_prg_stat        => l_mp_prog_status
      ,x_exception_code => l_mp_exception_code
      ,p_rule_id        => p_rule_rec.act_rate_obj_id
      ,p_eng_step       => L_CALC_ACT_RATE_VALUES
      ,p_data_table     => 'PFT_AR_DRIVER_VALUES_T'
      ,p_eng_sql        => l_act_rate_stmt
      ,p_table_alias    => 'drv'
      ,p_run_name       => L_CALC_ACT_RATE_VALUES
      ,p_eng_prg        => null
      ,p_condition      => l_drv_vals_tbl_where_clause
      ,p_failed_req_id  => null
      ,p_reuse_slices   => 'N' -- New data slice
    );

  else

    -- Replace the data slice and table partition tokens
    l_act_rate_stmt := REPLACE(l_act_rate_stmt,'{{data_slice}}',' 1=1 ');
    l_act_rate_stmt := REPLACE(l_act_rate_stmt,'{{table_partition}}',' ');

    execute immediate l_act_rate_stmt;

  end if;

  if (l_mp_prog_status <> G_COMPLETE_NORMAL) then

    if (l_mp_exception_code is not null) then
      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => l_mp_exception_code
      );
    end if;

    Update_Obj_Exec_Step_Status(
      p_request_rec       => p_request_rec
      ,p_rule_rec         => p_rule_rec
      ,p_exec_step        => L_CALC_ACT_RATE_VALUES
      ,p_exec_status_code => G_EXEC_STATUS_ERROR_UNDO
    );

    raise l_calc_act_rate_error;

  else

    Update_Obj_Exec_Step_Status(
      p_request_rec       => p_request_rec
      ,p_rule_rec         => p_rule_rec
      ,p_exec_step        => L_CALC_ACT_RATE_VALUES
      ,p_exec_status_code => G_EXEC_STATUS_SUCCESS
    );

  end if;

  commit;

  if (G_MP_ENABLED) then
    -- Purge Data Slices
    FEM_MULTI_PROC_PKG.Delete_Data_Slices (
      p_req_id => p_request_rec.request_id
    );
  end if;

  ------------------------------------------------------------------------------
  -- STEP 3: Bulk Insert into FEM_BALANCES_CALC_FCTRS Table
  ------------------------------------------------------------------------------

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'Step 3:  Bulk Insert into FEM_BALANCES_CALC_FCTRS Table'
  );

  -- Prepare the insert statement for FEM_BALANCES_CALC_FCTRS
  -- ammittal 03/30/06 - Bug # 5074996 - Updating the code below to uptake changes in FEM_BALANCES_CALC_FCTRS table
  l_calc_fctrs_stmt :=
  ' insert into FEM_BALANCES_CALC_FCTRS ('||
  '   created_by_request_id'||
  '   ,created_by_object_id'||
  '   ,creation_row_sequence'||
  '   ,factor'||
  '   ,output_type'||
  '   ,last_updated_by_object_id'||
  '   ,last_updated_by_request_id'||
  ' )'||
  ' select b.created_by_request_id'||
  ' ,b.created_by_object_id'||
  ' ,b.creation_row_sequence'||
  ' ,1/drv.driver_value'||
  ' ,''N/A'''||
  ' ,b.last_updated_by_object_id'||
  ' ,b.last_updated_by_request_id'||
  ' from fem_balances b'||
  ' ,pft_ar_driver_values_t {{table_partition}} drv'||
  ' where b.ledger_id = '||p_request_rec.ledger_id||
  ' and b.dataset_code = '||p_request_rec.output_dataset_code||
  ' and b.cal_period_id = '||p_request_rec.output_cal_period_id||
  ' and b.created_by_request_id = drv.created_by_request_id'||
  ' and b.created_by_object_id = drv.created_by_object_id'||
  ' and drv.activity_id = b.activity_id'||
  -- l_drv_vals_tbl_where_clause with aliases (start)
  ' and drv.created_by_request_id = '||p_request_rec.request_id||
  ' and drv.created_by_object_id = '||p_rule_rec.act_rate_obj_id||
  -- l_drv_vals_tbl_where_clause with aliases (end)
  ' and {{data_slice}} ';

  -- Register Object Execution Step
  Register_Obj_Exec_Step (
    p_request_rec       => p_request_rec
    ,p_rule_rec         => p_rule_rec
    ,p_exec_step        => L_CALC_ACT_RATE_FACTORS
    ,p_exec_status_code => G_EXEC_STATUS_RUNNING
  );

  -- Call MP API if MP is enabled, otherwise execute SQL directly
  if (G_MP_ENABLED) then

    -- Call MP Master (Pull Processing)
    FEM_MULTI_PROC_PKG.Master (
      x_prg_stat        => l_mp_prog_status
      ,x_exception_code => l_mp_exception_code
      ,p_rule_id        => p_rule_rec.act_rate_obj_id
      ,p_eng_step       => L_CALC_ACT_RATE_FACTORS
      ,p_data_table     => 'PFT_AR_DRIVER_VALUES_T'
      ,p_eng_sql        => l_calc_fctrs_stmt
      ,p_table_alias    => 'drv'
      ,p_run_name       => L_CALC_ACT_RATE_FACTORS
      ,p_eng_prg        => null
      ,p_condition      => l_drv_vals_tbl_where_clause
      ,p_failed_req_id  => null
      ,p_reuse_slices   => 'N' -- New data slice
    );

  else

    -- Replace the data slice and table partition tokens
    l_calc_fctrs_stmt := REPLACE(l_calc_fctrs_stmt,'{{data_slice}}',' 1=1 ');
    l_calc_fctrs_stmt := REPLACE(l_calc_fctrs_stmt,'{{table_partition}}',' ');

    execute immediate l_calc_fctrs_stmt;

  end if;

  if (l_mp_prog_status <> G_COMPLETE_NORMAL) then

    if (l_mp_exception_code is not null) then
      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => l_mp_exception_code
      );
    end if;

    Update_Obj_Exec_Step_Status(
      p_request_rec       => p_request_rec
      ,p_rule_rec         => p_rule_rec
      ,p_exec_step        => L_CALC_ACT_RATE_FACTORS
      ,p_exec_status_code => G_EXEC_STATUS_ERROR_UNDO
    );

    raise l_calc_act_rate_error;

  else

    Update_Obj_Exec_Step_Status(
      p_request_rec       => p_request_rec
      ,p_rule_rec         => p_rule_rec
      ,p_exec_step        => L_CALC_ACT_RATE_FACTORS
      ,p_exec_status_code => G_EXEC_STATUS_SUCCESS
    );

  end if;

  commit;

  if (G_MP_ENABLED) then
    -- Purge Data Slices
    FEM_MULTI_PROC_PKG.Delete_Data_Slices (
      p_req_id => p_request_rec.request_id
    );
  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_calc_act_rate_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => g_log_level_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Calculate Activity Rate Exception'
    );

    raise g_act_rate_request_error;

END Calc_Act_Rate;



/*===========================================================================+
 | PROCEDURE
 |   Rule_Prep
 |
 | DESCRIPTION
 |   Rule Preperation
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

PROCEDURE Rule_Prep (
  p_request_rec                   in request_record
  ,p_act_rate_obj_id              in number
  ,p_act_rate_obj_def_id          in number
  ,p_act_rate_sequence            in number
  ,x_rule_rec                     out nocopy rule_record
)
IS

  L_API_NAME             constant varchar2(30) := 'Rule_Prep';

  l_dimension_id                  number;

  l_rule_prep_error               exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'BEGIN'
  );

  x_rule_rec.act_rate_obj_id := p_act_rate_obj_id;
  x_rule_rec.act_rate_obj_def_id := p_act_rate_obj_def_id;
  x_rule_rec.act_rate_sequence := p_act_rate_sequence;

  ------------------------------------------------------------------------------
  -- Get the object info from FEM_OBJECT_CATALOG_B for the activity rate Object ID.
  ------------------------------------------------------------------------------
  begin
    select object_type_code
    ,object_name
    ,local_vs_combo_id
    into x_rule_rec.act_rate_obj_type_code
    ,x_rule_rec.act_rate_obj_name
    ,x_rule_rec.local_vs_combo_id
    from fem_object_catalog_vl
    where object_id = x_rule_rec.act_rate_obj_id;
  exception
    when others then
      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_ENG_NO_ACT_RATE_OBJ_ERR
        ,p_token1   => 'OBJECT_ID'
        ,p_value1   => x_rule_rec.act_rate_obj_id
      );
      raise l_rule_prep_error;
  end;

  ------------------------------------------------------------------------------
  -- If this is a Rule Set Submission, check that the object_type_code and
  -- local_vs_combo_id of the activity rate rule matches the Rule Set's.
  ------------------------------------------------------------------------------
  if (p_request_rec.submit_obj_type_code = 'RULE_SET') then

      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_ENG_RS_RULE_PROCESSING_TXT
        ,p_token1   => 'RULE_NAME'
        ,p_value1   => x_rule_rec.act_rate_obj_name
      );

    if (p_request_rec.act_rate_obj_type_code <> x_rule_rec.act_rate_obj_type_code) then

      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_ENG_BAD_RS_OBJ_TYPE_ERR
        ,p_token1   => 'OBJECT_TYPE_CODE'
        ,p_value1   => p_request_rec.act_rate_obj_type_code
      );
      raise l_rule_prep_error;

    end if;

    if (p_request_rec.local_vs_combo_id <> x_rule_rec.local_vs_combo_id) then

      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_ENG_RS_BAD_LCL_VS_COMBO_ERR
        ,p_token1   => 'OBJECT_TYPE_MEANING'
        ,p_value1   => Get_Lookup_Meaning('FEM_OBJECT_TYPE_DSC',x_rule_rec.act_rate_obj_type_code)
        ,p_token2   => 'OBJECT_ID'
        ,p_value2   => x_rule_rec.act_rate_obj_id
      );
      raise l_rule_prep_error;

    end if;

  end if;

  ------------------------------------------------------------------------------
  -- Get the Activity Rate Object Definition ID
  ------------------------------------------------------------------------------
  if (x_rule_rec.act_rate_obj_def_id is null) then

    Get_Object_Definition (
      p_object_type_code => x_rule_rec.act_rate_obj_type_code
      ,p_object_id       => x_rule_rec.act_rate_obj_id
      ,p_effective_date  => p_request_rec.effective_date
      ,x_obj_def_id      => x_rule_rec.act_rate_obj_def_id
    );

  end if;

  begin
    select activity_hier_obj_id,
           currency_code,
           condition_obj_id,
           top_nodes_flag,
           output_to_rate_stat_flag
      into x_rule_rec.hier_obj_id
           ,x_rule_rec.entered_currency_code
           ,x_rule_rec.cond_obj_id
           ,x_rule_rec.top_node_flag
           ,x_rule_rec.output_to_rate_stat_flag
      from PFT_ACTIVITY_RATES
     where activity_rate_obj_def_id = x_rule_rec.act_rate_obj_def_id;
  exception
    when others then
      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_ENG_NO_ACT_RATE_OBJ_DTL_ERR
        ,p_token1   => 'TABLE_NAME'
        ,p_value1   => 'PFT_ACTIVITY_RATES'
        ,p_token2   => 'OBJECT_TYPE_MEANING'
        ,p_value2   => Get_Lookup_Meaning('FEM_OBJECT_TYPE_DSC',x_rule_rec.act_rate_obj_type_code)
        ,p_token3   => 'OBJECT_ID'
        ,p_value3   => x_rule_rec.act_rate_obj_id
        ,p_token4   => 'OBJECT_DEF_ID'
        ,p_value4   => x_rule_rec.act_rate_obj_def_id
      );
      raise l_rule_prep_error;
  end;
  ------------------------------------------------------------------------------
  -- Get the Hierarchy Object Definition ID
  ------------------------------------------------------------------------------
  Get_Object_Definition (
    p_object_type_code => 'HIERARCHY'
    ,p_object_id       => x_rule_rec.hier_obj_id
    ,p_effective_date  => p_request_rec.effective_date
    ,x_obj_def_id      => x_rule_rec.hier_obj_def_id
  );

  ------------------------------------------------------------------------------
  -- Get the Condition Object Definition ID (if specified)
  ------------------------------------------------------------------------------
  x_rule_rec.cond_exists := (x_rule_rec.cond_obj_id is not null);
  if (x_rule_rec.cond_exists) then

    Get_Object_Definition (
      p_object_type_code => 'CONDITION'
      ,p_object_id       => x_rule_rec.cond_obj_id
      ,p_effective_date  => p_request_rec.effective_date
      ,x_obj_def_id      => x_rule_rec.cond_obj_def_id
    );

  end if;

  ------------------------------------------------------------------------------
  -- Get Dimension Id from FEM_HIERARCHIES
  ------------------------------------------------------------------------------
  begin
    select h.dimension_id
    into l_dimension_id
    from fem_hierarchies h
    where h.hierarchy_obj_id = x_rule_rec.hier_obj_id;
  exception
    when others then
      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_ENG_NO_OBJ_DTL_ERR
        ,p_token1   => 'TABLE_NAME'
        ,p_value1   => 'FEM_HIERARCHIES'
        ,p_token2   => 'OBJECT_TYPE_MEANING'
        ,p_value2   => Get_Lookup_Meaning('FEM_OBJECT_TYPE_DSC',x_rule_rec.act_rate_obj_type_code)
        ,p_token3   => 'OBJECT_ID'
        ,p_value3   => x_rule_rec.hier_obj_id
      );
    raise l_rule_prep_error;
  end;

  -- Check that the dimension Id matches that of the Request
  if (p_request_rec.dimension_rec.dimension_id <> l_dimension_id) then

      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_ENG_BAD_HIER_DIM_ERR
        ,p_token1   => 'OBJECT_TYPE_MEANING'
        ,p_value1   => Get_Lookup_Meaning('FEM_OBJECT_TYPE_DSC',x_rule_rec.act_rate_obj_type_code)
        ,p_token2   => 'OBJECT_ID'
        ,p_value2   => x_rule_rec.act_rate_obj_id
        ,p_token3   => 'OBJECT_DEF_ID'
        ,p_value3   => x_rule_rec.act_rate_obj_def_id
      );
      raise l_rule_prep_error;

  end if;

  ------------------------------------------------------------------------------
  -- Set the Temporary Sequence Names for performing Processing in the
  -- FEM_BALANCES table.
  ------------------------------------------------------------------------------
  x_rule_rec.rate_sequence_name :=
    'pft_ar_rate_'||
    to_char(p_request_rec.request_id)||
    '_'||
    to_char(x_rule_rec.act_rate_sequence)||
    '_s';

  x_rule_rec.drv_sequence_name :=
    'pft_ar_drv_'||
    to_char(p_request_rec.request_id)||
    '_'||
    to_char(x_rule_rec.act_rate_sequence)||
    '_s';

  ------------------------------------------------------------------------------
  -- Set the Entered Currency Code and Exchange Rate params
  ------------------------------------------------------------------------------
  if (p_request_rec.entered_currency_flag = 'N') then

    -- Set the Entered Currency to the Ledger's Functional Currency as the
    -- Ledger does not allow Entered Balances.
    -- Also default the exchange rate to null, so that all entered balances will
    -- result to null.
    x_rule_rec.entered_currency_code := p_request_rec.functional_currency_code;
    x_rule_rec.entered_exch_rate_num := null;
    x_rule_rec.entered_exch_rate_den := null;
    x_rule_rec.entered_exch_rate := null;

  else

    -- ammittal todo: find what the "Functional" currency code string value will be.
    if (x_rule_rec.entered_currency_code = 'FUNCTIONAL' ) then

      -- Set the Entered Currency to the Ledger's Functional Currency
      -- Also default the exchange rate to 1.
      x_rule_rec.entered_currency_code := p_request_rec.functional_currency_code;
      x_rule_rec.entered_exch_rate_num := 1;
      x_rule_rec.entered_exch_rate_den := 1;
      x_rule_rec.entered_exch_rate := 1;

    else

      if (x_rule_rec.entered_currency_code = p_request_rec.functional_currency_code) then

        -- Default the exchange rate to 1 as the Entered Currency is the same as
        -- the Ledger's Functional Currency
        x_rule_rec.entered_exch_rate_num := 1;
        x_rule_rec.entered_exch_rate_den := 1;
        x_rule_rec.entered_exch_rate := 1;

      else

        begin
          GL_CURRENCY_API.Get_Triangulation_Rate (
            x_from_currency    => p_request_rec.functional_currency_code
            ,x_to_currency     => x_rule_rec.entered_currency_code
            ,x_conversion_date => p_request_rec.entered_exch_rate_date
            ,x_conversion_type => g_currency_conv_type
            ,x_numerator       => x_rule_rec.entered_exch_rate_num
            ,x_denominator     => x_rule_rec.entered_exch_rate_den
            ,x_rate            => x_rule_rec.entered_exch_rate
          );
        exception
          when GL_CURRENCY_API.NO_RATE then
            FEM_ENGINES_PKG.User_Message (
              p_app_name  => G_FEM
              ,p_msg_name => G_ENG_NO_EXCH_RATE_FOUND_ERR
              ,p_token1   => 'FROM_CURRENCY_CODE'
              ,p_value1   => p_request_rec.functional_currency_code
              ,p_token2   => 'TO_CURRENCY_CODE'
              ,p_value2   => x_rule_rec.entered_currency_code
              ,p_token3   => 'CONVERSION_DATE'
              ,p_value3   => FND_DATE.date_to_chardate(p_request_rec.entered_exch_rate_date)
              ,p_token4   => 'CONVERSION_TYPE'
              ,p_value4   => g_currency_conv_type
            );
            raise l_rule_prep_error;

          when GL_CURRENCY_API.INVALID_CURRENCY then
            FEM_ENGINES_PKG.User_Message (
              p_app_name  => G_FEM
              ,p_msg_name => G_ENG_BAD_CURRENCY_ERR
              ,p_token1   => 'FROM_CURRENCY_CODE'
              ,p_value1   => p_request_rec.functional_currency_code
              ,p_token2   => 'TO_CURRENCY_CODE'
              ,p_value2   => x_rule_rec.entered_currency_code
              ,p_token3   => 'CONVERSION_DATE'
              ,p_value3   => FND_DATE.date_to_chardate(p_request_rec.entered_exch_rate_date)
              ,p_token4   => 'CONVERSION_TYPE'
              ,p_value4   => g_currency_conv_type
            );
            raise l_rule_prep_error;

        end;

      end if;

    end if;

  end if;

  -- Log all Rule Record Parameters if we have low level debugging
  if ( FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) ) then


    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||L_API_NAME||'.x_rule_rec'
      ,p_msg_text =>
        ' act_rate_obj_id='||x_rule_rec.act_rate_obj_id||
        ' act_rate_obj_def_id='||x_rule_rec.act_rate_obj_def_id||
        ' act_rate_obj_type_code ='||x_rule_rec.act_rate_obj_type_code||
        ' act_rate_sequence ='||x_rule_rec.act_rate_sequence||
        ' cond_obj_def_id ='||x_rule_rec.cond_obj_def_id||
        ' cond_obj_id ='||x_rule_rec.cond_obj_id||
        ' entered_currency_code ='||x_rule_rec.entered_currency_code ||
        ' entered_exch_rate ='||x_rule_rec.entered_exch_rate ||
        ' entered_exch_rate_den ='||x_rule_rec.entered_exch_rate_den ||
        ' entered_exch_rate_num ='||x_rule_rec.entered_exch_rate_num ||
        ' hier_obj_def_id ='||x_rule_rec.hier_obj_def_id ||
        ' local_vs_combo_id ='||x_rule_rec.local_vs_combo_id ||
        ' rate_sequence_name ='||x_rule_rec.rate_sequence_name ||
        ' drv_sequence_name ='||x_rule_rec.drv_sequence_name ||
        ' output_to_rate_stat_flag ='||x_rule_rec.output_to_rate_stat_flag ||
        ' top_node_flag ='||x_rule_rec.top_node_flag
    );

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||l_api_name||'.x_rule_rec'
      ,p_msg_text => null
    );

  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_rule_prep_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => g_log_level_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Rule Preparation Exception'
    );

    raise g_act_rate_request_error;

END Rule_Prep;



/*===========================================================================+
 | PROCEDURE
 |   Register_Rule
 |
 | DESCRIPTION
 |   Register Objects - Called from Act_Rate_Rule
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

PROCEDURE Register_Rule (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
)
IS

  L_API_NAME             constant varchar2(30) := 'Register_Rule';

  l_exec_state                    varchar2(30); -- normal, restart, rerun
  l_prev_request_id               number;

  l_return_status                 varchar2(1);
  l_msg_count                     number;
  l_msg_data                      varchar2(240);

  l_register_rule_error           exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'BEGIN'
  );

  savepoint register_rule_pub;

  -- Call the FEM_PL_PKG.Register_Object_Execution API procedure to register
  -- the activity rate object execution in FEM_PL_OBJECT_EXECUTIONS, thus obtaining
  -- an execution lock.
  FEM_PL_PKG.Register_Object_Execution (
    p_api_version                => 1.0
    ,p_commit                    => FND_API.G_FALSE
    ,p_request_id                => p_request_rec.request_id
    ,p_object_id                 => p_rule_rec.act_rate_obj_id
    ,p_exec_object_definition_id => p_rule_rec.act_rate_obj_def_id
    ,p_user_id                   => p_request_rec.user_id
    ,p_last_update_login         => p_request_rec.login_id
    ,p_exec_mode_code            => null
    ,x_exec_state                => l_exec_state
    ,x_prev_request_id           => l_prev_request_id
    ,x_msg_count                 => l_msg_count
    ,x_msg_data                  => l_msg_data
    ,x_return_status             => l_return_status
  );

  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
    Get_Put_Messages (
      p_msg_count => l_msg_count
      ,p_msg_data => l_msg_data
    );
    raise l_register_rule_error;
  end if;

  -- Register the Dataset Group Object Definition
  Register_Object_Definition (
    p_request_rec => p_request_rec
    ,p_rule_rec   => p_rule_rec
    ,p_obj_def_id => p_request_rec.dataset_grp_obj_def_id
  );

  -- Register all the Dependent Objects for the activity rate Object Definition
  FEM_PL_PKG.Register_Dependent_ObjDefs (
    p_api_version                => 1.0
    ,p_commit                    => FND_API.G_FALSE
    ,p_request_id                => p_request_rec.request_id
    ,p_object_id                 => p_rule_rec.act_rate_obj_id
    ,p_exec_object_definition_id => p_rule_rec.act_rate_obj_def_id
    ,p_effective_date            => p_request_rec.effective_date
    ,p_user_id                   => p_request_rec.user_id
    ,p_last_update_login         => p_request_rec.login_id
    ,x_msg_count                 => l_msg_count
    ,x_msg_data                  => l_msg_data
    ,x_return_status             => l_return_status
  );

  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
    Get_Put_Messages (
      p_msg_count => l_msg_count
      ,p_msg_data => l_msg_data
    );
    raise l_register_rule_error;
  end if;

  -- Register the data location for the FEM_BALANCES output table
  FEM_DIMENSION_UTIL_PKG.Register_Data_Location (
    p_request_id   => p_request_rec.request_id
    ,p_object_id   => p_rule_rec.act_rate_obj_id
    ,p_table_name  => 'FEM_BALANCES'
    ,p_ledger_id   => p_request_rec.ledger_id
    ,p_cal_per_id  => p_request_rec.output_cal_period_id
    ,p_dataset_cd  => p_request_rec.output_dataset_code
    ,p_source_cd   => p_request_rec.source_system_code
    ,p_load_status => null
  );

  -- Register the FEM_BALANCES output table as INSERT so that Undo will
  -- delete all output records
  Register_Table (
    p_request_rec     => p_request_rec
    ,p_rule_rec       => p_rule_rec
    ,p_table_name     => 'FEM_BALANCES'
    ,p_statement_type => 'INSERT'
  );

  -- Register the PFT_AR_DRIVERS_T processing table as INSERT.  This is needed
  -- in the event of a engine failure where the only way to purge these records
  -- is through the Undo Process
  Register_Table (
    p_request_rec     => p_request_rec
    ,p_rule_rec       => p_rule_rec
    ,p_table_name     => 'PFT_AR_DRIVERS_T'
    ,p_statement_type => 'INSERT'
  );

  -- Register the PFT_AR_DRIVER_VALUES_T processing table as INSERT.  This is needed
  -- in the event of a engine failure where the only way to purge these records
  -- is through the Undo Process
  Register_Table (
    p_request_rec     => p_request_rec
    ,p_rule_rec       => p_rule_rec
    ,p_table_name     => 'PFT_AR_DRIVER_VALUES_T'
    ,p_statement_type => 'INSERT'
  );

  commit;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_register_rule_error then

    rollback to register_rule_pub;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Register Rule Exception'
    );

    raise g_act_rate_request_error;

  when g_act_rate_request_error then

    rollback to register_rule_pub;
    raise g_act_rate_request_error;

  when others then

    rollback to register_rule_pub;
    raise;

END Register_Rule;



/*===========================================================================+
 | PROCEDURE
 |   Register_Object_Definition
 |
 | DESCRIPTION
 |   Register Object Definition - Called from Act_Rate_Rule
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

PROCEDURE Register_Object_Definition (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
  ,p_obj_def_id                   in number
)
IS

  L_API_NAME             constant varchar2(30) := 'Register_Object_Definition';

  l_return_status                 varchar2(1);
  l_msg_count                     number;
  l_msg_data                      varchar2(240);

  l_register_obj_def_error        exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'BEGIN'
  );

  -- Call the FEM_PL_PKG.Register_Object_Def API procedure to register
  -- the specified object definition in FEM_PL_OBJECT_DEFS, thus obtaining
  -- an object definition lock.
  FEM_PL_PKG.Register_Object_Def (
    p_api_version           => 1.0
    ,p_commit               => FND_API.G_FALSE
    ,p_request_id           => p_request_rec.request_id
    ,p_object_id            => p_rule_rec.act_rate_obj_id
    ,p_object_definition_id => p_obj_def_id
    ,p_user_id              => p_request_rec.user_id
    ,p_last_update_login    => p_request_rec.login_id
    ,x_msg_count            => l_msg_count
    ,x_msg_data             => l_msg_data
    ,x_return_status        => l_return_status
  );

  -- Object Definition Lock exists
  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
    Get_Put_Messages (
      p_msg_count => l_msg_count
      ,p_msg_data => l_msg_data
    );
    raise l_register_obj_def_error;
  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_register_obj_def_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => g_log_level_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Register Object Definition Exception'
    );

    raise g_act_rate_request_error;

END Register_Object_Definition;



/*===========================================================================+
 | PROCEDURE
 |   Register_Table
 |
 | DESCRIPTION
 |   Register tables
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

PROCEDURE Register_Table (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
  ,p_table_name                   in varchar2
  ,p_statement_type               in varchar2
)
IS

  L_API_NAME             constant varchar2(30) := 'Register_Table';

  l_return_status                 varchar2(1);
  l_msg_count                     number;
  l_msg_data                      varchar2(240);

  l_register_table_error          exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'BEGIN'
  );

  -- Call the FEM_PL_PKG.Register_Table API procedure to register
  -- the specified output table and the statement type that will be used.
  FEM_PL_PKG.Register_Table (
    p_api_version         => 1.0
    ,p_commit             => FND_API.G_FALSE
    ,p_request_id         => p_request_rec.request_id
    ,p_object_id          => p_rule_rec.act_rate_obj_id
    ,p_table_name         => p_table_name
    ,p_statement_type     => p_statement_type
    ,p_num_of_output_rows => 0
    ,p_user_id            => p_request_rec.user_id
    ,p_last_update_login  => p_request_rec.login_id
    ,x_msg_count          => l_msg_count
    ,x_msg_data           => l_msg_data
    ,x_return_status      => l_return_status
  );

  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
    Get_Put_Messages (
      p_msg_count => l_msg_count
      ,p_msg_data => l_msg_data
    );
    raise l_register_table_error;
  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_register_table_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => g_log_level_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Register Table Exception'
    );

    raise g_act_rate_request_error;

END Register_Table;



/*===========================================================================+
 | PROCEDURE
 |   Register_Obj_Exec_Step
 |
 | DESCRIPTION
 |   Register Object Execution Step
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

PROCEDURE Register_Obj_Exec_Step (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
  ,p_exec_step                    in varchar2
  ,p_exec_status_code             in varchar2
)
IS

  L_API_NAME             constant varchar2(30) := 'Register_Obj_Exec_Step';

  l_return_status                 varchar2(1);
  l_msg_count                     number;
  l_msg_data                      varchar2(240);

  l_register_obj_exec_step_error  exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'BEGIN'
  );

  FEM_PL_PKG.Register_Obj_Exec_Step (
    p_api_version           => 1.0
    ,p_commit               => FND_API.G_FALSE
    ,p_request_id           => p_request_rec.request_id
    ,p_object_id            => p_rule_rec.act_rate_obj_id
    ,p_exec_step            => p_exec_step
    ,p_exec_status_code     => p_exec_status_code
    ,p_user_id              => p_request_rec.user_id
    ,p_last_update_login    => p_request_rec.login_id
    ,x_msg_count            => l_msg_count
    ,x_msg_data             => l_msg_data
    ,x_return_status        => l_return_status
  );

  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
    Get_Put_Messages (
      p_msg_count => l_msg_count
      ,p_msg_data => l_msg_data
    );
    raise l_register_obj_exec_step_error;
  end if;

  commit;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_register_obj_exec_step_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => g_log_level_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Register Object Execution Step Exception'
    );

    raise g_act_rate_request_error;

END Register_Obj_Exec_Step;



/*===========================================================================+
 | PROCEDURE
 |   Update_Obj_Exec_Step_Status
 |
 | DESCRIPTION
 |   Update Object Execution Step Status
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

PROCEDURE Update_Obj_Exec_Step_Status (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
  ,p_exec_step                    in varchar2
  ,p_exec_status_code             in varchar2
)
IS

  L_API_NAME             constant varchar2(30) := 'Update_Obj_Exec_Step_Status';

  l_return_status                 varchar2(1);
  l_msg_count                     number;
  l_msg_data                      varchar2(240);

  l_upd_obj_exec_step_stat_error  exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'BEGIN'
  );

  FEM_PL_PKG.Update_Obj_Exec_Step_Status (
    p_api_version           => 1.0
    ,p_commit               => FND_API.G_FALSE
    ,p_request_id           => p_request_rec.request_id
    ,p_object_id            => p_rule_rec.act_rate_obj_id
    ,p_exec_step            => p_exec_step
    ,p_exec_status_code     => p_exec_status_code
    ,p_user_id              => p_request_rec.user_id
    ,p_last_update_login    => p_request_rec.login_id
    ,x_msg_count            => l_msg_count
    ,x_msg_data             => l_msg_data
    ,x_return_status        => l_return_status
  );

  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
    Get_Put_Messages (
      p_msg_count => l_msg_count
      ,p_msg_data => l_msg_data
    );
    raise l_upd_obj_exec_step_stat_error;
  end if;

  commit;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_upd_obj_exec_step_stat_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => g_log_level_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Register Object Execution Step Exception'
    );

    raise g_act_rate_request_error;

END Update_Obj_Exec_Step_Status;



/*===========================================================================+
 | PROCEDURE
 |   Create_Temp_Objects
 |
 | DESCRIPTION
 |   Create Temporary Objects - Sequences
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

PROCEDURE Create_Temp_Objects (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
)
IS

  L_API_NAME             constant varchar2(30) := 'Create_Temp_Objects';

  l_return_status                 varchar2(1);
  l_msg_count                     number;
  l_msg_data                      varchar2(240);

  l_create_temp_objects_error     exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'BEGIN'
  );

  ------------------------------------------------------------------------------
  -- Create Activity Rate Sequence for peforming Activity Rate Processing in
  -- FEM_BALANCES.
  ------------------------------------------------------------------------------
  begin
    -- Temporary sequence is in the default APPS schema as GSCC does not
    -- allow hardcoded schemas.
    execute immediate 'create sequence '||p_rule_rec.rate_sequence_name;
  exception
    when others then
      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_ENG_CREATE_SEQUENCE_ERR
        ,p_token1   => 'SEQUENCE_NAME'
        ,p_value1   => p_rule_rec.rate_sequence_name
      );
      raise l_create_temp_objects_error;
  end;

  -- Register Temp Sequence in PL Framework
  FEM_PL_PKG.Register_Temp_Object (
    p_api_version       => 1.0
    ,p_commit            => FND_API.G_FALSE
    ,p_request_id        => p_request_rec.request_id
    ,p_object_id         => p_rule_rec.act_rate_obj_id
    ,p_object_type       => 'SEQUENCE'
    ,p_object_name       => p_rule_rec.rate_sequence_name
    ,p_user_id           => p_request_rec.user_id
    ,p_last_update_login => p_request_rec.login_id
    ,x_return_status     => l_return_status
    ,x_msg_count         => l_msg_count
    ,x_msg_data          => l_msg_data
  );

  -- Check return status
  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
    Get_Put_Messages (
      p_msg_count => l_msg_count
      ,p_msg_data => l_msg_data
    );
    raise l_create_temp_objects_error;
  end if;

  commit;

  ------------------------------------------------------------------------------
  -- Create Driver Sequence for peforming Activity Rate Driver Processing in
  -- PFT_AR_DRIVERS_T.
  ------------------------------------------------------------------------------
  begin
    -- Temporary sequence is in the default APPS schema as GSCC does not
    -- allow hardcoded schemas.
    execute immediate 'create sequence '||p_rule_rec.drv_sequence_name;
  exception
    when others then
      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_ENG_CREATE_SEQUENCE_ERR
        ,p_token1   => 'SEQUENCE_NAME'
        ,p_value1   => p_rule_rec.drv_sequence_name
      );
      raise l_create_temp_objects_error;
  end;

  -- Register Temp Sequence in PL Framework
  FEM_PL_PKG.Register_Temp_Object (
    p_api_version       => 1.0
    ,p_commit            => FND_API.G_FALSE
    ,p_request_id        => p_request_rec.request_id
    ,p_object_id         => p_rule_rec.act_rate_obj_id
    ,p_object_type       => 'SEQUENCE'
    ,p_object_name       => p_rule_rec.drv_sequence_name
    ,p_user_id           => p_request_rec.user_id
    ,p_last_update_login => p_request_rec.login_id
    ,x_return_status     => l_return_status
    ,x_msg_count         => l_msg_count
    ,x_msg_data          => l_msg_data
  );

  -- Check return status
  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
    Get_Put_Messages (
      p_msg_count => l_msg_count
      ,p_msg_data => l_msg_data
    );
    raise l_create_temp_objects_error;
  end if;

  commit;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_create_temp_objects_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => g_log_level_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Create Temporary Objects Exception'
    );

    raise g_act_rate_request_error;

END Create_Temp_Objects;



/*===========================================================================+
 | PROCEDURE
 |   Drop_Temp_Objects
 |
 | DESCRIPTION
 |   Drop Temporary Objects - Sequences
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

PROCEDURE Drop_Temp_Objects (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
)
IS

  L_API_NAME             constant varchar2(30) := 'Drop_Temp_Objects';

  l_object_exists_flag            varchar(1);
  l_completion_status             boolean;

  l_return_status                 varchar2(1);
  l_msg_count                     number;
  l_msg_data                      varchar2(240);

  l_drop_temp_objects_error       exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'BEGIN'
  );

  ------------------------------------------------------------------------------
  -- Drop Activity Rate Sequence for peforming Activity Rate Processing in
  -- FEM_BALANCES.
  ------------------------------------------------------------------------------
  begin
    select 'Y'
    into l_object_exists_flag
    from fem_pl_temp_objects
    where request_id = p_request_rec.request_id
    and object_id = p_rule_rec.act_rate_obj_id
    and object_type = 'SEQUENCE'
    and object_name = p_rule_rec.rate_sequence_name;
  exception
    when no_data_found then
      l_object_exists_flag := 'N';
  end;

  if (l_object_exists_flag = 'Y') then

    begin
      -- Temporary sequence is in the default APPS schema as GSCC does not
      -- allow hardcoded schemas.
      execute immediate 'drop sequence '||p_rule_rec.rate_sequence_name;

      delete from fem_pl_temp_objects
      where request_id = p_request_rec.request_id
      and object_id = p_rule_rec.act_rate_obj_id
      and object_type = 'SEQUENCE'
      and object_name = p_rule_rec.rate_sequence_name;

    exception
      when others then
        l_completion_status := FND_CONCURRENT.Set_Completion_Status('WARNING',null);
        FEM_ENGINES_PKG.User_Message (
          p_app_name  => G_FEM
          ,p_msg_name => G_ENG_DROP_SEQUENCE_WRN
          ,p_token1   => 'SEQUENCE_NAME'
          ,p_value1   => p_rule_rec.rate_sequence_name
        );
    end;

    commit;

  end if;

  ------------------------------------------------------------------------------
  -- Create Driver Sequence for peforming Activity Rate Driver Processing in
  -- PFT_AR_DRIVERS_T.
  ------------------------------------------------------------------------------
  begin
    select 'Y'
    into l_object_exists_flag
    from fem_pl_temp_objects
    where request_id = p_request_rec.request_id
    and object_id = p_rule_rec.act_rate_obj_id
    and object_type = 'SEQUENCE'
    and object_name = p_rule_rec.drv_sequence_name;
  exception
    when no_data_found then
      l_object_exists_flag := 'N';
  end;

  if (l_object_exists_flag = 'Y') then

    begin
      -- Temporary sequence is in the default APPS schema as GSCC does not
      -- allow hardcoded schemas.
      execute immediate 'drop sequence '||p_rule_rec.drv_sequence_name;

      delete from fem_pl_temp_objects
      where request_id = p_request_rec.request_id
      and object_id = p_rule_rec.act_rate_obj_id
      and object_type = 'SEQUENCE'
      and object_name = p_rule_rec.drv_sequence_name;

    exception
      when others then
        l_completion_status := FND_CONCURRENT.Set_Completion_Status('WARNING',null);
        FEM_ENGINES_PKG.User_Message (
          p_app_name  => G_FEM
          ,p_msg_name => G_ENG_DROP_SEQUENCE_WRN
          ,p_token1   => 'SEQUENCE_NAME'
          ,p_value1   => p_rule_rec.drv_sequence_name
        );
    end;

    commit;

  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_drop_temp_objects_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => g_log_level_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Drop Temp Objects Exception'
    );

    raise g_act_rate_request_error;

END Drop_Temp_Objects;



/*===========================================================================+
 | PROCEDURE
 | Process_Drivers
 |
 | DESCRIPTION
 |   Process drivers
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

PROCEDURE Process_Drivers (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
  ,p_insert_count                 out nocopy number
)
IS

  L_API_NAME             constant varchar2(30) := 'Process_Drivers';

  L_CALC_DRIVER_VALUES   constant varchar2(30) := 'CALC_DRIVER_VALUES';

  l_mp_prog_status                varchar2(30);
  l_mp_exception_code             varchar2(30);

  l_return_status                 varchar2(1);
  l_msg_count                     number;
  l_msg_data                      varchar2(240);

  l_valid_drv_count               number;

  l_dimension_rec                 dimension_record;
  l_act_cond_where_clause         long;

  l_err_code                      number;
  l_err_msg                       varchar2(30);

  l_act_hier_where_clause         long;

  l_process_drivers_proc_error    exception;
  l_no_driver_error               exception;
  l_all_driver_invalid_error      exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'BEGIN'
  );

  -- Intialize variables
  l_mp_prog_status := G_COMPLETE_NORMAL;

  ------------------------------------------------------------------------------
  -- STEP 1: Assign the driver where clause
  ------------------------------------------------------------------------------

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'Step 1:  Assign Driver Where Clause'
  );

  IF (p_rule_rec.top_node_flag = 'Y') THEN

    l_act_hier_where_clause :=
    ' EXISTS ('||
    '   SELECT 1'||
    '   FROM FEM_ACTIVITIES_HIER H'||
    '   WHERE H.HIERARCHY_OBJ_DEF_ID = :b_hier_obj_def_id'||
    '   AND H.CHILD_ID = H.PARENT_ID'||
    '   AND H.PARENT_ID = ACTS.ACTIVITY_ID'||
    '   AND H.SINGLE_DEPTH_FLAG = ''Y'''||
    ' )';

  ELSE

    l_act_hier_where_clause  :=
    ' EXISTS ('||
    '   SELECT 1'||
    '   FROM FEM_ACTIVITIES_HIER H'||
    '   WHERE H.HIERARCHY_OBJ_DEF_ID = :b_hier_obj_def_id'||
    '   AND H.CHILD_ID = ACTS.ACTIVITY_ID'||
    '   AND H.SINGLE_DEPTH_FLAG = ''Y'''||
    ' )';

--  (H.PARENT_ID = ACTS.ACTIVITY_ID'||
--    '   OR H.CHILD_ID = ACTS.ACTIVITY_ID)'||


  END IF;

  ------------------------------------------------------------------------------
  -- STEP 2: Generate Conditions Predicate for Activity Rate Rule
  ------------------------------------------------------------------------------

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'Step 2:  Generate Conditions Predicate for Activity Rate Rule'
  );

  l_dimension_rec := p_request_rec.dimension_rec;

  if (p_rule_rec.cond_exists) then

    FEM_CONDITIONS_API.Generate_Condition_Predicate (
      p_api_version            => 1.0
      ,p_init_msg_list         => FND_API.G_FALSE
      ,p_commit                => FND_API.G_FALSE
      ,p_encoded               => FND_API.G_TRUE
      ,x_return_status         => l_return_status
      ,x_msg_count             => l_msg_count
      ,x_msg_data              => l_msg_data
      ,p_condition_obj_id      => p_rule_rec.cond_obj_id
      ,p_rule_effective_date   => p_request_rec.effective_date_varchar
      ,p_input_fact_table_name => l_dimension_rec.member_b_table
      ,p_table_alias           => 'acts'
      ,p_display_predicate     => 'N'
      ,p_return_predicate_type => 'DIM'
      ,p_logging_turned_on     => 'N'
      ,x_predicate_string      => l_act_cond_where_clause
    );

    if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      Get_Put_Messages (
        p_msg_count => l_msg_count
        ,p_msg_data => l_msg_data
      );
      raise l_process_drivers_proc_error;
    end if;

    if (l_act_cond_where_clause is null) then
      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_ENG_COND_WHERE_CLAUSE_ERR
        ,p_token1   => 'CONDITION_OBJECT_ID'
        ,p_value1   => p_rule_rec.cond_obj_id
        ,p_token2   => 'EFFECTIVE_DATE'
        ,p_value2   => FND_DATE.date_to_chardate(p_request_rec.effective_date)
        ,p_token3   => 'CONDITION_TABLE_NAME'
        ,p_value3   => l_dimension_rec.member_b_table
      );
      raise l_process_drivers_proc_error;
    end if;

    l_act_cond_where_clause := ' AND '|| l_act_cond_where_clause;

  end if;

  ------------------------------------------------------------------------------
  -- STEP 3: Populate data into the RATE DRIVER table
  ------------------------------------------------------------------------------

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'Step 3: Populate data into the RATE DRIVER table'
  );

  BEGIN

    EXECUTE IMMEDIATE
    ' INSERT INTO PFT_AR_DRIVERS_T('||
    '   CREATED_BY_REQUEST_ID'||
    '   ,CREATED_BY_OBJECT_ID'||
    '   ,SEQ_ID'||
    '   ,SOURCE_TABLE_NAME'||
    '   ,COLUMN_NAME'||
    '   ,STATISTIC_BASIS_ID'||
    '   ,CONDITION_OBJ_ID'||
    '   ,LAST_UPDATE_DATE'||
    ' )'||
    ' SELECT'||
    '   :b_request_id'||
    '   ,:b_act_rate_obj_id'||
    '   ,' || p_rule_rec.drv_sequence_name||'.nextval'||
    '   ,SOURCE_TABLE_NAME'||
    '   ,COLUMN_NAME'||
    '   ,STATISTIC_BASIS_ID'||
    '   ,CONDITION_OBJ_ID'||
    '   ,sysdate'||
    ' FROM ('||
    '   SELECT distinct assgn.SOURCE_TABLE_NAME'||
    '   ,assgn.COLUMN_NAME'||
    '   ,assgn.STATISTIC_BASIS_ID'||
    '   ,assgn.CONDITION_OBJ_ID'||
    '   FROM PFT_ACTIVITY_DRIVER_ASGN assgn'||
    '   WHERE EXISTS ('||
    '     SELECT activity_id'||
    '     FROM fem_activities acts'||
    '     WHERE acts.local_vs_combo_id = :b_local_vs_combo_id'||
    '     AND   acts.activity_id = assgn.ACTIVITY_ID'||
    '     AND '||l_act_hier_where_clause||
          l_act_cond_where_clause||
    '   )'||
    '   AND ACTIVITY_RATE_OBJ_DEF_ID = :b_act_rate_obj_def_id'||
    ' )'
    USING
      p_request_rec.request_id
      , p_rule_rec.act_rate_obj_id
      , p_request_rec.local_vs_combo_id
      , p_rule_rec.hier_obj_def_id
      , p_rule_rec.act_rate_obj_def_id;

    p_insert_count := SQL%ROWCOUNT;

    commit;

    if (p_insert_count > 0) then

      -- Register Object Execution Step
      Register_Obj_Exec_Step (
        p_request_rec       => p_request_rec
        ,p_rule_rec         => p_rule_rec
        ,p_exec_step        => L_CALC_DRIVER_VALUES
        ,p_exec_status_code => G_EXEC_STATUS_RUNNING
      );

      -- Call MP API if MP is enabled, otherwise call PL/SQL procedure directly
      if (G_MP_ENABLED) then

        -- Call Calulate_Driver_Values through MP API (Push Processing)
        FEM_MULTI_PROC_PKG.Master (
          x_prg_stat        => l_mp_prog_status
          ,x_exception_code => l_mp_exception_code
          ,p_rule_id        => p_rule_rec.act_rate_obj_id
          ,p_eng_step       => L_CALC_DRIVER_VALUES
          ,p_data_table     => 'PFT_AR_DRIVERS_T'
          ,p_eng_sql        => null
          ,p_table_alias    => 'drv'
          ,p_run_name       => L_CALC_DRIVER_VALUES
          ,p_eng_prg        => 'PFT_AR_ENGINE_PVT.Calc_Driver_Values'
          ,p_condition      => null
          ,p_failed_req_id  => null
          ,p_reuse_slices   => 'N' -- New data slice
          ,p_arg1           => p_request_rec.request_id
          ,p_arg2           => p_request_rec.dataset_grp_obj_def_id
          ,p_arg3           => p_request_rec.effective_date_varchar
          ,p_arg4           => p_request_rec.output_cal_period_id
          ,p_arg5           => p_request_rec.ledger_id
          ,p_arg6           => p_request_rec.local_vs_combo_id
          ,p_arg7           => p_request_rec.user_id
          ,p_arg8           => p_request_rec.login_id
          ,p_arg9           => p_rule_rec.act_rate_obj_id
          ,p_arg10          => p_rule_rec.act_rate_obj_def_id
          ,p_arg11          => p_rule_rec.hier_obj_def_id
          ,p_arg12          => l_act_hier_where_clause
          ,p_arg13          => l_act_cond_where_clause
        );

      else

        -- Call Calulate_Driver_Values directly
        Calc_Driver_Values (
          p_eng_sql                 => null
          ,p_slc_pred               => null
          ,p_proc_num               => null
          ,p_part_code              => null
          ,p_fetch_limit            => null
          ,p_request_id             => p_request_rec.request_id
          ,p_dataset_grp_obj_def_id => p_request_rec.dataset_grp_obj_def_id
          ,p_effective_date_varchar => p_request_rec.effective_date_varchar
          ,p_output_cal_period_id   => p_request_rec.output_cal_period_id
          ,p_ledger_id              => p_request_rec.ledger_id
          ,p_local_vs_combo_id      => p_request_rec.local_vs_combo_id
          ,p_user_id                => p_request_rec.user_id
          ,p_login_id               => p_request_rec.login_id
          ,p_act_rate_obj_id        => p_rule_rec.act_rate_obj_id
          ,p_act_rate_obj_def_id    => p_rule_rec.act_rate_obj_def_id
          ,p_hier_obj_def_id        => p_rule_rec.hier_obj_def_id
          ,p_act_hier_where_clause  => l_act_hier_where_clause
          ,p_act_cond_where_clause  => l_act_cond_where_clause
        );

      end if;

      if (l_mp_prog_status <> G_COMPLETE_NORMAL) then

        if (l_mp_exception_code is not null) then
          FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_FEM
            ,p_msg_name => l_mp_exception_code
          );
        end if;

        Update_Obj_Exec_Step_Status (
          p_request_rec       => p_request_rec
          ,p_rule_rec         => p_rule_rec
          ,p_exec_step        => L_CALC_DRIVER_VALUES
          ,p_exec_status_code => G_EXEC_STATUS_ERROR_UNDO
        );

        raise l_process_drivers_proc_error;

      else

        Update_Obj_Exec_Step_Status (
          p_request_rec       => p_request_rec
          ,p_rule_rec         => p_rule_rec
          ,p_exec_step        => L_CALC_DRIVER_VALUES
          ,p_exec_status_code => G_EXEC_STATUS_SUCCESS
        );

      end if;

      commit;

      if (G_MP_ENABLED) then
        -- Purge Data Slices
        FEM_MULTI_PROC_PKG.Delete_Data_Slices (
          p_req_id => p_request_rec.request_id
        );
      end if;

    else

      raise l_no_driver_error;

    end if;

    -- IF all drivers are invalid then report DRIVER_NOT_VALID error
    SELECT count(*)
      INTO l_valid_drv_count
      FROM PFT_AR_DRIVERS_T
     WHERE CREATED_BY_REQUEST_ID = p_request_rec.request_id
       AND CREATED_BY_OBJECT_ID =  p_rule_rec.act_rate_obj_id
       AND VALID_FLAG = 'Y';

    IF (l_valid_drv_count = 0) THEN
      raise l_all_driver_invalid_error;
    END IF;

--  ammittal - commented to let the exception fall through
--  EXCEPTION

--    WHEN OTHERS THEN
--      FEM_ENGINES_PKG.User_Message (
--        p_app_name  => G_FEM
--        ,p_msg_name => G_AR_INSERT_ACT_DRIV_ERR
--      );
--    raise l_process_drivers_proc_error;

  END;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_all_driver_invalid_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Process Driver All Invalid Driver Exception'
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_PFT
      ,p_msg_name => G_AR_ALL_INV_DRIV_ERR
      ,p_token1   => 'TABLE_NAME'
      ,p_value1   => 'PFT_AR_DRIVERS_T'
      ,p_token2   => 'OBJECT_ID'
      ,p_value2   => p_rule_rec.act_rate_obj_id
    );

    raise g_act_rate_request_error;

  when l_no_driver_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Process Driver No Driver Exception'
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_PFT
      ,p_msg_name => G_AR_NO_DRIVER_ERR
      ,p_token1   => 'TABLE_NAME'
      ,p_value1   => 'PFT_ACTIVITY_DRIVER_ASGN'
      ,p_token2   => 'OBJECT_ID'
      ,p_value2   => p_rule_rec.act_rate_obj_id
    );

    raise g_act_rate_request_error;


  when l_process_drivers_proc_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Rule Post Process Exception'
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_ENG_RULE_POST_PROC_ERR
    );

    raise g_act_rate_request_error;

END Process_Drivers;



/*===========================================================================+
 | PROCEDURE
 |   Calc_Driver_Values
 |
 | DESCRIPTION
 |   This procedure is called by the Multi-Processing Engine so that driver
 |   calculation can be done in parallel through multiple subrequests.
 |
 | SCOPE - PUBLIC
 |
 +===========================================================================*/

PROCEDURE Calc_Driver_Values (
  p_eng_sql                       in varchar2
  ,p_slc_pred                     in varchar2
  ,p_proc_num                     in number
  ,p_part_code                    in number
  ,p_fetch_limit                  in number
  ,p_request_id                   in number
  ,p_dataset_grp_obj_def_id       in number
  ,p_effective_date_varchar       in varchar2
  ,p_output_cal_period_id         in number
  ,p_ledger_id                    in number
  ,p_local_vs_combo_id            in number
  ,p_user_id                      in number
  ,p_login_id                     in number
  ,p_act_rate_obj_id              in number
  ,p_act_rate_obj_def_id          in number
  ,p_hier_obj_def_id              in number
  ,p_act_hier_where_clause        in long
  ,p_act_cond_where_clause        in long
)
IS

  L_API_NAME             constant varchar2(30) := 'Calc_Driver_Values';

  -- Bulk fetch limit for cursors
  l_fetch_limit                   number;

  -- MP partition variables
  l_slc_id                        number;
  l_slc_val1                      number;
  l_slc_val2                      number;
  l_slc_val3                      number;
  l_slc_val4                      number;
  l_num_vals                      number;
  l_part_name                     varchar2(30);

  -- MP status and output variables
  l_status                        number;
  l_message                       varchar2(30);
  l_rows_processed                number;
  l_rows_loaded                   number;

  l_return_status                 varchar2(1);
  l_msg_count                     number;
  l_msg_data                      varchar2(240);

  l_dummy                         number;

  l_err_code                      number;
  l_err_msg                       varchar2(30);

  l_driver_where_clause           long;
  l_drv_cond_where_clause         long;
  l_input_ds_d_where_clause       long;

  l_ar_drivers_csr                dynamic_cursor;
  l_ar_drivers_stmt               long;
  l_calc_drv_stmt                 long;
  l_ar_driver_values_stmt         long;

  -- PL/SQL tables to fetch details from appropriate queries.
  l_rowid_tbl                     rowid_type;
  l_drv_table_name_tbl            g_drv_table_name_table;
  l_column_name_tbl               g_column_name_table;
  l_statistic_basis_id_tbl        g_statistic_basis_id_table;
  l_drv_condition_obj_id_tbl      g_condition_obj_id_table;
  l_valid_flag_tbl                g_valid_flag_table;
  l_driver_value_tbl              g_driver_value_table;
  l_last_update_date_tbl          g_last_update_date_table;
  l_invalid_reason_tbl            g_invalid_reason_table;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'BEGIN'
  );

  -- Initialize Variables
  l_status := 0;
  l_message := 'COMPLETE:NORMAL';

  l_rows_processed := 0;
  l_rows_loaded := 0;

  l_num_vals := 0;
  l_part_name := null;

  -- Set the cursor fetch limit
  l_fetch_limit := p_fetch_limit;
  if (l_fetch_limit is null) then
    l_fetch_limit := G_DEFAULT_FETCH_LIMIT;
  end if;

  ------------------------------------------------------------------------------
  -- STEP 1: Build MP SQL Statement for fetching rows in PFT_AR_DRIVERS_T
  ------------------------------------------------------------------------------

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'Step 1: Build MP SQL Statement for fetching rows in PFT_AR_DRIVERS_T'
  );

  if (G_MP_ENABLED) then
    -- Get the Data Slice
    FEM_MULTI_PROC_PKG.Get_Data_Slice (
      p_req_id     => p_request_id
      ,p_proc_num  => p_proc_num
      ,x_slc_id    => l_slc_id
      ,x_slc_val1  => l_slc_val1
      ,x_slc_val2  => l_slc_val2
      ,x_slc_val3  => l_slc_val3
      ,x_slc_val4  => l_slc_val4
      ,x_num_vals  => l_num_vals
      ,x_part_name => l_part_name
    );
  end if;

  -- Build tokenized SQL statement
  l_ar_drivers_stmt :=
  ' select rowid'||
  ' ,source_table_name'||
  ' ,column_name'||
  ' ,statistic_basis_id'||
  ' ,condition_obj_id'||
  ' ,valid_flag'||
  ' ,driver_value'||
  ' ,last_update_date'||
  ' ,invalid_reason'||
  ' from pft_ar_drivers_t {{table_partition}} drv'||
  ' where created_by_request_id = '||p_request_id||
  ' and created_by_object_id = '||p_act_rate_obj_id||
  ' and {{data_slice}} ';

  -- Replace the data slice token with the slice predicate (if it exists)
  if (p_slc_pred is null) then
    l_ar_drivers_stmt := REPLACE(l_ar_drivers_stmt
      ,'{{data_slice}}',' 1=1 ');
  else
    l_ar_drivers_stmt := REPLACE(l_ar_drivers_stmt
      ,'{{data_slice}}',p_slc_pred);
  end if;

  -- Replace the partition token with the partition table name (if it exists)
  if (l_part_name is null) then
    l_ar_drivers_stmt := REPLACE(l_ar_drivers_stmt
      ,'{{table_partition}}',' ');
  else
    l_ar_drivers_stmt := REPLACE(l_ar_drivers_stmt
      ,'{{table_partition}}',' PARTITION('||l_part_name||') ');
  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'l_ar_drivers_stmt = '||l_ar_drivers_stmt
  );

  ------------------------------------------------------------------------------
  -- STEP 2: Open MP Cursor for fetching rows in PFT_AR_DRIVERS_T
  ------------------------------------------------------------------------------

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'Step 2: Open MP Cursor for fetching rows in PFT_AR_DRIVERS_T'
  );

  -- Execute the built SQL statement for opening the cursor
  if (l_num_vals = 4) then
    open l_ar_drivers_csr for l_ar_drivers_stmt
    using l_slc_val1, l_slc_val2, l_slc_val3, l_slc_val4;
  elsif (l_num_vals = 3) then
    open l_ar_drivers_csr for l_ar_drivers_stmt
    using l_slc_val1, l_slc_val2, l_slc_val3;
  elsif (l_num_vals = 2) then
    open l_ar_drivers_csr for l_ar_drivers_stmt
    using l_slc_val1, l_slc_val2;
  elsif (l_num_vals = 1) then
    open l_ar_drivers_csr for l_ar_drivers_stmt
    using l_slc_val1;
  elsif (l_num_vals = 0) then
    -- no data slice
    open l_ar_drivers_csr for l_ar_drivers_stmt;
  end if;

  loop

    fetch l_ar_drivers_csr
    bulk collect into
    l_rowid_tbl
    ,l_drv_table_name_tbl
    ,l_column_name_tbl
    ,l_statistic_basis_id_tbl
    ,l_drv_condition_obj_id_tbl
    ,l_valid_flag_tbl
    ,l_driver_value_tbl
    ,l_last_update_date_tbl
    ,l_invalid_reason_tbl
    limit l_fetch_limit;

    if l_rowid_tbl.count = 0 then
      exit;
    end if;

    for i in 1..l_rowid_tbl.count loop

      <<next_driver>>
      loop

        FEM_ENGINES_PKG.Tech_Message (
          p_severity  => G_LOG_LEVEL_1
          ,p_module   => G_BLOCK||'.'||L_API_NAME
          ,p_msg_text =>
            'Step 3.'||to_char(i)||
            ': Process Driver from '||l_drv_table_name_tbl(i)||
            ' with statistic_basis_id = '||l_statistic_basis_id_tbl(i)
        );

        begin
          select 1
          into l_dummy
          from fem_table_class_assignmt_v
          where table_classification_code in ('STATISTIC', 'PFT_LEDGER')
          and table_name = l_drv_table_name_tbl(i);
        exception
          when too_many_rows then
            null;
          when no_data_found then
            l_valid_flag_tbl(i) := 'N';
            l_invalid_reason_tbl(i) := G_AR_NO_DRV_TBL_CLASSF_ERR;
            exit next_driver;
        end;

        ------------------------------------------------------------------------
        -- Call the Where Clause Generator for source data in FEM_BALANCES
        ------------------------------------------------------------------------
        FEM_DS_WHERE_CLAUSE_GENERATOR.FEM_Gen_DS_WClause_PVT (
          p_api_version       => 1.0
          ,p_init_msg_list    => FND_API.G_FALSE
          ,p_encoded          => FND_API.G_TRUE
          ,x_return_status    => l_return_status
          ,x_msg_count        => l_msg_count
          ,x_msg_data         => l_msg_data
          ,p_ds_io_def_id     => p_dataset_grp_obj_def_id
          ,p_output_period_id => p_output_cal_period_id
          ,p_table_name       => l_drv_table_name_tbl(i)
          ,p_table_alias      => 'D'
          ,p_ledger_id        => p_ledger_id
          ,p_where_clause     => l_input_ds_d_where_clause
        );

        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
          Get_Put_Messages (
            p_msg_count => l_msg_count
            ,p_msg_data => l_msg_data
          );
          l_valid_flag_tbl(i) := 'N';
          exit next_driver;
        end if;

        if (l_input_ds_d_where_clause is null) then
          FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_FEM
            ,p_msg_name => G_ENG_BAD_DS_WCLAUSE_ERR
          );
          l_valid_flag_tbl(i) := 'N';
          exit next_driver;
        end if;

        if (l_drv_condition_obj_id_tbl(i) is not null) then

          FEM_CONDITIONS_API.Generate_Condition_Predicate (
            p_api_version            => 1.0
            ,p_init_msg_list         => FND_API.G_FALSE
            ,p_commit                => FND_API.G_FALSE
            ,p_encoded               => FND_API.G_TRUE
            ,x_return_status         => l_return_status
            ,x_msg_count             => l_msg_count
            ,x_msg_data              => l_msg_data
            ,p_condition_obj_id      => l_drv_condition_obj_id_tbl(i)
            ,p_rule_effective_date   => p_effective_date_varchar
            ,p_input_fact_table_name => l_drv_table_name_tbl(i)
            ,p_table_alias           => 'D'
            ,p_display_predicate     => 'N'
            ,p_return_predicate_type => 'DIM'
            ,p_logging_turned_on     => 'N'
            ,x_predicate_string      => l_drv_cond_where_clause
          );

          if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            Get_Put_Messages (
              p_msg_count => l_msg_count
              ,p_msg_data => l_msg_data
             );
          end if;

        end if;

        l_calc_drv_stmt :=
        ' select sum(d.'||l_column_name_tbl(i)||')'||
        ' from '||l_drv_table_name_tbl(i)|| ' d' ||
        ' where d.line_item_id = :b_statistic_basis_id'||
        ' and '|| l_input_ds_d_where_clause||
        ' and d.ledger_id = :b_ledger_id';

        -- ammittal - Do not allow Activity Rate data to be the driver of
        -- another activity rate
        if (l_drv_table_name_tbl(i) = 'FEM_BALANCES') then
          l_calc_drv_stmt := l_calc_drv_stmt||
          ' and d.financial_elem_id <> :b_act_rate_fin_elem_id';
        end if;

        if (l_drv_cond_where_clause is not null) then
          l_calc_drv_stmt := l_calc_drv_stmt||
          ' and '||l_drv_cond_where_clause;
        end if;

        begin

          if (l_drv_table_name_tbl(i) = 'FEM_BALANCES') then
            execute immediate l_calc_drv_stmt
            into l_driver_value_tbl(i)
            using l_statistic_basis_id_tbl(i)
            ,p_ledger_id
            ,G_FIN_ELEM_ID_ACTIVITY_RATE;
          else
            execute immediate l_calc_drv_stmt
            into l_driver_value_tbl(i)
            using l_statistic_basis_id_tbl(i)
            ,p_ledger_id;
          end if;

          -- Bug fix 4626068 - ammittal 06/21/05 - added the code for null
					-- as the statistic value can be null in FEM_BALANCES
          if ((l_driver_value_tbl(i) = 0)
					    OR (l_driver_value_tbl(i) IS NULL)) then

             FEM_ENGINES_PKG.User_Message (
               p_app_name  => G_PFT
              ,p_msg_name => G_AR_ZERO_DRV_VAL_ERR
              ,p_token1   => 'SOURCE_TABLE_NAME'
              ,p_value1   => l_drv_table_name_tbl(i)
              ,p_token2   => 'SOURCE_COLUMN_NAME'
              ,p_value2   => l_column_name_tbl(i)
              ,p_token3   => 'STATISTIC_BASIS_ID'
              ,p_value3   => l_statistic_basis_id_tbl(i)
              ,p_token4   => 'CONDITION_OBJ_ID'
              ,p_value4   => l_drv_condition_obj_id_tbl(i)
            );

            l_valid_flag_tbl(i) := 'N';
            l_invalid_reason_tbl(i) := G_AR_ZERO_DRV_VAL_ERR;
            exit next_driver;
          else
            l_valid_flag_tbl(i) := 'Y';
          end if;

        exception
          when others then
            FEM_ENGINES_PKG.User_Message (
              p_app_name  => G_PFT
             ,p_msg_name => G_AR_INSERT_ACT_DRIV_ERR
             ,p_token1   => 'TABLE_NAME'
             ,p_value1   => l_statistic_basis_id_tbl(i)
             ,p_token2   => 'OBJECT_ID'
             ,p_value2   => p_act_rate_obj_id
           );
           l_valid_flag_tbl(i) := 'N';
           l_invalid_reason_tbl(i) := G_AR_UNEXP_DRV_VAL_ERR;
           exit next_driver;

        end;

        if (g_track_event_chains) then

          Register_Driver_Chains (
            p_request_id               => p_request_id
            ,p_ledger_id               => p_ledger_id
            ,p_user_id                 => p_user_id
            ,p_login_id                => p_login_id
            ,p_act_rate_obj_id         => p_act_rate_obj_id
            ,p_drv_table_name          => l_drv_table_name_tbl(i)
            ,p_statistic_basis_id      => l_statistic_basis_id_tbl(i)
            ,p_drv_cond_where_clause   => l_drv_cond_where_clause
            ,p_input_ds_d_where_clause => l_input_ds_d_where_clause
          );

        end if;

        -- Always exit to ensure one pass in the next_driver loop
        exit next_driver;

      end loop; --next_driver

    end loop;

    ----------------------------------------------------------------------------
    -- STEP 4: Bulk Update PFT_AR_DRIVERS_T Table
    ----------------------------------------------------------------------------

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Step 4: Bulk Update PFT_AR_DRIVERS_T Table'
    );

    forall rec_num in l_rowid_tbl.FIRST..l_rowid_tbl.LAST
      update pft_ar_drivers_t
      set driver_value = l_driver_value_tbl(rec_num)
      ,valid_flag = l_valid_flag_tbl(rec_num)
      ,invalid_reason = l_invalid_reason_tbl(rec_num)
      where rowid = l_rowid_tbl(rec_num);

    -- Update row counts for MP Slice Post Processing
    l_rows_processed := l_rows_processed + SQL%ROWCOUNT;
    l_rows_loaded := l_rows_loaded + l_rowid_tbl.count;

    ----------------------------------------------------------------------------
    -- STEP 5: Build MP SQL Statement for bulk insert into PFT_AR_DRIVER_VALUES_T
    ----------------------------------------------------------------------------

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Step 5: Build MP SQL Statement for bulk insert into PFT_AR_DRIVER_VALUES_T'
    );

    -- ammittal 11/23/04 - Need to look at where clauses for hierarchy and
    -- conditions. Turn Value and Driver table population around?

    -- Build tokenized SQL statement
    l_ar_driver_values_stmt :=
    ' insert into pft_ar_driver_values_t ('||
    '   created_by_request_id'||
    '   ,created_by_object_id'||
    '   ,activity_id'||
    '   ,driver_value'||
    '   ,statistic_basis_id'||
    ' )'||
    ' select '||p_request_id||
    ' ,'||p_act_rate_obj_id||
    ' ,assgn.activity_id'||
    ' ,drv.driver_value'||
    ' ,assgn.statistic_basis_id'||
    ' from pft_ar_drivers_t {{table_partition}} drv'||
    ' ,pft_activity_driver_asgn assgn'||
    ' where drv.created_by_request_id = '||p_request_id||
    ' and drv.created_by_object_id = '||p_act_rate_obj_id||
    ' and drv.valid_flag = ''Y'''||
    ' and assgn.activity_rate_obj_def_id = '||p_act_rate_obj_def_id||
    ' and assgn.source_table_name = drv.source_table_name'||
    ' and assgn.column_name = drv.column_name'||
    ' and assgn.statistic_basis_id = drv.statistic_basis_id'||
    ' and exists ('||
    '   select activity_id'||
    '   from fem_activities acts'||
    '   where acts.local_vs_combo_id = '||p_local_vs_combo_id||
    '   and acts.activity_id = assgn.activity_id'||
    '   and '||p_act_hier_where_clause||
        p_act_cond_where_clause||
    ' )'||
    ' and nvl(assgn.condition_obj_id, -1) = nvl(drv.condition_obj_id, -1)'||
    ' and {{data_slice}} ';

    -- Replace the data slice token with the slice predicate (if it exists)
    if (p_slc_pred is null) then
      l_ar_driver_values_stmt := REPLACE(l_ar_driver_values_stmt
        ,'{{data_slice}}',' 1=1 ');
    else
      l_ar_driver_values_stmt := REPLACE(l_ar_driver_values_stmt,
        '{{data_slice}}',p_slc_pred);
    end if;

    -- Replace the partition token with the partition table name (if it exists)
    if (l_part_name is null) then
      l_ar_driver_values_stmt := REPLACE(l_ar_driver_values_stmt
        ,'{{table_partition}}',' ');
    else
      l_ar_driver_values_stmt := REPLACE(l_ar_driver_values_stmt
        ,'{{table_partition}}',' PARTITION('||l_part_name||') ');
    end if;

    ------------------------------------------------------------------------------
    -- STEP 6: Execute MP SQL Statement for bulk insert into PFT_AR_DRIVER_VALUES_T
    ------------------------------------------------------------------------------

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Step 6: Execute MP SQL Statement for bulk insert into PFT_AR_DRIVER_VALUES_T'
    );

    -- Execute the built SQL statement for bulk insert into PFT_AR_DRIVER_VALUES_T
    if (l_num_vals = 4) then
      execute immediate l_ar_driver_values_stmt
      using p_hier_obj_def_id
      ,l_slc_val1, l_slc_val2, l_slc_val3, l_slc_val4;
    elsif (l_num_vals = 3) then
      execute immediate l_ar_driver_values_stmt
      using p_hier_obj_def_id
      ,l_slc_val1, l_slc_val2, l_slc_val3;
    elsif (l_num_vals = 2) then
      execute immediate l_ar_driver_values_stmt
      using p_hier_obj_def_id
      ,l_slc_val1, l_slc_val2;
    elsif (l_num_vals = 1) then
      execute immediate l_ar_driver_values_stmt
      using p_hier_obj_def_id
      ,l_slc_val1;
    elsif (l_num_vals = 0) then
      -- no data slice
      execute immediate l_ar_driver_values_stmt
      using p_hier_obj_def_id;
    end if;

    -- Purge pl/sql tables
    l_rowid_tbl.DELETE;
    l_drv_table_name_tbl.DELETE;
    l_column_name_tbl.DELETE;
    l_statistic_basis_id_tbl.DELETE;
    l_drv_condition_obj_id_tbl.DELETE;
    l_valid_flag_tbl.DELETE;
    l_driver_value_tbl.DELETE;
    l_last_update_date_tbl.DELETE;
    l_invalid_reason_tbl.DELETE;

    commit;

  end loop;

  close l_ar_drivers_csr;

  if (G_MP_ENABLED) then
    -- MP Post Processing on processed data slice
    FEM_MULTI_PROC_PKG.Post_Data_Slice (
      p_req_id => p_request_id
      ,p_slc_id => l_slc_id
      ,p_status => l_status
      ,p_message => l_message
      ,p_rows_processed => l_rows_processed
      ,p_rows_loaded => l_rows_loaded
      ,p_rows_rejected => l_rows_loaded - l_rows_processed
    );
  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'END'
  );

EXCEPTION

  when others then

    g_prg_msg := SQLERRM;
    g_callstack := DBMS_UTILITY.Format_Call_Stack;

    if (l_ar_drivers_csr%ISOPEN) then
     close l_ar_drivers_csr;
    end if;

    l_status:= 2;
    l_message := 'COMPLETE:ERROR';

    if (G_MP_ENABLED) then
      FEM_MULTI_PROC_PKG.Post_Data_Slice (
        p_req_id => p_request_id
        ,p_slc_id => l_slc_id
        ,p_status => l_status
        ,p_message => l_message
        ,p_rows_processed => l_rows_processed
        ,p_rows_loaded => l_rows_loaded
        ,p_rows_rejected => l_rows_loaded - l_rows_processed
      );
    end if;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME||'.Unexpected_Exception'
      ,p_msg_text => g_prg_msg
    );

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME||'.Unexpected_Exception'
      ,p_msg_text => g_callstack
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_UNEXPECTED_ERROR
      ,p_token1   => 'ERR_MSG'
      ,p_value1   => g_prg_msg
    );

    raise g_act_rate_request_error;

END Calc_Driver_Values;



/*===========================================================================+
 | PROCEDURE
 |   Register_Driver_Chains
 |
 | DESCRIPTION
 |   Register Driver Chains - Called from Process Drivers
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

PROCEDURE Register_Driver_Chains (
  p_request_id                    in number
  ,p_ledger_id                    in number
  ,p_user_id                      in number
  ,p_login_id                     in number
  ,p_act_rate_obj_id              in number
  ,p_drv_table_name               in varchar2
  ,p_statistic_basis_id           in number
  ,p_drv_cond_where_clause        in long
  ,p_input_ds_d_where_clause      in long
)
IS

  L_API_NAME             constant varchar2(30) := 'Register_Driver_Chains';

  l_dummy                         number;
  l_find_driver_chains_last_row   number;
  l_created_by_request_id_tbl     number_table;
  l_created_by_object_id_tbl      number_table;

  l_drv_chain_csr                 dynamic_cursor;
  l_drv_chain_stmt                long;

  l_return_status                 varchar2(1);
  l_msg_count                     number;
  l_msg_data                      varchar2(240);

  l_register_driver_chains_error  exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'BEGIN'
  );

  l_drv_chain_stmt :=
  ' select distinct d.created_by_request_id'||
  ' ,d.created_by_object_id'||
  ' from ' || p_drv_table_name || ' d'||
  ' where d.line_item_id = :b_statistic_basis_id'||
  ' and '|| p_input_ds_d_where_clause||
  ' and d.ledger_id = :b_ledger_id'||
  ' and not ('||
  '   d.created_by_request_id = :b_request_id'||
  '   and d.created_by_object_id = :b_act_rate_obj_id'||
  ' )'||
  ' and not exists ('||
  '   select 1'||
  '   from fem_pl_chains c'||
  '   where c.request_id = :b_request_id'||
  '   and c.object_id = :b_act_rate_obj_id'||
  '   and c.source_created_by_request_id = d.created_by_request_id'||
  '   and c.source_created_by_object_id = d.created_by_object_id'||
  ' )';

  IF (p_drv_cond_where_clause IS NOT NULL) THEN
    l_drv_chain_stmt := l_drv_chain_stmt || ' AND '|| p_drv_cond_where_clause;
  END IF;

  open l_drv_chain_csr
   for l_drv_chain_stmt
  using p_statistic_basis_id
        ,p_ledger_id
        ,p_request_id
        ,p_act_rate_obj_id
        ,p_request_id
        ,p_act_rate_obj_id;
  loop

    fetch l_drv_chain_csr
    bulk collect into
      l_created_by_request_id_tbl
      ,l_created_by_object_id_tbl
    limit g_fetch_limit;

    l_find_driver_chains_last_row := l_created_by_request_id_tbl.LAST;

    if (l_find_driver_chains_last_row is null) then
      exit;
    end if;

    for i in 1..l_find_driver_chains_last_row loop

      -- Call the FEM_PL_PKG.Register_Chain API procedure to register
      -- the specified chain.
      FEM_PL_PKG.Register_Chain (
        p_api_version                   => 1.0
        ,p_commit                       => FND_API.G_FALSE
        ,p_request_id                   => p_request_id
        ,p_object_id                    => p_act_rate_obj_id
        ,p_source_created_by_request_id => l_created_by_request_id_tbl(i)
        ,p_source_created_by_object_id  => l_created_by_object_id_tbl(i)
        ,p_user_id                      => p_user_id
        ,p_last_update_login            => p_login_id
        ,x_msg_count                    => l_msg_count
        ,x_msg_data                     => l_msg_data
        ,x_return_status                => l_return_status
      );

      if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        Get_Put_Messages (
          p_msg_count => l_msg_count
          ,p_msg_data => l_msg_data
        );
        raise l_register_driver_chains_error;
      end if;
    end loop;

    l_created_by_request_id_tbl.DELETE;
    l_created_by_object_id_tbl.DELETE;

    commit;

  end loop;

  close l_drv_chain_csr;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_register_driver_chains_error then

    if (l_drv_chain_csr%ISOPEN) then
     close l_drv_chain_csr;
    end if;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Register Driver Chains Exception'
    );

    raise g_act_rate_request_error;

  when g_act_rate_request_error then

    if (l_drv_chain_csr%ISOPEN) then
     close l_drv_chain_csr;
    end if;

    raise g_act_rate_request_error;

  when others then

    g_prg_msg := SQLERRM;
    g_callstack := DBMS_UTILITY.Format_Call_Stack;

    if (l_drv_chain_csr%ISOPEN) then
     close l_drv_chain_csr;
    end if;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME||'.Unexpected_Exception'
      ,p_msg_text => g_prg_msg
    );

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME||'.Unexpected_Exception'
      ,p_msg_text => g_callstack
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_UNEXPECTED_ERROR
      ,p_token1   => 'ERR_MSG'
      ,p_value1   => g_prg_msg
    );

    raise g_act_rate_request_error;

END Register_Driver_Chains;



/*===========================================================================+
 | PROCEDURE
 |   Register_Source_Chains
 |
 | DESCRIPTION
 |   Register Source (FEM_BALANCES) Chains - Called from Act_Rate_Rule
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

PROCEDURE Register_Source_Chains (
  p_request_id                    in number
  ,p_act_rate_obj_id              in number
  ,p_ledger_id                    in number
  ,p_input_ds_b_where_clause      in long
  ,p_user_id                      in number
  ,p_login_id                     in number
)
IS

  L_API_NAME             constant varchar2(30) := 'Register_Source_Chains';

  t_created_by_request_id         number_type;
  t_created_by_object_id          number_type;

  l_find_source_chains_csr        dynamic_cursor;
  l_find_source_chains_stmt       long;
  l_find_source_chains_last_row   number;

  l_return_status                 varchar2(1);
  l_msg_count                     number;
  l_msg_data                      varchar2(240);

  l_register_source_chains_error  exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'BEGIN'
  );

  l_find_source_chains_stmt :=
  ' select distinct created_by_request_id'||
  ' ,created_by_object_id'||
  ' from fem_balances b'||
  ' where b.ledger_id = :b_ledger_id'||
  ' and b.financial_elem_id not in (:b_stat_fin_elem_id, :b_act_rate_fin_elem_id)'||
  ' and b.currency_type_code = ''ENTERED'''||
  ' and '||p_input_ds_b_where_clause||
  ' and not ('||
  '   b.created_by_request_id = :b_request_id'||
  '   and b.created_by_object_id = :b_act_rate_obj_id'||
  ' )'||
  ' and exists ('||
  '   select 1'||
  '   from pft_ar_driver_values_t drv'||
  '   where drv.created_by_request_id = :b_request_id'||
  '   and drv.created_by_object_id = :b_act_rate_obj_id'||
  '   and drv.activity_id = b.activity_id'||
  ' )'||
  ' and not exists ('||
  '   select 1'||
  '   from fem_pl_chains c'||
  '   where c.request_id = :b_request_id'||
  '   and c.object_id = :b_act_rate_obj_id'||
  '   and c.source_created_by_request_id = b.created_by_request_id'||
  '   and c.source_created_by_object_id = b.created_by_object_id'||
  ' )';

  open l_find_source_chains_csr
  for l_find_source_chains_stmt
  using p_ledger_id
  ,G_FIN_ELEM_ID_STATISTIC
  ,G_FIN_ELEM_ID_ACTIVITY_RATE
  ,p_request_id
  ,p_act_rate_obj_id
  ,p_request_id
  ,p_act_rate_obj_id
  ,p_request_id
  ,p_act_rate_obj_id;

  loop

    fetch l_find_source_chains_csr
    bulk collect into
    t_created_by_request_id
    ,t_created_by_object_id
    limit g_fetch_limit;

    l_find_source_chains_last_row := t_created_by_request_id.LAST;
    if (l_find_source_chains_last_row is null) then
      exit;
    end if;

    for i in 1..l_find_source_chains_last_row loop

      -- Call the FEM_PL_PKG.Register_Chain API procedure to register
      -- the specified chain.
      FEM_PL_PKG.Register_Chain (
        p_api_version                   => 1.0
        ,p_commit                       => FND_API.G_FALSE
        ,p_request_id                   => p_request_id
        ,p_object_id                    => p_act_rate_obj_id
        ,p_source_created_by_request_id => t_created_by_request_id(i)
        ,p_source_created_by_object_id  => t_created_by_object_id(i)
        ,p_user_id                      => p_user_id
        ,p_last_update_login            => p_login_id
        ,x_msg_count                    => l_msg_count
        ,x_msg_data                     => l_msg_data
        ,x_return_status                => l_return_status
      );

      if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        Get_Put_Messages (
          p_msg_count => l_msg_count
          ,p_msg_data => l_msg_data
        );
        raise l_register_source_chains_error;
      end if;

    end loop;

    t_created_by_request_id.DELETE;
    t_created_by_object_id.DELETE;

    commit;

  end loop;

  close l_find_source_chains_csr;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_register_source_chains_error then

    if (l_find_source_chains_csr%ISOPEN) then
     close l_find_source_chains_csr;
    end if;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => g_log_level_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Register Source Chains Exception'
    );

    raise g_act_rate_request_error;

  when g_act_rate_request_error then

    if (l_find_source_chains_csr%ISOPEN) then
     close l_find_source_chains_csr;
    end if;

    raise g_act_rate_request_error;

  when others then

    g_prg_msg := SQLERRM;
    g_callstack := DBMS_UTILITY.Format_Call_Stack;

    if (l_find_source_chains_csr%ISOPEN) then
     close l_find_source_chains_csr;
    end if;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => g_log_level_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME||'.Unexpected_Exception'
      ,p_msg_text => g_prg_msg
    );

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => g_log_level_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME||'.Unexpected_Exception'
      ,p_msg_text => g_callstack
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_UNEXPECTED_ERROR
      ,p_token1   => 'ERR_MSG'
      ,p_value1   => g_prg_msg
    );

    raise g_act_rate_request_error;

END Register_Source_Chains;



/*===========================================================================+
 | PROCEDURE
 |   Rule_Post_Proc
 |
 | DESCRIPTION
 |   Updates the status of the object execution in the
 |   processing locks tables.
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

PROCEDURE Rule_Post_Proc (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
  ,p_input_ds_b_where_clause      in long
  ,p_exec_status_code             in varchar2
)
IS

  L_API_NAME             constant varchar2(30) := 'Rule_Post_Proc';

  l_num_of_input_rows_stmt        long;
  l_num_of_input_rows             number;
  l_num_of_output_rows            number;

  l_return_status                 varchar2(1);
  l_msg_count                     number;
  l_msg_data                      varchar2(240);

  l_rule_post_proc_error    exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'BEGIN'
  );

  ------------------------------------------------------------------------------
  -- STEP 1: Drop all Temp Objects created for the Rollup Rule
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'Step 1:  Drop all Temp Objects'
  );

  Drop_Temp_Objects (
    p_request_rec => p_request_rec
    ,p_rule_rec   => p_rule_rec
  );

  ------------------------------------------------------------------------------
  -- STEP 2: If a successful object execution, update number of input rows in
  -- FEM_BALANCES before purging PFT_AR_DRIVER_VALUES_T.
  ------------------------------------------------------------------------------
  if (p_exec_status_code = G_EXEC_STATUS_SUCCESS) then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Step 2:  Update Number of Input Rows'
    );

    l_num_of_input_rows_stmt :=
    ' select count(*)'||
    ' from fem_balances b'||
    ' where b.ledger_id = :b_ledger_id'||
    ' and b.financial_elem_id not in (:b_stat_fin_elem_id,:b_act_rate_fin_elem_id)'||
    ' and b.currency_type_code = ''ENTERED'''||
    ' and '||p_input_ds_b_where_clause||
    ' and not ('||
    '   b.created_by_request_id = :b_request_id'||
    '   and b.created_by_object_id = :b_act_rate_obj_id'||
    ' )'||
    ' and exists ('||
    '   select 1'||
    '   from pft_ar_driver_values_t drv'||
    '   where drv.created_by_request_id = :b_request_id'||
    '   and drv.created_by_object_id = :b_act_rate_obj_id'||
    '   and drv.activity_id = b.activity_id'||
    ' )';

    execute immediate l_num_of_input_rows_stmt
    into l_num_of_input_rows
    using p_request_rec.ledger_id
    ,G_FIN_ELEM_ID_STATISTIC
    ,G_FIN_ELEM_ID_ACTIVITY_RATE
    ,p_request_rec.request_id
    ,p_rule_rec.act_rate_obj_id
    ,p_request_rec.request_id
    ,p_rule_rec.act_rate_obj_id;

    FEM_PL_PKG.Update_Num_Of_Input_Rows (
      p_api_version        => 1.0
      ,p_commit            => FND_API.G_FALSE
      ,p_request_id        => p_request_rec.request_id
      ,p_object_id         => p_rule_rec.act_rate_obj_id
      ,p_num_of_input_rows => l_num_of_input_rows
      ,p_user_id           => p_request_rec.user_id
      ,p_last_update_login => p_request_rec.login_id
      ,x_msg_count         => l_msg_count
      ,x_msg_data          => l_msg_data
      ,x_return_status     => l_return_status
    );

    if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      Get_Put_Messages (
        p_msg_count => l_msg_count
        ,p_msg_data => l_msg_data
      );
      raise l_rule_post_proc_error;
    end if;

    commit;

  end if;

  if (p_exec_status_code = G_EXEC_STATUS_SUCCESS) then
    ----------------------------------------------------------------------------
    -- STEP 2.1: Delete all records in the PFT_AR_DRIVER_VALUES_T table
    ----------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Step 2.1:  Purging Records in PFT_AR_DRIVER_VALUES_T'
    );

    delete from pft_ar_driver_values_t
    where created_by_request_id = p_request_rec.request_id
    and created_by_object_id = p_rule_rec.act_rate_obj_id;

    commit;

    ----------------------------------------------------------------------------
    -- STEP 2.2: Delete all records in the PFT_AR_DRIVERS_T table
    ----------------------------------------------------------------------------

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Step 2.2:  Purging Records in PFT_AR_DRIVERS_T'
    );

    delete from pft_ar_drivers_t
    where created_by_request_id = p_request_rec.request_id
    and created_by_object_id = p_rule_rec.act_rate_obj_id;

    commit;

  end if;

  ------------------------------------------------------------------------------
  -- STEP 3: Update Number of Output Rows.
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'Step 3:  Update Number of Output Rows'
  );

  select count(*)
  into l_num_of_output_rows
  from fem_balances
  where dataset_code = p_request_rec.output_dataset_code
  and cal_period_id = p_request_rec.output_cal_period_id
  and created_by_request_id = p_request_rec.request_id
  and created_by_object_id = p_rule_rec.act_rate_obj_id
  and ledger_id = p_request_rec.ledger_id;

  -- Unregister the data location for the FEM_BALANCES output table if no
  -- output rows were created.
  if (l_num_of_output_rows = 0) then

    FEM_DIMENSION_UTIL_PKG.Unregister_Data_Location (
      p_request_id   => p_request_rec.request_id
      ,p_object_id   => p_rule_rec.act_rate_obj_id
    );

  end if;

  -- Set the number of output rows for the FEM_BALANCES output table.
  FEM_PL_PKG.Update_Num_Of_Output_Rows (
    p_api_version         => 1.0
    ,p_commit             => FND_API.G_FALSE
    ,p_request_id         => p_request_rec.request_id
    ,p_object_id          => p_rule_rec.act_rate_obj_id
    ,p_table_name         => 'FEM_BALANCES'
    ,p_statement_type     => 'INSERT'
    ,p_num_of_output_rows => l_num_of_output_rows
    ,p_user_id            => p_request_rec.user_id
    ,p_last_update_login  => p_request_rec.login_id
    ,x_msg_count          => l_msg_count
    ,x_msg_data           => l_msg_data
    ,x_return_status      => l_return_status
  );

  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
    Get_Put_Messages (
      p_msg_count => l_msg_count
      ,p_msg_data => l_msg_data
    );
    raise l_rule_post_proc_error;
  end if;

  ------------------------------------------------------------------------------
  -- STEP 4: Update Object Execution Status.
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'Step 4:  Update Object Execution Status'
  );

  FEM_PL_PKG.Update_Obj_Exec_Status (
    p_api_version        => 1.0
    ,p_commit            => FND_API.G_FALSE
    ,p_request_id        => p_request_rec.request_id
    ,p_object_id         => p_rule_rec.act_rate_obj_id
    ,p_exec_status_code  => p_exec_status_code
    ,p_user_id           => p_request_rec.user_id
    ,p_last_update_login => p_request_rec.login_id
    ,x_msg_count         => l_msg_count
    ,x_msg_data          => l_msg_data
    ,x_return_status     => l_return_status
  );

  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
    Get_Put_Messages (
      p_msg_count => l_msg_count
      ,p_msg_data => l_msg_data
    );
    raise l_rule_post_proc_error;
  end if;

  ------------------------------------------------------------------------------
  -- STEP 5: Update Object Execution Errors.
  ------------------------------------------------------------------------------
  if (p_exec_status_code <> G_EXEC_STATUS_SUCCESS) then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Step 5:  Update Object Execution Errors'
    );

    -- An Activity Rate Rule is an all or nothing deal, so only 1 error can be reported
    FEM_PL_PKG.Update_Obj_Exec_Errors (
      p_api_version         => 1.0
      ,p_commit             => FND_API.G_FALSE
      ,p_request_id         => p_request_rec.request_id
      ,p_object_id          => p_rule_rec.act_rate_obj_id
      ,p_errors_reported    => 1
      ,p_errors_reprocessed => 0
      ,p_user_id            => p_request_rec.user_id
      ,p_last_update_login  => p_request_rec.login_id
      ,x_msg_count          => l_msg_count
      ,x_msg_data           => l_msg_data
      ,x_return_status      => l_return_status
    );

    if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      Get_Put_Messages (
        p_msg_count => l_msg_count
        ,p_msg_data => l_msg_data
      );
      raise l_rule_post_proc_error;
    end if;

  end if;

  commit;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_rule_post_proc_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => g_log_level_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Rule Post Process Exception'
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_ENG_RULE_POST_PROC_ERR
    );

    raise g_act_rate_request_error;

END Rule_Post_Proc;



/*===========================================================================+
 | PROCEDURE
 |   Request_Post_Proc
 |
 | DESCRIPTION
 |   Updates the status of the request in the processing locks tables.
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

PROCEDURE Request_Post_Proc (
  p_request_rec                   in request_record
  ,p_exec_status_code             in varchar2
)
IS

  L_API_NAME             constant varchar2(30) := 'Request_Post_Proc';

  l_return_status                 varchar2(1);
  l_msg_count                     number;
  l_msg_data                      varchar2(240);

  l_request_post_proc_error       exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'BEGIN'
  );

  if (p_request_rec.submit_obj_type_code = 'RULE_SET') then

    ----------------------------------------------------------------------------
    -- STEP 1: Purge RULE_SET_PROCESS_DATA table
    ----------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Step 1:  Purge RULE_SET_PROCESS_DATA table'
    );

    FEM_RULE_SET_MANAGER.FEM_DeleteFlatRuleList_PVT (
      p_api_version                  => 1.0
      ,p_init_msg_list               => FND_API.G_FALSE
      ,p_commit                      => FND_API.G_TRUE
      ,p_encoded                     => FND_API.G_TRUE
      ,x_return_status               => l_return_status
      ,x_msg_count                   => l_msg_count
      ,x_msg_data                    => l_msg_data
      ,p_ruleset_object_id           => p_request_rec.ruleset_obj_id
    );

    if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      Get_Put_Messages (
        p_msg_count => l_msg_count
        ,p_msg_data => l_msg_data
      );
      raise l_request_post_proc_error;
    end if;

  end if;

  ------------------------------------------------------------------------------
  -- STEP 2: Update Request Status.
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'Step 2:  Update Request Status'
  );

  FEM_PL_PKG.Update_Request_Status (
    p_api_version        => 1.0
    ,p_commit            => FND_API.G_FALSE
    ,p_request_id        => p_request_rec.request_id
    ,p_exec_status_code  => p_exec_status_code
    ,p_user_id           => p_request_rec.user_id
    ,p_last_update_login => p_request_rec.login_id
    ,x_msg_count         => l_msg_count
    ,x_msg_data          => l_msg_data
    ,x_return_status     => l_return_status
  );

  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
    Get_Put_Messages (
      p_msg_count => l_msg_count
      ,p_msg_data => l_msg_data
    );
    raise l_request_post_proc_error;
  end if;

  commit;

  ------------------------------------------------------------------------------
  -- STEP 3: Set the final execution status message in the log file.
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'Step 3:  Set the final execution message in the Log File'
  );

  if (p_exec_status_code = G_EXEC_STATUS_SUCCESS) then
    FEM_ENGINES_PKG.user_message (
      p_app_name  => G_FEM
      ,p_msg_name => G_EXEC_SUCCESS
    );
  else
    FEM_ENGINES_PKG.user_message (
      p_app_name  => G_FEM
      ,p_msg_name => G_EXEC_RERUN
    );
  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_request_post_proc_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => g_log_level_6
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'Request Post Process Exception'
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_ENG_REQ_POST_PROC_ERR
    );

    raise g_act_rate_request_error;

END Request_Post_Proc;

/*============================================================================+
 | FUNCTION
 |   Get_Lookup_Meaning
 |
 | DESCRIPTION
 |   Utility function to return the meaning for the specified lookup type and
 |   lookup code.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

FUNCTION Get_Lookup_Meaning (
  p_lookup_type                   in varchar2
  ,p_lookup_code                  in varchar2
)
RETURN varchar2
IS

  l_api_name             constant varchar2(30) := 'Get_Lookup_Meaning';
  l_meaning                       varchar2(80);

BEGIN

  select meaning
  into l_meaning
  from fnd_lookup_values
  where lookup_type = p_lookup_type
  and lookup_code = p_lookup_code
  and view_application_id = 274
  and language = userenv('LANG');

  return l_meaning;

EXCEPTION

  when others then
    return null;

END Get_Lookup_Meaning;



/*===========================================================================+
 | PROCEDURE
 |   Get_Put_Messages
 |
 | DESCRIPTION
 |   Copied from FEM_DATAX_LOADER_PKG.  Will be replaced when Get_Put_Messages
 |   is placed in the common loader package.
 |
 | SCOPE - PRIVATE
 |
 +===========================================================================*/

PROCEDURE Get_Put_Messages (
  p_msg_count                     in number
  ,p_msg_data                     in varchar2
)
IS

  L_API_NAME             constant varchar2(30) := 'Get_Put_Messages';

  l_msg_count                     number;
  l_msg_data                      varchar2(4000);
  l_msg_out                       number;
  l_message                       varchar2(4000);

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||L_API_NAME
    ,p_msg_text => 'msg_count='||p_msg_count
  );

  l_msg_data := p_msg_data;

  if (p_msg_count = 1) then

    FND_MESSAGE.Set_Encoded(l_msg_data);
    l_message := FND_MESSAGE.Get;

    FEM_ENGINES_PKG.User_Message (
      p_msg_text => l_message
    );

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_2
      ,p_module   => G_BLOCK||'.'||L_API_NAME
      ,p_msg_text => 'msg_data='||l_message
    );

  elsif (p_msg_count > 1) then

    for i in 1..p_msg_count loop

      FND_MSG_PUB.Get (
        p_msg_index      => i
        ,p_encoded       => FND_API.G_FALSE
        ,p_data          => l_message
        ,p_msg_index_out => l_msg_out
      );

      FEM_ENGINES_PKG.User_Message (
        p_msg_text => l_message
      );

      FEM_ENGINES_PKG.Tech_Message (
        p_severity  => G_LOG_LEVEL_2
        ,p_module   => G_BLOCK||'.'||L_API_NAME
        ,p_msg_text => 'msg_data='||l_message
      );

    end loop;

  end if;

  FND_MSG_PUB.Initialize;

END Get_Put_Messages;



END PFT_AR_ENGINE_PVT;

/
