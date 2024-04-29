--------------------------------------------------------
--  DDL for Package Body PFT_PROFCAL_PROSP_IDENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PFT_PROFCAL_PROSP_IDENT_PUB" AS
/* $Header: PFTPIDNTB.pls 120.1 2006/05/25 10:36:55 ssthiaga noship $ */

--------------------------------------------------------------------------------
-- Declare package constants --
--------------------------------------------------------------------------------

  g_object_version_number     CONSTANT    NUMBER        :=  1;
  g_pkg_name                  CONSTANT    VARCHAR2(30)  :=  'PFT_PROFCAL_PROSP_IDENT_PUB';

  -- Constants for p_exec_status_code
  g_exec_status_error_rerun   CONSTANT    VARCHAR2(30)  :=  'ERROR_RERUN';
  g_exec_status_success       CONSTANT    VARCHAR2(30)  :=  'SUCCESS';

  --Constants for output table names being registered with fem_pl_pkg
  -- API register_table method.
  g_fem_customer_profit  CONSTANT    VARCHAR2(30)  :=  'FEM_CUSTOMER_PROFIT';
  g_fem_customers_attr   CONSTANT    VARCHAR2(30)  :=  'FEM_CUSTOMERS_ATTR';

  --constant for sql_stmt_type
  g_insert               CONSTANT    VARCHAR2(30)  :=  'INSERT';
  g_update               CONSTANT    VARCHAR2(30)  :=  'UPDATE';

  g_default_fetch_limit  CONSTANT    NUMBER        :=  99999;

  g_log_level_1          CONSTANT    NUMBER        :=  fnd_log.level_statement;
  g_log_level_2          CONSTANT    NUMBER        :=  fnd_log.level_procedure;
  g_log_level_3          CONSTANT    NUMBER        :=  fnd_log.level_event;
  g_log_level_4          CONSTANT    NUMBER        :=  fnd_log.level_exception;
  g_log_level_5          CONSTANT    NUMBER        :=  fnd_log.level_error;
  g_log_level_6          CONSTANT    NUMBER        :=  fnd_log.level_unexpected;

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


  PROCEDURE Update_Nbr_Of_Output_Rows (
    p_request_id           IN NUMBER
    ,p_user_id             IN NUMBER
    ,p_login_id            IN NUMBER
    ,p_rule_obj_id         IN NUMBER
    ,p_num_output_rows     IN NUMBER
    ,p_tbl_name            IN VARCHAR2
    ,p_stmt_type           IN VARCHAR2
  );

  PROCEDURE Update_Obj_Exec_Step_Status (
    p_request_id           IN NUMBER
    ,p_user_id             IN NUMBER
    ,p_login_id            IN NUMBER
    ,p_rule_obj_id         IN NUMBER
    ,p_exe_step            IN VARCHAR2
    ,p_exe_status_code     IN VARCHAR2
  );

  PROCEDURE Get_Nbr_RowsTable_Request (
    x_rows_processed       OUT NOCOPY NUMBER
    ,x_rows_loaded         OUT NOCOPY NUMBER
    ,x_rows_rejected       OUT NOCOPY NUMBER
    ,p_request_id          IN  NUMBER
  );

  PROCEDURE Process_Obj_Exec_Step (
    p_request_id           IN NUMBER
    ,p_user_id             IN NUMBER
    ,p_login_id            IN NUMBER
    ,p_rule_obj_id         IN NUMBER
    ,p_exe_step            IN VARCHAR2
    ,p_exe_status_code     IN VARCHAR2
    ,p_tbl_name            IN VARCHAR2
  );

  PROCEDURE Get_Put_Messages (
    p_msg_count            IN NUMBER
    ,p_msg_data            IN VARCHAR2
  );

  FUNCTION Create_Prospect_Ident_Stmt (
    p_rule_obj_id          IN NUMBER
    ,p_table_name          IN VARCHAR2
    ,p_cal_period_id       IN NUMBER
    ,p_effective_date      IN VARCHAR2
    ,p_dataset_code        IN NUMBER
    ,p_ledger_id           IN NUMBER
    ,p_source_system_code  IN NUMBER
    ,p_value_set_id        IN NUMBER)

  RETURN LONG;

  PROCEDURE Update_Nbr_Of_Input_Rows (
    p_request_id           IN NUMBER
    ,p_user_id             IN NUMBER
    ,p_last_update_login   IN NUMBER
    ,p_rule_obj_id         IN NUMBER
    ,p_num_of_input_rows   IN NUMBER
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
                                  ,p_exec_state             IN VARCHAR2
                                  ,x_return_status          OUT NOCOPY VARCHAR2)

   IS

   l_api_name      CONSTANT     VARCHAR2(30)  := 'Process_Single_Rule';

   l_process_table              VARCHAR2(30) := 'FEM_CUSTOMER_PROFIT';
   l_table_alias                VARCHAR2(5)  := 'FCP';
   l_gvsc_id                    NUMBER;
   l_ds_where_clause            LONG := NULL;
   l_bulk_sql                   LONG;
   l_effective_date             DATE;
   l_err_code                   NUMBER := 0;
   l_num_msg                    NUMBER := 0;
   l_err_msg                    VARCHAR2(255);
   l_reuse_slices               VARCHAR2(10);
   l_msg_count                  NUMBER;
   l_exception_code             VARCHAR2(50);
   l_msg_data                   VARCHAR2(200);
   l_return_status              VARCHAR2(50)  :=  NULL;
   l_value_set_id               NUMBER;
   l_request_id                 NUMBER := FND_GLOBAL.Conc_Request_Id;
   l_user_id                    NUMBER := FND_GLOBAL.User_Id;
   l_login_id                   NUMBER := FND_GLOBAL.Login_Id;

   TYPE v_msg_list_type        IS VARRAY(20) OF
                               fem_mp_process_ctl_t.message%TYPE;
   v_msg_list                  v_msg_list_type;

   e_process_single_rule_error  EXCEPTION;
   e_register_rule_error        EXCEPTION;

   BEGIN
      -- Initialize the return status to SUCCESS
      x_return_status  := FND_API.G_RET_STS_SUCCESS;

      l_effective_date := FND_DATE.Canonical_To_Date(p_effective_date);

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      -- CHECKPOINT RESTART
      -- check executed state and jump to appropriate statement
      -- depending on which step was last executed successfully
      IF(p_exec_state = 'RESTART') THEN
         l_reuse_slices := 'Y';
      ELSE
         l_reuse_slices := 'N';
      END IF;

      -- Get Value Set Id for the given LEDGER.
      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
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

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
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
              ,p_msg_text => 'No Value Set Id for the Given GVSC ' ||l_gvsc_id);

            FEM_ENGINES_PKG.User_Message (
               p_app_name  => G_PFT
              ,p_msg_name  => G_ENG_INVALID_GVSC_ERR
              ,p_token1    => 'GVSC_ID'
              ,p_value1    => l_gvsc_id);

         RAISE e_process_single_rule_error;

         WHEN OTHERS THEN
         RAISE;
      END;

      -- To create the INSERT statement for the Prospect Identification Step.
      l_bulk_sql := Create_Prospect_Ident_Stmt(
                          p_rule_obj_id        =>  p_rule_obj_id
                         ,p_table_name         =>  l_process_table
                         ,p_cal_period_id      =>  p_cal_period_id
                         ,p_effective_date     =>  p_effective_date
                         ,p_dataset_code       =>  p_output_dataset_code
                         ,p_ledger_id          =>  p_ledger_id
                         ,p_source_system_code =>  p_source_system_code
                         ,P_value_set_id       =>  l_value_set_id);

      FEM_ENGINES_PKG.TECH_MESSAGE(
         p_severity => g_log_level_3
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Registering step: PROSP_IDENT');

      FEM_ENGINES_PKG.TECH_MESSAGE(
         p_severity => g_log_level_3
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Submitting to MP Master.p_rule_id: '
                       ||p_rule_obj_id);

      FEM_ENGINES_PKG.TECH_MESSAGE(
         p_severity => g_log_level_3
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Submitting Prospect Ident SQL to MP Master.p_eng_sql: '
                       ||l_bulk_sql);

      FEM_MULTI_PROC_PKG.Master(
         p_rule_id        =>  p_rule_obj_id
        ,p_eng_step       =>  'PROSP_IDENT'
        ,p_eng_sql        =>  l_bulk_sql
        ,p_data_table     =>  l_process_table
        ,p_table_alias    =>  l_table_alias
        ,p_run_name       =>  NULL
        ,p_eng_prg        =>  NULL
        ,p_condition      =>  NULL
        ,p_failed_req_id  =>  NULL
        ,p_reuse_slices   =>  l_reuse_slices
        ,x_prg_stat       =>  l_err_msg
        ,x_Exception_code =>  l_exception_code);

      IF (l_err_msg <> G_COMPLETE_NORMAL) THEN
         v_msg_list := v_msg_list_type();

         SELECT DISTINCT(message)
         BULK COLLECT INTO v_msg_list
         FROM fem_mp_process_ctl_t
         WHERE req_id = l_request_id
           AND status = 2;

         FEM_ENGINES_PKG.Tech_Message(p_severity => g_log_level_1
                                     ,p_module   => G_BLOCK||'.'||l_api_name
                                     ,p_msg_text => 'Total Errors : ' ||
                                                     TO_CHAR(v_msg_list.COUNT));

         -- Log all of the messages
         FOR i IN 1..v_msg_list.COUNT LOOP

            FEM_ENGINES_PKG.Tech_Message( p_severity => g_log_level_5
                                         ,p_module   => G_BLOCK||'.'||l_api_name
                                         ,p_msg_text => v_msg_list(i));

            FND_FILE.Put_Line(FND_FILE.log, v_msg_list(i));
         END LOOP;

         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_ENG_MULTI_PROC_ERR);

         Process_Obj_Exec_Step(
                p_request_id      => l_request_id
               ,p_user_id         => l_user_id
               ,p_login_id        => l_login_id
               ,p_rule_obj_id     => p_rule_obj_id
               ,p_exe_step        => 'PROSP_IDENT'
               ,p_exe_status_code => g_exec_status_error_rerun
               ,p_tbl_name        => 'FEM_REGION_INFO');

         RAISE e_process_single_rule_error;

      ELSIF(l_err_msg = G_COMPLETE_NORMAL) THEN

         Process_Obj_Exec_Step( p_request_id      =>  l_request_id
                               ,p_user_id         =>  l_user_id
                               ,p_login_id        =>  l_login_id
                               ,p_rule_obj_id     =>  p_rule_obj_id
                               ,p_exe_step        =>  'PROSP_IDENT'
                               ,p_exe_status_code =>  g_exec_status_success
                               ,p_tbl_name        =>  'FEM_REGION_INFO');

         -- commit the work
         COMMIT;

         -- Purge Data Slices
         FEM_MULTI_PROC_PKG.Delete_Data_Slices (
            p_req_id => l_request_id);

      END IF;

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
           ,p_msg_text  => 'Prospect Identification Error:
                            Process Single Rule Exception');

         FEM_ENGINES_PKG.User_Message (p_app_name  => G_PFT
                                      ,p_msg_name  => G_ENG_SINGLE_RULE_ERR);

         x_return_status  := FND_API.G_RET_STS_ERROR;

      WHEN OTHERS THEN

         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Prospect Identification Error:
                            Process Single Rule Exception');

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
   PROCEDURE Update_Nbr_Of_Output_Rows( p_request_id       IN NUMBER
                                       ,p_user_id          IN NUMBER
                                       ,p_login_id         IN NUMBER
                                       ,p_rule_obj_id      IN NUMBER
                                       ,p_num_output_rows  IN  NUMBER
                                       ,p_tbl_name         IN  VARCHAR2
                                       ,p_stmt_type        IN  VARCHAR2)
   IS

   l_api_name        CONSTANT    VARCHAR2(30) := 'Update_Num_Of_Output_Rows';

   l_return_status               VARCHAR2(2);
   l_msg_count                   NUMBER;
   l_msg_data                    VARCHAR2(240);

   e_upd_num_output_rows_error   EXCEPTION;

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
 |   Get_Nbr_RowsTable_For_Request
 |
 | DESCRIPTION
 |   To find the number rows processed by the request.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/
   PROCEDURE Get_Nbr_RowsTable_Request( x_rows_processed    OUT NOCOPY NUMBER,
                    x_rows_loaded       OUT NOCOPY NUMBER,
                    x_rows_rejected     OUT NOCOPY NUMBER,
                    p_request_id        IN  NUMBER)
   IS

   l_api_name      CONSTANT VARCHAR2(30) := 'Get_Nbr_RowsTable_Request';

   BEGIN

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      --Query the fem_mp_process_ctl_t table to get the number of rows
      --processed per request
      SELECT  NVL(SUM(rows_processed),0),
              NVL(SUM(rows_rejected),0),
	      NVL(SUM(rows_loaded),0)
        INTO  x_rows_processed,
	      x_rows_rejected,
	      x_rows_loaded
       FROM   fem_mp_process_ctl_t t
       WHERE  t.req_id = p_request_id
	 AND  t.process_num > 0;

      IF (x_rows_processed = 0) THEN
         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'No Rows returned by the SQL');

         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_ENG_NO_OP_ROWS_ERR);

         RAISE e_process_single_rule_error;
      END IF;

      FEM_ENGINES_PKG.Tech_Message( p_severity  => g_log_level_2
                                   ,p_module    => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text  => 'END');

   EXCEPTION
      WHEN OTHERS THEN

      RAISE;
   END Get_Nbr_RowsTable_Request;

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
                                   ,p_tbl_name        IN VARCHAR2)
   IS

   l_api_name           VARCHAR2(30);
   l_nbr_output_rows    NUMBER;
   l_nbr_input_rows     NUMBER;
   l_nbr_rejected_rows  NUMBER;
   l_nbr_loaded_rows    NUMBER;

   BEGIN
      l_api_name           := 'Process_Obj_Exec_Step';
      l_nbr_output_rows    := NULL;
      l_nbr_input_rows     := NULL;

      FEM_ENGINES_PKG.TECH_MESSAGE( p_severity => g_log_level_2
                                   ,p_module   => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text => 'BEGIN');

      FEM_ENGINES_PKG.TECH_MESSAGE(
         p_severity => g_log_level_3
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Update the status of the step with execution status :'
                       ||p_exe_status_code);

      --update the status of the step
      Update_Obj_Exec_Step_Status( p_request_id       => p_request_id
                                  ,p_user_id          => p_user_id
                                  ,p_login_id         => p_login_id
                                  ,p_rule_obj_id      => p_rule_obj_id
                                  ,p_exe_step         => 'PROSP_IDENT'
                                  ,p_exe_status_code  => p_exe_status_code );

      IF (p_exe_status_code = g_exec_status_success) THEN
         -- query table fem_mp_process_ctl_t to get the number of rows processed
         Get_Nbr_RowsTable_Request(x_rows_processed => l_nbr_output_rows,
                                   x_rows_loaded    => l_nbr_loaded_rows,
                                   x_rows_rejected  => l_nbr_rejected_rows,
                                   p_request_id     => p_request_id);

         --update the number of output rows processed succesfully
         --in the registered table
         FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Rows processed for registered output table :'
                          ||p_tbl_name);

         -- update the number of rows processed in the registered table
         Update_Nbr_Of_Output_Rows(p_request_id       =>  p_request_id
                                  ,p_user_id          =>  p_user_id
                                  ,p_login_id         =>  p_login_id
                                  ,p_rule_obj_id      =>  p_rule_obj_id
                                  ,p_num_output_rows  =>  l_nbr_loaded_rows
                                  ,p_tbl_name         =>  p_tbl_name
                                  ,p_stmt_type        =>  g_insert );

         -----------------------------------------------------------------------
         -- Call FEM_PL_PKG.update_num_of_input_rows();
         -----------------------------------------------------------------------
         FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => g_log_level_1,
            p_module   => G_BLOCK||'.'||l_api_name,
            p_msg_text => 'No:of Rows processed from input table'
                          ||l_nbr_input_rows);

         -- update the number of rows processed in the registered table
         Update_Nbr_Of_Input_Rows(  p_request_id        =>  p_request_id
                                   ,p_user_id           =>  p_user_id
                                   ,p_last_update_login =>  p_login_id
                                   ,p_rule_obj_id       =>  p_rule_obj_id
                                   ,p_num_of_input_rows =>  l_nbr_input_rows);

         FEM_ENGINES_PKG.User_Message(p_app_name => G_PFT,
                                      p_msg_name => 'PFT_PPROF_PIDNT_ROW_SUMMARY',
                                      p_token1   => 'ROWSP',
                                      p_value1   => l_nbr_output_rows,
                                      p_token2   => 'ROWSL',
                                      p_value2   => l_nbr_loaded_rows);

      END IF;

      FEM_ENGINES_PKG.TECH_MESSAGE( p_severity => g_log_level_2
                                   ,p_module   => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text => 'END');

   EXCEPTION
      WHEN OTHERS THEN
      RAISE e_process_single_rule_error;

   END;

