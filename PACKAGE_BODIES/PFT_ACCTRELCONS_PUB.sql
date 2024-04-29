--------------------------------------------------------
--  DDL for Package Body PFT_ACCTRELCONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PFT_ACCTRELCONS_PUB" AS
/* $Header: pftparcb.pls 120.9.12000000.2 2007/08/09 16:06:24 gdonthir ship $ */

--------------------------------------------------------------------------------
-- Declare package constants --
--------------------------------------------------------------------------------

   g_object_version_number    CONSTANT   NUMBER       :=  1;
   g_pkg_name                 CONSTANT   VARCHAR2(30) :=  'PFT_ACCTRELCONS_PUB';

   -- Constants for p_exec_status_code
   g_exec_status_error_rerun  CONSTANT   VARCHAR2(30) :=  'ERROR_RERUN';
   g_exec_status_success      CONSTANT   VARCHAR2(30) :=  'SUCCESS';

   --Constants for output table names being registered with fem_pl_pkg
   -- API register_table method.
   g_fem_customer_profit   CONSTANT   VARCHAR2(30) :=  'FEM_CUSTOMER_PROFIT';

   --constant for sql_stmt_type
   g_insert                CONSTANT   VARCHAR2(30) :=  'INSERT';


   g_default_fetch_limit   CONSTANT   NUMBER       :=  99999;

   g_log_level_1           CONSTANT   NUMBER       :=  FND_LOG.Level_Statement;
   g_log_level_2           CONSTANT   NUMBER       :=  FND_LOG.Level_Procedure;
   g_log_level_3           CONSTANT   NUMBER       :=  FND_LOG.Level_Event;
   g_log_level_4           CONSTANT   NUMBER       :=  FND_LOG.Level_Exception;
   g_log_level_5           CONSTANT   NUMBER       :=  FND_LOG.Level_Error;
   g_log_level_6           CONSTANT   NUMBER       :=  FND_LOG.Level_Unexpected;


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
  -- General account consolidation Engine Exception
   e_arc_engine_error           EXCEPTION;
   USER_EXCEPTION               EXCEPTION;


--------------------------------------------------------------------------------
-- Declare private procedures and functions --
--------------------------------------------------------------------------------

   PROCEDURE Eng_Master_Prep (
     p_obj_id                        IN NUMBER
     ,p_dataset_io_obj_def_id        IN NUMBER
     ,p_effective_date               IN VARCHAR2
     ,p_output_cal_period_id         IN NUMBER
     ,p_ledger_id                    IN NUMBER
     ,p_continue_process_on_err_flg  IN VARCHAR2
     ,p_source_system_code           IN NUMBER
     ,x_param_rec                    OUT NOCOPY param_record
   );

   PROCEDURE Preprocess_Rule_Set (
     p_param_rec                     IN param_record
   );

   PROCEDURE Process_Single_Rule (
     p_param_rec                     IN OUT NOCOPY param_record
   );

   PROCEDURE Register_Process_Request (
     p_param_rec                     IN param_record
   );

   PROCEDURE Get_Object_Definition (
     p_object_type_code              IN VARCHAR2
     ,p_object_id                    IN NUMBER
     ,p_effective_date               IN DATE
     ,x_obj_def_id                   OUT NOCOPY NUMBER
   );

   PROCEDURE Register_Obj_Exe_Step(
     p_param_rec                     IN param_record
     ,p_exe_step                     IN VARCHAR2
     ,p_exe_status_code              IN VARCHAR2
   );

   PROCEDURE Register_Table(
     p_param_rec                     IN param_record
     ,p_tbl_name                     IN VARCHAR2
     ,p_num_output_rows              IN NUMBER
     ,p_stmt_type                    IN VARCHAR2
   );

   PROCEDURE Update_Nbr_Of_Output_Rows(
     p_param_rec                     IN param_record
     ,p_num_output_rows              IN NUMBER
     ,p_tbl_name                     IN VARCHAR2
     ,p_stmt_type                    IN VARCHAR2
   );

   PROCEDURE Update_Obj_Exec_Step_Status(
     p_param_rec                     IN param_record
     ,p_exe_step                     IN VARCHAR2
     ,p_exe_status_code              IN VARCHAR2
   );

   PROCEDURE Get_Nbr_RowsTable_Request(x_rows_processed OUT NOCOPY NUMBER,
                                       x_rows_loaded    OUT NOCOPY NUMBER,
                                       x_rows_rejected  OUT NOCOPY NUMBER,
                                       p_request_id     IN NUMBER,
                                       p_sec_relns_flag IN VARCHAR2);

   PROCEDURE Process_Obj_Exec_Step(
     p_param_rec                     IN OUT NOCOPY param_record
     ,p_exe_step                     IN VARCHAR2
     ,p_exe_status_code              IN VARCHAR2
     ,p_tbl_name                     IN VARCHAR2
   );

   PROCEDURE Eng_Master_Post_Proc (
     p_param_rec                     IN param_record
     ,p_exec_status_code             IN VARCHAR2
   );

   PROCEDURE Get_Put_Messages (
     p_msg_count                     IN NUMBER
     ,p_msg_data                     IN VARCHAR2
   );

   PROCEDURE add_secondary_relation(
     p_select_col                    IN OUT NOCOPY LONG
     ,p_from_clause                  IN OUT NOCOPY LONG
     ,p_where_clause                 IN OUT NOCOPY LONG
   );

   FUNCTION is_rule_set_flattened(
     p_request_id                    IN NUMBER
     ,p_rule_set_obj_id              IN NUMBER
   )
   RETURN NUMBER;

   FUNCTION Create_Consolidation_Stmt (
     p_rule_obj_id                   IN NUMBER
     ,p_table_name                   IN VARCHAR2
     ,p_cal_period_id                IN NUMBER
     ,p_dataset_io_obj_def_id        IN NUMBER
     ,p_effective_date               IN VARCHAR2
     ,p_ledger_id                    IN NUMBER
     ,p_condition_obj_id             IN NUMBER
     ,p_source_system_code           IN NUMBER
     ,p_secondary_flag               IN VARCHAR2
     ,p_col_obj_def_id               IN NUMBER
   )
   RETURN LONG;

   PROCEDURE Update_Nbr_Of_Input_Rows(
     p_param_rec                     IN  param_record
     ,p_num_input_rows               IN  NUMBER
   );

   PROCEDURE Register_Dependent_Objects(
     p_param_rec                     IN param_record
   );

 -------------------------------------------------------------------------------
 -- Package bodies for functions/procedures
 -------------------------------------------------------------------------------
 /*============================================================================+
 | PROCEDURE
 |   PROCESS REQUEST
 |
 | DESCRIPTION
 |   Main engine procedure for account relationship consolidation step in PFT.
 |
 | SCOPE - PUBLIC
 |
 +============================================================================*/

  PROCEDURE Process_Request ( Errbuf                        OUT NOCOPY VARCHAR2,
                              Retcode                       OUT NOCOPY NUMBER,
                              p_obj_id                      IN  NUMBER,
                              p_effective_date              IN  VARCHAR2,
                              p_ledger_id                   IN  NUMBER,
                              p_output_cal_period_id        IN  NUMBER,
                              p_dataset_grp_obj_def_id      IN  NUMBER,
                              p_continue_process_on_err_flg IN  VARCHAR2,
                              p_source_system_code          IN  NUMBER)
  IS

  -----------------------
  -- Declare constants --
  -----------------------
  l_api_name         CONSTANT  VARCHAR2(30) := 'Process_Request';

  -----------------------
  -- Declare variables --
  -----------------------
  x_return_status             VARCHAR2(1000);
  x_msg_count                 NUMBER;
  x_msg_data                  VARCHAR2 (1000);
  l_api_version               NUMBER;
  l_commit                    VARCHAR2(10);
  l_init_msg_list             VARCHAR2(10);
  l_param_rec                 param_record;
  l_proc_param_rec            param_record;
  l_object_type_code          VARCHAR2(30);
  l_rule_set_obj_def_id       NUMBER;
  l_rule_set_name             VARCHAR2(255);
  l_next_rule_obj_id          NUMBER;
  l_next_rule_obj_def_id      NUMBER;
  l_next_rule_exec_seq        NUMBER;
  l_next_rule_exec_status     VARCHAR2(30);
  l_err_code                  NUMBER;
  l_msg_count                 NUMBER;
  l_err_msg                   VARCHAR2(500);
  l_msg_data                  VARCHAR2(500);
  l_return_status             VARCHAR2(500);
  l_ruleset_status            VARCHAR2(500);
  l_completion_status         BOOLEAN;
  l_rollup_sequence           NUMBER;
  l_rule_set_def_id           NUMBER;

  l_err_buf                   VARCHAR2(50);
  l_ret_code                  NUMBER;

  ----------------------------
  -- Declare static cursors --
  ----------------------------
  CURSOR l_rule_set_rules(p_request_id IN NUMBER
                         ,p_ruleset_obj_id IN NUMBER) IS
    /* SELECT p.child_obj_def_id,
            p.engine_execution_sequence,
            p.child_obj_id,
            x.exec_status_code
     FROM   fem_ruleset_process_data p,
            fem_pl_object_executions x
     WHERE  p.request_id = p_request_id AND
            p.request_id = x.request_id(+) AND
            p.rule_set_obj_id = p_rule_set_obj_id*/
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
  -----------------------------------------------------------
  -- Declare flags to keep track of which cursors are open --
  -----------------------------------------------------------
  l_rule_set_rules_is_open        BOOLEAN;

