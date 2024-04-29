--------------------------------------------------------
--  DDL for Package Body FEM_GL_POST_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_GL_POST_PROCESS_PKG" AS
/* $Header: fem_gl_post_proc.plb 120.11.12010000.2 2009/06/27 00:27:08 ghall ship $ */

/**************************************************************************
-- Private Package Variables and exceptions
**************************************************************************/

   pc_log_level_statement       CONSTANT NUMBER   := fnd_log.level_statement;
   pc_log_level_procedure       CONSTANT NUMBER   := fnd_log.level_procedure;
   pc_log_level_event           CONSTANT NUMBER   := fnd_log.level_event;
   pc_log_level_exception       CONSTANT NUMBER   := fnd_log.level_exception;
   pc_log_level_error           CONSTANT NUMBER   := fnd_log.level_error;
   pc_log_level_unexpected      CONSTANT NUMBER   := fnd_log.level_unexpected;

   pc_API_version               CONSTANT NUMBER   := 1.0;

   pv_proc_name                 VARCHAR2(30);

   pv_API_return_code           NUMBER;

   pv_dim_attr_id               fem_dim_attributes_b.attribute_id%TYPE;
   pv_dim_attr_ver_id           fem_dim_attr_versions_b.version_id%TYPE;
   pv_attr_label                fem_dim_attributes_b.attribute_varchar_label%TYPE;
   pv_dim_name                  fem_dimensions_tl.dimension_name%TYPE;

   pv_obj_type_cd               fem_object_catalog_b.object_type_code%TYPE;
   pv_cal_per_calendar_id       fem_cal_periods_b.calendar_id%TYPE;
   pv_ledger_calendar_id        fem_hierarchies.calendar_id%TYPE;
   pv_precedent_dataset_code    fem_datasets_b.dataset_code%TYPE;

   Invalid_Budget_ID            EXCEPTION;
   Invalid_Budget_or_Dataset    EXCEPTION;
   Invalid_Cal_Period_ID        EXCEPTION;
   Invalid_Dataset_Code         EXCEPTION;
   Warn_DS_Bal_Type             EXCEPTION;
   Invalid_Enc_Type_ID          EXCEPTION;
   Invalid_Enc_or_Dataset       EXCEPTION;
   Invalid_Engine_Parameter     EXCEPTION;
   Invalid_Execution_Mode       EXCEPTION;
   Invalid_Ledger_ID            EXCEPTION;
   Invalid_Obj_Approval_Status  EXCEPTION;
   Invalid_Object_Def_ID        EXCEPTION;
   Invalid_Object_ID            EXCEPTION;
   Invalid_QTD_YTD              EXCEPTION;
   Invalid_Request_ID           EXCEPTION;
   Invalid_Runtime_Parameter    EXCEPTION;
   Ledger_Cal_NEQ_Period_Cal    EXCEPTION;
   Value_Set_ID_Error           EXCEPTION;
   User_Not_Allowed             EXCEPTION;


/**************************************************************************
-- Private Procedure Declarations
**************************************************************************/

   PROCEDURE Get_Dim_IDs;


   PROCEDURE Validate_Budget;

   PROCEDURE Validate_Cal_Period;

   PROCEDURE Validate_Dataset;

   PROCEDURE Validate_DS_Bal_Type;

   PROCEDURE Validate_Encumbrance_Type;

   PROCEDURE Validate_Ledger;

   PROCEDURE Validate_Object_Def_ID;


   PROCEDURE Validate_Engine_Parameters (x_completion_code OUT NOCOPY NUMBER);


/**************************************************************************
-- Public Procedures
**************************************************************************/

-- =======================================================================
   PROCEDURE Validate_XGL_Eng_Parameters
                (p_ledger_id               IN  NUMBER,
                 p_cal_period_id           IN  NUMBER,
                 p_dataset_code            IN  NUMBER,
                 p_xgl_obj_def_id          IN  NUMBER,
                 p_exec_mode               IN  VARCHAR2,
                 p_qtd_ytd_code            IN  VARCHAR2 DEFAULT NULL,
                 p_budget_id               IN  NUMBER DEFAULT NULL,
                 p_enc_type_id             IN  NUMBER DEFAULT NULL,
                 x_completion_code         OUT NOCOPY NUMBER) IS
-- =======================================================================
-- Purpose
--    XGL-specific wrapper for Validate_Engine_Parameters, which has
--    functionality that is common to both engines.  All functionality
--    for setting package variables and validating engine parameters
--    that is specific to the XGL engine should go here.
-- History
--    11-13-03  G Hall  Created
--    12-02-03  G Hall  Added Object Type validation
--    01-27-04  G Hall  Moved the Object ID lookup to
--                      Validate_Object_Def_ID.
--    05-12-04  G Hall  Bug# 3610446: Added validation for p_qtd_ytd_code
--                      parameter.
-- Arguments
--    All of the IN arguments are the same as the IN arguments for the
--    FEM_XGL_POST_ENGINE_PKG.Main procedure.
--    x_completion_code returns 0 for success, 1 for warning, 2 for failure.
-- Notes
--    Called from the beginning of FEM_XGL_POST_ENGINE_PKG.Main
-- =======================================================================

      v_row_count     NUMBER;

   BEGIN

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'validate_xgl_eng_parameters.begin',
         p_msg_text => 'BEGIN');

   -- --------------------------------------------------------------------
   -- Set all engine parameters as public package variables
   -- --------------------------------------------------------------------

      pv_ledger_id        := p_ledger_id;
      pv_cal_period_id    := p_cal_period_id;
      pv_dataset_code     := p_dataset_code;
      pv_rule_obj_def_id  := p_xgl_obj_def_id;
      pv_exec_mode        := p_exec_mode;
      -- Updated by L Poon to fix the GSCC warning - File.Sql.35
      pv_qtd_ytd_code     := NVL(p_qtd_ytd_code, 'PTD');
      pv_budget_id        := p_budget_id;
      pv_enc_type_id      := p_enc_type_id;

   -- --------------------------------------------------------------------
   -- Log debug messages to display values for those variables
   -- --------------------------------------------------------------------

      FEM_ENGINES_PKG.Tech_Message
      (p_severity    => pc_log_level_statement,
       p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                     'validate_xgl_eng_parameters.pv_ledger_id',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_ledger_id',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_ledger_id));

      FEM_ENGINES_PKG.Tech_Message
      (p_severity    => pc_log_level_statement,
       p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                     'validate_xgl_eng_parameters.pv_cal_period_id',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_cal_period_id',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_cal_period_id));

      FEM_ENGINES_PKG.Tech_Message
      (p_severity    => pc_log_level_statement,
       p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                     'validate_xgl_eng_parameters.pv_dataset_code',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_dataset_code',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_dataset_code));

      FEM_ENGINES_PKG.Tech_Message
      (p_severity    => pc_log_level_statement,
       p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                     'validate_xgl_eng_parameters.pv_budget_id',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_budget_id',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_budget_id));

      FEM_ENGINES_PKG.Tech_Message
      (p_severity    => pc_log_level_statement,
       p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                     'validate_xgl_eng_parameters.pv_enc_type_id',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_enc_type_id',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_enc_type_id));

      FEM_ENGINES_PKG.Tech_Message
      (p_severity    => pc_log_level_statement,
       p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                     'validate_xgl_eng_parameters.pv_exec_mode',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_exec_mode',
       p_token2   => 'VAR_VAL',
       p_value2   => pv_exec_mode);

      FEM_ENGINES_PKG.Tech_Message
      (p_severity    => pc_log_level_statement,
       p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                     'validate_xgl_eng_parameters.pv_rule_obj_def_id',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_rule_obj_def_id',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_rule_obj_def_id));

      FEM_ENGINES_PKG.Tech_Message
      (p_severity    => pc_log_level_statement,
       p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                     'validate_xgl_eng_parameters.pv_qtd_ytd_code',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_qtd_ytd_code',
       p_token2   => 'VAR_VAL',
       p_value2   => pv_qtd_ytd_code);

   -- --------------------------------------------------------------------
   -- Validate the p_qtd_ytd_code engine parameter.
   -- --------------------------------------------------------------------

      SELECT COUNT(*)
      INTO v_row_count
      FROM fnd_lookup_values
      WHERE lookup_type = 'FEM_XGL_QTD_YTD_DSC'
        AND lookup_code = pv_qtd_ytd_code
        AND language = USERENV('LANG')
        AND view_application_id = 274;

      IF v_row_count = 0 THEN

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_statement,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'validate_xgl_eng_parameters.iqy',
            p_msg_text => 'raising Invalid_QTD_YTD');

         RAISE Invalid_QTD_YTD;

      END IF;

   -- --------------------------------------------------------------------
   -- Set package variables common to both GL posting engines and
   -- validate the engine parameters that are common to both engines.
   -- --------------------------------------------------------------------

      Validate_Engine_Parameters
        (x_completion_code => x_completion_code);

      IF x_completion_code = 2 THEN

         RAISE Invalid_Engine_Parameter;

      END IF;

   -- Validate that the rule to be executed is an XGL_INTEGRATION rule.

      IF pv_obj_type_cd <> 'XGL_INTEGRATION' THEN

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_statement,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'validate_xgl_eng_parameters.iobj2.',
            p_msg_text => 'raising Invalid_Object_ID');

         RAISE Invalid_Object_ID;

      END IF;

   -- Successful completion

      IF x_completion_code <> 1 THEN
         x_completion_code := 0;
      END IF;

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'validate_xgl_eng_parameters.end',
         p_msg_text => 'END');

   EXCEPTION
      WHEN Invalid_Engine_Parameter THEN
      ------------------------------------------------------------------
      -- Messages are aleady logged, x_completion_code is already set.
      ------------------------------------------------------------------
         NULL;

      WHEN Invalid_Object_ID THEN
      ------------------------------------------------------------------
      -- Invalid External GL Integration Rule:  Value not found or rule
      -- has the wrong Object Type.
      ------------------------------------------------------------------
         x_completion_code := 2;

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_error,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'validate_xgl_eng_parameters.invalid_object_id',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_010');

         FEM_ENGINES_PKG.User_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_010');

      WHEN Invalid_QTD_YTD THEN
      ------------------------------------------------------------------
      -- Invalid parameter.  Value not found.  Parameter Name:
      -- P_QTD_YTD_CODE (Period Specific Amounts Provided)
      ------------------------------------------------------------------
         x_completion_code := 2;

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_error,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'validate_xgl_eng_parameters.invalid_qtd_ytd',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_001',
            p_token1   => 'DIMENSION_NAME',
            p_value1   => 'P_QTD_YTD_CODE (Period Specific Amounts Provided)');

         FEM_ENGINES_PKG.User_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_001',
            p_token1   => 'DIMENSION_NAME',
            p_value1   => 'P_QTD_YTD_CODE (Period Specific Amounts Provided)');

      WHEN OTHERS THEN
      ------------------------------------------------------------------
      -- Unexpected exceptions
      ------------------------------------------------------------------
         pv_sqlerrm   := SQLERRM;
         pv_callstack := dbms_utility.format_call_stack;

         x_completion_code := 2;

      -- Log the call stack and the Oracle error message to
      -- FND_LOG with the "unexpected exception" severity level.

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'validate_xgl_eng_parameters.unexpected_exception',
            p_msg_text => pv_sqlerrm);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'validate_xgl_eng_parameters.unexpected_exception',
            p_msg_text => pv_callstack);

      -- Log the Oracle error message to the Concurrent Request Log.

         FEM_ENGINES_PKG.User_Message
           (p_app_name => 'FEM',
            p_msg_text => pv_sqlerrm);

   END Validate_XGL_Eng_Parameters;
-- =======================================================================


-- =======================================================================
   PROCEDURE Register_Process_Execution
               (x_completion_code OUT NOCOPY NUMBER) IS
-- =======================================================================
-- Purpose
--    Registers the concurrent request in FEM_PL_REQUESTS, registers
--    the object execution in FEM_PL_OBJECT_EXECUTIION, obtaining an
--    FEM "execution lock, and performs other FEM process initialization
--    steps.
-- History
--    11-13-03  G Hall  Created
--    01-27-04  G Hall  Added P_EXEC_MODE_CODE parameter in call
--                      to Register_Request.
--    03-10-04  G Hall  Added OA-compliant parameters to all
--                      Process Lock procedure calls.
--    03-16-04  G Hall  Added debug messages for message stack
--                      operations; added p_msg_index to call to
--                      FND_MSG_PUB.Get.
--    05-13-04  G Hall  Bug# 3597495: Removed call to Register_Data_Location.
--                      Final_Process_Logging now makes a call for each
--                      valid Source System Code processed.
--    08-23-05  G Hall  Bug# 4521255: Fixed message decoding after API calls
--                      when x_msg_count = 1.
-- Arguments
--    x_completion_code returns 0 for success, 2 for failure.
-- Notes
--    Called by FEM_XGL_POST_ENGINE_PKG.Main or by
--    FEM_OGL_POST_ENGINE.Main prior to processing.
-- =======================================================================

      v_return_status    VARCHAR2(1);
      v_msg_count        NUMBER;
      v_msg_data         VARCHAR2(2000);

      i                  PLS_INTEGER;

      v_exec_lock_exists BOOLEAN := FALSE;

      API_Error          EXCEPTION;

   BEGIN

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'register_process_execution.begin',
         p_msg_text => 'BEGIN');

   -- Call the FEM_PL_PKG.Register_Request API procedure to register
   -- the concurrent request in FEM_PL_REQUESTS.

      FND_MSG_PUB.Initialize;

      FEM_PL_PKG.Register_Request
        (P_API_VERSION            => pc_API_version,
         P_COMMIT                 => 'T',
         P_CAL_PERIOD_ID          => pv_cal_period_id,
         P_LEDGER_ID              => pv_ledger_id,
         P_OUTPUT_DATASET_CODE    => pv_dataset_code,
         P_REQUEST_ID             => pv_req_id,
         P_USER_ID                => pv_user_id,
         P_LAST_UPDATE_LOGIN      => pv_login_id,
         P_PROGRAM_ID             => pv_pgm_id,
         P_PROGRAM_LOGIN_ID       => pv_login_id,
         P_PROGRAM_APPLICATION_ID => pv_pgm_app_id,
         P_EXEC_MODE_CODE         => pv_exec_mode,
         X_MSG_COUNT              => v_msg_count,
         X_MSG_DATA               => v_msg_data,
         X_RETURN_STATUS          => v_return_status);

      IF v_return_status <> 'S' THEN

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_statement,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'register_process_execution.rrapie',
            p_msg_text => 'raising API_Error');

         RAISE API_Error;

      END IF;

   -- Check for process locks and process overlaps, validate the Execution Mode
   -- parameter, validate the period (for snapshot loads only), and register
   -- the execution in FEM_PL_OBJECT_EXECUTIONS, obtaining an execution lock.

      FND_MSG_PUB.Initialize;

      FEM_PL_PKG.Register_Object_Execution
        (P_API_VERSION               => pc_API_version,
         P_COMMIT                    => 'T',
         P_REQUEST_ID                => pv_req_id,
         P_OBJECT_ID                 => pv_rule_obj_id,
         P_EXEC_OBJECT_DEFINITION_ID => pv_rule_obj_def_id,
         P_USER_ID                   => pv_user_id,
         P_LAST_UPDATE_LOGIN         => pv_login_id,
         P_EXEC_MODE_CODE            => pv_exec_mode,
         X_EXEC_STATE                => pv_exec_state,
         X_PREV_REQUEST_ID           => pv_prev_req_id,
         X_MSG_COUNT                 => v_msg_count,
         X_MSG_DATA                  => v_msg_data,
         X_RETURN_STATUS             => v_return_status);

      IF v_return_status <> 'S' THEN

         IF v_return_status = 'E' THEN
         -- Lock exists
            v_exec_lock_exists := TRUE;
         END IF;

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_statement,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'register_process_execution.roeapie',
            p_msg_text => 'raising API_Error');

         RAISE API_Error;

      END IF;

      FEM_ENGINES_PKG.Tech_Message
      (p_severity    => pc_log_level_statement,
       p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                     'register_process_execution.pv_exec_state',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_exec_state',
       p_token2   => 'VAR_VAL',
       p_value2   => pv_exec_state);

      IF pv_exec_state = 'RERUN' THEN

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'register_process_execution.pv_prev_req_id',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'pv_prev_req_id',
          p_token2   => 'VAR_VAL',
          p_value2   => TO_CHAR(pv_prev_req_id));

      END If;

   -- Register the Object Definition ID together with this process execution in
   -- FEM_PL_OBJECT_DEFS to establish the required edit locks on the executed
   -- rule version.

      FND_MSG_PUB.Initialize;

      FEM_PL_PKG.Register_Object_Def
        (P_API_VERSION          => pc_API_version,
         P_COMMIT               => 'T',
         P_REQUEST_ID           => pv_req_id,
         P_OBJECT_ID            => pv_rule_obj_id,
         P_OBJECT_DEFINITION_ID => pv_rule_obj_def_id,
         P_USER_ID              => pv_user_id,
         P_LAST_UPDATE_LOGIN    => pv_login_id,
         X_MSG_COUNT            => v_msg_count,
         X_MSG_DATA             => v_msg_data,
         X_RETURN_STATUS        => v_return_status);

      IF v_return_status <> 'S' THEN

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_statement,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'register_process_execution.rodapie',
            p_msg_text => 'raising API_Error');

         RAISE API_Error;

      END IF;

   -- Log Undo information in FEM_PL_TABLES for rows inserted or merged into
   -- FEM_BALANCES.

      -- FEM-OGL Intg: Replace v_stmt_type by pv_stmt_type
      IF pv_exec_mode = 'S' THEN
         pv_stmt_type := 'INSERT';
      ELSE
         pv_stmt_type := 'MERGE';
      END IF;

      FND_MSG_PUB.Initialize;

      FEM_PL_PKG.Register_Table
        (P_API_VERSION        => pc_API_version,
         P_COMMIT             => 'T',
         P_REQUEST_ID         => pv_req_id,
         P_OBJECT_ID          => pv_rule_obj_id,
         P_TABLE_NAME         => 'FEM_BALANCES',
         P_STATEMENT_TYPE     => pv_stmt_type,
         P_NUM_OF_OUTPUT_ROWS => 0,
         P_USER_ID            => pv_user_id,
         P_LAST_UPDATE_LOGIN  => pv_login_id,
         X_MSG_COUNT          => v_msg_count,
         X_MSG_DATA           => v_msg_data,
         X_RETURN_STATUS      => v_return_status);

      IF v_return_status <> 'S' THEN

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_statement,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'register_process_execution.rtapie',
            p_msg_text => 'raising API_Error');

         RAISE API_Error;

      END IF;

   -- Successful completion

      x_completion_code := 0;

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'register_process_execution.end',
         p_msg_text => 'END');

   EXCEPTION

      WHEN API_Error THEN

         x_completion_code := 2;

      -- Technical messages have already been logged by the API; user
      -- messages are on the message stack.

         FND_MSG_PUB.Count_and_Get(
           p_encoded => 'F',
           p_count => v_msg_count,
           p_data => v_msg_data);

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'register_process_execution.v_msg_count',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'v_msg_count',
          p_token2   => 'VAR_VAL',
          p_value2   => TO_CHAR(v_msg_count));

         IF v_msg_count = 1 THEN

            FEM_ENGINES_PKG.Tech_Message
            (p_severity    => pc_log_level_statement,
             p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                           'register_process_execution.v_msg_data1',
             p_app_name => 'FEM',
             p_msg_name => 'FEM_GL_POST_204',
             p_token1   => 'VAR_NAME',
             p_value1   => 'v_msg_data',
             p_token2   => 'VAR_VAL',
             p_value2   => v_msg_data);

            FEM_ENGINES_PKG.User_Message
              (p_app_name => 'FEM',
               p_msg_text => v_msg_data);

         ELSIF v_msg_count > 1 THEN

            FOR i IN 1 .. v_msg_count LOOP

            -- Try fuller call here; see Tim's doc.

               v_msg_data :=
                  FND_MSG_PUB.Get(p_msg_index => i, p_encoded => 'F');

               FEM_ENGINES_PKG.Tech_Message
               (p_severity    => pc_log_level_statement,
                p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                              'register_process_execution.v_msg_data2.',
                p_app_name => 'FEM',
                p_msg_name => 'FEM_GL_POST_204',
                p_token1   => 'VAR_NAME',
                p_value1   => 'v_msg_data',
                p_token2   => 'VAR_VAL',
                p_value2   => v_msg_data);

               FEM_ENGINES_PKG.User_Message
                 (p_app_name => 'FEM',
                  p_msg_text => v_msg_data);

            END LOOP;

         END IF;

         IF v_exec_lock_exists THEN

         -- Unregister the concurrent request.

            FEM_PL_PKG.Unregister_Request
              (P_API_VERSION   => pc_API_version,
               P_COMMIT        => 'T',
               P_REQUEST_ID    => pv_req_id,
               X_MSG_COUNT     => v_msg_count,
               X_MSG_DATA      => v_msg_data,
               X_RETURN_STATUS => v_return_status);

         END IF;

      WHEN OTHERS THEN
      --------------------------------------------------------------------
      -- Unexpected exceptions
      --------------------------------------------------------------------
         x_completion_code := 2;

         pv_sqlerrm   := SQLERRM;
         pv_callstack := dbms_utility.format_call_stack;

      -- Log the call stack and the Oracle error message to
      -- FND_LOG with the "unexpected exception" severity level.

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'register_process_execution.unexpected_exception',
            p_msg_text => pv_sqlerrm);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'register_process_execution.unexpected_exception',
            p_msg_text => pv_callstack);

      -- Log the Oracle error message to the Concurrent Request Log.

         FEM_ENGINES_PKG.User_Message
           (p_app_name => 'FEM',
            p_msg_text => pv_sqlerrm);

   END Register_Process_Execution;
-- =======================================================================


-- =======================================================================
   PROCEDURE Final_Process_Logging
                (p_exec_status             IN  VARCHAR2,
                 p_num_data_errors         IN  NUMBER,
                 p_num_data_errors_reproc  IN  NUMBER,
                 p_num_output_rows         IN  NUMBER,
                 p_final_message_name      IN  VARCHAR2) IS
-- =======================================================================
-- Purpose
--    Performs final process logging after process completion.
-- History
--    11-13-03  G Hall  Created
--    03-10-04  G Hall  Added OA-compliant parameters to all
--                      Process Locks procedure calls.
--    03-16-04  G Hall  Added debug messages for message stack
--                      operations; added p_msg_index to call to
--                      FND_MSG_PUB.Get.
--    03-17-04  G Hall  Removed logging of p_final_message_name
--                      parameter to the Debug Log and the
--                      Concurrent Request Log. The parameter will
--                      be eliminated altogether during MP
--                      implementation.
--    05-12-04  G Hall  Reinstated logging of p_final_message_name
--                      parameter to the Debug Log and the
--                      Concurrent Request Log, and removed redundant
--                      message calls from Main.
--    05-13-04  G Hall  Bug# 3597495: Added a call to Register_Data_Location
--                      for each valid Source System Code processed.
--    05-25-04  G Hall  Changed call to Get_SSC_Not_Processed to parameterized
--                      call to Get_SSC.
--    07-06-05  G Hall  Bug# 4050862 Added successful and error row counts
--                      message to concurrent log file.
-- Arguments
--    p_exec_status             The final completion status:
--                              'SUCCESS','CANCELLED_RERUN','ERROR_RERUN'.
--    p_num_data_errors         The total number of data rows rejected
--                              with errors, including reprocessed
--                              previous errors that are still errors.
--    p_num_data_errors_reproc  The total number of previous error rows
--                              successfully reprocessed.
--    p_num_output_rows         The total number of rows inserted or
--                              merged into FEM_BALANCES by the engine.
--    p_final_message_name      The name of the final message to be logged
--                              for the engine.
-- Notes
--    Called by FEM_XGL_POST_ENGINE_PKG.Main or by
--    FEM_OGL_POST_ENGINE.Main after processing is complete.
-- =======================================================================

      v_return_status    VARCHAR2(1);
      v_msg_count        NUMBER;
      v_msg_data         VARCHAR2(2000);

      v_statement_type   fem_pl_tables.statement_type%TYPE;
      v_src_sys_code     fem_source_systems_b.source_system_code%TYPE;

      i                  PLS_INTEGER;
      j                  PLS_INTEGER;

   BEGIN

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'final_process_logging.begin',
         p_msg_text => 'BEGIN');

   -- Update the total number of rows inserted and/or updated in FEM_BALANCES
   -- by this execution, in the entry already posted in FEM_PL_TABLES.

      IF pv_exec_mode = 'S' THEN
         v_statement_type := 'INSERT';
      ELSE
         v_statement_type := 'MERGE';
      END IF;

      FND_MSG_PUB.Initialize;

      FEM_PL_PKG.Update_Num_of_Output_Rows
        (P_API_VERSION        => pc_API_version,
         P_COMMIT             => 'T',
         P_REQUEST_ID         => pv_req_id,
         P_OBJECT_ID          => pv_rule_obj_id,
         P_TABLE_NAME         => 'FEM_BALANCES',
         P_STATEMENT_TYPE     => v_statement_type,
         P_NUM_OF_OUTPUT_ROWS => p_num_output_rows,
         P_USER_ID            => pv_user_id,
         P_LAST_UPDATE_LOGIN  => pv_login_id,
         X_MSG_COUNT          => v_msg_count,
         X_MSG_DATA           => v_msg_data,
         X_RETURN_STATUS      => v_return_status);

   -- Log the number of data errors flagged on individual input rows in the
   -- interface table in this execution and the number of previously failed
   -- rows successfully reprocessed in this execution.

      FEM_PL_PKG.Update_Obj_Exec_Errors
        (P_API_VERSION        => pc_API_version,
         P_COMMIT             => 'T',
         P_REQUEST_ID         => pv_req_id,
         P_OBJECT_ID          => pv_rule_obj_id,
         P_ERRORS_REPORTED    => p_num_data_errors,
         P_ERRORS_REPROCESSED => p_num_data_errors_reproc,
         P_USER_ID            => pv_user_id,
         P_LAST_UPDATE_LOGIN  => pv_login_id,
         X_MSG_COUNT          => v_msg_count,
         X_MSG_DATA           => v_msg_data,
         X_RETURN_STATUS      => v_return_status);

   -- Update the status of the object execution from 'RUNNING' to
   -- 'SUCCESS', 'CANCELLED_RERUN', or 'ERROR_RERUN'.

      FEM_PL_PKG.Update_Obj_Exec_Status
        (P_API_VERSION        => pc_API_version,
         P_COMMIT             => 'T',
         P_REQUEST_ID         => pv_req_id,
         P_OBJECT_ID          => pv_rule_obj_id,
         P_EXEC_STATUS_CODE   => p_exec_status,
         P_USER_ID            => pv_user_id,
         P_LAST_UPDATE_LOGIN  => pv_login_id,
         X_MSG_COUNT          => v_msg_count,
         X_MSG_DATA           => v_msg_data,
         X_RETURN_STATUS      => v_return_status);

   -- Update the status of the concurrent request from 'RUNNING' to
   -- 'SUCCESS', 'CANCELLED_RERUN', or 'ERROR_RERUN'.

      FEM_PL_PKG.Update_Request_Status
        (P_API_VERSION        => pc_API_version,
         P_COMMIT             => 'T',
         P_REQUEST_ID         => pv_req_id,
         P_EXEC_STATUS_CODE   => p_exec_status,
         P_USER_ID            => pv_user_id,
         P_LAST_UPDATE_LOGIN  => pv_login_id,
         X_MSG_COUNT          => v_msg_count,
         X_MSG_DATA           => v_msg_data,
         X_RETURN_STATUS      => v_return_status);

      FND_MSG_PUB.Count_and_Get(
        p_encoded => 'F',
        p_count => v_msg_count,
        p_data => v_msg_data);

      IF v_msg_count = 1 THEN

         FEM_ENGINES_PKG.User_Message
           (p_app_name => 'FEM',
            p_msg_text => v_msg_data);

      ELSIF v_msg_count > 1 THEN

         FOR i IN 1 .. v_msg_count LOOP

            v_msg_data :=
               FND_MSG_PUB.Get(p_msg_index => i, p_encoded => 'F');

            FEM_ENGINES_PKG.User_Message
              (p_app_name => 'FEM',
               p_msg_text => v_msg_data);

         END LOOP;

      END IF;

      IF pv_ssc_where IS NOT NULL THEN

      -- -----------------------------------------------------------------------
      -- Register a data locations entry for each Source System Code processed,
      -- as 'COMPLETE' or 'INCOMPLETE' depending on whether or not there are
      -- any remaining error rows from the current process for that Source
      -- System Code.  If pv_ssc_where is NULL, a fatal error has occurred
      -- before any rows could be processed, so there is nothing to log in
      -- Data Locations.
      -- -----------------------------------------------------------------------

      -- Get the distinct list of Source System Codes with remaining error rows
      -- for the current process set.

         Get_SSC (p_dest_code => 'NP');

         j := 1;

      -- Loop thru the Source System Codes "To Be Processed" and compare them
      -- with the Source System Codes "Not (fully) Processed".

         FOR i IN 1..pv_ssc_tbp.count LOOP

            FEM_ENGINES_PKG.Tech_Message
            (p_severity    => pc_log_level_statement,
             p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                           'final_process_logging.i',
             p_app_name => 'FEM',
             p_msg_name => 'FEM_GL_POST_204',
             p_token1   => 'VAR_NAME',
             p_value1   => 'i',
             p_token2   => 'VAR_VAL',
             p_value2   => TO_CHAR(i));

            FEM_ENGINES_PKG.Tech_Message
            (p_severity    => pc_log_level_statement,
             p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                           'final_process_logging.j',
             p_app_name => 'FEM',
             p_msg_name => 'FEM_GL_POST_204',
             p_token1   => 'VAR_NAME',
             p_value1   => 'j',
             p_token2   => 'VAR_VAL',
             p_value2   => TO_CHAR(j));

            BEGIN

            -- Look up the Source System Code from the Display Code, for logging.

               SELECT source_system_code
               INTO v_src_sys_code
               FROM fem_source_systems_b
               WHERE source_system_display_code = pv_ssc_tbp(i).display_code;

            EXCEPTION
               WHEN NO_DATA_FOUND THEN

               -- No interface rows with this Source System Code should have been
               -- processed because it's an invalid code. Don't log any Data
               -- Locations entry for it.

                  FEM_ENGINES_PKG.Tech_Message
                  (p_severity    => pc_log_level_statement,
                   p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                                 'final_process_logging.ssc_invalid',
                   p_app_name => 'FEM',
                   p_msg_name => 'FEM_GL_POST_204',
                   p_token1   => 'VAR_NAME',
                   p_value1   => 'pv_ssc_tbp(i).display_code',
                   p_token2   => 'VAR_VAL',
                   p_value2   => pv_ssc_tbp(i).display_code || ' INVALID');

                  j := j + 1;

                  GOTO End_pv_ssc_tbp_Loop;
            END;

            IF pv_ssc_tbp(i).display_code < pv_ssc_np(j).display_code THEN

            -- This Source System Display Code was completly processed: Log
            -- it in Data Locations as 'COMPLETE'.

               FEM_DIMENSION_UTIL_PKG.Register_Data_Location
                 (P_REQUEST_ID  => pv_req_id,
                  P_OBJECT_ID   => pv_rule_obj_id,
                  P_TABLE_NAME  => 'FEM_BALANCES',
                  P_LEDGER_ID   => pv_ledger_id,
                  P_CAL_PER_ID  => pv_cal_period_id,
                  P_DATASET_CD  => pv_dataset_code,
                  P_SOURCE_CD   => v_src_sys_code,
                  P_LOAD_STATUS => 'COMPLETE');

               FEM_ENGINES_PKG.Tech_Message
               (p_severity    => pc_log_level_statement,
                p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                              'final_process_logging.ssc_complete',
                p_app_name => 'FEM',
                p_msg_name => 'FEM_GL_POST_204',
                p_token1   => 'VAR_NAME',
                p_value1   => 'pv_ssc_tbp(i).display_code',
                p_token2   => 'VAR_VAL',
                p_value2   => pv_ssc_tbp(i).display_code || ' COMPLETE');

            ELSE

            -- They must be equal; that means there is still at least one row
            -- for the current processing set with this Source System Code, so
            -- it must not have been fully processed.

               IF pv_ssc_tbp(i).row_count > pv_ssc_np(j).row_count THEN

               -- The number remaining is less than the original number to be
               -- processed: at least one row was processed for this Source
               -- System Code, so log it in Data Locations as 'INCOMPLETE'.

                  FEM_DIMENSION_UTIL_PKG.Register_Data_Location
                    (P_REQUEST_ID  => pv_req_id,
                     P_OBJECT_ID   => pv_rule_obj_id,
                     P_TABLE_NAME  => 'FEM_BALANCES',
                     P_LEDGER_ID   => pv_ledger_id,
                     P_CAL_PER_ID  => pv_cal_period_id,
                     P_DATASET_CD  => pv_dataset_code,
                     P_SOURCE_CD   => v_src_sys_code,
                     P_LOAD_STATUS => 'INCOMPLETE');

                  FEM_ENGINES_PKG.Tech_Message
                  (p_severity    => pc_log_level_statement,
                   p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                                 'final_process_logging.ssc_complete',
                   p_app_name => 'FEM',
                   p_msg_name => 'FEM_GL_POST_204',
                   p_token1   => 'VAR_NAME',
                   p_value1   => 'pv_ssc_tbp(i).display_code',
                   p_token2   => 'VAR_VAL',
                   p_value2   => pv_ssc_tbp(i).display_code || ' INCOMPLETE');

               END IF;

               j := j + 1;

            END IF;

          <<End_pv_ssc_tbp_Loop>>
            NULL;

         END LOOP;

      END IF;

   -- Log final messages

      FEM_ENGINES_PKG.Tech_Message
        (P_SEVERITY => pc_log_level_statement,
         P_MODULE   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                      'final_process_logging.completion_status',
         P_APP_NAME => 'FEM',
         P_MSG_NAME => 'FEM_GL_POST_204',
         P_TOKEN1   => 'VAR_NAME',
         P_VALUE1   => 'Completion Status',
         P_TOKEN2   => 'VAR_VAL',
         P_VALUE2   => p_exec_status);

   -- Successful completion

   -- LOADNUM rows loaded successfully.
   -- REJECTNUM rows failed to load successfully.
      FEM_ENGINES_PKG.User_Message
        (P_APP_NAME => 'FEM',
         P_MSG_NAME => 'FEM_SD_LDR_PROCESS_SUMMARY',
         P_TOKEN1   => 'LOADNUM',
         P_VALUE1   => TO_CHAR(NVL(p_num_output_rows, 0)),
         P_TOKEN2   => 'REJECTNUM',
         P_VALUE2   => TO_CHAR(NVL(p_num_data_errors, 0)));

      FEM_ENGINES_PKG.User_Message
        (P_APP_NAME => 'FEM',
         P_MSG_NAME => p_final_message_name);

      FEM_ENGINES_PKG.Tech_Message
        (P_SEVERITY => pc_log_level_event,
         P_MODULE   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'final_process_logging.final',
         P_APP_NAME => 'FEM',
         P_MSG_NAME => p_final_message_name);

      FEM_ENGINES_PKG.Tech_Message
        (P_SEVERITY => pc_log_level_procedure,
         P_MODULE   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'final_process_logging.end',
         P_MSG_TEXT => 'END');

   EXCEPTION

      WHEN OTHERS THEN
      ------------------------------------------------------------------
      -- Unexpected exceptions
      ------------------------------------------------------------------
         pv_sqlerrm   := SQLERRM;
         pv_callstack := dbms_utility.format_call_stack;

      -- Log the call stack and the Oracle error message to
      -- FND_LOG with the "unexpected exception" severity level.

         FEM_ENGINES_PKG.Tech_Message
           (P_SEVERITY => pc_log_level_unexpected,
            P_MODULE   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'final_process_logging.exception',
            P_MSG_TEXT => pv_sqlerrm);

         FEM_ENGINES_PKG.Tech_Message
           (P_SEVERITY => pc_log_level_unexpected,
            P_MODULE   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'final_process_logging.exception',
            P_MSG_TEXT => pv_callstack);

      -- Log the Oracle error message to the Concurrent Request Log.

         FEM_ENGINES_PKG.User_Message
           (p_app_name => 'FEM',
            p_msg_text => pv_sqlerrm);

      -- LOADNUM rows loaded successfully.
      -- REJECTNUM rows failed to load successfully.
         FEM_ENGINES_PKG.User_Message
           (P_APP_NAME => 'FEM',
            P_MSG_NAME => 'FEM_SD_LDR_PROCESS_SUMMARY',
            P_TOKEN1   => 'LOADNUM',
            P_VALUE1   => TO_CHAR(NVL(p_num_output_rows, 0)),
            P_TOKEN2   => 'REJECTNUM',
            P_VALUE2   => TO_CHAR(NVL(p_num_data_errors, 0)));

   END Final_Process_Logging;