/*=============================================================================+
 | FUNCTION
 |   Create Prospect Identification Statement
 |
 | DESCRIPTION
 |   Creates the Bulk SQL for Prospect Identification
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

   FUNCTION Create_Prospect_Ident_Stmt ( p_rule_obj_id            IN NUMBER
                                        ,p_table_name             IN VARCHAR2
                                        ,p_cal_period_id          IN NUMBER
                                        ,p_effective_date         IN VARCHAR2
                                        ,p_dataset_code           IN NUMBER
                                        ,p_ledger_id              IN NUMBER
                                        ,p_source_system_code     IN NUMBER
                                        ,p_value_set_id           IN NUMBER)
   RETURN LONG IS

   l_api_name       CONSTANT    VARCHAR2(30) := 'Create_Prospect_Ident_Stmt';

   l_update_head_stmt           LONG;
   l_select_stmt                LONG;
   l_where_stmt                 LONG;
   l_sub_query_stmt             LONG;
   l_request_id                 NUMBER;
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(500);
   l_return_status              VARCHAR2(20);
   l_effective_date             DATE;
   l_user_id                    NUMBER;
   l_login_id                   NUMBER := FND_GLOBAL.login_id;

   BEGIN
      l_request_id             :=  FND_GLOBAL.Conc_Request_Id;
      l_user_id                :=  FND_GLOBAL.User_Id;
      l_effective_date         :=  FND_DATE.Canonical_To_Date(p_effective_date);

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      l_update_head_stmt := ' UPDATE FEM_CUSTOMERS_ATTR attr' ||
                            ' SET ' ||
                            ' attr.VARCHAR_ASSIGN_VALUE '||
                            ' = ' ||
                            'fem_prospect_ident_s.NEXTVAL';

      l_where_stmt :=       ' WHERE ' ||
                            ' CUSTOMER_ID IN ( ';

      l_select_stmt :=      ' SELECT ' ||
                            ' CUSTOMER_ID ' ||
                            ' FROM FEM_CUSTOMERS_B FCB'||
                            ' WHERE FCB.CUSTOMER_ID NOT IN ( '||
                            ' SELECT DISTINCT CUSTOMER_ID '||
                            ' FROM FEM_CUSTOMER_PROFIT FCP'||
                            ' WHERE LEDGER_ID =' || p_ledger_id ||
                            ' AND SOURCE_SYSTEM_CODE ='|| p_source_system_code ||
                            ' AND cal_period_id = ' || p_cal_period_id ||
                            ' AND dataset_code = ' || p_dataset_code ||
                            ' AND DATA_AGGREGATION_TYPE_CODE =
                                                  ''CUSTOMER_AGGREGATION''';

      l_sub_query_stmt:=    ' ) ' ||
                            ' AND FCB.VALUE_SET_ID = '|| p_value_set_id || ' )'||
                            ' AND attr.ATTRIBUTE_ID = ( '||
                            ' SELECT att.ATTRIBUTE_ID '||
                            ' FROM FEM_CUSTOMERS_ATTR att, '||
                            ' FEM_DIM_ATTRIBUTES_B dim, '||
                            ' FEM_DIMENSIONS_B xdim '||
                            ' WHERE att.ATTRIBUTE_ID = dim.ATTRIBUTE_ID '||
                            ' AND dim.dimension_id = xdim.dimension_id '||
                            ' AND dim.ATTRIBUTE_VARCHAR_LABEL =
                                            ''FEM_PROSPECT_IDENT''' ||
                            ' AND xdim.dimension_varchar_label = ''CUSTOMER'''||
                            ') ';

      -- Creates the final where clause
      l_select_stmt := l_select_stmt || ' AND {{data_slice}} ';

      -- add mapped columns
      RETURN l_update_head_stmt || ' ' || l_where_stmt || ' ' || l_select_stmt || ' ' ||
             l_sub_query_stmt;

      FEM_ENGINES_PKG.Tech_Message ( p_severity => G_LOG_LEVEL_2
                                    ,p_module   => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text => 'END');

   EXCEPTION
      WHEN OTHERS THEN
      RAISE;

   END Create_Prospect_Ident_Stmt;

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

            FEM_ENGINES_PKG.Tech_Message ( p_severity => g_log_level_2
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

   l_api_name       CONSTANT    VARCHAR2(30) := 'Update_Num_Of_Input_Rows';

   l_return_status              VARCHAR2(2);
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(240);

   e_upd_num_input_rows_error   EXCEPTION;

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

 END PFT_PROFCAL_PROSP_IDENT_PUB;

/
