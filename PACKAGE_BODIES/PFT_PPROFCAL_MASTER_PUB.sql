--------------------------------------------------------
--  DDL for Package Body PFT_PPROFCAL_MASTER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PFT_PPROFCAL_MASTER_PUB" AS
/* $Header: PFTPCAMB.pls 120.2.12000000.3 2007/08/09 16:09:56 gdonthir ship $ */

--------------------------------------------------------------------------------
-- Declare package constants --
--------------------------------------------------------------------------------

   g_object_version_number      CONSTANT   NUMBER       := 1;
   g_pkg_name                   CONSTANT   VARCHAR2(30) := 'PFT_PPROFCAL_MASTER_PUB';

   -- Constants for p_exec_status_code
   g_exec_status_error_rerun    CONSTANT   VARCHAR2(30) := 'ERROR_RERUN';
   g_exec_status_success        CONSTANT   VARCHAR2(30) := 'SUCCESS';

   --Constants for output table names being registered with fem_pl_pkg
   -- API register_table method.
   g_fem_customer_profit        CONSTANT   VARCHAR2(30) := 'FEM_CUSTOMER_PROFIT';
   g_fem_region_info            CONSTANT   VARCHAR2(30) := 'FEM_REGION_INFO';
   g_fem_customers_attr         CONSTANT   VARCHAR2(30) := 'FEM_CUSTOMERS_ATTR';

   --constant for sql_stmt_type
   g_insert                CONSTANT   VARCHAR2(30) := 'INSERT';
   g_update                CONSTANT   VARCHAR2(30) := 'UPDATE';


   g_default_fetch_limit   CONSTANT   NUMBER       :=  99999;

   g_log_level_1           CONSTANT   NUMBER       :=  fnd_log.level_statement;
   g_log_level_2           CONSTANT   NUMBER       :=  fnd_log.level_procedure;
   g_log_level_3           CONSTANT   NUMBER       :=  fnd_log.level_event;
   g_log_level_4           CONSTANT   NUMBER       :=  fnd_log.level_exception;
   g_log_level_5           CONSTANT   NUMBER       :=  fnd_log.level_error;
   g_log_level_6           CONSTANT   NUMBER       :=  fnd_log.level_unexpected;


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
  -- General profit calculation Engine Exception
   e_pc_engine_error           EXCEPTION;
   USER_EXCEPTION              EXCEPTION;


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

   PROCEDURE Register_Object_Definition(
     p_param_rec                     IN param_record
     ,p_object_id                    IN NUMBER
     ,p_obj_def_id                   IN NUMBER
   );

   PROCEDURE Register_Obj_Exe_Step(
     p_param_rec                     IN param_record
     ,p_exe_step                     IN VARCHAR2
     ,p_exe_status_code              IN VARCHAR2
   );

   PROCEDURE Eng_Master_Post_Proc (
     p_param_rec                     IN param_record
     ,p_exec_status_code             IN VARCHAR2
   );

   PROCEDURE Get_Put_Messages (
     p_msg_count                     IN NUMBER
     ,p_msg_data                     IN VARCHAR2
   );

   FUNCTION is_rule_set_flattened(
     p_request_id                    IN NUMBER
     ,p_rule_set_obj_id              IN NUMBER
   )

   RETURN NUMBER;

   PROCEDURE Update_Nbr_Of_Input_Rows(
     p_param_rec                     IN  param_record
     ,p_num_input_rows               IN  NUMBER
   );

   PROCEDURE Register_Dependent_Objects(
     p_param_rec                     IN param_record
   );

   PROCEDURE Register_Table(
     p_param_rec                     IN param_record
     ,p_tbl_name                     IN VARCHAR2
     ,p_num_output_rows              IN NUMBER
     ,p_stmt_type                    IN VARCHAR2
   );

   PROCEDURE Register_Updated_Column(
     p_param_rec                     IN  param_record
     ,p_table_name                   IN  VARCHAR2
     ,p_statement_type               IN  VARCHAR2
     ,p_column_name                  IN  VARCHAR2);

   -----------------------------------------------------------------------------
   -- Package bodies for functions/procedures
   -----------------------------------------------------------------------------
   /*==========================================================================+
   | PROCEDURE
   |   PROCESS REQUEST
   |
   | DESCRIPTION
   |   Main engine procedure for Profit Calculation step in PFT.
   |
   | SCOPE - PUBLIC
   |
   +==========================================================================*/


   PROCEDURE Process_Request( Errbuf                        OUT NOCOPY VARCHAR2,
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
   l_api_name         VARCHAR2(30) := 'Process_Request';
   l_api_version      NUMBER;
   l_commit           VARCHAR2(10);
   l_init_msg_list    VARCHAR2(10);

   -----------------------
   -- Declare variables --
   -----------------------

   x_return_status             VARCHAR2(1000);
   x_msg_count                 NUMBER;
   x_msg_data                  VARCHAR2 (1000);
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

   l_err_buf                   VARCHAR2(50);
   l_ret_code                  NUMBER;

   ----------------------------
   -- Declare static cursors --
   ----------------------------
   CURSOR l_rule_set_rules(p_request_id IN NUMBER,p_ruleset_obj_id IN NUMBER) IS
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
*                          Profit Calculation Master                           *
*                             Execution BLOCK                                  *
*                                                                              *
*******************************************************************************/

   BEGIN

      l_api_version   := 1.0;
      l_init_msg_list := FND_API.G_FALSE;
      l_commit        := FND_API.G_FALSE;

      --Initialize Local Parameters
      l_rule_set_rules_is_open   :=   FALSE;
      z_master_err_state         :=   FEM_UTILS.G_RSM_NO_ERR;
      -- initialize status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      FEM_ENGINES_PKG.Tech_Message( p_severity => g_log_level_2
                                   ,p_module   => G_BLOCK||l_api_name
                                   ,p_msg_text => 'BEGIN');

      fnd_log_repository.init;
      fnd_msg_pub.initialize;

      --------------------------------------------------------------------------
      -- Check for the required parameters
      --------------------------------------------------------------------------

      IF (p_obj_id IS NULL OR p_dataset_grp_obj_def_id IS NULL OR
          p_effective_date IS NULL OR p_output_cal_period_id IS NULL OR
          p_ledger_id IS NULL) THEN

         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_FEM
           ,p_msg_name => G_ENG_BAD_CONC_REQ_PARAM_ERR);

         RAISE e_pc_engine_error;
      END IF;

      --Do the engine master prep
      --------------------------------------------------------------------------
      -- STEP 1: Engine Master Preparation
      --------------------------------------------------------------------------

      FEM_ENGINES_PKG.tech_message (
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
      FEM_ENGINES_PKG.tech_message (
         p_severity => g_log_level_3
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Step 2: Register Request');

            --Register request
      Register_Process_Request(p_param_rec => l_param_rec);

      IF (l_param_rec.obj_type_code = 'PPROF_PROFIT_CALC') THEN
         -----------------------------------------------------------------------
         -- STEP 3: Processing for a single rule submission
         -----------------------------------------------------------------------
         FEM_ENGINES_PKG.tech_message (
            p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Step 3: Process for a single rule ');

         --Set the current processing object id
         l_param_rec.crnt_proc_child_obj_id  := l_param_rec.obj_id;

         Process_Single_Rule(p_param_rec => l_param_rec);

         FEM_ENGINES_PKG.tech_message (
            p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Status After Process for a single rule '
	                  || l_param_rec.return_status);

         IF (l_param_rec.return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            -- For Single Consolidation Rule, raise exception to end request
	    -- immediately with a completion status of ERROR, regardless of the
	    -- value for the continue_process_on_err_flg parameter.
            RAISE e_pc_engine_error;
         END IF;

      ELSIF (l_param_rec.obj_type_code = 'RULE_SET') THEN
         -----------------------------------------------------------------------
         -- STEP 4: Processing for a rule set
         -----------------------------------------------------------------------
         -----------------------------------------------------------------------
         -- STEP 4.1: Flattening the rule set
         -----------------------------------------------------------------------
         FEM_ENGINES_PKG.Tech_Message(
            p_severity  => g_log_level_3
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Step 3.1 Flatten the rule set');

         IF(is_rule_set_flattened(l_param_rec.request_id
                                 ,l_param_rec.crnt_proc_child_obj_id ) <> 0)THEN
            --------------------------------------------------------------------
            -- STEP 4.2: Preprocess rule set
            --------------------------------------------------------------------
            FEM_ENGINES_PKG.Tech_Message(
               p_severity  => g_log_level_1
              ,p_module    => G_BLOCK||'.'||l_api_name
              ,p_msg_text  => 'Step 4.2 PreProcess rule set' );

            Preprocess_Rule_Set( p_param_rec => l_param_rec);

         END IF;
         -----------------------------------------------------------------------
         -- STEP 4.3.1: Loop through each rule in the rule set
         -- STEP 4.3.2: Open cursor for rule set
         -- STEP 4.3.3: Process each rule in the rule set loop
         -- STEP 4.3.4: Execution status for rule processing
         -----------------------------------------------------------------------
         FEM_ENGINES_PKG.Tech_Message(
            p_severity => g_log_level_1
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Step 4.3.1: Loop through all Rule Set Rules');

          OPEN l_rule_set_rules(l_param_rec.request_id,l_param_rec.obj_id);

         l_rule_set_rules_is_open := TRUE;

         FEM_ENGINES_PKG.Tech_Message(
            p_severity => g_log_level_1
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Step 4.3.2:Rule set loop');

         LOOP
            FETCH l_rule_set_rules INTO l_next_rule_obj_id,
                                        l_next_rule_obj_def_id,
                                        l_next_rule_exec_status;

            FEM_ENGINES_PKG.Tech_Message(
               p_severity => g_log_level_1
              ,p_module   => G_BLOCK||'.'||l_api_name
              ,p_msg_text => 'Step 4.3.3: Process next rule in rule set: '
                             ||l_next_rule_obj_id);

            FEM_ENGINES_PKG.Tech_Message(
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
               -----------------------------------------------------------------
               -- STEP 4.2.3: Process Rule Set Rule
               -----------------------------------------------------------------
               FEM_ENGINES_PKG.Tech_Message(
                  p_severity => g_log_level_1
                 ,p_module   => G_BLOCK||'.'||l_api_name
                 ,p_msg_text => 'Step 4.3.5: Process Rule Set Rule #'
                                ||TO_CHAR(l_rollup_sequence));

               Process_Single_Rule(p_param_rec => l_param_rec );

               FEM_ENGINES_PKG.tech_message (
                  p_severity => g_log_level_3
                 ,p_module   => G_BLOCK||'.'||l_api_name
                 ,p_msg_text => 'Status After Process for a single rule '
	                        || l_param_rec.return_status);

               IF (l_param_rec.return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                  -- Set the request status to match Calculation Rule's
		  -- return status.
                  l_ruleset_status := l_param_rec.return_status;
                  IF (l_param_rec.continue_process_on_err_flg = 'N') THEN
                     -- Raise exception to end request immediately with
		     -- a completion status of ERROR.
                     RAISE e_pc_engine_error;
                  END IF;
               END IF;
            END IF;
         END LOOP;

         CLOSE l_rule_set_rules;

         IF (l_ruleset_status <> FND_API.G_RET_STS_SUCCESS) THEN
            -- Raise exception to end request with a completion status of ERROR,
            -- if the rule set status is not equal to SUCCESS.
            RAISE e_pc_engine_error;
         END IF;

      ELSE
         NULL;
      END IF;

      --------------------------------------------------------------------------
      -- STEP 5: Engine Master Post Processing.
      --------------------------------------------------------------------------
      FEM_ENGINES_PKG.Tech_Message (
         p_severity => g_log_level_3
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Step 5: Engine Master Post Processing');

      Eng_Master_Post_Proc ( p_param_rec         => l_param_rec
                            ,p_exec_status_code  => g_exec_status_success);

      --------------------------------------------------------------------------
      -- STEP 6: Standard API support
      --------------------------------------------------------------------------
      IF FND_API.To_Boolean(NVL(l_commit,'F')) THEN
         COMMIT WORK;
      END IF;

      /*  IF (l_rule_set_rules_is_open) THEN
         CLOSE l_rule_set_rules;
      END IF;*/
      IF (l_rule_set_rules%ISOPEN) THEN
         CLOSE l_rule_set_rules;
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      FEM_ENGINES_PKG.Tech_Message ( p_severity => g_log_level_2
                                    ,p_module   => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text => 'END');

   EXCEPTION
      WHEN e_pc_engine_error THEN
         --close the open cursors
         /*IF (l_rule_set_rules_is_open) THEN
            CLOSE l_rule_set_rules;
         END IF;*/

         IF (l_rule_set_rules%ISOPEN) THEN
            CLOSE l_rule_set_rules;
         END IF;

         FEM_ENGINES_PKG.Tech_Message (
            p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Step 5: Engine Master Post Processing: ERROR');

         Eng_Master_Post_Proc( p_param_rec        => l_param_rec
                              ,p_exec_status_code => g_exec_status_error_rerun);

         l_completion_status := FND_CONCURRENT.Set_Completion_Status('ERROR'
                                                                     ,NULL);

--         FEM_ENGINES_PKG.User_Message (
--            p_app_name => G_PFT
--           ,p_msg_name => 'Profit Calculation Engine Error');

        -- Set the return status to ERROR
         x_return_status := 'E';

         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Profit Calculation Engine Error');
      WHEN OTHERS THEN
         gv_prg_msg := SQLERRM;
         gv_callstack := DBMS_UTILITY.Format_Call_Stack;

          --close the open cursors
          /*IF (l_rule_set_rules_is_open) THEN
             CLOSE l_rule_set_rules;
          END IF;*/
          IF (l_rule_set_rules%ISOPEN) THEN
             CLOSE l_rule_set_rules;
          END IF;

         FEM_ENGINES_PKG.Tech_Message (
            p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Step 5: Engine Master Post Processing: ERROR');

          Eng_Master_Post_Proc( p_param_rec        => l_param_rec
                               ,p_exec_status_code => g_exec_status_error_rerun);

          l_completion_status := FND_CONCURRENT.Set_Completion_Status('ERROR'
                                                                      ,NULL);

          FEM_ENGINES_PKG.Tech_Message (
             p_severity => g_log_level_6
            ,p_module   => G_BLOCK||'.'||l_api_name||'.Unexpected Exception'
            ,p_msg_text => gv_prg_msg);

          FEM_ENGINES_PKG.Tech_Message (
             p_severity => g_log_level_6
            ,p_module   => G_BLOCK||'.'||l_api_name||'.Unexpected Exception'
            ,p_msg_text => gv_callstack);

          FEM_ENGINES_PKG.User_Message (
             p_app_name => G_FEM
            ,p_msg_name => G_UNEXPECTED_ERROR
            ,p_token1   => 'ERR_MSG'
            ,p_value1   => gv_prg_msg);

          -- Set the return status to UNEXP_ERROR
          x_return_status := 'U';

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

   e_eng_master_prep_error         EXCEPTION;

   BEGIN

      FEM_ENGINES_PKG.Tech_Message ( p_severity => g_log_level_2
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
      x_param_rec.user_id     :=  FND_GLOBAL.User_Id;
      x_param_rec.login_id    :=  FND_GLOBAL.Login_Id;
      x_param_rec.request_id  :=  FND_GLOBAL.Conc_Request_Id;
      x_param_rec.resp_id     :=  FND_GLOBAL.Resp_Id;
      x_param_rec.pgm_id      :=  FND_GLOBAL.Conc_Program_Id;
      x_param_rec.pgm_app_id  :=  FND_GLOBAL.Prog_Appl_Id;

      -- Get the limit for bulk fetches
      gv_fetch_limit :=  NVL (FND_PROFILE.Value_Specific ('FEM_BULK_FETCH_LIMIT'
                                                          ,x_param_rec.user_id
                                                          ,NULL
                                                          ,NULL)
                             ,g_default_fetch_limit);

    ----------------------------------------------------------------------------
    -- Get the object info from fem_object_catalog_b for the object_id passed in
    ----------------------------------------------------------------------------
      FEM_ENGINES_PKG.Tech_Message (
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
            FEM_ENGINES_PKG.User_Message (
               p_app_name => G_PFT
              ,p_msg_name => G_ENG_INVALID_OBJ_ERR
              ,p_token1   => 'OBJECT_ID'
              ,p_value1   => x_param_rec.obj_id);

            FEM_ENGINES_PKG.Tech_Message (
               p_severity => g_log_level_3
              ,p_module   => G_BLOCK||'.'||l_api_name
              ,p_msg_text => 'Invalid Object Id' || x_param_rec.obj_id);

         RAISE e_eng_master_prep_error;
      END;

      --------------------------------------------------------------------------
      -- If this is a Rule Set Submission, check that the object_type_code and
      -- local_vs_combo_id of the rule matches the Rule Set's.
      --------------------------------------------------------------------------
      IF (x_param_rec.obj_type_code = 'RULE_SET') THEN

         FEM_ENGINES_PKG.Tech_Message (
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
               FEM_ENGINES_PKG.User_Message (
                  p_app_name  => G_PFT
                 ,p_msg_name  => G_ENG_INV_OBJ_DEFN_RS_ERR
                 ,p_token1    => 'OBJECT_ID'
                 ,p_value1    => x_param_rec.obj_id
                 ,p_token2    => 'EFFECTIVE_DATE'
                 ,p_value2    => x_param_rec.effective_date);

               FEM_ENGINES_PKG.Tech_Message (
                  p_severity  => g_log_level_3
                 ,p_module    => G_BLOCK||'.'||l_api_name
                 ,p_msg_text  => 'No Definition found for the ruleset :'
                                 || x_param_rec.obj_id || 'for the Date :'
                                 || x_param_rec.effective_date);

            RAISE e_eng_master_prep_error;
         END;

      ELSIF (x_param_rec.obj_type_code =  'PPROF_PROFIT_CALC') THEN

         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_3
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Obj type code is a single rule');

         BEGIN
            Get_Object_Definition(
               p_object_type_code => x_param_rec.obj_type_code
              ,p_object_id        => x_param_rec.obj_id
              ,p_effective_date   => x_param_rec.effective_date
              ,x_obj_def_id       => x_param_rec.crnt_proc_child_obj_defn_id);

         EXCEPTION
            WHEN OTHERS THEN
               FEM_ENGINES_PKG.User_Message (
                  p_app_name  => G_PFT
                 ,p_msg_name  => G_ENG_INVALID_OBJ_DEFN_ERR
                 ,p_token1    => 'OBJECT_ID'
                 ,p_value1    => x_param_rec.obj_id
                 ,p_token2    => 'EFFECTIVE_DATE'
                 ,p_value2    => x_param_rec.effective_date);

               FEM_ENGINES_PKG.Tech_Message (
                  p_severity  => g_log_level_3
                 ,p_module    => G_BLOCK||'.'||l_api_name
                 ,p_msg_text  => 'No Definition found for the Rule :'
                                 || x_param_rec.obj_id || 'for the Date :'
                                 || x_param_rec.effective_date);
            RAISE e_eng_master_prep_error;
         END;
      ELSE
         FEM_ENGINES_PKG.User_Message(
            p_app_name  => G_PFT
           ,p_msg_name  => G_ENG_INVALIDRULETYPE_ERR
           ,p_token1    => 'OBJECT_TYPE_CODE'
           ,p_value1    => x_param_rec.obj_type_code);

         RAISE e_eng_master_prep_error;
      END IF;

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
            FEM_ENGINES_PKG.User_Message (
               p_app_name => G_PFT
              ,p_msg_name => G_ENG_INVALID_OBJ_ERR
              ,p_token1   => 'OBJECT_ID'
              ,p_value1   => x_param_rec.dataset_io_obj_def_id);

            FEM_ENGINES_PKG.Tech_Message (
               p_severity  => g_log_level_3
              ,p_module    => G_BLOCK||'.'||l_api_name
              ,p_msg_text  => 'No Object found for the given Dataset Group:'
                              || x_param_rec.dataset_io_obj_def_id);
         RAISE e_eng_master_prep_error;
      END;
      --------------------------------------------------------------------------
      -- Get the Output Dataset Code
      --------------------------------------------------------------------------
      BEGIN
         SELECT  output_dataset_code
           INTO  x_param_rec.output_dataset_code
         FROM    fem_ds_input_output_defs
         WHERE   dataset_io_obj_def_id = x_param_rec.dataset_io_obj_def_id;

      EXCEPTION
         WHEN OTHERS THEN
            FEM_ENGINES_PKG.User_Message (
               p_app_name => G_PFT
              ,p_msg_name => G_ENG_NO_OUTPUT_DS_ERR
              ,p_token1   => 'DATASET_GROUP_OBJ_DEF_ID'
              ,p_value1   => x_param_rec.dataset_io_obj_def_id);

            FEM_ENGINES_PKG.Tech_Message (
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
               FEM_ENGINES_PKG.User_Message (
                  p_app_name  => G_PFT
                 ,p_msg_name  => G_ENG_INVALID_OBJ_ERR
                 ,p_token1   => 'OBJECT_ID'
                 ,p_value1   => x_param_rec.obj_id);

            RAISE e_eng_master_prep_error;
         END;

      END IF;

      -- Log all Request Record Parameters if we have low level debugging
      IF ( FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) ) THEN

         FEM_ENGINES_PKG.Tech_Message (
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
           ' user_id='||x_param_rec.user_id
         );

      END IF;

      FEM_ENGINES_PKG.Tech_Message ( p_severity => G_LOG_LEVEL_2
                                    ,p_module   => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text => 'END');

   EXCEPTION
      WHEN e_eng_master_prep_error THEN

         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Engine Master Preperation Exception');
      RAISE e_pc_engine_error;

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

   l_return_status                VARCHAR2(1);
   l_msg_count                    NUMBER;
   l_msg_data                     VARCHAR2(240);

   e_pl_register_request_error    EXCEPTION;

   BEGIN

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
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
        ,p_source_system_code     =>  p_param_rec.source_system_code
        ,p_effective_date         =>  p_param_rec.effective_date
        ,p_output_dataset_code    =>  p_param_rec.output_dataset_code
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
        ,x_msg_count              =>  l_msg_count
        ,x_msg_data               =>  l_msg_data
        ,x_return_status          =>  l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         Get_Put_Messages ( p_msg_count => l_msg_count
                           ,p_msg_data  => l_msg_data);

          RAISE  e_pl_register_request_error;
      END IF;

      COMMIT;

      FEM_ENGINES_PKG.Tech_Message (
         p_severity => g_log_level_1
        ,p_module   => G_BLOCK||'.'||l_api_name
        ,p_msg_text => 'Request id is '||p_param_rec.request_id);

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'END');

   EXCEPTION
      WHEN e_pl_register_request_error THEN

         ROLLBACK TO register_request_pub;

         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Register Request Exception');

         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_REG_REQUEST_ERR
           ,p_token1    => 'REQUEST_ID'
           ,p_value1    => p_param_rec.request_id);

      RAISE e_pc_engine_error;

      WHEN OTHERS THEN

         ROLLBACK TO register_request_pub;

         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_REG_REQUEST_ERR
           ,p_token1    => 'REQUEST_ID'
           ,p_value1    => p_param_rec.request_id);

      RAISE e_pc_engine_error;

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

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      -- Call the FEM_PL_PKG.Register_Object_Def API procedure to register
      -- the specified object definition in FEM_PL_OBJECT_DEFS, thus obtaining
      -- an object definition lock.
      FEM_PL_PKG.Register_Object_Def (
         p_api_version          =>  1.0
        ,p_commit               =>  FND_API.G_FALSE
        ,p_request_id           =>  p_param_rec.request_id
        ,p_object_id            =>  p_object_id
        ,p_object_definition_id =>  p_obj_def_id
        ,p_user_id              =>  p_param_rec.user_id
        ,p_last_update_login    =>  p_param_rec.login_id
        ,x_msg_count            =>  l_msg_count
        ,x_msg_data             =>  l_msg_data
        ,x_return_status        =>  l_return_status);

      -- Object Definition Lock exists
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

         Get_Put_Messages ( p_msg_count => l_msg_count
                           ,p_msg_data  => l_msg_data);
         RAISE e_register_obj_def_error;
      END IF;

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'END');

   EXCEPTION
      WHEN e_register_obj_def_error THEN
         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Register Object Definition Exception');

         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_OBJ_EXECLOCK_EXISTS_ERR
           ,p_token1    => 'REQUEST_ID'
           ,p_value1    => p_param_rec.request_id);

      RAISE e_pc_engine_error;

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

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      -- Call the FEM_PL_PKG.Register_Object_Def API procedure to register step
      -- in fem_pl_obj_steps.
      FEM_PL_PKG.Register_Obj_Exec_Step (
         p_api_version         =>  1.0
        ,p_commit              =>  FND_API.G_FALSE
        ,p_request_id          =>  p_param_rec.request_id
        ,p_object_id           =>  p_param_rec.crnt_proc_child_obj_id
        ,p_exec_step           =>  p_exe_step
        ,p_exec_status_code    =>  p_exe_status_code
        ,p_user_id             =>  p_param_rec.user_id
        ,p_last_update_login   =>  p_param_rec.login_id
        ,x_msg_count           =>  l_msg_count
        ,x_msg_data            =>  l_msg_data
       ,x_return_status        =>  l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

         Get_Put_Messages ( p_msg_count => l_msg_count
                           ,p_msg_data  => l_msg_data);
         RAISE e_register_obj_exe_step_error;
      END IF;

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'END');

   EXCEPTION
      WHEN e_register_obj_exe_step_error THEN
         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Register Obj Exec Step Exception');

         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_REG_EXEC_STEP_ERR
           ,p_token1    => 'OBJECT_ID'
           ,p_value1    => p_param_rec.crnt_proc_child_obj_id);

      RAISE e_pc_engine_error;

      WHEN OTHERS THEN
         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_REG_EXEC_STEP_ERR
           ,p_token1    => 'OBJECT_ID'
           ,p_value1    => p_param_rec.crnt_proc_child_obj_id);

      RAISE e_pc_engine_error;

   END Register_Obj_Exe_Step;

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

   l_api_name          CONSTANT  VARCHAR2(30) := 'Preprocess_Rule_Set';

   l_return_status               VARCHAR2(1);
   l_msg_count                   NUMBER;
   l_msg_data                    VARCHAR2(240);
   e_pl_preprocess_rule_set_err  EXCEPTION;

   BEGIN

      FEM_ENGINES_PKG.Tech_Message( p_severity => g_log_level_2
                                   ,p_module   => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text => 'BEGIN');

      FEM_RULE_SET_MANAGER.Fem_Preprocess_RuleSet_Pvt(
         p_api_version                 =>  G_CALLING_API_VERSION
        ,p_init_msg_list               =>  FND_API.G_FALSE
        ,p_commit                      =>  FND_API.G_TRUE
        ,p_encoded                     =>  FND_API.G_TRUE
        ,p_orig_ruleset_object_id      =>  p_param_rec.obj_id
        ,p_ds_io_def_id                =>  p_param_rec.dataset_io_obj_def_id
        ,p_rule_effective_date         =>  p_param_rec.effective_date_varchar
        ,p_output_period_id            =>  p_param_rec.output_cal_period_id
        ,p_ledger_id                   =>  p_param_rec.ledger_id
        ,p_continue_process_on_err_flg =>  p_param_rec.continue_process_on_err_flg
        ,p_execution_mode              =>  'E'-- Engine Execution Mode
        ,x_return_status               =>  l_return_status
        ,x_msg_count                   =>  l_msg_count
        ,x_msg_data                    =>  l_msg_data);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         Get_Put_Messages ( p_msg_count => l_msg_count
                           ,p_msg_data  => l_msg_data);

         RAISE e_pl_preprocess_rule_set_err ;

      END IF;

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'END');

   EXCEPTION
      WHEN e_pl_preprocess_rule_set_err  THEN
         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Preprocess Rule Set Exception' );

         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_ENG_PRE_PROC_RS_ERR
           ,p_token1    => 'RULE_SET_OBJ_ID'
           ,p_value1    => p_param_rec.obj_id);

      RAISE e_pc_engine_error;

      WHEN OTHERS THEN
         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_ENG_PRE_PROC_RS_ERR
           ,p_token1    => 'RULE_SET_OBJ_ID'
           ,p_value1    => p_param_rec.obj_id);

      RAISE e_pc_engine_error;

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
   l_err_code                   NUMBER := 0;
   l_err_msg                    VARCHAR2(255);
   l_prev_req_id                NUMBER;
   l_exec_state                 VARCHAR2(30);
   l_reuse_slices               VARCHAR2(10);
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(200);
   l_return_status              VARCHAR2(50):= NULL;
   l_ds_where_clause            LONG := NULL;
   l_region_counting_flag       VARCHAR2(1);
   l_proft_percentile_flag      VARCHAR2(1);
   l_value_index_flag           VARCHAR2(1);
   l_prospect_ident_flag        VARCHAR2(1);
   l_customer_level             NUMBER;
   l_output_column              VARCHAR2(30);
   l_value_index_formula_id     NUMBER;
   l_region_percent             NUMBER;
   l_profit_percentile          NUMBER;

   TYPE v_percentile_type       IS TABLE OF
                               fem_customer_profit.profit_percentile%TYPE;
   v_percentile                v_percentile_type;

   e_process_single_rule_error  EXCEPTION;
   e_register_rule_error        EXCEPTION;

   BEGIN
      -- Initialize the return status to SUCCESS
      p_param_rec.return_status  := FND_API.G_RET_STS_SUCCESS;

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => g_log_level_2
        ,p_module    => G_BLOCK||'.'||l_api_name
        ,p_msg_text  => 'Validate the Rule Definition');

      FEM_RULE_SET_MANAGER.Validate_Rule_Public(
              x_Err_Code            =>  l_err_code
             ,x_Err_Msg             =>  l_err_msg
             ,p_Rule_Object_ID      =>  p_param_rec.crnt_proc_child_obj_id
             ,p_DS_IO_Def_ID        =>  p_param_rec.dataset_io_obj_def_id
             ,p_Rule_Effective_Date =>  p_param_rec.effective_date_varchar
             ,p_Reference_Period_ID =>  p_param_rec.output_cal_period_id
             ,p_Ledger_ID           =>  p_param_rec.ledger_id);

      -- Unexpected error
      IF (l_err_code <> 0) THEN
         FEM_ENGINES_PKG.User_Message (p_app_name => G_PFT
                                      ,p_msg_name => l_err_msg);

         RAISE e_process_single_rule_error;

      END IF;

      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => g_log_level_1
        ,p_module    => G_BLOCK||'.'||l_api_name
        ,p_msg_text  => 'PROCESSING OBJECT ID: '
                        ||p_param_rec.crnt_proc_child_obj_id
                        ||'AND PROCESSING OBJECT DEFINITION ID: '
                        ||p_param_rec.crnt_proc_child_obj_defn_id);

      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => g_log_level_3
        ,p_module    => G_BLOCK||'.'||l_api_name
        ,p_msg_text  => 'Getting Profit Calculation Rule Details');


      BEGIN
         -- get the details of the rule
         SELECT value_index_formula_id,
                condition_obj_id,
                region_counting_flag,
                proft_percentile_flag,
                value_index_flag,
                prospect_ident_flag,
                customer_level,
                output_column
           INTO l_value_index_formula_id,
                p_param_rec.cond_obj_id,
                l_region_counting_flag,
                l_proft_percentile_flag,
                l_value_index_flag,
                l_prospect_ident_flag,
                l_customer_level,
                l_output_column
         FROM   pft_pprof_calc_rules
         WHERE  pprof_calc_obj_def_id = p_param_rec.crnt_proc_child_obj_defn_id;

      EXCEPTION
         WHEN no_data_found THEN
            FEM_ENGINES_PKG.User_Message (
               p_app_name  => G_PFT
              ,p_msg_name  => G_ENG_INVALID_OBJ_DEFN_ERR
              ,p_token1    => 'OBJECT_ID'
              ,p_value1    => p_param_rec.crnt_proc_child_obj_id
              ,p_token2    => 'EFFECTIVE_DATE'
              ,p_value2    => p_param_rec.effective_date);

         RAISE e_process_single_rule_error;

      END;

         -- Call the FEM_PL_PKG.Register_Object_Execution API procedure
         -- to register the rollup object execution in FEM_PL_OBJECT_EXECUTIONS,
         -- thus obtaining an execution lock.
      BEGIN
         SAVEPOINT register_rule_pub;

         FEM_PL_PKG.Register_Object_Execution(
            p_api_version               =>  G_CALLING_API_VERSION
           ,p_commit                    =>  FND_API.G_TRUE
           ,p_request_id                =>  p_param_rec.request_id
           ,p_object_id                 =>  p_param_rec.crnt_proc_child_obj_id
           ,p_exec_object_definition_id =>  p_param_rec.crnt_proc_child_obj_defn_id
           ,p_user_id                   =>  p_param_rec.user_id
           ,p_last_update_login         =>  p_param_rec.login_id
           ,p_exec_mode_code            =>  NULL
           ,x_exec_state                =>  l_exec_state
           ,x_prev_request_id           =>  l_prev_req_id
           ,x_msg_count                 =>  l_msg_count
           ,x_msg_data                  =>  l_msg_data
           ,x_return_status             =>  l_return_status);

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
            Get_Put_Messages (p_msg_count => l_msg_count
                             ,p_msg_data  => l_msg_data);

            RAISE e_register_rule_error;

         END IF;

      EXCEPTION
         WHEN e_register_rule_error THEN
            ROLLBACK TO register_rule_pub;

	    FEM_ENGINES_PKG.Tech_Message (
               p_severity  => G_LOG_LEVEL_6
              ,p_module    => G_BLOCK||'.'||l_api_name
              ,p_msg_text  => 'Register Rule Exception');

            FEM_ENGINES_PKG.User_Message (
               p_app_name  => G_PFT
              ,p_msg_name  => G_PL_OBJ_EXEC_LOCK_ERR);

            p_param_rec.return_status  := FND_API.G_RET_STS_ERROR;

         RAISE e_process_single_rule_error;
      END;

      --------------------------------------------------------------------------
      --call to FEM_PL_PKG.register_dependent_objdefs
      --------------------------------------------------------------------------
      FEM_ENGINES_PKG.Tech_Message( p_severity => g_log_level_3
                                   ,p_module   => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text => 'Register_Dependent_Objects');

      Register_Dependent_Objects( p_param_rec => p_param_rec);

     ---------------------------------------------------------------------------
     --Register the dependant object 'Dataset Group' object
     ---------------------------------------------------------------------------
      FEM_ENGINES_PKG.Tech_Message( p_severity => g_log_level_3
                                   ,p_module   => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text => 'Register_Dataset_Grp_Object');

      Register_Object_Definition (
              p_param_rec   => p_param_rec
             ,p_object_id   => p_param_rec.crnt_proc_child_obj_id
             ,p_obj_def_id  => p_param_rec.dataset_io_obj_def_id );

      -- CHECKPOINT RESTART
      -- check executed state and jump to appropriate statement
      -- depending on which step was last executed successfully
      IF(l_exec_state = 'RESTART') THEN
         l_reuse_slices := 'Y';
      ELSE
         l_reuse_slices := 'N';
      END IF;
      --------------------------------------------------------------------------
      --Check the Calculation Options selected in the rule and call appropriate
      --Engines.
      --------------------------------------------------------------------------
      --Check whether Region Counting is selected
      IF (l_region_counting_flag = 'Y') THEN
         -- Region Counting should be performed only once for a period
         BEGIN
            SELECT COUNT (region_pct_total_cust)
              INTO l_region_percent
            FROM   fem_region_info
            WHERE  cal_period_id = p_param_rec.output_cal_period_id
              AND  ledger_id = p_param_rec.ledger_id
              AND  dataset_code = p_param_rec.output_dataset_code
              AND  source_system_code = p_param_rec.source_system_code
              AND  dimension_group_id = l_customer_level;
         EXCEPTION
            WHEN no_data_found THEN
               FEM_ENGINES_PKG.Tech_Message (
                  p_severity => g_log_level_3
                 ,p_module   => G_BLOCK||'.'||l_api_name
                 ,p_msg_text => 'Region Counting is Already
                                Performed for the Specified Period');

               FEM_ENGINES_PKG.User_Message (
                  p_app_name  => G_PFT
                 ,p_msg_name  => G_ENG_RGN_CNT_DONE_ERR
                 ,p_token1    => 'CAL_PERIOD_ID'
                 ,p_value1    => p_param_rec.output_cal_period_id);

         END;

         IF l_region_percent = 0 THEN
         -----------------------------------------------------------------------
         -- Call FEM_PL_PKG.Register_Table()
         -----------------------------------------------------------------------
         FEM_ENGINES_PKG.Tech_Message(
            p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Register Table:REGION_COUNTING');

         Register_Table( p_param_rec        =>  p_param_rec
                        ,p_tbl_name         =>  g_fem_region_info
                        ,p_num_output_rows  =>  0
                        ,p_stmt_type        =>  g_insert);

         -----------------------------------------------------------------------
         -- Register this step
         -----------------------------------------------------------------------
         FEM_ENGINES_PKG.Tech_Message( p_severity => g_log_level_3
                                      ,p_module   => G_BLOCK||'.'||l_api_name
                                      ,p_msg_text => 'Register the step ');

         Register_Obj_Exe_Step( p_param_rec       => p_param_rec
                               ,p_exe_step        => 'RGN_CNT'
                               ,p_exe_status_code => l_exec_state );

         PFT_PROFCAL_RGNCNT_PUB.Process_Single_Rule (
            p_rule_obj_id           =>  p_param_rec.crnt_proc_child_obj_id
           ,p_cal_period_id         =>  p_param_rec.output_cal_period_id
           ,p_dataset_io_obj_def_id =>  p_param_rec.dataset_io_obj_def_id
           ,p_output_dataset_code   =>  p_param_rec.output_dataset_code
           ,p_effective_date        =>  p_param_rec.effective_date_varchar
           ,p_ledger_id             =>  p_param_rec.ledger_id
           ,p_source_system_code    =>  p_param_rec.source_system_code
           ,p_customer_level        =>  l_customer_level
           ,p_exec_state            =>  l_exec_state
           ,x_return_status         =>  l_return_status);

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
            Get_Put_Messages (p_msg_count => l_msg_count
                             ,p_msg_data  => l_msg_data);

            FEM_ENGINES_PKG.User_Message (
               p_app_name  => G_PFT
              ,p_msg_name  => 'Region Counting Engine Exception');

            RAISE e_process_single_rule_error;
         END IF;

         p_param_rec.return_status  := FND_API.G_RET_STS_SUCCESS;

         ELSE
            FEM_ENGINES_PKG.Tech_Message (
               p_severity => g_log_level_3
              ,p_module   => G_BLOCK||'.'||l_api_name
              ,p_msg_text => 'Region Counting is Already
	                      Performed for the Specified Period');

            FEM_ENGINES_PKG.User_Message (
               p_app_name  => G_PFT
              ,p_msg_name  => G_ENG_RGN_CNT_DONE_ERR
              ,p_token1    => 'CAL_PERIOD_ID'
              ,p_value1    => p_param_rec.output_cal_period_id);

         END IF;
      END IF;

      --Check whether Customer Profit Percentile is selected
      IF (l_proft_percentile_flag = 'Y') THEN
         -- Profit Percentile should be performed only once for a period
         BEGIN
            SELECT COUNT (profit_percentile)
              INTO l_profit_percentile
            FROM   fem_customer_profit
            WHERE  cal_period_id = p_param_rec.output_cal_period_id
              AND  ledger_id = p_param_rec.ledger_id
              AND  dataset_code = p_param_rec.output_dataset_code
              AND  source_system_code = p_param_rec.source_system_code
              AND  data_aggregation_type_code = 'CUSTOMER_AGGREGATION';

         EXCEPTION
            WHEN no_data_found THEN
               FEM_ENGINES_PKG.Tech_Message (
                  p_severity => g_log_level_3
                 ,p_module   => G_BLOCK||'.'||l_api_name
                 ,p_msg_text => 'Profit Percentile is Already
	                        Performed for the Specified Period');

               FEM_ENGINES_PKG.User_Message (
                  p_app_name  => G_PFT
                 ,p_msg_name  => G_ENG_PPTILE_DONE_ERR
                 ,p_token1    => 'CAL_PERIOD_ID'
                 ,p_value1    => p_param_rec.output_cal_period_id);

         END;

         -- Start of Bug # 4906275
         IF l_profit_percentile <> 0 THEN
            v_percentile := v_percentile_type();
	    BEGIN
	       SELECT profit_percentile
                 BULK COLLECT INTO v_percentile
               FROM   fem_customer_profit
               WHERE  cal_period_id = p_param_rec.output_cal_period_id
                 AND  ledger_id = p_param_rec.ledger_id
                 AND  dataset_code = p_param_rec.output_dataset_code
                 AND  source_system_code = p_param_rec.source_system_code
                 AND  data_aggregation_type_code = 'CUSTOMER_AGGREGATION';

               FOR i IN 1..v_percentile.COUNT LOOP
                  IF v_percentile(i) = 0 THEN
	             l_profit_percentile := 0;
                  END IF;
               END LOOP;
            END;

         END IF;
         -- End of Bug # 4906275

         IF l_profit_percentile = 0 THEN
         -----------------------------------------------------------------------
         -- Call FEM_PL_PKG.Register_Table()
         -----------------------------------------------------------------------
         FEM_ENGINES_PKG.Tech_Message( p_severity => g_log_level_3
                                      ,p_module   => G_BLOCK||'.'||l_api_name
                                      ,p_msg_text => 'Register table:CUST_PPTILE');

         Register_Table( p_param_rec        =>  p_param_rec
                        ,p_tbl_name         =>  g_fem_customer_profit
                        ,p_num_output_rows  =>  0
                        ,p_stmt_type        =>  g_update);

         FEM_ENGINES_PKG.Tech_Message(
            p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Register updt colmn:CUST_PPTILE');

         Register_Updated_Column( p_param_rec        =>  p_param_rec
                                  ,p_table_name      =>  g_fem_customer_profit
                                  ,p_statement_type  =>  g_update
                                  ,p_column_name     =>  'PROFIT_PERCENTILE');

         Register_Updated_Column( p_param_rec        =>  p_param_rec
                                  ,p_table_name      =>  g_fem_customer_profit
                                  ,p_statement_type  =>  g_update
                                  ,p_column_name     =>  'PROFIT_DECILE');

         -----------------------------------------------------------------------
         -- Register this step
         -----------------------------------------------------------------------
         FEM_ENGINES_PKG.Tech_Message(
            p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Register the step: CUST_PPTILE');

         Register_Obj_Exe_Step( p_param_rec        => p_param_rec
                               ,p_exe_step         => 'CUST_PPTILE'
                               ,p_exe_status_code  => l_exec_state );

         PFT_PROFCAL_CUST_PPTILE_PUB.Process_Single_Rule (
            p_rule_obj_id           =>  p_param_rec.crnt_proc_child_obj_id
           ,p_cal_period_id         =>  p_param_rec.output_cal_period_id
           ,p_dataset_io_obj_def_id =>  p_param_rec.dataset_io_obj_def_id
           ,p_output_dataset_code   =>  p_param_rec.output_dataset_code
           ,p_effective_date        =>  p_param_rec.effective_date_varchar
           ,p_ledger_id             =>  p_param_rec.ledger_id
           ,p_source_system_code    =>  p_param_rec.source_system_code
           ,p_customer_level        =>  l_customer_level
           ,p_exec_state            =>  l_exec_state
           ,x_return_status         =>  l_return_status);

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
            Get_Put_Messages (p_msg_count => l_msg_count
                             ,p_msg_data  => l_msg_data);

            FEM_ENGINES_PKG.User_Message (
               p_app_name  => G_PFT
              ,p_msg_name  => 'Profit Percentile Engine Exception');

            RAISE e_process_single_rule_error;
         END IF;

         p_param_rec.return_status  := FND_API.G_RET_STS_SUCCESS;
         ELSE
            FEM_ENGINES_PKG.Tech_Message (
               p_severity => g_log_level_3
              ,p_module   => G_BLOCK||'.'||l_api_name
              ,p_msg_text => 'Profit Percentile is Already
	                     Performed for the Specified Period');

            FEM_ENGINES_PKG.User_Message (
               p_app_name  => G_PFT
              ,p_msg_name  => G_ENG_PPTILE_DONE_ERR
              ,p_token1    => 'CAL_PERIOD_ID'
              ,p_value1    => p_param_rec.output_cal_period_id);

         END IF;
      END IF;

      --Check whether Caluclate Value Index is selected
      IF (l_value_index_flag = 'Y') THEN
      --SSHANMUG .. A special case which needs to be handled later

      /*IF(l_proft_percentile_flag = 'N' AND l_region_counting_flag = 'N') THEN
         -- WIP
         -- Call Register_Chaining();
         --
      END IF;*/

         -----------------------------------------------------------------------
         -- Call FEM_PL_PKG.Register_Table()
         -----------------------------------------------------------------------
         FEM_ENGINES_PKG.Tech_Message( p_severity => g_log_level_3
                                      ,p_module   => G_BLOCK||'.'||l_api_name
                                      ,p_msg_text => 'Register table:Value Index');

         Register_Table( p_param_rec        =>  p_param_rec
                        ,p_tbl_name         =>  g_fem_customer_profit
                        ,p_num_output_rows  =>  0
                        ,p_stmt_type        =>  g_update);

         -----------------------------------------------------------------------
         -- Register this step
         -----------------------------------------------------------------------
         FEM_ENGINES_PKG.Tech_Message(
            p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Register the step:VALUE_INDEX');

         Register_Obj_Exe_Step( p_param_rec       => p_param_rec
                               ,p_exe_step        => 'VAL_IDX'
                               ,p_exe_status_code => l_exec_state );

         PFT_PROFCAL_VALIDX_PUB.Process_Single_Rule (
            p_rule_obj_id            =>  p_param_rec.crnt_proc_child_obj_id
           ,p_cal_period_id          =>  p_param_rec.output_cal_period_id
           ,p_dataset_io_obj_def_id  =>  p_param_rec.dataset_io_obj_def_id
           ,p_output_dataset_code    =>  p_param_rec.output_dataset_code
           ,p_effective_date         =>  p_param_rec.effective_date_varchar
           ,p_ledger_id              =>  p_param_rec.ledger_id
           ,p_source_system_code     =>  p_param_rec.source_system_code
           ,p_value_index_formula_id =>  l_value_index_formula_id
           ,p_rule_obj_def_id        =>  p_param_rec.crnt_proc_child_obj_defn_id
	   ,p_region_counting_flag   =>  l_region_counting_flag
	   ,p_proft_percentile_flag  =>  l_proft_percentile_flag
           ,p_customer_level         =>  l_customer_level
           ,p_cond_obj_id            =>  p_param_rec.cond_obj_id
           ,p_output_column          =>  l_output_column
           ,p_exec_state             =>  l_exec_state
           ,x_return_status          =>  l_return_status);

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
            Get_Put_Messages (p_msg_count => l_msg_count
                             ,p_msg_data  => l_msg_data);

            FEM_ENGINES_PKG.User_Message (
               p_app_name  => G_PFT
              ,p_msg_name  => 'Value Index Engine Exception');

            RAISE e_process_single_rule_error;

         END IF;

         p_param_rec.return_status  := FND_API.G_RET_STS_SUCCESS;

      END IF;

      --Check whether Prospect Identification is selected
   /*   IF (l_prospect_ident_flag = 'Y') THEN
         -----------------------------------------------------------------------
         -- Call FEM_PL_PKG.Register_Table()
         -----------------------------------------------------------------------
         FEM_ENGINES_PKG.Tech_Message(
            p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Register table:Prospect Identification');

         Register_Table( p_param_rec        =>  p_param_rec
                        ,p_tbl_name         =>  g_fem_customers_attr
                        ,p_num_output_rows  =>  0
                        ,p_stmt_type        =>  g_update);

         Register_Updated_Column( p_param_rec       =>  p_param_rec
                                 ,p_table_name      =>  g_fem_customers_attr
                                 ,p_statement_type  =>  g_update
                                 ,p_column_name     =>  'VARCHAR_ASSIGN_VALUE');

         -----------------------------------------------------------------------
         -- Register this step
         -----------------------------------------------------------------------
         FEM_ENGINES_PKG.Tech_Message(
            p_severity => g_log_level_3
           ,p_module   => G_BLOCK||'.'||l_api_name
           ,p_msg_text => 'Register the step:PROSP_IDENT');

         Register_Obj_Exe_Step( p_param_rec       => p_param_rec
                               ,p_exe_step        => 'PROSP_IDENT'
                               ,p_exe_status_code => l_exec_state );

         PFT_PROFCAL_PROSP_IDENT_PUB.Process_Single_Rule (
            p_rule_obj_id           =>  p_param_rec.crnt_proc_child_obj_id
           ,p_cal_period_id         =>  p_param_rec.output_cal_period_id
           ,p_dataset_io_obj_def_id =>  p_param_rec.dataset_io_obj_def_id
           ,p_output_dataset_code   =>  p_param_rec.output_dataset_code
           ,p_effective_date        =>  p_param_rec.effective_date_varchar
           ,p_ledger_id             =>  p_param_rec.ledger_id
           ,p_source_system_code    =>  p_param_rec.source_system_code
           ,p_exec_state            =>  l_exec_state
           ,x_return_status         =>  l_return_status);

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
            Get_Put_Messages (p_msg_count => l_msg_count
                             ,p_msg_data  => l_msg_data);

            FEM_ENGINES_PKG.User_Message (
               p_app_name  => G_PFT
              ,p_msg_name  => 'Prospect Identification Engine Exception');

            RAISE e_process_single_rule_error;

         END IF;

      END IF; */
   EXCEPTION
      WHEN e_process_single_rule_error THEN
         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Process Single Rule Exception');

--         FEM_ENGINES_PKG.User_Message (p_app_name  => G_PFT
--                                      ,p_msg_name  => G_ENG_SINGLE_RULE_ERR);

        p_param_rec.return_status  := FND_API.G_RET_STS_ERROR;

      WHEN OTHERS THEN

         FEM_ENGINES_PKG.User_Message (p_app_name  => G_PFT
                                      ,p_msg_name  => G_ENG_SINGLE_RULE_ERR);

         p_param_rec.return_status  := FND_API.G_RET_STS_ERROR;

   END Process_Single_Rule;

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
      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
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
      FEM_ENGINES_PKG.Tech_Message ( p_severity  => G_LOG_LEVEL_2
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

   PROCEDURE Eng_Master_Post_Proc ( p_param_rec                IN param_record
                                   ,p_exec_status_code         IN VARCHAR2)
   IS

   l_api_name             CONSTANT VARCHAR2(30) := 'Eng_Master_Post_Proc';

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(240);

   e_eng_master_post_proc_error    EXCEPTION;


   BEGIN

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      --------------------------------------------------------------------------
      -- STEP 1: Update Object Execution Status.
      --------------------------------------------------------------------------
      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => g_log_level_1
        ,p_module    => G_BLOCK||'.'||l_api_name
        ,p_msg_text  => 'Step 1:  Update Object Execution Status');

      FEM_PL_PKG.Update_Obj_Exec_Status (
         p_api_version       =>  1.0
        ,p_commit            =>  FND_API.G_FALSE
        ,p_request_id        =>  p_param_rec.request_id
        ,p_object_id         =>  p_param_rec.crnt_proc_child_obj_id
        ,p_exec_status_code  =>  p_exec_status_code
        ,p_user_id           =>  p_param_rec.user_id
        ,p_last_update_login =>  p_param_rec.login_id
        ,x_msg_count         =>  l_msg_count
        ,x_msg_data          =>  l_msg_data
        ,x_return_status     =>  l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         Get_Put_Messages ( p_msg_count => l_msg_count
                           ,p_msg_data  => l_msg_data);
         RAISE e_eng_master_post_proc_error;
      END IF;

      --------------------------------------------------------------------------
      -- STEP 2: Update Object Execution Errors.
      --------------------------------------------------------------------------
      IF (p_exec_status_code <> g_exec_status_success) THEN

         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_1
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Step 2:  Update Object Execution Errors');

         FEM_PL_PKG.Update_Obj_Exec_Errors (
               p_api_version        => 1.0
              ,p_commit             => FND_API.G_FALSE
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
      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => g_log_level_1
        ,p_module    => G_BLOCK||'.'||l_api_name
        ,p_msg_text  => 'Step 3:  Update Request Status');

      FEM_PL_PKG.Update_Request_Status (
          p_api_version       => 1.0
         ,p_commit            => FND_API.G_FALSE
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

      COMMIT;

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'END');

   EXCEPTION
      WHEN e_eng_master_post_proc_error THEN
         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Engine Master Post Process Exception');


         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_ENG_ENGINE_POST_PROC_ERR
           ,p_token1    => 'OBJECT_ID'
           ,p_value1    => p_param_rec.obj_id);

      RAISE e_pc_engine_error;

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

   PROCEDURE Get_Object_Definition ( p_object_type_code      IN VARCHAR2
                                    ,p_object_id             IN NUMBER
                                    ,p_effective_date        IN DATE
                                    ,x_obj_def_id            OUT NOCOPY NUMBER)

   IS

   l_api_name             CONSTANT VARCHAR2(30) := 'Get_Object_Definition';

   BEGIN

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      SELECT  d.object_definition_id
        INTO  x_obj_def_id
      FROM    fem_object_definition_b d
             ,fem_object_catalog_b o
      WHERE   o.object_id = p_object_id
        AND   o.object_type_code = p_object_type_code
        AND   d.object_id = o.object_id
        AND   p_effective_date BETWEEN d.effective_start_date AND d.effective_end_date
        AND   d.old_approved_copy_flag = 'N';

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'END');

   EXCEPTION
      WHEN no_data_found THEN
         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_ENG_INVALID_OBJ_DEFN_ERR
           ,p_token1    => 'OBJECT_ID'
           ,p_value1    => p_object_id
           ,p_token2    => 'EFFECTIVE_DATE'
           ,p_value2    => p_effective_date);

      RAISE  e_pc_engine_error;

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
              ,p_msg_text => 'msg_data='||l_message);

         END LOOP;

      END IF;

      FND_MSG_PUB.Initialize;

   END Get_Put_Messages;

   --SSHANMUG : Added additional proc for PL Implementation
 /*============================================================================+
 | PROCEDURE
 |   Register_dependent_objdefs
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

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      -- Register all the Dependent Objects for CALC
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

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'END');

   EXCEPTION
      WHEN e_register_dep_obj_def_error  THEN
         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Register Dependant Objects Exception');

         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_DEP_OBJ_DEF_ERR
           ,p_token1    => 'OBJ_DEF_ID'
           ,p_value1    => p_param_rec.crnt_proc_child_obj_defn_id);

      RAISE e_pc_engine_error;

      WHEN OTHERS THEN
         FEM_ENGINES_PKG.Tech_Message (
	    p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Register Dependant Objects Exception');

         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_DEP_OBJ_DEF_ERR
           ,p_token1    => 'OBJ_DEF_ID'
           ,p_value1    => p_param_rec.crnt_proc_child_obj_defn_id);

      RAISE e_pc_engine_error;

   END Register_Dependent_Objects;

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
   PROCEDURE Update_Nbr_Of_Input_Rows( p_param_rec        IN  param_record
                                      ,p_num_input_rows  IN  NUMBER)
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

      RAISE e_pc_engine_error;

      WHEN OTHERS THEN
         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Update Input Rows Exception');

         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_IP_UPD_ROWS_ERR);

      RAISE e_pc_engine_error;

   END Update_Nbr_Of_Input_Rows;

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

   PROCEDURE Register_Table( p_param_rec       IN param_record
                            ,p_tbl_name        IN VARCHAR2
                            ,p_num_output_rows IN NUMBER
                            ,p_stmt_type       IN VARCHAR2)
   IS

   l_api_name             CONSTANT VARCHAR2(30) := 'Register_Table';

   l_return_status                 VARCHAR2(1);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(240);

   e_register_table_error          EXCEPTION;

   BEGIN

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      -- Call the FEM_PL_PKG.Register_Table API procedure to register
      -- the specified output table and the statement type that will be used.
      FEM_PL_PKG.Register_Table(
         p_api_version          =>  1.0
        ,p_commit               =>  FND_API.G_FALSE
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

      FEM_ENGINES_PKG.Tech_Message( p_severity  => g_log_level_2
                                   ,p_module    => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text  => 'END');

   EXCEPTION
      WHEN e_register_table_error THEN
         FEM_ENGINES_PKG.Tech_Message(
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Register Table Exception');

         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_REG_TABLE_ERR
           ,p_token1    => 'TABLE_NAME'
           ,p_value1    => p_tbl_name);

      RAISE e_pc_engine_error;

      WHEN OTHERS THEN
         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_REG_TABLE_ERR
           ,p_token1    => 'TABLE_NAME'
           ,p_value1    => p_tbl_name);

      RAISE e_pc_engine_error;

   END Register_Table;

 /*============================================================================+
 | PROCEDURE
 |   Register_Updated_Column
 |
 | DESCRIPTION
 |   This procedure is used to register a column updated during object execution
 |
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/
   PROCEDURE Register_Updated_Column( p_param_rec       IN  param_record
                                     ,p_table_name      IN  VARCHAR2
                                     ,p_statement_type  IN  VARCHAR2
                                     ,p_column_name     IN  VARCHAR2)
   IS

   l_api_name   CONSTANT VARCHAR2(30) := 'Register_Updated_Column';

   l_return_status       VARCHAR2(2);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(240);

   e_reg_updated_column_error     EXCEPTION;

   BEGIN

      FEM_ENGINES_PKG.Tech_Message ( p_severity  => g_log_level_2
                                    ,p_module    => G_BLOCK||'.'||l_api_name
                                    ,p_msg_text  => 'BEGIN');

      -- Set the number of output rows for the output table.
      FEM_PL_PKG.register_updated_column(
         p_api_version          =>  1.0
        ,p_commit               =>  FND_API.G_TRUE
        ,p_request_id           =>  p_param_rec.request_id
        ,p_object_id            =>  p_param_rec.crnt_proc_child_obj_id
        ,p_table_name           =>  p_table_name
        ,p_statement_type       =>  p_statement_type
        ,p_column_name          =>  p_column_name
        ,p_user_id              =>  p_param_rec.user_id
        ,p_last_update_login    =>  p_param_rec.login_id
        ,x_msg_count            =>  l_msg_count
        ,x_msg_data             =>  l_msg_data
        ,x_return_status        =>  l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

         Get_Put_Messages( p_msg_count => l_msg_count
                          ,p_msg_data  => l_msg_data);
         RAISE e_reg_updated_column_error;
      END IF;

      FEM_ENGINES_PKG.Tech_Message( p_severity  => g_log_level_2
                                   ,p_module    => G_BLOCK||'.'||l_api_name
                                   ,p_msg_text  => 'END');

   EXCEPTION
      WHEN e_reg_updated_column_error THEN
         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Register_Updated_Column_Exception');

         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_REG_UPD_COL_ERR
           ,p_token1    => 'TABLE_NAME'
           ,p_value1    => p_table_name
           ,p_token2    => 'COLUMN_NAME'
           ,p_value2    => p_column_name);

      RAISE e_pc_engine_error;

      WHEN OTHERS THEN
         FEM_ENGINES_PKG.Tech_Message (
            p_severity  => g_log_level_5
           ,p_module    => G_BLOCK||'.'||l_api_name
           ,p_msg_text  => 'Register_Updated_Column_Exception');

         FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_PFT
           ,p_msg_name  => G_PL_REG_UPD_COL_ERR
           ,p_token1    => 'TABLE_NAME'
           ,p_value1    => p_table_name
           ,p_token2    => 'COLUMN_NAME'
           ,p_value2    => p_column_name);

      RAISE e_pc_engine_error;

   END Register_Updated_Column;

 /*============================================================================+
 | PROCEDURE
 |   Register_Chaining
 |
 | DESCRIPTION
 |   This procedure is used to register the chain if this rule uses any
 | previously executed rules.
 |
 |
 | SCOPE - PRIVATE
 |
 +=============================================================================+
   PROCEDURE Register_Chaining()
   IS

   BEGIN

      Requirement :
      -------------
         If a new rule (say V1) is created with Value Index formula refers to 'Region Counting' and 'Profit Percentile'
         which is executed by some other rule(say R1), we need to call 'fem_pl_pkg.register_chain' to register this chain
         so that when ever R1 is undone (using 'UNDO UI'), V1 should also be undone.

      Logic:
      ------
         Get the concurrent req Id and Object Id of Rule R1 and call fem_pl_pkg.register_chain.

      EXCEPTION

      END Register_Chaining */

END PFT_PPROFCAL_MASTER_PUB;

/