-- =======================================================================


-- ======================================================================
   PROCEDURE Get_Proc_Key_Info
                (p_process_slice   IN  VARCHAR2,
                 x_completion_code OUT NOCOPY NUMBER) IS
-- ======================================================================
-- Purpose
--    Fetches the list of FEM_BALANCES processing key columns and other
--    related info from the FEM metadata.
-- History
--    10-31-03  S Kung  Created
--    01-27-04  G Hall  Removed superfluous call to get the
--                      Global VS Combo ID; Added check on
--                      VALUE_SET_REQUIRED_FLAG for getting
--                      Value Set ID for each dim; changed error
--                      handling to match other subroutines of
--                      Validate_Engine_Parameters.
--    02-06-04  G Hall  Added lookup to populate
--                      dim_int_disp_code_col.
--    03-10-04  G Hall  Removed SOURCE_SYSTEM_CODE from dim_col_name
--                      exclusion.
--    05-03-04  G Hall  Bug# 3603234 Change pv_proc_keys(v).dim_member_col
--                      to pv_proc_keys(v).dim_col_name.  Hard-coded a
--                      temporary workaround for INTERCOMPANY_DISPLAY_CODE.
--    05-07-04  G Hall  Bug# 3597527: Added IN parameter p_process_slice
--                      and used it in each call to Tech_Message.
--    05-12-04  G Hall  Bug# 3603260: Unhardcoded for INTERCOMPANY_
--                      DISPLAY_CODE; added FEM_DISPLAY_CODE_COL_MAP into
--                      BULK COLLECT join to fetch display code column names.
--    05-24-04  G Hall  Changed join to fem_xdim_dimensions to outer join,
--                      since some processing key columns are not dimenions
--                      (e.g. CURRENCY_TYPE_CODE).
--    05-25-04  G Hall  Added x_completion_code parameter; modified error-
--                      handling logic for being called by Process_Data_Slice.
--    06-02-04  G Hall  Bug# 3603260: Changed FEM_DISPLAY_CODE_COL_MAP to
--                      FEM_INT_COLUMN_MAP per design changes for this table.
--    01-28-05  G Hall  Bug# 4148677: Changed main query to get the
--                      DIMENSION_ID from FEM_TAB_COLUMNS_B instead of from
--                      FEM_COLUMN_REQUIREMNT_B.
--  Arguments
--     p_process_slice  A character string concatenation of the MP FW
--                      subrequest process number and the data slice id
--                      for distinguishing messages logged by different
--                      executions of FEM_XGL_ENGINE_PKG.Process_Data_Slice.
--     x_completion_code returns 0 for success, 2 for failure.
-- Notes
--    Called by Process_Data_Slice once for each subrequest.
-- ======================================================================

      v   NUMBER;

   BEGIN

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'get_proc_key_info.' || p_process_slice,
         p_msg_text => 'BEGIN');

   -- Bulk select dimension information into array of records

      SELECT
         xd.dimension_id,
         NULL,
         xd.value_set_required_flag,
         tcp.column_name,
         xd.member_b_table_name,
         xd.member_col,
         xd.member_display_code_col,
         cm.interface_column_name,
         xd.attribute_table_name
      BULK COLLECT INTO pv_proc_keys
      FROM fem_tab_column_prop tcp,
           fem_tab_columns_b tc,
           fem_xdim_dimensions xd,
           fem_int_column_map cm
      WHERE tcp.table_name = 'FEM_BALANCES'
        AND tcp.column_property_code = 'PROCESSING_KEY'
        AND tc.table_name = 'FEM_BALANCES'
        AND tc.column_name = tcp.column_name
        AND xd.dimension_id = tc.dimension_id
        AND cm.target_column_name (+) = tcp.column_name
        AND cm.object_type_code   (+) = 'XGL_INTEGRATION'
      ORDER BY tcp.column_name;

      pv_proc_key_dim_num := pv_proc_keys.count;

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'get_proc_key_info.' || p_process_slice,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'pv_proc_key_dim_num',
         p_token2   => 'VAR_VAL',
         p_value2   => TO_CHAR(pv_proc_key_dim_num));

      IF pv_proc_key_dim_num = 0 THEN

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_error,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'get_proc_key_info.' || p_process_slice,
            p_app_name => 'FEM',
            p_msg_text => 'The FEM_BALANCES Processing Key ' ||
                          'has not been set up yet.');

      END IF;

      FOR v IN 1..pv_proc_key_dim_num LOOP

         FEM_ENGINES_PKG.Tech_Message
            (p_severity => pc_log_level_statement,
             p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                           'get_proc_key_info.' || p_process_slice,
             p_app_name => 'FEM',
             p_msg_name => 'FEM_GL_POST_204',
             p_token1   => 'VAR_NAME',
             p_value1   => 'dim_col_name',
             p_token2   => 'VAR_VAL',
             p_value2   => pv_proc_keys(v).dim_col_name);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_statement,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'get_proc_key_info.' || p_process_slice,
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_204',
            p_token1   => 'VAR_NAME',
            p_value1   => 'dimension_id',
            p_token2   => 'VAR_VAL',
            p_value2   => TO_CHAR(pv_proc_keys(v).dimension_id));

         IF pv_proc_keys(v).dim_vsr_flag = 'Y' THEN

         -- Set Value Set ID for each dimension based on the ledger

            pv_proc_keys(v).dim_vs_id :=
               FEM_DIMENSION_UTIL_PKG.Dimension_Value_Set_ID
                 (p_Dimension_ID  => pv_proc_keys(v).dimension_id,
                  p_Ledger_ID     => pv_ledger_id);

            IF pv_proc_keys(v).dim_vs_id = -1 THEN

               FEM_ENGINES_PKG.Tech_Message
                 (p_severity => pc_log_level_statement,
                  p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                                'get_proc_key_info.' || p_process_slice,
                  p_msg_text => 'raising Value_Set_ID_Error');

               pv_dim_name := FEM_DIMENSION_UTIL_PKG.Get_Dimension_Name
                                 (p_dim_id => pv_proc_keys(v).dimension_id);

               RAISE Value_Set_ID_Error;

            END IF;

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'get_proc_key_info.' || p_process_slice,
               p_app_name => 'FEM',
               p_msg_name => 'FEM_GL_POST_204',
               p_token1   => 'VAR_NAME',
               p_value1   => 'dim_vs_id',
               p_token2   => 'VAR_VAL',
               p_value2   => TO_CHAR(pv_proc_keys(v).dim_vs_id));

         END IF;

         FEM_ENGINES_PKG.Tech_Message
            (p_severity => pc_log_level_statement,
             p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                           'get_proc_key_info.' || p_process_slice,
             p_app_name => 'FEM',
             p_msg_name => 'FEM_GL_POST_204',
             p_token1   => 'VAR_NAME',
             p_value1   => 'dim_member_b_table_name',
             p_token2   => 'VAR_VAL',
             p_value2   => pv_proc_keys(v).dim_member_b_table_name);

         FEM_ENGINES_PKG.Tech_Message
            (p_severity => pc_log_level_statement,
             p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                           'get_proc_key_info.' || p_process_slice,
             p_app_name => 'FEM',
             p_msg_name => 'FEM_GL_POST_204',
             p_token1   => 'VAR_NAME',
             p_value1   => 'dim_member_col',
             p_token2   => 'VAR_VAL',
             p_value2   => pv_proc_keys(v).dim_member_col);

         IF pv_proc_keys(v).dim_col_name NOT IN
               ('CAL_PERIOD_ID', 'DATASET_CODE', 'CREATED_BY_OBJECT_ID') THEN

            FEM_ENGINES_PKG.Tech_Message
               (p_severity => pc_log_level_statement,
                p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                              'get_proc_key_info.' || p_process_slice,
                p_app_name => 'FEM',
                p_msg_name => 'FEM_GL_POST_204',
                p_token1   => 'VAR_NAME',
                p_value1   => 'dim_member_disp_code_col',
                p_token2   => 'VAR_VAL',
                p_value2   => pv_proc_keys(v).dim_member_disp_code_col);

            FEM_ENGINES_PKG.Tech_Message
               (p_severity => pc_log_level_statement,
                p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                              'get_proc_key_info.' || p_process_slice,
                p_app_name => 'FEM',
                p_msg_name => 'FEM_GL_POST_204',
                p_token1   => 'VAR_NAME',
                p_value1   => 'dim_int_disp_code_col',
                p_token2   => 'VAR_VAL',
                p_value2   => pv_proc_keys(v).dim_int_disp_code_col);

         END IF;

         FEM_ENGINES_PKG.Tech_Message
            (p_severity => pc_log_level_statement,
             p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                           'get_proc_key_info.' || p_process_slice,
             p_app_name => 'FEM',
             p_msg_name => 'FEM_GL_POST_204',
             p_token1   => 'VAR_NAME',
             p_value1   => 'dim_attr_table_name',
             p_token2   => 'VAR_VAL',
             p_value2   => pv_proc_keys(v).dim_attr_table_name);

      END LOOP;

      x_completion_code := 0;

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'get_proc_key_info.' || p_process_slice,
         p_msg_text => 'END');

   EXCEPTION

      WHEN Value_Set_ID_Error THEN
      ------------------------------------------------------------------
      -- Unable to retrieve the Value Set ID for a processing key
      -- dimension.  Dimension Name:
      ------------------------------------------------------------------

         x_completion_code := 2;

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_error,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'get_proc_key_info.' || p_process_slice,
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_022',
            p_token1   => 'DIMENSION_NAME',
            p_value1   => pv_dim_name);

         FEM_ENGINES_PKG.User_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_022',
            p_token1   => 'DIMENSION_NAME',
            p_value1   => pv_dim_name);

         FND_MSG_PUB.Initialize;

         FEM_ENGINES_PKG.Put_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_022',
            p_token1   => 'DIMENSION_NAME',
            p_value1   => pv_dim_name);

         pv_sqlerrm := FND_MSG_PUB.Get(1, p_encoded => 'F');

      WHEN OTHERS THEN
      ------------------------------------------------------------------
      -- Unexpected exceptions
      ------------------------------------------------------------------
         pv_sqlerrm   := SQLERRM;
         pv_callstack := dbms_utility.format_call_stack;

      -- Log the call stack and the Oracle error message to
      -- FND_LOG with the "unexpected exception" severity level.

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'get_proc_key_info.' || p_process_slice,
            p_msg_text => pv_sqlerrm);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'get_proc_key_info.' || p_process_slice,
            p_msg_text => pv_callstack);

      -- Log the Oracle error message to the Concurrent Request Log.

         FEM_ENGINES_PKG.User_Message
           (p_app_name => 'FEM',
            p_msg_text => pv_sqlerrm);

   END Get_Proc_Key_Info;
-- =======================================================================

-- ======================================================================
   PROCEDURE Get_SSC (p_dest_code IN  VARCHAR2) IS
-- ======================================================================
-- Purpose
--    Fetches the distinct list and rowcount of Source System Display
--    Codes (SSDC's) from the interface table, for Data Locations logging.
--    When called prior to processing, it gets SSDC's to be processed;
--    when called after processing, it gets SSDC's not processed (due to
--    parameter error, data error, or unexpected database error).  This
--    way we can tell which SSC's to make Data Locations entries for, and
--    whether to post them as complete or incomplete.
-- History
--    05-13-04  G Hall  Bug# 3597495: Created.
--    05-25-04  G Hall  Renamed from Get_SSC_To_Be_Processed to Get_SSC;
--                      Changed p_sql_where argument reference to use a
--                      package variable instead; removed p_sql_where
--                      argument and added p_dest_code argument, so it
--                      can be used to populate both SSDC's to be
--                      processed and SSDC's not processed.
--    04-25-06  G Hall  Bug 5190527. Changed VARRAY to TABLE for
--                      src_sys_dsp_cd_list type, to remove limit on number
--                      of distinct source systems that can be loaded; this
--                      required a change to the syntax for adding the
--                      'ZZZZZZZZZZZZZZZ' display code as the last element
--                      of the collection.
--    06-01-06  G Hall  Bug 5190527 (as forward port for 11i bug 5257358).
--                      Added check for pv_ssc_np.count = 0.
--  Argument
--     p_dest_code      'TBP' to populate the pv_ssc_tbp structure;
--                      'NP'  to populate the pv_ssc_np  structure.
-- Notes
--    Called by Main just prior to calling MP Master, and by
--    Final_Process_Logging after processing is complete on upon early
--    termination due to error.
-- ======================================================================

      v_sql_stmt  VARCHAR2(1200);

      TYPE SrcSysDspCdTBP_cursor IS REF CURSOR;
      SrcSysDspCdTBP             SrcSysDspCdTBP_cursor;

   BEGIN

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'get_ssc.begin',
         p_msg_text => 'BEGIN');

      v_sql_stmt := 'SELECT source_system_display_code, COUNT(*)' ||
                    ' FROM fem_bal_interface_t' ||
                    ' WHERE ' || pv_ssc_where ||
                    ' GROUP BY source_system_display_code' ||
                    ' ORDER BY source_system_display_code';

      FEM_ENGINES_PKG.Tech_Message
         (p_severity => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'get_ssc',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'v_sql_stmt',
          p_token2   => 'VAR_VAL',
          p_value2   => v_sql_stmt);

      OPEN SrcSysDspCdTBP FOR v_sql_stmt;

      IF p_dest_code = 'TBP' THEN

         FETCH SrcSysDspCdTBP BULK COLLECT INTO pv_ssc_tbp;

         FEM_ENGINES_PKG.Tech_Message
            (p_severity => pc_log_level_statement,
             p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                           'get_ssc',
             p_app_name => 'FEM',
             p_msg_name => 'FEM_GL_POST_204',
             p_token1   => 'VAR_NAME',
             p_value1   => 'pv_ssc_tbp.count',
             p_token2   => 'VAR_VAL',
             p_value2   => TO_CHAR(pv_ssc_tbp.count));

      ELSE

         FETCH SrcSysDspCdTBP BULK COLLECT INTO pv_ssc_np;

         FEM_ENGINES_PKG.Tech_Message
            (p_severity => pc_log_level_statement,
             p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                           'get_ssc',
             p_app_name => 'FEM',
             p_msg_name => 'FEM_GL_POST_204',
             p_token1   => 'VAR_NAME',
             p_value1   => 'pv_ssc_np.count',
             p_token2   => 'VAR_VAL',
             p_value2   => TO_CHAR(pv_ssc_np.count));

      -- Add a dummy row at the end whose Display Code value is greater
      -- than all (like "high-values"). This is needed for the matching
      -- logic in Final_Process_Logging.

         IF pv_ssc_np.count = 0 THEN
            pv_ssc_np(1).display_code := 'ZZZZZZZZZZZZZZZ';
         ELSE
            pv_ssc_np(pv_ssc_np.last+1).display_code := 'ZZZZZZZZZZZZZZZ';
         END IF;

      END IF;

      CLOSE SrcSysDspCdTBP;

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'get_ssc.end',
         p_msg_text => 'END');

   END Get_SSC;
-- =======================================================================


-- ======================================================================
   PROCEDURE Undo_XGL_Interface_Error_Rows
                (p_request_id              IN  NUMBER,
                 x_return_status           OUT NOCOPY VARCHAR2,
                 x_msg_data                OUT NOCOPY VARCHAR2,
                 x_msg_count               OUT NOCOPY NUMBER) IS
