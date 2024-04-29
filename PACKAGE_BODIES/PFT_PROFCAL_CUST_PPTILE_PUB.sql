--------------------------------------------------------
--  DDL for Package Body PFT_PROFCAL_CUST_PPTILE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PFT_PROFCAL_CUST_PPTILE_PUB" AS
/* $Header: PFTPPCTB.pls 120.1 2006/05/25 10:26:44 ssthiaga noship $ */

--------------------------------------------------------------------------------
-- Declare package constants --
--------------------------------------------------------------------------------

  g_object_version_number     CONSTANT    NUMBER        :=  1;
  g_pkg_name                  CONSTANT    VARCHAR2(30)  :=  'PFT_PROFCAL_CUST_PPTILE_PUB';

  -- Constants for p_exec_status_code
  g_exec_status_error_rerun   CONSTANT    VARCHAR2(30)  :=  'ERROR_RERUN';
  g_exec_status_success       CONSTANT    VARCHAR2(30)  :=  'SUCCESS';

  --Constants for output table names being registered with fem_pl_pkg
  -- API register_table method.
  g_fem_customer_profit        CONSTANT   VARCHAR2(30)  :=  'FEM_CUSTOMER_PROFIT';
  g_fem_customer_percentile_gt CONSTANT   VARCHAR2(30)  :=  'FEM_CUSTOMER_PERCENTILE_GT';

  --constant for sql_stmt_type
  g_insert               CONSTANT    VARCHAR2(30)  :=  'INSERT';
  g_update               CONSTANT    VARCHAR2(30)  :=  'UPDATE';

  g_default_fetch_limit  CONSTANT    NUMBER        :=  99999;

  g_log_level_1          CONSTANT    NUMBER        :=  FND_LOG.Level_Statement;
  g_log_level_2          CONSTANT    NUMBER        :=  FND_LOG.Level_Procedure;
  g_log_level_3          CONSTANT    NUMBER        :=  FND_LOG.Level_Event;
  g_log_level_4          CONSTANT    NUMBER        :=  FND_LOG.Level_Exception;
  g_log_level_5          CONSTANT    NUMBER        :=  FND_LOG.Level_Error;
  g_log_level_6          CONSTANT    NUMBER        :=  FND_LOG.Level_Unexpected;

--------------------------------------------------------------------------------
-- Declare package variables --
--------------------------------------------------------------------------------
  -- Exception variables
  gv_prg_msg                  VARCHAR2(2000);
  gv_callstack                VARCHAR2(2000);
  -- Bulk Fetch Limit
  gv_fetch_limit              NUMBER;

  z_master_err_state          NUMBER;

--------------------------------------------------------------------------------
-- Declare package exceptions --
--------------------------------------------------------------------------------
  -- General profit Aggregation Engine Exception
  e_process_single_rule_error  EXCEPTION;
  USER_EXCEPTION               EXCEPTION;

--------------------------------------------------------------------------------
-- Declare private procedures and functions --
--------------------------------------------------------------------------------

  PROCEDURE Update_Nbr_Of_Output_Rows(
    p_request_id           IN  NUMBER
    ,p_user_id             IN  NUMBER
    ,p_login_id            IN  NUMBER
    ,p_rule_obj_id         IN  NUMBER
    ,p_num_output_rows     IN  NUMBER
    ,p_tbl_name            IN  VARCHAR2
    ,p_stmt_type           IN  VARCHAR2
  );

  PROCEDURE Update_Obj_Exec_Step_Status(
    p_request_id           IN  NUMBER
    ,p_user_id             IN  NUMBER
    ,p_login_id            IN  NUMBER
    ,p_rule_obj_id         IN  NUMBER
    ,p_exe_step            IN  VARCHAR2
    ,p_exe_status_code     IN  VARCHAR2
  );

  PROCEDURE Process_Obj_Exec_Step(
    p_request_id           IN  NUMBER
    ,p_user_id             IN  NUMBER
    ,p_login_id            IN  NUMBER
    ,p_rule_obj_id         IN  NUMBER
    ,p_exe_step            IN  VARCHAR2
    ,p_exe_status_code     IN  VARCHAR2
    ,p_tbl_name            IN  VARCHAR2
    ,p_num_rows            IN  NUMBER
  );

  PROCEDURE Get_Put_Messages (
    p_msg_count            IN  NUMBER
    ,p_msg_data            IN  VARCHAR2
  );

  FUNCTION Create_Pptile_Update_Stmt (
    p_rule_obj_id          IN  NUMBER
    ,p_table_name          IN  VARCHAR2
    ,p_cal_period_id       IN  NUMBER
    ,p_effective_date      IN  VARCHAR2
    ,p_dataset_code        IN  NUMBER
    ,p_ledger_id           IN  NUMBER
    ,p_source_system_code  IN  NUMBER
    ,p_ds_where_clause     IN  LONG)

  RETURN LONG;

  PROCEDURE Update_Nbr_Of_Input_Rows(
    p_request_id           IN  NUMBER
    ,p_user_id             IN  NUMBER
    ,p_last_update_login   IN  NUMBER
    ,p_rule_obj_id         IN  NUMBER
    ,p_num_of_input_rows   IN  NUMBER
  );

