--------------------------------------------------------
--  DDL for Package Body FEM_RU_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_RU_ENGINE_PVT" AS
/* $Header: FEMVRUEB.pls 120.6 2006/09/21 08:27:32 nmartine noship $ */


-------------------------------
-- Declare package constants --
-------------------------------

  -- Constants for p_exec_status_code
  G_EXEC_STATUS_RUNNING        constant varchar2(30) := 'RUNNING';
  G_EXEC_STATUS_SUCCESS        constant varchar2(30) := 'SUCCESS';
  G_EXEC_STATUS_ERROR_UNDO     constant varchar2(30) := 'ERROR_UNDO';
  G_EXEC_STATUS_ERROR_RERUN    constant varchar2(30) := 'ERROR_RERUN';

  -- Default Fetch Limit if none is specified in Profile Options
  G_DEFAULT_FETCH_LIMIT       constant number := 99999;

  -- Log Level Constants
  G_LOG_LEVEL_1               constant number := FND_LOG.Level_Statement;
  G_LOG_LEVEL_2               constant number := FND_LOG.Level_Procedure;
  G_LOG_LEVEL_3               constant number := FND_LOG.Level_Event;
  G_LOG_LEVEL_4               constant number := FND_LOG.Level_Exception;
  G_LOG_LEVEL_5               constant number := FND_LOG.Level_Error;
  G_LOG_LEVEL_6               constant number := FND_LOG.Level_Unexpected;

  -- Seeded Financial Element IDs
  G_FIN_ELEM_ID_STATISTIC      constant number := 10000;
  G_FIN_ELEM_ID_ACTIVITY_RATE  constant number := 5005;


------------------------------
-- Declare package messages --
------------------------------
  G_EXEC_RERUN                 constant varchar2(30) := 'FEM_EXEC_RERUN';
  G_EXEC_SUCCESS               constant varchar2(30) := 'FEM_EXEC_SUCCESS';
  G_UNEXPECTED_ERROR           constant varchar2(30) := 'FEM_UNEXPECTED_ERROR';
  G_NO_TABLE_CLASS_ERR         constant varchar2(30) := 'FEM_NO_TABLE_CLASS_ERR';

  G_ENG_BAD_CURRENCY_ERR       constant varchar2(30) := 'FEM_ENG_BAD_CURRENCY_ERR';
  G_ENG_BAD_DS_WCLAUSE_ERR     constant varchar2(30) := 'FEM_ENG_BAD_DS_WCLAUSE_ERR';
  G_ENG_BAD_HIER_DIM_ERR       constant varchar2(30) := 'FEM_ENG_BAD_HIER_DIM_ERR';
  G_ENG_BAD_LCL_VS_COMBO_ERR   constant varchar2(30) := 'FEM_ENG_BAD_LCL_VS_COMBO_ERR';
  G_ENG_BAD_OBJ_TYPE_ERR       constant varchar2(30) := 'FEM_ENG_BAD_OBJ_TYPE_ERR';
  G_ENG_BAD_RS_OBJ_TYPE_ERR    constant varchar2(30) := 'FEM_ENG_BAD_RS_OBJ_TYPE_ERR';
  G_ENG_COND_WHERE_CLAUSE_ERR  constant varchar2(30) := 'FEM_ENG_COND_WHERE_CLAUSE_ERR';
  G_ENG_CREATE_SEQUENCE_ERR    constant varchar2(30) := 'FEM_ENG_CREATE_SEQUENCE_ERR';
  G_ENG_DROP_SEQUENCE_WRN      constant varchar2(30) := 'FEM_ENG_DROP_SEQUENCE_WRN';
  G_ENG_NO_DIM_ATTR_VAL_ERR    constant varchar2(30) := 'FEM_ENG_NO_DIM_ATTR_VAL_ERR';
  G_ENG_NO_DIM_ATTR_VER_ERR    constant varchar2(30) := 'FEM_ENG_NO_DIM_ATTR_VER_ERR';
  G_ENG_NO_DIM_DTL_ERR         constant varchar2(30) := 'FEM_ENG_NO_DIM_DTL_ERR';
  G_ENG_NO_DIM_MEMBER_ERR      constant varchar2(30) := 'FEM_ENG_NO_DIM_MEMBER_ERR';
  G_ENG_NO_EXCH_RATE_ERR       constant varchar2(30) := 'FEM_ENG_NO_EXCH_RATE_ERR';
  G_ENG_NO_OBJ_ERR             constant varchar2(30) := 'FEM_ENG_NO_OBJ_ERR';
  G_ENG_NO_OBJ_DEF_DTL_ERR     constant varchar2(30) := 'FEM_ENG_NO_OBJ_DEF_DTL_ERR';
  G_ENG_NO_OBJ_DEF_ERR         constant varchar2(30) := 'FEM_ENG_NO_OBJ_DEF_ERR';
  G_ENG_NO_OBJ_DTL_ERR         constant varchar2(30) := 'FEM_ENG_NO_OBJ_DTL_ERR';
  G_ENG_NO_OUTPUT_DS_ERR       constant varchar2(30) := 'FEM_ENG_NO_OUTPUT_DS_ERR';
  G_ENG_NO_PROF_OPTION_VAL_ERR constant varchar2(30) := 'FEM_ENG_NO_PROF_OPTION_VAL_ERR';
  G_ENG_NO_SUBMIT_OBJ_ERR      constant varchar2(30) := 'FEM_ENG_NO_SUBMIT_OBJ_ERR';
  G_ENG_REQ_POST_PROC_ERR      constant varchar2(30) := 'FEM_ENG_REQ_POST_PROC_ERR';
  G_ENG_RS_RULE_PROCESSING_TXT constant varchar2(30) := 'FEM_ENG_RS_RULE_PROCESSING_TXT';
  G_ENG_RULE_POST_PROC_ERR     constant varchar2(30) := 'FEM_ENG_RULE_POST_PROC_ERR';

  G_RU_COND_NODES_LEAFS_ERR    constant varchar2(30) := 'FEM_RU_COND_NODES_LEAFS_ERR';
  G_RU_HIER_CIRC_REF_ERR       constant varchar2(30) := 'FEM_RU_HIER_CIRC_REF_ERR';
  G_RU_NO_ROLLUP_DIM_ERR       constant varchar2(30) := 'FEM_RU_NO_ROLLUP_DIM_ERR';
  G_RU_NO_COND_NODES_FOUND_ERR constant varchar2(30) := 'FEM_RU_NO_COND_NODES_FOUND_ERR';
  G_RU_NO_ROOT_NODES_FOUND_ERR constant varchar2(30) := 'FEM_RU_NO_ROOT_NODES_FOUND_ERR';
  G_RU_UNCOSTED_NODES_ERR      constant varchar2(30) := 'FEM_RU_UNCOSTED_NODES_ERR';


--------------------------------------
-- Declare package type definitions --
--------------------------------------
  t_return_status                 varchar2(1);
  t_msg_count                     number;
  t_msg_data                      varchar2(2000);

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

  -- Track Event Chains
  g_currency_conv_type            varchar2(30);

  -- Ledger Variables
  g_ledger_dimension_id           number;
  g_ledger_curr_attr_id           number;
  g_ledger_curr_attr_version_id   number;

  -- Cross Ledger Table
  g_xledger_tbl                   ledger_table;


--------------------------------
-- Declare package exceptions --
--------------------------------
  -- General Rollup Request Exception
  g_rollup_request_error          exception;

  -- Connect By Loop Exception
  g_connect_by_loop_error         exception;
  pragma exception_init (g_connect_by_loop_error, -1436);


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
  ,x_rollup_rule_def_stmt         out nocopy long
  ,x_input_ds_b_where_clause      out nocopy long
  ,x_input_ds_q_where_clause      out nocopy long
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
  ,x_dim_attribute_varchar_member out nocopy varchar2
  ,x_date_assign_value            out nocopy date
);

PROCEDURE Get_Ledger_Currency_Code (
  p_ledger_id                     in varchar2
  ,x_currency_code                out nocopy varchar2
);

PROCEDURE Get_Dim_Attribute (
  p_dimension_varchar_label       in varchar2
  ,p_attribute_varchar_label      in varchar2
  ,x_dimension_rec                out nocopy dimension_record
  ,x_attribute_id                 out nocopy number
  ,x_attr_version_id              out nocopy number
);

PROCEDURE Sql_Stmts_Prep (
  p_request_rec                   in request_record
  ,x_sql_rec                      out nocopy sql_record
);

PROCEDURE Register_Request (
  p_request_rec                   in request_record
);

PROCEDURE Rollup_Rule (
  p_request_rec                   in request_record
  ,p_sql_rec                      in sql_record
  ,p_rollup_obj_id                in number
  ,p_rollup_obj_def_id            in number
  ,p_rollup_sequence              in number
  ,p_rollup_rule_def_stmt         in long
  ,p_input_ds_b_where_clause      in long
  ,p_input_ds_q_where_clause      in long
  ,x_return_status                out nocopy varchar2
);

PROCEDURE Rule_Prep (
  p_request_rec                   in request_record
  ,p_rollup_obj_id                in number
  ,p_rollup_obj_def_id            in number
  ,p_rollup_sequence              in number
  ,p_rollup_rule_def_stmt         in long
  ,x_rule_rec                     out nocopy rule_record
);

PROCEDURE Sql_Stmts_Build (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
  ,p_sql_rec                      in sql_record
  ,p_input_ds_b_where_clause      in long
  ,p_input_ds_q_where_clause      in long
  ,x_find_children_stmt           out nocopy long
  ,x_rollup_parent_stmt           out nocopy long
  ,x_find_child_chains_stmt       out nocopy long
  ,x_num_of_input_rows_stmt       out nocopy long
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

PROCEDURE Create_Temp_Objects (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
);

PROCEDURE Drop_Temp_Objects (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
);

PROCEDURE Find_Condition_Nodes (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
);

PROCEDURE Find_Root_Nodes (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
);

PROCEDURE Rollup_Top_Node (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
  ,p_find_children_stmt           in long
  ,p_rollup_parent_stmt           in long
  ,p_find_child_chains_stmt       in long
  ,p_input_ds_b_where_clause      in long
  ,p_top_node_id                  in number
);

PROCEDURE Rollup_Parent_Node (
  p_request_id                    in number
  ,p_rollup_obj_id                in number
  ,p_hier_obj_def_id              in number
  ,p_dimension_varchar_label      in varchar2
  ,p_rollup_type_code             in varchar2
  ,p_cond_exists                  in boolean
  ,p_sequence_name                in varchar2
  ,p_source_system_code           in number
  ,p_ledger_id                    in number
  ,p_parent_id                    in number
  ,p_parent_depth_num             in number
  ,p_statistic_basis_id           in number
  ,p_find_children_stmt           in long
  ,p_rollup_parent_stmt           in long
  ,p_find_child_chains_stmt       in long
  ,p_output_dataset_code          in number
  ,p_output_cal_period_id         in number
  ,p_exch_rate_date               in date
  ,p_functional_currency_code     in varchar2
  ,p_entered_currency_code        in varchar2
  ,p_entered_exch_rate_num        in number
  ,p_entered_exch_rate_den        in number
  ,p_user_id                      in number
  ,p_login_id                     in number
);

PROCEDURE Register_Child_Chains (
  p_request_id                    in number
  ,p_rollup_obj_id                in number
  ,p_dimension_varchar_label      in varchar2
  ,p_rollup_type_code             in varchar2
  ,p_ledger_id                    in number
  ,p_statistic_basis_id           in number
  ,p_find_child_chains_stmt       in long
  ,p_child_id                     in number
  ,p_user_id                      in number
  ,p_login_id                     in number
);

PROCEDURE Rule_Post_Proc (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
  ,p_num_of_input_rows_stmt       in long
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

FUNCTION Get_Object_Type_Name (
  p_object_type_code              in varchar2
)
RETURN varchar2;

PROCEDURE Get_Put_Messages (
  p_msg_count                     in number
  ,p_msg_data                     in varchar2
);


--------------------------------------------------------------------------------
--  Package bodies for functions/procedures
--------------------------------------------------------------------------------

/*============================================================================+
 | PROCEDURE
 |   Rollup_Request
 |
 | DESCRIPTION
 |   Main engine procedure for rollup processing.
 |
 | SCOPE - PUBLIC
 |
 | MODIFICATION HISTORY
 |   nmartine   13-JUL-2004  Created
 |
 +============================================================================*/

PROCEDURE Rollup_Request (
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
  l_api_name             constant varchar2(30) := 'Rollup_Request';

  -----------------------
  -- Declare variables --
  -----------------------
  l_request_rec                   request_record;
  l_sql_rec                       sql_record;

  l_rollup_obj_id                 number;
  l_rollup_obj_def_id             number;
  l_rollup_exec_status_code       varchar2(30);
  l_rollup_sequence               number;

  l_rollup_rule_def_stmt          long;
  l_input_ds_b_where_clause       long;
  l_input_ds_q_where_clause       long;

  l_completion_status             boolean;

  l_ruleset_status                varchar2(1);

  l_return_status                 t_return_status%TYPE;
  l_msg_count                     t_msg_count%TYPE;
  l_msg_data                      t_msg_data%TYPE;

  l_err_code                      number;
  l_err_msg                       varchar2(30);

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
  from fem_ruleset_process_data rs
  ,fem_pl_object_executions x
  where rs.request_id = p_request_id
  and rs.rule_set_obj_id = p_ruleset_obj_id
  and x.request_id (+) = rs.request_id
  and x.object_id (+) = rs.child_obj_id
  and x.exec_object_definition_id (+) = rs.child_obj_def_id
  order by rs.engine_execution_sequence;

/******************************************************************************
 *                                                                            *
 *                              Rollup Request                                *
 *                              Execution Block                               *
 *                                                                            *
 ******************************************************************************/

BEGIN

  -- Initialize Message Stack on FND_MSG_PUB
  FND_MSG_PUB.Initialize;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  ------------------------------------------------
  -- Initialize Package and Procedure Variables --
  ------------------------------------------------

  -- Ledger Variables
  g_ledger_dimension_id := null;
  g_ledger_curr_attr_id := null;
  g_ledger_curr_attr_version_id := null;

  -- Cross Ledger Table
  g_xledger_tbl.DELETE;

  ------------------------------------------------------------------------------
  -- STEP 1: Request Preparation
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.tech_message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 1: Request Preperation'
  );

  Request_Prep (
    p_obj_id                       => p_obj_id
    ,p_effective_date_varchar      => p_effective_date
    ,p_ledger_id                   => p_ledger_id
    ,p_output_cal_period_id        => p_output_cal_period_id
    ,p_dataset_grp_obj_def_id      => p_dataset_grp_obj_def_id
    ,p_continue_process_on_err_flg => p_continue_process_on_err_flg
    ,p_source_system_code          => p_source_system_code
    ,x_request_rec                 => l_request_rec
    ,x_rollup_rule_def_stmt        => l_rollup_rule_def_stmt
    ,x_input_ds_b_where_clause     => l_input_ds_b_where_clause
    ,x_input_ds_q_where_clause     => l_input_ds_q_where_clause
  );

  ------------------------------------------------------------------------------
  -- STEP 2: Dynamic SQL Statments Preparation
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 2: Dynamic SQL Statments Preparation'
  );

  Sql_Stmts_Prep (
    p_request_rec => l_request_rec
    ,x_sql_rec    => l_sql_rec
  );

  ------------------------------------------------------------------------------
  -- STEP 3: Register Request
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 3: Register Request'
  );

  Register_Request (
    p_request_rec => l_request_rec
  );

  ------------------------------------------------------------------------------
  -- STEP 4: Start Rollup Processing
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 4: Start Rollup Processing'
  );

  -- Initialize the rollup sequence to 0
  -- For Single Rule Submit, the sequence will remain at 0.
  -- For Rule Set Submit, the sequence for rule processing will be 1 to n.
  l_rollup_sequence := 0;

  if (l_request_rec.submit_obj_type_code <> 'RULE_SET') then

    ----------------------------------------------------------------------------
    -- STEP 4.1: Single Rule Submit Processing
    ----------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Step 4.1: Single Rule Submit Processing'
    );

    l_rollup_obj_id := l_request_rec.submit_obj_id;
    l_rollup_obj_def_id := null;

    ----------------------------------------------------------------------------
    -- STEP 4.1.1: Validate Single Rule Submit
    ----------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Step 4.1.1: Single Rule Submit Processing'
    );

    FEM_RULE_SET_MANAGER.Validate_Rule_Public (
      x_err_code             => l_err_code
      ,x_err_msg             => l_err_msg
      ,p_rule_object_id      => l_rollup_obj_id
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
      raise g_rollup_request_error;
    end if;

    ----------------------------------------------------------------------------
    -- STEP 4.1.2: Rollup Single Rule
    ----------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Step 4.1.2: Rollup Single Rule'
    );

    Rollup_Rule (
      p_request_rec              => l_request_rec
      ,p_sql_rec                 => l_sql_rec
      ,p_rollup_obj_id           => l_rollup_obj_id
      ,p_rollup_obj_def_id       => l_rollup_obj_def_id
      ,p_rollup_sequence         => l_rollup_sequence
      ,p_rollup_rule_def_stmt    => l_rollup_rule_def_stmt
      ,p_input_ds_b_where_clause => l_input_ds_b_where_clause
      ,p_input_ds_q_where_clause => l_input_ds_q_where_clause
      ,x_return_status           => l_return_status
    );

    if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      -- For Single Rule Rollup, raise exception to end request immediately
      -- with a completion status of ERROR, regardless of the value for
      -- the continue_process_on_err_flg parameter.
      raise g_rollup_request_error;
    end if;

  else

    ----------------------------------------------------------------------------
    -- STEP 4.2: Rule Set Processing
    ----------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Step 4.2: Rule Set Processing'
    );

    ----------------------------------------------------------------------------
    -- STEP 4.2.1: Rule Set Pre Processing
    ----------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Step 4.2.1: Rule Set Pre Processing'
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
      ,p_execution_mode              => 'E' -- Engine Execution Mode
    );

    if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      Get_Put_Messages (
        p_msg_count => l_msg_count
        ,p_msg_data => l_msg_data
      );
      raise g_rollup_request_error;
    end if;

    ----------------------------------------------------------------------------
    -- STEP 4.2.2: Loop through all Rule Set Rules
    ----------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Step 4.2.2: Loop through all Rule Set Rules'
    );

    -- Initialize the rule set status to SUCCESS.
    l_ruleset_status := FND_API.G_RET_STS_SUCCESS;

    open l_ruleset_rules_csr (
      p_request_id      => l_request_rec.request_id
      ,p_ruleset_obj_id => l_request_rec.ruleset_obj_id
    );

    loop

      fetch l_ruleset_rules_csr
      into l_rollup_obj_id
      ,l_rollup_obj_def_id
      ,l_rollup_exec_status_code;

      exit when l_ruleset_rules_csr%NOTFOUND;

      l_rollup_sequence := l_rollup_sequence + 1;

      -- Do not process rule set rollup rules that completed successfully
      if ( (l_rollup_exec_status_code is null)
        or (l_rollup_exec_status_code <> 'SUCCESS') ) then

        ------------------------------------------------------------------------
        -- STEP 4.2.3: Rollup Rule Set Rule
        ------------------------------------------------------------------------
        FEM_ENGINES_PKG.Tech_Message (
          p_severity  => G_LOG_LEVEL_1
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 4.2.3: Rollup Rule Set Rule #'||to_char(l_rollup_sequence)
        );

        Rollup_Rule (
          p_request_rec              => l_request_rec
          ,p_sql_rec                 => l_sql_rec
          ,p_rollup_obj_id           => l_rollup_obj_id
          ,p_rollup_obj_def_id       => l_rollup_obj_def_id
          ,p_rollup_sequence         => l_rollup_sequence
          ,p_rollup_rule_def_stmt    => l_rollup_rule_def_stmt
          ,p_input_ds_b_where_clause => l_input_ds_b_where_clause
          ,p_input_ds_q_where_clause => l_input_ds_q_where_clause
          ,x_return_status           => l_return_status
        );

        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
          -- Set the request status to match Rollup_Rule's return status.
          l_ruleset_status := l_return_status;
          if (l_request_rec.continue_process_on_err_flg = 'N') then
            -- Raise exception to end request immediately with a completion
            -- status of ERROR.
            raise g_rollup_request_error;
          end if;
        end if;

      end if;

    end loop;

    close l_ruleset_rules_csr;

    if (l_ruleset_status <> FND_API.G_RET_STS_SUCCESS) then
      -- Raise exception to end request with a completion status of ERROR,
      -- if the rule set status is not equal to SUCCESS.
      raise g_rollup_request_error;
    end if;

  end if;

  ------------------------------------------------------------------------------
  -- STEP 5: Request Post Processing.
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 5: Request Post Processing'
  );

  Request_Post_Proc (
    p_request_rec       => l_request_rec
    ,p_exec_status_code => G_EXEC_STATUS_SUCCESS
  );

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when g_rollup_request_error then

    if (l_ruleset_rules_csr%ISOPEN) then
     close l_ruleset_rules_csr;
    end if;

    Request_Post_Proc (
      p_request_rec       => l_request_rec
      ,p_exec_status_code => G_EXEC_STATUS_ERROR_UNDO
    );

    l_completion_status := FND_CONCURRENT.Set_Completion_Status('ERROR',null);

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Rollup Request Exception'
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
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name||'.Unexpected_Exception'
      ,p_msg_text => g_prg_msg
    );

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name||'.Unexpected_Exception'
      ,p_msg_text => g_callstack
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_UNEXPECTED_ERROR
      ,p_token1   => 'ERR_MSG'
      ,p_value1   => g_prg_msg
    );