-- ======================================================================
-- Purpose
--    Called by the Undo engine to delete remaining error rows from the
--    XGL interface table that are associated with the executions being
--    Undone.
-- History
--    05-18-04  G Hall  Bug# 3634602: Created (stubbed for now).
--    06-07-04  G Hall  Bug# 3634602: Developed procedure body.
--  Arguments
--    p_request_id      The Request ID of the execution chosen for undo.
--                      Used to look up the runtime parameters for that
--                      execution, for identifying interface table rows
--                      to be deleted.
--    x_return_status   Returns 'S' for success, 'E' for detected logic
--                      error, 'U' for unexpected error (e.g. database or
--                      PL/SQL error).
--    x_msg_data        Returns end-user message when there is exactly
--                      one.
--    x_msg_count       Returns the number of end-user messages generated.
-- ======================================================================

      v_cal_per_dim_group_id   fem_cal_periods_b.dimension_group_id%TYPE;
      v_rows_deleted           NUMBER;

      v_param_name             fem_dimensions_tl.dimension_name%TYPE;
      v_param_value            VARCHAR2(40);
      v_attr_name              fem_dim_attributes_tl.attribute_name%TYPE;

   BEGIN

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'undo_xgl_int_error_rows.begin',
         p_msg_text => 'BEGIN');

   -- -------------------------------------------------------------------
   -- Using p_request_id, from FEM_PL_REQUESTS look up CAL_PERIOD_ID,
   -- LEDGER_ID, and OUTPUT_DATASET_CODE.
   -- -------------------------------------------------------------------

      BEGIN

         SELECT ledger_id, cal_period_id, output_dataset_code
         INTO pv_ledger_id, pv_cal_period_id, pv_dataset_code
         FROM fem_pl_requests
         WHERE request_id = p_request_id;

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'undo_xgl_int_error_rows.pv_ledger_id',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'pv_ledger_id',
          p_token2   => 'VAR_VAL',
          p_value2   => TO_CHAR(pv_ledger_id));

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'undo_xgl_int_error_rows.pv_cal_period_id',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'pv_cal_period_id',
          p_token2   => 'VAR_VAL',
          p_value2   => TO_CHAR(pv_cal_period_id));

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'undo_xgl_int_error_rows.pv_dataset_code',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'pv_dataset_code',
          p_token2   => 'VAR_VAL',
          p_value2   => TO_CHAR(pv_dataset_code));

      EXCEPTION
         WHEN NO_DATA_FOUND THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'undo_xgl_int_error_rows.irid.',
               p_msg_text => 'raising Invalid_Request_ID');

            RAISE Invalid_Request_ID;
      END;

   -- -------------------------------------------------------------------
   -- Use CAL_PERIOD_ID to look up CAL_PER_DIM_GRP_DISPLAY_CODE,
   -- CAL_PERIOD_END_DATE, and CAL_PERIOD_NUMBER.
   -- -------------------------------------------------------------------

   -- Get the Dimension ID for Cal Period.

      SELECT dimension_id
      INTO pv_cal_per_dim_id
      FROM fem_dimensions_b
      WHERE dimension_varchar_label = 'CAL_PERIOD';

   -- Set variables used in messaging upon failure.

      v_param_name := FEM_DIMENSION_UTIL_PKG.Get_Dimension_Name
                        (p_dim_id => pv_cal_per_dim_id);
      IF v_param_name IS NULL THEN
         v_param_name := 'Calendar Period';
      END IF;
      v_param_value := TO_CHAR(pv_cal_period_id);
      v_attr_name := NULL;

      BEGIN

      -- Get DIMENSION_GROUP_DISPLAY_CODE for the Calendar Period.

         SELECT dimension_group_id
         INTO v_cal_per_dim_group_id
         FROM fem_cal_periods_b
         WHERE cal_period_id = pv_cal_period_id
           AND personal_flag = 'N';

         v_attr_name := FEM_DIMENSION_UTIL_PKG.Get_Dim_Attr_Name
                           (p_dim_id     => pv_cal_per_dim_id,
                            p_attr_label => 'DIMENSION_GROUP_ID');

         IF v_attr_name IS NULL THEN
            v_attr_name := 'DIMENSION_GROUP_ID';
         END IF;

         SELECT dimension_group_display_code
         INTO pv_cal_per_dim_grp_dsp_cd
         FROM fem_dimension_grps_b
         WHERE dimension_group_id = v_cal_per_dim_group_id;

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'undo_xgl_int_error_rows.pv_cal_per_dim_grp_dsp_cd',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'pv_cal_per_dim_grp_dsp_cd',
          p_token2   => 'VAR_VAL',
          p_value2   => pv_cal_per_dim_grp_dsp_cd);

      EXCEPTION
         WHEN NO_DATA_FOUND THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'undo_xgl_int_error_rows.icpid1.',
               p_msg_text => 'raising Invalid_Runtime_Parameter');

            RAISE Invalid_Runtime_Parameter;
      END;

      BEGIN

      -- Get the CAL_PERIOD_END_DATE attribute of the Cal Period ID.

         v_attr_name := FEM_DIMENSION_UTIL_PKG.Get_Dim_Attr_Name
                           (p_dim_id     => pv_cal_per_dim_id,
                            p_attr_label => 'CAL_PERIOD_END_DATE');

         IF v_attr_name IS NULL THEN
            v_attr_name := 'CAL_PERIOD_END_DATE';
         END IF;

         fem_dimension_util_pkg.get_dim_attr_id_ver_id
           (x_err_code    => pv_API_return_code,
            x_attr_id     => pv_dim_attr_id,
            x_ver_id      => pv_dim_attr_ver_id,
            p_dim_id      => pv_cal_per_dim_id,
            p_attr_label  => 'CAL_PERIOD_END_DATE');

         IF pv_API_return_code > 0 THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'undo_xgl_int_error_rows.icpid2.',
               p_msg_text => 'raising Invalid_Runtime_Parameter');

            RAISE Invalid_Runtime_Parameter;

         END IF;

         SELECT date_assign_value
         INTO pv_cal_per_end_date
         FROM fem_cal_periods_attr
         WHERE attribute_id  = pv_dim_attr_id
           AND version_id    = pv_dim_attr_ver_id
           AND cal_period_id = pv_cal_period_id;

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'undo_xgl_int_error_rows.pv_cal_per_end_date',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'pv_cal_per_end_date',
          p_token2   => 'VAR_VAL',
          p_value2   => TO_CHAR(pv_cal_per_end_date, 'DD-MON-YYYY'));

      EXCEPTION
         WHEN NO_DATA_FOUND THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'undo_xgl_int_error_rows.icpid3.',
               p_msg_text => 'raising Invalid_Runtime_Parameter');

            RAISE Invalid_Runtime_Parameter;
      END;

      BEGIN

      -- Get the Calendar Period Number from the GL_PERIOD_NUM attribute of the
      -- Cal Period ID.

         v_attr_name := FEM_DIMENSION_UTIL_PKG.Get_Dim_Attr_Name
                           (p_dim_id     => pv_cal_per_dim_id,
                            p_attr_label => 'GL_PERIOD_NUM');

         IF v_attr_name IS NULL THEN
            v_attr_name := 'GL_PERIOD_NUM';
         END IF;

         fem_dimension_util_pkg.get_dim_attr_id_ver_id
           (x_err_code    => pv_API_return_code,
            x_attr_id     => pv_dim_attr_id,
            x_ver_id      => pv_dim_attr_ver_id,
            p_dim_id      => pv_cal_per_dim_id,
            p_attr_label  => 'GL_PERIOD_NUM');

         IF pv_API_return_code > 0 THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'undo_xgl_int_error_rows.icpid4.',
               p_msg_text => 'raising Invalid_Runtime_Parameter');

            RAISE Invalid_Runtime_Parameter;

         END IF;

         SELECT number_assign_value
         INTO pv_gl_per_number
         FROM fem_cal_periods_attr
         WHERE attribute_id  = pv_dim_attr_id
           AND version_id    = pv_dim_attr_ver_id
           AND cal_period_id = pv_cal_period_id;

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'undo_xgl_int_error_rows.pv_gl_per_number',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'pv_gl_per_number',
          p_token2   => 'VAR_VAL',
          p_value2   => TO_CHAR(pv_gl_per_number));

      EXCEPTION
         WHEN NO_DATA_FOUND THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'undo_xgl_int_error_rows.icpid5.',
               p_msg_text => 'raising Invalid_Runtime_Parameter');

            RAISE Invalid_Runtime_Parameter;
      END;

   -- -------------------------------------------------------------------
   -- Use LEDGER_ID to look up LEDGER_DISPLAY_CODE.
   -- -------------------------------------------------------------------

   -- Get the Dimension ID for Ledger.

      SELECT dimension_id
      INTO pv_ledger_dim_id
      FROM fem_dimensions_b
      WHERE dimension_varchar_label = 'LEDGER';

   -- Set variables used in messaging upon failure.

      v_param_name := FEM_DIMENSION_UTIL_PKG.Get_Dimension_Name
                        (p_dim_id => pv_ledger_dim_id);
      IF v_param_name IS NULL THEN
         v_param_name := 'Ledger';
      END IF;
      v_param_value := TO_CHAR(pv_ledger_id);
      v_attr_name := NULL;

      BEGIN

         SELECT ledger_display_code
         INTO pv_ledger_dsp_cd
         FROM fem_ledgers_b
         WHERE ledger_id = pv_ledger_id
           AND enabled_flag  = 'Y'
           AND personal_flag = 'N';

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'undo_xgl_int_error_rows.pv_ledger_dsp_cd',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'pv_ledger_dsp_cd',
          p_token2   => 'VAR_VAL',
          p_value2   => pv_ledger_dsp_cd);

      EXCEPTION
         WHEN NO_DATA_FOUND THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'undo_xgl_int_error_rows.ilid.',
               p_msg_text => 'raising Invalid_Runtime_Parameter');

            RAISE Invalid_Runtime_Parameter;
      END;

   -- -------------------------------------------------------------------
   -- Use OUTPUT_DATASET_CODE to look up DS_BALANCE_TYPE_CODE, and if
   -- applicable, BUDGET_DISPLAY_CODE or ENCUMBRANCE_TYPE_CODE.
   -- -------------------------------------------------------------------

   -- Get the Dimension ID for Dataset Code.

      SELECT dimension_id
      INTO pv_dataset_dim_id
      FROM fem_dimensions_b
      WHERE dimension_varchar_label = 'DATASET';

   -- Set variables used in messaging upon failure.

      v_param_name := FEM_DIMENSION_UTIL_PKG.Get_Dimension_Name
                        (p_dim_id => pv_dataset_dim_id);
      IF v_param_name IS NULL THEN
         v_param_name := 'Dataset';
      END IF;
      v_param_value := TO_CHAR(pv_dataset_code);

      BEGIN

      -- Look up the Dataset attribute DATASET_BALANCE_TYPE_CODE

         v_attr_name := FEM_DIMENSION_UTIL_PKG.Get_Dim_Attr_Name
                           (p_dim_id     => pv_dataset_dim_id,
                            p_attr_label => 'DATASET_BALANCE_TYPE_CODE');

         IF v_attr_name IS NULL THEN
            v_attr_name := 'DATASET_BALANCE_TYPE_CODE';
         END IF;

         fem_dimension_util_pkg.get_dim_attr_id_ver_id
           (x_err_code    => pv_API_return_code,
            x_attr_id     => pv_dim_attr_id,
            x_ver_id      => pv_dim_attr_ver_id,
            p_dim_id      => pv_dataset_dim_id,
            p_attr_label  => 'DATASET_BALANCE_TYPE_CODE');

         IF pv_API_return_code > 0 THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'undo_xgl_int_error_rows.idsc1.',
               p_msg_text => 'raising Invalid_Runtime_Parameter');

            RAISE Invalid_Runtime_Parameter;

         END IF;

         SELECT dim_attribute_varchar_member
         INTO pv_ds_balance_type_cd
         FROM fem_datasets_attr
         WHERE attribute_id  = pv_dim_attr_id
           AND version_id    = pv_dim_attr_ver_id
           AND dataset_code  = pv_dataset_code;

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'undo_xgl_int_error_rows.pv_ds_balance_type_cd',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'pv_ds_balance_type_cd',
          p_token2   => 'VAR_VAL',
          p_value2   => pv_ds_balance_type_cd);

      EXCEPTION
         WHEN NO_DATA_FOUND THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'undo_xgl_int_error_rows.idsc2.',
               p_msg_text => 'raising Invalid_Runtime_Parameter');

            RAISE Invalid_Runtime_Parameter;
      END;

      IF pv_ds_balance_type_cd = 'BUDGET' THEN

         BEGIN

         -- Look up the Dataset Code BUDGET_ID attribute

            v_attr_name := FEM_DIMENSION_UTIL_PKG.Get_Dim_Attr_Name
                              (p_dim_id     => pv_dataset_dim_id,
                               p_attr_label => 'BUDGET_ID');

            IF v_attr_name IS NULL THEN
               v_attr_name := 'BUDGET_ID';
            END IF;

            fem_dimension_util_pkg.get_dim_attr_id_ver_id
              (x_err_code    => pv_API_return_code,
               x_attr_id     => pv_dim_attr_id,
               x_ver_id      => pv_dim_attr_ver_id,
               p_dim_id      => pv_dataset_dim_id,
               p_attr_label  => 'BUDGET_ID');

            IF pv_API_return_code > 0 THEN

               FEM_ENGINES_PKG.Tech_Message
                 (p_severity => pc_log_level_statement,
                  p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                                'undo_xgl_int_error_rows.idsc3.',
                  p_msg_text => 'raising Invalid_Runtime_Parameter');

               RAISE Invalid_Runtime_Parameter;

            END IF;

            SELECT dim_attribute_numeric_member
            INTO pv_budget_id
            FROM fem_datasets_attr
            WHERE attribute_id  = pv_dim_attr_id
              AND version_id    = pv_dim_attr_ver_id
              AND dataset_code  = pv_dataset_code;

            FEM_ENGINES_PKG.Tech_Message
            (p_severity    => pc_log_level_statement,
             p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                           'undo_xgl_int_error_rows.pv_budget_id',
             p_app_name => 'FEM',
             p_msg_name => 'FEM_GL_POST_204',
             p_token1   => 'VAR_NAME',
             p_value1   => 'pv_budget_id',
             p_token2   => 'VAR_VAL',
             p_value2   => pv_budget_id);

         EXCEPTION
            WHEN NO_DATA_FOUND THEN

               FEM_ENGINES_PKG.Tech_Message
                 (p_severity => pc_log_level_statement,
                  p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                                'undo_xgl_int_error_rows.idsc4.',
                  p_msg_text => 'raising Invalid_Runtime_Parameter');

               RAISE Invalid_Runtime_Parameter;
         END;

         BEGIN

         -- Look up the Budget Display Code

            SELECT dimension_id
            INTO pv_budget_dim_id
            FROM fem_dimensions_b
            WHERE dimension_varchar_label = 'BUDGET';

            v_param_name := FEM_DIMENSION_UTIL_PKG.Get_Dimension_Name
                              (p_dim_id => pv_budget_dim_id);
            IF v_param_name IS NULL THEN
               v_param_name := 'Budget';
            END IF;
            v_param_value := TO_CHAR(pv_budget_id);
            v_attr_name := NULL;

            SELECT budget_display_code
            INTO pv_budget_dsp_cd
            FROM fem_budgets_b
            WHERE budget_id = pv_budget_id;

            FEM_ENGINES_PKG.Tech_Message
            (p_severity    => pc_log_level_statement,
             p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                           'undo_xgl_int_error_rows.pv_budget_dsp_cd',
             p_app_name => 'FEM',
             p_msg_name => 'FEM_GL_POST_204',
             p_token1   => 'VAR_NAME',
             p_value1   => 'pv_budget_dsp_cd',
             p_token2   => 'VAR_VAL',
             p_value2   => pv_budget_dsp_cd);

         EXCEPTION
            WHEN NO_DATA_FOUND THEN

               FEM_ENGINES_PKG.Tech_Message
                 (p_severity => pc_log_level_statement,
                  p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                                'undo_xgl_int_error_rows.idsc5.',
                  p_msg_text => 'raising Invalid_Runtime_Parameter');

               RAISE Invalid_Runtime_Parameter;
         END;

      ELSIF pv_ds_balance_type_cd = 'ENCUMBRANCE' THEN

         BEGIN

         -- Look up the Dataset Code ENCUMBRANCE_TYPE_ID attribute

            v_attr_name := FEM_DIMENSION_UTIL_PKG.Get_Dim_Attr_Name
                              (p_dim_id     => pv_dataset_dim_id,
                               p_attr_label => 'ENCUMBRANCE_TYPE_ID');

            IF v_attr_name IS NULL THEN
               v_attr_name := 'ENCUMBRANCE_TYPE_ID';
            END IF;

            fem_dimension_util_pkg.get_dim_attr_id_ver_id
              (x_err_code    => pv_API_return_code,
               x_attr_id     => pv_dim_attr_id,
               x_ver_id      => pv_dim_attr_ver_id,
               p_dim_id      => pv_dataset_dim_id,
               p_attr_label  => 'ENCUMBRANCE_TYPE_ID');

            IF pv_API_return_code > 0 THEN

               FEM_ENGINES_PKG.Tech_Message
                 (p_severity => pc_log_level_statement,
                  p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                                'undo_xgl_int_error_rows.idsc6.',
                  p_msg_text => 'raising Invalid_Runtime_Parameter');

               RAISE Invalid_Runtime_Parameter;

            END IF;

            SELECT dim_attribute_numeric_member
            INTO pv_enc_type_id
            FROM fem_datasets_attr
            WHERE attribute_id  = pv_dim_attr_id
              AND version_id    = pv_dim_attr_ver_id
              AND dataset_code  = pv_dataset_code;

            FEM_ENGINES_PKG.Tech_Message
            (p_severity    => pc_log_level_statement,
             p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                           'undo_xgl_int_error_rows.pv_enc_type_id',
             p_app_name => 'FEM',
             p_msg_name => 'FEM_GL_POST_204',
             p_token1   => 'VAR_NAME',
             p_value1   => 'pv_enc_type_id',
             p_token2   => 'VAR_VAL',
             p_value2   => pv_enc_type_id);

         EXCEPTION
            WHEN NO_DATA_FOUND THEN

               FEM_ENGINES_PKG.Tech_Message
                 (p_severity => pc_log_level_statement,
                  p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                                'undo_xgl_int_error_rows.idsc7.',
                  p_msg_text => 'raising Invalid_Runtime_Parameter');

               RAISE Invalid_Runtime_Parameter;
         END;

         BEGIN

         -- Look up the Encumbrance Type (Display) Code

            SELECT dimension_id
            INTO pv_enc_type_dim_id
            FROM fem_dimensions_b
            WHERE dimension_varchar_label = 'ENCUMBRANCE_TYPE';

            v_param_name := FEM_DIMENSION_UTIL_PKG.Get_Dimension_Name
                              (p_dim_id => pv_enc_type_dim_id);
            IF v_param_name IS NULL THEN
               v_param_name := 'Encumbrance Type';
            END IF;
            v_param_value := TO_CHAR(pv_enc_type_id);
            v_attr_name := NULL;

            SELECT encumbrance_type_code
            INTO pv_enc_type_dsp_cd
            FROM fem_encumbrance_types_b
            WHERE encumbrance_type_id = pv_enc_type_id;

            FEM_ENGINES_PKG.Tech_Message
            (p_severity    => pc_log_level_statement,
             p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                           'undo_xgl_int_error_rows.pv_enc_type_dsp_cd',
             p_app_name => 'FEM',
             p_msg_name => 'FEM_GL_POST_204',
             p_token1   => 'VAR_NAME',
             p_value1   => 'pv_enc_type_dsp_cd',
             p_token2   => 'VAR_VAL',
             p_value2   => pv_enc_type_dsp_cd);

         EXCEPTION
            WHEN NO_DATA_FOUND THEN

               FEM_ENGINES_PKG.Tech_Message
                 (p_severity => pc_log_level_statement,
                  p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                                'undo_xgl_int_error_rows.idsc8.',
                  p_msg_text => 'raising Invalid_Runtime_Parameter');

               RAISE Invalid_Runtime_Parameter;
         END;

      END IF;

   -- -------------------------------------------------------------------
   -- Delete all rows for the given ledger, period, and dataset that
   -- have a value for POSTING_ERROR_CODE, or that have been tagged for
   -- processing by any XGL execution.  This puts the interface table
   -- to a clean state for the given ledger, period, and dataset so the
   -- data can be reloaded and reprocessed without the risk of
   -- reprocessing left-over rows resulting in double-counting.
   -- -------------------------------------------------------------------

      DELETE FROM fem_bal_interface_t
      WHERE cal_per_dim_grp_display_code = pv_cal_per_dim_grp_dsp_cd
        AND cal_period_end_date = pv_cal_per_end_date
        AND cal_period_number = pv_gl_per_number
        AND ledger_display_code = pv_ledger_dsp_cd
        AND ds_balance_type_code = pv_ds_balance_type_cd
        AND (budget_display_code = pv_budget_dsp_cd
             OR pv_budget_dsp_cd is NULL)
        AND (encumbrance_type_code = pv_enc_type_dsp_cd
             OR pv_enc_type_dsp_cd is NULL)
        AND posting_error_code IS NOT NULL;

      v_rows_deleted := SQL%ROWCOUNT;

      COMMIT;

      FEM_ENGINES_PKG.Tech_Message
      (p_severity    => pc_log_level_statement,
       p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                     'undo_xgl_int_error_rows.v_rows_deleted',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_218',
       p_token1   => 'NUM',
       p_value1   => TO_CHAR(v_rows_deleted),
       p_token2   => 'TABLE',
       p_value2   => 'FEM_BAL_INTERFACE_T');

      x_return_status := 'S';
      x_msg_data      := NULL;
      x_msg_count     := 0;

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'undo_xgl_int_error_rows.end',
         p_msg_text => 'END');

   EXCEPTION
      WHEN Invalid_Request_ID THEN

      -- WARNING:  Error rows not undone from FEM_BAL_INTERFACE_T

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_error,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'undo_xgl_int_error_rows.xirid1',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_024');

         FEM_ENGINES_PKG.Put_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_024');

      -- Invalid parameter. Value not found. Parameter Name: Request ID.

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_error,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'undo_xgl_int_error_rows.xirid2',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_001',
            p_token1   => 'DIMENSION_NAME',
            p_value1   => 'FEM_REQUEST_ID_TXT',
            p_trans1   => 'Y');

         FEM_ENGINES_PKG.Put_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_001',
            p_token1   => 'DIMENSION_NAME',
            p_value1   => 'FEM_REQUEST_ID_TXT',
            p_trans1   => 'Y');

         x_return_status := 'E';
         x_msg_data      := NULL;
         x_msg_count     := 2;

      WHEN Invalid_Runtime_Parameter THEN
      ------------------------------------------------------------------
      -- WARNING:  Error rows not undone from FEM_BAL_INTERFACE_T
      --
      -- Unable to resolve one of the original runtime parameter values
      -- into its corresponding interface column value or values due to
      -- a missing dimension value or dimension attribute value.
      -- Parameter Name: v_param_name.  Parameter Value:
      -- v_param_value.  Attribute Name: v_attr_name.
      ------------------------------------------------------------------

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_error,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'undo_xgl_int_error_rows.xirp1',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_024');

         FEM_ENGINES_PKG.Put_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_024');

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_error,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'undo_xgl_int_error_rows.xirp2',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_025',
            p_token1   => 'PARAMETER_NAME',
            p_value1   => v_param_name,
            p_token2   => 'PARAMETER_VALUE',
            p_value2   => v_param_value,
            p_token3   => 'ATTRIBUTE_NAME',
            p_value3   => v_attr_name);

         FEM_ENGINES_PKG.Put_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_025',
            p_token1   => 'PARAMETER_NAME',
            p_value1   => v_param_name,
            p_token2   => 'PARAMETER_VALUE',
            p_value2   => v_param_value,
            p_token3   => 'ATTRIBUTE_NAME',
            p_value3   => v_attr_name);

         x_return_status := 'E';
         x_msg_data      := NULL;
         x_msg_count     := 2;

   END Undo_XGL_Interface_Error_Rows;
-- ======================================================================


/**************************************************************************
-- Private Procedures
**************************************************************************/

-- =======================================================================
   PROCEDURE Get_Dim_IDs IS
-- =======================================================================
-- Purpose
--    Gets the Dimension ID for each of the dimension-based engine
--    parameters and sets them in public package variables.
-- History
--    11-13-03  G Hall      Created
--    12-15-04  L Poon      Added to log messages
-- Notes
--    Called by Validate_XGL_Eng_Parameters
--    (and by Validate_OGL_Eng_Parameters)
-- =======================================================================

   BEGIN

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'get_dim_ids.begin',
         p_msg_text => 'BEGIN');

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'get_dim_ids',
         p_msg_text => 'Get Calendar Period dimension ID');

      SELECT dimension_id
      INTO pv_cal_per_dim_id
      FROM fem_dimensions_b
      WHERE dimension_varchar_label = 'CAL_PERIOD';

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'get_dim_ids',
         p_msg_text => 'Get Ledger dimension ID');

      SELECT dimension_id
      INTO pv_ledger_dim_id
      FROM fem_dimensions_b
      WHERE dimension_varchar_label = 'LEDGER';

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'get_dim_ids',
         p_msg_text => 'Get Dataset dimension ID');

      SELECT dimension_id
      INTO pv_dataset_dim_id
      FROM fem_dimensions_b
      WHERE dimension_varchar_label = 'DATASET';

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'get_dim_ids',
         p_msg_text => 'Get Budget dimension ID');

      SELECT dimension_id
      INTO pv_budget_dim_id
      FROM fem_dimensions_b
      WHERE dimension_varchar_label = 'BUDGET';

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'get_dim_ids',
         p_msg_text => 'Get Encumbrance Type dimension ID');

      SELECT dimension_id
      INTO pv_enc_type_dim_id
      FROM fem_dimensions_b
      WHERE dimension_varchar_label = 'ENCUMBRANCE_TYPE';

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'get_dim_ids',
         p_msg_text => 'Get Extended Account Type dimension ID');

      SELECT dimension_id
      INTO pv_ext_acct_type_dim_id
      FROM fem_dimensions_b
      WHERE dimension_varchar_label = 'EXTENDED_ACCOUNT_TYPE';

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'get_dim_ids',
         p_msg_text => 'Get Natural Account dimension ID');

      SELECT dimension_id
      INTO pv_nat_acct_dim_id
      FROM fem_dimensions_b
      WHERE dimension_varchar_label = 'NATURAL_ACCOUNT';

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'get_dim_ids.end',
         p_msg_text => 'END');

   EXCEPTION

      WHEN OTHERS THEN
      -- ------------------------
      -- Unexpected exception
      -- ------------------------

         pv_sqlerrm   := SQLERRM;
         pv_callstack := dbms_utility.format_call_stack;
         pv_proc_name := 'get_dim_ids';

         RAISE;

   END Get_Dim_IDs;
-- =======================================================================


-- =======================================================================
   PROCEDURE Validate_Budget IS
-- =======================================================================
-- Purpose
--    Validates the Budget ID engine parameter
-- History
--    11-13-03  G Hall          Created
--    03-30-06  G Hall          Bug# 5121106: Removed validation against
--                              BUDGET_LEDGER attribute.
-- Notes
--    Called by Validate_Engine_Parameters
-- =======================================================================

      v_ds_budget_id    fem_datasets_attr.dim_attribute_numeric_member%TYPE;
      v_budget_ledger   fem_budgets_attr.dim_attribute_numeric_member%TYPE;

   BEGIN

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'validate_budget.begin',
         p_msg_text => 'BEGIN');

   -- Validate the Budget ID engine parameter by looking up the Budget
   -- Display Code, and set it in a package variable.

      BEGIN

         SELECT budget_display_code
         INTO pv_budget_dsp_cd
         FROM fem_budgets_b
         WHERE budget_id = pv_budget_id
           AND enabled_flag  = 'Y'
           AND personal_flag = 'N';

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'validate_budget.pv_budget_dsp_cd',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'pv_budget_dsp_cd',
          p_token2   => 'VAR_VAL',
          p_value2   => pv_budget_dsp_cd);

      EXCEPTION
         WHEN NO_DATA_FOUND THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_budget.ibid1.',
               p_msg_text => 'raising Invalid_Budget_ID');

            RAISE Invalid_Budget_ID;
      END;

   -- Look up the BUDGET_ID attribute of the Dataset
   -- and make sure it matches the Budget ID parameter.

      BEGIN

         fem_dimension_util_pkg.get_dim_attr_id_ver_id
           (x_err_code    => pv_API_return_code,
            x_attr_id     => pv_dim_attr_id,
            x_ver_id      => pv_dim_attr_ver_id,
            p_dim_id      => pv_dataset_dim_id,
            p_attr_label  => 'BUDGET_ID');

         IF pv_API_return_code > 0 THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_budget.idsc1.',
               p_msg_text => 'raising Invalid_Dataset_Code');

            RAISE Invalid_Dataset_Code;

         END IF;

         SELECT dim_attribute_numeric_member
         INTO v_ds_budget_id
         FROM fem_datasets_attr
         WHERE attribute_id  = pv_dim_attr_id
           AND version_id    = pv_dim_attr_ver_id
           AND dataset_code  = pv_dataset_code;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_budget.idsc2.',
               p_msg_text => 'raising Invalid_Dataset_Code');

            RAISE Invalid_Dataset_Code;
      END;

      IF pv_budget_id <> v_ds_budget_id THEN

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_statement,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'validate_budget.ibds1.',
            p_msg_text => 'raising Invalid_Budget_or_Dataset');

         RAISE Invalid_Budget_or_Dataset;

      END IF;

   -- Successful completion

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'validate_budget.end',
         p_msg_text => 'END');

   EXCEPTION

      WHEN OTHERS THEN

      -- In case it's an unexpected exception

         pv_sqlerrm   := SQLERRM;
         pv_callstack := dbms_utility.format_call_stack;

      -- For all exceptions:

         pv_proc_name := 'validate_budget';

         RAISE;

   END Validate_Budget;
-- =======================================================================


-- =======================================================================
   PROCEDURE Validate_Cal_Period IS
-- =======================================================================
-- Purpose
--    Validates the Cal Period ID engine parameter and looks up and sets
--    the period-related package variables.
-- History
--    11-13-03  G Hall  Created
--    05-28-04  G Hall  Bug# 3659504: Updated Cal_Period_ID validation logic
--                      as required by change in Ledger attribute for Ledger
--                      Cal Period hierarchy.
--    07/07/05  G Hall  Bug# 4395891: Updated validation logic to only require
--                      that the CAL_PERIOD_ID belong to the same Calendar as
--                      the Ledger hierarchy, but does not need to be a node
--                      in that hierarchy.
-- Notes
--    Called by Validate_Engine_Parameters
-- =======================================================================

      v_cal_per_dim_group_id   fem_cal_periods_b.dimension_group_id%TYPE;
      v_cp_exists_in_hier      VARCHAR2(1);

   BEGIN

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'validate_cal_period.begin',
         p_msg_text => 'BEGIN');

      BEGIN

      -- Get the Cal Period Calendar ID and the Cal Period Dimension Group
      -- Display Code, and set the former into a package variable.

         SELECT calendar_id, dimension_group_id
         INTO pv_cal_per_calendar_id, v_cal_per_dim_group_id
         FROM fem_cal_periods_b
         WHERE cal_period_id = pv_cal_period_id
           AND enabled_flag  = 'Y'
           AND personal_flag = 'N';

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'validate_cal_period.pv_cal_per_calendar_id',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'pv_cal_per_calendar_id',
          p_token2   => 'VAR_VAL',
          p_value2   => TO_CHAR(pv_cal_per_calendar_id));

         SELECT dimension_group_display_code
         INTO pv_cal_per_dim_grp_dsp_cd
         FROM fem_dimension_grps_b
         WHERE dimension_group_id = v_cal_per_dim_group_id;

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'validate_cal_period.pv_cal_per_dim_grp_dsp_cd',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'pv_cal_per_dim_grp_dsp_cd',
          p_token2   => 'VAR_VAL',
          p_value2   => pv_cal_per_dim_grp_dsp_cd);

      EXCEPTION
         WHEN NO_DATA_FOUND THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_cal_period.icpid1.',
               p_msg_text => 'raising Invalid_Cal_Period_ID');

            RAISE Invalid_Cal_Period_ID;
      END;

   -- Compare the Cal Period Calendar ID and the Ledger Calendar ID.

      IF pv_cal_per_calendar_id <> pv_ledger_calendar_id THEN

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_statement,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'validate_cal_period.lcneqpc.',
            p_msg_text => 'raising Ledger_Cal_NEQ_Period_Cal');

         RAISE Ledger_Cal_NEQ_Period_Cal;

      END IF;

      BEGIN

      -- Retrieve the CAL_PERIOD_END_DATE attribute of the Cal Period ID
      -- and set it into a package variable.

         fem_dimension_util_pkg.get_dim_attr_id_ver_id
           (x_err_code    => pv_API_return_code,
            x_attr_id     => pv_dim_attr_id,
            x_ver_id      => pv_dim_attr_ver_id,
            p_dim_id      => pv_cal_per_dim_id,
            p_attr_label  => 'CAL_PERIOD_END_DATE');

         IF pv_API_return_code > 0 THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_cal_period.icpid2.',
               p_msg_text => 'raising Invalid_Cal_Period_ID');

            RAISE Invalid_Cal_Period_ID;

         END IF;

         SELECT date_assign_value
         INTO pv_cal_per_end_date
         FROM fem_cal_periods_attr
         WHERE attribute_id  = pv_dim_attr_id
           AND version_id    = pv_dim_attr_ver_id
           AND cal_period_id = pv_cal_period_id;

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'validate_cal_period.pv_cal_per_end_date',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'pv_cal_per_end_date',
          p_token2   => 'VAR_VAL',
          p_value2   => TO_CHAR(pv_cal_per_end_date, 'DD-MON-YYYY'));

      EXCEPTION
         WHEN NO_DATA_FOUND THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_cal_period.icpid3.',
               p_msg_text => 'raising Invalid_Cal_Period_ID');

            RAISE Invalid_Cal_Period_ID;
      END;

      BEGIN

      -- Get the Calendar Period Number from the GL_PERIOD_NUM attribute of the
      -- Cal Period ID and set it into a package variable.

         fem_dimension_util_pkg.get_dim_attr_id_ver_id
           (x_err_code    => pv_API_return_code,
            x_attr_id     => pv_dim_attr_id,
            x_ver_id      => pv_dim_attr_ver_id,
            p_dim_id      => pv_cal_per_dim_id,
            p_attr_label  => 'GL_PERIOD_NUM');

         IF pv_API_return_code > 0 THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_cal_period.icpid4.',
               p_msg_text => 'raising Invalid_Cal_Period_ID');

            RAISE Invalid_Cal_Period_ID;

         END IF;

         SELECT number_assign_value
         INTO pv_gl_per_number
         FROM fem_cal_periods_attr
         WHERE attribute_id  = pv_dim_attr_id
           AND version_id    = pv_dim_attr_ver_id
           AND cal_period_id = pv_cal_period_id;

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'validate_cal_period.pv_gl_per_number',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'pv_gl_per_number',
          p_token2   => 'VAR_VAL',
          p_value2   => TO_CHAR(pv_gl_per_number));

      EXCEPTION
         WHEN NO_DATA_FOUND THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_cal_period.icpid5.',
               p_msg_text => 'raising Invalid_Cal_Period_ID');

            RAISE Invalid_Cal_Period_ID;
      END;

   -- Successful completion

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'validate_cal_period.end',
         p_msg_text => 'END');

   EXCEPTION

      WHEN OTHERS THEN
      -- In case it's an unexpected exception

         pv_sqlerrm   := SQLERRM;
         pv_callstack := dbms_utility.format_call_stack;

      -- For all exceptions:

         pv_proc_name := 'validate_cal_period';

         RAISE;

   END Validate_Cal_Period;
-- =======================================================================


-- =======================================================================
   PROCEDURE Validate_Dataset IS
-- =======================================================================
-- Purpose
--    Validates the Dataset Code engine parameter.
-- History
--    11-13-03  G Hall          Created
-- Notes
--    Called by Validate_Engine_Parameters
-- =======================================================================

      v_rowcount   PLS_INTEGER;

   BEGIN

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'validate_dataset.begin',
         p_msg_text => 'BEGIN');


   -- Validate the Dataset Code engine parameter.

      SELECT COUNT(*)
      INTO v_rowcount
      FROM fem_datasets_b
      WHERE dataset_code  = pv_dataset_code
        AND enabled_flag  = 'Y'
        AND personal_flag = 'N';

      IF v_rowcount <> 1 THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_dataset.idsc7.',
               p_msg_text => 'raising Invalid_Dataset_Code');

         RAISE Invalid_Dataset_Code;

      END IF;

   -- Look up the Dataset Code DATASET_BALANCE_TYPE_CODE attribute

      BEGIN

         fem_dimension_util_pkg.get_dim_attr_id_ver_id
           (x_err_code    => pv_API_return_code,
            x_attr_id     => pv_dim_attr_id,
            x_ver_id      => pv_dim_attr_ver_id,
            p_dim_id      => pv_dataset_dim_id,
            p_attr_label  => 'DATASET_BALANCE_TYPE_CODE');

         IF pv_API_return_code > 0 THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_dataset.idsc8.',
               p_msg_text => 'raising Invalid_Dataset_Code');

            RAISE Invalid_Dataset_Code;

         END IF;

         SELECT dim_attribute_varchar_member
         INTO pv_ds_balance_type_cd
         FROM fem_datasets_attr
         WHERE attribute_id  = pv_dim_attr_id
           AND version_id    = pv_dim_attr_ver_id
           AND dataset_code  = pv_dataset_code;

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'validate_dataset.pv_ds_balance_type_cd',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'pv_ds_balance_type_cd',
          p_token2   => 'VAR_VAL',
          p_value2   => pv_ds_balance_type_cd);

      EXCEPTION
         WHEN NO_DATA_FOUND THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_dataset.idsc9.',
               p_msg_text => 'raising Invalid_Dataset_Code');

            RAISE Invalid_Dataset_Code;
      END;

   -- Successful completion

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'validate_dataset.end',
         p_msg_text => 'END');

   EXCEPTION

      WHEN OTHERS THEN

      -- In case it's an unexpected exception

         pv_sqlerrm   := SQLERRM;
         pv_callstack := dbms_utility.format_call_stack;

      -- For all exceptions:

         pv_proc_name := 'validate_dataset';

         RAISE;

   END Validate_Dataset;
-- =======================================================================


-- =======================================================================
   PROCEDURE Validate_DS_Bal_Type IS