/*======--=====================================================================+
 | PROCEDURE
 |   PROCESS SINGLE RULE
 |
 | DESCRIPTION
 |   Main engine procedure for region counting step in profit calcution in PFT.
 |
 | SCOPE - PUBLIC
 |
 +============================================================================*/

   PROCEDURE Process_Single_Rule ( p_rule_obj_id            IN NUMBER
                                  ,p_cal_period_id          IN NUMBER
                                  ,p_dataset_io_obj_def_id  IN NUMBER
                                  ,p_output_dataset_code    IN NUMBER
                                  ,p_effective_date         IN VARCHAR2
                                  ,p_ledger_id              IN NUMBER
                                  ,p_source_system_code     IN NUMBER
                                  ,p_customer_level         IN NUMBER
                                  ,p_exec_state             IN VARCHAR2
                                  ,x_return_status          OUT NOCOPY VARCHAR2)

   IS

   l_api_name               CONSTANT  VARCHAR2(30)  := 'Process_Single_Rule';

   l_process_table                    VARCHAR2(30) := 'FEM_CUSTOMER_PROFIT';
   l_table_alias                      VARCHAR2(5)  := 'FCP';
   l_ds_where_clause                  LONG := NULL;
   l_insert_sql                       LONG;
   l_update_sql                       LONG;
   l_err_msg                          VARCHAR2(255);
   l_reuse_slices                     VARCHAR2(10);
   l_msg_count                        NUMBER;
   l_exception_code                   VARCHAR2(50);
   l_msg_data                         VARCHAR2(200);
   l_return_status                    VARCHAR2(50)  :=  NULL;
   l_null_string                      VARCHAR2(10)  :=  NULL;
   l_request_id                       NUMBER := FND_GLOBAL.Conc_Request_Id;
   l_user_id                          NUMBER := FND_GLOBAL.User_Id;
   l_login_id                         NUMBER := FND_GLOBAL.Login_Id;
   l_num_rows_loaded                  NUMBER;

   TYPE v_msg_list_type               IS VARRAY(20) OF
                                      fem_mp_process_ctl_t.message%TYPE;
   v_msg_list                         v_msg_list_type;

   e_register_rule_error              EXCEPTION;

   BEGIN
      -- Initialize the return status to SUCCESS
      x_return_status  := FND_API.G_RET_STS_SUCCESS;

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => g_log_level_3
        ,p_module    => G_BLOCK||'.'||l_api_name
        ,p_msg_text  => 'Generating the dataset where clause');

      FEM_DS_WHERE_CLAUSE_GENERATOR.Fem_Gen_Ds_WClause_Pvt(
         p_api_version      => G_CALLING_API_VERSION
        ,p_init_msg_list    => FND_API.G_TRUE
        ,p_encoded          => FND_API.G_TRUE
        ,x_return_status    => l_return_status
        ,x_msg_count        => l_msg_count
        ,x_msg_data         => l_msg_data
        ,p_ds_io_def_id     => p_dataset_io_obj_def_id
        ,p_output_period_id => p_cal_period_id
        ,p_table_alias      => l_table_alias
        ,p_table_name       => l_process_table
        ,p_ledger_id        => p_ledger_id
        ,p_where_clause     => l_ds_where_clause);

      IF(l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
         Get_Put_Messages ( p_msg_count => l_msg_count
                           ,p_msg_data  => l_msg_data);
         FEM_ENGINES_PKG.User_Message (
            p_app_name => G_PFT
           ,p_msg_name => G_ENG_DS_WHERE_CLAUSE_ERR
           ,p_token1   => 'OUTPUT_DS_CODE'
           ,p_value1   => p_dataset_io_obj_def_id
           ,p_token2   => 'CAL_PERIOD_ID'
           ,p_value2   => p_cal_period_id);

         IF (l_ds_where_clause IS NULL) THEN
            FEM_ENGINES_PKG.User_Message (
               p_app_name => G_PFT
              ,p_msg_name => G_ENG_DS_WHERE_CLAUSE_ERR
              ,p_token1   => 'OUTPUT_DS_CODE'
              ,p_value1   => p_dataset_io_obj_def_id
              ,p_token2   => 'CAL_PERIOD_ID'
              ,p_value2   => p_cal_period_id);
         END IF;
         RAISE e_process_single_rule_error;

      END IF;

      -- CHECKPOINT RESTART
      -- check executed state and jump to appropriate statement
      -- depending on which step was last executed successfully
      IF(p_exec_state = 'RESTART') THEN
         l_reuse_slices := 'Y';
      ELSE
         l_reuse_slices := 'N';
      END IF;

      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => g_log_level_3
        ,p_module    => G_BLOCK||'.'||l_api_name
        ,p_msg_text  => 'Building Update SQL');

      -- To create the UPDATE statement for the Region Counting Step.
      l_update_sql := Create_Pptile_Update_Stmt(
                            p_rule_obj_id         =>  p_rule_obj_id
                           ,p_table_name          =>  l_process_table
                           ,p_cal_period_id       =>  p_cal_period_id
                           ,p_effective_date      =>  p_effective_date
                           ,p_dataset_code        =>  p_output_dataset_code
                           ,p_ledger_id           =>  p_ledger_id
                           ,p_source_system_code  =>  p_source_system_code
                           ,p_ds_where_clause     =>  l_ds_where_clause);

      FEM_ENGINES_PKG.TECH_MESSAGE(
         p_severity => g_log_level_3
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Update Sql'|| l_update_sql);

      BEGIN
         FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Issuing the Execute Immediate Stmt');

         EXECUTE IMMEDIATE l_update_sql;

         l_num_rows_loaded := SQL%ROWCOUNT;
      EXCEPTION
         WHEN OTHERS THEN
	    gv_prg_msg := SQLERRM;

            FEM_ENGINES_PKG.Tech_Message (
               p_severity => g_log_level_3
              ,p_module   => G_BLOCK||'.'||l_api_name
              ,p_msg_text => 'UPDATE STATEMENT ERROR');

            FEM_ENGINES_PKG.Tech_Message (
               p_severity => g_log_level_6
              ,p_module   => G_BLOCK||'.'||l_api_name||'.Unexpected Exception'
              ,p_msg_text => gv_prg_msg);

            FEM_ENGINES_PKG.User_Message (
               p_app_name => G_FEM
              ,p_msg_name => G_UNEXPECTED_ERROR
              ,p_token1   => 'ERR_MSG'
              ,p_value1   => gv_prg_msg);

            Process_Obj_Exec_Step(
                p_request_id      => l_request_id
               ,p_user_id         => l_user_id
               ,p_login_id        => l_login_id
               ,p_rule_obj_id     => p_rule_obj_id
               ,p_exe_step        => 'CUST_PPTILE'
               ,p_exe_status_code => g_exec_status_error_rerun
               ,p_tbl_name        => g_fem_customer_profit
               ,p_num_rows        => NULL);

         RAISE e_process_single_rule_error;
      END;

      Process_Obj_Exec_Step( p_request_id      => l_request_id
                            ,p_user_id         => l_user_id
                            ,p_login_id        => l_login_id
                            ,p_rule_obj_id     => p_rule_obj_id
                            ,p_exe_step        => 'CUST_PPTILE'
                            ,p_exe_status_code => g_exec_status_success
                            ,p_tbl_name        => g_fem_customer_profit
                            ,p_num_rows        => NVL(l_num_rows_loaded,0));

      -- commit the work
      COMMIT;

      FEM_ENGINES_PKG.Tech_Message ( p_severity => G_LOG_LEVEL_2
                                    ,p_module   => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text => 'END');

   EXCEPTION
      WHEN e_process_single_rule_error THEN

         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Process Single Rule Exception');

         FEM_ENGINES_PKG.User_Message (p_app_name  => G_PFT
                                      ,p_msg_name  => G_ENG_SINGLE_RULE_ERR);

         x_return_status  := FND_API.G_RET_STS_ERROR;

      WHEN OTHERS THEN
         FEM_ENGINES_PKG.User_Message (p_app_name  => G_PFT
                                      ,p_msg_name  => G_ENG_SINGLE_RULE_ERR);

         x_return_status  := FND_API.G_RET_STS_ERROR;

   END Process_Single_Rule;

 /*============================================================================+
 | PROCEDURE
 |   Update_Num_Of_Output_Rows
 |
 | DESCRIPTION
 |   Updates the rows successfully processed by calling
 |   fem_pl_pkg.Update_Num_Of_Output_Rows in fem_pl_tables.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/
   PROCEDURE Update_Nbr_Of_Output_Rows( p_request_id       IN  NUMBER
                                       ,p_user_id          IN  NUMBER
                                       ,p_login_id         IN  NUMBER
                                       ,p_rule_obj_id      IN  NUMBER
                                       ,p_num_output_rows  IN  NUMBER
                                       ,p_tbl_name         IN  VARCHAR2
                                       ,p_stmt_type        IN  VARCHAR2)
   IS

   l_api_name        CONSTANT      VARCHAR2(30) := 'Update_Num_Of_Output_Rows';

   l_return_status                 VARCHAR2(2);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(240);

   e_upd_num_output_rows_error     EXCEPTION;

   BEGIN

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      -- Set the number of output rows for the output table.
      FEM_PL_PKG.Update_Num_Of_Output_Rows(
         p_api_version          =>  1.0
        ,p_commit               =>  FND_API.G_TRUE
        ,p_request_id           =>  p_request_id
        ,p_object_id            =>  p_rule_obj_id
        ,p_table_name           =>  p_tbl_name
        ,p_statement_type       =>  p_stmt_type
        ,p_num_of_output_rows   =>  p_num_output_rows
        ,p_user_id              =>  p_user_id
        ,p_last_update_login    =>  p_login_id
        ,x_msg_count            =>  l_msg_count
        ,x_msg_data             =>  l_msg_data
        ,x_return_status        =>  l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

         Get_Put_Messages( p_msg_count => l_msg_count
                          ,p_msg_data  => l_msg_data);

         RAISE e_upd_num_output_rows_error;
      END IF;

      FEM_ENGINES_PKG.Tech_Message( p_severity  => g_log_level_2
                                   ,p_module    => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text  => 'END');

   EXCEPTION
      WHEN e_upd_num_output_rows_error THEN
         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Update Rows Exception');

         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_OP_UPD_ROWS_ERR);

      RAISE e_process_single_rule_error;

      WHEN OTHERS THEN
         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_OP_UPD_ROWS_ERR);

      RAISE e_process_single_rule_error;

   END Update_Nbr_Of_Output_Rows;

 /*============================================================================+
 | PROCEDURE
 |   Update_Obj_Exec_Step_Status
 |
 | DESCRIPTION
 |   Updates the status of the executuon of the object by calling
 |   fem_pl_pkg.Update_obj_exec_step_status in fem_pl_obj_steps.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/
   PROCEDURE Update_Obj_Exec_Step_Status( p_request_id       IN NUMBER
                                         ,p_user_id          IN NUMBER
                                         ,p_login_id         IN NUMBER
                                         ,p_rule_obj_id      IN NUMBER
                                         ,p_exe_step         IN VARCHAR2
                                         ,p_exe_status_code  IN VARCHAR2)
   IS

   l_api_name             CONSTANT VARCHAR2(30) := 'Update_Obj_Exe_Step_Status';

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(240);

   e_upd_obj_exec_step_stat_error  EXCEPTION;

   BEGIN

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      --Call the FEM_PL_PKG.Update_obj_exec_step_status API procedure
      --to update step staus in fem_pl_obj_steps.
      FEM_PL_PKG.Update_Obj_Exec_Step_Status(
         p_api_version          =>  1.0
        ,p_commit               =>  FND_API.G_TRUE
        ,p_request_id           =>  p_request_id
        ,p_object_id            =>  p_rule_obj_id
        ,p_exec_step            =>  p_exe_step
        ,p_exec_status_code     =>  p_exe_status_code
        ,p_user_id              =>  p_user_id
        ,p_last_update_login    =>  p_login_id
        ,x_msg_count            =>  l_msg_count
        ,x_msg_data             =>  l_msg_data
        ,x_return_status        =>  l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         Get_Put_Messages ( p_msg_count => l_msg_count
                           ,p_msg_data  => l_msg_data);
         RAISE e_upd_obj_exec_step_stat_error;

      END IF;

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'END');

   EXCEPTION
      WHEN  e_upd_obj_exec_step_stat_error   THEN
         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Update Obj Exec Step API Exception');

         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_UPD_EXEC_STEP_ERR
           ,p_token1    => 'OBJECT_ID'
           ,p_value1    => p_rule_obj_id);

      RAISE e_process_single_rule_error;

      WHEN OTHERS THEN
         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_UPD_EXEC_STEP_ERR
           ,p_token1    => 'OBJECT_ID'
           ,p_value1    => p_rule_obj_id);

      RAISE e_process_single_rule_error;

   END Update_Obj_Exec_Step_Status;

 /*============================================================================+
 | PROCEDURE
 |   Process_Obj_Exec_Step
 | DESCRIPTION
 |   Processes the execution of the Object.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/
   PROCEDURE Process_Obj_Exec_Step( p_request_id      IN NUMBER
                                   ,p_user_id         IN NUMBER
                                   ,p_login_id        IN NUMBER
                                   ,p_rule_obj_id     IN NUMBER
                                   ,p_exe_step        IN VARCHAR2
                                   ,p_exe_status_code IN VARCHAR2
                                   ,p_tbl_name        IN VARCHAR2
                                   ,p_num_rows        IN NUMBER)
   IS
   l_api_name         VARCHAR2(30);
   l_nbr_output_rows  NUMBER;
   l_nbr_input_rows   NUMBER;

   BEGIN
      l_api_name          := 'Process_Obj_Exec_Step';

      FEM_ENGINES_PKG.Tech_Message( p_severity => g_log_level_2
                                   ,p_module   => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text => 'BEGIN');

      --------------------------------------------------------------------------
      --update the status of the step
      --------------------------------------------------------------------------
      FEM_ENGINES_PKG.Tech_Message(
         p_severity => g_log_level_3
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Update the status of the step with execution status :'
                       ||p_exe_status_code);

      Update_Obj_Exec_Step_Status( p_request_id      =>  p_request_id
                                  ,p_user_id         =>  p_user_id
                                  ,p_login_id        =>  p_login_id
                                  ,p_rule_obj_id     =>  p_rule_obj_id
                                  ,p_exe_step        =>  'CUST_PPTILE'
                                  ,p_exe_status_code =>  p_exe_status_code );

      IF (p_exe_status_code = g_exec_status_success) THEN

         --update the number of output rows processed succesfully
         --in the registered table
         FEM_ENGINES_PKG.Tech_Message(
            p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Rows processed for registered output table :'
                          ||p_tbl_name);

         -- update the number of rows processed in the registered table
         Update_Nbr_Of_Output_Rows( p_request_id       =>  p_request_id
                                   ,p_user_id          =>  p_user_id
                                   ,p_login_id         =>  p_login_id
                                   ,p_rule_obj_id      =>  p_rule_obj_id
                                   ,p_num_output_rows  =>  p_num_rows
                                   ,p_tbl_name         =>  p_tbl_name
                                   ,p_stmt_type        =>  g_update );

         -----------------------------------------------------------------------
         -- Call FEM_PL_PKG.update_num_of_input_rows();
         -----------------------------------------------------------------------

        FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => g_log_level_1,
            p_module   => G_BLOCK||'.'||l_api_name,
            p_msg_text => 'No.of Rows processed from input table :'
                          || p_num_rows);

         -- update the number of rows processed in the registered table
         Update_Nbr_Of_Input_Rows( p_request_id        =>  p_request_id
                                  ,p_user_id           =>  p_user_id
                                  ,p_last_update_login =>  p_login_id
                                  ,p_rule_obj_id       =>  p_rule_obj_id
                                  ,p_num_of_input_rows =>  p_num_rows);

         FEM_ENGINES_PKG.User_Message(
            p_app_name => G_PFT
           ,p_msg_name => 'PFT_PPROF_PPTILE_ROW_SUMMARY'
           ,p_token1   => 'ROWSP'
           ,p_value1   => NVL(p_num_rows,0)
           ,p_token2   => 'ROWSL'
           ,p_value2   => NVL(p_num_rows,0));

      END IF;

      FEM_ENGINES_PKG.Tech_Message( p_severity => g_log_level_2
                                   ,p_module   => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text => 'END');

   EXCEPTION
      WHEN OTHERS THEN
      RAISE e_process_single_rule_error;

   END;

 /*============================================================================+
 | FUNCTION
 |   Create Profit Percentile Update Statement
 |
 | DESCRIPTION
 |   Creates the Bulk SQL for Profit Percentile
 |   (To Update Fem_Customer_Profit Table).
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

   FUNCTION Create_Pptile_Update_Stmt ( p_rule_obj_id            IN NUMBER
                                       ,p_table_name             IN VARCHAR2
                                       ,p_cal_period_id          IN NUMBER
                                       ,p_effective_date         IN VARCHAR2
                                       ,p_dataset_code           IN NUMBER
                                       ,p_ledger_id              IN NUMBER
                                       ,p_source_system_code     IN NUMBER
                                       ,p_ds_where_clause        IN LONG)
   RETURN LONG IS

   l_api_name       CONSTANT    VARCHAR2(30) := 'Create_Pptile_Update_Stmt';

   l_update_head_stmt           LONG;
   l_select_stmt                LONG;
   l_from_stmt                  LONG;
   l_where_stmt                 LONG;
   l_request_id                 NUMBER;
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(500);
   l_return_status              VARCHAR2(20);
   l_effective_date             DATE;
   l_user_id                    NUMBER;
   l_login_id                   NUMBER := FND_GLOBAL.Login_Id;
   l_gvsc_id                    NUMBER;
   l_err_code                   NUMBER := 0;
   l_num_msg                    NUMBER := 0;
   l_value_set_id               NUMBER;

   BEGIN
      l_request_id             :=  FND_GLOBAL.Conc_Request_Id;
      l_user_id                :=  FND_GLOBAL.User_Id;
      l_effective_date         :=  FND_DATE.Canonical_To_Date(p_effective_date);

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => g_log_level_2
        ,p_module    => G_BLOCK||'.'||l_api_name
        ,p_msg_text  => 'Getting Global VS Combo ID');

      l_gvsc_id := FEM_DIMENSION_UTIL_PKG.Global_VS_Combo_ID (
                      p_ledger_id => p_ledger_id
                     ,x_err_code  => l_err_code
                     ,x_num_msg   => l_num_msg);

      IF(l_err_code <> 0)THEN
         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_2
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'No GVSC Id for the Given Ledger' || p_ledger_id);

         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_ENG_INVALID_LEDGER_ERR
           ,p_token1    => 'LEDGER_ID'
           ,p_value1    => p_ledger_id);

         RAISE e_process_single_rule_error;
      END IF;

      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => g_log_level_2
        ,p_module    => G_BLOCK||'.'||l_api_name
        ,p_msg_text  => 'Getting Customer Value Set Id');

      BEGIN
         SELECT gvsc.value_set_id
           INTO l_value_set_id
         FROM   fem_global_vs_combo_defs gvsc,fem_dimensions_b dim
         WHERE  gvsc.dimension_id = dim.dimension_id
           AND  dim.dimension_varchar_label = 'CUSTOMER'
           AND  gvsc.global_vs_combo_id = l_gvsc_id;
      EXCEPTION
         WHEN no_data_found THEN
            FEM_ENGINES_PKG.Tech_Message (
               p_severity => g_log_level_2
              ,p_module   => G_BLOCK||'.'||l_api_name
              ,p_msg_text => 'No Value Set Id for the Given GVSC '|| l_gvsc_id);

            FEM_ENGINES_PKG.User_Message (
               p_app_name  => G_PFT
              ,p_msg_name  => G_ENG_INVALID_GVSC_ERR
              ,p_token1    => 'GVSC_ID'
              ,p_value1    => l_gvsc_id);

         RAISE e_process_single_rule_error;

         WHEN OTHERS THEN
         RAISE;
      END;

      l_update_head_stmt := ' UPDATE FEM_CUSTOMER_PROFIT FCP' ||
                            ' SET (' ||
                            ' FCP.PROFIT_PERCENTILE, '||
                            ' FCP.PROFIT_DECILE, '||
                            ' FCP.LAST_UPDATED_BY_OBJECT_ID, ' ||
                            ' FCP.LAST_UPDATED_BY_REQUEST_ID ' ||
                            ' ) = ';

      l_select_stmt :=      ' ( SELECT '||
                            ' PROFIT_PERCENTILE,' ||
                            ' PROFIT_DECILE, ' ||
                              p_rule_obj_id || ' , ' ||
                              l_request_id ;

      l_from_stmt :=        ' FROM' ||
                            ' ( SELECT  BUS_REL_ID, CUSTOMER_ID, ' ||
                  			    ' NTILE(100) OVER ' ||
                  			    ' (PARTITION BY dimension_group_id ' ||
                  			    ' ORDER BY  PROFIT_CONTRIB ASC NULLS FIRST) ' ||
                  			    ' AS PROFIT_PERCENTILE, ' ||
                  			    ' NTILE(10) OVER ' ||
                  			    ' (PARTITION BY dimension_group_id ' ||
                  			    ' ORDER BY  PROFIT_CONTRIB ASC NULLS FIRST) ' ||
                  			    ' AS PROFIT_DECILE ' ||
                            ' FROM (SELECT FCP.BUS_REL_ID,FCP.CUSTOMER_ID, ' ||
                            ' DIMENSION_GROUP_ID, ' ||
                            ' PROFIT_CONTRIB FROM   FEM_CUSTOMERS_B FCB, ' ||
                            ' FEM_CUSTOMER_PROFIT fcp ' ||
                            ' WHERE  FCP.LEDGER_ID = ' || p_ledger_id ||
                            ' AND FCP.SOURCE_SYSTEM_CODE = ' || p_source_system_code ||
                            ' AND DATA_AGGREGATION_TYPE_CODE = ' || '''CUSTOMER_AGGREGATION''' ||
                            ' AND FCP.CUSTOMER_ID = FCB.CUSTOMER_ID' ||
                            ' AND FCB.VALUE_SET_ID = ' || l_value_set_id;

      l_where_stmt :=       ' )) dump WHERE' ||
                            ' dump.BUS_REL_ID = FCP.BUS_REL_ID'||
                            ' AND dump.CUSTOMER_ID = FCP.CUSTOMER_ID ) ' ||
                            ' WHERE FCP.LEDGER_ID =' || p_ledger_id ||
                            ' AND FCP.SOURCE_SYSTEM_CODE = ' || p_source_system_code ||
                            ' AND FCP.DATA_AGGREGATION_TYPE_CODE = ' || '''CUSTOMER_AGGREGATION''';

      IF (p_ds_where_clause IS NOT NULL) THEN

         l_from_stmt := l_from_stmt || ' AND ' || p_ds_where_clause;

         l_where_stmt := l_where_stmt || ' AND ' || p_ds_where_clause;

      END IF;

      -- add mapped columns
      RETURN l_update_head_stmt || ' ' || l_select_stmt || ' ' || l_from_stmt
             || ' ' || l_where_stmt ;

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => G_LOG_LEVEL_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'END');

      EXCEPTION
        WHEN OTHERS THEN
        RAISE;

   END Create_Pptile_Update_Stmt;

 /*============================================================================+
 | PROCEDURE
 |   Get_Put_Messages
 |
 | DESCRIPTION
 |   To put the User messages,to be placed in common loader package.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

   PROCEDURE Get_Put_Messages ( p_msg_count         IN NUMBER
                               ,p_msg_data          IN VARCHAR2)
   IS

   l_api_name             CONSTANT VARCHAR2(30) := 'Get_Put_Messages';
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(4000);
   l_msg_out                       NUMBER;
   l_message                       VARCHAR2(4000);

   BEGIN

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'msg_count='||p_msg_count);

      l_msg_data := p_msg_data;

      IF (p_msg_count = 1) THEN

         FND_MESSAGE.Set_Encoded(l_msg_data);

	 l_message := FND_MESSAGE.Get;

         FEM_ENGINES_PKG.User_Message ( p_msg_text => l_message );

         FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                       ,p_module    => G_BLOCK||'.'||l_api_name
                                       ,p_msg_text  => 'msg_data='||l_message);

      ELSIF (p_msg_count > 1) THEN

         FOR i IN 1..p_msg_count LOOP
            FND_MSG_PUB.Get ( p_msg_index     => i
                             ,p_encoded       => FND_API.G_FALSE
                             ,p_data          => l_message
                             ,p_msg_index_out => l_msg_out);

            FEM_ENGINES_PKG.User_Message ( p_msg_text => l_message );

            FEM_ENGINES_PKG.Tech_Message (
               p_severity => g_log_level_2
              ,p_module   => G_BLOCK||'.'||l_api_name
              ,p_msg_text => 'msg_data = '||l_message);

         END LOOP;

      END IF;

      FND_MSG_PUB.Initialize;

   END Get_Put_Messages;

 /*============================================================================+
 | PROCEDURE
 |   Update_Num_Of_Input_Rows
 |
 | DESCRIPTION
 |   This procedure logs the total number of rows used as input into
 | an object execution
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

   PROCEDURE Update_Nbr_Of_Input_Rows( p_request_id             IN  NUMBER
                                      ,p_user_id                IN  NUMBER
                                      ,p_last_update_login      IN  NUMBER
                                      ,p_rule_obj_id            IN  NUMBER
                                      ,p_num_of_input_rows      IN  NUMBER)
   IS

   l_api_name       CONSTANT      VARCHAR2(30) := 'Update_Num_Of_Input_Rows';

   l_return_status                VARCHAR2(2);
   l_msg_count                    NUMBER;
   l_msg_data                     VARCHAR2(240);

   e_upd_num_input_rows_error     EXCEPTION;

   BEGIN

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      -- Set the number of output rows for the output table.
      FEM_PL_PKG.Update_Num_Of_Input_Rows(
                      p_api_version          =>  1.0
                     ,p_commit               =>  FND_API.G_TRUE
                     ,p_request_id           =>  p_request_id
                     ,p_object_id            =>  p_rule_obj_id
                     ,p_num_of_input_rows    =>  p_num_of_input_rows
                     ,p_user_id              =>  p_user_id
                     ,p_last_update_login    =>  p_last_update_login
                     ,x_msg_count            =>  l_msg_count
                     ,x_msg_data             =>  l_msg_data
                     ,x_return_status        =>  l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         Get_Put_Messages( p_msg_count => l_msg_count
                          ,p_msg_data  => l_msg_data);
         RAISE e_upd_num_input_rows_error;
      END IF;

      FEM_ENGINES_PKG.Tech_Message( p_severity  => g_log_level_2
                                   ,p_module    => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text  => 'END');

   EXCEPTION
      WHEN e_upd_num_input_rows_error THEN
         FEM_ENGINES_PKG.Tech_Message (
	    p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Update Input Rows Exception');

         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_IP_UPD_ROWS_ERR);

      RAISE e_process_single_rule_error;

      WHEN OTHERS THEN
         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Update Input Rows Exception');

         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_IP_UPD_ROWS_ERR);

      RAISE e_process_single_rule_error;

   END Update_Nbr_Of_Input_Rows;

 END PFT_PROFCAL_CUST_PPTILE_PUB;

/