END Rollup_Request;



/*============================================================================+
 | PROCEDURE
 |   Request_Prep
 |
 | DESCRIPTION
 |   Rollup Request Preparation.  Populates the request record and parameters
 |   that are common to all rollup rules that will be processed.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

PROCEDURE Request_Prep (
  p_obj_id                        in number
  ,p_effective_date_varchar       in varchar2
  ,p_ledger_id                    in number
  ,p_output_cal_period_id         in number
  ,p_dataset_grp_obj_def_id       in number
  ,p_continue_process_on_err_flg  in varchar2
  ,p_source_system_code           in number
  ,x_request_rec                  out nocopy request_record
  ,x_rollup_rule_def_stmt         out nocopy long
  ,x_input_ds_b_where_clause      out nocopy long
  ,x_input_ds_q_where_clause      out nocopy long
)
IS

  l_api_name             constant varchar2(30) := 'Request_Prep';

  l_object_name                   varchar2(150);
  l_folder_name                   varchar2(150);

  l_dimension_varchar_label       varchar2(30);
  l_dummy_varchar                 varchar2(30);
  l_dummy_date                    date;

  l_return_status                 t_return_status%TYPE;
  l_msg_count                     t_msg_count%TYPE;
  l_msg_data                      t_msg_data%TYPE;

  l_request_prep_error            exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
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
      ,x_request_rec.pgm_app_id
    )
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
      ,p_msg_name => G_ENG_NO_PROF_OPTION_VAL_ERR
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
          ,p_msg_name => G_ENG_NO_OBJ_ERR
          ,p_token1   => 'OBJECT_TYPE_MEANING'
          ,p_value1   => Get_Object_Type_Name('RULE_SET')
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

    -- Set the Object Type Code for the Rollup Process
    begin
      select rule_set_object_type_code
      into x_request_rec.rollup_obj_type_code
      from fem_rule_sets
      where rule_set_obj_def_id = x_request_rec.ruleset_obj_def_id;
    exception
      when others then
        FEM_ENGINES_PKG.User_Message (
          p_app_name  => G_FEM
          ,p_msg_name => G_ENG_NO_OBJ_DEF_DTL_ERR
          ,p_token1   => 'TABLE_NAME'
          ,p_value1   => 'FEM_RULE_SETS'
          ,p_token2   => 'OBJECT_TYPE_MEANING'
          ,p_value2   => Get_Object_Type_Name('RULE_SET')
          ,p_token3   => 'OBJECT_ID'
          ,p_value3   => x_request_rec.ruleset_obj_id
          ,p_token4   => 'OBJECT_DEF_ID'
          ,p_value4   => x_request_rec.ruleset_obj_def_id
        );
        raise l_request_prep_error;
    end;

  else

    x_request_rec.ruleset_obj_id := null;
    x_request_rec.ruleset_obj_name := null;
    x_request_rec.ruleset_obj_def_id := null;

    -- Set the Object Type Code for the Rollup Process
    x_request_rec.rollup_obj_type_code := x_request_rec.submit_obj_type_code;

  end if;

  ------------------------------------------------------------------------------
  -- Set rollup parameters depending on the Rollup Rule's Object Type Code
  ------------------------------------------------------------------------------
  if (x_request_rec.rollup_obj_type_code = 'COUC_ROLLUP') then

    l_dimension_varchar_label := 'COST_OBJECT';
    x_request_rec.rollup_type_code := 'COST';
    x_request_rec.rollup_rule_def_table := 'PFT_COUC_ROLLUP_RULES';
    x_rollup_rule_def_stmt :=
      ' select cost_object_hier_obj_id'||
      ' ,condition_obj_id'||
      ' ,currency_code'||
      ' ,null'||
      ' from pft_couc_rollup_rules'||
      ' where couc_rollup_obj_def_id = :b_rollup_obj_def_id';

  elsif (x_request_rec.rollup_obj_type_code = 'ACT_COST_ROLLUP') then

    l_dimension_varchar_label := 'ACTIVITY';
    x_request_rec.rollup_type_code := 'COST';
    x_request_rec.rollup_rule_def_table := 'PFT_ACTIVITY_COST_RU';
    x_rollup_rule_def_stmt :=
      ' select activity_hier_obj_id'||
      ' ,condition_obj_id'||
      ' ,currency_code'||
      ' ,null'||
      ' from pft_activity_cost_ru'||
      ' where cost_rollup_obj_def_id = :b_rollup_obj_def_id';

  elsif (x_request_rec.rollup_obj_type_code = 'ACT_STAT_ROLLUP') then

    l_dimension_varchar_label := 'ACTIVITY';
    x_request_rec.rollup_type_code := 'STAT';
    x_request_rec.rollup_rule_def_table := 'PFT_ACTIVITY_STAT_RU';
    x_rollup_rule_def_stmt :=
      ' select activity_hier_obj_id'||
      ' ,condition_obj_id'||
      ' ,''STAT'''||
      ' ,statistic_basis_id'||
      ' from pft_activity_stat_ru'||
      ' where stat_rollup_obj_def_id = :b_rollup_obj_def_id';

  else

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_ENG_BAD_OBJ_TYPE_ERR
      ,p_token1   => 'OBJECT_TYPE_CODE'
      ,p_value1   => x_request_rec.rollup_obj_type_code
    );
    raise l_request_prep_error;

  end if;

  ------------------------------------------------------------------------------
  -- Get Dimension Metadata
  ------------------------------------------------------------------------------
  Get_Dimension_Record (
    p_dimension_varchar_label    => l_dimension_varchar_label
    ,x_dimension_rec             => x_request_rec.dimension_rec
  );

  ------------------------------------------------------------------------------
  -- Check that FEM_BALANCES has the ABM_LEDGER table classification.
  ------------------------------------------------------------------------------
  -- Check added with bug 4510785
  begin
    select 'Y'
    into l_dummy_varchar
    from fem_table_class_assignmt_v
    where table_classification_code = 'ABM_LEDGER'
    and table_name = 'FEM_BALANCES';
  exception
    when no_data_found then
      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_NO_TABLE_CLASS_ERR
        ,p_token1   => 'TABLE_NAME'
        ,p_value1   => 'FEM_BALANCES'
        ,p_token2   => 'TABLE_CLASSIFICATION'
        ,p_value2   => Get_Lookup_Meaning('FEM_TABLE_CLASSIFICATION_DSC','ABM_LEDGER')
      );
      raise l_request_prep_error;
  end;

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
  -- Get the Source System Code for PFT if a null param value was passed.
  ------------------------------------------------------------------------------
  if (x_request_rec.source_system_code is null) then

    -- For all Rollup Processing default the Source System Display Code to PFT
    begin
      select source_system_code
      into x_request_rec.source_system_code
      from fem_source_systems_b
      where source_system_display_code = G_PFT_SOURCE_SYSTEM_DC;
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
        ,p_msg_name => G_ENG_NO_OBJ_ERR
        ,p_token1   => 'OBJECT_TYPE_MEANING'
        ,p_value1   => Get_Object_Type_Name('DATASET_IO_DEFINITION')
        ,p_token2   => 'OBJECT_ID'
        ,p_value2   => x_request_rec.dataset_grp_obj_id
      );
      raise l_request_prep_error;
  end;

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
  -- Call the Where Clause Generator for source data in FEM_COST_OBJECT_HIER_QTY
  ------------------------------------------------------------------------------
  if (x_request_rec.dimension_rec.dimension_varchar_label = 'COST_OBJECT') then

    FEM_DS_WHERE_CLAUSE_GENERATOR.FEM_Gen_DS_WClause_PVT (
      p_api_version       => 1.0
      ,p_init_msg_list    => FND_API.G_FALSE
      ,p_encoded          => FND_API.G_TRUE
      ,x_return_status    => l_return_status
      ,x_msg_count        => l_msg_count
      ,x_msg_data         => l_msg_data
      ,p_ds_io_def_id     => x_request_rec.dataset_grp_obj_def_id
      ,p_output_period_id => x_request_rec.output_cal_period_id
      ,p_table_name       => 'FEM_COST_OBJECT_HIER_QTY'
      ,p_table_alias      => 'Q'
      ,p_ledger_id        => x_request_rec.ledger_id
      ,p_where_clause     => x_input_ds_q_where_clause
    );

    if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      Get_Put_Messages (
        p_msg_count => l_msg_count
        ,p_msg_data => l_msg_data
      );
      raise l_request_prep_error;
    end if;

    if (x_input_ds_q_where_clause is null) then
      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_ENG_BAD_DS_WCLAUSE_ERR
        ,p_token1   => 'DATASET_GRP_OBJ_DEF_ID'
        ,p_value1   => x_request_rec.dataset_grp_obj_def_id
        ,p_token2   => 'OUTPUT_CAL_PERIOD_ID'
        ,p_value2   => x_request_rec.output_cal_period_id
        ,p_token3   => 'TABLE_NAME'
        ,p_value3   => 'FEM_COST_OBJECT_HIER_QTY'
        ,p_token4   => 'LEDGER_ID'
        ,p_value4   => x_request_rec.ledger_id
      );
      raise l_request_prep_error;
    end if;

  end if;

  ------------------------------------------------------------------------------
  -- Get Ledger information for Cost and Statistic Rollups
  ------------------------------------------------------------------------------
  Get_Dim_Attribute_Value (
    p_dimension_varchar_label       => 'LEDGER'
    ,p_attribute_varchar_label      => 'ENTERED_CRNCY_ENABLE_FLAG'
    ,p_member_id                    => x_request_rec.ledger_id
    ,x_dim_attribute_varchar_member => x_request_rec.entered_currency_flag
    ,x_date_assign_value            => l_dummy_date
  );

  if (x_request_rec.rollup_type_code = 'COST') then

    Get_Ledger_Currency_Code (
      p_ledger_id      => x_request_rec.ledger_id
      ,x_currency_code => x_request_rec.functional_currency_code
    );

  elsif (x_request_rec.rollup_type_code = 'STAT') then

    x_request_rec.functional_currency_code := 'STAT';

  end if;

  ------------------------------------------------------------------------------
  -- Set the exchange rate date
  ------------------------------------------------------------------------------
  if (x_request_rec.entered_currency_flag = 'Y') then

    Get_Dim_Attribute_Value (
      p_dimension_varchar_label       => 'CAL_PERIOD'
      ,p_attribute_varchar_label      => 'CAL_PERIOD_END_DATE'
      ,p_member_id                    => x_request_rec.output_cal_period_id
      ,x_dim_attribute_varchar_member => l_dummy_varchar
      ,x_date_assign_value            => x_request_rec.exch_rate_date
    );

  else

    x_request_rec.exch_rate_date := null;

  end if;

  -- Log all Request Record Parameters if we have low level debugging
  if ( FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) ) then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||l_api_name||'.x_request_rec'
      ,p_msg_text =>
      ' dataset_grp_obj_def_id='||x_request_rec.dataset_grp_obj_def_id||
      ' dataset_grp_obj_id='||x_request_rec.dataset_grp_obj_id||
      ' dimension_varchar_label='||x_request_rec.dimension_rec.dimension_varchar_label||
      ' effective_date='||FND_DATE.date_to_chardate(x_request_rec.effective_date)||
      ' entered_currency_flag='||x_request_rec.entered_currency_flag||
      ' exch_rate_date='||FND_DATE.date_to_chardate(x_request_rec.exch_rate_date)||
      ' functional_currency_code='||x_request_rec.functional_currency_code||
      ' ledger_id='||x_request_rec.ledger_id||
      ' local_vs_combo_id='||x_request_rec.local_vs_combo_id||
      ' login_id='||x_request_rec.login_id||
      ' output_cal_period_id='||x_request_rec.output_cal_period_id||
      ' output_dataset_code='||x_request_rec.output_dataset_code||
      ' pgm_app_id='||x_request_rec.pgm_app_id||
      ' pgm_id='||x_request_rec.pgm_id||
      ' resp_id='||x_request_rec.resp_id||
      ' request_id='||x_request_rec.request_id||
      ' rollup_obj_type_code='||x_request_rec.rollup_obj_type_code||
      ' rollup_type_code='||x_request_rec.rollup_type_code||
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
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_request_prep_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Request Preperation Exception'
    );

    raise g_rollup_request_error;

END Request_Prep;



/*============================================================================+
 | PROCEDURE
 |   Get_Object_Definition
 |
 | DESCRIPTION
 |   Get the object definition id for the specified object type code, object id
 |   and effective date.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

PROCEDURE Get_Object_Definition (
  p_object_type_code              in varchar2
  ,p_object_id                    in number
  ,p_effective_date               in date
  ,x_obj_def_id                   out nocopy number
)
IS

  l_api_name             constant varchar2(30) := 'Get_Object_Definition';

  l_object_name                   varchar2(150);
  l_object_type_code              varchar2(30);

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
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
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when no_data_found then

    select object_name
    ,object_type_code
    into l_object_name
    ,l_object_type_code
    from fem_object_catalog_vl
    where object_id = p_object_id;

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_ENG_NO_OBJ_DEF_ERR
      ,p_token1   => 'OBJECT_TYPE_MEANING'
      ,p_value1   => Get_Object_Type_Name(l_object_type_code)
      ,p_token2   => 'OBJECT_NAME'
      ,p_value2   => l_object_name
      ,p_token3   => 'EFFECTIVE_DATE'
      ,p_value3   => FND_DATE.date_to_chardate(p_effective_date)
    );

    raise g_rollup_request_error;

END Get_Object_Definition;



/*============================================================================+
 | PROCEDURE
 |   Get_Dimension_Record
 |
 | DESCRIPTION
 |   Validates the input dimension and returns a dimension record containing
 |   dimension metadata
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

PROCEDURE Get_Dimension_Record (
  p_dimension_varchar_label       in varchar2
  ,x_dimension_rec                out nocopy dimension_record
)
IS

  l_api_name             constant varchar2(30) := 'Get_Dimension_Record';

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  select dimension_id
  ,dimension_varchar_label
  ,composite_dimension_flag
  ,member_col
  ,member_b_table_name
  ,attribute_table_name as attr_table
  ,hierarchy_table_name as hier_table
  ,null as hier_rollup_table
  ,hier_versioning_type_code
  into x_dimension_rec
  from fem_xdim_dimensions_vl
  where dimension_varchar_label = p_dimension_varchar_label;

  -- Manually set the hierarchy rollup tables
  if (x_dimension_rec.dimension_varchar_label = 'COST_OBJECT') then

    -- Used for all COUC Rollups
    x_dimension_rec.hier_rollup_table := 'FEM_RU_COST_OBJ_HIER_T';

  elsif (x_dimension_rec.dimension_varchar_label = 'ACTIVITY') then

    -- Used for Activity Cost/Statistic Rollups that have a Condition
    x_dimension_rec.hier_rollup_table := 'FEM_RU_ACTIVITIES_HIER_T';

  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
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

    raise g_rollup_request_error;

END Get_Dimension_Record;



/*============================================================================+
 | PROCEDURE
 |   Get_Dim_Attribute_Value
 |
 | DESCRIPTION
 |   Get Dimension Attribute Value for the specified dimension label, attribute
 |   label and member id.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

PROCEDURE Get_Dim_Attribute_Value (
  p_dimension_varchar_label       in varchar2
  ,p_attribute_varchar_label      in varchar2
  ,p_member_id                    in number
  ,x_dim_attribute_varchar_member out nocopy varchar2
  ,x_date_assign_value            out nocopy date
)
IS

  l_api_name             constant varchar2(30) := 'Get_Dim_Attribute_Value';

  l_dimension_rec                 dimension_record;

  l_dimension_id                  number;
  l_attribute_id                  number;
  l_attr_version_id               number;

  l_get_dim_attr_val_error        exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  Get_Dim_Attribute (
    p_dimension_varchar_label  => p_dimension_varchar_label
    ,p_attribute_varchar_label => p_attribute_varchar_label
    ,x_dimension_rec           => l_dimension_rec
    ,x_attribute_id            => l_attribute_id
    ,x_attr_version_id         => l_attr_version_id
  );

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
        ,p_token1   => 'DIMENSION_VARCHAR_LABEL'
        ,p_value1   => p_dimension_varchar_label
        ,p_token2   => 'ATTRIBUTE_VARCHAR_LABEL'
        ,p_value2   => p_attribute_varchar_label
      );
      raise l_get_dim_attr_val_error;
  end;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_get_dim_attr_val_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Get Dimension Attribute Value Exception'
    );

    raise g_rollup_request_error;

END Get_Dim_Attribute_Value;



/*============================================================================+
 | PROCEDURE
 |   Get_Ledger_Currency_Code
 |
 | DESCRIPTION
 |   Get the currency code for the specified ledger id.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

PROCEDURE Get_Ledger_Currency_Code (
  p_ledger_id                     in varchar2
  ,x_currency_code                out nocopy varchar2
)
IS

  l_api_name             constant varchar2(30) := 'Get_Ledger_Currency_Code';

  l_dimension_rec                 dimension_record;

  l_dimension_id                  number;
  l_attribute_id                  number;
  l_attr_version_id               number;

  l_get_ledger_curr_code_error    exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (g_ledger_dimension_id is null) then

    Get_Dim_Attribute (
      p_dimension_varchar_label  => 'LEDGER'
      ,p_attribute_varchar_label => 'LEDGER_FUNCTIONAL_CRNCY_CODE'
      ,x_dimension_rec           => l_dimension_rec
      ,x_attribute_id            => g_ledger_curr_attr_id
      ,x_attr_version_id         => g_ledger_curr_attr_version_id
    );

    g_ledger_dimension_id := l_dimension_rec.dimension_id;

  end if;

  begin
    select dim_attribute_varchar_member
    into x_currency_code
    from fem_ledgers_attr
    where attribute_id = g_ledger_curr_attr_id
    and version_id = g_ledger_curr_attr_version_id
    and ledger_id = p_ledger_id;
  exception
    when others then
      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_ENG_NO_DIM_ATTR_VAL_ERR
        ,p_token1   => 'DIMENSION_VARCHAR_LABEL'
        ,p_value1   => 'LEDGER'
        ,p_token2   => 'ATTRIBUTE_VARCHAR_LABEL'
        ,p_value2   => 'LEDGER_FUNCTIONAL_CRNCY_CODE'
      );
      raise l_get_ledger_curr_code_error;
  end;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_get_ledger_curr_code_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Get Ledger Currency Code Exception'
    );

    raise g_rollup_request_error;

END Get_Ledger_Currency_Code;



/*============================================================================+
 | PROCEDURE
 |   Get_Dim_Attribute
 |
 | DESCRIPTION
 |   Get the dimension and attribute information for the specified dimension
 |   label and attribute label.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

PROCEDURE Get_Dim_Attribute (
  p_dimension_varchar_label       in varchar2
  ,p_attribute_varchar_label      in varchar2
  ,x_dimension_rec                out nocopy dimension_record
  ,x_attribute_id                 out nocopy number
  ,x_attr_version_id              out nocopy number
)
IS

  l_api_name             constant varchar2(30) := 'Get_Dim_Attribute';

  l_get_dim_attr_error            exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  Get_Dimension_Record (
    p_dimension_varchar_label => p_dimension_varchar_label
    ,x_dimension_rec          => x_dimension_rec
  );

  begin
    select att.attribute_id
    ,ver.version_id
    into x_attribute_id
    ,x_attr_version_id
    from fem_dim_attributes_b att
    ,fem_dim_attr_versions_b ver
    where att.dimension_id = x_dimension_rec.dimension_id
    and att.attribute_varchar_label = p_attribute_varchar_label
    and ver.attribute_id = att.attribute_id
    and ver.default_version_flag = 'Y';
  exception
    when others then
      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_ENG_NO_DIM_ATTR_VER_ERR
        ,p_token1   => 'DIMENSION_VARCHAR_LABEL'
        ,p_value1   => p_dimension_varchar_label
        ,p_token2   => 'ATTRIBUTE_VARCHAR_LABEL'
        ,p_value2   => p_attribute_varchar_label
      );
      raise l_get_dim_attr_error;
  end;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_get_dim_attr_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Get Dimension Attribute Value Exception'
    );

    raise g_rollup_request_error;

END Get_Dim_Attribute;



/*============================================================================+
 | PROCEDURE
 |   Sql_Stmts_Prep
 |
 | DESCRIPTION
 |   Dynamic SQL statement preparation.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

PROCEDURE Sql_Stmts_Prep (
  p_request_rec                   in request_record
  ,x_sql_rec                      out nocopy sql_record
)
IS

  l_api_name             constant varchar2(30) := 'Sql_Stmts_Prep';

  l_comp_dim_req_col              varchar2(30);
  l_column_name                   varchar2(30);
  l_proc_key_flag                 varchar2(1);

  l_comp_dim_comp_cols_using      long;
  l_comp_dim_data_cols_using      long;
  l_comp_dim_data_cols_on         long;
  l_comp_dim_comp_cols_insert     long;
  l_comp_dim_data_cols_insert     long;
  l_comp_dim_comp_cols_values     long;
  l_comp_dim_data_cols_values     long;

  l_comp_dim_cols_csr             dynamic_cursor;
  l_comp_dim_cols_stmt            long;

  l_sql_stmts_prep_error          exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (p_request_rec.dimension_rec.dimension_varchar_label = 'COST_OBJECT') then

    l_comp_dim_req_col := 'cost_obj';

  elsif (p_request_rec.dimension_rec.dimension_varchar_label = 'ACTIVITY') then

    l_comp_dim_req_col := 'activity';

  else

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_RU_NO_ROLLUP_DIM_ERR
      ,p_token1   => 'DIMENSION_VARCHAR_LABEL'
      ,p_value1   => p_request_rec.dimension_rec.dimension_varchar_label
    );
    raise l_sql_stmts_prep_error;

  end if;

  --todo: check if any user dims have been reassigned in FEM_BALANCES and that
  --are also a component dimension.

  -- First find all the component dimension columns
  l_comp_dim_cols_stmt :=
  ' select reqs.column_name'||
  ' from fem_column_requiremnt_b reqs'||
  ' ,fem_tab_columns_v cols'||
  ' where reqs.'||l_comp_dim_req_col||'_dim_requirement_code is not null'||
  ' and reqs.'||l_comp_dim_req_col||'_dim_component_flag = ''Y'''||
  ' and reqs.dimension_id is not null'||
  ' and cols.table_name = ''FEM_BALANCES'''||
  ' and cols.column_name = reqs.column_name'||
  ' and cols.dimension_id = reqs.dimension_id';

  open l_comp_dim_cols_csr
  for l_comp_dim_cols_stmt;

  loop

    fetch l_comp_dim_cols_csr into
    l_column_name;

    exit when l_comp_dim_cols_csr%NOTFOUND;

    -- build the Component cimension column string used in the Using clause
    l_comp_dim_comp_cols_using := l_comp_dim_comp_cols_using ||
    ' ,parent.'||l_column_name;

    -- build the Component dimension column string used in the Insert clause
    l_comp_dim_comp_cols_insert := l_comp_dim_comp_cols_insert ||
    ' ,bp.'||l_column_name;

    -- build the Component dimension column string used in the Values clause
    l_comp_dim_comp_cols_values := l_comp_dim_comp_cols_values ||
    ' ,bc.'||l_column_name;

  end loop;

  close l_comp_dim_cols_csr;

  -- Then find all the dimension columns that are not part of the composite
  -- dimension definition, thus making them data dimension columns in
  -- FEM_BALANCES
  l_comp_dim_cols_stmt :=
  ' select reqs.column_name'||
  ' ,decode(cols.column_name,props.column_name,''Y'',''N'') as proc_key_flag'||
  ' from fem_column_requiremnt_b reqs'||
  ' ,fem_tab_columns_v cols'||
  ' ,fem_tab_column_prop props'||
  ' where reqs.'||l_comp_dim_req_col||'_dim_component_flag = ''N'''||
  ' and reqs.dimension_id is not null'||
  ' and cols.table_name = ''FEM_BALANCES'''||
  ' and cols.column_name = reqs.column_name'||
  ' and cols.dimension_id is not null'||
  ' and cols.fem_data_type_code = ''DIMENSION'''||
  ' and props.table_name (+) = cols.table_name'||
  ' and props.column_name (+) = cols.column_name'||
  ' and props.column_property_code (+) = ''PROCESSING_KEY'''||
  ' and ('||
  '   reqs.'||l_comp_dim_req_col||'_dim_requirement_code is not null'||
  '   or ('||
  '     reqs.'||l_comp_dim_req_col||'_dim_requirement_code is null'||
  '     and cols.column_name not in ('||
  '       ''ACTIVITY_ID'''||
  '       ,''COST_OBJECT_ID'''||
  '       ,''CREATED_BY_OBJECT_ID'''||
  '       ,''LAST_UPDATED_BY_OBJECT_ID'''||
  '       ,''CURRENCY_TYPE_CODE'''||
  '       ,''CURRENCY_CODE'''||
  '       ,''DATASET_CODE'''||
  '       ,''CAL_PERIOD_ID'''||
  '       ,''LEDGER_ID'''||
  '       ,''SOURCE_SYSTEM_CODE'''||
  '     )'||
  '   )'||
  ' )';

  open l_comp_dim_cols_csr
  for l_comp_dim_cols_stmt;

  loop

    fetch l_comp_dim_cols_csr into
    l_column_name
    ,l_proc_key_flag;

    exit when l_comp_dim_cols_csr%NOTFOUND;

    -- build the Data dimension column string used in the Using clause
    l_comp_dim_data_cols_using := l_comp_dim_data_cols_using ||
    ' ,b.'||l_column_name;

    -- build the Data dimension column string used in the On clause
    if (l_proc_key_flag = 'Y') then
      -- If column is part of processing key, then column values cannot be null.
      -- Cannot use nvl() function as it will affect performance as the column
      -- will be part of the table's processing key unique index.
      l_comp_dim_data_cols_on := l_comp_dim_data_cols_on ||
      ' and bp.'||l_column_name||' = bc.'||l_column_name;
    else
      -- If column is not part of processing key, then column values can be
      -- null.  Must use nvl() function to handle these null values.  It will
      -- not greatly affect performance as the column is not be part of the
      -- table's processing key unique index.
      l_comp_dim_data_cols_on := l_comp_dim_data_cols_on ||
      ' and nvl(bp.'||l_column_name||',-1) = nvl(bc.'||l_column_name||',-1)';
    end if;

    -- build the Data dimension column string used in the Insert clause
    l_comp_dim_data_cols_insert := l_comp_dim_data_cols_insert ||
    ' ,bp.'||l_column_name;

    -- build the Data dimension column string used in the Values clause
    l_comp_dim_data_cols_values := l_comp_dim_data_cols_values ||
    ' ,bc.'||l_column_name;

  end loop;

  close l_comp_dim_cols_csr;

  -- Populate SQL record
  x_sql_rec.comp_dim_comp_cols_using := l_comp_dim_comp_cols_using;
  x_sql_rec.comp_dim_data_cols_using := l_comp_dim_data_cols_using;
  x_sql_rec.comp_dim_data_cols_on := l_comp_dim_data_cols_on;
  x_sql_rec.comp_dim_comp_cols_insert := l_comp_dim_comp_cols_insert;
  x_sql_rec.comp_dim_data_cols_insert := l_comp_dim_data_cols_insert;
  x_sql_rec.comp_dim_comp_cols_values := l_comp_dim_comp_cols_values;
  x_sql_rec.comp_dim_data_cols_values := l_comp_dim_data_cols_values;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_sql_stmts_prep_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'SQL Statements Preparation Exception'
    );

    raise g_rollup_request_error;

END Sql_Stmts_Prep;



/*============================================================================+
 | PROCEDURE
 |   Register_Request
 |
 | DESCRIPTION
 |   Registers the request in the processing locks tables.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

PROCEDURE Register_Request (
  p_request_rec                   in request_record
)
IS

  l_api_name             constant varchar2(30) := 'Register_Request';

  l_return_status                 t_return_status%TYPE;
  l_msg_count                     t_msg_count%TYPE;
  l_msg_data                      t_msg_data%TYPE;

  l_register_request_error        exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
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
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_register_request_error then

    rollback to register_request_pub;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Register Request Exception'
    );

    raise g_rollup_request_error;

  when g_rollup_request_error then

    rollback to register_request_pub;
    raise g_rollup_request_error;

  when others then

    rollback to register_request_pub;
    raise;

END Register_Request;



/*============================================================================+
 | PROCEDURE
 |   Rollup_Rule
 |
 | DESCRIPTION
 |   Main procedure for rollup processing on a rule.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

PROCEDURE Rollup_Rule (
  p_request_rec                   in request_record
  ,p_sql_rec                      in sql_record
  ,p_rollup_obj_id                in number
  ,p_rollup_obj_def_id            in number
  ,p_rollup_sequence              in number
  ,p_rollup_rule_def_stmt         in long
  ,p_input_ds_b_where_clause      in long
  ,p_input_ds_q_where_clause      in long
  ,x_return_status                out nocopy varchar2
)
IS

  l_api_name             constant varchar2(30) := 'Rollup_Rule';

  l_rule_rec                      rule_record;

  l_completion_status             boolean;
  l_uncosted_node_count           number;

  l_find_children_stmt            long;
  l_rollup_parent_stmt            long;
  l_find_child_chains_stmt        long;
  l_num_of_input_rows_stmt        long;

  -------------------------------------
  -- Declare bulk collection columns --
  -------------------------------------
  l_top_node_id_tbl               number_table;

  ----------------------------
  -- Declare static cursors --
  ----------------------------
  cursor l_get_root_nodes_csr (
    p_request_id in number
    ,p_object_id in number
  ) is
  select node_id
  from fem_ru_nodes_t
  where created_by_request_id = p_request_id
  and created_by_object_id = p_object_id
  and root_flag = 'Y'
  and costed_flag = 'N';

  cursor l_get_cond_nodes_csr (
    p_request_id in number
    ,p_object_id in number
  ) is
  select node_id
  from fem_ru_nodes_t
  where created_by_request_id = p_request_id
  and created_by_object_id = p_object_id
  and condition_flag = 'Y'
  and costed_flag = 'N';

  -----------------------------------------------------------
  -- Index indicating last row number for a cursor.
  -----------------------------------------------------------
  l_get_root_nodes_last_row       number;
  l_get_cond_nodes_last_row       number;

  l_rollup_rule_error             exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  -- Initialize the return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  ------------------------------------------------------------------------------
  -- STEP 1: Rule Pre Processing
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.tech_message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 1: Rule Pre Processing'
  );

  Rule_Prep (
    p_request_rec           => p_request_rec
    ,p_rollup_obj_id        => p_rollup_obj_id
    ,p_rollup_obj_def_id    => p_rollup_obj_def_id
    ,p_rollup_sequence      => p_rollup_sequence
    ,p_rollup_rule_def_stmt => p_rollup_rule_def_stmt
    ,x_rule_rec             => l_rule_rec
  );

  ------------------------------------------------------------------------------
  -- STEP 2: Build Dynamic SQL
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.tech_message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 2: Build Dynamic SQL'
  );

  Sql_Stmts_Build (
    p_request_rec              => p_request_rec
    ,p_rule_rec                => l_rule_rec
    ,p_sql_rec                 => p_sql_rec
    ,p_input_ds_b_where_clause => p_input_ds_b_where_clause
    ,p_input_ds_q_where_clause => p_input_ds_q_where_clause
    ,x_find_children_stmt      => l_find_children_stmt
    ,x_rollup_parent_stmt      => l_rollup_parent_stmt
    ,x_find_child_chains_stmt  => l_find_child_chains_stmt
    ,x_num_of_input_rows_stmt  => l_num_of_input_rows_stmt
  );

  ------------------------------------------------------------------------------
  -- STEP 3: Register Rule under the same parent request
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.tech_message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 3: Register Rule'
  );

  Register_Rule (
    p_request_rec => p_request_rec
    ,p_rule_rec   => l_rule_rec
  );

  ------------------------------------------------------------------------------
  -- STEP 4: Create Temporary Objects
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.tech_message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 4: Create Temporary Objects'
  );

  Create_Temp_Objects (
    p_request_rec => p_request_rec
    ,p_rule_rec   => l_rule_rec
  );

  if (l_rule_rec.cond_exists) then

    ----------------------------------------------------------------------------
    -- STEP 5.1: Find Condition Nodes
    ----------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Step 5.1: Find Condition Nodes'
    );

    Find_Condition_Nodes (
      p_request_rec => p_request_rec
      ,p_rule_rec   => l_rule_rec
    );

  else

    ----------------------------------------------------------------------------
    -- STEP 5.2: Find Root Nodes
    ----------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Step 5.2: Find Root Nodes'
    );

    Find_Root_Nodes (
      p_request_rec => p_request_rec
      ,p_rule_rec   => l_rule_rec
    );

  end if;

  ------------------------------------------------------------------------------
  -- STEP 6: Rollup Root Nodes
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 6: Rollup Root Nodes'
  );

  -- Cursor query to get all root nodes
  open l_get_root_nodes_csr (
    p_request_id => p_request_rec.request_id
    ,p_object_id => l_rule_rec.rollup_obj_id
  );

  loop

    fetch l_get_root_nodes_csr
    bulk collect into
    l_top_node_id_tbl
    limit g_fetch_limit;

    l_get_root_nodes_last_row := l_top_node_id_tbl.LAST;
    if (l_get_root_nodes_last_row is null) then
      exit;
    end if;

    -- Perform rollup on all root nodes
    for i in 1..l_get_root_nodes_last_row loop

      Rollup_Top_Node (
        p_request_rec              => p_request_rec
        ,p_rule_rec                => l_rule_rec
        ,p_find_children_stmt      => l_find_children_stmt
        ,p_rollup_parent_stmt      => l_rollup_parent_stmt
        ,p_find_child_chains_stmt  => l_find_child_chains_stmt
        ,p_input_ds_b_where_clause => p_input_ds_b_where_clause
        ,p_top_node_id             => l_top_node_id_tbl(i)
      );

    end loop;

    l_top_node_id_tbl.DELETE;

  end loop;

  close l_get_root_nodes_csr;

  ------------------------------------------------------------------------------
  -- STEP 7: Rollup Condition Nodes
  ------------------------------------------------------------------------------
  if (l_rule_rec.cond_exists) then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Step 7: Rollup Condition Nodes'
    );

    -- Cursor query to get all condition nodes
    open l_get_cond_nodes_csr (
      p_request_id => p_request_rec.request_id
      ,p_object_id => l_rule_rec.rollup_obj_id
    );

    loop

      fetch l_get_cond_nodes_csr
      bulk collect into
      l_top_node_id_tbl
      limit g_fetch_limit;

      l_get_cond_nodes_last_row := l_top_node_id_tbl.LAST;
      if (l_get_cond_nodes_last_row is null) then
        exit;
      end if;

      -- Perform rollup on all root nodes
      for i in 1..l_get_cond_nodes_last_row loop

        Rollup_Top_Node (
          p_request_rec              => p_request_rec
          ,p_rule_rec                => l_rule_rec
          ,p_find_children_stmt      => l_find_children_stmt
          ,p_rollup_parent_stmt      => l_rollup_parent_stmt
          ,p_find_child_chains_stmt  => l_find_child_chains_stmt
          ,p_input_ds_b_where_clause => p_input_ds_b_where_clause
          ,p_top_node_id             => l_top_node_id_tbl(i)
        );

      end loop;

      l_top_node_id_tbl.DELETE;

    end loop;

    close l_get_cond_nodes_csr;

  end if;

  ------------------------------------------------------------------------------
  -- STEP 8: Check for Uncosted Nodes
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 8: Check for Uncosted Nodes'
  );

  -- query to count number of uncosted nodes
  select count(*)
  into l_uncosted_node_count
  from fem_ru_nodes_t
  where created_by_request_id = p_request_rec.request_id
  and created_by_object_id = l_rule_rec.rollup_obj_id
  and costed_flag = 'N';

  if (l_uncosted_node_count > 0) then

    FEM_ENGINES_PKG.User_Message(
      p_app_name  => G_FEM
      ,p_msg_name => G_RU_UNCOSTED_NODES_ERR
    );
    raise l_rollup_rule_error;

  end if;

  ------------------------------------------------------------------------------
  -- STEP 9: Rule Post Processing
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 9: Rule Post Processing'
  );

  Rule_Post_Proc (
    p_request_rec             => p_request_rec
    ,p_rule_rec               => l_rule_rec
    ,p_num_of_input_rows_stmt => l_num_of_input_rows_stmt
    ,p_exec_status_code       => G_EXEC_STATUS_SUCCESS
  );

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_rollup_rule_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Rollup Rule Exception'
    );

    if (l_get_root_nodes_csr%ISOPEN) then
     close l_get_root_nodes_csr;
    end if;

    if (l_get_cond_nodes_csr%ISOPEN) then
     close l_get_cond_nodes_csr;
    end if;

    -- Rule Post Processing
    Rule_Post_Proc (
      p_request_rec             => p_request_rec
      ,p_rule_rec               => l_rule_rec
      ,p_num_of_input_rows_stmt => l_num_of_input_rows_stmt
      ,p_exec_status_code       => G_EXEC_STATUS_ERROR_UNDO
    );

    -- Commented out properly handle continue_process_on_err_flg
    --raise g_rollup_request_error;

    -- Set the return status to ERROR
    x_return_status := FND_API.G_RET_STS_ERROR;

  when g_rollup_request_error then

    if (l_get_root_nodes_csr%ISOPEN) then
     close l_get_root_nodes_csr;
    end if;

    if (l_get_cond_nodes_csr%ISOPEN) then
     close l_get_cond_nodes_csr;
    end if;

    -- Rule Post Processing
    Rule_Post_Proc (
      p_request_rec             => p_request_rec
      ,p_rule_rec               => l_rule_rec
      ,p_num_of_input_rows_stmt => l_num_of_input_rows_stmt
      ,p_exec_status_code       => G_EXEC_STATUS_ERROR_UNDO
    );

    -- Commented out properly handle continue_process_on_err_flg
    --raise g_rollup_request_error;

    -- Set the return status to ERROR
    x_return_status := FND_API.G_RET_STS_ERROR;

  when others then

    g_prg_msg := SQLERRM;
    g_callstack := DBMS_UTILITY.Format_Call_Stack;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name||'.Unexpected_Exception'
      ,p_msg_text => g_prg_msg
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_UNEXPECTED_ERROR
      ,p_token1   => 'ERR_MSG'
      ,p_value1   => g_prg_msg
    );

    if (l_get_root_nodes_csr%ISOPEN) then
     close l_get_root_nodes_csr;
    end if;

    if (l_get_cond_nodes_csr%ISOPEN) then
     close l_get_cond_nodes_csr;
    end if;

    -- Rule Post Processing
    Rule_Post_Proc (
      p_request_rec             => p_request_rec
      ,p_rule_rec               => l_rule_rec
      ,p_num_of_input_rows_stmt => l_num_of_input_rows_stmt
      ,p_exec_status_code       => G_EXEC_STATUS_ERROR_UNDO
    );

    -- Commented out properly handle continue_process_on_err_flg
    --raise g_rollup_request_error;

    -- Set the return status to UNEXP_ERROR
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Rollup_Rule;



/*============================================================================+
 | PROCEDURE
 |   Rule_Prep
 |
 | DESCRIPTION
 |   Rollup Rule Preparation.  Populates the rule record that will be processed.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

PROCEDURE Rule_Prep (
  p_request_rec                   in request_record
  ,p_rollup_obj_id                in number
  ,p_rollup_obj_def_id            in number
  ,p_rollup_sequence              in number
  ,p_rollup_rule_def_stmt         in long
  ,x_rule_rec                     out nocopy rule_record
)
IS

  l_api_name             constant varchar2(30) := 'Rule_Prep';

  l_dimension_id                  number;

  l_rule_prep_error               exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  x_rule_rec.rollup_obj_id := p_rollup_obj_id;
  x_rule_rec.rollup_obj_def_id := p_rollup_obj_def_id;
  x_rule_rec.rollup_sequence := p_rollup_sequence;

  ------------------------------------------------------------------------------
  -- Get the object info from FEM_OBJECT_CATALOG_B for the Rollup Object ID.
  ------------------------------------------------------------------------------
  begin
    select object_type_code
    ,object_name
    ,local_vs_combo_id
    into x_rule_rec.rollup_obj_type_code
    ,x_rule_rec.rollup_obj_name
    ,x_rule_rec.local_vs_combo_id
    from fem_object_catalog_vl
    where object_id = x_rule_rec.rollup_obj_id;
  exception
    when others then
      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_ENG_NO_OBJ_ERR
        ,p_token1   => 'OBJECT_TYPE_MEANING'
        ,p_value1   => Get_Object_Type_Name(p_request_rec.rollup_obj_type_code)
        ,p_token2   => 'OBJECT_ID'
        ,p_value2   => x_rule_rec.rollup_obj_id
      );
      raise l_rule_prep_error;
  end;

  ------------------------------------------------------------------------------
  -- If this is a Rule Set Submission, check that the object_type_code and
  -- local_vs_combo_id of the rollup rule matches the Rule Set's.
  ------------------------------------------------------------------------------
  if (p_request_rec.submit_obj_type_code = 'RULE_SET') then

    -- For rule sets processing, post to log file when starting to process a
    -- rule set rule.
    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_ENG_RS_RULE_PROCESSING_TXT
      ,p_token1   => 'RULE_NAME'
      ,p_value1   => x_rule_rec.rollup_obj_name
    );

    if (p_request_rec.rollup_obj_type_code <> x_rule_rec.rollup_obj_type_code) then

      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_ENG_BAD_RS_OBJ_TYPE_ERR
        ,p_token1   => 'RS_OBJECT_TYPE_CODE'
        ,p_value1   => p_request_rec.rollup_obj_type_code
        ,p_token2   => 'OBJECT_TYPE_CODE'
        ,p_value2   => x_rule_rec.rollup_obj_type_code
        ,p_token3   => 'OBJECT_ID'
        ,p_value3   => x_rule_rec.rollup_obj_id
      );
      raise l_rule_prep_error;

    end if;

    if (p_request_rec.local_vs_combo_id <> x_rule_rec.local_vs_combo_id) then

      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_ENG_BAD_LCL_VS_COMBO_ERR
        ,p_token1   => 'OBJECT_TYPE_MEANING'
        ,p_value1   => Get_Object_Type_Name(x_rule_rec.rollup_obj_type_code)
        ,p_token2   => 'OBJECT_ID'
        ,p_value2   => x_rule_rec.rollup_obj_id
      );
      raise l_rule_prep_error;

    end if;

  end if;

  ------------------------------------------------------------------------------
  -- Get the Rollup Object Definition ID
  ------------------------------------------------------------------------------
  if (x_rule_rec.rollup_obj_def_id is null) then

    Get_Object_Definition (
      p_object_type_code => x_rule_rec.rollup_obj_type_code
      ,p_object_id       => x_rule_rec.rollup_obj_id
      ,p_effective_date  => p_request_rec.effective_date
      ,x_obj_def_id      => x_rule_rec.rollup_obj_def_id
    );

  end if;

  ------------------------------------------------------------------------------
  -- Get Rollup Rule Definition Info
  ------------------------------------------------------------------------------
  begin
    execute immediate p_rollup_rule_def_stmt
    into x_rule_rec.hier_obj_id
    ,x_rule_rec.cond_obj_id
    ,x_rule_rec.entered_currency_code
    ,x_rule_rec.statistic_basis_id
    using x_rule_rec.rollup_obj_def_id;
  exception
    when others then
      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_ENG_NO_OBJ_DEF_DTL_ERR
        ,p_token1   => 'TABLE_NAME'
        ,p_value1   => p_request_rec.rollup_rule_def_table
        ,p_token2   => 'OBJECT_TYPE_MEANING'
        ,p_value2   => Get_Object_Type_Name(x_rule_rec.rollup_obj_type_code)
        ,p_token3   => 'OBJECT_ID'
        ,p_value3   => x_rule_rec.rollup_obj_id
        ,p_token4   => 'OBJECT_DEF_ID'
        ,p_value4   => x_rule_rec.rollup_obj_def_id
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
        ,p_value2   => Get_Object_Type_Name(x_rule_rec.rollup_obj_type_code)
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
        ,p_value1   => Get_Object_Type_Name(x_rule_rec.rollup_obj_type_code)
        ,p_token2   => 'OBJECT_ID'
        ,p_value2   => x_rule_rec.rollup_obj_id
        ,p_token3   => 'OBJECT_DEF_ID'
        ,p_value3   => x_rule_rec.rollup_obj_def_id
      );
      raise l_rule_prep_error;

  end if;

  if (p_request_rec.dimension_rec.dimension_varchar_label = 'COST_OBJECT') then

    -- Use the hierarchy rollup table for the Cost Object Dimension.  This
    -- is necessary as the Cost Object hierarchy is a DAG and needs a temporary
    -- table for flattening.
    x_rule_rec.hier_rollup_table := p_request_rec.dimension_rec.hier_rollup_table;

  elsif (p_request_rec.dimension_rec.dimension_varchar_label = 'ACTIVITY') then

    if (x_rule_rec.cond_exists) then

      -- Use the hierarchy rollup table for the Activity Dimension if a
      -- Condition is specified.  This is necessary as the Condition would
      -- restrict rollup processing to smaller subset of the entire Activity
      -- hierarchy.
      x_rule_rec.hier_rollup_table := p_request_rec.dimension_rec.hier_rollup_table;

    else

      -- Use the hierarchy table for the Activity Dimension if no Condition
      -- is specified.  With no condition, the rollup processes the entire
      -- Activity hierarchy.
      x_rule_rec.hier_rollup_table := p_request_rec.dimension_rec.hier_table;

    end if;

  end if;

  ------------------------------------------------------------------------------
  -- Set the Temporary Sequence Name for performing Rollup Processing in the
  -- FEM_BALANCES table.
  ------------------------------------------------------------------------------
  x_rule_rec.sequence_name :=
    'fem_ru_'||
    to_char(p_request_rec.request_id)||
    '_'||
    to_char(x_rule_rec.rollup_sequence)||
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

    --todo: find what the "Functional" currency code string value will be.
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
            ,x_conversion_date => p_request_rec.exch_rate_date
            ,x_conversion_type => g_currency_conv_type
            ,x_numerator       => x_rule_rec.entered_exch_rate_num
            ,x_denominator     => x_rule_rec.entered_exch_rate_den
            ,x_rate            => x_rule_rec.entered_exch_rate
          );
        exception
          when GL_CURRENCY_API.NO_RATE then
            FEM_ENGINES_PKG.User_Message (
              p_app_name  => G_FEM
              ,p_msg_name => G_ENG_NO_EXCH_RATE_ERR
              ,p_token1   => 'FROM_CURRENCY_CODE'
              ,p_value1   => p_request_rec.functional_currency_code
              ,p_token2   => 'TO_CURRENCY_CODE'
              ,p_value2   => x_rule_rec.entered_currency_code
              ,p_token3   => 'CONVERSION_DATE'
              ,p_value3   => FND_DATE.date_to_chardate(p_request_rec.exch_rate_date)
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
              ,p_value3   => FND_DATE.date_to_chardate(p_request_rec.exch_rate_date)
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
      ,p_module   => G_BLOCK||'.'||l_api_name||'.x_rule_rec'
      ,p_msg_text =>
      ' cond_obj_def_id='||x_rule_rec.cond_obj_def_id||
      ' cond_obj_id='||x_rule_rec.cond_obj_id||
      ' entered_currency_code='||x_rule_rec.entered_currency_code||
      ' entered_exch_rate='||x_rule_rec.entered_exch_rate||
      ' entered_exch_rate_den='||x_rule_rec.entered_exch_rate_den||
      ' entered_exch_rate_num='||x_rule_rec.entered_exch_rate_num||
      ' hier_obj_def_id='||x_rule_rec.hier_obj_def_id||
      ' hier_obj_id='||x_rule_rec.hier_obj_id||
      ' hier_rollup_table='||x_rule_rec.hier_rollup_table||
      ' local_vs_combo_id='||x_rule_rec.local_vs_combo_id||
      ' rollup_obj_def_id='||x_rule_rec.rollup_obj_def_id||
      ' rollup_obj_id='||x_rule_rec.rollup_obj_id||
      ' rollup_obj_type_code='||x_rule_rec.rollup_obj_type_code||
      ' rollup_sequence='||x_rule_rec.rollup_sequence||
      ' sequence_name='||x_rule_rec.sequence_name||
      ' statistic_basis_id='||x_rule_rec.statistic_basis_id
    );

  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_rule_prep_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Rule Preparation Exception'
    );

    raise g_rollup_request_error;

END Rule_Prep;



/*============================================================================+
 | PROCEDURE
 |   Sql_Stmts_Build
 |
 | DESCRIPTION
 |   Dynamic SQL statement building for use in a rollup rule.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

PROCEDURE Sql_Stmts_Build (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
  ,p_sql_rec                      in sql_record
  ,p_input_ds_b_where_clause      in long
  ,p_input_ds_q_where_clause      in long
  ,x_find_children_stmt           out nocopy long
  ,x_rollup_parent_stmt           out nocopy long
  ,x_find_child_chains_stmt        out nocopy long
  ,x_num_of_input_rows_stmt       out nocopy long
)
IS

  l_api_name             constant varchar2(30) := 'Sql_Stmts_Build';

  l_dimension_rec                 dimension_record;

  l_financial_elem_id_clause      varchar2(255);
  l_line_item_id_clause           varchar2(255);

  l_sql_stmts_build_error         exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  l_dimension_rec := p_request_rec.dimension_rec;

  if (l_dimension_rec.dimension_varchar_label = 'COST_OBJECT') then

    -- Build SQL statement for finding all Parent-Child Relationships
    x_find_children_stmt :=
    ' select h.child_id'||
    ' ,sum(nvl(q.child_qty/decode(q.parent_qty,0,null,q.parent_qty)/decode(q.yield_percentage,0,null,q.yield_percentage),0.00)) as weighting_pct'||
    ' ,h.child_ledger_id'||
    ' from '||p_rule_rec.hier_rollup_table||' h'||
    ' ,fem_cost_obj_hier_qty q'||
    ' where h.created_by_request_id = :b_request_id'||
    ' and h.created_by_object_id = :b_rollup_obj_id'||
    ' and h.parent_id = :b_parent_id'||
    ' and h.parent_depth_num = :b_parent_depth_num'||
    ' and q.relationship_id = h.relationship_id'||
    ' and '||p_input_ds_q_where_clause||
    ' group by h.child_ledger_id'||
    ' ,h.child_id';

    -- Build SQL statement for performing the rollup
    --todo: precision 38?
    x_rollup_parent_stmt :=
    ' merge into fem_balances bp'||
    ' using ('||
    '   select :b_source_system_code as source_system_code'||--new
    '   ,:b_currency_code as currency_code'||--new
    '   ,b.currency_type_code'||
    '   ,parent.cost_object_id'||
        p_sql_rec.comp_dim_comp_cols_using||
        p_sql_rec.comp_dim_data_cols_using||
    '   ,sum(b.xtd_balance_f) xtd_balance_f'||
    '   from fem_balances b'||
    '   ,fem_cost_objects parent'||
    '   where b.cost_object_id = :b_child_id'||
    '   and parent.cost_object_id = :b_parent_id'||
    '   and b.currency_type_code = ''ENTERED'''||
    '   and '||p_input_ds_b_where_clause||
    '   group by b.currency_type_code'||
    '   ,parent.cost_object_id'||
        p_sql_rec.comp_dim_comp_cols_using||
        p_sql_rec.comp_dim_data_cols_using||
    ' ) bc'||
    ' on ('||
    '   bp.source_system_code = bc.source_system_code'||
    '   and bp.currency_code = bc.currency_code'||
    '   and bp.currency_type_code = bc.currency_type_code'||
    '   and bp.cost_object_id = bc.cost_object_id'||
        p_sql_rec.comp_dim_data_cols_on||
    '   and bp.dataset_code = :b_output_dataset_code'||
    '   and bp.cal_period_id = :b_output_cal_period_id'||
    '   and bp.created_by_request_id = :b_request_id'||
    '   and bp.created_by_object_id = :b_rollup_obj_id'||
    ' )'||
    ' when matched then'||
    '   update set'||
    '     bp.xtd_balance_e = bp.xtd_balance_e + ( round((bc.xtd_balance_f * :b_weighting_pct),37) / :b_child_exch_rate_den * :b_child_exch_rate_num / :b_entered_exch_rate_den * :b_entered_exch_rate_num)'||
    '     ,bp.xtd_balance_f = bp.xtd_balance_f + ( round((bc.xtd_balance_f * :b_weighting_pct),37) / :b_child_exch_rate_den * :b_child_exch_rate_num )'||
    '     ,bp.last_updated_by_request_id = :b_request_id'||
    '     ,bp.last_updated_by_object_id = :b_rollup_obj_id'||
    ' when not matched then'||
    '   insert ('||
    '     bp.dataset_code'||
    '     ,bp.cal_period_id'||
    '     ,bp.creation_row_sequence'||
    '     ,bp.source_system_code'||
    '     ,bp.currency_code'||
    '     ,bp.currency_type_code'||
    '     ,bp.cost_object_id'||
          p_sql_rec.comp_dim_comp_cols_insert||
          p_sql_rec.comp_dim_data_cols_insert||
    '     ,bp.created_by_request_id'||
    '     ,bp.created_by_object_id'||
    '     ,bp.last_updated_by_request_id'||
    '     ,bp.last_updated_by_object_id'||
    '     ,bp.xtd_balance_e'||
    '     ,bp.xtd_balance_f'||
    '   )'||
    '   values'||
    '   ('||
    '     :b_output_dataset_code'||
    '     ,:b_output_cal_period_id'||
    '     ,'||p_rule_rec.sequence_name||'.NEXTVAL'||
    '     ,bc.source_system_code'||
    '     ,bc.currency_code'||
    '     ,bc.currency_type_code'||
    '     ,bc.cost_object_id'||
          p_sql_rec.comp_dim_comp_cols_values||
          p_sql_rec.comp_dim_data_cols_values||
    '     ,:b_request_id'||
    '     ,:b_rollup_obj_id'||
    '     ,:b_request_id'||
    '     ,:b_rollup_obj_id'||
    '     ,round((bc.xtd_balance_f * :b_weighting_pct),37) / :b_child_exch_rate_den * :b_child_exch_rate_num / :b_entered_exch_rate_den * :b_entered_exch_rate_num'||
    '     ,round((bc.xtd_balance_f * :b_weighting_pct),37) / :b_child_exch_rate_den * :b_child_exch_rate_num'||
    '   )';

    x_find_child_chains_stmt :=
    ' select distinct created_by_request_id'||
    ' ,created_by_object_id'||
    ' from fem_balances b'||
    ' where b.currency_type_code = ''ENTERED'''||
    ' and '||p_input_ds_b_where_clause||
    ' and b.cost_object_id = :b_child_id'||
    ' and not ('||
    '   b.created_by_request_id = :b_request_id'||
    '   and b.created_by_object_id = :b_rollup_obj_id'||
    ' )'||
    ' and not exists ('||
    '   select 1'||
    '   from fem_pl_chains c'||
    '   where c.request_id = :b_request_id'||
    '   and c.object_id = :b_rollup_obj_id'||
    '   and c.source_created_by_request_id = b.created_by_request_id'||
    '   and c.source_created_by_object_id = b.created_by_object_id'||
    ' )';

    x_num_of_input_rows_stmt :=
    ' select count(*)'||
    ' from fem_balances b'||
    ' where b.currency_type_code = ''ENTERED'''||
    ' and '||p_input_ds_b_where_clause||
    ' and not ('||
    '   created_by_request_id = :b_request_id'||
    '   and created_by_object_id = :b_rollup_obj_id'||
    ' )'||
    ' and exists ('||
    '   select 1'||
    '   from fem_ru_nodes_t n'||
    '   where n.created_by_request_id = :b_request_id'||
    '   and n.created_by_object_id = :b_rollup_obj_id'||
    '   and n.node_id = b.cost_object_id'||
    '   and n.costed_flag = ''Y'''||
    '   and n.root_flag = ''N'''||
    '   and n.condition_flag = ''N'''||
    ' )';

  elsif (l_dimension_rec.dimension_varchar_label = 'ACTIVITY') then

    -- Build SQL statement for finding all Parent-Child Relationships
    x_find_children_stmt :=
    ' select h.child_id'||
    ' ,nvl(h.weighting_pct,1.00) as weighting_pct'||
    ' ,null as child_ledger_id'||
    ' from '||p_rule_rec.hier_rollup_table||' h'||
    ' where h.hierarchy_obj_def_id = :b_hier_obj_def_id'||
    ' and h.child_id <> h.parent_id'||
    ' and h.single_depth_flag = ''Y'''||
    ' and h.parent_id = :b_parent_id'||
    ' and h.parent_depth_num = :b_parent_depth_num';

    -- If condition exists, we must include request_id and rollup_obj_id in the
    -- where clause for querying FEM_RU_ACTIVITIES_HIER_T
    if (p_rule_rec.cond_exists) then

      x_find_children_stmt := x_find_children_stmt ||
      ' and h.created_by_request_id = :b_request_id'||
      ' and h.created_by_object_id = :b_rollup_obj_id';

    end if;

    if (p_request_rec.rollup_type_code = 'COST') then
      l_financial_elem_id_clause := 'b.financial_elem_id not in ('||
        G_FIN_ELEM_ID_STATISTIC||','||G_FIN_ELEM_ID_ACTIVITY_RATE||')';
      l_line_item_id_clause := '1=1';
    elsif (p_request_rec.rollup_type_code = 'STAT') then
      l_financial_elem_id_clause := 'b.financial_elem_id = '||
        G_FIN_ELEM_ID_STATISTIC;
      l_line_item_id_clause := 'b.line_item_id = :b_statistic_basis_id';
    end if;

    -- Build SQL statement for performing the rollup
    x_rollup_parent_stmt :=
    ' merge into fem_balances bp'||
    ' using ('||
    '   select :b_source_system_code as source_system_code'||--new
    '   ,:b_currency_code as currency_code'||--new
    '   ,b.currency_type_code'||
    '   ,b.ledger_id'||
    '   ,parent.activity_id'||
        p_sql_rec.comp_dim_comp_cols_using||
        p_sql_rec.comp_dim_data_cols_using||
    '   ,sum(b.xtd_balance_f) xtd_balance_f'||
    '   from fem_balances b'||
    '   ,fem_activities parent'||
    '   where b.activity_id = :b_child_id'||
    '   and parent.activity_id = :b_parent_id'||
    '   and b.ledger_id = :b_ledger_id'||
    '   and b.currency_type_code = ''ENTERED'''||
    '   and '||l_financial_elem_id_clause||
    '   and '||l_line_item_id_clause||
    '   and '||p_input_ds_b_where_clause||
    '   group by b.currency_type_code'||
    '   ,b.ledger_id'||
    '   ,parent.activity_id'||
        p_sql_rec.comp_dim_comp_cols_using||
        p_sql_rec.comp_dim_data_cols_using||
    ' ) bc'||
    ' on ('||
    '   bp.source_system_code = bc.source_system_code'||
    '   and bp.currency_code = bc.currency_code'||
    '   and bp.currency_type_code = bc.currency_type_code'||
    '   and bp.ledger_id = bc.ledger_id'||
    '   and bp.activity_id = bc.activity_id'||
        p_sql_rec.comp_dim_data_cols_on||
    '   and bp.dataset_code = :b_output_dataset_code'||
    '   and bp.cal_period_id = :b_output_cal_period_id'||
    '   and bp.created_by_request_id = :b_request_id'||
    '   and bp.created_by_object_id = :b_rollup_obj_id'||
    ' )'||
    ' when matched then'||
    '   update set'||
    '     bp.xtd_balance_e = bp.xtd_balance_e + ( bc.xtd_balance_f * :b_weighting_pct / :b_entered_exch_rate_den * :b_entered_exch_rate_num)'||
    '     ,bp.xtd_balance_f = bp.xtd_balance_f + ( bc.xtd_balance_f * :b_weighting_pct)'||
    '     ,bp.last_updated_by_request_id = :b_request_id'||
    '     ,bp.last_updated_by_object_id = :b_rollup_obj_id'||
    ' when not matched then'||
    '   insert ('||
    '     bp.dataset_code'||
    '     ,bp.cal_period_id'||
    '     ,bp.creation_row_sequence'||
    '     ,bp.source_system_code'||
    '     ,bp.currency_code'||
    '     ,bp.currency_type_code'||
    '     ,bp.ledger_id'||
    '     ,bp.activity_id'||
          p_sql_rec.comp_dim_comp_cols_insert||
          p_sql_rec.comp_dim_data_cols_insert||
    '     ,bp.created_by_request_id'||
    '     ,bp.created_by_object_id'||
    '     ,bp.last_updated_by_request_id'||
    '     ,bp.last_updated_by_object_id'||
    '     ,bp.xtd_balance_e'||
    '     ,bp.xtd_balance_f'||
    '   )'||
    '   values'||
    '   ('||
    '     :b_output_dataset_code'||
    '     ,:b_output_cal_period_id'||
    '     ,'||p_rule_rec.sequence_name||'.NEXTVAL'||
    '     ,bc.source_system_code'||
    '     ,bc.currency_code'||
    '     ,bc.currency_type_code'||
    '     ,bc.ledger_id'||
    '     ,bc.activity_id'||
          p_sql_rec.comp_dim_comp_cols_values||
          p_sql_rec.comp_dim_data_cols_values||
    '     ,:b_request_id'||
    '     ,:b_rollup_obj_id'||
    '     ,:b_request_id'||
    '     ,:b_rollup_obj_id'||
    '     ,bc.xtd_balance_f * :b_weighting_pct / :b_entered_exch_rate_den * :b_entered_exch_rate_num'||
    '     ,bc.xtd_balance_f * :b_weighting_pct'||
    '   )';

    x_find_child_chains_stmt :=
    ' select distinct created_by_request_id'||
    ' ,created_by_object_id'||
    ' from fem_balances b'||
    ' where b.ledger_id = :b_ledger_id'||
    ' and b.currency_type_code = ''ENTERED'''||
    ' and '||l_financial_elem_id_clause||
    ' and '||l_line_item_id_clause||
    ' and '||p_input_ds_b_where_clause||
    ' and b.activity_id = :b_child_id'||
    ' and not ('||
    '   b.created_by_request_id = :b_request_id'||
    '   and b.created_by_object_id = :b_rollup_obj_id'||
    ' )'||
    ' and not exists ('||
    '   select 1'||
    '   from fem_pl_chains c'||
    '   where c.request_id = :b_request_id'||
    '   and c.object_id = :b_rollup_obj_id'||
    '   and c.source_created_by_request_id = b.created_by_request_id'||
    '   and c.source_created_by_object_id = b.created_by_object_id'||
    ' )';

    x_num_of_input_rows_stmt :=
    ' select count(*)'||
    ' from fem_balances b'||
    ' where b.ledger_id = :b_ledger_id'||
    ' and b.currency_type_code = ''ENTERED'''||
    ' and '||l_financial_elem_id_clause||
    ' and '||l_line_item_id_clause||
    ' and '||p_input_ds_b_where_clause||
    ' and not ('||
    '   created_by_request_id = :b_request_id'||
    '   and created_by_object_id = :b_rollup_obj_id'||
    ' )'||
    ' and exists ('||
    '   select 1'||
    '   from fem_ru_nodes_t n'||
    '   where n.created_by_request_id = :b_request_id'||
    '   and n.created_by_object_id = :b_rollup_obj_id'||
    '   and n.node_id = b.activity_id'||
    '   and n.costed_flag = ''Y'''||
    '   and n.root_flag = ''N'''||
    '   and n.condition_flag = ''N'''||
    ' )';

  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name||'.x_find_children_stmt'
    ,p_msg_text => x_find_children_stmt
  );

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name||'.x_rollup_parent_stmt'
    ,p_msg_text => x_rollup_parent_stmt
  );

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name||'.x_find_child_chains_stmt'
    ,p_msg_text => x_find_child_chains_stmt
  );

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name||'.x_num_of_input_rows_stmt'
    ,p_msg_text => x_num_of_input_rows_stmt
  );

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_sql_stmts_build_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'SQL Statements Build Exception'
    );

    raise g_rollup_request_error;

END Sql_Stmts_Build;



/*============================================================================+
 | PROCEDURE
 |   Register_Rule
 |
 | DESCRIPTION
 |   Registers the rule in the processing locks tables.  This includes
 |   registering the rollup object execution, its dependent object
 |   definitions, and any output tables.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

PROCEDURE Register_Rule (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
)
IS

  l_api_name             constant varchar2(30) := 'Register_Rule';

  l_exec_state                    varchar2(30); -- normal, restart, rerun
  l_prev_request_id               number;

  l_return_status                 t_return_status%TYPE;
  l_msg_count                     t_msg_count%TYPE;
  l_msg_data                      t_msg_data%TYPE;

  l_register_rule_error           exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  savepoint register_rule_pub;

  -- Call the FEM_PL_PKG.Register_Object_Execution API procedure to register
  -- the rollup object execution in FEM_PL_OBJECT_EXECUTIONS, thus obtaining
  -- an execution lock.
  FEM_PL_PKG.Register_Object_Execution (
    p_api_version                => 1.0
    ,p_commit                    => FND_API.G_FALSE
    ,p_request_id                => p_request_rec.request_id
    ,p_object_id                 => p_rule_rec.rollup_obj_id
    ,p_exec_object_definition_id => p_rule_rec.rollup_obj_def_id
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

  -- Register all the Dependent Objects for the Rollup Object Definition
  FEM_PL_PKG.Register_Dependent_ObjDefs (
    p_api_version                => 1.0
    ,p_commit                    => FND_API.G_FALSE
    ,p_request_id                => p_request_rec.request_id
    ,p_object_id                 => p_rule_rec.rollup_obj_id
    ,p_exec_object_definition_id => p_rule_rec.rollup_obj_def_id
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
    ,p_object_id   => p_rule_rec.rollup_obj_id
    ,p_table_name  => 'FEM_BALANCES'
    ,p_ledger_id   => p_request_rec.ledger_id
    ,p_cal_per_id  => p_request_rec.output_cal_period_id
    ,p_dataset_cd  => p_request_rec.output_dataset_code
    ,p_source_cd   => p_request_rec.source_system_code
    ,p_load_status => null
  );

  -- Register the FEM_BALANCES output table as INSERT.
  --
  -- NOTE: Eventhough we create output data in FEM_BALANCES through a MERGE
  -- statement, we are not updating records from other CREATED_BY_REQUEST_ID
  -- and CREATED_BY_OBJECT_ID combinations.  We are using the MERGE statement
  -- to insert or update rows such that:
  --
  --     CREATED_BY_REQUEST_ID = p_request_rec.request_id
  --     and CREATED_BY_OBJECT_ID = p_rule_rec.rollup_obj_id
  --
  -- We must therefore register the FEM_BALANCES output table as INSERT so that
  -- Undo will simply delete all output records, rather than zero the balance
  -- columns.  And since we are registering FEM_BALANCES as INSERT, we do not
  -- need to register the updated columns for the Undo functionality.
  Register_Table (
    p_request_rec     => p_request_rec
    ,p_rule_rec       => p_rule_rec
    ,p_table_name     => 'FEM_BALANCES'
    ,p_statement_type => 'INSERT'
  );

  -- Register the FEM_RU_NODES_T processing table as INSERT.  This is needed
  -- in the event of a engine failure where the only way to purge these records
  -- is through the Undo Process
  Register_Table (
    p_request_rec     => p_request_rec
    ,p_rule_rec       => p_rule_rec
    ,p_table_name     => 'FEM_RU_NODES_T'
    ,p_statement_type => 'INSERT'
  );

  if (p_request_rec.dimension_rec.dimension_varchar_label = 'COST_OBJECT') then

    -- Register the FEM_RU_COST_OBJ_HIER_T processing table as INSERT.
    -- This is needed in the event of a engine failure where the only way to
    -- purge these records is through the Undo Process
    Register_Table (
      p_request_rec     => p_request_rec
      ,p_rule_rec       => p_rule_rec
      ,p_table_name     => 'FEM_RU_COST_OBJ_HIER_T'
      ,p_statement_type => 'INSERT'
    );

  elsif ( (p_request_rec.dimension_rec.dimension_varchar_label = 'ACTIVITY')
      and (p_rule_rec.cond_exists) ) then

    -- Register the FEM_RU_ACTIVITIES_HIER_T processing table as INSERT.
    -- This is needed in the event of a engine failure where the only way to
    -- purge these records is through the Undo Process
    Register_Table (
      p_request_rec     => p_request_rec
      ,p_rule_rec       => p_rule_rec
      ,p_table_name     => 'FEM_RU_ACTIVITIES_HIER_T'
      ,p_statement_type => 'INSERT'
    );

  end if;

  commit;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_register_rule_error then

    rollback to register_rule_pub;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Register Rule Exception'
    );

    raise g_rollup_request_error;

  when g_rollup_request_error then

    rollback to register_rule_pub;
    raise g_rollup_request_error;

  when others then

    rollback to register_rule_pub;
    raise;

END Register_Rule;



/*============================================================================+
 | PROCEDURE
 |   Register_Object_Definition
 |
 | DESCRIPTION
 |   Registers the specified object definition.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

PROCEDURE Register_Object_Definition (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
  ,p_obj_def_id                   in number
)
IS

  l_api_name             constant varchar2(30) := 'Register_Object_Definition';

  l_return_status                 t_return_status%TYPE;
  l_msg_count                     t_msg_count%TYPE;
  l_msg_data                      t_msg_data%TYPE;

  l_register_obj_def_error        exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  -- Call the FEM_PL_PKG.Register_Object_Def API procedure to register
  -- the specified object definition in FEM_PL_OBJECT_DEFS, thus obtaining
  -- an object definition lock.
  FEM_PL_PKG.Register_Object_Def (
    p_api_version           => 1.0
    ,p_commit               => FND_API.G_FALSE
    ,p_request_id           => p_request_rec.request_id
    ,p_object_id            => p_rule_rec.rollup_obj_id
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
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_register_obj_def_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Register Object Definition Exception'
    );

    raise g_rollup_request_error;

END Register_Object_Definition;



/*============================================================================+
 | PROCEDURE
 |   Register_Table
 |
 | DESCRIPTION
 |   Registers the specified table name and statement type
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

PROCEDURE Register_Table (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
  ,p_table_name                   in varchar2
  ,p_statement_type               in varchar2
)
IS

  l_api_name             constant varchar2(30) := 'Register_Table';

  l_return_status                 t_return_status%TYPE;
  l_msg_count                     t_msg_count%TYPE;
  l_msg_data                      t_msg_data%TYPE;

  l_register_table_error          exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  -- Call the FEM_PL_PKG.Register_Table API procedure to register
  -- the specified output table and the statement type that will be used.
  FEM_PL_PKG.Register_Table (
    p_api_version         => 1.0
    ,p_commit             => FND_API.G_FALSE
    ,p_request_id         => p_request_rec.request_id
    ,p_object_id          => p_rule_rec.rollup_obj_id
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
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_register_table_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Register Table Exception'
    );

    raise g_rollup_request_error;

END Register_Table;



/*============================================================================+
 | PROCEDURE
 |   Create_Temp_Objects
 |
 | DESCRIPTION
 |   Creates all the temporary objects necessary for processing a rollup rule.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

PROCEDURE Create_Temp_Objects (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
)
IS

  l_api_name             constant varchar2(30) := 'Create_Temp_Objects';

  l_return_status                 t_return_status%TYPE;
  l_msg_count                     t_msg_count%TYPE;
  l_msg_data                      t_msg_data%TYPE;

  l_create_temp_objects_error     exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  ------------------------------------------------------------------------------
  -- Create Temporary Sequence for peforming Rollup Processing in FEM_BALANCES.
  ------------------------------------------------------------------------------
  begin
    -- Temporary sequence is in the default APPS schema as GSCC does not
    -- allow hardcoded schemas.
    execute immediate 'create sequence '||p_rule_rec.sequence_name;
  exception
    when others then
      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_ENG_CREATE_SEQUENCE_ERR
        ,p_token1   => 'SEQUENCE_NAME'
        ,p_value1   => p_rule_rec.sequence_name
      );
      raise l_create_temp_objects_error;
  end;

  -- Register Temp Sequence in PL Framework
  FEM_PL_PKG.Register_Temp_Object (
    p_api_version       => 1.0
    ,p_commit            => FND_API.G_FALSE
    ,p_request_id        => p_request_rec.request_id
    ,p_object_id         => p_rule_rec.rollup_obj_id
    ,p_object_type       => 'SEQUENCE'
    ,p_object_name       => p_rule_rec.sequence_name
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
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_create_temp_objects_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Create Temporary Objects Exception'
    );

    raise g_rollup_request_error;

END Create_Temp_Objects;



/*============================================================================+
 | PROCEDURE
 |   Drop_Temp_Objects
 |
 | DESCRIPTION
 |   Drops all the temporary objects that were created for processing a rollup
 |   rule.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

PROCEDURE Drop_Temp_Objects (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
)
IS

  l_api_name             constant varchar2(30) := 'Drop_Temp_Objects';

  l_object_exists_flag            varchar2(1);
  l_completion_status             boolean;

  l_drop_temp_objects_error       exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  ------------------------------------------------------------------------------
  -- Drop Temporary Sequence for peforming Rollup Processing on FEM_BALANCES.
  ------------------------------------------------------------------------------
  begin
    select 'Y'
    into l_object_exists_flag
    from fem_pl_temp_objects
    where request_id = p_request_rec.request_id
    and object_id = p_rule_rec.rollup_obj_id
    and object_type = 'SEQUENCE'
    and object_name = p_rule_rec.sequence_name;
  exception
    when no_data_found then
      l_object_exists_flag := 'N';
  end;

  if (l_object_exists_flag = 'Y') then

    begin

      -- Temporary sequence is in the default APPS schema as GSCC does not
      -- allow hardcoded schemas.
      execute immediate 'drop sequence '||p_rule_rec.sequence_name;

      delete from fem_pl_temp_objects
      where request_id = p_request_rec.request_id
      and object_id = p_rule_rec.rollup_obj_id
      and object_type = 'SEQUENCE'
      and object_name = p_rule_rec.sequence_name;

    exception
      when others then
        l_completion_status := FND_CONCURRENT.Set_Completion_Status('WARNING',null);
        FEM_ENGINES_PKG.User_Message (
          p_app_name  => G_FEM
          ,p_msg_name => G_ENG_DROP_SEQUENCE_WRN
          ,p_token1   => 'SEQUENCE_NAME'
          ,p_value1   => p_rule_rec.sequence_name
        );
    end;

    commit;

  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_drop_temp_objects_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Drop Temp Objects Exception'
    );

    raise g_rollup_request_error;

END Drop_Temp_Objects;



/*============================================================================+
 | PROCEDURE
 |   Find_Condition_Nodes
 |
 | DESCRIPTION
 |   Finds all the nodes in the rollup hierarchy that satisfies the rollup
 |   rule's condition, and stores them in the FEM_RU_NODES_T table.  If any of
 |   condition nodes are hierarchies, these are labeled as such in the
 |   FEM_RU_NODES_T table.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

PROCEDURE Find_Condition_Nodes (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
)
IS

  l_api_name             constant varchar2(30) := 'Find_Condition_Nodes';

  l_dimension_rec                 dimension_record;
  l_find_cond_node_stmt           long;
  l_find_cond_leaf_stmt           long;
  l_find_cond_root_stmt           long;
  l_cond_where_clause             long;
  l_node_count                    number;
  l_leaf_count                    number;

  l_return_status                 t_return_status%TYPE;
  l_msg_count                     t_msg_count%TYPE;
  l_msg_data                      t_msg_data%TYPE;

  l_find_cond_nodes_error         exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  l_dimension_rec := p_request_rec.dimension_rec;

  ------------------------------------------------------------------------------
  -- STEP 1: Generate Condition Where Clause Predicate
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 1: Generate Condition Where Clause Predicate'
  );

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
    ,p_table_alias           => 'm'
    ,p_display_predicate     => 'N'
    ,p_return_predicate_type => 'DIM'
    ,p_logging_turned_on     => 'N'
    ,x_predicate_string      => l_cond_where_clause
  );

  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
    Get_Put_Messages (
      p_msg_count => l_msg_count
      ,p_msg_data => l_msg_data
    );
    raise l_find_cond_nodes_error;
  end if;

  if (l_cond_where_clause is null) then

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
    raise l_find_cond_nodes_error;

  end if;

  ------------------------------------------------------------------------------
  -- STEP 2: Find "Parent" Condition Nodes
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 2: Find "Parent" Condition Nodes'
  );

  -- Build SQL statement for finding and inserting "Parent" Condition Nodes
  -- into FEM_RU_NODES_T
  l_find_cond_node_stmt :=
  ' insert into fem_ru_nodes_t ('||
  '   created_by_request_id'||
  '   ,created_by_object_id'||
  '   ,node_id'||
  '   ,costed_flag'||
  '   ,root_flag'||
  '   ,condition_flag'||
  ' )'||
  ' select :b_request_id'||
  ' ,:b_rollup_obj_id'||
  ' ,m.'||l_dimension_rec.member_col||
  ' ,''N'''||
  ' ,''N'''||
  ' ,''Y'''||
  ' from '||l_dimension_rec.member_b_table||' m'||
  ' where m.local_vs_combo_id = :b_local_vs_combo_id'||
--  ' and {{data_slice}}'||
  ' and '||l_cond_where_clause||
  ' and not exists ('||
  '   select 1'||
  '   from fem_ru_nodes_t n'||
  '   where n.created_by_request_id = :b_request_id'||
  '   and n.created_by_object_id = :b_rollup_obj_id'||
  '   and n.node_id = m.'||l_dimension_rec.member_col||
  ' )';

  if (l_dimension_rec.dimension_varchar_label = 'COST_OBJECT') then

    l_find_cond_node_stmt := l_find_cond_node_stmt ||
    ' and m.ledger_id = :b_ledger_id'|| --must restrict by ledger for x-ledger
    ' and exists ('||
    '   select 1'||
    '   from '||l_dimension_rec.hier_table||' h'||
    '   where h.hierarchy_obj_id = :b_hier_obj_id'||
    '   and :b_effective_date between h.effective_start_date and h.effective_end_date'||
    '   and h.parent_id = m.'||l_dimension_rec.member_col||
    ' )';

    --todo:  MP integration
    -- Execute SQL for finding all "Parent" Condition Nodes for the specified
    -- hierarchy object and effective date
    execute immediate l_find_cond_node_stmt
    using p_request_rec.request_id
    ,p_rule_rec.rollup_obj_id
    ,p_rule_rec.local_vs_combo_id
    ,p_request_rec.request_id
    ,p_rule_rec.rollup_obj_id
    ,p_request_rec.ledger_id
    ,p_rule_rec.hier_obj_id
    ,p_request_rec.effective_date;

  elsif (l_dimension_rec.dimension_varchar_label = 'ACTIVITY') then

    l_find_cond_node_stmt := l_find_cond_node_stmt ||
    ' and exists ('||
    '   select 1'||
    '   from '||l_dimension_rec.hier_table||' h'||
    '   where h.hierarchy_obj_def_id = :b_hier_obj_def_id'||
    '   and h.single_depth_flag = ''Y'''||
    '   and h.parent_id = m.'||l_dimension_rec.member_col||
    ' )';

    --todo:  MP integration
    -- Execute SQL for finding all "Parent" Condition Nodes for the specified
    -- hierarchy object definition
    execute immediate l_find_cond_node_stmt
    using p_request_rec.request_id
    ,p_rule_rec.rollup_obj_id
    ,p_rule_rec.local_vs_combo_id
    ,p_request_rec.request_id
    ,p_rule_rec.rollup_obj_id
    ,p_rule_rec.hier_obj_def_id;

  else

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_RU_NO_ROLLUP_DIM_ERR
      ,p_token1   => 'DIMENSION_VARCHAR_LABEL'
      ,p_value1   => l_dimension_rec.dimension_varchar_label
    );
    raise l_find_cond_nodes_error;

  end if;

  commit;

  ------------------------------------------------------------------------------
  -- STEP 3: Count "Parent" Conditions Nodes
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 3: Count "Parent" Condition Nodes'
  );

  -- Count the number of "Parent" Condition Nodes in FEM_RU_NODES_T
  select count(*)
  into l_node_count
  from fem_ru_nodes_t
  where created_by_request_id = p_request_rec.request_id
  and created_by_object_id = p_rule_rec.rollup_obj_id;

  if (l_node_count = 0) then

    ----------------------------------------------------------------------------
    -- STEP 3.a: Count "Leaf" Condition Nodes
    ----------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Step 3.a: Count "Leaf" Condition Nodes'
    );

    -- Build SQL statement for counting "Leaf" Condition Nodes
    l_find_cond_leaf_stmt :=
    ' select count(*)'||
    ' from '||l_dimension_rec.member_b_table||' m'||
    ' where m.local_vs_combo_id = :b_local_vs_combo_id'||
    ' and '||l_cond_where_clause;

    if (l_dimension_rec.dimension_varchar_label = 'COST_OBJECT') then

      l_find_cond_leaf_stmt := l_find_cond_leaf_stmt ||
      ' and m.ledger_id = :b_ledger_id'|| --must restrict by ledger for x-ledger
      ' and exists ('||
      '   select 1'||
      '   from '||l_dimension_rec.hier_table||' h'||
      '   where h.hierarchy_obj_id = :b_hier_obj_id'||
      '   and :b_effective_date between h.effective_start_date and h.effective_end_date'||
      '   and h.child_id = m.'||l_dimension_rec.member_col||
      ' )';

      -- Execute SQL for counting all "Leaf" Condition Nodes for the specified
      -- hierarchy object and effective date
      execute immediate l_find_cond_leaf_stmt
      into l_leaf_count
      using p_rule_rec.local_vs_combo_id
      ,p_request_rec.ledger_id
      ,p_rule_rec.hier_obj_id
      ,p_request_rec.effective_date;

    elsif (l_dimension_rec.dimension_varchar_label = 'ACTIVITY') then

      l_find_cond_leaf_stmt := l_find_cond_leaf_stmt ||
      ' and exists ('||
      '   select 1'||
      '   from '||l_dimension_rec.hier_table||' h'||
      '   where h.hierarchy_obj_def_id = :b_hier_obj_def_id'||
      '   and h.single_depth_flag = ''Y'''||
      '   and h.child_id = m.'||l_dimension_rec.member_col||
      ' )';

      -- Execute SQL for counting all "Leaf" Condition Nodes for the specified
      -- hierarchy object definition
      execute immediate l_find_cond_leaf_stmt
      into l_leaf_count
      using p_rule_rec.local_vs_combo_id
      ,p_rule_rec.hier_obj_def_id;

    else

      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_RU_NO_ROLLUP_DIM_ERR
        ,p_token1   => 'DIMENSION_VARCHAR_LABEL'
        ,p_value1   => l_dimension_rec.dimension_varchar_label
      );
      raise l_find_cond_nodes_error;

    end if;

    if (l_leaf_count = 0) then

      -- No Condition Nodes were found in the specified hierarchy
      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_RU_NO_COND_NODES_FOUND_ERR
      );
      raise l_find_cond_nodes_error;

    else

      -- Only "Leaf" Condition Nodes were found in the specified hierarchy.
      -- Rollup is not necessary on leaf nodes.
      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => G_RU_COND_NODES_LEAFS_ERR
      );
      raise l_find_cond_nodes_error;

    end if;

  end if;

  ------------------------------------------------------------------------------
  -- STEP 4: Find "Root" Condition Nodes
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 4: Find "Root" Condition Nodes'
  );

  -- Build SQL statement for finding any possible "Root" Condition Nodes
  -- in FEM_RU_NODES_T and update the Root Node Flag to Y.
  l_find_cond_root_stmt :=
  ' update fem_ru_nodes_t n'||
  ' set root_flag = ''Y'''||
  ' where created_by_request_id = :b_request_id'||
  ' and created_by_object_id = :b_rollup_obj_id';
--  ' and {{data_slice}}';

  if (l_dimension_rec.dimension_varchar_label = 'COST_OBJECT') then

    l_find_cond_root_stmt := l_find_cond_root_stmt ||
    ' and not exists ('||
    '   select 1'||
    '   from '||l_dimension_rec.hier_table||' h'||
    '   ,'||l_dimension_rec.member_b_table||' parent'||
    '   where h.hierarchy_obj_id = :b_hier_obj_id'||
    '   and :b_effective_date between h.effective_start_date and h.effective_end_date'||
    '   and h.child_id = n.node_id'||
    '   and parent.'||l_dimension_rec.member_col||' = h.parent_id'||
    '   and parent.ledger_id = :b_ledger_id'|| --must restrict by ledger for x-ledger
    ' )';

    --todo:  MP integration
    -- Execute SQL for finding all "Root" Condition Nodes for the specified
    -- hierarchy object and effective date and update Root Node Flag to Y.
    execute immediate l_find_cond_root_stmt
    using p_request_rec.request_id
    ,p_rule_rec.rollup_obj_id
    ,p_rule_rec.hier_obj_id
    ,p_request_rec.effective_date
    ,p_request_rec.ledger_id;

  elsif (l_dimension_rec.dimension_varchar_label = 'ACTIVITY') then

    l_find_cond_root_stmt := l_find_cond_root_stmt ||
    ' and exists ('||
    '   select 1'||
    '   from '||l_dimension_rec.hier_table||' h'||
    '   where h.hierarchy_obj_def_id = :b_hier_obj_def_id'||
    '   and h.child_id = h.parent_id'||
    '   and h.single_depth_flag = ''Y'''||
    '   and h.parent_id = n.node_id'||
    ' )';

    --todo:  MP integration
    -- Execute SQL for finding all "Root" Condition Nodes for the specified
    -- hierarchy object definition and update Root Node Flag to Y
    execute immediate l_find_cond_root_stmt
    using p_request_rec.request_id
    ,p_rule_rec.rollup_obj_id
    ,p_rule_rec.hier_obj_def_id;

  end if;

  commit;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_find_cond_nodes_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Find Condition Nodes Exception'
    );

    raise g_rollup_request_error;

END Find_Condition_Nodes;



/*============================================================================+
 | PROCEDURE
 |   Find_Root_Nodes
 |
 | DESCRIPTION
 |   Finds all the root nodes in the rollup hierarchy, and stores them in the
 |   FEM_RU_NODES_T table.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

PROCEDURE Find_Root_Nodes (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
)
IS

  l_api_name             constant varchar2(30) := 'Find_Root_Nodes';


  l_dimension_rec                 dimension_record;
  l_node_count                    number;
  l_find_root_node_stmt           long;

  l_find_root_nodes_error         exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  l_dimension_rec := p_request_rec.dimension_rec;

  ------------------------------------------------------------------------------
  -- STEP 1: Find Root Nodes
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 1: Find Root Nodes'
  );

  -- Build SQL statement for finding and inserting Root Nodes into
  -- FEM_RU_NODES_T
  l_find_root_node_stmt :=
  ' insert into fem_ru_nodes_t ('||
  '   created_by_request_id'||
  '   ,created_by_object_id'||
  '   ,node_id'||
  '   ,costed_flag'||
  '   ,root_flag'||
  '   ,condition_flag'||
  ' )'||
  ' select :b_request_id'||
  ' ,:b_rollup_obj_id'||
  ' ,m.'||l_dimension_rec.member_col||
  ' ,''N'''||
  ' ,''Y'''||
  ' ,''N'''||
  ' from '||l_dimension_rec.member_b_table||' m'||
  ' where m.local_vs_combo_id = :b_local_vs_combo_id'||
--  ' and {{data_slice}}'||
  ' and not exists ('||
  '   select 1'||
  '   from fem_ru_nodes_t n'||
  '   where n.created_by_request_id = :b_request_id'||
  '   and n.created_by_object_id = :b_rollup_obj_id'||
  '   and n.node_id = m.'||l_dimension_rec.member_col||
  ' )';

  if (l_dimension_rec.dimension_varchar_label = 'COST_OBJECT') then

    l_find_root_node_stmt := l_find_root_node_stmt ||
    ' and m.ledger_id = :b_ledger_id'|| --must restrict by ledger for x-ledger
    ' and exists ('||
    '   select 1'||
    '   from '||l_dimension_rec.hier_table||' h'||
    '   where h.hierarchy_obj_id = :b_hier_obj_id'||
    '   and :b_effective_date between h.effective_start_date and h.effective_end_date'||
    '   and h.parent_id = m.'||l_dimension_rec.member_col||
    ' )'||
    ' and not exists ('||
    '   select 1'||
    '   from '||l_dimension_rec.hier_table||' h'||
    '   ,'||l_dimension_rec.member_b_table||' parent'||
    '   where h.hierarchy_obj_id = :b_hier_obj_id'||
    '   and :b_effective_date between h.effective_start_date and h.effective_end_date'||
    '   and h.child_id = m.'||l_dimension_rec.member_col||
    '   and parent.'||l_dimension_rec.member_col||' = h.parent_id'||
    '   and parent.ledger_id = m.ledger_id'|| --must restrict by ledger for x-ledger
    ' )';

    --todo:  MP integration
    -- Execute SQL for finding all Root Nodes for the specified
    -- hierarchy object and effective date
    execute immediate l_find_root_node_stmt
    using p_request_rec.request_id
    ,p_rule_rec.rollup_obj_id
    ,p_rule_rec.local_vs_combo_id
    ,p_request_rec.request_id
    ,p_rule_rec.rollup_obj_id
    ,p_request_rec.ledger_id
    ,p_rule_rec.hier_obj_id
    ,p_request_rec.effective_date
    ,p_rule_rec.hier_obj_id
    ,p_request_rec.effective_date;

  elsif (l_dimension_rec.dimension_varchar_label = 'ACTIVITY') then

    l_find_root_node_stmt := l_find_root_node_stmt ||
    ' and exists ('||
    '   select 1'||
    '   from '||l_dimension_rec.hier_table||' h'||
    '   where h.hierarchy_obj_def_id = :b_hier_obj_def_id'||
    '   and h.child_id = h.parent_id'||
    '   and h.single_depth_flag = ''Y'''||
    '   and h.parent_id = m.'||l_dimension_rec.member_col||
    ' )';

    --todo:  MP integration
    -- Execute SQL for finding all Root Nodes for the specified
    -- hierarchy object definition
    execute immediate l_find_root_node_stmt
    using p_request_rec.request_id
    ,p_rule_rec.rollup_obj_id
    ,p_rule_rec.local_vs_combo_id
    ,p_request_rec.request_id
    ,p_rule_rec.rollup_obj_id
    ,p_rule_rec.hier_obj_def_id;

  else

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_RU_NO_ROLLUP_DIM_ERR
      ,p_token1   => 'DIMENSION_VARCHAR_LABEL'
      ,p_value1   => l_dimension_rec.dimension_varchar_label
    );
    raise l_find_root_nodes_error;

  end if;

  commit;

  ------------------------------------------------------------------------------
  -- STEP 2: Count Root Nodes
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 2: Count Root Nodes'
  );

  select count(*)
  into l_node_count
  from fem_ru_nodes_t
  where created_by_request_id = p_request_rec.request_id
  and created_by_object_id = p_rule_rec.rollup_obj_id
  and root_flag = 'Y';

  if (l_node_count = 0) then

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_RU_NO_ROOT_NODES_FOUND_ERR
    );
    raise l_find_root_nodes_error;

  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_find_root_nodes_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Find Root Nodes Exception'
    );

    raise g_rollup_request_error;

END Find_Root_Nodes;



/*============================================================================+
 | PROCEDURE
 |   Rollup_Top_Node
 |
 | DESCRIPTION
 |   Peforms multi-level rollup on the specified top node of a rollup hierarchy.
 |
 |   Flattening of the rollup hierarchy is necessary when performing rollups on
 |   the cost object hierarchy (regardless if a condition is specified or not),
 |   or on the activity hierarchy if and only if a condition is specified. The
 |   flattened hierarchy is store in FEM_RU_COST_OBJ_HIER_T for the cost object
 |   hierarchy, and in FEM_RU_ACTIVITIES_HIER_T for the activity hierarchy.
 |   After finishing all rollup processing for a top node, the flattened
 |   hierarchies need to be purged.
 |
 |   Rollup processing is done on a level by level basis, starting with the
 |   top node's deepest level, then climbing up to the next level and so forth,
 |   until the top node's level is reached.  At each level, we query
 |   for all the uncosted parent nodes that exist at that level, so that we
 |   can then call Rollup_Parent_Node() on each of these uncosted parent nodes.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

PROCEDURE Rollup_Top_Node (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
  ,p_find_children_stmt           in long
  ,p_rollup_parent_stmt           in long
  ,p_find_child_chains_stmt       in long
  ,p_input_ds_b_where_clause      in long
  ,p_top_node_id                  in number
)
IS

  l_api_name             constant varchar2(30) := 'Rollup_Top_Node';

  l_dimension_rec                 dimension_record;

  l_costed_flag                   varchar2(1);

  l_parent_depth_num              number;
  l_min_parent_depth_num          number;
  l_max_parent_depth_num          number;

  l_parent_id_tbl                 number_table;

  l_flatten_rollup_table_stmt     long;
  l_min_parent_node_depth_stmt    long;
  l_max_parent_node_depth_stmt    long;

  l_find_parent_nodes_csr         dynamic_cursor;
  l_find_parent_nodes_stmt        long;
  l_find_parent_nodes_last_row    number;

  l_find_child_nodes_stmt         long;

  l_source_table_query_stmt       long;
  l_source_table_query_param1     number;
  l_source_table_query_param2     number;

  l_return_status                 t_return_status%TYPE;
  l_msg_count                     t_msg_count%TYPE;
  l_msg_data                      t_msg_data%TYPE;

  l_rollup_top_node_error         exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  l_dimension_rec := p_request_rec.dimension_rec;

  ------------------------------------------------------------------------------
  -- STEP 1: Check to see if the top has been costed
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 1: Check if Top Node has been costed'
  );

  select costed_flag
  into l_costed_flag
  from fem_ru_nodes_t
  where created_by_request_id = p_request_rec.request_id
  and created_by_object_id = p_rule_rec.rollup_obj_id
  and node_id = p_top_node_id;

  if (l_costed_flag = 'Y') then
    return;
  end if;

  if (l_dimension_rec.dimension_varchar_label = 'COST_OBJECT') then

    ----------------------------------------------------------------------------
    -- STEP 1.a: Flatten the Cost Object hierarchy into the
    -- FEM_RU_COST_OBJ_HIER_T table.
    ----------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Step 1.a: Flatten Cost Object Hierarchy'
    );

    begin

      -- Flatten Cost Object hierarchy.  Can't use MP as this is a connect by
      -- query.
      insert into fem_ru_cost_obj_hier_t (
        created_by_request_id
        ,created_by_object_id
        ,relationship_id
        ,parent_id
        ,parent_depth_num
        ,child_id
        ,child_sequence_num
        ,child_depth_num
        ,child_ledger_id
      )
      select ru.created_by_request_id
      ,ru.created_by_object_id
      ,ru.relationship_id
      ,ru.parent_id
      ,ru.parent_depth_num
      ,ru.child_id
      ,ru.child_sequence_num
      ,ru.child_depth_num
      ,decode(child.ledger_id,p_request_rec.ledger_id,null,child.ledger_id)
      from (
        select created_by_request_id
        ,created_by_object_id
        ,relationship_id
        ,parent_id
        ,level as parent_depth_num
        ,child_id
        ,child_sequence_num
        ,(level + 1) as child_depth_num
        from (
          select nvl(n.created_by_request_id,p_request_rec.request_id) as created_by_request_id
          ,nvl(n.created_by_object_id,p_rule_rec.rollup_obj_id) as created_by_object_id
          ,h.relationship_id
          ,h.parent_id
          ,h.child_id
          ,h.child_sequence_num
          ,nvl(n.costed_flag,'N') as costed_flag
          from fem_cost_objects_hier h
          ,fem_cost_objects parent
          ,fem_ru_nodes_t n
          where h.hierarchy_obj_id = p_rule_rec.hier_obj_id
          and p_request_rec.effective_date between h.effective_start_date and h.effective_end_date
          and parent.cost_object_id = h.parent_id
          and parent.ledger_id = p_request_rec.ledger_id
          and n.created_by_request_id (+) = p_request_rec.request_id
          and n.created_by_object_id (+) = p_rule_rec.rollup_obj_id
          and n.node_id (+) = h.parent_id
        )
        start with parent_id = p_top_node_id
        connect by prior child_id = parent_id
        and prior costed_flag = 'N'
      ) ru
      ,fem_cost_objects child
      where child.cost_object_id = ru.child_id;

    exception
      when g_connect_by_loop_error then
        FEM_ENGINES_PKG.User_Message (
          p_app_name  => G_FEM
          ,p_msg_name => G_RU_HIER_CIRC_REF_ERR
        );
        raise l_rollup_top_node_error;
    end;

    commit;

  elsif ( (l_dimension_rec.dimension_varchar_label = 'ACTIVITY')
      and (p_rule_rec.cond_exists) ) then

    ----------------------------------------------------------------------------
    -- STEP 1.b: Flatten the Activity hierarchy into the FEM_RU_ACTIVITIES_HIER_T
    -- table if condition exists.
    ----------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Step 1.b: Flatten Activity Hierarchy'
    );

    begin

      -- Flatten Activity hierarchy.  Can't use MP as this is a connect by
      -- query.
      insert into fem_ru_activities_hier_t (
        created_by_request_id
        ,created_by_object_id
        ,hierarchy_obj_def_id
        ,parent_id
        ,parent_depth_num
        ,child_id
        ,child_depth_num
        ,single_depth_flag
        ,weighting_pct
      )
      select created_by_request_id
      ,created_by_object_id
      ,hierarchy_obj_def_id
      ,parent_id
      ,level
      ,child_id
      ,level + 1
      ,single_depth_flag
      ,weighting_pct
      from (
        select nvl(n.created_by_request_id,p_request_rec.request_id) as created_by_request_id
        ,nvl(n.created_by_object_id,p_rule_rec.rollup_obj_id) as created_by_object_id
        ,h.hierarchy_obj_def_id
        ,h.parent_id
        ,h.child_id
        ,h.single_depth_flag
        ,h.weighting_pct
        ,nvl(n.costed_flag,'N') as costed_flag
        from fem_activities_hier h
        ,fem_ru_nodes_t n
        where h.hierarchy_obj_def_id = p_rule_rec.hier_obj_def_id
        and h.child_id <> h.parent_id
        and h.single_depth_flag = 'Y'
        and n.created_by_request_id (+) = p_request_rec.request_id
        and n.created_by_object_id (+) = p_rule_rec.rollup_obj_id
        and n.node_id (+) = h.parent_id
      )
      start with parent_id = p_top_node_id
      connect by prior child_id = parent_id
      and prior costed_flag = 'N';

    exception
      when g_connect_by_loop_error then
        FEM_ENGINES_PKG.User_Message (
          p_app_name  => G_FEM
          ,p_msg_name => G_RU_HIER_CIRC_REF_ERR
        );
        raise l_rollup_top_node_error;
    end;

    commit;

  end if;

  ------------------------------------------------------------------------------
  -- STEP 2: Find Child Nodes not in FEM_RU_NODES_T table
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 2: Find Child Nodes'
  );

  -- Build SQL statement for finding and inserting Child Nodes into
  -- FEM_RU_NODES_T
  l_find_child_nodes_stmt :=
  ' insert into fem_ru_nodes_t ('||
  '   created_by_request_id'||
  '   ,created_by_object_id'||
  '   ,node_id'||
  '   ,costed_flag'||
  '   ,root_flag'||
  '   ,condition_flag'||
  ' )';

  if (l_dimension_rec.dimension_varchar_label = 'COST_OBJECT') then

    l_find_child_nodes_stmt := l_find_child_nodes_stmt ||
    ' select distinct h.created_by_request_id'||
    ' ,h.created_by_object_id'||
    ' ,h.child_id'||
    ' ,''N'''||
    ' ,''N'''||
    ' ,''N'''||
    ' from '||p_rule_rec.hier_rollup_table||' h'||
    ' where h.created_by_request_id = :b_request_id'||
    ' and h.created_by_object_id = :b_rollup_obj_id'||
    ' and not exists ('||
    '   select 1'||
    '   from fem_ru_nodes_t n'||
    '   where n.created_by_request_id = h.created_by_request_id'||
    '   and n.created_by_object_id = h.created_by_object_id'||
    '   and n.node_id = h.child_id'||
    ' )';

    --todo:  MP integration  (???)
    -- Execute SQL for finding all Child Nodes for the specified hierarchy
    execute immediate l_find_child_nodes_stmt
    using p_request_rec.request_id
    ,p_rule_rec.rollup_obj_id;

  elsif (l_dimension_rec.dimension_varchar_label = 'ACTIVITY') then

    -- If condition exists, we must include request_id and rollup_obj_id in the
    -- where clause for querying FEM_RU_ACTIVITIES_HIER_T
    if (p_rule_rec.cond_exists) then

      l_find_child_nodes_stmt := l_find_child_nodes_stmt ||
      ' select h.created_by_request_id'||
      ' ,h.created_by_object_id'||
      ' ,h.child_id'||
      ' ,''N'''||
      ' ,''N'''||
      ' ,''N'''||
      ' from '||p_rule_rec.hier_rollup_table||' h'||
      ' where h.created_by_request_id = :b_request_id'||
      ' and h.created_by_object_id = :b_rollup_obj_id'||
      ' and h.hierarchy_obj_def_id = :b_hier_obj_def_id'||
      ' and h.child_id <> h.parent_id'||
      ' and h.single_depth_flag = ''Y'''||
      ' and not exists ('||
      '   select 1'||
      '   from fem_ru_nodes_t n'||
      '   where n.created_by_request_id = h.created_by_request_id'||
      '   and n.created_by_object_id = h.created_by_object_id'||
      '   and n.node_id = h.child_id'||
      ' )';

      --todo:  MP integration  (???)
      -- Execute SQL for finding all Child Nodes for the specified
      -- hierarchy object definition
      execute immediate l_find_child_nodes_stmt
      using p_request_rec.request_id
      ,p_rule_rec.rollup_obj_id
      ,p_rule_rec.hier_obj_def_id;

    else

      l_find_child_nodes_stmt := l_find_child_nodes_stmt ||
      ' select :b_request_id'||
      ' ,:b_rollup_obj_id'||
      ' ,h.child_id'||
      ' ,''N'''||
      ' ,''N'''||
      ' ,''N'''||
      ' from '||p_rule_rec.hier_rollup_table||' h'||
      ' where h.hierarchy_obj_def_id = :b_hier_obj_def_id'||
      ' and h.child_id <> h.parent_id'||
      ' and h.single_depth_flag = ''Y'''||
      ' and not exists ('||
      '   select 1'||
      '   from fem_ru_nodes_t n'||
      '   where n.created_by_request_id = :b_request_id'||
      '   and n.created_by_object_id = :b_rollup_obj_id'||
      '   and n.node_id = h.child_id'||
      ' )';

      --todo:  MP integration  (???)
      -- Execute SQL for finding all Child Nodes for the specified
      -- hierarchy object definition
      execute immediate l_find_child_nodes_stmt
      using p_request_rec.request_id
      ,p_rule_rec.rollup_obj_id
      ,p_rule_rec.hier_obj_def_id
      ,p_request_rec.request_id
      ,p_rule_rec.rollup_obj_id;

    end if;

  else

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_RU_NO_ROLLUP_DIM_ERR
      ,p_token1   => 'DIMENSION_VARCHAR_LABEL'
      ,p_value1   => l_dimension_rec.dimension_varchar_label
    );
    raise l_rollup_top_node_error;

  end if;

  commit;

  ------------------------------------------------------------------------------
  -- STEP 3: Pre-Populate COST_OBJECT_ID or ACTIVITY_ID on FEM_BALANCES
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 3: Pre-Populate COST_OBJECT_ID or ACTIVITY_ID on FEM_BALANCES'
  );

  if (l_dimension_rec.dimension_varchar_label = 'COST_OBJECT') then

    -- The source table query comes from the list of uncosted nodes in
    -- FEM_RU_NODES_T.  A join to FEM_COST_OBJECTS is necessary for
    -- Populate_Cost_Object_Id to work properly as it needs all the
    -- component dimension columns for the join on FEM_BALANCES.
    l_source_table_query_stmt :=
    ' select co.cost_object_id'||
    ' from fem_cost_objects co'||
    ' ,fem_ru_nodes_t n'||
    ' where n.created_by_request_id = :b_request_id'||
    ' and n.created_by_object_id = :b_rollup_obj_id'||
    ' and n.costed_flag = ''N'''||
    ' and n.node_id = co.cost_object_id';

    l_source_table_query_param1 := p_request_rec.request_id;
    l_source_table_query_param2 := p_rule_rec.rollup_obj_id;

    --todo:  MP integration  (???)
    FEM_COMPOSITE_DIM_UTILS_PVT.Populate_Cost_Object_Id (
      p_api_version                   => 1.0
      ,p_init_msg_list                => FND_API.G_FALSE
      ,p_commit                       => FND_API.G_TRUE
      ,x_return_status                => l_return_status
      ,x_msg_count                    => l_msg_count
      ,x_msg_data                     => l_msg_data
      ,p_object_type_code             => p_rule_rec.rollup_obj_type_code
      ,p_source_table_query           => l_source_table_query_stmt
      ,p_source_table_query_param1    => l_source_table_query_param1
      ,p_source_table_query_param2    => l_source_table_query_param2
      ,p_source_table_alias           => 'co'
      ,p_target_table_name            => 'FEM_BALANCES'
      ,p_target_table_alias           => 'b'
      ,p_target_dsg_where_clause      => p_input_ds_b_where_clause
    );

  elsif (l_dimension_rec.dimension_varchar_label = 'ACTIVITY') then

    if (p_rule_rec.cond_exists) then

      -- If a condition exists, the source table query comes from the list of
      -- uncosted nodes in FEM_RU_NODES_T.  A join to FEM_ACTIVITIES is
      -- necessary for Populate_Activity_Id to work properly as it needs all the
      -- component dimension columns for the join on FEM_BALANCES.
      l_source_table_query_stmt :=
      ' select act.activity_id'||
      ' from fem_activities act'||
      ' ,fem_ru_nodes_t n'||
      ' where n.created_by_request_id = :b_request_id'||
      ' and n.created_by_object_id = :b_rollup_obj_id'||
      ' and n.costed_flag = ''N'''||
      ' and n.node_id = act.activity_id';

      l_source_table_query_param1 := p_request_rec.request_id;
      l_source_table_query_param2 := p_rule_rec.rollup_obj_id;

    else

      -- If no condition exists, the source table query comes from all the
      -- nodes that exist in the Activity hierarchy, including the root node.
      -- A join to FEM_ACTIVITIES is necessary for Populate_Activity_Id to work
      -- properly as it needs all the component dimension columns for the join
      -- on FEM_BALANCES.
      l_source_table_query_stmt :=
      ' select act.activity_id'||
      ' from fem_activities act'||
      ' ,'||p_rule_rec.hier_rollup_table||' h'||
      ' where h.hierarchy_obj_def_id = :b_hier_obj_def_id'||
      ' and h.child_id = act.activity_id'||
      ' and h.single_depth_flag = ''Y''';

      l_source_table_query_param1 := p_rule_rec.hier_obj_def_id;
      l_source_table_query_param2 := null;

    end if;

    --todo:  MP integration  (???)
    FEM_COMPOSITE_DIM_UTILS_PVT.Populate_Activity_Id (
      p_api_version                   => 1.0
      ,p_init_msg_list                => FND_API.G_FALSE
      ,p_commit                       => FND_API.G_TRUE
      ,x_return_status                => l_return_status
      ,x_msg_count                    => l_msg_count
      ,x_msg_data                     => l_msg_data
      ,p_object_type_code             => p_rule_rec.rollup_obj_type_code
      ,p_source_table_query           => l_source_table_query_stmt
      ,p_source_table_query_param1    => l_source_table_query_param1
      ,p_source_table_query_param2    => l_source_table_query_param2
      ,p_source_table_alias           => 'act'
      ,p_target_table_name            => 'FEM_BALANCES'
      ,p_target_table_alias           => 'b'
      ,p_target_dsg_where_clause      => p_input_ds_b_where_clause
      ,p_ledger_id                    => p_request_rec.ledger_id
      ,p_statistic_basis_id           => p_rule_rec.statistic_basis_id
    );

  end if;

  -- Check the return status after calling FEM_COMPOSITE_DIM_UTILS_PVT API's
  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
    Get_Put_Messages (
      p_msg_count => l_msg_count
      ,p_msg_data => l_msg_data
    );
    raise l_rollup_top_node_error;
  end if;

  ------------------------------------------------------------------------------
  -- STEP 4: Get the Minimum and Maximum Parent Node Depths for the Top Node
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 4: Get the Minimum and Maximum Parent Node Depths for the Top Node'
  );

  if (l_dimension_rec.dimension_varchar_label = 'COST_OBJECT') then

    select min(h.parent_depth_num)
    into l_min_parent_depth_num
    from fem_ru_cost_obj_hier_t h
    where h.created_by_request_id = p_request_rec.request_id
    and h.created_by_object_id = p_rule_rec.rollup_obj_id
    and h.parent_id = p_top_node_id;

    select max(h.parent_depth_num)
    into l_max_parent_depth_num
    from fem_ru_cost_obj_hier_t h
    where h.created_by_request_id = p_request_rec.request_id
    and h.created_by_object_id = p_rule_rec.rollup_obj_id;

  elsif (l_dimension_rec.dimension_varchar_label = 'ACTIVITY') then

    -- If condition exists, we must include request_id and rollup_obj_id in the
    -- where clause for querying FEM_RU_ACTIVITIES_HIER_T
    if (p_rule_rec.cond_exists) then

      select min(h.parent_depth_num)
      into l_min_parent_depth_num
      from fem_ru_activities_hier_t h
      where h.created_by_request_id = p_request_rec.request_id
      and h.created_by_object_id = p_rule_rec.rollup_obj_id
      and h.hierarchy_obj_def_id = p_rule_rec.hier_obj_def_id
      and h.child_id <> h.parent_id
      and h.single_depth_flag = 'Y'
      and h.parent_id = p_top_node_id;

      select max(h.parent_depth_num)
      into l_max_parent_depth_num
      from fem_ru_activities_hier_t h
      where h.created_by_request_id = p_request_rec.request_id
      and h.created_by_object_id = p_rule_rec.rollup_obj_id
      and h.hierarchy_obj_def_id = p_rule_rec.hier_obj_def_id
      and h.child_id <> h.parent_id
      and h.single_depth_flag = 'Y';

    else

      select min(h.parent_depth_num)
      into l_min_parent_depth_num
      from fem_activities_hier h
      where h.hierarchy_obj_def_id = p_rule_rec.hier_obj_def_id
      and h.child_id <> h.parent_id
      and h.single_depth_flag = 'Y'
      and h.parent_id = p_top_node_id;

      select max(h.parent_depth_num)
      into l_max_parent_depth_num
      from fem_activities_hier h
      where h.hierarchy_obj_def_id = p_rule_rec.hier_obj_def_id
      and h.child_id <> h.parent_id
      and h.single_depth_flag = 'Y';

    end if;

  else

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_RU_NO_ROLLUP_DIM_ERR
      ,p_token1   => 'DIMENSION_VARCHAR_LABEL'
      ,p_value1   => l_dimension_rec.dimension_varchar_label
    );
    raise l_rollup_top_node_error;

  end if;

  ------------------------------------------------------------------------------
  -- STEP 5: Build Parent Node Query at specified Parent Depth Number
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 5: Build Parent Node Query at specified Parent Depth Number'
  );

  -- Build SQL statement for retrieving all parent nodes of a hierarchy at the
  -- specified parent depth number that have not been costed
  l_find_parent_nodes_stmt :=
  ' select n.node_id'||
  ' from fem_ru_nodes_t n'||
  ' where n.created_by_request_id = :b_request_id'||
  ' and n.created_by_object_id = :b_rollup_obj_id'||
  ' and n.costed_flag = ''N''';
--  ' and {{data_slice}}'||

  if (l_dimension_rec.dimension_varchar_label = 'COST_OBJECT') then

    l_find_parent_nodes_stmt := l_find_parent_nodes_stmt ||
    ' and exists ('||
    '   select 1'||
    '   from '||p_rule_rec.hier_rollup_table||' h'||
    '   where h.created_by_request_id = n.created_by_request_id'||
    '   and h.created_by_object_id = n.created_by_object_id'||
    '   and h.parent_id = n.node_id'||
    '   and h.parent_depth_num = :b_parent_depth_num'||
    ' )';

  elsif (l_dimension_rec.dimension_varchar_label = 'ACTIVITY') then

    -- If condition exists, we must include request_id and rollup_obj_id in the
    -- where clause for querying FEM_RU_ACTIVITIES_HIER_T
    if (p_rule_rec.cond_exists) then

      l_find_parent_nodes_stmt := l_find_parent_nodes_stmt ||
      ' and exists ('||
      '   select 1'||
      '   from '||p_rule_rec.hier_rollup_table||' h'||
      '   where h.created_by_request_id = n.created_by_request_id'||
      '   and h.created_by_object_id = n.created_by_object_id'||
      '   and h.hierarchy_obj_def_id = :b_hier_obj_def_id'||
      '   and h.single_depth_flag = ''Y'''||
      '   and h.parent_id = n.node_id'||
      '   and h.parent_depth_num = :b_parent_depth_num'||
      ' )';

    else

      l_find_parent_nodes_stmt := l_find_parent_nodes_stmt ||
      ' and exists ('||
      '   select 1'||
      '   from '||p_rule_rec.hier_rollup_table||' h'||
      '   where h.hierarchy_obj_def_id = :b_hier_obj_def_id'||
      '   and h.single_depth_flag = ''Y'''||
      '   and h.parent_id = n.node_id'||
      '   and h.parent_depth_num = :b_parent_depth_num'||
      ' )';

    end if;

  else

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_RU_NO_ROLLUP_DIM_ERR
      ,p_token1   => 'DIMENSION_VARCHAR_LABEL'
      ,p_value1   => l_dimension_rec.dimension_varchar_label
    );
    raise l_rollup_top_node_error;

  end if;

  ------------------------------------------------------------------------------
  -- STEP 6: Loop through all Parent Depth Levels
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 6: Loop through all Parent Depth Levels'
  );

  l_parent_depth_num := l_max_parent_depth_num;

  while (l_parent_depth_num >= l_min_parent_depth_num) loop

    --todo:  MP integration
    -- Execute SQL for retrieving all parent nodes of a hierarchy at the
    -- specified parent depth number that have not been costed
    if (l_dimension_rec.dimension_varchar_label = 'COST_OBJECT') then

      open l_find_parent_nodes_csr
      for l_find_parent_nodes_stmt
      using p_request_rec.request_id
      ,p_rule_rec.rollup_obj_id
      ,l_parent_depth_num;

    elsif (l_dimension_rec.dimension_varchar_label = 'ACTIVITY') then

      open l_find_parent_nodes_csr
      for l_find_parent_nodes_stmt
      using p_request_rec.request_id
      ,p_rule_rec.rollup_obj_id
      ,p_rule_rec.hier_obj_def_id
      ,l_parent_depth_num;

    end if;

    loop

      fetch l_find_parent_nodes_csr
      bulk collect into
      l_parent_id_tbl
      limit g_fetch_limit;

      l_find_parent_nodes_last_row := l_parent_id_tbl.LAST;
      if (l_find_parent_nodes_last_row is null) then
        exit;
      end if;

      for i in 1..l_find_parent_nodes_last_row loop

        --todo:  MP integration
        Rollup_Parent_Node (
          p_request_id                => p_request_rec.request_id
          ,p_rollup_obj_id            => p_rule_rec.rollup_obj_id
          ,p_hier_obj_def_id          => p_rule_rec.hier_obj_def_id
          ,p_dimension_varchar_label  => l_dimension_rec.dimension_varchar_label
          ,p_rollup_type_code         => p_request_rec.rollup_type_code
          ,p_cond_exists              => p_rule_rec.cond_exists
          ,p_sequence_name            => p_rule_rec.sequence_name
          ,p_source_system_code       => p_request_rec.source_system_code
          ,p_ledger_id                => p_request_rec.ledger_id
          ,p_parent_id                => l_parent_id_tbl(i)
          ,p_parent_depth_num         => l_parent_depth_num
          ,p_statistic_basis_id       => p_rule_rec.statistic_basis_id
          ,p_find_children_stmt       => p_find_children_stmt
          ,p_rollup_parent_stmt       => p_rollup_parent_stmt
          ,p_find_child_chains_stmt   => p_find_child_chains_stmt
          ,p_output_dataset_code      => p_request_rec.output_dataset_code
          ,p_output_cal_period_id     => p_request_rec.output_cal_period_id
          ,p_exch_rate_date           => p_request_rec.exch_rate_date
          ,p_functional_currency_code => p_request_rec.functional_currency_code
          ,p_entered_currency_code    => p_rule_rec.entered_currency_code
          ,p_entered_exch_rate_num    => p_rule_rec.entered_exch_rate_num
          ,p_entered_exch_rate_den    => p_rule_rec.entered_exch_rate_den
          ,p_user_id                  => p_request_rec.user_id
          ,p_login_id                 => p_request_rec.login_id
        );

      end loop;

      l_parent_id_tbl.DELETE;

    end loop;

    close l_find_parent_nodes_csr;

    -- Go to the next parent depth number
    l_parent_depth_num := l_parent_depth_num - 1;

  end loop;

  if (l_dimension_rec.dimension_varchar_label = 'COST_OBJECT') then

    ----------------------------------------------------------------------------
    -- STEP 7.a: Purge all records in FEM_RU_COST_OBJ_HIER_T
    ----------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Step 7.a: Purge all records in FEM_RU_COST_OBJ_HIER_T'
    );

    delete from fem_ru_cost_obj_hier_t
    where created_by_request_id = p_request_rec.request_id
    and created_by_object_id = p_rule_rec.rollup_obj_id;

    commit;

  elsif ( (l_dimension_rec.dimension_varchar_label = 'ACTIVITY')
      and (p_rule_rec.cond_exists) ) then

    ----------------------------------------------------------------------------
    -- STEP 7.b: Purge all records in FEM_RU_ACTIVITIES_HIER_T
    ----------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Step 7.b: Purge all records in FEM_RU_ACTIVITIES_HIER_T'
    );

    delete from fem_ru_activities_hier_t
    where created_by_request_id = p_request_rec.request_id
    and created_by_object_id = p_rule_rec.rollup_obj_id;

    commit;

  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_rollup_top_node_error then

    if (l_find_parent_nodes_csr%ISOPEN) then
     close l_find_parent_nodes_csr;
    end if;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Rollup Top Node Exception'
    );

    raise g_rollup_request_error;

  when g_rollup_request_error then

    if (l_find_parent_nodes_csr%ISOPEN) then
     close l_find_parent_nodes_csr;
    end if;

    raise g_rollup_request_error;

  when others then

    g_prg_msg := SQLERRM;
    g_callstack := DBMS_UTILITY.Format_Call_Stack;

    if (l_find_parent_nodes_csr%ISOPEN) then
     close l_find_parent_nodes_csr;
    end if;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name||'.Unexpected_Exception'
      ,p_msg_text => g_prg_msg
    );

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name||'.Unexpected_Exception'
      ,p_msg_text => g_callstack
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_UNEXPECTED_ERROR
      ,p_token1   => 'ERR_MSG'
      ,p_value1   => g_prg_msg
    );

    raise g_rollup_request_error;

END Rollup_Top_Node;



/*============================================================================+
 | PROCEDURE
 |   Rollup_Parent_Node
 |
 | DESCRIPTION
 |   Peforms single-level rollup on the specified parent node and parent depth
 |   of a rollup hierarchy.
 |
 |   Rollup processing is done by querying for all the child nodes that exist
 |   for a the specified parent node and parent depth.  For each child node,
 |   we rollup all the data records in FEM_BALANCES to the parent node.
 |
 |   If the track events flag is set, then we must register the chain
 |   dependency of all the child node data records in FEM_BALANCES with respect
 |   to the rollup parent node data records in FEM_BALANCES.
 |
 |   For cost object hierarchies, special processing is necessary to handle
 |   cross ledger child nodes.  A cross ledger may have a functional currency
 |   code that differs from the request's ledger currency code.  If that's the
 |   case, the appropriate exchange rate must be used for rolling up all the
 |   child node's data records in FEM_BALANCES to the parent node.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

PROCEDURE Rollup_Parent_Node (
  p_request_id                    in number
  ,p_rollup_obj_id                in number
  ,p_hier_obj_def_id              in number
  ,p_dimension_varchar_label      in varchar2
  ,p_rollup_type_code             in varchar2
  ,p_cond_exists                  in boolean
  ,p_sequence_name                in varchar2
  ,p_source_system_code           in number
  ,p_ledger_id                    in number
  ,p_parent_id                    in number
  ,p_parent_depth_num             in number
  ,p_statistic_basis_id           in number
  ,p_find_children_stmt           in long
  ,p_rollup_parent_stmt           in long
  ,p_find_child_chains_stmt       in long
  ,p_output_dataset_code          in number
  ,p_output_cal_period_id         in number
  ,p_exch_rate_date               in date
  ,p_functional_currency_code     in varchar2
  ,p_entered_currency_code        in varchar2
  ,p_entered_exch_rate_num        in number
  ,p_entered_exch_rate_den        in number
  ,p_user_id                      in number
  ,p_login_id                     in number
)
IS

  l_api_name             constant varchar2(30) := 'Rollup_Parent_Node';

  l_costed_flag                   varchar2(1);
  l_xledger_id                    number;
  l_child_exch_rate_den           number;
  l_child_exch_rate_num           number;
  l_dummy_date                    date;

  l_child_id_tbl                  number_table;
  l_weighting_pct_tbl             number_table;
  l_xledger_id_tbl                number_table;

  l_find_children_csr             dynamic_cursor;
  l_find_children_last_row        number;

  l_rollup_parent_node_error      exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (p_dimension_varchar_label = 'COST_OBJECT') then

    ----------------------------------------------------------------------------
    -- STEP 1: Check to see if the parent has been costed in a Cost Object
    -- hierarchy
    ----------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Step 1: Check if Parent Cost Object has been costed'
    );

    select costed_flag
    into l_costed_flag
    from fem_ru_nodes_t
    where created_by_request_id = p_request_id
    and created_by_object_id = p_rollup_obj_id
    and node_id = p_parent_id;

    if (l_costed_flag = 'Y') then
      return;
    end if;

  end if;

  ------------------------------------------------------------------------------
  -- STEP 2: Find All Parent-Child Relationships for a hierarchy at the
  -- specified parent node id and parent depth num
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 2: Find All Parent-Child Relationships'
  );

  -- Build SQL statement for finding all Parent-Child Relationships
  if (p_dimension_varchar_label = 'COST_OBJECT') then

    open l_find_children_csr
    for p_find_children_stmt
    using p_request_id
    ,p_rollup_obj_id
    ,p_parent_id
    ,p_parent_depth_num;

  elsif (p_dimension_varchar_label = 'ACTIVITY') then

    -- If condition exists, we must include request_id and rollup_obj_id in
    -- the where clause for querying FEM_RU_ACTIVITIES_HIER_T
    if (p_cond_exists) then

      open l_find_children_csr
      for p_find_children_stmt
      using p_hier_obj_def_id
      ,p_parent_id
      ,p_parent_depth_num
      ,p_request_id
      ,p_rollup_obj_id;

    else

      open l_find_children_csr
      for p_find_children_stmt
      using p_hier_obj_def_id
      ,p_parent_id
      ,p_parent_depth_num;

    end if;

  else

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_RU_NO_ROLLUP_DIM_ERR
      ,p_token1   => 'DIMENSION_VARCHAR_LABEL'
      ,p_value1   => p_dimension_varchar_label
    );
    raise l_rollup_parent_node_error;

  end if;

  loop

    fetch l_find_children_csr
    bulk collect into
    l_child_id_tbl
    ,l_weighting_pct_tbl
    ,l_xledger_id_tbl
    limit g_fetch_limit;

    l_find_children_last_row := l_child_id_tbl.LAST;
    if (l_find_children_last_row is null) then
      exit;
    end if;

    for i in 1..l_find_children_last_row loop

      if (p_dimension_varchar_label = 'COST_OBJECT') then

        if (l_xledger_id_tbl(i) is not null) then

          ----------------------------------------------------------------------
          -- STEP 3: Child Cross Ledger Processing
          ----------------------------------------------------------------------
          FEM_ENGINES_PKG.Tech_Message (
            p_severity  => G_LOG_LEVEL_1
            ,p_module   => G_BLOCK||'.'||l_api_name
            ,p_msg_text => 'Step 3: Child Cross Ledger Processing'
          );

          -- Set the cross ledger
          l_xledger_id := l_xledger_id_tbl(i);

          -- If the cross ledger id does not exist in the cross ledger table,
          -- then get the cross ledger's currency code.
          if ( not g_xledger_tbl.EXISTS(l_xledger_id) ) then

            Get_Ledger_Currency_Code (
              p_ledger_id      => l_xledger_id
              ,x_currency_code => g_xledger_tbl(l_xledger_id).currency_code
            );

            -- If the cross ledger's currency code is the same as the request's
            -- functional currency code , then set all the exchange rate
            -- variables to 1.  If they differ, then call the GL Currency API
            -- to obtain the appropriate values for the exchange rate variables.
            if (g_xledger_tbl(l_xledger_id).currency_code = p_functional_currency_code) then

              -- Default the exchange rate to 1 as the cross ledger currency
              -- is the same as the request's ledger functional currency
              g_xledger_tbl(l_xledger_id).exch_rate_den := 1;
              g_xledger_tbl(l_xledger_id).exch_rate_num := 1;
              g_xledger_tbl(l_xledger_id).exch_rate := 1;

            else

              begin
                GL_CURRENCY_API.Get_Triangulation_Rate (
                  x_from_currency    => g_xledger_tbl(l_xledger_id).currency_code
                  ,x_to_currency     => p_functional_currency_code
                  ,x_conversion_date => p_exch_rate_date
                  ,x_conversion_type => g_currency_conv_type
                  ,x_numerator       => g_xledger_tbl(l_xledger_id).exch_rate_num
                  ,x_denominator     => g_xledger_tbl(l_xledger_id).exch_rate_den
                  ,x_rate            => g_xledger_tbl(l_xledger_id).exch_rate
                );
              exception
                when GL_CURRENCY_API.NO_RATE then
                  FEM_ENGINES_PKG.User_Message (
                    p_app_name  => G_FEM
                    ,p_msg_name => G_ENG_NO_EXCH_RATE_ERR
                    ,p_token1   => 'FROM_CURRENCY_CODE'
                    ,p_value1   => g_xledger_tbl(l_xledger_id).currency_code
                    ,p_token2   => 'TO_CURRENCY_CODE'
                    ,p_value2   => p_functional_currency_code
                    ,p_token3   => 'CONVERSION_DATE'
                    ,p_value3   => FND_DATE.date_to_chardate(p_exch_rate_date)
                    ,p_token4   => 'CONVERSION_TYPE'
                    ,p_value4   => g_currency_conv_type
                  );
                  raise l_rollup_parent_node_error;
                when GL_CURRENCY_API.INVALID_CURRENCY then
                  FEM_ENGINES_PKG.User_Message (
                    p_app_name  => G_FEM
                    ,p_msg_name => G_ENG_BAD_CURRENCY_ERR
                    ,p_token1   => 'FROM_CURRENCY_CODE'
                    ,p_value1   => g_xledger_tbl(l_xledger_id).currency_code
                    ,p_token2   => 'TO_CURRENCY_CODE'
                    ,p_value2   => p_functional_currency_code
                    ,p_token3   => 'CONVERSION_DATE'
                    ,p_value3   => FND_DATE.date_to_chardate(p_exch_rate_date)
                    ,p_token4   => 'CONVERSION_TYPE'
                    ,p_value4   => g_currency_conv_type
                  );
                  raise l_rollup_parent_node_error;
              end;

            end if;

          end if;

          -- Set the local exchange rate variables from the cross ledger table
          -- for rolling up a child to its parent.
          l_child_exch_rate_den := g_xledger_tbl(l_xledger_id).exch_rate_den;
          l_child_exch_rate_num := g_xledger_tbl(l_xledger_id).exch_rate_num;

        else

          -- Set all the local exchange rate variables to 1 for rolling up a
          -- child to its parent.
          l_child_exch_rate_den := 1;
          l_child_exch_rate_num := 1;

        end if;

      end if;

      if (g_track_event_chains) then

        ------------------------------------------------------------------------
        -- STEP 4: Register Child Chains
        ------------------------------------------------------------------------
        FEM_ENGINES_PKG.Tech_Message (
          p_severity  => G_LOG_LEVEL_1
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 4: Register Child Chains'
        );

        Register_Child_Chains (
          p_request_id               => p_request_id
          ,p_rollup_obj_id           => p_rollup_obj_id
          ,p_dimension_varchar_label => p_dimension_varchar_label
          ,p_rollup_type_code        => p_rollup_type_code
          ,p_ledger_id               => p_ledger_id
          ,p_statistic_basis_id      => p_statistic_basis_id
          ,p_find_child_chains_stmt  => p_find_child_chains_stmt
          ,p_child_id                => l_child_id_tbl(i)
          ,p_user_id                 => p_user_id
          ,p_login_id                => p_login_id
        );

      end if;

      --------------------------------------------------------------------------
      -- STEP 5: Rollup to the specified parent all data records in FEM_BALANCES
      -- of the specified child
      --------------------------------------------------------------------------
      FEM_ENGINES_PKG.Tech_Message (
        p_severity  => G_LOG_LEVEL_1
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Step 5.'||to_char(i)||': Rollup Child ID = '||to_char(l_child_id_tbl(i))
      );

      if (p_dimension_varchar_label = 'COST_OBJECT') then

        execute immediate p_rollup_parent_stmt
        using p_source_system_code
        ,p_entered_currency_code
        ,l_child_id_tbl(i)
        ,p_parent_id
        ,p_output_dataset_code
        ,p_output_cal_period_id
        ,p_request_id
        ,p_rollup_obj_id
        ,l_weighting_pct_tbl(i)
        ,l_child_exch_rate_den
        ,l_child_exch_rate_num
        ,p_entered_exch_rate_den
        ,p_entered_exch_rate_num
        ,l_weighting_pct_tbl(i)
        ,l_child_exch_rate_den
        ,l_child_exch_rate_num
        ,p_request_id
        ,p_rollup_obj_id
        ,p_output_dataset_code
        ,p_output_cal_period_id
        ,p_request_id
        ,p_rollup_obj_id
        ,p_request_id
        ,p_rollup_obj_id
        ,l_weighting_pct_tbl(i)
        ,l_child_exch_rate_den
        ,l_child_exch_rate_num
        ,p_entered_exch_rate_den
        ,p_entered_exch_rate_num
        ,l_weighting_pct_tbl(i)
        ,l_child_exch_rate_den
        ,l_child_exch_rate_num;

      elsif (p_dimension_varchar_label = 'ACTIVITY') then

        if (p_rollup_type_code = 'COST') then

          execute immediate p_rollup_parent_stmt
          using p_source_system_code
          ,p_entered_currency_code
          ,l_child_id_tbl(i)
          ,p_parent_id
          ,p_ledger_id
          ,p_output_dataset_code
          ,p_output_cal_period_id
          ,p_request_id
          ,p_rollup_obj_id
          ,l_weighting_pct_tbl(i)
          ,p_entered_exch_rate_den
          ,p_entered_exch_rate_num
          ,l_weighting_pct_tbl(i)
          ,p_request_id
          ,p_rollup_obj_id
          ,p_output_dataset_code
          ,p_output_cal_period_id
          ,p_request_id
          ,p_rollup_obj_id
          ,p_request_id
          ,p_rollup_obj_id
          ,l_weighting_pct_tbl(i)
          ,p_entered_exch_rate_den
          ,p_entered_exch_rate_num
          ,l_weighting_pct_tbl(i);

        elsif (p_rollup_type_code = 'STAT') then

          execute immediate p_rollup_parent_stmt
          using p_source_system_code
          ,p_entered_currency_code
          ,l_child_id_tbl(i)
          ,p_parent_id
          ,p_ledger_id
          ,p_statistic_basis_id
          ,p_output_dataset_code
          ,p_output_cal_period_id
          ,p_request_id
          ,p_rollup_obj_id
          ,l_weighting_pct_tbl(i)
          ,p_entered_exch_rate_den
          ,p_entered_exch_rate_num
          ,l_weighting_pct_tbl(i)
          ,p_request_id
          ,p_rollup_obj_id
          ,p_output_dataset_code
          ,p_output_cal_period_id
          ,p_request_id
          ,p_rollup_obj_id
          ,p_request_id
          ,p_rollup_obj_id
          ,l_weighting_pct_tbl(i)
          ,p_entered_exch_rate_den
          ,p_entered_exch_rate_num
          ,l_weighting_pct_tbl(i);

        end if;

      end if;

      commit;

    end loop;

    ----------------------------------------------------------------------------
    -- STEP 6: Mark all the uncosted children that were processes as costed
    ----------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Step 6: Mark All Uncosted Children Just Processed as Costed'
    );

    forall i in 1..l_find_children_last_row
      update fem_ru_nodes_t
      set costed_flag = 'Y'
      where created_by_request_id = p_request_id
      and created_by_object_id = p_rollup_obj_id
      and node_id = l_child_id_tbl(i)
      and costed_flag = 'N';

    l_child_id_tbl.DELETE;
    l_weighting_pct_tbl.DELETE;
    l_xledger_id_tbl.DELETE;

  end loop;

  close l_find_children_csr;

  ------------------------------------------------------------------------------
  -- STEP 7: Mark the parent as costed
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 7: Mark the Parent as Costed'
  );

  update fem_ru_nodes_t
  set costed_flag = 'Y'
  where created_by_request_id = p_request_id
  and created_by_object_id = p_rollup_obj_id
  and node_id = p_parent_id;

  commit;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_rollup_parent_node_error then

    if (l_find_children_csr%ISOPEN) then
     close l_find_children_csr;
    end if;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Rollup Parent Node Exception'
    );

    raise g_rollup_request_error;

  when g_rollup_request_error then

    if (l_find_children_csr%ISOPEN) then
     close l_find_children_csr;
    end if;

    raise g_rollup_request_error;

  when others then

    g_prg_msg := SQLERRM;
    g_callstack := DBMS_UTILITY.Format_Call_Stack;

    if (l_find_children_csr%ISOPEN) then
     close l_find_children_csr;
    end if;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name||'.Unexpected_Exception'
      ,p_msg_text => g_prg_msg
    );

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name||'.Unexpected_Exception'
      ,p_msg_text => g_callstack
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_UNEXPECTED_ERROR
      ,p_token1   => 'ERR_MSG'
      ,p_value1   => g_prg_msg
    );

    raise g_rollup_request_error;

END Rollup_Parent_Node;



/*============================================================================+
 | PROCEDURE
 |   Register_Child_Chains
 |
 | DESCRIPTION
 |   Registers the child chains in the processing locks table.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/
PROCEDURE Register_Child_Chains (
  p_request_id                    in number
  ,p_rollup_obj_id                in number
  ,p_dimension_varchar_label      in varchar2
  ,p_rollup_type_code             in varchar2
  ,p_ledger_id                    in number
  ,p_statistic_basis_id           in number
  ,p_find_child_chains_stmt       in long
  ,p_child_id                     in number
  ,p_user_id                      in number
  ,p_login_id                     in number
)
IS

  l_api_name             constant varchar2(30) := 'Register_Child_Chains';

  l_created_by_request_id_tbl     number_table;
  l_created_by_object_id_tbl      number_table;

  l_find_child_chains_csr         dynamic_cursor;
  l_find_child_chains_last_row    number;

  l_return_status                 t_return_status%TYPE;
  l_msg_count                     t_msg_count%TYPE;
  l_msg_data                      t_msg_data%TYPE;

  l_register_child_chains_error   exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (p_dimension_varchar_label = 'COST_OBJECT') then

    open l_find_child_chains_csr
    for p_find_child_chains_stmt
    using p_child_id
    ,p_request_id
    ,p_rollup_obj_id
    ,p_request_id
    ,p_rollup_obj_id;

  elsif (p_dimension_varchar_label = 'ACTIVITY') then

    if (p_rollup_type_code = 'COST') then

      open l_find_child_chains_csr
      for p_find_child_chains_stmt
      using p_ledger_id
      ,p_child_id
      ,p_request_id
      ,p_rollup_obj_id
      ,p_request_id
      ,p_rollup_obj_id;

    elsif (p_rollup_type_code = 'STAT') then

      open l_find_child_chains_csr
      for p_find_child_chains_stmt
      using p_ledger_id
      ,p_statistic_basis_id
      ,p_child_id
      ,p_request_id
      ,p_rollup_obj_id
      ,p_request_id
      ,p_rollup_obj_id;

    end if;

  end if;

  loop

    fetch l_find_child_chains_csr
    bulk collect into
    l_created_by_request_id_tbl
    ,l_created_by_object_id_tbl
    limit g_fetch_limit;

    l_find_child_chains_last_row := l_created_by_request_id_tbl.LAST;
    if (l_find_child_chains_last_row is null) then
      exit;
    end if;

    for i in 1..l_find_child_chains_last_row loop

      -- Call the FEM_PL_PKG.Register_Chain API procedure to register
      -- the specified chain.
      FEM_PL_PKG.Register_Chain (
        p_api_version                   => 1.0
        ,p_commit                       => FND_API.G_FALSE
        ,p_request_id                   => p_request_id
        ,p_object_id                    => p_rollup_obj_id
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
        raise l_register_child_chains_error;
      end if;

    end loop;

    l_created_by_request_id_tbl.DELETE;
    l_created_by_object_id_tbl.DELETE;

    commit;

  end loop;

  close l_find_child_chains_csr;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_register_child_chains_error then

    if (l_find_child_chains_csr%ISOPEN) then
     close l_find_child_chains_csr;
    end if;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Register Child Chains Exception'
    );

    raise g_rollup_request_error;

  when g_rollup_request_error then

    if (l_find_child_chains_csr%ISOPEN) then
     close l_find_child_chains_csr;
    end if;

    raise g_rollup_request_error;

  when others then

    g_prg_msg := SQLERRM;
    g_callstack := DBMS_UTILITY.Format_Call_Stack;

    if (l_find_child_chains_csr%ISOPEN) then
     close l_find_child_chains_csr;
    end if;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name||'.Unexpected_Exception'
      ,p_msg_text => g_prg_msg
    );

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name||'.Unexpected_Exception'
      ,p_msg_text => g_callstack
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_UNEXPECTED_ERROR
      ,p_token1   => 'ERR_MSG'
      ,p_value1   => g_prg_msg
    );

    raise g_rollup_request_error;

END Register_Child_Chains;



/*============================================================================+
 | PROCEDURE
 |   Rule_Post_Proc
 |
 | DESCRIPTION
 |   Updates the status of the object execution in the
 |   processing locks tables.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

PROCEDURE Rule_Post_Proc (
  p_request_rec                   in request_record
  ,p_rule_rec                     in rule_record
  ,p_num_of_input_rows_stmt       in long
  ,p_exec_status_code             in varchar2
)
IS

  l_api_name             constant varchar2(30) := 'Rule_Post_Proc';

  l_dimension_rec                 dimension_record;

  l_num_of_input_rows             number;
  l_num_of_output_rows            number;

  l_return_status                 t_return_status%TYPE;
  l_msg_count                     t_msg_count%TYPE;
  l_msg_data                      t_msg_data%TYPE;

  l_rule_post_proc_error          exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  l_dimension_rec := p_request_rec.dimension_rec;

  ------------------------------------------------------------------------------
  -- STEP 1: Drop all Temp Objects created for the Rollup Rule
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 1:  Drop all Temp Objects'
  );

  Drop_Temp_Objects (
    p_request_rec => p_request_rec
    ,p_rule_rec   => p_rule_rec
  );

  if (p_exec_status_code = G_EXEC_STATUS_SUCCESS) then

    ----------------------------------------------------------------------------
    -- STEP 2: If a successful object execution, update number of input rows in
    -- FEM_BALANCES before purging FEM_RU_NODES_T.
    ----------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Step 2:  Update Number of Input Rows'
    );

    if (l_dimension_rec.dimension_varchar_label = 'COST_OBJECT') then

      execute immediate p_num_of_input_rows_stmt
      into l_num_of_input_rows
      using p_request_rec.request_id
      ,p_rule_rec.rollup_obj_id
      ,p_request_rec.request_id
      ,p_rule_rec.rollup_obj_id;

    elsif (l_dimension_rec.dimension_varchar_label = 'ACTIVITY') then

      if (p_request_rec.rollup_type_code = 'COST') then

        execute immediate p_num_of_input_rows_stmt
        into l_num_of_input_rows
        using p_request_rec.ledger_id
        ,p_request_rec.request_id
        ,p_rule_rec.rollup_obj_id
        ,p_request_rec.request_id
        ,p_rule_rec.rollup_obj_id;

      elsif (p_request_rec.rollup_type_code = 'STAT') then

        execute immediate p_num_of_input_rows_stmt
        into l_num_of_input_rows
        using p_request_rec.ledger_id
        ,p_rule_rec.statistic_basis_id
        ,p_request_rec.request_id
        ,p_rule_rec.rollup_obj_id
        ,p_request_rec.request_id
        ,p_rule_rec.rollup_obj_id;

      end if;

    end if;

    FEM_PL_PKG.Update_Num_Of_Input_Rows (
      p_api_version        => 1.0
      ,p_commit            => FND_API.G_FALSE
      ,p_request_id        => p_request_rec.request_id
      ,p_object_id         => p_rule_rec.rollup_obj_id
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

  ------------------------------------------------------------------------------
  -- STEP 3: Delete all records in the FEM_RU_NODES_T table
  ------------------------------------------------------------------------------
  --todo: should only delete records for p_exec_status_code = SUCCESS.  But
  --until we bring in error reprocessing, must always delete temp data.
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 3:  Purging Records in FEM_RU_NODES_T'
  );

  delete from fem_ru_nodes_t
  where created_by_request_id = p_request_rec.request_id
  and created_by_object_id = p_rule_rec.rollup_obj_id;

  commit;

  -- Only need to purge the hierarchy rollup tables if there was an error
  if (p_exec_status_code <> G_EXEC_STATUS_SUCCESS) then

    if (l_dimension_rec.dimension_varchar_label = 'COST_OBJECT') then

      --------------------------------------------------------------------------
      -- STEP 4.a: For a COUC rollup, need to delete all records for this
      -- request id in the FEM_RU_COST_OBJ_HIER_T table
      --------------------------------------------------------------------------
      --todo: Until we bring in error reprocessing, must all ways delete temp data.
      FEM_ENGINES_PKG.Tech_Message (
        p_severity  => G_LOG_LEVEL_1
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Step 4.a:  Purging Records in FEM_RU_COST_OBJ_HIER_T'
      );

      delete from fem_ru_cost_obj_hier_t
      where created_by_request_id = p_request_rec.request_id
      and created_by_object_id = p_rule_rec.rollup_obj_id;

      commit;

    elsif ( (l_dimension_rec.dimension_varchar_label = 'ACTIVITY')
        and (p_rule_rec.cond_exists) ) then

      --------------------------------------------------------------------------
      -- STEP 4.b: For an Activity Cost/Stat rollup with a Condition, need to
      -- delete all records for this request id in the FEM_RU_ACTIVITIES_HIER_T
      -- table.
      --------------------------------------------------------------------------
      --todo: Until we bring in error reprocessing, must all ways delete temp data.
      FEM_ENGINES_PKG.Tech_Message (
        p_severity  => G_LOG_LEVEL_1
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Step 4.b:  Purging Records in FEM_RU_ACTIVITIES_HIER_T'
      );

      delete from fem_ru_activities_hier_t
      where created_by_request_id = p_request_rec.request_id
      and created_by_object_id = p_rule_rec.rollup_obj_id;

      commit;

    end if;

  end if;

  ------------------------------------------------------------------------------
  -- STEP 5: Update Number of Output Rows.
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 5:  Update Number of Output Rows'
  );

  select count(*)
  into l_num_of_output_rows
  from fem_balances
  where dataset_code = p_request_rec.output_dataset_code
  and cal_period_id = p_request_rec.output_cal_period_id
  and created_by_request_id = p_request_rec.request_id
  and created_by_object_id = p_rule_rec.rollup_obj_id
  and ledger_id = p_request_rec.ledger_id;

  -- Unregister the data location for the FEM_BALANCES output table if no
  -- output rows were created.
  if (l_num_of_output_rows = 0) then

    FEM_DIMENSION_UTIL_PKG.Unregister_Data_Location (
      p_request_id   => p_request_rec.request_id
      ,p_object_id   => p_rule_rec.rollup_obj_id
    );

  end if;

  -- Set the number of output rows for the FEM_BALANCES output table.
  FEM_PL_PKG.Update_Num_Of_Output_Rows (
    p_api_version         => 1.0
    ,p_commit             => FND_API.G_FALSE
    ,p_request_id         => p_request_rec.request_id
    ,p_object_id          => p_rule_rec.rollup_obj_id
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
  -- STEP 6: Update Object Execution Status.
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 6:  Update Object Execution Status'
  );

  FEM_PL_PKG.Update_Obj_Exec_Status (
    p_api_version        => 1.0
    ,p_commit            => FND_API.G_FALSE
    ,p_request_id        => p_request_rec.request_id
    ,p_object_id         => p_rule_rec.rollup_obj_id
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

  if (p_exec_status_code <> G_EXEC_STATUS_SUCCESS) then

    ----------------------------------------------------------------------------
    -- STEP 7: Update Object Execution Errors.
    ----------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Step 7:  Update Object Execution Errors'
    );

    -- A Rollup Rule is an all or nothing deal, so only 1 error can be reported
    FEM_PL_PKG.Update_Obj_Exec_Errors (
      p_api_version         => 1.0
      ,p_commit             => FND_API.G_FALSE
      ,p_request_id         => p_request_rec.request_id
      ,p_object_id          => p_rule_rec.rollup_obj_id
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
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_rule_post_proc_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Rule Post Process Exception'
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_ENG_RULE_POST_PROC_ERR
      ,p_token1   => 'OBJECT_ID'
      ,p_value1   => p_rule_rec.rollup_obj_id
    );

    raise g_rollup_request_error;

END Rule_Post_Proc;



/*============================================================================+
 | PROCEDURE
 |   Request_Post_Proc
 |
 | DESCRIPTION
 |   Updates the status of the request in the processing locks tables.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

PROCEDURE Request_Post_Proc (
  p_request_rec                   in request_record
  ,p_exec_status_code             in varchar2
)
IS

  l_api_name             constant varchar2(30) := 'Request_Post_Proc';

  l_return_status                 t_return_status%TYPE;
  l_msg_count                     t_msg_count%TYPE;
  l_msg_data                      t_msg_data%TYPE;

  l_request_post_proc_error    exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  if (p_request_rec.submit_obj_type_code = 'RULE_SET') then

    ----------------------------------------------------------------------------
    -- STEP 1: Purge RULE_SET_PROCESS_DATA table
    ----------------------------------------------------------------------------
    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_1
      ,p_module   => G_BLOCK||'.'||l_api_name
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
    ,p_module   => G_BLOCK||'.'||l_api_name
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
    ,p_module   => G_BLOCK||'.'||l_api_name
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
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_request_post_proc_error then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_6
      ,p_module   => G_BLOCK||'.'||l_api_name
      ,p_msg_text => 'Request Post Process Exception'
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_ENG_REQ_POST_PROC_ERR
    );

    raise g_rollup_request_error;

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
  from fnd_lookup_values_vl
  where lookup_type = p_lookup_type
  and lookup_code = p_lookup_code
  and view_application_id = 274;

  return l_meaning;

EXCEPTION

  when others then
    return null;

END Get_Lookup_Meaning;



/*============================================================================+
 | FUNCTION
 |   Get_Object_Type_Name
 |
 | DESCRIPTION
 |   Utility function to return the name for the specified object type code.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

FUNCTION Get_Object_Type_Name (
  p_object_type_code              in varchar2
)
RETURN varchar2
IS

  l_api_name             constant varchar2(30) := 'Get_Object_Type_Name';

  l_object_type_name              varchar2(150);

BEGIN

  select object_type_name
  into l_object_type_name
  from fem_object_types_vl
  where object_type_code = p_object_type_code;

  return l_object_type_name;

EXCEPTION

  when others then
    return null;

END Get_Object_Type_Name;



/*============================================================================+
 | PROCEDURE
 |   Get_Put_Messages
 |
 | DESCRIPTION
 |   Copied from FEM_DATAX_LOADER_PKG.  Will be replaced when Get_Put_Messages
 |   is placed in the common loader package.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

PROCEDURE Get_Put_Messages (
  p_msg_count                     in number
  ,p_msg_data                     in varchar2
)
IS

  l_api_name             constant varchar2(30) := 'Get_Put_Messages';

  l_msg_count                     t_msg_count%TYPE;
  l_msg_data                      t_msg_data%TYPE;
  l_msg_out                       t_msg_count%TYPE;
  l_message                       t_msg_data%TYPE;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
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
      ,p_module   => G_BLOCK||'.'||l_api_name
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
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'msg_data='||l_message
      );

    end loop;

  end if;

  FND_MSG_PUB.Initialize;

END Get_Put_Messages;




END FEM_RU_ENGINE_PVT;

/