-- =======================================================================
-- Purpose
--    Validates that the Dataset Balance Type has not already been run
--    for a different dataset for the current ledger and period.
-- History
--    07-19-05  G Hall  Created
--    03-30-06  G Hall  Bug# 5121111: Added specific validations for
--                      Budget and Encumbrance.
--    06-25-09  G Hall  Bug# 7691287: Now raises Warn_DS_Bal_Type instead
--                      of Invalid_DS_Bal_Type.
-- Notes
--    Called by Validate_Engine_Parameters
-- =======================================================================

   BEGIN

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'validate_ds_bal_type.begin',
         p_msg_text => 'BEGIN');

      IF pv_ds_balance_type_cd = 'ACTUAL' THEN

         SELECT MAX(r.output_dataset_code)
         INTO pv_precedent_dataset_code
         FROM fem_pl_requests r,
              fem_pl_object_executions x,
              fem_object_catalog_b o
         WHERE r.ledger_id = pv_ledger_id
           AND r.cal_period_id = pv_cal_period_id
           AND r.output_dataset_code <> pv_dataset_code
           AND r.exec_mode_code = 'S'
           AND r.exec_status_code = 'SUCCESS'
           AND x.request_id = r.request_id
           AND o.object_id = x.object_id
           AND o.object_type_code = 'XGL_INTEGRATION'
           AND 'ACTUAL' =
              (SELECT DIM_ATTRIBUTE_VARCHAR_MEMBER
               FROM fem_datasets_attr
               WHERE dataset_code = r.output_dataset_code
                 AND (attribute_id, version_id) =
                    (SELECT a.attribute_id, v.version_id
                     FROM fem_dim_attributes_b a,
                          fem_dim_attr_versions_b v
                     WHERE a.attribute_varchar_label = 'DATASET_BALANCE_TYPE_CODE'
                       AND v.attribute_id = a.attribute_id
                       and v.default_version_flag = 'Y'));

      ELSIF pv_ds_balance_type_cd = 'BUDGET' THEN

         SELECT MAX(r.output_dataset_code)
         INTO pv_precedent_dataset_code
         FROM fem_pl_requests r,
              fem_pl_object_executions x,
              fem_object_catalog_b o
         WHERE r.ledger_id = pv_ledger_id
           AND r.cal_period_id = pv_cal_period_id
           AND r.output_dataset_code <> pv_dataset_code
           AND r.exec_mode_code = 'S'
           AND r.exec_status_code = 'SUCCESS'
           AND x.request_id = r.request_id
           AND o.object_id = x.object_id
           AND o.object_type_code = 'XGL_INTEGRATION'
           AND pv_budget_id =
              (SELECT DIM_ATTRIBUTE_NUMERIC_MEMBER
               FROM fem_datasets_attr
               WHERE dataset_code = r.output_dataset_code
                 AND (attribute_id, version_id) =
                    (SELECT a.attribute_id, v.version_id
                     FROM fem_dim_attributes_b a,
                          fem_dim_attr_versions_b v
                     WHERE a.attribute_varchar_label = 'BUDGET_ID'
                       AND v.attribute_id = a.attribute_id
                       and v.default_version_flag = 'Y'));

      ELSIF pv_ds_balance_type_cd = 'ENCUMBRANCE' THEN

         SELECT MAX(r.output_dataset_code)
         INTO pv_precedent_dataset_code
         FROM fem_pl_requests r,
              fem_pl_object_executions x,
              fem_object_catalog_b o
         WHERE r.ledger_id = pv_ledger_id
           AND r.cal_period_id = pv_cal_period_id
           AND r.output_dataset_code <> pv_dataset_code
           AND r.exec_mode_code = 'S'
           AND r.exec_status_code = 'SUCCESS'
           AND x.request_id = r.request_id
           AND o.object_id = x.object_id
           AND o.object_type_code = 'XGL_INTEGRATION'
           AND pv_enc_type_id =
              (SELECT DIM_ATTRIBUTE_NUMERIC_MEMBER
               FROM fem_datasets_attr
               WHERE dataset_code = r.output_dataset_code
                 AND (attribute_id, version_id) =
                    (SELECT a.attribute_id, v.version_id
                     FROM fem_dim_attributes_b a,
                          fem_dim_attr_versions_b v
                     WHERE a.attribute_varchar_label = 'ENCUMBRANCE_TYPE_ID'
                       AND v.attribute_id = a.attribute_id
                       and v.default_version_flag = 'Y'));

      END IF;

      IF pv_precedent_dataset_code > 0 THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_ds_bal_type.idsbt.',
               p_msg_text => 'raising Warn_DS_Bal_Type');

         RAISE Warn_DS_Bal_Type;

      END IF;

   -- Successful completion

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'validate_ds_bal_type.end',
         p_msg_text => 'END');

   EXCEPTION

      WHEN OTHERS THEN

      -- In case it's an unexpected exception

         pv_sqlerrm   := SQLERRM;
         pv_callstack := dbms_utility.format_call_stack;

      -- For all exceptions:

         pv_proc_name := 'validate_ds_bal_type';

         RAISE;

   END Validate_DS_Bal_Type;
-- =======================================================================


-- =======================================================================
   PROCEDURE Validate_Encumbrance_Type IS
-- =======================================================================
-- Purpose
--    Validates the Encumbrance Type ID engine parameter
-- History
--    11-13-03  G Hall          Created
-- Notes
--    Called by Validate_Engine_Parameters
-- =======================================================================

      v_ds_enc_type_id   fem_datasets_attr.dim_attribute_numeric_member%TYPE;

   BEGIN

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'validate_encumbrance_type.begin',
         p_msg_text => 'BEGIN');

   -- Validate the Encumbrance Type ID engine parameter by looking up
   -- the Encumbrance Type [Display] Code, and set it in a package
   -- variable.

      BEGIN

         SELECT encumbrance_type_code
         INTO pv_enc_type_dsp_cd
         FROM fem_encumbrance_types_b
         WHERE encumbrance_type_id = pv_enc_type_id
           AND enabled_flag  = 'Y'
           AND personal_flag = 'N';

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'validate_encumbrance_type.pv_enc_type_dsp_cd',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'pv_enc_type_dsp_cd',
          p_token2   => 'VAR_VAL',
          p_value2   => pv_enc_type_dsp_cd);

      EXCEPTION
         WHEN NO_DATA_FOUND THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_encumbrance_type.ietid1.',
               p_msg_text => 'raising Invalid_Enc_Type_ID');

            RAISE Invalid_Enc_Type_ID;

      END;

   -- Look up the DATASET_ENCUMBRANCE_TYPE_ID attribute of the Dataset
   -- and make sure it matches the Encumbrance Type ID parameter.

      BEGIN

         fem_dimension_util_pkg.get_dim_attr_id_ver_id
           (x_err_code    => pv_API_return_code,
            x_attr_id     => pv_dim_attr_id,
            x_ver_id      => pv_dim_attr_ver_id,
            p_dim_id      => pv_dataset_dim_id,
            p_attr_label  => 'ENCUMBRANCE_TYPE_ID');

         IF pv_API_return_code > 0 THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_encumbrance_type.idsc3.',
               p_msg_text => 'raising Invalid_Dataset_Code');

            RAISE Invalid_Dataset_Code;

         END IF;

         SELECT dim_attribute_numeric_member
         INTO v_ds_enc_type_id
         FROM fem_datasets_attr
         WHERE attribute_id  = pv_dim_attr_id
           AND version_id    = pv_dim_attr_ver_id
           AND dataset_code  = pv_dataset_code;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_encumbrance_type.idsc4.',
               p_msg_text => 'raising Invalid_Dataset_Code');

            RAISE Invalid_Dataset_Code;
      END;

      IF pv_enc_type_id <> v_ds_enc_type_id THEN

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_statement,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'validate_encumbrance_type.ieds1.',
            p_msg_text => 'raising Invalid_Enc_or_Dataset');

         RAISE Invalid_Enc_or_Dataset;

      END IF;

   -- Successful completion

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'validate_encumbrance_type.end',
         p_msg_text => 'END');

   EXCEPTION

      WHEN OTHERS THEN

      -- In case it's an unexpected exception

         pv_sqlerrm   := SQLERRM;
         pv_callstack := dbms_utility.format_call_stack;

      -- For all exceptions:

         pv_proc_name := 'validate_encumbrance_type';

         RAISE;

   END Validate_Encumbrance_Type;
-- =======================================================================


-- =======================================================================
   PROCEDURE Validate_Ledger IS
-- =======================================================================
-- Purpose
--    Validate the Ledger ID engine parameter. Look up the Calendar ID
--    assigned to it for comparison with the Calendar ID for the period.
-- History
--    11-13-03  G Hall  Created
--    01-26-04  G Hall  Added Entered Currency Enable Flag ledger
--                      attribute lookup.
--    05-28-04  G Hall  Bug# 3659504: Updated Cal_Period_ID validation logic
--                      as required by change in Ledger attribute for Ledger
--                      Cal Period hierarchy.
--    11-16-04  L POON  Add changes for FEM-OGL Integration Project
-- Notes
--    Called by Validate_Engine_Parameters
-- =======================================================================

   BEGIN

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'validate_ledger.begin',
         p_msg_text => 'BEGIN');

      BEGIN

      -- Validate the Ledger ID engine parameter by looking up the Ledger
      -- Display Code, and set it in a package variable.

         SELECT ledger_display_code
         INTO pv_ledger_dsp_cd
         FROM fem_ledgers_b
         WHERE ledger_id = pv_ledger_id
           AND enabled_flag  = 'Y'
           AND personal_flag = 'N';

         FEM_ENGINES_PKG.Tech_Message
         (p_severity => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'validate_ledger.pv_ledger_dsp_cd',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'pv_ledger_dsp_cd',
          p_token2   => 'VAR_VAL',
          p_value2   => pv_ledger_dsp_cd);

      EXCEPTION
         WHEN NO_DATA_FOUND THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_ledger.ilid1.',
               p_msg_text => 'raising Invalid_Ledger_ID');

            RAISE Invalid_Ledger_ID;
      END;

      BEGIN

      -- Get the Entered Currency Enable Flag attribute of the Ledger ID and store
      -- it as a package variable.

         fem_dimension_util_pkg.get_dim_attr_id_ver_id
           (x_err_code    => pv_API_return_code,
            x_attr_id     => pv_dim_attr_id,
            x_ver_id      => pv_dim_attr_ver_id,
            p_dim_id      => pv_ledger_dim_id,
            p_attr_label  => 'ENTERED_CRNCY_ENABLE_FLAG');

         IF pv_API_return_code > 0 THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_ledger.ilid7.',
               p_msg_text => 'raising Invalid_Ledger_ID');

            pv_attr_label := 'ENTERED_CRNCY_ENABLE_FLAG';

            RAISE Invalid_Ledger_ID;

         END IF;

         SELECT dim_attribute_varchar_member
         INTO pv_entered_crncy_flag
         FROM fem_ledgers_attr
         WHERE attribute_id  = pv_dim_attr_id
           AND version_id    = pv_dim_attr_ver_id
           AND ledger_id     = pv_ledger_id;

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'validate_ledger.pv_entered_crncy_flag',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'pv_entered_crncy_flag',
          p_token2   => 'VAR_VAL',
          p_value2   => pv_entered_crncy_flag);

      EXCEPTION
         WHEN NO_DATA_FOUND THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_ledger.ilid8.',
               p_msg_text => 'raising Invalid_Ledger_ID');

            pv_attr_label := 'ENTERED_CRNCY_ENABLE_FLAG';

            RAISE Invalid_Ledger_ID;
      END;

      BEGIN

      -- Get the Hierarchy Object Definition ID of the Time hierarchy assigned
      -- to the given ledger. It is stored as a row-based ledger attribute.

         fem_dimension_util_pkg.get_dim_attr_id_ver_id
           (x_err_code    => pv_API_return_code,
            x_attr_id     => pv_dim_attr_id,
            x_ver_id      => pv_dim_attr_ver_id,
            p_dim_id      => pv_ledger_dim_id,
            p_attr_label  => 'CAL_PERIOD_HIER_OBJ_DEF_ID');

         IF pv_API_return_code> 0 THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_ledger.ilid4.',
               p_msg_text => 'raising Invalid_Ledger_ID');

            pv_attr_label := 'CAL_PERIOD_HIER_OBJ_DEF_ID';

            RAISE Invalid_Ledger_ID;

         END IF;

         SELECT dim_attribute_numeric_member
         INTO pv_ledger_per_hier_obj_def_id
         FROM fem_ledgers_attr
         WHERE attribute_id  = pv_dim_attr_id
           AND version_id    = pv_dim_attr_ver_id
           AND ledger_id     = pv_ledger_id;

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'validate_ledger.pv_lph_odid',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'pv_ledger_per_hier_obj_def_id',
          p_token2   => 'VAR_VAL',
          p_value2   => pv_ledger_per_hier_obj_def_id);

         SELECT object_id
         INTO pv_ledger_per_hier_obj_id
         FROM fem_object_definition_b
         WHERE object_definition_id = pv_ledger_per_hier_obj_def_id;

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'validate_ledger.pv_lph_oid',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'pv_ledger_per_hier_obj_id',
          p_token2   => 'VAR_VAL',
          p_value2   => pv_ledger_per_hier_obj_id);

      EXCEPTION
         WHEN NO_DATA_FOUND THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_ledger.ilid5.',
               p_msg_text => 'raising Invalid_Ledger_ID');

            pv_attr_label := 'CAL_PERIOD_HIER_OBJ_DEF_ID';

            RAISE Invalid_Ledger_ID;
      END;

      BEGIN

      -- Look up the Calendar ID for that hierarchy.

         SELECT calendar_id
         INTO pv_ledger_calendar_id
         FROM fem_hierarchies
         WHERE hierarchy_obj_id = pv_ledger_per_hier_obj_id;

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'validate_ledger.pv_ledger_calendar_id',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'pv_ledger_calendar_id',
          p_token2   => 'VAR_VAL',
          p_value2   => TO_CHAR(pv_ledger_calendar_id));

      EXCEPTION
         WHEN NO_DATA_FOUND THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_ledger.ilid6.',
               p_msg_text => 'raising Invalid_Ledger_ID');

            pv_attr_label := 'CAL_PERIOD_HIER_OBJ_DEF_ID';

            RAISE Invalid_Ledger_ID;
      END;


      BEGIN

      -- FEM-OGL Intg: Added to get the Ledger Functional Currency Code
     -- attribute of the Ledger ID and store it as a package variable.

         fem_dimension_util_pkg.get_dim_attr_id_ver_id
           (x_err_code    => pv_API_return_code,
            x_attr_id     => pv_dim_attr_id,
            x_ver_id      => pv_dim_attr_ver_id,
            p_dim_id      => pv_ledger_dim_id,
            p_attr_label  => 'LEDGER_FUNCTIONAL_CRNCY_CODE');

         IF pv_API_return_code > 0 THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_ledger.ilid9.',
               p_msg_text => 'raising Invalid_Ledger_ID');

            pv_attr_label := 'LEDGER_FUNCTIONAL_CRNCY_CODE';

            RAISE Invalid_Ledger_ID;

         END IF;

         SELECT dim_attribute_varchar_member
         INTO pv_func_ccy_code
         FROM fem_ledgers_attr
         WHERE attribute_id  = pv_dim_attr_id
           AND version_id    = pv_dim_attr_ver_id
           AND ledger_id     = pv_ledger_id;

         FEM_ENGINES_PKG.Tech_Message
         (p_severity => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'validate_ledger.pv_func_ccy_code',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'pv_func_ccy_code',
          p_token2   => 'VAR_VAL',
          p_value2   => pv_func_ccy_code);

      EXCEPTION
         WHEN NO_DATA_FOUND THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_ledger.ilid10.',
               p_msg_text => 'raising Invalid_Ledger_ID');

            pv_attr_label := 'LEDGER_FUNCTIONAL_CRNCY_CODE';

            RAISE Invalid_Ledger_ID;
      END;

      BEGIN

      -- FEM-OGL Intg: Added to get the Global Value Set Combination ID
     -- attribute of the Ledger ID and store it as a package variable.

         fem_dimension_util_pkg.get_dim_attr_id_ver_id
           (x_err_code    => pv_API_return_code,
            x_attr_id     => pv_dim_attr_id,
            x_ver_id      => pv_dim_attr_ver_id,
            p_dim_id      => pv_ledger_dim_id,
            p_attr_label  => 'GLOBAL_VS_COMBO');

         IF pv_API_return_code > 0 THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_ledger.ilid11.',
               p_msg_text => 'raising Invalid_Ledger_ID');

            pv_attr_label := 'GLOBAL_VS_COMBO';

            RAISE Invalid_Ledger_ID;

         END IF;

         SELECT dim_attribute_numeric_member
         INTO pv_global_vs_combo_id
         FROM fem_ledgers_attr
         WHERE attribute_id  = pv_dim_attr_id
           AND version_id    = pv_dim_attr_ver_id
           AND ledger_id     = pv_ledger_id;

         FEM_ENGINES_PKG.Tech_Message
         (p_severity => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'validate_ledger.pv_global_vs_combo_id',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'pv_global_vs_combo_id',
          p_token2   => 'VAR_VAL',
          p_value2   => pv_global_vs_combo_id);

      EXCEPTION
         WHEN NO_DATA_FOUND THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_ledger.ilid12.',
               p_msg_text => 'raising Invalid_Ledger_ID');

            pv_attr_label := 'GLOBAL_VS_COMBO';

            RAISE Invalid_Ledger_ID;
      END;

   -- Successful completion

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'validate_ledger.end',
         p_msg_text => 'END');

   EXCEPTION

      WHEN OTHERS THEN

      -- In case it's an unexpected exception

         pv_sqlerrm   := SQLERRM;
         pv_callstack := dbms_utility.format_call_stack;

      -- For all exceptions:

         pv_proc_name := 'validate_ledger';

         RAISE;

   END Validate_Ledger;
-- =======================================================================


-- =======================================================================
   PROCEDURE Validate_Object_Def_ID IS
-- =======================================================================
-- Purpose
--    Validates the Object Def ID engine parameter and its Object ID
-- History
--    11-13-03  G Hall  Created
--    01-26-04  G Hall  Added user privileges validation; added "AND
--                      old_approved_copy_flag = 'N'";
--    04-22-04  G Hall  Bug# 3585824: Commented out user/folder security
--                      validation since there's no Folders Security
--                      UI yet.
--    11-16-04  L POON  Add changes for FEM-OGL Integration Project
-- Notes
--    Called by Validate_Engine_Parameters
-- =======================================================================

      v_obj_approval_status_cd   fem_object_definition_b.approval_status_code%TYPE;
      v_folder_id                fem_object_catalog_b.folder_id%TYPE;
      v_ds_production_flag       fem_datasets_attr.dim_attribute_varchar_member%TYPE;
      v_rowcount                 PLS_INTEGER;

   BEGIN

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'validate_object_def_id.begin',
         p_msg_text => 'BEGIN');

   -- --------------------------------------------------------------------
   -- Validate the Object Definition ID engine parameter by looking up the
   -- Object ID and set it in a package variable.
   -- --------------------------------------------------------------------

      BEGIN

         SELECT object_id, approval_status_code
         INTO pv_rule_obj_id, v_obj_approval_status_cd
         FROM fem_object_definition_b
         WHERE object_definition_id   = pv_rule_obj_def_id
           AND old_approved_copy_flag = 'N';

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'validate_object_def_id.pv_rule_obj_id',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'pv_rule_obj_id',
          p_token2   => 'VAR_VAL',
          p_value2   => TO_CHAR(pv_rule_obj_id));

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'validate_object_def_id.v_obj_approval_status_cd',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'v_obj_approval_status_cd',
          p_token2   => 'VAR_VAL',
          p_value2   => v_obj_approval_status_cd);

      EXCEPTION
         WHEN NO_DATA_FOUND THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_object_def_id.iodid1.',
               p_msg_text => 'raising Invalid_Object_Def_ID');

            RAISE Invalid_Object_Def_ID;
      END;

   -- --------------------------------------------------------------------
   -- Get the Object Type Code and the Folder ID for the rule.
   -- --------------------------------------------------------------------

      BEGIN

         SELECT object_type_code, folder_id
         INTO pv_obj_type_cd, v_folder_id
         FROM fem_object_catalog_b
         WHERE object_id = pv_rule_obj_id;

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'validate_object_def_id.pv_obj_type_cd',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'pv_obj_type_cd',
          p_token2   => 'VAR_VAL',
          p_value2   => pv_obj_type_cd);

         FEM_ENGINES_PKG.Tech_Message
         (p_severity    => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                        'validate_object_def_id.v_folder_id',
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'v_folder_id',
          p_token2   => 'VAR_VAL',
          p_value2   => TO_CHAR(v_folder_id));

      EXCEPTION
         WHEN NO_DATA_FOUND THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_object_def_id.iobj1.',
               p_msg_text => 'raising Invalid_Object_ID');

            RAISE Invalid_Object_ID;
      END;

   -- --------------------------------------------------------------------
   -- Validate that the user has privileges to execute this rule.
   -- Commented out per Bug# 3585824
   -- --------------------------------------------------------------------

   -- FEM-OGL Intg: Folder Security is ready, so uncomment the following codes
   -- removed code

   -- FEM-OGL Intg: Since workflow is not implemented for OGL, the following
   -- codes will be only executed for XGL for this release.
   IF pv_obj_type_cd = 'XGL_INTEGRATION' THEN

   -- --------------------------------------------------------------------
   -- Validate that the approval status of the Object Definition is
   -- compatible with the Dataset's production status.
   -- --------------------------------------------------------------------

      BEGIN

         fem_dimension_util_pkg.get_dim_attr_id_ver_id
           (x_err_code    => pv_API_return_code,
            x_attr_id     => pv_dim_attr_id,
            x_ver_id      => pv_dim_attr_ver_id,
            p_dim_id      => pv_dataset_dim_id,
            p_attr_label  => 'PRODUCTION_FLAG');

         IF pv_API_return_code > 0 THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_object_def_id.idsc5.',
               p_msg_text => 'raising Invalid_Dataset_Code');

            v_ds_production_flag := 'N';

         END IF;

         SELECT dim_attribute_varchar_member
         INTO v_ds_production_flag
         FROM fem_datasets_attr
         WHERE attribute_id  = pv_dim_attr_id
           AND version_id    = pv_dim_attr_ver_id
           AND dataset_code  = pv_dataset_code;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_ds_production_flag := 'N';
      END;

   -- If the Dataset is in "Production" status, then the Object definition
   -- must be in "Approved" status

      IF (v_ds_production_flag = 'Y') AND
         (v_obj_approval_status_cd <> 'APPROVED') THEN

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_statement,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'validate_object_def_id.ioas1.',
            p_msg_text => 'raising Invalid_Obj_Approval_Status');

         RAISE Invalid_Obj_Approval_Status;

      END IF;

   END IF; -- IF pv_obj_type_cd = 'XGL_INTEGRATION' THEN

   -- Successful completion
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'validate_object_def_id.end',
         p_msg_text => 'END');

   EXCEPTION

      WHEN OTHERS THEN

      -- In case it's an unexpected exception

         pv_sqlerrm   := SQLERRM;
         pv_callstack := dbms_utility.format_call_stack;

      -- For all exceptions:

         pv_proc_name := 'validate_object_def_id';

         RAISE;

   END Validate_Object_Def_ID;
-- =======================================================================


-- =======================================================================
   PROCEDURE Validate_Engine_Parameters
               (x_completion_code OUT NOCOPY NUMBER) IS