/*******************************************************************************
*                                                                              *
*                          ACCOUNT consolidation engine                        *
*                          Execution BLOCK                                     *
*                                                                              *
*******************************************************************************/

  BEGIN

     l_api_version   := 1.0;
     l_init_msg_list := FND_API.g_false;
     l_commit        := FND_API.g_false;

     --Initialize Local Parameters
     l_rule_set_rules_is_open   :=   FALSE;
     z_master_err_state         :=   FEM_UTILS.G_RSM_NO_ERR;

     -- initialize status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     fem_engines_pkg.tech_message( p_severity => g_log_level_2
                                  ,p_module   => G_BLOCK||l_api_name
                                  ,p_msg_text => 'BEGIN');

     -- initialize msg stack?
     IF FND_API.to_Boolean(NVL(l_init_msg_list,'F')) THEN
        FND_MSG_PUB.Initialize;
     END IF;

     ---------------------------------------------------------------------------
     -- Check for the required parameters
     ---------------------------------------------------------------------------

     IF (p_obj_id IS NULL OR p_dataset_grp_obj_def_id IS NULL OR
         p_effective_date IS NULL OR p_output_cal_period_id IS NULL OR
         p_ledger_id IS NULL) THEN

        fem_engines_pkg.user_message (
           p_app_name  => G_FEM
          ,p_msg_name => G_ENG_BAD_CONC_REQ_PARAM_ERR);
        RAISE e_arc_engine_error;
     END IF;

     --Do the engine master prep
     --------------------------------------------------------------------------
     -- STEP 1: Engine Master Preparation
     --------------------------------------------------------------------------

     fem_engines_pkg.tech_message (
        p_severity => g_log_level_2
       ,p_module   => G_BLOCK||'.'||l_api_name
       ,p_msg_text => 'Step 1: Engine Master Preperation');

     Eng_Master_Prep (
        p_obj_id                      =>  p_obj_id
       ,p_effective_date              =>  p_effective_date
       ,p_ledger_id                   =>  p_ledger_id
       ,p_output_cal_period_id        =>  p_output_cal_period_id
       ,p_dataset_io_obj_def_id       =>  p_dataset_grp_obj_def_id
       ,p_continue_process_on_err_flg =>  p_continue_process_on_err_flg
       ,p_source_system_code          =>  p_source_system_code
       ,x_param_rec                   =>  l_param_rec);

   -----------------------------------------------------------------------------
   -- STEP 2: registering process request for either a single rule or a rule set
   -----------------------------------------------------------------------------
     fem_engines_pkg.tech_message ( p_severity => g_log_level_3
                                   ,p_module   => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text => 'Step 2: Register Request');


     --Register request
     Register_Process_Request(p_param_rec => l_param_rec);

     IF (l_param_rec.obj_type_code = 'PPROF_ACCT_REL_CONS') THEN
        ------------------------------------------------------------------------
        -- STEP 3: Processing for a single rule submission
        ------------------------------------------------------------------------
        fem_engines_pkg.tech_message (
           p_severity => g_log_level_3
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 3: Process for a single rule ');

         --Set the current processing object id
        l_param_rec.crnt_proc_child_obj_id  := l_param_rec.obj_id;

        Process_Single_Rule( p_param_rec => l_param_rec);

         fem_engines_pkg.tech_message (
            p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Status After Process for a single rule '
	                  || l_param_rec.return_status);

        IF (l_param_rec.return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           -- For Single Consolidation Rule, raise exception to end request
           -- immediately with a completion status of ERROR,
           -- regardless of the value for the continue_process_on_err_flg
           -- parameter.
           RAISE e_arc_engine_error;
        END IF;

     ELSIF (l_param_rec.obj_type_code = 'RULE_SET') THEN
        ------------------------------------------------------------------------
        -- STEP 4: Processing for a rule set
        ------------------------------------------------------------------------
        ------------------------------------------------------------------------
        -- STEP 4.1: Flattening the rule set
        ------------------------------------------------------------------------
        fem_engines_pkg.tech_message(
           p_severity  => g_log_level_3
          ,p_module    => G_BLOCK||'.'||l_api_name
          ,p_msg_text  => 'Step 3.1 Flatten the rule set');

        IF (is_rule_set_flattened(l_param_rec.request_id
                                 ,l_param_rec.crnt_proc_child_obj_id) <> 0) THEN
           ---------------------------------------------------------------------
           -- STEP 4.2: Preprocess rule set
           ---------------------------------------------------------------------
           fem_engines_pkg.tech_message(
              p_severity  => g_log_level_1
             ,p_module    => G_BLOCK||'.'||l_api_name
             ,p_msg_text  => 'Step 4.2 PreProcess rule set' );

           PreProcess_Rule_Set(p_param_rec => l_param_rec);

        END IF;
        ------------------------------------------------------------------------
        -- STEP 4.3.1: Loop through each rule in the rule set
        -- STEP 4.3.2: Open cursor for rule set
        -- STEP 4.3.3: Process each rule in the rule set loop
        -- STEP 4.3.4: Execution status for rule processing
        ------------------------------------------------------------------------

        fem_engines_pkg.tech_message(
           p_severity => g_log_level_1
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 4.3.1: Loop through all Rule Set Rules');

        OPEN l_rule_set_rules(l_param_rec.request_id,l_param_rec.obj_id);

        l_rule_set_rules_is_open := TRUE;

        fem_engines_pkg.tech_message(
           p_severity => g_log_level_1
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 4.3.2:Rule set loop');

        LOOP
          FETCH l_rule_set_rules INTO l_next_rule_obj_id,
                                       l_next_rule_obj_def_id,
                                       l_next_rule_exec_status;

           fem_engines_pkg.tech_message(
              p_severity => g_log_level_1
             ,p_module   => G_BLOCK||'.'||l_api_name
             ,p_msg_text => 'Step 4.3.3: Process next rule in rule set: '
                            ||l_next_rule_obj_id);

           fem_engines_pkg.tech_message(
              p_severity => g_log_level_1
             ,p_module   => G_BLOCK||'.'||l_api_name
             ,p_msg_text => 'Step 4.3.4: Process next rule in rule set status:'
                            || l_next_rule_exec_status);

           EXIT WHEN l_rule_set_rules%NOTFOUND;

           l_rollup_sequence := l_rollup_sequence + 1;

           --update the param rec for the current
           --processing object_id and object_definition_id
           l_param_rec.crnt_proc_child_obj_id := l_next_rule_obj_id;
           l_param_rec.crnt_proc_child_obj_defn_id := l_next_rule_obj_def_id;

           IF (l_next_rule_exec_status IS NULL OR
               l_next_rule_exec_status <> 'SUCCESS') THEN
              ------------------------------------------------------------------
              -- STEP 4.2.3: Process Rule Set Rule
              ------------------------------------------------------------------

              fem_engines_pkg.tech_message(
                 p_severity => g_log_level_1
                ,p_module   => G_BLOCK||'.'||l_api_name
                ,p_msg_text => 'Step 4.3.5: Process Rule Set Rule #'
		                ||TO_CHAR(l_rollup_sequence));

              /*      Get_Object_Definition(
               p_object_type_code => 'PPROF_ACCT_REL_CONS'
              ,p_object_id        => l_param_rec.crnt_proc_child_obj_id
              ,p_effective_date   => l_param_rec.effective_date
              ,x_obj_def_id       => l_param_rec.crnt_proc_child_obj_defn_id);*/

              Process_Single_Rule( p_param_rec => l_param_rec );

              fem_engines_pkg.tech_message (
                 p_severity => g_log_level_3
                ,p_module   => G_BLOCK||'.'||l_api_name
                ,p_msg_text => 'Status After Process for a single rule '
                               || l_param_rec.return_status);

              IF (l_param_rec.return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                 -- Set the request status to match Consolidation Rule's
                 -- return status.
                 l_ruleset_status := l_param_rec.return_status;
                 IF (l_param_rec.continue_process_on_err_flg = 'N') THEN
                    -- Raise exception to end request immediately with a
		    -- completion status of ERROR.
                    RAISE e_arc_engine_error;
                 END IF;
              END IF;
           END IF;
        END LOOP;

        CLOSE l_rule_set_rules;

        IF (l_ruleset_status <> FND_API.G_RET_STS_SUCCESS) THEN
           -- Raise exception to end request with a completion status of ERROR,
           -- if the rule set status is not equal to SUCCESS.
           RAISE e_arc_engine_error;
        END IF;

     ELSE
        NULL;
     END IF;

     ---------------------------------------------------------------------------
     -- STEP 5: Engine Master Post Processing.
     ---------------------------------------------------------------------------
     fem_engines_pkg.tech_message (
        p_severity => g_log_level_3
       ,p_module   => G_BLOCK||'.'||l_api_name
       ,p_msg_text => 'Step 5: Engine Master Post Processing');

     Eng_Master_Post_Proc ( p_param_rec         => l_param_rec
                           ,p_exec_status_code  => g_exec_status_success);

     ---------------------------------------------------------------------------
     -- STEP 6: Standard API support
     ---------------------------------------------------------------------------
     IF FND_API.To_Boolean(NVL(l_commit,'F')) THEN
        COMMIT WORK;
     END IF;

    /*   IF (l_rule_set_rules_is_open) THEN
        CLOSE l_rule_set_rules;
     END IF;*/
     IF (l_rule_set_rules%ISOPEN) THEN
        CLOSE l_rule_set_rules;
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     fem_engines_pkg.tech_message ( p_severity => g_log_level_2
                                   ,p_module   => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text => 'END');

  EXCEPTION
     WHEN e_arc_engine_error THEN
        --close the open cursors
         /*    IF (l_rule_set_rules_is_open) THEN
           CLOSE l_rule_set_rules;
        END IF;*/
        IF (l_rule_set_rules%ISOPEN) THEN
          CLOSE l_rule_set_rules;
        END IF;

        fem_engines_pkg.tech_message (
           p_severity => g_log_level_3
          ,p_module   => G_BLOCK||'.'||l_api_name
          ,p_msg_text => 'Step 5: Engine Master Post Processing: ERROR');

        Eng_Master_Post_Proc( p_param_rec        => l_param_rec
                             ,p_exec_status_code => g_exec_status_error_rerun);

        l_completion_status := Fnd_Concurrent.Set_Completion_Status( 'ERROR'
                                                                     ,NULL);

        fem_engines_pkg.tech_message (
           p_severity  => g_log_level_5
          ,p_module    => G_BLOCK||'.'||l_api_name
          ,p_msg_text  => 'Account consolidation Engine Error');

        --fem_engines_pkg.user_message (
        --   p_app_name => G_PFT
        --  ,p_msg_text => 'Account consolidation Engine Error');

        -- Set the return status to ERROR
        x_return_status := FND_API.G_RET_STS_ERROR;

     WHEN OTHERS THEN
        gv_prg_msg := SQLERRM;
        gv_callstack := DBMS_UTILITY.Format_Call_Stack;

         --close the open cursors
         /*      IF (l_rule_set_rules_is_open) THEN
            CLOSE l_rule_set_rules;
         END IF;*/

        IF (l_rule_set_rules%ISOPEN) THEN
          CLOSE l_rule_set_rules;
        END IF;

         fem_engines_pkg.tech_message (
            p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Step 5: Engine Master Post Processing: ERROR');

         Eng_Master_Post_Proc( p_param_rec        => l_param_rec
                              ,p_exec_status_code => g_exec_status_error_rerun);

         l_completion_status := Fnd_Concurrent.Set_Completion_Status( 'ERROR'
	                                                              ,NULL);

         fem_engines_pkg.tech_message (
            p_severity => g_log_level_6
           ,p_module   => G_BLOCK||'.'||l_api_name||'.Unexpected Exception'
           ,p_msg_text => gv_prg_msg);

         fem_engines_pkg.tech_message (
            p_severity => g_log_level_6
           ,p_module   => G_BLOCK||'.'||l_api_name||'.Unexpected Exception'
           ,p_msg_text => gv_callstack);

         fem_engines_pkg.user_message (
            p_app_name => G_FEM
           ,p_msg_name => G_UNEXPECTED_ERROR
           ,p_token1   => 'ERR_MSG'
           ,p_value1   => gv_prg_msg);

         -- Set the return status to UNEXP_ERROR
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END Process_Request;

 /*============================================================================+
 |PROCEDURE
 |   Eng_Master_Prep
 |DESCRIPTION
 |   Prepares the Engine Master, Initializes all the variables.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

  PROCEDURE Eng_Master_Prep (
     p_obj_id                      IN  NUMBER
    ,p_dataset_io_obj_def_id       IN  NUMBER
    ,p_effective_date              IN  VARCHAR2
    ,p_output_cal_period_id        IN  NUMBER
    ,p_ledger_id                   IN  NUMBER
    ,p_continue_process_on_err_flg IN  VARCHAR2
    ,p_source_system_code          IN  NUMBER
    ,x_param_rec                   OUT NOCOPY param_record)
  IS

   l_api_name           CONSTANT   VARCHAR2(30) := 'Eng_Master_Prep';
   l_dummy_varchar                 VARCHAR2(30);
   l_dummy_date                    DATE;
   l_err_code                      NUMBER;
   l_err_msg                       VARCHAR2(30);
   l_folder_name                   VARCHAR2(100);
   l_effective_date                DATE;

   e_eng_master_prep_error         EXCEPTION;

   BEGIN

      fem_engines_pkg.tech_message ( p_severity => g_log_level_2
                                    ,p_module   => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text => 'BEGIN');

      --------------------------------------------------------------------------
      -- Set all the Main Parameters
      --------------------------------------------------------------------------
      x_param_rec.obj_id                      :=  p_obj_id;
      x_param_rec.dataset_io_obj_def_id       :=  p_dataset_io_obj_def_id;
      x_param_rec.output_cal_period_id        :=  p_output_cal_period_id;
      x_param_rec.ledger_id                   :=  p_ledger_id;
      x_param_rec.effective_date_varchar      :=  p_effective_date;
      x_param_rec.effective_date              :=
        FND_DATE.Canonical_To_Date(p_effective_date);
      x_param_rec.source_system_code          :=  p_source_system_code;
      x_param_rec.continue_process_on_err_flg :=  p_continue_process_on_err_flg;

      --------------------------------------------------------------------------
      -- Set all the Global Parameters
      --------------------------------------------------------------------------
      x_param_rec.user_id     :=  FND_GLOBAL.user_id;
      x_param_rec.login_id    :=  FND_GLOBAL.login_id;
      x_param_rec.request_id  :=  FND_GLOBAL.conc_request_id;
      x_param_rec.resp_id     :=  FND_GLOBAL.resp_id;
      x_param_rec.pgm_id      :=  FND_GLOBAL.conc_program_id;
      x_param_rec.pgm_app_id  :=  FND_GLOBAL.prog_appl_id;

      -- Get the limit for bulk fetches
      gv_fetch_limit :=  NVL (FND_PROFILE.Value_Specific ('FEM_BULK_FETCH_LIMIT'
                                                          ,x_param_rec.user_id
                                                          ,NULL
                                                          ,NULL)
                             ,g_default_fetch_limit);

    ----------------------------------------------------------------------------
    -- Get the object info from fem_object_catalog_b for the object_id passed in
    ----------------------------------------------------------------------------
      fem_engines_pkg.tech_message (
         p_severity => g_log_level_3
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Getting the Object Type Code of the given Object');

      BEGIN
         SELECT  object_type_code
                ,local_vs_combo_id
           INTO  x_param_rec.obj_type_code
                ,x_param_rec.local_vs_combo_id
         FROM    fem_object_catalog_b
         WHERE   object_id = x_param_rec.obj_id;

      EXCEPTION
         WHEN OTHERS THEN
            fem_engines_pkg.user_message (
               p_app_name => G_PFT
              ,p_msg_name => G_ENG_INVALID_OBJ_ERR
              ,p_token1   => 'OBJECT_ID'
              ,p_value1   => x_param_rec.obj_id);

            fem_engines_pkg.tech_message (
               p_severity => g_log_level_3
              ,p_module   => G_BLOCK||'.'||l_api_name
              ,p_msg_text => 'Invalid Object Id' || x_param_rec.obj_id);

         RAISE e_eng_master_prep_error;
      END;

      --------------------------------------------------------------------------
      -- If this is a Rule Set Submission, check that the object_type_code and
      -- local_vs_combo_id of the rollup rule matches the Rule Set's.
      --------------------------------------------------------------------------
      IF (x_param_rec.obj_type_code = 'RULE_SET') THEN

         fem_engines_pkg.tech_message (
            p_severity  => g_log_level_3
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Obj type code is a rule set');

         BEGIN
            Get_Object_Definition(
	       p_object_type_code => x_param_rec.obj_type_code
	      ,p_object_id        => x_param_rec.obj_id
	      ,p_effective_date   => x_param_rec.effective_date
	      ,x_obj_def_id       => x_param_rec.crnt_proc_child_obj_defn_id);

            EXCEPTION
               WHEN OTHERS THEN
                  fem_engines_pkg.user_message (
                     p_app_name  => G_PFT
                    ,p_msg_name  => G_ENG_INV_OBJ_DEFN_RS_ERR
                    ,p_token1    => 'OBJECT_ID'
                    ,p_value1    => x_param_rec.obj_id
                    ,p_token2    => 'EFFECTIVE_DATE'
                    ,p_value2    => x_param_rec.effective_date);

                  fem_engines_pkg.tech_message (
                     p_severity  => g_log_level_3
                    ,p_module    => G_BLOCK||'.'||l_api_name
                    ,p_msg_text  => 'No Definition found for the ruleset :'
                                    || x_param_rec.obj_id || 'for the Date :'
                                    || x_param_rec.effective_date);

               RAISE e_eng_master_prep_error;
         END;

      ELSIF (x_param_rec.obj_type_code =  'PPROF_ACCT_REL_CONS') THEN

         fem_engines_pkg.tech_message (
            p_severity  => g_log_level_3
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Objext type code is a single rule');

         l_Effective_Date := FND_DATE.CANONICAL_TO_DATE(p_Effective_Date);

         BEGIN

            Get_Object_Definition(
	       p_object_type_code => x_param_rec.obj_type_code
	      ,p_object_id        => x_param_rec.obj_id
	      ,p_effective_date   => x_param_rec.effective_date
	      ,x_obj_def_id       => x_param_rec.crnt_proc_child_obj_defn_id);

         EXCEPTION
            WHEN OTHERS THEN
               fem_engines_pkg.user_message (
                  p_app_name  => G_PFT
                 ,p_msg_name  => G_ENG_INVALID_OBJ_DEFN_ERR
                 ,p_token1    => 'OBJECT_ID'
                 ,p_value1    => x_param_rec.obj_id
                 ,p_token2    => 'EFFECTIVE_DATE'
                 ,p_value2    => x_param_rec.effective_date);

               fem_engines_pkg.tech_message (
                  p_severity  => g_log_level_3
                 ,p_module    => G_BLOCK||'.'||l_api_name
                 ,p_msg_text  => 'No Definition found for the Rule :'
                                 || x_param_rec.obj_id || 'for the Date :'
                                 || x_param_rec.effective_date);
            RAISE e_eng_master_prep_error;
         END;
      ELSE
         fem_engines_pkg.user_message(
            p_app_name  => G_PFT
           ,p_msg_name  => G_ENG_INVALIDRULETYPE_ERR
           ,p_token1    => 'OBJECT_TYPE_CODE'
           ,p_value1    => x_param_rec.obj_type_code);

         RAISE e_eng_master_prep_error;

      END IF;

      fem_engines_pkg.tech_message (
         p_severity  => g_log_level_3
        ,p_module    => G_BLOCK||'.'||l_api_name
        ,p_msg_text  => 'Get the Dataset Group Object Id:');
      --------------------------------------------------------------------------
      -- Get the Dataset Group Object ID
      --------------------------------------------------------------------------
      BEGIN
         SELECT object_id
           INTO x_param_rec.dataset_grp_obj_id
         FROM   fem_object_definition_b
         WHERE  object_definition_id = x_param_rec.dataset_io_obj_def_id;
      EXCEPTION
         WHEN OTHERS THEN
            fem_engines_pkg.user_message (
               p_app_name => G_PFT
              ,p_msg_name => G_ENG_INVALID_OBJ_ERR
              ,p_token1   => 'OBJECT_ID'
              ,p_value1   => x_param_rec.dataset_io_obj_def_id);

            fem_engines_pkg.tech_message (
               p_severity  => g_log_level_3
              ,p_module    => G_BLOCK||'.'||l_api_name
              ,p_msg_text  => 'No Object found for the given Dataset Group:'
                              || x_param_rec.dataset_io_obj_def_id);
         RAISE e_eng_master_prep_error;
      END;

      --------------------------------------------------------------------------
      -- Get the Output Dataset Code
      --------------------------------------------------------------------------
      fem_engines_pkg.tech_message (
         p_severity  => g_log_level_3
        ,p_module    => G_BLOCK||'.'||l_api_name
        ,p_msg_text  => 'Getting the output DS Code for the given DS Group');

      BEGIN
         SELECT output_dataset_code
           INTO x_param_rec.output_dataset_code
         FROM   fem_ds_input_output_defs
         WHERE  dataset_io_obj_def_id = x_param_rec.dataset_io_obj_def_id;
      EXCEPTION
         WHEN OTHERS THEN
            fem_engines_pkg.user_message (
               p_app_name => G_PFT
              ,p_msg_name => G_ENG_NO_OUTPUT_DS_ERR
              ,p_token1   => 'DATASET_GROUP_OBJ_DEF_ID'
              ,p_value1   => x_param_rec.dataset_io_obj_def_id);

            fem_engines_pkg.tech_message (
               p_severity  => g_log_level_3
              ,p_module    => G_BLOCK||'.'||l_api_name
              ,p_msg_text  => 'No Output Dataset for the DS Group Definition:'
                              || x_param_rec.dataset_grp_name);

         RAISE e_eng_master_prep_error;
      END;

      --------------------------------------------------------------------------
      -- Get the Source System Code for PFT if a null param value was passed.
      --------------------------------------------------------------------------
      IF (x_param_rec.source_system_code IS NULL) THEN

         -- For all Processing default the Source System Display Code to PFT
         BEGIN
            SELECT source_system_code
              INTO x_param_rec.source_system_code
            FROM   fem_source_systems_b
            WHERE  source_system_display_code = G_PFT;

         EXCEPTION
            WHEN OTHERS THEN
               fem_engines_pkg.user_message (
                  p_app_name  => G_PFT
                 ,p_msg_name  => G_ENG_INVALID_OBJ_ERR
                 ,p_token1   => 'OBJECT_ID'
                 ,p_value1   => x_param_rec.obj_id);

            RAISE e_eng_master_prep_error;
         END;

      END IF;

      -- Log all Request Record Parameters if we have low level debugging
      IF ( FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) ) THEN

         fem_engines_pkg.tech_message (
            p_severity  => G_LOG_LEVEL_1
           ,p_module   => G_BLOCK||'.'||l_api_name||'.x_param_rec'
           ,p_msg_text =>
           ' dataset_grp_obj_def_id='||x_param_rec.dataset_io_obj_def_id||
           ' dataset_grp_obj_id='||x_param_rec.dataset_grp_obj_id||
           ' effective_date='||
	     FND_DATE.date_to_chardate(x_param_rec.effective_date)||
           ' ledger_id='||x_param_rec.ledger_id||
           ' local_vs_combo_id='||x_param_rec.local_vs_combo_id||
           ' login_id='||x_param_rec.login_id||
           ' output_cal_period_id='||x_param_rec.output_cal_period_id||
           ' output_dataset_code='||x_param_rec.output_dataset_code||
           ' pgm_app_id='||x_param_rec.pgm_app_id||
           ' pgm_id='||x_param_rec.pgm_id||
           ' resp_id='||x_param_rec.resp_id||
           ' request_id='||x_param_rec.request_id||
           ' obj_type_code='||x_param_rec.obj_type_code||
           ' ruleset_obj_def_id='||x_param_rec.crnt_proc_child_obj_defn_id||
           ' ruleset_obj_id='||x_param_rec.obj_id||
           ' source_system_code='||x_param_rec.source_system_code||
           ' submit_obj_id='||x_param_rec.obj_id||
           ' submit_obj_type_code='||x_param_rec.obj_type_code||
           ' user_id='||x_param_rec.user_id);

      END IF;

      fem_engines_pkg.tech_message ( p_severity => G_LOG_LEVEL_2
                                    ,p_module   => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text => 'END');

   EXCEPTION
      WHEN e_eng_master_prep_error THEN

         fem_engines_pkg.tech_message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Engine Master Preperation Exception');
         RAISE e_arc_engine_error;

   END Eng_Master_Prep;

 /*============================================================================+
 | PROCEDURE
 |   Register_Process_Request
 |
 | DESCRIPTION
 |   Registers the request for the object in processing locks tables.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

   PROCEDURE Register_Process_Request ( p_param_rec          IN param_record )

   IS

   l_api_name            CONSTANT VARCHAR2(30) := 'Register_Process_Request';

   l_exec_state                   VARCHAR2(30); -- normal, restart, rerun
   l_return_status                VARCHAR2(1);
   l_msg_count                    NUMBER;
   l_msg_data                     VARCHAR2(240);

   e_pl_register_request_error    EXCEPTION;

   BEGIN

      fem_engines_pkg.tech_message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      SAVEPOINT register_request_pub;

      -- Call the FEM_PL_PKG.Register_Request API procedure to register
      -- the concurrent request in FEM_PL_REQUESTS.
      FEM_PL_PKG.Register_Request(
         p_api_version            =>  G_CALLING_API_VERSION
        ,p_commit                 =>  FND_API.G_FALSE
        ,p_cal_period_id          =>  p_param_rec.output_cal_period_id
        ,p_ledger_id              =>  p_param_rec.ledger_id
        ,p_dataset_io_obj_def_id  =>  p_param_rec.dataset_io_obj_def_id
        ,p_output_dataset_code    =>  p_param_rec.output_dataset_code
        ,p_source_system_code     =>  p_param_rec.source_system_code
        ,p_effective_date         =>  p_param_rec.effective_date
        ,p_rule_set_obj_def_id    =>  p_param_rec.crnt_proc_child_obj_defn_id
        ,p_request_id             =>  p_param_rec.request_id
        ,p_user_id                =>  p_param_rec.user_id
        ,p_last_update_login      =>  p_param_rec.login_id
        ,p_program_id             =>  p_param_rec.pgm_id
        ,p_program_login_id       =>  p_param_rec.login_id
        ,p_program_application_id =>  p_param_rec.pgm_app_id
        ,p_exec_mode_code         =>  NULL
        ,p_dimension_id           =>  NULL
        ,p_table_name             =>  NULL
        ,p_hierarchy_name         =>  NULL
        ,x_msg_count              =>  l_msg_count
        ,x_msg_data               =>  l_msg_data
        ,x_return_status          =>  l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         Get_Put_Messages ( p_msg_count => l_msg_count
                           ,p_msg_data  => l_msg_data);

          RAISE  e_pl_register_request_error;
      END IF;

      COMMIT;

      fem_engines_pkg.tech_message (
         p_severity => g_log_level_1
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Request id is '||p_param_rec.request_id);

      fem_engines_pkg.tech_message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'END');

   EXCEPTION
      WHEN e_pl_register_request_error THEN

         ROLLBACK TO register_request_pub;

         fem_engines_pkg.tech_message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Register Request Exception');

         fem_engines_pkg.user_message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_REG_REQUEST_ERR
           ,p_token1    => 'REQUEST_ID'
           ,p_value1    => p_param_rec.request_id);

         RAISE e_arc_engine_error;

      WHEN OTHERS THEN

         ROLLBACK TO register_request_pub;

         fem_engines_pkg.user_message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_REG_REQUEST_ERR
           ,p_token1    => 'REQUEST_ID'
           ,p_value1    => p_param_rec.request_id);

         RAISE e_arc_engine_error;

   END Register_Process_Request;


 /*============================================================================+
 | PROCEDURE
 |   Register_Object_Definition
 |
 | DESCRIPTION
 |   Registers the specified object definition in FEM_PL_OBJECT_DEFS,
 |   thus obtaining an object definition lock.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

   PROCEDURE Register_Object_Definition ( p_param_rec           IN param_record
                                         ,p_object_id           IN NUMBER
                                         ,p_obj_def_id          IN NUMBER)
   IS

   l_api_name             CONSTANT VARCHAR2(30) := 'Register_Object_Definition';

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(240);

   e_register_obj_def_error        EXCEPTION;

   BEGIN

      fem_engines_pkg.tech_message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      -- Call the FEM_PL_PKG.Register_Object_Def API procedure to register
      -- the specified object definition in FEM_PL_OBJECT_DEFS, thus obtaining
      -- an object definition lock.
      FEM_PL_PKG.Register_Object_Def (
            p_api_version          => 1.0
           ,p_commit               => FND_API.G_TRUE
           ,p_request_id           => p_param_rec.request_id
           ,p_object_id            => p_object_id
           ,p_object_definition_id => p_obj_def_id
           ,p_user_id              => p_param_rec.user_id
           ,p_last_update_login    => p_param_rec.login_id
           ,x_msg_count            => l_msg_count
           ,x_msg_data             => l_msg_data
           ,x_return_status        => l_return_status);

      -- Object Definition Lock exists
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

         Get_Put_Messages ( p_msg_count => l_msg_count
                           ,p_msg_data  => l_msg_data);
         RAISE e_register_obj_def_error;
      END IF;

      fem_engines_pkg.tech_message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'END');

   EXCEPTION
      WHEN e_register_obj_def_error THEN
         fem_engines_pkg.tech_message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Register Object Definition Exception');

         fem_engines_pkg.user_message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_OBJ_EXECLOCK_EXISTS_ERR
           ,p_token1    => 'REQUEST_ID'
           ,p_value1    => p_param_rec.request_id);
         RAISE e_arc_engine_error;

   END Register_Object_Definition;

 /*============================================================================+
 | PROCEDURE
 |   Register_Obj_Exe_Step
 |
 | DESCRIPTION
 |   Registers the current step of execution in fem_pl_obj_steps
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/
   PROCEDURE Register_Obj_Exe_Step(p_param_rec       IN param_record
                                  ,p_exe_step        IN VARCHAR2
                                  ,p_exe_status_code IN VARCHAR2)
   IS

   l_api_name             CONSTANT VARCHAR2(30) := 'Register_Obj_Exe_Step';

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(240);

   e_register_obj_exe_step_error   EXCEPTION;

   BEGIN

      fem_engines_pkg.tech_message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      -- Call the FEM_PL_PKG.Register_Obj_Exec_Step API procedure
      -- to register step in fem_pl_obj_steps.
      FEM_PL_PKG.Register_Obj_Exec_Step (
            p_api_version         =>  1.0
           ,p_commit              =>  FND_API.G_TRUE
           ,p_request_id          =>  p_param_rec.request_id
           ,p_object_id           =>  p_param_rec.crnt_proc_child_obj_id
           ,p_exec_step           =>  p_exe_step
           ,p_exec_status_code    =>  p_exe_status_code
           ,p_user_id             =>  p_param_rec.user_id
           ,p_last_update_login   =>  p_param_rec.login_id
           ,x_msg_count           =>  l_msg_count
           ,x_msg_data            =>  l_msg_data
           ,x_return_status       =>  l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

         Get_Put_Messages ( p_msg_count => l_msg_count
                           ,p_msg_data  => l_msg_data);
         RAISE e_register_obj_exe_step_error;
      END IF;

      fem_engines_pkg.tech_message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'END');

   EXCEPTION
      WHEN e_register_obj_exe_step_error THEN
         fem_engines_pkg.tech_message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Register Obj Exec Step Exception');

         fem_engines_pkg.user_message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_REG_EXEC_STEP_ERR
           ,p_token1    => 'OBJECT_ID'
           ,p_value1    => p_param_rec.crnt_proc_child_obj_id);

      RAISE e_arc_engine_error;

      WHEN OTHERS THEN
         fem_engines_pkg.user_message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_REG_EXEC_STEP_ERR
           ,p_token1    => 'OBJECT_ID'
           ,p_value1    => p_param_rec.crnt_proc_child_obj_id);
      RAISE;

   END Register_Obj_Exe_Step;

 /*============================================================================+
 | PROCEDURE
 |   Register_Table
 |
 | DESCRIPTION
 |   Registers the output Table in fem_pl_tables.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

   PROCEDURE Register_Table( p_param_rec        IN param_record
                            ,p_tbl_name         IN VARCHAR2
                            ,p_num_output_rows  IN NUMBER
                            ,p_stmt_type        IN VARCHAR2)
   IS

   l_api_name             CONSTANT VARCHAR2(30) := 'Register_Table';

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(240);

   e_register_table_error          EXCEPTION;

   BEGIN

      fem_engines_pkg.tech_message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      -- Call the FEM_PL_PKG.Register_Table API procedure to register
      -- the specified output table and the statement type that will be used.
      FEM_PL_PKG.Register_Table(
          p_api_version          =>  1.0
         ,p_commit               =>  FND_API.G_TRUE
         ,p_request_id           =>  p_param_rec.request_id
         ,p_object_id            =>  p_param_rec.crnt_proc_child_obj_id
         ,p_table_name           =>  p_tbl_name
         ,p_statement_type       =>  p_stmt_type
         ,p_num_of_output_rows   =>  p_num_output_rows
         ,p_user_id              =>  p_param_rec.user_id
         ,p_last_update_login    =>  p_param_rec.login_id
         ,x_msg_count            =>  l_msg_count
         ,x_msg_data             =>  l_msg_data
         ,x_return_status        =>  l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

         Get_Put_Messages ( p_msg_count => l_msg_count
                           ,p_msg_data  => l_msg_data);
         RAISE e_register_table_error;
      END IF;

      fem_engines_pkg.tech_message( p_severity  => g_log_level_2
                                   ,p_module    => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text  => 'END');

   EXCEPTION
      WHEN e_register_table_error THEN
         fem_engines_pkg.tech_message(
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Register Table Exception');

         fem_engines_pkg.user_message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_REG_TABLE_ERR
           ,p_token1    => 'TABLE_NAME'
           ,p_value1    => p_tbl_name);

         RAISE e_arc_engine_error;

      WHEN OTHERS THEN
         fem_engines_pkg.user_message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_REG_TABLE_ERR
           ,p_token1    => 'TABLE_NAME'
           ,p_value1    => p_tbl_name);

      RAISE e_arc_engine_error;

   END Register_Table;

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
   PROCEDURE Update_Nbr_Of_Output_Rows( p_param_rec        IN  param_record
                                       ,p_num_output_rows  IN  NUMBER
                                       ,p_tbl_name         IN  VARCHAR2
                                       ,p_stmt_type        IN  VARCHAR2)
   IS

   l_api_name   CONSTANT VARCHAR2(30) := 'Update_Num_Of_Output_Rows';

   l_return_status       VARCHAR2(2);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(240);

   e_upd_num_output_rows_error     EXCEPTION;

   BEGIN

      fem_engines_pkg.tech_message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      -- Set the number of output rows for the output table.
      FEM_PL_PKG.Update_Num_Of_Output_Rows(
                p_api_version          =>  1.0
               ,p_commit               =>  FND_API.G_TRUE
               ,p_request_id           =>  p_param_rec.request_id
               ,p_object_id            =>  p_param_rec.crnt_proc_child_obj_id
               ,p_table_name           =>  p_tbl_name
               ,p_statement_type       =>  p_stmt_type
               ,p_num_of_output_rows   =>  p_num_output_rows
               ,p_user_id              =>  p_param_rec.user_id
               ,p_last_update_login    =>  p_param_rec.login_id
               ,x_msg_count            =>  l_msg_count
               ,x_msg_data             =>  l_msg_data
               ,x_return_status        =>  l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

         Get_Put_Messages( p_msg_count => l_msg_count
                          ,p_msg_data  => l_msg_data);

         RAISE e_upd_num_output_rows_error;
      END IF;

      fem_engines_pkg.tech_message( p_severity  => g_log_level_2
                                   ,p_module    => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text  => 'END');

   EXCEPTION
      WHEN e_upd_num_output_rows_error THEN
         fem_engines_pkg.tech_message (
	    p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Update Rows Exception');

         fem_engines_pkg.user_message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_OP_UPD_ROWS_ERR);

         RAISE e_arc_engine_error;

      WHEN OTHERS THEN
         fem_engines_pkg.user_message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_OP_UPD_ROWS_ERR);

         RAISE e_arc_engine_error;

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
   PROCEDURE Update_Obj_Exec_Step_Status( p_param_rec       IN param_record
                                         ,p_exe_step        IN VARCHAR2
                                         ,p_exe_status_code IN VARCHAR2)
   IS

   l_api_name             CONSTANT VARCHAR2(30) := 'Update_Obj_Exe_Step_Status';

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(240);

   e_upd_obj_exec_step_stat_error  EXCEPTION;

   BEGIN

      fem_engines_pkg.tech_message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      --Call the FEM_PL_PKG.Update_Obj_Exec_Step_status API procedure
      --to update step staus in fem_pl_obj_steps.
      FEM_PL_PKG.Update_Obj_Exec_Step_Status(
            p_api_version          =>  1.0
           ,p_commit               =>  FND_API.G_TRUE
           ,p_request_id           =>  p_param_rec.request_id
           ,p_object_id            =>  p_param_rec.crnt_proc_child_obj_id
           ,p_exec_step            =>  p_exe_step
           ,p_exec_status_code     =>  p_exe_status_code
           ,p_user_id              =>  p_param_rec.user_id
           ,p_last_update_login    =>  p_param_rec.login_id
           ,x_msg_count            =>  l_msg_count
           ,x_msg_data             =>  l_msg_data
           ,x_return_status        =>  l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

         Get_Put_Messages ( p_msg_count => l_msg_count
                           ,p_msg_data  => l_msg_data);
         RAISE e_upd_obj_exec_step_stat_error;

      END IF;

      fem_engines_pkg.tech_message ( p_severity => g_log_level_2
                                    ,p_module   => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text => 'END');

   EXCEPTION
      WHEN  e_upd_obj_exec_step_stat_error   THEN
         fem_engines_pkg.tech_message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Update Obj Exec Step API Exception');

         fem_engines_pkg.user_message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_UPD_EXEC_STEP_ERR
           ,p_token1    => 'OBJECT_ID'
           ,p_value1    => p_param_rec.crnt_proc_child_obj_id);

         RAISE e_arc_engine_error;

      WHEN OTHERS THEN
         fem_engines_pkg.user_message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_UPD_EXEC_STEP_ERR
           ,p_token1    => 'OBJECT_ID'
           ,p_value1    => p_param_rec.crnt_proc_child_obj_id);

         RAISE e_arc_engine_error;

   END Update_Obj_Exec_Step_Status;

 /*============================================================================+
 | PROCEDURE
 |   Get_Nbr_RowsTable_For_Request
 |
 | DESCRIPTION
 |   Gets the number of rows processed successfully by the Rule.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/
   PROCEDURE Get_Nbr_RowsTable_Request(x_rows_processed OUT NOCOPY NUMBER,
                                       x_rows_loaded    OUT NOCOPY NUMBER,
                                       x_rows_rejected  OUT NOCOPY NUMBER,
                                       p_request_id     IN NUMBER,
                                       p_sec_relns_flag IN VARCHAR2)
    IS

   l_api_name      CONSTANT VARCHAR2(30) := 'Get_Nbr_RowsTable_Request';

   BEGIN

      fem_engines_pkg.tech_message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      --Query the fem_mp_process_ctl_t table to get the number of rows
      --processed per request
      SELECT  NVL(SUM(rows_processed),0), NVL(SUM(rows_rejected),0), NVL(SUM(rows_loaded),0)
        INTO  x_rows_processed, x_rows_rejected, x_rows_loaded
      FROM    fem_mp_process_ctl_t  t
      WHERE   t.req_id = p_request_id
        AND   t.process_num > 0;

      IF (x_rows_processed = 0) THEN
         fem_engines_pkg.tech_message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'No Rows returned by the Insert Statement');

         IF (p_sec_relns_flag = 'Y') THEN
            fem_engines_pkg.user_message (
               p_app_name  => G_PFT
              ,p_msg_name  => G_ENG_SEC_NO_OP_ROWS_ERR);
         ELSE
            fem_engines_pkg.user_message (
               p_app_name  => G_PFT
              ,p_msg_name  => G_ENG_NO_OP_ROWS_ERR);
         END IF;
      END IF;

      fem_engines_pkg.tech_message( p_severity  => g_log_level_2
                                   ,p_module    => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text  => 'END');

   EXCEPTION
      WHEN OTHERS THEN
         RAISE;
   END Get_Nbr_RowsTable_Request;

  /*===========================================================================+
 | PROCEDURE
 |   Process_Obj_Exec_Step
 | DESCRIPTION
 |   Processes the execution of the Object.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/
   PROCEDURE Process_Obj_Exec_Step( p_param_rec       IN OUT NOCOPY param_record
                                   ,p_exe_step        IN VARCHAR2
                                   ,p_exe_status_code IN VARCHAR2
                                   ,p_tbl_name        IN VARCHAR2)
   IS
   l_api_name           VARCHAR2(30);
   l_nbr_output_rows    NUMBER;
   l_nbr_rejected_rows  NUMBER;
   l_nbr_loaded_rows    NUMBER;

   BEGIN
      l_api_name           := 'Process_Obj_Exec_Step';
      l_nbr_output_rows    := NULL;

      fem_engines_pkg.tech_message( p_severity => g_log_level_2
                                   ,p_module   => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text => 'BEGIN');

      IF (p_exe_status_code = g_exec_status_success) THEN
         -- query table fem_mp_process_ctl_t to get the number of rows processed

         Get_Nbr_RowsTable_Request(l_nbr_output_rows,
                                   l_nbr_loaded_rows,
                                   l_nbr_rejected_rows,
                                   p_param_rec.request_id,
                                   p_param_rec.sec_relns_flag);

         p_param_rec.rows_processed := l_nbr_output_rows;
         p_param_rec.rows_loaded := l_nbr_loaded_rows;
         p_param_rec.rows_rejected := l_nbr_rejected_rows;

         --update the number of output rows processed succesfully
         --in the registered table

         fem_engines_pkg.tech_message(
	    p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Total Number of Processed Rows :'
	                  ||l_nbr_output_rows);

         -- update the number of rows processed in the registered table
         Update_Nbr_Of_Output_Rows(p_param_rec        =>  p_param_rec
                                  ,p_num_output_rows  =>  p_param_rec.rows_processed
                                  ,p_tbl_name         =>  p_tbl_name
                                  ,p_stmt_type        =>  g_insert );

         -----------------------------------------------------------------------
         -- Call FEM_PL_PKG.update_num_of_input_rows();
         -----------------------------------------------------------------------

         fem_engines_pkg.tech_message(
            p_severity => g_log_level_1,
            p_module   => G_BLOCK||'.'||l_api_name,
            p_msg_text => 'No:of Rows processed from input table'
	                  ||l_nbr_loaded_rows );

         -- update the number of rows processed in the registered table
         Update_Nbr_Of_Input_Rows(p_param_rec        =>  p_param_rec
                                 ,p_num_input_rows   =>  p_param_rec.rows_processed);

      END IF;

      fem_engines_pkg.tech_message(
         p_severity => g_log_level_3
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Update the status of the step with execution status :'
                       ||p_exe_status_code);

      --update the status of the step
      Update_Obj_Exec_Step_Status( p_param_rec       => p_param_rec
                                  ,p_exe_step        => 'ACCT_REL_CONS'
                                  ,p_exe_status_code => p_exe_status_code );

      fem_engines_pkg.tech_message( p_severity => g_log_level_2
                                   ,p_module   => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text => 'END');

   EXCEPTION
      WHEN OTHERS THEN
      RAISE e_arc_engine_error;

   END;

/*=============================================================================+
 | PROCEDURE
 |   Preprocess_Rule_set
 |
 | DESCRIPTION
 |   Flattens the rule set
 |
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/
   PROCEDURE Preprocess_Rule_Set ( p_param_rec  IN param_record )

   IS

   l_api_name          CONSTANT VARCHAR2(30) := 'Preprocess_Rule_Set';

   l_return_status              VARCHAR2(1);
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(240);
   e_pl_preprocess_rule_set_err EXCEPTION;

   BEGIN

      fem_engines_pkg.tech_message( p_severity => g_log_level_2
                                   ,p_module   => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text => 'BEGIN');

      FEM_RULE_SET_MANAGER.Fem_Preprocess_RuleSet_Pvt(
         p_api_version                 =>  G_CALLING_API_VERSION
        ,p_init_msg_list               =>  FND_API.G_FALSE
        ,p_commit                      =>  FND_API.G_TRUE
        ,p_encoded                     =>  FND_API.G_TRUE
        ,x_return_status               =>  l_return_status
        ,x_msg_count                   =>  l_msg_count
        ,x_msg_data                    =>  l_msg_data
        ,p_orig_ruleset_object_id      =>  p_param_rec.obj_id
        ,p_ds_io_def_id                =>  p_param_rec.dataset_io_obj_def_id
        ,p_rule_effective_date         =>  p_param_rec.effective_date_varchar
        ,p_output_period_id            =>  p_param_rec.output_cal_period_id
        ,p_ledger_id                   =>  p_param_rec.ledger_id
        ,p_continue_process_on_err_flg =>  p_param_rec.continue_process_on_err_flg
        ,p_execution_mode              =>  'E'-- Engine Execution Mode
      );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         Get_Put_Messages ( p_msg_count => l_msg_count
                           ,p_msg_data  => l_msg_data);

         RAISE e_pl_preprocess_rule_set_err ;

      END IF;

      fem_engines_pkg.tech_message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'END');

      EXCEPTION
         WHEN e_pl_preprocess_rule_set_err  THEN
            fem_engines_pkg.tech_message (
               p_severity  => g_log_level_5
              ,p_module    => G_BLOCK||'.'||l_api_name
              ,p_msg_text  => 'Preprocess Rule Set Exception' );

            fem_engines_pkg.user_message (
               p_app_name  => G_PFT
              ,p_msg_name  => G_ENG_PRE_PROC_RS_ERR
              ,p_token1    => 'RULE_SET_OBJ_ID'
              ,p_value1    => p_param_rec.obj_id);

         RAISE e_arc_engine_error;

         WHEN OTHERS THEN
            fem_engines_pkg.user_message (
               p_app_name  => G_PFT
              ,p_msg_name  => G_ENG_PRE_PROC_RS_ERR
              ,p_token1    => 'RULE_SET_OBJ_ID'
              ,p_value1    => p_param_rec.obj_id);
         RAISE e_arc_engine_error;

   END Preprocess_Rule_Set;

/*=============================================================================+
 | PROCEDURE
 |   PROCESS SINGLE RULE
 |
 | DESCRIPTION
 |   Process the Single Account consolidation Rule
 |
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

   PROCEDURE Process_Single_Rule ( p_param_rec IN OUT NOCOPY  param_record)

   IS

   l_api_name       CONSTANT    VARCHAR2(30) := 'Process_Single_Rule';

   l_process_table              VARCHAR2(30);
   l_table_alias                VARCHAR(30);
   l_cond_obj_id                NUMBER;
   l_sec_rels_flag              VARCHAR2(1);
   l_col_obj_def_id             NUMBER;
   l_obj_name                   VARCHAR2(30);
   l_err_code                   NUMBER := 0;
   l_err_msg                    VARCHAR2(255);
   l_prev_req_id                NUMBER;
   l_exec_state                 VARCHAR2(30);
   l_reuse_slices               VARCHAR2(10);
   l_msg_count                  NUMBER;
   l_exception_code             VARCHAR2(50);
   l_msg_data                   VARCHAR2(200);
   l_return_status              VARCHAR2(50):= NULL;
   l_col_tmplt_obj_id           NUMBER;
   l_bulk_sql                   LONG;
   l_src_tab_name               VARCHAR2(30);
   l_aggregation_method         NUMBER;

    TYPE v_msg_list_type        IS VARRAY(20) OF
                                fem_mp_process_ctl_t.message%TYPE;
    v_msg_list                  v_msg_list_type;

   e_process_single_rule_error  EXCEPTION;
   e_register_rule_error        EXCEPTION;

   BEGIN
      -- Initialize the return status to SUCCESS
      p_param_rec.return_status  := FND_API.G_RET_STS_SUCCESS;

      fem_engines_pkg.tech_message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      fem_engines_pkg.tech_message (
         p_severity  => g_log_level_2
        ,p_module    => G_BLOCK||'.'||l_api_name
        ,p_msg_text  => 'Validate the Rule Definition');

      FEM_RULE_SET_MANAGER.Validate_Rule_Public(
              l_err_code,
              l_err_msg,
              p_param_rec.crnt_proc_child_obj_id,
              p_param_rec.dataset_io_obj_def_id,
              p_param_rec.effective_date_varchar, --p_effective_date,
              p_param_rec.output_cal_period_id,
              p_param_rec.ledger_id);

      -- Unexpected error
      IF (l_err_code <> 0) THEN
         fem_engines_pkg.user_message (p_app_name => G_FEM
                                      ,p_msg_name => l_err_msg);

         RAISE e_process_single_rule_error;

      END IF;

      fem_engines_pkg.tech_message (
         p_severity  => g_log_level_1
        ,p_module    => G_BLOCK||'.'||l_api_name
        ,p_msg_text  => 'PROCESSING OBJECT ID: '
                        ||p_param_rec.crnt_proc_child_obj_id
                        ||'AND PROCESSING OBJECT DEFINITION ID: '
                        ||p_param_rec.crnt_proc_child_obj_defn_id);

      fem_engines_pkg.tech_message (
         p_severity  => g_log_level_3
        ,p_module    => G_BLOCK||'.'||l_api_name
        ,p_msg_text  => 'Getting Account Consolidation Rule Details');

      BEGIN
         -- get the details of the rule
         SELECT processing_table
               ,load_secondary_rel_flag
               ,condition_obj_id
               ,col_tmplt_obj_id
           INTO l_process_table
               ,p_param_rec.sec_relns_flag
               ,p_param_rec.cond_obj_id
               ,l_col_tmplt_obj_id
         FROM   pft_acct_rel_cons_rules
         WHERE  acct_rel_cons_obj_def_id =
	            p_param_rec.crnt_proc_child_obj_defn_id;

         EXCEPTION
            WHEN no_data_found THEN
               fem_engines_pkg.user_message (
                  p_app_name  => G_PFT
                 ,p_msg_name  => G_ENG_INVALID_OBJ_DEFN_ERR
                 ,p_token1    => 'OBJECT_ID'
                 ,p_value1    => p_param_rec.crnt_proc_child_obj_id
                 ,p_token2    => 'EFFECTIVE_DATE'
                 ,p_value2    => p_param_rec.effective_date);

               RAISE e_process_single_rule_error;

      END;

      fem_engines_pkg.tech_message (
         p_severity  => g_log_level_3
        ,p_module    => G_BLOCK||'.'||l_api_name
        ,p_msg_text  => 'Getting column population template definition');

      Get_Object_Definition( p_object_type_code => 'COL_POP_TEMPLATE'
                            ,p_object_id        => l_col_tmplt_obj_id
                            ,p_effective_date   => p_param_rec.effective_date
                            ,x_obj_def_id       => l_col_obj_def_id);
      BEGIN
         SELECT source_table_name
           INTO l_src_tab_name
         FROM   fem_col_population_tmplt_b
         WHERE  col_pop_templt_obj_def_id = l_col_obj_def_id
           AND  ROWNUM = 1;

         IF (l_src_tab_name <> l_process_table) THEN
            fem_engines_pkg.tech_message (
               p_severity  => g_log_level_3
              ,p_module    => G_BLOCK||'.'||l_api_name
              ,p_msg_text  => 'The source table name defined in the column
                              population template and the processing table
                              defined in the rule should be same.');

            fem_engines_pkg.user_message (
               p_app_name  => G_PFT
              ,p_msg_name  => G_ENG_GENERIC_5_ERR);

            RAISE e_process_single_rule_error;
         END IF;

         EXCEPTION
            WHEN no_data_found THEN
               fem_engines_pkg.user_message (
                  p_app_name  => G_PFT
                 ,p_msg_name  => G_ENG_INVALID_OBJ_DEFN_ERR
                 ,p_token1    => 'OBJECT_DEFINITION_ID'
                 ,p_value1    => l_col_obj_def_id
                 ,p_token2    => 'EFFECTIVE_DATE'
                 ,p_value2    => p_param_rec.effective_date);

               RAISE e_process_single_rule_error;
      END;

      BEGIN
         SELECT COUNT(aggregation_method)
           INTO l_aggregation_method
         FROM   fem_col_population_tmplt_b
         WHERE  col_pop_templt_obj_def_id = l_col_obj_def_id
           AND  aggregation_method <> 'NOAGG';

         IF (l_aggregation_method <> 0) THEN
            fem_engines_pkg.tech_message (
               p_severity  => g_log_level_3
              ,p_module    => G_BLOCK||'.'||l_api_name
              ,p_msg_text  => 'No aggregation function should be defined on
                              column population template for Account
                              Consolidation Rule');

            -- Start of Bug 4686523
            fem_engines_pkg.user_message (
               p_app_name  => G_PFT
              ,p_msg_name  => G_ENG_COL_POP_GEN_ARC_AGG_ERR);

            -- End of Bug 4686523

            RAISE e_process_single_rule_error;
         END IF;
         EXCEPTION
            WHEN no_data_found THEN
               fem_engines_pkg.user_message (
                  p_app_name  => G_PFT
                 ,p_msg_name  => G_ENG_INVALID_OBJ_DEFN_ERR
                 ,p_token1    => 'OBJECT_DEFINITION_ID'
                 ,p_value1    => l_col_obj_def_id
                 ,p_token2    => 'EFFECTIVE_DATE'
                 ,p_value2    => p_param_rec.effective_date);

               RAISE e_process_single_rule_error;
      END;

      BEGIN
         -- Call the FEM_PL_PKG.Register_Object_Execution API procedure
         -- to register the rollup object execution in FEM_PL_OBJECT_EXECUTIONS,
         -- thus obtaining an execution lock.

         SAVEPOINT register_rule_pub;

         FEM_PL_PKG.Register_Object_Execution(
          p_api_version               => G_CALLING_API_VERSION
         ,p_commit                    => FND_API.G_TRUE
         ,p_request_id                => p_param_rec.request_id
         ,p_object_id                 => p_param_rec.crnt_proc_child_obj_id
         ,p_exec_object_definition_id => p_param_rec.crnt_proc_child_obj_defn_id
         ,p_user_id                   => p_param_rec.user_id
         ,p_last_update_login         => p_param_rec.login_id
         ,p_exec_mode_code            => NULL
         ,x_exec_state                => l_exec_state
         ,x_prev_request_id           => l_prev_req_id
         ,x_msg_count                 => l_msg_count
         ,x_msg_data                  => l_msg_data
         ,x_return_status             => l_return_status);

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
            Get_Put_Messages (p_msg_count => l_msg_count
                             ,p_msg_data  => l_msg_data);

            RAISE e_register_rule_error;

         END IF;

         EXCEPTION
            WHEN e_register_rule_error THEN

               ROLLBACK TO register_rule_pub;

               fem_engines_pkg.tech_message (
                  p_severity  => G_LOG_LEVEL_6
                 ,p_module    => G_BLOCK||'.'||l_api_name
                 ,p_msg_text  => 'Register Rule Exception');

               fem_engines_pkg.user_message (
                  p_app_name  => G_PFT
                 ,p_msg_name  => G_PL_OBJ_EXEC_LOCK_ERR);

               p_param_rec.return_status  := FND_API.G_RET_STS_ERROR;

            RAISE e_process_single_rule_error;

      END;

      --------------------------------------------------------------------------
      --Register the dependant object 'Dataset Group' object
      --------------------------------------------------------------------------
      fem_engines_pkg.tech_message(p_severity => g_log_level_3
                                  ,p_module   => G_BLOCK||'.'||l_api_name
                                  ,p_msg_text => 'Register_Dataset_Grp_Object');

      Register_Object_Definition (
          p_param_rec  => p_param_rec
         ,p_object_id  => p_param_rec.crnt_proc_child_obj_id
         ,p_obj_def_id => p_param_rec.dataset_io_obj_def_id);

      -- CHECKPOINT RESTART
      -- check executed state and jump to appropriate statement
      -- depending on which step was last executed successfully
      IF(l_exec_state = 'RESTART') THEN
         l_reuse_slices := 'Y';
      ELSE
         l_reuse_slices := 'N';
      END IF;

      --------------------------------------------------------------------------
      --call to FEM_PL_PKG.register_dependent_objdefs
      --------------------------------------------------------------------------

      fem_engines_pkg.tech_message( p_severity => g_log_level_3
                                   ,p_module   => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text => 'Register_Dependent_Objects');

      Register_Dependent_Objects(p_param_rec => p_param_rec);

      --------------------------------------------------------------------------
      -- Call FEM_PL_PKG.Register_Table()
      --------------------------------------------------------------------------
      fem_engines_pkg.tech_message( p_severity => g_log_level_3
                                   ,p_module   => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text => 'Register table ');

      Register_Table( p_param_rec        =>  p_param_rec
                     ,p_tbl_name         =>  g_fem_customer_profit
                     ,p_num_output_rows  =>  0
                     ,p_stmt_type        =>  g_insert);

      -- To create the INSERT statement for the Account Consolidation Step.
      l_bulk_sql := Create_Consolidation_Stmt(
           p_rule_obj_id           =>  p_param_rec.crnt_proc_child_obj_id
          ,p_table_name            =>  l_process_table
          ,p_cal_period_id         =>  p_param_rec.output_cal_period_id
          ,p_dataset_io_obj_def_id =>  p_param_rec.dataset_io_obj_def_id
          ,p_effective_date        =>  p_param_rec.effective_date_varchar
          ,p_ledger_id             =>  p_param_Rec.ledger_id
          ,p_condition_obj_id      =>  p_param_rec.cond_obj_id
          ,p_source_system_code    =>  p_param_rec.source_system_code
          ,p_secondary_flag        =>  p_param_rec.sec_relns_flag
          ,p_col_obj_def_id        =>  l_col_obj_def_id);

      fem_engines_pkg.tech_message(
         p_severity => g_log_level_3
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Submitting to MP Master.p_rule_id: '
                        ||p_param_rec.crnt_proc_child_obj_id);

      l_table_alias := Fem_Col_Tmplt_Defn_Api_Pub.g_src_alias;

      fem_engines_pkg.tech_message(
         p_severity => g_log_level_3
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Registering step: ACCT_REL_CONS');

      -------------------------------------------------------------------------
      -- The following step may not be needed as there is only one step in
      -- this engine.
      -------------------------------------------------------------------------

      --Register step by passing the step name and
      --the execution status of register object execution
      Register_Obj_Exe_Step(p_param_rec       => p_param_rec
                           ,p_exe_step        => 'ACCT_REL_CONS'
                           ,p_exe_status_code => l_exec_state );

      fem_engines_pkg.tech_message(
         p_severity => g_log_level_3
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Submitting to MP Master.p_rule_id: '
                        ||p_param_rec.crnt_proc_child_obj_id);

      fem_engines_pkg.tech_message(
         p_severity => g_log_level_3
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Submitting to MP Master.p_eng_sql: '||l_bulk_sql);

      FEM_MULTI_PROC_PKG.Master(
                x_prg_stat        =>  l_err_msg
               ,x_Exception_code  =>  l_exception_code
               ,p_rule_id         =>  p_param_rec.crnt_proc_child_obj_id
               ,p_eng_step        =>  'ALL'
               ,p_eng_sql         =>  l_bulk_sql
               ,p_data_table      =>  l_process_table
               ,p_table_alias     =>  l_table_alias
               ,p_run_name        =>  NULL
               ,p_eng_prg         =>  NULL
               ,p_condition       =>  NULL
               ,p_failed_req_id   =>  NULL
               ,p_reuse_slices    =>  l_reuse_slices );

      IF (l_err_msg <> G_COMPLETE_NORMAL) THEN
         v_msg_list := v_msg_list_type();

         SELECT DISTINCT(message)
         BULK COLLECT INTO v_msg_list
         FROM fem_mp_process_ctl_t
         WHERE req_id = p_param_rec.request_id
           AND status = 2;

         fem_engines_pkg.tech_message(p_severity => g_log_level_1
                                     ,p_module   => G_BLOCK||'.'||l_api_name
                                     ,p_msg_text => 'Total Errors : ' ||
                                                     TO_CHAR(v_msg_list.COUNT));

         -- Log all of the messages
         FOR i IN 1..v_msg_list.COUNT LOOP

            fem_engines_pkg.tech_message( p_severity => g_log_level_5
                                         ,p_module   => G_BLOCK||'.'||l_api_name
                                         ,p_msg_text => v_msg_list(i));

            fem_engines_pkg.user_message ( p_app_name => G_PFT
                                          ,p_msg_text => v_msg_list(i));

--            fnd_file.put_line(fnd_file.log, v_msg_list(i));

         END LOOP;

         fem_engines_pkg.user_message (p_app_name  => G_PFT
                                      ,p_msg_name  => G_ENG_MULTI_PROC_ERR);

         Process_Obj_Exec_Step( p_param_rec        => p_param_rec
                               ,p_exe_step         => 'ALL'
                               ,p_exe_status_code  => g_exec_status_error_rerun
                               ,p_tbl_name         => g_fem_customer_profit);

         RAISE e_process_single_rule_error;

      ELSIF(l_err_msg = G_COMPLETE_NORMAL) THEN

         Process_Obj_Exec_Step( p_param_rec       => p_param_rec
                               ,p_exe_step        => 'ALL'
                               ,p_exe_status_code => g_exec_status_success
                               ,p_tbl_name        => g_fem_customer_profit);

      END IF;

      -- commit the work
      COMMIT;

      -- Purge Data Slices
      FEM_MULTI_PROC_PKG.Delete_Data_Slices (
         p_req_id => p_param_rec.request_id);

      fem_engines_pkg.tech_message ( p_severity  => G_LOG_LEVEL_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'END');

   EXCEPTION
      WHEN e_process_single_rule_error THEN
         fem_engines_pkg.tech_message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Process Single Rule Exception');

         --fem_engines_pkg.user_message (p_app_name  => G_PFT
         --                             ,p_msg_name  => G_ENG_SINGLE_RULE_ERR);

         p_param_rec.return_status  := FND_API.G_RET_STS_ERROR;

      WHEN OTHERS THEN

         fem_engines_pkg.user_message (p_app_name  => G_PFT
                                      ,p_msg_name  => G_ENG_SINGLE_RULE_ERR);

         p_param_rec.return_status  := FND_API.G_RET_STS_ERROR;

   END Process_Single_Rule;

/*=============================================================================+
 | FUNCTION
 |   Create Consolidation Statement
 |
 | DESCRIPTION
 |   Creates the Bulk SQL statement required for account consolidation
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

   FUNCTION Create_Consolidation_Stmt ( p_rule_obj_id            IN NUMBER,
                                        p_table_name             IN VARCHAR2,
                                        p_cal_period_id          IN NUMBER,
                                        p_dataset_io_obj_def_id  IN NUMBER,
                                        p_effective_date         IN VARCHAR2,
                                        p_ledger_id              IN NUMBER,
                                        p_condition_obj_id       IN NUMBER,
                                        p_source_system_code     IN NUMBER,
                                        p_secondary_flag         IN VARCHAR2,
                                        p_col_obj_def_id         IN NUMBER)

                                        RETURN LONG IS
   l_api_name       CONSTANT    VARCHAR2(30) := 'Create_Consolidation_Stmt';

   l_insert_head_stmt           LONG;
   l_select_stmt                LONG;
   l_from_stmt                  LONG;
   l_where_stmt                 LONG;
   l_cond_where_stmt            LONG;
   l_request_id                 NUMBER;
   l_user_id                    NUMBER;
   l_selection_param            NUMBER;
   l_condition_sel_param        VARCHAR2(10);
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(500);
   l_return_status              VARCHAR2(20);
   l_effective_date             DATE;

   e_col_population_api_err     EXCEPTION;

   --   CURSOR l_mapped_cols IS
   --     SELECT table_name, column_name, target_column
   --     FROM pft_pprof_mapped_cols;

   BEGIN
      l_request_id             :=  FND_GLOBAL.Conc_Request_Id;
      l_user_id                :=  FND_GLOBAL.User_Id;
      l_effective_date         :=  FND_DATE.Canonical_To_Date(p_effective_date);
      l_condition_sel_param    :=  'BOTH';

      fem_engines_pkg.tech_message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      IF p_condition_obj_id IS NULL THEN
         l_selection_param := 1;
      ELSE
         l_selection_param := 0;
      END IF;

      -- Calls Column population Template API to create SQL statement based on
      -- the given col population tempalte.
      Fem_Col_Tmplt_Defn_Api_Pub.generate_predicates (
                 p_api_version             =>  g_api_version
                ,p_init_msg_list           =>  g_false
                ,p_commit                  =>  g_false
                ,p_encoded                 =>  g_true
                ,p_object_def_id           =>  p_col_obj_def_id
                ,p_selection_param         =>  l_selection_param
                ,p_effective_date          =>  p_effective_date
                ,p_condition_obj_id        =>  p_condition_obj_id
                ,p_condition_sel_param     =>  l_condition_sel_param
                ,p_load_sec_relns          =>  p_secondary_flag
                ,p_dataset_grp_obj_def_id  =>  p_dataset_io_obj_def_id
                ,p_cal_period_id           =>  p_cal_period_id
                ,p_ledger_id               =>  p_ledger_id
                ,p_source_system_code      =>  p_source_system_code
                ,p_created_by_object_id    =>  p_rule_obj_id
                ,p_created_by_request_id   =>  l_request_id
                ,p_insert_list             =>  l_insert_head_stmt
                ,p_select_list             =>  l_select_stmt
                ,p_from_clause             =>  l_from_stmt
                ,p_where_clause            =>  l_where_stmt
                ,p_con_where_clause        =>  l_cond_where_stmt
                ,x_msg_count               =>  l_msg_count
                ,x_msg_data                =>  l_msg_data
                ,x_return_status           =>  l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         Get_Put_Messages ( p_msg_count => l_msg_count
                           ,p_msg_data  => l_msg_data);

         RAISE e_col_population_api_err ;

      END IF;

      --To consolidate secondary relationships
      IF (p_secondary_flag = 'Y')THEN
         Add_Secondary_Relation( p_select_col   => l_select_stmt
                                ,p_from_clause  => l_from_stmt
                                ,p_where_clause => l_where_stmt);
      END IF;

      -- Adds the condition statement to the prepared SQL Statement.

      IF (l_cond_where_stmt IS NOT NULL) THEN
         l_where_stmt :=  l_where_stmt || ' AND ' ||  l_cond_where_stmt
                          || ' AND {{data_slice}}';
      ELSE
         l_where_stmt := l_where_stmt || ' AND {{data_slice}}';
      END IF;

      -- add mapped columns
      RETURN l_insert_head_stmt || ' ' || l_select_stmt || ' ' || l_from_stmt
                                || ' ' || l_where_stmt;

      fem_engines_pkg.tech_message ( p_severity  => G_LOG_LEVEL_2
                                    ,p_module   => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text => 'END');

      EXCEPTION
         WHEN e_col_population_api_err  THEN
            fem_engines_pkg.tech_message (
               p_severity  => g_log_level_5
              ,p_module    => G_BLOCK||'.'||l_api_name
              ,p_msg_text  => 'Column Population API Exception');

            fem_engines_pkg.user_message (p_app_name  => G_PFT
                                         ,p_msg_name  => G_ENG_COL_POP_API_ERR);

            RAISE e_arc_engine_error;

         WHEN OTHERS THEN
         RAISE;


   END Create_Consolidation_Stmt;

/*===========================================================================+==
 | FUNCTION
 |   is_ruleset_flattened
 |
 | DESCRIPTION
 |   To check whether the rule set is flattened or not
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

   FUNCTION is_rule_set_flattened( p_request_id      IN NUMBER,
                                   p_rule_set_obj_id IN NUMBER)

                                   RETURN NUMBER IS

   l_api_name       CONSTANT    VARCHAR2(30) := 'is_rule_set_flattened';

   l_count                      NUMBER;

   BEGIN
      fem_engines_pkg.tech_message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');
      SELECT COUNT(*)
        INTO l_count
      FROM   fem_ruleset_process_data p,
             fem_pl_object_executions x
      WHERE  p.request_id = p_request_id AND
             p.request_id = x.request_id(+) AND
             p.rule_set_obj_id = p_rule_set_obj_id
      ORDER BY p.engine_execution_sequence;

      IF (l_count = 0) THEN
         RETURN -1;
      END IF;

      RETURN 0;
      fem_engines_pkg.tech_message ( p_severity => G_LOG_LEVEL_2
                                    ,p_module   => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text => 'END');
   EXCEPTION
      WHEN no_data_found THEN
         RETURN -1;
      WHEN OTHERS THEN
         RAISE;

   END is_rule_set_flattened;

 /*============================================================================+
 | PROCEDURE
 |   Eng_Master_Post_Proc
 |
 | DESCRIPTION
 |   Updates the status of the request and object execution in the
 |   processing locks tables.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

   PROCEDURE Eng_Master_Post_Proc ( p_param_rec              IN   param_record
                                   ,p_exec_status_code       IN   VARCHAR2)
   IS

   l_api_name             CONSTANT VARCHAR2(30) := 'Eng_Master_Post_Proc';

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(240);
   l_commit                        BOOLEAN;

   e_eng_master_post_proc_error    EXCEPTION;


   BEGIN

      fem_engines_pkg.tech_message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      --------------------------------------------------------------------------
      -- STEP 1: Update Object Execution Status.
      --------------------------------------------------------------------------
      fem_engines_pkg.tech_message (
         p_severity  => g_log_level_1
        ,p_module    => G_BLOCK||'.'||l_api_name
        ,p_msg_text  => 'Step 1:  Update Object Execution Status');

      FEM_PL_PKG.Update_Obj_Exec_Status (
         p_api_version       => 1.0
        ,p_commit            => FND_API.G_TRUE
        ,p_request_id        => p_param_rec.request_id
        ,p_object_id         => p_param_rec.crnt_proc_child_obj_id
        ,p_exec_status_code  => p_exec_status_code
        ,p_user_id           => p_param_rec.user_id
        ,p_last_update_login => p_param_rec.login_id
        ,x_msg_count         => l_msg_count
        ,x_msg_data          => l_msg_data
        ,x_return_status     => l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         Get_Put_Messages ( p_msg_count => l_msg_count
                           ,p_msg_data  => l_msg_data);
         RAISE e_eng_master_post_proc_error;
      END IF;

      --------------------------------------------------------------------------
      -- STEP 2: Update Object Execution Errors.
      --------------------------------------------------------------------------
      IF (p_exec_status_code <> g_exec_status_success) THEN

         fem_engines_pkg.tech_message (
            p_severity  => g_log_level_1
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Step 2:  Update Object Execution Errors');

         FEM_PL_PKG.Update_Obj_Exec_Errors (
               p_api_version        => 1.0
              ,p_commit             => FND_API.G_TRUE
              ,p_request_id         => p_param_rec.request_id
              ,p_object_id          => p_param_rec.crnt_proc_child_obj_id
              ,p_errors_reported    => 1 --todo: verify
              ,p_errors_reprocessed => 0 --todo: verify
              ,p_user_id            => p_param_rec.user_id
              ,p_last_update_login  => p_param_rec.login_id
              ,x_msg_count          => l_msg_count
              ,x_msg_data           => l_msg_data
              ,x_return_status      => l_return_status);

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            Get_Put_Messages ( p_msg_count => l_msg_count
                              ,p_msg_data  => l_msg_data);
            RAISE e_eng_master_post_proc_error;
         END IF;

      END IF;

      --------------------------------------------------------------------------
      -- STEP 3: Update Request Status.
      --------------------------------------------------------------------------
      fem_engines_pkg.tech_message (
         p_severity  => g_log_level_1
        ,p_module    => G_BLOCK||'.'||l_api_name
        ,p_msg_text  => 'Step 3:  Update Request Status');

      FEM_PL_PKG.Update_Request_Status (
          p_api_version       => 1.0
         ,p_commit            => FND_API.G_TRUE
         ,p_request_id        => p_param_rec.request_id
         ,p_exec_status_code  => p_exec_status_code
         ,p_user_id           => p_param_rec.user_id
         ,p_last_update_login => p_param_rec.login_id
         ,x_msg_count         => l_msg_count
         ,x_msg_data          => l_msg_data
         ,x_return_status     => l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         Get_Put_Messages ( p_msg_count => l_msg_count
                           ,p_msg_data  => l_msg_data);
         RAISE e_eng_master_post_proc_error;
      END IF;

      IF (p_exec_status_code = g_exec_status_success) THEN
          fem_engines_pkg.user_message(p_app_name => G_PFT,
                                       p_msg_name => 'PFT_PPROF_ROW_SUMMARY',
                                       p_token1 => 'ROWSP',
                                       p_value1 => p_param_rec.rows_processed,
                                       p_token2 => 'ROWSL',
                                       p_value2 => p_param_rec.rows_processed);
      END IF;

      COMMIT;

      fem_engines_pkg.tech_message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'END');

   EXCEPTION
      WHEN e_eng_master_post_proc_error THEN
         fem_engines_pkg.tech_message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Engine Master Post Process Exception');

         fem_engines_pkg.user_message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_ENG_ENGINE_POST_PROC_ERR
           ,p_token1    => 'OBJECT_ID'
           ,p_value1    => p_param_rec.obj_id);

         RAISE e_arc_engine_error;

   END Eng_Master_Post_Proc;

/*=============================================================================+
 | PROCEDURE
 |   Get_Object_Definition
 |
 | DESCRIPTION
 |   Returns the Object Definition Id for the given Object Id for the
 |   given effective Date
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

   PROCEDURE Get_Object_Definition (p_object_type_code      IN VARCHAR2
                                   ,p_object_id             IN NUMBER
                                   ,p_effective_date        IN DATE
                                   ,x_obj_def_id            OUT NOCOPY NUMBER)
   IS

   l_api_name             CONSTANT VARCHAR2(30) := 'Get_Object_Definition';

   BEGIN

      fem_engines_pkg.tech_message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      SELECT d.object_definition_id
        INTO x_obj_def_id
      FROM   fem_object_definition_b d
            ,fem_object_catalog_b o
      WHERE  o.object_id = p_object_id
        AND  o.object_type_code = p_object_type_code
        AND  d.object_id = o.object_id
        AND  p_effective_date BETWEEN d.effective_start_date
	                          AND d.effective_end_date
        AND  d.old_approved_copy_flag = 'N';

      fem_engines_pkg.tech_message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'END');

      EXCEPTION
         WHEN no_data_found THEN
            fem_engines_pkg.user_message (
               p_app_name  => G_PFT
              ,p_msg_name  => G_ENG_INVALID_OBJ_DEFN_ERR
              ,p_token1    => 'OBJECT_ID'
              ,p_value1    => p_object_id
              ,p_token2    => 'EFFECTIVE_DATE'
              ,p_value2    => p_effective_date);

         RAISE  e_arc_engine_error;

   END Get_Object_Definition;

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

   PROCEDURE Get_Put_Messages ( p_msg_count             IN NUMBER
                               ,p_msg_data              IN VARCHAR2)
   IS

   l_api_name          CONSTANT VARCHAR2(30) := 'Get_Put_Messages';
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(4000);
   l_msg_out                    NUMBER;
   l_message                    VARCHAR2(4000);

   BEGIN

      fem_engines_pkg.tech_message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'msg_count='||p_msg_count);

      l_msg_data := p_msg_data;

      IF (p_msg_count = 1) THEN

         FND_MESSAGE.Set_Encoded(l_msg_data);
         l_message := FND_MESSAGE.Get;

         fem_engines_pkg.user_message ( p_msg_text => l_message );

         fem_engines_pkg.tech_message ( p_severity  => g_log_level_2
                                       ,p_module    => G_BLOCK||'.'||l_api_name
                                       ,p_msg_text  => 'msg_data='||l_message);

      ELSIF (p_msg_count > 1) THEN

         FOR i IN 1..p_msg_count LOOP

            FND_MSG_PUB.Get ( p_msg_index     => i
                             ,p_encoded       => FND_API.G_FALSE
                             ,p_data          => l_message
                             ,p_msg_index_out => l_msg_out);

            fem_engines_pkg.user_message ( p_msg_text => l_message );

            fem_engines_pkg.tech_message (
               p_severity => g_log_level_2
              ,p_module   => G_BLOCK||'.'||l_api_name
              ,p_msg_text => 'msg_data='||l_message);

         END LOOP;

      END IF;

      FND_MSG_PUB.Initialize;

   END Get_Put_Messages;

 /*============================================================================+
 | PROCEDURE
 |   add_secondary_relation
 |
 | DESCRIPTION
 |   To load the customer id for the secondary relationships
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

   PROCEDURE add_secondary_relation(p_select_col   IN OUT NOCOPY LONG,
                                    p_from_clause  IN OUT NOCOPY LONG,
                                    p_where_clause IN OUT NOCOPY LONG)
   IS

   l_api_name  CONSTANT  VARCHAR2(30) := 'add_secondary_relation';

   l_src_alias           VARCHAR2(10);
   l_sec_alias           VARCHAR2(10);
   l_src_tab_name        VARCHAR2(30);
   l_where               LONG;
   l_table_id            NUMBER;

   BEGIN

      fem_engines_pkg.tech_message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      l_src_alias    := Fem_Col_Tmplt_Defn_Api_Pub.g_src_alias;
      l_sec_alias    := Fem_Col_Tmplt_Defn_Api_Pub.g_sec_alias;
      l_src_tab_name := Fem_Col_Tmplt_Defn_Api_Pub.g_src_tab_name;
      l_table_id     := Fem_Col_Tmplt_Defn_Api_Pub.g_table_id;

      IF l_table_id IS NULL THEN
         RAISE e_arc_engine_error;
      END IF;

      SELECT REPLACE(p_select_col, '{{{CUSTOMER_ID}}}',
                     l_sec_alias || '.' || 'CUSTOMER_ID' )
        INTO p_select_col
      FROM DUAL;

      p_from_clause := p_from_clause || ', FEM_SECONDARY_OWNERS '|| l_sec_alias;

      l_where := l_src_alias || '.ledger_id' || ' = ' ||
                 l_sec_alias || '.ledger_id';

      l_where := l_where || ' AND ' || l_src_alias || '.cal_period_id' || ' = '
                                    || l_sec_alias || '.cal_period_id';
      l_where := l_where || ' AND ' || l_src_alias || '.dataset_code' || ' = '
                                    || l_sec_alias || '.dataset_code';
      l_where := l_where || ' AND ' || l_src_alias || '.source_system_code'
                         ||  ' = '  || l_sec_alias || '.source_system_code';
      l_where := l_where || ' AND ' || l_src_alias || '.id_number' || ' = '
                                    || l_sec_alias || '.id_number';
      l_where := l_where || ' AND ' || l_sec_alias || '.table_id = TO_NUMBER('
                         ||  ''''   || l_table_id  || '''' || ')';

      p_where_clause := p_where_clause || ' AND ' || l_where;

      fem_engines_pkg.tech_message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'END');

   EXCEPTION
      WHEN OTHERS THEN
         RAISE;
   END add_secondary_relation;

   --sshanmug : Added additional proc for PL Implementation
 /*============================================================================+
 | PROCEDURE
 |   Register_Dependent_Objects
 |
 | DESCRIPTION
 |   This procedure retrieves all objects that are dependent on the object that
 |   is being executed, from FEM_OBJECT_DEPENDENCIES.  The effective date is
 |   used to retrieve the specific definition that will be read, for each
 |   dependent object, and then registers the retrieved definitions.  This
 |   procedure does not validate that each dependent object has a valid
 |   definition for the given effective date, and will not detect that a
 |   dependent object is missing a valid definition.  It is the responsibility
 |   of the calling program to make sure that each dependent object has a
 |   valid definition for the given effective date.
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

  PROCEDURE Register_Dependent_Objects( p_param_rec  IN param_record )
  IS

   l_api_name             CONSTANT VARCHAR2(30) := 'Register_Dependent_Objects';

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(240);

   e_register_dep_obj_def_error    EXCEPTION;

   BEGIN

      fem_engines_pkg.tech_message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      -- Register all the Dependent Objects for ARC
      FEM_PL_PKG.Register_Dependent_ObjDefs (
          p_api_version                => G_CALLING_API_VERSION
         ,p_commit                    => FND_API.G_TRUE
         ,p_request_id                => p_param_rec.request_id
         ,p_object_id                 => p_param_rec.crnt_proc_child_obj_id
         ,p_exec_object_definition_id => p_param_rec.crnt_proc_child_obj_defn_id
         ,p_effective_date            => p_param_rec.effective_date
         ,p_user_id                   => p_param_rec.user_id
         ,p_last_update_login         => p_param_rec.login_id
         ,x_msg_count                 => l_msg_count
         ,x_msg_data                  => l_msg_data
         ,x_return_status             => l_return_status);

      -- Object Definition Lock exists
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

         Get_Put_Messages ( p_msg_count => l_msg_count
                           ,p_msg_data  => l_msg_data);
         RAISE e_register_dep_obj_def_error;
      END IF;

      fem_engines_pkg.tech_message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'END');

   EXCEPTION
      WHEN e_register_dep_obj_def_error  THEN
         fem_engines_pkg.tech_message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Register Dependant Objects Exception');

         fem_engines_pkg.user_message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_DEP_OBJ_DEF_ERR
           ,p_token1    => 'OBJ_DEF_ID'
           ,p_value1    => p_param_rec.crnt_proc_child_obj_defn_id);
      RAISE e_arc_engine_error;

      WHEN OTHERS THEN
         fem_engines_pkg.tech_message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Register Dependant Objects Exception');

         fem_engines_pkg.user_message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_DEP_OBJ_DEF_ERR
           ,p_token1    => 'OBJ_DEF_ID'
           ,p_value1    => p_param_rec.crnt_proc_child_obj_defn_id);

      RAISE e_arc_engine_error;

   END Register_Dependent_Objects;

 /*============================================================================+
 | PROCEDURE
 |   Update_Num_Of_Intput_Rows
 |
 | DESCRIPTION
 |   This procedure logs the total number of rows used as input into
 | an object execution
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/
   PROCEDURE Update_Nbr_Of_Input_Rows( p_param_rec        IN  param_record
                                      ,p_num_input_rows   IN  NUMBER)
   IS

   l_api_name   CONSTANT VARCHAR2(30) := 'Update_Num_Of_Input_Rows';

   l_return_status       VARCHAR2(2);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(240);

   e_upd_num_input_rows_error     EXCEPTION;

   BEGIN

      fem_engines_pkg.tech_message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      -- Set the number of output rows for the output table.
      FEM_PL_PKG.Update_Num_Of_Input_Rows(
                p_api_version          =>  1.0
               ,p_commit               =>  FND_API.G_TRUE
               ,p_request_id           =>  p_param_rec.request_id
               ,p_object_id            =>  p_param_rec.crnt_proc_child_obj_id
               ,p_num_of_input_rows    =>  p_num_input_rows
               ,p_user_id              =>  p_param_rec.user_id
               ,p_last_update_login    =>  p_param_rec.login_id
               ,x_msg_count            =>  l_msg_count
               ,x_msg_data             =>  l_msg_data
               ,x_return_status        =>  l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

         Get_Put_Messages( p_msg_count => l_msg_count
                          ,p_msg_data  => l_msg_data);
         RAISE e_upd_num_input_rows_error;
      END IF;

      fem_engines_pkg.tech_message( p_severity  => g_log_level_2
                                   ,p_module    => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text  => 'END');

   EXCEPTION
      WHEN e_upd_num_input_rows_error THEN
         fem_engines_pkg.tech_message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Update Input Rows Exception');

         fem_engines_pkg.user_message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_IP_UPD_ROWS_ERR);

      RAISE e_arc_engine_error;

      WHEN OTHERS THEN
         fem_engines_pkg.tech_message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Update Input Rows Exception');

        fem_engines_pkg.user_message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_IP_UPD_ROWS_ERR);

      RAISE e_arc_engine_error;

   END Update_Nbr_Of_Input_Rows;

END PFT_ACCTRELCONS_PUB;

/