-- =======================================================================
-- Purpose
--    Validates the dimension-based engine parameters that are common
--    to both the XGL and the OGL engines, and sets additional package
--    variables that are common to both.
-- History
--    11-13-03  G Hall  Created
--    01-26-04  G Hall  Added pv_pgm_app_id; added validation for
--                      Budget ID OR Encumbrance Type, not both;
--    01-27-04  G Hall  Modified call to Get_Proc_Key_Info.
--    02-16-04  G Hall  Enhanced validation for Budget and Encumbrance
--                      parameters.
--    05-07-04  G Hall  Bug# 3597527: Removed call to Get_Proc_Key_Info.
--    05-25-04  G Hall  Removed Value_Set_ID_Error exception; moved it
--                      to Get_Proc_Key_Info and modified it for passing
--                      back a status and message to Main.
--    05-28-04  G Hall  Bug# 3659504: Swapped order of calls to
--                      Validate_Cal_Period and Validate_Ledger.
--    03-30-06  G Hall  Bug# 5121111: Added specific error handling to
--                      Invalid_DS_Bal_Type for Budget and Encumbrance.
--    06-25-09  G Hall  Bug# 7691287 (FP of 11i bug 6970161):
--                      Changed Invalid_DS_Bal_Type exception
--                      to Warn_DS_Bal_Type exception, set x_completion_code
--                      to 1 in the exception handler.
-- Arguments
--    x_completion_code Returns 0 for success, 1 for warning, 2 for failure.
-- Notes
--    Called by Validate_XGL_Eng_Parameters
--    (and by Validate_OGL_Eng_Parameters)
-- =======================================================================

      v_dim_name1                   fem_dimensions_tl.dimension_name%TYPE;
      v_dim_name2                   fem_dimensions_tl.dimension_name%TYPE;
      v_attr_name                   fem_dim_attributes_tl.attribute_name%TYPE;
      v_precedent_dataset_name      fem_datasets_tl.dataset_name%TYPE;
      v_ds_balance_type_name        fem_ds_balance_types_tl.ds_balance_type_name%TYPE;
      v_budget_name                 fem_budgets_tl.budget_name%TYPE;
      v_enc_type_name               fem_encumbrance_types_tl.encumbrance_type_name%TYPE;
      v_ds_balance_type_string      VARCHAR2(300);

   BEGIN

      x_completion_code := 2;
      pv_proc_name  := 'validate_engine_parameters';
      pv_attr_label := NULL;

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'validate_engine_parameters.begin',
         p_msg_text => 'BEGIN');

   --------------------------------------------------------------------------
   -- Validate the execution mode parameter
   --------------------------------------------------------------------------

      IF pv_exec_mode NOT IN ('S', 'I', 'E') THEN

      -- Execution mode is invalid

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_statement,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          'validate_engine_parameters.iem',
            p_msg_text => 'raising Invalid_Execution_Mode');

         RAISE Invalid_Execution_Mode;

      END IF;

   --------------------------------------------------------------------------
   -- Set package variables common to both XGL and OGL Posting engines
   -- and log debug messages to display their values.
   --------------------------------------------------------------------------

      pv_req_id       := FND_GLOBAL.Conc_Request_Id;
      pv_user_id      := FND_GLOBAL.User_Id;
      pv_login_id     := FND_GLOBAL.Login_Id;
      pv_pgm_id       := FND_GLOBAL.Conc_Program_Id;
      pv_pgm_app_id   := FND_GLOBAL.Prog_Appl_ID;

      FEM_ENGINES_PKG.Tech_Message
      (p_severity    => pc_log_level_statement,
       p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                     'validate_engine_parameters.pv_req_id',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_req_id',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_req_id));

      FEM_ENGINES_PKG.Tech_Message
      (p_severity    => pc_log_level_statement,
       p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                     'validate_engine_parameters.pv_user_id',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_user_id',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_user_id));

      FEM_ENGINES_PKG.Tech_Message
      (p_severity    => pc_log_level_statement,
       p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                     'validate_engine_parameters.pv_login_id',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_login_id',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_login_id));

      FEM_ENGINES_PKG.Tech_Message
      (p_severity    => pc_log_level_statement,
       p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                     'validate_engine_parameters.pv_pgm_id',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_pgm_id',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_pgm_id));

   --------------------------------------------------------------------------
   -- Populate dimension ID package variables
   --------------------------------------------------------------------------

      Get_Dim_IDs;

   --------------------------------------------------------------------------
   -- Validate the p_dataset_code engine parameter.
   --------------------------------------------------------------------------

      Validate_Dataset;

   --------------------------------------------------------------------------
   -- Validate the p_xgl_obj_def_id parameter and look up and set any
   -- object_related package variables.
   --------------------------------------------------------------------------

      Validate_Object_Def_ID;

   --------------------------------------------------------------------------
   -- Validate the p_ledger_id engine parameter and look up the Calendar ID
   -- assigned to it for comparison with the Calendar ID for the period.
   --------------------------------------------------------------------------

      Validate_Ledger;

   --------------------------------------------------------------------------
   -- Validate the p_cal_period_id engine parameter and look up and set the
   -- period-related package variables.
   --------------------------------------------------------------------------

      Validate_Cal_Period;

   --------------------------------------------------------------------------
   -- Validate the Budget ID and Encumbrance Type ID engine parameters if
   -- applicable.
   --------------------------------------------------------------------------

      IF pv_ds_balance_type_cd = 'ACTUAL' THEN

         IF (pv_budget_id IS NOT NULL) OR
            (pv_enc_type_id IS NOT NULL) THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_error,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_engine_parameters.budget_enc_ignored',
               p_app_name => 'FEM',
               p_msg_name => 'FEM_GL_POST_023');

            FEM_ENGINES_PKG.User_Message
              (p_app_name => 'FEM',
               p_msg_name => 'FEM_GL_POST_023');

            pv_budget_id      := NULL;
            pv_enc_type_id    := NULL;
            x_completion_code := 1;

         END IF;

      ELSIF pv_ds_balance_type_cd = 'BUDGET' THEN

         Validate_Budget;

         IF pv_enc_type_id IS NOT NULL THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_error,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_engine_parameters.enc_type_ignored',
               p_app_name => 'FEM',
               p_msg_name => 'FEM_GL_POST_020');

            FEM_ENGINES_PKG.User_Message
              (p_app_name => 'FEM',
               p_msg_name => 'FEM_GL_POST_020');

            pv_enc_type_id    := NULL;
            x_completion_code := 1;

         END IF;

      ELSIF pv_ds_balance_type_cd = 'ENCUMBRANCE' THEN

         Validate_Encumbrance_Type;

         IF pv_budget_id IS NOT NULL THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_error,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             'validate_engine_parameters.budget_id_ignored',
               p_app_name => 'FEM',
               p_msg_name => 'FEM_GL_POST_021');

            FEM_ENGINES_PKG.User_Message
              (p_app_name => 'FEM',
               p_msg_name => 'FEM_GL_POST_021');

            pv_budget_id      := NULL;
            x_completion_code := 1;

         END IF;

      END IF;

      Validate_DS_Bal_Type;

   --------------------------------------------------------------------------
   -- Successful completion
   --------------------------------------------------------------------------

      IF x_completion_code <> 1 THEN
         x_completion_code := 0;
      END IF;

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                       'validate_engine_parameters.end',
         p_msg_text => 'END');

   EXCEPTION
   ------------------------------------------------------------------
   -- For each exception, try to get the translated names for the
   -- dimensions (parameters) and dimension attributes used as
   -- tokens in the messages logged to FND_LOG and Concurrent
   -- Request Log.
   ------------------------------------------------------------------

      WHEN Invalid_Budget_ID THEN
      ------------------------------------------------------------------
      -- Invalid Budget parameter: Value not found or
      -- Budget attribute "Budget Ledger" not set.
      ------------------------------------------------------------------

         v_dim_name1 := FEM_DIMENSION_UTIL_PKG.Get_Dimension_Name
                           (p_dim_id => pv_budget_dim_id);

         IF v_dim_name1 IS NULL THEN
            v_dim_name1 := 'Budget';
         END IF;

         v_attr_name := FEM_DIMENSION_UTIL_PKG.Get_Dim_Attr_Name
                           (p_dim_id     => pv_budget_dim_id,
                            p_attr_label => 'BUDGET_LEDGER');

         IF v_attr_name IS NULL THEN
            v_attr_name := 'Budget Ledger';
         END IF;

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_error,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          pv_proc_name || '.invalid_budget_id',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_003',
            p_token1   => 'DIMENSION_NAME1',
            p_value1   => v_dim_name1,
            p_token2   => 'DIMENSION_NAME2',
            p_value2   => v_dim_name1,
            p_token3   => 'ATTRIBUTE_NAME',
            p_value3   => v_attr_name);

         FEM_ENGINES_PKG.User_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_003',
            p_token1   => 'DIMENSION_NAME1',
            p_value1   => v_dim_name1,
            p_token2   => 'DIMENSION_NAME2',
            p_value2   => v_dim_name1,
            p_token3   => 'ATTRIBUTE_NAME',
            p_value3   => v_attr_name);

      WHEN Invalid_Budget_or_Dataset THEN
      ------------------------------------------------------------------
      -- Invalid Budget or Dataset parameter: Budget does not match
      -- Dataset attribute "Budget ID".
      ------------------------------------------------------------------

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_error,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          pv_proc_name || '.invalid_budget_or_dataset',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_007');

         FEM_ENGINES_PKG.User_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_007');

      WHEN Invalid_Cal_Period_ID THEN
      ------------------------------------------------------------------
      -- Invalid Calendar Period parameter: Value not found or
      -- Calendar Period attributes not set.
      ------------------------------------------------------------------

         v_dim_name1 := FEM_DIMENSION_UTIL_PKG.Get_Dimension_Name
                           (p_dim_id => pv_cal_per_dim_id);

         IF v_dim_name1 IS NULL THEN
            v_dim_name1 := 'Calendar Period';
         END IF;

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_error,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          pv_proc_name || '.invalid_cal_period_id',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_002',
            p_token1   => 'DIMENSION_NAME1',
            p_value1   => v_dim_name1,
            p_token2   => 'DIMENSION_NAME2',
            p_value2   => v_dim_name1);

         FEM_ENGINES_PKG.User_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_002',
            p_token1   => 'DIMENSION_NAME1',
            p_value1   => v_dim_name1,
            p_token2   => 'DIMENSION_NAME2',
            p_value2   => v_dim_name1);

      WHEN Invalid_Dataset_Code THEN
      ------------------------------------------------------------------
      -- Invalid Dataset parameter: Value not found or Dataset
      -- attributes not set.
      ------------------------------------------------------------------

         v_dim_name1 := FEM_DIMENSION_UTIL_PKG.Get_Dimension_Name
                           (p_dim_id => pv_dataset_dim_id);

         IF v_dim_name1 IS NULL THEN
            v_dim_name1 := 'Dataset';
         END IF;

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_error,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          pv_proc_name || '.invalid_dataset_code',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_002',
            p_token1   => 'DIMENSION_NAME1',
            p_value1   => v_dim_name1,
            p_token2   => 'DIMENSION_NAME2',
            p_value2   => v_dim_name1);

         FEM_ENGINES_PKG.User_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_002',
            p_token1   => 'DIMENSION_NAME1',
            p_value1   => v_dim_name1,
            p_token2   => 'DIMENSION_NAME2',
            p_value2   => v_dim_name1);

      WHEN Warn_DS_Bal_Type THEN
      ------------------------------------------------------------------
      -- Warning for Dataset parameter: DS_BAL_TYPE_NAME data has already
      -- been loaded into Dataset PRECEDENT_DATASET_NAME for this Ledger and
      -- Calendar Period.  All DS_BAL_TYPE_NAME data for this Ledger and
      -- Calendar Period should be loaded into the same Dataset, or you may
      -- have double-counting in the Balances table.
      ------------------------------------------------------------------

         BEGIN
            SELECT dataset_name
            INTO v_precedent_dataset_name
            FROM fem_datasets_vl
            WHERE dataset_code = pv_precedent_dataset_code;
         EXCEPTION
            WHEN OTHERS THEN
               v_precedent_dataset_name := TO_CHAR(pv_precedent_dataset_code);
         END;

         BEGIN
            SELECT ds_balance_type_name
            INTO v_ds_balance_type_name
            FROM fem_ds_balance_types_vl
            WHERE ds_balance_type_code = pv_ds_balance_type_cd;
         EXCEPTION
            WHEN OTHERS THEN
               v_ds_balance_type_name := pv_ds_balance_type_cd;
         END;

         IF pv_ds_balance_type_cd = 'ACTUAL' THEN

            v_ds_balance_type_string := v_ds_balance_type_name;

         ELSIF pv_ds_balance_type_cd = 'BUDGET' THEN

            BEGIN
               SELECT budget_name
               INTO v_budget_name
               FROM fem_budgets_vl
               WHERE budget_id = pv_budget_id;
            EXCEPTION
               WHEN OTHERS THEN
                  v_budget_name := TO_CHAR(pv_budget_id);
            END;

            v_ds_balance_type_string := v_ds_balance_type_name || ' ' || v_budget_name;

         ELSIF pv_ds_balance_type_cd = 'ENCUMBRANCE' THEN

            BEGIN
               SELECT encumbrance_type_name
               INTO v_enc_type_name
               FROM fem_encumbrance_types_vl
               WHERE encumbrance_type_id = pv_enc_type_id;
            EXCEPTION
               WHEN OTHERS THEN
                  v_enc_type_name := TO_CHAR(pv_enc_type_id);
            END;

            v_ds_balance_type_string := v_ds_balance_type_name || ' ' || v_enc_type_name;

         END IF;

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_error,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          pv_proc_name || '.invalid_dataset_code',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_026',
            p_token1   => 'DS_BAL_TYPE_NAME',
            p_value1   => v_ds_balance_type_string,
            p_token2   => 'PRECEDENT_DATASET_NAME',
            p_value2   => v_precedent_dataset_name);

         FEM_ENGINES_PKG.User_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_026',
            p_token1   => 'DS_BAL_TYPE_NAME',
            p_value1   => v_ds_balance_type_string,
            p_token2   => 'PRECEDENT_DATASET_NAME',
            p_value2   => v_precedent_dataset_name);

          x_completion_code := 1;

      WHEN Invalid_Enc_Type_ID THEN
      ------------------------------------------------------------------
      -- Invalid Encumbrance Type parameter: Value not found.
      ------------------------------------------------------------------

         v_dim_name1 := FEM_DIMENSION_UTIL_PKG.Get_Dimension_Name
                           (p_dim_id => pv_enc_type_dim_id);

         IF v_dim_name1 IS NULL THEN
            v_dim_name1 := 'Encumbrance Type';
         END IF;

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_error,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          pv_proc_name || '.invalid_enc_type_id',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_001',
            p_token1   => 'DIMENSION_NAME',
            p_value1   => v_dim_name1);

         FEM_ENGINES_PKG.User_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_001',
            p_token1   => 'DIMENSION_NAME',
            p_value1   => v_dim_name1);

      WHEN Invalid_Enc_or_Dataset THEN
      ------------------------------------------------------------------
      -- Invalid Encumbrance Type or Dataset parameter: Encumbrance Type
      -- does not match Dataset attribute "Dataset Encumbrance Type ID".
      ------------------------------------------------------------------

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_error,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          pv_proc_name || '.invalid_enc_or_dataset',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_009');

         FEM_ENGINES_PKG.User_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_009');

      WHEN Invalid_Execution_Mode THEN
      ------------------------------------------------------------------
      -- Invalid Execution Mode.  Valid values are 'S' (Snapshot), 'I'
      -- (Incremental), and 'E' (Error Reprocessing Only).
      ------------------------------------------------------------------

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => fnd_log.level_error,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          pv_proc_name || '.invalid_exec_mode',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_014');

         FEM_ENGINES_PKG.Put_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_014');

      WHEN Invalid_Ledger_ID THEN
      ------------------------------------------------------------------
      -- Invalid Ledger parameter: Value not found or Ledger attributes
      -- not set.
      ------------------------------------------------------------------

         -- FEM-OGL Intg: It should pass the ledger dim id instead of ledger id
       --               so replaced pv_ledger_id to pv_ledger_dim_id
         v_dim_name1 := FEM_DIMENSION_UTIL_PKG.Get_Dimension_Name
                           (p_dim_id => pv_ledger_dim_id);

         IF v_dim_name1 IS NULL THEN
            v_dim_name1 := 'Ledger';
         END IF;

         IF pv_attr_label IS NULL THEN

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_error,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             pv_proc_name || '.invalid_ledger_id',
               p_app_name => 'FEM',
               p_msg_name => 'FEM_GL_POST_001',
               p_token1   => 'DIMENSION_NAME',
               p_value1   => v_dim_name1);

            FEM_ENGINES_PKG.User_Message
              (p_app_name => 'FEM',
               p_msg_name => 'FEM_GL_POST_001',
               p_token1   => 'DIMENSION_NAME',
               p_value1   => v_dim_name1);

         ELSE

            v_attr_name := FEM_DIMENSION_UTIL_PKG.Get_Dim_Attr_Name
                              (p_dim_id     => pv_ledger_dim_id,
                               p_attr_label => pv_attr_label);

            IF v_attr_name IS NULL THEN
               v_attr_name := pv_attr_label;
            END IF;

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_error,
               p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                             pv_proc_name || '.invalid_ledger_id',
               p_app_name => 'FEM',
               p_msg_name => 'FEM_GL_POST_003',
               p_token1   => 'DIMENSION_NAME1',
               p_value1   => v_dim_name1,
               p_token2   => 'DIMENSION_NAME2',
               p_value2   => v_dim_name1,
               p_token3   => 'ATTRIBUTE_NAME',
               p_value3   => v_attr_name);

            FEM_ENGINES_PKG.User_Message
              (p_app_name => 'FEM',
               p_msg_name => 'FEM_GL_POST_003',
               p_token1   => 'DIMENSION_NAME1',
               p_value1   => v_dim_name1,
               p_token2   => 'DIMENSION_NAME2',
               p_value2   => v_dim_name1,
               p_token3   => 'ATTRIBUTE_NAME',
               p_value3   => v_attr_name);

         END IF;

      WHEN Invalid_Obj_Approval_Status THEN
      ------------------------------------------------------------------
      -- Cannot process a "production" Dataset using an Object
      -- Definition that is not in "approved" status.
      ------------------------------------------------------------------

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_error,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          pv_proc_name || '.invalid_obj_approval_status',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_005');

         FEM_ENGINES_PKG.User_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_005');

      WHEN Invalid_Object_ID THEN
      ------------------------------------------------------------------
      -- Invalid External GL Integration Rule:  Value not found or rule
      -- has the wrong Object Type.
      ------------------------------------------------------------------

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_error,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          pv_proc_name || '.invalid_object_def_id',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_010');

         FEM_ENGINES_PKG.User_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_010');

      WHEN Invalid_Object_Def_ID THEN
      ------------------------------------------------------------------
      -- Invalid Object Definition ID parameter: Value not found.
      ------------------------------------------------------------------

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_error,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          pv_proc_name || '.invalid_object_def_id',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_001',
            p_token1   => 'DIMENSION_NAME',
            p_value1   => 'FEM_OBJECT_DEF_ID_TXT',
            p_trans1   => 'Y');

         FEM_ENGINES_PKG.User_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_001',
            p_token1   => 'DIMENSION_NAME',
            p_value1   => 'FEM_OBJECT_DEF_ID_TXT',
            p_trans1   => 'Y');

      WHEN Ledger_Cal_NEQ_Period_Cal THEN
      ------------------------------------------------------------------
      -- Invalid Ledger or Calendar Period parameter:
      -- The Calendar assigned to the Ledger does not match
      -- the Calendar assigned to the Calendar Period.
      ------------------------------------------------------------------

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_error,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          pv_proc_name || '.ledger_cal_neq_period_cal',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_006');

         FEM_ENGINES_PKG.User_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_006');

      WHEN User_Not_Allowed THEN
      ------------------------------------------------------------------
      -- The current user is not allowed to execute this rule.  The
      -- user must have access to the folder containing the rule.
      ------------------------------------------------------------------

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_error,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          pv_proc_name || '.user_not_allowed',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_011');

         FEM_ENGINES_PKG.User_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_011');

      WHEN OTHERS THEN
      ------------------------------------------------------------------
      -- Unexpected exceptions
      ------------------------------------------------------------------
         IF pv_proc_name = 'validate_engine_parameters' THEN

            pv_sqlerrm   := SQLERRM;
            pv_callstack := dbms_utility.format_call_stack;

         END IF;

      -- Log the call stack and the Oracle error message to
      -- FND_LOG with the "unexpected exception" severity level.

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          pv_proc_name || '.unexpected_exception',
            p_msg_text => pv_sqlerrm);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.fem_gl_post_process_pkg.' ||
                          pv_proc_name || '.unexpected_exception',
            p_msg_text => pv_callstack);

      -- Log the Oracle error message to the Concurrent Request Log.

         FEM_ENGINES_PKG.User_Message
           (p_app_name => 'FEM',
            p_msg_text => pv_sqlerrm);

   END Validate_Engine_Parameters;
-- =======================================================================

-- =======================================================================
  PROCEDURE Validate_OGL_Eng_Parameters
                (p_bal_rule_obj_def_id     IN            NUMBER,
                 p_from_period             IN            VARCHAR2,
                 p_to_period               IN            VARCHAR2,
                 p_effective_date          IN OUT NOCOPY DATE,
                 p_bsv_range_low           IN            VARCHAR2,
                 p_bsv_range_high          IN            VARCHAR2,
                 x_generate_report_flag    OUT    NOCOPY VARCHAR2,
                 x_completion_code         OUT    NOCOPY NUMBER) IS
-- =======================================================================
-- Purpose
--    Validate the input parameters and perform initialization for FEM-OGL
--    Integration Balances Rule Engine
-- History
--    11-16-04  L Poon  Created
--    02-07-05  L Poon  Bug fix 4170124: Added codes to populate the new
--                      error Other_DS_Loaded for Actual balance type
--    05-27-05  Hari    Bug fix 4294018 : Added code to check whether both
--                      FEM: Signage Methodology Profile option value and
--                      the SIGN attribute for the dimension
--                      EXTENDED_ACCOUNT_TYPE is set.
--    06-22-05  Hari    Bug 4394404 - Modified code so that the periods are
--                      validated differently for Budget and Encumbrance
--                      Balances Rules.
-- Arguments
--    All of the IN arguments are the same as the IN arguments for the
--    FEM_INTG_BAL_RULE_ENG_PKG.Main procedure.
--
--    x_generate_report_flag   Returns 'Y' after updating the error code
--                             of FEM_INTG_EXEC_PARARMS_GT i.e. indicating
--                             report should be generated when erroring out
--                             after this point
--    x_completion_code        Returns 0 for success, 1 for warning, 2 for
--                             failure.
-- Notes
--    Called from the beginning of FEM_INTG_BAL_RULE_ENG_PKG.Main
-- =======================================================================

    v_module     VARCHAR2(100);
    v_func_name  VARCHAR2(80);
    v_dummy_flag VARCHAR2(1);
    v_count      NUMBER;
    v_signage_method VARCHAR2(50);

    v_dim_name   fem_dimensions_tl.dimension_name%TYPE;
    v_attr_name  fem_dim_attributes_tl.attribute_name%TYPE;


    OGLEngParam_FatalErr EXCEPTION;

  BEGIN
    v_module    := 'fem.plsql.fem_gl_post_process_pkg.validate_ogl_eng_parameters';
    v_func_name := 'FEM_GL_POST_PROCESS_PKG.Validate_OGL_Eng_Parameters';

    -- Log the function entry time to FND_LOG
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_201',
       p_token1   => 'FUNC_NAME',
       p_value1   => v_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    -- -----------------------
    -- 1. Initialize variables
    -- -----------------------
    pv_num_rows        := 0;
    pv_proc_name      := 'validate_ogl_eng_parameters';
    pv_attr_label     := NULL;
    v_count           := 0;
    -- Bug 4394404 hkaniven start - package variable to store the no of valid rows
    pv_num_rows_valid := 0;
    -- Bug 4394404 hkaniven end - package variable to store the no of valid rows

    -- Set Request ID and then print its value to FND_LOG
    pv_req_id := FND_GLOBAL.Conc_Request_Id;
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_req_id',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_req_id));

    -- Set User ID and then print its value to FND_LOG
    pv_user_id := FND_GLOBAL.User_Id;
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
      p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_user_id',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_user_id));

    -- Set Login ID and then print its value to FND_LOG
    pv_login_id := FND_GLOBAL.Login_Id;
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_login_id',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_login_id));

    -- Set Concurrent Program ID and then print its value to FND_LOG
    pv_pgm_id := FND_GLOBAL.Conc_Program_Id;
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_pgm_id',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_pgm_id));

    -- Set Program Application ID and then print its value to FND_LOG
    pv_pgm_app_id := FND_GLOBAL.Prog_Appl_ID;
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_pgm_app_id',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_pgm_app_id));

    -- Read the Signage profile option
    FND_PROFILE.GET('FEM_SIGNAGE_METHOD', v_signage_method);

    -- Bug 4294018 - hkaniven start - If Signage Methodology is not set,
    -- then error out
    IF (v_signage_method IS NULL)
    THEN
      -- Print the error message to FND_LOG and concurrent program log
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_event,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_SIGN_PROF_NOT_SET');
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_SIGN_PROF_NOT_SET');

      RAISE OGLEngParam_FatalErr;
    END IF;
    -- Bug 4294018 - hkaniven end - If Signage Methodology is not set,
    -- then error out

    -- Bug 4294018 hkaniven start - Count the no of 'SIGN' attribute rows
    SELECT COUNT(*)
    INTO v_count
    FROM fem_dimensions_b fdb,
         fem_dim_attributes_b fdab,
         fem_dim_attr_versions_b fdavb,
         fem_ext_acct_types_attr feata
    WHERE fdb.dimension_varchar_label = 'EXTENDED_ACCOUNT_TYPE'
    AND   fdab.attribute_varchar_label = 'SIGN'
    AND   fdb.dimension_id = fdab.dimension_id
    AND   fdab.attribute_id = fdavb.attribute_id
    AND   fdavb.default_version_flag = 'Y'
    AND   fdab.attribute_id = feata.attribute_id
    AND   fdavb.version_id =  feata.version_id;
    -- Bug 4294018 hkaniven end - Count the no of 'SIGN' attribute rows

    -- Bug 4294018 hkaniven start - If no 'SIGN' attribute rows then error out
    IF v_count = 0 THEN
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_event,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_SIGN_CP_NOT_RUN');
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_SIGN_CP_NOT_RUN');

      RAISE OGLEngParam_FatalErr;
    END IF;
    -- Bug 4294018 hkaniven end - If no 'SIGN' attribute rows then error out

    -- Log the signage method value
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'v_signage_method',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(v_signage_method));

    -- Set Advanced Line Item and Financial Element Mappings Flag and then
    -- print its value to FND_LOG
    FND_PROFILE.GET('FEM_GL_ADV_MAPPING_FLAG', pv_adv_li_fe_mappings_flag);

    -- If it is not set, default it as 'N'
    IF (pv_adv_li_fe_mappings_flag IS NULL)
    THEN
      -- Print the warning message to FND_LOG and concurrent program log
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_event,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_DEFAULT_ADV_MAP');
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_DEFAULT_ADV_MAP');
      -- Default it to No
      pv_adv_li_fe_mappings_flag := 'N';
    END IF;

    -- Log the advanced mapping flag value
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_adv_li_fe_mappings_flag',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_adv_li_fe_mappings_flag));

    -- Find the OGL Source System Code
    SELECT SOURCE_SYSTEM_CODE
    INTO pv_gl_source_system_code
    FROM FEM_SOURCE_SYSTEMS_B
    WHERE SOURCE_SYSTEM_DISPLAY_CODE = 'OGL';

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_gl_source_system_code',
       p_token2   => 'VAR_VAL',
       p_value2   => pv_gl_source_system_code);

    -- -------------------------------------------------------
    -- 2. Retrieve and validate the Balances Rule and Rule Def
    -- -------------------------------------------------------
   BEGIN
      SELECT balRDef.BAL_RULE_OBJ_DEF_ID
           , objDefT.DISPLAY_NAME
           , balRule.BAL_RULE_OBJ_ID
           , balRule.LEDGER_ID
           , lgr.NAME
           , balRule.CHART_OF_ACCOUNTS_ID
           , flex.ID_FLEX_STRUCTURE_NAME
           , balRule.BAL_SEG_COLUMN_NAME
           , balRule.DS_BAL_TYPE_CODE
           , balRule.INCLUDE_AVG_BAL_FLAG
           , balRule.MAINTAIN_QTD_FLAG
           , DECODE(balRDef.LOAD_METHOD_CODE
            , 'SNAPSHOT', 'S'
            , 'INCREMENTAL', 'I')
           , balRDef.BAL_SEG_VALUE_OPTION_CODE
           , balRDef.CURRENCY_OPTION_CODE
           , balRDef.XLATED_BAL_OPTION_CODE
           , balRDef.ACTUAL_OUTPUT_DATASET_CODE
           , objDef.EFFECTIVE_START_DATE
           , objDef.EFFECTIVE_END_DATE
      INTO   pv_rule_obj_def_id
           , pv_rule_obj_def_name
           , pv_rule_obj_id
           , pv_ledger_id
           , pv_ledger_name
           , pv_coa_id
           , pv_coa_name
           , pv_bsv_app_col_name
           , pv_ds_balance_type_cd
           , pv_include_avg_bal
           , pv_maintain_qtd_flag
           , pv_exec_mode
           , pv_bsv_option
           , pv_curr_option
           , pv_xlated_bal_option
           , pv_dataset_code
           , pv_rule_eff_start_date
           , pv_rule_eff_end_date
      FROM   FEM_INTG_BAL_RULES balRule
           , FEM_INTG_BAL_RULE_DEFS balRDef
           , FEM_OBJECT_DEFINITION_B objDef
           , FEM_OBJECT_DEFINITION_TL objDefT
           , FND_ID_FLEX_STRUCTURES_TL flex
           , GL_LEDGERS lgr
      WHERE balRule.BAL_RULE_OBJ_ID = objDef.OBJECT_ID
      AND objDef.OBJECT_DEFINITION_ID = balRDef.BAL_RULE_OBJ_DEF_ID
      AND objDefT.OBJECT_DEFINITION_ID = objDef.OBJECT_DEFINITION_ID
      AND objDefT.LANGUAGE = USERENV('LANG')
      AND balRDef.BAL_RULE_OBJ_DEF_ID = p_bal_rule_obj_def_id
     AND flex.APPLICATION_ID = 101
     AND flex.ID_FLEX_CODE = 'GL#'
     AND flex.ID_FLEX_NUM = balRule.CHART_OF_ACCOUNTS_ID
      AND flex.LANGUAGE = USERENV('LANG')
     AND lgr.LEDGER_ID = balRule.LEDGER_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- The balances rule object definition is not found
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement,
           p_module   => v_module,
          p_msg_text => 'Raising Invalid_Object_Def_ID exception');
      RAISE Invalid_Object_Def_ID;
   END;

    -- List out the balances rule setup to FND_LOG
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_rule_obj_def_id',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_rule_obj_def_id));
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_rule_obj_def_name',
       p_token2   => 'VAR_VAL',
       p_value2   => pv_rule_obj_def_name);
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_rule_obj_id',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_rule_obj_id));
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_ledger_id',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_ledger_id));
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_ledger_name',
       p_token2   => 'VAR_VAL',
       p_value2   => pv_ledger_name);
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_coa_id',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_coa_id));
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_coa_name',
       p_token2   => 'VAR_VAL',
       p_value2   => pv_coa_name);
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_bsv_app_col_name',
       p_token2   => 'VAR_VAL',
       p_value2   => pv_bsv_app_col_name);
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_ds_balance_type_cd',
       p_token2   => 'VAR_VAL',
       p_value2   => pv_ds_balance_type_cd);
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_include_avg_bal',
       p_token2   => 'VAR_VAL',
       p_value2   => pv_include_avg_bal);
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_maintain_qtd_flag',
       p_token2   => 'VAR_VAL',
       p_value2   => pv_maintain_qtd_flag);
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_exec_mode',
       p_token2   => 'VAR_VAL',
       p_value2   => pv_exec_mode);
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_bsv_option',
       p_token2   => 'VAR_VAL',
       p_value2   => pv_bsv_option);
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_curr_option',
       p_token2   => 'VAR_VAL',
       p_value2   => pv_curr_option);
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_xlated_bal_option',
       p_token2   => 'VAR_VAL',
       p_value2   => pv_xlated_bal_option);
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_dataset_code',
       p_token2   => 'VAR_VAL',
       p_value2   => pv_dataset_code);
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_rule_eff_start_date',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_rule_eff_start_date, 'DD-MON-YYYY'));
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_rule_eff_end_date',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_rule_eff_end_date, 'DD-MON-YYYY'));

    -- Validate the p_bal_rule_obj_def_id engine parameter
    Validate_Object_Def_ID;

    IF pv_obj_type_cd <> 'OGL_INTG_BAL_RULE'
    THEN
      -- It is not a FEM-OGL Integration Balances Rule
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_exception,
         p_module   => v_module,
         p_msg_text => 'Raising Invalid_Object_ID exception');

      RAISE Invalid_Object_ID;
    END IF; -- IF pv_obj_type_cd <> 'OGL_INTG_BAL_RULE'

    -- ----------------------
    -- 3. Validate the Ledger
    -- ----------------------

    -- Verify the ledger is assigned in the source ledger group
    BEGIN
      -- Bug fix 4214383: Changed the SQL to uptake new SLG implmentation
      SELECT 'Y'
      INTO v_dummy_flag
      FROM FEM_LEDGERS_HIER h
         , FEM_LEDGERS_B p
      WHERE h.HIERARCHY_OBJ_DEF_ID = 1505
      AND h.CHILD_ID = pv_ledger_id
      AND h.PARENT_ID = p.LEDGER_ID
      AND p.LEDGER_DISPLAY_CODE = 'OGL_SOURCE_LEDGER_GROUP';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- The Ledger is not assigned to the source ledger group
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_error,
           p_module   => v_module,
           p_app_name => 'FEM',
           p_msg_name => 'FEM_INTG_BAL_LG_NOT_IN_SRC',
           p_token1   => 'LEDGER_NAME',
           p_value1   => pv_ledger_name);

        FEM_ENGINES_PKG.User_Message
          (p_app_name => 'FEM',
           p_msg_name => 'FEM_INTG_BAL_LG_NOT_IN_SRC',
           p_token1   => 'LEDGER_NAME',
           p_value1   => pv_ledger_name);

      RAISE OGLEngParam_FatalErr;
    END;

    -- Cache the dimension IDs
    Get_Dim_IDs;

    -- Validate the pv_ledger_id retrieved from the balance rule def and
    -- cache ledger attributes
    Validate_Ledger;

    -- Verify the Time Hierarchy Object ID and Time Hierarchy Object Def ID
    -- this Ledger
    IF (pv_ledger_per_hier_obj_def_id = -1 OR pv_ledger_per_hier_obj_id = -1)
    THEN
      -- The Time Hierarchy Object ID/Object Def ID is wrong
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_error,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_PER_HIER_ERR',
         p_token1   => 'LEDGER_NAME',
         p_value1   => pv_ledger_name);

      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_PER_HIER_ERR',
         p_token1   => 'LEDGER_NAME',
         p_value1   => pv_ledger_name);

      RAISE OGLEngParam_FatalErr;
    END IF;

   -- Verify all Value-Set-Required dimensions are defined in the Global
   -- Value Set Combination
   BEGIN
      SELECT DISTINCT 'X'
      INTO v_dummy_flag
      FROM FEM_XDIM_DIMENSIONS xdim, FEM_DIMENSIONS_B dim
      WHERE xdim.VALUE_SET_REQUIRED_FLAG = 'Y'
      AND xdim.DIMENSION_ID = dim.DIMENSION_ID
      AND dim.DIMENSION_VARCHAR_LABEL
           NOT IN ('COMPANY', 'COST_CENTER') -- Bug fix 4158130
      AND NOT EXISTS
       (SELECT 'X'
        FROM FEM_GLOBAL_VS_COMBO_DEFS gvsc
        WHERE gvsc.DIMENSION_ID = dim.DIMENSION_ID
        AND gvsc.GLOBAL_VS_COMBO_ID = pv_global_vs_combo_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- No missing value-set-required dimensions
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement,
           p_module   => v_module,
           p_msg_text => 'All Value-Set-Required dimensions are defined in the GVSC');
    END;

    IF (v_dummy_flag = 'X')
    THEN
      -- Incomplete the Global Value Set Comboination setup
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_error,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_GVSC_ERR',
         p_token1   => 'COA_NAME',
         p_value1   => pv_coa_name);

      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_GVSC_ERR',
         p_token1   => 'COA_NAME',
         p_value1   => pv_coa_name);

      Raise OGLEngParam_FatalErr;
    END IF; -- IF (v_dummy_flag = 'X')

    -- Bug fix 4242130: Validate the dimension rules for non-processing key
   -- dimensions should have SINGLEVAL option
   BEGIN
     SELECT DISTINCT 'X'
     INTO v_dummy_flag
     FROM   fem_intg_dim_rules r
           , fem_intg_dim_rule_defs rd
           , fem_object_definition_b od
      WHERE r.dim_rule_obj_id = od.object_id
      AND rd.dim_rule_obj_def_id = od.object_definition_id
      AND rd.dim_mapping_option_code <> 'SINGLEVAL'
      AND r.dimension_id <> 0
      AND r.dimension_id NOT IN
           (SELECT tc.dimension_id
              FROM fem_tab_column_prop tcp
                 , fem_tab_columns_b tc
             WHERE tcp.table_name = 'FEM_BALANCES'
               AND tcp.column_property_code = 'PROCESSING_KEY'
               AND tc.table_name = 'FEM_BALANCES'
               AND tc.column_name = tcp.column_name)
      AND r.chart_of_accounts_id = pv_coa_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- All non-processing key dimensions have SINGLEVAL dim rule versions
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement,
           p_module   => v_module,
           p_msg_text => 'All non-processing key dimensions have SINGLEVAL dimension rule versions');
   END;

    IF (v_dummy_flag = 'X')
    THEN
      -- Invalid dimension rule setup for this COA
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_error,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_DIM_RULE_ERR',
         p_token1   => 'COA_NAME',
         p_value1   => pv_coa_name);

      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_DIM_RULE_ERR',
         p_token1   => 'COA_NAME',
         p_value1   => pv_coa_name);

      Raise OGLEngParam_FatalErr;
    END IF;

    -- ----------------------------
    -- 4. Validate the Period Range
    -- ----------------------------

    -- Check the From Period is a valid OGL period for the Ledger by getting
    -- its end date and period effective number
    -- Bug fix 4332989: Changed to get the end date of From Period to validate
    --                  the effective period range
    BEGIN
      SELECT per.END_DATE
           , per.EFFECTIVE_PERIOD_NUM
      INTO   pv_from_date
           , pv_from_period_eff_num
      FROM   GL_PERIOD_STATUSES per
      WHERE per.APPLICATION_ID = 101
      AND per.LEDGER_ID = pv_ledger_id
      AND per.PERIOD_NAME = p_from_period;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- The From Period is not a valid OGL period
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_error,
           p_module   => v_module,
           p_app_name => 'FEM',
           p_msg_name => 'FEM_GL_POST_001',
           p_token1   => 'DIMENSION_NAME',
           p_value1   => 'FEM_FROM_PERIOD_TXT',
           p_trans1   => 'Y');
        FEM_ENGINES_PKG.User_Message
          (p_app_name => 'FEM',
           p_msg_name => 'FEM_GL_POST_001',
           p_token1   => 'DIMENSION_NAME',
           p_value1   => 'FEM_FROM_PERIOD_TXT',
           p_trans1   => 'Y');

        Raise OGLEngParam_FatalErr;
    END;

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_from_date',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_from_date, 'DD-MON-YYYY'));

    -- Check the To Period is a valid OGL period for the Ledger by getting
   -- its start date and period effective number
    BEGIN
      SELECT per.END_DATE
           , per.EFFECTIVE_PERIOD_NUM
           , (SELECT 'Y' FROM DUAL
              WHERE NVL(p_effective_date, per.END_DATE) BETWEEN per.START_DATE
                                                        AND per.END_DATE)
      INTO   pv_to_date
           , pv_to_period_eff_num
           , v_dummy_flag
      FROM   GL_PERIOD_STATUSES per
      WHERE per.APPLICATION_ID = 101
      AND per.LEDGER_ID = pv_ledger_id
      AND per.PERIOD_NAME = p_to_period;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- The To Period is not a valid OGL period
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_error,
           p_module   => v_module,
           p_app_name => 'FEM',
           p_msg_name => 'FEM_GL_POST_001',
           p_token1   => 'DIMENSION_NAME',
           p_value1   => 'FEM_TO_PERIOD_TXT',
           p_trans1   => 'Y');
        FEM_ENGINES_PKG.User_Message
          (p_app_name => 'FEM',
           p_msg_name => 'FEM_GL_POST_001',
           p_token1   => 'DIMENSION_NAME',
           p_value1   => 'FEM_TO_PERIOD_TXT',
           p_trans1   => 'Y');

        Raise OGLEngParam_FatalErr;
    END;

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_to_date',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_to_date, 'DD-MON-YYYY'));

    -- Validate the From Period must be earlier than or same as To Period
    IF (pv_from_period_eff_num > pv_to_period_eff_num)
    THEN
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_error,
           p_module   => v_module,
           p_app_name => 'FEM',
           p_msg_name => 'FEM_INTG_BAL_PER_RANGE_ERR',
           p_token1   => 'FROM_PERIOD',
           p_value1   => p_from_period,
           p_token2   => 'TO_PERIOD',
           p_value2   => p_to_period);
        FEM_ENGINES_PKG.User_Message
          (p_app_name => 'FEM',
           p_msg_name => 'FEM_INTG_BAL_PER_RANGE_ERR',
           p_token1   => 'FROM_PERIOD',
           p_value1   => p_from_period,
           p_token2   => 'TO_PERIOD',
           p_value2   => p_to_period);

        Raise OGLEngParam_FatalErr;
    END IF; -- IF (pv_from_period_eff_num > pv_to_period_eff_num)

    -- Validate the pass period range must be within the balance rule effective
    -- date range
    IF (pv_from_date < pv_rule_eff_start_date
       OR pv_to_date > pv_rule_eff_end_date)
    THEN
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_error,
           p_module   => v_module,
           p_app_name => 'FEM',
           p_msg_name => 'FEM_INTG_BAL_RULE_NOT_EFF');
        FEM_ENGINES_PKG.User_Message
          (p_app_name => 'FEM',
           p_msg_name => 'FEM_INTG_BAL_RULE_NOT_EFF');

        Raise OGLEngParam_FatalErr;
    END IF; -- IF (pv_from_date < pv_rule_eff_start_date ...

    -- Check the As-Of-Date parameter if Include Average Balance Flag is Yes
    IF ((pv_include_avg_bal = 'Y')
       AND (p_effective_date IS NULL OR v_dummy_flag IS NULL))
    THEN
      -- If the As-Of-Date parameter is not provided or it is not within the To
     -- Period, we set it as the end date of the To Period
      p_effective_date := pv_to_date;

     -- Log a warning message to FND_LOG as well as the concurrent request log
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_event,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_EFF_DATE_WARN');
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_EFF_DATE_WARN');
    END IF; -- IF (pv_include_avg_bal = 'Y' ...

    -- ------------------------------------------------------------
    -- 4.5. Validate the BSV's
    -- ------------------------------------------------------------
    IF (p_bsv_range_low IS NOT NULL AND p_bsv_range_high IS NULL) OR
       (p_bsv_range_low IS NULL AND p_bsv_range_high IS NOT NULL) THEN

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_event,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BSV_ONE_NULL');
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BSV_ONE_NULL');

      Raise OGLEngParam_FatalErr;
    END IF;

    -- Start bug fix 5520680
    -- ------------------------------------------------------------
    -- we must ensure that no balances have been loaded
    -- for this Ledger/Output Dataset/Cal Period
    -- since snapshot mode is execution-once-only rules
    -- ------------------------------------------------------------
    IF (pv_exec_mode = 'S') THEN
        BEGIN

            SELECT 'Y'
              INTO v_dummy_flag
              FROM DUAL
             WHERE EXISTS
                    (SELECT 'Loaded'
                       FROM FEM_DL_DIMENSIONS
                      WHERE LEDGER_ID = pv_ledger_id
                        AND EXISTS (SELECT 1
                                      FROM GL_PERIOD_STATUSES per
                                     WHERE per.APPLICATION_ID = 101
                                       AND per.LEDGER_ID = pv_ledger_id
                                       AND FEM_DL_DIMENSIONS.CAL_PERIOD_ID =
                                                   FEM_DIMENSION_UTIL_PKG.Get_Cal_Period_ID(  pv_ledger_id
                                                                                              , 'OGL_'||per.PERIOD_TYPE
                                                                                              , per.PERIOD_NUM
                                                                                              , per.PERIOD_YEAR)
                                       AND per.EFFECTIVE_PERIOD_NUM BETWEEN pv_from_period_eff_num
                                                                    AND pv_to_period_eff_num)
                        AND DATASET_CODE = pv_dataset_code
                        AND SOURCE_SYSTEM_CODE = pv_gl_source_system_code
                        AND TABLE_NAME = 'FEM_BALANCES');

             EXCEPTION
                  WHEN NO_DATA_FOUND THEN NULL;

         END;

         IF (v_dummy_flag = 'Y') THEN

             FEM_ENGINES_PKG.Tech_Message
               (p_severity => pc_log_level_event,
                p_module   => v_module,
                p_app_name => 'FEM',
                p_msg_name => 'FEM_INTG_SNAPSHOT_LOAD_ERR');
             FEM_ENGINES_PKG.User_Message
               (p_app_name => 'FEM',
                p_msg_name => 'FEM_INTG_SNAPSHOT_LOAD_ERR');

             Raise OGLEngParam_FatalErr;
        END IF;

    END IF;
    -- End bug fix 5520680

    -- ------------------------------------------------------------
    -- 5. Populate FEM_INTG_EXEC_PARAMS_GT base on the balance type
    -- ------------------------------------------------------------
    IF (pv_ds_balance_type_cd = 'ACTUAL')
    THEN
      INSERT INTO FEM_INTG_EXEC_PARAMS_GT
      (      OUTPUT_DATASET_CODE
           , EFFECTIVE_PERIOD_NUM
           , PERIOD_NAME
           , CAL_PERIOD_ID
           , LOAD_METHOD_CODE
           , ERROR_CODE
           , NUM_OF_ROWS_SELECTED
           , NUM_OF_ROWS_POSTED
      )
      SELECT pv_dataset_code
           , per.EFFECTIVE_PERIOD_NUM
           , per.PERIOD_NAME
           , FEM_DIMENSION_UTIL_PKG.Get_Cal_Period_ID(  pv_ledger_id
                                                      , 'OGL_'||per.PERIOD_TYPE
                                                      , per.PERIOD_NUM
                                                      , per.PERIOD_YEAR)
           , pv_exec_mode
           , DECODE(per.CLOSING_STATUS
              , 'C', NULL
              , 'O', NULL
              , 'P', NULL
                   , 'INVALID_PERIOD_STATUS')
           , 0
           , 0
      FROM   GL_PERIOD_STATUSES per
      WHERE per.APPLICATION_ID = 101
      AND per.LEDGER_ID = pv_ledger_id
      AND per.EFFECTIVE_PERIOD_NUM BETWEEN pv_from_period_eff_num
                                       AND pv_to_period_eff_num;

    ELSIF (pv_ds_balance_type_cd = 'BUDGET')
    THEN
      INSERT INTO FEM_INTG_EXEC_PARAMS_GT
      (      OUTPUT_DATASET_CODE
         , BUDGET_ID
           , EFFECTIVE_PERIOD_NUM
           , PERIOD_NAME
           , CAL_PERIOD_ID
           , LOAD_METHOD_CODE
           , ERROR_CODE
           , NUM_OF_ROWS_SELECTED
           , NUM_OF_ROWS_POSTED
      )
      SELECT bgetDS.OUTPUT_DATASET_CODE
           , bget.BUDGET_ID
           , per.EFFECTIVE_PERIOD_NUM
           , per.PERIOD_NAME
           , FEM_DIMENSION_UTIL_PKG.Get_Cal_Period_ID(  pv_ledger_id
                                                      , 'OGL_'||per.PERIOD_TYPE
                                                      , per.PERIOD_NUM
                                                      , per.PERIOD_YEAR)
           , pv_exec_mode
           -- Bug 4394404 hkaniven start - populate 'INVALID_PERIOD_STATUS' error
           -- code if period's period year greater than the latest opened period
           -- year of the Budget
           , DECODE(SIGN(gb.latest_opened_year - per.period_year)
                , -1, 'INVALID_PERIOD_STATUS'
                , NULL)
           -- Bug 4394404 hkaniven end - populate 'INVALID_PERIOD_STATUS' error
           -- code if period's period year greater than the latest opened period
           -- year of the Budget
           , 0
           , 0
      FROM   GL_PERIOD_STATUSES per
           , FEM_INTG_BAL_DEF_BUDGTS bget
           , FEM_INTG_BUDGT_DS bgetDS
           -- Bug 4394404 hkaniven start - to get the latest opened year of each
           -- budget
           , GL_BUDGETS gb
           , GL_BUDGET_VERSIONS gbv
           -- Bug 4394404 hkaniven end - to get the latest opened year of each
           -- budget
      WHERE per.APPLICATION_ID = 101
      AND per.LEDGER_ID = pv_ledger_id
      AND per.EFFECTIVE_PERIOD_NUM BETWEEN pv_from_period_eff_num
                                       AND pv_to_period_eff_num
      AND bget.BAL_RULE_OBJ_DEF_ID = pv_rule_obj_def_id
      AND bgetDS.BUDGET_ID = bget.BUDGET_ID
      -- Bug 4394404 hkaniven start - to get the latest opened year of each
      -- budget
      AND gbv.budget_version_id = bget.budget_id
      AND gb.budget_name = gbv.budget_name;
      -- Bug 4394404 hkaniven end - to get the latest opened year of each
      -- budget

    ELSE -- i.e. Encumbrance Types
      INSERT INTO FEM_INTG_EXEC_PARAMS_GT
      (      OUTPUT_DATASET_CODE
           , ENCUMBRANCE_TYPE_ID
           , EFFECTIVE_PERIOD_NUM
           , PERIOD_NAME
           , CAL_PERIOD_ID
           , LOAD_METHOD_CODE
           , ERROR_CODE
           , NUM_OF_ROWS_SELECTED
           , NUM_OF_ROWS_POSTED
      )
      SELECT encTypeDS.OUTPUT_DATASET_CODE
           , encType.ENCUMBRANCE_TYPE_ID
           , per.EFFECTIVE_PERIOD_NUM
           , per.PERIOD_NAME
           , FEM_DIMENSION_UTIL_PKG.Get_Cal_Period_ID(  pv_ledger_id
                                                      , 'OGL_'||per.PERIOD_TYPE
                                                      , per.PERIOD_NUM
                                                      , per.PERIOD_YEAR)
           , pv_exec_mode
           -- Bug 4394404 hkaniven start - populate 'INVALID_PERIOD_STATUS' error
           -- code if period's period year greater than the latest encumbrance year
           , DECODE(SIGN(glgr.latest_encumbrance_year - per.period_year)
               , -1, 'INVALID_PERIOD_STATUS'
               , NULL)
           -- Bug 4394404 hkaniven end - populate 'INVALID_PERIOD_STATUS' error
           -- code if period's period year greater than the latest encumbrance year
           , 0
           , 0
      FROM   GL_PERIOD_STATUSES per
           , FEM_INTG_BAL_DEF_ENCS encType
           , FEM_INTG_ENC_TYPE_DS encTypeDS
           -- Bug 4394404 hkaniven start - to get latest encumbrance year
           , GL_LEDGERS glgr
           -- Bug 4394404 hkaniven end - to get latest encumbrance year
      WHERE per.APPLICATION_ID = 101
      AND per.LEDGER_ID = pv_ledger_id
      AND per.EFFECTIVE_PERIOD_NUM BETWEEN pv_from_period_eff_num
                                       AND pv_to_period_eff_num
      AND encType.BAL_RULE_OBJ_DEF_ID = pv_rule_obj_def_id
      AND encTypeDS.ENCUMBRANCE_TYPE_ID = encType.ENCUMBRANCE_TYPE_ID
      -- Bug 4394404 hkaniven start - to get latest encumbrance year
      AND glgr.ledger_id = pv_ledger_id;
      -- Bug 4394404 hkaniven end - to get latest encumbrance year

    END IF; -- IF (pv_ds_balance_type_cd = 'ACTUAL')

    -- Get the number of rows inserted and log it to FND_LOG
    pv_num_rows := SQL%ROWCOUNT;
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_216',
       p_token1   => 'NUM',
       p_value1   => TO_CHAR(pv_num_rows),
       p_token2   => 'TABLE',
       p_value2   => 'FEM_INTG_EXEC_PARAMS_GT');

    IF (pv_num_rows = 0)
    THEN
      -- No rows are inserted. It can be invalid budget/encumbrance type setup.
      -- If it is Actual balance type, it's impossible for them to get 0 rows.
      IF (pv_ds_balance_type_cd = 'BUDGET')
      THEN
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_error,
           p_module   => v_module,
           p_app_name => 'FEM',
           p_msg_name => 'FEM_INTG_BAL_BGT_SETUP_ERR');
        FEM_ENGINES_PKG.User_Message
          (p_app_name => 'FEM',
           p_msg_name => 'FEM_INTG_BAL_BGT_SETUP_ERR');

      ELSE -- i.e. Encumbrance Type
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_error,
           p_module   => v_module,
           p_app_name => 'FEM',
           p_msg_name => 'FEM_INTG_BAL_ECT_SETUP_ERR');
        FEM_ENGINES_PKG.User_Message
          (p_app_name => 'FEM',
           p_msg_name => 'FEM_INTG_BAL_ECT_SETUP_ERR');

      END IF; -- IF (pv_ds_balance_type_cd = 'BUDGET')

      Raise OGLEngParam_FatalErr;
    END IF; -- IF (pv_num_rows = 0)

    -- For Actual Balance Type, if the balances should be loaded into the same
   -- dataset for the entire accounting year, populate the error code for those
   -- periods whose accounting year has been loaded into other datasets.
    IF (pv_ds_balance_type_cd = 'ACTUAL')
    THEN
      -- The error OTHER_DS_LOADED will override other errors codes
      UPDATE FEM_INTG_EXEC_PARAMS_GT gt
      SET ERROR_CODE = 'OTHER_DS_LOADED'
      WHERE EFFECTIVE_PERIOD_NUM IN
        (SELECT DISTINCT per.EFFECTIVE_PERIOD_NUM
           FROM FEM_DL_DIMENSIONS dl
              , FEM_CAL_PERIODS_ATTR year
              , FEM_DIM_ATTR_VERSIONS_B yearV
              , GL_PERIOD_STATUSES per
          WHERE dl.LEDGER_ID = pv_ledger_id
            AND dl.DATASET_CODE <> pv_dataset_code
            AND dl.SOURCE_SYSTEM_CODE = pv_gl_source_system_code
            AND dl.TABLE_NAME = 'FEM_BALANCES'
      -- Bug fix 4335649: Change to check ACTUAL balance type only
            AND dl.BALANCE_TYPE_CODE = 'ACTUAL'
            AND year.CAL_PERIOD_ID = dl.CAL_PERIOD_ID
            AND year.ATTRIBUTE_ID =
                 (SELECT ATTRIBUTE_ID
                    FROM FEM_DIM_ATTRIBUTES_B
                   WHERE ATTRIBUTE_VARCHAR_LABEL = 'ACCOUNTING_YEAR')
            AND year.ATTRIBUTE_ID = yearV.ATTRIBUTE_ID
            AND year.VERSION_ID = yearV.VERSION_ID
            AND yearV.DEFAULT_VERSION_FLAG = 'Y'
            AND year.NUMBER_ASSIGN_VALUE = per.PERIOD_YEAR
            AND per.APPLICATION_ID = 101
            AND per.LEDGER_ID = dl.LEDGER_ID
            AND per.EFFECTIVE_PERIOD_NUM BETWEEN pv_from_period_eff_num
                                             AND pv_to_period_eff_num);

      -- Log the number of rows updated in FEM_INTG_EXEC_PARAMS_GT
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_217',
         p_token1   => 'NUM',
         p_value1   => TO_CHAR(SQL%ROWCOUNT),
         p_token2   => 'TABLE',
         p_value2   => 'FEM_INTG_EXEC_PARAMS_GT');

    END IF; -- IF (pv_ds_balance_type_cd = 'ACTUAL')

    -- For peirods not mapped to the FEM Cal Periods, update their error codes
    UPDATE FEM_INTG_EXEC_PARAMS_GT
    SET ERROR_CODE = 'PERIOD_NOT_MAPPED'
    WHERE ERROR_CODE IS NULL
    AND CAL_PERIOD_ID = -1;

    -- Set the Generate Report Flag to 'Y' i.e. indicating report should be
    -- generated when erroring out after this point
    x_generate_report_flag := 'Y';

    -- Log the number of rows updated in FEM_INTG_EXEC_PARAMS_GT
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_217',
       p_token1   => 'NUM',
       p_value1   => TO_CHAR(SQL%ROWCOUNT),
       p_token2   => 'TABLE',
       p_value2   => 'FEM_INTG_EXEC_PARAMS_GT');

    -- Find the min and max valid period effective numbers
    SELECT NVL(min(EFFECTIVE_PERIOD_NUM), -1)
         , NVL(max(EFFECTIVE_PERIOD_NUM), -1)
    INTO   pv_min_valid_period_eff_num
         , pv_max_valid_period_eff_num
    FROM FEM_INTG_EXEC_PARAMS_GT
    WHERE ERROR_CODE IS NULL;

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_min_valid_period_eff_num',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_min_valid_period_eff_num));

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_max_valid_period_eff_num',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_max_valid_period_eff_num));

    -- Bug 4394404 hkaniven start - Get the no of valid rows in
    -- FEM_INTG_EXEC_PARAMS_GT if the Balance type is 'Budget'
    IF (pv_ds_balance_type_cd = 'BUDGET') THEN
        SELECT COUNT(*)
        INTO pv_num_rows_valid
        FROM FEM_INTG_EXEC_PARAMS_GT
        WHERE ERROR_CODE IS NULL;
    END IF;
    -- Bug 4394404 hkaniven end - Get the no of valid rows in
    -- FEM_INTG_EXEC_PARAMS_GT if the Balance type is 'Budget'

    -- Check if there are any valid periods for processing
    IF (pv_min_valid_period_eff_num = -1)
    THEN
      -- All periods are invalid, so errors out
      -- Bug fix 4170124: The message is changed and doesn't have any tockens.
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_error,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_NO_VALID_PER');
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_NO_VALID_PER');

      Raise OGLEngParam_FatalErr;

    ELSIF ((pv_min_valid_period_eff_num <> pv_from_period_eff_num
            OR pv_max_valid_period_eff_num <> pv_to_period_eff_num)

          -- Bug 4394404 hkaniven start - End the program with a warning
          -- if the Balance type is 'Budget' and if any of the rows in
          -- FEM_INTG_EXEC_PARAMS_GT is not valid
          OR
          (pv_ds_balance_type_cd = 'BUDGET'
            AND pv_num_rows <> pv_num_rows_valid))
          -- Bug 4394404 hkaniven end - End the program with a warning
          -- if the Balance type is 'Budget' and if any of the rows in
          -- FEM_INTG_EXEC_PARAMS_GT is not valid

    THEN
      -- At least one but not all peroid are invalid, so set the return code to
      -- 1 i.e. indicating warning
      x_completion_code := 1;

      -- Log a warning message to FND_LOG as well as the concurrent request log
      -- Bug fix 4170124: The message is changed and doesn't have any tockens.
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_exception,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_INVALID_PER');
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_INVALID_PER');

    END IF; -- IF (pv_min_valid_period_eff_num = -1)

    -- ---------------------------------
    -- 6. Cache the Maximum Delta Run ID
    -- ---------------------------------
    SELECT NVL(MAX(DELTA_RUN_ID), 0)
    INTO   pv_max_delta_run_id
    FROM   GL_BALANCES_DELTA;

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_max_delta_run_id',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(pv_max_delta_run_id));

    -- ----------------------------
    -- 7. Exit with success/warning
    -- ----------------------------

    -- Log the function exit time to FND_LOG (successful completion)
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => v_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

  EXCEPTION
    WHEN Invalid_Object_Def_ID THEN
      -- <<< Balances rule definition not found >>>
      x_completion_code := 2; -- Indicating fatal error

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_error,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' || pv_proc_name,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_001',
         p_token1   => 'DIMENSION_NAME',
         p_value1   => 'FEM_OBJECT_DEF_ID_TXT',
         p_trans1   => 'Y');
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_001',
         p_token1   => 'DIMENSION_NAME',
         p_value1   => 'FEM_OBJECT_DEF_ID_TXT',
         p_trans1   => 'Y');

      -- Log the function exit time to FND_LOG (with error)
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_203',
         p_token1   => 'FUNC_NAME',
         p_value1   => v_func_name,
         p_token2   => 'TIME',
         p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    WHEN Invalid_Object_ID THEN
      -- <<< Balances rule not found or wrong object type >>>
      x_completion_code := 2; -- Indicating fatal error

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_error,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' || pv_proc_name,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_INVALID_RULE');
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_INVALID_RULE');

      -- Log the function exit time to FND_LOG (with error)
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_203',
         p_token1   => 'FUNC_NAME',
         p_value1   => v_func_name,
         p_token2   => 'TIME',
         p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    WHEN User_Not_Allowed THEN
      -- <<< User not allowed to execute >>>
      x_completion_code := 2; -- Indicating fatal error

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_error,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' || pv_proc_name,
       p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_011');
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_011');

      -- Log the function exit time to FND_LOG (with error)
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_203',
         p_token1   => 'FUNC_NAME',
         p_value1   => v_func_name,
         p_token2   => 'TIME',
         p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    WHEN Invalid_Ledger_ID THEN
      -- <<< Ledger not found or ledger attribute not set >>>
      x_completion_code := 2; -- Indicating fatal error

      -- Get the name for Ledger dimension
      v_dim_name := FEM_DIMENSION_UTIL_PKG.Get_Dimension_Name
                      (p_dim_id => pv_ledger_dim_id);

      IF (v_dim_name IS NULL)
      THEN
        v_dim_name := 'Ledger';
      END IF;

      IF pv_attr_label IS NOT NULL
     THEN
       -- Failed to retrieve ledger attribute
       -- Get the attribute name
        v_attr_name := FEM_DIMENSION_UTIL_PKG.Get_Dim_Attr_Name
                         (p_dim_id     => pv_ledger_dim_id,
                          p_attr_label => pv_attr_label);

      IF v_attr_name IS NULL
        THEN
          v_attr_name := pv_attr_label;
        END IF;

        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_error,
           p_module   => 'fem.plsql.fem_gl_post_process_pkg.' || pv_proc_name,
           p_app_name => 'FEM',
           p_msg_name => 'FEM_INTG_BAL_LG_ATTR_ERR',
           p_token1   => 'ATTR_NAME',
           p_value1   => v_attr_name,
           p_token2   => 'LEDGER_NAME',
           p_value2   => pv_ledger_name,
           p_token3  => 'LEDGER_DIM',
           p_value3   => v_dim_name);
        FEM_ENGINES_PKG.User_Message
          (p_app_name => 'FEM',
           p_msg_name => 'FEM_INTG_BAL_LG_ATTR_ERR',
           p_token1   => 'ATTR_NAME',
           p_value1   => v_attr_name,
           p_token2   => 'LEDGER_NAME',
           p_value2   => pv_ledger_name,
           p_token3  => 'LEDGER_DIM',
           p_value3   => v_dim_name);

      ELSE
       -- The Ledger cannot be found in FEM Ledger Dimension
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_error,
           p_module   => 'fem.plsql.fem_gl_post_process_pkg.' || pv_proc_name,
           p_app_name => 'FEM',
           p_msg_name => 'FEM_INTG_BAL_LG_ERR',
           p_token1   => 'LEDGER_NAME',
           p_value1   => pv_ledger_name,
           p_token2   => 'LEDGER_DIM',
           p_value2   => v_dim_name);
        FEM_ENGINES_PKG.User_Message
          (p_app_name => 'FEM',
           p_msg_name => 'FEM_INTG_BAL_LG_ERR',
           p_token1   => 'LEDGER_NAME',
           p_value1   => pv_ledger_name,
           p_token2   => 'LEDGER_DIM',
           p_value2   => v_dim_name);

      END IF; -- IF pv_attr_label IS NOT NULL

      -- Log the function exit time to FND_LOG (with error)
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_203',
         p_token1   => 'FUNC_NAME',
         p_value1   => v_func_name,
         p_token2   => 'TIME',
         p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    WHEN OGLEngParam_FatalErr THEN
      -- <<< Fatal error >>>
      x_completion_code := 2; -- Indicating fatal error

     -- The error messages were printed, so just need to log the function exit
     -- time to FND_LOG (with error)
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_203',
         p_token1   => 'FUNC_NAME',
         p_value1   => v_func_name,
         p_token2   => 'TIME',
         p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    WHEN Others THEN
      -- <<< Unexpected database exceptions >>>
      x_completion_code := 2; -- Indicating fatal error

      IF pv_proc_name = 'validate_ogl_eng_parameters'
     THEN
        pv_sqlerrm   := SQLERRM;
        pv_callstack := dbms_utility.format_call_stack;
      END IF;

      -- Log the call stack and the Oracle error message to
      -- FND_LOG with the "unexpected exception" severity level.
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' || pv_proc_name,
       p_msg_text => pv_sqlerrm);
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => 'fem.plsql.fem_gl_post_process_pkg.' || pv_proc_name,
       p_msg_text => pv_callstack);

      -- Log the Oracle error message to the Concurrent Request Log
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_text => pv_sqlerrm);

      -- Log the function exit time to FND_LOG (with error)
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_203',
         p_token1   => 'FUNC_NAME',
         p_value1   => v_func_name,
         p_token2   => 'TIME',
         p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

  END Validate_OGL_Eng_Parameters;
-- =======================================================================

-- =======================================================================
  PROCEDURE Register_OGL_Process_Execution
               (x_completion_code OUT NOCOPY NUMBER) IS
-- =======================================================================
-- Purpose
--    Validate the FEM-OGL Integration Balances Rule execution and perform
--    initial process execution registration in FEM processing architecture
-- History
--    11-29-04  L Poon  Created
--    02-07-05  L Poon  Bug fix 4170124: The period gap check is changed to
--                      maintain at ledger level for actual balance type
--                      instead of ledger/dataset level
-- Arguments
--    x_completion_code returns 0 for success, 1 for warning, 2 for failure.
-- Notes
--    Called by FEM_INTG_BAL_RULE_ENG_PKG.Main before loading balances
-- =======================================================================

    v_module        VARCHAR2(100);
    v_func_name     VARCHAR2(80);

    v_msg_count     NUMBER;
    v_msg_data      VARCHAR2(2000);
    i               PLS_INTEGER;
    v_return_status VARCHAR2(1);

    CURSOR ds_cur IS
     SELECT DISTINCT OUTPUT_DATASET_CODE
     FROM FEM_INTG_EXEC_PARAMS_GT
     WHERE ERROR_CODE IS NULL;

    -- Bug fix 4285337: Get the end date for each period in order to populate
    -- it in FEM_PL_REQUESTS.EFFECTIVE_DATE
    CURSOR cp_cur (p_dataset_code IN VARCHAR2) IS
      SELECT gt.CAL_PERIOD_ID
           , gt.LOAD_METHOD_CODE
           , gt.PERIOD_NAME
           , gt.EFFECTIVE_PERIOD_NUM
           , per.END_DATE
      FROM FEM_INTG_EXEC_PARAMS_GT gt
         , GL_PERIOD_STATUSES per
      WHERE gt.ERROR_CODE IS NULL
      AND gt.OUTPUT_DATASET_CODE = p_dataset_code
      AND per.PERIOD_NAME = gt.PERIOD_NAME
      AND per.APPLICATION_ID = 101
      AND per.LEDGER_ID = pv_ledger_id
      ORDER BY gt.EFFECTIVE_PERIOD_NUM;

    CURSOR req_cur IS
      SELECT REQUEST_ID
      FROM FEM_INTG_EXEC_PARAMS_GT
      WHERE ERROR_CODE IS NULL
      AND REQUEST_ID IS NOT NULL;

    v_first_load_cal_per_id  fem_pl_requests.cal_period_id%TYPE;
    v_last_load_cal_per_id   fem_pl_requests.cal_period_id%TYPE;
    v_cal_per_name           fem_cal_periods_tl.cal_period_name%TYPE;
    v_cal_per_num            fem_cal_periods_attr.number_assign_value%TYPE;
    v_cal_per_year           fem_cal_periods_attr.number_assign_value%TYPE;
    v_first_load_eff_per_num gl_period_statuses.effective_period_num%TYPE;
    v_last_load_eff_per_num  gl_period_statuses.effective_period_num%TYPE;
    v_first_reg_eff_per_num  gl_period_statuses.effective_period_num%TYPE;
    v_last_reg_eff_per_num   gl_period_statuses.effective_period_num%TYPE;
    v_min_valid_eff_per_num  gl_period_statuses.effective_period_num%TYPE;
    v_max_valid_eff_per_num  gl_period_statuses.effective_period_num%TYPE;
    v_any_period_gap         VARCHAR2(1);

    v_load_method fem_intg_exec_params_gt.load_method_code%TYPE;
    v_dummy_flag  VARCHAR2(1);
    v_req_id      NUMBER;

    v_dim_name    fem_dimensions_tl.dimension_name%TYPE;
    v_attr_name   fem_dim_attributes_tl.attribute_name%TYPE;

    OGLRegProc_FatalErr EXCEPTION;

  BEGIN
    v_module    := 'fem.plsql.fem_gl_post_process_pkg.register_ogl_process_execution';
    v_func_name := 'FEM_GL_POST_PROCESS_PKG.Register_OGL_Process_Execution';

    -- Log the function entry time to FND_LOG
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_201',
       p_token1   => 'FUNC_NAME',
       p_value1   => v_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    -- -------------------------------------------------------
    -- Loop for each Output Dataset in FEM_INTG_EXEC_PARAMS_GT
    -- -------------------------------------------------------
    FOR v_ds IN ds_cur LOOP
      -- Log the current Dataset Code
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'v_ds.output_dataset_code',
         p_token2   => 'VAR_VAL',
         p_value2   => v_ds.output_dataset_code);

      -- Initailze the local variables for this Dataset
      v_cal_per_name           := '';
      v_first_load_eff_per_num := -1;
      v_last_load_eff_per_num  := -1;
      v_first_reg_eff_per_num  := -1;
      v_last_reg_eff_per_num   := -1;
      v_any_period_gap         := 'N';

      -- Get the first and last valid periods for this Dataset
      SELECT NVL(min(EFFECTIVE_PERIOD_NUM), -1)
          , NVL(max(EFFECTIVE_PERIOD_NUM), -1)
        INTO v_min_valid_eff_per_num,
             v_max_valid_eff_per_num
        FROM FEM_INTG_EXEC_PARAMS_GT
       WHERE ERROR_CODE IS NULL
         AND OUTPUT_DATASET_CODE = v_ds.output_dataset_code;

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'v_min_valid_eff_per_num',
         p_token2   => 'VAR_VAL',
         p_value2   => TO_CHAR(v_min_valid_eff_per_num));
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'v_max_valid_eff_per_num',
         p_token2   => 'VAR_VAL',
         p_value2   => TO_CHAR(v_max_valid_eff_per_num));

      -- Only process this Dataset if at least one valid periods exist
      IF (v_min_valid_eff_per_num <> -1)
      THEN

        -- -------------------------------------------------------------------
        -- 1. Initialize the First and Last Load Cal Period ID for this Ledger
        --    Actual Balances or this Budget/Encumbrance Type Output Dataset
        -- -------------------------------------------------------------------

        -- If it is Actual balance type, get the first and last load cal periods
      -- of all Actual Balances loads for this ledger regardless the dataset.
      -- For other balance types, get these for this Ledger/Dataset.
        SELECT NVL(min(CAL_PERIOD_ID), -1)
           , NVL(max(CAL_PERIOD_ID), -1)
        INTO v_first_load_cal_per_id, v_last_load_cal_per_id
        FROM FEM_DL_DIMENSIONS
        WHERE LEDGER_ID = pv_ledger_id
      -- 04-26-05: Changed to check balance_type_code only when the dataset
      --           balance type is ACTUAL
        AND (   (pv_ds_balance_type_cd = 'ACTUAL'
               AND BALANCE_TYPE_CODE = pv_ds_balance_type_cd)
            OR (DATASET_CODE = v_ds.output_dataset_code))
        AND SOURCE_SYSTEM_CODE = pv_gl_source_system_code
        AND TABLE_NAME = 'FEM_BALANCES';

        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement,
           p_module   => v_module,
           p_app_name => 'FEM',
           p_msg_name => 'FEM_GL_POST_204',
           p_token1   => 'VAR_NAME',
           p_value1   => 'v_first_load_cal_per_id',
           p_token2   => 'VAR_VAL',
           p_value2   => TO_CHAR(v_first_load_cal_per_id));

        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement,
           p_module   => v_module,
           p_app_name => 'FEM',
           p_msg_name => 'FEM_GL_POST_204',
           p_token1   => 'VAR_NAME',
           p_value1   => 'v_last_load_cal_per_id',
           p_token2   => 'VAR_VAL',
           p_value2   => TO_CHAR(v_last_load_cal_per_id));

        IF (v_first_load_cal_per_id <> -1)
        THEN
          -- The First Load Cal Period exists for this Dataset, so find its
        -- name, GL period number and period year

          -- Find the Cal Period Name
          SELECT CAL_PERIOD_NAME
          INTO v_cal_per_name
          FROM FEM_CAL_PERIODS_TL
          WHERE CAL_PERIOD_ID = v_first_load_cal_per_id
          AND LANGUAGE = USERENV('LANG');

          BEGIN
            -- Retrieve the First Load Cal Period GL_PERIOD_NUM attribute
            fem_dimension_util_pkg.get_dim_attr_id_ver_id
              (x_err_code    => pv_API_return_code,
               x_attr_id     => pv_dim_attr_id,
               x_ver_id      => pv_dim_attr_ver_id,
               p_dim_id      => pv_cal_per_dim_id,
               p_attr_label  => 'GL_PERIOD_NUM');

            IF pv_API_return_code > 0
            THEN
              -- Fail to find the attribute version
              FEM_ENGINES_PKG.Tech_Message
                (p_severity => pc_log_level_exception,
                 p_module   => v_module,
                 p_msg_text => 'raising Invalid_Cal_Period_ID when getting period num');
              pv_attr_label := 'GL_PERIOD_NUM';
              RAISE Invalid_Cal_Period_ID;
            END IF;

            SELECT number_assign_value
              INTO v_cal_per_num
              FROM fem_cal_periods_attr
             WHERE attribute_id  = pv_dim_attr_id
               AND version_id    = pv_dim_attr_ver_id
               AND cal_period_id = v_first_load_cal_per_id;

            FEM_ENGINES_PKG.Tech_Message
             (p_severity => pc_log_level_statement,
              p_module   => v_module,
              p_app_name => 'FEM',
              p_msg_name => 'FEM_GL_POST_204',
              p_token1   => 'VAR_NAME',
              p_value1   => 'v_cal_per_num',
              p_token2   => 'VAR_VAL',
              p_value2   => TO_CHAR(v_cal_per_num));

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              -- Fail to retrieve the First Load Cal Peroid Number
              FEM_ENGINES_PKG.Tech_Message
                (p_severity => pc_log_level_exception,
                 p_module   => v_module,
                 p_msg_text => 'raising Invalid_Cal_Period_ID when getting period num');
              pv_attr_label := 'GL_PERIOD_NUM';
              RAISE Invalid_Cal_Period_ID;
          END;

          BEGIN
            -- Retrieve the First Load Cal Period ACCOUNTING_YEAR attribute
            fem_dimension_util_pkg.get_dim_attr_id_ver_id
              (x_err_code    => pv_API_return_code,
               x_attr_id     => pv_dim_attr_id,
               x_ver_id      => pv_dim_attr_ver_id,
               p_dim_id      => pv_cal_per_dim_id,
               p_attr_label  => 'ACCOUNTING_YEAR');

            IF pv_API_return_code > 0
            THEN
              -- Fail to find the attribute version
              FEM_ENGINES_PKG.Tech_Message
                (p_severity => pc_log_level_exception,
                 p_module   => v_module,
                 p_msg_text => 'raising Invalid_Cal_Period_ID when getting year');
              pv_attr_label := 'ACCOUNTING_YEAR';
              RAISE Invalid_Cal_Period_ID;
            END IF;

            SELECT number_assign_value
              INTO v_cal_per_year
              FROM fem_cal_periods_attr
             WHERE attribute_id  = pv_dim_attr_id
               AND version_id    = pv_dim_attr_ver_id
               AND cal_period_id = v_first_load_cal_per_id;

            FEM_ENGINES_PKG.Tech_Message
             (p_severity => pc_log_level_statement,
              p_module   => v_module,
              p_app_name => 'FEM',
              p_msg_name => 'FEM_GL_POST_204',
              p_token1   => 'VAR_NAME',
              p_value1   => 'v_cal_per_year',
              p_token2   => 'VAR_VAL',
              p_value2   => TO_CHAR(v_cal_per_year));

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              -- Fail to retrieve the First Load Cal Period Accounting Year
              FEM_ENGINES_PKG.Tech_Message
                (p_severity => pc_log_level_exception,
                 p_module   => v_module,
                 p_msg_text => 'raising Invalid_Cal_Period_ID when getting year');
              pv_attr_label := 'ACCOUNTING_YEAR';
              RAISE Invalid_Cal_Period_ID;
          END;

          -- Find the corresponding GL Effective Period Number
          SELECT effective_period_num
            INTO v_first_load_eff_per_num
            FROM GL_PERIOD_STATUSES
           WHERE APPLICATION_ID = 101
             AND LEDGER_ID = pv_ledger_id
             AND PERIOD_YEAR = v_cal_per_year
             AND PERIOD_NUM = v_cal_per_num;

          FEM_ENGINES_PKG.Tech_Message
            (p_severity => pc_log_level_statement,
             p_module   => v_module,
             p_app_name => 'FEM',
             p_msg_name => 'FEM_GL_POST_204',
             p_token1   => 'VAR_NAME',
             p_value1   => 'v_first_load_eff_per_num',
             p_token2   => 'VAR_VAL',
             p_value2   => TO_CHAR(v_first_load_eff_per_num));

          IF (v_last_load_cal_per_id <> v_first_load_cal_per_id)
          THEN
            -- The Last Load Cal Period is different with the First Load Cal
            -- Period, so find its name, GL period number and period year

            -- Find the Cal Period Name
            SELECT CAL_PERIOD_NAME
            INTO v_cal_per_name
            FROM FEM_CAL_PERIODS_TL
            WHERE CAL_PERIOD_ID = v_last_load_cal_per_id
            AND LANGUAGE = USERENV('LANG');

            BEGIN
              -- Retrieve the Last Load Cal Period GL_PERIOD_NUM attribute
              fem_dimension_util_pkg.get_dim_attr_id_ver_id
                (x_err_code    => pv_API_return_code,
                 x_attr_id     => pv_dim_attr_id,
                 x_ver_id      => pv_dim_attr_ver_id,
                 p_dim_id      => pv_cal_per_dim_id,
              p_attr_label  => 'GL_PERIOD_NUM');

              IF pv_API_return_code > 0
              THEN
                -- Fail to find the attribute version
                FEM_ENGINES_PKG.Tech_Message
                  (p_severity => pc_log_level_exception,
                   p_module   => v_module,
                   p_msg_text => 'raising Invalid_Cal_Period_ID when getting period num');
                pv_attr_label := 'GL_PERIOD_NUM';
                RAISE Invalid_Cal_Period_ID;
              END IF;

              SELECT number_assign_value
                INTO v_cal_per_num
                FROM fem_cal_periods_attr
               WHERE attribute_id  = pv_dim_attr_id
                 AND version_id    = pv_dim_attr_ver_id
                 AND cal_period_id = v_last_load_cal_per_id;

              FEM_ENGINES_PKG.Tech_Message
               (p_severity => pc_log_level_statement,
                p_module   => v_module,
                p_app_name => 'FEM',
                p_msg_name => 'FEM_GL_POST_204',
                p_token1   => 'VAR_NAME',
                p_value1   => 'v_cal_per_num',
                p_token2   => 'VAR_VAL',
                p_value2   => TO_CHAR(v_cal_per_num));

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                -- Fail to retrieve the Last Load Cal Peroid Number
                FEM_ENGINES_PKG.Tech_Message
                  (p_severity => pc_log_level_exception,
                   p_module   => v_module,
                   p_msg_text => 'raising Invalid_Cal_Period_ID when getting period num');
                   pv_attr_label := 'GL_PERIOD_NUM';
                RAISE Invalid_Cal_Period_ID;
            END;

            BEGIN
              -- Retrieve the Last Load Cal Period ACCOUNTING_YEAR attribute
              fem_dimension_util_pkg.get_dim_attr_id_ver_id
                (x_err_code    => pv_API_return_code,
                 x_attr_id     => pv_dim_attr_id,
                 x_ver_id      => pv_dim_attr_ver_id,
                 p_dim_id      => pv_cal_per_dim_id,
                 p_attr_label  => 'ACCOUNTING_YEAR');

              IF pv_API_return_code > 0
              THEN
                -- Fail to find the attribute version
                FEM_ENGINES_PKG.Tech_Message
                  (p_severity => pc_log_level_exception,
                   p_module   => v_module,
                   p_msg_text => 'raising Invalid_Cal_Period_ID when getting year');
                pv_attr_label := 'ACCOUNTING_YEAR';
                RAISE Invalid_Cal_Period_ID;
              END IF;

              SELECT number_assign_value
                INTO v_cal_per_year
                FROM fem_cal_periods_attr
               WHERE attribute_id  = pv_dim_attr_id
                 AND version_id    = pv_dim_attr_ver_id
                 AND cal_period_id = v_last_load_cal_per_id;

              FEM_ENGINES_PKG.Tech_Message
               (p_severity => pc_log_level_statement,
                p_module   => v_module,
                p_app_name => 'FEM',
                p_msg_name => 'FEM_GL_POST_204',
                p_token1   => 'VAR_NAME',
                p_value1   => 'v_cal_per_year',
                p_token2   => 'VAR_VAL',
                p_value2   => TO_CHAR(v_cal_per_year));

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                -- Fail to retrieve the Last Load Cal Period Accounting Year
                FEM_ENGINES_PKG.Tech_Message
                  (p_severity => pc_log_level_exception,
                   p_module   => v_module,
                   p_msg_text => 'raising Invalid_Cal_Period_ID when getting year');
                pv_attr_label := 'ACCOUNTING_YEAR';
                RAISE Invalid_Cal_Period_ID;
            END;

            -- Find the corresponding GL Effective Period Number
            SELECT effective_period_num
              INTO v_last_load_eff_per_num
              FROM GL_PERIOD_STATUSES
             WHERE APPLICATION_ID = 101
               AND LEDGER_ID = pv_ledger_id
               AND PERIOD_YEAR = v_cal_per_year
               AND PERIOD_NUM = v_cal_per_num;

          ELSE
            -- The Last Load Cal Period is same as the First Load Cal Period
            v_last_load_eff_per_num := v_first_load_eff_per_num;

          END IF; -- IF (v_last_load_cal_per_id <> v_first_load_cal_per_id)

          FEM_ENGINES_PKG.Tech_Message
            (p_severity => pc_log_level_statement,
             p_module   => v_module,
             p_app_name => 'FEM',
             p_msg_name => 'FEM_GL_POST_204',
             p_token1   => 'VAR_NAME',
             p_value1   => 'v_last_load_eff_per_num',
             p_token2   => 'VAR_VAL',
             p_value2   => TO_CHAR(v_last_load_eff_per_num));

          BEGIN
            SELECT 'Y'
            INTO v_any_period_gap
            FROM DUAL
            WHERE EXISTS
                  (SELECT 'Period gap exists'
                     FROM GL_PERIOD_STATUSES
                    WHERE LEDGER_ID = pv_ledger_id
                      AND APPLICATION_ID = 101
                      AND ((v_first_load_eff_per_num > v_max_valid_eff_per_num
                       AND EFFECTIVE_PERIOD_NUM > v_max_valid_eff_per_num
                            AND EFFECTIVE_PERIOD_NUM < v_first_load_eff_per_num)
                           OR
                           (v_min_valid_eff_per_num  > v_last_load_eff_per_num
                      AND EFFECTIVE_PERIOD_NUM > v_last_load_eff_per_num
                            AND EFFECTIVE_PERIOD_NUM < v_min_valid_eff_per_num)));
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              v_any_period_gap := 'N';
          END;

        END IF; -- IF (v_first_load_cal_per_id <> -1)

        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement,
           p_module   => v_module,
           p_app_name => 'FEM',
           p_msg_name => 'FEM_GL_POST_204',
           p_token1   => 'VAR_NAME',
           p_value1   => 'v_any_period_gap',
           p_token2   => 'VAR_VAL',
           p_value2   => v_any_period_gap);

        IF (v_any_period_gap = 'N')
        THEN
          -- No period gap exists between the loaded period range and the valid
        -- period range, so start to register the valid periods

          -- ------------------------------------------------------------------
          -- Loop for each valid Cal Period in FEM_INTG_EXEC_PARAMS_GT for this
          -- Output Dataset
          -- ------------------------------------------------------------------
          FOR v_cp IN cp_cur(v_ds.output_dataset_code) LOOP
            -- Log the current Period Name, Cal Period ID, and Load Method Code
            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => v_module,
               p_app_name => 'FEM',
               p_msg_name => 'FEM_GL_POST_204',
               p_token1   => 'VAR_NAME',
               p_value1   => 'v_cp.period_name',
               p_token2   => 'VAR_VAL',
               p_value2   => v_cp.period_name);
            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => v_module,
               p_app_name => 'FEM',
               p_msg_name => 'FEM_GL_POST_204',
               p_token1   => 'VAR_NAME',
               p_value1   => 'v_cp.cal_period_id',
               p_token2   => 'VAR_VAL',
               p_value2   => TO_CHAR(v_cp.cal_period_id));
           FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => v_module,
               p_app_name => 'FEM',
               p_msg_name => 'FEM_GL_POST_204',
               p_token1   => 'VAR_NAME',
               p_value1   => 'v_cp.effective_period_num',
               p_token2   => 'VAR_VAL',
               p_value2   => TO_CHAR(v_cp.effective_period_num));
            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => v_module,
               p_app_name => 'FEM',
               p_msg_name => 'FEM_GL_POST_204',
               p_token1   => 'VAR_NAME',
               p_value1   => 'v_cp.load_method_code',
               p_token2   => 'VAR_VAL',
               p_value2   => v_cp.load_method_code);
            -- Bug fix 4285337: Print the end date for each period
            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => v_module,
               p_app_name => 'FEM',
               p_msg_name => 'FEM_GL_POST_204',
               p_token1   => 'VAR_NAME',
               p_value1   => 'v_cp.end_date',
               p_token2   => 'VAR_VAL',
               p_value2   => v_cp.end_date);

            -- ------------------------------------------------------------------
            -- 2. If the load method is Incremental, check whether it is required
            --    to set the load method as Snapshot
            -- ------------------------------------------------------------------
            v_load_method := v_cp.load_method_code;
            IF (v_load_method = 'I')
            THEN
              IF (v_first_load_cal_per_id = -1)
              THEN
                -- Since no balances have ever been loaded before for this
            -- Ledger/Output Dataset, always set the load method as Snapshot
                v_load_method := 'S';
              ELSE
                -- Balances have been loaded before for this Ledger/Output
                -- Dataset, so we need to check if any balances have been loaded
                -- for this Ledger/Output Dataset/Cal Period
                BEGIN
                  -- Bug fix 4170124: Changed to check FEM_DL_DIMENSIONS instead
                  -- of FEM_PL_REQUESTS
                  SELECT 'Y'
                  INTO v_dummy_flag
                  FROM DUAL
                  WHERE EXISTS
                     (SELECT 'Loaded'
                            FROM FEM_DL_DIMENSIONS
                           WHERE LEDGER_ID = pv_ledger_id
                             AND CAL_PERIOD_ID = v_cp.cal_period_id
                             AND DATASET_CODE = v_ds.output_dataset_code
                             AND SOURCE_SYSTEM_CODE = pv_gl_source_system_code
                             AND TABLE_NAME = 'FEM_BALANCES');
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    -- No balances have been loaded for this Ledger/Output
                    -- Dataset/Cal Period, so set the load method as Snapshot
                    v_load_method := 'S';
                END;
              END IF; -- IF (v_first_load_cal_period_id = -1)
            END IF; -- IF (v_cp.load_method_code = 'I')

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => v_module,
               p_app_name => 'FEM',
               p_msg_name => 'FEM_GL_POST_204',
               p_token1   => 'VAR_NAME',
               p_value1   => 'v_load_method',
               p_token2   => 'VAR_VAL',
               p_value2   => v_load_method);

            -- -------------------------------------------------------------
            -- 3. Register request for this Ledger/Output Dataset/Cal Period
            -- -------------------------------------------------------------

            -- Get a new request ID to register
            SELECT FND_CONCURRENT_REQUESTS_S.nextval
            INTO v_req_id
            FROM DUAL;

            -- Print the request ID to FND Log
            FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_statement,
               p_module   => v_module,
               p_app_name => 'FEM',
               p_msg_name => 'FEM_GL_POST_204',
               p_token1   => 'VAR_NAME',
               p_value1   => 'v_req_id',
               p_token2   => 'VAR_VAL',
               p_value2   => TO_CHAR(v_req_id));

            -- Initialize the FND Message API
            FND_MSG_PUB.Initialize;
            -- Register the concurrent request in FEM_PL_REQUESTS
            -- Bug fix 4285337: Pass the end date of each period when
         -- registering the request
            FEM_PL_PKG.Register_Request
              (P_API_VERSION            => pc_API_version,
               P_COMMIT                 => 'T',
               P_CAL_PERIOD_ID          => v_cp.cal_period_id,
               P_LEDGER_ID              => pv_ledger_id,
               P_OUTPUT_DATASET_CODE    => v_ds.output_dataset_code,
               P_EFFECTIVE_DATE         => v_cp.end_date,
               P_REQUEST_ID             => v_req_id,
               P_USER_ID                => pv_user_id,
               P_LAST_UPDATE_LOGIN      => pv_login_id,
               P_PROGRAM_ID             => pv_pgm_id,
               P_PROGRAM_LOGIN_ID       => pv_login_id,
               P_PROGRAM_APPLICATION_ID => pv_pgm_app_id,
               P_EXEC_MODE_CODE         => v_load_method,
               X_MSG_COUNT              => v_msg_count,
               X_MSG_DATA               => v_msg_data,
               X_RETURN_STATUS          => v_return_status);

            IF (v_return_status <> 'S')
            THEN
              -- Incompatible API or unexpected database error
              FEM_ENGINES_PKG.Tech_Message
                (p_severity => pc_log_level_statement,
                 p_module   => v_module,
                 p_msg_text => 'Raising OGLRegProc_FatalErr after calling Register_Request');
              RAISE OGLRegProc_FatalErr;
            END IF; -- IF (v_return_status <> 'S')

            -- ---------------------------------------------------------------
            -- 4. Register execution for this Ledger/Output Dataset/Cal Period
            -- ---------------------------------------------------------------

            -- Initialize the FND Message API
            FND_MSG_PUB.Initialize;
            -- Check for process locks and process overlaps, validate the execution
            -- mode parameter, validate the period(s), and register the execution in
            -- FEM_PL_OBJECT_EXECUTIONS
            FEM_PL_PKG.Register_Object_Execution
              (P_API_VERSION               => pc_API_version,
               P_COMMIT                    => 'T',
               P_REQUEST_ID                => v_req_id,
               P_OBJECT_ID                 => pv_rule_obj_id,
               P_EXEC_OBJECT_DEFINITION_ID => pv_rule_obj_def_id,
               P_USER_ID                   => pv_user_id,
               P_LAST_UPDATE_LOGIN         => pv_login_id,
               P_EXEC_MODE_CODE            => v_load_method,
               X_EXEC_STATE                => pv_exec_state,
               X_PREV_REQUEST_ID           => pv_prev_req_id,
               X_MSG_COUNT                 => v_msg_count,
               X_MSG_DATA                  => v_msg_data,
               X_RETURN_STATUS             => v_return_status);

            IF v_return_status = 'E'
            THEN
              -- The execution lock exists for this Output Dataset/Cal Period
              FEM_ENGINES_PKG.Tech_Message
                (p_severity => pc_log_level_exception,
                 p_module   => v_module,
                 p_app_name => 'FEM',
                 p_msg_name => 'FEM_INTG_BAL_REGISTER_FAIL',
                 p_token1   => 'DS_CODE',
                 p_value1   => v_ds.output_dataset_code,
                 p_token2   => 'PER_NAME',
                 p_value2   => v_cp.PERIOD_NAME);
              FEM_ENGINES_PKG.User_Message
                (p_app_name => 'FEM',
                 p_msg_name => 'FEM_INTG_BAL_REGISTER_FAIL',
                 p_token1   => 'DS_CODE',
                 p_value1   => v_ds.output_dataset_code,
                 p_token2   => 'PER_NAME',
                 p_value2   => v_cp.PERIOD_NAME);

              -- Log the user message(s) returned by Register_Object_Execution()
              IF v_msg_count = 1
              THEN
                -- Only one message
                FEM_ENGINES_PKG.User_Message
                  (p_app_name => 'FEM',
                   p_msg_text => v_msg_data);

              ELSIF v_msg_count > 1
              THEN
                -- More than one messages
                FOR i IN 1 .. v_msg_count LOOP
                  v_msg_data := FND_MSG_PUB.Get(p_msg_index => i, p_encoded => 'F');
                  FEM_ENGINES_PKG.User_Message
                    (p_app_name => 'FEM',
                     p_msg_text => v_msg_data);
                END LOOP;

              END IF; -- IF v_msg_count = 1

              -- Update the load method code and error code of
              -- FEM_INTG_EXEC_PARAMS_GT for this Output Dataset/Cal Period
              UPDATE FEM_INTG_EXEC_PARAMS_GT
              SET LOAD_METHOD_CODE = v_load_method
                , ERROR_CODE = 'EXEC_LOCK_EXISTS'
              WHERE CAL_PERIOD_ID = v_cp.cal_period_id
              AND OUTPUT_DATASET_CODE = v_ds.output_dataset_code;

              -- Initialize the FND Message API
              FND_MSG_PUB.Initialize;
              -- Unregister the request for this Cal Period/Output Dataset
              FEM_PL_PKG.Unregister_Request
                (P_API_VERSION   => pc_API_version,
                 P_COMMIT        => 'T',
                 P_REQUEST_ID    => v_req_id,
                 X_MSG_COUNT     => v_msg_count,
                 X_MSG_DATA      => v_msg_data,
                 X_RETURN_STATUS => v_return_status);

              -- Log the user message(s) returned by Unregister_Request()
              IF v_msg_count = 1
              THEN
                -- Only one message
                FEM_ENGINES_PKG.User_Message
                  (p_app_name => 'FEM',
                   p_msg_text => v_msg_data);

              ELSIF v_msg_count > 1
              THEN
                -- More than one messages
                FOR i IN 1 .. v_msg_count LOOP
                  v_msg_data := FND_MSG_PUB.Get(p_msg_index => i, p_encoded => 'F');
                  FEM_ENGINES_PKG.User_Message
                    (p_app_name => 'FEM',
                     p_msg_text => v_msg_data);
                END LOOP;
              END IF; -- IF v_msg_count = 1

              x_completion_code := 1; -- Indicating warning
              EXIT; -- Exit the cp_cur loop

            ELSIF v_return_status = 'U'
            THEN
              -- Unexpected database error
              FEM_ENGINES_PKG.Tech_Message
                (p_severity => pc_log_level_exception,
                 p_module   => v_module,
                 p_app_name => 'FEM',
                 p_msg_name => 'FEM_INTG_BAL_REGISTER_FAIL',
                 p_token1   => 'DS_CODE',
                 p_value1   => v_ds.output_dataset_code,
                 p_token2   => 'PER_NAME',
                 p_value2   => v_cp.PERIOD_NAME);
              FEM_ENGINES_PKG.User_Message
                (p_app_name => 'FEM',
                 p_msg_name => 'FEM_INTG_BAL_REGISTER_FAIL',
                 p_token1   => 'DS_CODE',
                 p_value1   => v_ds.output_dataset_code,
                 p_token2   => 'PER_NAME',
                 p_value2   => v_cp.PERIOD_NAME);

              FEM_ENGINES_PKG.Tech_Message
                (p_severity => pc_log_level_exception,
                 p_module   => v_module,
                 p_msg_text => 'Raising OGLRegProc_FatalErr after calling Register_Object_Execution');
              RAISE OGLRegProc_FatalErr;

            ELSE
              -- Succeed to register execution for this Cal Period/Output Dataset
              FEM_ENGINES_PKG.Tech_Message
                (p_severity => pc_log_level_event,
                 p_module   => v_module,
                 p_app_name => 'FEM',
                 p_msg_name => 'FEM_INTG_BAL_REGISTER_SUCC',
                 p_token1   => 'DS_CODE',
                 p_value1   => v_ds.output_dataset_code,
                 p_token2   => 'PER_NAME',
                 p_value2   => v_cp.PERIOD_NAME);
              FEM_ENGINES_PKG.User_Message
                (p_app_name => 'FEM',
                 p_msg_name => 'FEM_INTG_BAL_REGISTER_SUCC',
                 p_token1   => 'DS_CODE',
                 p_value1   => v_ds.output_dataset_code,
                 p_token2   => 'PER_NAME',
                 p_value2   => v_cp.PERIOD_NAME);

              UPDATE FEM_INTG_EXEC_PARAMS_GT
              SET REQUEST_ID = v_req_id
                , LOAD_METHOD_CODE = v_load_method
              WHERE CAL_PERIOD_ID = v_cp.cal_period_id
              AND OUTPUT_DATASET_CODE = v_ds.output_dataset_code;

              -- Set the First Registered Effective Period Number as the current
              -- Effective Period Number of this Cal Period if this is the first
              -- period registered successfully for this Dataset
              IF (v_first_reg_eff_per_num = -1)
              THEN
                v_first_reg_eff_per_num := v_cp.effective_period_num;
              END IF;

              -- Set the Last Registered Effective Period Number as the current
              -- Effective Period Number of this Cal Period
              v_last_reg_eff_per_num := v_cp.effective_period_num;

            END IF; -- IF v_return_status = 'E'

          END LOOP; -- cp_cur LOOP

          FEM_ENGINES_PKG.Tech_Message
            (p_severity => pc_log_level_statement,
             p_module   => v_module,
             p_app_name => 'FEM',
             p_msg_name => 'FEM_GL_POST_204',
             p_token1   => 'VAR_NAME',
             p_value1   => 'v_first_reg_eff_per_num',
             p_token2   => 'VAR_VAL',
             p_value2   => TO_CHAR(v_first_reg_eff_per_num));
          FEM_ENGINES_PKG.Tech_Message
            (p_severity => pc_log_level_statement,
             p_module   => v_module,
             p_app_name => 'FEM',
             p_msg_name => 'FEM_GL_POST_204',
             p_token1   => 'VAR_NAME',
             p_value1   => 'v_last_reg_eff_per_num',
             p_token2   => 'VAR_VAL',
             p_value2   => TO_CHAR(v_last_reg_eff_per_num));

          IF (v_first_load_eff_per_num <> -1)
          THEN
            BEGIN
              SELECT 'Y'
              INTO v_any_period_gap
              FROM DUAL
              WHERE EXISTS
                    (SELECT 'Period gap exists'
                       FROM GL_PERIOD_STATUSES
                      WHERE LEDGER_ID = pv_ledger_id
                        AND APPLICATION_ID = 101
                        AND ((v_first_load_eff_per_num > v_last_reg_eff_per_num
                              AND EFFECTIVE_PERIOD_NUM > v_last_reg_eff_per_num
                              AND EFFECTIVE_PERIOD_NUM < v_first_load_eff_per_num)
                             OR
                             (v_first_reg_eff_per_num  > v_last_load_eff_per_num
                        AND EFFECTIVE_PERIOD_NUM > v_last_load_eff_per_num
                              AND EFFECTIVE_PERIOD_NUM < v_first_reg_eff_per_num)));

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                v_any_period_gap := 'N';
            END;
          END IF; -- IF (v_first_load_eff_per_num <> -1)

          FEM_ENGINES_PKG.Tech_Message
            (p_severity => pc_log_level_statement,
             p_module   => v_module,
             p_app_name => 'FEM',
             p_msg_name => 'FEM_GL_POST_204',
             p_token1   => 'VAR_NAME',
             p_value1   => 'v_any_period_gap',
             p_token2   => 'VAR_VAL',
             p_value2   => v_any_period_gap);

        END IF; -- IF (v_any_period_gap = 'N')

        IF (v_any_period_gap = 'Y')
        THEN
          -- Period gap exists between the loaded period range and the valid
          -- period range/registered period range, so no periods can be
          -- processed

          -- Log the warning messages
          FEM_ENGINES_PKG.Tech_Message
            (p_severity => pc_log_level_exception,
             p_module   => v_module,
             p_app_name => 'FEM',
             p_msg_name => 'FEM_INTG_BAL_PERIOD_GAP',
             p_token1   => 'DS_CODE',
             p_value1   => v_ds.output_dataset_code);
          FEM_ENGINES_PKG.User_Message
            (p_app_name => 'FEM',
             p_msg_name => 'FEM_INTG_BAL_PERIOD_GAP',
             p_token1   => 'DS_CODE',
             p_value1   => v_ds.output_dataset_code);

          -- Populate the error code PERIOD_GAP_EXISTS for all Cal Periods for
          -- this Output Dataset
          UPDATE FEM_INTG_EXEC_PARAMS_GT
          SET ERROR_CODE = 'PERIOD_GAP_EXISTS'
          WHERE OUTPUT_DATASET_CODE = v_ds.output_dataset_code
          AND ERROR_CODE IS NULL;

          x_completion_code := 1; -- Indicating warning

        END IF; -- IF (v_any_period_gap = 'Y')

      END IF; -- IF (v_min_valid_eff_per_num <> -1)

    END LOOP; -- ds_cur LOOP

    -- ------------------------------------------------------------------
    -- 5. Determine the statment type performed on FEM_BALANCES and which
    --    tables the balances will be loaded from
    -- ------------------------------------------------------------------

    BEGIN
      SELECT DISTINCT LOAD_METHOD_CODE
      INTO v_load_method
      FROM FEM_INTG_EXEC_PARAMS_GT
      WHERE ERROR_CODE IS NULL
      AND REQUEST_ID IS NOT NULL;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- There are no valid execution parameters
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_error,
           p_module   => v_module,
           p_app_name => 'FEM',
           p_msg_name => 'FEM_INTG_BAL_NO_VALID_EXEC');
        FEM_ENGINES_PKG.User_Message
          (p_app_name => 'FEM',
           p_msg_name => 'FEM_INTG_BAL_NO_VALID_EXEC');
        RAISE OGLRegProc_FatalErr;

      WHEN TOO_MANY_ROWS THEN
        v_load_method := 'B'; -- indicating both 'S' and 'I' exists
    END;

    -- Set the pv_stmt_type
    IF (v_load_method = 'S')
    THEN
      -- All load method codes are Snapshot
      pv_stmt_type := 'INSERT';

      IF (pv_exec_mode = 'I')
      THEN
        -- The original execution mode is Incremental, so log a message to
        -- inform users that it's been changed to Snapshot mode
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_event,
           p_module   => v_module,
           p_app_name => 'FEM',
           p_msg_name => 'FEM_INTG_BAL_CHANGE_TO_SNAP');
        FEM_ENGINES_PKG.User_Message
          (p_app_name => 'FEM',
           p_msg_name => 'FEM_INTG_BAL_CHANGE_TO_SNAP');
      END IF;

    ELSE
      -- All load method codes are Incremental or both codes exist
      pv_stmt_type := 'MERGE';

    END IF; -- IF (v_load_method = 'S')

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_stmt_type',
       p_token2   => 'VAR_VAL',
       p_value2   => pv_stmt_type);

    -- Set the pv_from_gl_bal_flag and pv_from_gl_delta_flag
    IF (pv_ds_balance_type_cd = 'BUDGET' OR v_load_method = 'S')
    THEN
      -- The balance type is Budget or all load method codes are 'Snapshot', so
      -- it'll only load balances from GL_BALANCES
      pv_from_gl_bal_flag := 'Y';
      pv_from_gl_delta_flag := 'N';

    ELSIF (v_load_method = 'I')
    THEN
      -- All load method codes are 'Incremental' and the balance type is Actual
      -- or Encumbrance Type, so it'll only load balances from GL_BALANCES_DELTA
      pv_from_gl_bal_flag := 'N';
      pv_from_gl_delta_flag := 'Y';

    ELSE
      -- Both codes exist and the balance type is Actual or Encumbrance Type, so
      -- it'll load balances from both GL_BALANCES and GL_BALANCES_DELTA
      pv_from_gl_bal_flag := 'Y';
      pv_from_gl_delta_flag := 'Y';

    END IF; -- IF (pv_ds_balance_type_cd = 'BALANCE' OR v_load_method = 'S')

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_from_gl_bal_flag',
       p_token2   => 'VAR_VAL',
       p_value2   => pv_from_gl_bal_flag);

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'pv_from_gl_delta_flag',
       p_token2   => 'VAR_VAL',
       p_value2   => pv_from_gl_delta_flag);

    -- -----------------------------------------------------
    -- 6. Register table information for registered requests
    -- -----------------------------------------------------
    FOR v_req IN req_cur LOOP
      -- Initialize the FND Message API
      FND_MSG_PUB.Initialize;
      -- Log Undo information for this Request, which will insert/update the
      -- table FEM_BALANCES; pass pv_stmt_type as the statement type
      FEM_PL_PKG.Register_Table
        (P_API_VERSION        => pc_API_version,
         P_COMMIT             => 'T',
         P_REQUEST_ID         => v_req.request_id,
         P_OBJECT_ID          => pv_rule_obj_id,
         P_TABLE_NAME         => 'FEM_BALANCES',
         P_STATEMENT_TYPE     => pv_stmt_type,
         P_NUM_OF_OUTPUT_ROWS => 0,
         P_USER_ID            => pv_user_id,
         P_LAST_UPDATE_LOGIN  => pv_login_id,
         X_MSG_COUNT          => v_msg_count,
         X_MSG_DATA           => v_msg_data,
         X_RETURN_STATUS      => v_return_status);

      IF v_return_status <> 'S'
      THEN
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_exception,
           p_module   => v_module,
           p_msg_text => 'Raising OGLRegProc_FatalErr after calling Register_Table');
        RAISE OGLRegProc_FatalErr;
      END IF; -- IF v_return_status <> 'S'

    END LOOP; -- req_cur LOOP

    -- ----------------------------
    -- 7. Exit with success/warning
    -- ----------------------------

    -- Log the function exit time to FND_LOG (successful completion)
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => v_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

  EXCEPTION
    WHEN Invalid_Cal_Period_ID THEN
      -- <<< Cal Period attributes not set >>>
      x_completion_code := 2; -- Indicating fatal error

      -- Get the name for Calendar Period dimension
      v_dim_name := FEM_DIMENSION_UTIL_PKG.Get_Dimension_Name
                      (p_dim_id => pv_cal_per_dim_id);

      IF (v_dim_name IS NULL)
      THEN
        v_dim_name := 'Calendar Period';
      END IF;

     -- Get the attribute name
     IF (pv_attr_label IS NOT NULL)
     THEN
        v_attr_name := FEM_DIMENSION_UTIL_PKG.Get_Dim_Attr_Name
                         (p_dim_id     => pv_cal_per_dim_id,
                          p_attr_label => pv_attr_label);

          IF v_attr_name IS NULL
        THEN
          v_attr_name := pv_attr_label;
        END IF;

      END IF; -- IF (pv_attr_label IS NOT NULL)

      -- Log the error message
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_error,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_DIM_ATTR_ERR',
         p_token1   => 'ATTR_NAME',
         p_value1   => v_attr_name,
         p_token2   => 'PER_NAME',
         p_value2   => v_cal_per_name,
         p_token3  => 'DIM_NAME',
         p_value3   => v_dim_name);
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_BAL_PER_ATTR_ERR',
         p_token1   => 'ATTR_NAME',
         p_value1   => v_attr_name,
         p_token2   => 'PER_NAME',
         p_value2   => v_cal_per_name,
         p_token3  => 'DIM_NAME',
         p_value3   => v_dim_name);

     -- Log the function exit time to FND_LOG (with error)
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_203',
         p_token1   => 'FUNC_NAME',
         p_value1   => v_func_name,
         p_token2   => 'TIME',
         p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    WHEN OGLRegProc_FatalErr THEN
      -- <<< Fatal error >>>
      x_completion_code := 2; -- Indicating fatal error

      -- Log the user message(s) returned by the API being called
      IF v_msg_count = 1
     THEN
       -- Only one message
        FEM_ENGINES_PKG.User_Message
          (p_app_name => 'FEM',
           p_msg_text => v_msg_data);

      ELSIF v_msg_count > 1
     THEN
       -- More than one messages
        FOR i IN 1 .. v_msg_count LOOP
          v_msg_data := FND_MSG_PUB.Get(p_msg_index => i, p_encoded => 'F');
          FEM_ENGINES_PKG.User_Message
            (p_app_name => 'FEM',
             p_msg_text => v_msg_data);
        END LOOP;

      END IF; -- IF v_msg_count = 1

     -- Log the function exit time to FND_LOG (with error)
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_203',
         p_token1   => 'FUNC_NAME',
         p_value1   => v_func_name,
         p_token2   => 'TIME',
         p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    WHEN OTHERS THEN
      -- <<< Unexpected database exceptions >>>
      x_completion_code := 2; -- Indicating fatal error

      pv_sqlerrm   := SQLERRM;
      pv_callstack := dbms_utility.format_call_stack;

      -- Log the call stack and the Oracle error message to
      -- FND_LOG with the "unexpected exception" severity level.
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => v_module,
       p_msg_text => pv_sqlerrm);
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => v_module,
       p_msg_text => pv_callstack);

      -- Log the Oracle error message to the Concurrent Request Log
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_text => pv_sqlerrm);

      -- Log the function exit time to FND_LOG (with error)
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_203',
         p_token1   => 'FUNC_NAME',
         p_value1   => v_func_name,
         p_token2   => 'TIME',
         p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

  END Register_OGL_Process_Execution;
-- =======================================================================

-- =======================================================================
  PROCEDURE Final_OGL_Process_Logging
                (p_exec_status             IN     VARCHAR2,
                 p_final_message_name      IN     VARCHAR2) IS
-- =======================================================================
-- Purpose
--    Performs final process logging after FEM-OGL Integration Balances
--    Rule execution
-- History
--    12-01-2004  L Poon  Created
--    01-25-2005  L Poon  Bug fix 4143603 - Uptake latest changes for the API
--                        register_data_location()
-- Arguments
--    p_exec_status        The final completion status: SUCCESS or
--                         ERROR_RERUN
--    p_final_message_name The name of the final message to be logged for
--                         the engine
-- Notes
--    Called by FEM_INTG_BAL_RULE_ENG_PKG.Main after process completion
-- =======================================================================

    v_module        VARCHAR2(100);
    v_func_name     VARCHAR2(80);

    v_msg_count     NUMBER;
    v_msg_data      VARCHAR2(2000);
    i               PLS_INTEGER;
    v_return_status VARCHAR2(1);

    v_exec_status   VARCHAR2(30);
    v_load_status   VARCHAR2(30);

    v_xlated_curr_ds_code    FEM_BAL_POST_INTERIM_GT.DATASET_CODE%TYPE;
    v_xlated_curr_cal_per_id FEM_BAL_POST_INTERIM_GT.CAL_PERIOD_ID%TYPE;
    v_xlated_curr_code       FEM_BAL_POST_INTERIM_GT.CURRENCY_CODE%TYPE;
    v_xlated_curr_found      BOOLEAN;

    CURSOR xlated_curr_cur IS
      SELECT DISTINCT bpi.DATASET_CODE
                    , bpi.CAL_PERIOD_ID
                   , bpi.CURRENCY_CODE
      FROM FEM_BAL_POST_INTERIM_GT bpi
      WHERE bpi.CURRENCY_TYPE_CODE = 'TRANSLATED'
      AND bpi.POSTING_ERROR_FLAG = 'N'
     AND NOT EXISTS
           (SELECT 'Invalid Delta Load'
              FROM FEM_INTG_DELTA_LOADS dl
             WHERE dl.LEDGER_ID = bpi.LEDGER_ID
               AND dl.DATASET_CODE = bpi.DATASET_CODE
               AND dl.CAL_PERIOD_ID = bpi.CAL_PERIOD_ID
               AND dl.DELTA_RUN_ID = bpi.DELTA_RUN_ID
               AND dl.LOADED_FLAG = 'N')
      ORDER BY bpi.DATASET_CODE, bpi.CAL_PERIOD_ID, bpi.CURRENCY_CODE;

    CURSOR req_cur IS
      SELECT REQUEST_ID
           , OUTPUT_DATASET_CODE
           , PERIOD_NAME
           , CAL_PERIOD_ID
           , NUM_OF_ROWS_SELECTED
           , NUM_OF_ROWS_POSTED
           , ERROR_CODE
      FROM FEM_INTG_EXEC_PARAMS_GT
      WHERE REQUEST_ID IS NOT NULL
     ORDER BY OUTPUT_DATASET_CODE, CAL_PERIOD_ID;

  BEGIN
    v_module    := 'fem.plsql.fem_gl_post_process_pkg.final_ogl_process_logging';
    v_func_name := 'FEM_GL_POST_PROCESS_PKG.Final_OGL_Process_Logging';

    -- Log the function entry time to FND_LOG
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_201',
       p_token1   => 'FUNC_NAME',
       p_value1   => v_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    -- List the IN parameters to FND_LOG
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'p_exec_status',
       p_token2   => 'VAR_VAL',
       p_value2   => p_exec_status);
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'p_final_message_name',
       p_token2   => 'VAR_VAL',
       p_value2   => p_final_message_name);

    -- Initialize local variables
    v_xlated_curr_found      := FALSE;
    v_xlated_curr_ds_code    := NULL;
    v_xlated_curr_cal_per_id := NULL;
    v_xlated_curr_code       := NULL;

    -- If the translated balances are included, open translated currency cursor
    IF (pv_xlated_bal_option <> 'NONE')
    THEN
      OPEN xlated_curr_cur;
      FETCH xlated_curr_cur INTO v_xlated_curr_ds_code,
                                v_xlated_curr_cal_per_id,
                          v_xlated_curr_code;
      IF (xlated_curr_cur%FOUND)
      THEN
       -- A translated currency is found
       v_xlated_curr_found := TRUE;
        -- Log the values retrieved from the translated currency cursor
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement,
           p_module   => v_module,
           p_app_name => 'FEM',
           p_msg_name => 'FEM_GL_POST_204',
           p_token1   => 'VAR_NAME',
           p_value1   => 'v_xlated_curr_ds_code',
           p_token2   => 'VAR_VAL',
           p_value2   => TO_CHAR(v_xlated_curr_ds_code));
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement,
           p_module   => v_module,
           p_app_name => 'FEM',
           p_msg_name => 'FEM_GL_POST_204',
           p_token1   => 'VAR_NAME',
           p_value1   => 'v_xlated_curr_cal_per_id',
           p_token2   => 'VAR_VAL',
           p_value2   => TO_CHAR(v_xlated_curr_cal_per_id));
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement,
           p_module   => v_module,
           p_app_name => 'FEM',
           p_msg_name => 'FEM_GL_POST_204',
           p_token1   => 'VAR_NAME',
           p_value1   => 'v_xlated_curr_code',
           p_token2   => 'VAR_VAL',
           p_value2   => v_xlated_curr_code);
      END IF; -- IF (xlated_curr_cur%FOUND)
    END IF; -- IF (pv_xlated_bal_option <> 'NONE')

    -- Loop for each request to perform final process logging
    FOR v_req IN req_cur LOOP

      -- Log the values retrieved from the request cursor for this Request
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'v_req.request_id',
         p_token2   => 'VAR_VAL',
         p_value2   => TO_CHAR(v_req.request_id));
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'v_req.output_dataset_code',
         p_token2   => 'VAR_VAL',
         p_value2   => v_req.output_dataset_code);
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'v_req.period_name',
         p_token2   => 'VAR_VAL',
         p_value2   => v_req.period_name);
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'v_req.cal_period_id',
         p_token2   => 'VAR_VAL',
         p_value2   => TO_CHAR(v_req.cal_period_id));
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'v_req.num_of_rows_selected',
         p_token2   => 'VAR_VAL',
         p_value2   => TO_CHAR(v_req.num_of_rows_selected));
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'v_req.num_of_rows_posted',
         p_token2   => 'VAR_VAL',
         p_value2   => TO_CHAR(v_req.num_of_rows_posted));
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'v_req.error_code',
         p_token2   => 'VAR_VAL',
         p_value2   => NVL(v_req.error_code, ''));

      -- ---------------------------------------------------------------------
      -- 1. Update the number of rows posted into FEM_BALANCES by this Request
      --    if there are any for this Output Dataset/Cal Period and the
      --    Execution Status is SUCCESS
      -- ---------------------------------------------------------------------
      IF (v_req.num_of_rows_posted > 0 AND p_exec_status = 'SUCCESS')
      THEN
        -- Initialize the FND Message API
        FND_MSG_PUB.Initialize;
        -- Update the number of output rows in FEM_PL_TABLES for this Request
        FEM_PL_PKG.Update_Num_of_Output_Rows
          (P_API_VERSION        => pc_API_version,
           P_COMMIT             => 'T',
           P_REQUEST_ID         => v_req.request_id,
           P_OBJECT_ID          => pv_rule_obj_id,
           P_TABLE_NAME         => 'FEM_BALANCES',
           P_STATEMENT_TYPE     => pv_stmt_type,
           P_NUM_OF_OUTPUT_ROWS => v_req.num_of_rows_posted,
           P_USER_ID            => pv_user_id,
           P_LAST_UPDATE_LOGIN  => pv_login_id,
           X_MSG_COUNT          => v_msg_count,
           X_MSG_DATA           => v_msg_data,
           X_RETURN_STATUS      => v_return_status);

        -- Log the user message(s) returned by the API
        IF v_msg_count = 1
        THEN
         -- Only one message
          FEM_ENGINES_PKG.User_Message
            (p_app_name => 'FEM',
             p_msg_text => v_msg_data);

        ELSIF v_msg_count > 1
        THEN
         -- More than one messages
          FOR i IN 1 .. v_msg_count LOOP
            v_msg_data := FND_MSG_PUB.Get(p_msg_index => i, p_encoded => 'F');
            FEM_ENGINES_PKG.User_Message
              (p_app_name => 'FEM',
               p_msg_text => v_msg_data);
          END LOOP;
        END IF; -- IF v_msg_count = 1

      END IF; -- IF (v_req.num_of_rows_posted > 0 AND p_exec_status = 'SUCCESS')

      -- ---------------------------------------------------------------------
      -- 2. Update the number of rows not posted into FEM_BALANCES for this
      --    Request if the number of rows posted is smaller than the number of
      --    rows selected for this Output Dataset/Cal Period
      -- ---------------------------------------------------------------------
      IF (v_req.num_of_rows_selected > v_req.num_of_rows_posted)
      THEN
        -- Initialize the FND Message API
        FND_MSG_PUB.Initialize;
        -- Update the number of data errors in FEM_PL_OBJECT_EXECUTIONS for
        -- this Request
        FEM_PL_PKG.Update_Obj_Exec_Errors
          (P_API_VERSION        => pc_API_version,
           P_COMMIT             => 'T',
           P_REQUEST_ID         => v_req.request_id,
           P_OBJECT_ID          => pv_rule_obj_id,
           P_ERRORS_REPORTED    => (v_req.num_of_rows_selected
                                   - v_req.num_of_rows_posted),
           P_ERRORS_REPROCESSED => 0,
           P_USER_ID            => pv_user_id,
           P_LAST_UPDATE_LOGIN  => pv_login_id,
           X_MSG_COUNT          => v_msg_count,
           X_MSG_DATA           => v_msg_data,
           X_RETURN_STATUS      => v_return_status);

        -- Log the user message(s) returned by the API
        IF v_msg_count = 1
        THEN
          -- Only one message
          FEM_ENGINES_PKG.User_Message
            (p_app_name => 'FEM',
             p_msg_text => v_msg_data);

        ELSIF v_msg_count > 1
        THEN
          -- More than one messages
          FOR i IN 1 .. v_msg_count LOOP
            v_msg_data := FND_MSG_PUB.Get(p_msg_index => i, p_encoded => 'F');
            FEM_ENGINES_PKG.User_Message
              (p_app_name => 'FEM',
               p_msg_text => v_msg_data);
          END LOOP;
        END IF; -- IF v_msg_count = 1

      END IF; -- IF (v_req.num_of_rows_selected > v_req.num_of_rows_posted)

      -- --------------------------------------------------
      -- 3. Determine the execution status for this Request
      -- --------------------------------------------------
      IF (   (p_exec_status = 'ERROR_RERUN')
          OR (v_req.num_of_rows_posted = 0 AND v_req.num_of_rows_selected > 0)
          OR (v_req.error_code IS NOT NULL))
      THEN
        -- Set the execution status to ERROR_RERUN when:
        --  * The passed Execution Status is ERROR_RERUN
        --  * OR there are rows selected but none of them can be posted
        --  * OR the error code of this Request is populated i.e. the possible
        --       error code will be PERIOD_GAP_EXIST
        v_exec_status := 'ERROR_RERUN';
      ELSE
        -- For other cases, set the execution status to SUCCESS
        v_exec_status := 'SUCCESS';
      END IF;
      -- Log the execution status of this Request
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'v_exec_status',
         p_token2   => 'VAR_VAL',
         p_value2   => v_exec_status);

      -- ------------------------------------------------------------
      -- 4. Update the object execution status to ERROR_RERUN/SUCCESS
      -- ------------------------------------------------------------
      -- Initialize the FND Message API
      FND_MSG_PUB.Initialize;
      -- Update the object execution status
      FEM_PL_PKG.Update_Obj_Exec_Status
        (P_API_VERSION        => pc_API_version,
         P_COMMIT             => 'T',
         P_REQUEST_ID         => v_req.request_id,
         P_OBJECT_ID          => pv_rule_obj_id,
         P_EXEC_STATUS_CODE   => v_exec_status,
         P_USER_ID            => pv_user_id,
         P_LAST_UPDATE_LOGIN  => pv_login_id,
         X_MSG_COUNT          => v_msg_count,
         X_MSG_DATA           => v_msg_data,
         X_RETURN_STATUS      => v_return_status);

      -- Log the user message(s) returned by the API
      IF v_msg_count = 1
      THEN
        -- Only one message
        FEM_ENGINES_PKG.User_Message
          (p_app_name => 'FEM',
           p_msg_text => v_msg_data);

      ELSIF v_msg_count > 1
      THEN
        -- More than one messages
        FOR i IN 1 .. v_msg_count LOOP
          v_msg_data := FND_MSG_PUB.Get(p_msg_index => i, p_encoded => 'F');
          FEM_ENGINES_PKG.User_Message
            (p_app_name => 'FEM',
             p_msg_text => v_msg_data);
        END LOOP;
      END IF; -- IF v_msg_count = 1

      -- -------------------------------------------------------------
      -- 5. Update the request execution status to ERROR_RERUN/SUCCESS
      -- -------------------------------------------------------------
      -- Initialize the FND Message API
      FND_MSG_PUB.Initialize;
      -- Update the request execution status
      FEM_PL_PKG.Update_Request_Status
        (P_API_VERSION        => pc_API_version,
         P_COMMIT             => 'T',
         P_REQUEST_ID         => v_req.request_id,
         P_EXEC_STATUS_CODE   => v_exec_status,
         P_USER_ID            => pv_user_id,
         P_LAST_UPDATE_LOGIN  => pv_login_id,
         X_MSG_COUNT          => v_msg_count,
         X_MSG_DATA           => v_msg_data,
         X_RETURN_STATUS      => v_return_status);

      -- Log the user message(s) returned by the API
      IF v_msg_count = 1
      THEN
        -- Only one message
        FEM_ENGINES_PKG.User_Message
          (p_app_name => 'FEM',
           p_msg_text => v_msg_data);

      ELSIF v_msg_count > 1
      THEN
        -- More than one messages
        FOR i IN 1 .. v_msg_count LOOP
          v_msg_data := FND_MSG_PUB.Get(p_msg_index => i, p_encoded => 'F');
          FEM_ENGINES_PKG.User_Message
            (p_app_name => 'FEM',
             p_msg_text => v_msg_data);
        END LOOP;
      END IF; -- IF v_msg_count = 1

      -- -------------------------------------------------------------------
      -- 6. Register a data location entry for this Request if the execution
      --    status of this Request is SUCCESS
      -- -------------------------------------------------------------------
      -- Bug fix 4330346: Changed to register the data location if the execution
      --                  status of this Request is SUCCESS regardless any
      --                  balances are posted to FEM
      IF (v_exec_status = 'SUCCESS')
      THEN
        -- Determine the load status i.e. COMPLETE or INCOMPLETE
        IF (v_req.num_of_rows_selected = v_req.num_of_rows_posted)
        THEN
          -- All rows are posted, so set the load status to COMPLETE
          v_load_status := 'COMPLETE';

        ELSE
          -- Only some rows are posted so set the load status to INCOMPLETE
          v_load_status := 'INCOMPLETE';

        END IF; -- IF (v_req.num_of_rows_selected = v_req.num_of_rows_posted)

        IF (v_xlated_curr_found
            AND v_req.output_dataset_code = v_xlated_curr_ds_code
            AND v_req.cal_period_id = v_xlated_curr_cal_per_id)
        THEN
          -- This translated currency is for this Request, so register the data
          -- location for each translated currency found
          LOOP
            -- Register the data location for a translated currency
            FEM_DIMENSION_UTIL_PKG.Register_Data_Location
              (P_REQUEST_ID   => v_req.request_id,
               P_OBJECT_ID    => pv_rule_obj_id,
               P_TABLE_NAME   => 'FEM_BALANCES',
               P_LEDGER_ID    => pv_ledger_id,
               P_CAL_PER_ID   => v_req.cal_period_id,
               P_DATASET_CD   => v_req.output_dataset_code,
               P_SOURCE_CD    => pv_gl_source_system_code,
               P_LOAD_STATUS  => v_load_status,
               P_AVG_BAL_FLAG => pv_include_avg_bal,
               P_TRANS_CURR   => v_xlated_curr_code);

            -- Get next translated currency
            FETCH xlated_curr_cur INTO v_xlated_curr_ds_code,
                                       v_xlated_curr_cal_per_id,
                                       v_xlated_curr_code;
            IF (xlated_curr_cur%NOTFOUND)
            THEN
              -- No more translated currency is found, so exit
              v_xlated_curr_found := FALSE;
              EXIT;
            ELSE
              -- A translated currency is found
              IF (v_xlated_curr_ds_code <> v_req.output_dataset_code
                  OR v_xlated_curr_cal_per_id <> v_req.cal_period_id)
              THEN
                -- This translated currency is for another request, so exit
                EXIT;
              END IF; -- IF (v_xlated_curr_ds_code <> v_req.output_dataset_code
            END IF; -- IF (xlated_curr_cur%NOTFOUND)

          END LOOP;

        ELSE
          -- No translated currency is found for the output dataset code and
          -- cal period of this Request, so register the data location without
          -- passing any translated currency code
          FEM_DIMENSION_UTIL_PKG.Register_Data_Location
            (P_REQUEST_ID   => v_req.request_id,
             P_OBJECT_ID    => pv_rule_obj_id,
             P_TABLE_NAME   => 'FEM_BALANCES',
             P_LEDGER_ID    => pv_ledger_id,
             P_CAL_PER_ID   => v_req.cal_period_id,
             P_DATASET_CD   => v_req.output_dataset_code,
             P_SOURCE_CD    => pv_gl_source_system_code,
             P_LOAD_STATUS  => v_load_status,
             P_AVG_BAL_FLAG => pv_include_avg_bal);

        END IF; -- IF (v_xlated_curr_found ...

      END IF; -- IF (v_exec_status = 'SUCCESS' AND v_req.num_of_rows_posted > 0)

    END LOOP; -- req_cur Loop

    -- If the translated balances are included, close translated currency cursor
    IF (pv_xlated_bal_option <> 'NONE')
    THEN
      CLOSE xlated_curr_cur;
    END IF; -- IF (pv_xlated_bal_option <> 'NONE')

    -- ---------------------------------------------
    -- 7. Log the passed Final Message and then exit
    -- ---------------------------------------------
    FEM_ENGINES_PKG.Tech_Message
      (P_SEVERITY => pc_log_level_event,
       P_MODULE   => v_module,
       P_APP_NAME => 'FEM',
       P_MSG_NAME => p_final_message_name);
    FEM_ENGINES_PKG.User_Message
      (P_APP_NAME => 'FEM',
       P_MSG_NAME => p_final_message_name);

    -- Log the function exit time to FND_LOG (successful completion)
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => v_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

  EXCEPTION
    WHEN OTHERS THEN
      -- <<< Unexpected database exceptions >>>
      pv_sqlerrm   := SQLERRM;
      pv_callstack := dbms_utility.format_call_stack;

      -- Log the call stack and the Oracle error message to
      -- FND_LOG with the "unexpected exception" severity level.
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => v_module,
       p_msg_text => pv_sqlerrm);
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => v_module,
       p_msg_text => pv_callstack);

      -- Log the Oracle error message to the Concurrent Request Log
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_text => pv_sqlerrm);

      -- Log the function exit time to FND_LOG (with error)
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_203',
         p_token1   => 'FUNC_NAME',
         p_value1   => v_func_name,
         p_token2   => 'TIME',
         p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

  END Final_OGL_Process_Logging;
-- =======================================================================

END FEM_GL_POST_PROCESS_PKG;

/
